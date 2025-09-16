User Function ETQEMB(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_cSeq,_Hora,_cReimp)
    DBSelectArea('SB1')
    SB1->(DBSetOrder(1))
    SB1->(MSSeek(FWXFilial('SB1')+ALLTRIM(_cod)))
    DBSelectArea('ZZ7')
    ZZ7->(DBSetOrder(1))
    ZZ7->(MSSeek(FWXFilial('SB1')+ALLTRIM(_cod)))

    cCONRES := GetAdvFVal( 'SBM' , 'BM_FARM' ,FWXFilial( 'SBM' )+AllTrim(SB1->B1_GRUPO),1)
    SBM->(DBSetOrder(1))
    SBM->(MSSeek(FWXFilial('SB1')+ALLTRIM(cCONRES)))

    Private Modelo      := _modelo
    Private Portap      := _porta
    Private NumCxa      := AllTrim(_control)
    Private CodPro      := AllTrim(_cod)
    Private Quanti      := _quant
    Private nPesoB      := _pesob
    Private nPesoL      := _pesol
    Private IPprint     := _IP
    Private Hora        := AllTrim(_Hora)
    Private cPT_DesSIF  := AllTrim(SB1->B1_DESCSIF)
    Private cIN_DesSIF  := AllTrim(SB1->B1_DINGLES)
    Private cES_DesSIF  := AllTrim(SB1->B1_DESPANH)
    Private cPT_DesCor  := AllTrim(SB1->B1_DESCRED)
    Private cIN_DesCor  := AllTrim(SB1->B1_DESCING)
    Private cES_DesCor  := AllTrim(SB1->B1_DESCESP)
    Private cDtaAbate   := DToC(GetAdvFVal('SZU','ZU_DTABT',FWXFilial('SZU')+AllTrim(SZ8->Z8_NUMPREV),2)) //Data de abate
    Private nTaraEmb    := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+AllTrim(SB1->B1_CTARAP),1)    
    Private nTaraCxa    := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+AllTrim(SB1->B1_CTARASE),1)
    PRIVATE QuantiCxa   := AllTrim(STR(GetAdvFVal('SZ8','Z8_QUANT',FWXFilial('SZ8')+_control,3)))
    PRIVATE Destino     := ALLTRIM(SB1->B1_DESTINO) //Destino do produto
    Private dPT_DtaAbt  := cDtaAbate
    Private dIN_DtaAbt  := SubSTR(cDtaAbate,4,3)+SubSTR(cDtaAbate,1,3)+SubSTR(cDtaAbate,7,2)
    Private dES_DtaAbt  := cDtaAbate
    Private dPT_DtaPro  := AllTrim(DToC(_datap))     //Data de produção em formato DDMMAA
    Private dIN_DtaPro  := SubSTR(DToC(_datap),4,3)+SubSTR(DToC(_datap),1,3)+SubSTR(DToC(_datap),7,2) //Data de produção em formato MMDDAA    
    Private dPT_DtaCon  := AllTrim(DToC(_datap + 16)) //Data de congelamento. Esta data será 16 dias após a produção
    Private dIN_DtaCon  := SubSTR(DToC(_datap + 16),4,3)+SubSTR(DToC(_datap + 16),1,3)+SubSTR(DToC(_datap + 16),7,2)
    Private dPT_DtaVal  := AllTrim(DToC(_dataval)) //Data de validade
    PRIVATE dIN_DtaVal  := SubSTR(DToC(_dataval),4,3)+SubSTR(DToC(_dataval),1,3)+SubSTR(DToC(_dataval),7,2)
    PRIVATE cPT_DtaVal  := DToC(_dataval + 16)
    PRIVATE cIN_DtaVal  := SubSTR(cPT_DtaVal,4,3)+SubSTR(cPT_DtaVal,1,3)+SubSTR(cPT_DtaVal,7,2)
    Private cTempeCong  := AllTrim(SB1->B1_MENETQ2)
    PRIVATE cNumRastre  := '1733' + STRTran(cDtaAbate, "/", "",) + '0000' //Codigo rastreabilidade
    Private cPesoBruKg  := Transform(nPesoB, '@E 99.999') //Peso bruto já formatado para impressão_pesob
    Private cPesoBruLi  := STRTran(Transform((nPesoB * 2.20462262185),'@E 99.99'),',','.')
    Private cPesoLiqKg  := Transform(nPesoL, '@E 99.999') //Peso líquido já formatado para impressão
    Private cPesoLiqLi  := STRTran(Transform((nPesoL * 2.20462262185),'@E 99.99'),',','.')
    Private cTaraEmbKg  := TRANSFORM(Quanti * nTaraEmb,'@E ##.###')
    Private cTaraEmbLi  := STRTran(Transform((Quanti * nTaraEmb * 2.20462262185),'@E 99.99'),',','.')
    Private cTaraCxaKg  := TRANSFORM(nTaraCxa,'@E ##.###')
    Private cTaraCxaLi  := STRTran(Transform((nTaraCxa * 2.20462262185),'@E 99.99'),',','.')
    Private cNumPreEtq  := AllTrim(GetAdvFVal('SZ8','Z8_SEQPETQ',FWXFilial('SZ8')+NumCxa,3)) //Nº da pré-etiqueta
    Private cShipM      := AllTrim(GetAdvFVal('SZU','ZU_SHIPPIN',FWXFilial('SZU')+ALLTRIM(SZ8->Z8_NUMPREV),2))
    Private LoteEUA     := AllTrim(GetAdvFVal('SZU','ZU_LOTEUA',FWXFilial('SZU')+ALLTRIM(SZ8->Z8_NUMPREV),2))
    Private cReimp      := _cReimp //Variavel para reimpressão da etiqueta
    PRIVATE cMatura     := alltrim(GetAdvFVal('ZZ7','ZZ7_MATURA',FWXFilial('ZZ7')+alltrim(CodPro),1))

    Imprime()
