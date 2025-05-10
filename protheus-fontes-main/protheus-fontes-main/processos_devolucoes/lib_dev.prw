#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'SET.CH'

STATIC cTitulo	:= "Liberação de Autorização de Devolução"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} LIB_DEV
@Type			: Função de Usuário
@Sample			: U_LIB_DEV()
@Description	: Rotina de Liberação de Autorização de Devolução
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function LIB_DEV()

	Local aArea	 := FWGetArea()
	Local oLayer := Nil
	Local aSize	 := {}

	Private oDlgTela   := Nil
	Private oBrowse	   := Nil
	Private dDatDe	   := Ctod("")
	Private dDatAte	   := Ctod("")
	Private cMotDev    := Space(03)
	Private oCbxFilTpR := Nil
	Private cFiltroTpr := ""
	Private oCbxFilMer := Nil
	Private cFiltroMer := ""

	DbSelectArea("ZH1")
	DbSetOrder(1)
	If !DbSeek(xFilial("ZH1") + "2" + RetCodUsr())		// 1=Usuário Supervisor
		FWAlertWarning("Rotina será encerrada.", "Usuário sem permissão para efetuar liberação de autorizações de devolução!!")
		Return
	EndIf

	// Definicoes da Janela
	aSize	 := FWGetDialogSize( oMainWnd )
	oDlgtela := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cTitulo,,,, nOr( WS_VISIBLE, WS_POPUP ),,,,, .T.,,,, .F. )
	oLayer   := FWLayer():New()
	oLayer:Init(oDlgTela,.F.,.T.)

	// Divisor de Tela Superior [ FILTRO ]
	oLayer:AddLine("LINESUP", 25 )
	oLayer:AddCollumn("BOX01", 100,, "LINESUP" )
	oLayer:AddWindow("BOX01", "PANEL01", "Filtros", 100, .F.,,, "LINESUP" )

	// Divisor de Tela Inferior [ GRID ]
	oLayer:AddLine("LINEINF", 75 )
	oLayer:AddCollumn( "BOX02", 100,, "LINEINF" )
	oLayer:AddWindow( "BOX02", "PANEL02", cTitulo	, 100, .F.,,, "LINEINF" )

	// Aloca Cada Componente em seu Respectivo Box ( TPANEL )
	FPanel01( oLayer:GetWinPanel( "BOX01", "PANEL01", "LINESUP" ) ) 	// Contrução do Painel de Filtros
	FPanel02( oLayer:GetWinPanel( "BOX02", "PANEL02", "LINEINF" ) ) 	// Contrução do Painel Liberação de Autorização de Devolução 

	oDlgtela:Activate()

	FWRestArea(aArea)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} FPanel01
