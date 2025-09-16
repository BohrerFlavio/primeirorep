#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MTAGRSD4 
@Type			: Função de Usuário
@Sample			: U_MTAGRSD4()
@Description	: Ponto entrada resp. por gravar registros de empenho (SD4)
                  Após gravar o registro no SD4 (Requisições Empenhadas)  
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Processa quando executado rotinas MGT_BLK2, MGT_BLK4, MGT_BLK5 ou MGT_BLK8
/*/
//--------------------------------------------------------------------------------------
User Function MTAGRSD4()

	//Local _aAmb := U_SalvaAmb()

	/* COMENTARIADO EM 24/07/2024 POR CAUSA DA NOVA ROTINA DE IMPORTAÇÃO IMP_BLCK.PRW
	   POSTERIORMENTE DESCOMPILAR DO RPO DE PRODUCAO
	DbSelectArea("SC2")
	_FLote := fBuscaCPO("SC2", 1, xFilial("SC2") + AllTrim(SD4->D4_OP), "C2_FLOTE")

	SD4->D4_FLOTE := _FLote
	*/
	
	//U_SalvaAmb(_aAmb)

Return
