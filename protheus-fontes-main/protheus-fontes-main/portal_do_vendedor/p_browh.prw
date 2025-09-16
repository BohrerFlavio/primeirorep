#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_browH(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	Local cHTML := ""
	Local i:= 0
	Local cQuery:= ""
	Local cAli:= GetNextAlias()
	Local cVend:= ""
	Local cCli:= ""
	Local cLoja:= ""
	Local dIni
	Local dFin

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	cHTML+= "<table id='tabb' border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
	cHTML+= "<tr height='25px'>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Codigo</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Descricao</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Unidades</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Peso</font></td>"
	cHTML+= "</tr>"

	If Len(__aProcParms) = 0
		cHTML:= '<p>Nenhum parametro informado na linha de URL.'
	Else
		For i := 1 To Len(__aProcParms)  
			If Alltrim(__aProcParms[i, 1]) == 'dataini'
				dIni:= CtoD(__aProcParms[i, 2])
			EndIf
			If Alltrim(__aProcParms[i, 1]) == 'datafin'
				dFin:=  CtoD(__aProcParms[i, 2])
			EndIf
			If Alltrim(__aProcParms[i, 1]) == 'vendedor'
				cVend:= __aProcParms[i, 2]
			EndIf
			If Alltrim(__aProcParms[i, 1]) == 'cliente'
				cCli:= __aProcParms[i, 2]
			EndIf
			If Alltrim(__aProcParms[i, 1]) == 'loja'
				cLoja:= __aProcParms[i, 2]
			EndIf  

		Next i
	Endif

	If !Empty(dIni) .AND. !Empty(dFin)
		cQuery:= " SELECT ZZ5_COD, SUM(ZZ5_QRPESO) AS PESO, SUM(ZZ5_QRCAIX) AS CAIXA"
		cQuery+= " FROM "+RetSqlName("ZZ4")+" ZZ4, "+ RetSqlName("ZZ5")+" ZZ5 "
		cQuery+= " WHERE ZZ4_REPRES = '"+cVend+"' AND "
		cQuery+= " ZZ4_DATA BETWEEN '"+DtoS(dIni)+"' AND '"+DtoS(dFin)+"' AND "
		cQuery+= " ZZ4_CODCLI = '"+cCli+"' AND "
		cQuery+= " ZZ4_LOJA = '"+cLoja+"' AND "
		cQuery+= " ZZ4_NUM = ZZ5_NUM AND "
		cQuery+= " ZZ4_STATUS = 'F' AND "
		cQuery+= " ZZ4_TPOPER = 'V' AND "
		cQuery+= " ZZ4_FILIAL = '" + xfilial('ZZ4') + "' AND "
		cQuery+= " ZZ5_FILIAL = '" + xfilial('ZZ5') + "' AND "
		cQuery+= " ZZ5.D_E_L_E_T_ <> '*' AND "
		cQuery+= " ZZ4.D_E_L_E_T_ <> '*' "	
		//	cQuery+= " "+RetSqlCond("ZZ4") 
		cQuery+= " GROUP BY ZZ5_COD"
		cQuery+= " ORDER BY SUM(ZZ5_QRPESO) DESC"

		TCQuery ChangeQuery(cQuery) New Alias &(cAli)

		i:= 0
		Do While !&(cAli)->(EOF())
			i++   
			dbSelectArea("ZZ4")
			dbSelectArea("ZZ5")
			dbSelectArea("SB1")	

			_cDesc := fBuscaCPO('SB1',1,xfilial('SB1')+ alltrim(&(cAli)->(ZZ5_COD)),'B1_DESC')

			cHTML+= "<tr>"
			cHTML+= "<td><input type='text' id='browser_nume_"+cValToChar(i)+"' size='6' readonly='readonly' style='border:none' value='" + alltrim(&(cAli)->(ZZ5_COD))+ "' /></td>"
			cHTML+= "<td><input type='text' id='browser_nume_"+cValToChar(i)+"' size='40' readonly='readonly' style='border:none' value='" + _cDesc +"' /></td>"
			cHTML+= "<td><input type='text' id='browser_nume_"+cValToChar(i)+"' size='10' readonly='readonly' style='border:none' value='"+transform(&(cAli)->(CAIXA),'@E 999,999')+"' /></td>"
			cHTML+= "<td><input type='text' id='browser_nume_"+cValToChar(i)+"' size='10' readonly='readonly' style='border:none' value='"+transform(&(cAli)->(PESO),'@E 999,999,999.99')+"' /></td>"
			cHTML+= "</tr>"
			&(cAli)->(dbSkip())
		EndDo

		&(cAli)->(dbCloseArea())
		cHTML+= "</table>"
	Else
		cHTML:= '<p>Data de emissão inicial e final invalidas, verifique.</p>'
	EndIf

	RESET ENVIRONMENT

Return(cHTML)
