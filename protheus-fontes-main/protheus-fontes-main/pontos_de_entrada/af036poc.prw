#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} AF036POC
Ponto de entrada pós gravação da baixa do ativo fixo para manutenção na tabela ZB2
@author 	Ajustado por Evandro Mugnol
@since 		28/01/2020
@return 	lRet
@obs 		Nil
/*/

User Function AF036POC()  

	If cEmpAnt == "01" 
		
		DbSelectArea("ZB2")
		DbSetOrder(1)
		DbSeek(xFilial("ZB2") + SN3->N3_CBASE + SN3->N3_ITEM)	
		If Found()		// Baixa ou transferencia torna o bem inativo para calculo
			RecLock("ZB2",.F.)
			ZB2->ZB2_ATIVO := "N"
			MsUnlock()
		Endif

		// Quando transferencia, cria um registro em outra filial...
		If AllTrim( FunName()) == "ATFA060"    
			//_filial := cFilDest 			// Variável do campo de filial de destino na transferencia
			_filial := ZB2->ZB2_FILIAL
			_cBase  := ZB2->ZB2_CBASE	
			_Item   := ZB2->ZB2_ITEM	
			_Descri := ZB2->ZB2_DESCRI
			_Aquisi := ZB2->ZB2_AQUISI
			_VlAqui := ZB2->ZB2_VLAQUI
			_MesCPI := ZB2->ZB2_MESCPI
			_VlPist := ZB2->ZB2_VLPIST
			_VlCost := ZB2->ZB2_VLCOFT
			_VlrPIS := ZB2->ZB2_VLRPIS	
			_VlrCof := ZB2->ZB2_VLRCOF	
			_Pcred  := ZB2->ZB2_PCRED		
			_SldPis := ZB2->ZB2_SLDPIS	
			_SldCof := ZB2->ZB2_SLDCOF	
			_Sldtot := ZB2->ZB2_SLDTOT	
			_ItemNF := ZB2->ZB2_ITEMNF	
			_Serie  := ZB2->ZB2_SERIE		
			_Doc    := ZB2->ZB2_DOC		
			_Fornec := ZB2->ZB2_FORNEC	
			_Loja   := ZB2->ZB2_LOJA		

			DbSelectArea("ZB2")
			reclock("ZB2",.T.)
			ZB2->ZB2_FILIAL	:= _filial	// Filial
			ZB2->ZB2_CBASE	:= _cBase	// Cbase
			ZB2->ZB2_ITEM	:= _Item	// Item
			ZB2->ZB2_DESCRI	:= _Descri	// Descrição
			ZB2->ZB2_AQUISI	:= _Aquisi	// Data Aquisição
			ZB2->ZB2_VLAQUI	:= _VlAqui
			ZB2->ZB2_MESCPI	:= _MesCPI
			ZB2->ZB2_VLPIST	:= _VlPist
			ZB2->ZB2_VLCOFT	:= _VlCost
			ZB2->ZB2_VLRPIS	:= _VlrPIS
			ZB2->ZB2_VLRCOF	:= _VlrCof
			ZB2->ZB2_PCRED	:= _Pcred 	// Nr de meses da parcela do Ativo a depreciar	   	*
			ZB2->ZB2_SLDPIS	:= _SldPis
			ZB2->ZB2_SLDCOF	:= _SldCof
			ZB2->ZB2_SLDTOT	:= _Sldtot
			ZB2->ZB2_ITEMNF	:= _ItemNF
			ZB2->ZB2_SERIE	:= _Serie
			ZB2->ZB2_DOC	:= _Doc
			ZB2->ZB2_FORNEC	:= _Fornec
			ZB2->ZB2_LOJA	:= _Loja
			ZB2->ZB2_ATIVO  := "S"
		Endif
	Endif

Return 
