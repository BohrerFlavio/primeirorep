#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"

Static _lConfMrkBr 	:= .F.

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MGT_BLK5 
@Type			: Função de Usuário
@Sample			: U_MGT_BLK5()
@Description	: Rotina para geração das ordens de produção, apontamentos de produção 
                  e baixa PA ref. aos movimentos da desossa conforme data de saída a ser
				  processada
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Revisão em Jun/2021 considerando situação atual para rodar em Jan/2022
/*/
//--------------------------------------------------------------------------------------
User Function MGT_BLK5()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| BLK5NewPerg ( oSelf ) }   
	Local cFunction    := "MGT_BLK5"
	Local cTitle	   := "Geração Dados Bloco K Referente Movimentos da Desossa"
	Local cDescription := "Rotina responsável pela geração das ordens de produção, apontamentos da produção e baixa dos PAs referente ao movimentos da desossa conforme data de saída e grupos de produtos que contém '5111','5112','5113','5121','5122','5123','5211','5213','5221','5223','5134','5135','5136'." + ;
	                      "Para executar a geração das informações necessárias, informe os parâmetros necessários." + CRLF + CRLF +;
						  "Clique no botão abaixo e aguarde a conclusão do processamento."

	Private cPerg		:= "MGT_BLK5"
	Private _nTotProd   := 0
	Private _lNumOPAtu  := .T.   	// Variável a ser utilizada no ponto de entrada MTGRVEMP
	Private _nTotalProd := 0    	// Total produzido na entrada da desossa
	Private _nPercTras  := 0    	// % de traseiro consumido na entrada da desossa
	Private _nPercDian  := 0    	// % de dianteiro consumido na entrada da desossa
	Private _nPercCost  := 0    	// % de costela consumido na entrada da desossa
	Private _aProdOPs   := {}   	// Vetor que armazena as produções a serem realizadas em SD3
	Private _aProdTot   := {}
	Private _aProdOP1   := {}
	Private _aProdOP2   := {}
	Private _aProdOP3   := {}
	Private _aProdOP4   := {}
	Private _nTProduz   := 0    	// Total produzido pelas OPs de PPs e PAs sem o despojo
	Private _cMemo      := ""

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
/*/{Protheus.doc} BLK5NewPerg
Tratamento para a utilização do tNewProcess
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK5NewPerg( oSelf )

	BLK5Proc(.F.,oSelf)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BLK5Proc