Funcao que cria a parte superior da janela "Filtros" e aloca ao painel 01
@Author     Evandro Mugnol
@Since      Nov/2024
@Param		oPanel - Painel para alocar os componentes de filtro
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function FPanel01( oPanel )

	Local bFiltrar := Nil
	Local oFont1   := TFont():New('Tahoma',,-12,,.T.)

	// Borda pora apresentacao dos componentes em tela
	TGroup():New( 005, 005, (oPanel:nHeight/2) - 005, (oPanel:nWidth/2) - 010 , "F I L T R O S", oPanel,CLR_RED,, .T. )

	// Legendas dos campos
	TSay():New( 020, 010, { || "Autorização Incluída De" }, oPanel,,oFont1,,,, .T.,CLR_HBLUE,CLR_WHITE, 110, 020 )
	TSay():New( 020, 130, { || "Autorização Incluída Até"}, oPanel,,oFont1,,,, .T.,CLR_HBLUE,CLR_WHITE, 110, 020 )
	TSay():New( 020, 252, { || "Tipo Retorno"}			  , oPanel,,oFont1,,,, .T.,CLR_HBLUE,CLR_WHITE, 110, 020 )
	TSay():New( 020, 372, { || "Mercadoria NF"}			  , oPanel,,oFont1,,,, .T.,CLR_HBLUE,CLR_WHITE, 110, 020 )
	TSay():New( 020, 492, { || "Motivo Devol."}			  , oPanel,,oFont1,,,, .T.,CLR_HBLUE,CLR_WHITE, 110, 020 )

	// Campos com as opções de filtro 
	@ 030, 010 MSGET dDatDe  PICTURE "@D" SIZE 110, 010 OF oPanel PIXEL HASBUTTON
	@ 030, 130 MSGET dDatAte PICTURE "@D" SIZE 110, 010 OF oPanel PIXEL HASBUTTON

	// Combo com as opções de filtro do tipo de retorno
	oCbxFilTpR := TCOMBOBOX():Create(oPanel)
	oCbxFilTpR:cName 	 := "oCbxFilTpR"
	oCbxFilTpR:cCaption  := "Filtro"
	oCbxFilTpR:nLeft 	 := 505
	oCbxFilTpR:nTop 	 := 059
	oCbxFilTpR:nWidth 	 := 200
	oCbxFilTpR:nHeight 	 := 024
	oCbxFilTpR:lShowHint := .F.
	oCbxFilTpR:lReadOnly := .F.
	oCbxFilTpR:Align 	 := 0
	oCbxFilTpR:cVariable := "cFiltroTpr"
	oCbxFilTpR:bSetGet 	 := {|u| If(PCount()>0,cFiltroTpr:=u,cFiltroTpr) }
	oCbxFilTpR:aItems 	 := {"0=Todos","1=Refaturamento Mesmo Cliente","2=Refaturamento Outro Cliente","3=Retorno Físico Frigorífico","4=Sem Retorno"}
	oCbxFilTpR:nAt 		 := 0

	// Combo com as opções de filtro da mercadoria nf
	oCbxFilMer := TCOMBOBOX():Create(oPanel)
	oCbxFilMer:cName 	 := "oCbxFilMer"
	oCbxFilMer:cCaption  := "Filtro"
	oCbxFilMer:nLeft 	 := 745
	oCbxFilMer:nTop 	 := 059
	oCbxFilMer:nWidth 	 := 200
	oCbxFilMer:nHeight 	 := 024
	oCbxFilMer:lShowHint := .F.
	oCbxFilMer:lReadOnly := .F.
	oCbxFilMer:Align 	 := 0
	oCbxFilMer:cVariable := "cFiltroMer"
	oCbxFilMer:bSetGet 	 := {|u| If(PCount()>0,cFiltroMer:=u,cFiltroMer) }
	oCbxFilMer:aItems 	 := {"0=Todos","1=Mercadoria Voltou","2=Dev. Simbólica","3=Refaturamento"}
	oCbxFilMer:nAt 		 := 0

	// Campos com as opções de filtro 
	@ 030, 492 MSGET cMotDev PICTURE "@!" F3 "ZH0"  SIZE 040, 010 OF oPanel PIXEL HASBUTTON

	// Botão filtrar
	bFiltrar := { || ExecFil("Aplicando Filtros") }
	TButton():New( 028,570, "Filtrar", oPanel, bFiltrar, 050, 013,,,, .T. )

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} FPanel02
Funcao que cria a parte inferior da janela "Grid Browse" e aloca ao painel 02
@Author     Evandro Mugnol
@Since      Nov/2024
@Param		oPanel - Painel para alocar os dados da grid
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function FPanel02( oPanel,lAllQry )

	Local cAliasQry	:= GetNextAlias()
	Local aIndex	:= {}
	Local aSeek 	:= {}
	Local cRetChave	:= ""
	Local cQuery 	:= ""
	Local nTpQry	:= 0

	Default lAllQry	:= .T. 		// Carrega todos os bloqueios

	// Aplica as definicoes para um Browse de tabela temporaria
	oBrowse := FWFormBrowse():New()
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetAlias(cAliasQry)
	oBrowse:SetDataQuery()
	
	If lAllQry
		cQuery := ""
		// Unifica todas as querys em uma unica (Union All)
		For nTpQry := 1 To 4
			cQuery += GetQuery(nTpQry)
			If nTpQry < 4
				cQuery += CRLF
				cQuery += " UNION ALL  "
			Else
				cQuery += " ORDER BY ZH2_NUMREC "
			EndIf
		Next
		oBrowse:SetQuery(cQuery)
	Else
		oBrowse:SetQuery(GetQuery())
	EndIf

	oBrowse:SetOwner(oPanel)
	oBrowse:SetDoubleClick({|| cRetChave := (oBrowse:Alias())->ZH2_NUMREC, oDlgTela:End()})
	oBrowse:SetColumns(GetColumns(cAliasQry))
	oBrowse:DisableDetails()
	oBrowse:SetDetails(.F.)
	oBrowse:ForceQuitButton()

	// Faz o inserção dos botoes para o browse
	oBrowse:AddButton( OemTOAnsi("LIBERAR")		       , {|| _LibeZH2((oBrowse:Alias())->ZH2_NUMREC) }	,, 2 )
	oBrowse:AddButton( OemTOAnsi("Visualizar")		   , {|| _VisuZH2((oBrowse:Alias())->ZH2_NUMREC) }	,, 2 )
	oBrowse:AddButton( OemTOAnsi("NFiscal Original")   , {|| _VisuSF2((oBrowse:Alias())->ZH2_NFORI, (oBrowse:Alias())->ZH2_SERORI) }  ,, 2 )
	oBrowse:AddButton( OemTOAnsi("Pré Nota Devolução") , {|| _VisuSF1((oBrowse:Alias())->ZH2_NFDEV, (oBrowse:Alias())->ZH2_SERDEV, (oBrowse:Alias())->ZH2_CODCLI, (oBrowse:Alias())->ZH2_LOJCLI) } 	,, 2 )
	oBrowse:AddButton( OemTOAnsi("Inspeção Qualidade") , {|| _VisuZH5((oBrowse:Alias())->ZH2_NUMREC) }  ,, 2 )
	oBrowse:AddButton( OemTOAnsi("Legenda")			   , {|| _LegBrw() }  ,, 2 )

	// Cria Indices para obter a busca por pedido e Cliente |
	Aadd( aIndex, "ZH2_NUMREC" )
	Aadd( aSeek, { "Num. Recibo", { {"","C",TamSx3('ZH2_NUMREC')[1],0,"Num. Recibo","@!"}  },1  } )

	Aadd( aIndex, "ZH2_CODCLI + ZH2_LOJCLI" )
	Aadd( aSeek, { "Cliente + Loja" , { {"","C",TamSx3('ZH2_CODCLI')[1],0,"Cliente"	,"@!"} ,;
									    {"","C",TamSx3('ZH2_LOJCLI')[1],0,"Loja"	,"@!"} },2  } )

	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetSeek(,aSeek)

	//Define as posições dos botões que serão exibidos
    oBrowse:oConfig:aButtonsOrder := {}
    aAdd(oBrowse:oConfig:aButtonsOrder, "LIBERAR")
    aAdd(oBrowse:oConfig:aButtonsOrder, "Visualizar")
    aAdd(oBrowse:oConfig:aButtonsOrder, "NFiscal Original")
    aAdd(oBrowse:oConfig:aButtonsOrder, "Pré Nota Devolução")
  	aAdd(oBrowse:oConfig:aButtonsOrder, "Inspeção Qualidade")

	// Ativa exibição do browse 
	oBrowse:Activate()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} GetQuery
