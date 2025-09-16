#INCLUDE "rwmake.ch"

User Function FFM09()

	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³F_PCP022  ºAutor  ³Fabian Maurer       º Data ³  17/01/14   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDesc.     ³ Planilha de avaliacao de lotes Inspeção Federal            º±±
	±±º          ³                                                            º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Sigapcp                                                    º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/

	cDesc1         := "Gera relat. Planilha de Avaliação de Lotes "
	cDesc2         := ""
	cDesc3         := ""
	cPict          := ""
	titulo         := "Planilha de Avaliação de Lotes"
	nLin           := 80
	Cabec1         := "" 
	Cabec2         := "" 
	imprime        := .T.
	limite         := 132
	aOrd           := {}

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private tamanho      := "M"
	Private nomeprog     := "FFM09"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := 'FFM09'  
	Private _aTipGord    := {}  //Tipificações de gordura
	Private _aClasProg   := {}  //Classificados em Programas
	Private _aAnimFPad   := {}  //Anaimais fora do padrão
	Private _aDiagDoen   := {}  //Diagnostico de doenças 
	Private _aPedCom     := {}  //Pedidos de compra     
	Private _nTotFUNDESA := 0
	Private 	_nTotNF     := 0
	Private _nPSocial    := 0    
	Private _nFunrural	:= 0 

	Private cString := "SZG"

	cPerg := "FFM09"

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

	SZG->(DbSeek( xFilial('SZG')+dtos(dini) ,.t. ) )

	While SZG->(!eof()) .AND. SZG->ZG_DATA <= dFim

		SZK->(DbSeek(xFilial('SZK')+SZG->ZG_NUMAM,.f.))

		cChave := SZK->(ZK_FILIAL+ZK_NUMAM)


		While !SZK->(eof()) .and. cChave == SZK->(ZK_FILIAL+ZK_NUMAM)

			cChave1:= SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE)     

			If SZK->ZK_LOTE < cLtini .OR. SZK->ZK_LOTE > cLtfim
				SZK->( dbSkip() )
				Loop
			Endif

			nfem      := 0
			npfem     := 0
			nptot     := 0
			nras      := 0
			nlin      := 80
			totPedesc := 0
			_cNumPren := 0  
			_nTotLote := 0 
			_nPrenhes := 0
			_nPrenAdi := 0
			_cDescCat := ''
			_nPrecoM  := 0.00
			_nTotVal  := 0.00

			SZ4->(DbSetOrder(1))

			SZE->(DbSeek(xFilial('SZE')+SZK->(ZK_NUMAM+ZK_LOTE)),.f.)
			SZ9->(DbSeek(xFilial('SZ9')+SZE->ZE_NUMSC+SZE->ZE_ITEMSC ) )
			SZD->(DbSeek(xFilial('SZD')+SZE->ZE_NUMERO))    
			SZR->(DbSeek(xFilial('SZR')+SZE->ZE_NUMERO+SZE->ZE_CATEG ) )
			SZ4->(DbSeek(xfilial('SZ4')+SZK->(ZK_NUMAM+ZK_LOTE)))

			_nTotLote := SZ4->Z4_QUANT
			_cDescCat := SZ4->Z4_DESCAT
			_nPrenhes := SZ4->Z4_NPREN
			_nPrenAdi := SZ4->Z4_NPREAD

			_cNumComp := fBuscaCPO('SZA',1,xfilial('SZA')+SZ9->Z9_NUMERO,'ZA_COMPRA')      
			_cNomeCom := fBuscaCPO('SA3',1,xfilial('SA3')+_cNumComp,'A3_NOME')
			POSICIONE("SA2",1,XFILIAL("SA2")+SZD->(ZD_FORNECE+ZD_LOJA),"A2_NOME")

			Cabec1 := " | Data do Abate: " + dtoc(SZG->ZG_DATA) + " | Lote:" + SZK->ZK_LOTE + " | Quantidade: "+transform(_nTotLote,'@E 999,999')

			Cabec2 := " | Produtor: " +alltrim(Left(SA2->A2_NOME,30))+" | Origem: " + alltrim(SA2->A2_MUN) +;
			" | Inscr.Estadual: " + alltrim(SA2->A2_INSCR)+" | Comprador: " + alltrim(_cNomeCom)    


			pesoprop := PesoProp( SZE->ZE_NUMERO,SZE->ZE_CATEG, If(Empty(SZE->ZE_RASTRO),'N','S')  )  //SZR->ZR_PESO  )
			pesofrig := PesoFrig( SZE->ZE_NUMERO,SZE->ZE_CATEG, If(Empty(SZE->ZE_RASTRO),'N','S')  ) //SZR->ZR_PESO  )
			_natprod := fBuscaCPO('SA2',1,xfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA),'A2_TIPO')

			_aTipGord  := {{'1',0},{'2',0},{'3',0},{'4',0},{'5',0}}  //Tipificações de gordura
			_aClasProg := {{'006',0,0,0},{'011',0,0,0},{'002',0,0,0}}            //Classificados em Programas
			_aAnimFPad := {{'005',0,0},{'008',0,0},{'007',0,0},{'001',0,0}}  //Animais fora do padrão
			_aDiagDoen := {}  //Diagnostico de doenças

			//Função para apurar os totais de condenas (doenças) do lote
			ImpCond(SZK->ZK_NUMAM,SZK->ZK_LOTE)

			While !SZK->(eof()) .and. cChave1 == SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE) 

				npeso := 0
				Det_Report()  //Detalhamento do relatorio (colunas)

				//Bloco para apurar totais de tipificação de gordura      
				_nPos := 0      
				_nPos := aScan(_aTipGord,{|aVal|aVal[1] = SZK->ZK_COBGOR})	   
				if _nPos <> 0
					_aTipGord[_nPos][2]++
				endif

				//Bloco para apurar totais de animais classificados em programas (006 = Angus 011 = Brangus 002 = Hereford)
				_nPos := 0
				_nPos := aScan(_aClasProg,{|aVal|aVal[1] = SZK->ZK_PROGRAM .and. SZK->ZK_PROGRAM $ '006/011/002'})
				if _nPos <> 0 
					_aClasProg[_nPos][2]++
					_aClasProg[_nPos][3]+= SZK->ZK_PRECOBO *	(npeso-(npeso*0.02))
					_aClasProg[_nPos][4] += (npeso-(npeso*0.02))
				endif

				//Bloco para apurar totais de animais classificados como fora do padrão (005 = Cruza Leite 008 = touruno 007 = Carreiro 001 = magro)		
				_nPos := 0
				_nPos := aScan(_aAnimFPad,{|aVal|aVal[1] = SZK->ZK_PROGRAM .and. SZK->ZK_PROGRAM $ '005/008/007/001'})
				if _nPos <> 0  
					_aAnimFPad[_nPos][2]++
					_aAnimFPad[_nPos][3]+= SZK->ZK_PRECOBO
				endif

				SZK->(DbSkip())       
			Enddo

			Tot_Report()

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
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin   := 8

