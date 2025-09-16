#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"   
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.ch" 

/*/{Protheus.doc} MT131WF
Ponto de Entrada para envio de workflow baseado nas informa็๕es de cota็๕es que estใo sendo geradas pela rotina em execu็ใo.
Possibilita preparar um e-mail customizado para os fornecedores contendo os itens a serem cotados para que possa ser respondido
pelo pr๓prio fornecedor selecionado.
@author 	Daniel
@since 		11/07/2019
@param		PARAMIXB[1] - Vetor - Elemento [1] do Vetor que armazena o n๚mero das Solicita็๕es de Compras que estใo relacionadas 
                                  na gera็ใo de cota็๕es. Representa a primeira SC selecionada. (Uma SC relacionada a cota็ใo)
			PARAMIXB[2] - Vetor - Vetor contendo todas as Solicita็๕es de Compras que estใo relacionadas na gera็ใo das cota็๕es 
			                      (Mais de uma SC relacionada a cota็ใo) ou quando houver quebra de uma mesma SC.
@return 	Nil, Fun็ใo nใo tem retorno
@obs 		As quebras de SC sใo geradas pela chave de ordena็ใo dos itens da SC ou pelo limite mแximo de itens.
			Para maiores informa็๕es sobre a chave de ordena็ใo que define a quebra de SC e limite mแximo de itens, 
			verificar a chave padrใo utilizada atualmente para determinar o crit้rio da quebra e o limite suportado de itens pelas rotinas.
/*/

User Function MT131WF(oProcess)

Local _aArea := GetArea()

Private aNumCot	 := {}
Private aItem	 := {}
Private aProd	 := {}
Private aFornec	 := {}
Private aLjFor	 := {}
Private aNForne	 := {}
Private aDtem	 := {}
Private aEmaF	 := {}
Private aQtdi	 := {}
Private aDtVa	 := {}
Private aSenha   := {}
Private cCodFor	 := "######"
Private cLojFor  := "##"
Private nVez	 := 1
Private _cEmlFor := SPACE(200)
Private cCGCPict := PesqPict("SA1","A1_CGC")

DbSelectArea("SC8")
DbSetOrder(1)
DbSeek(xFilial("SC8") + PARAMIXB[1])
While !Eof() .And. SC8->C8_FILIAL+SC8->C8_NUM == xFilial("SC8") + PARAMIXB[1]
	// Controla quebra para envio por fornecedor / loja
	If (SC8->C8_FORNECE <> cCodFor .Or. SC8->C8_LOJA <> cLojFor) .And. nVez > 1
		GerEmail()
		aNumCot	:= {}
		aItem	:= {}
		aProd	:= {}
		aFornec	:= {}
		aLjFor	:= {}
		aNForne	:= {}
		aDtem	:= {}
		aEmaF	:= {}
		aQtdi	:= {}
		aDtVa	:= {}
		aSenha  := {}
	Endif
	cCodFor := SC8->C8_FORNECE
	cLojFor := SC8->C8_LOJA
	nVez 	:= 2

	AADD(aNumCot, SC8->C8_NUM)
	AADD(aItem 	, SC8->C8_ITEM)
	AADD(aProd 	, SC8->C8_PRODUTO)
	AADD(aFornec, SC8->C8_FORNECE)
	AADD(aLjFor	, SC8->C8_LOJA)
	AADD(aNForne, GetAdvFVal("SA2", "A2_NOME", xFilial("SA2") + SC8->C8_FORNECE + SC8->C8_LOJA, 1, Space(TamSx3("A2_NOME")[1]), .T.)) 
	AADD(aDtem	, DTOS(SC8->C8_EMISSAO))
	AADD(aEmaF	, GetAdvFVal("SA2", "A2_EMAIL", xFilial("SA2") + SC8->C8_FORNECE + SC8->C8_LOJA, 1, Space(TamSx3("A2_EMAIL")[1]), .T.))
	AADD(aQtdi	, SC8->C8_QUANT)
	AADD(aDtVa	, DTOS(SC8->C8_VALIDA))
	AADD(aSenha	, Left(GetAdvFVal("SA2", "A2_CGC", xFilial("SA2") + SC8->C8_FORNECE + SC8->C8_LOJA, 1, Space(TamSx3("A2_CGC")[1]), .T.),6))

	DbSelectArea("SC8")
	DbSkip()
