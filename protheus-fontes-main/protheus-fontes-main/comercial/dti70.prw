#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//Variáveis Estáticas
Static cTitulo := "Correlação Produto Alternativo e Produto"

/*/{Protheus.doc} DTI70
Função para cadastro de Correlação Produto Alternativo e Produto (Modelo 3 - ZE0 x ZE1)
@author 	Evandro
@since 		17/12/2018
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas
/*/

User Function DTI70()
	
	Local aArea := GetArea()
	Local oBrowse

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias("ZE0")

	// Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

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
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"   	 OPERATION 1                   	  ACCESS 0  // OPERATION 1
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.DTI70" OPERATION MODEL_OPERATION_VIEW	  ACCESS 0  // OPERATION 2
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.DTI70" OPERATION MODEL_OPERATION_INSERT ACCESS 0  // OPERATION 3
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.DTI70" OPERATION MODEL_OPERATION_UPDATE ACCESS 0  // OPERATION 4
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.DTI70" OPERATION MODEL_OPERATION_DELETE ACCESS 0  // OPERATION 5

Return aRotina


/*====================================================================*
| Função:  		ModelDef                                               |
| Descrição:	Criação do modelo de dados MVC                         |
*====================================================================*/
Static Function ModelDef()

	Local oModel   := Nil
	Local oStPai   := FWFormStruct(1, "ZE0", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStFilho := FWFormStruct(1, "ZE1", /*bAvalCampo*/, /*lViewUsado*/)
	Local aZE1Rel  := {}
	Local bCommit   := { |oModel| U_DTI70Grv( oModel ) }

	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("DTI70M" , /*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/,/*bLoad*/ )
	oModel:AddFields("ZE0MASTER",/*cOwner*/,oStPai,/*bPreVld*/, /*bPost*/ ,)
	oModel:AddGrid("ZE1DETAIL","ZE0MASTER",oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPreVal - Grid Inteiro*/,/*bPosVal - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  	// cOwner é para quem pertence

	// Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZE1Rel, {"ZE1_FILIAL",	"ZE0_FILIAL"})
	aAdd(aZE1Rel, {"ZE1_CODZE0",	"ZE0_COD"})

	oModel:SetRelation("ZE1DETAIL", aZE1Rel, ZE1->(IndexKey(1))) 					// IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel("ZE1DETAIL"):SetUniqueLine({"ZE1_ITEM","ZE1_CODPRD"})			// Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})

	// Setando as descrições
	oModel:SetDescription("Correlação Produto Alternativo e Produto")
	oModel:GetModel("ZE0MASTER"):SetDescription("Cabeçalho Correlação Produto Alternativo e Produto")
	oModel:GetModel("ZE1DETAIL"):SetDescription("Itens Correlação Produto Alternativo e Produto")

Return oModel


/*====================================================================*
| Função:  		ViewDef                                                |
| Descrição:	Criação da visão MVC                                   |
*====================================================================*/
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("DTI70")
	Local oStPai	:= FWFormStruct(2, "ZE0")
	Local oStFilho	:= FWFormStruct(2, "ZE1")

	// Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField("VIEW_ZE0",oStPai,"ZE0MASTER")
	oView:AddGrid("VIEW_ZE1",oStFilho,"ZE1DETAIL")

	// Incrementa o campo ITEM
	oView:AddIncrementField("VIEW_ZE1", "ZE1_ITEM")

	// Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox("CABEC",25)
	oView:CreateHorizontalBox("GRID", 75)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// Amarrando a view com as box
	oView:SetOwnerView("VIEW_ZE0","CABEC")
	oView:SetOwnerView("VIEW_ZE1","GRID")

	// Habilitando título
	oView:EnableTitleView("VIEW_ZE0","Cabeçalho Correlação Produto Alternativo e Produto")
	oView:EnableTitleView("VIEW_ZE1","Itens Correlação Produto Alternativo e Produto")

Return oView


/*/{Protheus.doc} DTI70Grv
Comitt do modelo 
@author 	Evandro Mugnol
@since 		Dez/2018
/*/

User Function DTI70Grv( oModel ) 

	Local cItem	  := StrZero(0,TamSX3("ZE1_ITEM")[1])
	Local nOpc    := oModel:GetOperation()
	Local oStPai  := oModel:GetModel("ZE0MASTER")
	Local cNumZE0  := oStPai:GetValue("ZE0_COD")  

	// Efetuar a gravação de outros dados em entidade que não são do model
	FWFormCommit( oModel )

	DbSelectArea("ZE1")
	ZE1->(DbSetOrder(1)) 	// ZE1_FILIAL + ZE1_CODZE0 + ZE1_ITEM
	If ZE1->(DbSeek(xFilial("ZE1") + cNumZE0))
		While ZE1->(!Eof()) .And. ZE1->ZE1_FILIAL + ZE1->ZE1_CODZE0 == xFilial("ZE1") + cNumZE0

			cItem	:= Soma1(cItem)
			RecLock("ZE1",.F.)
			ZE1->ZE1_ITEM := cItem
			ZE1->(MsUnlock())

			ZE1->(DbSkip())
		EndDo
	EndIf

Return .T.