Funcao que retorna consulta SQL de Liberação de Autorização de Devolução.
Monta consulta sql para buscar as autorizações de devolução que necessitam
de liberação.
@Author     Evandro Mugnol
@Since      Nov/2024
@Param		nTipo = 1 Query para buscar as autorizações com Refaturamento Mesmo Cliente
            nTipo = 2 Query para buscar as autorizações com Refaturamento Outro Cliente
            nTipo = 3 Query para buscar as autorizações com Retorno Físico Frigorífico
@Return 	cQuery
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function GetQuery(nTipo)

	Local cQuery 	:= ""
	Local cCampo 	:= ""
	Local lInsOrder	:= .T.

	Default nTipo := 0
	
	// Aplica regra ao obter a selecao do filtro
	If ValType(cFiltroTpr) = "C"
		If Val(cFiltroTpr) == 0 	// "0=Todos"
			lInsOrder := .F.
		Else
			// "1=Refaturamento Mesmo Cliente","2=Refaturamento Outro Cliente","3=Retorno Físico Frigorífico"
			nTipo := Val(cFiltroTpr)
		EndIf
	EndIf

	cCampo := " ZH2_FILIAL,"
	cCampo += " ZH2_NUMREC,"
	cCampo += " ZH2_CODCLI,"
	cCampo += " ZH2_LOJCLI,"
	cCampo += " ZH2_NOMCLI,"
	cCampo += " ZH2_VLRDEV,"
	cCampo += " ZH2_NFDEV,"
	cCampo += " ZH2_SERDEV,"
	cCampo += " ZH2_NFORI,"
	cCampo += " ZH2_SERORI,"
	cCampo += " ZH2_MOTDEV,"
	cCampo += " ZH2_DESDEV,"
	cCampo += " ZH2_TIPDEV,"
	cCampo += " ZH2_MERCNF,"
	cCampo += " ZH2_TIPRET,"
	cCampo += " ZH2_STATUS,"
	cCampo += " ZH2.R_E_C_N_O_ RECNO "
	Do Case
		Case nTipo = 1		// Query de autorizações com Refaturamento Mesmo Cliente
			cQuery += " SELECT '1' STATZH2, " + cCampo
			cquery += "   FROM " + RetSqlTab('ZH2')
			cQuery += "  WHERE " + RetSqlFil('ZH2')
			cQuery += "    AND ZH2_TIPRET = '1' "
			cQuery += "    AND " + RetSqlDel('ZH2')
			If !Empty(dDatDe) .Or. !Empty(dDatAte)
				cQuery += "    AND ZH2_MNTDAT BETWEEN '" + Dtos(dDatDe) + "' AND '" + Dtos(dDatAte) + "' "
			EndIf
			If cFiltroMer == "1"
				cQuery += "    AND ZH2_MERCNF = '1' "
			ElseIf cFiltroMer == "2"
				cQuery += "    AND ZH2_MERCNF = '2' "
			ElseIf cFiltroMer == "3"
				cQuery += "    AND ZH2_MERCNF = '3' "
			Else 
				cQuery += "    AND ZH2_MERCNF IN ('1','2','3') "
			EndIf
			If !Empty(cMotDev)
				cQuery += "    AND ZH2_MOTDEV = '" + cMotDev + "'"
			EndIf
			If lInsOrder
				cQuery += " ORDER BY ZH2_NUMREC "
			EndIf
		Case nTipo = 2		// Query de autorizações com Refaturamento Outro Cliente
			cQuery += " SELECT '2' STATZH2, " + cCampo
			cquery += "   FROM " + RetSqlTab('ZH2')
			cQuery += "  WHERE " + RetSqlFil('ZH2')
			cQuery += "    AND ZH2_TIPRET = '2' "
			cQuery += "    AND " + RetSqlDel('ZH2')
			If !Empty(dDatDe) .Or. !Empty(dDatAte)
				cQuery += "    AND ZH2_MNTDAT BETWEEN '" + Dtos(dDatDe) + "' AND '" + Dtos(dDatAte) + "' "
			EndIf
			If cFiltroMer == "1"
				cQuery += "    AND ZH2_MERCNF = '1' "
			ElseIf cFiltroMer == "2"
				cQuery += "    AND ZH2_MERCNF = '2' "
			ElseIf cFiltroMer == "3"
				cQuery += "    AND ZH2_MERCNF = '3' "
			Else 
				cQuery += "    AND ZH2_MERCNF IN ('1','2','3') "
			EndIf
			If !Empty(cMotDev)
				cQuery += "    AND ZH2_MOTDEV = '" + cMotDev + "'"
			EndIf
			If lInsOrder
				cQuery += " ORDER BY ZH2_NUMREC "
			EndIf
		Case nTipo = 3	// Query de autorizações com Retorno Físico Frigorífico
			cQuery += " SELECT '3' STATZH2, " + cCampo
			cquery += "   FROM " + RetSqlTab('ZH2')
			cQuery += "  WHERE " + RetSqlFil('ZH2')
			cQuery += "    AND ZH2_TIPRET = '3' "
			cQuery += "    AND " + RetSqlDel('ZH2')
			If !Empty(dDatDe) .Or. !Empty(dDatAte)
				cQuery += "    AND ZH2_MNTDAT BETWEEN '" + Dtos(dDatDe) + "' AND '" + Dtos(dDatAte) + "' "
			EndIf
			If cFiltroMer == "1"
				cQuery += "    AND ZH2_MERCNF = '1' "
			ElseIf cFiltroMer == "2"
				cQuery += "    AND ZH2_MERCNF = '2' "
			ElseIf cFiltroMer == "3"
				cQuery += "    AND ZH2_MERCNF = '3' "
			Else 
				cQuery += "    AND ZH2_MERCNF IN ('1','2','3') "
			EndIf
			If !Empty(cMotDev)
				cQuery += "    AND ZH2_MOTDEV = '" + cMotDev + "'"
			EndIf
			If lInsOrder
				cQuery += " ORDER BY ZH2_NUMREC "
			EndIf
		Case nTipo = 4	// Query de autorizações com Sem Retorno
			cQuery += " SELECT '3' STATZH2, " + cCampo
			cquery += "   FROM " + RetSqlTab('ZH2')
			cQuery += "  WHERE " + RetSqlFil('ZH2')
			cQuery += "    AND ZH2_TIPRET = '4' "
			cQuery += "    AND " + RetSqlDel('ZH2')
			If !Empty(dDatDe) .Or. !Empty(dDatAte)
				cQuery += "    AND ZH2_MNTDAT BETWEEN '" + Dtos(dDatDe) + "' AND '" + Dtos(dDatAte) + "' "
			EndIf
			If cFiltroMer == "1"
				cQuery += "    AND ZH2_MERCNF = '1' "
			ElseIf cFiltroMer == "2"
				cQuery += "    AND ZH2_MERCNF = '2' "
			ElseIf cFiltroMer == "3"
				cQuery += "    AND ZH2_MERCNF = '3' "
			Else 
				cQuery += "    AND ZH2_MERCNF IN ('1','2','3') "
			EndIf
			If !Empty(cMotDev)
				cQuery += "    AND ZH2_MOTDEV = '" + cMotDev + "'"
			EndIf
			If lInsOrder
				cQuery += " ORDER BY ZH2_NUMREC "
			EndIf
		OTHERWISE
			cQuery += " SELECT '3' STATZH2, " + cCampo
			cquery += "   FROM " + RetSqlTab('ZH2')
			cQuery += "  WHERE " + RetSqlFil('ZH2')
			cQuery += "    AND ZH2_TIPRET IN ('1','2','3','4') "
			cQuery += "    AND " + RetSqlDel('ZH2')
			If !Empty(dDatDe) .Or. !Empty(dDatAte)
				cQuery += "    AND ZH2_MNTDAT BETWEEN '" + Dtos(dDatDe) + "' AND '" + Dtos(dDatAte) + "' "
			EndIf
			If cFiltroMer == "1"
				cQuery += "    AND ZH2_MERCNF = '1' "
			ElseIf cFiltroMer == "2"
				cQuery += "    AND ZH2_MERCNF = '2' "
			ElseIf cFiltroMer == "3"
				cQuery += "    AND ZH2_MERCNF = '3' "
			Else 
				cQuery += "    AND ZH2_MERCNF IN ('1','2','3') "
			EndIf
			If !Empty(cMotDev)
				cQuery += "    AND ZH2_MOTDEV = '" + cMotDev + "'"
			EndIf
			If lInsOrder
				cQuery += " ORDER BY ZH2_TIPRET, ZH2_NUMREC "
			EndIf
	EndCase

