#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} AF010TOK
Ponto de entrada para validar os dados digitados antes da gravação.
@author 	Ajustado por Evandro Mugnol
@since 		27/01/2020
@return 	lRet
@obs 		Efetua a gravação da tabela ZB2 para uso na geração do relatório personalizado de créditos PIS/COFINS
/*/

User Function AF010TOK()

	Local aArea := GetArea()
	Local _lRet := .T.

	If M->N1_CALCPIS == "3"

		DbSelectArea("ZB2")
		DbSetOrder(1)
		DbSeek(xFilial("ZB2") + M->N1_CBASE + M->N1_ITEM)
		If !Found()
			GravaZB2( .T. )
		Else
			GravaZB2( .F. )
		Endif
		
	Endif

	RestArea(aArea)

Return(_lRet)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função que efetua gravação da ZB2                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function gravaZB2(_lOper)

	DbSelectArea("ZB2")
	Reclock( "ZB2", _lOper )
	ZB2->ZB2_FILIAL	:= xFilial("ZB2")
	ZB2->ZB2_CBASE	:= M->N1_CBASE
	ZB2->ZB2_ITEM	:= M->N1_ITEM
	ZB2->ZB2_DESCRI	:= M->N1_DESCRIC
	ZB2->ZB2_AQUISI	:= M->N1_AQUISIC
	ZB2->ZB2_VLAQUI	:= M->N1_ALTVAL
	ZB2->ZB2_MESCPI	:= M->N1_MESCPIS
	ZB2->ZB2_VLPIST	:= M->N1_ALTVAL * 0.0165
	ZB2->ZB2_VLCOFT	:= M->N1_ALTVAL * 0.0760
	ZB2->ZB2_VLRPIS	:= ( (M->N1_ALTVAL * 0.0165) / M->N1_MESCPIS)
	ZB2->ZB2_VLRCOF	:= ( (M->N1_ALTVAL * 0.0760) / M->N1_MESCPIS)
	ZB2->ZB2_PCRED	:= 0		// Nr de meses depreciados
	ZB2->ZB2_SLDPIS	:= ( M->N1_MESCPIS * ( ( (M->N1_ALTVAL * 0.0165) / M->N1_MESCPIS) ) )
	ZB2->ZB2_SLDCOF	:= ( M->N1_MESCPIS * ( ( (M->N1_ALTVAL * 0.0760) / M->N1_MESCPIS) ) )
	ZB2->ZB2_SLDTOT	:= ( M->N1_MESCPIS * ( ( (M->N1_ALTVAL * 0.0165) / M->N1_MESCPIS) ) ) + ( M->N1_MESCPIS * ( ( (M->N1_ALTVAL * 0.0760 ) / M->N1_MESCPIS) ) )
	ZB2->ZB2_ITEMNF	:= M->N1_ITEMNF
	ZB2->ZB2_SERIE	:= M->N1_NSERIE
	ZB2->ZB2_DOC	:= M->N1_NFISCAL
	ZB2->ZB2_FORNEC	:= M->N1_FORNEC
	ZB2->ZB2_LOJA	:= M->N1_LOJA
	ZB2->ZB2_ATIVO  := "S"
	MsUnlock()

Return
