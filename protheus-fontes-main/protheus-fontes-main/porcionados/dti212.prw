/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI212            º Autor ³ Lucas Bolzan º Data ³ 16/04/24  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Etiqueta p/ espetinho                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Porcionados                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"

USER FUNCTION DTI212()
    //Variaveis para dimensões dos forms
    tsTop      := 0
    tsLeft     := 0
    tsBottom   := 300
    tsRight    := 300
    tsCaption  := 'Impressão de etiquetas identificadoras de produtos.'
    tsClrText  := CLR_BLACK
    tsClrBack  := CLR_WHITE
    tsPixel    := .T.
    //Variaveis gerais
    _cCmdZPL        := ""
    xTGet1          := Space(6) //codigo do produto
    xTGet2          := SToD("") //Data de abate
    xTGet3          := SToD("") //Data de produção
    xTGet4          := Space(6) //Quantidade de etiquetas    
    _cDescProd      := Space(40)
    _nTaraProd      := 0.000
    _cQtdEtq        := Space(6)
    _nQtdEtq        := 0
    _cDiret1        := 'C:\SMARTCLIENT_V2210\smartclient_OFICIAL\arquivos\'
    _cDiret2        := 'C:\smartclient_OFICIAL\arquivos\'
    _cFileTXT       := "EtiquetaInterna.txt"
    _cCodGrpProd    := GetAdvFval('SB1','B1_GRUPO' ,FWxFilial('SB1') + alltrim(xTGet1),1) //BUSCA GRUPO DE PRODUTOS
    _cDestino       := GetAdvFval('SB1','B1_DESTINO',FWxFilial('SB1') + alltrim(xTGet1),1) //BUSCA O DESTINO DO PRODUTO    
    _cCadMercadoria := GetAdvFval('SB1','B1_CADMERC',FWxFilial('SB1') + alltrim(xTGet1),1) //BUSCA O CADASTRO DA MERCADORIA DO PRODUTO
    taraSB1         := GetAdvFval('SB1','B1_CTARAP',FWXFilial('SB1')+alltrim(xTGet1),1) // Linhas inseridas para buscar"_NTARAp"
    taraZAB         := GetAdvFval('ZAB','ZAB_TARA',FWXFilial('ZAB')+alltrim(taraSB1),1) // os campos de codigo das taras primarias
    PesEmb          := 0.000//ALLTRIM(STR((taraZAB * 1000)))

    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
        oFont:= TFont():New('Arial',, -12, .T.)

        oSay1:= TSay():New(010,15,{||'Código do produto:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay2:= TSay():New(025,15,{||'Descrição do produto:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay3:= TSay():New(040,15,{||'Data de abate/estufa:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay4:= TSay():New(055,15,{||'Data de produção:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay5:= TSay():New(070,15,{||'Tara:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay6:= TSay():New(085,15,{||'Quant. de Caxias:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay7:= TSay():New(100,15,{||'Quant. de Etiquetas:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

        oSay8:= TSay():New(025,080,{||_cDescProd},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay9:= TSay():New(070,080,{||STR(_nTaraProd) + "g"},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay10 :=TSay():New(100,080,{||_cQtdEtq},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

        oTGet1 := TGet():New(10,75,{ | u | If( PCount() > 0, xTGet1 := u, xTGet1) },oDialog,40,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,xTGet1,,,,.t., )
            oTGet1:cF3 := 'ZZ7'
            //oTGet1:bValid := {|| Validacoes() }
            oTGet1:Picture := '@!'
        oTGet2 := TGet():New(040,75,{ | u | If( PCount() > 0, xTGet2 := u, xTGet2) },oDialog,40,10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t., )
        oTGet3 := TGet():New(055,75,{ | u | If( PCount() > 0, xTGet3 := u, xTGet3) },oDialog,40,10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t., )
        oTGet4 := TGet():New(085,75,{ | u | If( PCount() > 0, xTGet4 := u, xTGet4) },oDialog,40,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,xTGet4,,,,.t., )
            oTGet4:bValid := {|| QuantEtq() }
            oTGet4:Picture := '@!'

        oTButton1 := TButton():New(110, 50, "Imprimir",oDialog,{||Validacoes()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
        oTButton2 := TButton():New(125, 50, "Cancelar e Sair",oDialog,{||oDialog:end()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

        oTGet1:bLostFocus:= {|| Dados()}
    oDialog:Activate(,,,.T.,,,)
RETURN

STATIC FUNCTION Validacoes()
    _cCodGrpProd := GetAdvFval('SB1','B1_GRUPO',FWxFilial('SB1') + alltrim(xTGet1),1)

    //VALIDAÇÃO PARA GARANTIR QUE UM PRODUTO FOI INSERIDO
    IF (empty(oTGet1:bLostFocus))
        MsgAlert("Obrigatório informar um produto.", "Aviso")
    ENDIF

    DbSelectArea('ZZ7')
    ZZ7->(DbSetOrder(1))
    IF !ZZ7->(DbSeek(FWxFilial('ZZ7')+xTGet1))
        MsgAlert("Produto informado não existe.", "Aviso")
        RETURN
    ENDIF

    //VALIDAÇÃO PARA GARANTIR QUE UMA DATA DE ABATE FOI INFORMADA
    //SOMENTE PARA PRODUTOS DO PORCIONADOS NÃO SERÁ OBRIGADO INFORMAR DATA DE ABATE
    IF !(_cCodGrpProd $ GetMV('MV_GRPPORC'))
        IF (empty(xTGet2))
            MsgAlert("Obrigatório informar uma data de abate/estufa.", "Aviso")
            RETURN
        ENDIF
    ENDIF

    //VALIDAÇÃO PARA GARANTIR QUE UMA DATA DE PRODUÇÃO FOI INFORMADA
    IF (empty(xTGet3))
        MsgAlert("Obrigatório informar uma data de produção.", "Aviso")
        RETURN
    ENDIF

    //VALIDAÇÃO PARA GARANTIR QUE A DATA DE PRODUÇÃO NÃO SEJA MAIOR QUE O DIA
    IF (xTGet3 <> DDATABASE)
        IF (xTGet3 > DDATABASE)
            MsgAlert("Data de produção maior que a database.", "Aviso")
            RETURN
        ENDIF
    ENDIF

    //VALIDAÇÃO PARA SABER SE NA DATA INFORMADA HOUVE ABATE. SOMENTE PARA PRODUTOS DO PORCIONADOS NÃO SERÁ OBRIGADO INFORMAR DATA DE ABATE
    IF !(_cCodGrpProd $ GetMV('MV_GRPPORC')) .and. !(_cCodGrpProd $ GetMV('MV_GRPCHRQ'))
        IF Empty(GetAdvFval('SZG','ZG_DATA',FWxFilial('SZG')+DToS(xTGet2),2)) .AND. Empty(GetAdvFval('ZAP','ZAP_DATAP',FWxFilial('ZAP') + DToS(xTGet2),4))
            MsgAlert("Na data informada não houve abate!","Alerta")
            RETURN
        ENDIF
    ENDIF

    //VALIDAÇÃO PARA DATA DE ESTUFA E PRODUÇÃO DE PRODUTOS CHARQUE
    IF _cCodGrpProd $ GetMV('MV_GRPCHRQ')
        IF xTGet2 < (DDATABASE-30)
            MsgAlert("Data de estufa deve ser no máximo 30 dias antes da data base!","Alerta")
            RETURN
        ENDIF
        IF xTGet3 < (DDATABASE-15)
            MsgAlert("Data de produção deve ser no máximo 15 dias antes da data base!","Alerta")
            RETURN
        ENDIF
    ENDIF

    //VALIDAÇÃO PARA GARANTIR QUE A DATA DE ABATE INSERIDA NÃO SEJA A DATA BASE OU SUPERIOR, COM EXCESSÃO DE PRODUTOS DO MIÚDOS
    IF !(_cCodGrpProd $ GetMV('MV_GRPMDS'))
        IF(xTGet2 = DDATABASE)
            MsgAlert("Data de abate/estufa não pode ser igual a data do dia.", "Aviso")
            RETURN
        ENDIF
    ENDIF

    //VALIDAÇÃO PARA GARANTIR QUE NÃO SEJA DEFINIDA UMA DATA FUTURA COMO DATA DE ABATE
    IF (xTGet2 > Date())
        MsgAlert("Data de abate/estufa não pode ser maior que a data do dia.", "Aviso")
        RETURN
    ENDIF

    //VALIDAÇÃO PARA GARANTIR QUE A QUANTIDADE DE ETIQUETAS A SEREM IMPRESSA SEJA INSERIDA
    IF (empty(xTGet4))
        MsgAlert("Obrigatório informar quantidade de etiquetas.", "Aviso")
        RETURN
    ENDIF
    /*
    //VERIFICA SE JÁ EXISTE ORDEM DE PRODUÇÃO PARA EMBALAGEM
    //CASO EXISTA NÃO SE FAZ NADA, PORÉM SE NÃO EXISTIR É CRIADA UMA OP
    lExisteOP := OrdemDeProducao(ALLTRIM(_cDescProd), xTGet2, xTGet1, xTGet3)
    
    IF(lExisteOP = .F.)
        //MSGINFO( "Será criada OP", "Informação" )
    ELSE
        //MSGINFO( "Já existe OP", "Informação" )        
    ENDIF
	*/
    Imprime()
RETURN

STATIC FUNCTION Dados()
    _cDescProd := GetAdvFval('ZZ7','ZZ7_CORTE',FWxFilial('ZZ7') + alltrim(xTGet1),1)
    taraSB1    := GetAdvFval('SB1','B1_CTARAP',FWxfilial('SB1')+ alltrim(xTGet1),1) // Linhas inseridas para buscar"_NTARAp"
	taraZAB    := GetAdvFval('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(taraSB1),1) // os campos de codigo das taras primarias
	_nTaraProd := (taraZAB * 1000)

	oDialog:refresh()
RETURN

STATIC FUNCTION QuantEtq()
    a := GetAdvFval('SB1','B1_QCAIX',FWxFilial('SB1') + alltrim(xTGet1),1)
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

    EtiquetaInterna_ZPL()    

    MSCBEND()
	MSCBCLOSEPRINTER()
	
    GravaZBG()
    LimpaCampos()

	//msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

	oTButton1:enable()
	oDialog:refresh()
RETURN

STATIC FUNCTION LimpaCampos()
    xTGet1     := Space(6)
    xTGet2     := SToD("")
    xTGet3     := SToD("")
    xTGet4     := Space(6)
    _cDescProd := Space(40)
    _nTaraProd := 0.000
    _cQtdEtq   := Space(6)

	oDialog:refresh()
RETURN

STATIC FUNCTION GravaZBG()
    _cCodGrpProd := GetAdvFval('SB1','B1_GRUPO',FWxFilial('SB1') + alltrim(xTGet1),1)

    //GERA UM NÚMERO SEQUENCIAL PARA SER USADO COMO ID EM "ZBG_NUM"	
    _nSequen := GetSx8num('ZBG','ZBG_NUM')
    ConfirmSx8()
	_cSequen := cValToChar(PADL(_nSequen, 10, '0'))

	//QUERY PARA BUSCAR A PREVISAO DA DESSOSSA //FUNÇÕES GetAdvFval() E GETADVFVAL() NÃO FUNCIONARAM
    //SOMENTE SERA BUSCADA PREVISAO DA DESOSSA CASO OS PRODUTOS NÃO FOREM PORCIONADOS
    //indice8 := ALLTRIM(FWxFilial('SZU')+DToS(xTGet3)+xTGet1+DToS(xTGet2)+DTos(SToD('')))
    //a := GetAdvFval('SZU',1,indice8,'ZU_PREDES')
    //b := GetAdvFval( 'SZU' , 'ZU_PREDES' , indice8 ,8, "Sem retorno de informações" ,.t.)

    IF !(_cCodGrpProd $ GetMV('MV_GRPPORC'))
        _cQueryZU := "SELECT ZU_PREDES AS PREDES"
        _cQueryZU += "FROM " + RetSQLTab('SZU')
        _cQueryZU += "WHERE" + RetSQLFil('SZU') + " AND ZU_COD = " + "'"+ xTGet1 + "'" + " AND ZU_DTRPRO = " + DToS(xTGet3) + " AND ZU_DTABT = " + DToS(xTGet2)    

        _cQueryZU  := ChangeQuery(_cQueryZU)

        //IF SELECT("TMPZU") != 0
        //    TMPZU->(dbCloseArea())
        //ENDIF

        TCQUERY _cQueryZU NEW ALIAS "TMPZU"

        TMPZU->(dbGoTop())

        IF!(_cSequen $ ZBG->ZBG_NUM)
            DbSelectArea('ZBG')
            reclock('ZBG',.t.)
            ZBG->ZBG_FILIAL := FWCodFil()
            ZBG->ZBG_NUM    := _cSequen
            ZBG->ZBG_DTPROD := xTGet3
            ZBG->ZBG_DTABAT := xTGet2
            ZBG->ZBG_PREETQ := ''
            ZBG->ZBG_USUARI := UsrRetName(RetCodUsr())
            ZBG->ZBG_NUMPRE := TMPZU->PREDES
            ZBG->ZBG_CAIXA  := ''
            ZBG->ZBG_PRODUT := xTGet1
            ZBG->ZBG_DTACRI := Date()
            ZBG->ZBG_HORA   := Time()
            msunlock()     
        ELSE
            GravaZBG()
        ENDIF

        IF SELECT("TMPZU") != 0
            TMPZU->(dbCloseArea())
        ENDIF
    ENDIF    
RETURN

STATIC FUNCTION GravaSZU()
    //QUERY PARA BUSCAR A PREVISAO DA DESSOSSA //FUNÇÕES GetAdvFval() E GETADVFVAL() NÃO FUNCIONARAM
    //SOMENTE SERA BUSCADA PREVISAO DA DESOSSA CASO OS PRODUTOS NÃO FOREM PORCIONADOS
    _cQueryZ2 := "SELECT Z2_NUM AS NUM"
    _cQueryZ2 += " FROM " + retSqlTab('SZ2')
    _cQueryZ2 += " WHERE " + retSqlFil('SZ2')
    _cQueryZ2 += " AND " + retSqlDel('SZ2')
    _cQueryZ2 += " AND Z2_DATAABT = '" + dtos(xTGet2) + "' "
    _cQueryZ2 += " AND Z2_CORORI IN ('C','T') AND Z2_CLASSIF = 'HK' ORDER BY Z2_NUMAM DESC"

    _cQueryZ2  := ChangeQuery(_cQueryZ2)

    //IF Select("TMPZ2") != 0
    //    TMPZ2->(dbCloseArea())
    //ENDIF

    TCQUERY _cQueryZ2 NEW ALIAS "TMPZ2"
    
    IF !(_cCodGrpProd $ GetMV('MV_GRPPORC'))
        _cNumero := GETSX8NUM('SZU','ZU_NUM')
        ConfirmSX8()        

        RecLock("SZU",.T.)
        SZU->ZU_FILIAL  := FWXFilial( 'SZU' )
        SZU->ZU_NUM     := _cNumero
        SZU->ZU_DATA    := Date()
        SZU->ZU_DATA    := DDATABASE
        SZU->ZU_COD     := ALLTRIM(xTGet1)
        SZU->ZU_DESC    := _cDescProd
        SZU->ZU_PRIORI  := 'C'
        SZU->ZU_CONTEXA := 'N'
        SZU->ZU_DTRPRO  := Date()
        SZU->ZU_DTRPRO  := DDATABASE
        SZU->ZU_DTPROD  := xTGet3
        SZU->ZU_NOTIMP  := 'A'
        SZU->ZU_MDESP   := 'N'
        SZU->ZU_NUMETQ  := 1
        SZU->ZU_HORA    := Time()
        SZU->ZU_USUAR   := UsrRetName(RetCodUsr())
        SZU->ZU_QPETIQ  := 30
        SZU->ZU_LISTETQ := 'S'
        SZU->ZU_FECHADO := 'B'
        SZU->ZU_TIPO    := 'P'
        SZU->ZU_TF      := 'N'
        SZU->ZU_QPCAIX  := 10
        SZU->ZU_TOLERA  := 10
        IF(_cCodGrpProd $ GetMV('MV_GRPPORC'))
            SZU->ZU_MPPORC  := 'S'
        ENDIF
        IF(xTGet1 $ GETMV('SI_PETQES'))
            SZU->ZU_ETIQ    := 'ES'
        ENDIF
        SZU->ZU_REPAUT  := 'S'
        SZU->ZU_QPPESO  := CalcPesoMed(10,ALLTRIM(xTGet1))
        SZU->ZU_DTABT   := xTGet2
        SZU->ZU_PREDES  := TMPZ2->NUM
        MsUnLock()

        IF(TMPZ2->(EOF()))
            RETURN .F.
        ELSE
            RETURN .T.
        ENDIF
    ENDIF
RETURN

STATIC FUNCTION OrdemDeProducao(DescProd, DtAbt, CodProd, DtProd)
    //ATIVA OU DESATIVA GERAÇÃO AUTOMATICA DE OPs AUTOMATICAS
    Local _cAtivaOP := GetMV('SI_LIBR88')

    //QUERY PARA VERIFICAR SE JÁ EXISTE OP (ORDEM DE PRODUÇÃO) PARA EMBALAGEM CRIADA PARA OS DADOS INSERIDOS
    cQuery := " SELECT ZU_NUM AS NUM, ZU_COD AS CODIGO, ZU_DTRPRO AS DTPRODUCAO, ZU_PREDES AS PREDES, ZU_DTABT AS DTABATE"
	cQuery += " FROM " + retSqlTab('SZU')
	cQuery += " WHERE " + retSqlFil('SZU')
	cQuery += " AND " + retSqlDel('SZU')
	cQuery += " AND ZU_DTRPRO = '" + DToS(DtProd) + "' "
	cQuery += " AND ZU_COD = '" + ALLTRIM(CodProd) + "' "
	
	cQuery  := ChangeQuery(cQuery)

    IF SELECT("TMP") != 0
		TMP->(dbCloseArea())
	ENDIF

	TCQUERY cQuery NEW ALIAS "TMP"

    IF(_cAtivaOP = '1')
        IF Empty(TMP->NUM)
            GravaSZU()
        ENDIF
    ENDIF

    IF(TMP->(EOF()))
        RETURN .F.
    ELSE
        RETURN .T.
    ENDIF
RETURN

STATIC FUNCTION EtiquetaInterna_ZPL() 
    SB1->(dbSetOrder(1))
    SB1->(MsSeek(FWxFilial('SB1') + alltrim(xTGet1)))
    _cCodGrpProd    := SB1->B1_GRUPO    //BUSCA GRUPO DE PRODUTOS
    _cDestino       := SB1->B1_DESTINO  //BUSCA O DESTINO DO PRODUTO    
    _cCadMercadoria := SB1->B1_CADMERC  //BUSCA O CADASTRO DA MERCADORIA DO PRODUTO
    _PesEmb := ALLTRIM(STR((taraZAB * 1000)))
    //CONDIÇÃO PARA VERIFICAR SE PRODUTO FOR DO MIUDOS OU FOR DA EMBALAGEM PARA DATA DE VALIDADE
	IF(alltrim(_cCodGrpProd) $ GetMV('MV_GRPMDS'))
		_DtVal  := xTGet2 + SB1->B1_VALID
	ELSE
		_DtVal  := xTGet3 + SB1->B1_VALID
	ENDIF

	MSCBWrite("^XA")
	MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWR")

    MSCBWrite("^FO 630,040 ^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")    
    aCORTE := StrTokArr(ZZ7->ZZ7_CORTE, '%')
    MSCBWrite("^FO 600,040 ^FH\^FD" + aCORTE[1] +"%"+"^FS")
    IF (Len(aCORTE)>1)
        MSCBWrite("^FO 570,040 ^FH\^FD" + alltrim(aCORTE[2])+ "^FS")
    ENDIF

    IF !(Empty(ZZ7->ZZ7_MODPRE))
        MSCBWrite("^FO 030,040 ^FH\^FD" + "Modo de preparo: " + ZZ7->ZZ7_MODPRE + "^FS")
    ENDIF
    
    IF !(Empty(ZZ7->ZZ7_INGRE2))
        MSCBWrite("^FO 545,040 ^FH\^FD" + "Porcentagem m\A0xima de gordura: " + ZZ7->ZZ7_INGRE2 + "^FS")
        MSCBWrite("^FO 520,040 ^FH\^FD" + "Data de Produ\87\C6o/Lote: " + "^FS")
        MSCBWrite("^FO 500,040 ^FH\^FD" + "Data de validade: " + "^FS")
        MSCBWrite("^FO 480,040 ^FH\^FD" + "Tara: " + "^FS")

        MSCBWrite("^FO 520,280")
        MSCBWrite("^FH\^FD"  + DToC(xTGet3) + "^FS")
        MSCBWrite("^FO 500,280")
        MSCBWrite("^FH\^FD"  + DToC(_DtVal) + "^FS")
        MSCBWrite("^FO 480,280")
        MSCBWrite("^FH\^FD" + _PesEmb + " g" + "^FS")

        MsgTemp := Alltrim(SB1->B1_MENETQ2)    
        IF("CELSIUS" $ MsgTemp)
            MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
            MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
        ELSEIF("CELCIUS" $ MsgTemp)
            MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
            MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
        ENDIF
        //MSCBWrite("^FO 450,040 ^FH\^FD" + Capital(MsgTemp) + "^FS")
        MSCBWrite("^FO 440,040 ^FH\^FD" + MsgTemp + "^FS")
        MSCBWrite("^FO 410,040 ^FH\^FD" + "Registro no Minist\82rio da Agricultura SIF/DIPOA sob" + "^FS")

        MSCBWrite("^FO 390,140 ^FH\^FD" + "n.\A7 " + ALLTRIM(ZZ7->ZZ7_MSIF) + "^FS")
    ELSE        
        MSCBWrite("^FO 540,040 ^FH\^FD" + "Data de Produ\87\C6o/Lote: " + "^FS")
        MSCBWrite("^FO 510,040 ^FH\^FD" + "Data de validade: " + "^FS")
        MSCBWrite("^FO 480,040 ^FH\^FD" + "Tara: " + "^FS")
        
        MSCBWrite("^FO 540,280")
        MSCBWrite("^FH\^FD"  + DToC(xTGet3) + "^FS")
        MSCBWrite("^FO 510,280")
        MSCBWrite("^FH\^FD"  + DToC(_DtVal) + "^FS")
        MSCBWrite("^FO 480,280")
        MSCBWrite("^FH\^FD" + _PesEmb + " g" + "^FS")

        MsgTemp := Alltrim(SB1->B1_MENETQ2)    
        IF("CELSIUS" $ MsgTemp)
            MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
            MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
        ELSEIF("CELCIUS" $ MsgTemp)
            MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
            MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
        ENDIF
        //MSCBWrite("^FO 450,040 ^FH\^FD" + Capital(MsgTemp) + "^FS")
        MSCBWrite("^FO 450,040 ^FH\^FD" + MsgTemp + "^FS")
        MSCBWrite("^FO 420,040 ^FH\^FD" + "Registro no Minist\82rio da Agricultura SIF/DIPOA sob" + "^FS")

        MSCBWrite("^FO 390,140 ^FH\^FD" + "n.\A7 " + ALLTRIM(ZZ7->ZZ7_MSIF) + "^FS")
    ENDIF
    
    _cIDTabNut := ALLTRIM(GetAdvFval('ZZ7','ZZ7_TABNUT',FWxFilial('ZZ7')+xTGet1,1,'Sem informação',.t.))
    IF (ALLTRIM(GetAdvFval('ZBH','ZBH_VALPOR',_cIDTabNut,1,'Sem informação',.t.)) = '')
        TabNutSim1()
    ELSE
        TabNutSim2()
    ENDIF

    MSCBWrite("^FWN")
    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^CFA,20")
    
    a := "Ingredientes: " + SubStr(AllTrim(ZZ7->ZZ7_INGRED),001,043)//a := "Ingredientes: " + SubStr(AllTrim(ZZ7->ZZ7_INGRED),001,048)    
    b := SubStr(AllTrim(ZZ7->ZZ7_INGRED),044,061)    
    c := SubStr(AllTrim(ZZ7->ZZ7_INGRED),105,061)    
    d := SubStr(AllTrim(ZZ7->ZZ7_INGRED),165,061)

    IF (ZZ7->ZZ7_CODPRO <> '027019')
        MSCBWrite("^FO 050,540")
        MSCBWrite("^FH\^FD" + a + "^FS")
        MSCBWrite("^FO 050,560")
        MSCBWrite("^FH\^FD" + b + "^FS")
        MSCBWrite("^FO 050,580")
        MSCBWrite("^FH\^FD" + c + "^FS")
        MSCBWrite("^FO 050,600")
        MSCBWrite("^FH\^FD" + d + "^FS")
    ELSE
        //MSCBWrite("^FO 050,580")
        //MSCBWrite("^FH\^FD" + "Carne bovina, agua (8,3%), sal, estabilizante: trifosfato pentassodico (INS 451i), sal, acucar, dextrose, espessante: carragena (INS 407), antioxidante: eritorbato de sodio (INS 316), Papaina, glutamato monossodico, Aroma identico ao natural de: cebola, alho e pimenta do reino, oleo de pimenta preta e aroma identico ao natural da salsa." + "^FS")
        MSCBWrite("^FO 050,520")
        MSCBWrite("^FH\^FD" + "Ingrediente: Carne bovina, agua (8,3%), sal, estabilizante:" + "^FS")
        MSCBWrite("^FO 050,540")
        MSCBWrite("^FH\^FD" + "trifosfato pentassodico (INS 451i), sal, acucar, dextrose," + "^FS")
        MSCBWrite("^FO 050,560")
        MSCBWrite("^FH\^FD" + "espessante: carragena (INS 407), antioxidante: eritorbato de" + "^FS")
        MSCBWrite("^FO 050,580")
        MSCBWrite("^FH\^FD" + "sodio (INS 316) Papaina, glutamato monossodico, Aroma identico ao" + "^FS")
        MSCBWrite("^FO 050,600")
        MSCBWrite("^FH\^FD" + "natural de: cebola, alho e pimenta do reino, oleo de pimenta preta" + "^FS")
        MSCBWrite("^FO 050,620")
        MSCBWrite("^FH\^FD" + "e aroma identico ao natural da salsa." + "^FS")
    ENDIF

    IF (!EMPTY(ZZ7->ZZ7_TRAJ))
        MSCBWrite("^FO" + "050,610" + "^FH\^FD" + Alltrim(ZZ7->ZZ7_TRAJ) + " ^FS")
    ENDIF        

    MSCBWrite("^PQ" + _cQtdEtq + ",0,1,N")
    MSCBWrite("^XZ")
RETURN

STATIC FUNCTION TabNutSim1()    
    _cIDTaBN := ALLTRIM(GetAdvFval('ZZ7','ZZ7_TABNUT',FWxFilial('ZZ7')+xTGet1,1,'Sem informação',.t.))

    //_cPorCpe := ALLTRIM(GetAdvFval('ZBH','ZBH_PORCPE',_cIDTaBN,1,'Sem informação',.t.))
    _cPorEMB := ALLTRIM(GetAdvFval('ZBH','ZBH_POREMB',_cIDTaBN,1,'Sem informação',.t.))

    MSCBWrite("^CFA,20")
    MSCBWrite("^PW609")

    MSCBWrite("^CWA,E:ARIALBD.TTF")
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO 355,100")
    MSCBWrite("^FH\^FD" + " INFORMA\80\C7O NUTRICIONAL" + "^FS")

    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^CFA,22")
    
    IF empty(_cPorEMB)
        MSCBWrite("^FO 330,040")
        MSCBWrite("^FH\^FD Por\87\C6o: " + ALLTRIM(GetAdvFval('ZBH','ZBH_PORCPE',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^CWA,E:ARIALBD.TTF")   
        MSCBWrite("^FO 300,300 ^FD 100 g ^FS")
        MSCBWrite("^FO 300,410 ^FD %VD* ^FS")
        MSCBWrite("^CWA,E:ARIAL.TTF")
        
        MSCBWrite("^FO" + "270,040")
        MSCBWrite("^FH\^FD" + "Valor energ\82tico (kcal)" + "^FS")
        MSCBWrite("^FO" + "270,040")
        MSCBWrite("^FB" + "600,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VEN100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
        MSCBWrite("^FO" + "270,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VENVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
        
        MSCBWrite("^FO" + "240,040")
        MSCBWrite("^FH\^FD" + "Prote\A1nas (g)" + "^FS")
        MSCBWrite("^FO" + "240,040")
        MSCBWrite("^FB" + "600,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PRO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
        MSCBWrite("^FO" + "240,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PROVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
        
        MSCBWrite("^FO" + "210,040")
        MSCBWrite("^FH\^FD" + "Gorduras totais (g)" + "^FS")
        MSCBWrite("^FO" + "210,040")
        MSCBWrite("^FB" + "600,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
        MSCBWrite("^FO" + "210,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTOVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "180,050")
        MSCBWrite("^FH\^FD" + "Gorduras saturadas (g)" + "^FS")
        MSCBWrite("^FO" + "180,040")
        MSCBWrite("^FB" + "600,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSA100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
        MSCBWrite("^FO" + "180,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSAVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

        MSCBWrite("^FO" + "150,040")
        MSCBWrite("^FH\^FD" + "Fibras alimentares (g)" + "^FS")
        MSCBWrite("^FO" + "150,040")
        MSCBWrite("^FB" + "600,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FAL100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
        MSCBWrite("^FO" + "150,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FALVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "120,040")
        MSCBWrite("^FH\^FD" + "S\A2dio (mg)" + "^FS")
        MSCBWrite("^FO" + "120,040")
        MSCBWrite("^FB" + "600,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SOD100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
        MSCBWrite("^FO" + "120,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SODVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
        
        MSCBWrite("^CFA,19")
        MSCBWrite("^FO" + "100,040")
        MSCBWrite("^FH\^FD" + "N\C6o cont\82m quantidades significativas de carboidratos," + "^FS")

        MSCBWrite("^FO" + "080,040")
        MSCBWrite("^FH\^FD" + "a\87\A3cares totais, a\87\A3cares adicionados, gorduras trans." + "^FS")    

        MSCBWrite("^FO" + "055,040")
        MSCBWrite("^FH\^FD" + "*Percentual de valores di\A0rios fornecidos pela por\87\C6o" + "^FS")

        //INSERE QUADRADO
        MSCBWrite("^FO 050,035")
        MSCBWrite("^GB 340,480,2^FS")

        //INSERE LINHAS VERTICAIS    
        MSCBWrite("^FO 118,290")
        MSCBWrite("^GB 210,1,2^FS")

        MSCBWrite("^FO 118,390")
        MSCBWrite("^GB 210,1,2^FS")

        //INSERE LINHAS HORIZONTAIS    
        MSCBWrite("^FO 355,040")
        MSCBWrite("^GB1,475,2^FS")
        
        MSCBWrite("^FO 325,040")
        MSCBWrite("^GB1,475,5^FS")
        
        MSCBWrite("^FO 295,040")
        MSCBWrite("^GB1,475,2^FS")
        
        MSCBWrite("^FO 265,040")
        MSCBWrite("^GB1,475,2^FS")

        MSCBWrite("^FO 240,040")
        MSCBWrite("^GB1,475,2^FS")

        MSCBWrite("^FO 210,040")
        MSCBWrite("^GB1,475,2^FS")

        MSCBWrite("^FO 180,040")
        MSCBWrite("^GB1,475,2^FS")
        
        MSCBWrite("^FO 150,040")
        MSCBWrite("^GB1,475,2^FS")

        MSCBWrite("^FO 120,040")
        MSCBWrite("^GB1,475,2^FS")    

        MSCBWrite("^FO 075,040")
        MSCBWrite("^GB1,475,4^FS")
        
    ELSE
        //INSERE QUADRADO
        MSCBWrite("^FO 060,035")
        MSCBWrite("^GB 330,500,2^FS")

        //INSERE LINHAS VERTICAIS    
        MSCBWrite("^FO 130,290")
        MSCBWrite("^GB 180,1,2^FS")

        MSCBWrite("^FO 130,390")
        MSCBWrite("^GB 180,1,2^FS")

        //INSERE LINHAS HORIZONTAIS
        MSCBWrite("^FO 355,040")
        MSCBWrite("^GB1,490,2^FS")

        MSCBWrite("^FO 305,040")
        MSCBWrite("^GB1,490,5^FS")

        MSCBWrite("^FO 280,040")
        MSCBWrite("^GB1,490,2^FS")

        MSCBWrite("^FO 255,040")
        MSCBWrite("^GB1,490,2^FS")

        MSCBWrite("^FO 230,040")
        MSCBWrite("^GB1,490,2^FS")

        MSCBWrite("^FO 205,040")
        MSCBWrite("^GB1,490,2^FS")

        MSCBWrite("^FO 180,040")
        MSCBWrite("^GB1,490,2^FS")

        MSCBWrite("^FO 155,040")
        MSCBWrite("^GB1,490,2^FS")

        MSCBWrite("^FO 130,040")
        MSCBWrite("^GB1,490,2^FS")    

        MSCBWrite("^FO 080,040")
        MSCBWrite("^GB1,490,4^FS")

        _cIDTaBN := ALLTRIM(GetAdvFval('ZZ7','ZZ7_TABNUT',FWxFilial('ZZ7')+xTGet1,1,'Sem informação',.t.))

        _cPorEMB := ALLTRIM(GetAdvFval('ZBH','ZBH_POREMB',_cIDTaBN,1,'Sem informação',.t.))

        MSCBWrite("^CFA,20")
        MSCBWrite("^PW609")

        MSCBWrite("^CWA,E:ARIALBD.TTF")
        MSCBWrite("^CFA,25")
        MSCBWrite("^FO 355,100")
        MSCBWrite("^FH\^FD" + " INFORMA\80\C7O NUTRICIONAL" + "^FS")

        MSCBWrite("^CWA,E:ARIAL.TTF")
        MSCBWrite("^CFA,22")
        
        MSCBWrite("^FO 330,040")
        MSCBWrite("^FH\^FD Por\87\C6o por embalagem: " + ALLTRIM(GetAdvFval('ZBH','ZBH_POREMB',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
        MSCBWrite("^FO 305,040")
        MSCBWrite("^FH\^FD Por\87\C6o: " + ALLTRIM(GetAdvFval('ZBH','ZBH_PORCPE',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

        MSCBWrite("^CWA,E:ARIALBD.TTF")    
        MSCBWrite("^FO 280,300 ^FD 100 g ^FS")
        MSCBWrite("^FO 280,410 ^FD %VD* ^FS")
        MSCBWrite("^CWA,E:ARIAL.TTF")

        MSCBWrite("^FO" + "255,040")
        MSCBWrite("^FH\^FD" + "Valor energ\82tico (kcal)" + "^FS")
        MSCBWrite("^FO" + "255,040")
        MSCBWrite("^FB" + "600,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VEN100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
        MSCBWrite("^FO" + "255,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VENVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "230,040")
        MSCBWrite("^FH\^FD" + "Prote\A1nas (g)" + "^FS")
        MSCBWrite("^FO" + "230,040")
        MSCBWrite("^FB" + "600,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PRO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
        MSCBWrite("^FO" + "230,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PROVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "205,040")
        MSCBWrite("^FH\^FD" + "Gorduras totais (g)" + "^FS")
        MSCBWrite("^FO" + "205,040")
        MSCBWrite("^FB" + "600,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
        MSCBWrite("^FO" + "205,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTOVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "180,050")
        MSCBWrite("^FH\^FD" + "Gorduras saturadas (g)" + "^FS")
        MSCBWrite("^FO" + "180,040")
        MSCBWrite("^FB" + "600,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSA100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
        MSCBWrite("^FO" + "180,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSAVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

        MSCBWrite("^FO" + "155,040")
        MSCBWrite("^FH\^FD" + "Fibras alimentares (g)" + "^FS")
        MSCBWrite("^FO" + "155,040")
        MSCBWrite("^FB" + "600,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FAL100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
        MSCBWrite("^FO" + "155,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FALVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^FO" + "130,040")
        MSCBWrite("^FH\^FD" + "S\A2dio (mg)" + "^FS")
        MSCBWrite("^FO" + "130,040")
        MSCBWrite("^FB" + "600,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SOD100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
        MSCBWrite("^FO" + "130,095")
        MSCBWrite("^FB" + "700,001,0,C")
        MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SODVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

        MSCBWrite("^CFA,19")
        MSCBWrite("^FO" + "105,040")
        MSCBWrite("^FH\^FD" + "N\C6o cont\82m quantidades significativas de carboidratos," + "^FS")

        MSCBWrite("^FO" + "085,040")
        MSCBWrite("^FH\^FD" + "a\87\A3cares totais, a\87\A3cares adicionados, gorduras trans." + "^FS")    

        MSCBWrite("^FO" + "060,040")
        MSCBWrite("^FH\^FD" + "*Percentual de valores di\A0rios fornecidos pela por\87\C6o" + "^FS")
    ENDIF
RETURN

STATIC FUNCTION TabNutSim2()    
    //INSERE QUADRADO
    MSCBWrite("^FO 060,035")
    MSCBWrite("^GB 330,500,2^FS")

    //INSERE LINHAS VERTICAIS    
    MSCBWrite("^FO 130,290")
    MSCBWrite("^GB 180,1,2^FS")

    MSCBWrite("^FO 130,370")
    MSCBWrite("^GB 180,1,2^FS")

    MSCBWrite("^FO 130,450")
    MSCBWrite("^GB 180,1,2^FS")

    //INSERE LINHAS HORIZONTAIS
    MSCBWrite("^FO 355,040")
    MSCBWrite("^GB1,490,2^FS")

    MSCBWrite("^FO 305,040")
    MSCBWrite("^GB1,490,5^FS")

    MSCBWrite("^FO 280,040")
    MSCBWrite("^GB1,490,2^FS")

    MSCBWrite("^FO 255,040")
    MSCBWrite("^GB1,490,2^FS")

    MSCBWrite("^FO 230,040")
    MSCBWrite("^GB1,490,2^FS")

    MSCBWrite("^FO 205,040")
    MSCBWrite("^GB1,490,2^FS")

    MSCBWrite("^FO 180,040")
    MSCBWrite("^GB1,490,2^FS")

    MSCBWrite("^FO 155,040")
    MSCBWrite("^GB1,490,2^FS")

    MSCBWrite("^FO 130,040")
    MSCBWrite("^GB1,490,2^FS")    

    MSCBWrite("^FO 080,040")
    MSCBWrite("^GB1,490,4^FS")

    _cIDTaBN := ALLTRIM(GetAdvFval('ZZ7','ZZ7_TABNUT',FWxFilial('ZZ7')+xTGet1,1,'Sem informação',.t.))

    _cPorEMB := ALLTRIM(GetAdvFval('ZBH','ZBH_POREMB',_cIDTaBN,1,'Sem informação',.t.))

    MSCBWrite("^CFA,20")
    MSCBWrite("^PW609")

    MSCBWrite("^CWA,E:ARIALBD.TTF")
    MSCBWrite("^CFA,25")
    MSCBWrite("^FO 355,100")
    MSCBWrite("^FH\^FD" + " INFORMA\80\C7O NUTRICIONAL" + "^FS")

    MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^CFA,22")
    
    if empty(_cPorEMB)
        MSCBWrite("^FO 305,040")
        MSCBWrite("^FH\^FD Por\87\C6o: " + ALLTRIM(GetAdvFval('ZBH','ZBH_PORCPE',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")  
    else
        MSCBWrite("^FO 330,040")
        MSCBWrite("^FH\^FD Por\87\C6o por embalagem: " + ALLTRIM(GetAdvFval('ZBH','ZBH_POREMB',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
        MSCBWrite("^FO 305,040")
        MSCBWrite("^FH\^FD Por\87\C6o: " + ALLTRIM(GetAdvFval('ZBH','ZBH_PORCPE',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    endif

    MSCBWrite("^CWA,E:ARIALBD.TTF")    
    MSCBWrite("^FO 280,305 ^FD 100 g ^FS")
    IF (AllTrim(ALLTRIM(GetAdvFval('ZBH','ZBH_VALPOR',_cIDTaBN,1,'Sem informação',.t.))) = '30g')
        MSCBWrite("^FO 280,385 ^FD 30 g ^FS")
    ELSEIF (AllTrim(ALLTRIM(GetAdvFval('ZBH','ZBH_VALPOR',_cIDTaBN,1,'Sem informação',.t.))) = '50g')
        MSCBWrite("^FO 280,385 ^FD 50 g ^FS")
    ELSEIF (AllTrim(ALLTRIM(GetAdvFval('ZBH','ZBH_VALPOR',_cIDTaBN,1,'Sem informação',.t.))) = '80g')
        MSCBWrite("^FO 280,385 ^FD 80 g ^FS")
    ENDIF

    MSCBWrite("^FO 280,455 ^FD %VD* ^FS")
    MSCBWrite("^CWA,E:ARIAL.TTF")

    MSCBWrite("^FO" + "255,040")
    MSCBWrite("^FH\^FD" + "Valor energ\82tico (kcal)" + "^FS")
    MSCBWrite("^FO" + "255,030")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VEN100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")   
    MSCBWrite("^FO" + "255,110")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VEN80',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "255,140")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VENVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^FO" + "230,040")
    MSCBWrite("^FH\^FD" + "Prote\A1nas (g)" + "^FS")
    MSCBWrite("^FO" + "230,030")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PRO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    MSCBWrite("^FO" + "230,110")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PRO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    MSCBWrite("^FO" + "230,140")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PROVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^FO" + "205,040")
    MSCBWrite("^FH\^FD" + "Gorduras totais (g)" + "^FS")
    MSCBWrite("^FO" + "205,030")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    MSCBWrite("^FO" + "205,110")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    MSCBWrite("^FO" + "205,140")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTOVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^FO" + "180,050")
    MSCBWrite("^FH\^FD" + "Gorduras saturadas (g)" + "^FS")
    MSCBWrite("^FO" + "180,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSA100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    MSCBWrite("^FO" + "180,110")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSA100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    MSCBWrite("^FO" + "180,140")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSAVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    

    MSCBWrite("^FO" + "155,040")
    MSCBWrite("^FH\^FD" + "Fibras alimentares (g)" + "^FS")
    MSCBWrite("^FO" + "155,030")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FAL100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    MSCBWrite("^FO" + "155,110")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FAL100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    MSCBWrite("^FO" + "155,140")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_FALVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^FO" + "130,040")
    MSCBWrite("^FH\^FD" + "S\A2dio (mg)" + "^FS")
    MSCBWrite("^FO" + "130,030")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SOD100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    MSCBWrite("^FO" + "130,110")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SOD100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    MSCBWrite("^FO" + "130,140")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SODVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^CFA,19")
    MSCBWrite("^FO" + "105,040")
    MSCBWrite("^FH\^FD" + "N\C6o cont\82m quantidades significativas de carboidratos," + "^FS")

    MSCBWrite("^FO" + "085,040")
    MSCBWrite("^FH\^FD" + "a\87\A3cares totais, a\87\A3cares adicionados, gorduras trans." + "^FS")    

    MSCBWrite("^FO" + "060,040")
    MSCBWrite("^FH\^FD" + "*Percentual de valores di\A0rios fornecidos pela por\87\C6o" + "^FS")    
RETURN
