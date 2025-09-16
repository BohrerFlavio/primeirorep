#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_hvend(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)
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

		If __aProcParms[nX, 1] == "cliente"
			cCli:= __aProcParms[nX, 2]
		EndIf

		If __aProcParms[nX, 1] == "loja"
			cLoja:= __aProcParms[nX, 2]
		EndIf

		If __aProcParms[nX, 1] == "email"
			cMail:= __aProcParms[nX, 2]
		EndIf
	Next

	If !Empty(cUser) .AND. !Empty(cPass) .AND. !Empty(cMail)
		If !Empty(cCli) .AND. !Empty(cLoja)
			cHTML:= "<html>"	
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

			cHTML+= "function buscaHistorico() {"
			cHTML+= "var dini = document.getElementById('dataini').value;"
			cHTML+= "var dfin = document.getElementById('datafin').value;"        
			cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_browH.apl?cliente="+cCli+"&loja="+cLoja+"&dataini='+dini+'&datafin='+dfin+'&vendedor="+cUser+"';"
			cHTML+= "request.open('GET', url, true);"
			cHTML+= "request.onreadystatechange = atualizaBrowser;"
			cHTML+= "request.send(null);"
			cHTML+= "}"

			cHTML+= "function atualizaBrowser() {  "
			cHTML+= "if (request.readyState == 4) {  "
			cHTML+= "if (request.status == 200) {  "
			cHTML+= 'document.getElementById("browser").innerHTML = request.responseText;  '
			cHTML+= "} else  "
			cHTML+= 'alert("status is " + request.status);  '
			cHTML+= "} "
			cHTML+= "} "

			cHTML+= "function formatar(src, mask){"
			cHTML+= "var i = src.value.length;"
			cHTML+= "var saida = mask.substring(0,1);"
			cHTML+= "var texto = mask.substring(i);"
			cHTML+= "if (texto.substring(0,1) != saida) {"
			cHTML+= "  src.value += texto.substring(0,1);"
			cHTML+= "}"
			cHTML+= "}"

			cHTML+= "function validaData(data) {"
			cHTML+= "var dia = parseInt(data.value.substr(0, 2), 10);"
			cHTML+= "var mes = parseInt(data.value.substr(3, 2), 10)-1;"
			cHTML+= "var ano = parseInt('20'+data.value.substr(6, 2), 10);"
			cHTML+= "var novaData = new Date(ano, mes, dia);"
			cHTML+= "if ((novaData.getDate() != dia) || (novaData.getMonth() != mes) || (novaData.getFullYear() != ano))"
			cHTML+= "{"
			cHTML+= "    alert('Data Inválida!');"
			cHTML+= "}"
			cHTML+= "}"

			cHTML+= "</script>""

			cHTML +="<link rel='stylesheet' type='text/css' href='estilo2.css'>"   
			cHTML+= "<link rel='shortcut icon' href='imagens/silva.ico'>"
			cHTML+="<body onload='buscaHistorico()'>"	
			cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>" 
			cHTML+= "<input type='button' value='Fechar' onclick='window.close()' />"

			cHTML+= "<div id='toolbar'><div id='page'>"
			cHTML+= "<input type='hidden' name='usuario' id='usuario' value='"+cUser+"' />"
			cHTML+= "<input type='hidden' name='senha' id='senha' value='"+cPass+"' />"
			cHTML+= "<center><b>Historico de Vendas</b><center><br>"
			cHTML+= "<input type='hidden' id='pedido_selecionado' value='' />"
			cHTML+= "<br>"
			cHTML+= "<font face='arial' size='2'>Da data &nbsp;</font><input type='text' name='dataini' id='dataini' maxlength='8' size='8' style='border:1px solid' value='"+DtoC(Date())+"' onKeyPress='formatar(this, "+'"##/##/##"'+");' onBlur='validaData(this)' />"
			cHTML+= "<font face='arial' size='2'>&nbsp;&nbsp;Ate data &nbsp;</font><input type='text' name='datafin' id='datafin' maxlength='8' size='8' style='border:1px solid' value='"+DtoC(Date())+"' onKeyPress='formatar(this, "+'"##/##/##"'+");' onBlur='validaData(this)' />"
			cHTML+= "&nbsp;&nbsp;<input type='button' value='Pesquisar' onclick='buscaHistorico()' />"
			cHTML+= "</div>"  
			cHTML+= "<br>"
			cHTML+= "<div id='browser'>"

			cHTML+= "<table id='tabb' border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
			cHTML+= "<tr height='25px'>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Codigo")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Descrição")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Caixas")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Peso")+"</font></td>"
			cHTML+= "</tr>"
			cHTML+= "</table>"

			cHtml+= "</div></div>"
			cHTML+= "</body></html>"
		Else
			cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Nenhum cliente selecionado.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
		EndIf
	Else
		cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Usuario, senha ou email em branco.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
	EndIf

	RESET ENVIRONMENT

Return cHTML
