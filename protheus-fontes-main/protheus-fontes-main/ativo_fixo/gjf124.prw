#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF124    ºAutor  ³Giuliano Forgiarini º Data ³  01/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualização dos calculos de depreciação para apuração de  ¹±±
±±º crédito de PIS e COFINS dos bens do ativo fixo                        ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF124()

	Local cCondicao 	:= ""						// Condição para a filtragem
	lOk := .f.
	aObjects := {}                                             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )


	Private cCadastro := "Calculo de Depreciação para Credito de PIS e COFINS"
	Private aRotina := { {"Pesquisar"   ,"AxPesqui"     ,0,1} ,;  
	{"&Visualizar" ,"AxVisual"  	,0,2} ,;
	{"&Incluir"    ,"AxInclui"  	,0,3} ,;
	{"Vis.&Calculo","u_GJF124v()" ,0,4} ,;
	{"&Calcular"   ,"u_GJF123()"  ,0,4}}

	dbSelectArea("ZB2")
	ZB2->(dbsetorder(1))

	mBrowse(6,1,22,75,"ZB2", ,,,,2,,,,,) 

	DbCloseArea('ZB2')   

	Set Key 124 to

return

User Function GJF124V()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local lOk 		:= .F.
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private aGets   := {}
	Private aTela   := {}

	DbSelectArea('ZB3')
	ZB3->(DbSetOrder(1))
	ZB3->(DbGoTop())
	ZB3->(DbSeek(xfilial('SB3')+ZB2->(ZB2_CBASE+ZB2_ITEM)))

	DEFINE MSDIALOG oEnc TITLE 'Parcelas de Depreciação por Fração' from 0,0 To 350,650 OF oMainWnd PIXEL

	nUsado := gjf124head()

	inic := 0

	gjf124col()

	RegtoMemory('ZB3')

	oGet := MSGetDados():New (14,2,170,320, 2,,,,.F.,, ,.F. , len(aCols), )

	ACTIVATE MSDIALOG oEnc ON INIT EnchoiceBar(oEnc,{||lOk :=.t. .and.Obrigatorio(aGets,aTela) .and. u_gjf124Ok(),Iif(lOk,oEnc:End(),;
	oEnc:refresh())}, {||oEnc:End()}, , ) CENTERED

	If lOk
		gjf124Grv()
	Endif

	If Select("ZB3")<>0
		ZB3->(dbCloseArea())
	Endif

Return


Static Function gjf124head()

	Local aHeader := {} 	// Array aHeader de retorno da funcao
	Local aCpos	  := {}
	Local nC	  := 0

	aCpos := FWSX3Util():GetAllFields("ZB3" , .T.) 	// Retorna os campos virtuais

	For nC := 1 to Len(aCpos)

		If aCpos[nC] <>  "ZB3_FILIAL" .And. aCpos[nC] <> " ZB3_CBASE" .And. aCpos[nC] <> " ZB3_ITEM"

			If X3Uso(GetSx3Cache(aCpos[nC],"X3_USADO" )) .AND. cNivel >= GetSx3Cache(aCpos[nC],"X3_NIVEL" )
				nUsado++
				Aadd(aHeader, { AllTrim(GetSx3Cache(aCpos[nC],"X3_TITULO")	),;
								AllTrim(GetSx3Cache(aCpos[nC],"X3_CAMPO")	),;
								GetSx3Cache(aCpos[nC],"X3_PICTURE"			),;
								GetSx3Cache(aCpos[nC],"X3_TAMANHO"			),;
								GetSx3Cache(aCpos[nC],"X3_DECIMAL"			),;
								AllTrim(GetSx3Cache(aCpos[nC],"X3_VALID")	),;
								GetSx3Cache(aCpos[nC],"X3_USADO"			),;
								GetSx3Cache(aCpos[nC],"X3_TIPO"				),;
								GetSx3Cache(aCpos[nC],"X3_ARQUIVO"			),;
								GetSx3Cache(aCpos[nC],"X3_CONTEXT"			)})
			EndIf

		EndIf

	Next nC

Return Len(aHeader)


Static Function gjf124col()
	Local nI, nPos
	dbSelectArea("ZB3")
	ZB3->(dbSetOrder(1))
	if 	ZB3->(dbSeek(xFilial('ZB3')+ZB3->(ZB3_CBASE+ZB3_ITEM),.T.))
		Do While ZB3->(!Eof()) .and. ZB3->ZB3_FILIAL = xfilial('ZB3') .and. ;
		ZB2->(ZB2_CBASE+ZB2_ITEM) == ZB3->(ZB3_CBASE+ZB3_ITEM)
			aAdd(aCols,Array(nUsado+1))
			For nI := 1 to nUsado
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Next nI
			aCols[Len(aCols),nUsado+1] := .F.
			ZB3->(DbSkip())
		Enddo
	endif
Return

Static Function gjf124Grv()
return .t.

User Function gjf124Ok()
Return .T.

