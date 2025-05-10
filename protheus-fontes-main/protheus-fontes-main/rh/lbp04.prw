#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

#INCLUDE "FWPrintSetup.ch
#INCLUDE "rptdef.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LBP04            º Autor ³ Lucas Bolzan º Data ³ 30/08/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Lançamento de advertências                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DPL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION LBP04()
    BrowseDef()
RETURN

STATIC FUNCTION BrowseDef()
    LOCAL oBrowse
    LOCAL aArea := GetNextAlias()
    
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('SRA')
    oBrowse:SetOnlyFields({'RA_MAT','RA_NOME'})
    oBrowse:SetDescription('Infrações de registro ponto')
    oBrowse:DisableDetails()
    //oBrowse:SetFilial({FWxfilial('ZBI')})
    oBrowse:SetUseFilter(.T.)
    oBrowse:AddLegend("SRA->RA_MSBLQL == '2'", "GREEN", "Admitido")
    oBrowse:AddLegend("SRA->RA_MSBLQL == '1'", "RED", "Demitido")
    oBrowse:Activate()
RETURN oBrowse

STATIC FUNCTION MenuDef()
    LOCAL aRotina := {}

    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.LBP04' OPERATION MODEL_OPERATION_VIEW ACCESS 0
    ADD OPTION aRotina TITLE 'Registrar advertencia' ACTION 'U_LBP04inc' OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD OPTION aRotina TITLE 'Gerar relatório em Excel' ACTION 'U_LBP04Rel' OPERATION 6 ACCESS 0    
RETURN aRotina

STATIC FUNCTION ModelDef()
    LOCAL oModel := Nil
    LOCAL oStruct1 := FwFormStruct(1,"SRA")
    LOCAL oStruct2 := FwFormStruct(1,"ZBI")
    LOCAL aRelacao := {}
    
    oStruct2:AddField("","",'ZBI_LEGEND','C',50,0,NIL,NIL,NIL,NIL,{ || Iif(u_LBP04Qry(SRA->RA_MAT, ZBI->ZBI_DTAINF) = 'A', "BR_VERDE","BR_VERMELHO") },NIL,NIL,.T.)    

    oModel := MPFormModel():New('COMP011M' )
    oModel:AddFields('SRAMASTER',, oStruct1)
    oModel:AddGrid("ZBIDETAIL","SRAMASTER",oStruct2,,,,,)
    
    aAdd(aRelacao, {"ZBI_FILIAL",	"RA_FILIAL"})
	aAdd(aRelacao, {"ZBI_MATRIC",	"RA_MAT"})

    oModel:SetRelation("ZBIDETAIL", aRelacao, ZBI->(IndexKey(1)))

    oModel:SetPrimaryKey({})

    oModel:SetDescription('Infrações do usuário')    
    /*
    Não notei diferença retirando as classes abaixo

    oModel:GetModel("ZBIDETAIL"):SetUniqueLine({"ZBI_FILIAL","ZB8_NUM"})
    oModel:GetModel('SRAMASTER'):SetDescription('Dados de Autor/Interprete')
    oModel:GetModel('ZBIDETAIL'):SetDescription('Infrações do usuário N')
    */
Return oModel

