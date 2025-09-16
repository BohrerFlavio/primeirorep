#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  INTUY    º Autor ³ Lucas Bolzan         º Data ³  19/10/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Layout de etiquetas internas impressas na produção         º±±
±±º          ³ Etiquetas c/layout para Uruguay                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Produção                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION INTAME(_CodPro,_DtaAbt,_DtaPro,_DtaVal,_QtdEtq,_Mesa,_Lote)    
    //ABRE COMUNICAÇÃO COM A TABELA SB1
    SB1->(DBSetOrder(1))
    SB1->(MSSeek(FWXFilial('SB1')+ALLTRIM(_CodPro)))
    //ABRE COMUNICAÇÃO COM A TABELA SB1
    ZZ7->(DBSetOrder(1))
    ZZ7->(MSSeek(FWXFilial('ZZ7')+ALLTRIM(_CodPro)))
    //DECLARAÇÃO DE VARIAVEIS    
    PRIVATE CodPro  := ALLTRIM(_CodPro) //Nº do código do produto    
    PRIVATE SIFPTB  := ALLTRIM(ZZ7->ZZ7_DESC) //Descrição SIF do produto em português
    PRIVATE SIFING  := ALLTRIM(ZZ7->ZZ7_DESCI) //Descrição SIF do produto em português
    PRIVATE DescPT  := ALLTRIM(ZZ7->ZZ7_CORTE) //Descrição do produto em português
    PRIVATE DescIn  := ALLTRIM(ZZ7->ZZ7_CORTEI) //Descrição do produto em português
    PRIVATE DtaAbt  := ALLTRIM(DToC(_DtaAbt)) //Data de abate
    PRIVATE DtaPro  := ALLTRIM(DToC(_DtaPro)) //Data de produção
    PRIVATE DtaVal  := ALLTRIM(DToC(_DtaVal)) //Data de validade
    PRIVATE DtaAbtI := substr(DtaAbt,4,3)+substr(DtaAbt,1,3)+substr(DtaAbt,7,2) //Data de abate em inglês
    PRIVATE DtaProI := substr(DtaPro,4,3)+substr(DtaPro,1,3)+substr(DtaPro,7,2) //Data de produção em inglês
    PRIVATE DtaValI := substr(DtaVal,4,3)+substr(DtaVal,1,3)+substr(DtaVal,7,2) //Data de validade em inglês
    PRIVATE QtdEtq  := ALLTRIM(STR(_QtdEtq))
    PRIVATE PesEmb  := 0.000
    PRIVATE taraSB1 := GetAdvFval('SB1','B1_CTARAP',FWXFilial('SB1')+alltrim(_CodPro),1) // Linhas inseridas para buscar"_NTARAp"
	PRIVATE taraZAB := GetAdvFval('ZAB','ZAB_TARA',FWXFilial('ZAB')+alltrim(taraSB1),1) // os campos de codigo das taras primarias
	PesEmb  := ALLTRIM(STR((taraZAB * 1000)))
    PRIVATE DtaProx := StrTran(DtaPro, "/", "")
    PRIVATE CodGrp  := GetAdvFval('SB1','B1_GRUPO',FWxFilial('SB1')+alltrim(CodPro),1)
    //PRIVATE MsgTemp := STRTRAN(ALLTRIM(SB1->B1_MENETQ2), "ºC", "\A7C")
    PRIVATE MsgTemp := ALLTRIM(SB1->B1_MENETQ2)    
    PRIVATE Mesa    := _Mesa
    PRIVATE LoteUSA := _Lote 

    Imprime()
RETURN

