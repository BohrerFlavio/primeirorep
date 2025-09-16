User Function ETQEMBMDS(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_cSeq,_Hora,_cReimp)
    DBSelectArea('SB1')
    SB1->(DBSetOrder(1))
    SB1->(MSSeek(FWXFilial('SB1')+ALLTRIM(_cod)))
    DBSelectArea('ZZ7')
    ZZ7->(DBSetOrder(1))
    ZZ7->(MSSeek(FWXFilial('SB1')+ALLTRIM(_cod)))

    cCONRES := GetAdvFVal('SBM','BM_FARM',FWXFilial('SBM')+AllTrim(SB1->B1_GRUPO),1)
    SBM->(DBSetOrder(1))
    SBM->(MSSeek(FWXFilial('SB1')+ALLTRIM(cCONRES)))

    Private cPT_Titu01 := "Data de abate/produ\87\C6o/lote:" //Titulo da data de produ\87\C6o em Português
    Private cIN_Titu01 := "Slaughter date/production/batch:" //Titulo da data de produ\87\C6o em Inglês
    Private cES_Titu01 := "Fecha de matanza:" //Titulo da data de produ\87\C6o em Espanhol  
    Private cPT_Titu02 := "Data embalagem/congelamento:" //Titulo da data de congelamento em Português
    Private cIN_Titu02 := "Freezing date:" //Titulo da data de congelamento em Inglês
    Private cES_Titu02 := "Fecha de embalaje/congelaci\A2n:" //Titulo da data de congelamento em Espanhol
    Private cPT_Tit02  := "Data embalagem/resfriamento:" //Titulo da data de congelamento em Português
    Private cIN_Tit02  := "Packing/cooling date:" //Titulo da data de congelamento em Inglês
    Private cES_Tit02  := "Fecha de embalaje/refrigeraci\A2n:" //Titulo da data de congelamento em Espanho
    Private cPT_Titu03 := "Data de validade:" //Titulo da data de validade em Português
    Private cIN_Titu03 := "Expiration date:" //Titulo da data de validade em Inglês
    Private cES_Titu03 := "Fecha de validad:" //Titulo da data de validade em Espanhol
    Private cPT_Titu05 := "Manter congelado a:" //Titulo do congelamento em Português
    Private cIN_Titu05 := "Keep frozen at:" //Titulo do congelamento em Inglês
    Private cES_Titu05 := "Mantener congelado en:" //Titulo do congelamento em Espanhol
    Private cPT_Tit05  := "Manter resfriado a:" //Titulo do congelamento em Português
    Private cIN_Tit05  := "Keep cool at:" //Titulo do congelamento em Inglês
    Private cES_Tit05  := "Mantener frio en:" //Titulo do congelamento em Espanhol
    Private cPT_Titu5  := "Mantenha em lugar seco e arejado at\82 35\A7C"
    Private cIN_Titu5  := "Keep in a dry and ventilated place up to 35\A7C"
    Private cES_Titu5  := "Conservar en lugar seco y ventilado hasta 35\A7C"
    Private cPT_Titu06 := "Rastreabilidade:" //Titulo da rastreabilidade em Português
    Private cIN_Titu06 := "Traceability:" //Titulo da rastreabilidade em Inglês
    Private cES_Titu06 := "Trazabilidad:" //Titulo da rastreabilidade em Espanhol
    Private cPT_Titu07 := "Peso bruto:" //Titulo do peso bruto em Português
    Private cIN_Titu07 := "Gross weight:" //Titulo do peso bruto em Inglês
    Private cES_Titu07 := "Peso bruto:" //Titulo do peso bruto em Espanhol
    Private cPT_Titu08 := "Peso liquido:" //Titulo do peso liquido em Português
    Private cIN_Titu08 := "Net weight:" //Titulo do peso liquido em Inglês
    Private cES_Titu08 := "Peso neto:" //Titulo do peso liquido em Espanhol
    Private cPT_Titu09 := "Tara primaria:" //Titulo da tara da embalagem em Português
    Private cIN_Titu09 := "Primary packing tare:" //Titulo da tara da embalagem em Inglês
    Private cES_Titu09 := "Tara embalaje primario:" //Titulo da tara da embalagem em Espanhol
    Private cPT_Titu10 := "Tara da caixa:" //Titulo da tara da caixa em Português
    Private cIN_Titu10 := "Carton tare:" //Titulo da tara da caixa em Inglês
    Private cES_Titu10 := "Tara de caja:" //Titulo da tara da caixa em Espanhol
    Private cPT_Titu11 := "Quantidade:" //Titulo da quantidade em Português
    Private cIN_Titu11 := "Quantity:" //Titulo da quantidade em Inglês
    Private cES_Titu11 := "Cantidad:" //Titulo da quantidade em Espanhol
    Private cPT_Titu12 := "Hora:" //Titulo do horario em Português
    Private cIN_Titu12 := "Hour:" //Titulo do horario em Inglês
    Private cES_Titu12 := "Hora:" //Titulo do horario em Espanhol

    Private Modelo  := _modelo
    Private Portap  := _porta
    Private NumCxa  := AllTrim(_control)
    Private CodPro  := AllTrim(_cod)
    Private Quanti  := _quant
    Private nPesoB  := _pesob
    Private nPesoL  := _pesol
    Private IPprint := _IP
    Private Hora    := AllTrim(_Hora)
    Private cPT_DesSIF := AllTrim(SB1->B1_DESCSIF)
    Private cIN_DesSIF := AllTrim(SB1->B1_DINGLES)
    Private cES_DesSIF := AllTrim(SB1->B1_DESPANH)
    Private cPT_DesCor := AllTrim(SB1->B1_DESCRED)
    Private cIN_DesCor := AllTrim(SB1->B1_DESCING)
    Private cES_DesCor := AllTrim(SB1->B1_DESCESP)
    Private cNumPrevi  := Alltrim(GetAdvFVal('SZ8','Z8_NUMPREV',FWXFilial('SZ8')+NumCxa,3))
    Private cDtaAbate  := DToC(GetAdvFVal('SZU','ZU_DTABT',FWXFilial('SZU')+cNumPrevi,2))
    Private nTaraEmb   := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+AllTrim(SB1->B1_CTARAP),1)    
    Private nTaraCxa   := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+AllTrim(SB1->B1_CTARASE),1)
    PRIVATE QuantiCxa  := AllTrim(STR(GetAdvFVal('SZ8','Z8_QUANT',FWXFilial('SZ8')+_control,3)))
    PRIVATE Destino    := ALLTRIM(SB1->B1_DESTINO) //Destino do produto
    Private dPT_DtaPro := AllTrim(DToC(_datap))     //Data de produ\87\C6o em formato DDMMAA
    Private dIN_DtaPro := SubSTR(DToC(_datap),4,3)+SubSTR(DToC(_datap),1,3)+SubSTR(DToC(_datap),7,2) //Data de produ\87\C6o em formato MMDDAA
    Private dES_DtaPro := AllTrim(DToC(_datap))     //Data de produ\87\C6o em formato DDMMAA
    Private dPT_DtaCon := AllTrim(DToC(_datap + 2)) //Data de congelamento. Esta data será dois dias ap\A2s a produ\87\C6o
    Private dIN_DtaCon := SubSTR(DToC(_datap + 2),4,3)+SubSTR(DToC(_datap + 2),1,3)+SubSTR(DToC(_datap + 2),7,2)
    Private dES_DtaCon := AllTrim(DToC(_datap + 2)) //Data de congelamento. Esta data será dois dias ap\A2s a produ\87\C6o
    Private dPT_DtaVal := AllTrim(DToC(_dataval)) //Data de validade
    PRIVATE dIN_DtaVal := SubSTR(DToC(_dataval),4,3)+SubSTR(DToC(_dataval),1,3)+SubSTR(DToC(_dataval),7,2)
    Private dES_DtaVal := AllTrim(DToC(_dataval)) //Data de validade
    Private dPT_DtaAbt := cDtaAbate
    Private dIN_DtaAbt := SubSTR(cDtaAbate,4,3)+SubSTR(cDtaAbate,1,3)+SubSTR(cDtaAbate,7,2)
    Private dES_DtaAbt := cDtaAbate
    Private cTempeCong := AllTrim(SB1->B1_MENETQ2)
    PRIVATE cNumRastre := '1733' + STRTran(cDtaAbate, "/", "",) + '0000' //Codigo rastreabilidade
    Private cPesoBruKg := Transform(nPesoB, '@E 99.999') //Peso bruto já formatado para impress\C6o_pesob
    Private cPesoBruLi := STRTran(Transform((nPesoB * 2.20462262185),'@E 99.99'),',','.')
    Private cPesoLiqKg := Transform(nPesoL, '@E 99.999') //Peso liquido já formatado para impress\C6o
    Private cPesoLiqLi := STRTran(Transform((nPesoL * 2.20462262185),'@E 99.99'),',','.')
    Private cTaraEmbKg := TRANSFORM(Quanti * nTaraEmb,'@E ##.###')
    Private cTaraEmbLi := STRTran(Transform((Quanti * nTaraEmb * 2.20462262185),'@E 99.99'),',','.')
    Private cTaraCxaKg := TRANSFORM(nTaraCxa,'@E ##.###')
    Private cTaraCxaLi := STRTran(Transform((nTaraCxa * 2.20462262185),'@E 99.99'),',','.')
    Private cNumPreEtq := AllTrim(GetAdvFVal('SZ8','Z8_SEQPETQ',FWXFilial('SZ8')+NumCxa,3)) //Nº da pr\82-etiqueta
    Private cShipM     := AllTrim(GetAdvFVal('SZU','ZU_SHIPPIN',FWXFilial('SZU')+ALLTRIM(SZ8->Z8_NUMPREV),2))
    Private LoteEUA    := AllTrim(GetAdvFVal('SZU','ZU_LOTEUA',FWXFilial('SZU')+ALLTRIM(SZ8->Z8_NUMPREV),2))
    Private cReimp     := _cReimp //Variavel para reimpress\C6o da etiqueta

    Imprime()  
