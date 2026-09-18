trigger ChamadoTecnicoTrigger on Chamado_Tecnico__c (before insert, before update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        ChamadoTecnicoHandler.validarStatusInicial(Trigger.new);
    }
}