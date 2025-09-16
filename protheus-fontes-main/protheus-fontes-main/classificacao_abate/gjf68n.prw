#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "VKEY.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWBROWSE.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} GJF68N
@Type			: Função
@Sample			: U_GJF68N()
@Description	: Função de previsão e gerenciamento de produção da entrada da desossa New
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro
@Since			: Set/2022
@version		: Protheus 12
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function GJF68N(nOpc)

	Local cCondicao := ""						// Condição para a filtragem
	Local aCores := { { "( SZ2->Z2_STATUS == 'A' .And. SZ2->Z2_FILIAL = '" + FWxFilial('SZ2')+"' )" , "BR_VERDE"    },; 	// "Aberta"
					  { "( SZ2->Z2_STATUS == 'E' .And. SZ2->Z2_FILIAL = '" + FWxFilial('SZ2')+"' )" , "BR_VERMELHO" },; 	// "Encerrada"
					  { "( SZ2->Z2_STATUS == 'I' .And. SZ2->Z2_FILIAL = '" + FWxFilial('SZ2')+"' )" , "BR_AMARELO"  },; 	// "Iniciada"
					  { "( SZ2->Z2_STATUS == 'B' .And. SZ2->Z2_FILIAL = '" + FWxFilial('SZ2')+"' )" , "BR_AZUL"     } } 	// "Bloqueada"

	Private cAlias    := "SZ2"
	Private aRotina   := MenuDef()
	Private cCadastro := "Previsão de Gerenciamento de Producao - Desossa New"
	Private cPerg     := "GJF68"
	Private _cOPCorte := ""
	Private _aClasEsp := {}

	SZ2->(DbSetOrder(1))

	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	cCondicao := " (Z2_DATA BETWEEN '" + Dtos(mv_par01) + "' AND '" + Dtos(mv_par02) + "') " + ;
				 " AND (Z2_DTPROD BETWEEN '" + Dtos(mv_par03) + "' AND '" + Dtos(mv_par04) + "') " + ;
				 " AND Z2_FILIAL = '" + FWxFilial('SZ2') + "'"

	If mv_par05 <> 4
		cCondicao += " AND Z2_CORORI = '" + IIf(mv_par05 == 1,"T", IIf(mv_par05 == 2,"D","C")) + "'"
	EndIf

	If mv_par06 <> 4
		cCondicao += " AND Z2_PRIORID IN(" + IIf(mv_par06 == 1,"'R','P','A'", IIf(mv_par06 == 2,"'D'","C")) + ")"
	EndIf

	If !Empty(mv_par07)
		cCondicao += " AND Z2_NUMAM = '" + mv_par07 + "'"
	EndIf

	mBrowse(6,1,22,75,cAlias,,,,,2,aCores,,,,,,,,cCondicao)

Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao dos itens do menu
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {	{ OemToAnsi("Pesquisar")			,"AxPesqui"	  		, 0 , 1, ,.F.} ,;
						{ OemToAnsi("Visualizar")			,"U_Gjf68n_i" 		, 0 , 2		 } ,;
						{ OemToAnsi("Incluir")				,"U_Gjf68n_i"		, 0 , 3		 } ,;
						{ OemToAnsi("Encerrar")				,"U_Gjf68n_i"		, 0 , 4		 } ,;
						{ OemToAnsi("Excluir")				,"U_Gjf68n_i"		, 0 , 5		 } ,;
						{ OemToAnsi("Vis. Certificado")		,"U_VisCert"		, 0 , 6		 } ,;
						{ OemToAnsi("Lib/Bloq Automatica")	,"U_Gjf68aut"		, 0 , 6		 } ,;
						{ OemToAnsi("Liberar")				,"U_Gjf68nlb"		, 0 , 6		 } ,;
						{ OemToAnsi("Bloquear")				,"U_Gjf68nbq"		, 0 , 6		 } ,;
						{ OemToAnsi("Bloqueios Online")		,"U_Gjf68nvb"		, 0 , 6		 } ,;
						{ OemToAnsi("Legenda")    			,"U_BLegenda"		, 0 , 6, ,.F.}  }

					//	{ OemToAnsi("Ger. Lote")			,"U_Gjf68nlt"		, 0 , 6		 } ,;
					//	{ OemToAnsi("Lib. Carcaça")			,"U_Gjf68nlc"		, 0 , 6		 } ,;

Return(aRotina)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} BLegenda
Funcao que exibe a legenda referente aos status
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function BLegenda()

	BrwLegenda("Legenda","Previsão de Produção",{;
												{ "BR_VERDE" 	, "Aberta" 		},;
												{ "BR_VERMELHO" , "Encerrada" 	},;
												{ "BR_AMARELO" 	, "Iniciada" 	},;
												{ "BR_AZUL" 	, "Bloqueada"  	}})

Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} Gjf68n_i
Função que exibe na tela enchoice e a getdados
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
@param		ExpC1 = Alias do Arquivo
			ExpN1 = Numero do Registro
			ExpN2 = Numero da opcao selecionada
