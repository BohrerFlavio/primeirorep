#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_lprec(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	Local cHTML:= ""
	Local i:= 0
	Local cCli:= ""
	Local cLoja:= ""
	Local cQuery:= ""
	Local cAli:= GetNextAlias()

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	For i := 1 To Len(__aProcParms)  
		If Alltrim(__aProcParms[i, 1]) == 'cliente'
			cCli:= __aProcParms[i, 2]
		EndIf
		If Alltrim(__aProcParms[i, 1]) == 'loja'
			cLoja:= __aProcParms[i, 2]
		EndIf
	Next i

	If !Empty(cCli) .AND. !Empty(cLoja)
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+cCli+cLoja)
		If Found()
			cHTML:= "<html><head><title>Lista de Preços</Title></head>"
			cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"  
			cHTML+= "<link rel='shortcut icon' href='imagens/silva.ico'>"
			cHTML+= "<body>"
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

			cHTML+= "</script>"

			cHTML+= "<br>"
			cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
			cHTML+= "<input type='button' value='Fechar' onclick='window.close()' />"
			cHTML+= "<div id='listaPreco'>"  
			cHTML+= "<center><b>Lista de Precos</center></b><br><br>"
			cHTML+= "<table border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
			cHTML+= '<tr height="25px">'
			cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Produto</font></td>'
			cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Descricao</font></td>'
			cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Preco</font></td>'
			cHTML+= '</tr>'

			cQuery:= " SELECT DA1_CODPRO, B1_DESC, DA1_PRCVEN "
			cQuery+= " FROM "+RetSqlName("DA1")+" DA1, "
			cQuery+= "      "+RetSqlName("SB1")+" SB1"
			cQuery+= " WHERE B1_COD = DA1_CODPRO AND "
			cQuery+= "       DA1_CODTAB = '"+SA1->A1_TABELA+"' AND "
			cQuery+= "       DA1_VISUAL = 'S' AND "
			cQuery+= "       B1_MSBLQL = '2' AND "
			cQuery+= "       B1_TIPO = 'PA' AND "
			cQuery+= "      "+RetSqlCond("DA1")+" AND "
			cQuery+= "      "+RetSqlCond("SB1")
			cQuery+= " ORDER BY B1_DESC, B1_COD"

			TCQuery ChangeQuery(cQuery) New Alias &(cAli)

			Do While !&(cAli)->(EOF())
				cHTML+= "<tr>"
				cHTML+= "<td>"+&(cAli)->(DA1_CODPRO)+"</td>"
				cHTML+= "<td>"+&(cAli)->(B1_DESC)+"</td>"
				cHTML+= "<td>"+Transform(&(cAli)->(DA1_PRCVEN), "@e 999,999,999.99")+"</td>"
				cHTML+= "</tr>"
				&(cAli)->(dbSkip())
			EndDo
			&(cAli)->(dbCloseArea())

			cHTML+= "</table>"
			cHTML+="</div>"
			cHTML+= "</body></html>"
		Else
			cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Nenhum cliente selecionado.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
		EndIf

	Else
		cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Nenhum cliente selecionado.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
	EndIf

	RESET ENVIRONMENT

Return cHTML
