#Include "TOTVS.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#Include 'FWMVCDef.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

user function obit05ZAU(_dData)
	Local aArea   := GetArea()
	Local aCampos := {}
	Local aCampos2 := {}
	Local cFontPad   := 'Tahoma'

	Local oFnt		 := NIL
	Default _dData := dDatabase

	Private oFontGrid  := TFont():New(cFontPad,,-14)
	//Janela e componentes
	Private  aColunas   := {}
	Private  aColunas2   := {}
	Private oTempTable := Nil
	Private oTempT2 := Nil
	Private oDlgMark
	Private oPanGrid
	Private oPanGrid2
	Private oMarkBrowse
	Private oMarkB2
	Private cAliasTmp := GetNextAlias()
	Private cAliasTmp2 := GetNextAlias()
	//Private aRotina   := MenuDef2()
	//Tamanho da janela
	Private aTamanho := MsAdvSize()
	Private nJanLarg := aTamanho[5]//1.5
	Private nJanAltu := aTamanho[6]//1.5
	Private campoA   := Space(10) //campo do codigo da etiqueta
	Private campoB   := Space(40) //campo do lote
	Private campoC   := Space(40) //campo do lote
	Private campoD   := Space(40) //campo do lote
	Private campoF   := Space(40)
	Private valorA   := Space(10) //valor do lote
	Private campoE   := _dData
	Private valorE   := _dData
	Private campoG   := Space(40)
	Private valorG   := 0
	Private valorF   := 0
	//Ordenação da tela
	Private cUltOrdem := ""
	Private lDescend  := .F.

	If !(cEmpAnt == "01" .and. cFilAnt == "00")
		MsgAlert("Rotina não disponível para esta empresa e filial.")
		Return()
	endif

	//Janela de ZAU
	DbSelectArea('SX3')
	DbSetOrder(2)
	aAdd(aCampos, {'ZAU_OK', "C", 2, 0})
	MsSeek("ZAU_NUM") ; AADD(aCampos,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAU_COD") ; AADD(aCampos,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAU_DESC"); AADD(aCampos,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("X5_DESCRI")  ; AADD(aCampos,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAU_QPPESO") ; AADD(aCampos,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	AADD(aCampos,{"ZAS_QTDE",X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAU_DTPROD") ; AADD(aCampos,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})

	//Cria a tabela temporária
	oTempTable:= FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex("1", {"X5_DESCRI"} )
	oTempTable:AddIndex("2", {"ZAU_NUM"} )
	oTempTable:AddIndex("3", {"ZAU_COD"} )
	oTempTable:AddIndex("4", {"ZAU_DESC"} )
	oTempTable:Create()

	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas := fCriaCols()

	//janela de ZAS
	DbSelectArea('SX3')
	DbSetOrder(2)
	aAdd(aCampos2, {'ZAS_OK', "C", 2, 0})
	MsSeek("ZAS_CONTRO") ; AADD(aCampos2,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAS_COD")    ; AADD(aCampos2,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAS_DESC")   ; AADD(aCampos2,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAS_PESOL")  ; AADD(aCampos2,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAS_DTPROD") ; AADD(aCampos2,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})

	//Cria a tabela temporária
	oTempT2:= FWTemporaryTable():New(cAliasTmp2)
	oTempT2:SetFields( aCampos2 )
	oTempT2:Create()

	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas2 := fCriaCols2()

	DEFINE FONT oFnt NAME "Arial" SIZE 12,14 BOLD
	oFont   := tFont():New("arial",,-12,,.t.,,,,)
	//Criando a janela
	DEFINE MSDIALOG oDlgMark TITLE 'Vínculo de lote de produção com caçamba' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

	@ 015,010 SAY "Data dos lotes: "  Object oSay1
	@ 010,060 MSGET campoE VAR valorE SIZE 30,11 PIXEL  OF oDlgMark
	oSayCampoF := tSay():New(15, 150,{|| campoF },oDlgMark,,oFont,,,,.T.,CLR_BLACK,CLR_BLACK,200,30)

	@ (nJanAltu/4) + 10,010 SAY "Código da caçamba: "  Object oSay1
	@ (nJanAltu/4) + 05,070 MSGET campoA VAR valorA SIZE 60,11 F3 'ZAS' PIXEL OF oDlgMark VALID vldZAS(valorA, 2)
	oSayCampoB := tSay():New((nJanAltu/4) + 10, 150,{|| campoB },oDlgMark,,oFont,,,,.T.,CLR_BLACK,CLR_BLACK,200,30)
	oSayCampoC := tSay():New((nJanAltu/4) + 20, 150,{|| campoC },oDlgMark,,oFont,,,,.T.,CLR_BLACK,CLR_BLACK,200,30)
	oSayCampoD := tSay():New((nJanAltu/4) + 30, 150,{|| campoD },oDlgMark,,oFont,,,,.T.,CLR_BLACK,CLR_BLACK,200,30)
	oSayCampoG := tSay():New((nJanAltu/4) + 30, 250,{|| campoG },oDlgMark,,oFont,,,,.T.,CLR_BLACK,CLR_BLACK,200,30)

	campoE:bLostFocus := {|| Processa({|| fPopula()}, 'Processando...') }

	//Dados
	oPanGrid := tPanel():New(030, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1, (nJanAltu/4)-30)
	TButton():New( 015,400, "Gravar"   , oDlgMark,{||obit05G() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 015,450, "Cancelar" , oDlgMark,{||oDlgMark:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 015,500, "Recarregar" , oDlgMark,{||obit05R() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 015,550, "Cons Vínculos" , oDlgMark,{||obit05Vin() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	aSeek := {}
	cCampoAux := "ZAU_NUM"
	aAdd(aSeek,{GetSX3Cache(cCampoAux, "X3_TITULO"), {{"", GetSX3Cache(cCampoAux, "X3_TIPO"), GetSX3Cache(cCampoAux, "X3_TAMANHO"), GetSX3Cache(cCampoAux, "X3_DECIMAL"), AllTrim(GetSX3Cache(cCampoAux, "X3_TITULO")), AllTrim(GetSX3Cache(cCampoAux, "X3_PICTURE"))}} } )
	cCampoAux := "ZAU_COD"
	aAdd(aSeek,{GetSX3Cache(cCampoAux, "X3_TITULO"), {{"", GetSX3Cache(cCampoAux, "X3_TIPO"), GetSX3Cache(cCampoAux, "X3_TAMANHO"), GetSX3Cache(cCampoAux, "X3_DECIMAL"), AllTrim(GetSX3Cache(cCampoAux, "X3_TITULO")), AllTrim(GetSX3Cache(cCampoAux, "X3_PICTURE"))}} } )
	cCampoAux := "ZAU_DESC"
	aAdd(aSeek,{GetSX3Cache(cCampoAux, "X3_TITULO"), {{"", GetSX3Cache(cCampoAux, "X3_TIPO"), GetSX3Cache(cCampoAux, "X3_TAMANHO"), GetSX3Cache(cCampoAux, "X3_DECIMAL"), AllTrim(GetSX3Cache(cCampoAux, "X3_TITULO")), AllTrim(GetSX3Cache(cCampoAux, "X3_PICTURE"))}} } )
	cCampoAux := "X5_DESCRI"
	aAdd(aSeek,{"Molde", {{"", GetSX3Cache(cCampoAux, "X3_TIPO"), GetSX3Cache(cCampoAux, "X3_TAMANHO"), GetSX3Cache(cCampoAux, "X3_DECIMAL"), AllTrim(GetSX3Cache(cCampoAux, "X3_TITULO")), AllTrim(GetSX3Cache(cCampoAux, "X3_PICTURE"))}} } )

	oMarkBrowse:= FWMarkBrowse():New()
	oMarkBrowse:SetDescription("Selecione o lote a ser produzido") //Titulo da Janela
	oMarkBrowse:SetAlias(cAliasTmp)
	//oMarkBrowse:oBrowse:SetDBFFilter(.T.)
	//oMarkBrowse:ForceQuitButton(.F.)
	//oMarkBrowse:SetIgnoreARotina(.F.)
	oMarkBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
	//oMarkBrowse:oBrowse:SetFixedBrowse(.T.)
	oMarkBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
	oMarkBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
	oMarkBrowse:SetTemporary(.T.) //Indica que o Browse utiliza tabela temporária
	oMarkBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
	//oMarkBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
	oMarkBrowse:SetFieldMark('ZAU_OK')
	oMarkBrowse:SetMenuDef("obit05ZAU")
	oMarkBrowse:SetAfterMark({||obit05T()})
	oMarkBrowse:SetFontBrowse(oFontGrid)
	oMarkBrowse:DisableReport()
	oMarkBrowse:DisableConfig()
	oMarkBrowse:SetOwner(oPanGrid)
	oMarkBrowse:SetColumns(aColunas)
	//oMarkBrowse:lHeaderClick := .T.
	//oMarkBrowse:SetItemHeaderClick({"ZAU_NUM", "ZAU_COD"})
	//oMarkBrowse:AddButton("Enviar Mensagem"	, { || U_obit05C()},,,, .F., 2 )
	oMarkBrowse:Activate()

	oPanGrid2 := tPanel():New((nJanAltu/4)+50, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1, (nJanAltu/4)-50)

	oMarkB2:= FWMarkBrowse():New()
	oMarkB2:SetDescription("Caçamba vinculada") //Titulo da Janela
	oMarkB2:SetAlias(cAliasTmp2)
	//oMarkB2:oBrowse:SetDBFFilter(.T.)
	//oMarkBrowse:ForceQuitButton(.F.)
	//oMarkBrowse:SetIgnoreARotina(.F.)
	oMarkB2:oBrowse:SetUseFilter(.F.) //Habilita a utilização do filtro no Browse
	//oMarkBrowse:oBrowse:SetFixedBrowse(.T.)
	oMarkB2:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
	oMarkB2:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
	oMarkB2:SetTemporary(.T.) //Indica que o Browse utiliza tabela temporária
	//----oMarkBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
	//oMarkBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
	oMarkB2:SetFieldMark('ZAS_OK')
	oMarkB2:SetMenuDef("obit05ZAU")
	oMarkB2:SetAfterMark({||obitMB2()})
	oMarkB2:SetFontBrowse(oFontGrid)
	oMarkB2:DisableReport()
	oMarkB2:SetOwner(oPanGrid2)
	oMarkB2:SetColumns(aColunas2)
	//oMarkBrowse:AddButton("Enviar Mensagem"	, { || U_obit05C()},,,, .F., 2 )
	oMarkB2:Activate()
	campoE:setFocus()
	oMarkBrowse:oBrowse:Setfocus()

	/*
	oFwBrowse := FWBrowse():New()
	oFwBrowse:SetDataArrayoBrowse()  //Define utilização de array
	oFwBrowse:DisableReport()
	aItems := LoadItems()      //Carregar os itens que irão compor o conteudo do grid
	oFwBrowse:SetArray(aItems) //Indica o array utilizado para apresentação dos dados no Browse.
	oFwBrowse:SetDelete (.T.)
	aColumns := RetColumns( aItems )
	//Cria as colunas do array
	For nX := 1 To Len(aColumns )
		oFwBrowse:AddColumn( aColumns[nX] )
	Next
	oFwBrowse:SetOwner(oPanGrid2)
	//oFwBrowse:SetDescription( "Browse com Array" )
	oFwBrowse:Activate()
*/
	ACTIVATE MsDialog oDlgMark CENTERED

	//Deleta a temporária e desativa a tela de marcação
	oTempTable:Delete()
	oTempT2:Delete()
	oMarkBrowse:DeActivate()

	RestArea(aArea)

return()

static function obit05G()
	Local _nCont := 0
	Local _nCont2 := 0
	dbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())
	do while !eof()
		if  !Empty((cAliasTmp)->ZAU_OK)
			_nCont++
		endif
		(cAliasTmp)->(DbSkip())
	enddo
	dbSelectArea(cAliasTmp2)
	(cAliasTmp2)->(DbGoTop())
	do while !eof()
		if  !Empty((cAliasTmp2)->ZAS_OK)
			_nCont2++
		endif
		(cAliasTmp2)->(DbSkip())
	enddo
	if FWAlertNoYes("Foram selecionados " + cValToChar(_nCont) + " lotes e " + cValToChar(_nCont2) + " caçambas. Deseja gravar a vinculação?", "Seleção de lotes")
		apagaZLI2()
		dbSelectArea(cAliasTmp)
		(cAliasTmp)->(DbGoTop())
		do while !eof()
			if  !Empty((cAliasTmp)->ZAU_OK)
				dbSelectArea(cAliasTmp2)
				(cAliasTmp2)->(DbGoTop())
				do while !eof()
					if  !Empty((cAliasTmp2)->ZAS_OK)
						dbSelectArea("ZLI")
						RecLock("ZLI", .T.)
						ZLI->ZLI_FILIAL := fwFilial("ZLI")
						ZLI->ZLI_CONTRO := (cAliasTmp2)->ZAS_CONTRO
						ZLI->ZLI_NUM    := (cAliasTmp)->ZAU_NUM
						ZLI->ZLI_DATA   := dDatabase
						ZLI->ZLI_DATAIN := Date()
						ZLI->ZLI_HORAIN := time()
						ZLI->ZLI_USER   := retCodUsr()
						ZLI->ZLI_CODPRO := (cAliasTmp)->ZAU_COD
						MsUnlock()
						ZAS->(dbSetOrder(1))
						ZAS->(dbGoTop())
						If ZAS->(MsSeek(xFilial('ZAS')+(cAliasTmp2)->ZAS_CONTRO))
							Reclock('ZAS',.F.)
							ZAS->ZAS_DATAS  := date()
							ZAS->ZAS_HORAS  := time()
							MsUnlock()
							u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "2Vínculado a lote " + ZLI->ZLI_NUM, ZAS->ZAS_PALLET, "ZLI", alltrim(FUNNAME()))
						endif
					endif
					dbSelectArea(cAliasTmp2)
					(cAliasTmp2)->(DbSkip())
				enddo
			endif
			dbSelectArea(cAliasTmp)
			(cAliasTmp)->(DbSkip())
		enddo
		oTempTable:Zap()
		oTempT2:Zap()
		oDlgMark:End()

		u_obit05ZAU(valorE)
	endif
return(.T.)


static function apagaZLI2()
	Local aAreaZLI := GetArea()
	dbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())
	do while !eof()
		if  !Empty((cAliasTmp)->ZAU_OK)
			dbSelectArea("ZLI")
			DbSetOrder(2)
			ZLI->(DbGoTop())
			MsSeek(fwFilial("ZLI")+(cAliasTmp)->ZAU_NUM)
			do while !eof() .and. ZLI->ZLI_NUM == (cAliasTmp)->ZAU_NUM
				ZAS->(dbSetOrder(1))
				ZAS->(dbGoTop())
				If ZAS->(MsSeek(xFilial('ZAS')+ZLI->ZLI_CONTRO))
					Reclock('ZAS',.F.)
					ZAS->ZAS_DATAS  := stod('')
					ZAS->ZAS_HORAS  := ''
					MsUnlock()
					u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "1Exclus. vínc. lote " + ZLI->ZLI_NUM, ZAS->ZAS_PALLET, "ZLI", alltrim(FUNNAME()))
				endif
				dbSelectArea("ZLI")
				reclock("ZLI",.f.)
				DbDelete()
				msunlock()
				ZLI->(DbSkip())
			enddo
		endif
		dbSelectArea(cAliasTmp)
		(cAliasTmp)->(DbSkip())
	enddo
	RestArea(aAreaZLI)
return()


static function trazZASV(_cCodZAU)

	Local aAreaZLI := GetArea()
	dbSelectArea("ZLI")
	DbSetOrder(2)
	ZLI->(DbGoTop())
	MsSeek(fwFilial("ZLI")+_cCodZAU)
	do while !eof() .and. ZLI->ZLI_NUM == _cCodZAU
		vldZAS(ZLI->ZLI_CONTRO, 1)
		ZLI->(DbSkip())
	enddo
	RestArea(aAreaZLI)
return()

Static function fPopula()
	Local _cQuery := ""
	//Local nTotal  := 0
	if !empty(valorE)
		oTempTable:Zap()

		_cQuery := " SELECT '  ' AS ZAU_OK, ZAU_NUM, ZAU_COD, ZAU_DESC, ZAU_QPPESO, ZAU_DTPROD, X5_DESCRI AS X5_DESCRI, " + CRLF
		_cQuery += " ISNULL((SELECT SUM(ZAS_PESOL) FROM " + RETSQLNAME("ZLI") +" AS ZLI " + CRLF
		_cQuery += " INNER JOIN " + RETSQLNAME("ZAS") +" AS ZAS ON ZLI_NUM = ZAU_NUM AND ZLI_CONTRO = ZAS_CONTRO AND ZLI_FILIAL = ZAU_FILIAL AND ZAS.D_E_L_E_T_ = '' " + CRLF
		_cQuery += " WHERE ZLI.D_E_L_E_T_ = '' ), 0) AS ZAS_QTDE " + CRLF
		_cQuery += " FROM " + RETSQLNAME("ZAU") +" AS ZAU " + CRLF
		_cQuery += " INNER JOIN " + RETSQLNAME("SB1") +" AS SB1 ON B1_FILIAL = ZAU.ZAU_FILIAL AND B1_COD = ZAU.ZAU_COD AND SB1.D_E_L_E_T_ = '' " + CRLF
		_cQuery += " INNER JOIN " + RETSQLNAME("ZAX") +" AS ZAX ON ZAX.ZAX_FILIAL = ZAU.ZAU_FILIAL AND ZAX.ZAX_NUM = ZAU.ZAU_BATEL AND ZAX.D_E_L_E_T_ = '' " + CRLF
		_cQuery += " LEFT  JOIN " + RETSQLNAME("SX5") +" AS SX5 ON B1_MOLDE = RTRIM(X5_CHAVE) AND X5_TABELA = 'ZD' AND SX5.D_E_L_E_T_ = '' " + CRLF
		_cQuery += " WHERE ZAU.D_E_L_E_T_ = '' AND ZAX.ZAX_REC = 'N' AND ZAU_DTPROD = '"+DTOS(valorE)+"' " + CRLF
		_cQuery += " ORDER BY ZAU_OK DESC, X5_DESCRI " + CRLF

		TCQUERY _cQuery NEW ALIAS "QRYDADTMP"
		//Definindo o tamanho da régua
		DbSelectArea('QRYDADTMP')
		QRYDADTMP->(DbGoTop())

		//Enquanto houver registros, adiciona na temporária
		While ! QRYDADTMP->(EoF())
			RecLock(cAliasTmp, .T.)
			(cAliasTmp)->ZAU_OK   := iif( !empty(QRYDADTMP->ZAU_OK), oMarkBrowse:Mark(), '' )
			(cAliasTmp)->ZAU_NUM  := QRYDADTMP->ZAU_NUM
			(cAliasTmp)->ZAU_COD   := QRYDADTMP->ZAU_COD
			(cAliasTmp)->ZAU_DESC  := alltrim(QRYDADTMP->ZAU_DESC)
			(cAliasTmp)->X5_DESCRI := alltrim(QRYDADTMP->X5_DESCRI)
			(cAliasTmp)->ZAU_QPPESO := round(QRYDADTMP->ZAU_QPPESO,2)
			(cAliasTmp)->ZAS_QTDE   := round(QRYDADTMP->ZAS_QTDE,2)
			(cAliasTmp)->ZAU_DTPROD := stod(QRYDADTMP->ZAU_DTPROD)
			(cAliasTmp)->(MsUnlock())
			QRYDADTMP->(DbSkip())
		EndDo
		QRYDADTMP->(DbCloseArea())
		(cAliasTmp)->(DbGoTop())
		aColunas := fCriaCols()
		oMarkBrowse:Refresh(.T.)
	endif
	oMarkBrowse:oBrowse:Setfocus() //Seta o foco na grade
Return


Static Function fCriaCols()
	Local nAtual   := 0
	Local _aColunas1 := {}
	Local aEstrut  := {}
	Local oColumn

	//Adicionando campos que serão mostrados na tela
	//[1] - Campo da Temporaria
	//[2] - Titulo
	//[3] - Tipo
	//[4] - Tamanho
	//[5] - Decimais
	//[6] - Máscara
	DbSelectArea('SX3')
	DbSetOrder(2)
	//aAdd(aEstrut, { 'ZAR_OK',      'Ok', 'C', 2, 0, ''})
	MsSeek("ZAU_NUM") ; aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("ZAU_COD") ; aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("ZAU_DESC"); aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("X5_DESCRI"); aAdd(aEstrut, { X3_CAMPO, "Molde",             X3_TIPO, 15, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("ZAU_QPPESO"); aAdd(aEstrut, { X3_CAMPO, alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 2})
	aAdd(aEstrut, { "ZAS_QTDE", "Caçamba Já Vinc.", X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 2})
	MsSeek("ZAU_DTPROD"); aAdd(aEstrut, { X3_CAMPO, alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 2})
	//Percorrendo todos os campos da estrutura
	For nAtual := 1 To Len(aEstrut)
		//Cria a coluna
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
		oColumn:SetTitle(aEstrut[nAtual][2])
		oColumn:SetType(aEstrut[nAtual][3])
		oColumn:SetSize(aEstrut[nAtual][4])
		oColumn:SetDecimal(aEstrut[nAtual][5])
		oColumn:SetPicture(aEstrut[nAtual][6])
		oColumn:nAlign := aEstrut[nAtual][8]

		//Se for o código ou descrição, adiciona a opção de clique no cabeçalho
		If Alltrim(aEstrut[nAtual][1]) $ "X5_DESCRI;ZAU_NUM;ZAU_COD;ZAU_DESC;"
			oColumn:bHeaderClick := &("{|| fOrdena('" + aEstrut[nAtual][1] + "') }")
		EndIf

		//Adiciona a coluna
		aAdd(_aColunas1, oColumn)
	Next
Return _aColunas1


Static Function fCriaCols2()
	Local nAtual   := 0
	Local _aColunas2 := {}
	Local aEstrut  := {}
	Local oColumn

	//Adicionando campos que serão mostrados na tela
	//[1] - Campo da Temporaria
	//[2] - Titulo
	//[3] - Tipo
	//[4] - Tamanho
	//[5] - Decimais
	//[6] - Máscara
	DbSelectArea('SX3')
	DbSetOrder(2)
	//aAdd(aEstrut, { 'ZAR_OK',      'Ok', 'C', 2, 0, ''})
	MsSeek("ZAS_CONTRO")  ; aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("ZAS_COD")     ; aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("ZAS_DESC")    ; aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("ZAS_PESOL")   ; aAdd(aEstrut, { X3_CAMPO, alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 2})
	MsSeek("ZAS_DTPROD")  ; aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 2})

	//Percorrendo todos os campos da estrutura
	For nAtual := 1 To Len(aEstrut)
		//Cria a coluna
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&('{|| ' + cAliasTmp2 + '->' + aEstrut[nAtual][1] +'}'))
		oColumn:SetTitle(aEstrut[nAtual][2])
		oColumn:SetType(aEstrut[nAtual][3])
		oColumn:SetSize(aEstrut[nAtual][4])
		oColumn:SetDecimal(aEstrut[nAtual][5])
		oColumn:SetPicture(aEstrut[nAtual][6])
		oColumn:nAlign := aEstrut[nAtual][8]

		//Adiciona a coluna
		aAdd(_aColunas2, oColumn)
	Next
