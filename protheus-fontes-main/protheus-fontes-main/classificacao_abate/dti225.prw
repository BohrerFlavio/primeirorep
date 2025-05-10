#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI225  º Autor ³ Adonai Gabriel       º Data ³  15/04/25  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍLÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Incluir, alterar e excluir lotes de brincos de animais     º±±
±±º          ³ que serão abatidos, para rastreabilidade exigida pela UE.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI225()

	Private lInverte := .f.
	Private cMark    := GetMark()
	Private oMark
	Private aRotina  := {}
	Private aObjects := {}
	Private aPosObj  := {}
	Private aInfo    := {}
	Private aSizeAut := MsAdvSize()

	AAdd(aObjects, {315, 50, .T., .T.})
	AAdd(aObjects, {100, 100, .T., .T.})
	aInfo   := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3}
	aPosObj := MsObjSize(aInfo, aObjects, .T.)

	aX           := aPosObj[1]
	aX[3]        += 60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	aRotina := {{ "Pesquisar" ,"AxPesqui"  , 0, 1,},;	// "Pesquisar"
				{ "Visualizar","u_DTI225v" , 0, 2,},;	// "Visualizar"
				{ "Incluir"   ,"u_DTI225i" , 0, 3,},;	// "Incluir"
				{ "Alterar"   ,"u_DTI225a" , 0, 4,},;	// "Alterar"
				{ "Excluir"   ,"u_DTI225e" , 0, 5,}}    // "Excluir"

	cString := "ZRT"
	cCadastro := 'Cadastro de Brincos'

	dbSelectArea("ZRT")
	dbSetOrder(2)
	mBrowse(6,1,22,75,cString)

Return

//Função de inclusão de Brincos
User Function DTI225I(cAlias,nReg,nOpc)

    Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {}

	//AADD(aButtons, { 'FORM'   ,{||u_DTI225sld() , oDlg:Refresh() },'Consulta Saldo','Saldo'})

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	_cbrinco := getSx8Num('ZRT','ZRT_NUM')
	nUsado := DTI225Ahead("ZRI")
	DTI225Acols(nOpc)

	RegToMemory("ZRT",.T.)

	M->ZRT_NUM := _cbrinco

	oEnc := MsMGet():New("ZRT",ZRT->(RECNO()),nOpc,,,,,aPosObj[1],,3,,,,oDlg,,,.F.)
	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"u_DTI225LinOk(n,'I')","u_DTI225TudOk","+ZRI_ITEM",.T.,,,.F.,999,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_DTI225TudOk().and.Obrigatorio(aGets,aTela).and.u_DTI225LinOk(n,'I'),Iif(lOk,oDlg:End(),)},{||oDlg:End()},,aButtons)

	If  lOk
		if FWAlertYesNo("Conferiu tempo na propriedade e em área habilitada para a UE?","CONFIRMA")
			ConfirmSx8()
			DTI225Grav(nOpc)
		else
			RollBackSX8()
		endif
	else
		RollBackSX8()
	Endif

Return

//Função de alteração de Brincos
User Function DTI225A(cAlias,nReg,nOpc)

	Local oDlg		    := NIL
	Local lOk 		    := .F.
	Local aButtons	    := {}
	Private aHeader	    := {}
	Private aCols	    := {}
	Private nUsado	    :=	0
	Private oGet	    := NIL
	Private aGets	    := {}
	Private aTela	    := {}

	DbSelectArea(cAlias)

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := DTI225Ahead("ZRI")                                                 //Monta o aHeader

	DTI225Acols(nOpc)                                                            //Monta o Acols

	RegtoMemory('ZRT')

	oEnc := MsMGet():New("ZRT",ZRT->(RECNO()),nOpc,,,,,aPosObj[1],,3,,,,oDlg,,,.F.)
	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"u_DTI225LinOk(n,'A')","u_DTI225TudOk","+ZRI_ITEM",.T.,,,.F.,999,,,,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_DTI225TudOk().and.u_DTI225LinOk(n,'A').and.Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(), oDlg:refresh())}, {||oDlg:End()}, , aButtons)

	If lOk
		if FWAlertYesNo("Tem certeza das informações inseridas?","CONFIRMA")
			DTI225Grav(nOpc)
		endif
	Endif

Return