EndDo

If Len(aNumCot) > 0
	GerEmail()
Endif

RestArea(_aArea)

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GerEmail บ Autor ณ Daniel de Souza 	 บ Data ณ 11/07/2019  บฑฑ
ฑฑฬออออออออออุออออออออออผอออออออฯออออออออออออออออออออผออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para gera็ใo dos dados do E-mail.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GerEmail()

Local _oBtnCanc
Local _oBtnEnviar
Local _oGetAssun
Local _oGetEmail
Local _oGetPara
Local _oGrEnvio
Local _oLblAnexo
Local _oLblAssunt
Local _oLblEmail
Local _oLblPara
Local _oFontBtn   := TFont():New("Trebuchet MS",,017,,.F.,,,,,.F.,.F.)
Local _oFontLbl	  := TFont():New("Trebuchet MS",,018,,.T.,,,,,.F.,.F.)
Local _cGetAssun  := Space(250)
Local _cGetEmail  := Space(250)
Local _cGetPara	  := Space(250)		
Local _cNmFornec  := GetAdvFVal("SA2", "A2_NOME", xFilial("SA2") + aFornec[1] + aLjFor[1], 1, Space(TamSx3("A2_NOME")[1]), .T.) 
Local _cEmalForne := GetAdvFVal("SA2", "A2_EMAIL", xFilial("SA2") + aFornec[1] + aLjFor[1], 1, Space(TamSx3("A2_EMAIL")[1]), .T.)
Local _cContForne := GetAdvFVal("SA2", "A2_CONTATO", xFilial("SA2") + aFornec[1] + aLjFor[1], 1, Space(TamSx3("A2_CONTATO")[1]), .T.)
Local _cEnvEmail  := Space(250)

Private _oDlg

If Empty(AllTrim(_cEmalForne))
	MsgAlert("Nใo existe e-mail cadastrado para o Fornecedor." + Chr(13) + "Por favor, realize o cadastro do e-mail e tente novamente o envio.")
	Return()
EndIf

If !Empty(AllTrim(_cEmalForne))   
	_cEnvEmail := _cEmalForne
EndIf

_cGetEmail := _cEnvEmail + Space(150)
/*If AllTrim( RetCodUsr() ) == "000117"		// Se for usuแria Gianice
	_cGetPara := "compras@frigorificosilva.com.br" + Space(150)
ElseIf AllTrim( RetCodUsr() ) == "000995"	// Se for usuแrio Renan Santos
	_cGetPara := "compras2@frigorificosilva.com.br" + Space(150)
ElseIf AllTrim( RetCodUsr() ) == "000948"	// Se for usuแrio Gilvana Braz
	_cGetPara := "compras3@frigorificosilva.com.br" + Space(150)
Else										// Se for usuแrio Kaeny Albernaz
	_cGetPara := "compras4@frigorificosilva.com.br" + Space(150)
Endif*/
_cGetPara := "cotacoes@frigorificosilva.com.br" + Space(150)
_cGetAssun := "Nova Cota็ใo de Pre็os Nบ " + aNumCot[1] + " Aguardando Resposta -  A/C " + _cContForne

DEFINE MSDIALOG _oDlg TITLE "Envio de Cota็ใo para Fornecedor" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

@ 001, 002 GROUP _oGrEnvio TO 162, 251 OF _oDlg COLOR 0, 16777215 PIXEL

@ 008, 010 SAY _oLblEmail PROMPT "E-mail:" SIZE 028, 010 OF _oDlg FONT _oFontLbl COLORS 0, 16777215 PIXEL
@ 018, 010 MSGET _oGetEmail VAR _cGetEmail SIZE 230, 010 OF _oDlg COLORS 0, 16777215 PIXEL    

@ 033, 010 SAY _oLblPara PROMPT "Copia E-mail:" SIZE 058, 010 OF _oDlg FONT _oFontLbl COLORS 0, 16777215 PIXEL
@ 043, 010 MSGET _oGetPara VAR _cGetPara SIZE 230, 010 OF _oDlg COLORS 0, 16777215 PIXEL         

