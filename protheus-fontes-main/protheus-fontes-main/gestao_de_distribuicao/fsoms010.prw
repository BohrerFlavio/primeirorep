#INCLUDE "Protheus.ch"
#INCLUDE "fsomsa010.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"

#DEFINE MAXGETDAD 99999
#DEFINE MAXSAVERESULT 99999

Static aUltResult
Static lCenVenda := SuperGetMv("MV_LJCNVDA",,.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ OMSA010  ³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Manutencao da Tabela de Preco                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMSA010                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FSOMSA010()

	Local aCores     := {}
	Private aRotina := MenuDef()

	If FindFunction("LJValCenVd")
		LJValCenVd()
	EndIf

	cCadastro := OemToAnsi(STR0006)	//"Manutencao da Tabela de Precos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica as cores da MBrowse                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aCores,{"Dtos(DA0_DATATE) < Dtos(dDataBase).And. !Empty(Dtos(DA0_DATATE))","DISABLE"}) //inativa
	Aadd(aCores,{"(Dtos(DA0_DATATE) >= Dtos(dDataBase) .Or. Empty(Dtos(DA0_DATATE))).And.DA0_ATIVO =='1'","ENABLE"})    //Ativa simples
	Aadd(aCores,{"(Dtos(DA0_DATATE) >= Dtos(dDataBase) .Or. Empty(Dtos(DA0_DATATE))) .And.DA0_ATIVO =='2'","BR_LARANJA"}) //Ativa especial

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Habilita as perguntas da Rotina                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("OMS010",.F.)
	SetKey(VK_F12,{|| Pergunte("OMS010",.T.)})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para alterar cores do Browse do Cadastro    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("OM010COR")
		aCores := ExecBlock("OM010COR",.F.,.F.,aCores)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Endereca para a funcao MBrowse                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DA0")
	dbSetOrder(1)
	MsSeek(xFilial("DA0"))
	mBrowse(06,01,22,75,"DA0",,,,,,aCores)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a Integridade da Rotina                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DA0")
	dbSetOrder(1)
	dbClearFilter()
	SetKey(VK_F12,Nil)

Return

Static Function Oms010Tab(cAlias,nReg,nOpc,lConsulta,lCopia)
	Local nI
	Private aObjects  := {}
	Private aArea     := GetArea()
	Private aSize     := {}
	Private aInfo     := {}
	Private aButtons  := { { "PESQUISA"   , { || GdSeek(oGetDad,OemtoAnsi(STR0014),,,.T.) }, OemtoAnsi(STR0014), OemtoAnsi(STR0019) } } //"Busca Produto"
	Private aRecno    := {}
	Private aButtonUsr:= {}
	Private nOrderDA1 := 3
	Private nOpcA     := 0
	Private nSaveSx8  := GetSx8Len()
	Private nI        := 0
	Private bSavKey   := SetKey(VK_F12,Nil)
	Private bWhile    := {|| !Eof()}
	Private cKeyDA1   := ""
	Private cProduto  := ""
	Private cDescricao:= ""
	Private cCadastro := OemToAnsi(STR0006)	//"Manutencao da Tabela de Precos"
	Private cQuery    := ""
	Private lAltera   := nOpc==4              // Somente a Alteracao pode ser feita atraves do F12 por produto
	Private lContinua := .T.
	Private lQuery    := .F.
	Private lMemo     := .F.
	Private nTipo	    := 0
	Private bCond     := {|| !lCopia }
	Private bAction1  := {|| Oms010aRec(@aRecNo,lQuery) }
	Private bAction2  := {|| .T. }
	Private aNoFields := {}
	Private oDlg
	Private oGetD
	Private aColsBkp    := {}
	Private nOrderComp  := 0
	Private cKeyComp    := ""
	Private lReferencia := .F.
	Private lGrade      := DA1->(FieldPos("DA1_ITEMGR")) > 0 .And. MaGrade()
	Private bMontCols   := Nil
	Private aIntDA0		:= {}
	Private aoIntDA1		:= {}
	Private aPosObj   := {}

	Private aHeader := {}
	Private aCols   := {}
	Private aTELA[0][0],aGETS[0]
	Private oGrade := MsMatGrade():New("oGrade",,"DA1_PRCVEN","OMSASomG()","Positivo().And.OMSACalV()",,{{"DA1_PRCVEN",.T.,,.T.},;
	{"DA1_VLRDES",.T.,,.T.},;
	{"DA1_PERDES",.T.,,.T.}})
	Private oGetDad

	DEFAULT INCLUI    := .F.
	DEFAULT lConsulta := .F.
	DEFAULT lCopia    := .F.

	Pergunte("OMS010",.F.)
	nTipo  := mv_par01
	lGrade := lGrade .And. (INCLUI .Or. nTipo == 1)

	OMSA010Int( 1, nOpc, aIntDA0, aoIntDA1 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se outro programa estiver consultando a tabela de precos a visualizacao podera ser feita atraves do produto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(lConsulta) == "L"
		If lConsulta
			If !lAltera
				lAltera := .T.
			Endif
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui botoes de usuario  na enchoicebar                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ExistBlock("OS010BTN")
		aButtonUsr := ExecBlock("OS010BTN",.F.,.F.)
		If ValType(aButtonUsr) == "A"
			For nI   := 1  To  Len(aButtonUsr)
				Aadd(aButtons,aClone(aButtonUsr[nI]))
			Next nI
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa os parametros da rotina                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCopia
		mv_par01 := 1
		nTipo    := 1
	Endif

	Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Manutencao por Tabela                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case MV_PAR01 == 1 .Or. INCLUI

		If nOpc == 5
			lContinua := Os010CanDel(DA0->DA0_CODTAB)
		Endif

		If lContinua

			MV_PAR01 := 1
			nTipo    := 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicializa as variaveis da Enchoice                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If INCLUI .Or. lCopia
				RegToMemory( "DA0", .T., .F. )
			EndIf
			If !INCLUI .Or. lCopia

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se eh alteracao ou exclusao                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If aRotina[nOpc][4] == 4 .Or. aRotina[nOpc][4] == 5
					lContinua :=  SoftLock("DA0")
				Endif

				If lCopia .Or. lContinua
					If !lCopia
						RegToMemory( "DA0", .F., .F. )
					EndIf

					#IFDEF TOP

					dbSelectArea("DA1")
					dbSetOrder(3)

					If TcSrvType() <> "AS/400" .And. !lMemo

						bMontCols := {|aCols,aHeader| MontaCols(aCols,aHeader,lCopia,@aRecno)}

						lQuery    := .T.
						cQuery := "SELECT DA1.*,DA1.R_E_C_N_O_ DA1RECNO, B1_DESC, B1_PRV1 FROM "
						cQuery += RetSqlName("DA1")+ " DA1 "
						cQuery += "LEFT JOIN " +RetSqlName("SB1")+ " SB1  "
						cQuery += "  ON SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"
						cQuery += "  AND SB1.B1_COD     = DA1.DA1_CODPRO"
						cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
						cQuery += "WHERE DA1.DA1_FILIAL = '"+xFilial("DA1")+"'"
						cQuery += "  AND DA1.DA1_CODTAB = '"+DA0->DA0_CODTAB+"'"
						cQuery += "  AND DA1.D_E_L_E_T_ = ' ' "
						cQuery += "ORDER BY "+SqlOrder(DA1->(IndexKey()))
						bWhile := { || !Eof() }

						cQuery := ChangeQuery(cQuery)

						dbSelectArea("DA1")
						dbCloseArea()

					Else
						#ENDIF
						nOrderDA1 := 3
						cKeyDA1   := xFilial("DA1")+DA0->DA0_CODTAB
						bWhile    := {|| DA1->DA1_FILIAL+DA1->DA1_CODTAB }

						#IFDEF TOP
					Endif
					#ENDIF

				Else
					lContinua := .F.
				EndIf
			EndIf
		Else
			Help(" ",1,"NODELETA")
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Manutencao por Produto                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case MV_PAR01 == 2

		cProduto   := MV_PAR02
		lReferencia:= MatGrdPrrf(@cProduto,.T.)
		cDescricao := MaGetDescGrd(cProduto)

		If Empty(cDescricao)
			SB1->(dbSetOrder(1))
			If SB1->(MsSeek(xFilial("SB1")+cProduto))
				cDescricao := SB1->B1_DESC
			EndIf
		EndIf

		dbSelectArea("DA1")
		dbSetOrder(2)
		cKeyDA1   := xFilial("DA1")+cProduto
		bWhile    := {|| DA1->DA1_FILIAL+DA1->DA1_CODPRO }
		nOrderDA1 := 2

	EndCase
	If lContinua

		If mv_par01 == 2 .And. (!Inclui .Or. !lCopia)		// Por Produto
			aNoFields := {"DA1_CODPRO","DA1_DESCRI","DA1_GRUPO","DA1_REFGRD"}
		Else						// Por Tabela
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ATENCAO!!!Se for PYME retira o campo DA1_REFGRD da GetDados.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !__lPyme
				aNoFields := {"DA1_CODTAB","DA1_DESTAB"}
			Else
				aNoFields := {"DA1_CODTAB","DA1_DESTAB","DA1_REFGRD"}
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aHeader e aCols                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³FillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, aNoFields, aYesFields, lOnlyYes,       ³
		//³				  cQuery, bMountFile, lInclui )                                                                ³
		//³nOpcx			- Opcao (inclusao, exclusao, etc).                                                         ³
		//³cAlias		- Alias da tabela referente aos itens                                                          ³
		//³nOrder		- Ordem do SINDEX                                                                              ³
		//³cSeekKey		- Chave de pesquisa                                                                            ³
		//³bSeekWhile	- Loop na tabela cAlias                                                                        ³
		//³uSeekFor		- Valida cada registro da tabela cAlias (retornar .T. para considerar e .F. para desconsiderar ³
		//³				  o registro)                                                                                  ³
		//³aNoFields	- Array com nome dos campos que serao excluidos na montagem do aHeader                         ³
		//³aYesFields	- Array com nome dos campos que serao incluidos na montagem do aHeader                         ³
		//³lOnlyYes		- Flag indicando se considera somente os campos declarados no aYesFields + campos do usuario   ³
		//³cQuery		- Query para filtro da tabela cAlias (se for TOP e cQuery estiver preenchido, desconsidera     ³
		//³	           parametros cSeekKey e bSeekWhiele)                                                              ³
		//³bMountCols	- Preenchimento do aCols pelo usuario (aHeader e aCols ja estarao criados)                     ³
		//³lInclui		- Se inclusao passar .T. para qua aCols seja incializada com 1 linha em branco                 ³
		//³aHeaderAux	-                                                                                              ³
		//³aColsAux		-                                                                                              ³
		//³bAfterCols	- Bloco executado apos inclusao de cada linha no aCols                                         ³
		//³bBeforeCols	- Bloco executado antes da inclusao de cada linha no aCols                                     ³
		//³bAfterHeader -                                                                                              ³
		//³cAliasQry	- Alias para a Query                                                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		FillGetDados(nOPc,"DA1",nOrderDA1,cKeyDA1,bWhile,{{bCond,bAction1,bAction2}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,bMontCols,Inclui,,,,,,"DA1")
		If lGrade
			aCols := aColsGrade(oGrade,aCols,aHeader,"DA1_CODPRO","DA1_ITEM","DA1_ITEMGR",aScan(aHeader,{|x| AllTrim(x[2]) == "DA1_DESCRI"}))
		EndIf
		If mv_par01 == 1 .Or. Inclui .Or. lCopia
			aCols[1][Ascan(aHeader,{|x| AllTrim(x[2]) == "DA1_ITEM"})] := StrZero(1,Len(DA1->DA1_ITEM)) //Preenche o Item
		EndIf
		If mv_par01 == 2  .And. MaGrade()
			cProdRef    := MV_PAR02
			lReferencia := MatGrdPrrf(@cProdRef,.T.)
			cProdRef    := Padr(cProdRef,Len(DA1->DA1_REFGRD))
			aAreaTrb    := GetArea()
			If lReferencia
				If (len(aCols) == 0 ) .Or. (Len(aCols) > 0 .And. MaConsRefG() )
					If Empty(aCols[Len(aCols),ascan(aHeader,{|x| Alltrim(x[2])=="DA1_CODTAB"})])
						aCols:={}
					Endif
					aColsBkp 	:= aClone(aCols)
					aCols    	:= {}

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ATENCAO!!! A Ordem 4 do SIX da tabela DA1 nao foi criada para os paises diferentes do Brasil ³
					//³com isso o Indice 6 do Brasil e o indice 5 para outros paises.                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nOrderComp	:= IIf(cPaisLoc == "BRA", 6 , 5 )

					cKeyComp	:= xFilial("DA1")+cProdRef
					bWhileComp	:= {|| DA1->DA1_FILIAL+DA1->DA1_REFGRD }
					aHeader		:= {}
					FillGetDados(nOPc,"DA1",nOrderComp,cKeyComp,bWhileComp,{{bCond,bAction1,bAction2}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,/*bMontCols*/,.F.,,,,,,"DA1")
					aEval(aColsBkp, {|z,w| Aadd(aCols, z)})
					aCols       := aSort(aCols,,,{|x,y| x[ascan(aHeader,{|x| Alltrim(x[2])=="DA1_CODTAB"})]+x[ascan(aHeader,{|x| Alltrim(x[2])=="DA1_ITEM"})] < y[ascan(aHeader,{|x| Alltrim(x[2])=="DA1_CODTAB"})]+y[ascan(aHeader,{|x| Alltrim(x[2])=="DA1_ITEM"})] })
				Endif
			Endif
			RestArea(aAreaTrb)
		EndIf
		If MV_PAR01==2
			aHeader[Ascan(aHeader,{|x| AllTrim(x[2]) == "DA1_CODTAB"})][6] := "Oms010Vld()"
		EndIf

		If lQuery
			dbSelectArea("DA1")
			dbCloseArea()
			ChkFile("DA1",.F.)
		EndIf

		dbSelectArea("DA0")
		Do Case
			Case MV_PAR01 == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz o calculo automatico de dimensoes de objetos     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSize := MsAdvSize()
			AAdd( aObjects, { 100, 100, .T., .T. } )
			AAdd( aObjects, { 200, 200, .T., .T. } )
			aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
			aPosObj 	:= MsObjSize( aInfo, aObjects,.T.)

			DA1->(dbGoto(0))

			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
			EnChoice( "DA0", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.T. )
			oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Oms010LOk()",Iif(lCopia,"Oms010TCOk()","Oms010TOk()"),"+DA1_ITEM",.T.,,1,,MAXGETDAD)
			oGetDad := oGetD
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA := 1,If(oGetd:TudoOk(),If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},{||oDlg:End()},,aButtons )
			Case MV_PAR01 == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz o calculo automatico de dimensoes de objetos     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSize := MsAdvSize()
			AAdd( aObjects, { 100, 011, .T., .F. } )
			AAdd( aObjects, { 300, 200, .T., .T. } )
			aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ],2,2}
			aPosObj := MsObjSize( aInfo, aObjects)

			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
			@ aPosObj[1,1],aPosObj[1,2]+000 SAY RetTitle("DA1_CODPRO") SIZE 035,009 OF oDlg PIXEL	//"Produto"
			@ aPosObj[1,1],aPosObj[1,2]+035 MSGET oGet1 VAR cProduto	PICTURE "@!" WHEN .F.	SIZE 085,009 OF oDlg PIXEL
			@ aPosObj[1,1],aPosObj[1,2]+125 MSGET oGet2 VAR cDescricao	PICTURE "@!" WHEN .F.	SIZE 380,009 OF oDlg PIXEL
			dbSelectArea("DA1")
			oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Oms010LOk()","Oms010TOk()",,.T.,,,,MAXGETDAD)
			oGetDad := oGetD
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()},,aButtons)
		EndCase
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rotina de Gravacao da Tabela de preco                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcA == 1 .And. nOpc <> 2
			If lGrade
				aCols := aGradeCols(oGrade,aCols,aHeader,"DA1_CODPRO","DA1_ITEMGR","DA1_PRCVEN","DA1_ITEM")
			EndIf
			Oms010Grv(nOpc-2,nTipo,cProduto,aRecno,lCopia)
			While (GetSx8Len() > nSaveSx8 )
				ConfirmSx8()
			EndDo
			EvalTrigger()

			OMSA010Int( 2, nOpc, aIntDA0, aoIntDA1 )

		Else
			If nOpc <> 2
				While (GetSx8Len() > nSaveSx8 )
					RollBackSx8()
				Enddo
			Endif
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a entrada da Rotina                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MsUnLockAll()
	FreeUsedCode()
	SetKey(VK_F12,bSavKey)
	RestArea(aArea)