Return(cQuery)


//-----------------------------------------------------------------------
/*/{Protheus.doc} ExecFil
Função que cxecuta atualização do browse com opção de tela de processamento
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function ExecFil(cMsgRun)

	Default cMsgRun	:= ""

	If !Empty(cMsgRun)
		FWMsgRun( ,{|| UpdateBrw() },"Aguarde",cMsgRun)
	Else
		CursorWait()
		UpdateBrw()
		CursorArrow()
	EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} UpdateBrw
Função que faz atualização dos dados que estão no browse (REFRESH)
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function UpdateBrw()

	oBrowse:Data():DeActivate()
	oBrowse:SetQuery( GetQuery() )
	oBrowse:Data():Activate()
	oBrowse:UpdateBrowse(.T.)
	oBrowse:GoBottom()
	oBrowse:GoTo(1,.T.)
	oBrowse:Refresh(.T.)

Return()


//-----------------------------------------------------------------------
/*/{Protheus.doc} GetColumns
Função que é responsavel por montar a estrutura das colunas do Browse
@Author     Evandro Mugnol
@Since      Nov/2024
@Param		cAlias
@Return 	aColumns Estrutura de colunas do Browse - FwFormBrowse
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function GetColumns(cAlias)

	Local aArea	   := FWGetArea()
	Local cCampo   := ""
	Local aCampos  := {}
	Local aColumns := {}
	Local nX	   := 0
	Local nLinha   := 0
	Local cIniBrw  := ""
	Local aCpoQry  := {}
	
	aCampos := {'ZH2_FILIAL', ;
				'ZH2_NUMREC', ;
				'ZH2_CODCLI', ;
				'ZH2_LOJCLI', ;
				'ZH2_NOMCLI', ;
				'ZH2_VLRDEV', ;
				'ZH2_NFDEV' , ;
				'ZH2_SERDEV', ;
				'ZH2_NFORI' , ;
				'ZH2_SERORI', ;
				'ZH2_MORDEV', ;
				'ZH2_DESDEV', ;
				'ZH2_TIPDEV', ;
				'ZH2_MERCNF', ;
				'ZH2_TIPRET', ;
				'ZH2_STATUS', ;
				'RECNO' 	  }

	DbSelectArea("SX3")
	DbSetOrder(2)
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&( "{ || IIF( (cAlias)->ZH2_STATUS =='1','BR_VERMELHO', IIF( (cAlias)->ZH2_STATUS == '2','BR_AMARELO', IIF( (cAlias)->ZH2_STATUS == '3','BR_VERDE','BR_PRETO'))) } " ))
	aColumns[nLinha]:SetData(&( "{ || IIF( (cAlias)->ZH2_STATUS =='1','BR_VERMELHO', IIF( (cAlias)->ZH2_STATUS == '2','BR_AMARELO', IIF( (cAlias)->ZH2_STATUS == '3','BR_VERDE', IIF( (cAlias)->ZH2_STATUS == '4','BR_PRETO', 'CHECKED')))) } " ))
	aColumns[nLinha]:SetTitle("")
	aColumns[nLinha]:SetType("C")
	aColumns[nLinha]:SetPicture("@BMP")
	aColumns[nLinha]:SetSize(1)
	aColumns[nLinha]:SetDecimal(0)
	aColumns[nLinha]:SetDoubleClick({|| _LegBrw() })
	aColumns[nLinha]:SetImage(.T.)

	For nX := 1 To Len(aCampos)
		If SX3->(DbSeek(AllTrim(aCampos[nX])))
			If (X3USO(SX3->X3_USADO) .AND. SX3->X3_BROWSE == "S" .AND. SX3->X3_TIPO <> "M") .OR. SX3->X3_CAMPO == "ZH2_FILIAL"
				AAdd(aColumns,FWBrwColumn():New())
				nLinha	:= Len(aColumns)
				cCampo 	:= AllTrim(SX3->X3_CAMPO)
				cIniBrw := AllTrim(SX3->X3_INIBRW)
				aColumns[nLinha]:SetType(SX3->X3_TIPO)
				If SX3->X3_CONTEXT <> "V"
					aAdd(aCpoQry,cCampo)
					If SX3->X3_TIPO = "D"
						aColumns[nLinha]:SetData( &("{|| Stod(" + "('"+cAlias+"')->" + cCampo + ") }") )
					ElseIf !Empty(X3CBox())
						aColumns[nLinha]:SetData( &("{|| X3Combo('" + cCampo + "',('"+cAlias+"')->" + cCampo + ") }") )
					Else
						aColumns[nLinha]:SetData( &("{|| " + "('"+cAlias+"')->" + cCampo + " }") )
					EndIf
				Else
					aColumns[nLinha]:SetData( &("{|| _LbRetBrw(" + "'"+cIniBrw+"','"+cAlias+"'" + ") }") )
				EndIf
				aColumns[nLinha]:SetTitle(X3Titulo())
				aColumns[nLinha]:SetSize(SX3->X3_TAMANHO)
				aColumns[nLinha]:SetDecimal(SX3->X3_DECIMAL)
				aColumns[nLinha]:SetPicture(SX3->X3_PICTURE)

				// Adiciona na memoria o conteudo da celula ao realizar o duplo click
				If aCampos[nX] $ "ZH2_NUMREC|"
					aColumns[nLinha]:SetDoubleClick( &("{|| CopytoClipboard(" + "('"+cAlias+"')->" + cCampo + ") }") )
				EndIf
			EndIf
		ElseIf aCampos[nX] == "RECNO"
			cCampo := "RECNO"
			AAdd(aColumns,FWBrwColumn():New())
			nLinha := Len(aColumns)
			aColumns[nLinha]:SetData( &("{|| " + "('"+cAlias+"')->" + cCampo + " }") )
			aColumns[nLinha]:SetTitle("RECNO")
			aColumns[nLinha]:SetType("C")
			aColumns[nLinha]:SetPicture("9999999")
			aColumns[nLinha]:SetSize(7)
			aColumns[nLinha]:SetDecimal(0)
			aColumns[nLinha]:SetDoubleClick( &("{|| CopytoClipboard(" + "('"+cAlias+"')->" + cCampo + ") }") )
		EndIf
	Next nX

	FWRestArea(aArea)

