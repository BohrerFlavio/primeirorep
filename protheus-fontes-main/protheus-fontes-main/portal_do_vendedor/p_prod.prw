#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_prod(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	Local cHTML := ""
	Local i:= 0
	Local cQuery:= ""
	Local cAli:= GetNextAlias()
	Local cLista:= ""


	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	cHTML := "<input type='button' value='Fechar' onclick='HiddenProdutos()' />"
	cHTML+= "<table id='tab' border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
	cHTML+= "<tr height='25px'>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Acao</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Codigo</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Descricao</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Preco</font></td>"
	cHTML+= "</tr>"

	If Len(__aProcParms) = 0
		cHTML:= '<p>Nenhum parametro informado na linha de URL.'
	Else
		For i := 1 To Len(__aProcParms)  
			If Alltrim(__aProcParms[i, 1]) == 'lista'
				cLista:= __aProcParms[i, 2]
			EndIf
		Next i
	Endif


	If !Empty(cLista)
		//cQuery:= " SELECT B1_COD, B1_DESCRED, DA1_PRCVEN "
		cQuery:= " SELECT B1_COD, B1_DESC, DA1_PRCVEN "
		cQuery+= " FROM "+RetSqlName("SB1")+" SB1, "
		cQuery+= "      "+RetSqlName("DA1")+" DA1 "
		cQuery+= " WHERE B1_MSBLQL = '2' AND "
		cQuery+= "       DA1_CODTAB = '"+cLista+"' AND "
		cQuery+= "       DA1_CODPRO = B1_COD AND "
		cQuery+= "       B1_TIPO IN('PA','PR') AND "
		cQuery+= "       DA1_VISUAL = 'S' AND "
		cQuery+= "       "+RetSqlCond("SB1")+" AND "
		cQuery+= "       "+RetSqlCond("DA1")
		//cQuery+= " ORDER BY B1_DESCRED, B1_COD"
		cQuery+= " ORDER BY B1_DESC, B1_COD"

		TCQuery ChangeQuery(cQuery) New Alias &(cAli)

		i:= 0
		Do While !&(cAli)->(EOF())
			i++
			cHTML+= "<tr>"
			cHTML+= "<td><input type='button' value='Selecionar' onclick='preenche_itens(this)' /></td>"
			cHTML+= "<td><input type='text' id='produtos_prod_"+cValToChar(i)+"' size='14' readonly='readonly' style='border:none' value='"+&(cAli)->(B1_COD)+"' /></td>"
			//cHTML+= "<td><input type='text' id='produtos_desc_"+cValToChar(i)+"' size='50' readonly='readonly' style='border:none' value='"+&(cAli)->(B1_DESCRED)+"' /></td>"
			cHTML+= "<td><input type='text' id='produtos_desc_"+cValToChar(i)+"' size='50' readonly='readonly' style='border:none' value='"+&(cAli)->(B1_DESC)+"' /></td>"
			cHTML+= "<td><input type='text' id='produtos_prec_"+cValToChar(i)+"' size='6' readonly='readonly' style='border:none' value='"+Transform(&(cAli)->(DA1_PRCVEN), "@e 999,999,999.99")+"' /></td>"
			cHTML+= "</tr>"
			&(cAli)->(dbSkip())
		EndDo

		&(cAli)->(dbCloseArea())
		cHTML+= "</table>"
	Else

		cHTML:= '<p>Lista de precos nao informada.'
	EndIf

	RESET ENVIRONMENT

Return(cHTML)
