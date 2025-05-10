#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

User Function F_PCP022()

	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³F_PCP022  ºAutor  ³3V                  º Data ³  01/25/07   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDesc.     ³ Planilha de avaliacao de lotes                             º±±
	±±º          ³                                                            º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Sigapcp                                                    º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/

	Private cDesc1         := "Gera relat. Planilha de Avaliação de Lotes "
	Private cDesc2         := ""
	Private cDesc3         := ""
	Private cPict          := ""
	Private titulo         := "Planilha de Avaliação de Lotes"
	Private nLin           := 80
	Private Cabec1         := ""
	Private Cabec2         := ""
	Private imprime        := .T.
	Private limite         := 132
	Private aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private tamanho      := "M"
	Private nomeprog     := "PCP022"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	//Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := 'PCP022'
	Private _aTipGord    := {}  //Tipificações de gordura
	Private _aClasProg   := {}  //Classificados em Programas
	Private _aAnimFPad   := {}  //Anaimais fora do padrão
	Private _aDiagDoen   := {}  //Diagnostico de doenças
	Private _aPedCom     := {}  //Pedidos de compra
	Private _nTotFUNDESA := 0
	Private _nTotNF      := 0
	Private _nPSocial    := 0
	Private _nFunrural	 := 0
	Private _nCol        := 11
	Private cString := "SZG"
	Private nPesPren  	 := GETMV("SI_PNPREN")
	Private nPesPread 	 := GETMV("SI_PNPREAD")

	cPerg := "PCP022"

	If !Pergunte(cPerg,.T.)
		Return
	Endif

	dIni   := mv_par01
	dFim   := mv_par02

	cLtini := mv_par03
	cLtfim := mv_par04

	wnrel := SetPrint(cString,NomeProg,"",titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport() },Titulo)

Return