/*/
//------------------------------------------------------------------------------
User Function Gjf68n_i(cAlias,nReg,nOpc)

	// Declaração das variaveis
	Local nSaveSx8Len := GetSx8Len()

	Private oEnch
	Private oDlg
	Private aGets     := {}
	Private aTela     := {}
	Private aButtons  := {}
	Private nOpcao	  := 0
	Private bOk       := { || IIf(Obrigatorio(aGets,aTela) , (nOpcao:=1,oDlg:End()) , nOpcao := 0) }
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

	cAlias := "SZ2"

	// Maximizacao da tela em relação a area de trabalho
	aSizeAut := MsAdvSize()

	aAdd(aObjects,{100,53,.T.,.T.})
	aAdd(aObjects,{100,47,.T.,.T.})

	aInfo   := {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
	aPosObj := MsObjSize(aInfo,aObjects, .T.)

	//Ajusta para ter mais um array com divisoes da dimenssao da tela
	aAdd(aPosObj,{aPosObj[1,1],(aPosObj[1,4]*0.7)+3,aPosObj[1,4]*0.29,aPosObj[1,3]*0.8}) //Dimensao da MsMget em relacao ao Dialog  (LinhaI,ColunaI,LinhaF,ColunaF)
	aPosObj[1,3]:=aPosObj[1,3]*1.65
	aPosObj[1,4]:=aPosObj[1,4]*0.7

	// VerIfica o tipo de chamada e trata a situação
	cNaoExbCps := ""

	Do Case
		Case nOpc == 2	// Visualização
			nOpEnch:= 2
			aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
		Case nOpc == 3	// Inclusão
			nOpEnch:= 3
			aExbCpo:= fInitVarX3(cAlias,.T.,cNaoExbCps)
		Case nOpc == 4 .Or. nOpc == 5	// Encerramento ou Exclusão
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

	// Botão Calcular
	If nOpc == 3
		@ aPosObj[3,3]*1.3, aPosObj[3,4]*3.7 BUTTON "Calcular" SIZE 47,20 ACTION U_G68QTDN(M->Z2_RESERV)  OBJECT oBtn1
	EndIf

	// Montagem das "RADIO"
	fRadio(nOpc,oDlg,nReg)

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

	Do Case
		Case nOpc == 3 .And. nOpcao == 1		// Se for inclusao e foi confirmado
			fSalvaTudo(nOpc,cAlias,aExbCpo)
			// Atualiza ou retorna sequencial
			While GetSx8Len() > nSaveSx8Len
				If nOpcao == 1
					ConfirmSX8()
				Else
					RollBackSX8()
				EndIf
			EndDo
		Case (nOpc == 4 .Or. nOpc == 5) .And. nOpcao == 1		// Se for encerramento ou exclusão e foi confirmado
			fExcluiTudo(nOpc)
		OtherWise
			While GetSx8Len() > nSaveSx8Len
				// Retorna sequencial no cancelamento
				RollBackSX8()
			End
	EndCase
Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} fInitVarX3
Função que carrega as variáveis em memória
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function fInitVarX3(cAlias,lInitVarX3,cNaoExbCps)

	Local aExibLst := {}
	Local i

	_cAlias  := cAlias 		// SZ2
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')))
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
		Endif
	Next i

Return(aExibLst)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} fRadio
Função que monta o panel dos RADIO
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function fRadio(nOpc,oDefTela,nReg)

	Public dDtAbat := Ctod("")

	// RAÇA
	Public oRadioRC
	Public nRadioRC := 12

	// RASTREABILIDADE
	Public oRadioRS
	Public nRadioRS := 8

	// CORTE ORIGEM
	Public oRadioCT
	Public nRadioCT := 4

	// CLASS DESTINO
	Public oRadioTF
	Public nRadioTF := 4

	If nOpc <> 3
		DO CASE
			CASE Substr(SZ2->Z2_SELRACA, 01, 1) == "S"
				nRadioRC := 1
			CASE Substr(SZ2->Z2_SELRACA, 02, 1) == "S"
				nRadioRC := 2
			CASE Substr(SZ2->Z2_SELRACA, 03, 1) == "S"
				nRadioRC := 3
			CASE Substr(SZ2->Z2_SELRACA, 04, 1) == "S"
				nRadioRC := 4
			CASE Substr(SZ2->Z2_SELRACA, 05, 1) == "S"
				nRadioRC := 5
			CASE Substr(SZ2->Z2_SELRACA, 06, 1) == "S"
				nRadioRC := 6
			CASE Substr(SZ2->Z2_SELRACA, 07, 1) == "S"
				nRadioRC := 7
			CASE Substr(SZ2->Z2_SELRACA, 08, 1) == "S"
				nRadioRC := 8
			CASE Substr(SZ2->Z2_SELRACA, 09, 1) == "S"
				nRadioRC := 9
			CASE Substr(SZ2->Z2_SELRACA, 10, 1) == "S"
				nRadioRC := 10
			CASE Substr(SZ2->Z2_SELRACA, 11, 1) == "S"
				nRadioRC := 11
		ENDCASE

		DO CASE
			CASE Substr(SZ2->Z2_SELRAST, 01, 1) == "S"
				nRadioRS := 1
			CASE Substr(SZ2->Z2_SELRAST, 02, 1) == "S"
				nRadioRS := 2
			CASE Substr(SZ2->Z2_SELRAST, 03, 1) == "S"
				nRadioRS := 3
			CASE Substr(SZ2->Z2_SELRAST, 04, 1) == "S"
				nRadioRS := 4
			CASE Substr(SZ2->Z2_SELRAST, 05, 1) == "S"
				nRadioRS := 5
			CASE Substr(SZ2->Z2_SELRAST, 06, 1) == "S"
				nRadioRS := 6
			CASE Substr(SZ2->Z2_SELRAST, 07, 1) == "S"
				nRadioRS := 7
		ENDCASE

		DO CASE
			CASE Substr(SZ2->Z2_SELCORT, 01, 1) == "S"
				nRadioCT := 1
			CASE Substr(SZ2->Z2_SELCORT, 02, 1) == "S"
				nRadioCT := 2
			CASE Substr(SZ2->Z2_SELCORT, 03, 1) == "S"
				nRadioCT := 3
		ENDCASE

		DO CASE
			CASE Substr(SZ2->Z2_SELTFCS, 01, 1) == "S"
				nRadioTF := 1
			CASE Substr(SZ2->Z2_SELTFCS, 02, 1) == "S"
				nRadioTF := 2
			CASE Substr(SZ2->Z2_SELTFCS, 02, 1) == "S"
				nRadioTF := 3
		ENDCASE
	EndIf

	@ aPosObj[3,1], aPosObj[3,2] MSPANEL oPanel SIZE aPosObj[3,3], aPosObj[3,4]*1.5 Of oDlg
	@ 000,000 SCROLLBOX oScroll SIZE 009,009 Pixel Of oPanel
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT

	@ 008, 005 Say Replicate("=",58) Size 163,010 COLOR CLR_HBLUE Of oScroll Pixel
	@ 135, 005 Say Replicate("=",14) Size 163,010 COLOR CLR_HRED  Of oScroll Pixel

	@ 003, 005 SAY OemToAnsi("RAÇA") 				SIZE 050,010 COLOR CLR_HBLUE Of oScroll Pixel
	@ 015, 005 RADIO oRadioRC VAR nRadioRC ITEMS "ANGUS","ANGUS NJ","HEREFORD","HEREFORD NJ","NOVILHO","8 DENTES","BLACK","TOURUNO","TOURO","MAGRO","CZ LEITE"  	ON CHANGE { || SelecRac( nRadioRC ) } SIZE 050, 009 When IIf(nOpc==3, .T., .F.) OF oScroll Pixel

	@ 003, 060 SAY OemToAnsi("RASTREABILIDADE") 	SIZE 050,010 COLOR CLR_HBLUE Of oScroll Pixel
	@ 015, 075 RADIO oRadioRS VAR nRadioRS ITEMS "BR","CN","HK","LG","NE","RT","USA"  																				ON CHANGE { || SelecRas( nRadioRS ) } SIZE 050, 009 When IIf(nOpc==3, .T., .F.) OF oScroll Pixel

	@ 003, 125 Say OemToAnsi("CORTE ORIGEM")		SIZE 050,010 COLOR CLR_HBLUE Of oScroll Pixel
	@ 015, 125 RADIO oRadioCT VAR nRadioCT ITEMS "Traseiro","Dianteiro","Costela" 																					ON CHANGE { || SelecCor( nRadioCT ) } SIZE 050, 009 When IIf(nOpc==3, .T., .F.) OF oScroll Pixel

	@ 130, 005 SAY OemToAnsi("CLASS. DESTINO") 		SIZE 050,010 COLOR CLR_HRED  Of oScroll Pixel
	@ 142, 005 RADIO oRadioTF VAR nRadioTF ITEMS "TF","TS","Conserva"																								  	ON CHANGE { || SelecTFC( nRadioTF ) } SIZE 050, 009 When IIf(nOpc==3, .T., .F.) OF oScroll Pixel

Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} SelecRac
Função responsavel por atualizar a prioridade na seleção da Raça
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function SelecRac(nRadioRC)

	cCampo := "Z2_PRIORID"
	M->Z2_PRIORID := "A"

	DO CASE
		CASE nRadioRC == 1
			M->Z2_PROGRAM := "006"		// ANGUS
		CASE nRadioRC == 2
			M->Z2_PROGRAM := "021"		// ANGUS NJ
		CASE nRadioRC == 3
			M->Z2_PROGRAM := "002"		// HEREFORD
		CASE nRadioRC == 4
			M->Z2_PROGRAM := "022"		// HEREFORD NJ
		CASE nRadioRC == 5
			M->Z2_PROGRAM := "020"		// NOVILHO
		CASE nRadioRC == 6
			M->Z2_PROGRAM := "013"		// 8 DENTES
		CASE nRadioRC == 7
			M->Z2_PROGRAM := "014"		// BLACK
		CASE nRadioRC == 8
			M->Z2_PROGRAM := "008"		// TOURUNO
		CASE nRadioRC == 9
			M->Z2_PROGRAM := "019"		// TOURO
		CASE nRadioRC == 10
			M->Z2_PROGRAM := "001"		// MAGRO
		CASE nRadioRC == 11
			M->Z2_PROGRAM := "005"		// CZ LEITE
		OTHERWISE
			M->Z2_PROGRAM := ""
	ENDCASE

	If nRadioRC == 7
		M->Z2_BLACK := "S"
	Else
		M->Z2_BLACK := ""
	EndIf

	oEnch:Refresh()

	// Chama gatilho caso exista
    If ExistTrigger(cCampo)
        RunTrigger( ;
                    1,;           // nTipo (1=Enchoice; 2=GetDados; 3=F3)
                    Nil,;         // Linha atual da Grid quando for tipo 2
                    Nil,;         // Não utilizado
                    ,;            // Objeto quando for tipo 1
                    cCampo;       // Campo que dispara o gatilho
                    )
    EndIf

Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} SelecRas
Função responsavel por atualizar a prioridade na seleção da Rastreabilidade
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function SelecRas(nRadioRS)

	DO CASE
		CASE nRadioRS == 1
			M->Z2_CLASSIF := "BR"
		CASE nRadioRS == 2
			M->Z2_CLASSIF := "CN"
		CASE nRadioRS == 3
			M->Z2_CLASSIF := "HK"
		CASE nRadioRS == 4
			M->Z2_CLASSIF := "LG"
		CASE nRadioRS == 5
			M->Z2_CLASSIF := "NE"
		CASE nRadioRS == 6
			M->Z2_CLASSIF := "RT"
		CASE nRadioRS == 7
			M->Z2_CLASSIF := "USA"
		OTHERWISE
			M->Z2_CLASSIF := ""
	ENDCASE

	oEnch:Refresh()

Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} SelecCor
Função responsavel por atualizar o corte de origem na seleção do Corte
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function SelecCor(nRadioCT)

	lContinua := .T.
	cCampo    := "Z2_CORORI"

	// Busca as validações do campo
	cVldUsr := GetSX3Cache(cCampo, "X3_VLDUSER")

	// Altera o ReadVar da Memória
	__ReadVar := "M->" + cCampo
	Do CASE
		CASE nRadioCT == 1
			M->Z2_CORORI := "T"
		CASE nRadioCT == 2
			M->Z2_CORORI := "D"
		CASE nRadioCT == 3
			M->Z2_CORORI := "C"
	ENDCASE

	// Chama a validação de usuário
	If !Empty(cVldUsr)
		lContinua := &(cVldUsr)
	EndIf

	If lContinua
		oEnch:Refresh()
	EndIf

Return Nil


//-----------------------------------------------------------------------------
/*/{Protheus.doc} SelecTFC
Função responsavel por atualizar a TF ou Conserva na seleção da Class. Destino
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function SelecTFC(nRadioTF)

	Do CASE
		CASE nRadioTF == 1
			M->Z2_PRIORID := "A"
			M->Z2_PROGRAM := ""
			M->Z2_CLASSIF := ""
			M->Z2_OBS     := "TF"
			M->Z2_QPPECA  := 0
			M->Z2_QPPESO  := 0
		CASE nRadioTF == 2
			M->Z2_PRIORID := "A"
			M->Z2_PROGRAM := ""
			M->Z2_CLASSIF := ""
			M->Z2_OBS     := "Salga"
			M->Z2_QPPECA  := 0
			M->Z2_QPPESO  := 0
		CASE nRadioTF == 3
			M->Z2_PRIORID := "A"
			M->Z2_PROGRAM := ""
			M->Z2_CLASSIF := ""
			M->Z2_OBS     := "Conserva"
			M->Z2_QPPECA  := 0
			M->Z2_QPPESO  := 0
	ENDCASE

	oEnch:Refresh()

Return Nil


