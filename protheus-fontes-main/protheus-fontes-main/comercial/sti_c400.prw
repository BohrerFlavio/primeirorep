#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWBROWSE.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "FWMVCDEF.CH" 

/*/{Protheus.doc} STI_C400
Rotina que efetua consulta das notas dos últimos 10 dias a partir do pré-pedido
@author 	Evandro Mugnol
@since 		27/09/2018
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_C400(_cCli,_cLoj) 

	Local aCoors 	 := FWGetDialogSize( oMainWnd ) 
	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseDown, oRelacSF2, oRelacSD2 
	Local cAliasTmpU := GetNextAlias()
	Local aColumnsU	 := []

	Private oDlgPrinc 

	DEFINE MSDIALOG oDlgPrinc TITLE 'Consulta 10 Últimas Notas Fiscais do Cliente' FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL 

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
	cQueryU := fQueryU(aColumnsU[2],_cCli,_cLoj)

	// FWmBrowse Superior SF2 - Cabeçalho das Notas Fiscais de Saída 
	oBrowseUp:= FWmBrowse():New() 
	oBrowseUp:SetOwner( oPanelUp ) 
	oBrowseUp:SetDescription( "Cabeçalho das Notas Fiscais" ) 
	oBrowseUp:SetColumns( aColumnsU[1] )
	oBrowseUp:SetDataQuery(.T.)
	oBrowseUp:SetQuery( cQueryU )
	oBrowseUp:SetAlias( cAliasTmpU )	
	oBrowseUp:SetUseFilter(.F.)
	oBrowseUp:SetMenuDef( 'STI_C400' )
	oBrowseUp:SetProfileID( '1' )
	oBrowseUp:ForceQuitButton() 
	// Opcionalmente pode ser desligado a exibição dos detalhes
	oBrowseUp:DisableDetails() 
	oBrowseUp:Activate() 


	// FWmBrowse Inferior SD2 - Itens das Notas Fiscais de Saída
	oBrowseDown:= FWMBrowse():New() 
	oBrowseDown:SetOwner( oPanelLeft ) 
	oBrowseDown:SetDescription( 'Itens das Notas Fiscais' ) 
	oBrowseDown:SetAlias( 'SD2' ) 
	oBrowseDown:SetOnlyFields( { 'D2_ITEM',  'D2_COD',     'D2_DESCRI', 'D2_UM',     'D2_QUANT',  'D2_PRCVEN', 'D2_TOTAL', ;
	'D2_SEGUM', 'D2_QTSEGUM', 'D2_PRECAR', 'D2_PREPED', 'D2_PEDIDO', 'D2_ITEMPV' } )
	oBrowseDown:SetMenuDef( '' ) 
	oBrowseDown:SetProfileID( '2' ) 
	oBrowseDown:ForceQuitButton() 
	// Opcionalmente pode ser desligado a exibição dos detalhes
	oBrowseDown:DisableDetails() 
	oBrowseDown:Activate() 


	// Relacionamento entre os Paineis 
	oRelacSF2:= FWBrwRelation():New() 
	oRelacSF2:AddRelation( oBrowseUp , oBrowseDown , { { 'D2_FILIAL', 'xFilial( "SD2" )' }, {'D2_DOC','F2_DOC'} }) 
	oRelacSF2:Activate() 

	Activate MsDialog oDlgPrinc Center 

Return NIL


/*/{Protheus.doc} MenuDef
Cria botão de 'Visualizar' para consulta da nota posicionada no browse.
@author		Evandro Mugnol
@since		27/09/2018
/*/
Static Function MenuDef()  

	Local aRot := {}   

	aAdd( aRot, { "Visualizar",	"U_ConsNF(XX_F2RECNO)", 0, 2, 0, .F. } )	

Return aRot


/*/{Protheus.doc} ConsNF
Funcao que faz a consulta da nota fiscal posicionada no browse.
@author  	Evandro Mugnol
@since   	27/09/2018
@param		nRecnoSF2, R_E_C_N_O_ do documento original
@return		Nil
/*/
User Function ConsNF(nRecnoSF2)

	Local aArea      := GetArea()
	Local aAreaSA1   := SA1->(GetArea())
	Local aAreaSA2   := SA2->(GetArea())
	Local aAreaSD2   := SD2->(GetArea())
	Local cAliasSD2  := "SD2"
	Local cQuery     := ""

	Default nRecnoSF2 := 0		// SF2.R_E_C_N_O_

	// A query retorna o R_E_C_N_O_ da SF2, entao utilizamos ele para fazer o posicionamento
	SF2->( DbGoTo(nRecnoSF2) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a pilha da funcao fiscal                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisSave()
	MaFisEnd()

	dbSelectArea("SD2")
	dbSetOrder(3)

	cAliasSD2 := GetNextAlias()

	cQuery := "SELECT D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO,R_E_C_N_O_ SD2RECNO "
	cQuery += "  FROM "+RetSqlName("SD2")+" SD2 "
	cQuery += " WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
	cQuery += "SD2.D2_DOC='"+SF2->F2_DOC+"' AND "
	cQuery += "SD2.D2_SERIE='"+SF2->F2_SERIE+"' AND "
	cQuery += "SD2.D2_CLIENTE='"+SF2->F2_CLIENTE+"' AND "
	cQuery += "SD2.D2_LOJA='"+SF2->F2_LOJA+"' AND "
	cQuery += "SD2.D2_TIPO='"+SF2->F2_TIPO+"' AND "
	cQuery += "SD2.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(SD2->(IndexKey()))

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)

	While !Eof() .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
	SF2->F2_DOC == (cAliasSD2)->D2_DOC .And.;
	SF2->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
	SF2->F2_CLIENTE == (cAliasSD2)->D2_CLIENTE .And.;
	SF2->F2_LOJA == (cAliasSD2)->D2_LOJA

		If SF2->F2_TIPO == (cAliasSD2)->D2_TIPO
			SD2->(MsGoto((cAliasSD2)->SD2RECNO))
			A920NFSAI("SD2",SD2->(RecNo()),0)
			Exit
		EndIf

		dbSelectArea(cAliasSD2)
		dbSkip()
	EndDo

	dbSelectArea(cAliasSD2)
	dbCloseArea()
	dbSelectArea("SD2")	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a pilha da funcao fiscal                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisRestore()
	RestArea(aAreaSD2)
	RestArea(aAreaSA2)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return


/*/{Protheus.doc} fColumnsU
Retorna um array, onde a primeira posicao é um vetor de objetos da classe
FWBrwColumn, esses serao responsaveis pelos campos exibidos no mBrowse.
Já a segunda posicao, retorna os campos que serao retornados na query.
@author  	Evandro Mugnol
@since   	27/09/2018
@return		aRet [1] array com os campos do mBrowse [2] string com os campos que serao retornados na query
/*/
Static Function fColumnsU()

	Local aArea		:= GetArea()
	Local cColumnsU	:= ""
	Local aRet 		:= {}
	Local aColumnsU	:= {}
	Local i
	//Local aAreaSX3	:= SX3->( GetArea() )

	//DbSelectArea("SX3")
	//SX3->( DbSetOrder(1) )
	//SX3->( DbSeek("SF2") )
	//While SX3->( !Eof() ) .And. SX3->X3_ARQUIVO == "SF2"
	//	If AllTrim(SX3->X3_CAMPO) $ "F2_FILIAL/F2_DOC/F2_SERIE/F2_CLIENTE/F2_LOJA/F2_EMISSAO/F2_COND/F2_EST/F2_VALBRUT/F2_MENNOTA/F2_NUMPEDV/F2_CHVNFE/F2_TIPO"
			// Cria uma instancia da classe FWBrwColum
	//		Aadd( aColumnsU, FWBrwColumn():New() )

			// Ce for do tipo [D]ata, faz a conversao para o formato DD/MM/AAAA
	//		cX3Campo := AllTrim(SX3->X3_CAMPO)
	//		cColumnsU += (cX3Campo + ",")

	//		If SX3->X3_TIPO == "D"
	//			Atail(aColumnsU):SetData( &("{||Stod(" + cX3Campo + ")}") )
	//		Else
	//			Atail(aColumnsU):SetData( &("{||" + cX3Campo + "}") )
	//		EndIf

	//		Atail(aColumnsU):SetSize( SX3->X3_TAMANHO )
	//		Atail(aColumnsU):SetDecimal( SX3->X3_DECIMAL )
	//		Atail(aColumnsU):SetTitle( X3Titulo() )
	//		Atail(aColumnsU):SetPicture( SX3->X3_PICTURE )

	//		If SX3->X3_TIPO == "N"
	//			Atail(aColumnsU):SetAlign( CONTROL_ALIGN_RIGHT )
	//		Else
	//			Atail(aColumnsU):SetAlign( CONTROL_ALIGN_LEFT )
	//		EndIf
	//	EndIf
	//	SX3->( DbSkip() )
	//Enddo

	_cAlias  := "SF2"
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	_cAcols  := "F2_FILIAL/F2_DOC/F2_SERIE/F2_CLIENTE/F2_LOJA/F2_EMISSAO/F2_COND/F2_EST/F2_VALBRUT/F2_MENNOTA/F2_NUMPEDV/F2_CHVNFE/F2_TIPO"
	For i := 1 To Len(_aCpoSX3)
		If(X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) .And. AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) $ _cAcols)
			// Cria uma instancia da classe FWBrwColum
			Aadd( aColumnsU, FWBrwColumn():New() )

			// Ce for do tipo [D]ata, faz a conversao para o formato DD/MM/AAAA
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
			Atail(aColumnsU):SetPicture( GetSx3Cache(_aCpoSX3[i], 'X3_PICTURE'))

			If GetSx3Cache(_aCpoSX3[i], 'X3_TIPO') == "N"
				Atail(aColumnsU):SetAlign( CONTROL_ALIGN_RIGHT )
			Else
				Atail(aColumnsU):SetAlign( CONTROL_ALIGN_LEFT )
			EndIf
		Endif
	Next i

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
@param		cCliente, filtro que sera utilizado na query
@param		cLojaCli, filtro que sera utilizado na query
@author  	Evandro Mugnol
@since   	27/09/2018
@return		cQuery, query que sera utilizada na montagem do mBrowse
/*/
Static Function fQueryU(cColumnsU, cCliente, cLojaCli)

	Local cQuery := ""

	Default cColumnsU := ""

	cQuery := " SELECT TOP 10 SF2.R_E_C_N_O_ AS XX_F2RECNO," 
	cQuery += cColumnsU
	cQuery += "   FROM " + RetSqlTab("SF2") 
	cQuery += "  WHERE " + RetSqlFil("SF2") 
	cQuery += "    AND F2_CLIENTE = '" + cCliente + "' "
	cQuery += "    AND F2_LOJA    = '" + cLojaCli + "' "
	cQuery += "    AND " + RetSqlDel("SF2")
	cQuery += "  ORDER BY F2_EMISSAO DESC"

	cQuery := ChangeQuery(cQuery)

Return cQuery