STATIC FUNCTION EtiquetasEmZPLII()       
    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWN")

    MSCBWrite("^CFA,20^FO" + "010,030" + "^FH\^FD" + SIFPTB + "^FS")
    MSCBWrite("^CFA,20^FO" + "010,060" + "^FH\^FD" + SIFING + "^FS")
    MSCBWrite("^CFA,20^FO" + "010,090" + "^FH\^FD" + DescPT + ' | ' + DescIn + "^FS")    

    IF(CodGrp $ GetMV('MV_GRPMDS'))        
        MSCBWrite("^CFA,20")        
        MSCBWrite("^FO" + "010,120" + "^FH\^FD" + 'Data de abate/Produ\87\C6o/Lote:' + " ^FS")
        MSCBWrite("^FO" + "010,150" + "^FH\^FD" + 'Slaughter date/Production/Lot:' + " ^FS")
        MSCBWrite("^FO" + "010,180" + "^FH\^FD" + 'Data da embalagem:' + " ^FS")
        MSCBWrite("^FO" + "010,210" + "^FH\^FD" + 'Packing date:' + " ^FS")
        MSCBWrite("^FO" + "010,240" + "^FH\^FD" + 'Data de validade:' + " ^FS")
        MSCBWrite("^FO" + "010,270" + "^FH\^FD" + 'Expiry date:' + " ^FS")
        MSCBWrite("^FO" + "010,300" + "^FH\^FD" + 'Peso da embalagem:' + " ^FS")
        MSCBWrite("^FO" + "010,330" + "^FH\^FD" + 'Packing tare:' + " ^FS")

        MSCBWrite("^CFA,23")
        MSCBWrite("^FO" + "320,120" + "^FH\^FD" + DtaAbt + " ^FS")
        MSCBWrite("^FO" + "320,150" + "^FH\^FD" + DtaAbtI + " ^FS")
        MSCBWrite("^FO" + "320,180" + "^FH\^FD" + DtaPro + " ^FS")
        MSCBWrite("^FO" + "320,210" + "^FH\^FD" + DtaProI + " ^FS")
        MSCBWrite("^FO" + "320,240" + "^FH\^FD" + DtaVal + " ^FS")
        MSCBWrite("^FO" + "320,270" + "^FH\^FD" + DtaValI + " ^FS")
        MSCBWrite("^FO" + "320,315" + "^FH\^FD" + PesEmb + "g" + " ^FS")
    ELSEIF(CodGrp $ GetMV('MV_GRPCHRQ'))
        MSGINFO( 'Não há leyout de etiquetas para exportação para EUA feita no Charque', '' )
    ELSEIF(CodGrp $ GetMV('MV_GRPPORC'))
        MSGINFO( 'Não há leyout de etiquetas para exportação para EUA feita no Porcionados', '' )
    ELSE //DESOSSA        
        MSCBWrite("^CFA,20")        
        MSCBWrite("^FO" + "010,120" + "^FH\^FD" + 'Data de abate:' + " ^FS")
        MSCBWrite("^FO" + "010,150" + "^FH\^FD" + 'Slaughter date:' + " ^FS")
        MSCBWrite("^FO" + "010,180" + "^FH\^FD" + 'Data de produ\87\C6o/Lote:' + " ^FS")
        MSCBWrite("^FO" + "010,210" + "^FH\^FD" + 'Production date/Lot:' + " ^FS")
        MSCBWrite("^FO" + "010,240" + "^FH\^FD" + 'Data de validade:' + " ^FS")
        MSCBWrite("^FO" + "010,270" + "^FH\^FD" + 'Expiry date:' + " ^FS")
        MSCBWrite("^FO" + "010,300" + "^FH\^FD" + 'Peso da embalagem:' + " ^FS")
        MSCBWrite("^FO" + "010,330" + "^FH\^FD" + 'Packing tare:' + " ^FS")        
        MSCBWrite("^FO" + "320,120" + "^FH\^FD" + DtaAbt + " ^FS")
        MSCBWrite("^FO" + "320,150" + "^FH\^FD" + DtaAbtI + " ^FS")
        MSCBWrite("^FO" + "320,180" + "^FH\^FD" + DtaPro + " ^FS")
        MSCBWrite("^FO" + "320,210" + "^FH\^FD" + DtaProI + " ^FS")
        MSCBWrite("^FO" + "320,240" + "^FH\^FD" + DtaVal + " ^FS")
        MSCBWrite("^FO" + "320,270" + "^FH\^FD" + DtaValI + " ^FS")
        MSCBWrite("^FO" + "320,300" + "^FH\^FD" + PesEmb + "g" + " ^FS")
        MSCBWrite("^FO" + "320,330" + "^FH\^FD" + PesEmb + "g" + " ^FS")
    ENDIF
    
    if empty(LoteUSA)
        //MSCBWrite("^FO" + "010,360" + "^FH\^FD" + "LOTE/LOT: " + "D"+ DtaProx + "P" + CodPro + "0" + Mesa + "^FS")
    else
        if !(CodGrp $ GetMV('MV_GRPMDS') .OR. CodGrp $ GetMV('MV_GRPCHRQ') .OR. CodGrp $ GetMV('MV_GRPPORC'))
            MSCBWrite("^FO" + "010,360" + "^FH\^FD" + "LOTE/LOT: " + LoteUSA + "^FS")
        endif
    endif
    
    MSCBWrite("^CFA,18")
    IF("CELSIUS" $ MsgTemp)
        MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
        MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
    ELSEIF("CELCIUS" $ MsgTemp)
        MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
        MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
    ENDIF
    MSCBWrite("^FO" + "010,385" + "^FH\^FD" + MsgTemp + "^FS")
    MSCBWrite("^FO" + "010,407" + "^FH\^FD" + "KEEP FROZEN AT -18 \A7C" + "^FS")

    MSCBWrite("^FO" + "010,425" + "^FH\^FD" + "Origin: PRODUCT OF BRAZIL" + "^FS")
    MSCBWrite("^FO" + "010,448" + "^FH\^FD" + "Registro no Minist\82rio da Agricultura" + " ^FS")
    MSCBWrite("^FO" + "010,471" + "^FH\^FD" + "SIF/DIPOA sob n\A7 " + ALLTRIM(ZZ7->ZZ7_MSIF) + "^FS")

    MSCBWrite("^CFA,50^FO" + "030,520" + "^FH\^FD" + CodPro + " ^FS")
    //CODIGO DE BARRA
    MSCBWrite("^BY3,3,50")
    MSCBWrite("^FT" + "250,540")
    MSCBWrite("^BCN,,N,N")
    MSCBWrite("^FD>;" + ZZ7->ZZ7_CODPRO + "^FS")
    //ENCERRA LINGUAGEM ZPL
    MSCBWrite("^PQ" + QtdEtq + ",0,1,N")
    MSCBWrite("^XZ")
RETURN

STATIC FUNCTION Imprime()
    incproc()

    _cEst := getComputerName()
	_cIp  := ''

	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	IF ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	ENDIF
	
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

    EtiquetasEmZPLII()
    
    MSCBEND()
	MSCBCLOSEPRINTER()
RETURN
