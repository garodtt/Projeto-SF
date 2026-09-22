import { LightningElement } from 'lwc';

export default class ChatFixFlow extends LightningElement {

    numeroDoChamado = '';
    mostrarFlow = false;
    mensagemResposta = '';
    variaveisDeEntrada = [];

    handleInputChange(event) {
        this.numeroDoChamado = event.target.value;
    }

    handleConsultarClick() {
        if (!this.numeroDoChamado) {
            this.mensagemResposta = 'Por favor, digite o número do chamado antes de consultar.';
            return;
        }

        this.variaveisDeEntrada = [
            {
                name: 'numeroDoChamado',
                type: 'String',
                value: this.numeroDoChamado
            }
        ];

        this.mensagemResposta = '';
        this.mostrarFlow = true;
    }

    handleFlowStatusChange(event) {
    console.log('Status do Flow recebido:', event.detail.status);
    console.log('Detalhes completos:', JSON.stringify(event.detail));

    if (event.detail.status === 'FINISHED' || event.detail.status === 'FINISHED_SCREEN') {

            const variaveisDeSaida = event.detail.outputVariables;

            const chamadoEncontrado = this.buscarValorDaVariavel(variaveisDeSaida, 'chamadoEncontrado');
            const status = this.buscarValorDaVariavel(variaveisDeSaida, 'statusDoChamado');
            const prioridade = this.buscarValorDaVariavel(variaveisDeSaida, 'prioridadeDoChamado');
            const slaVencimento = this.buscarValorDaVariavel(variaveisDeSaida, 'slaVencimentoDoChamado');
            const slaVencimentoFormatado = this.formatarDataParaPtBr(slaVencimento);

            if (chamadoEncontrado === true || chamadoEncontrado === 'true') {
                this.mensagemResposta =
                    'Encontrei seu chamado! Status: ' + status +
                    '. Prioridade: ' + prioridade +
                    '. SLA de vencimento: ' + slaVencimentoFormatado + '.';
            } else {
                this.mensagemResposta = 'Não encontrei nenhum chamado com esse número. Verifique e tente novamente.';
            }

            this.mostrarFlow = false;
        }
    }

    buscarValorDaVariavel(variaveis, nomeDaVariavel) {
        const variavelEncontrada = variaveis.find(function (variavel) {
            return variavel.name === nomeDaVariavel;
        });
        return variavelEncontrada ? variavelEncontrada.value : null;
    }

    formatarDataParaPtBr(dataISO) {
        if (!dataISO) {
            return '';
        }
        const data = new Date(dataISO);
        return data.toLocaleString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

}
