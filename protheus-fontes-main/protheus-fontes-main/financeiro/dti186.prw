#INCLUDE 'protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI186   º Autor ³ Lucas Bolzanº Data ³  25/01/2023		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao ³Rotina para desbloqueio (ativação) de TODOS os clientes    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FATURAMENTO/FINANCEIRO                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION DTI186()
    CodEmp := FWCodEmp('SM0')
    DEFINE MSDIALOG oDlg TITLE "Desbloqueio Geral de Clientes" FROM 000, 000  TO 057, 500 COLORS 0, 16777215 PIXEL    
    @ 001, 000 BUTTON oButton1 PROMPT "DESBLOQUEAR TODOS CLIENTES" SIZE 251, 012 OF oDlg PIXEL ACTION MensgRun()
    @ 014, 000 BUTTON oButton2 PROMPT "CANCELAR" SIZE 251, 012 OF oDlg PIXEL ACTION (oDlg:End())
    ACTIVATE MSDIALOG oDlg CENTERED
RETURN

STATIC FUNCTION MensgRun()
    MsgRun("Aguarde... Alterando valores...",,{||  Desbloqueia() })
RETURN

STATIC FUNCTION Desbloqueia()
    DbSelectArea( 'SA1' )    
    SA1->(DbSetOrder(1))
    SA1->(dbGoTop())

    WHILE (SA1->(!EOF()))
        RecLock('SA1',.F.)
        SA1->A1_MSBLQL := '2'
        SA1->A1_SIBLQL := '2'
        SA1->A1_POBLQL := '2'
        MsUnlock()
        SA1->(dbSkip())                        
    END
    MsgInfo("Clientes desbloqueados (ativados)", "INFO")
RETURN
