#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BACA_RAP
Baca para gerar título de rapel conforme título principal
@author     Evandro Mugnol
@since      Set/2021
@version    1.0
/*/
//-------------------------------------------------------------------

User Function BACA_RAP()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| BacaNewPerg ( oSelf ) }
	Local cFunction    := "BACA_RAP"
	Local cTitle	   := "Geração de Títulos de Rapel com base no título original"
	Local cDescription := "Rotina responsável pela geração dos títulos de rapel com base nos títulos orifinais para os clientes de códigos 000173, 000174, 001110, 010343 e 020031, bem como todas as respectivas lojas." + ;
						  "Para executar a geração dos títulos necessárias, informe a data inicial a ser considerada." + CRLF + CRLF + ;
						  "Clique no botão abaixo e aguarde a conclusão do processamento."

	Private cPerg	   := "BACA_RAP"

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
/*/{Protheus.doc} BacaNewPerg
Tratamento para a utilização do tNewProcess
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BacaNewPerg( oSelf )

	BacaProc(.F.,oSelf)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BacaProc
Função que efetua o processamento das informações
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function BacaProc( lBat, oSelf )

	Local cIdCV8 	:= ""
	Local cClientes := "000173/000174/001110/010343/020031"

	// Valida data de processamento com data base do sistema
	If Empty(mv_par01)
		Aviso("PROCESSAMENTO BACA RAPEL", "Data inicial do processamento deve ser informada." + CRLF + CRLF + ;
			  "Processamento não será executado. Favor informar data inicial de processamento!",{"Ok"},2)
		Return
	Endif

	ProcLogIni({},FunName(),,@cIdCV8)
	ProcLogAtu("INICIO","Rotina Chamadora: "+ FunName() + " Data Inicial do Processamento: " + Alltrim(DtoC(mv_par01)) + " - " + Alltrim(Time()) ,,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Seleção dos títulos (SE1)
	cQuery := "SELECT * "
	cQuery += "  FROM " + RetSQLTab("SE1")
	cQuery += " WHERE " + RetSQLFil("SE1")
	cQuery += "   AND E1_EMISSAO >= '" + Dtos(mv_par01) + "'"
	cQuery += "   AND E1_CLIENTE IN " + FORMATIN(cClientes,"/")
	cQuery += "   AND E1_VLRAPEL > 0 "
	cQuery += "   AND " + RetSQLDel("SE1")

	cQuery := ChangeQuery(cQuery)

	ProcLogAtu("MENSAGEM", "Seleção dos títulos a serem processados com emissão inicial em: " + Alltrim(DtoC(mv_par01)) + " - " + Alltrim(Time()), cQuery)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .F., .T.)

	TRB->(dbGoTop())
	While TRB->(!Eof())

		oSelf:IncRegua1("Processando os títulos selecionados ...")
		oSelf:IncRegua2()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera novo título de rapel no SE1                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aVetSE1 := {}

		aAdd(aVetSE1, {"E1_FILIAL"	, TRB->E1_FILIAL				, Nil})
		aAdd(aVetSE1, {"E1_PREFIXO"	, "R"							, Nil})
		aAdd(aVetSE1, {"E1_NUM"		, TRB->E1_NUM					, Nil})
		aAdd(aVetSE1, {"E1_PARCELA"	, TRB->E1_PARCELA				, Nil})
		aAdd(aVetSE1, {"E1_TIPO"	, "RAP"							, Nil})
		aAdd(aVetSE1, {"E1_NATUREZ"	, "110107"						, Nil})
		aAdd(aVetSE1, {"E1_PORTADO"	, "RAP"							, Nil})
		aAdd(aVetSE1, {"E1_AGEDEP"	, "001  "						, Nil})
		aAdd(aVetSE1, {"E1_CLIENTE"	, TRB->E1_CLIENTE				, Nil})
		aAdd(aVetSE1, {"E1_LOJA"	, TRB->E1_LOJA					, Nil})
		aAdd(aVetSE1, {"E1_NOMCLI"	, TRB->E1_NOMCLI				, Nil})
		aAdd(aVetSE1, {"E1_EMISSAO"	, Stod(TRB->E1_EMISSAO)			, Nil})
		aAdd(aVetSE1, {"E1_VENCTO"	, Stod(TRB->E1_VENCTO)			, Nil})
		aAdd(aVetSE1, {"E1_VENCREA"	, Stod(TRB->E1_VENCREA)			, Nil})
		aAdd(aVetSE1, {"E1_VALOR"	, TRB->E1_VLRAPEL				, Nil})
		aAdd(aVetSE1, {"E1_VEND1"	, TRB->E1_VEND1					, Nil})
		aAdd(aVetSE1, {"E1_CONTA"	, "00001     "					, Nil})
		aAdd(aVetSE1, {"E1_MOEDA"	, TRB->E1_MOEDA					, Nil})
		aAdd(aVetSE1, {"E1_PEDIDO"	, TRB->E1_PEDIDO				, Nil})
		aAdd(aVetSE1, {"E1_SERIE"	, TRB->E1_SERIE					, Nil})
		aAdd(aVetSE1, {"E1_ORIGEM"	, "LOJA010"						, Nil})
		aAdd(aVetSE1, {"E1_FRMREC"	, TRB->E1_FRMREC				, Nil})
		aAdd(aVetSE1, {"E1_SDOC"	, TRB->E1_SDOC					, Nil})

		BEGIN TRANSACTION	// Inicia o controle de transação

		// Chama a rotina automática
		lMsErroAuto := .F.
		
		MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)

		// Se houve erro, mostra o erro ao usuário e desarma a transação
		If lMsErroAuto
			MostraErro()
			DisarmTransaction()
		Else
			ProcLogAtu("MENSAGEM", "Criado novo título rapel: " + "R" + TRB->E1_NUM + " " + TRB->E1_PARCELA + " " + TRB->E1_TIPO + " para Cliente " + TRB->E1_CLIENTE + "/" + TRB->E1_LOJA)
		EndIf
			
		END TRANSACTION		// Finaliza a transação

		TRB->(DbSkip())

	Enddo

	TRB->(DbCloseArea())

	ProcLogAtu("FIM","Rotina Chamadora: "+ FunName() + "  " + Alltrim(Dtoc(Date())) + " - " + Alltrim(Time()) ,,,.T.)

Return