//Função de visualização de Brincos
User Function DTI225V(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZRT")

	DTI225Ahead("ZRI")                                                           //Monta oa vetor aHeader

	nUsado := Len(aHeader)

	DTI225Acols(nOpc)															//Monta oa vetor aCols

	oEnc := MsMGet():New("ZRT",ZRT->(RECNO()),nOpc,,,,,aPosObj[1],,3,,,,oDlg,,,.F.)
	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","+ZRI_ITEM",.T.,,,.F.,999,,,,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, , aButtons)

Return

//Exclusão de brinco
User Function DTI225E(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	DbSelectArea(cAlias)

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("ZRT")

	EnChoice( "ZRT" ,ZRT->(RECNO()), nOpc, , , , , aPosObj[1], , 3 )
	DTI225Ahead("ZRI")
	nUsado	:= Len(aHeader)                                                           //Monta o aHeader
	DTI225Acols(nOpc)                                                                 //Monta o Acols

	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","+ZRI_ITEM",.T.,,,.F.,999,,,,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||DTI225Dele(),oDlg:End()},{||oDlg:End()}, , aButtons)

Return

//Exclusão dos Brincos
Static Function DTI225Dele()

	DbSelectArea("ZRI")
	DbSetOrder(1)
	MsSeek(FWxFilial("ZRI") + ZRT->ZRT_NUM)

	Do While ZRI->(!Eof()) .and. FWxFilial("ZRI") == ZRI->ZRI_FILIAL .AND. ZRT->ZRT_NUM == ZRI->ZRI_NUM  // Exclui os itens do brinco
		RecLock("ZRI",.f.)
		DbDelete()
		MsUnLock()
		ZRI->(DbSkip())
	Enddo

	DbSelectArea("ZRT")
	RecLock("ZRT",.f.)
	DbDelete()
	MsUnLock()

Return

//Montagem do aCols
static Function DTI225Acols(nOpc)
	Local nI, nPos

	If nOpc == 3

		aCols := Array(1,nUsado+1)

		For nI = 1 To Len(aHeader)
			If aHeader[nI,8] == "C"
				aCols[1,nI] := Space(aHeader[nI,4])
			ElseIf aHeader[nI,8] == "N"
				aCols[1,nI] := 0
			ElseIf aHeader[nI,8] == "D"
				aCols[1,nI] := CtoD(" / / ")
			ElseIf aHeader[nI,8] == "M"
				aCols[1,nI] := ""
			Else
				aCols[1,nI] := .F.
			EndIf
		Next nI

		aCols[1,nUsado+1] := .F.
	Else

		RegToMemory("ZRT")

		dbSelectArea("ZRI")
		dbSetOrder(1)
		MsSeek(FWxFilial('ZRI')+ZRT->ZRT_NUM)

		Do While ZRI->(!Eof()) .and. FWxFilial('ZRI') ==  ZRI->ZRI_FILIAL .and. ZRI->ZRI_NUM == ZRT->ZRT_NUM
			aAdd(aCols,Array(nUsado+1))

			For nI := 1 to nUsado
				If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Else										// Campo Virtual
					cCpo := AllTrim(Upper(aHeader[nI,2]))
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Endif
			Next nI

			nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZRI_ITEM" })
            if nPos > 0
                aCols[1,nPos]	:= StrZero(len(acols)+1,Len(aCols[1,nPos]))
            endif
            aCols[Len(aCols),nUsado+1] := .F.

			ZRI->(DbSkip())
		Enddo

	Endif

Return

//Monta o aHeader
Static Function DTI225Ahead(cAlias)

	Local i
	aHeader := {}

	_cAlias  := cAlias 		// ZRI
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i],'X3_USADO')) .And. AllTrim(GetSx3Cache(_aCpoSX3[i],'X3_CAMPO')) != "ZRI_FILIAL" .And. AllTrim(GetSx3Cache(_aCpoSX3[i],'X3_CAMPO')) != "ZRI_NUM")
			aAdd(aHeader, { GetSx3Cache(_aCpoSX3[i], 'X3_TITULO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_PICTURE')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_TAMANHO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_DECIMAL')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_VALID')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_USADO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_TIPO')		,;
							GetSx3Cache(_aCpoSX3[i], 'X3_ARQUIVO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_CONTEXT')	})
		Endif
	Next i

Return len(aHeader)

