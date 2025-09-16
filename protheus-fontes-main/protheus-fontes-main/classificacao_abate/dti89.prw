//Bibliotecas
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
//Variáveis Estáticas

Static cTitulo := "Fechamendo da Produção"

/*/{Protheus.doc} DTI89
Função para trabalhar as informações do Fechamento da Produção)
@author Flávio
@since 24/02/2020
@version 1.0
@example	
/*/

User Function DTI89()

	Local aArea   := GetArea()
	Local oBrowse
	Private lOk := .f.
	Private cPerg	:= "DTI89"
	
	if !pergunte(cPerg,.t.)
		ret
	endif
	
	
	aObjects := {}                                             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	
	
	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de CDs
	oBrowse:SetAlias("ZZW")

	//Legendas  - L=Lancada;S=Reaberta;B=Alterado;F=Fechada                                                                                       
	oBrowse:AddLegend( "ZZW->ZZW_STATU = 'L'", "GREEN",	 "Importado" )
	oBrowse:AddLegend( "ZZW->ZZW_STATU = 'R'", "Orange", "Recalculado" )
	oBrowse:AddLegend( "ZZW->ZZW_STATU = 'F'", "Black",	"Fechado" )

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	
	/*  Filtro */
	If !Empty(alltrim(mv_par01)) 
		set filter to ZZW_NUM >= alltrim(mv_par01) .AND. ZZW_NUM <= alltrim(mv_par02) 	
	Else
		//set filter to ZZX_NUMF >= alltrim(mv_par01) .AND. ZZX_NUMF <= alltrim(mv_par02)
	Endif
	
	//Ativa a Browse
	oBrowse:Activate()
	
	RestArea(aArea)