Função que efetua o processamento das informações
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK5Proc( lBat, oSelf )

	Local cIdCV8 := ""
	Local x
	Local j
	Local _sOps := '' //20220114
	Private lInverte := .F.
	Private cMark    := GetMark()
	Private oMark

	Pergunte(cPerg,.F.)

	ProcLogIni({},FunName(),,@cIdCV8)
	ProcLogAtu("INICIO","Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()) ,,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula total de registros a serem processados corretamente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT( SZ8.R_E_C_N_O_ ) TOTREG "
	cQuery += "  FROM " + RetSQLTab("SG1") + "," + RetSQLTab("SZ8") + "," + RetSQLTab("SB1")
	cQuery += " WHERE " + RetSQLFil("SG1") + " AND Z8_FILORI = '" + cFilAnt + "'" + " AND " + RetSQLFil("SB1")
	cQuery += "   AND B1_MSBLQL <> '1'"
	cQuery += "   AND B1_GRUPO IN ('5111','5112','5113','5121','5122','5123','5211','5213','5221','5223','5134','5135','5136') "
	cQuery += "   AND B1_COD = Z8_CODORI
	cQuery += "   AND B1_COD = G1_COD
	cQuery += "   AND G1_COMP IN (SELECT B1_COD "
	cQuery += "                     FROM " + RetSQLTab("SB1")
	cQuery += "                    WHERE " + RetSQLFil("SB1")
	cQuery += "                      AND B1_TIPO = 'PP'"
	cQuery += "                      AND B1_MSBLQL <> '1'"
	cquery += "                      AND " + RetSQLDel("SB1") + ")"
	cQuery += "   AND Z8_DATA = '" + Dtos(mv_par01) + "'"
	cQuery += "   AND " + RetSQLDel("SG1") + " AND " + RetSQLDel("SZ8") + " AND " + RetSQLDel("SB1")

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTOT",.T.,.T.)

	oSelf:SetRegua1(TRBTOT->TOTREG)
	oSelf:SetRegua2(TRBTOT->TOTREG)

	TRBTOT->( DbCloseArea() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula total Peças (Diant, Tras, Cost) consumidos na desossa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery0 := "SELECT CORORI, SUM(PESOTOT) PESOTOT FROM "
	cQuery0 += "(SELECT ZAJ_CORORI AS CORORI, SUM(ZAJ_PESO) AS PESOTOT "
	cQuery0 += "  FROM " + RetSQLTab("ZAJ")
	cQuery0 += " WHERE " + RetSQLFil("ZAJ")
	cQuery0 += "   AND ZAJ_DATAS = '" + Dtos(mv_par01) + "'"
	cQuery0 += "   AND ZAJ_DEST IN('D','C') "
	cQuery0 += "   AND " + RetSQLDel("ZAJ")
	cQuery0 += " GROUP BY ZAJ_CORORI "
	cQuery0 += " UNION ALL "
	cQuery0 += "SELECT B1_CORORI AS CORORI, SUM(ZN_PESOL) AS PESOTOT "
	cQuery0 += "  FROM " + RetSQLTab("SZN") + "," + RetSQLTab("SB1")
	cQuery0 += " WHERE " + RetSQLFil("SZN") + " AND " + RetSQLFil("SB1")
	cQuery0 += "   AND ZN_COD = B1_COD"
	cQuery0 += "   AND B1_SEGUM = 'PC'"
	cQuery0 += "   AND ZN_DESTINO IN ('R','P')"
	cQuery0 += "   AND ZN_CODDEST <> ' '"
	cQuery0 += "   AND ZN_DTSAIDA = '" + Dtos(mv_par01) + "'"
	cQuery0 += "   AND " + RetSQLDel("SZN") + " AND " + RetSQLDel("SB1")
	cQuery0 += " GROUP BY B1_CORORI) AS TOTAL "
	cQuery0 += " GROUP BY CORORI "

	cQuery0 := ChangeQuery(cQuery0)

	ProcLogAtu( 'MENSAGEM', "Seleção que calcula total peças (Diant, Tras, Cost) consumidos na desossa " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery0)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery0), "TRB0", .F., .T.)

	TRB0->(DbGotop())
	While TRB0->(!Eof())
		_nTotalProd += TRB0->PESOTOT
		TRB0->(DbSkip())
	Enddo

	TRB0->(DbGoTop())
	While TRB0->(!Eof())
		DO CASE
		CASE TRB0->CORORI = "T"
			_nPercTras := TRB0->PESOTOT / _nTotalProd
		CASE TRB0->CORORI = "D"
			_nPercDian := TRB0->PESOTOT / _nTotalProd
		CASE TRB0->CORORI = "C"
			_nPercCost := TRB0->PESOTOT / _nTotalProd
		ENDCASE
		TRB0->(DbSkip())
	Enddo

	_cMemo := "ENTRADA DA DESOSSA  :" + chr(13) + chr(10)
	_cMemo += Replicate('-',65) + chr(13) + chr(10)
	_cMemo += "Total Consumido (Kg):" + Transform(_nTotalProd,"@E 999,999.999999") + chr(13) + chr(10)
	_cMemo += "% de Traseiro       :" + Transform(_nPercTras * 100,"@E 999.999") + chr(13) + chr(10)
	_cMemo += "% de Dianteiro      :" + Transform(_nPercDian * 100,"@E 999.999") + chr(13) + chr(10)
	_cMemo += "% de Costela        :" + Transform(_nPercCost * 100,"@E 999.999") + chr(13) + chr(10)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção dos movimentos da desossa  - produção dos PPs (SZ8) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery1 := "SELECT G1_COMP, SUM(Z8_PESO) AS PESOTOT "
	cQuery1 += "  FROM " + RetSQLTab("SG1") + "," + RetSQLTab("SZ8") + "," + RetSQLTab("SB1")
	cQuery1 += " WHERE " + RetSQLFil("SG1") + " AND Z8_FILORI = '" + cFilAnt + "'" + " AND " + RetSQLFil("SB1")
	cQuery1 += "   AND B1_MSBLQL <> '1'"
	cQuery1 += "   AND B1_GRUPO IN ('5111','5112','5113','5121','5122','5123','5211','5213','5221','5223','5134','5135','5136') "
	cQuery1 += "   AND B1_COD = Z8_CODORI "
	cQuery1 += "   AND B1_COD = G1_COD   "
	cQuery1 += "   AND G1_COMP IN (SELECT B1_COD "
	cQuery1 += "                     FROM " + RetSQLTab("SB1")
	cQuery1 += "                    WHERE " + RetSQLFil("SB1")
	cQuery1 += "                      AND B1_TIPO = 'PP'"
	cQuery1 += "	                  AND B1_GRUPO IN('4003','9000') "
	cQuery1 += "                      AND B1_MSBLQL <> '1'"
	cQuery1 += "                      AND B1_CORORI IN('D','T','C','R') "
	cquery1 += "                      AND " + RetSQLDel("SB1") + ")"
	cQuery1 += "   AND Z8_DATA = '" + Dtos(mv_par01) + "'"
	cQuery1 += "   AND " + RetSQLDel("SG1") + " AND " + RetSQLDel("SZ8") + " AND " + RetSQLDel("SB1")
	cQuery1 += " GROUP BY G1_COMP "
	cQuery1 += " ORDER BY G1_COMP "

	cQuery1 := ChangeQuery(cQuery1)

	ProcLogAtu( 'MENSAGEM', "Seleção dos movimentos da desossa - produção dos PPs (SZ8) " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery1)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1), "TRB1", .F., .T.)

	TRB1->(DbGoTop())
	While TRB1->(!Eof())
		_nTotProd += TRB1->PESOTOT
		TRB1->(DbSkip())
	Enddo

	_cMemo += Replicate('-',65) + chr(13) + chr(10)
	_cMemo += "PRODUCAO DESOSSA     :" + chr(13) + chr(10)
	_cMemo += "Total PPs (Kg)       :" + Transform(_nTotProd,"@E 999,999.99999") + chr(13) + chr(10)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção dos movimentos da desossa - produção dos PAs (SZ8)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery2 := "SELECT Z8_CODORI, SUM(Z8_PESO) AS PESOTOT "
	cQuery2 += "  FROM " + RetSQLTab("SG1") + "," + RetSQLTab("SZ8") + "," + RetSQLTab("SB1")
	cQuery2 += " WHERE " + RetSQLFil("SG1") + " AND Z8_FILORI = '" + cFilAnt + "'" + " AND " + RetSQLFil("SB1")
	cQuery2 += "   AND B1_MSBLQL <> '1'"
	cQuery2 += "   AND B1_GRUPO IN ('5111','5112','5113','5121','5122','5123','5211','5213','5221','5223','5134','5135','5136') "
	cQuery2 += "   AND B1_COD = Z8_CODORI  "
	cQuery2 += "   AND B1_COD = G1_COD "
	cQuery2 += "   AND G1_COMP IN (SELECT B1_COD "
	cQuery2 += "                     FROM " + RetSQLTab("SB1")
	cQuery2 += "                    WHERE " + RetSQLFil("SB1")
	cQuery2 += "                      AND B1_TIPO = 'PP'"
	cQuery2 += "                      AND B1_MSBLQL <> '1'"
	cQuery2 += "	                  AND B1_GRUPO IN('4003','9000') "
	cQuery2 += "                      AND B1_CORORI IN('D','T','C','R') "
	cquery2 += "                      AND " + RetSQLDel("SB1") + ")"
	cQuery2 += "   AND Z8_DATA =  '" + Dtos(mv_par01) + "'"
	cQuery2 += "   AND " + RetSQLDel("SG1") + " AND " + RetSQLDel("SZ8") + " AND " + RetSQLDel("SB1")
	cQuery2 += " GROUP BY Z8_CODORI "
	cQuery2 += " ORDER BY Z8_CODORI "

	cQuery2 := ChangeQuery(cQuery2)

	ProcLogAtu( 'MENSAGEM', "Seleção dos movimentos da desossa - produção dos PAs (SZ8) " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery2)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery2), "TRB2", .F., .T.)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção dos movimentos da desossa - produção PPs Porc. (ZAS)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery3 := "SELECT G1_COMP, SUM(ZAS_PESOL) AS PESOTOT "
	cQuery3 += "  FROM " + RetSQLTab("SG1") + "," + RetSQLTab("ZAS")
	cQuery3 += " WHERE " + RetSQLFil("SG1") + " AND " + RetSQLFil("ZAS")
	cQuery3 += "   AND ZAS_TIPO = 'MP' "
	cQuery3 += "   AND ZAS_COD = G1_COD "
	cQuery3 += "   AND ZAS_DTPROD =  '" + Dtos(mv_par01) + "'"
	cQuery3 += "   AND " + RetSQLDel("SG1") + " AND " + RetSQLDel("ZAS")
	cQuery3 += " GROUP BY G1_COMP "
	cQuery3 += " ORDER BY G1_COMP "

	cQuery3 := ChangeQuery(cQuery3)

	ProcLogAtu( 'MENSAGEM', "Seleção dos movimentos da desossa - produção PPs Porc. (ZAS) " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery3)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery3), "TRB3", .F., .T.)

	_nTotPorc := 0

	TRB3->(DbGoTop())
	While TRB3->(!Eof())
		_nTotProd += TRB3->PESOTOT
		_nTotPorc += TRB3->PESOTOT
		TRB3->(DbSkip())
	Enddo

	_cMemo += "Total PPs Porc. (Kg):" + Transform(_nTotPorc,"@E 999,999.99999") + chr(13) + chr(10)
	_cMemo += "Total Geral(Kg)     :" + Transform(_nTotProd,"@E 999,999.99999") + chr(13) + chr(10)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sel. movim. desossa - produção dos PPs/MPs porc.     (ZAS)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery4 := "SELECT ZAS_COD, SUM(ZAS_PESOL) AS PESOTOT "
	cQuery4 += "  FROM " + RetSQLTab("ZAS")
	cQuery4 += " WHERE " + RetSQLFil("ZAS")
	cQuery4 += "   AND ZAS_TIPO = 'MP' "
	cQuery4 += "   AND ZAS_DTPROD =  '" + Dtos(mv_par01) + "'"
	cQuery4 += "   AND " + RetSQLDel("ZAS")
	cQuery4 += " GROUP BY ZAS_COD "
	cQuery4 += " ORDER BY ZAS_COD "

	cQuery4 := ChangeQuery(cQuery4)

	ProcLogAtu( 'MENSAGEM', "Seleção dos movimentos da desossa - produção dos PPs/MPs Porc. (ZAS) " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery4)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery4), "TRB4", .F., .T.)

	StatProc(_cMemo)

	//=================================================================================
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fase 1 - Processamento dos Dados Desossa      (PPs)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRB1->(dbGoTop())
	While TRB1->(!Eof())

		oSelf:IncRegua1("Fase 1 - Selecionando os dados desossa (PPs) ...")
		oSelf:IncRegua2()

		Pergunte(cPerg,.F.)

		_cProduto := TRB1->G1_COMP
		_cCorori  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_CORORI")
		_nPesoTot := TRB1->PESOTOT
		_cDescPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
		_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
		_cGrupPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_GRUPO")
		_cNumOp   := GETSX8NUM("SC2","C2_NUM")
		ConfirmSX8()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SC2 (ordens de produção de PP)                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aAutoSC2 := {}
		AADD(_aAutoSC2, {"AUTEXPLODE", "S"    							, NIL})
		AADD(_aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 	, NIL})
		AADD(_aAutoSC2, {"C2_NUM"    , _cNumOp                        	, NIL})
		AADD(_aAutoSC2, {"C2_ITEM"   , "01"                           	, NIL})
		AADD(_aAutoSC2, {"C2_SEQUEN" , "001"                    		, NIL})
		AADD(_aAutoSC2, {"C2_PRODUTO", _cProduto                      	, NIL})
		AADD(_aAutoSC2, {"C2_LOCAL"  , "01"                           	, NIL})
		AADD(_aAutoSC2, {"C2_CC"     , "1131005"                  		, NIL})	// Desossa
		AADD(_aAutoSC2, {"C2_QUANT"  , _nPesoTot                  		, NIL})
		AADD(_aAutoSC2, {"C2_DATPRI" , dDatabase                		, NIL})
		AADD(_aAutoSC2, {"C2_DATPRF" , dDatabase                		, NIL})
		AADD(_aAutoSC2, {"C2_EMISSAO", dDatabase                		, NIL})
		AADD(_aAutoSC2, {"C2_STATUS" , "N"                      		, NIL})
		AADD(_aAutoSC2, {"C2_TPOP"   , "F"                      		, NIL})
		AADD(_aAutoSC2, {"C2_GRUPO"  , _cGrupPrd                  		, NIL})
		AADD(_aAutoSC2, {"C2_UM"     , "KG"                       		, NIL})
		AADD(_aAutoSC2, {"C2_FLOTE"  , "P DEFTRB1" + Dtos(mv_par01) 	, NIL})  // Para fins de facilitar rastreio

		// Executa movimentacao de estoque via rotina automatica.
		If Len(_aAutoSC2) > 0
			lMSErroAuto := .F.
			DbSelectArea("SC2")
			Begin Transaction
				MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, 3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO -  OP NUMERO ==> " + _cNumOp + " PARA PP " + AllTrim(_cProduto))
					MsgAlert("Houve erro na geração da Ordem de Produção de PP na SC2. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else
					ProcLogAtu("MENSAGEM", "GERADO OP NUMERO ==> " + _cNumOp + " PARA PP " + AllTrim(_cProduto))
					AADD(_aProdOP1,_cNumOp + "01001")
					AADD(_aProdOPs,{_cNumOp + "01001","009",_cProduto,_nPesoTot})
					AADD(_aProdTot,{_cNumOp + "01001","009",_cProduto,_nPesoTot})
					DelSD4(_cNumOp + "01001")
					_sOps += "'" +alltrim(_cNumOp) + "01001" + "'," // 20220114
				Endif
			End Transaction
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO OP NUMERO ==> " + _cNumOp + " PARA PP " + AllTrim(_cProduto))
		Endif

		TRB1->(DbSkip())
	Enddo

	TRB1->(DbCloseArea())

	// Efetua a apuração dos empenhos
	_nTotEmp := 0
	For x := 1 To Len(_aProdOP1)
		SD4->(DbSetOrder(2))
		SD4->(DbSeek(xFilial("SD4") + _aProdOP1[x]))
		While SD4->(!Eof()) .And. SD4->D4_FILIAL = xFilial("SD4") .And. SD4->D4_OP = _aProdOP1[x]
			DbSelectArea("SB1")
			_cTipoEmp := fBuscaCPO("SB1",1,xFilial("SB1") + SD4->D4_COD,"B1_TIPO")
			If _cTipoEmp = "PP"
				_nTotEmp += SD4->D4_QUANT
			Endif
			SD4->(DbSkip())
		Enddo
	Next

	_cMemo += Replicate('-',65) + chr(13) + chr(10)
	_cMemo += "Fase 01: OPs de PPs" + chr(13) + chr(10)
	_cMemo += "Total Empenhos (kg)    :" + Transform(_nTotEmp,"@E 999,999.99999") + chr(13) + chr(10)

	StatProc(_cMemo)

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

	// Efetiva a produção no SD3
	ProdSD3()

	//=================================================================================
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fase 2 - Processamento dos Dados Desossa (PPs porcionados)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRB3->(dbGoTop())
	While TRB3->(!Eof())

		oSelf:IncRegua1("Fase 2 - Selecionando os dados desossa (PPs Porcionados) ...")
		oSelf:IncRegua2()

		Pergunte(cPerg,.F.)

		_cProduto := TRB3->G1_COMP
		_cCorori  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_CORORI")
		_nPesoTot := TRB3->PESOTOT
		_cDescPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
		_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
		_cGrupPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_GRUPO")
		_cNumOp   := GETSX8NUM("SC2","C2_NUM")
		ConfirmSX8()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SC2 (ordens de produção de PP)                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aAutoSC2 := {}
		AADD(_aAutoSC2, {"AUTEXPLODE", "S"    							, NIL})
		AADD(_aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 	, NIL})
		AADD(_aAutoSC2, {"C2_NUM"    , _cNumOp                        	, NIL})
		AADD(_aAutoSC2, {"C2_ITEM"   , "01"                           	, NIL})
		AADD(_aAutoSC2, {"C2_SEQUEN" , "001"                    		, NIL})
		AADD(_aAutoSC2, {"C2_PRODUTO", _cProduto                      	, NIL})
		AADD(_aAutoSC2, {"C2_LOCAL"  , "01"                           	, NIL})
		AADD(_aAutoSC2, {"C2_CC"     , "1131005"                  		, NIL})	// Desossa
		AADD(_aAutoSC2, {"C2_QUANT"  , _nPesoTot                  		, NIL})
		AADD(_aAutoSC2, {"C2_DATPRI" , dDatabase                		, NIL})
		AADD(_aAutoSC2, {"C2_DATPRF" , dDatabase                		, NIL})
		AADD(_aAutoSC2, {"C2_EMISSAO", dDatabase                		, NIL})
		AADD(_aAutoSC2, {"C2_STATUS" , "N"                      		, NIL})
		AADD(_aAutoSC2, {"C2_TPOP"   , "F"                      		, NIL})
		AADD(_aAutoSC2, {"C2_GRUPO"  , _cGrupPrd                  		, NIL})
		AADD(_aAutoSC2, {"C2_UM"     , "KG"                       		, NIL})
		AADD(_aAutoSC2, {"C2_FLOTE"  , "P DEFTRB3" + Dtos(mv_par01) 	, NIL})  // Para fins de facilitar rastreio

		// Executa movimentacao de estoque via rotina automatica.
		If Len(_aAutoSC2) > 0
			lMSErroAuto := .F.
			DbSelectArea("SC2")
			Begin Transaction
				_lNumOPAtu := .t.
				MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, 3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO -  OP NUMERO ==> " + _cNumOp + " PARA PP Porcionados" + AllTrim(_cProduto))
					MsgAlert("Houve erro na geração da Ordem de Produção de PP Porcionados na SC2. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else
					ProcLogAtu("MENSAGEM", "GERADO OP NUMERO ==> " + _cNumOp + " PARA PP Porcionados" + AllTrim(_cProduto))
					AADD(_aProdOPs,{_cNumOp + "01001","009",_cProduto,_nPesoTot})
					AADD(_aProdTot,{_cNumOp + "01001","009",_cProduto,_nPesoTot})
					AADD(_aProdOP2,_cNumOp + "01001")
					DelSD4(_cNumOp + "01001")
					_sOps += "'" +alltrim(_cNumOp) + "01001" + "'," // 20220114
				Endif
			End Transaction
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO OP NUMERO ==> " + _cNumOp + " PARA PP Porcionados" + AllTrim(_cProduto))
		Endif

		TRB3->(DbSkip())
	Enddo

	// Efetua a apuração dos empenhos
	_nTotEmp := 0

	For x := 1 To Len(_aProdOP2)
		SD4->(DbSetOrder(2))
		SD4->(DbSeek(xFilial("SD4") + _aProdOP2[x]))
		While SD4->(!Eof()) .And. SD4->D4_FILIAL = xFilial("SD4") .And. SD4->D4_OP = _aProdOP2[x]
			DbSelectArea("SB1")
			_cTipoEmp := fBuscaCPO("SB1",1,xFilial("SB1") + SD4->D4_COD,"B1_TIPO")
			If _cTipoEmp = "PP"
				_nTotEmp += SD4->D4_QUANT
			Endif
			SD4->(DbSkip())
		Enddo
	Next

	_cMemo += Replicate('-',65) + chr(13) + chr(10)
	_cMemo += "Fase 02: OPs de PPs Porcionados" + chr(13) + chr(10)
	_cMemo += "Total Empenhos (kg)    :" + Transform(_nTotEmp,"@E 999,999.99999") + chr(13) + chr(10)

	TRB3->(DbCloseArea())

	StatProc(_cMemo)

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

	// Efetiva a produção no SD3
	ProdSD3()

	//=================================================================================
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fase 3 - Processamento dos Dados Desossa        (PAs)    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aDadosPA := {}
	TRB2->(dbGoTop())
	While TRB2->(!Eof())

		oSelf:IncRegua1("Fase 3 - Selecionando os dados desossa (PAs) ...")
		oSelf:IncRegua2()

		Pergunte(cPerg,.F.)

		_cProduto := TRB2->Z8_CODORI
		_nPesoTot := TRB2->PESOTOT
		_cDescPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
		_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
		_cGrupPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_GRUPO")
		_cCorori  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_CORORI")
		_cNumOp   := GETSX8NUM("SC2","C2_NUM")
		ConfirmSX8()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SC2 (ordens de produção de PAs)                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aAutoSC2 := {}
		AADD(_aAutoSC2, {"AUTEXPLODE", "S"    							, NIL})
		AADD(_aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 	, NIL})
		AADD(_aAutoSC2, {"C2_NUM"    , _cNumOp                        	, NIL})
		AADD(_aAutoSC2, {"C2_ITEM"   , "01"                           	, NIL})
		AADD(_aAutoSC2, {"C2_SEQUEN" , "001"                    		, NIL})
		AADD(_aAutoSC2, {"C2_PRODUTO", _cProduto                      	, NIL})
		AADD(_aAutoSC2, {"C2_LOCAL"  , "01"                           	, NIL})
		AADD(_aAutoSC2, {"C2_CC"     , "1131005"                  		, NIL})	// Desossa
		AADD(_aAutoSC2, {"C2_QUANT"  , _nPesoTot                  		, NIL})
		AADD(_aAutoSC2, {"C2_DATPRI" , dDatabase                		, NIL})
		AADD(_aAutoSC2, {"C2_DATPRF" , dDatabase                		, NIL})
		AADD(_aAutoSC2, {"C2_EMISSAO", dDatabase                		, NIL})
		AADD(_aAutoSC2, {"C2_STATUS" , "N"                      		, NIL})
		AADD(_aAutoSC2, {"C2_TPOP"   , "F"                      		, NIL})
		AADD(_aAutoSC2, {"C2_GRUPO"  , _cGrupPrd                  		, NIL})
		AADD(_aAutoSC2, {"C2_UM"     , "KG"                       		, NIL})
		AADD(_aAutoSC2, {"C2_FLOTE"  , "P DEFTRB2" + Dtos(mv_par01) 	, NIL})  // Para fins de facilitar rastreio

		// Executa movimentacao de estoque via rotina automatica.
		If Len(_aAutoSC2) > 0
			lMSErroAuto := .F.
			DbSelectArea("SC2")
			Begin Transaction
				_lNumOPAtu := .t.
				MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, 3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO -  OP NUMERO ==> " + _cNumOp + " PARA PAs " + AllTrim(_cProduto))
					MsgAlert("Houve erro na geração da Ordem de Produção de PAs na SC2. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else 
					ProcLogAtu("MENSAGEM", "GERADO OP NUMERO ==> " + _cNumOp + " PARA PAs " + AllTrim(_cProduto))
					AADD(_aProdOPs,{_cNumOp + "01001","009",_cProduto,_nPesoTot})        
					AADD(_aProdOP3,_cNumOp + "01001")
					_sOps += "'" +alltrim(_cNumOp) + "01001" + "'," // 20220114
				Endif                                       
			End Transaction
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO OP NUMERO ==> " + _cNumOp + " PARA PAs " + AllTrim(_cProduto))
		Endif
		_sOps += "'" +alltrim(_cNumOp) + "01001" + "'," // 20220114
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena Array com Dados para lançar movimentos de produção   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD( _aDadosPA , {_cNumOp, "01", "001", dDataBase, _cProduto , "01", _cGrupPrd, "KG", _nPesoTot })

		TRB2->(DbSkip())
	Enddo

	// Inicio Bloco Desenvolvido
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra Listagem de OPs geradas para selecionar alteracao das embalagens com  ³
	//³ produtos alternativos														 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//_EmpEmb()
	//Alert('inicio EmpEmbCa')
	U_EmpEmbCa(_sOps) //20220113
	//Alert('fim EmpEmbCa')
	// Final Bloco Desenvolvido

	//Para apurar os empenhos
	_nTotEmp := 0

	For x := 1 To Len(_aProdOP3)
		SD4->(DbSetOrder(2))
		SD4->(DbSeek(xFilial("SD4") + _aProdOP3[x]))
		While SD4->(!Eof()) .And. SD4->D4_FILIAL = xFilial("SD4") .And. SD4->D4_OP = _aProdOP3[x]
			DbSelectArea("SB1")
			_cTipoEmp := fBuscaCPO("SB1",1,xFilial("SB1") + SD4->D4_COD,"B1_TIPO")
			If _cTipoEmp = "PP"
				_nTotEmp += SD4->D4_QUANT
			Endif
			SD4->(DbSkip())
		Enddo
	Next

	_cMemo += Replicate('-',65) + chr(13) + chr(10)
	_cMemo += "Fase 03: OPs de PAs Desossa" + chr(13) + chr(10)
	_cMemo += "Total Empenhos (Kg)    :" + Transform(_nTotEmp,"@E 999,999.99999") + chr(13) + chr(10)

	TRB2->(DbCloseArea())

	StatProc(_cMemo)

	Pergunte(cPerg,.F.)

	// Efetiva a produção no SD3
	ProdSD3()


	//=================================================================================
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fase 4 - Processamento dos Dados Desossa (PPs/MPs porc)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRB4->(dbGoTop())
	While TRB4->(!Eof())

		oSelf:IncRegua1("Fase 4 - Selecionando os dados desossa (PPs/MPs Porc) ...")
		oSelf:IncRegua2()

		Pergunte(cPerg,.F.)

		_cProduto := TRB4->ZAS_COD
		_nPesoTot := TRB4->PESOTOT
		_cDescPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
		_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
		_cGrupPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_GRUPO")
		_cCorori  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_CORORI")
		_cNumOp   := GETSX8NUM("SC2","C2_NUM")
		ConfirmSX8()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SC2 (ordens de produção de PAs)                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aAutoSC2 := {}
		AADD(_aAutoSC2, {"AUTEXPLODE", "S"    							, NIL})
		AADD(_aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 	, NIL})
		AADD(_aAutoSC2, {"C2_NUM"    , _cNumOp                        	, NIL})
		AADD(_aAutoSC2, {"C2_ITEM"   , "01"                           	, NIL})
		AADD(_aAutoSC2, {"C2_SEQUEN" , "001"                    		, NIL})
		AADD(_aAutoSC2, {"C2_PRODUTO", _cProduto                      	, NIL})
		AADD(_aAutoSC2, {"C2_LOCAL"  , "01"                           	, NIL})
		AADD(_aAutoSC2, {"C2_CC"     , "1131005"                  		, NIL})	// Desossa
		AADD(_aAutoSC2, {"C2_QUANT"  , _nPesoTot                  		, NIL})
		AADD(_aAutoSC2, {"C2_DATPRI" , dDatabase                		, NIL})
		AADD(_aAutoSC2, {"C2_DATPRF" , dDatabase                		, NIL})
		AADD(_aAutoSC2, {"C2_EMISSAO", dDatabase                		, NIL})
		AADD(_aAutoSC2, {"C2_STATUS" , "N"                      		, NIL})
		AADD(_aAutoSC2, {"C2_TPOP"   , "F"                      		, NIL})
		AADD(_aAutoSC2, {"C2_GRUPO"  , _cGrupPrd                  		, NIL})
		AADD(_aAutoSC2, {"C2_UM"     , "KG"                       		, NIL})
		AADD(_aAutoSC2, {"C2_FLOTE"  , "P DEFTRB4" + Dtos(mv_par01) 	, NIL})  // Para fins de facilitar rastreio

		// Executa movimentacao de estoque via rotina automatica.
		If Len(_aAutoSC2) > 0
			lMSErroAuto := .F.
			DbSelectArea("SC2")
			Begin Transaction
				_lNumOPAtu := .t.
				MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, 3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO -  OP NUMERO ==> " + _cNumOp + " PARA PPs/MPs Porc. " + AllTrim(_cProduto))
					MsgAlert("Houve erro na geração da Ordem de Produção de PPs/MPs Porc. na SC2. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else
					ProcLogAtu("MENSAGEM", "GERADO OP NUMERO ==> " + _cNumOp + " PARA PPs/MPs Porc. " + AllTrim(_cProduto))
					AADD(_aProdOPs,{_cNumOp + "01001","009",_cProduto,_nPesoTot})
					AADD(_aProdOP4,_cNumOp + "01001")
					_sOps += "'" +alltrim(_cNumOp) + "01001" + "'," // 20220114
				Endif
			End Transaction
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO OP NUMERO ==> " + _cNumOp + " PARA PPs/MPs Porc. " + AllTrim(_cProduto))
		Endif

		TRB4->(DbSkip())
	Enddo

	_nTotEmp := 0

	For x := 1 To Len(_aProdOP4)
		SD4->(DbSetOrder(2))
		SD4->(DbSeek(xFilial("SD4") + _aProdOP4[x]))
		While SD4->(!Eof()) .And. SD4->D4_FILIAL = xFilial("SD4") .And. SD4->D4_OP = _aProdOP4[x]
			DbSelectArea("SB1")
			_cTipoEmp := fBuscaCPO("SB1",1,xFilial("SB1") + SD4->D4_COD,"B1_TIPO")
			If _cTipoEmp = "PP"
				_nTotEmp += SD4->D4_QUANT
			Endif
			SD4->(DbSkip())
		Enddo
	Next

	_cMemo += Replicate('-',65) + chr(13) + chr(10)
	_cMemo += "Fase 04: OPs de PPs/MPs Porcionados:" + chr(13) + chr(10)
	_cMemo += "Total Empenhos (Kg)    :" + Transform(_nTotEmp,"@E 999,999.99999") + chr(13) + chr(10)

	TRB4->(DbCloseArea())

	Pergunte(cPerg,.F.)

	StatProc(_cMemo)

	// Efetiva a produção no SD3
	ProdSD3()


	//=================================================================================
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fase 5 - Processamento dos Dados Desossa  Despojos (PP)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nTProduz := 0

	For j := 1 To Len(_aProdtot)
		_nTProduz += _aProdTot[j,4]
	Next

	_nPesoTot := _nTotalProd - _nTProduz

	_cMemo += Replicate('-',65) + chr(13) + chr(10)
	_cMemo += "Fase 05: OPs de Despojo" + chr(13) + chr(10)
	_cMemo += "Total Cons. Desossa (Kg):" + Transform(_nTotalProd,"@E 999,999.99999") + chr(13) + chr(10)
	_cMemo += "Total Prod. Embal.1 (Kg):" + Transform(_nTProduz  ,"@E 999,999.99999") + chr(13) + chr(10)
	_cMemo += "Total Prod. Embal.2 (Kg):" + Transform(_nTotProd  ,"@E 999,999.99999") + chr(13) + chr(10)
	_cMemo += "Produção Despojo (Kg)   :" + Transform(_nPesoTot  ,"@E 999,999.99999") + chr(13) + chr(10)

	Pergunte(cPerg,.F.)

	_cProduto  := "PP0084"
	_cDescPrd  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
	_cUnidMed  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
	_cGrupPrd  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_GRUPO")
	_cCorori   := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_CORORI")
	_cNumOp    := GETSX8NUM("SC2","C2_NUM")
	ConfirmSX8()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava SC2 (ordens de produção de PAs)                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aAutoSC2 := {}
	AADD(_aAutoSC2, {"AUTEXPLODE", "S"    							, NIL})
	AADD(_aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 	, NIL})
	AADD(_aAutoSC2, {"C2_NUM"    , _cNumOp                        	, NIL})
	AADD(_aAutoSC2, {"C2_ITEM"   , "01"                           	, NIL})
	AADD(_aAutoSC2, {"C2_SEQUEN" , "001"                    		, NIL})
	AADD(_aAutoSC2, {"C2_PRODUTO", _cProduto                      	, NIL})
	AADD(_aAutoSC2, {"C2_LOCAL"  , "01"                           	, NIL})
	AADD(_aAutoSC2, {"C2_CC"     , "1131005"                  		, NIL})	// Desossa
	AADD(_aAutoSC2, {"C2_QUANT"  , _nPesoTot                  		, NIL})
	AADD(_aAutoSC2, {"C2_DATPRI" , dDatabase                		, NIL})
	AADD(_aAutoSC2, {"C2_DATPRF" , dDatabase                		, NIL})
	AADD(_aAutoSC2, {"C2_EMISSAO", dDatabase                		, NIL})
	AADD(_aAutoSC2, {"C2_STATUS" , "N"                      		, NIL})
	AADD(_aAutoSC2, {"C2_TPOP"   , "F"                      		, NIL})
	AADD(_aAutoSC2, {"C2_GRUPO"  , _cGrupPrd                  		, NIL})
	AADD(_aAutoSC2, {"C2_UM"     , "KG"                       		, NIL})
	AADD(_aAutoSC2, {"C2_FLOTE"  , "P DESPOJO" + Dtos(mv_par01) 	, NIL})  // Para fins de facilitar rastreio

	// Executa movimentacao de estoque via rotina automatica.
	If Len(_aAutoSC2) > 0
		lMSErroAuto := .F.
		DbSelectArea("SC2")
		Begin Transaction
			_lNumOPAtu := .t.
			MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, 3)    // Inclusão
			If lMSErroAuto
				ProcLogAtu("ERRO", "ERRO GERACAO -  OP NUMERO ==> " + _cNumOp + " PARA PAs DESPOJO " + AllTrim(_cProduto))
				MsgAlert("Houve erro na geração da Ordem de Produção de PAs Despojo na SC2. Verifique na tela seguinte.", ProcName())
				MostraErro()
				DisarmTransaction()
			Else
				ProcLogAtu("MENSAGEM", "GERADO OP NUMERO ==> " + _cNumOp + " PARA PAs DESPOJO " + AllTrim(_cProduto))
				AADD(_aProdOPs,{_cNumOp + "01001","009",_cProduto,_nPesoTot})
				AADD(_aProdTot,{_cNumOp + "01001","009",_cProduto,_nPesoTot})
				DelSD4(_cNumOp + "01001")
				_sOps += "'" +alltrim(_cNumOp) + "01001" + "'," // 20220114
			Endif
		End Transaction
	Else
		ProcLogAtu("MENSAGEM", "NAO FOI GERADO OP NUMERO ==> " + _cNumOp + " PARA PAs DESPOJO " + AllTrim(_cProduto))
	Endif

	_nTotEmp := 0

	SD4->(DbSetOrder(2))
	SD4->(DbSeek(xFilial("SD4") + _cNumOp))
	While SD4->(!Eof()) .And. SD4->D4_FILIAL = xFilial("SD4") .And. SD4->D4_OP = _cNumOp
		DbSelectArea("SB1")
		_cTipoEmp := fBuscaCPO("SB1",1,xFilial("SB1") + SD4->D4_COD,"B1_TIPO")
		If _cTipoEmp = "PP"
			_nTotEmp += SD4->D4_QUANT
		Endif
		SD4->(DbSkip())
	Enddo

	_cMemo += "Total Empenho (Kg)   :" + Transform(_nTotEmp,"@E 999,999.99999") + chr(13) + chr(10)

	Pergunte(cPerg,.F.)

	StatProc(_cMemo)

	// Efetiva a produção no SD3
	ProdSD3()

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
		AADD(_aVetor, {"D3_OP"      , _aProdOPs[i,1]        		  		,NIL})
		AADD(_aVetor, {"D3_TM"      , _aProdOPs[i,2]    					,NIL})
		AADD(_aVetor, {"D3_EMISSAO" , dDatabase 					    	,NIL})
		AADD(_aVetor, {"D3_COD"     , _aProdOPs[i,3]						,NIL})
		AADD(_aVetor, {"D3_UM"      , "KG"									,NIL})
		AADD(_aVetor, {"D3_QUANT"   , _aProdOPs[i,4]						,NIL})
		AADD(_aVetor, {"D3_DOC"     , NextNumero("SD3",2,"D3_DOC",.T.) 		,NIL})
		AADD(_aVetor, {"D3_LOCAL"   , "01"           						,NIL})
		AADD(_aVetor, {"D3_FLOTE" 	, "P DEFINIR "							,NIL})
		AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())   					,NIL})

		// Executa movimentacao de produção de PP via rotina automatica.
		If Len(_aVetor) > 0
			lMSErroAuto := .F.
			DbSelectArea("SD3")
			Begin Transaction
				MSExecAuto({|x,y| mata250(x,y)}, _aVetor, 3)    // Inclusão
				If lMSErroAuto
					ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE PRODUCAO OP ==> " + _aProdOPs[i,1] + " PARA PP " + _aProdOPs[i,3] + " D3_TM = " + _aProdOPs[i,2])
					MsgAlert("Houve erro na geração da produção do SD3 de PP. Verifique na tela seguinte.", ProcName())
					MostraErro()
					DisarmTransaction()
				Else
					ProcLogAtu("MENSAGEM", "GERADO SD3 DE PRODUCAO OP ==> " + _aProdOPs[i,1] + " PARA PP " + _aProdOPs[i,3] + " D3_TM = " + _aProdOPs[i,2])
				Endif
			End Transaction
		Else
			ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE PRODUCAO OP ==> " + _aProdOPs[i,1] + " PARA PP " + _aProdOPs[i,3] + " D3_TM = " + _aProdOPs[i,2])
		Endif
	next

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

	_aProdOPs := {}

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} DelSD4
Ajusta SD4 (empenhos de produção)
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function DelSD4(_cNumOP)

	SC2->(DbSetOrder(1))
	SC2->(DbSeek(xFilial("SC2") + _cNumOP))

	_cProdPP  := SC2->C2_PRODUTO
	_nQtdePai := SC2->C2_QUANT

	DbSelectArea("SB1")
	_cTipo   := fBuscaCPO("SB1",1,xFilial("SB1") + _cProdPP,"B1_TIPO")
	_cCorori := fBuscaCPO("SB1",1,xFilial("SB1") + _cProdPP,"B1_CORORI")

	//Ajusta empenho para recortes e carne para charque
	//Exclui o processamento o PP0084: despojo de desossa
	If (_cTipo = "PP" .And. _cCorori = "R") .Or. _cProdPP = "PP0084"
		DbSelectArea("SD4")
		SD4->(DbGoTop())
		SD4->(DbSetOrder(2))
		SD4->(DbSeek(xFilial("SD4") + _cNumOp))
		While SD4->(!Eof()) .And. SD4->D4_FILIAL + SD4->D4_OP == xFilial("SD4") + _cNumOp
			SB2->(DbSetOrder(1))
			If SB2->(DbSeek(xFilial("SB2") + SD4->D4_COD + SD4->D4_LOCAL))
				Reclock("SB2",.F.)
				SB2->B2_QEMP -= SD4->D4_QUANT
				MsUnlock()
			Endif

			Reclock("SD4",.F.)
			DbDelete()
			MsUnlock()
			SD4->(DbSkip())
		Enddo

		If _nPercTras <> 0
			DbSelectArea("SD4")
			Reclock("SD4",.T.)
			SD4->D4_FILIAL  := xFilial("SD4")
			SD4->D4_COD     := "005016"
			SD4->D4_OP      := _cNumOP
			SD4->D4_LOCAL   := "01"
			SD4->D4_DATA    := DDATABASE
			SD4->D4_QTDEORI := _nQtdePai * _nPercTras
			SD4->D4_QUANT   := _nQtdePai * _nPercTras
			SD4->D4_DTVALID := DDATABASE
			SD4->D4_ROTBLK  := AllTrim(FunName())
			MsUnlock()
		Endif

		If _nPercDian <> 0
			DbSelectArea("SD4")
			Reclock("SD4",.T.)
			SD4->D4_FILIAL  := xFilial("SD4")
			SD4->D4_COD     := "005020"
			SD4->D4_OP      := _cNumOP
			SD4->D4_LOCAL   := "01"
			SD4->D4_DATA    := DDATABASE
			SD4->D4_QTDEORI := _nQtdePai * _nPercDian
			SD4->D4_QUANT   := _nQtdePai * _nPercDian
			SD4->D4_DTVALID := DDATABASE
			SD4->D4_ROTBLK  := AllTrim(FunName())
			MsUnlock()
		Endif

		If _nPercCost <> 0
			DbSelectArea("SD4")
			Reclock("SD4",.T.)
			SD4->D4_FILIAL  := xFilial("SD4")
			SD4->D4_COD     := "005018"
			SD4->D4_OP      := _cNumOP
			SD4->D4_LOCAL   := "01"
			SD4->D4_DATA    := DDATABASE
			SD4->D4_QTDEORI := _nQtdePai * _nPercCost
			SD4->D4_QUANT   := _nQtdePai * _nPercCost
			SD4->D4_DTVALID := DDATABASE
			SD4->D4_ROTBLK  := AllTrim(FunName())
			MsUnlock()
		Endif
	Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} StatProc
