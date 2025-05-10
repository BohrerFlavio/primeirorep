#INCLUDE 'PROTHEUS.CH'
#INCLUDE "totvs.ch"
#INCLUDE "tbiconn.ch"

USER FUNCTION DTI187
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI187  º Autor ³ Lucas Bolzan         º Data ³  09/10/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retira marca FUSION do carregamento                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Almoxarifado (SIGAFIN)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

tsTop := 0
    tsLeft := 0
    tsBottom := 200
    tsRight := 300
    tsCaption := 'Retirar marca FUSION de carregamentos.'
    tsClrText := CLR_BLACK
    tsClrBack := CLR_WHITE
    tsPixel := .T.    
    //Variaveis Gerais
    _cNumCar := Space(6)
    
    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
        oFont:= TFont():New('Arial',, -12, .T.)
        
        oSay1:= TSay():New(10,15,{||'Cód. do carregamento:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)        
        oTGet1 := TGet():New(08,75,{ | u | If( PCount() > 0, _cNumCar := u, _cNumCar) },oDialog,40,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,_cNumCar,,,,.t., )
        oTGet1:cF3 := 'ZZ4_1'
        oTGet1:bValid := {|| Validacoes() }
        oTGet1:Picture := '@!'

        oTButton1 := TButton():New(40, 30, "Altera marca",oDialog,{||AlteraDados()}, 90,10,,,.F.,.T.,.F.,,.F.,,,.F. )
        oTButton2 := TButton():New(55, 30, "Cancelar e Sair",oDialog,{||oDialog:end()}, 90,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oDialog:Activate(,,,.T.,,,)
RETURN

STATIC FUNCTION Validacoes()    
    IF (empty(oTGet1:bLostFocus))
        MsgAlert("Obrigatrório informar um carregamento.", "Aviso")
    ENDIF

    DbSelectArea('ZZ4')
    ZZ4->(DbSetOrder(1))
    IF !ZZ4->(DbSeek(FWxFilial('ZZ4')+_cNumCar))
        MsgAlert("Carregamento informado não existe.", "Aviso")
    ENDIF
RETURN


STATIC FUNCTION AlteraDados()    
    CodEmp := FWCodEmp('SM0')
    
    DbSelectArea('ZZ4')
    ZZ4->(DbSetOrder(1))
    IF !ZZ4->(DbSeek(FWxFilial('ZZ4')+_cNumCar))
        MsgAlert("Carregamento informado não existe.", "ALERTA")
        RETURN
    ELSE
        IF ZZ4->ZZ4_STAFUS <> '1'
            cQuery := "UPDATE ZZ4" + CodEmp + '0'
            cQuery += " SET ZZ4_STAFUS = '1'"
            cQuery += " WHERE " + RetSQLFil('ZZ4') + " AND " + " ZZ4_PRECAR = " + "'" + _cNumCar + "'"

            TcSqlExec(cQuery)

            MSGINFO( 'Marca retirada', 'INFORMAÇÂO' )
        ELSE
            MSGINFO("Marca não alterada", "INFORMAÇÂO")
        ENDIF
    ENDIF
RETURN
