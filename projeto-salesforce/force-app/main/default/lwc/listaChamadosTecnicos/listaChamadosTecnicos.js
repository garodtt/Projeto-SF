import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import buscarChamadosPaginados from '@salesforce/apex/ListaChamadosTecnicosController.buscarChamadosPaginados';
import contarTotalDeChamados from '@salesforce/apex/ListaChamadosTecnicosController.contarTotalDeChamados';
import atualizarStatusDoChamado from '@salesforce/apex/ListaChamadosTecnicosController.atualizarStatusDoChamado';

const TAMANHO_DA_PAGINA = 20;
const ATRASO_DA_BUSCA_EM_MILISSEGUNDOS = 400;

const PROXIMO_STATUS_POR_STATUS_ATUAL = {
    'Aberto': { proximoStatus: 'Em Atendimento', rotulo: 'Iniciar Atendimento' },
    'Em Atendimento': { proximoStatus: 'Resolvido', rotulo: 'Marcar como Resolvido' },
    'Resolvido': { proximoStatus: 'Fechado', rotulo: 'Fechar Chamado' }
};

export default class ListaChamadosTecnicos extends NavigationMixin(LightningElement) {

    chamados = [];
    paginaAtual = 1;
    totalDePaginas = 1;
    estaCarregando = true;
    termoDeBusca = '';

    temporizadorDaBusca;

    connectedCallback() {
        this.carregarDados();
    }

    carregarDados() {
        this.estaCarregando = true;

        contarTotalDeChamados({ termoDeBusca: this.termoDeBusca })
            .then((total) => {
                this.totalDePaginas = Math.max(1, Math.ceil(total / TAMANHO_DA_PAGINA));
                return buscarChamadosPaginados({
                    tamanhoDaPagina: TAMANHO_DA_PAGINA,
                    numeroDaPagina: this.paginaAtual,
                    termoDeBusca: this.termoDeBusca
                });
            })
            .then((resultado) => {
                this.chamados = resultado.map((chamado) => this.montarChamadoParaExibicao(chamado));
                this.estaCarregando = false;
            })
            .catch((erro) => {
                console.error('Erro ao buscar chamados:', erro);
                this.estaCarregando = false;
            });
    }

    montarChamadoParaExibicao(chamado) {

        const slaVencido = this.verificarSlaVencido(chamado.SLA_Vencimento__c, chamado.Status__c);
        const infoDeAcao = PROXIMO_STATUS_POR_STATUS_ATUAL[chamado.Status__c];

        return {
            ...chamado,
            nomeDoCliente: this.obterNomeDoCliente(chamado),
            classeDoStatus: this.obterClasseDoStatus(chamado.Status__c),
            classeDaPrioridade: this.obterClasseDaPrioridade(chamado.Prioridade__c),
            dataAberturaFormatada: this.formatarData(chamado.Data_de_Abertura__c),
            slaFormatado: this.formatarData(chamado.SLA_Vencimento__c),
            slaVencido: slaVencido,
            classeDaLinha: slaVencido ? 'slds-hint-parent linha-sla-vencido' : 'slds-hint-parent',
            temAcaoDisponivel: Boolean(infoDeAcao),
            proximoStatus: infoDeAcao ? infoDeAcao.proximoStatus : '',
            rotuloDaAcao: infoDeAcao ? infoDeAcao.rotulo : ''
        };
    }

    verificarSlaVencido(slaVencimento, status) {
        if (!slaVencimento) {
            return false;
        }
        const statusFinalizados = ['Resolvido', 'Fechado'];
        if (statusFinalizados.includes(status)) {
            return false;
        }
        return new Date(slaVencimento).getTime() < Date.now();
    }

    handleSelecionarAcao(event) {
        const idDoChamado = event.currentTarget.dataset.id;
        const novoStatus = event.detail.value;

        atualizarStatusDoChamado({ idDoChamado: idDoChamado, novoStatus: novoStatus })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Sucesso',
                        message: 'Status atualizado para "' + novoStatus + '"',
                        variant: 'success'
                    })
                );
                this.carregarDados();
            })
            .catch((erro) => {
                const mensagemDeErro = erro && erro.body && erro.body.message
                    ? erro.body.message
                    : 'Não foi possível atualizar o status.';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: mensagemDeErro,
                        variant: 'error'
                    })
                );
            });
    }

    handleMudancaNaBusca(event) {
        const valorDigitado = event.target.value;

        clearTimeout(this.temporizadorDaBusca);

        this.temporizadorDaBusca = setTimeout(() => {
            this.termoDeBusca = valorDigitado;
            this.paginaAtual = 1;
            this.carregarDados();
        }, ATRASO_DA_BUSCA_EM_MILISSEGUNDOS);
    }

    obterNomeDoCliente(chamado) {
        if (chamado.Equipamento__r && chamado.Equipamento__r.Conta__r) {
            return chamado.Equipamento__r.Conta__r.Name;
        }
        return '';
    }

    obterClasseDoStatus(status) {
        const classesBase = 'slds-badge ';
        if (status === 'Aberto') {
            return classesBase + 'slds-theme_warning';
        } else if (status === 'Em Atendimento') {
            return classesBase + 'slds-theme_info';
        } else if (status === 'Resolvido') {
            return classesBase + 'slds-theme_success';
        }
        return classesBase;
    }

    obterClasseDaPrioridade(prioridade) {
        const classesBase = 'slds-badge ';
        if (prioridade === 'Urgente') {
            return classesBase + 'slds-theme_error';
        } else if (prioridade === 'Alta') {
            return classesBase + 'slds-theme_warning';
        }
        return classesBase;
    }

    formatarData(dataISO) {
        if (!dataISO) {
            return '';
        }
        const data = new Date(dataISO);
        return data.toLocaleDateString('pt-BR');
    }

    handleClickNaLinha(event) {
        const idDoChamadoClicado = event.currentTarget.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: idDoChamadoClicado,
                objectApiName: 'Chamado_Tecnico__c',
                actionName: 'view'
            }
        });
    }

    handleProximaPagina() {
        if (this.paginaAtual < this.totalDePaginas) {
            this.paginaAtual++;
            this.carregarDados();
        }
    }

    handlePaginaAnterior() {
        if (this.paginaAtual > 1) {
            this.paginaAtual--;
            this.carregarDados();
        }
    }

    get desabilitarBotaoProxima() {
        return this.paginaAtual >= this.totalDePaginas;
    }

    get desabilitarBotaoAnterior() {
        return this.paginaAtual <= 1;
    }

    get nenhumResultadoEncontrado() {
        return this.chamados.length === 0;
    }
}