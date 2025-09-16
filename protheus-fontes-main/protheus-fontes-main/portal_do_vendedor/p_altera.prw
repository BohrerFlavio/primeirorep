#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_altera(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	Local cHTML    := ""
	Local i        := 0
	Local cPedido  := ""
	Local cUsuario := ""
	Local aPedido  := {}
	Local cMail    := ""  
	Local _lFail   := .f.

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	For i := 1 To Len(__aPostParms)  

		If Alltrim(__aPostParms[i, 1]) == 'pedido'
			cPedido:= __aPostParms[i, 2]
		ElseIf Alltrim(__aPostParms[i, 1]) == 'email'
			cMail:= __aPostParms[i, 2]
		ElseIf Alltrim(__aPostParms[i, 1]) == 'usuario'
			cUsuario:= __aPostParms[i, 2]
		Else
			AADD(aPedido, {__aPostParms[i, 1], __aPostParms[i, 2]})
		EndIf
	Next i

	cHTML:= "<html>"
	cHTML+= "<body>"
	cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"

	If !Empty(cPedido) .AND. !Empty(cUsuario)
		dbSelectArea("ZZ4")
		dbSetOrder(2)
		dbSeek(xFilial("ZZ4")+cPedido)
		If Found()
			/*RecLock("ZZ4", .F.)
			dbDelete()
			MsUnLock()
			dbSelectArea("ZZ5")
			dbSetorder(1)
			dbSeek(xFilial("ZZ5")+cPedido)
			Do While !ZZ5->(EOF()) .AND. xFilial("ZZ5")+cPedido == ZZ5->ZZ5_FILIAL+ZZ5->ZZ5_NUM
			RecLock("ZZ5", .F.)
			dbDelete()
			MsUnLock()
			ZZ5->(dbSkip())
			EndDo*/
			//se o pedido foi excluido, incluo novamente com o mesmo numero
			cHTML+= Incped(aPedido, cPedido, cUsuario, cMail)
		Else
			cHTML+= "<b>Pedido nao encontrado: "+cPedido+".</b>"
		EndIf
	Else
		cHTML:= "<b>Pedido em branco, selecione novamente.</b>"
	EndIf

Return cHTML

