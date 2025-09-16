#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "FWCSS.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} IMP_BLCK
@Type			: Função de Usuário
@Sample			: U_IMP_BLCK()
@Description	: Função para importar planilhas .CSV para geração do Bloco K
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Jul/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum 
/*/
//--------------------------------------------------------------------------------------
User Function IMP_BLCK(_LimpaLog)

    Local aSize     := FWGetDialogSize( oMainWnd )
    Local oWorkArea := Nil
    Local oMenu     := Nil
    Local cMenuFld1 := ""
    Local cMenuFld2 := ""
    Local oMenuItem := Nil

    Private oDlgWA  := Nil
    Private lProc   := .T.

	Default _LimpaLog := "S"

	// Limpa tabelas de logs somente na entrada da rotina, pois quando processado, matém os dados do processamento
	If _LimpaLog == "S"
		// Deleta dados da tabela ZM0 para nova carga de dados
		_cQueryA := "DELETE FROM " + RetSqlName("ZM0")
		_cQueryA += " WHERE ZM0_FILIAL = '" + FWxFilial("ZM0") + "'" 

		If TcSQLExec(_cQueryA) < 0	
			MsgStop(TcSqlError())
		Endif

		// Deleta dados da tabela ZM1 para nova carga de dados
		_cQueryB := "DELETE FROM " + RetSqlName("ZM1")
		_cQueryB += " WHERE ZM1_FILIAL = '" + FWxFilial("ZM1") + "'" 

		If TcSQLExec(_cQueryB) < 0	
			MsgStop(TcSqlError())
		Endif

		// Deleta dados da tabela ZM1 para nova carga de dados
		_cQueryC := "DELETE FROM " + RetSqlName("ZM2")
		_cQueryC += " WHERE ZM2_FILIAL = '" + FWxFilial("ZM2") + "'" 

		If TcSQLExec(_cQueryC) < 0	
			MsgStop(TcSqlError())
		Endif
	EndIf

	oDlgWA := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "Importação de Arquivos para o Bloco K", , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

	oWorkArea := FWUIWorkArea():New( oDlgWA )
	oWorkArea:SetMenuWidth( 215 )

	oMenu := FWMenu():New()
	oMenu:Init()

	cMenuFld1 := oMenu:AddFolder( "Principal", "E" )
	oMenuItem := oMenu:GetItem(cMenuFld1) 
	oMenuItem:AddSeparator()
	oMenuItem:AddContent( "Sair", "E", {|| If(CloseScreen(),oDlgWA:End(),.T.) } )
	oMenuItem:AddSeparator()
	cMenuFld2 := oMenu:AddFolder( "LOGs TEMPORÁRIOS", "E" )
	oMenuItem := oMenu:GetItem(cMenuFld2) 
	oMenuItem:AddSeparator()
	oMenuItem:AddContent( "1) Log Geração OPs (SC2)", 		"E", {|| U_ZM0GRID() } )
	oMenuItem:AddContent( "2) Log Empenhos Múltiplos (SD4)","E", {|| U_ZM1GRID() } )
	oMenuItem:AddContent( "3) Log Apont. Produção (SD3)",	"E", {|| U_ZM2GRID() } )

	oWorkArea:SetMenu( oMenu )

	oWorkArea:CreateHorizontalBox( "LINE01", aSize[3], .T.)
	oWorkArea:SetBoxCols( "LINE01", { "WDGT01" } )

	oWorkArea:Activate()

	oDlgWA:Activate(,,,,,,{|| BLKMain( oWorkArea ) }) 

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CloseScreen
Função que monta tela de saída
@author     Evandro Mugnol
@since      Jul/2024
/*/
//-------------------------------------------------------------------
Static Function CloseScreen()

    Local oModal
    Local oContainer
    Local oSay := Nil
    Local lRet := .F.
    
    oModal := FWDialogModal():New()        
    oModal:SetEscClose(.T.)
    oModal:setTitle("SAIR")
    oModal:setSize(100, 150)
    oModal:createDialog()
    oModal:addYesNoButton()

    oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT
        
    oSay := TSay():New(4,4,{|| "Deseja realmente sair do programa? "},oContainer,,,,,,.T.,,,98,98,,,,,,.T.)

    oModal:Activate()

    If oModal:getButtonSelected()
        lRet := .T.
    EndIf

Return lRet


