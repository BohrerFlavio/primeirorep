#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MLR29    ³ Mauricio Roehrs               ³ Data ³ 23/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tabela de Preço                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaoms                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR29()

	Private aCores      := {}
	Private aCores2     := {}
	Private aRotina     := {}
	Private cCondicao   := ''        
	Private _lSalv      := .f.
	aIndZZ4             := {} 
	aObjects            := {}                                                                 
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           :=aPosObj[1]                                                            
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	bLegenda1 := "DA0->DA0_ATIVO == '1'"          // ativo
	bLegenda2 := "DA0->DA0_ATIVO == '2'"          // inativo

	aCores := {{bLegenda1, 'BR_VERDE'   },;       // ativo
	{bLegenda2, 'BR_LARANJA' }}         // inativo

	aRotina := {{ "Pesquisa"   ,"AxPesqui"  , 	0, 1},; 	//"Pesquisar"
	{ "Visualizar" ,"u_mlr29Visu" , 	0, 2},;	//"Visualizar"
	{ "Incluir"    ,"u_mlr29Incl" , 	0, 3},;	//"Incluir" 
	{ "Alterar"    ,"u_mlr29Alte" , 	0, 4},;	//"Alterar"
	{ "Excluir"    ,"u_mlr29Excl" , 	0, 5},;  //"Excluir"
	{ "Legenda"    ,"u_mlr29Leg"  , 	0, 1}}   //"Legenda"

	Private cCadastro 	:= "Tabela de Preços"

	DbSelectArea("DA0")
	DA0->(DbSetOrder(1))

	mBrowse(6,1,22,75,"DA0", ,,,,2    ,aCores,,,,,,,,cCondicao) 

	dbclosearea('DA0')  

Return

//Disponibiliza a legenda
User Function mlr29Leg(cAlias,nReg,nOpc) 
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return

//Visualiza Pré-Pedidos de Venda
User Function mlr29Visu(cAlias,nReg,nOpc)

	Local oDlg		:= NIL

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL   
	area := GetArea()

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("DA0") 

	mlr29Ahead("DA1")                                                           //Monta oa vetor aHeader

	nUsado := Len(aHeader)                                                        

	mlr29Acols(nOpc)															//Monta oa vetor aCols      

	oEnc    := MsMGet():New("DA0" ,DA0->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+DA1_ITEM",.T.)

	oGetDad:oBrowse:bChange    := {||  }             //Realiza todos os calculos ao mudar de linha 
	oGetDad:oBrowse:bLostFocus := {||  }             //Realiza todos os calculos ao perder o foco da linha

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, ,)

	RestArea(area)

Return

//Incluir itens na tabela de preços
User Function mlr29Incl(cAlias,nReg,nOpc)
	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {} 

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := mlr29Ahead("DA1")
	mlr29Acols(nOpc)

	RegToMemory("DA0",.T.)

	oEnc := MsMGet():New("DA0" ,DA0->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_mlr29LinOk(n,'I')","u_mlr29TudOk","+DA1_ITEM",.T., , ,.F. , 9999)


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_mlr29TudOk().and.Obrigatorio(aGets,aTela).and.u_mlr29LinOk(n,'I'), ;
	Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,)

	If  lOk  
		confirmsx8()
		mlr29Grav(nOpc)      
	else
		Rollbacksx8()
	Endif

Return

//Alteração de Pré-Pedido
User Function mlr29Alte(cAlias,nReg,nOpc)

	Local oDlg		    := NIL
	Local lOk 		    := .F.
	Local aCposAlt	    := {}
	Local aButtons	    := {}
	Local _cCodigo     := ''
	Private aHeader	 := {}
	Private aCols	    := {}
	Private nUsado	    :=	0
	Private oGet		 := NIL
	Private aGets		 := {}
	Private aTela		 := {}

	DbSelectArea(cAlias)

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := mlr29Ahead("DA1")                                                 //Monta o aHeader

	mlr29Acols(nOpc)                                                            //Monta o Acols

	RegtoMemory('DA0')

	oEnc := MsMGet():New("DA0" ,DA0->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_mlr29LinOk(n,'A')","u_mlr29TudOk","+DA1_ITEM",.T., , ,.F. ,9999)

	oGet:oBrowse:bChange    := {||  }             //Realiza todos os calculos ao mudar de linha 
	oGet:oBrowse:bLostFocus := {||  }             //Realiza todos os calculos ao perder o foco da linha

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_mlr29TudOk().and.u_mlr29LinOk(n,'A').and.;
	Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(), odlg:refresh())}, {||oDlg:End()}, ,)

Return

//Exclusão de Pré-Pedidos de venda
User Function mlr29Excl(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	DbSelectArea(cAlias) 

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("DA0") 

	EnChoice( "DA0" ,DA0->(RECNO()), nOpc, , , , , aPosObj[1], , 3 )
	mlr29Ahead("DA1") 

	nUsado	:= Len(aHeader)                                                           //Monta o aHeader

	mlr29Acols(nOpc)                                                                  //Monta o Acols

	oGet:= MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+DA1_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||mlr29Dele(),oDlg:End()},{||oDlg:End()}, , aButtons)

