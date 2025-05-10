#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF166  º Autor ³ Giuliano Forgiraini  º Data ³ 18/03/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Geração dos pedidos de compra com base nos registros de    º±±
±±º          ³ fechamento de compra de gado                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compra de Gado                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    
User Function GJF166() 
	private aRotina :={}
	Private lInverte := .f.
	Private cMark    := GetMark()
	Private oMark
	aObjects := {}    //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	area := GetArea()
	cPerg := "GJF166"

	If !Pergunte(cPerg,.T.)
		RestArea( area )
		Return
	Endif

	SA2->(DbSetorder(1))

	DbSelectArea('ZAG')
	ZAG->(DbSetOrder(3))

	//cArq  := CriaTrab( Nil, .F. )

	_aArqTrb := {}
	aStru := {}
	aadd(aStru,{"ZAG_OK"     ,"C"	  ,02,0 })
	aadd(aStru,{"ZAG_STAT"   ,"C"   ,10,0  })
	aadd(aStru,{"ZAG_STATUS" ,"C"   ,01,0  })
	aadd(aStru,{"ZAG_NUM"    ,"C"   ,10,0  })
	aadd(aStru,{"ZAG_NUMAM"  ,"C"   ,08,0  })
	aadd(aStru,{"ZAG_LOTE"   ,"C"   ,06,0  })
	aadd(aStru,{"ZAG_FORNEC" ,"C"   ,06,0  })
	aadd(aStru,{"ZAG_LOJA"   ,"C"   ,02,0  })
	aadd(aStru,{"ZAG_NOME"   ,"C"   ,20,0  })
	aadd(aStru,{"ZAG_EMISSA" ,"D"   ,08,0  })
	aadd(aStru,{"ZAG_PRODUT" ,"C"   ,06,0  })
	aadd(aStru,{"ZAG_DESCRI" ,"C"   ,20,0  })
	aadd(aStru,{"ZAG_SLDQ"   ,"N"   ,03,0  })
	aadd(aStru,{"ZAG_SLDP"   ,"N"   ,09,2  })
	aadd(aStru,{"ZAG_QTDG"   ,"N"   ,03,0  })
	aadd(aStru,{"ZAG_PESG"   ,"N"   ,09,2  })
	aadd(aStru,{"ZAG_QUANT"  ,"N"   ,03,0  })
	aadd(aStru,{"ZAG_PESO"   ,"N"   ,09,2  })
	aadd(aStru,{"ZAG_PRECO"  ,"N"   ,06,2  })
	aadd(aStru,{"ZAG_TOTAL"  ,"N"   ,11,2  })

	//dbcreate(cArq,aStru)
	//If Select('TMP')<>0
	//	TMP->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )               //cria temp
	//Index On ZAG_NUMAM+ZAG_LOTE To (cArq)

	If Select('TMP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {"ZAG_NUMAM","ZAG_LOTE"}, @_aArqTrb)

	ZAG->(Msseek(FWxFilial('ZAG') + mv_par01,.t.))

	Do While !ZAG->(Eof()) .and. ZAG->ZAG_NUMAM  = mv_par01
		_cNome := GetAdvFVal('SA2','A2_NOME',FWxfilial('SA2')+ZAG->(ZAG_FORNEC+ZAG_LOJA),1)

		if mv_par03 = 1
			if ZAG->ZAG_STATUS = 'E'
				ZAG->(DbSkip())
				loop
			endif
		endif

		DbSelectArea('TMP')
		Reclock('TMP',.t.)
		TMP->ZAG_NUMAM  := ZAG->ZAG_NUMAM
		TMP->ZAG_LOTE   := ZAG->ZAG_LOTE
		TMP->ZAG_NUM    := ZAG->ZAG_NUM
		TMP->ZAG_STAT   := iif(ZAG->ZAG_STATUS = 'A','Aberto',iif(ZAG->ZAG_STATUS = 'P','Parcial','Encerrado'))
		TMP->ZAG_STATUS := ZAG->ZAG_STATUS
		TMP->ZAG_FORNEC := ZAG->ZAG_FORNEC
		TMP->ZAG_LOJA   := ZAG->ZAG_LOJA 
		TMP->ZAG_NOME   := _cNome
		TMP->ZAG_PRODUT := ZAG->ZAG_PRODUT
		TMP->ZAG_DESCRI := ZAG->ZAG_DESCRI
		TMP->ZAG_SLDQ   := ZAG->ZAG_SLDQ
		TMP->ZAG_SLDP   := ZAG->ZAG_SLDP
		TMP->ZAG_QUANT  := ZAG->ZAG_QUANT
		TMP->ZAG_PESO   := ZAG->ZAG_PESO
		TMP->ZAG_PRECO  := ZAG->ZAG_PRECO
		TMP->ZAG_TOTAL  := ZAG->ZAG_TOTAL
		TMP->ZAG_EMISSA := ZAG->ZAG_EMISSA
		TMP->ZAG_NUMAM  := ZAG->ZAG_NUMAM
		MsUnlock()

		ZAG->(DbSkip())
	Enddo

	TMP->(dbGotop())

	aCampos  := {} 
	AADD(aCampos,{"ZAG_OK"     ,, "OK"       ,"@!" })
	AADD(aCampos,{"ZAG_STATUS" ,,"Status"    ,""   })
	AADD(aCampos,{"ZAG_STAT"   ,,"Status"    ,""   })
	AADD(aCampos,{"ZAG_NUM"    ,,"Número"    ,"@!" })
	AADD(aCampos,{"ZAG_LOTE"   ,,"Lote"      ,"@!" })
	AADD(aCampos,{"ZAG_FORNEC" ,,"Fornec"    ,"@!" })
	AADD(aCampos,{"ZAG_LOJA"   ,,"Loja"      ,"@!" })
	AADD(aCampos,{"ZAG_NOME"   ,,"Nome  "    ,"@!" })
	AADD(aCampos,{"ZAG_EMISSA" ,,"Emissao "  ,"99/99/9999"})
	AADD(aCampos,{"ZAG_PRODUT" ,,"Produto "  ,"@!" })
	AADD(aCampos,{"ZAG_DESCRI" ,,"Descricao" ,"@!" })
	AADD(aCampos,{"ZAG_SLDQ"   ,,"Saldo Cab.","@E 999"}) 
	AADD(aCampos,{"ZAG_SLDP"   ,,"Saldo Peso","@E 999,999.99"})
	AADD(aCampos,{"ZAG_QTDG"   ,,"Qtd. Gerar","@E 999,999"   })
	AADD(aCampos,{"ZAG_PESG"   ,,"Peso Gerar","@E 999,999.99"})
	AADD(aCampos,{"ZAG_QUANT"  ,,"Num. Cab. ","@E 999"   })
	AADD(aCampos,{"ZAG_PESO"   ,,"Peso      ","@E 999,999.99"})
	AADD(aCampos,{"ZAG_PRECO"  ,, "Preco    ","@E 999.99"    })
	AADD(aCampos,{"ZAG_TOTAL"  ,, "Total    ","@E 9,999,999.99" })

	//dbSelectarea('TMP')
	//IndRegua("TMP",cArq,"ZAG_FORNEC+ZAG_LOJA",,,"Selecionando Registros...") //ordena
	//dbGotop()  
	TMP->(DbGotop())

	DEFINE MSDIALOG oDlg TITLE "Selecionar" From 9,0 To 570,1280 PIXEL
	oMark := MsSelect():New("TMP","ZAG_OK","",aCampos,@lInverte,@cMark,{05,1,255,643},,,,,) 
	oMark:bMark := {| | Disp()}

	TButton():New(260, 020, "Gerar Pedido"  , oDlg,{|| u_GJF166P() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(260, 070, "Estornar"      , oDlg,{|| u_GJF166S() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(260, 120, "Excluir"       , oDlg,{|| u_GJF166E() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(260, 390, "Sair"          , oDlg,{|| oDlg:end() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED

Return .T.

Static Function Disp()

	DbSelectArea('TMP')
	RecLock("TMP",.F.)
	If Marked("ZAG_OK")
		TMP->ZAG_OK := cMark
	Else
		TMP->ZAG_OK := ""
	Endif
	msunlock()
	u_gjf166M()
	oMark:oBrowse:Refresh()
Return()


//Tela para acerto dos valores de quantidade
Static Function Valores()

	DEFINE MSDIALOG oDlg1 TITLE 'Apontamento de Valores' from 000,000 To 140,220 OF oMainWnd PIXEL
	@ 009,005 SAY  'Quant. Animais:' Object oSay1
	@ 021,005 SAY  'Peso Animais:  ' Object oSay2
	@ 009,060 GET  _nQuantAnim SIZE 40,10  PICTURE "@E 999"    valid (_nQuantAnim <= TMP->ZAG_SLDQ .and. _nQuantAnim > 0) Object oVal1
	@ 021,060 GET _nPesoAnim   SIZE 40,10 PICTURE  "@E 999,999.99" valid (_nPesoAnim  <= TMP->ZAG_SLDP .and. _nPesoAnim > 0)  Object oVal2

	oVal2:disable()
	oVal1:bLostFocus := {||Ajuste()}

	@ 050,045 BMPBUTTON TYPE 1 ACTION EVAL({||_cOk := cMark,oDlg1:end()})    Object Obtn1  //OK
	@ 050,080 BMPBUTTON TYPE 2 ACTION EVAL({||_cOk := ''   ,oDlg1:end()})    Object Obtn2  //Cancelar

	ACTIVATE MSDIALOG oDlg1   

return .t.

//Função para gerar ajuste proporcional
//entre quantidade e peso
Static Function Ajuste()
	Local k := TMP->(ZAG_SLDP/ZAG_SLDQ)
	_nPesoAnim := _nQuantAnim * k
	oDlg1:refresh()
return

//Exclusão de fechamento de compra
User Function GJF166E()
	Local _lExc      := .t.
	Local _cTMPChave := TMP->(ZAG_NUMAM+ZAG_LOTE)
	if !empty(TMP->ZAG_OK)
		msgbox('Registro de Fechamento de Compra deve estar desmarcado!','DESMARQUE O REGISTRO!','ERRO')
		return
	endif

	ZAG->(DbSetOrder(3))
	if ZAG->(MsSeek(FWxfilial('ZAG')+_cTMPChave))
		while ZAG->(!eof()) .and. ZAG->ZAG_FILIAL = FWxfilial('ZAG') .and. ZAG->(ZAG_NUMAM+ZAG_LOTE) = TMP->(ZAG_NUMAM+ZAG_LOTE)
			if ZAG->ZAG_SLDQ <> ZAG->ZAG_QUANT
				msgbox('Já existe movimentação para este Fechamento de Compra','OPERAÇÃO INVÁLIDA!','STOP')
				_lExc := .f.
				exit
			endif
			ZAG->(DbSkip())
		enddo

		if _lExc
			ZAG->(DbGoTop())
			if ZAG->(MsSeek(FWxfilial('ZAG')+_cTMPChave))
				if  msgbox('Deseja realmente excluir este Fechamento de compra? (S/N)','EXCLUSAO DE REGISTRO','YESNO')

					while ZAG->(!eof()) .and. ZAG->ZAG_FILIAL = FWxfilial('ZAG') .and. _cTMPChave = ZAG->(ZAG_NUMAM+ZAG_LOTE)

						reclock('ZAG',.f.)
						dbdelete()
						msunlock()

						ZAG->(DbSkip())
					enddo

					TMP->(DbGoTop())
					while TMP->(!eof())
						if TMP->(ZAG_NUMAM + ZAG_LOTE) = _cTMPChave
							reclock('TMP',.f.)
							dbdelete()
							msunlock()
						endif
						TMP->(DbSkip())
					enddo

					TMP->(DbGoTop())

					//oMark:oBrowse := getObjBrow()
					//oMark:oBrowse:default()
					oMark:oBrowse:refresh()
				endif
			endif
		endif
	else
		alert('Registro não encontrado')
	endif

return

//Função destinada a marcar o item
User Function gjf166M()

	_nQuantAnim := TMP->(ZAG_SLDQ - ZAG_QTDG)
	_nPesoAnim  := TMP->(ZAG_SLDP - ZAG_PESG)
	_cOk        := TMP->ZAG_OK

	if TMP->ZAG_STATUS = 'E'
		msgbox('Fechamento de Compra encerrado!','OPERAÇÃO NEGADA!','STOP')
		return
	endif

	If Marked("ZAG_OK")
		Valores()
	Else
		_cOk := ""
	Endif

	reclock('TMP',.f.) 
	TMP->ZAG_SLDQ := iif(!empty(_cOk),TMP->ZAG_SLDQ -_nQuantAnim, TMP->(ZAG_SLDQ + ZAG_QTDG)) 
	TMP->ZAG_SLDP := iif(!empty(_cOk),TMP->ZAG_SLDP -_nPesoAnim,  TMP->(ZAG_SLDP + ZAG_PESG))
	TMP->ZAG_QTDG := iif(!empty(_cOk),_nQuantAnim,0) 
	TMP->ZAG_PESG := iif(!empty(_cOk),_nPesoAnim,0) 
	TMP->ZAG_OK   := _cOk
	msunlock()
return

//Função que gera os pedidos de compra
User Function GJF166P()
	//Local i
	_lIncl  := .f.
	_aComis := {} //Vetor para aglutinar comissoes

	//Pra gerar dois pedidos por fornecedor
	//for i := 1 to 2

		_cForn      := ''  
		_cFornC     := ''
		_cContato   := ''
		_dData      := ddatabase

		TMP->(DbGoTop())
		While TMP->(!eof())

			if empty(TMP->ZAG_OK)
				TMP->(DbSkip())
				loop
			endif

			if TMP->ZAG_STATUS = 'E'
				TMP->(DbSkip())
				loop
			endif

			_cFornC := TMP->(ZAG_FORNEC+ZAG_LOJA)

			ZAG->(DbSetOrder(1))
			if ZAG->(MsSeek(FWxfilial('ZAG')+TMP->ZAG_NUM))

				if _cForn <> ZAG->(ZAG_FORNEC+ZAG_LOJA) 

					_cForn  := ZAG->(ZAG_FORNEC+ZAG_LOJA)
					_cNumPC := GetSx8num('SC7','C7_NUM')
					confirmSX8()
					_nItem      := 1     
					_cTP        := GetAdvFVal('SA2','A2_TIPORUR',FWxfilial('SA2')+_cForn,1)
					_cContato   := GetAdvFVal('SA2','A2_CONTATO',FWxfilial('SA2')+_cForn,1)
					_dData      := GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+ZAG->ZAG_NUMAM,1)
					_nTotComiss := 0
					_nTotBase   := 0
				endif

				_cGrupo :=  GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+ZAG->ZAG_PRODUT,1)

				_nValCom := ZAG->ZAG_COMISS / TMP->ZAG_QUANT
				_nValCom := _nValCom * TMP->ZAG_QTDG

				SC7->(DbSetOrder(1))
				reclock('SC7',.t.)
				SC7->C7_FILIAL     :=  FWxFilial('SC7')
				SC7->C7_NUM        :=  _cNumPC
				SC7->C7_FORNECE    :=  ZAG->ZAG_FORNEC
				SC7->C7_LOJA       :=  ZAG->ZAG_LOJA
				SC7->C7_COND       :=  ZAG->ZAG_COND
				SC7->C7_CONTATO    :=  _cContato
				SC7->C7_EMISSAO    :=  _dData
				SC7->C7_PRODUTO    :=  ZAG->ZAG_PRODUT
				SC7->C7_TIPO       :=  1
				SC7->C7_ITEM       :=  STRZERO(_nItem,4)
				SC7->C7_DESCRI     :=  ZAG->ZAG_DESCRI
				SC7->C7_UM         :=  'KG'
				SC7->C7_SEGUM      :=  'CB'
				SC7->C7_QUANT      :=  TMP->ZAG_PESG
				SC7->C7_QTSEGUM    :=  TMP->ZAG_QTDG
				SC7->C7_PRECO      :=  ZAG->ZAG_PRECO
				SC7->C7_TOTAL      :=  TMP->ZAG_PESG * ZAG->ZAG_PRECO
				SC7->C7_DATPRF     :=  _dData
				SC7->C7_DTABATE    :=  _dData
				SC7->C7_TXMOEDA    :=  1
				SC7->C7_MOEDA      :=  1
				SC7->C7_LOCAL      := '01'
				SC7->C7_CONAPRO    := 'L'
				SC7->C7_DTABATE    :=  _dData
				SC7->C7_TPCOM      :=  ZAG->ZAG_TPCOM
				SC7->C7_FILENT     :=  FWxFilial('SC7')
				SC7->C7_COMPR      :=  ZAG->ZAG_COMPR
				SC7->C7_GRUPO      :=  _cGrupo
				SC7->C7_NUMAM      :=  ZAG->ZAG_NUMAM
				SC7->C7_LOTE       :=  ZAG->ZAG_LOTE
				SC7->C7_TES        :=  iif(_cTP = 'J','192','190')
				SC7->C7_TPFRETE    :=  'C'
				SC7->C7_FLUXO      :=  'S'
				SC7->C7_MOEDA      :=  1
				SC7->C7_COMISS     :=  _nValCom
				SC7->C7_TPCOM      :=  ZAG->ZAG_TPCOM
				SC7->C7_NUMFCG     :=  TMP->ZAG_NUM
				SC7->C7_PCNOTA     :=  'NFP'
				msunlock()

				_lIncl := .t.

				//if i = 1
					_nPos := aScan(_aComis,{|aVal|aVal[1] = _cNumPc})
					if _nPos <> 0
						_aComis[_nPos,6] += _nValCom                       //somatorio para o total de comissao do PC
						_aComis[_nPos,7] += TMP->ZAG_PESG * ZAG->ZAG_PRECO //somatorio para o total da base de comissao do PC 
					else   
						aadd(_aComis,{_cNumPc,_dData,ZAG->ZAG_FORNEC,ZAG->ZAG_LOJA,ZAG->ZAG_COMPR,_nValCom,TMP->ZAG_PESG * ZAG->ZAG_PRECO})
					endif
				//endif

				/*if i = 2

					if TMP->ZAG_SLDQ = 0
						_cStat := 'E'
					elseif TMP->ZAG_SLDQ > 0 .and. TMP->ZAG_SLDQ <> TMP->ZAG_QUANT
						_cStat := 'P'
					else
						_cStat := 'A'
					endif

					reclock('ZAG',.f.)
					ZAG->ZAG_SLDQ   -= TMP->ZAG_QTDG
					ZAG->ZAG_SLDP   -= TMP->ZAG_PESG
					ZAG->ZAG_STATUS := _cStat
					msunlock()

					reclock('TMP',.f.)
					TMP->ZAG_OK     := ''
					TMP->ZAG_STAT   := iif(_cStat = 'A','Aberto',iif(_cStat = 'P','Parcial','Encerrado'))
					TMP->ZAG_STATUS := _cStat 
					TMP->ZAG_PESG   := 0.00
					TMP->ZAG_QTDG   := 0
					msunlock()

				endif*/

				_nItem++

			else
				alert('Registro não encontrado!')
			endif

			TMP->(DbSkip())

		enddo
	//next

	if mv_par02 = 2
		MsgRun("Gerando comissões..." ,,{|| GeraCom()})
	endif

	if _lIncl
		msgbox('Operação de inclusão efetivada!','PEDIDOS DE COMPRA DE GADO','INFO')
	else
		msgbox('Não ha operação a ser realizada!','PEDIDOS DE COMPRA DE GADO','STOP')
	endif

	TMP->(DbGoTop())

return

//Função que gera comissão
Static Function GeraCom()
	Local k
	for k := 1 to len(_aComis)

		RecLock('SE3',.T.)
		SE3->E3_FILIAL    := FWxFilial('SE3')
		SE3->E3_VEND      := _aComis[k,5] 
		SE3->E3_NUM       := _aComis[k,1]
		SE3->E3_EMISSAO   := _aComis[k,2]
		SE3->E3_SERIE     := ''
		SE3->E3_CODCLI    := _aComis[k,3]
		SE3->E3_LOJA      := _aComis[k,4]
		SE3->E3_BASE      := _aComis[k,7]
		SE3->E3_PORC      := 0.00
		SE3->E3_COMIS     := _aComis[k,6]
		SE3->E3_PREFIXO   := ''
		SE3->E3_TIPO      := 'CG'   
		SE3->E3_BAIEMI    := 'E'
		SE3->E3_PEDIDO    := ' '
		SE3->E3_ORIGEM    := 'C'  
		SE3->E3_VENCTO    := _aComis[k,2]
		MsUnlock()
	next

return

//Função de estorno
User Function GJF166S()
	Local _lFlagE := .f.
	Local i

	if TMP->ZAG_STATUS = 'A'
		alert('Não existe operação a estornar!')
		return
	endif

	_aNumPC := {}

	ZAG->(DbSetOrder(1))
	ZAG->(MsSeek(FWxfilial('ZAG')+TMP->ZAG_NUM))
	//Verifica se os pedidos setados estão encerrados   
	SC7->(DbGoTop())
	SC7->(DborderNickName('SC7PCNOTA'))
	if SC7->(MsSeek(FWxfilial('SC7')+alltrim(TMP->ZAG_NUM)))
		while SC7->(!eof()) .and. SC7->C7_FILIAL = FWxfilial('SC7') .and. SC7->C7_NUMFCG = alltrim(TMP->ZAG_NUM)
			if SC7->C7_ENCER = 'E' 
				alert(SC7->C7_NUM)
				_lFlagE := .t.
				exit 
			else 
				//apura no vetor os pedidos relativos ao fechamento a ser estornado
				aadd(_aNumPc,SC7->C7_NUM)
			endif
			SC7->(DbSkip())
		enddo
	else
		MSGBOX('Pedidos de Compra relativos ao fechamento de compra não encontrados!','OPERAÇÃO IRREGULAR','STOP')
		return
	endif

	if _lFlagE
		alert('Existem Pedidos de Compra desta fechamento já encerrado!')   
		return
	else 

		//Varre os pedidos do fechamento de compra setado para ver se estes estão encerrados
		for i := 1 to len(_aNumPC)   
			SC7->(DbSetOrder(1))
			SC7->(MsSeek(FWxfilial('SC7')+_aNumPC[i]))
			while SC7->(!eof()) .and. SC7->C7_FILIAL = FWxfilial('SC7') .and. SC7->C7_NUM = _aNumPC[i]
				if SC7->C7_ENCER = 'E'
					_lFlagE := .t.
					exit 
				endif

				SC7->(DbSkip())
			enddo
		next
	endif

	SC7->(DbGotop())
	if !_lFlagE
		//Se os PCs do fechamento de compra setado não estiverem encerrados, entao faz o estorno
		for i := 1 to len(_aNumPC)  
			SC7->(DbGoTop())
			if SC7->(MsSeek(FWxfilial('SC7')+_aNumPC[i]))
				while SC7->(!eof()) .and. SC7->C7_FILIAL = FWxfilial('SC7') .and. SC7->C7_NUM = _aNumPC[i]
					ZAG->(DbGotop())
					if ZAG->(MsSeek(FWxfilial('ZAG')+SC7->C7_NUMFCG))
						while ZAG->(!eof()) .and. ZAG->ZAG_FILIAL = FWxfilial('ZAG') .and. ZAG->ZAG_NUM = SC7->C7_NUMFCG
							Reclock('ZAG',.f.)
							ZAG->ZAG_SLDQ   := ZAG->ZAG_QUANT
							ZAG->ZAG_SLDP   := ZAG->ZAG_PESO
							ZAG->ZAG_STATUS := 'A'
							MsUnlock()

							TMP->(DbGotop())
							while TMP->(!eof())
								if TMP->ZAG_NUM = ZAG->ZAG_NUM
									Reclock('TMP',.f.)
									TMP->ZAG_SLDQ   := ZAG->ZAG_QUANT
									TMP->ZAG_SLDP   := ZAG->ZAG_PESO
									TMP->ZAG_QTDG   := 0
									TMP->ZAG_PESG   := 0.00
									TMP->ZAG_STATUS := 'A'
									TMP->ZAG_STAT   := 'Aberto' 
									TMP->ZAG_OK     := ''
									MsUnlock()
								endif
								TMP->(DbSkip())
							enddo
							ZAG->(DbSkip())
						enddo
					endif
					SC7->(DbSkip())
				enddo

				SC7->(DbGoTop())
				if SC7->(MsSeek(FWxfilial('SC7')+_aNumPC[i]))
					while SC7->(!eof()) .and. SC7->C7_FILIAL = FWxfilial('SC7') .and. SC7->C7_NUM = _aNumPC[i]
						reclock('SC7',.f.)
						DbDelete()
						msunlock()
						SC7->(DbSkip())
					enddo

				endif

				msgbox('Saldos estornados e Pedidos de Compra excluídos!','OPERAÇÃO DE ESTORNO REALIZADA!','INFO')
			else
				alert('pedidos não encontrados')
			endif
		next
		TMP->(Dbgotop())
	else
		alert('Existem pedidos de compra já encerrados!')
	endif

return
