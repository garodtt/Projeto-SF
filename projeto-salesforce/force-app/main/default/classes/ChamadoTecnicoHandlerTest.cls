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
    @isTest
    static void deveBloquearPuloDeAbertoParaResolvido() {

        Equipamento__c equipamentoTeste = new Equipamento__c(Name = 'Equipamento Teste 3', Numero_Serie__c = 'TEST-003');
        insert equipamentoTeste;

        Chamado_Tecnico__c chamado = new Chamado_Tecnico__c(
            Equipamento__c = equipamentoTeste.Id,
            Descricao_do_Problema__c = 'Teste de transicao',
            Prioridade__c = 'Media',
            Status__c = 'Aberto'
        );
        insert chamado;

        chamado.Status__c = 'Resolvido';

        Boolean erroCapturado = false;
        Test.startTest();
        try {
            update chamado;
        } catch (DmlException e) {
            erroCapturado = true;
        }
        Test.stopTest();

        System.assertEquals(true, erroCapturado, 'Deveria bloquear pulo direto de Aberto para Resolvido');
    }

    @isTest
    static void devePermitirTransicaoDeEmAtendimentoParaResolvido() {

        Equipamento__c equipamentoTeste = new Equipamento__c(Name = 'Equipamento Teste 4', Numero_Serie__c = 'TEST-004');
        insert equipamentoTeste;

        Chamado_Tecnico__c chamado = new Chamado_Tecnico__c(
            Equipamento__c = equipamentoTeste.Id,
            Descricao_do_Problema__c = 'Teste de transicao valida',
            Prioridade__c = 'Media',
            Status__c = 'Aberto'
        );
        insert chamado;

        chamado.Status__c = 'Em Atendimento';
        update chamado;

        chamado.Status__c = 'Resolvido';
        Test.startTest();
        update chamado;
        Test.stopTest();

        Chamado_Tecnico__c chamadoAtualizado = [SELECT Status__c FROM Chamado_Tecnico__c WHERE Id = :chamado.Id];
        System.assertEquals('Resolvido', chamadoAtualizado.Status__c, 'Deveria permitir Em Atendimento -> Resolvido');
    }


}