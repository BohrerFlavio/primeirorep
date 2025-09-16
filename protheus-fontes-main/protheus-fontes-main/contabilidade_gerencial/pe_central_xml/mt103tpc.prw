#Include 'Protheus.ch'
/*/{Protheus.doc} MT103TPC
//TODO Descrição auto-gerada.
@author Marcelo Alberto Lauschner 
@since 17/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MT103TPC()
	//cRetTes := ExecBlock("MT103TPC",.F.,.F.,{cTesPcNf})
	Local	cInTesRet	:= ParamIxb[1] 
	Local	aAreaOld	:= GetArea()
	Local 	nLinAtu		:= n //Len(aCols)
	Local 	cTesAtu		:= aCols[nLinAtu,aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="D1_TES" })]			//pego a TES informada pelo usuário
	Local 	cRetTes 	:= cInTesRet				//variável de retorno

	// Posiciona no cadastro do TES 
	DbSelectArea("SF4")
	DbSetOrder(1)
	If DbSeek(xFilial("SF4") + cTesAtu) .And. SF4->(FieldPos("F4_X_PCOBR")) > 0
		// Verifica se o TES precisa ou não ter pedido de compra
		If !(SF4->F4_X_PCOBR $ "1") .And. !(cTesAtu $ cRetTes)
			cRetTes += cTesAtu + "#"
		Endif
	Endif 
	
	// Se for nota tipo normal e não tiver TES retornada pelo PE acima
	If cTipo $ "N" .And. Empty(Alltrim(StrTran(cRetTes,"#","")))
		If SA2->(FieldPos("A2_XNOPCNF")) > 0 .And. SA2->A2_XNOPCNF == "1"
			cRetTes += cTesAtu + "#"
		Endif
	Endif
	RestArea(aAreaOld)

Return  cRetTes
