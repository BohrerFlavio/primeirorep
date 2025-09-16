#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} STI_RG04
Função para cadastro e manutenção das ordens de recebimento - Cabeçalho (SZD) e Itens (SZE)
@author 	Evandro Mugnol
@since 		Out/2017
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas.
/*/

User Function STI_RG04(nOpc)

	Private cAlias    := "SZD"
	Private aRotina   := MenuDef()
	Private cCadastro := "Ordem de Recebimento"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse(6,1,22,75,cAlias,,,,,,,,,,,,,,)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Evandro Mugnol        ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

	Local aRotina := {	{ OemToAnsi("Pesquisar")	,"AxPesqui"	  	, 0 , 1,,.F.} ,;
						{ OemToAnsi("Visualizar")	,"U_RG04Inc" 	, 0 , 2		} ,;
						{ OemToAnsi("Incluir")		,"U_RG04Inc"	, 0 , 3		} ,;
						{ OemToAnsi("Alterar")		,"U_RG04Inc"	, 0 , 4		} ,;
						{ OemToAnsi("Excluir")		,"U_RG04Inc"	, 0 , 5		} ,;
						{ OemToAnsi("Veículos")     ,"U_RG04Vei"	, 0 , 3		} ,;
						{ OemToAnsi("Pesos")        ,"U_RG04Pes"	, 0 , 3		}  }

Return(aRotina)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RG04Inc  ³ Autor ³ Evandro Mugnol        ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Exibe na tela enchoice e a getdados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RG04Inc(cAlias,nReg,nOpc)

	// Declaração das variaveis
	Local nSaveSx8Len := GetSx8Len()

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

	If (nOpc == 3 .Or. nOpc == 4)
		Aadd(aButtons,{"AUTOM", {||RG04Vin()},"Vincula SC"      ,"Vincula SC"      })
		Aadd(aButtons,{"EDIT",  {||RG04Cop()},"Copia Mangueiras","Copia Mangueiras"})
		Aadd(aButtons,{"BUDGET",{||RG04Ite()},"Copia Item"      ,"Copia Item"      })
	EndIf

	If (nOpc == 2 )
		Aadd(aButtons,{"AUTOM", {||RG04VQr()},"Visualiza QR"    ,"Visualiza QR"  })
	endif

	nReg   := IIf(nOpc==3,Nil,SZD->(Recno()))
	cAlias := "SZD"

	// Maximizacao da tela em relação a area de trabalho
	aSizeAut := MsAdvSize()
	aAdd(aObjects,{100,040,.T.,.F.})
	aAdd(aObjects,{100,100,.T.,.T.})

	aInfo   := {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
	aPosObj := MsObjSize(aInfo,aObjects)

	// Ajusta para ter mais um array com divisoes da dimenssao da tela
	aAdd(aPosObj,{aPosObj[1,1],aPosObj[1,4]*0.7+3,aPosObj[1,3]+50,(aPosObj[1,4]*0.3)-3}) // Dimensao da MsMget em relacao ao Dialog  (LinhaI,ColunaI,LinhaF,ColunaF)
	aPosObj[1,4]:=aPosObj[1,4]*0.7
	aPosObj[1,3]:=(aPosObj[1,3]*3.2)+50

	// Verifica o tipo de chamada e trata a situação
	cNaoExbCps := "ZD_QTDTOT/ZD_TRACE"

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
	fGDItens(nOpc,oDlg,nReg)

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

	Do Case
	Case nOpc == 3 .And. nOpcao == 1		// Se for inclusao e foi confirmado
		fSalvaTudo(nOpc,cAlias,aExbCpo,nReg)
		// Atualiza ou retorna sequencial da ordem de recebimento
		While GetSx8Len() > nSaveSx8Len
			IF nOpcao == 1
				ConfirmSX8()
			Else
				RollBackSX8()
			Endif
		Enddo
	Case nOpc == 4 .And. nOpcao == 1		// Se for alteracao e foi confirmado
		_cCaclrepl := CalcRepl(M->ZD_NUMERO)
		_cNumAvMat := GetAdvFval('SZE','ZE_NUMAM',FWxFilial('SZE') + M->ZD_NUMERO,1)

		if(_cCaclrepl > 0)
			SZG->(dbSetOrder(1))
			if (SZG->(MsSeek(FWxFilial('SZG') + _cNumAvMat)))
				_nQtdTot := GetAdvFval('SZG','ZG_QTDTOT',FWxFilial('SZG') + _cNumAvMat,1) - _cCaclrepl

				Reclock('SZG',.F.)
				SZG->ZG_QTDTOT := _nQtdTot
				MsUnLock()
			endif
		endif
		fSalvaTudo(nOpc,cAlias,aExbCpo,nReg)
	Case nOpc == 5 .And. nOpcao == 1		// Se for exclusao e foi confirmado
		fExcluiTudo()
	OtherWise
		While GetSx8Len() > nSaveSx8Len
			// Retorna sequencial da ordem de recebimento no cancelamento
			RollBackSX8()
		End
	EndCase

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ fInitVarX3   ³ Autor ³ Evandro Mugnol    ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Carrega as variaveis em memoria                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fInitVarX3(cAlias,lInitVarX3,cNaoExbCps)

	Local i
	Local aExibLst := {}

	//SX3->(DbSetOrder(1))
	//SX3->(MsSeek(cAlias))
	//While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
	//	If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
	_cAlias  := cAlias
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO'))) .And. cNivel >= GetSx3Cache(_aCpoSX3[i], 'X3_NIVEL')
			If Empty(cNaoExbCps) .Or. !(AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) $ cNaoExbCps)
				If lInitVarX3
					_SetOwnerPrvt(Trim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')),CriaVar(Trim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')),.T.))
				Else
					If GetSx3Cache(_aCpoSX3[i], 'X3_CONTEXT') != "V"
						_SetOwnerPrvt(Trim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')),&(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')))
					Else
						_SetOwnerPrvt(Trim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')),&(GetSx3Cache(_aCpoSX3[i], 'X3_RELACAO')))
					EndIf
				EndIf
				AADD(aExibLst,GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO'))
			EndIf
		EndIf
	Next
	//	SX3->(DbSkip())
	//End

Return(aExibLst)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ fChekBox     ³ Autor ³ Evandro Mugnol    ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Monta Panel com checkbox                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fChekBox(nOpc,oDefTela,nReg)

	Public nTotAni := IIF(nOpc==3,0    ,SZD->ZD_QTDTOT)
	Public cTrace  := IIF(nOpc==3,"   ",IIF(SZD->ZD_TRACE=="S","Sim","Não"))

	@ aPosObj[3,1], aPosObj[3,2] MSPANEL oPanel SIZE aPosObj[3,4], aPosObj[1,3]-2 Of oDlg
	@ 000,000 SCROLLBOX oScroll SIZE 010,010 Pixel Of oPanel
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT

	@ 020, 015 Say "Animais Previstos"  								Size 150,010 COLOR CLR_RED	Of oScroll Pixel
	@ 030, 015 Get nTotAni Picture "@E 9999999999"	When .F. 	Size 050,010 					Of oScroll Pixel

	@ 045, 015 Say "Propriedade TRACE"              				Size 150,010 COLOR CLR_RED	Of oScroll Pixel
	@ 055, 015 Get cTrace  Picture "@!"					When .F. 	Size 050,010 					Of oScroll Pixel

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ fGDItens     ³ Autor ³ Evandro Mugnol    ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Monta MsNewGetDados                                        ³±±
±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGDItens(nOpc,oDefTela,nReg)

	// Posicao do elemento do vetor aRotina que a MsNewGetDados usará como referência
	Local cGetOpc        := Iif(Altera .OR. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE, 0)    // GD_INSERT+GD_DELETE+GD_UPDATE
	Local cLinhaOk       := "U_RG04LOk"                     // Funcao executada para validar o contexto da linha atual do aCols
	Local cTudoOk        := "U_RG04TOk"                     // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
	Local cIniCpos       := "+ZE_ITEM"                      // Nome dos campos do tipo caracter que utilizarao incremento automatico.
	Local nFreeze        := Nil                             // Campos estaticos na GetDados.
	Local nMax           := 999                             // Numero maximo de linhas permitidas. Valor padrao 99
	Local cCampoOk       := "U_RG04COk"                     // Funcao executada na validacao do campo
	Local cSuperApagar   := Nil                             // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
	Local cApagaOk       := "U_RG04Del"                     // Funcao executada para validar a exclusao de uma linha do aCols
	Local aHead          := {}                              // Array do aHeader
	Local aCols          := {}                              // Array do aCols

	// Valor das variaveis que as rotinas faCols e faHead irá utilizar como referencia
	Local x       := 1                                       						// Variavel usada no For/Next
	Local cGetAls := "SZE"                                   						// Alias usado na função para montar o aHeader e o Acols
	Local nGetOpc := nOpc                                    						// Opção da operação que está sendo executada
	Local cGetOrd := 1                                       						// Ordem do Indice utilizado na função que carrega o aCols
	Local nGetQtd := 1                                       						// Quantidade de linhas iniciadas no aCols quando inclusão
	Local cGetCnd := "FWxFilial('SZD')+SZD->ZD_NUMERO"           						//
	Local cGetCpo := "SZE->ZE_FILIAL+SZE->ZE_NUMERO"         						//
	Local cExbCpo := "ZE_ITEM/ZE_PRODUTO/ZE_DESCRI/ZE_OBS/ZE_QTD1UM/ZE_UM/ZE_LOCAL/ZE_CATEG/ZE_RACA/ZE_TPCOM/ZE_NUMSC/ZE_ITEMSC/ZE_NUMAM/ZE_LOTE/ZE_HORA/ZE_PLACA/ZE_SERGTA/ZE_GTA/ZE_PROGRAM/ZE_IDLOT"	// Forçar mostrar no MsNewGetDados apenas os campos definidos nesta variavel
	Local aTrtCpo := {}                            				          			// Array contendo campos com valores que serão usadas no aCols quando inclusão
	Local aArea := GetArea()

	// A quantidade máxima de linha conforme o tamanho do campo ZE_ITEM
	nMax := Val(Replicate("9",TamSx3("ZE_ITEM")[1]))

	// Montando um array conforme parametros acima para ser usada na função que montas o aCols
	For x:=1 To nGetQtd
		aAdd(aTrtCpo,{"ZE_ITEM",StrZero(x,Len(CriaVar("ZE_ITEM"))),.F.})
	Next x

	// Execução das rotinas
	aHead 	:= faHead(cGetAls,cExbCpo)
	aCols 	:= faCols(aHead,cGetAls,nGetQtd,nGetOpc,cGetOrd,cGetCnd,cGetCpo,cExbCpo,aTrtCpo)
	oGDItens := MsNewGetDados():New(aPosObj[2,1]+150,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],cGetOpc,cLinhaOk,cTudoOk,cIniCpos,,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oDefTela,aHead,aCols)

	RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ faHead       ³ Autor ³ Evandro Mugnol    ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Carrega aHeader usado no MsNewGetDados                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function faHead(cAlias,cExibeCpos)

	Local aHeader := {}
	Local i

	// Montagem do aHeader
	//SX3->(dbSetOrder(1))
	//SX3->(MsSeek(cAlias))
	//While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
	//	If (X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL)
	_cAlias  := cAlias
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO'))) .And. cNivel >= GetSx3Cache(_aCpoSX3[i], 'X3_NIVEL')
			If Empty(cExibeCpos) .Or. AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) $ cExibeCpos
				aAdd(aHeader, { GetSx3Cache(_aCpoSX3[i], 'X3_TITULO')	,;
								GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')	,;
								GetSx3Cache(_aCpoSX3[i], 'X3_PICTURE')	,;
								GetSx3Cache(_aCpoSX3[i], 'X3_TAMANHO')	,;
								GetSx3Cache(_aCpoSX3[i], 'X3_DECIMAL')	,;
								GetSx3Cache(_aCpoSX3[i], 'X3_VALID')	,;
								GetSx3Cache(_aCpoSX3[i], 'X3_USADO')	,;
								GetSx3Cache(_aCpoSX3[i], 'X3_TIPO')		,;
								GetSx3Cache(_aCpoSX3[i], 'X3_F3')		,;
								GetSx3Cache(_aCpoSX3[i], 'X3_CONTEXT')	,;
								GetSx3Cache(_aCpoSX3[i], 'X3_CBOX')		,;
								GetSx3Cache(_aCpoSX3[i], 'X3_RELACAO')	,;
								GetSx3Cache(_aCpoSX3[i], 'X3_WHEN')		,;
								GetSx3Cache(_aCpoSX3[i], 'X3_VISUAL')	,;
								GetSx3Cache(_aCpoSX3[i], 'X3_VLDUSER')	,;
								GetSx3Cache(_aCpoSX3[i], 'X3_PICTVAR')	,;
								GetSx3Cache(_aCpoSX3[i], 'X3_OBRIGAT')	})
			EndIf
		EndIf
	Next

	//SX3->(DbSkip())
	//End

Return(aHeader)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ faCols       ³ Autor ³ Evandro Mugnol    ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Carrega aCols usado no MsNewGetDados                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function faCols(aHead,cGetAls,nGetQtd,nGetOpc,cGetOrd,cGetCnd,cGetCpo,cExbCpo,aTrtCpo)

	Local lFoiTratado := .F.
	Local aCol        := {}
	Local y           := 1
	Local k           := 1
	Local i

	If nGetOpc == 3
		// Montagem do aCols em Branco
		For y := 1 To nGetQtd
			AADD(aCol,Array(Len(aHead)+1))
			nLin	:= Len(aCol)
			//Sempre reposicionar a set para o alias correto
			//SX3->(DbSetOrder(1))
			//SX3->(MsSeek(cGetAls))
			//While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cGetAls
			//	If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			_cAlias  := cGetAls
			_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
			For i := 1 To Len(_aCpoSX3)
				If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO'))) .And. cNivel >= GetSx3Cache(_aCpoSX3[i], 'X3_NIVEL')
					//Faz tratamento para montagem do acols somente com campos especificos ou com todos habilitados via sigacfg
					If Empty(cExbCpo) .Or. AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) $ cExbCpo
						//Faz tratamento de campos especificas caso seja necessario
						lFoiTratado := .F.
						For k := 1 To Len(aTrtCpo)
							If aTrtCpo[k,1] $ GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO') .And. !aTrtCpo[k,3]
								aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO'))})] := aTrtCpo[k,2]
								aTrtCpo[k,3] := .T.
								lFoiTratado := .T.
								k := Len(aTrtCpo)
							EndIf
						Next k
						//Caso não seja um tratamento especifico seguirá o padrão
						If !lFoiTratado
							If Empty(GetSx3Cache(_aCpoSX3[i], 'X3_RELACAO'))
								aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO'))})] := CriaVar(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO'))
							Else
								aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO'))})] := &(GetSx3Cache(_aCpoSX3[i], 'X3_RELACAO'))
							EndIf
						EndIf
					EndIf
				EndIf
			Next
			//	SX3->(DbSkip())
			//End
			aCol[nLin,Len(aHead)+1] := .F.
		Next y
	Else
		// Montagem do aCols com registros caso tenha             

		DbSelectArea(cGetAls)
		DbSetOrder(cGetOrd)
		If MsSeek(&(cGetCnd)) 

			While !EOF() .And. &(cGetCnd) == &(cGetCpo)
				aAdd(aCol,Array(Len(aHead)+1))
				nLin	:= Len(aCol)
				//SX3->(DbSetOrder(1))
				//SX3->(MsSeek(cGetAls))
				//While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cGetAls   
				//	If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
				_cAlias  := cGetAls
				_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
				For i := 1 To Len(_aCpoSX3)
					If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO'))) .And. cNivel >= GetSx3Cache(_aCpoSX3[i], 'X3_NIVEL')
						//Faz tratamento para montagem do acols somente com campos especificos ou com todos habilitados via sigacfg   
						_VlrCamp := iif(GetSx3Cache(_aCpoSX3[i], 'X3_CONTEXT') = 'V',GetAdvFVal("SB1","B1_DESC",(FWXFILIAL("SDT")+SDT->DT_COD),1), &(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')))
						If Empty(cExbCpo) .Or. AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) $ cExbCpo
							aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO'))})] := _VlrCamp//&(SX3->X3_CAMPO)
						EndIf
					EndIf
				Next	
				//	SX3->(DbSkip())
				//End

				aCol[nLin,Len(aHead)+1] := .F.
				DbSkip()
			End  

		EndIf
	EndIf

	/*
	Local lFoiTratado := .F.
	Local aCol        := {}
	Local y           := 1
	Local k           := 1

	If nGetOpc == 3
		// Montagem do aCols em Branco
		For y := 1 To nGetQtd
			AADD(aCol,Array(Len(aHead)+1))
			nLin	:= Len(aCol)
			// Sempre reposicionar a set para o alias correto
			SX3->(DbSetOrder(1))
			SX3->(MsSeek(cGetAls))
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
		If MsSeek(&(cGetCnd))
			While !EOF() .And. &(cGetCnd) == &(cGetCpo)
				aAdd(aCol,Array(Len(aHead)+1))
				nLin	:= Len(aCol)

				SX3->(DbSetOrder(1))
				SX3->(MsSeek(cGetAls))
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
	*/

