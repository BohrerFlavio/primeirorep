#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI217  º Autor ³ Adonai Gabriel       º Data ³  31/10/24  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍLÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Incluir, alterar e excluir subgrupos de produtos, que     º±±
±±º          ³ serão usados para consumo de matéria prima, inicialmente.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI217()

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
				{ "Visualizar","u_dti217v" , 0, 2,},;	// "Visualizar"
				{ "Incluir"   ,"u_dti217i" , 0, 3,},;	// "Incluir"
				{ "Alterar"   ,"u_dti217a" , 0, 4,},;	// "Alterar"
				{ "Excluir"   ,"u_dti217e" , 0, 5,}}    // "Excluir"

	cString := "ZG0"
	cCadastro := 'Subgrupos de produtos'

	dbSelectArea("ZG0")
	dbSetOrder(1)
	mBrowse(6,1,22,75,cString)

Return

//Função de inclusão de subgrupos
User Function DTI217I(cAlias,nReg,nOpc)

    Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {}

	//AADD(aButtons, { 'FORM'   ,{||u_DTI217sld() , oDlg:Refresh() },'Consulta Saldo','Saldo'})

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	_cSubGrupo := getSx8Num('ZG0','ZG0_NUM')
	nUsado := DTI217Ahead("ZG1")
	DTI217Acols(nOpc)

	RegToMemory("ZG0",.T.)

	M->ZG0_NUM := _cSubGrupo

	oEnc := MsMGet():New("ZG0",ZG0->(RECNO()),nOpc,,,,,aPosObj[1],,3,,,,oDlg,,,.F.)
	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"u_DTI217LinOk(n,'I')","u_DTI217TudOk","+ZG1_ITEM",.T.,,,.F.,999,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_DTI217TudOk().and.Obrigatorio(aGets,aTela).and.u_DTI217LinOk(n,'I'),Iif(lOk,oDlg:End(),)},{||oDlg:End()},,aButtons)

	If  lOk
		ConfirmSx8()
		DTI217Grav(nOpc)
	else
		RollBackSX8()
	Endif

Return

//Função de alteração de subgrupos
User Function DTI217A(cAlias,nReg,nOpc)

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

	//AADD(aButtons, { 'FORM'   ,{||u_DTI217sld() , oDlg:Refresh() }, 'Consulta Saldo' , 'Saldo'  } )

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := DTI217Ahead("ZG1")                                                 //Monta o aHeader

	DTI217Acols(nOpc)                                                            //Monta o Acols

	RegtoMemory('ZG0')

	oEnc := MsMGet():New("ZG0",ZG0->(RECNO()),nOpc,,,,,aPosObj[1],,3,,,,oDlg,,,.F.)
	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"u_DTI217LinOk(n,'A')","u_DTI217TudOk","+ZG1_ITEM",.T.,,,.F.,999,,,,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_DTI217TudOk().and.u_DTI217LinOk(n,'A').and.Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(), oDlg:refresh())}, {||oDlg:End()}, , aButtons)

	If lOk
		DTI217Grav(nOpc)
	Endif

Return

//Função de visualização de subgrupos
User Function DTI217V(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZG0")

	DTI217Ahead("ZG1")                                                           //Monta oa vetor aHeader

	nUsado := Len(aHeader)

	DTI217Acols(nOpc)															//Monta oa vetor aCols

	oEnc := MsMGet():New("ZG0" ,ZG0->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","+ZG1_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, , aButtons)

Return

//Exclusão de subgrupo
User Function DTI217E(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	DbSelectArea(cAlias)

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("ZG0")

	EnChoice( "ZG0" ,ZG0->(RECNO()), nOpc, , , , , aPosObj[1], , 3 )
	DTI217Ahead("ZG1")
	nUsado	:= Len(aHeader)                                                           //Monta o aHeader
	DTI217Acols(nOpc)                                                                 //Monta o Acols

	oGet:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","+ZG1_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||DTI217Dele(),oDlg:End()},{||oDlg:End()}, , aButtons)

Return

//Exclusão dos subgrupos
Static Function DTI217Dele()

	DbSelectArea("ZG1")
	ZG1->(DbSetOrder(1))
	MsSeek(FWxFilial("ZG1") + ZG0->ZG0_NUM,.t.)

	Do While ZG1->(!Eof()) .and. FWxFilial("ZG1") == ZG1->ZG1_FILIAL .AND. ZG0->ZG0_NUM == ZG1->ZG1_NUM  // Exclui os itens do subgrupo
		RecLock("ZG1",.f.)
		DbDelete()
		MsUnLock()
		ZG1->(DbSkip())
	Enddo

	DbSelectArea("ZG0")
	RecLock("ZG0",.f.)
	DbDelete()
	MsUnLock()

Return

