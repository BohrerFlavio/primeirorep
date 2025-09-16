#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI175            º Autor ³ Lucas Bolzan º Data ³ 24/08/23  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorno de pallets para o estoque                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Expedições                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION DTI184()
//Variaveis para dimensões dos forms
    tsTop      := 0
    tsLeft     := 0
    tsBottom   := 300
    tsRight    := 300
    tsCaption  := 'Reabilitar pallets para uso'
    tsClrText  := CLR_BLACK
    tsClrBack  := CLR_WHITE
    tsPixel    := .T.
    //Variaveis gerais
    _nNumPal    := Space(10)

    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
    oFont:= TFont():New('Arial',, -24, .T.)

    oSay1:= TSay():New(010,30,{||'Código do pallet:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
    oTGet1 := TGet():New(30,30,{ | u | If( PCount() > 0, _nNumPal := u, _nNumPal) },oDialog,100,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,_nNumPal,,,,.t.,)
    oTGet1:cF3 := 'ZBF'
    oTGet1:Picture := '@!'

    oTButton1 := TButton():New(50, 30, "Reabilitar pallets",oDialog,{||RevivePallet()}, 90,10,,,.F.,.T.,.F.,,.F.,,,.F.)
    oTButton2 := TButton():New(65, 30, "Cancelar e Sair",oDialog,{||oDialog:end()}, 90,10,,,.F.,.T.,.F.,,.F.,,,.F.)
    oDialog:Activate(,,,.T.,,,)   
RETURN

STATIC FUNCTION RevivePallet()
    dDataSaida :=  GetAdvFval('ZBF','ZBF_DATAS',FWxFilial('ZBF') + alltrim(_nNumPal),1)
    cHoraSaida :=  GetAdvFval('ZBF','ZBF_HORAS',FWxFilial('ZBF') + alltrim(_nNumPal),1)

    DbSelectArea('ZBF')
    ZBF->(DbSetOrder(1))
    IF !ZBF->(MsSeek(FWxFilial('ZBF')+_nNumPal))
        MsgAlert("Pallet informado não existe.", "ALERTA")
        RETURN
    ELSE
        IF !Empty(dDataSaida) .OR. !Empty(cHoraSaida)

            reclock("ZBF",.f.)
            ZBF_DATAS := stod("")
            ZBF_HORAS := ""
            msunlock()

            u_dtilog(cFilAnt, "DTI184", "Exclusão do Pallet -> " + ZBF->ZBF_NUM + " | Carreg. -> " + ZBF->ZBF_PRECAR, "E")

            MSGINFO('Pallet retornado para uso', 'INFORMAÇÂO')
        ELSE
            MSGINFO("Pallet já está em estoque", "INFORMAÇÂO")
        ENDIF
    ENDIF
RETURN
