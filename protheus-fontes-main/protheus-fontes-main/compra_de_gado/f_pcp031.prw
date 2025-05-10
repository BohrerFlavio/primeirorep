#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"

User Function F_PCP031()

	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³F_PCP031  ºAutor  ³3V                  º Data ³  01/25/07   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDesc.     ³ Formacao do preco de venda do frigorifico                  º±±
	±±º          ³                                                            º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Sigapcp                                                    º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	cDesc1         := "Gera relat. Formacao de preço de venda do "
	cDesc2         := "frigorifico"
	cDesc3         := ""
	cPict          := ""
	titulo         := "Formação do preço de venda"
	nLin           := 80

	Cabec1         := ""
	Cabec2         := ""
	imprime        := .T.
	limite         := 120

	aOrd           := {}

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private tamanho      := "M"
	Private nomeprog     := "PCP031"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := 'PCP031'
	Private ddata1       := CTOD('')

	Private cString := "SZG"

	cPerg := "PCP031"

	If !Pergunte(cPerg,.T.)
		Return
	Endif

	dIni   := mv_par01
	dFim   := mv_par02

	cAvini := mv_par03
	cAvfim := mv_par04

	cLtini := mv_par05
	cLtfim := mv_par06

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
//
//
//
Static Function RunReport()

	aDENT := CTBCBOX('ZK_DENT')
	aFORM := CTBCBOX('ZK_CONFORM')
	aSEXO := CTBCBOX('ZK_SEXO')
	aDest := CTBCBOX('ZK_DESTINO')
	aObs  := CTBCBOX('ZK_OBS')

	SetRegua(SZG->(reccount()))

	SZG->(DbSetorder(2)) // data
	SZK->(DbSetorder(2)) // av matanca+lote
	SZD->(DbSetorder(1)) //
	SZ9->(DbSetOrder(1)) // numero+item

	SZG->(DbSeek( xFilial('SZG')+dtos(dini) ,.t. ) )

	//MsgBox( 'Vou entrar no laço SZG!', "Atenção", "ALERT" )
	While SZG->(!eof()) .AND. SZG->ZG_DATA <= dFim

		//        MsgBox( 'Vou entrar no Loop do SZG!', "Atenção", "ALERT" )
		If  SZG->ZG_NUMAM < cAvIni .OR. SZG->ZG_NUMAM > cAvFim
			SZG->(dbSkip())
			Loop
		Endif

		SZK->(DbSeek(xFilial('SZK')+SZG->ZG_NUMAM,.f.))

		cChave := SZK->(ZK_FILIAL+ZK_NUMAM)

		//Variaveis para o total de report

		aGord_TT   := {} // num,  nani, npeso, npmed, valtot, preco, no de machos
		nfem_TT    := 0
		npfem_TT   := 0
		nptot_TT   := 0
		nras_TT    := 0   // Contador de animais com rastreabilidade
		nRaca_TT   := 0   // Contador de animais da raça HereFord
		nani_TT    := 0
		nComi_TT   := 0
		nKm_TT     := 0
		nFrete_TT  := 0
		nVeic_TT   := 0
		nVivoP_TT  := 0
		nVivoF_TT  := 0

		aCateg_TT  := {}
		// 1-Categ, 2-Qtde Anim, 3-Vivo Prop(Kg), 4-Vivo Frig(Kg),5-Peso Abate(Kg), 6-Rend Prop(%),7-Rend Frig(%),
		// 8-Média vivo (kg),9-Média carcaça(kg),10-Valor do Kg
		// 11-total da compra, 12-falor do frete, 13-valor comissao, 14-valor da rastreabilidade,
		//MsgBox( 'Vou entrar no laço SZK!', "Atenção", "ALERT" )

		//--------------------------------------------------------------//
		// Laço de leitura dos lotes de gados comprados.                //
		// Esta tabela contém as informações individuais de cada aniaml //
		// do lote.                                                     //
		//--------------------------------------------------------------//
		While !SZK->(eof()) .and. cChave == SZK->(ZK_FILIAL+ZK_NUMAM)

			cNumam  := SZK->ZK_NUMAM
			cLote   := SZK->ZK_LOTE

			//--------------------------------------------------------------//
			// Só apanha os lotes solicitados.                              //
			//--------------------------------------------------------------//
			If SZK->ZK_LOTE < cLtini .OR. SZK->ZK_LOTE > cLtfim
				SZK->( dbSkip() )
				Loop
			Endif

			//Variaveis para o total de lote
			aGord     := {} // num,nani,npeso,npmed,valtot,preco,machos
			_aFrete   := {} // Matriz de calculo do frete.
			nptot     := 0  // peso produzido (ou carcaça) total do aviso+lote
			nras      := 0  // qtde animais rastraeados  do aviso+lote
			nRaca     := 0  // Contador de animais da raca HEREFORD
			nani      := 0  // no animais para matriz
			nComi     := 0  // comissao do aviso+lote
			nKm       := 0  // km total do aviso+lote
			nFrete    := 0  // frete proporcional do aviso+lote
			nVeic     := 0  // Quantidade de veículos envolvidos nos recebimentos deste aviso+lote
			nVivoF    := 0  // Peso vivo do frigorífico
			nVivoP    := 0  // Peso vivo da propriedade
			nTotBixo  := 0	// total de bixos produzidos neste aviso+lote
			totPedesc := 0  // total de peso com desconto do aviso+lote
			nRendF     := 0.00
			nRendP     := 0.00

			nVeicBixo := 0  // bixos transportados nos recebimentos envolvidos deste aviso+lote
			nFreteR   := 0  // valor pago de frete total nos recebimentos envolvidos deste aviso+lote
			_cComprador := '' // Nome do comprador
			_cProdutor  := '' // Nome do Produtor

			//--------------------------------------------------------------//
			// Posiciona nos ítens da ordem de recebimento.                 //
			//--------------------------------------------------------------//
			SZE->(DbSetorder(2)) //
			SZE->(DbSeek(xFilial('SZE')+cNumAm + cLote),.f.)

			//--------------------------------------------------------------//
			// Posiciona no cabeçalho da ordem de recebimento para pegar o  //
			// código do fornecedor e a loja.                               //
			//--------------------------------------------------------------//
			SZD->(DbSetorder(1)) // Filial + ZD_NUMERO
			SZD->(DbSeek(xFilial('SZD')+ SZE->ZE_NUMERO ) )

			//--------------------------------------------------------------//
			// Apanha o nome do Produtor.                                   //
			//--------------------------------------------------------------//
			SA2->(DbSeek(xFilial('SA2')+SZD->ZD_FORNECE + SZD->ZD_LOJA) )
			_cProdutor := SA2->A2_NOME

			//--------------------------------------------------------------//
			// Posiciona nos ítens da Solicitação de compra                 //
			//--------------------------------------------------------------//
			SZ9->(DbSeek(xFilial('SZ9')+SZE->ZE_NUMSC+SZE->ZE_ITEMSC ) )
			cCateg := alltrim(SZE->ZE_CATEG)

			//--------------------------------------------------------------//
			// Posiciona no cabeçalho da solicitação de compra.             //
			//--------------------------------------------------------------//
			SZA->(DbSeek(xFilial('SZA')+SZ9->Z9_NUMERO ) )

			//--------------------------------------------------------------//
			// Posiciona na tabela de compradores.                          //
			//--------------------------------------------------------------//
			SA3->(DbSeek(xFilial('SA3')+SZA->ZA_COMPRA ) )
			_cComprador := SA3->A3_NOME

			//--------------------------------------------------------------//
			// Enquanto for o mesmo lote, acumula os dados.                 //
			//--------------------------------------------------------------//
			//MsgBox( 'Vou entrar no skip do SZK!', "Atenção", "ALERT" )
			While !SZK->(eof()) .and. cNumam+cLote == SZK->(ZK_NUMAM+ZK_LOTE)
				Private _n := 0,; // Posição na matriz da classe de gordura no lote.
				_z := 0   // posicao na matriz da categoria

				Det_Report()
				nTotBixo++
				SZK->(DbSkip())
			Enddo

			//------------------------------------------------------//
			// Função responsável pelo cálculo do frete, da         //
			// kilometragem, do peso total dos animais no produtor  //
			// e no frigorífico.                                    //
			//------------------------------------------------------//
			//MsgBox( 'Vou entrar no busca_Frete()!', "Atenção", "ALERT" )
			busca_frete(@nFrete,@nVeic,@nKm)

			//MsgBox( 'Vou entrar no tot_lote!', "Atenção", "ALERT" )
			Tot_lote() // Imprime Val.Frete

			aCateg_TT[_z,12] += nFrete
			aCateg_TT[_z,13] += nComi
			aCateg_TT[_z,14] += nRas   // Contador de animais com rastreabilidade
			aCateg_TT[_z,15] += nRaca  // Contador de animais da raça HEREFORD - essa raça tem custo com bonificação


			nFrete_TT += nFrete  // Total geral do frete
			nComi_TT  += nComi   // Total geral de comissão do comprador
			nRas_TT   += nRas    // Total geral da rastreabilidade
			nRaca_TT  += nRaca   // Total geral da raça HEREFORD



		Enddo
		SZG->(DBSkip())
	Enddo

	//Totais do relatorio - analise por gordura
	//nlin+=3
	//MsgBox( 'Vou entrar no cab_report()!', "Atenção", "ALERT" )
	Cab_Report()
	//MsgBox( 'Vou entrar no tot_geral()!', "Atenção", "ALERT" )
	tot_geral()

	Set device to screen
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	//MsgBox( 'Chamando o MS_FLUSH!', "Atenção", "ALERT" )

	MS_FLUSH()

return


