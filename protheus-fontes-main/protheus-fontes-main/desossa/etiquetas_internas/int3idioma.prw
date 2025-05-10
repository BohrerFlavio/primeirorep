#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  INTBRA   º Autor ³ Lucas Bolzan         º Data ³  19/10/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Layout de etiquetas internas impressas na produção         º±±
±±º          ³ Etiquetas c/layout para Brasil                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Produção                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION INT3IDIOMA(_cCodPro,_cDtaAbt,_cDtaPro,_cDtaVal,_cQtdEtq,_cMesa, _cLoteEUA)
    //DECLARAÇÃO DE VARIAVEIS
    PRIVATE cDtaAbt     := ALLTRIM(DToC(_cDtaAbt)) //Data de abate
    PRIVATE cDtaAbtING  := SubSTR(DToC(_cDtaAbt),4,3)+SubSTR(DToC(_cDtaAbt),1,3)+SubSTR(DToC(_cDtaAbt),7,2) //Data de produção em formato MMDDAA
    PRIVATE cDtaPro     := ALLTRIM(DToC(_cDtaPro)) //Data de produção
    PRIVATE cDtaProING  := SubSTR(DToC(_cDtaPro),4,3)+SubSTR(DToC(_cDtaPro),1,3)+SubSTR(DToC(_cDtaPro),7,2) //Data de produção em formato MMDDAA
    PRIVATE cDtaMat     := ALLTRIM(DToC(CToD(cDtaPro)+2))
    PRIVATE cDtaMatING  := SubSTR(cDtaMat,4,3)+SubSTR(cDtaMat,1,3)+SubSTR(cDtaMat,7,2) 
    PRIVATE cDtaCon     := ALLTRIM(DToC(CToD(cDtaPro)+16))
    PRIVATE cDtaConING  := SubSTR(cDtaCon,4,3)+SubSTR(cDtaCon,1,3)+SubSTR(cDtaCon,7,2) 
    PRIVATE cDtaVal     := ALLTRIM(DToC(_cDtaVal)) //Data de validade    
    PRIVATE cDtaValING  := SubSTR(DToC(_cDtaVal),4,3)+SubSTR(DToC(_cDtaVal),1,3)+SubSTR(DToC(_cDtaVal),7,2) //Data de produção em formato MMDDAA
    PRIVATE cDtaVld     := ALLTRIM(DToC(CToD(cDtaVal)+16))
    PRIVATE cDtaVldING  := SubSTR(cDtaVld,4,3)+SubSTR(cDtaVld,1,3)+SubSTR(cDtaVld,7,2) 
    PRIVATE cQtdEtq     := ALLTRIM(STR(_cQtdEtq))
    PRIVATE nPesEmb     := 0.000
    //ABRE COMUNICAÇÃO COM A TABELA SB1
    SB1->(DBSetOrder(1))
    SB1->(MSSeek(FWXFilial('SB1')+ALLTRIM(_cCodPro)))
    PRIVATE taraSB1     := SB1->B1_CTARAP // Linhas inseridas para buscar"_NTARAp"
	PRIVATE taraZAB     := GetAdvFVal('ZAB','ZAB_TARA',FWXFilial('ZAB')+alltrim(taraSB1),1) // os campos de codigo das taras primarias
	PRIVATE cPesEmb     := ALLTRIM(STR((taraZAB * 1000)))
    PRIVATE cTaraEmbLi  := STRTran(Transform((Val(cPesEmb) * 0.00220462),'@E 99.99'),',','.')
    PRIVATE cCodGrp     := SB1->B1_GRUPO
    PRIVATE cCodPrg     := alltrim(SB1->B1_PROGRAM)
    PRIVATE cMsgTemp    := Alltrim(SB1->B1_MENETQ2)
    PRIVATE cNumRastre  := '1733' + STRTran(cDtaAbt, "/", "",)// + 'ØØØØ' // ALT+0216 = Ø
    //ABRE COMUNICAÇÃO COM A TABELA ZZ7
    ZZ7->(DBSetOrder(1))
    ZZ7->(MSSeek(FWXFilial('ZZ7')+ALLTRIM(_cCodPro)))
    PRIVATE cCodPro     := ALLTRIM(_cCodPro) //Nº do código do produto    
    PRIVATE cDescSIFPT  := ALLTRIM(ZZ7->ZZ7_DESC) //Descrição SIF do produto em português
    PRIVATE cDescSIFIN  := ALLTRIM(ZZ7->ZZ7_DESCI) //Descrição SIF do produto em ingles
    PRIVATE cDescSIFES  := ALLTRIM(ZZ7->ZZ7_DESCE) //Descrição SIF do produto em espanhol
    PRIVATE cDescCorPT  := ALLTRIM(ZZ7->ZZ7_CORTE) //Descrição do produto em português
    PRIVATE cDescCorIN  := ALLTRIM(ZZ7->ZZ7_CORTEI) //Descrição do produto em ingles
    PRIVATE cDescCorES  := ALLTRIM(ZZ7->ZZ7_CORTEE) //Descrição do produto em espanho
    PRIVATE cObser3     := ALLTRIM(ZZ7->ZZ7_INGRE2)
    PRIVATE cMatura     := ZZ7->ZZ7_MATURA

    Imprime()    
RETURN

