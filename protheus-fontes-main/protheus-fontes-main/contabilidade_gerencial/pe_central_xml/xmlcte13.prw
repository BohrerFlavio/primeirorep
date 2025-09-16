#Include 'totvs.ch'

/*/{Protheus.doc} U_XMLCTE13
Ponto de entrada Central XML - para retornar TES que não precisa de pedido de compra
@type function
@version
@author Marcelo Alberto Lauschner
@since 17/10/2018
@return return_type, return_description
/*/
Function U_XMLCTE13()

	Local	cTesRet		:= ""
	Local 	cTesPcNF 	:= GetNewPar("MV_TESPCNF","")
	Private n 			:= Len(oMulti:aCols)
	Private aCols		:= aClone(oMulti:aCols)
	Private	aHeader		:= aClone(oMulti:aHeader)
	
	// Valida ponto de entrada padrão 
	cTesRet	:= ExecBlock("MT103TPC",.F.,.F.,{cTesPcNf}) 
	
	If !(cTipo $ "D#B")
		If SA2->(FieldPos("A2_XNOPCNF")) > 0 .And. SA2->A2_XNOPCNF == "1"
			cItemNPed	+= CONDORXMLITENS->XIT_ITEM + "#"
		Endif
	Endif 

Return cTesRet

