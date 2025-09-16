#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF217  º Autor ³ Giuliano Forgiarini  º Data ³ 30/04/15    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Aglutinação das Ordens de Produção m Lotes de Produção paraº±±
±±º          ³ a industria de porcionados                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP porcionados                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function GJF217()
	Local _aArqTrb    := {}
	private aRotina   :={}
	Private lInverte  := .f.
	Private cMark     := GetMark()
	Private oMark
	Private aBrowse1  := {}
	Private aBrowse2  := {}
	//Private aBrowse2  := {}
	Private aBrowse3  := {}
	Private aBrowse4  := {}
	//Private _cGrpMoi  := GetMV('SI_GRPMOI')
	Private cPerg := "GJF217"
	Private _nPrevUni := 0
	//Private cArq  := CriaTrab( Nil, .F. )

	aObjects := {}    //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	area := GetArea()

	If !Pergunte(cPerg,.T.)
		RestArea( area )
		Return
	Endif

	if ((  ( empty(mv_par01) .and. empty(mv_par02) ) .or. ( empty(mv_par05)  .and. empty(mv_par06) ) ))  .and. empty(mv_par03)
		alert('Parametros iniciais inconsistentes!')
		Return
	endif

	_dDtProd := mv_par03

	if _dDtProd < ddatabase
		alert('Data de produção dos lotes inferior a data base do sistema!')
		return
	endif

	GeraTMP()

	aCampos  := {}
	AADD(aCampos,{"ZAR_OK"     ,,"OK"           ,"@!" })
	AADD(aCampos,{"ZAR_NUM"    ,,"Num. OP     " ,"@!" })
	AADD(aCampos,{"ZAR_DATA"	,,"Dt. Geracao " ,"99/99/9999" })
	AADD(aCampos,{"ZAR_COD"    ,,"Codigo Prod." ,"@!" })
	AADD(aCampos,{"ZAR_DESC"   ,,"Descricao   " ,"@!" })
	AADD(aCampos,{"ZAR_PREPED" ,,"Pre-pedido  " ,"@!" })
	AADD(aCampos,{"ZAR_ITEMPP" ,,"Item PP"      ,"@!" })
	AADD(aCampos,{"ZAR_DTPREP" ,,"Data Pre-Ped.","99/99/9999" })
	AADD(aCampos,{"ZAR_CODCLI" ,,"Cod. Cliente" ,"@!" })
	AADD(aCampos,{"ZAR_LOJA"   ,,"Loja        " ,"@!" })
	AADD(aCampos,{"ZAR_DESCLI" ,,"Nome Cliente" ,"@!" })
	AADD(aCampos,{"ZAR_LAYETQ"	,,"Layout Etq. " ,"@!" })
	AADD(aCampos,{"ZAR_PRCCLI" ,,"Preco Cli.  " ,"@E 999.99"})
	AADD(aCampos,{"ZAR_DTABAT"	,,"Dt. Abate   " ,"99/99/9999" })
	AADD(aCampos,{"ZAR_QPPESO" ,,"Qtd.Pr.Peso " ,"@E 999,999.99"})
	AADD(aCampos,{"ZAR_QPCAIX" ,,"Qtd.Pr.Caixa" ,"@E 999,999" })
	AADD(aCampos,{"ZAR_QPUNI"  ,,"Qtd.Pr.Unid." ,"@E 999,999"})
	AADD(aCampos,{"ZAR_QTDMP"  ,,"Qtd.Pr. MP  " ,"@E 999,999.99"})
	AADD(aCampos,{"ZAR_QTDPI"  ,,"Qtd.Pr. PP  " ,"@E 999,999.99"})

	//Cabeçalho e colunsa do browse dos lotes
	aHeader1 := {'','Numero  ','Produto','Descricao','Layout Etq.','Preço','Dt.Abate','Peso Prev.','Peso Real','Caixa Prev.','Caixa Real','Uni Prev.', 'Uni. Real','Preço'}
	aLargCol1 := {10,40,30,100,60,60,60,60,60,60,60,60,60}

	//Cabeçalhos e colunas do browse das OPs
	aHeader2 := {'','Numero  ','Num.Lote','Produto','Descricao','Dt.Geracao','Peso Prev.','Peso Real','Caixa Prev.','Caixa Real','Uni Prev.', 'Uni. Real','Preço'}
	aLargCol2 := {10,40,30,30,100,60,60,60,60,60,60,60,60}

	//Cabeçalho e colunas do browse da receita para moida
	aHeader3 := {'Num.Lote  ','Item','% ','Produto','Descricao','Peso Prev.','Peso Real','Pert.Receita?'}
	aLargCol3 := {40,10,10,60,100,60,60,60}

	//Cabeçalho e colunas do browse das bateladas
	aHeader4 := {'Status','Batelada ','Cod. MP','Produto','Peso Prev.','Consumo','Pert.Receita?'}
	aLargCol4 := {10,40,40,100,60,60,20}

	DEFINE MSDIALOG oDlg TITLE "Geração e Manutenção de Lotes de Produção" From 9,0 To 570,1280 PIXEL

	oMark := MsSelect():New("TMP","ZAR_OK","",aCampos,@lInverte,@cMark,{05,1,70,643},,,,,)
	oMark:bMark := {| | Disp()}

	oBrowse1 := TCBrowse():New(80,1,640,100,,aHeader1,aLargCol1,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	AtuBr1()

	oBrowse2 := TCBrowse():New(190,1,640,40,,aHeader2,aLargCol2,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	AtuBr2('')

	oBtn1  := TButton():New(240, 005, "Marcar/Desmarcar", oDlg,{|| Selecionar()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn2  := TButton():New(260, 005, "Gerar Lote"      , oDlg,{|| GeraLote()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn3  := TButton():New(240, 215, "Incluir OP Lote" , oDlg,{|| IncOP()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	//oBtn5 := TButton():New(255, 355, "Hab./Des.Refile ", oDlg,{|| Refile()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn4  := TButton():New(260, 075, "Refaz Bateladas" , oDlg,{|| RefBat()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn5  := TButton():New(240, 145, "Excluir Lote"    , oDlg,{|| ExcLote()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn6  := TButton():New(260, 145, "Encerrar Lote"   , oDlg,{|| Encerra()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	//oBtn7  := TButton():New(240, 215, "Empenhos"        , oDlg,{|| Empenho()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	//oBtn3  := TButton():New(240, 075, "Incluir OP Lote" , oDlg,{|| IncOP()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn7  := TButton():New(240, 075, "Bateladas"       , oDlg,{|| Batel()  } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn8  := TButton():New(260, 215, "Param. Produção ", oDlg,{|| ParProd()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn9  := TButton():New(260, 285, "Receita Moida   ", oDlg,{|| Receita()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn10 := TButton():New(260, 355, "Legenda"         , oDlg,{|| Legenda()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn11 := TButton():New(260, 565, "Sair"            , oDlg,{|| oDlg:end()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn12 := TButton():New(240, 285, "Exporta p/ Excel", oDlg,{|| GeraXLS()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED

	If Select('TMP')<>0
		TMP->(dbCloseArea())
	Endif

	//fErase(cArq+GetDbExtension())
	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb)

Return .T.

Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("ZAR_OK")
		TMP->ZAR_OK := cMark
	Else
		TMP->ZAR_OK := ""
	Endif
	msunlock()

	oMark:oBrowse:Refresh()
Return()

Static Function Selecionar()
	TMP->(dbgotop())

	while TMP->(!eof())
		reclock('TMP',.f.)
		TMP->ZAR_OK := iif(empty(TMP->ZAR_OK),cMark,"")
		msunlock()

		TMP->(dbskip())
	enddo

	TMP->(dbgotop())

	oMark:oBrowse:Refresh()
return .t.

//Função para gerar lotes de produção e bateladas de consumo de MP
Static Function GeraLote()

	//Local _nLote      := 0
	Local _aBatel     := {}
	//Local _aLotes     := {}
	//Local _aLotesXOps := {}
	Local _cBatel 		:= ''
	Local i

	//Monta o vetor de bateladas
	ZAX->(DbsetOrder(2))
	if ZAX->(MsSeek(FWxfilial('ZAX') + dtos(mv_par03),.t.))
		while ZAX->(!eof()) .and. ZAX->ZAX_FILIAL = FWxfilial('ZAX') .and. ZAX->ZAX_DTPROD = mv_par03

			aadd(_aBatel,{alltrim(ZAX->ZAX_CODMP),ZAX->ZAX_QTDMP,ZAX->ZAX_NUM,ZAX->ZAX_REC})

			ZAX->(DbSkip())
		enddo
	endif

	TMP->(DbGoTop())

	While TMP->(!eof())

		_cCod := TMP->ZAR_COD

		While TMP->(!eof()) .and. _cCod = TMP->ZAR_COD

			_cPrc := TMP->ZAR_PRC

			While TMP->(!eof()) .and. _cCod = TMP->ZAR_COD .and. TMP->ZAR_PRC  = _cPrc

				_cLayEtq := TMP->ZAR_LAYETQ
				_lGerlote := .t.

				While TMP->(!eof()) .and. _cCod = TMP->ZAR_COD .and. TMP->ZAR_PRC  = _cPrc  .and. TMP->ZAR_LAYETQ  = _cLayEtq

					_dDtAbat := TMP->ZAR_DTABAT

					if _lGerlote
						_cNum := GetSx8num('ZAU','ZAU_NUM')
						ConfirmSx8()
						_lGerlote := .f.
					endif

					_nQpPeso := 0.00
					_nQpUni  := 0.00
					_nQpCaix := 0.00
					_nQtdMP  := 0.00
					_nQtdPI  := 0.00

					While TMP->(!eof()) .and. _cCod = TMP->ZAR_COD .and. TMP->ZAR_PRC  = _cPrc .and. TMP->ZAR_LAYETQ = _cLayEtq  .and. TMP->ZAR_DTABAT = _dDtAbat

						if empty(TMP->ZAR_OK)
							TMP->(DbSkip())
							loop
						endif

						ZAR->(DbSetOrder(1))
						if ZAR->(MsSeek(FWxfilial('ZAR')+TMP->ZAR_NUM))

							reclock('ZAR',.f.)
							ZAR->ZAR_LOTE := _cNum
							msunlock()

							_lGerlote := .t.
						endif

						_nPrcCli := TMP->ZAR_PRCCLI
						_cCod    := TMP->ZAR_COD
						_cCodPI  := TMP->ZAR_CODPI
						_cCodMP  := TMP->ZAR_CODMP
						_cLayEtq := TMP->ZAR_LAYETQ
						_dDtAbat := TMP->ZAR_DTABAT
						_dDtGer  := TMP->ZAR_DATA
						_nQpPeso += TMP->ZAR_QPPESO
						_nQpUni  += TMP->ZAR_QPUNI
						_nQpCaix += TMP->ZAR_QPCAIX
						_nQtdMP  += TMP->ZAR_QTDMP
						_nQtdPI  += TMP->ZAR_QTDPI

						TMP->(DbSkip())
					enddo

					DbSelectArea('SB1')
					SB1->(DbSetOrder(1))
					SB1->(MsSeek(FWxfilial('SB1')+_cCod))

					//TARA DA BANDEJA
					_nTP     := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+SB1->B1_CTARAP,1,0.0,.T.)
					//QUANTIDADE DE BANDEIJAS NA CAIXA
					_nQtdCx  := SB1->B1_QTBCAIX
					//TARA PRIMARIA DA CAIXA					
					_nTPCx   := _nQtdCx * GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+SB1->B1_CTARAP,1,0.0,.T.)				
					//TARA SECUNDÁRIA DA CAIXA
					_nTSCx   := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+SB1->B1_CTARASE,1,0.0,.T.)
					//TARA TOTAL DA CAIXA
					_nTTCx   := _nTPCx + _nTSCx
					//PESO LIQUIDO FIXO
					_nPeFixL := SB1->B1_PESFIX
					//PESO BRUTO FIXO
					_nPeFixB := _nPeFixL + _nTTCx

					if _lGerlote
						reclock('ZAU',.t.)
						ZAU->ZAU_FILIAL  := FWxfilial('ZAU')
						ZAU->ZAU_STATUS  := 'A'
						ZAU->ZAU_STATW   := 'A'
						ZAU->ZAU_STATT   := 'A'
						ZAU->ZAU_STATF   := 'A'
						ZAU->ZAU_NUM     := _cNum
						ZAU->ZAU_QPPESO  := _nQpPeso
						ZAU->ZAU_QPCAIX  := _nQpCaix
						ZAU->ZAU_QPUNI   := _nQpUni
						ZAU->ZAU_QTDMP   := _nQtdMP
						ZAU->ZAU_CODPI   := _cCodPI
						ZAU->ZAU_CODMP   := _cCodMP
						ZAU->ZAU_QTDPI   := _nQtdPI
						ZAU->ZAU_DTPROD  := _dDtProd
						ZAU->ZAU_COD     := _cCod
						ZAU->ZAU_PRCCLI  := _nPrcCli
						ZAU->ZAU_IMLOTE  := strtran(dtoc(_dDtProd),'/','')+substr(_cNum,5,6)
						ZAU->ZAU_IMPROD  := SB1->B1_DESCRED
						ZAU->ZAU_DESC    := AllTrim(SB1->B1_DESC)
						ZAU->ZAU_IMTARA  := AllTrim(Transform(_nTP,'@E 9.999'))
						ZAU->ZAU_TARA    := _nTP
						ZAU->ZAU_IMVAL   := dtoc(_dDtProd + SB1->B1_VALID)
						ZAU->ZAU_IMPRC   := AllTrim(Transform(_nPrcCli,'@E 999.99'))
						ZAU->ZAU_IMPCOM  := SB1->B1_IMPCOM
						ZAU->ZAU_LAYETQ  := AllTrim(_cLayEtq)
						ZAU->ZAU_DTABAT  := _dDtAbat
						ZAU->ZAU_PROREF  := 'N'
						ZAU->ZAU_WFW     := 'N'
						ZAU->ZAU_MOLDE   := SB1->B1_MOLDE
						ZAU->ZAU_GRAMAT  := SB1->B1_GRAMAT
						ZAU->ZAU_CTRLP   := 'L'
						ZAU->ZAU_IMCBAR  := iif(!empty(SB1->B1_EANCLI),substr(SB1->B1_EANCLI,1,12),substr(SB1->B1_CODBAR,1,12))
						ZAU->ZAU_TIPOPR  := 'PA'
						ZAU->ZAU_PESBAN  := SB1->B1_PESBAND
						ZAU->ZAU_PORCI1  := AllTrim(SB1->B1_MENETQ4)
						ZAU->ZAU_PORCI2  := AllTrim(SB1->B1_GORDURA)
						ZAU->ZAU_PORCI3  := AllTrim(SB1->B1_INGREDI)
						ZAU->ZAU_PORCI4  := AllTrim(StrTran(SB1->B1_GRAMATU,'G','g')) //AllTrim(SB1->B1_GRAMATU)
						ZAU->ZAU_PORCI5  := AllTrim(SB1->B1_MENETQ2)
						ZAU->ZAU_RASTRE  := '1733' + StrTran(DToC(_dDtProd),'/','') + '0000'
						ZAU->ZAU_TARAS   := _nTSCx
						ZAU->ZAU_ITARAS  := AllTrim(Transform(_nTSCx,'@E 9.999'))
						ZAU->ZAU_TARAT   := _nTTCx
						ZAU->ZAU_ITARAT  := AllTrim(Transform(_nTTCx,'@E 9.999'))
						ZAU->ZAU_TARAB   := _nTPCx
						ZAU->ZAU_ITARAB  := AllTrim(Transform(_nTPCx,'@E 9.999'))
						//SE O PESO FIXO ESTIVER INFORMADO GRAVA PARA USO NA BIZERBA, SENÃO GRAVA EM BRANCO E A BIZERBA PEGA O PESO DA BALANÇA
						IF(!Empty(SB1->B1_PESFIX) .AND. (SB1->B1_PESFIX > 0))
							ZAU->ZAU_IPEFIX := AllTrim(Transform(_nPeFixL,'@E 999,999,999.99'))
							ZAU->ZAU_PBFIXO := AllTrim(Transform(_nPeFixB,'@E 999,999,999.99'))//'@E 9.999'))
							//ZAU->ZAU_LAYETT := AllTrim('001')
						ELSE
							ZAU->ZAU_IPEFIX := AllTrim('')
							ZAU->ZAU_PBFIXO := AllTrim('')
							//ZAU->ZAU_LAYETT := AllTrim('002')
						ENDIF
						msunlock()

						//_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1') + _cCod,1,"ERRO",.T.)

						//if (_cGrupo $ _cGrpMoi)
						_aReceita := ProcessaRec(_cCod,_nQpPeso)
						if !empty(_aReceita)
							ZAV->(DbSetOrder(1))
							if !ZAV->(MsSeek(FWxfilial('ZAV') + _cNum))
								for i := 1 to len(_aReceita)
									//Bloco para montar o vetor de bateladas por MP
									//para agilizar consumo na saída da camara
									_nPos := aScan(_aBatel,{|aVal|aVal[1] = alltrim(_aReceita[i,1])})

									if _nPos <> 0
										_aBatel[_nPos,2] += _aReceita[i,2]

										// Para atualizar o ZAU recem criado
										_cBatel := _aBatel[_nPos,3]
									else
										_cBatel := GetSx8num('ZAX','ZAX_NUM')
										ConfirmSx8()

										aadd(_aBatel,{alltrim(_aReceita[i,1]),_aReceita[i,2],_cBatel,'S'})
									endif
									//Fim do bloco de montagem do vetor de bateladas

									reclock('ZAV',.t.)
									ZAV->ZAV_FILIAL := FWxfilial('ZAV')
									ZAV->ZAV_NUM    := _cNum
									ZAV->ZAV_COD    := _aReceita[i,1]
									ZAV->ZAV_QPPESO := _aReceita[i,2]
									ZAV->ZAV_ITEM   := strzero(i,3)
									ZAV->ZAV_BATEL  := _cBatel
									msunlock()
								next
							endif
						else
							//Atualização da ZAS com o lote
							AtuZAS(_cNum)

							//Bloco para montar o vetor de bateladas por MP
							//para agilizar consumo na saída da camara
							_nPos := aScan(_aBatel,{|aVal|aVal[1] = alltrim(_cCodMP) })

							if _nPos <> 0

								_aBatel[_nPos,2] += _nQtdMP

								// Para atualizar o ZAU recem criado
								_cBatel := _aBatel[_nPos,3]
							else
								_cBatel := GetSx8num('ZAX','ZAX_NUM')
								ConfirmSx8()
								aadd(_aBatel,{alltrim(_cCodMP),_nQtdMP,_cBatel,'N'})
							endif
							//Fim do bloco de montagem do vetor de bateladas

						endif

						reclock('ZAU',.f.)
						ZAU->ZAU_BATEL  := _cBatel
						msunlock()

					endif

				enddo
			enddo
		enddo
	enddo

	//Bloco para geração de registros das bateladas
	//de consumo de MP na saída da camara para agilização
	//do processo
	for i := 1 to len(_aBatel)

		if len(alltrim(_aBatel[i,1])) = 4
			_cDescMP := GetAdvFVal('ZG0','ZG0_DESC',FWxfilial('ZG0') + _aBatel[i,1],1,"ERRO",.T.)
		else
			_cDescMP := GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1') + _aBatel[i,1],1,"ERRO",.T.)
		endif

		ZAX->(DbSetOrder(1))
		if ZAX->(MsSeek(FWxfilial('ZAX') + _aBatel[i,3]))
			reclock('ZAX',.f.)
			ZAX->ZAX_QTDMP  := _aBatel[i,2]
			msunlock()

		else
			reclock('ZAX',.t.)
			ZAX->ZAX_NUM    := _aBatel[i,3]
			ZAX->ZAX_CODMP  := _aBatel[i,1]
			ZAX->ZAX_QTDMP  := _aBatel[i,2]
			ZAX->ZAX_DESCRI := _cDescMP
			ZAX->ZAX_STATUS := 'A'
			ZAX->ZAX_FILIAL := FWxfilial('ZAX')
			ZAX->ZAX_DTPROD := _dDtProd
			ZAX->ZAX_REC    := _aBatel[i,4]
			msunlock()
		endif

	next
	//Fim do bloco de geração de registros das bateladas

	pergunte(cPerg,.f.)

	GeraTMP()

	AtuBr1()

	oMark:oBrowse:Refresh()

return

//Função responsável pela geração do arquivo de trabalho TMP
Static Function GeraTMP()

	cQuery := " SELECT * FROM " + RetSQLTab('ZAR')
	cQuery += " WHERE " + RetSQLFil('ZAR') + " AND "
	cQuery += " ZAR_LOTE = ''  "

	if !empty(mv_par01)  .and. !empty(mv_par02)
		cQuery += " AND ZAR_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	endif

	cQuery += iif(!empty(mv_par04)," AND ZAR_COD = '" + mv_par04 + "'","")

	if !empty(mv_par05)  .and. !empty(mv_par06)
		cQuery += " AND ZAR_DTPREP BETWEEN '" + dtos(mv_par05) + "' AND '" + dtos(mv_par06) + "'"
	endif

	cQuery += " AND " + RetSQLDel('ZAR')
	cQuery += " ORDER BY ZAR_COD,ZAR_PRCCLI,ZAR_LAYETQ,ZAR_DTABAT"
	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRY")<> 0
		QRY->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "QRY"

	QRY->(DbGotop())

	_aArqTrb    := {}
	//cArq  := CriaTrab( Nil, .F. )

	aStru := ZAR->(dbStruct())

	//aadd(aStru,{"ZAR_OK"  , "C",  02, 0, "@!",'OK'     })
	//aadd(aStru,{"ZAR_PRC" , "C",  10, 0, "@!", 'Preco'})

	aadd(aStru,{"ZAR_OK"  , "C",  02, 0})
	aadd(aStru,{"ZAR_PRC" , "C",  10, 0})

	//dbcreate(cArq,aStru)
	// ProcData 04/2023 - Chamada para criar arquivo de trabalho

	If Select('TMP')<>0
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {"ZAR_COD","ZAR_PRC","ZAR_LAYETQ","ZAR_DTABAT"}, @_aArqTrb)

	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )               //cria temp
	//Index On ZAR_COD+ZAR_PRC+ZAR_LAYETQ+dtoc(ZAR_DTABAT)  To (cArq)

	While QRY->(!eof())

		//_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1') + QRY->ZAR_COD,1,"ERRO",.T.)
		//_cEstProd := GetAdvFVal('SG1','G1_TPPORC',FWxfilial('SG1') + QRY->ZAR_COD,1)

		//Se não for produtos de grupos de moida
		//então verifica se a data de abate está preenchida
		ZG1->(DbSetOrder(4))

		if !(ZG1->(MsSeek(FWxfilial('ZG1') + alltrim(QRY->ZAR_COD)))) //!(_cEstProd = 'RM')//!(_cGrupo $ _cGrpMoi)

			if empty(QRY->ZAR_DTABAT)
				QRY->(DbSkip())
				loop
			endif

			//Se não for do grupo a granel faz a verificação do layout
			// if _cGrupo <> '5613'
			// 	if empty(QRY->ZAR_LAYETQ)
			// 		QRY->(DbSkip())
			// 		loop
			// 	endif
			// endif
		endif

		DbSelectArea('TMP')
		Reclock('TMP',.t.)
		TMP->ZAR_FILIAL  := QRY->ZAR_FILIAL
		TMP->ZAR_NUM     := QRY->ZAR_NUM
		TMP->ZAR_LAYETQ  := QRY->ZAR_LAYETQ
		TMP->ZAR_DATA    := stod(QRY->ZAR_DATA)
		TMP->ZAR_COD	  := QRY->ZAR_COD
		TMP->ZAR_PREPED  := QRY->ZAR_PREPED
		TMP->ZAR_ITEMPP  := QRY->ZAR_ITEMPP
		TMP->ZAR_CODCLI  := QRY->ZAR_CODCLI
		TMP->ZAR_LOJA	  := QRY->ZAR_LOJA
		TMP->ZAR_DESCLI  := QRY->ZAR_DESCLI
		TMP->ZAR_DTPREP  := stod(QRY->ZAR_DTPREP)
		TMP->ZAR_DESC    := QRY->ZAR_DESC
		TMP->ZAR_QPPESO  := QRY->ZAR_QPPESO
		TMP->ZAR_QPCAIX  := QRY->ZAR_QPCAIX
		TMP->ZAR_QPUNI   := QRY->ZAR_QPUNI
		TMP->ZAR_QTDMP   := QRY->ZAR_QTDMP
		TMP->ZAR_QTDPI   := QRY->ZAR_QTDPI
		TMP->ZAR_PRC     := iif(QRY->ZAR_PRCCLI = 0,'0.00',str(QRY->ZAR_PRCCLI,5,2))
		TMP->ZAR_PRCCLI  := QRY->ZAR_PRCCLI
		TMP->ZAR_CODMP   := QRY->ZAR_CODMP
		TMP->ZAR_CODPI   := QRY->ZAR_CODPI
		TMP->ZAR_DTABAT  := stod(QRY->ZAR_DTABAT)
		MsUnlock()

		QRY->(DbSkip())
	enddo

	dbSelectarea('TMP')
	//IndRegua("TMP",cArq,"ZAR_COD+ZAR_PRC+ZAR_LAYETQ+dtoc(ZAR_DTABAT)",,,"Selecionando Registros...") //ordena
	TMP->(dbGotop())

return

//Função de atualização do Browse 1
Static Function AtuBr1()

	// Vetor com elementos do Browse
	aBrowse1 := {}

	ZAU->(DbSetOrder(2))
	if ZAU->(MsSeek(FWxfilial('ZAU')+dtos(mv_par03)))
		while ZAU->(!eof()) .and. ZAU->ZAU_FILIAL = FWxfilial('ZAU') .and. ZAU->ZAU_DTPROD = mv_par03

			//Filtra por produto
			if !empty(mv_par04)
				if ZAU->ZAU_COD <> mv_par04
					ZAU->(DbSkip())
					loop
				endif
			endif

			_nQpPeso := 0
			_nQrPeso := 0
			_nQpCaix	:= 0
			_nQrCaix	:= 0
			_nQpUni  := 0
			_nQrUni  := 0

			_cDescPro := GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1')+ZAU->ZAU_COD,1,"ERRO",.T.)

			if ZAU->ZAU_STATUS = 'E'
				_stt  := 'E'
			elseif ZAU->ZAU_STATUS <> 'E' .and. (ZAU->ZAU_STATF $ 'R/S'  .or. ZAU->ZAU_STATW $ 'R/S' .or. ZAU->ZAU_STATT $ 'R/S')
				_stt  := 'P'
			else
				_stt  := 'A'
			endif

			aadd(aBrowse1,{RetCores(_Stt),;
			ZAU->ZAU_NUM,;
			ZAU->ZAU_COD,;
			alltrim(_cDescPro),;
			alltrim(ZAU->ZAU_LAYETQ),;
			transform(ZAU->ZAU_PRCCLI,'@E 999,999,999.99'),;
			alltrim(dtoc(ZAU->ZAU_DTABAT)),;
			transform(ZAU->ZAU_QPPESO,'@E 999,999.99'),;
			transform(ZAU->ZAU_QRPESO,'@E 999,999.99'),;
			transform(ZAU->ZAU_QPCAIX,'@E 999'),;
			transform(ZAU->ZAU_QRCAIX,'@E 999'),;
			transform(ZAU->ZAU_QPUNI,'@E 999,999'),;
			transform(ZAU->ZAU_QRUNI,'@E 999,999')})

			ZAU->(DbSkip())
		enddo

	endif

	if len(aBrowse1) = 0
		aadd(aBrowse1,{RetCores('A'),'','','','','','','','','','','',''})
	endif

	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],;
	aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],aBrowse1[oBrowse1:nAT,06],;
	aBrowse1[oBrowse1:nAT,07],aBrowse1[oBrowse1:nAT,08],aBrowse1[oBrowse1:nAT,09],;
	aBrowse1[oBrowse1:nAT,10],aBrowse1[oBrowse1:nAT,11],aBrowse1[oBrowse1:nAT,12],;
	aBrowse1[oBrowse1:nAT,13]}}

	oBrowse1:nScrollType := 1
	oBrowse1:bLDblClick   := {|| Atubr2(aBrowse1[oBrowse1:nAt,02]) }

	oBrowse1:DrawSelect()
	oBrowse1:refresh()
	oDlg:refresh()