STATIC FUNCTION EtqZPL_PORTUGA()        
    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWR")
    //IMPRIMI DESCRIÇÃO DO SIF
    IF(!Empty(cDescSIFPT))
        IF cCodPrg $ "006/002"
            MSCBWrite("^CFA,20^FO" + "640,200" + "^FH\^FD" + cDescSIFPT + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "640,020" + "^FH\^FD" + cDescSIFPT + "^FS")
        ENDIF
    ELSE
        IF cCodPrg $ "006/002"
            MSCBWrite("^CFA,20^FO" + "640,200" + "^FH\^FD" + cDescSIFI + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "640,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
        ENDIF
    ENDIF

    IF (!Empty(cDescSIFES))
        IF cCodPrg $ "006/002"
            MSCBWrite("^CFA,20^FO" + "620,200" + "^FH\^FD" + cDescSIFES + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "620,020" + "^FH\^FD" + cDescSIFES + "^FS")
        ENDIF
    ELSE
        IF cCodPrg $ "006/002"
            MSCBWrite("^CFA,20^FO" + "620,200" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "620,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
        ENDIF
    ENDIF

    IF (!Empty(cDescSIFIN))
        IF cCodPrg $ "006/002"
            MSCBWrite("^CFA,20^FO" + "600,200" + "^FH\^FD" + cDescSIFIN + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "600,020" + "^FH\^FD" + cDescSIFIN + "^FS")
        ENDIF
    ELSE
        IF cCodPrg $ "006/002"
            MSCBWrite("^CFA,20^FO" + "600,200" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "600,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
        ENDIF
    ENDIF
    //IMPRIMI O NOME DO CORTE
    IF (!Empty(cDescCorPT))
        IF cCodPrg $ "006/002"
            MSCBWrite("^CFA,20^FO" + "580,200" + "^FH\^FD" + cDescCorPT + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "580,020" + "^FH\^FD" + cDescCorPT + "^FS")
        ENDIF
    ELSE
        MSCBWrite("^CFA,20^FO" + "580,200" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")            
    ENDIF

    IF (!Empty(cDescCorES))
        IF cCodPrg $ "006/002"
            MSCBWrite("^CFA,20^FO" + "560,200" + "^FH\^FD" + cDescCorES + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "560,020" + "^FH\^FD" + cDescCorES + "^FS")
        ENDIF
    ELSE
        IF cCodPrg $ "006/002"
            MSCBWrite("^CFA,20^FO" + "540,200" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS") 
        ELSE
            MSCBWrite("^CFA,20^FO" + "540,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
        ENDIF
    ENDIF

    IF (!Empty(cDescCorIN))
        IF cCodPrg $ "006/002"
            MSCBWrite("^CFA,20^FO" + "540,200" + "^FH\^FD" + cDescCorIN + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "540,020" + "^FH\^FD" + cDescCorIN + "^FS")
        ENDIF
    ELSE
        IF cCodPrg $ "006/002"
            MSCBWrite("^CFA,20^FO" + "540,200" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "540,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
        ENDIF
    ENDIF

    MSCBWrite("^FO" + "500,200" + "^FH\^FD Rastreabilidade:" + cNumRastre + "\9D\9D\9D\9D" + " ^FS")//Alt+0216 = Ø

    //IMPRIMI FORMA DE RESFRIAMENTO/CONGELAMENTO
    IF !Empty(cMsgTemp)
        aTemper := STRTOKARR(cMsgTemp, ' ')
        IF('RESFRIADO' $ cMsgTemp)
            MSCBWrite("^FO" + "470,020")
            MSCBWrite("^FH\^FD Manter resfriado a/Conservar a/Keep cool at " + aTemper[4] + ' \A7C' + "^FS")
        ELSEIF ('CONGELADO' $ cMsgTemp)
            MSCBWrite("^FO" + "470,020")
            MSCBWrite("^FH\^FD Manter congelado a/Conservar a/Keep frozen at " + aTemper[4] + ' \A7C' + "^FS")
        ENDIF
    ELSE
        MSCBWrite("^FO" + "490,020" + "^FH\^FD " + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    ENDIF
    //IMPRIMI DATAS    
    IF (!cCodGrp $ GetMV('MV_GRPCHRQ')) .AND. (!cCodGrp $ GetMV('MV_GRPMDS')) .AND. (!cCodGrp $ GetMV('MV_GRPPORC')) .AND. cMatura == 'S'
        //Alert("Pertence ao grupo da desossa e maturado")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Data de abate:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Slaugther date:' + " ^FS")
        MSCBWrite("^FO" + "440,400" + "^FH\^FD" + cDtaAbt + " ^FS")
        MSCBWrite("^FO" + "420,400" + "^FH\^FD" + cDtaAbtING + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data de produ\87\C6o/Lote:' + "^FS")
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Production date/Batch:' + "^FS")
        MSCBWrite("^FO" + "400,400" + "^FH\^FD" + cDtaPro + " ^FS")
        MSCBWrite("^FO" + "380,400" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Data da matura\87\C6o:' + "^FS")
        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Maturaty date:' + "^FS")
        MSCBWrite("^FO" + "360,400" + "^FH\^FD" + cDtaMat + " ^FS")
        MSCBWrite("^FO" + "340,400" + "^FH\^FD" + cDtaMatING + " ^FS")

        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Data de congela\87\C6o:' + "^FS")
        MSCBWrite("^FO" + "320,400" + "^FH\^FD" + cDtaCon + " ^FS")
        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Freezing date:' + "^FS")
        MSCBWrite("^FO" + "300,400" + "^FH\^FD" + cDtaConING + "^FS")

        //MSCBWrite("^FO" + "280,020" + "^FH\^FD" + 'Data de validade:' + "^FS")
        MSCBWrite("^FO" + "280,020" + "^FH\^FD" + 'Consumir de prefer\88ncia antes de:' + "^FS")
        MSCBWrite("^FO" + "260,020" + "^FH\^FD" + 'Expiration date:' + "^FS") 
        MSCBWrite("^FO" + "280,400" + "^FH\^FD" + cDtaVld + "^FS")
        //MSCBWrite("^FO" + "260,400" + "^FH\^FD" + cDtaVld + "^FS")
        MSCBWrite("^FO" + "260,400" + "^FH\^FD" + cDtaVldING + "^FS")

        MSCBWrite("^FO" + "240,020" + "^FH\^FD" + 'Tara da embalagem:' + "^FS")
        MSCBWrite("^FO" + "220,020" + "^FH\^FD" + 'Packing tare:' + "^FS")
        MSCBWrite("^FO" + "240,400" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "220,400" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")
    ELSEIF (!cCodGrp $ GetMV('MV_GRPCHRQ')) .AND. (!cCodGrp $ GetMV('MV_GRPMDS')) .AND. (!cCodGrp $ GetMV('MV_GRPPORC')) .AND. cMatura == 'N'
        //Alert("Pertence ao grupo da desossa e não maturado")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Data de abate:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Slaugther date:' + " ^FS")
        MSCBWrite("^FO" + "440,400" + "^FH\^FD" + cDtaAbt + " ^FS")
        MSCBWrite("^FO" + "420,400" + "^FH\^FD" + cDtaAbtING + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data de produ\87\C6o/Lote:' + "^FS")
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Production date/Batch:' + "^FS")
        MSCBWrite("^FO" + "400,400" + "^FH\^FD" + cDtaPro + " ^FS")
        MSCBWrite("^FO" + "380,400" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Data de congela\87\C6o:' + "^FS")
        MSCBWrite("^FO" + "360,400" + "^FH\^FD" + cDtaPro + " ^FS")
        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Freezing date:' + "^FS")
        MSCBWrite("^FO" + "340,400" + "^FH\^FD" + cDtaProING + "^FS")

        //MSCBWrite("^FO" + "280,020" + "^FH\^FD" + 'Data de validade:' + "^FS")
        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Consumir de prefer\88ncia antes de:' + "^FS")
        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Expiration date:' + "^FS") 
        MSCBWrite("^FO" + "320,400" + "^FH\^FD" + cDtaVal + "^FS")
        //MSCBWrite("^FO" + "260,400" + "^FH\^FD" + cDtaVld + "^FS")
        MSCBWrite("^FO" + "300,400" + "^FH\^FD" + cDtaValING + "^FS")

        MSCBWrite("^FO" + "280,020" + "^FH\^FD" + 'Tara da embalagem:' + "^FS")
        MSCBWrite("^FO" + "260,020" + "^FH\^FD" + 'Packing tare:' + "^FS")
        MSCBWrite("^FO" + "280,400" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "260,400" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")
    //SE PRODUTOS FOREM DO GRUPO DE PRODUTOS DO CHARQUE
    ELSEIF(cCodGrp $ GetMV('MV_GRPCHRQ'))
        //Alert("Pertence ao grupo do charque")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "460,020" + "^FH\^FD" + 'Data de abate/Produ\87\C6o/Lote:' + " ^FS")
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Datos de abando/Producci\A2n/Lote:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Date of slaughter/Production/Batch:' + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data da embalagem:' + "^FS")        
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Datos del embalaje:' + "^FS")
        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Packaging data:' + "^FS")

        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Data da validade:' + "^FS")        
        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Datos de validaci\A2n:' + "^FS")
        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Validation data:' + "^FS")

        MSCBWrite("^FO" + "280,020" + "^FH\^FD" + 'Tara da embalagem:' + "^FS")        
        MSCBWrite("^FO" + "260,020" + "^FH\^FD" + 'Tara del embalaje:' + "^FS")
        MSCBWrite("^FO" + "240,020" + "^FH\^FD" + 'Packaging tare:' + "^FS")  

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "450,400" + "^FH\^FD" + cDtaAbt + " ^FS")
        MSCBWrite("^FO" + "420,400" + "^FH\^FD" + cDtaAbtING + " ^FS")        

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "390,400" + "^FH\^FD" + cDtaPro + " ^FS")
        MSCBWrite("^FO" + "360,400" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "330,400" + "^FH\^FD" + cDtaVal + "^FS")
        MSCBWrite("^FO" + "300,400" + "^FH\^FD" + cDtaValING + "^FS")        

        MSCBWrite("^FO" + "270,400" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "240,400" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")   
    //SE PRODUTOS FOREM DO GRUPO DE PRODUTOS DO MIUDOS
    ELSEIF(cCodGrp $ GetMV('MV_GRPMDS'))
        //Alert("Pertence ao grupo do miúdos")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "460,020" + "^FH\^FD" + 'Data de abate/Produ\87\C6o/Lote:' + " ^FS")
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Fecha de matanza/Producci\A2n/Lote:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Date of slaughter/Production/Batch:' + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data da embalagem/Fecha de embalaje:' + "^FS")                
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Packing date:' + "^FS")

        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Data da validade/Fecha de validad:' + "^FS")        
        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Expiration date:' + "^FS")

        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Tara da embalagem/Tara de embalaje:' + "^FS")       
        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Packing tare:' + "^FS")  

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "450,400" + "^FH\^FD" + cDtaAbt + " ^FS")
        MSCBWrite("^FO" + "420,400" + "^FH\^FD" + cDtaAbtING + " ^FS")        

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "400,400" + "^FH\^FD" + cDtaPro + " ^FS")
        MSCBWrite("^FO" + "380,400" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "360,400" + "^FH\^FD" + cDtaVal + "^FS")
        MSCBWrite("^FO" + "340,400" + "^FH\^FD" + cDtaValING + "^FS")        

        MSCBWrite("^FO" + "320,400" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "300,400" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")   
    //SE PRODUTOS FOREM DO GRUPO DE PRODUTOS DO PORCIONADOS
    ELSEIF(cCodGrp $ GetMV('MV_GRPPORC'))
        //Alert("Pertence ao grupo do porcionados")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "460,020" + "^FH\^FD" + 'Data de produ\87\C6o/Lote:' + " ^FS")    
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Datos de producci\A2n/Lote:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Date of production/Batch:' + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data da validade:' + "^FS")        
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Datos de validaci\A2n:' + "^FS")
        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Validation data:' + "^FS")

        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Tara da embalagem:' + "^FS")        
        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Tara del embalaje:' + "^FS")
        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Packaging tare:' + "^FS")

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "450,320" + "^FH\^FD" + cDtaPro + " ^FS")        
        MSCBWrite("^FO" + "420,320" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "390,320" + "^FH\^FD" + cDtaVal + "^FS")
        MSCBWrite("^FO" + "360,320" + "^FH\^FD" + cDtaValING + "^FS")        

        MSCBWrite("^FO" + "330,320" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "300,320" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")
    ENDIF    
    //IMPRIME DADOS SOBRE CONSUMO
    IF (ZZ7->ZZ7_CONSU = '1')
        MSCBWrite("^FO" + "280,020" + "^FH\^FD" + "Ap\A2s aberto consumir em at\82 2 (dois) dias" + " ^FS")
        MSCBWrite("^FO" + "260,020" + "^FH\^FD" + "Una vez abierto, consumir dentro en 2 (dos) dias" + " ^FS")
        MSCBWrite("^FO" + "240,020" + "^FH\^FD" + "Once opened, consume within 2 (two) days." + " ^FS")
    ENDIF
    //IMPRIME DADOS SOBRE INGREDIENTES
    IF (!EMPTY(ZZ7->ZZ7_INGRED))
        MSCBWrite("^FO" + "210,020" + "^FH\^FD" + "Ingredientes/Ingredientes/Ingredients: " + Alltrim(ZZ7->ZZ7_INGRED) + " ^FS")
    ENDIF
    IF (!EMPTY(ZZ7->ZZ7_MSGVAR))
        //MSCBWrite("^FO" + "110,020" + "^FH\^FD" + Alltrim(ZZ7->ZZ7_MSGVAR) + "/Prohibida la venta al por menor/Retail sale prohibited" + " ^FS")
        MSCBWrite("^FO" + "190,020" + "^FH\^FD" + "Proibida venda no varejo/Prohibida la venta al por menor/Retail sale prohibited" + " ^FS")
    ENDIF
    MSCBWrite("^FO" + "200,020" + "^FH\^FD" + "Uma vez descongelado, n\C6o voltar a congelar." + "^FS")
    MSCBWrite("^FO" + "180,020" + "^FH\^FD" + "Antes de consumir, submeter a tratamento t\82rmico." + "^FS")

    MSCBWrite("^FO" + "160,020" + "^FH\^FD" + "IMPORTADO POR: Frimarc, S.A. Estoi, Faro, Portugal" + "^FS")

    MSCBWrite("^FO" + "140,020" + "^FH\^FD" + "Origem: Brasil" + "^FS")
    MSCBWrite("^FO" + "120,020" + "^FH\^FD" + "Abatido em: Brasil 1733" + "^FS")
    MSCBWrite("^FO" + "100,020" + "^FH\^FD" + "Desmancha em: Brasil 1733" + "^FS")

    MSCBWrite("^CFA,20")
    MSCBWrite("^FO" + "060,020" + "^FH\^FD" + "Registro no Minist\82rio da Agricultura SIF/DIPOA sob n\A7 " + "^FS")
    MSCBWrite("^FO" + "040,020" + "^FH\^FD" + "Registration in the Ministry of Agriculture SIF/DIPOA under no. " + "^FS")
    MSCBWrite("^FO" + "050,600" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_MSIF) + "^FS")
    //IMPRIME CODIGO DO PRODUTO
    //MSCBWrite("^CFA,50^FO" + "030,050" + "^FH\^FD" + cCodPro + " ^FS")
    //CODIGO DE BARRAS
    MSCBWrite("^BY3,3,50")
    MSCBWrite("^FT" + "200,530")
    MSCBWrite("^BCN,,Y,N")
    MSCBWrite("^FD>;" + ZZ7->ZZ7_CODPRO + "^FS")
    //QRCODE
    IF cCodPrg = "006"
        MSCBWrite("^FO" + "480,500")
        MSCBWrite("^BQN,2,3")
        MSCBWrite("^FD" + "MA," + "https://cnabrasil.org.br/protocolo-angus" + "^FS")
    ENDIF

    //IMAGEM LOGO CERTIFICAÇÃO
    IF cCodPrg = "006"
        MSCBWrite("^FO" + "500,020")
        MSCBWrite(AngLogoImg())
        //MSCBWrite("^IME:IMGANGUS_INGLES.GRF,1,1")
    ELSEIF cCodPrg = "002"
        MSCBWrite("^FO" + "495,020")
        MSCBWrite(HerLogoImg())
        //MSCBWrite("^IME:IMGCERTHER.GRF,1,1")
    ENDIF

    //ENCERRA LINGUAGEM ZPL
    MSCBWrite("^PQ" + cQtdEtq + ",0,1,N")
    MSCBWrite("^XZ")
RETURN

STATIC FUNCTION EtqZPL_MEXICO()        
    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWR")

    Local cY := '020'
    IF(cCodPrg $ '002')
        cY := '200'
    ELSEIF(cCodPrg $ '006')
        cY := '150'
    ENDIF
    //IMPRIMI DESCRIÇÃO DO SIF
    IF(!Empty(cDescSIFPT))
        MSCBWrite("^CFA,20^FO" + "640,"+cY + "^FH\^FD" + cDescSIFPT + "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "640,"+cY + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    ENDIF
    IF(!Empty(cDescSIFES))
        MSCBWrite("^CFA,20^FO" + "620,"+cY + "^FH\^FD" + cDescSIFES + "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "620,"+cY + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    ENDIF
    IF(!Empty(cDescSIFIN))
        MSCBWrite("^CFA,20^FO" + "600,"+cY + "^FH\^FD" + cDescSIFIN + "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "600,"+cY + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    ENDIF
    //IMPRIMI O NOME DO CORTE
    IF(!Empty(cDescCorPT))
        MSCBWrite("^CFA,20^FO" + "580,"+cY + "^FH\^FD" + cDescCorPT + "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "580,"+cY + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")            
    ENDIF
    IF(!Empty(cDescCorES))
        MSCBWrite("^CFA,20^FO" + "560,"+cY + "^FH\^FD" + cDescCorES + "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "560,"+cY + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")            
    ENDIF
    IF(!Empty(cDescCorIN))
        MSCBWrite("^CFA,20^FO" + "540,"+cY + "^FH\^FD" + cDescCorIN + "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "540,"+cY + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")            
    ENDIF
    //IMPRIMI PORCENTAGEM DE GORDURA
    IF (cCodGrp $ GetMV('MV_GRPPORC') .AND. !Empty(ZZ7->ZZ7_INGRE2))
        IF(!Empty(cObser3))                        
            MSCBWrite("^CFA,20^FO" + "520,020" + "^FH\^FD" + "M\A0ximo " + cObser3 + " de gordura / " + "Maximum " + cObser3 + " fat / " + "M\A0ximo " + cObser3 + " de grasa" + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "515,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")            
        ENDIF
    ELSEIF (!cCodGrp $ GetMV('MV_GRPPORC') .AND. !Empty(ZZ7->ZZ7_INGRE2))
        IF(!Empty(cObser3))            
            MSCBWrite("^CFA,20^FO" + "520,020" + "^FH\^FD" + cObser3 + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "520,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")            
        ENDIF
    ENDIF
    //IMPRIMI FORMA DE RESFRIAMENTO/CONGELAMENTO    
    IF !Empty(cMsgTemp)
        aTemper := STRTOKARR(cMsgTemp, ' ')
        IF('RESFRIADO' $ cMsgTemp)
            MSCBWrite("^FO" + "470,020")            
            MSCBWrite("^FH\^FD Manter resfriado a/Mantener resfriado en/Keep cool at " + aTemper[4] + ' \A7C' + "^FS")                    
        ELSEIF ('CONGELADO' $ cMsgTemp)
            MSCBWrite("^FO" + "470,020")
            MSCBWrite("^FH\^FD Manter congelado a/Mantener congelado en/Keep frozen at " + aTemper[4] + ' \A7C' + "^FS")                    
        ENDIF
    ELSE
        MSCBWrite("^FO" + "490,020" + "^FH\^FD " + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    ENDIF
    //IMPRIMI DATAS    
    IF (!cCodGrp $ GetMV('MV_GRPCHRQ')) .AND. (!cCodGrp $ GetMV('MV_GRPMDS')) .AND. (!cCodGrp $ GetMV('MV_GRPPORC'))
        //Alert("Pertence ao grupo da desossa")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Data de abate/Fecha de matanza:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Slaugther date:' + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data da embalagem/Produ\87\C6o/Lote:' + "^FS")        
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Fecha del embalaje/Produccion/Lote:' + "^FS")
        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Packing date/Production/Batch:' + "^FS")

        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Data de validade/Fecha de validad:' + "^FS")        
        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Expiration date:' + "^FS")        

        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Tara da embalagem/Tara del embalaje:' + "^FS")        
        MSCBWrite("^FO" + "280,020" + "^FH\^FD" + 'Packing tare:' + "^FS") 

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "440,400" + "^FH\^FD" + cDtaAbt + " ^FS")
        MSCBWrite("^FO" + "420,400" + "^FH\^FD" + cDtaAbtING + " ^FS")        

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "390,400" + "^FH\^FD" + cDtaPro + " ^FS")
        MSCBWrite("^FO" + "360,400" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "340,400" + "^FH\^FD" + cDtaVal + "^FS")
        MSCBWrite("^FO" + "320,400" + "^FH\^FD" + cDtaValING + "^FS")        

        MSCBWrite("^FO" + "300,400" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "280,400" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")
    //SE PRODUTOS FOREM DO GRUPO DE PRODUTOS DO CHARQUE    
    ELSEIF(cCodGrp $ GetMV('MV_GRPCHRQ'))
        //Alert("Pertence ao grupo do charque")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "460,020" + "^FH\^FD" + 'Data de abate/Produ\87\C6o/Lote:' + " ^FS")
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Datos de abando/Producci\A2n/Lote:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Date of slaughter/Production/Batch:' + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data da embalagem:' + "^FS")        
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Datos del embalaje:' + "^FS")
        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Packaging data:' + "^FS")

        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Data da validade:' + "^FS")        
        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Datos de validaci\A2n:' + "^FS")
        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Validation data:' + "^FS")

        MSCBWrite("^FO" + "280,020" + "^FH\^FD" + 'Tara da embalagem:' + "^FS")        
        MSCBWrite("^FO" + "260,020" + "^FH\^FD" + 'Tara del embalaje:' + "^FS")
        MSCBWrite("^FO" + "240,020" + "^FH\^FD" + 'Packaging tare:' + "^FS")  

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "450,400" + "^FH\^FD" + cDtaAbt + " ^FS")
        MSCBWrite("^FO" + "420,400" + "^FH\^FD" + cDtaAbtING + " ^FS")        

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "390,400" + "^FH\^FD" + cDtaPro + " ^FS")
        MSCBWrite("^FO" + "360,400" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "330,400" + "^FH\^FD" + cDtaVal + "^FS")
        MSCBWrite("^FO" + "300,400" + "^FH\^FD" + cDtaValING + "^FS")        

        MSCBWrite("^FO" + "270,400" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "240,400" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")   
    //SE PRODUTOS FOREM DO GRUPO DE PRODUTOS DO MIUDOS
    ELSEIF(cCodGrp $ GetMV('MV_GRPMDS'))
        //Alert("Pertence ao grupo do miúdos")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "460,020" + "^FH\^FD" + 'Data de abate/Produ\87\C6o/Lote:' + " ^FS")
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Fecha de matanza/Producci\A2n/Lote:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Date of slaughter/Production/Batch:' + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data da embalagem/Fecha de embalaje:' + "^FS")                
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Packing date:' + "^FS")

        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Data da validade/Fecha de validad:' + "^FS")        
        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Expiration date:' + "^FS")

        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Tara da embalagem/Tara de embalaje:' + "^FS")       
        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Packing tare:' + "^FS")  

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "450,400" + "^FH\^FD" + cDtaAbt + " ^FS")
        MSCBWrite("^FO" + "420,400" + "^FH\^FD" + cDtaAbtING + " ^FS")        

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "400,400" + "^FH\^FD" + cDtaPro + " ^FS")
        MSCBWrite("^FO" + "380,400" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "360,400" + "^FH\^FD" + cDtaVal + "^FS")
        MSCBWrite("^FO" + "340,400" + "^FH\^FD" + cDtaValING + "^FS")        

        MSCBWrite("^FO" + "320,400" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "300,400" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")   
    //SE PRODUTOS FOREM DO GRUPO DE PRODUTOS DO PORCIONADOS
    ELSEIF(cCodGrp $ GetMV('MV_GRPPORC'))
        //Alert("Pertence ao grupo do porcionados")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "460,020" + "^FH\^FD" + 'Data de produ\87\C6o/Lote:' + " ^FS")    
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Datos de producci\A2n/Lote:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Date of production/Batch:' + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data da validade:' + "^FS")        
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Datos de validaci\A2n:' + "^FS")
        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Validation data:' + "^FS")

        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Tara da embalagem:' + "^FS")        
        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Tara del embalaje:' + "^FS")
        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Packaging tare:' + "^FS")

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "450,320" + "^FH\^FD" + cDtaPro + " ^FS")        
        MSCBWrite("^FO" + "420,320" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "390,320" + "^FH\^FD" + cDtaVal + "^FS")
        MSCBWrite("^FO" + "360,320" + "^FH\^FD" + cDtaValING + "^FS")        

        MSCBWrite("^FO" + "330,320" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "300,320" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")
    ENDIF

    IF (!EMPTY(ZZ7->ZZ7_IMPOR))
        MSCBWrite("^FO" + "260,020" + "^FH\^FD" + "IMPORTER: "+ Alltrim(ZZ7->ZZ7_IMPOR) + "^FS")  
        MSCBWrite("^FO" + "240,020" + "^FH\^FD" + "RUC: "+ Alltrim(ZZ7->ZZ7_RUT) + "^FS")  
        MSCBWrite("^FO" + "220,020" + "^FH\^FD" + Alltrim(ZZ7->ZZ7_ENDIMP) + "^FS") 
    ENDIF
    // MSCBWrite("^FO" + "260,020" + "^FH\^FD" + "IMPORTER: YOREME CORTES Y PROCESOS SA DE CV" + "^FS")
    // MSCBWrite("^FO" + "240,020" + "^FH\^FD" + "RFC:YCP990322HZ1" + "^FS")
    // MSCBWrite("^FO" + "220,020" + "^FH\^FD" + "BLVD. CIRCUNVALACION 1049 SUR, C.P. 85065" + "^FS")    
    // MSCBWrite("^FO" + "200,020" + "^FH\^FD" + "PARQUE INDUSTRIAL, CIUDAD" + "^FS")
    // MSCBWrite("^FO" + "180,020" + "^FH\^FD" + "OBREGON, CAJEME, SONORA, MEXICO" + "^FS")

    MSCBWrite("^CFA,20")
    MSCBWrite("^FO" + "160,020" + "^FH\^FD" + "Registro no Minist\82rio da Agricultura SIF/DIPOA sob n\A7 " + "^FS")
    MSCBWrite("^FO" + "140,020" + "^FH\^FD" + "Registro en el Minist\82rio de Agricultura SIF/DIPOA bajo n\A7. " + "^FS")
    MSCBWrite("^FO" + "120,020" + "^FH\^FD" + "Registration in the Ministry of Agriculture SIF/DIPOA under no. " + "^FS")
    MSCBWrite("^FO" + "100,150" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_MSIF) + "^FS")
    //IMPRIME CODIGO DO PRODUTO
    MSCBWrite("^CFA,50^FO" + "030,050" + "^FH\^FD" + cCodPro + " ^FS")
    //CODIGO DE BARRAS
    MSCBWrite("^BY3,3,50")
    MSCBWrite("^FT" + "055,450")
    MSCBWrite("^BCR,,Y,N")
    MSCBWrite("^FD>;" + ZZ7->ZZ7_CODPRO + "^FS")

    //QRCODE
    IF cCodPrg = "006"
        MSCBWrite("^FO" + "325,450")
        MSCBWrite("^BQN,2,3")
        MSCBWrite("^FD" + "MA," + "https://cnabrasil.org.br/protocolo-angus" + "^FS")
    ENDIF

    //IMAGEM LOGO CERTIFICAÇÃO
    IF cCodPrg = "006"
        MSCBWrite("^FO" + "500,020")
        MSCBWrite(AngLogoImg())
        //MSCBWrite("^IME:IMGANGUS_INGLES.GRF,1,1")
    ELSEIF cCodPrg = "002"
        MSCBWrite("^FO" + "495,020")
        MSCBWrite(HerLogoImg())
        //MSCBWrite("^IME:IMGCERTHER.GRF,1,1")
    ENDIF

    //IMAGEM LOGO IMPORTADOR
    IF (!Empty(ZZ7->ZZ7_IMPOR))
        IF ('SICARNES' $ ZZ7->ZZ7_IMPOR)
            MSCBWrite("^FO" + "500,515")
            MSCBWrite(ImpLogoImg())
        ENDIF
    ENDIF

    //ENCERRA LINGUAGEM ZPL
    MSCBWrite("^PQ" + cQtdEtq + ",0,1,N")
    MSCBWrite("^XZ")
RETURN

STATIC FUNCTION EtiquetasEmZPLII()        
    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWR")
    //IMPRIMI DESCRIÇÃO DO SIF
    IF(!Empty(cDescSIFPT))
        MSCBWrite("^CFA,20^FO" + "640,020" + "^FH\^FD" + cDescSIFPT + "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "640,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    ENDIF
    IF(!Empty(cDescSIFES))
        MSCBWrite("^CFA,20^FO" + "620,020" + "^FH\^FD" + cDescSIFES + "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "620,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    ENDIF
    IF(!Empty(cDescSIFIN))
        MSCBWrite("^CFA,20^FO" + "600,020" + "^FH\^FD" + cDescSIFIN + "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "600,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    ENDIF
    //IMPRIMI O NOME DO CORTE
    IF(!Empty(cDescCorPT))
        MSCBWrite("^CFA,20^FO" + "580,020" + "^FH\^FD" + cDescCorPT + "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "580,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")            
    ENDIF
    IF(!Empty(cDescCorES))
        MSCBWrite("^CFA,20^FO" + "560,020" + "^FH\^FD" + cDescCorES + "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "560,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")            
    ENDIF
    IF(!Empty(cDescCorIN))
        MSCBWrite("^CFA,20^FO" + "540,020" + "^FH\^FD" + cDescCorIN + "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "540,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")            
    ENDIF
    //IMPRIMI PORCENTAGEM DE GORDURA
    IF (cCodGrp $ GetMV('MV_GRPPORC') .AND. !Empty(ZZ7->ZZ7_INGRE2))
        IF(!Empty(cObser3))                        
            MSCBWrite("^CFA,20^FO" + "520,020" + "^FH\^FD" + "M\A0ximo " + cObser3 + " de gordura / " + "Maximum " + cObser3 + " fat / " + "M\A0ximo " + cObser3 + " de grasa" + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "515,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")            
        ENDIF
    ELSEIF (!cCodGrp $ GetMV('MV_GRPPORC') .AND. !Empty(ZZ7->ZZ7_INGRE2))
        IF(!Empty(cObser3))            
            MSCBWrite("^CFA,20^FO" + "520,020" + "^FH\^FD" + cObser3 + "^FS")
        ELSE
            MSCBWrite("^CFA,20^FO" + "520,020" + "^FH\^FD" + Upper("Sem dados no banco de dados para imprimir") + "^FS")            
        ENDIF
    ENDIF
    //IMPRIMI FORMA DE RESFRIAMENTO/CONGELAMENTO    
    IF !Empty(cMsgTemp)
        aTemper := STRTOKARR(cMsgTemp, ' ')
        IF('RESFRIADO' $ cMsgTemp)
            MSCBWrite("^FO" + "490,020")            
            MSCBWrite("^FH\^FD Manter resfriado a/Mantener resfriado en/Keep cool at " + aTemper[4] + ' \A7C' + "^FS")                    
        ELSEIF ('CONGELADO' $ cMsgTemp)
            MSCBWrite("^FO" + "490,020")
            MSCBWrite("^FH\^FD Manter congelado a/Mantener congelado en/Keep frozen at " + aTemper[4] + ' \A7C' + "^FS")                    
        ENDIF
    ELSE
        MSCBWrite("^FO" + "490,020" + "^FH\^FD " + Upper("Sem dados no banco de dados para imprimir") + "^FS")
    ENDIF
    //IMPRIMI DATAS    
    IF (!cCodGrp $ GetMV('MV_GRPCHRQ')) .AND. (!cCodGrp $ GetMV('MV_GRPMDS')) .AND. (!cCodGrp $ GetMV('MV_GRPPORC'))
        //Alert("Pertence ao grupo da desossa")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "460,020" + "^FH\^FD" + 'Data de abate/Produ\87\C6o/Lote:' + " ^FS")
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Datos de abando/Producci\A2n/Lote:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Date of slaughter/Production/Batch:' + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data da embalagem:' + "^FS")        
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Datos del embalaje:' + "^FS")
        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Packaging data:' + "^FS")

        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Data da validade:' + "^FS")        
        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Datos de validaci\A2n:' + "^FS")
        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Validation data:' + "^FS")

        MSCBWrite("^FO" + "280,020" + "^FH\^FD" + 'Tara da embalagem:' + "^FS")        
        MSCBWrite("^FO" + "260,020" + "^FH\^FD" + 'Tara del embalaje:' + "^FS")
        MSCBWrite("^FO" + "240,020" + "^FH\^FD" + 'Packaging tare:' + "^FS")  

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "450,400" + "^FH\^FD" + cDtaAbt + " ^FS")
        MSCBWrite("^FO" + "420,400" + "^FH\^FD" + cDtaAbtING + " ^FS")        

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "390,400" + "^FH\^FD" + cDtaPro + " ^FS")
        MSCBWrite("^FO" + "360,400" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "330,400" + "^FH\^FD" + cDtaVal + "^FS")
        MSCBWrite("^FO" + "300,400" + "^FH\^FD" + cDtaValING + "^FS")        

        MSCBWrite("^FO" + "270,400" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "240,400" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")        
    //SE PRODUTOS FOREM DO GRUPO DE PRODUTOS DO CHARQUE    
    ELSEIF(cCodGrp $ GetMV('MV_GRPCHRQ'))
        //Alert("Pertence ao grupo do charque")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "460,020" + "^FH\^FD" + 'Data de abate/Produ\87\C6o/Lote:' + " ^FS")
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Datos de abando/Producci\A2n/Lote:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Date of slaughter/Production/Batch:' + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data da embalagem:' + "^FS")        
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Datos del embalaje:' + "^FS")
        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Packaging data:' + "^FS")

        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Data da validade:' + "^FS")        
        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Datos de validaci\A2n:' + "^FS")
        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Validation data:' + "^FS")

        MSCBWrite("^FO" + "280,020" + "^FH\^FD" + 'Tara da embalagem:' + "^FS")        
        MSCBWrite("^FO" + "260,020" + "^FH\^FD" + 'Tara del embalaje:' + "^FS")
        MSCBWrite("^FO" + "240,020" + "^FH\^FD" + 'Packaging tare:' + "^FS")  

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "450,400" + "^FH\^FD" + cDtaAbt + " ^FS")
        MSCBWrite("^FO" + "420,400" + "^FH\^FD" + cDtaAbtING + " ^FS")        

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "390,400" + "^FH\^FD" + cDtaPro + " ^FS")
        MSCBWrite("^FO" + "360,400" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "330,400" + "^FH\^FD" + cDtaVal + "^FS")
        MSCBWrite("^FO" + "300,400" + "^FH\^FD" + cDtaValING + "^FS")        

        MSCBWrite("^FO" + "270,400" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "240,400" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")   
    //SE PRODUTOS FOREM DO GRUPO DE PRODUTOS DO MIUDOS
    ELSEIF(cCodGrp $ GetMV('MV_GRPMDS'))
        //Alert("Pertence ao grupo do miúdos")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "460,020" + "^FH\^FD" + 'Data de abate/Produ\87\C6o/Lote:' + " ^FS")
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Fecha de matanza/Producci\A2n/Lote:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Date of slaughter/Production/Batch:' + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data da embalagem/Fecha de embalaje:' + "^FS")                
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Packing date:' + "^FS")
        
        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Data da validade/Fecha de validad:' + "^FS")        
        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Expiration date:' + "^FS")
        
        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Tara da embalagem/Tara de embalaje:' + "^FS")       
        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Packing tare:' + "^FS")  

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "450,400" + "^FH\^FD" + cDtaAbt + " ^FS")
        MSCBWrite("^FO" + "420,400" + "^FH\^FD" + cDtaAbtING + " ^FS")        

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "400,400" + "^FH\^FD" + cDtaPro + " ^FS")
        MSCBWrite("^FO" + "380,400" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "360,400" + "^FH\^FD" + cDtaVal + "^FS")
        MSCBWrite("^FO" + "340,400" + "^FH\^FD" + cDtaValING + "^FS")        

        MSCBWrite("^FO" + "320,400" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "300,400" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")   
    //SE PRODUTOS FOREM DO GRUPO DE PRODUTOS DO PORCIONADOS
    ELSEIF(cCodGrp $ GetMV('MV_GRPPORC'))
        //Alert("Pertence ao grupo do porcionados")
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "460,020" + "^FH\^FD" + 'Data de produ\87\C6o/Lote:' + " ^FS")    
        MSCBWrite("^FO" + "440,020" + "^FH\^FD" + 'Datos de producci\A2n/Lote:' + " ^FS")
        MSCBWrite("^FO" + "420,020" + "^FH\^FD" + 'Date of production/Batch:' + " ^FS")

        MSCBWrite("^FO" + "400,020" + "^FH\^FD" + 'Data da validade:' + "^FS")        
        MSCBWrite("^FO" + "380,020" + "^FH\^FD" + 'Datos de validaci\A2n:' + "^FS")
        MSCBWrite("^FO" + "360,020" + "^FH\^FD" + 'Validation data:' + "^FS")

        MSCBWrite("^FO" + "340,020" + "^FH\^FD" + 'Tara da embalagem:' + "^FS")        
        MSCBWrite("^FO" + "320,020" + "^FH\^FD" + 'Tara del embalaje:' + "^FS")
        MSCBWrite("^FO" + "300,020" + "^FH\^FD" + 'Packaging tare:' + "^FS")

        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "450,320" + "^FH\^FD" + cDtaPro + " ^FS")        
        MSCBWrite("^FO" + "420,320" + "^FH\^FD" + cDtaProING + " ^FS")

        MSCBWrite("^FO" + "390,320" + "^FH\^FD" + cDtaVal + "^FS")
        MSCBWrite("^FO" + "360,320" + "^FH\^FD" + cDtaValING + "^FS")        

        MSCBWrite("^FO" + "330,320" + "^FH\^FD" + cPesEmb + " g" + "^FS")
        MSCBWrite("^FO" + "300,320" + "^FH\^FD" + cTaraEmbLi + " Lb" + "^FS")
    ENDIF    

    IF (!EMPTY(ZZ7->ZZ7_IMPOR) .AND. ZZ7->ZZ7_CONSU != '1')
        MSCBWrite("^FO" + "260,020" + "^FH\^FD" + "IMPORTER: "+ Alltrim(ZZ7->ZZ7_IMPOR) + "^FS")  
        MSCBWrite("^FO" + "240,020" + "^FH\^FD" + "RUC: "+ Alltrim(ZZ7->ZZ7_RUT) + "^FS")  
        MSCBWrite("^FO" + "220,020" + "^FH\^FD" + Alltrim(ZZ7->ZZ7_ENDIMP) + "^FS") 
    ENDIF
    //IMPRIME DADOS SOBRE CONSUMO
    IF (ZZ7->ZZ7_CONSU = '1')
        MSCBWrite("^FO" + "280,020" + "^FH\^FD" + "Ap\A2s aberto consumir em at\82 2 (dois) dias" + " ^FS")
        MSCBWrite("^FO" + "260,020" + "^FH\^FD" + "Una vez abierto, consumir dentro en 2 (dos) dias" + " ^FS")
        MSCBWrite("^FO" + "240,020" + "^FH\^FD" + "Once opened, consume within 2 (two) days." + " ^FS")
    ENDIF
    //IMPRIME DADOS SOBRE INGREDIENTES
    IF (!EMPTY(ZZ7->ZZ7_INGRED))
        MSCBWrite("^FO" + "210,020" + "^FH\^FD" + "Ingredientes/Ingredientes/Ingredients: " + Alltrim(ZZ7->ZZ7_INGRED) + " ^FS")
    ENDIF
    IF (!EMPTY(ZZ7->ZZ7_MSGVAR))
        //MSCBWrite("^FO" + "110,020" + "^FH\^FD" + Alltrim(ZZ7->ZZ7_MSGVAR) + "/Prohibida la venta al por menor/Retail sale prohibited" + " ^FS")
        MSCBWrite("^FO" + "190,020" + "^FH\^FD" + "Proibida venda no varejo/Prohibida la venta al por menor/Retail sale prohibited" + " ^FS")
    ENDIF
    
    MSCBWrite("^CFA,20")
    MSCBWrite("^FO" + "160,020" + "^FH\^FD" + "Registro no Minist\82rio da Agricultura SIF/DIPOA sob n\A7 " + "^FS")
    MSCBWrite("^FO" + "140,020" + "^FH\^FD" + "Registro en el Minist\82rio de Agricultura SIF/DIPOA bajo n\A7. " + "^FS")
    MSCBWrite("^FO" + "120,020" + "^FH\^FD" + "Registration in the Ministry of Agriculture SIF/DIPOA under no. " + "^FS")
    MSCBWrite("^FO" + "100,150" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_MSIF) + "^FS")
    //IMPRIME CODIGO DO PRODUTO
    MSCBWrite("^CFA,50^FO" + "030,050" + "^FH\^FD" + cCodPro + " ^FS")
    //CODIGO DE BARRAS
    MSCBWrite("^BY3,3,50")
    MSCBWrite("^FT" + "055,450")
    MSCBWrite("^BCR,,Y,N")
    MSCBWrite("^FD>;" + ZZ7->ZZ7_CODPRO + "^FS")
    //ENCERRA LINGUAGEM ZPL
    MSCBWrite("^PQ" + cQtdEtq + ",0,1,N")
    MSCBWrite("^XZ")
RETURN

STATIC FUNCTION Imprime()
    incproc()

    _cEst := getComputerName()
	_cIp  := ''

    IF !_cEst == 'THIS'
        dbselectarea('ZAM')
        ZAM->(dbSetOrder(2))
        IF ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
            _cIp := alltrim(ZAM->ZAM_IP)
        ENDIF
    ELSE
        _cIp  := GetMV("SI_PRCOMDS")//'10.6.20.86'        
    ENDIF
	
	IF empty(_cIp)
		MSCBPRINTER('S600','LPT1')
	ELSE
		MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
	ENDIF

    MSCBCHKSTATUS(.F.)
    MSCBBEGIN(1,6,15)

    If (ZZ7->ZZ7_PAIS = "607")
        EtqZPL_PORTUGA()
    ElseIf (ZZ7->ZZ7_PAIS $ "493/589")
        EtqZPL_MEXICO()
    Else
        EtiquetasEmZPLII()
    EndIf    
    MSCBEND()
	MSCBCLOSEPRINTER()
RETURN

// Retorna a string de imagem do logo da Angus
Static Function HerLogoImg()

    Local cImgStr := ""

    cImgStr += "^GFA,4094,4094,23,,,,g07FFC,Y0KFE,X07LFC,W01NF8,W0PF,V03PFE,V07QF8,U01SF,U07SFE,U0UFC003FF8,T01gHF,T07gHFE,T0gJF8,
    cImgStr += "S01gJFC,S07gKF,S0MFCI01TF8,R01LFI07FC07RFE,R03KF007KFC7RF,R07JF80NFEPFEFC,R0JFC07OFDPF3E,Q01IFE03QFBOFDF,Q03IF81gHFE78,Q07F
    cImgStr += "FE07gIF3E,Q0IF81QF8RF8F,P01FFE07PFE39QFC78,P03FFC1QFCFCQFE1C,P07FF07QF9FERF0E,P0FFC0RF1FERF86,O01FF83LFBKF3TFC1,O03FF07KFC3
    cImgStr += "KF3TFC08,O07FC1LFC0KF3TFE04,O0FF83LFC0KF3UF,N01FF07LFC3KF3IFBQF82,N03FE0NFBKF9FFE3QF81,N07FC3TFDFDD3QFC1,N0FF87TFE73B7QFC08
    cImgStr += "0M01FF0FFBSFC357E7OFE080M03FE1FF3TFCF7E3OFE040M07FC3FE3UF67CDPF040M0FF87FD9UFC79CPF040L01FF07FFCVF70CPF060L01FF0IFE7MFC00KF
    cImgStr += "B21PF860L03FE1FEFE3LFK07IFE67EOF820L07FC3FDFE1KF87IFC07IF67E7NF820L0FF87F8FD8DIFC7KFC1IFE7C7NF820L0FF87F47BC3IF3MF83FFE727N
    cImgStr += "F830K01FF0FFE37E7FFDNFE0IF6EENF830K03FE1IF0FEIF7OF87FF9EF7MF030K03FE1FDF8JFDPFE1FFDEE3MF030K07FC3FBFC7IFBQF8IFEDNF070K0FF87
    cImgStr += "FBFE3FFERFC3FFCBDMF070K0FF87F0FF0FFDSF1FFC7EMF070J01FF0FEC7F9FFBSF8FFCFCLFE070J01FF0FEE1FBVFC7FDF07KFE070J03FE1FDF877VFE3FF
    cImgStr += "E3LFE0F0J07FE1F9FE2XF1FF0BBKFE0E0J07FC3F9F70XF8FF9CBKFC0E0J0FFC3FDCFDXFC7FFB7KFC0E0J0FFC7FDE7BXFE3FDMFC1E0J0FF87JFBYF3FE7LF
    cImgStr += "81E0I01FF8FEIF7WFEF9FEMF81C0I01FF0FEFF8XFE78OF83C0I03FF0FC3FEXFE7COF83C0I03FF1FC0gFE7E7NF0380I07FE1FBC1DXFE7E3FFE07IF0780I0
    cImgStr += "7FE1FFE03XFE7F3FFC03IF0780I07FE3FFCE3UFDEFF3F1FF8FDIF07,I0FFE3FC1FBUFDEFF3F9FF3FEIF0F,I0FFC3F03WFBF7FBF9FF7KF0E,I0FFC7F3EF7
    cImgStr += "JF0PFBF7F9FCFF7FF7FF0E,001FFC7EFE0IF3C03OF3F7FDFCFF7FF7FF1C,001FFC7IF0IF1I0OF7F7FDFE7JF7FF1C,001FF87LFEJ01NF7EFFDFE7F7FE7FF
    cImgStr += "98,001FF87LFEJ07MFE7DFFDFE7F7FCIFB,003FF8FDKFEI01NFE7DFFDFF7FBLF,003FF8FDFFDFFCI03FFE1KF73FFDFF3F9LF,003FF8FC03DFFCI01FF047
    cImgStr += "JF61DFDFF3FCKFE,003FF8FC001FFCJ0FF083IF00C1FDFF3IFBIFE,003FF8FDF43FFCJ079I0FFCI09FDFF3IFBIFE,007FF8FDF7IF8J079I03FJ03FDFFBF
    cImgStr += "C03IFE,007FF0IF7IF8J039P0FCFFBFC1BIFE,007FF0FDE7BFF8K09P03CFF9FDDJFA,007FF0F9E3BFF8K09P01CFF9FDDJFE,007FF1FDFFBFF8K0918O0EF
    cImgStr += "F9FDFBIFE,007FF1FE7E3FF8K0B1CO067F9FCF7JF,007FF1MF8K0A0CO027F9NF,00IF1JFBFF8J01A06O013F9FDLF,00IF1FBFFBFF8J032Q013F9FDFDJF,
    cImgStr += "00IF1F8003FF8J072R09F9FC03JF,00IF0FC003FF8J0F8R01F9FD83JF,00IF8FDFFBFF8I01F8R05FBNF,00IF8JFBFF8I0788R04FBFF1BIFD,00IF8IF7BF
    cImgStr += "F807FF88S0FBFC43IFD,00IF8FFE1BFF81IF0CR02FBFCE7IFD,00IF8JFBFFC7FFE0CR02FBMFD,00IF8IFE7FFCIFC04K04L02F3MFD,00IF8MFDIF906K02L
    cImgStr += "03F7FFEJFD,00IF8IF8MF902K01L03F7FBF3IF9,00IFCFFC03LF003L0CK01F7FBF7IF9,00IFC7F879KFE001L06K03EFF837IFB,01IFC7F9FEKFEI08K07K
    cImgStr += "07EFF607IFB,01IFC7F3KF7FEI08K07K07EIFEJFB,01IFE7F7FF7FFL04K02K0FDNFB,01IFE3F7FF7FFX0FDIFEJF2,03IFE3F7FF7FF8W0FBIF8JF2,03IFE
    cImgStr += "3F7FF7FF8V01FBNF2,03JF3F7FE7FFCV01F7FC7KF2,03JF1FBF8IFEV03F7FC0DIFE2,03JF1F8E1JFR07FFE7EIFC3IFE6,03JF9FE03DJF801N0FBFELF3IF
    cImgStr += "E4,03JF8FF9FCJFE01CM0FC7CFDFF7KFE4,03JFCJF8KF00FL01FE7DJF7KFC4,01JFC7IF17KF07CL0FF3BIFE1KFC4,01JFC7FFC3BLF3F8K0FF37JF87JFCC
    cImgStr += ",01JFE7FF0FBKFDFFDFFC01FF2FEIFE0JF88,00JFE3F62FBLF8FEJ017FBFDIF59JF88,00KF3F86F3MF808J07FBKFDKF98,007JF1F9E03NFC4J0BFBJF7FB
    cImgStr += "JF1,007JF9FDE47PFJ07FBIFE7C7JF1,003JF8FFCRFEI07F7IFC3F7IFE3,001JFCFFCFFBPFE03FF7JF1KFE2,I0JFE7F9FF9TFEKFC7JFE6,I07IFE3F9FF2
    cImgStr += "7YFE1JFC6,I03JF3FBFE7BWFE1F3JFCC,I03JF1FDFC7BWFB8F7JF8C,I01JF9FDF8FDWF7E7KF98,I01JFCIF1FDWF7E7KF18,J0JFE7F63FCVFD7F7KF38,J0
    cImgStr += "JFE3F87FCVF97F7JFE3,J07JF3FCFFCVFDFF7JFE7,J07JF9FEFF9UFDDFEKFC6,J03JFCFF7F1UF9DF1KFCE,J01JFE7FBE3UF87MF9C,J01KF3FC07TF9E3MF
    cImgStr += "18,K0KF9FF9TFE9F0MF38,K0KFCWFB9FCLFE3,K07JFE7UFD3CFELFE7,K03KF3TFE33CNFCE,K03KF9SFC7F3E7MF9C,K01KFCNFBJFE7F3E7MF9C,L0LF7LFC
    cImgStr += "3KF071E3MF38,L07KFBLFC1KF978DMFE7,L07KFCLFE07JFC7E7MFEE,L03LF7KFC1KFC7OFCE,L01LF9KF93KFEPF9C,M0LFELFBVFB8,M07LFBgHF7,M03gOF
    cImgStr += "E,M01gNFDC,N0gNFBC,N07gMF78,N03gLFEF,N01gLFDE,O0gLF3E,O07gJFE3C,O03gJF878,O01FC0gGF0F,P0FC07YFC3E,P0FC03YF07C,P07C01XFC0F8,
    cImgStr += "P03C007WF01F,P03EI0VFC03E,P01FJ0UF00F8,Q0F8J03RFC01F,Q07CK01PFE007C,Q07JFE001OF001F8,Q01KFE001MF8007E,R0LF8I07JF8001F8,R03L
    cImgStr += "FQ0FE,U03JFN03FF8,V07KFJ0JFC,W0RFE,X0QF,Y07MFE,gG07JF,"

Return cImgStr

// Retorna a string de imagem do logo da Angus
Static Function AngLogoImg()

    Local cImgStr := ""

    cImgStr += "^GFA,2808,2808,24,,,,,,,,,,,gR01IF,gQ07KFC,gP03MF8,00gLFC1OF07KFE0007gKF07OFC1KFE0003gJFE1NF7FF87JFE0003gJF87JFBIF8FFE3JFE0"
    cImgStr += "001gIFE1KF9IF81FF0JFE0001gIFC7KF81FF8CFFC7IFE0I0gIF8FFDIF83FF867FE1IFE0I07gGFE1FF1FFE03FF1C7FF8IFE0I07gGFC7FFDFFC03FF147FFC"
    cImgStr += "7FFE0I03gGF8IFDIF81FF007F7E3FFE0I01gGF1FE7DIF88FE33FF3F1FFE0I01gFE3F833IF9FFE39FE1F8FFE0J0gFC7FE0JFBFFE28FC2FC7FE0J0gF8FEF0"
    cImgStr += "BIFBFF478FC57E3FE0J07YF1FCF82LFE50F8F3F1FE0J03YF3FF7C0MFC1F0D1F8FE0J03XFE7FFBF0OFE071FCFE0J01XFCIFDF8IF001IFC203FE7E0K0XF8I"
    cImgStr += "FEFCFFJ01FF8603FE3E0K0XF9MF8K03FCE3IF1E0K07WF3F80IFEM0FEE3IF9E0K03VFE3FCI0F8M03F63IFCE0K03VFE7FE001EO07E3IFCE0K01VFCIF783CN"
    cImgStr += "07DE3IFE60K01VFCFC1BFF8N09BF3IFE20L0VF9F005FFN02ECFBJF20L07QFE0FF9F702FCN059E7DF81F,L07IFDMFCE7F3EFC33807EK0A743E161F80L03I"
    cImgStr += "FEBLFDF7F3DFF1780C1EI01BDE1EEC3F80L01IFE8LFDFFE7DFF8F005208I0EF81FFC7FC0L01IFE1LFDF7E7CFF9E01CC9I03B740FF0FFC0M0IFCJFEFFEE7"
    cImgStr += "E7C1FDC02C108002FDC07F0FFE0M0NFE03IFCF83FF8035A8I036F003A1FFE0M07MFEFFE3FCFE3FB8054515DDBD1003C3FFE0M03IF3IFEDBDDFCFF7FF003"
    cImgStr += "AA9977EBF001C7IF0M03FFA7IFE03D9F9FF7E700I502AD7C0801E7IF0M01FFCBJF37EFF9F9F9E00B8B9BFFD3F400KF0N0KF7JFDDF9E01CE006B2906B7E0"
    cImgStr += "C00IF870N0IF3F3FE0FC1F9E001C003C193FFB552007BFE78N07FA7FD7E0FFDF3CE01C00E3840DACEAE00787F78N07FCBFD1FEFFDF3DFE1C016D7E7AFFB"
    cImgStr += "1500781F78N03JF47FEFFDF3DIF801A22A25AD5E6803807F8N01FC3F1FE5FC0F3DIF8036C509B7BA39803B80F8N01FBFF7FE9FDDF3DIF801E10626D67CF"
    cImgStr += "403BE03CO0F83JF0JF3E7FF803440C50AIB1A03FF83CO07C7F07E0FC167F8FF803EA808016EEF603DFF3CO07IF07IFDF67FF87002B080290IBCA01DIFCO"
    cImgStr += "03C3F77E6FFDE7EFF7007EE8702FEFEBD01CIFCO019FF07E3FC0678F0700EFB70C44FEFEB81C7FFCO01F3F7FE8FDDE7BE0700DB5833B3ABBFE01JFCP0FF"
    cImgStr += "EEFEEIF67BC3F00BEAFC8D8FEEB3C1JFCO01J0202I027FC7F0057DC2427577FE01CIFCP082550A0B48A7B87F01FDB7F8D97DAEB81C003CO02A480745083"
    cImgStr += "27B0F700976D1714AB3BE81C003CO050122020240A7C1E703FED6FABC7EDED01F803CO04CAD55C019557E3FF855BBF9B6A2A17A03IFBCO09010020AA209"
    cImgStr += "3JFAFEED5769E745D703IFBCN01264554A00CD53JFDABFBBCFFED84FC03BIFCO058BA014550053IFBBFF5EEFB5539DA203BIF8N02A4010290AC493IFBEA"
    cImgStr += "DF75BFIE7BFC038IF8N014A4E2A4041953FFC3FFBDDFED75AD7480701FF8N069290C4951C013FF01EDB7FA5FDFDFEB00700378N08282A0360E0A69D805D"
    cImgStr += "B6D5FBAF57A9A807700F8N05D405900A0A489C03DF6D7F5DFBFAFFE40FFE0F0M01A02A2276155969E094EB7ADF75EAFD5580EFFCF0M024B81CC880AA289"
    cImgStr += "E79CFCCDIBF7FD7FC41EFFEF0M0134141153420034FB80F793D6ABB6FDD281EJF0M0649436AA404C944F6817F7E7DFEEFAF7C03E7FFE0M089280851A0B1"
    cImgStr += "434F0137DD5AFAB7DFBEF87JFE0M056D2A58A05040CA783C3FFEF57FEBA6BB47JFE0L01A80C1A557AEA5127C381F6BBAD69E5BD68F7IFC0M043B120A281"
    cImgStr += "1086A7FE05FFD6FBBF9FF6F9E1IFC0L032C44174C56451853FC1EF57FBFFD702D99E07FF80L0651280831A8B04393D03F7FD56A42CD0BF3F83FF80M0A6D"
    cImgStr += "5534A134D3429E0C77EIFDBD124027BC0FF,L0B480AAC9564124AC9F1CE3FAB5742F0240F3F05F20K01435BI1228AE49114F7BD9JFDFF04813E3F83E20L"
    cImgStr += "09424I6546909I64FB7F0FFAD750B1407FBFE3E60K0269D1I8AA9256898A7FFE17EFFDAF4004KF7CA0L0860E357452DA834723DFC3BFEAB700203FF9FF7"
    cImgStr += "CA0K0558B0C2818C015C3053E387DJFACI0FEF5IF920K0AA3452C2E31BA22C6A9EF0FC7FC092483FC2DIF0A0K01142A91D0C645491948FF01D9IF6481FF"
    cImgStr += "00AFFE2A0J01E6AD4660B1894B66214FE19F0IF991FFEF02FFE520J020850A98B46329018CEA7C3BF1BMF1FC0FFCAA0J01558B123418C92EC33053E77E3"
    cImgStr += "CMFDFF0FF84A0J06AA346CC2E326D1344591F7FE3EBFBMFC7F1B20J091142812D0C48048A9A28FBFC7EAF9FFCFEIF7E20A0J046AAD5A90B155BB6564D47"
    cImgStr += "C3827D79EFC7EJFC56A0I01B8511256B4A924018890A3E78CFE781FE1KF88920K02A664A04126496C336D51FF0DIF03FE077IF132A0I03B5188B0DAEC8B"
    cImgStr += "293440228FD1DFFC03FE837FFE2CCA0I044A63547210354D24AAECD47F1JF03FFE0IFC51120I02918C2984E582909915110A1FDJF81FF703FF8AA6A0I0D"
    cImgStr += "2A31C2530A6C2B6268A6B58FEJF99FF7C0FE1458A0001254CA1D2C5491C41585184247KFBJFE7FC69A320I04A91560D1A9261ACA2AE5ADA1KFBIFBIF096"
    cImgStr += "14A0003942A88B0642D96130D10A10587NF9FFE320IA0I069D5354589D02964726516B241QF84CD49200050202429A3207448A848AA84CB07OFC191292A"
    cImgStr += "000AFEFDBD65CEF8BB75BB756BB36C1OF076ED6D60gP03MF8,gQ03KFC,gR01IF8,"

Return cImgStr

Static Function ImpLogoImg()

    Local cImgStr := ""

    cImgStr += "^GFA,2520,2520,15,,R03FFE,Q07JFE,P03LFE,O01FBFFC07F8,O07FFEJ01E,N01FDFL038,N07DF80JF806,N0FFE0LF818,M03EF87MF04,M077E1FF7FFE"
    cImgStr += "FFC1,M0FF8PF08,L01DF1IFE003EFFC,L03FC77FCJ03DFF,L0F79FFEL07FF8,K01FF3FFN0DFE,K03BE7FCN03FF,K03FDFFP0DF8,K06F3FEP03FC,K0FE7F8"
    cImgStr += "Q0FF,J01FEFFR03F8,J03BDFCR03FC,J03FBF8O0F0017E,J06F7FO022I0FF,J0FEFEO047I0378,I01FDFCO0E9I01F8,I01BBF8O0A1J0BC,I03FBFO0181J0"
    cImgStr += "7E,I03F4EO018180F03F,I076B6P080C1C03F8,I0FFB08O0807FF80F8,I0BDC78N01C01CF80FC,001FBF88N02I011807E,001FBC7O03I035003E,003B78C"
    cImgStr += "O0600E3D003F,003FFD4O0601E1B001F,006EF86O040023BI0F8,007DF1C04008J0E00232I0FC,007DF1K08J0CI0228007C,00DBEI0300F0400EJ044043E"
    cImgStr += ",00FBE300100E0B00EJ0840F3E,01BFC140080F3F80AK06091F,01F7C2C0080E7FA0C8007C21D9F,01FF80E0040F7FC0DI0FE21D8F,036F8280050E73D04"
    cImgStr += "001FF0178F8,03FF0140060F71C84801FE83F878,03DF0240020773C840017E72F07C,05DE02C00207F1C420037E33F07C,07FE02800183F3C4I067E01FC"
    cImgStr += "3C,07BC01A00100E1C618067EI063E,0BFC01I018003C2003CCEI031E,0F7C0278018E00C21FF08J019F,0F780388008FE0033FE08K08F,0778014I08FFC"
    cImgStr += "011F00804I0CF,0FF802J0C7FF01L03I04F,1EFI0EI0807F010FJ018004F8016F003CI0C00F0181E1L0C7801FF001J0C7F1018031K01C7801FF0024I0CFF"
    cImgStr += "C01800D8K0C3C03DEI04I0CFFE018002600100C7C02DE001CI0CE7F0186010801C0C3C03FE0011I0EE0F0180E0CI0C083C03DE0024I04E0701819838I018"
    cImgStr += "3C01FC001CI0CE0701806707800383C03BCM06E07018008C003E601F03BCM0C2070180033C11EC01E03BC003CI0E807018I0FBE3F801E05FE0023800CE07"
    cImgStr += "018K013F801E07F8009C800CFI018L0BEC01E07BC0034I0EFC0018L087801E83F8002J0C3F0018076981C7I0E87F8M0C1FC03018007F3D001F8778002J0C"
    cImgStr += "1FE03L0661800F8778001EI0C19F03J040C41I0B877800BCI0C18703I08400C3I0F8778M0CIF030030400CF800F0378002CI0EIF070020701BEI0F07F800"
    cImgStr += "380018IF06J07E1E4I0F47B80154001CJ06J03FFCCI0F0378006I018EI070101FDFC8I0F47F8002D0018FE0060103C0708I0F47FJ0C0018FFC060206C0F1"
    cImgStr += "8I0F43B8003400183FF0C0604C081CI0F4778001200180FF0D020EEI0EI0F47F8003C00300C70C0018J06I0F43B8L0383C30C00122I06I0F4778L030FC30"
    cImgStr += "C02126I06I0F4778001I030FF30C0216CI06I0FC37800240030EFF180617CI06I074378I0C006007F180216CI06I0FC3780038007001E1C011C6I06I0FC3"
    cImgStr += "7800140060F0018081EJ0CI0EC378002I060FE0180787EI0C001FC3BC001E0060FFE1C007F80C18001EC3F8002280C03FF18I03C0E3I01EC1FCI0C00E003"
    cImgStr += "F18I03FFE48001EC3BC003900CI0F1CI06IFC8I0EC19CI0400C03FF18I060638C001FC1BE002780C0IF1800340326C001F81BC001980C0FF018007C0323C"
    cImgStr += "003D81EE00340080FE01800C001B0E003D80FE00200180BFE1800C001B0E003D80DFI0C01C03FF1C00C001986003D80D6003C018003F183FCI0582007F80"
    cImgStr += "DF0023818I070832I01BC2007B80FFJ081CI08083F8I07E6007B806FK01807E60838J03FE007B006F00240180FFE0C38001E14I0FF006F002C0180IF0838"
    cImgStr += "007B0EI0F70077C0380180E7F0478006F0FI0F7003780040180E6F04E800FF0E001FF0037C02C0180E67059001FC8F005EE0033CJ01C0E7703E001F90F00"
    cImgStr += "1EE001BEJ0180E67038I0735F003EE001BC038008061701C003F31F003DE0019E02I08I07006003F09C003DC000DE01200C0E0700C003E13E007FC000DF8"
    cImgStr += "240080E0C002023E2FE0079C000EF01C00C0E7E001F81E3F800FBC0006F83I040E7FK0177F800F780006F8240040E7FL0F7F001F7800037C1E0020E67L02"
    cImgStr += "7C001FB800037E318020E67L025I03EF,001BE2400107E7L028I03EF,0019F0C00107E7L07J07DE,I0DFK0A3E7Q07DE,I0CF8M07Q0FBE,I06FBCI0500307"
    cImgStr += "IFK01FFC,I067AO07IFK01F5C,I037D2N03FBFK03EF8,I03384N03IFK07EF8,I01BD4W07D7,I019C6W0FDF,J0C9DV01FBF,J0EBW03F6E,J0607V07E7C,J0"
    cImgStr += "338CU0FEFC,J03948T01FDB8,J01C1CT03FBF8,K0CFFT07F7F,K067FT0DE6E,K071FCR01FCFE,K039FER03F9BC,K01CBFR0FF3F8,L0E7FCP01FE7F8,L072"
    cImgStr += "FEP07FCEF,L038FF8O0F79FE,L03C5FEN03FF3BC,L01E3FF8L01FFC7F8,M0F0BFF0800407FF9EF,M07C7IFJ07FFE3FE,M01E1BJF7IF78FBC,N0F87BNF1FF"
    cImgStr += "8,N07C1FDJFBF876F,N03F03FIEFFE1FFE,O0FC07KF07FFC,O07F803FFE01F6F,O01FFL0IFE,P0IFJ0FFDF8,P037LFEFE,Q0ELF7F8,Q03DJFBFE,R07BB6D"
    cImgStr += "FF8,S0KF8,T03FF,,,,"

Return cImgStr
