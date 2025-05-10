#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"

#DEFINE BR Chr(10)

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MGT_BLK1 
@Type			: Função de Usuário
@Sample			: U_MGT_BLK1()
@Description	: Rotina para geração das ordens de produção e apontamentos da produção
                  referente aos movimentos do abate conforme número do aviso de matança
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Revisão em Mai/2021 considerando situação atual para rodar em Jan/2022
/*/
//--------------------------------------------------------------------------------------
User Function MGT_BLK1()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| BLK1NewPerg ( oSelf ) }   
	Local cFunction    := "MGT_BLK1"
	Local cTitle	   := "Geração Dados Bloco K Referente Abate"
	Local cDescription := "Rotina responsável pela geração das ordens de produção e apontamentos da produção referente ao movimentos do abate conforme número do aviso de matança." + ;
						  "Para executar a geração das informações necessárias, informe os parâmetros necessários." + CRLF + CRLF + ; 
						  "Clique no botão abaixo e aguarde a conclusão do processamento."

	Private cPerg	   := "MGT_BLK1"

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
/*/{Protheus.doc} BLK1NewPerg
Tratamento para a utilização do tNewProcess
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK1NewPerg( oSelf )

	BLK1Proc(.F.,oSelf)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BLK1Proc
Função que efetua o processamento das informações
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK1Proc( lBat, oSelf )

	Local cIdCV8 := ""
	Local nT

	// Valida data de processamento com data base do sistema
	If mv_par01 <> dDataBase
		Aviso("PROCESSAMENTO BLOCO K - ABATE", "Data do processamento DIFERENTE da data base do sistema." + CRLF + CRLF + ;
			  "Processamento não será executado. Favor ajustar datas!",{"Ok"},2)
		Return
	Endif

	ProcLogIni({},FunName(),,@cIdCV8)
	ProcLogAtu("INICIO","Rotina Chamadora: "+ FunName() + " " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()) ,,,.T.)

	// Se for processamento Abate/Terceiros ou Só Abate
	If mv_par04 == 1 .Or. mv_par04 == 2
		// Verifica se existe aviso de matança para data informada
		DbSelectArea("SZG")
		DbSetOrder(2)
		If !DbSeek(xFilial("SZG") + Dtos(mv_par01) + mv_par02)
			Aviso("PROCESSAMENTO BLOCO K - ABATE", "Não existe aviso de matança para data de processamento informada." + CRLF + CRLF + ;
				"Processamento não será executado. Favor Verificar!",{"Ok"},2)
			Return
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 															³
		//³ PROCESSAMENTO DE ABATE PRÓPRIO DO FRIGSILVA					³
		//³ 															³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lMSErroAuto := .T.
		_FlagIncMP  := .F.
		_FlagIncOP  := .F.
		_FlagMovPD  := .F.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula total de registros a serem processados corretamente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT COUNT( ZAJ.R_E_C_N_O_ ) TOTREG "
		cQuery += "  FROM " + RetSQLTab("ZAJ") + "," + RetSQLTab("SZK") + "," + RetSQLTab("SZ5") + "," + RetSQLTab("SZG") + "," + RetSQLTab("SB1")
		cQuery += " WHERE " + RetSQLFil("ZAJ") + " AND " + RetSQLFil("SZK") + " AND " + RetSQLFil("SZ5") + " AND " + RetSQLFil("SZG") + " AND " + RetSQLFil("SB1")
		cQuery += "   AND ZAJ_CONTRO = ZK_CONTROL "
		cQuery += "   AND ZAJ_LOTE = ZK_LOTE "
		cQuery += "   AND ZAJ_NUMAM = ZK_NUMAM "
		cQuery += "   AND ZAJ_NUMAM = ZG_NUMAM "
		cQuery += "   AND ZAJ_COD = B1_COD "
		//cQuery += "   AND ZAJ_DTEXE1 = ''"
		cQuery += "   AND ZK_CATEG = Z5_COD "
		cQuery += "   AND ZG_NUMAM = '" + mv_par02 + "'"
		cQuery += "   AND B1_GRUPO = '4001'"
		cQuery += "   AND " + RetSQLDel("ZAJ") + " AND " + RetSQLDel("SZK") + " AND " + RetSQLDel("SZ5") + " AND " + RetSQLDel("SZG") + " AND " + RetSQLDel("SB1")

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTOT",.T.,.T.)

		oSelf:SetRegua1(TRBTOT->TOTREG)
		oSelf:SetRegua2(TRBTOT->TOTREG)

		TRBTOT->( DbCloseArea() )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processamento dos Dados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Seleção dos movimentos do abate (ZAJ)
		cQuery := "SELECT ZAJ_NUMAM, Z5_PRODUTO, COUNT(ZAJ_NUM) / 6 AS QTDEPROD, SUM(ZAJ_PESOES) AS PESOTOT "
		cQuery += "  FROM " + RetSQLTab("ZAJ") + "," + RetSQLTab("SZK") + "," + RetSQLTab("SZ5") + "," + RetSQLTab("SZG") + "," + RetSQLTab("SB1")
		cQuery += " WHERE " + RetSQLFil("ZAJ") + " AND " + RetSQLFil("SZK") + " AND " + RetSQLFil("SZ5") + " AND " + RetSQLFil("SZG") + " AND " + RetSQLFil("SB1")
		cQuery += "   AND ZAJ_CONTRO = ZK_CONTROL "
		cQuery += "   AND ZAJ_LOTE = ZK_LOTE "
		cQuery += "   AND ZAJ_NUMAM = ZK_NUMAM "
		cQuery += "   AND ZAJ_NUMAM = ZG_NUMAM "
		cQuery += "   AND ZAJ_COD = B1_COD "
		//cQuery += "   AND ZAJ_DTEXE1 = ''"
		cQuery += "   AND ZK_CATEG = Z5_COD "
		cQuery += "   AND ZG_NUMAM = '" + mv_par02 + "'"
		cQuery += "   AND B1_GRUPO = '4001'"
		cQuery += "   AND " + RetSQLDel("ZAJ") + " AND " + RetSQLDel("SZK") + " AND " + RetSQLDel("SZ5") + " AND " + RetSQLDel("SZG") + " AND " + RetSQLDel("SB1")
		cQuery += " GROUP BY ZAJ_NUMAM, Z5_PRODUTO "
		cQuery += " ORDER BY ZAJ_NUMAM, Z5_PRODUTO "

		cQuery := ChangeQuery(cQuery)

		ProcLogAtu("MENSAGEM", "Seleção dos movimentos do abate (ZAJ) Aviso: " + Alltrim(mv_par02) + " " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery)

		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .F., .T.)

		// Vetor para armazenar os codigos de MPs e suas quantidades
		_aMP := {}
		_nPesTot := 0

		// Vetor para realizar transferência de MPs de boi, vaca e touro para Bovinos
		_aTransf := {}

		TRB->(dbGoTop())
		While TRB->(!Eof())

			oSelf:IncRegua1("Selecionando os movimentos do abate ...")
			oSelf:IncRegua2()

			Pergunte(cPerg,.F.)

			_cNumam   := TRB->ZAJ_NUMAM
			_cLoteCTL := "P" + TRB->ZAJ_NUMAM + Dtos(mv_par01)
			_cProduto := TRB->Z5_PRODUTO
			_cDescPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
			_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
			_nQuant   := TRB->QTDEPROD
			_nPesoTot := TRB->PESOTOT / (mv_par03/100)
			_cNumDoc  := NextNumero("SD3",2,"D3_DOC",.T.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava SD3 (inclusão de MP em estoque)                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_aVetor := {}

			AADD(_aVetor, {"D3_TM" 		, "007"      			,NIL})
			AADD(_aVetor, {"D3_DOC" 	, _cNumDoc    			,NIL})
			AADD(_aVetor, {"D3_CC" 		, "1131001"   			,NIL})
			AADD(_aVetor, {"D3_EMISSAO" , ddatabase	  			,NIL})
			AADD(_aVetor, {"D3_COD" 	, _cProduto				,NIL})
			AADD(_aVetor, {"D3_UM" 		, "KG"					,NIL})
			AADD(_aVetor, {"D3_QUANT" 	, _nPesoTot				,NIL})
			AADD(_aVetor, {"D3_SEGUM" 	, "PC"					,NIL})
			AADD(_aVetor, {"D3_QTSEGUM" , _nQuant				,NIL})
			AADD(_aVetor, {"D3_LOCAL" 	, "01"           		,NIL})
			AADD(_aVetor, {"D3_FLOTE" 	, _cLoteCTL		   		,NIL})
			AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())   	,NIL})

			_nPesTot := _nPesTot + TRB->PESOTOT
	
			AADD( _aTransf, {_cProduto , _nPesoTot , _nQuant , _cLoteCTL})

			// Executa entrada de MP via rotina automatica
			If Len(_aVetor) > 0
				lMSErroAuto := .F.
				DbSelectArea("SD3")
				Begin Transaction
					MSExecAuto({|x,y| MATA240(x,y)},_aVetor,3)
					If lMSErroAuto
						ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE ENTRADA DE MP ==> " + _cNumDoc + " PARA PRODUTO " + Alltrim(_cProduto) + " D3_TM = 007")
						MsgAlert("Houve erro na geração da produção do SD3 ExecAuto MATA240 TM 007. Verifique na tela seguinte.", ProcName())
						MostraErro()
						DisarmTransaction()
						_FlagIncMP := .F.
					Else
						ProcLogAtu("MENSAGEM", "GERADO SD3 DE ENTRADA DE MP ==> " + _cNumDoc + " PARA PRODUTO " + Alltrim(_cProduto) + " D3_TM = 007")
						_FlagIncMP := .T.
					Endif
				End Transaction
			Else
				ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE ENTRADA DE MP ==> " + _cNumDoc + " PARA PRODUTO " + Alltrim(_cProduto) + " D3_TM = 007")
				_FlagIncMP := .F.
			Endif

			TRB->(DbSkip())

		Enddo

		_lOk1 := !lMSErroAuto

		TRB->(DbCloseArea())

		AADD( _aMP , {PADR("021787", TamSX3("B1_COD") [1]) , _nPesTot})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SD3 (tranferências para Bovinos)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lMsErroAuto := .F.
		aAuto := {}
		
		// Cabecalho a Incluir
		AADD(aAuto, {NextNumero("SD3",2,"D3_DOC",.T.), ddatabase})

		For nT := 1 To Len(_aTransf)
			aLinha := {}
			_cCodOrig := _aTransf[nT, 1]
			_cCodDest := PADR("021787", TamSX3("D3_COD") [1])
			
			// Origem 
			SB1->(DbSeek(xFilial("SB1") +_cCodOrig ))
			AADD(aLinha,{"ITEM"		 ,  "00" + cValToChar(nT)		, Nil})
			AADD(aLinha,{"D3_COD"	 , 	_cCodOrig					, Nil}) 	// Código produto origem 
			AADD(aLinha,{"D3_DESCRI" , 	SB1->B1_DESC				, Nil}) 	// Descr. produto origem 
			AADD(aLinha,{"D3_UM"	 , 	"KG"						, Nil}) 	// Unidade medida origem 
			AADD(aLinha,{"D3_LOCAL"	 , 	"01"						, Nil}) 	// Armazem origem 
			AADD(aLinha,{"D3_LOCALIZ", 	CriaVar("D3_LOCALIZ")		, Nil}) 	// Endereço origem

			// Destino 
			SB1->(DbSeek(xFilial("SB1") + _cCodDest ))
			AADD(aLinha,{"D3_COD"	 , 	_cCodDest					, Nil}) 	// Código produto destino 
			AADD(aLinha,{"D3_DESCRI" , 	SB1->B1_DESC				, Nil}) 	// Descr. produto destino 
			AADD(aLinha,{"D3_UM"	 , 	"KG"						, Nil}) 	// Unidade medida destino 
			AADD(aLinha,{"D3_LOCAL"	 , 	"01"						, Nil}) 	// Armazem destino 
			AADD(aLinha,{"D3_LOCALIZ", 	CriaVar("D3_LOCALIZ")		, Nil}) 	// Endereço destino
			AADD(aLinha,{"D3_NUMSERI", 	CriaVar("D3_NUMSERI")		, Nil}) 	// Número serie
			AADD(aLinha,{"D3_LOTECTL", 	CriaVar("D3_LOTECTL")		, Nil}) 	// Lote Origem
			AADD(aLinha,{"D3_NUMLOTE", 	CriaVar("D3_NUMLOTE")		, Nil}) 	// Sublote origem
			AADD(aLinha,{"D3_DTVALID", 	CriaVar("D3_DTVALID")		, Nil}) 	// Data validade 
			AADD(aLinha,{"D3_POTENCI", 	CriaVar("D3_POTENCI")		, Nil}) 	// Potencia
			AADD(aLinha,{"D3_QUANT"	 , 	_aTransf[nT, 2]				, Nil}) 	// Quantidade
			AADD(aLinha,{"D3_QTSEGUM", 	_aTransf[nT, 3]				, Nil}) 	// Seg. unidade medida
			AADD(aLinha,{"D3_ESTORNO", 	CriaVar("D3_ESTORNO")		, Nil}) 	// Estorno 
			AADD(aLinha,{"D3_NUMSEQ" , 	CriaVar("D3_NUMSEQ")		, Nil}) 	// Numero sequencia D3_NUMSEQ
			AADD(aLinha,{"D3_LOTECTL", 	CriaVar("D3_LOTECTL")		, Nil}) 	// Lote destino
			AADD(aLinha,{"D3_NUMLOTE", 	CriaVar("D3_NUMLOTE")		, Nil}) 	// Sublote destino 
			AADD(aLinha,{"D3_DTVALID", 	CriaVar("D3_DTVALID")		, Nil}) 	// Validade lote destino
			AADD(aLinha,{"D3_ITEMGRD", 	CriaVar("D3_ITEMGRD")		, Nil}) 	// Item Grade
			AADD(aLinha,{"D3_CODLAN" , 	""							, Nil}) 	// Cat83 Prod Origem
			AADD(aLinha,{"D3_CODLAN" , 	""							, Nil}) 	// Cat83 Prod Destino 

			AADD(aAuto,aLinha)
		Next nT

		MSExecAuto({|x,y| MATA261(x,y)}, aAuto, 3)		// Inclusão

		If lMsErroAuto 
			MostraErro()
		EndIf

		Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

		If _lOk1
			cQuery := "SELECT COUNT(ZAJ_NUM) / 6 AS QTDEPROD, SUM(ZAJ_PESOES) AS PESOTOT "
			cQuery += "  FROM " + RetSQLTab("ZAJ") + "," + RetSQLTab("SZK") + "," + RetSQLTab("SZ5") + "," + RetSQLTab("SZG") + "," + RetSQLTab("SB1")
			cQuery += " WHERE " + RetSQLFil("ZAJ") + " AND " + RetSQLFil("SZK") + " AND " + RetSQLFil("SZ5") + " AND " + RetSQLFil("SZG") + " AND " + RetSQLFil("SB1")
			cQuery += "   AND ZAJ_CONTRO = ZK_CONTROL "
			cQuery += "   AND ZAJ_LOTE = ZK_LOTE "
			cQuery += "   AND ZAJ_NUMAM = ZK_NUMAM "
			cQuery += "   AND ZAJ_NUMAM = ZG_NUMAM "
			cQuery += "   AND ZAJ_COD = B1_COD "
			//cQuery += "   AND ZAJ_DTEXE1 = ''"
			cQuery += "   AND ZK_CATEG = Z5_COD
			cQuery += "   AND ZG_NUMAM = '" + mv_par02 + "'"
			cQuery += "   AND B1_GRUPO = '4001'"
			cQuery += "   AND " + RetSQLDel("ZAJ") + " AND " + RetSQLDel("SZK") + " AND " + RetSQLDel("SZ5") + " AND " + RetSQLDel("SZG") + " AND " + RetSQLDel("SB1")

			cQuery := ChangeQuery(cQuery)

			DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .F., .T.)

			TRB->(dbGoTop())
			While TRB->(!Eof())

				oSelf:IncRegua1("Gerando ordens de produção do abate ...")
				oSelf:IncRegua2()

				Pergunte(cPerg,.F.)

				_nPercRend := mv_par03
				_cDescPrd  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
				_cUnidMed  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
				_nQtdSeg   := TRB->QTDEPROD
				_nPesoTot  := TRB->PESOTOT
				_cNumam    := mv_par02
				_cLoteCTL  := "P" + mv_par02 + Dtos(mv_par01)
				_dDataProd := mv_par01
				_cNumOp    := GetSX8Num("SC2","C2_NUM")
				
				ConfirmSX8()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava SC2 (ordens de produção)                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_aAutoSC2 := {}

				AADD(_aAutoSC2, {"AUTEXPLODE", "S"    						   	, NIL})
				AADD(_aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 	, NIL})
				AADD(_aAutoSC2, {"C2_NUM"    , _cNumOp                        	, NIL})
				AADD(_aAutoSC2, {"C2_ITEM"   , "01"                           	, NIL})
				AADD(_aAutoSC2, {"C2_SEQUEN" , "001"                    		, NIL})
				AADD(_aAutoSC2, {"C2_PRODUTO", "005013         "              	, NIL})
				AADD(_aAutoSC2, {"C2_LOCAL"  , "01"                           	, NIL})
				AADD(_aAutoSC2, {"C2_CC"     , "1131002"                  		, NIL})	// Abate
				AADD(_aAutoSC2, {"C2_QUANT"  , _nPesoTot                  		, NIL})
				AADD(_aAutoSC2, {"C2_DATPRI" , ddatabase                 		, NIL})
				AADD(_aAutoSC2, {"C2_DATPRF" , ddatabase                 		, NIL})
				AADD(_aAutoSC2, {"C2_EMISSAO", ddatabase                 		, NIL})
				AADD(_aAutoSC2, {"C2_STATUS" , "N"                      		, NIL})
				AADD(_aAutoSC2, {"C2_TPOP"   , "F"                      		, NIL})
				AADD(_aAutoSC2, {"C2_GRUPO"  , "4001"                    		, NIL})
				AADD(_aAutoSC2, {"C2_NUMAM"  , _cNumam                   		, NIL})
				AADD(_aAutoSC2, {"C2_FLOTE"  , _cLoteCTL                  		, NIL})
				AADD(_aAutoSC2, {"C2_UM"     , "KG"                       		, NIL})
				AADD(_aAutoSC2, {"C2_SEGUM"  , "PC"                     		, NIL})
				AADD(_aAutoSC2, {"C2_QTSEGUM", _nQtdSeg * 2               		, NIL})

				// Executa geração de OP via rotina automatica
				If Len(_aAutoSC2) > 0
					lMSErroAuto := .F.
					DbSelectArea("SC2")
					Begin Transaction
						MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, 3)
						If lMSErroAuto
							ProcLogAtu("ERRO", "ERRO GERACAO - OP NUMERO ==> " + _cNumOp + " PARA PRODUTO 005013 Aviso de Matanca " + _cNumam)
							MsgAlert("Houve erro na geração da Ordem de Produção na SC2. Verifique na tela seguinte.", ProcName())
							MostraErro()
							DisarmTransaction()
							_FlagIncOP := .F.
						Else
							ProcLogAtu("MENSAGEM", "GERADO OP NUMERO ==> " + _cNumOp + " PARA PRODUTO 005013 Aviso de Matanca " + _cNumam)
							_FlagIncOP := .T.
						Endif
					End Transaction
				Else
					ProcLogAtu("MENSAGEM", "NAO FOI GERADO OP NUMERO ==> " + _cNumOp + " PARA PRODUTO 005013 Aviso de Matanca " + _cNumam)
					_FlagIncOP := .F.
				Endif

				// Função para produção de PPs de subprodutos
				If _FlagIncOP
					ProcSubProds(_aMP, _cNumOp + "01001")
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava SD3 (movimentos de produção)                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SD3")
				_aVetor := {}
				AADD(_aVetor, {"D3_OP" 		, _cNumOp + "01001"			 	 		,NIL})
				AADD(_aVetor, {"D3_TM" 		, "004"            						,NIL})
				AADD(_aVetor, {"D3_EMISSAO" , ddatabase  					    	,NIL})
				AADD(_aVetor, {"D3_COD" 	, "005013"								,NIL})
				AADD(_aVetor, {"D3_UM" 		, "KG"									,NIL})
				AADD(_aVetor, {"D3_QUANT" 	, _nPesoTot								,NIL})
				AADD(_aVetor, {"D3_SEGUM" 	, "PC"									,NIL})
				AADD(_aVetor, {"D3_QTSEGUM" , _nQtdSeg * 2   						,NIL})
				AADD(_aVetor, {"D3_DOC" 	, NextNumero("SD3",2,"D3_DOC",.T.) 		,NIL})
				AADD(_aVetor, {"D3_LOCAL" 	, "01"           						,NIL})
				AADD(_aVetor, {"D3_FLOTE" 	, _cLoteCTL         					,NIL})
				AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())   					,NIL})

				// Executa movimentacao de produção via rotina automatica
				If Len(_aVetor) > 0
					lMSErroAuto := .F.
					DbSelectArea("SD3")
					Begin Transaction
						MSExecAuto({|x,y| mata250(x,y)}, _aVetor, 3)
						If lMSErroAuto
							ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE PRODUCAO ==> " + _cNumOp + "01001 PARA PRODUTO 005013 D3_TM = 004")
							MsgAlert("Houve erro na geração da produção do SD3 ExecAuto MATA250 TM 004. Verifique na tela seguinte.", ProcName())
							MostraErro()
							DisarmTransaction()
							_FlagMovPD := .F.
						Else
							ProcLogAtu("MENSAGEM", "GERADO SD3 DE PRODUCAO ==> " + _cNumOp + "01001 PARA PRODUTO 005013 D3_TM = 004")
							_FlagMovPD := .T.
						Endif
					End Transaction
				Else
					ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE PRODUCAO ==> " + _cNumOp + "01001 PARA PRODUTO 005013 D3_TM = 004")
					_FlagMovPD := .F.
				Endif

				TRB->(DbSkip())
			Enddo

			TRB->(DbCloseArea())

		Endif

		Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

		// Verifica se todos os processos de inclusão de MP, inclusão das OPs e realização dos movimentos de produção
		// foram executados com sucesso e grava o flag de data da fase 1 - abate (ZAJ_DTEXE1)
		If _FlagIncMP .And. _FlagIncOP .And. _FlagMovPD
			/*
			cQueryUPD := "UPDATE " + RetSQLName("ZAJ")
			cQueryUPD += "   SET ZAJ_DTEXE1 = '" + Dtos(DDATABASE) + "'"
			cQueryUPD += "  FROM " + RetSQLTab("ZAJ") + "," + RetSQLTab("SZK") + "," + RetSQLTab("SZ5") + "," + RetSQLTab("SZG") + "," + RetSQLTab("SB1")
			cQueryUPD += " WHERE " + RetSQLFil("ZAJ") + " AND " + RetSQLFil("SZK") + " AND " + RetSQLFil("SZ5") + " AND " + RetSQLFil("SZG") + " AND " + RetSQLFil("SB1")
			cQueryUPD += "   AND ZAJ_CONTRO = ZK_CONTROL "
			cQueryUPD += "   AND ZAJ_LOTE = ZK_LOTE "
			cQueryUPD += "   AND ZAJ_NUMAM = ZK_NUMAM "
			cQueryUPD += "   AND ZAJ_NUMAM = ZG_NUMAM "
			cQueryUPD += "   AND ZAJ_COD = B1_COD "
			cQueryUPD += "   AND ZK_CATEG = Z5_COD "
			cQueryUPD += "   AND ZG_NUMAM = '" + mv_par02 + "'"
			cQueryUPD += "   AND B1_GRUPO = '4001'"
			cQueryUPD += "   AND ZAJ.D_E_L_E_T_ = ''"
			cQueryUPD += "   AND SZK.D_E_L_E_T_ = ''"
			cQueryUPD += "   AND SZ5.D_E_L_E_T_ = ''"
			cQueryUPD += "   AND SZG.D_E_L_E_T_ = ''"
			cQueryUPD += "   AND SB1.D_E_L_E_T_ = ''"

			If TCSQLExec(cQueryUPD) < 0
				ProcLogAtu("ERRO", "ERRO NO UPDATE DE PROCESSAMENTO da ZAJ ABATE: ", TCSQLError())
				MsgStop("TCSQLError() ABATE " + TCSQLError())
			Else
				ProcLogAtu("MENSAGEM", "Geração dados bloco K referente abate na data de " + Dtoc(mv_par01) + " finalizado com sucesso.")
				MsgAlert("Geração dados bloco K referente abate na data de " + Dtoc(mv_par01) + " finalizado com sucesso.")
			EndIf
			*/
		Else
			ProcLogAtu("MENSAGEM", "Não houve processamento a ser realizado para data de " + Dtoc(mv_par01) + " ou processamento nesta data já realizado.")
			MsgAlert("Não houve processamento a ser realizado para data de " + Dtoc(mv_par01) + " ou processamento nesta data já realizado.")
		Endif
	Endif

	// Se for processamento Abate/Terceiros ou Só Terceiros
	If mv_par04 == 1 .Or. mv_par04 == 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 															³
		//³ PROCESSAMENTO DE ABATE DE MP DE TERCEIROS					³
		//³ 															³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lMSErroAuto := .T.
		_FlagIncMP  := .F.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula total de registros a serem processados corretamente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT COUNT( ZAJ.R_E_C_N_O_ ) TOTREG "
		cQuery += "  FROM " + RetSQLTab("ZAJ") + "," + RetSQLTab("SB1")
		cQuery += " WHERE " + RetSQLFil("ZAJ") + " AND " + RetSQLFil("SB1")
		cQuery += "   AND ZAJ_NUMAM = '' "
		cQuery += "   AND ZAJ_DATA = '" + Dtos(mv_par01) + "'"
		//cQuery += "   AND ZAJ_DTEXE1 = ''"
		cQuery += "   AND ZAJ_COD = B1_COD "
		cQuery += "   AND B1_TIPO = 'MP'"
		cQuery += "   AND B1_SEGUM = 'PC'"
		cQuery += "   AND B1_GRUPO = '1002'"
		cQuery += "   AND " + RetSQLDel("ZAJ") + " AND " + RetSQLDel("SB1")

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTOT",.T.,.T.)

		oSelf:SetRegua1(TRBTOT->TOTREG)
		oSelf:SetRegua2(TRBTOT->TOTREG)

		TRBTOT->( DbCloseArea() )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processamento dos Dados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Seleção dos movimentos de terceiros (ZAJ)
		cQuery := "SELECT ZAJ_ZAPNUM, B1_COD, COUNT(ZAJ_NUM) / 6 AS QTDEPROD, SUM(ZAJ_PESOES) AS PESOTOT "
		cQuery += "  FROM " + RetSQLTab("ZAJ") + "," + RetSQLTab("SB1")
		cQuery += " WHERE " + RetSQLFil("ZAJ") + " AND " + RetSQLFil("SB1")
		cQuery += "   AND ZAJ_NUMAM = '' "
		cQuery += "   AND ZAJ_DATA = '" + Dtos(mv_par01) + "'"
		//cQuery += "   AND ZAJ_DTEXE1 = ''"
		cQuery += "   AND ZAJ_COD = B1_COD "
		cQuery += "   AND B1_TIPO = 'MP'"
		cQuery += "   AND B1_SEGUM = 'PC'"
		cQuery += "   AND B1_GRUPO = '1002'"
		cQuery += "   AND " + RetSQLDel("ZAJ") + " AND " + RetSQLDel("SB1")
		cQuery += " GROUP BY ZAJ_ZAPNUM, B1_COD "
		cQuery += " ORDER BY ZAJ_ZAPNUM, B1_COD "

		cQuery := ChangeQuery(cQuery)

		ProcLogAtu("MENSAGEM", "Seleção dos movimentos de TERCEIROS (ZAJ) Data: " + Alltrim(Dtoc(mv_par01)) + " " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQuery)

		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .F., .T.)

		TRB->(dbGoTop())
		While TRB->(!Eof())

			oSelf:IncRegua1("Selecionando os movimentos de terceiros ...")
			oSelf:IncRegua2()

			Pergunte(cPerg,.F.)

			_cNumcer  := TRB->ZAJ_ZAPNUM
			_cProduto := TRB->B1_COD
			_cLoteCTL := "T" + _cNumcer + Dtos(mv_par01)
			_cDescPrd := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_DESC")
			_cUnidMed := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
			_nQuant   := TRB->QTDEPROD
			_nPesoTot := TRB->PESOTOT
			_cNumDoc  := NextNumero("SD3",2,"D3_DOC",.T.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava SD3 (inclusão de MP em estoque)                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_aVetor := {}

			AADD(_aVetor, {"D3_TM" 		, "007"      			,NIL})
			AADD(_aVetor, {"D3_DOC" 	, _cNumDoc    			,NIL})
			AADD(_aVetor, {"D3_CC" 		, "1131001"   			,NIL})
			AADD(_aVetor, {"D3_EMISSAO" , ddatabase	  			,NIL})
			AADD(_aVetor, {"D3_COD" 	, _cProduto				,NIL})
			AADD(_aVetor, {"D3_UM" 		, "KG"					,NIL})
			AADD(_aVetor, {"D3_QUANT" 	, _nPesoTot				,NIL})
			AADD(_aVetor, {"D3_SEGUM" 	, "PC"					,NIL})
			AADD(_aVetor, {"D3_QTSEGUM" , _nQuant				,NIL})
			AADD(_aVetor, {"D3_LOCAL" 	, "01"           		,NIL})
			AADD(_aVetor, {"D3_FLOTE" 	, _cLoteCTL 	 		,NIL})
			AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())   	,NIL})

			// Executa entrada de MP via rotina automatica
			If Len(_aVetor) > 0
				lMSErroAuto := .F.
				DbSelectArea("SD3")
				Begin Transaction
					MSExecAuto({|x,y| MATA240(x,y)},_aVetor,3)
					If lMSErroAuto
						ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE ENTRADA DE MP TERCEIROS ==> " + _cNumDoc + " PARA PRODUTO " + Alltrim(_cProduto) + " D3_TM = 007")
						MsgAlert("Houve erro na geração da produção do SD3 TERCEIROS ExecAuto MATA240 TM 007. Verifique na tela seguinte.", ProcName())
						MostraErro()
						DisarmTransaction()
						_FlagIncMP := .F.
					Else
						ProcLogAtu("MENSAGEM", "GERADO SD3 DE ENTRADA DE MP TERCEIROS ==> " + _cNumDoc + " PARA PRODUTO " + Alltrim(_cProduto) + " D3_TM = 007")
						_FlagIncMP := .T.
					Endif
				End Transaction
			Else
				ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE ENTRADA DE MP TERCEIROS ==> " + _cNumDoc + " PARA PRODUTO " + Alltrim(_cProduto) + " D3_TM = 007")
				_FlagIncMP := .F.
			Endif

			TRB->(DbSkip())

		Enddo

		Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

		// Verifica se o processo de TERCEIROS, inclusão de MP
		// foi executado com sucesso e grava o flag de data da fase 1 - abate (ZAJ_DTEXE1)
		If _FlagIncMP
			/*
			cQueryUPD := "UPDATE " + RetSQLName("ZAJ")
			cQueryUPD += "   SET ZAJ_DTEXE1 = '" + Dtos(DDATABASE) + "'"
			cQueryUPD += "  FROM " + RetSQLTab("ZAJ") + "," + RetSQLTab("SB1")
			cQueryUPD += " WHERE " + RetSQLFil("ZAJ") + " AND " + RetSQLFil("SB1")
			cQueryUPD += "   AND ZAJ_NUMAM = '' "
			cQueryUPD += "   AND ZAJ_DATA = '" + Dtos(mv_par01) + "'"
			cQueryUPD += "   AND ZAJ_DTEXE1 = ''"
			cQueryUPD += "   AND ZAJ_COD = B1_COD "
			cQueryUPD += "   AND B1_TIPO = 'MP'"
			cQueryUPD += "   AND B1_SEGUM = 'PC'"
			cQueryUPD += "   AND B1_GRUPO = '1002'"
			cQueryUPD += "   AND ZAJ.D_E_L_E_T_ = ''"
			cQueryUPD += "   AND SB1.D_E_L_E_T_ = ''"

			If TCSQLExec(cQueryUPD) < 0
				ProcLogAtu("ERRO", "ERRO NO UPDATE DE PROCESSAMENTO da ZAJ TERCEIROS: ", TCSQLError())
				MsgStop("TCSQLError() TERCEIROS" + TCSQLError())
			Else
				ProcLogAtu("MENSAGEM", "Geração dados bloco K referente TERCEIROS na data de " + Dtoc(mv_par01) + " finalizado com sucesso.")
				MsgAlert("Geração dados bloco K referente TERCEIROS na data de " + Dtoc(mv_par01) + " finalizado com sucesso.")
			EndIf
			*/
		Else
			ProcLogAtu("MENSAGEM", "Não houve processamento TERCEIROS a ser realizado para data de " + Dtoc(mv_par01) + " ou processamento nesta data já realizado.")
			MsgAlert("Não houve processamento TERCEIROS a ser realizado para data de " + Dtoc(mv_par01) + " ou processamento nesta data já realizado.")
		Endif
	Endif
	
	ProcLogAtu("FIM","Rotina Chamadora: "+ FunName() + " " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()) ,,,.T.)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSubProds
