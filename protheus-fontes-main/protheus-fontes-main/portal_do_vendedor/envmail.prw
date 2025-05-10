#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "totvsmail.ch"

User Function EnvMail(cAcao, cMsg, cPed, cMail)
	Local cSMTP    := AllTrim(GetMV('MV_RELSERV')) //'webmail.frigorificosilva.com.br:587'     //SMTP servidor de email     
	Local cRemet   := AllTrim(GetMV('MV_RELACNT')) //workflow@frigorificosilva.com.br' //Email remetente
	Local cUser    := AllTrim(GetMV('MV_RELACNT')) //'workflow@frigorificosilva.com.br' //Conta de usuário para logon
	Local cPass    := AllTrim(GetMV('MV_RELPSW'))  // Wfw%1972!@ /'wfw%' 05/09/18 //Senha para logon
	Local cMens    := ""
	Local cTit     := ""
	Local nTimeOut:= GetMv("MV_RELTIME",,120)
	Local lAutentica:= GetMv("MV_RELAUTH",,.F.)
	Local lEnviado := .F.

	cTit:= "Pedido "+cPed+" "+cAcao
	cMens:= "Pedido "+cPed+" "+cAcao+" dia "+DtoC(Date())+", as "+Left(Time(), 5)+cMsg

	dbSelectArea("ZZ4")
	dbSetOrder(2)
	dbSeek(xFilial("ZZ4")+cPed)
	If Found()

	EndIf


	CONNECT SMTP SERVER cSMTP ACCOUNT cUser PASSWORD cPass TIMEOUT nTimeOut Result lConectou


	//Função que efetiva o envio do email 
	If lAutentica                     
		lOk := MailAuth(cRemet,cPass)
	EndIf

	If lOk
		Send Mail From cRemet To cMail Subject cTit Body cMens Result lEnviado
	endif

	DISCONNECT SMTP SERVER Result lDesconectou

Return