//-----------------------------------------------------------------------------
/*/{Protheus.doc} fSalvaTudo
Função responsavel pela gravacao das inclusoes e alteracoes
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function fSalvaTudo(nOpc,cAlias,aExbCpo)

	// Declara variaveis
	Local aArea	  := SZ2->(GetArea())
	Local aGrvCps := {}
	Local nW
	Local nX

	// RAÇA
	Local cConteudRC := "NNNNNNNNNNN"

	// RASTREABILIDADE
	Local cConteudRS := "NNNNNNN"

	// CORTE ORIGEM
	Local cConteudCT := "NNN"

	// DESTINO
	Local cConteudTF := "NNN"

	// Trata campos do enchoice
	For nW:=1 To Len(aExbCpo)
		aAdd(aGrvCps,{aExbCpo[nW] ,"M->"+aExbCpo[nW] })
	Next nW

	// RAÇA
	DO CASE
		CASE nRadioRC == 1
			cConteudRC := "SNNNNNNNNNN"
		CASE nRadioRC == 2
			cConteudRC := "NSNNNNNNNNN"
		CASE nRadioRC == 3
			cConteudRC := "NNSNNNNNNNN"
		CASE nRadioRC == 4
			cConteudRC := "NNNSNNNNNNN"
		CASE nRadioRC == 5
			cConteudRC := "NNNNSNNNNNN"
		CASE nRadioRC == 6
			cConteudRC := "NNNNNSNNNNN"
		CASE nRadioRC == 7
			cConteudRC := "NNNNNNSNNNN"
		CASE nRadioRC == 8
			cConteudRC := "NNNNNNNSNNN"
		CASE nRadioRC == 9
			cConteudRC := "NNNNNNNNSNN"
		CASE nRadioRC == 10
			cConteudRC := "NNNNNNNNNSN"
		CASE nRadioRC == 11
			cConteudRC := "NNNNNNNNNNS"
	ENDCASE

	// RASTREABILIDADE
	DO CASE
		CASE nRadioRS == 1
			cConteudRS := "SNNNNNN"
		CASE nRadioRS == 2
			cConteudRS := "NSNNNNN"
		CASE nRadioRS == 3
			cConteudRS := "NNSNNNN"
		CASE nRadioRS == 4
			cConteudRS := "NNNSNNN"
		CASE nRadioRS == 5
			cConteudRS := "NNNNSNN"
		CASE nRadioRS == 6
			cConteudRS := "NNNNNSN"
		CASE nRadioRS == 1
			cConteudRS := "NNNNNNS"
	ENDCASE

	// CORTE ORIGEM 
	DO CASE
		CASE nRadioCT == 1
			cConteudCT := "SNN"
		CASE nRadioCT == 2
			cConteudCT := "NSN"
		CASE nRadioCT == 3
			cConteudCT := "NNS"
	ENDCASE

	// CLASS. DESTINO 
	DO CASE
		CASE nRadioTF == 1
			cConteudTF := "SNN"
		CASE nRadioTF == 2
			cConteudTF := "NSN"
		CASE nRadioTF == 3
			cConteudTF := "NNS"
	ENDCASE

	If nOpc == 3
	
		If M->Z2_QPPECA > 0
			Processa({||GravaZAJ()},"GERAÇÃO DE PREVISAO DE PRODUÇÃO","Gravando registros na tabela ZAJ..." )     
			// M->Z2_PROGRAM
			// Grava campos do cabeçalho			
			If nOpc == 3
				DbSelectArea("SZ2")
				RecLock("SZ2",.T.)
				SZ2->Z2_FILIAL := FWxFilial("SZ2")
				For nX:=1 TO Len(aGrvCps)
					&(aGrvCps[nX,1]) := &(aGrvCps[nX,2])
				Next nX
				SZ2->Z2_SELRACA := cConteudRC
				SZ2->Z2_SELRAST := cConteudRS
				SZ2->Z2_SELCORT := cConteudCT
				SZ2->Z2_SELTFCS := cConteudTF
				SZ2->Z2_STATUS  := "B"		// Gera Bloqueado na inclusão por solicitação da Valeska em 26/09/2023
				if M->Z2_OBS = 'TF'
					SZ2->Z2_PRGDESC := 'TF'
				elseif M->Z2_OBS = 'TS'
					SZ2->Z2_PRGDESC := 'Salga'
				elseif M->Z2_OBS = 'Conserva'
					SZ2->Z2_PRGDESC := 'Conserva'
				else
					SZ2->Z2_PRGDESC := GetAdvFVal('SZ6', 'Z6_DESC', FWxfilial("SZ6") + M->Z2_PROGRAM, 1, Space(TamSx3("Z6_DESC")[1]), .T.)
				endif
				MsUnlock()
			EndIf
		Else
			MsgAlert("Não será gerado Previsão de Produção, pois Qtde Peças não foi calculado. Refaça o processo!", "Atenção")
		EndIf

	EndIf

	RestArea(aArea)

Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} fExcluiTudo
Função responsavel pela exclusão do registro apresentado em tela
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function fExcluiTudo(nOpc)

	cNum := SZ2->Z2_NUM

	If nOpc == 4	// Encerrar
		_cOper := "E"
	Else			// Excluir
		_cOper := "X"
	EndIf

	If SZ2->Z2_STATUS $ "B/I" .And. _cOper == "X"
		Alert('Previsão de Produção não pode ser excluída. Encerre-a primeiramente!')
		Return
	ElseIf SZ2->Z2_STATUS == "E" .And. _cOper == "E"
		Alert('Previsão de Produção já encerrada!')
		Return		
	EndIf

	If Aviso("Confirma exclusão?","Toda informação será excluída.",{"Confirma","Cancela"},2) == 1

		DbSelectarea("ZAJ")
		ZAJ->(dbSetOrder(1))
		ZAJ->(DbGoTop())
		If ZAJ->(MsSeek(FWxFilial("ZAJ") + SZ2->Z2_NUMAM))		// Laço para cÁlculo mediante os parâmetros   
			While ZAJ->(!Eof()) .And. ZAJ->ZAJ_FILIAL + ZAJ->ZAJ_NUMAM == FWxFilial("ZAJ") + SZ2->Z2_NUMAM
				If SZ2->Z2_NUM <> ZAJ->ZAJ_PREDES
					ZAJ->(DbSkip())
					Loop
				EndIf

				If Empty(ZAJ->ZAJ_DATAS) .And. Empty(ZAJ->ZAJ_HORAS) 
					RecLock("ZAJ",.F.)
					ZAJ->ZAJ_PREDES := ""
					MsUnlock()
				EndIf

				ZAJ->(DbSkip())
			EndDo
		EndIf

		// Executa procedimento de exclusão ou encerramento do registro
		DbSelectArea("SZ2")
		RecLock("SZ2",.F.)
		If _cOper == "X"
			DbDelete()
		Else
			SZ2->Z2_STATUS := "E"
		EndIf
		MsUnlock()

		SZ2->(dbsetorder(2))
		SZ2->(Msseek(FWxFilial("SZ2") + cNum,.T.))

		If _cOper == "X"
			MsgInfo("Previsão de Produção excluída!", "Info")
		Else
			MsgInfo("Previsão de Produção encerrada!", "Info")
		EndIf
	
	EndIf

Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} G68QTDN
Função para sugerir e reservar a quantidade de peças a serem desossadas de 
acordo com os parametros
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function G68QTDN(Oper)

	If (nRadioRC == 1 .Or. nRadioRC == 2 .Or. nRadioRC == 3 .Or. nRadioRC == 4 .Or. nRadioRC == 5 .Or. nRadioRC == 6 .Or. nRadioRC == 7 .Or. nRadioRC == 8 .Or. nRadioRC == 9 .Or. nRadioRC == 10 .Or. nRadioRC == 11) .And. (nRadioTF == 1 .Or. nRadioTF == 2 .Or. nRadioTF == 3)
		cMensagem := "Não é permitido Calcular 'Quant Peças' e 'Quant Peso' quando informado RAÇA e CLASS. DESTINO ao mesmo tempo."
		cSolucao  := "Será necessário informar novamente os dados e recalcular."

		Help(NIL, NIL, "NAOPERMIT", NIL, cMensagem, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})

		// Elimina da memória a instância do objeto informado como parâmetro
		FreeObj(oRadioRC)
		FreeObj(oRadioRS)
		FreeObj(oRadioCT)
		FreeObj(oRadioTF)

		// Montagem das "RADIO"
		fRadio(3,oDlg,1)

		M->Z2_OBS := ""

		oEnch:Refresh()
	Else
		MsgRun("Aguarde... Realizando contagem de registros...",,{||  U_G68AP(Oper) })
	Endif

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} G68AP
Função
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function G68AP(Oper)	
	Local nX
	Local nY
	Local nZ

	// RAÇA ou CLASS. DESTINO E RASTREABILIDADE
	Local aSelRC := {}
	Local aSelRS := {}
	Local aSelTF := {}
	
	// RAÇA
	DO CASE
		CASE nRadioRC == 1
			aAdd(aSelRC, "006")	// ANGUS
		CASE nRadioRC == 2
			aAdd(aSelRC, "021")	// ANGUS NJ
		CASE nRadioRC == 3
			aAdd(aSelRC, "002")	// HEREFORD
		CASE nRadioRC == 4
			aAdd(aSelRC, "022")	// HEREFORD NJ
		CASE nRadioRC == 5
			aAdd(aSelRC, "020")	// NOVILHO
		CASE nRadioRC == 6
			aAdd(aSelRC, "013")	// 8 DENTES
		CASE nRadioRC == 7
			aAdd(aSelRC, "014")	// BLACK
		CASE nRadioRC == 8
			aAdd(aSelRC, "008")	// TOURUNO
		CASE nRadioRC == 9
			aAdd(aSelRC, "019")	// TOURO
		CASE nRadioRC == 10
			aAdd(aSelRC, "001")	// MAGRO
		CASE nRadioRC == 11
			aAdd(aSelRC, "005")	// CZ LEITE
	ENDCASE

	// RASTREABILIDADE
	DO CASE
		CASE nRadioRS == 1
			aAdd(aSelRS, "BR ")	// MERCADO INTERNO
		CASE nRadioRS == 2
			aAdd(aSelRS, "CN ")	// ANIMAIS ATE 4 DENTES
		CASE nRadioRS == 3
			aAdd(aSelRS, "HK ")	// LIVRE DE AVOPARCINA
		CASE nRadioRS == 4
			aAdd(aSelRS, "LG ")	// LIVRE DE AVOPARCINA
		CASE nRadioRS == 5
			aAdd(aSelRS, "NE ")	// DOCUMENTO INCONFORME NO RECEBIMENTO
		CASE nRadioRS == 6
			aAdd(aSelRS, "RT ")	// GADO RASTREADO - COM BRINCO
		CASE nRadioRS == 7
			aAdd(aSelRS, "USA")	// LISTA DE PRODUTOS NA IF
	ENDCASE

	// 	CLASS. DESTINO
	DO CASE
		CASE nRadioTF == 1
			aAdd(aSelTF, "T") // TF
		CASE nRadioTF == 2
			aAdd(aSelTF, "S") // TS
		CASE nRadioTF == 3
			aAdd(aSelTF, "R") // Conserva
	ENDCASE	

	GeraTMP()

	M->Z2_QPPESO := 0.00
	M->Z2_QPPECA := 0

	_cOPCorte := M->Z2_NUM

	If Substr(M->Z2_NUMAM,1,3) == "SIF"
		M->Z2_QPPESO := 999999.99
		M->Z2_QPPECA := 9999
		Return .T.
	EndIf

	// =============== INICIO PROCESSAMENTO DE DADOS PARA RAÇA INFORMADA
	For nX:=1 To Len(aSelRC)

		For nY:=1 To Len(aSelRS)

			DbSelectArea("ZAJ")
			DbSelectArea("SZK")
			DbSelectArea("SZL")
			ZAJ->(DbSetOrder(1))
			SZK->(DbSetOrder(4))
			SZL->(DbSetOrder(1))
			ZAJ->(DbGoTop())
			SZK->(DbGoTop())
			SZL->(DbGoTop())

			//_aClasEsp := {}

			// Se prioridade for (T)erceiros...
			If Alltrim(M->Z2_PRIORID) == "T"

				BuscaCert(M->Z2_CERTIf,M->Z2_CORORI,M->Z2_DERIV)

				While QRY->(!Eof())
					If !Empty(QRY->ZAJ_PREDES)
						QRY->(DbSkip())
						Loop
					EndIf

					M->Z2_QPPECA := M->Z2_QPPECA + 1

					RecLock("TMP",.T.)
					TMP->SEQPECA := QRY->ZAJ_NUM
					MsUnlock()

					QRY->(DbSkip())
				EndDo

			ElseIf ZAJ->(MsSeek(FWxFilial("ZAJ") + M->Z2_NUMAM))		// Laço para calculo mediante os parametros

				While ZAJ->(!eof()) .And. ZAJ->ZAJ_FILIAL = FWxFilial("ZAJ") .And. ZAJ->ZAJ_NUMAM = M->Z2_NUMAM
					// Trata carcaças já baixadas
					If !Empty(ZAJ->ZAJ_HORAS) .And. !Empty(ZAJ->ZAJ_DATAS)
						ZAJ->(DbSkip())
						Loop
					EndIf

					// Validação para não marcar Predes nas carcaças BLack se OP não for Black
					if M->Z2_PROGRAM != '014' .and. ZAJ->ZAJ_BLACK == 'S'
						ZAJ->(DbSkip())
						Loop
					endif

					// Trata o empenho
					If !Empty(ZAJ->ZAJ_PREDES)
						ZAJ->(DbSkip())
						Loop
					EndIf

					// Se é OP de um produto derivativo faz o tratamento
					If !Empty(M->Z2_DERIV)
						If M->Z2_DERIV <> ZAJ->ZAJ_COD
							ZAJ->(DbSkip())
							Loop
						EndIf
					EndIf

					If SZK->(MsSeek(FWxFilial("SZK") + ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO)))
						//_cClasEsp := SZK->ZK_CLASESP

						// Trata a Tipificação
						If SZK->ZK_TIPIFI <> M->Z2_TIPIFI .And. M->Z2_PRIORID $ 'R/A'
							ZAJ->(DbSkip())
							Loop
						EndIf

						// Trata o programa
						if M->Z2_PROGRAM == '014'
							// Se for Black não verifica o programa
						else
							If SZK->ZK_PROGRAM <> aSelRC[nX] .And. M->Z2_PRIORID $ 'P/A'
								ZAJ->(DbSkip())
								Loop
							EndIf
						endif

						If ZAJ->ZAJ_CORORI <> M->Z2_CORORI
							ZAJ->(DbSkip())
							Loop
						EndIf

						// Trata se é Black
						If !Empty(M->Z2_BLACK)
							If SZK->ZK_BLACK <> M->Z2_BLACK
								ZAJ->(DbSkip())
								Loop
							EndIf
						EndIf

						// Trata a categoria
						If !Empty(M->Z2_CATEG) .And. M->Z2_PRIORID <> 'D'
							If SZK->ZK_CATEG <> M->Z2_CATEG
								ZAJ->(DbSkip())
								Loop
							EndIf
						EndIf

						// Trata a dentição
						If !Empty(M->Z2_DENT)
							If SZK->ZK_DENT <> M->Z2_DENT
								ZAJ->(DbSkip())
								Loop
							EndIf
						EndIf

						// Trata a Camara
						If !Empty(M->Z2_CAMARA)
							If SZK->ZK_LOCAL <> M->Z2_CAMARA
								ZAJ->(DbSkip())
								Loop
							EndIf
						EndIf

						// Se a Previsão de Produção tiver prioridade por rastreabilidade ou Ambos...
						If M->Z2_PRIORID $ 'R/A'
							_cClasEsp := SZK->ZK_CLASESP	  

							/*If M->Z2_CLASESP == "S"          			   			   
								If _cClasEsp <> "1" 
									ZAJ->(DbSkip())
									Loop					                      						
								EndIf                     
							EndIf                   

							If M->Z2_CLASESP == "N"
								If _cClasEsp <> "2"
									ZAJ->(DbSkip())
									Loop					
								EndIf				
							EndIf*/

							// Se a previsão de Produção tiver prioridade Ambos...
							if M->Z2_PROGRAM == '014'
							// Se for Black não valida programa porque carcaças Black são de vários programas 
							else
								If M->Z2_PRIORID == "A" 
									If SZK->ZK_PROGRAM <> aSelRC[nX]
										ZAJ ->(DbSkip())
										Loop
									EndIf
								EndIf
							endif

							if AllTrim(aSelRS[nY]) $ "RU/RT/USA/BR/NE"
								If AllTrim(SZK->ZK_CLASSIF) = AllTrim(aSelRS[nY])		//"RU/RT"
									// Nao considera TF ou Conserva na apuracao das pecas e peso
									If !ChkDest("T/R/S")
										AtuTmpSZ2(oper)
									EndIf
								EndIf
							elseif AllTrim(aSelRS[nY]) == "HK"
								if M->Z2_PROGRAM == '014' .and. SZK->ZK_BLACK <> M->Z2_BLACK
									ZAJ->(DbSkip())
									Loop
								else
									If AllTrim(SZK->ZK_CLASSIF) = "HK"		//"HK/RU/RT"
										// Nao considera TF ou Conserva na apuracao das pecas e peso
										If !ChkDest("T/R/S")
											AtuTmpSZ2(oper)
										EndIf
									EndIf
								endif
							endif

							// Trata as classIficações por rastreabiliade...
							DO CASE
								CASE AllTrim(aSelRS[nY]) == "RU"
									If AllTrim(SZK->ZK_CLASSIF) $ "RU"		//"RU/RT"
										// Nao considera TF ou Conserva na apuracao das pecas e peso
										If !ChkDest("T/R/S")
											AtuTmpSZ2(oper)
										EndIf
									EndIf

								CASE AllTrim(aSelRS[nY]) == "RT"
									If (AllTrim(SZK->ZK_CLASSIF) == "RT")
										// Nao considera TF ou Conserva na apuracao das pecas e peso
										If !ChkDest("T/R/S")
											AtuTmpSZ2(oper)
										EndIf
									EndIf

								CASE AllTrim(aSelRS[nY]) == "USA"
									If (AllTrim(SZK->ZK_CLASSIF) == "USA")
										// Nao considera TF ou Conserva na apuracao das pecas e peso
										If !ChkDest("T/R/S")
											AtuTmpSZ2(oper)
										EndIf
									EndIf

								CASE AllTrim(aSelRS[nY]) == "BR"
									If (AllTrim(SZK->ZK_CLASSIF) == "BR")
										// Nao considera TF ou Conserva na apuracao das pecas e peso
										If !ChkDest("T/R/S")
											AtuTmpSZ2(oper)
										EndIf
									EndIf

								CASE AllTrim(aSelRS[nY]) == "HK"
									// Programado para todas as Black serem Classificação HK
									if M->Z2_PROGRAM == '014' .and. SZK->ZK_BLACK <> M->Z2_BLACK
										ZAJ->(DbSkip())
										Loop
									else
										If AllTrim(SZK->ZK_CLASSIF) $ "HK"		//"HK/RU/RT"
											// Nao considera TF ou Conserva na apuracao das pecas e peso
											If !ChkDest("T/R/S")
												AtuTmpSZ2(oper)
											EndIf
										EndIf
									endif
								CASE AllTrim(aSelRS[nY]) == "NE"
									If AllTrim(SZK->ZK_CLASSIF) $ "NE"		//"NE/HK/RU/RA/RT"
										// Nao considera TF ou Conserva na apuracao das pecas e peso
										If !ChkDest("T/R/S")
											AtuTmpSZ2(oper)
										EndIf
									EndIf
							ENDCASE

						ElseIf M->Z2_PRIORID == 'P'	// Se a Previsão de Produção tiver prioridade por programa...

							// Se validação for por programa black (014) e carcaça não vier do abate como black não marca Predes
							if M->Z2_PROGRAM == '014' .and. SZK->ZK_BLACK <> M->Z2_BLACK
								ZAJ->(DbSkip())
								Loop
							else
								If SZK->ZK_PROGRAM == aSelRC[nX]
									// Nao considera TF ou Conserva na apuracao das pecas e peso
									If !ChkDest("T/R/S")
										AtuTmpSZ2(oper)
									EndIf
								EndIf
							endif

						ElseIf M->Z2_PRIORID == "D" // Prioridade por dentição

							If SZK->ZK_DENT == M->Z2_DENT
								// Nao considera TF ou Conserva na apuracao das pecas e peso
								If !ChkDest("T/R/S")
									AtuTmpSZ2(oper)
								EndIf
							EndIf

						ElseIf M->Z2_PRIORID == "C"// .And. _cClasEsp == "1" 		// Prioridade por classIficação especial

							// Nao considera TF ou Conserva na apuracao das pecas e peso
							If !ChkDest("T/R/S")
								AtuTmpSZ2(oper)
							EndIf
						EndIf
					EndIf

					ZAJ->(DbSkip())
				EndDo
			EndIf

		Next nY

	Next nX
	// =============== FINAL PROCESSAMENTO DE DADOS PARA RAÇA INFORMADA

	M->Z2_QPPECA := ceiling(M->Z2_QPPECA/2)
	M->Z2_QPPESO := round(M->Z2_QPPESO/2,2)

	// =============== INICIO PROCESSAMENTO DE DADOS PARA CLASS. DESTINO INFORMADA
	aSelRC := {}
	aSelRS := {}

	// RAÇA
	aAdd(aSelRC, "006")	// ANGUS
	aAdd(aSelRC, "021")	// ANGUS NJ
	aAdd(aSelRC, "002")	// HEREFORD
	aAdd(aSelRC, "022")	// HEREFORD NJ
	aAdd(aSelRC, "020")	// NOVILHO
	aAdd(aSelRC, "013")	// 8 DENTES
	aAdd(aSelRC, "014")	// BLACK
	aAdd(aSelRC, "008")	// TOURUNO
	aAdd(aSelRC, "019")	// TOURO
	aAdd(aSelRC, "001")	// MAGRO
	aAdd(aSelRC, "005")	// CZ LEITE

	// RASTREABILIDADE
	aAdd(aSelRS, "BR ")	// MERCADO INTERNO
	aAdd(aSelRS, "CN ")	// ANIMAIS ATE 4 DENTES
	aAdd(aSelRS, "HK ")	// LIVRE DE AVOPARCINA
	aAdd(aSelRS, "LG ")	// LIVRE DE AVOPARCINA
	aAdd(aSelRS, "NE ")	// DOCUMENTO INCONFORME NO RECEBIMENTO
	aAdd(aSelRS, "RT ")	// GADO RASTREADO - COM BRINCO
	aAdd(aSelRS, "USA")	// LISTA DE PRODUTOS NA If

	For nZ:=1 To Len(aSelTF)		
		For nX:=1 To Len(aSelRC)

			For nY:=1 To Len(aSelRS)

				DbSelectArea("ZAJ")
				DbSelectArea("SZK")
				DbSelectArea("SZL")
				ZAJ->(DbSetOrder(1))
				SZK->(DbSetOrder(4))
				SZL->(DbSetOrder(1))
				ZAJ->(DbGoTop())
				SZK->(DbGoTop())
				SZL->(DbGoTop())

				//_aClasEsp := {}

				// Se prioridade for (T)erceiros...
				If Alltrim(M->Z2_PRIORID) == "T"

					BuscaCert(M->Z2_CERTIf,M->Z2_CORORI,M->Z2_DERIV)

					While QRY->(!Eof())   
						If !Empty(QRY->ZAJ_PREDES)
							QRY->(DbSkip())
							Loop					
						EndIf	 

						M->Z2_QPPECA := M->Z2_QPPECA + 1	   

						RecLock("TMP",.T.)
						TMP->SEQPECA := QRY->ZAJ_NUM
						MsUnlock()  

						QRY->(DbSkip())	
					EndDo

				ElseIf ZAJ->(MsSeek(FWxFilial("ZAJ") + M->Z2_NUMAM))		// Laço para calculo mediante os parametros

					While ZAJ->(!eof()) .And. ZAJ->ZAJ_FILIAL = FWxFilial("ZAJ") .And. ZAJ->ZAJ_NUMAM = M->Z2_NUMAM  
						// Trata carcaças já baixadas
						If !Empty(ZAJ->ZAJ_HORAS) .And. !Empty(ZAJ->ZAJ_DATAS)
							ZAJ->(DbSkip())
							Loop
						EndIf

						// Validação para não marcar Predes nas carcaças BLack se OP não for Black
						if M->Z2_PROGRAM != '014' .and. ZAJ->ZAJ_BLACK == 'S'
							ZAJ->(DbSkip())
							Loop
						endif

						// Trata o empenho
						If !Empty(ZAJ->ZAJ_PREDES)
							ZAJ->(DbSkip())
							Loop
						EndIf

						// Se é OP de um produto derivativo faz o tratamento
						If !Empty(M->Z2_DERIV)
							If M->Z2_DERIV <> ZAJ->ZAJ_COD
								ZAJ->(DbSkip())
								Loop
							EndIf
						EndIf

						If SZK->(MsSeek(FWxFilial("SZK") + ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO)))
							_cClasEsp := SZK->ZK_CLASESP				

							// Trata a Tipificação
							If SZK->ZK_TIPIFI <> M->Z2_TIPIFI .And. M->Z2_PRIORID $ 'R/A'
								ZAJ->(DbSkip())
								Loop
							EndIf

							// Trata o programa
							if M->Z2_PROGRAM != '014'
								// Se for Black não valida programa porque carcaças Black são de vários programas 
								If SZK->ZK_PROGRAM <> aSelRC[nX] .And. M->Z2_PRIORID $ 'P/A'
									ZAJ->(DbSkip())
									Loop
								EndIf
							Endif
							// ---- fim
							If ZAJ->ZAJ_CORORI <> M->Z2_CORORI
								ZAJ->(DbSkip())
								Loop
							EndIf        

							// Trata se é Black
							If !Empty(M->Z2_BLACK)
								If SZK->ZK_BLACK <> M->Z2_BLACK
									ZAJ->(DbSkip())
									Loop
								EndIf
							EndIf             

							// Trata a categoria
							If !Empty(M->Z2_CATEG) .And. M->Z2_PRIORID <> 'D'
								If SZK->ZK_CATEG <> M->Z2_CATEG
									ZAJ->(DbSkip())
									Loop
								EndIf
							EndIf

							// Trata a dentição
							If !Empty(M->Z2_DENT)
								If SZK->ZK_DENT <> M->Z2_DENT
									ZAJ->(DbSkip())
									Loop
								EndIf
							EndIf

							// Trata a Camara
							If !Empty(M->Z2_CAMARA)
								If SZK->ZK_LOCAL <> M->Z2_CAMARA
									ZAJ->(DbSkip())
									Loop
								EndIf
							EndIf

							// Se a Previsão de Produção tiver prioridade por rastreabilidade ou Ambos...
							If M->Z2_PRIORID $ 'R/A'
								_cClasEsp := SZK->ZK_CLASESP

								/*If M->Z2_CLASESP == "S"
									If _cClasEsp <> "1"
										ZAJ->(DbSkip())
										Loop
									EndIf
								EndIf

								If M->Z2_CLASESP == "N"
									If _cClasEsp <> "2"
										ZAJ->(DbSkip())
										Loop
									EndIf
								EndIf*/

								// Se a previsão de Produção tiver prioridade Ambos...
								if M->Z2_PROGRAM != '014'
									If M->Z2_PRIORID == "A"
										If SZK->ZK_PROGRAM <> aSelRC[nX]
											ZAJ->(DbSkip())
											Loop
										EndIf
									EndIf
								endif

								// Trata as classIficações por rastreabiliade...
								if AllTrim(aSelRS[nY]) $ "RU/RT/USA/BR/HK/NE"
									If AllTrim(SZK->ZK_CLASSIF) = AllTrim(aSelRS[nY])		//"RU/RT"
										// Nao considera TF ou Conserva na apuracao das pecas e peso
										If ChkDest(aSelTF[nZ])
											AtuTmpSZ2(oper)
										EndIf
									EndIf
								endif

							ElseIf M->Z2_PRIORID == 'P'	// Se a Previsão de Produção tiver prioridade por programa...

								if M->Z2_PROGRAM == '014' .and. SZK->ZK_BLACK <> M->Z2_BLACK
									Loop
								else
									If SZK->ZK_PROGRAM == aSelRC[nX]
										// Nao considera TF ou Conserva na apuracao das pecas e peso
										If ChkDest(aSelTF[nZ])
											AtuTmpSZ2(oper)
										EndIf
									EndIf
								Endif
								// --- Fim
							ElseIf M->Z2_PRIORID == "D" // Prioridade por dentição

								If SZK->ZK_DENT == M->Z2_DENT
									// Nao considera TF ou Conserva na apuracao das pecas e peso
									If ChkDest(aSelTF[nZ])
										AtuTmpSZ2(oper)
									EndIf
								EndIf

							ElseIf M->Z2_PRIORID == "C" //.And. _cClasEsp == "1" 		// Prioridade por classIficação especial

								// Nao considera TF ou Conserva na apuracao das pecas e peso
								If ChkDest(aSelTF[nZ])
									AtuTmpSZ2(oper)
								EndIf
							EndIf
						EndIf

						ZAJ->(DbSkip())
					EndDo 
				EndIf

			Next nY

		Next nX

	Next nZ
	// =============== FINAL PROCESSAMENTO DE DADOS PARA CLASS. DESTINO INFORMADA

	oDlg:refresh()

