#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "rwmake.ch"
//Variáveis Estáticas
Static cTitulo := "Ítens do Fechamento de Produção"

/*/{Protheus.doc} Proveio da Rotina Base - STI_RG03
Função para cadastro e manutenção dos Fechamentos de Produção - Cabeçalho (ZZX) e Itens (ZZY) - Modelo 3 em MVC
@author 		Flávio Bohrer Flôres
@since 			Jan/2020
@obs 			Não se pode executar função MVC dentro do fórmulas
/*/

User Function DTI89N()		
	Local aArea := GetArea()
	Local oBrowse
	Private cPerg	:= "DTI89N"
	
	
	if !pergunte(cPerg,.t.)
		Return
	endif
	
	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro de Autor/Interprete
	/* 	SZA - Cabeçalho por  ZZX
		SZ9 - Ítens		por  ZZY
	*/
	//oBrowse:SetAlias("SZA")
	oBrowse:SetAlias("ZZX")

	// Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	
	If !Empty(alltrim(mv_par03)) 
		set filter to ZZX_NUMF >= alltrim(mv_par01) .AND. ZZX_NUMF <= alltrim(mv_par02) .AND. ZZX_TCORTE = alltrim(mv_par03)		
	Else
		set filter to ZZX_NUMF >= alltrim(mv_par01) .AND. ZZX_NUMF <= alltrim(mv_par02)
	Endif
	
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
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"   	  OPERATION 1                   	 ACCESS 0 // OPERATION 1
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.DTI89N" OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 // OPERATION 2
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.DTI89N" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERATION 4
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.DTI89N" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERATION 5
	

Return aRotina


/*====================================================================*
| Função:  		ModelDef                                              |
| Descrição:	Criação do modelo de dados MVC                        |
*====================================================================*/
Static Function ModelDef()

	Local oModel 	:= Nil
	Local oStPai 	:= FWFormStruct(1, "ZZX", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStFilho  := FWFormStruct(1, "ZZY", /*bAvalCampo*/, /*lViewUsado*/)
	Local aZZYRel	:= {}
	Local bCommit   := { |oModel| U_DT89NGrv( oModel ) }

	/* Carregar Função do F10*/
	U_SldFP()
		
	// Criando o modelo e os relacionamentos	
	
	oModel := MPFormModel():New("DTI89NM" , /*bPreValidacao*/, /*bPosValidacao*/,bCommit,/*bCancel*/,/*bLoad*/ )
	oModel:AddFields("ZZXMASTER",/*cOwner*/,oStPai,/*bPreVld*/, /*bPost*/ ,)
	oModel:AddGrid("ZZYDETAIL","ZZXMASTER",oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPreVal - Grid Inteiro*/,/*bPosVal - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  	// cOwner é para quem pertence

	/* Definições dos campos para desativar */
	oStPai:SetProperty('ZZX_ITEM',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))
	oStPai:SetProperty('ZZX_TCORTE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))
	oStPai:SetProperty('ZZX_DATA',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))
	oStPai:SetProperty('ZZX_CORORI',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))
	oStPai:SetProperty('ZZX_QPEC',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))
	oStPai:SetProperty('ZZX_FAM',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))	
	
	aAdd(aZZYRel, {"ZZY_FILIAL",	"ZZX_FILIAL"})
	aAdd(aZZYRel, {"ZZY_NUM",	"ZZX_NUM"})

	oModel:SetRelation("ZZYDETAIL", aZZYRel, ZZY->(IndexKey(1))) 					// IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel("ZZYDETAIL"):SetUniqueLine({"ZZY_ITEM","ZZY_COD"})			
	oModel:SetPrimaryKey({})

	// Setando as descrições
	oModel:SetDescription("Solicitação Fechamento de Produção")
	oModel:GetModel("ZZXMASTER"):SetDescription("Cabeçalho Fechamento de Produção")
	oModel:GetModel("ZZYDETAIL"):SetDescription("Itens Fechamento de Produção")

Return oModel


