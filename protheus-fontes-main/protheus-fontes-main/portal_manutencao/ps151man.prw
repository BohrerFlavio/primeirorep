#INCLUDE 'TBICONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS151MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  15/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera os logs da solicitacao                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS151MAN()
	Local cHtml:= ""
	Local cSol:= HTTPPOST->SOLICITACAO
	Local cTab:= ""
	Local nX:= 0
	Local aTabela:= {}
	Local aLinha:= {}
	Local oAlert:= Nil

	If ValType(HTTPSESSION->cEMP) == "U" .OR. ValType(HTTPSESSION->cFil) == "U" .OR. ValType(HTTPSESSION->cCC) == "U"
		cHtml:= "  $.ajax({"
		cHtml+= "          async: true,"
		cHtml+= "          method: 'POST',"
		cHtml+= "          url: 'u_ps001man.apw',"
		cHtml+= "         }).done(function(data){eval(data);});"
		Return cHtml
	EndIf

	RESET ENVIRONMENT
	PREPARE ENVIRONMENT EMPRESA HTTPSESSION->cEmp FILIAL HTTPSESSION->cFil

	ZP2->(dbSetOrder(1))
	If ZP2->(DbSeek(xFilial("ZP2")+cSol))

		aTabela:= StrTokArr(ZP2->ZP2_LOG, Chr(13)+Chr(10))
		cTab:= "<table class='table' width='100%'>"
		cTab+= "<thead>"
		cTab+= "<tr>"
		cTab+= "<th>Usuario</th>"
		cTab+= "<th>Data</th>"
		cTab+= "<th>Hora</th>"
		cTab+= "<th>Descricao</th>"
		cTab+= "</tr>"
		cTab+= "</thead>"

		cTab+= "<tbody>"
		For nX:= 1 To Len(aTabela)
			aLinha:= StrTokArr(aTabela[nX], "|")
			If Len(aLinha) > 0
				cTab+= "<tr>"
				cTab+= "<td>"+aLinha[1]+"</td>"
				cTab+= "<td>"+aLinha[2]+"</td>"
				cTab+= "<td>"+aLinha[3]+"</td>"
				cTab+= "<td>"+aLinha[4]+"</td>"
				cTab+= "</tr>"
			EndIf
		Next nX

		cTab+= "</tbody>"
		cTab+= "</table>"
		oAlert:= PSWebAlert():New("ps151man_alert", cTab, HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	Else
		oAlert:= PSWebAlert():New("ps151man_alert", "Solicitacao '"+cSol+"' nao encontrada", HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	EndIf
Return cHtml
