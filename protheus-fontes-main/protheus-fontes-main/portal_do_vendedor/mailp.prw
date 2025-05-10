#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function mailp(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)
	Local cMail:= ""  
	Local cPass:= 0
	Local cHTML:= ""
	Local nX:= 0

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1", "ZZ4", "ZZ5"

	For nX:= 1 To Len(__aPostParms)
		If __aPostParms[nX, 1] == "email"
			cMail:= __aPostParms[nX, 2]
		EndIf
	Next
	cHTML+="<html>"
	cHTML+="<head>"
	cHTML+="<meta http-equiv='Cache-Control' content='No-Cache'>
	cHTML+="<meta http-equiv='Pragma' content='No-Cache'>"
	cHTML+="<meta http-equiv='Expires' content='0'>"
	cHTML+="</head>" 
	cHTML+= "<body>"
	cHTML+= "<link rel='stylesheet' type='text/css' href='estilo.css'>"
	cHTML+= "<link rel='shortcut icon' href='imagens/silva.ico'>"


	dbSelectArea("ZZJ")
	dbSetOrder(3)
	if DBSeek(xFilial('ZZJ')+cMail)
		cPass := ZZJ->ZZJ_SENHA 
		u_GJF54('Sua senha atual para acesso ao Portal do Vendedor é: '+ cPass,'WORKFLOW Portal do Vendedor Frigorífico Silva',cMail,'')
		cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Email com a senha atual enviado para " + cMail + "</b></font><br><br><input type='button' value='Voltar' onclick='document:history.back(1)' />"
	Else
		cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Email digitado invalido.</b></font><br><br><input type='button' value='Voltar' onclick='document:history.back(1)' />"
	EndIf  
	cHTML += "</body></html>"                    
	RESET ENVIRONMENT

Return cHTML