Return _aColunas2


Static Function fCriaCols4()
	Local nAtual   := 0
	Local _aColunas4 := {}
	Local aEstrut  := {}
	Local oColumn

	//Adicionando campos que serão mostrados na tela
	//[1] - Campo da Temporaria
	//[2] - Titulo
	//[3] - Tipo
	//[4] - Tamanho
	//[5] - Decimais
	//[6] - Máscara
	DbSelectArea('SX3')
	DbSetOrder(2)
	MsSeek("ZAS_CONTRO")  ; aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("ZAS_COD")     ; aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("ZAS_DESC")    ; aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("ZAS_PESOL")   ; aAdd(aEstrut, { X3_CAMPO, alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 2})
	MsSeek("ZAS_DTPROD")  ; aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 2})

	//Percorrendo todos os campos da estrutura
	For nAtual := 1 To Len(aEstrut)
		//Cria a coluna
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&('{|| ' + cAliasT4 + '->' + aEstrut[nAtual][1] +'}'))
		oColumn:SetTitle(aEstrut[nAtual][2])
		oColumn:SetType(aEstrut[nAtual][3])
		oColumn:SetSize(aEstrut[nAtual][4])
		oColumn:SetDecimal(aEstrut[nAtual][5])
		oColumn:SetPicture(aEstrut[nAtual][6])
		oColumn:nAlign := aEstrut[nAtual][8]

		//Adiciona a coluna
		aAdd(_aColunas4, oColumn)
	Next
