#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GJF104    ³ Giuliano Forgiarini           ³ Data ³ 05.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Correlacionamento de produtos frigorifico - clientes        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaoms                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF104()

	Private aRotina  := {}
	aObjects := {}                                                                 
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	aX    :=aPosObj[1]                                                            
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 05

	aRotina := { { "Pesquisa"  , "AxPesqui"  , 0, 1},; 	//"Pesquisar"
	{ "Visualizar", "u_gjf104V" , 0, 2},; 	//"Visualizar"
	{ "Incluir"   , "u_gjf104I" , 0, 3},; 	//"Incluir"
	{ "Alterar"   , "u_gjf104A" , 0, 4},; 	//"Alterar" 
	{ "Excluir",    "u_gjf104E" , 0, 5},;    //"Excluir"    
	{ "Imprimir"  , "u_gjf104IM", 0, 4}}     //"Imprimir"


	Private cCadastro 	:= "Correlacionamento de Produtos Cliente-Frigorifico"

	DbSelectArea("ZA1")
	ZA1->(DbSetOrder(1))

	mBrowse(6,1,22,75,"ZA1", ,,,,2,,,,,) 

	dbclosearea('ZA1')  

Return


//Visualiza
User Function gjf104V(cAlias,nReg,nOpc)

	Local oDlg		:= NIL

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL   
	Private campo1 := space(06)
	Private campo2 := space(02)
	Private campo3 := space(80)
	Private _valor1 := space(06)
	Private _valor2 := space(03)
	Private _valor3 := space(80)

	area := GetArea()

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := gjf104Ahd("ZA1")                                                 //Monta o aHeader

	RegToMemory('ZA1')

	_valor1 := M->ZA1_CLIENT
	_valor2 := M->ZA1_LOJA

	if empty(_valor2)
		_chave := _valor1
	else
		_chave := _valor1+_valor2
	endif

	_valor3 := fBuscaCPO('SA1',1,xfilial('SA1')+_chave,'A1_NOME')

	gjf104Acls(nOpc)                                                            //Monta o Acols

	@ 002,002   SAY  "Cliente :" OF oDlg
	@ 002,007   MSGET campo1 VAR _valor1 SIZE 30,11   OF oDlg 
	@ 003,002   SAY  "Loja :" OF oDlg
	@ 003,007   MSGET campo2 VAR _valor2 SIZE 11,11   OF oDlg
	@ 004,002   SAY  "Nome :" OF oDlg
	@ 004,007   MSGET campo3 VAR _valor3 SIZE 160,11 OF oDlg

	campo1:disable()
	campo2:disable()
	campo3:disable()

	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","+ZA1_ITEM",.T.,,,,999,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()},)

	DbSelectArea('ZA1')

	RestArea(area)

Return

//Inclusão
User Function gjf104I(cAlias,nReg,nOpc)
	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}  
	Private campo1 := space(06)
	Private campo2 := space(02)
	Private campo3 := space(80)
	Private _valor1 := space(06)
	Private _valor2 := space(03)
	Private _valor3 := space(80)

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {} 


	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := gjf104Ahd("ZA1")

	gjf104Acls(nOpc)

	RegToMemory("ZA1",.T.)

	@ 002,002   SAY  "Cliente :" OF oDlg
	@ 002,007   MSGET campo1 VAR _valor1 SIZE 30,11  VALID RetCli() F3 'SA1' OF oDlg 
	@ 003,002   SAY  "Loja :" OF oDlg
	@ 003,007   MSGET campo2 VAR _valor2 SIZE 11,11  VALID RetCli() .and. MudaLj() OF oDlg
	@ 004,002   SAY  "Nome :" OF oDlg
	@ 004,007   MSGET campo3 VAR _valor3 SIZE 160,11 OF oDlg

	campo3:disable()                                                             

	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_gjf104LOk(n,'I')","u_gjf104TOk","ZA1_ITEM",.T., , ,.F.,,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_gjf104TOk().and.Obrigatorio(aGets,aTela).and.u_gjf104LOk(n,'I'), ;
	Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

	If  lOk  
		confirmsx8()
		gjf104Grv(nOpc)      
	else
		Rollbacksx8()
	Endif

Return

