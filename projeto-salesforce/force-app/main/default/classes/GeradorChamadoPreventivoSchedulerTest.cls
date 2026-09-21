@isTest
private class GeradorChamadoPreventivoSchedulerTest {

    private static final String EXPRESSAO_CRON = '0 0 6 15 3 ? 2099';

    @isTest
    static void deveAgendarJobComExpressaoCronCorreta() {

        Test.startTest();
        Id idDoJob = System.schedule(
            'Teste Agendamento Chamados Preventivos',
            EXPRESSAO_CRON,
            new GeradorChamadoPreventivoScheduler()
        );

        CronTrigger jobAgendado = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime, State
            FROM CronTrigger
            WHERE Id = :idDoJob
        ];
        Test.stopTest();

        System.assertEquals(EXPRESSAO_CRON, jobAgendado.CronExpression, 'A expressao CRON do job agendado esta incorreta');
        System.assertEquals(0, jobAgendado.TimesTriggered, 'O job nao deveria ter sido executado antes do Test.stopTest');
        System.assertNotEquals(null, jobAgendado.NextFireTime, 'O job deveria ter uma proxima execucao programada');
    }

    @isTest
    static void deveGerarChamadosPreventivosAoExecutarOScheduler() {

        List<Equipamento__c> equipamentosTeste = new List<Equipamento__c>{
            new Equipamento__c(Name = 'Equipamento Agendado 1', Numero_Serie__c = 'SCHED-001'),
            new Equipamento__c(Name = 'Equipamento Agendado 2', Numero_Serie__c = 'SCHED-002')
        };
        insert equipamentosTeste;

        Test.startTest();
        new GeradorChamadoPreventivoScheduler().execute(null);
        Test.stopTest();

        List<Chamado_Tecnico__c> chamadosGerados = [
            SELECT Id, Equipamento__c, Prioridade__c, Status__c
            FROM Chamado_Tecnico__c
            WHERE Equipamento__c IN :equipamentosTeste
        ];

        System.assertEquals(2, chamadosGerados.size(), 'Deveria ter gerado um chamado preventivo para cada equipamento');
        for (Chamado_Tecnico__c chamado : chamadosGerados) {
            System.assertEquals('Baixa', chamado.Prioridade__c, 'Chamado preventivo deveria ter prioridade Baixa');
            System.assertEquals('Aberto', chamado.Status__c, 'Chamado preventivo deveria ser criado com status Aberto');
        }
    }
}