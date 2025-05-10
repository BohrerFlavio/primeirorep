#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_incped(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)
	Local nX       := 0
	Local nCampo   := 1
	Local nComis   := 0
	Local cMarca   := ""
	Local aCab     := {}
	Local aItens   := {}
	Local aAux     := {}
	Local cHTML    := ""
	Local cNum     := ""
	Local cVend    := ""
	Local cNomVend := ""
	Local cBlq     := ""
	Local cCli     := ""
	Local cLoja    := "" 
	Local cDataC   := date()
	Local cMail    := "" 
	Local _lFail   := .f.

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1", "ZZ4", "ZZ5"


	cNum:= GETSX8NUM('ZZ4','ZZ4_NUM')
	Confirmsx8()

	For nX:= 1 To Len(__aPostParms)
		If "cab_" $ __aPostParms[nX, 1]
			AADD(aCab, {"", __aPostParms[nX, 1], __aPostParms[nX, 2]})
		EndIf

		If "grid_" $ __aPostParms[nX, 1]
			AADD(aAux, {"", __aPostParms[nX, 1], __aPostParms[nX, 2]})
		EndIf

		If Alltrim(__aPostParms[nX, 1]) == 'vendedor'
			cVend:= __aPostParms[nX, 2]
		EndIf

		If Alltrim(__aPostParms[nX, 1]) == 'email'
			cMail:= __aPostParms[nX, 2]
		EndIf

		If Alltrim(__aPostParms[nX, 1]) == 'cab_codi'
			cCli:= __aPostParms[nX, 2]
		EndIf

		If Alltrim(__aPostParms[nX, 1]) == 'cab_loja'
			cLoja:= __aPostParms[nX, 2]
		EndIf   

		If Alltrim(__aPostParms[nX, 1]) == 'cab_marc'
			cMarca:= iif(!empty(__aPostParms[nX, 2]),padl(__aPostParms[nX, 2],3,'0'),'')
		endif

	next nX

	cHTML:="<html>" 
	cHTML+="<head>"
	cHTML+="<meta http-equiv='Cache-Control' content='No-Cache'>
	cHTML+="<meta http-equiv='Pragma' content='No-Cache'>"
	cHTML+="<meta http-equiv='Expires' content='0'>"
	cHTML+="</head>" 
	cHTML+= "<body>"
	cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"

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
	AADD(aCab, {"ZZ4_NOMREP"	, "", cNomVend})
	AADD(aCab, {"ZZ4_HORAC"		, "", Left(Time(), 5)})
	AADD(aCab, {"ZZ4_ORIGEM"	, "", "P"})
	AADD(aCab, {"ZZ4_LIMCRE"	, "", cBlq})    
	AADD(aCab, {"ZZ4_SIBLQL"   , "", iif(cBlq = 'B','1','2')})
	AADD(aCab, {"ZZ4_CREVIG"	, "", SA1->A1_LC})
	AADD(aCab, {"ZZ4_COMIS"		, "", nComis})
	AADD(aCab, {"ZZ4_MARCA"		, "", cMarca})

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
				Case aCab[nX, 2] == "cab_carr"
				aCab[nX, 1]:= "ZZ4_DATA"       
				if empty(aCab[nX, 3])
					_lFail := .t.
				endif
				aCab[nX, 3]:= ctod(aCab[nX, 3])
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
				Case aCab[nX, 2] == "cab_data"
				aCab[nX, 1]:= "ZZ4_DATAC"     
				aCab[nX, 3]:= Date()
				Case aCab[nX, 2] == "cab_marc"
				aCab[nX, 1]:= "ZZ4_MARCA"

			EndCase

		Next nX
		_string := ''  
		nNodo := 0
		For nX:= 1 To Len(aAux)
			nNodo++
			Do Case
				Case Left(aAux[nX, 2], 9) == "grid_item"  
				_string += "Item: " + aAux[nX, 3]//Para debug
				AADD(aItens, {"ZZ5_ITEM", aAux[nX, 3]})
				Case Left(aAux[nX, 2], 9) == "grid_prod"
				if empty(aAux[nX, 3])
					_lFail := .t.
					exit
				endif   
				_string += "Prod: " + aAux[nX, 3]//Para debug
				AADD(aItens, {"ZZ5_COD", aAux[nX, 3]})
				Case Left(aAux[nX, 2], 9) == "grid_desc"   
				if empty(aAux[nX, 3])
					_lFail := .t.
					exit
				endif         
				_string += "Desc: " + aAux[nX, 3]//Para debug
				AADD(aItens, {"ZZ5_DESC", aAux[nX, 3]})
				Case Left(aAux[nX, 2], 9) == "grid_caix"
				if empty(aAux[nX, 3])
					_lFail := .t.
					exit
				endif       
				_string += "Caixa: " + aAux[nX, 3]//Para debug
				AADD(aItens, {"ZZ5_QPCAIX", Val(StrTran(StrTran(aAux[nX, 3], ".", ""), ",", "."))})
				Case Left(aAux[nX, 2], 9) == "grid_peso" 
				if empty(aAux[nX, 3])
					_lFail := .t.
					exit
				endif
				_string += "Peso: " + aAux[nX, 3]//Para debug
				AADD(aItens, {"ZZ5_QPPESO", Val(StrTran(StrTran(aAux[nX, 3], ".", ""), ",", "."))})
				Case Left(aAux[nX, 2], 9) == "grid_prio"  
				_string += "Prioridade: " + aAux[nX, 3]//Para debug
				AADD(aItens, {"ZZ5_PRIORI", aAux[nX, 3]})
				Case Left(aAux[nX, 2], 9) == "grid_tole" 
				_string += "Tolerancia: " + aAux[nX, 3]//Para debug
				AADD(aItens, {"ZZ5_TOLERA", Val(StrTran(StrTran(aAux[nX, 3], ".", ""), ",", "."))})
				Case Left(aAux[nX, 2], 9) == "grid_prec"   
				if empty(aAux[nX, 3])
					_lFail := .t.
					exit
				endif   
				_string += "Preco: " + aAux[nX, 3]//Para debug
				AADD(aItens, {"ZZ5_PRECO", Val(StrTran(StrTran(aAux[nX, 3], ".", ""), ",", "."))})
				Case Left(aAux[nX, 2], 9) == "grid_tbon"  
				_string += "Tipo Bonif.:" + aAux[nX, 3]//Para debug
				AADD(aItens, {"ZZ5_TPBONI", aAux[nX, 3]})
				Case Left(aAux[nX, 2], 9) == "grid_boni"  
				_string += "Bonificação: " + aAux[nX, 3]//Para debug
				AADD(aItens, {"ZZ5_BONIF", Val(StrTran(StrTran(aAux[nX, 3], ".", ""), ",", "."))})
				Case Left(aAux[nX, 2], 9) == "grid_prcf" 
				_string += "Preco Final: " + aAux[nX, 3]//Para debug
				AADD(aItens, {"ZZ5_PRCFIN", Val(StrTran(StrTran(aAux[nX, 3], ".", ""), ",", "."))})
				Case Left(aAux[nX, 2], 9) == "grid_obse"  
				_string += "Obs: " + aAux[nX, 3]//Para debug
				AADD(aItens, {"ZZ5_OBS", aAux[nX, 3]})
			EndCase

			If Mod(nX, 12) == 0 .AND. nX < Len(aAux)  //quebra por item, vindo do portal 12 campos   
				_string += "Filial: " + cFilAnt//Para debug
				AADD(aItens, {"ZZ5_FILIAL"	, cFilAnt})
				_string += "Numero: " + cNum//Para debug
				AADD(aItens, {"ZZ5_NUM"		, cNum}) 
				_string += "Status: " + ""//Para debug
				AADD(aItens, {"ZZ5_STATUS"	, ""})  
				_string += "Reserva: " + "N" + "<br>"//Para debug
				AADD(aItens, {"ZZ5_RESERV"	, "N"})
			EndIf
		Next nX
		AADD(aItens, {"ZZ5_FILIAL"	, cFilAnt})
		_string += "Filial: " + cFilAnt//Para debug
		AADD(aItens, {"ZZ5_NUM"		, cNum}) 
		_string += "Numero: " + cNum//Para debug
		AADD(aItens, {"ZZ5_STATUS"	, ""})
		_string += "Status: +" //Para debug
		AADD(aItens, {"ZZ5_RESERV"	, "N"})
		_string +="Reserva: " + "N"//Para debug
		_string += 'fim'+'<br><br><br>'//Para debug
		//gravacao do pre pedido - cabecalho
		if !_lFail
			dbSelectArea("ZZ4")
			RecLock("ZZ4", .T.)

			For nX:= 1 To Len(aCab)
				&("ZZ4->"+aCab[nX, 1]):= aCab[nX, 3]
			Next nX
			MsUnLock()
			//fim da gravacao do pre pedido - cabecalho

			//gravacao do pre pedido - itens
			dbSelectArea("ZZ5")
			RecLock("ZZ5", .T.)   
			For nX:= 1 To Len(aItens)

				&("ZZ5->"+aItens[nX, 1]):= aItens[nX, 2]  
				if aItens[nX, 1] = 'ZZ5_ITEM'
					_String += aItens[nX, 2] + '  '//Para debug  
				endif

				if aItens[nX, 1] = 'ZZ5_COD'
					_String += aItens[nX, 2] //Para debug 
				endif
				If Mod(nX, 16) == 0 .AND. nX < Len(aItens) //12 mais os 4 campos que adiciono manualmente
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
			_lTpP := .f.   
			_lTpD := .f.
			ZZ5->(DbSetOrder(1))
			if ZZ5->(DbSeek(cFilAnt+cNum)) 
				_nItem := 0
				while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = cFilAnt .and. ZZ5->ZZ5_NUM = cNum

					_nItem++
					reclock('ZZ5',.f.)
					ZZ5->ZZ5_ITEM   := strzero(_nItem,3)
					ZZ5->ZZ5_SLDPOR := ZZ5->ZZ5_QPPESO
					msunlock() 

					//Bloco para verrficiar tipo de produção
					DbSelectArea('SB1')
					_grp := fBuscaCPO('SB1',1,xfilial('SB1')+ZZ5->ZZ5_COD,'B1_GRUPO')

					if substr(_grp,1,2) = '56'
						_lTpP := .t.
					else
						_lTpD := .t.
					endif
					//Fim do bloco de verificação da produção

					ZZ5->(DbSkip())

				enddo
			endif		

			ZZ4->(DbSetOrder(2)) 
			if ZZ4->(DbSeek(xfilial('ZZ4')+cNum))
				reclock('ZZ4',.f.)
				ZZ4->ZZ4_TIPOPR := iif(_lTpP .and. _lTpD,'',iif(_lTpP,'P','D'))
				msunlock()
			endif
			//Fim do bloco para ajustar numeração dos itens do pre-pedido

			cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Pedido "+cNum+" incluído com sucesso!</b></font><br><br><input type='button' value='Fechar' onclick='window.close()'/>" 
			cHTML+= "</body></html>" 
			//		cHTML := _string  +  '<br><br>' + str(nNodo)

			If GetMV("PR_ENVMAIL")
				u_EnvMail("incluido", u_PedMail(cNum), cNum, cMail)
			EndIf
		Else    
			cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Falha ao incluir pedido. Verifique o preenchimento de campos necessários.</b>
			cHTML+= "</font><br><br><input type='button' value='Fechar' onclick='history.go(-1)'/>" 
			cHTML+= "</body></html>"
		endif

	Else
		cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Falha ao incluir pedido. Verifique o preenchimento de campos necessários.</b>
		cHTML+= "</font><br><br><input type='button' value='Fechar' onclick='history.go(-1)'/>" 
		cHTML+= "</body></html>"
	EndIf

	RESET ENVIRONMENT

Return cHTML
