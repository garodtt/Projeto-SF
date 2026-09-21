String expressaoCron = '0 0 6 ? * MON *';
System.schedule('Geracao Semanal de Chamados Preventivos', expressaoCron, new GeradorChamadoPreventivoScheduler());
