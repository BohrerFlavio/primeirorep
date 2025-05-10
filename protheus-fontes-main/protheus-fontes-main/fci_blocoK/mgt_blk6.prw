#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MGT_BLK6 
@Type			: Função de Usuário
@Sample			: U_MGT_BLK6()
@Description	: Rotina para geração das ordens de produção, apontamentos de produção 
                  e baixa PA de carregamentos de produtos pendurados no tendal conforme
				  data de saída a ser processada
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Revisão em Jun/2021 considerando situação atual para rodar em Jan/2022
/*/
//--------------------------------------------------------------------------------------
User Function MGT_BLK6()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| BLK6NewPerg ( oSelf ) }   
	Local cFunction    := "MGT_BLK6"
	Local cTitle	   := "Geração Dados Bloco K Referente Carregamento Tendal"
	Local cDescription := "Rotina responsável pela geração das ordens de produção e apontamentos da produção e baixa dos PAs referente ao movimentos de carregamento de peça penduradas no tendal conforme data de saída." + ;
						  "Para executar a geração das informações necessárias, informe os parâmetros necessários." + CRLF + CRLF + ; 
						  "Clique no botão abaixo e aguarde a conclusão do processamento."

	Private cPerg	   := "MGT_BLK6"
	Private _aProdOPs  := {}   // Vetor que armazena as produções a serem realizadas em SD3    

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
/*/{Protheus.doc} BLK6NewPerg
Tratamento para a utilização do tNewProcess
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK6NewPerg( oSelf )

	BLK6Proc(.F.,oSelf)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BLK6Proc