Static Function RunReport()

	aDENT := CTBCBOX('ZK_DENT')
	aFORM := CTBCBOX('ZK_CONFORM')
	aSEXO := CTBCBOX('ZK_SEXO')
	aDest := CTBCBOX('ZK_DESTINO')
	aObs  := CTBCBOX('ZK_OBS')

	SetRegua(SZG->(reccount()))

	SZG->(DbSetorder(2)) // data
	SZK->(DbSetorder(2)) // av matanca+lote
	SZE->(DbSetorder(2)) //
	SZD->(DbSetorder(1)) //
	SZ9->(DbSetOrder(1)) // numero+item
	SZR->(dbSetOrder(1)) // receb+categ
	SZ4->(DbSetOrder(1))
	SA2->(DbSetOrder(1))
	SA3->(DbSetOrder(1))
	SZA->(DbSetOrder(1))

	SZG->(MsSeek(FWxFilial('SZG')+dtos(dini),.t.))

	While SZG->(!eof()) .AND. SZG->ZG_DATA <= dFim

		SZK->(MsSeek(FWxFilial('SZK')+SZG->ZG_NUMAM,.f.))

		cChave := SZK->(ZK_FILIAL+ZK_NUMAM)

		//Para uso em cabeçalho no relatorio de modo continuo
		Cabec1 := '|'+  padc('Data',_nCol,'') +'|'+padc('Sexo',_nCol,'')+'|'+padc('Peso',_nCol,'')      +'|'+;
		padc('Idade',_nCol,'')      +'|'+padc('Classe',_nCol,'')    +'|'+padc('Codigo',_nCol,'')    +'|'+ padc('Carc.',_nCol,'')    +'|'+;
		padc('Destino',_nCol,'')    +'|'+padc('Preço',_nCol,'')     +'|'+padc('Raca do',_nCol,'')   +'|'+ padc('Programa',_nCol,'') +'|'
		Cabec2 := '|'+  padc('Abate',_nCol,'')       +'|'+padc('Categoria',_nCol,'')     +'|'+padc('Carc. Fria',_nCol,'')+'|'+;
		padc('Dentição',_nCol,'')   +'|'+padc('Gordura',_nCol,'')   +'|'+padc('Contus.',_nCol,'')   +'|'+ padc('Rast.',_nCol,'')      +'|'+;
		padc('Carcaça',_nCol,'')    +'|'+padc('R$/Kg',_nCol,'')     +'|'+padc('Animal',_nCol,'')    +'|'+ padc('de Carne',_nCol,'')   +'|'

		While !SZK->(eof()) .and. cChave == SZK->(ZK_FILIAL+ZK_NUMAM)

			cChave1:= SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE)

			If SZK->ZK_LOTE < cLtini .OR. SZK->ZK_LOTE > cLtfim
				SZK->(dbSkip())
				Loop
			Endif

			nfem      := 0
			npfem     := 0
			nptot     := 0
			nras      := 0

			if mv_par06 = 1
				nlin  := 80
			endif

			totPedesc := 0
			_cNumPren := 0
			_nTotLote := 0
			_nPrenhes := 0
			_nPrenAdi := 0
			_cDescCat := ''
			_nPrecoM  := 0.00
			_nTotVal  := 0.00
			_cProg 	  := ""

			SZE->(MsSeek(FWxFilial('SZE')+SZK->(ZK_NUMAM+ZK_LOTE)),.f.)
			SZ9->(MsSeek(FWxFilial('SZ9')+SZE->ZE_NUMSC+SZE->ZE_ITEMSC))
			SZD->(MsSeek(FWxFilial('SZD')+SZE->ZE_NUMERO))
			SZR->(MsSeek(FWxFilial('SZR')+SZE->ZE_NUMERO+SZE->ZE_CATEG))
			SZ4->(MsSeek(FWxfilial('SZ4')+SZK->(ZK_NUMAM+ZK_LOTE)))
			SZA->(MsSeek(FWxfilial('SZA')+SZ9->Z9_NUMERO))
			SA2->(MsSeek(FWxfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA)))
			SA3->(MsSeek(FWxfilial('SA3')+SZA->ZA_COMPRA))

			_nTotLote := SZ4->Z4_QUANT
			_cDescCat := SZ4->Z4_DESCAT
			_nPrenhes := SZ4->Z4_NPREN
			_nPrenAdi := SZ4->Z4_NPREAD

			if mv_par06 = 1 //modo padrão
				Cabec1 := " | Data do Abate: " + dtoc(SZG->ZG_DATA) + " | Lote:" + SZK->ZK_LOTE + " | Quantidade: "+transform(_nTotLote,'@E 999,999') +;
				" | Preço Base: "+transform(SZ9->Z9_PRECO,'@E 99.99')+ " | Categoria: " + alltrim(_cDescCat)
				Cabec2 := " | Produtor: " +alltrim(substr(SA2->A2_NOME,1,30))+" | Origem: " + alltrim(SA2->A2_MUN) +;
				" | Inscr.Estadual: " + alltrim(SA2->A2_INSCR)+" | Comprador: " + alltrim(SA3->A3_NOME)
			endif

			pesooriP := PesoProp(SZE->ZE_NUMERO,SZE->ZE_CATEG, If(Empty(SZE->ZE_RASTRO),'N','S'))
			pesoprop := pesooriP - iif(pesooriP > 0, (((SZ4->Z4_NPREN-SZ4->Z4_NPREAD)*nPesPren)+(SZ4->Z4_NPREAD*nPesPread)), 0)
			pesooriF := PesoFrig(SZE->ZE_NUMERO,SZE->ZE_CATEG, If(Empty(SZE->ZE_RASTRO),'N','S'))
			_nPercQ  := pesooriF/iif(pesoprop > 0.0, pesoprop, 1.0)
			_nPercQ  := iif(_nPercQ > 0 .and. _nPercQ < 1, _nPercQ, 1.0)
			pesofrig := pesooriF - iif(pesooriF > 0, (((SZ4->Z4_NPREN-SZ4->Z4_NPREAD)*(nPesPren*_nPercQ))+(SZ4->Z4_NPREAD*(nPesPread*_nPercQ))), 0)
			_natprod := GetAdvFVal('SA2','A2_TIPO',FWxfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA),1)

			_aTipGord  := {{'1',0},{'2',0},{'3',0},{'4',0},{'5',0}}  //Tipificações de gordura
			_aClasProg := {{'002',0,0,0},{'006',0,0,0},{'013',0,0,0},{'020',0,0,0}}            //Classificados em Programas
			_aAnimFPad := {{'005',0,0},{'008',0,0},{'019',0,0},{'001',0,0}}  //Animais fora do padrão
			_aDiagDoen := {}  //Diagnostico de doenças

			//Função para apurar os totais de condenas (doenças) do lote
			ImpCond(SZK->ZK_NUMAM,SZK->ZK_LOTE)

			While !SZK->(eof()) .and. cChave1 == SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE)

				_cTpCom := GetAdvFVal("SZE","ZE_TPCOM",FWxFilial("SZE")+SZK->ZK_NUMAM+SZK->ZK_LOTE,2)
				npeso := 0
				Det_Report(_cTpCom)  //Detalhamento do relatorio (colunas)

				//Bloco para apurar totais de tipificação de gordura
				_nPos := 0
				_nPos := aScan(_aTipGord,{|aVal|aVal[1] = substr(SZK->ZK_COBGOR,1,1)})
				if _nPos <> 0
					_aTipGord[_nPos][2]++
				endif

				//Bloco para apurar totais de animais classificados em programas (006 = Angus 011 = Brangus 002 = Hereford)
				//if SZK->ZK_PROGPGP = "013"
				//	_cProg := ""
				//else
					_cProg := SZK->ZK_PROGPGP
				//endif
				_nPos := 0
				_nPos := aScan(_aClasProg,{|aVal|aVal[1] = _cProg .and. _cProg $ '002/006/013/020'})
				if _nPos <> 0 
					_aClasProg[_nPos][2]++
					//If _cTpCom == "Q"
						_aClasProg[_nPos][3] += SZK->ZK_PRECOBO * npeso
						_aClasProg[_nPos][4] += npeso
					//Else
						//_aClasProg[_nPos][3] += SZK->ZK_PRECOBO * (npeso-(npeso*0.02))
						//_aClasProg[_nPos][4] += (npeso-(npeso*0.02))
					//Endif
				endif

				//Bloco para apurar totais de animais classificados como fora do padrão (005 = Cruza Leite 008 = touruno 019 = Touro 001 = magro)
				_nPos := 0
				_nPos := aScan(_aAnimFPad,{|aVal|aVal[1] = SZK->ZK_PROGPGP .and. SZK->ZK_PROGPGP $ '005/008/019/001'})
				if _nPos <> 0  
					_aAnimFPad[_nPos][2]++
					_aAnimFPad[_nPos][3]+= SZK->ZK_PRECOBO
				endif
				SZK->(DbSkip())
			Enddo

			Tot_Report(_cTpCom)

		Enddo

		SZG->(DBSkip())
	Enddo

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return


