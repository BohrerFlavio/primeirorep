/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI208            º Autor ³ Lucas Bolzan º Data ³ 22/03/24  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de etiqueta                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desossa                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "COLORS.ch"

USER FUNCTION ETQTRI(_cProd, _DtaPro,_QtdEtq, _Lote,_Maco,_Msif, _nTaraProd)

    PRIVATE CodProd := ALLTRIM(_cProd)
    PRIVATE DtaPro  := ALLTRIM(DToC(_DtaPro))
    PRIVATE DtaVal  := ALLTRIM(DToC(_DtaPro + GetAdvFval('SB1','B1_VALID',FWXFilial('SB1') + CodProd,1,'Sem informação',.t.)))
    PRIVATE Lote    := ALLTRIM(_Lote)
    PRIVATE Maco   := _Maco
    PRIVATE QtdEtq  := _QtdEtq
    PRIVATE Msif  := ALLTRIM(_Msif)

    Imprime()
RETURN

STATIC FUNCTION EtiquetasEmZPLII()
    //CABEÇALHO DA LINGUAGEM ZPL
    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:arialbd.TTF")
    MSCBWrite("^FWR")
    MSCBWrite("^CFA,43^FO 580,040 ^FH\^FD ENVOLT\E3RIOS NATURAIS SALGADOS DE BOVINO ^FS")

    MSCBWrite("^CWA,E:arial.TTF")    
    MSCBWrite("^CFA,26^FO 540,040 ^FH\^FD REGISTRO NO MINIST\90RIO DA AGRICULTURA SIF/DIPOA SOB N\A7 "+Msif+" ^FS")

    MSCBWrite("^CFA,25^FO 510,040 ^FH\^FD DATA DE PRODU\80\C7O: ^FS")
    MSCBWrite("^CFA,25^FO 470,045 ^FH\^FD" + DtaPro + " ^FS")
    MSCBWrite("^FO 460,040")
    MSCBWrite("^GB 050,300,2^FS")

    MSCBWrite("^CFA,25^FO 510,350 ^FH\^FD LOTE: ^FS")    
    MSCBWrite("^CFA,25^FO 470,355 ^FH\^FD" + Lote + " ^FS")
    MSCBWrite("^FO 460,350")
    MSCBWrite("^GB 050,300,2^FS")

    MSCBWrite("^CFA,25^FO 430,040 ^FH\^FD V\B5LIDO AT\90: ^FS")
    MSCBWrite("^CFA,25^FO 390,045 ^FH\^FD" + DtaVal + " ^FS")
    MSCBWrite("^FO 380,040")
    MSCBWrite("^GB 050,300,2^FS")

    MSCBWrite("^CFA,25^FO 430,350 ^FH\^FD N\A7 MA\80OS: ^FS")
    MSCBWrite("^CFA,25^FO 390,355 ^FH\^FD" + AllTrim(Maco) + "^FS")
    MSCBWrite("^FO 380,350")
    MSCBWrite("^GB 050,300,2^FS")    

    MSCBWrite("^CFA,25^FO 350,040 ^FH\^FD PESO EMBALAGEM: " + AllTrim(STR(_nTaraProd)) + " Kg ^FS")
    
    MSCBWrite("^CFA,20^FO 320,040 ^FH\^FD FRIGOR\D6FICO SILVA IND\E9STRIA E COM\90RCIO LTDA ^FS")
    MSCBWrite("^CFA,20^FO 290,040 ^FH\^FD IND\E9STRIA E COM\90RCIO DE CARNES E SEUS DERIVADOS ^FS")
    MSCBWrite("^CFA,20^FO 260,040 ^FH\^FD ABATEDOURO FRIGOR\D6FICO ^FS")
    MSCBWrite("^CFA,20^FO 230,040 ^FH\^FD BR 392 - KM8 - BAIRRO TOMAZETTI - SANTA MARIA - RS BRASIL ^FS")
    MSCBWrite("^CFA,20^FO 200,040 ^FH\^FD  CEP: 97065-400 FONE (55)21032525 FAX: (55)2103 2505  ^FS")
    MSCBWrite("^CFA,20^FO 170,040 ^FH\^FD CNPJ: 88.728.027/0001-46 INSC. EST: 109.0096949 ^FS")
    MSCBWrite("^CFA,20^FO 140,040 ^FH\^FD IND\E9STRIA BRASILEIRA ^FS")

    MSCBWrite("^CWA,E:arialbd.TTF")
    MSCBWrite("^CFA,30^FO 110,180 ^FH\^FD N\C7O CONT\90M GL\E9TEN ^FS")
    MSCBWrite("^CFA,20^FO 080,040 ^FH\^FD INGREDIENTES: ENVOLT\E3RIOS NATURAIS DE BOVINO (TRIPA) ^FS")
    MSCBWrite("^CFA,20^FO 050,240 ^FH\^FD CLORETO DE S\E3DIO (SAL) ^FS")
    MSCBWrite("^CFA,20^FO 020,080 ^FH\^FD  DEVE SER ABERTO NA PRESEN\80A DO CONSUMIDOR ^FS")
    
    MSCBWrite("^FO 120,950")
    MSCBWrite("^IME:LOGOSIF.GRF,1,1^FS")

    MSCBWrite("^FO 001,990")
    MSCBWrite("^IME:LOGO_FRIGORIFICO_SILVA.GRF,1,1^FS")

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
