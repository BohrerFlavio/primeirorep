#INCLUDE "rwmake.ch"                                                                                                 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_acred(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	Local cHTML:= ""
	Local i:= 0
	Local cCli:= ""
	Local cLoja:= ""

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	For i := 1 To Len(__aProcParms)  
		If Alltrim(__aProcParms[i, 1]) == 'cliente'
			cCli:= __aProcParms[i, 2]
		EndIf
		If Alltrim(__aProcParms[i, 1]) == 'loja'
			cLoja:= __aProcParms[i, 2]
		EndIf
	Next i

	If !Empty(cCli) .AND. !Empty(cLoja)
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+cCli+cLoja)
		If Found()
			cHTML:= "<html>"
			cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"
			cHTML+= "<link rel='shortcut icon' href='imagens/silva.ico'>"
			cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
			cHTML+= "<input type='button' value='Fechar' onclick='window.close()' /><br>"
			cHTML+= "<center><b>Analise de credito<b></center><br><br>"
			cHTML+= "<table border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
			cHTML+= "<tr>"
			cHTML+= "<td><input type='text' readonly='readonly' style='border:none;' value='Limite de credito:' /></td>"
			cHTML+= "<td style='text-align:right;'><input type='text' readonly='readonly' style='border:none;text-align:right;' maxlength='30' value='"+Transform(SA1->A1_LC, "@e 999,999,999.99")+"' /></td>"
			cHTML+= "</tr>"
			cHTML+= "<tr>"
			cHTML+= "<td><input type='text' readonly='readonly' style='border:none' value='Data de vencimento:' /></td>"
			cHTML+= "<td style='text-align:right;'><input type='text' readonly='readonly' style='border:none;text-align:right;' maxlength='30' value='"+DtoC(SA1->A1_VENCLC)+"' /></td>"
			cHTML+= "</tr>"
			cHTML+= "<tr>"
			cHTML+= "<td><input type='text' readonly='readonly' style='border:none' value='Ultima compra:' /></td>"
			cHTML+= "<td style='text-align:right;'><input type='text' readonly='readonly' style='border:none;text-align:right;' maxlength='30'  value='"+DtoC(SA1->A1_ULTCOM)+"' /></td>"
			cHTML+= "</tr>"
			cHTML+= "<tr>"
			cHTML+= "<td><input type='text' readonly='readonly' style='border:none' value='Credito vigente:' /></td>"
			cHTML+= "<td style='text-align:right;'><input type='text' readonly='readonly' style='border:none;text-align:right;' maxlength='30' value='"+Transform(u_nLimCred(SA1->A1_COD, SA1->A1_LOJA), "@e 999,999,999.99")+"' /></td>"
			cHTML+= "</tr>"
			cHTML+= "</table>"
			cHTML+= "</html>"
		Else
			cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
			cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Cliente nao encontrado.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
		EndIf
	Else
		cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
		cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Nenhum cliente selecionado.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
	EndIf

	RESET ENVIRONMENT

Return cHTML
