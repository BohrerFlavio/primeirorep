#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//Variáveis Estáticas
Static cTitulo := "Manutenção de Romaneios de Embarque de Gado"

/*/{Protheus.doc} STI_RG01
Função para cadastro e manutenção de romaneios de embarque de gado - Modelo 1 em MVC
@author 	Evandro Mugnol
@since 		Set/2017
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas.
/*/

User Function STI_RG01()

	Local aArea := GetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias("ZAQ")

	// Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	// Legendas
	oBrowse:AddLegend( "ZAQ->ZAQ_STATUS == 'A'", "GREEN",	"Autorizado" )
	oBrowse:AddLegend( "ZAQ->ZAQ_STATUS == 'B'", "RED"	,	"Bloqueado" )

	// Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil

/*====================================================================*
| Função:  		MenuDef                                               |
| Descrição:	Criação do menu MVC                                   |
*====================================================================*/
Static Function MenuDef()

	Local aRotina := {}

	// Adicionando opções
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw" 			 OPERATION 0                   	 ACCESS 0 // OPERATION 1
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.STI_RG01" OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 // OPERATION 2
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.STI_RG01" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERATION 3
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.STI_RG01" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERATION 4
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.STI_RG01" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERATION 5
	ADD OPTION aRotina TITLE "Legenda"    ACTION "U_RG01Leg" 	    OPERATION 6                      ACCESS 0 // OPERATION X

Return aRotina

/*====================================================================*
| Função:  		ModelDef                                              |
| Descrição:	Criação do modelo de dados MVC                        |
*====================================================================*/
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_RG01Pre()} 	// Função chamada antes de abrir a tela
	Local bPos 	  	:= {|| U_RG01Pos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_RG01Com()} 	// Função chamada no commit
	//Local bCancel := {|| U_RG01Can()} 	// Função chamada ao cancelar

	// Criação do objeto do modelo de dados
	Local oModel := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStZAQ := FWFormStruct(1, "ZAQ")

	// Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("STIRG01M",/*bPre*/, bPos,/*bCommit*/,/*bCancel*/)

	// Atribuindo formulários para o modelo
	oModel:AddFields("FORMZAQ",/*cOwner*/,oStZAQ)

	// Setando a chave primária da rotina
	oModel:SetPrimaryKey({"ZAQ_FILIAL","ZAQ_NUM"})

	// Adicionando descrição ao modelo
	oModel:SetDescription("Modelo de Dados do Cadastro " + cTitulo)

	// Setando a descrição do formulário
	oModel:GetModel("FORMZAQ"):SetDescription("Formulário do Cadastro " + cTitulo)

Return oModel


/*====================================================================*
| Função:  		ViewDef                                               |
| Descrição:	Criação da visão MVC                                  |
*====================================================================*/
Static Function ViewDef()

	// Criação do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("STI_RG01")

	// Criação da estrutura de dados utilizada na interface do cadastro
	Local oStZAQ := FWFormStruct(2, "ZAQ")  // pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'XXX_NOME|XXX_DATAI|'}

	// Criando oView como nulo
	Local oView := Nil

	// Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Atribuindo formulários para interface
	oView:AddField("VIEW_ZAQ", oStZAQ, "FORMZAQ")

	// Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	// Colocando título do formulário
	//oView:EnableTitleView('VIEW_ZAQ', 'Dados da Manutenção de Romaneios de Embarque de Gado' )

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZAQ","TELA")

Return oView

/*/{Protheus.doc} RG01Leg
Função para mostrar a legenda da rotina em MVC
@author 	Evandro Mugnol
@since 		Set/2017
/*/

User Function RG01Leg()

	Local aLegenda := {}

	// Monta as cores
	AADD(aLegenda,{"BR_VERDE",		"Autorizado" })
	AADD(aLegenda,{"BR_VERMELHO",	"Bloqueado"	})

	BrwLegenda("Manutenção de Romaneios de Embarque de Gado", "Legenda", aLegenda)

Return

/*/{Protheus.doc} RG01Pos
Função chamada no clique do botão Ok do Modelo de Dados (pós-validação)
@author		Evandro Mugnol
@since		Out/2017
/*/

