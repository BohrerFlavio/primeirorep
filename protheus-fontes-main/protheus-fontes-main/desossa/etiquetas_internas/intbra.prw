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

USER FUNCTION INTBRA(_CodPro,_DtaAbt,_DtaPro,_DtaVal,_QtdEtq)
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
    PRIVATE DescPT  := ALLTRIM(ZZ7->ZZ7_CORTE) //Descrição do produto em português
    PRIVATE Obser3  := ALLTRIM(ZZ7->ZZ7_INGRE2)
    PRIVATE Absorv  := ALLTRIM(ZZ7->ZZ7_ABSORV) //Se tem uso de absorvente
    PRIVATE DtaAbt  := ALLTRIM(DToC(_DtaAbt)) //Data de produção
    PRIVATE DtaPro  := ALLTRIM(DToC(_DtaPro)) //Data de produção
    PRIVATE DtaVal  := ALLTRIM(DToC(_DtaVal)) //Data de validade    
    PRIVATE QtdEtq  := ALLTRIM(STR(_QtdEtq))
    PRIVATE PesEmb  := 0.000
    PRIVATE CodGrp  := SB1->B1_GRUPO
    PRIVATE MsgTemp := Alltrim(SB1->B1_MENETQ2)
    // Linhas inseridas para buscar"_NTARAp"
    taraSB1 := SB1->B1_CTARAP
	taraZAB := GetAdvFVal('ZAB','ZAB_TARA',FWXFilial('ZAB')+alltrim(taraSB1),1) // os campos de codigo das taras primarias
	PesEmb := ALLTRIM(STR((taraZAB * 1000)))

    Imprime()    
RETURN

