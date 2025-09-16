#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//Variáveis Estáticas
Static cTitulo := "Gerenciamento de Refeições"

/*/{Protheus.doc} DTI104
Função para Gerenciamento de Refeições - Cabeçalho (SRA) e Itens (ZB8) - Modelo 3 em MVC
@author 	Flávio Bohrer
@since 		Jul/2020
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas
/*/

User Function DTI104()

	Local aArea := GetArea()
	Local oBrowse
	Private cIPerg  	:= "DTI104"   

	
	if !pergunte(cIPerg,.t.)
		return
	endif
	
	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SRA")

	// Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	// Legendas
	oBrowse:AddLegend("U_STLeg(SRA->RA_MAT) = 'V' ", "GREEN",	"Normal")
	oBrowse:AddLegend("U_STLeg(SRA->RA_MAT) = 'A' ", "YELLOW",	"Afastado Temp.")
	oBrowse:AddLegend("U_STLeg(SRA->RA_MAT) = 'D' ", "RED",		"Demitido")
	oBrowse:AddLegend("U_STLeg(SRA->RA_MAT) = 'F' ", "BLUE",	"Ferias")
	
	//set filter to (RA_SITFOLH <> 'D' .AND. RA_SITFOLH <> 'A' .AND. RA_SITFOLH <> 'F')  
	//set filter to (RA_SITFOLH <> 'D'  .AND. RA_SITFOLH <> 'F')
	//set filter to (RA_SITFOLH <> 'D' )

	// Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil


/*====================================================================*
| Função:  		MenuDef                                                |
| Descrição:	Criação do menu MVC                                    |
*====================================================================*/
Static Function MenuDef()

	Local aRotina := {}

	// Adicionando opções
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"   		 OPERATION 1                   	 ACCESS 0 // OPERATION 1
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.DTI104" OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 // OPERATION 2
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.DTI104" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERATION 3
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.DTI104" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERATION 4
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.DTI104" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERATION 5
	ADD OPTION aRotina TITLE "Legenda"    ACTION "U_DT104Leg" 	  OPERATION 6                      ACCESS 0 // OPERATION X

Return aRotina


/*====================================================================*
| Função:  		ModelDef                                               |
| Descrição:	Criação do modelo de dados MVC                         |
*====================================================================*/
Static Function ModelDef()

	Local oModel 	:= Nil
	Local oStPai 	:= FWFormStruct(1, "SRA", /*bAvalCampo*/, /*lViewUsado*/)
	//Local oStPai 	:= FWFormStruct(1, "SRA", { |x| ALLTRIM(x) $ 'RA_MAT, RA_NOME,RA_PAISEXT' } )
	Local oStFilho := FWFormStruct(1, "ZB8", /*bAvalCampo*/, /*lViewUsado*/)
	Local bCommit   := { |oModel| U_DT104Grv( oModel ) }
	Local aZB8Rel	:= {}

	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("DTI104M" , /*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/,/*bLoad*/ )
	oModel:AddFields("SRAMASTER",/*cOwner*/,oStPai,/*bPreVld*/, /*bPost*/ ,)
	oModel:AddGrid("ZB8DETAIL","SRAMASTER",oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPreVal - Grid Inteiro*/,/*bPosVal - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  	// cOwner é para quem pertence

	// Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZB8Rel, {"ZB8_FILIAL",	"RA_FILIAL"})
	aAdd(aZB8Rel, {"ZB8_MAT",	"RA_MAT"})


	//oModel:SetRelation("ZB8DETAIL", aZB8Rel, ZB8->(IndexKey(1))) 					// IndexKey -> quero a ordenação e depois filtrado
	oModel:SetRelation("ZB8DETAIL", aZB8Rel, ZB8->(IndexKey(9))) 
	
	// Usando uma expressão
   
	//oModel:GetModel("ZB8DETAIL"):SetUniqueLine({"ZB8_FILIAL","ZB8_MAT"})			// Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:GetModel("ZB8DETAIL"):SetUniqueLine({"ZB8_FILIAL","ZB8_NUM"})	
	
	oModel:SetPrimaryKey({})
	//alert(mv_par01)
	oModel:GetModel("ZB8DETAIL"):SetLoadFilter( , " ZB8_DATA BETWEEN '" + DTos(mv_par01) + "' AND '" + DTos(mv_par02) + "' " )	
	

	// Setando as descrições
	oModel:SetDescription("Solicitação de Reg. Refeições")
	oModel:GetModel("SRAMASTER"):SetDescription("Cabeçalho Solicitação de Reg. Refeições")
	oModel:GetModel("ZB8DETAIL"):SetDescription("Itens Solicitação de Reg. Refeições")

Return oModel


/*====================================================================*
| Função:  		ViewDef                                                |
| Descrição:	Criação da visão MVC                                   |
*====================================================================*/
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("DTI104")
	Local oStPai	:= FWFormStruct(2, "SRA")
	Local oStFilho	:= FWFormStruct(2, "ZB8")

	// Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	/*   Testando somente visualização da SRA */
	oStPai:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)
	
	// Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField("VIEW_SRA",oStPai,"SRAMASTER")
	oView:AddGrid("VIEW_ZB8",oStFilho,"ZB8DETAIL")

	// Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox("CABEC",65)
	oView:CreateHorizontalBox("GRID", 35)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// Amarrando a view com as box
	oView:SetOwnerView("VIEW_SRA","CABEC")
	oView:SetOwnerView("VIEW_ZB8","GRID")

	// Habilitando título
	oView:EnableTitleView("VIEW_SRA","Cabeçalho de Registro de Refeições")
	oView:EnableTitleView("VIEW_ZB8","Itens de  Registro de Refeições")


	/* Filho */
	oStFilho:RemoveField('ZB8_MAT')  

Return oView


/*/{Protheus.doc} DT104Leg
Função para mostrar a legenda da rotina em MVC
@author 	Flavio Bohrer
@since 		Julh/2020
/*/

User Function DT104Leg()

	Local aLegenda := {}

	// Monta as cores
	AADD(aLegenda,{"GREEN",			"Normal"})
	AADD(aLegenda,{"YELLOW",		"Afastado Temp."})
	AADD(aLegenda,{"RED",			"Demitido"})
	AADD(aLegenda,{"BLUE",			"Ferias"})
	
	BrwLegenda("Gerenciamento de Refeições", "Legenda", aLegenda)
Return


/*/{Protheus.doc} STATLeg
Função para mostrar a legenda da rotina em MVC
@author 	Flávio Bohrer
@since 		Julh/2020
/*/

User Function STLeg(cMat)

	Private lAtendido := ''
	Private nRet

	SRA->(DbSetOrder(1))
	SRA->(DbSeek(xFilial("SRA") + cMat))
			
	If SRA->RA_SITFOLH = 'A' 	
		nRet := 'A'					//Afastado Temp.
	Elseif SRA->RA_SITFOLH = 'D' 	
		nRet := 'D'					//Demitido
	Elseif SRA->RA_SITFOLH = 'F' 
		nRet := 'F'					//Ferias	
	Else
		nRet := 'V'	 				// Normal
	Endif
	
Return(nRet)


/*/{Protheus.doc} DT104Grv
Comitt do modelo 
@author 	Flávio Bohrer
@since 		Julh/2017
/*/

User Function DT104Grv( oModel ) 
	
	// Efetuar a gravação de outros dados em entidade que não são do model
	FWFormCommit( oModel )
	
Return .T.

User Function DTI04S()

	Private _cNum := space(10)
	_cNum := GetSx8num('ZB8','ZB8_NUM')
	ConfirmSX8()                                                   
	
Return _cNum