/*====================================================================*
| Função:  		ViewDef                                                |
| Descrição:	Criação da visão MVC                                   |
*====================================================================*/
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= FWLoadModel("DTI89N")
	Local oStPai	:= FWFormStruct(2, "ZZX")
	Local oStFilho	:= FWFormStruct(2, "ZZY")

	// Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	
	// Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField("VIEW_ZZX",oStPai,"ZZXMASTER")
	oView:AddGrid("VIEW_ZZY",oStFilho,"ZZYDETAIL")

	// Incrementa o campo ITEM
	oView:AddIncrementField("VIEW_ZZY", "ZZY_ITEM")

	// Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox("CABEC",65)
	oView:CreateHorizontalBox("GRID", 35)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// Amarrando a view com as box
	oView:SetOwnerView("VIEW_ZZX","CABEC")
	oView:SetOwnerView("VIEW_ZZY","GRID")

	// Habilitando título
	oView:EnableTitleView("VIEW_ZZX","Cabeçalho da Solicitação de Compra")
	oView:EnableTitleView("VIEW_ZZY","Itens da Solicitação de Compra")

	//Remove os campos de Código do Artista e CD
	/* Pai */
	oStPai:RemoveField('ZZX_DREST1')
	
	/* Filho */
	oStFilho:RemoveField('ZZY_NUM')  
	oStFilho:RemoveField('ZZY_CORORI')
	oStFilho:RemoveField('ZZY_TCORTE')
	oStFilho:RemoveField('ZZY_MARCA')
	oStFilho:RemoveField('ZZY_ITEM')
	
	
	
Return oView


/*/{Protheus.doc} RG03Leg
Função para mostrar a legenda da rotina em MVC
@author 		Evandro Mugnol
@since 		Set/2017
/*/

User Function DTI89NLeg()

	Local aLegenda := {}

	// Monta as cores
	AADD(aLegenda,{"RED",		"Solicitação Incompleta"})
	AADD(aLegenda,{"YELLOW",	"Solicitação Completa"})
	AADD(aLegenda,{"GREEN",		"Solicitação Atendida"})

	BrwLegenda("Manutenção de Solicitação de Compra de Gado", "Legenda", aLegenda)

Return


/*/{Protheus.doc} STATLeg
Função para mostrar a legenda da rotina em MVC
@author 		Evandro Mugnol
@since 		Set/2017
/*/

//User Function STATLeg(cNumSC)
/*  Não estou usando esta rotina no momento*/
User Function STDTLeg(cNumSC)

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
@author 		Evandro Mugnol
@since 		Set/2017
/*/

//User Function RG03Grv( oModel ) 
User Function DT89NGrv( oModel ) 
	Local cItem	  	:= StrZero(0,TamSX3("ZZY_ITEM")[1])
	Local nOpc    	:= oModel:GetOperation()
	Local oStPai  	:= oModel:GetModel("ZZXMASTER")
	Local cNum  	:= oStPai:GetValue("ZZX_NUM")
	Local cIt  		:= oStPai:GetValue("ZZX_ITEM")
	Local cNumF  	:= oStPai:GetValue("ZZX_NUMF")    
	Local cData  	:= oStPai:GetValue("ZZX_DATA")  
	

	// Efetuar a gravação de outros dados em entidade que não são do model
	FWFormCommit( oModel )
	
	/*  Refazer a somatório após gravar Alterações */	
	U_DTI89NC(cNum)
	

Return .T.



/*-------------------------------------------------------------------------*
 | Func:  Peso Médio Caixa                                                 |
 | Autor: FLávio Bohrer Flôres                                             |
 | Data:  23/09/2019                                                       |
 | Desc:  Função que recalcula o Peso médio da caixa via gatilho ZZY_QCAIX |
 *-------------------------------------------------------------------------*/                                                                    
User Function DTI89Npmc()

	Local oModel    := FWModelActive()
	Local oModelZZY := oModel:GetModel( 'ZZYDETAIL' )
	Local cCod     := oModelZZY:GetValue('ZZY_COD')
	Local cQcaix   := oModelZZY:GetValue('ZZY_QCAIX')
	Local nSomap   := oModelZZY:GetValue('ZZY_QPCAIX')
	Local cNum     := oModelZZY:GetValue('ZZY_NUM')
	pmedio := 0

	SB1->(dbsetorder(1))
	if SB1->(Dbseek(xfilial('SB1')+cCod))
	
		pmc    := SB1->B1_PMCAIX
		pmedio := (cQcaix * pmc)
		
	endif	
	nSomap := cQcaix * nSomap
	
return pmedio



/*-------------------------------------------------------------------------*
 | Func:  Peso Médio Caixa                                                 |
 | Autor: FLávio Bohrer Flôres                                             |
 | Data:  23/09/2019                                                       |
 | Desc:  Função que recalcula o Peso médio da caixa via gatilho ZZY_QCAIX |
 *-------------------------------------------------------------------------*/    
 // Calculo da quantidade de Peças utilizadas                                                                
