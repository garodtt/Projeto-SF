@isTest
private class GeradorChamadoPreventivoSchedulerTest {

    @isTest
    static void deveAgendarExecucaoDoBatchComSucesso() {

        String expressaoCron = '0 0 6 ? * MON *';

        Test.startTest();
        String jobId = System.schedule(
            'Teste Agendamento Preventivo',
            expressaoCron,
            new GeradorChamadoPreventivoScheduler()
        );
        Test.stopTest();

        CronTrigger jobAgendado = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        System.assertEquals(expressaoCron, jobAgendado.CronExpression, 'A expressao cron deveria ser igual a que foi definida');
        System.assertEquals(0, jobAgendado.TimesTriggered, 'O job ainda nao deveria ter sido executado no momento do teste');
    }
}