STATIC FUNCTION ViewDef()
    LOCAL oView    := Nil
    LOCAL oModel   := FWLoadModel("LBP04")
    LOCAL oStruct1 := FwFormStruct(2,"SRA") //1=Model 2=View
    LOCAL oStruct2 := FwFormStruct(2,"ZBI") //1=Model 2=View        

    oStruct2:AddField('ZBI_LEGEND',"00", AllTrim('Legenda') , AllTrim('Legenda'),{'Legenda'},'C','@BMP',NIL,,.T.,NIL,NIL,NIL,NIL,NIL,.T.,NIL,NIL)    

    oView := FWFormView():New()
    oView:SetModel(oModel)        

    oView:AddField( 'VIEW_SRA', oStruct1, 'SRAMASTER')
    oView:AddGrid(  'VIEW_ZBI', oStruct2, 'ZBIDETAIL')

    oView:CreateHorizontalBox('HEADER',25)
    oView:CreateHorizontalBox('GRID',75)

    oView:SetOwnerView("VIEW_SRA","HEADER")
    oView:SetOwnerView("VIEW_ZBI","GRID")

    oView:SetCloseOnOk({||.T.})

    //oView:AddUserButton( 'Imprimir/Reimprimir Advertencia', 'NOTE', {|oView| u_LBP04Doc(ZBI->ZBI_MATRIC, ZBI->ZBI_NOME, ZBI->ZBI_DTAINF,ZBI->ZBI_TIPOIN)} )
    oView:AddUserButton( 'Imprimir/Reimprimir Advertencia', 'NOTE', {|oView| u_LBP04Doc(M->RA_MAT)} )

    SX3->(DbSetOrder(1))
    SX3->(DbGoTop())
    SX3->(MsSeek('SRA'))
    WHILE SX3->(!EoF()) .AND. SX3->X3_ARQUIVO = 'SRA'
        IF !(AllTrim(SX3->X3_CAMPO) $ 'RA_MAT,RA_NOME')
            oStruct1:RemoveField(AllTrim(SX3->X3_CAMPO))
        ENDIF
        SX3->(DbSkip())
    ENDDO
RETURN oView