Return(nOpcA)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010For ³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de geracao de tabela a partit do cadastro de produtos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Tab()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                       ³±±
±±³          ³ExpN2: Numero do Registro                                     ³±±
±±³          ³ExpN3: Opcao do aRotina                                       ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010For(cAlias,nReg,nOpc)

	Local aCampos   := {}
	Local aPosObj   := {}
	Local aObjects  := {}
	Local aSize     := {}
	Local aButtons  := {}
	Local aButtonUsr:= {}
	Local aArea     := GetArea()
	Local aRecno    := {}

	Local bSavKey   := SetKey(VK_F12,Nil)

	Local cAliasSB1 := "SB1"
	Local cCondicao := ""
	Local cArqInd   := ""
	Local cProduto  := ""
	Local lGrade    := DA1->(FieldPos("DA1_ITEMGR")) > 0 .And. MaGrade()
	Local lQuery    := .F.
	Local lExcLine  := ExistBlock("OS010LCO")
	Local lOs010Col := ExistBlock("OS010COL")

	Local nIndex    := 0
	Local nUsado    := 0
	Local nOpcA     := 0
	Local cItem     := Repl("0",Len(DA1->DA1_ITEM))
	Local nSaveSx8  := GetSx8Len()
	Local nX        := 0
	Local nI        := 0

	Local oDlg
	Local oGetD
	Local i

	Private aHeader := {}
	Private aCols   := {}
	Private aTELA[0][0],aGETS[0]
	Private oGrade := MsMatGrade():New("oGrade",,"DA1_PRCVEN",,"Positivo()",,{{"DA1_PRCVEN",.T.,,.T.},{"DA1_VLRDES",.T.,,.T.},{"DA1_PERDES",.T.,,.T.}})
	Private oGetDad

	INCLUI := .T.
	ALTERA := .F.

	If ExistBlock("OS010BTN")
		aButtonUsr := ExecBlock("OS010BTN",.F.,.F.)
		If ValType(aButtonUsr) == "A"
			For nI   := 1  To  Len(aButtonUsr)
				Aadd(aButtons,aClone(aButtonUsr[nI]))
			Next nI
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa os parametros da rotina                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define variaveis de parametrizacao de lancamentos    ³
	//³                                                      ³
	//³ MV_PAR01 Produto inicial?                            ³
	//³ MV_PAR02 Produto final  ?                            ³
	//³ MV_PAR03 Grupo inicial  ?                            ³
	//³ MV_PAR04 Grupo final    ?                            ³
	//³ MV_PAR05 Tipo inicial   ?                            ³
	//³ MV_PAR06 Tipo final     ?                            ³
	//³ MV_PAR07 Tabela Inicial ?                            ³
	//³ MV_PAR08 Tabela final   ?                            ³
	//³ MV_PAR09 Fator          ?                            ³
	//³ MV_PAR10 Numero decimais?                            ³
	//³ MV_PAR11 Pedido em Carteira? Sim/Nao                 ³
	//³ MV_PAR12 Reaplicar fator?                            ³
	//³ MV_PAR13 Planilha       ?                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Pergunte("OMS10A",.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa as variaveis da Enchoice                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		RegToMemory( "DA0", .T., .F. )

		aCampos := {"DA1_CODTAB","DA1_DESTAB"}
		If lGrade
			aCols := aColsGrade(oGrade,aCols,aHeader,"DA1_CODPRO","DA1_ITEM","DA1_ITEMGR",aScan(aHeader,{|x| AllTrim(x[2]) == "DA1_DESCRI"}))
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o Array aHeader.                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//dbSelectArea("SX3")
		//dbSetOrder(1)
		//MsSeek("DA1")
		//While !Eof() .And. SX3->X3_ARQUIVO == "DA1"
		//	If Ascan(aCampos,AllTrim(SX3->X3_CAMPO)) == 0 .And. X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
		//		Aadd(aHeader, {   AllTrim(X3Titulo()),;
		//		SX3->X3_CAMPO,;
		//		SX3->X3_PICTURE,;
		//		SX3->X3_TAMANHO,;
		//		SX3->X3_DECIMAL,;
		//		SX3->X3_VALID,;
		//		SX3->X3_USADO,;
		//		SX3->X3_TIPO,;
		//		SX3->X3_ARQUIVO,;
		//		SX3->X3_CONTEXT } )
		//		nUsado++
		//	EndIf
		//	dbSelectArea("SX3")
		//	dbSkip()
		//EndDo

		_cAlias  := "DA1"
		_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
		For i := 1 To Len(_aCpoSX3)
			If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 		  .And. ;
			AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "DA1_FILIAL")

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

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o Array aCols.                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		dbSelectArea("SB1")
		dbSetOrder(1)

		#IFDEF TOP

		If TcSrvType() <> "AS/400"

			lQuery    := .T.
			cAliasSB1 := "QRYSB1"

			cQuery := "SELECT B1_COD,B1_DESC,B1_PRV1,B1_MSBLQL "
			cQuery += "FROM "+RetSqlName("SB1")+ " SB1 "
			cQuery += "WHERE "
			cQuery += "B1_FILIAL ='"+xFilial("SB1")+"' AND "
			cQuery += "B1_COD >= '"+mv_par01+"' AND "
			cQuery += "B1_COD <= '"+mv_par02+"' AND "
			cQuery += "B1_GRUPO >= '"+mv_par03+"' AND "
			cQuery += "B1_GRUPO <= '"+mv_par04+"' AND "
			cQuery += "B1_TIPO >= '"+mv_par05+"' AND "
			cQuery += "B1_TIPO <= '"+mv_par06+"' AND "
			cQuery += "SB1.D_E_L_E_T_ = ' '"
			cQuery += "ORDER BY "+SqlOrder(SB1->(IndexKey()))

			If ExistBlock("OM010FIL")
				cQuery := ExecBlock("OM010FIL",.F.,.F.,{cQuery})
			Endif

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)

			TcSetField(cAliasSB1,"B1_PRV1","N",TamSx3("B1_PRV1")[1],TamSx3("B1_PRV1")[2])

		Else
			#ENDIF
			cAliasSB1 := "SB1"
			cArqInd   := CriaTrab(,.F.)

			cCondicao := 'B1_FILIAL == "'+xFilial("SB1")+'" .And.'
			cCondicao += 'B1_COD >= "'+mv_par01+'" .And. B1_COD <= "'+mv_par02+'" .And. '
			cCondicao += 'B1_GRUPO >= "'+mv_par03+'" .And. B1_GRUPO <= "'+mv_par04+'" .And. '
			cCondicao += 'B1_TIPO >= "'+mv_par05+'" .And. B1_TIPO <= "'+mv_par06+'" '

			If ExistBlock("OM010FIL")
				cCondicao := ExecBlock("OM010FIL",.F.,.F.,{cCondicao})
			Endif

			IndRegua(cAliasSB1,cArqInd,IndexKey(),,cCondicao)

			nIndex := RetIndex("SB1")
			#IFNDEF TOP
			dbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			dbSetOrder(nIndex+1)
			dbGotop()

			#IFDEF TOP
		Endif
		#ENDIF

		While (cAliasSB1)->(!Eof())

			If RegistroOk(cAliasSB1,.F.,(CALIASSB1)->(FieldPos("B1_MSBLQL")))

				Aadd(aCols,Array(nUsado+1))
				cItem := Soma1(cItem,Len(DA1->DA1_ITEM))

				For nX := 1 To nUsado

					If ( aHeader[nX,10] !=  "V" )

						Do Case
							Case Alltrim(aHeader[nX][2]) == "DA1_ITEM"
							aCOLS[Len(aCols)][nX] := cItem
							Case Alltrim(aHeader[nX][2]) == "DA1_CODPRO"
							aCOLS[Len(aCols)][nX] := (cAliasSB1)->(FieldGet(FieldPos("B1_COD")))
							Case Alltrim(aHeader[nX][2]) == "DA1_DATVIG"
							aCOLS[Len(aCols)][nX] := mv_par07
							Case Alltrim(aHeader[nX][2]) == "DA1_PRCVEN"
							aCOLS[Len(aCols)][nX] := (cAliasSB1)->(FieldGet(FieldPos("B1_PRV1")))
							OtherWise
							aCols[Len(aCols)][nX] := Criavar(aHeader[nX][2],.T.)
						EndCAse
					Else

						Do Case
							Case  Alltrim(aHeader[nX][2]) == "DA1_DESCRI"
							aCOLS[Len(aCols)][nX] := (cAliasSB1)->(FieldGet(FieldPos("B1_DESC")))
							Case Alltrim(aHeader[nX][2]) == "DA1_PRCBAS"
							aCOLS[Len(aCols)][nX] := (cAliasSB1)->(FieldGet(FieldPos("B1_PRV1")))
							OtherWise
							aCOLS[Len(aCols)][nX] := CriaVar(aHeader[nX,2],.T.)
						EndCase

					EndIf

				Next nX
				aCols[Len(aCols)][nUsado+1] := .F.
				IF lGrade
					oGrade:MontaGrade(Len(aCols),(cAliasSB1)->(FieldGet(FieldPos("B1_COD"))),.T.,,.F.)
				Endif

				If lExcLine
					aCols[Len(aCols)] := ExecBlock("OS010LCO",.F.,.F.,{aHeader,aCols[Len(aCols)]})
				Endif

				If lOs010Col
					aCols := ExecBlock("OS010COL",.F.,.F.,{aHeader,aCols})
				Endif
			EndIf
			dbSelectArea(cAliasSB1)
			dbSkip()
		EndDo

		If Empty(aCols)
			Aadd(aCols,Array(nUsado+1))
			For nX := 1 To nUsado
				If AllTrim(aHeader[nX,2]) == "DA1_ITEM"
					aCOLS[Len(aCols)][nX] := StrZero(1,Len(DA1->DA1_ITEM))
				Else
					aCOLS[Len(aCols)][nX] := CriaVar(aHeader[nX,2],.T.)
				EndIf
			Next nX
			aCols[Len(aCols)][nUsado+1] := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o calculo automatico de dimensoes de objetos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize := MsAdvSize()
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 200, 200, .T., .T. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
		aPosObj := MsObjSize( aInfo, aObjects,.T.)

		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
		EnChoice( "DA0", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.T. )
		oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Oms010LOk()","Oms010TOk()","+DA1_ITEM",.T.,,1,,MAXGETDAD)
		oGetDad := oGetD
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA := 1,If(oGetd:TudoOk(),If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},{||oDlg:End()},,aButtons )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rotina de Gravaca da Tabela de preco                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcA == 1 .And. nOpc <> 2
			If lGrade
				aCols := aGradeCols(oGrade,aCols,aHeader,"DA1_CODPRO","DA1_ITEMGR","DA1_PRCVEN","DA1_ITEM")
			EndIf
			Oms010Grv(nOpc-2,1,,aRecno,.F.)
			While ( GetSx8Len() > nSaveSx8 )
				ConfirmSx8()
			EndDo
			EvalTrigger()
		Else
			If nOpc <> 2
				While ( GetSx8Len() > nSaveSx8 )
					RollBackSx8()
				EndDo
			Endif
		EndIf

		If lQuery
			dbSelectArea(cAliasSB1)
			dbCloseArea()
			dbselectArea("DA0")
		Else
			dbSelectArea("SB1")
			dbClearFilter()
			RetIndex("SB1")
			Ferase(cArqInd+OrdBagExt())
			dbselectArea("DA0")
		Endif

		MsUnLockAll()
		FreeUsedCode()
		SetKey(VK_F12,bSavKey)
		RestArea(aArea)

	Endif

	If Inclui
		Inclui := !Inclui
	Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010Grv ³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Gravacao da Tabela de Preco                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Grv                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opcao da Gravacao sendo:                               ³±±
±±³          ³       [1] Inclusao                                           ³±±
±±³          ³       [2] Alteracao                                          ³±±
±±³          ³       [3] Exclusao                                           ³±±
±±³          ³ExpN2: Tipo de Gravacao sendo:                                ³±±
±±³          ³       [1] Tabela                                             ³±±
±±³          ³       [2] Produto                                            ³±±
±±³          ³ExpC3: Codigo do Produto para gravacao por produto            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010Grv(nOpcao,nTipo,cProduto,aRecno,lCopia)

	Local aArea      := GetArea()
	Local aTabDel    := {}
	Local aRegNo     := {}
	Local aUsrMemo   := If( ExistBlock( "OM010MEM" ), ExecBlock( "OM010MEM", .F.,.F. ), {} )
	Local aMemoDA0   := {}
	Local aMemoDA1   := {}
	Local lGravou    := .F.
	Local lTravou    := .T.
	Local lEntryDA1  := ExistBlock("OM010DA1")
	Local lEntryEnd  := ExistBlock("OS010END")
	Local lEntryGrv  := ExistBlock("OS010GRV")
	Local nX         := 0
	Local nY         := 0
	Local nCntfor    := 0
	Local nUsado     := Len(aHeader)
	Local nPosTabela := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_CODTAB"})
	Local nPItem     := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_ITEM"})
	Local nLoop      := 0
	Local bCampo     := {|nCPO| Field(nCPO) }
	Local cItem      := Repl("0",Len(DA1->DA1_ITEM))
	Local lReferencia:= .F.
	Local lContinua  := .T.
	Local cProdRef   := ""

	Default lCopia   := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa buffer                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aUltResult := Nil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordena o aCols pela ordem de itens³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo == 1
		aSort(aCols,,,{|x,y|x[1] <= y[1]})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega campos memo de usuario mas se nao for copia          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType( aUsrMemo ) == "A" .And. Len( aUsrMemo ) > 0 .And. nOpcao <> 4
		For nLoop := 1 to Len( aUsrMemo )
			If aUsrMemo[ nLoop, 1 ] == "DA0"
				AAdd( aMemoDA0, { aUsrMemo[ nLoop, 2 ], aUsrMemo[ nLoop, 3 ] } )
			ElseIf aUsrMemo[ nLoop, 1 ] == "DA1"
				AAdd( aMemoDA1, { aUsrMemo[ nLoop, 2 ], aUsrMemo[ nLoop, 3 ] } )
			Endif
		Next nLoop
	EndIf

	Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao por Tabela                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case nTipo == 1 .And. nOpcao <> 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda os registro para reaproveita-los                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("DA1")
		dbSetOrder(1)
		DbSeek(xFilial("DA1")+M->DA0_CODTAB)
		While ( !Eof() .AND. xFilial("DA1") == DA1->DA1_FILIAL .AND. M->DA0_CODTAB == DA1->DA1_CODTAB)
			aadd(aRegNo,RecNo())
			dbSelectArea("DA1")
			dbSkip()
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Antes de iniciar o processo de alteração verifica se todos os itens foram apagados,³
		//³ caso afirmativo analisa se a tabela esta sendo utilidada.                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcao == 2 .And. aScan(aCols, { |x| x[nUsado + 1] == .F. }) == 0
			lContinua := Os010CanDel(M->DA0_CODTAB)
			If !lContinua
				Help(" ",1,"NODELETA")
			EndIf
		Endif

		If lContinua

			For nX := 1 To Len(aCols)

				Begin Transaction

					//If ExistBlock( "OS010MAN")
					//	ExecBlock( "OS010MAN", .F., .F. )
					//EndIf

					If nX == 1

						dbSelectArea("DA0")
						dbSetOrder(1)
						If MsSeek(xFilial("DA0")+M->DA0_CODTAB)
							RecLock("DA0",.F.)
						Else
							RecLock("DA0",.T.)
						EndIf
						For nCntFor := 1 TO FCount()
							FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
						Next nCntFor

						DA0->DA0_FILIAL := xFilial("DA0")

						For nLoop := 1 To Len( aMemoDA0 )
							MSMM( DA0->( FieldGet( FieldPos(aMemoDA0[nLoop,1] ) ) ),,, M->&( aMemoDA0[nLoop,2] ),1,,,"DA0",aMemoDA0[nLoop,1])
						Next nLoop

						MsUnLock()
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Grava os itens                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If !Empty(aCols[nX,nUsado]) .And. nOpcao <> -1  .And. !lCopia
						DbSelectArea("DA1")
						DbGoto(aCols[nX,nUsado])
						RecLock("DA1")
						nY := aScan(aRegNo,{|x| x == aCols[nX,nUsado]})
						aDel(aRegNo,nY)
						aSize(aRegNo,Len(aRegNo)-1)
					ElseIf !aCols[nX,nUsado+1]
						RecLock("DA1",.T.)
					EndIf
					If (!aCols[nX][nUsado+1] )
						For nY := 1 to Len(aHeader)
							If aHeader[nY][10] <> "V"
								DA1->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
							EndIf
						Next nY
						DA1->DA1_FILIAL := xFilial("DA1")
						DA1->DA1_CODTAB := DA0->DA0_CODTAB
						DA1->DA1_INDLOT := StrZero(DA1->DA1_QTDLOT,18,2)

						For nLoop := 1 To Len( aMemoDA1 )
							MSMM( DA1->( FieldGet( FieldPos( aMemoDA1[nLoop,1] ) ) ),,,GDFieldGet( aMemoDA1[nLoop,2], nX ),1,,,"DA1",aMemoDA1[nLoop,1])
						Next nLoop

						MsUnLock()

						If lEntryDA1
							ExecBlock("OM010DA1",.F.,.F.,{nTipo,nOpcao})
						Endif
						lGravou := .T.

					ElseIf !Empty(aCols[nX,nUsado]) .And. !lCopia
						DA1->(DbDelete())
						For nLoop := 1 To Len( aMemoDA1)
							MSMM( DA1->( FieldGet( FieldPos( aMemoDA1[ nLoop, 1 ] ) ) ),,,,2)
						Next nLoop
					EndIf
					MsUnLock()

					If lEntryEnd
						ExecBlock("OS010END",.F.,.F.,{nTipo,nOpcao})
					Endif

				End Transaction
			Next nX
			DbSelectArea("DA1")
			For nX := 1 To Len(aRegNo)
				DbGoto(aRegNo[nX])
				RecLock("DA1")
				dbDelete()
				MsUnLock()
			Next nX
			If !lGravou
				dbSelectArea("DA0")
				dbSetOrder(1)
				If MsSeek(xFilial("DA0")+M->DA0_CODTAB)
					RecLock("DA0")
					dbDelete()

					For nLoop := 1 To Len( aMemoDA0 )
						MSMM( DA0->( FieldGet( FieldPos( aMemoDA0[ nLoop, 1 ] ) ) ),,,,2)
					Next nLoop

					MsUnLock()
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclusao por Tabela                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case  nTipo == 1 .And. nOpcao == 3

		Begin Transaction

			If ExistBlock( "OS010EXT" )
				ExecBlock( "OS010EXT", .F., .F. )
			EndIf

			dbSelectArea("DA1")
			dbSetOrder(1)
			MsSeek(xFilial("DA1")+M->DA0_CODTAB)
			While ( !Eof() .And. xFilial("DA1") == DA1->DA1_FILIAL .And. M->DA0_CODTAB == DA1->DA1_CODTAB )

				RecLock("DA1")
				dbDelete()

				For nLoop := 1 To Len( aMemoDA1 )
					MSMM( DA1->( FieldGet( FieldPos( aMemoDA1[ nLoop, 1 ] ) ) ),,,,2)
				Next nLoop

				MsUnLock()

				If lEntryDA1
					ExecBlock("OM010DA1",.F.,.F.,{nTipo,nOpcao})
				Endif

				dbSelectArea("DA1")
				dbSkip()
			EndDo

			dbSelectArea("DA0")
			dbSetOrder(1)
			If MsSeek(xFilial("DA0")+M->DA0_CODTAB)
				RecLock("DA0",.F.)
				dbDelete()
				For nLoop := 1 To Len( aMemoDA0 )
					MSMM( DA0->( FieldGet( FieldPos( aMemoDA0[ nLoop, 1 ] ) ) ),,,,2)
				Next nLoop
				MsUnLock()
			EndIf
		End Transaction

		If lEntryEnd
			ExecBlock("OS010END",.F.,.F.,{nTipo,nOpcao})
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao por Produto                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		Case  nTipo == 2 .And. nOpcao <> 3
		cProdRef	:= cProduto
		lReferencia	:= MatGrdPrRf(@cProdRef,.T.)
		Begin Transaction

			If ExistBlock( "OS010MNP" )
				ExecBlock("OS010MNP",.f.,.f., cProduto )
			EndIf

			For nX := 1 To Len(aCols)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava DA1                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lTravou := .F.
				If nX <= Len(aRecNo)
					dbSelectArea("DA1")
					dbGoto(aRecNo[nX])
					RecLock("DA1")
					lTravou := .T.
				EndIf

				If ( !aCols[nX][nUsado+1] )
					If !lTravou
						RecLock("DA1",.T.)
					EndIf

					For nY := 1 To nUsado
						If ( aHeader[nY][10] != "V" )
							DA1->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
						EndIf
					Next nY
					DA1->DA1_FILIAL := xFilial("DA1")
					DA1->DA1_INDLOT := StrZero(DA1->DA1_QTDLOT,18,2)
					DA1->DA1_CODPRO := cProduto
					MsUnlock()

					If lEntryDA1
						ExecBlock("OM010DA1",.F.,.F.,{nTipo,nOpcao})
					Endif

				Else
					If lTravou
						dbSelectArea("DA1")
						dbSetOrder(2)
						MsSeek(xFilial()+cProduto+aCols[nX][nPosTabela]+aCols[nX][nPItem])

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se delecao armazena para verificar se deleta cabecalho       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Ascan(aTabDel,aCols[nX][nPosTabela]) == 0
							Aadd(aTabDel,aCols[nX][nPosTabela])
						Endif

						RecLock("DA1",.F.)
						dbDelete()
						MsUnlock()
					Endif
				Endif

			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Analisa se deleta cabecalho de acordo com os deletados       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nY := 1 to Len(aTabDel)
				DA1->(dbSetOrder(3))
				If !DA1->(MsSeek(xFilial("DA1")+aTabDel[nY]))
					DA0->(DBSetOrder(1))
					If DA0->(MsSeek(xFilial("DA0")+aTabDel[nY]))
						RecLock("DA0",.F.)
						dbDelete()
						MsUnlock()
					Endif
				Endif
			Next

			If lEntryEnd
				ExecBlock("OS010END",.F.,.F.,{nTipo,nOpcao})
			Endif

		End Transaction

	EndCase

	If lEntryGrv
		ExecBlock("OS010GRV",.F.,.F.,{nTipo,nOpcao})
	Endif

