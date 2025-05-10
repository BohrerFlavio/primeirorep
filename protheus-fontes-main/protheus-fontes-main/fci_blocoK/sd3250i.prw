#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} SD3250I 
@Type			: Função de Usuário
@Sample			: U_SD3250I()
@Description	: Ponto de Entrada executado na função A250Atu(), rotina responsável pela
				  atualização das tabelas de apontamentos de produção simples.
				  DESCRIÇÃO : Após atualização dos arquivos na rotina de produções. 
				  Executa após atualizar SD3, SB2, SB3 e SC2. 
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function SD3250I()

	Local _aArea 	:= GetArea()
	Local _aAreaSD3 := SD3->(GetArea())
	/* COMENTARIADO EM 24/07/2024 POR CAUSA DA NOVA ROTINA DE IMPORTAÇÃO IMP_BLCK.PRW
	   POSTERIORMENTE DESCOMPILAR DO RPO DE PRODUCAO
	Local _cOp      := SD3->D3_OP

	Pergunte("MGT_BLK1",.F.)

	DbSelectArea("SD3")
	DbSetOrder(1)
	DbSeek(xFilial("SD3") + _cOp)
	While !Eof() .And. SD3->D3_FILIAL + SD3->D3_OP == xFilial("SD3") + _cOp

		If SD3->D3_TM == "999" .And. SD3->D3_ESTORNO <> "S"
			RecLock("SD3",.F.)
			SD3->D3_SEGUM := "PC"
			SD3->D3_FLOTE := "P" + MV_PAR02 + Dtos(mv_par01)
			MsUnLock()
		EndIf

		DbSelectArea("SD3")
		DbSkip()
	EndDo

    Pergunte("MTA250",.F.)
	*/

	RestArea(_aAreaSD3)
	RestArea(_aArea)

Return