return

//Função de atualzação do browse 2
//Visualiza as OPs de cada lote
Static Function Atubr2(_Lote)

	aBrowse2 := {}

	ZAR->(DbSetOrder(4))
	if ZAR->(MsSeek(FWxfilial('ZAR')+_Lote))  .and. !empty(_Lote)
		while  ZAR->(!eof()) .and. ZAR->ZAR_FILIAL = FWxfilial('ZAR') .and. ZAR->ZAR_LOTE = _Lote
			aadd(aBrowse2,{RetCores(ZAR->ZAR_STATUS),;
			ZAR->ZAR_NUM,;
			ZAR->ZAR_LOTE,;
			ZAR->ZAR_COD,;
			alltrim(ZAR->ZAR_DESC),;
			dtoc(ZAR->ZAR_DATA),;
			transform(ZAR->ZAR_QPPESO,'@E 999,999.99'),;
			transform(ZAR->ZAR_QRPESO,'@E 999,999.99'),;
			transform(ZAR->ZAR_QPCAIX ,'@E 999'),;
			transform(ZAR->ZAR_QRCAIX,'@E 999'),;
			transform(ZAR->ZAR_QPUNI,'@E 999,999'),;
			transform(ZAR->ZAR_QRUNI,'@E 999,999'),;
			transform(ZAR->ZAR_PRCCLI,'@E 999.99')})
			ZAR->(DbSkip())
		enddo
	else
		aadd(aBrowse2,{RetCores('A'),'','','','','','','','','','','',''})
	endif

	oBrowse2:SetArray(aBrowse2)

	// Monta a linha a ser exibina no Browse
	oBrowse2:bLine := {||{aBrowse2[oBrowse2:nAt,01],aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],;
	aBrowse2[oBrowse2:nAT,04],aBrowse2[oBrowse2:nAT,05],aBrowse2[oBrowse2:nAT,06],;
	aBrowse2[oBrowse2:nAT,07],aBrowse2[oBrowse2:nAT,08],aBrowse2[oBrowse2:nAT,09],;
	aBrowse2[oBrowse2:nAT,10],aBrowse2[oBrowse2:nAT,11],aBrowse2[oBrowse2:nAT,12],;
	aBrowse2[oBrowse2:nAT,13]}}

	oBrowse2:nScrollType := 1

	oBrowse2:DrawSelect()
	oBrowse2:refresh()
	oDlg:refresh()