Return Nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Flávio                                                       |
 | Data:  18/11/2019                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRot := {}
	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.DTI89'  OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 
	ADD OPTION aRot TITLE 'Alterar'   	 	ACTION 'VIEWDEF.DTI89'  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    		ACTION 'VIEWDEF.DTI89'  OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'ImpSol.Prod.' 	ACTION 'u_ImpDados'     OPERATION 6  					ACCESS 0 //OPERATION 1	
	ADD OPTION aRot TITLE 'Fech.Prod' 		ACTION 'u_DTI89F' 	    OPERATION 6  					ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Relatório' 		ACTION 'u_DTI89Rel'     OPERATION 6  					ACCESS 0 //OPERATION 1
	
Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 |  Autor: Flávio                                                       |
 | Data:  18/11/2019                                                |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/

Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'ZZW')
	Local oStFilho 		:= FWFormStruct(1, 'ZZX')
	Local oStNeto 		:= FWFormStruct(1, 'ZZY')
	Local aZZXRel		:= {}
	Local aZZYRel		:= {}
	
	//Definições dos campos
	oStPai:SetProperty('ZZW_NUM',     MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSXENum("ZZW", "ZZW_NUM")'))       //Ini Padrão
	oStPai:SetProperty('ZZW_NUM',     MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('ZZW_DESC',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))
	oStPai:SetProperty('ZZW_DATA',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))
	oStPai:SetProperty('ZZW_CORORI',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))
	

	oStFilho:SetProperty('ZZX_DATA',  	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                                                                     
	oStFilho:SetProperty('ZZX_ITEM',  	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))
	oStFilho:SetProperty('ZZX_CORORI',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.')) 
	oStFilho:SetProperty('ZZX_TCORTE',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))
	oStFilho:SetProperty('ZZX_QPEC',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))
	oStFilho:SetProperty('ZZX_FAM',     MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))
	
	oStNeto:SetProperty('ZZY_COD',  	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))  
	oStNeto:SetProperty('ZZY_CORORI',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.')) 
	oStNeto:SetProperty('ZZY_ITEM',  	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                                                                                              
	oStNeto:SetProperty('ZZY_TCORTE',  	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))
	oStNeto:SetProperty('ZZY_QPCAIX',  	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.')) 
	oStNeto:SetProperty('ZZY_PMCAIX',  	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))
	oStNeto:SetProperty('ZZY_MARCA',  	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))  
	
	    
	/*   Esta validação vai na ZZY depois, para criar ítens ( que são as carnes) não deixando repetir ítens*/
	        
	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('DTI89M',)
	oModel:AddFields('ZZWMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('ZZXDETAIL','ZZWMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	oModel:AddGrid('ZZYDETAIL','ZZXDETAIL',oStNeto,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	
	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZZXRel, {'ZZX_DATA',	'ZZW_DATA'})
	aAdd(aZZXRel, {'ZZX_NUMF',	'ZZW_NUM'})
	aAdd(aZZXRel, {'ZZX_CORORI','ZZW_CORORI'})
	aAdd(aZZYRel, {'ZZY_NUM',	'ZZX_NUM'})
	aAdd(aZZYRel, {'ZZY_TCORTE','ZZX_TCORTE'})
	aAdd(aZZYRel, {'ZZY_CORORI','ZZX_CORORI'})
	
	
	oModel:SetRelation('ZZXDETAIL', aZZXRel, ZZX->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:SetPrimaryKey({})
	
	oModel:SetRelation('ZZYDETAIL', aZZYRel, ZZY->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:SetPrimaryKey({})
	
	//Setando as descrições
	oModel:SetDescription("Fechamento de Produção")
	oModel:GetModel('ZZWMASTER'):SetDescription('Produção')
	oModel:GetModel('ZZXDETAIL'):SetDescription('Grupo Corte')
	oModel:GetModel('ZZYDETAIL'):SetDescription('Cortes')
	
Return oModel

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: FLávio                                                       |
 | Data:  03/09/2016                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/

Static Function ViewDef()
	Local oView			:= Nil
	Local aTreeInfo		:= {}
	Local oModel		:= FWLoadModel('DTI89')
	Local oStPai		:= FWFormStruct(2, 'ZZW')
	Local oStFilho		:= FWFormStruct(2, 'ZZX')
	Local oStNeto		:= FWFormStruct(2, 'ZZY')
		
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
		

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_ZZW',oStPai,'ZZWMASTER')
	// Cria a estrutura das grids em formato de árvore 
	aAdd( aTreeInfo, { "ZZXDETAIL", { "ZZX_NUM", "ZZX_TCORTE" ,"ZZX_FAM" ,"ZZX_QPEC","ZZX_DREST1"}, oStFilho } )
	aAdd( aTreeInfo, { "ZZYDETAIL", { "ZZY_COD" , "ZZY_DESC", "ZZY_MARCA" } , oStNeto } )
	oView:AddTreeGrid( "TREE", aTreeInfo, "DETAIL_TREE" )
		
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',40)
	oView:CreateHorizontalBox('GRID',60)
		
	
	// Criar "box" vertical para receber algum elemento da view
	oView:CreateVerticalBox( 'EMBAIXOESQ', 40, 'GRID' )
	oView:CreateVerticalBox( 'EMBAIXODIR', 60, 'GRID' )
	
	
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZZW','CABEC')
	oView:SetOwnerView( 'TREE' , 'EMBAIXOESQ' )
	oView:SetOwnerView( 'DETAIL_TREE', 'EMBAIXODIR' )
	
	//Habilitando título
	oView:EnableTitleView('VIEW_ZZW','Cabeçalho - Cadastro')
	oView:EnableTitleView('DETAIL_TREE','Cortes')
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//Remove os campos de Código do Artista e CD
	 oStFIlho:RemoveField('ZZX_DREST1') 
	 oStNeto:RemoveField('ZZY_NUM')    
	 oStNeto:RemoveField('ZZY_CORORI')
	 oStNeto:RemoveField('ZZY_ITEM')
	 oStNeto:RemoveField('ZZY_NUM')
	       
Return oView


/*---------------------------------------------------------------------*
 | Func:  Fechamento                                                   |
 | Autor: FLávio                                                       |
 | Data:  20/11/2019                                                   |
 | Desc:  Criação da Rotina de Fechamento                              |
 *---------------------------------------------------------------------*/
User Function  DTI89F()
	
	Local aArea    	:= GetArea()
	//Local _cDesc 	:= ''
	Local _bOk 		:= .F.
	Local Fechou 	:= .F.
	Local _cOpc		:= ''
		
	Private _cTitulo    := OemToAnsi("Fechamento de Produção")
	Private _oTela, _oConfir//, _bOk
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	_cNum := Space(06)
	_cDescri := ''
	
	DbSelectArea("ZZW")
	
	
	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(100), C(400) PIXEL
	@ C(005), C(25) SAY "INFORME O NUMERO PARA O FECHAMENTO"							Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela
	@ C(015), C(010) SAY "Nr Fechamento:"   		       							Size C(080), C(10) FONT _oFtArial24 COLOR CLR_GREEN PIXEL OF _oTela
	@ C(024), C(010) MSGET _cNum Picture "@!" When .T. Valid VldFec('F') F3 "ZZW"		Size C(045), C(08) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(024), C(080) MSGET _cDescri When .F.        								Size C(100), C(08) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(036), C(160) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED  
	 
	_cStatus := fBuscaCPO('ZZW',1,xfilial('ZZW')+alltrim(_cNum),'ZZW_STATU')
	_dDtABT := fBuscaCPO('ZZW',1,xfilial('ZZW')+alltrim(_cNum),'ZZW_DATAA')
	_dDtEMB := date()+1

	If Empty(_dDtABT)
		MsgAlert("Cancelado pelo Operador. Falta preencher Data do Abate.")
		Return 
	Endif

	if _bOk
		If MsgYesNo("Deseja continuar com o Fechamento da Produção Nr-"+_cNum+"?","Continuar")
			// Percorrendo os registros da SA1
			/*Criar as OPs da Embalagem - Aguardando somente o Henrique e Valeska testarem o sistema  */
			_cOpc := '1'
			Fechou := LOps(alltrim(_cNum),_dDtABT,_dDtEMB,_cOpc)
			
			IF Fechou
			
				DbSelectArea("ZZW")
				ZZW->(DbGoTop())
				DbSeek(xFilial("ZZW") + alltrim(_cNum))
				RecLock("ZZW",.F.)							
					ZZW->ZZW_STATU := 'F'
					ZZW->ZZW_DATAF := DATE()							
				MsUnLock()			
				
				Alert("Fechamento processado o com Sucesso!!")
			Else				
				Alert("Não foi processado o Fechamento da Produção")
			Endif
					
		Else
			MsgAlert("Não foi processado nenhum Fechamento devido ao cancelamento.")
		Endif	
	Endif
	RestArea(aArea)

Return 


Static Functio LOps(cZZWNUM,dDTa,dDTE,cOP)
	Local Ok := .F.
	//Local cNum := ''
	//Local _cMens := ''
	//local _cDest  := 'valeska.brum@frigorificosilva.com.br' 
	
	/*  Aqui fazer a busca em todas as linhas que estão setadas para o fechamento em questão...*/
	If cOP = '1'
		/* Sistema vai fazer o fechamento*/ 
	_dDt := fBuscaCPO('ZZW',1,xfilial('ZZW')+alltrim(cZZWNUM),'ZZW_DATA')	
	GerQ3(cZZWNUM)	
	TMP3->(dbGoTop())
	
		Do While TMP3->(!EOF()) 
			
			GerQ4(alltrim(TMP3->ZZX_NUM))	
			
			Do While TMP4->(!EOF())
				
				/* 
				DTI41 - gerando as OPs automáticas conforme a mesma regra que foi criada 
				no processo de impressão de Etiquetas primárias.
				*/
				U_QtdPrev(dDTa,Alltrim(TMP4->ZZY_DESC),dDTE,alltrim(TMP4->ZZY_COD)) 
							
				TMP4->(dbSkip())						
			Enddo	
			
			TMP3->(dbSkip()) 
		Enddo
		Ok := .T.
	
	Elseif cOP = '2'
	
			/* Sistema vai fazer a Abertura na ZZW do Fechamento
				Ainda não implementado - Só deixei a idéia*/ 
		dDt := fBuscaCPO('ZZW',1,xfilial('ZZW')+alltrim(cZZWNUM),'ZZW_DATA')	
		GerQ5(alltrim(cZZWNUM))	
		
		TMP5->(dbGoTop())
	
		Do While TMP5->(!EOF()) 
			
			//DbSelectArea("SZU")
			DbSelectArea("SZU")
			SZU->(DbGoTop())			
			SZU->(DbSetOrder(2))
			if SZU->(DbSeek(xFilial("SZU") + alltrim(TMP5->ZU_NUM)))
						
				Ok := .T.
				
			Endif	
			TMP5->(dbSkip()) 
			
		Enddo
		
	Endif
	
Return Ok


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Consistencia no Vendedor                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VldFec(_cTipo)
	_cDescri := ''
	DbSelectArea("ZZW")
	DbSeek(xFilial("ZZW") + _cNum)
	If Found()
		If ZZW->ZZW_STATU = 'F' .AND. _cTipo = 'F'
			lVal 	:= .F.
			_bOk	:= .F.			
			MsgAlert("Fechamento Já executado. Informe outro número de Fechamento Válido!")
			Return
		Endif
		
		
		lVal       := .T.
		_cNumero := ZZW->ZZW_NUM
		_cDescri := ZZW->ZZW_DESC
		
	Else
		lVal 	  := .F.
		_cNumero := ""
		MsgAlert("Fechamento Inválido. Informe um Fechamento Válido!")
	EndIf

Return 



User Function  DTI89Rel()
	
   //DimensÃµes da janela
    Local nJanAltu := 180
    Local nJanLarg := 450
    //Objetos da tela
    Local oGrpPar
	Private oSayD
    Private oGetD := space(8)
	Private cGetD :=  date() 
	
	
	 DEFINE MSDIALOG oDlgPvt TITLE " Relatório de Fechamento da Produção " FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	 	 @ 003, 003     GROUP oGrpPar TO 060, (nJanLarg/2)     PROMPT "Parâmetros: "         OF oDlgPvt COLOR 0, 16777215 PIXEL  
	 	 	@ 013, 006 SAY        oSayD PROMPT "Data do Fechamento a Visualizar :"          SIZE 060, 007 OF oDlgPvt PIXEL
	 	 	@ 010, 070 MSGET      oGetD VAR    cGetD                      SIZE 70,10 OF oDlgPvt PIXEL
	 	 	oGetD:bHelp := {||    ShowHelpCpo(    "cGetD",;
                           {"Data de Fechamento da Produção¡ utilizada para este relatório."},2,;
                           {},2)}
       //Grupo Açôes
        @ 063, 003     GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2)     PROMPT "Ações: "         OF oDlgPvt COLOR 0, 16777215 PIXEL
         	
            //Botões            
            @ 070, (nJanLarg/2)-(63*3)  BUTTON oBtnRela PROMPT "Gerar"   SIZE 60, 014 OF oDlgPvt ACTION (GerRel(cGetD)) PIXEL
            @ 070, (nJanLarg/2)-(63*1)  BUTTON oBtnSair PROMPT "Sair"      SIZE 60, 014 OF oDlgPvt ACTION (oDlgPvt:End()) PIXEL                    
                            
	 ACTIVATE MSDIALOG oDlgPvt CENTERED
	
Return 


/*---------------------------------------------------------------------*
 | Func:  fRelacao                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  28/08/2015                                                   |
 | Desc:  FunÃ§Ã£o que exporta a relaÃ§Ã£o dos campos para TReport         |
 *---------------------------------------------------------------------*/
 
Static Function GerRel(_dData)
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia do Fechamento de Produção"
	Local cDesc3         := " "
	//Local cPict          := ""
	Local titulo         := "RESUMO DE FECHAMENTO DE PRODUÇÃO"
	Local Cabec1         := " "
	Local Cabec2         := ""
	//Local imprime         := .T.
	Local aOrd            := {}  
	Private nLin          := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "DTI89Rel" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	//Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI89" // Coloque aqui o nome do arquivo usado para impressao em disco    
		
	wnrel := SetPrint('ZZW',NomeProg,,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	GerQuery(_dData)
	GerQ2(_dData)
	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZZW')

	If nLastKey == 27
		Return
	Endif
   
   nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
      
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	
	Local nCont := 0
	Local nCont2 := 1
	Local nCont3 := 0
	//Local _nZZVnum := ''
	Local _cZZWD := ''
	Local _cZZWN := ''
	local nl2	 := 9
	
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))
	TMP->(dbGoTop())
	
	While TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 .OR. nl2 > 70// Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
			nl2	 := 9 
		Endif
		
		// " SELECT ZZW_NUM, ZZW_DESC, ZZW_DATA 		
		If nCont = 0
						
			nlin++
			nl2++												
			@nlin,010 psay 'Fechamento do Dia:'
			@nlin,030 psay STOD(TMP->ZZW_DATA)
			nlin++
			nl2++
			@nlin,008 psay replicate('-',115)
			nlin++
			nl2++
			nlin++
			nl2++
			
			l0 := 10
			l1 := 12
			l2 := 29
			l4 := 35
			l5 := 49
			l3 := 55
			
			/* aqui fazer o cabçalho  */
				TMP2->(dbGoTop())
				While TMP2->(!EOF())
					
					if nCont3 = 0
						@nlin,l0 psay alltrim(TMP2->ZZW_NUM)+' - '+alltrim(TMP2->ZZW_DESC)		
						nlin++			
						// Esquerda
						@nlin,l1 psay 'Qt Geral Peças:'
						@nlin,l2 psay TMP2->ZZW_QPEC					
						// Direita
						@nlin,l4 psay 'Qt Black:'
						@nlin,l5 psay TMP2->ZZW_QPECBK
						@nlin,l3 psay '|'
						nlin++	
						// Esquerda 
						@nlin,l1 psay 'Qt Hereford:'  
						@nlin,l2 psay TMP2->ZZW_QPECH 
						// Direita
						@nlin,l4 psay 'Qt Diant.UY:'
						@nlin,l5 psay TMP2->ZZW_QPECDU
						@nlin,l3 psay '|'
						nlin++	
						@nlin,l1 psay 'Qt Angus:'
						@nlin,l2 psay TMP2->ZZW_QPECA
						nlin++
						@nlin,l1 psay 'Total Peças:'
						@nlin,l2 psay TMP2->ZZW_QPECGR
						@nlin,l4 psay 'Dif.Sug./Sol:'
						@nlin,l5 psay TMP2->ZZW_QPECDF
						@nlin,l3 psay '|'					
						nlin++
						nCont3++
					elseif nCont3 = 1
											
						l0 := 62
						l1 := 64
						l2 := 81
						l4 := 87
						l5 := 101
						l3 := 106
						
						@nlin,l0 psay alltrim(TMP2->ZZW_NUM)+' - '+alltrim(TMP2->ZZW_DESC)		
						nlin++			
						// Esquerda
						@nlin,l1 psay 'Qt Geral Peças:'
						@nlin,l2 psay TMP2->ZZW_QPEC					
						// Direita
						@nlin,l4 psay 'Qt Black:'
						@nlin,l5 psay TMP2->ZZW_QPECBK
						@nlin,l3 psay '|'
						nlin++	
						// Esquerda 
						@nlin,l1 psay 'Qt Hereford:'  
						@nlin,l2 psay TMP2->ZZW_QPECH 
						// Direita
						@nlin,l4 psay 'Qt Diant.UY:'
						@nlin,l5 psay TMP2->ZZW_QPECDU
						@nlin,l3 psay '|'
						nlin++	
						@nlin,l1 psay 'Qt Angus:'
						@nlin,l2 psay TMP2->ZZW_QPECA
						nlin++
						@nlin,l1 psay 'Total Peças:'
						@nlin,l2 psay TMP2->ZZW_QPECGR
						@nlin,l4 psay 'Dif.Sug./Sol:'
						@nlin,l5 psay TMP2->ZZW_QPECDF
						@nlin,l3 psay '|'					
						nlin++
						nCont3++
					
					elseif nCont3 = 2
						l0 := 10
						l1 := 12
						l2 := 29
						l4 := 35
						l5 := 49
						l3 := 55
						
						@nlin,l0 psay alltrim(TMP2->ZZW_NUM)+' - '+alltrim(TMP2->ZZW_DESC)		
						nlin++			
						// Esquerda
						@nlin,l1 psay 'Qt Geral Peças:'
						@nlin,l2 psay TMP2->ZZW_QPEC					
						// Direita
						@nlin,l4 psay 'Qt Black:'
						@nlin,l5 psay TMP2->ZZW_QPECBK
						@nlin,l3 psay '|'
						nlin++	
						// Esquerda 
						@nlin,l1 psay 'Qt Hereford:'  
						@nlin,l2 psay TMP2->ZZW_QPECH 
						// Direita
						@nlin,l4 psay 'Qt Diant.UY:'
						@nlin,l5 psay TMP2->ZZW_QPECDU
						@nlin,l3 psay '|'
						nlin++	
						@nlin,l1 psay 'Qt Angus:'
						@nlin,l2 psay TMP2->ZZW_QPECA
						nlin++
						@nlin,l1 psay 'Total Peças:'
						@nlin,l2 psay TMP2->ZZW_QPECGR
						@nlin,l4 psay 'Dif.Sug./Sol:'
						@nlin,l5 psay TMP2->ZZW_QPECDF
						@nlin,l3 psay '|'					
						nlin++
						nCont3++
					
					
					endif
					if nCont2 < 3
						@nlin,008 psay replicate('-',115)
					endif
					nlin++
					nl2++
					nCont2++
					TMP2->(dbSkip()) // Avanca o ponteiro do registro no arquivo
				Enddo
							
				nlin++
				@nlin,004 psay replicate('-',100)
				nlin++
		Endif
		
		IF _cZZWD = alltrim(TMP->ZZW_DESC)
			
		else
			nlin++
			nlin++
			// Escrever a descrição quando troca de nome				
			
			@nlin,010 psay alltrim(TMP->ZZW_NUM)
			@nlin,023 psay 'Corte :'
			@nlin,032 psay substr(alltrim(TMP->ZZW_DESC),1,20)	
			If TMP->ZZW_QPEC >0
				_QPECGR := 0
				@nlin,055 psay 'Qtd. Geral Peças :'
				@nlin,080 psay TMP->ZZW_QPECGR
				_QPECGR := TMP->ZZW_QPECGR
				
						
			Endif				
			_cZZWD := alltrim(TMP->ZZW_DESC)	
			
		Endif
		
		IF _cZZWN = alltrim(TMP->ZZX_NUM)
		Else
			
			nlin++			
			@nlin,020 psay 'Tp Corte:' 
			@nlin,033 psay alltrim(TMP->ZZX_TCORTE)			
			@nlin,052 psay 'Total Peças:'
			@nlin,070 psay TMP->ZZX_QPEC
						
			_cZZWN := alltrim(TMP->ZZX_NUM)	
			nlin++	
			
		Endif
		
		
			/*  Corpo */
			@nlin,035 psay alltrim(TMP->ZZY_COD)
			@nlin,043 psay  substr(alltrim(TMP->ZZY_DESC),1,30)
			
			If TMP->ZZY_QCAIX > 0
				@nlin,074 psay TMP->ZZY_QCAIX
			Else
				@nlin,074 psay TMP->ZZY_QPESO
			Endif
				
			nlin++ 
			
		nCont++
		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo
	nlin++
	nlin++
	                                                                                                                           
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return


Static Function GerQuery(_dDat)
	
	// _dDat = Data do Fechamento de produção

		/*  Se Relatório gerará para PCP		*/
		_cQuery := " SELECT  ZZW_NUM, ZZW_DESC, ZZW_DATA, ZZW_QPEC,ZZW_QPECGR,ZZW_QPECDF,ZZX_NUM , ZZX_TCORTE,ZZX_QPEC ,ZZY_COD ,ZZY_QCAIX, ZZY_QPESO,ZZY_DESC "
		_cQuery += " FROM " + RetSQLTab('ZZW') + ", " + RetSQLTab('ZZX')+ ", " + RetSQLTab('ZZY')
		_cQuery += " WHERE" + RetSQLFil('ZZW') + " AND " + RetSQLFil('ZZX') + " AND "+ RetSQLFil('ZZY') 
		_cQuery += " AND " + RetSQLDel('ZZW') + " AND " + RetSQLDel('ZZX')+ " AND " + RetSQLDel('ZZY') + " AND " 
		_cQuery += " ZZW_DATA = '" + DTOS(_dDat) + "' AND"
		_cQuery += " ZZW_NUM  = ZZX_NUMF  AND"
		_cQuery += " ZZW_DATA  = ZZX_DATA  AND"
		_cQuery += " ZZW_CORORI  = ZZX_CORORI  AND"
		_cQuery += " ZZX_NUM  = ZZY_NUM  AND"
		_cQuery += " ZZX_TCORTE  = ZZY_TCORTE  AND"
		_cQuery += " ZZX_CORORI  = ZZY_CORORI"		 
		_cQuery += " ORDER BY ZZW_DATA,ZZW_NUM,ZZX_NUM,ZZX_TCORTE,ZZY_COD,ZZY_DESC"
		
		
	_cQuery  := ChangeQuery(_cQuery)
	
	MsgRun("Aguarde... Realizando contagem de registros...",,{||  Gera_T() })
	
Return


Static Function GerQ2(_dDat)
	
	// _dDat = Data do Fechamento de produção

		/*  Se Relatório gerará para PCP		*/
		_cQuery := " SELECT  ZZW_NUM, ZZW_DESC, ZZW_DATA, ZZW_QPEC, ZZW_QPECH, ZZW_QPEC, ZZW_QPECA, ZZW_QPECBK, ZZW_QPECDU, ZZW_QPECGR, ZZW_QPECDF"
		_cQuery += " FROM " + RetSQLTab('ZZW') 
		_cQuery += " WHERE" + RetSQLFil('ZZW') 
		_cQuery += " AND "  + RetSQLDel('ZZW')  + " AND " 
		_cQuery += " ZZW_DATA = '" + DTOS(_dDat) + "'"		 
		_cQuery += " ORDER BY ZZW_DATA"
		
		
	_cQuery  := ChangeQuery(_cQuery)
	
	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP2"
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	
Return

 Static Function GerQ3(_cNF)
	
	// _dDat = Data do Fechamento de produção

		_cQuery := " SELECT  ZZX_NUM, ZZX_ITEM, ZZX_TCORTE, ZZX_NUMF"
		_cQuery += " FROM " + RetSQLTab('ZZX') 
		_cQuery += " WHERE" + RetSQLFil('ZZX') 
		_cQuery += " AND "  + RetSQLDel('ZZX')  + " AND " 
		_cQuery += " ZZX_NUMF = '" + _cNF + "'"		 
		_cQuery += " ORDER BY ZZX_NUM, ZZX_ITEM"
		
	_cQuery  := ChangeQuery(_cQuery)
	
	If Select("TMP3") != 0
		TMP3->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP3"
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	
Return 

Static Function GerQ4(_cZZXNum)

		_cQuery := " SELECT  ZZY_NUM, ZZY_COD,ZZY_DESC ,ZZY_TCORTE"
		_cQuery += " FROM " + RetSQLTab('ZZY') 
		_cQuery += " WHERE" + RetSQLFil('ZZY') 
		_cQuery += " AND "  + RetSQLDel('ZZY')  + " AND " 
		_cQuery += " ZZY_NUM = '" + _cZZXNum + "'"		 
		_cQuery += " ORDER BY ZZY_NUM, ZZY_ITEM"
		
	_cQuery  := ChangeQuery(_cQuery)
	
	If Select("TMP4") != 0
		TMP4->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP4"
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	
Return 

Static Function GerQ5(_nZZWN)
	
		_cQuery := " SELECT  ZU_NUM,ZU_COD,ZU_DESC,ZU_OBS"
		_cQuery += " FROM " + RetSQLTab('SZU') 
		_cQuery += " WHERE" + RetSQLFil('SZU') 
		_cQuery += " AND "  + RetSQLDel('SZU')  + " AND " 
		_cQuery += " ZU_OBS  LIKE '%" + _nZZWN + "%'"		 
		
		
	_cQuery  := ChangeQuery(_cQuery)
	
	If Select("TMP5") != 0
		TMP5->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP5"
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	
Return 



Static Function Gera_T()   

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"
	
Return


/*-------------------------------------------------------------------------*
 | Func:  Preenchimento de campos                                          |
 | Autor: FLávio Bohrer Flôres                                             |
 | Data:  25/09/2019                                                       |
 | Desc:  Função que atualiza os valores de vários campos  de somatórios   |
 | OBS - Esta linkada em validações nos campos  abaixo Listados			   | 
 |   					                                                   |
 *-------------------------------------------------------------------------*/ 

User Function DTI89P(_nVal)
	Local oModel  	:= FWModelActive()
	Local oModelW 	:= oModel:GetModel( 'ZZWMASTER' )
	Local cNum    	:= oModelW:GetValue('ZZW_NUM')
//	Local nQtp		:= 0
	Local nQth 		:= 0
	Local nQta 		:= 0
	//local nQt7 		:= 0
	//Local nQtn 		:= 0
	//Local nQtb		:= 0
	Local W_QPECDF 	:= 0

	

	if _nVal = '13'
				//Origem da SZ6 - 013 - GERAL 
				nQtp := oModelW:GetValue('ZZW_QPEC')
				lOk1 := oModel:SetValue( 'ZZWMASTER', 'ZZW_QPEC', nQtp )
				aSomPec(cNum)		
	
	elseif _nVal = '2'			
				//Origem da SZ6 - 002 - HEREFORD            
				nQth := oModelW:GetValue('ZZW_QPECH')
				lOk1 := oModel:SetValue( 'ZZWMASTER', 'ZZW_QPECH', nQth )
				aSomPec(cNum)
				nQtp := nQth
	Elseif _nVal = '6'
				//Origem da SZ6 - 006 - ANGUS                           
				nQta := oModelW:GetValue('ZZW_QPECA')
				lOk1 := oModel:SetValue( 'ZZWMASTER', 'ZZW_QPECA', nQta )	
				aSomPec(cNum)
				nQtp :=	nQta				
	Elseif _nVal = '14'
				//SZ6_ 014 - Black
				nQtbk := oModelW:GetValue('ZZW_QPECBK')
				lOk1 := oModel:SetValue( 'ZZWMASTER', 'ZZW_QPECBK', nQtbk )
				aSomPec(cNum)
				nQtp := nQtbk
	elseif _nVal = '15'
				//SZ6_ 015 - Dianteiro UY
				nQtdu := oModelW:GetValue('ZZW_QPECDU')
				lOk1 := oModel:SetValue( 'ZZWMASTER', 'ZZW_QPECDU', nQtdu )		
				aSomPec(cNum)
				nQtp := nQtdu
	endif

	_nVSoma := CalcGeral(cNum,oModelW,_nVal,nQtp)
	// Valor total lançado
	nVtdu := oModelW:GetValue('ZZW_QPECGR')
	//alert('Valor somatório: '+cvaltochar(_nVSoma))
	W_QPECDF := nVtdu - _nVSoma

	//	Aqui é salvo o valor da cálculo do valor do cálculo subtraindo a quantidade que veio importada
	lOk1 := oModel:SetValue( 'ZZWMASTER', 'ZZW_QPECDF', W_QPECDF )		
	lOk1 := oModel:SetValue( 'ZZWMASTER', 'ZZW_STATU', 'R' )
	
Return .T.


Static Function aSomPec(cN)
	Local oModel  	:= FWModelActive()
	Local oModelW 	:= oModel:GetModel( 'ZZWMASTER' )
	
	Local nTot    	:= 0
	local nT		:= 0
	local _dData
	
	ZZW->(dbgotop())
	ZZW->(DbSetOrder(1))
	
	if ZZW->(DbSeek(xfilial('ZZW')+alltrim(cN)))
		nTot := 0
		// Criando atualização do campo ZZW_QPECGR = Quant. de Peças Gerais
		_dData := ZZW->ZZW_DATA
		While ZZW->(!EOF())  .AND. _dData = ZZW->ZZW_DATA
													
			nTot += oModelW:GetValue('ZZW_QPEC')					
			nTot +=  oModelW:GetValue('ZZW_QPECH')
			nTot +=  oModelW:GetValue('ZZW_QPECA')
			nTot +=  oModelW:GetValue('ZZW_QPECBK')
			nTot +=  oModelW:GetValue('ZZW_QPECDU')
								
			lOk1 := oModelW:LoadValue( 'ZZW_QPECGR', nTot )	
				
			nT := 0 	
			nTot := 0
			ZZW->(dbSkip())
		Enddo
					
	Endif
	

Return .T.


Static Function  CalcGeral(cN,oMdlW,_nFam,_nQuantc)
	//Local oModel	:= FWModelActive()
	//Local oMdlZZX 	:= oModel:GetModel( 'ZZXDETAIL' )
	//Local _cNUm 	:= cN
	//Local familia 	:= ''
	Local nCont 	:= 0
	Local cQpecw  	:= 0
	Local nT		:= 0
	Local _nT2		:= 0
	Local _nTot 	:= 0
	Local _nRes		:= 0
	//Local lOk2 		:= .T.
	//Local _cNum 	:= ''
	//Local _cCv		:= ''
	Local _nB5CNVP := 0 
	//Local _nVar		:= 0	
	

	_cQuery := " SELECT  ZZX_NUMF,ZZX_NUM,ZZX_TCORTE,ZZX_QPEC,ZZX_FAM"
	_cQuery += " FROM " + RetSQLTab('ZZX') 
	_cQuery += " WHERE" + RetSQLFil('ZZX')
	_cQuery += " AND ZZX_NUMF  ='"+cN+"'"
	_cQuery += " AND " + RetSQLDel('ZZX')
	_cQuery += " ORDER BY ZZX_NUMF,ZZX_FAM,ZZX_NUM"
	
	_cQuery  := ChangeQuery(_cQuery)
  
	//	* Mostrar a consulta 
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	
	
	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"
			
	TMP->(dbGoTop())
	
	While TMP->(!EOF())
		
		//_cChave := xfilial('ZZX')+alltrim(TMP->ZZX_NUM)		
		_nMult := 0
		_nB5CNVP := 0
		//_nboh:= 'Z' 
		ZZY->(dbGoTop())
		ZZY->(DbSetOrder(1))   
		
		//ZZY->(DbSeek(_cChave))		
		IF ZZY->(DbSeek(xfilial('ZZX')+alltrim(TMP->ZZX_NUM)))
		
			While ZZY->(!EOF()) .AND. alltrim(ZZY->ZZY_NUM) = alltrim(TMP->ZZX_NUM)		
					
				
					//  Nova forma de calcular Preenchendo ou não a SB5
					
					_nMult := U_DTI89Calc(alltrim(ZZY->ZZY_COD),ZZY->ZZY_QCAIX)
					cQpecw := cQpecw + _nMult
					
					
				ZZY->(dbSkip()) // Avanca o ponteiro do registro no arquivo
			
			EndDo
		Endif
		
		dbselectarea('ZZX')
		ZZX->(dbsetorder(1))
		if ZZX->(DbSeek(xfilial('ZZX')+alltrim(TMP->ZZX_NUM)))	
			
			reclock('ZZX',.f.)
				ZZX->ZZX_DREST1 := cQpecw
			msunlock()
			
		Endif
		
		_nT2 	:= _nT2 + cQpecw
		nT	 	:= 0 
		cQpecw 	:= 0
		_nMult 	:= 0 		
		nCont++
		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		
	EndDo	
		
	_nTot := 0
	_nRes := 0
	
Return _nT2

/*--------------------------------------------------------------------------*
 | Func:  ImpDados                                                           |
 | Autor: Flávio                                                             |
 | Data:  18/11/2019                                                         |
 | Desc:  Função criada para gerar a interfaçe de buscar informações da ZZV  | 
 |        para a ZZY,ZZX eZZW   											 |
 *--------------------------------------------------------------------------*/
User Function ImpDados()
	Local cMsgAux := ""
    Local aArea := GetArea()
    //DimensÃµes da janela
    Local nJanAltu := 180
    Local nJanLarg := 650
	//Objetos da tela
	 Local oGrpPar
    Local oGrpAco
    Local oBtnSair
    Local oBtnImp
   // Local oBtnRela
   // Local oBtnArq
    Private oSayC, oGetC
    Private oSayD
    Private oGetD := space(8)
	Private oDlgPvt
    Private cGetD :=  date()    
    Private cGetC  := {"Dianteiro","Traseiro","Costela"}
	
	//Mostrando mensagem de atensão ao usar a rotina
    cMsgAux := "<h2>Cuidado!</h2><br>"
    cMsgAux += "Rotina para importação de Solicitações de Produção, será<br>"
    cMsgAux += "executado apenas a importação dos cortes das Solicitações de Produção que estão com o dia Encerrado.<br>"
    cMsgAux += "Após a importação, rode o Fechamento da Produção!<br>"
    MsgAlert(cMsgAux, "Atenção")
    
    //Criando a janela
    DEFINE MSDIALOG oDlgPvt TITLE " Importação da Solicitação de Produção para a ZZX" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        	//Grupo ParÃ¢metros
        @ 003, 003     GROUP oGrpPar TO 060, (nJanLarg/2)     PROMPT "Parâmetros: "         OF oDlgPvt COLOR 0, 16777215 PIXEL         
           @ 013, 006 SAY        oSayD PROMPT "Data Fechamento"          SIZE 060, 007 OF oDlgPvt PIXEL
           @ 010, 070 MSGET      oGetD VAR    cGetD                      SIZE 70,10 OF oDlgPvt PIXEL
            
            oGetD:bHelp := {||    ShowHelpCpo(    "cGetD",;
                                    {"Data de Fechamento da Produção¡ utilizada para importação."},2,{},2)} 
        //Grupo Açôes
        @ 063, 003     GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2)     PROMPT "Ações: "         OF oDlgPvt COLOR 0, 16777215 PIXEL
         	
            //BotÃµes
            @ 070, (nJanLarg/2)-(63*1)  BUTTON oBtnSair PROMPT "Sair"      SIZE 60, 014 OF oDlgPvt ACTION (oDlgPvt:End()) PIXEL         
            @ 070, (nJanLarg/2)-(63*2)  BUTTON oBtnImp  PROMPT "Importar"  SIZE 60, 014 OF oDlgPvt ACTION (Processa({|| gtemp(cGetD) }, "Aguarde...")) PIXEL
          
    ACTIVATE MSDIALOG oDlgPvt CENTERED
       
    RestArea(aArea)
   
