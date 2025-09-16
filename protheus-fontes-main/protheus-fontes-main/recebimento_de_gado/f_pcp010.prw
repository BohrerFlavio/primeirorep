#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ F_PCP010 ³ Autor ³ Raul Pietsch          ³ Data ³ 26.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao da ordem de recebimento                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigapcp                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function F_PCP010()

	aObjects := {}
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX    :=aPosObj[1]                                                             //aumenta cabec e diminui itens
	aX[3]        += 30
	aPosObj[1]   := aX
	aPosObj[2,1] += 30

	Private aRotina := { { "Pesquisa",  "AxPesqui"  ,   0, 1},; 	//"Pesquisar"
	{ "Visualizar","u_pcp010Visu", 0, 2},; 	//"Visualizar"
	{ "Incluir",   "u_pcp010Incl", 0, 3},;     //"Incluir"
	{ "Alterar",   "U_pcp010Alte", 0, 4},;     //"Alterar"
	{ "Veiculos",   "U_f_pcp034",  0, 4},;     //"Veiculos"
	{ "Pesos   ",   "U_f_pcp033",  0, 4},;     //"Pesos"
	{ "Excluir",   "U_pcp010Excl", 0, 4} } 	//"Excluir"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho da tela de atualizacoes                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCadastro 	:= "Ordem de recebimento"

	Private nQtAnimal := 0  

	DbSelectArea("SZD")
	DbSetOrder(1)

	mBrowse( 6, 1, 22, 75,"SZD",,,,,,)
