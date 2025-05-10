#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MATUCOMP
@Type			: Ponto de Entrada
@Sample			: U_MATUCOMP()
@Description	: Utilizado para alterações automáticas nos complementos dos documentos
                  fiscais após a emissão das Notas Fiscais.
                  Este Ponto de Entrada é executado após gravação de todos os dados da
				  NF de saída ou entrada digitadas no modulo fiscal, faturamento e compras.
@Param			: ParamIXB[1] 	E=Entrada ou S=Saida
    			  ParamIXB[2] 	Serie do documento fiscal
    			  ParamIXB[3] 	Numero do documento
    			  ParamIXB[4] 	Cliente/Fornecedor
    			  ParamIXB[5] 	Loja do Cliente/Fornecedor
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Fev/2025
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Abaixo
___________________________________________________________________________________________________
|Quando se referir aos complementos para geracao dos registros C110, C111, C112, C113, C114 e C115|
|  a tabela CDT tambÃ©m deve ser alimentada, pois ela que efetua o relacionamentos com as outras  |
|  conforme registro. C110 = Tab. CDT, C111 = Tab. CDG, , C112 = Tab. CDC, C113 = Tab. CDD,       |
|  C114 = Tab. CDE e C115 = Tab. CDF                                                              |
|_________________________________________________________________________________________________|
/*/
//--------------------------------------------------------------------------------------
User function MATUCOMP()

	_cEntSai   := ParamIXB[1]
	_cSerRefat := ParamIXB[2]
	_cDocRefat := ParamIXB[3]
	_cCliRefat := ParamIXB[4]
	_cLojRefat := ParamIXB[5]

	// Executa somente para notas de saída
	If _cEntSai == "S"
		// Busca a fórmula (F4_FORMULA) no TES da nota fiscal para saber se é refaturamento
		_cTESRefat := GetAdvFVal("SD2", "D2_TES"    , FWxFilial("SD2") + _cDocRefat + _cSerRefat + _cCliRefat + _cLojRefat, 3, Space(TamSx3("D2_TES")[1])    , .T.)
		_cFormula  := GetAdvFVal("SF4", "F4_FORMULA", FWxFilial("SF4") + _cTESRefat                                       , 1, Space(TamSx3("F4_FORMULA")[1]), .T.)

		If AllTrim(_cFormula) $ "203/204"	// Refaturamento mesmo cliente / Refaturamento outro cliente
			// Busca dados da nf devolução
			_cDocDevol := GetAdvFVal("SD2", "D2_NFORI"  , FWxFilial("SD2") + _cDocRefat + _cSerRefat + _cCliRefat + _cLojRefat, 3, Space(TamSx3("D2_NFORI")[1])  , .T.)
			_cSerDevol := GetAdvFVal("SD2", "D2_SERIORI", FWxFilial("SD2") + _cDocRefat + _cSerRefat + _cCliRefat + _cLojRefat, 3, Space(TamSx3("D2_SERIORI")[1]), .T.)
			_cPVOrig   := GetAdvFVal("SD2", "D2_PEDIDO" , FWxFilial("SD2") + _cDocRefat + _cSerRefat + _cCliRefat + _cLojRefat, 3, Space(TamSx3("D2_PEDIDO")[1]) , .T.)
			_cCliDevol := GetAdvFVal("SC5", "C5_CLIRET" , FWxFilial("SC5") + _cPVOrig                                         , 1, Space(TamSx3("C5_CLIRET")[1]) , .T.)
			_cLojDevol := GetAdvFVal("SC5", "C5_LOJARET", FWxFilial("SC5") + _cPVOrig                                         , 1, Space(TamSx3("C5_LOJARET")[1]), .T.)
			_dEmiDevol := GetAdvFVal("SD2", "D2_EMISSAO", FWxFilial("SD2") + _cDocRefat + _cSerRefat + _cCliRefat + _cLojRefat, 3, Space(TamSx3("D2_EMISSAO")[1]), .T.)

			// Busca dados da nf original
			_cDocOrig := GetAdvFVal("SD1", "D1_NFORI"  , FWxFilial("SD1") + _cDocDevol + _cSerDevol + _cCliDevol + _cLojDevol, 1, Space(TamSx3("D1_NFORI")[1])  , .T.)
			_cSerOrig := GetAdvFVal("SD1", "D1_SERIORI", FWxFilial("SD1") + _cDocDevol + _cSerDevol + _cCliDevol + _cLojDevol, 1, Space(TamSx3("D1_SERIORI")[1]), .T.)
			_cCliOrig := GetAdvFVal("SD1", "D1_FORNECE", FWxFilial("SD1") + _cDocDevol + _cSerDevol + _cCliDevol + _cLojDevol, 1, Space(TamSx3("D1_FORNECE")[1]), .T.)
			_cLojOrig := GetAdvFVal("SD1", "D1_LOJA"   , FWxFilial("SD1") + _cDocDevol + _cSerDevol + _cCliDevol + _cLojDevol, 1, Space(TamSx3("D1_LOJA")[1])   , .T.)
			_dEmiOrig := GetAdvFVal("SF2", "F2_EMISSAO", FWxFilial("SF2") + _cDocOrig  + _cSerOrig  + _cCliorig  + _cLojOrig , 1, Space(TamSx3("F2_EMISSAO")[1]), .T.)

			// Grava complemento fiscal para nota original de venda
			DbSelectArea("CDD")
			RecLock("CDD",.T.)
			CDD->CDD_FILIAL := FWxFilial("CDD")
			CDD->CDD_TPMOV  := "S"
			CDD->CDD_DOC    := _cDocRefat
			CDD->CDD_SERIE  := _cSerRefat
			CDD->CDD_CLIFOR := _cCliRefat
			CDD->CDD_LOJA   := _cLojRefat
			CDD->CDD_DOCREF := _cDocOrig
			CDD->CDD_SERREF := _cSerOrig
			CDD->CDD_PARREF := _cCliOrig
			CDD->CDD_LOJREF := _cLojOrig
			CDD->CDD_IFCOMP := "000204"
			CDD->CDD_CHVNFE := GetAdvFVal("SF3", "F3_CHVNFE", FWxFilial("SF3") + _cCliOrig + _cLojOrig + _cDocOrig + _cSerOrig , 4, Space(TamSx3("F3_CHVNFE")[1]), .T.)
			CDD->CDD_SDOC   := _cSerRefat
			CDD->CDD_SDOCRF := _cSerOrig
			CDD->CDD_ENTSAI := "2"			// 2=Saída
			CDD->CDD_MEANRF := Alltrim(STRZERO(Month(_dEmiOrig),2)) + Alltrim(STR(YEAR(_dEmiOrig),4))
			CDD->CDD_MODREF := "SPED"
			MsUnlock()

			// Grava complemento fiscal para nota de devolução
			DbSelectArea("CDD")
			RecLock("CDD",.T.)
			CDD->CDD_FILIAL := FWxFilial("CDD")
			CDD->CDD_TPMOV  := "S"
			CDD->CDD_DOC    := _cDocRefat
			CDD->CDD_SERIE  := _cSerRefat
			CDD->CDD_CLIFOR := _cCliRefat
			CDD->CDD_LOJA   := _cLojRefat
			CDD->CDD_DOCREF := _cDocDevol
			CDD->CDD_SERREF := _cSerDevol
			CDD->CDD_PARREF := _cCliDevol
			CDD->CDD_LOJREF := _cLojDevol
			CDD->CDD_IFCOMP := "000204"
			CDD->CDD_CHVNFE := GetAdvFVal("SF3", "F3_CHVNFE", FWxFilial("SF3") + _cCliDevol + _cLojDevol + _cDocDevol + _cSerDevol, 4, Space(TamSx3("F3_CHVNFE")[1]), .T.)
			CDD->CDD_SDOC   := _cSerRefat
			CDD->CDD_SDOCRF := _cSerDevol
			CDD->CDD_ENTSAI := "1"			// 2=Entrada
			CDD->CDD_MEANRF := Alltrim(STRZERO(Month(_dEmiDevol),2)) + Alltrim(STR(YEAR(_dEmiDevol),4))
			CDD->CDD_MODREF := "SPED"
			MsUnlock()
		EndIf

	EndIf

Return
