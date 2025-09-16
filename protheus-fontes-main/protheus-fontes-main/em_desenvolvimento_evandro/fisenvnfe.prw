#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} FISENVNFE
@Type			: Ponto de Entrada
@Sample			: U_FISENVNFE()
@Description	: Ponto de entrada executado logo após a transmissão da NF-e
@Param			: _aNotas	Array	ID de iden tificação da NF-e, junto ao TSS
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Jan/2025
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function FISENVNFE()

	Local _aNotas    := PARAMIXB[1]
	Local _aArea     := FWGetArea()
	Local _aArSF1    := SF1 -> ( FWGetArea() )
	Local _aArSA2	 := SA2 -> ( FWGetArea() )
	Local _aArSD1	 := SD1 -> ( FWGetArea() )
	Local _aArSF2    := SF2 -> ( FWGetArea() )
	Local _aArSA1	 := SA1 -> ( FWGetArea() )
	Local _aArSD2	 := SD2 -> ( FWGetArea() )
	Local _cSerie    := ""
	Local _cDoc      := ""
	Local _cChaveNfe := ""
	Local _nX        := 0

	// NOTAS DE ENTRADA
	If (Alltrim( FWCodEmp() ) == "01") .And. (Alias() == "SF1") .And. (Len(_aNotas) > 0)

		For _nX := 1 To Len(_aNotas)
			_cSerie    := SubStr(_aNotas[_nX], 1, 3)
			_cDoc      := SubStr(_aNotas[_nX], 4, 9)
			_cChaveNfe := ""

			SLEEP(5 * 1000)		// Aguarda 5 segundos para filtrar dados do 

			BeginSQL Alias "_SP"
				SELECT
					NFE_CHV
				FROM
					SPED054
				WHERE NFE_PROT <> ' '
					AND CSTAT_SEFR = '100'
					AND NFE_ID = %exp:_aNotas[_nX]%
					AND ID_ENT = '000001'
				ORDER BY R_E_C_N_O_ DESC                
			EndSQL

			DbSelectArea("_SP")
			DbGoTop()
			If !Eof() .And. !Empty(_SP->NFE_CHV)
				_cChaveNfe := _SP->NFE_CHV
			Endif
			_SP -> ( DbCloseArea() )


			DbSelectArea("SF1")
			DbSetOrder(8)
			DbSeek(FWxFilial("SF1") + _cChaveNfe)
			If Found() .And. SF1->F1_TIPO == "D" .And. !Empty(SF1->F1_NUMREC)
				// Quando "Tipo Retorno" do recibo for refaturamento, atualiza ZH3_CHVDEV no vinculo NFe
				_cTipoRet := GetAdvFVal("ZH2", "ZH2_TIPRET", FWxFilial("ZH2") + SF1->F1_NUMREC, 1, Space(TamSx3("ZH2_TIPRET")[1]), .T.)
				If _cTipoRet == "1" .Or. _cTipoRet == "2"
					DbSelectArea("ZH3")
					DbSetOrder(1)
					If DbSeek(FWxFilial("ZH3") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)
						DbSelectArea("ZH3")
						RecLock("ZH3", .F.)
						ZH3->ZH3_CHVDEV := SF1->F1_CHVNFE
						MsUnlock()
					EndIf
				EndIf
			Endif
		Next

	EndIf

	FWRestArea(_aArSD2)
	FWRestArea(_aArSA1)
	FWRestArea(_aArSF2)
	FWRestArea(_aArSD1)
	FWRestArea(_aArSA2)
	FWRestArea(_aArSF1)
	FWRestArea(_aArea)

Return Nil