Return




 /*--------------------------------------------------------------------------*
 | Func:  gtemp                                                              |
 | Autor: Flávio                                                             |
 | Data:  05/09/2019                                                         |
 | Desc:  Função criada para buscar informações da ZZV para a ZZY,ZZX eZZW   |
 *--------------------------------------------------------------------------*/
 
 Static Function gtemp(_dData)
	
	Local _nID 	:= 0
	Local _nZZUNum := space(6)
	Local _nTcort := 'WWW'
	Local _ncont := 0
	Local _cItem := 0
	Local _cItem2:= 0
	Local _cOrig := 'D'	
	Local _cOdes := ''
	Local _cNum := ''
	Local _cNumF :=''
	Local _cNumF1 :=''
	Local _cNumF2 :=''
	Local _cNumF3 :=''
	Local _dDia := Substr(Dtos(_dData),7,2)
	Local _dMes := Substr(Dtos(_dData),5,2)
	Local _dAno := Substr(Dtos(_dData),1,4)
	Local _dD 	:= _dDia+'/'+_dMes+'/'+_dAno
	Local ProgFam :=''
	//Local nCont := 0
	Local nCpo := 0
	/*
	_dData = Data de Produção
	_cCrori = Corte de Origem a processar   ------ D=Dianteiro  T=Traseiro  C=Costela  ------ 
	*/	
		
	ZZW->(DbSetOrder(2))
	ZZW->(DbGoTop())
	
	While ZZW->(!EOF()) 
		 		
		if  _dData = ZZW->ZZW_DATA .AND.  alltrim(_cOrig) = alltrim(ZZW->ZZW_CORORI)
		
			msgbox('Processo de Importação CANCELADO !! Pois Solicitação de Produção do dia: '+_dD+' - e Tipo de corte já Importados','OPERAÇÃO NEGADA!','STOP')
			Return
			
		Endif
		ZZW->(dbSkip())
	
	Enddo
			
	ZZU->(DbSetOrder(1))
	ZZU->(DbGoTop())		
	While ZZU->(!EOF()) 
		/*  Verifica aqui se o fechamento das solicitações de Produção já foi feito  na ZZU (Solicitação de Produção Encerrada)*/			
		if  _dData = ZZU->ZZU_DATAF
			
			//MsgInfo('Achou data de fechamento !!, ' Importando Informações para a Rotina de Fechamento de Produção' )
			_nZZUNum := ZZU->ZZU_NUM
			_nID++
			exit
							
		Endif	
		ZZU->(dbSkip())
	
	Enddo
		
	/*  Se as solicitações de Produção já estiverem fechadas nessa data - - então o sistema traz as informações para */	
	// Se achou a data de Fechamento ( ZZU->ZZU_DATAF ) então busca ítens na ZZV e gera a tabela temporária	
	
	/* Fazer o sistema Buscar os */