Return
//
//
//
User Function pcp010Incl(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	Private aGets	:= {}
	Private aTela	:= {}

	DbSelectArea(cAlias)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Enchoice Modelo3                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	AADD(aButtons, { 'EDIT'  ,{||u_pcp010cop() , oDlg:Refresh() }, 'Cópia Mangueira' , 'Cop.Mang'  } )  //Copia mangueiras
	AADD(aButtons, { 'AUTOM' ,{||u_pcp010Sol() , oDlg:Refresh() }, 'Vincula SC'      , 'Vinc.SC'   } )  //Vincula SCs
	AADD(aButtons, { 'BUDGET',{||u_pcp010_it() , oDlg:Refresh() }, 'Cópia Item'      , 'Cop.Item'  } )  //Copia item

	DEFINE MSDIALOG oDlg TITLE cCadastro ;
	from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("SZD",.T.)
	M->ZD_NUMERO := GetSx8num('SZD','ZD_NUMERO')
	EnChoice( "SZD" ,SZD->(RECNO()), nOpc, , , , , aPosObj[1], , 3 )

	p010Ahead("SZE")

	nUsado	:= Len(aHeader)

	p010Acols(nOpc)

	DbSelectArea("SZE")

	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_p010LinOk","u_p010TudOk","+ZE_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_p010TudOk() .and. Obrigatorio(aGets,aTela), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

	If lOk
		confirmsx8()  
		p010Grav(nOpc) 
		_cNumOR := SZD->ZD_NUMERO
		AtVeic(_cNumOR)
		AtPeso(_cNumOR)
	else
		Rollbacksx8()
	Endif

Return
//
//
//
User Function pcp010Sol()
	Local i
	PRIVATE ALTERA 
	Private lInverte 	 := .f.
	Private cMark    	 := GetMark()  
	Private oMark
	Private marc       := .f.                           

	If .f. 
		MsgBox ("Aviso de recebimento já possui ordem de matança, não pode ser alterado!","Erro!!!","STOP")
		Return
	Endif

	Private area := GetArea()
	//Private cArq  := CriaTrab( Nil, .F. )                 //temporario

	dbSelectar('SZ9')
	dbSetOrder(4)                                        //fornecedor+loja+numero

	Private aStru := {}//dbStruct()                          //estrutura
	AADD(aStru,{"Z9_OK"      	,"C"	,2		,0	})
	AADD(aStru,{"Z9_NUMERO"  	,"C"  ,30   ,0 })    
	AADD(aStru,{"Z9_DATA"      ,"D"	,8		,0	})  
	AADD(aStru,{"Z9_ITEM"   	,"C"	,3		,0 })
	AADD(aStru,{"Z9_PRODUTO"   ,"C"	,15	,0	})
	AADD(aStru,{"Z9_QUANT"     ,"N"	,6		,0 })
	AADD(aStru,{"Z9_PRECO"     ,"N"	,12	,5	})
	AADD(aStru,{"Z9_CATEG"     ,"C"	,3  	,0	})
	AADD(aStru,{"Z9_RACA "     ,"C"	,3 	,0	}) 
	AADD(aStru,{"Z9_FORNECE "  ,"C"	,6 	,0	}) 
	AADD(aStru,{"Z9_LOJA "     ,"C"	,2 	,0	}) 


	//dbcreate(cArq,aStru)
	//If Select('TMP')<>0
	//	TMP->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )               //cria temp
	//IndRegua("TMP",cArq,"Z9_FORNECE+Z9_LOJA",,,"Selecionando Registros...") //ordena

	_aArqTrb :={}
	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {"Z9_FORNECE","Z9_LOJA"}, @_aArqTrb)


	SZ9->(dbSeek(xFilial('SZ9')+M->ZD_FORNECE+M->ZD_LOJA,.T.))

	Do While !SZ9->(Eof()) .AND. SZ9->(Z9_FORNECE+Z9_LOJA) == SZD->(ZD_FORNECE+ZD_LOJA)

		DbSelectArea('TMP')
		Reclock('TMP',.t.)
		For i:=1 to SZ9->(fcount())

			NAME := FieldName( i )

			dbSelectARea('TMP')
			POSICAO := FieldPos( NAME )
			dbSelectArea('SZ9')

			If POSICAO > 0
				TMP->(FieldPut(POSICAO, SZ9->(FieldGet(i)) ))
			EndIf	
		Next
		//campos adicionais
		MsUnlock()
		SZ9->(DbSkip())
	Enddo

	dbGotop()  


	private aCampos := {}
	AADD(aCampos,{"Z9_OK"     ,     "@X",                 "OK"            })
	AADD(aCampos,{"Z9_NUMERO" ,     "@9",                 "Numero"        })
	AADD(aCampos,{"Z9_DATA" ,       "@X",                 "Data"          })
	AADD(aCampos,{"Z9_ITEM",        "@9",                 "Item"          })
	AADD(aCampos,{"Z9_PRODUTO" ,    "@X",                 "Produto"       })
	AADD(aCampos,{"Z9_QUANT"   ,    "@9",                 "Quantidade"    })
	AADD(aCampos,{"Z9_PRECO",       "@E 999,999.99",      "Preço"         })
	AADD(aCampos,{"Z9_CATEG"    ,   "999",                "Categoria"     })
	AADD(aCampos,{"Z9_RACA"   ,     "@!",                 "Raça"          })

	//Private aRotina  := { { "Confirmar"   , 'u_PCP010M1', 0, 4}  }


	dbSelectarea('TMP')
	TMP->(dbGotop())

	/*Executa a Vinculação da Solicitação de compra
	*Autor: Mauricio Roehrs
	*Data: 18/10/13
	*/ 
	DEFINE MSDIALOG oDlg2 TITLE "Vinculação de Solc.Comp." From 9,0 To 400,1000 PIXEL
	oMark := MsSelect():New("TMP","Z9_OK","",aCampos,@lInverte,@cMark,{17,1,160,500},,,,,) 
	oMark:bMark := {| | Disp()}        

	TButton():New(170, 020, "Marcar Todos"    , oDlg2,{|| pcp010Sel()   },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New(170, 070, "Vincular"       	, oDlg2,{|| pcp010Vinc()  },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New(170, 390, "Sair"            , oDlg2,{|| oDlg2:end()    },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg2 CENTERED 

Return 

Static Function Disp()

	RecLock("TMP",.F.)
	if Marked("Z9_OK")
		TMP->Z9_OK := cMark
	else          
		TMP->Z9_OK := ""
	endif             
	msunlock() 
	oMark:oBrowse:Refresh()	
Return .t.   

//MARCA TODOS
Static Function pcp010Sel()
	TMP->(dbgotop())   

	while TMP->(!eof())                               
		reclock('TMP',.f.)
		TMP->Z9_OK := cMark
		msunlock()
		TMP->(dbskip())
	enddo      

	TMP->(dbgotop())   

	oMark:oBrowse:Refresh()
return .t.

/*Executa a Vinculação da Solicitação de compra
*Autor: Mauricio Roehrs
*Data: 18/10/13
*/ 
Static Function pcp010Vinc()

	SZA->(dbsetorder(1))
	TMP->(dbgotop()) 

	nItsel := 0
	while TMP->(!eof())
		if !empty(TMP->Z9_OK)
			nItSel++
		endif
		TMP->(DbSkip())
	enddo

	TMP->(DbGotop())	
	nIt := 1	

	while TMP->(!eof()) 
		if !empty(TMP->Z9_OK)   				
			marc := .t.

			SZA->(dbsetorder(1))		
			if SZA->(dbseek(xfilial('SZA')+TMP->Z9_NUMERO))		
				reclock('SZA',.f.)								
				SZA->ZA_ORDREC := SZD->ZD_NUMERO 
				msunlock()			
			endif

			if nItSel == 1
				aCols[n,_ascan("ZE_NUMSC")]   := TMP->Z9_NUMERO
				aCols[n,_ascan("ZE_ITEMSC")]  := TMP->Z9_ITEM
				exit
			endif

			if nIt <= len(aCols)
				aCols[nIt,_ascan("ZE_NUMSC")]   := TMP->Z9_NUMERO
				aCols[nIt,_ascan("ZE_ITEMSC")]  := TMP->Z9_ITEM
			endif

			nIt++							
		endif
		TMP->(dbskip())
	enddo

	if marc
		msgbox('Solicitação de Compra Vinculada ',"CONFIRMAÇÃO","INFO")  
	else
		msgbox('Não houve Solicitação selecionada!',"OPERACAO NULA",'INFO')  
	endif	

	oDlg:end()
return
//
//BLOCO DESATIVADO por Mauricio Lopes Roehrs
/* 
User Function Pcp010m1()
dbSelectarea('TMP')
dbGotop()
nItsel := 0

While ! TMP->( Eof() )
If !Empty( TMP->Z9_OK )
nItSel++
Endif
TMP->(dbSkip())
Enddo

dbGotop()
nIt := 1
While ! TMP->( Eof() )
If !Empty( TMP->Z9_OK )

if nItSel == 1
aCols[n,_ascan("ZE_NUMSC")]   := TMP->Z9_NUMERO
aCols[n,_ascan("ZE_ITEMSC")]  := TMP->Z9_ITEM
exit
endif

if nIt <= len(aCols)
aCols[nIt,_ascan("ZE_NUMSC")]   := TMP->Z9_NUMERO
aCols[nIt,_ascan("ZE_ITEMSC")]  := TMP->Z9_ITEM
endif

nIt++

Endif
TMP->(dbSkip())
Enddo

Return
*/
//
//

User Function pcp010Visu(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	Private aCateg  := {}
	Private aVeic   := {}

	DbSelectArea(cAlias)

	//AADD(aButtons, { 'RECALC',{||u_f_pcp033(@acateg), oDlg:Refresh()  }, 'Peso Categoria'  , 'Pes.Categ' } ) //Peso categoria
	//AADD(aButtons, { 'FORM',{||u_f_pcp034(M->ZD_NUMERO, M->ZD_TRANSP, @aVeic )  , oDlg:Refresh() }, 'Dados do transporte'  , 'Veículos' } ) //Peso categoria

	DEFINE MSDIALOG oDlg TITLE cCadastro ;
	from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL


	dbSelectArea("SZD")
	RegToMemory("SZD")
	EnChoice( "SZD" ,SZD->(RECNO()), nOpc, , , , , aPosObj[1], , 3 )


	dbSelectArea("SZE")

	p010Ahead("SZE")
	nUsado	:= Len(aHeader)
	p010Acols(nOpc)

	oGet:= MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZE_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons)


Return
//
//
//
User Function pcp010Alte(cAlias,nReg,nOpc)

	Local aButtons	:= {}

	Private aGets	:= {}
	Private aTela	:= {}
	Private aCateg  := {}
	Private aVeic   := {}  // Vetor dos recebimentos por veículo



	//Verifica se não houve geracao da ordem de matanca.
	SZE->( dbSeek( xFilial('SZE')+SZD->ZD_NUMERO ) )
	IF .f. //!Empty( SZE->ZE_NUMAM )
		MsgBox ("Aviso de recebimento já possui ordem de matança, não pode ser alterado!","Erro!!!","STOP")
		Return
	Endif


	Private oDlg		:= NIL
	Private lOk 		:= .F.
	Private aCposAlt	:= {}
	Private aButtons	:= {}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private _cNumOR := SZE->ZE_NUMERO
	DbSelectArea(cAlias)

	aCposAlt := {}  // Campos que podem ser alterados

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Enchoice Modelo3                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	AADD(aButtons, { 'EDIT'  ,{||U_pcp010cop() , oDlg:Refresh() }, 'Copia Mangueira' , 'Cop.Mang'  } )  //Totais
	AADD(aButtons, { 'AUTOM' ,{||U_pcp010Sol() , oDlg:Refresh() }, 'Vincula SC'      , 'Vinc.SC'   } )  //Vincula SCs
	AADD(aButtons, { 'BUDGET',{||u_pcp010_it() , oDlg:Refresh() }, 'Cópia Item'      , 'Cop.Item'  } )  //Copia item

	DEFINE MSDIALOG oDlg TITLE cCadastro ;
	from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL


	DbSelectArea("SZD")
	RegtoMemory('SZD')

	p010Ahead("SZE")
	nUsado	:= Len(aHeader)
	p010Acols(nOpc)

	EnChoice( "SZD" ,SZD->(RECNO()), nOpc, , , , , aPosObj[1], , 3 )

	DbSelectArea("SZE")

	oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_p010LinOk","u_p010TudOk","+ZE_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_p010TudOk().and.Obrigatorio(aGets,aTela), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)
	_cNumOR := SZD->ZD_NUMERO
	If lOk 
		p010Grav(nOpc)
		AtVeic(_cNumOR)
		AtPeso(_cNumOR)
	Endif

Return

static Function p010Acols(nOpc)
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

		nPos			:= aScan(aHeader,{ |x| AllTrim(x[2])== "ZE_ITEM" })
		if nPos > 0
			aCols[1,nPos]	:= StrZero(len(acols)+1,Len(aCols[1,nPos]))
		endif

		aCols[1,nUsado+1] := .F.

	Else

		dbSelectArea("SZE")
		dbSetOrder(1)
		dbSeek(xFilial('SZE')+M->ZD_NUMERO,.T.)

		Do While SZE->(!Eof()) .and.;
		xFilial('SZE') == SZE->ZE_FILIAL .and.;
		SZE->ZE_NUMERO == M->ZD_NUMERO

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

			DbSkip()

		Enddo

	Endif

Return
//
//
//
Static Function p010Ahead(cAlias)

	Local i
	aHeader := {}
	nUsado 	:= 0

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//DbSeek(cAlias)
	//Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	//	If 	at(Upper(AllTrim(X3_CAMPO)), "ZE_FILIAL ZE_NUMERO") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++
	//		aAdd(aHeader,{ Trim(X3Titulo()), X3_CAMPO  , X3_PICTURE ,;
	//		X3_TAMANHO       , X3_DECIMAL, X3_VALID   ,;
	//		X3_USADO         , X3_TIPO   , X3_ARQUIVO, X3_CONTEXT })
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := cAlias			// SZE
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 				.And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZE_FILIAL" .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZE_NUMERO")
			nUsado++
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

Return
//
//
//
Static Function P010Grav(nOpc)

	Local nIt
	Local nCont
	Local nNumItem
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.   	// Indica se todas as gravacoes obtiveram sucesso
	Local cAtividade	:= "11 " 	// Definido no ID - QKZ
	Local aAVAP1		:= {}  		// Array para converter o texto
	//Local nSaveSX8		:= GetSX8Len()

	Begin Transaction


		DbSelectArea("SZD")
		DbSetOrder(1)

		If INCLUI
			RecLock("SZD",.T.)
		Else
			RecLock("SZD",.F.)
		Endif

		For nCont := 1 To FCount()

			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("SZD"))
			Else
				FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
			Endif

		Next nCont

		MsUnLock()

		DbSelectArea("SZE")
		DbSetOrder(1)

		nNumItem := 1  // Contador para os Itens

		If ALTERA // Exclui todos os Itens existentes
			While DbSeek(xFilial("SZE")+ M->ZD_NUMERO)
				RecLock("SZE",.F.)
				dbDelete()
				MsUnlock()
			Enddo
		Endif

		For nIt := 1 To Len(aCols)

			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

				RecLock("SZE",.T.)

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"
						SZE->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				SZE->ZE_FILIAL	 := xFilial("SZE")
				SZE->ZE_NUMERO	 := SZD->ZD_NUMERO
				SZE->ZE_ITEM     := strzero(nNumItem,3)

				//Se o tipo de compra é vivo , calcula o peso vivo de um animal pela média 
				/*
				IF SZE->ZE_TPCOM == 'V'
				SZE->ZE_QTD2UM := M->ZD_PESOANT / nQtAnimal
				Endif
				*/
				nNumItem++

				MsUnlock()
			Endif

		Next nIt

		//Igualar() - desativada
		/*
		//Grava pesos por categoria
		SZR->( dbSetOrder(1) )
		SZR->( dbSeek(xFilial('SZR')+M->ZD_NUMERO ) )
		While !SZR->(Eof()) .AND. SZR->ZR_RECEB == M->ZD_NUMERO
		RecLock('SZR',.F.)
		SZR->(dbDelete())
		MsUnLock()
		SZR->(dbSkip())
		Enddo

		If !Empty( aCateg )
		For w1 := 1 To Len( aCateg )
		tam := Len(aCateg[1])
		If !aCateg[w1,tam]
		RecLock('SZR',.T.)
		SZR->ZR_FILIAL  := xFilial('SZR')
		SZR->ZR_RECEB   := M->ZD_NUMERO
		SZR->ZR_CATEG   := aCateg[w1,1]
		SZR->ZR_RASTRO  := aCateg[w1,3]
		SZR->ZR_PESO    := aCateg[w1,4]
		SZR->ZR_PESOFRI := CalcPsFr()
		//			SZR->ZR_PESOFRI := aCateg[w1,5]
		MsUnlock()
		Endif
		Next w1
		Endif
		*/
		//Grava informacoes SZS - Receb. p/ Veiculos


	End Transaction