Return

//Montagem do aCols
static Function mlr29Acols(nOpc)
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

		nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "DA1_ITEM" })
		if nPos > 0
			aCols[1,nPos]	:= StrZero(len(acols),Len(aCols[1,nPos]))
		endif
		aCols[1,nUsado+1] := .F.
	Else
		RegToMemory("DA0")

		dbSelectArea("DA1")
		dbSetOrder(3)
		dbSeek(xFilial('DA1')+DA0->DA0_CODTAB,.T.)

		Do While DA1->(!Eof()) .and. xFilial('DA1') ==  DA1->DA1_FILIAL .and. DA1->DA1_CODTAB == DA0->DA0_CODTAB
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

			DA1->(DbSkip())	
		Enddo

	Endif

Return

//Monta oa aHeader
Static Function mlr29Ahead(cAlias)

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//DbSeek(cAlias)
	//Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	//	If 	at(Upper(AllTrim(X3_CAMPO)), "DA1_FILIAL DA1_CODTAB") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++                                
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := cAlias			// DA1
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 				.And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "DA1_FILIAL" .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "DA1_CODTAB")

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
Static Function mlr29Grav(nOpc)

	Local nIt
	Local nCont
	Local nNumItem
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                                       	// Indica se todas as gravacoes obtiveram sucesso

	Begin Transaction

		DbSelectArea("DA0")
		DbSetOrder(1)
		If INCLUI             
			//Se a opção foi de incluir registros, faz isso    
			RecLock("DA0",.T.)
		Else                                                             //Senão...
			RecLock("DA0",.F.)                                             
		Endif

		For nCont := 1 To FCount()

			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("DA0"))
			Else
				FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
			Endif

		Next nCont

		MsUnLock()

		DbSelectArea("DA1")
		DbSetOrder(3)

		nNumItem := 1  // Contador para os Itens
		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				If DbSeek(xFilial("DA1") + M->DA0_CODTAB + StrZero(nIt,3)) 	
					RecLock("DA1",.F.)
					DbDelete()
					MsUnlock()
				Endif
			Endif     
		Next

		For nIt := 1 To Len(aCols)

			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

				If ALTERA 
					If DbSeek(xFilial("DA1")+ M->DA0_CODTAB + StrZero(nIt,3))
						RecLock("DA1",.F.)
					Else 
						RecLock("DA1",.T.)
					Endif
				Else  
					RecLock("DA1",.T.)
				Endif

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"
						DA1->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				DA1->DA1_FILIAL  := xFilial("DA1")
				DA1->DA1_CODTAB  := DA0->DA0_CODTAB                           //Atribui o numero do PP ao item                                
				DA1->DA1_ITEM    := strzero(nNumItem,3)
				DA1->DA1_USALTE  := cUserName                          //Grava o nome do usuario

				nNumItem++
				MsUnlock()
			Endif
		Next nIt


	End Transaction

Return lGraOk

//Exclusão dos pré-pedidos de venda
Static Function mlr29Dele()

	DbSelectArea("DA1")
	DA1->(DbSetOrder(3))

	DbSeek(xFilial("DA1") + DA0->DA0_CODTAB,.t.)

	Do While DA1->(!Eof()) .and. xFilial("DA1") == DA1->DA1_FILIAL .AND. DA0->DA0_CODTAB == DA1->DA1_CODTAB

		RecLock("DA1",.f.)
		DbDelete()
		MsUnLock()
		DA1->(DbSkip())
	Enddo

	DbSelectArea("DA0")

	RecLock("DA0",.f.)
	DbDelete()
	MsUnLock()                 

Return

//Testa todo aCols
User Function mlr29TudOk()

	Local lRetorno	:= .T.
	Local nIt 		:= 0
	Local nTot		:= 0
	Local nPosDel  	:= Len(aHeader) + 1

	If INCLUI
		If DA0 ->(dbSeek( XFILIAL("DA0") + M->DA0_CODTAB) )
			lRetorno := .F.
			Help(" ",1,"JAGRAVADO")  // Campo ja Existe
		Endif
	Endif

Return lRetorno

//Teste de validação da linha do grid
User Function mlr29LinOk(n,op)       

	Local lRetorno 	:= .F.
	Local nPosDel 	:= Len(aHeader) + 1
	Local nCpo

	If !aCols[n, nPosDel]                                                  // Verifica se o item foi deletado
		For nCpo := 2 To Len(aHeader)                                      // Ignora o  Item
			If !Empty(aCols[n, nCpo]) .and. ValType(aCols[n, nCpo]) <> "D"
				lRetorno := .T.
			Endif
		Next nCpo
	Else
		lRetorno := .T.
	Endif

Return .T.

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
