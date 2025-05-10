#INCLUDE "PROTHEUS.CH"

Static __cArqLog

User Function BACA_NCM()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ BACA_NCM ³ Autor ³ Evandro Mugnol        ³ Data ³ Mai/2017 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ BACA para buscar códigos incorretos de NCM do cadstro de   ³±±
	±±³          ³ produtos                                                   ³±±
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

	Private lTelaLog := .F.
	Private oDlg     := NIL
	Private oFont    := NIL
	Private oMemo    := NIL
	Private cFile    := ""
	Private cCaminho := AllTrim(GetPvProfString(GetEnvServer(),"RootPath","",GetADV97()))+"\log_tafncm\"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria diretório			                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File(cCaminho)
		MakeDir(cCaminho)
	Endif

	MsgAlert("SERÁ INICIADO LEITURA DO CADASTRO DE PRODUTOS. NÃO INTERROMPA O PROCESSAMENTO.")

	_nVez := 1
	DbSelectArea("SB1")
	DbGoTop()
	DbSetOrder(1)
	DbSeek(xFilial("SB1"))
	While !Eof() .And. SB1->B1_FILIAL == xFilial("SB1")
		lTelaLog := .T.
		_cNCM    := SB1->B1_POSIPI
		If _nVez == 1
			GeraLog("PRODUTOS COM NCM INCORRETA CADASTRADA NO SISTEMA")
			GeraLog("")
			GeraLog("PRODUTO         DESCRICAO                                                                                NCM")
			GeraLog(Replicate("-", 135))
		Endif

		DbSelectArea("SYD")
		DbSetOrder(1)
		DbSeek(xFilial("SYD") + _cNCM)
		If !Found()
			GeraLog(SB1->B1_COD + " " + SB1->B1_DESC + " " + SB1->B1_POSIPI)
		Endif
		_nVez ++
		DbSelectArea("SB1")
		DbSkip()
	EndDo

	MsgAlert("PROCESSO FINALIZADO.")

	// Somente mostra tela de log se encontrou algum NCM incorreto
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

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função gera o log                                   		               ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GeraLog(cLogErro)

	DEFAULT __cArqLog := "\log_tafncm\" + CriaTrab(,.F.) + "_as_" + Substr(Time(),1,2) + "-" + Substr(Time(),4,2) + ".log"

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