Return lGraOk
//
//
//
User Function p010TudOk()

	Local lRetorno	:= .T.
	Local nIt 		:= 0
	Local nTot		:= 0
	Local nPosDel  	:= Len(aHeader) + 1
	Local nPosCateg := Ascan( aHeader, {|X| Trim(X[2]) == "ZE_CATEG"   } )
	Local nPosLocal := Ascan( aHeader, {|X| Trim(X[2]) == "ZE_LOCAL"   } )
	Local nPosTpcom := Ascan( aHeader, {|X| Trim(X[2]) == "ZE_TPCOM"   } )
	//Local nPosPeso  := Ascan( aHeader, {|X| Trim(X[2]) == "ZE_QTD2UM"  } )
	Local nQtdeSC	:= 0
	Local nQtdeOR	:= 0

	dbSelectArea('SZA')
	dbSetOrder(03)                                        //numero
	SZA->(dbSeek(xFilial('SZA')+M->ZD_NUMERO,.T.))

	nQtdeSC := SZA->ZA_TOTALQT

	For nIt := 1 To Len(aCols)
		nQtdeOR:= nQtdeOR + aCols[nIt,5]
	Next nIt

	For nIt := 1 To Len(aCols)
		//Categoria obrigatoria e mangueiras obrigatórias

		If ! aCols[nIt,nPosDel] //verifica se não foi deletado

			If  Empty( aCols[nIt,nPosCateg] )
				lRetorno := .F.
				Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
				Exit
			Endif
			If   Empty( aCols[nIt,nPosLocal]  )
				lRetorno := .F.
				Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
				Exit
			Endif
			If   Empty( aCols[nIt,nPosTpcom]  )
				lRetorno := .F.
				Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
				Exit
			Endif
			/*
			//Se tipo e compra =Vivo, peso é obrigatório
			If aCols[nIt,nPosTpcom] == 'V' .and. Empty( aCols[nIt,nPosPeso] )
			lRetorno := .F.
			Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
			Exit
			Endif
			*/
		Endif
		//ALERT(aCols[nIt,nPosTpcom])
		If aCols[nIt, nPosDel]
			nTot ++
		Endif
	Next nIt


	If INCLUI
		If SZD->( dbSeek( XFILIAL("SZD")+M->ZD_NUMERO) )
			lRetorno := .F.
			Help(" ",1,"JAGRAVADO")  // Campo ja Existe
		Endif
	Endif

	/*  //Total peso por categoria?
	nPcateg := 0
	nPfrigo := 0
	If !Empty( aCateg )
	For w1 := 1 To Len( aCateg )
	nPcateg +=  aCateg[w1,4]
	//		nPFrigo +=  aCateg[w1,5]
	Next w1
	Endif

	If ( M->ZD_PESOANT <> nPcateg .and. M->ZD_PESOANT <> 0 )
	MsgBox ("Peso da propriedade diverge do peso por categoria!","Erro!!!","STOP")
	U_F_PCP033( @aCateg )
	lRetorno := .F.
	Endif
	*/
	/*
	If ( M->ZD_PESODEP <> nPFrigo .and. M->ZD_PESODEP <> 0  )
	MsgBox ("Peso do frigorifico diverge do peso por categoria!","Erro!!!","STOP")
	U_F_PCP033( @aCateg )
	lRetorno := .F.
	Endif
	*/

	//Valida as categorias/rastro na tabela peso por categoria
	/*
	If !Empty( M->ZD_PESODEP ) .OR. !EMPTY(M->ZD_PESOANT)
	aCtrec := {}            // categoria/rastro na sze (acols )
	For ix := 1 To Len(aCols)

	If ! aCols[ix, Len(aCols[1])]      //não considera deletados
	categx   := aCols[ ix,_ascan("ZE_CATEG")]
	rastrox  := If( !Empty(aCols[ix,_ascan("ZE_RASTRO")]),'S','N')
	onde   := Ascan( aCateg,{|y|,y[1] == categx .and. y[3] ==  rastrox } )
	If onde  == 0
	MsgBox ("Categoria/rastro "+categx+"/"+rastrox+" não encontrada na tabela pesos por categoria!!","Erro!!!","STOP")
	lRetorno := .F.
	exit
	Endif

	//Adiciona categoria as categorias do recebimento
	If Ascan( aCtRec, categx+rastrox ) == 0
	Aadd( aCtRec, categx+rastrox  )
	Endif
	Endif
	Next ix

	If ( Len(aCtRec) <> Len(aCateg) ) .and. lRetorno
	MsgBox ("Faltou Categoria/rastro a ser definida!","Erro!!!","STOP")
	lRetorno := .F.
	Endif
	Endif

	cQtdAnim := 0

	For w2 := 1 To Len( aVeic )
	tam := Len(aVeic[1])
	If !aVeic[w2,tam]   // exclui deletados
	cQtdAnim = cQtdAnim + aVeic[w2,5]
	Endif
	Next w2

	DbSelectArea("SZE")
	DbSetOrder(1)

	/*
	//Calcula qt de animais
	nQtAnimal := 0  

	For nIt := 1 To Len(aCols)
	If ! aCols[ nIt, Len(aCols[1]) ]
	nQtAnimal += aCols[nIt,_ascan("ZE_QTD1UM")]
	endif
	Next nIt

	If nQtAnimal <> cQtdAnim
	MsgBox ("Quantidade de Animais Lançado esta Diferente do Recebimento por Veículo","Erro!!!","STOP")
	lRetorno := .F.
	EndIf
	*/
