public with sharing class ListaChamadosTecnicosController {

    @AuraEnabled(cacheable=true)
    public static List<Chamado_Tecnico__c> buscarChamadosPaginados(Integer tamanhoDaPagina, Integer numeroDaPagina, String termoDeBusca) {

        Integer registrosParaPular = (numeroDaPagina - 1) * tamanhoDaPagina;
        String termoDeBuscaFormatado = '%' + termoDeBusca + '%';

        if (String.isBlank(termoDeBusca)) {
            return [
                SELECT Id, Name, Status__c, Prioridade__c, Data_de_Abertura__c, SLA_Vencimento__c, Equipamento__c, Equipamento__r.Name, Equipamento__r.Conta__r.Name
                FROM Chamado_Tecnico__c
                ORDER BY Data_de_Abertura__c DESC
                LIMIT :tamanhoDaPagina
                OFFSET :registrosParaPular
            ];
        }

        return [
            SELECT Id, Name, Status__c, Prioridade__c, Data_de_Abertura__c, SLA_Vencimento__c, Equipamento__c, Equipamento__r.Name, Equipamento__r.Conta__r.Name
            FROM Chamado_Tecnico__c
            WHERE Name LIKE :termoDeBuscaFormatado
            ORDER BY Data_de_Abertura__c DESC
            LIMIT :tamanhoDaPagina
            OFFSET :registrosParaPular
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Integer contarTotalDeChamados(String termoDeBusca) {

        if (String.isBlank(termoDeBusca)) {
            return [SELECT COUNT() FROM Chamado_Tecnico__c];
        }

        String termoDeBuscaFormatado = '%' + termoDeBusca + '%';
        return [SELECT COUNT() FROM Chamado_Tecnico__c WHERE Name LIKE :termoDeBuscaFormatado];
    }
}