#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "TBICODE.ch"

USER FUNCTION DTI164_EUA(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_seqPetq,_Hora,_cLotePor)
//                          1       2       3      4     5      6      7     8       9       10    11    12    13     14      15       16  17     18     19      20
//USER FUNCTION DTI164_EUA(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_Hora)
//                          1       2       3      4     5      6      7     8       9       10    11    12    13     14      15       16  17     18
    SB1->(dbsetorder(1))
	SB1->(MsSeek(FWxfilial('SB1')+alltrim(_cod)))

    _cNotImp      := GetAdvFVal('SZU','ZU_NOTIMP',FWxfilial('SZU') + SZ8->Z8_NUMPREV,2)
    _cDescPor     := SB1->B1_DESCSIF
    _cDescIng     := SB1->B1_DINGLES
    _cDescEsp     := SB1->B1_DESCESP
    _cDestino     := SB1->B1_DESTINO
    _cDataAbate   := _vDTABATE := DToC(SZ2->Z2_DATAABT)
    _cPesoBruto   := (strtran(transform(_pesob, '@E 99.999' ), ',' , '.'))
    _cPesoLiq     := (strtran(transform(_pesol, '@E 99.999' ), ',' , '.'))
    _nTaraPrim    := _quant * (GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB') + alltrim(GetAdvFVal('SB1','B1_CTARAP',FWxfilial('SB1') + SB1->B1_COD,1)),1))
    _cTaraPrim    := (strtran(transform(_quant * (GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB') + alltrim(GetAdvFVal('SB1','B1_CTARAP',FWxfilial('SB1') + SB1->B1_COD,1)),1)),'@E ##.###'), ',' , '.'))
    _nTaraSec     := (GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB') + alltrim(GetAdvFVal('SB1','B1_CTARASE',FWxfilial('SB1') + SB1->B1_COD,1)),1))
    _cTaraSec     := strtran((transform((GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB') + alltrim(GetAdvFVal('SB1','B1_CTARASE',FWxfilial('SB1') + SB1->B1_COD,1)),1)),'@E ##.###')), ',' , '.')
    _cTaraTotal   := strtran(transform(_tara, '@E #.###' ), ',' , '.')
    _cMsgSIF      := SB1->B1_MENETQ1
    _cMsgGlutem   := SB1->B1_MENETQ3
    _cMsgMantCong := SB1->B1_MENETQ2
    _cSeqPE       := SZ8->Z8_SEQPETQ
    _cQtdEtq      := GetAdvFVal('ZZR','ZZR_QTDCX',FWxfilial('ZZR') + SZ8->Z8_CONTROL,4)
    _cLoteEUA     := GetAdvFVal('SZU','ZU_LOTEUA',FWxfilial('SZU') + SZ8->Z8_NUMPREV,2)
    _nCdBarcli    := SB1->B1_EANCLI
    _cCmdZPL      := ""
    _nCodBar      := SB1->B1_CODBAR
    Private _sPl 	:= Chr(13) + Chr(10)
    
    _cCmdZPL += "" + _sPl
    _cCmdZPL += "^XA" + _sPl
    _cCmdZPL += "^FT230,1380^A0R,23,24^FH\^FD\A7C^FS"    

    //DEFINE ESTILO E TAMANHO DA FONTE DE TEXTO   
    _cEstilo1 := "15,10"
    _cEstilo2 := "25,18"
    _cEstilo3 := '45,20'  
    aTemper := STRTOKARR(_cMsgMantCong, ' ')
    //VERIFICA O VINCULO ENTRE ESTAÇÃO E IMPRESSORA    
	dbselectarea('ZAM')
	ZAM->(DbSetOrder(2))
	IF ZAM->(MsSeek(FWxFilial('ZAM') + alltrim(getComputerName())))
        _cIp := alltrim(ZAM->ZAM_IP)
	ENDIF    
    //INICIA A IMPRESSORA
    MSCBPRINTER(_modelo,"IP",,,,,_IP)
    //MSCBPRINTER(_modelo,"IP",,,,,'10.11.20.4')
    MSCBCHKSTATUS(.f.)
    MSCBLoadGRF("LOGOSIF.GRF")
    MSCBLoadGRF("DADOSIF.GRF")
    MSCBLoadGRF("ICON_CLO.GRF")
    MSCBBEGIN(_nNumEtq,6,40)

    MSCBSAY(018,165,aTemper[4] + _cCmdZPL,"R","F",_cEstilo2)

    MSCBGrafic(52, 005, "LOGOSIF")
    MSCBGrafic(00, 007, "DADOSIF")
    MSCBGrafic(15, 140, "ICON_CLO")
    
    MSCBSAY(091,065,_cDescIng,"R","F",_cEstilo1)
    MSCBSAY(087,065,_cDescPor,"R","F",_cEstilo1)
    MSCBSAY(083,065,"A-F 95 CL","R","F",_cEstilo1)
    MSCBSAY(079,065,"PRODUCT OF BRAZIL","R","F",_cEstilo1)
    MSCBSAY(075,065,"Batch/Lote:","R","F",_cEstilo1)    
    MSCBSAY(075,101,_cLoteEUA,"R","F",_cEstilo2)
    MSCBSAY(087,180,_cDestino,"R","F",_cEstilo3)	    
    //MSCBSAY(082,180, _Hora,"R","F",_cEstilo1)
    MSCBSAY(075,180, _control,"R","F",_cEstilo1)

    MSCBBOX(075,065,075,200,4)

    MSCBSAY(071,065,"Production Date:","R","F",_cEstilo1)
    MSCBSAY(067,065,"Data da Produção:","R","F",_cEstilo1)    
    MSCBSAY(071,101, substr(DToC(_datap),4,3)+substr(DToC(_datap),1,3)+substr(DToC(_datap),7,2),"R","F",_cEstilo2)
    MSCBSAY(067,101, DToC(_datap),"R","F",_cEstilo2)

    MSCBSAY(071,125,"Packing Date:","R","F",_cEstilo1)
    MSCBSAY(067,125,"Data Embalagem:","R","F",_cEstilo1)
    MSCBSAY(071,156, substr(DToC(_datap),4,3)+substr(DToC(_datap),1,3)+substr(DToC(_datap),7,2),"R","F",_cEstilo2)
    MSCBSAY(067,156, DToC(_datap),"R","F",_cEstilo2)

    MSCBSAY(061,065,"Freezing Date:","R","F",_cEstilo1)
    MSCBSAY(057,065,"Data Congelamento:","R","F",_cEstilo1)
    MSCBSAY(061,101, substr(DToC(_datap),4,3)+substr(DToC(_datap),1,3)+substr(DToC(_datap),7,2),"R","F",_cEstilo2)
    MSCBSAY(057,101, DToC(_datap),"R","F",_cEstilo2)

    //MSCBSAY(061,125,"Traceab. Code:","R","F",_cEstilo1)
    //MSCBSAY(057,125,"Cód. Rastreavel:","R","F",_cEstilo1)    
    //MSCBSAY(058,156,GetMv("MV_NUMIF") + strtran(_vDTABATE,'/','') +'0000',"R","F",_cEstilo2)

    MSCBSAY(051,065,"Best Before","R","F",_cEstilo1)
    MSCBSAY(047,065,"Data Validade.","R","F",_cEstilo1)
    MSCBSAY(051,101, substr(DToC(_dataval),4,3)+substr(DToC(_dataval),1,3)+substr(DToC(_dataval),7,2),"R","F",_cEstilo2)
    MSCBSAY(047,101,DToC(_dataval),"R","F",_cEstilo2)

    MSCBSAY(061,125,"Box Tare:","R","F",_cEstilo1)
    MSCBSAY(057,125,"Tara da Caixa:","R","F",_cEstilo1)
    MSCBSAY(058,156,(strtran(transform((_nTaraSec * 1.000),'@E 99.999'),',','.')) + "g","R","F",_cEstilo2)

    MSCBSAY(041,065,"Packing Tare:","R","F",_cEstilo1)
    MSCBSAY(037,065,"Tara da Embalagem:","R","F",_cEstilo1)    
    MSCBSAY(038,101,(strtran(transform((_nTaraPrim * 1.000),'@E 99.999'),',','.')) + "g","R","F",_cEstilo2)

    MSCBSAY(051,125,"Quantity:","R","F",_cEstilo1)
    MSCBSAY(047,125,"Quantidade:","R","F",_cEstilo1)
    MSCBSAY(048,156,str(_cQtdEtq),"R","F",_cEstilo2)

    MSCBSAY(031,065,"Gross Weight:","R","F",_cEstilo1)
    MSCBSAY(027,065,"Peso Bruto:","R","F",_cEstilo1)
    MSCBSAY(031,101,(strtran(transform((_pesob * 2.20462262185),'@E 99.99'),',','.')) + "lb","R","F",_cEstilo2)  
    MSCBSAY(027,101,_cPesoBruto + ' Kg',"R","F",_cEstilo2)                                     
    
    MSCBSAY(041,125,"Net Weight:","R","F",_cEstilo1)
    MSCBSAY(037,125,"Peso Liquido:","R","F",_cEstilo1)
    MSCBSAY(041,156,(strtran(transform((_pesol * 2.20462262185),'@E 99.99'),',','.')) + "lb","R","F",_cEstilo2)
    MSCBSAY(037,156,_cPesoLiq + 'Kg',"R","F",_cEstilo2)    

    MSCBSAY(031,125,"Keep Frozen At:","R","F",_cEstilo1)
    MSCBSAY(027,125,"Manter Congelado a:","R","F",_cEstilo1)
    MSCBSAY(028,165,aTemper[4],"R","F",_cEstilo2)
    
    MSCBSAY(017,148, _Hora,"R","F",_cEstilo1)
    MSCBSAYBAR(015,101,_control,"R","C",10,.F.,.T.,,,2,1,.T.)
    MSCBBOX(15,65,27,100,80,"B") //MSCBBOX(4,88,17,123,80,"B")
    MSCBSAYMEMO(12,65,58,1,alltrim(_cod),"R","0","110,80",.t.,"J") //MSCBSAYMEMO(2,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")
    
    cPEAN14  := getMV('SI_CDEAN14')
	cPEan142 := getMV('SI_CEAN142')
	cPEan143 := getMV('SI_CEAN143')
	cPEan144 := getMV('SI_CEAN144')
	cPEan145 := getMV('SI_CEAN145')

	IF (alltrim(_cod) $ cPEAN14) .or. (alltrim(_cod) $ cPEan142) .or. (alltrim(_cod) $ cPEan143).or. (alltrim(_cod) $ cPEan144).or. (alltrim(_cod) $ cPEan145)
		IF !empty(_nCdBarcli)//bloco para imprimir dun14 do cliente
			_cod13 := '1' + substr(_nCdBarcli,1,12)				 
		ELSE
			_cod13 := '1' + substr(_nCodBar,1,12)	
		ENDIF
	    
        _cod13 := '1' + substr(_nCodBar,1,12)
		_cDig  := EAN14(_cod13)
		_cod14 := _cod13 + _cDig		
        MSCBSAYBAR(015,180,_cod14,"N","C",13,.F.,.T.,,,3,1,.T.)
	ENDIF    
    //ENVIA DADOS E FINALIZA A IMPRESSÃO
    MSCBEND()
    MSCBCLOSEPRINTER()
RETURN

STATIC FUNCTION EAN14(cCod13)
	LOCAL nOdd := 0
	LOCAL nEven := 0 
	LOCAL nI
	LOCAL nDig  
	LOCAL nMul := 10 
	FOR nI := 1 to 13
		IF (nI%2) == 0
			nEven += val(substr(cCod13,nI,1))
		ELSE
			nOdd += val(substr(cCod13,nI,1))
		ENDIF
	NEXT
	nDig := nEven + (nOdd*3)
	WHILE nMul<nDig
		nMul += 10 
	ENDDO
RETURN strzero(nMul-nDig,1)