Return lRetorno


User Function p010LinOk()

	Local lRetorno 	:= .F.
	Local nPosDel 	:= Len(aHeader) + 1
	Local nCpo

	If !aCols[n, nPosDel]  // Verifica se o item foi deletado
		For nCpo := 2 To Len(aHeader) // Ignora o Item
			If !Empty(aCols[n, nCpo]) .and. ValType(aCols[n, nCpo]) <> "D"
				lRetorno := .T.
			Endif
		Next nCpo
	Else
		lRetorno := .T.
	Endif

	If !lRetorno
		Help(" ",1,"QPPA210AO1")  // Ao menos 1 campo deve ser preenchido !
	Endif

Return lRetorno
//
//
//


Static Function resumocat()
	aCat := {} //categ,raca,qtde

	SZE->(DbSetOrder(1))
	SZE->( dbSeek( xFilial('SZE')+SZD->ZD_NUMERO ) )

	While !SZE->(EOF()) .and. SZE->(ZE_FILIAL+ZE_NUMERO) == SZD->(ZD_FILIAL+ZD_NUMERO)

		ccat := left(POSICIONE('SZ5', 1, xFilial('SZ9')+SZE->ZE_CATEG, 'Z5_DESC'),20)
		crac := left(POSICIONE('SZ6', 1, xFilial('SZ9')+SZE->ZE_RACA,  'Z6_DESC'),20)
		nP := ascan(aCat,{|x|x[1]==ccat.and.x[2]=crac})
		if nP == 0
			aadd(aCat,{ccat, crac, SZE->(ZE_QTD1UM)})
		else
			aCat[np,3] += SZE->(ZE_QTD1UM)
		endif

		SZE->(DbSkip())
	EndDo

