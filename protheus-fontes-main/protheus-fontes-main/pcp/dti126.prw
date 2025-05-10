#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

// Variáveis Estáticas
Static cTitulo := "Detalhes do Abate"

/*/{Protheus.doc} DTI126
Função para manutenção de segmentos dos detalhes do Abate ( SZ4 ) do protheus - Modelo 1 em MVC
@author 	Flavio Bohrer Flôres
@since 		16/09/2021
@return 	Nil, Função não tem retorno
@obs 		Rotina utilizada para setar etiquetas(do abate) que vão sair com nome do cliente.
/*/

User Function DTI126()

	Local aArea := GetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias("SZ4")

	// Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	/* Filtro para aparecer só aviso em aberto */
	_cNumam 	:= fBuscaCpo('SZG',2,xFilial('SZG') + dtos(date()),'ZG_NUMAM')	
	
	set filter to Z4_NUMAM = alltrim(_cNumam) 
	
	
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
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.DTI126" 	OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 // OPERATION 2
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.DTI126" 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERATION 4
	

Return aRotina


/*====================================================================*
| Função:  		ModelDef                                              |
| Descrição:	Criação do modelo de dados MVC                        |
*====================================================================*/
Static Function ModelDef()

	
	// Criação do objeto do modelo de dados
	Local oModel := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStSZ4 := FWFormStruct(1,"SZ4")

	// Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("DTI126M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

	// Atribuindo formulários para o modelo
	oModel:AddFields("FORM126",/*cOwner*/,oStSZ4)

	// Setando a chave primária da rotina
	oModel:SetPrimaryKey({"Z4_FILIAL","Z4_NUMAM","Z4_LOTE"})

	// Adicionando descrição ao modelo
	oModel:SetDescription("Cadastro de " + cTitulo)

	// Setando a descrição do formulário
	oModel:GetModel("FORM126"):SetDescription("Formulário do Cadastro " + cTitulo)

Return oModel


/*====================================================================*
| Função:  		ViewDef                                               |
| Descrição:	Criação da visão MVC                                  |
*====================================================================*/
Static Function ViewDef()

	// Criação do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("DTI126")

	// Criação da estrutura de dados utilizada na interface do cadastro
	Local oStSZ4 := FWFormStruct(2, "SZ4")  // pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'XXX_NOME|XXX_DATAI|'}

	// Criando oView como nulo
	Local oView := Nil

	// Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Atribuindo formulários para interface	
	oView:AddField("VIEW_SZ4", oStSZ4, "FORM126")

	// Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	// Colocando título do formulário
	oView:EnableTitleView('VIEW_SZ4', 'Preencha os campos abaixo para serem considerados no cadastro de fornecedores -> Outras Opções -> Segmentos x Fornecedor' )  

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.F.})

	// O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SZ4","TELA")

	//Remove os campos (Deixa campos inativos "Cinza")
	/* 	01011421 */
	
	oStSZ4:RemoveField('Z4_IDLOT')
	oStSZ4:RemoveField('Z4_ORDEM')
	oStSZ4:RemoveField('Z4_AREAGTA')
	oStSZ4:RemoveField('Z4_PROPGTA')
	oStSZ4:RemoveField('Z4_DECPROD')
	oStSZ4:RemoveField('Z4_ELEMID')
	oStSZ4:RemoveField('Z4_TUBERC')
	oStSZ4:RemoveField('Z4_PROGRAM')
	oStSZ4:RemoveField('Z4_QUANT')
	oStSZ4:RemoveField('Z4_NPREN')
	oStSZ4:RemoveField('Z4_NPREAD')
	oStSZ4:RemoveField('Z4_DESCLA')
	

Return oView
