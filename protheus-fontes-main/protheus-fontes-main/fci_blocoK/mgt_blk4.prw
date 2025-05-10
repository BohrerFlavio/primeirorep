#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MGT_BLK4 
@Type			: Função de Usuário
@Sample			: U_MGT_BLK4()
@Description	: Rotina para geração das ordens de produção e apontamentos da produção
                  referente aos movimentos de miudos e despojos relativos ao número do 
				  aviso de matança
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Revisão em Jun/2021 considerando situação atual para rodar em Jan/2022
/*/
//--------------------------------------------------------------------------------------
User Function MGT_BLK4()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| BLK4NewPerg ( oSelf ) }   
	Local cFunction    := "MGT_BLK4"
	Local cTitle	   := "Geração Dados Bloco K Referente PA Miudezas"
	Local cDescription := "Rotina responsável pela geração das ordens de produção, apontamentos da produção referente a produção de miudezas conforme número do aviso de matança." + ;
	                      "Para executar a geração das informações necessárias, informe os parâmetros necessários." + CRLF + CRLF +;
						  "Clique no botão abaixo e aguarde a conclusão do processamento."

	Private cPerg	   := "MGT_BLK4"
	Private nEstru 	   := 0		// Variavel PRIVATE obrigatória para o uso da função ESTRUT2

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
/*/{Protheus.doc} BLK4NewPerg
Tratamento para a utilização do tNewProcess
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK4NewPerg( oSelf )

	BLK4Proc(.F.,oSelf)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BLK4Proc
