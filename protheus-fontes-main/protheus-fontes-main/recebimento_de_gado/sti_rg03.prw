#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//Variáveis Estáticas
Static cTitulo := "Solicitação de Compra de Gado"

/*/{Protheus.doc} STI_RG03
Função para cadastro e manutenção das solicitações de compra de gado - Cabeçalho (SZA) e Itens (SZ9) - Modelo 3 em MVC
@author 	Evandro Mugnol
@since 		Set/2017
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas
/*/

User Function STI_RG03()

	Local aArea := GetArea()
	Local oBrowse

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SZA")

	// Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	// Legendas
	oBrowse:AddLegend("U_STATLeg(SZA->ZA_NUMERO) = 1 ", "RED",		"Solicitação Incompleta")
	oBrowse:AddLegend("U_STATLeg(SZA->ZA_NUMERO) = 2 ", "YELLOW",	"Solicitação Completa")
	oBrowse:AddLegend("U_STATLeg(SZA->ZA_NUMERO) = 3 ", "GREEN",	"Solicitação Atendida")

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
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"   		 OPERATION 1                   	 ACCESS 0 // OPERATION 1
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.STI_RG03" OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 // OPERATION 2
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.STI_RG03" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERATION 3
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.STI_RG03" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERATION 4
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.STI_RG03" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERATION 5
	ADD OPTION aRotina TITLE "Legenda"    ACTION "U_RG03Leg" 	    OPERATION 6                      ACCESS 0 // OPERATION X

Return aRotina


