#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} GAT_TESP
@Type			: Função de Usuário
@Sample			: U_GAT_TESP()
@Description	: Gatilho no C6_PRODUTO para sugerir TES somente para empresa 08
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Mar/2023
@version		: Protheus 12.1.33 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function GAT_TESP(_cCampo, _cItem)

	Local _aArea := FWGetArea()
	Local _cRet  := ""

	Private _nItem     := 0
	Private _aDadosCfo := {}	
	Private _npITEM    := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_ITEM"})
	Private _npPROD    := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_PRODUTO"})
	Private _npTES     := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_TES"})
	Private _npCF      := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_CF"})
	Private _npCLASFIS := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_CLASFIS"})

	If (_cItem != "00")
		_nItem := _ProcITE(_cItem)
	EndIf

	If _cCampo == "C6_PRODUTO"

		If cEmpAnt == "08" .And. Ddatabase >= Ctod("01/04/2023")	// Somente deve executar para empresa 08 e a partir de 01/04/2023

			_cNCMProd := GetAdvFVal("SB1", "B1_POSIPI", xFilial("SB1") + aCols[_nItem,_npPROD]	      , 1, Space(TamSx3("B1_POSIPI")[1]), .T.)
			_cSegmCli := GetAdvFVal("SA1", "A1_CODSEG", xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, 1, Space(TamSx3("A1_CODSEG")[1]), .T.)

			If AllTrim(_cNCMProd) == "23011010" .Or. AllTrim(_cNCMProd) == "23011090"
				If AllTrim(_cSegmCli) == "000001" .Or. AllTrim(_cSegmCli) == "000002"
					aCols[_nItem,_npTES] := "763"
					DbSelectArea("SA1")
					DbSetOrder(1)
					DbGoTop()
					DbSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI)
					Aadd(_aDadosCfo,{"OPERNF"	, "S"		 	 })
					Aadd(_aDadosCfo,{"TPCLIFOR"	, M->C5_TIPOCLI	 })
					Aadd(_aDadosCfo,{"UFDEST"	, SA1->A1_EST	 })
					Aadd(_aDadosCfo,{"INSCR" 	, SA1->A1_INSCR	 })
					If SA1->(FieldPos("A1_CONTRIB")) > 0 		 						
						Aadd(_aDadosCfo,{"CONTR", SA1->A1_CONTRIB})
					EndIf	
					aCols[_nItem,_npCF] := MaFisCfo(,GetAdvFVal("SF4", "F4_CF", xFilial("SF4") + aCols[_nItem,_npTES], 1, Space(TamSx3("F4_CF")[1]), .T.), _aDadosCfo)
					aCols[_nItem,_npCLASFIS] := Subs(GetAdvFVal("SB1", "B1_ORIGEM", xFilial("SB1") + aCols[_nItem,_npPROD], 1, Space(TamSx3("B1_ORIGEM")[1]), .T.), 1, 1) + GetAdvFVal("SF4", "F4_SITTRIB", xFilial("SF4") + aCols[_nItem,_npTES], 1, Space(TamSx3("F4_SITTRIB")[1]), .T.)

				ElseIf AllTrim(_cSegmCli) == "000003" .Or. AllTrim(_cSegmCli) == "000004"
					aCols[_nItem,_npTES] := "558"
					DbSelectArea("SA1")
					DbSetOrder(1)
					DbGoTop()
					DbSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI)
					Aadd(_aDadosCfo,{"OPERNF"	, "S"		 	 })
					Aadd(_aDadosCfo,{"TPCLIFOR"	, M->C5_TIPOCLI	 })
					Aadd(_aDadosCfo,{"UFDEST"	, SA1->A1_EST	 })
					Aadd(_aDadosCfo,{"INSCR" 	, SA1->A1_INSCR	 })
					If SA1->(FieldPos("A1_CONTRIB")) > 0 		 						
						Aadd(_aDadosCfo,{"CONTR", SA1->A1_CONTRIB})
					EndIf	
					aCols[_nItem,_npCF] := MaFisCfo(,GetAdvFVal("SF4", "F4_CF", xFilial("SF4") + aCols[_nItem,_npTES], 1, Space(TamSx3("F4_CF")[1]), .T.), _aDadosCfo)
					aCols[_nItem,_npCLASFIS] := Subs(GetAdvFVal("SB1", "B1_ORIGEM", xFilial("SB1") + aCols[_nItem,_npPROD], 1, Space(TamSx3("B1_ORIGEM")[1]), .T.), 1, 1) + GetAdvFVal("SF4", "F4_SITTRIB", xFilial("SF4") + aCols[_nItem,_npTES], 1, Space(TamSx3("F4_SITTRIB")[1]), .T.)

				EndIf
			EndIf

		EndIf

		_cRet := aCols[_nItem,_npPROD]
	EndIF

	FWRestArea(_aArea)

Return(_cRet)


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
