#INCLUDE 'TBICONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS111MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  26/06/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclusao da solicitacao no banco                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS111MAN()
	Local cHtml:= ""
	Local cNum:= ""
	Local oAlert:= Nil
	Local cScript:= ""
	Local dData:= StoD(StrTran(HTTPPOST->PS100MAN_GET_DATA, "-", ""))
	Local cUser:= HTTPPOST->PS100MAN_GET_SOL
	Local cDesc:= HTTPPOST->PS100MAN_GET_DESC
	Local cSitua:= HTTPPOST->PS100MAN_GET_SITUACAO
	Local cMaq:= HTTPPOST->PS100MAN_GET_MAQUINA
	Local cCC:= HTTPPOST->PS100MAN_GET_CC
	Local cTipo:= HTTPPOST->PS100MAN_COMBO_TIPO
	Local cPrior:= HTTPPOST->PS100MAN_COMBO_PRIORIDADE
	Local dPrazo:= StoD(StrTran(HTTPPOST->PS100MAN_GET_PRAZO, "-", ""))
	Local cMauUso:= HTTPPOST->PS100MAN_COMBO_MAUUSO
	Local cPrevent:= HTTPPOST->PS100MAN_COMBO_PREVENTIVA
	Local cCorret:= HTTPPOST->PS100MAN_COMBO_CORRETIVA
	Local cMelhor:= HTTPPOST->PS100MAN_COMBO_MELHORIA
	Local cQualid:= HTTPPOST->PS100MAN_COMBO_QUALIDADE
	Local cMaqPar:= HTTPPOST->PS100MAN_COMBO_MAQUINA_PARADA
	Local lContinua:= .T.

	If ValType(HTTPSESSION->cEMP) == "U" .OR. ValType(HTTPSESSION->cFil) == "U" .OR. ValType(HTTPSESSION->cCC) == "U"
		cHtml:= "  $.ajax({"
		cHtml+= "          async: true,"
		cHtml+= "          method: 'POST',"
		cHtml+= "          url: 'u_ps001man.apw',"
		cHtml+= "         }).done(function(data){eval(data);});"
		Return cHtml
	EndIf

	lContinua:= lContinua .AND. !Empty(dData)
	lContinua:= lContinua .AND. !Empty(cUser)
	lContinua:= lContinua .AND. !Empty(cDesc)
	//lContinua:= lContinua .AND. !Empty(cSitua)
	lContinua:= lContinua .AND. !Empty(cPrior)
	lContinua:= lContinua .AND. !Empty(dPrazo)
	lContinua:= lContinua .AND. !Empty(cTipo)
	lContinua:= lContinua .AND. !Empty(cMaq)
	lContinua:= lContinua .AND. !Empty(cCC)
	lContinua:= lContinua .AND. !Empty(cMauUso)
	lContinua:= lContinua .AND. !Empty(cPrevent)
	lContinua:= lContinua .AND. !Empty(cCorret)
	lContinua:= lContinua .AND. !Empty(cMelhor)
	lContinua:= lContinua .AND. !Empty(cQualid)
	lContinua:= lContinua .AND. !Empty(cMaqPar)

	If lContinua

		If dPrazo < Date()
			oAlert:= PSWebAlert():New("ps111man_alert", "Prazo informado nao pode ser inferior a data de hoje.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
			Return cHtml
		EndIf

		//RPCSetType(3)
		RESET ENVIRONMENT
		PREPARE ENVIRONMENT EMPRESA HTTPSESSION->cEmp FILIAL HTTPSESSION->cFil

		dbSelectArea("ZP2")
		cNum:= NextNumero("ZP2", 1, "ZP2_CODIGO", .T.)
		RecLock("ZP2", .T.)
		ZP2->ZP2_FILIAL:= xFilial("ZP2")
		ZP2->ZP2_DATA:= dData
		ZP2->ZP2_USER:= cUser
		ZP2->ZP2_CODIGO:= cNum
		ZP2->ZP2_DESC:= U_PS002MAN(cDesc)
		ZP2->ZP2_HIST:= U_PS002MAN(cSitua)
		ZP2->ZP2_PRIOR:= cPrior
		ZP2->ZP2_LEGEND:= "<img src=imagens/verde.png>"
		ZP2->ZP2_STATUS:= "1 - Aberto (Solicitante)"
		ZP2->ZP2_PRAZO:= dPrazo
		ZP2->ZP2_TIPO:= cTipo
		ZP2->ZP2_MAQ:= cMaq
		ZP2->ZP2_CC:= cCC
		ZP2->ZP2_MAUUSO:= cMauUso
		ZP2->ZP2_PREVEN:= cPrevent
		ZP2->ZP2_CORRET:= cCorret
		ZP2->ZP2_MELHOR:= cMelhor
		ZP2->ZP2_QUALID:= cQualid
		ZP2->ZP2_MAQPAR:= cMaqPar
		ZP2->(MsUnLock())

		u_PS101MNT(cNum, "Solicitacao incluida")
		//u_PS100MNT(cNum, "Solicitacao '"+cNum+"' incluida", "A solicitacao '"+cNum+"' foi incluida dia "+DtoC(Date())+" as "+Time()+", para maiores informacoes consultar o portal de solicitacoes pelo endereco http://10.0.0.239:93/u_ps001man.apw.")
		u_PS100MNT(cNum, "Solicitacao '"+cNum+" ("+Alltrim(ZP2->ZP2_STATUS)+")", ZP2->ZP2_HIST+"<br>"+"Data "+DtoC(Date())+" as "+Time(), "")

		oAlert:= PSWebAlert():New("ps111man_alert", "Solicitacao '"+cNum+"' gerada com sucesso.", HTTPSESSION->cLogo)
		cHtml:= oAlert:show()

		cScript:= "  $.ajax({"
		cScript+= "          async: true,"
		cScript+= "          method: 'POST',"
		cScript+= "          url: 'u_ps101man.apw',"
		cScript+= "          data: {'PS100MAN_GET_USER':'"+HTTPSESSION->cUSER+"','PS100MAN_GET_PASS':'"+HTTPSESSION->cPASS+"'}"
		cScript+= "         }).done(function(data){eval(data);});"
		cHtml+= cScript
	Else
		oAlert:= PSWebAlert():New("ps111man_alert", "Um (ou mais) campo(s) obrigatorio(s) nao foi(foram) preenchido(s). Verifique a descricao dos campos com asterisco (*).", HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	EndIf

Return cHtml