Return(aCol)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ RG04LOk	    ³ Autor ³ Evandro Mugnol    ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida linhas do MsNewGetDados para obrigar preenchimento  ³±±
±±³          ³ dos campos obrigatorio.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RG04LOk()

	Local nGDLin := oGDItens:oBrowse:nAt
	Local nGDCol := 1
	Local lRet := .T.

	// Valida campos obrigatorios do MsNewGetDados
	For nGDCol:=1 To Len(oGDItens:aHeader)
		If X3OBRIGAT(oGDItens:aHeader[nGDCol,2]) .And. Empty(oGDItens:aCols[nGDLin,nGDCol])
			lRet := .F.
			Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(oGDItens:aHeader[nGDCol,2])),3,1)
			nGDCol:=Len(oGDItens:aHeader)
		EndIf
	Next nGDCol

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ RG04TOk      ³ Autor ³ Evandro Mugnol    ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida todos os campos do MsNewGetDados de todas as linhas ³±±
±±³          ³ para obrigar preenchimento dos campos obrigatorio.         ³±±
±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RG04TOk()

	Local nGDLin := 1
	Local nGDCol := 1
	Local lRet   := .T.

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


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ RG04COk      ³ Autor ³ Evandro Mugnol    ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida campos do MsNewGetDados para proibir duplicidades   ³±±
±±³          ³ e tratar alteração do codigo digitado que já foi utilizado ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RG04COk()

	Local nGDLin := oGDItens:oBrowse:nAt
	Local nGDCol := oGDItens:oBrowse:ColPos
	Local cGDCpo := &("M->"+oGDItens:aHeader[nGDCol,2])
	//Local cVCpos := "ZE_ITEM/ZE_PRODUTO"
	//Local nConta := 1
	Local lRet 	 := .T.

	// Trava alteração caso arquivo deletado
	If oGDItens:aCols[nGDLin,Len(oGDItens:aHeader)+1] .And. lRet
		lRet := .F.
		Help(" ",1,"HELP","PROIBIDO","Favor restaurar linha excluída para depois alterar.",3,1)
	Endif

	// Valida duplicidade de alguns campos do MsNewGetDados conforme definido acima na variavel cVCpos
	/*
	If AllTrim(oGDItens:aHeader[nGDCol,2]) $ cVCpos .And. lRet
		For nConta:=1 To Len(oGDItens:aCols)
			If nConta != nGDLin
				If AllTrim(cGDCpo) == AllTrim(oGDItens:aCols[nConta,nGDCol])
	lRet := .F.
	Help(" ",1,"EXISTE",,"Já existe um registro com esta informação!",3,1)
	nConta := Len(oGDItens:aCols)
				EndIf
			EndIf
		Next nConta
	EndIf
	*/

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ RG04Del      ³ Autor ³ Evandro Mugnol    ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida exclusão de linhas do MsNewGetDados para verificar  ³±±
±±³          ³ se já foi utilizada em alguma outra rotina                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RG04Del()

	Local lRet := .T.

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ fSalvaTudo   ³ Autor ³ Evandro Mugnol    ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Funcao responsavel pela gravacao das inclusoes e alteracoes³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSalvaTudo(nOpc,cAlias,aExbCpo)

	// Declara variaveis
	Local aArea	   := SZD->(GetArea())
	Local x        := 1
	Local nOrdSeek := 1
	Local aGrvCps  := {}
	Local aGrvSZE  := {}
	Local cCpoItem := "ZE_ITEM"
	Local cCndSeek := "FWxFilial('SZD')+SZD->ZD_NUMERO"
	Local k

	// Trata campos do enchoice
	For x:=1 To Len(aExbCpo)
		aAdd(aGrvCps,{aExbCpo[x] ,"M->"+aExbCpo[x] })
	Next x

	If nOpc == 3 .Or. nOpc == 4
		// Grava campos do cabeçalho
		DbSelectArea("SZD")
		If nOpc == 3
			RecLock("SZD",.T.)
		ElseIf nOpc == 4
			RecLock("SZD",.F.)
		Else
			RecLock("SZD",.F.)
		EndIf

		SZD->ZD_FILIAL := FWxFilial("SZD")
		For k:=1 To Len(aGrvCps)
			&(aGrvCps[k,1]) := &(aGrvCps[k,2])
		Next k
		MsUnlock()
	Endif

	// Executa rotina pra tratar gravação das variaveis acima e do MsNewGetDados
	fGravaGD(oGDItens,"SZE",aGrvSZE,nOpc,nOrdSeek,cCndSeek,cCpoItem,SZD->ZD_NUMERO)

	If nOpc == 3 .Or. nOpc == 4
		AtuVeic(SZD->ZD_NUMERO)
		AtuPeso(SZD->ZD_NUMERO)
	Endif

	RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ fGravaGD     ³ Autor ³ Evandro Mugnol    ³ Data ³ Jan/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Funcao responsavel pela gravacao das inclusoes e alteracoes³±±