Função que efetua o processamento das informações
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK6Proc( lBat, oSelf )

	Local cIdCV8 := ""

	Pergunte(cPerg,.F.)

	ProcLogIni({},FunName(),,@cIdCV8)
	ProcLogAtu("INICIO","Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()) ,,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula total de registros a serem processados corretamente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT( ZZ5.R_E_C_N_O_ ) TOTREG "
	cQuery += "  FROM " + RetSQLTab("ZZ4") + "," + RetSQLTab("ZZ5") + "," + RetSQLTab("SB1")
	cQuery += " WHERE " + RetSQLFil("ZZ4") + " AND " + RetSQLFil("ZZ5") + " AND " + RetSQLFil("SB1")
	cQuery += "   AND B1_MSBLQL <> '1'"    
	cQuery += "   AND B1_TIPO = 'PA' "   
	cQuery += "   AND B1_SEGUM = 'PC' "	
	cQuery += "   AND ZZ4_NUM = ZZ5_NUM "
	cQuery += "   AND ZZ4_TPOPER IN('V','T','E','R') "
	cQuery += "   AND ZZ4_STATUS = 'F' "
	cQuery += "   AND ZZ4_DATA = '" + Dtos(mv_par01) + "'"
	cQuery += "   AND " + RetSQLDel("ZZ4") + " AND " + RetSQLDel("ZZ5") + " AND " + RetSQLDel("SB1")

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTOT",.T.,.T.)

	oSelf:SetRegua1(TRBTOT->TOTREG)
	oSelf:SetRegua2(TRBTOT->TOTREG)

	TRBTOT->( DbCloseArea() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula total Peças PAS carregadas                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery1 := " SELECT ZZ5_COD, SUM(ZZ5_QRPESO) AS QRPESO "
	cQuery1 += "  FROM " + RetSQLTab("ZZ4") + "," + RetSQLTab("ZZ5") + "," + RetSQLTab("SB1")
	cQuery1 += " WHERE " + RetSQLFil("ZZ4") + " AND " + RetSQLFil("ZZ5") + " AND " + RetSQLFil("SB1")
	cQuery1 += "   AND B1_MSBLQL <> '1'"
	cQuery1 += "   AND B1_TIPO = 'PA' "
	cQuery1 += "   AND B1_SEGUM = 'PC' "  
	cQuery1 += "   AND B1_COD = ZZ5_COD "
	cQuery1 += "   AND ZZ4_NUM = ZZ5_NUM "	
	cQuery1 += "   AND ZZ4_TPOPER IN('V','T','E','R') "
	cQuery1 += "   AND ZZ4_STATUS = 'F' "
	cQuery1 += "   AND ZZ4_DATA = '" + Dtos(mv_par01) + "'"
	cQuery1 += "   AND " + RetSQLDel("ZZ4") + " AND " + RetSQLDel("ZZ5") + " AND " + RetSQLDel("SB1")   
	cQuery1 += " GROUP BY ZZ5_COD "

	cQuery1 := ChangeQuery(cQuery1)

	ProcLogAtu( 'MENSAGEM', "Seleção de total peças PAS carregadas " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery1)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1), "TRB1", .F., .T.)

	TRB1->(DbGoTop())


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apura os pedidos de Peças PAS carregadas para baixa         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery2 := " SELECT ZZ5_NUM,ZZ5_COD,SUM(ZZ5_QRPESO) AS QRPESO "
	cQuery2 += "  FROM " + RetSQLTab("ZZ4") + "," + RetSQLTab("ZZ5") + "," + RetSQLTab("SB1")
	cQuery2 += " WHERE " + RetSQLFil("ZZ4") + " AND " + RetSQLFil("ZZ5") + " AND " + RetSQLFil("SB1")
	cQuery2 += "   AND B1_MSBLQL <> '1'"
	cQuery2 += "   AND B1_TIPO = 'PA' "
	cQuery2 += "   AND B1_SEGUM = 'PC' "  
	cQuery2 += "   AND B1_COD = ZZ5_COD "
	cQuery2 += "   AND ZZ4_NUM = ZZ5_NUM "	
	cQuery2 += "   AND ZZ4_TPOPER IN('V','T','E','R') "
	cQuery2 += "   AND ZZ4_STATUS = 'F' "
	cQuery2 += "   AND ZZ4_DATA = '" + Dtos(mv_par01) + "'"
	cQuery2 += "   AND " + RetSQLDel("ZZ4") + " AND " + RetSQLDel("ZZ5") + " AND " + RetSQLDel("SB1")   
	cQuery2 += " GROUP BY ZZ5_NUM,ZZ5_COD "

	cQuery2 := ChangeQuery(cQuery2)

	ProcLogAtu( 'MENSAGEM', "Seleção que apura os pedidos de peças PAS carregadas para baixa " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery2)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery2), "TRB2", .F., .T.)

	TRB2->(DbGoTop())


	//=================================================================================
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fase 1 - Processamento dos Dados Carreg. pendurados (PAs)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRB1->(dbGoTop())
	While TRB1->(!Eof())

		oSelf:IncRegua1("Fase 1 - Selecionando dados carreg. pendurados (PAs) ...")
		oSelf:IncRegua2()

		Pergunte(cPerg,.F.)

		_cProduto := TRB1->ZZ5_COD
		_nPesoTot := TRB1->QRPESO
		_cDescPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
		_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
		_cGrupPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_GRUPO") 
		_cNumOp   := GETSX8NUM("SC2","C2_NUM")
		ConfirmSX8()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SC2 (ordens de produção de PA)                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aAutoSC2 := {}
		AADD (_aAutoSC2, {"AUTEXPLODE", "S"    							, NIL})
		AADD (_aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 	, NIL})
		AADD (_aAutoSC2, {"C2_NUM"    , _cNumOp                        	, NIL})
		AADD (_aAutoSC2, {"C2_ITEM"   , "01"                           	, NIL})
		AADD (_aAutoSC2, {"C2_SEQUEN" , "001"                    		, NIL})
		AADD (_aAutoSC2, {"C2_PRODUTO", _cProduto                      	, NIL})
		AADD (_aAutoSC2, {"C2_LOCAL"  , "01"                           	, NIL})
		AADD (_aAutoSC2, {"C2_CC"     , "1131005"                  		, NIL})	// Desossa
		AADD (_aAutoSC2, {"C2_QUANT"  , _nPesoTot                  		, NIL})
		AADD (_aAutoSC2, {"C2_DATPRI" , dDatabase                		, NIL})
		AADD (_aAutoSC2, {"C2_DATPRF" , dDatabase                		, NIL})
		AADD (_aAutoSC2, {"C2_EMISSAO", dDatabase                		, NIL})
		AADD (_aAutoSC2, {"C2_STATUS" , "N"                      		, NIL})
		AADD (_aAutoSC2, {"C2_TPOP"   , "F"                      		, NIL})
		AADD (_aAutoSC2, {"C2_GRUPO"  , _cGrupPrd                  		, NIL})
		AADD (_aAutoSC2, {"C2_UM"     , "KG"                       		, NIL})
		AADD (_aAutoSC2, {"C2_FLOTE"  , "P DEFINIR" + Dtos(mv_par01) 	, NIL})  // Para fins de facilitar rastreio

		// Executa movimentacao de estoque via rotina automatica.   
		If Len(_aAutoSC2) > 0 
			lMSErroAuto := .F.
			DbSelectArea("SC2")      
			Begin Transaction
				MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, 3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - OP NUMERO ==> " + _cNumOp + " PARA PA " + AllTrim(_cProduto))
					MsgAlert("Houve erro na geração da Ordem de Produção de PA na SC2. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO OP NUMERO ==> " + _cNumOp + " PARA PA " + AllTrim(_cProduto))
					aadd(_aProdOPs,{_cNumOp + "01001   ","009",_cProduto,_nPesoTot})    
				Endif                                       
			End Transaction
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO OP NUMERO ==> " + _cNumOp + " PARA PA " + AllTrim(_cProduto))
		Endif

		TRB1->(DbSkip())
	Enddo

	ProdSD3()

	Pergunte(cPerg,.F.)

	//=================================================================================
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fase 2 - Saida de PA pendurados (PAs)					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRB2->(dbGoTop())

	While TRB2->(!Eof())

		oSelf:IncRegua1("Fase 2 - Selecionando saída de PA pendurados (PAs) ...")
		oSelf:IncRegua2()

		_cProduto := TRB2->ZZ5_COD
		_nPesoTot := TRB2->QRPESO
		_cNumDoc  := fBuscaCPO("ZZ4",2,xFilial("ZZ4") + TRB2->ZZ5_NUM,"ZZ4_NUMPED")   //NextNumero("SD3",2,"D3_DOC",.T.)
		_aVetor   := {}   

		AADD(_aVetor, {"D3_TM"      , "504"      	           	, NIL})        
		AADD(_aVetor, {"D3_DOC"     , _cNumDoc             		, NIL})
		AADD(_aVetor, {"D3_CC"      , "1131001"              	, NIL})
		AADD(_aVetor, {"D3_EMISSAO" , ddatabase              	, NIL})     
		AADD(_aVetor, {"D3_COD"     , _cProduto	           		, NIL})
		AADD(_aVetor, {"D3_UM"      , "KG"			          	, NIL})
		AADD(_aVetor, {"D3_QUANT"   , _nPesoTot	          		, NIL})
		AADD(_aVetor, {"D3_LOCAL"   , "01"                    	, NIL})
		AADD(_aVetor, {"D3_FLOTE" 	, "DEFINIR"					, NIL})
		AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName()) 		, NIL})

		// Executa entrada de MP via rotina automatica     
		If Len(_aVetor) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y| MATA240(x,y)},_aVetor,3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE SAIDA DE PA ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 504")
					MsgAlert("Houve erro na geração da produção do SD3 ExecAuto MATA240 TM 504. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
					_FlagIncMP := .F.
				Else 
					ProcLogAtu("MENSAGEM", "GERADO SD3 DE SAIDA DE PA ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 504")
				Endif                                       
			End Transaction 
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE SAIDA DE PA ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 504")
		Endif

		TRB2->(DbSkip())
	Enddo 

	TRB1->(DbCloseArea())
	TRB2->(DbCloseArea())

	ProcLogAtu("FIM","Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()) ,,,.T.)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProdSD3
Grava SD3 (movimentos de produção)
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function ProdSD3()

	Local i

	Pergunte(cPerg,.F.)	

	For i := 1 To Len(_aProdOPs)
		_aVetor := {}
		AADD(_aVetor, {"D3_OP"      , _aProdOPs[i,1]        		  		, NIL})
		AADD(_aVetor, {"D3_TM"      , _aProdOPs[i,2]    					, NIL})
		AADD(_aVetor, {"D3_EMISSAO" , dDatabase 					    	, NIL})
		AADD(_aVetor, {"D3_COD"     , _aProdOPs[i,3]						, NIL})
		AADD(_aVetor, {"D3_UM"      , "KG"									, NIL})
		AADD(_aVetor, {"D3_QUANT"   , _aProdOPs[i,4]						, NIL})
		AADD(_aVetor, {"D3_DOC"     , NextNumero("SD3",2,"D3_DOC",.T.) 		, NIL})
		AADD(_aVetor, {"D3_LOCAL"   , "01"           						, NIL})
		AADD(_aVetor, {"D3_FLOTE" 	, "DEFINIR2"							, NIL})
		AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName()) 					, NIL})

		// Executa movimentacao de produção de PP via rotina automatica.
		If Len(_aVetor) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y| mata250(x,y)}, _aVetor, 3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE PRODUCAO OP ==> " + _aProdOPs[i,1] + " PARA PRODUTO " + AllTrim(_aProdOPs[i,3]) + " D3_TM = " + _aProdOPs[i,2])
					MsgAlert("Houve erro na geração da produção do SD3 de PP. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO SD3 DE PRODUCAO OP ==> " + _aProdOPs[i,1] + " PARA PRODUTO " + AllTrim(_aProdOPs[i,3]) + " D3_TM = " + _aProdOPs[i,2])
				Endif                                       
			End Transaction 
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE PRODUCAO OP ==> " + _aProdOPs[i,1] + " PARA PRODUTO " + AllTrim(_aProdOPs[i,3]) + " D3_TM = " + _aProdOPs[i,2])
		Endif
	Next

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

Return