Return .T.

/*/{Protheus.doc} ChkDest
	Função para checar se alguma das peças de uma carcaça foi destinada confome a string recebida por parâmetro
	@author Adonai
	@since 20/12/2023
	@param cDest, String, String contendo o(s) destino(s) a ser filtrado(s)
	@return lRet, Boolean, Retorna .T. caso encontre uma peça com destino que esteja contido na string recebida por parâmetro
	@version 1.0
/*/
Static Function ChkDest(cDest)

	Local lRet := .F.

	if SZK->ZK_DESTINO $ cDest
		lRet := .T.
	endif
Return lRet

/*/{Protheus.doc} AtuTmpSZ2
	Função de gravação no arquivo de trabalho e atualização da OP
	@author Adonai
	@since 20/12/2023
	@version 1.0
/*/
Static Function AtuTmpSZ2(oper)
	M->Z2_QPPECA := M->Z2_QPPECA + 1
	M->Z2_QPPESO := M->Z2_QPPESO + ZAJ->ZAJ_PESO

	If oper == "S"		 // Para reserva da carcaça
		RecLock("TMP",.T.)
		TMP->NUMAM   := M->Z2_NUMAM
		TMP->SEQABT  := ZAJ->ZAJ_CONTRO
		TMP->SEQPECA := ZAJ->ZAJ_NUM
		TMP->CLASESP :=	_cClasEsp
		MsUnlock()
	EndIf
Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} GeraTMP
Função para gerar o arquivo temporário
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function GeraTMP()

	_aArqTrb := {}
	aStru := {}                                           

	aadd(aStru,{"NUMAM"   , "C",   08, 0,  "@!",'Abate'})	
	aadd(aStru,{"SEQABT"  , "C",   06, 0,  "@!",'Seq.Abate'})
	aadd(aStru,{"SEQPECA" , "C",   10, 0,  "@!",'Seq.Peca'}) 
	aadd(aStru,{"CLASESP" , "C",   01, 0,  "@!",'Clas.Esp.'}) 

	If Select('TMP') <> 0                   // Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} BuscaCert