Return _aColunas4
static function vldZAS(_cEtiq, _nTp) //_nTp := 1 adiciona já existentes e 2 apenas novos
	local _lRet := .T.
	Local _aAreaTmp := {}
	if !empty(_cEtiq)
		dbSelectArea("ZAS")
		dbSetOrder(1)
		if !MsSeek(fwFilial("ZAS")+_cEtiq)
			_lRet := .F.
			if _nTp == 2
				MsgAlert("Etiqueta não localizada!!!")
			endif
		endif
		if _lRet
			_aAreaTmp := (cAliasTmp2)->(GetArea())
			dbSelectArea(cAliasTmp2)
			(cAliasTmp2)->(DbGoTop())
			do while !eof()
				if _cEtiq == (cAliasTmp2)->ZAS_CONTRO
					_lRet := .F.
					if _nTp == 2
						MsgAlert("Etiqueta já informada!!!")
					endif
					RestArea(_aAreaTmp)
					exit
				endif
				dbSelectArea(cAliasTmp2)
				(cAliasTmp2)->(DbSkip())
			enddo
			RestArea(_aAreaTmp)
		endif
		if _lRet
			if _nTp == 2 .and. valorE < ZAS->ZAS_DTPROD
				if !FWAlertNoYes("A etiqueta selecionada foi fabricada em " + dtoc(ZAS->ZAS_DTPROD) + " e a data do lote é " + dtoc(valorE) + ". Deseja prosseguir?", "Aviso de fabricação")
					_lRet := .F.
				endif
			endif
		endif
		if _lRet
			campoB := alltrim(ZAS->ZAS_COD) + " - " + ZAS->ZAS_DESC
			campoC := "Data de fabricação: " + dtoc(ZAS->ZAS_DTPROD)
			campoD := "Peso líquido: " + Transform(ZAS->ZAS_PESOL,'@E 999,999.99')
			campoF := "Peso lotes selecionados: " + Transform(valorF,'@E 999,999.99')
			oSayCampoB:SetText(campoB)
			oSayCampoC:SetText(campoC)
			oSayCampoD:SetText(campoD)
			oSayCampoF:SetText(campoF)
			oMarkB2:GoTop(.T.)
			RecLock(cAliasTmp2, .T.)
			(cAliasTmp2)->ZAS_OK   := oMarkB2:Mark()
			(cAliasTmp2)->ZAS_CONTRO := ZAS->ZAS_CONTRO
			(cAliasTmp2)->ZAS_COD     := ZAS->ZAS_COD
			(cAliasTmp2)->ZAS_DESC    := ZAS->ZAS_DESC
			(cAliasTmp2)->ZAS_PESOL   := ZAS->ZAS_PESOL
			(cAliasTmp2)->ZAS_DTPROD  := ZAS->ZAS_DTPROD
			(cAliasTmp2)->(MsUnlock())
			//aColunas2 := fCriaCols2()
			valorG += ZAS->ZAS_PESOL
			campoG := "Peso das caçambas selecionadas: " + Transform(valorG,'@E 999,999.99')
			oSayCampoG:SetText(campoG)
			oSayCampoG:Refresh()

			/*
			if _nTp == 2
				valorF += round((cAliasTmp)->ZAU_QPPESO,2)
			endif
			*/
			m2Refresh()
			oDlgMark:Refresh()
			if _nTp == 2
				valorA := Space(10)
				campoA:SetFocus()
			else
				oMarkBrowse:oBrowse:Setfocus() //Seta o foco na grade
			endif
		endif
		//oDlgMark:Refresh()
