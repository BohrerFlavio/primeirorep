#Include "TOTVS.ch"
#Include "TOPCONN.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ETQIND    ºAutor  ³Lucas Bolzan     º Data ³  20/02/24      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Etiquetas industriais                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP           .                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION ETQIND(_CodPro,_DtaAbt,_DtaPro,_DtaVal,_QtdEtq)
    //ABRE COMUNICAÇÃO COM A TABELA SB1
    DBSelectArea('SB1')
    SB1->(DBSetOrder(1))
    SB1->(MSSeek(FWXFilial('SB1')+ALLTRIM(_CodPro)))
    //ABRE COMUNICAÇÃO COM A TABELA SB1
    DBSelectArea('ZZ7')
    SB1->(DBSetOrder(1))
    SB1->(MSSeek(FWXFilial('ZZ7')+ALLTRIM(_CodPro)))
    //DECLARAÇÃO DE VARIAVEIS    
    PRIVATE CodPro  := ALLTRIM(_CodPro) //Nº do código do produto    
    PRIVATE SIFPTB  := ALLTRIM(ZZ7->ZZ7_DESC) //Descrição SIF do produto em português
    PRIVATE SIFING  := ALLTRIM(ZZ7->ZZ7_DESCI) //Descrição SIF do produto em português
    PRIVATE DescPT  := ALLTRIM(ZZ7->ZZ7_CORTE) //Descrição do produto em português
    PRIVATE DescIn  := ALLTRIM(ZZ7->ZZ7_CORTEI) //Descrição do produto em português
    PRIVATE DtaAbt  := ALLTRIM(DToC(_DtaAbt)) //Data de produção
    PRIVATE DtaPro  := ALLTRIM(DToC(_DtaPro)) //Data de produção
    PRIVATE DtaVal  := ALLTRIM(DToC(_DtaVal)) //Data de validade
    PRIVATE QtdEtq  := ALLTRIM(STR(_QtdEtq))    

    Imprime()
Return (NIL)

STATIC FUNCTION EtiquetasEmZPLII()
    //CABEÇALHO DA LINGUAGEM ZPL
    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWN")

    MSCBWrite("^CFA,20^FO" + "010,030" + "^FH\^FD" + SIFPTB + "^FS")
    MSCBWrite("^CFA,20^FO" + "010,060" + "^FH\^FD" + SIFING + "^FS")
    MSCBWrite("^CFA,20^FO" + "010,090" + "^FH\^FD" + DescPT + ' | ' + DescIn + "^FS")
    //MSCBWrite("^CFA,25^FO" + "010,120" + "^FH\^FD" + DescPT + "^FS")

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
