#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_cli(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	Local cHTML := ""
	Local i:= 0
	Local cQuery:= ""
	Local cAli:= GetNextAlias()
	Local cVend:= ""

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	cHTML:= "<table id='tabc' border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
	cHTML+= "<tr height='25px'>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>"+EncodeUTF8("Ação")+"</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>"+EncodeUTF8("Código")+"</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>"+EncodeUTF8("Loja")+"</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>"+EncodeUTF8("Nome")+"</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>"+EncodeUTF8("Cidade")+"</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>"+EncodeUTF8("Tabela")+"</font></td>"
	cHTML+= "</tr>"

	If Len(__aProcParms) = 0
		cHTML:= '<p>Nenhum parametro informado na linha de URL.'
	Else
		For i := 1 To Len(__aProcParms)  
			If Alltrim(__aProcParms[i, 1]) == 'vendedor'
				cVend:= __aProcParms[i, 2]
			EndIf
		Next i
	Endif

	If !Empty(cVend)
		cQuery:= " SELECT A1_COD, A1_LOJA, A1_NOME, A1_MUN, A1_TABELA "
		cQuery+= " FROM "+RetSqlName("SA1")+" SA1 "
		cQuery+= " WHERE A1_POBLQL = '2' AND "
		cQuery+= "       A1_VEND = '"+cVend+"' AND "
		cQuery+= "       "+RetSqlCond("SA1")
		cQuery+= " ORDER BY A1_NOME, A1_COD, A1_LOJA "

		TCQuery ChangeQuery(cQuery) New Alias &(cAli)

		i:= 0
		Do While !&(cAli)->(EOF())
			i++

			cHTML+= "<tr>"
			cHTML+= "<td><input type='button' value='Selecionar' onclick='preenche_cab(this)' /></td>"
			cHTML+= "<td><input type='text' id='clientes_codi_"+cValToChar(i)+"' size='14' readonly='readonly' style='border:none' value='"+&(cAli)->(A1_COD)+"' /></td>"
			cHTML+= "<td><input type='text' id='clientes_loja_"+cValToChar(i)+"' size='2' readonly='readonly' style='border:none' value='"+&(cAli)->(A1_LOJA)+"' /></td>"
			cHTML+= "<td><input type='text' id='clientes_nome_"+cValToChar(i)+"' size='40' readonly='readonly' style='border:none' value='"+&(cAli)->(A1_NOME)+"' /></td>"
			cHTML+= "<td><input type='text' id='clientes_cida_"+cValToChar(i)+"' size='25' readonly='readonly' style='border:none' value='"+&(cAli)->(A1_MUN)+"' /></td>"
			cHTML+= "<td><input type='text' id='clientes_tabe_"+cValToChar(i)+"' size='3' readonly='readonly' style='border:none' value='"+&(cAli)->(A1_TABELA)+"' /></td>"
			cHTML+= "</tr>"

			&(cAli)->(dbSkip())
		EndDo

		&(cAli)->(dbCloseArea())
		cHTML+= "</table>"
	Else
		cHTML:= '<p>Vendedor nao informado.'
	EndIf

	RESET ENVIRONMENT

Return(cHTML)
