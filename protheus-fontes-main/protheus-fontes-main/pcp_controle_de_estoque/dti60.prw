#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI60     º Autor ³ Fabian Maurerº Data ³  12/07/18         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Quantidade de Peso Camaras                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gerencia Produção						                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI60()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "com a Quantidade de Peso das Camaras tanto de"
	Local cDesc3         := "entrada quanto de saida"
	Local cPict          := ""
	Local titulo         := "RELATORIO DE QUANTIDADE DE PESO DAS CAMARAS"
	Local nLin           := 80
	Local Cabec1       := ""
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private tamanho          := "M"
	Private nomeprog         := "DTI60" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   := "DTI60"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "DTI60" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    := 0.00
	Private TotPeso    := 0.00 
	Private _QUANT     := 0
	Private _PESO      := 0
	Private _QUANT2    := 0
	Private _PESO2     := 0

	pergunte(cPerg,.F.)

	if mv_par04 = 1
		Cabec1 := 'Codigo       Descricao          Caixa          Data    Hora   Peso        Local       Localiz.               Pallet'
	elseif mv_par04 = 2
		Cabec1 := 'Codigo       Descricao          Data           Peso1	  		  Peso2   			     Peso Tot. 			        Camara'
	endif

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	_nQtCai := 0
	_nQtPes := 0

	if mv_par04 = 1
		cQuery := " SELECT Z8_COD AS COD, Z8_DATA AS DATA, Z8_PALLET AS PALLET, Z8_HORA AS HORA, Z8_CONTROL AS CAIXA, Z8_PESOBR AS PESOBR,
		cQuery += " Z8_PESO AS PESO, Z8_LOCAL AS LUGAR, Z8_DATAS AS DATAS, Z8_HORAS AS HORAS, Z8_LOCALIZ AS LOCALIZ
		cQuery += " FROM " + RetSqlName("SZ8") +" WHERE SZ8010.D_E_L_E_T_ <> '*'   "
		cQuery += " AND Z8_FILIAL = '" + xFilial("SZ8") + "'" 
		cQuery += " AND Z8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		cQuery += " AND Z8_HORAS = '' AND Z8_DATAS = '' AND Z8_LOTEPOR = ''
		cQuery += " AND Z8_LOCAL = '" + mv_par03 + "'"

		cQuery  +=  " ORDER BY Z8_DATA, Z8_COD, Z8_CONTROL"

	elseif mv_par04 = 2
		cQuery := " SELECT ZK_NUMAM AS NUMAM, ZK_LOTE AS LOTE, ZK_CONTROL AS CONTROL, ZK_PECARC1 AS PESO1, ZK_PECARC2 AS PESO2,
		cQuery += " ZK_PETOTAL AS PESTOT, ZK_LOCAL AS CAMARA, ZAJ_NUMAM, ZAJ_LOTE, ZAJ_CONTRO, ZAJ_DATA AS DATA, ZAJ_DATAS AS DATAS,
		cQuery += "	ZAJ_HORAS AS HORAS, ZAJ_COD AS COD
		cQuery += " FROM " + retSqlTab('SZK') + ", " + retSqlTab('ZAJ')
		cQuery += " WHERE " +  retSqlFil('SZK') + " AND " + retSqlFil('ZAJ')
		cQuery += " AND ZAJ_FILIAL = '" + xFilial("ZAJ") + "'" 
		cQuery += " AND ZAJ_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		cQuery += " AND ZAJ_NUMAM = ZK_NUMAM AND ZAJ_CONTRO = ZK_CONTROL AND ZAJ_LOTE = ZK_LOTE
		cQuery += " AND ZAJ_HORAS = '' AND ZAJ_DATAS = ''
		cQuery += " AND ZK_LOCAL = '" + mv_par03 + "'"

		cQuery  +=  " ORDER BY ZAJ_DATA, ZAJ_CONTRO"
	endif

	cQuery  := ChangeQuery(cQuery)


	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("POS") != 0
		POS->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "POS"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ8')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	POS->(SetRegua(RecCount()))

	POS->(dbGoTop())

	cGrupo := '' 
	_cFarm := ''

	While POS->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif



		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif      

		if mv_par04 = 1
			DbSelectArea('SB1')
			@nlin,001 psay alltrim(POS->COD)
			@nlin,008 psay substr(fBuscaCPO('SB1',1,xfilial('SB1')+POS->COD,'B1_DESCRED'),1,20) 
			@nlin,030 psay POS->CAIXA
			@nlin,045 psay POS->DATA
			@nlin,055 psay POS->HORA
			@nlin,062 psay POS->PESO
			@nlin,070 psay POS->LUGAR  
			@nlin,080 psay POS->LOCALIZ
			@nlin,110 psay POS->PALLET
		elseif mv_par04 = 2
			DbSelectArea('SB1')
			@nlin,001 psay alltrim(POS->COD)
			@nlin,008 psay substr(fBuscaCPO('SB1',1,xfilial('SB1')+POS->COD,'B1_DESCRED'),1,20) 
			@nlin,030 psay POS->DATA
			@nlin,047 psay POS->PESO1
			@nlin,056 psay POS->PESO2
			@nlin,071 psay POS->PESTOT
			@nlin,089 psay POS->CAMARA
		endif

		nlin++	 

		_nQtCai += 1
		_nQtPes += POS->PESTOT

		POS->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo

	@nlin,001 psay replicate('-',132)
	nlin++

	if mv_par04 = 1	
		@nlin,001 psay 'Total Caixas em Estoque: '
		@nlin,028 psay Transform(_nQtcai,'@E 999,999') + ' Kg'
	elseif mv_par04 = 2
		@nlin,001 psay 'Total Peças em Estoque: '
		@nlin,028 psay Transform(_nQtPes,'@E 999,999.99') + ' Kg'
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return
