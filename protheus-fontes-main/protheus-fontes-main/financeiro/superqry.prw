#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "VKEY.CH"
#INCLUDE "COLORS.CH"

#DEFINE BR Chr(10)

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} SUPERQRY 
@Type			: Função de Usuário
@Sample			: U_SUPERQRY()
@Description	: Rotina que monta uma tela para a digitação e execução de Comandos SQL
                  (SELECT, UPDATE e INSERT).
                  Com opção de exportar os resultados para planilha eletrônica.
                  Possibilidade de exportar a consulta para o formato ADVPL que pode ser
                  colado no código fonte.
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Jun/2021
@version		: Protheus 12.1.25 e posteriores
@Comments		: N/D
/*/
//--------------------------------------------------------------------------------------
User Function SUPERQRY()

	Local cSQL     := ""
	Local cLine    := ""
	Local cLogErro := ""
	Local cTipo    := "Original"
	Local aTipos   := {"Titulo","Original"}
	Local nHdl     := 0
	Local oFont    := TFont():New( "Arial",0,-14,,.F.,0,,700,.F.,.F.,,,,,, )
	Local oPanelResultado
	Local oPanelQuery
	Local oDlg
	Local oMGSql
	Local oMenu
	Local cButton1 := "QPushButton {" ;
									+ BR + " background: #B0E0E6;";							 	// Cor do fundo
									+ BR + " border: 1px solid #096A82;";						// Cor da borda
									+ BR + " outline:0;";
									+ BR + " border-radius: 5px;"; 								// Arrerondamento da borda
									+ BR + " font: normal 14px Arial;"; 
									+ BR + " padding: 6px;";
									+ BR + " color: #000000;";									// Cor da fonte
									+ BR + " }";
									+ BR + " QPushButton:pressed {";							// Ações quando pressionado botão
									+ BR + " background-color: #B0E0E6;border-style: inset;"; 
									+ BR + " border-color: #B0E0E6;";
									+ BR + " color: #000000;";
									+ BR + " }"

	Local cButton2 := "QPushButton {" ;
									+ BR + " background: #FF0000;";							 	// Cor do fundo
									+ BR + " border: 1px solid #096A82;";						// Cor da borda
									+ BR + " outline:0;";
									+ BR + " border-radius: 5px;"; 								// Arrerondamento da borda
									+ BR + " font: normal 14px Arial;"; 
									+ BR + " padding: 6px;";
									+ BR + " color: #000000;";									// Cor da fonte
									+ BR + " }";
									+ BR + " QPushButton:pressed {";							// Ações quando pressionado botão
									+ BR + " background-color: #FF0000;border-style: inset;"; 
									+ BR + " border-color: #FF0000;";
									+ BR + " color: #000000;";
									+ BR + " }"
	Local cCombo1 := "QComboBox {";
								 + BR + " font-family: Calibri,Lucida,Verdana;";				// nome da fonte
								 + BR + " font-size: 12pt;";									// tamanho da fonte
								 + BR + " border-radius: 6px;";									// arredondamento da borda
								 + BR + " ";
								 + BR + " background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #B0E0E6, stop: 1 #B0E0E6);";	// cor de fundo
								 + BR + " border: 1px solid #096A82;";							// borda
								 + BR + " color: #000000;";										// cor da fonte
								 + BR + " padding: 1px;";										// espacamento (margin)
								 + BR + " min-height: 26px;";									// altura minima
								 + BR + " }";
								 + BR + " ";
								 + BR + " QComboBox QAbstractItemView {";						// Itens da lista
								 + BR + " border: 2px solid #096A82;";							// Borda do container de itens
								 + BR + " ";
								 + BR + " selection-background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #B0E0E6, stop: 1 #B0E0E6); ";		// Cor de fundo do item tambem aceita degrade
								 + BR + " height: 14px;";										// Altura do item
								 + BR + " }";
								 + BR + " ";													// Acoes ao pressionar o drop-down
								 + BR + " QComboBox:on {";
								 + BR + " ";
								 + BR + " background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #B0E0E6, stop: 1 #B0E0E6);";	// cor de fundo
								 + BR + " }";
								 + BR + " ";
								 + BR + " QComboBox::drop-down {";								// Caracteristicas do botao drop-drown
								 + BR + " width: 30px;";										// largura
								 + BR + " border: 1px solid #096A82;";							// borda
								 + BR + " border-top-right-radius: 3px;";						// arredondamento superior direito
								 + BR + " border-bottom-right-radius: 3px;";					// arredondamento inferior direito
								 + BR + " }";
								 + BR + " ";
								 + BR + " QComboBox::down-arrow {";								// Imagem do botao drop-down
								 + BR + " padding: 0px 5px 0px 5px;";							// margem				
								 + BR + " image: url(S:/Protheus12_Homolog/protheus_data/fontes/estudo/SetCSS/combo.png);";		 // imagem do botao drop-down
								 + BR + " width: 20px;";										// largura
								 + BR + " height: 20px;";										// altura
								 + BR + " }"		

	Private oPanelMsg
	Private oGridResult
	Private cArqUser := "super"+RetCodUsr()+".qry"

	If File( cArqUser )
		nHdl := FT_FUse( cArqUser )
		If nHdl = -1
            MsgAlert("Erro na abertura do arquivo " + cArqUser)
		Else
			FT_FGoTop()
			While !FT_FEOF()
				cLine := FT_FReadLn()
				cSQL += cLine + CRLF
				FT_FSKIP()
			End
			FT_FUSE()
		EndIf
	EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Calcula as 2 dimensões, onde cada uma terá seus objetos      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New( .F. ) // Não terá barra com os botões
	oSize:AddObject( "SUPERIOR", 100, 10, .T., .T. )
	oSize:AddObject( "INFERIOR", 100, 90, .T., .T. )
	oSize:lProp := .F.      // Proporcional
	oSize:Process()         // Dispara os calculos

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Divide a Superior em 3                                       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSizeSup := FwDefSize():New( .F. ) // Não terá barra com os botões
	oSizeSup:aWorkArea := oSize:GetNextCallArea( "SUPERIOR" )
	oSizeSup:AddObject( "OPCOES"  , 15, 100, .T., .T. )
	oSizeSup:AddObject( "CONSULTA", 70, 100, .T., .T. )
	oSizeSup:AddObject( "MENSAGEM", 15, 100, .T., .T. )
	oSizeSup:lLateral := .T. // Cálculo em Lateral
	oSizeSup:lProp := .T.
	oSizeSup:Process()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Monta Dialog                                                 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDlg := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],"Super Query Analyser",,,,nOr(WS_VISIBLE,WS_POPUP),,,,,.T.)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Aqui está criando o grupo onde serão colocados os botões     ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGgpOpcoes := TGroup():New(oSizeSup:GetDimension("OPCOES","LININI"),;
                               oSizeSup:GetDimension("OPCOES","COLINI"),;
                               oSizeSup:GetDimension("OPCOES","LINEND"),;
                               oSizeSup:GetDimension("OPCOES","COLEND"),'Opções',oDlg,CLR_BLUE,,.T.)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Aqui está criando o grupo onde será colocado o MultiGet para a digitação do SQL ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelQuery := TGroup():New(oSizeSup:GetDimension("CONSULTA","LININI"),;
                                oSizeSup:GetDimension("CONSULTA","COLINI"),;
                                oSizeSup:GetDimension("CONSULTA","LINEND"),;
                                oSizeSup:GetDimension("CONSULTA","COLEND"),'Comando SQL',oDlg,CLR_BLUE,,.T.)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Aqui está criando o grupo onde será colocado o MultiGet para as Mensagens       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelMsg := TGroup():New(oSizeSup:GetDimension("MENSAGEM","LININI"),;
                              oSizeSup:GetDimension("MENSAGEM","COLINI"),;
                              oSizeSup:GetDimension("MENSAGEM","LINEND"),;
                              oSizeSup:GetDimension("MENSAGEM","COLEND"),'Mensagens',oDlg,CLR_BLUE,,.T.)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Aqui está criando o grupo onde será colocado o browse dos dados apresentados    ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelResultado := TGroup():New(oSize:GetDimension("INFERIOR","LININI"),;
                                    oSize:GetDimension("INFERIOR","COLINI"),;
                                    oSize:GetDimension("INFERIOR","LINEND"),;
                                    oSize:GetDimension("INFERIOR","COLEND"),"R E S U L T A D O",oDlg,CLR_GREEN,,.T.)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Aqui está criando os Botões/Atalhos das ações                ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey( VK_F5, {|| MsgRun( "Executando a consulta...", "Aguarde",  {|| ExecSQL(oPanelResultado, cSQL, @cLogErro, cTipo, oMGSql:nPos ), oMGSql:SetFocus() } ) } )

	oButton1:=TButton():New(oSizeSup:GetDimension("OPCOES","LININI")+10,;
                            oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                            "Executar SQL (F5)",oGgpOpcoes,{|u| MsgRun( "Executando a consulta...", "Aguarde",  {|| ExecSQL(oPanelResultado, cSQL, @cLogErro, cTipo, oMGSql:nPos ), oMGSql:SetFocus() } ) },70,14,,,,.T.,,"",,,,.F. )
	oButton1:SetCss(cButton1)

	oButton2:=TComboBox():New(oSizeSup:GetDimension("OPCOES","LININI")+25,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                    {|u| If(PCount()>0,cTipo:=u,cTipo)},aTipos,072,014,oGgpOpcoes,,,,CLR_BLUE,CLR_WHITE,.T.,,"",,,,,,,cTipo, "Coluna dos dados", 1 )
	oButton2:SetCss(cCombo1)

	oButton3:=TButton():New(oSizeSup:GetDimension("OPCOES","LININI")+52,;
                            oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                            "Gerar Excel",oGgpOpcoes,{|u| MsgRun( "Gerando arquivo...", "Aguarde",  {|| GeraExcel( cSQL, cLogErro, oMGSql:nPos ) } ) },70,14,,,,.T.,,"",,,,.F. )
	oButton3:SetCss(cButton1)

	oButton4:=TButton():New(oSizeSup:GetDimension("OPCOES","LININI")+72,;
                            oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                            "Enviar Log",oGgpOpcoes,{|u| MsgRun( "Enviando arquivo...", "Aguarde",  {|| Mysend(cLogErro) } ) },70,14,,,,.T.,,"",,,,.F. )
	oButton4:SetCss(cButton1)

	oButton5:=TButton():New(oSizeSup:GetDimension("OPCOES","LININI")+92,;
                            oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                            "Exportar ADVPL",oGgpOpcoes,{|u| MsgRun( "Gerando cQuery...", "Aguarde",  {|| CQuery(cSQL, oMGSql:nPos) } ) },70,14,,,,.T.,,"",,,,.F. )
	oButton5:SetCss(cButton1)

	oButton6:=TButton():New(oSizeSup:GetDimension("OPCOES","LININI")+110,;
                            oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                            "Fechar",oGgpOpcoes,{|u| oDlg:END() },70,14,,,,.T.,,"",,,,.F. )
	oButton6:SetCss(cButton2)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Aqui está criando o MultiGet para a digitação do SQL         ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMGSql := tMultiget():New(oSizeSup:GetDimension("CONSULTA","LININI")+10/*Linha inicial*/,;
                              oSizeSup:GetDimension("CONSULTA","COLINI")+5/*Coluna inicial*/,;
                              {| u | if( pCount() > 0, cSQL := u, cSQL )},oPanelQuery,;
                              oSizeSup:GetDimension("CONSULTA","XSIZE")-10/*Largura*/,;
                              oSizeSup:GetDimension("CONSULTA","YSIZE")-15/*Altura*/,oFont,,,,,.T./*lPixel*/,,,,,,.F./*lReadOnly*/,/*bValid*/,,,/*lNoBorder*/,.T./*lVScroll*/)

	oMenu := TMenu():New(0,0,0,0,.T.)
	oMenu:Add( TMenuItem():New(oMenu,"Opção",,,,{|| MsgInfo("Melhoria futura", "Super Query") },,,,,,,,,.T.) )
	oMGSql:SetPopup(oMenu)
	oMGSql:SetFocus()

	oDlg:Activate()

	SetKey( VK_F5 , NIL )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CQuery
