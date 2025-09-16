#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI200    ºAutor  ³Lucas Bolzan     º Data ³  28/12/23      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Manipulação de padrinhos                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP           .                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION DTI200()
    PRIVATE cAlias := 'SRA'
    PRIVATE cCadastro := 'Alterar Padrinho'

    cMColab := Space(6)
    cNColab := Space(30)
    cMPadr1 := Space(6)
    cNPadr1 := Space(30)
    cMPadr2 := Space(6)
    cNPadr2 := Space(30)
    
    tsTop := 0
    tsLeft := 0
    tsBottom := 300
    tsRight := 600
    tsCaption := 'Ajuste nas definições de padrinho dos colaboadores.'
    tsClrText := CLR_BLACK
    tsClrBack := CLR_WHITE
    tsPixel := .T.
    
    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
        oFont:= TFont():New('Arial',, -12, .T.)
        
        oSay1  := TSay():New(010,005,{||'Matricula do colaborador:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)        
        oTGet1 := TGet():New(008,088,{ | u | If( PCount() > 0, cMColab := u, cMColab) },oDialog,040,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cMColab,,,,.T., )        
        oTGet1:cF3 := 'SRA'
        oTGet1:Picture := '@!'

        oSay2  := TSay():New(010,130,{||'Nome do colaborador:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oTGet2 := TGet():New(008,190,{ | u | If( PCount() > 0, cNColab := u, cNColab) },oDialog,100,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cNColab,,,,.T., )
        oTGet2:Picture := '@!'
        oTGet2:lActive := .F.
        
        oSay3  := TSay():New(025,005,{||'Matricula do 1º padrinho:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)        
        oTGet3 := TGet():New(023,088,{ | u | If( PCount() > 0, cMPadr1 := u, cMPadr1) },oDialog,040,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cMPadr1,,,,.T., )
        oTGet3:cF3 := 'SRA'
        oTGet3:Picture := '@'

        oSay4  := TSay():New(025,130,{||'Nome do 1º padrinho:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oTGet4 := TGet():New(023,190,{ ||cNPadr1 },oDialog,100,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cNPadr1,,,,.T., )
        oTGet4:Picture := '@!'        
        oTGet4:lActive := .F.    

        oSay5  := TSay():New(040,005,{||'Matricula do 2º padrinho:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)        
        oTGet5 := TGet():New(038,088,{ | u | If( PCount() > 0, cMPadr2 := u, cMPadr2) },oDialog,040,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cMPadr2,,,,.T., )
        oTGet5:cF3 := 'SRA'
        oTGet5:Picture := '@!'
        
        oSay6  := TSay():New(040,130,{||'Nome do 2º padrinho:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oTGet6 := TGet():New(038,190,{||cNPadr2 },oDialog,100,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cNPadr2,,,,.T., )
        oTGet6:Picture := '@!'        
        oTGet6:lActive := .F.

        oTGet1:bLostFocus:= {|| AtualizaDados()}
        oTGet3:bLostFocus:= {|| oTGRefres1()}
        oTGet5:bLostFocus:= {|| oTGRefres2()}

        oTButton1 := TButton():New(055, 005, "Salvar edições",oDialog,{||SalvaEdicoes()}, 290,010,,,.F.,.T.,.F.,,.F.,,,.F. )        
        
    oDialog:Activate(,,,.T.,,,)
RETURN

STATIC FUNCTION SalvaEdicoes()    
    DbSelectArea(cAlias)
    SRA->(DbSetOrder(1))    
    IF (SRA->(DBSeek(FWXFilial(cAlias)+cMColab)))
        Reclock('SRA', .F.)
            SRA->RA_PADRIN  := AllTrim(cMPadr1)
            SRA->RA_NOMEP1  := AllTrim(cNPadr1)
            SRA->RA_PADRINH := AllTrim(cMPadr2)
            SRA->RA_NOMEP2  := AllTrim(cNPadr2)
        MSUnlock()
        MsgInfo("Edições salvas com sucesso", "Informação")
    ENDIF
RETURN
//ATUALIZA DADOS COM BASE NO COLABORADOR
STATIC FUNCTION AtualizaDados()
    //APENAS EXIBE O NOME DO COLABORADOR E BUSCA SEUS PADRINHOS
    cMColab := AllTrim(cMColab)
    IF (cMColab <> "")
        cNColab := AllTrim(GetAdvFval(cAlias, 'RA_NOME' ,FWxFilial(cAlias)+cMColab,1))
        cMPadr1 := AllTrim(GetAdvFval(cAlias, 'RA_PADRIN' ,FWxFilial(cAlias)+cMColab,1))
        cNPadr1 := AllTrim(GetAdvFval(cAlias, 'RA_NOMEP1' ,FWxFilial(cAlias)+cMColab,1))
        cMPadr2 := AllTrim(GetAdvFval(cAlias, 'RA_PADRINH' ,FWxFilial(cAlias)+cMColab,1))
        cNPadr2 := AllTrim(GetAdvFval(cAlias, 'RA_NOMEP2' ,FWxFilial(cAlias)+cMColab,1))

        oTGet2:refresh()
    ENDIF
    //TRATA OS CAMPOS QUE EXIBEM OS NOMES DOS PADRINHOS CASO ELES NÃO EXISTAM
    IF (cMPadr1 <> "")
        cNPadr1 := ALLTRIM(GetAdvFval(cAlias,'RA_NOME' ,FWxFilial(cAlias) + alltrim(cMPadr1),1))    
        oTGet4:refresh()
    ELSE
        cNPadr1 := Space(30)
    ENDIF
    
    IF (cMPadr2 <> "")
        cNPadr2 := ALLTRIM(GetAdvFval(cAlias,'RA_NOME' ,FWxFilial(cAlias) + alltrim(cMPadr2),1))    
        oTGet6:refresh()
    ELSE
        cNPadr2 := Space(30)
    ENDIF
RETURN

STATIC FUNCTION oTGRefres1() 
    cMPadr1 := AllTrim(cMPadr1)    
    IF (cMPadr1 <> "")    
        cNPadr1 := AllTrim(GetAdvFval(cAlias,'RA_NOME' ,FWxFilial(cAlias) + cMPadr1,1))
        oTGet4:refresh()
    ELSE
        cMPadr1 := Space(6)
        cNPadr1 := ""
    ENDIF
RETURN

STATIC FUNCTION oTGRefres2()
    cMPadr2 := AllTrim(cMPadr2)    
    IF (cMPadr2 <> "")    
        cNPadr2 := AllTrim(GetAdvFval(cAlias,'RA_NOME' ,FWxFilial(cAlias) + cMPadr2,1))
        oTGet6:refresh()
    ELSE
        cMPadr2 := Space(6)
        cNPadr2 := ""
    ENDIF
RETURN