Função que efetua o processamento das informações
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK4Proc( lBat, oSelf )

	Local cIdCV8 	 := ""
	Local x
	Local cNomeArq   := ''
	Local oTempTable := NIL

	lMSErroAuto := .T.

	// Valida data de processamento com data base do sistema
	If mv_par01 <> dDataBase
		Aviso("PROCESSAMENTO BLOCO K - PROCESSO REFERENTE PA MIUDEZAS", "Data do processamento DIFERENTE da data base do sistema." + CRLF + CRLF + ;
			  "Processamento não será executado. Favor ajustar datas!",{"Ok"},2)
		Return
	Endif

	ProcLogIni({},FunName(),,@cIdCV8)
	ProcLogAtu("INICIO","Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()) ,,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula total de registros a serem processados corretamente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT( SZ8.R_E_C_N_O_ ) TOTREG "
	cQuery += "  FROM " + RetSQLTab("SZ8") + "," + RetSQLTab("SB1")+ "," + RetSQLTab("SG1") + ", " + RetSqlTab("SZ2")
	cQuery += " WHERE Z8_FILORI = '" + cFilAnt + "' AND " + RetSQLFil("SB1") + " AND " + RetSQLFil("SG1") + " AND " + RetSQLFil("SZ2")"
	cQuery += "   AND B1_GRUPO = '3000'" 
	cQuery += "   AND Z2_DATAABT = '" + Dtos(mv_par01) + "'"
	cQuery += "   AND Z2_NUM = Z8_PREDES "
	cQuery += "   AND B1_MSBLQL = '2'"
	cQuery += "   AND B1_COD = G1_COMP "
	cQuery += "   AND G1_COD = Z8_CODORI "
	cQuery += "   AND " + RetSQLDel("SZ8") + " AND " + RetSQLDel("SB1") + " AND " + RetSQLDel("SG1") + " AND " + RetSQLDel("SZ2")
	cQuery += " GROUP BY Z8_CODORI "
	cQuery += " ORDER BY Z8_CODORI "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTOT",.T.,.T.)

	oSelf:SetRegua1(TRBTOT->TOTREG)
	oSelf:SetRegua2(TRBTOT->TOTREG)

	TRBTOT->( DbCloseArea() )

	// Executa somente para produtos do grupo 3000
	cQueryB1 := "SELECT * "
	cQueryB1 += "  FROM " + RetSQLTab("SB1")
	cQueryB1 += " WHERE " + RetSQLFil("SB1")
	cQueryB1 += "   AND B1_GRUPO = '3000'"
	cQueryB1 += "   AND B1_MSBLQL = '2'"
	cQueryB1 += "   AND " + RetSQLDel("SB1")

	cQueryB1 := ChangeQuery(cQueryB1)

	ProcLogAtu( 'MENSAGEM', "Seleção somente para produtos do grupo 3000 " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQueryB1)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryB1), "TRB1", .F., .T.)

	TRB1->(dbGoTop())
	While TRB1->(!Eof())
		_cCodB1 := TRB1->B1_COD

		Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

		cQuery1 := "SELECT Z8_CODORI AS COD,COUNT(Z8_CONTROL) AS QTDEPROD, SUM(Z8_PESO) AS PESOTOT "
		cQuery1 += "  FROM " + RetSQLTab("SZ8") + "," + RetSQLTab("SG1")+ "," + RetSQLTab("SZ2")
		cQuery1 += " WHERE Z8_FILORI = '" + cFilAnt + "' AND " + RetSQLFil("SG1") + " AND " + RetSQLFil("SZ2")
		cQuery1 += "   AND Z2_DATAABT = '" + dtos(mv_par01) + "'"
		cQuery1 += "   AND Z2_NUM = Z8_PREDES "
		cQuery1 += "   AND G1_COD = Z8_CODORI "
		cQuery1 += "   AND G1_COMP = '" + _cCodB1 + "'"
		cQuery1 += "   AND " + RetSQLDel("SZ8") + " AND " + RetSQLDel("SG1") + " AND " + RetSQLDel("SZ2")
		cQuery1 += " GROUP BY Z8_CODORI "
		cQuery1 += " ORDER BY Z8_CODORI "

		cQuery1 := ChangeQuery(cQuery1)

		ProcLogAtu( 'MENSAGEM', "Seleção pesagem PA (SZ8) para Data Abate: " + Dtoc(mv_par01) + " Componente: " + _cCodB1 + " " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery1)

		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1), "TRB", .F., .T.)

		_aDadosD3 := {}

		TRB->(dbGoTop())
		While TRB->(!Eof())

			oSelf:IncRegua1("Selecionando registros para Ops e produção ...")
			oSelf:IncRegua2()

			Pergunte(cPerg,.F.)
			_cProduto := TRB->COD
			_cDescPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
			_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")        
			_cGrupo   := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_GRUPO")        
			_nQtdSeg  := TRB->QTDEPROD
			_nPesoTot := TRB->PESOTOT
			_cLoteCTL := "P" + mv_par02 + Dtos(mv_par01)
			_dDataProd:= mv_par01
			_cNumOp   := GetSX8Num("SC2","C2_NUM")
			ConfirmSX8() 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava SC2 (ordens de produção)                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_aAutoSC2 := {}
			AADD(_aAutoSC2, {"AUTEXPLODE", "S"    							, NIL})
			AADD(_aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 	, NIL})
			AADD(_aAutoSC2, {"C2_NUM"    , _cNumOp                        	, NIL})
			AADD(_aAutoSC2, {"C2_ITEM"   , "01"                           	, NIL})
			AADD(_aAutoSC2, {"C2_SEQUEN" , "001"                    		, NIL})
			AADD(_aAutoSC2, {"C2_PRODUTO", _cProduto                      	, NIL})
			AADD(_aAutoSC2, {"C2_LOCAL"  , "01"                           	, NIL})
			AADD(_aAutoSC2, {"C2_CC"     , "1131002"                  		, NIL})	// Abate
			AADD(_aAutoSC2, {"C2_QUANT"  , _nPesoTot                  		, NIL})
			AADD(_aAutoSC2, {"C2_DATPRI" , dDatabase                		, NIL})
			AADD(_aAutoSC2, {"C2_DATPRF" , dDatabase                		, NIL})
			AADD(_aAutoSC2, {"C2_EMISSAO", dDatabase                		, NIL})
			AADD(_aAutoSC2, {"C2_STATUS" , "N"                      		, NIL})
			AADD(_aAutoSC2, {"C2_TPOP"   , "F"                      		, NIL})
			AADD(_aAutoSC2, {"C2_GRUPO"  , _cGrupo                   		, NIL})
			AADD(_aAutoSC2, {"C2_UM"     , "KG"                       		, NIL})
			AADD(_aAutoSC2, {"C2_SEGUM"  , "CX"                     		, NIL})
			AADD(_aAutoSC2, {"C2_QTSEGUM", _nQtdSeg                  		, NIL})
			AADD(_aAutoSC2, {"C2_NUMAM"  , mv_par02                   		, NIL})
			AADD(_aAutoSC2, {"C2_FLOTE"  , _cLoteCTL 						, NIL})  // Para fins de facilitar rastreio

			// Executa geração de OP via rotina automatica 
			If Len(_aAutoSC2) > 0
				lMSErroAuto := .F.
				DbSelectArea("SC2")
				Begin Transaction
					MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, 3)    // Inclusão
					If lMSErroAuto
						ProcLogAtu("ERRO", "ERRO GERACAO - OP NUMERO ==> " + _cNumOp + " PARA PRODUTO " + AllTrim(_cProduto) + " Aviso de Matanca " + _cLoteCTL)
						MsgAlert("Houve erro na geração da Ordem de Produção na SC2. Verifique na tela seguinte.", ProcName())
						MostraErro()
						DisarmTransaction()
						_FlagIncOP := .F.
					Else                                                 
						ProcLogAtu("MENSAGEM", "GERADO OP NUMERO ==> " + _cNumOp + " PARA PRODUTO " + AllTrim(_cProduto) + " Aviso de Matanca " + _cLoteCTL)
						_FlagIncOP := .T.
					Endif
				End Transaction
			Else
				ProcLogAtu("MENSAGEM", "NAO FOI GERADO OP NUMERO ==> " + _cNumOp + " PARA PRODUTO " + AllTrim(_cProduto) + " Aviso de Matanca " + _cLoteCTL)
				_FlagIncOP := .F.
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Array com Dados para lançar movimentos de produção   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD( _aDadosD3 , {_cNumOp + "01001", _cProduto , _nPesoTot, _nQtdSeg, _cLoteCTL})

			TRB->(DbSkip())
		Enddo

		For x:=1 To Len(_aDadosD3)
			If x == Len(_aDadosD3)		// Faz o processamento de ajustes no último array para não gerar erros na rotina automática ref. arredondamentos
				// Início da rotina que faz a explossão de uma estrutura cadastrada no SG1
				cNomeArq 	 := Estrut2(PADR(_aDadosD3[x,2], 15, " "),,,@oTempTable)
				_cComponente := Space(15)

				DbSelectArea('ESTRUT')
				ESTRUT->(DbGotop())
				Do While !ESTRUT->(Eof())
					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1") + ESTRUT->COMP)
					If Found()
						If SB1->B1_TIPO <> "SP"
							DbSelectArea('ESTRUT')
							DbSkip()
							Loop
						Else
							_cComponente := SB1->B1_COD
							Exit
						Endif
					Endif	
					ESTRUT->(DbSkip())
				EndDo

				// Final da rotina que faz a explossão de uma estrutura cadastrada no SG1
				// EFETUA O FECHAMENTO DA TABELA
				FimEstrut2(Nil,oTempTable)
				nEstru := 0


				MsgAlert("PASSEI Produto: " + PADR(_aDadosD3[x,2], 15, " ") )

				DbSelectArea("SB2")
				_nSldFimB2 := fBuscaCPO("SB2", 1, xFilial("SB2") + _cComponente + "01", "B2_QATU")

				// Deleta SD4 da OP posicionada somente para D4_TRT igual a 002 pois gerou devido a arredondamentos internos do sistema
				DbSelectArea("SD4")
				DbSetOrder(1)
				DbSeek(xFilial("SD4") + _cComponente + _aDadosD3[x,1] + "002")
				If Found()
					Reclock("SD4",.F.)
					DbDelete()
					MsUnlock()
				Endif

				// Ajusta empenho com o conteúdo da quantidade atual devido a exclusão feita anteriormente
				DbSelectArea("SB2")
				DbSeek(xFilial("SB2") + _cComponente + "01")
				If Found()
					RecLock("SB2",.F.)
					SB2->B2_QEMP := SB2->B2_QATU 
					MsUnlock()
				Endif

				// Ajusta quantidade da OP conforme valor armazenado anteriormente da SB2
				DbSelectArea("SC2")
				DbSetOrder(1)
				DbSeek(xFilial("SC2") + _aDadosD3[x,1])
				If Found()
					Reclock("SC2",.F.)
					SC2->C2_QUANT := _nSldFimB2
					MsUnlock()
				Endif

				// Ajusta quantidade original e quantidade dos empenhos conforme valor armazenado anteriormente da SB2
				DbSelectArea("SD4")
				DbSetOrder(1) 
				DbGoTop()
				DbSeek(xFilial("SD4") + _cComponente + _aDadosD3[x,1])
				If Found()      
					Reclock("SD4",.F.)
					SD4->D4_QTDEORI := _nSldFimB2
					SD4->D4_QUANT   := _nSldFimB2
					MsUnlock()
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava SD3 (movimentos de produção)                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SD3")
				_aVetor := {}

				AADD(_aVetor, {"D3_OP" 		, _aDadosD3[x,1]					,NIL})
				AADD(_aVetor, {"D3_TM" 		, "004"            					,NIL})
				AADD(_aVetor, {"D3_EMISSAO" , dDatabase 					    ,NIL})
				AADD(_aVetor, {"D3_COD" 	, PADR(_aDadosD3[x,2], 15, " ")		,NIL})
				AADD(_aVetor, {"D3_UM" 		, "KG"								,NIL})
				AADD(_aVetor, {"D3_QUANT" 	, _nSldFimB2           		    	,NIL})
				AADD(_aVetor, {"D3_SEGUM" 	, "CX"								,NIL})
				AADD(_aVetor, {"D3_QTSEGUM" , _aDadosD3[x,4]   					,NIL})
				AADD(_aVetor, {"D3_DOC" 	, NextNumero("SD3",2,"D3_DOC",.T.) 	,NIL})
				AADD(_aVetor, {"D3_LOCAL" 	, "01"           					,NIL})
				AADD(_aVetor, {"D3_FLOTE" 	, _aDadosD3[x,5]					,NIL})
				AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())   				,NIL})

				// Executa movimentacao de produção via rotina automatica
				If Len(_aVetor) > 0
					lMSErroAuto := .F.
					DbSelectArea("SD3")
					Begin Transaction
						MSExecAuto({|x,y| mata250(x,y)}, _aVetor, 3)    // Inclusão
						If lMSErroAuto
							ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE PRODUCAO ==> " + _cNumOp + "01001 PARA PRODUTO " + AllTrim(PADR(_aDadosD3[x,2], 15, " ")) + " D3_TM = 004")
							MsgAlert("Houve erro na geração da produção do SD3 ExecAuto MATA250 TM 004 Último Array. Verifique na tela seguinte.", ProcName())
							MostraErro()
							DisarmTransaction()
							_FlagMovPD := .F.
						Else
							ProcLogAtu("MENSAGEM", "GERADO SD3 DE PRODUCAO ==> " + _cNumOp + "01001 PARA PRODUTO " + AllTrim(PADR(_aDadosD3[x,2], 15, " ")) + " D3_TM = 004")
							_FlagMovPD := .T.
						Endif
					End Transaction
				Else
					ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE PRODUCAO ==> " + _cNumOp + "01001 PARA PRODUTO " + AllTrim(PADR(_aDadosD3[x,2], 15, " ")) + " D3_TM = 004")
					_FlagMovPD := .F.
				Endif

			Else	// Faz o processamento normal de movimento de produção

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava SD3 (movimentos de produção)                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SD3")
				_aVetor := {}
				AADD(_aVetor, {"D3_OP     " , _aDadosD3[x,1]					,NIL})
				AADD(_aVetor, {"D3_TM     " , "004"            					,NIL})
				AADD(_aVetor, {"D3_EMISSAO" , dDatabase 					    ,NIL})
				AADD(_aVetor, {"D3_COD    " , _aDadosD3[x,2]					,NIL})
				AADD(_aVetor, {"D3_UM     " , "KG"								,NIL})
				AADD(_aVetor, {"D3_QUANT  " , _aDadosD3[x,3]					,NIL})
				AADD(_aVetor, {"D3_SEGUM  " , "CX"								,NIL})
				AADD(_aVetor, {"D3_QTSEGUM" , _aDadosD3[x,4]   					,NIL})
				AADD(_aVetor, {"D3_DOC    " , NextNumero("SD3",2,"D3_DOC",.T.) 	,NIL})
				AADD(_aVetor, {"D3_LOCAL  " , "01"           					,NIL})
				AADD(_aVetor, {"D3_FLOTE" 	, _aDadosD3[x,5]					,NIL})
				AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())   				,NIL})

				// Executa movimentacao de produção via rotina automatica
				If Len(_aVetor) > 0
					lMSErroAuto := .F.
					DbSelectArea("SD3")
					Begin Transaction
						MSExecAuto({|x,y| mata250(x,y)}, _aVetor, 3)    // Inclusão
						If lMSErroAuto
							ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE PRODUCAO ==> " + _cNumOp + "01001 PARA PRODUTO " + AllTrim(_aDadosD3[x,2]) + " D3_TM = 004")
							MsgAlert("Houve erro na geração da produção do SD3 ExecAuto MATA250 TM 004. Verifique na tela seguinte.", ProcName())
							MostraErro()
							DisarmTransaction()
							_FlagMovPD := .F.
						Else
							ProcLogAtu("MENSAGEM", "GERADO SD3 DE PRODUCAO ==> " + _cNumOp + "01001 PARA PRODUTO " + AllTrim(_aDadosD3[x,2]) + " D3_TM = 004")
							_FlagMovPD := .T.
						Endif
					End Transaction
				Else
					ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE PRODUCAO ==> " + _cNumOp + "01001 PARA PRODUTO " + AllTrim(_aDadosD3[x,2]) + " D3_TM = 004")
					_FlagMovPD := .F.
				Endif

			Endif

		Next

		TRB->(DbCloseArea())

		TRB1->(DbSkip())
	Enddo

	TRB1->(DbCloseArea())

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

	ProcLogAtu("FIM","Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()) ,,,.T.)

Return
