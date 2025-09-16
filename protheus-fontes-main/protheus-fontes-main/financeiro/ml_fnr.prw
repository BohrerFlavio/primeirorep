/*
Programa:   ML_FNR
Autor:      Robert Koch
Data:       29/11/2001
Cliente:    Frigorífico Silva
Descricao:  Relatorio de movto financeiro (FK5) realizado por natureza/dia.

Historico de alteracoes:
10/12/2001 - Robert Koch - Incluido parametro de quebra: por dia ou por mes
- Alteracoes no layout de impressao. Ok.
27/12/2001 - Robert Koch - Alteracoes no layout de impressao para ficar semelhante ao ML_NAT
10/01/2002 - Robert Koch - Nao estava ordenando corretamente os meses
- Incluido parametro "Saldo inicial" a ser informado pelo usuario
- Removido filtro por prefixo por nao ser usado.
- Finalizacao dos ajustes e liberacao para testes dos usuarios
16/01/2002 - Leandro Scapini - Filtrado FK5_BANCO = '   ' nas querys.
- Filtrado FK5_TPDOC = 'DC' nas querys.
17/01/2002 - Robert Koch - Separadas as querys de recebimentos e pagamentos por que
os pagamentos sao filtrados pelo campo FK5_DATA e os re-
cebimentos pelo campo FK5_DTDISP.
- Criado mais um arquivo de trabalho com os cancelamentos
de baixas, que sao posteriormente descontados diretamente
em _aMatriz, pois nao teve como filtrar as baixas
canceladas do FK5.
07/10/2003 - Robert Koch - Query mensal tinha problemas
- Ajustes no layout para caber mais linhas na folha
03/05/2007 - Jose Vergani - Ajuste no calculo do saldo anterior

As querys foram montadas tomando por base a tabela abaixo, obtida da Siga SP em 29/11/01:

DESCRICAO DO FK5_TPDOC:
AP	Aplicacao Financeira
BA	Baixa Automatica ou Baixa que nao tenha movimentacao bancaria
BD	Bordero em cobranca descontada
BL	Baixa Aplicacao Longo Prazo
C2	Correcao Monetaria na cobranca descontada
CB	Cancelamento Bordero em Cobranca Descontada
CD	Cheque Pre-Datado
CH	Cheque
CM	Correcao Monetaria
CP	Compensacao 
CX	Movimentacao do Caixa
D2	Desconto na cobranca descontada
DB	Despesas Bancarias
DC	Desconto
DV	Devolucao - Sigaloja
EP	Emprestimo
ES	Estorno de movimentacao
IB	Impostos Bancarios
J2	Juro na cobranca descontada
JR	Juro
LJ	Entrada Dinheiro pelo Caixa - Sigaloja
M2	Multa na cobranca descontada
MT	Multa
NCC	Nota de Credito Cliente
NDF	Nota de Debito Fornecedor
PA	Pagamento Antecipado
PE	Pagamento Emprestimo
RA	Recebimento Antecipado
RF	Resgate de Aplicacao Financeira
R$	Entrada em dinheiro - Sigaloja
SG	Sangria do Caixa - Sigaloja
TC	Entrada de Troco - Sigaloja
TE	Transferencia Estornada
TL	Valor de "Tolerancia" Recebido sobre o titulo
TR	Transferencia
VL	Movimentacao Bancaria ou Baixas que movimentem banco
V2	Movimentacao Bancaria na Cobranca Descontada

*/

#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