//Alteração
User Function gjf104A(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aCposAlt	:= {}
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {}  
	Private campo1 := space(06)
	Private campo2 := space(02)
	Private campo3 := space(80)
	Private _valor1 := space(06)
	Private _valor2 := space(03)
	Private _valor3 := space(80)

	DbSelectArea(cAlias)

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := gjf104Ahd("ZA1")                                                 //Monta o aHeader

	RegtoMemory('ZA1')

	_valor1 := M->ZA1_CLIENT
	_valor2 := M->ZA1_LOJA

	if empty(_valor2)
		_chave := _valor1
	else
		_chave := _valor1+_valor2
	endif

	_valor3 := fBuscaCPO('SA1',1,xfilial('SA1')+_chave,'A1_NOME')

	gjf104Acls(nOpc)                                                            //Monta o Acols

	@ 002,002   SAY  "Cliente :" OF oDlg
	@ 002,007   MSGET campo1 VAR _valor1 SIZE 30,11  VALID RetCli() F3 'SA1' OF oDlg 
	@ 003,002   SAY  "Loja :" OF oDlg
	@ 003,007   MSGET campo2 VAR _valor2 SIZE 11,11  VALID RetCli() .and. MudaLj() OF oDlg
	@ 004,002   SAY  "Nome :" OF oDlg
	@ 004,007   MSGET campo3 VAR _valor3 SIZE 160,11 OF oDlg

	campo1:disable()
	campo2:disable()
	campo3:disable()

	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],nOpc,"u_gjf104LOk(n,'A')","u_gjf104TOk","+ZA1_ITEM",.T., , ,.F. ,999, )


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_gjf104TOk().and.u_gjf104LOk(n,'A').and.;
	Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(), odlg:refresh())}, {||oDlg:End()}, , aButtons)

	If lOk  
		gjf104Grv(nOpc)
	Endif

Return

//Exclusão
User Function gjf104E(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	DbSelectArea(cAlias) 

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := gjf104Ahd("ZA1")                                                 //Monta o aHeader

	RegtoMemory('ZA1')

	_valor1 := M->ZA1_CLIENT
	_valor2 := M->ZA1_LOJA

	if empty(_valor2)
		_chave := _valor1
	else
		_chave := _valor1+_valor2
	endif

	_valor3 := fBuscaCPO('SA1',1,xfilial('SA1')+_chave,'A1_NOME')

	gjf104Acls(nOpc)                                                            //Monta o Acols

	@ 002,002   SAY  "Cliente :" OF oDlg
	@ 002,007   MSGET campo1 VAR _valor1 SIZE 30,11 OF oDlg 
	@ 003,002   SAY  "Loja :" OF oDlg
	@ 003,007   MSGET campo2 VAR _valor2 SIZE 11,11 OF oDlg
	@ 004,002   SAY  "Nome :" OF oDlg
	@ 004,007   MSGET campo3 VAR _valor3 SIZE 160,11 OF oDlg

	campo1:disable()
	campo2:disable()
	campo3:disable()

	oGet:= MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZZ5_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gjf104D(),oDlg:End()},{||oDlg:End()})

Return

//Montagem do aCols
static Function gjf104Acls(nOpc)
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

		nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZA1_ITEM" })
		if nPos > 0
			aCols[1,nPos]	:= StrZero(len(acols)+1,Len(aCols[1,nPos]))
		endif
		aCols[1,nUsado+1] := .F.
	Else
		if empty(ZA1->ZA1_LOJA)
			_lIndex := 1
			_chave  := xfilial('ZA1')+ZA1->ZA1_CLIENT
			_chave2 := "xfilial('ZA1')+ZA1->ZA1_CLIENT"
		else
			_lIndex := 2
			_chave  := xfilial('ZA1')+ZA1->(ZA1_CLIENT+ZA1_LOJA)  
			_chave2 := "xfilial('ZA1')+ZA1->(ZA1_CLIENT+ZA1_LOJA)"
		endif

		dbSelectArea("ZA1")
		dbSetOrder(_lIndex)
		dbSeek(_chave,.T.)

		Do While ZA1->(!Eof()) .and. _chave = &_chave2 
			if _lIndex = 1 .and. !empty(ZA1->ZA1_LOJA)
				ZA1->(DbSkip())
				loop
			endif
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

			ZA1->(DbSkip())	
		Enddo 

		DbGoTop()
		dbSetOrder(_lIndex)
		dbSeek(_chave,.T.)

	Endif

Return

