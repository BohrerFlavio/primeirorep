#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_senha(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)
	Local cUser:= ""
	Local cPass:= "" 
	Local cSenha1:= ""
	Local cSenha2:= "" 
	Local cMail := ""
	Local cHTML:= ""
	Local nX:= 0

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1", "ZZ4", "ZZ5"

	For nX:= 1 To Len(__aPostParms)
		If __aPostParms[nX, 1] == "senha1"
			cSenha1:= __aPostParms[nX, 2]
		EndIf

		If __aPostParms[nX, 1] == "senha2"
			cSenha2:= __aPostParms[nX, 2]
		EndIf
		If __aPostParms[nX, 1] == "usuario"
			cUser:= __aPostParms[nX, 2]
		EndIf
		If __aPostParms[nX, 1] == "email"
			cMail:=__aPostParms[nX, 2]
		EndIf 
		If __aPostParms[nX, 1] == "senha"
			cPass:=__aPostParms[nX, 2]
		EndIf
	Next 

	cHTML:="<html>"
	cHTML+="<head>"
	cHTML+="<meta http-equiv='Cache-Control' content='No-Cache'>
	cHTML+="<meta http-equiv='Pragma' content='No-Cache'>"
	cHTML+="<meta http-equiv='Expires' content='0'>"
	cHTML+="</head>"
	cHTML+= "<body>"
	cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"
	cHTML+= "<link rel='shortcut icon' href='imagens/silva.ico'>"

	If cSenha1 = cSenha2 
		if len(cSenha1)>= 6
			dbSelectArea("ZZJ")
			dbSetOrder(3)
			if ZZJ->(DBSeek(xFilial('ZZJ')+cMail))

				reclock('ZZJ',.f.)
				ZZJ->ZZJ_SENHA := cSenha1
				msunlock()               

				cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br>"
				cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'><br>Alteração de senha realizada com sucesso!</b></font><br><input type='button' value='Fechar' onclick='window.close()' />"

			else
				cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br>"
				cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'><br>Não foi possivel alterar senha."+cMail+cPass+"</b></font><br><input type='button' value='Fechar' onclick='window.close()' />"
			endif
		else
			cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'><br>Senha deve ter mínimo de 6 dígitos.</b></font><br><input type='button' value='Fechar' onclick='window.close()' />"
		EndIf                      
	Else
		cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'><br>Confirmação da senha está divergente.</b></font><br><input type='button' value='Fechar' onclick='window.close()' />"
	EndIf

	RESET ENVIRONMENT

Return cHTML