Função para produção de subprodutos
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function ProcSubProds(_aMP, _cOP)

	Local aSize1     := MsAdvSize()
	Local nTop       := 23
	Local nLeft      := 5
	Local nBottom    := aSize1[6]
	Local nRight     := aSize1[5]
	Local nLinaMais  := 0
	Local cButton1   := "QPushButton {" ;
									+ BR + " background: #FF8C00;";							 	// Cor do fundo
									+ BR + " border: 1px solid #096A82;";						// Cor da borda
									+ BR + " outline:0;";
									+ BR + " border-radius: 5px;"; 								// Arrerondamento da borda
									+ BR + " font: normal 15px Arial Black;"; 
									+ BR + " padding: 6px;";
									+ BR + " color: #000000;";									// Cor da fonte
									+ BR + " }";
									+ BR + " QPushButton:pressed {";							// Ações quando pressionado botão
									+ BR + " background-color: #FF8C00;border-style: inset;"; 
									+ BR + " border-color: #FF8C00;";
									+ BR + " color: #000000;";
									+ BR + " }"
	Local _lOkS 	  := .F.
	Local i

	Private _nQtdTot  := 0
	Private _nPerTot  := 0
	Private _nQtdPA   := 0
	Private _nQtdDesp := 0
	Private aBrowse   := {}
	Private _oFont    := tFont():New("Arial",,-18,,.T.,,,,)

	aObjects := {}
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           :=aPosObj[1]
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	// Calculo da quantidade total a ser produzida
	For i := 1 To Len(_aMP)
		_nQtdTot += _aMP[i,2]
	Next

	_cQtdPA   := ""
	_cQtdDesp := ""
	_cPerTot  := ""
	_cQtdTot  := "Peso p/ Rateio (Kg): " + AllTrim(Transform(_nQtdTot,"@E 999,999,999.9999999"))

	aHead     := {"Codigo","Descrição","% SubProduto","Qtde (Kg)","Qtde PA (Kg)"}
	aLargCol  := {30      ,150        ,50            ,50         ,50            }

	nTop    -= nLinAmais
	nBottom += nLinAmais

	DEFINE DIALOG oDlg TITLE "Consulta de Estoque de PA" FROM aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] PIXEL

	// Cria Browse
	oBrowse := TCBrowse():New(55+nLinAmais, 005, (nRight-nLeft-20)/2, ((nBottom-nTop-150)/2)-(nLinaMais*1.5),,aHead,aLargCol,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	_oSay0 := TSay():New(005,005, {|| _cQtdTot},  oDlg,, _oFont,,,, .T.,CLR_HBLUE,, 250, 40)
	_oSay1 := TSay():New(020,005, {|| _cQtdPA},   oDlg,, _oFont,,,, .T.,CLR_HBLUE,, 250, 40)
	_oSay2 := TSay():New(005,190, {|| _cQtdDesp}, oDlg,, _oFont,,,, .T.,CLR_GREEN,, 250, 40)
	_oSay3 := TSay():New(020,190, {|| _cPerTot},  oDlg,, _oFont,,,, .T.,CLR_GREEN,, 250, 40)

	AtuBrow()

	oButton1:=TButton():New( 010,400, "Confirmar"  , oDlg,{||_lOks := .T. , oDlg:End()},65,16,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton1:SetCss(cButton1)
	oButton2:=TButton():New( 028,400, "Fechar"     , oDlg,{||_lOks := .F. , oDlg:End()},65,16,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton2:SetCss(cButton1)

	ACTIVATE DIALOG oDlg CENTERED

	If _lOkS
		ProdSub(_aMP, _cOP)
	Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AtuBrow
Função para atualização do browse
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function AtuBrow()

	Montabr()

	oBrowse:SetArray(aBrowse)

	// Monta a linha a ser exibina no Browse
	oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],;
						 aBrowse[oBrowse:nAt,02],;
						 Transform(aBrowse[oBrowse:nAt,03],"@E 99.999999"),;
						 Transform(aBrowse[oBrowse:nAt,04],"@E 999,999,999.999999"),;
						 Transform(aBrowse[oBrowse:nAt,05],"@E 999,999,999.999999")}}

	oBrowse:nScrollType := 1

	oBrowse:bLDblClick  := {|| AltQtd()}

	_cQtdPA   := "Qtde PA Prod. (Kg): " + Alltrim(Transform(_nQtdPA, "@E 999,999,999,999.9999999"))
	_cQtdDesp := "Qtde Desp. (Kg): " + Alltrim(Transform(_nQtdDesp, "@E 999,999,999,999.9999999"))
	_cPerTot  := "Total p/ Rateio (%): " + Alltrim(Transform(_nPerTot,"@E 999.99"))

	_oSay1:SetText(_cQtdPA)
	_oSay2:SetText(_cQtdDesp)
	_oSay3:SetText(_cPerTot)

	oBrowse:DrawSelect()
	oBrowse:Refresh()

	oDlg:Refresh()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Montabr
