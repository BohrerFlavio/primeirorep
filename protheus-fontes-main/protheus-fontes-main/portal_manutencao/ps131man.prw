#INCLUDE 'TBICONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS131MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  07/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alteracao da solicitacao no banco                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS131MAN()
	Local cHtml:= ""
	Local cNum:= ""
	Local oAlert:= Nil
	Local cScript:= ""
	Local cFinal:= HTTPPOST->PS130MAN_COMBO_FINAL
	Local cSol:= HTTPPOST->PS130MAN_GET_SOLICITACAO
	Local dData:= StoD(StrTran(HTTPPOST->PS130MAN_GET_DATA, "-", ""))
	Local cUser:= HTTPPOST->PS130MAN_GET_SOL
	Local cDesc:= HTTPPOST->PS130MAN_GET_DESC
	Local cSitua:= HTTPPOST->PS130MAN_GET_SITUACAO
	Local cMaq:= HTTPPOST->PS130MAN_GET_MAQUINA
	Local cCC:= HTTPPOST->PS130MAN_GET_CC
	Local cTipo:= HTTPPOST->PS130MAN_COMBO_TIPO
	Local cPrior:= HTTPPOST->PS130MAN_COMBO_PRIORIDADE
	Local dPrazo:= StoD(StrTran(HTTPPOST->PS130MAN_GET_PRAZO, "-", ""))
	Local cMauUso:= HTTPPOST->PS130MAN_COMBO_MAUUSO
	Local cPrevent:= HTTPPOST->PS130MAN_COMBO_PREVENTIVA
	Local cCorret:= HTTPPOST->PS130MAN_COMBO_CORRETIVA
	Local cMelhor:= HTTPPOST->PS130MAN_COMBO_MELHORIA
	Local cQualid:= HTTPPOST->PS130MAN_COMBO_QUALIDADE
	Local lContinua:= .T.

	If ValType(HTTPSESSION->cEMP) == "U" .OR. ValType(HTTPSESSION->cFil) == "U" .OR. ValType(HTTPSESSION->cCC) == "U"
		cHtml:= "  $.ajax({"
		cHtml+= "          async: true,"
		cHtml+= "          method: 'POST',"
		cHtml+= "          url: 'u_ps001man.apw',"
		cHtml+= "         }).done(function(data){eval(data);});"
		Return cHtml
	EndIf

	//RPCSetType(3)
	RESET ENVIRONMENT
	PREPARE ENVIRONMENT EMPRESA HTTPSESSION->cEmp FILIAL HTTPSESSION->cFil

	ZP2->(dbSetOrder(1))
	If ZP2->(dbSeek(xFilial("ZP2")+cSol))

		If Left(ZP2->ZP2_STATUS, 1) == "1"
			lContinua:= lContinua .AND. !Empty(cFinal)
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
		ElseIf Left(ZP2->ZP2_STATUS, 1) == "4"
			lContinua:= lContinua .AND. !Empty(cFinal)
		EndIf

		If lContinua

			If cFinal == "S" .AND. Alltrim(HTTPSESSION->cUser) != Alltrim(ZP2->ZP2_USER)
				oAlert:= PSWebAlert():New("ps131man_alert", "Apenas o solicitante pode finalizar a solicitacao, verifique.", HTTPSESSION->cLogo)
				cHtml:= oAlert:show()
				Return cHtml
			EndIf

			//If dPrazo < Date()
			//	oAlert:= PSWebAlert():New("ps131man_alert", "Prazo informado nao pode ser inferior a data de hoje.", HTTPSESSION->cLogo)
			//	cHtml:= oAlert:show()
			//	Return cHtml
			//EndIf

			dbSelectArea("ZP2")
			RecLock("ZP2", .F.)
			If Left(ZP2->ZP2_STATUS, 1) == "1"
				ZP2->ZP2_DATA:= dData
				ZP2->ZP2_USER:= cUser
				ZP2->ZP2_CODIGO:= cSol
				ZP2->ZP2_DESC:= U_PS002MAN(cDesc)
				ZP2->ZP2_HIST:= U_PS002MAN(ZP2->ZP2_HIST)+Chr(13)+Chr(10)+U_PS002MAN(cSitua)
				ZP2->ZP2_PRIOR:= cPrior
				ZP2->ZP2_PRAZO:= dPrazo
				ZP2->ZP2_TIPO:= cTipo
				ZP2->ZP2_MAQ:= cMaq
				ZP2->ZP2_CC:= cCC
				ZP2->ZP2_MAUUSO:= cMauUso
				ZP2->ZP2_PREVEN:= cPrevent
				ZP2->ZP2_CORRET:= cCorret
				ZP2->ZP2_MELHOR:= cMelhor
				ZP2->ZP2_QUALID:= cQualid
				If cFinal == "S"
					ZP2->ZP2_STATUS:= "5 - Finalizado (Solicitante)"
					ZP2->ZP2_LEGEND:= "<img src=imagens/vermelho.png>"
					ZP2->ZP2_DTRFIM:= Date()
					ZP2->ZP2_HRRFIM:= Left(Time(), 5)
				Else
					ZP2->ZP2_STATUS:= "1 - Reativado (Solicitante)"
					ZP2->ZP2_LEGEND:= "<img src=imagens/roxo.png>"
					ZP2->ZP2_DTFIN:= StoD("")
					ZP2->ZP2_HRFIN:= ""
					ZP2->ZP2_REATIV:= "S"
				EndIf
			ElseIf Left(ZP2->ZP2_STATUS, 1) == "4"
				If cFinal == "S"
					ZP2->ZP2_STATUS:= "5 - Finalizado (Solicitante)"
					ZP2->ZP2_LEGEND:= "<img src=imagens/vermelho.png>"
					ZP2->ZP2_DTRFIM:= Date()
					ZP2->ZP2_HRRFIM:= Left(Time(), 5)
					ZP2->ZP2_HIST:= U_PS002MAN(ZP2->ZP2_HIST)+Chr(13)+Chr(10)+U_PS002MAN(cSitua)
				Else
					ZP2->ZP2_STATUS:= "1 - Reativado (Solicitante)"
					ZP2->ZP2_LEGEND:= "<img src=imagens/roxo.png>"
					ZP2->ZP2_DTFIN:= StoD("")
					ZP2->ZP2_HRFIN:= ""
					ZP2->ZP2_HIST:= U_PS002MAN(ZP2->ZP2_HIST)+Chr(13)+Chr(10)+U_PS002MAN(cSitua)
					ZP2->ZP2_REATIV:= "S"
				EndIf
			EndIf
			ZP2->(MsUnLock())

			u_PS101MNT(cSol, "Solicitacao alterada")
			//u_PS100MNT(cSol, "Solicitacao '"+cSol+"' alterada", "A solicitacao '"+cSol+"' foi alterada dia "+DtoC(Date())+" as "+Time()+", para maiores informacoes consultar o portal de solicitacoes pelo endereco http://10.0.0.239:93/u_ps001man.apw.")
			u_PS100MNT(cSol, "Solicitacao '"+cSol+" ("+Alltrim(ZP2->ZP2_STATUS)+")", ZP2->ZP2_HIST+"<br>"+"Data "+DtoC(Date())+" as "+Time(), "")

			cScript:= "  $.ajax({"
			cScript+= "          async: true,"
			cScript+= "          method: 'POST',"
			cScript+= "          url: 'u_ps101man.apw',"
			cScript+= "          data: {'PS100MAN_GET_USER':'"+HTTPSESSION->cUSER+"','PS100MAN_GET_PASS':'"+HTTPSESSION->cPASS+"'}"
			cScript+= "         }).done(function(data){eval(data);});"
			cHtml+= cScript
		Else
			oAlert:= PSWebAlert():New("ps131man_alert", "Um (ou mais) campo(s) obrigatorio(s) nao foi(foram) preenchido(s). Verifique a descricao dos campos com asterisco (*).", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
		EndIf
	Else
		oAlert:= PSWebAlert():New("ps131man_alert", "Solicitacao "+cSol+", nao encontrada.", HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	EndIf

Return cHtml
