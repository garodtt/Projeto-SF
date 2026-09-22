import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import buscarChamadosPaginados from '@salesforce/apex/ListaChamadosTecnicosController.buscarChamadosPaginados';
import contarTotalDeChamados from '@salesforce/apex/ListaChamadosTecnicosController.contarTotalDeChamados';

const TAMANHO_DA_PAGINA = 20;
const ATRASO_DA_BUSCA_EM_MILISSEGUNDOS = 400;

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
                this.chamados = resultado.map((chamado) => {
                    return {
                        ...chamado,
                        nomeDoCliente: this.obterNomeDoCliente(chamado),
                        classeDoStatus: this.obterClasseDoStatus(chamado.Status__c),
                        classeDaPrioridade: this.obterClasseDaPrioridade(chamado.Prioridade__c),
                        dataAberturaFormatada: this.formatarData(chamado.Data_de_Abertura__c)
                    };
                });
                this.estaCarregando = false;
            })
            .catch((erro) => {
                console.error('Erro ao buscar chamados:', erro);
                this.estaCarregando = false;
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