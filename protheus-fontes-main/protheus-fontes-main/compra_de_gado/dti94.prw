//Bibliotecas
#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Cadastramento de Preços de Animais por Lote"

/*TABELAS ZCA E ZCB*/

User Function DTI94()
	Local aArea   := GetArea()
	Local oBrowse
	
	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro do aviso de matanca
	oBrowse:SetAlias("ZCA")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	
	//Ativa a Browse
	oBrowse:Activate()
	
	RestArea(aArea)
Return Nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  03/09/2016                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRot := {}
	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.DTI94' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.DTI94' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.DTI94' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.DTI94' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  03/09/2016                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/

Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'ZCA')
	Local oStFilho 		:= FWFormStruct(1, 'ZCB')
	Local aZCBRel		:= {}
	
	//Definições dos campos
	oStPai:SetProperty('ZCA_NUM',      MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('ZCA_NUM',      MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZCA", "ZCA_NUM")'))        //Ini Padrão
	oStPai:SetProperty('ZCA_NUMAM',    MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistCpo("SZG", M->ZCA_NUMAM)'))      //Validação de Campo
	
	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('DTI94M')
	oModel:AddFields('ZCAMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('ZCBDETAIL','ZCAMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	
	//Fazendo o relacionamento entre o Pai e Filho
	//aAdd(aZCBRel, {'ZCB_FILIAL','ZCA_FILIAL'})
	aAdd(aZCBRel, {'ZCB_FILIAL', 'IIF(!INCLUI, ZCB->ZCB_FILIAL, FWxFilial("ZCB"))'} )
	aAdd(aZCBRel, {'ZCB_NUM'   ,'ZCA_NUM'})
	aAdd(aZCBRel, {'ZCB_NUMAM' ,'ZCA_NUMAM'}) 
	
	
	oModel:SetRelation('ZCBDETAIL', aZCBRel, ZCB->(IndexKey(3))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('ZCBDETAIL'):SetUniqueLine({"ZCB_LOTE"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})
	
	//Setando as descrições
	oModel:SetDescription("Dados Valores Lotes Abate")
	oModel:GetModel('ZCAMASTER'):SetDescription('Cabeçalho - Abate')
	oModel:GetModel('ZCBDETAIL'):SetDescription('Lotes - Valores')
Return oModel

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  03/09/2016                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/

Static Function ViewDef()
	Local oView		:= Nil
	Local oModel		:= FWLoadModel('DTI94')
	Local oStPai		:= FWFormStruct(2, 'ZCA')
	Local oStFilho	:= FWFormStruct(2, 'ZCB')
	
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_ZCA',oStPai,'ZCAMASTER')
	oView:AddGrid('VIEW_ZCB',oStFilho,'ZCBDETAIL')
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZCA','CABEC')
	oView:SetOwnerView('VIEW_ZCB','GRID')
	
	//Habilitando título
	oView:EnableTitleView('VIEW_ZCA','Cabeçalho - Abate')
	oView:EnableTitleView('VIEW_ZCB','Lotes - Valores')
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//Remove os campos 
	oStFilho:RemoveField('ZCB_NUM')
	oStFilho:RemoveField('ZCB_NUMAM')
	oStFilho:RemoveField('ZCB_FILIAL')
Return oView
