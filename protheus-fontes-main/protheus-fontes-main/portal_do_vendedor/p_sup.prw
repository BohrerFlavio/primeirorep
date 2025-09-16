#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_sup(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)
	Local cUser:= ""
	Local cPass:= ""
	Local cCli:= ""
	Local cLoja:= ""
	Local cHTML:= ""
	Local cMail:= ""
	Local nX:= 0

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1", "ZZ4", "ZZ5"

	For nX:= 1 To Len(__aProcParms)
		If __aProcParms[nX, 1] == "usuario"
			cUser:= __aProcParms[nX, 2]
		EndIf

		If __aProcParms[nX, 1] == "senha"
			cPass:= __aProcParms[nX, 2]
		EndIf

		If __aProcParms[nX, 1] == "email"
			cMail:= __aProcParms[nX, 2]
		EndIf
	Next

	cHTML:= "<html>"
	cHTML+= "<title>Suporte ao Usuario</title>"
	cHTML+= "<script language='JavaScript'>"
	cHTML+= "var request = false;"
	cHTML+= "try {  "
	cHTML+= "request = new XMLHttpRequest();  "
	cHTML+= "} catch (trymicrosoft) {  "
	cHTML+= "try {  "
	cHTML+= "request = new ActiveXObject('Msxml2.XMLHTTP');  "
	cHTML+= "} catch (othermicrosoft) {  "
	cHTML+= "try {  "
	cHTML+= "request = new ActiveXObject('Microsoft.XMLHTTP');  "
	cHTML+= "} catch (failed) {  "
	cHTML+= "request = false;  "
	cHTML+= "}    "
	cHTML+= "}  "
	cHTML+= "}  "

	cHTML+= "if (!request)  "
	cHTML+= "alert('Error initializing XMLHttpRequest!');"

	cHTML+= "function abre_pagina(pagina) {"
	cHTML+= "largura = screen.width;"
	cHTML+= "altura = screen.height;"
	cHTML+= "w = screen.width;"
	cHTML+= "h = screen.height;"
	cHTML+= "meio_w = w/2;"
	cHTML+= "meio_h = h/2;"
	cHTML+= "altura2 = altura/2;"
	cHTML+= "largura2 = largura/2;"
	cHTML+= "meio1 = meio_h-altura2;"
	cHTML+= "meio2 = meio_w-largura2;"
	cHTML+= "win = window.open(pagina,'','height=' + altura + ', width=' + largura + ', top='+meio1+', left='+meio2+'');"
	cHTML+= "}"

	cHTML+= "</script>""

	cHTML +="<link rel='stylesheet' type='text/css' href='estilo.css'>"
	cHTML+="<body>" 
	cHTML+= "<input type='button' value='Fechar' onclick='window.close()' />"
	cHTML+= "<form name='frm_senha' method='post' action='u_p_senha.apl'>"
	cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"

	cHTML+= "<input type='hidden' name='usuario' id='usuario' value='"+cUser+"' />"
	cHTML+= "<input type='hidden' name='senha' id='senha' value='"+cPass+"' />"
	cHTML+= "<input type='hidden' name='email' id='senha' value='"+cMail+"' />"
	cHTML+= "<center><font size=3><b>Suporte ao Usuario</b></font><br><br>"
	cHTML+= "<center><font size=2><b>Alteracao de Senha</b></font><br>"

	cHTML+= "<table border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='50%'>"
	cHTML+= "<tr>"
	cHTML+= "<td  align='center'><font size=2>Nova Senha</font></td>
	cHTML+= "<td>"
	cHTML+= "<p align='center'>"
	cHTML+= "<input type='password' name='senha1' id='senha1' size='20'></td>"
	cHTML+= "</tr>"
	cHTML+= "<tr>"
	cHTML+= "<td align='center'><font size=2>Confirmacao</font></td>"
	cHTML+= "<td>"
	cHTML+= "<p align='center'>"
	cHTML+= "<input type='password' name='senha2' id='senha2' size='20'</td>"
	cHTML+= "</tr>" 
	cHTML+= "<tr>"
	cHTML+= "<td align='center'></td>"
	cHTML+= "<td align='center' height=20></td>"
	cHTML+= "</tr>"
	cHTML+= "<tr>"
	cHTML+= "<td align='right'><input type='submit' id='confirma'/></td>"
	cHTML+= "<td align='left'><input type='reset' id='cancelar'/></td>"
	cHTML+= "</tr>"
	cHTML+= "</table>"
	cHTML+= "<br></center>"
	cHTML+= "<a href='docs/manual.pdf'>Manual Portal do Vendedor</a> "
	cHTML+="</div>"
	cHTML+="</form>"
	cHTML+= "</body></html>"

	RESET ENVIRONMENT

Return cHTML
