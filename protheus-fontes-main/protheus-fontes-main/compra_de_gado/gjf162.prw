#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GJF162   ºAutor  ³ Giualiano          º Data ³  18/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Relatorio de Formação de Preço de Gado 		              º±±
±±º          ³  banco de dados                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF162()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de Formação de preço de gado abatido para avaliação"
	Local cDesc3         := "da Diretoria da Empresa mediante parametros apontados."
	Local titulo         := "Formação de Previsão de Gado"
	Local nLin           := 132
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 165
	Private tamanho      := "G"
	Private nomeprog     := "GJF162" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF162" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _cDtAbat     := ''
	Private cPerg        := ''
	Private _nVlrTF      := 0.00
	Private _nVlrCons    := 0.00
	Private _nVlrGrax    := 0.01
	Private _aLiq		 := {}
	Private nPesPren  	 := GETMV("SI_PNPREN")
	Private nPesPread 	 := GETMV("SI_PNPREAD")

	dbSelectArea("SZ4")
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta interface com usuário                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPerg := "GJF162"

	If !Pergunte(cPerg,.T.)
		Return
	Endif

	_nVlrTF      := mv_par05
	_nVlrCons    := mv_par06

	wnrel := SetPrint("SZ4",NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,"SZ4")

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
	//Â³ Processamento. RPTSTATUS monta janela com a regua de processamento. Â³
	//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™

	_cDtAbat := dtoc(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+mv_par01,1))

	Cabec1   := 'Abate em: ' + _cDtAbat

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//Local nOrdem
	Local _cOrigem     := ''
	Local _aCodProd    := ''
	Local _cProdutor   := ''
	Local _cCodComp    := ''
	Local _cCompr      := ''
	Local _nQTLotes    := 0
	Local _nPcarcF     := 0.00   //Peso carcaça fria do lote
	Local _nPesoFrig   := 0
	Local _nPesoProp   := 0
	Local _nQuebra     := 0.00
	//Local _cCodCat    := ''
	Local _nComis      := 0.00
	Local _cTpCompr    := ''
	Local i
	Private _nPrecIni  := 0.00
	Private _nQTAnim   := 0
	Private _nKm       := 0.00
	Private _nVeic     := 0
	Private _nValFre   := 0
	Private _aProg	   := {{'000',0,0,0,0,0},{'001',0,0,0,0,0},{'002',0,0,0,0,0},{'005',0,0,0,0,0},{'006',0,0,0,0,0},{'008',0,0,0,0,0},{'013',0,0,0,0,0},{'019',0,0,0,0,0},{'020',0,0,0,0,0},{'T',0,0,0,0,0}}
	Private _aGord     := {{'1',0,0,0,0,0},{'2',0,0,0,0,0},{'2+',0,0,0,0,0},{'3',0,0,0,0,0},{'4',0,0,0,0,0},{'5',0,0,0,0,0}}
	Private _aGordTT   := {{'1',0,0,0,0,0,0},{'2',0,0,0,0,0,0},{'2+',0,0,0,0,0,0},{'3',0,0,0,0,0,0},{'4',0,0,0,0,0,0},{'5',0,0,0,0,0,0}}
	Private _cFPadrao  := '001/005/007' //Programas fora do padrão
	Private _aProgTT   := {}
	Private _aCateTT   := {}
	Private _aDestTT   := {{'T',0,0,0,0,0,0},{'R',0,0,0,0,0,0}}
	Private _aTotDes   := {}
	Private _aTotRec   := {}
	Private _aTDCate   := {}
	Private _aTDProg   := {}
	Private _aTRCate   := {}
	Private _aTRProg   := {}
	Private _nFrAnim   := 0.00   //Frete por animal
	Private _nCoAnim   := 0.00   //Comissao por animal
	Private _nFrDia    := 0.00   //Custo do frete do dia
	Private _nCoDia    := 0.00   //Custo da comissão do dia
	Private _nPcDia    := 0.00   //Peso de carcaça fria do dia
	Private _nFrLote   := 0.00   //Custo de frete do lote
	Private _nCoLote   := 0.00   //Custo de comissao do lote
	Private _cListProg := '001/002/011'

	//Montagem do vetor de programas
	DbSelectArea('SZ6')
	DbSelectArea('SZ5')

	SZ6->(DbSetOrder(1))
	SZ5->(DbSetOrder(1))

	SZ6->(DbGotop())
	SZ5->(DbGotop())

	while SZ6->(!eof())
		if SZ6->Z6_COD $ _cFPadrao .or. SZ6->Z6_COD = "013"
			_nPos := aScan(_aProgTT,{|aVal|aVal[1] = '000'})
			if  _nPos = 0
				aAdd(_aProgTT,{'000',0,0,0,0,0,0,0,0})
			endif
		else
			aAdd(_aProgTT,{alltrim(SZ6->Z6_COD),0,0,0,0,0,0,0,0})
		endif

		SZ6->(DbSkip())
	enddo

	while SZ5->(!eof())
		if SZ5->Z5_COD = "003"
			SZ5->(DbSkip())
		endif
		aAdd(_aProgTT,{'S' + alltrim(SZ5->Z5_COD),0,0,0,0,0,0,0,0})
		SZ5->(DbSkip())
	enddo

	aAdd(_aProgTT,{'007',0,0,0,0,0,0,0,0})      //Black Label - 007 para ordenação
	aAdd(_aProgTT,{'S_TF',0,0,0,0,0,0,0,0})     //destino TF
	aAdd(_aProgTT,{'S_TS',0,0,0,0,0,0,0,0})     //destino Salga
	aAdd(_aProgTT,{'S_CO',0,0,0,0,0,0,0,0})     //destino Conserva
	aAdd(_aProgTT,{'S_GR',0,0,0,0,0,0,0,0})     //destino Graxaria
	aAdd(_aProgTT,{'TOTAL',0,0,0,0,0,0,0,0})

	_aProgTT := aSort(_aProgTT,,,{|x,y| x[1] < y[1] } )

	//Fim da montagem do vetor de programas

	//Montagem dos vetores de categorias
	DbSelectArea('SZ5')
	SZ5->(DbSetOrder(1))
	SZ5->(DbGotop())
	while SZ5->(!eof())
		aAdd(_aCateTT,{alltrim(SZ5->Z5_COD),0,0,0,0,0,0,0,0})
		SZ5->(DbSkip())
	enddo

	aAdd(_aCateTT,{'TOTAL',0,0,0,0,0,0,0,0})

	_aCateTT := aSort(_aCateTT,,,{|x,y| x[1] < y[1]})

	//Fim da montagem do vetor de categorias

	dbSelectArea("SZ4")
	dbSetOrder(1)
	DbGoTop()
	if MsSeek(FWxfilial('SZ4') + mv_par01)
		While SZ4->(!eof()) .and. SZ4->Z4_FILIAL = FWxfilial('SZ4') .and. SZ4->Z4_NUMAM = mv_par01

			if SZ4->Z4_LOTE <= mv_par03 .or. SZ4->Z4_LOTE >= mv_par04
				SZ4->(DbSkip())
				loop
			endif
			_nQTLotes++
			SZ4->(DbSkip())
		enddo
	else
		alert('Aviso de Matança nao encontrado!')
		return
	endif

	SZ4->(DbGoTop())
	SZ4->(MsSeek(FWxfilial('SZ4') + mv_par01))

	SZ4->(SetRegua(_nQTLotes))

	While SZ4->(!EOF()) .and. SZ4->Z4_FILIAL = FWxfilial('SZ4') .and. SZ4->Z4_NUMAM = mv_par01

		_nCoLote := 0.00
		_nQTAnim := 0

		if SZ4->Z4_LOTE <= mv_par03 .or. SZ4->Z4_LOTE >= mv_par04
			SZ4->(DbSkip())
			loop
		endif

		//Laço de repetição para calcular o numero total de carcaças do lote
		SZK->(DbSetOrder(2))
		SZK->(DbGoTop())
		SZK->(MsSeek(FWxfilial('SZK') + SZ4->(Z4_NUMAM + Z4_LOTE)))

		while SZK->(!eof()) .and. SZK->(ZK_FILIAL + ZK_NUMAM + ZK_LOTE) = FWxfilial('SZK') + SZ4->(Z4_NUMAM + Z4_LOTE)
			//Calculo do numero de carcaças do lote
			_nQTAnim++
			SZK->(DbSkip())
		enddo
		//fim do laço para calcular o numero total de carcaças do lote

		//Busca valores da comissão
		SC7->(DBordernickname('C7NUMAMLOT'))
		SC7->(MsSeek(FWxFilial('SC7')+SZ4->(Z4_NUMAM + Z4_LOTE) ) )

		_nComis := 0.00

		While !SC7->(EOF()) .AND. FWxFilial('SC7')+SZ4->(Z4_NUMAM + Z4_LOTE) == SC7->(C7_FILIAL+C7_NUMAM+C7_LOTE)

			//Para não calcular comissão duplicada
			if AllTrim(SC7->C7_PCNOTA) <> 'SPED'
				SC7->(DbSkip())
				loop
			endif

			// Se for comprador "CENTRAL DE COMPRA DE GADO" não calcula comissão - IMPLEMENTADO EM 31/05/22
			If SC7->C7_COMPR == "000068"
				_nComis += 0
				//Calcula o total de comissão do dia
				_nCoDia += 0
				//Calcula total de comissao do lote
				_nCoLote += 0
			Else
				_nComis += SC7->C7_COMISS
				//Calcula o total de comissão do dia
				_nCoDia += SC7->C7_COMISS
				//Calcula total de comissao do lote
				_nCoLote += SC7->C7_COMISS
			EndIf

			SC7->(DbSkip())
		Enddo

		//Calculo de comissão por animal do lote
		_nCoAnim := _nCoLote/SZ4->Z4_QUANT

		//Fim da busca da comissão

		//Busca de dados do recebimento
		SZE->(DbSetOrder(2))
		if !SZE->(MsSeek(FWxfilial('SZE')+SZ4->(Z4_NUMAM + Z4_LOTE)))
			alert('Dados do recebimento nao encontrados para o lote ' + SZ4->Z4_LOTE + '!')
			return
		else
			//Processa dados do frete
			busca_frete(SZE->ZE_NUMERO)
			//Calcula o total de frete do dia
			_nFrDia  += _nValFre
			//Calcula o total de frete do lote
			_nFrLote += _nValFre
			//Calcula o custo de frete por animal
			_nFrAnim := _nFrLote/SZ4->Z4_QUANT
			//Calculo do custo de frete e comissao por kg
			_nClcFC := (_nValFre + _nComis)/_nPcarcF

			_cCodCateg := SZE->ZE_CATEG
			_cOrigem   := GetAdvFVal('SZD','ZD_MUN',FWxfilial('SZD')+SZE->ZE_NUMERO,1)
			_aCodProd  := GetAdvFVal('SZD',{'ZD_FORNECE','ZD_LOJA'},FWxfilial('SZD')+SZE->ZE_NUMERO,1)
			_cProdutor := GetAdvFVal('SA2','A2_NOME',FWxfilial('SA2')+_aCodProd[1]+_aCodProd[2],1)
			_cCodComp  := GetAdvFVal('SZA','ZA_COMPRA',FWxfilial('SZA')+SZE->ZE_NUMERO,3)
			_cTpCompr  := GetAdvFVal('SZA','ZA_TPCOM',FWxfilial('SZA')+SZE->ZE_NUMERO,3)
			_cCompr    := GetAdvFVal('SA3','A3_NOME',FWxfilial('SA3')+_cCodComp,1)
			_nPrecIni  := GetAdvFVal('SZ9','Z9_PRECO',FWxfilial('SZ9')+SZE->(ZE_NUMSC+ZE_ITEMSC),1)
			_nPesovivo := GetAdvFVal('SZR','ZR_PESO',FWxfilial('SZR')+SZE->(ZE_NUMERO+ZE_CATEG),1)
		endif

		if mv_par07 == 1
			if _cTpCompr <> 'R'
				SZ4->(DbSkip())
				loop
			endif
		elseif  mv_par07 == 2
			if _cTpCompr <> 'V'
				SZ4->(DbSkip())
				loop
			endif
		elseif  mv_par07 == 3
			MsgAlert(_cTpCompr)
			if _cTpCompr <> 'Q'
				SZ4->(DbSkip())
				loop
			endif
		endif

		//Bloco para processar carcaça por carcaça
		_nPcarcF   := 0
		_nPos      := 0
		_nPesoProc := 0.00
		_nPesFProc := 0.00

		SZK->(DbGoTop())
		SZK->(MsSeek(FWxfilial('SZK') + SZ4->(Z4_NUMAM + Z4_LOTE)))
		while SZK->(!eof()) .and. SZK->(ZK_FILIAL + ZK_NUMAM + ZK_LOTE) = FWxfilial('SZK') + SZ4->(Z4_NUMAM + Z4_LOTE)

			_cTpCom    := GetAdvFVal("SZE", "ZE_TPCOM", FWxFilial("SZE") + SZK->ZK_NUMAM + SZK->ZK_LOTE, 2)
			_nPeso     := SZK->ZK_PETOTAL
			_nPesoProc := ProcPeso(_npeso,SZK->ZK_IF,_cTpCom)
			_nPesFProc := ProcPesF(_npeso,SZK->ZK_IF)

			//Somatorio dos pesos processados
			_nPcarcF += _nPesoProc
			_nPcDia  += _nPesoProc
			//Processamento de carcaças por cobertura de gordura
			_nPos := aScan(_aGord,{|aVal|aVal[1] = alltrim(SZK->ZK_COBGOR)})

			if _nPos <> 0
				_aGord[_nPos,2]++                                  							  //Quantidade de animais
				_aGord[_nPos,3] += _nPesoProc                      							  //Peso liquido
				_aGord[_nPos,4] := _aGord[_nPos,3]/_aGord[_nPos,2] 							  //Peso médio
				//Valor no lote
				if _cTpCompr  = 'V'
					_aGord[_nPos,5] := _nPrecIni * _nPesovivo
				else
					_aGord[_nPos,5] += _nPesoProc * SZK->ZK_PRECOBO
				endif

				_aGord[_nPos,6] := iif(_cTpCompr  = 'V',_nPrecIni,_aGord[_nPos,5]/_aGord[_nPos,3]) 	//Custo por kg
				_aGordTT[_nPos,2]++                                  							  	//Quantidade de animais
				_aGordTT[_nPos,3] += _nPesFProc                      							  	//Peso liquido
				_aGordTT[_nPos,4] := _aGord[_nPos,3]/_aGord[_nPos,2] 							  	//Peso médio
				//Valor total
				if _cTpCompr  = 'V'
					_aGordTT[_nPos,5] := 0
				else
					_aGordTT[_nPos,5] += _nPesoProc * SZK->ZK_PRECOBO
				endif

				_aGordTT[_nPos,6] := iif(_cTpCompr = 'V',_nPrecIni,_aGord[_nPos,5]/_aGord[_nPos,3]) 				//Custo por kg
			endif
			//Fim do processamento de carcaças por gordura
			//Processamento de carcaças por programa por lote
			if (SZK->ZK_PROGPGP $ _cFPadrao)
				_cProg := '000'
			else
				_cProg := SZK->ZK_PROGPGP
			endif
			_nPos := aScan(_aProg,{|aVal|aVal[1] = _cProg})

			if _nPos <> 0
				_aProg[_nPos,2]++                                  					//Quantidade de animais
				_aProg[_nPos,3] += _nPesoProc                      					//Peso liquido
				_aProg[_nPos,4] := _aProg[_nPos,3]/_aProg[_nPos,2] 					//Peso médio
				//Valor total
				if _cTpCompr  = 'V'
					_aProg[_nPos,5] := _nPrecIni * _nPesovivo
				else
					_aProg[_nPos,5] += _nPesoProc * SZK->ZK_PRECOBO
				endif

				_aProg[_nPos,6] := iif(_cTpCompr  = 'V',_nPrecIni,_aProg[_nPos,5]/_aProg[_nPos,3]) 		//Custo por kg
			endif

			//Processamento de carcaças por programa total
			if SZK->ZK_DESTINO $ 'R/T/G'
				_cProg := iif(SZK->ZK_DESTINO = 'T','S_TF', iif(SZK->ZK_DESTINO = 'R','S_CO',iif(SZK->ZK_DESTINO = 'S','S_TS','S_GR')))
			elseif (SZK->ZK_PROGPGP $ _cFPadrao) .or. (SZK->ZK_PROGPGP = "019" .and. substr(SZK->ZK_COBGOR,1,1) = "1")
				_cProg := '000'
			elseif SZK->ZK_PROGPGP = "013"
				_cProg := 'S' + alltrim(SZK->ZK_CATEG)
			elseif SZK->ZK_BLACK = 'S'
				_cProg := '007'
			elseif !empty(SZK->ZK_PROGPGP)
				_cProg := SZK->ZK_PROGPGP
			else
				_cProg := 'S' + alltrim(SZK->ZK_CATEG)
			endif

			_nPos := aScan(_aProgTT,{|aVal|aVal[1] = _cProg})

			if _nPos <> 0
				_aProgTT[_nPos,2]++                                  						//Quantidade de animais
				_aProgTT[_nPos,3] += _nPesoProc                      						//Peso liquido
				_aProgTT[_nPos,4] := _aProgTT[_nPos,3]/_aProgTT[_nPos,2] 					//Peso médio
				//Valor total
				if _cTpCompr  = 'V'
					_aProgTT[_nPos,5] := _nPrecIni * _nPesovivo
				else
					_aProgTT[_nPos,5] += _nPesoProc * SZK->ZK_PRECOBO
				endif

				_aProgTT[_nPos,6] := iif(_cTpCompr  = 'V',_nPrecIni,_aProgTT[_nPos,5]/_aProgTT[_nPos,3]) 		//Custo por kg
				_aProgTT[_nPos,8] += iif(_cTpCompr  = 'V',0,_nFrAnim)                                           //Custo frete
				_aProgTT[_nPos,9] += iif(_cTpCompr  = 'V',0,_nCoAnim)                                           //Custo de comissão
			endif
			//fim do processamento de carcaças por programa
			//Processamento de carcaças por categoria
			_nPos  := aScan(_aCateTT,{|aVal|aVal[1] = SZK->ZK_CATEG})

			if _nPos <> 0
				_aCateTT[_nPos,2]++                                  							//Quantidade de animais
				_aCateTT[_nPos,3] += _nPesFProc                      							//Peso liquido
				_aCateTT[_nPos,4] := _aCateTT[_nPos,3]/_aCateTT[_nPos,2] 						//Peso médio
				//Valor total
				if _cTpCompr  = 'V'
					_aCateTT[_nPos,5] := _nPrecIni * _nPesovivo
				else
					_aCateTT[_nPos,5] += _nPesoProc * SZK->ZK_PRECOBO
				endif

				_aCateTT[_nPos,6] := iif(_cTpCompr  = 'V',_nPrecIni,_aCateTT[_nPos,5]/_aCateTT[_nPos,3])  	  //Custo por kg
			endif
			//fim do processamento de carcaças por programa
			//Processamento de carcaças por destino
			_nPos  := aScan(_aDestTT,{|aVal|aVal[1] = SZK->ZK_DESTINO})

			if _nPos <> 0
				_aDestTT[_nPos,2]++                                  							//Quantidade de animais
				_aDestTT[_nPos,3] += _nPesFProc                      							//Peso liquido
				_aDestTT[_nPos,4] := _aDestTT[_nPos,3]/_aDestTT[_nPos,2] 						//Peso médio
				//Valor total
				if _cTpCompr  = 'V'
					_aDestTT[_nPos,5] := _nPrecIni * _nPesovivo
				else
					_aDestTT[_nPos,5] += _nPesoProc * SZK->ZK_PRECOBO
				endif

				_aDestTT[_nPos,6] := iif(_cTpCompr  = 'V',_nPrecIni,_aDestTT[_nPos,5]/_aDestTT[_nPos,3]) 			//Custo por kg
			endif
			//fim do processamento de carcaças por programa

			SZK->(DbSkip())
		enddo

		//Busca dados dos registros de transporte por recebimento
		SZR->(DbSetOrder(1))
		if !SZR->(MsSeek(FWxfilial('SZR')+SZE->ZE_NUMERO + _cCodCateg))
			alert('Dados de transporte nao encontrados para o lote ' + SZ4->Z4_LOTE + '!')
			return
		else
			//Dados do transporte, exatamente igual ao fonte f_pcp022
			pesooriP   := PesoProp(SZE->ZE_NUMERO,SZE->ZE_CATEG, If(Empty(SZE->ZE_RASTRO),'N','S'))
			_nPesoProp := pesooriP - iif(pesooriP > 0, (((SZ4->Z4_NPREN-SZ4->Z4_NPREAD)*nPesPren)+(SZ4->Z4_NPREAD*nPesPread)), 0)
			pesooriF   := PesoFrig(SZE->ZE_NUMERO,SZE->ZE_CATEG, If(Empty(SZE->ZE_RASTRO),'N','S'))
			_nPercQ    := pesooriF/iif(_nPesoProp > 0.0, _nPesoProp, 1.0)
			_nPercQ    := iif(_nPercQ > 0 .and. _nPercQ < 1, _nPercQ, 1.0)
			_nPesoFrig  := pesooriF - iif(pesooriF > 0, (((SZ4->Z4_NPREN-SZ4->Z4_NPREAD)*(nPesPren*_nPercQ))+(SZ4->Z4_NPREAD*(nPesPread*_nPercQ))), 0)
			//Calculo dos rendimentos
			//peso origem
			If _nPesoProp > 0
				_rendOri := ((_nPcarcF)/_nPesoProp) * 100   //Rendimento origem
			Else
				_rendOri := 0
			Endif
			//peso frigorifico
			If _nPesoFrig > 0
				_rendFrig := (_nPCarcF)/_nPesoFrig * 100  //Rendimento propriedade
			Else
				_rendFrig := 0
			Endif

			//Calculo do percentual da quebra por tranporte
			_nQuebra := iif(_nPesoProp <> 0, (((_nPesoFrig/_nPesoProp) * 100) - 100)*(-1),0)
			_nQuebra := iif(_nQuebra > 0,_nQuebra,0)
		endif
		//Fim de busca de dados dos registros de transporte por recebimento

		//Laço para calculo do custo final por kg por cobertura de gordura
		/*for i:= 1 to len(_aGord)
			//Calculo do custo de comissao e do frete por gordura
			_nClcFCGord := _aGord[i,3] * _nClcFC
			_aGord[i,7] := (_aGord[i,5] + _nClcFCGord)/_aGord[i,3]        //Custo final por kg
		next*/

		//Fim do bloco para processar carcaça por carcaça
		//Fim da busca de dados do recebimento
		//Processamento do custo de comissão e frete por categoria
		_nPos := aScan(_aCateTT,{|aVal|aVal[1] = _cCodCateg})

		if _nPos <> 0
			_aCateTT[_nPos,8] += _nCoLote  //Acumulador de comissão
			_aCateTT[_nPos,9] += _nFrLote  //Acumulador de frete
		endif
		//Zera acumuladores a cada lote
		_nCoLote := 0
		_nFrLote := 0
		//Fim do processamento do custo de comissao por categoria
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin + 16 > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		@nlin,000 psay replicate('-',220)
		nlin++
		@nlin,000 psay '|Lote:                  ' + SZ4->Z4_LOTE
		@nlin,052 psay '|Produtor: ' + substr(_cProdutor,1,35)
		@nlin,100 psay '|Origem: ' + alltrim(_cOrigem)

		If _cTpCom == "Q"
			@nlin,145 psay '|Quente'
		Else
			@nlin,147 psay '|Fria'
		Endif

		@nlin,152 psay '|Comprador: ' + alltrim(_cCompr)
		nlin++
		@nlin,000 psay replicate('-',220)
		nlin++
		@nlin,000 psay '|Categoria:             ' + alltrim(SZ4->Z4_DESCAT)
		//@nlin,052 psay '|Quant. Veiculos (un):  ' + transform(_nVeic,'@E 999,999')
		@nlin,052 psay '|Peso liq. origem (kg): ' + transform(_nPesoProp,'@E 999,999.99')
		@nlin,100 psay '|Rendimento de Origem:  ' + transform(_rendOri,'@E 999,999.99')
		@nlin,152 psay '|Preço Inicial (R$):    ' + transform(_nPrecIni,'@E 999,999.99')
		nlin++
		@nlin,000 psay '|Qtd. Animais (cab):    ' + transform(_nQTAnim,'@E 99,999,999')
		//@nlin,052 psay '|Quilometragem (km):    ' + transform(_nKm,'@E 999,999')
		@nlin,052 psay '|Peso liq. frigo. (kg): ' + transform(_nPesoFrig,'@E 999,999.99')
		@nlin,100 psay '|Rendimento Frigorifico:' + transform(_rendFrig,'@E 999,999.99')
		@nlin,152 psay '|Tipo de Compra:        ' + iif(_cTpCompr = 'V','Vivo',iif(_cTpCompr = 'F','Fechado','Rendimento'))
		nlin++
		@nlin,000 psay '|Peso Carc. Quente (kg):' + transform(_nPcarcF,'@E 999,999.99')
		//@nlin,052 psay '|Valor Frete (R$):      ' + transform(_nValFre,'@E 999,999.99')
		@nlin,052 psay '|Quilometragem (km):    ' + transform(round((_nKm/_nVeic),0),'@E 99,999,999')
		@nlin,100 psay '|Quebra Transp.(%):     ' + transform(_nQuebra,'@E 999,999.99')
		@nlin,152 psay '|Comissão (R$):         ' + transform(_nComis,'@E 999,999.99')
		nlin++
		@nlin,000 psay replicate('-',220)
		nLin++
		@nlin,008 psay "Programa           Nº.Animais         Peso Liquido              Peso Medio          "+;
			"Valor Lote                   Custo kg     |        Gordura        		Nº.Animais"
		nLin++

		//Limpeza de itens vazios dos arrays
		i := 1
		while i <= len(_aGord)
			if _aGord[i,2] <= 0
				aDel(_aGord, i)
				aSize(_aGord, (len(_aGord) - 1))
			else
				i++
			endif
		end
		i := 1
		while i <= len(_aProg)
			if _aProg[i,2] <= 0 .and. _aProg[i,1] != 'T'
				aDel(_aProg, i)
				aSize(_aProg, (len(_aProg) - 1))
			else
				i++
			endif
		end

		_nPos  := aScan(_aProg,{|aVal|aVal[1] = 'T'})
		for i := 1 to len(iif(Len(_aGord) > (Len(_aProg)-1), _aGord, _aProg))

			if i <= len(_aProg)
				if _aProg[i,1] != 'T'
					@nlin,005 psay iif(_aProg[i,1] = "000","fora do padrão",lower(alltrim(GetAdvFVal("SZ6","Z6_DESC",FWxFilial("SZ6")+_aProg[i,1],1))))
					@nlin,030 psay transform(_aProg[i,2],'@E 999')
					@nlin,045 psay transform(_aProg[i,3],'@E 9,999,999.99')
					@nlin,070 psay transform(_aProg[i,4],'@E 9,999,999.99')
					@nlin,090 psay transform(iif(_cTpCompr  = 'R',_aProg[i,5],0),'@E 9,999,999.99')
					@nlin,117 psay transform(_aProg[i,6],'@E 9,999,999.99')
				endif
			endif
			@nlin,134 psay "|"
			if i <= len(_aGord)
				@nlin,145 psay _aGord[i,1]
				@nlin,159 psay transform(_aGord[i,2],'@E 999')
			endif
			nlin++

			if i <= len(_aProg)
				if _aProg[i,1] != 'T'
					_aProg[_nPos,2] += _aProg[i,2]
					_aProg[_nPos,3] += _aProg[i,3]
					_aProg[_nPos,4] := _aProg[_nPos,3]/_aProg[_nPos,2]

					if _cTpCompr = 'V'
						if _aProg[_nPos,5] = 0
							_aProg[_nPos,5] := _aProg[i,5]
						endif
						//_aProg[_nPos,7]  := (_nValFre + _nComis + _aProg[_nPos,5])
					else
						_aProg[_nPos,5] += _aProg[i,5]
						//_aProg[_nPos,7] += (_aProg[i,7]*_aProg[i,3])
					endif

					_aProg[_nPos,6] += (_aProg[i,6]*_aProg[i,3])
				endif
			endif
		next

		@nlin,000 psay '|Totais/Medias:'
		@nlin,030 psay transform(_aProg[_nPos,2],'@E 999')
		@nlin,045 psay transform(_aProg[_nPos,3],'@E 9,999,999.99')
		@nlin,070 psay transform(_aProg[_nPos,4],'@E 9,999,999.99')
		@nlin,090 psay transform(_aProg[_nPos,5],'@E 9,999,999.99')
		@nlin,117 psay transform(_aProg[_nPos,6]/_aProg[_nPos,3],'@E 9,999,999.99')
		@nlin,134 psay "|"
		//@nlin,142 psay transform(_aProg[_nPos,7]/_aProg[_nPos,3],'@E 9,999,999.99')
		//Zera vetor de gorduras e programas por lote
		_aGord := {{'1',0,0,0,0,0},{'2',0,0,0,0,0},{'2+',0,0,0,0,0},{'3',0,0,0,0,0},{'4',0,0,0,0,0},{'5',0,0,0,0,0}}
		_aProg := {{'000',0,0,0,0,0},{'001',0,0,0,0,0},{'002',0,0,0,0,0},{'005',0,0,0,0,0},{'006',0,0,0,0,0},{'008',0,0,0,0,0},{'013',0,0,0,0,0},{'019',0,0,0,0,0},{'020',0,0,0,0,0},{'T',0,0,0,0,0}}
		nlin++
		@nlin,000 psay replicate('-',220)
		nLin++

		SZ4->(dbSkip())
	EndDo
	//Calculo do custo de frete e comissao por kg do dia
	//Usa a mesma variavel _nClcFC, não dá nada!
	_nClcFC := (_nFrDia + _nCoDia)/_nPcDia
	//Laço para calculo do custo final por kg  por cobertura de gordura
	for i:= 1 to len(_aGordTT)
		//Calculo do custo de comissao e do frete por gordura do dia
		//Usa a mesma variavel _nClcFCGord, não dá nada!
		_nClcFCGord := _aGordTT[i,3] * _nClcFC
		_aGordTT[i,7] := 	iif(_cTpCompr = 'V',0,(_aGordTT[i,5] + _nClcFCGord)/_aGordTT[i,3])        //Custo final por kg do dia
	next
	//Laço para calculo do custo final por kg  por programa
	for i:= 1 to len(_aProgTT)
		_nClcFCProg   := _aProgTT[i,3] * _nClcFC
		_aProgTT[i,7] := iif(_cTpCompr = 'V',0,(_aProgTT[i,5] + _nClcFCProg)/_aProgTT[i,3])        //Custo final por kg do dia
	next
	//Laço para calculo do custo final por kg  por categoria
	for i:= 1 to len(_aCateTT)
		_nClcFCCate := _aCateTT[i,3] * _nClcFC
		_aCateTT[i,7] := iif(_cTpCompr = 'V',0,(_aCateTT[i,5] + _nClcFCCate)/_aCateTT[i,3])        //Custo final por kg do dia
	next
	//Laço para calculo do custo final por kg  por destino
	for i:= 1 to len(_aDestTT)
		_nClcFCDest := _aDestTT[i,3] * _nClcFC
		_aDestTT[i,7] := iif(_cTpCompr = 'V',0,(_aDestTT[i,5] + _nClcFCDest)/_aDestTT[i,3])        //Custo final por kg do dia
	next

	Titulo := "TOTAL GERAL POR CLASSES"
	Cabec1 :=  "|     Classe       |     Nº.Animais   |     Peso Liquido    "+;
		"|     Peso Medio      |     Valor Lote       |     Custo kg        |     Custo Final kg     |     Custo Total"

	Cabec2 :=  "|                  |   (cabeças)      |       (kg)          "+;
		"|        (kg)         |        (R$)          |        (R$)         |          (R$)          |        (R$)

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9
	@nlin,000 psay '| POR GORDURA'
	nlin++

	for i := 1 to len(_aGordTT)
		@nlin,009 psay _aGordTT[i,1]
		@nlin,027 psay transform(_aGordTT[i,2],'@E 999')
		@nlin,042 psay transform(_aGordTT[i,3],'@E 9,999,999.99')
		@nlin,065 psay transform(_aGordTT[i,4],'@E 9,999,999.99')
		@nlin,087 psay transform(_aGordTT[i,5],'@E 9,999,999.99')
		@nlin,110 psay transform(_aGordTT[i,6],'@E 9,999,999.99')
		@nlin,133 psay transform(_aGordTT[i,7],'@E 9,999,999.99')
		@nlin,157 psay transform(_aGordTT[i,3] * _aGordTT[i,7],'@E 999,999,999.99')
		nlin++
	next

	@nlin,000 psay replicate('-',220)
	nLin++
	@nlin,000 psay '| POR PROGRAMA'
	nlin++
	_nPosT := aScan(_aProgTT,{|aVal|aVal[1] = 'TOTAL'})

	for i := 1 to len(_aProgTT)

		if substr(_aProgTT[i,1],1,1) <> 'S' //.and. _aProgTT[i,1] != "S003"
			_cList   := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
			_cDescri := lower(GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6')+_aProgTT[i,1],1))
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
			_cDescri := 'saldo '+lower(GetAdvFVal('SZ5','Z5_DESC',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1))
		endif

		if _aProgTT[i,1] $ 'S_TF/S_CO/S_GR/007'
			_cDescri := iif(_aProgTT[i,1] = 'S_TF','san. TF',iif(_aProgTT[i,1] = 'S_CO','san. Conserva',iif(_aProgTT[i,1] = 'S_GR','san. Graxaria',iif(_aProgTT[i,1] = 'S_TS','san. Salga','black label'))))
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000' .or.  _aProgTT[i,1] $ 'S_TF/S_CO/S_GR/007'

			_aProgTT[_nPosT,2] += _aProgTT[i,2]                         //Quantidade de animais
			_aProgTT[_nPosT,3] += _aProgTT[i,3]                         //Peso liquido
			_aProgTT[_nPosT,4] := _aProgTT[_nPosT,3]/_aProgTT[_nPosT,2] //peso medio
			_aProgTT[_nPosT,5] += _aProgTT[i,5]                         //Valor total
			_aProgTT[_nPosT,6] := _aProgTT[_nPosT,5]/_aProgTT[_nPosT,3] //Custo médio kg
			_aProgTT[_nPosT,8] += _aProgTT[i,3] * _aProgTT[i,7]         //Custo total
			_aProgTT[_nPosT,7] := _aProgTT[_nPosT,8]/_aProgTT[_nPosT,3]	//custo final kg
			//_aCateTT[_nPosT,8] += _aCateTT[i,3] * _aCateTT[i,7]         //Custo total
			//_aCateTT[_nPosT,7] := _aCateTT[_nPosT,8]/_aCateTT[_nPosT,3]	//custo final kg
			//_nPesMedCateg      := _aCateTT[_nPosT,4]
			//
			////Valor total
			//if _cTpCompr  = 'V'
			//	if _aProgTT[_nPosT,8] <> 0
			//		_aProgTT[_nPosT,8] := _aProgTT[i,5]
			//	endif
			//else
			//	_aProgTT[_nPosT,8] += _aProgTT[i,5]
			//endif
			////Custo total
			//if _cTpCompr  = 'V'
			//	_aProgTT[_nPosT,8] := _aProgTT[i,3] * _aProgTT[i,7]
			//else
			//	_aProgTT[_nPosT,8] += _aProgTT[i,3] * _aProgTT[i,7]
			//endif
			if _aProgTT[i,2] > 0
				@nlin,009 psay substr(iif(_aProgTT[i,1] = '000','fora do padrao',_cDescri),1,15)
				@nlin,027 psay transform(_aProgTT[i,2],'@E 999')
				@nlin,042 psay transform(_aProgTT[i,3],'@E 9,999,999.99')
				@nlin,065 psay transform(_aProgTT[i,4],'@E 9,999,999.99')
				@nlin,087 psay transform(_aProgTT[i,5],'@E 9,999,999.99')
				@nlin,110 psay transform(_aProgTT[i,6],'@E 9,999,999.99')
				@nlin,133 psay transform(_aProgTT[i,7],'@E 9,999,999.99')
				@nlin,157 psay transform(_aProgTT[i,3] * _aProgTT[i,7],'@E 999,999,999.99')
				nlin++
			endif
		endif
	next

	@nlin,009 psay 'Total'
	@nlin,027 psay transform(_aProgTT[_nPosT,2],'@E 999')
	@nlin,042 psay transform(_aProgTT[_nPosT,3],'@E 9,999,999.99')
	@nlin,065 psay transform(_aProgTT[_nPosT,4],'@E 9,999,999.99')
	@nlin,087 psay transform(_aProgTT[_nPosT,5],'@E 9,999,999.99')
	@nlin,110 psay transform(_aProgTT[_nPosT,6],'@E 9,999,999.99')
	@nlin,133 psay transform(_aProgTT[_nPosT,7],'@E 9,999,999.99')
	@nlin,157 psay transform(_aProgTT[_nPosT,8],'@E 999,999,999.99')
	nlin++

	@nlin,000 psay replicate('-',220)
	nLin++
	@nlin,000 psay '| POR CATEGORIA'
	nlin++
	_nPosT := aScan(_aCateTT,{|aVal|aVal[1] = 'TOTAL'})

	for i := 1 to len(_aCateTT)
		_cList := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+_aCateTT[i,1],1)
		if _cList = 'S'

			_aCateTT[_nPosT,2] += _aCateTT[i,2]                         //Quantidade de animais
			_aCateTT[_nPosT,3] += _aCateTT[i,3]                         //Peso liquido
			_aCateTT[_nPosT,4] := _aCateTT[_nPosT,3]/_aCateTT[_nPosT,2] //peso medio
			_aCateTT[_nPosT,5] += _aCateTT[i,5]                         //Valor total
			_aCateTT[_nPosT,6] := _aCateTT[_nPosT,5]/_aCateTT[_nPosT,3] //Custo médio kg
			_aCateTT[_nPosT,8] += _aCateTT[i,3] * _aCateTT[i,7]         //Custo total
			_aCateTT[_nPosT,7] := _aCateTT[_nPosT,8]/_aCateTT[_nPosT,3]	//custo final kg
			_nPesMedCateg      := _aCateTT[_nPosT,4]

			@nlin,009 psay alltrim(lower(GetAdvFVal('SZ5','Z5_DESC',FWxfilial('SZ5')+_aCateTT[i,1],1)))
			@nlin,027 psay transform(_aCateTT[i,2],'@E 999')
			@nlin,042 psay transform(_aCateTT[i,3] / 0.98,'@E 9,999,999.99')
			@nlin,065 psay transform(_aCateTT[i,4],'@E 9,999,999.99')
			@nlin,087 psay transform(_aCateTT[i,5],'@E 9,999,999.99')
			@nlin,110 psay transform(_aCateTT[i,6],'@E 9,999,999.99')
			@nlin,133 psay transform(_aCateTT[i,7],'@E 9,999,999.99')
			@nlin,157 psay transform(_aCateTT[i,3] * _aCateTT[i,7],'@E 999,999,999.99')
			nlin++
		endif
	next

	@nlin,009 psay 'Total'
	@nlin,027 psay transform(_aCateTT[_nPosT,2],'@E 999')
	@nlin,042 psay transform(_aCateTT[_nPosT,3] / 0.98,'@E 9,999,999.99')
	@nlin,065 psay transform(_aCateTT[_nPosT,4] / 0.98,'@E 9,999,999.99')
	@nlin,087 psay transform(_aCateTT[_nPosT,5],'@E 9,999,999.99')
	@nlin,110 psay transform(_aCateTT[_nPosT,6] * 0.98,'@E 9,999,999.99')
	@nlin,133 psay transform(_aCateTT[_nPosT,7] * 0.98,'@E 9,999,999.99')
	@nlin,157 psay transform(_aCateTT[_nPosT,8],'@E 999,999,999.99')
	nlin++

	//Chamada de Ã­ndices de rentabilidade cadastrados
	DbSelectArea('SZQ')
	SZQ->(DbSetOrder(2))
	SZQ->(MsSeek(FWxfilial('SZQ')+mv_par02))

	@nlin,000 psay replicate('-',220)
	nLin++

	@nlin,000 psay '| ANALISE DE RENTABILIDADE - DESPESAS'
	nlin++
	/*
	@nlin,000 psay '|Por Categoria:'
	//Impressão dos cabeçalho das categorias
	_nCol := 28
	for i := 1 to len(_aCateTT)
	_cList := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aCateTT[i,1],'Z5_LISTA')
		if _cList = 'S'
	@nlin,_nCol psay alltrim(lower(GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aCateTT[i,1],'Z5_DESC')))
	_nCol+=15
		endif
	next
	@nlin,195 psay 'Total'
	nlin++
	//Impressao dos valores de compra de animais  por categoria
	@nlin,000 psay '|Compra:'

	_nTotal := 0.00

	_nCol := 25
	for i := 1 to len(_aCateTT)
	_cList := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aCateTT[i,1],'Z5_LISTA')
		if _cList = 'S'
	@nlin,_nCol psay transform(_aCateTT[i,3] * _aCateTT[i,6],'@E 999,999,999.99')

	_nTotal += _aCateTT[i,3] * _aCateTT[i,6]

	_nCol+=15

	//Construção do vetor de despesas
	_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aCateTT[i,1]})
			if _nPos <> 0
	_aTotDes[_nPos,2] += _aCateTT[i,3] * _aCateTT[i,6]
			else
	aAdd(_aTotDes,{_aCateTT[i,1],_aCateTT[i,3] * _aCateTT[i,6]})
			endif
		endif
	next

	@nlin, 195 psay transform(_nTotal, '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de frete por categoria
	@nlin,000 psay '|Frete:'
	_nTotal := 0.00
	_nCol := 25
	for i := 1 to len(_aCateTT)
	_cList := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aCateTT[i,1],'Z5_LISTA')
		if _cList = 'S'
	@nlin,_nCol psay transform(_aCateTT[i,9],'@E 999,999.99')

	_nTotal += _aCateTT[i,9]

	_nCol+=15

	//Construção do vetor de despesas
	_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aCateTT[i,1]})
			if _nPos <> 0
	_aTotDes[_nPos,2] += _aCateTT[i,9]
			else
	aAdd(_aTotDes,{_aCateTT[i,1],_aCateTT[i,9]})
			endif
		endif
	next

	@nlin,195 psay transform(_nTotal, '@E 999,999,999.99')

	nlin++

	//Impressão dos valores de comissão por categoria
	@nlin,000 psay '|Comissao:'

	_nTotal := 0.00

	_nCol := 25
	for i := 1 to len(_aCateTT)
	_cList := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aCateTT[i,1],'Z5_LISTA')
		if _cList = 'S'
	@nlin,_nCol psay transform(_aCateTT[i,8],'@E 999,999.99')

	_nTotal += _aCateTT[i,8]

	_nCol+=15

	//Construção do vetor de despesas
	_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aCateTT[i,1]})
			if _nPos <> 0
	_aTotDes[_nPos,2] += _aCateTT[i,8]
			else
	aAdd(_aTotDes,{_aCateTT[i,1],_aCateTT[i,8]})
			endif
		endif
	next

	@nlin, 195 psay transform(_nTotal, '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de Custo do abate por categoria
	@nlin,000 psay '|C.Abate('+alltrim(transform(SZQ->ZQ_VLRDESP,'@E 999,999.99'))+'):'

	_nTotal := 0

	_nCol := 25
	for i := 1 to len(_aCateTT)
	_cList := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aCateTT[i,1],'Z5_LISTA')
		if _cList = 'S'
	@nlin,_nCol psay transform(_aCateTT[i,2] * SZQ->ZQ_VLRDESP,'@E 999,999.99')
	_nCol+=15

	_nTotal += _aCateTT[i,2] * SZQ->ZQ_VLRDESP

	//Construção do vetor de despesas por categoria
	_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aCateTT[i,1]})
			if _nPos <> 0
	_aTotDes[_nPos,2] += _aCateTT[i,2] * SZQ->ZQ_VLRDESP
			else
	aAdd(_aTotDes,{_aCateTT[i,1],_aCateTT[i,2] * SZQ->ZQ_VLRDESP})
			endif
		endif
	next

	@nlin, 195 psay transform(_nTotal, '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de Credito de compra por categoria
	@nlin,000 psay '|% Cred.Comp.('+alltrim(transform(SZQ->ZQ_CREDIT,'@E 999.99'))+'):'

	_nTotal := 0

	_nCol := 25
	for i := 1 to len(_aCateTT)
	_cList := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aCateTT[i,1],'Z5_LISTA')
		if _cList = 'S'
	_nImp := (_aCateTT[i,3] * _aCateTT[i,6])* (SZQ->ZQ_CREDIT/100)
	@nlin,_nCol psay transform(_nImp,'@E 999,999.99')
	_nCol+=15

	_nTotal += _nImp

	//Construção do vetor de despesas por categoria
	_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aCateTT[i,1]})
			if _nPos  <> 0
	_aTotDes[_nPos,2] -= _nImp
			else
	aAdd(_aTotDes,{_aCateTT[i,1],_nImp*(-1)})
			endif
		endif
	next

	@nlin, 195 psay transform(_nTotal, '@E 999,999,999.99')

	nlin++

	//Impressao dos totais de despesas por categoria
	@nlin,000 psay '|TOTAIS:'

	_ntotal := 0

	_nCol := 25

	for i := 1 to len(_aTotDes)
	@nlin,_nCol psay transform(_aTotDes[i,2],'@E 999,999.99')
	_nCol+=15
	_nTotal += _aTotDes[i,2]
	next

	@nlin,195 psay transform(_nTotal, '@E 999,999,999.99')

	nlin+=2

	_aTDCate := _aTotDes
	//Analise de rendimento por programas

	_aTotDes := {}

	@nlin,000 psay '|Por Programa:'
	*/

	//Impressão dos cabeçalho dos programas
	// _nCol := 25
	// for i := 1 to len(_aProgTT)
	// if substr(_aProgTT[i,1],1,1) <> 'S'
	// 	_cList   := GetAdvFVal('SZ6',1,FWxfilial('SZ6')+_aProgTT[i,1],'Z6_LISTA')
	// 	_cDescri := lower(GetAdvFVal('SZ6',1,FWxfilial('SZ6')+_aProgTT[i,1],'Z6_DESC'))
	// else
	// 	_cList   := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),'Z5_LISTA')
	// 	_cDescri := 'saldo '+lower(GetAdvFVal('SZ5',1,FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),'Z5_DESC'))
	// endif

	// if _aProgTT[i,1] $ 'S_TF/S_CO'
	// 	_cDescri := iif(_aProgTT[i,1] = 'S_CO',substr('san. Conserva',1,10),substr('san. TF',1,10))
	// endif

	//Impressão dos cabeçalho dos programas
	_nCol := 25
	for i := 1 to len(_aProgTT)
		if _cList = 'S' .or. _aProgTT[i,1] = '000' .or. _aProgTT[i,1] $ 'S_TF/S_CO/S_GR/007'
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Fora do Padrao',_cDescri)
			_nCol+=18
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Hereford',_cDescri)
			_nCol+=18
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Angus',_cDescri)
			_nCol+=12
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Black Label',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Touruno',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Touro',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Novilho',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Saldo Macho',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Saldo Fêmea',_cDescri)
			_nCol+=15
			//@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Saldo Touro',_cDescri)
			//_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','San. Conse',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','San. Grax',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','San. TF',_cDescri)
			@nlin,210 psay "Total"
		endif
	next

	nlin++
	//Impressao dos valores de compra de animais  por programa
	@nlin,000 psay '|Compra:'

	_nTotal := 0.00

	_nCol := 20
	for i := 1 to len(_aProgTT)
		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000' .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			If _aProgTT[i,1] != 'S_TS'
				if _aProgTT[i,1] = 'S_CO'
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_aProgTT[i,3] * _aProgTT[i,6])+(_aProgTT[i+3,3] * _aProgTT[i+3,6])),'@E 999,999,999.99')
				else
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,_aProgTT[i,3] * _aProgTT[i,6]),'@E 999,999,999.99')
				endif
				_nCol+=15
			EndIf
			_nTotal += _aProgTT[i,3] * _aProgTT[i,6]

			//Construção do vetor de despesas
			_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aProgTT[i,1]})
			if _nPos <> 0
				_aTotDes[_nPos,2] += _aProgTT[i,3] * _aProgTT[i,6]
			else
				aAdd(_aTotDes,{_aProgTT[i,1],_aProgTT[i,3] * _aProgTT[i,6]})
			endif
		endif
	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal), '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de frete por programa
	@nlin,000 psay '|Frete:'
	_nTotal := 0.00
	_nCol := 20
	for i := 1 to len(_aProgTT)
		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList   := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		/* Cálculo  do valor individual do animal */
		_nVunit := (SZQ->ZQ_VLRFRET/_aCateTT[_nPosT,2])
		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			If _aProgTT[i,1] != 'S_TS'
				if _aProgTT[i,1] = 'S_CO'
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nVunit * _aProgTT[i,2])+(_nVunit * _aProgTT[i+3,2])),'@E 999,999,999.99')
				else
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nVunit * _aProgTT[i,2])),'@E 999,999,999.99')
				endif
				_nCol+=15
			EndIf

			//Construção do vetor de despesas
			_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aProgTT[i,1]})
			if _nPos <> 0
				_aTotDes[_nPos,2] += _nVunit * _aProgTT[i,2]
			else
				aAdd(_aTotDes,{_aProgTT[i,1],_nVunit * _aProgTT[i,2]})
			endif
		endif
	next

	@nlin,205 psay transform(iif(_cTpCompr = 'V',0,SZQ->ZQ_VLRFRET), '@E 999,999,999.99')

	nlin++

	//Impressão dos valores de comissão por programa
	@nlin,000 psay '|Comissão:'

	_nTotal := 0.00

	_nCol := 20
	for i := 1 to len(_aProgTT)
		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList   := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'

			If _aProgTT[i,1] != 'S_TS'
				if _aProgTT[i,1] = 'S_CO'
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_aProgTT[i,9])+(_aProgTT[i+3,9])),'@E 999,999,999.99')
				else
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_aProgTT[i,9])),'@E 999,999,999.99')
				endif
				_nCol+=15
			EndIf

			_nTotal += _aProgTT[i,9]

			//Construção do vetor de despesas
			_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aProgTT[i,1]})
			if _nPos <> 0
				_aTotDes[_nPos,2] += _aProgTT[i,9]
			else
				aAdd(_aTotDes,{_aProgTT[i,1],_aProgTT[i,9]})
			endif
		endif
	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal), '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de Bonus ABA por programa
	@nlin,000 psay '|B.ABA('+alltrim(transform(SZQ->ZQ_ABA,'@E 999,999,999.99'))+'):'
	_nTotal := 0.00

	_nCol := 20
	for i := 1 to len(_aProgTT)

		_nBonus := 0.00

		if _aProgTT[i,1] = '006'
			_nBonus := _aProgTT[i,3] * SZQ->ZQ_ABA
			_nTotal += _nBonus
			//Construção do vetor de despesas
			_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aProgTT[i,1]})
			if _nPos <> 0
				_aTotDes[_nPos,2] += _nBonus
			else
				aAdd(_aTotDes,{_aProgTT[i,1],_nBonus})
			endif
		endif

		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList   := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			If _aProgTT[i,1] != 'S_TS'
				@nlin,_nCol psay transform(_nBonus,'@E 999,999,999.99')
				_nCol+=15
			EndIf
		endif
	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal), '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de Bonus ABB por programa
	@nlin,000 psay '|B.ABB('+alltrim(transform(SZQ->ZQ_ABB,'@E 999,999,999.99'))+'):'

	_nTotal := 0.00

	_nCol := 20

	for i := 1 to len(_aProgTT)
		_nBonus := 0.00

		if _aProgTT[i,1] = '011'
			_nBonus := _aProgTT[i,3] * SZQ->ZQ_ABB
			_nTotal += _nBonus
			//Construção do vetor de despesas
			_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aProgTT[i,1]})
			if _nPos <> 0
				_aTotDes[_nPos,2] += _nBonus
			else
				aAdd(_aTotDes,{_aProgTT[i,1],_nBonus})
			endif
		endif

		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList   := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			If _aProgTT[i,1] != 'S_TS'
				@nlin,_nCol psay transform(_nBonus,'@E 999,999,999.99')
				_nCol+=15
			EndIf
		endif
	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal), '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de Bonus ABHB por programa
	@nlin,000 psay '|B.ABHB('+alltrim(transform(SZQ->ZQ_ABHB,'@E 999,999,999.99'))+'):'
	_nTotal := 0.00

	_nCol := 20

	for i := 1 to len(_aProgTT)
		_nBonus := 0.00
		if _aProgTT[i,1] = '002'
			_nBonus := _aProgTT[i,3] * SZQ->ZQ_ABHB
			_nTotal += _nBonus
			//Construção do vetor de despesas
			_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aProgTT[i,1]})
			if _nPos <> 0
				_aTotDes[_nPos,2] += _nBonus
			else
				aAdd(_aTotDes,{_aProgTT[i,1],_nBonus})
			endif
		endif

		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList   := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			If _aProgTT[i,1] != 'S_TS'
				@nlin,_nCol psay transform(_nBonus,'@E 999,999,999.99')
				_nCol+=15
			EndIf
		endif

	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal), '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de Custo do abate por programa
	@nlin,000 psay '|C.Abate('+alltrim(transform(SZQ->ZQ_VLRDESP,'@E 999,999,999.99'))+'):'
	_nTotal := 0
	_nCol := 20
	for i := 1 to len(_aProgTT)
		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList   := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			If _aProgTT[i,1] != 'S_TS'
				if _aProgTT[i,1] = 'S_CO'
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_aProgTT[i,2] * SZQ->ZQ_VLRDESP)+(_aProgTT[i+3,2] * SZQ->ZQ_VLRDESP)),'@E 999,999,999.99')
				else
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_aProgTT[i,2] * SZQ->ZQ_VLRDESP)),'@E 999,999,999.99')
				endif
				_nCol+=15
			EndIf

			_nTotal += _aProgTT[i,2] * SZQ->ZQ_VLRDESP

			//Construção do vetor de despesas por categoria
			_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aProgTT[i,1]})
			if _nPos <> 0
				_aTotDes[_nPos,2] += _aProgTT[i,2] * SZQ->ZQ_VLRDESP
			else
				aAdd(_aTotDes,{_aProgTT[i,1],_aProgTT[i,2] * SZQ->ZQ_VLRDESP})
			endif
		endif
	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal), '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de credito de compra por programa
	@nlin,000 psay '|% Cred.Comp.('+alltrim(transform(SZQ->ZQ_CREDIT,'@E 999,999,999.99'))+'):'

	_nTotal := 0

	_nCol := 20
	for i := 1 to len(_aProgTT)
		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList   := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			_nImp := (_aProgTT[i,3] * _aProgTT[i,6]) * (SZQ->ZQ_CREDIT/100)

			If _aProgTT[i,1] != 'S_TS'
				if _aProgTT[i,1] = 'S_CO'
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nImp)+((_aProgTT[i+3,3]*_aProgTT[i+3,6])*(SZQ->ZQ_CREDIT/100))),'@E 999,999,999.99')
				else
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,_nImp),'@E 999,999,999.99')
				endif
				_nCol+=15
			EndIf

			_nTotal += _nImp

			//Construção do vetor de despesas por categoria
			_nPos := aScan(_aTotDes,{|aVal|aVal[1] = _aProgTT[i,1]})
			if _nPos  <> 0
				_aTotDes[_nPos,2] -= _nImp
			else
				aAdd(_aTotDes,{_aProgTT[i,1],_nImp*(-1)})
			endif
		endif

	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal), '@E 999,999,999.99')

	nlin++

	//Impressao dos totais de despesas por categoria
	@nlin,000 psay '|TOTAIS:'

	_ntotal := 0

	_nCol := 20


	for i := 1 to len(_aTotDes)

		@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,_aTotDes[i,2]),'@E 999,999,999.99')
		_nCol+=15
		_nTotal += _aTotDes[i,2]

	next

	@nlin,205 psay transform(iif(_cTpCompr = 'V',0,_nTotal), '@E 999,999,999.99')

	nlin++

	_aTDProg  := _aTotDes

	@nlin,000 psay replicate('-',220)
	nLin++
	@nlin,000 psay '| ANALISE DE RENTABILIDADE - RECEITAS'
	nlin++
	//Impressão dos cabeçalho dos programas
	// _nCol := 20
	// for i := 1 to len(_aProgTT)
	// 	if substr(_aProgTT[i,1],1,1) <> 'S'
	// 		_cList   := GetAdvFVal('SZ6',1,FWxfilial('SZ6')+_aProgTT[i,1],'Z6_LISTA')
	// 		_cDescri := lower(GetAdvFVal('SZ6',1,FWxfilial('SZ6')+_aProgTT[i,1],'Z6_DESC'))
	// 	else
	// 		_cList   := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),'Z5_LISTA')
	// 		_cDescri := 'saldo '+lower(GetAdvFVal('SZ5',1,FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),'Z5_DESC'))
	// 	endif
	// 	if _aProgTT[i,1] $ 'S_TF/S_CO'
	// 		_cDescri := iif(_aProgTT[i,1] = 'S_CO',substr('san. Conserva',1,10),substr('san. TF',1,10))
	// 	endif

	// 	if _cList = 'S' .or. _aProgTT[i,1] = '000' .or. _aProgTT[i,1] $ 'S_TF/S_CO'
	// 		@nlin,_nCol psay iif( _aProgTT[i,1] = '000','fora do padrão',_cDescri)
	// 		_nCol+=15
	// 	endif

	//Impressão dos cabeçalho dos programas
	_nCol := 25
	for i := 1 to len(_aProgTT)
		if _cList = 'S' .or. _aProgTT[i,1] = '000' .or. _aProgTT[i,1] $ 'S_TF/S_CO/S_GR/007'
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Fora do Padrao',_cDescri)
			_nCol+=18
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Hereford',_cDescri)
			_nCol+=18
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Angus',_cDescri)
			_nCol+=12
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Black Label',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Touruno',_cDescri)
			_nCol+=15
			//@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Terneiro',_cDescri)
			//_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Touro',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Novilho',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Saldo Macho',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Saldo Fêmea',_cDescri)
			_nCol+=15
			//@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Saldo Touro',_cDescri)
			//_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','San. Conse',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','San. Grax',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','San. TF',_cDescri)
			@nlin,210 psay "Total"
		endif

	next

	nlin++

	//Impressao dos valores de vendas por kg  por programa
	@nlin,000 psay '|Venda kg:'

	_nPosT  := aScan(_aProgTT,{|aVal|aVal[1] = 'TOTAL'})
	_nTotal := 0.00

	//Para procura do total de venda para calcular o valor medio da venda por kg
	for i := 1 to len(_aProgTT)
		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList  := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
			_nVenda := GetAdvFVal('SZ6','Z6_VENDA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
			_nVenda  := GetAdvFVal('SZ5','Z5_VENDA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		_nVenda := iif(_aProgTT[i,1] = '000',SZQ->ZQ_VENDA,_nVenda)

		if _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR'
			_nVenda := iif(_aProgTT[i,1] = 'S_TF',_nVlrTF,iif(_aProgTT[i,1] $ 'S_CO/S_TS',_nVlrCons,_nVlrGrax))
		elseif _aProgTT[i,1] = '007'
			_nVenda := GetAdvFVal('SZ6','Z6_VENDA',FWxfilial('SZ6')+'014',1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			_nCalculo := (_aProgTT[i,3] * _nVenda)
			_nTotal += _nCalculo
		endif
	next
	//Fim desta procura do valor total para calculo do preço medio de venda por kg

	_nCol := 20
	for i := 1 to len(_aProgTT)
		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList  := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
			_nVenda := GetAdvFVal('SZ6','Z6_VENDA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
			_nVenda  := GetAdvFVal('SZ5','Z5_VENDA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		_nVenda := iif(_aProgTT[i,1] = '000',SZQ->ZQ_VENDA,_nVenda)

		if _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR'
			_nVenda := iif(_aProgTT[i,1] = 'S_TF',_nVlrTF,iif(_aProgTT[i,1] $ 'S_CO/S_TS',_nVlrCons,_nVlrGrax))
		elseif _aProgTT[i,1] = '007'
			_nVenda := GetAdvFVal('SZ6','Z6_VENDA',FWxfilial('SZ6')+'014',1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			If _aProgTT[i,1] != 'S_TS'
				@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,_nVenda),'@E 999,999,999.99')
				_nCol+=15
			EndIf

		endif
	next

	_nPrcMedio := _nTotal/_aProgTT[_nPosT,3]

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nPrcMedio), '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de vendas de rejeito  por programa
	@nlin,000 psay '|V.Rejeitos('+alltrim(transform(SZQ->ZQ_REJEITO,'@E 999,999,999.99')) +'):'

	_nTotal := 0.00

	_nCol := 20
	for i := 1 to len(_aProgTT)

		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList  := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			_nCalculo := (_aProgTT[i,3] * (SZQ->ZQ_PRCREJ/100)) * SZQ->ZQ_REJEITO

			If _aProgTT[i,1] != 'S_TS'
				if _aProgTT[i,1] = 'S_CO'
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo * 0.98)+(((_aProgTT[i+3,3] * (SZQ->ZQ_PRCREJ/100)) * SZQ->ZQ_REJEITO) * 0.98)),'@E 999,999,999.99')
				else
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo * 0.98)),'@E 999,999,999.99')
				endif
				_nCol+=15
				_nTotal += _nCalculo

				//Construção do vetor de receitas
				_nPos := aScan(_aTotRec,{|aVal|aVal[1] = _aProgTT[i,1]})
				if _nPos <> 0
					_aTotRec[_nPos,2] += _nCalculo
				else
					aAdd(_aTotRec,{_aProgTT[i,1],_nCalculo})
				endif
			EndIf
		endif
	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal * 0.98), '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de vendas de carne por programa
	@nlin,000 psay '|V.Carne:'

	_nTotal := 0.00

	_nCol := 20
	for i := 1 to len(_aProgTT)
		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList  := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
			_nVenda := GetAdvFVal('SZ6','Z6_VENDA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
			_nVenda  := GetAdvFVal('SZ5','Z5_VENDA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		_nVenda := iif(_aProgTT[i,1] = '000',SZQ->ZQ_VENDA,_nVenda)

		if _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR'
			_nVenda := iif(_aProgTT[i,1] = 'S_TF',_nVlrTF,iif(_aProgTT[i,1] $ 'S_TS/S_CO',_nVlrCons,_nVlrGrax))
		elseif _aProgTT[i,1] = '007'
			_nVenda := GetAdvFVal('SZ6','Z6_VENDA',FWxfilial('SZ6')+'014',1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			_nCalculo := _aProgTT[i,3] * _nVenda
			If _aProgTT[i,1] != 'S_TS'
				if _aProgTT[i,1] = 'S_CO'
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo * 0.98)+((_aProgTT[i+3,3] * _nVenda) * 0.98)),'@E 999,999,999.99')
				else
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo * 0.98)),'@E 999,999,999.99')
				endif
				_nCol+=15
			EndIf

			_nTotal += _nCalculo
		endif
	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal * 0.98), '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de impostos de vendas de carne por programa
	@nlin,000 psay '|%Impostos('+ alltrim(transform(SZQ->ZQ_IMPOSTO,"@E 999.99")) +'):'

	_nTotal := 0.00

	_nCol := 20
	for i := 1 to len(_aProgTT)
		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList  := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
			_nVenda := GetAdvFVal('SZ6','Z6_VENDA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
			_nVenda  := GetAdvFVal('SZ5','Z5_VENDA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		_nVenda := iif(_aProgTT[i,1] = '000',SZQ->ZQ_VENDA,_nVenda)

		if _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR'
			_nVenda := iif(_aProgTT[i,1] = 'S_TF',_nVlrTF,iif(_aProgTT[i,1] $ 'S_TS/S_CO',_nVlrCons,_nVlrGrax))
		elseif _aProgTT[i,1] = '007'
			_nVenda := GetAdvFVal('SZ6','Z6_VENDA',FWxfilial('SZ6')+'014',1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			_nCalculo := (_aProgTT[i,3] * _nVenda)*(SZQ->ZQ_IMPOSTO/100)

			If _aProgTT[i,1] != 'S_TS'
				if _aProgTT[i,1] = 'S_CO'
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo * 0.98)+(((_aProgTT[i+3,3] * _nVenda)*(SZQ->ZQ_IMPOSTO/100)) * 0.98)),'@E 999,999,999.99')
				else
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo * 0.98)),'@E 999,999,999.99')
				endif
				_nCol+=15
			EndIf

			_nTotal += _nCalculo
		endif
	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal * 0.98), '@E 999,999,999.99')

	nlin++

	//Impressao dos valores de vendas de carne por programa
	@nlin,000 psay '|V.Carne Fim:'

	_nTotal := 0.00

	_nCol := 20
	for i := 1 to len(_aProgTT)
		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList  := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
			_nVenda := GetAdvFVal('SZ6','Z6_VENDA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
			_nVenda  := GetAdvFVal('SZ5','Z5_VENDA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		_nVenda := iif(_aProgTT[i,1] = '000',SZQ->ZQ_VENDA,_nVenda)

		if _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR'
			_nVenda := iif(_aProgTT[i,1] = 'S_TF',_nVlrTF,iif(_aProgTT[i,1] $ 'S_TS/S_CO',_nVlrCons,_nVlrGrax))
		elseif _aProgTT[i,1] = '007'
			_nVenda := GetAdvFVal('SZ6','Z6_VENDA',FWxfilial('SZ6')+'014',1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			_nCalculo := (_aProgTT[i,3] *  _nVenda)-((_aProgTT[i,3] *  _nVenda)*SZQ->ZQ_IMPOSTO/100)

			If _aProgTT[i,1] != 'S_TS'
				if _aProgTT[i,1] = 'S_CO'
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo * 0.98)+(((_aProgTT[i+3,3]*_nVenda)-((_aProgTT[i+3,3]*_nVenda)*SZQ->ZQ_IMPOSTO/100))*0.98)),'@E 999,999,999.99')
				else
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo * 0.98)),'@E 999,999,999.99')
				endif
				_nCol+=15
				_nTotal += _nCalculo

				//Construção do vetor de receitas
				_nPos := aScan(_aTotRec,{|aVal|aVal[1] = _aProgTT[i,1]})
				if _nPos <> 0
					_aTotRec[_nPos,2] += _nCalculo
				else
					aAdd(_aTotRec,{_aProgTT[i,1],_nCalculo})
				endif
			EndIf
		endif
	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal * 0.98), '@E 999,999,999.99')

	nlin++

	@nlin,000 psay '|V.Mds/Couro('+alltrim(transform(SZQ->ZQ_SUBPROD,'@E 999.99')) +'):'

	_nTotal := 0.00

	_nCol := 20
	for i := 1 to len(_aProgTT)
		if substr(_aProgTT[i,1],1,1) <> 'S'
			_cList  := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aProgTT[i,1],1)
		else
			_cList   := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aProgTT[i,1] = '000'  .or. _aProgTT[i,1] $ 'S_TF/S_TS/S_CO/S_GR/007'
			_nCalculo := (_aProgTT[i,3] * (SZQ->ZQ_PERCSUB/100)) * SZQ->ZQ_SUBPROD

			If _aProgTT[i,1] != 'S_TS'
				if _aProgTT[i,1] = 'S_CO'
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo * 0.98)+(((_aProgTT[i+3,3] * (SZQ->ZQ_PERCSUB/100)) * SZQ->ZQ_SUBPROD) * 0.98)),'@E 999,999,999.99')
				else
					@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo * 0.98)),'@E 999,999,999.99')
				endif
				_nCol+=15
				_nTotal += _nCalculo

				//Construção do vetor de receitas
				_nPos := aScan(_aTotRec,{|aVal|aVal[1] = _aProgTT[i,1]})
				if _nPos <> 0
					_aTotRec[_nPos,2] += _nCalculo
				else
					aAdd(_aTotRec,{_aProgTT[i,1],_nCalculo})
				endif
			EndIf
		endif
	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal * 0.98), '@E 999,999,999.99')

	nlin++

	//Impressao dos totais de receitas por programa
	@nlin,000 psay '|TOTAIS:'

	_ntotal := 0

	_nCol := 20

	for i := 1 to len(_aTotRec)
		@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,_aTotRec[i,2]),'@E 999,999,999.99')
		_nCol+=15
		_nTotal += _aTotRec[i,2]
	next

	@nlin,205 psay transform(iif(_cTpCompr = 'V',0,_nTotal), '@E 999,999,999.99')

	nlin++

	_aTRProg := _aTotRec

	@nlin,000 psay replicate('-',220)
	nLin++
	@nlin,000 psay '| ANALISE DE RENTABILIDADE - RESULTADOS'
	nlin++

	//Calculo do numero de categorias e programas
	_nNumCateg := 0
	_nNumProg  := 0

	for i := 1 to len(_aCateTT)
		if _aCateTT[i,2] <> 0
			_nNumCateg++
		endif
	next

	for i := 1 to len(_aProgTT)
		if _aProgTT[i,2] <> 0 .and. _aProgTT[i,1] <> '000'
			_nNumProg++
		endif
	next
	/*
	@nlin,000 psay '|Por Categoria:'

	//Impressão dos cabeçalho das categorias
	_nCol   := 28

	for i := 1 to len(_aCateTT)
	_cList := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aCateTT[i,1],'Z5_LISTA')
		if _cList = 'S'
	@nlin,_nCol psay alltrim(lower(GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aCateTT[i,1],'Z5_DESC'))    )
	_nCol+=15
		endif
	next
	@nlin,210 psay 'Total'

	nlin++

	//Impressao dos valores totais bruto por categoria
	@nlin,000 psay '|Total Bruto:'

	_nTotal := 0.00

	_nCol := 25
	for i := 1 to len(_aTRCate)
	_cList := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aCateTT[i,1],'Z5_LISTA')
		if _cList = 'S'
	_nCalculo := _aTRCate[i,2] - _aTDCate[i,2]
	@nlin,_nCol psay transform(_nCalculo,'@E 999,999,999.99')

	_nTotal += _nCalculo
	_nCol+=15
		endif
	next

	@nlin, 195 psay transform(_nTotal, '@E 999,999,999.99')

	nlin++

	//Impressao dos valores totais bruto por categoria
	@nlin,000 psay '|Liquido(-35%):'

	_nTotal := 0.00

	_nCol := 25
	for i := 1 to len(_aTRCate)
	_cList := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aCateTT[i,1],'Z5_LISTA')
		if _cList = 'S'
	_nCalculo := (_aTRCate[i,2] - _aTDCate[i,2]) * 0.65
	@nlin,_nCol psay transform(_nCalculo,'@E 999,999,999.99')

	_nTotal += _nCalculo

	_nCol+=15
		endif
	next

	@nlin, 195 psay transform(_nTotal, '@E 999,999,999.99')

	nlin++

	//Impressao dos valores totais liquido por cabeça por categoria
	@nlin,000 psay '|Liq. por Cabeça:'

	_nTotal := 0.00

	_nCol := 25
	for i := 1 to len(_aTRCate)
	_cList := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aTRCate[i,1],'Z5_LISTA')
		if _cList = 'S'
	_nPos :=  aScan(_aCateTT,{|aVal|aVal[1] = _aTRCate[i,1]})
	_nCalculo := ((_aTRCate[i,2] - _aTDCate[i,2]) * 0.65)/_aCateTT[_nPos,2]
	@nlin,_nCol psay transform(_nCalculo,'@E 999,999,999.99')

	_nTotal += _nCalculo

	_nCol+=15
		endif
	next

	@nlin, 195 psay transform(_nTotal/_nNumCateg, '@E 999,999,999.99')

	nlin++

	//Impressao dos valores totais liquido por cabeça por categoria
	@nlin,000 psay '|Liq. por kg:'

	_nTotal := 0.00

	_nCol := 25
	for i := 1 to len(_aTRCate)
	_cList := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+_aTRCate[i,1],'Z5_LISTA')
		if _cList = 'S'
	_nPos :=  aScan(_aCateTT,{|aVal|aVal[1] = _aTRCate[i,1]})
	_nCalculo := ((_aTRCate[i,2] - _aTDCate[i,2]) * 0.65)/_aCateTT[_nPos,3]
	@nlin,_nCol psay transform(_nCalculo,'@E 999,999,999.99')

	_nTotal += _nCalculo

	_nCol+=15
		endif
	next

	@nlin, 195 psay transform(_nTotal/_nNumCateg, '@E 999,999,999.99')

	nlin+=2
	*/

	//Impressão dos cabeçalho das programas

	// _nCol := 21
	// for i := 1 to len(_aProgTT)
	// 	if substr(_aProgTT[i,1],1,1) <> 'S'
	// 		_cList   := GetAdvFVal('SZ6',1,FWxfilial('SZ6')+_aProgTT[i,1],'Z6_LISTA')
	// 		_cDescri := lower(GetAdvFVal('SZ6',1,FWxfilial('SZ6')+_aProgTT[i,1],'Z6_DESC'))
	// 	else
	// 		_cList   := GetAdvFVal('SZ5',1,FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),'Z5_LISTA')
	// 		_cDescri := 'saldo '+lower(GetAdvFVal('SZ5',1,FWxfilial('SZ5')+substr(_aProgTT[i,1],2,3),'Z5_DESC'))
	// 	endif

	// 	if _aProgTT[i,1] $ 'S_TF/S_CO'
	// 		_cDescri := iif(_aProgTT[i,1] = 'S_CO',substr('san. Conserva',1,10),substr('san. TF',1,10))
	// 	endif

	// 	if _cList = 'S' .or. _aProgTT[i,1] = '000' .or. _aProgTT[i,1] $ 'S_TF/S_CO'
	// 		@nlin,_nCol psay iif( _aProgTT[i,1] = '000','fora do padrão',_cDescri)
	// 		_nCol+=15
	// 	endif

	//Impressão dos cabeçalho dos programas
	_nCol := 25
	for i := 1 to len(_aProgTT)
		if _cList = 'S' .or. _aProgTT[i,1] = '000' .or. _aProgTT[i,1] $ 'S_TF/S_CO/S_GR/007'
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Fora do Padrao',_cDescri)
			_nCol+=18
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Hereford',_cDescri)
			_nCol+=18
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Angus',_cDescri)
			_nCol+=12
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Black Label',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Touruno',_cDescri)
			_nCol+=15
			//@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Terneiro',_cDescri)
			//_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Touro',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Novilho',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Saldo Macho',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Saldo Fêmea',_cDescri)
			_nCol+=15
			//@nlin,_nCol psay iif( _aProgTT[i,1] = '000','Saldo Touro',_cDescri)
			//_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','San. Conse',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','San. Grax',_cDescri)
			_nCol+=15
			@nlin,_nCol psay iif( _aProgTT[i,1] = '000','San. TF',_cDescri)
			@nlin,210 psay "Total"
		endif

	next

	nlin++

	//Impressao dos valores totais bruto por programas
	@nlin,000 psay '|Total Bruto:'

	_nTotal := 0.00
	_nCol := 20

	_nCalculo := 0

	for i := 1 to len(_aTRProg)
		if substr(_aTRProg[i,1],1,1) <> 'S'
			_cList := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aTRProg[i,1],1)
		else
			_cList := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aTRProg[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aTRProg[i,1] = '000'  .or. _aTRProg[i,1] $ 'S_TF/S_CO/S_GR/007'
			_nCalculo := (_aTRProg[i,2] * 0.98) - _aTDProg[i,2]

			@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo)),'@E 999,999,999.99')
			_nCol+=15

			_nTotal += _nCalculo
		endif

	next
	@nlin, 205 psay transform(_nTotal, '@E 999,999,999.99')

	nlin++

	//Impressao dos valores totais bruto por programas
	@nlin,000 psay '|Liquido:' // era |Liquido(-35%):

	_nTotal := 0.00

	_nCol := 20
	for i := 1 to len(_aTRProg)
		if substr(_aTRProg[i,1],1,1) <> 'S'
			_cList := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aTRProg[i,1],1)
		else
			_cList := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aTRProg[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aTRProg[i,1] = '000'  .or. _aTRProg[i,1] $ 'S_TF/S_CO/S_GR/007'
			_nCalculo := ((_aTRProg[i,2] * 0.98) - _aTDProg[i,2]) * 1
			aAdd(_aLiq,{_aTRProg[i,1],_nCalculo})
			_nTotal += _nCalculo

			@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo)),'@E 999,999,999.99')
			_nCol+=15
		endif

	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotal), '@E 999,999,999.99')

	_nTotLiq := _nTotal

	nlin++

	//Impressao dos valores totais liquido por cabeça por Programa
	@nlin,000 psay '|Liq. por Cabeça:'

	_nPosT   := aScan(_aProgTT,{|aVal|aVal[1] = 'TOTAL'})
	_nQTAnim := _aProgTT[_nPosT,2]

	_nTotal := 0.00

	_nCol := 20
	_nCalculo := 0

	// Mudança na forma de cálculo de "Liq. por kg" solicitada pela Progepec (16/06/23)
	for i := 1 to len(_aLiq)
		if substr(_aLiq[i,1],1,1) <> 'S'
			_cList := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aLiq[i,1],1)
		else
			_cList := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aLiq[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aLiq[i,1] = '000'  .or. _aLiq[i,1] $ 'S_TF/S_CO/S_GR/007'
			_nPos := aScan(_aProgTT,{|aVal|aVal[1] = _aLiq[i,1]})
			_nCalculo := (_aLiq[i,2]/_aProgTT[_nPos,2])

			@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo)),'@E 999,999,999.99')
			_nCol+=15

		endif
	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,_nTotLiq/_nQTAnim), '@E 999,999,999.99')

	nlin++

	//Impressao dos valores totais liquido por cabeça por Programa
	@nlin,000 psay '|Liq. por kg:'

	_nTotal   := 0.00
	_nCalculo := 0
	_nCol     := 20

	// Mudança na forma de cálculo de "Liq. por kg" solicitada pela Progepec (16/06/23)
	for i := 1 to len(_aLiq)
		if substr(_aLiq[i,1],1,1) <> 'S'
			_cList := GetAdvFVal('SZ6','Z6_LISTA',FWxfilial('SZ6')+_aLiq[i,1],1)
		else
			_cList := GetAdvFVal('SZ5','Z5_LISTA',FWxfilial('SZ5')+substr(_aLiq[i,1],2,3),1)
		endif

		if _cList = 'S' .or. _aLiq[i,1] = '000'  .or. _aLiq[i,1] $ 'S_TF/S_CO/S_GR/007'
			_nPos := aScan(_aProgTT,{|aVal|aVal[1] = _aLiq[i,1]})
			_nCalculo := (_aLiq[i,2]/_aProgTT[_nPos,3])

			@nlin,_nCol psay transform(iif(_cTpCompr = 'V',0,(_nCalculo)),'@E 999,999,999.99')
			_nCol+=15

		endif
	next

	@nlin, 205 psay transform(iif(_cTpCompr = 'V',0,(_nTotLiq/_nQTAnim)/_nPesMedCateg), '@E 999,999,999.99')

	nlin++

	//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
	//Â³ Finaliza a execucao do relatorio...                                 Â³
	//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™

	SET DEVICE TO SCREEN

	//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„ï¿½ï¿½ï¿½ï¿½Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
	//Â³ Se impressao em disco, chama o gerenciador de impressao...          Â³
	//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