User Function DTI89SUG(nQpc)

	Local oMl  	:= FWModelActive()
	Local oModelX  	:= FWModelActive()
	Local oMX 		:= oModelX:GetModel( 'ZZXMASTER' )
	Local cNum    	:= oMX:GetValue('ZZX_NUMF')
	Local _nFAM   	:= oMX:GetValue('ZZX_FAM')
	Local sld 		:= 0 
	Local sld2 		:= 0 
	Local nQth		:= 0 
	Local nQtp		:= 0 
	Local nQta		:= 0 
	Local nQtbk		:= 0 
	Local nQtdu		:= 0 
	Local oModel := FWModelActive()
	Local oModelZZY := oModel:GetModel( 'ZZYDETAIL' )
	Local nZZYNum := oModelZZY:GetValue('ZZY_NUM')
		
	
	IF _nFAM = '002'
		
		ZZW->(dbsetorder(1))
		ZZW->(dbgotop())
		if 	ZZW->(DbSeek(xfilial('ZZW') + alltrim(cNum))) 
			
			sld2 := somaq(nZZYNum)			
			nQth := ZZW->ZZW_QPECH		
			sld :=  nQth - nQpc - sld2
			lOk1 := oModel:SetValue( 'ZZYDETAIL', 'ZZY_QPECS', sld )
		

		endif	
	elseif _nFAM = '013'
		
		nQtp := oModel:GetValue('ZZW_QPEC')
		sld :=  nQtp - cQcaix
		lOk1 := oModel:SetValue( 'ZZYDETAIL', 'ZZY_QPECS', sld )
				
	Elseif _nFAM = '006'
		
		nQta := oModelW:GetValue('ZZW_QPECA')
		sld :=  nQta - cQcaix
		lOk1 := oModel:SetValue( 'ZZYDETAIL', 'ZZY_QPECS', sld )
		
	Elseif _nFAM = '014'	
		
		nQtbk := oModelW:GetValue('ZZW_QPECBK')
		sld :=  nQtbk - cQcaix
		lOk1 := oModel:SetValue( 'ZZYDETAIL', 'ZZY_QPECS', sld )
		
	Elseif _nFAM = '015'
	
		nQtdu := oModelW:GetValue('ZZW_QPECDU')
		sld :=  nQtdu - cQcaix
		lOk1 := oModel:SetValue( 'ZZYDETAIL', 'ZZY_QPECS', sld )
	else

		// Aqui vai cair quando não tiver familia configurada no produto 	Dai por enquanto não faz nada
    	// Estão incluindo caixas e diminuindo do saldo sugerido
		//lOk1 := oModelX:SetValue( 'ZZYDETAIL', 'ZZY_QPECS', sld )
			
	Endif
	*/

return 


/*-------------------------------------------------------------------------*
 | Func:  Peso Médio Peça                                                  |
 | Autor: FLávio Bohrer Flôres                                             |
 | Data:  23/09/2019                                                       |
 | Desc:  Função que recalcula o Peso médio do Peso via gatilho ZZY_QPESO  |
 *-------------------------------------------------------------------------*/ 
User Function DTI89Ncmp()
	Local oModel := FWModelActive()
	Local oModelZZY := oModel:GetModel( 'ZZYDETAIL' )
	Local cProd := oModelZZY:GetValue('ZZY_COD')
	Local cQpeso := oModelZZY:GetValue('ZZY_QPESO')
	
	Local oModel := FWModelActive()
	Local oModelZZX := oModel:GetModel( 'ZZXMASTER' )
	Local cNum := oModelZZX:GetValue('ZZX_NUM')
	caixas := 0

	SB1->(dbsetorder(1))
	if SB1->(Dbseek(xfilial('SB1')+cProd))
		
		cmp   := SB1->B1_PMCAIX
		ncaix := round(cQpeso/cmp,0)
		return ncaix
		
	endif

return caixas


/*--------------------------------------------------------------------------------*
 | Func:  Preencher Campos da ZZY                                         		  |
 | Autor: FLávio Bohrer Flôres                                            		  |
 | Data:  03/01/2020                                                       		  |
 | Desc:  Função que preenche os campos padrões da ZZY conf.Cabec. de Fechamento  |
 *--------------------------------------------------------------------------------*/ 