Return aCat
//
//
//
User Function pcp010cop()
	Local _i
	private lOk := .f.
	private aButtons := {}
	private cMan := '  '

	DEFINE MSDIALOG oDlg2 TITLE "Local";
	from 00,00 To 100,350 OF oMainWnd PIXEL

	@ 25,10 SAY  'Local'
	@ 25,50 GET cMan PICTURE "@!" Object oManc F3 "NNR" //valid existcpo('SX5','74'+cMan)

	ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||lOk:=.t., oDlg2:End()},{||oDlg2:End()}, , aButtons)

	If Lok
		_c  := Ascan( aHeader, {|X| Trim(X[2]) == "ZE_LOCAL"  } )

		if _c > 0
			for _i := 1 to len(aCols)
				aCols[_i,_c] := cman
			next
		Endif

	Endif

Return

//
//
//
User Function pcp010Excl(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	//Verifica se pode excluir                  
	SZE->(DbSetOrder(1))
	SZE->(dbseek(xfilial('SZE')+SZD->ZD_NUMERO))   
	while SZE->(!eof()) .and. SZE->ZE_FILIAL = xfilial('SZE') .and. SZE->ZE_NUMERO = SZD->ZD_NUMERO

		If !Empty(SZE->ZE_NUMAM )
			MsgBox ("SC já possui Ordem de abate não pode ser excluiída!","Erro!!!","STOP")
			Return
		Endif   
		SZE->(dbskip())
	enddo

	DbSelectArea(cAlias)

	DEFINE MSDIALOG oDlg TITLE cCadastro ;
	from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("SZD")
	EnChoice( "SZD" ,SZD->(RECNO()), nOpc, , , , , aPosObj[1], , 3 )
	p010Ahead("SZE")
	nUsado	:= Len(aHeader)
	p010Acols(nOpc)
	oGet:= MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZE_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||P010Dele(),oDlg:End()},{||oDlg:End()}, , aButtons)