// Peso propriedade da categoria+rastro no receb, modificado para "peso lote origem"
Static Function PesoProp( receb, categ, rastreado  )
	Private nPeso1 := 0
	SZR->( dbSetOrder(1) )
	SZR->( MsSeek(FWxFilial('SZR')+receb+categ ) )
	While !SZR->(Eof()) .and. receb+categ == SZR->( ZR_RECEB+ZR_CATEG )
		if SZR->ZR_RASTRO <> rastreado
			SZR->(DbSkip())
			loop
		endif
		nPeso1 += SZR->ZR_PESO
		SZR->( dbSkip() )
	Enddo
Return nPeso1

// Peso frigorifico da categoria+rastro no receb, modificado para "peso lote frigorifico"
Static Function PesoFrig( receb, categ, rastreado )
	Private nPeso1 := 0
	SZR->( dbSetOrder(1) )
	SZR->( MsSeek(FWxFilial('SZR')+receb+categ ) )
	While !SZR->(Eof()) .and. receb+categ == SZR->( ZR_RECEB+ZR_CATEG)
		if SZR->ZR_RASTRO <> rastreado
			SZR->(DbSkip())
			loop
		endif
		nPeso1 += SZR->ZR_PESOFRI
		SZR->( dbSkip() )
	Enddo