User Function ML_FNR()

	// Variaveis obrigatorias dos programas de relatorio
	_sTitulo  := "Movimento financeiro REALIZADO por natureza"
	_sTamanho := "G"
	cDesc1    := ""
	cDesc2    := ""
	cDesc3    := ""
	cString   := "SE1"
	aReturn   := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nLastKey  := 0
	cPerg     := "ML_FNW"
	wnrel     := "ML_FNR"
	nTipo     := 0
	limite    := 220
	aReturn   := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }

	// Perguntas no arquivo SX1
	_ValidPerg()
	Pergunte(cPerg,.F.)

	// Envia controle para a funcao SETPRINT
	wnrel:=SetPrint(cString,wnrel,cPerg,_sTitulo,cDesc1,cDesc2,cDesc3,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	_sTitulo  += " entre " + dtoc (mv_par01) + " e " + dtoc (mv_par02)
	RptStatus({|| RptDetail()})
Return



// --------------------------------------------------------------------------
Static Function RptDetail()
	local _sWhere := ""  // Clausula where basica para pagamentos e recebimentos

	// Inicializa os codigos de caracter Comprimido/Normal da impressora e cabecalho
	nTipo    := IIF (aReturn [4] == 1, 15, 18)
	m_pag    := 1
	_sTexto1 := ""
	_sTexto2 := ""
	li       := 0

	_sWhere := "   FROM " + RETSQLNAME ("SED") + " SED, " + ;
	RETSQLNAME ("FK5") + " FK5 " + ;
	"  WHERE SED.D_E_L_E_T_ <> '*'" + ;
	"    AND SED.ED_FILIAL  =  '" + xfilial ("SED") + "'" + ;
	"    AND FK5.FK5_NATURE =  SED.ED_CODIGO" + ;
	"    AND FK5.D_E_L_E_T_ <> '*'" + ;
	"    AND FK5.FK5_BANCO   <> '   '" + ;
	"    AND FK5.FK5_TPDOC NOT IN ('TR', 'ES', 'TE', 'CP', 'JR', 'DC', 'MT', 'V2', 'J2')" + ;  
	"    AND FK5.FK5_NATURE BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'" + ;
	"    AND FK5.FK5_FILIAL = '" + xfilial ("FK5") + "'"

	// tirado tipodoc 'EC'

	SetRegua (5)  // Inicio + query + montagem de _aDias + 1 de reserva...
	incregua ()
	if mv_par05 == 1  // Quebra por dia: uma query para pagamentos e outra para recebimentos
		_cQueryP := " SELECT FK5.FK5_NATURE NATUREZA, FK5.FK5_DATA DT_MOVTO, SUM (FK5.FK5_VALOR) TOTAL " + ;
		_sWhere + ;
		"    AND FK5.FK5_RECPAG = 'P'" + ;
		"    AND FK5.FK5_DATA BETWEEN '" + dtos (mv_par01) + "' AND '" + dtos (mv_par02) + "'" + ;
		"  GROUP BY FK5.FK5_NATURE, FK5.FK5_DATA"

		_cQueryR := " SELECT FK5.FK5_NATURE NATUREZA, FK5.FK5_DTDISP DT_MOVTO, SUM (FK5.FK5_VALOR) TOTAL " + ;
		_sWhere + ;
		"    AND FK5.FK5_RECPAG = 'R'" + ;
		"    AND FK5.FK5_DTDISP BETWEEN '" + dtos (mv_par01) + "' AND '" + dtos (mv_par02) + "'" + ;
		"  GROUP BY FK5.FK5_NATURE, FK5.FK5_DTDISP"
	else  // Quebra por mes: uma query para pagamentos e outra para recebimentos
		_cQueryP := " SELECT FK5.FK5_NATURE NATUREZA, YEAR (FK5.FK5_DATA) ANO, MONTH (FK5.FK5_DATA) MES, SUM (FK5.FK5_VALOR) TOTAL " + ;
		_sWhere + ;
		"    AND FK5.FK5_RECPAG = 'P'" + ;
		"    AND FK5.FK5_DATA BETWEEN '" + dtos (mv_par01) + "' AND '" + dtos (mv_par02) + "'" + ;
		"  GROUP BY FK5.FK5_NATURE, YEAR (FK5.FK5_DATA), MONTH (FK5.FK5_DATA)"

		_cQueryR := " SELECT FK5.FK5_NATURE NATUREZA, YEAR (FK5.FK5_DTDISP) ANO, MONTH (FK5.FK5_DTDISP) MES, SUM (FK5.FK5_VALOR) TOTAL " + ;
		_sWhere + ;
		"    AND FK5.FK5_RECPAG = 'R'" + ;
		"    AND FK5.FK5_DTDISP BETWEEN '" + dtos (mv_par01) + "' AND '" + dtos (mv_par02) + "'" + ;
		"  GROUP BY FK5.FK5_NATURE, YEAR (FK5.FK5_DTDISP), MONTH (FK5.FK5_DTDISP)"
	endif

	// Busca cancelamentos de baixas. Verificado que FK5_DATA = FK5_DTDISP sao sempre iguais
	_cQueryC:= " SELECT FK5.FK5_RECPAG RECPAG, FK5.FK5_NATURE NATUREZA, FK5.FK5_DTDISP DT_MOVTO, FK5.FK5_VALOR TOTAL" + ;
	"   FROM " + RETSQLNAME ("SED") + " SED, " + ;
	RETSQLNAME ("FK5") + " FK5 " + ;
	"  WHERE SED.D_E_L_E_T_ <> '*'" + ;
	"    AND SED.ED_FILIAL  = '" + XFILIAL ("SED") + "'" + ;
	"    AND FK5.FK5_NATURE =  SED.ED_CODIGO" + ;
	"    AND FK5.D_E_L_E_T_ <> '*'" + ;
	"    AND FK5.FK5_BANCO   <> '   '" + ;
	"    AND FK5.FK5_TPDOC =  'ES'" + ;
	"    AND FK5.FK5_NATURE BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'" + ;
	"    AND FK5.FK5_DTDISP BETWEEN '" + dtos (mv_par01) + "' AND '" + dtos (mv_par02) + "'" + ;
	"    AND FK5.FK5_FILIAL  = '" + xfilial ("FK5") + "'"


	tcquery _cQueryP new alias _pag
	tcsetfield ("_pag", "DT_MOVTO", "D")
	incregua ()
	tcquery _cQueryR new alias _rec
	tcsetfield ("_rec", "DT_MOVTO", "D")
	incregua ()
	tcquery _cQueryC new alias _can
	tcsetfield ("_can", "DT_MOVTO", "D")
	incregua ()

	_Imp_trb ()
	_rec -> (dbclosearea ())
	_pag -> (dbclosearea ())
	_can -> (dbclosearea ())

	Set Device To Screen
	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif
	MS_FLUSH()
return


// --------------------------------------------------------------------------
// Passa os dados dos arq. de trabalho para a array _aMatriz
static function _Imp_trb ()
	local _nDia      := 0   // Indice para _aDias
	local _sNatureza := ""  // Para controlar quebra por natureza
	local _nSld_dia  := 0   // Saldo diario a ser impresso no final
	local _nRes_Dia  := 0   // Resultado do dia a ser impresso no final
	local _nReg_trb  := 0   // Numero registros do arq. trb p/ regua de impressao
	local _dData     := date ()  // Data do movimento nos arq. de trabalho
	Local _nLin
	Local _nCol

	private _aMatriz := {}  // Matriz com as datas, naturezas e valores
	private _aDias   := {}  // Lista de dias a serem impressos


	// Monta array com os dias ou meses entre a data inicial e final.
	// Varre os arqs. de trabalho procurando o dia ou mes. Se nao tem movimentacao, nem coloca-o em _aDias.
	_aDias = {}
	_nReg_trb = 0
	_rec -> (dbgotop ())
	do while ! _rec -> (eof ())
		_nReg_trb ++
		_dData = iif (mv_par05 == 1, _rec -> dt_movto, strzero (_rec -> mes, 2) + "/" + strzero (_rec -> ano, 4))
		if ascan (_aDias, _dData) == 0
			aadd (_aDias, _dData)
		endif
		_rec -> (dbskip ())
	enddo

	_pag -> (dbgotop ())
	do while ! _pag -> (eof ())
		_nReg_trb ++
		_dData = iif (mv_par05 == 1, _pag -> dt_movto, strzero (_pag -> mes, 2) + "/" + strzero (_pag -> ano, 4))
		if ascan (_aDias, _dData) == 0
			aadd (_aDias, _dData)
		endif
		_pag -> (dbskip ())
	enddo


	// Ordena _aDias por dia ou por ano/mes, conforme o caso
	if mv_par05 == 1
		_aDias = asort (_aDias)
	else
		_aDias = asort (_aDias,,, {|_x, _y| (substr (_x, 4, 4) + substr (_x, 1, 2)) < (substr (_y, 4, 4) + substr (_y, 1, 2))})
	endif
	incregua ()


	// Monta a linha de datas e as linhas de totais em _aMatriz
	_aMatriz = {}
	_Lin_Nat ("0", "", .T.)
	_aMatriz [_Lin_Nat ("1", "TOTAL", .T.), 3] = "TOTAL DE RECEBIMENTOS"
	_aMatriz [_Lin_Nat ("2", "TOTAL", .T.), 3] = "TOTAL DE PAGAMENTOS"
	_aMatriz [_Lin_Nat ("3", "TOTAL", .T.), 3] = "SALDO DO PERIODO"
	_aMatriz [_Lin_Nat ("4", "TOTAL", .T.), 3] = "ACUMULADO DO PERIODO"

	// Monta array de datas
	_nDia = 1
	do while _nDia <= len (_aDias)
		if mv_par05 == 1
			_aMatriz [1, _nDia + 3] = _aDias [_nDia]
		else
			_aMatriz [1, _nDia + 3] = _aDias [_nDia]
		endif
		_nDia ++
	enddo
	_aMatriz [1, len (_aMatriz [1])] = " TOTAL"


	// Insere valores do arquivo _rec em _aMatriz
	SetRegua (_nReg_trb)
	_rec -> (dbgotop ())
	do while ! _rec -> (eof ())
		incregua ()

		// Completa natureza com Z para facilitar posterior ordenacao e totalizacao
		_sNatureza = padr (alltrim (_rec -> natureza), 10, "Z")

		// Encontra a coluna de _aMatriz onde o valor deve ser somado
		_dData = iif (mv_par05 == 1, _rec -> dt_movto, strzero (_rec -> mes, 2) + "/" + strzero (_rec -> ano, 4))
		_nCol = ascan (_aMatriz [1], _dData)

		// Insere o valor (tipo 1), soma-o no grupo (tipo 2) e no total rec. (tipo 3)
		_aMatriz [_Lin_Nat ("1", _sNatureza, .T.)                          , _nCol] =  _rec -> total
		_aMatriz [_Lin_Nat ("1", padr (left (_sNatureza, 4), 10, "Z"), .T.), _nCol] += _rec -> total
		_aMatriz [_Lin_Nat ("1", "TOTAL", .T.)                             , _nCol] += _rec -> total
		_rec -> (dbskip ())
	enddo


	// Insere valores do arquivo _pag em _aMatriz
	_pag -> (dbgotop ())
	do while ! _pag -> (eof ())
		incregua ()

		// Completa natureza com Z para facilitar posterior ordenacao e totalizacao
		_sNatureza = padr (alltrim (_pag -> natureza), 10, "Z")

		// Encontra a coluna de _aMatriz onde o valor deve ser somado
		_dData = iif (mv_par05 == 1, _pag -> dt_movto, strzero (_pag -> mes, 2) + "/" + strzero (_pag -> ano, 4))
		_nCol = ascan (_aMatriz [1], _dData)

		// Insere o valor (tipo 1), soma-o no grupo (tipo 2) e no total rec. (tipo 3)
		_aMatriz [_Lin_Nat ("2", _sNatureza, .T.)                          , _nCol] =  _pag -> total
		_aMatriz [_Lin_Nat ("2", padr (left (_sNatureza, 4), 10, "Z"), .T.), _nCol] += _pag -> total
		_aMatriz [_Lin_Nat ("2", "TOTAL", .T.)                             , _nCol] += _pag -> total
		_pag -> (dbskip ())
	enddo


	// Subtrai cancelamentos de baixas (arquivo _can) de _aMatriz. Isso foi feito
	// por nao haver possibilidade de filtrar as baixas canceladas no FK5, uma
	// vez que a baixa no FK5 ocorreu normalmente. Apenas o cancelamento pode ser
	// filtrado com FK5_TPDOC='ES'.
	_can -> (dbgotop ())
	do while ! _can -> (eof ())

		// Completa natureza com Z para facilitar posterior ordenacao e totalizacao
		_sNatureza = padr (alltrim (_can -> natureza), 10, "Z")

		// Encontra a coluna de _aMatriz onde o valor deve ser somado
		_dData = iif (mv_par05 == 1, _can -> dt_movto, strzero (month (_can -> dt_movto), 2) + "/" + strzero (year (_can -> dt_movto), 4))
		_nCol = ascan (_aMatriz [1], _dData)

		// Encontra a natureza correspondente ao cancelamento e subtrai da mesma
		// o valor do cancelamento. No caso, nao importa qual foi o titulo
		// cancelado, bastando bater natureza e data.
		if _can -> recpag == "R" // Significa o cancelamento de um "P"
			_aMatriz [_Lin_Nat ("2", _sNatureza, .F.)                          , _nCol] -= _can -> total
			_aMatriz [_Lin_Nat ("2", padr (left (_sNatureza, 4), 10, "Z"), .F.), _nCol] -= _can -> total
			_aMatriz [_Lin_Nat ("2", "TOTAL", .F.)                             , _nCol] -= _can -> total
		else  // Significa o cancelamento de um "R"
			_aMatriz [_Lin_Nat ("1", _sNatureza, .F.)                          , _nCol] -= _can -> total
			_aMatriz [_Lin_Nat ("1", padr (left (_sNatureza, 4), 10, "Z"), .F.), _nCol] -= _can -> total
			_aMatriz [_Lin_Nat ("1", "TOTAL", .F.)                             , _nCol] -= _can -> total
		endif
		_can -> (dbskip ())
	enddo


	// Calcula total da linha de _aMatriz
	for _nLin = 2 to len (_aMatriz)
		for _nCol = 4 to len (_aMatriz [1]) - 1
			_aMatriz [_nLin, len (_aMatriz [1])] += _aMatriz [_nLin, _nCol]
		next
	next

	dDtProc   := MV_PAR01 - 1 //seta a variavel para o dia anterior a data informada pelo usuario (pq o saldo é anterior)
	nDecs     := MsDecimais(1)
	nSaldoAnt := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura pelo 1.o banco no SA6   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SA6" )
	dbSetOrder(1)
	dbSeek(xFilial("SA6"))
	While !Eof() .And. SA6->A6_FILIAL == xFilial( "SA6" )
		IF lEnd
			Exit
		End

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se não considerar banco para o Fluxo de Caixa                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//If SA6->A6_FLUXCAI == "N"
		//	 dbSkip()
		//	 Loop
		//EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura pelo saldo anterior dos bancos no SE8 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE8")
		dbSetOrder(1)
		If ! (dbSeek(xFilial("SE8")+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON+DtoS(dDtProc),.T.))
			dbSkip( -1 )
		EndIf

		If SA6->A6_COD 	   != SE8->E8_BANCO		.or. ;
		SA6->A6_AGENCIA != SE8->E8_AGENCIA	.or. ;
		SA6->A6_NUMCON  != SE8->E8_CONTA		.or. ;
		SE8->E8_DTSALAT >  dDtProc
			dbSelectArea("SA6")
			dbSkip()
			Loop
		Else
			nMoedaBco :=	Iif(cPaisLoc=="BRA",1,Max(SA6->A6_MOEDA,1))
			nSaldoAnt += xMoeda(SE8->E8_SALATUA,1,1,SE8->E8_DTSALAT,nDecs+1)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define os parametros do array dos saldos anteriores. aBancos  ³
		//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³Banco        => [1]                                            ³
		//³Agencia      => [2]                                            ³
		//³Conta        => [3]                                            ³
		//³Nome Red     => [4]                                            ³
		//³Data         => [5]                                            ³
		//³Saldo        => [6]                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//AAdd( aBancos,{SE8->E8_BANCO,SE8->E8_AGENCIA,SE8->E8_CONTA,SA6->A6_NREDUZ,;
		//DtoC(SE8->E8_DTSALAT),Transform(xMoeda(SE8->E8_SALATUA,1,1,SE8->E8_DTSALAT,nDecs+1),TM(SE8->E8_SALATUA,14,nDecs))})
		dbSelectArea("SA6")
		dbSkip()
	EndDo


	// Calcula resultado e saldo do dia
	_nRes_dia = 0
	_nSld_dia = nSaldoAnt   //mv_par06
	for _nCol = 4 to len (_aMatriz [1])
		_nRes_dia = _aMatriz [_Lin_Nat ("1", "TOTAL", .F.), _nCol] - _aMatriz [_Lin_Nat ("2", "TOTAL", .F.), _nCol]
		_aMatriz [_Lin_Nat ("3", "TOTAL", .F.), _nCol] = _nRes_dia
		_nSld_dia += _nRes_dia
		_aMatriz [_Lin_Nat ("4", "TOTAL", .F.), _nCol] = _nSld_dia
	next


	// Ordena _aMatriz por tipo de registro (pos. 1) e por natureza (pos.2)
	_aMatriz = asort (_aMatriz,,, {|_x, _y| _x[1] + _x[2] < _y[1] + _y[2]})

	if len (_aMatriz) <= 5  // Nao foi encontrado menhum movimento dentro dos parametros informados
		return
	else
		_Imp_array ()
	endif
return


// --------------------------------------------------------------------------
// Imprime a array _aMatriz formatada
static function _Imp_array ()
	local _nCol       := 0   // Coluna sendo impressa
	local _nCol_ini   := 0   // Coluna inicial na pagina atual
	local _nMax_col   := 16  // Maximo de colunas por pagina
	local _nCol_fim   := 0   // Coluna final na pagina atual
	local _sTipo      := ""  // Tipo de registro sendo impresso
	private _sTraco   := ""  // Traco com os pipes
	private _sBrancos := ""  // Linha em branco com os pipes
	private _nTam_col := 14  // Tamanho (largura) da coluna para impressao
	private _nPag     := 1   // Controle de numeracao de pagina


	// Enquanto nao listar todas as colunas de _aMatriz...
	_nCol_ini = 4
	_nCol_fim = min (_nMax_col, len (_aMatriz [1]))
	do while _nCol_ini <= len (_aMatriz [1])

		_sTraco   = "|-----------------------------------|-------------|" + replicate ("-------------|", _nCol_fim - _nCol_ini)
		_sBrancos = strtran (_sTraco, "-", " ")
		_Cabecalho (_nCol_ini, _nCol_fim)

		_nLin = 2
		do while _nLin <= len (_aMatriz)
			if _aMatriz [_nLin, 1] != _sTipo
				_sTipo = _aMatriz [_nLin, 1]
				do case
					case _sTipo == "1"  // Inicio dos recebimentos
					@ li, 0 psay stuff (_sBrancos, 2, 12, "RECEBIMENTOS")
					li ++
					case _sTipo == "2"  // Inicio dos pagamentos
					@ li, 0 psay _sTraco
					li ++
					@ li, 0 psay stuff (_sBrancos, 2, 10, "PAGAMENTOS")
					li ++
					case _sTipo == "3"  // Vou listar o saldo do dia
					@ li, 0 psay strtran (_sTraco, "-", "=")
					li ++
					case _sTipo == "4"  // Vou listar o acumulado do dia
					//            @ li, 0 psay _sTraco
					//            li ++
				endcase
			endif

			do while _nLin <= len (_aMatriz) .and. _aMatriz [_nLin, 1] == _sTipo
				if li >= 65
					_Cabecalho (_nCol_ini, _nCol_fim)
				endif

				// Traco antes dos totais de rec/pag
				if (_sTipo == "1" .or. _sTipo == "2") .and. alltrim (_aMatriz [_nLin, 2]) == "TOTAL"
					@ li, 0 psay _sTraco
					li ++
				endif

				@ li, 0  psay "|     " + _aMatriz [_nLin, 3]  // Descricao da natureza
				@ li, 36 psay "|"
				for _nCol = 0 to (_nCol_fim - _nCol_ini)
					if _nLin != len (_aMatriz) .or. (_nCol_ini + _nCol) != len (_aMatriz [1])  // Nao imprime acumulado na ultima coluna
						@ li, 37 + _nCol * _nTam_col psay _aMatriz [_nLin, _nCol_ini + _nCol] picture "@E 99,999,999.99"
					endif
					@ li, 50 + _nCol * _nTam_col psay "|"
				next
				li ++
				_nLin ++
			enddo
		enddo

		@ li, 1 psay replicate ("=", len (_sTraco) - 2)
		li ++
		_nCol_ini = _nCol_fim + 1
		_nCol_fim = min ((_nCol_fim + _nMax_col), len (_aMatriz [1]))
	enddo
return




//---------------------------------------------------------------------------
// Imprime cabecalho com datas, etc. ao iniciar nova folha
static function _Cabecalho (_nCol_ini, _nCol_fim)
	Local _ncol
	local _aSemana := {"   Domingo","   Segunda","   Terca","   Quarta","   Quinta","   Sexta","   Sabado"}
	dDtProc   := MV_PAR01 - 1 //seta a variavel para o dia anterior a data informada pelo usuario (pq o saldo é anterior)
	nDecs     := MsDecimais(1)
	nSaldoAnt := 0

	if _nPag == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura pelo 1.o banco no SA6   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "SA6" )
		dbSetOrder(1)
		dbSeek(xFilial("SA6"))
		While !Eof() .And. SA6->A6_FILIAL == xFilial( "SA6" )
			IF lEnd
				Exit
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se não considerar banco para o Fluxo de Caixa                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//If SA6->A6_FLUXCAI == "N"
			//	 dbSkip()
			//	 Loop
			//EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura pelo saldo anterior dos bancos no SE8 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SE8")
			dbSetOrder(1)
			If ! (dbSeek(xFilial("SE8")+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON+DtoS(dDtProc),.T.))
				dbSkip( -1 )
			EndIf

			If SA6->A6_COD 	   != SE8->E8_BANCO		.or. ;
			SA6->A6_AGENCIA != SE8->E8_AGENCIA	.or. ;
			SA6->A6_NUMCON  != SE8->E8_CONTA		.or. ;
			SE8->E8_DTSALAT >  dDtProc
				dbSelectArea("SA6")
				dbSkip()
				Loop
			Else
				nMoedaBco :=	Iif(cPaisLoc=="BRA",1,Max(SA6->A6_MOEDA,1))
				nSaldoAnt += xMoeda(SE8->E8_SALATUA,1,1,SE8->E8_DTSALAT,nDecs+1)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define os parametros do array dos saldos anteriores. aBancos  ³
			//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
			//³Banco        => [1]                                            ³
			//³Agencia      => [2]                                            ³
			//³Conta        => [3]                                            ³
			//³Nome Red     => [4]                                            ³
			//³Data         => [5]                                            ³
			//³Saldo        => [6]                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//AAdd( aBancos,{SE8->E8_BANCO,SE8->E8_AGENCIA,SE8->E8_CONTA,SA6->A6_NREDUZ,;
			//DtoC(SE8->E8_DTSALAT),Transform(xMoeda(SE8->E8_SALATUA,1,1,SE8->E8_DTSALAT,nDecs+1),TM(SE8->E8_SALATUA,14,nDecs))})
			dbSelectArea("SA6")
			dbSkip()
		EndDo

		//cabec (_sTitulo + "   (Saldo inicial: " + transform (mv_par06, "@E 99,999,999.99") + ")", _sTexto1, _sTexto2, wnrel, _sTamanho, 15)
		cabec (_sTitulo + "   (Saldo inicial: " + transform (nSaldoAnt, "@E 999,999,999,999.99") + ")", _sTexto1, _sTexto2, wnrel, _sTamanho, 15)
	else
		cabec (_sTitulo, _sTexto1, _sTexto2, wnrel, _sTamanho, 15)
	endif

	_nPag ++
	//   @ li, 1 psay replicate ("=", len (_sTraco) - 2)
	//   li ++
	@ li, 0  psay "|       HISTORICO / PERIODOS        |"
	for _nCol = 0 to (_nCol_fim - _nCol_ini)
		@ li, 40 + _nCol * _nTam_col psay _aMatriz [1, _nCol_ini + _nCol]
		@ li, 50 + _nCol * _nTam_col psay "|"
	next
	li ++
	if mv_par05 == 1
		@ li, 0  psay "|                                   |"
		for _nCol = 0 to (_nCol_fim - _nCol_ini)
			if (_nCol_ini + _nCol) < len (_aMatriz [1])
				@ li, 38 + _nCol * _nTam_col psay _aSemana [dow (_aMatriz [1, _nCol_ini + _nCol])]
			endif
			@ li, 50 + _nCol * _nTam_col psay "|"
		next
		li ++
	endif
	@ li, 0 psay strtran (_sTraco, "-", "=")
	li ++