±±³          ³ apontadas no MsNewGetDados / tratamento por objeto         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGravaGD(oObjct,cAlias,aCposAdd,nTpOper,nOrdSeek,cCndSeek,cCpoItm,cNumero)

	Local x := 1
	Local y := 1
	//Local k := 1
	Private cCodItem := StrZero(1,Len(CriaVar(cCpoItm)))

	DbSelectArea(cAlias)

	For x:=1 To Len(oObjct:aCols)
		If !oObjct:aCols[x,Len(oObjct:aHeader)+1]

			DbSelectArea(cAlias)
			DbSetOrder(nOrdSeek)

			If nTpOper == 3
				RecLock(cAlias,.T.)
			ElseIf MsSeek(&(cCndSeek)+oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==cCpoItm})])
				RecLock(cAlias,.F.)
			Else
				RecLock(cAlias,.T.)
			EndIf

			For y:=1 To Len(oObjct:aHeader)
				&(oObjct:aHeader[y,2]) := oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==AllTrim(oObjct:aHeader[y,2])})]
			Next y

			cCodItem 	   := Soma1(cCodItem)
			SZE->ZE_FILIAL := FWxFilial("SZE")
			SZE->ZE_NUMERO := cNumero
			SZE->ZE_SEGUM  := "KG"
			MsUnLock()
		Else
			DbSelectArea(cAlias)
			DbSetOrder(nOrdSeek)
			If nTpOper != 3
				If MsSeek(&(cCndSeek)+oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==cCpoItm})])
					RecLock(cAlias,.F.)
					dbDelete()
					MsUnLock()
				EndIf
			EndIf
		EndIf
	Next x

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ fExcluiTudo  ³ Autor ³ Evandro Mugnol    ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Funcao responsavel pela exclusão de todos os itens         ³±±
±±³          ³ apresentados na tela                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fExcluiTudo()

	SZE->(DbSetOrder(1))
	SZE->(MsSeek(FWxFilial("SZE") + SZD->ZD_NUMERO))
	While SZE->(!Eof()) .And. SZE->ZE_FILIAL + SZE->ZE_NUMERO == FWxFilial("SZE") + SZD->ZD_NUMERO
		If !Empty(SZE->ZE_NUMAM)
			MsgBox("Ordem de Recebimento já possui Ordem de Abate e não pode ser excluída!","Erro!!!","STOP")
			Return
		Endif
		SZE->(DbSkip())
	EndDo

	If Aviso("Confirma exclusão?","Todos os itens da ordem de recebimento serão excluídos.",{"Confirma","Cancela"}) == 1
		// Peso por categoria
		DbSelectArea("SZR")
		DbSetOrder(1)
		MsSeek(FWxFilial("SZR") + SZD->ZD_NUMERO)
		Do While !Eof() .And. SZR->ZR_FILIAL + SZR->ZR_RECEB == FWxFilial("SZR") + SZD->ZD_NUMERO
			RecLock("SZR",.F.)
			DbDelete()
			MsUnLock()
			DbSkip()
		Enddo

		DbSelectArea("SZS")
		DbSetOrder(1)
		MsSeek(FWxFilial("SZS") + SZD->ZD_NUMERO)
		Do While !Eof() .And. SZS->ZS_FILIAL + SZS->ZS_NUMERO == FWxFilial("SZS") + SZD->ZD_NUMERO
			RecLock("SZS",.F.)
			DbDelete()
			MsUnLock()
			DbSkip()
		Enddo

		// Deleta todos os itens do romaneio
		SZE->(DbSetOrder(1))
		If SZE->(MsSeek(FWxFilial('SZE')+SZD->ZD_NUMERO))
			While SZE->(!Eof()) .And. SZE->ZE_FILIAL+SZE->ZE_NUMERO == FWxFilial('SZE')+SZD->ZD_NUMERO
				RecLock("SZE",.F.)
				DbDelete()
				MsUnLock()
				SZE->(DbSkip())
			End
		Endif

		// Deleta cabeçalho do romaneio
		DbSelectArea("SZD")
		RecLock("SZD",.F.)
		DbDelete()
		MsUnLock()
	EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RG04VEI  ³ Autor ³ Evandro Mugnol        ³ Data ³ Out/2017 ³±±