Return nPeso1

//Função destinada a processar os dados de frete
Static Function busca_frete(_cReceb)
	Local _nTotFre     := 0.00
	Local _nTotAnim    := 0.00
	Local _cListPlaca  := "''"
	Local _cListHora   := "''"
	Local _nValFretCab := 0.00
	//Contador de veí­culos
	_nVeic := 0
	//Contador de quilometragem
	_nKm   := 0
	//--------------------------------------------------------------//
	// Existem casos em que o caminhão faz um frete para mais de um //
	// produtor. Por exemplo, os lotes 1 e 2 estão com frete no     //
	// valor de R$ 400,00 cada, mas 400,00 é o valor total do frete,//
	// devendo ser rateado pelo número de animais de cada lote.     //
	//                                                              //
	// Por isso é precisso:                                         //
	//--------------------------------------------------------------//
	// Quando a placa+data+hora forem diferentes para dois          //
	// registros significa que foram viagens diferentes e o valor   //
	// do frete deve ser somado. Caso data+hora+placa forem iguais  //
	// então o valor do frete deve ser proporcial à quantidade de   //
	// animais do lote desejado.                                    //
	//--------------------------------------------------------------//
	//Esta query traz todos os fretes relativos ao recebimento
	cQuery1 := " SELECT ZD_DATA,ZS_PLACA,ZS_HORA,ZS_VAVE,ZS_DCHPREV,ZS_DASFPR "
	cQuery1 += " FROM " + RetSQLTab('SZD') + " , " + RetSQLTab('SZS')
	cQuery1 += " WHERE " + RetSQLFil('SZD') + " AND " + RetSQLFil('SZS')  + " AND ZD_NUMERO = ZS_NUMERO AND "
	cQuery1 += " ZD_NUMERO = '" + _cReceb + "' AND "
	cQuery1 +=  RetSQLDel('SZD') + " AND " + RetSQLDel('SZS')
	cQuery1 += " GROUP BY ZS_PLACA, ZD_DATA,ZS_HORA,ZS_VAVE,ZS_DCHPREV,ZS_DASFPR"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery1 := ChangeQuery(cQuery1)

	If Select("TMP1") <> 0
		TMP1->(dbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "TMP1"

	TMP1->(DbGotop())
	While TMP1->(!eof())
		//Soma o valor total do frete
		_nTotFre += TMP1->ZS_VAVE
		_cListPlaca += ",'" + TMP1->ZS_PLACA + "'"
		_cListHora  += ",'" + TMP1->ZS_HORA + "'"
		//Soma o numero total de veiculos
		_nVeic++
		//Soma a quilometragem
		_nKm += TMP1->(ZS_DCHPREV+ZS_DASFPR)
		// inclusão da soma pura do frete
		TMP1->(DbSkip())
	enddo

	TMP1->(DbGotop())

	//Esta query traz todos os recebimentos de acordo com a data, hora e placa apurados
	//na query anterior para saber quantos animais chegaram num mesmo frete, independente
	//do lote de animais. Pega placa, hora e data apuradas na query anterior
	cQuery2 := " SELECT SUM(ZS_QTANIM) AS QTANIM "
	cQuery2 += " FROM " + RetSQLTab('SZD') + " , " + RetSQLTab('SZS')
	cQuery2 += " WHERE " + RetSQLFil('SZD') + " AND " + RetSQLFil('SZS')
	cQuery2 += " AND ZS_PLACA IN(" + _cListPlaca + ")"
	cQuery2 += " AND ZS_HORA  IN(" + _cListHora  + ")"
	cQuery2 += " AND ZD_DATA = '" + TMP1->ZD_DATA + "'"
	cQuery2 += " AND ZS_NUMERO = ZD_NUMERO "
	cQuery2 += " AND " + RetSQLDel('SZD') + " AND " + RetSQLDel('SZS')

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery2 := ChangeQuery(cQuery2)

	If Select("TMP2") <> 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY cQuery2 NEW ALIAS "TMP2"

	dbSelectarea('TMP2')

	TMP2->(DbGotop())
	While TMP2->(!eof())
		//Quantidade total de animais do frete
		_nTotAnim += TMP2->QTANIM
		TMP2->(DbSkip())
	enddo

	//Valor do frete por cabeça de gado
	_nValFretCab := _nTotFre/_nTotAnim
	//Valor do frete conforme o numero de animais por lote
	_nValFre     := _nValFretCab * _nQTAnim

return

//Função para o tratamento do peso
Static Function ProcPeso(_ps,_if,_cTpCom)

	dbSelectArea('SZG')
	dbSetOrder(1)
	SZG->(MsSeek(FWxFilial('SZG') + SZ4->Z4_NUMAM))
	_dDtPraTras := ctod('30/06/16')

	//Penalização caso desviado a IF
	if _if = 'S'
		if SZG->ZG_DATA < _dDtPraTras //se a data do abate for menor que 30/06/16 mantem o calculo antigo
			if _ps > 200
				_ps -= 10
			elseif _ps <=200
				_ps -= 7.5
			endif
		else
			if _ps > 200
				//_ps -= 20
				_ps := _ps * 0.92
			elseif _ps <=200
				//_ps -= 15
				_ps := _ps * 0.92
			endif
		endif
	endif

	//Somatorio dos pesos com desconto de 2%
	If _cTpCom == "Q"
		_ps := _ps
	Else
		_ps := _ps * 0.98
	Endif

return _ps

//Função para o tratamento do peso frio
Static Function ProcPesF(_psf,_iff)

	dbSelectArea('SZG')
	dbSetOrder(1)
	SZG->(MsSeek(FWxFilial('SZG') + SZ4->Z4_NUMAM))
	_dDtPraTras := ctod('30/06/16')

	//Penalização caso desviado a IF
	if _iff = 'S'
		if SZG->ZG_DATA < _dDtPraTras //se a data do abate for menor que 30/06/16 mantem o calculo antigo
			if _psf > 200
				_psf -= 10
			elseif _psf <=200
				_psf -= 7.5
			endif
		else
			if _psf > 200
				_psf := _psf * 0.92
			elseif _psf <=200
				_psf := _psf * 0.92
			endif
		endif
	endif

	//Somatorio dos pesos com desconto de 2%
	_psf := _psf * 0.98

return _psf