Return(aColumns)


//-----------------------------------------------------------------------
/*/{Protheus.doc} _LbRetBrw
Função que executa função definida no inicializador padrao do browse X3_INIBRW
referente a autorização de devolução
@Author     Evandro Mugnol
@Since      Nov/2024
@Param		cIniBrw -> 
			cAlias	->
@Return 	cRetorno
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function _LbRetBrw(cIniBrw, cAlias)

	Local cRetorno := ""

	DbSelectArea(cAlias)
	DbSetOrder(1)
	If DbSeek(FWxFilial(cAlias) + (cAlias)->ZH2_NUMREC)
		cRetorno := &(cIniBrw)
	EndIf

Return(cRetorno)


//-----------------------------------------------------------------------
/*/{Protheus.doc} _LibeZH2
Função que efetua a liberação da pré nota para classificação e sequencia
do fluxo do processo da nota fiscal de devolução
@Author     Evandro Mugnol
@Since      Jan/2025
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function _LibeZH2(_cNumRec)

	Local aArea    := FWGetArea()
	Local aAreaZH2 := ZH2->(FWGetArea())

	DbSelectArea("ZH2")
	ZH2->(DbSetOrder(1))
	ZH2->(DbGoTop())

	// Se conseguir posicionar
	If ZH2->(DbSeek(FWxFilial("ZH2") + _cNumRec))
		If ZH2->ZH2_STATUS == "2"		// Somente deixa liberar recibo cujo status seja igual a 2 - "Autorização Dev. Incluída c/ Pré Nota de Devolução Lançada e Bloqueada"
			// Altera status do recibo de devolução para 3 = "Autorização Dev. Liberada p/ Supervisor ou Qualidade" 
			DbSelectArea("ZH2")
			RecLock("ZH2", .F.)
			ZH2->ZH2_LIBUSU := UsrRetName(RetCodUsr())
			ZH2->ZH2_LIBDAT := DDATABASE
			ZH2->ZH2_LIBHOR := SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2)
			ZH2->ZH2_STATUS := "3"
			MsUnlock()


			// Efetua desbloqueio da pré nota de devolução para permitir que seja classificada
			DbSelectArea("SF1")
			DbSetOrder(1)
			If DbSeek(FWxFilial("SF1") + ZH2->ZH2_NFDEV + ZH2->ZH2_SERDEV + ZH2->ZH2_CODCLI + ZH2->ZH2_LOJCLI + "D")
				DbSelectArea("SF1")
				RecLock("SF1", .F.)
				SF1->F1_STATUS := IIF(SF1->F1_STATUS == "B", " ", SF1->F1_STATUS)
				MsUnlock()
			EndIf

			// Efetua refresh no browse
			UpdateBrw()
		Else
			FWAlertError("Somente é permitido liberação para status com legenda igual a cor 'Amarela'.", "O Status deste recibo não permite liberação da pré nota de devolução.")
		EndIf
	Else
		FWAlertError("Verifique se o mesmo existe", "Número do Recibo Não Encontrado.")
	EndIf

	FWRestArea(aAreaZH2)
	FWRestArea(aArea)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _VisuZH2