/*
	else
		oTempTable:Zap()
		oSayCampoB:SetText("")
		oSayCampoC:SetText("")
		oSayCampoD:SetText("")
		oSayCampoF:SetText("")
		oDlgMark:Refresh()
		oMarkBrowse:Refresh(.T.)
		oSayCampoF:Refresh()
		*/
	endif
return(_lRet)


static function obit05T()

	if oMarkBrowse:IsMark()
		valorF += round((cAliasTmp)->ZAU_QPPESO,2)
		//aqui teria que inclur abaixo o que já está vinculado a este lote
		trazZASV((cAliasTmp)->ZAU_NUM)
	else
		valorF -= round((cAliasTmp)->ZAU_QPPESO,2)
	endif
	campoF := "Peso lotes selecionados: " + Transform(valorF,'@E 999,999.99')
	oSayCampoF:Refresh()

return(.T.)

static function obitMB2()

	if oMarkB2:IsMark()
		valorG += round((cAliasTmp2)->ZAS_PESOL,2)
	else
		valorG -= round((cAliasTmp2)->ZAS_PESOL,2)
	endif
	campoG := "Peso das caçambas selecionadas: " + Transform(valorG,'@E 999,999.99')
	oSayCampoG:SetText(campoG)
	oSayCampoG:Refresh()

