#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ATUA_000
@Type			: Função de Usuário
@Sample			: U_ATUA_000()
@Description	: Rotina para seleção de integrações a serem processadas através de POST
                  consumidos da Atua Sistemas
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2023
@version		: Protheus 12.1.2210 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function ATUA_000()

	Local aArea := FWGetArea()

	// Rodar somente na empresa 07
	If cEmpAnt <> "07"
		FWAlertWarning("Somente disponível para uso na Transportadora Arrieche", "Rotina Inválida para esta Empresa")
		Return
	Endif

	MsAguarde({|| fMontaTela()}, "Montando Tela de Seleção ...", "Aguarde ...")

	FWRestArea(aArea)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} fMontaTela
Função de montagem da tela para seleção das APIs que serão processadas
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function fMontaTela()

	Local nLargBtn   := 50
	Local nLinhaObj  := 0
	Local nLargPanel := 0

	// Objetos e componentes gerais
	Private oDlgTela
	Private oFwLayer
	Private oPanTitulo
	Private oPanCheck
	Private oPanParam
	Private cMascCgc := "@R 99.999.999/9999-99"
	Private cMascDat := "@D"
	Private cMascCte := "99999999999999999999999999999999999999999999"
	Private aItems	 := {'CTRCs','Motoristas','Proprietários','Veículos','Despesas'}
	Private aAmbCte  := {'1=Produção','2=Homologação'}

	// Cabeçalho
	Private oSayModulo, cSayModulo := "TMS"
	Private oSayTitulo, cSayTitulo := "Integração Atua Sistemas -> Protheus"

	// Fontes
	Private cFontUti  := "Tahoma"
	Private oFontMod  := TFont():New(cFontUti, , -38)
	Private oFontSub  := TFont():New(cFontUti, , -20)
	Private oFontSubN := TFont():New(cFontUti, , -20, , .T.)
	Private oFontBtn  := TFont():New(cFontUti, , -14)
	Private oFontSay  := TFont():New(cFontUti, , -12)

	// Dados do cadastro de empresas
	Private aDadosSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt, {"M0_NOMECOM", ;
																	"M0_ENDENT",  ;
																	"M0_BAIRENT", ;
																	"M0_CEPENT",  ;
																	"M0_CIDENT",  ;
																	"M0_ESTENT",  ;
																	"M0_CGC"	 })

	// Componentes da segunda coluna
	Private oCombo
	Private oAmbie
	Private oSayChkDes
	Private oSayChkCgc
	Private oSayChkDti
	Private oSayChkDtf
	Private oSayChkCId
	Private oSayChkCte
	Private oSayAmbCte
	Private oCheck01, lCheck01 := .F., oGetCgc01, cGetCgc01 := AllTrim(aDadosSM0[7][2]), oGetDti01, cGetDti01 := Ctod(""), oGetDtf01, cGetDtf01 := Ctod(""), oGetCId01, cGetCId01 := Space(10), oGetCte01, cGetCte01 := Space(44)

	// Tamanho da janela
	Private aSizeTela := MsAdvSize(.F.)		 // Se a janela de diálogo possuirá enchoicebar (.T.), senão (.F.)
	Private nJanLarg  := aSizeTela[5]
	Private nJanAltu  := aSizeTela[6] / 2

	// Cria a janela
	DEFINE MSDIALOG oDlgTela TITLE "Integração Atua Sistemas -> Protheus"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL

	// Criando a camada
	oFwLayer := FwLayer():New()
	oFwLayer:Init(oDlgTela,.F.)

	// Adicionando 3 linhas para separar a tela. A do título, a do corpo e a do rodapé
	oFWLayer:addLine("TITULO", 020, .F.)
	oFWLayer:addLine("CORPO",  078, .F.)
	oFWLayer:addLine("RODAPE", 002, .F.)

	// Adicionando as colunas das linhas
	oFWLayer:addCollumn("HEADERTEXT",   070, .T., "TITULO")
	oFWLayer:addCollumn("BTNSAIR",      030, .T., "TITULO")

	oFWLayer:addCollumn("BLANKANTES",   001, .T., "CORPO")
	oFWLayer:addCollumn("COLCHECK",     019, .T., "CORPO")
	oFWLayer:addCollumn("COLPARAM",     079, .T., "CORPO")
	oFWLayer:addCollumn("BLANKDEPOIS",  001, .T., "CORPO")

	// Criando os paineis
	oPanHeader := oFWLayer:GetColPanel("HEADERTEXT", "TITULO")
	oPanSair   := oFWLayer:GetColPanel("BTNSAIR",    "TITULO")
	oPanCheck  := oFWLayer:GetColPanel("COLCHECK",   "CORPO")
	oPanParam  := oFWLayer:GetColPanel("COLPARAM",   "CORPO")

	// Módulo e títulos
	oSayModulo := TSay():New(003, 003, {|| cSayModulo}, oPanHeader, "", oFontMod,  , , , .T., RGB(149, 179, 215), , 200, 30, , , , , , .F., , )
	oSayTitulo := TSay():New(009, 045, {|| cSayTitulo}, oPanHeader, "", oFontSubN,  , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )

	@ 024, 003 GROUP oGrpDad TO (nJanAltu/2), (nJanLarg/2) PROMPT "" OF oDlgTela COLOR 0, 16777215 PIXEL
	oGrpDad:oFont := oFontBtn

	// Cria os componentes da primeira coluna
	@ 001, 001 SCROLLBOX oScroll1 VERTICAL HORIZONTAL SIZE oPanCheck:nHeight -10 / 2, oPanCheck:nWidth -10 / 2 OF oPanCheck

	// Cria os componentes da segunda coluna
	@ 001, 001 SCROLLBOX oScroll2 VERTICAL HORIZONTAL SIZE oPanParam:nHeight / 2, oPanParam:nWidth / 2 OF oPanParam

	nLinhaObj  := 1
	nLargPanel := (oPanCheck:nWidth) / 2
	nTotEspCol := (nLargPanel/1)
	nTotCol01  := 003 + nTotEspCol * 0
	oSayChkDes := TSay():New(nLinhaObj + 025, nTotCol01 + 003, {|| "API a Integrar"}, oScroll1 , "", oFontSub,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 12, , , , , , .F., , )

	nLinhaObj  := 1
	nLargPanel := (oPanParam:nWidth) / 2
	nTotEspCol := (nLargPanel/8)
	nTotCol01  := 003 + nTotEspCol * 0
	nTotCol02  := 003 + nTotEspCol * 1
	nTotCol03  := 003 + nTotEspCol * 2
	nTotCol04  := 003 + nTotEspCol * 3
	nTotCol05  := 003 + nTotEspCol * 4
	nTotCol06  := 003 + nTotEspCol * 6.4
	oSayChkCgc := TSay():New(nLinhaObj + 030, nTotCol01 + 003, {|| "CNPJ"},        	oScroll2, "", oFontSay,  , , , .T., RGB(255, 000, 000), , nTotEspCol, 10, , , , , , .F., , )
	oSayChkDti := TSay():New(nLinhaObj + 030, nTotCol02 + 003, {|| "Data Inicial"},	oScroll2, "", oFontSay,  , , , .T., RGB(255, 000, 000), , nTotEspCol, 10, , , , , , .F., , )
	oSayChkDtf := TSay():New(nLinhaObj + 030, nTotCol03 + 003, {|| "Data Final"},	oScroll2, "", oFontSay,  , , , .T., RGB(255, 000, 000), , nTotEspCol, 10, , , , , , .F., , )
	oSayChkCId := TSay():New(nLinhaObj + 030, nTotCol04 + 003, {|| "Código Id"},    oScroll2, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
	oSayChkCte := TSay():New(nLinhaObj + 030, nTotCol05 + 003, {|| "Chave CT-e"},   oScroll2, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
	oSayAmbCte := TSay():New(nLinhaObj + 030, nTotCol06 + 003, {|| "Ambiente CT-e"},oScroll2, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )

	nLinhaObj += 15

	cCombo := aItems[1]
	oCombo := TComboBox():New(nLinhaObj + 025, nTotCol01 + 003,{|u| Iif(PCount() > 0,  cCombo := u, cCombo)}, aItems, nTotEspCol + 30, 14, oScroll1, , /*bValid*/,,,,.T.,oFontBtn,,,,,,,,'cCombo')

	oGetCgc01 := TGet():New(nLinhaObj + 025, nTotCol01 + 003, {|u| Iif(PCount() > 0 , cGetCgc01 := u, cGetCgc01)}, oScroll2, nTotEspCol - 09, 10, cMascCgc, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)
	oGetCgc01:lActive := .F.
	oGetDti01 := TGet():New(nLinhaObj + 025, nTotCol02 + 003, {|u| Iif(PCount() > 0 , cGetDti01 := u, cGetDti01)}, oScroll2, nTotEspCol - 09, 10, cMascDat, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)
	oGetDti01:lActive := .T.
	oGetDtf01 := TGet():New(nLinhaObj + 025, nTotCol03 + 003, {|u| Iif(PCount() > 0 , cGetDtf01 := u, cGetDtf01)}, oScroll2, nTotEspCol - 09, 10, cMascDat, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)
	oGetDtf01:lActive := .T.
	oGetCId01 := TGet():New(nLinhaObj + 025, nTotCol04 + 003, {|u| Iif(PCount() > 0 , cGetCId01 := u, cGetCId01)}, oScroll2, nTotEspCol - 09, 10, cMascDat, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)
	oGetCId01:lActive := .T.
	oGetCte01 := TGet():New(nLinhaObj + 025, nTotCol05 + 003, {|u| Iif(PCount() > 0 , cGetCte01 := u, cGetCte01)}, oScroll2, nTotEspCol + 89, 10, cMascCte, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)
	oGetCte01:lActive := .T.

	cAmbie := aAmbCte[1]
	oAmbie := TComboBox():New(nLinhaObj + 025, nTotCol06 + 003,{|u| Iif(PCount() > 0,  cAmbie := u, cAmbie)}, aAmbCte, nTotEspCol + 15, 12, oScroll2, , /*bValid*/,,,,.T.,oFontBtn,,,,,,,,'cAmbie')

	// Criando os botões
	nLargBot := (oPanSair:nWidth) / 2
	nColBot1 := nLargBot - 120
	nColBot2 := nLargBot - 060
	oBtnProc := TButton():New(005, nColBot1 - 10, "Importar", oPanSair, {|| _Importar(cCombo,cAmbie)}, nLargBtn, 018, , oFontBtn, , .T., , , , , , )
	oBtnProc:SetCSS(GetCSS("TBUTTON_01"))
	oBtnSair := TButton():New(005, nColBot2 - 10, "Fechar",   oPanSair, {|| oDlgTela:End()}	 , nLargBtn, 018, , oFontBtn, , .T., , , , , , )
	oBtnSair:SetCSS(GetCSS("TBUTTON_02"))

	Activate MsDialog oDlgTela Centered

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} GetCss
Função que retorno o CSS
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function GetCSS(cClass)

	Local cCSS := '' as character
	
	Default cClass := ''

	If cClass == 'TBUTTON_01'
		cCSS += "QPushButton { color: white }"
		cCSS += "QPushButton { font-weight: bolder }"
		cCSS += "QPushButton { border: 2px solid #CECECE }"
		cCSS += "QPushButton { background-color: #008000 }"
		cCSS += "QPushButton { border-radius: 8px }"
		cCSS += "QPushButton:hover { background-color: #008000 } "
		cCSS += "QPushButton:hover { border-style: solid } "
		cCSS += "QPushButton:hover { border-width: 4px }"
		cCSS += "QPushButton:pressed { background-color: #008000 }"
		cCSS += "QPushButton:focus { background-color: #008000 } "
		cCSS += "QPushButton:focus { border-style: solid } "
		cCSS += "QPushButton:focus { border-width: 8px }"
	ElseIf cClass == 'TBUTTON_02'
		cCSS += "QPushButton { color: white }"
		cCSS += "QPushButton { font-weight: bolder }"
		cCSS += "QPushButton { border: 2px solid #CECECE }"
		cCSS += "QPushButton { background-color: #FF0000 }"
		cCSS += "QPushButton { border-radius: 8px }"
		cCSS += "QPushButton:hover { background-color: #FF0000 } "
		cCSS += "QPushButton:hover { border-style: solid } "
		cCSS += "QPushButton:hover { border-width: 4px }"
		cCSS += "QPushButton:pressed { background-color: #FF0000 }"
		cCSS += "QPushButton:focus { background-color: #FF0000 } "
		cCSS += "QPushButton:focus { border-style: solid } "
		cCSS += "QPushButton:focus { border-width: 8px }"
	Endif

Return(cCSS)


//-----------------------------------------------------------------------
/*/{Protheus.doc} _Importar
Função que efetua a importação dos dados ref. ao tComboBox selecionado
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _Importar(cCombo,cAmbie)

	_lContinua := _VldParam(cCombo)

	If _lContinua

		If cCombo == "Motoristas"
			MsAguarde({|| U_ATUA_001(cGetCgc01,cGetDti01,cGetDtf01,cGetCId01)},"Aguarde","Processando Motoristas da Atua Sistemas ...")
		EndIf	
		If cCombo == "Proprietários"
			MsgAlert("Reservado para importação futura. Verificar com suporte.")
			//MsAguarde({|| U_ATUA_002(cGetCgc01,cGetDti01,cGetDtf01)},"Aguarde","Processando Proprietários da Atua Sistemas ...")
		EndIf	
		If cCombo == "Veículos"
			MsAguarde({|| U_ATUA_003(cGetCgc01,cGetDti01,cGetDtf01,cGetCId01)},"Aguarde","Processando Veículos da Atua Sistemas ...")
		EndIf	
		If cCombo == "CTRCs"
			MsAguarde({|| U_ATUA_004(cGetCgc01,cGetDti01,cGetDtf01,cGetCId01,cGetCte01,Left(cAmbie,1))},"Aguarde","Processando CTRCs da Atua Sistemas ...")
		EndIf	
		If cCombo == "Despesas"
			MsAguarde({|| U_ATUA_005(cGetCgc01,cGetDti01,cGetDtf01,cGetCId01)},"Aguarde","Processando Contas a Pagar da Atua Sistemas ...")
			MsAguarde({|| U_ATUA_006(cGetCgc01,cGetDti01,cGetDtf01,cGetCId01)},"Aguarde","Processando Despesas da Atua Sistemas ...")
		EndIf	

		oDlgTela:End()
		U_ATUA_000()
	Else
		MsgAlert("AJUSTE PARÂMETROS E PROCESSE NOVAMENTE")
	EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _VldParam
Função que efetua a validação de todos parâmetros
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _VldParam(cCombo)

	_lRet := .T.

	If cCombo == "Motoristas"
		If Empty(cGetDti01) .Or. Empty(cGetDtf01)
			MsgAlert("Data Inicial ou Data Final estão em branco e são campos OBRIGATÓRIOS. Informe as datas!")
			_lRet := .F.
		EndIf
		If cGetDti01 > cGetDtf01
			MsgAlert("Data Inicial não pode ser MAIOR que Data Final. Ajuste as datas!")
			_lRet := .F.
		EndIf
	EndIf

	If cCombo == "Proprietários"
		If Empty(cGetDti01) .Or. Empty(cGetDtf01)
			MsgAlert("Data Inicial ou Data Final estão em branco e são campos OBRIGATÓRIOS. Informe as datas!")
			_lRet := .F.
		EndIf
		If cGetDti01 > cGetDtf01
			MsgAlert("Data Inicial não pode ser MAIOR que Data Final. Ajuste as datas!")
			_lRet := .F.
		EndIf
	EndIf

	If cCombo == "Veículos"
		If Empty(cGetDti01) .Or. Empty(cGetDtf01)
			MsgAlert("Data Inicial ou Data Final estão em branco e são campos OBRIGATÓRIOS. Informe as datas!")
			_lRet := .F.
		EndIf
		If cGetDti01 > cGetDtf01
			MsgAlert("Data Inicial não pode ser MAIOR que Data Final. Ajuste as datas!")
			_lRet := .F.
		EndIf
	EndIf

	If cCombo == "CTRCs"
		If Empty(cGetDti01) .Or. Empty(cGetDtf01)
			MsgAlert("Data Inicial ou Data Final estão em branco e são campos OBRIGATÓRIOS. Informe as datas!")
			_lRet := .F.
		EndIf
		If cGetDti01 > cGetDtf01
			MsgAlert("Data Inicial não pode ser MAIOR que Data Final. Ajuste as datas!")
			_lRet := .F.
		EndIf
		If !Empty(cGetCId01) .And. !Empty(cGetCte01)
			MsgAlert("Não é permitido informar Código Id e Chave Ct-e para ComboBox CTRCs. Informe apenas um dos campos!")
			_lRet := .F.
		EndIf
	EndIf

	If cCombo == "Despesas"
		If Empty(cGetDti01) .Or. Empty(cGetDtf01)
			MsgAlert("Data Inicial ou Data Final estão em branco e são campos OBRIGATÓRIOS. Informe as datas!")
			_lRet := .F.
		EndIf
		If cGetDti01 > cGetDtf01
			MsgAlert("Data Inicial não pode ser MAIOR que Data Final. Ajuste as datas!")
			_lRet := .F.
		EndIf
	EndIf

Return(_lRet)
