#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT097APR  ºAutor  ³Ezequiel Pianegonda º Data ³  15/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PE na liberacao dos itens do pedido de compra               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT097APR()
	Local aArea:= GetArea()
	Local cUpdate:= ""
	Local cSol:= SC7->C7_NUMSC
	Local cItSol:= SC7->C7_ITEMSC
	Local cQuery:= ""
	Local nErro:= 0

	//gravo a data de liberacao do item do pedido na solicitacao do portal
	If cEmpAnt == "01"
		If !Empty(cSol) .AND. !Empty(cItSol)
			cUpdate:= "UPDATE "+RetSqlName("ZP4")+" SET ZP4_DTLPC = '"+DtoS(Date())+"' WHERE ZP4_FILIAL = '"+xFilial("ZP4")+"' AND ZP4_SOLC = '"+cSol+"' AND ZP4_ITEMSC = '"+cItSol+"' AND D_E_L_E_T_ = ''"
			nErro:= TCSqlExec(cUpdate)
			If nErro < 0
				//MemoWrite('MT097APR1.TXT', cUpdate+"||"+TCSQLError())
			EndIf
			cQuery:= "SELECT DISTINCT ZP4_CODIGO FROM "+RetSqlTab("ZP4")+" WHERE ZP4_FILIAL = '"+xFilial("ZP4")+"' AND ZP4_SOLC = '"+cSol+"' AND ZP4_ITEMSC = '"+cItSol+"' AND D_E_L_E_T_ = ''"
			cUpdate:= "UPDATE "+RetSqlName("ZP2")+" SET ZP2_DTLPC = '"+DtoS(Date())+"' WHERE ZP2_FILIAL = '"+xFilial("ZP2")+"' AND ZP2_CODIGO IN ("+cQuery+") AND D_E_L_E_T_ = ''"
			nErro:= TCSqlExec(cUpdate)
			If nErro < 0
				//MemoWrite('MT097APR2.TXT', cUpdate+"||"+TCSQLError())
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
Return