//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
static function tot_geral()
	Local i
	local _nAnimais := 0.00,;
	_nPesoTot := 0.00,;
	_nPesoMed := 0.00,;
	_nValLote := 0.00,;
	_nValLote := 0.00,;
	_nCustoFKg := 0.00,;
	_nMachos  := 0.00,;
	_nVivoPro := 0.00,;
	_nVivoFri := 0.00,;
	_nVivoMed := 0.00,;
	_nCarcMed := 0.00,;
	_nValMed  := 0.00,;
	_nValLucro := 0.00,;
	_nPerLucro := 0.00,;
	_nLiquido:= 0.00,;
	_nResBrutaimp:= 0.00,;
	totDebito  := 0.00,;
	totCredito := 0.00,;
	_nValVenda := 0.00,;
	_nSubProd  := 0.00,;
	_nLucro    := 0.00,;
	_nCustoKg  := 0.00,;
	_nuRast    := 0.00,;    // Rastreabilidade proporcional a esta classe de gordura
	_nuRaca    := 0.00      // Bonif. da Raça  proporcional a esta classe de gordura


	//-----------------------------------------------------------//
	// Impressão dos totais por gordura.                         //
	//-----------------------------------------------------------//
	@ nLin,048 Psay 'TOTAIS GERAIS POR GORDURA'
	nLin++

	@ nLin  ,016 Psay '+----------------------------------------------------------------------------------------+'
	@ nLin+1,016 Psay '| Gordura    NºAnimais   PesoTotal   PesoMédio     Vlr. Lote   Custo Kg Final  Custo Kg  |'
	@ nLin+2,016 Psay '| -------    ---------   ---------   ---------    ----------   --------------  --------  |'
	nLin += 3


	//---------------------------------------------------//
	// Calcula o peso total para calcular o custo        //
	// proporcional do frete, comissão e rastreabilidade //
	//---------------------------------------------------//
	_nPesoTot := 0.00
	_nPesoMed := 0.00
	_nCustoKg := 0.00
	_nuCustoFKg := 0.00
	_nuCustoKg  := 0.00
	_nValLote   := 0.00

	_NTComi  := 0.00    // Valor acumulado da comissão do comprador proporcional a esta classe de gordura
	_NTFrete := 0.00    // Valor acumulado do frete proporcional a esta classe de gordura
	_NTRast  := 0.00    // Rastreabilidade acumulada proporcional a esta classe de gordura
	_NTRaca  := 0.00    // Bonif. acumulada da Raça  proporcional a esta classe de gordura

	for i:=1 to len(aGord_TT)                        
		_nPesoTot += (aGord_TT[i,3] * 0.98)   // Tira 2% referente a perdas diversas  
	Next

	//_nKgmed :=   ( aGord_TT[1,3] * 0.98 ) / aGord_TT[1,2] // Deixe aqui para poder funcionar a fórmula abaixo.

	for i:=1 to len(aGord_TT)

		If nLin > 70
			Cab_Report()
		Endif

		//--------------------------------------------------------------//
		// Cálculo do peso líquido desta classe de gordura.             //
		//--------------------------------------------------------------//
		_nuPesoLiq := round(aGord_TT[i,3] * 0.98, 2)   // Tira 2% referente a perdas com congelamento


		//--------------------------------------------------------------//
		// Cálculo da comissão proporcional a esta classe de  gordura.  //
		//--------------------------------------------------------------//
		_nuComi    := round( (_nuPesoLiq * nComi_TT) /; // Peso líquido desta classe de gordura * Comissão total
		(_nPesoTot)           , 2) // Peso total líquido

		//--------------------------------------------------------------//
		// Cálculo do frete    proporcional a esta classe de  gordura.  //
		//--------------------------------------------------------------//
		_nuFrete   := round( (_nuPesoLiq * nFrete_TT) /; // Peso líquido desta classe de gordura * Valor do Frete
		(_nPesoTot)            , 2) // Peso total líquido

		//--------------------------------------------------------------//
		// Cálculo do custo com a bonificação referente à rastreabil.   //
		// do animal, proporcional a esta classe de  gordura.           //
		//--------------------------------------------------------------//
		_Rastro := _GetPar1()
		_nVlRas    := round( nRas_TT * _Rastro ,2)  // Valor total geral da rastreabilidade
		_nuRast    := round( (_nuPesoLiq * _nVlRas) /;          // Peso líquido desta classe de gordura * Valor da rastreabilidade
		(_nPesoTot)                   ,2)  // Peso total líquido

		//--------------------------------------------------------------//
		// Cálculo do custo com a bonificação referente à raça HEREFORD //
		// proporcional a esta classe de  gordura.                      //
		//--------------------------------------------------------------//
		_Bhere := _GetPar2()
		_nVlRaca   := round(nRaca_TT * _Bhere, 2)   // Valor total geral da da bonificação com a raça HEREFORD
		_nuRaca    := round((_nuPesoLiq * _nVlRaca) /;         // Peso líquido desta classe de gordura * Valor da raça HEREFORD
		(_nPesoTot)             ,2)        // Peso total líquido


		//--------------------------------------------------------------//
		// Cálculo do custo médio final por Kg e classe de gordura.     //
		//--------------------------------------------------------------//
		_nuCustoFKg := round(( aGord_TT[i,5] +;               // Valor em moeda acumulado desta classe de gordura
		_nuComi    +;                  // Valor da comissão do comprador proporcional a esta classe de gordura
		_nuFrete   +;                  // Valor do frete proporcional a esta classe de gordura
		_nuRast    +;                  // Rastreabilidade proporcional a esta classe de gordura
		_nuRaca     ) /;               // Bonif. da Raça  proporcional a esta classe de gordura
		(_nuPesoLiq)   ,2)              // peso liquido desta classe de gordura


		//--------------------------------------------------------------//
		// Cálculo do custo médio por Kg e classe de gordura.           //
		//--------------------------------------------------------------//
		_nuCustoKg := round(( aGord_TT[i,5] +;               // Valor em moeda acumulado desta classe de gordura
		_nuRast        +;              // Rastreabilidade proporcional a esta classe de gordura
		_nuRaca     ) /;               // Bonif. da Raça  proporcional a esta classe de gordura
		(_nuPesoLiq)   ,2)              // peso liquido desta classe de gordura



		_nKgmed := round(_nuPesoLiq / aGord_TT[i,2] ,2)      // Peso médio desta classe de gordura



		@ nLin,016 Psay '|'
		@ nLin,020 Psay aGord_TT[i,1] picture '99'                // Classe gordura
		@ nLin,031 Psay aGord_TT[i,2] picture '9999'              // Quantidade de animais
		@ nLin,039 Psay _nuPesoLiq    picture '@E 9999,999.99'    // peso total líquido
		@ nLin,051 Psay _nKgmed       picture '@E 9999,999.99'    // peso medio
		@ nLin,065 Psay aGord_TT[i,5] picture '@E 9999,999.99'	  // valor total desta classe de gordura
		@ nLin,084 Psay _nuCustoFKg   picture '@E 999.99'         // valor medio kg
		@ nLin,096 Psay _nuCustoKg    picture '@E 999.99'         // valor medio kg
		//	@ nLin,107 Psay aGord_TT[i,7] picture '@E 99999'	      // qtde de machos
		@ nLin,105 Psay '|'
		nLin++

		_nAnimais += aGord_TT[i,2]
		_nValLote += aGord_TT[i,5]
		_nMachos  += aGord_TT[i,7]

		_NTComi  += _nuComi    // Valor acumulado da comissão do comprador proporcional a esta classe de gordura
		_NTFrete += _nuFrete   // Valor acumulado do frete proporcional a esta classe de gordura
		_NTRast  += _nuRast    // Rastreabilidade acumulada proporcional a esta classe de gordura
		_NTRaca  += _nuRaca    // Bonif. acumulada da Raça  proporcional a esta classe de gordura


		//--------------------------------------------------------------//
		// Cálculo do custo médio final por Kg geral.                   //
		// ( com os valores da comissão do comprador e o frete.)        //
		//--------------------------------------------------------------//
		//    if _nCustoFKg > 0
		//       _nCustoFKg := ( _nCustoFKg + _nuCustoFKg ) / 2
		//    else
		//       _nCustoFKg := _nuCustoFKg
		//	endif    


		//--------------------------------------------------------------//
		// Cálculo do custo médio por Kg geral.                         //
		// ( sem os valores da comissão do comprador e o frete.)        //
		//--------------------------------------------------------------//
		//    if _nCustoKg > 0
		//       _nCustoKg := ( _nCustoKg + _nuCustoKg ) / 2
		//    else
		//       _nCustoKg := _nuCustoKg
		//	endif    

		//--------------------------------------------------------------//
		// Cálculo do peso médio.                                       //
		//--------------------------------------------------------------//
		if _nPesoMed > 0
			_nPesoMed := (_nPesoMed + _nKgmed ) / 2
		else
			_nPesoMed := _nKgmed
		endif    



	Next


	//--------------------------------------------------------------//
	// Cálculo do custo médio final por Kg e classe de gordura.     //
	//--------------------------------------------------------------//
	_nCustoFKg := round(( _nValLote  +;      // Valor em moeda acumulado desta classe de gordura
	_NTComi    +;      // Valor da comissão do comprador proporcional a esta classe de gordura
	_NTFrete   +;      // Valor do frete proporcional a esta classe de gordura
	_NTRast    +;      // Rastreabilidade proporcional a esta classe de gordura
	_NTRaca     ) /;   // Bonif. da Raça  proporcional a esta classe de gordura
	(_nPesoTot)   ,2)   // peso liquido desta classe de gordura


	//--------------------------------------------------------------//
	// Cálculo do custo médio por Kg e classe de gordura.           //
	//--------------------------------------------------------------//
	_nCustoKg := _nValLote / _nPesoTot
	//_nCustoKg := round(( _nValLote  +;       // Valor em moeda acumulado desta classe de gordura
	//                     _nuRast    +;       // Rastreabilidade proporcional a esta classe de gordura
	//                     _nuRaca     ) /;    // Bonif. da Raça  proporcional a esta classe de gordura
	//                    (_nPesoTot)   ,2)    // peso liquido desta classe de gordura




	@ nLin  ,016 Psay '+----------------------------------------------------------------------------------------+'
	@ nLin+1,016 Psay '| Totais..:'
	nLin++
	@ nLin,031 Psay _nAnimais               picture '9999'              // qtde
	@ nLin,039 Psay _nPesoTot               picture '@E 9999,999.99'    // peso total líquido
	@ nLin,051 Psay _nPesoTot / _nAnimais   picture '@E 9999,999.99'    // peso medio
	//@ nLin,051 Psay _nPesoMed               picture '@E 9999,999.99'    // peso medio
	@ nLin,065 Psay _nValLote               picture '@E 9999,999.99'	// valor total
	//@ nLin,065 Psay _nCustoKg * _nPesoTot   picture '@E 9999,999.99'	// valor total

	@ nLin,084 Psay _nCustoFKg              picture '@E 999.99'         // valor medio por kilo com comissão, frete, rastreabilidade e bonif.Raça Hereford
	@ nLin,096 Psay _nCustoKg               picture '@E 999.99'         // valor medio kg sem comissão e frete
	//@ nLin,107 Psay _nMachos                picture '@E 99999'	        // qtde de machos
	@ nLin,105 Psay '|'
	@ nLin+1,016 Psay '+----------------------------------------------------------------------------------------+'
	nLin += 2


	//-----------------------------------------------------------//
	// Impressão dos totais gerais por Categoria.                //
	//-----------------------------------------------------------//
	//Totais do relatório - analise por categoria
	// 1-Categ, 2-Qtde Anim, 3-Vivo Prop(Kg), 4-Vivo Frig(Kg),5-Peso Abate(Kg), 6-Rend Prop(%),7-Rend Frig(%),
	// 8-Média vivo (kg),9-Média carcaça(kg),10-Valor do Kg
	// 11-total da compra, 12-falor do frete, 13-valor comissao, 14-valor da rastreabilidade,

	//processa os totais da categoria
	for i:=1 to len(aCateg_TT)

		//--------------------------------------------------------------//
		// Cálculo do peso líquido desta categoria.                     //
		//--------------------------------------------------------------//
		//    _nuPesoLiq := aCateg_TT[i,5] * 0.98   // Tira 2% referente a perdas diversas

		//  aCateg_TT[i,6]  := _nuPesoLiq     / aCateg_TT[i,3] * 100 //rend prop
		//  aCateg_TT[i,7]  := _nuPesoLiq     / aCateg_TT[i,4] * 100 //rend frigo
		aCateg_TT[i,8]  := aCateg_TT[i,3] / aCateg_TT[i,2]       //média vivo prop
		aCateg_TT[i,9]  := aCateg_TT[i,4] / aCateg_TT[i,2]       //média carcaça produzido
		//  aCateg_TT[i,10] := aCateg_TT[i,10]/ aCateg_TT[i,2]       //valor médio do kg
	next i


	@ nLin,047 Psay 'TOTAIS GERAIS POR CATEGORIA'
	nLin++

	@ nLin  ,000 Psay '+----------------------------------------------------------------------------------------------------------------------+'
	@ nLin+1,000 Psay '|             |          |        Peso (kg)         |  Produzido  |      Media(Kg)    |   Custo por Kg  |     Custo    |'
	@ nLin+2,000 Psay '|  Categoria  |  Qtde.   |  Vivo Prop.  Vivo Frig.  |     (Kg)    |   Vivo   Carcaça  |  Final  Parcial |     Total    |'
	@ nLin+3,000 Psay '|-------------+----------+--------------------------+-------------+-------------------+-----------------|--------------+'
	nLin += 4

	_nVivoMed  := iif(len(aCateg_TT) > 0, aCateg_TT[1,8], 0)          // Deixe aqui para poder fechar a fórmula abaixo
	//_nCarcMed  := aCateg_TT[1,9]          // Deixe aqui para poder fechar a fórmula abaixo
	_nCustoFKg := 0.00                    // Custo final por kilo.
	_nuCustoFKg := 0.00
	_nuCustoKg  := 0.00
	_nTVlPago  := 0.00                    // Valor total pago.

	_NTComi  := 0.00    // Valor acumulado da comissão do comprador proporcional a esta classe de gordura
	_NTFrete := 0.00    // Valor acumulado do frete proporcional a esta classe de gordura
	_NTRast  := 0.00    // Rastreabilidade acumulada proporcional a esta classe de gordura
	_NTRaca  := 0.00    // Bonif. acumulada da Raça  proporcional a esta classe de gordura

	for i := 1 to len(aCateg_TT)
		If nLin > 70
			Cab_Report()
		Endif

		//--------------------------------------------------------------//
		// Cálculo do peso líquido desta classe de gordura.             //
		//--------------------------------------------------------------//
		_nuPesoLiq := round(aCateg_TT[i,5] * 0.98,2)   // Tira 2% referente a perdas diversas

		//--------------------------------------------------------------//
		// Cálculo da comissão proporcional a esta classe de  gordura.  //
		//--------------------------------------------------------------//
		_nuComi    := round((_nuPesoLiq * nComi_TT) /; // Peso líquido desta classe de gordura * Comissão total
		(_nPesoTot)   ,2)                // Peso total líquido

		//--------------------------------------------------------------//
		// Cálculo do frete    proporcional a esta classe de  gordura.  //
		//--------------------------------------------------------------//
		_nuFrete   := round((_nuPesoLiq * nFrete_TT) /; // Peso líquido desta classe de gordura * Valor do Frete
		(_nPesoTot)    ,2)                // Peso total líquido


		//--------------------------------------------------------------//
		// Cálculo do custo com a bonificação referente à rastreabil.   //
		// do animal, proporcional a esta classe de categoria.          //
		//--------------------------------------------------------------//
		_Rastro := _GetPar1()
		_nVlRas    := round(nRas_TT * _Rastro ,2)  // Valor total geral da rastreabilidade
		_nuRast    := round((_nuPesoLiq * _nVlRas) /;      // Peso líquido desta classe de categoria * Valor da rastreabilidade
		(_nPesoTot), 2)                    // Peso total líquido

		//--------------------------------------------------------------//
		// Cálculo do custo com a bonificação referente à raça HEREFORD //
		// proporcional a esta classe de categoria animal (Boi, vaca)   //
		//--------------------------------------------------------------//
		_Bhere := _GetPar2()
		_nVlRaca   := round(nRaca_TT * _Bhere ,2)   // Valor total geral da da bonificação com a raça HEREFORD
		_nuRaca    := round((_nuPesoLiq * _nVlRaca) /;     // Peso líquido desta classe de categoria * Valor da raça HEREFORD
		(_nPesoTot) ,2)                   // Peso total líquido

		//--------------------------------------------------------------//
		// Cálculo do custo médio por Kg e categoria.                   //
		//--------------------------------------------------------------//
		_nuCustoFKg := round(( aCateg_TT[i,11] +;           // Valor em moeda acumulado desta categoria
		_nuComi    +;                  // Valor da comissão do comprador proporcional a esta classe de gordura
		_nuFrete   +;                  // Valor do frete proporcional a esta classe de gordura
		_nuRast    +;                  // Rastreabilidade proporcional a esta classe de categoria
		_nuRaca     ) /;               // Bonif. da Raça  proporcional a esta classe de categoria
		(_nuPesoLiq) ,2)               // peso liquido desta classe de gordura


		//--------------------------------------------------------------//
		// Cálculo do custo médio por Kg e categoria.       .           //
		//--------------------------------------------------------------//
		_nuCustoKg := aCateg_TT[i,11] / _nuPesoLiq
		//	_nuCustoKg := round(( aCateg_TT[i,11] +;            // Valor em moeda acumulado desta classe de gordura
		//	               _nuRast        +;              // Rastreabilidade proporcional a esta classe de categoria
		//	               _nuRaca     ) /;               // Bonif. da Raça  proporcional a esta classe de categoria
		//	               (_nuPesoLiq)  , 2)                 // peso liquido desta classe de gordura


		_nKgmed := round(_nuPesoLiq / aCateg_TT[i,2],2)          // Peso médio desta categoria
		//    _nKgmed := round(_nuPesoLiq / aGord[i,2],2)            // Peso médio desta classe de gordura


		@ nLin,000 Psay '|'
		@ nlin,003 Psay Left(POSICIONE("SZ5",1,XFILIAL("SZ5")+aCateg_TT[i,1],"Z5_DESC"),10)
		@ nLin,014 Psay '|'
		@ nlin,017 Psay aCateg_TT[i,2]                     picture '9999'              //qtde
		@ nLin,025 Psay '|'
		@ nlin,027 Psay aCateg_TT[i,3]                     picture '@E 9999,999.99'    // Peso vivo na propriedade
		@ nlin,039 Psay aCateg_TT[i,4]                     picture '@E 9999,999.99'    // Peso vivo no frigorífico

		@ nLin,052 Psay '|'
		@ nlin,053 Psay _nuPesoLiq                         picture '@E 9999,999.99'    //peso produzido  (ou carcaça)
		@ nLin,066 Psay '|'

		//  @ nlin,079 Psay aCateg_TT[i,6]                     picture '@E 999.99'     	// rendimento prop
		//  @ nlin,088 Psay aCateg_TT[i,7]                     picture '@E 999.99'     	// rendimento frig

		@ nlin,067 Psay aCateg_TT[i,8]                     picture '@E 9,999.99'    // média vivo
		@ nlin,076 Psay _nuPesoLiq / aCateg_TT[i,2]        picture '@E 9,999.99'    // média carcaça
		//    @ nlin,076 Psay aCateg_TT[i,9]                     picture '@E 9,999.99'    // média carcaça
		@ nLin,086 Psay '|'


		@ nlin,088 Psay _nuCustoFKg                        picture '@E 999.99'      // Custo médio por Kg final (com todos os custos)
		@ nlin,097 Psay _nuCustoKg                         picture '@E 999.99'      // Custo médio por Kg parcial (sem o frete e a comissão do comprador)
		@ nLin,104 Psay '|'

		@ nlin,106 Psay aCateg_TT[i,11]                    picture '@E 9,999,999.99'  // Valor médio pago.
		//  @ nlin,106 Psay _nuPesoLiq * _nuCustoKg            picture '@E 9,999,999.99'  // Valor médio pago.
		@ nLin,119 Psay '|'

		nLin++

		_nTVlPago  += aCateg_TT[i,11]  // Valor total pago

		_nVivoPro += aCateg_TT[i,3]
		_nVivoFri += aCateg_TT[i,4]

		_nVivoMed := (_nVivoMed + aCateg_TT[i,8]) / 2
		//    _nCarcMed := (_nuPesoLiq / aCateg_TT[i,2]) / 2

		_NTComi  += _nuComi    // Valor acumulado da comissão do comprador proporcional a esta classe de gordura
		_NTFrete += _nuFrete   // Valor acumulado do frete proporcional a esta classe de gordura
		_NTRast  += _nuRast    // Rastreabilidade acumulada proporcional a esta classe de gordura
		_NTRaca  += _nuRaca    // Bonif. acumulada da Raça  proporcional a esta classe de gordura

		//--------------------------------------------------------------//
		// Cálculo do custo médio por Kg geral.                         //
		//--------------------------------------------------------------//
		//    if _nCustoFKg > 0
		//       _nCustoFKg := ( _nCustoFKg + _nuCustoFKg ) / 2
		//    else
		//       _nCustoFKg := _nuCustoFKg
		//	endif    

		//--------------------------------------------------------------//
		// Cálculo do custo médio por Kg geral.                         //
		// ( sem os valores da comissão do comprador e o frete.)        //
		//--------------------------------------------------------------//
		//    if _nCustoKg > 0
		//       _nCustoKg := round(( _nCustoKg + _nuCustoKg ) / 2  ,2)
		//    else
		//       _nCustoKg := _nuCustoKg
		//	endif    

	Next

	//--------------------------------------------------------------//
	// Cálculo do custo médio final por Kg e classe de gordura.     //
	//--------------------------------------------------------------//
	_nCustoFKg := round(( _nValLote  +;      // Valor em moeda acumulado desta classe de gordura
	_NTComi    +;      // Valor da comissão do comprador proporcional a esta classe de gordura
	_NTFrete   +;      // Valor do frete proporcional a esta classe de gordura
	_NTRast    +;      // Rastreabilidade proporcional a esta classe de gordura
	_NTRaca     ) /;   // Bonif. da Raça  proporcional a esta classe de gordura
	(_nPesoTot)   ,2)   // peso liquido desta classe de gordura


	//--------------------------------------------------------------//
	// Cálculo do custo médio por Kg e classe de gordura.           //
	//--------------------------------------------------------------//
	_nCustoKg := round(( _nValLote  +;       // Valor em moeda acumulado desta classe de gordura
	_nuRast    +;       // Rastreabilidade proporcional a esta classe de gordura
	_nuRaca     ) /;    // Bonif. da Raça  proporcional a esta classe de gordura
	(_nPesoTot)   ,2)    // peso liquido desta classe de gordura



	@ nLin  ,000 Psay '|-------------+----------+--------------------------+-------------+-------------------+-----------------|--------------+'
	nLin++
	@ nLin,000 Psay '|  Totais..:  |'
	@ nLin,017 Psay _nAnimais               picture '9999'              //qtde
	@ nLin,025 Psay '|'
	@ nLin,027 Psay _nVivoPro               picture '@E 9999,999.99'    //Vivo Prop
	@ nLin,039 Psay _nVivoFri               picture '@E 9999,999.99'    //vivo Frigorífico
	@ nLin,052 Psay '|'
	@ nLin,053 Psay _nPesoTot               picture '@E 9999,999.99'	//Peso Produzido  (ou carcaça)
	@ nLin,066 Psay '|'

	@ nlin,067 Psay _nVivoPro / _nAnimais   picture '@E 9,999.99'     	//média vivo
	@ nlin,076 Psay _nPesoTot / _nAnimais   picture '@E 9,999.99'     	//média carcaça
	//@ nlin,076 Psay _nVivoFri / _nTAnimais  picture '@E 9,999.99'     	//média carcaça
	@ nLin,086 Psay '|'

	@ nLin,088 Psay _nCustoFKg              picture '@E 999.99'         // Custo médio por Kg final (com todos os custos)
	@ nLin,097 Psay _nTVlPago / _nPesoTot   picture '@E 999.99'         // Custo médio por Kg parcial (sem o frete e a comissão do comprador)
	//@ nLin,097 Psay _nCustoKg               picture '@E 999.99'         // Custo médio por Kg parcial (sem o frete e a comissão do comprador)
	@ nLin,104 Psay '|'

	@ nlin,106 Psay _nTVlPago               picture '@E 9,999,999.99'  // Valor médio pago.
	//@ nlin,106 Psay _nCustoKg * _nPesoTot   picture '@E 9,999,999.99'  // Valor médio pago.
	@ nLin,119 Psay '|'
	nLin++
	@ nLin  ,000 Psay '+----------------------------------------------------------------------------------------------------------------------+'
	nLin += 2

	//-----------------------------------------------------------//
	// Impressão dos totais gerais por Categoria x Rentabilidade //
	//-----------------------------------------------------------//
	@ nLin,048 Psay 'TOTAIS GERAIS POR CATEGORIA x RENTABILIDADE'
	nLin++

	@ nLin  ,004 Psay '+---------------------------------------------------------------------------------------------------------------+'
	@ nLin+1,004 Psay '|           D E S P E S A S          |           R E C E I T A S           |         R E S U L T A D O          |'
	nLin += 2


	//Fechamento por categoria

	_nuReceitas := 0.00  // Total receitas da categoria
	_nuDespesas := 0.00  // Total despesas da categoria
	totCredito  := 0.00  // Total receitas geral
	totDebito   := 0.00  // Total despesas geral


	fechCompra := 0
	fechFrete  := 0
	fechComis  := 0
	fechRastro := 0
	fechRaca   := 0
	fechKg     := 0

	fechAchb    := 0
	fechAbate   := 0
	fechImposto := 0
	fechCredito := 0
	fechVenda   := 0
	fechSub     := 0
	fechCabeca  := 0

	For i := 1 To Len(aCateg_TT)

		If nLin > 64
			Cab_Report()
		Endif



		// busca dados vindo dos parâmetros
		SZQ->(dbSetOrder(1) )//data+categoria
		SZQ->(dbSeek(xFilial('SZQ')+DTOS(ddata1)+aCateg_TT[i,1]) )

		//-----------------------------------------------------//
		// Cálculo dos créditos                                //
		//-----------------------------------------------------//
		_nValVenda := SZQ->ZQ_VENDA * (aCateg_TT[i,5] * 0.98)  // Abate 2% do peso referente a perda com resfriamento.
		_nSubProd  := SZQ->ZQ_SUBPROD * aCateg_TT[i,2]    // Valor unitário * quantidade da categoria


		//--------------------------------------------------------------//
		// Cálculo do custo com a bonificação referente à rastreabil.   //
		// do animal, proporcional a esta classe de categoria.          //
		//--------------------------------------------------------------//
		_Rastro := _GetPar1()
		_nVlRas    := aCateg_TT[i,14] * _Rastro  // Valor total geral da rastreabilidade

		//--------------------------------------------------------------//
		// Cálculo do custo com a bonificação referente à raça HEREFORD //
		// proporcional a esta classe de categoria animal (Boi, vaca)   //
		//--------------------------------------------------------------//
		_Bhere := _GetPar2()
		_nVlRaca   := aCateg_TT[i,15] * _Bhere   // Valor total geral da da bonificação com a raça HEREFORD

		//--------------------------------------------------------------//
		// Cálculo do valor do imposto sobre o valor de venda e o       //
		// valor do subproduto. O imposto é dado em percentual.         //
		//--------------------------------------------------------------//
		_nuVlImpost := (_nValVenda + _nSubProd) * (SZQ->ZQ_IMPOSTO / 100)

		//--------------------------------------------------------------//
		// Cálculo do valor do abate: Valor da cabeça * qt. animais     //
		//--------------------------------------------------------------//
		_nuVlAbate := SZQ->ZQ_VLRDESP * aCateg_TT[i,2]

		//-----------------------------------------------------//
		// Cálculo do lucro (Receitas - despesas)              //
		//-----------------------------------------------------//
		_nuReceitas := SZQ->ZQ_CREDIT + _nValVenda + _nSubProd
		_nuDespesas := (aCateg_TT[i,11]  + ;   // Débitos: Compra
		aCateg_TT[i,12]  + ;   // 	       Frete
		aCateg_TT[i,13]  + ;   //          Comissão
		_nVlRas          + ;   //          Bônus Rastreab.
		_nVlRaca         + ;   //          Bônus Raça HEREFORD.
		SZQ->ZQ_ACBH     + ;   //          ACHB
		_nuVlAbate       + ;   //          Abate
		_nuVlImpost        )   //          Impostos

		_nLucro    :=  _nuReceitas - _nuDespesas

		//-----------------------------------------------------//
		// Percentual de lucro = lucro / despesas.             //
		//-----------------------------------------------------//
		_nPLucro := _nLucro / _nuDespesas
		_cPL     := Transform(_nPLucro * 100, '@E 999.99' )


		@ nLin,004 Psay '+-[ Categoria:'
		@ nLin,019 Psay Left(POSICIONE("SZ5",1,XFILIAL("SZ5")+aCateg_TT[i,1],"Z5_DESC"),10)
		@ nLin,029 Psay ']-----------+-------------------------------------+------------------------------------+'
		nLin++

		@ nLin  ,004 Psay '|  Val.Compra.......:'  + Transform(aCateg_TT[i,11], '@E 999,999,999.99' )
		@ nLin  ,041 Psay '| Val.Credito........:' + Transform(SZQ->ZQ_CREDIT,  '@E 999,999,999.99' )
		@ nLin  ,079 Psay '|   Result.('+_cPL +'%).:' + Transform(_nLucro,     '@E 999,999,999.99' )
		@ nLin  ,116 Psay '|'
		nLin++

		@ nLin  ,004 Psay '|  Val.Frete........:'  + Transform(aCateg_TT[i,12], '@E 999,999,999.99' )
		@ nLin  ,041 Psay '| Val.Venda  ('         + Transform(SZQ->ZQ_VENDA,   '@E 999.99' ) + '):' +;
		Transform(_nValVenda,      '@E 999,999,999.99' )
		@ nLin  ,079 Psay '|'
		@ nLin  ,116 Psay '|'
		nLin++

		@ nLin  ,004 Psay '|  Val.Comissao.....:'  + Transform(aCateg_TT[i,13], '@E 999,999,999.99' )
		@ nLin  ,041 Psay '| Vl.Subprod.('         + transform(SZQ->ZQ_SUBPROD, '@E 999.99' ) + '):' +;
		Transform(_nSubProd,       '@E 999,999,999.99' )
		@ nLin  ,079 Psay '|'
		@ nLin  ,116 Psay '|'
		nLin++

		@ nLin  ,004 Psay '|  Val.Rastreab.....:'  + Transform(_nVlRas, '@E 999,999,999.99' )
		@ nLin  ,041 Psay '|'
		@ nLin  ,079 Psay '|'
		@ nLin  ,116 Psay '|'
		nLin++

		@ nLin  ,004 Psay '|  Val.Raça HEREFORD:'  + Transform(_nVlRaca, '@E 999,999,999.99' )
		@ nLin  ,041 Psay '|'
		@ nLin  ,079 Psay '|'
		@ nLin  ,116 Psay '|'
		nLin++

		@ nLin  ,004 Psay '|  Val.ACHB.........:'  + Transform(SZQ->ZQ_ACBH,    '@E 999,999,999.99' )
		@ nLin  ,041 Psay '|'
		@ nLin  ,079 Psay '|'
		@ nLin  ,116 Psay '|'
		nLin++

		@ nLin  ,004 Psay '|  Val.Abate(' + Transform(SZQ->ZQ_VLRDESP,    '@E 999.99' ) + '):' + ;
		Transform(_nuVlAbate     ,    '@E 999,999,999.99' )
		@ nLin  ,041 Psay '|'
		@ nLin  ,079 Psay '|'
		@ nLin  ,116 Psay '|'
		nLin++

		@ nLin  ,004 Psay '|  Vl.Impost(' + Transform(SZQ->ZQ_IMPOSTO,    '@E 99.99' ) + '%):'  + ;
		Transform(_nuVlImpost,        '@E 999,999,999.99' )
		@ nLin  ,041 Psay '|'
		@ nLin  ,079 Psay '|'
		@ nLin  ,116 Psay '|'
		nLin++

		@ nLin  ,004 Psay '|'
		@ nLin  ,041 Psay '|'
		@ nLin  ,079 Psay '|'
		@ nLin  ,116 Psay '|'
		nLin++


		fechCabeca  += aCateg_TT[i,2 ]
		fechCompra  += aCateg_TT[i,11]
		fechFrete   += aCateg_TT[i,12]
		fechComis   += aCateg_TT[i,13]
		fechRastro  += _nVlRas
		fechRaca    += _nVlRaca
		fechKg      += aCateg_TT[i,5]  * 0.98   // Remove 2% referente a perdas diversas.

		fechAchb    += SZQ->ZQ_ACBH
		fechAbate   += _nuVlAbate
		fechImposto += _nuVlImpost
		fechCredito += SZQ->ZQ_CREDIT
		fechVenda   += _nValVenda
		fechSub     += _nSubProd

		totCredito  += _nuReceitas
		totDebito   += _nuDespesas

	Next i   

	_nPorc := (mv_par07 * 100)
	_nValLucro := (totCredito - totDebito)     
	_nLiquido := (_nValLucro) * (1 - mv_par07)	// Aplica a porcentagem do ultimo parâmetro
	_nPerLucro := (_nValLucro / totDebito) * 100
	_nResBruta := ((totCredito-totDebito)/fechCabeca)    
	_nBruto := _nResBruta * (1 - mv_par07)// Aplica a porcentagem do ultimo parâmetro
	_nResLiq   := (totCredito-totDebito)/fechKg

	@ nLin  ,004 Psay '+---------------------------------------------------------------------------------------------------------------+'
	@ nLin+1,004 Psay '|  Total Despesas...:'  + Transform( totDebito,                         '@E 999,999,999.99' )
	@ nLin+1,041 Psay '| Resultado(' + Transform( _nPerLucro,                                   '@E 999.99' ) + '%).:' +;
	Transform( _nValLucro,                                   '@E 999,999,999.99' )
	@ nLin+1,079 Psay '| Resultado/Cabeça..:'  + Transform(_nResBruta , '@E 999,999,999.99' ) + '  |'

	@ nLin+2,004 Psay '|  Total Receitas...:'+Transform( totCredito,                        '@E 999,999,999.99' )
	@ nLin+2,041 Psay '|'
	@ nLin+2,079 Psay '| Resultado/Kg......:'  + Transform(_nResLiq ,     '@E 999,999,999.99' ) + '  |'
	@ nLin+3,004 Psay '|
	@ nLin+3,041 Psay '| Result.Liq('+ Transform( _nPorc,        								'@E 999.99' ) + '%):'+;
	Transform(_nLiquido , 									'@E 999,999,999.99' ) 
	@ nLin+3,079 Psay '| Result.Liq('+ Transform( _nPorc,'@E 999.99' ) + '%):'+;
	Transform(_nBruto ,     '@E 99,999,999.99' ) + '  |'
	@ nLin+4,004 Psay '+---------------------------------------------------------------------------------------------------------------+'
	nLin += 4


	//? margem de contribuicao será o  percentual do resultado sobre o débito?

