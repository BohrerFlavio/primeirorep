#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MGT_BLK2 
@Type			: Função de Usuário
@Sample			: U_MGT_BLK2()
@Description	: Rotina para geração das ordens de produção e apontamentos da produção
                  referente aos movimentos do processo de corte conforme data do corte 
				  a ser processado
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Revisão em Mai/2021 considerando situação atual para rodar em Jan/2022
/*/
//--------------------------------------------------------------------------------------
User Function MGT_BLK2()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| BLK2NewPerg ( oSelf ) }   
	Local cFunction    := "MGT_BLK2"
	Local cTitle	   := "Geração Dados Bloco K Referente Processo de Corte"
	Local cDescription := "Rotina responsável pela geração das ordens de produção e apontamentos da produção referente ao movimentos do processo de corte conforme data de corte a ser processado." + ;
						  "Para executar a geração das informações necessárias, informe os parâmetros necessários." + CRLF + CRLF +;
						  "Clique no botão abaixo e aguarde a conclusão do processamento."


	Private cPerg	   := "MGT_BLK2"

	// Botão para visualização do log de processamento
	AADD(aInfo,{"Históricos de Processamentos", { || ProcLogView(,FunName()) },"WATCH" })

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
/*/{Protheus.doc} BLK2NewPerg
Tratamento para a utilização do tNewProcess
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK2NewPerg( oSelf )

	BLK2Proc(.F.,oSelf)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BLK2Proc