Return
//
//
//
Static Function P010Dele()
	//peso por categoria
	DbSelectArea("SZR")
	DbSetOrder(1)
	DbSeek(xFilial("SZR") + SZD->ZD_NUMERO )
	Do While !Eof() .and. ;
	xFilial("SZR") == SZD->ZD_FILIAL .AND.  ;
	SZD->ZD_NUMERO == SZR->ZR_RECEB
		RecLock("SZR",.F.)
		DbDelete()
		MsUnLock()
		DbSkip()
	Enddo

	DbSelectArea("SZS")
	DbSetOrder(1)
	DbSeek(xFilial("SZS") + SZD->ZD_NUMERO )
	Do While !Eof() .and. ;
	xFilial("SZS") == SZS->ZS_FILIAL .AND.  ;
	SZD->ZD_NUMERO == SZS->ZS_NUMERO
		RecLock("SZS",.F.)
		DbDelete()
		MsUnLock()
		DbSkip()
	Enddo


	//itens
	DbSelectArea("SZE")
	DbSetOrder(1)
	DbSeek(xFilial("SZE") + SZD->ZD_NUMERO )
	Do While !Eof() .and. ;
	xFilial("SZE") == SZD->ZD_FILIAL .AND. ;
	SZD->ZD_NUMERO == SZE->ZE_NUMERO
		RecLock("SZE",.F.)
		DbDelete()
		MsUnLock()
		DbSkip()
	Enddo
	//cabecalho
	DbSelectArea("SZD")
	RecLock("SZD",.F.)
	DbDelete()
	MsUnLock()
Return
//
//
//
Static Function _ascan(cCampo)
Return ascan(aHeader,{|x|alltrim(x[2])==cCampo})
//
//
//
//
//Calcula a quantidade real no recebimento
//
User Function pcp10Qtd()
	Local area   := GetArea()
	Local qtTot  := 0
	SZE->( dbSetOrder(1) )
	SZE->( dbSeek(xFilial('SZE')+M->ZD_NUMERO) )
	While !Eof() .AND. SZE->ZE_NUMERO == M->ZD_NUMERO
		qtTot += SZE->ZE_QTD1UM
		SZE->( dbSkip() )
	Enddo
	RestArea(area)
Return qtTot

//
// Botão para cópia de item, irá adicionar ao final uma cópia do item posicionado
//
User Function  pcp010_it()
	Local aCopia := Aclone( aCols[n] )
	AAdd( aCols, aCopia )
Return




