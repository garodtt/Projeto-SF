// ============================================================
// SCRIPT 1 - CADASTROS BASE (rodar UMA UNICA VEZ)
// Execute via: sf apex run --file gerar-cadastros-base.apex
// ============================================================

// ---------- 1. CRIAR CONTAS (CLIENTES) ----------

List<Account> contas = new List<Account>();
contas.add(new Account(Name = 'Condominio Vista Alegre'));
contas.add(new Account(Name = 'Shopping Center Norte Sul'));
contas.add(new Account(Name = 'Industria Metalurgica Ferraz'));
contas.add(new Account(Name = 'Hospital Sao Lucas'));
contas.add(new Account(Name = 'Hotel Costa Azul'));
contas.add(new Account(Name = 'Edificio Comercial Prime Office'));
contas.add(new Account(Name = 'Supermercado Boa Compra'));
contas.add(new Account(Name = 'Escola Tecnica Horizonte'));
contas.add(new Account(Name = 'Distribuidora Alimentos Sul'));
contas.add(new Account(Name = 'Clinica Odontologica Sorriso'));
contas.add(new Account(Name = 'Fabrica de Autopecas Rodamax'));
contas.add(new Account(Name = 'Centro Empresarial Atlantico'));

insert contas;

// ---------- 2. CRIAR EQUIPAMENTOS (VOLUME MAIOR: ~8 a 12 por conta) ----------

List<Equipamento__c> todosOsEquipamentos = new List<Equipamento__c>();
Integer contadorSerie = 1000;

for (Account conta : contas) {

    Integer quantidadeDeEquipamentos = 8 + Math.mod(Math.abs(Crypto.getRandomInteger()), 5); // 8 a 12 por conta

    for (Integer i = 0; i < quantidadeDeEquipamentos; i++) {

        String tipoEscolhido;

        if (conta.Name.contains('Industria') || conta.Name.contains('Hospital') || conta.Name.contains('Fabrica')) {
            tipoEscolhido = (Math.mod(i, 2) == 0) ? 'Máquina Industrial' : 'Elevador';
        } else if (conta.Name.contains('Shopping') || conta.Name.contains('Hotel') || conta.Name.contains('Prime Office') || conta.Name.contains('Atlantico')) {
            tipoEscolhido = (Math.mod(i, 2) == 0) ? 'Elevador' : 'Ar-Condicionado';
        } else {
            tipoEscolhido = 'Ar-Condicionado';
        }

        contadorSerie++;

        todosOsEquipamentos.add(new Equipamento__c(
            Name = tipoEscolhido + ' - ' + conta.Name + ' - Unidade ' + (i + 1),
            Numero_Serie__c = 'SN-' + contadorSerie,
            Tipo_Equipamento__c = tipoEscolhido,
            Data_Instalacao__c = Date.today().addYears(-(1 + Math.mod(i, 6))),
            Conta__c = conta.Id
        ));
    }
}

insert todosOsEquipamentos;

// ---------- 3. CRIAR CONTRATOS DE MANUTENCAO ----------

List<Contrato_de_Manutencao__c> contratos = new List<Contrato_de_Manutencao__c>();

Integer indiceConta = 0;
for (Account conta : contas) {

    Date dataInicio = Date.today().addMonths(-(6 + indiceConta));
    Date dataFim;
    String statusContrato;

    if (Math.mod(indiceConta, 3) == 0) {
        dataFim = Date.today().addDays(15 + indiceConta);
        statusContrato = 'Ativo';
    } else if (Math.mod(indiceConta, 5) == 0) {
        dataFim = Date.today().addDays(-10);
        statusContrato = 'Vencido';
    } else {
        dataFim = Date.today().addMonths(6);
        statusContrato = 'Ativo';
    }

    Decimal valorBase = 1500 + (indiceConta * 350);

    contratos.add(new Contrato_de_Manutencao__c(
        Name = 'Contrato ' + conta.Name,
        Data_de_Inicio__c = dataInicio,
        Data_de_Fim__c = dataFim,
        Status__c = statusContrato,
        Valor_Mensal__c = valorBase,
        Conta__c = conta.Id
    ));

    indiceConta++;
}

insert contratos;

System.debug('=== CADASTROS BASE CRIADOS COM SUCESSO ===');
System.debug('Contas criadas: ' + contas.size());
System.debug('Equipamentos criados: ' + todosOsEquipamentos.size());
System.debug('Contratos criados: ' + contratos.size());
System.debug('>>> Agora rode gerar-lote-de-chamados.apex varias vezes para popular os chamados tecnicos <<<');