Função que efetua o processamento das informações (Primeira Etapa)
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK2Proc( lBat, oSelf )

	Local cIdCV8 := ""

	// Valida data de processamento com data base do sistema
	If mv_par01 <> dDataBase
		Aviso("PROCESSAMENTO BLOCO K - PROCESSO DE CORTE", "Data do processamento DIFERENTE da data base do sistema." + CRLF + CRLF + ;
			  "Processamento não será executado. Favor ajustar datas!",{"Ok"},2)
		Return
	Endif

	// Verifica se existe processo de corte para data informada
	DbSelectArea("ZAJ")
	DbSetOrder(12)
	If !DbSeek(xFilial("ZAJ") + Dtos(mv_par01))
		Aviso("PROCESSAMENTO BLOCO K - PROCESSO DE CORTE", "Não existe processo de corte para data de corte informada." + CRLF + CRLF + ;
			  "Processamento não será executado. Favor Verificar!",{"Ok"},2)
		Return
	Endif

	ProcLogIni({},FunName(),,@cIdCV8)
	ProcLogAtu("INICIO","Rotina Chamadora: "+ FunName() + " " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()) ,,,.T.)

	_FlagIncOP := .F.
	_FlagMovPD := .F.

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula total de registros a serem processados corretamente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT( ZAJ.R_E_C_N_O_ ) TOTREG "
	cQuery += "  FROM " + RetSQLTab("ZAJ") + "," + RetSQLTab("SZG") + "," + RetSQLTab("SB1")
	cQuery += " WHERE " + RetSQLFil("ZAJ") + " AND " + RetSQLFil("SZG") + " AND " + RetSQLFil("SB1")
	cQuery += "   AND ZAJ_NUMAM = ZG_NUMAM "
	cQuery += "   AND ZAJ_DTCORT = '" + dtos(mv_par01) + "'"
	cQuery += "   AND ZAJ_COD = B1_COD "
	cQuery += "   AND B1_GRUPO = '4001'"
	//cQuery += "   AND ZAJ_DTEXE1 <> ''"
	//cQuery += "   AND ZAJ_DTEXE2 = ''"
	cQuery += "   AND " + RetSQLDel("ZAJ") + " AND " + RetSQLDel("SZG") + " AND " + RetSQLDel("SB1")

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTOT",.T.,.T.)

	oSelf:SetRegua1(TRBTOT->TOTREG)
	oSelf:SetRegua2(TRBTOT->TOTREG)

	TRBTOT->( DbCloseArea() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados ZAJ para GRUPO PRODUTO == '4001' ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Seleção dos movimentos do corte (ZAJ) 
	cQuery := "SELECT ZG_NUMAM, ZAJ_CORORI, ZAJ_COD, COUNT(ZAJ_NUM) AS QTDEPCS, SUM(ZAJ_PESOES) AS PESOTOT " // Alterado o campo ZAJ_PESO para ZAJ_PESOES
	cQuery += "  FROM " + RetSQLTab("ZAJ") + "," + RetSQLTab("SZG") + "," + RetSQLTab("SB1")                 // (peso estimado)
	cQuery += " WHERE " + RetSQLFil("ZAJ") + " AND " + RetSQLFil("SZG") + " AND " + RetSQLFil("SB1")
	cQuery += "   AND ZAJ_NUMAM = ZG_NUMAM "
	cQuery += "   AND ZAJ_DTCORT = '" + dtos(mv_par01) + "'"
	cQuery += "   AND ZAJ_COD = B1_COD "
	cQuery += "   AND B1_GRUPO = '4001'"
	//cQuery += "   AND ZAJ_DTEXE1 <> ''"
	//cQuery += "   AND ZAJ_DTEXE2 = ''"
	cQuery += "   AND " + RetSQLDel("ZAJ") + " AND " + RetSQLDel("SZG") + " AND " + RetSQLDel("SB1")
	cQuery += " GROUP BY ZG_NUMAM, ZAJ_CORORI, ZAJ_COD"
	cQuery += " ORDER BY ZG_NUMAM, ZAJ_CORORI, ZAJ_COD"

	cQuery := ChangeQuery(cQuery)

	ProcLogAtu("MENSAGEM", "Seleção dos movimentos do corte (ZAJ) GRUPO = '4001' com Data de: " + Dtoc(mv_par01) + " " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery)

	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "TRB", .F., .T.)

	TRB->(dbGoTop())
	While TRB->(!Eof())

		oSelf:IncRegua1("Selecionando os movimentos do abate GRUPO = '4001' ...")
		oSelf:IncRegua2()

		Pergunte(cPerg,.F.)

		// Determina o % da meia res a ser produzida para aplicação na segunda unidade de medida
		_cNumam   := TRB->ZG_NUMAM
		_cLoteCTL := "P" + TRB->ZG_NUMAM + Dtos(mv_par01)
		_cProduto := TRB->ZAJ_COD

		// Aplicando o % da meia res apurado na quantidade da segunda unidade de medida a ser produzida
		_nQtdePcs := TRB->QTDEPCS
		_nPesoTot := TRB->PESOTOT      
		_cDescPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
		_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
		_cGrupPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_GRUPO")
		_cNumOp   := GETSX8NUM("SC2","C2_NUM")
		ConfirmSX8()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SC2 (ordens de produção)                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aAutoSC2 := {}
		AADD(_aAutoSC2, {"AUTEXPLODE", "S"    						, NIL})
		AADD(_aAutoSC2, {"C2_FILIAL" , xFilial("SC2")              	, NIL})
		AADD(_aAutoSC2, {"C2_NUM"    , _cNumOp                     	, NIL})
		AADD(_aAutoSC2, {"C2_ITEM"   , "01"                        	, NIL})
		AADD(_aAutoSC2, {"C2_SEQUEN" , "001"                    	, NIL})
		AADD(_aAutoSC2, {"C2_PRODUTO", _cProduto                   	, NIL})
		AADD(_aAutoSC2, {"C2_LOCAL"  , "01"                        	, NIL})
		AADD(_aAutoSC2, {"C2_CC"     , "1131004"                  	, NIL})		// Sala de Corte I
		AADD(_aAutoSC2, {"C2_QUANT"  , _nPesoTot                  	, NIL})
		AADD(_aAutoSC2, {"C2_DATPRI" , dDatabase                	, NIL})
		AADD(_aAutoSC2, {"C2_DATPRF" , dDatabase                	, NIL})
		AADD(_aAutoSC2, {"C2_EMISSAO", dDatabase                	, NIL})
		AADD(_aAutoSC2, {"C2_STATUS" , "N"                      	, NIL})
		AADD(_aAutoSC2, {"C2_TPOP"   , "F"                      	, NIL})
		AADD(_aAutoSC2, {"C2_GRUPO"  , _cGrupPrd                  	, NIL})
		AADD(_aAutoSC2, {"C2_UM"     , "KG"                       	, NIL})
		AADD(_aAutoSC2, {"C2_SEGUM"  , "PC"                     	, NIL})
		AADD(_aAutoSC2, {"C2_QTSEGUM", _nQtdePcs		            , NIL})
		AADD(_aAutoSC2, {"C2_NUMAM"  , _cNumam		              	, NIL})
		AADD(_aAutoSC2, {"C2_FLOTE"  , _cLoteCTL         	       	, NIL})  	// Para fins de facilitar rastreio

		// Executa movimentacao de estoque via rotina automatica.
		If Len(_aAutoSC2) > 0
			lMSErroAuto := .F.
			DbSelectArea("SC2")
			Begin Transaction
				MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, 3)
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - GRUPO = '4001' GERADO OP NUMERO ==> " + _cNumOp + " PARA PRODUTO: " + AllTrim(_cProduto) + " Aviso de Matanca: " + _cNumam)
					MsgAlert("Houve erro na geração da Ordem de Produção na SC2. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
					_FlagIncOP := .F.
				Else 
					ProcLogAtu("MENSAGEM", "GRUPO = '4001' GERADO OP NUMERO ==> " + _cNumOp + " PARA PRODUTO: " + AllTrim(_cProduto) + " Aviso de Matanca: " + _cNumam)
					_FlagIncOP := .T.
				Endif                                       
			End Transaction
		Else
			ProcLogAtu("MENSAGEM", "GRUPO = '4001' NAO FOI GERADO OP NUMERO ==> " + _cNumOp + " PARA PRODUTO: " + AllTrim(_cProduto) + " Aviso de Matanca: " + _cNumam)
			_FlagIncOP := .F.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SD3 (movimentos de produção)                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aVetor := {}
		AADD(_aVetor, {"D3_TM" 		, "006"            						,NIL})
		AADD(_aVetor, {"D3_COD" 	, _cProduto								,NIL})
		AADD(_aVetor, {"D3_UM" 		, "KG"									,NIL})
		AADD(_aVetor, {"D3_QUANT" 	, _nPesoTot								,NIL})
		AADD(_aVetor, {"D3_OP" 		, _cNumOp + "01001"				  		,NIL})
		AADD(_aVetor, {"D3_LOCAL" 	, "01"           						,NIL})
		AADD(_aVetor, {"D3_DOC" 	, NextNumero("SD3",2,"D3_DOC",.T.) 		,NIL})
		AADD(_aVetor, {"D3_EMISSAO" , dDatabase 					    	,NIL})
		AADD(_aVetor, {"D3_SEGUM" 	, "PC"									,NIL})
		AADD(_aVetor, {"D3_QTSEGUM" , _nQtdePcs								,NIL})
		AADD(_aVetor, {"D3_FLOTE"   , _cLoteCTL		 				  		,NIL})
		AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())  					,NIL})

		// Executa movimentacao de produção via rotina automatica.
		If Len(_aVetor) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y| mata250(x,y)}, _aVetor, 3)
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - GRUPO = '4001' GERADO SD3 DE PRODUCAO ==> " + _cNumOp + "01001 PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 006")
					MsgAlert("Houve erro na geração da produção do SD3 ExecAuto MATA250 TM 006. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
					_FlagMovPD := .F.
				Else 
					ProcLogAtu("MENSAGEM", "GRUPO = '4001' GERADO SD3 DE PRODUCAO ==> " + _cNumOp + "01001 PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 006")
					_FlagMovPD := .T.
				Endif                                       
			End Transaction 
		Else
			ProcLogAtu("MENSAGEM", "GRUPO = '4001' NAO FOI GERADO SD3 DE PRODUCAO ==> " + _cNumOp + "01001 PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 006")
			_FlagMovPD := .F.
		Endif

		TRB->(DbSkip())
	Enddo

	TRB->(DbCloseArea())

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

	// Verifica se todos os processos de inclusão das OPs e realização dos movimentos de produção
	// foram executados com sucesso e grava o flag de data da fase 2 - corte (ZAJ_DTEXE2) GRUPO PRODUTO == '4001'
	If _FlagIncOP .And. _FlagMovPD
		/*
		cQueryUPD := "UPDATE " + RetSQLName("ZAJ")
		cQueryUPD += "   SET ZAJ_DTEXE2 = '" + Dtos(DDATABASE) + "'"
		cQueryUPD += " WHERE ZAJ_FILIAL = '" + xFilial('ZAJ') + "'"
		cQueryUPD += "   AND ZAJ_DTCORT = '" + Dtos(mv_par01) + "'"
		cQueryUPD += "   AND B1_GRUPO = '4001'"
		cQueryUPD += "   AND D_E_L_E_T_ = ''"

		If TCSQLExec(cQueryUPD) < 0
			ProcLogAtu("ERRO", "ERRO NO UPDATE DE PROCESSAMENTO da ZAJ CORTE GRUPO = '4001': ", TCSQLError())
			MsgStop("TCSQLError() " + TCSQLError())
		Else
			ProcLogAtu("MENSAGEM", "Geração dados bloco K referente corte na data de " + Dtoc(mv_par01) + " finalizado com sucesso. GRUPO = '4001'")
			MsgAlert("Geração dados bloco K referente corte na data de " + Dtoc(mv_par01) + " finalizado com sucesso. GRUPO = '4001'")
		EndIf
		*/
	Else
		ProcLogAtu("MENSAGEM", "Não houve processamento a ser realizado para data de corte " + Dtoc(mv_par01) + " ou processamento nesta data já realizado. GRUPO = '4001'")
		MsgAlert("Não houve processamento a ser realizado para data de corte " + Dtoc(mv_par01) + " ou processamento nesta data já realizado. GRUPO = '4001'")
	Endif

	ProcLogAtu("FIM","Rotina Chamadora: "+ FunName() + " " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()) ,,,.T.)

Return
