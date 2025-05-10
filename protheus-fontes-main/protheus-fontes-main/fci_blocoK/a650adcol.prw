#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} A650ADCOL 
@Type			: Função de Usuário
@Sample			: U_A650ADCOL()
@Description	: Ponto entrada executado após a inclusão de cada linha do aCols (usado
                  para gerar empenhos e SCs, permitindo executar qualquer processamento,
				  ou até manipular conteúdo do aCols que acabou de ser incluido.
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Processa quando executado rotina MGT_BLK2
/*/
//--------------------------------------------------------------------------------------
User Function A650ADCOL()

	//Local _aAmb 	 := U_SalvaAmb()
	//Local cProduto   := PARAMIXB[1]		// Código do produto ou componente explodido
	//Local nQuantPai  := PARAMIXB[2]		// Quantidade do produto pai explodido
	//Local cOpcionais := PARAMIXB[3]		// String com opcionais selecionados
	//Local cRevisao   := PARAMIXB[4]		// Revisao do Produto

	If AllTrim(FunName()) == "MGT_BLK2"
		// Leva a quantidade apurada na segunda unidade de medida aos empenhos
		DbSelectArea("SB1")
		_nPercQtd := fBuscaCpo("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_PERCQTD")
		_cCalcPQ  := fBuscaCpo("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_CALCPQ")

		If _cCalcPQ == "D"		// Faz cálculo na desmontagem de produto
			aCols[Len(aCols),nPosQtSegUm] := (SC2->C2_QTSEGUM * _nPercQtd) / 100
		Else					// Para montagem considera segunda UM da OP
			aCols[Len(aCols),nPosQtSegUm] := SC2->C2_QTSEGUM
		Endif
	EndIf

	//U_SalvaAmb(_aAmb)

Return
