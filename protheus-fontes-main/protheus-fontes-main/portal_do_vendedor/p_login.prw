#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_login(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)
	Local cUser:= ""
	Local cPass:= "" 
	Local cStat:= ""
	Local cMail:= "" 
	Local cNRep:= ""
	Local cCRep:= "" 
	Local cAces:= 0
	Local cHTML:= ""
	Local nX:= 0

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1", "ZZ4", "ZZ5"

	For nX:= 1 To Len(__aPostParms)
		If __aPostParms[nX, 1] == "usuario"
			cUser:= __aPostParms[nX, 2]
			cMail:= cUser
		EndIf

		If __aPostParms[nX, 1] == "senha"
			cPass:= __aPostParms[nX, 2]
		EndIf
	Next

	//se nao achar via post tEsto vIa get pois na rotina voltar chamo novamente esta tela via get
	/*If Empty(cUser) .AND. Empty(cPass)
	For nX:= 1 To Len(__aProcParms)
	If __aProcParms[nX, 1] == "usuario"
	cUser:= __aProcParms[nX, 2]
	EndIf

	If __aProcParms[nX, 1] == "senha"
	cPass:= __aProcParms[nX, 2]
	EndIf
	Next
	//ao inves do codigo preciso pegar o email para dar continuidade na rotina
	dbSelectArea("ZZJ")
	dbSetOrder(2)
	DBSeek(xFilial('ZZJ')+cUser)
	If Found()
	cUser:= ZZJ->ZZJ_EMAIL
	EndIf
	EndIf*/

	If !Empty(cUser) .AND. !Empty(cPass)

		dbSelectArea("ZZJ")
		dbSetOrder(3)
		DBSeek(xFilial('ZZJ')+cUser)
		If Found()
			If Alltrim(ZZJ->ZZJ_SENHA) == cPass
				dbSelectArea("SA3")
				dbSetOrder(1)
				dbSeek(xFilial("SA3")+ZZJ->ZZJ_CODREP)
				cStat := ZZJ->ZZJ_STATUS

				If Found() .and. cStat = 'L'

					cCRep := alltrim(SA3->A3_COD)
					cNRep := alltrim(SA3->A3_NOME)

					reclock('ZZJ',.f.)
					ZZJ->ZZJ_NACESS++
					msunlock() 

					cUser:= ZZJ->ZZJ_CODREP
					nAces:= ZZJ->ZZJ_NACESS  

					cHTML:="<html>" 
					cHTML+="<head>"
					cHTML+="<meta http-equiv='Cache-Control' content='No-Cache'>
					cHTML+="<meta http-equiv='Pragma' content='No-Cache'>"
					cHTML+="<meta http-equiv='Expires' content='0'>" 
					cHTML+="<title></title>" 
					cHTML+="</head>" 
					cHTML+= "<body onload='buscaClientes()'>"
					cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>" 
					cHTML+= "<link rel='shortcut icon' href='imagens/silva.ico'>"
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

					cHTML+= "function gerenciarPedidos() {"
					cHTML+= "var cliente = document.getElementById('cliente').value;"
					cHTML+= "var loja = document.getElementById('loja').value;"
					cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_gerped.apl?rdm='+encodeURI(Math.random())+'&cliente='+cliente+'&loja='+loja+'&senha="+cPass+"&usuario="+cUser+"&email="+cMail+"';"
					//	cHTML+= "var url = 'http://portaldovendedor.frigorficosilva.com.br:91/u_p_gerped.apl?rdm='+encodeURI(Math.random())+'&cliente='+cliente+'&loja='+loja+'&senha="+cPass+"&usuario="+cUser+"&email="+cMail+"';"
					cHTML+= "if (cliente == '')"
					cHTML+= "{"
					cHTML+= "  win.close();"
					cHTML+= "  alert('Selecione cliente para continuar...');"
					cHTML+= "  return false;"
					cHTML+= "}"
					cHTML+= "request.open('GET', url, true);"
					cHTML+= "request.onreadystatechange = pedidos;"
					cHTML+= "request.send(null);"
					cHTML+= "}"

					cHTML+= "function listarPedidos() {"
					cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_gerp2.apl?rdm='+encodeURI(Math.random())+'&senha="+cPass+"&usuario="+cUser+"&email="+cMail+"';"
					cHTML+= "request.open('GET', url, true);"
					cHTML+= "request.onreadystatechange = pedidos;"
					cHTML+= "request.send(null);"
					cHTML+= "}"

					cHTML+= "function pedidos() {  "
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

					cHTML+= "function buscaClientes() {"
					cHTML+= "var ordem  = document.getElementById('ordem').value;"
					cHTML+= "var codcli = document.getElementById('codcliente').value;"
					cHTML+= "var nomcli = document.getElementById('nomcliente').value;"
					cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_browcli.apl?rdm='+encodeURI(Math.random())+'&ordem='+ordem+'&codcli='+codcli+'&nomcli='+nomcli+'&vendedor="+cUser+"';"
					cHTML+= "request.open('GET', url, true);"
					cHTML+= "request.onreadystatechange = atualizaBrowser;"
					cHTML+= "request.send(null);"
					cHTML+= "}"

					cHTML+= "function atualizaBrowser() {  "
					cHTML+= "if (request.readyState == 4) {  "
					cHTML+= "if (request.status == 200) {  "
					cHTML+= 'document.getElementById("browser").innerHTML = request.responseText;  '
					cHTML+= "} else {"
					cHTML+= 'alert("status is " + request.status);}'
					cHTML+= "} "
					cHTML+= "} "

					cHTML+= "function getCliente(linha) {"
					cHTML+= 'var cliente = "cliente_codi_"+linha;'
					cHTML+= 'var loja = "cliente_loja_"+linha;'
					cHTML+= 'document.getElementById("cliente").value = document.getElementById(cliente).value;'
					cHTML+= 'document.getElementById("loja").value = document.getElementById(loja).value;'
					cHTML+= "}"

					cHTML+= "function getAnaliseCredito() {"
					cHTML+= 'var cliente = document.getElementById("cliente").value;'
					cHTML+= 'var loja = document.getElementById("loja").value;'
					cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_acred.apl?rdm='+encodeURI(Math.random())+'&cliente='+cliente+'&loja='+loja;" 
					cHTML+= "if (cliente == '')"
					cHTML+= "{"
					cHTML+= "  win.close();"
					cHTML+= "  alert('Selecione cliente apra continuar...');"
					cHTML+= "  return false;"
					cHTML+= "}"
					cHTML+= "request.open('GET', url, true);"
					cHTML+= "request.onreadystatechange = analiseCredito;"
					cHTML+= "request.send(null);"
					cHTML+= "}"

					cHTML+= "function analiseCredito() {  "
					cHTML+= "largura = screen.width/2;"
					cHTML+= "altura = screen.height/2;"
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
					//cHTML+= "win = window.open('','','height=' + altura + ', width=' + largura + ', top='+meio1+', left='+meio2+'');"
					cHTML+= "win.resizeTo(largura, altura);"
					cHTML+= "win.moveTo(meio2, meio1);"
					cHTML+= "win.document.getElementById('msg_win').innerHTML = '';"
					cHTML+= "win.document.write(request.responseText);"
					cHTML+= "} else {"
					cHTML+= 'win.close();alert("status is " + request.status);}'
					cHTML+= "} "
					cHTML+= "} "

					cHTML+= "function getDadosCadastrais() {"
					cHTML+= 'var cliente = document.getElementById("cliente").value;'
					cHTML+= 'var loja = document.getElementById("loja").value;'
					cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_dcad.apl?rdm='+encodeURI(Math.random())+'&cliente='+cliente+'&loja='+loja;;"  
					cHTML+= "if (cliente == '')"
					cHTML+= "{"
					cHTML+= "  win.close();"
					cHTML+= "  alert('Selecione cliente apra continuar...');"
					cHTML+= "  return false;"
					cHTML+= "}"
					cHTML+= "request.open('GET', url, true);"
					cHTML+= "request.onreadystatechange = dadosCadastrais;"
					cHTML+= "request.send(null);"
					cHTML+= "}"

					cHTML+= "function dadosCadastrais() {  "
					cHTML+= "largura = screen.width/2;"
					cHTML+= "altura = screen.height/2;"
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
					//cHTML+= "win = window.open('','','height=' + altura + ', width=' + largura + ', top='+meio1+', left='+meio2+'');"
					cHTML+= "win.resizeTo(largura, altura);"
					cHTML+= "win.moveTo(meio2, meio1);"
					cHTML+= "win.document.getElementById('msg_win').innerHTML = '';"
					cHTML+= "win.document.write(request.responseText);"
					cHTML+= "} else {"
					cHTML+= 'win.close();alert("status is " + request.status);}'
					cHTML+= "} "
					cHTML+= "} "

					cHTML+= "function getPosicaoFinanceira() {"
					cHTML+= 'var cliente = document.getElementById("cliente").value;'
					cHTML+= 'var loja = document.getElementById("loja").value;'
					cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_pfin.apl?rdm='+encodeURI(Math.random())+'&cliente='+cliente+'&loja='+loja;"
					cHTML+= "if (cliente == '')"
					cHTML+= "{"
					cHTML+= "  win.close();"
					cHTML+= "  alert('Selecione cliente apra continuar...');"
					cHTML+= "  return false;"
					cHTML+= "}"
					cHTML+= "request.open('GET', url, true);"
					cHTML+= "request.onreadystatechange = posicaoFinanceira;"
					cHTML+= "request.send(null);"
					cHTML+= "}"

					cHTML+= "function posicaoFinanceira() {  "
					cHTML+= "largura = screen.width/2;"
					cHTML+= "altura = screen.height/2;"
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
					//cHTML+= "win = window.open('','','height=' + altura + ', width=' + largura + ', top='+meio1+', left='+meio2+'');"
					cHTML+= "win.resizeTo(largura, altura);"
					cHTML+= "win.moveTo(meio2, meio1);"
					cHTML+= "win.document.getElementById('msg_win').innerHTML = '';"
					cHTML+= "win.document.write(request.responseText);"
					cHTML+= "} else {"
					cHTML+= 'win.close();alert("status is " + request.status);}'
					cHTML+= "} "
					cHTML+= "} "

					cHTML+= "function getListaPreco() {"
					cHTML+= 'var cliente = document.getElementById("cliente").value;'
					cHTML+= 'var loja = document.getElementById("loja").value;'
					cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_lprec.apl?rdm='+encodeURI(Math.random())+'&cliente='+cliente+'&loja='+loja;"
					cHTML+= "if (cliente == '')"
					cHTML+= "{"
					cHTML+= "  win.close();"
					cHTML+= "  alert('Selecione cliente para continuar...');"
					cHTML+= "  return false;"
					cHTML+= "}"
					cHTML+= "request.open('GET', url, true);"
					cHTML+= "request.onreadystatechange = listaPreco;"
					cHTML+= "request.send(null);"
					cHTML+= "}"

					cHTML+= "function listaPreco() {  "
					cHTML+= "largura = screen.width/2;"
					cHTML+= "altura = screen.height/2;"
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

					cHTML+= "function historicoVendas() {"
					cHTML+= "var cliente = document.getElementById('cliente').value;"
					cHTML+= "var loja = document.getElementById('loja').value;"
					cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_hvend.apl?rdm='+encodeURI(Math.random())+'&cliente='+cliente+'&loja='+loja+'&senha="+cPass+"&usuario="+cUser+"&email="+cMail+"';"
					cHTML+= "if (cliente == '')"
					cHTML+= "{"
					cHTML+= "  win.close();"
					cHTML+= "  alert('Selecione cliente apra continuar...');"
					cHTML+= "  return false;"
					cHTML+= "}"
					cHTML+= "request.open('GET', url, true);"
					cHTML+= "request.onreadystatechange = HistVendas;"
					cHTML+= "request.send(null);"
					cHTML+= "}"

					cHTML+= "function HistVendas() {  "
					cHTML+= "largura = screen.width/2;"
					cHTML+= "altura = screen.height/2;"
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

					cHTML+= "function ChamaSuporte() {"
					cHTML+= "var url = '"+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+"/u_p_sup.apl?rdm='+encodeURI(Math.random())+'&senha="+cPass+"&usuario="+cUser+"&email="+cMail+"';"
					cHTML+= "request.open('GET', url, true);"
					cHTML+= "request.onreadystatechange = ChamaSup;"
					cHTML+= "request.send(null);" 
					cHTML+= "}"

					cHTML+= "function ChamaSup(){"
					cHTML+= "largura = screen.width/2;"
					cHTML+= "altura = screen.height/2;"
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

					cHTML+= " function sair()"
					cHTML+= " {"
					cHTML+= "var doc=document.open('text/html','replace');"
					cHTML+= "doc.close();
					cHTML+= ' document.write("Operação Encerrada!");'   				
					cHTML+= " }"


					cHTML+= "</Script>"

					cHTML+= "<div id='toolbar'><div id='page'>"
					cHTML+= "<input type='hidden' name='usuario' id='usuario' value='"+cUser+"' />"
					cHTML+= "<input type='hidden' name='senha' id='senha' value='"+cPass+"' />"
					cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
					cHTML+= "<b>Seja Bem-vindo.</b><br>" 
					cHTML+= "<b>Usuário do Portal: ("+ZZJ->ZZJ_COD+") "+ZZJ->ZZJ_NOME+"</b><br>"
					cHTML+= "<b>Nome do Vendedor: ("+cCRep+") " + cNRep + "</b><br>"
					cHTML+= "<p><font size=2>Este é seu acesso de número: &nbsp;&nbsp; " + str(ZZJ->ZZJ_NACESS) + "</font><br><br>"
					//cHTML+= "<input type='button' value='Pedidos de venda' onclick='gerenciarPedidos()' />"
					//cHTML+= "<input type='button' value='Analise de credito' onclick='getAnaliseCredito()' />"
					//cHTML+= "<input type='button' value='Dados cadastrais' onclick='getDadosCadastrais();' />"
					//cHTML+= "<input type='button' value='Posicao financeira' onclick='getPosicaoFinanceira()' />"
					//cHTML+= "<input type='button' value='Lista de precos' onclick='getListaPreco()' />"
					//cHTML+= "<input type='button' value='Historico de vendas' onclick='historicoVendas()' />"
					//cHTML+= "<input type='button' value='Lista de pedidos' onclick='listarPedidos()' />"
					//cHTML+= "<input type='button' value='Suporte' onclick='ChamaSuporte()' />"

					//tratamento para evitar bloqueio de pop up
					cHTML+= "<input type='button' value='Pedidos de venda'    onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>Buscando informações, aguarde...</div>"'+");gerenciarPedidos()    ;return false;' />"
					cHTML+= "<input type='button' value='Analise de credito'  onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>Buscando informações, aguarde...</div>"'+");getAnaliseCredito()   ;return false;' />"
					cHTML+= "<input type='button' value='Dados cadastrais'    onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>Buscando informações, aguarde...</div>"'+");getDadosCadastrais()  ;return false;' />"
					cHTML+= "<input type='button' value='Posicao financeira'  onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>Buscando informações, aguarde...</div>"'+");getPosicaoFinanceira();return false;' />"
					cHTML+= "<input type='button' value='Lista de precos'     onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>Buscando informações, aguarde...</div>"'+");getListaPreco()       ;return false;' />"
					cHTML+= "<input type='button' value='Historico de vendas' onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>Buscando informações, aguarde...</div>"'+");historicoVendas()     ;return false;' />"
					cHTML+= "<input type='button' value='Lista de pedidos'    onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>Buscando informações, aguarde...</div>"'+");listarPedidos()       ;return false;' />"
					cHTML+= "<input type='button' value='Suporte'             onclick='win=window.open("+'"","","width=300,height=100,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no"'+");win.document.write("+'"<div id=msg_win>Buscando informações, aguarde...</div>"'+");ChamaSuporte()        ;return false;' />"

					cHTML+= "<input type='button' value='Sair' onclick='sair()' />"
					cHTML+= "<br>"
					cHTML+= "<p><font size=2>Ordenar Clientes por:&nbsp;<select id='ordem' name='ordem'><option selected value='A1_NOME, A1_MUN, A1_EST'>Nome+Municipio+Estado</option><option value='A1_NREDUZ, A1_MUN, A1_EST'>Fantasia+Municipio+Estado</option><option value='A1_MUN, A1_NOME'>Municipio+Nome</option><option value='A1_EST, A1_NOME'>Estado+Nome</option></select></Font>" 
					cHTML+= "<font size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Busca Cliente por Codigo:&nbsp;<input type='text' id='codcliente' value='' maxlength='06' size='06'/>&nbsp;&nbsp;"
					cHTML+= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Busca Cliente por Nome:&nbsp;<input type='text' id='nomcliente' value='' maxlength='20' size='20'/>&nbsp;&nbsp;<input type='button' value='Atualizar' onclick='buscaClientes()'/></font></p>" 

					cHTML+= "<input type='hidden' id='cliente' value='' />"
					cHTML+= "<input type='hidden' id='loja' value='' />"
					cHTML+= "</div>"     
					cHTML+= "<br>"
					cHTML+= "<div id='browser'>"

					//cHTML+= "<table id='tabb' border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
					cHTML+= "<table id='tabb' border='1px' width='100%'>"
					cHTML+= "<tr height='25px'>"
					cHTML+= "<td>"+EncodeUTF8("")+"</td>"
					cHTML+= "<td>Codigo</td>"
					cHTML+= "<td>Loja</td>"
					cHTML+= "<td>Razao Social</td>"
					cHTML+= "<td>Fantasia</td>"
					cHTML+= "<td>Nome</td>"
					cHTML+= "<td>Endereco</td>"
					cHTML+= "<td>Municipio</td>"
					cHTML+= "<td>Estado</td>"
					/*cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Telefone</font></td>"
					cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Email</font></td>"
					cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Lim Credito</font></td>"
					cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Venc Lim Cred</font></td>"
					cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Condicao Pagto</font></td>"
					cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Forma de Cobranca</font></td>"
					cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Ultima Compra</font></td>"
					cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Credito Vigente</font></td>"*/
					cHTML+= "</tr>"
					cHTML+= "</table>"

					cHtml+= "</div></div>"
					cHTML+= "</body></html>"   

				Elseif found() .and.cStat # 'L'
					cHTML:="<html>" 
					cHTML+="<head>"
					cHTML+="<meta http-equiv='Cache-Control' content='No-Cache'>
					cHTML+="<meta http-equiv='Pragma' content='No-Cache'>"
					cHTML+="<meta http-equiv='Expires' content='0'>"
					cHTML+="</head>" 
					cHTML+= "<body>"
					cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"  
					cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br>"
					cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Vendedor Bloqueado.</b></font><br><br><input type='button' value='Voltar' onclick='document:history.back(1)' /></body></html>"			
				else
					cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
					cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Vendedor encontrado.</b></font><br><input type='button' value='Voltar' onclick='document:history.back(1)' /></body></html>"
				EndIf
			Else
				cHTML:="<html>" 
				cHTML+="<head>"
				cHTML+="<meta http-equiv='Cache-Control' content='No-Cache'>
				cHTML+="<meta http-equiv='Pragma' content='No-Cache'>"
				cHTML+="<meta http-equiv='Expires' content='0'>"
				cHTML+="</head>" 
				cHTML+= "<body>"
				cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"
				cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
				cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Senha incorreta, digite novamente.</b></font><br><br><input type='button' value='Voltar' onclick='document:history.back(1)' /></body></html>"
			EndIf
		Else
			cHTML:="<html>" 
			cHTML+="<head>"
			cHTML+="<meta http-equiv='Cache-Control' content='No-Cache'>
			cHTML+="<meta http-equiv='Pragma' content='No-Cache'>"
			cHTML+="<meta http-equiv='Expires' content='0'>"
			cHTML+="</head>" 
			cHTML+= "<body>"
			cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"
			cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"			
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Usuario digitado invalido.</b></font><br><br><input type='button' value='Voltar' onclick='document:history.back(1)' /></body></html>"
		EndIf                      
	Else
		cHTML:="<html>" 
		cHTML+="<head>"
		cHTML+="<meta http-equiv='Cache-Control' content='No-Cache'>
		cHTML+="<meta http-equiv='Pragma' content='No-Cache'>"
		cHTML+="<meta http-equiv='Expires' content='0'>"
		cHTML+="</head>" 
		cHTML+= "<body>"
		cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"  
		cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Usuario ou senha em branco.</b></font><br><br><input type='button' value='Voltar' onclick='document:history.back(1)' /></body></html>"
	EndIf

	RESET ENVIRONMENT

Return cHTML
