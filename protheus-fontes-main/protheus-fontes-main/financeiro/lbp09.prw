#Include "TOTVS.ch"
#Include "TOPCONN.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LBP09    ºAutor  ³Lucas Bolzan     º Data ³  19/12/24       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Altera para todas as lojas de determinado clinte          º±±
±±º          ³  a data de vencimento do limite de crédito                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN           .                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION LBP09()
    tsTop := 0
    tsLeft := 0
    tsBottom := 200
    tsRight := 300
    tsCaption := 'Altera data de vencimento do limite de crédito.'
    tsClrText := CLR_BLACK
    tsClrBack := CLR_WHITE
    tsPixel := .T.    
    //Variaveis Gerais
    cCodCli := Space(6)    
    dDtaVen := SToD("")
    cCodEmp := FWCodEmp('SM0')
    
    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
        oFont:= TFont():New('Arial',, -12, .T.)
        
        oSay1:= TSay():New(10,15,{||'Cód. do cliente:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)        
        oSay2:= TSay():New(23,15,{||'Nova data:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)        
        oTGet1 := TGet():New(08,75,{ | u | If( PCount() > 0, cCodCli := u, cCodCli) },oDialog,40,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cCodCli,,,,.t., )
        oTGet1:cF3 := 'SA1'        
        oTGet1:Picture := '@!'
        oTGet2 := TGet():New(21,75,{ | u | If( PCount() > 0, dDtaVen := u, dDtaVen) },oDialog,40,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t., )
        oTGet2:Picture := '@!'

        oTButton1 := TButton():New(40, 30, "Aplica data",oDialog,{||Altera()}, 90,10,,,.F.,.T.,.F.,,.F.,,,.F. )
        oTButton2 := TButton():New(55, 30, "Cancelar e Sair",oDialog,{||oDialog:end()}, 90,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oDialog:Activate(,,,.T.,,,)
RETURN

STATIC FUNCTION Altera()
    Local _cNomCli := AllTrim(GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1') + AllTrim(cCodCli),1))

    IF MsgNoYes('Todas as lojas do cliente ' + cCodCli + " | " + _cNomCli + ' terão suas datas de vencimento de limite de crédito alteradas para '+ DToC(dDtaVen) + ". Deseja continuar?" )
        cQry := "UPDATE SA1" + cCodEmp + '0 '
        cQry += "SET A1_VENCLC  = '" + DToS(dDtaVen) + "' "
        cQry += "WHERE A1_COD = '" + cCodCli + "'"
        TcSqlExec(cQry)

        MsgInfo("Alteração efetuada com sucesso.","Info")
    ELSE
        MsgInfo("Operação cancelada.","Info")
        RETURN
    ENDIF    
RETURN