return

//Atualiza o browse das receitas para carne moída
Static Function Atubr3(_Lote,_nPesoT)

	aBrowse3 := {}

	ZAV->(DbSetOrder(1))
	if ZAV->(MsSeek(FWxfilial('ZAV')+_Lote))
		while  ZAV->(!eof()) .and. ZAV->ZAV_FILIAL = FWxfilial('ZAV') .and. ZAV->ZAV_NUM = _Lote

			_cDesc := GetAdvFVal('SB1','B1_DESC',FWxfilial('ZAV') + ZAV->ZAV_COD,1,"ERRO",.T.)

			aadd(aBrowse3,{ZAV->ZAV_NUM,;
			ZAV->ZAV_ITEM,;
			transform((ZAV->ZAV_QPPESO/_nPesoT)*100,'@E 99.99' ),;
			alltrim(ZAV->ZAV_COD),;
			alltrim(_cDesc),;
			transform(ZAV->ZAV_QPPESO,'@E 9,999.99'),;
			transform(ZAV->ZAV_QRPESO,'@E 9,999.99'),;
			iif(empty(ZAV->ZAV_PREC),'Sim','Nao')})
			ZAV->(DbSkip())
		enddo
	else
		aadd(aBrowse3,{'','','','','','','',''})
	endif

	oBrowse3:SetArray(aBrowse3)

	// Monta a linha a ser exibina no Browse
	oBrowse3:bLine := {||{aBrowse3[oBrowse3:nAt,01],aBrowse3[oBrowse3:nAt,02],aBrowse3[oBrowse3:nAt,03],;
	aBrowse3[oBrowse3:nAT,04],aBrowse3[oBrowse3:nAT,05],aBrowse3[oBrowse3:nAT,06],;
	aBrowse3[oBrowse3:nAT,07],aBrowse3[oBrowse3:nAT,08]}}

	oBrowse3:nScrollType := 1

	oBrowse3:DrawSelect()
	oBrowse3:refresh()
	oDlg3:refresh()
