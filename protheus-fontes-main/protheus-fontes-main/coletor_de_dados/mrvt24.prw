#INCLUDE "APVT100.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "Totvs.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "Topconn.ch"

USER FUNCTION MRVT24(_usuario)
    PRIVATE cModelo := ' '
    PRIVATE lTela  := .T.
    
	_cModelo = VTModelo()

	IF _cModelo <> 'RF'
		VTSetSize(2,16)
	ELSE
		VTSetSize(20,30)
	ENDIF

	VTClear()
	VTClearBuffer()

    WHILE lTela
        cCodPro := Space(6)
        nQtdEtq := 0
		dDtaProd:=SToD("")

        @ 01,01 VTSay "Cód. do Produto:"
        @ 03,01 VTSay "Data de produção:"
		@ 05,01 VTSay "Quant. etiquetas:"
		@ 02,01 VTGet cCodPro Pict "@!"
        @ 04,01 VTGet dDtaProd Pict "@!"
		@ 06,01 VTGet nQtdEtq Pict "@!"
        
        VTRead
		If (VTLastKey() == 27)	
			exit
		Endif

        Imprime(cCodPro, nQtdEtq)    

		VTClear()
		VTClearBuffer()
    ENDDO

    VTClear()
	VTClearBuffer()
RETURN

STATIC FUNCTION Imprime(cCodPro, nQtdEtq)
	EtiquetasEmZPLII()	
RETURN
STATIC FUNCTION EtiquetasEmZPLII()	
	SB1->(DbSetOrder(1))
    SB1->(MsSeek(FWxFilial('SB1')+alltrim(cCodPro)))

	_cDestino       := SB1->B1_DESTINO //BUSCA O DESTINO DO PRODUTO    
    _cCadMercadoria := SB1->B1_CADMERC //BUSCA O CADASTRO DA MERCADORIA DO PRODUTO
	/*
		IF (_cDestino = "MI" .or. (_cDestino = "ME" .and. _cCadMercadoria = ""))		
			Conout("MRVT24 -> Produto: " + cCodPro + " | Mercadoria Interna | " + DTos(date()) + " " + time())
			U_INTBRA(cCodPro,dDtaProd,ddatabase,dDtaProd + SB1->B1_VALID ,nQtdEtq)
		ELSEIF (_cDestino = "ME" .and. (_cCadMercadoria = "A" .OR. _cCadMercadoria = "C"))
			Conout("MRVT24 -> Produto: " + cCodPro + " | Mercadoria Externa | Americana | " + DTos(date()) + " " + time())
			INT3IDIOMA(cCodPro,dDtaProd,ddatabase,dDtaProd + SB1->B1_VALID ,nQtdEtq)    
		//SE DESTINO FOR MERCADO EXTERNO E PAIS URUGUAI
		ELSEIF (_cDestino = "ME" .and. _cCadMercadoria = "E")		
			Conout("MRVT24 -> Produto: " + cCodPro + " | Mercadoria Externa | Uruguai | " + DTos(date()) + " " + time())
			U_INTUY(cCodPro,dDtaProd,ddatabase,ddatabase + SB1->B1_VALID,nQtdEtq)
		ELSEIF (_cDestino = "ME" .and. _cCadMercadoria = "U")
			//U_INTUSA(cCodPro,SToD(ddatabase),dDtaProd,_DtVal,_nQtdEtq)
		ENDIF
	*/
	U_INT3IDIOMA(cCodPro,dDtaProd,ddatabase,dDtaProd + SB1->B1_VALID ,nQtdEtq)    
RETURN