Return

Static Function EtqZPLP()
    Local cPT_Titu01 := "Data de abate:"
    Local cIN_Titu01 := "Slaughter date"
    Local cPT_Titu02 := "Data produ\87\C6o/Lote:"
    Local cIN_Titu02 := "Production date/batch:"
    Local cPT_Titu03 := "Data de Congela\87\C6o:"
    Local cIN_Titu03 := "Freezing date:"
    Local cPT_Titu04 := "Consumir de prefer\88ncia antes de:"
    Local cIN_Titu04 := "Expiry date:"
    Local cPT_Titu05 := "Conservar a:"
    Local cIN_Titu05 := "Keep at:"
    Local cPT_Titu06 := "Rastreabilidade:"
    Local cIN_Titu06 := "Traceability:"
    Local cPT_Titu07 := "Peso bruto:"
    Local cIN_Titu07 := "Gross weight:"
    Local cPT_Titu08 := "Peso liquido:"
    Local cIN_Titu08 := "Net weight:"
    Local cPT_Titu09 := "Tara prim\A0ria:"
    Local cIN_Titu09 := "Primary packing tare:"
    Local cPT_Titu10 := "Tara da caixa:"
    Local cIN_Titu10 := "Carton tare:"
    Local cPT_Titu11 := "Hora:"
    Local cIN_Titu11 := "Hour:"
    Local cPT_Titu12 := "Quantidade:"
    Local cIN_Titu12 := "Quantity:"

    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:ARIALBD.TTF")
    MSCBWrite("^FWR")

    MSCBWrite("^CFA,18")
    MSCBWrite("^FO" + "280,030" + "^FH\^FD" + "Registro no Minist\82rio da Agricultura SIF/DIPOA sob n\A7 ^FS")
    MSCBWrite("^FO" + "260,030" + "^FH\^FD" + "Registration in the Ministry of Agriculture SIF/DIPOA under no. ^FS")
    MSCBWrite("^FO" + "240,200" + "^FH\^FD" + ZZ7->ZZ7_MSIF + "^FS")
    MSCBWrite("^FO" + "190,030" + "^FH\^FD" + "FRIGOR\D6FICO SILVA IND\E9STRIA E COM\90RCIO LTDA. ^FS")
    MSCBWrite("^FO" + "170,030" + "^FH\^FD" + "ABATEDOURO FRIGOR\D6FICO IND. E COM. DE CARNES ^FS")
    MSCBWrite("^FO" + "150,030" + "^FH\^FD" + "E SEUS DERIVADOS ^FS")
    MSCBWrite("^FO" + "130,030" + "^FH\^FD" + "CNPJ: 88.728.027/0001-46 ^FS")
    MSCBWrite("^FO" + "110,030" + "^FH\^FD" + "INSC EST: 109/0096949 | PRODUCT OF BRAZIL ^FS")
    MSCBWrite("^FO" + "090,030" + "^FH\^FD" + "RODOVIA BR 392 Km 8 - BAIRRO TOMAZETTI ^FS")
    MSCBWrite("^FO" + "070,030" + "^FH\^FD" + "SANTA MARIA-RS - BRASIL CEP 97065-400 ^FS")
    MSCBWrite("^FO" + "050,030" + "^FH\^FD" + "OFFICE FONE: +55 55 2103 2525 ^FS")
    MSCBWrite("^FO" + "030,030" + "^FH\^FD" + "www.frigorificosilva.com.br ^FS")

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
        MSCBWrite("^FO" + "630,600" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    EndIf    

    if cMatura == 'S'
        MSCBWrite("^FO" + "600,600" + "^FH\^FD" + "Aged 14 days (maturado)" + "^FS")
    endif

    //LINHA HORIZONTAL 1
    MSCBWrite("^FO 585,600")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DADOS SOBRE A DATA DE ABATE
    MSCBWrite("^FO 560,600")
    MSCBWrite("^FH\^FD" + cPT_Titu01 + "^FS")
    MSCBWrite("^FO 540,600")
    MSCBWrite("^FH\^FD" + cIN_Titu01 + "^FS")    
    MSCBWrite("^FO 560,1020")
    MSCBWrite("^FH\^FD" + dPT_DtaAbt + "^FS")
    MSCBWrite("^FO 540,1020")
    MSCBWrite("^FH\^FD" + dIN_DtaAbt + "^FS")

    //DADOS SOBRE PESO BRUTO
    MSCBWrite("^FO 560,1130")
    MSCBWrite("^FH\^FD" + cPT_Titu07 + "^FS")
    MSCBWrite("^FO 540,1130")
    MSCBWrite("^FH\^FD" + cIN_Titu07 + "^FS")
    MSCBWrite("^FO 560,1430")
    MSCBWrite("^FH\^FD" + cPesoBruKg + " Kg" + "^FS")
    MSCBWrite("^FO 540,1430")
    MSCBWrite("^FH\^FD" + cPesoBruLi + " Lb" + "^FS")

    //LINHA HORIZONTAL 2
    MSCBWrite("^FO 535,600")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DADOS SOBRE A DATA DE PRODUÇÃO/EMBALAGEM/LOTE
    MSCBWrite("^FO 510,600")
    MSCBWrite("^FH\^FD" + cPT_Titu02 + "^FS")
    MSCBWrite("^FO 490,600")
    MSCBWrite("^FH\^FD" + cIN_Titu02 + "^FS")
    MSCBWrite("^FO 510,1020")
    MSCBWrite("^FH\^FD" + dPT_DtaPro + "^FS")
    MSCBWrite("^FO 490,1020")
    MSCBWrite("^FH\^FD" + dIN_DtaPro + "^FS")

    //DADOS SOBRE PESO LÍQUIDO
    MSCBWrite("^FO 510,1130")
    MSCBWrite("^FH\^FD" + cPT_Titu08 + "^FS")
    MSCBWrite("^FO 490,1130")
    MSCBWrite("^FH\^FD" + cIN_Titu08 + "^FS")
    MSCBWrite("^FO 510,1430")
    MSCBWrite("^FH\^FD" + cPesoLiqKg + " kg" + "^FS")
    MSCBWrite("^FO 490,1430")
    MSCBWrite("^FH\^FD" + cPesoLiqLi + " Lb" + "^FS")

    //LINHA HORIZONTAL 3
    MSCBWrite("^FO 485,600")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DADOS SOBRE A DATA DE EMBALAGEM/CONGELAMENTO
    if cMatura == 'S'
        MSCBWrite("^FO 460,600")
        MSCBWrite("^FH\^FD" + cPT_Titu03 + "^FS")
        MSCBWrite("^FO 440,600")
        MSCBWrite("^FH\^FD" + cIN_Titu03 + "^FS")
        MSCBWrite("^FO 460,1020")
        MSCBWrite("^FH\^FD" + dPT_DtaCon + "^FS")
        MSCBWrite("^FO 440,1020")
        MSCBWrite("^FH\^FD" + dIN_DtaCon + "^FS")
    else
        MSCBWrite("^FO 460,600")
        MSCBWrite("^FH\^FD" + cPT_Titu03 + "^FS")
        MSCBWrite("^FO 440,600")
        MSCBWrite("^FH\^FD" + cIN_Titu03 + "^FS")
        MSCBWrite("^FO 460,1020")
        MSCBWrite("^FH\^FD" + dPT_DtaPro + "^FS")
        MSCBWrite("^FO 440,1020")
        MSCBWrite("^FH\^FD" + dIN_DtaPro + "^FS")
    endif

    //DADOS SOBRE A TARA DA EMBALAGEM
    MSCBWrite("^FO 460,1130")
    MSCBWrite("^FH\^FD" + cPT_Titu09 + "^FS")
    MSCBWrite("^FO 440,1130")
    MSCBWrite("^FH\^FD" + cIN_Titu09 + "^FS")
    MSCBWrite("^FO 460,1430")
    MSCBWrite("^FH\^FD" + cTaraEmbKg + " kg" + "^FS")
    MSCBWrite("^FO 440,1430")
    MSCBWrite("^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")

    //LINHA HORIZONTAL 4
    MSCBWrite("^FO 435,600")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DADOS SOBRE A DATA DE VALIDADE
    if cMatura == 'S'
        MSCBWrite("^FO 410,600")
        MSCBWrite("^FH\^FD" + cPT_Titu04 + "^FS")
        MSCBWrite("^FO 390,600")
        MSCBWrite("^FH\^FD" + cIN_Titu04 + "^FS")
        MSCBWrite("^FO 410,1020")
        MSCBWrite("^FH\^FD" + cPT_DtaVal + "^FS")
        MSCBWrite("^FO 390,1020")
        MSCBWrite("^FH\^FD" + cIN_DtaVal + "^FS")
    else
        MSCBWrite("^FO 410,600")
        MSCBWrite("^FH\^FD" + cPT_Titu04 + "^FS")
        MSCBWrite("^FO 390,600")
        MSCBWrite("^FH\^FD" + cIN_Titu04 + "^FS")
        MSCBWrite("^FO 410,1020")
        MSCBWrite("^FH\^FD" + dPT_DtaVal + "^FS")
        MSCBWrite("^FO 390,1020")
        MSCBWrite("^FH\^FD" + dIN_DtaVal + "^FS")
    endif

    //DADOS SOBRE A TARA DA CAIXA
    MSCBWrite("^FO 410,1130")
    MSCBWrite("^FH\^FD" + cPT_Titu10 + "^FS")
    MSCBWrite("^FO 390,1130")
    MSCBWrite("^FH\^FD" + cIN_Titu10 + "^FS")    
    MSCBWrite("^FO 410,1430")
    MSCBWrite("^FH\^FD" + cTaraCxaKg + " kg" + "^FS")
    MSCBWrite("^FO 390,1430")
    MSCBWrite("^FH\^FD" + cTaraCxaLi + " Lb" + "^FS")

    //LINHA HORIZONTAL 5
    MSCBWrite("^FO 385,600")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DADOS SOBRE FORMA DE ARMAZENAMENTO
    MSCBWrite("^FO 360,600")
    If (cCONRES = 'R')
        MSCBWrite("^FH\^FD" + cPT_Tit05 + "^FS")
        MSCBWrite("^FO 340,600")
        MSCBWrite("^FH\^FD" + cIN_Tit05 + "^FS")
    ElseIf (cCONRES = 'C')
        MSCBWrite("^FH\^FD" + cPT_Titu05 + "^FS")
        MSCBWrite("^FO 340,600")
        MSCBWrite("^FH\^FD" + cIN_Titu05 + "^FS")
    ElseIf (cCONRES = 'S')
        MSCBWrite("^FH\^FD" + cPT_Titu5 + "^FS")
        MSCBWrite("^FO 340,600")
        MSCBWrite("^FH\^FD" + cIN_Titu5 + "^FS")
    Else
        MSCBWrite("^FH\^FD" + "Sem dados para exibir:" + "^FS")
        MSCBWrite("^FO 340,600")
        MSCBWrite("^FH\^FD" + "No data to display:" + "^FS")
    EndIf

    If !Empty(SB1->B1_MENETQ2)
        aTemper := STRTOKARR(cTempeCong, ' ')
        MSCBWrite("^FO" + "350,1020")
        IF aTemper[2] = 'CONGELADO'
            MSCBWrite("^FH\^FD" + aTemper[4] +' \A7C' + "^FS")
        ELSEIF aTemper[2] = 'RESFRIADO'
            MSCBWrite("^FH\^FD" + aTemper[4] + " a " + aTemper[6] +' \A7C' + "^FS")
        ENDIF
    Else
        MSCBWrite("^FO" + "350,1020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    EndIf
    //DADOS SOBRE HORA
    MSCBWrite("^FO 360,1130")
    MSCBWrite("^FH\^FD" + cPT_Titu11 + "^FS")
    MSCBWrite("^FO 340,1130")
    MSCBWrite("^FH\^FD" + cIN_Titu11 + "^FS")
    MSCBWrite("^FO" + "350,1430")
    MSCBWrite("^FH\^FD" + Hora + "^FS")

    //LINHA HORIZONTAL 6
    MSCBWrite("^FO 335,600")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DAODS SOBRE RASTREABILIDADE
    MSCBWrite("^FO 310,600")
    MSCBWrite("^FH\^FD" + cPT_Titu06 + "^FS")
    MSCBWrite("^FO 290,600")
    MSCBWrite("^FH\^FD" + cIN_Titu06 + "^FS")
    MSCBWrite("^FO" + "300,820")
    MSCBWrite("^FH\^FD" + cNumRastre + "^FS")

    //DAODS SOBRE QUANTIDADE
    MSCBWrite("^FO 310,1130")
    MSCBWrite("^FH\^FD" + cPT_Titu12 + "^FS")
    MSCBWrite("^FO 290,1130")
    MSCBWrite("^FH\^FD" + cIN_Titu12 + "^FS")
    MSCBWrite("^FO" + "300,1430")
    MSCBWrite("^FH\^FD" + QuantiCxa + "^FS")

    //LINHA HORIZONTAL 7
    MSCBWrite("^FO 285,600")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //LINHA VERTICAL
    MSCBWrite("^FO 285,1125")
    MSCBWrite("^GB 300,1,4 ^FS")

    MSCBWrite("^FO" + "190,600" + "^FH\^FD" + "Antes de consumir, submeter a tratamento t\82rmico." + "^FS")
    MSCBWrite("^FO" + "170,600" + "^FH\^FD" + "Uma vez descongelado, n\C6o voltar a congelar." + "^FS")
    MSCBWrite("^FO" + "150,600" + "^FH\^FD" + "Importado por: Frimarc,SA,Estoi,Faro,Portugal." + "^FS")

    MSCBWrite("^FO 190,1250")
    MSCBWrite("^FH\^FD" + "Origem: Brasil" + "^FS")
    MSCBWrite("^FO 170,1250")
    MSCBWrite("^FH\^FD" + "Abatido em: Brasil 1733" + "^FS")
    MSCBWrite("^FO 150,1250")
    MSCBWrite("^FH\^FD" + "Desmancha em: Brasil 1733" + "^FS")

    //FUNDO PRETO COM COD DO PRODUTO HORIZONTAL
    MSCBWrite("^LRY")
    MSCBWrite("^FO 060,630")
    MSCBWrite("^GB 000,430,080 ^FS")
    MSCBWrite("^FO 060,635")
    MSCBWrite("^CFG ^FD" + Destino + " " + CodPro + " ^FS")

    //CODIGO DE BARRAS HORIZONTAL
    MSCBWrite("^BY3,3,55")
    MSCBWrite("^FT 080,1130")
    MSCBWrite("^BCR,,Y,N")
    MSCBWrite("^FD>; " + NumCxa + " ^FS")

    //REIMPRESSÃO
    if !empty(cReimp)
        MSCBWrite("^CFA,40,30")
        MSCBWrite("^FO 080,1450")
        MSCBWrite("^FH\^FD" + "R" + "^FS")
    endif

    //IMPRIME NÚMERO DA PRE-ETIQUETA
    MSCBWrite("^CFA,20")
    MSCBWrite("^FO 030,650")
    MSCBWrite("^FH\^FD" + "PE: " + cNumPreEtq + " ^FS")

    //IMAGEM LOGO SIF
    MSCBWrite("^FO" + "300,030")
    MSCBWrite("^IME:LOGOSIF.GRF,1,1")

    //FIM DO BLOCO
    MSCBWrite("^PQ 1,0,1,N")
    MSCBWrite("^XZ")
Return

Static Function EtqZPLM()
    Local cPT_Titu01 := "Data de produ\87\C6o/lote:"
    Local cIN_Titu01 := "Production date/batch:"
    Local cES_Titu01 := "Fecha de producci\A2n/lote:"
    Local cPT_Titu02 := "Data de abate:"
    Local cIN_Titu02 := "Slaughter date:"
    Local cES_Titu02 := "Fecha de matanza:"
    //Local cPT_Tit02  := "Data de resfriamento:"
    //Local cIN_Tit02  := "Cooling date:"
    //Local cES_Tit02  := "Fecha de enfriamiento:"
    Local cPT_Titu03 := "Data de validade:"
    Local cIN_Titu03 := "Expiration date:"
    Local cES_Titu03 := "Fecha de expiraci\A2n:"
    Local cPT_Titu04 := "Data embalagem/congelamento:"
    Local cIN_Titu04 := "Packing/freezing date:"
    Local cES_Titu04 := "Fecha de embalaje/congelaci\A2n:"
    //Local cPT_Tit04  := "Data embalagem/resfriamento:"
    //Local cIN_Tit04  := "Packing date/cooling:"
    //Local cES_Tit04  := "Fecha de embalaje/refrigeracion:"
    Local cPT_Titu05 := "Manter congelado a:"
    Local cIN_Titu05 := "Keep frozen at:"
    Local cES_Titu05 := "Mantener congelado en:"
    Local cPT_Tit05  := "Manter resfriado a:"
    Local cIN_Tit05  := "Keep cool at:"
    Local cES_Tit05  := "Mantener frio en:"
    Local cPT_Titu5  := "Mantenha em lugar seco e arejado at\82 35 \A7C"
    Local cIN_Titu5  := "Keep in a dry and ventilated place up to 35 \A7C"
    Local cES_Titu5  := "Conservar en lugar seco y ventilado hasta 35 \A7C"
    Local cPT_Titu06 := "Rastreabilidade:"
    Local cIN_Titu06 := "Traceability:"
    Local cES_Titu06 := "Trazabilidad:"
    Local cPT_Titu07 := "Peso bruto:"
    Local cIN_Titu07 := "Gross weight:"
    Local cES_Titu07 := "Peso bruto:"
    Local cPT_Titu08 := "Peso liquido:"
    Local cIN_Titu08 := "Net weight:"
    Local cES_Titu08 := "Peso neto:"
    Local cPT_Titu09 := "Tara prim\A0ria:"
    Local cIN_Titu09 := "Primary packing tare:"
    Local cES_Titu09 := "Tara embalaje primario:"
    Local cPT_Titu10 := "Tara da caixa:"
    Local cIN_Titu10 := "Carton tare:"
    Local cES_Titu10 := "Tara de caja:"
    Local cPT_Titu11 := "Quantidade:"
    Local cIN_Titu11 := "Quantity:"
    Local cES_Titu11 := "Cantidad:"
    Local cPT_Titu12 := "Hora:"
    Local cIN_Titu12 := "Hour:"
    Local cES_Titu12 := "Hora:"

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
    MSCBWrite("^FO" + "090,010" + "^FH\^FD" + "RODOVIA BR 392 Km 8 - BAIRRO TOMAZETTI ^FS")
    MSCBWrite("^FO" + "070,010" + "^FH\^FD" + "SANTA MARIA-RS - BRASIL CEP 97065-400 ^FS")
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
        MSCBWrite("^FO" + "630,600" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    EndIf

    //LINHA HORIZONTAL 1
    MSCBWrite("^FO 585,620")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DADOS SOBRE A DATA DE ABATE
    MSCBWrite("^FO 560,620")
    MSCBWrite("^FH\^FD " + cPT_Titu02 + "^FS")
    MSCBWrite("^FO 540,620")
    MSCBWrite("^FH\^FD " + cIN_Titu02 + "^FS")
    MSCBWrite("^FO 520,620")
    MSCBWrite("^FH\^FD " + cES_Titu02 + "^FS")
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

    //DADOS SOBRE A DATA DE PRODUÇÃO
    MSCBWrite("^FO 485,620")
    MSCBWrite("^FH\^FD " + cPT_Titu01 + "^FS")
    MSCBWrite("^FO 465,620")
    MSCBWrite("^FH\^FD " + cIN_Titu01 + "^FS")
    MSCBWrite("^FO 445,620")
    MSCBWrite("^FH\^FD " + cES_Titu01 + "^FS")

    MSCBWrite("^FO 485,1040")
    MSCBWrite("^FH\^FD " + dPT_DtaPro + "^FS")
    MSCBWrite("^FO 465,1040")
    MSCBWrite("^FH\^FD " + dIN_DtaPro + "^FS")
    MSCBWrite("^FO 445,1040")
    MSCBWrite("^FH\^FD " + dPT_DtaPro + "^FS")

    //DADOS SOBRE PESO LÍQUIDO
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
    MSCBWrite("^FH\^FD " + dPT_DtaVal + "^FS")

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

    //DADOS SOBRE A DATA DA EMBALAGEM
    MSCBWrite("^FO 340,620")
    MSCBWrite("^FH\^FD " + cPT_Titu04 + "^FS")
    MSCBWrite("^FO 320,620")
    MSCBWrite("^FH\^FD " + cIN_Titu04 + "^FS")
    MSCBWrite("^FO 300,620")
    MSCBWrite("^FH\^FD " + cES_Titu04 + "^FS")
    MSCBWrite("^FO 340,1040")
    MSCBWrite("^FH\^FD " + dPT_DtaPro + "^FS")
    MSCBWrite("^FO 320,1040")
    MSCBWrite("^FH\^FD " + dIN_DtaPro + "^FS")
    MSCBWrite("^FO 300,1040")
    MSCBWrite("^FH\^FD " + dPT_DtaPro + "^FS")

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
    MSCBWrite("^FO 265,620")
    If (cCONRES = 'R')
        MSCBWrite("^FH\^FD " + cPT_Tit05 + "^FS")
        MSCBWrite("^FO 245,620")
        MSCBWrite("^FH\^FD " + cIN_Tit05 + "^FS")
        MSCBWrite("^FO 225,620")
        MSCBWrite("^FH\^FD " + cES_Tit05 + "^FS")
    ElseIf (cCONRES = 'C')
        MSCBWrite("^FH\^FD " + cPT_Titu05 + "^FS")
        MSCBWrite("^FO 245,620")
        MSCBWrite("^FH\^FD " + cIN_Titu05 + "^FS")
        MSCBWrite("^FO 225,620")
        MSCBWrite("^FH\^FD " + cES_Titu05 + "^FS") 
    ElseIf (cCONRES = 'S')
        MSCBWrite("^FH\^FD " + cPT_Titu5 + "^FS")
        MSCBWrite("^FO 245,620")
        MSCBWrite("^FH\^FD " + cIN_Titu5 + "^FS")
        MSCBWrite("^FO 225,620")
        MSCBWrite("^FH\^FD " + cES_Titu5 + "^FS") 
    Else
        MSCBWrite("^FH\^FD " + "Sem dados para exibir:" + "^FS")
        MSCBWrite("^FO 225,620")
        MSCBWrite("^FH\^FD " + "No data to display:" + "^FS")
    EndIf

    If !Empty(SB1->B1_MENETQ2)
        aTemper := STRTOKARR(cTempeCong, ' ')
        MSCBWrite("^FO" + "245,1040")
        IF aTemper[2] = 'CONGELADO'
            MSCBWrite("^FH\^FD" + aTemper[4] +' \A7C' + "^FS")
        ELSEIF aTemper[2] = 'RESFRIADO'
            MSCBWrite("^FH\^FD" + aTemper[4] + " a " + aTemper[6] +' \A7C' + "^FS")
        ENDIF
    Else
        MSCBWrite("^FO" + "245,1040" + "^FH\^FD " + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    EndIf
    //DADOS SOBRE QUANTIDADE
    MSCBWrite("^FO 265,1150")
    MSCBWrite("^FH\^FD " + cPT_Titu11 + "^FS")
    MSCBWrite("^FO 245,1150")
    MSCBWrite("^FH\^FD " + cIN_Titu11 + "^FS")
    MSCBWrite("^FO 225,1150")
    MSCBWrite("^FH\^FD " + cES_Titu11 + "^FS")
    MSCBWrite("^FO" + "245,1430")
    MSCBWrite("^FH\^FD " + QuantiCxa + "^FS")

    //LINHA HORIZONTAL 6
    MSCBWrite("^FO 220,620")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //DAODS SOBRE RASTREABILIDADE
    MSCBWrite("^FO 190,620")
    MSCBWrite("^FH\^FD " + cPT_Titu06 + "^FS")
    MSCBWrite("^FO 170,620")
    MSCBWrite("^FH\^FD " + cIN_Titu06 + "^FS")
    MSCBWrite("^FO 150,620")
    MSCBWrite("^FH\^FD " + cES_Titu06 + "^FS")
    MSCBWrite("^FO" + "165,820")
    MSCBWrite("^FH\^FD " + cNumRastre + "^FS")

    //DADOS SOBRE HORA
    MSCBWrite("^FO 190,1150")
    MSCBWrite("^FH\^FD " + cPT_Titu12 + "^FS")
    MSCBWrite("^FO 170,1150")
    MSCBWrite("^FH\^FD " + cIN_Titu12 + "^FS")
    MSCBWrite("^FO 150,1150")
    MSCBWrite("^FH\^FD " + cES_Titu12 + "^FS")
    MSCBWrite("^FO" + "165,1430")
    MSCBWrite("^FH\^FD" + Hora + "^FS")

    //LINHA HORIZONTAL 7
    MSCBWrite("^FO 145,620")
    MSCBWrite("^GB1, 1000,005 ^FS")

    //LINHA VERTICAL
    MSCBWrite("^FO 145,1150")
    MSCBWrite("^GB 442,1,4 ^FS")

    //FUNDO PRETO COM COD DO PRODUTO HORIZONTAL
    MSCBWrite("^LRY")
    MSCBWrite("^FO 060,630")
    MSCBWrite("^GB 000,430,080 ^FS")
    MSCBWrite("^FO 060,635")
    MSCBWrite("^CFG ^FD" + Destino + " " + CodPro + " ^FS")

    //CODIGO DE BARRAS HORIZONTAL    
    MSCBWrite("^BY3,3,55")
    MSCBWrite("^FT 080,1150")
    MSCBWrite("^BCR,,Y,N")
    MSCBWrite("^FD>; " + NumCxa + " ^FS")

    //REIMPRESSÃO
    if !empty(cReimp)
        MSCBWrite("^CFA,40,30")
        MSCBWrite("^FO 080,1450")
        MSCBWrite("^FH\^FD" + "R" + "^FS")
    endif

    //IMPRIME NÚMERO DA PRE-ETIQUETA
    MSCBWrite("^CFA,20")
    MSCBWrite("^FO 030,650")
    MSCBWrite("^FH\^FD" + "PE: " + cNumPreEtq + " ^FS")

    //IMAGEM LOGO IMPORTADOR
    IF (!Empty(ZZ7->ZZ7_IMPOR))
        IF ('SICARNES' $ ZZ7->ZZ7_IMPOR)
            MSCBWrite("^FO" + "650,1350")
            MSCBWrite(ImpLogoImg())
        ENDIF
    ENDIF

    //IMAGEM LOGO SIF
    MSCBWrite("^FO" + "300,030")
    MSCBWrite("^IME:LOGOSIF.GRF,1,1")

    //FIM DO BLOCO
    MSCBWrite("^PQ 1,0,1,N")
    MSCBWrite("^XZ")
Return

Static Function Imprime()

    Local _cPais := GetAdvFVal('ZZ7','ZZ7_PAIS',FWXFilial('ZZ7')+alltrim(CodPro),1)

    MSCBPRINTER(Modelo,Portap,,,,,IPprint)

    MSCBCHKSTATUS(.F.)
    MSCBBEGIN(1,6,15)

    if _cPais $ "607"
        EtqZPLP()
    elseif _cPais $ "589/493"
        EtqZPLM()
    endif

    MSCBEND()
	MSCBCLOSEPRINTER()
RETURN

Static Function ImpLogoImg()

    Local cImgStr := ""

    cImgStr += "^GFA,4400,4400,20,,,,X02,V03JF,U07LF8,T07NF,S01OFE,S0KF8I03FC,R03JFL01F,R0JFN01C,Q01IFE007FFEI0E,Q07IF01LF8018,Q0IFC0NF806,"
    cImgStr += "P03FFE0PF018,P07FF83PFC04,O01IF0RF81,O03FFC3RFE,O07FF8KF8001KF,O0IF1JF8K0JFC,N01FFC7IF8M0JF,N03FF8IFCN01IF8,N07FE3FFEP07FFE,N0FFC7FF8P0"
    cImgStr += "1IF,M01FF9FFER07FF8,M03FF9FFCR01FFC,M03FE7FFT0FFE,M07FCFFCT03FF8,M0FF9FF8U0FFC,L01FF3FFV07FE,L03FE7FCR0EI03FF,L03FCFF8Q033J0FF8,L07FDFF"
    cImgStr += "S03J0FF8,L0FFBFES06J03FC,K01JFCQ018DJ03FE,K01FF7F8Q03C1K0FF,K03FEFFR0301K07F8,K03FDFER06018J03FC,K07FBFCR0601801F01FE,K0FFA2S0600C03C01"
    cImgStr += "FE,K0FF79CR0700E07800FF,J01FEECS03007FDF807F,J01FEF3DR05I0F9F803F8,J03FDFA3R08J033801FC,J07IF33R08J043I0FE,J07FBECCQ018J0DBI0FE,J07F7F3"
    cImgStr += "R01I060BBI07F,J0FF7EF8Q03I0F0FBI07F,J0FEFES03I09872I03F8,I01IFC18Q03I010F2I01F8,I01FDF93004O03K0C6I01FC,I03IF8S07K0848I0FE,I03FBFJ01I0F"
    cImgStr += "01I07L0C8I07E,I03IFJ01I0F008007L08400C7E,I07F7E0EI0800F07E0078L040163F,I07FFE1CI0400F1FF0068L060323F8,I07EFC0B800400F1FF8068J0F030731F8"
    cImgStr += ",I0IFC08I0200F3FFA06J03FC30731FC,I0FDF807I0200F3EF8024I07FE00DB0FC,I0FDF013I0100F3C7902J07FF00CF0FE,001IF009800100F3C7902J07FD80CF07E,0"
    cImgStr += "01FBF01AI0180F3C7881J0DFCC0BF07E,003FFE01E8I080FFC7881J0DFC79BE03F,003F7E001J0C07FC784080019FC38FF03F,003FFC01EJ0C03FC784080039FC007F83"
    cImgStr += "F,007FFC01C8I0400F8786040079FCJ0E1F8,007EFC003J06J0782J0E33CJ071F8,007FF800FJ06J0783001FC31CJ038F8,007FF8001EI060E0038307FF82L018FC,00F"
    cImgStr += "DF800E380030FEI030FFE06M0C7C,00FDF001CJ030FFC00187F804M047C,00IFI0B8I030IFC0187L07J067E,00IF001EJ0303FFE008J04003CI063E,00FBEI028I03003"
    cImgStr += "FE0081C004I06I063F,01FFE001FJ01I03E00C07E0CM063F,01FFEI098I0187E0E00C0070CL01E3F,01FFCI0EJ018FFCI0C00184M0E1F,01F7C0018J019IFI0CI066M06"
    cImgStr += "1F8,01FFCI01J019IFC00CI031J040061F8,01FF8I0EJ019IFC00CI0186I070041F8,03FF8I09J019E07E00C03806J070040F8,03FF8001E2I019E01E00C007018I0300"
    cImgStr += "C0F8,03EF8I09J019E01E00C031C0EL0C0FC,03FF8001F8I019E01E00C01C701EJ0180FC,03FFO019E01E00C0011EI0180300FC,03DFO018E01E00CI0638I0FC6007C,0"
    cImgStr += "3DFO018001E00CI01F7FF8FFC007C,07FFJ0EJ018001E00CJ03F3F0FF8007D,07FFJ08EI018E01E00CK04009FF8007E,07FFK03I018E00E00CN09FE8007E,07FEI011J01"
    cImgStr += "8F8J0CN05DD8007E,07FEJ0D8I018FEJ0CN041F8003E,07FEJ08J0187F8001C007FFE00E1FI03E,07BEO0181FE001C01C001FD9FFI03E8007BEO0181FF801C02J07F083I"
    cImgStr += "03E8007BEI01CJ0381DFC038M0E302I03E8007FEJ07J0381CFC038J0200C302I03E8007FEJ09J0381C3E038J01I0706I03F8007FEJ078I038IFE038001E1I060EI03F800"
    cImgStr += "7FEI01DJ030IFE03800381I067EI03F8007FEJ0B8I030IFE03800201C00CFCI03F8007FCJ0EJ030IFE03K01FE0F98I03FC007FCI07CJ07L07L07F3F1J03FC007FCI04E8I"
    cImgStr += "07L07K01JF1J03F4007FCI038J070EJ07001007F8FF2J03F4007FCJ0B8I070FEI0700201F00F86J03F4007FCJ0E6I070FFE00700603300F86J03F4007FCJ078I070IFE0E"
    cImgStr += "00C02200E07J03F4007FCJ04J0E01FFE0E00C063J078I03F4007FCJ018I0E00FFE0E0040E78I03CI03FC007FCJ098I0E00E7E0CJ0CK01CI03FC007FCJ09J0E00E0E0CI01"
    cImgStr += "98K0CI03FC007FCO0E07E0E0CI01988J0CI03FC007FEO0C0FE0E0C004I18J0CI03FC007FEO0C0FF8E0C00C133K0CI03FC007FEI019I01C0F7FE1C00C13FJ018I03FC007F"
    cImgStr += "EJ0E8001C087FE1C00C1BFK08I03FC007FEJ01I018003FC1C0061B38J0CI03FC003FEI01EI018I0FC180021E18I018I03EC003BEJ09800180EI018J0F1J018I03EC003BEI"
    cImgStr += "017I0380FE001801E07F8I038I03EC003BEJ04I0380FFC01801IFEJ03J03EC003BEI011E00300IFC18J0FE00C06J03EC003BEJ0C5003001FFE18J01F00E06J03EC003BFI0"
    cImgStr += "171003I07FE18J01FF0E12J07FC003FFK06003J07E18J01JFE2J07FC001FFI013I07I01FE18J0307C3E1J07FC001FFJ018007003FFE18J0300E3E1J07DC001DFJ01E00600"
    cImgStr += "IFC18I0360073318I07DC001DFJ0E500600IF018I07E00331F8I07D8001DFJ09I0600FC0018I0FC0033078I0FF8001DF8I0D800600FF8018I0CI01B81CI0FF8000EF8I08I"
    cImgStr += "0600IF018I0CI01981CI0FF8000EF8001EI06007FFE18I0CI01881CI0FB8000EF8I09800EI07FE1807FCK0C04I0FB8000FFC001F800CJ07E180FF8J07404001FB80007FCJ"
    cImgStr += "0E00CK0E180CK01FE04001FF800077CJ0100CJ020080DF8J07F8C001F7,0077EM0C007C30080DL037FC001F7,0077EI0CI0C00FFD8080DL01BF8003F7,0037E001DI0C01I"
    cImgStr += "FC080DJ0780FJ03FF,003BEI0F800C01IFC0C0DJ0FF05J03EF,003BF001CI0C01IFE041FI01FF05J07EF,003BFI03800C01E3FE047AI036F07J07EE,001DF001FI0C01E39"
    cImgStr += "E04F6I03DC078I07DE,001DF8003800C01E39E00C4I07F8878I07DE,I0DF8L0C01E39E02D8I07F0078I0FFE,I0CF8L0C01E39E01EJ03E74FC001FBC,I0EFCL0400E39E016"
    cImgStr += "J07E74FC001FBC,I0EFC019I0400201E00FI01FE68F8001FFC,I06FE01E8004J01E007I01FE08FI03F7C,I077E001I0400C01E003I01F811EI03F7C,I037E013I0600E022"
    cImgStr += "001I01F82FFI07FF8,I033F009800200E01J08001F85FFI07EF8,I03BF017800200E3F8I03F01FE3FEI07EF8,I019F8K0200E3FCM07E7FCI0FDF,I01DF811I0300E7FEM07"
    cImgStr += "8FFCI0FDF,I01CFC0D800100E7BEO0FFI01IF,J0EFE09E00100E79EN0C7CI01FBE,J0EFE0E5I080F79EN08EJ03FBE,J0E7E01J080FF9EN08K03F7C,J077F1F8I040FF9EN0B"
    cImgStr += "K07E7C,J073F88J0207F9EN08K0FEFC,J03BF8K0201F1ET0FDF8,J019FCK01I01EI016B8L01FDF8,J01CFCCK08001EI01604L01FBF8,K0CFF8gI03FBF,K0E7EE8J02W07F7F"
    cImgStr += ",K067EgJ07F7E,K073F3gI0FEFE,K031EF8gG01FEFC,K039FgI01FDFC,K01CE18gG03F9FC,K01E734gG07F3F8,L0E604gG0FF7F8,L073FCg01FEFF,L0708Fg03FCFE,L038E"
    cImgStr += "4g07F9FE,L01DC1g0FFBFC,M0EB38X01FF7F8,M0E07CX03FE7F8,M071FEX07FCFF,M079FFX0FF9FF,M038FF8V01FF3FE,M01C7FEV03FE7FC,N0E3FFV07FCFFC,N071FFCT01"
    cImgStr += "FF9FF8,N0787FET07FF3FF,N03C7FFT0FFE3FE,N01E1FFCR01FFCFFE,O0F0IFR07FF8FFC,O0787FFCP01FFE3FF8,O03E1IFP0IFC7FF,O01F0IFEN03IF8FFE,P0F83IFCL03I"
    cImgStr += "FE3FFC,P07C1JF8K0JFC7FF8,P03F07JFE003KF0IF,P01F81RFC3FFE,Q0FE07PFE0IFC,Q07F01PF81IF8,Q01FE03NFE07IF,R0FF807LFE03IFC,R07FC00LF807IF8,R01FF8"
    cImgStr += "007FFE003JF,S0IFM01JFC,S03IFK01KF8,T0JFE00LFE,T03RF8,U0QFE,U03PF8,V07NFC,W0MFE,W01LF,Y01FF,,,,,,,""

Return cImgStr