Função que coloca na área de memória da máquina, toda a consulta no formato
cQuery para que fique fácil de colar no código fonte.
@Since      Jun/2021
@param      cSql,       character,  Comando SQL
@param      nPosCursor, numeric,    Posição do cursor na tela
/*/
//-------------------------------------------------------------------
Static Function CQuery( cSql, nPosCursor )

	Local cRet     := ""
	Local cTab     := ""
	Local cTxt     := ""
	Local cFirma   := FWCodEmp()
	Local aQry     := {}
	Local aCposSel := {}
	Local lOk      := .F.
	Local nX       := 0
	Local nPos     := 0
    Local nPEsp    := 0

	If( Empty( cSql ) .Or. nPosCursor <= 0 .Or. !("SELECT" $ Upper( cSql ) ) )
		Return
	EndIf

	cRet += "Local cQuery := ''" + CRLF
	cRet += "Local cAliTmp := GetNextAlias()" + CRLF + CRLF

	cSql := LimpaSql( cSql, nPosCursor )

	// Pega a estrutura do SQL para adicionar os campos Data e Numérico no TCSetField()
	If TCSQLEXEC( cSql ) == 0
		cTab := GetNextAlias()
		MPSysOpenQuery( cSql, cTab )
		aCposSel := (cTab)->(DBSTRUCT())
		(cTab)->( DbCloseArea() )
		cTab := ""
	Endif

	aQry := StrTokArr(cSql, CRLF)

	For nX:= 1 To Len(aQry)
		cTxt := aQry[nX]
		If !Empty(cTxt)

			cTxt := Replace( cTxt, '"', "'" )

			// Ajusta a Filial
			nPFil := At( '_FILIAL', Upper(cTxt) )
			If nPFil > 0

				cTab    := ''
				nPPonto := 0
				nPEsp   := 0

				// Pega o espaço/parentese antes do Alias
				For nPEsp := nPFil To 1 Step - 1
					If SubStr( cTxt, nPEsp, 1 ) $ ' /('
						Exit
					EndIf
					// Se tem ponto então tem ALIAS antes do nome do campo/coluna
					If SubStr( cTxt, nPEsp, 1 ) == '.' .And. nPPonto == 0
						nPPonto := nPEsp
					Endif
				Next

				If nPPonto > 0 .And. nPEsp > 0
					cTab := SubStr( cTxt, nPEsp+1, (nPPonto-nPEsp-1) )
					If !Empty( cTab )
						cTab := FWSX2Util():GetFile( cTab )
					Endif
				Endif

				nPAspIN := At( "'", cTxt, nPFil )       // aspas simples após a posição da palavra '_FILIAL'
				nPAspFI := At( "'", cTxt, nPAspIN+1 )   // aspas simpes que fecha a string da filial

				If( nPAspIN > 0 .And. nPAspFI > 0 .And. nPFil + 15 >= nPAspIN )
					If Empty( cTab )
						cTxt := Replace( cTxt, SubStr( cTxt, nPAspIN+1, (nPAspFI-nPAspIN-1) ), '" + xFilial( ?? ) + "' )
					Else
						cTxt := Replace( cTxt, SubStr( cTxt, nPAspIN+1, (nPAspFI-nPAspIN-1) ), '" + xFilial( "' + Left( cTab, 3 ) + '" ) + "' )
					Endif
				Endif
			Endif

			// Ajusta o nome da tabela
			nPos := At( cFirma+'0', cTxt )
			If nPos > 0
				cTab := SubStr( cTxt, nPos-3, 6 )
				cTab := FWSX2Util():GetFile( cTab )
				If !Empty( cTab )
					cTxt := Replace( cTxt, cTab, '" + RetSqlName( "' + Left(cTab,3) + '" ) + " ' )
				Endif
			Endif

			If ( At( '--', cTxt ) > 0 .Or. At( '/*', cTxt ) > 0 )
				cRet += '//cQuery += "' + cTxt + ' "' + CRLF
			Else
				cRet += 'cQuery += "' + cTxt + ' "' + CRLF
			EndIf

		EndIf
	Next

	cRet +=  CRLF + 'DbUseArea(.T.,"TOPCONECT",TcGenQry(,,cQuery),cAliTmp,.F.,.F.)' + CRLF

	For nPos := 1 To Len( aCposSel )

		If AllTrim(aCposSel[ nPos, 1 ]) $ "R_E_C_N_O_/R_E_C_D_E_L_"
			Loop
		Endif

		If aCposSel[ nPos, 2 ] $ "D/N"
			lOk := .T.
		ElseIf aCposSel[ nPos, 3 ] == 8     // Campo pode ser Data mesmo vindo como C no DBSTRUCT()
			If FWSX3Util():GetFieldType( aCposSel[ nPos, 1 ] ) == "D"
				lOk := .T.
				aCposSel[ nPos, 2 ] := "D"
			EndIf
		EndIf

		If lOk
			cRet += 'TCSetField( cAliTmp, "' + aCposSel[ nPos, 1 ] + '", "' + aCposSel[ nPos, 2 ] + '", ' + cValToChar(aCposSel[ nPos, 3 ]) + ', ' + cValToChar(aCposSel[ nPos, 4 ]) + ' )' + CRLF
			If aCposSel[ nPos, 2 ] == "N"
				cRet += '// c' + AllTrim( Replace( aCposSel[ nPos, 1 ], "_", "" ) ) + 'Picture := X3Picture( "' + aCposSel[ nPos, 1 ] + '" ) ' + CRLF
			Endif
		Endif
		lOk := .F.
	Next

	cRet += 'While (cAliTmp)->( !EOF() ) ' + CRLF+CRLF
	cRet += '   (cAliTmp)->( DbSkip() ) ' + CRLF
	cRet += 'EndDo ' + CRLF
	cRet += '(cAliTmp)->( DbCloseArea() ) ' + CRLF

	CopytoClipboard( cRet )

	MsgInfo( "Comando copiado para a área de trabalho !!" + CRLF + CRLF + ;
		     "Antes de sair do Protheus, abra o código fonte e COLE no local desejado !!" )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ExecSQL
Função que Executa os comandos digitados.
@Since      Jun/2021
@param      oPanelResultado,    object,     Painel com o resultado
@param      cSql,               character,  Comando Sql que está na "tela"
@param      cLogErro,           character,  Variável com o erro na execução
@param      cTipo,              character,  Qual é o Título que deverá ser gerado
@param      nPosCursor,         numeric,    Posição do cursos no momento da execução do comando Sql
/*/
//-------------------------------------------------------------------
Static Function ExecSQL( oPanelResultado, cSql, cLogErro, cTipo, nPosCursor )

	Local nQueryRet   := 0
	Local nX          := 0
	Local nHdl        := 0
	Local oFont       := TFont():New( "Tahoma",0,-14,,.F.,0,,700,.F.,.F.,,,,,, )
	Local cTRB        := ""
	Local cSqlDigit   := cSql
	Local cErro       := ""
	Local cCampo      := ""
	Local cMensagem   := ""
	Local cComandoSQL := UPPER( cSql )
	Local aHeaderEx   := {}
	Local aColsEx     := {}
	Local aFieldFill  := {}
	Local aStru       := {}
	Local aSQL        := {}
	Local oMGMensagem

	If( Empty( cSql ) .Or. nPosCursor <= 0 )
		Return
	EndIf

	cSql := LimpaSql( cSql, nPosCursor )

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Aqui está criando o MultiGet para as mensagens               ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMGMensagem := tMultiget():New(oSizeSup:GetDimension("MENSAGEM","LININI")+10/*Linha inicial*/,;
                                   oSizeSup:GetDimension("MENSAGEM","COLINI")+05/*Coluna inicial*/,;
                                   {| u | if( pCount() > 0, cMensagem := u, cMensagem )},oPanelMsg,;
                                   oSizeSup:GetDimension("MENSAGEM","XSIZE")-10/*Largura*/,;
                                   oSizeSup:GetDimension("MENSAGEM","YSIZE")-15/*Altura*/,oFont,,,,,.T./*lPixel*/,,,,,,.T./*lReadOnly*/,/*bValid*/,,,.T./*lNoBorder*/,.T./*lVScroll*/)

	If ( 'INSERT ' $ cComandoSQL .OR. 'UPDATE ' $ cComandoSQL .OR. ' INTO ' $ cComandoSQL )

		aSQL:= StrTokArr( strtran(cSql,CRLF," "), "#" ) // troca o ENTER por ESPAÇO para compatibilizar  e depois divide por instruções

		Processa({|| cErro := RunSql(aSQL)}," Processando Intruções SQL...")

		oMGMensagem:AppendText( "Comando executado " + IIF( Empty( cErro ), "sem", "com" ) + " erro !" )

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Aqui está criando o MultiGet com OU sem erro do gerado       ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		tMultiget():New(oSize:GetDimension("INFERIOR","LININI")+10,; //nTop
                        oSize:GetDimension("INFERIOR","COLINI")+05,; //nLeft
                        {| u | if( pCount() > 0, cErro := u, cErro )},oPanelResultado,;
                        oSize:GetDimension("INFERIOR","XSIZE")-10,;//nLargura
                        oSize:GetDimension("INFERIOR","YSIZE")-15,;//nAltura
                        oFont,,,,,.T./*lPixel*/,,,,,,.F./*lReadOnly*/)

	ElseIf 'SELECT ' $ cComandoSQL

		If TCSQLEXEC(cSql) < 0
			cErro := TCSQLError()

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Aqui está criando o MultiGet com o erro do SQL gerado        ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			tMultiget():New(oSize:GetDimension("INFERIOR","LININI")+10,; //nTop
                            oSize:GetDimension("INFERIOR","COLINI")+05,; //nLeft
                            {| u | if( pCount() > 0, cErro := u, cErro )},oPanelResultado,;
                            oSize:GetDimension("INFERIOR","XSIZE")-10,;//nLargura
                            oSize:GetDimension("INFERIOR","YSIZE")-15,;//nAltura
                            oFont,,,,,.T./*lPixel*/,,,,,,.F./*lReadOnly*/)

			cLogErro := cErro
			oMGMensagem:AppendText( "" )
		Else
			cLogErro := ""
			cTRB     := GetNextAlias()

			// Função padrão que executa a consulta e carrega na tabela cTRB
			MPSysOpenQuery( cSql, cTRB )
			aStru := (cTRB)->(DBSTRUCT())

			For nX := 1 to Len(aStru)
				cCampo := aStru[nX][1]

				If cTipo == "Titulo"
					cTitulo := AllTrim(FWX3Titulo(cCampo) )
					If Empty(cTitulo)
						cTitulo := cCampo
					Endif
				Else
					cTitulo := cCampo
				EndIf

				Aadd(aHeaderEx,{ cTitulo, cCampo, "", aStru[nX][3], aStru[nX][4], ".T.", ".T.", aStru[nX][2] , "", "", "", ""} )
			Next nX

			// Se não tem dados, cria uma linha vazia
			If (cTRB)->( EOF() )
				Aadd(aColsEx, Array( Len(aStru) ) )
			Else
				// Faz a Leitura dos dados
				While !(cTRB)->(EOF())
					For nX := 1 to Len(aStru)
						cCampo := aStru[nX][1]
						Aadd(aFieldFill,  &('(cTRB)->' + cCampo ))
					Next nX
					Aadd(aFieldFill, .F.) // Delete

					Aadd(aColsEx, aFieldFill)
					aFieldFill := {}
					nQueryRet++

					(cTRB)->(DBSkip())
				Enddo
			EndIf

			(cTRB)->( DbCloseArea() )

			oMGMensagem:AppendText( "Consulta retornou " + cValToChar( nQueryRet ) + " registros." )

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Aqui está criando o Grid com os resultados                   ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oGridResult := MsNewGetDados():New( oSize:GetDimension("INFERIOR","LININI")+10,; // nTop
                                                oSize:GetDimension("INFERIOR","COLINI")+05,; // nLeft
                                                oSize:GetDimension("INFERIOR","LINEND")-05,; // nBottom
                                                oSize:GetDimension("INFERIOR","COLEND")-05,; // nRight
                                                0,;	     		                             // nStyle // GD_INSERT+GD_DELETE+GD_UPDATE
                                                "AllwaysTrue()",;							 // cLinhaOk
                                                ,;											 // cTudoOk
                                                "",;										 // cIniCpos
                                                ,;											 // aAlter
                                                ,;											 // nFreeze
                                                99,;										 // nMax
                                                ,;											 // cFieldOK
                                                ,;											 // cSuperDel
                                                ,;											 // cDelOk
                                                oPanelResultado,;					         // oWnd
                                                aHeaderEx,;								     // aHeader
                                                aColsEx)									 // aCols

			oGridResult:nAt := 1
			oGridResult:oBrowse:nAt := 1
			oGridResult:Refresh()
		EndIf
	Else
		oMGMensagem:AppendText("Comando não permitido!")
	EndIf

	nHdl := 0
	nHdl := FCreate( cArqUser )

	If nHdl = -1
		MsgAlert("Erro na criação do arquivo")
	Else
		FWrite( nHdl, cSqlDigit + CRLF)
		FClose( nHdl )
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RunSql
Função que efetivamente irá executar o Insert ou Update digitado.
@Since      Jun/2021
@param      aSQL,       array,  Comandos a serem executados
@return     character,  Erro na execução do comando SQL
/*/
//-------------------------------------------------------------------
Static Function RunSql( aSQL )

	Local nX      := 0
	Local nLenSQL := Len( aSql )
	Local cSqlEx  := ""
	Local cErro   := ""

	ProcRegua( nLenSQL )

	For nX:= 1 To nLenSQL

		IncProc("Processando Instrução " + alltrim(STR(nX)) + ' de ' + alltrim( STR( nLenSQL ) ) )

		cSqlEx := aSQL[nX]

		If TCSQLEXEC(cSqlEx) < 0
			lErro := .T.
			cErro += TCSQLError() + CRLF
		EndIf

	Next nX

Return( cErro )


//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaSql
Função para pegar somente o comando SQL que deve ser executado
@Since      Jun/2021
@param      cSql,       character,  Comando SQL
@param      nPosCursor, numeric,    Posição do cursor no momento da chamada da execução
@return     character,  Comando SQL que será executado, ou seja, o que estive entre ;
/*/
//-------------------------------------------------------------------
Static Function LimpaSql( cSql, nPosCursor )

	Local nPosIni := 0
	Local nPosFim := 0
	Local nPosCom := 0

	// Localiza o ; apos a posição do cursor
	nPosFim := At( ";", cSql, nPosCursor )

	If nPosFim > 0
		// Pega todo o texto desde o inicio ate o ; apos a posição do cursor
		cSql := SubStr( cSql, 1, nPosFim-1 )

		// Pega a posicao do ULTIMO ; sendo que pode não existir
		nPosIni := RAt( ";", cSql ) + 1
	Else        // Se não tem o ; apos o cursor, pega o ultimo ; localizado
		nPosIni := RAt( ";", cSql ) + 1
	EndIf

	If nPosIni > 0
		// Pega somente o que deve ser executado
		cSql := SubStr( cSql, nPosIni )
	EndIf

	nPosCom := At( '--', cSql )
	If nPosCom <= 0
		nPosCom := At( '/*', cSql )
	Endif

	// Retira a linha comentada no início do código
	If nPosCom > 0
		nPosIni := At( "SELECT ", Upper(cSql) )
		If nPosIni <= 0
			nPosIni := At( "UPDATE ", Upper(cSql) )
			If nPosIni <= 0
				nPosIni := At( "INSERT ", Upper(cSql) )
			Endif
		Endif

		// Comentário antes do comando "inicial" de qualquer instrução SQL permitida
		If nPosCom < nPosIni
			cSql := SubStr( cSql, nPosIni )
		Endif
	Endif