//Montagem do aCols
static Function DTI217Acols(nOpc)
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

		RegToMemory("ZG0")

		dbSelectArea("ZG1")
		dbSetOrder(1)
		MsSeek(FWxFilial('ZG1')+ZG0->ZG0_NUM,.T.)

		Do While ZG1->(!Eof()) .and. FWxFilial('ZG1') ==  ZG1->ZG1_FILIAL .and. ZG1->ZG1_NUM == ZG0->ZG0_NUM
			aAdd(aCols,Array(nUsado+1))

			For nI := 1 to nUsado
				If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Else										// Campo Virtual
					cCpo := AllTrim(Upper(aHeader[nI,2]))
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Endif
			Next nI

			nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZG1_ITEM" })
            if nPos > 0
                aCols[1,nPos]	:= StrZero(len(acols)+1,Len(aCols[1,nPos]))
            endif
            aCols[Len(aCols),nUsado+1] := .F.

			ZG1->(DbSkip())
		Enddo

	Endif

Return

//Monta o aHeader
Static Function DTI217Ahead(cAlias)

	Local i
	aHeader := {}

	_cAlias  := cAlias 		// ZG1
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i],'X3_USADO')) .And. AllTrim(GetSx3Cache(_aCpoSX3[i],'X3_CAMPO')) != "ZG1_FILIAL" .And. AllTrim(GetSx3Cache(_aCpoSX3[i],'X3_CAMPO')) != "ZG1_NUM")
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
Static Function DTI217Grav(nOpc)

	Local nIt
	Local nCont
    Local nNumItem
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                              // Indica se todas as gravacoes obtiveram sucesso

	Begin Transaction

		DbSelectArea("ZG0")
		DbSetOrder(1)
		If INCLUI
			//Se a opção foi de incluir registros, faz isso
			RecLock("ZG0",.T.)
		Else
			RecLock("ZG0",.F.)
		Endif

		For nCont := 1 To FCount()

			If "FILIAL"$Field(nCont)
				FieldPut(nCont,FWxFilial("ZG0"))
			Else
				FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
			Endif

		Next nCont

		MsUnLock()

		DbSelectArea("ZG1")
		DbSetOrder(1)
        nNumItem := 1  // Contador para os Itens

		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				If MsSeek(FWxFilial("ZG1") + M->ZG0_NUM + StrZero(nIt,3))
					RecLock("ZG1",.F.)
					DbDelete()
					MsUnlock()
				Endif
			Endif
		Next

		For nIt := 1 To Len(aCols)

			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				If ALTERA
					If MsSeek(FWxFilial("ZG1")+ M->ZG0_NUM + StrZero(nIt,3))
						RecLock("ZG1",.F.)
					Else
						RecLock("ZG1",.T.)
					Endif
				Else
					RecLock("ZG1",.T.)
				Endif

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"
						ZG1->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				ZG1->ZG1_FILIAL	 := FWxFilial("ZG1")
				ZG1->ZG1_NUM	 := ZG0->ZG0_NUM                           //Atribui o numero do subgrupo ao item
                ZG1->ZG1_ITEM    := strzero(nNumItem,3)

				if ALTERA
					ZG1->ZG1_USERAL := cUserName							//Grava o nome do usuario
					ZG1->ZG1_DATAAL := DATE()
					ZG1->ZG1_HORAAL := TIME()
				else
					ZG1->ZG1_USERIN  := cUserName							//Grava o nome do usuario
					ZG1->ZG1_DATAAL := DATE()
					ZG1->ZG1_HORAAL := TIME()
				endif
                nNumItem++
				MsUnlock()
			Endif
		Next nIt

	End Transaction

Return lGraOk

//Testa todo aCols
User Function DTI217TudOk()

	Local lRetorno	:= .T.
	Local nTot		:= 0
	Local nX
	Local nI

	If Empty(M->ZG0_NUM) .or. nTot == Len(aCols)
		lRetorno := .F.
		FWAlertWarning("Campo obrigatório não preenchido!","ALERTA!")  // Campos obrigatorios
	EndIf

	If INCLUI
		If ZG0->(MsSeek(FWXFILIAL("ZG0") + M->ZG0_NUM))
			lRetorno := .F.
			FWAlertWarning("Subgrupo já existe!",1,"ALERTA!")  // Campo ja Existe
		Endif
	Endif

	_nTam := Len(aCols)

	for nX := 1 To _nTam
		_ColCod := GDFieldGet('ZG1_COD',nX)
		For nI := 1 To _nTam
			if (GDFieldGet('ZG1_COD',nI) = _ColCod) .and. (nI <> nX)
				FWAlertError('Produtos do subgrupo repetidos!','ERRO!')
				lRetorno := .F.
				exit
			endif
		Next nI
	Next nX

Return lRetorno

//Teste de validação da linha do grid
User Function DTI217LinOk(n,op)

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
					FWAlertError('Produtos do subgrupo repetidos! ('+ _ColCod + ')','ERRO!')
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
