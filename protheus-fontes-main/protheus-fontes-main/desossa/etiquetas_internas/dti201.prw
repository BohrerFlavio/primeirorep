/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI201            º Autor ³ Lucas Bolzan º Data ³ 18/05/23  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de etiqueta interna                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desossa                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "COLORS.ch"

USER FUNCTION DTI201()
    //Variaveis gerais
    Private _cCmdZPL    := ""
    Private xTGet1      := Space(6) //codigo do produto
    Private xTGet2      := SToD("") //Data de abate
    Private xTGet3      := SToD("") //Data de produção
    Private xTGet4      := Space(6) //Quantidade de etiquetas
    Private xTGet5      := Space(1) //codigo da mesa
    Private xTGet6      := Space(16) //lote EUA
    Private _cDescProd  := Space(40)    
    Private _nTaraProd  := 0.000
    Private _cQtdEtq    := Space(6)
    Private _nQtdEtq    := 0
    Private _cPerg      := "DTI175"
    Private _cOpera     := UsrRetName(retCodUsr())    
    Private DtaMin7   := DDATABASE-7
    Private DtaMin14  := DDATABASE-14
    Private DtaMin30  := DDATABASE-30
    Private DtaMin365 := DDATABASE-365
    Private DtaMax7   := DDATABASE+7
    Private DtaMax14  := DDATABASE+14
    Private DtaMax30  := DDATABASE+30
    Private DtaMax365 := DDATABASE+365
    Private nRadB     := 1
    Private aOpcao    := {"2 Idiomas","3 Idiomas"}
    //Variaveis para dimensões dos forms
    tsTop      := 0
    tsLeft     := 0
    tsBottom   := 400
    tsRight    := 300
    tsCaption  := 'Impressão de etiquetas identificadoras de produtos.'
    tsClrText  := CLR_BLACK
    tsClrBack  := CLR_WHITE
    tsPixel    := .T.

    pergunte(_cPerg,.T.)

    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
        oFont:= TFont():New('Arial',, -12, .T.)

        oSay1:= TSay():New(010,15,{||'Código do produto:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay2:= TSay():New(025,15,{||'Descrição do produto:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay3:= TSay():New(040,15,{||'Data de abate/produção:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay4:= TSay():New(055,15,{||'Data de embalagem:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay5:= TSay():New(070,15,{||'Tara:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay6:= TSay():New(085,15,{||'Quant. de Caxias:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay7:= TSay():New(100,15,{||'Quant. de Etiquetas:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay11:= TSay():New(115,15,{||'Mesa:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay12:= TSay():New(130,15,{||'Lote:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

        oSay8:= TSay():New(025,080,{||_cDescProd},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay9:= TSay():New(070,080,{||STR(_nTaraProd) + "g"},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay10 :=TSay():New(100,080,{||_cQtdEtq},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

        oRadio := TRadMenu():New(000,005,aOpcao,{|u| Iif(PCount()==0,nRadB,nRadB:=u)},oDialog,,{||NumLingua()},,,,,,75,20,,,,.T.,.T.)        

        oTGet1 := TGet():New(10,80,{ | u | If( PCount() > 0, xTGet1 := u, xTGet1) },oDialog,40,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,xTGet1,,,,.t., )
            oTGet1:cF3 := 'ZZ7'            
            oTGet1:bValid := {|| PorChar() }
            oTGet1:Picture := '@!'
        oTGet2 := TGet():New(040,80,{ | u | If( PCount() > 0, xTGet2 := u, xTGet2) },oDialog,40,10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t., )            
        oTGet3 := TGet():New(055,80,{ | u | If( PCount() > 0, xTGet3 := u, xTGet3) },oDialog,40,10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t., )
        oTGet4 := TGet():New(085,80,{ | u | If( PCount() > 0, xTGet4 := u, xTGet4) },oDialog,40,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,xTGet4,,,,.t., )
            oTGet4:bValid := {|| QuantEtq() }
            oTGet4:Picture := '@!'
        oTGet5 := TGet():New(115,80,{ | u | If( PCount() > 0, xTGet5 := u, xTGet5) },oDialog,40,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,xTGet5,,,,.t., )
        oTGet6 := TGet():New(130,80,{ | u | If( PCount() > 0, xTGet6 := u, xTGet6) },oDialog,40,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,xTGet6,,,,.t., )            

        oTButton1 := TButton():New(150, 50, "Imprimir",oDialog,{||Validacoes()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
        oTButton2 := TButton():New(165, 50, "Cancelar e Sair",oDialog,{||oDialog:end()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )        
        IF (_cOpera == "adriana.freire" .OR. _cOpera == "lucas.bolzan")
        //IF (_cOpera == "adriana.freire")
            oTButton3 := TButton():New(180, 50, "Gerenciar Permissões",oDialog,{||GerenPerm()}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
        ENDIF

        oTGet6:disable()
        oTGet1:bLostFocus:= {|| Dados()}

    oDialog:Activate(,,,.T.,,,)
RETURN

STATIC FUNCTION GerenPerm()
    Local oGet1
    Local cGet1   := PADR(GetMV("SI_USRN1"),254," ")
    Local oGet1_1
    Local cGet1_1 := PADR(GetMV("SI_USRN1.1"),254," ")
    Local oGet2
    Local cGet2   := PADR(GetMV("SI_USRN2"),254," ")
    Local oGet2_1
    Local cGet2_1 := PADR(GetMV("SI_USRN2.1"),254," ")
    Local oGet3
    Local cGet3   := PADR(GetMV("SI_USRN3"),254," ")
    Local oGet3_1
    Local cGet3_1 := PADR(GetMV("SI_USRN3.1"),254," ")
    Local oGet4
    Local cGet4   := PADR(GetMV("SI_USRN4"),254," ")
    
    Static oDlg

    DEFINE MSDIALOG oDlg TITLE "Gerenciador de Níveis" FROM 000, 000  TO 350, 500 COLORS 0, 16777215 PIXEL

    @ 015, 008 SAY oSay PROMPT "Usuários Nível 1:"   SIZE 043, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 015, 065 MSGET oGet1   VAR cGet1   SIZE 183, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 030, 008 SAY oSay PROMPT "Usuários Nível 1.1:" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL    
    @ 030, 065 MSGET oGet1_1   VAR cGet1_1   SIZE 183, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 045, 008 SAY oSay PROMPT "Usuários Nível 2:" SIZE 043, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 045, 065 MSGET oGet2 VAR cGet2 SIZE 183, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 060, 008 SAY oSay PROMPT "Usuários Nível 2.1:" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 060, 065 MSGET oGet2_1 VAR cGet2_1 SIZE 183, 010 OF oDlg COLORS 0, 16777215 PIXEL
    
    @ 075, 008 SAY oSay PROMPT "Usuários Nível 3:" SIZE 043, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 075, 065 MSGET oGet3 VAR cGet3 SIZE 183, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 090, 008 SAY oSay PROMPT "Usuários Nível 3.1:" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 090, 065 MSGET oGet3_1 VAR cGet3_1 SIZE 183, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 105, 008 SAY oSay PROMPT "Usuários Nível 4:" SIZE 043, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 105, 065 MSGET oGet4 VAR cGet4 SIZE 183, 010 OF oDlg COLORS 0, 16777215 PIXEL    
    
    @ 120, 062 BUTTON oButton1 PROMPT "Salvar" SIZE 082, 010 OF oDlg PIXEL ACTION Processa({|| PutMV("SI_USRN1",cGet1), PutMV("SI_USRN1.1",cGet1_1), PutMV("SI_USRN2",cGet2), PutMV("SI_USRN2.1",cGet2_1), PutMV("SI_USRN3",cGet3), PutMV("SI_USRN3.1",cGet3_1), PutMV("SI_USRN4",cGet4)},"Salvando")
    @ 120, 159 BUTTON oButton2 PROMPT "Cancelar" SIZE 082, 010 OF oDlg PIXEL ACTION oDlg:end()
    @ 135, 062 BUTTON oButton3 PROMPT "Ajuda" SIZE 180, 020 OF oDlg PIXEL ACTION HelPNiveis()

    ACTIVATE MSDIALOG oDlg CENTERED
RETURN

STATIC FUNCTION HelPNiveis()
    DEFINE MSDIALOG oDlgHelp TITLE "Informações sobre níveis" FROM 000, 000  TO 250, 900 COLORS 0, 16777215 PIXEL

    @ 010, 005 SAY oSay1  PROMPT "Nível 1: Imprime etiquetas podendo avançar ou retroceder as datas em 1 (um) ano com base na data atual." SIZE 350, 008 OF oDlgHelp COLORS 0, 16777215 PIXEL
    @ 020, 005 SAY oSay2  PROMPT "Nível 1.1: Imprime etiquetas podendo retroceder a data de abate em 1 (um) ano com base na data atual. A data de embalagem deve ser a data atual." SIZE 400, 008 OF oDlgHelp COLORS 0, 16777215 PIXEL
    @ 030, 005 SAY oSay3  PROMPT "Nível 2: Imprime etiquetas podendo avançar ou retroceder as datas em 30 (trinta) dias com base na data atual." SIZE 350, 008 OF oDlgHelp COLORS 0, 16777215 PIXEL    
    @ 040, 005 SAY oSay4  PROMPT "Nível 2.1: Imprime etiquetas podendo retroceder a data de abate em 30 (trinta) dias com base na data atual. A data de embalagem deve ser a data atual." SIZE 400, 008 OF oDlgHelp COLORS 0, 16777215 PIXEL
    @ 050, 005 SAY oSay5  PROMPT "Nível 3: Imprime etiquetas podendo avançar ou retroceder as datas em 14 (quatorze) dias com base na data atual." SIZE 350, 008 OF oDlgHelp COLORS 0, 16777215 PIXEL
    @ 060, 005 SAY oSay6  PROMPT "Nível 3.1: Imprime etiquetas podendo retroceder a data de abate em 14 (quatorze) dias com base na data atual. A data de embalagem deve ser a data atual." SIZE 400, 008 OF oDlgHelp COLORS 0, 16777215 PIXEL
    @ 070, 005 SAY oSay7  PROMPT "Nível 4: Imprime etiquetas podendo avançar ou retroceder as datas em 7 (sete) dias com base na data atual." SIZE 350, 008 OF oDlgHelp COLORS 0, 16777215 PIXEL
    //@ 080, 005 SAY oSay8  PROMPT "Nível 4.1: Imprime etiquetas podendo retroceder a data de abate em 7 (sete) dias com base na data atual. A data de embalagem deve ser a data atual." SIZE 400, 008 OF oDlgHelp COLORS 0, 16777215 PIXEL
    @ 080, 005 SAY oSay9  PROMPT "Caso o usuário não esteja em nenhum dos parâmetros acima ele apenas pode imprimir etiquetas com data de abate." SIZE 350, 350 OF oDlgHelp COLORS 0, 16777215 PIXEL
    @ 090, 010 SAY oSay10 PROMPT "retroagindo sete dias a data atual e a data de embalagem deve ser a do dia atual." SIZE 350, 350 OF oDlgHelp COLORS 0, 16777215 PIXEL

  ACTIVATE MSDIALOG oDlgHelp CENTERED
RETURN

STATIC FUNCTION PorChar()
    _cCodGrpProd    := GetAdvFval( 'SB1' , 'B1_GRUPO' ,FWxFilial( 'SB1' ) + alltrim(xTGet1),1) //BUSCA GRUPO DE PRODUTOS

    if ALLTRIM(_cCodGrpProd) $ (ALLTRIM(GetMV('MV_GRPPORC')) + ALLTRIM(GetMV('MV_GRPCHRQ')))
		oTGet2:disable()
		oTGet2:hide()
        oSay3:disable()
        oSay3:hide()
        oTGet5:disable()
		oTGet5:hide()
        oSay11:disable()
        oSay11:hide()

		Return .T.
	else
		oTGet2:enable()
		oTGet2:show()
		oTGet2:setFocus()
        oSay3:enable()
        oSay3:show()
        oTGet5:enable()
		oTGet5:show()        
        oSay11:enable()
        oSay11:show()

		Return .T.
	Endif
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
                IF (xTGet3 <> DDATABASE)
                    MsgAlert("Você não pode imprimir etiquetas com data de embalagem diferente do dia atual","Aviso")
                    RETURN
                ENDIF
            ELSEIF ((_cOpera $ GetMV('SI_USRN2.1')))
                IF (xTGet2 < DtaMin30)
                    MsgAlert("Você não pode imprimir etiquetas com data de abate anterior a 30 (trinta) dias","Aviso")
                    RETURN
                ENDIF
                IF (xTGet3 <> DDATABASE)
                    MsgAlert("Você não pode imprimir etiquetas com data de embalagem diferente do dia atual","Aviso")
                    RETURN
                ENDIF
            ELSEIF ((_cOpera $ GetMV('SI_USRN3.1')))
                IF (xTGet2 < DtaMin14)
                    MsgAlert("Você não pode imprimir etiquetas com data de abate anterior a 14 (quatorze) dias","Aviso")
                    RETURN
                ENDIF
                IF (xTGet3 <> DDATABASE)
                    MsgAlert("Você não pode imprimir etiquetas com data de embalagem diferente do dia atual","Aviso")
                    RETURN
                ENDIF
            ELSE
                IF (xTGet2 < DDATABASE-7)
                    MsgAlert("Você não pode imprimir etiquetas com data de abate com mais de 7 dias","Aviso")
                    RETURN
                ENDIF
                IF (xTGet3 <> DDATABASE)
                    MsgAlert("Você não pode imprimir etiquetas com data de embalagem diferente do dia atual","Aviso")
                    RETURN
                ENDIF
            ENDIF
        ENDIF
    ELSE        
        IF (xTGet3 > DDATABASE+1)
            MsgAlert("Você não pode imprimir etiquetas com data de embalagem superior a 7 (sete) dias","Aviso")
            RETURN
        ENDIF
        IF (xTGet3 < DDATABASE-1)
            MsgAlert("Você não pode imprimir etiquetas com data de embalagem inferior a 7 (sete) dias","Aviso")
            RETURN
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

    taraSB1    := GetAdvFval('SB1','B1_CTARAP',FWxfilial('SB1')+alltrim(xTGet1),1) // Linhas inseridas para buscar"_NTARAp"
	taraZAB    := GetAdvFval('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(taraSB1),1) // os campos de codigo das taras primarias
	_nTaraProd := (taraZAB * 1000)

    LoteEUA()

	oDialog:refresh()
RETURN

STATIC FUNCTION QuantEtq()
    a := GetAdvFval('SB1','B1_QCAIX',FWxFilial('SB1') + alltrim(xTGet1),1)
    _cQtdEtq := ALLTRIM(STR(a * VAL(xTGet4)))
    _nQtdEtq := (a * VAL(xTGet4))
    oDialog:refresh()
RETURN

STATIC FUNCTION LoteEUA()
    Local _cCadMerc := GetAdvFval('SB1','B1_CADMERC',FWxFilial('SB1') + alltrim(xTGet1),1)

    IF (xTGet1 = '003796')
        oTGet6:enable()
        oDialog:refresh()
    ELSEIF (xTGet1 $ '000300/001834')
        oTGet2:disable()
        oTGet3:disable()
        oTGet5:disable()
        oTGet6:enable()
        oDialog:refresh()
        xTGet3 := DDATABASE
    ELSEIF (_cCadMerc = 'C')
        oTGet6:enable()
        oDialog:refresh()
    ELSE
        oTGet6:disable()
        oDialog:refresh()
    ENDIF

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

    //PARA GERAR OP
    //descrição produto,data de abate, cod do produto, data de produção

    _cCadasM := GetAdvFVal('SB1','B1_CADMERC',FWXFilial('SB1')+AllTrim(xTGet1),1)
	IF (_cCadasM <> "U" .AND. !(xTGet1 $ '000300/001834'))
        U_GeraOP(AllTrim(_cDescProd),xTGet2,xTGet1,xTGet3)
    ENDIF

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

    IF mv_par01 = 1        
        EtiquetaInterna_ZPL()
    ELSEIF mv_par01 = 2        
        EtiquetasInternaRecortes()        
    ELSEIF mv_par01 = 3
        EtiquetasBile()
    ELSEIF mv_par01 = 4
        EtiquetasTripa()
    ELSE
        RETURN .F.
    ENDIF

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
    xTGet5     := Space(1)
    xTGet6     := Space(16)
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
    indice8 := ALLTRIM(FWxFilial('SZU')+DToS(xTGet3)+xTGet1+DToS(xTGet2)+DTos(SToD('')))
    a := GetAdvFval('SZU','ZU_PREDES',indice8,1)
    b := GetAdvFval('SZU','ZU_PREDES',indice8,8)

    IF !(_cCodGrpProd $ GetMV('MV_GRPPORC'))
        _cQueryZU := "SELECT ZU_PREDES AS PREDES "
        _cQueryZU += "FROM " + RetSQLTab('SZU')
        IF !(xTGet1 $ '000300/001834')
            _cQueryZU += "WHERE" + RetSQLFil('SZU') + " AND ZU_COD = " + "'"+ xTGet1 + "'" + " AND ZU_DTRPRO = " + DToS(xTGet3) + " AND ZU_DTABT = " + DToS(xTGet2) + " AND " + retSqlDel('SZU')
        ELSE
            _cQueryZU += "WHERE" + RetSQLFil('SZU') + " AND ZU_COD = " + "'"+ xTGet1 + "'" + " AND ZU_DTRPRO = " + DToS(xTGet2) + " AND ZU_DTABT = " + DToS(xTGet2) + " AND " + retSqlDel('SZU')
        ENDIF

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
            ZBG->ZBG_UFUNCT := FunName()
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

USER FUNCTION GeraOP(_cDescProd, xTGet2, xTGet1, xTGet3)
    LOCAL _nCont := 0
	LOCAL _nCont2 := 0
	LOCAL _nNvinc := 0	
	LOCAL _nMark := 'N'
    LOCAL _nCount := 0

    //QUERY PARA VERIFICAR SE JÁ EXISTE OP (ORDEM DE PRODUÇÃO) PARA EMBALAGEM CRIADA PARA OS DADOS INSERIDOS
    cQuery := " SELECT ZU_NUM AS NUM, ZU_COD AS CODIGO, ZU_DTRPRO AS DTPRODUCAO, ZU_PREDES AS PREDES"
	cQuery += " FROM " + retSqlTab('SZU')
	cQuery += " WHERE " + retSqlFil('SZU')
	cQuery += " AND " + retSqlDel('SZU')
	cQuery += " AND ZU_DTRPRO = '" + DToS(xTGet3) + "' "
	cQuery += " AND ZU_COD = '" + AllTrim(xTGet1) + "' "

	cQuery  := ChangeQuery(cQuery)

    IF SELECT("TMP") != 0
		TMP->(dbCloseArea())
	ENDIF

	TCQUERY cQuery NEW ALIAS "TMP"

    cQuery2 := " SELECT TOP 1 NUM,Z2_CLASSIF "
    cQuery2 += " FROM (SELECT Z2_NUM AS NUM, Z2_CLASSIF, CASE WHEN Z2_CLASSIF = 'HK' THEN 1 WHEN Z2_CLASSIF = 'NE' THEN 2 WHEN Z2_CLASSIF = 'NE' THEN 3 ELSE 4 END PRIORIDADE
    cQuery2 += " FROM SZ2010
    cQuery2 += " WHERE Z2_FILIAL = '00'
    cQuery2 += " AND D_E_L_E_T_ <> '*'
    cQuery2 += " AND Z2_DATAABT = '" + dtos(xTGet2) + "' "
    cQuery2 += " AND Z2_CORORI IN ('T', 'D', 'C')
    cQuery2 += " AND Z2_CLASSIF IN('HK', 'BR', 'NE')) T1
    cQuery2 += " ORDER BY PRIORIDADE"

    cQuery2  := ChangeQuery(cQuery2)
    
    IF SELECT("TMP2") != 0
		TMP2->(dbCloseArea())
	ENDIF

	TCQUERY cQuery2 NEW ALIAS "TMP2"

    IF !(_cCodGrpProd $ GetMV('MV_GRPMDS') .OR. _cCodGrpProd $ GetMV('MV_GRPPORC'))    
        Count to _nCount
        TMP2->(DbGoTop())
        IF _nCount = 0
            U_WFWOPE(xTGet1,xTGet2)
        ENDIF
    ENDIF
    
    SZ2->(DbGoTop()) 
	SZ2->(dbSetOrder(2))

	TMP->(dbGoTop())
	While TMP->(!EOF())
		_cPrevde := alltrim(TMP->PREDES)	
		if  !empty(alltrim(_cPrevde)) .AND. !empty(SZ2->(dbSeek(FWxFilial('SZ2') + alltrim(_cPrevde))))				
            _nCont2++		
            _nNvinc++		
		Endif

		_nCont++
		TMP->(dbSkip())
	Enddo

	TMP2->(dbGoTop())		

	_predes := TMP2->NUM	

	If _nMark = 'N'
		If _nCont = 0 .AND. _nCont2 = 0			
			_nNvinc:= 999
			DTI201wfw(xTGet1,_nNvinc,_cDescProd,xTGet3)
		elseif _nCont > 0		 	
			if _nCont =_nCont2
				DTI201wfw(xTGet1,_nNvinc,_cDescProd,xTGet3)
			Endif
		Endif
	Endif
RETURN

STATIC FUNCTION DTI201wfw(xTGet1,_nNvinc,_cDescProd,xTGet3)	
	Local _cAtivaR := GetMV('SI_LIBR88')		

    If  _nNvinc = 999
        IF _cAtivaR = '1'
            U_DTI88PPE(1,xTGet1,xTGet3, xTGet2, _predes)
        Endif
    Elseif _nNvinc > 0			
        cQuery3 := " SELECT ZU_COD,ZU_DTPROD,ZU_DTABT "
        cQuery3 += " FROM " + retSqlTab('SZU')
        cQuery3 += " WHERE " + retSqlFil('SZU')
        cQuery3 += " AND " + retSqlDel('SZU')
        cQuery3 += " AND ZU_DTPROD = '" + alltrim(dtos(xTGet3)) + "' "
        cQuery3 += " AND ZU_COD = '" + xTGet1 + "' "

        cQuery3  := ChangeQuery(cQuery3)

        If Select("TMP3") != 0
            TMP3->(dbCloseArea())
        Endif

        TCQUERY cQuery3 NEW ALIAS "TMP3"

        TMP3->(dbGoTop())
        WHILE TMP3->(!EOF())
            IF(TMP3->ZU_DTABT = dtos(xTGet2) .and. TMP3->ZU_DTPROD = dtos(xTGet3))
                return .f.
            ENDIF
            TMP3->(DBSKIP())
        END
    Endif
return

STATIC FUNCTION NumLingua()
    IF nRadB = 1
        return 1
    ELSE
        return 2
    ENDIF
RETURN

STATIC FUNCTION EtiquetaInterna_ZPL()
    //BUSCA DADOS DO PRDOUTO
    SB1->(DbSetOrder(1))
    SB1->(MsSeek(FWxFilial('SB1')+alltrim(xTGet1)))
    _cCodGrpProd    := SB1->B1_GRUPO   //BUSCA GRUPO DE PRODUTOS
    _cDestino       := SB1->B1_DESTINO //BUSCA O DESTINO DO PRODUTO    
    _cCadMercadoria := SB1->B1_CADMERC //BUSCA O CADASTRO DA MERCADORIA DO PRODUTO
    //CONDIÇÃO PARA VERIFICAR SE PRODUTO FOR DO MIUDOS OU FOR DA EMBALAGEM PARA DATA DE VALIDADE    
	IF(ALLTRIM(_cCodGrpProd) $ GetMV('MV_GRPMDS'))
		IF(SB1->B1_VALID > 0)
            _DtVal  := xTGet2 + SB1->B1_VALID
        ELSE
            MsgAlert("Data de validade do produto não esta de acordo. Verifique o cadastro do produto com o PCP","Aviso")
            RETURN
        ENDIF
	ELSE
		IF(SB1->B1_VALID > 0)
            _DtVal  := xTGet3 + SB1->B1_VALID            
        ELSE
            MsgAlert("Data de validade do produto não esta de acordo. Verifique o cadastro do produto com o PCP","Aviso")
            RETURN
        ENDIF
	ENDIF    

    //SE DESTINO FOR MERCADO INTERNO OU DESTINO FOR MERCADO EXTERNO E CADASTRO DA MERCADORIA NÃO EXISTIR
    IF (_cDestino = "MI" .or. (_cDestino = "ME" .and. _cCadMercadoria = ""))
        IF(nRadB = 1)
            U_INTBRA(xTGet1,xTGet2,xTGet3,_DtVal,_nQtdEtq)
        ELSEIF (nRadB = 2)
            U_INT3IDIOMA(xTGet1,xTGet2,xTGet3,_DtVal,_nQtdEtq,xTGet5,xTGet6)
        ENDIF
    //SE DESTINO FOR MERCADO EXTERNO E PAIS FOR E.U.A OU CANADA
    ELSEIF (_cDestino = "ME" .and. (_cCadMercadoria = "A" .OR. _cCadMercadoria = "C"))
        IF(nRadB = 1)
            U_INTAME(xTGet1,xTGet2,xTGet3,_DtVal,_nQtdEtq,xTGet5,xTGet6)
        ELSEIF (nRadB = 2)
            U_INT3IDIOMA(xTGet1,xTGet2,xTGet3,_DtVal,_nQtdEtq,xTGet5,xTGet6)
        ENDIF    
    //SE DESTINO FOR MERCADO EXTERNO E PAIS URUGUAI
    ELSEIF (_cDestino = "ME" .and. _cCadMercadoria = "E")
        U_INTUY(xTGet1,xTGet2,xTGet3,_DtVal,_nQtdEtq)
    //SE DESTINO FOR MERCADO EXTERNO E PAIS LIBANO
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
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "510,040" + "^FD" + "Data de produção/Lote:" + "^FS")
            MSCBWrite("^CFA,22" )
            MSCBWrite("^FO" + "480,350" + "^FD" + DtoC(xTGet2) + "^FS")

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
    //SE DESTINO FOR MERCADO EXTERNO E PAIS E.U.A
    ELSEIF (_cDestino = "ME" .and. _cCadMercadoria = "U")
        U_INTUSA(xTGet1,xTGet2,xTGet3,_DtVal,_nQtdEtq)    
    ELSE        
        MSGALERT( "Problema no cadastro do produto: Revisar Destino ou Cadastro de Mercadoria", "Aviso:" )
    ENDIF
RETURN

STATIC FUNCTION EtiquetasInternaRecortes()
    //BUSCA DADOS DO PRDOUTO
    SB1->(DbSetOrder(1))
    SB1->(MsSeek(FWxFilial('SB1')+alltrim(xTGet1)))
    _cTipEtq := GetAdvFval( 'ZZ7' , 'ZZ7_TPETQ' ,FWxFilial( 'ZZ7' ) + alltrim(xTGet1),1)
    _cRaca   := GetAdvFval( 'ZZ7' , 'ZZ7_RACA' ,FWxFilial( 'ZZ7' ) + alltrim(xTGet1),1)
    _cCodGrpProd    := SB1->B1_GRUPO   //BUSCA GRUPO DE PRODUTOS
    _cDestino       := SB1->B1_DESTINO //BUSCA O DESTINO DO PRODUTO    
    _cCadMercadoria := SB1->B1_CADMERC //BUSCA O CADASTRO DA MERCADORIA DO PRODUTO
    //CONDIÇÃO PARA VERIFICAR SE PRODUTO FOR DO MIUDOS OU FOR DA EMBALAGEM PARA DATA DE VALIDADE    
	IF(ALLTRIM(_cCodGrpProd) $ GetMV('MV_GRPMDS'))
		IF(SB1->B1_VALID > 0)
            _DtVal  := xTGet2 + SB1->B1_VALID
        ELSE
            MsgAlert("Data de validade do produto não esta de acordo. Verifique o cadastro do produto com o PCP","Aviso")
            RETURN
        ENDIF
	ELSE
		IF(SB1->B1_VALID > 0)
            _DtVal  := xTGet3 + SB1->B1_VALID            
        ELSE
            MsgAlert("Data de validade do produto não esta de acordo. Verifique o cadastro do produto com o PCP","Aviso")
            RETURN
        ENDIF
	ENDIF

	MSCBWrite("^XA")
	MSCBWrite("^CWA,E:ARIAL.TTF")
    MSCBWrite("^FWR")

    //INFORMAÇÕES NO RODAPÉ DA ETIQQUETA
    MSCBWrite("^CFA,19")
    MSCBWrite("^FO" + "110,100")
    MSCBWrite("^FH\^FD" + "Registro no Minist\82rio da Agricultura SIF/DIPOA sob n.\A7 " + ALLTRIM(ZZ7->ZZ7_MSIF) + "^FS")
    MSCBWrite("^FO" + "080,040")
    MSCBWrite("^FH\^FD" + "Frigorifico Silva Ind\A3stria e Com\82rcio LTDA. Abatedouro Frigor\A1fico Ind. e Com. de Carnes e seus derivados" + "^FS")
    MSCBWrite("^FO" + "050,040")
    MSCBWrite("^FH\^FD" + "BR 392 km 8 Tomazetti, Santa Maria - RS - Brasil, CEP 97065-400, CNPJ: 88.728.027/0001-46" + "^FS")
    MSCBWrite("^FO" + "020,040")
    MSCBWrite("^FH\^FD" + "INDUSTRIA BRASILEIRA. N\C7O CONT\90M GL\E9TEN" + "^FS")

    //CODIGO DE BARRA
    MSCBWrite("^BY3,3,50")
    MSCBWrite("^FT135,170")
    MSCBWrite("^BCR,,N,N")
    MSCBWrite("^FD>;" + ZZ7->ZZ7_CODPRO + "^FS")

    IF(ALLTRIM(_cTipEtq) = "CON" .AND. (ALLTRIM(_cDestino) = "MI" .OR. ALLTRIM(_cDestino) = ""))
        IF(ALLTRIM(_cRaca) = "S" .OR. ALLTRIM(_cRaca) = "")
            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
            MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")            
            MSCBWrite("^FO" + "450,080" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "400,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "370,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "340,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,22")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
                IF("CELSIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ELSEIF("CELCIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ENDIF
                MSCBWrite("^FO" + "275,100" + "^FH\^FD" + MsgTemp + "^FS")
            MSCBWrite("^CFA,22")
            MSCBWrite("^FO" + "205,040" + "^FH\^FD" + "CARNE DESTINADA A TRATAMENTO POR CALOR" + "^FS")
        ELSEIF(ALLTRIM(_cRaca) = "A")
            MSGINFO('Não há etiqueta homologada para este tipo Conserva | Mercado Interno | Angus', "")
        ELSEIF(ALLTRIM(_cRaca) = "B")            
            MSGINFO('Não há etiqueta homologada para este tipo Conserva | Mercado Interno | Black', "")
        ELSEIF(ALLTRIM(_cRaca) = "H")           
            MSGINFO('Não há etiqueta homologada para este tipo Conserva | Mercado Interno | Hereford', "")
        ELSEIF(ALLTRIM(_cRaca) = "N")
            //MSGINFO('Conserva | MI | Novilho', "")
            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
            MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")            
            MSCBWrite("^FO" + "450,080" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "400,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "370,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "340,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,22")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
                IF("CELSIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ELSEIF("CELCIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ENDIF
                MSCBWrite("^FO" + "275,100" + "^FH\^FD" + MsgTemp + "^FS")
            MSCBWrite("^CFA,22")
            MSCBWrite("^FO" + "205,040" + "^FH\^FD" + "CARNE DESTINADA A TRATAMENTO POR CALOR" + "^FS")
        ENDIF
    ELSEIF(ALLTRIM(_cTipEtq) = "CON" .AND. ALLTRIM(_cDestino) = "ME")
        IF(ALLTRIM(_cRaca) = "S" .OR. ALLTRIM(_cRaca) = "")
            MSGINFO('Não há etiqueta homologada para este tipo Conserva | Mercado Externo | Sem Raça', "")
        ELSEIF(ALLTRIM(_cRaca) = "A")
            MSGINFO('Não há etiqueta homologada para este tipo Conserva | Mercado Externo | Angus', "")
        ELSEIF(ALLTRIM(_cRaca) = "B")
            MSGINFO('Não há etiqueta homologada para este tipo Conserva | Mercado Externo | Black', "")
        ELSEIF(ALLTRIM(_cRaca) = "H")
            MSGINFO('Não há etiqueta homologada para este tipo Conserva | Mercado Externo | Hereford', "")
        ELSEIF(ALLTRIM(_cRaca) = "N")
            MSGINFO('Não há etiqueta homologada para este tipo Conserva | Mercado Externo | Novilho', "")
        ENDIF
    ELSEIF(ALLTRIM(_cTipEtq) = "COR" .AND. (ALLTRIM(_cDestino) = "MI" .OR. ALLTRIM(_cDestino) = ""))
        IF(ALLTRIM(_cRaca) = "S" .OR. ALLTRIM(_cRaca) = "")
            //MSGINFO('Corte | MI | Sem Raça', "")
            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
            MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
            MSCBWrite("^FO" + "450,080" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "400,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "370,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "340,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,22")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "275,100" + "^FH\^FD" + MsgTemp + "^FS")
        ELSEIF(ALLTRIM(_cRaca) = "A")
            //MSGINFO('Corte | MI | Angus', "")            
            MSCBWrite("^CFA,21")
            MSCBWrite("^FO" + "575,120" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
            MSCBWrite("^FO" + "545,120" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "450,080" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "400,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "370,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "340,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,22")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "275,100" + "^FH\^FD" + MsgTemp + "^FS")
            
            MSCBWrite("^CFA,19" )
            MSCBWrite("^FO" + "250,040" + "^FH\^FD" + "PRODUZIDA DE ACORDO COM O PROTOCOLO" + "^FS")
            MSCBWrite("^FO" + "220,040" + "^FH\^FD" + "ANGUS, CONTENDO NO M\D6NIMO 50% DE SANGUE" + "^FS")
            MSCBWrite("^FO" + "190,040" + "^FH\^FD" + "ANGUS E SUAS CRUZAS." + "^FS")
            
            //QR CODE
            MSCBWrite("^FO" + "150,850")
            MSCBWrite("^BQN,2,3")
            MSCBWrite("^FD" + "MA," + "https://cnabrasil.org.br/protocolo-angus" + "^FS")
            //IMAGEM LOGO CERTIFICAÇÃO
            MSCBWrite("^FO" + "420,040")
            MSCBWrite("^IME:IMGANGUS.GRF,1,1")
            MSCBWrite("^FO" + "450,010^FH\^FD ^FS")
        ELSEIF(ALLTRIM(_cRaca) = "B")
            MSGINFO('Corte | MI | Black', "")
            MSGINFO('Não há etiqueta homologada para este tipo Corte | Mercado Interno | Black', "")
        ELSEIF(ALLTRIM(_cRaca) = "H")
            //MSGINFO('Recorte | MI | Hereford', "")
            MSCBWrite("^CFA,22")
            MSCBWrite("^FO" + "575,150" + "^FH\^FD" + SUBSTR(ZZ7->ZZ7_DESC,01,25) + "^FS")
            MSCBWrite("^FO" + "545,240" + "^FH\^FD" + SUBSTR(ZZ7->ZZ7_DESC,26)+ "^FS")
            MSCBWrite("^FO" + "515,150" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "450,130" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "400,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "370,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "340,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,22")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "275,100" + "^FH\^FD" + MsgTemp + "^FS")                        
            //IMAGEM LOGO CERTIFICAÇÃO
            MSCBWrite("^FO" + "420,040")
            MSCBWrite("^IME:IMGHEREFORD.GRF,1,1")
            MSCBWrite("^FO" + "480,010^FH\^FD ^FS")
        ELSEIF(ALLTRIM(_cRaca) = "N")                
            //MSGINFO('Corte | MI | Novilho', "")
            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
            MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
            MSCBWrite("^FO" + "450,080" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "400,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "370,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "340,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,22")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "275,100" + "^FH\^FD" + MsgTemp + "^FS")            
        ENDIF
    ELSEIF(ALLTRIM(_cTipEtq) = "COR" .AND. ALLTRIM(_cDestino) = "ME")
        IF(ALLTRIM(_cRaca) = "S" .OR. ALLTRIM(_cRaca) = "")
            //MSGINFO('Corte | ME/A | Sem Raça', "")
            IF (ALLTRIM(_cCadMercadoria) = "A")
                MSCBWrite("^CFA,25")
                MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
                MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_DESCI + "^FS")
                MSCBWrite("^FO" + "515,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
                MSCBWrite("^FO" + "485,040" + "^FH\^FD" + ZZ7->ZZ7_CORTEI + "^FS")
                MSCBWrite("^FO" + "455,100" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
                MSCBWrite("^CFA,19")
                MSCBWrite("^FO" + "380,040" + "^FH\^FD DATA DE ABATE: ^FS")
                MSCBWrite("^FO" + "350,040" + "^FH\^FD SLAUGHTER DATE: ^FS")
                MSCBWrite("^FO" + "320,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
                MSCBWrite("^FO" + "290,040" + "^FH\^FD PRODUCTION DATE/LOT: ^FS")
                MSCBWrite("^FO" + "260,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
                MSCBWrite("^FO" + "230,040" + "^FH\^FD EXPIRY DATE: ^FS")
                MSCBWrite("^CFA,21^FO" + "365,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
                MSCBWrite("^CFA,21^FO" + "305,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
                MSCBWrite("^CFA,21^FO" + "245,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
                MSCBWrite("^CFA,19")
                MsgTemp := Alltrim(SB1->B1_MENETQ2)
                IF("CELSIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ELSEIF("CELCIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ENDIF
                MSCBWrite("^FO" + "195,100" + "^FH\^FD" + MsgTemp + "^FS")            
            ELSE
                MSGINFO( 'Somente cadastro de mercadoria Americano', '' )
            ENDIF
        ELSEIF(ALLTRIM(_cRaca) = "A")            
            MSGINFO('Não há etiqueta homologada para este tipo Corte | Mercado Externo | Angus', "")
        ELSEIF(ALLTRIM(_cRaca) = "B")
            MSGINFO('Não há etiqueta homologada para este tipo Corte | Mercado Externo | Black', "")
        ELSEIF(ALLTRIM(_cRaca) = "H")
            MSGINFO('Não há etiqueta homologada para este tipo Corte | Mercado Externo | Hereford', "")
        ELSEIF(ALLTRIM(_cRaca) = "N")
            //MSGINFO('Corte | ME | Novilho', "")
            IF (ALLTRIM(_cCadMercadoria) = "A")
                MSCBWrite("^CFA,22")
                MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
                MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_DESCI + "^FS")
                MSCBWrite("^FO" + "515,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
                MSCBWrite("^FO" + "485,040" + "^FH\^FD" + ZZ7->ZZ7_CORTEI + "^FS")
                MSCBWrite("^FO" + "440,120" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
                MSCBWrite("^CFA,19")
                MSCBWrite("^FO" + "380,040" + "^FH\^FD DATA DE ABATE: ^FS")
                MSCBWrite("^FO" + "350,040" + "^FH\^FD SLAUGHTER DATE: ^FS")
                MSCBWrite("^FO" + "320,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
                MSCBWrite("^FO" + "290,040" + "^FH\^FD PRODUCTION DATE/LOT: ^FS")
                MSCBWrite("^FO" + "260,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
                MSCBWrite("^FO" + "230,040" + "^FH\^FD EXPIRY DATE: ^FS")
                MSCBWrite("^CFA,21^FO" + "365,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
                MSCBWrite("^CFA,21^FO" + "305,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
                MSCBWrite("^CFA,21^FO" + "245,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
                MSCBWrite("^CFA,19")
                MsgTemp := Alltrim(SB1->B1_MENETQ2)
                IF("CELSIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ELSEIF("CELCIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ENDIF
                MSCBWrite("^FO" + "185,100" + "^FH\^FD" + MsgTemp + "^FS")
            ELSEIF (ALLTRIM(_cCadMercadoria) = "E")
                MSCBWrite("^CFA,22")
                MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
                MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_DESCE + "^FS")
                MSCBWrite("^FO" + "515,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
                MSCBWrite("^FO" + "485,040" + "^FH\^FD" + ZZ7->ZZ7_CORTEE + "^FS")
                MSCBWrite("^FO" + "440,120" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
                MSCBWrite("^CFA,19")
                MSCBWrite("^FO" + "380,040" + "^FH\^FD DATA DE ABATE: ^FS")
                MSCBWrite("^FO" + "350,040" + "^FH\^FD FECHA DE MATANZA: ^FS")
                MSCBWrite("^FO" + "320,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
                MSCBWrite("^FO" + "290,040" + "^FH\^FD FECHA DE PRODUCCI\E3N/LOTE: ^FS")
                MSCBWrite("^FO" + "260,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
                MSCBWrite("^FO" + "230,040" + "^FH\^FD FECHA DE VALIDAD: ^FS")
                MSCBWrite("^CFA,21^FO" + "365,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
                MSCBWrite("^CFA,21^FO" + "305,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
                MSCBWrite("^CFA,21^FO" + "245,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
                MSCBWrite("^CFA,19")
                MsgTemp := Alltrim(SB1->B1_MENETQ2)
                IF("CELSIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ELSEIF("CELCIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ENDIF
                MSCBWrite("^FO" + "185,100" + "^FH\^FD" + MsgTemp + "^FS")
            ELSE
                MSGINFO( 'Somente cadastro de mercadoria Americano ou Espanhol', '' )
            ENDIF
        ENDIF
    ELSEIF(ALLTRIM(_cTipEtq) = "GOR" .AND. (ALLTRIM(_cDestino) = "MI" .OR. ALLTRIM(_cDestino) = ""))
        IF(ALLTRIM(_cRaca) = "S" .OR. ALLTRIM(_cRaca) = "")
            //MSGINFO('Não há etiqueta homologada para este tipo Gordura | Mercado Interno | Sem Raça', "")
            MSCBWrite("^CFA,22")
            MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
            MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
            MSCBWrite("^FO" + "450,040" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "380,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "350,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "320,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "380,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "350,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "320,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,19")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "280,100" + "^FH\^FD" + MsgTemp + "^FS")
        ELSEIF(ALLTRIM(_cRaca) = "A")
            //MSGINFO('GORDURA | MI | Angus', "")

            MSCBWrite("^CFA,40")
            MSCBWrite("^FO" + "575,120" + "^FH\^FD" + "GORDURA ANGUS" + "^FS")

            MSCBWrite("^CFA,21")
            MSCBWrite("^FO" + "520,150" + "^FH\^FD" + "C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + iif(!empty(xTGet5), " MESA:" + xTGet5,"") + "^FS")
            MSCBWrite("^FO" + "470,120" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_DESC) + "^FS")

            MSCBWrite("^CFA,19")

            IF(!ALLTRIM(_cCodGrpProd) $ GetMV('MV_GRPMDS'))
                MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE: ^FS")
                MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
                MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            ELSE
                MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE/PROD/LOTE: ^FS")
                MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE EMBALAGEM: ^FS")
                MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            ENDIF

            MSCBWrite("^FO" + "400,370" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "370,370" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "340,370" + "^FH\^FD" + DToC(_DtVal) + "^FS")

            MsgTemp := Alltrim(SB1->B1_MENETQ2)
                IF("CELSIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ELSEIF("CELCIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ENDIF
                MSCBWrite("^FO" + "290,100" + "^FH\^FD" + MsgTemp + "^FS")
            
            MSCBWrite("^CFA,19" )
            MSCBWrite("^FO" + "250,040" + "^FH\^FD" + "PRODUZIDA DE ACORDO COM O PROTOCOLO" + "^FS")
            MSCBWrite("^FO" + "220,040" + "^FH\^FD" + "ANGUS, CONTENDO NO M\D6NIMO 50% DE SANGUE" + "^FS")
            MSCBWrite("^FO" + "190,040" + "^FH\^FD" + "ANGUS E SUAS CRUZAS." + "^FS")
            
            //QR CODE
            MSCBWrite("^FO" + "150,850")
            MSCBWrite("^BQN,2,3")
            MSCBWrite("^FD" + "MA," + "https://cnabrasil.org.br/protocolo-angus" + "^FS")
            //IMAGEM LOGO CERTIFICAÇÃO
            MSCBWrite("^FO" + "420,040")
            MSCBWrite("^IME:IMGANGUS.GRF,1,1")
            MSCBWrite("^FO" + "450,010^FH\^FD ^FS")
        ELSEIF(ALLTRIM(_cRaca) = "B")
            MSGINFO('Não há etiqueta homologada para este tipo Gordura | Mercado Interno | Angus', "")
        ELSEIF(ALLTRIM(_cRaca) = "H")
            MSGINFO('Não há etiqueta homologada para este tipo Gordura | Mercado Interno | Hereford', "")
        ELSEIF(ALLTRIM(_cRaca) = "N")
            //MSGINFO('GORDURA | MI | Novilho', "")
            MSCBWrite("^CFA,40")
            MSCBWrite("^FO" + "575,040" + "^FH\^FD" + "GORDURA NOVILHO" + "^FS")

            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "520,040" + "^FH\^FD" + "C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: XXXX" + "^FS")
            MSCBWrite("^FO" + "470,040" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_DESC) + "^FS")

            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "400,370" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "370,370" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "340,370" + "^FH\^FD" + DToC(_DtVal) + "^FS")

            MsgTemp := Alltrim(SB1->B1_MENETQ2)
                IF("CELSIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ELSEIF("CELCIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ENDIF
                MSCBWrite("^FO" + "290,100" + "^FH\^FD" + MsgTemp + "^FS")                        
        ENDIF
    ELSEIF(ALLTRIM(_cTipEtq) = "GOR" .AND. ALLTRIM(_cDestino) = "ME")
        IF(ALLTRIM(_cRaca) = "S" .OR. ALLTRIM(_cRaca) = "")
            MSGINFO('Não há etiqueta homologada para este tipo Gordura | Mercado Externo | Sem Raça', "")
        ELSEIF(ALLTRIM(_cRaca) = "A")
            MSGINFO('Não há etiqueta homologada para este tipo Gordura | Mercado Externo | Angus', "")
        ELSEIF(ALLTRIM(_cRaca) = "B")
            MSGINFO('Não há etiqueta homologada para este tipo Gordura | Mercado Externo | Black', "")
        ELSEIF(ALLTRIM(_cRaca) = "H")
            MSGINFO('Não há etiqueta homologada para este tipo Gordura | Mercado Externo | Hereford', "")
        ELSEIF(ALLTRIM(_cRaca) = "N")
            MSGINFO('Não há etiqueta homologada para este tipo Gordura | Mercado Externo | Novilho', "")
        ENDIF
    ELSEIF(ALLTRIM(_cTipEtq) = "RAS" .AND. (ALLTRIM(_cDestino) = "MI" .OR. ALLTRIM(_cDestino) = ""))
        IF(_cRaca = "S" .OR. ALLTRIM(_cRaca) = "")            
            //MSGINFO('Não há etiqueta homologada para este tipo Raspagem | Mercado Interno | Sem Raça', "")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "575,045" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_DESC) + "^FS")
            MSCBWrite("^FO" + "545,045" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_CORTE) + "^FS")
            MSCBWrite("^FO" + "515,045" + "^FH\^FD" + "(PARA FINS INDUSTRIAIS)" + "^FS")
            MSCBWrite("^FO" + "485,045" + "^FH\^FD" + ALLTRIM(SubStr(ZZ7->ZZ7_INGRE2,1,34)) + "^FS")
            MSCBWrite("^FO" + "455,045" + "^FH\^FD" + ALLTRIM(SubStr(ZZ7->ZZ7_INGRE2,35,50)) + "^FS")
            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "400,030" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + "^FS")

            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "300,045" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "270,045" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "240,045" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "300,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "270,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "240,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")

            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "185,100" + "^FH\^FD" + MsgTemp + "^FS")        
        ELSEIF(ALLTRIM(_cRaca) = "A")        
            MSGINFO('Não há etiqueta homologada para este tipo Raspagem | Mercado Interno | Angus', "")
        ELSEIF(ALLTRIM(_cRaca) = "B")        
            MSGINFO('Não há etiqueta homologada para este tipo Raspagem | Mercado Interno | Black', "")
        ELSEIF(ALLTRIM(_cRaca) = "H")
            MSGINFO('Não há etiqueta homologada para este tipo Raspagem | Mercado Interno | Hereford', "")
        ELSEIF(ALLTRIM(_cRaca) = "N")
            //MSGINFO('RASPAGEM | MI | Novilho', "")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "575,030" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_DESC) + "^FS")
            MSCBWrite("^FO" + "545,030" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_CORTE) + "^FS")
            MSCBWrite("^FO" + "515,030" + "^FH\^FD" + "(PARA FINS INDUSTRIAIS)" + "^FS")
            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "400,030" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: XXXX ^FS")

            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "300,030" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "270,030" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "240,030" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "300,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "270,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "240,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")

            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "185,100" + "^FH\^FD" + MsgTemp + "^FS")
        ENDIF
    ELSEIF(ALLTRIM(_cTipEtq) = "RAS" .AND. ALLTRIM(_cDestino) = "ME")
        IF(ALLTRIM(_cRaca) = "S" .OR. ALLTRIM(_cRaca) = "")
            MSGINFO('Não há etiqueta homologada para este tipo Raspagem | Mercado Externo | Sem Raça', "")
        ELSEIF(ALLTRIM(_cRaca) = "A")        
            MSGINFO('Não há etiqueta homologada para este tipo Raspagem | Mercado Externo | Angus', "")
        ELSEIF(ALLTRIM(_cRaca) = "B")        
            MSGINFO('Não há etiqueta homologada para este tipo Raspagem | Mercado Externo | Black', "")
        ELSEIF(ALLTRIM(_cRaca) = "H")
            MSGINFO('Não há etiqueta homologada para este tipo Raspagem | Mercado Externo | Hereford', "")
        ELSEIF(ALLTRIM(_cRaca) = "N")
            //MSGINFO('RASPAGEM | ME | Novilho', "")

            IF (ALLTRIM(_cCadMercadoria) = "E")
                MSCBWrite("^CFA,19")                
                MSCBWrite("^FO" + "575,030" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_DESC) + "^FS")
                MSCBWrite("^FO" + "545,030" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_DESCE) + "^FS")
                MSCBWrite("^FO" + "515,030" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_CORTE) + "^FS")
                MSCBWrite("^FO" + "485,030" + "^FH\^FD" + ALLTRIM(ZZ7->ZZ7_CORTEE) + "^FS")
                MSCBWrite("^FO" + "455,030" + "^FH\^FD" + "(PARA FINS INDUSTRIAIS)" + "^FS")
                MSCBWrite("^FO" + "425,030" + "^FH\^FD" + "(PARA FINES INDUSTRIALES)" + "^FS")
                MSCBWrite("^CFA,25")
                MSCBWrite("^FO" + "350,030" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: XXXX ^FS")

                MSCBWrite("^CFA,19")
                MSCBWrite("^FO" + "300,030" + "^FH\^FD DATA DE ABATE / FECHA MATANZA: ^FS")
                MSCBWrite("^FO" + "270,030" + "^FH\^FD DATA DE PROD. / FECHA DE PRODUCCI\E3N: ^FS")
                MSCBWrite("^FO" + "240,030" + "^FH\^FD DATA DE VALIDADE/FECHA DE VALIDAD: ^FS")
                MSCBWrite("^FO" + "300,440" + "^FH\^FD" + DToC(xTGet2) + "^FS")
                MSCBWrite("^FO" + "270,440" + "^FH\^FD" + DToC(xTGet3) + "^FS")
                MSCBWrite("^FO" + "240,440" + "^FH\^FD" + DToC(_DtVal) + "^FS")

                MsgTemp := Alltrim(SB1->B1_MENETQ2)
                IF("CELSIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ELSEIF("CELCIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ENDIF
                MSCBWrite("^FO" + "185,100" + "^FH\^FD" + MsgTemp + "^FS")
            ELSE
                MSGINFO( 'Somente cadastro de mercadoria Espanhol', '' )
            ENDIF
        ENDIF
    ELSEIF(ALLTRIM(_cTipEtq) = "REC" .AND. (ALLTRIM(_cDestino) = "MI" .OR. ALLTRIM(_cDestino) = ""))
        IF(_cRaca = "S" .OR. ALLTRIM(_cRaca) = "")
            //MSGINFO('Recorte | MI | Sem Raça', "")
            MSCBWrite("^CFA,22")
            MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
            MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
            MSCBWrite("^FO" + "450,040" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "380,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "350,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "320,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "380,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "350,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "320,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,19")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "280,100" + "^FH\^FD" + MsgTemp + "^FS")
        ELSEIF(ALLTRIM(_cRaca) = "A")
            //MSGINFO('Recorte | MI | Angus', "")
            MSCBWrite("^CFA,22")
            MSCBWrite("^FO" + "575,120" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
            MSCBWrite("^FO" + "545,120" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
            MSCBWrite("^FO" + "450,080" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "380,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "350,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "320,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "380,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "350,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "320,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,19")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "280,100" + "^FH\^FD" + MsgTemp + "^FS")            
            MSCBWrite("^CFA,19" )
            MSCBWrite("^FO" + "250,040" + "^FH\^FD" + "PRODUZIDA DE ACORDO COM O PROTOCOLO" + "^FS")
            MSCBWrite("^FO" + "220,040" + "^FH\^FD" + "ANGUS, CONTENDO NO M\D6NIMO 50% DE SANGUE" + "^FS")
            MSCBWrite("^FO" + "190,040" + "^FH\^FD" + "ANGUS E SUAS CRUZAS." + "^FS")
            
            //QR CODE
            MSCBWrite("^FO" + "150,850")
            MSCBWrite("^BQN,2,3")
            MSCBWrite("^FD" + "MA," + "https://cnabrasil.org.br/protocolo-angus" + "^FS")
            //IMAGEM LOGO CERTIFICAÇÃO
            MSCBWrite("^FO" + "420,040")
            MSCBWrite("^IME:IMGANGUS.GRF,1,1")
            MSCBWrite("^FO" + "450,010^FH\^FD ^FS")
        ELSEIF(ALLTRIM(_cRaca) = "B")
            MSGINFO('Não há etiqueta homologada para este tipo Recorte | Mercado Interno | Black', "")
        ELSEIF(ALLTRIM(_cRaca) = "H")
            MSGINFO('Não há etiqueta homologada para este tipo Recorte | Mercado Interno | Hereford', "")
        ELSEIF(ALLTRIM(_cRaca) = "N")
            MSGINFO('Não há etiqueta homologada para este tipo Recorte | Mercado Interno | Novilho', "")
        ENDIF
    ELSEIF(ALLTRIM(_cTipEtq) = "REC" .AND. ALLTRIM(_cDestino) = "ME")        
        MSCBWrite("^FO" + "160,400" + "^FH\^FD" + "LOTE: " + xTGet6 + "^FS")
        IF(_cRaca = "S" .OR. ALLTRIM(_cRaca) = "")            
            IF (ALLTRIM(_cCadMercadoria) = "A")
                MSCBWrite("^CFA,22")
                MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
                MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_DESCI + "^FS")
                MSCBWrite("^FO" + "515,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
                MSCBWrite("^FO" + "485,040" + "^FH\^FD" + ZZ7->ZZ7_CORTEI + "^FS")
                MSCBWrite("^FO" + "440,120" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
                MSCBWrite("^CFA,19")
                MSCBWrite("^FO" + "380,040" + "^FH\^FD DATA DE ABATE: ^FS")
                MSCBWrite("^FO" + "350,040" + "^FH\^FD SLAUGHTER DATE: ^FS")
                MSCBWrite("^FO" + "320,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
                MSCBWrite("^FO" + "290,040" + "^FH\^FD PRODUCTION DATE/LOT: ^FS")
                MSCBWrite("^FO" + "260,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
                MSCBWrite("^FO" + "230,040" + "^FH\^FD EXPIRY DATE: ^FS")
                MSCBWrite("^CFA,21^FO" + "365,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
                MSCBWrite("^CFA,21^FO" + "305,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
                MSCBWrite("^CFA,21^FO" + "245,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
                MSCBWrite("^CFA,19")
                MsgTemp := Alltrim(SB1->B1_MENETQ2)
                IF("CELSIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ELSEIF("CELCIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ENDIF
                MSCBWrite("^FO" + "185,100" + "^FH\^FD" + MsgTemp + "^FS")
            ELSEIF (ALLTRIM(_cCadMercadoria) = "E")
                IF(EMPTY(ZZ7->ZZ7_IMPOR))
                    MSCBWrite("^CFA,22")
                    MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
                    MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_DESCE + "^FS")
                    MSCBWrite("^FO" + "515,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
                    MSCBWrite("^FO" + "485,040" + "^FH\^FD" + ZZ7->ZZ7_CORTEE + "^FS")
                    MSCBWrite("^FO" + "440,120" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
                    MSCBWrite("^CFA,19")
                    MSCBWrite("^FO" + "380,040" + "^FH\^FD DATA DE ABATE: ^FS")
                    MSCBWrite("^FO" + "350,040" + "^FH\^FD FECHA DE MATANZA: ^FS")
                    MSCBWrite("^FO" + "320,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
                    MSCBWrite("^FO" + "290,040" + "^FH\^FD FECHA DE PRODUCCI\E3N/LOTE: ^FS")
                    MSCBWrite("^FO" + "260,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
                    MSCBWrite("^FO" + "230,040" + "^FH\^FD FECHA DE VALIDAD: ^FS")
                    MSCBWrite("^CFA,21^FO" + "365,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
                    MSCBWrite("^CFA,21^FO" + "305,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
                    MSCBWrite("^CFA,21^FO" + "245,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
                    MSCBWrite("^CFA,19")
                    MsgTemp := Alltrim(SB1->B1_MENETQ2)
                    IF("CELSIUS" $ MsgTemp)
                        MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                        MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                    ELSEIF("CELCIUS" $ MsgTemp)
                        MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                        MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                    ENDIF
                    MSCBWrite("^FO" + "185,100" + "^FH\^FD" + MsgTemp + "^FS")
                ELSE
                    MSCBWrite("^CFA,22")
                    MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
                    MSCBWrite("^FO" + "555,040" + "^FH\^FD" + ZZ7->ZZ7_DESCE + "^FS")
                    MSCBWrite("^FO" + "535,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
                    MSCBWrite("^FO" + "515,040" + "^FH\^FD" + ZZ7->ZZ7_CORTEE + "^FS")

                    MSCBWrite("^FO" + "485,120" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")

                    MSCBWrite("^CFA,19")
                    MSCBWrite("^FO" + "450,040" + "^FH\^FD DATA DE ABATE: ^FS")
                    MSCBWrite("^FO" + "430,040" + "^FH\^FD FECHA DE MATANZA: ^FS")
                    MSCBWrite("^FO" + "410,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
                    MSCBWrite("^FO" + "390,040" + "^FH\^FD FECHA DE PRODUCCI\E3N/LOTE: ^FS")
                    MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
                    MSCBWrite("^FO" + "350,040" + "^FH\^FD FECHA DE VALIDAD: ^FS")
                    MSCBWrite("^CFA,21^FO" + "440,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
                    MSCBWrite("^CFA,21^FO" + "400,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
                    MSCBWrite("^CFA,21^FO" + "360,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")

                    MSCBWrite("^FO" + "320,040" + "^FH\^FD" + "Importador: " + AllTrim(ZZ7->ZZ7_IMPOR) + "^FS")                    
                    MSCBWrite("^FO" + "300,040" + "^FH\^FD" + 'Direcci\A2n: ' + SUBSTR(AllTrim(ZZ7->ZZ7_ENDIMP),01,27) + " ^FS")
                    MSCBWrite("^FO" + "280,040" + "^FH\^FD" + SUBSTR(AllTrim(ZZ7->ZZ7_ENDIMP),28,22) + " ^FS")
                    MSCBWrite("^FO" + "260,040" + "^FH\^FD" + "N\A7 RUT: " + AllTrim(ZZ7->ZZ7_RUT) + "^FS")
                    MSCBWrite("^FO" + "240,040" + "^FH\^FD" + "N\A7 Reg. Monografia: " + AllTrim(ZZ7->ZZ7_RMONO) + "^FS")
                    MSCBWrite("^FO" + "220,040" + "^FH\^FD" + "N\A7 Reg. Rotulo: " + AllTrim(ZZ7->ZZ7_RROTU) + "^FS")

                    MSCBWrite("^CFA,19")
                    MsgTemp := Alltrim(SB1->B1_MENETQ2)
                    IF("CELSIUS" $ MsgTemp)
                        MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                        MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                    ELSEIF("CELCIUS" $ MsgTemp)
                        MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                        MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                    ENDIF
                    MSCBWrite("^FO" + "185,100" + "^FH\^FD" + MsgTemp + "^FS")
                ENDIF
            ELSE
                MSGINFO( 'Somente cadastro de mercadoria Americano ou Espanhol', '' )
            ENDIF
        ELSEIF(ALLTRIM(_cRaca) = "A")
            MSGINFO('Não há etiqueta homologada para este tipo Recorte | Mercado Externo | Angus', "")
        ELSEIF(ALLTRIM(_cRaca) = "B")
            MSGINFO('Não há etiqueta homologada para este tipo Recorte | Mercado Externo | Black', "")
        ELSEIF(ALLTRIM(_cRaca) = "H")
            MSGINFO('Não há etiqueta homologada para este tipo Recorte | Mercado Externo | Hereford', "")
        ELSEIF(ALLTRIM(_cRaca) = "N")
            //MSGINFO('Recorte | ME | Novilho', "")            
            IF (ALLTRIM(_cCadMercadoria) = "A")
                MSCBWrite("^CFA,22")
                MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
                MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_DESCI + "^FS")
                MSCBWrite("^FO" + "515,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
                MSCBWrite("^FO" + "485,040" + "^FH\^FD" + ZZ7->ZZ7_CORTEI + "^FS")
                MSCBWrite("^FO" + "440,120" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
                MSCBWrite("^CFA,19")
                MSCBWrite("^FO" + "380,040" + "^FH\^FD DATA DE ABATE: ^FS")
                MSCBWrite("^FO" + "350,040" + "^FH\^FD SLAUGHTER DATE: ^FS")
                MSCBWrite("^FO" + "320,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
                MSCBWrite("^FO" + "290,040" + "^FH\^FD PRODUCTION DATE/LOT: ^FS")
                MSCBWrite("^FO" + "260,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
                MSCBWrite("^FO" + "230,040" + "^FH\^FD EXPIRY DATE: ^FS")
                MSCBWrite("^CFA,21^FO" + "365,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
                MSCBWrite("^CFA,21^FO" + "305,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
                MSCBWrite("^CFA,21^FO" + "245,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
                MSCBWrite("^CFA,19")
                MsgTemp := Alltrim(SB1->B1_MENETQ2)
                IF("CELSIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ELSEIF("CELCIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ENDIF
                MSCBWrite("^FO" + "185,100" + "^FH\^FD" + MsgTemp + "^FS")
            ELSEIF (ALLTRIM(_cCadMercadoria) = "E")
                MSCBWrite("^CFA,22")
                MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
                MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_DESCE + "^FS")
                MSCBWrite("^FO" + "515,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
                MSCBWrite("^FO" + "485,040" + "^FH\^FD" + ZZ7->ZZ7_CORTEE + "^FS")
                MSCBWrite("^FO" + "440,120" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
                MSCBWrite("^CFA,19")
                MSCBWrite("^FO" + "380,040" + "^FH\^FD DATA DE ABATE: ^FS")
                MSCBWrite("^FO" + "350,040" + "^FH\^FD FECHA DE MATANZA: ^FS")
                MSCBWrite("^FO" + "320,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
                MSCBWrite("^FO" + "290,040" + "^FH\^FD FECHA DE PRODUCCI\E3N/LOTE: ^FS")
                MSCBWrite("^FO" + "260,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
                MSCBWrite("^FO" + "230,040" + "^FH\^FD FECHA DE VALIDAD: ^FS")
                MSCBWrite("^CFA,21^FO" + "365,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
                MSCBWrite("^CFA,21^FO" + "305,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
                MSCBWrite("^CFA,21^FO" + "245,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
                MSCBWrite("^CFA,19")
                MsgTemp := Alltrim(SB1->B1_MENETQ2)
                IF("CELSIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ELSEIF("CELCIUS" $ MsgTemp)
                    MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                    MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
                ENDIF
                MSCBWrite("^FO" + "185,100" + "^FH\^FD" + MsgTemp + "^FS")
            ELSE
                MSGINFO( 'Somente cadastro de mercadoria Americano ou Espanhol', '' )
            ENDIF
        ENDIF        
    ELSEIF(ALLTRIM(_cTipEtq) = "CIN" .AND. (ALLTRIM(_cDestino) = "MI" .OR. ALLTRIM(_cDestino) = ""))
        IF(ALLTRIM(_cRaca) = "S" .OR. ALLTRIM(_cRaca) = "")
            //MSGINFO('Industrial | MI | Sem Raça', "")
            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
            MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
            MSCBWrite("^FO" + "450,080" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE/PROD/LOTE: ^FS")
            MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE EMBALAGEM: ^FS")
            MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "400,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "370,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "340,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,22")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "275,100" + "^FH\^FD" + MsgTemp + "^FS")
        ELSEIF(ALLTRIM(_cRaca) = "A")
            //MSGINFO('Corte | MI | Angus', "")            
            MSCBWrite("^CFA,21")
            MSCBWrite("^FO" + "575,120" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
            MSCBWrite("^FO" + "545,120" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "450,080" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "400,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "370,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "340,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,22")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "275,100" + "^FH\^FD" + MsgTemp + "^FS")
            
            MSCBWrite("^CFA,19" )
            MSCBWrite("^FO" + "250,040" + "^FH\^FD" + "PRODUZIDA DE ACORDO COM O PROTOCOLO" + "^FS")
            MSCBWrite("^FO" + "220,040" + "^FH\^FD" + "ANGUS, CONTENDO NO M\D6NIMO 50% DE SANGUE" + "^FS")
            MSCBWrite("^FO" + "190,040" + "^FH\^FD" + "ANGUS E SUAS CRUZAS." + "^FS")
            
            //QR CODE
            MSCBWrite("^FO" + "150,850")
            MSCBWrite("^BQN,2,3")
            MSCBWrite("^FD" + "MA," + "https://cnabrasil.org.br/protocolo-angus" + "^FS")
            //IMAGEM LOGO CERTIFICAÇÃO
            MSCBWrite("^FO" + "420,040")
            MSCBWrite("^IME:IMGANGUS.GRF,1,1")
            MSCBWrite("^FO" + "450,010^FH\^FD ^FS")
        ELSEIF(ALLTRIM(_cRaca) = "B")
            MSGINFO('Corte | MI | Black', "")
            MSGINFO('Não há etiqueta homologada para este tipo Corte | Mercado Interno | Black', "")
        ELSEIF(ALLTRIM(_cRaca) = "H")
            //MSGINFO('Recorte | MI | Hereford', "")
            MSCBWrite("^CFA,22")
            MSCBWrite("^FO" + "575,150" + "^FH\^FD" + SUBSTR(ZZ7->ZZ7_DESC,01,25) + "^FS")
            MSCBWrite("^FO" + "545,240" + "^FH\^FD" + SUBSTR(ZZ7->ZZ7_DESC,26)+ "^FS")
            MSCBWrite("^FO" + "515,150" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "450,130" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "400,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "370,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "340,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,22")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "275,100" + "^FH\^FD" + MsgTemp + "^FS")                        
            //IMAGEM LOGO CERTIFICAÇÃO
            MSCBWrite("^FO" + "420,040")
            MSCBWrite("^IME:IMGHEREFORD.GRF,1,1")
            MSCBWrite("^FO" + "480,010^FH\^FD ^FS")
        ELSEIF(ALLTRIM(_cRaca) = "N")                
            //MSGINFO('Corte | MI | Novilho', "")
            MSCBWrite("^CFA,25")
            MSCBWrite("^FO" + "575,040" + "^FH\^FD" + ZZ7->ZZ7_DESC + "^FS")
            MSCBWrite("^FO" + "545,040" + "^FH\^FD" + ZZ7->ZZ7_CORTE + "^FS")
            MSCBWrite("^FO" + "450,080" + "^FH\^FD C\E3DIGO: " + ALLTRIM(SB1->B1_COD) + " MESA: " + xTGet5 + "^FS")
            MSCBWrite("^CFA,19")
            MSCBWrite("^FO" + "400,040" + "^FH\^FD DATA DE ABATE: ^FS")
            MSCBWrite("^FO" + "370,040" + "^FH\^FD DATA DE PRODU\80\C7O/LOTE: ^FS")
            MSCBWrite("^FO" + "340,040" + "^FH\^FD DATA DE VALIDADE: ^FS")
            MSCBWrite("^FO" + "400,350" + "^FH\^FD" + DToC(xTGet2) + "^FS")
            MSCBWrite("^FO" + "370,350" + "^FH\^FD" + DToC(xTGet3) + "^FS")
            MSCBWrite("^FO" + "340,350" + "^FH\^FD" + DToC(_DtVal) + "^FS")
            MSCBWrite("^CFA,22")
            MsgTemp := Alltrim(SB1->B1_MENETQ2)
            IF("CELSIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELSIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ELSEIF("CELCIUS" $ MsgTemp)
                MsgTemp := StrTran(Alltrim(SB1->B1_MENETQ2), "GRAUS CELCIUS", "ºC" )
                MsgTemp := StrTran(Alltrim(MsgTemp), "ºC", "\A7C")
            ENDIF
            MSCBWrite("^FO" + "275,100" + "^FH\^FD" + MsgTemp + "^FS")            
        ENDIF
    ELSE
        MsgAlert("O pruduto utilizado não se classifica em nenhuma regra de etiquetas. Verique o cadastro junto ao PCP.","")
        U_WFWETQ(ZZ7->ZZ7_CODPRO,_cCadMercadoria,_cDestino,_cTipEtq,_cRaca)
        RETURN .F.
    ENDIF
    //IMAGEM LOGO SIF
    MSCBWrite("^FO" + "130,450")
    MSCBWrite("^IME:LOGOSIF.GRF,1,1^FS")

    MSCBWrite("^PQ" + _cQtdEtq + ",0,1,N")
    MSCBWrite("^XZ")
RETURN

STATIC FUNCTION EtiquetasBile()    
    _cPeso      := Space(6)
    _cData      := SToD('')

    DEFINE MSDIALOG oDlg4 TITLE 'Peso' from 000,000 To 180,210 OF oMainWnd PIXEL
	_lFt := .f.
	@ 010,003 SAY  'Data final:' Object oSay1
    @ 010,035 GET _cData PICTURE "99/99/99"Object oData	
    @ 020,003 SAY  'Peso:' Object oSay1
	@ 020,035 GET _cPeso PICTURE "@E 999.999"Object oPeso	
	@ 035,005 BMPBUTTON TYPE 1 ACTION oDlg4:end() Object Obtn4
	ACTIVATE MSDIALOG oDlg4	

	_lFt := .t.

    U_ETQBIL(xTGet2,xTGet4,xTGet6,_cPeso,_cData)
RETURN

STATIC FUNCTION EtiquetasTripa()    
    _cMaco      := Space(7)
    _Msif       := alltrim(GetAdvFval('ZZ7','ZZ7_MSIF',FWxFilial('ZZ7')+xTGet1,1))

    DEFINE MSDIALOG oDlg4 TITLE 'Maço' from 000,000 To 080,110 OF oMainWnd PIXEL
	_lFt := .f.
	@ 010,003 SAY  'Nº Maço:' Object oSay1
	@ 010,025 GET _cMaco PICTURE "@E 999.999" Object oMaco
	@ 025,005 BMPBUTTON TYPE 1 ACTION oDlg4:end() Object Obtn4
	ACTIVATE MSDIALOG oDlg4

	_lFt := .t.

    U_ETQTRI(xTGet1,xTGet2,_cQtdEtq,xTGet6,_cMaco,_Msif, _nTaraProd)
RETURN

STATIC FUNCTION TabNutrSimp()
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

    _cIDTaBN := ALLTRIM(GetAdvFval('ZZ7','ZZ7_TABNUT',FWxFilial('ZZ7')+xTGet1,1,'Sem informação',.t.))

    //HÁ TRÊS IMPRESSÕES PARA O CABEÇALHO DE VALORES POIS ASSIM O CABEÇALHO É IMPRESSO EM NEGRITO
    MSCBWrite("^CFA,20")
    MSCBWrite("^PW609")

    MSCBWrite("^FO" + "330,040")
    MSCBWrite("^FH\^FD" + "                    INFORMA\80\C7O NUTRICIONAL" + "^FS")
    MSCBWrite("^FO" + "331,040")
    MSCBWrite("^FH\^FD" + "                    INFORMA\80\C7O NUTRICIONAL" + "^FS")
    MSCBWrite("^FO" + "332,040")
    MSCBWrite("^FH\^FD" + "                    INFORMA\80\C7O NUTRICIONAL" + "^FS")

    MSCBWrite("^FO" + "300,040")
    MSCBWrite("^FH\^FD" + "Por\87\C6o: " + GetAdvFval('ZBH','ZBH_PORCPE',_cIDTaBN,1,'Sem informação',.t.) + "^FS")

    //HÁ TRÊS IMPRESSÕES PARA O CABEÇALHO DE VALORES POIS ASSIM O CABEÇALHO É IMPRESSO EM NEGRITO
    MSCBWrite("^FO" + "270,040")
    MSCBWrite("^FD" + "                                              100 g              %VD*" + "^FS")        
    MSCBWrite("^FO" + "271,040")
    MSCBWrite("^FD" + "                                              100 g              %VD*" + "^FS")
    MSCBWrite("^FO" + "272,040")
    MSCBWrite("^FD" + "                                              100 g              %VD*" + "^FS")    

    MSCBWrite("^FO" + "240,040")
    MSCBWrite("^FH\^FD" + "Valor energ\82tico (kcal)" + "^FS")
    MSCBWrite("^FO" + "240,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VEN100',_cIDTaBN,1,'Sem informação',.t.))  + "^FS")
    MSCBWrite("^FO006,455")
    MSCBWrite("^FO" + "240,130")
    MSCBWrite("^FB" + "700,001,0,C")    
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VENVD',_cIDTaBN,1,'Sem informação',.t.))  + "^FS")

    MSCBWrite("^FO" + "210,040")
    MSCBWrite("^FH\^FD" + "Prote\A1nas (g)" + "^FS")
    MSCBWrite("^FO" + "210,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PRO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "210,130")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PROVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^FO" + "180,040" + "^FD")
    MSCBWrite("^FD" + "Gorduras totais (g)" + "^FS")    
    MSCBWrite("^FO" + "180,040" + "^FD")
    MSCBWrite("^FB" + "600,001,0,C")

    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    MSCBWrite("^FO" + "180,130" + "^FD")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTOVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^FO" + "150,040")
    MSCBWrite("^FD" + " Gorduras saturadas  (g)" + "^FS")
    MSCBWrite("^FO" + "150,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSA100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "150,130")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSAVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^FO" + "120,040")
    MSCBWrite("^FH\^FD" + "S\A2dio (mg)" + "^FS")
    MSCBWrite("^FO" + "120,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SOD100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "120,130")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SODVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^FO" + "085,040")
    MSCBWrite("^FH\^FD" + "N\C6o cont\82m quantidades significativas de carboidratos," + "^FS")

    MSCBWrite("^FO" + "065,040")
    MSCBWrite("^FH\^FD" + "a\87\A3cares totais, a\87\A3cares adicionados, gorduras trans" + "^FS")

    MSCBWrite("^FO" + "045,040")
    MSCBWrite("^FD" + "e fibras alimentares." + "^FS")

    MSCBWrite("^FO" + "015,040")
    MSCBWrite("^FH\^FD" + "*Percentual de valores di\A0rios fornecidos pela por\87\C6o" + "^FS")
RETURN

STATIC FUNCTION TabNutrComp()
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

    _cIDTaBN := ALLTRIM(GetAdvFval('ZZ7','ZZ7_TABNUT',FWxFilial('ZZ7')+xTGet1,1,'Sem informação',.t.))

    //HÁ TRÊS IMPRESSÕES PARA O CABEÇALHO DE VALORES POIS ASSIM O CABEÇALHO É IMPRESSO EM NEGRITO
    MSCBWrite("^CFA,20")
    MSCBWrite("^PW609")

    MSCBWrite("^FO" + "330,040")
    MSCBWrite("^FH\^FD" + "                    INFORMA\80\C7O NUTRICIONAL" + "^FS")
    MSCBWrite("^FO" + "331,040")
    MSCBWrite("^FH\^FD" + "                    INFORMA\80\C7O NUTRICIONAL" + "^FS")
    MSCBWrite("^FO" + "332,040")
    MSCBWrite("^FH\^FD" + "                    INFORMA\80\C7O NUTRICIONAL" + "^FS")

    MSCBWrite("^FO" + "300,040")
    MSCBWrite("^FH\^FD" + "Por\87\C6o: " + GetAdvFval('ZBH','ZBH_PORCPE',_cIDTaBN,1,'Sem informação',.t.) + "^FS")

    //HÁ TRÊS IMPRESSÕES PARA O CABEÇALHO DE VALORES POIS ASSIM O CABEÇALHO É IMPRESSO EM NEGRITO
    MSCBWrite("^FO" + "270,040")
    MSCBWrite("^FD" + "                                              100 g              %VD*" + "^FS")        
    MSCBWrite("^FO" + "271,040")
    MSCBWrite("^FD" + "                                              100 g              %VD*" + "^FS")
    MSCBWrite("^FO" + "272,040")
    MSCBWrite("^FD" + "                                              100 g              %VD*" + "^FS")    

    MSCBWrite("^FO" + "240,040")
    MSCBWrite("^FH\^FD" + "Valor energ\82tico (kcal)" + "^FS")
    MSCBWrite("^FO" + "240,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VEN100',_cIDTaBN,1,'Sem informação',.t.))  + "^FS")
    MSCBWrite("^FO006,455")
    MSCBWrite("^FO" + "240,130")
    MSCBWrite("^FB" + "700,001,0,C")    
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_VENVD',_cIDTaBN,1,'Sem informação',.t.))  + "^FS")

    MSCBWrite("^FO" + "210,040")
    MSCBWrite("^FH\^FD" + "Prote\A1nas (g)" + "^FS")
    MSCBWrite("^FO" + "210,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PRO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "210,130")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_PROVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^FO" + "180,040" + "^FD")
    MSCBWrite("^FD" + "Gorduras totais (g)" + "^FS")    
    MSCBWrite("^FO" + "180,040" + "^FD")
    MSCBWrite("^FB" + "600,001,0,C")

    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTO100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")    
    MSCBWrite("^FO" + "180,130" + "^FD")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GTOVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^FO" + "150,040")
    MSCBWrite("^FD" + " Gorduras saturadas  (g)" + "^FS")
    MSCBWrite("^FO" + "150,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSA100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^CFA,20" )
    MSCBWrite("^FO" + "150,130")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_GSAVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^FO" + "120,040")
    MSCBWrite("^FH\^FD" + "S\A2dio (mg)" + "^FS")
    MSCBWrite("^FO" + "120,040")
    MSCBWrite("^FB" + "600,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SOD100',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")
    MSCBWrite("^FO" + "120,130")
    MSCBWrite("^FB" + "700,001,0,C")
    MSCBWrite("^FD" + ALLTRIM(GetAdvFval('ZBH','ZBH_SODVD',_cIDTaBN,1,'Sem informação',.t.)) + "^FS")

    MSCBWrite("^FO" + "085,040")
    MSCBWrite("^FH\^FD" + "N\C6o cont\82m quantidades significativas de carboidratos," + "^FS")

    MSCBWrite("^FO" + "065,040")
    MSCBWrite("^FH\^FD" + "a\87\A3cares totais, a\87\A3cares adicionados, gorduras trans" + "^FS")

    MSCBWrite("^FO" + "045,040")
    MSCBWrite("^FD" + "e fibras alimentares." + "^FS")

    MSCBWrite("^FO" + "015,040")
    MSCBWrite("^FH\^FD" + "*Percentual de valores di\A0rios fornecidos pela por\87\C6o" + "^FS")
RETURN
