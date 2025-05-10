#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} GAT_TESC
@Type			: Função de Usuário
@Sample			: U_GAT_TESC()
@Description	: Gatilho no C5_CLIENTE e C5_LOJACLI para sugerir TES somente para empresa 08
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Mar/2023
@version		: Protheus 12.1.33 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function GAT_TESC(_cCampo)

	Local _aArea := FWGetArea()
	Local _cRet  := ""
	Local _i

	Private _aDadosCfo := {}	
	Private _npPROD    := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_PRODUTO"})
	Private _npTES     := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_TES"})
	Private _npCF      := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_CF"})
	Private _npCLASFIS := aScan(aHeader, { |x| Alltrim(X[2]) == "C6_CLASFIS"})

	If _cCampo == "C5_CLIENTE" .Or. _cCampo == "C5_LOJACLI"

		If At(M->C5_TIPO,"DB") == 0 	// Cliente
			If cEmpAnt == "08" .And. Ddatabase >= Ctod("01/04/2023")	// Somente deve executar para empresa 08 e a partir de 01/04/2023

				For _i := 1 To Len(aCols)

					_cNCMProd := GetAdvFVal("SB1", "B1_POSIPI", xFilial("SB1") + aCols[_i,_npPROD]	   	      , 1, Space(TamSx3("B1_POSIPI")[1]), .T.)
					_cSegmCli := GetAdvFVal("SA1", "A1_CODSEG", xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, 1, Space(TamSx3("A1_CODSEG")[1]), .T.)

					If AllTrim(_cNCMProd) == "23011010" .Or. AllTrim(_cNCMProd) == "23011090"
						If AllTrim(_cSegmCli) == "000001" .Or. AllTrim(_cSegmCli) == "000002"
							aCols[_i,_npTES] := "763"
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
							aCols[_i,_npCF] := MaFisCfo(,GetAdvFVal("SF4", "F4_CF", xFilial("SF4") + aCols[_i,_npTES], 1, Space(TamSx3("F4_CF")[1]), .T.), _aDadosCfo)
							aCols[_i,_npCLASFIS] := Subs(GetAdvFVal("SB1", "B1_ORIGEM", xFilial("SB1") + aCols[_i,_npPROD], 1, Space(TamSx3("B1_ORIGEM")[1]), .T.), 1, 1) + GetAdvFVal("SF4", "F4_SITTRIB", xFilial("SF4") + aCols[_i,_npTES], 1, Space(TamSx3("F4_SITTRIB")[1]), .T.)

						ElseIf AllTrim(_cSegmCli) == "000003" .Or. AllTrim(_cSegmCli) == "000004"
							aCols[_i,_npTES] := "558"
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
							aCols[_i,_npCF] := MaFisCfo(,GetAdvFVal("SF4", "F4_CF", xFilial("SF4") + aCols[_i,_npTES], 1, Space(TamSx3("F4_CF")[1]), .T.), _aDadosCfo)
							aCols[_i,_npCLASFIS] := Subs(GetAdvFVal("SB1", "B1_ORIGEM", xFilial("SB1") + aCols[_i,_npPROD], 1, Space(TamSx3("B1_ORIGEM")[1]), .T.), 1, 1) + GetAdvFVal("SF4", "F4_SITTRIB", xFilial("SF4") + aCols[_i,_npTES], 1, Space(TamSx3("F4_SITTRIB")[1]), .T.)

						EndIf
					EndIf

				Next

				If (AllTrim(FunName()) == "MATA410")
					If oGetDad<>Nil
						oGetDad:oBrowse:nAt := 1
						oGetDad:oBrowse:Refresh()
					Endif
				EndIf

			EndIf
		EndIf

		_cRet := IIF(_cCampo == "C5_CLIENTE", M->C5_CLIENTE, M->C5_LOJACLI) 
	EndIF

	FWRestArea(_aArea)

Return(_cRet)