Função que efetua a visualização dos dados do registro posicionado na tela
referente a autorização de devolução
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function _VisuZH2(_cNumRec)

	Local aArea    := FWGetArea()
	Local aAreaZH2 := ZH2->(FWGetArea())

	Private cCadastro := ""

	DbSelectArea("ZH2")
	ZH2->(DbSetOrder(1))
	ZH2->(DbGoTop())

	// Se conseguir posicionar
	If ZH2->(DbSeek(FWxFilial("ZH2") + _cNumRec))
		FWExecView( "Visualização Detalhada Autorização de Devolução" ,;
					"AUTDEV",;
					MODEL_OPERATION_VIEW,;
					/*oDlg*/,;
					{ || .T. },;
					/*bOk*/,;
					/*nPercReducao*/,;
					/*aEnableButtons*/,;
					/*bCancel*/,;
					/*cOperatId*/,;
					/*cToolBar*/,;
					/*oModel*/)
	Else
		FWAlertError("Verifique se o mesmo existe", "Número do Recibo Não Encontrado.")
	EndIf

	FWRestArea(aAreaZH2)
	FWRestArea(aArea)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _VisuSF2
Função que efetua a visualização dos dados do registro posicionado na tela
referente a nota fiscal original
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function _VisuSF2(_cDocto, _cSerie)

	Local aArea    := FWGetArea()
	Local aAreaSD2 := SD2->(FWGetArea())
	Local aAreaSF2 := SF2->(FWGetArea())

	DbSelectArea("SF2")
	DbSetOrder(1)
	DbSeek(FWxFilial("SF2") + _cDocto + _cSerie)
	If Found()
		MC090Visual("SF2", Recno(), 2)
	Else
		FWAlertError("Verifique se a mesma existe", "Nota Fiscal Original Não Encontrada.")
	EndIf

	FWRestArea(aAreaSF2)
	FWRestArea(aAreaSD2)
	FWRestArea(aArea)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _VisuSF1