Static Function Cab_report()
	if mv_par06 = 1

		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin   := 8
	else
		if nlin > 68

			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin   := 8
		endif
	endif

Return

//Função para totais do relatorio
Static Function Tot_report(_cTpCom)
	Local i
	if mv_par06 = 1
		if nlin > 68 
			Cabec(Titulo,'','',NomeProg,Tamanho,nTipo)
			nLin   := 8
		else
			nlin++
			@ nlin,000 psay Replicate('-',limite)
		endif

		//Calculo dos rendimentos
		//peso origem
		If pesoprop > 0
			//If _cTpCom == "Q"
				_rendO := (nPtot/pesoprop) * 100   //Rendimento origem
			//Else
				//_rendO := ((nPtot-totPedesc)/pesoprop) * 100   //Rendimento origem
			//Endif
		Else
			_rendO := 0
		Endif
	
		//peso frigorifico
		If pesofrig > 0
			//If _cTpCom == "Q"
				_rendF := (nPtot/pesofrig) * 100  //Rendimento propriedade
			//Else
				//_rendF := (nPtot-totPedesc)/pesofrig * 100  //Rendimento propriedade
			//Endif
		Else
			_rendF := 0
		Endif

		//Calculo do percentual da quebra por tranporte
		_nQTransp1 := (1 - (pesofrig/pesoprop))*100
		_nQTransp1 := iif(_nQTransp1 > 0,_nQTransp1,0)
		//Calculo kg/Ca da quebra por transporte
		_nQTransp2 := iif(pesoprop <> 0, (pesoprop - pesofrig) / _nTotLote,0)
		_nQTransp2 := iif(_nQTransp2 > 0,_nQTransp2,0)
		//busca Números de prenhez

		if(pesofrig <=0 .or. pesoprop <=0)
			_nQTransp1 := 0
			_nQTransp2 := 0
		endif

		nlin++

		@ nlin,001 Psay '|Peso bruto origem:'+ transform(pesooriP,'@E 999,999.99')+' kg'
		@ nlin,035 Psay '|Peso liq. origem: '+ transform(pesoprop,'@E 999,999.99')+' kg'
		@ nlin,070 Psay '|Peso medio origem:'+ transform(pesoprop/_nTotLote,'@E 999,999.99')+' kg'
		@ nlin,105 Psay '|Rendimento origem:'+ transform(_rendO,'@E 999.99')+' %'
		nlin++
		@ nlin,001 Psay '|Peso bruto frigo.:'+ transform(pesooriF,'@E 999,999.99')+' kg'
		@ nlin,035 Psay '|Peso liq. frigo.: '+ transform(pesofrig,'@E 999,999.99')+' kg'
		@ nlin,070 Psay '|Peso medio frigo.:'+ transform(pesofrig/_nTotLote,'@E 999,999.99')+' kg'
		@ nlin,105 Psay '|Rendimento frigo.:'+ transform(_rendF,'@E 999.99')+' %'
		nlin++
		//If _cTpCom == "Q"
		@ nlin,001 Psay '|Peso total carc.: '+ transform(( nPtot ),'@E 999,999.99')+' kg'
		//Else
			//@ nlin,001 Psay '|Peso total carc. fria: '+ transform(( nPtot - totPedesc ),'@E 999,999.99')+' kg'
		//Endif
		@ nlin,035 Psay '|Quebra peso transp.:'+ transform(_nQTransp1,'@E 999.99') + ' %'
		@ nlin,070 psay '|Prenhez total:      '+ transform(_nPrenhes,'@E 999')+' Cab'
		nlin++
		//If _cTpCom == "Q"
		@ nlin,001 psay '|Peso medio carc.: '+ transform(( nPtot )/_nTotLote,"@E 99,999.99")+' kg'
		//Else
			//@ nlin,001 psay '|Peso medio carc. fria: '+ transform(( nPtot - totPedesc )/_nTotLote,"@E 999,999.99")+' kg'
		//Endif
		@ nlin,035 Psay '|Quebra peso transp.:'+ transform(_nQTransp2,'@E 999.99') + ' kg/Cab'
		@ nlin,070 psay '|Prenhez adiantada:  '+ transform(_nPrenAdi,'@E 999')+' Cab'
		nlin++

		@ nlin,000 psay Replicate('-',limite)
		nlin++

		_nMaxLinha := len(_aTipGord)

		if len(_aClasProg) > _nMaxLinha
			_nMaxLinha :=  len(_aClasProg)
		elseif len(_aAnimFPad) > _nMaxLinha
			_nMaxLinha :=  len(_aAnimFPad)
		elseif len(_aDiagDoen) > _nMaxLinha
			_nMaxLinha :=  len(_aDiagDoen)
		endif

		aSort(_aTipGord ,,,{|X,Y| X[1]< Y[1]})

		@ nlin,01 psay '|TIPIFICAÇÕES DE GORDURA'
		@ nlin,34 psay '|CLASSIFICAÇÃO DE PROGRAMAS'
		@ nlin,65 psay '|ANIMAIS FORA DO PADRÃO'
		@ nlin,93 psay '|DIAGNOSTICO DE DOENÇAS'
		nlin++

		//Calculo do preço médio dos animais classificados em programas
		_nPrcProgM  := 0
		_nPrecoProg  := 0
		_nQuantProg  := 0

		for i := 1 to len(_aClasProg)
			if _aClasProg[i][3] <> 0
				_nQuantProg  += _aClasProg[i][4]
				_nPrecoProg  += _aClasProg[i][3]
			endif
		next

		_nPrcProgM := _nPrecoProg / _nQuantProg

		AADD(_aClasProg,{'M',_nPrcProgM,0})

		//Impressão das tipificações, classificações, padrões e diagnósticos de doenças
		for i := 1 to _nMaxLinha

			if len(_aTipGord) >= i
				_cDescri := iif(_aTipGord[i][1] == '1',' (ausente)',;
				iif(_aTipGord[i][1] == '2',' (escassa)',;
				iif(_aTipGord[i][1] == '3',' (mediana)',;
				iif(_aTipGord[i][1] == '4',' (uniforme)',' (excessiva)'))))
				@nlin,001 psay '|gordura ' +_aTipGord[i][1] + _cDescri +':'
				@nlin,025 psay  transform(_aTipGord[i][2],'@E 999') + ' Cab'
			endif

			if len(_aClasProg) >= i
				_cDescri := iif(_aClasProg[i][1] = 'M','|Preço Medio:','|' + GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6')+_aClasProg[i][1],1))
				@nlin,034 psay alltrim(substr(lower(_cDescri),1,15)) + ':'
				@nlin,052 psay iif(_aClasProg[i][1] = 'M',transform(_aClasProg[i][2],'@E 999.99' + ' R$/kg'),transform(_aClasProg[i][2],'@E 999') + ' Cab')
			endif

			if len(_aAnimFPad) >= i
				_cDescri := '|' + GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6')+_aAnimFPad[i][1],1)
				@nlin,065 psay alltrim(substr(lower(_cDescri),1,15)) + ':'
				@nlin,080 psay transform(_aAnimFPad[i][2],'@E 999') + ' Cab'
			endif

			if len(_aDiagDoen) >= i
				//@nlin,093 psay '|' + alltrim(lower(_aDiagDoen[i][2])) + ':'
				@nlin,093 psay '|' + substr(alltrim(lower(_aDiagDoen[i][2])),1,30) + ':'
				@nlin,123 psay transform(_aDiagDoen[i][3],'@E 999') + ' Cab'
			endif

			nlin++
		next

		//Para listar os pedidos de compra
		@ nlin,000 psay Replicate('-',limite)
		nlin++
		@ nlin,01 psay '|DADOS DE COMPRA'
		ListaPC()
		Cab_compra()
		nlin++

		aSort(_aPedCom ,,,{|X,Y| X[4] > Y[4]})

		_nTotVal := 0

		for i := 1 to len(_aPedCom)
			if nlin > 75
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin   := 8
			endif

			@nlin,001 psay padc(_aPedCom[i][1],25,'') +;
			padc(transform(_aPedCom[i][2],'@E 999,999'),22,'') +;
			padc(transform(_aPedCom[i][3],'@E 999,999.99')+ ' kg',30,'') +;
			padc('R$ ' + transform(_aPedCom[i][4],'@E 999.99'),27,'') +;
			padc('R$ ' + transform(_aPedCom[i][5],'@E 9,999,999.99'),27,'')
			_nTotVal +=  _aPedCom[i][5]
			nlin++
		next

		//IF _cTpCom == "Q"
			_nPrecoM := round(_nTotVal/( nPtot ),2)
		//Else
			//_nPrecoM := round(_nTotVal/( nPtot - totPedesc ),2)
		//Endif
	
		//Para listar os pedidos de compra
		@ nlin,000 psay Replicate('-',limite)
		nlin++

		_cEMPREG := GetAdvFVal('SA2','A2_POSEMP',FWxfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA),1)

		//Inserido "if" e bloco "Else" por Fabian Maurer para diferenciar a impressão quando fornecedor nao tiver empregado
		IF _cEMPREG <> '2'
			@nlin,001 psay '|Preço médio lote:'+ transform(round(_nPrecoM,2),'@E 999,999.99')+ ' R$/kg' +;
			space(03) + '|Total Fundesa: R$'+ transform(_nTotFUNDESA,'@E 999.99') +;
			space(03) + '|Senar: R$' + transform(_nPSocial,'@E 999,999.99')+;
			space(03) + '|TOTAL A RECEBER: R$' + transform(iif(_natprod <> 'J',_nTotNF-(_nTotFUNDESA+_nPSocial),_nTotNF-_nTotFUNDESA),'@E 999,999,999.99')
		ELSE
			@nlin,001 psay '|Preço médio lote:'+ transform(round(_nPrecoM,2),'@E 999,999.99')+ ' R$/kg' +;
			space(03) + '|Total Fundesa: R$'+ transform(_nTotFUNDESA,'@E 999.99') +;
			iif(_natprod <> 'J', space(03) + '|Senar: R$' + transform(_nPSocial,'@E 999,999.99'),'')+;
			iif(_natprod <> 'J', space(03) + '|FunRural: R$' + transform(_nFunrural,'@E 999,999.99'), '')
			nlin++
			@nlin,001 psay '|TOTAL A RECEBER: R$' + transform(iif(_natprod <> 'J',_nTotNF-(_nTotFUNDESA+_nPSocial+_nFunrural),_nTotNF-_nTotFUNDESA),'@E 999,999,999.99')
		ENDIF
		// Fim do bloco inserido por Fabian Maurer

		nlin++

		@ nlin,000 psay Replicate('-',limite)

		/*mensagem de rodapé*/
		/*
		nlin++
		VerLinha()
		@ nlin,000 psay "Prezado Produtor Rural: O Frigorífico Silva, preocupado com as contusões de carcaça que geram perdas para a empresa e com o "
		nlin++
		VerLinha()
		@ nlin,000 psay "bem-estar animal, está monitorando, em parceria com a UFSM o grau e o local das contusões. Essas contusões são retiradas depois"
		nlin++
		VerLinha()
		@ nlin,000 psay "da pesagem de carcaça e não representam perda para o produtor rural, mas pedimos a gentileza de monitorar as contusões no sentido"
		nlin++
		VerLinha()
		@ nlin,000 psay "de reduzi-las, o que trará benefício a todos."
		nlin++
		VerLinha()
		@ nlin,000 psay "Legenda: 00 – carcaça sem contusões;01 – contusão leve no Coxa;02 – contusão grave no Coxa;03 – contusão leve no Quadril;"
		nlin++
		VerLinha()
		@ nlin,000 psay "04 – contusão grave no Quadril;05 – contusão leve no Lombo;06 – contusão grave no Lombo;07 – contusão leve no Costilhar;"
		nlin++
		VerLinha()
		@ nlin,000 psay "08 – contusão grave no Costilhar;09 – contusão leve no Dianteiro;10 – contusão grave no Dianteiro;"
		nlin++
		VerLinha()
		@ nlin,000 psay "11 – grandes contusões."
		//nlin++
		//VerLinha()
		//@ nlin,000 psay "Temos fotos de todas as carcaças com as contusões. Você pode solicitá-las pelo email sap@frigoríficosilva.com.br."
		*/
	endif

