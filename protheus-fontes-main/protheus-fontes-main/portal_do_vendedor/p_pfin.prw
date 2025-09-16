#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_pfin(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
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
			cHTML:= "<html>"  
			cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"
			cHTML+= "<link rel='shortcut icon' href='imagens/silva.ico'>"
			cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
			cHTML+= "<input type='button' value='Fechar' onclick='window.close()' /><br>"
			cHTML+= "<center><b>Posicao Financeira<b><br>" 
			cHTML+= u_cLimCred(cCli, cLoja)+"</center><br><br>"
			cHTML+= "<table border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
			cHTML+= '<tr height="25px">'
			cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Nota Fiscal</font></td>'
			cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Dt Emissao</font></td>'
			cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Vencimento</font></td>'
			cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Valor</font></td>'
			cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Saldo</font></td>'
			cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Dias Atraso</font></td>'
			cHTML+= '</tr>'

			cQuery:= " SELECT E1_NUM, E1_EMISSAO, E1_VENCTO, E1_VALOR, E1_SALDO "
			cQuery+= " FROM "+RetSqlName("SE1")+" SE1 "
			cQuery+= " WHERE E1_CLIENTE = '"+cCli+"' AND "
			cQuery+= "       E1_LOJA = '"+cLoja+"' AND "
			cQuery+= "       E1_TIPO IN ('NF', 'RA', 'CH', 'CHP') AND "
			cQuery+= "       E1_SALDO > 0 AND "
			cQuery+= "      "+RetSqlCond("SE1")
			cQuery+= " ORDER BY E1_VENCTO"
			TCQuery ChangeQuery(cQuery) New Alias &(cAli)          

			_cData := ''

			Do While !&(cAli)->(EOF())
				_cData:= iif( (date()-StoD(&(cAli)->(E1_VENCTO)))> 0,cValToChar(date()-StoD(&(cAli)->(E1_VENCTO))),'Em dia')  
				cHTML+= "<tr>"
				cHTML+= "<td>"+&(cAli)->(E1_NUM)+"</td>"
				cHTML+= "<td>"+DtoC(StoD(&(cAli)->(E1_EMISSAO)))+"</td>"
				cHTML+= "<td>"+DtoC(StoD(&(cAli)->(E1_VENCTO)))+"</td>"
				cHTML+= "<td>"+Transform(&(cAli)->(E1_VALOR), "@e 999,999,999.99")+"</td>"
				cHTML+= "<td>"+Transform(&(cAli)->(E1_SALDO), "@e 999,999,999.99")+"</td>"
				cHTML+= "<td>"+_cData+"</td>"
				cHTML+= "</tr>"              

				&(cAli)->(dbSkip())
			EndDo
			&(cAli)->(dbCloseArea())
			cHTML+= "</table>"
			cHTML+= "</html>"
		Else
			cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Nenhum cliente selecionado.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
		EndIf
	Else
		cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Nunhum cliente selecionado.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
	EndIf

	RESET ENVIRONMENT

Return cHTML
