#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"

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

USER FUNCTION EMBUSA(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_cSeq,_Hora)        
    DBSelectArea('SB1')
    SB1->(DBSetOrder(1))
    SB1->(MSSeek(FWXFilial('SB1')+ALLTRIM(_cod)))
    DBSelectArea('ZZ7')
    ZZ7->(DBSetOrder(1))
    ZZ7->(MSSeek(FWXFilial('SB1')+ALLTRIM(_cod)))
    //DECLARAÇÃO DE VARIAVEIS
    PRIVATE TT1POR  := "Data de produ\87\C6o:"              //"Data de produ\87\C6o/Lote:"
    PRIVATE TT1ING  := "Production date:"                   //"Production date/Lot:"
    PRIVATE TT2POR  := "Data de congelamento:"
    PRIVATE TT2ING  := "Freezing date:"
    PRIVATE TT3POR  := "Data de validade:"
    PRIVATE TT3ING  := "Best before:"
    PRIVATE TT4POR  := "Data de embalagem:"
    PRIVATE TT4ING  := "Packing date:"
    PRIVATE TT5POR  := "Manter congelado a:"
    PRIVATE TT5ING  := "Keep frozen at:"
    PRIVATE TT6POR  := "Peso bruto:"
    PRIVATE TT6ING  := "Gross weight:"
    PRIVATE TT7POR  := "Peso l\A1quido:"
    PRIVATE TT7ING  := "Net weight:"
    PRIVATE TT8POR  := "Tara da embalagem:"
    PRIVATE TT8ING  := "Packing tare:"
    PRIVATE TT9POR  := "Tara da caixa:"
    PRIVATE TT9ING  := "Box Tare:"
    PRIVATE TT10POR := "Quantidade:"
    PRIVATE TT10ING := "Quantity:"
    PRIVATE TT11POR := "Rastreabilidade:"
    PRIVATE TT11ING := "Traceability:"
    PRIVATE TT12POR := "Hora:"
    PRIVATE TT12ING := "Hour:"

    PRIVATE NumCxa  := ALLTRIM(_control) //Nº da caixa
    PRIVATE NumPEt  := ALLTRIM(GetAdvFVal('SZ8','Z8_SEQPETQ',FWXFilial('SZ8')+ _control,3)) //Nº da pré-etiqueta
    PRIVATE CodPro  := ALLTRIM(_cod) //Nº do código do produto
    PRIVATE Mercad  := ALLTRIM(SB1->B1_CADMERC) //Mercado do produto
    PRIVATE Destin  := ALLTRIM(SB1->B1_DESTINO) //Destino do produto
    PRIVATE SIFPTB  := ALLTRIM(SB1->B1_DESCSIF) //Descrição SIF do produto em português
    PRIVATE SIFING  := ALLTRIM(SB1->B1_DINGLES) //Descrição SIF do produto em ingles
    PRIVATE SIFESP  := ALLTRIM(SB1->B1_DESPANH) //Descrição SIF do produto em espanhol
    PRIVATE DescPT  := ALLTRIM(SB1->B1_DESC) //Descrição do produto em português
    PRIVATE DescING := ALLTRIM(SB1->B1_DESCING) //Descrição do produto em ingles
    PRIVATE DescESP := ALLTRIM(SB1->B1_DESCESP) //Descrição do produto em espanhol    
    PRIVATE CortePT := ALLTRIM(ZZ7->ZZ7_CORTE) //Descrição do produto em português
    PRIVATE CorteIN := ALLTRIM(ZZ7->ZZ7_CORTEI) //Descrição do produto em ingles
    PRIVATE CorteES := ALLTRIM(ZZ7->ZZ7_CORTEE) //Descrição do produto em espanhol    
    PRIVATE DtaCon  := ALLTRIM(DToC(_datap + 2)) //Data de congelamento. Esta data será dois dias após a produção
    PRIVATE DtaPro  := ALLTRIM(DToC(_datap)) //Data de produção
    PRIVATE DtaConI := SUBSTR(DToC(_datap + 2),4,3)+SUBSTR(DToC(_datap + 2),1,3)+SUBSTR(DToC(_datap + 2),7,2)
    PRIVATE DtaProI := SUBSTR(DToC(_datap),4,3)+SUBSTR(DToC(_datap),1,3)+SUBSTR(DToC(_datap),7,2)
    PRIVATE DtaValI := SUBSTR(DToC(_dataval),4,3)+SUBSTR(DToC(_dataval),1,3)+SUBSTR(DToC(_dataval),7,2)
    PRIVATE DtaVal  := ALLTRIM(DToC(_dataval)) //Data de validade
    PRIVATE DtaAbt  := DToC(GetAdvFVal( 'SZU' , 'ZU_DTABT' ,FWXFilial( 'SZU' )+ALLTRIM(SZ8->Z8_NUMPREV),2)) //Data de abate
    PRIVATE PesoBr  := TRANSFORM(_pesob, '@E 99.999' ) //Peso bruto já formatado para impressão
    PRIVATE PesoLi  := TRANSFORM(_pesol, '@E 99.999' ) //Peso liquido já formatado para impressão
    PRIVATE nPesoBr := _pesob //Peso bruto
    PRIVATE nPesoLi := _pesol //Peso líquido
    PRIVATE vTarPri := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB') + ALLTRIM(SB1->B1_CTARAP),1)    
    PRIVATE cTarPri := TRANSFORM(_quant * vTarPri,'@E ##.###')
    PRIVATE cTaraPr := STRTRAN(cTarPri,',','.')
    PRIVATE vTarSec := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+alltrim(SB1->B1_CTARASE),1)
    PRIVATE cTarSec := TRANSFORM(vTarSec,'@E ##.###')
    PRIVATE cTaraSe := STRTRAN(cTarSec,',','.')    
    PRIVATE Quanti  := _quant //Quantidade de peças na caixa
    PRIVATE Hora    := ALLTRIM(_Hora) //Horário
    PRIVATE LoteEUA := GetAdvFVal( 'SZU' , 'ZU_LOTEUA' ,FWXFilial( 'SZU' )+ALLTRIM(SZ8->Z8_NUMPREV),2) //Nº lote para EUA
    //PRIVATE QtdCXA  := ALLTRIM(STR(GetAdvFVal( 'ZZR' , 'ZZR_QTDCX' ,FWXFilial( 'ZZR' )+ _control,4))) //Quantidade da caixa
    PRIVATE QtdCXA  := ALLTRIM(STR(GetAdvFVal('SZ8','Z8_QUANT',FWXFilial('SZ8') + _control,3)))
    PRIVATE Rastre  := '1733' + STRTRAN(DtaAbt, "/", "",) + '0000' //Codigo rastreabilidade
    PRIVATE MsgTemp := ALLTRIM(SB1->B1_MENETQ2)
    PRIVATE Modelo  := _modelo
    PRIVATE Portap  := _porta
    PRIVATE IPprint := _IP
    PRIVATE _cMSif  := AllTrim(ZZ7->ZZ7_MSIF)
    PRIVATE _cShipM := GetAdvFVal('SZU','ZU_SHIPPIN',FWXFilial('SZU')+ALLTRIM(SZ8->Z8_NUMPREV),2)

    Imprime()
