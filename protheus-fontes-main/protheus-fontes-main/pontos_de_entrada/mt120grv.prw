#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT120GRV  บAutor  ณEzequiel Pianegonda บ Data ณ  15/08/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPE na gravacao do pedido de compra.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MT120GRV()
	Local aArea:= GetArea()
	Local cNumPed:= PARAMIXB[1]
	Local lInclui:= PARAMIXB[2]
	Local lAltera:= PARAMIXB[3]
	Local lDeleta:= PARAMIXB[4]
	Local cSol:= ""
	Local cItSol:= ""
	Local cUpdate:= ""
	Local cQuery:= ""
	Local nErro:= 0
	Local nX
	
	//Gravacao do campo ZP4_PC, ZP4_ITEMPC e ZP4_DTPC
	If cEmpAnt == "01"
		If lInclui .OR. lAltera
			For nX:= 1 To Len(aCols)
				cSol:= GdFieldget("C7_NUMSC", nX)
				cItSol:= GdFieldget("C7_ITEMSC", nX)
				cUpdate:= ""
				If !Empty(cSol)
					If GdDeleted(nX)
						cUpdate:= "UPDATE "+RetSqlName("ZP4")+" SET ZP4_PC = '', ZP4_ITEMPC = '', ZP4_DTPC = '' WHERE ZP4_FILIAL = '"+xFilial("ZP4")+"' AND ZP4_SOLC = '"+cSol+"' AND ZP4_ITEMSC = '"+cItSol+"' AND D_E_L_E_T_ = ''"
						nErro:= TCSqlExec(cUpdate)
						If nErro < 0
							//MemoWrite('MT120GRV1.TXT', cUpdate+"||"+TCSQLError())
						EndIf
					Else
						cUpdate:= "UPDATE "+RetSqlName("ZP4")+" SET ZP4_PC = '"+cNumPed+"', ZP4_ITEMPC = '"+GdFieldGet("C7_ITEM", nX)+"', ZP4_DTPC = '"+DtoS(Date())+"' WHERE ZP4_FILIAL = '"+xFilial("ZP4")+"' AND ZP4_SOLC = '"+cSol+"' AND ZP4_ITEMSC = '"+cItSol+"' AND D_E_L_E_T_ = ''"
						nErro:= TCSqlExec(cUpdate)
						If nErro < 0
							//MemoWrite('MT120GRV2.TXT', cUpdate+"||"+TCSQLError())
						EndIf
						cQuery  := "SELECT DISTINCT ZP4_CODIGO FROM "+RetSqlTab("ZP4")+" WHERE ZP4_FILIAL = '"+xFilial("ZP4")+"' AND ZP4_SOLC = '"+cSol+"' AND ZP4_ITEMSC = '"+cItSol+"' AND D_E_L_E_T_ = ''"
						cUpdate := "UPDATE "+RetSqlName("ZP2")+" SET ZP2_DTPC = '"+DtoS(Date())+"' WHERE ZP2_FILIAL = '"+xFilial("ZP2")+"' AND ZP2_CODIGO IN ("+cQuery+") AND D_E_L_E_T_ = ''"
						nErro   := TCSqlExec(cUpdate)//arrumei o erro do ezequiel aqui. ass:Mauricio
						If nErro < 0
							//MemoWrite('MT120GRV3.TXT', cUpdate+"||"+TCSQLError())
						EndIf
					EndIf
				EndIf
			Next nX
		ElseIf lDeleta
			For nX:= 1 To Len(aCols)
				cSol:= GdFieldget("C7_NUMSC", nX)
				cItSol:= GdFieldget("C7_ITEMSC", nX)
				cUpdate:= ""
				If !Empty(cSol)
					cUpdate:= "UPDATE "+RetSqlName("ZP4")+" SET ZP4_PC = '', ZP4_ITEMPC = '', ZP4_DTPC = '' WHERE ZP4_FILIAL = '"+xFilial("ZP4")+"' AND ZP4_SOLC = '"+cSol+"' AND ZP4_ITEMSC = '"+cItSol+"' AND D_E_L_E_T_ = ''"
					nErro:= TCSqlExec(cUpdate)
					If nErro < 0
						//MemoWrite('MT120GRV4.TXT', cUpdate+"||"+TCSQLError())
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf


	RestArea(aArea)
Return .T.
