#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_browcli(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	Local cHTML := ""
	Local cQuery:= ""
	Local cAli:= GetNextAlias()
	Local cVend:= ""
	Local cOrdem:= ""  
	Local cCodCli := ""
	Local cNomCli := ""
	Local dDataIni
	Local dDataFin
	Local i:= 0

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	cHTML+= "<table id='tabb' border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
	cHTML+= "<tr height='25px'>"
	cHTML+= "<td bgcolor='#FFFFFF'><font size='3'><b>"+EncodeUTF8("")+"</font></b></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font size='3'><b>Codigo</font></b></td>"
	cHTML+= "<td bgcolor='#FFFFFF' ><font size='3'><b>Loja</font></b></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font size='3'><b>Razao Social</font></b></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font size='3'><b>Fantasia</font></b></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font size='3'><b>Endereco</font></b></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font size='3'><b>Municipio</font></b></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font size='3'><b>Estado</font></b></td>"
	/*cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Telefone</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Email</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Lim Credito</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Venc Lim Cred</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Condicao Pagto</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Forma de Cobranca</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Ultima Compra</font></td>"
	cHTML+= "<td bgcolor='#D3D3D3'><font face='arial' size='2'>Credito Vigente</font></td>"*/
	cHTML+= "</tr>"

	If Len(__aProcParms) = 0
		cHTML:= '<p>Nenhum parametro informado na linha de URL.'
	Else
		For i := 1 To Len(__aProcParms)
			If Alltrim(__aProcParms[i, 1]) == 'vendedor'
				cVend:= alltrim(__aProcParms[i, 2])
			EndIf

			If Alltrim(__aProcParms[i, 1]) == 'ordem'
				cOrdem:= __aProcParms[i, 2]
			EndIf   

			If Alltrim(__aProcParms[i, 1]) == 'codcli'
				cCodCli:= __aProcParms[i, 2]
			EndIf 

			If Alltrim(__aProcParms[i, 1]) == 'nomcli'
				cNomCli:= UPPER(__aProcParms[i, 2])
			EndIf

		Next i
	Endif

	If !Empty(cVend)
		cQuery:= " SELECT * "
		cQuery+= " FROM "+RetSqlName("SA1")+" SA1 "
		cQuery+= " WHERE A1_VEND = '"+cVend+"' AND "
		cQuery+= "       A1_POBLQL = '2' AND "   

		if !empty(cCodCli)
			cQuery+= " A1_COD = '"+ cCodCli +"' AND "   
		endif  

		if !empty(cNomCli)
			cQuery+= " A1_NOME LIKE '"+ cNomCli +"%' AND "   
		endif

		cQuery+= " "+RetSqlCond("SA1")
		If !Empty(cOrdem)
			cQuery+= " ORDER BY "+cOrdem
		EndIf

		TCQuery ChangeQuery(cQuery) New Alias &(cAli)

		i:= 0 

		Do While !&(cAli)->(EOF()) // .and. i < 500
			i++
			cHTML+= "<tr>"
			cHTML+= "<td><input type='radio' name='browse_clientes' value='"+strzero(i,4)+"' onclick='getCliente(this.value)' /></td>"
			cHTML+= "<td><input type='text' id='cliente_codi_"+strzero(i,4)+"' size='6' readonly='readonly' style='border:none' value='"+EncodeUTF8(Alltrim(&(cAli)->(A1_COD)))+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_loja_"+strzero(i,4)+"' size='2' readonly='readonly' style='border:none' value='"+EncodeUTF8(Alltrim(&(cAli)->(A1_LOJA)))+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_nome_"+strzero(i,4)+"' size='40' readonly='readonly' style='border:none' value='"+EncodeUTF8(Alltrim(&(cAli)->(A1_NOME)))+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_nred_"+strzero(i,4)+"' size='20' readonly='readonly' style='border:none' value='"+EncodeUTF8(Alltrim(&(cAli)->(A1_NREDUZ)))+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_ende_"+strzero(i,4)+"' size='40' readonly='readonly' style='border:none' value='"+EncodeUTF8(Alltrim(&(cAli)->(A1_END)))+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_muni_"+strzero(i,4)+"' size='25' readonly='readonly' style='border:none' value='"+EncodeUTF8(Alltrim(&(cAli)->(A1_MUN)))+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_esta_"+strzero(i,4)+"' size='2' readonly='readonly' style='border:none' value='"+EncodeUTF8(Alltrim(&(cAli)->(A1_EST)))+"' /></td>"
			/*cHTML+= "<td><input type='text' id='cliente_fone_"+cValToChar(i)+"' size='15' readonly='readonly' style='border:none' value='"+EncodeUTF8(&(cAli)->(A1_DDD))+" "+&(cAli)->(A1_TEL)+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_mail_"+cValToChar(i)+"' size='80' readonly='readonly' style='border:none' value='"+EncodeUTF8(&(cAli)->(A1_EMAIL))+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_limi_"+cValToChar(i)+"' size='14' readonly='readonly' style='border:none' value='"+Transform(&(cAli)->(A1_LC), "@e 999,999,999.99")+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_dtli_"+cValToChar(i)+"' size='14' readonly='readonly' style='border:none' value='"+EncodeUTF8(DtoC(StoD(&(cAli)->(A1_VENCLC))))+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_cond_"+cValToChar(i)+"' size='14' readonly='readonly' style='border:none' value='"+EncodeUTF8(&(cAli)->(A1_COND))+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_form_"+cValToChar(i)+"' size='14' readonly='readonly' style='border:none' value='"+EncodeUTF8(&(cAli)->(A1_FORMREC))+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_ultc_"+cValToChar(i)+"' size='14' readonly='readonly' style='border:none' value='"+EncodeUTF8(DtoC(StoD(&(cAli)->(A1_ULTCOM))))+"' /></td>"
			cHTML+= "<td><input type='text' id='cliente_ultc_"+cValToChar(i)+"' size='14' readonly='readonly' style='border:none' value='"+Transform(u_nLimCred(&(cAli)->(A1_COD), &(cAli)->(A1_LOJA)), "@e 999,999,999.99")+"' /></td>"*/
			cHTML+= "</tr>"
			&(cAli)->(dbSkip())
		EndDo  

		i := 0 

		&(cAli)->(dbCloseArea())

		cHTML+= "</table>"
	Else
		cHTML:= '<p>Vendedor nao informado.'
	EndIf

	RESET ENVIRONMENT

Return(cHTML)
