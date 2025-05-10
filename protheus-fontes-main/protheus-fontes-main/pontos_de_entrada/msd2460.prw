#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

User Function MSD2460()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ MSD2460  º Autor ³ Eleandro Casagrandeº Data ³  Mai/2004   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Ponto de entrada usado na gravacao dos itens da nota       º±±
	±±º          ³ Executado: MATA460 - Preparacao da nota fiscal             º±±
	±±º          ³ foi criado na gravacao dos itens da nf                     º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Especifico para Frigorifico Silva                          º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	_aArea := GetArea()

	SC5->(DbSetOrder(1))
	SC5->(MsSeek(FWxfilial('SC5')+SC6->C6_NUM))
	
	RecLock("SD2",.F.)
	If cEmpAnt $ "01/07/08"
		SD2->D2_DESCRI  := SC6->C6_DESCRI
		SD2->D2_PRECAR  := SC5->C5_PRECAR
		SD2->D2_PREPED  := SC5->C5_PREPED
	Endif

	// Grava Valores de Rapel/IQF/Logística/VerbaExtra/Marca Própria
	If cEmpAnt == "01" .And. SD2->D2_TIPO == "N"
		//If SF2->F2_CLIENTE == "000173" .Or. SF2->F2_CLIENTE == "000174" .Or. SF2->F2_CLIENTE == "001110" .Or. SF2->F2_CLIENTE == "010343" .Or. SF2->F2_CLIENTE == "020031"
			_cTpVerba := GetAdvFVal("SB1", "B1_TPVERBA", FWxFilial("SB1") + SD2->D2_COD					, 1, Space(TamSx3("B1_TPVERBA")[1]), .T.)
			_dVencRap := GetAdvFVal("SA1", "A1_VENRAP" , FWxFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, 1, Space(TamSx3("A1_VENRAP")[1]) , .T.)
			_cPercRap := GetAdvFVal("SA1", "A1_PRAPEL" , FWxFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, 1, Space(TamSx3("A1_PRAPEL")[1]) , .T.)
			_cPercIqf := GetAdvFVal("SA1", "A1_PIQF"   , FWxFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, 1, Space(TamSx3("A1_PIQF")[1])   , .T.)
			_cPercLog := GetAdvFVal("SA1", "A1_PLOGIST", FWxFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, 1, Space(TamSx3("A1_PLOGIST")[1]), .T.)
			_cPercVex := GetAdvFVal("SA1", "A1_PVBAEXT", FWxFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, 1, Space(TamSx3("A1_PVBAEXT")[1]), .T.)
			_cPercMcp := GetAdvFVal("SA1", "A1_PMCPROP", FWxFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, 1, Space(TamSx3("A1_PMCPROP")[1]), .T.)

			DO CASE
				CASE _cTpVerba == "01"		// IQF
					SD2->D2_VLIQF   := (SD2->D2_VALBRUT * _cPercIqf) / 100
				CASE _cTpVerba == "02"		// Marca Propria
					SD2->D2_VLMCPRO := (SD2->D2_VALBRUT * _cPercMcp) / 100
				OTHERWISE					// Rapel
					If _dVencRap >= date()
						If SF2->F2_CLIENTE == "000173" .Or. SF2->F2_CLIENTE == "000174" .Or. SF2->F2_CLIENTE == "001110" .Or. SF2->F2_CLIENTE == "010343" .Or. SF2->F2_CLIENTE == "020031"						//SD2->D2_VLRAPEL := (SD2->D2_VALBRUT * _cPercRap) / 100
							SD2->D2_VLRAPEL := (SD2->D2_VALBRUT * (_cPercRap + _cPercLog)) / 100
						Else
							SD2->D2_VLRAPEL := (SD2->D2_VALBRUT * _cPercRap) / 100
						EndIF
					Endif
			ENDCASE
			
			// As Verbas de Logística e Verba Extra sempre calculam para todos itens
			//SD2->D2_VLLOGIS := (SD2->D2_VALBRUT * _cPercLog) / 100
			SD2->D2_VLVBEXT := (SD2->D2_VALBRUT * _cPercVex) / 100
		//EndIf
	Endif
	MsUnlock()

	// Grava histórico de faturamento na tabela SZU
	If AllTrim(SD2->D2_SEGUM) == "CX" .and. !empty(SD2->D2_PRECAR)
		DbSelectArea("SZ8")
		DbSetOrder(26)
		MsSeek(FWxFilial("SZ8") + SD2->D2_FILIAL + SD2->D2_PREPED + Left(SD2->D2_COD,14))
		While !Eof() .And. SZ8->Z8_FILIAL + SZ8->Z8_FIL + SZ8->Z8_PREPED + SZ8->Z8_COD == FWxFilial("SZ8") + SD2->D2_FILIAL + SD2->D2_PREPED + Left(SD2->D2_COD,14)

			DbSelectArea("SZV")

			_id := GetSx8Num("SZV","ZV_ID")
			ConfirmSx8()

			RecLock("SZV",.T.)
			SZV->ZV_FILIAL  := FWxFilial("SZV")
			SZV->ZV_ID      := _id
			SZV->ZV_CONTROL := SZ8->Z8_CONTROL
			SZV->ZV_DATA    := SD2->D2_EMISSAO
			SZV->ZV_HORA    := Time()
			SZV->ZV_DESC    := "FATURAMENTO NF. NUM.: " + SD2->D2_DOC + " SERIE: " + SD2->D2_SERIE
			SZV->ZV_USAR    := cUserName
			SZV->ZV_EST     := GetComputerName()
			SZV->ZV_TIPO    := "M"
			SZV->ZV_CODMSG  := "000034"
			MsUnLock()

			//DbSelecArea("SZ8")
			DbSelectArea("SZ8")
			DbSkip()
		EndDo
	EndIf

	RestArea(_aArea)

Return
