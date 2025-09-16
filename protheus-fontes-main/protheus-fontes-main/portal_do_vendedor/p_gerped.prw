#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_gerped(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)   
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
			cHTML+="<head>"
			cHTML+="<meta http-equiv='Cache-Control' content='No-Cache'>
			cHTML+="<meta http-equiv='Pragma' content='No-Cache'>"
			cHTML+="<meta http-equiv='Expires' content='0'>"
			cHTML+="</head>" 	
			cHTML+="<body onload='buscaPedidos()'>"	
			cHTML+= "<script language='JavaScript'>"

			cHTML+= "var request = false;"
			cHTML+= "var win;"
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
			//cHTML+= "win.document.getElementById('clientes').innerHTML+= '<input type="+'"text"'+" name="+'"usuario"'+" id="+'"usuario"'+" value="+'"'+cUser+'"'+" />';"
			//cHTML+= "alert('"+cUser+"');"

			//cHTML+= "win.setInterval('document.getElementById("+'"usuario"'+").value="+cUser+"', 5000);"

			//cHTML+= "win.onload = function() {win.document.getElementById('usuario').value='"+cUser+"';};"
			//cHTML+= "alert('teste teste on load');"
			//cHTML+= "win.document.getElementById('usuario').value= '"+cUser+"';"
			cHTML+= "}"

			cHTML+= "function buscaPedidos() {"
			cHTML+= "var dini = document.getElementById('dataini').value;"
			cHTML+= "var dfin = document.getElementById('datafin').value;"  
			cHTML+= "var stt  = document.getElementById('status').value;"   		
			cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_brow.apl?rdm='+encodeURI(Math.random())+'&cliente="+cCli+"&loja="+cLoja+"&dataini='+dini+'&datafin='+dfin+'&status='+stt+'&vendedor="+cUser+"';"
			cHTML+= "request.open('GET', url, true);"
			cHTML+= "request.onreadystatechange = atualizaBrowser;"
			cHTML+= "request.send(null);"   
			cHTML+= "}"

			cHTML+= "function atualizaBrowser() {  "  
			cHTML+= "if (request.readyState == 4) {  "
			cHTML+= "if (request.status == 200) {  "
			cHTML+= 'document.getElementById("browser").innerHTML = request.responseText;  '
			cHTML+= "} else "
			cHTML+= 'alert("status is " + request.status);  '
			cHTML+= "} "
			cHTML+= "} "

			cHTML+= "function getPedido(linha) {"
			cHTML+= 'var pedido = "browser_nume_"+linha;' 
			cHTML+= 'var status = "browser_stat_"+linha;'
			cHTML+= 'document.getElementById("pedido_selecionado").value = document.getElementById(pedido).value;'
			cHTML+= 'document.getElementById("status_selecionado").value = document.getElementById(status).value;'   
			cHTML+= "}"

			cHTML+= "function visualizaPedido() {"
			cHTML+= "var pedido = document.getElementById('pedido_selecionado').value;"
			cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_visu.apl?rdm='+encodeURI(Math.random())+'&pedido='+pedido;"
			cHTML+= "request.open('GET', url, true);"
			cHTML+= "request.onreadystatechange = mostraPedido;"
			cHTML+= "request.send(null);"
			cHTML+= "}"

			cHTML+= "function mostraPedido() {  "
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
			cHTML+= "if (request.readyState == 4) {  "
			cHTML+= "if (request.status == 200) {  "
			//cHTML+= "win = window.open('','','height=' + altura + ', width=' + largura + ', top='+meio1+', left='+meio2+',toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no');"
			cHTML+= "win.resizeTo(largura, altura);"
			cHTML+= "win.moveTo(meio2, meio1);"
			cHTML+= "win.document.getElementById('msg_win').innerHTML = '';"
			cHTML+= "win.document.write(request.responseText);"
			cHTML+= "} else {"
			cHTML+= 'win.close();alert("status is " + request.status);}'
			cHTML+= "} "
			cHTML+= "} "

			cHTML+= "function excluiPedido() {"
			cHTML+= "var pedido = document.getElementById('pedido_selecionado').value;" 
			cHTML+= "var status = document.getElementById('status_selecionado').value;"
			cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_exclui.apl?rdm='+encodeURI(Math.random())+'&pedido='+pedido;" 
			cHTML+= "if (pedido == '')"
			cHTML+= "{win.close();alert('Selecione primeiramente um pedido!');
			cHTML+= "return false };"  
			cHTML+= "if (status != 'Em Portal')"
			cHTML+= "{win.close();alert('Status do pedido impede exclusão!');
			cHTML+= "return false };"
			cHTML+= "url+= '&email='+'"+cMail+"';"
			cHTML+= "request.open('GET', url, true);"
			cHTML+= "request.onreadystatechange = apagarPedido;"
			cHTML+= "request.send(null);"
			cHTML+= "}"

			cHTML+= "function apagarPedido() {  "
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
			cHTML+= "if (request.readyState == 4) {  "
			cHTML+= "if (request.status == 200) {  "
			//cHTML+= "win = window.open('','','height=' + altura + ', width=' + largura + ', top='+meio1+', left='+meio2+',toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no');"
			cHTML+= "win.resizeTo(largura, altura);"
			cHTML+= "win.moveTo(meio2, meio1);"
			cHTML+= "win.document.getElementById('msg_win').innerHTML = '';"
			cHTML+= "win.document.write(request.responseText);"
			cHTML+= "} else {"
			cHTML+= 'win.close();alert("status is " + request.status);}'
			cHTML+= "} "
			cHTML+= "} "

			cHTML+= "function incluiPedido() {"
			cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_inclui.apl?';"
			cHTML+= "url+= '&usuario='+'"+cUser+"';"
			cHTML+= "url+= '&cliente='+'"+cCli+"';"
			cHTML+= "url+= '&loja='+'"+cLoja+"';"
			cHTML+= "url+= '&email='+'"+cMail+"';"
			cHTML+= "request.open('GET', url, true);"
			cHTML+= "request.onreadystatechange = incluirPedido;"
			cHTML+= "request.send(null);"
			cHTML+= "}"

			cHTML+= "function incluirPedido() {  "
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
			cHTML+= "if (request.readyState == 4) {  "
			cHTML+= "if (request.status == 200) {  "
			//cHTML+= "win = window.open('','','height=' + altura + ', width=' + largura + ', top='+meio1+', left='+meio2+',toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no');"
			cHTML+= "win.resizeTo(largura, altura);"
			cHTML+= "win.moveTo(meio2, meio1);"
			cHTML+= "win.document.getElementById('msg_win').innerHTML = '';"
			cHTML+= "win.document.write(request.responseText);"
			cHTML+= "} else {"
			cHTML+= 'win.close();alert("status is " + request.status);}'
			cHTML+= "} "
			cHTML+= "} "

			cHTML+= "function alteraPedido() {"
			cHTML+= "var pedido = document.getElementById('pedido_selecionado').value;"  
			cHTML+= "var status = document.getElementById('status_selecionado').value;"
			cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_altped.apl?rdm='+encodeURI(Math.random())+'&pedido='+pedido;" 
			cHTML+= "if (pedido == '')"
			cHTML+= "{win.close();alert('Selecione primeiramente um pedido!');
			cHTML+= "return false };"  
			cHTML+= "if (status != 'Em Portal')"
			cHTML+= "{win.close();alert('Status do pedido impede alteracao!');
			cHTML+= "return false };"
			cHTML+= "url+= '&usuario='+'"+cUser+"';"
			cHTML+= "url+= '&email='+'"+cMail+"';" 
			cHTML+= "url+= '&cliente='+'"+cCli+"';"
			cHTML+= "url+= '&loja='+'"+cLoja+"';"
			cHTML+= "request.open('GET', url, true);"
			cHTML+= "request.onreadystatechange = alterarPedido;"
			cHTML+= "request.send(null);"
			cHTML+= "}"

			cHTML+= "function alterarPedido() {  "
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
			cHTML+= "if (request.readyState == 4) {  "
			cHTML+= "if (request.status == 200) {  "
			//cHTML+= "win = window.open('','','height=' + altura + ', width=' + largura + ', top='+meio1+', left='+meio2+',toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no');"
			cHTML+= "win.resizeTo(largura, altura);"
			cHTML+= "win.moveTo(meio2, meio1);"
			cHTML+= "win.document.getElementById('msg_win').innerHTML = '';"
			cHTML+= "win.document.write(request.responseText);"
			cHTML+= "} else {"
			cHTML+= 'win.close();alert("status is " + request.status);}'
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

			cHTML+= "</script>"	
			cHTML+= "<div id='toolbar'><div id='page'>"
			cHTML+= "<input type='hidden' name='usuario' id='usuario' value='"+cUser+"' />"
			cHTML+= "<input type='hidden' name='senha' id='senha' value='"+cPass+"' />"
			cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"  
			cHTML+= "<link rel='shortcut icon' href='imagens/silva.ico'>"
			cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
			cHTML+= "<input type='button' value='Fechar' onclick='window.close()' /><br>"
			cHTML+= "<center><b>Gerenciar Pedidos de venda</b><br><br>"+u_cLimCred(cCli, cLoja)+"</center><br>"
			//cHTML+= "<input type='button' value='Incluir' onclick='incluiPedido()' />"
			//cHTML+= "<input type='button' value='Alterar' onclick='alteraPedido()' />"
			//cHTML+= "<input type='button' value='Excluir' onclick='excluiPedido()' />"
			//cHTML+= "<input type='button' value='Visualizar' onclick='visualizaPedido()' />"

			//tratamento para evitar bloqueio de pop up
			cHTML+= "<input type='button' value='Incluir'          onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>Buscando informações, aguarde...</div>"'+");incluiPedido()    ;return false;' />"
			cHTML+= "<input type='button' value='Alterar'          onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>Buscando informações, aguarde...</div>"'+");alteraPedido()    ;return false;' />"
			cHTML+= "<input type='button' value='Excluir'          onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>Buscando informações, aguarde...</div>"'+");excluiPedido()    ;return false;' />"
			cHTML+= "<input type='button' value='Visualizar'       onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>Buscando informações, aguarde...</div>"'+");visualizaPedido() ;return false;' />"
			//cHTML+= "<input type='button' value='Visualizar'       onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>"'+EncodeUTF8("Buscando informações, aguarde...")+'"</div>"'+");visualizaPedido() ;return false;' />"

			cHTML+= "<input type='hidden' id='pedido_selecionado' value='' />"
			cHTML+= "<input type='hidden' id='status_selecionado' value='' />" 
			cHTML+= "<br><br>"
			cHTML+= "<font face='arial' size='2'>Emissao de &nbsp;&nbsp;</font><input type='text' name='dataini' id='dataini' maxlength='8' size='8' style='border:1px solid' value='"+DtoC(Date()-30)+"' onKeyPress='formatar(this, "+'"##/##/##"'+");' onBlur='validaData(this)' />"
			cHTML+= "<font face='arial' size='2'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Emissao ate&nbsp;&nbsp;</font><input type='text' name='datafin' id='datafin' maxlength='8' size='8' style='border:1px solid' value='"+DtoC(Date())+"' onKeyPress='formatar(this, "+'"##/##/##"'+");' onBlur='validaData(this)' />"
			cHTML+= "&nbsp;&nbsp;"  
			cHTML+= "<font face='arial' size='2'>Status&nbsp;&nbsp;</font> 
			cHTML+= "<select id='status' name='status'>"
			cHTML+= "<option value='P'>Em Portal</option>"
			cHTML+= "<option value='B'>Bloqueado</option>"
			cHTML+= "<option value='L'>Liberado</option>"
			cHTML+= "<option value='S'>Espera</option>"
			cHTML+= "<option value='C'>Carregando...</option>"
			cHTML+= "<option value='E'>Encerrado</option>"
			cHTML+= "<option value='F'>Faturado</option>"
			cHTML+= "<option  selected value='T'>Todos</option></select>"
			cHTML+= "&nbsp;&nbsp;<input type='button' value='Atualizar' onclick='buscaPedidos();' />"
			cHTML+= "</div>"
			cHTML+= "<div id='browser'>"

			cHTML+= "<table id='tabb' border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
			cHTML+= "<tr height='25px'>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Numero")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Status")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Cliente")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Loja")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Nome")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Emissao")+"</font></td>"
			//		cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Desconto")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Q.Peso")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Q.Caixas")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Valor Total")+"</font></td>"
			cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("Observacoes")+"</font></td>"
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
		cHTML:= "<b><td bgcolor='#000000'><font face='arial' size='3'>Usuario, senha ou email nao digitado.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
	EndIf

	RESET ENVIRONMENT

Return cHTML