Funcao de status do processamento
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function StatProc(_cMemo)

	@ 000,000 To 290,320 Dialog oDlgMemo Title "Status do Processamento:"
	@ 005,005 Get _cMemo Size 150,120 MEMO Object oMemo
	@ 130,045 BUTTON botao1 PROMPT "Fechar" OF oDlgMemo PIXEL ACTION oDlgMemo:end()
	Activate Dialog oDlgMemo  CENTERED

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _AtuD4B2
Funcao executada ao confirmar tela de OPs que necessitam ajuste das embalagens
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function _AtuD4B2(_cOp)

	Local oGetDados
	Local nUsado 	:= 0
	Local aSize		:= MsAdvSize()
	Local aObjects 	:= {}
	Local aInfo    	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj  	:= {}
	Local nX

	Private oDlg1	:= Nil
	Private lRefresh:= .T.
	Private aHeader := {}
	Private aCols 	:= {}
	Private aRotina := {{"Pesquisar"	, "AxPesqui", 0, 1},;
						{"Visualizar"	, "AxVisual", 0, 2},;
						{"Incluir"		, "AxInclui", 0, 3},;
						{"Alterar"		, "AxAltera", 0, 4},;
						{"Excluir"		, "AxDeleta", 0, 5}}


	AADD(aHeader,{'Produto'   			,'D4_COD'   	,'@!'          				,15   ,0 , , , 'C' , ,})
	AADD(aHeader,{'Descrição' 			,'D4_DESC'    	,'@!'          				,40   ,0 , , , 'C' , ,})
	AADD(aHeader,{'Produto Altern.'  	,'D4_CODA'    	,'@!'          				,15   ,0 , , , 'C' , ,})
	AADD(aHeader,{'Descrição Altern.'	,'D4_DESCA'	  	,'@!'          				,40   ,0 , , , 'C' , ,})
	AADD(aHeader,{'Armazém'				,'D4_LOCAL'   	,'@!'          				,2    ,0 , , , 'C' , ,})
	AADD(aHeader,{'Ordem de Produção'	,'D4_OP'      	,'@N'          				,13   ,0 , , , 'C' , ,})
	AADD(aHeader,{'DT Empenho'			,'D4_DATA'    	,'@D'         				,8    ,0 , , , 'D' , ,})
	AADD(aHeader,{'Qtd. Empenho'		,'D4_QTDEORI' 	,'@E 9,999,999,999.9999999'	,18   ,7 , , , 'N' , ,})
	AADD(aHeader,{'Sal. Empenho'		,'D4_QUANT'   	,'@E 9,999,999,999.9999999'	,18   ,7 , , , 'N' , ,})
	AADD(aHeader,{'Seq. Estrutura'		,'D4_TRT'     	,'@!'          				,3    ,0 , , , 'C' , ,})
	AADD(aHeader,{'Data Validade'		,'D4_DTVALID' 	,'@D'          				,8    ,0 , , , 'D' , ,})
	AADD(aHeader,{'Sld. Emp 2aUM'		,'D4_QTSEGUM' 	,'@E 9,999,999,999.9999999'	,18   ,7 , , , 'N' , ,})

	nUsado := Len(aHeader)

	DbSelectArea("SD4")
	DbSetOrder(2)
	DbSeek(xFilial("SD4") + _cOp)
	Do While !Eof() .And. SD4->D4_FILIAL + SD4->D4_OP == xFilial("SD4") + _cOp
		AADD(aCols,Array(nUsado+1))
		For nX := 1 To nUsado
			DO CASE
				CASE aHeader[nX,2] == "D4_DESC"
					aCols[Len(aCols)][nX] := fBuscaCpo("SB1", 1, xFilial("SB1") + FieldGet(FieldPos(aHeader[1,2])), "B1_DESC")
				CASE aHeader[nX,2] == "D4_DESCA"
					aCols[Len(aCols)][nX] := Space(40)
				OTHERWISE
					aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHeader[nX,2]))
			ENDCASE
		Next nX
		aCols[Len(aCols)][nUsado+1] := .F.

		// Estorno empenho dos saldos do produto
		DbSelectArea("SB2")
		DbSetOrder(1)
		If DbSeek(xFilial("SB2")+SD4->D4_COD+SD4->D4_LOCAL)
			RecLock("SB2",.F.)
			SB2->B2_QEMP  := SB2->B2_QEMP - SD4->D4_QUANT
			SB2->B2_QEMP2 := SB2->B2_QEMP2 - SD4->D4_QTSEGUM
			MsUnlock()
		Else
			MsgAlert("Produto / Local " + SD4->D4_COD + " / " + SD4->D4_LOCAL + " não encontrado no SB2 para estorno do empenho. Verifique!")
		Endif

		// Deleta empemho apos leitura do mesmo
		DbSelectArea("SD4")
		Reclock("SD4",.F.)
		DbDelete()
		MsUnlock()
		DbSkip()
	Enddo


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aObjects,{315,50,.T.,.T.})
	AADD(aObjects,{100,450,.T.,.T.})
	AADD(aObjects,{100,15,.T.,.F.})
	aPosObj := MsObjSize(aInfo,aObjects,.T.)

	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{005,050,110,165,225,280}} )
	nGetLin := aPosObj[3,1]

	oDlg1:= MSDIALOG():New(aSize[7], 0, aSize[6], aSize[5], "Empenhos para Ajuste das Embalagens",,,,,,,,,.T.)
	oDlg1:lMaximized:= .T.

	_aAlter := {"D4_CODA","D4_LOCAL","D4_DATA","D4_QTDEORI","D4_QUANT","D4_QTSEGUM"}
	oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],4,"U_LINHAOK1","U_TUDOOK1","D4_OP.D4_TRT.D4_DTVALID",.T.,_aAlter,,.T.,,"U_FIELDOK1",,,,oDlg1)

	TButton():New(nGetLin,aPosGet[1,5], "Confirmar" , oDlg1, {|| _GrvD4B2(), nOpc:= 1}, 50, 010,,,.F.,.T.,.F.,,.F.,,,.F.)
	oDlg1:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _GrvD4B2