return

//Atualiza o browse das bateladas
Static Function Atubr4()

	aBrowse4 := {}

	ZAX->(DbsetOrder(2))
	if ZAX->(MsSeek(FWxfilial('ZAX') + dtos(mv_par03)))
		while ZAX->(!eof()) .and. ZAX->ZAX_FILIAL = FWxfilial('ZAX') .and. ZAX->ZAX_DTPROD = mv_par03

			aadd(aBrowse4,{ZAX->ZAX_STATUS,;
			ZAX->ZAX_NUM,;
			ZAX->ZAX_CODMP,;
			ZAX->ZAX_DESCRI,;
			transform(ZAX->ZAX_QTDMP,'@E 999,999.99'),;
			transform(ZAX->ZAX_QTDMPC,'@E 9,999.99'),;
			iif(empty(ZAX->ZAX_REC),'Sim','Nao')})

			ZAX->(DbSkip())
		enddo
	else
		aadd(aBrowse4,{'','','','','','',''})
	endif

	oBrowse4:SetArray(aBrowse4)

	// Monta a linha a ser exibina no Browse
	oBrowse4:bLine := {||{aBrowse4[oBrowse4:nAt,01],aBrowse4[oBrowse4:nAt,02],aBrowse4[oBrowse4:nAt,03],;
	aBrowse4[oBrowse4:nAT,04],aBrowse4[oBrowse4:nAT,05],aBrowse4[oBrowse4:nAT,06]}}

	oBrowse4:nScrollType := 1

	oBrowse4:DrawSelect()
	oBrowse4:refresh()
	oDlg4:refresh()
return

//Inclusão de uma OP sortida num lote já existente
Static Function IncOP()

	Local _cLote := aBrowse1[oBrowse1:nAt,02]
	Local i
	TMP->(DbGoTop())

	ZAU->(DbSetOrder(1))
	if ZAU->(MsSeek(FWxfilial('ZAU')+_cLote))
		if ZAU->ZAU_STATUS  <> 'E'

			While TMP->(!eof())

				if empty(TMP->ZAR_OK)
					TMP->(DbSkip())
					loop
				endif

				ZAR->(DbSetOrder(1))
				if ZAR->(MsSeek(FWxfilial('ZAR')+TMP->ZAR_NUM))

					if  TMP->ZAR_PRCCLI          = ZAU->ZAU_PRCCLI .and.;
					alltrim(TMP->ZAR_LAYETQ) = alltrim(ZAU->ZAU_LAYETQ) .and.;
					TMP->ZAR_DTABAT          = ZAU->ZAU_DTABAT .and.;
					alltrim(TMP->ZAR_COD)    = alltrim(ZAU->ZAU_COD)

						//_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1') + alltrim(ZAU->ZAU_COD),1,"ERRO",.T.)
						//_cEstProd := GetAdvFVal('SG1','G1_TPPORC',FWxfilial('SG1') + alltrim(ZAU->ZAU_COD),1)
						ZG1->(DbSetOrder(4))

						if ZG1->(MsSeek(FWxfilial('ZG1') + alltrim(ZAU->ZAU_COD)))//(_cEstProd = 'RM')//(_cGrupo $ _cGrpMoi)

							_aRec := ProcessaRec(ZAR->ZAR_COD,ZAR->ZAR_QPPESO)

							for i := 1 to len(_aRec)
								ZAV->(DbSetOrder(1))
								if ZAV->(MsSeek(FWxfilial('ZAV') + _cLote + _aRec[i,1]))
									reclock('ZAV',.f.)
									ZAV->ZAV_QPPESO += _aRec[i,2]
									msunlock()

									ZAX->(DbSetOrder(1))
									if ZAX->(MsSeek(FWxfilial('ZAX') + ZAV->ZAV_BATEL))
										reclock('ZAX',.f.)
										ZAX->ZAX_QTDMP += _aRec[i,2]
										msunlock()
									endif
								endif
							next

						else
							ZAX->(DbSetOrder(1))
							if ZAX->(MsSeek(FWxfilial('ZAX') + ZAU->ZAU_BATEL))
								reclock('ZAX',.f.)
								ZAX->ZAX_QTDMP += TMP->ZAR_QTDMP
								msunlock()
							endif
						endif

						reclock('ZAR',.f.)
						ZAR->ZAR_LOTE := _cLote
						msunlock()

						reclock('ZAU',.f.)
						ZAU->ZAU_QTDMP  += TMP->ZAR_QTDMP
						ZAU->ZAU_QPPESO += TMP->ZAR_QPPESO
						ZAU->ZAU_QPCAIX += TMP->ZAR_QPCAIX
						ZAU->ZAU_QPUNI  += TMP->ZAR_QPUNI
						msunlock()

					else
						FWAlertError("OP não possui características para aglutinação no lote especificado!","OPERACAO",)
					endif
				endif

				TMP->(DbSkip())
			enddo
		else
			FWAlertError("Status do lote impede operação!","OPERACAO",)
		endif
	endif

	GeraTMP()

	AtuBr1()
	Atubr2(_cLote)

	oMark:oBrowse:Refresh()

return

//Função que exclui OP de um lote
Static Function ExcOP()
	Local _cOP   := aBrowse2[oBrowse2:nAt,02]
	Local _cLote := aBrowse2[oBrowse2:nAt,03]
	Local _aRec  := {}
	Local i

	If Aviso("Confirma exclusão?","Ao realizar a exclusão, as OPs serão liberadas!",{"Confirma","Cancela"}) == 1
		if !empty(aBrowse2[oBrowse2:nAt,02])

			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU')+_cLote))
				if ZAU->ZAU_STATUS  = 'A'

					ZAR->(DbSetOrder(1))
					if ZAR->(MsSeek(FWxfilial('ZAR')+_cOP))
						_aRec := ProcessaRec(ZAR->ZAR_COD,ZAR->ZAR_QPPESO)

						for i := 1 to len(_aRec)
							ZAV->(DbSetOrder(1))
							if ZAV->(MsSeek(FWxfilial('ZAV')+_cLote+_aRec[i,1]))
								reclock('ZAV',.f.)
								ZAV->ZAV_QPPESO -= _aRec[i,2]
								msunlock()
							endif
						next

						reclock('ZAR',.f.)
						ZAR->ZAR_LOTE := ''
						msunlock()
					endif

					_lExistOP := .f.

					ZAR->(DbSetOrder(4))
					if ZAR->(MsSeek(FWxfilial('ZAR')+_cLote))
						While ZAR->(!eof()) .and. ZAR->ZAR_FILIAL = FWxfilial('ZAR') .and. ZAR->ZAR_LOTE  = _cLote

							_lExistOP := .t.

							ZAR->(DbSkip())
						enddo
					endif

					if !_lExistOP

						//Exclui a receita de moida
						ExcRec(_cLote)

						reclock('ZAU',.f.)
						DbDelete()
						msunlock()
					endif

				else
					FWAlertError("Status do lote impede operação!","OPERACAO")
				endif
			endif
		else
			FWAlertError("Selecione uma OP para exclusão do lote!","OPERACAO")
		endif
	endif

	GeraTMP()

	AtuBr1()
	Atubr2(_cLote)

	oMark:oBrowse:Refresh()

return

//Função que excluir todo um lote
Static Function ExcLote()
	Local _cLote := aBrowse1[oBrowse1:nAt,02]
	Local _aOP   := {}
	Local i

	ZAU->(DbSetOrder(1))
	if ZAU->(MsSeek(FWxfilial('ZAU')+_cLote))
		if ZAU->ZAU_STATF = 'A' .and. ZAU->ZAU_STATW = 'A' .and. ZAU->ZAU_STATT = 'A'
			ZAR->(DbSetOrder(4))
			if ZAR->(MsSeek(FWxfilial('ZAR')+_cLote))
				While ZAR->(!eof()) .and. ZAR->ZAR_FILIAL = FWxfilial('ZAR') .and. ZAR->ZAR_LOTE  = _cLote

					aadd(_aOP,ZAR->ZAR_NUM)

					ZAR->(DbSkip())
				enddo
			endif

			for i := 1 to len(_aOP)

				ZAR->(DbSetOrder(1))
				if ZAR->(MsSeek(FWxfilial('ZAR')+_aOP[i]))

					reclock('ZAR',.f.)
					ZAR->ZAR_LOTE := ''
					msunlock()
				endif

			next

			//Excluir a receita para moída do lote
			//caso exista.
			ExcRec(_cLote)

			//_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1') + ZAU->ZAU_COD,1,"ERRO",.T.)
			//_cEstProd := GetAdvFVal('SG1','G1_TPPORC',FWxfilial('SG1') + alltrim(ZAU->ZAU_COD),1)

			_aRBat := {}

			ZG1->(DbSetOrder(4))

			if ZG1->(MsSeek(FWxfilial('ZG1') + alltrim(ZAU->ZAU_COD)))//_cEstProd = 'RM'//_cGrupo $ _cGrpMoi
				ZAV->(DbSetOrder(1))
				if  ZAV->(MsSeek(FWxfilial('ZAV') + ZAU->ZAU_COD))
					while ZAV->(!eof()) .and. ZAV->ZAV_FILIAL = FWxfilial('ZAV')
						aadd(_aRBat,ZAV->ZAV_BATEL)
						ZAV->(DbSkip())
					enddo
				endif
			else
				aadd(_aRBat,ZAU->ZAU_BATEL)
			endif

			for i := 1 to len(_aRBat)
				//bloco para atualizar as bateladas de MP
				ZAX->(DbSetOrder(1))
				if ZAX->(MsSeek(FWxfilial('ZAX') + _aRBat[i]))
					while ZAU->ZAU_FILIAL = FWxfilial('ZAU') .and. ZAX->ZAX_NUM = _aRBat[i]

						reclock('ZAX',.f.)
						ZAX->ZAX_QTDMP -= ZAU->ZAU_QTDMP
						msunlock()

						if ZAX->ZAX_QTDMP <= 0
							reclock('ZAX',.f.)
							DbDelete()
							msunlock()
						endif

						ZAX->(DbSkip())
					enddo
				endif
			next

			reclock('ZAU',.f.)
			dbdelete()
			msunlock()

			GeraTMP()

		else
			FWAlertError("Status do lote impede operação!","OPERACAO")
		endif
	endif

	AtuBr1()
	Atubr2(_cLote)

	oMark:oBrowse:Refresh()