For nCpo := 1 To 3

	If _nID > 0
	
		// buscar por ZZU_NUM e corte de Origem		 
		
		_cQuery := " SELECT B1_CORORI,B1_PROGRAM,B1_DESBSE3,ZZV_NUM,ZZV_COD,ZZV_DESC,SUM(ZZV_QCAIX) AS QCAIX,SUM(ZZV_QPESO) AS QPESO"
		_cQuery += " FROM " + retSqlTab('ZZV')+ ", " + RetSQLTab('SB1')
		_cQuery += " WHERE " + retSqlFil('ZZV') + " AND " + RetSQLFil('SB1') 
		_cQuery += " AND " + retSqlDel('ZZV') + " AND " + RetSQLDel('SB1')
		_cQuery += " AND ZZV_NUM = '" + _nZZUNum + "' "
		_cQuery += " AND ZZV_FILIAL = B1_FILIAL "
		_cQuery += " AND ZZV_COD = B1_COD "
		_cQuery += " AND B1_CORORI = '"+_cOrig+"'"
		_cQuery += " GROUP BY B1_CORORI,B1_PROGRAM,B1_DESBSE3,ZZV_NUM,ZZV_COD,ZZV_DESC"
		_cQuery += " ORDER BY B1_CORORI,B1_PROGRAM,B1_DESBSE3,ZZV_NUM,ZZV_COD,ZZV_DESC"
	  						 				
		_cQuery  := ChangeQuery(_cQuery)
		
		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo
		//Return
				
		If Select("TMP") != 0
			TMP->(dbCloseArea())
		Endif

		TCQUERY _cQuery NEW ALIAS "TMP"
	
		_cItem2 := 1
		_cNumF := GetSx8num('ZZW','ZZW_NUM')
		If nCpo = 1
			_cNumF1 := _cNumF
		Elseif  nCpo = 2
			_cNumF2 := _cNumF
		Elseif  nCpo = 3
			_cNumF3 := _cNumF
		Endif 
		ConfirmSX8()    
		If _cOrig = 'D'
			_cOdes := 'Dianteiro'
		Elseif _cOrig = 'T'
			_cOdes := 'Traseiro'
		Else 
			_cOdes := 'Costela'
		Endif
		
		RecLock("ZZW",.T.)
			ZZW->ZZW_FILIAL := xfilial('ZZW')
			ZZW->ZZW_NUM 	:= _cNumF
			ZZW->ZZW_STATU 	:= 'L'
			ZZW->ZZW_DESC	:= _cOdes
			ZZW->ZZW_DATA 	:= _dData
			ZZW->ZZW_CORORI	:= _cOrig
			ZZW->ZZW_NUMSP  := _nZZUNum
		MsUnLock()
		
		_cNum :=''		
		TMP->(dbsetorder())
		TMP->(dbgotop())
		
		While TMP->(!EOF())
		
			// Se for a Primeira vez do laço
			If _ncont = 0  
				// Grava a ZZX  já separando por "Tipo de Corte" ZZX_TCORTE
								
				_cNum := GetSx8num('ZZX','ZZX_NUM')
				ConfirmSX8()                       
				
				_cItem := 1
				_nTcort := TMP->B1_DESBSE3
				ProgFam := alltrim(TMP->B1_PROGRAM)
				RecLock("ZZX",.T.)
						ZZX->ZZX_FILIAL := ZZU->ZZU_FILIAL
						ZZX->ZZX_NUM 	:= _cNum
						ZZX->ZZX_NUMF	:= _cNumF
						ZZX->ZZX_TCORTE := alltrim(_nTcort)
						ZZX->ZZX_DATA 	:= _dData      
						ZZX->ZZX_CORORI	:= _cOrig	
						ZZX->ZZX_ITEM	:= _cItem2   
						ZZX->ZZX_FAM	:= ProgFam						
				MsUnLock()	
				_cItem2++
							
			else
					
				// Grava a ZZX  já separando por "Tipo de Corte" ZZX_TCORTE. Dados que vêm da 
				ZZU->(DbSeek(xfilial('ZZU') + alltrim(_nZZUNum)))
				
				// Aqui o sistema cria nova ZZX caso sejá "Tipo de corte" e "Programa" diferentes
				if  alltrim(_nTcort) = alltrim(TMP->B1_DESBSE3) .AND. ProgFam = alltrim(TMP->B1_PROGRAM)

						
				else 
					// Deve criar a um novo registro na ZZX
					_nTcort := TMP->B1_DESBSE3
					ProgFam = alltrim(TMP->B1_PROGRAM)
					_cNum :=''
					_cItem := 1
					
					_cNum := GetSx8num('ZZX','ZZX_NUM')
					ConfirmSX8()
					RecLock("ZZX",.T.)
						ZZX->ZZX_FILIAL := ZZU->ZZU_FILIAL
						ZZX->ZZX_NUM 	:= _cNum
						ZZX->ZZX_TCORTE := _nTcort
						ZZX->ZZX_DATA 	:= _dData 
						ZZX->ZZX_CORORI	:= _cOrig	
						ZZX->ZZX_NUMF	:= _cNumF
						ZZX->ZZX_ITEM	:= _cItem2 
						ZZX->ZZX_FAM	:= ProgFam  
					MsUnLock()	
					_cItem2++
					
				Endif	
					
			Endif
			
			_nQcaix  := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(TMP->ZZV_COD),'B1_QCAIX')
			_nPMcaix  := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(TMP->ZZV_COD),'B1_PMCAIX')

			RecLock("ZZY",.T.)
				ZZY->ZZY_FILIAL := '00'
				ZZY->ZZY_NUM 	:= _cNum
				ZZY->ZZY_COD 	:= TMP->ZZV_COD
				ZZY->ZZY_ITEM 	:= _cItem
				ZZY->ZZY_QCAIX 	:= TMP->QCAIX
				ZZY->ZZY_QPESO 	:= TMP->QPESO
				ZZY->ZZY_DESC 	:= TMP->ZZV_DESC
				ZZY->ZZY_TCORTE := _nTcort		
				ZZY->ZZY_CORORI := _cOrig	
				ZZY->ZZY_MARCA	:= alltrim(TMP->B1_PROGRAM) 
				ZZY->ZZY_QPCAIX	:= _nQcaix
				ZZY->ZZY_PMCAIX	:= _nPMcaix
			MsUnLock()		
						
			_nTcort := TMP->B1_DESBSE3	
			_ncont++
			_cItem++
			TMP->(dbSkip())
			
		Enddo
		
		/* atualização de somatório dos campos ....... 
		
			_dData = Data de Produção
			_cCrori = Corte de Origem a processar   ------ D=Dianteiro  T=Traseiro  C=Costela  ------ 
			
			Este Primeiro Somatório precisa ser feito 		
		*/
		
	
	else				
			msgbox('Processo de Importação CANCELADO !! Data sem Solicitações de Produção','OPERAÇÃO NEGADA!','STOP')			
	endif
	
	If nCpo = 1
		_cOrig := 'T'
	Elseif nCpo = 2
		_cOrig := 'C'
	Endif
	