return


// --------------------------------------------------------------------------
// Encontra em _aMatriz a linha com o tipo e natureza passados como parametro.
// Se lCria = .T. inclui a natureza, se ela ainda nao estiver em _aMatriz, e
// devolve o numero da linha incluida, jah inicializada com zeros.
// Se lCria = .F. nao inclui a natiureza, apenas devolve o numero da linha. Se
// a natureza ainda nao estiver em _aMatriz, devolve zero.
static function _Lin_Nat (_sTipo, _sNatur, _lCria)
	local _nLinha := 0
	local _nColuna := 0
	_nLinha = ascan (_aMatriz, {|_aVal| _aVal [1] == _sTipo .and. _aVal [2] == _sNatur})
	if _nLinha == 0
		if _lCria
			aadd (_aMatriz, array (len (_aDias) + 4))
			_nLinha = len (_aMatriz)
			_aMatriz [_nLinha, 1] = _sTipo
			_aMatriz [_nLinha, 2] = _sNatur
			sed -> (dbseek (xfilial ("SED") + strtran (_sNatur, "Z", " "), .F.))
			if substr (_sNatur, 5, 6) == "ZZZZZZ"
				_aMatriz [_nLinha, 3] = left (sed -> ed_descric, 28) + "->"
			else
				_aMatriz [_nLinha, 3] = sed -> ed_descric
			endif

			// Inicializa todas as posicoes com zero.
			for _nColuna = 4 to len (_aMatriz [_nLinha])
				_aMatriz [_nLinha, _nColuna] = 0
			next
		endif
	endif