//Grava cabecalho e itens
Static Function DTI225Grav(nOpc)

	Local nIt
	Local nCont
    Local nNumItem
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                              // Indica se todas as gravacoes obtiveram sucesso

	Begin Transaction

		DbSelectArea("ZRT")
		DbSetOrder(2)
		If INCLUI
			//Se a opção foi de incluir registros, faz isso
			RecLock("ZRT",.T.)
		Else
			RecLock("ZRT",.F.)
		Endif

		For nCont := 1 To FCount()

			If "FILIAL"$Field(nCont)
				FieldPut(nCont,FWxFilial("ZRT"))
			Else
				FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
			Endif

		Next nCont

		MsUnLock()

		/*if ZRT->ZRT_MODELO = 'B'
			SZ4->(DbSetOrder(1))
			if SZ4->(MsSeek(FWxFilial("ZRI") + ZRT->ZRT_NUMAM + ZRT->ZRT_LOTE))
				RecLock("SZ4",.F.)
					SZ4->Z4_CLASSIF := "HK"
				MsUnlock()
			endif
		endif*/

		DbSelectArea("ZRI")
		DbSetOrder(1)
        nNumItem := 1  // Contador para os Itens

		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				If MsSeek(FWxFilial("ZRI") + M->ZRT_NUM + StrZero(nIt,3))
					RecLock("ZRI",.F.)
					DbDelete()
					MsUnlock()
				Endif
			Endif
		Next

		For nIt := 1 To Len(aCols)

			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				If ALTERA
					If MsSeek(FWxFilial("ZRI")+ M->ZRT_NUM + StrZero(nIt,3))
						RecLock("ZRI",.F.)
					Else
						RecLock("ZRI",.T.)
					Endif
				Else
					RecLock("ZRI",.T.)
				Endif

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"
						ZRI->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				ZRI->ZRI_FILIAL	 := FWxFilial("ZRI")
				ZRI->ZRI_NUM	 := ZRT->ZRT_NUM                           //Atribui o numero do brinco ao item
                ZRI->ZRI_ITEM    := strzero(nNumItem,3)

                nNumItem++
				MsUnlock()
			Endif
		Next nIt

	End Transaction

Return lGraOk

//Testa todo aCols
User Function DTI225TudOk()

	Local lRetorno	:= .T.
	Local nTot		:= 0
	Local nX
	Local nI

	If Empty(M->ZRT_NUM) .or. nTot == Len(aCols)
		lRetorno := .F.
		FWAlertWarning("Campo obrigatório não preenchido!","ALERTA!")
	EndIf

	If INCLUI
		DbSelectArea("ZRT")
		DbSetOrder(1)
		If ZRT->(MsSeek(FWXFILIAL("ZRT") + M->ZRT_NUMAM + M->ZRT_LOTE))
			lRetorno := .F.
			FWAlertWarning("Lote já cadastrado!","ALERTA!")
		Endif
	Endif

	_nTam := Len(aCols)

	for nX := 1 To _nTam
		_ColCod := GDFieldGet('ZRI_BRINCO',nX)
		For nI := 1 To _nTam
			if (GDFieldGet('ZRI_BRINCO',nI) = _ColCod) .and. (nI <> nX)
				FWAlertError('Brincos repetidos!','ERRO!')
				lRetorno := .F.
				exit
			endif
		Next nI
	Next nX

Return lRetorno

//Teste de validação da linha do grid
User Function DTI225LinOk(n,op)

	Local lRetorno 	:= .T.
	Local nPosDel 	:= Len(aHeader) + 1
	Local nCpo
	Local nI
	Local nX

	if lRetorno
		lRetorno := .F.
		If !aCols[n, nPosDel]                                                  // Verifica se o item foi deletado
			For nCpo := 2 To Len(aHeader)                                      // Ignora o  Item
				If !Empty(aCols[n, nCpo]) .and. ValType(aCols[n, nCpo]) <> "D"
					lRetorno := .T.
				Endif
			Next nCpo
		Else
			lRetorno := .T.
		Endif
	endif

	if lRetorno
		_nTam := Len(aCols)

		for nX := 1 To _nTam
			_ColCod := aCols[nX,1]
			For nI := 1 To _nTam
				if (aCols[nI,1] = _ColCod) .and. (nI <> nX) .and. !aCols[nX, nPosDel] .and. !aCols[nI, nPosDel]
					FWAlertError('Brincos repetidos! ('+ _ColCod + ')','ERRO!')
					lRetorno := .f.
					exit
				endif
			Next nI
		Next nX
	endif

	if lRetorno
        if empty(aCols[n,1])
            FWAlertWarning('Produto não informado!','OPERAÇÃO IRREGULAR!')
            lRetorno := .F.
        endif
	endif

Return lRetorno
