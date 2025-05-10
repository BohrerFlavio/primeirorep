#INCLUDE 'Protheus.ch'
#INCLUDE 'TBICONN.CH'
#INCLUDE "ap5mail.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS100MNT  ºAutor  ³Primme              º Data ³  08/08/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envio de email do portal de manutencao                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Silva                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS100MNT(cSolic,cSubject,cBody,cMailAux)
	Local cServer:= AllTrim(GetNewPar("MV_RELSERV"," "))
	Local cAccount:= AllTrim(GetNewPar("MV_RELACNT"," "))
	Local cPassword:= AllTrim(GetNewPar("MV_RELPSW" ," "))
	Local nTimeOut:= GetMv("MV_RELTIME",,120)
	Local lAutentica:= GetMv("MV_RELAUTH",,.F.)
	Local cFrom:= cAccount
	Local lOk:= .F.
	Local cErro:= ""
	Local nCount:= 0
	Local cCC:= ""
	Local cTo:= ""
	Local aRet:= {}
	Local cCusto:= ""
	Local cMaq:= ""
	Local cPri:= ""
	Local cItem:= ""

	ZP2->(DbSetOrder(1))
	If ZP2->(DbSeek(xFilial("ZP2")+cSolic))

		//prioridade
		If ZP2->ZP2_PRIOR == "A"
			cPri:= "Alta"
		ElseIf ZP2->ZP2_PRIOR == "M"
			cPri:= "Media"
		ElseIf ZP2->ZP2_PRIOR == "B"
			cPri:= "Baixa"
		ElseIf ZP2->ZP2_PRIOR == "N"
			cPri:= "Normal"
		EndIf

		//email para os responsaveis por setor
		If ZP2->ZP2_TIPO == "M"			//Manutencao
			cCC:= "mecanica@frigorificosilva.com.br;"
		ElseIf ZP2->ZP2_TIPO == "E"		//Eletrica
			cCC:= "eletrica@frigorificosilva.com.br;"
		ElseIf ZP2->ZP2_TIPO == "I"		//Informatica
			cCC:= "informatica@frigorificosilva.com.br;"
		ElseIf ZP2->ZP2_TIPO == "L"		//Limpeza
			cCC:= "limpeza@frigorificosilva.com.br;"
		ElseIf ZP2->ZP2_TIPO == "P"		//Manutencao externa patio
			cCC:= "cristiane.pacheco@frigorificosilva.com.br;"
		ElseIf ZP2->ZP2_TIPO == "4"		//Porcionados
			cCC:= "porcionados@frigorificosilva.com.br;"
		EndIf

		////email para a qualidade, sempre que o campo qualidade for SIM
		//If ZP2->ZP2_QUALID == "S"
		//	cCC+= "qualidade@frigorificosilva.com.br;"
		//EndIf

		//email auxiliar usado para envio ao almoxarifado no recebimento do material
		If !Empty(cMailAux)
			cItem:= ""
			cCC+= Alltrim(cMailAux)
			ZP4->(dbSetOrder(1))
			ZP4->(dbSeek(xFilial("ZP4")+ZP2->ZP2_CODIGO))
			Do While !ZP4->(EOF()) .AND. xFilial("ZP4")+ZP2->ZP2_CODIGO == ZP4->ZP4_FILIAL+ZP4->ZP4_CODIGO
				If Left(ZP4->ZP4_STATUS, 1) == "3"
					cItem+= "Produto: "+ZP4->ZP4_PRODUT+"<br>"
					cItem+= "Descricao: "+ZP4->ZP4_DESC+"<br>"
					cItem+= "Quantidade: "+Transform(ZP4->ZP4_QUANT, "@e 999,999,999.99")+"<br>"
					cItem+= "Unidade: "+ZP4->ZP4_UM+"<br>"
					cItem+= "<br>"
				EndIf
				ZP4->(dbSkip())
			EndDo
		EndIf

		cCusto:= Alltrim(ZP2->ZP2_CC)+"-"+Alltrim(fBuscaCpo("CTT", 1, xFilial("CTT")+ZP2->ZP2_CC, "CTT_DESC01"))
		ZP3->(DbSetOrder(1))
		If ZP3->(Dbseek(xFilial("ZP3")+ZP2->ZP2_MAQ))
			cCC+= alltrim(ZP3->ZP3_EMAIL)
			cMaq:= Alltrim(ZP2->ZP2_MAQ)+"-"+Alltrim(ZP3->ZP3_NOME)
		Endif
		If !Empty(ZP2->ZP2_USER)
			PswOrder(2)
			If PswSeek(ZP2->ZP2_USER)
				aRet := PswRet()
				cTo := alltrim(aret[1,14])
			Endif
		Endif
		If !Empty(ZP2->ZP2_USRCOM) .and. ZP2->ZP2_USRCOM <> ZP2->ZP2_USER
			PswOrder(2)
			If PswSeek(ZP2->ZP2_USRCOM)
				aRet := PswRet()
				cTo += iif(empty(cTo),'',';')+alltrim(aret[1,14])
			Endif
		Endif
		cBody:= "Maquina:"+cMaq+"<br>"+"Centro de custo:"+cCusto+"<br>"+"Prioridade:"+cPri+"<br>"+"Maquina parada:"+IIF(ZP2->ZP2_MAQPAR == "S", "SIM", IIF(ZP2->ZP2_MAQPAR == "N", "Nao", ""))+"<br>"+"Descrição:"+cBody+"<br>"+cItem
	Else
		Return	'Solicitacao nao encontrada.'
	Endif


	If Empty(cCC+cTo)
		Return 'Nenhum e-mail valido.'
	Endif


	Do While !lOk .AND. nCount < 5
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword TIMEOUT nTimeOut Result lOk
		nCount++
	EndDo
	If lOk
		If lAutentica                     
			lOk:= MailAuth(cAccount, cPassword)
		EndIf

		If lOk
			SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody Result lOk
			//SEND MAIL FROM cFrom TO "ezequiel.pianegonda@primmeservices.com.br" CC "ezequiel.pianegonda@primmeservices.com.br" SUBJECT cSubject BODY cBody Result lOk
			If !lOk
				GET MAIL ERROR cErro
				MsgAlert(cErro)
			EndIf
		Endif
	Else
		GET MAIL ERROR cErro
		MsgAlert(cErro)
	EndIf
	DISCONNECT SMTP SERVER RESULT lOk
