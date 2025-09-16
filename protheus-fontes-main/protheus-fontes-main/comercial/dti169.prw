#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI169    ºAutor  ³Adonai Gabriel      º Data ³  20/03/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Rotina para gerar acréscimos ou decréscimos de conta     º±±
±±º          ³   corrente para algum representante                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI169()

    campoA   := 0.0
	campoB   := Space(06)
	campoC   := stod('')
    campoD   := Space(60)
    campoE   := {'A', 'D'}
	_nValor  := 0.0
	_cRepres := Space(06)
	_dData   := stod('')
    _cMotiv  := Space(60)
    _cTpBoni := Space(1)

	DEFINE MSDIALOG telaCC FROM 0,0 TO 450,350 PIXEL TITLE "GERACAO DE CONTA CORRENTE PARA REPRESENTANTE"

	@ 01,01 SAY "Valor (R$):" of telaCC
	@ 02,01 SAY "Representante:" of telaCC
	@ 03,01 SAY "Data:" of telaCC
    @ 04,01 SAY "Motivo:" of telaCC
    @ 05,01 SAY "T. Boni.(A,D):" of telaCC

    @ 01,08 MSGET campoA VAR _nValor SIZE 40,10 OF telaCC picture '@E 999,999.99' VALID _nValor != 0.0
    @ 02,08 MSGET campoB VAR _cRepres SIZE 30,10 F3 'SA3' OF telaCC picture '@!' VALID !Vazio()
	@ 03,08 MSGET campoC VAR _dData SIZE 30,10 OF telaCC picture '99/99/99' VALID !Vazio()
	@ 04,08 MSGET campoD VAR _cMotiv SIZE 60,10 OF telaCC picture '@!' VALID !Vazio()
    @ 05,08 MSCOMBOBOX oComboBox VAR _cTpBoni ITEMS campoE SIZE 20,10 OF telaCC

	@ 200,25 BUTTON btn1 PROMPT "Gerar" SIZE 50,15 OF telaCC  pixel action MostraMsg()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaCC  pixel action telaCC:end()

	ACTIVATE MSDIALOG telaCC CENTERED

Return

Static Function MostraMsg()

	Processa({|| GeraCC()},"GERACAO DE CONTA CORRENTE","Gerando registro de conta corrente...")
	sleep(1000)
	telaCC:refresh()
	FWAlertSuccess('Conta corrente gerada com sucesso!', "Sucesso!")

Return

Static Function GeraCC()

    _cNum := getsx8num('ZCC','ZCC_NUM')
	confirmSX8()

	reclock('ZCC',.t.)
	ZCC->ZCC_FILIAL := cFilAnt
	ZCC->ZCC_NUM    := _cNum
	ZCC->ZCC_DATA   := _dData
	ZCC->ZCC_REPRES := _cRepres
	ZCC->ZCC_NOMREP := Posicione('SA3',1,xfilial('SA3')+_cRepres,'A3_NOME')
	ZCC->ZCC_TPBONI := _cTpBoni
	ZCC->ZCC_VALOR  := _nValor
	ZCC->ZCC_MOTIV  := _cMotiv
	ZCC->ZCC_USER   := UsrRetName(RetCodUsr())
	msunlock()

Return
