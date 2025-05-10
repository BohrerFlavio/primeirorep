#INCLUDE "AP5MAIL.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.ch"

/*/{Protheus.doc} STI_CP50
Rotina para envio de e-mail de pedido de compra para o fornecedor
@author 	Evandro Mugnol
@since 		29/01/2019
@return 	Nil, Fun็ใo nใo tem retorno
@obs 		N/A
/*/

User Function STI_CP50(_cFilial, _cNumPC, _cFornec, _cLoja)

	Local _oBtnCanc
	Local _oBtnEnviar
	Local _oGetAssun
	Local _oGetEmail
	Local _oGetPara
	Local _oGrEnvio
	Local _oLblAnexo
	Local _oLblAssunt
	Local _oLblTpFret
	Local _oLblTransp
	Local _oLblDesc
	Local _oLblEmail
	Local _oLblPara
	Local _oGetDesc
	Local _oFontBtn   	:= TFont():New("Trebuchet MS",,017,,.F.,,,,,.F.,.F.)
	Local _oFontLbl	  	:= TFont():New("Trebuchet MS",,018,,.T.,,,,,.F.,.F.)
	Local _cGetAssun  	:= Space(250)
	Local _cGetEmail  	:= Space(250)
	Local _cGetDesc   	:= Space(250)
	Local _cGetPara	  	:= Space(250)		
	Local _cFilial		:= AllTrim(_cFilial)
	Local _cPedCmp		:= AllTrim(_cNumPC)
	Local _cFornec		:= AllTrim(_cFornec)
	Local _cLoja	  	:= AllTrim(_cLoja)
	Local _cNmFornec 	:= GetAdvFVal("SA2", "A2_NOME", FWxFilial("SA2") + _cFornec + _cLoja, 1, Space(TamSx3("A2_NOME")[1]), .T.) 
	Local _cEmalForne	:= GetAdvFVal("SA2", "A2_EMAIL", FWxFilial("SA2") + _cFornec + _cLoja, 1, Space(TamSx3("A2_EMAIL")[1]), .T.)
	Local _cEnvEmail	:= Space(250)

	Private _oDlg
	Private _oGetTrans
	Private _oGetNomTr
	Private _oGetTpFrt
	Private _cGetTrans 	:= Space(006)
	Private _cGetNomTr  := Space(060)
	Private _cGetTpFrt  := Space(001)
	Private _cDirOri  	:= "C:\Temp\"
	Private _cDirOriPdf := ""
	Private _cDirDST  	:= "\system\pdfcompra\"
	Private _aFiles	  	:= {}
	Private _cUsrCod	:= RetCodUsr()
	Private _cUsrMail	:= alltrim(UsrRetMail(_cUsrCod))
	Private _cUsrName	:= upper(alltrim(UsrFullName(_cUsrCod)))

	If Empty(AllTrim(_cEmalForne))
		MsgAlert("Nใo existe e-mail cadastrado para o Fornecedor." + Chr(13) + "Por favor, realize o cadastro do e-mail e tente novamente o envio.")
		Return()
	EndIf

	DbSelectArea("SC7")
	DBSetOrder(1)
	MsSeek(FWxFilial("SC7") + _cPedCmp)

	// Gera o Relatorio em PDF
	U_STI_CP51("2", _cPedCmp, _cFilial, 1, 1, 1, AllTrim(_cNmFornec))

	// Copia o Relatorio para a pasta temporaria.
	_cDirOriPdf := _cDirOri + STRTRAN(STRTRAN(STRTRAN(STRTRAN(AllTrim(_cNmFornec)," ","_"),"-",""),".",""),"/","") + "_" + AllTrim(_cFilial) + "_" + AllTrim(_cPedCmp)
	_aFiles	 	:= Directory(_cDirOriPdf + ".pdf")

	If !Empty(AllTrim(_cEmalForne))
		_cEnvEmail := _cEmalForne
	EndIf

	_cGetEmail 	:= _cEnvEmail + Space(150)
	/*If AllTrim( __CUSERID ) == "000117"		// Se for usuแria Gianice
		_cGetPara := "compras@frigorificosilva.com.br,cotacoes@frigorificosilva.com.br" + Space(150)
	ElseIf AllTrim( __CUSERID ) == "001081"		// Se for usuแrio Adriano Rodrigues
		_cGetPara := "compras1@frigorificosilva.com.br,cotacoes@frigorificosilva.com.br" + Space(150)
	ElseIf AllTrim( __CUSERID ) == "000128"	// Se for usuแrio Henrique Andrade
		_cGetPara := "compras2@frigorificosilva.com.br,cotacoes@frigorificosilva.com.br" + Space(150)
	ElseIf AllTrim( __CUSERID ) == "000948"	// Se for usuแrio Gilvana Braz
		_cGetPara := "compras3@frigorificosilva.com.br,cotacoes@frigorificosilva.com.br" + Space(150)
	Else										// Se for usuแrio Kaeny Albernaz
		_cGetPara := "compras4@frigorificosilva.com.br,cotacoes@frigorificosilva.com.br" + Space(150)
	Endif*/
	_cGetPara  := _cUsrMail + ",cotacoes@frigorificosilva.com.br" + Space(150)
	_cGetAssun := "Pedido de Compra Nบ " + _cPedCmp + " - " + _cNmFornec + Space(150)
	//_cGetDesc   := "Prezado Fornecedor Segue em Anexo Pdf do Pedido de Compra Nบ " + _cPedCmp + " Frigorํfico Silva Ltda." + Space(150)

	DEFINE MSDIALOG _oDlg TITLE "Envio Pedido de Compra para Fornecedor" FROM 000, 000  TO 390, 500 COLORS 0, 16777215 PIXEL

	@ 001, 002 GROUP _oGrEnvio TO 162, 251 OF _oDlg COLOR 0, 16777215 PIXEL

	@ 008, 010 SAY _oLblEmail PROMPT "E-mail:" SIZE 028, 010 OF _oDlg FONT _oFontLbl COLORS 0, 16777215 PIXEL
	@ 018, 010 MSGET _oGetEmail VAR _cGetEmail SIZE 230, 010 OF _oDlg COLORS 0, 16777215 PIXEL

	@ 033, 010 SAY _oLblPara PROMPT "Copia E-mail:" SIZE 058, 010 OF _oDlg FONT _oFontLbl COLORS 0, 16777215 PIXEL
	@ 043, 010 MSGET _oGetPara VAR _cGetPara SIZE 230, 010 OF _oDlg COLORS 0, 16777215 PIXEL

	@ 059, 010 SAY _oLblAssunt PROMPT "Assunto:" SIZE 033, 010 OF _oDlg FONT _oFontLbl COLORS 0, 16777215 PIXEL
	@ 069, 010 MSGET _oGetAssun VAR _cGetAssun SIZE 230, 010 OF _oDlg COLORS 0, 16777215 PIXEL

	@ 084, 010 SAY _oLblDesc PROMPT "Descri็ใo E-mail:" SIZE 060, 010 OF _oDlg FONT _oFontLbl COLORS 0, 16777215 PIXEL
	@ 094, 010 MSGET _oGetDesc VAR _cGetDesc SIZE 230, 010 OF _oDlg COLORS 0, 16777215 PIXEL

	@ 109, 010 SAY _oLblTransp PROMPT "Transportadora:" SIZE 060, 010 OF _oDlg FONT _oFontLbl COLORS 0, 16777215 PIXEL
	@ 119, 010 MSGET _oGetTrans VAR _cGetTrans Picture "@!" WHEN .T. VALID Vazio() .Or. _VldTra() F3 "SA4" SIZE 045, 010 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 119, 060 MSGET _oGetNomTr VAR _cGetNomTr Picture "@!" WHEN .F. SIZE 180, 010 OF _oDlg COLORS 0, 16777215 PIXEL

	@ 134, 010 SAY _oLblTpFret PROMPT "Tipo do Frete:" SIZE 060, 010 OF _oDlg FONT _oFontLbl COLORS 0, 16777215 PIXEL
	@ 144, 010 MSCOMBOBOX _oGetTpFrt VAR _cGetTpFrt ITEMS {"C-CIF","F-FOB","T-Por Conta Terceiros","R-Por Conta Remetente","D-Por Conta Destinatแrio","S-Sem Frete"} SIZE 80, 12 OF _oDlg COLORS 0, 16777215 PIXEL

	@ 164, 010 SAY _oLblAnexo PROMPT "Anexo Gerado com Sucesso!" SIZE 150, 010 OF _oDlg FONT _oFontLbl COLOR CLR_HRED PIXEL

	@ 175, 002 BUTTON _oBtnEnviar PROMPT "Enviar" Action(_OkProc(_cGetEmail, _cGetPara, _cGetAssun, _cGetDesc, _cFilial, _cPedCmp, _cFornec, _cLoja)) SIZE 054, 018 OF _oDlg FONT _oFontBtn PIXEL
	@ 175, 060 BUTTON _oBtnCanc PROMPT "Cancelar" Action(_CancProc()) SIZE 054, 018 OF _oDlg FONT _oFontBtn PIXEL

	ACTIVATE MSDIALOG _oDlg CENTERED

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _VldTra   บ Autor ณ Evandro Mugnol	 บ Data ณ 29/01/2019  บฑฑ
ฑฑฬออออออออออุอออออออออออผอออออออฯอออออออออออออออออออผออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Efetua consist๊ncia na transportadora informada.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _VldTra()

	_lRet := .T.
	DbSelectArea("SA4")
	MsSeek(FWxFilial("SA4") + _cGetTrans)
	If Found()
		_cGetNomTr := SA4->A4_NOME
	Else
		MsgAlert("Transportadora Informada Nใo Existe. Verifique!")
		_lRet := .F.
	Endif

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _CancProc บ Autor ณ Evandro Mugnol	 บ Data ณ 29/01/2019  บฑฑ
ฑฑฬออออออออออุอออออออออออผอออออออฯอออออออออออออออออออผออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cancela processo e elimina Pdf Criado no load da tela.     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _CancProc()

	Local _cArquivo  := ""
	Local i

	For i := 1 To Len(_aFiles)

		_cArquivo := Alltrim(_cDirOri) + Alltrim(_aFiles[i,1])

		// Deleta Arquivo da Area de Importacao
		If File(_cArquivo)
			Ferase(_cArquivo)
		EndIf
		
	Next i

	_oDlg:End()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _OkProc  บ Autor ณ Evandro Mugnol 	 บ Data ณ 29/01/2019  บฑฑ