Return

Static Function Cab_compra()
	if mv_par06 = 1
		nlin++
		@ nlin,01 psay '|'+padc('Pedido de compra',25,'')+;
		'|'+padc('Quantidade',25,'')+;
		'|'+padc('Peso',25,'')+;
		'|'+padc('Preço',25,'')+;
		'|'+padc('Sub-Total',25,'')+'|'
	endif

Return

//Função para apurar os pedidos de compra do lote
Static Function ListaPC()
	if mv_par06 = 1
		_cNumam     := SZE->ZE_NUMAM
		_cLote      := SZE->ZE_LOTE
		_cForn		:= SZD->ZD_FORNECE
		_aPedCom    := {}

		/*SC7->(DbOrderNickName("C7NUMAMLOT"))
		If SC7->(MsSeek(FWxFilial('SC7')+SZE->ZE_NUMAM+SZE->ZE_LOTE))

			_nTotFUNDESA := 0
			_nTotNF      := 0
			_nPSocial    := 0
			_nFunrural	 := 0

			DO WHILE !SC7->(EOF()) .AND. FWxFilial('SC7')+SZE->ZE_NUMAM+SZE->ZE_LOTE+_cForn==SC7->(C7_FILIAL+C7_NUMAM+C7_LOTE+C7_FORNECE)
				//if SC7->C7_PCNOTA = 'NFP'
				//	SC7->(DbSkip())
				//	Loop
				//endif
				If nLin > 68
					Cab_Report()
					cab_Compra()
				Endif

				_nFUNDESA := SC7->C7_QTSEGUM * GetAdvFVal('SB1','B1_FESA',FWxfilial('SB1')+SC7->C7_PRODUTO,1)

				_nTotFUNDESA += _nFUNDESA
				_nTotNF      += SC7->C7_TOTAL

				AADD(_aPedCom,{SC7->C7_NUM,SC7->C7_QTSEGUM,SC7->C7_QUANT,SC7->C7_PRECO,SC7->C7_TOTAL})

				SC7->(DbSkip())
			ENDDO

			_nPSocial := (val(substr(getmv("MV_CONTSOC"),5,3)))/100 * _nTotNF

			// Inicio Bloco Alterado por Fabian Maurer para inserir
			//o valor do FUNRURAL quando fornecedor nao tiver empregado
			_cEMPREG := GetAdvFVal('SA2','A2_POSEMP',FWxfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA),1)

			if _cEMPREG = '2'
				//_nFunrural := 2.1/100 * _nTotNF    ---Ajuste solicitado pelo Diogo e Fabiane dia 15/01/18
				_nFunrural := 1.3/100 * _nTotNF
			endif

		Else*/

			ZAG->(DbSetOrder(3))
			If ZAG->(MsSeek(FWxFilial("ZAG") + SZE->ZE_NUMAM + SZE->ZE_LOTE))
				_nTotFUNDESA := 0
				_nTotNF      := 0
				_nPSocial    := 0
				_nFunrural	 := 0

				While !ZAG->(Eof()) .And. ZAG->ZAG_FILIAL + ZAG->ZAG_NUMAM + ZAG->ZAG_LOTE == FWxFilial("ZAG") + SZE->ZE_NUMAM + SZE->ZE_LOTE
					If nLin > 68
						Cab_Report()
						Cab_Compra()
					Endif

					_nFUNDESA := ZAG->ZAG_QUANT * GetAdvFVal('SB1','B1_FESA',FWxFilial('SB1')+ZAG->ZAG_PRODUT,1)

					_nTotFUNDESA += _nFUNDESA
					_nTotNF      += ZAG->ZAG_PESO * ZAG->ZAG_PRECO

					AADD(_aPedCom,{"      ", ZAG->ZAG_QUANT, ZAG->ZAG_PESO, ZAG->ZAG_PRECO, ZAG->ZAG_PESO * ZAG->ZAG_PRECO})

					ZAG->(DbSkip())
				EndDo

				_nPSocial := (Val(Substr(GetMv("MV_CONTSOC"),5,3)))/100 * _nTotNF

				// Inicio Bloco Alterado por Fabian Maurer para inserir
				//o valor do FUNRURAL quando fornecedor nao tiver empregado
				_cEMPREG := GetAdvFVal('SA2','A2_POSEMP',FWxfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA),1)

				If _cEMPREG = '2'
					//_nFunrural := 2.1/100 * _nTotNF --- Ajuste solicitado pelo Diogo e Fabiane dia 15/01/18
					_nFunrural := 1.3/100 * _nTotNF
				Endif
			Endif
		//Endif
	Endif