Return cErro

/*

User Function PS100MNT(cSolic,cSubject,cBody)
Local nErro := 0
Local oMailManager := NIL
Local cServ := ''
Local sErro := ''
Local oMessage := NIL
Local nPort := 0
Local cFrom := GetMv("MV_RELFROM")
Local cTo := ''
Local cCC := ''
Local cBCC := ''
Local cAttach := ''
Local aAreaZP1 := ZP1->(GetArea())
Local aAreaZP2 := ZP2->(GetArea())
Local aAreaZP3 := ZP3->(GetArea())

Default cSubject := ''
Default cBody := ''

If Empty(cSolic) .or. empty(cSubject) .or. empty(cBody)
Return 'Parametros invalidos.'
Endif

ZP2->(DbSetOrder(1))
If ZP2->(DbSeek(xFilial("ZP2")+cSolic))
ZP3->(DbSetOrder(1))
If ZP3->(Dbseek(xFilial("ZP3")+ZP2->ZP2_MAQ))
cCC := alltrim(ZP3->ZP3_EMAIL)
Endif
If !Empty(ZP2->ZP2_USER)
PswOrder(2)
If PswSeek(ZP2->ZP2_USER)
aRet := PswRet()
cTo := alltrim(aret[1,14])
Endif
Endif
If !Empty(ZP2->ZP2_USRCOM) .and. ZP2->ZP2_USRCOM <> ZP2->ZP2_USER
PswOrder(2)
If PswSeek(ZP2->ZP2_USRCOM)
aRet := PswRet()
cTo += iif(empty(cTo),'',';')+alltrim(aret[1,14])
Endif
Endif
Else
Return	'Solicitacao nao encontrada.'
Endif

If Empty(cCC+cTo)
Return 'Nenhum e-mail valido.'
Endif

nErro := 0
oMailManager := TMailManager():New()
oMailManager:SetUseSSL (GetMv("MV_RELSSL"))
oMailManager:SetUseTLS (GetMv("MV_RELTLS"))
cServ := getmv("MV_RELSERV")
if ! ':' $ cServ
nPort := 587
Else
cServ := Left(getmv("MV_RELSERV"),at(':',getmv("MV_RELSERV"))-1)
nPort := Val(SubStr(getmv("MV_RELSERV"),at(':',getmv("MV_RELSERV"))+1))
Endif
If (nErro := oMailManager:Init( "", cServ , GetMv("MV_RELACNT"), GetMv("MV_RELPSW"),0,nPort )) != 0
sErro := oMailManager:GetErrorString( nErro )
Else
oMailManager:SetSmtpTimeOut( 30 )
If (nErro := oMailManager:SmtpConnect()) != 0
sErro := oMailManager:GetErrorString( nErro )
Else
if GetMv("MV_RELAUTH")
if (nErro := oMailManager:SmtpAuth(GetMv("MV_RELACNT") ,GetMv("MV_RELPSW"))) != 0
sErro := oMailManager:GetErrorString( nErro )
Endif
Endif
If Empty(sErro)
oMessage := tMailMessage():new()
oMessage:Clear()
//oMessage:cFrom	:= cFrom
oMessage:cFrom	:= GetMv("MV_RELACNT")
oMessage:cTo 	:= cTo
If !Empty(cCc)
oMessage:cCc 	:= cCC
Endif
If !Empty(cBcc)
oMessage:cBcc 	:= cBcc
Endif
oMessage:cSubject := cSubject
oMessage:cBody := cBody
If !Empty(cAttach)    
If (nErro  := oMessage:AttachFile(cAttach) ) != 0
serro := 'Erro ao anexar o arquivo'
Endif
Endif
If empty(sErro)
If (nErro := oMessage:Send( oMailManager )) != 0
sErro := oMailManager:GetErrorString( nErro )
Endif
Endif
Endif
If (nErro := oMailManager:SmtpDisconnect()) != 0
If Empty(sErro) // deixo o erro anterior (caso tenha ocorrido), caso contrario eu pego o erro do desconectar
sErro := oMailManager:GetErrorString( nErro )
Endif
Endif
Endif
EndIf

RestArea(aAreaZP1)
RestArea(aAreaZP2)
RestArea(aAreaZP3)
Return sErro
*/
