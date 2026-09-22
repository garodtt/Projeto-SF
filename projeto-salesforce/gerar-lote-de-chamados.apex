// ============================================================
// SCRIPT 2 - LOTE DE CHAMADOS TECNICOS (rodar VARIAS VEZES)
// Cada execucao cria ~1.800 chamados, respeitando os limites
// de governor do Salesforce (max 10.000 linhas de DML por transacao).
// Rode este script 3 a 6 vezes para atingir alguns milhares de chamados.
// Execute via: sf apex run --file gerar-lote-de-chamados.apex
// ============================================================

Integer totalDeChamadosNesteLote = 700;

List<Equipamento__c> todosOsEquipamentos = [
    SELECT Id, Name, Tipo_Equipamento__c, Conta__c, Conta__r.Name
    FROM Equipamento__c
];

if (todosOsEquipamentos.isEmpty()) {
    System.debug('ERRO: nenhum equipamento encontrado. Rode primeiro gerar-cadastros-base.apex');
} else {

    Id contaProblematicaId = null;
        for (Equipamento__c equipamento : todosOsEquipamentos) {
            if (equipamento.Conta__r != null && equipamento.Conta__r.Name != null && equipamento.Conta__r.Name.contains('Ferraz')) {
                contaProblematicaId = equipamento.Conta__c;
                break;
            }
        }

    List<String> descricoesProblema = new List<String>{
        'Equipamento nao liga',
        'Ruido excessivo durante funcionamento',
        'Vazamento identificado',
        'Perda de eficiencia no desempenho',
        'Parada inesperada durante uso',
        'Manutencao preventiva solicitada pelo cliente',
        'Emissao de odor incomum',
        'Superaquecimento constante',
        'Falha eletrica intermitente',
        'Desgaste visivel em componente critico'
    };

    // ---------- ETAPA 1: INSERIR TODOS COMO "ABERTO" ----------

    List<Chamado_Tecnico__c> chamadosParaCriar = new List<Chamado_Tecnico__c>();

    for (Integer i = 0; i < totalDeChamadosNesteLote; i++) {

        Integer indiceEquipamentoAleatorio = Math.mod(Math.abs(Crypto.getRandomInteger()), todosOsEquipamentos.size());
        Equipamento__c equipamentoEscolhido = todosOsEquipamentos[indiceEquipamentoAleatorio];

        Boolean ehContaProblematica = (equipamentoEscolhido.Conta__c == contaProblematicaId);

        String prioridadeEscolhida;
        Integer sorteioPrioridade = Math.mod(Math.abs(Crypto.getRandomInteger()), 10);

        if (ehContaProblematica) {
            prioridadeEscolhida = (sorteioPrioridade < 5) ? 'Urgente' : (sorteioPrioridade < 8 ? 'Alta' : 'Media');
        } else if (sorteioPrioridade < 2) {
            prioridadeEscolhida = 'Urgente';
        } else if (sorteioPrioridade < 5) {
            prioridadeEscolhida = 'Alta';
        } else if (sorteioPrioridade < 8) {
            prioridadeEscolhida = 'Media';
        } else {
            prioridadeEscolhida = 'Baixa';
        }

        String descricaoEscolhida = descricoesProblema[Math.mod(Math.abs(Crypto.getRandomInteger()), descricoesProblema.size())];

        chamadosParaCriar.add(new Chamado_Tecnico__c(
            Equipamento__c = equipamentoEscolhido.Id,
            Descricao_do_Problema__c = descricaoEscolhida + ' - ' + equipamentoEscolhido.Name,
            Prioridade__c = prioridadeEscolhida,
            Status__c = 'Aberto'
        ));
    }

    insert chamadosParaCriar;

    // ---------- ETAPA 2: DEFINIR STATUS FINAL DESEJADO PARA CADA UM ----------

    Map<Id, String> statusFinalDesejadoPorId = new Map<Id, String>();
    Map<Id, Integer> diasAtrasPorId = new Map<Id, Integer>();
    Map<Id, String> prioridadePorId = new Map<Id, String>();

    for (Chamado_Tecnico__c chamado : chamadosParaCriar) {

        Integer diasAtras = Math.mod(Math.abs(Crypto.getRandomInteger()), 240);
        Integer sorteio = Math.mod(Math.abs(Crypto.getRandomInteger()), 10);

        String statusFinalDesejado;
        if (diasAtras > 30) {
            statusFinalDesejado = (sorteio < 7) ? 'Fechado' : 'Resolvido';
        } else if (diasAtras > 7) {
            if (sorteio < 5) {
                statusFinalDesejado = 'Resolvido';
            } else if (sorteio < 8) {
                statusFinalDesejado = 'Em Atendimento';
            } else {
                statusFinalDesejado = 'Aberto';
            }
        } else {
            statusFinalDesejado = (sorteio < 6) ? 'Aberto' : 'Em Atendimento';
        }

        statusFinalDesejadoPorId.put(chamado.Id, statusFinalDesejado);
        diasAtrasPorId.put(chamado.Id, diasAtras);
        prioridadePorId.put(chamado.Id, chamado.Prioridade__c);
    }

    // ---------- ETAPA 3: AVANCAR "ABERTO" -> "EM ATENDIMENTO" (quando necessario) ----------

    List<Chamado_Tecnico__c> paraEmAtendimento = new List<Chamado_Tecnico__c>();

    for (Chamado_Tecnico__c chamado : chamadosParaCriar) {
        String statusFinal = statusFinalDesejadoPorId.get(chamado.Id);
        if (statusFinal != 'Aberto') {
            paraEmAtendimento.add(new Chamado_Tecnico__c(Id = chamado.Id, Status__c = 'Em Atendimento'));
        }
    }

    if (!paraEmAtendimento.isEmpty()) {
        update paraEmAtendimento;
    }

    // ---------- ETAPA 4: AVANCAR "EM ATENDIMENTO" -> STATUS FINAL (Resolvido/Fechado) ----------

    List<Chamado_Tecnico__c> paraStatusFinal = new List<Chamado_Tecnico__c>();

    for (Chamado_Tecnico__c chamado : paraEmAtendimento) {
        String statusFinal = statusFinalDesejadoPorId.get(chamado.Id);
        if (statusFinal == 'Resolvido' || statusFinal == 'Fechado') {
            paraStatusFinal.add(new Chamado_Tecnico__c(Id = chamado.Id, Status__c = statusFinal));
        }
    }

    if (!paraStatusFinal.isEmpty()) {
        update paraStatusFinal;
    }

    // ---------- ETAPA 5: REDISTRIBUIR DATA DE ABERTURA E RECALCULAR SLA ----------

    List<Chamado_Tecnico__c> chamadosComDataAjustada = new List<Chamado_Tecnico__c>();

    for (Chamado_Tecnico__c chamado : chamadosParaCriar) {

        Integer diasAtras = diasAtrasPorId.get(chamado.Id);
        String statusFinal = statusFinalDesejadoPorId.get(chamado.Id);
        String prioridade = prioridadePorId.get(chamado.Id);

        if ((statusFinal == 'Resolvido' || statusFinal == 'Fechado') && diasAtras < 5) {
            diasAtras += 10;
        }

        DateTime novaDataAbertura = DateTime.now().addDays(-diasAtras);

        Integer horasDeSla;
        if (prioridade == 'Urgente') {
            horasDeSla = 4;
        } else if (prioridade == 'Alta') {
            horasDeSla = 8;
        } else if (prioridade == 'Media') {
            horasDeSla = 24;
        } else {
            horasDeSla = 72;
        }

        chamadosComDataAjustada.add(new Chamado_Tecnico__c(
            Id = chamado.Id,
            Data_de_Abertura__c = novaDataAbertura,
            SLA_Vencimento__c = novaDataAbertura.addHours(horasDeSla)
        ));
    }

    update chamadosComDataAjustada;

    System.debug('=== LOTE DE CHAMADOS GERADO COM SUCESSO ===');
    System.debug('Chamados criados neste lote: ' + chamadosParaCriar.size());
    System.debug('>>> Rode este script novamente para adicionar mais um lote <<<');
}