Return
//
//
//
Static Function Cab_report()
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin   := 6
Return



//-----------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------//
// Função..: Busca_Frete
// Objetivo: Função responsável pelo cálculo do frete, da kilometragem, do peso total
//           dos animais no produtor e no frigorífico.
//-----------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------//
Static Function busca_frete(nFrete,nVeic,nKm)
	Local i
	l_aFrete := {}

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
	//MsgBox( 'Entrei no laço 1!', "Atenção", "ALERT" )


	//--------------------------------------------------------------//
	// 1° - Laço de leitura dos ítens da ordem de recebimento só do //
	// lote desejado (Preciso pegar placas, data, hora, qt. etc)    //
	//--------------------------------------------------------------//
	SZE->(DbSetorder(2)) //
	SZE->(DbSeek(xFilial('SZE')+cNumAm + cLote),.f.)

	While !SZE->(Eof()) .AND. SZE->( ZE_NUMAM+ZE_LOTE ) == cNumAm+cLote

		cReceb := SZE->ZE_NUMERO

		While ! SZE->( Eof() ) .AND. SZE->ZE_NUMERO == cReceb
			SZE->(dbSkip())
		Enddo

		//--------------------------------------------------------------//
		// 2° - Posiciona no cabeçalho do recebimento para ver quem     //
		//      pagará o frete.                                         //
		//--------------------------------------------------------------//
		SZD->(DbSetorder(1)) // Filial + ZD_NUMERO
		SZD->( dbSeek(xFilial('SZD') + cReceb ) )
		_dData  := SZD->ZD_DATA   // A data será sempre a mesma no mesmo lote.

		//--------------------------------------------------------------//
		// 3° - Varre os ítens do recebimento para apanhar a placa e a  //
		//      hora deste.                                             //
		//--------------------------------------------------------------//
		SZS->( dbSetOrder(1) )   //numero + placa
		SZS->( dbSeek(xFilial('SZS')+ cReceb ) )

		While !SZS->(Eof()) .AND.  SZS->ZS_NUMERO == cReceb


			//--------------------------------------------------------------//
			// Frete por conta do comprador.                                //
			//--------------------------------------------------------------//
			//if SZD->ZD_TPFRETE == 'F'
			//--------------------------------------------------------------//
			//  1 - Número do recebimento;                                  //
			//  2 - Placa do veículo;                                       //
			//  3 - Hora do recebimento;                                    //
			//  4 - Valor do frete;                                         //
			//  5 - Quantidade de animais do lote desejado;                 //
			//  6 - Quantidade de animais dos demais lotes que foram trans- //
			//      portados no mesmo frete.                                //
			//  7 - Data do lote.                                           //
			//--------------------------------------------------------------//
			//----------------------------------------------------//
			// Cada ZS_NUMERO, ZS_PLACA e ZS_HORA pode se repetir.//
			//----------------------------------------------------//
			aadd(_aFrete,{SZS->ZS_NUMERO, SZS->ZS_PLACA, SZS->ZS_HORA, SZS->ZS_VAVE, SZS->ZS_QTANIM,0,_dData})
			nVeic++                                       // Quantidade de veículos
			nKm       += SZS->ZS_DCHPREV + SZS->ZS_DASFPR // Kilometros percorridos sem pavimento e com pavimento.


			// parei aqui
			/*
			if cLote $ '000005'
			MsgBox( 'Lote: ' + cLote + ' OR:' + cReceb + ' Qt. Veículos:' + str(nVeic) + ' Km:' + str(nKm)  , "Atenção", "ALERT" )
			MsgBox( 'aFrete ' + cLote + ' OR:' + cReceb + ' Placa: ' + SZS->ZS_PLACA +;
			' Hora: ' + SZS->ZS_HORA + 'Vl.Frete:'+ str(SZS->ZS_VAVE) +;
			' Qt.Animais: ' + str(SZS->ZS_QTANIM) + 'Data: ' + dtoc(_dData) , "Atenção", "ALERT" )
			endif
			*/



			//endif

			SZS->(dbSkip())
		enddo

		//----------------------------------------------------//
		// Apanha o peso do lote no frigorífico e no produtor //
		// Esses valores estão agrupados por categoria.       //
		//----------------------------------------------------//
		nVivoF  += PesoRend( 'F', cReceb, cCateg, cNumam+cLote ) // SZR->ZR_PESOFRI = Peso frigorífico.
		nVivoP  += PesoRend( 'P', cReceb, cCateg, cNumam+cLote ) // SZR->ZR_PESO    = Peso na propriedade do pecuarista

		// Matriz de dados por categoria
		aCateg_TT[_z,3] += nVivoP
		aCateg_TT[_z,4] += nVivoF

	Enddo


	nRendF :=   (nPtot * 0.98) / nVivoF * 100  //Rendimento frigorifico = Peso líquido / Rendimento
	nRendP :=   (nPtot * 0.98) / nVivoP * 100  //Rendimento propriedade = Peso líquido / Rendimento


	//--------------------------------------------------------------//
	// Agora que já sei quais são as placas e horas que fazem parte //
	// deste lote, posso varrer todos os SZS para saber se o        //
	// caminhão transportou outros lotes (de outros produtores).    //
	//--------------------------------------------------------------//
	//MsgBox( 'Entrei no laço 2!', "Atenção", "ALERT" )

	//--------------------------------------------------------------//
	// Deixa este índice para verificar se o SDS é do mesmo aviso   //
	// de matança.                                                  //
	//--------------------------------------------------------------//
	SZE->(DbSetorder(1)) // Filial + ZE_NUMERO


	//--------------------------------------------------------------//
	// 4° - Varrer o SZD para todos os registros nesta data;        //
	//--------------------------------------------------------------//
	SZD->(DbSetorder(3)) // Filial + ZD_DATA
	SZD->( dbSeek(xFilial('SZD') + dtos(_dData) ) )  // _dData foi pega no início da função pelo lote desejado

	While !SZD->(Eof()) .AND. dtos(SZD->ZD_DATA) == dtos(_dData)


		//--------------------------------------------------------------//
		// Frete por conta do comprador.                                //
		//--------------------------------------------------------------//
		/*
		if SZD->ZD_TPFRETE <> 'F'
		SZD->(dbSkip())
		loop
		endif
		*/

		//--------------------------------------------------------------//
		// Posiciona nos ítens da ordem de recebimento para             //
		// verificar se faz parte do mesmo aviso de matança.            //
		//--------------------------------------------------------------//
		SZE->(DbSeek(xFilial('SZE')+SZD->ZD_NUMERO),.f.)


		//--------------------------------------------------------------//
		// Laço de leitura dos ítens da ordem de recebimento.           //
		// Cálculo da Km, valor frete  e No de veiculos do lote.        //
		//--------------------------------------------------------------//
		While !SZE->(Eof()) .AND. SZE->ZE_NUMERO == SZD->ZD_NUMERO

			//--------------------------------------------------------------//
			// Se não for do mesmo aviso de matança então pula.             //
			//--------------------------------------------------------------//
			if SZE->ZE_NUMAM <> cNumAm
				SZE->(dbSkip())
				loop
			endif


			//--------------------------------------------------------------//
			//   Varre apenas só 1 registro da mesma Ordem de Recebimento   //
			//   pois como quero pegar o total de animais em SZS não posso  //
			//   duplicar.                                                  //
			//--------------------------------------------------------------//
			_cNumero    := SZE->ZE_NUMERO

			While ! SZE->( Eof() ) .AND. SZE->ZE_NUMERO == _cNumero
				SZE->(dbSkip())
			Enddo

			//--------------------------------------------------------------//
			// 5° - Varrer os registros de SZS para cada SZE a procura de   //
			//      mais lotes netes mesmos fretes.                         //
			//--------------------------------------------------------------//
			SZS->( dbSetOrder(1) )   //numero + placa
			SZS->( dbSeek(xFilial('SZS')+ _cNumero ) )
			_x := _Y := 0
			While !SZS->(Eof()) .AND.  SZS->ZS_NUMERO == _cNumero



				//--------------------------------------------------------------//
				// Se for o mesmo registro então não precisa carregar novamente.//
				//--------------------------------------------------------------//
				_y := ASCAN(_aFrete, {|x| x[1]+x[2]+x[3]==SZS->ZS_NUMERO+SZS->ZS_PLACA+SZS->ZS_HORA})
				_x := ASCAN(_aFrete, {|x|      x[2]+x[3]==               SZS->ZS_PLACA+SZS->ZS_HORA})

				//--------------------------------------------------------------//
				// Se não for o mesmo registro e (placa e hora) forem os mesmos,//
				// então o caminhão transportou mais de um lote ao mesmo tempo. //
				// Neste caso o valor do lote é o total e deve ser dividido     //
				// pela quantidade de animais transportados.                    //
				//--------------------------------------------------------------//
				if _x > 0 .and. empty(_y)
					_aFrete[_x,6] += SZS->ZS_QTANIM   // Quantidade total de animais.


					// Parei aqui			   
					/*	
					if cLote $ '000005'
					MsgBox( 'OR:' + _aFrete[_x,1] + ' Qt. Veículos:' + str(nVeic) + ' Km:' + str(nKm)  , "Atenção", "ALERT" )
					MsgBox( 'OR:' + _aFrete[_x,1] + ' Placa: ' + _aFrete[_x,2] +;
					' Hora: ' + _aFrete[_x,3] + 'Vl.Frete:'+ str(_aFrete[_x,4]) +;
					' Qt.Animais: ' + str(_aFrete[_x,5]) +;
					' Qt.Anim.++: ' + str(_aFrete[_x,6]) +;
					' Data: ' + dtoc(_aFrete[_x,7])+;
					' Número,Placa,Hora,Frete: '+ SZS->ZS_NUMERO + ',' + SZS->ZS_PLACA + ',' + SZS->ZS_HORA + ',' + str(SZS->ZS_VAVE) , "Atenção", "ALERT" )
					endif	   
					*/			   
				endif	
				SZS->(dbSkip())
			enddo
			SZE->(dbSkip())
		enddo
		SZD->(dbSkip())
	enddo

	// Parei aqui
	/*
	if cLote $ '000005'
	MsgBox( 'Saí dos laços!', "Atenção", "ALERT" )
	endif
	*/

	//--------------------------------------------------------------//
	// 6° - Agora sim podemos calcular o frete com segurança.       //
	//--------------------------------------------------------------//
	_nTotQtBixos := 0.00
	_nLotQtBixos := 0.00
	_nTotFrete   := 0.00
	for i := 1 to len(_aFrete)
		_nTotQtBixos += (_aFrete[i,5] + _aFrete[i,6]) // Quantidade de animais no frete.
		_nLotQtBixos +=  _aFrete[i,5]                 // Quantidade de animais do lote.
		_nTotFrete   += _aFrete[i,4]                  // Valor do frete em moeda
	next i

	// Alterei aqui
	_nLotQtBixos := ntotBixo     // Total de animais do lote.
	nFrete := If( _nTotFrete > 0, (_nTotFrete / _nTotQtBixos) * _nLotQtBixos , 0 )

	//Parei aqui
	/*
	if cLote $ '000005'
	MsgBox( 'Valor do frete do lote 5:' + str(nFrete) , "Atenção", "ALERT" )
	endif
	*/