User Function RG01Pos()

	Local lRet       := .T.
	Local oModel  	 := FWModelActive()
	Local nOperation := oModel:GetOperation()
	Local cCampo     := oModel:GetValue("FORMZAQ", "ZAQ_CNPJ")

	Local cNUMSC	 := oModel:GetValue("FORMZAQ", "ZAQ_NUMSC")
	Local dDATAEM    := oModel:GetValue("FORMZAQ", "ZAQ_DATAEM")
	// Boi
	Local cNGITSC    := oModel:GetValue("FORMZAQ", "ZAQ_NGITSC")
	Local cNGPROD    := "000230"
	Local nNGQTD     := oModel:GetValue("FORMZAQ", "ZAQ_NGQTD")
	Local nNGPRC     := oModel:GetValue("FORMZAQ", "ZAQ_NGPRC")
	Local nNGPRCB    := oModel:GetValue("FORMZAQ", "ZAQ_NGPRCB")
	Local nNGPES     := oModel:GetValue("FORMZAQ", "ZAQ_NGPES")
	Local cNGProg    := oModel:GetValue("FORMZAQ", "ZAQ_NGPROG")
	// Vaca
	Local cVGITSC    := oModel:GetValue("FORMZAQ", "ZAQ_VGITSC")
	Local cVGPROD    := "000231"
	Local nVGQTD     := oModel:GetValue("FORMZAQ", "ZAQ_VGQTD")
	Local nVGPRC     := oModel:GetValue("FORMZAQ", "ZAQ_VGPRC")
	Local nVGPRCB    := oModel:GetValue("FORMZAQ", "ZAQ_VGPRCB")
	Local nVGPES     := oModel:GetValue("FORMZAQ", "ZAQ_VGPES")
	Local cVGProg    := oModel:GetValue("FORMZAQ", "ZAQ_VGPROG")
	// Touro
	Local cTGITSC    := oModel:GetValue("FORMZAQ", "ZAQ_TGITSC")
	Local cTGPROD    := "001075"
	Local nTGQTD     := oModel:GetValue("FORMZAQ", "ZAQ_TGQTD")
	Local nTGPRC     := oModel:GetValue("FORMZAQ", "ZAQ_TGPRC")
	Local nTGPRCB    := oModel:GetValue("FORMZAQ", "ZAQ_TGPRCB")
	Local nTGPES     := oModel:GetValue("FORMZAQ", "ZAQ_TGPES")
	Local cTGProg    := oModel:GetValue("FORMZAQ", "ZAQ_TGPROG")
	// Búfalo
	Local cBGITSC    := oModel:GetValue("FORMZAQ", "ZAQ_BGITSC")
	Local cBGPROD    := "001073"
	Local nBGQTD     := oModel:GetValue("FORMZAQ", "ZAQ_BGQTD")
	Local nBGPRC     := oModel:GetValue("FORMZAQ", "ZAQ_BGPRC")
	Local nBGPRCB    := oModel:GetValue("FORMZAQ", "ZAQ_BGPRCB")
	Local nBGPES     := oModel:GetValue("FORMZAQ", "ZAQ_BGPES")
	Local cBGProg    := oModel:GetValue("FORMZAQ", "ZAQ_BGPROG")
	// Búfala
	Local cBAITSC    := oModel:GetValue("FORMZAQ", "ZAQ_BAITSC")
	Local cBAPROD    := "001074"
	Local nBAQTD     := oModel:GetValue("FORMZAQ", "ZAQ_BAQTD")
	Local nBAPRC     := oModel:GetValue("FORMZAQ", "ZAQ_BAPRC")
	Local nBAPRCB    := oModel:GetValue("FORMZAQ", "ZAQ_BAPRCB")
	Local nBAPES     := oModel:GetValue("FORMZAQ", "ZAQ_BAPES")
	Local cBAProg    := oModel:GetValue("FORMZAQ", "ZAQ_BAPROG")

	//campos pro consumo do WS do APP
	Local cStatus 	 := oModel:GetValue("FORMZAQ", "ZAQ_STATUS")
	Local cNumRom  	 := oModel:GetValue("FORMZAQ", "ZAQ_NUM")
	Local cDTADIA    := oModel:GetValue("FORMZAQ", "ZAQ_DTADIA")
	Local nPrazo     := oModel:GetValue("FORMZAQ", "ZAQ_PRAZO")
	Local cCodBanco  := oModel:GetValue("FORMZAQ", "ZAQ_CDBCOD")
	Local cAgencia   := oModel:GetValue("FORMZAQ", "ZAQ_AGENC")
	Local cConta     := oModel:GetValue("FORMZAQ", "ZAQ_CC")
	Local cNomeDest  := oModel:GetValue("FORMZAQ", "ZAQ_NOMEDE")
	Local cCGCDest   := oModel:GetValue("FORMZAQ", "ZAQ_CGCDEP")
	Local cCarcaca   := oModel:GetValue("FORMZAQ", "ZAQ_TPCOM")

	//novilho Cruza Leite
	Local nNGQMES    := oModel:GetValue("FORMZAQ", "ZAQ_NGQMES") //quantidade
	Local nNGPMES    := oModel:GetValue("FORMZAQ", "ZAQ_NGPMES") //preco

	//Touruno Novilho
	Local nNGQTOU    := oModel:GetValue("FORMZAQ", "ZAQ_NGQTOU") //quantidade
	Local nNGPTOU    := oModel:GetValue("FORMZAQ", "ZAQ_NGPTOU") //preco

	//Vaca Cruza Leite
	Local nVGQMES    := oModel:GetValue("FORMZAQ", "ZAQ_VGQMES") //quantidade
	Local nVGPMES    := oModel:GetValue("FORMZAQ", "ZAQ_VGPMES") //preco

	Local aAnimais   := {}
	Local aRet       := {}

	_cCNPJ  := PADR(AllTrim(StrTran(StrTran(StrTran(StrTran(AllTrim(oModel:GetValue("FORMZAQ", "ZAQ_CNPJ")) ,"/",""),".",""),"-","")," ","")), TamSX3("A2_CGC")[1], " ")
	_cINSCR := PADR(AllTrim(StrTran(StrTran(StrTran(StrTran(AllTrim(oModel:GetValue("FORMZAQ", "ZAQ_INSCR")),"/",""),".",""),"-","")," ","")), TamSX3("A2_INSCR")[1], " ")
	
	DbSelectArea("SA2")
	DbOrderNickName("CNPJINSCR")
	DbSeek(xFilial("SA2") + _cCNPJ + _cINSCR)
	If Found()
		_cCodiFor := SA2->A2_COD
		_cLojaFor := SA2->A2_LOJA
		_cNomeFor := SA2->A2_NOME
	Else
		_cCodiFor := ""
		_cLojaFor := ""
		_cNomeFor := ""
	Endif

	// Valida o CPF ou CNPJ que está informado
	cCampo := AllTrim(StrTran(StrTran(StrTran(StrTran(AllTrim(cCampo),"/",""),".",""),"-","")," ",""))

	If !Empty(cCampo)
		If CGC(cCampo)
			If Len(cCampo) == 11 .Or. Len(cCampo) == 14    // CPF ou CNPJ
				lRet := .T.
			Else
				lRet := .F.
				Aviso("Atenção", "CPF/CNPJ inválido!", {"OK"}, 2)
			EndIf
		Else
			lRet := .F.
			Aviso("Atenção", "CPF/CNPJ com dígito verificador incorreto!", {"OK"}, 2)
		EndIf
	Else
		lRet := .F.
		Aviso("Atenção", "Campo CPF/CNPJ está em branco!", {"OK"}, 2)
	EndIf

	// Inclui novo item a solicitação de compra caso alguma categoria tenha sido adicionada ao romaneio. SOMENTE NA ALTERAÇÃO DO ROMANEIO
	// Considera se já existe ZAQ_NUMSC gerada e campo ZAQ_??ITEM em branco
	If nOperation == MODEL_OPERATION_UPDATE .And. lRet
		lVinc := .F.

		/*Lista de categorias
		001 - Novilhos Gordos
		002 - Vacas Gordas
		003 - Touros Gordos
		004 - Búfalos Gordos
		005 - Búfalas Gordas
		006 - Cruza Leite Novilho
		007 - Touruno Novilho
		008 - Vaca Cruza Leite
		*/
																	//czleite	 ||	  touruno
		aAdd(aAnimais,{'001',nNGQTD,nNGPRC,nNGPRCB,nNGPES,cNGProg,nNGQMES,nNGPMES,nNGQTOU,nNGPTOU})
																	//czleite
		aAdd(aAnimais,{'002',nVGQTD,nVGPRC,nVGPRCB,nVGPES,cVGProg,nVGQMES,nVGPMES,0,0})
		aAdd(aAnimais,{'003',nTGQTD,nTGPRC,nTGPRCB,nTGPES,cTGProg,0,0,0,0})
		aAdd(aAnimais,{'004',nBGQTD,nBGPRC,nBGPRCB,nBGPES,cBGProg,0,0,0,0})
		aAdd(aAnimais,{'005',nBAQTD,nBAPRC,nBAPRCB,nBAPES,cBAProg,0,0,0,0})

		aAdd(aRet,aAnimais)

		//chamada de função para webservice
		u_consLibRom(cNumRom,cStatus,cDTADIA,dDATAEM,nPrazo,cCodBanco,cAgencia,cConta,cNomeDest,cCGCDest,aAnimais,1,cCarcaca)

		// Boi
		If !Empty(cNUMSC) .And. Empty(cNGITSC) .And. nNGQTD > 0
			DbSelectArea("SZ5")
			_cCateg := fBuscaCPO("SZ5", 3, xFilial("SZ5") + cNGPROD, "Z5_COD")

			DbSelectArea("SZ9")
			RecLock("SZ9",.T.)
			SZ9->Z9_FILIAL  := xFilial("SZ9")
			SZ9->Z9_NUMERO  := cNUMSC
			SZ9->Z9_ITEM    := Soma1(_UltITE(cNUMSC))
			SZ9->Z9_RASTRO  := "N"
			SZ9->Z9_PRODUTO := cNGPROD
			SZ9->Z9_UM      := "CB"
			SZ9->Z9_QUANT   := nNGQTD
			SZ9->Z9_PRECO   := nNGPRC
			SZ9->Z9_PESO    := nNGPES
			SZ9->Z9_FORNECE := _cCodiFor
			SZ9->Z9_LOJA    := _cLojaFor
			SZ9->Z9_NOMFOR  := _cNomeFor
			SZ9->Z9_DATA    := dDATAEM + 1			// Sempre 1 dia posterior a data de embarque do romaneio conforme passado por Leonardo
			SZ9->Z9_QTDENT  := nNGQTD				// Atualiza quantidade entregue, pois já foi acrescentado o item ref. essa categoria na ordem de recebimento
			SZ9->Z9_PRECOBN := nNGPRCB
			SZ9->Z9_CATEG   := _cCateg
			MsUnlock()

			oModel:SetValue("FORMZAQ", "ZAQ_NGITSC", SZ9->Z9_ITEM)		// Grava item da solicitação de compra gerada no romaneio
			lVinc := .T.
		Endif

		// Vaca
		If !Empty(cNUMSC) .And. Empty(cVGITSC) .And. nVGQTD > 0
			DbSelectArea("SZ5")
			_cCateg := fBuscaCPO("SZ5", 3, xFilial("SZ5") + cVGPROD, "Z5_COD")

			DbSelectArea("SZ9")
			RecLock("SZ9",.T.)
			SZ9->Z9_FILIAL  := xFilial("SZ9")
			SZ9->Z9_NUMERO  := cNUMSC
			SZ9->Z9_ITEM    := Soma1(_UltITE(cNUMSC))
			SZ9->Z9_RASTRO  := "N"
			SZ9->Z9_PRODUTO := cVGPROD
			SZ9->Z9_UM      := "CB"
			SZ9->Z9_QUANT 	:= nVGQTD
			SZ9->Z9_PRECO   := nVGPRC
			SZ9->Z9_PESO  	:= nVGPES
			SZ9->Z9_FORNECE := _cCodiFor
			SZ9->Z9_LOJA    := _cLojaFor
			SZ9->Z9_NOMFOR  := _cNomeFor
			SZ9->Z9_DATA    := dDATAEM + 1			// Sempre 1 dia posterior a data de embarque do romaneio conforme passado por Leonardo
			SZ9->Z9_QTDENT  := nVGQTD				// Atualiza quantidade entregue, pois já foi acrescentado o item ref. essa categoria na ordem de recebimento
			SZ9->Z9_PRECOBN := nVGPRCB
			SZ9->Z9_CATEG   := _cCateg
			MsUnlock()

			oModel:SetValue("FORMZAQ", "ZAQ_VGITSC", SZ9->Z9_ITEM)		// Grava item da solicitação de compra gerada no romaneio
			lVinc := .T.
		Endif

		// Touro
		If !Empty(cNUMSC) .And. Empty(cTGITSC) .And. nTGQTD > 0
			DbSelectArea("SZ5")
			_cCateg := fBuscaCPO("SZ5", 3, xFilial("SZ5") + cTGPROD, "Z5_COD")

			DbSelectArea("SZ9")
			RecLock("SZ9",.T.)
			SZ9->Z9_FILIAL  := xFilial("SZ9")
			SZ9->Z9_NUMERO  := cNUMSC
			SZ9->Z9_ITEM    := Soma1(_UltITE(cNUMSC))
			SZ9->Z9_RASTRO  := "N"
			SZ9->Z9_PRODUTO := cTGPROD
			SZ9->Z9_UM      := "CB"
			SZ9->Z9_QUANT 	:= nTGQTD
			SZ9->Z9_PRECO   := nTGPRC
			SZ9->Z9_PESO  	:= nTGPES
			SZ9->Z9_FORNECE := _cCodiFor
			SZ9->Z9_LOJA    := _cLojaFor
			SZ9->Z9_NOMFOR  := _cNomeFor
			SZ9->Z9_DATA    := dDATAEM + 1			// Sempre 1 dia posterior a data de embarque do romaneio conforme passado por Leonardo
			SZ9->Z9_QTDENT  := nTGQTD				// Atualiza quantidade entregue, pois já foi acrescentado o item ref. essa categoria na ordem de recebimento
			SZ9->Z9_PRECOBN := nTGPRCB
			SZ9->Z9_CATEG   := _cCateg
			MsUnlock()

			oModel:SetValue("FORMZAQ", "ZAQ_TGITSC", SZ9->Z9_ITEM)		// Grava item da solicitação de compra gerada no romaneio
			lVinc := .T.
		Endif

		// Búfalo
		If !Empty(cNUMSC) .And. Empty(cBGITSC) .And. nBGQTD > 0
			DbSelectArea("SZ5")
			_cCateg := fBuscaCPO("SZ5", 3, xFilial("SZ5") + cBGPROD, "Z5_COD")

			DbSelectArea("SZ9")
			RecLock("SZ9",.T.)
			SZ9->Z9_FILIAL  := xFilial("SZ9")
			SZ9->Z9_NUMERO  := cNUMSC
			SZ9->Z9_ITEM    := Soma1(_UltITE(cNUMSC))
			SZ9->Z9_RASTRO  := "N"
			SZ9->Z9_PRODUTO := cBGPROD
			SZ9->Z9_UM      := "CB"
			SZ9->Z9_QUANT 	:= nBGQTD
			SZ9->Z9_PRECO   := nBGPRC
			SZ9->Z9_PESO  	:= nBGPES
			SZ9->Z9_FORNECE := _cCodiFor
			SZ9->Z9_LOJA    := _cLojaFor
			SZ9->Z9_NOMFOR  := _cNomeFor
			SZ9->Z9_DATA    := dDATAEM + 1			// Sempre 1 dia posterior a data de embarque do romaneio conforme passado por Leonardo
			SZ9->Z9_QTDENT  := nBGQTD				// Atualiza quantidade entregue, pois já foi acrescentado o item ref. essa categoria na ordem de recebimento
			SZ9->Z9_PRECOBN := nBGPRCB
			SZ9->Z9_CATEG   := _cCateg
			MsUnlock()

			oModel:SetValue("FORMZAQ", "ZAQ_BGITSC", SZ9->Z9_ITEM)		// Grava item da solicitação de compra gerada no romaneio
			lVinc := .T.
		Endif

		// Búfala
		If !Empty(cNUMSC) .And. Empty(cBAITSC) .And. nBAQTD > 0
			DbSelectArea("SZ5")
			_cCateg := fBuscaCPO("SZ5", 3, xFilial("SZ5") + cBAPROD, "Z5_COD")

			DbSelectArea("SZ9")
			RecLock("SZ9",.T.)
			SZ9->Z9_FILIAL  := xFilial("SZ9")
			SZ9->Z9_NUMERO  := cNUMSC
			SZ9->Z9_ITEM    := Soma1(_UltITE(cNUMSC))
			SZ9->Z9_RASTRO  := "N"
			SZ9->Z9_PRODUTO := cBAPROD
			SZ9->Z9_UM      := "CB"
			SZ9->Z9_QUANT 	:= nBAQTD
			SZ9->Z9_PRECO   := nBAPRC
			SZ9->Z9_PESO  	:= nBAPES
			SZ9->Z9_FORNECE := _cCodiFor
			SZ9->Z9_LOJA    := _cLojaFor
			SZ9->Z9_NOMFOR  := _cNomeFor
			SZ9->Z9_DATA    := dDATAEM + 1			// Sempre 1 dia posterior a data de embarque do romaneio conforme passado por Leonardo
			SZ9->Z9_QTDENT  := nBAQTD				// Atualiza quantidade entregue, pois já foi acrescentado o item ref. essa categoria na ordem de recebimento
			SZ9->Z9_PRECOBN := nBAPRCB
			SZ9->Z9_CATEG   := _cCateg
			MsUnlock()

			oModel:SetValue("FORMZAQ", "ZAQ_BAITSC", SZ9->Z9_ITEM)		// Grava item da solicitação de compra gerada no romaneio
			lVinc := .T.
		Endif

		// Atualiza cabeçalho da solicitação de compra
		_nQtde  := 0
		_nValor := 0
		DbSelectArea("SZ9")
		SZ9->(DbSetOrder(1)) 	// Z9_FILIAL + Z9_NUMERO + Z9_ITEM
		If SZ9->(DbSeek(xFilial("SZ9") + cNUMSC))
			While SZ9->(!Eof()) .And. SZ9->Z9_FILIAL + SZ9->Z9_NUMERO == xFilial("SZ9") + cNUMSC
				cTipCom := fBuscaCpo("SZA", 1, xFilial("SZA") + cNUMSC, "ZA_TPCOM")
				_nQtde += SZ9->Z9_QUANT

				If cTipCom == "R"
					_nRend  := Posicione("SZ5", 1, xFilial("SZ5") + SZ9->Z9_CATEG, "Z5_REND")
					_nRend  := If(Empty(_nRend),100, _nRend) 			// Caso a categoria não tenha sido definida
					_nValor += (SZ9->Z9_QUANT * SZ9->Z9_PRECO) * (SZ9->Z9_PESO * (_nRend / 100))
				Else
					_nValor += SZ9->Z9_QUANT * SZ9->Z9_PRECO * SZ9->Z9_PESO
				Endif

				SZ9->(DbSkip())
			EndDo
		EndIf

		DbSelectArea("SZA")
		SZA->(DbSetOrder(1)) 	// Z9_FILIAL + Z9_NUMERO + Z9_ITEM
		If SZA->(DbSeek(xFilial("SZA") + cNUMSC))
			RecLock("SZA",.F.)
			SZA->ZA_TOTALQT := _nQtde
			SZA->ZA_VALTOT  := _nValor
			MsUnlock()
		Endif

		If lVinc
			MsgAlert("É necessário vincular a nova categoria que foi incluída e gerada na SC, à Ordem de Recebimento.")
		Endif
		
	elseif nOperation == MODEL_OPERATION_DELETE .And. lRet
		/*Lista de categorias
		001 - Novilhos Gordos
		002 - Vacas Gordas
		003 - Touros Gordos
		004 - Búfalos Gordos
		005 - Búfalas Gordas
		006 - Cruza Leite Novilho
		007 - Touruno Novilho
		008 - Vaca Cruza Leite
		*/
																	//czleite	 ||	  touruno
		aAdd(aAnimais,{'001',nNGQTD,nNGPRC,nNGPRCB,nNGPES,cNGProg,nNGQMES,nNGPMES,nNGQTOU,nNGPTOU})
																	//czleite
		aAdd(aAnimais,{'002',nVGQTD,nVGPRC,nVGPRCB,nVGPES,cVGProg,nVGQMES,nVGPMES,0,0})
		aAdd(aAnimais,{'003',nTGQTD,nTGPRC,nTGPRCB,nTGPES,cTGProg,0,0,0,0})
		aAdd(aAnimais,{'004',nBGQTD,nBGPRC,nBGPRCB,nBGPES,cBGProg,0,0,0,0})
		aAdd(aAnimais,{'005',nBAQTD,nBAPRC,nBAPRCB,nBAPES,cBAProg,0,0,0,0})

		aAdd(aRet,aAnimais)

		//chamada de função para webservice
		u_consLibRom(cNumRom,cStatus,cDTADIA,dDATAEM,nPrazo,cCodBanco,cAgencia,cConta,cNomeDest,cCGCDest,aAnimais,2,cCarcaca)
	Endif

Return lRet

/*/{Protheus.doc} UltITE
Função busca o maior item na solicitação de compra de gado
@author		Evandro Mugnol
@since		Out/2017
/*/

Static Function _UltITE(_cNUMSC)

	//Local _Num := 0

	cQuery := "SELECT MAX(Z9_ITEM) MAXITEM"
	cQuery += "  FROM " + RetSQLTab("SZ9")
	cQuery += " WHERE " + RetSQLFil("SZ9")
	cQuery += "   AND Z9_NUMERO = '" + _cNUMSC + "'"
	cQuery += "   AND " + RetSQLDel("SZ9")

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBMAX",.T.,.T.)

	TRBMAX->(dbGoTop())

	_MaxItem := TRBMAX->MAXITEM

	TRBMAX->(DbCloseArea())

Return(_MaxItem)