return(.T.)

Static Function m2Refresh()
	(cAliasTmp2)->(DbGoTop())
	oMarkB2:GoBottom(.T.)
	oMarkB2:Refresh(.T.)
	oMarkB2:GoTop(.T.)
	oMarkB2:Refresh(.T.)
Return

Static Function m1Refresh()
	(cAliasTmp)->(DbGoTop())
	oMarkBrowse:GoBottom(.T.)
	oMarkBrowse:Refresh(.T.)
	oMarkBrowse:GoTop(.T.)
	oMarkBrowse:Refresh(.T.)
Return

Static Function m3Refresh()
	(cAliasT3)->(DbGoTop())
	oBrowse3:GoBottom(.T.)
	oBrowse3:Refresh(.T.)
	oBrowse3:GoTop(.T.)
	oBrowse3:Refresh(.T.)
Return

Static Function m4Refresh()
	if  Select(cAliasT4) > 0
		(cAliasT4)->(DbGoTop())
		oBrowse4:GoBottom(.T.)
		oBrowse4:Refresh(.T.)
		oBrowse4:GoTop(.T.)
		oBrowse4:Refresh(.T.)
	endif
Return

static function obit05R()

	oTempTable:Zap()
	oTempT2:Zap()
	oDlgMark:End()

	u_obit05ZAU(valorE)