Funcao para regravar os empenhos SD4 e atualizar os empenhos da SB2
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function _GrvD4B2()
	Local nX

	For nX:= 1 To Len(aCols)
		If !aCols[nX][Len(aHeader)+1]    // Trata Somente Itens Nao Deletados
			DbSelectArea("SD4")
			Reclock("SD4",.T.)
			SD4->D4_FILIAL  := xFilial("SD4")
			If Empty(aCols[nX, 3])
				SD4->D4_COD := aCols[nX, 1]
			Else
				SD4->D4_COD := aCols[nX, 3]
			Endif
			SD4->D4_LOCAL   := aCols[nX, 5]
			SD4->D4_OP      := aCols[nX, 6]
			SD4->D4_DATA    := aCols[nX, 7]
			SD4->D4_QTDEORI := aCols[nX, 8]
			SD4->D4_QUANT   := aCols[nX, 9]
			SD4->D4_TRT     := aCols[nX, 10]
			SD4->D4_DTVALID := aCols[nX, 11]
			SD4->D4_QTSEGUM := aCols[nX, 12]
			SD4->D4_ROTBLK  := AllTrim(FunName())
			MsUnlock()

			// Ajusta empenho dos saldos do produto
			DbSelectArea("SB2")
			DbSetOrder(1)
			If DbSeek(xFilial("SB2")+SD4->D4_COD+SD4->D4_LOCAL)
				RecLock("SB2",.F.)
				SB2->B2_QEMP  := SB2->B2_QEMP + SD4->D4_QUANT
				SB2->B2_QEMP2 := SB2->B2_QEMP2 + SD4->D4_QTSEGUM
				MsUnlock()
			Else
				MsgAlert("Produto / Local " + SD4->D4_COD + " / " + SD4->D4_LOCAL + " não encontrado no SB2 para ajuste do empenho. Verifique!")
			Endif
		Endif
	Next

	oDlg1:End()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FIELDOK1
