public with sharing class ChamadoTecnicoHandler {

    public static void validarStatusInicial(List<Chamado_Tecnico__c> novosChamados) {

        for (Chamado_Tecnico__c chamado : novosChamados) {

            if (chamado.Status__c == 'Resolvido' || chamado.Status__c == 'Fechado') {
                chamado.addError('Um chamado nao pode ser criado diretamente como Resolvido ou Fechado. Ele deve nascer como Aberto.');
            }
        }
    }
}