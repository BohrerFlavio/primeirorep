#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MTA650I 
@Type			   : Função de Usuário
@Sample			: U_MTA650I()
@Description	: Ponto de entrada é chamado nas funções: 
                 A650Inclui (Inclusão de OP's)
                 A650GeraC2 (Gera Op para Produto/Quantidade Informados nos parâmetros)
                 Após inclusão das OP's (A650Inclui)
                 Após gravar registro no SC2 (Ordens de Produção). (A650C2)
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		   : Protheus 12.1.25 e posteriores
@Comments		: Revisão em Jun/2021 considerando situação atual para rodar em Jan/2022
/*/
//--------------------------------------------------------------------------------------
User Function MTA650I()

	_aArea   := GetArea()
	_aAreaC2 := SC2->(GetArea())

	/* COMENTARIADO EM 24/07/2024 POR CAUSA DA NOVA ROTINA DE IMPORTAÇÃO IMP_BLCK.PRW
	   POSTERIORMENTE DESCOMPILAR DO RPO DE PRODUCAO
	DbSelectArea("SC2")
   If SC2->C2_DESTINA == "E"
      _Numam := GetAdvFVal("SC2", "C2_NUMAM", xFilial("SC2") + SC2->C2_NUM + "01001", 1, Space(TamSx3("C2_NUMAM")[1]), .T.) 
      _FLote := GetAdvFVal("SC2", "C2_FLOTE", xFilial("SC2") + SC2->C2_NUM + "01001", 1, Space(TamSx3("C2_FLOTE")[1]), .T.) 
      
      RecLock("SC2",.F.)
      SC2->C2_NUMAM := _Numam
      SC2->C2_FLOTE := _FLote
      MsUnlock()
   Endif
   */

   RestArea(_aAreaC2)
   RestArea(_aArea)

Return
