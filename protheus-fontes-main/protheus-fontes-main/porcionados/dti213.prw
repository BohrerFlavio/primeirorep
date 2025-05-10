/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI213            º Autor ³ Lucas Bolzan º Data ³ 11/04/24  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de etiquetas colantes temperado                  º±±
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
#INCLUDE "COLORS.ch"

USER FUNCTION DTI213()
    //Variaveis para dimensões dos forms
    tsTop      := 0
    tsLeft     := 0
    tsBottom   := 400
    tsRight    := 300
    tsCaption  := 'Impressão de etiquetas identificadoras de produtos.'
    tsClrText  := CLR_BLACK
    tsClrBack  := CLR_WHITE
    tsPixel    := .T.
    //Variaveis gerais
    _cCmdZPL       := ""
    xTGet1         := Space(6) //codigo do produto    
    xTGet3         := SToD("") //Data de produção
    xTGet4         := Space(6) //Quantidade de etiquetas
    xTGet5         := Space(1) //codigo da mesa
    xTGet6         := Space(16) //lote EUA
    _cDescProd     := Space(40)    
    _nTaraProd     := 0.000
    _cQtdEtq       := Space(6)
    _nQtdEtq       := 0
    _cOpera        := UsrRetName(retCodUsr())
    DtaMax7        := DDATABASE+7
    MsgTemp := ALLTRIM(SB1->B1_MENETQ2)
    PesEmb  := 0.000
        taraSB1    := POSICIONE( 'SB1' ,1,FWXFilial( 'SB1' )+ alltrim(xTGet1), 'B1_CTARAP' ) // Linhas inseridas para buscar"_NTARAp"
	    taraZAB    := POSICIONE( 'ZAB' ,1,FWXFilial( 'ZAB' )+alltrim(taraSB1), 'ZAB_TARA' ) // os campos de codigo das taras primarias
	    PesEmb := ALLTRIM(STR((taraZAB * 1000)))

    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
        oFont:= TFont():New('Arial',, -12, .T.)
        
        oSay1:= TSay():New(010,15,{||'Código do produto:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay2:= TSay():New(025,15,{||'Descrição do produto:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)        
        oSay4:= TSay():New(40,15,{||'Data de embalagem:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

        //oSay13:= TSay():New(070,15,{||'Data de maturação:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

        oSay5:= TSay():New(085,15,{||'Tara:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay6:= TSay():New(100,15,{||'Quant. de Caxias:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay7:= TSay():New(115,15,{||'Quant. de Etiquetas:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)        

        oSay8:= TSay():New(025,080,{||_cDescProd},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay9:= TSay():New(085,080,{||STR(_nTaraProd) + "g"},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay10 :=TSay():New(100,080,{||_cQtdEtq},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

        oTGet1 := TGet():New(10,75,{ | u | If( PCount() > 0, xTGet1 := u, xTGet1) },oDialog,40,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,xTGet1,,,,.t., )
            oTGet1:cF3 := 'ZZ7'
            oTGet1:Picture := '@!'        
        oTGet3 := TGet():New(040,75,{ | u | If( PCount() > 0, xTGet3 := u, xTGet3) },oDialog,40,10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t., )        

        oTGet4 := TGet():New(115,75,{ | u | If( PCount() > 0, xTGet4 := u, xTGet4) },oDialog,40,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,xTGet4,,,,.t., )
            oTGet4:bValid := {|| QuantEtq() }
            oTGet4:Picture := '@!'

        oTButton1 := TButton():New(165, 030, "Imprimir",oDialog,{||Validacoes()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
        oTButton2 := TButton():New(165, 080, "Cancelar e Sair",oDialog,{||oDialog:end()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

        oTGet1:bLostFocus:= {|| Dados()}
    oDialog:Activate(,,,.T.,,,)
RETURN

STATIC FUNCTION Validacoes()
    _cCodGrpProd := GetAdvFval('SB1','B1_GRUPO',FWxFilial('SB1') + alltrim(xTGet1),1)

    //VALIDAÇÃO PARA GARANTIR QUE UM PRODUTO FOI INSERIDO
    IF (empty(oTGet1:bLostFocus))
        MsgAlert("Obrigatrório informar um produto.", "Aviso")
    ENDIF

    DbSelectArea('ZZ7')
    ZZ7->(DbSetOrder(1))
    IF !ZZ7->(DbSeek(FWxFilial('ZZ7')+xTGet1))
        MsgAlert("Produto informado não existe.", "Aviso")
        RETURN
    ENDIF

    //VALIDAÇÃO PARA GARANTIR QUE UMA DATA DE EMBALAGEM FOI INFORMADA    
    IF (xTGet1 <> '000300')
        IF (empty(xTGet3))
            MsgAlert("Obrigatrório informar uma data de embalagem.", "Aviso")
            RETURN
        ENDIF
    ENDIF
    //VALIDAÇÃO PARA GARANTIR QUE A DATA DE PRODUÇÃO NÃO SEJA MAIOR QUE O DIA
    IF (xTGet1 <> '000300')
        IF (xTGet3 <> DDATABASE)
            IF(!_cOpera $ GetMV('SI_UDESN1'))
                MsgAlert("A data de embalagem não pode ser maior que a database.", "Aviso")
                RETURN
            ELSE            
                IF (xTGet3 > DtaMax7)
                    MsgAlert("Esta data de embalagem é maior que 7 (sete) dia acima da database, por isso não pode ser usada. ", "Aviso")
                    RETURN
                ENDIF
            ENDIF
        ENDIF
    ENDIF
    
    //VALIDAÇÃO PARA GARANTIR QUE A QUANTIDADE DE ETIQUETAS A SEREM IMPRESSA SEJA INSERIDA
    IF (empty(xTGet4))
        MsgAlert("Obrigatrório informar quantidade de etiquetas.", "Aviso")
        RETURN        
    ENDIF
    Imprime()
RETURN

STATIC FUNCTION Dados()
    _cDescProd := GetAdvFval('ZZ7','ZZ7_CORTE',FWxFilial('ZZ7') + alltrim(xTGet1),1)

    taraSB1    := POSICIONE( 'SB1' ,1,FWxfilial( 'SB1' )+ alltrim(xTGet1), 'B1_CTARAP' ) // Linhas inseridas para buscar"_NTARAp"
	taraZAB    := POSICIONE( 'ZAB' ,1,FWxfilial( 'ZAB' )+alltrim(taraSB1), 'ZAB_TARA' ) // os campos de codigo das taras primarias
	_nTaraProd := (taraZAB * 1000)    

	oDialog:refresh()
RETURN

STATIC FUNCTION QuantEtq()
    a := POSICIONE('SB1',1,FWxFilial('SB1') + alltrim(xTGet1),'B1_QCAIX')
    _cQtdEtq := ALLTRIM(STR(a * VAL(xTGet4)))
    _nQtdEtq := (a * VAL(xTGet4))
    oDialog:refresh()
RETURN

STATIC FUNCTION CalcPesoMed(caixas,Codigo)
	IF !empty(caixas) .and. !empty(Codigo)
		pmc    := GetAdvFval('SB1','B1_PMCAIX',FWxfilial('SB1')+Codigo,1)
		pmedio := (caixas * pmc)
		RETURN pmedio
	ENDIF
RETURN 0

STATIC FUNCTION Imprime()
	Processa({||ETIQUETA() },"IMPRESSAO DE ETIQUETA","Realizando envio à impressora...")
RETURN

STATIC FUNCTION ETIQUETA()
    ProcRegua(VAL(xTGet4))
    
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
    MSCBBEGIN(_nQtdEtq,6,15)
    
    EtiquetaZPL()
    
    MSCBEND()
	MSCBCLOSEPRINTER()
	
    LimpaCampos()

	//msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

	oTButton1:enable()
	oDialog:refresh()
RETURN

STATIC FUNCTION LimpaCampos()
    xTGet1     := Space(6)    
    xTGet3     := SToD("")
    xTGet4     := Space(6)
    _cDescProd := Space(40)
    _nTaraProd := 0.000
    _cQtdEtq   := Space(6)

	oDialog:refresh()
RETURN

STATIC FUNCTION EtiquetaZPL()
    //BUSCA DADOS DO PRDOUTO
    _cTipEtq := GetAdvFval( 'ZZ7' , 'ZZ7_TPETQ' ,FWxFilial( 'ZZ7' ) + alltrim(xTGet1),1)
    _cRaca   := GetAdvFval( 'ZZ7' , 'ZZ7_RACA' ,FWxFilial( 'ZZ7' ) + alltrim(xTGet1),1)
    _cCodGrpProd    := GetAdvFval( 'SB1' , 'B1_GRUPO' ,FWxFilial( 'SB1' ) + alltrim(xTGet1),1) //BUSCA GRUPO DE PRODUTOS
    _cDestino       := GetAdvFval( 'SB1' , 'B1_DESTINO' ,FWxFilial( 'SB1' ) + alltrim(xTGet1),1) //BUSCA O DESTINO DO PRODUTO    
    _cCadMercadoria := GetAdvFval( 'SB1' , 'B1_CADMERC' ,FWxFilial( 'SB1' ) + alltrim(xTGet1),1) //BUSCA O CADASTRO DA MERCADORIA DO PRODUTO
    
	_DtVal  := xTGet3 + SB1->B1_VALID	

	MSCBWrite("^XA")
	MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWR")
    MSCBWrite("^CFA,22")
    MSCBWrite("^FO 780,040")
    MSCBWrite("^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
    MSCBWrite("^FO 750,040")
    MSCBWrite("^FH\^FD" + ZZ7->ZZ7_CORTE + " / " + ZZ7->ZZ7_MSGVAR + "^FS")
    MSCBWrite("^FO" + "710,040")
    MSCBWrite("^FH\^FD" + ZZ7->ZZ7_INGRE2 + "^FS")
    MSCBWrite("^FO 670,040")
    MSCBWrite("^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
    MSCBWrite("^FO 640,040")
    MSCBWrite("^FH\^FD DATA DE VALIDADE ^FS")
    MSCBWrite("^FO 610,040")
    MSCBWrite("^FH\^FD TARA DA EMBALAGEM ^FS")    
    MSCBWrite("^FO 670,350")
    MSCBWrite("^FH\^FD"  + DToC(xTGet3) + "^FS")
    MSCBWrite("^FO 640,350")
    MSCBWrite("^FH\^FD"  + DToC(_DtVal) + "^FS")
    MSCBWrite("^FO 610,350")
    MSCBWrite("^FH\^FD" + PesEmb + " g" + "^FS")
    
    MSCBWrite("^FO" + "560,040")
    MSCBWrite("^FH\^FD" + "Ingredientes: " + SubSTR(ALLTRIM(ZZ7->ZZ7_INGRED),001,050) + " ^FS")
    MSCBWrite("^FO" + "530,040")
    MSCBWrite("^FH\^FD" + SubSTR(ALLTRIM(ZZ7->ZZ7_INGRED),051,065) + " ^FS") //MSCBWrite("^FH\^FD" + SubSTR(ALLTRIM(ZZ7->ZZ7_INGRED),051,050) + " ^FS")
    MSCBWrite("^FO" + "500,040")
    MSCBWrite("^FH\^FD" + SubSTR(ALLTRIM(ZZ7->ZZ7_INGRED),116,065) + " ^FS") //MSCBWrite("^FH\^FD" + SubSTR(ALLTRIM(ZZ7->ZZ7_INGRED),101,050) + " ^FS")
    //MSCBWrite("^FO" + "470,040")
    //MSCBWrite("^FH\^FD" + SubSTR(ALLTRIM(ZZ7->ZZ7_INGRED),151,100) + " ^FS")
    MsgTemp := Alltrim(SB1->B1_MENETQ2)    
    IF("CELSIUS" $ MsgTemp)
        MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
        MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
    ELSEIF("CELCIUS" $ MsgTemp)
        MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
        MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
    ENDIF
    MSCBWrite("^FO" + "220,620" + "^FH\^FD" + MsgTemp + "^FS")
    MSCBWrite("^FO" + "160,620" + ZZ7->ZZ7_METQ1 + "^FS")
    MSCBWrite("^FO" + "190,620" + "^FH\^FD N\C7O CONT\90M GL\E9TEN ^FS")

    //INFORMAÇÕES NO RODAPÉ DA ETIQQUETA
    MSCBWrite("^CFA,19")
    MSCBWrite("^FO" + "110,620")
    MSCBWrite("^FH\^FD" + "Registro no Minist\82rio da Agricultura SIF/DIPOA sob n.\A7 " + ALLTRIM(ZZ7->ZZ7_MSIF) + "^FS")
    MSCBWrite("^FO" + "080,620")
    MSCBWrite("^FH\^FD" + "Frigorifico Silva Ind\A3stria e Com\82rcio LTDA. Abatedouro Frigor\A1fico Ind. e Com. de Carnes e seus derivados" + "^FS")
    MSCBWrite("^FO" + "050,620")
    MSCBWrite("^FH\^FD" + "BR 392 km 8 Tomazetti, Santa Maria - RS - Brasil, CEP 97065-400, CNPJ: 88.728.027/0001-46" + "^FS")
    MSCBWrite("^FO" + "020,620")
    MSCBWrite("^FH\^FD" + "INDUSTRIA BRASILEIRA. N\C7O CONT\90M GL\E9TEN" + "^FS")

    //CODIGO DE BARRA
    MSCBWrite("^BY3,3,50")
    MSCBWrite("^FT250,670")
    MSCBWrite("^BCN,,Y,N")
    MSCBWrite("^FD>;" + ZZ7->ZZ7_CODPRO + "^FS")
    
    //IMAGEM LOGO SIF
    MSCBWrite("^FO" + "310,950")
    MSCBWrite("^IME:LOGOSIF.GRF,1,1^FS")

    TabNutComp()

    MSCBWrite("^PQ" + _cQtdEtq + ",0,1,N")
    MSCBWrite("^XZ")    
RETURN

STATIC FUNCTION TabNutComp()    
    //INSERE QUADRADO
    MSCBWrite("^FO 040,035")
    MSCBWrite("^GB 430,455,2^FS")

    //INSERE LINHAS VERTICAIS
    MSCBWrite("^FO 075,305")
    MSCBWrite("^GB 330,1,2^FS")

    MSCBWrite("^FO 075,390")
    MSCBWrite("^GB 330,1,2^FS")

    //INSERE LINHAS HORIZONTAIS
    MSCBWrite("^FO 435,040")
    MSCBWrite("^GB1,440,2^FS")

    MSCBWrite("^FO 405,040")
    MSCBWrite("^GB1,440,4^FS")

    MSCBWrite("^FO 375,040")
    MSCBWrite("^GB1,440,2^FS")

    MSCBWrite("^FO 345,040")
    MSCBWrite("^GB1,440,2^FS")

    MSCBWrite("^FO 315,040")
    MSCBWrite("^GB1,440,2^FS")

    MSCBWrite("^FO 285,040")
    MSCBWrite("^GB1,440,2^FS")

    MSCBWrite("^FO 255,040")
    MSCBWrite("^GB1,440,2^FS")

    MSCBWrite("^FO 225,040")
    MSCBWrite("^GB1,440,2^FS")

    MSCBWrite("^FO 195,040")
    MSCBWrite("^GB1,440,2^FS")

    MSCBWrite("^FO 165,040")
    MSCBWrite("^GB1,440,2^FS")

    MSCBWrite("^FO 135,040")
    MSCBWrite("^GB1,440,2^FS")

    MSCBWrite("^FO 105,040")
    MSCBWrite("^GB1,440,2^FS")

    MSCBWrite("^FO 075,040")
    MSCBWrite("^GB1,440,3^FS")
    
    _cIDTaBN := ALLTRIM(GetAdvFval('ZZ7','ZZ7_TABNUT',FWxFilial('ZZ7')+xTGet1,1,'Sem informação',.t.))
    _cPorCpe := ALLTRIM(GetAdvFval('ZBH','ZBH_PORCPE',_cIDTaBN,1,'Sem informação',.t.))

    MSCBWrite("^CFA,20")
    MSCBWrite("^PW609")
    
    MSCBWrite("^CWA,E:ARIALBD.TTF")
    MSCBWrite("^CFA,25 ^FO 440,080")
    MSCBWrite("^FH\^FD" + " INFORMA\80\C7O NUTRICIONAL" + "^FS")

    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^CFA,22")    
    MSCBWrite("^FO 410,040")
    MSCBWrite("^FH\^FD Por\87\C6o: " + ALLTRIM(GetAdvFval('ZBH','ZBH_PORCPE',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^CWA,E:ARIALBD.TTF")    
    MSCBWrite("^FO 380,315 ^FD 100 g ^FS")    
    MSCBWrite("^FO 380,400 ^FD %VD* ^FS")

    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FO" + "350,040")
    MSCBWrite("^FH\^FD" + "Valor energ\82tico (kcal)" + "^FS")
    MSCBWrite("^FO" + "350,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VEN100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "350,085")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VENVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")        

    MSCBWrite("^FO" + "320,040")
    MSCBWrite("^FH\^FD" + "Carboidratos (g)" + "^FS")
    MSCBWrite("^FO" + "320,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_CAR100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "320,085")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_CARVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "290,040")
    MSCBWrite("^FH\^FD" + "A\87\A3cares totais (g)" + "^FS")
    MSCBWrite("^FO" + "290,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_ATO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "290,085")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_ATOVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "260,050")
    MSCBWrite("^FH\^FD" + "A\87\A3cares adicionados (g)" + "^FS")
    MSCBWrite("^FO" + "260,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_AAD100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "260,085")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_ADDVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    
    MSCBWrite("^FO" + "230,040")
    MSCBWrite("^FH\^FD" + "Prote\A1nas (g)" + "^FS")
    MSCBWrite("^FO" + "230,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PRO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "230,085")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PROVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "200,040")
    MSCBWrite("^FH\^FD" + "Gorduras totais (g)" + "^FS")
    MSCBWrite("^FO" + "200,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "200,085")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTOVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "170,050")
    MSCBWrite("^FH\^FD" + "Gorduras saturadas (g)" + "^FS")
    MSCBWrite("^FO" + "170,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSA100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "170,085")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSAVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "140,050")
    MSCBWrite("^FH\^FD" + "Gorduras trans (g)" + "^FS")
    MSCBWrite("^FO" + "140,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTR100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "140,085")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTRVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "110,040")
    MSCBWrite("^FH\^FD" + "Fibras alimentares (g)" + "^FS")
    MSCBWrite("^FO" + "110,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FAL100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "110,085")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FALVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    
    MSCBWrite("^FO" + "080,040")
    MSCBWrite("^FH\^FD" + "S\A2dio (mg)" + "^FS")
    MSCBWrite("^FO" + "080,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SOD100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "080,085")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SODVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^CFA,18 ^FO" + "050,040")
    MSCBWrite("^FH\^FD" + "*Percentual de valores di\A0rios fornecidos pela por\87\C6o" + "^FS")

    IF !("100" $ _cPorCpe)
        MSCBWrite("^FO" + "330,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VEN80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

        MSCBWrite("^FO" + "300,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_CAR80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "270,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_ATO80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "240,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_ADD80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "210,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PRO80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "180,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTO80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "150,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSA80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "120,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTR80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
        
        MSCBWrite("^FO" + "090,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FAL80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "060,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SOD80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    ENDIF
RETURN

STATIC FUNCTION BKPTabNutComp()    
    //INSERE QUADRADO
    MSCBWrite("^FO 010,035")
    MSCBWrite("^GB 460,550,2^FS")

    //INSERE LINHAS VERTICAIS    
    MSCBWrite("^FO 055,290")
    MSCBWrite("^GB 330,1,2^FS")

    MSCBWrite("^FO 055,390")
    MSCBWrite("^GB 330,1,2^FS")

    MSCBWrite("^FO 055,490")
    MSCBWrite("^GB 330,1,2^FS")

    //INSERE LINHAS HORIZONTAIS
    MSCBWrite("^FO 435,040")
    MSCBWrite("^GB1,550,5^FS")

    MSCBWrite("^FO 385,040")
    MSCBWrite("^GB1,550,5^FS")
    
    MSCBWrite("^FO 355,040")
    MSCBWrite("^GB1,550,5^FS")

    MSCBWrite("^FO 325,040")
    MSCBWrite("^GB1,550,2^FS")

    MSCBWrite("^FO 295,040")
    MSCBWrite("^GB1,550,2^FS")

    MSCBWrite("^FO 265,040")
    MSCBWrite("^GB1,550,2^FS")

    MSCBWrite("^FO 235,040")
    MSCBWrite("^GB1,550,2^FS")

    MSCBWrite("^FO 205,040")
    MSCBWrite("^GB1,550,2^FS")

    MSCBWrite("^FO 175,040")
    MSCBWrite("^GB1,550,2^FS")

    MSCBWrite("^FO 145,040")
    MSCBWrite("^GB1,550,2^FS")

    MSCBWrite("^FO 115,040")
    MSCBWrite("^GB1,550,2^FS")
    
    MSCBWrite("^FO 085,040")
    MSCBWrite("^GB1,550,2^FS")
    
    MSCBWrite("^FO 055,040")
    MSCBWrite("^GB1,550,2^FS")

    MSCBWrite("^FO 020,040")
    MSCBWrite("^GB1,550,4^FS")
    
    _cIDTaBN := ALLTRIM(GetAdvFval('ZZ7','ZZ7_TABNUT',FWxFilial('ZZ7')+xTGet1,1,'Sem informação',.t.))
    _cPorCpe := ALLTRIM(GetAdvFval('ZBH','ZBH_PORCPE',_cIDTaBN,1,'Sem informação',.t.))

    MSCBWrite("^CFA,20")
    MSCBWrite("^PW609")
    
    MSCBWrite("^CWA,E:ARIALBD.TTF")
    MSCBWrite("^CFA,25 ^FO 440,150")
    MSCBWrite("^FH\^FD" + " INFORMA\80\C7O NUTRICIONAL" + "^FS")

    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^CFA,22 ^FO 410,040")
    MSCBWrite("^FH\^FD Por\87\C6o por embalagem: " + ALLTRIM(GetAdvFval('ZBH','ZBH_POREMB',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO 390,040")
    MSCBWrite("^FH\^FD Por\87\C6o: " + ALLTRIM(GetAdvFval('ZBH','ZBH_PORCPE',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^CWA,E:ARIALBD.TTF")    
    MSCBWrite("^FO 360,300 ^FD 100 g ^FS")
    MSCBWrite("^FO 360,410 ^FD 80 g ^FS")
    MSCBWrite("^FO 360,500 ^FD %VD* ^FS")

    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FO" + "330,040")
    MSCBWrite("^FH\^FD" + "Valor energ\82tico (kcal)" + "^FS")
    MSCBWrite("^FO" + "330,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VEN100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "330,095")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VENVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")        

    MSCBWrite("^FO" + "300,040")
    MSCBWrite("^FH\^FD" + "Carboidratos (g)" + "^FS")
    MSCBWrite("^FO" + "300,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_CAR100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "300,095")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_CARVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "270,040")
    MSCBWrite("^FH\^FD" + "A\87\A3cares totais (g)" + "^FS")
    MSCBWrite("^FO" + "270,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_ATO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "270,095")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_ATOVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "240,050")
    MSCBWrite("^FH\^FD" + "A\87\A3cares adicionados (g)" + "^FS")
    MSCBWrite("^FO" + "240,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_AAD100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "240,095")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_ADDVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    
    MSCBWrite("^FO" + "210,040")
    MSCBWrite("^FH\^FD" + "Prote\A1nas (g)" + "^FS")
    MSCBWrite("^FO" + "210,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PRO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "210,095")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PROVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "180,040")
    MSCBWrite("^FH\^FD" + "Gorduras totais (g)" + "^FS")
    MSCBWrite("^FO" + "180,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "180,095")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTOVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "150,050")
    MSCBWrite("^FH\^FD" + "Gorduras saturadas (g)" + "^FS")
    MSCBWrite("^FO" + "150,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSA100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "150,095")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSAVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "120,050")
    MSCBWrite("^FH\^FD" + "Gorduras trans (g)" + "^FS")
    MSCBWrite("^FO" + "120,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTR100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "120,095")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTRVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "090,040")
    MSCBWrite("^FH\^FD" + "Fibras alimentares (g)" + "^FS")
    MSCBWrite("^FO" + "090,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FAL100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "090,095")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FALVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    
    MSCBWrite("^FO" + "060,040")
    MSCBWrite("^FH\^FD" + "S\A2dio (mg)" + "^FS")
    MSCBWrite("^FO" + "060,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SOD100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "060,095")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SODVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^CFA,19 ^FO" + "030,040")
    MSCBWrite("^FH\^FD" + "*Percentual de valores di\A0rios fornecidos pela por\87\C6o" + "^FS")

    IF !("100" $ _cPorCpe)
        MSCBWrite("^FO" + "330,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VEN80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

        MSCBWrite("^FO" + "300,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_CAR80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "270,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_ATO80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "240,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_ADD80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "210,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PRO80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "180,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTO80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "150,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSA80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "120,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTR80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
        
        MSCBWrite("^FO" + "090,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FAL80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "060,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SOD80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    ENDIF
RETURN
