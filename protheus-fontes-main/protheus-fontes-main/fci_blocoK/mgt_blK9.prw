#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MGT_BLK9 
@Type			: Função de Usuário
@Sample			: U_MGT_BLK9()
@Description	: Rotina para geração das ordens de produção e apontamentos da produção
                  referente aos movimentos do processo de moídas dos porcionados conforme
				  data do corte a ser processado
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Revisão em Jun/2021 considerando situação atual para rodar em Jan/2022
/*/
//--------------------------------------------------------------------------------------
User Function MGT_BLK9()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| BLK9NewPerg ( oSelf ) }   
	Local cFunction    := "MGT_BLK9"
	Local cTitle	   := "Geração Dados Bloco K Referente Processo de Moídas"
	Local cDescription := "Rotina responsável pela geração das ordens de produção e apontamentos da produção referente ao movimentos do processo de moídas dos porcionados conforme data a ser processado." + ;
						  "Para executar a geração das informações necessárias, informe os parâmetros necessários." + CRLF + CRLF + ; 
						  "Clique no botão abaixo e aguarde a conclusão do processamento."

	Private cPerg	   := "MGT_BLK9"
	//Private cCadastro  := OemToAnsi("Geração Dados Bloco K Referente Processo de Moídas")

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
/*/{Protheus.doc} BLK9NewPerg
Tratamento para a utilização do tNewProcess
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK9NewPerg( oSelf )

	BLK9Proc(.F.,oSelf)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BLK9Proc
