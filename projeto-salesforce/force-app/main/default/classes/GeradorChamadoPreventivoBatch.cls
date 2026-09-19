public with sharing class GeradorChamadoPreventivoBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext contexto) {
        return Database.getQueryLocator(
            'SELECT Id, Name FROM Equipamento__c'
        );
    }

    public void execute(Database.BatchableContext contexto, List<Equipamento__c> equipamentosDoLote) {

        List<Chamado_Tecnico__c> chamadosPreventivosParaCriar = new List<Chamado_Tecnico__c>();

        for (Equipamento__c equipamento : equipamentosDoLote) {

            Chamado_Tecnico__c chamadoPreventivo = new Chamado_Tecnico__c(
                Equipamento__c = equipamento.Id,
                Descricao_do_Problema__c = 'Manutencao preventiva programada para o equipamento ' + equipamento.Name,
                Prioridade__c = 'Baixa',
                Status__c = 'Aberto'
            );

            chamadosPreventivosParaCriar.add(chamadoPreventivo);
        }

        insert chamadosPreventivosParaCriar;
    }

    public void finish(Database.BatchableContext contexto) {
        System.debug('Geracao de chamados preventivos finalizada com sucesso.');
    }
}