return

//Função que imprime o detalhamento (colunas) do relatorio
Static Function Det_report(_cTpCom)

	If nLin > 68

		Cab_Report()
		nlin++

		if mv_par06 = 1
			_Coluna61 := iif(mv_par05 = 1,padc('Carc',_nCol,''),padc('Codigo',_nCol,''))
			_Coluna62 := iif(mv_par05 = 1,padc('Rast?',_ncol,''),padc('Comprador',_nCol,''))

			_Coluna1_1 := iif(mv_par05 = 1,padc('Sequencial',_nCol,''),padc('Categoria',_nCol,''))
			_Coluna1_2 := iif(mv_par05 = 1,padc('Lote',_nCol,''),padc('Sexo',_nCol,''))

			@ nlin,00 psay '|'+_Coluna1_1                   +'|'+padc('Sequencial',_nCol,'')+'|'+padc('Peso',_nCol,'')   +'|'+;
			padc('Idade',_nCol,'')      +'|'+padc('Classe',_nCol,'')    +'|'+padc(''/*Codigo*/,_nCol,'')  +'|'+_Coluna61                  +'|'+;
			padc('Destino',_nCol,'')    +'|'+padc('Preço',_nCol,'')     +'|'+padc('Raca do',_nCol,'')+'|'+ padc('Programa',_nCol,'') +'|'
			//padc('Idade',_nCol,'')      +'|'+padc('Classe',_nCol,'')    +'|'+padc('Codigo',_nCol,'')  +'|'+_Coluna61                  +'|'+;
			nlin++
			@ nlin,00 psay '|'+_Coluna1_2                   +'|'+padc('Abate',_nCol,'')     +'|'+IIF(_cTpCom=="Q",padc('Carc. Quen',_nCol,''),padc('Carc. Fria',_nCol,''))+'|'+;
			padc('Dentição',_nCol,'')   +'|'+padc('Gordura',_nCol,'')   +'|'+padc(''/*Contus*/,_nCol,'')   +'|'+ _Coluna62                   +'|'+;
			padc('Carcaça',_nCol,'')    +'|'+padc('R$/Kg',_nCol,'')     +'|'+padc('Animal',_nCol,'')    +'|'+ padc('de Carne',_nCol,'')   +'|'
			//padc('Dentição',_nCol,'')   +'|'+padc('Gordura',_nCol,'')   +'|'+padc('Contus.',_nCol,'')   +'|'+ _Coluna62                   +'|'+;
		endif
	Endif

	npeso  := SZK->ZK_PETOTAL

	_dDtPraTras := ctod('30/06/16')

	if SZK->ZK_IF = 'S' 
		if SZG->ZG_DATA < _dDtPraTras //se a data do abate for menor que 30/06/16 mantem o calculo antigo

			if npeso > 200 
				npeso -= 10 
			elseif npeso <=200
				npeso -= 7.5 
			endif

		else //senão faz o calculo novo
			/*
			if npeso > 200 
				npeso -= 20 ////era 10 mudança solicitada por Gabriel 29/06/16 20
			elseif npeso <=200
				npeso -= 15 //era 7.5 mudança solicitada por Gabriel 29/06/16   15
			endif   
			Dia 23/03/20
			Ajuste abaixo foi feito pelo Maurício (gjf162) e eu (Flávio ) atualizei aqui nesse fonte para calculo correto do peso             
			*/
			//if npeso > 200
				//_ps -= 20
				npeso := npeso * 0.92
			//elseif npeso <=200
				//_ps -= 15
				//npeso := npeso * 0.92
			//endif
		endif
	endif

	//If _cTpCom == "Q"
		totPedesc  += npeso
	//Else
		//totPedesc  += npeso * 0.02 
	//Endif

	_cSexo := GetAdvFVal('SZ4','Z4_SEXO',FWxfilial('SZ4')+SZK->(ZK_NUMAM+ZK_LOTE),1)

	_Coluna6 := iif(mv_par05 = 1,iif(empty(SZK->ZK_RASTRO),'N','S'),SZA->ZA_COMPRA)

	_Coluna1 := iif(mv_par06 = 1,iif(mv_par05 = 1,strzero(SZK->ZK_ORDEM,3),_cSexo),dtoc(SZG->ZG_DATA))

	_Coluna2 := iif(mv_par06 = 1,SZK->ZK_CONTROL,SZK->ZK_SEXO)

	//If _cTpCom == "Q"
		_cImpress := '|'+padc(_Coluna1,_nCol,'') + '|'+padc(_Coluna2,_nCol,'') +;
		'|' + padc(Transform( npeso,'@E 9,999.99'),_nCol,'') +;
		'|' + padc(SZK->ZK_DENT,_nCol,'') +  '|' + padc(substr(SZK->ZK_COBGOR,1,1),_nCol,'') + '|' + padc(''/*SZK->ZK_CONTUS*/,_nCol,'') + '|' + padc(_Coluna6,_nCol,'') + '|'
		//'|' + padc(SZK->ZK_DENT,_nCol,'') +  '|' + padc(SZK->ZK_COBGOR,_nCol,'') + '|' + padc(SZK->ZK_CONTUS,_nCol,'') + '|' + padc(_Coluna6,_nCol,'') + '|'
	//Else
		//_cImpress := '|'+padc(_Coluna1,_nCol,'') + '|'+padc(_Coluna2,_nCol,'') +;
		//'|' + padc(Transform( npeso-(npeso*0.02),'@E 9,999.99'),_nCol,'') +;
		//'|' + padc(SZK->ZK_DENT,_nCol,'') +  '|' + padc(SZK->ZK_COBGOR,_nCol,'') + '|' + padc(''/*SZK->ZK_CONTUS*/,_nCol,'') + '|' + padc(_Coluna6,_nCol,'') + '|'
		//'|' + padc(SZK->ZK_DENT,_nCol,'') +  '|' + padc(SZK->ZK_COBGOR,_nCol,'') + '|' + padc(SZK->ZK_CONTUS,_nCol,'') + '|' + padc(_Coluna6,_nCol,'') + '|'
	//Endif
	nlin++

	Do Case
		Case SZK->ZK_DESTINO = 'R'
		_cImpress +=  padc('CO',_nCol,'') + '|' 
		Case SZK->ZK_DESTINO = 'T'
		_cImpress += padc('TF',_nCol,'') + '|' 
		Case SZK->ZK_DESTINO = 'G'
		_cImpress += padc('GR',_nCol,'') + '|' 
		Case SZK->ZK_DESTINO = 'C' .and. SZK->ZK_IF <> 'S'
		_cImpress += padc('CA',_nCol,'')  + '|'
		Case SZK->ZK_IF = 'S'
		_cImpress += padc('IF',_nCol,'') + '|'
	EndCase

	_cImpress += padc(transform(SZK->ZK_PRECOBO, '@E 999.99'),_nCol,'') + '|'
	// Coluna Raça
	if !empty(SZK->ZK_RACA)
		_cRaca := ''
		_cRaca := GetAdvFVal('ZA8','ZA8_DESC',FWxFilial('ZA8')+SZK->ZK_RACA,1)
		_cImpress += padc(_cRaca,_nCol,'') +'|'
	else
		_cImpress += padc('',_nCol,'') +'|'
	endif          

	// Coluna Programa 
	_cPrograma := ''
	if !(SZK->ZK_PROGPGP $ '013/020')
		_cPrograma := GetAdvFVal('SZ6','Z6_DESC',FWxFilial('SZ6')+SZK->ZK_PROGPGP,1)
	endif

	_cImpress += padc(_cPrograma,_nCol,'') +'|' 

	@ nlin,000 psay _cImpress

	if SZK->ZK_SEXO == 'F'
		nFem++
		nPfem += npeso
	endif

	npTot += npeso

	if !empty(SZK->ZK_RASTRO) .AND. SZ9->Z9_RASTRO == 'S'
		nRas++
	endif