USER FUNCTION LBP04inc()
    //Variaveis para dimensões dos forms
    tsTop      := 0
    tsLeft     := 0
    tsBottom   := 100
    tsRight    := 600
    tsCaption  := 'Impressão de etiquetas identificadoras de produtos.'
    tsClrText  := CLR_BLACK
    tsClrBack  := CLR_WHITE
    tsPixel    := .T.

    dDtaInf    := SToD("")
    cDescri    := Space(254)
    cCbox      := '1'
    aCbox      := {'1= - 1h','2= + 2hs','3= + 6hs','4= + 11hs'}

    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
        oFont:= TFont():New('Arial',, -12, .T.)

        oSay1  := TSay():New(05,05,{||'Data da infração:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay2  := TSay():New(20,05,{||'Tipo da infração:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)        
        oSay3  := TSay():New(35,05,{||'Descrição:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)                
        oTGet1 := TGet():New(05,75,{ |u| If(PCount() > 0, dDtaInf := u, dDtaInf) },oDialog,40,10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t., )
        oCbox1 := TComboBox():New(20,75,{|u| Iif(PCount() > 0, cCbox := u, cCbox)},aCbox,150,10,oDialog,,,,,,.T.,oFont)
        oTGet2 := TGet():New(35,75,{|u| If( PCount() > 0, cDescri := u, cDescri) },oDialog,220,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cDescri,,,,.t., )

        oTButton1 := TButton():New(005,250, "Gravar",oDialog,{||GravaZBI(dDtaInf,cCbox,cDescri)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
        oTButton2 := TButton():New(020,250, "Cancelar",oDialog,{||oDialog:end()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oDialog:Activate(,,,.T.,,,)
RETURN

STATIC FUNCTION GravaZBI(dDtaInf,cCbox,cDescri)

    IF (!Empty(dDtaInf))
        ZBI->(DbSetOrder(1))
        ZBI->(DbGoTop())
        reclock('ZBI',.T.)
        ZBI->ZBI_FILIAL := FWxfilial('ZBI')
        ZBI->ZBI_MATRIC := SRA->RA_MAT
        ZBI->ZBI_NOME   := SRA->RA_NOME
        ZBI->ZBI_CC     := SRA->RA_CC
        ZBI->ZBI_DTADMI := SRA->RA_ADMISSA
        ZBI->ZBI_DTADEM := SRA->RA_DEMISSA
        ZBI->ZBI_DTAINF := dDtaInf
        ZBI->ZBI_TIPOIN := VAL(cCbox)
        ZBI->ZBI_DESCRI := cDescri
        ZBI->ZBI_SITUAC := "A"
        msunlock()

        MsgInfo ("Dados da advertência inseridos com sucesso.","INFO")

        LimpaCampos()
    ELSE
        MsgAlert ("Insira uma data de advertêmcia para continuar.","ALERTA")
    ENDIF    
RETURN

STATIC FUNCTION LimpaCampos()
    oTGet1     := SToD("")
    oTGet2     := Space(100)

	oDialog:refresh()
    oDialog:End()
RETURN

USER FUNCTION LBP04Qry(cMatricula, dDtaInf)
    IF (dDtaInf < DDATABASE-365 .AND. ZBI->ZBI_SITUAC = 'A')                                     
        cQuery := "UPDATE ZBI010 "
        cQuery += "SET ZBI_SITUAC = 'I' "
        cQuery += "WHERE " + RetSQLFil('ZBI') + " AND " + " ZBI_MATRIC = '" + cMatricula + "' AND ZBI_DTAINF = '" + DTos(dDtaInf) + "' AND ZBI_SITUAC = 'A'"

        TcSqlExec(cQuery)
    ENDIF

    cQry := "SELECT ZBI_SITUAC AS SITUACAO"
    cQry += " FROM " + retSqlTab('ZBI')
    cQry += " WHERE " + retSqlFil('ZBI')
    cQry += " AND " + retSqlDel('ZBI')
    cQry += " AND ZBI_MATRIC = '" + cMatricula + "' "
    cQry += " AND ZBI_DTAINF = '" + DToS(dDtaInf)+ "' "

    cQry := ChangeQuery(cQry)

    TCQuery cQry New Alias "QRY"

    QRY->(dbGoTop())

    IF !QRY->(EoF())
        cSituacao := QRY->SITUACAO
    ENDIF
    QRY->(DbCloseArea())
RETURN cSituacao

USER FUNCTION LBP04Rel()
    aDados	 := {}
    aCabec	 := {}
    cPerg := 'LBP04REL'
    pergunte(cPerg,.T.)

    cQryRel := "SELECT ZBI_FILIAL AS xFILIAL, ZBI_MATRIC AS MATRICULA, ZBI_NOME AS NOME, ZBI_CC AS CENCUSTO, ZBI_DTADMI AS ADMISSAO, ZBI_DTADEM AS DEMISSAO,ZBI_DTAINF AS INFRACAO, ZBI_TIPOIN AS TIPOINF,ZBI_DESCRI AS DESCRICAO, ZBI_SITUAC AS SITUACAO"
    cQryRel += " FROM " + retSqlTab('ZBI')
    cQryRel += " WHERE " + retSqlFil('ZBI')
    cQryRel += " AND " + retSqlDel('ZBI')

    IF (!Empty(mv_par01)) .AND. (!Empty(mv_par02))
        cQryRel += " AND ZBI_MATRIC BETWEEN '" + AllTrim(mv_par01) + "' AND '" + AllTrim(mv_par02) + "'"
    ELSEIF (!Empty(mv_par01)) .AND. (Empty(mv_par02))
        MsgInfo("A pergunta 'Da matrícula' deve ser respondida. ","Alerta")
        RETURN .F.
    ELSEIF (Empty(mv_par01)) .AND. (!Empty(mv_par02))
        MsgInfo("A pergunta 'Até a matrícula' deve ser respondida. ","Alerta")
        RETURN .F.
    ENDIF

    IF (!Empty(mv_par03)) .AND. (!Empty(mv_par04))
        cQryRel += " AND ZBI_CC BETWEEN '" + AllTrim(mv_par03) + "' AND '" + AllTrim(mv_par04) + "'"
    ELSEIF (!Empty(mv_par03)) .AND. (Empty(mv_par04))
        MsgInfo("A pergunta 'Do centro de custo' deve ser respondida. ","Alerta")
        RETURN .F.
    ELSEIF (Empty(mv_par03)) .AND. (!Empty(mv_par04))
        MsgInfo("A pergunta 'Até o centro de custo' deve ser respondida. ","Alerta")
        RETURN .F.
    ENDIF

    IF mv_par05 = 1
        cQryRel += " AND ZBI_SITUAC = 'A'"
    ELSE
        cQryRel += " AND (ZBI_SITUAC = 'A' OR ZBI_SITUAC = 'I')"
    ENDIF

    cQryRel := ChangeQuery(cQryRel)

    IF SELECT("QRYREL") != 0
		QRYREL->(dbCloseArea())
	ENDIF

    TCQuery cQryRel New Alias "QRYREL"
    
    QRYREL->(dbGoTop())

    WHILE QRYREL->(!EOF())
        aAdd(aDados, { QRYREL->xFILIAL,;
            QRYREL->MATRICULA,;
            QRYREL->NOME,;
            QRYREL->CENCUSTO,;
            QRYREL->ADMISSAO,;
            QRYREL->DEMISSAO,;
            QRYREL->INFRACAO,;
            QRYREL->TIPOINF,;
            QRYREL->DESCRICAO,;
            QRYREL->SITUACAO,;
            })
        QRYREL->(DBSKIP())
    ENDDO

    //Gera o arquivo excel
    If Len(aDados) > 0
		aadd(aCabec, {"Filial"          , "C", 2  , 0})
		aadd(aCabec, {"Matrícula"       , "C", 6  , 0})
		aadd(aCabec, {"Nome"            , "C", 30 , 0})
		aadd(aCabec, {"Centro de Custo" , "C", 9  , 2})
		aadd(aCabec, {"Data de Admissão", "D", 8  , 2})
        aadd(aCabec, {"Data de Demissão", "D", 8  , 2})
		aadd(aCabec, {"Data da Infração", "D", 8  , 2})
        aadd(aCabec, {"Tipo da Infração", "N", 1  , 2})
        aadd(aCabec, {"Descrição"       , "C", 100, 2})
        aadd(aCabec, {"Situação"        , "C", 1  , 2})

		U_GERAEXCEL("LBP04", aDados, aCabec, .T., .T.)
	Endif	
RETURN

USER FUNCTION LBP04Doc(cMatricula/*, cNome, dDtaInf, nTipoInf*/)
    LOCAL lAdjustToLegacy := .F.
    LOCAL lDisableSetup := .T.
    LOCAL cLocal := "\spool"
    LOCAL oPrinter    
    
    DBSelectArea('ZBI')
    ZBI->(DBSetOrder(1))
    ZBI->(DbGoTop())
    ZBI->(MSSeek(FWXFilial('ZBI')+ALLTRIM(cMatricula),,.F.))

    cQryDoc := "SELECT TOP 1 ZBI_FILIAL AS xFILIAL, ZBI_MATRIC AS MATRICULA, ZBI_NOME AS NOME, ZBI_CC AS CENCUSTO, ZBI_DTADMI AS ADMISSAO, ZBI_DTADEM AS DEMISSAO,ZBI_DTAINF AS DTAINFRACAO, ZBI_TIPOIN AS TIPOINF, ZBI_DESCRI AS DESCRICAO, ZBI_SITUAC AS SITUACAO"
    cQryDoc += " FROM " + retSqlTab('ZBI')
    cQryDoc += " WHERE " + retSqlFil('ZBI')
    cQryDoc += " AND " + retSqlDel('ZBI')
    cQryDoc += " AND ZBI_MATRIC = '" + AllTrim(cMatricula) + "'"
    cQryDoc += " ORDER BY ZBI_DTAINF DESC"

    cQryDoc := ChangeQuery(cQryDoc)

    IF SELECT("QRYDOC") != 0
		QRYDOC->(dbCloseArea())
	ENDIF

    TCQuery cQryDoc New Alias "QRYDOC"
    
    QRYDOC->(dbGoTop())    

    DO CASE
        CASE QRYDOC->TIPOINF = 1
        cTipoInf1 = ' ao realizar seu intervalo menor'
        cTipoInf2 = ' que 1 hora. Tendo em vista que a orientação da empresa é 1h10m.'
        CASE QRYDOC->TIPOINF = 2
        cTipoInf1 = ' excedeu ás horas extras, sendo'
        cTipoInf2 = ' que, máximo permitido por lei é 2hs. '
        CASE QRYDOC->TIPOINF = 3
        cTipoInf1 = ' ao realizar mais de 6 horas trabalhadas'
        cTipoInf2 = 'sem intervalo.'
        CASE QRYDOC->TIPOINF = 4
        cTipoInf1 = ' ao não respeitar o limite de 11 horas'
        cTipoInf2 = ' de descanso entre o término de uma jornada, e o início da outra.'
    ENDCASE

    oPrinter := FWMSPrinter():New("exemplo.rel", IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )

    oPrinter:Say(050,175,"FRIGORÍFICO SILVA INDÚSTRIA E COMÉRCIO LTDA")
    oPrinter:Say(080,220,"ADVERTÊNCIA DISCIPLINAR")

    oPrinter:Say(110,050,AllTrim(QRYDOC->NOME) + ' - '+ AllTrim(QRYDOC->CENCUSTO))
    oPrinter:Say(130,050,"Na conformidade da Consolidação das Leis do Trabalho, o colaborador acima fica advertido em decorrência")
    oPrinter:Say(150,050,"das faltas abaixo discriminadas.")
    oPrinter:Say(170,050,"O colaborador apresentou atitudes inadequadas no registro do seu ponto no dia " + DToC(SToD(QRYDOC->DTAINFRACAO)) + cTipoInf1)
    
    oPrinter:Say(190,050,cTipoInf2)
    oPrinter:Say(210,050,"Justificou que " + AllTrim(QRYDOC->DESCRICAO) + ". Todos os colaboradores da empresa estão cientes da responsabilidade de registrar cor-")
    oPrinter:Say(230,050,"retamente seus horários a fim de não cometer nenhuma penalidade que infrinja a legislação trabalhista. ")
    oPrinter:Say(250,050,"Horário registrado: ")

    oPrinter:Say(280,050,"Não só esperamos que tome as necessárias providências, a fim de que não se repitam as irregularidades acima")
    oPrinter:Say(300,050,"discriminadas, como também aproveitamos para esclarecer-lhe que a repetição ou prática de outra prevista em")
    oPrinter:Say(320,050,"nossos regulamentos, ordens de serviços, comunicação etc., irá contribuir desfavoravelmente em seu progresso")
    oPrinter:Say(340,050,"nesta empresa, além de poder acarretar-lhe penalidades mais severas, conforme preceitua as disposições do ar-")
    oPrinter:Say(360,050,"tigo 482 e suas alíneas da consolidação das leis do trabalho.")

    oPrinter:Say(390,050,"Ciente, " + DToC(Date()))
    oPrinter:Say(410,050,"Assinatura do funcionário:")
    oPrinter:Line(440,050,440,200,0,"-3")
    oPrinter:Say(450,050,"Nome do colaborador: " + AllTrim(QRYDOC->NOME))
    oPrinter:Say(470,050,"RG: " + GetAdvFval('SRA','RA_CIC', FWxFilial('SRA') + alltrim(cMatricula),1))
    oPrinter:Say(410,350,"Assinatura da empresa:")
    oPrinter:Line(440,350,440,500,0,"-3")
    oPrinter:Say(450,350,"Nome do colaborador DPL: MARIA F. C. DA SILVA")
    oPrinter:Say(470,350,"RG: 03107295051")

    oPrinter:Setup()

    IF oPrinter:nModalResult == PD_OK
        oPrinter:Preview()
    ENDIF
RETURN