return

//-----------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------//
// Função..: Tot_lote()
// Objetivo: Impressão dos detalhes do lote e do resumo por gordura do lote
//-----------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------//
Static Function Tot_lote()
	Local i
	local _nQtd          :=    0,;
	_nPesoTot      := 0.00,;
	_nPesoMed      := 0.00,;
	_nValTot       := 0.00,;
	_nCustoFKg     := 0.00,;
	_nuCustoFKg    := 0.00,;
	_nCustoKg      := 0.00,;
	_nuCustoKg     := 0.00,;
	_nKgmed        := 0.00,;
	_nVlMed        := 0.00,;
	_cTipoCompra   := '',;
	_nQuebraTransp := 0.00,;
	_nVlRas        := 0.00,;
	_nVlRaca       := 0.00

	//--------------------------------------------------------------//
	// Cálculo da comissão.                                         //
	//--------------------------------------------------------------//
	//SC7->(DbSetOrder(20))
	SC7->(DBordernickname('C7NUMAMLOT'))      // verificar e testar
	SC7->(DbSeek(xFilial('SC7')+cNumAm+cLote ) )
	teste := 0.00
	//--------------------------------------------------------------//
	// Laço de leitura dos pedidos de compra para buscar a comissão //
	// do comprador.                                                //
	//--------------------------------------------------------------//
	While !SC7->(EOF()) .AND. xFilial('SC7')+cNumAm+cLote == SC7->(C7_FILIAL+C7_NUMAM+C7_LOTE)
		nComi += SC7->C7_COMISS  
		SC7->(DbSkip())
	Enddo

	ddata1 := SZG->ZG_DATA

	Cb1 := "Abate em: " + dtoc(ddata1) + space(29) + "Comprador..: " + left(_cComprador,35) + "  Lote.........: " + cLote
	Cb2 := "Produtor: " + Left(_cProdutor,35)    + "  Procedencia: " + left(SA2->A2_MUN,35) + "            Aviso Matança: " + cNumAm


	//Cb1 := "Abate em: " + dtoc(ddata1) + space(28) + "Aviso da Matança: " + cNumAm + "  Lote: " + cLote
	//Cb2 := "Produtor: " + Left(SA2->A2_NOME,35) + " Procedencia: " + SA2->A2_MUN

	//--------------------------------------------------------------//
	// Impressão do cabeçalho do relatório.                         //
	//--------------------------------------------------------------//
	If nLin > 58
		Cab_Report()
	Endif

	//--------------------------------------------------------------//
	// Impressão do cabeçalho do lote.                              //
	//--------------------------------------------------------------//
	@ nlin,000 psay Replicate('-',limite)
	nlin++
	@ nLin,000 psay Cb1
	nLin++
	@ nLin,000 psay Cb2
	nlin++
	@ nlin,000 psay Replicate('-',limite)
	nlin++

	//--------------------------------------------------------------//
	// Impressão dos detalhes do lote.                              //
	//--------------------------------------------------------------//
	_nQuebraTransp := ((nVivoP - nVivoF) / nVivoP ) * 100
	_cuCateg        := POSICIONE("SZ5",1,XFILIAL("SZ5")+cCateg,"Z5_DESC")
	@ nlin,000 Psay 'Qtde Animais.:       ' +transform(ntotBixo,'9999')
	@ nLin,030 Psay 'Peso líquido:   '      +Transform( nPtot - totPedesc ,'@E 999,999.99')
	@ nLin,061 Psay 'Quebra Transp:  '      +transform(_nQuebraTransp     ,'@E 999,999.99') + '%'
	//@ nLin,061 Psay 'Peso Bruto...:  '    +transform(nPtot,'@E 999,999.99')
	@ nLin,092 Psay 'Categoria...: '        + _cuCateg
	nlin++

	//@ nLin,Pcol()+1 Psay 'Peso líquido: '+Transform( nPtot - totPedesc ,'@E 999,999.99')
	//@ nLin,Pcol()+1 Psay 'Peso  Total : '+transform(nPtot,'@E 999,999.99')

	//-----------------------------------------------------------//
	// Impressão dos custos com bonificação sobre os animais com //
	// rastreabilidade e da raça HEREFORD.                       //
	//-----------------------------------------------------------//
	_nVlRas  := nRas * GETMV('MV_BRASTRO')  // Quantidade * valor da bonificação unitário
	_nVlRaca := nRaca * GETMV('MV_BHERE')   // Quantidade * valor da bonificação unitário

	if (_nVlRas + _nVlRaca)  > 0
		@ nLin,000 Psay 'Qtde. Rastro.:        ' +transform(nRas,   '9999')
		@ nlin,030 Psay 'Bonif.Rastro.:   '      +transform(_nVlRas,'@E 99,999.99')
		@ nLin,061 Psay 'Qt.Hereford..:        ' +transform(nRaca,  '9999')
		@ nlin,092 Psay 'Bonif.Hford.:     '     +transform(_nVlRaca,'@E 99,999.99')
		nLin++
	endif

	if (nVivoP + nRendP + nVivoF + nRendf) > 0
		@ nLin,000 Psay 'Vivo Propried: '     +transform(nVivoP,'@E 999,999.99')+'Kg'
		@ nlin,030 Psay 'Rend. Prop...:      '+Transform(nRendP,'@e 999.99')+'%'
		@ nLin,061 Psay 'Vivo Frigorif:  '    +transform(nVivoF,'@E 999,999.99')+'Kg'
		@ nlin,092 Psay 'Rend. Frig..:        '+Transform(nRendf,'@e 999.99')+'%'
		nLin++
	endif

	//@ nlin,Pcol()+1 Psay 'Rend. Prop: '+Transform(nRendP,'@e 999.99')
	//@ nLin,Pcol()+1 Psay 'Vivo Frigorif: '+transform(nVivoF,'@E 999,999.99')
	//@ nlin,Pcol()+1 Psay 'Rend. Frig: '+Transform(nRendf,'@e 999.99')


	//-------------------------------------------------------------//
	// Verifica o tipo de compra do lote.                          //
	//-------------------------------------------------------------//
	if alltrim(SZA->ZA_TPCOM) = 'F'
		_cTipoCompra := 'FECHADO'
	elseif alltrim(SZA->ZA_TPCOM) = 'V'
		_cTipoCompra := 'VIVO'

	elseif alltrim(SZA->ZA_TPCOM) = 'R'
		_cTipoCompra := 'RENDIMENTO'
	else
		_cTipoCompra := 'Inexistente!'
	endif                                                              

	//teste := fBuscaCPO('SC7',20,xfilial('SC7')+cNumAm+cLote,'C7_COMISS')
	//teste := SC7->(DbSeek(xFilial('SC7')+,'C7_COMISS'))
	//alert(cNumAm+' - '+cLote+CVALTOCHAR(teste))
	//	alert('animais: '+CVALTOCHAR(ntotBixo)+'AVISO '+cNumAm+cLote)
	//	alert('Comissao: '+CVALTOCHAR(SC7->C7_COMISS))  
	@ nLin,000 Psay 'Km...........:    '      +Transform(nKm,'@E 999,999')
	@ nLin,030 Psay 'Val.Frete...:   '        +Transform(nFrete,'@e 999,999.99')
	@ nLin,061 Psay 'No.Veiculo...:          '+Transform(nVeic,'99')
	@ nlin,092 Psay 'Comissão....:     '       +Transform(nComi,'@e 99,999.99')

	nlin++
	@ nLin,000 Psay 'Preço Inicial:  '        +Transform(SZ9->Z9_PRECO,'@E 99,999.99') + ' R$/Kg'
	@ nlin,092 Psay 'Tip.Compra..: '           + _cTipoCompra
	nlin++



	//@ nLin,Pcol()+1 Psay 'Val.Frete:  '+Transform(nFrete,'@e 999,999.99')
	//@ nLin,Pcol()+1 Psay 'No.Veicul:  '+Transform(nVeic,'99')
	//@ nlin,Pcol()+1 Psay 'Comissão: '+Transform(nComi,'@e 99,999.99')

	//--------------------------------------------------------------//
	// Impressão da tabela de acumulados por gordura.               //
	//--------------------------------------------------------------//
	@ nlin  ,26 psay '+----------------------------------------------------------------------------------+'
	@ nlin+1,26 psay '| Gordura NºAnimais   Peso Liq.   PesoMédio    Vlr. Lote   Custo Kg Final Custo Kg |'
	@ nlin+2,26 psay '+ ------- ---------   ---------   ---------    ---------   -------------- -------- |'
	nlin += 3

	//_nCustoFKg := (aGord[1,5]/aGord[1,3])  // Inicia com este valor para a média abaixo dar certo

	for i:=1 to len(aGord)
		If nLin > 70
			Cab_Report()
		Endif

		//--------------------------------------------------------------//
		// Cálculo do peso líquido desta classe de gordura.             //
		//--------------------------------------------------------------//
		_nuPesoLiq := aGord[i,3] * 0.98   // Tira 2% referente a perdas diversas


		//-------------------------------------------------------------//
		// Se o tipo de compra for VIVO, muda o valor  do lote.        //
		//-------------------------------------------------------------//
		_nuVlote := aGord[i,5]

		if _cTipoCompra == 'VIVO'

			//--------------------------------------------------------//
			// Neste caso muda o cálculo do valor do lote.            //
			// Passa a ser preço inicial (tratado) * peso propriedade.//
			// Como o peso propriedade está cadastrado por categoria  //
			// e precisamos achar ele por classe de gordura, então    //
			// faremos a formula da proporção da seguinte forma:      //
			// 1°- Achamos o percentual desta classe de gordura em    //
			//     relação ao peso líquido total do lote.             //
			// 2°- Aplicamos este percentual sobre o peso propriedade.//
			//--------------------------------------------------------//
			_per := (_nuPesoLiq * 100) /  (nPtot - totPedesc) // Apanha a proporção desta gordura em relação ao peso total líquido

			_nuVlote := SZ9->Z9_PRECO * (nVivoP * (_per/100) )       // Apanha o preço propriedade proporcional.
		endif

		//--------------------------------------------------------------//
		// Corrige o valor total dos lotes por classe de gordura.       //
		//--------------------------------------------------------------//
		// Matriz de valores acumulados pela gordura  do animal.        //
		//--------------------------------------------------------------//
		y := ASCAN(aGord_TT, {|x| x[1]==aGord[i,1]})       //faixa gordura
		aGord_TT[y,5] += _nuVlote


		//--------------------------------------------------------------//
		// Corrige o valor total dos lotes por categoria.               //
		//--------------------------------------------------------------//
		// Matriz de valores acumulados pela gordura  do animal.        //
		//--------------------------------------------------------------//
		y := ASCAN(aCateg_TT, {|x| x[1]==cCateg})       // Categoria
		aCateg_TT[y,11] += _nuVlote                     // Custo total por categoria.


		//--------------------------------------------------------------//
		// Cálculo da comissão proporcional a esta classe de  gordura.  //
		//--------------------------------------------------------------//
		_nuComi    := (_nuPesoLiq * nComi) /; // Peso líquido desta classe de gordura * Comissão total
		(nPtot - totPedesc)     // Peso total líquido

		//--------------------------------------------------------------//
		// Cálculo do frete    proporcional a esta classe de  gordura.  //
		//--------------------------------------------------------------//
		_nuFrete   := (_nuPesoLiq * nFrete) /; // Peso líquido desta classe de gordura * Valor do Frete
		(nPtot - totPedesc)      // Peso total líquido

		//--------------------------------------------------------------//
		// Cálculo rastreabil. proporcional a esta classe de  gordura.  //
		//--------------------------------------------------------------//
		_nuRast    := (_nuPesoLiq * _nVlRas) /;  // Peso líquido desta classe de gordura * Valor da rastreabilidade
		(nPtot - totPedesc)        // Peso total líquido

		//--------------------------------------------------------------//
		// Cálculo bonif.Raça  proporcional a esta classe de  gordura.  //
		//--------------------------------------------------------------//
		_nuRaca    := (_nuPesoLiq * _nVlRaca) /; // Peso líquido desta classe de gordura * Valor da bonif.pela raça HEREFORD
		(nPtot - totPedesc)        // Peso total líquido

		//--------------------------------------------------------------//
		// Cálculo do custo médio por Kg por classificação de gordura.  //
		//--------------------------------------------------------------//
		_nuCustoFKg := ( _nuVlote +;                  // Valor acumulado desta classe de gordura
		_nuComi    +;                  // Valor da comissão do comprador proporcional a esta classe de gordura
		_nuFrete   +;                  // Valor do frete proporcional a esta classe de gordura
		_nuRast    +;                  // Rastreabilidade proporcional a esta classe de gordura
		_nuRaca     ) /;               // Bonif. da Raça  proporcional a esta classe de gordura
		(_nuPesoLiq)                   // peso liquido desta classe de gordura

		_nuCustoKg  := ( _nuVlote +;                  // Valor acumulado desta classe de gordura
		_nuRast    +;                  // Rastreabilidade proporcional a esta classe de gordura
		_nuRaca     ) /;               // Bonif. da Raça  proporcional a esta classe de gordura
		(_nuPesoLiq)                   // peso liquido desta classe de gordura


		_nKgmed := _nuPesoLiq / aGord[i,2]            // Peso médio desta classe de gordura

		@ nlin,026 psay '|'
		@ nlin,030 Psay aGord[i,1]  picture '99'                // Classificação da gordura
		@ nlin,037 Psay aGord[i,2]  picture '9999'              // qtde de animais
		@ nlin,046 Psay _nuPesoLiq  picture '@E 9999,999.99'    // peso líquido
		@ nlin,058 Psay _nKgmed     picture '@E 9999,999.99'    // peso medio  (Antes era aGord[i,4])
		@ nlin,071 Psay _nuVlote    picture '@E 9999,999.99'	// valor do lote nesta classe de gordura
		@ nlin,091 Psay _nuCustoFKg picture '@E 999.99'         // Custo médio por kilo para esta classe de gordura
		// Considerando: Frete, comissão e rastreabilidade

		@ nlin,101 Psay _nuCustoKg picture '@E 999.99'          // Custo médio por kilo para esta classe de gordura
		// DESconsiderando: Comissão e frete
		@ nlin,109 psay '|'
		nlin++

		_nQtd     += aGord[i,2]      // Acumula as quantidade por gordura
		_nPesoTot += _nuPesoLiq      // Acumula peso líquido  por gordura
		_nValTot  += _nuVlote        // Acumula valor total   por gordura

		//    _nCustoFKg := ( _nCustoFKg + _nVlMed ) / 2   // Custo médio por Kg.

	Next

	//--------------------------------------------------------------//
	// Cálculo do custo médio final por kg de todo o lote.          //
	//--------------------------------------------------------------//
	_nCustoFKg := ( _nValTot +;                   // Valor total do lote
	nComi    +;                    // Valor da comissão do comprador
	nFrete   +;                    // Valor do frete
	_nVlRas  +;                    // Valor total da Rastreabilidade
	_nVlRaca    ) /;               // Bonif. da Raça  proporcional ao peso líquido do lote
	(nPtot - totPedesc)            // peso liquido total das carcaças


	//--------------------------------------------------------------//
	// Cálculo do custo médio por kg de todo o lote.                //
	//--------------------------------------------------------------//
	_nCustoKg := ( _nValTot +;                    // Valor total do lote
	_nVlRas  +;                    // Valor total da Rastreabilidade
	_nVlRaca    ) /;               // Bonif. da Raça  proporcional ao peso líquido do lote
	(nPtot - totPedesc)            // peso liquido total das carcaças



	_nPesoMed := _nPesoTot / _nQtd            // Peso total / Qtd. Animais do lote (Antes era aGord[i,4])


	//--------------------------------------------------------------//
	// Impressão do total da tabela de acumulados por gordura.      //
	//--------------------------------------------------------------//
	@ nlin  ,26 psay '+----------------------------------------------------------------------------------+'
	nlin++
	@ nlin,026 psay '| Totais.:'
	@ nlin,037 Psay _nQtd      picture '9999'              //qtde
	@ nlin,046 Psay _nPesoTot  picture '@E 9999,999.99'    //peso total
	@ nlin,058 Psay _nPesoMed  picture '@E 9999,999.99'    //peso medio
	@ nlin,071 Psay _nValTot   picture '@E 9999,999.99'	   //valor total
	@ nlin,091 Psay _nCustoFKg picture '@E 999.99'         //valor medio total com frete, comissão, rastreabilidade e bonificação da raça HEREFORD.

	@ nlin,101 Psay _nCustoKg  picture '@E 999.99'         //valor medio só com rastreabilidade
	@ nlin,109 psay '|'
	nlin++

	@ nlin  ,26 psay '+----------------------------------------------------------------------------------+'
	nlin++
