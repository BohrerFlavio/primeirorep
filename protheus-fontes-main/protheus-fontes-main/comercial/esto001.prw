#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//Variáveis Estáticas
Static cTitulo := "Cadastro de Grupos de Estoque On Line"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ESTO001 
@type			: Função de Usuário
@Sample			: U_ESTO001()
@description	: Função para manutenção de grupos de estoque on-line - Cabeçalho (ZE2) e Itens (ZE3) - Modelo 2 em MVC
@Param			: Nulo
@return			: Nulo
@ --------------|-----------------------------------------------------------------------
@author			: Evandro Mugnol
@since			: Mai/2021
@version		: Protheus 12.1.25 e posteriores
/*/
//--------------------------------------------------------------------------------------

User Function ESTO001()

	Local aArea := GetArea()
	Local oBrowse

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZE2")

	// Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	// Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definicao do aRotina (Menu funcional)
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	// Adicionando opções
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"   	   OPERATION 1                   	ACCESS 0 // OPERATION 1
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ESTO001" OPERATION MODEL_OPERATION_VIEW	ACCESS 0 // OPERATION 2
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ESTO001" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERATION 3
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ESTO001" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERATION 4
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ESTO001" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERATION 5

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo do cadastro
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel   := Nil
	Local oStPai   := FWFormStruct(1, "ZE2", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStFilho := FWFormStruct(1, "ZE3", /*bAvalCampo*/, /*lViewUsado*/)
	Local aZE3Rel  := {}
	Local aAux 	   := CreateTrigger()

	oStPai:AddTrigger( ;
					   aAux[1] , ;       // [01] Id do campo de origem
					   aAux[2] , ;       // [02] Id do campo de destino
					   aAux[3] , ;       // [03] Bloco de codigo de validação da execução do gatilho
					   aAux[4] )       	 // [04] Bloco de codigo de execução do gatilho

	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("ESTO001M" , /*bPreValidacao*/,/*bPosValidacao*/,/*Commit*/,/*bCancel*/,/*bLoad*/ )
	oModel:AddFields("ZE2MASTER",/*cOwner*/,oStPai, /*bPreVld*/, /*bPosVld*/ ,)
	oModel:AddGrid("ZE3DETAIL","ZE2MASTER",oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPreVal - Grid Inteiro*/,/*bPosVal - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  	// cOwner é para quem pertence

	// Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZE3Rel, {"ZE3_FILIAL", "xFilial('ZE3')"})
	aAdd(aZE3Rel, {"ZE3_CODGRP", "ZE2_CODGRP"})

	oModel:SetRelation("ZE3DETAIL", aZE3Rel, ZE3->(IndexKey(1))) 					// IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel("ZE3DETAIL"):SetUniqueLine({"ZE3_ITEM","ZE3_CODPRO"})			// Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}

	// Chave primaria para a entidade principal do modelo de dados.
	oModel:SetPrimaryKey({'ZE2_FILIAL','ZE2_CODGRP'})

	// Verifica Linha duplicada
	oModel:GetModel( 'ZE3DETAIL' ):SetUniqueLine( { 'ZE3_CODPRO' } )

	// Executa gatilhos itens (grid)
    oStFilho:AddTrigger("ZE3_CODPRO", "ZE3_DESPRO", {||.T.} , {|| Posicione('SB1',1,xFilial('SB1')+FwFldGet("ZE3_CODPRO"),'B1_DESC')   })

	// Setando as descrições
	oModel:SetDescription("Cadastro de Grupos de Estoque On Line")
	oModel:GetModel("ZE2MASTER"):SetDescription("Cabeçalho Grupo de Estoque On Line")
	oModel:GetModel("ZE3DETAIL"):SetDescription("Itens Grupo de Estoque On Line")

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao da interface do cadastro
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("ESTO001")
	Local oStPai	:= FWFormStruct(2, "ZE2")
	Local oStFilho	:= FWFormStruct(2, "ZE3")

	// Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField("VIEW_ZE2",oStPai,"ZE2MASTER")
	oView:AddGrid("VIEW_ZE3",oStFilho,"ZE3DETAIL")

	// Incrementa o campo ITEM
	oView:AddIncrementField("VIEW_ZE3", "ZE3_ITEM")

	// Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox("CABEC",20)
	oView:CreateHorizontalBox("GRID", 80)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// Amarrando a view com as box
	oView:SetOwnerView("VIEW_ZE2","CABEC")
	oView:SetOwnerView("VIEW_ZE3","GRID")

	// Habilitando título
	oView:EnableTitleView("VIEW_ZE2","Cabeçalho Grupo de Estoque On Line")
	oView:EnableTitleView("VIEW_ZE3","Itens Grupo de Estoque On Line")

	oView:AddIncrementField('VIEW_ZE3','ZE2_ITEM')

Return oView

 
//-------------------------------------------------------------------
/*/{Protheus.doc} VldCod
A função fornece um array com a estrutura para criação de um trigger na estrutura de dados
de um submodelo (FWFormModelStruct)
Ela deve ser usada quando deseja-se criar um gatilho na estrutura de dados, baseado nos parametros
informados a função devolve as informações que são necessárias para criar um gatilho usando o método AddTrigger
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function CreateTrigger()

	Local aAux := FwStruTrigger(;
							    "ZE2_CODGRP" ,; 		// Campo Dominio
								"ZE2_DESGRP" ,; 		// Campo de Contradominio
								"Posicione('SB1', 1, xFilial('SB1') + FwFldGet('ZE2_CODGRP'),'B1_DESC')",; 	// Regra de Preenchimento
								.F. ,; 					// Se posicionara ou nao antes da execucao do gatilhos
								"" ,; 					// Alias da tabela a ser posicionada
							 	0 ,; 					// Ordem da tabela a ser posicionada
								"" ,; 					// Chave de busca da tabela a ser posicionada
								NIL ,; 					// Condicao para execucao do gatilho
								"01" ) 					// Sequencia do gatilho (usado para identificacao no caso de erro)   

Return aAux


//-------------------------------------------------------------------
/*/{Protheus.doc} VldCod
Função de usuário executada no SX3 para validação
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
User Function VldCod(cMaster,cCampo)
    
	Local _lRet		:= .T.
	Local oModel 	:= FwModelActive()
    Local _Conteudo := oModel:GetValue( cMaster, cCampo )

	If UPPER(Left(_Conteudo,2)) <> "PP"
		FWAlertHelp("Cógido do produto inválido para grupo de estoque on line", "Informe um código que inicie com PP")
	EndIf

Return(_lRet)