±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca informações dos recebimentos de animais para transp. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RG04Vei()

	Private area 	 := GetArea()
	Private nVlPsFri := 0
	Private onde
	Private aCateg   := {}
	Private aVeic    := {}

	aCols   := {}
	aHeader := {}

	// Carrega Veiculos por Recebimento
	SZS->(DbSetOrder(1))
	SZS->(MsSeek(FWxFilial("SZD") + SZD->ZD_NUMERO))
	While !SZS->(Eof()) .And. SZS->ZS_FILIAL + SZS->ZS_NUMERO == FWxFilial("SZD") + SZD->ZD_NUMERO
		Aadd( aVeic, {  SZS->ZS_PLACA		,;
						SZS->ZS_MOTOR		,;
						SZS->ZS_VEIC		,;
						SZS->ZS_DESTPTR		,;
						SZS->ZS_QTANIM		,;
						SZS->ZS_DCHPREV		,;
						SZS->ZS_DASFPR		,;
						SZS->ZS_VAVE		,;
						SZS->ZS_PESOFRI		,;
						SZS->ZS_HORA		,;
						.F. 				})
		SZS->(DbSkip())
	Enddo

	If Empty(SZD->ZD_NUMERO)
		MsgBox("Nº Recebimento inválido! O número é obrigatório.")
		Return
	ElseIf Empty(SZD->ZD_TRANSP)
		msgbox("Código da transportadora inválido! O código é obrigatório.")
		Return
	Endif

	//--------------------------------------------------------------//
	//  Se a matriz estiver cheia, então estamos entrando neste     //
	//  programa pela segunda vez e já tem algo digitado. Neste     //
	//  caso precisamos recuperar.                                  //
	//--------------------------------------------------------------//
	//--------------------------------------------------------------//
	//  Prepara a leitura da tabela de recebimentos por veículo     //
	//--------------------------------------------------------------//
	SZS->(DbSetOrder(1))   // SZS - Cadastro de recebimentos de carcaças por transporte
	SZS->(MsSeek(FWxFilial("SZS") + SZD->ZD_NUMERO))
	If SZS->( Eof() )
		Aadd( aCols, { 	Space(7)	,;  // Nº Placa do veículo                          1
						Space(40)	,; 	// Nome do motorista                            2
						Space(2)	,;  // Código do tipo do veículo                    3
						Space(30)	,; 	// Nome do tipo de veículo                      4
						0			,;  // Número de animais neste veículo.             5
						0			,;  // Distância prevista para estrada sem asfalto  6
						0			,;  // Distância prevista para estrada com asfalto  7
						0.00		,;  // Valor do frete para este veículo		       	8
						0.00		,;  // Peso Frigorifico                             9
						Space(5)	,;  // Hora de recebimento                         10
						.F. 		})  // Informa se esta linha do vetor foi deletada 11

	Else
		While !SZS->(Eof()) .And. SZS->ZS_FILIAL + SZS->ZS_NUMERO == FWxFilial("SZS") + SZD->ZD_NUMERO
			// Busca descrição do tipo do veiculo
			//SX5->(MsSeek(FWxFilial("SX5")+ "Z3" + SZS->ZS_VEIC))
			//_nVeic := SX5->X5_DESCRI

			_nVeic := Alltrim(FWGetSX5("Z3", SZS->ZS_VEIC)[1][4])

			// Monta o vetor com os dados cadastrados
			Aadd( aCols, { 	SZS->ZS_PLACA	,;    // Nº Placa do veículo                            1
							SZS->ZS_MOTOR	,;    // Nome do motorista                              2
							SZS->ZS_VEIC	,;    // Código do tipo do veículo                      3
							_nveic			,;    // Nome do tipo de veículo (Char,18)              4
							SZS->ZS_QTANIM	,;    // Número de animais neste veículo.               5
							SZS->ZS_DCHPREV	,;    // Distância prevista para estrada sem asfalto    6
							SZS->ZS_DASFPR	,;    // Distância prevista para estrada com asfalto    7
							SZS->ZS_VAVE	,;    // Valor do frete para este veículo               8
							SZS->ZS_PESOFRI	,;    // Peso Frigorifico                               9
							SZS->ZS_HORA	,;    // Hora                                          10
							.F. 			})    // Informa se esta linha do vetor foi deletada   11

			SZS->(dbSkip())
		EndDo
	Endif

	// Monta o cabeçalho do grid e os formatos de display dos dados
	AADD(aHeader,{ "Placa",         "ZS_PLACA",	        "@!",   				07,  0,                             "", " ", "C",  "SZS"} )
	AADD(aHeader,{ "Motorista",     "ZS_MOTOR",  	    "@!",   				40,  0,                             "", " ", "C",  "SZS"} )
	AADD(aHeader,{ "Tipo Veic. ",   "ZS_VEIC",      	"@!",   				02,  0,  		                 	"U_TPVeic()", " ", "C",  "SZS"} )
	AADD(aHeader,{ "Descrição",     "ZS_DESTPTR",       "",   					18,  0,                             "", " ", "C",  "SZS"} )
	AADD(aHeader,{ "Qt.Animais",    "ZS_QTANIM",        "@E 999,999",   		04,  0,                             "", " ", "N",  "SZS"} )
	AADD(aHeader,{ "Dist.Chão(Km)", "ZS_DCHPREV",     	"@E 999,999.99",   		08,  2,		                       	"", " ", "N",  "SZS"} )
	AADD(aHeader,{ "Dist.Pavm(Km)", "ZS_DASFPR",    	"@E 999,999.99",   		08,  2, 			                "", " ", "N",  "SZS"} )
	AADD(aHeader,{ "Valor Frete",   "ZS_VAVE", 			"@E 999,999,999.99",   	12,  2,                             "", " ", "N",  "SZS"} )
	AADD(aHeader,{ "Peso Frigor",   "ZS_PESOFRI",		"@E 999,999,999.99",   	12,  2,                             "", " ", "N",  "SZS"} )
	AADD(aHeader,{ "Hora chegada",  "ZS_HORA",          "99:99",   				05,  0,                             "", " ", "C",  "SZS"} )

	DEFINE MSDIALOG dProdV TITLE "Recebimentos por Veículo" FROM 128,055 TO 400,900 PIXEL
	@ 004,003 To 114,422 MultiLine Modify
	DEFINE SBUTTON  FROM 119,335 TYPE 1 ACTION GravaV()		ENABLE OF dProdV PIXEL
	DEFINE SBUTTON  FROM 119,290 TYPE 2 ACTION Close(dProdV)	ENABLE OF dProdV PIXEL

	ACTIVATE MSDIALOG dProdV CENTER

	RestArea(area)

