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

USER FUNCTION INTUY(_CodPro,_DtaAbt,_DtaPro,_DtaVal,_QtdEtq)                

    //ABRE COMUNICAÇÃO COM A TABELA SB1
    DBSelectArea('SB1')
    SB1->(DBSetOrder(1))
    SB1->(MSSeek(FWXFilial('SB1')+ALLTRIM(_CodPro)))
    //ABRE COMUNICAÇÃO COM A TABELA ZZ7
    DBSelectArea('ZZ7')
    ZZ7->(DBSetOrder(1))
    ZZ7->(MSSeek(FWXFilial('ZZ7')+ALLTRIM(_CodPro)))
    //DECLARAÇÃO DE VARIAVEIS    
    PRIVATE CodPro  := ALLTRIM(_CodPro) //Nº do código do produto    
    PRIVATE SIFPTB  := ALLTRIM(ZZ7->ZZ7_DESC) //Descrição SIF do produto em português
    PRIVATE SIFESP  := ALLTRIM(ZZ7->ZZ7_DESCE) //Descrição SIF do produto em português
    PRIVATE DescPT  := ALLTRIM(ZZ7->ZZ7_CORTE) //Descrição do produto em português
    PRIVATE DescES  := ALLTRIM(ZZ7->ZZ7_CORTEE) //Descrição do produto em português
    PRIVATE DtaAbt  := ALLTRIM(DToC(_DtaAbt)) //Data de produção
    PRIVATE DtaPro  := ALLTRIM(DToC(_DtaPro)) //Data de produção
    PRIVATE DtaVal  := ALLTRIM(DToC(_DtaVal)) //Data de validade
    PRIVATE QtdEtq  := ALLTRIM(STR(_QtdEtq))
    PRIVATE PesEmb  := 0.000
        taraSB1    := POSICIONE( 'SB1' ,1,FWXFilial( 'SB1' )+ alltrim(_CodPro), 'B1_CTARAP' ) // Linhas inseridas para buscar"_NTARAp"
	    taraZAB    := POSICIONE( 'ZAB' ,1,FWXFilial( 'ZAB' )+alltrim(taraSB1), 'ZAB_TARA' ) // os campos de codigo das taras primarias
	    PesEmb := ALLTRIM(STR((taraZAB * 1000)))
    PRIVATE CodGrp := GetAdvFval( 'SB1' , 'B1_GRUPO' ,FWxFilial( 'SB1' ) + alltrim(CodPro),1)
    PRIVATE MsgTemp := Alltrim(SB1->B1_MENETQ2)
    //PRIVATE MsgTemp := STRTRAN(ALLTRIM(SB1->B1_MENETQ2), "ºC", "\A7C")    
    PRIVATE Import := ALLTRIM(ZZ7_IMPOR)
    PRIVATE EndImp := ALLTRIM(ZZ7_ENDIMP)
    PRIVATE NumRUT := ALLTRIM(ZZ7_RUT)
    PRIVATE Monogr := ALLTRIM(ZZ7_RMONO)
    PRIVATE Rotulo := ALLTRIM(ZZ7_RROTU)

    Imprime()
RETURN