return

//Função que define as cores de status
Static Function RetCores(_Stt)
	Local ret   := iif(_Stt = 'A',LoadBitmap(GetResources(),'br_verde'   ),;
	iif(_Stt = 'P',LoadBitmap(GetResources(),'br_laranja' ),;
	LoadBitmap(GetResources(),'br_vermelho')))
return  ret

//Função que habilita/desabilita registro
//de produção de refile ou quebras refile/fatiadoras
Static Function Refile()
	Local _cLote := aBrowse1[oBrowse1:nAt,02]
	//Local _aOP   := {}

	ZAU->(DbSetOrder(1))
	if ZAU->(MsSeek(FWxfilial('ZAU')+_cLote))

		//_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1') + ZAU->ZAU_COD,1,"ERRO",.T.)
		//_cEstProd := GetAdvFVal('SG1','G1_TPPORC',FWxfilial('SG1') + alltrim(ZAU->ZAU_COD),1)
		ZG1->(DbSetOrder(4))

		if ZG1->(MsSeek(FWxfilial('ZG1') + alltrim(ZAU->ZAU_COD)))//_cEstProd = 'RM'//(_cGrupo $ _cGrpMoi)
			FWAlertWarning("Lote de produção de carne moída!","ATENÇÃO")
		else
			ZAU->(DbSetOrder(4))

			reclock('ZAU',.f.)
			ZAU->ZAU_PROREF := iif(ZAU->ZAU_PROREF = 'S','N','S')
			msunlock()

			GeraTMP()

			AtuBr1()

			oMark:oBrowse:Refresh()
		endif
	endif

return

//Função que gera vetor de receita
//para carne moída
Static Function ProcessaRec(_cCod,_nPeso)
	Local _aRet := {}
	ZG1->(DbSetOrder(4))
	ZG1->(DbGoTop())
	SG1->(DbSetOrder(1))
	SG1->(DbGoTop())
	if ZG1->(MsSeek(FWxfilial('ZG1') + alltrim(_cCod)))
		aadd(_aRet,{ZG1->ZG1_NUM,_nPeso})
		return _aRet
	else
		if SG1->(MsSeek(FWxfilial('SG1') + padr(_cCod,15,'')))
			while SG1->(!eof()) .and. SG1->G1_FILIAL = FWxfilial('SG1') .and. SG1->G1_COD = padr(_cCod,15,'')
				if SG1->G1_TPPORC = 'RM'
					_nQtdMP := SG1->G1_QUANT * _nPeso
					aadd(_aRet,{SG1->G1_COMP,_nQtdMP})
				endif
				SG1->(dbSkip())
			enddo
		endif
	endif

return _aRet

//Função que exclui as demandas MP para receita de moida
Static Function ExcRec(_cNum)
	Local _aDem := {}
	Local i := 0

	ZAV->(DbSetOrder(2))
	if ZAV->(MsSeek(FWxfilial('ZAV') + _cNum))
		While ZAV->(!eof()) .and. ZAV->ZAV_FILIAL = FWxfilial('ZAV') .and. ZAV->ZAV_NUM = _cNum

			aadd(_aDem,ZAV->(ZAV_NUM+ZAV_ITEM))

			ZAV->(DbSkip())
		enddo
	endif

	for i := 1 to len(_aDem)

		if ZAV->(MsSeek(FWxfilial('ZAV')+_aDem[i]))
			reclock('ZAV',.f.)
			DbDelete()
			msunlock()
		endif
	next

return