//Monta oa aHeader
Static Function gjf104Ahd(cAlias)

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//DbSeek(cAlias)
	//Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	//	If 	at(Upper(AllTrim(X3_CAMPO)), "ZA1_FILIAL ZA1_CLIENT") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := cAlias			// ZA1
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 				 .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZA1_FILIAL" .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZA1_CLIENT")

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
Static Function gjf104Grv(nOpc)

	Local nIt
	Local nCont
	Local nNumItem
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                                       	// Indica se todas as gravacoes obtiveram sucesso

	if empty(_valor2)   
		_chave  := xfilial('ZA1')+alltrim(_valor1)+space(02)
	else
		_chave  := xfilial('ZA1')+alltrim(_valor1)+alltrim(_valor2) 
	endif


	Begin Transaction
		ZA1->(DbSetOrder(6))

		DbSelectArea("ZA1")
		nNumItem := 1  // Contador para os Itens
		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado  
				ZA1->(DbGotop()) 
				If DbSeek(_chave + StrZero(nIt,3))
					RecLock("ZA1",.F.)
					DbDelete()
					MsUnlock()
				Endif
			Endif     
		Next

		For nIt := 1 To Len(aCols)	
			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

				If ALTERA 
					ZA1->(DbGotop())
					If ZA1->(DbSeek(_chave + StrZero(nIt,3)))
						RecLock("ZA1",.F.)
					Else 
						RecLock("ZA1",.T.)
					Endif
				Else  
					RecLock("ZA1",.T.)
				Endif 

				if !empty(GDFieldGet('ZA1_COD',nIt)) .and. !empty(GDFieldGet('ZA1_CODCLI',nIt))  

					For nCpo := 1 To Len(aHeader)
						If aHeader[nCpo, 10] <> "V"
							ZA1->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
						EndIf
					Next nCpo

					ZA1->ZA1_FILIAL	 := xFilial("ZA1")                              
					ZA1->ZA1_ITEM    := strzero(nNumItem,3)  
					ZA1->ZA1_CLIENT  := _valor1
					ZA1->ZA1_NOME    := alltrim(_valor3)

					nNumItem++

				endif
				MsUnlock()
			Endif
		Next nIt

	End Transaction

Return lGraOk

//Exclusão 
Static Function gjf104D()

	if empty(_valor2)
		_chave  := xfilial('ZA1')+alltrim(_valor1)
		_chave2 := "xfilial('ZA1')+ZA1->ZA1_CLIENT"
		_lIndex := 1 
	else
		_chave := xfilial('ZA1')+alltrim(_valor1)+alltrim(_valor2)  
		_chave2 := "xfilial('ZA1')+ZA1->(ZA1_CLIENT+ZA1_LOJA)"
		_lIndex := 2
	endif

	ZA1->(DbGoTop())
	ZA1->(DbSetOrder(_lIndex))
	if ZA1->(DbSeek(_chave)) 

		while ZA1->(!Eof()) .and. alltrim(_chave) = alltrim(&_chave2)  
			if _lIndex = 1 .and. !empty(_valor2)
				ZA1->(DbSkip())
				loop
			endif
			reclock('ZA1',.f.)
			dbdelete()
			msunlock() 

			ZA1->(DbSkip())
		enddo
	endif
Return

//Testa todo aCols
User Function gjf104TOk()

	Local lRetorno	:= .T.

Return lRetorno