STATIC FUNCTION EtiquetasEmZPLII()
    //CABEÇALHO DA LINGUAGEM ZPL
    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWN")

    MSCBWrite("^CFA,20^FO" + "010,030" + "^FH\^FD" + SIFPTB + "^FS")
    MSCBWrite("^CFA,20^FO" + "010,060" + "^FH\^FD" + SIFESP + "^FS")
    MSCBWrite("^CFA,20^FO" + "010,090" + "^FH\^FD" + DescPT + ' | ' + DescES + "^FS")

    MSCBWrite("^CFA,20")
    IF("CELSIUS" $ MsgTemp)
        MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
        MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
    ELSEIF("CELCIUS" $ MsgTemp)
        MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
        MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
    ENDIF
    MSCBWrite("^FO" + "010,130" + "^FH\^FD" + MsgTemp + " ^FS")
    
    IF(CodGrp $ GetMV('MV_GRPMDS'))
        //MSGINFO( 'URUGUAI - Miudos', '' )
        MSCBWrite("^CFA,18")
        MSCBWrite("^FO" + "010,165" + "^FH\^FD" + 'Data de abate/Prod./Lote:' + " ^FS")
        MSCBWrite("^FO" + "010,195" + "^FH\^FD" + 'Fecha de matanza/Prod./Lote:' + " ^FS")
        MSCBWrite("^FO" + "010,225" + "^FH\^FD" + 'Data de embal.|Fecha de embalaje:' + " ^FS")
        MSCBWrite("^FO" + "010,255" + "^FH\^FD" + 'Data de validade|Fecha de validad:' + " ^FS")
        MSCBWrite("^FO" + "010,285" + "^FH\^FD" + 'Peso da embal.|Peso del paquete:' + " ^FS")
        MSCBWrite("^CFA,23")
        MSCBWrite("^FO" + "350,180" + "^FH\^FD" + DtaAbt + " ^FS")
        MSCBWrite("^FO" + "350,225" + "^FH\^FD" + DtaPro + " ^FS")
        MSCBWrite("^FO" + "350,255" + "^FH\^FD" + DtaVal + " ^FS")
        MSCBWrite("^FO" + "350,285" + "^FH\^FD" + PesEmb + "g" + " ^FS")   
    ELSEIF(CodGrp $ GetMV('MV_GRPCHRQ'))
        MSGINFO( 'Não há leyout de etiquetas para exportação para URUGUAI feita no Charque', '' )
    ELSEIF(CodGrp $ GetMV('MV_GRPPORC'))
        MSGINFO( 'Não há leyout de etiquetas para exportação para URUGUAI feita no Porcionados', '' )
    ELSE //DESOSSA
        //MSGINFO( 'URUGUAI - Desossa', '' )
        MSCBWrite("^CFA,18")
        MSCBWrite("^FO" + "010,165" + "^FH\^FD" + 'Data de abate|Fecha de matanza:' + " ^FS")        
        MSCBWrite("^FO" + "010,195" + "^FH\^FD" + 'Data de prod./Lote|Fecha de prod./Lote:' + " ^FS")        
        MSCBWrite("^FO" + "010,225" + "^FH\^FD" + 'Data de validade|Fecha de validad:' + " ^FS")
        MSCBWrite("^FO" + "010,255" + "^FH\^FD" + 'Peso da embal.|Peso del paquete:' + " ^FS")
        MSCBWrite("^CFA,23")
        MSCBWrite("^FO" + "350,165" + "^FH\^FD" + DtaAbt + " ^FS")
        MSCBWrite("^FO" + "350,195" + "^FH\^FD" + DtaPro + " ^FS")
        MSCBWrite("^FO" + "350,225" + "^FH\^FD" + DtaVal + " ^FS")
        MSCBWrite("^FO" + "350,255" + "^FH\^FD" + PesEmb + "g" + " ^FS")
    ENDIF    
    
    MSCBWrite("^FO" + "010,320" + "^FH\^FD" + "Registro no Minist\82rio da Agricultura SIF/DIPOA" + " ^FS")
    MSCBWrite("^FO" + "150,340" + "^FH\^FD" + "sob n\A7 " + ALLTRIM(ZZ7->ZZ7_MSIF) + "^FS")
    
    IF(!EMPTY(ZZ7->ZZ7_IMPOR))
        MSCBWrite("^CFA,18")
        MSCBWrite("^FO" + "010,380" + "^FH\^FD" + 'Importador: ' + Import + " ^FS")
        MSCBWrite("^FO" + "010,400" + "^FH\^FD" + 'Direcci\A2n: ' + SUBSTR(ALLTRIM(EndImp),01,33) + " ^FS")
        MSCBWrite("^FO" + "010,420" + "^FH\^FD" + SUBSTR(ALLTRIM(EndImp),34,22) + " ^FS")
        MSCBWrite("^FO" + "010,440" + "^FH\^FD" + 'N\A7 RUT: ' + NumRUT + " ^FS")
        IF (!EMPTY(ZZ7->ZZ7_RMONO))
            MSCBWrite("^FO" + "010,460" + "^FH\^FD" + 'N\A7 Reg. Monografia: ' + Monogr + " ^FS")
            MSCBWrite("^FO" + "010,480" + "^FH\^FD" + 'N\A7 Reg.: ' + Rotulo + " ^FS")
        ELSE
            MSCBWrite("^FO" + "010,460" + "^FH\^FD" + 'N\A7 Reg.: ' + Rotulo + " ^FS")
        ENDIF
    ENDIF
    
    /*
    IF(!EMPTY(ZZ7->ZZ7_IMPOR))
        MSCBWrite("^CFA,18")
        MSCBWrite("^FO" + "010,380" + "^FH\^FD" + 'Importador: ' + Import + " ^FS")
        MSCBWrite("^FO" + "010,400" + "^FH\^FD" + 'Direcci\A2n: ' + SUBSTR(ALLTRIM(EndImp),01,33) + " ^FS")
        MSCBWrite("^FO" + "010,420" + "^FH\^FD" + SUBSTR(ALLTRIM(EndImp),34,22) + " ^FS")
        MSCBWrite("^FO" + "010,440" + "^FH\^FD" + 'N\A7 RUT: ' + NumRUT + " ^FS")
        if empty(Rotulo)
            MSCBWrite("^FO" + "010,460" + "^FH\^FD" + 'N\A7 Reg.: ' + Monogr + " ^FS")
        else
            MSCBWrite("^FO" + "010,460" + "^FH\^FD" + 'N\A7 Reg. Monografia: ' + Monogr + " ^FS")
            MSCBWrite("^FO" + "010,480" + "^FH\^FD" + 'N\A7 Reg. Rotulo: ' + Rotulo + " ^FS")
        endif
    ENDIF
    */
    MSCBWrite("^CFA,50^FO" + "030,520" + "^FH\^FD" + CodPro + " ^FS")
    //CODIGO DE BARRA
    MSCBWrite("^BY3,3,50")
    MSCBWrite("^FT" + "250,550")
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
