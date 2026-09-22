public with sharing class WidgetChatMatiasController {

    public class ResultadoConsulta {
        @AuraEnabled public Boolean chamadoEncontrado;
        @AuraEnabled public String status;
        @AuraEnabled public String prioridade;
        @AuraEnabled public DateTime slaVencimento;
    }

    @AuraEnabled
    public static ResultadoConsulta consultarStatusDoChamado(String numeroDoChamado) {

        Map<String, Object> parametrosDeEntrada = new Map<String, Object>{
            'numeroDoChamado' => numeroDoChamado
        };

        Flow.Interview.Consultar_Status_Do_Chamado execucaoDoFlow =
            new Flow.Interview.Consultar_Status_Do_Chamado(parametrosDeEntrada);

        execucaoDoFlow.start();

        ResultadoConsulta resultado = new ResultadoConsulta();
        resultado.chamadoEncontrado = (Boolean) execucaoDoFlow.getVariableValue('chamadoEncontrado');
        resultado.status = (String) execucaoDoFlow.getVariableValue('statusDoChamado');
        resultado.prioridade = (String) execucaoDoFlow.getVariableValue('prioridadeDoChamado');
        resultado.slaVencimento = (DateTime) execucaoDoFlow.getVariableValue('slaVencimentoDoChamado');

        return resultado;
    }
}