//----------------------------------------------------------------------
/*/{Protheus.doc} BLKMain
Função da tela principal
@author     Evandro Mugnol
@since      Jul/2024
/*/
//----------------------------------------------------------------------
Static Function BLKMain( oWaMain )
    Local oPanel        := oWaMain:GetPanel( "WDGT01" )
    Local oLogo         := Nil
    Local oPanelFull    := Nil
    Local oPanelLogo    := Nil
    Local oPanelTit     := Nil
    Local oTextTit      := Nil
    Local oPanelLeft    := Nil
    Local oPanelRight   := Nil
    Local oPanelFilter  := Nil
    Local oPanelDesc    := Nil
    Local oPanelProc    := Nil
    Local oBtProc       := Nil
    Local oGet01        := Nil
	Local cGet01        := Space(150)
    Local oGet02        := Nil
	Local cGet02        := Space(150)
	Local oGetOPDe		:= Nil
	Local cGetOPDe		:= Space(14)
	Local oGetOPAte		:= Nil
	Local cGetOPAte		:= Space(14)
	Local oGetTPMov		:= Nil
	Local cGetTPMov		:= Space(03)
	Local oGetDTApo		:= Nil
	Local dGetDTApo		:= Ctod("")

    // Limpa o Painel
    oPanel:freeChildren()
    
    oPanelFull := TPanelCss():New(0,0,"",oPanel,,.F.,.F.,,,oPanel:nWidth/2,oPanel:nHeight/2,.T.,.F.)
    oPanelFull:SetCSS("TPanelCss { background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; }")
    
    oPanelLogo := TPanelCss():New(0,(oPanelFull:nWidth/4)-40,"",oPanelFull,,.F.,.F.,,,83.5,80,.T.,.F.)
    oPanelLogo:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
    oPanelLogo:Align := CONTROL_ALIGN_TOP
    oPanelLogo:ReadClientCoors(.T.,.T.)
    
    oLogo := TBitmap():New(0,(oPanelLogo:nWidth/4)-130,0,0,,"\SYSTEM\FW_LOGOSILVABLOCOK.PNG",.T.,oPanelLogo,,,.F.,.F.,,,.F.,,.T.,,)
    oLogo:lAutoSize := .T.

    oPanelTit := TPanelCss():New(0,(oPanelFull:nWidth/4)-40,"",oPanelFull,,.F.,.F.,,,0,70,.T.,.F.)
    oPanelTit:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
    oPanelTit:Align := CONTROL_ALIGN_TOP
    oPanelTit:ReadClientCoors(.T.,.T.)

    oTextTit := tSimpleEditor():New(0,(oPanelTit:nWidth/4)-150, oPanelTit,300 ,70,,.T.,,,.T. )
    oTextTit:Setcss("color: #757776; font-size: 20px; background-color : transparent; border: 0px; ") 
    oTextTit:Load("<h1 align='center'>Importação de Arquivos para Geração Bloco K</h1>")

    oPanelLeft := TPanelCss():New(0,(oPanelFull:nWidth/4)-40,"",oPanelFull,,.F.,.F.,,,(oPanelFull:nWidth/4)+2,80,.T.,.F.)
    oPanelLeft:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
    oPanelLeft:Align := CONTROL_ALIGN_LEFT
    oPanelLeft:ReadClientCoors(.T.,.T.)
    
    oPanelDesc := TPanelCss():New(2,2,"",oPanelLeft,,.F.,.F.,,,(oPanelLeft:nWidth/2)-4,(oPanelLeft:nHeight/2)-4 ,.T.,.F.)
    oPanelDesc:SetCSS("TPanelCss { background-color : #FCFAF9; border: 1px solid #DCDCDC;  border-radius: 4px;}") 

    oTextDesc := tSimpleEditor():New(2,2, oPanelDesc,(oPanelDesc:nWidth/2)-4,(oPanelDesc:nHeight/2)-32,,.T.,,,.T. )
    oTextDesc:Setcss("background-color : transparent; border: 1px solid #DCDCDC;  border-radius: 4px; ") 
    oTextDesc:Load("<strong>Esta rotina tem por objetivo efetuar a leitura de arquivos no formato CSV, " + ;
                    "disponibilizados pelo setor responsável, os quais irão demonstrar em tela o conteúdo " + ;
                    "de cada um deles em sequência, para posteriormente gravar os respectivos movimentos " + ;
                    "no sistema, com a finalidade de gerar os registros para o Bloco K.</strong><br />" + ;
                    "<p>Informe os arquivos a serem processados ao lado e clique em Processar para iniciar.</p><br />"+;
                    "Atenção: Dependendo do conteúdo / tamanho dos arquivos, pode demorar para processar, porém evite derrubar "+;
                    "o sistema enquanto o sistema está em processamento.")
    
    oPanelLink := TPanelCss():New((oPanelLeft:nHeight/2)-30,4,"",oPanelLeft,,.F.,.F.,,,(oPanelLeft:nWidth/2)-8,26 ,.T.,.F.)
    oPanelLink:SetCSS("TPanelCss { background-color : #FCFAF9; border: 0px solid #DCDCDC;  border-radius: 4px;}") 

    oBtnLei1 := TButton():New( 0, 0, "Guia de Referência do Bloco K"   ,oPanelLink,, oPanelLink:nWidth/2 ,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
    oBtnLei1:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 1px solid #DCDCDC; border-radius: 4px;}")
    oBtnLei1:bLClicked := {|| ShellExecute("open", "http://tdn.totvs.com/pages/releaseview.action?pageId=235589625" ,"","",SW_SHOW) }

    oBtnLei2 := TButton():New(14, 0, "MANUAL do Bloco K - Frig. Silva" ,oPanelLink,, oPanelLink:nWidth/2 ,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
    oBtnLei2:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 1px solid #DCDCDC; border-radius: 4px;}")
    oBtnLei2:bLClicked := {|| ShellExecute("open", "https://docs.google.com/document/d/1YtSrhFoiQfRDhlsgbO7NTXXMTVbHu-xEBz13R77oxTk/edit?usp=sharing" ,"","",SW_SHOW) }

    oPanelRight := TPanelCss():New(0,(oPanelFull:nWidth/4)-40,"",oPanelFull,,.F.,.F.,,,(oPanelFull:nWidth/4)-4,80,.T.,.F.)
    oPanelRight:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
    oPanelRight:Align := CONTROL_ALIGN_RIGHT
    oPanelRight:ReadClientCoors(.T.,.T.)
    
    oPanelFilter := TPanelCss():New(2,2,"",oPanelRight,,.F.,.F.,,,(oPanelRight:nWidth/2)-4,(oPanelRight:nHeight/2)-34 ,.T.,.F.)
    oPanelFilter:SetCSS("TPanelCss { background-color : #FCFAF9; border: 1px solid #DCDCDC;  border-radius: 4px;}") 

    oFont3 := TFont():New("Arial",,-11,,.T.,,,,,,.F.)
    oSayTitle:= TSay():New(2,2,{|| ""},oPanelFilter,,oFont3,,,,.T.,,,(oPanelFilter:nWidth/2)-4,15,,,,,,.T.)
    oSayTitle:SetCss("background-color : #E9F0F6; border: 1px #DCDCDC; border-top-left-radius: 4px; border-top-right-radius: 4px;")

    oSayTitle2:= TSay():New(6,6,{|| "Definição de Arquivos"},oPanelFilter,,oFont3,,,,.T.,,,100,20,,,,,,.T.)
    oSayTitle2:SetCss("background-color : transparent; color : #757776}")

    oSay   := tSay():New(25, 004, {|| "1) Arquivo Ordens de Produção (SC2):" }  , oPanelFilter,,,,,,.T.,,,200,10)
	oGet01 := TGet():New(23, 105, {|u| If(PCount() > 0 , cGet01 := u, cGet01)}  , oPanelFilter, 170, 010, "@!", /*bValid*/, 0,16777215, ,.F.,,.T.,,.F.,{||.T.}/*When*/,.F.,.F.,,,.F. ,,,,,,.T. )
    oGet01:cTooltip := 'Caminho completo do arquivo de importação das ordens de produção'
    oGet01:cF3      := 'DIR'
    oGet01:bHelp    := {|| ShowHelpCpo( 'AjudaSC2', {' INFORMAR O CAMINHO COMPLETO DO ARQUIVO DE IMPORTAÇÃO DAS ORDENS DE PRODUÇÃO '}, 0 ) }

    oSay   := tSay():New(45, 004, {|| "2) Arquivo Empenhos Múltiplos (SD4):" }  , oPanelFilter,,,,,,.T.,,,200,10)
	oGet02 := TGet():New(43, 105, {|u| If(PCount() > 0 , cGet02 := u, cGet02)}  , oPanelFilter, 170, 010, "@!", /*bValid*/, 0,16777215, ,.F.,,.T.,,.F.,{||.T.}/*When*/,.F.,.F.,,,.F. ,,,,,,.T. )
    oGet02:cTooltip := 'Caminho completo do arquivo de importação de empenhos múltiplos'
    oGet02:cF3      := 'DIR'
    oGet02:bHelp    := {|| ShowHelpCpo( 'AjudaSD4', {' INFORMAR O CAMINHO COMPLETO DO ARQUIVO DE IMPORTAÇÃO DE EMPENHOS MÚLTIPLOS '}, 0 ) }

    oTextFilt := tSimpleEditor():New(65,2, oPanelFilter,(oPanelFilter:nWidth/2)-4,(oPanelFilter:nHeight/2)-67,,.T.,,,.T. )
    oTextFilt:Setcss("background-color : transparent; border: 1px solid #DCDCDC;  border-radius: 4px; ") 
    oTextFilt:Load("<font color=red><strong>Os parâmetros abaixo só devem ser informados no caso em que forem realizados " + ;
                    "os apontamentos de produção. É recomendado que os apontamentos de produção sejam feitos " + ;
                    "de forma exclusiva, ou seja, que este processamento seja independente dos 2 acima.</strong></font>")

    oSay 	 := tSay():New(095, 004, {|| "Da Ordem de Produção:" },oPanelFilter,,,,,,.T.,,, 080, 010)
    oGetOPDe := TGet():New(093, 080, {|u| If( PCount() == 0, cGetOPDe, cGetOPDe := u ) },oPanelFilter, 060, 010,"@!",,0,16777215, ,.F.,,.T.,,.F.,{||.T.}/*When*/,.F.,.F.,,,.F. ,,,,,,.T. )
    oGetOPDe:cF3 := 'SC2'

    oSay 	  := tSay():New(110, 004, {|| "Até a Ordem de Produção:" },oPanelFilter,,,,,,.T.,,, 080, 010)
    oGetOPAte := TGet():New(108, 080, {|u| If( PCount() == 0, cGetOPAte, cGetOPAte := u ) },oPanelFilter, 060, 010,"@!",,0,16777215,,.F.,,.T.,,.F.,{||.T.}/*When*/,.F.,.F.,,,.F. ,,,,,,.T. )
    oGetOPAte:cF3 := 'SC2'

    oSay 	  := tSay():New(125, 004, {|| "TP Movto p/ Apontamento:" },oPanelFilter,,,,,,.T.,,, 080, 010)
    oGetTPMov := TGet():New(123, 080, {|u| If( PCount() == 0, cGetTPMov, cGetTPMov := u ) },oPanelFilter, 025, 010,"@!",,0,16777215,,.F.,,.T.,,.F.,{||.T.}/*When*/,.F.,.F.,,,.F. ,,,,,,.T. )
    oGetTPMov:cF3 := 'SF5'

    oSay      := tSay():New(140, 004, {|| "Data p/ Apontamento:" },oPanelFilter,,,,,,.T.,,, 080,10)
    oGetDTApo := TGet():New(138, 080, {|u| If( PCount() == 0, dGetDTApo, dGetDTApo := u ) },oPanelFilter, 060, 010,"@D",,0,16777215,,.F.,,.T.,,.F.,{||.T.}/*When*/,.F.,.F.,,,.F. ,,,,,,.T. )

    oPanelProc := TPanelCss():New((oPanelRight:nHeight/2)-30,2,"",oPanelRight,,.F.,.F.,,,(oPanelRight:nWidth/4)-4,28 ,.T.,.F.)
    oPanelProc:SetCSS("TPanelCss { background-color : #FCFAF9; border: 1px solid #DCDCDC;  border-radius: 4px;}") 
    
    bProcBloc:= {|| ProcArqs(cGet01, cGet02, cGetOPDe, cGetOPAte, cGetTPMov, dGetDTApo)}

    oBtProc := TButton():New( 2, 2, "Processar",oPanelProc,bProcBloc, (oPanelProc:nWidth/2)-4,(oPanelProc:nHeight/2)-4,,,.F.,.T.,.F.,,.F.,,,.F. )

    If !lProc
        oBtProc:Disable()
    Endif

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcArqs
Função de processamento dos arquivos informados
@author     Evandro Mugnol
@since      Jul/2024
/*/
//-------------------------------------------------------------------
Static Function ProcArqs(cGet01, cGet02, cGetOPDe, cGetOPAte, cGetTPMov, dGetDTApo)

    Local _cArq01 := AllTrim(cGet01)
    Local _cArq02 := AllTrim(cGet02)
	Local _cOPIni := cGetOPDe
	Local _cOPFim := cGetOPAte
	Local _cTPMov := cGetTPMov
	Local _dDTApo := dGetDTApo

	Private _lPrim   := .T.
	Private _aCampos := {}
	Private _aDados  := {}
	Private _cLinha  := ""

	// Deleta dados da tabela ZM0 para nova carga de dados
	_cQueryA := "DELETE FROM " + RetSqlName("ZM0")
	_cQueryA += " WHERE ZM0_FILIAL = '" + FWxFilial("ZM0") + "'" 

	If TcSQLExec(_cQueryA) < 0	
		MsgStop(TcSqlError())
	Endif

	// Deleta dados da tabela ZM1 para nova carga de dados
	_cQueryB := "DELETE FROM " + RetSqlName("ZM1")
	_cQueryB += " WHERE ZM1_FILIAL = '" + FWxFilial("ZM1") + "'" 

	If TcSQLExec(_cQueryB) < 0	
		MsgStop(TcSqlError())
	Endif

	// Deleta dados da tabela ZM1 para nova carga de dados
	_cQueryC := "DELETE FROM " + RetSqlName("ZM2")
	_cQueryC += " WHERE ZM2_FILIAL = '" + FWxFilial("ZM2") + "'" 

	If TcSQLExec(_cQueryC) < 0	
		MsgStop(TcSqlError())
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua validações quanto aos parâmetros informados            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(_cArq01) .And. !Empty(_cArq02))
		FWAlertWarning("Não é permitido informar parâmetros para importar ordens de produção e empenhos múltiplos no mesmo processamento.", "Parâmetros informados incorretamente.")
		// Fecha tela principal ao final dos processamento e reabre para trazer parâmetros de seleção de arquivos vazios
		oDlgWA:End()
		U_IMP_BLCK("N")
		Return
	EndIf

	If (!Empty(_cArq01) .Or. !Empty(_cArq02)) .And. (!Empty(_cOPIni) .Or. !Empty(_cOPFim) .Or. !Empty(_cTPMov) .Or. !Empty(_dDTApo))
		FWAlertWarning("Não permitido informar parâmetros do primeiro grupo juntamente com parâmetros de apontamentos de OPs.", "Parâmetros informados incorretamente.")
		// Fecha tela principal ao final dos processamento e reabre para trazer parâmetros de seleção de arquivos vazios
		oDlgWA:End()
		U_IMP_BLCK("N")
		Return
	ElseIf (Empty(_cArq01) .And. Empty(_cArq02)) .And. (Empty(_cOPIni) .Or. Empty(_cOPFim) .Or. Empty(_cTPMov) .Or. Empty(_dDTApo))
		FWAlertWarning("É obrigatório informar todos parâmetros de apontamentos de OPs.", "Parâmetros apontamentos OPs vazios.")
		// Fecha tela principal ao final dos processamento e reabre para trazer parâmetros de seleção de arquivos vazios
		oDlgWA:End()
		U_IMP_BLCK("N")
		Return
	EndIf

	If !Empty(_cArq01)
		// Importa os dados do arquivo para um vetor
		MsAguarde({|| ArqVetor(_cArq01)}, "Aguarde","Efetuando carga de dados das ordens de produção ...")

		// Varre o vetor para gerar a tabela intermediária ZM0 
		MsAguarde({|| ImpOP()}, "Aguarde","Importando dados das ordens de produção ...")

		// Monta tela para processamento dos dados importados e posteriormente gera as ordens de produção
		_TelaOP()
	EndIf

	If !Empty(_cArq02)
		// Importa os dados do arquivo para um vetor
		MsAguarde({|| ArqVetor(_cArq02)}, "Aguarde","Efetuando carga de dados dos empenhos múltiplos ...")

		// Varre o vetor para gerar a tabela intermediária ZM1 
		MsAguarde({|| ImpEMPM()}, "Aguarde","Importando dados dos empenhos múltiplos ...")

		// Monta tela para processamento dos dados importados e posteriormente gera os empenhos múltiplos
		_TelaEMPM()
	EndIf

	If (Empty(_cArq01) .And. Empty(_cArq02))
		If !Empty(_cOPIni) .And. !Empty(_cOPFim) .And. !Empty(_cTPMov) .And. !Empty(_dDTApo)
			// Filtra odens de produção conforme parâmetros para gerar a tabela intermediária ZM2 
			MsAguarde({|| FiltOPs(_cOPIni, _cOPFim)}, "Aguarde","Filtrando ordens de produção a serem apontadas ...")

			// Monta tela para processamento dos dados filtrados e posteriormente gera os apontamentos de produção
			_TelaENC(_cTPMov, _dDTApo)
		Else
			FWAlertWarning("É obrigatório informar todos parâmetros de apontamentos de OPs para encerramento das mesmas.", "Parâmetros apontamentos OPs vazios.")
			Return
		EndIf
	EndIf

	// Fecha tela principal ao final dos processamento e reabre para trazer parâmetros de seleção de arquivos vazios
	oDlgWA:End()
	U_IMP_BLCK("N")

Return


//----------------------------------------------------------------------
/*/{Protheus.doc} ArqVetor
Função que importa os dados do arquivo para um vetor
@author     Evandro Mugnol
@since      Jul/2024
/*/
//----------------------------------------------------------------------
Static Function ArqVetor(_cArq)

	// Verifica se o arquivo existe
	If !File(_cArq)
		MsgStop("O arquivo '" + _cArq + "' não foi encontrado. A importação será abortada.", "[" + FunName() + "] - Atenção!")
		Return
	EndIf

	FT_FUSE(_cArq) 		    	// Seleciona o arquivo para usar
	ProcRegua(FT_FLASTREC()) 	// Seta a regua para o numero de registros encontrados
	_nNumReg := FT_FLASTREC() 	// Seta o _nNumReg para o numero de registros encontrados, para usar no IncProc
	FT_FGOTOP() 				// Posiciona o arquivo no primeiro registro

	_nNumLendo := 0
	While !FT_FEOF()
		_nNumLendo++

		IncProc("Lendo registro " + cValToChar(_nNumLendo) + " de " + cValToChar(_nNumReg) + "...")

		_cLinha := FT_FREADLN() 	// Joga a linha do arquivo para a variavel

		If _lPrim 					// Se for o primeiro registro entao os dados contem os nomes dos campos que serao inseridos
			_aCampos := Separa(_cLinha, ";", .T.)
			_lPrim := .F.
		Else
			aAdd(_aDados, Separa(_cLinha, ";", .T.))
		EndIf

		FT_FSKIP()
	EndDo

	FT_FUSE() 					// Fecha o arquivo que estava em uso

Return


//----------------------------------------------------------------------
/*/{Protheus.doc} ImpOP
Função que importa os dados do arquivo CSV para a tabela intermediária
de ordens de produção
@author     Evandro Mugnol
@since      Jul/2024
/*/
//----------------------------------------------------------------------
Static Function ImpOP()

	Local _nPos  	:= 0
	Local _aArea	:= GetArea()
	Local _aAreaZM0 := GetArea("ZM0")	

	_nNumReg := Len(_aDados)

	ProcRegua(_nNumReg)

	_nNumLendo := 0

	For _nPos := 1 To Len(_aDados)
		_nNumLendo++

		IncProc("Incluindo registro " + cValToChar(_nNumLendo) + " de " + cValToChar(_nNumReg) + " na tabela ZM0...")

        DbSelectArea("ZM0")
        RecLock("ZM0", .T.)
        ZM0->ZM0_FILIAL := FWxFilial("ZM0")
        ZM0->ZM0_DTEMIS := Stod(_aDados[_nPos,01]) 
        ZM0->ZM0_CODPRD := PADR(_aDados[_nPos,03] , 15, "")
        ZM0->ZM0_DESPRD := GetAdvFVal("SB1", "B1_DESC",  FWxFilial("SB1") + PADR(_aDados[_nPos,03] , 15, ""), 1, Space(TamSx3("B1_DESC")[1]),  .T.)
        ZM0->ZM0_LOCAL  := _aDados[_nPos,04]
        ZM0->ZM0_QUANT  := Val( StrTran( AllTrim(_aDados[_nPos,02]), ",", "." ) )
        ZM0->ZM0_UM     := _aDados[_nPos,05]
        ZM0->ZM0_CCUSTO := _aDados[_nPos,11]
        ZM0->ZM0_DATPRI := Stod(_aDados[_nPos,06])
        ZM0->ZM0_DATPRF := Stod(_aDados[_nPos,07])
        ZM0->ZM0_PRIOR  := _aDados[_nPos,08]
        ZM0->ZM0_TPPR   := _aDados[_nPos,09]
        ZM0->ZM0_NUMAM  := _aDados[_nPos,10]
        MsUnlock()
	Next _nPos

	RestArea(_aArea)
	RestArea(_aAreaZM0)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _TelaOP
Função que monta tela para processamento das ordens de produção
@author     Evandro Mugnol
@since      Jul/2024
/*/
//-----------------------------------------------------------------------
Static Function _TelaOP()

	Local aCpos1   := {}
	Local nX	   := 0
	Local aArea	   := FWGetArea()
	Local aAreaSX3 := SX3->(FWGetArea())
	Local aSize    := {}
	Local aInfo    := {}

	Private aHead1   := {}
	Private aCols1   := {}
	Private aPosObj1 := {}
	Private aObject1 := {}
	Private lChkSel1 := .F.
	Private oDlgOPs
	Private oGetDad1

	Static oChk1

	aSize := MsAdvSize(.T.)		 // Se a janela de diálogo possuirá enchoicebar (.T.), senão (.F.)
	AAdd( aObject1, { 100, 015, .T., .T. } )
	AAdd( aObject1, { 100, 065, .T., .T. } )
	AAdd( aObject1, { 100, 020, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj1 := MsObjSize( aInfo, aObject1,.T.)

	// Array de cabeçalho do oGetDad1
	// Neste caso serão 13 colunas incluindo o campo que possui caixa de seleção ou checkBox
	aAdd(aCpos1,"ZM0_DTEMIS")
	aAdd(aCpos1,"ZM0_CODPRD")
	aAdd(aCpos1,"ZM0_DESPRD")
	aAdd(aCpos1,"ZM0_LOCAL")
	aAdd(aCpos1,"ZM0_QUANT")
	aAdd(aCpos1,"ZM0_UM")
	aAdd(aCpos1,"ZM0_CCUSTO")
	aAdd(aCpos1,"ZM0_DATPRI")
	aAdd(aCpos1,"ZM0_DATPRF")
	aAdd(aCpos1,"ZM0_PRIOR")
	aAdd(aCpos1,"ZM0_TPPR")
	aAdd(aCpos1,"ZM0_NUMAM")

	aAdd(aHead1, { ''	 	 , 'CHECKBOL', '@BMP', 2, 0,     ,, 'C',, 'V',,,'', 'V' } )

	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aCpos1)
		If SX3->( MsSeek(aCpos1[nX]) )
			aAdd( aHead1, { AlLTrim( X3Titulo() )	,; 	// 01 - Titulo
							SX3->X3_CAMPO			,;	// 02 - Campo
							SX3->X3_PICTURE			,;	// 03 - Picture
							SX3->X3_TAMANHO			,;	// 04 - Tamanho
							SX3->X3_DECIMAL			,;	// 05 - Decimal
							SX3->X3_VALID  			,;	// 06 - Valid
							SX3->X3_USADO  			,;	// 07 - Usado
							SX3->X3_TIPO   			,;	// 08 - Tipo
							SX3->X3_F3				,;	// 09 - F3
							SX3->X3_CONTEXT 		,;  // 10 - Contexto
							SX3->X3_CBOX			,;	// 11 - ComboBox
							SX3->X3_RELACAO    		})  // 12 - Relacao
		EndIf
	Next nX

	FWRestArea( aAreaSX3 )
	FWRestArea( aArea )

	DEFINE MSDIALOG oDlgOPs TITLE "Dados Importados do CSV para Gerar Ordens de Produção" From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
	_oPanel1 := TPanel():New(aPosObj1[1,1], aPosObj1[1,2], , oDlgOPs ,, .F., ,, , aPosObj1[1,4], aPosObj1[1,3], .T., .F.)

	// Objeto oChk1 de checkbox e variável lChkSel1. Quando clicado, executa o método "Selec1" e possibilita
	// que o usuário selecione todas as linhas ao mesmo tempo.
	@ aPosObj1[2,2] * 2, 003 CHECKBOX oChk1 VAR lChkSel1 PROMPT "Marca/Desmarca Todos" SIZE 070, 007 on CLICK Selec1(lChkSel1) OF _oPanel1 PIXEL

	oGetDad1:= MsNewGetDados():New((aPosObj1[2,1])-20,(aPosObj1[2,2])+3, aPosObj1[3,3], aPosObj1[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgOPs,aHead1,aCols1)

	// Antes de ativar a tela (oDlgOPs) busca todas informações para carregar o oGetDad1
	_BuscaZM0()

	// Botões da Tela
	@ aPosObj1[2,2] * 2, aPosObj1[2,4] - 140 BUTTON "Pesquisar"  SIZE 060, 015 ACTION {|| GdSeek(oGetDad1,"Busca Itens",oGetDad1:aHeader,oGetDad1:aCols,If(Type("oGetDad1:aIniCpos")=="A",.T.,)) } OF _oPanel1 PIXEL
	@ aPosObj1[2,2] * 2, aPosObj1[2,4] - 070 BUTTON "Gerar OPs"  SIZE 060, 015 ACTION FWMsgRun(, {|oSay| _GerOPs(oSay) }, "Aguarde", "Processando Geração das Ordens de Produção ...") OF _oPanel1 PIXEL

	oDlgOPs:lEscClose := .F.
  	ACTIVATE MSDIALOG oDlgOPs CENTERED ON INIT EnchoiceBar(oDlgOPs, {||oDlgOPs:End()}, { ||oDlgOPs:End()},,,,,.T.,.T., .T., .F.,.T.,)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} Selec1
Função que faz a marcação dos registros na tela
@author     Evandro Mugnol
@since      Jul/2024
/*/
//-----------------------------------------------------------------------
Static Function Selec1(lChkSel1)

	Local i
	
	For i := 1 To Len(oGetDad1:aCols)
		// Verifica o valor da variável lChkSel1
		// Se verdadeiro, define a primeira coluna do aCols como LBOK ou marcado (checked)
		If lChkSel1
			oGetDad1:aCOLS[i,1] := "LBOK"
		Else	//se falso, marca como LBNO ou desmarcado (unchecked)
			oGetDad1:aCOLS[i,1] := "LBNO"
		Endif
	Next i

	// Executa refresh no getdados e na tela
	// esses métodos Refresh() são próprio da classe MsNewGetDados e do dialog
	oGetDad1:oBrowse:Refresh()
	oDlgOPs:Refresh()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _BuscaZM0
Função que carrega todos registros da tabela intermediária ZM0 para tela
@author     Evandro Mugnol
@since      Jul/2024
/*/
//-----------------------------------------------------------------------
Static Function _BuscaZM0()

	Private aCols1 := {}

	// Atualiza/Recarrega o oGetDad1 e o oDlgOPs antes de receber novos dados          
	_Refresh1(aCols1)

	DbSelectArea("ZM0")
	DbSetOrder(1)
	DbGoTop()
	DbSeek(FWxFilial("ZM0"))
	While !Eof() .And. ZM0->ZM0_FILIAL == FWxFilial("ZM0")
		aAdd(aCols1, {'LBNO'			,;
					   ZM0->ZM0_DTEMIS	,;
					   ZM0->ZM0_CODPRD	,;
					   ZM0->ZM0_DESPRD	,;
					   ZM0->ZM0_LOCAL	,;
					   ZM0->ZM0_QUANT	,;
					   ZM0->ZM0_UM		,;
					   ZM0->ZM0_CCUSTO	,;
					   ZM0->ZM0_DATPRI	,;
					   ZM0->ZM0_DATPRF	,;
					   ZM0->ZM0_PRIOR	,;
					   ZM0->ZM0_TPPR	,;
					   ZM0->ZM0_NUMAM	,;
					   ZM0->(RECNO())	,;
					   .F.				})

		DbSelectArea("ZM0")
		DbSkip()
	EndDo

	// Atualiza o oGetDad1 com o novo array
	_Refresh1(aCols1)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _Refresh1
Função que refersh do oGetDad1
@author     Evandro Mugnol
@since      Jul/2024
/*/
//-----------------------------------------------------------------------
Static Function _Refresh1(aDados)

	oGetDad1:oBrowse:Refresh()
	oDlgOPs:Refresh()

	oGetDad1:= MsNewGetDados():New((aPosObj1[2,1])-20,(aPosObj1[2,2])+3, aPosObj1[3,3], aPosObj1[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgOPs,aHead1,aCols1)
	oGetDad1:oBrowse:bLDblClick := {|| oGetDad1:EditCell(), oGetDad1:aCols[oGetDad1:nAt,1] := iif(oGetDad1:aCols[oGetDad1:nAt,1] == 'LBOK','LBNO','LBOK')}

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _GerOPs
Função que efetua do processamento dos registros marcados na tela
@author     Evandro Mugnol
@since      Jul/2024
/*/
//-----------------------------------------------------------------------
Static Function _GerOPs(oSay)

	Local nAtual := 0
	Local nTotal := 0
	Local nY
	Local nZ

	oSay:SetText("Iniciando processamento...")

	// Gera Contador de Total de Linhas Marcadas
	For nZ := 1 To Len(oGetDad1:aCols)
		If oGetDad1:aCols[nZ,1] == 'LBOK'
			nTotal++
		EndIf
	Next nZ

	// Laço para Gerar OP Referente as Linhas Marcadas
	For nY := 1 To Len(oGetDad1:aCols)
		If oGetDad1:aCols[nY,1] == 'LBOK'
			_nRecnoZM0 := oGetDad1:aCols[nY,14]
			nAtual++
			oSay:SetText("Processando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " marcados ...")


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Salvo o valor real da database por segurança		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dDataBkp  := dDataBase

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizado a database com data de entrega do arquivo³
			//³ CSV para gerar OP sem dar erro de ExecAuto			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dDataBase := oGetDad1:aCols[nY,10]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ 3 - Inclusao     ³
			//³ 4 - Alteracao    ³
			//³ 5 - Exclusao     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nOpc := 3
			lMsErroAuto := .F.
			_cNumOp := GetNumSc2()
			_cIteOp := "01"
			_cSeqOp := "001"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava SC2 (ordens de produção)                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_aAutoSC2 := {}
			AADD(_aAutoSC2, {"C2_FILIAL" , FWxFilial("SC2")       	, NIL})
			AADD(_aAutoSC2, {"C2_NUM"    , _cNumOp                	, NIL})
			AADD(_aAutoSC2, {"C2_ITEM"   , _cIteOp                 	, NIL})
			AADD(_aAutoSC2, {"C2_EMISSAO", oGetDad1:aCols[nY,2]		, NIL})
			AADD(_aAutoSC2, {"C2_NUMAM"  , oGetDad1:aCols[nY,13]	, NIL})
			AADD(_aAutoSC2, {"C2_QUANT"  , oGetDad1:aCols[nY,6]		, NIL})
			AADD(_aAutoSC2, {"C2_PRODUTO", oGetDad1:aCols[nY,3]    	, NIL})
			AADD(_aAutoSC2, {"C2_LOCAL"  , oGetDad1:aCols[nY,5]    	, NIL})
			AADD(_aAutoSC2, {"C2_CC"     , oGetDad1:aCols[nY,8]		, NIL})
			AADD(_aAutoSC2, {"C2_UM"     , oGetDad1:aCols[nY,7]     , NIL})
			AADD(_aAutoSC2, {"C2_SEQUEN" , _cSeqOp            		, NIL})
			AADD(_aAutoSC2, {"C2_DATPRI" , oGetDad1:aCols[nY,9]		, NIL})
			AADD(_aAutoSC2, {"C2_DATPRF" , oGetDad1:aCols[nY,10]	, NIL})
			AADD(_aAutoSC2, {"C2_PRIOR"  , oGetDad1:aCols[nY,11]	, NIL})
			AADD(_aAutoSC2, {"C2_TPPR"   , oGetDad1:aCols[nY,12]	, NIL})
			AADD(_aAutoSC2, {"AUTEXPLODE", "S" 					   	, NIL})

			// Executa geração de OP via rotina automatica
			MSExecAuto({|x,y| mata650(x,y)}, _aAutoSC2, nOpc)

			If !lMSErroAuto
				ConfirmSX8()

				// Grava Número da OP que foi Gerada no registro de origem da ZM0 para poder visualizar no log que é temporário
				_cQuery1 := "UPDATE " + RetSqlName('ZM0')
				_cQuery1 += "   SET ZM0_NUM = '" + _cNumOp + "',"
				_cQuery1 += "       ZM0_ITEM = '" + _cIteOp + "',"
				_cQuery1 += "       ZM0_SEQUEN = '" + _cSeqOp + "'"
				_cQuery1 += " WHERE R_E_C_N_O_ = '" + AllTrim(Str(_nRecnoZM0)) + "'"

				TCSqlExec(_cQuery1)
			Else
				RollBackSX8()
				MostraErro()
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recupera o valor real da database por segurança		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dDataBase := dDataBkp

		EndIf
	Next nY

	oDlgOPs:End()

Return


//----------------------------------------------------------------------
/*/{Protheus.doc} ImpEMPM
Função que importa os dados do arquivo CSV para a tabela intermediária
de empenhos múltiplos
@author     Evandro Mugnol
@since      Ago/2024
/*/
//----------------------------------------------------------------------
Static Function ImpEMPM()

	Local _nPos  	:= 0
	Local _aArea	:= GetArea()
	Local _aAreaZM1 := GetArea("ZM1")	

	_nNumReg := Len(_aDados)

	ProcRegua(_nNumReg)

	_nNumLendo := 0

	For _nPos := 1 To Len(_aDados)
		_nNumLendo++

		IncProc("Incluindo registro " + cValToChar(_nNumLendo) + " de " + cValToChar(_nNumReg) + " na tabela ZM1...")

        DbSelectArea("ZM1")
        RecLock("ZM1", .T.)
        ZM1->ZM1_FILIAL := FWxFilial("ZM1")
        ZM1->ZM1_PROD   := PADR(_aDados[_nPos,02] , 15, "")
        ZM1->ZM1_DESC   := GetAdvFVal("SB1", "B1_DESC",  FWxFilial("SB1") + PADR(_aDados[_nPos,02] , 15, ""), 1, Space(TamSx3("B1_DESC")[1]),  .T.)
        ZM1->ZM1_OP     := PADR(_aDados[_nPos,01] , 14, "")
        ZM1->ZM1_LOCAL  := _aDados[_nPos,04]
        ZM1->ZM1_DATA   := Stod(_aDados[_nPos,03])
        ZM1->ZM1_QTDORI := Val( StrTran( AllTrim(_aDados[_nPos,05]), ",", "." ) )
        ZM1->ZM1_QUANT  := Val( StrTran( AllTrim(_aDados[_nPos,06]), ",", "." ) )
        MsUnlock()
	Next _nPos

	RestArea(_aArea)
	RestArea(_aAreaZM1)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _TelaEMPM
Função que monta tela para processamento dos empenhos múltiplos
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function _TelaEMPM()

	Local aCpos2   := {}
	Local nX	   := 0
	Local aArea	   := FWGetArea()
	Local aAreaSX3 := SX3->(FWGetArea())
	Local aSize    := {}
	Local aInfo    := {}

	Private aHead2   := {}
	Private aCols2   := {}
	Private aPosObj2 := {}
	Private aObject2 := {}
	Private lChkSel2 := .F.
	Private oDlgEmp
	Private oGetDad2

	Static oChk2

	aSize := MsAdvSize(.T.)		 // Se a janela de diálogo possuirá enchoicebar (.T.), senão (.F.)
	AAdd( aObject2, { 100, 015, .T., .T. } )
	AAdd( aObject2, { 100, 065, .T., .T. } )
	AAdd( aObject2, { 100, 020, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj2 := MsObjSize( aInfo, aObject2,.T.)

	// Array de cabeçalho do oGetDad2
	// Neste caso serão 8 colunas incluindo o campo que possui caixa de seleção ou checkBox
	aAdd(aCpos2,"ZM1_OP")
	aAdd(aCpos2,"ZM1_PROD")
	aAdd(aCpos2,"ZM1_DESC")
	aAdd(aCpos2,"ZM1_DATA")
	aAdd(aCpos2,"ZM1_LOCAL")
	aAdd(aCpos2,"ZM1_QTDORI")
	aAdd(aCpos2,"ZM1_QUANT")

	aAdd(aHead2, { ''	 	 , 'CHECKBOL', '@BMP', 2, 0,     ,, 'C',, 'V',,,'', 'V' } )

	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aCpos2)
		If SX3->( MsSeek(aCpos2[nX]) )
			aAdd( aHead2, { AlLTrim( X3Titulo() )	,; 	// 01 - Titulo
							SX3->X3_CAMPO			,;	// 02 - Campo
							SX3->X3_PICTURE			,;	// 03 - Picture
							SX3->X3_TAMANHO			,;	// 04 - Tamanho
							SX3->X3_DECIMAL			,;	// 05 - Decimal
							SX3->X3_VALID  			,;	// 06 - Valid
							SX3->X3_USADO  			,;	// 07 - Usado
							SX3->X3_TIPO   			,;	// 08 - Tipo
							SX3->X3_F3				,;	// 09 - F3
							SX3->X3_CONTEXT 		,;  // 10 - Contexto
							SX3->X3_CBOX			,;	// 11 - ComboBox
							SX3->X3_RELACAO    		})  // 12 - Relacao
		EndIf
	Next nX

	FWRestArea( aAreaSX3 )
	FWRestArea( aArea )

	DEFINE MSDIALOG oDlgEmp TITLE "Dados Importados do CSV para Gerar Empenhos Múltiplos" From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
	_oPanel2 := TPanel():New(aPosObj2[1,1], aPosObj2[1,2], , oDlgEmp ,, .F., ,, , aPosObj2[1,4], aPosObj2[1,3], .T., .F.)

	// Objeto oChk2 de checkbox e variável lChkSel2. Quando clicado, executa o método "Selec2" e possibilita
	// que o usuário selecione todas as linhas ao mesmo tempo.
	@ aPosObj2[2,2] * 2, 003 CHECKBOX oChk2 VAR lChkSel2 PROMPT "Marca/Desmarca Todos" SIZE 070, 007 on CLICK Selec2(lChkSel2) OF _oPanel2 PIXEL

	oGetDad2:= MsNewGetDados():New((aPosObj2[2,1])-20,(aPosObj2[2,2])+3, aPosObj2[3,3], aPosObj2[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgEmp,aHead2,aCols2)

	// Antes de ativar a tela (oDlgEmp) busca todas informações para carregar o oGetDad2
	_BuscaZM1()

	// Botões da Tela
	@ aPosObj2[2,2] * 2, aPosObj2[2,4] - 160 BUTTON "Pesquisar"  			SIZE 070, 015 ACTION {|| GdSeek(oGetDad2,"Busca Itens",oGetDad2:aHeader,oGetDad2:aCols,If(Type("oGetDad2:aIniCpos")=="A",.T.,)) } OF _oPanel2 PIXEL
	@ aPosObj2[2,2] * 2, aPosObj2[2,4] - 080 BUTTON "Gerar Emp. Múltiplos"  SIZE 070, 015 ACTION FWMsgRun(, {|oSay| _GerEMP(oSay) }, "Aguarde", "Processando Geração dos Empenhos Múltiplos ...") OF _oPanel2 PIXEL

	oDlgEmp:lEscClose := .F.
  	ACTIVATE MSDIALOG oDlgEmp CENTERED ON INIT EnchoiceBar(oDlgEmp, {||oDlgEmp:End()}, { ||oDlgEmp:End()},,,,,.T.,.T., .T., .F.,.T.,)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} Selec2
Função que faz a marcação dos registros na tela
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function Selec2(lChkSel2)

	Local i
	
	For i := 1 To Len(oGetDad2:aCols)
		// Verifica o valor da variável lChkSel2
		// Se verdadeiro, define a primeira coluna do aCols como LBOK ou marcado (checked)
		If lChkSel2
			oGetDad2:aCOLS[i,1] := "LBOK"
		Else	//se falso, marca como LBNO ou desmarcado (unchecked)
			oGetDad2:aCOLS[i,1] := "LBNO"
		Endif
	Next i

	// Executa refresh no getdados e na tela
	// esses métodos Refresh() são próprio da classe MsNewGetDados e do dialog
	oGetDad2:oBrowse:Refresh()
	oDlgEmp:Refresh()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _BuscaZM1
Função que carrega todos registros da tabela intermediária ZM1 para tela
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function _BuscaZM1()

	Private aCols2 := {}

	// Atualiza/Recarrega o oGetDad2 e o oDlgEmp antes de receber novos dados          
	_Refresh2(aCols2)

	DbSelectArea("ZM1")
	DbSetOrder(2)
	DbGoTop()
	DbSeek(FWxFilial("ZM1"))
	While !Eof() .And. ZM1->ZM1_FILIAL == FWxFilial("ZM1")
		aAdd(aCols2, {'LBNO'			,;
					  ZM1->ZM1_OP		,;
					  ZM1->ZM1_PROD		,;
					  ZM1->ZM1_DESC		,;
					  ZM1->ZM1_DATA		,;
					  ZM1->ZM1_LOCAL	,;
					  ZM1->ZM1_QTDORI	,;
					  ZM1->ZM1_QUANT	,;
					  ZM1->(RECNO())	,;
					  .F.				})

		DbSelectArea("ZM1")
		DbSkip()
	EndDo

	// Atualiza o oGetDad2 com o novo array
	_Refresh2(aCols2)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _Refresh2
Função que refresh do oGetDad2
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function _Refresh2(aDados)

	oGetDad2:oBrowse:Refresh()
	oDlgEmp:Refresh()

	oGetDad2:= MsNewGetDados():New((aPosObj2[2,1])-20,(aPosObj2[2,2])+3, aPosObj2[3,3], aPosObj2[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgEmp,aHead2,aCols2)
	oGetDad2:oBrowse:bLDblClick := {|| oGetDad2:EditCell(), oGetDad2:aCols[oGetDad2:nAt,1] := iif(oGetDad2:aCols[oGetDad2:nAt,1] == 'LBOK','LBNO','LBOK')}

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _GerEMP
Função que efetua do processamento dos registros marcados na tela
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function _GerEMP(oSay)

	Local aAreaSD4  := SD4->(FWGetArea())
	Local nAtual    := 0
	Local nTotal    := 0
	Local aCabecSD4 := {}
    Local aLine     := {}
	Local aLinesSD4 := {}
    Local aItensLog := {}
	Local nInd1     := 0
	Local nInd2     := 0
	Local nX		:= 0
	Local nZ		:= 0

	Private lMsErroAuto := .F.

	oSay:SetText("Iniciando processamento...")

	// Gera Contador de Total de Linhas Marcadas
	For nZ := 1 To Len(oGetDad2:aCols)
		If oGetDad2:aCols[nZ,1] == 'LBOK'
			nTotal++
		EndIf
	Next nZ

	_zNumOP := "##############"
	_Vez    := 1
	// Laço para Alterar Empenhos Múltiplos Referente as Linhas Marcadas
	For nInd1 := 1 To Len(oGetDad2:aCols)

		If oGetDad2:aCols[nInd1,1] == 'LBOK'

			nAtual++
			oSay:SetText("Processando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " marcados ...")
			_cNumOP := oGetDad2:aCols[nInd1,2]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o cabeçalho com o número da OP que será utilizada para alteração dos empenhos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If _zNumOP <> _cNumOP
				If _Vez <> 1
					// Executa o MATA381, com a operação de Inclusão.
					MSExecAuto( { |x,y,z| MATA381( x, y, z ) }, aCabecSD4, aLinesSD4, 4 )

					If !lMSErroAuto
						For nX := 1 To Len(aItensLog)
							_nRecnoZM1 := aItensLog[nX]

							// Grava 'Alteração Empenho' que foi Gerada no registro de origem da ZM1 para poder visualizar no log que é temporário
							_cQuery2 := "UPDATE " + RetSqlName('ZM1')
							_cQuery2 += "   SET ZM1_INCEMP = 'S'"
							_cQuery2 += " WHERE R_E_C_N_O_ = '" + AllTrim(Str(_nRecnoZM1)) + "'"

							TCSqlExec(_cQuery2)
						Next nX
					Else
						MostraErro()
					Endif
					aLine     := {}
					aLinesSD4 := {}
					aItensLog := {}
				EndIf

				// Cabeçalho do empenho, identificando a OP que será vinculada
				aCabecSD4 := {}
				aAdd(aCabecSD4, {"D4_OP", _cNumOP	, Nil})

				// Utilizar o índice 2 para efetuar a alteração
				aAdd(aCabecSD4, {"INDEX", 2			, Nil})
     			
				_zNumOP := _cNumOP
				_Vez := 2
			EndIf

			aLine := {}
			DbSelectArea("SD4")
			DbSetOrder(2) 		// D4_FILIAL + D4_OP + D4_COD + D4_LOCAL
			If MsSeek(FWxFilial("SD4") + _cNumOP + oGetDad2:aCols[nInd1,3] + oGetDad2:aCols[nInd1,6])
				// Carrega as informações do empenho conforme a SD4
				For nInd2 := 1 To SD4->(FCount())
					If SD4->(Field(nInd2)) == "D4_QUANT" .Or. SD4->(Field(nInd2)) == "D4_QTDEORI"
						Loop
					EndIf
					aAdd(aLine, {SD4->(Field(nInd2)), SD4->(FieldGet(nInd2))	, Nil})
				Next nInd2

				// Preenche array com as informações alteradas
				aAdd(aLine, {"D4_QTDEORI", oGetDad2:aCols[nInd1,7]		, Nil})
				aAdd(aLine, {"D4_QUANT"  , oGetDad2:aCols[nInd1,8]		, Nil})

				// Adiciona o identificador LINPOS para posicionar registro correto na SD4
				aAdd(aLine, {"LINPOS"		,;
							"D4_COD+D4_TRT+D4_LOTECTL+D4_NUMLOTE+D4_LOCAL+D4_OPORIG+D4_SEQ",;
							SD4->D4_COD    ,;
							SD4->D4_TRT    ,;
							SD4->D4_LOTECTL,;
							SD4->D4_NUMLOTE,;
							SD4->D4_LOCAL  ,;
							SD4->D4_OPORIG ,;
							SD4->D4_SEQ 	})
			Else
				aAdd(aLine, {"D4_OP"     , _cNumOP              		, Nil})
				aAdd(aLine, {"D4_COD"    , oGetDad2:aCols[nInd1,3]		, Nil})
				aAdd(aLine, {"D4_LOCAL"  , oGetDad2:aCols[nInd1,6]		, Nil})
				aAdd(aLine, {"D4_DATA"   , oGetDad2:aCols[nInd1,5]		, Nil})
				aAdd(aLine, {"D4_QTDEORI", oGetDad2:aCols[nInd1,7]		, Nil})
				aAdd(aLine, {"D4_QUANT"  , oGetDad2:aCols[nInd1,8]		, Nil})
				aAdd(aLine, {"D4_TRT"    , "001"						, Nil})
			EndIf

			// Incluir as informações do empenho no listagem de empenhos
			aAdd(aLinesSD4, aLine )
			aAdd(aItensLog, oGetDad2:aCols[nInd1,9])

		EndIf

	Next nInd1

	MSExecAuto( { |x,y,z| MATA381( x, y, z ) }, aCabecSD4, aLinesSD4, 4 )

	If !lMsErroAuto
		For nX := 1 To Len(aItensLog)
			_nRecnoZM1 := aItensLog[nX]

			// Grava 'Alteração Empenho' que foi Gerada no registro de origem da ZM1 para poder visualizar no log que é temporário
			_cQuery2 := "UPDATE " + RetSqlName('ZM1')
			_cQuery2 += "   SET ZM1_INCEMP = 'S'"
			_cQuery2 += " WHERE R_E_C_N_O_ = '" + AllTrim(Str(_nRecnoZM1)) + "'"

			TCSqlExec(_cQuery2)
		Next nX
	Else
		MostraErro()
	EndIf

	oDlgEmp:End()

	FWRestArea(aAreaSD4)

Return


//----------------------------------------------------------------------
/*/{Protheus.doc} FiltOPs
Função que filtra as ordens de produção cfe parâmetros para a tabela
intermediária de apontamentos de ordens de produção
@author     Evandro Mugnol
@since      Ago/2024
/*/
//----------------------------------------------------------------------
Static Function FiltOPs(_cOPIni, _cOPFim)

	Local _aArea	 := GetArea()
	Local _aAreaZM2  := GetArea("ZM2")
	Local _nNumReg   := 0
	Local _nNumLendo := 0
	Local cQueryC2	 := ''
	Local aTam		 := {}
	Local _nSaldoOP  := 0

	DbSelectArea("SC2")
	DbSetOrder(1)

	cQueryC2 := "SELECT C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_EMISSAO, C2_PRODUTO, C2_LOCAL, C2_UM, C2_CC, C2_DATPRI, C2_DATPRF, C2_DATRF, C2_STATUS, C2_QUANT, C2_QUJE, C2_PERDA"
	cQueryC2 += "  FROM " +	RetSQLTab("SC2")
	cQueryC2 += " WHERE " + RetSQLFil("SC2")
	cQueryC2 += "   AND C2_NUM >= '" + Substr(_cOPIni,1,6) + "'"
	cQueryC2 += "   AND C2_ITEM >= '" + Substr(_cOPIni,7,2) + "'"
	cQueryC2 += "   AND C2_SEQUEN >= '"	+ Substr(_cOPIni,9,3) + "'"
	cQueryC2 += "   AND C2_NUM <= '" + Substr(_cOPFim,1,6) + "'"
	cQueryC2 += "   AND C2_ITEM <= '" + Substr(_cOPFim,7,2) + "'"
	cQueryC2 += "   AND C2_SEQUEN <= '"	+ Substr(_cOPFim,9,3) + "'"
	cQueryC2 += "   AND " + RetSQLDel("SC2")
	cQueryC2 += " ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN"

	cQueryC2 := ChangeQuery(cQueryC2)

	If Select("SC2") != 0
		SC2->(dbCloseArea())
	Endif

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryC2),"SC2", .F., .T.)

	aTam := TamSx3("C2_QUANT")
	TcSetField("SC2", "C2_QUANT"  , "N",aTam[1],aTam[2])
	TcSetField("SC2", "C2_EMISSAO", "D")
	TcSetField("SC2", "C2_DATPRI" , "D")
	TcSetField("SC2", "C2_DATPRF" , "D")
	TcSetField("SC2", "C2_DATRF"  , "D")

	COUNT TO _nNumReg

	SC2->(dbGoTop())
	Procregua(_nNumReg)
	While SC2->(!Eof())
		_nNumLendo++

		IncProc("Incluindo registro " + cValToChar(_nNumLendo) + " de " + cValToChar(_nNumReg) + " na tabela ZM2...")

		_nSaldoOP := aSC2Sld()

		If _nSaldoOP <= 0 .And. !Empty(SC2->C2_DATRF)
			SC2->(DbSkip())
			Loop
		Endif	
				
		If SC2->C2_STATUS == "U"
			SC2->(DbSkip())
			Loop
		Endif

		If !Empty(SC2->C2_DATRF)
			SC2->(DbSkip())
			Loop
		EndIf	
			
        DbSelectArea("ZM2")
        RecLock("ZM2", .T.)
        ZM2->ZM2_FILIAL := FWxFilial("ZM2")
        ZM2->ZM2_NUM    := SC2->C2_NUM
        ZM2->ZM2_ITEM   := SC2->C2_ITEM
        ZM2->ZM2_SEQUEN := SC2->C2_SEQUEN
        ZM2->ZM2_DTEMIS := SC2->C2_EMISSAO
        ZM2->ZM2_CODPRD := SC2->C2_PRODUTO
        ZM2->ZM2_DESPRD := GetAdvFVal("SB1", "B1_DESC",  FWxFilial("SB1") + SC2->C2_PRODUTO, 1, Space(TamSx3("B1_DESC")[1]),  .T.)
        ZM2->ZM2_LOCAL  := SC2->C2_LOCAL
        ZM2->ZM2_SALDO  := _nSaldoOP
        ZM2->ZM2_UM     := SC2->C2_UM
        ZM2->ZM2_CCUSTO := SC2->C2_CC
        ZM2->ZM2_DATPRI := SC2->C2_DATPRI
        ZM2->ZM2_DATPRF := SC2->C2_DATPRF
        ZM2->ZM2_DATRF  := SC2->C2_DATRF
        MsUnlock()

		SC2->(DbSkip())
	Enddo

	SC2->(DbCloseArea())

	RestArea(_aArea)
	RestArea(_aAreaZM2)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _TelaENC
Função que monta tela para processamento dos apontamentos de produção
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function _TelaENC(_cTPMov, _dDTApo)

	Local aCpos3   := {}
	Local nX	   := 0
	Local aArea	   := FWGetArea()
	Local aAreaSX3 := SX3->(FWGetArea())
	Local aSize    := {}
	Local aInfo    := {}

	Private aHead3   := {}
	Private aCols3   := {}
	Private aPosObj3 := {}
	Private aObject3 := {}
	Private lChkSel3 := .F.
	Private oDlgEnc
	Private oGetDad3

	Static oChk3

	aSize := MsAdvSize(.T.)		 // Se a janela de diálogo possuirá enchoicebar (.T.), senão (.F.)
	AAdd( aObject3, { 100, 015, .T., .T. } )
	AAdd( aObject3, { 100, 065, .T., .T. } )
	AAdd( aObject3, { 100, 020, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj3 := MsObjSize( aInfo, aObject3,.T.)

	// Array de cabeçalho do oGetDad3
	// Neste caso serão 14 colunas incluindo o campo que possui caixa de seleção ou checkBox
	aAdd(aCpos3,"ZM2_NUM")
	aAdd(aCpos3,"ZM2_ITEM")
	aAdd(aCpos3,"ZM2_SEQUEN")
	aAdd(aCpos3,"ZM2_DTEMIS")
	aAdd(aCpos3,"ZM2_CODPRD")
	aAdd(aCpos3,"ZM2_DESPRD")
	aAdd(aCpos3,"ZM2_LOCAL")
	aAdd(aCpos3,"ZM2_SALDO")
	aAdd(aCpos3,"ZM2_UM")
	aAdd(aCpos3,"ZM2_CCUSTO")
	aAdd(aCpos3,"ZM2_DATPRI")
	aAdd(aCpos3,"ZM2_DATPRF")
	aAdd(aCpos3,"ZM2_DATRF")

	aAdd(aHead3, { ''	 	 , 'CHECKBOL', '@BMP', 2, 0,     ,, 'C',, 'V',,,'', 'V' } )

	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aCpos3)
		If SX3->( MsSeek(aCpos3[nX]) )
			aAdd( aHead3, { AlLTrim( X3Titulo() )	,; 	// 01 - Titulo
							SX3->X3_CAMPO			,;	// 02 - Campo
							SX3->X3_PICTURE			,;	// 03 - Picture
							SX3->X3_TAMANHO			,;	// 04 - Tamanho
							SX3->X3_DECIMAL			,;	// 05 - Decimal
							SX3->X3_VALID  			,;	// 06 - Valid
							SX3->X3_USADO  			,;	// 07 - Usado
							SX3->X3_TIPO   			,;	// 08 - Tipo
							SX3->X3_F3				,;	// 09 - F3
							SX3->X3_CONTEXT 		,;  // 10 - Contexto
							SX3->X3_CBOX			,;	// 11 - ComboBox
							SX3->X3_RELACAO    		})  // 12 - Relacao
		EndIf
	Next nX

	FWRestArea( aAreaSX3 )
	FWRestArea( aArea )

	DEFINE MSDIALOG oDlgEnc TITLE "OPs Filtradas para Gerar Apontamentos de Produção" From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
	_oPanel3 := TPanel():New(aPosObj3[1,1], aPosObj3[1,2], , oDlgEnc ,, .F., ,, , aPosObj3[1,4], aPosObj3[1,3], .T., .F.)

	// Objeto oChk3 de checkbox e variável lChkSel3. Quando clicado, executa o método "Selec3" e possibilita
	// que o usuário selecione todas as linhas ao mesmo tempo.
	@ aPosObj3[2,2] * 2, 003 CHECKBOX oChk3 VAR lChkSel3 PROMPT "Marca/Desmarca Todos" SIZE 070, 007 on CLICK Selec3(lChkSel3) OF _oPanel3 PIXEL

	oGetDad3:= MsNewGetDados():New((aPosObj3[2,1])-20,(aPosObj3[2,2])+3, aPosObj3[3,3], aPosObj3[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgEnc,aHead3,aCols3)

	// Antes de ativar a tela (oDlgEnc) busca todas informações para carregar o oGetDad3
	_BuscaZM2()

	// Botões da Tela
	@ aPosObj3[2,2] * 2, aPosObj3[2,4] - 160 BUTTON "Pesquisar"  			   SIZE 070, 015 ACTION {|| GdSeek(oGetDad3,"Busca Itens",oGetDad3:aHeader,oGetDad3:aCols,If(Type("oGetDad3:aIniCpos")=="A",.T.,)) } OF _oPanel3 PIXEL
	@ aPosObj3[2,2] * 2, aPosObj3[2,4] - 080 BUTTON "Apontar Ordens Produção"  SIZE 070, 015 ACTION FWMsgRun(, {|oSay| _GerENC(oSay, _cTPMov, _dDTApo) }, "Aguarde", "Processando Apontamento das Ordens de Produção ...") OF _oPanel3 PIXEL

	oDlgEnc:lEscClose := .F.
  	ACTIVATE MSDIALOG oDlgEnc CENTERED ON INIT EnchoiceBar(oDlgEnc, {||oDlgEnc:End()}, { ||oDlgEnc:End()},,,,,.T.,.T., .T., .F.,.T.,)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} Selec3
Função que faz a marcação dos registros na tela
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function Selec3(lChkSel3)

	Local i
	
	For i := 1 To Len(oGetDad3:aCols)
		// Verifica o valor da variável lChkSel3
		// Se verdadeiro, define a primeira coluna do aCols como LBOK ou marcado (checked)
		If lChkSel3
			oGetDad3:aCOLS[i,1] := "LBOK"
		Else	//se falso, marca como LBNO ou desmarcado (unchecked)
			oGetDad3:aCOLS[i,1] := "LBNO"
		Endif
	Next i

	// Executa refresh no getdados e na tela
	// esses métodos Refresh() são próprio da classe MsNewGetDados e do dialog
	oGetDad3:oBrowse:Refresh()
	oDlgEnc:Refresh()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _BuscaZM2
Função que carrega todos registros da tabela intermediária ZM2 para tela
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function _BuscaZM2()

	Private aCols3 := {}

	// Atualiza/Recarrega o oGetDad3 e o oDlgEnc antes de receber novos dados          
	_Refresh3(aCols3)

	DbSelectArea("ZM2")
	DbSetOrder(1)
	DbGoTop()
	DbSeek(FWxFilial("ZM2"))
	While !Eof() .And. ZM2->ZM2_FILIAL == FWxFilial("ZM2")
		aAdd(aCols3, {'LBNO'			,;
					  ZM2->ZM2_NUM		,;
					  ZM2->ZM2_ITEM		,;
					  ZM2->ZM2_SEQUEN	,;
					  ZM2->ZM2_DTEMIS	,;
					  ZM2->ZM2_CODPRD	,;
					  ZM2->ZM2_DESPRD	,;
					  ZM2->ZM2_LOCAL	,;
					  ZM2->ZM2_SALDO	,;
					  ZM2->ZM2_UM		,;
					  ZM2->ZM2_CCUSTO	,;
					  ZM2->ZM2_DATPRI	,;
					  ZM2->ZM2_DATPRF	,;
					  ZM2->ZM2_DATRF	,;
					  ZM2->(RECNO())	,;
					  .F.				})

		DbSelectArea("ZM2")
		DbSkip()
	EndDo

	// Atualiza o oGetDad3 com o novo array
	_Refresh3(aCols3)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _Refresh3
Função que refresh do oGetDad3
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function _Refresh3(aDados)

	oGetDad3:oBrowse:Refresh()
	oDlgEnc:Refresh()

	oGetDad3:= MsNewGetDados():New((aPosObj3[2,1])-20,(aPosObj3[2,2])+3, aPosObj3[3,3], aPosObj3[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgEnc,aHead3,aCols3)
	oGetDad3:oBrowse:bLDblClick := {|| oGetDad3:EditCell(), oGetDad3:aCols[oGetDad3:nAt,1] := iif(oGetDad3:aCols[oGetDad3:nAt,1] == 'LBOK','LBNO','LBOK')}

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _GerENC
Função que efetua do processamento dos registros marcados na tela
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function _GerENC(oSay, _cTPMov, _dDTApo)

	Local nAtual := 0
	Local nTotal := 0
	Local nY
	Local nZ

	oSay:SetText("Iniciando processamento...")

	// Gera Contador de Total de Linhas Marcadas
	For nZ := 1 To Len(oGetDad3:aCols)
		If oGetDad3:aCols[nZ,1] == 'LBOK'
			nTotal++
		EndIf
	Next nZ

	// Laço para Apontar OPs Referente as Linhas Marcadas
	For nY := 1 To Len(oGetDad3:aCols)
		If oGetDad3:aCols[nY,1] == 'LBOK'
			_nRecnoZM2 := oGetDad3:aCols[nY,15]

			nAtual++
			oSay:SetText("Processando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " marcados ...")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ 3 - Inclusao     ³
			//³ 5 - Estorno      ³
			//³ 7 - Encerramento ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nOpc := 3
			lMsErroAuto := .F.
			_cNumOP := oGetDad3:aCols[nY,2] + oGetDad3:aCols[nY,3] + oGetDad3:aCols[nY,4]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava SD3 (Encerramento ordens de produção)                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_aAutoSD3 := {}
			AADD(_aAutoSD3, {"D3_FILIAL" , FWxFilial("SD3")       				, NIL})
			AADD(_aAutoSD3, {"D3_TM"     , _cTPMov                				, NIL})
			AADD(_aAutoSD3, {"D3_OP"     , _cNumOp                 				, NIL})
			AADD(_aAutoSD3, {"D3_COD"    , oGetDad3:aCols[nY,6]    				, NIL})
			AADD(_aAutoSD3, {"D3_UM"     , oGetDad3:aCols[nY,10]   				, NIL})
			AADD(_aAutoSD3, {"D3_QUANT"  , oGetDad3:aCols[nY,9]    				, NIL})
			AADD(_aAutoSD3, {"D3_LOCAL"  , oGetDad3:aCols[nY,8]  			  	, NIL})
			AADD(_aAutoSD3, {"D3_EMISSAO", _dDTApo								, NIL})
			AADD(_aAutoSD3, {"D3_CC"     , oGetDad3:aCols[nY,11]   				, NIL})

			// Executa apontamento/encerramento da OP via rotina automatica
			MSExecAuto({|x,y| mata250(x,y)}, _aAutoSD3, nOpc)

			If !lMSErroAuto
				// Grava Data Real Fim da OP que foi Encerrada no registro de origem da ZM2 para poder visualizar no log que é temporário
				_cQuery3 := "UPDATE " + RetSqlName('ZM2')
				_cQuery3 += "   SET ZM2_DATRF = '" + Dtos(_dDTApo) + "'"
				_cQuery3 += " WHERE R_E_C_N_O_ = '" + AllTrim(Str(_nRecnoZM2)) + "'"

				TCSqlExec(_cQuery3)
			Else
				MostraErro()
			Endif

		EndIf
	Next nY

	oDlgEnc:End()

Return