Return

//Função para totais do relatorio
Static Function Tot_report()
	Local i
	if nlin > 68
		Cabec(Titulo,'','',NomeProg,Tamanho,nTipo)
		nLin   := 8
	else
		nlin++
		//@ nlin,000 psay Replicate('-',limite)
	endif


	//Calculo dos rendimentos     
	//peso origem
	If pesoprop > 0   
		_rendO := ((nPtot-totPedesc)/pesoprop) * 100   //Rendimento origem
	Else
		_rendO := 0
	Endif           
	//peso frigorifico
	If pesofrig > 0    	
		_rendF := (nPtot-totPedesc)/pesofrig * 100  //Rendimento propriedade
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

	//nlin++

	//@ nlin,001 Psay '|Peso lote origem:      '+ transform(pesoprop,'@E 999,999.99')+' kg'
	//@ nlin,045 Psay '|Peso medio origem:     '+ transform(pesoprop/_nTotLote,'@E 999,999.99')+' kg' 
	//@ nlin,095 Psay '|Rendimento origem:     '+ transform(_rendO,'@E 999,999.99')+' %' 
	//nlin++
	//@ nlin,001 Psay '|Peso lote frigorífico: '+ transform(pesofrig,'@E 999,999.99')+' kg'           
	//@ nlin,045 Psay '|Peso medio frigorifico:'+ transform(pesofrig/_nTotLote,'@E 999,999.99')+' kg' 
	//@ nlin,095 Psay '|Rendimento frigorífico:'+ transform(_rendF,'@E 999,999.99')+' %' 
	//nlin++
	@ nlin,001 Psay '|Peso total carc. fria: '+ transform(( nPtot - totPedesc ),'@E 999,999.99')+' kg'  
	//@ nlin,045 Psay '|Quebra peso transporte:'+ transform(_nQTransp1,'@E 999,999.99') + ' %' 
	//@ nlin,095 psay '|Prenhez total:         '+ transform(_nPrenhes,'@E 999,999')+' Cab'
	//nlin++
	//@ nlin,001 psay '|Peso medio carc. fria: '+ transform(( nPtot - totPedesc )/_nTotLote,"@E 999,999.99")+' kg'
	//@ nlin,045 Psay '|Quebra peso transporte:'+ transform(_nQTransp2,'@E 999,999.99') + ' kg/Cab'  
	//@ nlin,095 psay '|Prenhez adiantada:     '+ transform(_nPrenAdi,'@E 999,999')+' Cab'
	nlin++

	@ nlin,000 psay Replicate('-',limite)
	//nlin++

	_nMaxLinha := len(_aTipGord)

	if len(_aClasProg) > _nMaxLinha
		_nMaxLinha :=  len(_aClasProg)
	elseif len(_aAnimFPad) > _nMaxLinha
		_nMaxLinha :=  len(_aAnimFPad)
	elseif len(_aDiagDoen) > _nMaxLinha
		_nMaxLinha :=  len(_aDiagDoen)
	endif            

	aSort(_aTipGord ,,,{|X,Y| X[1]< Y[1]})

	//@ nlin,01 psay '|TIPIFICAÇÕES DE GORDURA'   
	//@ nlin,34 psay '|CLASSIFICAÇÃO DE PROGRAMAS'   
	//@ nlin,65 psay '|ANIMAIS FORA DO PADRÃO'
	//@ nlin,93 psay '|DIAGNOSTICO DE DOENÇAS'
	//nlin++

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
			_cDescri := iif(_aTipGord[i][1] = '1',' (ausente)',;
			iif(_aTipGord[i][1] = '2',' (escassa)',;
			iif(_aTipGord[i][1] = '3',' (mediana)',;
			iif(_aTipGord[i][1] = '4',' (uniforme)',' (excessiva)'))))
			//@nlin,001 psay '|gordura ' +_aTipGord[i][1] + _cDescri +':' 
			//@nlin,025 psay  transform(_aTipGord[i][2],'@E 999') + ' Cab'  
		endif

		if len(_aClasProg) >= i
			_cDescri := iif(_aClasProg[i][1] = 'M','|Preço Medio:','|' + fBuscaCPO('SZ6',1,xfilial('SZ6')+_aClasProg[i][1],'Z6_DESC')+':')	
			//@nlin,034 psay alltrim(substr(lower(_cDescri),1,15))
			//@nlin,052 psay iif(_aClasProg[i][1] = 'M',transform(_aClasProg[i][2],'@E 999.99' + ' R$/kg'),transform(_aClasProg[i][2],'@E 999') + ' Cab')
		endif

		if len(_aAnimFPad) >= i
			_cDescri := '|' + fBuscaCPO('SZ6',1,xfilial('SZ6')+_aAnimFPad[i][1],'Z6_DESC')+':'	  
			//@nlin,065 psay alltrim(substr(lower(_cDescri),1,15)) + ':'
			//@nlin,080 psay transform(_aAnimFPad[i][2],'@E 999') + ' Cab'	
		endif

		if len(_aDiagDoen) >= i
			//@nlin,093 psay '|' + alltrim(lower(_aDiagDoen[i][2])) + ':'
			//@nlin,123 psay transform(_aDiagDoen[i][3],'@E 999') + ' Cab'		
		endif

		//nlin++
	next

	//Para listar os pedidos de compra    
	//@ nlin,000 psay Replicate('-',limite)
	//nlin++
	//@ nlin,01 psay '|DADOS DE COMPRA'   
	ListaPC()
	Cab_compra()  
	//nlin++ 

	aSort(_aPedCom ,,,{|X,Y| X[4] > Y[4]})

	_nTotVal := 0

	for i := 1 to len(_aPedCom)
		//@nlin,001 psay padc(_aPedCom[i][1],25,'') +;
		//	               padc(transform(_aPedCom[i][2],'@E 999,999'),22,'') +;
		//	               padc(transform(_aPedCom[i][3],'@E 999,999.99')+ ' kg',30,'') +;
		//	               padc('R$ ' + transform(_aPedCom[i][4],'@E 999.99'),27,'') +;
		//	               padc('R$ ' + transform(_aPedCom[i][5],'@E 999,999.99'),27,'')		

		_nTotVal +=  _aPedCom[i][5]              
		//nlin++
	next

	_nPrecoM := round(_nTotVal/( nPtot - totPedesc ),2)

	//Para listar os pedidos de compra    
	//@ nlin,000 psay Replicate('-',limite)
	//nlin++

	_cEMPREG := fBuscaCPO('SA2',1,xfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA),'A2_POSEMP')

	//Inserido "if" e bloco "Else" por Fabian Maurer para diferenciar a impressão quando fornecedor nao tiver empregado
	IF _cEMPREG <> '2'
		//@nlin,001 psay '|Preço médio lote:'+ transform(round(_nPrecoM,2),'@E 999,999.99')+ ' R$/kg' +;
		//space(03) + '|Total Fundesa: R$'+ transform(_nTotFUNDESA,'@E 999.99') +;
		//space(03) + '|Previd. Social: R$' + transform(_nPSocial,'@E 999,999.99')+;
		//space(03) + '|TOTAL A RECEBER: R$' + transform(iif(_natprod <> 'J',_nTotNF-(_nTotFUNDESA+_nPSocial),_nTotNF-_nTotFUNDESA),'@E 999,999.99')
	ELSE
		//@nlin,001 psay '|Preço médio lote:'+ transform(round(_nPrecoM,2),'@E 999,999.99')+ ' R$/kg' +;
		//space(03) + '|Total Fundesa: R$'+ transform(_nTotFUNDESA,'@E 999.99') +;
		//space(03) + '|Previd. Social: R$' + transform(_nPSocial,'@E 999,999.99')+;
		//space(03) + '|FunRural: R$' + transform(_nFunrural,'@E 999,999.99')
		//nlin++
		//@nlin,001 psay '|TOTAL A RECEBER: R$' + transform(iif(_natprod <> 'J',_nTotNF-(_nTotFUNDESA+_nPSocial+_nFunrural),_nTotNF-_nTotFUNDESA),'@E 999,999.99')
	ENDIF
	// Fim do bloco inserido por Fabian Maurer

	//nlin++

	//@ nlin,000 psay Replicate('-',limite)