Return

//--------------------------------------------------//
// Função que Apanha a descrição do tipo do veiculo //
//--------------------------------------------------//
User Function TPVeic()

	Private lRet
	lRet := .F.

	SZH->(DbSetOrder(2))
	SZH->(MsSeek(FWxFilial("SZH") + SZD->ZD_TRANSP + M->ZS_VEIC))
	If SZH->(Found())
		//SX5->(MsSeek(FWxFilial("SX5") + "Z3" + M->ZS_VEIC))
		//aCols[n,4] := SX5->X5_DESCRI         // n é variável reservada de aCols e indica a posição atual do cursor
		aCols[n,4] := Alltrim(FWGetSX5("Z3", M->ZS_VEIC)[1][4])
		lRet := .T.
	Endif

Return(lRet)

//--------------------------------------------------//
// Função que efetua a gravação                     //
//--------------------------------------------------//
Static Function GravaV()
	Local i
	SZS->(DbSetOrder(1))
	SZS->(MsSeek(FWxFilial("SZS") + SZD->ZD_NUMERO))
	For i := 1 To Len(aCols)
		_cPlaca := GDFieldGet("ZS_PLACA",i)
		_cHora  := GDFieldGet("ZS_HORA",i)
		If SZS->(MsSeek(FWxFilial("SZS") + SZD->ZD_NUMERO + _cPlaca + _cHora))
			RecLock("SZS",.F.)
			SZS->ZS_DCHPREV := GDFieldGet("ZS_DCHPREV",i)
			SZS->ZS_DASFPR  := GDFieldGet("ZS_DASFPR",i)
			SZS->ZS_MOTOR   := GDFieldGet("ZS_MOTOR",i)
			SZS->ZS_VEIC    := GDFieldGet("ZS_VEIC",i)
			SZS->ZS_VAVE    := GDFieldGet("ZS_VAVE",i)
			SZS->ZS_DESTPTR := GDFieldGet("ZS_DESTPTR",i)
			SZS->ZS_PESOFRI := GDFieldGet("ZS_PESOFRI",i)
			MsUnlock()
		Endif
	Next

	Close(dProdV)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RG04PES  ³ Autor ³ Evandro Mugnol        ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca pesos por categoria no recebimento                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RG04Pes()

	Private area := GetArea()

	aCols   := {}
	aHeader := {}

	// Prepara a leitura da tabela de peso por categoria
	SZR->(DbSetOrder(1))
	SZR->(MsSeek(FWxFilial("SZD") + SZD->ZD_NUMERO))
	If SZR->( Eof() )
		Aadd( aCols, { 	Space(10)	,;  	// Categoria                                   1
						0			,;    	// Peso propriedade                            2
						Space(3) 	,;  	// Rastreado?                                  3
						0			,;    	// Peso Frigorifico                            4
						.F.			})  	// Informa se esta linha do vetor foi deletada 5
	Else
		While !SZR->(Eof()) .And. SZR->ZR_FILIAL + SZR->ZR_RECEB == FWxFilial("SZD") + SZD->ZD_NUMERO
			// Monta o vetor com os dados cadastrados
			_cCateg := GetAdvFval('SZ5','Z5_DESC',FWxfilial('SZ5')+SZR->ZR_CATEG,1)
			Aadd( aCols, {  _cCateg  								,;
							SZR->ZR_PESO   							,;
							IIF(SZR->ZR_RASTRO == 'S','Sim','Nao') 	,;
							SZR->ZR_PESOFRI							,;
							.F. 									})
			SZR->(dbSkip())
		EndDo
	Endif

	AADD(aHeader,{ "Categoria",	"ZR_DESC",         		      "",   10,  0,  ""     ,   " ",  "C",  "SZ5"  } )
	AADD(aHeader,{ "Peso Prop",	"ZR_PESO",   	"@E 9,999,999.99",  12,  2,  ""     ,   " ",  "N",  "SZR"  } )
	AADD(aHeader,{ "Rastreado",	"RASTRO",     	         	 "!@",  03,  0,  ""     ,   " ",  "C", 	     } )
	AADD(aHeader,{ "Peso Frig",	"ZR_PESOFRI",	"@E 9,999,999.99",  12,  2,  ""     ,   " ",  "N",  "SZR"  } )

	DEFINE MSDIALOG dProdP TITLE "Pesos por Categoria" FROM 128,055 TO 398,500 PIXEL
	@ 004,003 To 114,220 MultiLine Modify

	DEFINE SBUTTON  FROM 119,145 TYPE 2 ACTION Close(dProdP)	ENABLE OF dProdP PIXEL
	DEFINE SBUTTON  FROM 119,185 TYPE 1 ACTION GravaP()		ENABLE OF dProdP PIXEL

	ACTIVATE MSDIALOG dProdP CENTER

	RestArea(area)

