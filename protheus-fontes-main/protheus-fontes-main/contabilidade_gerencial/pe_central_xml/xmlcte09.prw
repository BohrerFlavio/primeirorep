#Include 'Protheus.ch'
/*/{Protheus.doc} XMLCTE09
Ponto de entrada para ajustar código de produto e TES conforme regra de nota vinculada 
@type function
@version  
@author Lauschner Consulting Ltda - Marcelo Alberto Lauschner
@since 03/12/2023
@return variant, return_description
/*/
User Function XMLCTE09()

	// Variável aItem  Private dentro da Central XML e contém o vetor da SD1 para lançamento de cada CTE
	// Variável aCab  Private dentro da Central XML e contém o vetor da SF1 para o lançamento de cada CTE

	// Recebe o registro posicionada da SF2
	Local	aNfOri		:= ParamIxb

	Local	aAreaOld	:= GetArea()
	Local	nPosTes		:= aScan(aItem,{|x| AllTrim(x[1]) == "D1_TES"})
	Local	nPosOper	:= aScan(aItem,{|x| AllTrim(x[1]) == "D1_OPER"})
	Local	nPosPrd		:= aScan(aItem,{|x| AllTrim(x[1]) == "D1_COD"})
	//Local	nPosNaturez	:= aScan(aCab,{|x| AllTrim(x[1])  == "E2_NATUREZ"})
	Local	nLenItem	:= Len(aItem)
	Local	aTesOri		:= {}
	Local	nPxTes		:= 0
	Local	cTesRetPe	:= ""
	Local   cPrdRetPe   := aItem[nPosPrd,2]
	Local	aCfopTes	:= &(GetNewPar("FS_CFTES09",'{{"XXX","X916/X908"}}'))
	Local	nPosCfTes	:= 0
	Local 	cUfDes		:= IIf( Type("oIdent:_UFFim") <> "U" , oIdent:_UFFim:TEXT , Space(TamSX3("F1_UFDESTR")[1]) )
	Local 	lIsA2SIMPN	:=  SA2->A2_SIMPNAC == "1"  // Verifica se o fornecedor é Optante do Simples Nacional

	// Variável aInfIcmsCte existe por causa da função sfVldAlqIcms que alimenta o array Private
	//aInfIcmsCte	:= {{"ICM","ICMS",nBaseIcms,nAliqIcms,nValIcms}}
	// Esta variável pode ser usada caso tenha que ser identificada alguma situação que avalie o valor do ICMS no CTe
	//e interfira no retorno do TES a ser usada
	// Se o vetor veio zerado, efetua um ajuste
	If Len(aInfIcmsCte) == 0
		Aadd(aInfIcmsCte,{"ICM","ICMS",0,0,0})
	Endif

	DbSelectArea("SF2")
	DbSetOrder(1)
	If DbSeek(aNfOri[1]+aNfOri[2]+aNfOri[3]+aNfOri[4]+aNfOri[5])

		// Percorre todos os itens da nota para montar um vetor somando por TES o valor das mercadorias
		DbSelectArea("SD2")
		DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		DbGotop()
		DbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
		While !Eof() .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2") + SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

			nPxTes	:= aScan(aTesOri,{|x| x[1] == SD2->D2_TES})

			//  Se o TES de saída ainda não foi adicionado ao vetor
			If nPxTes == 0
				// Cria vetor
				// 1 - TES de saída
				// 2 - Valor da mercadoria
				// 3 - Valor do ICMS destacado
				// 4 - Valor do Pis Destacado
				// 5 - Valor do Cofins Destacado
				// 6 - UF de destino
				// 7 - CFOP
				// 8 - Centro Custo NF Origem
				Aadd(aTesOri,{SD2->D2_TES,SD2->D2_TOTAL,SD2->D2_VALICM,SD2->D2_VALIMP6,SD2->D2_VALIMP5,SD2->D2_EST,SD2->D2_CF,SD2->D2_CCUSTO})
			Else
				aTesOri[nPxTes][2] += SD2->D2_TOTAL
				aTesori[nPxTes][3] += SD2->D2_VALICM
				aTesori[nPxTes][4] += SD2->D2_VALIMP6
				aTesori[nPxTes][5] += SD2->D2_VALIMP5
			Endif



			DbSelectArea("SD2")
			DbSkip()
		Enddo

		// Ordena por valor Decrescente, para assumir apenas uma TES com maior participação na nota
		aSort(aTesOri,,,{|x,y| x[2] > y[2] })
		//VarInfo("aTesOri",aTesOri)
		If Len(aTesOri) > 0


			nPosCfTes	:=  aScan(aCfopTes,{|x| Alltrim(aTesOri[1][7]) $ x[2]})

			If nPosCfTes > 0  // Se encontrada exceção de CFOP x TES específica
				cTesRetPe	:= aCfopTes[nPosCfTes,1] 	// TES conforme array que relaciona TES x CFOP saída
			Else
				DbSelectArea("SF4")
				DbSetOrder(1)
				DbSeek(xFilial("SF4")+aTesOri[1][1]) // Posiciona no primeiro registro de TES ordenado pelo maior valor

				// Destinatório fora do Estado
				If aTesOri[1][6] <> GetMv("MV_ESTADO") .And. !(CONDORXML->XML_EMIT $ "94560620000129#08603476000129#17648280000141") //#10466983000100")

					If lIsA2SIMPN
						cPrdRetPe   := Padr("900079",TamSX3("D1_COD")[1])   // Frete Sobre vendas fora do estado - Simples nacional
					Else
						cPrdRetPe   := Padr("900061",TamSX3("D1_COD")[1])   // Frete sobre vendas Fora do estado
					Endif

					// ICMS destacado no CTe
					If aInfIcmsCTe[1,5] > 0
						// Se tiver ICMS destacado na Nota Referencia
						If aTesOri[1][3] > 0
							If lIsA2SIMPN
								cTesRetPe	:= "407"
							Else
								cTesRetPe	:= "104"
							Endif
						Else
							If lIsA2SIMPN
								cTesRetPe	:= "407"
							Else
								cTesRetPe	:= "104"
							Endif
						Endif
					Else
						If lIsA2SIMPN
							cTesRetPe	:= "407"
						Else
							cTesRetPe	:= "407"
						Endif
					Endif
					// Dentro do Estado
				Else
					If lIsA2SIMPN
						cPrdRetPe   := Padr("900002",TamSX3("D1_COD")[1])   // Frete Sobre vendas dentro do estado - Simples nacional
					Else
						cPrdRetPe   := Padr("900002",TamSX3("D1_COD")[1])   // Frete sobre vendas dentro do estado
					Endif

					// ICMS destacado no CTe
					If aInfIcmsCTe[1,5] > 0
						// Se tiver ICMS destacado na Nota Referencia
						If aTesOri[1][3] > 0
							If lIsA2SIMPN
								cTesRetPe	:= "407"
							Else
								cTesRetPe	:= "104"
							Endif
						Else
							If lIsA2SIMPN
								cTesRetPe	:= "407"
							Else
								cTesRetPe	:= "104"
							Endif
						Endif
					Else
						If lIsA2SIMPN
							cTesRetPe	:= "015"
						Else
							cTesRetPe	:= "015"
						Endif
					Endif

				Endif

			Endif

			// Se o TES já existe no Vetor - substitui
			If nPosTes <> 0
				aItem[nPosTes,2] := cTesRetPe
			Else
				// Adiciona
				Aadd(aItem,{"D1_TES"	,cTesRetPe,Nil})
			Endif

		Endif
        
        DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+cPrdRetPe)

		aItem[nPosPrd,2]		:= SB1->B1_COD	

		/*  Código de Produto do FRETE deve ser configurado nestes 3 parametros caso seja sempre o mesmo código de produto.
		Esta configuraão de código de produto para o Frete CIF pode ser feito pelo Wizard da Central XML  
		XM_CDPFRET
		XM_CDPEDAG
		XM_CDPMALT

		Exemplo se houver necessidade forçar o ajuste do código de produto conforme alguma regra.
		aItem[nPosPrd,2]	:= "PRODUTO FRETE"
		*/

		/* Exemplo se houver necessidade forçar o ajuste da Natureza em função de alguma condição originada no frete. 
		If nPosNaturez > 0
		aCab[nPosNaturez,2]	:= "NAT.1" 
		Else
		Aadd(aCab,{"E2_NATUREZ"   ,"NAT.2" 		,NIL,NIL})
		Endif
		*/

		// Remove o campo D1_OPER pois como foi calculado o TES por este ponto de entrada, não será mais necessário chamar o TES inteligente.
		If nPosOper <> 0
			aDel(aItem,nPosOper)
			aSize(aItem,nLenItem-1)
		Endif
		// Tratamento para quando não encontrar a nota de origem referenciada, pega dados só do CTE
	Else
		If lIsA2SIMPN
			cPrdRetPe   := Padr("900001",TamSX3("D1_COD")[1])   // Frete Sobre compras fora do estado - Simples nacional
		Else
			cPrdRetPe   := Padr("900001",TamSX3("D1_COD")[1])   // Frete sobre compras Fora do estado
		Endif
		
        If cUfDes <> GetMv("MV_ESTADO") .And. !(CONDORXML->XML_EMIT $ "94560620000129#08603476000129#17648280000141") //#10466983000100")
			// ICMS destacado no CTe
			If aInfIcmsCTe[1,5] > 0
				cTesRetPe	:= "104"
			// Se não houver ICMS destacado no CTE, não poder tomar crédito, mesmo que a mercadoria Transpotada tenha ICMS
			Else
				cTesRetPe	:= "105"
			Endif

		Else
			cTesRetPe	:= "105"
		Endif

		// Se o TES já existe no Vetor - substitui
		If nPosTes <> 0
			aItem[nPosTes,2] := cTesRetPe
		Else
			// Adiciona
			Aadd(aItem,{"D1_TES"	,cTesRetPe,Nil})
		Endif

		// Remove o campo D1_OPER pois como foi calculado o TES por este ponto de entrada, não será mais necessário chamar o TES inteligente.
		If nPosOper <> 0
			aDel(aItem,nPosOper)
			aSize(aItem,nLenItem-1)
		Endif

        DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+cPrdRetPe)

		aItem[nPosPrd,2]		:= SB1->B1_COD	

	Endif

	RestArea(aAreaOld)
Return