//Função que exibe os itens da receita
//para carne moida
Static Function Receita()
	Local _cLote   := aBrowse1[oBrowse1:nAt,02]
	Local _nPesoT  := GetAdvFVal('ZAU','ZAU_QPPESO',FWxfilial('ZAU')+_cLote,1,0.0,.T.)

	DEFINE DIALOG oDlg3 TITLE "Itens de Receita de Carne Moida" FROM 020,105 To 220,1000 PIXEL

	oBrowse3 := TCBrowse():New(005,005,440,070,,aHeader3,aLargCol3,oDlg3,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	AtuBr3(_cLote,_nPesoT)

	@ 085,350  BUTTON 'Sair'  SIZE 40,10 ACTION oDlg3:end() OBJECT oBtn1

	ACTIVATE DIALOG oDlg3 CENTERED

return

//Função que exibe as bateladas
Static Function Batel()

	DEFINE DIALOG oDlg4 TITLE "Bateladas" FROM 020,105 To 220,1000 PIXEL

	oBrowse4 := TCBrowse():New(005,005,440,070,,aHeader4,aLargCol4,oDlg4,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	AtuBr4()

	@ 085,300  BUTTON 'Ajusta Prev.'  SIZE 40,10 ACTION ajustPrev() OBJECT oBtn1
	@ 085,350  BUTTON 'Sair'  		  SIZE 40,10 ACTION oDlg4:end() OBJECT oBtn1

	ACTIVATE DIALOG oDlg4 CENTERED

return

Static Function ajustPrev()

	Local _cBatel   := aBrowse4[oBrowse4:nAt,02]
	Local _lAlt     := .f.

	ZAX->(dbSetOrder(1))
	if ZAX->(MsSeek(FWxFilial('ZAX') + _cBatel))

		_nPeso := ZAX->ZAX_QTDMP

	endif

	DEFINE MSDIALOG oDlg5 TITLE 'Ajusta Previsao' from 000,000 To 150,280 OF oMainWnd PIXEL

	@ 009,002 SAY  'Peso Prev:' Object oSay1

	@ 009,065 GET _nPeso    SIZE 050,10 PICTURE "@E 999,999.99" valid !Vazio() Object oPeso

	@ 055,060 BMPBUTTON TYPE 1 ACTION EVAL({|| _lAlt := .t.,oDlg5:end()}) Object Obtn2

	ACTIVATE DIALOG oDlg5 CENTERED

	if _lAlt
		//alert('vai gravar o peso na batelada' + ZAX->ZAX_NUM)
		//alert(_nPeso)

		reclock('ZAX',.f.)
		ZAX->ZAX_QTDMP := _nPeso
		msunlock()
	endif

return

//Função que encerra um lote de produção
Static Function Encerra()
	Local _cLote   := aBrowse1[oBrowse1:nAt,02]
	Local _nCount  := Contar()

	If Aviso("Confirma encerramento deste lote?","Ao encerrá-la os empenhos de MP serão desfeitos e as OPs do lote encerradas!",{"Confirma","Cancela"}) == 1
		Processa({||ProcEnc(_nCount,_cLote,'E')},"ENCERRAMENTO DE LOTE","Desfazendo empenhos...")
	endif

	AtuBr1()

return

Static Function ProcEnc(_ncount,_cLote,_Oper)
	Local i
	//Faz contagem de OPs
	ZAU->(DbSetOrder(1))
	ZAR->(DbSetOrder(4))

	ProcRegua(_nCount)

	if ZAU->(MsSeek(FWxfilial('ZAU')+_cLote))
		if ZAR->(MsSeek(FWxfilial('ZAR')+_cLote))
			while ZAR->(!eof()) .and. ZAR->ZAR_FILIAL = FWxfilial('ZAR') .and. ZAR->ZAR_LOTE = _cLote
				ZAS->(DbSetOrder(2))
				if ZAS->(MsSeek(FWxfilial('ZAS') + ZAR->ZAR_NUM))
					while ZAS->(!eof()) .and. ZAS->ZAS_PREPOR = ZAR->ZAR_NUM
						incProc()

						if ZAS->ZAS_TIPO <> 'MP'
							ZAS->(Dbskip())
							loop
						endif

						if !empty(ZAS->ZAS_DATAS) .and. !empty(ZAS->ZAS_HORAS)
							ZAS->(DbSkip())
							loop
						endif

						reclock('ZAS',.f.)
						if _Oper = 'E'
							ZAS->ZAS_PREPOR := ''
							ZAS->ZAS_LOTE   := ''
						else
							ZAS->ZAS_LOTE   := _cLote
						endif
						msunlock()

						u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, iif(_Oper == 'E',"Encerramento de lote","Atualização de Empenhos"), ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

						ZAS->(DbSkip())
					enddo
				endif

				if _Oper = 'E'
					reclock('ZAR',.f.)
					ZAR->ZAR_STATUS := 'E'
					msunlock()
				endif

				ZAR->(DbSkip())
			enddo

			if _Oper = 'E'
				_aCaixas := {}
				ZAS->(DbSetOrder(9))
				if ZAS->(MsSeek(FWxfilial('ZAS') + _cLote))
					while ZAS->(!eof()) .and. ZAS->ZAS_LOTE = _cLote
						incProc()

						if ZAS->ZAS_TIPO <> 'MP'
							ZAS->(Dbskip())
							loop
						endif

						if !empty(ZAS->ZAS_DATAS) .and. !empty(ZAS->ZAS_HORAS)
							ZAS->(DbSkip())
							loop
						endif

						aadd(_aCaixas,{ZAS->ZAS_CONTRO})

						ZAS->(DbSkip())
					enddo

					for i := 1 to len(_aCaixas)
						ZAS->(DbSetOrder(1))
						if ZAS->(MsSeek(FWxfilial('ZAS') + _aCaixas[i]))
							reclock('ZAS',.f.)
							ZAS->ZAS_PREPOR := ''
							ZAS->ZAS_LOTE   := ''
							msunlock()
							
							u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Encerramento de Lote", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

						endif
					next
				endif
			endif

			if _Oper = 'E'
				reclock('ZAU',.f.)
				ZAU->ZAU_STATF  := 'E'
				ZAU->ZAU_STATW  := 'E'
				ZAU->ZAU_STATT  := 'E'
				ZAU->ZAU_STATUS := 'E'
				ZAU->ZAU_WFW    := 'E'
				msunlock()
			endif

		endif
	endif

return

//Função para contagem
Static Function Contar()
	Local _nCont := 0

	_cQuery := " SELECT COUNT(*) AS CONTAGEM FROM " + RetSQLTab('ZAU') + "," + RetSQLTab('ZAR') + "," + RetSQLTab('ZAS')
	_cQuery += " WHERE " + RetSQLFil('ZAU') + " AND " + RetSQLFil('ZAR') + " AND " + RetSQLFil('ZAS')
	_cQuery += " AND ZAU_NUM = ZAR_LOTE AND ZAR_NUM = ZAS_PREPOR AND ZAS_DATAS = '' AND ZAS_HORAS = '' "

	_cQuery += iif(!empty(mv_par04)," AND ZAR_COD = '" + mv_par04 + "'","")

	_cQuery += " AND " + RetSQLDel('ZAU') + " AND " + RetSQLDel('ZAR') + " AND " +  RetSQLDel('ZAS')

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("CON") != 0
		CON->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "CON"

	_nCont := CON->CONTAGEM

return _nCont

//Função para atualizar a tabela ZAS com o lote
Static Function AtuZAS(_Lote)
	Local _nCount := Contar()

	Processa({||ProcEnc(_nCount,_Lote,'A')},"ATUALIZAÇÃO DE EMPENHOS","Refazendo empenhos no lote...")

return

//Função para alteração de parametros de produção
Static Function ParProd()

	Local _cLote   := aBrowse1[oBrowse1:nAt,02]
	Local _lAlt    := .f.

	ZAU->(DbSetOrder(1))
	if ZAU->(MsSeek(FWxfilial('ZAU')+_cLote))
		if ZAU->ZAU_STATUS <> 'E'
			_dDataP   := ZAU->ZAU_DTPROD
			_dDataAbt := ZAU->ZAU_DTABAT
			_cLayEtq  := ZAU->ZAU_LAYETQ
			_cImProd  := ZAU->ZAU_IMPROD
			_cImpCom  := ZAU->ZAU_IMPCOM
			//_dDataV   := ZAU->ZAU_IMVAL
			_cMolde   := ZAU->ZAU_MOLDE
			_nGramat  := ZAU->ZAU_GRAMAT
			_cCtrlP   := ZAU->ZAU_CTRLP
			_nToler   := ZAU->ZAU_TOLER
			_nPesPrev := ZAU->ZAU_QPPESO
			_nPrevCx	 := ZAU->ZAU_QPCAIX //iif(ZAU->ZAU_QPCAIX = ,0,ZAU->ZAU_QPCAIX)
			_aCtrlP   := CTBCBOX('ZAU_CTRLP')
			_nPrevUni := ZAU->ZAU_QPUNI // ajuste

			//DEFINE MSDIALOG oDlg2 TITLE 'Parametros de Produção' from 000,000 To 280,550 OF oMainWnd PIXEL
			DEFINE MSDIALOG oDlg2 TITLE 'Parametros de Produção' from 000,000 To 310,460 OF oMainWnd PIXEL
			@ 009,002 SAY  'Data de Produção:' Object oSay1
			@ 021,002 SAY  'Data de Abate:   ' Object oSay2
			//@ 033,002 SAY  'Data de Validade:' Object oSay2
			@ 045,002 SAY  'Layout:          ' Object oSay3
			@ 057,002 SAY  'Desc. Reduzida:  ' Object oSay4
			@ 069,002 SAY  'Desc. Oficial:   ' Object oSay5
			@ 081,002 SAY  'Molde:           ' Object oSay6
			@ 093,002 SAY  'Gramatura:       ' Object oSay7
			@ 105,002 SAY  'Controle Prod.:  ' Object oSay8
			@ 117,002 SAY  'Tolerancia(%):   ' Object oSay9
			@ 129,002 SAY  'Peso Previsto:   ' Object oSay10
			@ 141,002 SAY  'Caixas Prevista: ' Object oSay11

			@ 009,065 GET _dDataP    SIZE 050,10 PICTURE "99/99/99" valid !Vazio() Object odDataP
			@ 021,065 GET _dDataAbt  SIZE 050,10 PICTURE "99/99/99" valid !Vazio() Object oDataAbt
			//@ 033,065 GET _dDataV    SIZE 050,10 PICTURE "99/99/99" valid !Vazio() Object odDataV
			@ 045,065 GET _cLayEtq   SIZE 030,10 PICTURE "@!"  valid !Vazio() F3 'ZC' Object oLayEtq
			@ 057,065 GET _cImProd   SIZE 130,10 PICTURE "@!"  valid !Vazio() Object oImProd
			@ 069,065 GET _cImpCom   SIZE 130,10 PICTURE "@!"  valid !Vazio() Object oImCom
			@ 081,065 GET _cMolde    SIZE 020,10 PICTURE "@!" F3 'ZD' Object oMolde
			@ 093,065 GET _nGramat   SIZE 020,10 PICTURE "@E 999"  Object oGramat
			@ 105,065 COMBOBOX _cCtrlP ITEMS _aCtrlP size 50,50 oBject oCtrlP
			@ 117,065 GET _nToler   SIZE 020,10 PICTURE "@E 999" Object oToler
			/*Solicitação de inclusão da Lucinéia de um campo de ajuste de caixas
			OBS - Desvilculada a proporção de caixas e Peso , deixando independente o ajuste das mesmas
			Este processo foi autorizado pelo Matheus Silva dia 09/06/2017 */
			//	@ 129,065 GET _nPesPrev SIZE 060,10 PICTURE "@E 999,999.99" Object oPesPrev
			@ 129,065 GET _nPesPrev SIZE 060,10 PICTURE "@E 999,999.99" valid Calcc() Object oPesPrev
			@ 141,065 GET _nPrevCx  SIZE 060,10 PICTURE "@E 999" valid Calcp() Object oPrevCx

			if empty(_cLayEtq)
				oLayEtq:disable()
			endif

			@ 129,195 BMPBUTTON TYPE 1 ACTION EVAL({|| _lAlt := .t.,oDlg2:end()}) Object Obtn2
			ACTIVATE MSDIALOG oDlg2

			if _lAlt

				SB1->(DbSetOrder(1))

				if SB1->(MsSeek(FWxfilial('SB1') + ZAU->ZAU_COD))
					reclock('SB1',.f.)
					if empty(SB1->B1_MOLDE)
						SB1->B1_MOLDE := _cMolde
					endif
					if SB1->B1_GRAMAT = 0
						SB1->B1_GRAMAT := _nGramat
					endif
					msunlock()
				endif

				//recalcula o previsto de caixas  Calcc
				//_nPrevCx := _nPesPrev / SB1->B1_PMCAIX
				//_nPrevUni := _nPesPrev / SB1->B1_PESBAND
				/*Trocado pelas funções Calcp() e Calcc()*/
				//alert(_nPrevUni)
				reclock('ZAU',.f.)
				ZAU->ZAU_IMPROD := _cImProd
				ZAU->ZAU_IMPCOM := _cImpCom
				ZAU->ZAU_DTPROD := _dDataP
				ZAU->ZAU_DTABAT := _dDataAbt
				ZAU->ZAU_LAYETQ := _cLayEtq
				//ZAU->ZAU_IMVAL  := _dDataV
				ZAU->ZAU_MOLDE  := _cMolde
				ZAU->ZAU_GRAMAT := _nGramat
				ZAU->ZAU_CTRLP  := _cCtrlP
				ZAU->ZAU_TOLER  := _nToler
				ZAU->ZAU_QPPESO := _nPesPrev
				ZAU->ZAU_QPCAIX := _nPrevCx
				ZAU->ZAU_QPUNI  := _nPrevUni
				ZAU->ZAU_USUALT := cUserName				
				msunlock()
			endif

			AtuBr1()
			oDlg:Refresh()
		else
			alert('Lote já encerrado!')
		endif
	endif
return

//Função de empenhos
Static Function Empenho()
	Local _cLote      := aBrowse1[oBrowse1:nAt,02]
	Private lInverte  := .f.
	Private cMark     := GetMark()
	Private oMark
	Private _dDataProd:= ddatabase
	Private _nQtdEmpF := 0.00                                     //Quantidade de empenho faltante
	Private _nQtdEmpA := 0.00                                     //Quantidade de empenho atual
	//Private _cGrpMoi  := GetMV('SI_GRPMOI')
	Private _cGrupo   := ''
	Private _nPercQ   := 0

	cPerg2 := "GJF217b"

	if pergunte(cPerg2,.t.)

		ZAU->(DbSetOrder(1))
		if ZAU->(MsSeek(FWxfilial('ZAU')+_cLote))

			if ZAU->ZAU_STATUS  = 'E'
				alert('Lote já encerrado!')
				return
			endif

			//_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+ZAU->ZAU_COD,1,"ERRO",.T.)
			//_cEstProd := GetAdvFVal('SG1','G1_TPPORC',FWxfilial('SG1') + alltrim(ZAU->ZAU_COD),1)
			ZG1->(DbSetOrder(4))

			if ZG1->(MsSeek(FWxfilial('ZG1') + alltrim(ZAU->ZAU_COD)))//_cEstProd = 'RM'//_cGrupo $_cGrpMoi
				FWAlertWarning("Tipo do PA impede esta operação!","RECEITA MOÍDA")
			else

				//Bloco para apurar a quantidade atual de empenho

				_nPercQ := round(ZAU->(ZAU_QTDPI/ZAU_QTDMP),2)

				ZAS->(DbSetOrder(9))
				if ZAS->(MsSeek(FWxfilial('ZAS')+_cLote))
					while ZAS->(!eof()) ;
					.and. ZAS->ZAS_FILIAL = FWxfilial('ZAS') ;
					.and. ZAS->ZAS_LOTE = _cLote

						if !(ZAS->ZAS_TIPO $ 'MP/PP')
							ZAS->(DbSkip())
							loop
						endif

						if !(ZAS->ZAS_TIPO $ ('QR','QF'))
							_nQtdEmpA += iif(ZAS->ZAS_TIPO = 'PP',(ZAS->ZAS_PESOL/_nPercQ),ZAS->ZAS_PESOL)
						endif

						ZAS->(DbSkip())
					enddo
				endif

				aObjects := {}    //dimensao janelas
				aPosObj  := {}
				aInfo    := {}
				aSizeAut := MsAdvSize()

				AAdd( aObjects, { 315, 50, .T., .T. } )
				AAdd( aObjects, { 100, 100, .T., .T. } )
				aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
				aPosObj := MsObjSize( aInfo, aObjects, .T. )

				TMPEmp(_cLote)

				aCampos  := {}
				AADD(aCampos,{"ZAS_OK"      ,,"OK"         ,"@!" })
				AADD(aCampos,{"ZAS_LOTE"    ,,"Lote"       ,"@!" })
				AADD(aCampos,{"ZAS_LOTE2"   ,,"Lote OP"    ,"@!" })
				AADD(aCampos,{"ZAS_CONTRO"  ,,"Codigo"  	 ,"@!" })
				AADD(aCampos,{"ZAS_COD"     ,,"Produto"    ,"@!" })
				AADD(aCampos,{"ZAS_DESC"	 ,,"Descricao"  ,"@!" })
				AADD(aCampos,{"ZAS_DATAP"   ,,"Data.Prod." ,"99/99/99" })
				AADD(aCampos,{"ZAS_VAL"     ,,"Validade"   ,"99/99/99" })
				AADD(aCampos,{"ZAS_PESOL"   ,,"Peso Liq."  ,"@E 999.99" })
				AADD(aCampos,{"ZAS_TIPO"    ,,"Tipo"       ,"@!" })
				AADD(aCampos,{"ZAS_PREPOR"  ,,"Prev.Porc." ,"@!" })
				AADD(aCampos,{"ZAS_PREEMB"  ,,"Prev.Des."  ,"@!" })

				oFont   := tFont():New("arial",,-12,,.t.,,,,)
				_oEmp1  := 'Quantidade empenhada(kg):
				_oEmp2  :=  iif(ZAU->ZAU_QTDMP >= _nQtdEmpA,Transform(_nQtdEmpA,'@E 999,999.99'),"")
				_oEmp3  :=  iif(ZAU->ZAU_QTDMP <  _nQtdEmpA,Transform(_nQtdEmpA,'@E 999,999.99'),"")
				_oEmp4  := 'Empenho necessário de MP(kg): ' + Transform(ZAU->ZAU_QTDMP,'@E 999,999.99')

				DEFINE MSDIALOG oDlg2 TITLE "Selecionar" From 9,0 To 380,1100 PIXEL

				oMark := MsSelect():New("TMP2","ZAS_OK","",aCampos,@lInverte,@cMark,{15,5,155,540},,,,,)

				oMark:bMark := {| | Disp2()}

				oBtn1 	 := TButton():New(160, 020, "Marcar/Desmarcar", oDlg2,{|| Sele2()           } ,60,020,,,.F.,.T.,.F.,,.F.,,,.F. )
				oBtn2 	 := TButton():New(160, 090, "Empenhar"        , oDlg2,{|| Empenhar(_cLote)  } ,60,020,,,.F.,.T.,.F.,,.F.,,,.F. )
				oBtn3 	 := TButton():New(160, 200, "Sair"            , oDlg2,{|| oDlg2:end()       } ,60,020,,,.F.,.T.,.F.,,.F.,,,.F. )
				oSayEmp1 :=  tSay():New(170, 300,{|| _oEmp1 },oDlg2,,oFont,,,,.T.,,,200,30)
				oSayEmp2 :=  tSay():New(170, 375,{|| _oEmp2 },oDlg2,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
				oSayEmp3 :=  tSay():New(170, 375,{|| _oEmp3 },oDlg2,,oFont,,,,.T.,CLR_HRED,CLR_HRED,200,30)
				oSayEmp4 :=  tSay():New(170, 420,{|| _oEmp4 },oDlg2,,oFont,,,,.T.,,,200,30)

				ACTIVATE MSDIALOG oDlg2 CENTERED

				If Select('TMP2')<>0
					TMP2->(dbCloseArea())
				Endif

				If Select('MAT')<>0
					MAT->(dbCloseArea())
				Endif
			endif
		endif
	endif

	pergunte(cPerg,.f.)

Return .T.

//Função que marca a caixa de MP e
//faz a atualização do valor de empenho
Static Function Disp2()

	RecLock("TMP2",.F.)
	If Marked("ZAS_OK")
		TMP2->ZAS_OK := iif(lInverte,"",cMark)
		CalcEmp(.t.)
	Else
		TMP2->ZAS_OK := iif(lInverte,cMark,"")
		CalcEmp(.f.)
	Endif
	msunlock()

	oSayEmp2:SetText(iif(ZAU->ZAU_QTDMP >= _nQtdEmpA,Transform(_nQtdEmpA,'@E 999,999.99'),""))
	oSayEmp3:SetText(iif(ZAU->ZAU_QTDMP <  _nQtdEmpA,Transform(_nQtdEmpA,'@E 999,999.99'),""))

	oMark:oBrowse:Refresh()

Return()

//Função estática para calculo dinamico do empenho
Static Function CalcEmp(_x)
	if _x
		_nQtdEmpA += iif(TMP2->ZAS_TIPO = 'PP',(TMP2->ZAS_PESOL/_nPercQ),TMP2->ZAS_PESOL)
	else
		_nQtdEmpA -= iif(TMP2->ZAS_TIPO = 'PP',(TMP2->ZAS_PESOL/_nPercQ),TMP2->ZAS_PESOL)
	endif
return

Static Function Sele2()
	TMP2->(dbgotop())

	while TMP2->(!eof())
		reclock('TMP2',.f.)
		TMP2->ZAS_OK := iif(empty(TMP2->ZAS_OK),cMark,"")
		msunlock()

		If Marked("ZAS_OK")
			CalcEmp(.t.)
		Else
			CalcEmp(.f.)
		Endif

		TMP2->(dbskip())
	enddo

	TMP2->(dbgotop())

	oSayEmp2:SetText(iif(ZAU->ZAU_QTDMP >= _nQtdEmpA,Transform(_nQtdEmpA,'@E 999,999.99'),""))
	oSayEmp3:SetText(iif(ZAU->ZAU_QTDMP <  _nQtdEmpA,Transform(_nQtdEmpA,'@E 999,999.99'),""))

	oMark:oBrowse:Refresh()
return .t.

//Função para Gerar a Previsão de Produção
Static Function Empenhar(_cLote)
	TMP2->(DbGoTop())

	While TMP2->(!eof())

		ZAS->(DbSetOrder(1))
		if ZAS->(MsSeek(FWxfilial('ZAS')+TMP2->ZAS_CONTRO))
			reclock('ZAS',.f.)
			ZAS->ZAS_LOTE := iif(!empty(TMP2->ZAS_OK),_cLote,iif(_cLote = TMP2->ZAS_LOTE,'',TMP2->ZAS_LOTE ))
			msunlock()
			u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Empenho para lote "+alltrim(ZAS->ZAS_LOTE), ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))
		endif

		TMP2->(DbSkip())
	EndDo

	TMPEmp(_cLote)

	oMark:oBrowse:Refresh()

	oDlg2:end()

return

//Função responsável pela geração do arquivo de trabalho TMP
Static Function TMPEmp(_cLote)

	cQuery := " SELECT *  FROM " + RetSQLTab('ZAS') + " WHERE " + RetSQLFil('ZAS') + " AND "
	cQuery += " ZAS_DATAS = ' ' AND ZAS_HORAS = ' ' AND ZAS_TIPO IN('MP','PP') AND "

	//Matéria-Prima alocada?
	if mv_par01 = 1
		cQuery += " ZAS_LOTE = '" + _cLote + "' AND "
	elseif mv_par01 = 2
		cQuery += " (ZAS_LOTE = ' ' OR ZAS_LOTE <> '" + _cLote + ") AND "
		cQuery += " (ZAS_COD = '" + ZAU->ZAU_CODMP + "'"
		cQuery += " OR ZAS_COD = '" + ZAU->ZAU_CODPI + "') AND "
	else
		cQuery += " (ZAS_COD = '" + ZAU->ZAU_CODMP + "' OR ZAS_COD = '" + ZAU->ZAU_CODPI + "')  "
		cQuery += " AND "
	endif

	cQuery += iif(mv_par02 <> 0," ZAS_DTPROD >= '" + dtos(ddatabase - mv_par02) + "' AND ",'') 

	cQuery += RetSqlDel('ZAS')
	cQuery += " ORDER BY ZAS_DTPROD "

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("MAT") != 0
		MAT->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "MAT"

	MAT->(DbGoTop())

	ZAS->(DbSetOrder(1))

	_aArqTrb:= {}
	//cArq  := CriaTrab( Nil, .F. )

	aStru := dbStruct()

	aadd(aStru,{"ZAS_OK"    , "C",  02, 0})
	aadd(aStru,{"ZAS_VAL"   , "D",  08, 0})
	aadd(aStru,{"ZAS_DATAP" , "D",  08, 0})
	aadd(aStru,{"ZAS_LOTE2" , "C",  10, 0})

	//dbcreate(cArq,aStru)
	// ProcData 04/2023 - Chamada para criar arquivo de trabalho
	U_ArqTrb("Cria", "TMP2", aStru, {"ZAS_FILIAL","ZAS_DTPROD"}, @_aArqTrb)

	If Select('TMP2')<>0
		TMP2->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	//dbUseArea( .T.,,cArq,"TMP2", .F. , .F. )               //cria temp
	//Index On ZAS_FILIAL+dtos(ZAS_DTPROD) To (cArq)

	While MAT->(!eof())

		_cLote2 := GetAdvFVal('ZAR','ZAR_LOTE',FWxfilial('ZAR') + MAT->ZAS_PREPOR,1,"ERRO",.T.)

		_lEmp := iif(MAT->ZAS_LOTE = _cLote,.t.,.f.)

		DbSelectArea('TMP2')
		reclock('TMP2',.t.)
		TMP2->ZAS_VAL     := MAT->(stod(ZAS_DTPROD) + ZAS_VALID)
		TMP2->ZAS_FILIAL  := cFilAnt
		TMP2->ZAS_COD     := MAT->ZAS_COD
		TMP2->ZAS_OK      := iif(_lEmp,cMark,'')
		TMP2->ZAS_CONTRO  := MAT->ZAS_CONTRO
		TMP2->ZAS_DESC    := MAT->ZAS_DESC
		TMP2->ZAS_PESOL   := MAT->ZAS_PESOL
		TMP2->ZAS_TARA    := MAT->ZAS_TARA
		TMP2->ZAS_PESOB   := MAT->ZAS_PESOB
		TMP2->ZAS_PREPOR  := MAT->ZAS_PREPOR
		TMP2->ZAS_TIPO    := MAT->ZAS_TIPO
		TMP2->ZAS_PREEMB  := MAT->ZAS_PREEMB
		TMP2->ZAS_DATAP   := stod(MAT->ZAS_DTPROD)
		TMP2->ZAS_LOTE    := MAT->ZAS_LOTE
		TMP2->ZAS_LOTE2   := _cLote2
		msunlock()

		MAT->(DbSkip())
	enddo

	dbSelectarea('TMP2')
	IndRegua("TMP2",cArq,"ZAS_FILIAL+dtos(ZAS_VAL)",,,"Selecionando Registros...") //ordena
	TMP2->(dbGotop())

return

Static Function Legenda()

	aCores:= { {'BR_VERDE'    ,'Aberto'    },;
	{'BR_LARANJA'  ,'Em produção...'},;
	{'BR_VERMELHO' ,'Encerrado'}}

	BrwLegenda('OPs. Porcionados','Legenda',aCores)

return

//Rotina para refazer bateladas
Static Function RefBat()

	Local _lCons    := .f.
	Local _aBatel   := {}
	Local _aBatOri  := {}
	Local i
	Local j

	ZAX->(DbsetOrder(2))
	if ZAX->(MsSeek(FWxfilial('ZAX') + dtos(mv_par03),.t.))
		while ZAX->(!eof()) .and. ZAX->ZAX_FILIAL = FWxfilial('ZAX') .and. ZAX->ZAX_DTPROD <= mv_par03

			if ZAX->ZAX_QTDMPC <> 0
				_lCons := .t.
				exit
			else
				aadd(_aBatOri,ZAX->ZAX_NUM)
			endif

			ZAX->(DbSkip())
		enddo
	endif

	if _lCons
		FWAlertError("Consumo de matéria prima das bateladas do dia já iniciado!","OPERACAO")

	else

		for i := 1 to len(_aBatOri)
			ZAX->(DbsetOrder(1))
			if ZAX->(MsSeek(FWxfilial('ZAX') +_aBatOri[i]))
				reclock('ZAX',.f.)
				dbdelete()
				msunlock()
			endif
		next

		ZAU->(DbSetOrder(2))
		if ZAU->(MsSeek(FWxfilial('ZAU')+dtos(mv_par03),.t.))
			while ZAU->(!eof()) .and. ZAU->ZAU_FILIAL = FWxfilial('ZAU') .and. ZAU->ZAU_DTPROD = mv_par03

				//_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1') + ZAU->ZAU_COD,1,"ERRO",.T.)
				//_cEstProd := GetAdvFVal('SG1','G1_TPPORC',FWxfilial('SG1') + alltrim(ZAU->ZAU_COD),1)
				ZG1->(DbSetOrder(4))

				if ZG1->(MsSeek(FWxfilial('ZG1') + alltrim(ZAU->ZAU_COD)))//_cEstProd = 'RM'//_cGrupo $ _cGrpMoi

					ZAV->(DbSetOrder(1))
					if  ZAV->(MsSeek(FWxfilial('ZAV') + ZAU->ZAU_NUM))
						while ZAV->(!eof()) .and. ZAV->ZAV_FILIAL = FWxfilial('ZAV') .and. ZAV->ZAV_NUM = ZAU->ZAU_NUM

							//Bloco para montar o vetor de bateladas por MP
							//para agilizar consumo na saída da camara
							_nPos := aScan(_aBatel,{|aVal|aVal[1] = alltrim(ZG1->ZG1_NUM)})

							if _nPos <> 0
								_aBatel[_nPos,2] += ZAV->ZAV_QPPESO

								// Para atualizar o ZAV recem criado
								_cBatel := _aBatel[_nPos,3]
							else
								_cBatel := GetSx8num('ZAX','ZAX_NUM')
								ConfirmSx8()

								aadd(_aBatel,{alltrim(ZG1->ZG1_NUM),ZAV->ZAV_QPPESO,_cBatel,'S'})
							endif

							reclock('ZAV',.f.)
							ZAV->ZAV_BATEL := _cBatel
							msunlock()

							ZAV->(DbSkip())
						enddo
						//Fim do bloco de montagem do vetor de bateladas

					endif

				else
					//Bloco para montar o vetor de bateladas por MP
					//para agilizar consumo na saída da camara
					_nPos := aScan(_aBatel,{|aVal|aVal[1] = alltrim(ZAU->ZAU_CODMP) })

					if _nPos <> 0
						_aBatel[_nPos,2] += ZAU->ZAU_QTDMP
						// Para atualizar o ZAU recem criado
						_cBatel := _aBatel[_nPos,3]
					else
						_cBatel := GetSx8num('ZAX','ZAX_NUM')
						ConfirmSx8()
						aadd(_aBatel,{alltrim(ZAU->ZAU_CODMP),ZAU->ZAU_QTDMP,_cBatel,'N'})
					endif
					//Fim do bloco de montagem do vetor de bateladas

					reclock('ZAU',.f.)
					ZAU->ZAU_BATEL := _cBatel
					msunlock()
				endif

				ZAU->(DbSkip())
			enddo
		endif

		for j := 1 to len(_aBatel)

			if len(alltrim(_aBatel[i,1])) = 4
				_cDescMP := GetAdvFVal('ZG0','ZG0_DESC',FWxfilial('ZG0') + _aBatel[j,1],1,"ERRO",.T.)
			else
				_cDescMP := GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1') + _aBatel[j,1],1,"ERRO",.T.)
			endif

			reclock('ZAX',.t.)
			ZAX->ZAX_NUM    := _aBatel[j,3]
			ZAX->ZAX_CODMP  := _aBatel[j,1]
			ZAX->ZAX_QTDMP  := _aBatel[j,2]
			ZAX->ZAX_DESCRI := _cDescMP
			ZAX->ZAX_STATUS := 'A'
			ZAX->ZAX_FILIAL := FWxfilial('ZAX')
			ZAX->ZAX_DTPROD := mv_par03
			ZAX->ZAX_REC    := _aBatel[j,4]
			msunlock()
		next

		MsgInfo('Bateladas de MP reorganizadas!')

	endif
return

//Rotina para refazer cálculo de Prev.Caixas e Prev.Bandeijas
Static Function Calcc()
	//Era
	//_nPrevC  := _nPesPrev / SB1->B1_PMCAIX
	//_nPrevUni := _nPesPrev / SB1->B1_PESBAND

	// Alterado para
	_cProdut  	:= GetAdvFVal('SB1','B1_COD',FWxfilial('SB1')+ZAU->ZAU_COD,1,"ERRO",.T.)
	_cPMCAIX 	:= GetAdvFVal('SB1','B1_PMCAIX',FWxfilial('SB1')+ZAU->ZAU_COD,1,"ERRO",.T.)
	_cPESBAN		:= GetAdvFVal('SB1','B1_PESBAND',FWxfilial('SB1')+ZAU->ZAU_COD,1,"ERRO",.T.)
	//alert(_cProdut)
	//alert(_cPMCAIX)
	//alert(_cPESBAN)
	_nPrevC := _nPesPrev / _cPMCAIX
	_nPrevB := _nPesPrev / _cPESBAN
	_nPrevCx  := round(_nPrevC,0)
	_nPrevUni := round(_nPrevB,0)

	//alert(_nPesPrev)
	//alert(SB1->B1_QCAIX)
	//alert(_nPrevC)
	//alert(_nPrevB)
	//alert(_nPrevCx)
	//alert(_nPrevUni)

return
//Rotina para refazer cálculo de Prev.Peso e Prev.Bandeijas
Static Function Calcp()

	//ZAU->ZAU_STATUS
	/*Era assim*/
	//_nPesPrev := _nPrevCx * SB1->B1_PMCAIX
	//_nPrevUni := _nPesPrev / SB1->B1_PESBAND

	/*Conforme contato e pedido de André , ele precisa alterar somente a quantidade de caixas  e não alterar a quantidade da previsão do peso total do pedido.
	Este pedido de desvincular o Peso total da  quantidade de caixas foi feito pelo André (PCP) e Liberado pelo Sr Matheus Silva dia 05/07/2017. E feito por Flávio dia 18/07/2017
	*/
	// Prev.Bandeijas  = Quant. Caixas * Quant.bandejas na caixa  //
	//

	_cQCAIX  	:= GetAdvFVal('SB1','B1_QCAIX',FWxfilial('SB1')+ZAU->ZAU_COD,1,"ERRO",.T.)
	_nPrevUni 	:= _nPrevCx * _cQCAIX
	/*
	alert(ZAU->ZAU_COD)
	alert(_nPrevCx)
	alert(_cQCAIX)
	alert(_nPrevCx)
	alert(_nPrevUni)
	*/

return

Static Function GeraXLS()
	_cAlias := GetNextAlias()
	aDados	 := {}
    aCabec	 := {}

	_cQRY := "SELECT ZAU.ZAU_FILIAL AS xFILIAL, ZAU.ZAU_NUM AS NUMERO, ZAU.ZAU_COD AS CODPRODUTO, ZAU.ZAU_IMPROD AS DESCPRODUTO, ZAU.ZAU_LAYETQ AS LAIOUT, "
	_cQRY += "ZAU.ZAU_PRCCLI AS PRECOCLI, ZAU.ZAU_DTABAT AS DTABATE, ZAU.ZAU_QPPESO AS QPESO, ZAU.ZAU_QRPESO AS QRPESO, ZAU.ZAU_QPCAIX AS QTDPORCXA, "
	_cQRY += "ZAU.ZAU_QRCAIX AS QTDRPORCXA, ZAU.ZAU_QPUNI AS QTDPUNI, ZAU.ZAU_QRUNI AS QTDRPUNI"
	_cQRY += "FROM " + RetSQLTab('ZAU')
	_cQRY += "WHERE " + RetSQLFil('ZAU') + " AND " + RetSQLDel('ZAU') + " AND ZAU_DTPROD = " + DToS(mv_par03)

	_cQRY := ChangeQuery(_cQRY)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQRY NEW ALIAS "QRY"

	QRY->(DbGotop())

	While QRY->(!EOF())		
		aAdd(aDados, { QRY->xFILIAL,;
            QRY->NUMERO,;
			QRY->CODPRODUTO,;
			QRY->DESCPRODUTO,;
			QRY->LAIOUT,;
			QRY->PRECOCLI,;
			QRY->DTABATE,;
			QRY->QPESO,;
			QRY->QRPESO,;
			QRY->QTDPORCXA,;
			QRY->QTDRPORCXA,;
			QRY->QTDPUNI,;
			QRY->QTDRPUNI;
            })
        QRY->(DBSKIP())
	EndDo
	//Gera o arquivo excel
    If Len(aDados) > 0
		aadd(aCabec, {"Filial"       , "C", 2 , 0})
		aadd(aCabec, {"OP"           , "C", 10, 0})
		aadd(aCabec, {"Cod. Produto" , "C", 14, 0})
		aadd(aCabec, {"Desc. Produto", "C", 60, 2})
		aadd(aCabec, {"Layout"       , "C", 3 , 2})
        aadd(aCabec, {"Preço"        , "N", 6 , 2})
		aadd(aCabec, {"Dta. Abate"   , "D", 8 , 2})
        aadd(aCabec, {"Peso Prev."   , "N", 9 , 2})
        aadd(aCabec, {"Peso Real"    , "N", 9 , 2})
        aadd(aCabec, {"Cxa. Prev"    , "N", 5 , 2})
		aadd(aCabec, {"Cxa. Real"    , "N", 5 , 2})
		aadd(aCabec, {"Uni. Prev."   , "N", 6 , 2})
		aadd(aCabec, {"Uni. Real"    , "N", 6 , 2})

		U_GERAEXCEL("GJF217", aDados, aCabec, .T., .T.)
	Endif	
Return