return()

Static Function fOrdena(cCampo)
	Default cCampo := ""

	//Pegando o Índice conforme o campo
	cCampo := Alltrim(cCampo)
	If cCampo == "X5_DESCRI"
		nOrder := 1
	ElseIf cCampo == "ZAU_NUM"
		nOrder := 2
	elseIf cCampo == "ZAU_COD"
		nOrder := 3
	ElseIf cCampo == "ZAU_DESC"
		nOrder := 4
	EndIf

	//Ordena pelo Índice
	(cAliasTmp)->(DbSetOrder(nOrder))

	//Se o último campo clicado é o mesmo, irá mudar entre crescente / decrescente
	If cUltOrdem == cCampo
		//Se esta como decrescente, ordena crescente
		If lDescend
			OrdDescend(nOrder, cValToChar(nOrder), .F.)
			lDescend := .F.

			//Se esta como crescente, ordena como decrescente
		Else
			OrdDescend(nOrder, cValToChar(nOrder), .T.)
			lDescend := .T.
		EndIf
	Else
		lDescend := .F.
	EndIf
	cUltOrdem := cCampo

	m1Refresh()
Return


static function obit05Vin()

	Local aCampos3 := {}
	Local aCampos4 := {}
	Private oDlg3      As Object
	Private oBrowse3   As Object
	Private aColunas3 := {}
	Private cAliasT3 := GetNextAlias()
	Private oTempT3 := Nil

	Private oBrowse4   As Object
	Private aColunas4 := {}
	Private cAliasT4  := GetNextAlias()
	Private oTempT4 := Nil

	Private _dData3   := valorE
	Private _valor3   := _dData3

	//Janela de ZAU
	DbSelectArea('SX3')
	DbSetOrder(2)
	aAdd(aCampos3, {'ZAU_OK', "C", 2, 0})
	MsSeek("ZAU_NUM") ; AADD(aCampos3,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAU_COD") ; AADD(aCampos3,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAU_DESC"); AADD(aCampos3,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("X5_DESCRI")  ; AADD(aCampos3,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAU_QPPESO") ; AADD(aCampos3,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	AADD(aCampos3,{"ZAS_QTDE",X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAU_DTPROD") ; AADD(aCampos3,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})

	//janela de ZAS
	DbSelectArea('SX3')
	DbSetOrder(2)
	MsSeek("ZAS_CONTRO") ; AADD(aCampos4,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAS_COD")    ; AADD(aCampos4,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAS_DESC")   ; AADD(aCampos4,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAS_PESOL")  ; AADD(aCampos4,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})
	MsSeek("ZAS_DTPROD") ; AADD(aCampos4,{alltrim(X3_CAMPO),X3_TIPO, X3_TAMANHO,X3_DECIMAL})

	DEFINE MSDIALOG oDlg3 TITLE "Consulta vinculos" FROM 0,0 TO nJanAltu-100, nJanLarg-100 PIXEL

	@ 010,010 SAY "Data dos lotes: "  Object oSay3
	@ 005,060 MSGET _dData3 VAR _valor3 SIZE 30,11 PIXEL  OF oDlg3
	_dData3:bLostFocus := {|| Processa({|| fPopula3()}, 'Processando...') }
	TButton():New( 005,300, "Desvincular"   , oDlg3,{||obit05Des((cAliasT3)->ZAU_NUM) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	oTempT3:= FWTemporaryTable():New(cAliasT3)
	oTempT3:SetFields( aCampos3 )
	oTempT3:Create()

	oPanGrid3 := tPanel():New(020, 001, '', oDlg3, , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg-100)/2), ((nJanAltu-100)/4))
	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas3 := fCriaCols3()

	oBrowse3 := FWMarkBrowse():New()
	oBrowse3:SetAlias(cAliasT3)
	oBrowse3:oBrowse:SetUseFilter(.F.) //Habilita a utilização do filtro no Browse
	oBrowse3:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
	oBrowse3:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
	oBrowse3:SetTemporary(.T.) //Indica que o Browse utiliza tabela temporária
	//oMarkBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
	//oMarkBrowse:SetFieldMark('ZAU_OK')
	//oMarkBrowse:SetMenuDef("obit05ZAU")
	//oMarkBrowse:SetAfterMark({||obit05T()})
	oBrowse3:SetFontBrowse(oFontGrid)
	oBrowse3:DisableReport()
	oBrowse3:DisableConfig()
	oBrowse3:SetOwner(oPanGrid3)
	oBrowse3:SetChange( {|| _Change((cAliasT3)->ZAU_NUM) } )
	oBrowse3:SetColumns(aColunas3)
	oBrowse3:Activate()
	_dData3:setFocus()

	oTempT4:= FWTemporaryTable():New(cAliasT4)
	oTempT4:SetFields( aCampos4 )
	oTempT4:Create()

	oPanGrid4 := tPanel():New((nJanAltu/4), 001, '', oDlg3, , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg-100)/2), ((nJanAltu-155)/4))
	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas4 := fCriaCols4()
	oBrowse4 := FWMarkBrowse():New()
	oBrowse4:SetAlias(cAliasT4)
	oBrowse4:oBrowse:SetUseFilter(.F.) //Habilita a utilização do filtro no Browse
	oBrowse4:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
	oBrowse4:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
	oBrowse4:SetTemporary(.T.) //Indica que o Browse utiliza tabela temporária
	oBrowse4:SetFontBrowse(oFontGrid)
	oBrowse4:DisableReport()
	oBrowse4:DisableConfig()
	oBrowse4:SetOwner(oPanGrid4)
	oBrowse4:SetColumns(aColunas4)
	oBrowse4:Activate()

	ACTIVATE MSDIALOG oDlg3 CENTERED

	oTempT3:Delete()
	oTempT4:Delete()

	oBrowse3:DeActivate()