Return

//--------------------------------------------------//
// Função que efetua a gravação                     //
//--------------------------------------------------//
Static Function GravaP()

	Local i
	Local _nPesProp := 0.0
	Local _nPesFrig := 0.0
	Local _nPercQ   := 0.0

	SZR->(DbSetOrder(1))
	SZR->(MsSeek(FWxfilial('SZR')+SZD->ZD_NUMERO))
	For i := 1 To Len(aCols)
		_cCateg  := GetAdvFval("SZ5","Z5_COD",FWxFilial("SZ5") + GDFieldGet("ZR_DESC",i),2)
		_cRastro := IIF(GDFieldGet("ZR_RASTRO",i)=="Sim","S","N")
		_nPesProp := GDFieldGet("ZR_PESO",i)
		_nPesFrig := GDFieldGet("ZR_PESOFRI",i)
		_nPercQ := (1-(iif(_nPesFrig > 0.0, _nPesFrig, 1.0)/iif(_nPesProp > 0.0, _nPesProp, 1.0)))*100
		If SZR->(MsSeek(FWxFilial("SZR") + SZD->ZD_NUMERO + _cCateg + _cRastro))
			RecLock("SZR",.F.)
			SZR->ZR_PESO    := _nPesProp
			SZR->ZR_PESOFRI := _nPesFrig
			MsUnlock()
			VerifQuebra(_nPercQ)
		Endif
	Next

	Close(dProdP)

Return

