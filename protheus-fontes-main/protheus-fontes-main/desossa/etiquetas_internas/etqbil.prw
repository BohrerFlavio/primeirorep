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

USER FUNCTION ETQBIL(_DtaProI,_QtdEtq, _Lote,_Peso,_DtaProF)

    PRIVATE DtaProIni  := ALLTRIM(DToC(_DtaProI))
    PRIVATE DtaProFim  := ALLTRIM(DToC(_DtaProF))
    PRIVATE DtaValIni  := ALLTRIM(DToC(_DtaProI + 180))
    PRIVATE DtaValFim  := ALLTRIM(DToC(_DtaProF + 180))
    PRIVATE Lote   := ALLTRIM(_Lote)
    PRIVATE Peso   := _Peso
    PRIVATE QtdEtq := _QtdEtq

    Imprime()
RETURN

STATIC FUNCTION EtiquetasEmZPLII()
    //CABEÇALHO DA LINGUAGEM ZPL
    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:arialbd.TTF")
    MSCBWrite("^FWR")
    MSCBWrite("^CFA,50^FO 580,410 ^FH\^FD BILE CONSERVADA DE BOVINO ^FS")

    MSCBWrite("^CWA,E:arial.TTF")
    MSCBWrite("^FWR")
    MSCBWrite("^CFA,25^FO 530,030 ^FH\^FD DATA DE PRODU\80\C7O: ^FS")
    MSCBWrite("^CFA,25^FO 490,035 ^FH\^FD" + DtaProIni + ' at\82 ' +  DtaProFim + "^FS")
    MSCBWrite("^FO 480,030")
    MSCBWrite("^GB 050,300,2^FS")

    MSCBWrite("^CFA,25^FO 530,350 ^FH\^FD LOTE: ^FS")
    MSCBWrite("^CFA,25^FO 490,355 ^FH\^FD" + Lote + " ^FS")
    MSCBWrite("^FO 480,350")
    MSCBWrite("^GB 050,300,2^FS")

    MSCBWrite("^CFA,25^FO 450,030 ^FH\^FD V\B5LIDO AT\90: ^FS")
    MSCBWrite("^CFA,25^FO 410,035 ^FH\^FD" + DtaValIni + ' at\82 ' +  DtaValFim + "^FS")    
    MSCBWrite("^FO 400,030")
    MSCBWrite("^GB 050,300,2^FS")

    MSCBWrite("^CFA,25^FO 450,350 ^FH\^FD PESO L\D6QUIDO: ^FS")
    MSCBWrite("^CFA,25^FO 410,355 ^FH\^FD" + AllTrim(StrTran(Peso,".",",")) + ' Kg' + "^FS")
    MSCBWrite("^FO 400,350")
    MSCBWrite("^GB 050,300,2^FS")

    MSCBWrite("^CFA,25^FO 265,040 ^FH\^FD FRIGOR\D6FICO SILVA IND\E9STRIA E COM\90RCIO LTDA ^FS")
    MSCBWrite("^CFA,25^FO 240,040 ^FH\^FD IND\E9STRIA E COM\90RCIO DE CARNES E SEUS DERIVADOS ^FS")
    MSCBWrite("^CFA,25^FO 215,040 ^FH\^FD ABATEDOURO FRIGOR\D6FICO ^FS")
    MSCBWrite("^CFA,25^FO 190,040 ^FH\^FD BR 392 - KM8 - BAIRRO TOMAZETTI - FONE (55)21032525 ^FS")
    MSCBWrite("^CFA,25^FO 165,040 ^FH\^FD FAX: (55)2103 2505 - SANTA MARIA - RS BRASIL CNPJ: 88.728.027/0001-46 ^FS")
    MSCBWrite("^CFA,25^FO 140,040 ^FH\^FD INSC. EST. 109.0096949 IND\E9STRIA BRASILEIRA ^FS")

    MSCBWrite("^CFA,25^FO 115,040 ^FH\^FD PRODUTO ISENTO DE REGISTRO NO MINIST\90RIO DA AGRICULTURA, PECU\B5RIA E ABASTECIMENTO ^FS")

    MSCBWrite("^CFA,20^FO 090,500 ^FH\^FD Ingredientes: Bile de bovino e Formol ^FS")

    MSCBWrite("^CFA,25^FO 065,350 ^FH\^FD CONSERVAR EM TEMPERATURA AMBIENTE ^FS")

    MSCBWrite("^CFA,25^FO 040,500 ^FH\^FD N\C7O COMEST\D6VEL ^FS")

    MSCBWrite("^FO 290,300")
    MSCBWrite("^IME:LOGO_BESTBEEF.GRF,1,1^FS")

    MSCBWrite("^FO 200,990")
    MSCBWrite("^IME:LOGO_SIFM4.GRF,1,1^FS")

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
