#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MTAB2D3 
@Type			: Função de Usuário
@Sample			: U_MTAB2D3()
@Description	: Ponto de Entrada está localizado na função B2AtuComD3
                  (Atualiza os dados do SB2 baseado no SD3)
				  É executado ANTES da gravação do SB2, pois seu objetivo é que o usuário
				  possa manipular os dados do SB2, antes da atualização feita pelo sistema.  
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Processa quando executado rotina MGT_BLK7
/*/
//--------------------------------------------------------------------------------------
User Function MTAB2D3()

	//Local _aAmb 	  := U_SalvaAmb()
	//Local _cCodPro    := ParamIXB[1]  	// Codigo do Produto (D3_COD)
	//Local _cLocal     := ParamIXB[2]  	// Local
	//Local _nMultiplic := ParamIXB[3]  	// 1 = Operacao de Entrada; -1 = Operacao de Saida

	If AllTrim(FunName()) == "MGT_BLK7"

		MsgAlert("VERIFICAR ESSA MENSAGEM NO PE MTAB2D3.PRW QUANDO EXECUTADO MGT_BLK7")

		DbSelectArea("SB2")
		DbSetOrder(1)
		If SB2->B2_QATU < SD3->D3_QUANT
			RecLock("SB2",.F.)
			SB2->B2_QATU := SD3->D3_QUANT
			MsUnLock()
		Endif

	Endif

	//U_SalvaAmb(_aAmb)

Return .T.