Função para buscar certIficado
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function BuscaCert(_cNum,_cCorOri,_cDeriv)

	_cQuery := " SELECT ZAJ_NUM, ZAJ_IMP, ZAJ_ZAPNUM, ZAJ_PREDES 
	_cQuery += "  FROM " + RetSqlTab("ZAJ")
	_cQuery += " WHERE " + RetSqlFil("ZAJ")
	_cQuery += "   AND ZAJ_ZAPNUM = '" + _cNum + "' AND ZAJ_IMP = 'S'"
	_cQuery += "   AND ZAJ_DATAS = '' AND ZAJ_HORAS = '' AND ZAJ_CORORI = '" + _cCorOri + "'"
	_cQuery += IIf(!Empty(_cDeriv)," AND ZAJ_COD = '" + _cDeriv + "'","")
	_cQuery += "   AND " + RetSqlDel("ZAJ")
	_cQuery += " ORDER BY ZAJ_NUM

	_cQuery  := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(DbCloseArea())
	EndIf

	TCQUERY _cQuery NEW ALIAS "QRY"

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} GravaZAJ
Função para gravar o que está no TMP para a ZAJ
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function GravaZAJ()

	Local _nCont := 0

	_aArqTrb := {}
	
	If M->Z2_RESERV == "S"

		If Select('TMP') <> 0
			ZAJ->(DbSetOrder(2))
			SZK->(DbSetOrder(4))
			SZK->(DbGoTop())
			ZAJ->(DbGoTop())
			TMP->(DbGoTop())

			While TMP->(!eof())
				_ncont++
				TMP->(DbSkip())
			EndDo

			TMP->(DbGoTop())

			// Se houverem registros selecionados faz o processo...
			If _nCont <> 0
				ProcRegua(M->Z2_QPPECA)

				While TMP->(!Eof())
					IncProc()
					
					If ZAJ->(MsSeek(FWxFilial("ZAJ") + TMP->SEQPECA))
						RecLock("ZAJ",.F.)
						ZAJ->ZAJ_PREDES := _cOPCorte
						MsUnlock()
					EndIf
					TMP->(DbSkip())
				EndDo
				TMP->(DbCloseArea())
				u_arqtrb("FechaTodos",,,, @_aArqTrb)
			EndIf
		EndIf
	EndIf

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} VisCert
Função para mostrar o número do certificado da tabela ZAP
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function VisCert()

	Local cCodigo := SZ2->Z2_CERTIF 

	_cCERT := GetAdvFVal("ZAP", "ZAP_CERT", FWxFilial("ZAP") + AllTrim(cCodigo), 3)

	If !Empty(AllTrim(cCodigo))
		FWAlertSuccess("", "Certificado Número: " + _cCERT)
	Else
		FWAlertInfo("", "!! Prev. Desossa sem Certificado Marcado !!")
	Endif

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} Gjf68nlb
Função para liberar
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function Gjf68nlb()

	If SZ2->Z2_STATUS != "E" .And. SZ2->Z2_STATUS != "I" .And. SZ2->Z2_STATUS != "A"
		RecLock("SZ2",.F.)
		If SZ2->Z2_QRPECA == 0
			SZ2->Z2_STATUS := "A"
		Else
			SZ2->Z2_STATUS := "I"
		EndIf
		MsUnlock()
	Else
		MsgBox("Status não permite essa operação!","OPERAÇÃO INVALIDA!","STOP")
	EndIf

	if FWAlertYesNo("Deseja bloquear as OPs liberadas restantes?", "CONFIRMA")
		BloqOPs(SZ2->Z2_PROGRAM, SZ2->Z2_COD)
	endif

