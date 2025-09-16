#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DTI42    ³ Mauricio Roehrs           ³ Data ³ 30/08/17     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Correlação de Produtos alternativos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAOMS/Comercial                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI42()

	Private aCores      := {}
	Private aCores2     := {}
	Private aRotina     := {}
	Private cCondicao   := ''
	Private _cUser      := alltrim(RetCodUsr())
	IndSZX              := {}
	aObjects            := {}
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           := aPosObj[1]
	aX[3]        += 10
	aPosObj[1]   := aX
	aPosObj[2,1] += 10


	aRotina := {{ "Pesquisa",  "AxPesqui"  , 	0, 1},; 	     //"Pesquisar"
	{ "Visualizar", "u_dti42Visu", 	0, 2},;	 //"Visualizar"
	{ "Incluir",    "u_dti42Incl", 	0, 3},;	 //"Incluir"
	{ "Alterar",    "u_dti42Alte", 	0, 4},;	 //"Alterar"
	{ "Excluir",    "u_dti42Excl", 	0, 5},;  //"Excluir"
	{ "Legenda",    "u_dti42Leg" , 	0, 1}}   //"Legenda"

	Private cCadastro 	:= "Correlação de Prod. Alternativos"


	cCondicao := "B1_FILIAL = '" + xFilial('SB1') + "' AND B1_TIPO = 'PA' AND B1_MSBLQL = '2'"//String para filtro
	//Aplicação da filtragem

	mBrowse(6,1,22,75,"SB1", ,,,,2    ,aCores,,,,{|x| AutoRefresh(x)},,,,cCondicao)


	dbclosearea('SB1')

Return

//Disponibiliza a legenda
User Function dti42Leg(cAlias,nReg,nOpc)
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return

