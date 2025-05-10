#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MTAB2D3R 
@Type			: Função de Usuário
@Sample			: U_MTAB2D3R()
@Description	: Ponto de Entrada executado no final da função B2AtuComD3 após todas as
                  gravações e é utilizado para complementar a gravação no arquivo de
				  saldos (SB2) ou outras atualizações e campos de usuário.
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Processa quando executado rotinas MGT_BLK?
/*/
//--------------------------------------------------------------------------------------
User Function MTAB2D3R()

	//Local _aAmb 	  := U_SalvaAmb()
	//Local _cCodPro    := ParamIXB[1]  	// Codigo do Produto (D3_COD)
	//Local _cLocal     := ParamIXB[2]  	// Local (D3_LOCAL)
	//Local _nMultiplic := ParamIXB[3]  	// 1 = Operacao de Entrada; -1 = Operacao de Saida

	If ("MGT_BLK" $ FunName())

		DbSelectArea("SD3")
		RecLock("SD3",.F.)
		SD3->D3_ROTBLK := AllTrim(FunName())
		MsUnLock()

	Endif

	//U_SalvaAmb(_aAmb)

Return