Return(lGravou)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010Calc³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de calculo do fator de acrescimo/descrescimo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Calc()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010Calc()

	Local aArea     := GetArea()
	Local cCampo    := ReadVar()
	Local nRetorno  := 0
	Local nPrecoOri := 0
	Local nPosPreco := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_PRCVEN"})
	Local nPosProd  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_CODPRO"})
	Local nPMoeda   := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_MOEDA"})
	Local nPPrcTab  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_PRCBAS"})
	Local nPVlrDes  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_VLRDES"})
	Local nPPerDes  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_PERDES"})
	Local nPPrcBas   := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_PRCBAS"})

	Do Case
		Case cCampo == "M->DA1_VLRDES" .AND. !Empty(aCols[n,nPPrcBas])

		If aCols[n,nPMoeda] <= MoedFin()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Parametro que indica qual sera a moeda do preco base na tabela de precos³
			//³                             1-Moeda 1 (DEFAULT)                        ³
			//³                             2-Moeda da linha de itens da tabela        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SuperGetMv("MV_MPRCBAS",.F.,"1") == "1"
				nPrecoOri := xMoeda(aCols[n,nPPrcTab],1,aCols[n,nPMoeda])
			Else
				nPrecoOri := aCols[n,nPPrcTab]
			Endif

			If ( ( nPrecoOri - M->DA1_VLRDES ) > 0 )
				aCols[n][nPosPreco] := NoRound(nPrecoOri - M->DA1_VLRDES,aHeader[nPosPreco][5])
				aCols[n][nPPerDes]  := NoRound((aCols[n][nPosPreco]/nPrecoOri),aHeader[nPPerDes][5])
				nRetorno := M->DA1_VLRDES
			Else
				nRetorno := 0
			EndIf
		Endif
		Case cCampo =="M->DA1_PERDES" .AND. !Empty(aCols[n,nPPrcBas])

		If aCols[n,nPMoeda] <= MoedFin()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Parametro que indica qual sera a moeda do preco base na tabela de precos³
			//³                             1-Moeda 1 (DEFAULT)                        ³
			//³                             2-Moeda da linha de itens da tabela        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SuperGetMv("MV_MPRCBAS",.F.,"1") == "1"
				nPrecoOri := xMoeda(aCols[n,nPPrcTab],1,aCols[n,nPMoeda])
			Else
				nPrecoOri := aCols[n,nPPrcTab]
			Endif

			If ( nPrecoOri > 0 )
				aCols[n][nPosPreco] := NoRound(nPrecoOri * If(M->DA1_PERDES == 0,1,M->DA1_PERDES),aHeader[nPosPreco][5])
				nRetorno := M->DA1_PERDES
			Else
				nRetorno := 0
			EndIf
			If nPVlrDes<>0
				aCols[n][nPVlrDes]   := 0
			EndIf
		Endif
		Case cCampo =="M->DA1_MOEDA"
		aCols[n,nPosPreco] := 0
		aCols[n,nPVlrDes ] := 0
		aCols[n,nPPerDes ] := 0
	EndCase
