#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} CRI_DEV
@Type			: Função de Usuário
@Sample			: U_CRI_DEV()
@Description	: Cadastro de controle de recebimento e inspeção de devoluções
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function CRI_DEV(nOpc)

	Private cAlias    := "ZH5"
	Private aRotina   := MenuDef()
	Private cCadastro := "Controle de Receb. e Inspeção Devol."

	DbSelectArea("ZH1")
	DbSetOrder(1)
	If !DbSeek(xFilial("ZH1") + "3" + RetCodUsr())		// 2=Usuário Qualidade
		FWAlertWarning("Rotina será encerrada.", "Usuário sem permissão para efetuar Controle de Recebimento e Inspeção Devolução!!")
		Return
	EndIf

	// Endereca a funcao de BROWSE                                  ³
	mBrowse(6,1,22,75,cAlias,,,,,,,,,,,,,,)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao de chamada do menu
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {	{ OemToAnsi("Pesquisar") ,"AxPesqui"	, 0 , 1,,.F.} ,;
						{ OemToAnsi("Visualizar"),"U_CriDvInc" 	, 0 , 2		} ,;
						{ OemToAnsi("Incluir")	 ,"U_CriDvInc"	, 0 , 3		} ,;
						{ OemToAnsi("Alterar")	 ,"U_CriDvInc"	, 0 , 4		} ,;
						{ OemToAnsi("Excluir")	 ,"U_CriDvInc"	, 0 , 5		}  }

Return(aRotina)


