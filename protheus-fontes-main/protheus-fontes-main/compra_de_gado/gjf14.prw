#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GJF14    ³ Giuliano Forgiarini           ³ Data ³ 01.06.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lançamento de Condenas                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigapcp                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF14()

	Private aRotina     := {}
	Private cCondicao := ''
	Private IndSZ4   := {} 
	lOk := .f.
	aObjects := {}                                             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )


	aRotina := {{ "Pesquisa", "AxPesqui"  , 0, 1},{ "Alterar",  "u_gjf14Alt", 0, 4}}  //"Alterar"  

	Private cCadastro 	:= "Lançamento de Condenas"
	//Alert('')
	//if select('SZ4') != 0														//Verifica o status do pré-carregamento e fecha seu arquivo
	//dbclosearea('SZ4')
	//endif

	cPerg := "GJF14"

	if !pergunte(cPerg,.t.)
		return
	endif

	cCondicao := "Z4_NUMAM =  '" + mv_par01 + "' AND Z4_FILIAL = '" + xfilial('SZ4') + "'"

	DbSelectArea("SZ4")
	SZ4->(DbSetOrder(1))
	SZ4->(dbgotop())

	//FilBrowse("SZ4",@IndSZ4,@cCondicao)

	mBrowse(6,1,22,75,"SZ4", ,,,,2,,,,,,,,,cCondicao)


	//mBrowse(6,1,22,75,"SZ4", ,,,,2 ,,,,,) 

	//If ( Len(IndSZ4)>0 )
	//EndFilBrw("SZ4",IndSZ4)
	//endif    

	If Select('SZ4')<> 0
		SZ4->(dbCloseArea())
	Endif
	//dbclosearea('SZ4')  

Return


//Edição das condenas
User Function gjf14Alt(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL 
	Private aGets	:= {}
	Private aTela	:= {} 


	DEFINE MSDIALOG oDlg TITLE cCadastro from 00,00 To 360,800 OF oMainWnd PIXEL  

	Usado := gjf14Ahead("ZA3")                                                 //Monta o aHeader

	gjf14Acols()                                                            //Monta o Acols

	oGet := MSGetDados():New (30,2,170,400,nOpc,"u_gjf14LinOk(n)","u_gjf14TudOk",,.T., , ,.F. , , )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_gjf14TudOk().and.u_gjf14LinOk(n).and.;
	Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(), odlg:refresh())}, {||oDlg:End()}, ,) CENTERED

	If lOk  
		gjf14Grav()
	Endif

	//FilBrowse("SZ4",@IndSZ4,@cCondicao)

Return


//Montagem do aCols
static Function gjf14Acols()
	Local nI, nPos

	dbSelectArea("ZA3")
	dbSetOrder(1)
	dbSeek(xFilial('ZA3')+SZ4->(Z4_NUMAM+Z4_LOTE),.T.)

	Do While ZA3->(!Eof()) .and. xFilial('ZA3') ==  ZA3->ZA3_FILIAL .and.;
	ZA3->ZA3_NUMAM == SZ4->Z4_NUMAM .and.;
	ZA3->ZA3_LOTE == SZ4->Z4_LOTE
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

		ZA3->(DbSkip())	
	Enddo

Return

//Monta oa aHeader
Static Function gjf14Ahead(cAlias)

	//Local i
	aHeader := {}

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAlias)
	Do While !Eof() .and. (X3_ARQUIVO == cAlias)
		If 	at(Upper(AllTrim(X3_CAMPO)), "ZA3_FILIAL ZA3_NUMAM") > 0
			DbSkip()
			Loop
		Endif
		If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
			nUsado++
			aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
		Endif
		DbSkip()
	Enddo

	/*
	_cAlias  := cAlias			// ZA3
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZA3_FILIAL" .Or. AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZA3_NUMAM"
		
		Endif

		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) .And.  cNivel >= GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO'))
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
	*/

Return len(aHeader)

//Grava cabecalho e itens
Static Function gjf14Grav(nOpc)

	Local nIt
	Local nCont
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                                       	// Indica se todas as gravacoes obtiveram sucesso

	DbSelectArea("SZ4")
	DbSetOrder(1)

	DbSelectArea("ZA3")
	DbSetOrder(1)

	For nIt := 1 To Len(aCols)
		If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
			If DbSeek(xFilial("ZA3") + SZ4->(Z4_NUMAM + Z4_LOTE) + GDFieldGet('ZA3_CODCON',nIt)) 

				RecLock("ZA3",.F.)
				DbDelete()
				MsUnlock()
			Endif
		Endif     
	Next

	For nIt := 1 To Len(aCols)

		If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

			If DbSeek(xFilial("ZA3") + SZ4->(Z4_NUMAM + Z4_LOTE) + GDFieldGet('ZA3_CODCON',nIt)) 
				RecLock("ZA3",.F.)
			Else 
				RecLock("ZA3",.T.)
			Endif

			For nCpo := 1 To Len(aHeader)
				If aHeader[nCpo, 10] <> "V"
					ZA3->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
				EndIf
			Next nCpo

			ZA3->ZA3_FILIAL	 := xFilial("ZA3")
			ZA3->ZA3_NUMAM	 := SZ4->Z4_NUMAM
			ZA3->ZA3_LOTE    := SZ4->Z4_LOTE

			MsUnlock()
		Endif
	Next nIt

Return lGraOk


//Testa todo aCols
User Function gjf14TudOk()

	Local lRetorno	:= .T.
	Local nIt 		:= 0
	Local nTot		:= 0
	Local nPosDel  	:= Len(aHeader) + 1
	Local nI
	
	For nI = 1 To Len(aCols)
		if empty(GDFieldGet('ZA3_CODCON'))
			lRetorno := .F.
		endif
	Next nI  

Return lRetorno

//Teste de validação da linha do grid
User Function gjf14LinOk(n)       

	Local lRetorno 	:= .F.
	Local nPosDel 	:= Len(aHeader) + 1
	Local nCpo         
	Local i
	
	If !aCols[n, nPosDel]                                                  // Verifica se o item foi deletado   
		For nCpo := 2 To Len(aHeader)                                      // Ignora o  Item
			If !Empty(aCols[n, nCpo]) .and. ValType(aCols[n, nCpo]) <> "D"
				lRetorno := .T.
			Endif
		Next nCpo
	Else
		lRetorno := .T.
	Endif

	if  lRetorno
		if !aCols[n, nPosDel]
			_cCodCon := GDFieldGet('ZA3_CODCON',n)

			for i := 1 to len(aCols)
				if  _cCodCon = GDFieldGet('ZA3_CODCON',i) .and. n <> i  .and. !aCols[i, nPosDel]                                                 
					msgbox('Condenas já informada!',,'STOP')
					return .F.
				endif      
			next           

		endif
	endif
Return .T.
