#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MGT_BLKD 
@Type			: Função de Usuário
@Sample			: U_MGT_BLKD()
@Description	: Rotina para das desmontagens de produtos a partir das devoluções
                  realizadas conforme data de entrada
				  Esta rotina possibilita a realização das transferências múltiplas,
				  ou seja, transferências de um único produto para vários produtos
				  através do mecanismo de rotina automática
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Revisão em Jun/2021 considerando situação atual para rodar em Jan/2022
/*/
//--------------------------------------------------------------------------------------
User Function MGT_BLKD()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| BLKDNewPerg ( oSelf ) }   
	Local cFunction    := "MGT_BLKD"
	Local cTitle	   := "Geração Dados Bloco K Referente Devoluções"
	Local cDescription := "Rotina responsável pela geração das desmontagens de produtos (origem X destino) referente aos movimentos de devoluções conforme data de entrada." + ;
						  "Para executar a geração das informações necessárias, informe os parâmetros necessários." + CRLF + CRLF + ; 
						  "Clique no botão abaixo e aguarde a conclusão do processamento."

	Private cPerg	   := "MGT_BLKD"
	//Private cCadastro  := OemToAnsi("Geração Dados Bloco K Referente Devoluções")

	// Botão para visualização do log de processamento
	Aadd(aInfo,{"Históricos de Processamentos", { || ProcLogView(,FunName()) },"WATCH" })

	oProcess := tNewProcess():New( cFunction,;
									cTitle,;
									bProcess,;
									cDescription,;
									cPerg,;
									aInfo,;
									.T.,;
									5,;
									"Descrição do Painel Auxiliar",;
									.T.)


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BLKDNewPerg
Tratamento para a utilização do tNewProcess
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLKDNewPerg( oSelf )

	BLKDProc(.F.,oSelf)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BLKDProc
Função que efetua o processamento das informações
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLKDProc( lBat, oSelf )

	Local cIdCV8 := ""

	lMSErroAuto := .T.

	ProcLogIni({},FunName(),,@cIdCV8)
	ProcLogAtu("INICIO","Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()) ,,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula total de registros a serem processados corretamente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT( SZN.R_E_C_N_O_ ) TOTREG "
	cQuery += "  FROM " + RetSQLTab("SZN")
	cQuery += " WHERE " + RetSQLFil("SZN")
	cQuery += "   AND ZN_DESTINO IN ('R','P')"
	cQuery += "   AND ZN_CODDEST <> ' '"
	cQuery += "   AND ZN_DTSAIDA = '" + dtos(mv_par01) + "'"
	cQuery += "   AND " + RetSQLDel("SZN")

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTOT",.T.,.T.)

	oSelf:SetRegua1(TRBTOT->TOTREG)
	oSelf:SetRegua2(TRBTOT->TOTREG)

	TRBTOT->( DbCloseArea() )


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados p/ R=Repesagem e P=Reprocesso    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT ZN_COD, ZN_CODDEST, SUM(ZN_PESOL) AS PESOTOT "
	cQuery += "  FROM " + RetSQLTab("SZN")
	cQuery += " WHERE " + RetSQLFil("SZN")
	cQuery += "   AND ZN_DESTINO IN ('R','P')"
	cQuery += "   AND ZN_CODDEST <> ' '"
	cQuery += "   AND ZN_CODDEST <> ZN_COD"
	cQuery += "   AND ZN_DTSAIDA = '" + dtos(mv_par01) + "'"
	cQuery += "   AND " + RetSQLDel("SZN")
	cQuery += " GROUP BY ZN_COD, ZN_CODDEST "
	cQuery += " ORDER BY ZN_COD "

	cQuery := ChangeQuery(cQuery)

	ProcLogAtu( 'MENSAGEM', "Seleção dos Dados p/ R=Repesagem e P=Reprocesso " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .F., .T.)

	TRB->(dbGoTop())
	While TRB->(!Eof())

		oSelf:IncRegua1("Selecionando dados p/ R=Repesagem e P=Reprocesso ...")
		oSelf:IncRegua2()

		Pergunte(cPerg,.F.)   

		_cPrdOrig := PADR(TRB->ZN_COD, 15, " ")
		_cLocOrig := fBuscaCpo("SB1", 1, xFilial("SB1") + _cPrdOrig, "B1_LOCPAD")
		_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cPrdOrig, "B1_UM")
		_cPrdDest := PADR(TRB->ZN_CODDEST, 15, " ")
		_cLocDest := fBuscaCpo("SB1", 1, xFilial("SB1") + _cPrdDest, "B1_LOCPAD")
		_nPesoTot := TRB->PESOTOT
		_cNumDoc  := NextNumero("SD3",2,"D3_DOC",.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SD3 (devolução estoque produto de origem - reprocesso)  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aVetor := {}   

		AADD(_aVetor, {"D3_TM     " , "013"      			,NIL})        
		AADD(_aVetor, {"D3_DOC    " , _cNumDoc    			,NIL})
		AADD(_aVetor, {"D3_CC     " , "1131005"   			,NIL})	// Desossa
		AADD(_aVetor, {"D3_EMISSAO" , ddatabase	  			,NIL})     
		AADD(_aVetor, {"D3_COD    " , _cPrdOrig				,NIL})
		AADD(_aVetor, {"D3_UM     " , _cUnidMed				,NIL})
		AADD(_aVetor, {"D3_QUANT  " , _nPesoTot				,NIL})
		AADD(_aVetor, {"D3_LOCAL  " , _cLocOrig      		,NIL})
		AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())   ,NIL})

		// Executa devolução de reprocesso via rotina automatica
		If Len(_aVetor) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y| MATA240(x,y)},_aVetor,3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DEVOL REPROCESSO ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cPrdOrig) + " D3_TM = 013")
					MsgAlert("Houve erro na geração da devolução do estoque no SD3 ExecAuto MATA240 TM 013. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO SD3 DEVOL REPROCESSO ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cPrdOrig) + " D3_TM = 013")
				Endif                                       
			End Transaction 
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DEVOL REPROCESSO ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cPrdOrig) + " D3_TM = 013")
		Endif

		aAutoCab   := {}
		aAutoItens := {}
		aItem	   := {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SD3 (desmontagem de produtos)                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aAutoCab,{"cProduto"	, _cPrdOrig						, Nil})
		AADD(aAutoCab,{"cLocOrig"	, _cLocorig						, Nil})
		AADD(aAutoCab,{"nQtdOrig"	, _nPesoTot						, Nil})
		AADD(aAutoCab,{"nQtdOrigSe" , CriaVar("D3_QTSEGUM") 		, Nil})
		AADD(aAutoCab,{"cDocumento" , _cNumDoc						, Nil})
		AADD(aAutoCab,{"cNumLote" 	, CriaVar("D3_NUMLOTE") 		, Nil})
		AADD(aAutoCab,{"cLoteDigi"  , CriaVar("D3_LOTECTL") 		, Nil})
		AADD(aAutoCab,{"dDtValid" 	, CriaVar("D3_DTVALID") 		, Nil})
		AADD(aAutoCab,{"nPotencia"  , CriaVar("D3_POTENCI") 		, Nil})
		AADD(aAutoCab,{"cLocaliza"  , CriaVar("D3_LOCALIZ") 		, Nil})
		AADD(aAutoCab,{"cNumSerie"  , CriaVar("D3_NUMSERI") 		, Nil})

		AADD(aItem,{"D3_COD"		, _cPrdDest						, Nil})
		AADD(aItem,{"D3_LOCAL"		, _cLocDest						, Nil})
		AADD(aItem,{"D3_QUANT"		, _nPesoTot						, Nil})
		AADD(aItem,{"D3_QTSEGUM"	, CriaVar("D3_QTSEGUM")			, Nil})
		AADD(aItem,{"D3_RATEIO"		, 100							, Nil})
		AADD(aItem,{"D3_ROTBLK"		, AllTrim(FunName())			, Nil})
		AADD(aAutoItens,aClone(aItem))

		// Executa desmontagem via rotina automatica
		If Len(aAutoCab) > 0 .And. Len(aAutoItens) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y,z,t| Mata242(x,y,z,t)},aAutoCab,aAutoItens,3,.T.) 	// inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - DESMONTAGEM ==> " + _cNumDoc)
					MsgAlert("Houve erro na geração da desmontagem no SD3 ExecAuto MATA242. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO DESMONTAGEM ==> " + _cNumDoc)
				Endif                                       
			End Transaction 
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO DESMONTAGEM ==> " + _cNumDoc)
		Endif

		TRB->(DbSkip())

	Enddo

	TRB->(DbCloseArea())

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados do Charque p/ origem D=Devolução ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT ZZZ_PRDORI, ZZZ_CODPRO, SUM(ZZZ_PESLIQ) AS PESOTOT "
	cQuery += "  FROM " + RetSQLTab("ZZZ")
	cQuery += " WHERE " + RetSQLFil("ZZZ")
	cQuery += "   AND ZZZ_ORIGEM = 'D'"
	cQuery += "   AND ZZZ_DATAE = '" + dtos(mv_par01) + "'"
	cQuery += "   AND " + RetSQLDel("ZZZ")
	cQuery += " GROUP BY ZZZ_PRDORI, ZZZ_CODPRO "
	cQuery += " ORDER BY ZZZ_PRDORI "

	cQuery := ChangeQuery(cQuery)

	ProcLogAtu( 'MENSAGEM', "Seleção dos dados do charque p/ origem D=Devolução " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .F., .T.)

	TRB->(dbGoTop())
	While TRB->(!Eof())

		oSelf:IncRegua1("Selecionando dados do charque p/ origem D=Devolução ...")
		oSelf:IncRegua2()

		Pergunte(cPerg,.F.)   

		_cPrdOrig := PADR(TRB->ZZZ_PRDORI, 15, " ")
		_cLocOrig := fBuscaCpo("SB1", 1, xFilial("SB1") + _cPrdOrig, "B1_LOCPAD")
		_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cPrdOrig, "B1_UM")
		_cPrdDest := PADR(TRB->ZZZ_CODPRO, 15, " ")
		_cLocDest := fBuscaCpo("SB1", 1, xFilial("SB1") + _cPrdDest, "B1_LOCPAD")
		_nPesoTot := TRB->PESOTOT
		_cNumDoc  := NextNumero("SD3",2,"D3_DOC",.T.)


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SD3 (devolução estoque produto de origem - charque)     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aVetor := {}   

		AADD(_aVetor, {"D3_TM     " , "014"      			,NIL})        
		AADD(_aVetor, {"D3_DOC    " , _cNumDoc    			,NIL})
		AADD(_aVetor, {"D3_CC     " , "1131005"   			,NIL})	// Desossa
		AADD(_aVetor, {"D3_EMISSAO" , ddatabase	  			,NIL})     
		AADD(_aVetor, {"D3_COD    " , _cPrdOrig				,NIL})
		AADD(_aVetor, {"D3_UM     " , _cUnidMed				,NIL})
		AADD(_aVetor, {"D3_QUANT  " , _nPesoTot				,NIL})
		AADD(_aVetor, {"D3_LOCAL  " , _cLocOrig      		,NIL})
		AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())   	,NIL})

		// Executa devolução de charque via rotina automatica
		If Len(_aVetor) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y| MATA240(x,y)},_aVetor,3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DEVOL CHARQUE ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cPrdOrig) + " D3_TM = 014")
					MsgAlert("Houve erro na geração da devolução do estoque no SD3 ExecAuto MATA240 para TM 014. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO SD3 DEVOL CHARQUE ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cPrdOrig) + " D3_TM = 014")
				Endif                                       
			End Transaction 
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DEVOL CHARQUE ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cPrdOrig) + " D3_TM = 014")
		Endif

		aAutoCab   := {}
		aAutoItens := {}
		aItem      := {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SD3 (Desmontagem)                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aAutoCab,{"cProduto"	, _cPrdOrig						, Nil})
		AADD(aAutoCab,{"cLocOrig"	, _cLocorig						, Nil})
		AADD(aAutoCab,{"nQtdOrig"	, _nPesoTot						, Nil})
		AADD(aAutoCab,{"nQtdOrigSe" , CriaVar("D3_QTSEGUM") 		, Nil})
		AADD(aAutoCab,{"cDocumento" , _cNumDoc						, Nil})
		AADD(aAutoCab,{"cNumLote" 	, CriaVar("D3_NUMLOTE") 		, Nil})
		AADD(aAutoCab,{"cLoteDigi"  , CriaVar("D3_LOTECTL") 		, Nil})
		AADD(aAutoCab,{"dDtValid" 	, CriaVar("D3_DTVALID") 		, Nil})
		AADD(aAutoCab,{"nPotencia"  , CriaVar("D3_POTENCI") 		, Nil})
		AADD(aAutoCab,{"cLocaliza"  , CriaVar("D3_LOCALIZ") 		, Nil})
		AADD(aAutoCab,{"cNumSerie"  , CriaVar("D3_NUMSERI") 		, Nil})

		AADD(aItem,{"D3_COD"		, _cPrdDest						, Nil})
		AADD(aItem,{"D3_LOCAL"		, _cLocDest						, Nil})
		AADD(aItem,{"D3_QUANT"		, _nPesoTot						, Nil})
		AADD(aItem,{"D3_QTSEGUM"	, CriaVar("D3_QTSEGUM")			, Nil})
		AADD(aItem,{"D3_RATEIO"		, 100							, Nil})
		AADD(aItem,{"D3_ROTBLK"		, AllTrim(FunName())			, Nil})
		AADD(aAutoItens,aClone(aItem))

		// Executa desmontagem via rotina automatica
		If Len(aAutoCab) > 0 .And. Len(aAutoItens) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y,z,t| Mata242(x,y,z,t)},aAutoCab,aAutoItens,3,.T.) 	// inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - DESMONTAGEM CHARQUE  ==> " + _cNumDoc)
					MsgAlert("Houve erro na geração da desmontagem charque no SD3 ExecAuto MATA242. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO DESMONTAGEM CHARQUE  ==> " + _cNumDoc)
				Endif                                       
			End Transaction 
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO DESMONTAGEM CHARQUE  ==> " + _cNumDoc)
		Endif

		TRB->(DbSkip())

	Enddo

	TRB->(DbCloseArea())

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados de Devolução de Estoque          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT ZN_COD, ZN_CODDEST, SUM(ZN_PESOL) AS PESOTOT "
	cQuery += "  FROM " + RetSQLTab("SZN")
	cQuery += " WHERE " + RetSQLFil("SZN")
	cQuery += "   AND ZN_DESTINO = 'E'"
	cQuery += "   AND ZN_DTENTR = '" + dtos(mv_par01) + "'"
	cQuery += "   AND " + RetSQLDel("SZN")
	cQuery += " GROUP BY ZN_COD, ZN_CODDEST "
	cQuery += " ORDER BY ZN_COD "

	cQuery := ChangeQuery(cQuery)

	ProcLogAtu( 'MENSAGEM', "Seleção dos dados de devolução de estoque " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .F., .T.)

	TRB->(dbGoTop())
	While TRB->(!Eof())

		oSelf:IncRegua1("Selecionando dados de devolução de estoque ...")
		oSelf:IncRegua2()

		Pergunte(cPerg,.F.)   

		_cProduto := PADR(TRB->ZN_COD, 15, " ")
		_cDescPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
		_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
		_cLocal   := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_LOCPAD")
		_nPesoTot := TRB->PESOTOT
		_cNumDoc  := NextNumero("SD3",2,"D3_DOC",.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SD3 (devolução para o estoque)                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aVetor := {}   

		AADD(_aVetor, {"D3_TM     " , "012"      			,NIL})        
		AADD(_aVetor, {"D3_DOC    " , _cNumDoc    			,NIL})
		AADD(_aVetor, {"D3_CC     " , "1131005"   			,NIL})	// Desossa
		AADD(_aVetor, {"D3_EMISSAO" , ddatabase	  			,NIL})     
		AADD(_aVetor, {"D3_COD    " , _cProduto				,NIL})
		AADD(_aVetor, {"D3_UM     " , _cUnidMed				,NIL})
		AADD(_aVetor, {"D3_QUANT  " , _nPesoTot				,NIL})
		AADD(_aVetor, {"D3_LOCAL  " , _cLocal        		,NIL})
		AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())   	,NIL})

		// Executa devolução de estoque via rotina automatica
		If Len(_aVetor) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y| MATA240(x,y)},_aVetor,3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DEVOL DE ESTOQUE ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 012")
					MsgAlert("Houve erro na geração da devolução do estoque no SD3 ExecAuto MATA240 para TM 012. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO SD3 DEVOL DE ESTOQUE ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 012")
				Endif                                       
			End Transaction 
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DEVOL DE ESTOQUE ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 012")
		Endif

		TRB->(DbSkip())

	Enddo

	TRB->(DbCloseArea())

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados de Devolução da Graxaria         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT ZN_COD, ZN_CODDEST, SUM(ZN_PESOL) AS PESOTOT "
	cQuery += "  FROM " + RetSQLTab("SZN")
	cQuery += " WHERE " + RetSQLFil("SZN")
	cQuery += "   AND ZN_DESTINO = 'G'"
	cQuery += "   AND ZN_DTENTR = '" + dtos(mv_par01) + "'"
	cQuery += "   AND " + RetSQLDel("SZN")
	cQuery += " GROUP BY ZN_COD, ZN_CODDEST "
	cQuery += " ORDER BY ZN_COD "

	cQuery := ChangeQuery(cQuery)

	ProcLogAtu( 'MENSAGEM', "Seleção dos dados de devolução da Graxaria " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .F., .T.)

	TRB->(dbGoTop())
	While TRB->(!Eof())

		oSelf:IncRegua1("Selecionando dados de devolução da Graxaria ...")
		oSelf:IncRegua2()

		Pergunte(cPerg,.F.)   

		_cProduto := PADR(TRB->ZN_COD, 15, " ")
		_cDescPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
		_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
		_cLocal   := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_LOCPAD")
		_nPesoTot := TRB->PESOTOT
		_cNumDoc  := NextNumero("SD3",2,"D3_DOC",.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SD3 (devolução para o estoque graxaria)                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aVetor := {}   

		AADD(_aVetor, {"D3_TM     " , "015"      			,NIL})        
		AADD(_aVetor, {"D3_DOC    " , _cNumDoc    			,NIL})
		AADD(_aVetor, {"D3_CC     " , "1131005"   			,NIL})	// Desossa
		AADD(_aVetor, {"D3_EMISSAO" , ddatabase	  			,NIL})     
		AADD(_aVetor, {"D3_COD    " , _cProduto				,NIL})
		AADD(_aVetor, {"D3_UM     " , _cUnidMed				,NIL})
		AADD(_aVetor, {"D3_QUANT  " , _nPesoTot				,NIL})
		AADD(_aVetor, {"D3_LOCAL  " , _cLocal        		,NIL})
		AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())   	,NIL})

		// Executa devolução de estoque graxaria via rotina automatica
		If Len(_aVetor) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y| MATA240(x,y)},_aVetor,3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DEVOL GRAXARIA   ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 015")
					MsgAlert("Houve erro na geração da devolução do estoque Graxaria no SD3 ExecAuto MATA240 para TM 015. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO SD3 DEVOL GRAXARIA   ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 015")
				Endif                                       
			End Transaction 
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DEVOL GRAXARIA   ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 015")
		Endif

		aAutoCab   := {}
		aAutoItens := {}
		aItem	   := {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SD3 (Desmontagem Graxaria)                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aAutoCab,{"cProduto"	, _cProduto						, Nil})
		AADD(aAutoCab,{"cLocOrig"	, _cLocal  						, Nil})
		AADD(aAutoCab,{"nQtdOrig"	, _nPesoTot						, Nil})
		AADD(aAutoCab,{"nQtdOrigSe" , CriaVar("D3_QTSEGUM") 		, Nil})
		AADD(aAutoCab,{"cDocumento" , _cNumDoc						, Nil})
		AADD(aAutoCab,{"cNumLote" 	, CriaVar("D3_NUMLOTE") 		, Nil})
		AADD(aAutoCab,{"cLoteDigi"  , CriaVar("D3_LOTECTL") 		, Nil})
		AADD(aAutoCab,{"dDtValid" 	, CriaVar("D3_DTVALID") 		, Nil})
		AADD(aAutoCab,{"nPotencia"  , CriaVar("D3_POTENCI") 		, Nil})
		AADD(aAutoCab,{"cLocaliza"  , CriaVar("D3_LOCALIZ") 		, Nil})
		AADD(aAutoCab,{"cNumSerie"  , CriaVar("D3_NUMSERI") 		, Nil})

		AADD(aItem,{"D3_COD"		, PADR("PP0084", 15, " ")		, Nil})
		AADD(aItem,{"D3_LOCAL"		, "01"     						, Nil})
		AADD(aItem,{"D3_QUANT"		, _nPesoTot						, Nil})
		AADD(aItem,{"D3_QTSEGUM"	, CriaVar("D3_QTSEGUM")			, Nil})
		AADD(aItem,{"D3_RATEIO"		, 100							, Nil})
		AADD(aItem,{"D3_ROTBLK"		, AllTrim(FunName())			, Nil})
		AADD(aAutoItens,aClone(aItem))

		// Executa desmontagem via rotina automatica
		If Len(aAutoCab) > 0 .And. Len(aAutoItens) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y,z,t| Mata242(x,y,z,t)},aAutoCab,aAutoItens,3,.T.) 	// inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - DESMONTAGEM GRAXARIA ==> " + _cNumDoc)
					MsgAlert("Houve erro na geração da desmontagem graxaria no SD3 ExecAuto MATA242. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO DESMONTAGEM GRAXARIA ==> " + _cNumDoc)
				Endif                                       
			End Transaction 
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO DESMONTAGEM GRAXARIA ==> " + _cNumDoc)
		Endif

		TRB->(DbSkip())

	Enddo

	TRB->(DbCloseArea())

	ProcLogAtu("FIM","Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()) ,,,.T.)

Return
