#INCLUDE "colors.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TOTVS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI174  º Autor ³ Lucas Bolzan         º Data ³  09/05/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressão de etiquetas de produtos                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Almoxarifado (SIGAFIN)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER Function DTI174()
    Local tsTop := 0
    Local tsLeft := 0
    Local tsBottom := 300
    Local tsRight := 300
    Local tsCaption := 'Impressão de etiquetas identificadoras de produtos.'
    Local tsClrText := CLR_BLACK
    Local tsClrBack := CLR_WHITE
    Local tsPixel := .T.
    //Variaveis Gerais
    Private cTGet1 := Space(6)
    Private cTGet2 := Space(2)
    Private cTGet3 := Space(3)
    Private _cDescProd := Space(40)
    Private _cGrupo := Space(4)
    Private _cIP := GETMV('SI_IPPCAMX')
    Private _cGrpPC := GETMV('SI_PCAMX')

    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
        oFont  := TFont():New('Arial',, -12, .T.)

        oSay1  := TSay():New(10,15,{||'Código:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oTGet1 := TGet():New(08,50,{ | u | if( PCount() > 0, cTGet1 := u, cTGet1) },oDialog,40,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet1,,,,.t.,)
        oTGet1:cF3 := 'SB1'
        oTGet1:bValid := {|| Validacoes(1)}
        oTGet1:Picture := '@!'

        oSay2  := TSay():New(25,15,{||'Armazém:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oTGet2 := TGet():New(23,50,{ | u | if( PCount() > 0, cTGet2 := u, cTGet2) },oDialog,05,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet2,,,,.t.,)
        oTGet2:cF3 := 'NNR'
        oTGet2:bValid := {|| Validacoes(2)}
        oTGet2:Picture := '@!'

        oSay2  := TSay():New(40,15,{||'Descrição:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay3  := TSay():New(40,50,{||_cDescProd},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

        oSay2  := TSay():New(55,15,{||'Grupo:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oSay3  := TSay():New(55,50,{||_cGrupo},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

        oSay4  := TSay():New(70,15,{||'Quantidade:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
        oTGet2 := TGet():New(68,50,{ | u | if( PCount() > 0, cTGet3 := u, cTGet3) },oDialog,05,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet3,,,,)

        oTButton1 := TButton():New(90, 50, "Imprimir",oDialog,{||Imprime()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F.)

        oTGet1:bLostFocus:= {|| Dados()}
    oDialog:Activate(,,,.T.,,,)
return

Static Function Validacoes(_nModo)
    _lRet := .T.
    if _nModo = 1
        if (empty(oTGet1:bLostFocus))
            FWAlertWarning("Obrigatrório informar um produto.", "ALERTA")
            _lRet := .F.
        endif

        SB1->(DbGoTop())
        SB1->(DbSetOrder(1))
        if !(SB1->(MsSeek(FWxfilial('SB1')+cTGet1)))
            FWAlertWarning("Produto informado não existe.", "ALERTA")
            _lRet := .F.
        endif
    else
        if (empty(oTGet2:bLostFocus))
            FWAlertWarning("Obrigatrório informar um armazém.", "ALERTA")
            _lRet := .F.
        endif

        SBF->(DbGoTop())
        SBF->(DbSetOrder(2))
        if !(SBF->(MsSeek(FWxfilial('SBF')+padr(cTGet1,15,' ')+cTGet2)))
            FWAlertWarning("Produto sem saldo no armazém.", "ALERTA")
            _lRet := .F.
        endif
    endif
return _lRet

Static Function Dados()
    SB1->(dbsetorder(1))
	if SB1->(MsSeek(FWxfilial('SB1')+cTGet1))
        _cDescProd := SB1->B1_DESC
        _cGrupo := SB1->B1_GRUPO
    endif
return

Static Function Imprime()

	Processa({||Etiqueta() },"IMPRESSAO DE ETIQUETA","Realizando envio à impressora...")

return

Static Function Etiqueta()
    Local i
    tamanhoFonteA := "30,0"
    _nQuantEtiq   := VAL(alltrim(cTGet3))
    _nCodProduto  := cTGet1
    _cCodProduto  := cValToChar(_nCodProduto)
    _cGrupoProd   := GetAdvFVal('SB1','B1_GRUPO',FWFilial('SB1')+cTGet1,1)
    _cLocaliz     := GetAdvFVal('SBF','BF_LOCALIZ',FWxfilial('SBF')+padr(cTGet1,15,' ')+cTGet2,2,"")

    ProcRegua(_nQuantEtiq)

    for i := 0 to _nQuantEtiq -1
        _nCount := 0
        _nX := 7
        _nColuna := 5

        incproc()

        _cEst := getComputerName()

        if(_cEst $ _cGrpPC)
            MSCBPRINTER('S600','IP',,,,,_cIP)
            MSCBCHKSTATUS(.f.)
            MSCBBEGIN(1,4,50)

            while _nCount < 2
                if _nCount == 1
                    /* Lado direito*/
                    MSCBSAY(55,05,'Código: ' + alltrim(_cCodProduto),"N","0",tamanhoFonteA)
                    MSCBSAY(55,10,'Grupo: ' + alltrim(_cGrupoProd),"N","0",tamanhoFonteA)
                    MSCBSAY(55,15,'Descrição:',"N","0",tamanhoFonteA)
                    MSCBSAY(55,20,substr(alltrim(_cDescProd),1,22),"N","0",tamanhoFonteA)
                    MSCBSAY(55,25,substr(alltrim(_cDescProd),23,22),"N","0",tamanhoFonteA)
                    MSCBSAYBAR(60,30,alltrim(_cCodProduto),"N","C",8,.F.,.F.,,,3,08,.T.)
                    MSCBSAY(55,40,'Local: ' + alltrim(_cLocaliz),"N","0",tamanhoFonteA)
                else
                    /* Lado Esquerdo*/
                    MSCBSAY(02,05,'Código: ' + alltrim(_cCodProduto),"N","0",tamanhoFonteA)
                    MSCBSAY(02,10,'Grupo: ' + alltrim(_cGrupoProd),"N","0",tamanhoFonteA)
                    MSCBSAY(02,15,'Descrição:',"N","0",tamanhoFonteA)
                    MSCBSAY(02,20,substr(alltrim(_cDescProd),1,22),"N","0",tamanhoFonteA)
                    MSCBSAY(02,25,substr(alltrim(_cDescProd),23,22),"N","0",tamanhoFonteA)
                    MSCBSAYBAR(07,30,alltrim(_cCodProduto),"N","C",8,.F.,.F.,,,3,08,.T.)
                    MSCBSAY(02,40,'Local: ' + alltrim(_cLocaliz),"N","0",tamanhoFonteA)
                endif

                _nCount++
            enddo

            MSCBend()
            MSCBCLOSEPRINTER()

            if mod(i,10) = 0
                sleep(1500)
            endif
        else
            MSGINFO( 'O computador ' + _cEst + ' não está autorizado a imprimir este tipo de etiqueta.', 'AVISO' )
        endif
    NEXT
    LimpaCampos()
return

Static Function LimpaCampos()
	cTGet1 := Space(6)
    cTGet2 := Space(2)
    cTGet3 := Space(3)
    _cDescProd := Space(40)
	oDialog:refresh()
return