Return

// Peso propriedade da categoria+rastro no receb, modificado para "peso lote origem"
Static Function PesoProp(receb, categ, rastreado)
	Private nPeso1 := 0
	SZR->(dbSetOrder(1))
	SZR->(MsSeek(FWxFilial('SZR')+receb+categ)) 
	While !SZR->(Eof()) .and. receb+categ == SZR->(ZR_RECEB+ZR_CATEG)
		if SZR->ZR_RASTRO <> rastreado
			SZR->(DbSkip())
			loop
		endif
		nPeso1 += SZR->ZR_PESO
		SZR->(dbSkip())
	Enddo
Return nPeso1

// Peso frigorifico da categoria+rastro no receb, modificado para "peso lote frigorifico"
Static Function PesoFrig(receb, categ, rastreado)
	Private nPeso1 := 0
	SZR->(dbSetOrder(1))
	SZR->(MsSeek(FWxFilial('SZR')+receb+categ))
	While !SZR->(Eof()) .and. receb+categ == SZR->(ZR_RECEB+ZR_CATEG)
		if SZR->ZR_RASTRO <> rastreado
			SZR->(DbSkip())
			loop
		endif  

		nPeso1 += SZR->ZR_PESOFRI
		SZR->( dbSkip() )
	Enddo
Return nPeso1