Return

// Função para bloquear as outras OPs quando se libera uma
Static Function BloqOPs(_cProg, _cCodC)

	_cQuery2 := "SELECT Z2_NUM, Z2_COD"
	_cQuery2 += " FROM  " + RetSQLTab('SZ2')
	_cQuery2 += " WHERE " + RetSQLFil('SZ2')
	if _cProg $ "006/021"
		_cQuery2 += " AND Z2_PROGRAM NOT IN ('006','021','014')"
	elseif _cProg = "002"
		_cQuery2 += " AND Z2_PROGRAM NOT IN ('002','014')"
	elseif _cProg = "022"
		_cQuery2 += " AND Z2_PROGRAM NOT IN ('022','014')"
	else
		_cQuery2 += " AND Z2_PROGRAM <> '" + alltrim(_cProg) + "'"
	endif
	_cQuery2 += " AND Z2_STATUS NOT IN ('B','E')"
	_cQuery2 += " AND Z2_COD = '" + alltrim(_cCodC) + "'"
	_cQuery2 += " AND " + RetSQLDel('SZ2')
	_cQuery2 += " ORDER BY Z2_NUM"

	_cQuery2  := ChangeQuery(_cQuery2)

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "QRY2"

	QRY2->(dbGoTop())
	SZ2->(DbSetOrder(2))
	SZ2->(dbGoTop())

    While QRY2->(!EOF())

		if SZ2->(MsSeek(FwxFilial("SZ2")+QRY2->(Z2_NUM+Z2_COD)))
			RecLock("SZ2",.F.)
			SZ2->Z2_STATUS := "B"
			MsUnlock()
		else
			FWAlertError("Op da Desossa não encontrada!", "ERRO")
		endif

		QRY2->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    enddo

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} Gjf68nbq
Função para bloquear
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function Gjf68nbq()

	If SZ2->Z2_STATUS != "B" .And. SZ2->Z2_STATUS != "E"
		RecLock("SZ2",.F.)
		SZ2->Z2_STATUS := "B"
		MsUnlock()
	Else
		MsgBox("Status não permite essa operação!","OPERAÇÃO INVALIDA!","STOP")
	EndIf

Return

// Função para visualização de log de OPs bloqueadas online
User Function Gjf68nvb()

	Local oTimer
	aObjects := {}    //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	GeraLOG()

	aCampos  := {}

	//AADD(aCampos,{"LOG_OK"     	,, "OK"			,"@!"})
	AADD(aCampos,{"LOG_DATA"    ,, "Data"		,"@!"})
	AADD(aCampos,{"LOG_HORA"	,, "Hora"		,"@!"})
	AADD(aCampos,{"LOG_DESC"    ,, "Descrição"	,"@!"})
	AADD(aCampos,{"LOG_USER"   	,, "Usuário"	,"@!"})

	DEFINE MSDIALOG oDlgvb TITLE "LOG de OPs da Desossa" From 02,0 To 600,1280 PIXEL

	oMark := MsSelect():New("TMP2","","",aCampos,,,{05,1,250,643},,,,,)

	_oButton5 := TButton():New(275, 300, "Sair", oDlgvb,{|| oDlgvb:end()},50,15,,,.F.,.T.,.F.,,.F.,,,.F.)

	oTimer := TTimer():New(5000, {|| u_gjf68nat()}, oDlgvb)
	oTimer:Activate()

	ACTIVATE MSDIALOG oDlgvb CENTERED

Return

User function Gjf68nat()
	GeraLOG()
	oDlgvb:refresh()
	oMark:oBrowse:Refresh()
Return

Static Function GeraLOG()

    _cQuery2 := "SELECT LOG_DATA, LOG_HORA, LOG_DESC, LOG_USER"
	_cQuery2 += " FROM  " + RetSQLTab('LOG')
	_cQuery2 += " WHERE " + RetSQLFil('LOG')
	_cQuery2 += " AND LOG_ROTINA = 'MRVT05'"
	_cQuery2 += " AND LOG_DATA = '" + dtos(date()) + "'"
	_cQuery2 += " AND " + RetSQLDel('LOG')
	_cQuery2 += " ORDER BY LOG_ID DESC"

	cAliasTMP2 := GetNextAlias()
	TCQuery _cQuery2 new alias &cAliasTMP2
	(cAliasTMP2)->(dbGoTop())

	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"

	_aArqTrb  := {}

	If Select("TMP2")<>0
		TMP2->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	DbSelectArea(cAliasTMP2)
	(cAliasTMP2)->(DbGotop())

	aStru := {}

	//aadd(aStru,{"LOG_OK"    , "C",  2, 0})
	aadd(aStru,{"LOG_DATA"	, "C",  8, 0})
	aadd(aStru,{"LOG_HORA"  , "C",  5, 0})
	aadd(aStru,{"LOG_DESC"  , "C",  100, 0})
	aadd(aStru,{"LOG_USER"  , "C",  20, 0})

	U_ArqTrb("Cria", "TMP2", aStru, {}, @_aArqTrb)

	(cAliasTMP2)->(DbGoTop())

	While (cAliasTMP2)->(!eof())

		DbSelectArea('TMP2')
		Reclock('TMP2',.t.)
		TMP2->LOG_DATA := dtoc(stod((cAliasTMP2)->LOG_DATA))
		TMP2->LOG_HORA := (cAliasTMP2)->LOG_HORA
		TMP2->LOG_DESC := alltrim((cAliasTMP2)->LOG_DESC)
		TMP2->LOG_USER  := alltrim((cAliasTMP2)->LOG_USER)
		MsUnlock() 

		(cAliasTMP2)->(DbSkip())
	enddo

	dbSelectarea('TMP2')

	TMP2->(dbGotop())

	(cAliasTMP2)->(dbCloseArea())

