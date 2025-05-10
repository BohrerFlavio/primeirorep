#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MGT_BLK7 
@Type			: Função de Usuário
@Sample			: U_MGT_BLK7()
@Description	: Rotina para geração das ordens de produção, apontamentos de produção 
                  e baixa PA de carregamentos de produtos envazados em caixas conforme
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
User Function MGT_BLK7()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| BLK7NewPerg ( oSelf ) }   
	Local cFunction    := "MGT_BLK7"
	Local cTitle	   := "Geração Dados Bloco K Referente Carregamento de Caixas"
	Local cDescription := "Rotina responsável pela geração das ordens de produção e apontamentos da produção e baixa dos PAs referente ao movimentos de carregamento de produtos envazados em caixas conforme data de saída." + ;
						  "Para executar a geração das informações necessárias, informe os parâmetros necessários." + CRLF + CRLF + ; 
						  "Clique no botão abaixo e aguarde a conclusão do processamento."

	Private cPerg	   := "MGT_BLK7"
	//Private cCadastro  := OemToAnsi("Geração Dados Bloco K Referente Carregamento de Caixas")

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
/*/{Protheus.doc} BLK7NewPerg
Tratamento para a utilização do tNewProcess
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK7NewPerg( oSelf )

	BLK7Proc(.F.,oSelf)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BLK7Proc
Função que efetua o processamento das informações
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK7Proc( lBat, oSelf )

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
	cQuery += "   AND B1_SEGUM IN('CX','SC','L ','BB')"
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
	//³ Apura os pedidos de PAs carregadas para baixa 	    	    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery1 := " SELECT ZZ5_NUM,ZZ5_COD,SUM(ZZ5_QRPESO) AS QRPESO "
	cQuery1 += "  FROM " + RetSQLTab("ZZ4") + "," + RetSQLTab("ZZ5") + "," + RetSQLTab("SB1")
	cQuery1 += " WHERE " + RetSQLFil("ZZ4") + " AND " + RetSQLFil("ZZ5") + " AND " + RetSQLFil("SB1")
	cQuery1 += "   AND B1_MSBLQL <> '1'"
	cQuery1 += "   AND B1_TIPO = 'PA' "
	cQuery1 += "   AND B1_SEGUM IN('CX','SC','L ','BB') "  
	cQuery1 += "   AND B1_COD = ZZ5_COD "
	cQuery1 += "   AND ZZ4_NUM = ZZ5_NUM "	
	cQuery1 += "   AND ZZ4_TPOPER IN('V','T','E','R') "
	cQuery1 += "   AND ZZ4_STATUS = 'F' "
	cQuery1 += "   AND ZZ4_DATA = '" + Dtos(mv_par01) + "'"
	cQuery1 += "   AND " + RetSQLDel("ZZ4") + " AND " + RetSQLDel("ZZ5") + " AND " + RetSQLDel("SB1")   
	cQuery1 += " GROUP BY ZZ5_NUM,ZZ5_COD "  
	cQuery1 += " HAVING SUM(ZZ5_QRPESO) <> 0 "
	cQuery1 += " ORDER BY ZZ5_COD "

	cQuery1 := ChangeQuery(cQuery1)

	ProcLogAtu( 'MENSAGEM', "Seleção dos pedidos de PAs carregadas para baixa " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery1)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1), "TRB1", .F., .T.)

	Pergunte(cPerg,.F.)

	//=================================================================================
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Saida de PA pendurados (PAs)								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRB1->(dbGoTop())

	While TRB1->(!Eof())

		oSelf:IncRegua1("Selecionando saída de PA pendurados (PAs) ...")
		oSelf:IncRegua2()

		_cProduto := PADR(TRB1->ZZ5_COD, 15, " ")
		_nPesoTot := TRB1->QRPESO                                                   
		_cNumPed  := fBuscaCPO("ZZ4",2,xFilial("ZZ4") + TRB1->ZZ5_NUM,"ZZ4_NUMPED")
		_cNumDoc  := _cNumPed //NextNumero("SD3",2,"D3_DOC",.T.)

		_aVetor := {}   
		AADD(_aVetor, {"D3_TM     " , "505"      	           	,NIL})        
		AADD(_aVetor, {"D3_DOC    " , _cNumDoc             		,NIL})
		AADD(_aVetor, {"D3_CC     " , "1131001"              	,NIL})
		AADD(_aVetor, {"D3_EMISSAO" , ddatabase              	,NIL})     
		AADD(_aVetor, {"D3_COD    " , _cProduto	           		,NIL})
		AADD(_aVetor, {"D3_UM     " , "KG"			          	,NIL})
		AADD(_aVetor, {"D3_QUANT  " , _nPesoTot	          		,NIL})
		AADD(_aVetor, {"D3_LOCAL  " , "01"                    	,NIL})
		AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName()) 		,NIL})

		// Verifica para criar SB2 caso não exista  
		FailSaldo := .F.
		SB2->(DbSetOrder(1))
		If !SB2->(DbSeek(xFilial("SB2") + _cProduto + "01"))
			CriaSB2(_cProduto, "01")
			MsUnLock()
			FailSaldo := .T.
		ElseIf SB2->B2_QATU < _nPesoTot
			FailSaldo := .T.		
		Endif

		If FailSaldo
			Reclock("SB2",.F.)
			SB2->B2_QATU := _nPesoTot
			Msunlock()        
		Endif

		// Executa entrada de MP via rotina automatica     
		If Len(_aVetor) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y| MATA240(x,y)},_aVetor,3)    // Inclusão
				If lMSErroAuto                            
					ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE SAIDA DE PA ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 505")
					MsgAlert("Houve erro na geração da produção do SD3 ExecAuto MATA240 TM 505. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO SD3 DE SAIDA DE PA ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 505")
				Endif                                       
			End Transaction 
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE SAIDA DE PA ==> " + _cNumDoc + " PARA PRODUTO " + AllTrim(_cProduto) + " D3_TM = 505")
		Endif

		TRB1->(DbSkip())
	Enddo 

	TRB1->(DbCloseArea())

	ProcLogAtu("FIM","Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()) ,,,.T.)

Return
