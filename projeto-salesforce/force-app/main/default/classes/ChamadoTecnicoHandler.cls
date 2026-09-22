public with sharing class ChamadoTecnicoHandler {

    public static void validarStatusInicial(List<Chamado_Tecnico__c> novosChamados) {
        for (Chamado_Tecnico__c chamado : novosChamados) {
            if (chamado.Status__c == 'Resolvido' || chamado.Status__c == 'Fechado') {
                chamado.addError('Um chamado nao pode ser criado diretamente como Resolvido ou Fechado. Ele deve nascer como Aberto.');
            }
        }
    }

    public static void validarTransicaoDeStatus(List<Chamado_Tecnico__c> chamadosAtualizados, Map<Id, Chamado_Tecnico__c> chamadosAntigos) {
        for (Chamado_Tecnico__c chamadoAtualizado : chamadosAtualizados) {
            Chamado_Tecnico__c chamadoAntigo = chamadosAntigos.get(chamadoAtualizado.Id);

            Boolean estavaAberto = chamadoAntigo.Status__c == 'Aberto';
            Boolean estaIndoParaResolvido = chamadoAtualizado.Status__c == 'Resolvido';

            if (estavaAberto && estaIndoParaResolvido) {
                chamadoAtualizado.addError('Um chamado nao pode pular de Aberto direto para Resolvido. Ele deve passar por Em Atendimento antes.');
            }
        }
    }
}