//Visualiza os produtos alternativos
User Function dti42Visu(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	area := GetArea()

	RegToMemory("SB1")

	verificaProd()

	if TMP->ACHOU = 0
		alert('Não há lançamentos para este produto!')
		return
	endif


	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL


	dti42Ahead("ZAL")                                                           //Monta oa vetor aHeader


	nUsado := Len(aHeader)

	dti42Acols(nOpc)															//Monta oa vetor aCols

	oEnc    := MsMGet():New("SB1" ,SB1->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZAL_COD",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, )

	DbSelectArea('SB1')

	RestArea(area)

Return

//Incluir produtos alternativos
User Function dti42Incl(cAlias,nReg,nOpc)
	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {}


	area := GetArea()

	RegtoMemory('SB1')

	verificaProd()

	if TMP->ACHOU > 0
		alert('Já existem lançamentos para este produto!')
		return
	endif

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL


	nUsado := dti42Ahead("ZAL")
	dti42Acols(nOpc)

	oEnc := MsMGet():New("SB1" ,SB1->(RECNO()), 2,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_dti42LinOk(n,'I')","u_dti42TudOk","",.T., , ,.F. , 20,,)


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_dti42TudOk() .and. u_dti42LinOk(n,'I'), ;
	Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

	If  lOk
		dti42Grav(nOpc)
	Endif

	DbSelectArea('SB1')
	RestArea(area)
Return

//Alteração dos produtos alternativos
User Function dti42Alte(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aCposAlt	:= {}
	Local aButtons	:= {}
	Local _cCodigo := ''
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {}

	DbSelectArea(cAlias)

	area := GetArea()


	RegtoMemory('SB1')

	verificaProd()

	if TMP->ACHOU = 0
		alert('Não há lançamentos para este produto!')
		return
	endif


	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := dti42Ahead("ZAL")                                                 //Monta o aHeader

	dti42Acols(nOpc)                                                            //Monta o Acols


	oEnc := MsMGet():New("SB1" ,SB1->(RECNO()), 2,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_dti42LinOk(n,'A')","u_dti42TudOk","",.T., , ,.F. ,20 ,,,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_dti42TudOk().and.u_dti42LinOk(n,'A');
	,Iif(lOk,oDlg:End(), odlg:refresh())}, {||oDlg:End()}, , aButtons)

	If lOk
		dti42Grav(nOpc)
	Endif

	DbSelectArea('SB1')
	RestArea(area)

Return


//Exclusão dos produtos alternativos
User Function dti42Excl(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL


	DbSelectArea(cAlias)
	area := GetArea()

	RegToMemory("SB1")

	verificaProd()

	if TMP->ACHOU = 0
		alert('Não há lançamentos para este produto!')
		return
	endif

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL


	EnChoice( "SB1" ,SB1->(RECNO()), 2, , , , , aPosObj[1], , 3 )
	dti42Ahead("ZAL")


	nUsado	:= Len(aHeader)                                                           //Monta o aHeader

	dti42Acols(nOpc)                                                                  //Monta o Acols

	oGet:= MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||dti42Dele(),oDlg:End()},{||oDlg:End()},)

	DbSelectArea('SB1')
	RestArea(area)

Return


//Montagem do aCols
static Function dti42Acols(nOpc)
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

		//	nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZAL_DATA" })
		//	if nPos > 0
		//		aCols[1,nPos]	:= stod("")
		//	endif
		aCols[1,nUsado+1] := .F.
	Else

		RegToMemory("SB1")

		dbSelectArea("ZAL")
		ZAL->(dbsetorder(1))
		ZAL->(dbGoTop())
		if ZAL->(dbSeek(xfilial('ZAL') + padr(alltrim(M->B1_COD),14,"")))
			While ZAL->(!Eof()) .and. xFilial('ZAL') == ZAL->ZAL_FILIAL .and. padr(alltrim(ZAL->ZAL_COD),14,"") == padr(alltrim(M->B1_COD),14,"")

				aAdd(aCols,Array(nUsado+1))

				For nI := 1 to nUsado
					If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
						aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
					Else										// Campo Virtual
						cCpo := AllTrim(Upper(aHeader[nI,2]))
						aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
					Endif
				Next nI

				aCols[Len(aCols),nUsado+1] := .F.

				ZAL->(DbSkip())
			Enddo
		endif
	Endif

Return

//Monta oa aHeader
Static Function dti42Ahead(cAlias)

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//DbSeek(cAlias)
	//Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	//	If 	at(Upper(AllTrim(X3_CAMPO)), "ZAL_FILIAL ZAL_COD") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := cAlias			// ZAL
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 				.And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZAL_FILIAL" .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZAL_COD")

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

//Grava os produtos alternativos
Static Function dti42Grav(nOpc)

	Local nIt
	Local nCont
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                                       	// Indica se todas as gravacoes obtiveram sucesso


	Begin Transaction


		ZAL->(DbGoTop())
		ZAL->(dbSetOrder(1))

		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				//NUMERO
				If ZAL->(DbSeek(xFilial("ZAL") + padr(alltrim(M->B1_COD),14,"") + padr(alltrim(aCols[nIt,1]),14,"")))

					//Função que cancela as reservas de caixas
					//quando um item de um pre-pedido é excluído

					RecLock("ZAL",.F.)
					DbDelete()
					MsUnlock()
				Endif
			Endif
		Next nIt


		For nIt := 1 To Len(aCols)

			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

				If ZAL->(DbSeek(xFilial('ZAL') + padr(alltrim(M->B1_COD),14,"") + padr(alltrim(aCols[nIt,1]),14,"")))
					RecLock("ZAL",.F.)
				Else
					RecLock("ZAL",.T.)
				Endif

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"
						ZAL->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				ZAL->ZAL_FILIAL := xFilial('ZAL')
				ZAL->ZAL_COD    := alltrim(M->B1_COD)

				MsUnlock()
			Endif

		Next nIt


	End Transaction

Return lGraOk

//Exclusão dos produtos alternativos
Static Function dti42Dele()


	dbSelectArea("ZAL")
	ZAL->(dbsetorder(1))
	ZAL->(dbGoTop())
	if ZAL->(dbSeek(xfilial('ZAL') + padr(alltrim(M->B1_COD),14,"")))

		While ZAL->(!Eof()) .and. xFilial('ZAL') == ZAL->ZAL_FILIAL .and. padr(alltrim(ZAL->ZAL_COD),14,"") = padr(alltrim(M->B1_COD),14,"")

			reclock('ZAL',.f.)
			dbDelete()
			msunlock()

			ZAL->(dbSkip())
		enddo
	endif


Return

//Teste de validação da linha do grid
User Function dti42LinOk(n,op)

	Local lRetorno 	:= .F.
	Local nPosDel 	:= Len(aHeader) + 1
	Local nCpo
	Local nX
	Local nI

	If !aCols[n, nPosDel]                                                  // Verifica se o item foi deletado
		For nCpo := 2 To Len(aHeader)                                      // Ignora o  Item
			If !Empty(aCols[n, nCpo]) .and. ValType(aCols[n, nCpo]) <> "D"
				lRetorno := .T.
			Endif
		Next nCpo
	Else
		lRetorno := .T.
	Endif

	if lRetorno
		//FAZ VALIDAÇÃO DAS LINHAS

		_nTam := Len(aCols)

		for nX := 1 To _nTam
			_ColCod := aCols[nX,1]
			For nI := 1 To _nTam
				if (aCols[nI,1] = _ColCod) .and. (nI <> nX) .and. !aCols[nX, nPosDel] .and. !aCols[nI, nPosDel]
					alert('Produtos repetidos!')
					lRetorno := .f.
					exit
				endif
			Next nI

		Next nX

	endif

Return lRetorno


//Testa todo aCols
User Function dti42TudOk()

	Local lRetorno	:= .T.
	Local nIt 		:= 0
	Local nTot		:= 0
	Local nPosDel  	:= Len(aHeader) + 1
	Local nX

	_nTam := Len(aCols)

	for nX := 1 To _nTam

		//	_dData   := GDFieldGet('ZAL_DATA',nX)

		//	if empty(_dData) .or. empty(_cHora) .or. empty(_cCodRef) .or. empty(_cTpRef)
		//		msgbox('Campos em branco!','OPERAÇÃO INVÁLIDA!','STOP')
		//		lRetorno := .F.
		//		exit
		//  	endif



	Next nX

Return lRetorno



////Funções para atualização do mBrowse////
Static Function AutoRefresh(oDlg)
	Local oTimer
	oTimer := TTimer():New(2, {|| PBrow() }, oDlg)
	oTimer:Activate()
Return .T.

////Funções para atualização do mBrowse////
Static Function PBrow()
	oBrowse := getObjBrow()
	oBrowse:default()
	oBrowse:refresh()
Return

static function verificaProd()


	_cQuery := " SELECT count(ZAL_COD) AS ACHOU
	_cQuery += " FROM  " + retSqlTab('ZAL')
	_cQuery += " WHERE " + retSqlFil('ZAL')
	_cQuery += " AND ZAL_COD = '" + padr(alltrim(M->B1_COD),14,"") + "'"
	_cQuery += " AND " + retSqlDel('ZAL')


	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return