return()

static function _Change(_cCodZAU)
	if Select(cAliasT4) > 0
		oTempT4:Zap()
	endif
	dbSelectArea("ZLI")
	DbSetOrder(2)
	ZLI->(DbGoTop())
	MsSeek(fwFilial("ZLI")+_cCodZAU)
	do while !eof() .and. ZLI->ZLI_NUM == _cCodZAU
		dbSelectArea("ZAS")
		dbSetOrder(1)
		if MsSeek(fwFilial("ZAS")+ZLI->ZLI_CONTRO)
			RecLock(cAliasT4, .T.)
			(cAliasT4)->ZAS_CONTRO  := ZAS->ZAS_CONTRO
			(cAliasT4)->ZAS_COD     := ZAS->ZAS_COD
			(cAliasT4)->ZAS_DESC    := ZAS->ZAS_DESC
			(cAliasT4)->ZAS_PESOL   := ZAS->ZAS_PESOL
			(cAliasT4)->ZAS_DTPROD  := ZAS->ZAS_DTPROD
			(cAliasT4)->(MsUnlock())
		endif
		ZLI->(DbSkip())
	enddo
	m4Refresh()
	oDlg3:Refresh()
return(.T.)

Static Function fCriaCols3()
	Local nAtual   := 0
	Local _aColunas3 := {}
	Local aEstrut  := {}
	Local oColumn

	//Adicionando campos que serão mostrados na tela
	//[1] - Campo da Temporaria
	//[2] - Titulo
	//[3] - Tipo
	//[4] - Tamanho
	//[5] - Decimais
	//[6] - Máscara
	DbSelectArea('SX3')
	DbSetOrder(2)
	MsSeek("ZAU_NUM") ; aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("ZAU_COD") ; aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("ZAU_DESC"); aAdd(aEstrut, { X3_CAMPO,   alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("X5_DESCRI"); aAdd(aEstrut, { X3_CAMPO, "Molde",             X3_TIPO, 15, X3_DECIMAL, X3_PICTURE, .F., 1})
	MsSeek("ZAU_QPPESO"); aAdd(aEstrut, { X3_CAMPO, alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 2})
	aAdd(aEstrut, { "ZAS_QTDE", "Caçamba Já Vinc.", X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 2})
	MsSeek("ZAU_DTPROD"); aAdd(aEstrut, { X3_CAMPO, alltrim(X3_TITULO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, .F., 2})
	//Percorrendo todos os campos da estrutura
	For nAtual := 1 To Len(aEstrut)
		//Cria a coluna
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&('{|| ' + cAliasT3 + '->' + aEstrut[nAtual][1] +'}'))
		oColumn:SetTitle(aEstrut[nAtual][2])
		oColumn:SetType(aEstrut[nAtual][3])
		oColumn:SetSize(aEstrut[nAtual][4])
		oColumn:SetDecimal(aEstrut[nAtual][5])
		oColumn:SetPicture(aEstrut[nAtual][6])
		oColumn:nAlign := aEstrut[nAtual][8]

		//Adiciona a coluna
		aAdd(_aColunas3, oColumn)
	Next
Return _aColunas3


Static function fPopula3()
	Local _cQuery := ""
	//Local nTotal  := 0
	if !empty(_valor3)
		oTempT3:Zap()
		oTempT4:Zap()

		_cQuery := " SELECT ZAU_NUM, ZAU_COD, ZAU_DESC, ZAU_QPPESO, ZAU_DTPROD, X5_DESCRI AS X5_DESCRI, " + CRLF
		_cQuery += " ISNULL((SELECT SUM(ZAS_PESOL) FROM " + RETSQLNAME("ZLI") +" AS ZLI " + CRLF
		_cQuery += " INNER JOIN " + RETSQLNAME("ZAS") +" AS ZAS ON ZLI_NUM = ZAU_NUM AND ZLI_CONTRO = ZAS_CONTRO AND ZLI_FILIAL = ZAU_FILIAL AND ZAS.D_E_L_E_T_ = '' " + CRLF
		_cQuery += " WHERE ZLI.D_E_L_E_T_ = '' ), 0) AS ZAS_QTDE " + CRLF
		_cQuery += " FROM " + RETSQLNAME("ZAU") +" AS ZAU " + CRLF
		_cQuery += " INNER JOIN " + RETSQLNAME("SB1") +" AS SB1 ON B1_FILIAL = ZAU.ZAU_FILIAL AND B1_COD = ZAU.ZAU_COD AND SB1.D_E_L_E_T_ = '' " + CRLF
		_cQuery += " INNER JOIN " + RETSQLNAME("ZAX") +" AS ZAX ON ZAX.ZAX_FILIAL = ZAU.ZAU_FILIAL AND ZAX.ZAX_NUM = ZAU.ZAU_BATEL AND ZAX.D_E_L_E_T_ = '' " + CRLF
		_cQuery += " LEFT  JOIN " + RETSQLNAME("SX5") +" AS SX5 ON B1_MOLDE = RTRIM(X5_CHAVE) AND X5_TABELA = 'ZD' AND SX5.D_E_L_E_T_ = '' " + CRLF
		_cQuery += " WHERE ZAU.D_E_L_E_T_ = '' AND ZAX.ZAX_REC = 'N' AND ZAU_DTPROD = '"+DTOS(_valor3)+"' " + CRLF
		_cQuery += " ORDER BY X5_DESCRI " + CRLF

		TCQUERY _cQuery NEW ALIAS "QRYDADTMP"

		//Definindo o tamanho da régua
		DbSelectArea('QRYDADTMP')
		QRYDADTMP->(DbGoTop())

		//Enquanto houver registros, adiciona na temporária
		While ! QRYDADTMP->(EoF())
			RecLock(cAliasT3, .T.)
			(cAliasT3)->ZAU_NUM  := QRYDADTMP->ZAU_NUM
			(cAliasT3)->ZAU_COD   := QRYDADTMP->ZAU_COD
			(cAliasT3)->ZAU_DESC  := alltrim(QRYDADTMP->ZAU_DESC)
			(cAliasT3)->X5_DESCRI := alltrim(QRYDADTMP->X5_DESCRI)
			(cAliasT3)->ZAU_QPPESO := round(QRYDADTMP->ZAU_QPPESO,2)
			(cAliasT3)->ZAS_QTDE   := round(QRYDADTMP->ZAS_QTDE,2)
			(cAliasT3)->ZAU_DTPROD := stod(QRYDADTMP->ZAU_DTPROD)
			(cAliasT3)->(MsUnlock())
			QRYDADTMP->(DbSkip())
		EndDo
		QRYDADTMP->(DbCloseArea())
		(cAliasT3)->(DbGoTop())
		aColunas3 := fCriaCols3()
		m3Refresh()
	endif
	oBrowse3:oBrowse:Setfocus() //Seta o foco na grade
Return


static function obit05Des(_cCod)
	Local aAreaZLI := GetArea()

	dbSelectArea("ZLI")
	DbSetOrder(2)
	ZLI->(DbGoTop())
	if MsSeek(fwFilial("ZLI")+_cCod)
		if FWAlertNoYes("Deseja desvincular todos as caçambas do lote "+_cCod+"?")
			do while !eof() .and. ZLI->ZLI_NUM == _cCod
				ZAS->(dbSetOrder(1))
				ZAS->(dbGoTop())
				If ZAS->(MsSeek(xFilial('ZAS')+ZLI->ZLI_CONTRO))
					Reclock('ZAS',.F.)
					ZAS->ZAS_DATAS  := stod('')
					ZAS->ZAS_HORAS  := ''
					MsUnlock()
					u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "1Exclus. vínc. lote " + ZLI->ZLI_NUM, ZAS->ZAS_PALLET, "ZLI", alltrim(FUNNAME()))
				endif
				dbSelectArea("ZLI")
				reclock("ZLI",.f.)
				DbDelete()
				msunlock()
				ZLI->(DbSkip())
			enddo
			DbSelectArea(cAliasT3)
			reclock(cAliasT3,.f.)
			(cAliasT3)->ZAS_QTDE   := 0
			msunlock()
			if Select(cAliasT4) > 0
				oTempT4:Zap()
			endif
			m3Refresh()
			m4Refresh()
			oDlg3:Refresh()
		endif
		RestArea(aAreaZLI)
	endif
return()
