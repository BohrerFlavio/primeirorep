#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} TM200DT6
@Type			: Ponto de Entrada
@Sample			: U_TM200DT6()
@Description	: Na Gravação do Documento de Transporte
@Param			: _cFilDoc	PARAMIXB[1] - Filial do Documento										
				  _cDocto	PARAMIXB[2] - Documento								
				  _cSerie	PARAMIXB[3] - Série	
@Return			: Nil
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Jan/2024
@version		: Protheus 12.1.2210 e posteriores
@Comments		: Localizado no TMSA200 (Cálculo de Frete), é executado após a gravação
                  do Documento de Transporte (DT6)
/*/
//--------------------------------------------------------------------------------------
User Function TM200DT6()

	Local _aArea   := FWGetArea()
	Local _cFilDoc := PARAMIXB[1]
	Local _cDocto  := PARAMIXB[2]
	Local _cSerie  := PARAMIXB[3]

	If cEmpAnt == "07"		// Executa somente para a empresa 07
		// Grava dados complementares na tabela DT6 que já está posicionada
		DbSelectArea("DT6")
		RecLock("DT6", .F.)
		DT6->DT6_HOREMI := ZM4->ZM4_HREMIS
		DT6->DT6_FIMP   := "1"
		DT6->DT6_STATUS := "6"
		DT6->DT6_USRGER := __cUserID
		DT6->DT6_IDRCTE := Left(ZM4->ZM4_RETCTE,3)
		DT6->DT6_PROCTE := ZM4->ZM4_PROCTE
		DT6->DT6_CHVCTE := ZM4->ZM4_CHVCTE
		DT6->DT6_SITCTE := "2"					// DEFINIR
		DT6->DT6_RETCTE := ZM4->ZM4_RETCTE
		DT6->DT6_AMBIEN := Val(ZM4->ZM4_AMBIEN)
		MsUnlock()
	EndIf

	FWRestArea(_aArea)

Return
