#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} SB_A1VEN
Markbrowse em MVC no cadastro de clientes para alterar automaticamente vendedores com o novo código informado para os clientes marcados
@author 	Evandro Mugnol
@since 		07/08/2016
@version 	1.0
@obs 		Criar o campo A1_OKFS com o tamanho 2 no configurador e deixar como não usado
Não se pode executar função MVC dentro do fórmulas
/*/

User Function SB_A1VEN()
	Private oMark

	// Criando o MarkBrow
	oMark := FWMarkBrowse():New()
	oMark:SetAlias("SA1")

	// Setando semáforo, descrição e campo de mark
	oMark:SetSemaphore(.T.)
	oMark:SetDescription("Seleção do Cadastro de Clientes")
	oMark:SetFieldMark("A1_OKFS")

	// Ativando a janela
	oMark:Activate()

Return NIL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função MenuDef para criação do menu MVC                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function MenuDef()
	Local aRotina := {}

	// Criação das opções
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.SB_A1MVC' OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.SB_A1MVC' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Processar'  ACTION 'U_MarkProc'       OPERATION 2 ACCESS 0

Return aRotina


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função ModelDef para criação do modelo de dados MVC                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ModelDef()

Return FWLoadModel("SB_A1MVC")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função ViewDef para criação da visão MVC                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ViewDef()

Return FWLoadView("SBA1MVC")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função MarkProc para processamento dos registros que estão marcados    ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function MarkProc()

	Local aArea    := GetArea()
	Local cMarca   := oMark:Mark()
	Local lInverte := oMark:IsInvert()
	Local nCt	   := 0

	Private _oTela, _oConfir, _bOk
	Private _cTitulo    := OemToAnsi("Código Novo Vendedor")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)

	_cVendedor := Space(06)
	DbSelectArea("SA3")
	_cNomeVend := AllTrim(fBuscaCpo("SA3", 1, xFilial("SA3") + _cVendedor, "A3_NOME"))

	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(100), C(700) PIXEL
	@ C(005), C(100) SAY "INFORME O CÓDIGO DO NOVO VENDEDOR"							Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela

	@ C(015), C(010) SAY "Novo Vendedor"   		       									Size C(080), C(10) FONT _oFtArial24 COLOR CLR_GREEN PIXEL OF _oTela
	@ C(024), C(010) MSGET _cVendedor Picture "@!" When .T. Valid VldVen() F3 "SA3"		Size C(045), C(08) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(024), C(080) MSGET _cNomeVend When .F.        									Size C(250), C(08) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(036), C(290) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED                                                                        

	If MsgYesNo("Deseja continuar com o processamento da troca de vendedores do clientes marcados?","Continuar")
		// Percorrendo os registros da SA1
		SA1->(DbGoTop())
		While !SA1->(EoF())
			// Caso esteja marcado, efetua troca do vendedor
			If oMark:IsMark(cMarca)
				// Grava novo vendedor e limpa a marca
				RecLock("SA1", .F.)
				A1_OKFS := ""
				A1_VEND	:= _cVendedor
				SA1->(MsUnlock())
				nCt ++
			EndIf

			SA1->(DbSkip())
		EndDo

		// Mostrando a mensagem de registros marcados
		MsgInfo('Foram processados <b>' + cValToChar( nCt ) + ' clientes </b>.', "Atenção")
	Else
		MsgAlert("Não foi processado nenhum cliente devido ao cancelamento.")
	Endif	

	RestArea(aArea)

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Consistencia no Vendedor                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VldVen()
	DbSelectArea("SA3")
	DbSeek(xFilial("SA3") + _cVendedor)
	If Found()
		lVal       := .T.
		_cNomeVend := SA3->A3_NOME
	Else
		lVal 	  := .F.
		_cNomeVend := ""
		MsgAlert("Vendedor Inválido. Informe um Vendedor Válido!")
	EndIf

Return