Return( cSql )


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraExcel
Função que gera um arquivo com os dados localizados e também com o comando SQL executado.
Sendo que irá gerar esse arquivo no formato .XLS quando tiver o Excel instalado, OU então
cria um arquivo .CSV
@Since      Jun/2021
@param      cSql,           character,  Comando Sql
@param      cLogErro,       character,  Log com o erro
@param      nPosCursor,     numeric,    Posição do cursor no momento da chamada da rotina
/*/
//-------------------------------------------------------------------
Static Function GeraExcel( cSql, cLogErro, nPosCursor )

	Local nX, nY
	Local nHdr     := 0
	Local nModo         // Modo do Tipo do Campo| 1 = Modo Texto ou data | 2 = Valor sem R$ | 3 = Valor com R$
	Local aHeader  := {}
	Local aCols    := {}
	Local aLinha
	Local aArea    := {}
	Local cAba01
	Local cTitTabela01
	Local cAba02
	Local cTmp     := ""
	Local cTitTabela02
	Local X_TIPO   := 8
	Local X_TITULO := 1
	Local oFWMsExcel
	Local oExcel
	Local cTime    := ""
	Local cArquivo := ""

	If !Empty( cLogErro )
		MsgInfo("Não é possível gerar o excel com erro!")
		Return
	EndIf

	cSql := LimpaSql( cSql, nPosCursor )

	aHeader  := oGridResult:aHeader
	aCols    := oGridResult:aCols
	aArea    := GetArea()
	cTime    := time()
	cArquivo := GetTempPath()+'superqry-temp-' + SUBSTR(cTime,1,2) + "H" + SUBSTR(cTime,4,2) + '.xml'

	If ApOleClient("MSExcel")
		// Criando o objeto que irá gerar o conteúdo do Excel
		oFWMsExcel := FWMSExcel():New()
		oFWMsExcel:SetTitleBold(.T.)    // Título em Negrito

		// Aba 01 - Dados
		cAba01 := "Dados"
		cTitTabela01 := 'Dados da Consulta'
		oFWMsExcel:AddworkSheet(cAba01) // Não utilizar número junto com sinal de menos. Ex.: 1-

		// Criando a Tabela
		oFWMsExcel:AddTable(cAba01,cTitTabela01)

		// Criando Colunas
		For nX := 1 to Len(aHeader)
			DO CASE
                CASE aHeader[nx,X_TIPO] $ 'C'
                    nModo := 1  // 1 = Modo Texto
                CASE aHeader[nx,X_TIPO] $ 'D'
                    nModo := 1
                CASE aHeader[nx,X_TIPO] $ 'N'
                    nModo := 2  // 2 = Valor sem R$ | 3 = Valor com R$
                OTHERWISE
                    nModo := 1
			END CASE
			oFWMsExcel:AddColumn(cAba01,cTitTabela01,aHeader[nx,X_TITULO],nModo)
		Next nX
		
        // Criando as Linhas
		For nX := 1 to Len(aCols)
			aLinha := {}
			For nY := 1 to LEN(aCols[nX])-1
				AADD(aLinha, aCols[nX][nY])
			Next nY
			oFWMsExcel:AddRow(cAba01,cTitTabela01,aLinha)
		Next nX


		// Aba 02 - Sql
		cAba02 := "SQL"
		cTitTabela02 := 'Consulta SQL'

		oFWMsExcel:AddworkSheet(cAba02)

		// Criando a Tabela
		oFWMsExcel:AddTable(cAba02,cTitTabela02)
		oFWMsExcel:AddColumn(cAba02,cTitTabela02,"Consulta",1)

		// Criando as Linhas... Enquanto não for fim da query
		oFWMsExcel:AddRow(cAba02,cTitTabela02,{cSql})

		// Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)

		// Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()           // Abre uma nova conexão com Excel
		oExcel:WorkBooks:Open(cArquivo)     // Abre uma planilha
		oExcel:SetVisible(.T.)              // Visualiza a planilha
		oExcel:Destroy()                    // Encerra o processo do gerenciador de tarefas

	Else    // Não tem Excel instalado

		// Pega o nome do arquivo, mas sem a extensão XML para usar o CSV
		cArquivo := Left( cArquivo, Len(cArquivo)-3 ) + "csv"

		nHdr := FCreate( cArquivo )
		If nHdr <= 0
			MsgInfo( 'Não foi possível criar o arquivo "' + cArquivo + '"'+CRLF+'Verifique se o arquivo está em uso.')
		Else
			// Carrega o Cabeçalho das colunas
			For nX := 1 to Len(aHeader)
				cTmp += cValToChar( aHeader[ nX, 1 ] ) + ";"
			Next nX
			FWrite( nHdr, cTmp + CRLF )

			// Carrega os dados para gerar cada Linha
			For nX := 1 to Len(aCols)

				cTmp := ""
				For nY := 1 to LEN(aCols[nX])-1
					cTmp += cValToChar( aCols[ nX, nY ] ) + ";"
				Next nY
				FWrite( nHdr, cTmp + CRLF )

			Next nX

			// No final gera uma linha com o SQL executado
			fWrite( nHdr, strtran(cSql,CRLF," ") + CRLF)

			FClose( nHdr )
			ShellExecute("open", cArquivo, "", GetTempPath(), 1)
		EndIf
	EndIf

	RestArea(aArea)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Mysend
Função para enviar o erro por e-mail
@Since      Jun/2021
@param      cTxt,   character,  Texto com o erro
/*/
//-------------------------------------------------------------------
Static Function Mysend( cTxt )

	Local lEnvia := .F.

	Static oDlgLog
	Static oButton1
	Static oButton2
	Static oGet1
	Static cGet1 := ""
	Static oSay

	If Empty( cTxt )
		MsgInfo("Não tem erro para enviar log !")
		Return
	EndIf

	cGet1 := PadR( AllTrim( UsrRetMail( RetCodUsr() ) ), 200 )

	DEFINE MSDIALOG oDlgLog TITLE "Envio de Log" FROM 000, 000  TO 150, 300 COLORS 0, 12632256 PIXEL

	@ 031, 015 MSGET oGet1 VAR cGet1 SIZE 114, 010 OF oDlgLog PICTURE "@!" VALID !Empty(Alltrim(cGet1)) COLORS 0, 16777215 PIXEL
	@ 016, 015 SAY oSay PROMPT "Por favor, entre com seu e-mail ABAIXO:" SIZE 100, 007 OF oDlgLog PICTURE "@!" COLORS 0, 12632256 PIXEL

	@ 050, 025 BUTTON oButton1 PROMPT "Enviar" SIZE 040, 012 OF oDlgLog ACTION {||lEnvia := .T.,oDlgLog:End()} PIXEL
	@ 050, 075 BUTTON oButton2 PROMPT "Sair" SIZE 040, 012 OF oDlgLog ACTION oDlgLog:End()  PIXEL

	ACTIVATE MSDIALOG oDlgLog CENTERED

	If lEnvia
		CONNECT SMTP SERVER GETMV("MV_RELSERV") ACCOUNT GETMV("MV_RELACNT") PASSWORD GETMV("MV_RELPSW") RESULT lResult

		If !lResult
			MsgBox("Erro no Envio")
			Return()
		EndIf

		cAccount := GETMV("MV_RELACNT")

		SEND MAIL FROM cAccount;
                  TO cGet1;
                  SUBJECT "Executar Query";
                  BODY cTxt

		DISCONNECT SMTP SERVER

		MsgInfo("Email Enviado com Sucesso!")
	EndIf

Return