Next nCpo

/* Colocar a Rotina que vai atualizaro campo  ZZW_QPECDF   */
AtQpecdf(_cNumF1,_cNumF2,_cNumF3)

MsgInfo('## Importação e Somatório das Peças Finalizada com Sucesso!! ##', ' Fim da Importação Para Fechamento de Prod.' )


return .T.

Static Function gjf89wfw(_nProd,_dDataABT,_nNvinc,_nDABT,_cDes,_dDtEmb,_cZZWM)
		
	local _cDest  := 'valeska.brum@frigorificosilva.com.br,henrique.jardim@frigorificosilva.com.br,flavio.flores@frigorificosilva.com.br'
	//local _VLD := 'N'
	Local _cMens := ''
	Local _cAtivaR := GetMV('SI_LIBR88')
	
		_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
	
		If  _nNvinc = 999
			IF _cAtivaR = '1'	
				GRVZZU(1,_nProd,_dDataABT,_dDtEmb,_cZZWM)		
			Endif			
			_cMens += 'O Produto :'+_nProd+' - '+_cDes+' Produto não possui previsão de Embalagem Lançada  !!'+ chr(13) + chr(10)				
					
		Elseif _nNvinc > 0
				
			_cMens += 'O Produto :'+_nProd+' - '+_cDes+' esta com '+cValtoChar(_nNvinc)+' Previsões da Enbalagem NÃO vinculada com Prev. da Desossa   !!'+ chr(13) + chr(10)
			
		elseif _nDABT > 0
			
			IF _cAtivaR = '1'	
				GRVZZU(3,_nProd,_dDataABT,_dDtEmb,_cZZWM)
			Endif	
			_cMens += 'O Produto :'+_nProd+' - '+_cDes+' esta com '+cValtoChar(_nDABT)+' Previsões de  Data do Abate diferente da Data lançada na produção das Etiqueta Internas  !!'+ chr(13) + chr(10)
		
		Endif
	
		//alert(' 1895 enviando mensagem...')
	
		_cMens += 'Na Data do Abate de :'+ dtoc(_dDataABT) + chr(13) + chr(10)
		_cMens +=   chr(13) + chr(10)		 
		_cTit  := 'Workflow Produção: Aviso de Produção na Rotina de fechamento de Produção para Embalagem  '
		u_GJF54(_cMens,_cTit,_cDest)

		