User Function DTI89NY()
		
	Local oModel := FWModelActive()
	Local oModel2 := FWModelActive()
	Local oModelZZX := oModel:GetModel( 'ZZXMASTER' )
	Local cNum := oModelZZX:GetValue('ZZX_NUM')
	Local cTcorte := oModelZZX:GetValue('ZZX_TCORTE')
	Local cCorori := oModelZZX:GetValue('ZZX_CORORI')
	Local cMarca := oModelZZX:GetValue('ZZX_FAM')


	lOk1 := oModel2:SetValue( 'ZZYDETAIL', 'ZZY_TCORTE', cTcorte )
	lOk1 := oModel2:SetValue( 'ZZYDETAIL', 'ZZY_CORORI', cCorori )
	lOk1 := oModel2:SetValue( 'ZZYDETAIL', 'ZZY_MARCA', cMarca )

	
return cNum





/*
User Function DTI89INC()
		
		Alert('Entrou na Inclusão')
	
return .T.

*/


/* Função para fazer o somatório do campo de sugestão de peças que ainda tem */
Static Function somaq(nZZYNum)
	Local soma := 0
	
	//alert(nZZYNum)
	ZZY->(DbSetOrder(1))
	ZZY->(DbGoTop())
	if ZZY->(DbSeek(xfilial('ZZY') + alltrim(nZZYNum))) 
		While ZZY->(!EOF()) .AND. ZZY->ZZY_NUM = nZZYNum
				//alert(ZZY->ZZY_QPECS)
				soma := soma + ZZY->ZZY_QPECS			
				//soma := soma + _nTot2						
				ZZY->(dbSkip())
			
		Enddo
	Endif
//	alert(soma)
Return soma		



/*
_cNF = ZZX_NUM

Função para 
*/
User Function DTI89NC(_cNF)

	Local _cNum 	:= ''
	Local _nTot 	:= 0
	Local _nTot2 	:= 0
	Local _nTot3 	:= 0
	Local _nTot4 	:= 0
	Local _nTot5	:= 0
	Local _nMult 	:= 0
	Local _nQcaix 	:= 0
	Local cMsgAux   := ''
	Local _cNumF    := ''
	
	//alert('Linha 447 - ZZX Numero:'+_cNF)
	ZZX->(DbSetOrder(1))
	ZZX->(DbGoTop())
	
	
	IF 	!Empty(ZZX->(DbSeek(xfilial('ZZX')+_cNF)))
		
		ZZY->(DbSetOrder(1))
		ZZY->(DbGoTop())
		ZZY->(DbSeek(xfilial('ZZY')+_cNF))
		_cNumF := ZZX->ZZX_NUMF
	
		While ZZY->(!EOF()) .AND. alltrim(ZZY->ZZY_NUM) = alltrim(_cNF)
			
			_nTot2 := U_DTI89Calc(alltrim(ZZY->ZZY_COD),ZZY->ZZY_QCAIX)			
			_nTot4 := _nTot4 + _nTot2
						
			ZZY->(dbSkip())
		
		Enddo
				
		//alert('Linha 474 - Quant. Peças:'+cValToChar(_nTot4))
		RecLock("ZZX",.F.)							
			ZZX->ZZX_QPEC := _nTot4						
		MsUnLock()
		
		/*Novo*/
		ZZX->(DbSetOrder(3))
		ZZX->(DbGoTop())
		ZZX->(DbSeek(xfilial('ZZX')+_cNumF))
		While ZZX->(!EOF()) .AND. alltrim(ZZX->ZZX_NUMF) = alltrim(_cNumF)
			
			_nTot3 := _nTot3 + ZZX->ZZX_QPEC
			ZZX->(dbSkip())
			
		Enddo
		
		//alert('linha 490 - Num:'+_cNumF+' ZZW_QPECDF -'+cValtoChar(_nTot3))
		ZZW->(DbSetOrder(1))
		ZZW->(DbGoTop())
		ZZW->(DbSeek(xfilial('ZZW')+_cNumF))
		RecLock("ZZW",.F.)							
			ZZW->ZZW_QPECDF := _nTot3 * -1							
		MsUnLock()
		
	Endif
	
Return .T.




/*----------------------------------------------------------------------------------------*
 | Func:  Somatório para a Sugestão de Peças a Produzir			           		 		  |
 | Autor: FLávio Bohrer Flôres                                            				  |
 | Data:  01/02/2020                                                       				  |
 | Desc:  Função que efetua somente o somatório para mostrar saldo em tela      		  |
 | OBS :  Função só mostra o somatório atual ,não grava   (DTI89ST = Somatório para tela  |
 *---------------------------------------------------------------------------------------*/ 