Return
//--------------------------------------------------------------------//
//--------------------------------------------------------------------//
// Funtion:                                                           //
// Objetivo: Acumular os valores referentes ao lote, classe de        //
//           gordura e de categoria.                                  //
//--------------------------------------------------------------------//
//--------------------------------------------------------------------//
Static Function Det_report()

	nDent  := ASCAN(aDent, {|x| left(x,1)==SZK->ZK_DENT})
	nForm  := ASCAN(aForm, {|x| left(x,1)==SZK->ZK_CONFORM})
	nSexo  := ASCAN(aSexo, {|x| left(x,1)==SZK->ZK_SEXO})
	ndest  := ASCAN(aDEst, {|x| left(x,1)==SZK->ZK_DESTINO})
	nobs   := ASCAN(aobs,  {|x| left(x,1)==SZK->ZK_OBS})

	npeso  := SZK->ZK_PETOTAL

	//----------------------------------------------------//
	// Se houve inspeção federal, então subtrai o peso da //
	// amostra.                                           //
	//----------------------------------------------------//
	if SZK->ZK_IF = 'S'

		//----------------------------------------------------//
		// Se a carcaça possui mais de 200Kg, subtrai 20Kg    //
		// do contrário subtrai apenas 15Kg.                  //
		//----------------------------------------------------//
		if npeso >= 200
			npeso -= 10
		else
			npeso -= 7.5
		endif
	endif

	totPedesc  += npeso*2/100

	//--------------------------------------------------------------//
	// Matriz de valores acumulados pela gordura dentro do lote.    //
	//--------------------------------------------------------------//
	_n := ASCAN(aGord, {|x| x[1]==SZK->ZK_COBGOR})          //faixa gordura
	if empty(_n)
		//--------------------------------------------------------------//
		//  1 - Código de classificação do animal pela gordura          //
		//  2 - Quantidade de animais.                                  //
		//  3 - Peso acumulado sem o pedaço da amostra.                 //
		//  4 - Peso acumulado na propriedade por classe de gordura no  //
		//      lote.                                                   //
		//  5 - Preço Bonificado * peso por classe de gordura no lote   //
		//  6 - Preço Bonificado unitário por classe de gordura no lote //
		//--------------------------------------------------------------//
		aadd(aGord,{0,0,0,0,0,0})
		_n := len(aGord)
		aGord[_n,1] := SZK->ZK_COBGOR
	endif

	//--------------------------------------------------------------//
	// Matriz de valores acumulados pela gordura  do animal.        //
	//--------------------------------------------------------------//
	_y := ASCAN(aGord_TT, {|x| x[1]==SZK->ZK_COBGOR})       //faixa gordura
	if empty(_y)
		//--------------------------------------------------------------//
		//  1 - Código de classificação do animal pela gordura          //
		//  2 - Quantidade de animais.                                  //
		//  3 - Peso acumulado sem o pedaço da amostra.                 //
		//  4 - Não utilizado                                           //
		//  5 - Preço Bonificado * peso total do lote                   //
		//  6 - Preço Bonificado unitário.                              //
		//  7 - Quantidade de machos.                                   //
		//--------------------------------------------------------------//
		aadd(aGord_TT,{0,0,0,0,0,0,0})
		//
		_y := len(aGord_TT)
		aGord_TT[_y,1] := SZK->ZK_COBGOR
	endif

	//--------------------------------------------------------------//
	// Matriz de valores acumulados por Categoria do animal.        //
	//--------------------------------------------------------------//
	//--------------------------------------------------------------//
	//  1 - Código da categoria do animal;                          //
	//  2 - Quantidade de animais por categoria;                    //
	//  3 - Acumula peso dos animais no produtor;                   //
	//  4 - Acumula peso dos animais no frigorífico;                //
	//  5 - Peso bruto acumulado na categoria;                      //
	// *6 - Percentual de rendimento sobre peso na propriedade;     //
	// *7 - Percentual de rendimento sobre o peso no frigorífico;   //
	//  8 - Peso médio dos animais na propriedade;                  //
	//  9 - Peso médio dos animais produzidos;                      //
	// *10- Valor médio por Kg;                                     //
	//  11- Custo total por categoria (tudo - imposto);             //
	//  12- Acumula o valor do frete;                               //
	//  13- Acumula o valor da comissão;                            //
	//  14- Qt. Animais com custo de rastreabilidade.               //
	//  15- At. animais com custo ref. Raça HEREFORD. (mais caro)   //
	//                                                              //
	//  * Reservado, porém não utilizado.                           //
	//--------------------------------------------------------------//
	_z := ASCAN(aCateg_TT, {|x| x[1]==cCateg } )       //categoria
	if empty(_z)
		aadd(aCateg_TT,{0,0,0,0,0,;
		0,0,0,0,0,;
		0,0,0,0,0   } )
		_z := len(aCateg_TT)
		aCateg_TT[_z,1] := cCateg
	endif

	// 1-Categ, 2-Qtde Anim, 3-Vivo Prop(Kg), 4-Vivo Frig(Kg),5-Peso Abate(Kg), 6-Rend Prop(%),7-Rend Frig(%),
	// 8-Média vivo (kg),9-Média carcaça(kg),10-Valor do Kg, 15- Contador de animais da raça HereFord


	// no de animais
	aGord[_n,2]++
	aGord_TT[_y,2]++
	aCateg_TT[_z,2]++

	// peso do abate
	aGord[_n,3]     += npeso
	aGord_TT[_y,3]  += npeso
	aCateg_TT[_z,5] += npeso

	//valor
	// Parei aqui - Verificar as matrizes abaixo0 para ver se está tudo ok com a mudança para o peso líquidio.

	aGord[_n,5]      += ( (npeso * 0.98) * SZK->ZK_PRECOBON )  // Preço Bonificado por classe de gordura no lote

	//------------------------------------------------------------------//
	// Não será calculado aqui, mas durante a impressão do lote porque  //
	// o preço do lote depende do tipo do lote.                         //
	//------------------------------------------------------------------//
	//aGord_TT[_y,5]   += ( (npeso * 0.98) * SZK->ZK_PRECOBON )  // Preço Bonificado total no lote
	//aCateg_TT[_z,10] += ( (npeso * 0.98) * SZK->ZK_PRECOBON )
	//aCateg_TT[_z,11] += ( (npeso * 0.98) * SZK->ZK_PRECOBON )

	aGord[_n,6]    := SZK->ZK_PRECOBON           // Preço bonificado unitário
	aGord_TT[_y,6] := SZK->ZK_PRECOBON

	If SZK->ZK_SEXO == 'M'
		aGord_TT[_y,7] := aGord_TT[_y,7] + 1
	Endif

	nani++

	npTot += npeso

	//----------------------------------------------------------//
	// Acumula o total de animais com controle de rastreamento  //
	//----------------------------------------------------------//
	if !empty(SZK->ZK_RASTRO) .AND. SZ9->Z9_RASTRO == 'S'
		nRas++
	endif

	//----------------------------------------------------------//
	// Acumula o total de animais da raça Hereford.             //
	// Essa raça tem custo de bonificação.                      //
	//----------------------------------------------------------//
	if SZK->ZK_RACA == '002'
		nRaca++
	endif