Return(nRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010LOk ³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Validacao da linha Ok                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Lok())                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010Lok()

	Local aArea     := GetArea()
	Local lRetorno  := .T.
	Local nPosProd  := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_CODPRO"})
	Local nPosGrupo := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_GRUPO"})
	Local nPosFaixa := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_QTDLOT"})
	Local nPosPrcVen:= aScan(aHeader,{|x| AllTrim(x[2])=="DA1_PRCVEN"})
	Local nPosTab   := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_CODTAB"})
	Local nPosUF    := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_ESTADO"})
	Local nPosTpOpe := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_TPOPER"})
	Local nPosDtVig := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_DATVIG"})
	Local nPosRefGr := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_REFGRD"})
	Local nUsado    := Len(aHeader)
	Local nX        := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica os campos obrigatorios                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[n][nUsado+1]
		Do Case
			Case nPosFaixa == 0 .Or. nPosPrcVen == 0
			lRetorno := .F.
			Help(" ",1,"OBRIGAT",,RetTitle("DA1_CODPRO")+","+RetTitle("DA1_QTDLOT")+","+RetTitle("DA1_PRCVEN"),4)
			Case (nPosProd > 0 .And. Empty(aCols[n][nPosProd]))
			If nPosRefGr >0
				If Empty(aCols[n][nPosRefGr])
					If nPosGrupo == 0
						lRetorno := .F.
						Help(" ",1,"OBRIGAT",,RetTitle("DA1_CODPRO"),4)
					ElseIf Empty(aCols[n][nPosGrupo])
						lRetorno := .F.
						Help(" ",1,"OBRIGAT",,RetTitle("DA1_CODPRO")+","+RetTitle("DA1_GRUPO"),4)
					EndIf
				Endif
			Else
				If nPosGrupo == 0
					lRetorno := .F.
					Help(" ",1,"OBRIGAT",,RetTitle("DA1_CODPRO"),4)
				ElseIf Empty(aCols[n][nPosGrupo])
					lRetorno := .F.
					Help(" ",1,"OBRIGAT",,RetTitle("DA1_CODPRO")+","+RetTitle("DA1_GRUPO"),4)
				EndIf
			Endif
			Case Empty(aCols[n][nPosFaixa])
			lRetorno := .F.
			Help(" ",1,"OBRIGAT",,RetTitle("DA1_QTDLOT"),4)
			Case nPosTab > 0
			If Empty(aCols[n][nPosTab])
				lRetorno := .F.
				Help(" ",1,"OBRIGAT",,RetTitle("DA1_CODTAB"),4)
			Endif
		EndCase
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se nao ha valores duplicados                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno
			If nPosTab == 0
				For nX := 1 To Len(aCols)
					If nX <> N .And. !aCols[nX][nUsado+1]
						If (nPosProd == 0 .Or. (aCols[nX][nPosProd] == aCols[N][nPosProd] .And. !Empty(aCols[N][nPosProd]))) .And.;
						aCols[nX][nPosFaixa] == aCols[N][nPosFaixa] .And.;
						IIf(nPosTpOpe<>0,aCols[nX][nPosTpOpe] == aCols[N][nPosTpOpe],.F.) .And.;
						IIf(nPosUf<>0,aCols[nX][nPosUf] == aCols[N][nPosUf],.F.) .And.;
						Iif(nPosDtVig<>0,aCols[nX][nPosDtVig] == aCols[N][nPosDtVig],.F.)
							lRetorno := .F.
							Help(" ",1,"JAGRAVADO")
						ElseIf nPosGrupo > 0
							If (aCols[nX][nPosGrupo] == aCols[N][nPosGrupo] .And. !Empty(aCols[N][nPosGrupo])) .And.;
							aCols[nX][nPosFaixa] == aCols[N][nPosFaixa] .And.;
							IIf(nPosTpOpe<>0,aCols[nX][nPosTpOpe] == aCols[N][nPosTpOpe],.F.) .And.;
							IIf(nPosUf<>0,aCols[nX][nPosUf] == aCols[N][nPosUf],.F.) .And.;
							Iif(nPosDtVig<>0,aCols[nX][nPosDtVig] == aCols[N][nPosDtVig],.F.) .Or. ;
							(nPosRefGr >0 .And. aCols[nX][nPosRefGr] == aCols[N][nPosRefGr] .And. !Empty(aCols[N][nPosRefGr])) .And.;
							aCols[nX][nPosFaixa] == aCols[N][nPosFaixa] .And.;
							IIf(nPosTpOpe<>0,aCols[nX][nPosTpOpe] == aCols[N][nPosTpOpe],.F.) .And.;
							IIf(nPosUf<>0,aCols[nX][nPosUf] == aCols[N][nPosUf],.F.) .And.;
							Iif(nPosDtVig<>0,aCols[nX][nPosDtVig] == aCols[N][nPosDtVig],.F.)
								lRetorno := .F.
								Help(" ",1,"JAGRAVADO")
							EndIf
						ElseIf nPosGrupo == 0
							If (nPosRefGr >0 .And. aCols[nX][nPosRefGr] == aCols[N][nPosRefGr] .And. !Empty(aCols[N][nPosRefGr])) .And.;
							aCols[nX][nPosFaixa] == aCols[N][nPosFaixa] .And.;
							IIf(nPosTpOpe<>0,aCols[nX][nPosTpOpe] == aCols[N][nPosTpOpe],.F.) .And.;
							IIf(nPosUf<>0,aCols[nX][nPosUf] == aCols[N][nPosUf],.F.) .And.;
							Iif(nPosDtVig<>0,aCols[nX][nPosDtVig] == aCols[N][nPosDtVig],.F.)
								lRetorno := .F.
								Help(" ",1,"JAGRAVADO")
							EndIf
						EndIf
					EndIf
				Next nX
			Else
				For nX := 1 To Len(aCols)
					If nX <> N .And. !aCols[nX][nUsado+1]
						If ( nPosProd==0 .Or. aCols[nX][nPosProd] == aCols[N][nPosProd]) .And.;
						aCols[nX][nPosFaixa] == aCols[N][nPosFaixa] .And.;
						aCols[nX][nPosTab] == aCols[N][nPosTab] .And.;
						IIf(nPosTpOpe<>0,aCols[nX][nPosTpOpe] == aCols[N][nPosTpOpe],.F.) .And.;
						IIf(nPosUf<>0,aCols[nX][nPosUf] == aCols[N][nPosUf],.F.) .And.;
						Iif(nPosDtVig<>0,aCols[nX][nPosDtVig] == aCols[N][nPosDtVig],.F.)
							lRetorno := .F.
							Help(" ",1,"JAGRAVADO")
						EndIf
					EndIf
				Next nX
			EndIf
		EndIf
	EndIf

	If lRetorno
		If ExistBlock("OM010LOK")
			lRetorno := ExecBlock("OM010LOK",.F.,.F.)
		Endif
	Endif

	RestArea(aArea)
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010TOk ³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Validacao da confirmacao da tabela                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Tok())                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010Tok()

	Local lRet  	:= .T.
	Local aArea 	:= GetArea()
	Local aAreaDA0 	:= DA0->(GetArea())
	Local nPosPreco	:= aScan(aHeader,{|x|AllTrim(x[2])=="DA1_PRCVEN"})
	Local nPosItem	:= aScan(aHeader,{|x|AllTrim(x[2])=="DA1_ITEM"})
	Local nX		:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se estiver sendo executado a partir do loja, nao permite³
	//³cadastrar preco zerado                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCenVenda
		For nX := 1 to Len(aCols)
			If !aTail(aCols[nX]) .AND. aCols[nX][nPosPreco] <= 0
				lRet := .F.
				MsgStop("Não é permitido cadastrar produtos com preço de venda zerado. Corrija o item " + aCols[nX][nPosItem])
				Exit
			EndIf
		Next nX
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para validacao da confirmacao da tabela de preco       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ExistBlock("OM010TOK")
		lRet := ExecBlock("OM010TOK",.F.,.F.)
	Endif

	RestArea(aAreaDA0)
	RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010TCOk³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Validacao da confirmacao da copia da tabela         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Tok())                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010TCok()

	Local lRet  := .T.
	Local aArea := GetArea()
	Local aAreaDA0 := DA0->(GetArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para validacao da confirmacao da tabela de preco       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DA0->(dbSetOrder(1))
	If DA0->(MsSeek(xFilial("DA0")+M->DA0_CODTAB))
		lRet := .F.
		Help(" ",1,"JAGRAVADO")
	Endif

	If lRet
		If ExistBlock("OM010TOK")
			lRet := ExecBlock("OM010TOK",.F.,.F.)
		Endif
	Endif

	RestArea(aAreaDA0)
	RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Oms010Rej  ³ Autor ³Eduardo Riera          ³ Data ³03.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Reajuste das tabelas de precos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                     ³±±
±±³          ³ExpN2: Numero do Registro                                   ³±±
±±³          ³ExpN3: Opcao do aRotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010Rej(cAlias,nReg,nOpc)

	Local aArea := GetArea()
	Local nOpcA := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define variaveis de parametrizacao de lancamentos    ³
	//³                                                      ³
	//³ MV_PAR01 Produto inicial?                            ³
	//³ MV_PAR02 Produto final  ?                            ³
	//³ MV_PAR03 Grupo inicial  ?                            ³
	//³ MV_PAR04 Grupo final    ?                            ³
	//³ MV_PAR05 Tipo inicial   ?                            ³
	//³ MV_PAR06 Tipo final     ?                            ³
	//³ MV_PAR07 Tabela inicial ?                            ³
	//³ MV_PAR08 Tabela final   ?                            ³
	//³ MV_PAR09 Fator          ?                            ³
	//³ MV_PAR10 Numero decimais?                            ³
	//³ MV_PAR11 Pedido em Carteira? Sim/Nao                 ³
	//³ MV_PAR12 Reaplicar fator?                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetKey(VK_F12,{|| Nil })

	Pergunte("OMS011",.F.)
	FormBatch(OemToAnsi(STR0008),{OemToAnsi(STR0009),OemToAnsi(STR0010)},;
	{{5,.T.,{|o| Pergunte("OMS011",.T.) }},;
	{1,.T.,{|o| nOpcA:=1,o:oWnd:End()}  },;
	{2,.T.,{|o| o:oWnd:End() }}})
	If ( nOpcA == 1 )
		Processa({|| Oms010Proc()})
	EndIf

	SetKey(VK_F12,{|| Pergunte("OMS010",.T.)})

	RestArea(aArea)
Return(.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Oms010Proc ³ Autor ³Eduardo Riera          ³ Data ³03.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento da tabela de preco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010Proc()

	Local aArea     := GetArea()
	Local aParam    := {}
	Local aAtuPrV   := {}

	Local cQuery    := ""
	Local cArqInd   := ""
	Local cAliasSC9:= "SC9"
	Local cCursor   := "DA1"
	Local cCursorSC6:= "SC6"
	Local cCursorSCK:= "SCK"
	Local cUltProc  := ""

	Local lQuery    := .F.
	Local lContinua := .F.
	Local lAtualiza := .F.
	Local lReajSC9  := GetNewPar("MV_REAJSC9",.F.)
	Local nIndex    := 0
	Local nLoop     := 0
	Local nPPrUnit  := 0
	Local nPPrcVen  := 0
	Local nPValDesc := 0
	Local nPDesc    := 0
	Local nPValor   := 0
	Local nQtdLib   := 0
	Local nX        := 0

	Local cPrdRefde := ""
	Local cPrdRefAte:= ""
	Local i

	PRIVATE aHeader := {}
	PRIVATE aCols   := {}
	PRIVATE N       := 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define variaveis de parametrizacao de lancamentos    ³
	//³                                                      ³
	//³ MV_PAR01 Produto inicial?                            ³
	//³ MV_PAR02 Produto final  ?                            ³
	//³ MV_PAR03 Grupo inicial  ?                            ³
	//³ MV_PAR04 Grupo final    ?                            ³
	//³ MV_PAR05 Tipo inicial   ?                            ³
	//³ MV_PAR06 Tipo final     ?                            ³
	//³ MV_PAR07 Tabela inicial ?                            ³
	//³ MV_PAR08 Tabela final   ?                            ³
	//³ MV_PAR09 Fator          ?                            ³
	//³ MV_PAR10 Numero decimais?                            ³
	//³ MV_PAR11 Pedido em Carteira? Sim/Nao                 ³
	//³ MV_PAR12 Reaplicar fator?                            ³
	//³ MV_PAR13 Planilha       ?                            ³
	//³ MV_PAR14 Atualiza Preco Venda Produto ? Nao/Sim      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva parametros da rotina                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParam := {}
	For nLoop := 1 To 20
		AAdd( aParam, &( "MV_PAR" + StrZero( nLoop, 2 ) ) )
	Next nLoop
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa a atualizacao da tabela de preco             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DA1")
	dbSetOrder(1)
	#IFDEF TOP
	If TcSrvType()<>"AS/400"
		cCursor:= "Oms010Rej"
		lQuery := .T.
		cQuery := "SELECT DA1.* "
		cQuery += "FROM "+RetSqlName("DA1")+" DA1 "
		cQuery += "WHERE DA1.DA1_FILIAL='"+xFilial("DA1")+"' "
		cQuery += "AND ((DA1.DA1_CODPRO >= '"+MV_PAR01+"' "
		cQuery += "AND DA1.DA1_CODPRO <= '"+MV_PAR02+"' "
		cQuery += "AND DA1.DA1_GRUPO = '"+Space(Len(DA1->DA1_GRUPO))+"') "
		cQuery += "OR (DA1.DA1_CODPRO = '"+Space(Len(DA1->DA1_CODPRO))+"' "
		cQuery += "AND DA1.DA1_GRUPO >= '"+MV_PAR03+"' "
		cQuery += "AND DA1.DA1_GRUPO <= '"+MV_PAR04+"') "
		If MaGrade()
			cQuery += "OR (DA1.DA1_CODPRO = '"+Space(Len(DA1->DA1_CODPRO))+"' "
			cQuery += "AND DA1.DA1_GRUPO = '" +Space(Len(DA1->DA1_GRUPO))+"' "
			cQuery += "AND DA1.DA1_REFGRD >= '"+cPrdRefDe+"' "
			cQuery += "AND DA1.DA1_REFGRD <= '"+cPrdRefAte+"') "
		Endif
		cQuery += " ) "
		cQuery += "AND DA1.DA1_CODTAB >= '"+MV_PAR07+"'  "
		cQuery += "AND DA1.DA1_CODTAB <= '"+MV_PAR08+"'  "
		cQuery += "AND DA1.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+SqlOrder(DA1->(IndexKey()))

		If ExistBlock("OM010REJ")
			cQuery := ExecBlock("OM010REJ",.F.,.F.,{cQuery})
		Endif
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor,.T.,.T.)

	Else
		#ENDIF
		cArqInd := CriaTrab(,.F.)

		cQuery := "DA1_FILIAL=='"+xFilial("DA1")+"' "
		cQuery += ".AND. ((DA1_CODPRO>='"+MV_PAR01+"' "
		cQuery += ".AND. DA1_CODPRO<='"+MV_PAR02+"'  "
		cQuery += ".AND. DA1_GRUPO=='"+Space(Len(DA1->DA1_GRUPO))+"')  "
		cQuery += ".OR. (DA1_CODPRO=='"+Space(Len(DA1->DA1_CODPRO))+"'  "
		cQuery += ".AND. DA1_GRUPO>='"+MV_PAR03+"' "
		cQuery += ".AND. DA1_GRUPO<='"+MV_PAR04+"') "
		cQuery += " ) "
		cQuery += ".AND. DA1_CODTAB>='"+MV_PAR07+"' "
		cQuery += ".AND. DA1_CODTAB<='"+MV_PAR08+"'"

		IndRegua("DA1",cArqInd,IndexKey(),,cQuery)
		nIndex := RetIndex("DA1")
		#IFNDEF TOP
		dbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
		dbSetOrder(nIndex+1)
		dbGotop()
		#IFDEF TOP
	EndIf
	#ENDIF
	ProcRegua(DA1->(LastRec()))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define variaveis de parametrizacao de lancamentos    ³
	//³                                                      ³
	//³ MV_PAR01 Produto inicial?                            ³
	//³ MV_PAR02 Produto final  ?                            ³
	//³ MV_PAR03 Grupo inicial  ?                            ³
	//³ MV_PAR04 Grupo final    ?                            ³
	//³ MV_PAR05 Tipo inicial   ?                            ³
	//³ MV_PAR06 Tipo final     ?                            ³
	//³ MV_PAR07 Tabela inicial ?                            ³
	//³ MV_PAR08 Tabela final   ?                            ³
	//³ MV_PAR09 Fator          ?                            ³
	//³ MV_PAR10 Numero decimais?                            ³
	//³ MV_PAR11 Pedido em Carteira? Sim/Nao                 ³
	//³ MV_PAR12 Reaplicar fator?                            ³
	//³ MV_PAR13 Planilha       ?                            ³
	//³ MV_PAR14 Atualiza Preco Venda Produto ? Nao/Sim      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva parametros da rotina                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aParam := {}
	For nLoop := 1 To 20
		AAdd( aParam, &( "MV_PAR" + StrZero( nLoop, 2 ) ) )
	Next nLoop

	dbSelectArea(cCursor)
	While ( !Eof() )
		lContinua := .F.
		If !Empty((cCursor)->DA1_CODPRO)
			If 	(cCursor)->DA1_CODPRO >= aParam[1] .And.;
			(cCursor)->DA1_CODPRO <= aParam[2] .And.;
			(cCursor)->DA1_CODTAB >= aParam[7] .And.;
			(cCursor)->DA1_CODTAB <= aPAram[8]

				dbSelectArea("SB1")
				dbSetOrder(1)
				If MsSeek(xFilial("SB1")+(cCursor)->DA1_CODPRO)
					If 	SB1->B1_GRUPO >= aParam[3] .And. ;
					SB1->B1_GRUPO <= aParam[4] .And. ;
					SB1->B1_TIPO >= aParam[5] .And. ;
					SB1->B1_TIPO <= aParam[6]

						lContinua := .T.
					EndIf
				EndIf
			EndIf
		Else
			lContinua := .T.
		EndIf
		If lContinua
			If (cCursor)->DA1_CODTAB+(cCursor)->DA1_CODPRO+(cCursor)->DA1_GRUPO +(cCursor)->DA1_REFGRD == cUltProc
				lContinua := .F.
			EndIf
		EndIf
		If lContinua
			MaRejTabPrc((cCursor)->DA1_CODTAB,(cCursor)->DA1_CODPRO,aParam[9],aParam[10],aParam[12]==1, aParam[13], @aAtuPrV,(cCursor)->DA1_GRUPO,(cCursor)->DA1_REFGRD)
			lAtualiza := .T.
		EndIf
		cUltProc := (cCursor)->DA1_CODTAB+(cCursor)->DA1_CODPRO+(cCursor)->DA1_GRUPO+(cCursor)->DA1_REFGRD
		dbSelectArea(cCursor)
		dbSkip()
		IncProc(OemtoAnsi(STR0011)+": "+(cCursor)->DA1_CODTAB)
	EndDo
	If lQuery
		dbSelectarea(cCursor)
		dbCloseArea()
		dbSelectArea("DA1")
	Else
		dbSelectArea("DA1")
		RetIndex("DA1")
		Ferase(cArqInd+OrdBagExt())
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza Preco de Venda do Produto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aAtuPrV)
		dbSelectArea("SB1")
		dbSetOrder(1)
		If MsSeek(xFilial("SB1")+aAtuPrV[nX][1])
			RecLock("SB1",.F.)
			SB1->B1_PRV1 := aAtuPrV[nX][2]
			MsUnLock()
		EndIf
	Next nX
	aAtuPrV := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa a atualizacao dos pedidos de venda           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aParam[11] == 1 .And. lAtualiza
		ProcRegua(SC6->(LastRec()))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do aHeader para utilizacao da funcoes do PV  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHeader := {}
		//dbSelectArea("SX3")
		//dbSetOrder(1)
		//MsSeek("SC6")
		//While ( !Eof() .And. (SX3->X3_ARQUIVO == "SC6") )
		//	If ( X3USO(SX3->X3_USADO) .And.;
		//	!(	Trim(SX3->X3_CAMPO) == "C6_NUM" ) 	.And.;
		//	Trim(SX3->X3_CAMPO) <> "C6_QTDEMP" 	.And.;
		//	Trim(SX3->X3_CAMPO) <> "C6_QTDENT" 	.And.;
		//	cNivel >= SX3->X3_NIVEL )
		//		Aadd(aHeader,{ TRIM(X3Titulo()),;
		//		SX3->X3_CAMPO,;
		//		SX3->X3_PICTURE,;
		//		SX3->X3_TAMANHO,;
		//		SX3->X3_DECIMAL,;
		//		SX3->X3_VALID,;
		//		SX3->X3_USADO,;
		//		SX3->X3_TIPO,;
		//		SX3->X3_ARQUIVO,;
		//		SX3->X3_CONTEXT } )
		//	EndIf
		//	dbSelectArea("SX3")
		//	dbSkip()
		//EndDo

		_cAlias  := "SC6"
		_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
		For i := 1 To Len(_aCpoSX3)
			If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 		 	     .And. ;
				AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "C6_NUM"    .And. ;
				AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "C6_QTDEMP" .And. ;
				AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "C6_QTDENT")
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

		dbSelectArea("SC6")
		dbSetOrder(1)
		#IFDEF TOP
		lQuery := .T.
		cCursorSC6 := "OMS010REJ"
		cQuery := "SELECT SC6.C6_NUM,C6_ITEM,SC6.C6_FILIAL,SC6.R_E_C_N_O_ SC6RECNO,SC5.R_E_C_N_O_ SC5RECNO "
		cQuery += "FROM "+RetSqlName("SC6")+" SC6, "
		cQuery += RetSqlName("SB1")+" SB1, "
		cQuery += RetSqlName("SC5")+" SC5  "
		cQuery += "WHERE SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
		cQuery += "SC6.C6_QTDVEN-SC6.C6_QTDENT>0 AND "
		cQuery += "SC6.C6_BLQ NOT IN ('R ') AND "
		cQuery += "SC6.C6_PRUNIT <> 0 AND "
		cQuery += "SC6.C6_PRODUTO>='"+aParam[01]+"' AND "
		cQuery += "SC6.C6_PRODUTO<='"+aParam[02]+"' AND "
		cQuery += "SC6.D_E_L_E_T_ = ' ' AND "
		cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
		cQuery += "SB1.B1_COD = SC6.C6_PRODUTO AND "
		cQuery += "SB1.B1_GRUPO>='"+aParam[03]+"' AND "
		cQuery += "SB1.B1_GRUPO<='"+aParam[04]+"' AND "
		cQuery += "SB1.B1_TIPO>='"+aParam[05]+"' AND "
		cQuery += "SB1.B1_TIPO<='"+aParam[06]+"' AND "
		cQuery += "SB1.D_E_L_E_T_ = ' ' AND "
		cQuery += "SC5.C5_FILIAL='"+xFilial("SC5")+"' AND "
		cQuery += "SC5.C5_NUM = SC6.C6_NUM AND "
		cQuery += "SC5.C5_TABELA>='"+aParam[07]+"' AND "
		cQuery += "SC5.C5_TABELA<='"+aParam[08]+"' AND "
		cQuery += "SC5.C5_TIPO NOT IN ('C','I','P') AND "
		cQuery += "SC5.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursorSC6)
		#ELSE
		MsSeek(xFilial("SC6"))
		#ENDIF
		While !Eof() .And. xFilial("SC6") == (cCursorSC6)->C6_FILIAL
			lAtualiza := .F.
			If !lQuery
				If (cCursorSC6)->C6_BLQ <> 'R  ' .And.;
				(cCursorSC6)->C6_PRUNIT <> 0 .And.;
				(cCursorSC6)->C6_QTDVEN-(cCursorSC6)->C6_QTDENT > 0 .And.;
				(cCursorSC6)->C6_PRODUTO >= aParam[01] .And.;
				(cCursorSC6)->C6_PRODUTO <= aParam[02]
					SB1->(dbSetOrder(1))
					SB1->(MsSeek(xFilial("SB1")+(cCurSorSC6)->C6_PRODUTO))
					SC5->(dbSetOrder(1))
					SC5->(MsSeek(xFilial("SC5")+(cCurSorSC6)->C6_NUM))
					If !SC5->C5_TIPO $ "CIP" .And.;
					SB1->B1_GRUPO >= aParam[03] .And.;
					SB1->B1_GRUPO <= aParam[04] .And.;
					SB1->B1_TIPO >= aParam[05] .And.;
					SB1->B1_TIPO <= aParam[06] .And.;
					SC5->C5_TABELA >= aParam[07] .And.;
					SC5->C5_TABELA <= aParam[08]
						lAtualiza := .T.
					EndIf
				EndIf
			Else
				SC5->(MsGoto((cCursorSC6)->SC5RECNO))
				SC6->(MsGoto((cCursorSC6)->SC6RECNO))
				lAtualiza := .T.
			EndIf
			If lAtualiza
				Begin Transaction
					If RecLock("SC5")
						RegToMemory("SC5",.F.,.F.)
						If RecLock("SC6")
							aCols := {}
							aadd(aCols,Array(Len(aHeader)+1))
							aCols[1][Len(aHeader)+1] := .F.
							For nLoop := 1 To Len(aHeader)
								Do Case
									Case AllTrim(aHeader[nLoop][2]) == "C6_PRUNIT"
									nPPrUnit := nLoop
									Case AllTrim(aHeader[nLoop][2]) == "C6_PRCVEN"
									nPPrcVen := nLoop
									Case AllTrim(aHeader[nLoop][2]) == "C6_VALDESC"
									nPValDesc := nLoop
									Case AllTrim(aHeader[nLoop][2]) == "C6_DESCONT"
									nPDesc := nLoop
									Case AllTrim(aHeader[nLoop][2]) == "C6_VALOR"
									nPValor:= nLoop
								EndCase
								If aHeader[nLoop][10] <> "V"
									aCols[1][nLoop] := SC6->(FieldGet(FieldPos(aHeader[nLoop][2])))
								Endif
							Next nLoop
							M->C6_PRUNIT := MaTabPrVen(SC5->C5_TABELA,SC6->C6_PRODUTO,1,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_MOEDA,SC5->C5_EMISSAO)
							A410MultT("C6_PRUNIT",M->C6_PRUNIT)
							aCols[1][nPPrunit] := M->C6_PRUNIT
							SC6->C6_PRUNIT     := aCols[1][nPPrUnit]
							SC6->C6_PRCVEN     := aCols[1][nPPrcVen]
							SC6->C6_VALDESC    := aCols[1][nPValDesc]
							SC6->C6_DESCONT    := aCols[1][nPDesc]
							SC6->C6_VALOR      := aCols[1][nPValor]

							//ponto de entrada para atualizacoes feitas pelo usuario
							//If ExistBlock("OM010SC6")
							//	ExecBlock("OM010SC6",.F.,.F.)
							//Endif

							If lReajSC9
								dbSelectArea("SC9")
								dbSetOrder(1)
								#IFDEF TOP
								cAliasSC9 := GetNextAlias()
								cQuery := "SELECT SUM(C9_QTDLIB) C9_QTDLIB "
								cQuery += "FROM "+RetSqlName("SC9")+" SC9 "
								cQuery += "WHERE SC9.C9_FILIAL='"+xFilial("SC9")+"' AND "
								cQuery += "SC9.C9_PEDIDO='" +(cCurSorSC6)->C6_NUM+"' AND "
								cQuery += "SC9.C9_ITEM='"   +(cCurSorSC6)->C6_ITEM+"' AND "
								cQuery += "SC9.C9_NFISCAL='"+Space(Len(SC9->C9_NFISCAL))+"' AND "
								cQuery += "SC9.D_E_L_E_T_=' ' "

								cQuery := ChangeQuery(cQuery)

								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)
								nQtdLib := (cAliasSC9)->C9_QTDLIB
								dbCloseArea()
								dbSelectArea("SC9")
								#ELSE
								cAliasSC9 := "SC9"
								If MsSeek(xFilial("SC9")+(cCurSorSC6)->C6_NUM+(cCurSorSC6)->C6_ITEM)
									While !Eof() .And. (cAliasSC9)->C9_FILIAL == xFilial("SC9") .And.;
									(cAliasSC9)->C9_PEDIDO == (cCurSorSC6)->C6_NUM .And.;
									(cAliasSC9)->C9_ITEM   == (cCurSorSC6)->C6_ITEM
										If Empty((cAliasSC9)->C9_NFISCAL)
											nQtdLib += (cAliasSC9)->C9_QTDLIB
										EndIf
										dbSelectArea("SC9")
										dbSkip()
									EndDo
								EndIf
								#ENDIF
								MaAvalSC6("SC6",2,"SC5",.T.,.F.)
								SC6->C6_QTDLIB	:= nQtdLib
								nQtdLib := 0
								MaAvalSC6("SC6",1,"SC5",.T.,.F.)
							EndIf
						EndIf
					EndIf
				End Transaction
			EndIf
			dbSelectArea(cCursorSC6)
			dbSkip()
			IncProc(OemtoAnsi(STR0014)+": "+(cCursorSC6)->C6_NUM) //"Pedido"
		EndDo
		If lQuery
			dbSelectArea(cCursorSC6)
			dbCloseArea()
			dbSelectArea("SC6")
		EndIf

		If .f.

			dbSelectArea("SCK")
			dbSetOrder(1)
			#IFDEF TOP
			lQuery := .T.
			cCursorSCK := "OMS010REJ"
			cQuery := "SELECT SCK.CK_NUM,SCK.CK_FILIAL,SCK.R_E_C_N_O_ SCKRECNO,SCJ.R_E_C_N_O_ SCJRECNO "
			cQuery += "FROM "+RetSqlName("SCK")+" SCK, "
			cQuery += RetSqlName("SB1")+" SB1, "
			cQuery += RetSqlName("SCJ")+" SCJ  "
			cQuery += "WHERE SCK.CK_FILIAL='"+xFilial("SCK")+"' AND "
			cQuery += "SCK.CK_PRUNIT <> 0 AND "
			cQuery += "SCK.CK_PRODUTO>='"+aParam[01]+"' AND "
			cQuery += "SCK.CK_PRODUTO<='"+aParam[02]+"' AND "
			cQuery += "SCK.D_E_L_E_T_ = ' ' AND "
			cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
			cQuery += "SB1.B1_COD = SCK.CK_PRODUTO AND "
			cQuery += "SB1.B1_GRUPO>='"+aParam[03]+"' AND "
			cQuery += "SB1.B1_GRUPO<='"+aParam[04]+"' AND "
			cQuery += "SB1.B1_TIPO>='"+aParam[05]+"' AND "
			cQuery += "SB1.B1_TIPO<='"+aParam[06]+"' AND "
			cQuery += "SB1.D_E_L_E_T_ = ' ' AND "
			cQuery += "SCJ.CJ_FILIAL='"+xFilial("SCJ")+"' AND "
			cQuery += "SC5.CJ_NUM = SCK.CK_NUM AND "
			cQuery += "SCJ.CJ_TABELA>='"+aParam[07]+"' AND "
			cQuery += "SCJ.CJ_TABELA<='"+aParam[08]+"' AND "
			cQuery += "SCJ.CJ_TIPO NOT IN ('B','E') AND "
			cQuery += "SCJ.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursorSCK)
			#ELSE
			MsSeek(xFilial("SCJ"))
			#ENDIF

			While !Eof() .And. xFilial("SCJ") == (cCursorSCK)->CK_FILIAL

				lAtualiza := .F.
				If !lQuery
					If 	(cCursorSCK)->CK_PRUNIT <> 0 .And.;
					(cCursorSCK)->CK_QTDVEN > 0 .And.;
					(cCursorSCK)->CK_PRODUTO >= aParam[01] .And.;
					(cCursorSCK)->CK_PRODUTO <= aParam[02]

						SB1->(dbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1")+(cCurSorSCK)->CK_PRODUTO))
						SCK->(dbSetOrder(1))
						SCK->(MsSeek(xFilial("SCK")+(cCurSorSCK)->CK_NUM))
						If !SCK->CK_TIPO $ "CIP" .And.;
						SB1->B1_GRUPO >= aParam[03] .And.;
						SB1->B1_GRUPO <= aParam[04] .And.;
						SB1->B1_TIPO >= aParam[05] .And.;
						SB1->B1_TIPO <= aParam[06] .And.;
						SCK->CK_TABELA >= aParam[07] .And.;
						SCK->CK_TABELA <= aParam[08]
							lAtualiza := .T.
						EndIf

					Endif
				Endif

				dbSelectArea(cCursorSCK)
				dbSkip()
				IncProc(OemtoAnsi(STR0014)+": "+(cCursorSCK)->CK_NUM) //"Pedido"

			Enddo

		Endif
	EndIf
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaRejTabPrc³ Autor ³ Eduardo Riera         ³ Data ³07.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de reajuste da tabela de preco                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Numerico (Preco de Venda)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tabela de Preco                                      ³±±
±±³          ³ExpC2: Codigo do Produto                                    ³±±
±±³          ³ExpN3: Fator                                                ³±±
±±³          ³ExpN4: Decimais a serem consideradas                        ³±±
±±³          ³ExpL5: Aplica fator no preco base para calculo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaRejTabPrc(cCodTab,cCodPro,nFator,nDecimais,lFator,cPlanilha,aAtuPrV,cGrupo,cCodRef)

	Local aArea    := GetArea()
	Local aAreaDA0 := DA0->(GetArea())
	Local aAreaDA1 := DA1->(GetArea())
	Local nBase    := 0
	Local nPrcAnt  := 0
	Local lPReaj   := ExistBlock("OS010REJ")
	Local nFtAplic := 0

	DEFAULT nDecimais := TamSx3("DA1_PRCVEN")[2]
	DEFAULT lFator    := .F.
	DEFAULT cPlanilha := ""
	DEFAULT cGrupo    := ""
	DEFAULT aAtuPrV   := {}

	If !Empty(cPlanilha)
		Pergunte("MTC010",.F.)
	Endif

	If !Empty(cCodPro)
		dbSelectArea("DA1")
		dbSetOrder(1)
		If MsSeek(xFilial("DA1")+cCodTab+cCodPro)

			While !Eof() .And. DA1->DA1_FILIAL == xFilial("DA1") .And.;
			DA1->DA1_CODTAB == cCodTab .And. DA1->DA1_CODPRO == cCodPro

				Begin Transaction

					nBase   := DA1->DA1_PRCVEN
					nPrcAnt := DA1->DA1_PRCVEN
					nFtAplic:= nFator

					If lFator
						dbSelectArea("SB1")
						dbSetOrder(1)
						If MsSeek(xFilial("SB1")+cCodPro)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Atualiza pela planilha de formacao de precos          ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Empty(cPlanilha)
								nBase := MaPrcPlan(cCodPro,cPlanilha,cCodTab,nBase)
							Else
								nBase := SB1->B1_PRV1
							EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza Preco de Venda Produto³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If mv_par14 == 2 .And. nFtAplic > 0
								If aScan(aAtuPrV,{|x| x[1]==cCodPro}) == 0
									aAdd(aAtuPrV,{cCodPro,NoRound(nBase * nFtAplic,nDecimais)})
								Endif
							EndIf
						EndIf
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza pela planilha de formacao de precos          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(cPlanilha)
							nBase := MaPrcPlan(cCodPro,cPlanilha,cCodTab,nBase)
						EndIf
					EndIf

					If DA1->DA1_PERDES > 0
						nFtAplic*= DA1->DA1_PERDES
					EndIf

					RecLock("DA1")
					DA1->DA1_PRCVEN := If(nFtAplic > 0, NoRound(nBase * nFtAplic,nDecimais), nBase )
					MsUnLock()

				End Transaction

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada para atualizacao de precos           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lPReaj
					ExecBlock("OS010REJ",.F.,.F.,{nPrcAnt, DA1->DA1_PRCVEN})
				Endif

				dbSelectArea("DA1")
				dbSkip()
			EndDo

		EndIf
	Elseif !Empty(cGrupo)
		dbSelectArea("DA1")
		dbSetOrder(4)
		If MsSeek(xFilial("DA1")+cCodTab+cGrupo)

			While !Eof() .And. DA1->DA1_FILIAL == xFilial("DA1") .And.;
			DA1->DA1_CODTAB == cCodTab .And. DA1->DA1_GRUPO == cGrupo

				Begin Transaction

					nBase   := DA1->DA1_PRCVEN
					nPrcAnt := DA1->DA1_PRCVEN
					nFtAplic:= nFator

					If DA1->DA1_PERDES > 0
						nFtAplic*= DA1->DA1_PERDES
					EndIf

					RecLock("DA1")
					DA1->DA1_PRCVEN := If(nFtAplic > 0, NoRound(nBase * nFtAplic,nDecimais), nBase )
					MsUnLock()

				End Transaction

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada para atualizacao de precos           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lPReaj
					ExecBlock("OS010REJ",.F.,.F.,{nPrcAnt, DA1->DA1_PRCVEN})
				Endif

				dbSelectArea("DA1")
				dbSkip()
			EndDo

		EndIf
	Elseif !Empty(cCodRef)
		dbSelectArea("DA1")
		dbSetOrder(5)
		If MsSeek(xFilial("DA1")+cCodTab+cCodRef)

			While !Eof() .And. DA1->DA1_FILIAL == xFilial("DA1") .And.;
			DA1->DA1_CODTAB == cCodTab .And. DA1->DA1_REFGRD == cCodRef

				Begin Transaction

					nBase   := DA1->DA1_PRCVEN
					nPrcAnt := DA1->DA1_PRCVEN
					nFtAplic:= nFator

					If DA1->DA1_PERDES > 0
						nFtAplic*= DA1->DA1_PERDES
					EndIf

					RecLock("DA1")
					DA1->DA1_PRCVEN := If(nFtAplic > 0, NoRound(nBase * nFtAplic,nDecimais), nBase )
					MsUnLock()

				End Transaction

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada para atualizacao de precos           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lPReaj
					ExecBlock("OS010REJ",.F.,.F.,{nPrcAnt, DA1->DA1_PRCVEN})
				Endif

				dbSelectArea("DA1")
				dbSkip()
			EndDo

		EndIf
	EndIf

	If !Empty(cPlanilha)
		Pergunte("OMS010",.F.)
	Endif

	RestArea(aAreaDA1)
	RestArea(aAreaDA0)
	RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaPrcPlan  ³ Autor ³Henry Fila             ³ Data ³03.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca preco de acordo com a planilha de precos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Produto                                              ³±±
±±³          ³ExpC2: Planilha                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Preco                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MaPrcPlan(cProduto,cPlanilha,cCodTab,nPreco)

	Local aArray := {}
	Local nX     := 0
	Local nPos   := 0

	Private cArqMemo   := cPlanilha
	Private lDirecao   := .T.
	Private nQualCusto := 1
	Private cProg      := "R430"
	Default nPreco := 0

	If !Empty(cPlanilha)
		SB1->(dbSetOrder(1))
		If SB1->(MsSeek(xFilial("SB1")+cProduto))
			cArqMemo := cPlanilha
			aArray   := MC010Forma("SB1",SB1->(RecNo()),98)
		Endif
	Endif

	If ValType(aArray) <> "A"
		aArray := {}
	Endif

	For nX := 1 To Len(aArray)
		nPos := At("#"+cCodTab,aArray[nX][3])
		If nPos > 0
			nPreco := aArray[nX][6]
			Exit
		EndIf
	Next nX

	If nPos == 0
		For nX := 1 To Len(aArray)
			nPos  := At("@",aArray[nX][3])
			If nPos > 0
				nPreco := aArray[nX][6]
				Exit
			EndIf
		Next nX
	Endif

Return(nPreco)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MATABPRVEN ³ Autor ³ Henry Fila            ³ Data ³ 20.04.00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para trazer preco de venda de acordo com a qtde      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Numerico (Preco de Venda)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tabela de Preco                                      ³±±
±±³          ³ExpC2: Codigo do Produto                                    ³±±
±±³          ³ExpN3: Quantidade                                           ³±±
±±³          ³ExpC4: Cliente                                              ³±±
±±³          ³ExpC5: Loja                                                 ³±±
±±³          ³ExpN6: Moeda a ser retornada                                ³±±
±±³          ³ExpD7:                                                      ³±±
±±³          ³ExpN8: Tipo                                                 ³±±
±±³          ³       1 = Preco (Default)                                  ³±±
±±³          ³       2 = Fator de acrescimo ou desconto                   ³±±
±±³          ³ExpL9:                                                      ³±±
±±³          ³ExpL10:                                                     ³±±
±±³          ³ExpL11:Se o cliente deve ser tratado como um prospect       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 04/12/06 ³ Conrado Q.    ³ - BOPS: 111439: Criado parâmetro para atu  ³±±
±±³          ³               ³ alização das variáveis estáticas.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaTabPrVen(cTabPreco,cProduto,nQtde,cCliente,cLoja,nMoeda,dDataVld,nTipo,lExec,lAtuEstado,lProspect)

	Static cMvEstado
	Static cMvNorte

	Local aArea     := GetArea()
	Local aAreaSB1  := SB1->(GetArea())
	Local aStruDA1  := {}

	Local cTpOper   := ""
	Local cQuery    := ""
	Local cAliasDA1 := "DA1"

	Local nPrcVen   := 0
	Local nResult   := 0
	Local nMoedaTab := 1
	Local nScan     := 0
	Local nY        := 0
	Local cMascara  := SuperGetMv("MV_MASCGRD")
	Local nTamProd  := Len(SB1->B1_COD)
	Local nFator    := 0

	Local lUltResult:= .T.
	Local lQuery    := .F.
	Local nProcessa := 0
	Local lGrade    := DA1->(FieldPos("DA1_ITEMGR")) > 0 .And. MaGrade()
	Local lGradeReal:= .F.
	Local lPrcDA1   := .F.
	Local cProdRef  := cProduto
	Local lSeekDa1  := .F.

	DEFAULT cMvEstado := GetMv("MV_ESTADO")
	DEFAULT cMvNorte  := GetMv("MV_NORTE")
	DEFAULT nMoeda    := 1
	DEFAULT aUltResult:= {}
	DEFAULT dDataVld  := dDataBase
	DEFAULT nTipo     := 1
	DEFAULT lExec     := .T.
	DEFAULT lAtuEstado:= .F.
	DEFAULT lProspect := .F.

	If lAtuEstado
		cMvEstado	:= GetMv("MV_ESTADO")
		cMvNorte	:= GetMv("MV_NORTE")
	Endif

	If lGrade .And.	MatGrdPrrf(@cProdRef,.T.)
		nTamProd	:= Len(cProdRef)
		lGradeReal	:= .T.
		cProdRef	:= Padr(cProdRef,Len(DA1->DA1_REFGRD))
	Endif

	If ExistBlock("OM010PRC") .And. lExec
		nResult := ExecBlock("OM010PRC",.F.,.F.,{cTabPreco,cProduto,nQtde,cCliente,cLoja,nMoeda,dDataVld,nTipo})
	Else

		nScan := aScan(aUltResult,{|x| x[1] == cTabPreco .And.;
		x[2] == cProduto .And.;
		x[3] == nQtde .And.;
		x[4] == cCliente .And.;
		x[5] == cLoja .And.;
		x[6] == nMoeda .And.;
		x[7] == cFilAnt .And.;
		x[10] == lProspect})

		If nScan == 0

			If !(Empty(cCliente) .And. nQtde == 0 )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for prospect, pega a informação do mesmo.            ³
				//³Funcionalidade implantada para utilização do televendas,³
				//³já que ele suporta orçamento para prospect.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lProspect
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Acho o tipo de operacao para busca do preco de venda³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SUS")
					dbSetOrder(1)
					If MsSeek(xFilial("SUS")+cCliente+cLoja)
						Do Case
							Case SUS->US_EST == cMvEstado
							cTpOper := "1"
							Case SUS->US_EST != cMvEstado
							If (SUS->US_EST $ cMvNorte) .And. !(cMvEstado $ cMvNorte)
								cTpOper := "3"
							Else
								cTpOper := "2"
							EndIf
						EndCase
					EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Acho o tipo de operacao para busca do preco de venda³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SA1")
					dbSetOrder(1)
					If MsSeek(xFilial("SA1")+cCliente+cLoja)
						Do Case
							Case SA1->A1_EST == cMvEstado
							cTpOper := "1"
							Case SA1->A1_EST != cMvEstado
							If (SA1->A1_EST $ cMvNorte) .And. !(cMvEstado $ cMvNorte)
								cTpOper := "3"
							Else
								cTpOper := "2"
							EndIf
						EndCase
					EndIf
				EndIf
			Endif

			dbSelectarea("DA1")
			dbSetOrder(1)

			#IFDEF TOP
			If TcSrvType() <> "AS/400"
				lQuery    := .T.
				cAliasDA1 := GetNextAlias()
				aStruDA1  := DA1->(dbStruct())
				cQuery    := ""

				If lGradeReal
					cQuery += "SELECT * FROM ( "
				EndIf

				cQuery += "SELECT * "
				cQuery += "FROM "+RetSqlName("DA1")+ " DA1 "
				cQuery += "WHERE "
				cQuery += "DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
				cQuery += "DA1.DA1_CODTAB = '"+cTabPreco+"' AND "
				cQuery += "DA1.DA1_CODPRO = '"+cProduto+"' AND "
				cQuery += "DA1.DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
				cQuery += "DA1.DA1_ATIVO = '1' AND  "

				cQuery += "( DA1.DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "

				If !(nQtde == 0 .And. Empty(cCliente))
					cQuery += "( DA1.DA1_TPOPER = '"+cTpOper+"' OR DA1.DA1_TPOPER = '4' ) AND "
				Endif

				cQuery += "DA1.D_E_L_E_T_ = ' ' "
				If lGradeReal
					cQuery += " UNION "
					cQuery += "SELECT * "
					cQuery += "FROM "+RetSqlName("DA1")+ " DA1 "
					cQuery += "WHERE "
					cQuery += "DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
					cQuery += "DA1.DA1_CODTAB = '"+cTabPreco+"' AND "
					cQuery += "DA1.DA1_REFGRD = '"+cProdRef+"' AND "
					cQuery += "DA1.DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
					cQuery += "DA1.DA1_ATIVO = '1' AND  "
					cQuery += "( DA1.DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "

					If !(nQtde == 0 .And. Empty(cCliente))
						cQuery += "( DA1.DA1_TPOPER = '"+cTpOper+"' OR DA1.DA1_TPOPER = '4' ) AND "
					Endif

					cQuery += "DA1.D_E_L_E_T_ = ' ' "
					cQuery += "AND NOT EXISTS ( "
					cQuery += "SELECT DA1B.DA1_CODPRO  "
					cQuery += "FROM "+RetSqlName("DA1")+ " DA1B "
					cQuery += "WHERE "
					cQuery += "DA1B.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
					cQuery += "DA1B.DA1_CODTAB = '"+cTabPreco+"' AND "
					cQuery += "DA1B.DA1_CODPRO = '"+cProduto+"' AND "
					cQuery += "DA1B.DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
					cQuery += "DA1B.DA1_ATIVO = '1' AND  "
					cQuery += "( DA1B.DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1B.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "

					If !(nQtde == 0 .And. Empty(cCliente))
						cQuery += "( DA1B.DA1_TPOPER = '"+cTpOper+"' OR DA1B.DA1_TPOPER = '4' ) AND "
					Endif
					cQuery += "DA1B.D_E_L_E_T_ = ' ' ) "

					cQuery += " UNION "
					cQuery += "SELECT * "
					cQuery += "FROM "+RetSqlName("DA1")+ " DA1 "
					cQuery += "WHERE "
					cQuery += "DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
					cQuery += "DA1.DA1_CODTAB = '"+cTabPreco+"' AND "
					cQuery += "DA1.DA1_CODPRO LIKE '"+cProduto+"%' AND "
					cQuery += "DA1.DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
					cQuery += "DA1.DA1_ATIVO = '1' AND  "
					cQuery += "( DA1.DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "

					If !(nQtde == 0 .And. Empty(cCliente))
						cQuery += "( DA1.DA1_TPOPER = '"+cTpOper+"' OR DA1.DA1_TPOPER = '4' ) AND "
					Endif

					cQuery += "DA1.D_E_L_E_T_ = ' ' "
					cQuery += "AND NOT EXISTS ( "
					cQuery += "SELECT DA1C.DA1_CODPRO  "
					cQuery += "FROM "+RetSqlName("DA1")+ " DA1C "
					cQuery += "WHERE "
					cQuery += "DA1C.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
					cQuery += "DA1C.DA1_CODTAB = '"+cTabPreco+"' AND "
					cQuery += "DA1C.DA1_REFGRD = '"+cProdRef+"' AND "
					cQuery += "DA1C.DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
					cQuery += "DA1C.DA1_ATIVO = '1' AND  "
					cQuery += "( DA1C.DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1C.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "

					If !(nQtde == 0 .And. Empty(cCliente))
						cQuery += "( DA1C.DA1_TPOPER = '"+cTpOper+"' OR DA1C.DA1_TPOPER = '4' ) AND "
					Endif
					cQuery += "DA1C.D_E_L_E_T_ = ' ' ) ) QRYDAI "

				Endif

				cQuery += "ORDER BY "+SqlOrder(DA1->(IndexKey()))
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.T.,.T.)

				If (cAliasDA1)->(!Eof())
					nProcessa := 1
				Else
					SB1->(dbSetOrder(1))
					If SB1->(MsSeek(xFilial("SB1")+cProduto))
						cGrupo := SB1->B1_GRUPO
						If !Empty(cGrupo)
							(cAliasDA1)->(dbCloseArea())
							cAliasDA1 := GetNextAlias()

							cQuery := "SELECT * "
							cQuery += "FROM "+RetSqlName("DA1")+ " DA1 "
							cQuery += "WHERE "
							cQuery += "DA1_FILIAL = '"+xFilial("DA1")+"' AND "
							cQuery += "DA1_CODTAB = '"+cTabPreco+"' AND "
							If cPaisLoc == "BRA"
								cQuery += "DA1_GRUPO = '"+cGrupo+"' AND "
							EndIf
							cQuery += "DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
							cQuery += "DA1_ATIVO = '1' AND  "
							cQuery += "( DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "
							If !(nQtde == 0 .And. Empty(cCliente))
								cQuery += "( DA1_TPOPER = '"+cTpOper+"' OR DA1_TPOPER = '4' ) AND "
							Endif
							cQuery += "DA1.D_E_L_E_T_ = ' ' "
							cQuery += "ORDER BY "+SqlOrder(DA1->(IndexKey()))

							cQuery := ChangeQuery(cQuery)

							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.T.,.T.)

							If (cAliasDA1)->(!Eof())
								nProcessa := 2
							EndIf
						EndIf
					EndIf
				Endif
				For nY := 1 To Len(aStruDA1)
					If aStruDA1[nY][2]<>"C"
						TcSetField(cAliasDA1,aStruDA1[nY][1],aStruDA1[nY][2],aStruDA1[nY][3],aStruDA1[nY][4])
					EndIf
				Next nY
			Else
				#ENDIF
				lSeekDA1:= aPesqDA1(cTabPreco,cProduto)
				If lSeekDA1
					nProcessa := 1
				Else
					SB1->(dbSetOrder(1))
					If SB1->(MsSeek(xFilial("SB1")+cProduto))
						cGrupo := SB1->B1_GRUPO
						If !Empty(cGrupo)
							dbSelectarea("DA1")
							dbSetOrder(4)
							If MsSeek(xFilial("DA1")+ cTabPreco + cGrupo)
								nProcessa := 2
							EndIf
						EndIF
					Endif
				EndIf
				#IFDEF TOP
			Endif
			#ENDIF

			If nProcessa > 0

				If nQtde == 0 .And. Empty(cCliente)
					nPrcVen   := (cAliasDA1)->DA1_PRCVEN
					nMoedaTab := (cAliasDA1)->DA1_MOEDA
					nFator    := (cAliasDA1)->DA1_PERDES

					lPrcDA1   := .T.
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco o preco e analiso a qtde de acordo com a faixa³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea(cAliasDA1)
					While (cAliasDA1)->(!Eof()) .And. (cAliasDA1)->DA1_FILIAL == xFilial("DA1") .And.;
					(cAliasDA1)->DA1_CODTAB == cTabPreco .And.;
					If(nProcessa==1,Left((cAliasDA1)->DA1_CODPRO,nTamProd)== cProduto .Or. (cAliasDA1)->DA1_CODPRO==cProduto .Or. (cAliasDA1)->DA1_REFGRD == cProdRef,(cAliasDA1)->DA1_GRUPO==cGrupo)

						If nQtde <= (cAliasDA1)->DA1_QTDLOT .And. (cAliasDA1)->DA1_ATIVO == "1"

							If Empty((cAliasDA1)->DA1_ESTADO) .And. ((cAliasDA1)->DA1_TPOPER == cTpOper .Or. (cAliasDA1)->DA1_TPOPER == "4")

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica a vigencia do item                                   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

								nQtdLote := (cAliasDA1)->DA1_QTDLOT

								While (cAliasDA1)->(!Eof()) .And. (cAliasDA1)->DA1_FILIAL == xFilial("DA1") .And.;
								(cAliasDA1)->DA1_CODTAB == cTabPreco .And.;
								If(nProcessa==1,Left((cAliasDA1)->DA1_CODPRO,nTamProd)== cProduto .Or. (cAliasDA1)->DA1_CODPRO==cProduto .Or. (cAliasDA1)->DA1_REFGRD == cProdRef ,(cAliasDA1)->DA1_GRUPO==cGrupo) .And.;
								(cAliasDA1)->DA1_QTDLOT == nQtdLote .And.;
								(cAliasDA1)->DA1_DATVIG <= dDataVld
									If nQtde <= (cAliasDA1)->DA1_QTDLOT .And. (cAliasDA1)->DA1_ATIVO == "1" .And.;
									((!Empty((cAliasDA1)->DA1_ESTADO) .And. ( If(lProspect, SUS->US_EST, SA1->A1_EST) == (cAliasDA1)->DA1_ESTADO )).Or.(Empty((cAliasDA1)->DA1_ESTADO) .And. ((cAliasDA1)->DA1_TPOPER == cTpOper .Or. (cAliasDA1)->DA1_TPOPER == "4")))

										nPrcVen   := (cAliasDA1)->DA1_PRCVEN
										nMoedaTab := (cAliasDA1)->DA1_MOEDA
										nFator    := (cAliasDA1)->DA1_PERDES

										lPrcDA1   := .T.
									EndIf

									dbSelectArea(cAliasDA1)
									dbSkip()
								Enddo
								If lPrcDA1
									Exit
								Endif

							ElseIf !Empty((cAliasDA1)->DA1_ESTADO) .And. ( If(lProspect, SUS->US_EST, SA1->A1_EST) == (cAliasDA1)->DA1_ESTADO )

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica a vigencia do item                                   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

								nQtdLote := (cAliasDA1)->DA1_QTDLOT

								While (cAliasDA1)->(!Eof()) .And. (cAliasDA1)->DA1_FILIAL == xFilial("DA1") .And.;
								(cAliasDA1)->DA1_CODTAB == cTabPreco .And.;
								If(nProcessa==1,Left((cAliasDA1)->DA1_CODPRO,nTamProd)== cProduto .Or. (cAliasDA1)->DA1_CODPRO==cProduto .Or. (cAliasDA1)->DA1_REFGRD == cProdRef,(cAliasDA1)->DA1_GRUPO==cGrupo) .And.;
								(cAliasDA1)->DA1_QTDLOT == nQtdLote .And.;
								(cAliasDA1)->DA1_DATVIG <= dDataVld
									If nQtde <= (cAliasDA1)->DA1_QTDLOT .And. (cAliasDA1)->DA1_ATIVO == "1" .And.;
									((!Empty((cAliasDA1)->DA1_ESTADO) .And. ( If(lProspect, SUS->US_EST, SA1->A1_EST) == (cAliasDA1)->DA1_ESTADO )).Or.(Empty((cAliasDA1)->DA1_ESTADO) .And. ((cAliasDA1)->DA1_TPOPER == cTpOper .Or. (cAliasDA1)->DA1_TPOPER == "4")))

										nPrcVen   := (cAliasDA1)->DA1_PRCVEN
										nMoedaTab := (cAliasDA1)->DA1_MOEDA
										nFator    := (cAliasDA1)->DA1_PERDES

										lPrcDA1   := .T.

									Endif

									dbSelectArea(cAliasDA1)
									dbSkip()
								Enddo
								If lPrcDA1
									Exit
								Endif

							EndIf
						EndIf
						dbSelectArea(cAliasDA1)
						dbSkip()
					Enddo

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente atualiza com o SB1 caso nao tenha achado nenhuma tabela    ³
					//³caso contrario retornara o preco zerado                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If nTipo == 1
						If nPrcVen == 0 .And. !lPrcDA1
							dbSelectArea("SB1")
							dbSetOrder(1)
							If MsSeek(xFilial("SB1")+cProduto)
								nPrcVen := SB1->B1_PRV1
							EndIf
							lUltResult := .F.
						Endif
					Endif

				EndIf
			Else
				If nTipo == 1
					If nPrcVen == 0 .And. !lPrcDA1
						dbSelectArea("SB1")
						dbSetOrder(1)
						If MsSeek(xFilial("SB1")+cProduto)
							nPrcVen := SB1->B1_PRV1
						EndIf
					EndIf
				Endif
				lUltResult := .F.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o tipo for para trazer preco converte para a moeda    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			nFator := Iif( nFator == 0, 1, nFator )

			If nTipo == 1
				nResult := xMoeda(nPrcVen,nMoedaTab,nMoeda,,TamSx3("D2_PRCVEN")[2])
			Else
				nResult	:= nFator
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Guarda os ultimos resultados                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUltResult
				aadd(aUltResult,{cTabPreco,cProduto,nQtde,cCliente,cLoja,nMoeda,cFilAnt,nResult,nFator,lProspect})
				If Len(aUltResult) > MAXSAVERESULT
					aUltResult := aDel(aUltResult,1)
					aUltResult := aSize(aUltResult,MAXSAVERESULT)
				EndIf
			EndIf
		Else

			If nTipo == 1
				nResult := aUltResult[nScan][8]
			Else
				nResult := aUltResult[nScan][9]
			Endif
		EndIf
	Endif
	If lQuery
		dbSelectArea(cAliasDA1)
		dbCloseArea()
		dbSelectArea("DA1")
	Endif

	RestArea(aAreaSB1)
	RestArea(aArea)