@ 059, 010 SAY _oLblAssunt PROMPT "Assunto:" SIZE 033, 010 OF _oDlg FONT _oFontLbl COLORS 0, 16777215 PIXEL
@ 069, 010 MSGET _oGetAssun VAR _cGetAssun SIZE 230, 010 OF _oDlg COLORS 0, 16777215 PIXEL    

@ 128, 002 BUTTON _oBtnEnviar PROMPT "Enviar" Action(_OkProc(_cGetEmail, _cGetPara, _cGetAssun)) SIZE 054, 018 OF _oDlg FONT _oFontBtn PIXEL
@ 128, 060 BUTTON _oBtnCanc PROMPT "Cancelar" Action(_CancProc()) SIZE 054, 018 OF _oDlg FONT _oFontBtn PIXEL    

ACTIVATE MSDIALOG _oDlg CENTERED

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _CancProc บ Autor ณ Daniel de Souza	 บ Data ณ 11/07/2019  บฑฑ
ฑฑฬออออออออออุอออออออออออผอออออออฯอออออออออออออออออออผออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cancela processo de envio da cota็ใo.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _CancProc()

_oDlg:End()
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _CancProc บ Autor ณ Daniel de Souza	 บ Data ณ 11/07/2019  บฑฑ
ฑฑฬออออออออออุออออออออออผอออออออฯออออออออออออออออออออผออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Secundaria de Processamento E-mail.                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _OkProc(_cEmail, _cPara, _cAssEmail)
    
Local _cAssunto  := ""
Local _cTexto	 := ""
Local _cMailDest := "" 

If Empty(AllTrim(_cEmail)) .OR. Empty(AllTrim(_cAssEmail))
	MsgAlert("Os seguintes campos sใo de preenchimento obrigat๓rio: E-mail e Assunto.","Aten็ใo")
	Return()	
EndIf

