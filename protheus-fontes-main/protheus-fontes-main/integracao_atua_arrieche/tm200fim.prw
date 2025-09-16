#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

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
User Function TM200FIM()

	Local _aArea    := FWGetArea()
	Local _aAreaSFT := SFT->(FWGetArea())
	Local _aAreaSF3 := SF3->(FWGetArea())
	Local _aAreaSF2 := SF2->(FWGetArea())
	Local _cFilDoc  := PARAMIXB[1]
	Local _cDocto   := PARAMIXB[2]
	Local _cSerie   := PARAMIXB[3]

	If cEmpAnt == "07"		// Executa somente para a empresa 07
		
		// Grava dados complementares nas tabelas SF3 e SFT
		SF2->F2_FIMP    := "T"
		SF2->F2_ESPECIE := "CTE"
		SF2->F2_HORA    := SUBSTR(ZM4->ZM4_HREMIS,1,2) + ":" + SUBSTR(ZM4->ZM4_HREMIS,3,2)
		SF2->F2_CHVNFE  := ZM4->ZM4_CHVCTE

		// Grava dados complementares nas tabelas SF3 e SFT
		RecLock("SF3", .F.)
		SF3->F3_ESPECIE := "CTE"
		SF3->F3_ISSST   := "1"
		SF3->F3_CODRSEF := Left(ZM4->ZM4_RETCTE,3)
		SF3->F3_CHVNFE  := ZM4->ZM4_CHVCTE
		SF3->F3_CODRET  := "T"
		SF3->F3_CFO     := ZM4->ZM4_CFOP
		SF3->F3_ESTADO  := ZM4->ZM4_UFDEST
		SF3->F3_BASEICM := ZM4->ZM4_BASICM
		SF3->F3_VALICM  := ZM4->ZM4_VALICM
		SF3->F3_ISENICM := ZM4->ZM4_ISEICM
		MsUnlock()

		SFT->(DbSetOrder(1))
		SFT->(DbGoTop())
		If SFT->(DBSeek(xFilial("SFT") + "S" + SF3->F3_SERIE + SF3->F3_NFISCAL + SF3->F3_CLIEFOR + SF3->F3_LOJA))
			Do While !SFT->(Eof()) .AND. SFT->FT_FILIAL + SFT->FT_TIPOMOV + SFT->FT_SERIE + SFT->FT_NFISCAL + SFT->FT_CLIEFOR + SFT->FT_LOJA == xFilial("SFT") + "S" + SF3->F3_SERIE + SF3->F3_NFISCAL + SF3->F3_CLIEFOR + SF3->F3_LOJA

				RecLock("SFT",.F.)
				SFT->FT_ISSST   := "1"
				SFT->FT_ESPECIE := "CTE"
				SFT->FT_CODNFE  := ZM4->ZM4_PROCTE
				SFT->FT_CHVNFE  := ZM4->ZM4_CHVCTE
				SFT->FT_CFOP    := ZM4->ZM4_CFOP
				SFT->FT_ESTADO  := ZM4->ZM4_UFDEST
				SFT->FT_BASEICM := ZM4->ZM4_BASICM
				SFT->FT_VALICM  := ZM4->ZM4_VALICM
				SFT->FT_ISENICM := ZM4->ZM4_ISEICM
				MsUnlock()

				SFT->(DbSkip())
			Enddo

		EndIf

	EndIf

	FWRestArea(_aAreaSF2)
	FWRestArea(_aAreaSF3)
	FWRestArea(_aAreaSFT)
	FWRestArea(_aArea)

Return
