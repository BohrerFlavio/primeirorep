#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} SD3240I 
@Type			: Função de Usuário
@Sample			: U_SD3240I()
@Description	: Ponto entrada na inclusão de movimentação interna.  
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Processa quando executado rotinas MGT_BLK?
/*/
//--------------------------------------------------------------------------------------
User Function SD3240I()

	Local _aArea    := GetArea()
	Local _aAreaSD3 := SD3->(GetArea())

	If ("MGT_BLK" $ FunName())
		DbSelectArea("SD3")
		RecLock("SD3",.F.)
		SD3->D3_ROTBLK := AllTrim(FunName())
		SD3->( MsUnLock() )
	Endif

	RestArea(_aAreaSD3)
	RestArea(_aArea)

Return(.T.)