Funcao para validacao do campo
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
User Function FIELDOK1()
	_lRet := .T.

	If (fBuscaCpo("SB1", 1, xFilial("SB1") + GDFieldGet("D4_COD", n), "B1_TIPO") == "PP") .Or. (fBuscaCpo("SB1", 1, xFilial("SB1") + GDFieldGet("D4_COD", n), "B1_TIPO") == "SP")
		MsgAlert("Não é permitido manipular linha de produtos do tipo PP ou SP")
		Return(.F.)
	Endif

	If __ReadVar == "M->D4_CODA"

		If !Empty(GDFieldGet("D4_COD", n))
			GdFieldPut("D4_LOCAL", fBuscaCpo("SB1", 1, xFilial("SB1") + M->D4_CODA, "B1_LOCPAD"))

			DbSelectArea("SGI")
			DbSetOrder(1)
			DbSeek(xFilial("SGI") + GDFieldGet("D4_COD", n))
			While !Eof() .And. SGI->GI_FILIAL + SGI->GI_PRODORI == xFilial("SGI") + GDFieldGet("D4_COD", n)
				If SGI->GI_PRODALT == M->D4_CODA		// Se produto alternativo diferente do produto informado
					_lRet := .T.
					GdFieldPut("D4_DESCA", fBuscaCpo("SB1", 1, xFilial("SB1") + M->D4_CODA, "B1_DESC"))
					Exit
				Else
					_lRet := .F.
				Endif
				DbSelectArea("SGI")
				DbSkip()
			Enddo
			If !_lRet
				MsgAlert("Produto informado não e produto alternativo ou não esta cadastrado como produto alternativo. Informe novo produto alternativo.")
			Endif
		Else
			GdFieldPut("D4_LOCAL", fBuscaCpo("SB1", 1, xFilial("SB1") + M->D4_CODA, "B1_LOCPAD"))

			DbSelectArea("SC2")
			DbSetOrder(1)
			If DbSeek(xFilial("SC2") + AllTrim(GDFieldGet("D4_OP", n)))			// Procura a OP da primeira linha do aCols
				_cProdOP := SC2->C2_PRODUTO
			Else
				_cProdOP := Space(15)
			Endif

			DbSelectArea("SG1")
			DbSetOrder(1)
			DbSeek(xFilial("SG1") + _cProdOP)
			While !Eof() .And. SG1->G1_FILIAL + SG1->G1_COD == xFilial("SG1") + _cProdOP
				_cProdComp := SG1->G1_COMP

				DbSelectArea("SGI")
				DbSetOrder(1)
				DbSeek(xFilial("SGI") + _cProdComp)
				While !Eof() .And. SGI->GI_FILIAL + SGI->GI_PRODORI == xFilial("SGI") + _cProdComp
					If SGI->GI_PRODALT == M->D4_CODA		// Se produto alternativo diferente do produto componente da estrutura
						_lRet := .T.
						GdFieldPut("D4_DESCA", fBuscaCpo("SB1", 1, xFilial("SB1") + M->D4_CODA, "B1_DESC"))
						Exit
					Else
						_lRet := .F.
					Endif
					DbSelectArea("SGI")
					DbSkip()
				Enddo

				If _lRet
					Exit
				Endif

				DbSelectArea("SG1")
				DbSkip()
			Enddo

			If !_lRet
				MsgAlert("Produto informado não e produto alternativo ou não esta cadastrado como produto alternativo. Informe novo produto alternativo.")
			Endif

		Endif

	Endif

