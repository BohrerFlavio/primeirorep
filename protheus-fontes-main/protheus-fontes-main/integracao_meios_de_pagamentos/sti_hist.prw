#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWBROWSE.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "FWMVCDEF.CH" 

/*/{Protheus.doc} STI_HIST
Rotina que efetua consulta de histórico de retorno de dados por documento
@author 	Evandro Mugnol
@since 		Dez/2020
@return 	Nil, Função não tem retorno
@obs 		Chamado pela rotina STI_ZK2C
/*/

User Function STI_HIST(_cNumDoc,_cSerDoc) 

	Local aCoors 	 := FWGetDialogSize( oMainWnd ) 
	Local oPanelUp, oFWLayer, oPanelLeft, oBrowseUp, oBrowseDown, oRelacSF2 
	Local cAliasTmpU := GetNextAlias()
	Local aColumnsU	 := []

	Private aRotina  := MenuDef()
	Private oDlgPrinc 


	DEFINE MSDIALOG oDlgPrinc TITLE 'Histórico de retorno de dados por documento' FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL 

	// Cria o conteiner onde serão colocados os browses 
	oFWLayer := FWLayer():New() 
	oFWLayer:Init( oDlgPrinc, .F., .T. ) 

	// Define Painel Superior 
	oFWLayer:AddLine( 'UP', 50, .F. )						// Cria uma "linha" com 50% da tela 
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )			// Na "linha" criada eu crio uma coluna com 100% da tamanho dela 
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )			// Pego o objeto desse pedaço do container 

	// Painel Inferior 
	oFWLayer:AddLine( 'DOWN', 50, .F. )						// Cria uma "linha" com 50% da tela
	oFWLayer:AddCollumn( 'LEFT' , 100, .T., 'DOWN' )		// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	oPanelLeft := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' )	// Pego o objeto do pedaço esquerdo 

	// Os campos da mBrowseUp serão preenchidos pelos campos retornados do result set, ou seja, todos os campos da mBrowseUp deverao estar presentes na query
	// [1] campos presentes no mBrowseUp 	(A)rray
	// [2] campos retornados na query		(C)aracter
	aColumnsU := fColumnsU()

	// Passamos os campos utilizados no mBrowse para obter a query que sera realizada
	cQueryU := fQueryU(aColumnsU[2],_cNumDoc,_cSerDoc)

	// FWmBrowse Superior SF2 - Cabeçalho das Notas Fiscais de Saída 
	oBrowseUp:= FWmBrowse():New() 
	oBrowseUp:SetOwner( oPanelUp ) 
	oBrowseUp:SetDescription( "Documento" ) 
	oBrowseUp:SetColumns( aColumnsU[1] )
	oBrowseUp:SetDataQuery(.T.)
	oBrowseUp:SetQuery( cQueryU )
	oBrowseUp:SetAlias( cAliasTmpU )	
	oBrowseUp:SetUseFilter(.F.)
	oBrowseUp:SetMenuDef( 'STI_HIST' )
	oBrowseUp:SetProfileID( '1' )
	oBrowseUp:ForceQuitButton() 
	// Opcionalmente pode ser desligado a exibição dos detalhes
	oBrowseUp:DisableDetails()
	oBrowseUp:Activate() 


	// FWmBrowse Inferior SD2 - Itens das Notas Fiscais de Saída
	oBrowseDown:= FWMBrowse():New() 
	oBrowseDown:SetOwner( oPanelLeft ) 
	oBrowseDown:SetDescription( 'Histórico' ) 
	oBrowseDown:SetAlias( 'ZK2' ) 
	oBrowseDown:SetOnlyFields( { 'ZK2_CHKID',  'ZK2_CODINT', 'ZK2_NOMINT', 'ZK2_CALLST', 'ZK2_REFID',  'ZK2_STATUS', 'ZK2_DTTRAN', ;
								 'ZK2_DTPGTO', 'ZK2_IDEMCC', 'ZK2_STEMCC', 'ZK2_VLACOB', 'ZK2_CTOKEN', 'ZK2_BANDCC', 'ZK2_CCRED4', 'ZK2_NOMTIT' } )
	oBrowseDown:SetMenuDef( '' ) 
	oBrowseDown:SetProfileID( '2' ) 
	oBrowseDown:ForceQuitButton() 
	// Opcionalmente pode ser desligado a exibição dos detalhes
	oBrowseDown:DisableDetails()
	oBrowseDown:Activate() 

	// Relacionamento entre os Paineis 
	oRelacSF2:= FWBrwRelation():New() 
	oRelacSF2:AddRelation( oBrowseUp , oBrowseDown , { { 'ZK2_FILIAL', 'xFilial( "ZK2" )' }, {'ZK2_REFID','ZK2_REFID'} }) 
	oRelacSF2:Activate() 

    oBrowseDown:UpdateBrowse()
    oBrowseDown:Refresh(.T.)

	Activate MsDialog oDlgPrinc Center 