STATIC FUNCTION EtiquetasEmZPLII()    
    //CABEÇALHO DA LINGUAGEM ZPL
    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWN")

    MSCBWrite("^CFA,20^FO" + "010,030" + "^FH\^FD" + SIFPTB + "^FS")

    IF (CodGrp $ GetMV('MV_GRPPORC') .AND. !Empty(ZZ7->ZZ7_INGRE2))
        MSCBWrite("^CFA,20^FO" + "010,060" + "^FH\^FD" + DescPT + "^FS")
        MSCBWrite("^CFA,20^FO" + "010,090" + "^FH\^FD" + "M\A0ximo " + Obser3 + " de gordura" + "^FS")
    ELSEIF (!CodGrp $ GetMV('MV_GRPPORC') .AND. !Empty(ZZ7->ZZ7_INGRE2))
        MSCBWrite("^CFA,20^FO" + "010,060" + "^FH\^FD" + DescPT + "^FS")
        MSCBWrite("^CFA,20^FO" + "010,090" + "^FH\^FD" + Obser3+ "^FS")
    ELSE
        MSCBWrite("^CFA,20^FO" + "010,060" + "^FH\^FD" + DescPT + "^FS")
    ENDIF

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
        //MSGINFO( 'BRASIL - Miudos', '' )
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "010,165" + "^FH\^FD" + 'Data de abate/Produ\87\C6o/Lote:' + " ^FS")
        MSCBWrite("^FO" + "010,195" + "^FH\^FD" + 'Data da embalagem:' + "^FS")
        MSCBWrite("^FO" + "010,225" + "^FH\^FD" + 'Data de validade:' + "^FS")
        MSCBWrite("^FO" + "010,255" + "^FH\^FD" + 'Tara da embalagem:' + "^FS")
        MSCBWrite("^CFA,25")
        MSCBWrite("^FO" + "300,165" + "^FH\^FD" + DtaAbt + "^FS")
        MSCBWrite("^FO" + "300,195" + "^FH\^FD" + DtaPro + "^FS")
        MSCBWrite("^FO" + "300,225" + "^FH\^FD" + DtaVal + "^FS")
        MSCBWrite("^FO" + "300,255" + "^FH\^FD" + PesEmb + "g" + "^FS")
    ELSEIF(CodGrp $ GetMV('MV_GRPCHRQ'))
        //MSGINFO( 'BRASIL - Charque', '' )
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "010,100" + "^FH\^FD" + 'Data de Produ\87\C6o/Lote:' + " ^FS")        
        MSCBWrite("^FO" + "010,130" + "^FH\^FD" + 'Data de validade:' + " ^FS")
        MSCBWrite("^FO" + "010,160" + "^FH\^FD" + 'Tara da embalegem:' + " ^FS")
        MSCBWrite("^CFA,25")
        MSCBWrite("^FO" + "250,100" + "^FH\^FD" + DtaPro + " ^FS")
        MSCBWrite("^FO" + "250,130" + "^FH\^FD" + DtaVal + " ^FS")
        MSCBWrite("^FO" + "250,160" + "^FH\^FD" + PesEmb + "g" + " ^FS")        
    ELSEIF(CodGrp $ GetMV('MV_GRPPORC'))
        //MSGINFO( 'BRASIL - Porcionados', '' )
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "010,170" + "^FH\^FD" + 'Data de produ\87\C6o/Lote:' + " ^FS")
        MSCBWrite("^FO" + "010,200" + "^FH\^FD" + 'Data de validade:' + " ^FS")
        MSCBWrite("^FO" + "010,230" + "^FH\^FD" + 'Tara da embalagem:' + " ^FS")
        MSCBWrite("^CFA,25")        
        MSCBWrite("^FO" + "300,170" + "^FH\^FD" + DtaPro + " ^FS")
        MSCBWrite("^FO" + "300,200" + "^FH\^FD" + DtaVal + " ^FS")
        MSCBWrite("^FO" + "300,230" + "^FH\^FD" + PesEmb + "g" + " ^FS")

        MSCBWrite("^CFA,20")        
        IF (ZZ7->ZZ7_CONSU = '1')
            MSCBWrite("^FO" + "010,340" + "^FH\^FD" + "Ap\A2s aberto consumir em at\82 2 (dois) dias" + " ^FS")
        ENDIF

        IF (!EMPTY(ZZ7->ZZ7_INGRED))
            MSCBWrite("^FO" + "010,370" + "^FH\^FD" + "Ingredientes: " + Alltrim(ZZ7->ZZ7_INGRED) + " ^FS")
        ENDIF

        IF (!EMPTY(ZZ7->ZZ7_MSGVAR))
            MSCBWrite("^FO" + "010,400" + "^FH\^FD" + Alltrim(ZZ7->ZZ7_MSGVAR) + " ^FS")
        ENDIF

        IF (!EMPTY(ZZ7->ZZ7_TRAJ))
            MSCBWrite("^FO" + "010,430" + "^FH\^FD" + Alltrim(ZZ7->ZZ7_TRAJ) + " ^FS")
        ENDIF
    ELSE //DESOSSA
        //MSGINFO( 'BRASIL - Desossa', '' )
        MSCBWrite("^CFA,20")
        MSCBWrite("^FO" + "010,165" + "^FH\^FD" + 'Data de abate:' + " ^FS")
        MSCBWrite("^FO" + "010,195" + "^FH\^FD" + 'Data de produ\87\C6o/Lote:' + " ^FS")
        MSCBWrite("^FO" + "010,225" + "^FH\^FD" + 'Data de validade:' + " ^FS")
        MSCBWrite("^FO" + "010,255" + "^FH\^FD" + 'Tara da embalagem:' + " ^FS")
        MSCBWrite("^CFA,25")
        MSCBWrite("^FO" + "250,165" + "^FH\^FD" + DtaAbt + " ^FS")
        MSCBWrite("^FO" + "250,195" + "^FH\^FD" + DtaPro + " ^FS")
        MSCBWrite("^FO" + "250,225" + "^FH\^FD" + DtaVal + " ^FS")
        MSCBWrite("^FO" + "250,255" + "^FH\^FD" + PesEmb + "g" + " ^FS")
    ENDIF

    MSCBWrite("^CFA,20") 
    MSCBWrite("^FO" + "010,280" + "^FH\^FD" + "Registro no Minist\82rio da Agricultura SIF/DIPOA" + " ^FS")
    MSCBWrite("^FO" + "150,310" + "^FH\^FD" + "sob n\A7 " + ALLTRIM(ZZ7->ZZ7_MSIF) + "^FS")

    if Absorv = '1'
        MSCBWrite("^FO" + "010,340" + "^FH\^FD" + "Retirar o absorvedor antes do preparo" + " ^FS")
    endif

    MSCBWrite("^CFA,50^FO" + "030,455" + "^FH\^FD" + CodPro + " ^FS")    
    //CODIGO DE BARRA
    MSCBWrite("^BY3,3,50")
    MSCBWrite("^FT" + "250,500")
    MSCBWrite("^BCN,,Y,N")
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