/*====================================================================*
| Função:  		ModelDef                                              |
| Descrição:	Criação do modelo de dados MVC                        |
*====================================================================*/
Static Function ModelDef()

	Local oModel   := Nil
	Local oStPai   := FWFormStruct(1, "SZA", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStFilho := FWFormStruct(1, "SZ9", /*bAvalCampo*/, /*lViewUsado*/)
	Local aSZ9Rel  := {}
	Local bCommit  := { |oModel| U_RG03Grv( oModel ) }

	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("STIRG03M" , /*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/,/*bLoad*/ )
	oModel:AddFields("SZAMASTER",/*cOwner*/,oStPai,/*bPreVld*/, /*bPost*/ ,)
	oModel:AddGrid("SZ9DETAIL","SZAMASTER",oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPreVal - Grid Inteiro*/,/*bPosVal - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  	// cOwner é para quem pertence

	// Fazendo o relacionamento entre o Pai e Filho
	aAdd(aSZ9Rel, {"Z9_FILIAL",	"ZA_FILIAL"})
	aAdd(aSZ9Rel, {"Z9_NUMERO",	"ZA_NUMERO"})

	oModel:SetRelation("SZ9DETAIL", aSZ9Rel, SZ9->(IndexKey(1))) 					// IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel("SZ9DETAIL"):SetUniqueLine({"Z9_ITEM","Z9_PRODUTO"})			// Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})

	// Setando as descrições
	oModel:SetDescription("Solicitação de Compra de Gado")
	oModel:GetModel("SZAMASTER"):SetDescription("Cabeçalho Solicitação de Compra de Gado")
	oModel:GetModel("SZ9DETAIL"):SetDescription("Itens Solicitação de Compra de Gado")

Return oModel


/*====================================================================*
| Função:  		ViewDef                                               |
| Descrição:	Criação da visão MVC                                  |
*====================================================================*/
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("STI_RG03")
	Local oStPai	:= FWFormStruct(2, "SZA")
	Local oStFilho	:= FWFormStruct(2, "SZ9")

	// Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField("VIEW_SZA",oStPai,"SZAMASTER")
	oView:AddGrid("VIEW_SZ9",oStFilho,"SZ9DETAIL")

	// Incrementa o campo ITEM
	oView:AddIncrementField("VIEW_SZ9", "Z9_ITEM")

	// Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox("CABEC",65)
	oView:CreateHorizontalBox("GRID", 35)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// Amarrando a view com as box
	oView:SetOwnerView("VIEW_SZA","CABEC")
	oView:SetOwnerView("VIEW_SZ9","GRID")

	// Habilitando título
	oView:EnableTitleView("VIEW_SZA","Cabeçalho da Solicitação de Compra")
	oView:EnableTitleView("VIEW_SZ9","Itens da Solicitação de Compra")

Return oView


/*/{Protheus.doc} RG03Leg
Função para mostrar a legenda da rotina em MVC
@author 	Evandro Mugnol
@since 		Set/2017
/*/

User Function RG03Leg()

	Local aLegenda := {}

	// Monta as cores
	AADD(aLegenda,{"RED",		"Solicitação Incompleta"})
	AADD(aLegenda,{"YELLOW",	"Solicitação Completa"})
	AADD(aLegenda,{"GREEN",		"Solicitação Atendida"})

	BrwLegenda("Manutenção de Solicitação de Compra de Gado", "Legenda", aLegenda)

Return


/*/{Protheus.doc} STATLeg
Função para mostrar a legenda da rotina em MVC
@author 	Evandro Mugnol
@since 		Set/2017
/*/

User Function STATLeg(cNumSC)

	Private lAtendido := .T.
	Private nRet

	SZ9->(DbSetOrder(1))
	SZ9->(DbSeek(xFilial("SZ9") + cNumSC))

	lErro := IIF(cNumSC == SZ9->Z9_NUMERO, .F., .T.)

	Do While !SZ9->(Eof()) .And. SZ9->Z9_FILIAL + SZ9->Z9_NUMERO == xFilial("SZ9") + cNumSC
		lErro := IIF(Empty(SZ9->Z9_PRECO) .Or. Empty(SZ9->Z9_PRODUTO) .Or. Empty(SZ9->Z9_QUANT), .T., lErro)
		SZ9->(DbSkip())
	Enddo

	lErro :=  Empty(SZA->ZA_CODFOR) .Or. Empty(SZA->ZA_LOJA) .Or. Empty(SZA->ZA_COMPRA) .Or. lErro

	DO CASE
		CASE lAtendido
		nRet := 3  	// Atendido
		CASE !lErro
		nRet := 2  	// Completo		
		CASE lErro
		nRet := 1  	// Incompleto
	ENDCASE

Return(nRet)


/*/{Protheus.doc} RG03Grv
Comitt do modelo 
@author 	Evandro Mugnol
@since 		Set/2017
/*/

User Function RG03Grv( oModel ) 

	Local cItem	  := StrZero(0,TamSX3("Z9_ITEM")[1])
	Local nOpc    := oModel:GetOperation()
	Local oStPai  := oModel:GetModel("SZAMASTER")
	Local cNumSC  := oStPai:GetValue("ZA_NUMERO")  
	Local dDtAbat := oStPai:GetValue("ZA_ABATE")
	Local cCodFor := oStPai:GetValue("ZA_CODFOR")
	Local cLojFor := oStPai:GetValue("ZA_LOJA")
	Local cTipCom := oStPai:GetValue("ZA_TPCOM")

	// Efetuar a gravação de outros dados em entidade que não são do model
	FWFormCommit( oModel )

	_nQtde  := 0
	_nValor := 0
	DbSelectArea("SZ9")
	SZ9->(DbSetOrder(1)) 	// Z9_FILIAL + Z9_NUMERO + Z9_ITEM
	If SZ9->(DbSeek(xFilial("SZ9") + cNumSC))
		While SZ9->(!Eof()) .And. SZ9->Z9_FILIAL + SZ9->Z9_NUMERO == xFilial("SZ9") + cNumSC

			cItem	:= Soma1(cItem)
			RecLock("SZ9",.F.)
			SZ9->Z9_ITEM 	 := cItem
			SZ9->Z9_FORNECE := cCodFor
			SZ9->Z9_LOJA	 := cLojFor
			SZ9->Z9_NOMFOR	 := fBuscaCpo("SA2", 1, xFilial("SA2") + cCodFor + cLojFor, "A2_NOME")
			SZ9->Z9_DATA	 := dDtAbat
			SZ9->(MsUnlock())

			// Atualiza valores no romaneio quando for ALTERAÇÃO
			If nOpc == 4
				DbSelectArea("ZAQ")
				DbSetOrder(4)
				DbSeek(xFilial("ZAQ") + SZ9->Z9_NUMERO)
				If Found()
					DO CASE
						CASE SZ9->Z9_PRODUTO == "000230         "		// Boi
						If SZ9->Z9_ITEM == ZAQ->ZAQ_NGITSC
							DbSelectArea("ZAQ")
							RecLock("ZAQ",.F.)
							ZAQ->ZAQ_NGPRC  := SZ9->Z9_PRECO
							ZAQ->ZAQ_NGPRCB := SZ9->Z9_PRECOBN
							MsUnlock()
						Endif
						CASE SZ9->Z9_PRODUTO == "000231         "		// Vaca
						If SZ9->Z9_ITEM == ZAQ->ZAQ_VGITSC
							DbSelectArea("ZAQ")
							RecLock("ZAQ",.F.)
							ZAQ->ZAQ_VGPRC  := SZ9->Z9_PRECO
							ZAQ->ZAQ_VGPRCB := SZ9->Z9_PRECOBN
							MsUnlock()
						Endif
						CASE SZ9->Z9_PRODUTO == "001075         "		// Touro
						If SZ9->Z9_ITEM == ZAQ->ZAQ_TGITSC
							DbSelectArea("ZAQ")
							RecLock("ZAQ",.F.)
							ZAQ->ZAQ_TGPRC  := SZ9->Z9_PRECO
							ZAQ->ZAQ_TGPRCB := SZ9->Z9_PRECOBN
							MsUnlock()
						Endif
						CASE SZ9->Z9_PRODUTO == "001073         "		// Búfalo
						If SZ9->Z9_ITEM == ZAQ->ZAQ_BGITSC
							DbSelectArea("ZAQ")
							RecLock("ZAQ",.F.)
							ZAQ->ZAQ_BGPRC  := SZ9->Z9_PRECO
							ZAQ->ZAQ_BGPRCB := SZ9->Z9_PRECOBN
							MsUnlock()
						Endif
						CASE SZ9->Z9_PRODUTO == "001074         "		// Búfala
						If SZ9->Z9_ITEM == ZAQ->ZAQ_BAITSC
							DbSelectArea("ZAQ")
							RecLock("ZAQ",.F.)
							ZAQ->ZAQ_BAPRC  := SZ9->Z9_PRECO
							ZAQ->ZAQ_BAPRCB := SZ9->Z9_PRECOBN
							MsUnlock()
						Endif
					ENDCASE
				Endif
			Endif

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
	If SZA->(DbSeek(xFilial("SZA") + cNumSC))
		RecLock("SZA",.F.)
		SZA->ZA_TOTALQT := _nQtde
		SZA->ZA_VALTOT  := _nValor
		MsUnlock()
	Endif

Return .T.