Função que efetua o processamento das informações
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK9Proc( lBat, oSelf )

	Local cIdCV8 := ""

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

	ProcLogIni({},FunName(),,@cIdCV8)
	ProcLogAtu("INICIO","Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()) ,,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula total de registros a serem processados corretamente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT( ZAU.R_E_C_N_O_ ) TOTREG "
	cQuery += "  FROM " + RetSQLTab("ZAU")
	cQuery += " WHERE " + RetSQLFil("ZAU")
	cQuery += "   AND ZAU_DTPROD = '" + dtos(mv_par01) + "'"
	cQuery += "   AND ZAU_QRPESF > 0 "
	cQuery += "   AND " + RetSQLDel("ZAU")

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTOT",.T.,.T.)

	oSelf:SetRegua1(TRBTOT->TOTREG)
	oSelf:SetRegua2(TRBTOT->TOTREG)

	TRBTOT->( DbCloseArea() )


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento das Moídas                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cGrupoMoi := GETMV("SI_GRPMOI")			// Filtra somente produtos do grupo de moídas conforme parâmetro

	cQuery := "SELECT ZAU_NUM, ZAU_COD, SUM(ZAU_QRPESF) AS TOTPESO, SUM(ZAU_QRCAIF) AS TOTCAIX "
	cQuery += "  FROM " + RetSQLTab("ZAU") + "," + RetSQLTab("SB1")
	cQuery += " WHERE " + RetSQLFil("ZAU") + " AND " + RetSQLFil("SB1")
	cQuery += "   AND ZAU_DTPROD = '" + dtos(mv_par01) + "'"
	cQuery += "   AND ZAU_QRPESF > 0 "
	cQuery += "   AND ZAU_COD = B1_COD "
	cQuery += "   AND B1_GRUPO IN " + FORMATIN(_cGrupoMoi,"/")
	cQuery += "   AND " + RetSQLDel("ZAU") + " AND " + RetSQLDel("SB1")
	cQuery += " GROUP BY ZAU_NUM, ZAU_COD "
	cQuery += " ORDER BY ZAU_NUM, ZAU_COD "

	cQuery := ChangeQuery(cQuery)

	ProcLogAtu( 'MENSAGEM', "Seleção das moídas " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery)

	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "TRB", .F., .T.)

	TRB->(dbGoTop())
	While TRB->(!Eof())

		oSelf:IncRegua1("Selecionando saída de PA pendurados (PAs) ...")
		oSelf:IncRegua2()

		Pergunte(cPerg,.F.)

		_cLoteMoi := TRB->ZAU_NUM
		_cProduto := TRB->ZAU_COD
		_nPesoTot := TRB->TOTPESO      
		_nQtdeCxs := TRB->TOTCAIX
		_cLocPad  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_LOCPAD")
		_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
		_cGrupPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_GRUPO")
		_cNumOp   := GETSX8NUM("SC2","C2_NUM")
		ConfirmSX8()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SC2 (ordens de produção)                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aAutoSC2 := {}
		//AADD (_aAutoSC2, {"AUTEXPLODE", "S"    						, NIL})	// NÃO USADO NESTA FASE PARA NÃO GERAR EMPENHOS, POIS SERÃO GERADOS MANUALMENTE
		AADD (_aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 	, NIL})
		AADD (_aAutoSC2, {"C2_NUM"    , _cNumOp                        	, NIL})
		AADD (_aAutoSC2, {"C2_ITEM"   , "01"                           	, NIL})
		AADD (_aAutoSC2, {"C2_SEQUEN" , "001"                    		, NIL})
		AADD (_aAutoSC2, {"C2_PRODUTO", _cProduto                      	, NIL})
		AADD (_aAutoSC2, {"C2_LOCAL"  , _cLocPad                       	, NIL})
		AADD (_aAutoSC2, {"C2_CC"     , "1131014"                  		, NIL})	// Porcionados
		AADD (_aAutoSC2, {"C2_QUANT"  , _nPesoTot                  		, NIL})
		AADD (_aAutoSC2, {"C2_DATPRI" , dDatabase                		, NIL})
		AADD (_aAutoSC2, {"C2_DATPRF" , dDatabase                		, NIL})
		AADD (_aAutoSC2, {"C2_EMISSAO", dDatabase                		, NIL})
		AADD (_aAutoSC2, {"C2_STATUS" , "N"                      		, NIL})
		AADD (_aAutoSC2, {"C2_TPOP"   , "F"                      		, NIL})
		AADD (_aAutoSC2, {"C2_GRUPO"  , _cGrupPrd                  		, NIL})
		AADD (_aAutoSC2, {"C2_UM"     , _cUnidMed                  		, NIL})
		AADD (_aAutoSC2, {"C2_BATCH"  , "S"    		              		, NIL})  //	Força gravação deste campo para não mostrar mensagem na tela de OPs pelo sistema

		// Executa geração da OP via rotina automatica
		If Len(_aAutoSC2) > 0
			lMSErroAuto := .F.
			DbSelectArea("SC2")
			Begin Transaction
				MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, 3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - GERADO OP MOIDAS ==> " + _cNumOp + " PARA PRODUTO " + AllTrim(_cProduto) + " Lote " + _cLoteMoi)
					MsgAlert("Houve erro na geração da Ordem de Produção na SC2. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO OP MOIDAS ==> " + _cNumOp + " PARA PRODUTO " + AllTrim(_cProduto) + " Lote " + _cLoteMoi)
				Endif                                       
			End Transaction
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO OP MOIDAS ==> " + _cNumOp + " PARA PRODUTO " + AllTrim(_cProduto) + " Lote " + _cLoteMoi)
		Endif


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SD4 (empenhos) a partir do Lote correspondente da ZAV   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery1 := "SELECT ZAV_NUM, ZAV_COD, SUM(ZAV_QRPESO) AS PESOTOT "
		cQuery1 += "  FROM " + RetSQLTab("ZAV")
		cQuery1 += " WHERE " + RetSQLFil("ZAV")
		cQuery1 += "   AND ZAV_NUM = '" + _cLoteMoi + "'"
		cQuery1 += "   AND ZAV_QRPESO > 0 "
		cQuery1 += "   AND " + RetSQLDel("ZAV")
		cQuery1 += " GROUP BY ZAV_NUM, ZAV_COD "
		cQuery1 += " ORDER BY ZAV_NUM, ZAV_COD "

		cQuery1 := ChangeQuery(cQuery1)

		ProcLogAtu( 'MENSAGEM', "Seleção que grava SD4 (empenhos) a partir do Lote correspondente da ZAV " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery1)

		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1), "TRB1", .F., .T.)

		TRB1->(dbGoTop())
		While TRB1->(!Eof())

			_cLoteMoi1 := TRB1->ZAV_NUM
			_cProduto1 := TRB1->ZAV_COD
			_nPesoTot1 := TRB1->PESOTOT
			_cLocPad1  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto1, "B1_LOCPAD")

			DbSelectArea("SD4")
			Reclock("SD4",.T.)
			SD4->D4_FILIAL  := xFilial("SD4")
			SD4->D4_COD     := _cProduto1
			SD4->D4_OP      := _cNumOP
			SD4->D4_LOCAL   := _cLocPad1
			SD4->D4_DATA    := DDATABASE
			SD4->D4_QTDEORI := _nPesoTot1
			SD4->D4_QUANT   := _nPesoTot1
			SD4->D4_DTVALID := DDATABASE
			SD4->D4_ROTBLK  := AllTrim(FunName())
			MsUnlock()

			// Ajusta empenho dos saldos do produto
			DbSelectArea("SB2")
			DbSetOrder(1)
			If DbSeek(xFilial("SB2") + SD4->D4_COD + SD4->D4_LOCAL)
				RecLock("SB2",.F.)
				SB2->B2_QEMP := SB2->B2_QEMP + SD4->D4_QUANT
				MsUnlock()
			Else
				MsgAlert("Produto / Local " + SD4->D4_COD + " / " + SD4->D4_LOCAL + " não encontrado no SB2 para ajuste do empenho. Verifique!")
			Endif

			TRB1->(DbSkip())
		Enddo

		TRB1->(DbCloseArea())


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SD3 (movimentos de produção)                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SD3")
		_aVetor := {}
		AADD(_aVetor, {"D3_TM     " , "011"            						,NIL})
		AADD(_aVetor, {"D3_COD    " , _cProduto								,NIL})
		AADD(_aVetor, {"D3_UM     " , _cUnidMed								,NIL})
		AADD(_aVetor, {"D3_QUANT  " , _nPesoTot								,NIL})
		AADD(_aVetor, {"D3_OP     " , _cNumOp + "01001  "			  		,NIL})
		AADD(_aVetor, {"D3_LOCAL  " , _cLocPad         						,NIL})
		AADD(_aVetor, {"D3_DOC    " , NextNumero("SD3",2,"D3_DOC",.T.) 		,NIL})
		AADD(_aVetor, {"D3_EMISSAO" , dDatabase 					    	,NIL})
		AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())  					,NIL})

		// Executa movimentacao de produção via rotina automatica.
		If Len(_aVetor) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y| mata250(x,y)}, _aVetor, 3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - GERADO SD3 DE PRODUCAO MOIDAS ==> " + _cNumOp + "01001   PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 011")
					MsgAlert("Houve erro na geração da produção do SD3 ExecAuto MATA250 TM 011. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO SD3 DE PRODUCAO MOIDAS ==> " + _cNumOp + "01001   PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 011")
				Endif                                       
			End Transaction 
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE PRODUCAO MOIDAS ==> " + _cNumOp + "01001   PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 011")
		Endif

		TRB->(DbSkip())
	Enddo

	TRB->(DbCloseArea())

	ProcLogAtu("FIM","Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()) ,,,.T.)

Return
