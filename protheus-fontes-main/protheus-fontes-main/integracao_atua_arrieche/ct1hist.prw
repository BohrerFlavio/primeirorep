#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} TM200FIM
@Type			: Ponto de Entrada
@Sample			: U_TM200FIM()
@Description	: Na Finalização do Processo de Gravação de Documentos
@Param			: _cFilDoc	PARAMIXB[1] - Filial do Documento										
				  _cDocto	PARAMIXB[2] - Documento								
				  _cSerie	PARAMIXB[3] - Série	
@Return			: Nil
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Jan/2024
@version		: Protheus 12.1.2210 e posteriores
@Comments		: Localizado no TMSA200, é executado após o final de todo o processo de
                  gravação dos documentos e da geração das notas de saída.
/*/
//--------------------------------------------------------------------------------------
User Function CT1HIST()

	Local _aArea   := FWGetArea()
	Local oModel   := FWModelActive()
	Local cIdHAtua := oModel:GetValue('CT1MASTER','CT1_IDHATU')

	If cEmpAnt == "07"		// Executa somente para a empresa 07

		oModel:SetValue('CT1MASTER', 'CT1_IDHATU', StrZero(Val(cIdHAtua),10))

	EndIf

	FWRestArea(_aArea)

Return .T.