Return(nResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaVldTabPrc³ Autor ³Eduardo Riera          ³ Data ³03.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da tabela de precos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tabela valida                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tabela de Preco                                      ³±±
±±³          ³ExpC2: Condicao de Pagamento                                ³±±
±±³          ³ExpN3: Help                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaVldTabPrc(cCodTab,cCondPag,cHelp,dDataVld)

	Local aArea		:= GetArea()
	Local lValido	:= .T.
	Local lTabLoja	:= cPaisLoc != "BRA" .And. nModulo == 12
	Local lCenVenda	:= .F.

	DEFAULT dDataVld := dDataBase

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o cenario de vendas estiver integrado com o sigaloja,   ³
	//³nao eh necessario validar a tabela seguindo o padrao antigo³
	//³de numeracao de tabela de preco do loja, ex: 1,2,3,4,etc.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nModulo == 12
		lCenVenda	:= SuperGetMv("MV_LJCNVDA",,.F.)
		lTabLoja	:= !lCenVenda .AND. cPaisLoc != "BRA" .And. nModulo == 12
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a vigencia da tabela de precos                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DA0")
	dbSetOrder(1)
	If MsSeek(xFilial("DA0")+cCodTab)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico se a tabela de preço está ativa e depois faço a validação da  ³
		//³ vigencia da tabela de preço, conforme o tipo de hora.                  ³
		//³ DA0_TPHORA = (1-Unico ou 2-Recorrente)                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (DA0->DA0_ATIVO == "2") .Or.;
		(DA0->DA0_TPHORA == "1" .And. !(SubtHoras(dDataVld,Time(),If(Empty(DA0->DA0_DATATE),dDataVld,DA0->DA0_DATATE),DA0->DA0_HORATE) >= 0 .And.;
		SubtHoras(DA0->DA0_DATDE,DA0->DA0_HORADE,dDataVld,Time()) >= 0)) .Or.;
		(DA0->DA0_TPHORA == "2" .And. !(dDataVld >= DA0->DA0_DATDE .And. dDataVld <= If(Empty(DA0->DA0_DATATE),dDataVld,DA0->DA0_DATATE) .And.;
		(SubStr(Time(),1,5) >= DA0->DA0_HORADE .And. SubStr(Time(),1,5) <= DA0->DA0_HORATE)))
			If Empty(cHelp)
				Help(" ",1,"OMSTABPRC1")   		//"Tabela de preço fora da vigência"
			Else
				cHelp := "OMSTABPRC1"
			EndIf
			lValido := .F.
		Else
			If !Empty(cCondPag) .And. !Empty(DA0->DA0_CONDPG) .And. cCondPag <> DA0->DA0_CONDPG
				If Empty(cHelp)
					Help(" ",1,"OMSTABPRC2")  	//"Condição de pagamento inválida para esta tabela de preços"
				Else
					cHelp := "OMSTABPRC2"
				EndIf
				lValido := .F.
			EndIf
		EndIf
	ElseIf !lTabLoja
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a tabela nao esta em branco e nao e' tabela 1              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cCodTab) .And. cCodTab <> PadR( "1", Len( DA0->DA0_CODTAB ) )
			If Empty(cHelp)
				Help(" ",1,"REGNOIS")
			Else
				cHelp := "REGNOIS"
			EndIf
			lValido := .F.
		EndIf
	EndIf
	RestArea(aArea)
Return(lValido)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Oms010Leg  ³ Autor ³Henry Fila             ³ Data ³30.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Legenda das tabelas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010Leg()

	Local aLegenda := { { "BR_VERMELHO"  , OemToAnsi( STR0016 ) },;
	{ "BR_VERDE"    , OemToAnsi( STR0017) },;
	{ "BR_LARANJA"  , OemToAnsi( STR0018) } }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para alterar cores da legenda    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("OM010LEG")
		aLegenda := ExecBlock("OM010LEG",.F.,.F.,aLegenda)
	Endif

	BrwLegenda( cCadastro, OemToAnsi( "Status" ), aLegenda  ) //"Somente faturada e nao acertada"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Oms010Hora ³ Autor ³Henry Fila             ³ Data ³30.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao das horas no cabecalho da tabela de precos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010Hora()

	Local lRet := .T.

	If !Empty( M->DA0_DATATE ) .And. ( M->DA0_DATDE == M->DA0_DATATE ) .And.;
	!Empty(M->DA0_HORATE)

		If M->DA0_HORATE < M->DA0_HORADE
			Help(" ",1,"OMS010HORA")
			lRet := .F.
		Endif
	Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MaReleTabPrcºAutor  ³Marcelo Kotaki    º Data ³  11/26/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Essa funcao limpa o conteudo do array com os precos da      º±±
±±º          ³ultima tabela de preco                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MaReleTabPrc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa buffer                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aUltResult := Nil

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Os010CanDel³ Autor ³Henry Fila             ³ Data ³07.04.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se a tabela de precos pode ser excluida            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. (pode ser excluida) ou .F. (nao pode                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo da tabela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Os010CanDel(cCodTab)

	Local cAliasACO := "ACO"
	Local cAliasACQ := "ACQ"
	Local cAliasACT := "ACT"

	Local lRet      := .T.

	#IFDEF TOP
	Local cQuery    := ""
	#ENDIF

	#IFDEF TOP

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica regras de desconto                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lQuery    := .T.
	cAliasACO := "QRYACO"

	cQuery    := "SELECT COUNT(*) QTDREC FROM "
	cQuery    += RetSqlName("ACO")+ " ACO "
	cQuery    += " WHERE "
	cQuery    += "( ACO_FILIAL ='"+xFilial("ACO")+"' AND "
	cQuery    += "ACO_CODTAB = '"+cCodTab+"' AND "
	cQuery    += "ACO.D_E_L_E_T_ = ' ' ) "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACO,.T.,.T.)

	If (cAliasACO)->QTDREC > 0
		lRet := .F.
	Endif

	(cAliasACO)->(dbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica regras de bonificacao                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lRet

		cAliasACQ := "QRYACQ"

		cQuery    := "SELECT COUNT(*) QTDREC FROM "
		cQuery    += RetSqlName("ACQ")+ " ACQ "
		cQuery    += " WHERE "
		cQuery    += "( ACQ_FILIAL ='"+xFilial("ACQ")+"' AND "
		cQuery    += "ACQ_CODTAB = '"+cCodTab+"' AND "
		cQuery    += "ACQ.D_E_L_E_T_ = ' ' ) "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACQ,.T.,.T.)

		If (cAliasACQ)->QTDREC > 0
			lRet := .F.
		Endif

		(cAliasACQ)->(dbCloseArea())

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica regras de negocio                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet

		cAliasACT := "QRYACT"

		cQuery    := "SELECT COUNT(*) QTDREC FROM "
		cQuery    += RetSqlName("ACT")+ " ACT "
		cQuery    += " WHERE "
		cQuery    += "( ACT_FILIAL ='"+xFilial("ACT")+"' AND "
		cQuery    += "ACT_CODTAB = '"+cCodTab+"' AND "
		cQuery    += "ACT.D_E_L_E_T_ = ' ' ) "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACT,.T.,.T.)

		If (cAliasACT)->QTDREC > 0
			lRet := .F.
		Endif

		(cAliasACT)->(dbCloseArea())

	Endif

	#ELSE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica regras de desconto                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	(cAliasACO)->(dbSetOrder(1))
	(cAliasACO)->(MsSeek(xFilial("ACO")))

	While (cAliasACO)->(!Eof()) .And. (cAliasACO)->ACO_FILIAL == xFilial("ACO") .And. lRet

		If (cAliasACO)->ACO_CODTAB == cCodTab
			lRet := .F.
		Endif

		ACO->(dbSkip())

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica regras de bonificacao                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet

		(cAliasACQ)->(dbSetOrder(1))
		(cAliasACQ)->(MsSeek(xFilial("ACQ")))

		While (cAliasACQ)->(!Eof()) .And. (cAliasACQ)->ACQ_FILIAL == xFilial("ACQ") .And. lRet

			If (cAliasACQ)->ACQ_CODTAB == cCodTab
				lRet := .F.
			Endif

			ACQ->(dbSkip())

		EndDo

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica regras de negocio                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet

		(cAliasACT)->(dbSetOrder(1))
		(cAliasACT)->(MsSeek(xFilial("ACT")))

		While (cAliasACT)->(!Eof()) .And. (cAliasACT)->ACT_FILIAL == xFilial("ACT") .And. lRet

			If (cAliasACT)->ACT_CODTAB == cCodTab
				lRet := .F.
			Endif

			ACT->(dbSkip())

		EndDo

	Endif

	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a tabela foi usada em algum pedido de vendas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		lRet := !Os010PVAssoc(cCodTab)
	EndIf

	If lRet
		If ExistBlock("OS010DEL")
			lRet := ExecBlock("OS010DEL",.F.,.F.,{cCodTab})
		Endif
	Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010Vld ³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da tabela quando for por produto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Vld()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010Vld()

	Local aArea      := GetArea()
	Local aAreaDA1   := DA1->(GetArea())
	Local aAreaDA0   := DA0->(GetArea())
	Local aItens     := {}

	Local cItem      := ""

	Local nX         := 0
	Local nPosCod    := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_CODTAB"})
	Local nPosTabela := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_DESTAB"})
	Local nPosItem   := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_ITEM"})
	Local nPosPrc    := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_PRCBAS"})
	Local lRet       := .T.

	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+mv_par02))
		aCols[n][nPosPrc] := SB1->B1_PRV1
	Endif

	DA0->(dbsetOrder(1))
	If DA0->(MsSeek(xFilial("DA0")+M->DA1_CODTAB))
		aCols[n][nPosTabela] := DA0->DA0_DESCRI

		DA1->(dbSetORder(3))
		DA1->(MsSeek(xFilial("DA1")+M->DA1_CODTAB+"ZZZZ",.T.))
		dbSkip(-1)
		cItem := Soma1(DA1->DA1_ITEM)

		If aScan(aCols,{|x| Upper(Alltrim(x[nPosCod])) == M->DA1_CODTAB})	> 0

			For nX := 1 to Len(aCols)
				If !aCols[nX][Len(aHeader)+1]
					If aCols[nX][nPosCod] == M->DA1_CODTAB .And. n <> nX

						DA1->(dbSetORder(3))
						If !DA1->(MsSeek(xFilial("DA1")+M->DA1_CODTAB+aCols[nX][nPosItem],.T.))
							cItem := Soma1(cItem)
						Endif
					Endif
				Endif
			Next nX

		Endif

		aCols[n][nPosItem] := cItem

	Else
		Help(" ",1,"REGNOIS")
		lRet := .F.
	Endif

	RestArea(aAreaDA0)
	RestArea(aAreaDA1)
	RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Oms010PFor³ Autor ³ Henry Fila            ³ Data ³17/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara a funcao de copia para evitar que seja chamada a   ³±±
