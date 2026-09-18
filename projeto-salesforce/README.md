# FixFlow — Gestão Inteligente de Manutenção e Suporte Técnico

Projeto de portfólio Salesforce simulando um sistema real de gestão de manutenção técnica: clientes com contratos de manutenção, equipamentos instalados e abertura de chamados técnicos com cálculo automático de SLA.

Construído em uma Trailhead Playground, com todo o código versionado via Salesforce CLI (SFDX).

---

## 🎯 Objetivo do Projeto

Simular um cenário de negócio completo (empresa de manutenção de equipamentos) para demonstrar, de forma prática, o uso de:

- Modelagem de dados relacional no Salesforce
- Automação declarativa com Flow Builder (Record-Triggered e Screen Flow)
- Apex (em construção)
- Integração com GitHub via SFDX
- Boas práticas de documentação e versionamento

---

## 🗂️ Modelo de Dados

```
Account (padrão do Salesforce)
   │
   ├── Contrato_de_Manutencao__c
   │      ├── Data_de_Inicio__c
   │      ├── Data_de_Fim__c
   │      ├── Status__c (Ativo / Vencido / Cancelado)
   │      ├── Valor_Mensal__c
   │      └── Conta__c (Lookup → Account)
   │
   └── Equipamento__c
          ├── Numero_Serie__c
          ├── Tipo_Equipamento__c (Ar-Condicionado / Elevador / Maquina Industrial)
          ├── Data_Instalacao__c
          ├── Conta__c (Lookup → Account)
          │
          └── Chamado_Tecnico__c
                 ├── Equipamento__c (Lookup → Equipamento__c)
                 ├── Descricao_do_Problema__c
                 ├── Prioridade__c (Baixa / Media / Alta / Urgente)
                 ├── Status__c (Aberto / Em Atendimento / Aguardando Peca / Resolvido / Fechado)
                 ├── Data_de_Abertura__c
                 └── SLA_Vencimento__c
```

---

## ⚙️ Automações (Flow Builder)

### 1. Calcular SLA do Chamado (Record-Triggered Flow)

**Objetivo**: sempre que um novo Chamado Técnico é criado, o sistema calcula automaticamente a data/hora limite de atendimento (SLA), com base na prioridade — sem nenhuma ação manual.

| Prioridade | SLA calculado |
|---|---|
| Urgente | Data/hora atual + 4 horas |
| Alta | Data/hora atual + 8 horas |
| Media | Data/hora atual + 24 horas |
| Baixa (default) | Data/hora atual + 72 horas |

Também preenche automaticamente o campo `Data_de_Abertura__c` no momento da criação do registro.

**Estrutura**:
```
Start (Record-Triggered: Chamado_Tecnico__c criado)
  └── Preencher Data Abertura (Update Triggering Record)
        └── Decision: Verificar Prioridade
              ├── Urgente → SLA +4h
              ├── Alta → SLA +8h
              ├── Media → SLA +24h
              └── Baixa (default) → SLA +72h
```

### 2. Abrir Chamado Tecnico (Screen Flow)

**Objetivo**: interface simples para o cliente (ou atendente) abrir um chamado técnico, selecionando o equipamento com problema, descrevendo a ocorrência e definindo a prioridade.

**Estrutura**:
```
Start
  └── Buscar Equipamentos (Get Records: todos os Equipamento__c)
        └── Screen: Abrir Chamado Tecnico
              ├── Selecione o Equipamento (Picklist + Record Choice Set)
              ├── Descreva o Problema (Long Text Area)
              └── Prioridade (Picklist estático)
        └── Criar Chamado Tecnico (Create Records)
```

Ao finalizar, o Chamado Técnico é criado com `Status__c = "Aberto"`, o que dispara automaticamente o Flow **Calcular SLA do Chamado** (automação encadeada).

---

## 🔧 Decisão técnica: por que Record Choice Set em vez de Lookup

Durante a construção do Screen Flow, o componente padrão **Lookup** apresentou instabilidade na Trailhead Playground utilizada: mesmo configurado corretamente (Object API Name e Field API Name válidos), a busca de registros não retornava resultados de forma consistente, mesmo com os registros existindo e sendo encontrados normalmente pela busca global do Salesforce.

**Solução adotada**: substituição do componente Lookup por um **Picklist alimentado por um Record Choice Set**, construído a partir de um elemento **Get Records** que busca todos os equipamentos antecipadamente. Essa abordagem se mostrou mais estável neste ambiente.

**Trade-off identificado**: essa solução funciona bem para volumes pequenos/médios de registros. Em um cenário de produção com um volume muito grande de equipamentos, a abordagem recomendada seria investigar a causa raiz da instabilidade do Lookup (permissões, índice de busca) ou utilizar um componente Lightning Web Component (LWC) customizado com busca server-side.

---

## 🚀 Como usar este projeto

### Pré-requisitos
- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli)
- Uma org Salesforce (Trailhead Playground, Developer Edition ou Sandbox)

### Passos

```bash
# Clonar o repositório
git clone https://github.com/garodtt/Projeto-SF.git
cd Projeto-SF/projeto-salesforce

# Autenticar na sua org
sf org login web --alias minha-org --set-default

# Fazer deploy do projeto
sf project deploy start
```

---

## 📌 Roadmap do Projeto

- [x] Modelagem de dados (Equipamento, Contrato de Manutenção, Chamado Técnico)
- [x] Flow: cálculo automático de SLA
- [x] Flow: abertura de chamado via tela (Screen Flow)
- [ ] Apex: Trigger com handler pattern
- [ ] Apex: Batch + Schedulable para chamados preventivos
- [ ] Apex: integração via callout externo
- [ ] Testes unitários (Apex)
- [ ] Agentforce: assistente virtual para consulta de status de chamados
- [ ] CI/CD com GitHub Actions
- [ ] Experience Cloud (portal do cliente)

---

## 🛠️ Stack Técnica

- Salesforce Platform (Flow Builder, Apex — em construção)
- Salesforce CLI (SFDX)
- Git / GitHub
- VS Code + Salesforce Extension Pack

---

## 👤 Autor

Vinicius Dias
Projeto desenvolvido para fins de portfólio profissional em Salesforce.