// Verifica Quebra de Pesagem de animais
Static Function VerifQuebra(_nPercQ)
	SZS->(DbSetOrder(1))   // SZS - Cadastro de recebimentos de carcaças por transporte
	SZS->(MsSeek(FWxFilial("SZS") + SZD->ZD_NUMERO))
	do case
		case SZS->ZS_DASFPR <= 100.0 .and. _nPercQ > 3.5
			FWAlertWarning("Quebra alta (" + alltrim(transform(_nPercQ,'@E 999.99')) + "%)! Confira as pesagens e reporte à Compra de Gado!", "ALERTA!")
		case SZS->ZS_DASFPR > 100.0 .and. SZS->ZS_DASFPR <= 200.0 .and. _nPercQ > 4.5
			FWAlertWarning("Quebra alta (" + alltrim(transform(_nPercQ,'@E 999.99')) + "%)! Confira as pesagens e reporte à Compra de Gado!", "ALERTA!")
		case SZS->ZS_DASFPR > 200.0 .and. SZS->ZS_DASFPR <= 300.0 .and. _nPercQ > 5.5
			FWAlertWarning("Quebra alta (" + alltrim(transform(_nPercQ,'@E 999.99')) + "%)! Confira as pesagens e reporte à Compra de Gado!", "ALERTA!")
		case SZS->ZS_DASFPR > 300.0 .and. SZS->ZS_DASFPR <= 400.0 .and. _nPercQ > 6.0
			FWAlertWarning("Quebra alta (" + alltrim(transform(_nPercQ,'@E 999.99')) + "%)! Confira as pesagens e reporte à Compra de Gado!", "ALERTA!")
		case SZS->ZS_DASFPR > 400.0 .and. SZS->ZS_DASFPR <= 500.0 .and. _nPercQ > 6.5
			FWAlertWarning("Quebra alta (" + alltrim(transform(_nPercQ,'@E 999.99')) + "%)! Confira as pesagens e reporte à Compra de Gado!", "ALERTA!")
		case SZS->ZS_DASFPR > 500.0 .and. _nPercQ > 7.0
			FWAlertWarning("Quebra alta (" + alltrim(transform(_nPercQ,'@E 999.99')) + "%)! Confira as pesagens e reporte à Compra de Gado!", "ALERTA!")
	endcase
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ATUVEIC  ³ Autor ³ Evandro Mugnol        ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Atualiza o lançamento de animais por veículo               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuVeic(_cNumOR)

	SZS->(DbSetOrder(1))
	SZE->(DbSetOrder(6))
	SZE->(DbGoTop())
	SZS->(DbGoTop())
	SZE->(MsSeek(FWxFilial("SZE") + _cNumOR))
	If SZS->(MsSeek(FWxFilial("SZS") + _cNumOR))
		While SZS->(!Eof()) .And. SZS->ZS_FILIAL + SZS->ZS_NUMERO == FWxFilial("SZS") + _cNumOR
			If SZE->(MsSeek(FWxFilial("SZE") + SZS->ZS_NUMERO + SZS->ZS_PLACA + SZS->ZS_HORA))
				SZS->(DbSkip())
				Loop
			Else
				RecLock("SZS",.F.)
				DbDelete()
				MsUnlock()
			Endif
			SZS->(DbSkip())
		EndDo
	Endif

	_nAnim  := 0
	_cChave := ""
	SZE->(DbSetOrder(6))
	SZE->(DbGotop())
	SZE->(MsSeek(FWxFilial("SZE") + _cNumOR))
	While SZE->(!Eof()) .And. SZE->ZE_FILIAL + SZE->ZE_NUMERO == FWxFilial("SZE") + _cNumOR
		SZS->(DbGoTop())
		SZS->(DbSetOrder(1))
		If SZS->(MsSeek(FWxFilial("SZS") + SZE->ZE_NUMERO + SZE->ZE_PLACA + SZE->ZE_HORA))
			_cChave := SZE->ZE_NUMERO + SZE->ZE_PLACA + SZE->ZE_HORA
			_nAnim  += SZE->ZE_QTD1UM
			RecLock("SZS",.F.)
			SZS->ZS_QTANIM := _nAnim
			MsUnlock()
		Else
			RecLock("SZS",.T.)
			SZS->ZS_FILIAL := FWxFilial("SZS")
			SZS->ZS_NUMERO := SZE->ZE_NUMERO
			SZS->ZS_QTANIM := SZE->ZE_QTD1UM
			SZS->ZS_PLACA  := SZE->ZE_PLACA
			SZS->ZS_HORA   := SZE->ZE_HORA
			MsUnlock()
		Endif

		SZE->(DbSkip())
		If _cChave <> SZE->ZE_NUMERO + SZE->ZE_PLACA + SZE->ZE_HORA .And. SZE->(!Eof())
			_nAnim := 0
		Endif
	EndDo

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ATUPESO  ³ Autor ³ Evandro Mugnol        ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Atualiza o peso                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuPeso(_cNumOR)

	SZR->(DbSetOrder(1))
	SZE->(DbSetOrder(7))
	SZR->(DbGotop())
	SZE->(DbGotop())
	If SZR->(MsSeek(FWxFilial("SZR") + _cNumOR))
		While SZR->(!Eof()) .And. SZR->ZR_FILIAL + SZR->ZR_RECEB == FWxFilial("SZR") + _cNumOR
			_cRastro := IIF(SZR->ZR_RASTRO == "N"," ","S")
			If SZE->(MsSeek(FWxFilial("SZE") + SZR->ZR_RECEB + SZR->ZR_CATEG + _cRastro))
				SZR->(DbSkip())
				Loop
			Else
				RecLock("SZR",.F.)
				DbDelete()
				MsUnlock()
			endif
			SZR->(DbSkip())
		EndDo
	Endif

	SZE->(DbGoTop())
	SZE->(MsSeek(FWxFilial("SZE") + _cNumOR))
	While SZE->(!Eof()) .And. SZE->ZE_FILIAL + SZE->ZE_NUMERO == FWxFilial("SZE") + _cNumOR
		_cRastro := IIF(Empty(SZE->ZE_RASTRO),"N","S")
		SZR->(DbGoTop())
		if !(SZR->(MsSeek(FWxFilial("SZR") + SZE->ZE_NUMERO + SZE->ZE_CATEG + _cRastro)))
			RecLock("SZR",.T.)
			SZR->ZR_FILIAL := FWxFilial("SZR")
			SZR->ZR_RECEB  := SZE->ZE_NUMERO
			SZR->ZR_CATEG  := SZE->ZE_CATEG
			SZR->ZR_RASTRO := _cRastro
			MsUnlock()
		Endif
		SZE->(DbSkip())
	EndDo

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RG04VIN  ³ Autor ³ Evandro Mugnol        ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Efetua vinculo da SC                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RG04Vin()
	Local i

	Private area     := GetArea()
	Private ALTERA
	Private lInverte := .F.
	Private cMark    := GetMark()
	Private oMark
	Private marc     := .F.
	//Private cArq     := CriaTrab( Nil, .F. )
	Private aStru 	 := {}
	Private aCampos  := {}

	DbSelectArea("SZ9")
	DbSetOrder(4)

	AADD(aStru,{"Z9_OK"      	,"C"	,2	,0	})
	AADD(aStru,{"Z9_NUMERO"  	,"C"  	,30 ,0 	})
	AADD(aStru,{"Z9_DATA"      	,"D"	,8	,0	})
	AADD(aStru,{"Z9_ITEM"   	,"C"	,3	,0 	})
	AADD(aStru,{"Z9_PRODUTO"   	,"C"	,15	,0	})
	AADD(aStru,{"Z9_QUANT"     	,"N"	,6	,0 	})
	AADD(aStru,{"Z9_PRECO"     	,"N"	,12	,5	})
	AADD(aStru,{"Z9_CATEG"     	,"C"	,3  ,0	})
	AADD(aStru,{"Z9_RACA "     	,"C"	,3 	,0	})
	AADD(aStru,{"Z9_FORNECE "  	,"C"	,6 	,0	})
	AADD(aStru,{"Z9_LOJA "     	,"C"	,2 	,0	})

	//DbCreate(cArq,aStru)
	//If Select("TMP") <> 0
	//	TMP->(DbCloseArea())
	//Endif
	//DbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	//IndRegua("TMP",cArq,"Z9_FORNECE+Z9_LOJA",,,"Selecionando Registros...")

	_aArqTrb :={}
	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {"Z9_FORNECE","Z9_LOJA"}, @_aArqTrb)

	SZ9->(MsSeek(FWxFilial("SZ9") + M->ZD_FORNECE + M->ZD_LOJA,.T.))
	While !SZ9->(Eof()) .And. SZ9->Z9_FILIAL + SZ9->Z9_FORNECE + SZ9->Z9_LOJA == FWxFilial("SZ9") + SZD->ZD_FORNECE + SZD->ZD_LOJA
		DbSelectArea('TMP')
		Reclock("TMP",.T.)
		For i:=1 To SZ9->(fCount())
			NAME := FieldName(i)

			DbSelectArea("TMP")
			POSICAO := FieldPos(NAME)
			DbSelectArea("SZ9")

			If POSICAO > 0
				TMP->(FieldPut(POSICAO, SZ9->(FieldGet(i))))
			EndIf
		Next
		MsUnlock()
		SZ9->(DbSkip())
	EndDo

	DbGotop()

	AADD(aCampos,{"Z9_OK"     	,     		  	"@X",           "OK"            })
	AADD(aCampos,{"Z9_NUMERO" 	,     		  	"@9",           "Numero"        })
	AADD(aCampos,{"Z9_DATA" 	,       		"@X",           "Data"          })
	AADD(aCampos,{"Z9_ITEM"		,        	  	"@9",           "Item"          })
	AADD(aCampos,{"Z9_PRODUTO" 	,    			"@X",           "Produto"       })
	AADD(aCampos,{"Z9_QUANT"   	,    			"@9",           "Quantidade"    })
	AADD(aCampos,{"Z9_PRECO"	,  	 "@E 999,999.99",    	  	"Preço"         })
	AADD(aCampos,{"Z9_CATEG"   	,  			   "999",           "Categoria"     })
	AADD(aCampos,{"Z9_RACA"   	,    			"@!",           "Raça"          })

	DbSelectArea("TMP")
	TMP->(DbGotop())

	DEFINE MSDIALOG oDlg2 TITLE "Vinculação Solicitação de Compra" From 9,0 To 400,1000 PIXEL
	oMark := MsSelect():New("TMP","Z9_OK","",aCampos,@lInverte,@cMark,{17,1,160,500},,,,,)
	oMark:bMark := {| | Disp()}

	TButton():New(170, 020, "Marcar Todos"   , oDlg2,{|| Seleciona()  },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 070, "Vincular"       , oDlg2,{|| Vincula() 	  },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 390, "Sair"           , oDlg2,{|| oDlg2:End()  },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg2 CENTERED

Return

/*====================================================================*
| Função:  		Disp                                                  |
| Descrição:	Marca individual                                      |
*====================================================================*/
Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("Z9_OK")
		TMP->Z9_OK := cMark
	Else
		TMP->Z9_OK := ""
	Endif
	MsUnlock() 

	oMark:oBrowse:Refresh()	

Return .T.

/*====================================================================*
| Função:  		Seleciona                                             |
| Descrição:	Marca todos                                           |
*====================================================================*/
Static Function Seleciona()

	TMP->(DbGoTop())   
	While TMP->(!Eof())
		RecLock("TMP",.F.)
		TMP->Z9_OK := cMark
		MsUnlock()
		TMP->(DbSkip())
	EndDo

	TMP->(DbGoTop())   

	oMark:oBrowse:Refresh()

Return .T.

/*====================================================================*
| Função:  		Vincula                                               |
| Descrição:	Executa a vinculação da SC                            |
*====================================================================*/
Static Function Vincula()

	Local _cNumam
	Local _cLote
	Local _cNumSC
	Local _cNome
	Local _cCompr

	SZA->(DbSetOrder(1))
	SZ4->(DbSetOrder(1))
	TMP->(DbGoTop())

	nItSel := 0
	While TMP->(!Eof())
		If !Empty(TMP->Z9_OK)
			nItSel++
		Endif
		TMP->(DbSkip())
	EndDo

	TMP->(DbGotop())
	nIt := 1

	While TMP->(!Eof())
		If !Empty(TMP->Z9_OK)
			marc := .T.

			_cNumam := alltrim(GetAdvFVal('SZE','ZE_NUMAM',FWxFilial('SZE') + SZD->ZD_NUMERO,1))
			_cLote := alltrim(GetAdvFVal('SZE','ZE_LOTE',FWxFilial('SZE') + SZD->ZD_NUMERO,1))
			_cCompr := alltrim(GetAdvFVal('SZA','ZA_COMPRA',FWxFilial('SZA') + TMP->Z9_NUMERO,1))
			if SZ4->(MsSeek(FWxFilial("SZ4") + _cNumam + _cLote))
				RecLock("SZ4",.F.)
				SZ4->Z4_COMPRAD := _cCompr
				MsUnlock()
			endif

			If SZA->(MsSeek(FWxFilial("SZA") + TMP->Z9_NUMERO))
				RecLock("SZA",.F.)
				SZA->ZA_ORDREC := SZD->ZD_NUMERO
				MsUnlock()
			Endif

			If nItSel == 1
				oGDItens:aCols[oGDItens:oBrowse:nAt, ascan(oGDItens:aHeader,{|x|alltrim(x[2])=="ZE_NUMSC"})]  := TMP->Z9_NUMERO		// Linha posicionada do cursor
				oGDItens:aCols[oGDItens:oBrowse:nAt, ascan(oGDItens:aHeader,{|x|alltrim(x[2])=="ZE_ITEMSC"})] := TMP->Z9_ITEM       	// Linha posicionada do cursor
				Exit
			Endif

			If nIt <= Len(oGDItens:aCols)
				oGDItens:aCols[nIt, ascan(oGDItens:aHeader,{|x|alltrim(x[2])=="ZE_NUMSC"})]  := TMP->Z9_NUMERO
				oGDItens:aCols[nIt, ascan(oGDItens:aHeader,{|x|alltrim(x[2])=="ZE_ITEMSC"})] := TMP->Z9_ITEM
			Endif

			nIt++							
		Endif
		TMP->(DbSkip())
	EndDo

	If marc
		MsgBox("Solicitação de Compra Vinculada","CONFIRMAÇÃO","INFO")  
	Else
		MsgBox("Não Houve Solicitação Selecionada!","OPERAÇÃO NULA","INFO")  
	Endif

	oDlg:End()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RG04COP  ³ Autor ³ Evandro Mugnol        ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Efetua cópia do 'Local' para todos os itens                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RG04Cop()
	Local _i
	Private lOk 	 := .F.
	Private aButtons := {}
	Private cMan 	 := "  "

	DEFINE MSDIALOG oDlg2 TITLE "Local" FROM 000,000 TO 100,400 OF oMainWnd PIXEL

	@ 15,10 SAY "Local" Object oManc
	@ 15,50 GET cMan PICTURE "@!" Object oManc F3 "NNR"

	ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||lOk:=.T., oDlg2:End()},{||oDlg2:End()}, , aButtons)

	If lOk
		For _i := 1 To Len(oGDItens:aCols)
			oGDItens:aCols[_i,6] := cMan		// Mangueira
		Next
	Endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RG04COP  ³ Autor ³ Evandro Mugnol        ³ Data ³ Out/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Copia de item que irá adicionar ao final um novo item      ³±±