Return(_lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} LINHAOK1
Funcao para validacao da linha
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
User Function LINHAOK1()
	_lRet := .T.

	If !GDDeleted()
		If Empty(GDFieldGet("D4_LOCAL")) .Or. Empty(GDFieldGet("D4_DATA")) .Or. GDFieldGet("D4_QTDEORI") == 0 .Or. GDFieldGet("D4_QUANT") == 0
			MsgAlert("Algum dos campos Armazém, DT Empenho, Qtd. Empenho ou Sal. Empenho não estão preenchidos. Verifique")
			_lRet = .F.
		Endif
	Endif

Return(_lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} TUDOOK1
Funcao para validacao de todas as linhas
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
User Function TUDOOK1()
	Local nX
	_lRet := .T.

	For nX:= 1 To Len(aCols)
		If !aCols[nX][Len(aHeader)+1]    // Trata Somente Itens Nao Deletados
			If Empty(GDFieldGet("D4_LOCAL",nX)) .Or. Empty(GDFieldGet("D4_DATA",nX)) .Or. GDFieldGet("D4_QTDEORI",nX) == 0 .Or. GDFieldGet("D4_QUANT",nX) == 0
				MsgAlert("Algum dos campos Armazém, DT Empenho, Qtd. Empenho ou Sal. Empenho não estão preenchidos na linha " + StrZero(nX,3,0) + ". Verifique")
				_lRet = .F.
			Endif
		Endif
	Next

