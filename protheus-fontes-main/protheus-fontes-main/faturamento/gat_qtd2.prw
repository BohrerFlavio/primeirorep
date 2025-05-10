#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} GAT_QTD2
@Type			: Função de Usuário
@Sample			: U_GAT_QTD2()
@Description	: Gatilho no C6_QUANT para atualizar C6_UNSVEN
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: MaI/2024
@version		: Protheus 12.1.2210 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function GAT_QTD2(_cCampo, _cItem)

	Local _aArea := FWGetArea()
	Local _nRet  := 0

	Private _nItem    := 0
	Private _npITEM   := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_ITEM"})
	Private _npPROD   := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_PRODUTO"})
	Private _npQTDVEN := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_QTDVEN"})
	Private _npUNSVEN := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_UNSVEN"})

	If (_cItem != "00")
		_nItem := _ProcITE(_cItem)
	EndIf

	If _cCampo == "C6_QTDVEN"

		If cEmpAnt == "01"	// Somente deve executar para empresa 01

			_nConvPrd := GetAdvFVal("SB1", "B1_CONV",   xFilial("SB1") + aCols[_nItem,_npPROD]	      , 1, Space(TamSx3("B1_CONV")[1]), .T.)
			_cPrePedV := M->C5_PREPED		//GetAdvFVal("SA1", "A1_CODSEG", xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, 1, Space(TamSx3("A1_CODSEG")[1]), .T.)

			If _nConvPrd == 0

				DbSelectArea("ZZ5")
				DbSetOrder(2)
				DbGoTop()
				DbSeek(xFilial("ZZ5") + _cPrePedV + PADR(aCols[_nItem,_npPROD], 14, " "))
				If Found()
					aCols[_nItem,_npUNSVEN] := Round(ZZ5->ZZ5_QRCAIX,2)    // Quantidade em CX
				Else
					aCols[_nItem,_npUNSVEN] := aCols[_nItem,_npUNSVEN]
				EndIf	
			EndIf

		EndIf

		_nRet := aCols[_nItem,_npQTDVEN]
	EndIF

	FWRestArea(_aArea)

Return(_nRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} _ProcITE
Função que procura o item, passado por parâmetro, dentro do array aCols
@Since      Mar/2022
/*/
//-------------------------------------------------------------------
Static Function _ProcITE(_cItem)

	Local _nReturn := 0
	Local _i
	
	For _i := 1 To Len(aCols)

		If (aCols[_i,_npITEM] == _cItem)
			_nReturn := _i
		EndIf

	Next _i
	
Return(_nReturn)