return _nLinha


// --------------------------------------------------------------------------
// Cria perguntas no SX1, caso nao existam
Static Function _ValidPerg()
	Local i
	Local j
	cAlias := Alias()
	aRegs  := {}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	AADD(aRegs,{cPerg,"01","Data de            ?","Data inicial       ?","Data inicial       ?","mv_ch1" ,"D",08,0,0,"G","","mv_par01","",   "","","","","",   "","","","","","","","","","","","","","","","","","","",   ""})
	AADD(aRegs,{cPerg,"02","Data ate           ?","Data final         ?","Data final         ?","mv_ch2" ,"D",08,0,0,"G","","mv_par02","",   "","","","","",   "","","","","","","","","","","","","","","","","","","",   ""})
	AADD(aRegs,{cPerg,"03","Natureza de        ?","Natureza de        ?","Natureza de        ?","mv_ch3" ,"C",10,0,0,"G","","mv_par03","",   "","","","","",   "","","","","","","","","","","","","","","","","","","SED",""})
	AADD(aRegs,{cPerg,"04","Natureza ate       ?","Natureza ate       ?","Natureza ate       ?","mv_ch4" ,"C",10,0,0,"G","","mv_par04","",   "","","","","",   "","","","","","","","","","","","","","","","","","","SED",""})
	AADD(aRegs,{cPerg,"05","Quebra por         ?","Quebra por         ?","Quebra por         ?","mv_ch5" ,"N",01,0,0,"C","","mv_par05","Dia","","","","","Mes","","","","","","","","","","","","","","","","","","","",   ""})
	AADD(aRegs,{cPerg,"06","Saldo inicial      ?","Saldo inicial      ?","Saldo inicial      ?","mv_ch6" ,"N",15,2,0,"G","","mv_par06","",   "","","","","",   "","","","","","","","","","","","","","","","","","","",   ""})

	DbSelectArea("SX1")
	DbSetOrder(1)
	For i:=1 to Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j<=Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	DbSelectArea(cAlias)
Return

