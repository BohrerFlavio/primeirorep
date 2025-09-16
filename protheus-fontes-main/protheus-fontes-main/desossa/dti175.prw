/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI175            º Autor ³ Lucas Bolzan º Data ³ 18/05/23  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de etiqueta interna                              º±±
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
#INCLUDE "FILEIO.CH"

USER FUNCTION DTI175()
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
    _cOpera     := UsrRetName(retCodUsr())    
    DtaMin7   := DDATABASE-7
    DtaMin14  := DDATABASE-14
    DtaMin30  := DDATABASE-30
    DtaMin365 := DDATABASE-365
    DtaMax7   := DDATABASE+7
    DtaMax14  := DDATABASE+14
    DtaMax30  := DDATABASE+30
    DtaMax365 := DDATABASE+365
    _cCodGrpProd    := GetAdvFval( 'SB1' , 'B1_GRUPO' ,FWxFilial( 'SB1' ) + alltrim(xTGet1),1) //BUSCA GRUPO DE PRODUTOS
    _cDestino       := GetAdvFval( 'SB1' , 'B1_DESTINO' ,FWxFilial( 'SB1' ) + alltrim(xTGet1),1) //BUSCA O DESTINO DO PRODUTO    
    _cCadMercadoria := GetAdvFval( 'SB1' , 'B1_CADMERC' ,FWxFilial( 'SB1' ) + alltrim(xTGet1),1) //BUSCA O CADASTRO DA MERCADORIA DO PRODUTO

    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
        oFont:= TFont():New('Arial',, -12, .T.)

        oSay1:= TSay():New(010,15,{||'Código do produto:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay2:= TSay():New(025,15,{||'Descrição do produto:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay3:= TSay():New(040,15,{||'Data de abate/produção:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay4:= TSay():New(055,15,{||'Data de embalagem:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
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
        MsgAlert("Obrigatrório informar um produto.", "Aviso")
    ENDIF

    DbSelectArea('ZZ7')
    ZZ7->(DbSetOrder(1))
    IF !ZZ7->(DbSeek(FWxFilial('ZZ7')+xTGet1))
        MsgAlert("Produto informado não existe.", "Aviso")
        RETURN
    ENDIF

    //VALIDAÇÃO PARA GARANTIR QUE UMA DATA DE ABATE FOI INFORMADA, SOMENTE PARA PRODUTOS DO PORCIONADOS NÃO SERÁ OBRIGADO INFORMAR DATA DE ABATE
    IF !(_cCodGrpProd $ GetMV('MV_GRPPORC'))
        IF (empty(xTGet2))
            MsgAlert("Obrigatrório informar uma data de abate/produção.", "Aviso")
            RETURN
        ENDIF
    ENDIF

    //VALIDAÇÃO PARA GARANTIR QUE A DATA DE ABATE NÃO SEJA A DO DIA ATUAL. SOMENTE MIÚDOS PODE INFORMAR DATA DE ABATE IGUAL A DATA DA EMBALAGEM
    IF !(_cCodGrpProd $ GetMV('MV_GRPMDS'))
        IF(xTGet2 = DDATABASE)
            MsgAlert("Data de abate não pode ser igual a data do dia.", "Aviso")
            RETURN
        ENDIF
    ENDIF

    //VALIDAÇÃO PARA GARANTIR QUE UMA DATA DE EMBALAGEM FOI INFORMADA. SOMENTE OS PRODUTOS 000300 e 001834 NÃO NECESSITAM DATA DE EMBALAGEM
    IF !(xTGet1 $ '000300/001834')
        IF (empty(xTGet3))
            MsgAlert("Obrigatrório informar uma data de embalagem.", "Aviso")
            RETURN
        ENDIF
    ENDIF

    //VALIDAÇÃO PARA DATA DE ABATE SEMPRE SER MENOR QUE A DATA DE EMBALAGEM
    IF !(xTGet1 $ '000300/001834')
        IF !(_cCodGrpProd $ GetMV('MV_GRPMDS'))
            IF(xTGet2 >= xTGet3)
                    MsgAlert("A data de abate não pode ser maior que a data de embalagem.")
                RETURN
            ENDIF
        ENDIF
    ENDIF

    //VALIDAÇÃO PARA VERIFICAR AS PERMISSÕES DE DATA DE ABATE E DATA DE PRODUÇÃO PARA O USUÁRIO
    IF !(_cCodGrpProd $ GetMV('MV_GRPPORC')) .AND. !(_cCodGrpProd $ GetMV('MV_GRPMDS'))
        IF ((_cOpera $ GetMV('SI_USRN1')) .OR. (_cOpera $ GetMV('SI_USRN2')) .OR. (_cOpera $ GetMV('SI_USRN3')) .OR. (_cOpera $ GetMV('SI_USRN4')))
            IF ((_cOpera $ GetMV('SI_USRN1')))
                IF (xTGet2 < DtaMin365)
                    MsgAlert("Você não pode imprimir etiquetas com data de abate anterior a 1 (um) ano","Aviso")
                    RETURN        
                ENDIF            
                IF (xTGet3 > DtaMax365)
                    MsgAlert("Você não pode imprimir etiquetas com data de embalagem superior a 1 (um) ano","Aviso")
                    RETURN
                ENDIF
            ELSEIF ((_cOpera $ GetMV('SI_USRN2')))
                IF (xTGet2 < DtaMin30)
                    MsgAlert("Você não pode imprimir etiquetas com data de abate anterior a 30 (trinta) dias","Aviso")
                    RETURN        
                ENDIF            
                IF (xTGet3 > DtaMax30)
                    MsgAlert("Você não pode imprimir etiquetas com data de embalagem superior a 30 (trinta) dias","Aviso")
                    RETURN
                ENDIF
            ELSEIF ((_cOpera $ GetMV('SI_USRN3')))
                IF (xTGet2 < DtaMin14)
                    MsgAlert("Você não pode imprimir etiquetas com data de abate anterior a 14 (quatorze) dias","Aviso")
                    RETURN        
                ENDIF            
                IF (xTGet3 > DtaMax14)
                    MsgAlert("Você não pode imprimir etiquetas com data de embalagem superior a 14 (quatorze) dias","Aviso")
                    RETURN
                ENDIF
            ELSEIF ((_cOpera $ GetMV('SI_USRN4')))
                IF (xTGet2 < DtaMin7)
                    MsgAlert("Você não pode imprimir etiquetas com data de abate anterior a 7 (sete) dias","Aviso")
                    RETURN        
                ENDIF            
                IF (xTGet3 > DtaMax7)
                    MsgAlert("Você não pode imprimir etiquetas com data de embalagem superior a 7 (sete) dias","Aviso")
                    RETURN
                ENDIF
            ENDIF
        ELSE
            IF ((_cOpera $ GetMV('SI_USRN1.1')))
                IF (xTGet2 < DtaMin365)
                    MsgAlert("Você não pode imprimir etiquetas com data de abate anterior a 1 (um) ano","Aviso")
                    RETURN
                ENDIF
            ELSEIF ((_cOpera $ GetMV('SI_USRN2.1')))
                IF (xTGet2 < DtaMin30)
                    MsgAlert("Você não pode imprimir etiquetas com data de abate anterior a 30 (trinta) dias","Aviso")
                    RETURN
                ENDIF
            ELSEIF ((_cOpera $ GetMV('SI_USRN3.1')))
                IF (xTGet2 < DtaMin14)
                    MsgAlert("Você não pode imprimir etiquetas com data de abate anterior a 14 (quatorze) dias","Aviso")
                    RETURN
                ENDIF            
            ENDIF

            IF (xTGet3 <> DDATABASE)
                MsgAlert("Você não pode imprimir etiquetas com data de embalagem diferente do dia atual","Aviso")
                RETURN
            ENDIF
        ENDIF
    ENDIF

    //VALIDAÇÃO PARA SABER SE NA DATA INFORMADA HOUVE ABATE. SOMENTE PARA PRODUTOS DO PORCIONADOS NÃO SERÁ OBRIGADO INFORMAR DATA DE ABATE
    IF !(_cCodGrpProd $ GetMV('MV_GRPPORC'))
        IF Empty(GetAdvFval('SZG','ZG_DATA',FWxFilial('SZG')+DToS(xTGet2),2)) .AND. Empty(GetAdvFval('ZAP','ZAP_DATAP',FWxFilial('ZAP') + DToS(xTGet2),4))
            MsgAlert("Na data informada não houve abate!","Alerta")
            RETURN
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

	//QUERY PARA BUSCAR A PREVISAO DA DESSOSSA //FUNÇÕES POSICIONE() E GETADVFVAL() NÃO FUNCIONARAM
    //SOMENTE SERA BUSCADA PREVISAO DA DESOSSA CASO OS PRODUTOS NÃO FOREM PORCIONADOS
    indice8 := ALLTRIM(FWxFilial('SZU')+DToS(xTGet3)+xTGet1+DToS(xTGet2)+DTos(SToD('')))
    a := POSICIONE('SZU',1,indice8,'ZU_PREDES')
    b := GetAdvFval( 'SZU' , 'ZU_PREDES' , indice8 ,8, "Sem retorno de informações" ,.t.)

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
    //QUERY PARA BUSCAR A PREVISAO DA DESSOSSA //FUNÇÕES POSICIONE() E GETADVFVAL() NÃO FUNCIONARAM
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
    _cCodGrpProd    := GetAdvFval( 'SB1' , 'B1_GRUPO'   ,FWxFilial( 'SB1' ) + alltrim(xTGet1),1) //BUSCA GRUPO DE PRODUTOS
    _cDestino       := GetAdvFval( 'SB1' , 'B1_DESTINO' ,FWxFilial( 'SB1' ) + alltrim(xTGet1),1) //BUSCA O DESTINO DO PRODUTO    
    _cCadMercadoria := GetAdvFval( 'SB1' , 'B1_CADMERC' ,FWxFilial( 'SB1' ) + alltrim(xTGet1),1) //BUSCA O CADASTRO DA MERCADORIA DO PRODUTO
    _Absorv         := GetAdvFval( 'ZZ7' , 'ZZ7_ABSORV' ,FWxFilial( 'ZZ7' ) + alltrim(xTGet1),1)
    /*
    //BUSCA GRUPO DE PRODUTOS
    _cCodGrpProd := GetAdvFval('SB1','B1_GRUPO',FWxFilial('SB1') + alltrim(xTGet1),1)
    //BUSCA O DESTINO DO PRODUTO
    _cDestino := GetAdvFval('SB1','B1_DESTINO',FWxFilial('SB1') + alltrim(xTGet1),1)
    //BUSCA O CADASTRO DA MERCADORIA DO PRODUTO
    _cCadMercadoria := GetAdvFval('SB1','B1_CADMERC',FWxFilial('SB1') + alltrim(xTGet1),1)
    */
    //CONDIÇÃO PARA VERIFICAR SE PRODUTO FOR DO MIUDOS OU FOR DA EMBALAGEM PARA DATA DE VALIDADE    
	IF(alltrim(_cCodGrpProd) $ GetMV('MV_GRPMDS'))
		_DtVal  := xTGet2 + SB1->B1_VALID
	ELSE
		_DtVal  := xTGet3 + SB1->B1_VALID
	ENDIF

	MSCBWrite("^XA")
	MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWR")
    
    MSCBWrite("^CFA,22" )
    MSCBWrite("^FO" + "600,040" + "^FH\^FD" + Alltrim(ZZ7->ZZ7_DESC) + "^FS")

    MSCBWrite("^CFA,22" )    
    MSCBWrite("^FO" + "580,040" + "^FH\^FD" + Alltrim(ZZ7->ZZ7_CORTE) + "^FS")

    MSCBWrite("^CFA,22" )    

    MsgTemp := Alltrim(SB1->B1_MENETQ2)
    IF("CELSIUS" $ MsgTemp)
        MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )                                                     
        MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
    ELSEIF("CELCIUS" $ MsgTemp)
        MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
        MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
    ENDIF
    MSCBWrite("^FO" + "560,040" + "^FH\^FD" + MsgTemp + "^FS")

    if _Absorv = '1'
        MSCBWrite("^FO" + "530,040" + "^FH\^FD" + "Retirar o absorvedor antes do preparo" + " ^FS")
    endif

    //SE DESTINO FOR MERCADO INTERNO OU DESTINO FOR MERCADO EXTERNO E CADASTRO DA MERCADORIA NÃO EXISTIR
    IF (_cDestino = "MI" .or. (_cDestino = "ME" .and. _cCadMercadoria = ""))
        //SE PRODUTO FOR MIÚDOS
        IF(_cCodGrpProd $ GetMV('MV_GRPMDS'))
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "490,040")
            MSCBWrite("^FH^FD" + "Data de abate/Produ\87\C6o/Lote:" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "490,350")
            MSCBWrite("^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "470,040")
            MSCBWrite("^FD" + "Data de embalagem:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "470,350")
            MSCBWrite("^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,040")
            MSCBWrite("^FD" + "Data de validade:" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,350")
            MSCBWrite("^FD" + DtoC(_DtVal) + "^FS")
        //SE PRODUTO FOR CHARQUE
        ELSEIF(_cCodGrpProd $ GetMV('MV_GRPCHRQ'))
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "540,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "541,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "542,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "490,040")
            MSCBWrite("^FH^FD" + "Data de Estufa:" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "490,350")
            MSCBWrite("^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "470,040")
            MSCBWrite("^FH\^FD" + "Data de produ\87\C6o/Lote:" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "470,350")
            MSCBWrite("^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,040" + "^FD" + "Data de validade:" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,350" + "^FD" + DtoC(_DtVal) + "^FS")
        //SE PRODUTO FOR PORCIONADOS
        ELSEIF(_cCodGrpProd $ GetMV('MV_GRPPORC'))
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "470,040")
            MSCBWrite("^FH\^FD" + "Data de produ\87\C6o/Lote:" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "470,350")
            MSCBWrite("^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,040")
            MSCBWrite("^FD" + "Data de validade:" + "^FS")
            
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,350" + "^FD" + DtoC(_DtVal) + "^FS")
        ELSE
        //SE NÃO FOR NENHUM DOS ANTERIORES (ENTÃO NO CASO É DESOSSA)
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Data de abate:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,040")
            MSCBWrite("^FH\^FD" + "Data de produ\87\C6o/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,040" + "^FD" + "Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,350" + "^FD" + DtoC(_DtVal) + "^FS")
        ENDIF
    //SE DESTINO FOR MERCADO INTERNO OU DESTINO FOR MERCADO EXTERNO E CADASTRO DA MERCADORIA FOR 
    ELSEIF (_cDestino = "ME" .and. _cCadMercadoria = "A")
        //SE PRODUTO FOR MIÚDOS
        IF(_cCodGrpProd $ GetMV('MV_GRPMDS'))
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Slaughter date | Data de abate:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,040" + "^FD" + "Production date/Lot | Data de produção/Lote:" + "^FS")        
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,040" + "^FD" + "Expiry Date | Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,350" + "^FD" + DtoC(_DtVal) + "^FS")
        //SE PRODUTO FOR CHARQUE
        ELSEIF(_cCodGrpProd $ GetMV('MV_GRPCHRQ'))
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "540,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "541,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "542,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040")
            MSCBWrite("^FH^FD" + "Data de Estufa:" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350")
            MSCBWrite("^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Production date/Lot | Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,040" + "^FD" + "Expiry Date | Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(_DtVal) + "^FS")
        //SE PRODUTO FOR PORCIONADOS
        ELSEIF(_cCodGrpProd $ GetMV('MV_GRPPORC'))
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Production date/Lot | Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,040" + "^FD" + "Expiry Date | Data de validade::" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(_DtVal) + "^FS")
        ELSE
        //SE NÃO FOR NENHUM DOS ANTERIORES (ENTÃO NO CASO É DESOSSA)
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Slaughter date | Data de abate:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,040" + "^FD" + "Production date/Lot | Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,040" + "^FD" + "Expiry date | Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,350" + "^FD" + DtoC(_DtVal) + "^FS")
        ENDIF
    //SE DESTINO FOR MERCADO INTERNO OU DESTINO FOR MERCADO EXTERNO E CADSTRO DA MERCADORIA NÃO EXISTIR
    ELSEIF (_cDestino = "ME" .and. _cCadMercadoria = "E")
        //SE PRODUTO FOR MIÚDOS
        IF(_cCodGrpProd $ GetMV('MV_GRPMDS'))
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Fecha de matanza/Producción/Lote | Data de abate/Produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,040" + "^FD" + "Fecha de empaque | Data de embalagem:" + "^FS")        
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,040" + "^FD" + "Fecha de validad | Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,350" + "^FD" + DtoC(_DtVal) + "^FS")
        //SE PRODUTO FOR CHARQUE
        ELSEIF(_cCodGrpProd $ GetMV('MV_GRPCHRQ'))
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "540,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "541,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "542,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040")
            MSCBWrite("^FH^FD" + "Data de Estufa:" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350")
            MSCBWrite("^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,040" + "^FD" + "Fecha de validad | Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(_DtVal) + "^FS")
        //SE PRODUTO FOR PORCIONADOS
        ELSEIF(_cCodGrpProd $ GetMV('MV_GRPPORC'))
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,040" + "^FD" + "Fecha de validad | Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(_DtVal) + "^FS")
        ELSE
        //SE NÃO FOR NENHUM DOS ANTERIORES (ENTÃO NO CASO É DESOSSA)
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Fecha de matanza | Data de abate:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,040" + "^FD" + "Fecha de producción/Tara | Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,040" + "^FD" + "Fecha de validad | Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,350" + "^FD" + DtoC(_DtVal) + "^FS")
        ENDIF
    //SE DESTINO FOR MERCADO INTERNO OU DESTINO FOR MERCADO EXTERNO E CADSTRO DA MERCADORIA NÃO EXISTIR
    ELSEIF (_cDestino = "ME" .and. _cCadMercadoria = "L")
        //SE PRODUTO FOR MIÚDOS
        IF(_cCodGrpProd $ GetMV('MV_GRPMDS'))
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Data de abate/Produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,040" + "^FD" + "Packing date | Data de embalagem:" + "^FS")        
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,040" + "^FD" + "Expiry Date | Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,350" + "^FD" + DtoC(_DtVal) + "^FS")
        //SE PRODUTO FOR CHARQUE
        ELSEIF(_cCodGrpProd $ GetMV('MV_GRPCHRQ'))
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "540,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "541,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "542,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040")
            MSCBWrite("^FH^FD" + "Data de Estufa:" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350")
            MSCBWrite("^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(_DtVal) + "^FS")
        //SE PRODUTO FOR PORCIONADOS
        ELSEIF(_cCodGrpProd $ GetMV('MV_GRPPORC'))
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,040" + "^FD" + "Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(_DtVal) + "^FS")
        ELSE
        //SE NÃO FOR NENHUM DOS ANTERIORES (ENTÃO NO CASO É DESOSSA)
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Data de abate:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,040" + "^FD" + "Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,040" + "^FD" + "Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "450,350" + "^FD" + DtoC(_DtVal) + "^FS")
        ENDIF
    //SE DESTINO FOR MERCADO INTERNO OU DESTINO FOR MERCADO EXTERNO E CADSTRO DA MERCADORIA NÃO EXISTIR
    ELSEIF (_cDestino = "ME" .and. _cCadMercadoria = "U")
        //SE PRODUTO FOR MIÚDOS
        IF(_cCodGrpProd $ GetMV('MV_GRPMDS'))
            MSCBWrite("^CFA,27" )
            MSCBWrite("^FO" + "010,130" + "^FD" + "Data de abate/Produção/Lote:" + "^FS")
            MSCBWrite("^CFA,27" )
            MSCBWrite("^FO" + "400,130" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,27" )
            MSCBWrite("^FO" + "010,160" + "^FD" + "Data de embalagem:" + "^FS")        
            MSCBWrite("^CFA,27" )
            MSCBWrite("^FO" + "400,160" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,27" )
            MSCBWrite("^FO" + "010,190" + "^FD" + "Data de validade:" + "^FS")
            MSCBWrite("^CFA,27" )
            MSCBWrite("^FO" + "400,190" + "^FD" + DtoC(_DtVal) + "^FS")
        //SE PRODUTO FOR CHARQUE
        ELSEIF(_cCodGrpProd $ GetMV('MV_GRPCHRQ'))
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "540,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "541,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")
            MSCBWrite("^CFA,14" )
            MSCBWrite("^FO" + "542,040" + "^FH\^FD" + "INGR.: CARNE BOVINA E SAL  CONSERVAR EM LOCAL FRESCO E AREJADO" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040")
            MSCBWrite("^FH^FD" + "Data de Estufa:" + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,350")
            MSCBWrite("^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "010,130" + "^FD" + "Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "400,130" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "010,160" + "^FD" + "Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "400,160" + "^FD" + DtoC(_DtVal) + "^FS")
        //SE PRODUTO FOR PORCIONADOS
        ELSEIF(_cCodGrpProd $ GetMV('MV_GRPPORC'))
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "010,130" + "^FD" + "Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "400,130" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "010,190" + "^FD" + "Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "400,190" + "^FD" + DtoC(_DtVal) + "^FS")
        ELSE
        //SE NÃO FOR NENHUM DOS ANTERIORES (ENTÃO NO CASO É DESOSSA)
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "010,130" + "^FD" + "Data de abate:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "400,130" + "^FD" + DtoC(xTGet2) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "010,160" + "^FD" + "Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "400,160" + "^FD" + DtoC(xTGet3) + "^FS")

            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "010,190" + "^FD" + "Data de validade:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "400,190" + "^FD" + DtoC(_DtVal) + "^FS")
        ENDIF
    ELSE        
        MSGALERT( "Problema no cadastro do produto: Revisar Destino ou Cadastro de Mercadoria", "Aviso:" )
    ENDIF
    
    MSCBWrite("^CFA,22" )
    MSCBWrite("^FO" + "420,040" + "^FD" + "Tara:" + "^FS")
    MSCBWrite("^CFA,22" )
    MSCBWrite("^FO" + "420,350" + "^FD" + Alltrim(STR(_nTaraProd)) + "g" + "^FS" )
    
    MSCBWrite("^CFA,22" )
    MSCBWrite("^FO" + "390,040")
    MSCBWrite("^FH\^FD" + "REGISTRO NO MINIST\90RIO DA AGRICULTURA" + "^FS")
    MSCBWrite("^CFA,22" )
    MSCBWrite("^FO" + "370,040")
    MSCBWrite("^FH\^FD" + "SIF/DIPOA SOB N\A7 " + ZZ7->ZZ7_MSIF + "^FS")    
    
    //INSERE QUADRADO
    MSCBWrite("^FO010,035")
    MSCBWrite("^GB350,500,2^FS")
    //INSERE LINHAS VERTICAIS
    MSCBWrite("^FO115,270")
    MSCBWrite("^GB180,1,2^FS")

    MSCBWrite("^FO115,415")
    MSCBWrite("^GB180,1,2^FS")
    //INSERE LINHAS HORIZONTAIS
    MSCBWrite("^FO325,040")
    MSCBWrite("^GB1,480,2^FS")

    MSCBWrite("^FO295,040")
    MSCBWrite("^GB1,480,5^FS")

    MSCBWrite("^FO265,040")
    MSCBWrite("^GB1,480,2^FS")

    MSCBWrite("^FO235,040")
    MSCBWrite("^GB1,480,2^FS")

    MSCBWrite("^FO205,040")
    MSCBWrite("^GB1,480,2^FS")

    MSCBWrite("^FO175,040")
    MSCBWrite("^GB1,480,2^FS")
    
    MSCBWrite("^FO145,040")
    MSCBWrite("^GB1,480,2^FS")

    MSCBWrite("^FO115,040")
    MSCBWrite("^GB1,480,2^FS")

    MSCBWrite("^FO040,040")
    MSCBWrite("^GB1,480,4^FS")

    //_cIDTaBN := '5'
    //_cIDTaBN := '2'
    _cIDTaBN := ALLTRIM(GetAdvFval('ZZ7','ZZ7_TABNUT',FWxFilial('ZZ7')+xTGet1,1,'Sem informação',.t.))
    

    //HÁ TRÊS IMPRESSÕES PARA O CABEÇALHO DE VALORES POIS ASSIM O CABEÇALHO É IMPRESSO EM NEGRITO
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "330,040")
    MSCBWrite("^FH\^FD" + "                    INFORMA\80\C7O NUTRICIONAL" + "^FS")
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "331,040")
    MSCBWrite("^FH\^FD" + "                    INFORMA\80\C7O NUTRICIONAL" + "^FS")
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "332,040")
    MSCBWrite("^FH\^FD" + "                    INFORMA\80\C7O NUTRICIONAL" + "^FS")
    
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "300,040")
    MSCBWrite("^FH\^FD" + "Por\87\C6o: " + GetAdvFval('ZBH','ZBH_PORCPE',_cIDTaBN,1,'Sem informação',.t.) + "^FS")
    
    //HÁ TRÊS IMPRESSÕES PARA O CABEÇALHO DE VALORES POIS ASSIM O CABEÇALHO É IMPRESSO EM NEGRITO
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "270,040")
    MSCBWrite("^FD" + "                                              100 g             %VD*" + "^FS")
    
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "271,040")
    MSCBWrite("^FD" + "                                              100 g             %VD*" + "^FS")
    
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "272,040")
    MSCBWrite("^FD" + "                                              100 g             %VD*" + "^FS")    

    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "240,040")
    MSCBWrite("^FH\^FD" + "Valor energ\82tico (kcal)" + "^FS")    

    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "240,320")
    MSCBWrite("^FD" + GetAdvFval('ZBH','ZBH_VEN100',_cIDTaBN,1,'Sem informação',.t.)  + "^FS")
    MSCBWrite("^FO006,455")

    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "240,455")
    MSCBWrite("^FD" + GetAdvFval('ZBH','ZBH_VENVD',_cIDTaBN,1,'Sem informação',.t.)  + "^FS")

    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "210,040")
    MSCBWrite("^FH\^FD" + "Prote\A1nas (g)" + "^FS")

    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "210,320")
    MSCBWrite("^FD" + GetAdvFval('ZBH','ZBH_PRO100',_cIDTaBN,1,'Sem informação',.t.) + "^FS")

    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "210,455")
    MSCBWrite("^FD" + GetAdvFval('ZBH','ZBH_PROVD',_cIDTaBN,1,'Sem informação',.t.) + "^FS")
    
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "180,040" + "^FD")
    MSCBWrite("^FD" + "Gorduras totais (g)" + "^FS")
    
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "180,320" + "^FD")
    MSCBWrite("^FD" + GetAdvFval('ZBH','ZBH_GTO100',_cIDTaBN,1,'Sem informação',.t.) + "^FS")

    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "180,455" + "^FD")
    MSCBWrite("^FD" + GetAdvFval('ZBH','ZBH_GTOVD',_cIDTaBN,1,'Sem informação',.t.) + "^FS")
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "150,040")
    MSCBWrite("^FD" + " Gorduras saturadas  (g)" + "^FS")
    
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "150,320")
    MSCBWrite("^FD" + GetAdvFval('ZBH','ZBH_GSA100',_cIDTaBN,1,'Sem informação',.t.) + "^FS")

    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "150,455")
    MSCBWrite("^FD" + GetAdvFval('ZBH','ZBH_GSAVD',_cIDTaBN,1,'Sem informação',.t.) + "^FS")
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "120,040")
    MSCBWrite("^FH\^FD" + "S\A2dio (mg)" + "^FS")

    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "120,320")
    MSCBWrite("^FD" + GetAdvFval('ZBH','ZBH_SOD100',_cIDTaBN,1,'Sem informação',.t.) + "^FS")

    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "120,455")
    MSCBWrite("^FD" + GetAdvFval('ZBH','ZBH_SODVD',_cIDTaBN,1,'Sem informação',.t.) + "^FS")
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "085,040")
    MSCBWrite("^FH\^FD" + "N\C6o cont\82m quantidades significativas de carboidratos," + "^FS")
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "065,040")
    MSCBWrite("^FH\^FD" + "a\87\A3cares totais, a\87\A3cares adicionados, gorduras trans" + "^FS")
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "045,040")
    MSCBWrite("^FD" + "e fibras alimentares." + "^FS")

    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "015,040")
    MSCBWrite("^FH\^FD" + "*Percentual de valores di\A0rios fornecidos pela por\87\C6o" + "^FS")

    //CODIGO DE BARRA
    MSCBWrite("^BY3,3,50")
    MSCBWrite("^FT030,590")
    MSCBWrite("^BCN,,Y,N")
    MSCBWrite("^FD>;" + ZZ7->ZZ7_CODPRO + "^FS")

    MSCBWrite("^PQ" + _cQtdEtq + ",0,1,N")
    MSCBWrite("^XZ")
RETURN