User Function DTI89ST(_cNF)

	Local _cNum 	:= ''
	Local _nTot 	:= 0
	Local _nTot2 	:= 0
	Local _nTot3 	:= 0
	Local _nTot4 	:= 0
	Local _nTot5	:= 0
	Local _nMult 	:= 0
	Local _nQcaix 	:= 0
	Local cMsgAux   := ''
	Local _cNumF    := ''
	Local ZZX_QPEC := 0 
	
	//alert('Linha 447 - ZZX Numero:'+_cNF)
	ZZX->(DbSetOrder(1))
	ZZX->(DbGoTop())
	
	
	IF 	!Empty(ZZX->(DbSeek(xfilial('ZZX')+_cNF)))
		
		ZZY->(DbSetOrder(1))
		ZZY->(DbGoTop())
		ZZY->(DbSeek(xfilial('ZZY')+_cNF))
		_cNumF := ZZX->ZZX_NUMF
		
		While ZZY->(!EOF()) .AND. alltrim(ZZY->ZZY_NUM) = alltrim(_cNF)
			
			//alert('Linha 458 - ZZY_COD Produto'+ZZY->ZZY_COD)
			//alert('Produto:-'+alltrim(ZZY->ZZY_COD)+' - Quantidade:'+cValToChar(ZZY->ZZY_QCAIX))
			_nTot2 := U_DTI89Calc(alltrim(ZZY->ZZY_COD),ZZY->ZZY_QCAIX)			
			_nTot4 := _nTot4 + _nTot2
						
			ZZY->(dbSkip())
		
		Enddo
				
		ZZX_QPEC := _nTot4
		
		/*Novo*/
		ZZX->(DbSetOrder(3))
		ZZX->(DbGoTop())
		ZZX->(DbSeek(xfilial('ZZX')+_cNumF))
		While ZZX->(!EOF()) .AND. alltrim(ZZX->ZZX_NUMF) = alltrim(_cNumF)
			
			// Aqui vai buscar todos os valores da ZZX menos o que esta sendo sugerido a alteração 
			if _cNF <> alltrim(ZZX->ZZX_NUM)
				_nTot3 := _nTot3 + ZZX->ZZX_QPEC
			Endif
			
			ZZX->(dbSkip())
			
		Enddo
		
		ZZX_QPEC := ZZX_QPEC + _nTot3

	Endif
	
Return ZZX_QPEC


/* SldFP = Saldo de Fechamento de Produção*/

User Function SldFP()

	
	Set Key VK_F10 TO u_dti89nS()  
	
	
Return 

