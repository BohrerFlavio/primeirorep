#INCLUDE 'TBICONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS123MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  17/07/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta estoque dos produtos da solicitacao                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS123MAN()
	Local cHtml:= ""
	Local cTabela:= HTTPPOST->TABELA
	Local cEst:= ""
	Local cProdut:= ""
	Local nQtd:= 0
	Local nX:= 0
	Local nY:= 0
	Local aTabela:= {}
	Local aLinha:= {}
	Local aCampos:= {}
	Local oAlert:= Nil

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
	aTabela:= StrTokArr(cTabela, "|")
	cEst:= "<table class='table' width='100%'>"
	cEst+= "<thead>"
	cEst+= "<tr>"
	cEst+= "<th>Produto</th>"
	cEst+= "<th>Descricao</th>"
	cEst+= "<th>Estoque</th>"
	cEst+= "</tr>"
	cEst+= "</thead>"
	cEst+= "<tbody>"	
	For nX:= 1 To Len(aTabela)
		aLinha:= StrTokArr(aTabela[nX], ";")
		cProdut:= ""
		nQtd:= 0
		For nY:= 1 To Len(aLinha)
			aCampos:= StrTokArr(aLinha[nY], ":")
			If Len(aCampos) == 3
				If nY == 2
					cProdut:= aCampos[3]
				ElseIf nY == 4
					If AT(",", aCampos[3]) > 0
						nQtd:= Val(StrTran(StrTran(aCampos[3], ".", ""), ",", "."))
					Else
						nQtd:= Val(StrTran(aCampos[3], ".", ","))
					EndIf
				EndIf
			EndIf
		Next nY
		SB1->(Posicione("SB1", 1, xFilial("SB1")+cProdut, "B1_DESC"))
		SB2->(Posicione("SB2", 1, xFilial("SB1")+SB1->B1_COD+SB1->B1_LOCPAD, "B2_QATU"))
		cEst+= "<tr>"
		cEst+= "<td>"+cProdut+"</td>"
		cEst+= "<td>"+Alltrim(StrTran(U_PS002MAN(SB1->B1_DESC), '"', ""))+"</td>"
		//cEst+= "<td>"+IIF(SaldoSb2() >= nQtd, "OK", Alltrim(Transform(nQtd-SaldoSb2(), "@e 999,999,999.99")))+"</td>"
		cEst+= "<td>"+IIF(SaldoSb2() >= nQtd, Alltrim(Transform(SaldoSb2(), "@e 999,999,999.99")), Alltrim(Transform(0, "@e 999,999,999.99")))+"</td>"
		cEst+= "</tr>"
	Next nX
	cEst+= "</tbody>"
	cEst+= "</table>"
	oAlert:= PSWebAlert():New("ps123man_alert", cEst, HTTPSESSION->cLogo)
	cHtml:= oAlert:show()

Return cHtml