Static Function Igualar() // desativada
	// igualar dados do transporte para as outras OR

	//xZD_DATA       :=  SZD->ZD_DATA  - estes campos são exclusivos para
	//xZD_HORA       :=  SZD->ZD_HORA  - cada ordem de recebimento
	xZD_PESOANT    :=  SZD->ZD_PESOANT
	xZD_PESODEP    :=  SZD->ZD_PESODEP
	xZD_FRETE      :=  SZD->ZD_FRETE
	xZD_QTDTOT     :=  SZD->ZD_QTDTOT
	xZD_TRANSP     :=  SZD->ZD_TRANSP

	xZD_MOTOR1     := SZD->ZD_MOTOR1
	xZD_MOTOR2     := SZD->ZD_MOTOR2
	xZD_MOTOR3     := SZD->ZD_MOTOR3

	xZD_PLACA1     := SZD->ZD_PLACA1
	xZD_PLACA2     := SZD->ZD_PLACA2
	xZD_PLACA3     := SZD->ZD_PLACA3

	xZD_VEIC1      :=  SZD->ZD_VEIC1
	xZD_VEIC2      :=  SZD->ZD_VEIC2
	xZD_VEIC3      :=  SZD->ZD_VEIC3

	xZD_VAVE1      :=  SZD->ZD_VAVE1
	xZD_VAVE2      :=  SZD->ZD_VAVE2
	xZD_VAVE3      :=  SZD->ZD_VAVE3


	xZD_QTVE1      :=  SZD->ZD_QTVE1
	xZD_QTVE2      :=  SZD->ZD_QTVE2
	xZD_QTVE3      :=  SZD->ZD_QTVE3
	xZD_TPFRETE    :=  SZD->ZD_TPFRETE

	xZD_VLFRET     :=  SZD->ZD_VLFRET

	xZD_DASFPRE    :=  SZD->ZD_DASFPRE
	xZD_DCHPREV    :=  SZD->ZD_DCHPREV
	xZD_DTOTPRE    :=  SZD->ZD_DTOTPRE

	dbSelectArea('SZD')
	recSzd := SZD->( RECNO() )

	Private area := getArea()

	SZD->( dbSetOrder(4) ) //ordem de frete
	SZD->( dbSeek(xFilial('SZD')+xZD_FRETE ) )

	While ! SZD->(Eof()) .and. SZD->ZD_FRETE == xZD_FRETE

		If !INCLUI // somente para OR não avulsas

			RecLock('SZD',.F.)

			//SZD->ZD_DATA      := xZD_DATA - a data deve ser informada em cada um
			//SZD->ZD_HORA      := xZD_HORA
			SZD->ZD_PESOANT   := xZD_PESOANT
			SZD->ZD_PESODEP   := xZD_PESODEP
			SZD->ZD_FRETE     := xZD_FRETE
			SZD->ZD_QTDTOT    := xZD_QTDTOT
			SZD->ZD_TRANSP    := xZD_TRANSP

			SZD->ZD_VEIC1     := xZD_VEIC1
			SZD->ZD_VEIC2     := xZD_VEIC2
			SZD->ZD_VEIC3     := xZD_VEIC3

			SZD->ZD_MOTOR1    := xZD_MOTOR1
			SZD->ZD_MOTOR2    := xZD_MOTOR2
			SZD->ZD_MOTOR3    := xZD_MOTOR3

			SZD->ZD_PLACA1    := xZD_PLACA1
			SZD->ZD_PLACA2    := xZD_PLACA2
			SZD->ZD_PLACA3    := xZD_PLACA3

			SZD->ZD_QTVE1     := xZD_QTVE1
			SZD->ZD_QTVE2     := xZD_QTVE2
			SZD->ZD_QTVE3     := xZD_QTVE3

			SZD->ZD_VAVE1     := xZD_VAVE1
			SZD->ZD_VAVE2     := xZD_VAVE2
			SZD->ZD_VAVE3     := xZD_VAVE3

			SZD->ZD_TPFRETE   := xZD_TPFRETE

			SZD->ZD_VLFRET    := xZD_VLFRET

			SZD->ZD_DASFPRE   := xZD_DASFPRE
			SZD->ZD_DCHPREV   := xZD_DCHPREV
			SZD->ZD_DTOTPRE   := xZD_DTOTPRE

			MsUnlock()

		Endif

		SZD->( dbSkip() )
	Enddo
	Restarea( area )
	dbSelectArea('SZD')
	dbGoto( recSzd )
Return
//
// Valida Rastro, que não deve constar na tabela SZE ou no aCols atual
//
User Function valRast()
	Local ix
	Private ret  := .T.
	//Private ix
	Private area := GetArea()

	//testa a base
	ret := ExistChav("SZE",M->ZE_RASTRO,4)

	For ix := 1 To Len(aCols )
		If ix <> n // não testa a linha atual
			If  Rtrim(aCols[ix, _ascan('ZE_RASTRO')]) == Rtrim(M->ZE_RASTRO)   //aCols[n, _ascan('ZE_RASTRO')]
				ret := .F.
				msgbox("Este rastro ja foi lançado neste recebimento!",'Erro!',"STOP")
			Endif
		Endif
	Next ix

	RestArea(area)
Return ret



