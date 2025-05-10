#INCLUDE 'protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI166   บ Autor ณ Lucas Bolzanบ Data ณ  25/01/2023		  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณRotina para desbloqueio (ativa็ใo) de TODOS os clientes    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATURAMENTO/FINANCEIRO                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

USER FUNCTION DTI166()
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
    IF !CodEmp <> '07'
        DbSelectArea( 'SA1' )    
        SA1->(DbSetOrder(1))
        SA1->(dbGoTop())

        WHILE (SA1->(!EOF()))
            RecLock('SA1',.F.)
            SA1->A1_MSBLQL := '2'
            MsUnlock()
            SA1->(dbSkip())                        
        END
        MsgInfo("Clientes desbloqueados (ativados)", "INFO")     
    ELSE
        MsgInfo("ESSA FUNวรO APENAS PODE SER USADA NA EMPRESA TRANSPORTADORA")
    ENDIF    
RETURN