return

Static Function GQ()

	_cQuery  := ChangeQuery(_cQuery)

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return


/*  Rotina feita para */
STATIC function GRVZZU(_nTip,_cProd,_dDABT,_dDtEmba,ZZW_NUM) 
	Local _cCodPEs := GETMV('SI_PETQES')
	Local _nPesom := 0
	Local Ret      := 'PA'
	Local _grp		:= ''
	Local _MPPORC	:= ''
	Local _cPTF		:= 'N'
	Local _cCodTF	:= GETMV('SI_TFCOD')  
  
	If _nTip = 1 .OR. _nTip = 3    
		/*Primeiro caso (_nTip = 1) - O  Produto não possui previsão de Embalagem Lançada 
		
		 Segundo Caso (_nTip = 3) - 'O Produto  esta com '+cValtoChar(_nDABT)+' Previsões de  Data do Abate diferente da Data lançada na produção das Etiqueta Internas 
			Aqui acho que devo só vincular as previsões ou refazer uma nova ??? ver com a Valeska
		 */
		_nPesom := pmc(10,alltrim(_cProd))
		_cDesc := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(_cProd),'B1_DESCRED')      
		_cNumP:= BuscaPDes(_dDABT,_cProd,_cPTF,_cCodTF)	                                                           
			
		if alltrim(_cProd) $ _cCodPEs
			Ret := 'ES'
		endif
		
		/*  Regra para quando for produto para porcionados*/
		DbSelectArea('SB1')
		_grp := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(_cProd),'B1_GRUPO')
		if _grp $ '4006/4007'
			_MPPORC  := 'S'			
		endif

		if Empty(substr(_cNumP,11,1))
			_tf := 'N'
		else
			_tf := substr(_cNumP,11,1)
		endif

		_cNumer := GETSX8NUM('SZU','ZU_NUM')  
		ConfirmSX8() 
		RecLock("SZU",.T.)
			SZU->ZU_FILIAL	:= xFilial("SZU")	
			SZU->ZU_NUM		:= _cNumer
			SZU->ZU_DATA	:= ddatabase				
			SZU->ZU_COD		:= alltrim(_cProd)
			SZU->ZU_DESC 	:= _cDesc
			SZU->ZU_PRIORI 	:= 'C'	
			SZU->ZU_CONTEXA := 'N'	
			SZU->ZU_DTRPRO 	:= date()
			SZU->ZU_DTPROD 	:= _dDtEmba
			SZU->ZU_PREDES 	:= substr(_cNumP,1,10)	
			SZU->ZU_NOTIMP 	:= 'A'
			SZU->ZU_TF 		:= _tf	
			SZU->ZU_MDESP	:= 'N'
			SZU->ZU_NUMETQ	:= 1
			SZU->ZU_HORA	:= Time()
			SZU->ZU_USUAR	:= 'Sist.Aut'
			SZU->ZU_QPETIQ	:= 30
			SZU->ZU_LISTETQ	:= 'S'
			SZU->ZU_FECHADO := 'B'						
			SZU->ZU_TIPO 	:= 'P'
			SZU->ZU_OBS 	:= 'Incl. Rot. DTI89 - Fech. Prod. Nr - '+ZZW_NUM
			SZU->ZU_QPCAIX 	:= 10
			SZU->ZU_TOLERA 	:= 10
			SZU->ZU_MPPORC  := _MPPORC
			SZU->ZU_ETIQ 	:= Ret
			SZU->ZU_REPAUT	:= 'S' 
			SZU->ZU_QPPESO 	:= _nPesom
		MsUnLock()    
	
	Elseif _nTip =2 
	
	Endif	
									