ฑฑฬออออออออออุออออออออออผอออออออฯออออออออออออออออออออผออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Secundaria de Processamento E-mail.                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _OkProc(_cEmail, _cPara, _cAssEmail, _cDesc, _cFilial, _cPedCmp, _cFornec, _cLoja)

	Local _cArquivo  := ""
	Local _cArqBKP 	 := ""
	Local _cAssunto  := ""
	Local _cTexto	 := ""
	Local _cMailDest := ""
	Local i

	If Empty(AllTrim(_cEmail)) .OR. Empty(AllTrim(_cAssEmail))
		MsgAlert("Os seguintes campos sใo de preenchimento obrigat๓rio: E-mail e Assunto.","Aten็ใo")
		Return()
	EndIf

	For i := 1 To Len(_aFiles)

		_cArquivo := Alltrim(_cDirOri) + Alltrim(_aFiles[i,1])
		_cArqBKP  := Alltrim(_cDirDST) + Alltrim(_aFiles[i,1])

		copy file (_cArquivo) to (_cArqBkp) // Copia Arquivo Importado Para Diretorio de BackUp

		If !Empty(Alltrim(_cEmail))

			_cAssunto := AllTrim(_cAssEmail)

			If !Empty(_cDesc)
				_cTexto := "<html>"
				_cTexto += "<body>"
				_cTexto += '<font face="Arial"><h4 align="Center" style="color: #000000;">------------------------------------------- ATENCรO PEDIDO DE COMPRA -------------------------------------------</h4>'
				_cTexto += '<p align="center">' + Alltrim(_cDesc) + '</p>'
				_cTexto += '<p align="center">E-mail Automแtico. Por Favor nใo Responder.</p>'
				_cTexto += '</body>'
				_cTexto += '</html>'
			Else
				/*
				_cTexto := "<html>"
				_cTexto += "<body>"
				_cTexto += '<p style="background: white;"><strong><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: red;">SEGUE EM ANEXO NOSSO PEDIDO DE COMPRA</span></strong></p>'
				_cTexto += '<p style="background: white;"><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: black;">FAVOR INFORMAR NA NF O NUMERO DO PEDIDO, CUIDAR O CNPJ DO PEDIDO, TENS QUE SER O MESMO DA NF INFORMADO NA COTA&Ccedil;&Atilde;O.</span></p>'
				_cTexto += '<p style="background: white;"><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: black;">N&Atilde;O ACEITAMOS TOLER&Acirc;NCIA NEM VALOR DIVERGENTE COM NOSSO PEDIDO, QUANTIDADES EXCEDENTES SER&Atilde;O RECUSADAS NO ATO DO RECEBIMENTO OU DEVOLVIDAS SEM PREVIA AUTORIZA&Ccedil;&Atilde;O COM FRETE POR CONTA DO DESTINAT&Aacute;RIO(FORNECEDOR).</span></p>'
				_cTexto += '<p style="background: white;"><span style="font-family: "Arial",sans-serif; color: black;"><strong><span style="font-family:" Arial",sans-serif;">FAVOR ENVIAR O ARQUIVO XML para&nbsp;</span></strong></span><span class="xobject"><strong><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: #005a95;"><a href="mailto:recebimento@frigorificosilva.com.br" target="_blank"><span style="color: darkblue;">recebimento@frigorificosilva.com.br</span></a></span></strong></span><strong><span style="font-family: "Arial",sans-serif; color: black;">&nbsp;</span></strong><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: black;">COM COPIA/ ESPELHO DA NF PARA<strong><span style="font-family: "Arial",sans-serif;">&nbsp;</span></strong></span><span class="xobject"><strong><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: #005a95;"><a href="mailto:compras@frigorificosilva.com.br" target="_blank"><span style="color: darkblue;">compras@frigorificosilva.com.br</span></a></span></strong></span></p>'
				_cTexto += '<p style="background: white;"><strong><span style="font-size: 13.5pt; font-family: "Arial",sans-serif; color: red;">O N&Atilde;O RECEBIMENTO DO ARQUIVO XML DA NF NO ATO DO RECEBIMENTO ACARRETAR&Aacute; NO N&Atilde;O RECEBIMENTO DA MERCADORIA</span></strong></p>'
				_cTexto += '<p style="background: white;"><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: black;">TRANSPORTADORA</span><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: red;">:&nbsp;</span><strong><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: green;">FRETE -</span></strong></p>'
				_cTexto += '<p style="background: white;"><strong><em><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: fuchsia;">CUIDAR AS DATAS DE FATURAMENTO&nbsp; - DATA ENTREGA QUE CONSTA NO PEDIDO &Eacute; A DATA PARA FATURAR A MERCADORIA</span></em></strong><strong><em><span style="font-family: "Arial",sans-serif; color: red;">.</span></em></strong></p>'
				_cTexto += '<p style="background: white;"><strong><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: green;">OBS. FAVOR CONFIRMAR RECEBIMENTO DESTE. MATERIAL CONFORME&nbsp; COTADO</span></strong></p>'
				_cTexto += '<p style="background: white;"><strong><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: red;">ATEN&Ccedil;&Atilde;O: N&Atilde;O FAREMOS PAGAMENTOS DE T&Iacute;TULOS NEGOCIADOS COM FACTORING OU TERCEIROS.</span></strong></p>'
				_cTexto += '<p style="background: white;"><strong><span style="font-size: 10.0pt; font-family: "Arial",sans-serif; color: red;">CASO QUEIRA ANTECIPAR O RECEBIMENTO ENTRE EM CONTATO COM NOSSO SETOR FINANCEIRO*&acute;&uml;</span></strong></p>'
				_cTexto += '<p class="xmsonormal"><span style="color: black;">&nbsp;</span></p>'
				_cTexto += '<p style="background: white;"><span style="font-size: 10.0pt; font-family: "Courier New"; color: black;">&nbsp;&cedil;.&middot;&acute;&cedil;.&middot;*&acute;&uml;) &cedil;.&middot;*&uml;)&nbsp;<br />(&cedil;.&middot;&acute; *(&cedil;.&middot;`&nbsp;<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GIANICE WEBER DE OLIVEIRA&nbsp;<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Gest&atilde;o de Suprimentos&nbsp;<br />&nbsp;&nbsp;&nbsp;Frigor&iacute;fico Silva Ind. &amp; Com. Ltda&nbsp;<br />Fone(55)2103-2525/R2516 Fax(55)2103-2505&nbsp;<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Santa Maria/RS&nbsp;<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><a href="mailto:compras@frigorificosilva.com.br"><span style="font-size: 10.0pt; font-family: "Courier New"; color: blue;">compras@frigorificosilva.com.br</span></a></p>'
				_cTexto += '</body>'
				_cTexto += '</html>'
				*/
				_cTexto := '<html>'
				_cTexto += '<body>'
				_cTexto += '<h2><strong>SEGUE EM ANEXO NOSSO PEDIDO DE COMPRA</strong>&nbsp; &nbsp;</h2>'
				_cTexto += '<h3>Favor informar na nota fiscal o n&uacute;mero de nosso pedido de compra que consta no assunto acima. Cuidado! O CNPJ dever&aacute; ser o mesmo informado no ato da cota&ccedil;&atilde;o.</h3>'
				_cTexto += '<h3>N&atilde;o aceitamos mercadorias divergentes e toler&acirc;ncias, quantidades excedentes ser&atilde;o recusadas no ato do recebimento ou devolvidas sem pr&eacute;via autoriza&ccedil;&atilde;o com frete por conta do fornecedor. O arquivo&nbsp;<strong>XML</strong>&nbsp;dever&aacute; ser enviado para<strong>&nbsp;<a href="mailto:centralxml@frigorificosilva.com.br">centralxml@frigorificosilva.com.br</a>&nbsp;</strong>com c&oacute;pia da danfe para&nbsp;<strong><a href="mailto:recebimento@frigorificosilva.com.br">recebimento@frigorificosilva.com.br</a></strong></h3>'
				_cTexto += '<h2><strong>O N&Atilde;O RECEBIMENTO DO ARQUIVO XML DA NF NO ATO DO RECEBIMENTO ACARRETAR&Aacute; NO N&Atilde;O RECEBIMENTO DA MERCADORIA</strong></h2>'
				_cTexto += '<h3>A data que consta no pedido &eacute; a data para faturar a mercadoria.&nbsp;</h3>'
				_cTexto += '<h3>N&atilde;o realizamos pagamentos de t&iacute;tulos negociados com factoring ou terceiros, caso queira antecipar o recebimento favor entrar em contato com nosso setor financeiro.</h3>'
				_cTexto += '<h3>Nossos pagamentos, a partir de janeiro de 2024, ser&atilde;o realizados somente &agrave;s ter&ccedil;as e sextas-feiras.</h3>'
				_cTexto += '<h2><strong>Favor confirmar recebimento deste e-mail. Material conforme cotado.</strong></h2>'

				If !Empty(_cGetTrans)
					_cTexto += '<h2><strong><u>Transportadora</u></strong></h2>'
					_cTexto += '<h3>'+Alltrim(_cGetNomTr)+'</h3>'
				Else
					if _cGetTpFrt != "T-Por Conta Terceiros"
						_cTexto += '<h2><strong><u>Transportadoras:</u></strong></h2>'
						_cTexto += '<h2><strong>RS/SC/PR</strong></h2>'
						_cTexto += '<h4>Peso at&eacute; 100kg - Expresso Sใo Miguel/Alfa Transportes/NIMEC/Translovato/Braspress</h4>'
						_cTexto += '<h4>Peso acima de 100kg - Expresso Sใo Miguel/Alfa Transportes/NIMEC</h4>'
						_cTexto += '<h2><strong>SP e demais regi&otilde;es -</strong>Expresso Sใo Miguel/Alfa Transportes/NIMEC</h2>'
					endif
				Endif

				DO CASE
					CASE _cGetTpFrt == "C-CIF" .or. _cGetTpFrt == "R-Por Conta Remetente"
						_cTexto += '<h2>Frete: CIF - Por Conta Remetente (sem custo para destinat&aacute;rio)</h2>'
					CASE _cGetTpFrt == "F-FOB" .or. _cGetTpFrt == "D-Por Conta Destinatแrio"
						_cTexto += '<h2>Frete: FOB - Por Conta Destinat&aacute;rio</h2>'
					CASE _cGetTpFrt == "T-Por Conta Terceiros"
						_cTexto += '<h2>Frete: Terceiros - O pedido serแ coletado pela Transportadora Arrieche da Silva - CNPJ 08.708.477/0001-38.</h2>'
						_cTexto += '<h2>Assim que a NF for emitida, favor encaminhแ-la neste e-mail para agendamento de coleta.</h2>'
					/*CASE _cGetTpFrt == "R-Por Conta Remetente" 
						_cTexto += '<h2>Frete: Por Conta Remetente</h2>'
					CASE _cGetTpFrt == "D-Por Conta Destinatแrio" 
						_cTexto += '<h2>Frete: Por Conta Destinat&aacute;rio</h2>'*/
					CASE _cGetTpFrt == "S-Sem Frete" 
						_cTexto += '<h2>Frete: Sem Frete - Opera็ใo triangular. Verificar endere็o de destino com o setor de suprimentos.</h2>'
				ENDCASE
				If AllTrim( __CUSERID ) == "000117"	// Se for usuแria Gianice
					_cTexto += '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p>'
					_cTexto += '<p>&nbsp;&cedil;.&middot;&acute;&cedil;.&middot;*&acute;&uml;) &cedil;.&middot;*&uml;)&nbsp;<br /> (&cedil;.&middot;&acute; *(&cedil;.&middot;`</p>'
					_cTexto += '<h4><strong><em>Gianice Weber de Oliveira da Palma</em></strong><em><br /> Gest&atilde;o de Suprimentos<br /> Frigor&iacute;fico Silva Ind&uacute;stria e Com&eacute;rcio Ltda<br /> Fone(55) 2103-2516&nbsp; &nbsp;Santa Maria/RS<br /> <a href="mailto:compras@frigorificosilva.com.br">compras@frigorificosilva.com.br</a></em></h4>'
					_cTexto += '</body>'
					_cTexto += '</html>'
				/*ElseIf AllTrim( __CUSERID ) == "001081"	// Se for usuแrio Adriano Rodrigues
					_cTexto += '<p>&nbsp;</p>'
					_cTexto += '<p><strong>Att.</strong></p>'
					_cTexto += '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ADRIANO RODRIGUES<br /> Frigor&iacute;fico Silva Ind. &amp; Com. Ltda.<br /> &nbsp;&nbsp;&nbsp;CNPJ 88.728.027/0001-46<br /> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fone: 55 2103 2517<br /> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Fax: 55 2103 2505<br /> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Santa Maria/RS<br /> <a href="mailto:compras1@frigorificosilva.com.br">compras1@frigorificosilva.com.br</a></p>'
					_cTexto += '</body>'
					_cTexto += '</html>'
				ElseIf AllTrim( __CUSERID ) == "000128"	// Se for usuแrio Henrique Andrade
					_cTexto += '<p>&nbsp;</p>'
					_cTexto += '<p><strong>Att.</strong></p>'
					_cTexto += '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;HENRIQUE ANDRADE<br /> Frigor&iacute;fico Silva Ind. &amp; Com. Ltda.<br /> &nbsp;&nbsp;&nbsp;CNPJ 88.728.027/0001-46<br /> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fone: 55 2103 2517<br /> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Fax: 55 2103 2505<br /> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Santa Maria/RS<br /> <a href="mailto:compras2@frigorificosilva.com.br">compras2@frigorificosilva.com.br</a></p>'
					_cTexto += '</body>'
					_cTexto += '</html>'
				ElseIf AllTrim( __CUSERID ) == "000948"	// Se for usuแrio Gilvana Braz
					_cTexto += '<p>&nbsp;</p>'
					_cTexto += '<p><strong>Att.</strong></p>'
					_cTexto += '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GILVANA BRAZ<br /> Frigor&iacute;fico Silva Ind. &amp; Com. Ltda.<br /> &nbsp;&nbsp;&nbsp;CNPJ 88.728.027/0001-46<br /> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fone: 55 2103 2517<br /> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Fax: 55 2103 2505<br /> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Santa Maria/RS<br /> <a href="mailto:compras3@frigorificosilva.com.br">compras3@frigorificosilva.com.br</a></p>'
					_cTexto += '</body>'
					_cTexto += '</html>'*/
				Else										// Se for qualquer outro usuแrio
					_cTexto += '<p>&nbsp;</p>'
					_cTexto += '<p><strong>Att.</strong></p>'
					_cTexto += '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + _cUsrName + '<br /> Frigor&iacute;fico Silva Ind. &amp; Com. Ltda.<br /> &nbsp;&nbsp;&nbsp;CNPJ 88.728.027/0001-46<br /> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fone: 55 2103 2517<br /> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Fax: 55 2103 2505<br /> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Santa Maria/RS<br /> <a href="mailto:' + _cUsrMail + '">' + _cUsrMail + '</a></p>'
					_cTexto += '</body>'
					_cTexto += '</html>'
				Endif
			Endif

			_cMailDest := Alltrim(_cEmail)

			_EnvMail(_cMailDest, _cPara, _cAssunto, _cTexto, _cArqBkp, _cFilial, _cPedCmp, _cFornec, _cLoja)

		Endif

		// Deleta Arquivo da Area de Importacao
		If File(_cArqBkp) 
			Ferase(_cArqBkp)
			Ferase(_cArquivo)
		EndIf

	Next i

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _EnvMail บ Autor ณ Evandro Mugnol	 บ Data ณ 29/01/2019  บฑฑ
ฑฑฬออออออออออุออออออออออผอออออออฯออออออออออออออออออออผออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que Envia o E-mail.                 				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _EnvMail(_cMailDest, _cPara, _cAssunto, _cTexto, _cArqBkp, _cFilial, _cPedCmp, _cFornec, _cLoja)

	// Parametros para envio de email
	Local _cServer    := alltrim(GETMV('SI_COTSERV')) 	// Endereco SMTP
	Local _cAccount   := alltrim(GETMV('SI_COTACNT')) 	// Conta
	Local _cPassword  := alltrim(GETMV('SI_COTPSW'))  	// Senha
	Local _lEnvEmail  := .T.
	Local _lConectou  := .F.
	Local _lLogou     := .F.
	Local _lEnviou    := .F.
	Local _lDesconect := .F.
	Local _cNL        := CHR(13) + CHR(10)
	//Local _lGrvStatus := .F.

	If !_lEnvEmail
		Return()
	EndIF

	// Faz a conexao com o servidor
	CONNECT SMTP SERVER _cServer ACCOUNT _cAccount PASSWORD _cPassword Result _lConectou
	If !_lConectou
		MsgAlert("ATENวรO!" + _cNL + "Nใo foi possํvel CONECTAR ao servidor de e-mail." + _cNL + "Por favor avise o TI." + _cNL + "Rotina _EnvMail no STI_CP50.")
	EndIf

	// Faz o login no servidor
	_lLogou := mailAuth(_cAccount, _cPassword)
	If !_lLogou
		MsgAlert("ATENวรO!" + _cNL + "Nใo foi possํvel LOGAR no servidor de e-mail." + _cNL + "Por favor avise o TI." + _cNL + "Rotina _EnvMail no STI_CP50.")
	EndIf

	// Faz o envio do e-mail
	If !Empty(_cPara)
		SEND MAIL FROM _cAccount TO _cMailDest CC _cPara SUBJECT _cAssunto BODY _cTexto ATTACHMENT _cArqBkp FORMAT TEXT RESULT _lEnviou
	Else
		SEND MAIL FROM _cAccount TO _cMailDest SUBJECT _cAssunto BODY _cTexto ATTACHMENT _cArqBkp FORMAT TEXT RESULT _lEnviou
	EndIf

	If !_lEnviou
		MsgAlert("ATENวรO!" + _cNL + "Nใo foi possํvel ENVIAR o e-mail." + _cNL + "Por favor avise o TI." + _cNL + "Rotina _envMail no STI_CP50.")
	Else
		MsgInfo("Pedido de Compra enviado para o Fornecedor com Sucesso!","Informa็ใo")
		_oDlg:End()
	EndIf

	// Desconecta do servidor
	DISCONNECT SMTP SERVER RESULT _lDesconect

Return
