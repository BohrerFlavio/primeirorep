#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI188  º Autor ³ Lucas Bolzan         º Data ³  19/10/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Layout de etiquetas testeiras impressas na embalagem       º±±
±±º          ³ Etiquetas c/layout para EUA                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ EMBALAGEM                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION INTUSA(_CodPro,_DtaAbt,_DtaPro,_DtaVal,_QtdEtq)                

    //ABRE COMUNICAÇÃO COM A TABELA SB1
    DBSelectArea('SB1')
    SB1->(DBSetOrder(1))
    SB1->(MSSeek(FWXFilial('SB1')+ALLTRIM(_CodPro)))
    //DECLARAÇÃO DE VARIAVEIS        
    PRIVATE CodPro  := ALLTRIM(_CodPro) //Nº do código do produto    
    PRIVATE SIFPTB  := ALLTRIM(SB1->B1_DESCSIF) //Descrição SIF do produto em português
    PRIVATE SIFING  := ALLTRIM(SB1->B1_DINGLES) //Descrição SIF do produto em ingles    
    PRIVATE DescPT  := ALLTRIM(SB1->B1_DESC) //Descrição do produto em português
    PRIVATE DescING := ALLTRIM(SB1->B1_DESCING) //Descrição do produto em ingles    
    PRIVATE DtaPro  := ALLTRIM(DToC(_DtaPro)) //Data de produção    
    PRIVATE DtaProI := SUBSTR(DToC(_DtaPro),4,3)+SUBSTR(DToC(_DtaPro),1,3)+SUBSTR(DToC(_DtaPro),7,2)
    PRIVATE DtaValI := SUBSTR(DToC(_DtaVal),4,3)+SUBSTR(DToC(_DtaVal),1,3)+SUBSTR(DToC(_DtaVal),7,2)
    PRIVATE DtaVal  := ALLTRIM(DToC(_DtaVal)) //Data de validade
    PRIVATE QtdEtq  := ALLTRIM(STR(_QtdEtq))

    PRIVATE PesEmb  := 0.000
        taraSB1    := POSICIONE( 'SB1' ,1,FWXFilial( 'SB1' )+ alltrim(_CodPro), 'B1_CTARAP' ) // Linhas inseridas para buscar"_NTARAp"
	    taraZAB    := POSICIONE( 'ZAB' ,1,FWXFilial( 'ZAB' )+alltrim(taraSB1), 'ZAB_TARA' ) // os campos de codigo das taras primarias
	    PesEmb := ALLTRIM(STR((taraZAB * 1000)))

    //PRIVATE LoteEUA := GetAdvFVal( 'SZU' , 'ZU_LOTEUA' ,FWXFilial( 'SZU' )+ALLTRIM(SZ8->Z8_NUMPREV),2) //Nº lote para EUA    
    PRIVATE MsgTemp := STRTRAN(ALLTRIM(SB1->B1_MENETQ2), "ºC", "\A7C")

    Imprime()
RETURN

STATIC FUNCTION EtiquetasEmZPLII()
    //CABEÇALHO DA LINGUAGEM ZPL
    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWR")
    MSCBWrite("^CFA,25")    
    MSCBWrite("^FO" + "600,020" + "^FH\^FD" + SIFPTB + "^FS")
    MSCBWrite("^FO" + "570,020" + "^FH\^FD" + SIFING + "^FS")    
    MSCBWrite("^FO" + "500,020" + "^FH\^FD DATA DE PRODU\80\B6O: " + " ^FS")
    MSCBWrite("^FO" + "470,020" + "^FH\^FD PRODUCTION DATE: " + " ^FS")
    MSCBWrite("^FO" + "440,020" + "^FH\^FD DATA DE VALIDADE: " + " ^FS")
    MSCBWrite("^FO" + "410,020" + "^FH\^FD EXPIRITY DATE: ^FS")    
    MSCBWrite("^FO" + "500,300" + "^FH\^FD " + DtaPro + "^FS")
    MSCBWrite("^FO" + "470,300" + "^FH\^FD " + DtaProI + "^FS")
    MSCBWrite("^FO" + "440,300" + "^FH\^FD " + DtaVal + "^FS")
    MSCBWrite("^FO" + "410,300" + "^FH\^FD " + DtaValI + "^FS")
    MSCBWrite("^CFA,20")
    MSCBWrite("^FO" + "350,020" + "^FH\^FD PESO DA EMBALAGEM | PACKING TARE: " + PesEmb + 'g' + "^FS")
    MSCBWrite("^FO" + "300,020" + "^FH\^FD LOTE | LOT: " + 'AINDA A DEFINIR' + "^FS")
    MSCBWrite("^FO" + "250,100" + "^FH\^FD N\C7O CONT\90M GLUT\90N | GLUTEN FREE ^FS")
    MSCBWrite("^FO" + "220,100" + "^FH\^FD"  + MsgTemp + "^FS")
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "120,110" + "^FH\^FD" + " Registro no Minist\82rio da Agricultura SIF/DIPOA sob n\A7 0097/1733 " + " ^FS")
    MSCBWrite("^FO" + "121,110" + "^FH\^FD" + " Registro no Minist\82rio da Agricultura SIF/DIPOA sob n\A7 0097/1733 " + " ^FS")
    MSCBWrite("^FO" + "122,110" + "^FH\^FD" + " Registro no Minist\82rio da Agricultura SIF/DIPOA sob n\A7 0097/1733 " + " ^FS")
    MSCBWrite("^CFA,20")
    MSCBWrite("^FO" + "090,020" + "^FH\^FD" + "FRIGOR\D6FICO SILVA IND\E9STRIA E COM\90RCIO LTDA Abatedouro e Frigor\A1fico Ind. e Com. de Carnes" + " ^FS")
    MSCBWrite("^FO" + "060,020" + "^FH\^FD" + "e sus Derivados. BR 392 - Km 8, Tomazetti - Santa Maria / RS Brasil, CEP: 97.065-400. IE: 109/0096949" + " ^FS")
    MSCBWrite("^FO" + "030,020" + "^FH\^FD" + "CNPJ: 88.728.027/0001-46 IND\E9STRIA BRASILEIRA" + " ^FS")
    //IMAGEM LOGO SIF
    MSCBWrite("^FO" + "130,450")
    MSCBWrite("^IME:LOGOSIF.GRF,1,1")
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
