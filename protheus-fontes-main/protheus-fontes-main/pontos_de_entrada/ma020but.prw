#INCLUDE "PROTHEUS.CH"

Static __cArqLog

User Function MA020BUT()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ MA020BUT ³ Autor ³ Evandro Mugnol        ³ Data ³ Out/2017 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ P.E. que acrescenta opções no cadastro de fornecedores     ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Frigorífico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Data      ³ Programador   ³ Manutencao Efetuada                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local _aRet := {}

	// Somente cria botão se for realizada inclusão via rotina de geração SC e OR automaticamente pela PROGEPEC
	If AllTrim(FunName()) == "STI_RG02"		
		_aRet := {{"NOTE" , {|| LeRoman()} , "Atualiza Romaneio" }}
	Endif

Return(_aRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LeRoman  ³ Autor ³ Evandro Mugnol        ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua leitura dos dados do romaneio de compra de gado     ³±±
±±³          ³ A chamada da inclusão ocorro no fonte STI_RG02             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LeRoman()

	Private lTelaLog := .F.
	Private oDlg     := NIL
	Private oFont    := NIL
	Private oMemo    := NIL
	Private cFile    := ""
	Private cCaminho := AllTrim(GetPvProfString(GetEnvServer(),"RootPath","",GetADV97()))+"\log_fornec\"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria diretório			                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File(cCaminho)
		MakeDir(cCaminho)
	Endif

	_cCNPJ  := PADR(AllTrim(TRB->ZAQ_CNPJ), TamSX3("A2_CGC")[1], " ")
	_cINSCR := PADR(AllTrim(TRB->ZAQ_INSCR), TamSX3("A2_INSCR")[1], " ")

	_nVez := 1
	DbSelectArea("SA2")
	DbGoTop()
	DbSetOrder(3)
	DbSeek(xFilial("SA2") + _cCNPJ)
	While !Eof() .And. SA2->A2_FILIAL + SA2->A2_CGC == xFilial("SA2") + _cCNPJ
		lTelaLog := .T.
		If _nVez == 1
			GeraLog("FORNECEDORES JÁ EXISTENTES E CADASTRADOS NO SISTEMA")
			GeraLog("")
			GeraLog("CODIGO   LOJA  N O M E                                                         CNPJ/CPF               INSCRIÇÃO")
			GeraLog(Replicate("-", 110))
		Endif
		GeraLog(" " + SA2->A2_COD + "      " + SA2->A2_LOJA + "    " + SA2->A2_NOME + "     " + SA2->A2_CGC + "     " + SA2->A2_INSCR)
		_nVez ++
		DbSelectArea("SA2")
		DbSkip()
	EndDo

	// Somente mostra tela de log se encontrou algum fornecedor
	If lTelaLog
		cMask  := "Arquivos Texto (*.TXT) |*.txt|"
		cTexto := MemoRead(__cArqLog)

		DEFINE FONT oFont Name "Courier New" SIZE 5,0

		DEFINE MSDIALOG oDlg TITLE __cArqLog FROM 3, 0 TO 340, 540 PIXEL

		@ 5, 5 GET oMemo VAR cTexto Memo SIZE 263, 145 OF oDlg PIXEL
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont

		DEFINE SBUTTON FROM 153, 175 TYPE  1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
		DEFINE SBUTTON FROM 153, 145 TYPE 13 ACTION (cFile := cGetFile(cMask, ""), IF(cFile == "", .T., MemoWrite(cFile, cTexto))) ENABLE OF oDlg PIXEL

		ACTIVATE MSDIALOG oDlg CENTER
	Endif

	M->A2_NOME	  := UPPER(TRB->ZAQ_DESCP) 				// Nome Produtor
	M->A2_NREDUZ  := UPPER(TRB->ZAQ_DESCP) 				// Nome Produtor
	M->A2_END	  := UPPER(TRB->ZAQ_END)				// Endereço
	M->A2_BAIRRO  := "INTERIOR"
	M->A2_EST     := "RS"
	M->A2_MUN	  := UPPER(TRB->ZAQ_MUN)				// Municipio
	M->A2_COD_MUN := fBuscaCPO("CC2", 4, xFilial("CC2") + "RS" + UPPER(AllTrim(TRB->ZAQ_MUN)), "CC2_CODMUN")
	M->A2_TIPO    := IIF(Len(AllTrim(TRB->ZAQ_CNPJ))==14,"J","F")
	M->A2_CGC     := TRB->ZAQ_CNPJ						// CNPJ ou CPF
	M->A2_INSCR	  := TRB->ZAQ_INSCR						// Inscrição Estadual
	M->A2_PAIS	  := "105"
	M->A2_NATUREZ := "120101"
	M->A2_COND	  := "049"
	M->A2_CONTA	  := "2101011001"
	M->A2_TPFOR	  := "M"
	M->A2_TIPORUR := IIF(Len(AllTrim(TRB->ZAQ_CNPJ))==14,"J","L")
	M->A2_CODPAIS := "01058"
	M->A2_FOMEZER := "2"
	M->A2_CDPAIS  := "311"
	M->A2_SIMPNAC := "2"
	M->A2_SENHAP  := Substr(AllTrim(TRB->ZAQ_CNPJ),1,3)
	M->A2_STATUSP := "L"

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função gera o log                                   		               ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GeraLog(cLogErro)

	DEFAULT __cArqLog := "\log_fornec\" + CriaTrab(,.F.) + "_as_" + Substr(Time(),1,2) + "-" + Substr(Time(),4,2) + ".log"

	If !File(__cArqLog)
		If (nHandle2 := MSFCreate(__cArqLog,0)) == -1
			Return
		EndIf
	Else
		If (nHandle2 := FOpen(__cArqLog,2)) == -1
			Return
		EndIf
	EndIf

	FSeek(nHandle2,0,2)
	FWrite(nHandle2,cLogErro+chr(13)+chr(10))
	FClose(nHandle2)

Return
