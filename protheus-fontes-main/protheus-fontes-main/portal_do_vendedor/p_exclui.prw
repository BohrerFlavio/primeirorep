#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_exclui(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)
	Local cHTML:= ""
	Local cPedido:= ""
	Local nX:= 0
	Local cMail:= ""

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1", "ZZ4", "ZZ5"

	For nX := 1 To Len(__aProcParms)  
		If Alltrim(__aProcParms[nX, 1]) == 'pedido'
			cPedido:= __aProcParms[nX, 2]
		EndIf
		If Alltrim(__aProcParms[nX, 1]) == 'email'
			cMail:= __aProcParms[nX, 2]
		EndIf
	Next nX

	If !Empty(cPedido)

		dbSelectArea("ZZ4")
		dbSetOrder(2)
		dbSeek(xFilial("ZZ4")+cPedido)
		If Found()
			If ZZ4->ZZ4_STATUS != "P"
				cHTML:= "<b>Nao e permitida a manutencao de pedidos com status diferente de 'P', verifique.</b></p><input type='button' value='Fechar' onclick='window.close()' />"
			Else

				cHTML:= '<html>'
				cHTML+= '<body>'
				cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"
				cHTML+= "<link rel='shortcut icon' href='imagens/silva.ico'>"
				cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>" 

				cHTML+= '<font face="arial" size="2">'
				cHTML+= '<form name="frm_exc" method="post" action="u_p_exped.apl" >'
				cHTML+= '<input type="hidden" name="pedido" value="'+cPedido+'" />'
				cHTML+= '<input type="hidden" name="email" value="'+cMail+'" />'  

				cHTML+= '<div style="position:absolute;top:071;left:0"> 
				cHTML+= "<input type='button' value='Fechar' onclick='window.close()' />&nbsp;&nbsp;"
				cHTML+= '<input type="submit" value="Excluir" /></div>' 

				cHTML+= '<font face="arial" size="2">'
				cHTML+= '<title>PORTAL DO VENDEDOR - Excluir Pre-Pedido de Venda - '+cPedido+'</title>'
				cHTML+= '<div style="position:absolute;top:100;left:20">Cliente'
				cHTML+= '<input type="text" name="cab_codi" id="cab_codi" readonly="readonly" value="'+ZZ4->ZZ4_CODCLI+'" style="position:absolute;top:0;left:100;border:1px solid" maxlength="6" size="6"  />'
				cHTML+= '</div>'
				cHTML+= '<div style="position:absolute;top:100;left:500">Loja'
				cHTML+= '<input type="text" name="cab_loja" id="cab_loja" readonly="readonly" value="'+ZZ4->ZZ4_LOJA+'" style="position:absolute;top:0;left:100;border:1px solid" maxlength="2" size="2" />'
				cHTML+= '</div>'
				cHTML+= '<div style="position:absolute;top:125;left:20">Nome Cliente'
				cHTML+= '<input type="text" name="cab_nome" id="cab_nome" readonly="readonly" value="'+ZZ4->ZZ4_NOME+'" style="position:absolute;top:0;left:100;border:1px solid"  maxlength="40" size="100" />'
				cHTML+= '</div>'
				cHTML+= '<div style="position:absolute;top:150;left:20">Cidade'
				cHTML+= '<input type="text" name="cab_cida" id="cab_cida" readonly="readonly" value="'+ZZ4->ZZ4_MUN+'" style="position:absolute;top:0;left:100;border:1px solid"  maxlength="25" size="100" />'
				cHTML+= '</div>'
				//cHTML+= '<div style="position:absolute;top:125;left:20">Desconto'
				//cHTML+= '<input type="text" name="cab_desc" id="cab_desc" readonly="readonly" value="'+Transform(ZZ4->ZZ4_DESC, '@e 999,999,999.99')+'" style="position:absolute;top:0;left:100;text-align:right;border:1px solid" maxlength="10" size="10" />'
				//cHTML+= '</div>'
				cHTML+= '<div style="position:absolute;top:175;left:20">Data'
				cHTML+= '<input type="text" name="cab_data" id="cab_data" readonly="readonly" value="'+DtoC(ZZ4->ZZ4_DATAC)+'" style="position:absolute;top:0;left:100;border:1px solid" maxlength="8" size="8" />'
				cHTML+= '</div>'
				cHTML+= '<div style="position:absolute;top:175;left:500">Qt.Prev.Peso'
				cHTML+= '<input type="text" name="cab_peso" id="cab_peso" readonly="readonly" value="'+Transform(ZZ4->ZZ4_QPPESO, '@e 999,999,999.99')+'" style="position:absolute;top:0;left:100;text-align:right;border:1px solid" maxlength="14" size="14" />'
				cHTML+= '</div>'
				cHTML+= '<div style="position:absolute;top:200;left:20">Qt.Prev.Caixa'
				cHTML+= '<input type="text" name="cab_caix" id="cab_caix" readonly="readonly" value="'+Transform(ZZ4->ZZ4_QPCAIX, '@e 999,999,999')+'" style="position:absolute;top:0;left:100;text-align:right;border:1px solid" maxlength="14" size="11" />'
				cHTML+= '</div>'
				cHTML+= '<div style="position:absolute;top:200;left:500">Total'
				cHTML+= '<input type="text" name="cab_tota" id="cab_tota" readonly="readonly" value="'+Transform(ZZ4->ZZ4_TOTAL, '@e 999,999,999.99')+'" style="position:absolute;top:0;left:100;text-align:right;border:1px solid" maxlength="14" size="14" />'
				cHTML+= '</div>'			
				cHTML+= '<div style="position:absolute;top:225;left:20">Carregamento'
				cHTML+= '<input type="text" name="cab_data" id="cab_carr" readonly="readonly" value="'+DtoC(ZZ4->ZZ4_DATA)+'" style="position:absolute;top:0;left:100;border:1px solid" maxlength="8" size="8" />'
				cHTML+= '</div>'  			
				cHTML+= '<div style="position:absolute;top:225;left:500">Marca'
				cHTML+= '<input type="text" name="cab_marc" id="cab_marc" readonly="readonly" value="'+ZZ4->ZZ4_MARCA+'" style="position:absolute;top:0;left:100;border:1px solid" maxlength="3" size="3" />'
				cHTML+= '</div>'

				cHTML+= '<div style="position:absolute;top:250;left:20">Observacao'
				//cHTML+= '<input type="text" name="cab_obse" id="cab_obse" readonly="readonly" value="'+ZZ4->ZZ4_OBS+'" style="position:absolute;top:0;left:100;border:1px solid" maxlength="100" size="100">'
				cHTML+= '<textarea name="cab_obse" id="cab_obse" style="position:absolute;top:0;left:100;border:1px solid" rows="3" cols="76" readonly="readonly">'+ZZ4->ZZ4_OBS+'</textarea>'
				cHTML+= '</div>'
				//	cHTML+= '<div id="grid" style="position:absolute;top:260;left:0px;width:100%;">'
				cHTML+= '<div id="grid" style="position:absolute;top:310;left:0px;width:100%;overflow:auto;">'
				cHTML+= '<table border="1px" id="itens" style="border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid">'
				cHTML+= '<tr height="25px">'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Item</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Produto</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Descricao</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Qt.Prev.Caixa</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Qt.Prev.Peso</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Priorizar</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Toleranci</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Preco</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Tp.Bonificacao</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Bonificacao</font></td>'
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Preco Final</font></td>'			
				cHTML+= '<td bgcolor="#FFFFFF"><font face="arial" size="2">Observacao</font></td>'
				cHTML+= '</tr>'
				dbSelectArea("ZZ5")
				dbSetorder(1)
				dbSeek(xFilial("ZZ5")+cPedido)
				Do While !ZZ5->(EOF()) .AND. xFilial("ZZ5")+cPedido == ZZ5->ZZ5_FILIAL+ZZ5->ZZ5_NUM
					cHTML+= '<tr>'
					cHTML+= '<td><input type="text" readonly="readonly" style="border:none" value="'+EncodeUTF8(ZZ5->ZZ5_ITEM)+'" size="2" /></td>'
					cHTML+= '<td><input type="text" readonly="readonly" style="border:none" value="'+EncodeUTF8(ZZ5->ZZ5_COD)+'" size="14" /></td>'
					cHTML+= '<td><input type="text" readonly="readonly" style="border:none" value="'+EncodeUTF8(ZZ5->ZZ5_DESC)+'" size="60" /></td>'
					cHTML+= '<td><input type="text" readonly="readonly" style="border:none" value="'+EncodeUTF8(Transform(ZZ5->ZZ5_QPCAIX, "@e 999,999"))+'" size="7" /></td>'
					cHTML+= '<td><input type="text" readonly="readonly" style="border:none" value="'+EncodeUTF8(Transform(ZZ5->ZZ5_QPPESO, "@e 99,999.99"))+'" size="9" /></td>'
					_cAux:= IIF(ZZ5->ZZ5_PRIORI=='P', 'Peso', IIF(ZZ5->ZZ5_PRIORI=='A', 'Automatico', 'Caixa'))
					cHTML+= '<td><input type="text" readonly="readonly" style="border:none" value="'+EncodeUTF8(_cAux)+'" size="10" /></td>'
					cHTML+= '<td><input type="text" readonly="readonly" style="border:none" value="'+EncodeUTF8(Transform(ZZ5->ZZ5_TOLERA, "@e 99"))+'" size="3" /></td>'
					cHTML+= '<td><input type="text" readonly="readonly" style="border:none" value="'+EncodeUTF8(Transform(ZZ5->ZZ5_PRECO, "@e 999.99"))+'" size="6" /></td>'
					_cAux:= IIF(ZZ5->ZZ5_TPBONI=='D', 'Desconto', 'Acrescimo')
					cHTML+= '<td><input type="text" readonly="readonly" style="border:none" value="'+EncodeUTF8(_cAux)+'" size="9" /></td>'
					cHTML+= '<td><input type="text" readonly="readonly" style="border:none" value="'+EncodeUTF8(Transform(ZZ5->ZZ5_BONIF, "@e 99.99"))+'" size="5" /></td>'
					cHTML+= '<td><input type="text" readonly="readonly" style="border:none" value="'+EncodeUTF8(Transform(ZZ5->ZZ5_PRCFIN, "@e 999.99"))+'" size="6" /></td>'
					cHTML+= '<td><input type="text" readonly="readonly" style="border:none" value="'+EncodeUTF8(ZZ5->ZZ5_OBS)+'" size="60" /></td>'
					cHTML+= '</tr>'
					ZZ5->(dbSkip())
				EndDo
				cHTML+= '</table>'
				cHTML+= '</div>'
				cHTML+= '</font>'
				cHTML+= '</form>'
				cHTML+= '</body>'
				cHTML+= '</html>'
			EndIf
		EndIf
	Else
		cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Nenhum pedido selecionado, porfavor selecione um pedido.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
	EndIf

	RESET ENVIRONMENT

Return cHTML
