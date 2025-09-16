#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MGT_BLK3 
@Type			: Função de Usuário
@Sample			: U_MGT_BLK3()
@Description	: Rotina para geração das ordens de produção, apontamentos de produção
                  e baixa PA ref. aos movimentos do carregamento de pendurados conforme
				  data de saída a ser processada
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Revisão em Mai/2021 considerando situação atual para rodar em Jan/2022
/*/
//--------------------------------------------------------------------------------------
User Function MGT_BLK3()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| BLK3NewPerg ( oSelf ) }   
	Local cFunction    := "MGT_BLK3"
	Local cTitle	   := "Geração Dados Bloco K Referente Carregamento Pendurados"
	Local cDescription := "Rotina responsável pela geração das ordens de produção, apontamentos da produção e baixa dos PAs referente ao movimentos do carregamento de pendurados " + ;
	                      "conforme data de saída. Para executar a geração das informações necessárias, informe os parâmetros necessários." + CRLF + CRLF +;
						  "Clique no botão abaixo e aguarde a conclusão do processamento."

	Private cPerg	   := "MGT_BLK3"

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
/*/{Protheus.doc} BLK3NewPerg
Tratamento para a utilização do tNewProcess
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK3NewPerg( oSelf )

	BLK3Proc(.F.,oSelf)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BLK3Proc
