/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI201            º Autor ³ Lucas Bolzan º Data ³ 18/11/24  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Abre o mês                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include 'protheus.ch'
#include 'topconn.ch'
#include 'totvs.ch'

User Function LBP06()
    Private cULMES   := Getmv( 'MV_ULMES' )
    Private cDBLQMOV := Getmv( 'MV_DBLQMOV' )
    Private dULMES   := SToD("")
    Private dDBLQMOV := SToD("")
    //Variaveis para dimensões dos forms
    Private tsTop      := 0
    Private tsLeft     := 0
    Private tsBottom   := 400
    Private tsRight    := 300
    Private tsCaption  := 'Abre o mês em ULMES e DBLQMOV'
    Private tsClrText  := CLR_BLACK
    Private tsClrBack  := CLR_WHITE
    Private tsPixel    := .T.

    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
    oFont := TFont():New('Arial',    , -12                , .T.)        
    oSay1 := TSay():New(025, 015, {|| 'Data atual MV_ULMES:' }  , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 020)
    oSay2 := TSay():New(040, 015, {|| 'Data atual MV_DBLQMOV:' }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 020)
    oSay3 := TSay():New(025, 100, {||cULMES}                    , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 020)
    oSay4 := TSay():New(040, 100, {||cDBLQMOV}                  , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 020)
    oSay5 := TSay():New(070, 015, {|| 'Nova data em MV_ULMES:' }  , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 020)
    oSay6 := TSay():New(085, 015, {|| 'Nova data em MV_DBLQMOV:' }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 020)
    oTGet1 := TGet():New(070, 100, {| u | If( PCount() > 0, dULMES := u, dULMES)}    , oDialog, 40, 10, , , 0, , , .F., , .T., , .F., , .F., .F., , .F., .F., , , , , , .t.,)
    oTGet2 := TGet():New(085, 100, {| u | If( PCount() > 0, dDBLQMOV := u, dDBLQMOV)}, oDialog, 40, 10, , , 0, , , .F., , .T., , .F., , .F., .F., , .F., .F., , , , , , .t.,)
    oTButton1 := TButton():New(150, 050, "Gravar e sair",oDialog,{||GravaPar()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )        
    oTButton2 := TButton():New(165, 050, "Cancelar e Sair",oDialog,{||oDialog:end()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

    oDialog:Activate(,,,.T.,,,)
Return

Static Function GravaPar()
    Putmvfil('MV_ULMES'  ,DToS(dULMES),cFilAnt)
    Putmv('MV_DBLQMOV',DToS(dDBLQMOV))    
    Msginfo("Alterações realizadas com sucesso: O parâmetro MV_ULMES foi definido com a data " + DToC(dULMES) + " e o parâmetro MV_DBLQMOV foi definido com a data " + DToC(dDBLQMOV), 'Informação')
    oDialog:end()
Return