If !Empty(Alltrim(_cEmail))
   
	_cAssunto := AllTrim(_cAssEmail)
	
	_cTexto := '<html>'
	_cTexto += '<body>'
	DO CASE
		CASE AllTrim(cEmpAnt) == "01"	// Empresa Frigorํfico Silva
			_cTexto += '<div style="width: 776px;"><img src="http://portais.frigorificosilva.com.br:91/vendedor/imagens/logosilva.jpg" alt="" /></div>'
		CASE AllTrim(cEmpAnt) == "07"	// Empresa Transportadora
			_cTexto += '<div style="width: 776px;"><img src="http://portais.frigorificosilva.com.br:91/vendedor/imagens/logotransp.jpg" alt="" /></div>'
		CASE AllTrim(cEmpAnt) == "08"	// Empresa Graxaria
			_cTexto += '<div style="width: 776px;"><img src="http://portais.frigorificosilva.com.br:91/vendedor/imagens/logoracao.jpg" alt="" /></div>'
	OTHERWISE
			_cTexto += '<div style="width: 776px;"><img src="http://portais.frigorificosilva.com.br:91/vendedor/imagens/logosilva.jpg" alt="" /></div>'
	ENDCASE
	_cTexto += '<div style="width: 776px; font-family: Arial; font-size: 16px; color: #003366; text-align: center;"><strong>&nbsp;</strong></div>'
	_cTexto += '<p>Prezado Fornecedor,</p>'
	_cTexto += '<p>Convidamos a sua empresa para participar de uma nova concorr&ecirc;ncia conforme link abaixo.</p>'
	_cTexto += '<p><strong><span style="color: #0000ff;">Login: ' + aFornec[1] + '</span></strong></p>'
	_cTexto += '<p><strong><span style="color: #0000ff;">Senha: ' + aSenha[1] + '</span></strong></p>'
	_cTexto += '<!DOCTYPE html>'
	_cTexto += '<html>'
	_cTexto += '   <head>'
	_cTexto += '      <title>Title of the document</title>'
 	_cTexto += '     <style>'
	_cTexto += '         .button {'
	_cTexto += '         background-color: #1c87c9;'
	_cTexto += '         border: none;'
	_cTexto += '         color: white;'
	_cTexto += '         padding: 20px 34px;'
	_cTexto += '         text-align: center;'
	_cTexto += '         text-decoration: none;'
	_cTexto += '         display: inline-block;'
	_cTexto += '         font-size: 20px;'
 	_cTexto += '        margin: 4px 2px;'
	_cTexto += '         cursor: pointer;'
	_cTexto += '         }'
	_cTexto += '      </style>'
	_cTexto += '   </head>'
	_cTexto += '   <body>'
	_cTexto += '      <a href="http://compras.frigorificosilva.com.br:8180/fsilva/fornecedor/cotacao.php?cotacao=' + aNumCot[1] + '&amp;fornece=' + aFornec[1] + '&amp;lojaf=' + aLjFor[1] + '&amp;fil=' + cFilAnt + '&amp;emp=' + cEmpAnt + '" class="button">Acessar Cota็ใo</a>'
	_cTexto += '   </body>'
	_cTexto += '</html>'
	_cTexto += '<p><span style="color: #ffffff; background-color: #ff0000;"><em><strong>Em caso de problema com o acesso a cota&ccedil;&atilde;o, favor entrar em contato com um de nossos compradores.</strong></em></span></p>'
	_cTexto += '<p>O prazo para preenchimento da cota&ccedil;&atilde;o expira em ' + Substr(aDtVa[1],7,2) + '/' + Substr(aDtVa[1],5,2) + '/' + Subst(aDtVa[1],1,4) + ', podendo ser fechada a partir de 24:00hs de sua emiss&atilde;o.</p>'
	_cTexto += '<p><span style="color: #ff0000;"><strong><em><u>Importante:</u></em></strong></span></p>'
	_cTexto += '<p><span style="color: #ff0000;"><em>O documento que oficializar&aacute; a compra &eacute; o Pedido de Compra. Materiais e/o servi&ccedil;os s&oacute; poder&atilde;o ser entregues e faturados ap&oacute;s o envio formal deste pedido pelo comprador respons&aacute;vel.</em></span></p>'
	_cTexto += '<p><span style="color: #ff0000;"><em>&Eacute; obrigat&oacute;rio mencionar o n&uacute;mero do Pedido de Compra na Nota Fiscal.</em></span></p>'
	_cTexto += '<p>Obrigado!</p>'
	_cTexto += '<div>&nbsp;</div>'

	/*If AllTrim( RetCodUsr() ) == "000117"	// Se for usuแria Gianice
		_cTexto += '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p>'
		_cTexto += '<p>&nbsp;&cedil;.&middot;&acute;&cedil;.&middot;*&acute;&uml;) &cedil;.&middot;*&uml;)&nbsp;<br /> (&cedil;.&middot;&acute; *(&cedil;.&middot;`</p>'
		_cTexto += '<h4><strong><em>Gianice Weber de Oliveira da Palma</em></strong><em><br /> Gest&atilde;o de Suprimentos<br /> Frigor&iacute;fico Silva Ind&uacute;stria e Com&eacute;rcio Ltda<br /> Fone(55) 2103-2516&nbsp; &nbsp;Santa Maria/RS<br /> <a href="mailto:compras@frigorificosilva.com.br">compras@frigorificosilva.com.br</a></em></h4>'
		_cTexto += '</body>'
		_cTexto += '</html>'
	ElseIf AllTrim( RetCodUsr() ) == "000995"	// Se for usuแrio Renan Santos
		_cTexto += '<p>&nbsp;</p>'
		_cTexto += '<p><strong>Att.</strong></p>'
		_cTexto += '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;RENAN SANTOS<br /> Frigor&iacute;fico Silva Ind. &amp; Com. Ltda.<br /> &nbsp;&nbsp;&nbsp;CNPJ 88.728.027/0001-46<br /> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fone: 55 2103 2517<br /> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Fax: 55 2103 2505<br /> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Santa Maria/RS<br /> <a href="mailto:compras2@frigorificosilva.com.br">compras2@frigorificosilva.com.br</a></p>'
		_cTexto += '</body>'
		_cTexto += '</html>'
	ElseIf AllTrim( RetCodUsr() ) == "000948"	// Se for usuแrio Gilvana Braz
		_cTexto += '<p>&nbsp;</p>'
		_cTexto += '<p><strong>Att.</strong></p>'
		_cTexto += '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GILVANA BRAZ<br /> Frigor&iacute;fico Silva Ind. &amp; Com. Ltda.<br /> &nbsp;&nbsp;&nbsp;CNPJ 88.728.027/0001-46<br /> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fone: 55 2103 2517<br /> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Fax: 55 2103 2505<br /> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Santa Maria/RS<br /> <a href="mailto:compras3@frigorificosilva.com.br">compras3@frigorificosilva.com.br</a></p>'
		_cTexto += '</body>'
		_cTexto += '</html>'
	Else										// Se for usuแrio Kaeny Albernaz
		_cTexto += '<p>&nbsp;</p>'
		_cTexto += '<p><strong>Grata.</strong></p>'
		_cTexto += '<p>&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;KAENY MIOLA ALBERNAZ;</strong><br /> &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; Auxiliar de Suprimentos <br /> &nbsp;&nbsp; Frigor&iacute;fico Silva Ind. &amp; Com. Ltda <br /> &nbsp;&nbsp; &nbsp; &nbsp; &nbsp;Fone(55)2103-2525/R 2526 <br /> &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Santa Maria/RS <br /> &nbsp;&nbsp; &nbsp;<a href="mailto:compras4@frigorificosilva.com.br">compras4@frigorificosilva.com.br</a></p>'
		_cTexto += '</body>'
		_cTexto += '</html>'
	Endif*/
	_cTexto += '<p>&nbsp;</p>'
	_cTexto += '<p><strong>Em caso de d&uacute;vida, informar o n&uacute;mero da cota&ccedil;&atilde;o para agilizar seu atendimento.</strong></p>'
	_cTexto += '<h4><em>Att. Gest&atilde;o de Suprimentos<br /> Frigor&iacute;fico Silva Ind&uacute;stria e Com&eacute;rcio Ltda<br /> Fone(55) 2103-2516&nbsp;</em></h4>'
	_cTexto += '</body>'
	_cTexto += '</html>'

	//memowrite("ZZZ_MT130WF.TXT",_cTexto)
	_cMailDest := Alltrim(_cEmail)

	_EnvMail(_cMailDest, _cPara, _cAssunto, _cTexto)	