//Função para apurar os totais de condenas (doenças)
Static Function ImpCond(_cNumam,_cLote)

	area := getarea()

	DbSelectArea('ZA3')
	ZA3->(DbSetOrder(1))

	if ZA3->(MsSeek(FWxfilial('ZA3')+_cNumam+_cLote))  

		while ZA3->(!eof()) .and. ZA3->ZA3_FILIAL = FWxfilial('ZA3') .and. ;
		ZA3->ZA3_NUMAM = _cNumam .and. ;
		ZA3->ZA3_LOTE  = _cLote
			if AllTrim(ZA3->ZA3_CODCON) $ "01/16/19/02/24/32/40/41/52/53/06/09/37/42/113/133/168/42"
				_nPos := aScan(_aDiagDoen,{|aVal|aVal[1] = ZA3->ZA3_CODCON})
				if _nPos = 0
					aadd(_aDiagDoen,{ZA3->ZA3_CODCON,ZA3->ZA3_DESCON,ZA3->ZA3_QUANT})
				else
					_aDiagDoen[_nPos][3] += ZA3->ZA3_QUANT
				endif
			endif
			ZA3->(DbSkip())
		EndDo 

	endif

	restarea(area)
Return


Static function VerLinha()
	if nlin > 66
		Cabec(Titulo,'','',NomeProg,Tamanho,nTipo)
		nLin  := 8 
	endif
return