±±³          ³ a partir do item que se está posicionado.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RG04Ite()

	aCopia := Aclone(oGDItens:aCols[oGDItens:oBrowse:nAt])

	AAdd(oGDItens:aCols, aCopia)

	oGDItens:aCols[oGDItens:oBrowse:nAt, ascan(oGDItens:aHeader,{|x|alltrim(x[2])=="ZE_ITEM"})] := StrZero(Len(oGDItens:aCols),3,0)  // Atualiza Item

	oGDItens:Refresh()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RG04VIN  ³ Autor ³ Flávio Bohrer Flôres ³ Data ³ Abril/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera o QrCode do Numero de recebimento  P/PLanilhas        ³±±
±±³Descrição ³ da Qualidade - Processo BRC                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RG04VQr()
Local oDLG := Nil
Local cCodigo := M->ZD_NUMERO
Private oQrCode

//Cria a Dialog
DEFINE MSDIALOG oDlg TITLE "Número do Recebimento de Gado" FROM 0,0 TO 260,460 PIXEL

//Cria o objeto FwQrCode
oQrCode := FwQrCode():New({25,25,200,200},oDlg,cCodigo)

//Get com o codigo exibido
@25,150 GET oGet VAR cCodigo OF oDlg SIZE 60,10 PIXEL

//Botao Gerar não foi utilizado então ocultamos
//@45,150 BUTTON "Gerar" SIZE 30,20 PIXEL OF oDlg ACTION MsgRun("Gerando QRCode","Aguarde",{|| MyRefresh(cCodigo)}) PIXEL

//Exibe a Dialog em Video
ACTIVATE MSDIALOG oDlg CENTERED

Return


Static Function MyRefresh(cNewCod)

	oQrCode:SetCodeBar(cNewCod)
	oQrCode:Refresh()

Return

Static Function CalcRepl(nNumero)
	Local _cQuery := ""
	_cQuery += " SELECT SUM(ZE_QTD1UM) AS SOMA"
	_cQuery += " FROM " + retSqlTab("SZE")
	_cQuery += " WHERE " + retSqlFil("SZE")
	_cQuery += " AND " + retSqlDel("SZE")
	_cQuery += " AND ZE_NUMERO = '" + nNumero + "'"	
	_cQuery += " AND (ZE_LOCAL IN ('AE', 'OC', 'OV'))"
	_cQuery := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"
	QRY->(dbGoTop())
Return iif(empty(QRY->SOMA), 0, QRY->SOMA)
