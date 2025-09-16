//Bibliotecas
#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Controle de Sobra de Bandejas"



User Function DTI96()
	Local aArea   := GetArea()
	Local oBrowse
	
	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro do aviso de matanca
	oBrowse:SetAlias("ZDA")

	//Legendas  - L=Lancada;S=Reaberta;B=Alterado;F=Fechada                                                                                       
	oBrowse:AddLegend( "ZDA->ZDA_STATUS = 'A'", "GREEN",	 "Aberto" )
	oBrowse:AddLegend( "ZDA->ZDA_STATUS = 'L'", "Orange",   "Alterado" )
	oBrowse:AddLegend( "ZDA->ZDA_STATUS = 'F'", "Black",	"Processado" )

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	
	//Ativa a Browse
	oBrowse:Activate()
	
	RestArea(aArea)
Return Nil


/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Flávio Flôres                                                |
 | Data:  02/04/2020                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRot := {}
	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.DTI96' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.DTI96' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.DTI96' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.DTI96' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Processar'  ACTION 'u_DTI96F' 	  OPERATION 6  					   ACCESS 0 //OPERATION 1

Return aRot

Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'ZDA', /*bAvalCampo*/, /*lViewUsado*/)
	//Local aZCBRel		:= {}
	Local bCommit       := { |oModel| U_Dt96grv( oModel ) }

	//Definições dos campos
	oStPai:SetProperty('ZDA_COD',      MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.')) 
	oStPai:SetProperty('ZDA_DESC',     MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))
	oStPai:SetProperty('ZDA_DTPROD',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.')) 
	oStPai:SetProperty('ZDA_NUM',      MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))  
	oStPai:SetProperty('ZDA_NUM',      MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZDA", "ZDA_NUM")'))        //Ini Padrão
	
	//Criando o modelo e os relacionamentos
 
	oModel := MPFormModel():New('DTI96M', /*bPreValidacao*/, /*bPosValidacao*/, bCommit,/*bCancel*/,/*bLoad*/)
	oModel:AddFields('ZDAMASTER',/*cOwner*/,oStPai)
	

	oModel:SetPrimaryKey({})
	
	//Setando as descrições
	oModel:SetDescription("!!!!")
	oModel:GetModel('ZDAMASTER'):SetDescription('Cabeçalho - Sobre de Bandejas')
	

Return oModel


Static Function ViewDef()
	Local oView		:= Nil
	Local oModel		:= FWLoadModel('DTI96')
	Local oStPai		:= FWFormStruct(2, 'ZDA')
	
	
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_ZDA',oStPai,'ZDAMASTER')
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',30)
	
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZDA','CABEC')
	
	
	//Habilitando título
	oView:EnableTitleView('VIEW_ZDA','Cabeçalho - Sobre de Bandejas')

	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//Remove os campos 
	oStPai:RemoveField('ZDA_VALID')
	
Return oView







/*   
Função utilizada para efetuar alterações conforme são inclusos ou alterados registros 
*/
User Function Dt96grv( oModel ) 
	
	Local nOpc    	:= oModel:GetOperation()
	Local oStPai  	:= oModel:GetModel("ZDAMASTER")
	Local cNum  	:= oStPai:GetValue("ZDA_NUM")
	Local cStatus  	:= oStPai:GetValue("ZDA_STATUS")
	
	/*  Gravar as informações conforme  o tipo de instrução 
	3 - Inserindo dados
	4 - Alterando dados
	*/	
	
	IF  nOpc = 3  //oStPai:IsUpdated()
	  //alert('Inserindo Dados')
		
	Elseif nOpc = 4
		/*alert('Alterando Dados')    -------- oBrowse:AddLegend( "ZDA->ZDA_STATUS = 'L'", "Orange",   "Alterado" )*/
		lOk1 := oModel:SetValue( 'ZDAMASTER', 'ZDA_STATUS', 'L' )
	Endif
	
	FWFormCommit( oModel )
	
Return .T.



User Function DTI96P(cNumZAU)
	Local oModel  	:= FWModelActive()
	
	cCod := fBuscaCPO('ZAU',1,xfilial('ZAU')+cNumZAU,'ZAU_COD')	
	dDtprod := fBuscaCPO('ZAU',1,xfilial('ZAU')+cNumZAU,'ZAU_DTPROD')
	nDiasv := fBuscaCPO('SB1',1,xfilial('SB1')+cCod,'B1_VALID')
	nDescP := fBuscaCPO('SB1',1,xfilial('SB1')+cCod,'B1_DESC')	
	/* Não consegui usar direto a interface porque estava dando erro quando tentava incluir mais de um campo ao mesmo tempo*/
	//lOk1 := oModel:SetValue( 'ZDAMASTER', 'ZDA_COD', cCod )
	M->ZDA_COD := cCod	
	M->ZDA_DESC := nDescP
	M->ZDA_DTPROD := dDtprod
	M->ZDA_VALID := nDiasv
	
Return .T.


/*---------------------------------------------------------------------*
 | Func:  Fechamento                                                   |
 | Autor: FLávio                                                       |
 | Data:  20/11/2019                                                   |
 | Desc:  Criação da Rotina de Processamento                           |
 *---------------------------------------------------------------------*/
User Function  DTI96F()
	
	Local aArea    	:= GetArea()
	Local _cDesc 	:= ''
	Local _bOk 		:= .F.
	Local Fechou 	:= .F.
	Local _cOpc		:= ''
		
	Private _cTitulo    := OemToAnsi("Processamento de Bandejas")
	Private _oTela, _oConfir, _bOk
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	_cNum := Space(10)
	_cDescri := ''

	DbSelectArea("ZDA")
	
	
	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(100), C(400) PIXEL
	@ C(005), C(25)  SAY "INFORME O NR DO REGISTRO:"						Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela
	@ C(015), C(010) SAY "Nr Reg.:"   		       									Size C(080), C(14) FONT _oFtArial24 COLOR CLR_GREEN PIXEL OF _oTela
	@ C(024), C(014) MSGET _cNum Picture "@!" When .T. Valid VldF() F3 "ZDA2"	Size C(058), C(12) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(024), C(080) MSGET _cDescri When .F.        								Size C(100), C(08) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(036), C(160) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED  
	 
	_cStatus := fBuscaCPO('ZDA',1,xfilial('ZDA')+alltrim(_cNum),'ZDA_STATUS')


	if _bOk
		If MsgYesNo("Deseja continuar com o Processamento das Bandejas Nr:"+_cNum+"?","Continuar")
			// Percorrendo os registros da SA1
			/*Criar as OPs da Embalagem - Aguardando somente o Henrique e Valeska testarem o sistema  */
			_cOpc := '1'
						
				DbSelectArea("ZDA")
				ZDA->(DbGoTop())
				DbSeek(xFilial("ZDA") + alltrim(_cNum))
				RecLock("ZDA",.F.)							
					ZDA->ZDA_STATUS := 'F'											
				MsUnLock()			
				MsgInfo( "Processamento Finalizado com Sucesso!!", "Aviso de Finalização" )
					
		Else
			MsgAlert("Não foi processado nenhum Fechamento devido ao cancelamento.")
		Endif	
	Endif
	RestArea(aArea)

Return 

Static Function VldF()
	_cDescri := ''
	_cDescri := fBuscaCPO('ZDA',1,xfilial('ZDA')+alltrim(_cNum),'ZDA_DESC')
	_cSt := fBuscaCPO('ZDA',1,xfilial('ZDA')+alltrim(_cNum),'ZDA_STATUS')
	
		If _cSt = 'F' 
			
			_bOk	:= .F.			
			MsgAlert("Fechamento Já executado. Informe outro número de Fechamento Válido!")
			Return
		
		Else
			
			_cNumero := fBuscaCPO('ZDA',1,xfilial('ZDA')+alltrim(_cNum),'ZDA_NUM')
			_bOk	:= .F.	
			_cDescri := fBuscaCPO('ZDA',1,xfilial('ZDA')+alltrim(_cNum),'ZDA_DESC')
					
		Endif
	

Return 