return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} Gjf68nlt
Função para gerenciamento em lote
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function Gjf68nlt()

	CampoA := {"NE","HK","RU","RT"}
	CampoB := {"Liberar","Bloquear"}
	Valor1 := ""
	Valor2 := ""

	DEFINE MSDIALOG oDlg2 TITLE "Gerenciamento em Lote" FROM 000,000 TO 100,250 OF oMainWnd PIXEL

	@ 013,002 SAY "Classificação:" 	Object oSay1
	@ 025,002 SAY "Operação:" 		Object oSay2

	@ 001,006 COMBOBOX Valor1 ITEMS CampoA SIZE 20,08
	@ 002,006 COMBOBOX Valor2 ITEMS CampoB SIZE 40,08

	@ 014,100 BMPBUTTON TYPE 1 ACTION Lote() 		Object Obtn1
	@ 028,100 BMPBUTTON TYPE 2 ACTION odlg2:End() 	Object Obtn2

	ACTIVATE MSDIALOG oDlg2 CENTERED

Return .T.

// Chamada da função Lote
Static Function Lote()

	SZ2->(DbSetOrder(2))
	SZ2->(DbGoTop())
	SZ2->(MsSeek(FWxFilial("SZ2")))
	While SZ2->(!Eof()) .And. SZ2->Z2_FILIAL = FWxFilial("SZ2")

		If SZ2->Z2_STATUS == "E"
			SZ2->(DbSkip())
			Loop
		EndIf

		If AllTrim(SZ2->Z2_CLASSIF) <> Valor1
			SZ2->(DbSkip())
			Loop
		EndIf

		If Valor2 == "Liberar"
			If SZ2->Z2_QRPECA <> 0
				RecLock("SZ2",.F.)
				SZ2->Z2_STATUS := "I"
				MsUnlock()
			ElseIf SZ2->Z2_QRPECA == 0
				RecLock("SZ2",.F.)
				SZ2->Z2_STATUS := "A"
				MsUnlock()
			EndIf
		ElseIf Valor2 == "Bloquear"
			If SZ2->Z2_STATUS $ "A/I"
				RecLock("SZ2",.F.)
				SZ2->Z2_STATUS := "B"
				MsUnlock()
			EndIf
		EndIf

		SZ2->(DbSkip())
	EndDo

	SZ2->(DbSetOrder(1))

	odlg2:end()

Return .T.

//-----------------------------------------------------------------------------
/*/{Protheus.doc} Gjf68nlc
Função para liberação de carcaças não usadas das OPs
@author     Evandro Mugnol
@since      Nov/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function Gjf68nlc()

	_nCarc := 0

	If SZ2->Z2_STATUS <> "E"
		MsgBox("Previsão de Produção ainda não encerrada!","OPERAÇÃO INCONSISTENTE!","ERRO")
		Return .F.
	EndIf

	DbSelectArea("ZAJ")
	ZAJ->(dbSetOrder(1))
	ZAJ->(DbGoTop()) 
	If ZAJ->(MsSeek(FWxFilial("ZAJ") + SZ2->Z2_NUMAM))         

		While ZAJ->(!Eof()) .And. ZAJ->ZAJ_FILIAL + ZAJ->ZAJ_NUMAM == FWxFilial("ZAJ") + SZ2->Z2_NUMAM

			If SZ2->Z2_NUM == ZAJ->ZAJ_PREDES
				If !Empty(ZAJ->ZAJ_DATAS) .And. !Empty(ZAJ->ZAJ_HORAS) .And. !Empty(ZAJ->ZAJ_PRECAR) .And. !Empty(ZAJ->ZAJ_PREPED) .And. !Empty(ZAJ->ZAJ_ITEM)
					_nCarc++
					RecLock("ZAJ",.F.)
					ZAJ->ZAJ_PREDES := " "
					MsUnlock()
				EndIf
			EndIf

			ZAJ->(DbSkip())
		EndDo
	EndIf

	MsgBox("TOTAL DE CARCAÇAS COM RESERVA LIBERADA: " + Transform(_nCarc, "@E 9,999"),"FIM DE OPERAÇÃO","INFO")

Return .T.

// ================================================================================================== //
// ======== EXECBLOCKS ABAIXO DEVEM SER COMPILADOS QUANDO NÃO MAIS USADO O FONTE GFJ68.PRW ========== //
// ================================================================================================== //
/*
// Execblock disparado pelo campo X3_VLDUSER do campo Z2_CORORI
User Function GJF68c()
	
	Local _cCod  := ""
	Local _cDesc := ""

	DbSelectArea("SB1")
	If M->Z2_PRIORID <> "T"
		DO CASE
			CASE M->Z2_CORORI == "T"
				_cCod := '005016"
			CASE M->Z2_CORORI == "D"
				_cCod := "005020"			
			CASE M->Z2_CORORI == "C"
				_cCod := "005018"			
		ENDCASE
	Else
		DO CASE
			CASE M->Z2_CORORI == "T"
				_cCod := "001340"
			CASE M->Z2_CORORI == "D"
				_cCod := "001502"			
			CASE M->Z2_CORORI == "C"
				_cCod := '001450"			
		ENDCASE
	EndIf

	_cDesc := fBuscaCPO("SB1", 1, FWxFilial("SB1") + _cCod, "B1_DESC")

	M->Z2_COD    := _cCod
	M->Z2_DESCRI := _cDesc

Return .T.


// Execblock disparado pelo campo X3_VLDUSER do campo Z2_DERIV
User Function GJF68d()
	Local _cCod    := ""
	Local _cDesc   := ""
	Local _cCorOri := ""

	ZB4->(DbSetOrder(1))
	If ZB4->(MsSeek(FWxFilial("ZB4") + M->Z2_DERIV))
		_cCod    := ZB4->ZB4_COD
		_cDesc   := ZB4->ZB4_DESC
		_cCorOri := ZB4->ZB4_CODORI
	EndIf

	M->Z2_COD    := _cCod
	M->Z2_DESCRI := _cDesc
	M->Z2_CORORI := _cCorOri    

Return .T.
*/

