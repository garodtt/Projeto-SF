@isTest
private class ChamadoTecnicoHandlerTest {

    @isTest
    static void deveBloquearCriacaoComStatusResolvido() {

        Equipamento__c equipamentoTeste = new Equipamento__c(
            Name = 'Equipamento Teste',
            Numero_Serie__c = 'TEST-001'
        );
        insert equipamentoTeste;

        Chamado_Tecnico__c chamado = new Chamado_Tecnico__c(
            Equipamento__c = equipamentoTeste.Id,
            Descricao_do_Problema__c = 'Teste de bloqueio',
            Prioridade__c = 'Baixa',
            Status__c = 'Resolvido'
        );

        Boolean erroCapturado = false;
        String mensagemErro = '';

        Test.startTest();
        try {
            insert chamado;
        } catch (DmlException e) {
            erroCapturado = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, erroCapturado, 'Deveria ter bloqueado a criacao com status Resolvido');
        System.assert(mensagemErro.contains('nao pode ser criado diretamente'), 'Mensagem de erro incorreta');
    }

    @isTest
    static void devePermitirCriacaoComStatusAberto() {

        Equipamento__c equipamentoTeste = new Equipamento__c(
            Name = 'Equipamento Teste 2',
            Numero_Serie__c = 'TEST-002'
        );
        insert equipamentoTeste;

        Chamado_Tecnico__c chamado = new Chamado_Tecnico__c(
            Equipamento__c = equipamentoTeste.Id,
            Descricao_do_Problema__c = 'Teste de sucesso',
            Prioridade__c = 'Alta',
            Status__c = 'Aberto'
        );

        Test.startTest();
        insert chamado;
        Test.stopTest();

        Chamado_Tecnico__c chamadoSalvo = [
            SELECT Id, Status__c 
            FROM Chamado_Tecnico__c 
            WHERE Id = :chamado.Id
        ];

        System.assertEquals('Aberto', chamadoSalvo.Status__c, 'O chamado deveria ter sido salvo com status Aberto');
    }
}