Função que efetua a visualização dos dados do registro posicionado na tela
referente a pré nota de devolução
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function _VisuSF1(_cDocto, _cSerie, _cFornec, _cLoja)

	Local aArea    := FWGetArea()
	Local aAreaSD1 := SD1->(FWGetArea())
	Local aAreaSF1 := SF1->(FWGetArea())

	Private aRotina    := {{ , , 0 , 2 }}
	Private l103Auto   := .F.
	Private aAutoCab   := {}
	Private aAutoItens := {}

	DbSelectArea("SF1")
	DbSetOrder(1)
	DbSeek(FWxFilial("SF1") + _cDocto + _cSerie + _cFornec + _cLoja)
	If Found()
		A103NFiscal("SF1", SF1->(Recno()), 1)
	Else
		FWAlertError("Verifique se a mesma existe", "Pré Nota de Devolução Não Encontrada.")
	EndIf

	FWRestArea(aAreaSF1)
	FWRestArea(aAreaSD1)
	FWRestArea(aArea)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _VisuZH5
Função que efetua a visualização dos dados do registro posicionado na tela
referente a controle de recebimento e inspeção de devoluções
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function _VisuZH5(_cNumRec)

	Local aArea    := FWGetArea()
	Local aAreaZH6 := ZH6->(FWGetArea())
	Local aAreaZH5 := ZH5->(FWGetArea())

	// Variáveis utilizadas para consulta na função abaixo
	Private cCadastro := "Controle de Receb. e Inspeção Devol."
	Private INCLUI := .F.
	Private ALTERA := .F.

	DbSelectArea("ZH5")
	DbSetOrder(1)
	DbSeek(FWxFilial("ZH5") + _cNumRec)
	If Found()
		U_CriDvInc("ZH5", ZH5->(Recno()), 2)
	Else
		FWAlertError("Verifique se o mesmo existe", "Controle de Recebimento e Inspeção de Devolução Não Encontrado.")
	EndIf

	FWRestArea(aAreaZH5)
	FWRestArea(aAreaZH6)
	FWRestArea(aArea)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _LegBrw
Função que monta interface com as legenda do browse
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function _LegBrw()

	Local oLegenda := FWLegend():New()

	oLegenda:Add("ZH2->ZH2_STATUS == '1'", "RED"    , "Autorização Dev. Incluída s/ Pré Nota de Devolução")
	oLegenda:Add("ZH2->ZH2_STATUS == '2'", "YELLOW" , "Autorização Dev. Incluída c/ Pré Nota de Devolução Lançada e Bloqueada")
	oLegenda:Add("ZH2->ZH2_STATUS == '3'", "GREEN"  , "Autorização Dev. Liberada p/ Supervisor ou Qualidade")
	oLegenda:Add("ZH2->ZH2_STATUS == '4'", "BLACK"  , "Autorização Dev. Encerrada c/ NF Classificada")
	oLegenda:Add("ZH2->ZH2_STATUS == '5'", "CHECKED", "Autorização Dev. Encerrada c/ NF Classificada e Refaturamento Realizado")

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return
