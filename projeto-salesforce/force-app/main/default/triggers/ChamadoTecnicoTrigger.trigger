trigger ChamadoTecnicoTrigger on Chamado_Tecnico__c (before insert, before update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            ChamadoTecnicoHandler.validarStatusInicial(Trigger.new);
        }
        if (Trigger.isUpdate) {
            ChamadoTecnicoHandler.validarTransicaoDeStatus(Trigger.new, Trigger.oldMap);
        }
    }
}