#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_exped(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	Local cHTML := ""
	Local i:= 0
	Local cPedido:= ""
	Local cMail:= ""

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	For i := 1 To Len(__aPostParms)  
		If Alltrim(__aPostParms[i, 1]) == 'pedido'
			cPedido:= __aPostParms[i, 2]
		EndIf
		If Alltrim(__aPostParms[i, 1]) == 'email'
			cMail:= __aPostParms[i, 2]
		EndIf
	Next i

	If !Empty(cPedido)
		dbSelectArea("ZZ4")
		dbSetOrder(2)
		dbSeek(xFilial("ZZ4")+cPedido)
		If Found()
			If GetMV("PR_ENVMAIL")
				_cMSG:= u_PedMail(cPedido)//preciso pegar os dados do pedido antes de excluir ele
			EndIf
			RecLock("ZZ4", .F.)
			dbDelete()
			MsUnLock()
			dbSelectArea("ZZ5")
			dbSetorder(1)
			dbSeek(xFilial("ZZ5")+cPedido)
			Do While !ZZ5->(EOF()) .AND. xFilial("ZZ5")+cPedido == ZZ5->ZZ5_FILIAL+ZZ5->ZZ5_NUM
				RecLock("ZZ5", .F.)
				dbDelete()
				MsUnLock()
				ZZ5->(dbSkip())
			EndDo 

			cHTML:="<html>" 
			cHTML+="<head>"
			cHTML+="<meta http-equiv='Cache-Control' content='No-Cache'>
			cHTML+="<meta http-equiv='Pragma' content='No-Cache'>"
			cHTML+="<meta http-equiv='Expires' content='0'>"
			cHTML+="</head>" 
			cHTML+= "<body>"
			cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"
			cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Pedido "+cPedido+" excluído com sucesso!</b></font><br><br><input type='button' value='Fechar' onclick='window.close()'/>" 
			cHTML+= "</body></html>"

			If GetMV("PR_ENVMAIL")
				u_EnvMail("excluido", _cMSG, cPedido, cMail)
			EndIf
		Else
			cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Pedido nao encontrado: "+cPedido+".</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
		EndIf
	Else
		cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Pedido em branco, selecione novamente.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
	EndIf

	RESET ENVIRONMENT

Return cHTML
