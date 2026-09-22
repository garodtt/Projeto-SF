import { LightningElement } from 'lwc';
import consultarStatusDoChamado from '@salesforce/apex/WidgetChatMatiasController.consultarStatusDoChamado';

let contadorDeMensagens = 0;

export default class WidgetChatMatias extends LightningElement {

    chatAberto = false;
    textoDigitado = '';
    estaConsultando = false;

    mensagens = [
        this.criarMensagem('Olá! Sou o Matias. Digite o número do seu chamado técnico (ex: CH-0001) para consultar o status.', false)
    ];

    handleAbrirChat() {
        this.chatAberto = true;
    }

    handleFecharChat() {
        this.chatAberto = false;
    }

    handleMudancaNoTexto(event) {
        this.textoDigitado = event.target.value;
    }

    handleTeclaPressionada(event) {
        if (event.key === 'Enter') {
            this.handleEnviarMensagem();
        }
    }

    handleEnviarMensagem() {
        const numeroDigitado = this.textoDigitado.trim();

        if (!numeroDigitado) {
            return;
        }

        this.mensagens = [...this.mensagens, this.criarMensagem(numeroDigitado, true)];
        this.textoDigitado = '';
        this.estaConsultando = true;
        this.rolarParaOFinalDoChat();

        consultarStatusDoChamado({ numeroDoChamado: numeroDigitado })
            .then((resultado) => {
                const textoDaResposta = this.montarTextoDaResposta(resultado);
                this.mensagens = [...this.mensagens, this.criarMensagem(textoDaResposta, false)];
            })
            .catch(() => {
                this.mensagens = [
                    ...this.mensagens,
                    this.criarMensagem('Ocorreu um erro ao consultar o chamado. Tente novamente.', false)
                ];
            })
            .finally(() => {
                this.estaConsultando = false;
                this.rolarParaOFinalDoChat();
            });
    }

    montarTextoDaResposta(resultado) {
        if (!resultado.chamadoEncontrado) {
            return 'Não encontrei nenhum chamado com esse número. Verifique e tente novamente.';
        }

        const dataFormatada = this.formatarData(resultado.slaVencimento);

        return 'Encontrei seu chamado!\nStatus: ' + resultado.status +
            '\nPrioridade: ' + resultado.prioridade +
            '\nSLA de vencimento: ' + dataFormatada;
    }

    formatarData(dataISO) {
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

    criarMensagem(texto, ehDoUsuario) {
        contadorDeMensagens++;
        return {
            id: contadorDeMensagens,
            texto: texto,
            classeDaBolha: ehDoUsuario ? 'bolha-do-usuario' : 'bolha-do-bot'
        };
    }

    rolarParaOFinalDoChat() {
        setTimeout(() => {
            const corpoDoChat = this.template.querySelector('[data-id="corpo-do-chat"]');
            if (corpoDoChat) {
                corpoDoChat.scrollTop = corpoDoChat.scrollHeight;
            }
        }, 50);
    }
}