Função que efetua o processamento das informações
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK3Proc( lBat, oSelf )

	Local cIdCV8 := ""
	Local cOpIni := ""
	Local cOpFim := ""

	// Valida data de processamento com data base do sistema
	If mv_par01 <> dDataBase
		Aviso("PROCESSAMENTO BLOCO K - PROCESSO DE CARREGAMENTO DE PENDURADOS", "Data do processamento DIFERENTE da data base do sistema." + CRLF + CRLF + ;
			  "Processamento não será executado. Favor ajustar datas!",{"Ok"},2)
		Return
	Endif

	// Carrega variáveis para gerar LOG de inconsistências referente aos PAs não cadastrados nas estruturas de produtos
	cMask  := "Arquivos Texto (*.TXT) |*.txt|"
	cTexto := "Verifique abaixo o resultado de PAs que não estão cadastros nas estruturas de produtos." + CHR(13) + CHR(10)
	cTexto += Replicate("-",128) + CHR(13) + CHR(10)
	cTexto += "Empresa : " + SM0->M0_CODIGO + " - " + SM0->M0_NOME + CHR(13) + CHR(10)
	cTexto += Space(128) + CHR(13) + CHR(10)
	cTexto += Replicate("-",128) + CHR(13) + CHR(10)

	// Verifica se existe data de saída informada
	cQuery := "SELECT COUNT( R_E_C_N_O_ ) TOTREG "
	cQuery += "  FROM " + RetSQLName("ZAJ")
	cQuery += " WHERE ZAJ_FILIAL ='" + xFilial("ZAJ") + "'"
	cQuery += "   AND ZAJ_DATAS = '" + Dtos(mv_par01) + "'"
	cQuery += "   AND D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTOT",.T.,.T.)

	If TRBTOT->TOTREG = 0
		Aviso("PROCESSAMENTO BLOCO K - PROCESSO DE CARREGAMENTO DE PENDURADOS", "Não existe processo de carregamento de pendurados para data de saída informada." + CRLF + CRLF + ;
		      "Processamento não será executado. Favor Verificar!",{"Ok"},2)
		Return
	Endif

	TRBTOT->( DbCloseArea() )

	// Verifica se todos os PAs do processamento em questão possuem estruturas cadastradas
	_lProcessa := .F.
	cQuery := "SELECT ZAJ_NUMAM, ZAJ_CODPA, (SELECT COUNT(*) FROM SG1010 WHERE G1_COD = ZAJ_CODPA AND D_E_L_E_T_ <> '*') AS QTDECOMP, COUNT(*) AS QTDEPCS, SUM(ZAJ_PESO) AS PESOTOT "
	cQuery += "  FROM " + RetSQLTab("ZAJ")
	cQuery += " WHERE " + RetSQLFil("ZAJ")
	cQuery += "   AND ZAJ_DATAS = '" + dtos(mv_par01) + "'"
	cQuery += "   AND ZAJ_PRECAR <> ''"
	cQuery += "   AND ZAJ_CODPA <> ''"
	//cQuery += "   AND ZAJ_DTEXE1 <> ''"
	//cQuery += "   AND ZAJ_DTEXE2 <> ''"
	//cQuery += "   AND ZAJ_DTEXE3 = ''"
	cQuery += "   AND " + RetSQLDel("ZAJ")
	cQuery += " GROUP BY ZAJ_NUMAM, ZAJ_CODPA"
	cQuery += " ORDER BY ZAJ_NUMAM, ZAJ_CODPA"

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .F., .T.)

	TRB->(dbGoTop())
	While TRB->(!Eof())
		_cCodPA := TRB->ZAJ_CODPA

		DbSelectArea("SG1")
		DbSetOrder(1)
		If !DbSeek(xFilial("SG1") + _cCodPA)
			cTexto += "Produto " + AllTrim(_cCodPA) + " não possui estrutura cadastrada e necessita ser cadastrada." + CHR(13) + CHR(10)
			_lProcessa := .T.
		Endif

		TRB->(DbSkip())
	Enddo

	TRB->(DbCloseArea())

	If _lProcessa
		cTexto := "Log de Validações Iniciais" + CHR(13) + CHR(10) + cTexto
		__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG",cTexto)
		DEFINE FONT oFont NAME "Mono AS" SIZE 6,15
		DEFINE MSDIALOG oDlg TITLE "Processamento da verificação das estruturas que necessitam de cadastramento" From 000, 000 to 570,950 PIXEL
		@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 470,245 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		DEFINE SBUTTON FROM 255,395 TYPE 1  ACTION oDlg:End() ENABLE OF oDlg PIXEL                                                               // Apaga
		DEFINE SBUTTON FROM 255,365 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL     // Salva e Apaga   // "Salvar Como..."
		ACTIVATE MSDIALOG oDlg CENTER

		MsgAlert("Processo interrompido devido estruturas que necessitam de cadastramento. Após corrigido refaça esta operação.")

		Return
	Endif

	ProcLogIni({},FunName(),,@cIdCV8)
	ProcLogAtu("INICIO","Rotina Chamadora: " + FunName() + " " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()) ,,,.T.)

	_FlagIncOP := .F.
	_FlagMovPD := .F.
	_FlagMovBX := .F.

	Pergunte(cPerg,.F.)

	If !lBat
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula total de registros a serem processados corretamente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT COUNT( ZAJ.R_E_C_N_O_ ) TOTREG "
		cQuery += "  FROM " + RetSQLTab("ZAJ")
		cQuery += " WHERE " + RetSQLFil("ZAJ")
		cQuery += "   AND ZAJ_DATAS = '" + dtos(mv_par01) + "'"
		cQuery += "   AND ZAJ_PRECAR <> ''"
		cQuery += "   AND ZAJ_CODPA <> ''"
		//cQuery += "   AND ZAJ_DTEXE1 <> ''"
		//cQuery += "   AND ZAJ_DTEXE2 <> ''"
		//cQuery += "   AND ZAJ_DTEXE3 = ''"
		cQuery += "   AND " + RetSQLDel("ZAJ")

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTOT",.T.,.T.)

		oSelf:SetRegua1(TRBTOT->TOTREG)
		oSelf:SetRegua2(TRBTOT->TOTREG)

		TRBTOT->( DbCloseArea() )
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados Carregamento Pendurados          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Seleção dos movimentos do carregamento pendurados (ZAJ)
	cQuery := "SELECT ZAJ_NUMAM, ZAJ_ZAPNUM, ZAJ_CODPA, ZAJ_COD, (SELECT COUNT(*) FROM SG1010 WHERE G1_COD = ZAJ_CODPA AND D_E_L_E_T_ <> '*') AS QTDECOMP, COUNT(*) AS QTDEPCS, SUM(ZAJ_PESO) AS PESOTOT "
	cQuery += "  FROM " + RetSQLTab("ZAJ")
	cQuery += " WHERE " + RetSQLFil("ZAJ")
	cQuery += "   AND ZAJ_DATAS = '" + dtos(mv_par01) + "'"
	cQuery += "   AND ZAJ_PRECAR <> ''"
	cQuery += "   AND ZAJ_CODPA <> ''"
	//cQuery += "   AND ZAJ_DTEXE1 <> ''"
	//cQuery += "   AND ZAJ_DTEXE2 <> ''"
	//cQuery += "   AND ZAJ_DTEXE3 = ''"
	cQuery += "   AND " + RetSQLDel("ZAJ")
	cQuery += " GROUP BY ZAJ_NUMAM, ZAJ_ZAPNUM, ZAJ_CODPA, ZAJ_COD "
	cQuery += " ORDER BY ZAJ_NUMAM, ZAJ_ZAPNUM, ZAJ_CODPA, ZAJ_COD "

	cQuery := ChangeQuery(cQuery) 

	ProcLogAtu("MENSAGEM", "Seleção dos movimentos do carregamento pendurados (ZAJ) com Data de: " + Dtoc(mv_par01) + " " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery)

	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .F., .T.)

	_nCont := 1
	TRB->(dbGoTop())
	While TRB->(!Eof())

		oSelf:IncRegua1("Selecionando os movimentos do carregamento pendurados ...")
		oSelf:IncRegua2()

		Pergunte(cPerg,.F.)

		_cNumam    := TRB->ZAJ_NUMAM
		_cLoteCTLP := "P" + TRB->ZAJ_NUMAM + Dtos(mv_par01)
		_cNumcer   := TRB->ZAJ_ZAPNUM
		_cLoteCTLT := "T" + TRB->ZAJ_ZAPNUM + Dtos(mv_par01)
		_cProduto  := TRB->ZAJ_CODPA
		_nQtdePcs  := TRB->QTDEPCS		// TRB->QTDEPCS / TRB->QTDECOMP (retirado por solicitação do Henrique em 15/11/2016)
		_nPesoTot  := TRB->PESOTOT		// TRB->PESOTOT / TRB->QTDECOMP (retirado por solicitação do Henrique em 15/11/2016)
		_cDescPrd  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
		_cUnidMed  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
		_cGrupPrd  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_GRUPO")
		_cNumOp    := GETSX8NUM("SC2","C2_NUM")
		ConfirmSX8()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SC2 (ordens de produção de PA)                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aAutoSC2 := {}
		AADD(_aAutoSC2, {"AUTEXPLODE", "S"    										, NIL})
		AADD(_aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 				, NIL})
		AADD(_aAutoSC2, {"C2_NUM"    , _cNumOp                        				, NIL})
		AADD(_aAutoSC2, {"C2_ITEM"   , "01"                           				, NIL})
		AADD(_aAutoSC2, {"C2_SEQUEN" , "001"                    					, NIL})
		AADD(_aAutoSC2, {"C2_PRODUTO", _cProduto                      				, NIL})
		AADD(_aAutoSC2, {"C2_LOCAL"  , "01"                           				, NIL})
		AADD(_aAutoSC2, {"C2_CC"     , "1131004"                  					, NIL})	// Sala de Corte I
		AADD(_aAutoSC2, {"C2_QUANT"  , _nPesoTot                  					, NIL})
		AADD(_aAutoSC2, {"C2_DATPRI" , dDatabase                					, NIL})
		AADD(_aAutoSC2, {"C2_DATPRF" , dDatabase                					, NIL})
		AADD(_aAutoSC2, {"C2_EMISSAO", dDatabase                					, NIL})
		AADD(_aAutoSC2, {"C2_STATUS" , "N"                      					, NIL})
		AADD(_aAutoSC2, {"C2_TPOP"   , "F"                      					, NIL})
		AADD(_aAutoSC2, {"C2_GRUPO"  , _cGrupPrd                  					, NIL})
		AADD(_aAutoSC2, {"C2_UM"     , "KG"                       					, NIL})
		AADD(_aAutoSC2, {"C2_SEGUM"  , "PC"                     					, NIL})
		AADD(_aAutoSC2, {"C2_QTSEGUM", _nQtdePcs		              				, NIL})
		AADD(_aAutoSC2, {"C2_NUMAM"  , _cNumam		              					, NIL})
		AADD(_aAutoSC2, {"C2_FLOTE"  , IIF(!Empty(_cNumam),_cLoteCTLP,_cLoteCTLT) 	, NIL})  // Para fins de facilitar rastreio

		// Executa movimentacao de estoque via rotina automatica.
		If Len(_aAutoSC2) > 0
			lMSErroAuto := .F.
			DbSelectArea("SC2")
			Begin Transaction
				MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, 3)
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - OP NUMERO ==> " + _cNumOp + " PARA PA " + AllTrim(_cProduto) + " Aviso de Matanca " + _cNumam)
					MsgAlert("Houve erro na geração da Ordem de Produção de PA na SC2. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
					_FlagIncOP := .F.
				Else
					If _nCont == 1
						cOpIni := _cNumOp
						_nCont := 2
					Else
						cOpFim := _cNumOp
					Endif
					ProcLogAtu("MENSAGEM", "GERADO OP NUMERO ==> " + _cNumOp + " PARA PA " + AllTrim(_cProduto) + " Aviso de Matanca " + _cNumam)
					_FlagIncOP := .T.
				Endif                                       
			End Transaction
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO OP NUMERO ==> " + _cNumOp + " PARA PA " + AllTrim(_cProduto) + " Aviso de Matanca " + _cNumam)
			_FlagIncOP := .F.
		Endif

		TRB->(DbSkip())
	Enddo

	TRB->(DbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa intervalo de OPs geradas em ordem dscrescente   ³
	//³ para que os movimentos de produção sejam gerados pelas   ³
	//³ OPs intermediárias primeiro, senão ocorre erro de saldo  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cOpIni) .And. !Empty(cOpFim)
		cQueryC2 := "SELECT * "
		cQueryC2 += "  FROM " + RetSQLTab("SC2")
		cQueryC2 += " WHERE " + RetSQLFil("SC2")
		cQueryC2 += "   AND C2_NUM BETWEEN '" + cOpIni + "' AND '" + cOpFim + "'"
		cQueryC2 += "   AND " + RetSQLDel("SC2")
		cQueryC2 += " ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN DESC"

		cQueryC2 := ChangeQuery(cQueryC2) 

		ProcLogAtu("MENSAGEM", "OPs geradas em ordem descrescente de: " + cOpIni + " ate " + cOpFim + " " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQueryC2)

		DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQueryC2), "TRBC2", .F., .T.)

		TRBC2->(dbGoTop())
		While TRBC2->(!Eof())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava SD3 (movimentos de produção de PA)                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_aVetor := {}
			AADD(_aVetor, {"D3_OP" 		, TRBC2->(C2_NUM+C2_ITEM+C2_SEQUEN)	,NIL})
			AADD(_aVetor, {"D3_TM" 		, "008"            					,NIL})
			AADD(_aVetor, {"D3_COD" 	, TRBC2->C2_PRODUTO					,NIL})
			AADD(_aVetor, {"D3_UM" 		, "KG"								,NIL})
			AADD(_aVetor, {"D3_QUANT" 	, TRBC2->C2_QUANT					,NIL})
			AADD(_aVetor, {"D3_LOCAL" 	, TRBC2->C2_LOCAL  					,NIL})
			AADD(_aVetor, {"D3_DOC" 	, NextNumero("SD3",2,"D3_DOC",.T.) 	,NIL})
			AADD(_aVetor, {"D3_EMISSAO" , dDatabase 					    ,NIL})
			AADD(_aVetor, {"D3_CC" 		, "1131001" 					    ,NIL})
			AADD(_aVetor, {"D3_SEGUM" 	, "PC"								,NIL})
			AADD(_aVetor, {"D3_QTSEGUM" , TRBC2->C2_QTSEGUM					,NIL})
			AADD(_aVetor, {"D3_FLOTE" 	, TRBC2->C2_FLOTE					,NIL})
			AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())   				,NIL})

			// Executa movimentacao de produção de PA via rotina automatica.
			If Len(_aVetor) > 0
				lMSErroAuto := .F.
				DbSelectArea("SD3")
				Begin Transaction
					MSExecAuto({|x,y| mata250(x,y)}, _aVetor, 3)
					If lMSErroAuto
						ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE PRODUCAO ==> " + TRBC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + " PARA PA " + AllTrim(TRBC2->C2_PRODUTO) + " D3_TM = 008")
						MsgAlert("Houve erro na geração da produção do SD3 de PA ExecAuto MATA250 TM 008. Verifique na tela seguinte.", ProcName())
						MostraErro()
						DisarmTransaction()
						_FlagMovPD := .F.
					Else 
						ProcLogAtu("MENSAGEM", "GERADO SD3 DE PRODUCAO ==> " + TRBC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + " PARA PA " + AllTrim(TRBC2->C2_PRODUTO) + " D3_TM = 008")
						_FlagMovPD := .T.
					Endif                                       
				End Transaction 
			Else
				ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE PRODUCAO ==> " + TRBC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + " PARA PA " + AllTrim(TRBC2->C2_PRODUTO) + " D3_TM = 008")
				_FlagMovPD := .F.
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava SD3 (movimentos de baixa do PA) 		                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_aVetor := {}
			AADD(_aVetor, {"D3_TM" 		, "504"            					,NIL})
			AADD(_aVetor, {"D3_COD" 	, TRBC2->C2_PRODUTO					,NIL})
			AADD(_aVetor, {"D3_UM" 		, "KG"								,NIL})
			AADD(_aVetor, {"D3_QUANT" 	, TRBC2->C2_QUANT					,NIL})
			AADD(_aVetor, {"D3_LOCAL" 	, TRBC2->C2_LOCAL  					,NIL})
			AADD(_aVetor, {"D3_DOC" 	, NextNumero("SD3",2,"D3_DOC",.T.) 	,NIL})
			AADD(_aVetor, {"D3_EMISSAO" , dDatabase 					    ,NIL})
			AADD(_aVetor, {"D3_CC" 		, "1131001" 					    ,NIL})
			AADD(_aVetor, {"D3_SEGUM" 	, "PC"								,NIL})
			AADD(_aVetor, {"D3_QTSEGUM" , TRBC2->C2_QTSEGUM					,NIL})
			AADD(_aVetor, {"D3_FLOTE" 	, TRBC2->C2_FLOTE					,NIL})
			AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())   				,NIL})

			// Executa movimentacao de baixa de PA via rotina automatica.
			If Len(_aVetor) > 0
				lMSErroAuto := .F.
				DbSelectArea("SD3")
				Begin Transaction
					MSExecAuto({|x,y| mata240(x,y)}, _aVetor, 3)
					If lMSErroAuto
						ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE BAIXA ==> " + TRBC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + " PARA PA " + AllTrim(TRBC2->C2_PRODUTO) + " D3_TM = 504")
						MsgAlert("Houve erro na geração da baixa do SD3 de PA ExecAuto MATA250 TM 504. Verifique na tela seguinte.", ProcName())
						MostraErro()
						DisarmTransaction()
						_FlagMovBX := .F.
					Else 
						ProcLogAtu("MENSAGEM", "GERADO SD3 DE BAIXA ==> " + TRBC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + " PARA PA " + AllTrim(TRBC2->C2_PRODUTO) + " D3_TM = 504")
						_FlagMovBX := .T.
					Endif                                       
				End Transaction 
			Else
				ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE BAIXA ==> " + TRBC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + " PARA PA " + AllTrim(TRBC2->C2_PRODUTO) + " D3_TM = 504")
				_FlagMovBX := .F.
			Endif

			TRBC2->(DbSkip())
		Enddo

		TRBC2->(DbCloseArea())
	Else
		MsgAlert("Não foram gerados movimentos de produção e baixas dos PAs. VERIFICAR...!")
	Endif

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

	// Verifica se todos os processos de inclusão das OPs e realização dos movimentos de produção PA e baixa PA
	// foram executados com sucesso e grava o flag de data da fase 3 - carregamento de pendurados (ZAJ_DTEXE3)
	If _FlagIncOP .And. _FlagMovPD .And. _FlagMovBX
		/*
		cQueryUPD := "UPDATE " + RetSQLName("ZAJ")
		cQueryUPD += "   SET ZAJ_DTEXE3 = '" + Dtos(DDATABASE) + "'"
		cQueryUPD += " WHERE ZAJ_FILIAL = '" + xFilial('ZAJ') + "'"
		cQueryUPD += "   AND ZAJ_DATAS = '" + dtos(mv_par01) + "'"
		cQueryUPD += "   AND ZAJ_PRECAR <> ''"
		cQueryUPD += "   AND ZAJ_CODPA <> ''"
		cQueryUPD += "   AND ZAJ_DTEXE1 <> ''"
		cQueryUPD += "   AND ZAJ_DTEXE2 <> ''"
		cQueryUPD += "   AND ZAJ_DTEXE3 = ''"
		cQueryUPD += "   AND D_E_L_E_T_ = ''"

		If TCSQLExec(cQueryUPD) < 0
			ProcLogAtu("ERRO", "ERRO NO UPDATE DE PROCESSAMENTO no CARREGAMENTO PENDURADOS: ", TCSQLError())
			MsgStop("TCSQLError() " + TCSQLError())
		Else
			ProcLogAtu("MENSAGEM", "Geração dados bloco K referente carregamento de pendurados na data de " + Dtoc(mv_par01) + " finalizado com sucesso.")
			MsgAlert("Geração dados bloco K referente carregamento de pendurados na data de " + Dtoc(mv_par01) + " finalizado com sucesso.")
		EndIf
		*/
	Else
		ProcLogAtu("MENSAGEM", "Não houve processamento a ser realizado para data de carregamento de pendurados " + Dtoc(mv_par01) + " ou processamento nesta data já realizado.")
		MsgAlert("Não houve processamento a ser realizado para data de carregamento de pendurados " + Dtoc(mv_par01) + " ou processamento nesta data já realizado.")
	Endif

	ProcLogAtu("FIM","Rotina Chamadora: " + FunName() + " " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()) ,,,.T.)

Return