Return(_lRet)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} _EMPEMB
Função que mostra listagem de OPs geradas para selecionar alteracao das embalagens com 
produtos alternativos
@Since      Jun/2021
/*/
//------------------------------------------------------------------------------------------
Static Function _EMPEMB()

	Local _lRet 	   := .T.
	Private oArqTrbPC  := Nil
	Private oBrowseQRY := Nil
	
	Processa({|| _lRet := CriaBrw(),"Selecionando registros ..."})

	oArqTrbPC:Delete()

Return(_lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaBrw
Cria browse filtrando registros da selecao da query
@Since      Jun/2021
/*/
//------------------------------------------------------------------------------------------
Static Function CriaBrw()

	Local lMarcar := .F.

	Processa({|| oArqTrbPC := CriaTRB()}, "Aguarde, carregando informações", "", .F.)

	oBrowseQRY := FWMarkBrowse():New()
	oBrowseQRY:SetAlias(oArqTrbPC:GetAlias())
	oBrowseQRY:SetDescription("Selecione OPs geradas para alteração das embalagens com produtos alternativos")
	oBrowseQRY:SetFieldMark("TAB_OK")
	oBrowseQRY:DisableDetails()
	oBrowseQRY:SetTemporary(.T.)
	oBrowseQRY:SetWalkThru(.F.)
	oBrowseQRY:SetIgnoreARotina(.T.)
	oBrowseQRY:SetMenuDef("")
	oBrowseQRY:oBrowse:SetFixedBrowse(.T.)
	oBrowseQRY:oBrowse:SetDBFFilter(.F.)
	oBrowseQRY:oBrowse:SetUseFilter(.F.)
	oBrowseQRY:oBrowse:SetFilterDefault("")
	oBrowseQRY:oBrowse:SetIgnoreARotina(.T.)
	oBrowseQRY:oBrowse:SetMenuDef("")

	oBrowseQRY:AddButton("Confirma", { ||((_lConfMrkBr := .T., _lConfMrkBr := Confirmar()))}, , 4 )
	oBrowseQRY:AddButton("Cancela",  { ||((_lConfMrkBr := .F., _lConfMrkBr := Cancelar()))}, , 2 )

	oBrowseQRY:bAllMark := { || CheckAll(oBrowseQRY:Mark() ,lMarcar := !lMarcar), oBrowseQRY:Refresh(.T.)}

	oBrowseQRY:SetColumns(AddCol("NUM",  	"Número OP"		, 2, "@N", 							0, 06, 0))
	oBrowseQRY:SetColumns(AddCol("ITEM",  	"Item"			, 3, "@9!", 						0, 02, 0))
	oBrowseQRY:SetColumns(AddCol("SEQUEN", 	"Sequência"  	, 4, "@9", 							0, 06, 0))
	oBrowseQRY:SetColumns(AddCol("EMISSAO", "Data Emissão"  , 5, "", 							0, 08, 0))
	oBrowseQRY:SetColumns(AddCol("PRODUTO", "Produto"  		, 6, "@!", 							1, 15, 0))
	oBrowseQRY:SetColumns(AddCol("DESCRI", 	"Descrição" 	, 7, "@!", 							1, 40, 0))
	oBrowseQRY:SetColumns(AddCol("ARMAZEM",	"Armazém" 		, 8, "@!", 							0, 02, 0))
	oBrowseQRY:SetColumns(AddCol("GRUPO", 	"Grupo Prod." 	, 9, "@!", 							0, 08, 0))
	oBrowseQRY:SetColumns(AddCol("UM", 		"Unid Medida" 	,10, "@!", 							0, 02, 0))
	oBrowseQRY:SetColumns(AddCol("QUANT", 	"Maior Compra" 	,11, "@E 9,999,999,999.9999999", 	0, 18, 7))

 	oBrowseQRY:Activate()

