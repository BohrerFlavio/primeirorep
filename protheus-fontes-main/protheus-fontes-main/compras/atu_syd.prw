#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ATU_SYD
@Type			: Função de Usuário
@Sample			: U_ATU_SYD()
@Description	: Função para atualizar a tabela de NCM no Protheus via planilha .CSV
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Mar/2024
@version		: Protheus 12.1.2210 e posteriores
@Comments		: Ao final do processo irá perguntar se deseja atualizar Aliq. IPI no SB1
/*/
//--------------------------------------------------------------------------------------
User Function ATU_SYD()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| ImpCSV ( oSelf ) }
	Local cFunction    := "ATU_SYD"
	Local cTitle	   := "Importação / Atualização da tabela SYD (Cadastro de NCMs) conforme planilha .CSV"
	Local cDescription := "Rotina responsável pela importação / atualização do CADASTRO DE NCMs (tabela SYD) conforme planilha .CSV" + CRLF + CRLF + ;
						  "CLIQUE NO BOTÃO ABAIXO, SELECIONE O ARQUIVO .CSV E AGUARDE A CONCLUSÃO DO PROCESSAMENTO."

	Private cPerg	   := "ATU_SYD"

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
								"Painel Auxiliar",;
								.T.)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} ImpCSV
Tratamento para a utilização do tNewProcess
@author     Evandro Mugnol
@since      Mar/2024
/*/
//----------------------------------------------------------------------
Static Function ImpCSV( oSelf )

	Processa( .F., oSelf )

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} ImpCSV
Função que efetua o processamento das informações
@author     Evandro Mugnol
@since      Mar/2024
/*/
//----------------------------------------------------------------------
Static Function Processa( lBat, oSelf )

	Local cDirLog  := GetTempPath()
	Local cArqLog  := "ImpNCM_" + DTOS(Date()) + "_" + StrTran(Time(), ':', '-') + ".Log"
	Local cDiret
	Local cLinha   := ""
	Local lPrimlin := .T.
	Local aCampos  := {}
	Local aDados   := {}
	Local nX

	Private aDadosSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt, {"M0_NOMECOM", ;
	                                                                "M0_ENDENT",  ;
																	"M0_BAIRENT", ;
																	"M0_CEPENT",  ;
																	"M0_CIDENT",  ;
																	"M0_ESTENT",  ;
																	"M0_CGC"	 }) 

	cDiret := cGetFile( 'Arquito CSV|*.csv| Arquivo TXT|*.txt| Arquivo XML|*.xml',; //[ cMascara],
						'Seleção de Arquivo',;                  					//[ cTitulo],
						0,;                                      					//[ nMascpadrao],
						'C:\',;   		                         					//[ cDirinicial],
						.F.,;                                    					//[ lSalvar],
						GETF_LOCALHARD  + GETF_NETWORKDRIVE,;    					//[ nOpcoes],
						.T.)

	Private nHandle := FT_FUSE(cDiret)

	// Carrega variaveis para gerar LOG de processamento
	cMask  := "Arquivos Texto (*.TXT) |*.txt|"
	cTexto := "Verifique abaixo o resultado do processamento"+CHR(13)+CHR(10)
	cTexto += Replicate("-",128) + CHR(13)+CHR(10)
	cTexto += "Empresa / Filial ... " + cEmpAnt + " / " + cFilAnt + " => " + AllTrim(aDadosSM0[1][2]) + CHR(13)+CHR(10)
	cTexto += Space(128) + CHR(13)+CHR(10)
	cTexto += Replicate("-",128) + CHR(13)+CHR(10)

	If nHandle == -1
		Return
	EndIf

	FT_FGOTOP()

	While !FT_FEOF()

		oSelf:IncRegua1("Importando Arquivo CSV ... ")
		oSelf:IncRegua2()

		cLinha := FT_FREADLN()

		If lPrimlin
			aCampos := Separa(cLinha,";",.T.)
			lPrimlin := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo

	_lProcessa := .F.
	For nX:=1 to Len(aDados)

		oSelf:IncRegua1("Importando / Atualizando Registros da NCM ... " + Transform(aDados[nX,1], "@R 9999.99.99"))
		oSelf:IncRegua2()

		_cCodNCM  := PADR(aDados[nX,1] , 10, "")
        _cDescri  := UPPER(PADR(AllTrim(aDados[nX,3]) , 40, ""))
        _nAliqIPI := Val(StrTran(aDados[nX,4], ",", "."))

		If Len(AllTrim(_cCodNCM)) == 8		// Somente processa códigos de NCM com 8 dígitos
			DbSelectArea("SYD")
			DbSetOrder(1)
			If !DbSeek(FWxFilial("SYD") + _cCodNCM)		// YD_FILIAL + YD_TEC
				Reclock("SYD",.T.)
				SYD->YD_FILIAL  := FWxFilial("SYD")
				SYD->YD_TEC     := _cCodNCM
				SYD->YD_DESC_P  := _cDescri
				SYD->YD_UNID    := "UN"
				SYD->YD_PER_IPI := _nAliqIPI
				SYD->YD_ANUENTE := "2"
				SYD->YD_GRVUSER := cUserName
				SYD->YD_GRVDATA := dDataBase
				SYD->YD_GRVHORA := Time()
				SYD->YD_MSBLQL  := "2"
				SYD->(MsUnlock())
				cTexto += "Importado novo NCM: " + _cCodNCM + " - " + _cDescri + "   | Aliq IPI: " + Transform(_nAliqIPI, "@E 99.99") + CHR(13) + CHR(10)
				_lProcessa := .T.
			Else
				If SYD->YD_MSBLQL <> "1"
					_nOldIPI := SYD->YD_PER_IPI
					Reclock("SYD",.F.)
					SYD->YD_PER_IPI := _nAliqIPI
					SYD->YD_ANUENTE := "2"
					SYD->YD_GRVUSER := cUserName
					SYD->YD_GRVDATA := dDataBase
					SYD->YD_GRVHORA := Time()
					SYD->YD_MSBLQL  := "2"
					SYD->(MsUnlock())
					cTexto += "ATUALIZADO NCM: " + _cCodNCM + " - " + _cDescri + "   | Aliq IPI Antes: " + Transform(_nOldIPI, "@E 99.99") + "  Depois: " + Transform(_nAliqIPI, "@E 99.99") + CHR(13) + CHR(10)
					_lProcessa := .T.
				Else
					cTexto += "NCM: " + _cCodNCM + " - " + _cDescri + "   | está bloqueado e nao foi atualizado" + CHR(13) + CHR(10)
					_lProcessa := .T.
				EndIf
			EndIf
		EndIf

	Next nX

	If FWAlertYesNo("Deseja atualizar Alíquota de IPI das NCMs no cadastro de Produtos?", "Continua")

		cTexto += "" + CHR(13) + CHR(10)
		cTexto += "========== A T U A L I Z A Ç Õ E S    D O    C A D A S T R O    DE    P R O D U T O S ==========" + CHR(13) + CHR(10)
		cTexto += "" + CHR(13) + CHR(10)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// Atualizando tabela SB1 (Cadastro de Produtos com códigos novos de NCM)               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbGoTop()
		While !Eof() .And. SB1->B1_FILIAL = FWxFilial()
			_cCodProd := SB1->B1_COD
			_cNCMProd := SB1->B1_POSIPI
			_nIPIAnt  := SB1->B1_IPI

			oSelf:IncRegua1("Processando atualização SB1 ... " + SB1->B1_COD)
			oSelf:IncRegua2()

			DbSelectArea("SYD")
			DbSetOrder(1)
			DbSeek(xFilial("SYD") + _cNCMProd)
			If Found()
				_nIPISYD := SYD->YD_PER_IPI
				DbSelectArea("SB1")
				RecLock("SB1", .F.)
				SB1->B1_IPI := _nIPISYD
				MsUnlock()
				cTexto += "Produto: " + _cCodProd + " atualizado Aliq. IPI Antes: " + Transform(_nIPIAnt, "@E 99.99") + "  Depois: " + Transform(_nIPISYD, "@E 99.99") + CHR(13) + CHR(10)
				_lProcessa := .T.
			Else	
				cTexto += "NCM: " + _cNCMProd + " do Produto: " + _cCodProd + " não encontrado na tabela SYD. Verifique ..." + CHR(13) + CHR(10)
				_lProcessa := .T.
			EndIf

			DbSelectArea("SB1")
			DbSkip()
		Enddo
		
	EndIf

	FWAlertSuccess("Importação de NCMs finalizado. Verifique o Log na próxima tela.","Fim. Concluído com SUCESSO.")

	If _lProcessa
		// Se tiver log, mostra ele
		If !Empty(cTexto)
			MemoWrite(cDirLog + cArqLog, cTexto)
			ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
		EndIf
	EndIf

	/*
	If _lProcessa
		cTexto := "Log de Importação"+CHR(13)+CHR(10)+cTexto
		__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
		DEFINE FONT oFont NAME "Mono AS" SIZE 6,15
		DEFINE MSDIALOG oDlg TITLE "Processamento da importação abaixo" From 000, 000 to 550,950 PIXEL
		@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 470,245 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		DEFINE SBUTTON FROM 255,395 TYPE 1  ACTION oDlg:End() ENABLE OF oDlg PIXEL                                                               // Apaga
		DEFINE SBUTTON FROM 255,365 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL     // Salva e Apaga   // "Salvar Como..."
		ACTIVATE MSDIALOG oDlg CENTER
	Endif
	*/

Return