Return NIL


/*/{Protheus.doc} MenuDef
Cria botão de 'Pesquisar' e 'Visualizar'
@author		Evandro Mugnol
@since		Dez/2020
/*/
Static Function MenuDef()  

	Local aRot := {}   

	ADD OPTION aRot TITLE "Pesquisar"  ACTION "PesqBrw"			 	OPERATION 1 ACCESS 0
	ADD OPTION aRot TITLE "Visualizar" ACTION "VIEWDEF.STI_ZK2C"	OPERATION MODEL_OPERATION_VIEW	 ACCESS 0

Return aRot


/*/{Protheus.doc} fColumnsU
Retorna um array, onde a primeira posicao é um vetor de objetos da classe
FWBrwColumn, esses serao responsaveis pelos campos exibidos no mBrowse.
Já a segunda posicao, retorna os campos que serao retornados na query.
@author  	Evandro Mugnol
@since   	Dez/2020
@return		aRet [1] array com os campos do mBrowse [2] string com os campos que serao retornados na query
/*/
Static Function fColumnsU()

	Local cColumnsU	:= ""
	Local aRet 		:= {}
	Local aColumnsU	:= {}
	Local aArea		:= GetArea()
	Local i
	//Local aAreaSX3	:= SX3->( GetArea() )

	//DbSelectArea("SX3")
	//SX3->( DbSetOrder(1) )
	//SX3->( DbSeek("ZK2") )
	//While SX3->( !Eof() ) .And. SX3->X3_ARQUIVO == "ZK2"
	_cAlias  := "ZK2"
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) $ "ZK2_FILIAL/ZK2_REFID"
			// Cria uma instancia da classe FWBrwColum
			Aadd( aColumnsU, FWBrwColumn():New() )

			// Se for do tipo [D]ata, faz a conversao para o formato DD/MM/AAAA
			cX3Campo := AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO'))
			cColumnsU += (cX3Campo + ",")

			If GetSx3Cache(_aCpoSX3[i], 'X3_TIPO') == "D"
				Atail(aColumnsU):SetData( &("{||Stod(" + cX3Campo + ")}") )
			Else
				Atail(aColumnsU):SetData( &("{||" + cX3Campo + "}") )
			EndIf

			Atail(aColumnsU):SetSize( GetSx3Cache(_aCpoSX3[i], 'X3_TAMANHO') )
			Atail(aColumnsU):SetDecimal( GetSx3Cache(_aCpoSX3[i], 'X3_DECIMAL') )
			Atail(aColumnsU):SetTitle( GetSx3Cache(_aCpoSX3[i], 'X3_TITULO') )
			Atail(aColumnsU):SetPicture( GetSx3Cache(_aCpoSX3[i], 'X3_PICTURE') )

			If GetSx3Cache(_aCpoSX3[i], 'X3_TIPO') == "N"
				Atail(aColumnsU):SetAlign( CONTROL_ALIGN_RIGHT )
			Else
				Atail(aColumnsU):SetAlign( CONTROL_ALIGN_LEFT )
			EndIf
		EndIf
	Next
	//	SX3->( DbSkip() )
	//Enddo

	//RestArea(aAreaSX3)
	RestArea(aArea)

	// Retira a ultima virgula dos campos da query
	cColumnsU := Substr(cColumnsU, 1, Len(cColumnsU) - 1)

	Aadd(aRet, Aclone(aColumnsU) )	// Campos presentes na mBrowse (cada campo é um objeto da classe FWBrwColumn)
	Aadd(aRet, cColumnsU )			// Campos que serao retornados na query

	// Destroi o aColumnsU
	aSize( aColumnsU,0 )
	aColumnsU := Nil

Return aRet


/*/{Protheus.doc} fQueryU
Retorna uma string no formato SQL com as últimas 10 notas. Essa query sera utilizada para montagem do mBrowse.
@param		cColumns, campos do result set da query
@param		cDoc, filtro que sera utilizado na query
@param		cSer, filtro que sera utilizado na query
@author  	Evandro Mugnol
@since   	Dez/2020
@return		cQuery, query que sera utilizada na montagem do mBrowse
/*/
Static Function fQueryU(cColumnsU, cDoc, cSer)

	Local cQuery := ""

	Default cColumnsU := ""

	cQuery := " SELECT TOP 1 ZK2.R_E_C_N_O_ AS XXZK2RECNO," 
	cQuery += cColumnsU
	cQuery += "   FROM " + RetSqlTab("ZK2") 
	cQuery += "  WHERE " + RetSqlFil("ZK2") 
	cQuery += "    AND ZK2_REFID = '" + cDoc + cSer + "' "
	cQuery += "    AND " + RetSqlDel("ZK2")
	//cQuery += "  ORDER BY F2_EMISSAO DESC"

	cQuery := ChangeQuery(cQuery)

Return cQuery