Return(_lConfMrkBr)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTRB
Cria arquivo de trabalho referente Query
@Since      Jun/2021
/*/
//------------------------------------------------------------------------------------------
Static Function CriaTRB()

	Local aCampos     := {}
	Local cAliasArea  := ""
	Local oTrb        := Nil
	Local x

    AADD(aCampos,{ "TAB_OK", 	"C", 2,		0 	} )
	AADD(aCampos,{ "NUM", 		"C", 6, 	0 	} )
	AADD(aCampos,{ "ITEM", 		"C", 2, 	0 	} )
	AADD(aCampos,{ "SEQUEN", 	"C", 6, 	0	} )
	AADD(aCampos,{ "EMISSAO", 	"D", 8, 	0	} )
	AADD(aCampos,{ "PRODUTO", 	"C", 15, 	0	} )
	AADD(aCampos,{ "DESCRI", 	"C", 40, 	0	} )
	AADD(aCampos,{ "ARMAZEM", 	"C", 2, 	0	} )
	AADD(aCampos,{ "GRUPO", 	"C", 8, 	0	} )
	AADD(aCampos,{ "UM", 		"C", 2, 	0	} )
	AADD(aCampos,{ "QUANT", 	"N", 18,	7	} )

	oTrb := FWTemporaryTable():New()
	oTrb:SetFields(aCampos)

	oTrb:AddIndex("IDX1", {"NUM"})

	oTrb:Create()
	cAliasArea := oTrb:GetAlias()

	// Grava o arquivo temporário com os registros da selecao da query
	For x:=1 To Len(_aDadosPA)

		RecLock((cAliasArea), .T.)
		(cAliasArea)->NUM     := _aDadosPA[x,1]
		(cAliasArea)->ITEM    := _aDadosPA[x,2]
		(cAliasArea)->SEQUEN  := _aDadosPA[x,3]
		(cAliasArea)->EMISSAO := _aDadosPA[x,4]
		(cAliasArea)->PRODUTO := _aDadosPA[x,5]
		(cAliasArea)->DESCRI  := fBuscaCpo("SB1", 1, xFilial("SB1") + _aDadosPA[x,5], "B1_DESC")
		(cAliasArea)->ARMAZEM := _aDadosPA[x,6]
		(cAliasArea)->GRUPO   := _aDadosPA[x,7]
		(cAliasArea)->UM      := _aDadosPA[x,8]
		(cAliasArea)->QUANT   := _aDadosPA[x,9]
		MsUnlock((cAliasArea))

	Next

Return(oTrb)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddCol
Adiciona uma coluna no Browse em tempo de execução
@Since      Jun/2021
/*/
//------------------------------------------------------------------------------------------
Static Function AddCol(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

	Local aColumn
	Local bData 	 := {||}
	Default nAlign 	 := 1
	Default nSize 	 := 20
	Default nDecimal := 0
	Default nArrData := 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}")
	EndIf

	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return({aColumn})


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckAll
Verifica marcação no browse
@Since      Jun/2021
/*/
//------------------------------------------------------------------------------------------
Static Function CheckAll(cMarca, lMarcar)

	Local cAliasTRB := oArqTrbPC:GetAlias()
	Local aAreaTRB  := (cAliasTRB)->(GetArea())
	Local cTAB_OK   := IIf(lMarcar, cMarca, '  ')

	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())

	While !(cAliasTRB)->(Eof())
		RecLock((cAliasTRB), .F.)
		(cAliasTRB)->TAB_OK := cTAB_OK
		MsUnlock()

		(cAliasTRB)->(dbSkip())
	EndDo

	RestArea(aAreaTRB)

Return(.T.)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Confirma
Confirmação dos dados do browse
@Since      Jun/2021
/*/
//------------------------------------------------------------------------------------------
Static Function Confirmar()

	Local cAliasBrw := oArqTrbPC:GetAlias()
	Local nFCount   := 0
	Local nX        := 0
	Local nY        := 0
	Local aLinha    := {}
	Local lRet      := .T.

	aRetOP  := {}
	nFCount := (cAliasBrw)->(FCount())

	(cAliasBrw)->(DbGoTop())

	While !((cAliasBrw)->(Eof()))
		If (!Empty((cAliasBrw)->(TAB_OK)))
			aLinha := {}
			For nX := 2 To nFCount
				AADD(aLinha, (cAliasBrw)->(FieldGet(nX)))
			End
			AADD(aRetOP, aLinha)
		EndIf
		(cAliasBrw)->(DbSkip())
	EndDo


	If (!Empty(aRetOP))
		For nY:=1 To Len(aRetOP)
			_AtuD4B2(aRetOP[nY,1] + aRetOP[nY,2] + aRetOP[nY,3])
		Next
	Endif

	CloseBrowse()

Return(lRet)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Cancelar
Cancelamento dos dados do browse
@Since      Jun/2021
/*/
//------------------------------------------------------------------------------------------
Static Function Cancelar()

	Local lRet := .F.

	MsgAlert("Cancelada a tela de seleção.")

	CloseBrowse()

Return(lRet)