RETURN

STATIC FUNCTION EtiquetasEmZPLII()
    //CABEÇALHO DA LINGUAGEM ZPL
    MSCBWrite("^XA")
    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWR")
    MSCBWrite("^CFA,25")
    //INSERE DESCRIÇÂO SIF DOS PRODUTOS
    MSCBWrite("^FO" + "780,0550" + "^FH\^FD" + SIFING + "^FS")
    MSCBWrite("^FO" + "750,0550" + "^FH\^FD" + SIFPTB + "^FS")
    MSCBWrite("^FO" + "720,0550" + "^FH\^FD" + CortePT + "^FS")
    MSCBWrite("^FO" + "690,0550" + "^FH\^FD" + CorteIN + "^FS")
    MSCBWrite("^FO" + "660,0550" + "^FH\^FD" + "PRODUCT OF BRAZIL" + "^FS")
    MSCBWrite("^FO" + "630,0550" + "^FH\^FD" + "Batch/Lote: " + LoteEUA + "^FS")
    MSCBWrite("^FO" + "630,1300" + "^FH\^FD" + NumCxa + "^FS")
    //DESTINO DO PRODUTO EM FUNDO PRETO
    MSCBWrite("^LRY")
    MSCBWrite("^FO" + "730,1300")
    MSCBWrite("^GB" + "000,150,070" + "^FS")
    MSCBWrite("^FO" + "730,1350" + "^CFG")
    MSCBWrite("^FD" + Destin + "^FS")
    //INSERE LINHA HORIZONTAL
    MSCBWrite("^FO" + "620,550")
    MSCBWrite("^GB1,"+ "900,005" + "^FS")
    //INSERE DESCRIÇÃO E DATA RELACIONADA A PRODUÇÃO
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "580,550" + "^FH\^FD " + TT1ING + "^FS")
    MSCBWrite("^FO" + "550,550" + "^FH\^FD " + TT1POR + "^FS")
    MSCBWrite("^CFA,30^FO" + "580,830" + "^FH\^FD " + DtaProI + "^FS")
    MSCBWrite("^CFA,30^FO" + "550,830" + "^FH\^FD " + DtaPro + "^FS")
    //INSERE LINHA HORIZONTAL
    MSCBWrite("^FO" + "540,550")
    MSCBWrite("^GB1,"+ "900,005" + "^FS")
    //INSERE DESCRIÇÃO E DATA RELACIONADA A CONGELAMENTO
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "500,550" + "^FH\^FD " + TT2ING + "^FS")
    MSCBWrite("^FO" + "470,550" + "^FH\^FD " + TT2POR + "^FS")
    MSCBWrite("^CFA,30^FO" + "500,830" + "^FH\^FD " + DtaConI + "^FS")
    MSCBWrite("^CFA,30^FO" + "470,830" + "^FH\^FD " + DtaCon + "^FS")
    //INSERE LINHA HORIZONTAL
    MSCBWrite("^FO" + "460,550")
    MSCBWrite("^GB1,"+ "900,005" + "^FS")
    //INSERE DESCRIÇÃO E DATA RELACIONADA A VALIDADE
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "420,550" + "^FH\^FD " + TT3ING + "^FS")
    MSCBWrite("^FO" + "390,550" + "^FH\^FD " + TT3POR + "^FS")
    MSCBWrite("^CFA,30^FO" + "420,830" + "^FH\^FD " + DtaValI + "^FS")
    MSCBWrite("^CFA,30^FO" + "390,830" + "^FH\^FD " + DtaVal + "^FS")
    //INSERE LINHAS HORIZONTAL
    MSCBWrite("^FO" + "380,550")
    MSCBWrite("^GB1,"+ "900,005" + "^FS")
    //INSERE DESCRIÇÃO E DATA RELACIONADA A EMBALAGEM
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "340,550" + "^FH\^FD " + TT4ING + "^FS")
    MSCBWrite("^FO" + "310,550" + "^FH\^FD " + TT4POR + "^FS")
    MSCBWrite("^CFA,30^FO" + "340,830" + "^FH\^FD " + DtaProI + "^FS")
    MSCBWrite("^CFA,30^FO" + "310,830" + "^FH\^FD " + DtaPro + "^FS")
    //INSERE LINHA HORIZONTAL
    MSCBWrite("^FO" + "300,550")
    MSCBWrite("^GB1,"+ "900,005" + "^FS")
    //INSERE DESCRIÇÃO E DATA RELACIONADA A CONSERVAÇÃO
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "260,550" + "^FH\^FD " + TT5ING + "^FS")
    MSCBWrite("^FO" + "230,550" + "^FH\^FD " + TT5POR + "^FS")
    aTemper := STRTOKARR(MsgTemp, ' ')
    MSCBWrite("^CFA,30^FO" + "245,830" + "^FH\^FD " + aTemper[4] + ' \A7C' + "^FS")
    //INSERE LINHA HORIZONTAL
    MSCBWrite("^FO" + "220,550")
    MSCBWrite("^GB1,"+ "900,005" + "^FS")
    //RASTREABILIDADE
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "180,550" + "^FH\^FD " + TT11ING + "^FS")
    MSCBWrite("^FO" + "150,550" + "^FH\^FD " + TT11POR + "^FS")
    MSCBWrite("^CFA,30^FO" + "165,750" + "^FH\^FD " + Rastre + "^FS")
    //INSERE LINHA HORIZONTAL
    MSCBWrite("^FO" + "140,550")
    MSCBWrite("^GB1,"+ "900,005" + "^FS")

    //INSERE LINHAS VERTICAIS
    MSCBWrite("^FO" + "140,1000")
    MSCBWrite("^GB" + "480,1,4^FS")
    //INSERE INFORMAÇÕES RELACIONADAS A PESAGEM (BRUTO)
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "580,1000" + "^FH\^FD " + TT6ING + "^FS")
    MSCBWrite("^FO" + "550,1000" + "^FH\^FD " + TT6POR + "^FS")
    pesoBru := STRTRAN(TRANSFORM((nPesoBr * 2.20462262185),'@E 99.99'),',','.')
    MSCBWrite("^CFA,30^FO" + "577,1280" + "^FH\^FD " + PesoBru + " Lb" +  "^FS")
    MSCBWrite("^CFA,30^FO" + "540,1280" + "^FH\^FD " + pesoBr + " Kg" +  "^FS")
    //INSERE INFORMAÇÕES RELACIONADAS A PESAGEM (LIQUIDO)
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "500,1000" + "^FH\^FD " + TT7ING + "^FS")
    MSCBWrite("^FO" + "470,1000" + "^FH\^FD " + TT7POR + "^FS")
    pesoLiq := STRTRAN(TRANSFORM((nPesoLi * 2.20462262185),'@E 99.99'),',','.')
    MSCBWrite("^CFA,30^FO" + "497,1280" + "^FH\^FD " + PesoLiq  + " Lb" + "^FS")
    MSCBWrite("^CFA,30^FO" + "467,1280" + "^FH\^FD " + PesoLi + " Kg" + "^FS")
    //
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "420,1000" + "^FH\^FD " + TT8ING + "^FS")
    MSCBWrite("^FO" + "390,1000" + "^FH\^FD " + TT8POR + "^FS")
    tprim := STRTRAN(TRANSFORM((VAL(cTaraPr) * 2.20462262185),'@E 99.99'),',','.')
    MSCBWrite("^CFA,30^FO" + "417,1280" + "^FH\^FD " + tprim + ' Lb' + "^FS")
    MSCBWrite("^CFA,30^FO" + "387,1280" + "^FH\^FD " + ALLTRIM(TRANSFORM((cTaraPr),'@E 99,99')) + ' Kg' + "^FS")
    //
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "340,1000" + "^FH\^FD " + TT9ING + "^FS")
    MSCBWrite("^FO" + "310,1000" + "^FH\^FD " + TT9POR + "^FS")    
    tsecu := STRTRAN(TRANSFORM((VAL(cTaraSe) * 2.20462262185),'@E 99.99'),',','.')
    MSCBWrite("^CFA,30^FO" + "337,1280" + "^FH\^FD " + tsecu + ' Lb' + "^FS")
    MSCBWrite("^CFA,30^FO" + "307,1280" + "^FH\^FD " + ALLTRIM(TRANSFORM((cTaraSe),'@E 99,99')) + ' Kg' + "^FS")
    //
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "260,1000" + "^FH\^FD " + TT10ING + "^FS")
    MSCBWrite("^FO" + "230,1000" + "^FH\^FD " + TT10POR + "^FS")
    MSCBWrite("^CFA,30^FO" + "245,1280" + "^FH\^FD " + QtdCXA + "^FS")
    //HORA
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "180,1000" + "^FH\^FD " + TT12ING + "^FS")
    MSCBWrite("^FO" + "150,1000" + "^FH\^FD " + TT12POR + "^FS")
    MSCBWrite("^CFA,30^FO" + "165,1280" + "^FH\^FD" + Hora + "^FS")
    //IMPRIME NÚMERO DA PRE-ETIQUETA
    MSCBWrite("^FO" + "090,550" + "^FH\^FD " + "PE: " + NumPEt + "^FS")
    //CODIGO DE BARRA DO Nº DA CAIXA
    MSCBWrite("^BY3,3,75")
    MSCBWrite("^FT" + "040,880")
    MSCBWrite("^BCR,,Y,N")
    MSCBWrite("^FD>;" + NumCxa + "^FS")
    //CODIGO DE BARRA DUN14
    /*
    MSCBWrite("^BY3,3,50")
    MSCBWrite("^FT" + "250,1550")
    MSCBWrite("^BCN,,Y,N")
    MSCBWrite("^FD>;" + '0000000000' + "^FS")
    */
    //NÚMERO DO CODIGO DO PRODUTO EM FUNDO PRETO
    MSCBWrite("^LRY")
    MSCBWrite("^FO" + "010,550")
    MSCBWrite("^GB" + "000,300,070" + "^FS")
    MSCBWrite("^FO" + "010,550" + "^CFG")
    MSCBWrite("^FD" + CodPro + "^FS")
    //DADOS DO FRIGORíFICO
    MSCBWrite("^CFA,20")
    MSCBWrite("^FO" + "280,010" + "^FH\^FD" + "Registro no Minist\82rio da Agricultura SIF/DIPOA sob n\A7 ^FS")
    MSCBWrite("^FO" + "250,200" + "^FH\^FD" + _cMSif + "^FS")
    MSCBWrite("^FO" + "190,010" + "^FH\^FD" + "FRIGOR\D6FICO SILVA IND\E9STRIA E COM\90RCIO LTDA. ^FS")
    MSCBWrite("^FO" + "170,010" + "^FH\^FD" + "ABATEDOURO FRIGOR\D6FICO IND. E COM. DE CARNES ^FS")
    MSCBWrite("^FO" + "150,010" + "^FH\^FD" + "E SEUS DERIVADOS ^FS")
    MSCBWrite("^FO" + "130,010" + "^FH\^FD" + "CNPJ: 88.728.027/0001-46 ^FS")
    MSCBWrite("^FO" + "110,010" + "^FH\^FD" + "INSC EST: 109/0096949 | PRODUCT OF BRAZIL ^FS")
    MSCBWrite("^FO" + "090,010" + "^FH\^FD" + "BR 392 Km 8 - BAIRRO TOMAZETTI - SANTA MARIA-RS ^FS")
    MSCBWrite("^FO" + "070,010" + "^FH\^FD" + "CEP 97065-400 ^FS")
    MSCBWrite("^FO" + "050,010" + "^FH\^FD" + "OFFICE +55 55 2103 2525 ^FS")
    MSCBWrite("^FO" + "030,010" + "^FH\^FD" + "www.frigorificosilva.com.br ^FS")
    //INSERE CAIXA
    MSCBWrite("^FO" + "030,1180")
    MSCBWrite("^GB1,"+"270,005" + "^FS")
    MSCBWrite("^FO" + "030,1180")
    MSCBWrite("^GB" + "110,1,4^FS")
    MSCBWrite("^FO" + "030,1450")
    MSCBWrite("^GB" + "110,1,4^FS")
    //IMPRIME NÚMERO DO SHIPPING MARK
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO" + "080,1200" + "^FH\^FD " + "SHIPPING MARK:^FS")
    MSCBWrite("^CFA,40,30")
    MSCBWrite("^FO" + "035,1200" + "^FH\^FD " + _cShipM + "^FS")
    //IMAGEM LOGO SIF
    MSCBWrite("^FO" + "300,010")
    MSCBWrite("^IME:LOGOSIF.GRF,1,1")
    //ENCERRA LINGUAGEM ZPL
    MSCBWrite("^PQ" + '1' + ",0,1,N")
    MSCBWrite("^XZ")
RETURN

STATIC FUNCTION Imprime()

    MSCBPRINTER(Modelo,Portap,,,,,IPprint)

    MSCBCHKSTATUS(.F.)
    MSCBBEGIN(1,6,15)

    EtiquetasEmZPLII()

    MSCBEND()
	MSCBCLOSEPRINTER()
RETURN