Endif

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _CancProc บ Autor ณ Daniel de Souza	 บ Data ณ 11/07/2019  บฑฑ
ฑฑฬออออออออออุออออออออออผอออออออฯออออออออออออออออออออผออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que Envia o E-mail.                 				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _EnvMail(_cMailDest, _cPara, _cAssunto, _cTexto)

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

	If !_lEnvEmail
		Return()
	EndIF

	// Faz a conexao com o servidor
	CONNECT SMTP SERVER _cServer ACCOUNT _cAccount PASSWORD _cPassword Result _lConectou
	If !_lConectou
		MsgAlert("ATENวรO!" + _cNL + "Nใo foi possํvel CONECTAR ao servidor de e-mail." + _cNL + "Por favor avise o TI." + _cNL + "Rotina _EnvMail no MT131WF.")
	EndIf

	// Faz o login no servidor
	_lLogou := mailAuth(_cAccount, _cPassword)
	If !_lLogou
		MsgAlert("ATENวรO!" + _cNL + "Nใo foi possํvel LOGAR no servidor de e-mail." + _cNL + "Por favor avise o TI." + _cNL + "Rotina _EnvMail no MT131WF.")
	EndIf

	// Faz o envio do e-mail
	If !Empty(_cPara)
		SEND MAIL FROM _cAccount TO _cMailDest CC _cPara SUBJECT _cAssunto BODY _cTexto FORMAT TEXT RESULT _lEnviou
	Else
		SEND MAIL FROM _cAccount TO _cMailDest SUBJECT _cAssunto BODY _cTexto FORMAT TEXT RESULT _lEnviou	
	EndIf

	If !_lEnviou
		MsgAlert("ATENวรO!" + _cNL + "Nใo foi possํvel ENVIAR o e-mail." + _cNL + "Por favor avise o TI." + _cNL + "Rotina _envMail no MT131WF.")
	Else
		MsgInfo("Cota็ใo de Compra enviado para o Fornecedor com Sucesso!","Informa็ใo")	
		_oDlg:End()
	EndIf

	// Desconecta do servidor
	DISCONNECT SMTP SERVER RESULT _lDesconect

Return   
