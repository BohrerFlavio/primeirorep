#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_altped(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)
	Local cPed:= ""
	Local cUser:= ""
	Local cTabela:= ""
	Local cHTML:= ""
	Local nX:= 0
	Local cMail:= ""

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1", "ZZ4", "ZZ5"

	For nX:= 1 To Len(__aProcParms)
		If __aProcParms[nX, 1] == "pedido"
			cPed:= __aProcParms[nX, 2]
		EndIf
		If __aProcParms[nX, 1] == "usuario"
			cUser:= __aProcParms[nX, 2]
		EndIf	
		If __aProcParms[nX, 1] == "email"
			cMail:= __aProcParms[nX, 2]
		EndIf  
		If __aProcParms[nX, 1] == "cliente"
			cCli:= __aProcParms[nX, 2]
		EndIf
		If __aProcParms[nX, 1] == "loja"
			cLoja:= __aProcParms[nX, 2]
		EndIf

	Next


	If !Empty(cPed) .AND. !Empty(cUser)

		dbSelectArea("ZZ4")
		dbSetOrder(2)
		dbSeek(xFilial("ZZ4")+cPed)
		If Found()

			If ZZ4->ZZ4_STATUS != "P"
				cHTML:= "<b>Nao e permitida a manutencao de pedidos com status diferente de 'P', verifique.</b></p><input type='button' value='Fechar' onclick='window.close()' />"
			Else

				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1")+ZZ4->ZZ4_CODCLI+ZZ4->ZZ4_LOJA)
				cTabela:= SA1->A1_TABELA

				//pego o numero de itens
				dbSelectArea("ZZ5")
				dbSetorder(1)
				dbSeek(xFilial("ZZ5")+cPed)
				_nI:= 0
				Do While !ZZ5->(EOF()) .AND. xFilial("ZZ5")+cPed == ZZ5->ZZ5_FILIAL+ZZ5->ZZ5_NUM
					_nI++
					ZZ5->(dbSkip())
				EndDo

				cHTML:= "<html>"

				cHTML+= "<style type='text/css'>"
				cHTML+= "div.digiprod {"
				cHTML+= "border: 1px solid;"
				cHTML+= "border-color: #f000000 #f000000 #f000000 #f000000;}" 
				cHTML+= "</style>"

				cHTML+= "<body>"
				cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>" 
				cHTML+= "<link rel='shortcut icon' href='imagens/silva.ico'>"
				cHTML+= '<font face="arial" size="2">'
				cHTML+= "<title>PORTAL DO VENDEDOR - Alterar Pedido de Venda - Tabela de Precos "+cTabela+"</title>"   
				cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br>" 
				cHTML+= "<input type='button' value='Alterar' onclick='ChamaPost()' />&nbsp;&nbsp;" 
				cHTML+= "<input type='button' value='Fechar' onclick='window.close()' />&nbsp;&nbsp;"

				cHTML+= '<script language="javascript">'

				cHTML+= "  var totals = "+cValToChar(_nI)+";"
				cHTML+= "  var request = false;"
				cHTML+= "  var lin = 0;"
				cHTML+= " try {  "
				cHTML+= "    request = new XMLHttpRequest();  "
				cHTML+= "  } catch (trymicrosoft) {  "
				cHTML+= "    try {  "
				cHTML+= '      request = new ActiveXObject("Msxml2.XMLHTTP");  '
				cHTML+= "      } catch (othermicrosoft) {  "
				cHTML+= "        try {  "
				cHTML+= '          request = new ActiveXObject("Microsoft.XMLHTTP");  '
				cHTML+= "        } catch (failed) {  "
				cHTML+= "          request = false;  "
				cHTML+= "          }    "
				cHTML+= "      }  "
				cHTML+= "  }  "

				cHTML+= "  if (!request)  "
				cHTML+= '    alert("Error initializing XMLHttpRequest!");'

				cHTML+= '  function deleta(linha){'   
				cHTML+= '    var tbl = document.getElementById("itens");' 
				cHTML+= '    var objLinha = linha.parentNode.parentNode;' 
				cHTML+= '    tbl.deleteRow(objLinha.rowIndex);'   
				//			cHTML+= '    totals--;   
				cHTML+= '  }' 


				/*cHTML+= '  function cab(linha) {'
				cHTML+= '    var clientes_codi = "clientes_codi_"+linha.parentNode.parentNode.rowIndex;'
				cHTML+= '    var clientes_loja = "clientes_loja_"+linha.parentNode.parentNode.rowIndex;'
				cHTML+= '    var clientes_nome = "clientes_nome_"+linha.parentNode.parentNode.rowIndex;'
				cHTML+= '    var clientes_cida = "clientes_cida_"+linha.parentNode.parentNode.rowIndex;'
				cHTML+= '    var clientes_tabe = "clientes_tabe_"+linha.parentNode.parentNode.rowIndex;'

				cHTML+= '    document.getElementById("cab_codi").value = document.getElementById(clientes_codi).value;'
				cHTML+= '    document.getElementById("cab_loja").value = document.getElementById(clientes_loja).value;'
				cHTML+= '    document.getElementById("cab_nome").value = document.getElementById(clientes_nome).value;'
				cHTML+= '    document.getElementById("cab_cida").value = document.getElementById(clientes_cida).value;'
				cHTML+= '    document.getElementById("produtos_tabela").value = document.getElementById(clientes_tabe).value;'
				cHTML+= '    document.getElementById("clientes").style.visibility = "hidden";'
				cHTML+= '  }'

				cHTML+= '  function f3a1() { '
				cHTML+= '  	 buscaClientes();'
				cHTML+= '    document.getElementById("clientes").style.visibility = "visible";'
				cHTML+= '  }'	

				cHTML+= "  function buscaClientes() {  "
				cHTML+= '    var url = "http://portaldovendedor.frigorficosilva.com.br:91/u_p_cli.apl?vendedor="+document.getElementById("usuario").value;'
				cHTML+= '    request.open("GET", url, true);'
				cHTML+= "    request.onreadystatechange = atualizaClientes;"
				cHTML+= "    request.send(null);  "
				cHTML+= "  }  "

				cHTML+= '  function atualizaClientes() {'
				cHTML+= '    if (request.readyState == 4) {  '
				cHTML+= '      if (request.status == 200) {  '
				cHTML+= '        document.getElementById("tab_cli").innerHTML = request.responseText;'
				cHTML+= '      } else  '
				cHTML+= '        alert("status is " + request.status);  '
				cHTML+= '    }  '
				cHTML+= '  }'*/

				cHTML+= '  function f3b1(item) { '   
				cHTML+= '    var lin = item.id.substr(10,1);'   
				cHTML+= '    var NumLin = 0;  '
				cHTML+= '    NumLin = eval(item.id.substr(10, 2));'
				cHTML+= '    if (NumLin < 10)' 
				cHTML+= '     { '                    
				cHTML+= '    lin = item.id.substr(10, 1);' 
				cHTML+= '     } '
				cHTML+= '    else '
				cHTML+= '     { '
				cHTML+= '    lin = item.id.substr(10, 2);'       	
				cHTML+= '     } '  		
				cHTML+= '    buscaProdutos();'
				cHTML+= '    document.getElementById("produtos").style.visibility = "visible";'
				cHTML+= '    document.getElementById("produtos_item").value = lin;'
				cHTML+= '  }'

				cHTML+= '  function buscaProdutos() {  '
				cHTML+= '    var url = "'+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+'/u_p_prod.apl?rdm="+encodeURI(Math.random())+"&lista="+document.getElementById("produtos_tabela").value;'
				cHTML+= '    request.open("GET", url, true);'
				cHTML+= '    request.onreadystatechange = atualizaProdutos;'
				cHTML+= '    request.send(null);  '
				cHTML+= '  }  '

				cHTML+= '  function atualizaProdutos() {  '
				cHTML+= '    if (request.readyState == 4) {  '
				cHTML+= '      if (request.status == 200) {  '
				cHTML+= '        document.getElementById("tab_prod").innerHTML = request.responseText;'
				cHTML+= '      } else  '
				cHTML+= '        alert("status is " + request.status);  '
				cHTML+= '    }  '
				cHTML+= '  }'


				cHTML+= '  function preenche_itens(linha) {' 
				cHTML+= '    var i = 1 ;'
				cHTML+= '    var grid_prod = "grid_prod_"+document.getElementById("produtos_item").value;'
				cHTML+= '    var grid_desc = "grid_desc_"+document.getElementById("produtos_item").value;'
				cHTML+= '    var grid_prec = "grid_prec_"+document.getElementById("produtos_item").value;'
				cHTML+= '    var grid_prcf = "grid_prcf_"+document.getElementById("produtos_item").value;'
				cHTML+= '    var produtos_prod = "produtos_prod_"+linha.parentNode.parentNode.rowIndex;'
				cHTML+= '    var produtos_desc = "produtos_desc_"+linha.parentNode.parentNode.rowIndex;'
				cHTML+= '    var produtos_prec = "produtos_prec_"+linha.parentNode.parentNode.rowIndex;'
				cHTML+= '    var produtos_prcf = "produtos_prcf_"+linha.parentNode.parentNode.rowIndex;'
				cHTML+= '    var CodigoProduto = document.getElementById(produtos_prod).value.substr(0,6); ' 
				cHTML+= "    for (i == 1; i <= totals; i++)" 
				cHTML+= "    {        "    
				cHTML+= "     if (document.getElementById('grid_prod_'+i))"
				cHTML+= "	  {    "                           
				cHTML+= "      if (CodigoProduto == document.getElementById('grid_prod_'+i).value.substr(0,6))" 
				cHTML+= "      {     "    
				cHTML+= "          alert('Produto repetido! Verifique os itens ja incluidos no pedido!');" 
				cHTML+= "          return false;"   
				cHTML+= "       } " 
				cHTML+= "     }"    
				cHTML+= "    }" 
				cHTML+= '    document.getElementById(grid_prod).value = document.getElementById(produtos_prod).value;'
				cHTML+= '    document.getElementById(grid_desc).value = document.getElementById(produtos_desc).value;'
				cHTML+= '    document.getElementById(grid_prec).value = document.getElementById(produtos_prec).value;'
				cHTML+= '    document.getElementById(grid_prcf).value = document.getElementById(produtos_prec).value;'
				cHTML+= '    document.getElementById("produtos").style.visibility = "hidden";  '
				cHTML+= '  }'


				cHTML+= '  var moeda = {'+chr(13)
				cHTML+= '    desformatar: function(num){'+chr(13)
				cHTML+= '    num = num.replace(".","");'+chr(13)
				cHTML+= '    num = num.replace(",",".");'+chr(13)
				cHTML+= '	  return parseFloat(num);'+chr(13)
				cHTML+= '	},'+chr(13)

				cHTML+= '    formatar: function(num){'+chr(13)
				cHTML+= '      x = 0;'+chr(13)
				cHTML+= '      if(num<0){'+chr(13)
				cHTML+= '        num = Math.abs(num);'+chr(13)
				cHTML+= '        x = 1;'+chr(13)
				cHTML+= '      }'+chr(13)
				cHTML+= '      if(isNaN(num)) num = "0";'+chr(13)
				cHTML+= '        cents = Math.floor((num*100+0.5)%100);'+chr(13)
				cHTML+= '        num = Math.floor((num*100+0.5)/100).toString();'+chr(13)
				cHTML+= '	  if(cents < 10) cents = "0" + cents;'+chr(13)
				cHTML+= '        for (var i = 0; i < Math.floor((num.length-(1+i))/3); i++)'+chr(13)
				cHTML+= "          num = num.substring(0,num.length-(4*i+3))+'.'+num.substring(num.length-(4*i+3));"+chr(13)
				cHTML+= "          ret = num + ',' + cents;"+chr(13)
				cHTML+= "	      if (x == 1) ret = ' - ' + ret; return ret;"+chr(13)
				cHTML+= '	    },'+chr(13)
				cHTML+= '	    arredondar: function(num){'+chr(13)
				cHTML+= '        return Math.round(num*Math.pow(10,2))/Math.pow(10,2);'+chr(13)
				cHTML+= '    }'+chr(13)
				cHTML+= '  }'+chr(13)

				cHTML+= '  function formatar(src, mask){'+chr(13)
				cHTML+= '    var i = src.value.length;'+chr(13)
				cHTML+= '    var saida = mask.substring(0,1);'+chr(13)
				cHTML+= '    var texto = mask.substring(i);'+chr(13)
				cHTML+= '    if (texto.substring(0,1) != saida) {'+chr(13)
				cHTML+= '      src.value += texto.substring(0,1);'+chr(13)
				cHTML+= '    }'+chr(13)
				cHTML+= '  }'+chr(13)

				cHTML+= "  function MascaraMoeda(objTextBox, e, Tamanho, Decimais){"
				cHTML+= "    var sep = 0;"
				cHTML+= "    var key = '';"
				cHTML+= "    var i = j = 0;"
				cHTML+= "    var len = len2 = 0;"
				cHTML+= "    var strCheck = '0123456789';"
				cHTML+= "    var aux = aux2 = aux3 = '';"
				cHTML+= "    var whichCode = (window.Event) ? e.which : e.keyCode;"
				cHTML+= "    var SeparadorMilesimo = '.';"
				cHTML+= "    var SeparadorDecimal = ',';"

				cHTML+= "    if (objTextBox.value.length == Tamanho && objTextBox.value.charAt(0) != '0') {"
				cHTML+= "      objTextBox.value = objTextBox.value;"
				cHTML+= "      return false;"
				cHTML+= "    }"

				cHTML+= "    if (whichCode == 13)"
				cHTML+= "      return true;"
				cHTML+= "    key = String.fromCharCode(whichCode);"
				cHTML+= "    if (strCheck.indexOf(key) == -1)"
				cHTML+= "      return false;"
				cHTML+= "    len = objTextBox.value.length;"
				cHTML+= "    for(i = 0; i < len; i++)"
				cHTML+= "      if ((objTextBox.value.charAt(i) != '0') && (objTextBox.value.charAt(i) != SeparadorDecimal)) break;"

				cHTML+= "    aux = '';"
				cHTML+= "    for(; i < len; i++)"
				cHTML+= "      if (strCheck.indexOf(objTextBox.value.charAt(i))!=-1)"
				cHTML+= "        aux += objTextBox.value.charAt(i);"
				cHTML+= "    aux += key;"
				cHTML+= "    len = aux.length;"

				cHTML+= "    for(i = 1; i <= Decimais - len; i++)"
				cHTML+= "      aux3 = aux3+'0';"


				cHTML+= "    if (Decimais == 0){"
				cHTML+= "      objTextBox.value = aux;"
				cHTML+= "      return false;"
				cHTML+= "    }"


				cHTML+= "    if (len == 0)"
				cHTML+= "      objTextBox.value = '';"
				cHTML+= "    else"
				cHTML+= "      objTextBox.value = '0'+ SeparadorDecimal + aux3 + aux;"

				cHTML+= "    if (len > Decimais) {"
				cHTML+= "      aux2 = '';"
				cHTML+= "      for (j = 0, i = len - (Decimais + 1); i >= 0; i--) {"
				cHTML+= "        if (j == 3) {"
				cHTML+= "          aux2 += SeparadorMilesimo;"
				cHTML+= "          j = 0;"
				cHTML+= "        }"
				cHTML+= "        aux2 += aux.charAt(i);"
				cHTML+= "        j++;"
				cHTML+= "      }"

				cHTML+= "      objTextBox.value = '';"
				cHTML+= "      len2 = aux2.length;"

				cHTML+= "      for (i = len2 - 1; i >= 0; i--)"
				cHTML+= "        objTextBox.value += aux2.charAt(i);"
				cHTML+= "      objTextBox.value += SeparadorDecimal + aux.substr(len - Decimais, len);"
				cHTML+= "    }"

				cHTML+= "    return false;"
				cHTML+= "  }"

				cHTML+= '  function buscaPeso(caixas) {'
				cHTML+= '    var url = "";'  
				cHTML+= '    lin = caixas.id.substr(10, 1);'  
				cHTML+= '    var NumLin = 0;  '
				cHTML+= '    NumLin = eval(caixas.id.substr(10, 2));'
				cHTML+= '    if (NumLin < 10)' 
				cHTML+= '     { '                    
				cHTML+= '    lin = caixas.id.substr(10, 1);' 
				cHTML+= '     } '
				cHTML+= '    else '
				cHTML+= '     { '
				cHTML+= '    lin = caixas.id.substr(10, 2);'       	
				cHTML+= '     } '  
				cHTML+= '    url = "'+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+'/u_p_gpeso.apl?rdm="+encodeURI(Math.random())+"&produto="+document.getElementById("grid_prod_"+lin).value+"&caixas="+caixas.value;'
				cHTML+= '    request.open("GET", url, true);  '
				cHTML+= '    request.onreadystatechange = atualizaPeso;'
				cHTML+= '    request.send(null);  '
				cHTML+= '  }  '

				cHTML+= '  function atualizaPeso() {'
				cHTML+= '    if (request.readyState == 4) {'
				cHTML+= '      if (request.status == 200) {'
				cHTML+= '        document.getElementById("grid_peso_"+lin).value = request.responseText;'
				cHTML+= '        calcula_totais();'
				cHTML+= '      } else  '
				cHTML+= '        alert("status is " + request.status);  '
				cHTML+= '    }  '
				cHTML+= '  }'

				cHTML+= '  function buscaCaixas(peso) {'
				cHTML+= '    var url = "";'
				cHTML+= '    lin = peso.id.substr(10, 1);'      
				cHTML+= '    var NumLin = 0;  '
				cHTML+= '    NumLin = eval(peso.id.substr(10, 2));'
				cHTML+= '    if (NumLin < 10)' 
				cHTML+= '     { '                    
				cHTML+= '    lin = peso.id.substr(10, 1);' 
				cHTML+= '     } '
				cHTML+= '    else '
				cHTML+= '     { '
				cHTML+= '    lin = peso.id.substr(10, 2);'       	
				cHTML+= '     } '  
				cHTML+= '    url = "'+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+'/u_p_gcaixa.apl?rdm="+encodeURI(Math.random())+"&produto="+document.getElementById("grid_prod_"+lin).value+"&peso="+peso.value;'
				cHTML+= '    request.open("GET", url, true);  '
				cHTML+= '    request.onreadystatechange = atualizaCaixas;'
				cHTML+= '    request.send(null);  '
				cHTML+= '  }  '

				cHTML+= '  function atualizaCaixas() {'
				cHTML+= '    if (request.readyState == 4) {'
				cHTML+= '      if (request.status == 200) {'
				cHTML+= '        document.getElementById("grid_caix_"+lin).value = request.responseText;'
				cHTML+= '        calcula_totais();'
				cHTML+= '      } else  '
				cHTML+= '        alert("status is " + request.status);  '
				cHTML+= '    }  '
				cHTML+= '  }'

				cHTML+= '  function calcula_totais() {'
				cHTML+= '    var i = 0;'
				cHTML+= '    var peso = 0;'
				cHTML+= '    var pesoaux = 0;'
				cHTML+= '    var caixas = 0;'
				cHTML+= '    var total = 0;'
				cHTML+= '    var aux = 0;'
				cHTML+= '    for (i == 0; i <= totals; i++) {'
				cHTML+= '      if (document.getElementById("grid_peso_"+i)) {'
				cHTML+= '        aux = document.getElementById("grid_peso_"+i).value.replace(".", "");'
				cHTML+= '        aux = aux.replace(",", ".");'
				cHTML+= '        pesoaux = aux;'
				cHTML+= '        peso+= eval(aux);'
				cHTML+= '      }'
				cHTML+= '    	if (document.getElementById("grid_caix_"+i)) {'
				cHTML+= '    	  aux = document.getElementById("grid_caix_"+i).value.replace(".", "");'
				cHTML+= '    	  aux = aux.replace(",", ".");'
				cHTML+= '        caixas+= eval(aux);'
				cHTML+= '      }'
				cHTML+= '      if (document.getElementById("grid_prec_"+i)) {'
				cHTML+= '        aux = document.getElementById("grid_prec_"+i).value.replace(".", "");'
				cHTML+= '        aux = aux.replace(",", ".");'
				cHTML+= '        aux = eval(aux) * eval(pesoaux);'
				cHTML+= '        total+= aux;'
				cHTML+= '      }'
				cHTML+= '    }'
				cHTML+= '    document.getElementById("cab_peso").value = moeda.formatar(peso);'
				cHTML+= '    document.getElementById("cab_caix").value = caixas;'
				cHTML+= '    document.getElementById("cab_tota").value = moeda.formatar(total);'
				cHTML+= '    return'
				cHTML+= '  }'

				cHTML+= '  function preco_final(prod) {'     
				cHTML+= '    var NumLin = 0;'  
				cHTML+= '    var prcf   = 0;'
				cHTML+= '    var prc    = 0;'
				cHTML+= '    var boni   = 0;'
				cHTML+= '    var tpbon  = "";' 
				cHTML+= '    NumLin = eval(prod.id.substr(10, 2));'    

				cHTML+= '    if (NumLin < 10)' 
				cHTML+= '     { '                    
				cHTML+= '    lin = prod.id.substr(10, 1);' 
				cHTML+= '     } '
				cHTML+= '    else '
				cHTML+= '     { '
				cHTML+= '    lin = prod.id.substr(10, 2);'       	
				cHTML+= '     } '   
				cHTML+= '    prc  = document.getElementById("grid_prec_"+lin).value.replace(".", "");'   
				cHTML+= '    prc  = prc.replace(",", ".");' 
				cHTML+= '    prc  = eval(prc);'  
				cHTML+= '    if (document.getElementById("grid_boni_"+lin).value != "") '
				cHTML+= '       {   '
				cHTML+= '        boni = document.getElementById("grid_boni_"+lin).value.replace(".", "");'   
				cHTML+= '        boni = boni.replace(",", ".");' 
				cHTML+= '        boni = eval(boni);'	
				cHTML+= '       }   '  
				cHTML+= '    tpbon  = document.getElementById("grid_tbon_"+lin).value;' 
				cHTML+= '    if (tpbon == "D")' 
				cHTML+= '     { '                    
				cHTML+= '       prcf = prc - boni;' 
				cHTML+= '     } '
				cHTML+= '    else if(tpbon == "A")'
				cHTML+= '     { '
				cHTML+= '       prcf = prc + boni;' 
				cHTML+= '     } '
				cHTML+= '    else '
				cHTML+= '     { '
				cHTML+= '       prcf = prc;'      	    	
				cHTML+= '     } '   
				cHTML+= '    document.getElementById("grid_prcf_"+lin).value = moeda.formatar(prcf);' 
				cHTML+= '  }'

				cHTML+= '  function desabilita_capos(e) {'
				cHTML+= '    var whichCode = (window.Event) ? e.which : e.keyCode;'
				cHTML+= '    if (whichCode == 9)'
				cHTML+= '      return true;'
				cHTML+= '    else'
				cHTML+= '      return false;'
				cHTML+= '  }'     

				cHTML+= ' function adiciona(){' 
				cHTML+= " var i = 1; "
				cHTML+= " var j = 1; "  
				cHTML+= " var k = '';"
				cHTML+= " var fail = false;"  
				cHTML+= "for (i == 1; i <= totals; i++)"  
				cHTML+= "{"
				cHTML+= "    if (document.getElementById('grid_prod_'+i).value == '')"
				cHTML+= "      {     "   
				cHTML+= "         fail = true;" 
				cHTML+= "         break;"   
				cHTML+= "      }"  
				cHTML+= "    if (document.getElementById('grid_caix_'+i).value == 0)"
				cHTML+= "      {     "   
				cHTML+= "         fail = true;" 
				cHTML+= "         break;"   
				cHTML+= "      }"
				cHTML+= "    if (document.getElementById('grid_peso_'+i).value == 0)"
				cHTML+= "      {     "   
				cHTML+= "         fail = true;" 
				cHTML+= "         break;"   
				cHTML+= "      }"                                                	 
				cHTML+= "}"	 
				cHTML+= "      if (fail)" 
				cHTML+= "      {     "    
				cHTML+= "          alert('Falha na inclusao de pedidos! Faltam informacoes para os itens de produtos!');" 
				cHTML+= "          return false;"   
				cHTML+= "       } "                
				cHTML+= 'totals++;'+chr(13)
				cHTML+= 'var tbl = document.getElementById("itens");'+chr(13)
				cHTML+= "var item = totals+'';"+chr(13)
				cHTML+= 'if (item.length == 1)'+chr(13)
				cHTML+= "  item = '00'+item;"+chr(13)
				cHTML+= 'else'+chr(13)
				cHTML+= "  item = '0'+item;"+chr(13)
				cHTML+= 'var novaLinha = tbl.insertRow(-1);'+chr(13)
				cHTML+= 'var novaCelula;'+chr(13)
				cHTML+= 'novaCelula = novaLinha.insertCell(0);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)
				cHTML+= 'novaCelula.innerHTML = "<input type='+"'button'"+' value='+"'Apagar'"+' onClick='+"'deleta(this);'"+' />";
				cHTML+= 'novaCelula = novaLinha.insertCell(1);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)
				cHTML+= 'novaCelula.innerHTML = "<input type='+"'text'"+' name="+'+"'grid_item_'"+'+totals+" id="+'+"'grid_item_'"+'+totals+" maxlength='+"'2'"+' size='+"'2'"+' value="+item+" readonly='+"'readonly'"+' style='+"'border:none'"+' />";'
				cHTML+= 'novaCelula = novaLinha.insertCell(2);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)

				//    cHTML+= 'novaCelula.innerHTML = "<div style='+"'position:relative;width:150px;height:15px;top:-5px'"+'><input type='+"'text'"+' name="+'+"'grid_prod_'"+'+totals+" id="+'+"'grid_prod_'"+'+totals+" maxlength='+"'06'"+' size='+"'06'"+' style='+"'border:none'"+' onBlur='+"'buscaProdDig(this);'"+'/><input type='+"'button'"+' value='+"'?'"+' onClick='+"'f3b1(totals);'"+'/></div>";'
				cHTML+= 'novaCelula.innerHTML = "<div class=digiprod><input type='+"'text'"+' name="+'+"'grid_prod_'"+'+totals+" id="+'+"'grid_prod_'"+'+totals+" maxlength='+"'06'"+' size='+"'06'"+' style='+"'border:none'"+' onBlur='+"'buscaProdDig(this);'"+'/></div><a href=# name="+'+"'grid_busc_'"+'+totals+" id="+'+"'grid_busc_'"+'+totals+" onClick='+"' f3b1(this);'"+'/>[procurar]</a>";' 
				cHTML+= 'novaCelula = novaLinha.insertCell(3);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)
				cHTML+= 'novaCelula.innerHTML = "<input type='+"'text'"+' name="+'+"'grid_desc_'"+'+totals+" id="+'+"'grid_desc_'"+'+totals+" readonly='+"'readonly'"+' maxlength='+"'25'"+' size='+"'60'"+' style='+"'border:none'"+' />";'

				cHTML+= 'novaCelula = novaLinha.insertCell(4);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)
				cHTML+= 'novaCelula.innerHTML = "<input type='+"'text'"+' name="+'+"'grid_caix_'"+'+totals+" id="+'+"'grid_caix_'"+'+totals+" maxlength='+"'4'"+' size='+"'7'"+' value='+"'0'"+' style='+"'text-align:right;border:none;'"+' onKeyPress='+"'return(MascaraMoeda(this, event, 5, 0))'"+' onBlur='+"'buscaPeso(this)'"+' />";'

				cHTML+= 'novaCelula = novaLinha.insertCell(5);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)
				cHTML+= 'novaCelula.innerHTML = "<input type='+"'text'"+' name="+'+"'grid_peso_'"+'+totals+" id="+'+"'grid_peso_'"+'+totals+" maxlength='+"'9'"+' size='+"'9'"+' value='+"'0,00'"+' style='+"'text-align:right;border:none;'"+' onKeyPress='+"'return(MascaraMoeda(this, event, 10, 2))'"+' onBlur='+"'buscaCaixas(this)'"+' />";'

				cHTML+= 'novaCelula = novaLinha.insertCell(6);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)
				cHTML+= 'novaCelula.innerHTML = "<select size='+"'1'"+' name="+'+"'grid_prio_'"+'+totals+" id="+'+"'grid_prio_'"+'+totals+" style='+"'border:none;'"+'><option value='+"'P'"+'>Peso</option><option selected value='+"'C'"+'>Caixa</option></select>";'

				cHTML+= 'novaCelula = novaLinha.insertCell(7);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)
				cHTML+= 'novaCelula.innerHTML = "<input type='+"'text'"+' name="+'+"'grid_tole_'"+'+totals+" id="+'+"'grid_tole_'"+'+totals+" maxlength='+"'2'"+' size='+"'3'"+' value='+"'0'"+' style='+"'text-align:right;border:none;'"+' onKeyPress='+"'return(MascaraMoeda(this, event, 2, 0))'"+' />";'

				cHTML+= 'novaCelula = novaLinha.insertCell(8);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)
				cHTML+= 'novaCelula.innerHTML = "<input type='+"'text'"+' name="+'+"'grid_prec_'"+'+totals+" id="+'+"'grid_prec_'"+'+totals+" maxlength='+"'6'"+' size='+"'6'"+' readonly='+"'readonly'"+' style='+"'text-align:right;border:none;'"+' />";'

				cHTML+= 'novaCelula = novaLinha.insertCell(9);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)
				cHTML+= 'novaCelula.innerHTML = "<select size='+"'1'"+' name="+'+"'grid_tbon_'"+'+totals+" id="+'+"'grid_tbon_'"+'+totals+"  onBlur='+"'preco_final(this)'"+' style='+"'border:none;'"+'><option selected value='+"' '"+'></option><option value='+"'D'"+'>Desconto</option><option value='+"'A'"+'>Acrescimo</option></select>";'

				cHTML+= 'novaCelula = novaLinha.insertCell(10);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)
				cHTML+= 'novaCelula.innerHTML = "<input type='+"'text'"+' name="+'+"'grid_boni_'"+'+totals+" id="+'+"'grid_boni_'"+'+totals+" maxlength='+"'5'"+' size='+"'5'"+' value=0 style='+"'text-align:right;border:none;'" +' onBlur='+"'preco_final(this)'"+' onKeyPress='+"'return(MascaraMoeda(this, event, 6, 2))'"+'  />";'

				cHTML+= 'novaCelula = novaLinha.insertCell(11);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)
				cHTML+= 'novaCelula.innerHTML = "<input type='+"'text'"+' name="+'+"'grid_prcf_'"+'+totals+" id="+'+"'grid_prcf_'"+'+totals+" maxlength='+"'6'"+' size='+"'6'"+' readonly='+"'readonly'"+' value=0 readonly='+"'readonly'"+' style='+"'text-align:right;border:none;'"+' />";'

				cHTML+= 'novaCelula = novaLinha.insertCell(12);'+chr(13)
				cHTML+= 'novaCelula.align = "left";'+chr(13)
				cHTML+= 'novaCelula.innerHTML = "<input type='+"'text'"+' name="+'+"'grid_obse_'"+'+totals+" id="+'+"'grid_obse_'"+'+totals+" maxlength='+"'60'"+' size='+"'60'"+' style='+"'border:none'"+' />";'

				cHTML+= '}'

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

				cHTML+= "function ChamaPost()"
				cHTML+= "{"      
				cHTML+= "var fail = false; " 
				cHTML+= "var i = 1; " 
				cHTML+= "if (totals == 0)"
				cHTML+= "{ "
				cHTML+= "   alert('Pedido nao possui itens inseridos!'); "
				cHTML+= "   return; "
				cHTML+= "} "  
				cHTML+= "for (i == 1; i <= totals; i++)"  
				cHTML+= "{"  
				cHTML+= "  if (document.getElementById('grid_prod_'+i)) 
				cHTML+= "   {
				cHTML+= "    if (document.getElementById('grid_prod_'+i).value == '')"
				cHTML+= "      {     "   
				cHTML+= "         fail = true;" 
				cHTML+= "         break;"   
				cHTML+= "      }" 
				cHTML+= "    }"	

				cHTML+= "  if (document.getElementById('grid_caix_'+i)) 
				cHTML+= "   {
				cHTML+= "    if (document.getElementById('grid_caix_'+i).value == 0)"
				cHTML+= "      {     "   
				cHTML+= "         fail = true;" 
				cHTML+= "         break;"   
				cHTML+= "      }"
				cHTML+= "    }"	

				cHTML+= "  if (document.getElementById('grid_peso_'+i)) 
				cHTML+= "   {
				cHTML+= "    if (document.getElementById('grid_peso_'+i).value == '0,00')"
				cHTML+= "      {     "   
				cHTML+= "         fail = true;" 
				cHTML+= "         break;"   
				cHTML+= "      }" 
				cHTML+= "    }"	
				cHTML+= "}"	 
				cHTML+= "if (fail)"
				cHTML+="    {"
				cHTML+= "   alert('Falha na alteracao do pedido! Verifique quantidade de caixas/peças ou peso.'); "
				cHTML+= "   return; "
				cHTML+= "   }"    

				cHTML+= "frm_alt_ped.submit()"  
				cHTML+= "}"	    

				cHTML+= "function HiddenProdutos()"
				cHTML+= "{"
				cHTML+= 'document.getElementById("produtos").style.visibility = "hidden";'
				cHTML+= "}"

				//Funções que fazem a busca dos dados de produtos
				//no momento da digitação do codigo deste
				//evento OnBlur do campo de codigo de produto
				//na linha de itens de produtos
				cHTML+= '  function buscaProdDig(prod) {'
				cHTML+= '    var url = "";' 
				cHTML+= '    var i = 1;'  
				cHTML+= '    var CodigoProduto = "";'
				cHTML+= '    var GridProduto = "";'      
				cHTML+= '    var NumLin = 0;  '     
				cHTML+= '    NumLin = eval(prod.id.substr(10, 2));'
				cHTML+= '    if (NumLin < 10)' 
				cHTML+= '     { '                    
				cHTML+= '    lin = prod.id.substr(10, 1);'  
				cHTML+= '     } '
				cHTML+= '    else '
				cHTML+= '     { '
				cHTML+= '    lin = prod.id.substr(10, 2);'       	
				cHTML+= '     } '  
				cHTML+= '	 CodigoProduto = document.getElementById("grid_prod_"+lin).value;' 
				cHTML+= '    CodigoProduto = CodigoProduto.substr(0,6);	
				cHTML+= "    for (i == 1; i <= totals; i++)" 
				cHTML+= "    {        "      
				cHTML+= "     if (document.getElementById('grid_prod_'+i))"
				cHTML+= "	  {    "                           
				cHTML+= "      GridProduto = document.getElementById('grid_prod_'+i).value.substr(0,6);	"
				cHTML+= "      if (CodigoProduto == GridProduto && i != lin)" 
				cHTML+= "      {     "    
				cHTML+= "          alert('Produto repetido! Verifique os itens ja incluidos no pedido!');"   
				cHTML+= "          document.getElementById('grid_prod_'+lin).value = '';"
				cHTML+= "          return false;"   
				cHTML+= "       } "   
				cHTML+= "	  }     "
				cHTML+= "    }"                               
				cHTML+= '    url = "'+GetNewPar("SI_URLPORT", 'http://portaldovendedor.frigorificosilva.com.br:91')+'/u_p_gdesc.apl?rdm="+encodeURI(Math.random())+"&produto="+document.getElementById("grid_prod_"+lin).value+"&tabela="+document.getElementById("tabprec").value;'
				cHTML+= '    request.open("GET", url, true);  '
				cHTML+= '    request.onreadystatechange = atualizaProd;'
				cHTML+= '    request.send(null);  '  
				cHTML+= '  }  '

				cHTML+= '  function atualizaProd() '
				cHTML+= '  {   '	
				cHTML+= '    if (request.readyState == 4)'
				cHTML+= '    { '
				cHTML+= '      if (request.status == 200)'
				CHTML+= '      {'  
				cHTML+= '        document.getElementById("grid_desc_"+lin).value = request.responseText.substr(0,30);'   
				cHTML+= '        document.getElementById("grid_prec_"+lin).value = request.responseText.substr(30,16);'  
				cHTML+= '        document.getElementById("grid_prcf_"+lin).value = request.responseText.substr(30,16);' 
				cHTML+= '        document.getElementById("grid_boni_"+lin).value = "";' 
				cHTML+= '        if (request.responseText == "")'
				cHTML+= '        {'                         
				cHTML+= '           alert("Produto invalido!");'
				cHTML+= '        	document.getElementById("grid_prod_"+lin).value = "";'
				cHTML+= '  			document.getElementById("grid_prec_"+lin).value = "";' 
				cHTML+= '  			document.getElementById("grid_prcf_"+lin).value = "";' 
				cHTML+= '           document.getElementById("grid_boni_"+lin).value = "";'
				cHTML+= '           return false;'
				cHTML+= '        }'
				cHTML+= '      } '
				cHTML+= '     else  '
				cHTML+= '        alert("status is 2 " + request.status);  '      
				cHTML+= '    }  '   
				cHTML+= '  }'  

				//Fim do bloco de busca da descrição dos produtos

				cHTML+= '</script>'

				//	cHTML+= "<input type='button' value='Alterar' onclick='ChamaPost()' />"
				cHTML+= '<form name="frm_alt_ped" method="post" action="u_p_altera.apl">'

				cHTML+= '<div style="position:absolute;top:100;left:20">Cliente'
				cHTML+= '<input type="text" name="cab_codi" id="cab_codi" value="'+ZZ4->ZZ4_CODCLI+'" style="position:absolute;top:0;left:100;background:#F5F5F5;border:1px solid" maxlength="6" size="6" onkeydown="return desabilita_capos(event);"  />'
				//cHTML+= '<input type="button" style="position:absolute;top:0;left:170" value="?" onClick="f3a1();" />'
				cHTML+= '</div>'

				cHTML+= '<div style="position:absolute;top:100;left:500">Loja'
				cHTML+= '<input type="text" name="cab_loja" id="cab_loja" value="'+ZZ4->ZZ4_LOJA+'" style="position:absolute;top:0;left:100;background:#F5F5F5;border:1px solid" maxlength="2" size="2" onkeydown="return desabilita_capos(event);" />'
				cHTML+= '</div>'

				cHTML+= '<div style="position:absolute;top:125;left:20">Nome Cliente'
				cHTML+= '<input type="text" name="cab_nome" id="cab_nome" value="'+ZZ4->ZZ4_NOME+'" style="position:absolute;top:0;left:100;background:#F5F5F5;border:1px solid"  maxlength="40" size="100" onkeydown="return desabilita_capos(event);" />'
				cHTML+= '</div>'

				cHTML+= '<div style="position:absolute;top:150;left:20">Cidade'
				cHTML+= '<input type="text" name="cab_cida" id="cab_cida" value="'+ZZ4->ZZ4_MUN+'" style="position:absolute;top:0;left:100;background:#F5F5F5;border:1px solid"  maxlength="25" size="100" onkeydown="return desabilita_capos(event);" />'
				cHTML+= '</div>'

				//cHTML+= '<div style="position:absolute;top:125;left:20">Desconto'
				//cHTML+= '<input type="text" name="cab_desc" id="cab_desc" value="'+Transform(ZZ4->ZZ4_DESC, '@e 999,999,999.99')+'" style="position:absolute;top:0;left:100;text-align:right;border:1px solid" maxlength="10" size="10" onKeyPress="return(MascaraMoeda(this, event, 9, 2))" onBlur="calcula_totais()" />'
				//cHTML+= '<input type="text" name="cab_desc" id="cab_desc" value="'+Transform(ZZ4->ZZ4_DESC, '@e 999,999,999.99')+'" style="position:absolute;top:0;left:100;text-align:right;background:#F5F5F5;border:1px solid" maxlength="10" size="10" onkeydown="return desabilita_capos(event);" />'
				//cHTML+= '</div>'

				cHTML+= '<div style="position:absolute;top:175;left:20">Data'
				cHTML+= '<input type="text" name="cab_data" id="cab_data" value="'+DtoC(ZZ4->ZZ4_DATAC)+'" style="position:absolute;top:0;left:100;background:#F5F5F5;border:1px solid" maxlength="8" size="8" onkeydown="return desabilita_capos(event);" />'
				cHTML+= '</div>'

				cHTML+= '<div style="position:absolute;top:175;left:500">Qt.Prev.Peso'
				cHTML+= '<input type="text" name="cab_peso" id="cab_peso" value="'+Transform(ZZ4->ZZ4_QPPESO, '@e 999,999,999.99')+'" style="position:absolute;top:0;left:100;text-align:right;background:#F5F5F5;border:1px solid" maxlength="14" size="14" onkeydown="return desabilita_capos(event);" />'
				cHTML+= '</div>'

				cHTML+= '<div style="position:absolute;top:200;left:20">Qt.Prev.Caixa'
				cHTML+= '<input type="text" name="cab_caix" id="cab_caix" value="'+Transform(ZZ4->ZZ4_QPCAIX, '@e 999,999,999')+'" style="position:absolute;top:0;left:100;text-align:right;background:#F5F5F5;border:1px solid" maxlength="7" size="14" onkeydown="return desabilita_capos(event);" />'
				cHTML+= '</div>'

				cHTML+= '<div style="position:absolute;top:200;left:500">Total'
				cHTML+= '<input type="text" name="cab_tota" id="cab_tota" value="'+Transform(ZZ4->ZZ4_TOTAL, '@e 999,999,999.99')+'" style="position:absolute;top:0;left:100;text-align:right;background:#F5F5F5;border:1px solid" maxlength="6" size="14" onkeydown="return desabilita_capos(event);" />'
				cHTML+= '</div>'

				cHTML+= '<div style="position:absolute;top:225;left:20">Carregamento'
				cHTML+= '<input type="text" name="cab_carr" id="cab_carr" value="'+DtoC(ZZ4->ZZ4_DATA)+'" style="position:absolute;top:0;left:100;border:1px solid" maxlength="8" size="8" onKeyPress="formatar(this, '+"'##/##/##'"+');" onBlur="validaData(this)" />'
				cHTML+= '</div>'  

				cHTML+= '<div style="position:absolute;top:225;left:500">Marca'
				cHTML+= '<input type="text" name="cab_marc" id="cab_marc" value="'+ZZ4->ZZ4_MARCA+'" style="position:absolute;top:0;left:100;border:1px solid" maxlength="3" size="3" />'
				cHTML+= '</div>'

				cHTML+= '<div style="position:absolute;top:250;left:20">Observacao'
				//cHTML+= '<input type="text" name="cab_obse" id="cab_obse" value="'+ZZ4->ZZ4_OBS+'" style="position:absolute;top:0;left:100;border:1px solid" maxlength="100" size="100">'
				cHTML+= '<textarea name="cab_obse" id="cab_obse" style="position:absolute;top:0;left:100;border:1px solid" rows="3" cols="76">'+ZZ4->ZZ4_OBS+'</textarea>'
				cHTML+= '</div>'

				cHTML+= '<div id="grid" style="position:absolute;top:310;left:0px;width:100%;overflow:auto;">'
				cHTML+= '<table border="1px" id="itens" style="border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid">'
				cHTML+= '<tr height="25px">'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Acao</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Item</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF" width="500px"><font face="arial" size="2">Produto</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Descricao</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Qt.Prev.Caixa</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Qt.Prev.Peso</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Priorizar</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Tolerancia</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Preco</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Tp.Bonificacao</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Bonificacao</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Prec.Final</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Observacao</font></td>'
				cHTML+= '</tr>'
				dbSelectArea("ZZ5")
				dbSetorder(1)
				dbSeek(xFilial("ZZ5")+cPed)
				_nI:= 0
				Do While !ZZ5->(EOF()) .AND. xFilial("ZZ5")+cPed == ZZ5->ZZ5_FILIAL+ZZ5->ZZ5_NUM
					_nI++
					cHTML+= '<tr>'
					cHTML+= "<td><input type='button' value='Apagar' onClick='deleta(this);' /></td>"
					cHTML+= "<td><input type='text' name='grid_item_"+cValToChar(_nI)+"' id='grid_item_"+cValToChar(_nI)+"' maxlength='2' size='2' value='"+EncodeUTF8(ZZ5->ZZ5_ITEM)+"' readonly='readonly' style='border:none' /></td>"
					cHTML+= "<td><div class=digiprod><input type='text' name='grid_prod_"+cValToChar(_nI)+"' id='grid_prod_"+cValToChar(_nI)+"' value='"+EncodeUTF8(ZZ5->ZZ5_COD)+"' maxlength='06' size='06' style='border:none' onBlur='buscaProdDig(this)'/></div><a href=# id='grid_busc_"+cValToChar(_nI)+"' name='grid_busc_"+cValToChar(_nI)+"' onClick='f3b1(this)'/>[procurar]</a></td>"
					cHTML+= "<td><input type='text' name='grid_desc_"+cValToChar(_nI)+"' id='grid_desc_"+cValToChar(_nI)+"' value='"+EncodeUTF8(ZZ5->ZZ5_DESC)+"' maxlength='25' readonly='readonly' size='60' style='border:none' /></td>"
					cHTML+= "<td><input type='text' name='grid_caix_"+cValToChar(_nI)+"' id='grid_caix_"+cValToChar(_nI)+"' value='"+EncodeUTF8(Transform(ZZ5->ZZ5_QPCAIX, "@e 999,999,999"))+"' maxlength='4' size='7' value='0' style='text-align:right;border:none;' onKeyPress='return(MascaraMoeda(this, event, 5, 0))' onBlur='buscaPeso(this)' /></td>"
					cHTML+= "<td><input type='text' name='grid_peso_"+cValToChar(_nI)+"' id='grid_peso_"+cValToChar(_nI)+"' value='"+EncodeUTF8(Transform(ZZ5->ZZ5_QPPESO, "@e 999,999,999.99"))+"' maxlength='9' size='9' value='0,00' style='text-align:right;border:none;' onKeyPress='return(MascaraMoeda(this, event, 10, 2))' onBlur='buscaCaixas(this)' /></td>"
					_cAux:= IIF(ZZ5->ZZ5_PRIORI=='P', "<option selected value='P'>Peso</option><option value='C'>Caixa</option><option value='A'>Automatico</option>", IIF(ZZ5->ZZ5_PRIORI=='A', "<option value='P'>Peso</option><option selected value='C'>Caixa</option><option value='A'>Automatico</option>", "<option value='P'>Peso</option><option value='C'>Caixa</option><option selected value='A'>Automatico</option>"))
					cHTML+= "<td><select size='1' name='grid_prio_"+cValToChar(_nI)+"' id='grid_prio_"+cValToChar(_nI)+"' style='border:none;'>"+_cAux+"</select></td>"		
					cHTML+= "<td><input type='text' name='grid_tole_"+cValToChar(_nI)+"' id='grid_tole_"+cValToChar(_nI)+"' value='"+EncodeUTF8(Transform(ZZ5->ZZ5_TOLERA, "@e 99"))+"' maxlength='2' size='3' value='0' style='text-align:right;border:none;' onKeyPress='return(MascaraMoeda(this, event, 2, 0))' /></td>"		
					cHTML+= "<td><input type='text' name='grid_prec_"+cValToChar(_nI)+"' id='grid_prec_"+cValToChar(_nI)+"' value='"+EncodeUTF8(Transform(ZZ5->ZZ5_PRECO, "@e 999,999,999.99"))+"' maxlength='6' size='6' readonly='readonly' style='border:none' /></td>"
					_cAux:= IIF(ZZ5->ZZ5_TPBONI=='D', "<option selected value='D'>Desconto</option><option value='A'>Acrescimo</option>", "<option value='D'>Desconto</option><option selected value='A'>Acrescimo</option>")
					cHTML+= "<td><select size='1' name='grid_tbon_"+cValToChar(_nI)+"' id='grid_tbon_"+cValToChar(_nI)+"' onBlur='preco_final(this)' style='border:none;'>"+_cAux+"</select></td>"
					cHTML+= "<td><input type='text' name='grid_boni_"+cValToChar(_nI)+"' id='grid_boni_"+cValToChar(_nI)+"' value='"+EncodeUTF8(Transform(ZZ5->ZZ5_BONIF, "@e 999,999,999.99"))+"' maxlength='5' size='5' style='text-align:right;border:none;' onBlur='preco_final(this)' onKeyPress='return(MascaraMoeda(this, event, 6, 2))' /></td>"
					cHTML+= "<td><input type='text' name='grid_prcf_"+cValToChar(_nI)+"' id='grid_prcf_"+cValToChar(_nI)+"' value='"+EncodeUTF8(Transform(ZZ5->ZZ5_PRCFIN, "@e 999,999,999.99"))+"' maxlength='6' size='6' readonly='readonly' style='text-align:right;border:none' /></td>"				
					cHTML+= "<td><input type='text' name='grid_obse_"+cValToChar(_nI)+"' id='grid_obse_"+cValToChar(_nI)+"' value='"+EncodeUTF8(ZZ5->ZZ5_OBS)+"' maxlength='60' size='60' style='border:none' /></td>"
					cHTML+= '</tr>'
					ZZ5->(dbSkip())
				EndDo  

				cHTML+= '<tr height="25px">' 
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '<td bgcolor="#FFFFFF"></td>'
				cHTML+= '</tr>'

				cHTML+= '</table>'
				cHTML+= '<br>'
				cHTML+= "<input type='button' id='incluir' value='Adicionar Item' onclick='adiciona()'/>"
				cHTML+= '<br>'
				cHTML+= '<br>'
				cHTML+= '</div>'

				cHTML+= '<input type="hidden" id="pedido" name="pedido" value="'+cPed+'" />'
				cHTML+= '<input type="hidden" id="usuario" name="usuario" value="'+cUser+'" />'
				cHTML+= '<input type="hidden" id="email" name="email" value="'+cMail+'" />' 
				cHTML+= '<input type="hidden" id="tabprec" value="'+cTabela+'" />'

				//cHTML+= '<input type="submit" value="Alterar">'
				//cHTML+= "<input type='button' value='Fechar' onclick='window.close()' />"
				cHTML+= '</form>'

				cHTML+= '<div id="produtos" style="border:1px solid;position:absolute;top:25%;left:25%;width:50%;height:50%;background-color:#FFF;visibility:hidden;overflow:auto;">'
				cHTML+= '<div id="tab_prod">'
				cHTML+= '</div>'
				cHTML+= '<input type="hidden" id="produtos_item" value="" />'
				cHTML+= '<input type="hidden" id="produtos_tabela" value="'+cTabela+'" />'


				cHTML+= '</div>'

				cHTML+= '<div id="clientes" style="border:1px solid;position:absolute;top:25%;left:25%;width:50%;height:50%;background-color:#FFF;visibility:hidden;overflow:auto;">'
				cHTML+= '<div id="tab_cli">'
				cHTML+= '</div>'

				cHTML+= '</div>'

				cHTML+= '</font>'

				cHTML+= '</body>'

				cHTML+= '</html>'
			EndIf
		Else  
			cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
			cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Pedido Selecionado nao foi encontrado, selecione o pedido novamente.</b></font><br><br><input type='button' value='Fechar' onclick='window.close()' />"
		EndIf
	Else 

		cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
		cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Nenhum pedido selecionado.</b></font><br><br><input type='button' value='Fechar' onclick='window.close()' />"

	EndIf

	RESET ENVIRONMENT

Return cHTML