return

//função para calcular o peso medio por caixa e o peso medio a produzir
Static function pmc(caixas,Codigo)
	
	if !empty(caixas) .and. !empty(Codigo)
		pmc    := posicione('SB1',1,xfilial('SB1')+Codigo,'B1_PMCAIX')
		pmedio := (caixas * pmc)
		return pmedio
	endif
return 0

Static Function BuscaPDes(_dA,_pro,_Stf,_cTF)

	Local _cN  := ''
	Local _cN2 := ''
	Local _cN3 := '' 
	Local _nCont := 0
	Local _nCont2 := 0
	
	/*
	_dA = Data do Abate
	_pro - Código do Produto que esta sendo impresso
	_Stf = Situação da identificação de TF 
	_cTF = Códigos de produtos identificados como TF que o PCP denomina 
	*/
	If alltrim(_pro) $ alltrim(_cTF)
			
		_Stf := 'S'
						
	Endif
	
	SZ2->(DbGoTop()) 
	SZ2->(dbSetOrder(5))
	
	/* Se previsão for TF então sistema só busca  previsões comclassificação NE*/
	IF _Stf = 'S'
		if !empty(SZ2->(dbSeek(xFilial('SZ2') + DTOS(_dA))))
			
			While SZ2->(!EOF()) .AND.  SZ2->Z2_DATAABT = _dA
				
					if AllTrim(SZ2->Z2_CLASSIF) = 'NE'
						
						_cN3 :=  SZ2->Z2_NUM	
						_cN3 := _cN3+_Stf	
								
						_nCont++
						Exit
					endif
					
					SZ2->(dbSkip())
					
			Enddo
		Endif
		
	Else		
		// Caso a previsão não esteja marcada como TF então busca aqui	
		if !empty(SZ2->(dbSeek(xFilial('SZ2') + DTOS(_dA))))
			
			While SZ2->(!EOF()) .AND.  SZ2->Z2_DATAABT = _dA
								
				if AllTrim(SZ2->Z2_CLASSIF) = 'HK' .AND.  SZ2->Z2_CLASESP= 'S'  
				
					/*  Se tiver previsão que for HK e Classificação especial  */
					_cN :=  SZ2->Z2_NUM
					_nCont++
					Exit
					
				else
					
					/*  Se tiver qualquer Previsão da Desossa */			
					_cN2 :=  SZ2->Z2_NUM
					_nCont2++
					
				Endif			
				SZ2->(dbSkip())
				
			Enddo
			
			If _nCont >0 	
				_cN3 := _cN
				_cN3 := _cN3+_Stf
			elseif _nCont2 >0
				_cN3 := _cN2
				_cN3 := _cN3+_Stf
			endif
		
		Else 
		
			alert('Sem Previsão da Desossa Lançada para esta data de Abate, Entrar em contato com PCP !!')
			
		Endif
	Endif
	