User Function PedMail(cPedido)
	Local cHTML:= ""

	dbSelectArea("ZZ4")
	dbSetOrder(2)
	dbSeek(xFilial("ZZ4")+cPedido)

	cHTML+= '<br><br>'
	cHTML+= "<table border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
	cHTML+= '<tr>'
	cHTML+= '<td width="20%"><font face="arial" size="2">Cliente</font></td><td><font face="arial" size="2">'+ZZ4->ZZ4_CODCLI+'</font></td>'
	cHTML+= '</tr>'
	cHTML+= '<tr>'
	cHTML+= '<td width="20%"><font face="arial" size="2">Loja</font></td><td><font face="arial" size="2">'+ZZ4->ZZ4_LOJA+'</font></td>'
	cHTML+= '</tr>'
	cHTML+= '<tr>'
	cHTML+= '<td width="20%"><font face="arial" size="2">Nome Cliente</font></td><td><font face="arial" size="2">'+ZZ4->ZZ4_NOME+'</font></td>'
	cHTML+= '</tr>'
	cHTML+= '<tr>'
	cHTML+= '<td width="20%"><font face="arial" size="2">Cidade</font></td><td><font face="arial" size="2">'+ZZ4->ZZ4_MUN+'</font></td>'
	cHTML+= '</tr>'
	cHTML+= '<tr>'
	cHTML+= '<td width="20%"><font face="arial" size="2">Data</font></td><td><font face="arial" size="2">'+DtoC(ZZ4->ZZ4_DATAC)+'</font></td>'
	cHTML+= '</tr>'
	cHTML+= '<tr>'
	cHTML+= '<td width="20%"><font face="arial" size="2">Qt.Prev.Peso</font></td><td><font face="arial" size="2">'+Transform(ZZ4->ZZ4_QPPESO, '@e 999,999,999.99')+'</font></td>'
	cHTML+= '</tr>'
	cHTML+= '<tr>'
	cHTML+= '<td width="20%"><font face="arial" size="2">Qt.Prev.Caixa</font></td><td><font face="arial" size="2">'+Transform(ZZ4->ZZ4_QPCAIX, '@e 999,999,999')+'</font></td>'
	cHTML+= '</tr>'
	cHTML+= '<tr>'
	cHTML+= '<td width="20%"><font face="arial" size="2">Total</font></td><td><font face="arial" size="2">'+Transform(ZZ4->ZZ4_TOTAL, '@e 999,999,999.99')+'</font></td>'
	cHTML+= '</tr>'
	cHTML+= '<tr>'
	cHTML+= '<td width="20%"><font face="arial" size="2">Carregamento</font></td><td><font face="arial" size="2">'+DtoC(ZZ4->ZZ4_DATA)+'</font></td>'
	cHTML+= '</tr>'
	cHTML+= '<tr>'
	cHTML+= '<td width="20%"><font face="arial" size="2">Observacao</font></td><td><font face="arial" size="2">'+ZZ4->ZZ4_OBS+'</font></td>'
	cHTML+= '</tr>'
	cHTML+= '</table>'
	cHTML+= '<table width="100%" border="1px" id="itens" style="border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid">'
	cHTML+= '<tr height="25px">'
	cHTML+= '<td bgcolor="#D3D3D3"><font face="arial" size="2">Item</font></td>'
	cHTML+= '<td bgcolor="#D3D3D3"><font face="arial" size="2">Produto</font></td>'
	cHTML+= '<td bgcolor="#D3D3D3"><font face="arial" size="2">Descricao</font></td>'
	cHTML+= '<td bgcolor="#D3D3D3"><font face="arial" size="2">Qt.Prev.Caixa</font></td>'
	cHTML+= '<td bgcolor="#D3D3D3"><font face="arial" size="2">Qt.Prev.Peso</font></td>'
	cHTML+= '<td bgcolor="#D3D3D3"><font face="arial" size="2">Priorizar</font></td>'
	cHTML+= '<td bgcolor="#D3D3D3"><font face="arial" size="2">Tolerancia</font></td>'
	cHTML+= '<td bgcolor="#D3D3D3"><font face="arial" size="2">Preco</font></td>'
	cHTML+= '<td bgcolor="#D3D3D3"><font face="arial" size="2">Tp.Bonificacao</font></td>'
	cHTML+= '<td bgcolor="#D3D3D3"><font face="arial" size="2">Bonificacao</font></td>'
	cHTML+= '<td bgcolor="#D3D3D3"><font face="arial" size="2">Observacao</font></td>'
	cHTML+= '</tr>'
	dbSelectArea("ZZ5")
	dbSetorder(1)
	dbSeek(xFilial("ZZ5")+cPedido)
	Do While !ZZ5->(EOF()) .AND. xFilial("ZZ5")+cPedido == ZZ5->ZZ5_FILIAL+ZZ5->ZZ5_NUM
		cHTML+= '<tr>'
		cHTML+= '<td><font face="arial" size="2">'+EncodeUTF8(ZZ5->ZZ5_ITEM)+'</font></td>'
		cHTML+= '<td><font face="arial" size="2">'+EncodeUTF8(ZZ5->ZZ5_COD)+'</font></td>'
		cHTML+= '<td><font face="arial" size="2">'+EncodeUTF8(ZZ5->ZZ5_DESC)+'</font></td>'
		cHTML+= '<td><font face="arial" size="2">'+EncodeUTF8(Transform(ZZ5->ZZ5_QPCAIX, "@e 999,999"))+'</font></td>'
		cHTML+= '<td><font face="arial" size="2">'+EncodeUTF8(Transform(ZZ5->ZZ5_QPPESO, "@e 99,999.99"))+'</font></td>'
		_cAux:= IIF(ZZ5->ZZ5_PRIORI=='P', 'Peso', IIF(ZZ5->ZZ5_PRIORI=='A', 'Automatico', 'Caixa'))
		cHTML+= '<td><font face="arial" size="2">'+EncodeUTF8(_cAux)+'</font></td>'
		cHTML+= '<td><font face="arial" size="2">'+EncodeUTF8(Transform(ZZ5->ZZ5_TOLERA, "@e 99"))+'</font></td>'
		cHTML+= '<td><font face="arial" size="2">'+EncodeUTF8(Transform(ZZ5->ZZ5_PRECO, "@e 999.99"))+'</font></td>'
		_cAux:= IIF(ZZ5->ZZ5_TPBONI=='D', 'Desconto', 'Acrescimo')
		cHTML+= '<td><font face="arial" size="2">'+EncodeUTF8(_cAux)+'</font></td>'
		cHTML+= '<td><font face="arial" size="2">'+EncodeUTF8(Transform(ZZ5->ZZ5_BONIF, "@e 99.99"))+'</font></td>'
		cHTML+= '<td><font face="arial" size="2">'+EncodeUTF8(ZZ5->ZZ5_OBS)+'</font></td>'
		cHTML+= '</tr>'
		ZZ5->(dbSkip())
	EndDo
	cHTML+= '</table>'
Return cHTML