//-----------------------------------------------------------------------------
/*/{Protheus.doc} Gjf68aut
FWMarkBrowse nas previsões de produção para liberar/bloquear os marcados.
@author     Evandro Mugnol
@since      Set/2023
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function GJF68AUT()

	Local lRet 	  := .T.
	Local aCpos	  := {}
	Local aCampos := {}
	Local nI

	Private cFiltro	  := ""
	Private aRotina	  := {}
	Private cCadastro := "Seleção das Previsões de Produção"
	Private oMark

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incluindo botões no menu                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aRotina,{"Pesquisar" 		 ,	"AxPesqui" 		,0 ,1 })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definindo campos a serem apresentados no FWMarkBrowse                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCpos := {"Z2_NUM","Z2_DATA","Z2_PRIORID","Z2_CORORI","Z2_COD","Z2_DESCRI","Z2_RESERV","Z2_NUMAM","Z2_CLASSIF","Z2_QPPECA","Z2_QRPECA","Z2_DATAABT","Z2_CLASESP"}

	DbSelectArea("SX3")
	DbSetOrder(2)
	For nI := 1 To Len(aCpos)
		MsSeek(aCpos[nI])
		AADD(aCampos,{AllTrim(X3_TITULO),X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_PICTURE})
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Construindo o FWMarkBrowse    							               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMark:= FWMarkBrowse():New()'

	oMark:SetAlias("SZ2")						// Define a tabela do MarkBrowse
	oMark:SetSemaphore(.F.)						// Define se utiliza marcacao exclusiva
	oMark:SetDescription(cCadastro)				// Define o titulo do MarkBrowse
	oMark:SetFieldMark("Z2_OK")					// Define o campo utilizado para a marcacao
	oMark:SetFields(aCampos)					// Define os campos a serem mostrados no MarkBrowse

	// Setando Legenda
	oMark:AddLegend("( SZ2->Z2_STATUS == 'A' .And. SZ2->Z2_FILIAL = '" + FWxFilial('SZ2')+"' )" , 	"BR_VERDE"   , 	"Aberta"   )
	oMark:AddLegend("( SZ2->Z2_STATUS == 'E' .And. SZ2->Z2_FILIAL = '" + FWxFilial('SZ2')+"' )" ,		"BR_VERMELHO", 	"Encerrada")
	oMark:AddLegend("( SZ2->Z2_STATUS == 'I' .And. SZ2->Z2_FILIAL = '" + FWxFilial('SZ2')+"' )" , 	"BR_AMARELO" , 	"Iniciada" )
	oMark:AddLegend("( SZ2->Z2_STATUS == 'B' .And. SZ2->Z2_FILIAL = '" + FWxFilial('SZ2')+"' )" , 	"BR_AZUL"    , 	"Bloqueada")

	// Adiciona botoes na janela
	oMark:AddButton("Liberar Marcados"  , { || FWMsgRun(, {|| U_LibMarc()}, "Processando Liberações", "Processando dados aguarde...")} , ,2,)
	oMark:AddButton("Bloquerar Marcados", { || FWMsgRun(, {|| U_BlqMarc()}, "Processando Bloqueios" , "Processando dados aguarde...")} , ,2,)
	oMark:AddButton("Legenda"	 		, "U_Z2Leg()"																				   , ,2,)

	// Define o filtro a ser aplicado no MarkBrowse
	lRet := _FilBrow(@cFiltro) 
	If lRet
		oMark:SetFilterDefault( cFiltro )
		oMark:AddFilter("GJF68AUT",cFiltro,.T.,.T.,"SZ2",.F.,{cFiltro,"EXPRESSION"},"1")
	Endif

	If lRet
		// Ativando a janela
		oMark:Activate()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaurando a condicao original						  			       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SZ2")
	RetIndex("SZ2")
	DbClearFilter()

	// Continua chamando os parâmetros da liberação automática até que seja clicado em CANCELAR
	If lRet
		U_Gjf68aut()
	EndIf

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} LibMarc
Função para liberar os registros que estão marcados
@author     Evandro Mugnol
@since      Set/2023
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function LibMarc()

	Local nCont	:= 0

	If MsgYesNo("Deseja efetuar a liberação das previsões de produção marcadas?","Continuar")
		// Percorrendo os registros da SZ2
		SZ2->(DbGoTop())
		While SZ2->(!EoF())

			If oMark:IsMark(oMark:Mark())	// Caso esteja marcado

				// Grava e limpa a marca
				If SZ2->Z2_STATUS != "E" .And. SZ2->Z2_STATUS != "I" .And. SZ2->Z2_STATUS != "A"
					RecLock("SZ2",.F.)
					If SZ2->Z2_QRPECA == 0
						SZ2->Z2_STATUS := "A"
					Else
						SZ2->Z2_STATUS := "I"
					EndIf
					SZ2->Z2_OK := ""
					MsUnlock()
				Else
					MsgBox("Status da previsão de produção número " + SZ2->Z2_NUM + " não permite essa operação!","OPERAÇÃO INVALIDA!","STOP")
				EndIf

				nCont++

			EndIf

			SZ2->(DbSkip())
		EndDo

		oMark:oBrowse:Refresh(.T.)

		// Mostrando a mensagem de registros marcados
		MsgInfo('Foram liberadas <b>' + cValToChar( nCont ) + ' previsões de produção </b>.', "Atenção")
	Else
		MsgAlert("Não foi processado nenhuma liberação devido ao cancelamento.")
	Endif	

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} BlqMarc
Função para bloquear os registros que estão marcados
@author     Evandro Mugnol
@since      Set/2023
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function BlqMarc()

	Local nCont	:= 0

	If MsgYesNo("Deseja efetuar o bloqueio das previsões de produção marcadas?","Continuar")
		// Percorrendo os registros da SZ2
		SZ2->(DbGoTop())
		While !SZ2->(EoF())

			If oMark:IsMark(oMark:Mark())	// Caso esteja marcado

				// Grava e limpa a marca
				If SZ2->Z2_STATUS != "B" .And. SZ2->Z2_STATUS != "E"
					RecLock("SZ2",.F.)
					SZ2->Z2_STATUS := "B"
					SZ2->Z2_OK 	   := ""
					SZ2->(MsUnlock())
				Else
					MsgBox("Status da previsão de produção número " + SZ2->Z2_NUM + "não permite essa operação!","OPERAÇÃO INVALIDA!","STOP")
				EndIf

				nCont++

			EndIf
			
			SZ2->(DbSkip())
		EndDo

		oMark:oBrowse:Refresh(.T.)

		// Mostrando a mensagem de registros marcados
		MsgInfo('Foram bloqueadas <b>' + cValToChar( nCont ) + ' previsões de produção </b>.', "Atenção")
	Else
		MsgAlert("Não foi processado nenhum bloqueio devido ao cancelamento.")
	Endif	

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} _FilBrow
Função para filtrar títulos a serem apresentados no browse
@author     Evandro Mugnol
@since      Set/2023
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function _FilBrow(cFiltro)

	Local lRet	 := .T.

	PRIVATE oDlg1	  := Nil
	PRIVATE oPanel    := Nil
	PRIVATE nOpca	  := 0
	PRIVATE dDtAbate  := dDataBase
	PRIVATE oRadioRac
	PRIVATE nRadioRac := 12
	PRIVATE oRadioRas
	PRIVATE nRadioRas := 8
	PRIVATE oRadioCor
	PRIVATE nRadioCor := 4
	PRIVATE oRadioTfc
	PRIVATE nRadioTfc := 4

	DEFAULT cFiltro := ""

	DEFINE MSDIALOG oDlg1 FROM 143,200 To 164, 270  TITLE OemToAnsi("Filtros Liberação/Bloqueio Automático")
	oDlg1:lMaximized := .F.

	oPanel := TPanel():New(0,0,'',oDlg1,, .T., .T.,, ,00,00)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 002,002 TO 120,278 PIXEL OF oPanel 

	@ 008,005 SAY OemToAnsi("=============================================================================")
	@ 064,005 SAY OemToAnsi("===========")
			
	@ 004,005 SAY OemToAnsi("Data Abate") 												SIZE 40,08 	PIXEL OF oPanel
	@ 014,005 MSGET dDtAbate 															SIZE 50,08  PIXEL OF oPanel HASBUTTON

	@ 060,005 SAY OemToAnsi("Class. Destino") 											SIZE 50,08 			PIXEL OF oPanel
	@ 069,005 RADIO oRadioTfc VAR nRadioTfc ITEMS "TF","Salga","Conserva"				SIZE 50,09 When .T. PIXEL OF oPanel

	@ 004,070 SAY OemToAnsi("Raça") 																																SIZE 40,08 	PIXEL OF oPanel
	@ 013,070 RADIO oRadioRac VAR nRadioRac ITEMS "ANGUS","ANGUS NJ","HEREFORD","HEREFORD NJ","NOVILHO","8 DENTES","BLACK","TOURUNO","TOURO","MAGRO","CZ LEITE"  	SIZE 50,09 When .T. PIXEL OF oPanel

	@ 004,150 SAY OemToAnsi("Rastreabilidade") 											SIZE 40,08 	  		PIXEL OF oPanel
	@ 013,150 RADIO oRadioRas VAR nRadioRas ITEMS "BR","CN","HK","LG","NE","RT","USA"  	SIZE 50,09 When .T. PIXEL OF oPanel

	@ 004,220 SAY OemToAnsi("Corte Origem") 											SIZE 40,08 	  		PIXEL OF oPanel
	@ 013,220 RADIO oRadioCor VAR nRadioCor ITEMS "Traseiro","Dianteiro","Costela"  	SIZE 50,09 When .T. PIXEL OF oPanel

	DEFINE SBUTTON FROM 128, 120 TYPE 1 ACTION (nOpca := 1,If(_FilTdOk(),oDlg1:End(),nOpca:=0)) ENABLE OF oDlg1
	DEFINE SBUTTON FROM 128, 150 TYPE 2 ACTION oDlg1:End() ENABLE OF oDlg1

	ACTIVATE MSDIALOG oDlg1 CENTERED

	If nOpca == 0
		lRet := .F.
	Else
		Do CASE
			CASE nRadioCor == 1
				_cCorori := "T"
			CASE nRadioCor == 2
				_cCorori := "D"
			CASE nRadioCor == 3
				_cCorori := "C"
			OTHERWISE
				_cCorori := ""
		ENDCASE

		DO CASE
			CASE nRadioTfc == 1
				cFiltro := "Z2_FILIAL == '" + FWxFilial('SZ2') + "' .AND. " 
				cFiltro += "DTOS(Z2_DATAABT) == '" + DTOS(dDtAbate) + "' .AND. "
				cFiltro += "Substr(Z2_SELTFCS, " + cValToChar(nRadioTfc) + ", 1) == 'S'"
			CASE nRadioTfc == 2
				cFiltro := "Z2_FILIAL == '" + FWxFilial('SZ2') + "' .AND. " 
				cFiltro += "DTOS(Z2_DATAABT) == '" + DTOS(dDtAbate) + "' .AND. "
				cFiltro += "Substr(Z2_SELTFCS, " + cValToChar(nRadioTfc) + ", 1) == 'S'"
			CASE nRadioTfc == 3
				cFiltro := "Z2_FILIAL == '" + FWxFilial('SZ2') + "' .AND. " 
				cFiltro += "DTOS(Z2_DATAABT) == '" + DTOS(dDtAbate) + "' .AND. "
				cFiltro += "Substr(Z2_SELTFCS, " + cValToChar(nRadioTfc) + ", 1) == 'S'"
			CASE !Empty(dDtAbate) .And. nRadioRac <> 12 .And. nRadioRas <> 8 .And. nRadioCor <> 4
				cFiltro := "Z2_FILIAL == '" + FWxFilial('SZ2') + "' .AND. " 
				cFiltro += "DTOS(Z2_DATAABT) == '" + DTOS(dDtAbate) + "' .AND. "
				cFiltro += "Substr(Z2_SELRACA, " + cValToChar(nRadioRac) + ", 1) == 'S' .AND. "
				cFiltro += "Substr(Z2_SELRAST, " + cValToChar(nRadioRas) + ", 1) == 'S' .AND. "
				cFiltro += "Z2_CORORI == '" + _cCorori + "'"
		ENDCASE
	EndIf

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} _FilTdOk
Função para validar os gets da tela inicial do browse
@author     Evandro Mugnol
@since      Set/2023
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function _FilTdOk()

	Local lRet := .T.

	cFiltro	:= ""

	// Valida todos os gets
	If nRadioTfc <> 4 .And. (nRadioRac == 12 .Or. nRadioRas == 8 .Or. nRadioCor == 4)
		MsgAlert("Não é permitido informar 'Class. Destino' e demais parâmetros de filtragem ao mesmo tempo. Verifique!")
		lRet := .F.
		oDlg1:End()
		_FilBrow(cFiltro)
	EndIf

	If lRet
		If Empty(dDtAbate) .Or. nRadioRac == 12 .Or. nRadioRas == 8 .Or. nRadioCor == 4
			MsgAlert("É obrigatório informar todos parâmetros de filtragem. Verifique!")
			lRet := .F.
		EndIf 
	EndIf

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} Z2Leg
Função para mostrar a legenda
@author     Evandro Mugnol
@since      Set/2023
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function Z2Leg()

	Local aLegenda := {}

	// Monta as cores
	AADD(aLegenda,{"BR_VERDE"	,  	"Aberta" 	})
	AADD(aLegenda,{"BR_VERMELHO", 	"Encerrada" })
	AADD(aLegenda,{"BR_AMARELO"	,  	"Iniciada" 	})
	AADD(aLegenda,{"BR_AZUL"	, 	"Bloqueada" })

	BrwLegenda("Seleção das Previsões de Produção", "Status", aLegenda)

Return
