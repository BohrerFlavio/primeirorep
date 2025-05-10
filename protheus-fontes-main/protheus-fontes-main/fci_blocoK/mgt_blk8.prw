#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MGT_BLK8 
@Type			: Função de Usuário
@Sample			: U_MGT_BLK8()
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
User Function MGT_BLK8()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| BLK8NewPerg ( oSelf ) }   
	Local cFunction    := "MGT_BLK8"
	Local cTitle	   := "Geração Dados Bloco K Referente Produção e Saída de Despojo"
	Local cDescription := "Rotina responsável pela geração das ordens de produção e apontamentos da produção e baixa dos PAs referente ao despojo." + ;
						  "Para executar a geração das informações necessárias, informe os parâmetros necessários." + CRLF + CRLF + ; 
						  "Clique no botão abaixo e aguarde a conclusão do processamento."

	Private cPerg	   := "MGT_BLK8"
	//Private cCadastro  := OemToAnsi("Geração Dados Bloco K Referente Produção e Saída de Despojo")

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
/*/{Protheus.doc} BLK8NewPerg
Tratamento para a utilização do tNewProcess
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK8NewPerg( oSelf )

	BLK8Proc(.F.,oSelf)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BLK8Proc
Função que efetua o processamento das informações
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BLK8Proc( lBat, oSelf )

	Local cIdCV8 := ""

	Pergunte(cPerg,.F.)

	ProcLogIni({},FunName(),,@cIdCV8)
	ProcLogAtu("INICIO","Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()) ,,,.T.)

	_cProduto := PADR("000826", 15," ")		// DESPOJOS DE MATANCA
	_cLoteCTL := mv_par01

	DbSetOrder(1)
	SB1->(DbSeek(xFilial("SB1") + _cProduto))

	_nPesoTot := mv_par03
	_cDescPrd := SB1->B1_DESC
	_cUnidMed := SB1->B1_UM
	_cGrupPrd := SB1->B1_GRUPO
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
	AADD (_aAutoSC2, {"C2_NUMAM"  , mv_par01                   		, NIL})

	// Executa movimentacao de estoque via rotina automatica.
	If Len(_aAutoSC2) > 0
		lMSErroAuto := .F.
		DbSelectArea("SC2")
		Begin Transaction
			MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, 3)    // Inclusão
			If lMSErroAuto
				ProcLogAtu("ERRO", "ERRO GERACAO -  OP NUMERO ==> " + _cNumOp + " PARA PA " + AllTrim(_cProduto) + " Aviso de Matanca " + _cLoteCTL)
				MsgAlert("Houve erro na geração da Ordem de Produção de PA na SC2. Verifique na tela seguinte.", ProcName())
				MostraErro()
				DisarmTransaction()     
			Else   
				ProcLogAtu("MENSAGEM", "GERADO OP NUMERO ==> " + _cNumOp + " PARA PA " + AllTrim(_cProduto) + " Aviso de Matanca " + _cLoteCTL)
				//ProcSD4(_cNumOp + "01001   ")
				ProdSD3(_cNumOp + "01001   ","010",_cProduto,_nPesoTot)
				SaiSD3(_cProduto,_nPesoTot,mv_par02,'506')
			Endif
		End Transaction
	Else
		ProcLogAtu("MENSAGEM", "NAO FOI GERADO OP NUMERO ==> " + _cNumOp + " PARA PA " + AllTrim(_cProduto) + " Aviso de Matanca " + _cLoteCTL)
	Endif

	ProcLogAtu("FIM","Rotina Chamadora: "+ FunName() + " "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()) ,,,.T.)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProdSD3
Grava SD3 (movimentos de produção)
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function ProdSD3(_Op,_TM,_Prod,_Quant)

	Pergunte(cPerg,.F.)	

	_cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)

	_aVetor := {}
	AADD(_aVetor, {"D3_OP     " ,_Op        		   	,NIL})
	AADD(_aVetor, {"D3_TM     " ,_TM    				,NIL})
	AADD(_aVetor, {"D3_EMISSAO" , dDatabase 			,NIL})
	AADD(_aVetor, {"D3_COD    " ,_Prod					,NIL})
	AADD(_aVetor, {"D3_UM     " , "KG"					,NIL})
	AADD(_aVetor, {"D3_QUANT  " ,_Quant					,NIL})
	AADD(_aVetor, {"D3_DOC    " , _cNumDoc          	,NIL})
	AADD(_aVetor, {"D3_LOCAL  " , "01"           		,NIL})
	AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())	,NIL})

	// Executa movimentacao de produção de PP via rotina automatica.
	If Len(_aVetor) > 0

		lMSErroAuto := .F.
		DbSelectArea("SD3")
		Begin Transaction
			MSExecAuto({|x,y| mata250(x,y)}, _aVetor, 3)    // Inclusão
			If lMSErroAuto
				ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE PRODUCAO ==> " + _Op + " PARA PRODUTO " + AllTrim(_cProd) + " D3_TM = " + _TM)
				MsgAlert("Houve erro na geração da produção do SD3 de PP ExecAuto MATA240 TM 010. Verifique na tela seguinte.", ProcName())
				MostraErro()
				DisarmTransaction()
			Else 
				ProcLogAtu("MENSAGEM", "GERADO SD3 DE PRODUCAO ==> " + _Op + " PARA PRODUTO " + AllTrim(_cProd) + " D3_TM = " + _TM)
			Endif                                       
		End Transaction 
	Else
		ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE PRODUCAO ==> " + _Op + " PARA PRODUTO " + AllTrim(_cProd) + " D3_TM = " + _TM)
	Endif

	Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas desta rotina e não da execauto

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProdSD4
Processa SD4 (Empenhos de Produção)
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function ProcSD4(_Op)

	DbSelectArea("SD4")
	SD4->(DbGoTop())
	SD4->(DbSetOrder(2))
	SD4->(DbSeek(xFilial("SD4") + _Op))
	While SD4->(!Eof()) .And. SD4->D4_FILIAL + SD4->D4_OP == xFilial("SD4") + _Op       
		_cProdEmp := SD4->D4_COD
		_cLocal   := SD4->D4_LOCAL

		DbSelectArea("SB1")
		_cTipo   := fBuscaCPO("SB1",1,xFilial("SD4") + _cProdEmp,"B1_TIPO")
		_cRastro := fBuscaCPO("SB1",1,xFilial("SD4") + _cProdEmp,"B1_RASTRO")

		If _cTipo $ "SP/PP"      
			SB2->(DbSetOrder(1))

			If SB2->(DbSeek(xFilial("SB2") + _cProdEmp + _cLocal))
				DbSelectArea("SB2")
				Reclock("SB2",.F.)
				SB2->B2_QEMP := SB2->B2_QATU 
				MsUnlock()   

				If SB2->B2_QATU <> 0              
					DbSelectArea("SD4")
					Reclock("SD4",.F.)
					SD4->D4_QTDEORI := SB2->B2_QATU
					SD4->D4_QUANT   := SB2->B2_QATU 
					MsUnlock()
				Else    
					DbSelectArea("SD4")
					Reclock("SD4",.F.)
					DbDelete()
					MsUnlock()  
				Endif			
			Endif
		Endif

		SD4->(DbSkip())
	Enddo

Return         


//-------------------------------------------------------------------
/*/{Protheus.doc} SaiSD3
Processa Saídas SD3
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function SaiSD3(_Prod,_Quant,_Doc,_TM) 

	Pergunte(cPerg,.F.)

	_aVetor := {}

	AADD(_aVetor, {"D3_TM     " , _TM      	           	,NIL})
	AADD(_aVetor, {"D3_DOC    " , _Doc                 	,NIL})
	AADD(_aVetor, {"D3_CC     " , "1131001"             ,NIL})
	AADD(_aVetor, {"D3_EMISSAO" , ddatabase             ,NIL})
	AADD(_aVetor, {"D3_COD    " , _Prod    	           	,NIL})
	AADD(_aVetor, {"D3_UM     " , "KG"			        ,NIL})
	AADD(_aVetor, {"D3_QUANT  " , _Quant   	          	,NIL})
	AADD(_aVetor, {"D3_LOCAL  " , "01"                  ,NIL})
	AADD(_aVetor, {"D3_ROTBLK"  , AllTrim(FunName())	,NIL})

	// Executa entrada de MP via rotina automatica
	If Len(_aVetor) > 0
		lMSErroAuto := .F.
		DbSelectArea("SD3")
		Begin Transaction
			MSExecAuto({|x,y| MATA240(x,y)},_aVetor,3)    // Inclusão
			If lMSErroAuto
				ProcLogAtu("ERRO", "ERRO GERACAO - SD3 DE SAIDA DE PA ==> " + _Doc + " PARA PRODUTO " + AllTrim(_Prod) + " D3_TM = " + _TM)
				MsgAlert("Houve erro na geração da saida do SD3 ExecAuto MATA240 TM 506. Verifique na tela seguinte.", ProcName())
				MostraErro()
				DisarmTransaction()
				_FlagIncMP := .F.
			Else
				ProcLogAtu("MENSAGEM", "GERADO SD3 DE SAIDA DE PA ==> " + _Doc + " PARA PRODUTO " + AllTrim(_Prod) + " D3_TM = " + _TM)
			Endif
		End Transaction
	Else
		ProcLogAtu("MENSAGEM", "NAO FOI GERADO SD3 DE SAIDA DE PA ==> " + _Doc + " PARA PRODUTO " + AllTrim(_Prod) + " D3_TM = " + _TM)
	Endif

Return