Static Function Incped(aPedido, cNum, cVend, cMail)
	Local aCab:= {}
	Local aAux:= {}
	Local aItens:= {}
	Local cHTML:= ""
	Local cCli:= ""
	Local cLoja:= ""
	Local cBlq:= ""
	Local _lFail := .f.
	Local nX
	
	For nX:= 1 To Len(aPedido)
		If "cab_" $ aPedido[nX, 1]
			AADD(aCab, {"", aPedido[nX, 1], aPedido[nX, 2]})
		EndIf

		If "grid_" $ aPedido[nX, 1]
			AADD(aAux, {"", aPedido[nX, 1], aPedido[nX, 2]})
		EndIf

		If Alltrim(aPedido[nX, 1]) == 'cab_codi'
			cCli:= aPedido[nX, 2]
		EndIf

		If Alltrim(aPedido[nX, 1]) == 'cab_loja'
			cLoja:= aPedido[nX, 2]
		EndIf
	Next nX

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+cCli+cLoja)
	If Found()
		u_cLimCred(SA1->A1_COD, cLoja, @cBlq)
		//nComis   := IIF(Empty(Posicione("SA3", 1, xFilial("SA3")+cVend, "A3_COMIS")), SA1->A1_COMIS, SA3->A3_COMIS) 
		nComis   := IIF(Empty(SA1->A1_COMIS),fBuscaCPO("SA3",1,xFilial("SA3")+cVend, "A3_COMIS"), SA1->A1_COMIS) 
		cNomVend := fBuscaCPO("SA3", 1, xFilial("SA3")+cVend, "A3_NOME")
	EndIf

	AADD(aCab, {"ZZ4_FILIAL"	, "", cFilAnt})
	AADD(aCab, {"ZZ4_NUM"		, "", cNum})
	AADD(aCab, {"ZZ4_STATUS"	, "", "P"})
	AADD(aCab, {"ZZ4_TPOPER"	, "", "V"})
	AADD(aCab, {"ZZ4_REPRES"	, "", cVend})
	AADD(aCab, {"ZZ4_LIMCRE"	, "", cBlq})
	AADD(aCab, {"ZZ4_CREVIG"	, "", SA1->A1_LC})
	AADD(aCab, {"ZZ4_COMIS"		, "", nComis})  
	AADD(aCab, {"ZZ4_SIBLQL"   , "", iif(cBlq = 'B','1','2')})

	If Empty(cVend) 

		Return "<b>Vendedor nao informado.</b><input type='button' value='Fechar' onclick='window.close()' />"
	EndIf

	If Len(aCab) > 0 .AND. Len(aAux) > 0

		//faco o ajuste do vetor do cabecalho
		For nX:= 1 To Len(aCab)

			Do Case
				Case aCab[nX, 2] == "cab_codi"
				aCab[nX, 1]:= "ZZ4_CODCLI"
				Case aCab[nX, 2] == "cab_loja"
				aCab[nX, 1]:= "ZZ4_LOJA"
				Case aCab[nX, 2] == "cab_nome"
				aCab[nX, 1]:= "ZZ4_NOME"
				Case aCab[nX, 2] == "cab_cida"
				aCab[nX, 1]:= "ZZ4_MUN"
				Case aCab[nX, 2] == "cab_data"
				aCab[nX, 1]:= "ZZ4_DATAC"
				aCab[nX, 3]:= CtoD(aCab[nX, 3])
				Case aCab[nX, 2] == "cab_peso"
				aCab[nX, 1]:= "ZZ4_QPPESO"
				aCab[nX, 3]:= Val(StrTran(StrTran(aCab[nX, 3], ".", ""), ",", "."))
				Case aCab[nX, 2] == "cab_caix"
				aCab[nX, 1]:= "ZZ4_QPCAIX"
				aCab[nX, 3]:= Val(StrTran(StrTran(aCab[nX, 3], ".", ""), ",", "."))
				Case aCab[nX, 2] == "cab_tota"
				aCab[nX, 1]:= "ZZ4_TOTAL"
				aCab[nX, 3]:= Val(StrTran(StrTran(aCab[nX, 3], ".", ""), ",", "."))
				Case aCab[nX, 2] == "cab_obse"
				aCab[nX, 1]:= "ZZ4_OBS"
				Case aCab[nX, 2] == "cab_carr"
				aCab[nX, 1]:= "ZZ4_DATA"
				aCab[nX, 3]:= CtoD(aCab[nX, 3])
				if empty(aCab[nX, 3])
					_lFail := .t.
					exit
				endif
				Case aCab[nX, 2] == "cab_marc"
				aCab[nX, 1]:= "ZZ4_MARCA" 
				aCab[nX, 3]:= iif(!empty(aCab[nX, 3]),padl(aCab[nX, 3],3,'0'),'')
			EndCase

		Next nX

		For nX:= 1 To Len(aAux)

			Do Case
				Case Left(aAux[nX, 2], 9) == "grid_item"
				AADD(aItens, {"ZZ5_ITEM", aAux[nX, 3]})
				Case Left(aAux[nX, 2], 9) == "grid_prod"
				if empty(aAux[nX, 3])
					_lFail := .t.
					exit
				endif
				AADD(aItens, {"ZZ5_COD", aAux[nX, 3]})
				Case Left(aAux[nX, 2], 9) == "grid_desc"
				if empty(aAux[nX, 3])
					_lFail := .t.
					exit
				endif
				AADD(aItens, {"ZZ5_DESC", aAux[nX, 3]})
				Case Left(aAux[nX, 2], 9) == "grid_caix"
				if empty(aAux[nX, 3])
					_lFail := .t.
					exit
				endif
				AADD(aItens, {"ZZ5_QPCAIX", Val(StrTran(StrTran(aAux[nX, 3], ".", ""), ",", "."))})
				Case Left(aAux[nX, 2], 9) == "grid_peso"
				if empty(aAux[nX, 3])
					_lFail := .t.
					exit
				endif
				AADD(aItens, {"ZZ5_QPPESO", Val(StrTran(StrTran(aAux[nX, 3], ".", ""), ",", "."))})
				Case Left(aAux[nX, 2], 9) == "grid_prio"
				AADD(aItens, {"ZZ5_PRIORI", aAux[nX, 3]})
				Case Left(aAux[nX, 2], 9) == "grid_tole"
				AADD(aItens, {"ZZ5_TOLERA", Val(StrTran(StrTran(aAux[nX, 3], ".", ""), ",", "."))})
				Case Left(aAux[nX, 2], 9) == "grid_prec"
				if empty(aAux[nX, 3])
					_lFail := .t.
					exit
				endif
				AADD(aItens, {"ZZ5_PRECO", Val(StrTran(StrTran(aAux[nX, 3], ".", ""), ",", "."))})
				Case Left(aAux[nX, 2], 9) == "grid_tbon"
				AADD(aItens, {"ZZ5_TPBONI", aAux[nX, 3]})
				Case Left(aAux[nX, 2], 9) == "grid_boni"
				AADD(aItens, {"ZZ5_BONIF", Val(StrTran(StrTran(aAux[nX, 3], ".", ""), ",", "."))})   
				Case Left(aAux[nX, 2], 9) == "grid_prcf"
				AADD(aItens, {"ZZ5_PRCFIN", Val(StrTran(StrTran(aAux[nX, 3], ".", ""), ",", "."))})		
				Case Left(aAux[nX, 2], 9) == "grid_obse"
				AADD(aItens, {"ZZ5_OBS", aAux[nX, 3]})
			EndCase

			If Mod(nX, 12) == 0 .AND. nX < Len(aAux) //quebra por item, vindo do portal 12 campos
				AADD(aItens, {"ZZ5_FILIAL"	, cFilAnt})
				AADD(aItens, {"ZZ5_NUM"		, cNum})
				AADD(aItens, {"ZZ5_STATUS"	, ""})
				AADD(aItens, {"ZZ5_RESERV"	, "N"})
			EndIf
		Next nX
		AADD(aItens, {"ZZ5_FILIAL"	, cFilAnt})
		AADD(aItens, {"ZZ5_NUM"		, cNum})
		AADD(aItens, {"ZZ5_STATUS"	, ""})
		AADD(aItens, {"ZZ5_RESERV"	, "N"})

		if !_lFail
			//gravacao do pre pedido - cabecalho
			dbSelectArea("ZZ4")
			dbSetOrder(2)
			dbSeek(xFilial("ZZ4")+cNum)
			If Found()
				RecLock("ZZ4", .f.)
			Else
				RecLock("ZZ4", .T.)
			EndIf

			For nX:= 1 To Len(aCab)
				&("ZZ4->"+aCab[nX, 1]):= aCab[nX, 3]
			Next nX
			MsUnLock()
			//fim da gravacao do pre pedido - cabecalho

			//apago todos os itens depois incluo novamente
			dbSelectArea("ZZ5")
			dbSetorder(1)
			dbSeek(xFilial("ZZ5")+cNum)
			Do While !ZZ5->(EOF()) .AND. xFilial("ZZ5")+cNum == ZZ5->ZZ5_FILIAL+ZZ5->ZZ5_NUM
				RecLock("ZZ5", .F.)
				dbDelete()
				MsUnLock()
				ZZ5->(dbSkip())
			EndDo

			//gravacao do pre pedido - itens
			dbSelectArea("ZZ5")
			RecLock("ZZ5", .T.)
			For nX:= 1 To Len(aItens)

				&("ZZ5->"+aItens[nX, 1]):= aItens[nX, 2]
				If Mod(nX, 16) == 0 .AND. nX < Len(aItens) //12 mais os quatro campos que adiciono manualmente
					MsUnLock()
					//novo item
					RecLock("ZZ5", .T.)
				EndIf

			Next nX
			MsUnLock() 
			//fim da gravacao do pre pedido - itens

			//Bloco para eliminar itens repetidos
			ZZ5->(DbSetOrder(2))
			if ZZ5->(DbSeek(cFilAnt+cNum))
				while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = cFilAnt .and. ZZ5->ZZ5_NUM = cNum

					_cCodigo := alltrim(ZZ5->ZZ5_COD)

					ZZ5->(DbSkip())

					if _cCodigo = alltrim(ZZ5->ZZ5_COD) .and. ZZ5->ZZ5_NUM = cNum .and. ZZ5->(!eof())

						reclock('ZZ5',.f.)
						DbDelete()
						msunlock()
					endif

				enddo
			endif
			//Fim do bloco para eliminar itens repetidos 

			//Bloco para ajustar numeração dos itens do pre-pedido
			ZZ5->(DbSetOrder(1))
			if ZZ5->(DbSeek(cFilAnt+cNum)) 
				_nItem := 0
				while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = cFilAnt .and. ZZ5->ZZ5_NUM = cNum

					_nItem++
					reclock('ZZ5',.f.)
					ZZ5->ZZ5_ITEM  := strzero(_nItem,3)
					ZZ5->ZZ5_SLDPOR := ZZ5->ZZ5_QPPESO
					msunlock() 

					ZZ5->(DbSkip())

				enddo
			endif		
			//Fim do bloco para ajustar numeração dos itens do pre-pedido


			cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
			cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Pedido "+cNum+" alterado com sucesso! </b></font><br><br><input type='button' value='Fechar' onclick='window.close()' />"
			If GetMV("PR_ENVMAIL")
				u_EnvMail("alterado", u_PedMail(cNum), cNum, cMail)
			EndIf
		else
			cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Falha ao alterar pedido. Verifique o preenchimento de campos necessários.</b>
			cHTML+= "</font><br><br><input type='button' value='Fechar' onclick='history.go(-1)'/>"
			cHTML+= "</body></html>"

		endif
	else
		cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Falha ao alterar pedido. Verifique o preenchimento de campos necessários.</b>
		cHTML+= "</font><br><br><input type='button' value='Fechar' onclick='history.go(-1)'/>"
		cHTML+= "</body></html>"	
	EndIf

	RESET ENVIRONMENT

Return cHTML
