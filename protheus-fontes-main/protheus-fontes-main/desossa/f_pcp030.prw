#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F_PCP030     º Autor ³ 3v Technology   º Data ³  17/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de entrada e saída da desossa                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function F_PCP030()

	Private cCadastro := "Entrada/saida da desossa"

	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
	{"Visualizar","AxVisual",0,2} ,;
	{"Entrada","U_pcp030En",0,3} ,;
	{"Saída","U_pcp030Sai",0,3} ,;
	{"Cancelar","AxDeleta",0,5} }

	cPerg := "PCP030"
	Pergunte(cPerg,.F.)
	SetKey(123,{|| Pergunte(cPerg,.T.)}) // Seta a tecla F12 para acionamento dos parametros

	Private cDelFunc := ".T."
	Private cString := "SZO"
	dbSelectArea("SZO")
	dbSetOrder(1) // tipo+data+sequencia
	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString)
Return
//
// Entrada da desossa, charque, moida
//
User Function Pcp030En()
	Local i
	cMsg     := Space(30)
	nDIg     := 0
	nOpma    := 0
	aObjects := {}
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	odlg  := nil

	SB1->(dbSetorder(1))


	aCols   := {}

	//Totais
	nTotQtde := 0
	nTotVal  := 0


	Private prox := 0
	dbSelectArea('SZO')
	SZO->(dbSetorder(1))  // tipo+data+sequen
	SZO->( dbSeek(xFilial('SZO')+'E'+DTOS(ddatabase) ) )
	Do While !SZO->(Eof()) .AND. SZO->ZO_DATA == ddatabase .AND. SZO->ZO_TIPO == 'E'
		prox := Val( SZO->ZO_SEQUEN )
		SZO->( dbSkip() )
	Enddo
	SZO->( dbSkip(-1) )


	Do While !SZO->(Bof()) .AND. SZO->ZO_DATA == ddatabase .AND. SZO->ZO_TIPO == 'E'

		SB1->( dbSeek( xFilial('SB1')+SZO->ZO_PROD ) )
		If SZO->ZO_DEST == 'D'
			nTotQtde += SZO->ZO_QUANT
			nTotVal  += SZO->ZO_PESOL
		Endif

		AADD( aCols, { SZO->ZO_HORA,;  //1
		SB1->B1_DESC,;  //2
		SZO->ZO_QUANT,; //3
		SZO->ZO_PESOL,; //4
		SZO->ZO_PROD,;  //5
		SZO->ZO_DEST,;  //6
		SZO->ZO_DATA,;  //7
		SZO->ZO_PESOB,; //8
		SZO->ZO_TARA,;  //9
		SZO->ZO_TIPO,;  //10
		SZO->ZO_SEQUEN,;  //11
		.F. } )
		SZO->( dbSkip(-1) )
	Enddo

	//Hora, descricao, quantidade, peso liquido
	aStru := {}                                                                    //CAMPOS NO MULTILINE

	aadd(aStru,{"ZO_HORA"     ,"N",  6,  0,   "99:99"          , 'Hora'})          //1
	aadd(aStru,{"DESC"        ,"C",  30, 0,   "@!"             , 'Descrição'})     //2
	aadd(aStru,{"ZO_QUANT"    ,"N",  5,  2,   "@E 9,999.99"    , 'Quantidade'})    //3
	aadd(aStru,{"ZO_PESOL"    ,"N",  5,  2,   "@E 9,999.99"    , 'Peso Liq.'})     //4
	aadd(aStru,{"ZO_PROD"     ,"C", 15,  0,   "@X"             , 'Produto'})       //5
	aadd(aStru,{"ZO_DEST"     ,"C",  1,  0,   "X"              , 'Destino' })      //6
	aadd(aStru,{"ZO_DATA"     ,"D",  8,  0,   "X"              , 'Data'    })      //7
	aadd(aStru,{"ZO_PESOB"    ,"N",  5,  2,   "X"              , 'Peso Bruto' })   //8
	aadd(aStru,{"ZO_TARA"     ,"N",  5,  2,   "X"              , 'Tara'       })   //9
	aadd(aStru,{"ZO_TIPO"     ,"C",  1,  2,   "X"              , 'Tipo Mov.'  })   //10
	aadd(aStru,{"ZO_SEQUEN"   ,"C",  6,  0,   "999999"         , 'Sequênc.'   })   //11

	aHeader := {} ;  aButtons:= {}

	aAltera := {"ZO_HORA","ZO_QUANT","ZO_PESOL"}

	//DbSelectarea('SX3')
	//DbSetOrder(2)
	//For i:=1 to len(aStru)                                                                               //Header
	//	If DbSeek(padr(astru[i,1],10))                                                                   //existe no dic inf de lá
	//		aAdd(aHeader,{aStru[i,6]    , X3_CAMPO   , X3_PICTURE ,;
	//		X3_TAMANHO    , X3_DECIMAL , X3_VALID ,;
	//		X3_USADO      , X3_TIPO    , X3_ARQUIVO, X3_CONTEXT })
	//	else                                                                                         //nao existe pega da estrutura
	//		aAdd(aHeader,{iif(empty(aStru[i,6]), aStru[i,1], aStru[i,6]), aStru[i,1], aStru[i,5] ,;
	//		aStru[i,3], aStru[i,4], '' ,;
	//		''         , aStru[i,2], '', 'R'})
	//	Endif
	//Next

	_cAlias  := "SZO"
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	_cAcols  := "ZO_HORA/ZO_QUANT/ZO_PESOL/ZO_PROD/ZO_DEST/ZO_DATA/ZO_PESOB/ZO_TARA/ZO_TIPO/ZO_SEQUEN"
	For i := 1 To Len(_aCpoSX3)
		If i == 2
			aAdd(aHeader, { GetSx3Cache("B1_DESC", 'X3_DESCRIC')	,;
							GetSx3Cache("B1_DESC", 'X3_CAMPO')		,;
							GetSx3Cache("B1_DESC", 'X3_PICTURE')	,;
							GetSx3Cache("B1_DESC", 'X3_TAMANHO')	,;
							GetSx3Cache("B1_DESC", 'X3_DECIMAL')	,;
							GetSx3Cache("B1_DESC", 'X3_VALID')		,;
							GetSx3Cache("B1_DESC", 'X3_USADO')		,;
							GetSx3Cache("B1_DESC", 'X3_TIPO')		,;
							GetSx3Cache("B1_DESC", 'X3_ARQUIVO')	,;
							GetSx3Cache("B1_DESC", 'X3_CONTEXT')	})
		Else
			If(X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) .And. AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) $ _cAcols)
				aAdd(aHeader, { GetSx3Cache(_aCpoSX3[i], 'X3_DESCRIC')	,;
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
		EndIf
	Next i

	cProd  := space(15)
	nTara  := mv_par04

	nPesob := 0.00
	nPesol := 0.00
	nQuant := 0.00

	nDestino := 1

	aOpcoes := {"Desossa","Charque","Carne Moida"}


	Do while .t.                //loop ate encerra no botao x

		lok := .t.

		DEFINE MSDIALOG oDlg TITLE "Entrada da desossa" ;
		from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

		oSay := tSay():New(20,5,{||'Produto'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)

		@ 20,040 GET cProd PICTURE "XXXXXX" F3 'BB7' Object oGet  valid v_prod()

		oSay := tSay():New(20,73,{|| cMsg  },oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)

		oSay := tSay():New(35,5,{||'Destino'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)
		@ 35,040 Radio aOpcoes Var nDestino

		oSay := tSay():New(20,200,{||'Quantidade:'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)
		@ 20,230 Get nQuant PICTURE '@E 999,999.99'  Size 65,8 OBJECT oQt //Valid nQuant > 0

		oSay := tSay():New(30,200,{||'Peso Bruto:'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)
		@ 30,230 Get nPesob PICTURE '@E 999,999.99' Size 65,8

		oSay := tSay():New(40,200,{||'Tara      :'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)
		@ 40,230 Get nTara PICTURE '@E 999,999.99' Size 65,8

		@ 20,300    BUTTON 'Pesar._Ok'   SIZE 47,20 ACTION If(!empty(cprod) .and. nquant > 0, ;
		u_pcp030_bal(@nPesob,'E'),Alert('Digite o produto e a Qtde.!'))  OBJECT oBtn3
		//ENABLE OF !Empty(cProd)//When !Empty(cProd)
		//	@ 20,360    BUTTON 'Relatório'   SIZE 47,20 ACTION EVAL({||u_pcp030_imp(), Pergunte(cPerg,.T.) })
		@ 20,420    BUTTON 'Excluir'     SIZE 47,20 ACTION u_pcp030_exc()

		//Totais
		oSay := tSay():New(280,5,{||'Total desossa'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)

		oSay := tSay():New(280,40,{||'Qtde:'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)

		oSay := tSay():New(280,110,{||Transform(nTotQtde,'@e 999,999.99')},oDlg,,,,;
		,,.T.,CLR_HRED,CLR_HRED)


		oSay := tSay():New(280,170,{||'Peso Líquido:'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)

		oSay := tSay():New(280,220,{||Transform(nTotVal,'@e 999,999.99')},oDlg,,,,;
		,,.T.,CLR_HRED,CLR_HRED)

		oGetDad := MSGetDados():New(aPosObj[2,1]-30, aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
		4, "U_PCP030LOK", "U_PCP030TOK", "", .T.,;
		aAltera,,.t.,1000,"Allwaystrue")

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := .t., oDlg:End()},;
		{||lok := .f., oDlg:end()};
		,,aButtons)

		If !lOk                                                                            //botao X (encerra)
			Return
		Endif

		aCols := {}

		Exit
	Enddo
Return

//
// Saida da desossa
//
User Function Pcp030Sai()
	Local i
	cMsg     := Space(25)
	nDIg     := 0
	nOpma    := 0
	aObjects := {}
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	odlg  := nil

	SB1->(dbSetorder(1))

	Private prox := 0

	aCols   := {}

	//Totais
	nTotQtde := 0
	nTotVal  := 0

	dbSelectArea('SZO')
	SZO->(dbSetorder(1))  // tipo+data+sequen


	SZO->( dbSeek(xFilial('SZO')+'S'+DTOS(ddatabase) ) )
	Do While !SZO->(Eof()) .AND. SZO->ZO_DATA == ddatabase .AND. SZO->ZO_TIPO == 'S'
		prox := Val( SZO->ZO_SEQUEN )
		dbSkip()
	Enddo
	dbSkip(-1)

	//Carga do Acols // em ordem decrescente
	Do While !SZO->(Bof()) .AND. SZO->ZO_DATA == ddatabase .AND. SZO->ZO_TIPO == 'S'
		SB1->( dbSeek( xFilial('SB1')+SZO->ZO_PROD ) )

		If SZO->ZO_DEST == 'D'
			nTotQtde += SZO->ZO_QUANT
			nTotVal  += SZO->ZO_PESOL
		Endif

		AADD( aCols, { SZO->ZO_HORA,;  //1
		SB1->B1_DESC,;  //2
		SZO->ZO_QUANT,; //3
		SZO->ZO_PESOL,; //4
		SZO->ZO_PROD,;  //5
		SZO->ZO_DEST,;  //6
		SZO->ZO_DATA,;  //7
		SZO->ZO_PESOB,; //8
		SZO->ZO_TARA,;  //9
		SZO->ZO_TIPO,;  //10
		SZO->ZO_SEQUEN,;  //11
		.F. } )
		SZO->( dbSkip(-1) )
	Enddo

	//Hora, descricao, quantidade, peso liquido
	aStru := {}                                                                    //CAMPOS NO MULTILINE

	aadd(aStru,{"ZO_HORA"     ,"N",  6,  0,   "99:99"          , 'Hora'})          //1
	aadd(aStru,{"DESC"        ,"C",  30, 0,   "@!"             , 'Descrição'})     //2
	aadd(aStru,{"ZO_QUANT"    ,"N",  5,  2,   "@E 9,999.99"    , 'Quantidade'})    //3
	aadd(aStru,{"ZO_PESOL"    ,"N",  5,  2,   "@E 9,999.99"    , 'Peso Liq.'})     //4
	aadd(aStru,{"ZO_PROD"     ,"C", 15,  0,   "@X"             , 'Produto'})       //5
	aadd(aStru,{"ZO_DEST"     ,"C",  1,  0,   "X"              , 'Destino' })      //6
	aadd(aStru,{"ZO_DATA"     ,"D",  8,  0,   "X"              , 'Data'    })      //7
	aadd(aStru,{"ZO_PESOB"    ,"N",  5,  2,   "X"              , 'Peso Bruto' })   //8
	aadd(aStru,{"ZO_TARA"     ,"N",  5,  2,   "X"              , 'Tara'       })   //9
	aadd(aStru,{"ZO_TIPO"     ,"C",  1,  2,   "X"              , 'Tipo Mov.'  })   //10
	aadd(aStru,{"ZO_SEQUEN"   ,"C",  6,  0,   "999999"         , 'Sequênc.'   })   //11


	aHeader := {} ;  aButtons:= {}

	aAltera := {"ZO_HORA","ZO_QUANT","ZO_PESOL"}

	//DbSelectarea('SX3')
	//DbSetOrder(2)
	//For i:=1 to len(aStru)                                                                               //Header
	//	If DbSeek(padr(astru[i,1],10))                                                                   //existe no dic inf de lá
	//		aAdd(aHeader,{aStru[i,6]    , X3_CAMPO   , X3_PICTURE ,;
	//		X3_TAMANHO    , X3_DECIMAL , X3_VALID ,;
	//		X3_USADO      , X3_TIPO    , X3_ARQUIVO, X3_CONTEXT })
	//	else                                                                                         //nao existe pega da estrutura
	//		aAdd(aHeader,{iif(empty(aStru[i,6]), aStru[i,1], aStru[i,6]), aStru[i,1], aStru[i,5] ,;
	//		aStru[i,3], aStru[i,4], '' ,;
	//		''         , aStru[i,2], '', 'R'})
	//	Endif
	//Next

	_cAlias  := "SZO"
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	_cAcols  := "ZO_HORA/ZO_QUANT/ZO_PESOL/ZO_PROD/ZO_DEST/ZO_DATA/ZO_PESOB/ZO_TARA/ZO_TIPO/ZO_SEQUEN"
	For i := 1 To Len(_aCpoSX3)
		If i == 2
			aAdd(aHeader, { GetSx3Cache("B1_DESC", 'X3_DESCRIC')	,;
							GetSx3Cache("B1_DESC", 'X3_CAMPO')		,;
							GetSx3Cache("B1_DESC", 'X3_PICTURE')	,;
							GetSx3Cache("B1_DESC", 'X3_TAMANHO')	,;
							GetSx3Cache("B1_DESC", 'X3_DECIMAL')	,;
							GetSx3Cache("B1_DESC", 'X3_VALID')		,;
							GetSx3Cache("B1_DESC", 'X3_USADO')		,;
							GetSx3Cache("B1_DESC", 'X3_TIPO')		,;
							GetSx3Cache("B1_DESC", 'X3_ARQUIVO')	,;
							GetSx3Cache("B1_DESC", 'X3_CONTEXT')	})
		Else
			If(X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) .And. AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) $ _cAcols)
				aAdd(aHeader, { GetSx3Cache(_aCpoSX3[i], 'X3_DESCRIC')	,;
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
		EndIf
	Next i

	cProd  := space(15)
	nTara  := mv_par04

	nPesob := 0.00
	nPesol := 0.00
	nQuant := 0.00

	nDestino := 1

	Do while .t.                //loop ate encerra no botao x

		lok := .t.

		DEFINE MSDIALOG oDlg TITLE "Saída da desossa" ;
		from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

		oSay := tSay():New(20,5,{||'Produto'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)

		@ 20,040 GET cProd PICTURE "XXXXXX" F3 'SB1' Object oGet  valid v_prod()

		oSay := tSay():New(20,73,{|| cMsg  },oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)

		oSay := tSay():New(20,200,{||'Quantidade:'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)
		@ 20,230 Get nQuant PICTURE '@E 999,999.99'  Size 65,8 OBJECT oQt

		oSay := tSay():New(30,200,{||'Peso Bruto:'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)
		@ 30,230 Get nPesob PICTURE '@E 999,999.99' Size 65,8

		oSay := tSay():New(40,200,{||'Tara      :'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)
		@ 40,230 Get nTara PICTURE '@E 999,999.99' Size 65,8

		@ 20,300    BUTTON 'Pesar._Ok'   SIZE 47,20 ACTION If( !Empty(cProd) .and. nQuant > 0, ;
		u_pcp030_bal(@nPesob,'S'),Alert('Digite o produto e a Qtde.!') ) OBJECT oBtn3
		//	@ 20,360    BUTTON 'Relatório'   SIZE 47,20 ACTION EVAL({||u_pcp030_imp(), Pergunte(cPerg,.T.) })
		@ 20,420    BUTTON 'Excluir'     SIZE 47,20 ACTION u_pcp030_exc()

		//Totais
		oSay := tSay():New(280,5,{||'Total desossa'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)

		oSay := tSay():New(280,40,{||'Qtde:'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)

		oSay := tSay():New(280,110,{||Transform(nTotQtde,'@e 999,999.99')},oDlg,,,,;
		,,.T.,CLR_HRED,CLR_HRED)


		oSay := tSay():New(280,170,{||'Peso Líquido:'},oDlg,,,,;
		,,.T.,CLR_HBLUE,CLR_HBLUE)

		oSay := tSay():New(280,220,{||Transform(nTotVal,'@e 999,999.99')},oDlg,,,,;
		,,.T.,CLR_HRED,CLR_HRED)

		oGetDad := MSGetDados():New(aPosObj[2,1]-30, aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
		4, "U_PCP030LOK", "U_PCP030TOK", "", .T.,;
		aAltera,,.t.,1000,"Allwaystrue")

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := .t., oDlg:End()},;
		{||lok := .f., oDlg:end()};
		,,aButtons)

		If !lOk                                                                            //botao X (encerra)
			Return
		Endif

		aCols := {}

		Exit
	Enddo
Return
//
//
//
Static Function v_prod()
	If Empty( cProd )
		lAc := .T.
	Else
		lac := ExistCpo("SB1",cProd,1)
		SB1->( dbSeek(xFilial('SB1')+cProd ) )
		If lac
			cMsg := Left(SB1->B1_DESC,30)
			osay:Refresh()
			oGetDad:Refresh()
			odlg:Refresh()
		Endif
	Endif
	//Seta o foco para a quantidade
	oQt:Setfocus()
Return lAc
//
//
//
User Function PCP030LOK()
	osay:Refresh()
	oGetDad:Refresh()
	odlg:Refresh()
Return .t.
//
//
//
User Function PCP030TOK()
Return .t.
//
//
//
//Numero da linha
//
Static Function _ascan(cCampo)
Return ascan(aHeader,{|x|alltrim(x[2])==cCampo})
//
//  Captura a pesagem e salva os dados
//
User Function pcp030_bal(v,oper)

	cCom     := mv_par01  //comunicao balanca
	nDec     := mv_par02  //precisao balanca
	lBalan   := mv_par03 == 1 // situacao balanca

	If lBalan
		nHdll := 0
		if !MSOpenPort(nHdll,cCom)
			msgbox("Não foi possível pegar informações da porta",,"STOP")
			Return 0
		endif

		cText := space(15)
		if !MsRead(nHdll,@cText)
			msgbox("Não foi possível pegar informações da porta",,"STOP")
			Return 0
		endif

		inkey(1)
		if empty(cText)
			inkey(1)
			cText := space(15)
			MsRead(nHdll,@cText)
		endif

		do Case
			Case at("p`",cText)> 0
			cPeso := substr(cText,at("p`",cText)+2,6)
			cC := "`"

			Case at("`",cText) > 0
			cPeso := substr(cText,at("`",cText)+1,6)
			cC := "`"

			Case at("p ",cText)> 0
			cPeso := substr(cText,at("p ",cText)+2,6)
			cC := " "

			Otherwise
			cPeso :='000000'
			cC := ""
		Endcase

		cPeso := substr(cText,at("`",cText)+1,6)
		cPeso := substr(cText,at(cC,cText)+1,6)

		nPeso := val(cPeso)/(10**nDec)

		if valtype(nPeso) == 'N'
			v := npeso
		else
			v     := 0
			nPeso := 0
		endif


		//oenc:Refresh()
		msClosePort(nHdll)

	Else
		nPeso := nPesob
	Endif

	Msgbox('Peso(kg): '+Transform(nPeso,'@e 99,999.9999'),"Informação","INFO")


	//Atualiza liquido
	nPesol   := nPeso - nTara

	If nPesol <= 0
		Msgbox('Peso(kg) não pode ser menor ou igual a zero!)',"Erro!","ERRO")
		Return 0
	Endif

	//Salva registro
	prox++
	reg   := { TIME(),SB1->B1_DESC,nQuant,nPesol,cProd,Dest(nDestino),ddatabase,nPeso,nTara, oper,Strzero(prox,6), .f. }

	Begin TRansaction

		RECLOCK('SZO',.t.)
		SZO->ZO_FILIAL  := xFilial('SZL')
		SZO->ZO_HORA    := Reg[1]      //aCols[i,_ascan('ZO_HORA') ]
		SZO->ZO_QUANT   := Reg[3]      //aCols[i,_ascan('ZO_QUANT')]
		SZO->ZO_PESOL   := Reg[4]      //aCols[i,_ascan('ZO_PESOL')]
		SZO->ZO_PROD    := Reg[5]      //cProd
		SZO->ZO_DEST    := Reg[6]      //aCols[i,_ascan('ZO_DEST')]
		SZO->ZO_DATA    := Reg[7]      //ddatabase
		SZO->ZO_PESOB   := Reg[8]      //acols[i,_ascan('ZO_PESOB')]
		SZO->ZO_TARA    := Reg[9]      //nTara
		SZO->ZO_TIPO    := Reg[10]     //nTipo
		SZO->ZO_SEQUEN  := STRZERO(prox,6)
		MsUnlock()
	End Transaction


	If Empty(aCols[1,2])
		aCols[1] := reg
	Else
		//1 salva ultimo elemento do array
		ult := Acols[ Len(aCols) ]

		//2 Insere um Nil ao 1o elemento
		Ains( Acols,1 )

		//3 Coloca o ultimo elemento de volta
		AADD( aCols, ult  )

		//4 Adiciona o 1o elemento
		aCols[1] := reg
	Endif


	//Totais de rodape
	If nDestino == 1 //Desossa
		nTotQtde += nQuant
		nTotVal  += nPesol
	Endif

	nPesob := 0.00
	nPesol := 0.00
	nQuant := 0.00

	//Refresh
	osay:Refresh()
	oGetDad:Refresh()
	odlg:Refresh()

	//Seta o foco para a quantidade
	oQt:Setfocus()

Return nPeso
//
//
//
Static Function Dest( nDestino )
	Private cDest := ''
	If nDestino == 1
		cDest := 'D'
	ElseIf nDestino == 2
		cDest := 'C'
	Else
		cDest := 'M'
	Endif
Return cDest

//
//
//
/*
User Function Pcp030_imp
Local cDesc1         := "Este programa tem como objetivo resumo das movimentações"
Local cDesc2         := "de entrada e saida da desossa na database do sistema."
Local cDesc3         := "Entrada e saida da desossa"
Local cPict          := ""
Local titulo       := "Entrada e saida da desossa"
Local nLin         := 80

Local Cabec1       := "Data                               Código           Descrição                        Qtde.   Peso Bruto   Peso Líq."
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 132
Private tamanho          := "M"
Private nomeprog         := "PCP030"
Private nTipo            := 15
Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "PCP030"

Private cString := "SZO"

cPerg := "RPC030"


Pergunte(cPerg,.T.)

wnrel := SetPrint(cString,NomeProg,"RPC030",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
If nLastKey == 27
Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
Return
Endif
nTipo := If(aReturn[4]==1,15,18)
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return
//
//
//
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

datade  := mv_par01
dataate := mv_par02

SZO->(dbSetOrder(2)) // data + tipo + destino + produto

SetRegua(RecCount())

datax    := ddatabase
qtdia    := 0
pesoldia := 0
pesobdia := 0

SZO->( dbSeek(xFilial('SZO')+DTOS(datade),.t. ) )




While ! SZO->(EOF()) .AND. SZO->ZO_DATA <= dataate

datax := SZO->ZO_DATA

If nLin > 55
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 8
Endif


@ nLin,0  PSAY DTOC(datax)
nLin += 2

While ! SZO->(EOF()) .AND. SZO->ZO_DATA == datax

tipomov := SZO->ZO_TIPO
qtmov    := 0
pesolmov := 0
pesobmov := 0

cTipo := If( tipomov == 'E', 'Entrada - ','Saida - ')
If nLin > 55
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 8
Endif

While ! SZO->(EOF()) .AND. SZO->ZO_DATA == datax .AND. SZO->ZO_TIPO == tipomov

destino := SZO->ZO_DEST
qtdest    := 0
pesoldest := 0
pesobdest := 0

If nLin > 55
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 8
Endif
@ nLin,0 PSAY cTipo + If( destino == 'D', 'Desossa ', If( destino == 'C','Charque','Moida'  ))
nLin += 2

While ! SZO->(EOF()) .AND. SZO->ZO_DATA == datax .AND. SZO->ZO_TIPO == tipomov .AND. ;
SZO->ZO_DEST == destino

prod  := SZO->ZO_PROD
qt    := 0
pesol := 0
pesob := 0

While ! SZO->(EOF()) .AND. SZO->ZO_DATA == datax .AND. SZO->ZO_TIPO == tipomov .AND. ;
SZO->ZO_DEST == destino  .AND. 	prod == SZO->ZO_PROD

qtdia    += SZO->ZO_QUANT
pesoldia += SZO->ZO_PESOL
pesobdia += SZO->ZO_PESOB

qtmov    += SZO->ZO_QUANT
pesolmov += SZO->ZO_PESOL
pesobmov += SZO->ZO_PESOB

qtdest    += SZO->ZO_QUANT
pesoldest += SZO->ZO_PESOL
pesobdest += SZO->ZO_PESOB

qt    += SZO->ZO_QUANT
pesol += SZO->ZO_PESOL
pesob += SZO->ZO_PESOB

If lAbortPrint
@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
Exit
Endif
dbSkip()
Enddo

SB1->( dbSeek(xFilial('SB1')+prod  ) )

If nLin > 55
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 8
Endif

@ nLin,035      PSAY prod
@ nLin,PCOL()+2 PSAY Left(SB1->B1_DESC,30)
@ nLin,PCOL()+2 PSAY qt     PICTURE '@E 999999'
@ nLin,PCOL()+2 PSAY pesol  PICTURE '@E 999,999.99'
@ nLin,PCOL()+2 PSAY pesob  PICTURE '@E 999,999.99'

nLin++

Enddo
//                  123456789012345
nLin++
@ nLin,035    PSAY 'Sub Total      '
@ nLin,PCOL()+2 PSAY Space(30)
@ nLin,PCOL()+2 PSAY qtdest     PICTURE '@E 999999'
@ nLin,PCOL()+2 PSAY pesoldest  PICTURE '@E 999,999.99'
@ nLin,PCOL()+2 PSAY pesobdest  PICTURE '@E 999,999.99'
nLin++
@ nLin, 000 PSay __PrtThinLine()
nLin++

Enddo
EndDo
Enddo


//                  123456789012345
@ nLin,035    PSAY 'Total geral    '
@ nLin,PCOL()+2 PSAY Space(30)
@ nLin,PCOL()+2 PSAY qtdia      PICTURE '@E 999999'
@ nLin,PCOL()+2 PSAY pesoldia   PICTURE '@E 999,999.99'
@ nLin,PCOL()+2 PSAY pesobdia   PICTURE '@E 999,999.99'


Set device to screen
If aReturn[5]==1
dbCommitAll()
SET PRINTER TO
OurSpool(wnrel)
Endif

MS_FLUSH()

SZO->( dbSetOrder(1) )
Return 
*/
//
//
//
User function pcp030_exc()
	aCols[n,Len(aCols[1])] := .T. //marca no browse

	SZO->( dbSetOrder(1) )
	// tipo mov  +   data          +  sequen
	If SZO->( dbSeek(xFilial('SZO')+aCols[n,10]+Dtos(aCols[n,7])+aCols[n,11] ) )
		Reclock('SZO',.F.)
		SZO->( dbDelete() )
		MsUnlock()
	Endif
	//Seta o foco para a quantidade
	oQt:Setfocus()

Return .t.
//
//
//