Return

Static Function Cab_compra()
	//nlin++
	//@ nlin,01 psay '|'+padc('Pedido de compra',25,'')+;
	//               '|'+padc('Quantidade',25,'')+;
	//               '|'+padc('Peso',25,'')+;
	//               '|'+padc('Preço',25,'')+;
	//              '|'+padc('Sub-Total',25,'')+'|'                   
Return

//Função para apurar os pedidos de compra do lote
Static Function ListaPC()

	_cNumam     := SZE->ZE_NUMAM
	_cLote      := SZE->ZE_LOTE
	_aPedCom    := {}

	SC7->(DbOrderNickName("C7NUMAMLOT"))
	if SC7->(DbSeek(xFilial('SC7')+SZE->ZE_NUMAM+SZE->ZE_LOTE))

		_nTotFUNDESA := 0
		_nTotNF      := 0
		_nPSocial    := 0
		_nFunrural	 := 0

		DO WHILE !SC7->(EOF()) .AND. xFilial('SC7')+SZE->ZE_NUMAM+SZE->ZE_LOTE==SC7->(C7_FILIAL+C7_NUMAM+C7_LOTE)
			if SC7->C7_PCNOTA = 'NFP'
				SC7->(DbSkip())
				Loop
			endif  
			If nLin > 68
				Cab_Report()
				cab_Compra()
			Endif

			_nFUNDESA := SC7->C7_QTSEGUM * fBuscaCPO('SB1',1,xfilial('SB1')+SC7->C7_PRODUTO,'B1_FESA')


			_nTotFUNDESA += _nFUNDESA
			_nTotNF      += SC7->C7_TOTAL

			AADD(_aPedCom,{SC7->C7_NUM,SC7->C7_QTSEGUM,SC7->C7_QUANT,SC7->C7_PRECO,SC7->C7_TOTAL})

			SC7->(DbSkip())
		ENDDO

		_nPSocial := (val(substr(getmv("MV_CONTSOC"),5,3)))/100 * _nTotNF                             

		// Inicio Bloco Alterado por Fabian Maurer para inserir 
		//o valor do FUNRURAL quando fornecedor nao tiver empregado	
		_cEMPREG := fBuscaCPO('SA2',1,xfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA),'A2_POSEMP')          

		if _cEMPREG = '2'
			_nFunrural := 2.1/100 * _nTotNF
		endif
		// Final do bloco Fabian Maurer	
	else
		alert('Não há pedidos de compra!')
	endif

