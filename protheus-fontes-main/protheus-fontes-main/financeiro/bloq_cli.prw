#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} BLOQ_CLI
@Type			: Função de Usuário
@Sample			: U_BLOQ_CLI()
@Description	: Rotina que realiza bloqueio para movimentação comercial e financeira
                  dos clientes avaliados junto ao seu cadastro.
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Out/2023
@version		: Protheus 12.1.33 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function BLOQ_CLI()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| ProcBLQ ( oSelf ) }
	Local cFunction    := "BLOQ_CLI"
	Local cTitle	   := "Atualização do Bloqueio de Clientes"
	Local cDescription := "Rotina responsável por bloquear os clientes que possuem títulos em atraso, conforme o número de dias, a data de emissão dos títulos a receber ou os dias da ultima venda definidos nos parâmetros dessa rotina." + CRLF + CRLF + ;
						  "Clique no botão abaixo e aguarde a conclusão do processamento."

	Private cPerg	   := "BLOQ_CLI"

	// Botão para visualização do log de processamento
	Aadd(aInfo,{"Históricos de Processamentos", { || ProcLogView(,FunName()) },"WATCH" })

	oProcess := tNewProcess():New ( cFunction,;
									cTitle,;
									bProcess,;
									cDescription,;
									cPerg,;
									aInfo,;
									.T.,;
									5,;
									"Painel Auxiliar",;
									.T.,;
									.T.)
Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} ProcBLQ
Tratamento para a utilização do tNewProcess
@author     Evandro Mugnol
@since      Out/2023
/*/
//----------------------------------------------------------------------
Static Function ProcBLQ( oSelf )

	Processa( .F., oSelf )

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} Processa
Função que efetua o processamento das informações
@author     Evandro Mugnol
@since      Out/2023
/*/
//----------------------------------------------------------------------
Static Function Processa( lBat, oSelf )

	Local _lContinua := .F.
	Local _lProcessa := .F.

	Private aDadosSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt, {"M0_NOMECOM", ;
																	"M0_ENDENT",  ;
																	"M0_BAIRENT", ;
																	"M0_CEPENT",  ;
																	"M0_CIDENT",  ;
																	"M0_ESTENT",  ;
																	"M0_CGC"	 })

	// Carrega variaveis para gerar LOG de processamento
	cMask  := "Arquivos Texto (*.TXT) |*.txt|"
	cTexto := "Verifique abaixo o resultado do processamento"+CHR(13)+CHR(10)
	cTexto += Replicate("-",128) + CHR(13)+CHR(10)
	cTexto += "Empresa / Filial ... " + cEmpAnt + " / " + cFilAnt + " => " + AllTrim(aDadosSM0[1][2]) + CHR(13)+CHR(10)
	cTexto += Space(128) + CHR(13)+CHR(10)
	cTexto += Replicate("-",128) + CHR(13)+CHR(10)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// Efetua desbloqueio de todos os clientes							                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cQuery1 := "UPDATE " + RetSQLName("SA1")
	_cQuery1 += "   SET A1_MSBLQL = '2', A1_MOTBLQL = ' ', A1_DTBLQL = ' ', "
	_cQuery1 += "       A1_SIBLQL = '2', A1_SIMOTBL = ' ', A1_SIDTBL = ' ', "
	_cQuery1 += "       A1_POBLQL = '2', A1_POMOTBL = ' ', A1_PODTBL = ' ' "
	_cQuery1 += " WHERE D_E_L_E_T_ = ' ' "
	_cQuery1 += "   AND A1_FILIAL = '" + FWxFilial("SA1") + "' "

	oSelf:IncRegua1("Desbloqueando Clientes ... ")
	
	If TCSqlExec(_cQuery1) < 0
		FWAlertError(TCSQLError(), "Problema Desbloqueio Clientes")
		_lContinua := .F.
	Else
		cTexto += "DESBLOQUEIO DE TODOS OS CLIENTES REALIZADO COM SUCESSO ..." + CHR(13) + CHR(10)
		_lContinua := .T.
		_lProcessa := .T.
	EndIf

	If 	_lContinua
		DbSelectArea("SA1")
		DbSetOrder(1)
		MsSeek(FWxFilial("SA1"))
		DbGoTop()
		While !Eof() .And. SA1->A1_FILIAL == FWxFilial("SA1") 

			oSelf:IncRegua1("Processando Cliente: " + AllTrim(SA1->A1_COD) + " Loja: " + AllTrim(SA1->A1_LOJA) + "...")

			// Não processa cliente VT Sistemas (Hotmedia), pois é cliente de testes dos meios de pagamento
			If SA1->A1_COD == "021350" .And. SA1->A1_LOJA == "01"
				DbSelectArea("SA1")
				DbSkip()
				Loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// Processa Vencto do Limite de Credito								                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par01 == 1  
				If !Empty(SA1->A1_VENCLC)
					If SA1->A1_VENCLC < DDATABASE
						DbSelectArea("SA1")
						RecLock("SA1",.F.)
						SA1->A1_MSBLQL  := "1"
						SA1->A1_MOTBLQL := "LIMITE DE CREDITO VENCIDO"
						SA1->A1_DTBLQL  := DDATABASE

						SA1->A1_SIBLQL  := "1"
						SA1->A1_SIMOTBL := "LIMITE DE CREDITO VENCIDO"
						SA1->A1_SIDTBL  := DDATABASE

						SA1->A1_POBLQL  := "1"      
						SA1->A1_POMOTBL := "LIMITE DE CREDITO VENCIDO"
						SA1->A1_PODTBL  := DDATABASE
						MsUnlock()

						cTexto += "Cliente: " + AllTrim(SA1->A1_COD) + " Loja: " + AllTrim(SA1->A1_LOJA) + "  -> BLOQUEADO Status, Movto e Portal POR LIMITE DE CREDITO VENCIDO" + CHR(13) + CHR(10)
						_lContinua := .T.
					EndIf
				Else
					cTexto += "Cliente: " + AllTrim(SA1->A1_COD) + " Loja: " + AllTrim(SA1->A1_LOJA) + "  -> SEM VENCIMENTO DE LIMITE DE CREDITO" + CHR(13) + CHR(10)
					_lContinua := .T.
				EndIf
			EndIf


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// Processa Vencto dos Titulos										                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par02 == 1
				_cQuery2 := "SELECT * "
				_cQuery2 += "  FROM " + RetSQLTab("SE1")
				_cQuery2 += " WHERE " + RetSQLFil("SE1")
				_cQuery2 += "   AND E1_CLIENTE = '" + SA1->A1_COD + "' AND  E1_LOJA = '" + SA1->A1_LOJA + "' AND E1_SALDO <> 0 AND E1_TIPO NOT IN ('NCC','RA') "
				//_cQuery2 += "   AND E1_EMISSAO >= '" + Dtos(DDATABASE) + "' AND E1_BAIXA = ''"
				_cQuery2 += "   AND " + RetSQLDel("SE1")

				_cQuery2 := ChangeQuery(_cQuery2)

				If Select("VER") <> 0
					VER->(dbCloseArea())
				Endif

				TCQUERY _cQuery2 NEW ALIAS "VER"

				VER->(DbGoTop())
				While VER->(!Eof())
					_Atraso := DDATABASE - Stod(VER->E1_VENCREA)

					If _Atraso >= mv_par03
						DbSelectArea("SA1")
						RecLock("SA1",.F.)
						SA1->A1_MSBLQL  := "1"
						SA1->A1_MOTBLQL := "TITULOS VENCIDOS"
						SA1->A1_DTBLQL  := DDATABASE

						SA1->A1_POBLQL  := "2"
						SA1->A1_POMOTBL := ""
						SA1->A1_PODTBL  := Ctod("")
						MsUnlock()

						cTexto += "Cliente: " + AllTrim(SA1->A1_COD) + " Loja: " + AllTrim(SA1->A1_LOJA) + "  -> BLOQUEADO Status POR TITULOS VENCIDOS e DESBLOQUEADO Portal" + CHR(13) + CHR(10)
						_lContinua := .T.
						Exit
					Endif

					VER->(DbSkip())
				EndDo

				VER->(dbCloseArea())
			EndIf


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// Processa Condicao de Pagamento									                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par04 == 1  
				If SA1->A1_COND == "001"
					DbSelectArea("SA1")
					RecLock("SA1",.F.)
					SA1->A1_MSBLQL  := "1"
					SA1->A1_MOTBLQL := "CONDICAO PAGAMENTO"
					SA1->A1_DTBLQL  := DDATABASE

					SA1->A1_SIBLQL  := "2"
					SA1->A1_SIMOTBL := ""
					SA1->A1_SIDTBL  := Ctod("")
					MsUnlock()

					cTexto += "Cliente: " + AllTrim(SA1->A1_COD) + " Loja: " + AllTrim(SA1->A1_LOJA) + "  -> BLOQUEADO Status POR CONDICAO PAGAMENTO e DESBLOQUEADO Movto" + CHR(13) + CHR(10)
					_lContinua := .T.
				EndIf
			EndIf
			
			DbSelectArea("SA1")
			DbSkip()
		EndDo

	EndIf

	If _lContinua
		If mv_par05 == 1
			FWAlertSuccess("Bloqueio dos clientes finalizado. Verifique o Log na próxima tela.","Fim. Concluído com SUCESSO.")
		Else
			FWAlertSuccess("Bloqueio dos clientes finalizado.","Fim. Concluído com SUCESSO.")
		EndIf
	Else
		FWAlertError("Houve problemas na rotina de bloqueio de clientes. Verifique o Log na próxima tela.","Fim. Concluído com PROBLEMAS.")
	EndIf

	If mv_par05 == 1
		If _lProcessa
			cTexto := "Log de Processamento"+CHR(13)+CHR(10)+cTexto
			__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
			DEFINE FONT oFont NAME "Mono AS" SIZE 6,15
			DEFINE MSDIALOG oDlg TITLE "Processamento Bloqueio Clientes Abaixo" From 000, 000 to 550,950 PIXEL
			@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 470,245 OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont
			DEFINE SBUTTON FROM 255,395 TYPE 1  ACTION oDlg:End() ENABLE OF oDlg PIXEL                                                               // Apaga
			DEFINE SBUTTON FROM 255,365 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL     // Salva e Apaga   // "Salvar Como..."
			ACTIVATE MSDIALOG oDlg CENTER
		Endif
	EndIf

Return