//Teste de validação da linha do grid
User Function gjf104LOk(n,op)       

	Local lRetorno 	:= .F.
	Local nPosDel 	:= Len(aHeader) + 1
	Local nCpo
	Local i

	if empty(_valor1)
		msgbox('Cliente não apontado!','OPERAÇÃO INVÁLIDA!','STOP')
		return .f.
	endif  


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
		if !empty(_valor2)
			GDFieldPut("ZA1_LOJA", _valor2)
		endif
		if !aCols[n, nPosDel] .and. INCLUI
			for i := 1 to len(aCols)
				area := getarea()  
				_cCodLj   := alltrim(GDFieldGet('ZA1_LOJA',i))
				_cCodPro  := alltrim(GDFieldGet('ZA1_COD',i)) 
				_cCodCli  := alltrim(GDFieldGet('ZA1_CODCLI',i)) 

				if empty(_Valor2)
					_chave  := xfilial('ZA1')+_valor1+_cCodPro
					_chave2 := xfilial('ZA1')+_valor1+_cCodCli
					_nInd  := 1 
					_nInd2 := 3
				else
					_chave  := xfilial('ZA1')+_valor1+_cCodLj+_cCodPro 
					_chave2 := xfilial('ZA1')+_valor1+_cCodLj+_cCodCli  
					_nInd  := 2     
					_nInd2 := 4      
				endif  
				ZA1->(DbGoTop())
				ZA1->(DbSetOrder(_nInd))
				if ZA1->(DbSeek(_chave)) .and. !aCols[i, nPosDel] 
					msgbox('Registro já existente!','OPERAÇÃO INVALIDA! (1)','STOP') 
					restarea(area)
					return .f.
				else 
					ZA1->(DbGoTop())
					ZA1->(DbSetOrder(_nInd2))
					if ZA1->(DbSeek(_chave2)) .and. !aCols[i, nPosDel] 
						msgbox('Registro já existente!','OPERAÇÃO INVALIDA! (2)','STOP') 
						restarea(area)
						return .f.
					endif
				endif

				restarea(area)
			next             
		endif
		_cCodLj   := alltrim(GDFieldGet('ZA1_LOJA'))
		_cCodPro  := alltrim(GDFieldGet('ZA1_COD')) 
		_cCodCli  := alltrim(GDFieldGet('ZA1_CODCLI')) 

		if  !aCols[n, nPosDel]   
			for i := 1 to len(aCols)
				if (_cCodPro = alltrim(GDFieldGet('ZA1_COD',i)) .or.; 
				_cCodCli = alltrim(GDFieldGet('ZA1_CODCLI',i))) .and.; 
				_cCodLj  = alltrim(GDFieldGet('ZA1_LOJA',i)) .and. ;
				n <> i .and. !aCols[i, nPosDel]
					msgbox('Registro repetido!','OPERAÇÃO INVALIDA! (3)','STOP') 
					return .f.  
				endif
			next    
		endif
	endif

Return .t.

Static Function RetCli()    
	if !empty(_valor2)
		_valor3 := fBuscaCPO('SA1',1,xfilial('SA1')+_valor1+_valor2,'A1_NOME')
	else
		_valor3 := fBuscaCPO('SA1',1,xfilial('SA1')+_valor1,'A1_NOME')
	endif
Return .t.

Static Function MudaLj()
	Local i
	For i := 1 to len(aCols)
		if !empty(_valor2)
			GDFieldPut("ZA1_LOJA", _valor2,i)
		endif
	next
	oGet:refresh()
Return .t.    

User Function gjf104IM()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de codigos correlacionados para o processo de EDI  "
	Local cDesc3         := "entre os clientes da empresa                       "
	Local cPict          := ""
	Local titulo         := "CORRELACIONAMENTO DE CODIGOS DE PRODUTOS"
	Local nLin         	:= 80

	Local Cabec1       	:= "Dados do Cliente                                    Codigos dos Produtos        "
	Local Cabec2       	:= "    Descrição do Produto                      Cod.Frig.   EAN-13     Cod.Cliente"

	Local imprime      	:= .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private Tamanho      := "P"
	Private nomeprog     := "GJF104IM" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	   := "GJF104"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF104" // Coloque aqui o nome do arquivo usado para impressao em disco

	DbSelectArea('ZA1')

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZA1',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZA1')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if empty(mv_par02)  
		_chave  := xfilial('ZA1')+ZA1->ZA1_CLIENT
		_chave2 := xfilial('ZA1')+mv_par01
		ZA1->(DbSetOrder(9))
		ZA1->(DbSeek(_chave2))
	else   
		_chave  := xfilial('ZA1')+ZA1->(ZA1_CLIENT+ZA1_LOJA)  
		_chave2 := xfilial('ZA1')+ mv_par01 + mv_par02
		ZA1->(DbSetOrder(10))
		ZA1->(DbSeek(_chave2))
	endif

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	@nlin,01 psay iif(empty(mv_par02),ZA1->ZA1_CLIENT + '   ' + ZA1_NOME,ZA1->ZA1_CLIENT + '/' + ZA1->ZA1_LOJA + '   ' + ZA1_NOME)

	nlin++   
	@nlin,00 psay replicate('-',80)
	nlin += 2

	_count := 1

	Do While ZA1->(!Eof()) .and. _chave = _chave2 


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif		
		@nlin,00 psay alltrim(strzero(_count,3))
		@nlin,04 psay alltrim(substr(ZA1->ZA1_DESC,1,39))
		@nlin,46 psay alltrim(ZA1->ZA1_COD)
		@nlin,53 psay alltrim(ZA1->ZA1_CODBAR)
		@nlin,67 psay alltrim(ZA1->ZA1_CODCLI)
		nlin++	
		_count++
		ZA1->(dbskip())

	enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return