Return alltrim(_cN3)

/* _nQcx = Quantidade de caixas vindas no comercial */
User Function DTI89Calc(_cCodp,_nQcx)
	Local _nQc := 0
	Local B5_CNVPC := 0
	//Local _nTt2 := 0 
	Local _nMult := 0

	_nQc := fBuscaCPO('SB1',1,xfilial('SB1')+_cCodp,'B1_QCAIX')
	B5_CNVPC := fBuscaCPO('SB5',1,xfilial('SB5')+_cCodp,'B5_CNVPC')
	
	if B5_CNVPC > 0
		//_nMult := ((_nQc/B5_CNVPC)*_nQcx) // depois de criado campo fazer essa conta
		_nMult := ((_nQc/B5_CNVPC)*_nQcx) 						
	elseif B5_CNVPC = 0
		
		_nMult := _nQc * _nQcx
		
	Endif
	//_nTt2 := _nTt2 + _nMult

Return _nMult

Static Function AtQpecdf(nf1,nf2,nf3)
	Local nCpo1 := 0
		
		//Alert('2280 - Inicio da atualização - '+'FN1-'+nf1+' - NF2'+nf2+' - NF3'+nf3)
	
		For nCpo1 := 1 To 3
			
			//CalcEsp(cNum,oModelW,_nVal,nQtp)
	
			IF nCpo1 = 1
				_QPECDF    := CalcEsp(nf1)
				
				DbSelectArea('ZZW')
				ZZW->(DbSetOrder(1))
				if ZZW->(DbSeek(xfilial('ZZW') + alltrim(nf1))) 
				
					RecLock("ZZW",.F.)						
						ZZW->ZZW_QPECDF	:= _QPECDF * -1						
					MsUnLock()
				Endif
			Elseif nCpo1 = 2
				_QPECDF := CalcEsp(nf2)
				DbSelectArea('ZZW')
				ZZW->(DbSetOrder(1))
				If ZZW->(DbSeek(xfilial('ZZW') + alltrim(nf2))) 
					
					RecLock("ZZW",.F.)
						ZZW->ZZW_QPECDF	:= _QPECDF * -1					
					MsUnLock()
				Endif
			Elseif nCpo1 = 3
				_QPECDF := CalcEsp(nf3)
				DbSelectArea('ZZW')
				ZZW->(DbSetOrder(1))
				If ZZW->(DbSeek(xfilial('ZZW') + alltrim(nf3))) 
				
					RecLock("ZZW",.F.)
						ZZW->ZZW_QPECDF	:= _QPECDF  * -1					
					MsUnLock()
				Endif
			Endif
		
		
		Next nCpo
		
		/*
		_nVSoma := CalcGeral(cNum,oModelW,_nVal,nQtp)
		lOk1 := oModel:SetValue( 'ZZWMASTER', 'ZZW_QPECDF', W_QPECDF )		
		lOk1 := oModel:SetValue( 'ZZWMASTER', 'ZZW_STATU', 'R' )
		*/
		
Return .T.



Static Function  CalcEsp(cN)
	
	//Local _cNUm 	:= cN
	//Local familia 	:= ''
	Local nCont 	:= 0
	Local cQpecw  	:= 0
	Local nT		:= 0
	Local _nT2		:= 0
	Local _nTot 	:= 0
	Local _nRes		:= 0
	//Local lOk2 		:= .T.
	//Local _cNum 	:= ''	
	//Local _cCv		:= ''
	Local _nB5CNVP  := 0 
	//Local _nVar		:= 0
	//Local _nSUM	 	:= 0	
	

	_cQuery := " SELECT  ZZX_NUMF,ZZX_NUM,ZZX_TCORTE,ZZX_QPEC,ZZX_FAM,ZZX_DREST1"
	_cQuery += " FROM " + RetSQLTab('ZZX') 
	_cQuery += " WHERE" + RetSQLFil('ZZX')
	_cQuery += " AND ZZX_NUMF  ='"+cN+"'"
	_cQuery += " AND " + RetSQLDel('ZZX')
	_cQuery += " ORDER BY ZZX_NUMF,ZZX_FAM,ZZX_NUM"
	
	_cQuery  := ChangeQuery(_cQuery)
	
	//ZZX->ZZX_FAM	:= TMP->B1_FAM     
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo


	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"
			
	TMP->(dbGoTop())
	
	While TMP->(!EOF())
		
		//_cChave := xfilial('ZZX')+alltrim(TMP->ZZX_NUM)		
		_nMult := 0
		_nB5CNVP := 0
		//_nboh:= 'Z' 
		ZZY->(dbGoTop())
		ZZY->(DbSetOrder(1))   
		
		//ZZY->(DbSeek(_cChave))		
		
		IF ZZY->(DbSeek(xfilial('ZZX')+alltrim(TMP->ZZX_NUM)))
		
			While ZZY->(!EOF()) .AND. alltrim(ZZY->ZZY_NUM) = alltrim(TMP->ZZX_NUM)		
					
					_nMult := U_DTI89Calc(alltrim(ZZY->ZZY_COD),ZZY->ZZY_QCAIX)
					cQpecw := cQpecw + _nMult
					
				ZZY->(dbSkip()) // Avanca o ponteiro do registro no arquivo
			
			EndDo
		Endif
		
		dbselectarea('ZZX')
		ZZX->(dbsetorder(1))
		if ZZX->(DbSeek(xfilial('ZZX')+alltrim(TMP->ZZX_NUM)))	
			
			reclock('ZZX',.f.)
				ZZX->ZZX_DREST1 := cQpecw
				ZZX->ZZX_QPEC 	:= cQpecw
			msunlock()
			
		Endif
		
		_nT2 	:= _nT2 + cQpecw
		nT	 	:= 0 
		cQpecw 	:= 0
		_nMult 	:= 0 		
		nCont++
		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		
	EndDo	
		
	_nTot := 0
	_nRes := 0
	
Return _nT2