Função para montagem do browse
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function Montabr()

	// Vetor com elementos do Browse
	aBrowse := {}

	DbSelectArea("SB1")
	SB1->(DbSetOrder(4))
	SB1->(DbGotop())
	SB1->(DbSeek(xFilial("SB1") + "3000"))
	While !Eof() .And. SB1->B1_FILIAL + SB1->B1_GRUPO == xFilial("SB1") + "3000"
		_nQuant   := _nQtdTot * (SB1->B1_PERCSUB/100)
		_nQuantPA := ProdPAM(SB1->B1_COD,_dDataProd)

		AADD(aBrowse,{SB1->B1_COD,SB1->B1_DESC,SB1->B1_PERCSUB,_nQuant,_nQuantPA})

		_nQtdPA  += _nQuantPA

		SB1->(DbSkip())
	Enddo

	_nPerTot := 100 - _nPercRend

	_nQtdDesp := _nQtdTot - _nQtdPA

	_nPos := aScan(aBrowse,{|aVal|aVal[1] = "011492"})
	aBrowse[_nPos,5] := _nQtdDesp

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AltQtd
Função para alteração de quantidade
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function AltQtd()

	Local _nQtdAlt := aBrowse[oBrowse:nAt,05]
	Local _lAlt    := .F.
	Local k

	If aBrowse[oBrowse:nAt,01] <> "011492"

		DEFINE MSDIALOG oDlg2 TITLE "Quantidade" FROM 000,000 TO 150,250 OF oMainWnd PIXEL
		@ 009,002 SAY "Qtde Original: " Object oSay1
		@ 009,065 GET _nQtdAlt SIZE 50,10 PICTURE "@E 999,999.9999999"  Object oQtdAlt 

		@ 055,090 BMPBUTTON TYPE 1 ACTION EVAL({|| _lAlt := .t.,oDlg2:end()}) Object Obtn2
		ACTIVATE MSDIALOG oDlg2

		If _lAlt
			aBrowse[oBrowse:nAt,05] := _nQtdAlt

			_nQtdPA := 0

			For k := 1 To Len(aBrowse)
				If aBrowse[k,01] <> "011492"
					_nQtdPA += aBrowse[k,05]
				Endif
			Next

			_nQtdDesp := _nQtdTot - _nQtdPA

			_nPos := aScan(aBrowse,{|aVal|aVal[1] = "011492"})
			aBrowse[_nPos,5] := _nQtdDesp
		Endif

		_cQtdPA   := "Qtde PA Prod. (Kg): " + Alltrim(Transform(_nQtdPA, "@E 999,999,999.9999999"))
		_cQtdDesp := "Qtde Desp. (Kg): " + Alltrim(Transform(_nQtdDesp, "@E 999,999,999.9999999"))

		_oSay1:SetText(_cQtdPA)
		_oSay2:SetText(_cQtdDesp)
		oBrowse:DrawSelect()
		oBrowse:refresh()

		oDlg:refresh()
	Else
		MsgAlert("Produto Despojo não pode ser Alterado!")
	Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProdSub
Função para processar subprodutos
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function ProdSub(_aMP, _cOP)

	//Local _nTotSaldo := 0
	Local j
	Local y

	For j := 1 To Len(_aMP)                                      		// Laço de repetição para produzir sub-produtos por categoria
		_cCodMP := _aMP[j,1]     	                             		// Codigo da MP a ser consumida

		For y := 1 To Len(aBrowse)                                 		// Laço para produção de sub-produtos a sub-produto
			_cCodSub   := aBrowse[y,1]                              	// Codigo do sub-produto a ser produzido
			_nQuantSub := aBrowse[y,5] 				                 	// Aplica o % da categoria sobre a quantidade de sub-produto a ser produzida

			If _cCodSub <> "011492"
				If _nQuantSub <> 0
					TranSub(_cOP, _cCodMP , _nQuantSub , _cCodSub  )  	// Cria vetor de itens para executar a rotina automática para produzir cada sub-produto
				Endif
			Endif
		Next

		_nQuantSld := fBuscaCPO("SB2", 1, xFilial("SB2") + _cCodMP + "01", "B2_QATU")
		_nQuantEmp := fBuscaCPO("SB2", 1, xFilial("SB2") + _cCodMP + '01', "B2_QEMP")
		_nQuantSub := _nQuantSld - _nQuantEmp
		
		TranSub(_cOP, _cCodMP , _nQuantSub , "011492")
	Next

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} TranSub
Função para transferencia de subprodutos baixando saldos das matérias primas
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function TranSub(_cOP, _cCodMP , _nQuantSub , _cCodSub )

	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}

	aCabec := { {"BC_OP"      , _cOP 				,NIL}}

	aItens := { {"BC_QUANT"   , _nQuantSub 			,NIL},;
				{"BC_PRODUTO" , _cCodMP    			,NIL},;
				{"BC_LOCAL"   , "01"       			,NIL},;
				{"BC_LOCORIG" , "01"       			,NIL},;
				{"BC_TIPO"    , "R"        			,NIL},;
				{"BC_DTVALID" , ddatabase  			,NIL},;
				{"BC_MOTIVO"  , "RB"       			,NIL},;
				{"BC_CODDEST" , _cCodSub   			,NIL},;
				{"BC_LOCDEST" , "01"       			,NIL},;
				{"BC_QTDDEST" , _nQuantSub 			,NIL},;
				{"BC_FLOTE"   , _cLoteCtl  			,NIL},;
				{"BC_ROTBLK"  , AllTrim(FunName())	,NIL}}

	AADD(aLinha,aItens)

	lMSErroAuto := .F.

	DbSelectArea("SBC")
	Begin Transaction
		MsExecAuto({|x,y,z| MATA685(x,y,z) }, aCabec, aLinha, 3)
		If lMSErroAuto
			ProcLogAtu("ERRO", "Houve erro na geração de apontamento de perda da produção na SBC. Verifique na tela seguinte.")
			MsgAlert("Houve erro na geração de apontamento de perda da produção na SBC. Verifique na tela seguinte.", ProcName())
			MostraErro()
			DisarmTransaction()
		Else
			ProcLogAtu("MENSAGEM", "GERADO SBC APONTAMENTO DE PERDA DA PRODUÇÃO OP: " + _cOP + " PROD: " + Alltrim(_cCodMP) + " PROD DESTINO: " + Alltrim(_cCodSub) + " QTDE DESTINO: " + AllTrim(Transform(_nQuantSub, "@E 9,999,999,999.9999999")))
		Endif
	End Transaction

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProdPAM
Função que retorna a quantidade em Kg do que foi produzido de PA
miudezas na data que está sendo apurada
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function ProdPAM(_cComp,_dData)

	cQueryPAM := "SELECT SUM(Z8_PESO) AS PESO "
	cQueryPAM += "  FROM " + RetSQLTab("SZ8") + "," + RetSQLTab("SB1") + "," + RetSQLTab("SG1") + ", " + RetSqlTab("SZ2")
	cQueryPAM += " WHERE " + RetSQLFil('SB1') + " AND " + RetSQLFil('SG1') + " AND Z8_FILORI = '" + cFilAnt + "' AND " + RetSQLFil("SZ2")
	cQueryPAM += "   AND B1_COD = G1_COMP AND G1_COD = Z8_CODORI AND Z2_DATAABT = '" + dtos(_dData) + "' AND Z2_NUM = Z8_PREDES"
	cQueryPAM += "   AND G1_COMP = '" + _cComp + "' AND B1_MSBLQL = '2' "
	cQueryPAM += "   AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('SG1') + " AND " + RetSQLDel("SZ2")

	cQueryPAM := ChangeQuery(cQueryPAM)

	memowrite('c:\temp\ProdPAM.txt',cQueryPAM)

	If Select("QRYPAM")<>0
		QRYPAM->(dbCloseArea())
	Endif

	TCQUERY cQueryPAM NEW ALIAS "QRYPAM"

	_Qtd := QRYPAM->PESO

	//ProcLogAtu("MENSAGEM", "Produzido " + AllTrim(Transform(_Qtd, "@E 999.999.999")) + " Kg de PA miudezas: " + Alltrim(DtoC(Date())) + "-" + Alltrim(Time()), cQueryPAM)

Return(_Qtd)