Return

Static Function EtqZPLII()
    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:ARIALBD.TTF")
    MSCBWrite("^FWR")

    MSCBWrite("^CFA,20")
    MSCBWrite("^FO" + "280,010" + "^FH\^FD" + "Registro no Minist\82rio da Agricultura SIF/DIPOA sob n\A7 ^FS")
    MSCBWrite("^FO" + "260,010" + "^FH\^FD" + "Registration in the Ministry of Agriculture SIF/DIPOA under no. ^FS")
    MSCBWrite("^FO" + "240,010" + "^FH\^FD" + "Registro an el Minist\82rio da Agricultura SIF/DIPOA bajo n\A7 ^FS")
    MSCBWrite("^FO" + "220,200" + "^FH\^FD" + ZZ7->ZZ7_MSIF + "^FS")
    MSCBWrite("^FO" + "190,010" + "^FH\^FD" + "FRIGOR\D6FICO SILVA IND\E9STRIA E COM\90RCIO LTDA. ^FS")
    MSCBWrite("^FO" + "170,010" + "^FH\^FD" + "ABATEDOURO FRIGOR\D6FICO IND. E COM. DE CARNES ^FS")
    MSCBWrite("^FO" + "150,010" + "^FH\^FD" + "E SEUS DERIVADOS ^FS")
    MSCBWrite("^FO" + "130,010" + "^FH\^FD" + "CNPJ: 88.728.027/0001-46 ^FS")
    MSCBWrite("^FO" + "110,010" + "^FH\^FD" + "INSC EST: 109/0096949 | PRODUCT OF BRAZIL ^FS")
    MSCBWrite("^FO" + "090,010" + "^FH\^FD" + "BR 392 Km 8 - BAIRRO TOMAZETTI - SANTA MARIA-RS ^FS")
    MSCBWrite("^FO" + "070,010" + "^FH\^FD" + "BRASIL - CEP 97065-400 ^FS")
    MSCBWrite("^FO" + "050,010" + "^FH\^FD" + "OFFICE FONE: +55 55 2103 2525 ^FS")
    MSCBWrite("^FO" + "030,010" + "^FH\^FD" + "www.frigorificosilva.com.br ^FS")

    MSCBWrite("^CFA,25")
    If !Empty(SB1->B1_DESCSIF)
        MSCBWrite("^FO" + "780,600" + "^FH\^FD" + cPT_DesSIF + "^FS")
    else
        MSCBWrite("^FO" + "780,600" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    EndIf

    If !Empty(SB1->B1_DINGLES)
        MSCBWrite("^FO" + "750,600" + "^FH\^FD" + cIN_DesSIF + "^FS")
    else
        MSCBWrite("^FO" + "750,600" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    EndIf

    If !Empty(SB1->B1_DESPANH)
        MSCBWrite("^FO" + "720,600" + "^FH\^FD" + cES_DesSIF + "^FS")
    else
        MSCBWrite("^FO" + "720,600" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    EndIf

    If !Empty(SB1->B1_DESC)
        MSCBWrite("^FO" + "690,600" + "^FH\^FD" + cPT_DesCor + "^FS")
    Else
        MSCBWrite("^FO" + "690,600" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    EndIf

    If !Empty(SB1->B1_DESCING)
        MSCBWrite("^FO" + "660,600" + "^FH\^FD" + cIN_DesCor + "^FS")
    Else
        MSCBWrite("^FO" + "660,600" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    EndIf

    If !Empty(SB1->B1_DESCESP)
        MSCBWrite("^FO" + "630,600" + "^FH\^FD" + cES_DesCor + "^FS")
    Else
        MSCBWrite("^FO" + "630,620" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    EndIf

    //LINHA HORIZONTAL 1
    MSCBWrite("^FO 585,620")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DADOS SOBRE A DATA DE PRODU\87\C6O
    MSCBWrite("^FO 560,620")
    MSCBWrite("^FH\^FD " + cPT_Titu01 + "^FS")
    MSCBWrite("^FO 540,620")
    MSCBWrite("^FH\^FD " + cIN_Titu01 + "^FS")
    MSCBWrite("^FO 520,620")
    MSCBWrite("^FH\^FD " + cES_Titu01 + "^FS")
    MSCBWrite("^FO 560,1040")
    MSCBWrite("^FH\^FD " + dPT_DtaAbt + "^FS")
    MSCBWrite("^FO 540,1040")
    MSCBWrite("^FH\^FD " + dIN_DtaAbt + "^FS")
    MSCBWrite("^FO 520,1040")
    MSCBWrite("^FH\^FD " + dES_DtaAbt + "^FS")

    //DADOS SOBRE PESO BRUTO
    MSCBWrite("^FO 560,1150")
    MSCBWrite("^FH\^FD " + cPT_Titu07 + "^FS")
    MSCBWrite("^FO 540,1150")
    MSCBWrite("^FH\^FD " + cIN_Titu07 + "^FS")
    MSCBWrite("^FO 520,1150")
    MSCBWrite("^FH\^FD " + cES_Titu07 + "^FS")
    MSCBWrite("^FO 560,1430")
    MSCBWrite("^FH\^FD " + cPesoBruKg + " kg" + "^FS")
    MSCBWrite("^FO 540,1430")
    MSCBWrite("^FH\^FD " + cPesoBruLi + " Lb" + "^FS")
    MSCBWrite("^FO 520,1430")
    MSCBWrite("^FH\^FD " + cPesoBruKg + " kg" + "^FS")

    //LINHA HORIZONTAL 2
    MSCBWrite("^FO 515,620")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DADOS SOBRE A DATA DE CONGELAMENTO OU RESFRIAMENTO
    If (cCONRES = 'C')
        MSCBWrite("^FO 485,620")
        MSCBWrite("^FH\^FD " + cPT_Titu02 + "^FS")
        MSCBWrite("^FO 465,620")
        MSCBWrite("^FH\^FD " + cIN_Titu02 + "^FS")
        MSCBWrite("^FO 445,620")
        MSCBWrite("^FH\^FD " + cES_Titu02 + "^FS")
    ElseIf (cCONRES = 'R')
        MSCBWrite("^FO 485,620")
        MSCBWrite("^FH\^FD " + cPT_Tit02 + "^FS")
        MSCBWrite("^FO 465,620")
        MSCBWrite("^FH\^FD " + cIN_Tit02 + "^FS")
        MSCBWrite("^FO 445,620")
        MSCBWrite("^FH\^FD " + cES_Tit02 + "^FS")
    EndIf

    MSCBWrite("^FO 485,1040")
    MSCBWrite("^FH\^FD " + dPT_DtaPro + "^FS")
    MSCBWrite("^FO 465,1040")
    MSCBWrite("^FH\^FD " + dIN_DtaPro + "^FS")
    MSCBWrite("^FO 445,1040")
    MSCBWrite("^FH\^FD " + dES_DtaPro + "^FS")

    //DADOS SOBRE PESO LIQUIDO
    MSCBWrite("^FO 485,1150")
    MSCBWrite("^FH\^FD " + cPT_Titu08 + "^FS")
    MSCBWrite("^FO 465,1150")
    MSCBWrite("^FH\^FD " + cIN_Titu08 + "^FS")
    MSCBWrite("^FO 445,1150")
    MSCBWrite("^FH\^FD " + cES_Titu08 + "^FS")
    MSCBWrite("^FO 485,1430")
    MSCBWrite("^FH\^FD " + cPesoLiqKg + " kg" + "^FS")
    MSCBWrite("^FO 465,1430")
    MSCBWrite("^FH\^FD " + cPesoLiqLi + " Lb" + "^FS")
    MSCBWrite("^FO 445,1430")
    MSCBWrite("^FH\^FD " + cPesoLiqKg + " kg" + "^FS")

    //LINHA HORIZONTAL 3
    MSCBWrite("^FO 440,620")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DADOS SOBRE A DATA DE VALIDADE
    MSCBWrite("^FO 415,620")
    MSCBWrite("^FH\^FD " + cPT_Titu03 + "^FS")
    MSCBWrite("^FO 395,620")
    MSCBWrite("^FH\^FD " + cIN_Titu03 + "^FS")
    MSCBWrite("^FO 375,620")
    MSCBWrite("^FH\^FD " + cES_Titu03 + "^FS")
    MSCBWrite("^FO 415,1040")
    MSCBWrite("^FH\^FD " + dPT_DtaVal + "^FS")
    MSCBWrite("^FO 395,1040")
    MSCBWrite("^FH\^FD " + dIN_DtaVal + "^FS")
    MSCBWrite("^FO 375,1040")
    MSCBWrite("^FH\^FD " + dES_DtaVal + "^FS")

    //DADOS SOBRE A TARA DA EMBALAGEM
    MSCBWrite("^FO 415,1150")
    MSCBWrite("^FH\^FD " + cPT_Titu09 + "^FS")
    MSCBWrite("^FO 395,1150")
    MSCBWrite("^FH\^FD " + cIN_Titu09 + "^FS")
    MSCBWrite("^FO 375,1150")
    MSCBWrite("^FH\^FD " + cES_Titu09 + "^FS")
    MSCBWrite("^FO 415,1430")
    MSCBWrite("^FH\^FD " + cTaraEmbKg + " kg" + "^FS")
    MSCBWrite("^FO 395,1430")
    MSCBWrite("^FH\^FD " + cTaraEmbLi + " Lb" + "^FS")
    MSCBWrite("^FO 375,1430")
    MSCBWrite("^FH\^FD " + cTaraEmbKg + " kg" + "^FS")

    //LINHA HORIZONTAL 4
    MSCBWrite("^FO 370,620")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DADOS SOBRE A TARA DA CAIXA
    MSCBWrite("^FO 340,1150")
    MSCBWrite("^FH\^FD " + cPT_Titu10 + "^FS")
    MSCBWrite("^FO 320,1150")
    MSCBWrite("^FH\^FD " + cIN_Titu10 + "^FS")
    MSCBWrite("^FO 300,1150")
    MSCBWrite("^FH\^FD " + cES_Titu10 + "^FS")
    MSCBWrite("^FO 340,1430")
    MSCBWrite("^FH\^FD " + cTaraCxaKg + " kg" + "^FS")
    MSCBWrite("^FO 320,1430")
    MSCBWrite("^FH\^FD " + cTaraCxaLi + " Lb" + "^FS")
    MSCBWrite("^FO 300,1430")
    MSCBWrite("^FH\^FD " + cTaraCxaKg + " kg" + "^FS")

    //LINHA HORIZONTAL 5
    MSCBWrite("^FO 295,620")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DADOS SOBRE FORMA DE ARMAZENAMENTO
    MSCBWrite("^FO 340,620")
    If (cCONRES = 'R')
        MSCBWrite("^FH\^FD " + cPT_Tit05 + "^FS")
        MSCBWrite("^FO 320,620")
        MSCBWrite("^FH\^FD " + cIN_Tit05 + "^FS")
        MSCBWrite("^FO 300,620")
        MSCBWrite("^FH\^FD " + cES_Tit05 + "^FS")
    ElseIf (cCONRES = 'C')
        MSCBWrite("^FH\^FD " + cPT_Titu05 + "^FS")
        MSCBWrite("^FO 320,620")
        MSCBWrite("^FH\^FD " + cIN_Titu05 + "^FS")
        MSCBWrite("^FO 300,620")
        MSCBWrite("^FH\^FD " + cES_Titu05 + "^FS")
    ElseIf (cCONRES = 'S')
        MSCBWrite("^FH\^FD " + cPT_Titu5 + "^FS")
        MSCBWrite("^FO 340,620")
        MSCBWrite("^FH\^FD " + cIN_Titu5 + "^FS")
        MSCBWrite("^FO 300,620")
        MSCBWrite("^FH\^FD " + cES_Titu5 + "^FS")
    Else
        MSCBWrite("^FH\^FD " + "Sem dados para exibir:" + "^FS")
        MSCBWrite("^FO 340,620")
        MSCBWrite("^FH\^FD " + "No data to display:" + "^FS")
        MSCBWrite("^FO 300,620")
        MSCBWrite("^FH\^FD " + "No hay datos para mostrar:" + "^FS")
    EndIf

    If !Empty(SB1->B1_MENETQ2)
        aTemper := STRTOKARR(cTempeCong, ' ')
        MSCBWrite("^FO" + "320,920")
        IF aTemper[2] = 'CONGELADO'
            MSCBWrite("^FH\^FD" + aTemper[4] +' \A7C' + "^FS")
        ELSEIF aTemper[2] = 'RESFRIADO'
            MSCBWrite("^FH\^FD" + aTemper[4] + " a " + aTemper[6] +' \A7C' + "^FS")
        ENDIF
    Else
        MSCBWrite("^FO" + "320,920" + "^FH\^FD " + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    EndIf

    //LINHA HORIZONTAL 6
    MSCBWrite("^FO 220,620")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DAODS SOBRE RASTREABILIDADE
    MSCBWrite("^FO 265,620")
    MSCBWrite("^FH\^FD " + cPT_Titu06 + "^FS")
    MSCBWrite("^FO 245,620")
    MSCBWrite("^FH\^FD " + cIN_Titu06 + "^FS")
    MSCBWrite("^FO 225,620")
    MSCBWrite("^FH\^FD " + cES_Titu06 + "^FS")
    MSCBWrite("^FO" + "245,920")
    MSCBWrite("^FH\^FD " + cNumRastre + "^FS")

    //DADOS SOBRE HORA
    MSCBWrite("^FO 265,1150")
    MSCBWrite("^FH\^FD " + cPT_Titu12 + "^FS")
    MSCBWrite("^FO 245,1150")
    MSCBWrite("^FH\^FD " + cIN_Titu12 + "^FS")
    MSCBWrite("^FO 225,1150")
    MSCBWrite("^FH\^FD " + cES_Titu12 + "^FS")
    MSCBWrite("^FO" + "240,1350")
    MSCBWrite("^FH\^FD" + Hora + "^FS")

    //LINHA VERTICAL
    MSCBWrite("^FO 219,1150")
    MSCBWrite("^GB 370,1,4 ^FS")

    //IMPRIME NÚMERO DO SHIPPING MARK
    If !Empty(cShipM)
        MSCBWrite("^CFA,25")
        MSCBWrite("^FO" + "080,1380" + "^FH\^FD " + "SHIPPING MARK:^FS")
        MSCBWrite("^CFA,40,30")
        MSCBWrite("^FO" + "035,1380" + "^FH\^FD " + cShipM + "^FS")
    Endif

    //FUNDO PRETO COM COD DO PRODUTO HORIZONTAL
    MSCBWrite("^LRY")
    MSCBWrite("^FO 060,630")
    MSCBWrite("^GB 000,430,080 ^FS")
    MSCBWrite("^FO 060,580")
    MSCBWrite("^CFG ^FD " + Destino + " " + CodPro + " ^FS")

    //CODIGO DE BARRAS HORIZONTAL    
    MSCBWrite("^BY3,3,55")
    MSCBWrite("^FT 080,1070")
    MSCBWrite("^BCR,,Y,N")
    MSCBWrite("^FD>; " + NumCxa + " ^FS")

    //REIMPRESS\C6O
    if !empty(cReimp)
        MSCBWrite("^CFA,40,30")
        MSCBWrite("^FO 240,1450")
        MSCBWrite("^FH\^FD" + "R" + "^FS")
    endif

    //IMPRIME NÚMERO DA PRE-ETIQUETA
    MSCBWrite("^CFA,20")
    MSCBWrite("^FO 030,650")
    MSCBWrite("^FH\^FD " + "PE: " + cNumPreEtq + " ^FS")    

    //IMAGEM LOGO SIF
    MSCBWrite("^FO" + "300,010")
    MSCBWrite("^IME:LOGOSIF.GRF,1,1")

    //FIM DO BLOCO
    MSCBWrite("^PQ 1,0,1,N")
    MSCBWrite("^XZ")
Return

Static Function Imprime()

    MSCBPRINTER(Modelo,Portap,,,,,IPprint)

    MSCBCHKSTATUS(.F.)
    MSCBBEGIN(1,6,15)

    EtqZPLII()

    MSCBEND()
	MSCBCLOSEPRINTER()
RETURN