Return



/*----------------------------------------------------------------

17.04.2007  Raul

Colocar no total de lote
Peso vivo
Frete, Km,No de veiculos, No de animais do lote(ok) , Valor da comissao
Bonus de rastreabilidade do lote
Total de rendimento do lote total carcaca/peso vivo

----------------------------------------------------
Totalizar por tipo de gordura

tipo  Qtde   Kg   Valor No de Machas
0
1
2
3

-----------------------------------------------------
Totais do crédito ??

TOTAL MACHOS  :  Kg produzido  Kg vivo -  rendimento , média de peso por animal, valor do Kg
TOTAL FEMEAS  :
TOTAL ANIMAIS :

-----------------------------------------

Espécie Bois

Espécie Vacas

*/


/*****
* Function PesoRend
* Indica o peso da categoria e tipo rastro
*/

Static Function PesoRend( tipo , receb , cCateg, aviso )
	Private ppeso := 0

	//Pocisiono a Op de ordem de mantaça
	SZ4->( dbSetOrder(1) ) //aviso + lote
	SZ4->( dbSeek(xFilial('SZ4')+aviso ) )

	//localiza a tabela recebi x pesos categoria
	SZR->( dbSetOrder(1) ) //numero recebi
	SZR->( dbSeek(xFilial('SZR')+receb+cCateg ) )

	//Localiza a categ x rastro correta
	Private lachei := .F.
	While !Eof() .AND. SZR->ZR_RECEB == receb  .AND. SZR->ZR_CATEG == cCateg
		If SZ4->Z4_RASTRO == SZR->ZR_RASTRO
			lAchei := .T.
			Exit
		Endif
		SZR->( dbSkip() )
	Enddo

	If lAchei
		If    tipo == 'F'
			ppeso := SZR->ZR_PESOFRI    // Peso frigorífico
		ElseIf  tipo == 'P'
			ppeso := SZR->ZR_PESO       // Peso na propriedade do pecuarista
		Endif
	Endif

Return ppeso


Static Function _GetPar1()

	_cRet := GETMV('MV_BRASTRO')

Return(_cRet)


Static Function _GetPar2()

	_cRet := GETMV('MV_BHERE')

Return(_cRet)

