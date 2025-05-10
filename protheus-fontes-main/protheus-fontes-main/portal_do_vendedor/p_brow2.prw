#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_brow2(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	Local cHTML := ""
	Local i:= 0
	Local cQuery:= ""
	Local cAli:= GetNextAlias()
	Local cVend:= ""
	Local cCli:= ""
	Local cLoja:= ""
	Local cRdm:= ""
	Local dIni
	Local dFin

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	cHTML+= "<table id='tabb' border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
	cHTML+= "<tr height='25px'>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>"+EncodeUTF8("")+"</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Numero</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Status</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Cliente</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Loja</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Nome</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Emissao</font></td>"
	//cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Desconto</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Q.Peso</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Q.Caixas</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Valor Total</font></td>"
	cHTML+= "<td bgcolor='#FFFFFF'><font face='arial' size='2'>Observacoes</font></td>"
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
			If Alltrim(__aProcParms[i, 1]) == 'status'
				cStat:= __aProcParms[i, 2]
			EndIf
			If Alltrim(__aProcParms[i, 1]) == 'rdm'
				cRdm:= __aProcParms[i, 2]
			EndIf

		Next i
	Endif

	cHTML+= "<input type='hidden' name=rdm id=rdm value="+cRdm+">"

	If !Empty(dIni) .AND. !Empty(dFin)
		cQuery:= " SELECT ZZ4_NUM, ZZ4_STATUS, ZZ4_CODCLI, ZZ4_LOJA, ZZ4_NOME, ZZ4_DATAC, ZZ4_DESC, ZZ4_QPPESO, ZZ4_QPCAIX,ZZ4_TOTAL, ZZ4_OBS, R_E_C_N_O_ ZZ4RECNO "
		cQuery+= " FROM "+RetSqlName("ZZ4")+" ZZ4 "
		cQuery+= " WHERE ZZ4_REPRES = '"+cVend+"' AND "
		cQuery+= " ZZ4_DATAC BETWEEN '"+DtoS(dIni)+"' AND '"+DtoS(dFin)+"' AND "
		cQuery+= " ZZ4.D_E_L_E_T_ <> '*' AND "
		cQuery+= " ZZ4_ORIGEM = 'P'" 
		//	cQuery+= +RetSqlCond("ZZ4") 
		if cStat <> 'T'
			cQuery+= " AND ZZ4_STATUS = '" + cStat + "'"
		endif
		cQuery+= " ORDER BY ZZ4_NUM"

		TCQuery ChangeQuery(cQuery) New Alias &(cAli)

		i:= 0
		Do While !&(cAli)->(EOF())
			i++
			dbSelectArea("ZZ4")
			dbGoTo(&(cAli)->(ZZ4RECNO))
			_cStatus := &(cAli)->(ZZ4_STATUS)
			_cStat := ''
			do case
				case  _cStatus = 'P'  
				_cStat := 'Em Portal'
				case  _cStatus = 'B'  
				_cStat := 'Bloqueado'
				case  _cStatus = 'L' 
				_cStat := 'Liberado'
				case  _cStatus = 'S' 
				_cStat := 'Em Espera'
				case  _cStatus = 'C'
				_cStat := 'Carregando...'
				case  _cStatus = 'E'
				_cStat := 'Encerrado'
				case  _cStatus = 'F' 
				_cStat := 'Faturado'
			endcase

			cHTML+= "<tr>"
			cHTML+= "<td><input type='radio' name='browse' value='"+cValToChar(i)+"' onclick='getPedido(this.value)' /></td>"
			cHTML+= "<td><input type='text' id='browser_nume_"+cValToChar(i)+"' size='6' readonly='readonly' style='border:none' value='"+&(cAli)->(ZZ4_NUM)+"' /></td>"
			cHTML+= "<td><input type='text' id='browser_stat_"+cValToChar(i)+"' size='10' readonly='readonly' style='border:none' value='"+_cStat +"' /></td>"
			cHTML+= "<td><input type='text' id='browser_cli_"+cValToChar(i)+"' size='6' readonly='readonly' style='border:none' value='"+&(cAli)->(ZZ4_CODCLI)+"' /></td>"
			cHTML+= "<td><input type='text' id='browser_loja_"+cValToChar(i)+"' size='2' readonly='readonly' style='border:none' value='"+&(cAli)->(ZZ4_LOJA)+"' /></td>"
			cHTML+= "<td><input type='text' id='browser_nome_"+cValToChar(i)+"' size='40' readonly='readonly' style='border:none' value='"+&(cAli)->(ZZ4_NOME)+"' /></td>"
			cHTML+= "<td><input type='text' id='browser_datac_"+cValToChar(i)+"' size='8' readonly='readonly' style='border:none' value='"+DtoC(StoD(&(cAli)->(ZZ4_DATAC)))+"' /></td>"
			//		cHTML+= "<td><input type='text' id='browser_nume_"+cValToChar(i)+"' size='14' readonly='readonly' style='border:none' value='"+Transform(&(cAli)->(ZZ4_DESC), "@e 999,999,999.99")+"' /></td>"
			cHTML+= "<td><input type='text' id='browser_qpeso_"+cValToChar(i)+"' size='10' readonly='readonly' style='border:none' value='"+Transform(&(cAli)->(ZZ4_QPPESO), "@e 999,999,999.99")+"' /></td>"
			cHTML+= "<td><input type='text' id='browser_qcaix_"+cValToChar(i)+"' size='10' readonly='readonly' style='border:none' value='"+Transform(&(cAli)->(ZZ4_QPCAIX), "@e 999,999,999.99")+"' /></td>"
			cHTML+= "<td><input type='text' id='browser_total_"+cValToChar(i)+"' size='10' readonly='readonly' style='border:none' value='"+Transform(&(cAli)->(ZZ4_TOTAL), "@e 999,999,999.99")+"' /></td>"
			cHTML+= "<td><input type='text' id='browser_obs_"+cValToChar(i)+"' size='60' readonly='readonly' style='border:none' value='"+ZZ4->ZZ4_OBS+"' /></td>"
			cHTML+= "</tr>"
			&(cAli)->(dbSkip())
		EndDo

		&(cAli)->(dbCloseArea())
		cHTML+= "</table>"
	Else
		cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Data de emissão inicial e final invalidas.</b></font></td>"
	EndIf

	RESET ENVIRONMENT

Return(cHTML)