/*--------------------------------------------------------------------------------------------
15.03.07    Raul Se tipo e compra =Vivo, peso é obrigatório
29.03.07    Raul Calcular o peso unitário de um animal  de forma automática quanto o tipo de compra for vivo
09.05.07    Raul validar se o rastro já não foi lançado
21.06.07    Raul Separação do valor do frete para cada tipo de veículo a ser gravado nos campos
ZI_VAVE1,ZI_VAVE2,ZI_VAVE3 
06.07.07    Raul Validacoes para a rotina peso x categoria     
correçao */


Static Function CalcPsFr()

	If INCLUI
		cPercentual	 := (aCateg[w1,4]/M->ZD_PESOANT)
		cPesoFrig	 := (M->ZD_PESODEP * cPercentual)
	EndIf

	If ALTERA
		cPercentual	 := (aCateg[w1,4]/SZD->ZD_PESOANT)
		cPesoFrig	 := (SZD->ZD_PESODEP * cPercentual)
	EndIf

Return(cPesoFrig)


//Atualiza o lançamento de animais por veículos
Static Function AtVeic(_cNumOR)

	SZS->(DbSetOrder(1)) 
	SZE->(DbSetOrder(6))
	SZE->(DbGoTop()) 
	SZS->(DbGoTop())
	SZE->(DbSeek(xfilial('SZE')+_cNumOR)) 
	if SZS->(DbSeek(xfilial('SZS')+_cNumOR))
		while SZS->(!eof()) .and. SZS->ZS_FILIAL = xfilial('SZS') .and. SZS->ZS_NUMERO = _cNumOR
			if SZE->(DbSeek(xfilial('SZE')+SZS->(ZS_NUMERO+ZS_PLACA+ZS_HORA)))
				SZS->(DbSkip())
				loop
			else
				reclock('SZS',.f.)
				dbdelete()
				msunlock()
			endif
			SZS->(DbSkip())
		enddo
	endif

	SZE->(DbSetOrder(6))
	SZE->(DbGotop()) 
	SZE->(DbSeek(xfilial('SZE')+_cNumOR)) 
	_nAnim  := 0
	_cChave := ''
	while SZE->(!eof()) .and. SZE->ZE_FILIAL = xfilial('SZE') .and. SZE->ZE_NUMERO = _cNumOR

		SZS->(DbGoTop())
		SZS->(DbSetOrder(1))
		if SZS->(DbSeek(xfilial('SZS')+SZE->(ZE_NUMERO+ZE_PLACA+ZE_HORA))) 
			//	alert('Achou placa ' + SZE->ZE_PLACA)
			_cChave := SZE->(ZE_NUMERO+ZE_PLACA+ZE_HORA) 
			_nAnim += SZE->ZE_QTD1UM 
			reclock('SZS',.f.)
			SZS->ZS_QTANIM := _nAnim
			msunlock()
		else   
			//alert('Insere placa ' + SZE->ZE_PLACA)
			reclock('SZS',.t.)
			SZS->ZS_FILIAL := xfilial('SZS')  
			SZS->ZS_NUMERO := SZE->ZE_NUMERO
			SZS->ZS_QTANIM := SZE->ZE_QTD1UM
			SZS->ZS_PLACA  := SZE->ZE_PLACA
			SZS->ZS_HORA   := SZE->ZE_HORA
			msunlock()
		endif

		SZE->(DbSkip())  
		if _cChave <> SZE->(ZE_NUMERO+ZE_PLACA+ZE_HORA).and. SZE->(!eof())
			_nAnim  := 0
		endif
	enddo
	DbClosearea('SZS')

Return .t.


Static Function AtPeso(_cNumOR)     

	SZR->(DbSetOrder(1))
	SZE->(DbSetOrder(7))
	SZR->(DbGotop())
	SZE->(DbGotop()) 

	if SZR->(DbSeek(xfilial('SZR')+_cNumOR))
		While SZR->(!eof()) .and. SZR->ZR_RECEB = _cNumOR .and. SZR->ZR_FILIAL = xfilial('SZR')  
			_cRastro := iif(SZR->ZR_RASTRO = 'N',' ','S')
			if SZE->(DbSeek(xfilial('SZE')+SZR->(ZR_RECEB+ZR_CATEG)+_cRastro))
				SZR->(DbSkip())
				loop
			else
				reclock('SZR',.f.)
				dbdelete()
				msunlock()
			endif
			SZR->(DbSkip())
		enddo  

	endif
	SZE->(DbGoTop())
	SZE->(DbSeek(xfilial('SZE')+_cNumOR))

	While SZE->(!eof()) .and. SZE->ZE_FILIAL = xfilial('SZE') .and. SZE->ZE_NUMERO = _cNumOR
		_cRastro := iif(empty(SZE->ZE_RASTRO),'N','S')     
		SZR->(DbGoTop())  
		if !(SZR->(DbSeek(xfilial('SZR')+SZE->(ZE_NUMERO+ZE_CATEG)+_cRastro)) )  
			reclock('SZR',.t.)
			SZR->ZR_FILIAL := xfilial('SZR')  
			SZR->ZR_RECEB  := SZE->ZE_NUMERO
			SZR->ZR_CATEG  := SZE->ZE_CATEG
			SZR->ZR_RASTRO := _cRastro 
			msunlock()
		endif                           
		SZE->(DbSkip())
	enddo  

	DbCloseArea('SZR')
Return .t.