return

//Função que imprime o detalhamento (colunas) do relatorio
Static Function Det_report()

	_nCol := 12

	If nLin > 68
		Cab_Report()
		//nlin++

		//_Coluna61 := iif(mv_par05 = 1,padc('Carc',_nCol,''),padc('Codigo',_nCol,''))
		//_Coluna62 := iif(mv_par05 = 1,padc('Rast?',_ncol,''),padc('Comprador',_nCol,''))

		//@ nlin,00 psay '|'+padc('Sequencial',_nCol,'')+'|'+padc('Sequencial',_nCol,'')+'|'+padc('Peso',_nCol,'')   +'|'+;
		//padc('Idade',_nCol,'')     +'|'+padc('Classe',_nCol,'')    +'|'+_Coluna61               +'|'+;
		//padc('Destino',_nCol,'')   +'|'+padc('Preço',_nCol,'')     +'|'+padc('Raca do',_nCol,'')+'|'+;
		//padc('Programa',_nCol,'')  +'|'
		//nlin++
		//@ nlin,00 psay '|'+padc('Lote',_nCol,'')    +'|'+padc('Abate',_nCol,'')   +'|'+padc('Carcaça Fria',_nCol,'')+'|'
		//padc('Dentição',_nCol,'')+'|'+padc('Gordura',_nCol,'') +'|'+ _Coluna62                   +'|'+;
		//padc('Carcaça',_nCol,'') +'|'+padc('R$/Kg',_nCol,'')   +'|'+padc('Animal',_nCol,'')      +'|'+;
		//padc('de Carne',_nCol,'')+'|'
		//nlin++
	Endif

	npeso  := SZK->ZK_PETOTAL

	if SZK->ZK_IF = 'S' 
		if npeso > 200 
			npeso -= 10
		elseif npeso <=200
			npeso -= 7.5
		endif    
	endif                    

	totPedesc  += npeso * 0.02 

	_cSexo := fBuscaCPO('SZ4',1,xfilial('SZ4')+SZK->(ZK_NUMAM+ZK_LOTE),'Z4_SEXO')

	_Coluna6 := iif(mv_par05 = 1,iif(empty(SZK->ZK_RASTRO),'N','S'),_cNumComp)


	_cImpress := '|'+padc(strzero(SZK->ZK_ORDEM,3),_nCol,'') + '|'+padc(SZK->ZK_CONTROL,_nCol,'') +;
	'|' + padc(Transform( npeso-(npeso*0.02),'@E 9,999.99'),_nCol,'') +;
	'|' + padc(SZK->ZK_DENT,_nCol,'') +  '|' + padc(SZK->ZK_COBGOR,_nCol,'') + '|' + padc(_Coluna6,_nCol,'') + '|' 

	//nlin++

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
		_cRaca := fBuscaCPO('ZA8', 1, xFilial('ZA8')+SZK->ZK_RACA , 'ZA8_DESC')
		_cImpress += padc(_cRaca,_nCol,'') +'|' 
	else
		_cImpress += padc('',_nCol,'') +'|' 
	endif          

	// Coluna Programa 
	_cPrograma := ''		 
	_cPrograma := fBuscaCPO('SZ6', 1, xFilial('SZ6')+SZK->ZK_PROGRAM , 'Z6_DESC')

	_cImpress += padc(_cPrograma,_nCol,'') +'|' 

	//@ nlin,000 psay _cImpress  

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
Static Function PesoProp( receb, categ, rastreado  )  
	Private nPeso1 := 0
	SZR->( dbSetOrder(1) )
	SZR->( dbSeek(xFilial('SZR')+receb+categ ) ) 
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
	SZR->( dbSeek(xFilial('SZR')+receb+categ ) ) 
	While !SZR->(Eof()) .and. receb+categ == SZR->( ZR_RECEB+ZR_CATEG) 
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

	if ZA3->(DbSeek(xfilial('ZA3')+_cNumam+_cLote))  

		while ZA3->(!eof()) .and. ZA3->ZA3_FILIAL = xfilial('ZA3') .and. ;
		ZA3->ZA3_NUMAM = _cNumam .and. ;
		ZA3->ZA3_LOTE  = _cLote 

			//if ZA3->ZA3_CODCON $ '1/16/19/2/24/25/32/40/41/52/53/6/9'
			if alltrim(ZA3->ZA3_CODCON) $ '1/16/19/2/24/25/32/40/41/52/53/6/9/37/42'                                
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