//-----------------------------------------------------------------------
/*/{Protheus.doc} CriDvInc
Funcao que exibe na tela enchoice e a getdados
@Author     Evandro Mugnol
@Since      Nov/2024
@Param		ExpC1 = Alias do Arquivo
            ExpN1 = Numero do Registro
            ExpN2 = Numero da opcao selecionada
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
User Function CriDvInc(cAlias,nReg,nOpc)

	// Declaração das variaveis
	Private oEnch
	Private oDlg
	Private oGDItens
	Private aGets     := {}
	Private aTela     := {}
	Private aButtons  := {}
	Private nOpcao	  := 0
	Private bOk       := { || IIf(Obrigatorio(aGets,aTela) .And. oGDItens:TudoOk() , (nOpcao:=1,oDlg:End()) , nOpcao := 0) }
	Private bCancel   := { || nOpcao:=0 , oDlg:End() }
	Private nSuperior := 0
	Private nEsquerda := 0
	Private nInferior := 0
	Private nDireita  := 0
	Private aSizeAut  := {}
	Private aObjects  := {}
	Private aInfo     := {}
	Private aPosGet   := {}
	Private aPosObj   := {}
	
	// Cria Fonte para visualização
	Private oFont  := TFont():New('Tahoma',,-20,,.T.)
	Private oFont1 := TFont():New('Tahoma',,-12,,.T.)

	nReg   := IIf(nOpc==3,Nil,ZH5->(Recno()))
	cAlias := "ZH5"

	// Maximizacao da tela em relação a area de trabalho
	aSizeAut := MsAdvSize()

	aAdd(aObjects,{100,53,.T.,.T.})
	aAdd(aObjects,{100,47,.T.,.T.})

	aInfo   := {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
	aPosObj := MsObjSize(aInfo,aObjects, .T.)

	// Ajusta para ter mais um array com divisoes da dimenssao da tela
	aAdd(aPosObj,{aPosObj[1,1],aPosObj[1,4]*0.7+3,aPosObj[1,3],aPosObj[1,4]}) // Dimensao da MsMget em relacao ao Dialog  (LinhaI,ColunaI,LinhaF,ColunaF)
	aPosObj[1,3]:=aPosObj[1,3]*1.15
	aPosObj[1,4]:=aPosObj[1,4]*0.74

	// Verifica o tipo de chamada e trata a situação
	cNaoExbCps := ""

	Do Case
		Case nOpc == 2	// Visualização
			nOpEnch:= 2
			aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
		Case nOpc == 3	// Inclusão
			nOpEnch:= 3
			aExbCpo:= fInitVarX3(cAlias,.T.,cNaoExbCps)
		Case nOpc == 4	// Alteração
			nOpEnch:= 3
			aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
		Case nOpc == 5	// Exclusão
			nOpEnch:= 5
			aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
		Otherwise 		// Outras Situações
			nOpEnch:= 2
			aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
	EndCase

	// Montagem da tela que serah apresentada para usuario (lay-out)
	Define MsDialog oDlg Title cCadastro From aSizeAut[7],0 To aSizeAut[6],aSizeAut[5] Of oMainWnd Pixel

	// Montagem do Cabeçalho
	oEnch := Msmget():New(cAlias,nReg,nOpEnch,,,,aExbCpo,aPosObj[1],aExbCpo,,,,,oDlg,,.T.)

	// Montagem do CheckBox
	fChekBox(nOpc,oDlg,nReg)

	// Montagem dos Itens
	oSay1:= TSay():New(aPosObj[2,1]+37,aPosObj[2,2],{||'Produtos Devolvidos / Quantidades / Destino'},oDlg,,oFont,,,,.T.,CLR_HRED,CLR_WHITE,300,20)
	fGDItens(nOpc,oDlg,nReg)

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

	Do Case
	Case nOpc == 3 .And. nOpcao == 1		// Se for inclusao e foi confirmado
		fSalvaTudo(nOpc,cAlias,aExbCpo,nReg)
	Case nOpc == 4 .And. nOpcao == 1		// Se for alteracao e foi confirmado
		fSalvaTudo(nOpc,cAlias,aExbCpo,nReg)
	Case nOpc == 5 .And. nOpcao == 1		// Se for exclusao e foi confirmado
		fExcluiTudo()
	EndCase
Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} fInitVarX3
Funcao que carrega as variaveis em memoria
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function fInitVarX3(cAlias,lInitVarX3,cNaoExbCps)

	Local aExibLst := {}

	SX3->(DbSetOrder(1))
	SX3->(DbSeek(cAlias))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
		If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			If Empty(cNaoExbCps) .Or. !(AllTrim(SX3->X3_CAMPO) $ cNaoExbCps)
				If lInitVarX3
					_SetOwnerPrvt(Trim(SX3->X3_CAMPO),CriaVar(Trim(SX3->X3_CAMPO),.T.))
				Else
					If SX3->X3_CONTEXT != "V"
						_SetOwnerPrvt(Trim(SX3->X3_CAMPO),&(SX3->X3_CAMPO))
					Else
						_SetOwnerPrvt(Trim(SX3->X3_CAMPO),&(SX3->X3_RELACAO))
					EndIf
				EndIf
				AADD(aExibLst,SX3->X3_CAMPO)
			EndIf
		EndIf
		SX3->(DbSkip())
	End

Return(aExibLst)


//-----------------------------------------------------------------------
/*/{Protheus.doc} fChekBox
Funcao que monta Panel com checkbox
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function fChekBox(nOpc,oDefTela,nReg)

	Public oCheck01 := Nil
	Public oCheck02 := Nil
	Public oCheck03 := Nil
	Public oCheck04 := Nil
	Public oCheck05 := Nil
	Public oCheck06 := Nil
	Public oCheck07 := Nil
	Public oCheck08 := Nil
	Public oCheck09 := Nil
	Public oCheck10 := Nil
	Public oCheck11 := Nil
	Public oCheck12 := Nil
	Public oCheck13 := Nil
	Public oCheck14 := Nil
	Public oCheck15 := Nil
	Public oCheck16 := Nil
	Public oCheck17 := Nil
	Public oCheck18 := Nil
	Public oCheck19 := Nil
	Public oCheck20 := Nil
	Public oCheck21 := Nil
	Public oCheck22 := Nil
	Public oCheck23 := Nil
	Public oCheck24 := Nil
	Public oCheck25 := Nil
	Public lCheck01 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,01,1)=="S",.T.,.F.))
	Public lCheck02 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,02,1)=="S",.T.,.F.))
	Public lCheck03 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,03,1)=="S",.T.,.F.))
	Public lCheck04 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,04,1)=="S",.T.,.F.))
	Public lCheck05 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,05,1)=="S",.T.,.F.))
	Public lCheck06 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,06,1)=="S",.T.,.F.))
	Public lCheck07 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,07,1)=="S",.T.,.F.))
	Public lCheck08 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,08,1)=="S",.T.,.F.))
	Public lCheck09 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,09,1)=="S",.T.,.F.))
	Public lCheck10 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,10,1)=="S",.T.,.F.))
	Public lCheck11 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,11,1)=="S",.T.,.F.))
	Public lCheck12 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,12,1)=="S",.T.,.F.))
	Public lCheck13 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,13,1)=="S",.T.,.F.))
	Public lCheck14 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,14,1)=="S",.T.,.F.))
	Public lCheck15 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,15,1)=="S",.T.,.F.))
	Public lCheck16 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,16,1)=="S",.T.,.F.))
	Public lCheck17 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,17,1)=="S",.T.,.F.))
	Public lCheck18 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,18,1)=="S",.T.,.F.))
	Public lCheck19 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,19,1)=="S",.T.,.F.))
	Public lCheck20 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,20,1)=="S",.T.,.F.))
	Public lCheck21 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,21,1)=="S",.T.,.F.))
	Public lCheck22 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,22,1)=="S",.T.,.F.))
	Public lCheck23 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,23,1)=="S",.T.,.F.))
	Public lCheck24 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,24,1)=="S",.T.,.F.))
	Public lCheck25 := IIF(nOpc==3,.F.,IIF(Substr(ZH5->ZH5_MOTIVO,25,1)=="S",.T.,.F.))

	Public _aItens01 := {"1=Conforme","2=Não Conforme","3=Não Aplicável",""}
	Public _cCombo01 := IIF(nOpc==3,_aItens01[04],ZH5->ZH5_ACOMOD)
	Public _aItens02 := {"1=Conforme","2=Não Conforme","3=Não Aplicável",""}
	Public _cCombo02 := IIF(nOpc==3,_aItens02[04],ZH5->ZH5_ASPECT)
	Public _aItens03 := {"1=Conforme","2=Não Conforme","3=Não Aplicável",""}
	Public _cCombo03 := IIF(nOpc==3,_aItens03[04],ZH5->ZH5_TEMPER)
	Public _aItens04 := {"1=Conforme","2=Não Conforme","3=Não Aplicável",""}
	Public _cCombo04 := IIF(nOpc==3,_aItens04[04],ZH5->ZH5_INTSEC)
	Public _aItens05 := {"1=Conforme","2=Não Conforme","3=Não Aplicável",""}
	Public _cCombo05 := IIF(nOpc==3,_aItens05[04],ZH5->ZH5_INTPRI)
	Public _aItens06 := {"1=Conforme","2=Não Conforme","3=Não Aplicável",""}
	Public _cCombo06 := IIF(nOpc==3,_aItens06[04],ZH5->ZH5_ETIQUE)
	Public _aItens07 := {"1=Conforme","2=Não Conforme","3=Não Aplicável",""}
	Public _cCombo07 := IIF(nOpc==3,_aItens07[04],ZH5->ZH5_PADRON)
	Public _aItens08 := {"1=Conforme","2=Não Conforme","3=Não Aplicável",""}
	Public _cCombo08 := IIF(nOpc==3,_aItens08[04],ZH5->ZH5_OUTROS)

	@ aPosObj[3,1], aPosObj[3,2]+50 MSPANEL oPanel SIZE aPosObj[3,3], aPosObj[3,4] Of oDlg
	@ 000,000 SCROLLBOX oScroll SIZE 009,090 Pixel Of oPanel
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT

	oSay1:= TSay():New(03,05,{||'Motivos da Devolução'},oPanel,,oFont,,,,.T.,CLR_HRED,CLR_WHITE,200,20)

	@ 015, 005 CHECKBOX oCheck01 VAR lCheck01 Size 120,009 PROMPT '1) Vácuo'								FONT oFont1 OF oScroll
	@ 023, 005 CHECKBOX oCheck02 VAR lCheck02 Size 120,009 PROMPT '2) Gordura - Padrão'						FONT oFont1 OF oScroll
	@ 031, 005 CHECKBOX oCheck03 VAR lCheck03 Size 120,009 PROMPT '3) Magro - Padrão'  						FONT oFont1 OF oScroll
	@ 039, 005 CHECKBOX oCheck04 VAR lCheck04 Size 120,009 PROMPT '4) Pescoço - Padrão'  					FONT oFont1 OF oScroll
	@ 047, 005 CHECKBOX oCheck05 VAR lCheck05 Size 120,009 PROMPT '5) Padrão de Corte/Especificação'		FONT oFont1 OF oScroll
	@ 055, 005 CHECKBOX oCheck06 VAR lCheck06 Size 120,009 PROMPT '6) Data Curta'  							FONT oFont1 OF oScroll
	@ 063, 005 CHECKBOX oCheck07 VAR lCheck07 Size 120,009 PROMPT '7) Erro de Carregamento'					FONT oFont1 OF oScroll
	@ 071, 005 CHECKBOX oCheck08 VAR lCheck08 Size 120,009 PROMPT '8) Contaminação Física'		  			FONT oFont1 OF oScroll
	@ 079, 005 CHECKBOX oCheck09 VAR lCheck09 Size 120,009 PROMPT '9) Erro na Embalagem'					FONT oFont1 OF oScroll
	@ 087, 005 CHECKBOX oCheck10 VAR lCheck10 Size 120,009 PROMPT '10) Problemas de Recebimento no Cliente'	FONT oFont1 OF oScroll
	@ 095, 005 CHECKBOX oCheck11 VAR lCheck11 Size 120,009 PROMPT '11) Erros de Logística'					FONT oFont1 OF oScroll
	@ 103, 005 CHECKBOX oCheck12 VAR lCheck12 Size 120,009 PROMPT '12) Desacordo com o Pedido'				FONT oFont1 OF oScroll
	@ 111, 005 CHECKBOX oCheck13 VAR lCheck13 Size 120,009 PROMPT '13) Temperatura'							FONT oFont1 OF oScroll
	@ 119, 005 CHECKBOX oCheck14 VAR lCheck14 Size 120,009 PROMPT '14) Bandeja Quebrada'					FONT oFont1 OF oScroll
	@ 127, 005 CHECKBOX oCheck15 VAR lCheck15 Size 120,009 PROMPT '15) Absorvente Rasgado'					FONT oFont1 OF oScroll
	@ 135, 005 CHECKBOX oCheck16 VAR lCheck16 Size 120,009 PROMPT '16) Filme Baixo'							FONT oFont1 OF oScroll
	@ 143, 005 CHECKBOX oCheck17 VAR lCheck17 Size 120,009 PROMPT '17) Filme Rasgado'						FONT oFont1 OF oScroll
	@ 151, 005 CHECKBOX oCheck18 VAR lCheck18 Size 120,009 PROMPT '18) coloração'							FONT oFont1 OF oScroll
	@ 159, 005 CHECKBOX oCheck19 VAR lCheck19 Size 120,009 PROMPT '19) Sem Motivo'							FONT oFont1 OF oScroll
	@ 167, 005 CHECKBOX oCheck20 VAR lCheck20 Size 120,009 PROMPT '20) Improcedente'						FONT oFont1 OF oScroll
	@ 175, 005 CHECKBOX oCheck21 VAR lCheck21 Size 120,009 PROMPT '21) Odor'								FONT oFont1 OF oScroll
	@ 183, 005 CHECKBOX oCheck22 VAR lCheck22 Size 120,009 PROMPT '22) Sobra em Caminhão'					FONT oFont1 OF oScroll
	@ 191, 005 CHECKBOX oCheck23 VAR lCheck23 Size 120,009 PROMPT '23) Pedido Cancelado'					FONT oFont1 OF oScroll
	@ 199, 005 CHECKBOX oCheck24 VAR lCheck24 Size 120,009 PROMPT '24) Avaria nas Caixas'					FONT oFont1 OF oScroll
	@ 207, 005 CHECKBOX oCheck25 VAR lCheck25 Size 120,009 PROMPT '25) Outros'								FONT oFont1 OF oScroll

	oSay1 := TSay():New(228,05,{||'Avaliação das Condições'},oPanel,,oFont,,,,.T.,CLR_HRED,CLR_WHITE,200,20)

	oSay01   := TSay():New(240,05,{||'1-Acomodação do produto dentro do caminhão baú'}	,oPanel,,oFont1,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oCombo01 := tComboBox():New(240,110,{|u|if(PCount()>0,_cCombo01:=u,_cCombo01)},_aItens01,60,10,oPanel,,{||},,,,.T.,,,,,,,,,"_cCombo01")
	oSay02   := TSay():New(255,05,{||'2-Aspectos higiênico-sanitários da carga'}		,oPanel,,oFont1,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oCombo02 := tComboBox():New(255,110,{|u|if(PCount()>0,_cCombo02:=u,_cCombo02)},_aItens02,60,10,oPanel,,{||},,,,.T.,,,,,,,,,"_cCombo02")
	oSay03   := TSay():New(270,05,{||'3-Temperatura do produto'}						,oPanel,,oFont1,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oCombo03 := tComboBox():New(270,110,{|u|if(PCount()>0,_cCombo03:=u,_cCombo03)},_aItens03,60,10,oPanel,,{||},,,,.T.,,,,,,,,,"_cCombo03")
	oSay04   := TSay():New(285,05,{||'4-Integridade das embalagens secundárias'}		,oPanel,,oFont1,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oCombo04 := tComboBox():New(285,110,{|u|if(PCount()>0,_cCombo04:=u,_cCombo04)},_aItens04,60,10,oPanel,,{||},,,,.T.,,,,,,,,,"_cCombo04")
	oSay05   := TSay():New(300,05,{||'5-Integridade das embalagens primárias'}			,oPanel,,oFont1,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oCombo05 := tComboBox():New(300,110,{|u|if(PCount()>0,_cCombo05:=u,_cCombo05)},_aItens05,60,10,oPanel,,{||},,,,.T.,,,,,,,,,"_cCombo05")
	oSay06   := TSay():New(315,05,{||'6-Etiquetas'}										,oPanel,,oFont1,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oCombo06 := tComboBox():New(315,110,{|u|if(PCount()>0,_cCombo06:=u,_cCombo06)},_aItens06,60,10,oPanel,,{||},,,,.T.,,,,,,,,,"_cCombo06")
	oSay07   := TSay():New(330,05,{||'7-Padronização / especificação técnica'}			,oPanel,,oFont1,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oCombo07 := tComboBox():New(330,110,{|u|if(PCount()>0,_cCombo07:=u,_cCombo07)},_aItens07,60,10,oPanel,,{||},,,,.T.,,,,,,,,,"_cCombo07")
	oSay08   := TSay():New(345,05,{||'8-Outros'}										,oPanel,,oFont1,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oCombo08 := tComboBox():New(345,110,{|u|if(PCount()>0,_cCombo08:=u,_cCombo08)},_aItens08,60,10,oPanel,,{||},,,,.T.,,,,,,,,,"_cCombo08")

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} fGDItens
Funcao que monta MsNewGetDados
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function fGDItens(nOpc,oDefTela,nReg)

	// Posicao do elemento do vetor aRotina que a MsNewGetDados usará como referência  
	Local cGetOpc        := Iif(Altera .OR. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE, 0)    // GD_INSERT+GD_DELETE+GD_UPDATE  
	Local cLinhaOk       := "U_CriDvLOk"                    // Funcao executada para validar o contexto da linha atual do aCols                  
	Local cTudoOk        := "U_CriDvTOk"                    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
	Local cIniCpos       := "+ZH6_ITEM"                     // Nome dos campos do tipo caracter que utilizarao incremento automatico.                                                              
	Local nFreeze        := Nil                             // Campos estaticos na GetDados.                                                               
	Local nMax           := 999                             // Numero maximo de linhas permitidas. Valor padrao 99                           
	Local cCampoOk       := "U_CriDvCOk"                    // Funcao executada na validacao do campo                                           
	Local cSuperApagar   := Nil                             // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
	Local cApagaOk       := "U_CriDvDel"                    // Funcao executada para validar a exclusao de uma linha do aCols                   
	Local aHead          := {}                              // Array do aHeader
	Local aCols          := {}                              // Array do aCols

	// Valor das variaveis que as rotinas faCols e faHead irá utilizar como referencia
	Local x       := 1                                      // Variavel usada no For/Next
	Local cGetAls := "ZH6"                                  // Alias usado na função para montar o aHeader e o Acols
	Local nGetOpc := nOpc                                   // Opção da operação que está sendo executada
	Local cGetOrd := 1                                      // Ordem do Indice utilizado na função que carrega o aCols
	Local nGetQtd := 1                                      // Quantidade de linhas iniciadas no aCols quando inclusão
	Local cGetCnd := "xFilial('ZH5')+ZH5->ZH5_NUMREC"
	Local cGetCpo := "ZH6->ZH6_FILIAL+ZH6->ZH6_NUMREC"
	Local cExbCpo := "ZH6_ITEM/ZH6_PRODUT/ZH6_DESCRI/ZH6_ANOMAL/ZH6_DTPROD/ZH6_DESTIN/ZH6_QTDEST/ZH6_UMDEST"	// Forçar mostrar no MsNewGetDados apenas os campos definidos nesta variavel
	Local aTrtCpo := {}                            				          										// Array contendo campos com valores que serão usadas no aCols quando inclusão
	Local aArea := GetArea()

	// A quantidade máxima de linha conforme o tamanho do campo ZH6_ITEM
	nMax := Val(Replicate("9",TamSx3("ZH6_ITEM")[1]))

	// Montando um array conforme parametros acima para ser usada na função que montas o aCols
	For x:=1 To nGetQtd
		aAdd(aTrtCpo,{"ZH6_ITEM",StrZero(x,Len(CriaVar("ZH6_ITEM"))),.F.})
	Next x

	//Execução das rotinas
	aHead 	:= faHead(cGetAls,cExbCpo)
	aCols 	:= faCols(aHead,cGetAls,nGetQtd,nGetOpc,cGetOrd,cGetCnd,cGetCpo,cExbCpo,aTrtCpo)
	oGDItens := MsNewGetDados():New(aPosObj[2,1]+50,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]-200,cGetOpc,cLinhaOk,cTudoOk,cIniCpos,,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oDefTela,aHead,aCols)

	RestArea(aArea)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} faHead
Funcao que carrega aHeader usado no MsNewGetDados
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function faHead(cAlias,cExibeCpos)

	Local aHead := {}

	//  Montagem do aHeader
	SX3->(dbSetOrder(1))
	SX3->(dbSeek(cAlias))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
		If (X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL)
			If Empty(cExibeCpos) .Or. AllTrim(SX3->X3_CAMPO) $ cExibeCpos
				aAdd(aHead,{AllTrim(X3Titulo())	,;
							SX3->X3_CAMPO		,;
							SX3->X3_PICTURE		,;
							SX3->X3_TAMANHO		,;
							SX3->X3_DECIMAL		,;
							SX3->X3_VALID		,;
							SX3->X3_USADO		,;
							SX3->X3_TIPO		,;
							SX3->X3_F3			,;
							SX3->X3_CONTEXT		,;
							SX3->X3_CBOX		,;
							SX3->X3_RELACAO		,;
							SX3->X3_WHEN		,;
							SX3->X3_VISUAL		,;
							SX3->X3_VLDUSER		,;
							SX3->X3_PICTVAR		,;
							SX3->X3_OBRIGAT		})
			EndIf
		EndIf
		SX3->(DbSkip())
	End

Return(aHead)


//-----------------------------------------------------------------------
/*/{Protheus.doc} faCols
Funcao que carrega aCols usado no MsNewGetDados
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function faCols(aHead,cGetAls,nGetQtd,nGetOpc,cGetOrd,cGetCnd,cGetCpo,cExbCpo,aTrtCpo)

	Local lFoiTratado := .F.
	Local aCol        := {}
	Local y           := 1
	Local k           := 1

	If nGetOpc == 3
		// Montagem do aCols em Branco
		For y := 1 To nGetQtd
			AADD(aCol,Array(Len(aHead)+1))
			nLin := Len(aCol)
			// Sempre reposicionar a set para o alias correto
			SX3->(DbSetOrder(1))
			SX3->(DbSeek(cGetAls))
			While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cGetAls
				If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
					// Faz tratamento para montagem do acols somente com campos especificos ou com todos habilitados via sigacfg
					If Empty(cExbCpo) .Or. AllTrim(SX3->X3_CAMPO) $ cExbCpo
						// Faz tratamento de campos especificas caso seja necessario
						lFoiTratado := .F.
						For k := 1 To Len(aTrtCpo)
							If aTrtCpo[k,1] $ SX3->X3_CAMPO .And. !aTrtCpo[k,3]
								aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(SX3->X3_CAMPO)})] := aTrtCpo[k,2]
								aTrtCpo[k,3] := .T.
								lFoiTratado := .T.
								k := Len(aTrtCpo)
							EndIf
						Next k
						// Caso não seja um tratamento especifico seguirá o padrão
						If !lFoiTratado
							If Empty(SX3->X3_RELACAO)
								aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(SX3->X3_CAMPO)})] := CriaVar(SX3->X3_CAMPO)
							Else
								aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(SX3->X3_CAMPO)})] := &(SX3->X3_RELACAO)
							EndIf
						EndIf
					EndIf
				EndIf
				SX3->(DbSkip())
			End
			aCol[nLin,Len(aHead)+1] := .F.
		Next y
	Else
		// Montagem do aCols com registros caso tenha
		DbSelectArea(cGetAls)
		DbSetOrder(cGetOrd)
		If DbSeek(&(cGetCnd))
			While !EOF() .And. &(cGetCnd) == &(cGetCpo)
				aAdd(aCol,Array(Len(aHead)+1))
				nLin := Len(aCol)

				SX3->(DbSetOrder(1))
				SX3->(DbSeek(cGetAls))
				While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cGetAls
					If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
						// Faz tratamento para montagem do acols somente com campos especificos ou com todos habilitados via sigacfg
						If Empty(cExbCpo) .Or. AllTrim(SX3->X3_CAMPO) $ cExbCpo
							aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(SX3->X3_CAMPO)})] := &(SX3->X3_CAMPO)
						EndIf
					EndIf
					SX3->(DbSkip())
				End

				aCol[nLin,Len(aHead)+1] := .F.
				DbSkip()
			End
		EndIf
	EndIf

Return(aCol)


//-----------------------------------------------------------------------
/*/{Protheus.doc} CriDvLOk
Funcao que valida linhas do MsNewGetDados para obrigar preenchimento dos
campos obrigatorios
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
User Function CriDvLOk()

	Local nGDLin := oGDItens:oBrowse:nAt
	Local nGDCol := 1
	Local lRet   := .T.

	// Valida campos obrigatorios do MsNewGetDados
	For nGDCol:=1 To Len(oGDItens:aHeader)
		If X3OBRIGAT(oGDItens:aHeader[nGDCol,2]) .And. Empty(oGDItens:aCols[nGDLin,nGDCol])
			lRet := .F.
			Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(oGDItens:aHeader[nGDCol,2])),3,1)
			nGDCol:=Len(oGDItens:aHeader)
		EndIf
	Next nGDCol

Return(lRet)


//-----------------------------------------------------------------------
/*/{Protheus.doc} CriDvTOk
Funcao que valida todos os campos do MsNewGetDados de todas as linhas para
obrigar preenchimento dos campos obrigatórios.
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
User Function CriDvTOk()

	Local nGDLin := 1
	Local nGDCol := 1
	Local lRet := .T.

	// Valida campos obrigatorios do MsNewGetDados
	For nGDLin:=1 To Len(oGDItens:aCols)
		For nGDCol:=1 To Len(oGDItens:aHeader)
			If X3OBRIGAT(oGDItens:aHeader[nGDCol,2]) .And. Empty(oGDItens:aCols[nGDLin,nGDCol])
				lRet := .F.
				Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(oGDItens:aHeader[nGDCol,2])),3,1)
				nGDLin:=Len(oGDItens:aCols)
				nGDCol:=Len(oGDItens:aHeader)
			EndIf
		Next nGDCol
	Next nGDLin

Return(lRet)


//-----------------------------------------------------------------------
/*/{Protheus.doc} CriDvCOk
Funcao que valida campos do MsNewGetDados para proibir duplicidades e tratar
alteração do codigo digitado que já foi utilizado.
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
User Function CriDvCOk()

	Local nGDLin := oGDItens:oBrowse:nAt
	Local nGDCol := oGDItens:oBrowse:ColPos
	Local cGDCpo := &("M->"+oGDItens:aHeader[nGDCol,2])
	Local cVCpos := "ZH6_ITEM/ZH6_PRODUT"
	Local nLinha := 1
	Local lRet 	 := .T.

	// Trava alteração caso arquivo deletado
	If oGDItens:aCols[nGDLin,Len(oGDItens:aHeader)+1] .And. lRet
		lRet := .F.
		Help(" ",1,"HELP","PROIBIDO","Favor restaurar linha excluída para depois alterar.",3,1)
	Endif

	// Valida duplicidade de alguns campos do MsNewGetDados conforme definido acima na variavel cVCpos
	If AllTrim(oGDItens:aHeader[nGDCol,2]) $ cVCpos .And. lRet
		For nLinha:=1 To Len(oGDItens:aCols)
			If nLinha != nGDLin
				If AllTrim(cGDCpo) == AllTrim(oGDItens:aCols[nLinha,nGDCol])
					lRet := .F.
					Help(" ",1,"EXISTE",,"Já existe um registro com esta informação!",3,1)
					nLinha := Len(oGDItens:aCols)
				EndIf
			EndIf
		Next nLinha
	EndIf

Return(lRet)


//-----------------------------------------------------------------------
/*/{Protheus.doc} CriDvDel
Funcao que valida exclusão de linhas do MsNewGetDados para verificar se já
foi utilizada em alguma outra rotina.
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
User Function CriDvDel()

	Local lRet := .T.

Return(lRet)


//-----------------------------------------------------------------------
/*/{Protheus.doc} fSalvaTudo
Funcao que é responsável pela gravação das inclusões e alterações.
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function fSalvaTudo(nOpc,cAlias,aExbCpo,nReg)

	// Declara variaveis
	Local aArea	   := ZH5->(GetArea())
	Local x        := 1
	Local k        := 1
	Local nOrdSeek := 1
	Local aGrvCps  := {}
	Local aGrvZH6  := {}
	Local cCpoItem := "ZH6_ITEM"
	Local cCndSeek := "xFilial('ZH5')+ZH5->ZH5_NUMREC" 
	Local cAnPos01 := "N"
	Local cAnPos02 := "N"
	Local cAnPos03 := "N"
	Local cAnPos04 := "N"
	Local cAnPos05 := "N"
	Local cAnPos06 := "N"
	Local cAnPos07 := "N"
	Local cAnPos08 := "N"
	Local cAnPos09 := "N"
	Local cAnPos10 := "N"
	Local cAnPos11 := "N"
	Local cAnPos12 := "N"
	Local cAnPos13 := "N"
	Local cAnPos14 := "N"
	Local cAnPos15 := "N"
	Local cAnPos16 := "N"
	Local cAnPos17 := "N"
	Local cAnPos18 := "N"
	Local cAnPos19 := "N"
	Local cAnPos20 := "N"
	Local cAnPos21 := "N"
	Local cAnPos22 := "N"
	Local cAnPos23 := "N"
	Local cAnPos24 := "N"
	Local cAnPos25 := "N"

	// Trata campos do enchoice
	For x:=1 To Len(aExbCpo)
		aAdd(aGrvCps,{aExbCpo[x] ,"M->"+aExbCpo[x] })
	Next x

	If lCheck01
		cAnPos01 := "S"
	Endif
	If lCheck02
		cAnPos02 := "S"
	Endif
	If lCheck03
		cAnPos03 := "S"
	Endif
	If lCheck04
		cAnPos04 := "S"
	Endif
	If lCheck05
		cAnPos05 := "S"
	Endif
	If lCheck06
		cAnPos06 := "S"
	Endif
	If lCheck07
		cAnPos07 := "S"
	Endif
	If lCheck08
		cAnPos08 := "S"
	Endif
	If lCheck09
		cAnPos09 := "S"
	Endif
	If lCheck10
		cAnPos10 := "S"
	Endif
	If lCheck11
		cAnPos11 := "S"
	Endif
	If lCheck12
		cAnPos12 := "S"
	Endif
	If lCheck13
		cAnPos13 := "S"
	Endif
	If lCheck14
		cAnPos14 := "S"
	Endif
	If lCheck15
		cAnPos15 := "S"
	Endif
	If lCheck16
		cAnPos16 := "S"
	Endif
	If lCheck17
		cAnPos17 := "S"
	Endif
	If lCheck18
		cAnPos18 := "S"
	Endif
	If lCheck19
		cAnPos19 := "S"
	Endif
	If lCheck20
		cAnPos20 := "S"
	Endif
	If lCheck21
		cAnPos21 := "S"
	Endif
	If lCheck22
		cAnPos22 := "S"
	Endif
	If lCheck23
		cAnPos23 := "S"
	Endif
	If lCheck24
		cAnPos24 := "S"
	Endif
	If lCheck25
		cAnPos25 := "S"
	Endif

	If nOpc == 3 .Or. nOpc == 4
		// Grava campos do cabeçalho
		DbSelectArea("ZH5")
		If nOpc == 3
			RecLock("ZH5",.T.)
		ElseIf nOpc == 4
			RecLock("ZH5",.F.)
		Else
			RecLock("ZH5",.F.)
		EndIf

		ZH5->ZH5_FILIAL := xFilial("ZH5")
		For k:=1 TO Len(aGrvCps)
			&(aGrvCps[k,1]) := &(aGrvCps[k,2])
		Next k
		ZH5->ZH5_MOTIVO := cAnPos01+cAnPos02+cAnPos03+cAnPos04+cAnPos05+cAnPos06+cAnPos07+cAnPos08+cAnPos09+cAnPos10+cAnPos11+cAnPos12+cAnPos13+cAnPos14+cAnPos15+cAnPos16+cAnPos17+cAnPos18+cAnPos19+cAnPos20+cAnPos21+cAnPos22+cAnPos23+cAnPos24+cAnPos25
		ZH5->ZH5_ACOMOD := _cCombo01
		ZH5->ZH5_ASPECT := _cCombo02
		ZH5->ZH5_TEMPER := _cCombo03
		ZH5->ZH5_INTSEC := _cCombo04
		ZH5->ZH5_INTPRI := _cCombo05
		ZH5->ZH5_ETIQUE := _cCombo06
		ZH5->ZH5_PADRON := _cCombo07
		ZH5->ZH5_OUTROS := _cCombo08

		If nOpc == 3
			// Gravação dos campos MEMO na tabela SYP
			_cObserv := M->ZH5_VMOBS
			_nTam    := TamSX3("ZH5_VMOBS")
			_nTam1   := _nTam[1]
			MSMM(,_nTam1,,_cObserv,1,,,"ZH5","ZH5_CDOBS")

			_cNaoCon := M->ZH5_VMNCON
			_nTam    := TamSX3("ZH5_VMNCON")
			_nTam1   := _nTam[1]
			MSMM(,_nTam1,,_cNaoCon,1,,,"ZH5","ZH5_CDNCON")

			_cAcaoCo := M->ZH5_VMACOR
			_nTam    := TamSX3("ZH5_VMACOR")
			_nTam1   := _nTam[1]
			MSMM(,_nTam1,,_cAcaoCo,1,,,"ZH5","ZH5_CDACOR")

			_cResPrz := M->ZH5_VMRPRZ
			_nTam    := TamSX3("ZH5_VMRPRZ")
			_nTam1   := _nTam[1]
			MSMM(,_nTam1,,_cResPrz,1,,,"ZH5","ZH5_CDRPRZ")
		ElseIf nOpc == 4
			// Gravação dos campos MEMO na tabela SYP
			_cObserv := M->ZH5_VMOBS
			_nTam    := TamSX3("ZH5_VMOBS")
			_nTam1   := _nTam[1]
			MSMM(ZH5->ZH5_CDOBS,_nTam1,,_cObserv,1,,,"ZH5","ZH5_CDOBS")

			_cNaoCon := M->ZH5_VMNCON
			_nTam    := TamSX3("ZH5_VMNCON")
			_nTam1   := _nTam[1]
			MSMM(ZH5->ZH5_CDNCON,_nTam1,,_cNaoCon,1,,,"ZH5","ZH5_CDNCON")

			_cAcaoCo := M->ZH5_VMACOR
			_nTam    := TamSX3("ZH5_VMACOR")
			_nTam1   := _nTam[1]
			MSMM(ZH5->ZH5_CDACOR,_nTam1,,_cAcaoCo,1,,,"ZH5","ZH5_CDACOR")

			_cResPrz := M->ZH5_VMRPRZ
			_nTam    := TamSX3("ZH5_VMRPRZ")
			_nTam1   := _nTam[1]
			MSMM(ZH5->ZH5_CDRPRZ,_nTam1,,_cResPrz,1,,,"ZH5","ZH5_CDRPRZ")
		EndIf

		MsUnlock()
	Endif

	// Executa rotina pra tratar gravação das variaveis acima e do MsNewGetDados
	fGravaGD(oGDItens,"ZH6",aGrvZH6,nOpc,nOrdSeek,cCndSeek,cCpoItem,ZH5->ZH5_NUMREC)

	RestArea(aArea)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} fGravaGD
Funcao que é responsável pela gravacao das inclusoes e alteracoes apontadas
no MsNewGetDados / tratamento por objeto.
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function fGravaGD(oObjct,cAlias,aCposAdd,nTpOper,nOrdSeek,cCndSeek,cCpoItm,cNumRec)

	Local x := 1
	Local y := 1

	Private cCodItem := StrZero(1,Len(CriaVar(cCpoItm)))

	DbSelectArea(cAlias)

	For x:=1 To Len(oObjct:aCols)
		If !oObjct:aCols[x,Len(oObjct:aHeader)+1]

			DbSelectArea(cAlias)
			DbSetOrder(nOrdSeek)

			If nTpOper == 3
				RecLock(cAlias,.T.)
			ElseIf DbSeek(&(cCndSeek)+oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==cCpoItm})])
				RecLock(cAlias,.F.)
			Else
				RecLock(cAlias,.T.)
			EndIf

			For y:=1 To Len(oObjct:aHeader)
				&(oObjct:aHeader[y,2]) := oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==AllTrim(oObjct:aHeader[y,2])})]
			Next y

			cCodItem 		:= Soma1(cCodItem)
			ZH6->ZH6_FILIAL := xFilial("ZH6")
			ZH6->ZH6_NUMREC := cNumRec
			MsUnLock()
		Else
			DbSelectArea(cAlias)
			DbSetOrder(nOrdSeek)
			If nTpOper != 3
				If DbSeek(&(cCndSeek)+oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==cCpoItm})])
					RecLock(cAlias,.F.)
					DbDelete()
					MsUnLock()
				EndIf
			EndIf
		EndIf
	Next x

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} fExcluiTudo
Funcao que é responsável pela exclusão de todos itens apresentados na tela.
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function fExcluiTudo()

	_cAlias := Alias()

	If Aviso("Confirma exclusão?","Todos dados deste recibo serão excluídos.",{"Confirma","Cancela"}) == 1

		// Executa procedimento de exclusão de registros
		ZH5->(DbSetOrder(1))
		If ZH5->(DbSeek(xFilial('ZH5') + ZH5->ZH5_NUMREC))

			// Efetua exclusão dos campos MEMO na tabela SYP
			DbSelectArea("SYP")
			DbSeek(FWxFilial("SYP") + ZH5->ZH5_CDOBS)
			If Found()
				While SYP->YP_CHAVE == ZH5->ZH5_CDOBS
					Reclock("SYP",.F.)
					DbDelete()
					MsUnlock()
					DbSkip()
				Enddo
			Endif

			DbSelectArea("SYP")
			DbSeek(FWxFilial("SYP") + ZH5->ZH5_CDNCON)
			If Found()
				While SYP->YP_CHAVE == ZH5->ZH5_CDNCON
					Reclock("SYP",.F.)
					DbDelete()
					MsUnlock()
					DbSkip()
				Enddo
			Endif

			DbSelectArea("SYP")
			DbSeek(FWxFilial("SYP") + ZH5->ZH5_CDACOR)
			If Found()
				While SYP->YP_CHAVE == ZH5->ZH5_CDACOR
					Reclock("SYP",.F.)
					DbDelete()
					MsUnlock()
					DbSkip()
				Enddo
			Endif

			DbSelectArea("SYP")
			DbSeek(FWxFilial("SYP") + ZH5->ZH5_CDRPRZ)
			If Found()
				While SYP->YP_CHAVE == ZH5->ZH5_CDRPRZ
					Reclock("SYP",.F.)
					DbDelete()
					MsUnlock()
					DbSkip()
				Enddo
			Endif

			DbSelectArea(_cAlias)

			// Deleta todos os itens do recibo
			ZH6->(DbSetOrder(1))
			If ZH6->(DbSeek(xFilial('ZH6') + ZH5->ZH5_NUMREC))
				While ZH6->(!Eof()) .And. ZH6->ZH6_FILIAL + ZH6->ZH6_NUMREC == xFilial('ZH6') + ZH5->ZH5_NUMREC
					RecLock("ZH6",.F.)
					DbDelete()
					MsUnLock()
					ZH6->(DbSkip())
				End
			Endif

			// Deleta cabeçalho do recibo
			DbSelectArea("ZH5")
			RecLock("ZH5",.F.)
			DbDelete()
			MsUnLock()
		EndIf
	EndIf

Return