User Function dti89nS()

	Local oModel 	:= FWModelActive()
	Local oModelZZY := oModel:GetModel( 'ZZYDETAIL' )
	Local cCod 		:= oModelZZY:GetValue('ZZY_COD')
	Local cQcaix 	:= oModelZZY:GetValue('ZZY_QCAIX')
	Local nSomap 	:= oModelZZY:GetValue('ZZY_QPCAIX')
	Local nSum 	 	:= 0
	Local nSald		:= 0
	Local cNum 		:= oModelZZY:GetValue('ZZY_NUM')
	Local _cDesc 	:= 'Sugestão de Peças a Produzir'
	Local _nPsldL 	:= 0
	Local saldoG 	:= 0
	Local IntQ	 	:= 0
	Local saldoH 	:= 0
	Local oFont    	:= tFont():New("courier new",,-16,,.t.,,,,)
	Local oFont2    := tFont():New("courier new",,-12,,.t.,,,,)
	
	// _nPsldL =  Pré Saldo buscado das solicitações de produção do Comercial 
	//alert('zzY_NUM-'+cNum+'-zzY_COD-'+cCod)
	
	/* Tela */
	
	IntQ 	:= fBuscaCpo('ZZX',1,xFilial('ZZX') + alltrim(cNum),'ZZX_NUMF')	
	saldoG 	:= fBuscaCpo('ZZW',1,xFilial('ZZW') + alltrim(IntQ),'ZZW_QPEC') 
	saldoH 	:= fBuscaCpo('ZZW',1,xFilial('ZZW') + alltrim(IntQ),'ZZW_QPECH') 
	saldoA 	:= fBuscaCpo('ZZW',1,xFilial('ZZW') + alltrim(IntQ),'ZZW_QPECA')
	saldoBK := fBuscaCpo('ZZW',1,xFilial('ZZW') + alltrim(IntQ),'ZZW_QPECBK')
	saldoDU := fBuscaCpo('ZZW',1,xFilial('ZZW') + alltrim(IntQ),'ZZW_QPECDU')
	nSum 	:= fBuscaCpo('ZZW',1,xFilial('ZZW') + alltrim(IntQ),'ZZW_QPECGR')
	_QPECDF := fBuscaCpo('ZZW',1,xFilial('ZZW') + alltrim(IntQ),'ZZW_QPECDF')
	
	DEFINE MSDIALOG oSld TITLE _cDesc from 000,000 To 200,380 OF oMainWnd PIXEL
	
		
	oSay100 := tSay():New(010,075,{|| '<font size="2" color="green"><b>Sug. |   Soma Sug. |   Saldo</b></font><br/>' }	,oSld,,oFont,,,,.T.,,,350,30,,,,,,.T.)		
	
	//alert('Solic.Comercial-'+str(nSum))
	@ 010,060 SAY '' Object oSay100
	
	// Primeira coluna
	@ 020,030 SAY  'Qt. Geral'    Object oSay1
	@ 030,030 SAY  'Hereford'     Object oSay2
	@ 040,030 SAY  'Ângus'        Object oSay3
	@ 050,030 SAY  'Black'        Object oSay4
	@ 060,030 SAY  'Diant.UY'     Object oSay5
	
	// Segunda coluna
	@ 020,105 SAY  ''        Object oSay6
	
	// Terceira coluna
	@ 020,125 SAY  ''        Object oSay11
	
	//Qt.Geral
	if saldoG > 0

			oSay1 := tSay():New(020,035,{|| PADR(STR(saldoG),20) },oSld,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
			_nPsldL := _nPsldL + saldoG
	else			
			
			oSay1 := tSay():New(020,035,{|| PADR(STR(saldoG),20) },oSld,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
			_nPsldL := _nPsldL +  saldoG							
	Endif
	//Hereford
	if saldoH > 0
					
			oSay2 := tSay():New(030,035,{|| PADR(STR(saldoH),20) },oSld,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)			
			_nPsldL :=  _nPsldL +  saldoH
			
	else			
			oSay2 := tSay():New(030,035,{|| PADR(STR(saldoH),20) },oSld,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,350,30)
			_nPsldL := _nPsldL +  saldoH	
									
	Endif
	// Ângus
	if saldoA > 0					

			oSay3 := tSay():New(040,035,{|| PADR(STR(saldoA),20) },oSld,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
			_nPsldL :=  _nPsldL +  saldoA
	else						
			oSay3 := tSay():New(040,035,{|| PADR(STR(saldoA),20) },oSld,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,350,30)
			_nPsldL := _nPsldL +  saldoA							
	Endif
	// Black
	if saldoBK > 0					
			oSay4 := tSay():New(050,035,{|| PADR(STR(saldoBK),20) },oSld,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
			_nPsldL :=  _nPsldL +  saldoBK
	else			
			
			oSay4 := tSay():New(050,035,{|| PADR(STR(saldoBK),20) },oSld,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,350,30)
			_nPsldL := _nPsldL +  saldoBK							
	Endif
	// DU
	if saldoDU > 0		
						
			oSay5 := tSay():New(060,035,{|| PADR(STR(saldoDU),20) },oSld,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
			_nPsldL :=  _nPsldL +  saldoDU
	else			
			
			oSay5 := tSay():New(060,035,{|| PADR(STR(saldoDU),20) },oSld,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
			_nPsldL := _nPsldL +  saldoDU							
	Endif
				
	oSay6 := tSay():New(070,70,{|| PADR(STR(nSum),20) },oSld,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
			
	if nSald >0
				
		oSay11 := tSay():New(070,115,{||  PADR(STR(_QPECDF),20) },oSld,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
	Else
			
		oSay11 := tSay():New(070,115,{|| PADR(STR(_QPECDF),20) },oSld,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,350,30)
	Endif
		
	@ 083,146 BMPBUTTON TYPE 1 ACTION oSld:end() Object Obtn1
		
	ACTIVATE MSDIALOG oSld

Return .T.


User Function dti89T1()
	Local oModel := FWModelActive()
	
	Local oModelZZX := oModel:GetModel( 'ZZXMASTER' )
	Local _dData := oModelZZX:GetValue('ZZX_DATA')
	//alert('Entrou na parte de atualizar o saldo do campo da ZZX para atualizar o campo -- ZZW_QPECDF ---....')
	//gtemp(_dData)// do fonte DTI89
	alert(_dData)
	
	//gtemp(_dData)
Return .T.
 