±±³          ³ janela de filiais                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do cabecalho do pedido de venda                ³±±
±±³          ³ExpN2: Recno do cabecalho do pedido de venda                ³±±
±±³          ³ExpN3: Opcao do arotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Oms010PFor(cAlias,nReg,nOpc)

	Local aRotBkp := aClone(aRotina)

	aRotina := {{ OemToAnsi(STR0013),"Oms010For",0,3}}

	Oms010For(calias,nReg,1)

	aRotina := aClone(aRotBkp)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010Cpy ³ Autor ³ Eduardo Riera         ³ Data ³ 23/05/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Copia da tabela de preco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Tab()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                       ³±±
±±³          ³ExpN2: Numero do Registro                                     ³±±
±±³          ³ExpN3: Opcao do aRotina                                       ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010Cpy(cAlias,nReg,nOpc)

	Private aRotina := {{ "","AxPesqui",0,1},;
	{ "","Oms010Tab",0,2},;
	{ "","Oms010Tab",0,3},;
	{ "","Oms010Tab",0,4},;
	{ "","Oms010Tab",0,5},;
	{ "","Oms010Tab",0,3},;
	{ "","Oms010PFor",0,3},;
	{ "","Oms010Rej",0,5},;
	{ "","Oms010Leg",0,2} }

	Oms010Tab(cAlias,nReg,nOpc,,.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

	Private aRotina := {{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.},;		//"Pesquisar"
	{ OemToAnsi(STR0002),"Oms010Tab"		,0,2,0,NIL},;	//"Visualizar"
	{ OemToAnsi(STR0003),"Oms010Tab"		,0,3,0,NIL},;	//"Incluir"
	{ OemToAnsi(STR0004),"Oms010Tab"		,0,4,0,NIL},;	//"Alterar"
	{ OemToAnsi(STR0005),"Oms010Tab"		,0,5,0,NIL},;	//"Excluir"
	{ OemToAnsi(STR0012),"Oms010Cpy"		,0,4,0,NIL},;  //"Copiar"
	{ OemToAnsi("Gerar"),"Oms010PFor"	    ,0,3,0,NIL},;
	{ OemToAnsi(STR0007),"Oms010Rej"		,0,5,0,NIL},;  //"Reajuste"
	{ OemtoAnsi("Legenda"),"Oms010Leg"		,0,2,0,.F.} }

	If ExistBlock("OM010MNU")
		ExecBlock("OM010MNU",.F.,.F.)
	EndIf

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010aRec³ Autor ³ Marco Bianchi         ³ Data ³ 13/12/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina para preencher array aRecno que sera utilizado nas     ³±±
±±³          ³opcoes diferentes de inclisao e copia.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010aRec()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array a ser preenchido                                 ³±±
±±³          ³ExpL2: identifica se esta executando query                    ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010aRec(aRecNo,lQuery)

	If !lQuery
		aadd(aRecno,Recno())
	Else
		aadd(aRecno,DA1RECNO)
	Endif

Return (.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OMS010VlRfºAutor  ³Patricia D. Aguiar  º Data ³  29/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a digitacao da referencia de Grade                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OMS010VlRf()

	Local lRetorno 	  := .T.
	Local cProdRef 	  := &(ReadVar())
	Local lGrade   	  := MaGrade()
	Local lReferencia := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se produto eh referencia de grade                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGrade // utilização de grade ativa
		lReferencia:=MatGrdPrrf(@cProdRef)
		If !lReferencia //
			Help(" ",1,"REFGRADE")
			lRetorno:=.F.
		Endif
	Else
		Help(" ",1,"NOGRADE")
		lRetorno := .f.
	Endif
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³aPesqDA1  ºAutor  ³Patricia Duca Aguiarº Data ³  03/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao genérica para pesquisa no arquivo DA1(tabela de pre-)º±±
±±º          ³co, que deve considerar codigo do produto ou Referencia de  º±±
±±º          ³grade                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Codigo da Tabela de preço                          º±±
±±º          ³ ExpC2 - Codigo do Produto                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function aPesqDA1(cTabela,cProduto)

	Local cProdRef    := cProduto
	Local lRet        := .F.
	Local lReferencia := .F.

	cProduto:= Pad(cProduto,Len(DA1->DA1_CODPRO))
	lReferencia := MatGrdPrRf(@cProdRef,.T.)
	If Alltrim(cProduto)== Alltrim(cProdRef) .And. lReferencia
		dbSelectarea("DA1")
		dbSetOrder(5)
		If MsSeek(xFilial("DA1")+cTabela+Pad(cProdRef,len(DA1->DA1_REFGRD)),.F.)
			lRet := .T.
		Else
			dbSelectarea("DA1")
			dbSetOrder(1)
			DbSeek(xFilial("DA1")+cTabela+cProduto,.T.)
			If !EOF()
				lRet:=.T.
			Endif
		Endif
	Else
		dbSelectarea("DA1")
		dbSetOrder(1)
		If MsSeek(xFilial("DA1")+cTabela+cProduto,.F.)
			lRet := .T.
		Else
			If MaGrade() .And. lReferencia
				dbSelectarea("DA1")
				dbSetOrder(5)
				If MsSeek(xFilial("DA1")+cTabela+Pad(cProdRef,len(DA1->DA1_REFGRD)),.F.)
					lRet := .T.
				Endif
			Endif
		Endif
	Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MontaCols ³ Autor ³ Vendas & CRM          ³ Data ³ 02/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Montagem do aCols (a montagem do aHeader e feita automatica-³±±
±±³          ³mente pela funcao FILLGETDADOS) na alteracao.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MontaCols()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaCols(aCols,aHeader,lCopia,aRecno)

	Local aArea    := GetArea()
	Local aAreaDA0 := DA0->(GetArea())
	Local aAreaDA1 := DA1->(GetArea())
	Local aCampos  := {}
	Local cAliasDA1:= GetNextAlias()
	Local cQuery   := ""
	Local aStruDA1 := {}
	Local nCntFor  := 0
	Local nUsado   := Len(aHeader)
	Local nX       := 0
	Local lOM010COL:= ExistBlock("OM010COL")

	If ExistBlock("OM010CPO")
		aCampos := ExecBlock("OM010CPO",.F.,.F.)
	Endif

	dbSelectArea("DA1")
	dbSetOrder(3)

	aStruDA1  := DA1->(dbStruct())

	cQuery := "SELECT DA1.*,DA1.R_E_C_N_O_ DA1RECNO, B1_DESC, B1_PRV1 FROM "
	cQuery += RetSqlName("DA1")+ " DA1 "
	cQuery += "LEFT JOIN " +RetSqlName("SB1")+ " SB1  "
	cQuery += "  ON SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"
	cQuery += "  AND SB1.B1_COD     = DA1.DA1_CODPRO"
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE DA1.DA1_FILIAL = '"+xFilial("DA1")+"'"
	cQuery += "  AND DA1.DA1_CODTAB = '"+DA0->DA0_CODTAB+"'"
	cQuery += "  AND DA1.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY "+SqlOrder(DA1->(IndexKey()))

	If ExistBlock("OM010QRY")
		cQuery := ExecBlock("OM010QRY",.F.,.F.,{cQuery})
	Endif

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.T.,.T.)

	For nCntFor := 1 To Len(aStruDA1)
		If ( aStruDA1[nCntFor,2]<>"C" )
			TcSetField(cAliasDA1,aStruDA1[nCntFor,1],aStruDA1[nCntFor,2],aStruDA1[nCntFor,3],aStruDA1[nCntFor,4])
		EndIf
	Next nCntFor
	TcSetField(cAliasDA1,"B1_PRV1","N",TamSX3("B1_PRV1")[1],TamSX3("B1_PRV1")[2])

	While (cAliasDA1)->(!Eof())
		Aadd(aCols,Array(nUsado+1))

		If !lCopia
			aadd(aRecno,(cAliasDA1)->DA1RECNO)
		Endif

		For nX := 1 To nUsado
			If ( aHeader[nX,10] !=  "V" )
				aCOLS[Len(aCols)][nX] := (cAliasDA1)->(FieldGet(FieldPos(aHeader[nX,2])))
			ElseIf AllTrim(aHeader[nX,2]) == "DA1_ALI_WT"
				aCOLS[Len(aCols)][nX] := "DA1"
			ElseIf AllTrim(aHeader[nX,2]) == "DA1_REC_WT"
				aCOLS[Len(aCols)][nX] := (cAliasDA1)->DA1RECNO
			ElseIf AllTrim(aHeader[nX,2]) == "DA1_DESCRI"
				aCOLS[Len(aCols)][nX] := (cAliasDA1)->B1_DESC
			ElseIf AllTrim(aHeader[nX,2]) == "DA1_PRCBAS"
				aCOLS[Len(aCols)][nX] := (cAliasDA1)->B1_PRV1
			ElseIf !Empty(Ascan(aCampos,AllTrim(aHeader[nX,2]))) .And. lOM010COL
				aCOLS[Len(aCols)][nX] := ExecBlock("OM010COL",.F.,.F.,{cAliasDA1,AllTrim(aHeader[nX,2])})
			Else
				aCOLS[Len(aCols)][nX] := CriaVar(aHeader[nX,2],.T.)
			EndIf
		Next nX
		aCols[Len(aCols)][nUsado+1] := .F.
		dbSelectArea(cAliasDA1)
		dbSkip()
	EndDo

	dbSelectArea(cAliasDA1)
	dbCloseArea()
	ChkFile("DA1",.F.)
	dbSelectArea("DA0")

	RestArea(aAreaDA1)
	RestArea(aAreaDA0)
	RestArea(aArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMSA010Grd³Autor  ³Alexandre Inacio Lemes ³ Data ³22/10/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a digitacao de produtos de grade                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. se Valido ou .F. se Invalido                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Pergunte OMS010 da Tabela de Precos Faturamento OMSA010.PRX  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function OMSA010Grd()

	Local aArea	      := GetArea()
	Local lReferencia := .F.
	Local lRet 		  := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a grade esta ativa e se o produto digitado e uma referencia     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MaGrade() .And. !Empty(&(ReadVar()))
		cProdRef := &(ReadVar())
		lReferencia := MatGrdPrrf(@cProdRef)

		If lReferencia
			lRet := .T.
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o Produto nao for um produto de grade executa a validacao no SB1 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SB1")
			dbSetOrder(1)
			If !dbSeek(xFilial("SB1")+cProdRef,.F.)
				Help("  ",1,"REGNOIS")
				lRet := .F.
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o Produto nao for um produto de grade executa a validacao no SB1     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := ExistCpo("SB1")
	EndIf

	RestArea(aArea)

Return(lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMSAGrPrd ³Autor  ³Rodrigo T. Silva 		³ Data ³11/11/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Interface de Grade de Produtos - Tabela de Precos			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³OMSA010													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OMSAGrPrd()
	Local lRet := .T.
	Local nITEMGR := aScan(aHeader,{|x| AllTrim(x[2]) == "DA1_ITEMGR"})
	Local nDESPRO := aScan(aHeader,{|x| AllTrim(x[2]) == "DA1_DESCRI"})
	Local nDESCON := aScan(aHeader,{|x| AllTrim(x[2]) == "DA1_VLRDES"})
	Local nPVENDA := aScan(aHeader,{|x| AllTrim(x[2]) == "DA1_PRCVEN"})
	Local nFATOR  := aScan(aHeader,{|x| AllTrim(x[2]) == "DA1_PERDES"})
	Local lGrade  := !Empty(nITEMGR) .And. MaGrade()
	Local lReferencia := .F.

	If lGrade
		lReferencia := MatGrdPrrf(M->DA1_CODPRO)
		oGrade:MontaGrade(n,M->DA1_CODPRO,.T.,,lReferencia)
	EndIf

	If lReferencia
		aCols[n,nITEMGR] := "01"
		aCols[n,nDESPRO] := oGrade:GetDescProd(M->DA1_CODPRO)
		aCols[n,nDESCON] := 0
		aCols[n,nPVENDA] := 0
		aCols[n,nFATOR]  := 0
	ElseIf (lRet := ExistCpo("SB1",M->DA1_CODPRO))
		aCols[n,nDESPRO] := Posicione("SB1",1,xFilial("SB1")+M->DA1_CODPRO,"B1_DESC")
		If !Empty(nITEMGR)
			aCols[n,nITEMGR] := CriaVar("DA1_ITEMGR")
		EndIf
	EndIf
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMSAGrPV	³Autor  ³Rodrigo T. Silva 		³ Data ³11/11/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Se a Grade estiver ativa, efetua a entrada de dados na colu- ³±±
±±³          ³na preco de venda.			                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³OMSA010													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms010Grd()
	Local nCODPRO := aScan(aHeader,{|x| AllTrim(x[2]) == "DA1_CODPRO"})
	Local lGrade  := DA1->(FieldPos("DA1_ITEMGR")) > 0 .And. MaGrade() .And. !Empty(nCODPRO)
	Local cCampo  := Substr(ReadVar(),4)

	If lGrade .And. MatGrdPrrf(aCols[n,nCODPRO])
		oGrade:cProdRef := aCols[n,nCODPRO]
		oGrade:lShowGrd := .T.
		oGrade:nPosLinO := n
		oGrade:Show(cCampo)
		&(ReadVar()) := oGrade:SomaGrade(cCampo,n)
	ElseIf cCampo # "DA1_PRCVEN"
		&(ReadVar()) := Oms010Calc()
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OMSACalV ºAutor  ³Andre Anjos         º Data ³  17/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Calcula os valores dos campos para grade simulando a execu º±±
±±º          ³ cao dos gatilhos.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ OMSA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OMSACalV()
	Local lRet    := .T.
	Local nColuna := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(Substr(Readvar(),4))})
	Local nPRV1   := Posicione("SB1",1,xFilial("SB1")+oGrade:GetNameProd(,n,nColuna),"B1_PRV1")
	Local nValDig := &(ReadVar())

	If oGrade:cCpo # "DA1_PRCVEN" .And. Empty(nPRV1)
		&(ReadVar()) := 0
	Else
		Do Case
			Case oGrade:cCpo == "DA1_VLRDES"
			oGrade:aColsGrade[oGrade:nPosLinO][n][nColuna][oGrade:GetFieldGrdPos("DA1_PRCVEN")] := nPRV1 - nValDig
			oGrade:aColsGrade[oGrade:nPosLinO][n][nColuna][oGrade:GetFieldGrdPos("DA1_PERDES")] := (nPRV1 - nValDig) / nPRV1
			Case oGrade:cCpo == "DA1_PERDES"
			oGrade:aColsGrade[oGrade:nPosLinO][n][nColuna][oGrade:GetFieldGrdPos("DA1_PRCVEN")] := nPRV1 * nValDig
		EndCase
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OMSASomG ºAutor  ³Andre Anjos		 º Data ³  17/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Soma grades para atualizar campos no aCols                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ OMSA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OMSASomG()
	Local lRet := .T.
	Local nPRCVEN := aScan(oGrade:aHeadAux, {|x| AllTrim(x[2]) == "DA1_PRCVEN"})
	Local nVLRDES := aScan(oGrade:aHeadAux, {|x| AllTrim(x[2]) == "DA1_VLRDES"})
	Local nPERDES := aScan(oGrade:aHeadAux, {|x| AllTrim(x[2]) == "DA1_PERDES"})

	oGrade:lShowMsgDiff := .F.
	Do Case
		Case oGrade:cCpo == "DA1_PRCVEN"
		oGrade:aColsAux[oGrade:nPosLinO,nVLRDES] := 0
		oGrade:aColsAux[oGrade:nPosLinO,nPERDES] := 0
		oGrade:ZeraGrade("DA1_VLRDES")
		oGrade:ZeraGrade("DA1_PERDES")
		Case oGrade:cCpo == "DA1_VLRDES"
		oGrade:aColsAux[oGrade:nPosLinO,nPRCVEN] := oGrade:SomaGrade("DA1_PRCVEN",oGrade:nPosLinO)
		oGrade:aColsAux[oGrade:nPosLinO,nPERDES] := oGrade:SomaGrade("DA1_PERDES",oGrade:nPosLinO)
		Case oGrade:cCpo == "DA1_PERDES"
		oGrade:aColsAux[oGrade:nPosLinO,nPERDES] := oGrade:SomaGrade("DA1_PERDES",oGrade:nPosLinO)
		oGrade:aColsAux[oGrade:nPosLinO,nPRCVEN] := oGrade:SomaGrade("DA1_PRCVEN",oGrade:nPosLinO)
		oGrade:aColsAux[oGrade:nPosLinO,nVLRDES] := 0
		oGrade:ZeraGrade("DA1_VLRDES")
	EndCase
	oGrade:lShowMsgDiff := .T.

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Os010PVAssoc ³ Autor ³ Vendas CRM            ³ Data ³01.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Verifica se a tabela de precos está associada	                ³±±
±±³			 ³a um pedido de venda 								            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. (tem PV associado) ou .F. (nao tem PV)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo da tabela                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Os010PVAssoc(cCodTab)

	Local aArea		:= GetArea()
	Local aAreaSC5	:= SC5->(GetArea())
	Local lRet      := .F.
	Local cArqInd	:= ""
	Local cCond		:= ""
	Local nIndex	:= 0

	#IFDEF TOP

	Local cQuery    := ""
	Local cAliasSC5 := "SC5"

	If TcSrvType() <> "AS/400"

		cAliasSC5 := GetNextAlias()

		cQuery    := "SELECT COUNT(*) QTDREC FROM "
		cQuery    += RetSqlName("SC5")+ " SC5 "
		cQuery    += " WHERE C5_TABELA = '"+cCodTab+"' AND D_E_L_E_T_ = '' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC5,.T.,.T.)

		If (cAliasSC5)->QTDREC > 0
			lRet := .T.
		Endif

		(cAliasSC5)->(dbCloseArea())
	Else

		#ENDIF

		cArqInd	:= CriaTrab(,.F.)

		cCond	:= 'C5_FILIAL == "' + xFilial("SC5") + '" .AND. C5_TABELA == "' + cCodTab + '" '

		IndRegua("SC5",cArqInd,"C5_FILIAL+C5_TABELA",,cCond)
		DbSelectArea("SC5")
		nIndex := RetIndex("SC5")
		DbSetIndex(cArqInd+OrdBagExt())
		DbSetOrder(nIndex+1)
		DbGoTop()

		While SC5->(!Eof())

			If SC5->C5_TABELA == cCodTab
				lRet := .T.
				Exit
			Endif

			SC5->(DbSkip())
		End

		dbSelectArea("SC5")
		dbClearFilter()
		RetIndex("SC5")
		Ferase(cArqInd+OrdBagExt())

		#IFDEF TOP
	EndIf
	#ENDIF

	RestArea(aAreaSC5)
	RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³OMSA010Int³ Autor ³ Vendas CRM            ³ Data ³ 15/09/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Realiza integracao com a criterium ou outra integracao       ³±±
±±³          ³que utiliza o framework do SIGALOJA de integracao.            ³±±
±±³          ³ Os parâmetro aIntDA0 e aoIntDA1 normalmente são vazios.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³OMSA010Int()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Momento da chamada, sendo:                             ³±±
±±³          ³           1: Antes de qualquer alteração                     ³±±
±±³          ³           2: Depois das alterações                           ³±±
±±³          ³ExpN2: Opção da rotina                                        ³±±
±±³          ³ExpA3: Array contendo o número do registro e adaptador do DA0.³±±
±±³          ³ExpA4: Array contendo os números dos registros e adaptadores  ³±±
±±³          ³       do DA1.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function OMSA010Int( nMomento, nOpc, aIntDA0, aoIntDA1 )
	Local lIntegra 		:= SuperGetMv("MV_LJGRINT", .F.)	// Se há integração ou não

	If lIntegra
		If nMomento == 1
			MsgRun( "Anotando registros para integração", "Aguarde", {|| OMSA010IniInt( nOpc, aIntDA0, aoIntDA1 ) } )
		ElseIf nMomento == 2
			MsgRun( "Executando integração", "Aguarde", {|| OMSA010FimInt( nOpc, aIntDA0, aoIntDA1 ) } )
		EndIf
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³OMSA010IniInt³ Autor ³ Vendas CRM         ³ Data ³ 15/09/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Faz o cache dos itens antes de serem excluídos, possibilitan-³±±
±±³          ³do o envio dos mesmos, mesmo após de serem apagados.          ³±±
±±³          ³ Os parâmetro aIntDA0 e aoIntDA1 normalmente são vazios.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³OMSA010IniInt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opção da rotina                                        ³±±
±±³          ³ExpA2: Array contendo o número do registro e adaptador do DA0.³±±
±±³          ³ExpA3: Array contendo os números dos registros e adaptadores  ³±±
±±³          ³       do DA1.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function OMSA010IniInt( nOpc, aIntDA0, aoIntDA1 )
	Local oFactory		:= LJCAdapXmlEnvFactory():New()
	Local oTempIntDA1	:= Nil
	Local cChave		:= ""

	// Se houver integração e não for inclusão, anota todos os registros para exclusão, caso algum seja excluído
	If nOpc != 3
		aIntDA0 :=	{ DA0->(Recno()), oFactory:Create( "DA0" ) }
		cChave 	:= xFilial( "DA0" ) + DA0->DA0_CODTAB
		aIntDA0[2]:Inserir( "DA0", cChave, "1", "5" )
		aIntDA0[2]:Gerar()

		aoIntDA1 := {}
		DbSelectArea( "DA1" )
		DbSetOrder( 1 )
		DbSeek( xFilial( "DA1" ) + DA0->DA0_CODTAB )
		// Interage com todos os registros relacionados
		While	xFilial( "DA1" )	== DA0->DA0_FILIAL	.And.;
		DA1->DA1_CODTAB		== DA0->DA0_CODTAB
			cChave := xFilial( "DA1" ) + DA1->DA1_CODTAB + DA1->DA1_ITEM
			oTempIntDA1 := oFactory:Create( "DA1" )
			oTempIntDA1:Inserir( "DA1", cChave, "3", "5" )
			oTempIntDA1:Gerar()
			aAdd( aoIntDA1, { DA1->( Recno() ), oTempIntDA1 } )
			DA1->( DbSkip() )
		End
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³OMSA010FimInt³ Autor ³ Vendas CRM         ³ Data ³ 15/09/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Envia os itens apagados e todos os outros itens.             ³±±
±±³          ³ Os parâmetro aIntDA0 e aoIntDA1 normalmente são vazios.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³OMSA010FimInt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opção da rotina                                        ³±±
±±³          ³ExpA2: Array contendo o número do registro e adaptador do DA0.³±±
±±³          ³ExpA3: Array contendo os números dos registros e adaptadores  ³±±
±±³          ³       do DA1.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function OMSA010FimInt( nOpc, aIntDA0, aoIntDA1 )
	Local oFactory		:= LJCAdapXmlEnvFactory():New( )	// Cria a fabrica de Adaptadores de envio
	Local cChave		:= ""
	Local oTempIntDA1	:= Nil
	Local nCount		:= 0								// Contador temporário

	// Verifica se houve algum registro apagado, e gera a integração desse registro
	If nOpc != 3
		// Procura pelo registro do cabeçalho
		DA0->(DbGoTo( aIntDA0[1] ) )

		// Se não encontrar, significa que o cabeçalho foi apagado, então envia somente a exclusão do cabeçalho
		If DA0->( DELETED() )
			aIntDA0[2]:Finalizar()
		Else
			For nCount := 1 To Len( aoIntDA1 )
				DA1->( DbGoTo( aoIntDA1[nCount][1] ) )

				If DA1->( DELETED() )
					aoIntDA1[nCount][2]:Finalizar()
				EndIf
			Next
		EndIf
	EndIf

	// Independente de ter registros apagados ou não, gera quando não for exclusão, todos os outros registros
	If nOpc != 5
		aIntDA0 := { DA0->( Recno() ), oFactory:Create( "DA0" ) }
		cChave 	:= xFilial( "DA0" ) + DA0->DA0_CODTAB
		aIntDA0[2]:Inserir( "DA0", cChave, "1", cValToChar( nOpc ) )
		aIntDA0[2]:Gerar()
		aIntDA0[2]:Finalizar()

		aoIntDA1 := {}
		DbSelectArea( "DA1" )
		DbSetOrder( 1 )
		DbSeek( xFilial( "DA1" ) + DA0->DA0_CODTAB )
		While	xFilial( "DA1" )	== DA0->DA0_FILIAL	.And.;
		DA1->DA1_CODTAB		== DA0->DA0_CODTAB
			cChave := xFilial( "DA1" ) + DA1->DA1_CODTAB + DA1->DA1_ITEM
			oTempIntDA1 := oFactory:Create( "DA1" )
			oTempIntDA1:Inserir( "DA1", cChave, "3", cValToChar( nOpc ) )
			oTempIntDA1:Gerar()
			oTempIntDA1:Finalizar()
			aAdd( aoIntDA1, { DA1->( Recno() ), oTempIntDA1 } )
			DA1->( DbSkip() )
		End
	EndIf
Return
