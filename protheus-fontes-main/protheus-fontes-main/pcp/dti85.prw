#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "totvs.ch"
#INCLUDE "fileio.ch"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DTI85    ³ Flávio Bohrer Flôres          ³ Data ³ 26.06.19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Solicitação de Produção                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PCP                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI85()

	Private cCadastro := "Rotina de Solicitação de Produção"
	Private aCores      := {}
	Private cPerg     := "MDTI85"
	Private cCondicao   := ''
	Private _lSldFlag   := .f. 

	if !pergunte(cPerg,.t.)
		return
	endif

	cCondicao := "ZZU_DATA >= '" + dtos(mv_par01) + "' AND ZZU_DATA <= '" + dtos(mv_par02) + "' AND ZZU_FILIAL = '" + FWxfilial('ZZU') + "'"

	If mv_par03 = 1  // Só ussuário corrente
		cCondicao += " AND ZZU_USERIN = '" + cUserName + "'"
	else // Senão de todos usuários
	Endif

	aObjects            := {}
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           := aPosObj[1]
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	/*  Primeira Tela 
	Legenda    */
	bLegenda1 := "ZZU->ZZU_STATUS $ 'B'"          // Alterado
	bLegenda2 := "ZZU->ZZU_STATUS == 'L'"          // lancada
	bLegenda3 := "ZZU->ZZU_STATUS == 'S'"          // Reaberta
	bLegenda4 := "ZZU->ZZU_STATUS == 'F'"          // fechada

	aCores := { {bLegenda1, 'BR_AZUL'    		},;       // Alterada
				{bLegenda2, 'BR_VERDE'   		},;       // Lançada pelo Comercial
				{bLegenda3, 'BR_LARANJA' 		},;       // Reaberta
				{bLegenda4, 'BR_PRETO'  		}}        // Fechada

	aCores2:= { { 'BR_AZUL' ,'Solicitação Alterada'   },;       
	{ 'BR_VERDE'    		,'Solicitação Lançada'    	},;    
	{ 'BR_PRETO'  			,'Solicitação Fechada'  	},;    
	{ 'BR_LARANJA'   		,'Solicitação Reaberta'   	}}  

	aRotina := {{ "Pesquisa"   ,"AxPesqui"    , 	0, 1},; 	     //"Pesquisar"
	{ "Visualizar" 		,"u_d85Visu" , 	0, 2},;	 //"Visualizar"
	{ "Incluir"    		,"u_d85Inc" , 	0, 3},;	 //"Incluir"
	{ "Alterar"    		,"u_d85Alte" , 	0, 4},;	 //"Alterar"
	{ "Excluir"    		,"u_d85Excl" , 	0, 5},;  //"Excluir"	
	{ "FecharProdPCP"  	,"u_d85FProd" , 0, 2},;  //"Fechamento de Solicitação"
	{ "ControlePCP"    	,"u_d85Con" , 	0, 2},;  //"Controle de Produção"
	{ "Liberações"    	,"u_d85Lib" , 	0, 4},;  //"Liberações de pesos Traseiro/ Dianteiro"
	{ "Relatório"    	,"u_d85Rel" , 	0, 2},;  //"Relatório de Solicitação de Produção PCP"
	{ "Legenda"    		,"U_d85Leg"  , 	0, 1}}   //"Legenda"

	/* 	{ "VerItens"    	,"u_d85Item" , 	0, 2},;  //"Verificar Itens da Solicitação"	*/
	DbSelectArea("ZZU")
	ZZU->(DbSetOrder(2))

	mBrowse(6,1,22,75,"ZZU", ,,,,2,aCores,,,,,,,,cCondicao)	

Return

//Disponibiliza a legenda
User Function d85Leg(cAlias,nReg,nOpc)
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return

//Disponibiliza a legenda
User Function d85Inc(cAlias,nReg,nOpc)
	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}
	//Local _nPlib	:= ""
	Private aHeader	:= {}
	Private aCols	:= {}
	Private aGets	:= {}
	Private aTela	:= {}
	Private nUsado	:=	0

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := d85Ahead("ZZV")
	d85Acols(nOpc)

	RegToMemory("ZZU",.T.)

	oEnc := MsMGet():New("ZZU" ,ZZU->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_d85LinOk(n,'I')","u_d85TudOk","+ZZV_ITEM",.T., , ,.F. , 20,)

	u_d85vk()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_d85TudOk().and.Obrigatorio(aGets,aTela).and.u_d85LinOk(n,'I'), ;
	Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

	/* Testar se prodúção já não esta encerrada*/
	if U_TFechProd(M->ZZU_DATA)
		// Não tem data Encerrada
	else
		msgbox('Status não permite Inclusão !! Pois Produção já encerrada','OPERAÇÃO NEGADA!','STOP')
		lOk := .F.
	endif

	If  lOk
		confirmsx8()
		d85Grav(nOpc)
	else
		Rollbacksx8()
	Endif

Return

//Grava cabecalho e itens
Static Function d85Grav(nOpc)

	Local nIt
	Local nCont
	Local nNumItem
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                        

/*  nOpc = 3 Inclusão
    nOpc = 4 Alteração
    */

	Begin Transaction

		DbSelectArea("ZZU")
		DbSetOrder(1)
		If INCLUI
			RecLock("ZZU",.T.)
		Else
			RecLock("ZZU",.F.)
		Endif

		For nCont := 1 To FCount()

			If "FILIAL"$Field(nCont)
				FieldPut(nCont,FWxFilial("ZZU"))
			Else
				FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
			Endif

		Next nCont

		MsUnLock()

		DbSelectArea("ZZV")
		DbSetOrder(1)

		nNumItem := 1  // Contador para os Itens

		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				If MsSeek(FWxFilial("ZZV") + M->ZZU_NUM + StrZero(nIt,3))
					RecLock("ZZV",.F.)
					DbDelete()
					MsUnlock()
				Endif
			Endif
		Next

		_lTpP := .f.
		_lTpD := .f.

		For nIt := 1 To Len(aCols)

			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

				If ALTERA
					If MsSeek(FWxFilial("ZZV")+ M->ZZU_NUM + StrZero(nIt,3))
						RecLock("ZZV",.F.)
					Else
						RecLock("ZZV",.T.)
					Endif
				Else
					RecLock("ZZV",.T.)
				Endif

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"
						ZZV->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				ZZV->ZZV_FILIAL	 := FWxFilial("ZZV")
				ZZV->ZZV_NUM	 := ZZU->ZZU_NUM
				ZZV->ZZV_ITEM    := strzero(nNumItem,3)

				if ALTERA
					ZZV->ZZV_USERAL := cUserName
					ZZV->ZZV_DATAAL := DATE()
					ZZV->ZZV_HORAAL := TIME()
					ZZV->ZZV_CIDADE := ZZU->ZZU_CIDADE
				else
					ZZV->ZZV_CIDADE := ZZU->ZZU_CIDADE
				endif
				nNumItem++

				MsUnlock()

				DbSelectArea('ZZV')
			Endif
		Next nIt

		If ALTERA
			RecLock("ZZU",.F.)
				ZZU->ZZU_STATUS  := 'B'  // Caso peçam para bloquear quando alterar futuramente
			MsUnlock()
		Else
			RecLock("ZZU",.F.)
				ZZU->ZZU_STATUS  := 'L'
				ZZU->ZZU_GERAU  := '2'
				ZZU->ZZU_USERIN  := cUserName
				ZZU->ZZU_DATAIN := DATE()
				ZZU->ZZU_HORAIN := TIME()
			MsUnlock()
		Endif
	End Transaction

Return lGraOk


User Function d85TudOk()

	Local lRetorno	:= .T.
	/* Acrescentar futuras Regras */

	/*  Controle de liberação Lançamento de Solicitação de Produção   */
	_nPlib 	:= GetMV('SI_LIBPROD')

	If alltrim(M->ZZU_TIPPRO) = 'P' .AND. alltrim(_nPlib) = 'C'
		msgbox('Status não permite Inclusão !! Peça Bloqueada para Lançamento!  Entrar em contato com PCP','OPERAÇÃO NEGADA!','STOP')
		//lOk := .F.
		lRetorno	:= .F.

	Elseif alltrim(M->ZZU_TIPPRO) = 'C' .AND. alltrim(_nPlib) = 'P'
		msgbox('Status não permite Inclusão !! Caixa Bloqueada para Lançamento! Entrar em contato com PCP','OPERAÇÃO NEGADA!','STOP')
		//lOk := .F.
		lRetorno	:= .F.
	Endif

Return lRetorno


User Function d85LinOk(n,op)

	Local lRetorno 	:= .T.
	Local nPosDel 	:= Len(aHeader) + 1
	Local nCpo
	Local _cVer :=''
	Local _cExc	:= GetMV('SI_LIBCOD')
	Local i

	/*   Verifica se o item foi deletado */
	If !aCols[n, nPosDel]       
		For nCpo := 2 To Len(aHeader)                                      
			If !Empty(aCols[n, nCpo]) .and. ValType(aCols[n, nCpo]) <> "D"
				lRetorno := .T.
			Endif
		Next nCpo
	Else
		lRetorno := .T.
	Endif

	_cProd := GDFieldGet('ZZV_COD',n)
	_cVer := GetAdvFVal("SB1","B1_SEGUM",FWxFilial("SB1") + alltrim(_cProd),1)

	if  alltrim(_cProd) $ _cExc
		_cVer := 'CX'
	endif

	dbselectarea('SB1')
	dbsetorder(1)
	if !MsSeek(FWxfilial('SB1')+_cProd) 
		return .F.
	endif

	for i:=1 to len(aCols)
		if _cProd = aCols[i][1]  .and.  i <> n
			alert('Produto repetido !!')
			lRetorno := .F.
			exit
		elseif 	M->ZZU_TIPPRO = 'P' .AND. !(_cVer $ 'PC')
			alert('Este produto não pode ser lançado !! Unidade de medida CX')
			lRetorno := .F.
			exit
		elseif 	M->ZZU_TIPPRO = 'C' .AND. !(_cVer $ 'CX') 
			alert('Este produto não pode ser lançado !! Unidade de medida PC')
			lRetorno := .F.
			exit
		endif
	next

	/* Acrescentar futuras Regras */

Return lRetorno

//Monta oa aHeader
Static Function d85Ahead(cAlias)

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//MsSeek(cAlias)
	//Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	//	If 	at(Upper(AllTrim(X3_CAMPO)), "ZZV_FILIAL ZZV_NUM") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := cAlias 			// ZZV
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 			 	 .And. ;
			AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZZV_FILIAL" .And. ;
			AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZZV_NUM")

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

//Montagem do aCols
static Function d85Acols(nOpc)
	Local nI, nPos
	If nOpc == 3

		//aCols := Array(1,nUsado+1)
		aCols := Array(1,nUsado+1)
		/* verificar inclusão de informações */
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

		nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZZV_ITEM" })
		if nPos > 0
			aCols[1,nPos]	:= StrZero(len(acols)+1,Len(aCols[1,nPos]))
		endif
		//aCols[1,nUsado+1] := .F.
		aCols[1,nUsado+1] := .F.
	Else

		RegToMemory("ZZU")

		dbSelectArea("ZZV")
		dbSetOrder(1)
		MsSeek(FWxFilial('ZZV')+ZZU->ZZU_NUM,.T.)

		Do While ZZV->(!Eof()) .and. FWxFilial('ZZV') ==  ZZV->ZZV_FILIAL .and. ZZV->ZZV_NUM == ZZU->ZZU_NUM
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

			ZZV->(DbSkip())
		Enddo

	Endif

Return

User Function d85Alte(cAlias,nReg,nOpc)

	Local oDlg		    := NIL
	Local lOk 		    := .F.
	//Local aCposAlt	    := {}
	Local aButtons	    := {}
	//Local _cCodigo      := ''
	Private aHeader	    := {}
	Private aCols	    := {}
	Private nUsado	    :=	0
	Private oGet	    := NIL
	Private aGets	    := {}
	Private aTela	    := {}

	DbSelectArea(cAlias)

	area := GetArea()

	//VERIFICAR POSSIBILIDADE DE ALTERAÇÃO DA SOLICITAÇÃO DE PRODUÇÂO

	if ZZU->ZZU_STATUS == 'F' 
		msgbox('Status não permite Alteração da Solicitação de Produção!','OPERAÇÃO NEGADA!','STOP')
		return
	Elseif  ZZU->ZZU_GERAU = '1' 
		msgbox('Solicitação de Produção gerada de forma Automática! Favor excluir e encerrar a produção novamente!!','OPERAÇÃO NEGADA!','STOP')
		return
	Elseif alltrim(cUserName) = alltrim(ZZU->ZZU_USERIN)  .OR. AllTrim(UPPER(cUserName)) = UPPER("valeska.anhanha") .OR. AllTrim(UPPER(cUserName)) = UPPER("andre.pcp") 
		// Deixa gravar normal
	else		
		msgbox('Usuário :'+cUserName+' não permitido para alterar esta solicitação!','OPERAÇÃO NEGADA!','STOP')
		return .f.
	endif	

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := d85Ahead("ZZV")   //Monta o aHeader

	d85Acols(nOpc)              //Monta o Acols

	RegtoMemory('ZZU')

	//M->ZZU_STATUS := 'B'                  //Já bloqueia novamente o PP

	oEnc := MsMGet():New("ZZU" ,ZZU->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_d85LinOk(n,'A')","u_d85TudOk","+ZZV_ITEM",.T., , ,.F. ,20 ,,,,"u_d85Val")

	u_d85vk()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_d85TudOk().and.u_d85LinOk(n,'A').and.;
	Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(), oDlg:refresh())}, {||oDlg:End()}, , aButtons)

	If lOk
		d85Grav(nOpc)
	Endif

	RestArea(area)

Return

//Visualiza A SOLICITAÇÃO DE PRODUÇÂO
User Function d85Visu(cAlias,nReg,nOpc)

	Local oDlg		:= NIL

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	area := GetArea()

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZU")

	d85Ahead("ZZV")

	nUsado := Len(aHeader)

	d85Acols(nOpc)

	oEnc    := MsMGet():New("ZZU" ,ZZU->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZZ5_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, , )

	RestArea(area)

Return

User Function d85Excl(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	/* Verificação para não liberar solicitações criadas pelos usuários  
	Campo "Geração Aut.Solic."
	ZZU_GERAU = 1 -  Para quando sistema gerar solicitação através do encerramento da Produção
	ZZU_GERAU = 2 -  Para quando o usuário incluir a solicitação
	*/
	if ZZU->ZZU_STATUS == 'F' .AND. ZZU->ZZU_GERAU = '2'
		msgbox('Status não permite exclusão da Solicitação de Compra!','OPERAÇÃO NEGADA!','STOP')
		return .f.
	endif

	if  alltrim(cUserName) = alltrim(ZZU->ZZU_USERIN) .AND. !(ZZU->ZZU_STATUS == 'F' )
		// Deixa Excluir normal
	elseif ZZU->ZZU_GERAU = '1'  .AND. (  AllTrim(UPPER(cUserName)) = UPPER("valeska.anhanha")  .OR. AllTrim(UPPER(cUserName)) = UPPER("andre.pcp") .OR. AllTrim(UPPER(cUserName)) = UPPER("flavio") )
		// Deixa Excluir normal  -  Só os 2 usu´arios do  PCP
	else
		msgbox('Usuário :'+cUserName+' não permitido para Exclusão esta solicitação!','OPERAÇÃO NEGADA!','STOP')
		return .f.
	endif

	DbSelectArea(cAlias)

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("ZZU")

	EnChoice( "ZZU" ,ZZU->(RECNO()), nOpc, , , , , aPosObj[1], , 3 )
	d85Ahead("ZZV")

	nUsado	:= Len(aHeader)

	d85Acols(nOpc)

	oGet:= MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZZV_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||d85Dele(alltrim(ZZU->ZZU_GERAU)),oDlg:End()},{||oDlg:End()}, , aButtons)

Return

Static Function d85Dele(_cTP)
	Local _dDatap := ZZU->ZZU_DATA
	// _cTP - Tipo de Solicitação gerada se 1= Automatica  se 2 = Padrão inclusao manual

	DbSelectArea("ZZV")
	ZZV->(DbSetOrder(1))
	MsSeek(FWxFilial("ZZV") + ZZU->ZZU_NUM,.t.)

	Do While ZZV->(!Eof()) .and. FWxFilial("ZZV") == ZZV->ZZV_FILIAL .AND. ZZU->ZZU_NUM == ZZV->ZZV_NUM  // Exclui os itens do PP
		RecLock("ZZV",.f.)
		DbDelete()
		MsUnLock()
		ZZV->(DbSkip())
	Enddo

	DbSelectArea("ZZU")

	RecLock("ZZU",.f.)
	DbDelete()
	MsUnLock()

	/* Reabrir solicitações de Produção   ZZU->ZZU_FECH := '2' */

	if ZZU->ZZU_GERAU = '1'
		// Se for soliicitação criada Automaticamente então reabrir todas solicitações vinculadas 
		DbSelectArea("ZZU")
		ZZU->(DbSetOrder(2))

		MsSeek(FWxFilial("ZZU") + DTOS(_dDatap),.t.)
		Do While ZZU->(!Eof()) .AND. FWxFilial("ZZU") == ZZU->ZZU_FILIAL  .AND. ZZU->ZZU_DATA = _dDatap
			RecLock("ZZU",.f.)
				ZZU->ZZU_FECH := '2'
				ZZU->ZZU_STATUS := 'S'
			MsUnLock()
			ZZU->(DbSkip())
		Enddo
	Endif
Return


User Function  d85Item()

	area := getarea()

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	cQuery := "SELECT ZZV_COD AS COD,ZZV_DESC AS DESCRI, SUM(ZZV_QCAIX) AS PCAIX,  "+;
	" SUM(ZZV_QPESO) AS PPESO                                      "+;
	" FROM ZZV010                                                                             "+;
	" WHERE ZZV010.D_E_L_E_T_ <> '*' AND ZZV_NUM = '" + ZZU->ZZU_NUM + "'                     "+;
	" AND ZZV_FILIAL = '" + FWxfilial('ZZV') + "'" +;
	" GROUP BY ZZV_COD, ZZV_DESC"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	aCampos := {}

	aadd(aCampos,{"COD"    ,"Codigo ",""                  })
	aadd(aCampos,{"DESCRI" ,"Descricao   ",""             })
	aadd(aCampos,{"PCAIX"  ,"Prev. Caixas","@E 9,999"     })
	aadd(aCampos,{"PPESO"  ,"Prev. Peso"  ,"@E 999,999.99"})

	_nTotCaix  := 0
	_nTotPeca  := 0
	_nTotPCaix := 0
	_nTotPPeca := 0

	cQuery := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	dbSelectarea('QRY')

	aStru := dbStruct()                                                           //Pega a estrutura do QRY e atribui a um vetor

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	_aArqTrb :={}
	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	QRY->(dbgotop())

	SBM->(dbsetorder(1))

	while QRY->(!eof())
		DbSelectArea('TMP')
		reclock('TMP',.t.)
		TMP->COD    := QRY->COD
		TMP->DESCRI := QRY->DESCRI
		TMP->PCAIX  := QRY->PCAIX	
		TMP->PPESO  := QRY->PPESO
		msunlock()
		QRY->(dbskip())
	enddo

	TMP->(dbgotop())

	DEFINE MSDIALOG oEnc TITLE 'Consulta por Itens da Solicitação de Produção ' from 00,00 to 240,835 OF oMainWnd PIXEL

	@ 005,005 To 90,420 Browse "TMP"  fields aCampos object oiBrowse
	@ 103,350  BUTTON 'Sair'        SIZE 40,15 ACTION oEnc:end() OBJECT oBtn
	
	ACTIVATE MSDIALOG oEnc

	If Select("TMP")<>0
		TMP->(dbCloseArea())
	Endif

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	restarea(area)

Return


User Function d85pmc()
	pmedio := 0
	prod 	:= GDFieldGet('ZZV_COD',n)
	SB1->(dbsetorder(1))
	if SB1->(MsSeek(FWxfilial('SB1')+prod))
		pmc    := SB1->B1_PMCAIX
		pmedio := (M->ZZV_QCAIX * pmc)
	endif	
return pmedio


User Function d85cmp
	caixas := 0
	prod   := GDFieldGet('ZZV_COD',n)
	peso   := M->ZZV_QPESO

	SB1->(dbsetorder(1))

	if SB1->(MsSeek(FWxfilial('SB1')+prod))
		cmp   := SB1->B1_PMCAIX
		ncaix := round(peso/cmp,0)
		return ncaix
	endif

return caixas


Static Function LiberaC()

	oTxtCx  := 'Liberada Produção de Caixaria!'
	PUTMV('SI_LIBPROD','C')

	//Refresh para mostrar Bloqueio do Traseiro
	oSayTxtCX:CtrlRefresh() 
	oAut:refresh()
	//oTxtRetP  := ''
	oTxtPC	 := ''
	oTxtT	:= ''

Return


Static Function LiberaP()

	oTxtPC  := 'Liberada Produção de Peças!'
	PUTMV('SI_LIBPROD','P')

	//Refresh para mostrar Bloqueio do Traseiro
	oSayTxtPC:CtrlRefresh() 
	oAut:refresh()
	//oTxtRetP  := ''
	oTxtCx	 := ''
	oTxtT	:= ''

Return


Static Function Limpamsg()
	oTxtCx		:= ''
	oTxtPC		:= ''
	oTxtT		:= ''
Return


Static Function LiberaT()

	oTxtT  := 'Liberada Toda Produção!'
	PUTMV('SI_LIBPROD','')

	//Refresh para mostrar Bloqueio do Traseiro
	oSayTxtT:CtrlRefresh() 
	oAut:refresh()
	//oTxtRetP  := ''
	oTxtCx	 := ''
	oTxtPC	 := ''

Return


Static Function LibPA()

	oTxtT  := 'Ativa Produção Automática!'
	PUTMV('SI_LIBR88','1')

	oSayTxtT:CtrlRefresh() 
	oAut:refresh()

	oTxtCx	 := ''
	oTxtPC	 := ''

Return


Static Function BlPA()

	oTxtT  := 'Bloqueado a Produção Automática!'
	PUTMV('SI_LIBR88','2')

	oSayTxtT:CtrlRefresh() 
	oAut:refresh()

	oTxtCx	 := ''
	oTxtPC	 := ''

Return


Static Function Vis()

	oTxtCx := ''

	_nProd 	:= GetMV('SI_LIBPROD')

	/*Visualização da Rotina da Embalagem*/
	If empty(alltrim(_nProd))
		oTxtCx  := 'Produção Toda liberada pelo PCP!'	
	elseif alltrim(_nProd) = 'C'
		oTxtCx  := 'Produção de Caixas Liberadas pelo PCP!'
	elseif alltrim(_nProd) = 'P'
		oTxtCx  := 'Produção de Peças Liberadas pelo PCP!'
	endif

	// Refresh para mostrar o Status da Embalagem
	oSayTxtCx:CtrlRefresh() 

	oAut:refresh()
	//oTxtCx	 := ''
	oTxtPC	 := ''
	oTxtT	 := ''

Return


User Function d85Con()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis  By DTI                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	private oFont     := tFont():New("courier new",,-28,,.t.,,,,)
	private oFont2    := tFont():New("courier new",,-24,,.t.,,,,)     
	private oFont3    := tFont():New("courier new",,-12,,.t.,,,,)     

	Private oTxtTitulo 	:= ' Liberação Caixa/Peça'
	Private oTxtCx		:= ''
	Private oTxtPC		:= ''
	Private  oTxtT		:= ''
	Private _lVr	:= .F.

	_lVr := VldUsr(cUserName)

	If !(_lVr)
		msgbox('Usuário :'+cUserName+' não permitido Acesso a esta Operação!','OPERAÇÃO NEGADA!','STOP')
		return .f.
	Endif

	DEFINE MSDIALOG oAut TITLE 'Controle da Produção de Caixas / Peças' from 000,000 To 350,650  PIXEL

	/* Objetos da Liberação Caixas/Peças*/
	oSayTxtCX  := tSay():New(095,020,{|| oTxtCX	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	oSayTxtPC  := tSay():New(095,020,{|| oTxtPC	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	oSayTxtT   := tSay():New(095,020,{|| oTxtT	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	oGrupoL1   := tGroup():New(05, 10, 80, 320,'Liberação da Produção', oAut,,, .t.)
	oGrupoL2   := tGroup():New(85, 10, 170, 320,'MSG', oAut,,, .t.)	
	oSayTxtTit := tSay():New(015,035,{|| oTxtTitulo	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,60)

	/* Colocar botão */
	_oBtn01 := TButton():New(037, 046, "Liberar Prod. Caixaria", oAut,{|| LiberaC() },60,012,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn03 := TButton():New(054, 046, "Liberar Prod. Peças"    , oAut,{|| LiberaP() },60,012,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn05 := TButton():New(040, 130, "LIMPA MSG"   , oAut,{|| Limpamsg() },40,015,,oFont3,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn02 := TButton():New(037, 190, "Liberar Caixa/Peça"   , oAut,{|| LiberaT() },60,012,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn06 := TButton():New(056, 190, "Vis.Status"   , oAut,{|| Vis() },55,020,,oFont3,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn01:SetColor(CLR_WHITE,CLR_GREEN)

	ACTIVATE MSDIALOG oAut CENTERED

Return


Static Function VldUsr(cUSR)

	lRet := .T.
	_cUR 	:= GetMV('SI_USRPCP')

	if cUSR $ _cUR

	Else
		lRet := .F.
	endif

Return lRet


User Function d85FProd()

	local nOpca	:=0
	local aSays:={}, aButtons:={}
	//local lValid := .F.
	Private cCadastro := "Processo de Fechamento das Solicitações de Produções"
	Private cPerg     := "DTI85"
	Private _nNumProd := 0
	Private _lVr	:= .F.	

	_lVr := VldUsr(cUserName)

	If !(_lVr)
		msgbox('Usuário :'+cUserName+' não permitido Acesso a esta Operação!','OPERAÇÃO NEGADA!','STOP')
		return .f.
	Endif

	/* - -Processo de Fechamento das Solicitações de Produção - By - MLR02  */

	Pergunte(cPerg,.f.)

	AADD (aSays, "  Esta rotina tem como objetivo realizar o fechamento das ")  //
	AADD (aSays, "  Solicitações de Produção")  //

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )

	If nopca == 1
		//Processa({||u_d85Pr(mv_par01,mv_par02)},"PROCESSO DE FECHAMENTO ","Realizando Fechamento...")
		Processa({||u_d85Pr(mv_par01,1)},"PROCESSO DE FECHAMENTO ","Realizando Fechamento...")
	endif

Return


User Function d85Pr(_dData,_cTipo)

	//Local	_nSoma  := 0
	//Local 	_nCount := 0
	//Local 	_cRet 	:= 0 

	_nNumProd := 0

	/* Testar se prodúção já não esta encerrada*/

	if U_TFechProd(_dData)
		// Data de Produção não Encerrada ainda ...
	else
		msgbox('Status não permite Encerramento !! Pois Produção já encerrada','OPERAÇÃO NEGADA!','STOP')
		return .f.
	endif

	if empty(_dData)
		alert('Data do Encerramento deve ser Preenchida!')
		return .f.
	endif

	/* tipo 1 = Ambos ( Caixaria e Pendurados)*/
	If _cTipo = 1
		/* Encerra as Produções envonvidas e alimenta o vetor TMP*/		
		EncProd(_dData,_cTipo)
		/* Grava as informações da nova solicitação gerada Automática*/
		GrvEnc(_dData)		
	Elseif _cTipo = 2
		/* Processo de fechamento da caixaria para o Futuro caso peçam*/
		alert('Tipo de Processo Caixaria !!!')
		return .f.
	Elseif _cTipo = 3
		/* Processo de fechamento da Pendurados para o Futuro caso peçam*/
		alert('Tipo de Processo Pendurados !!!')
		return .f.
	Else
		alert('Tipo de Processo não definido Favor verificar o Lançamento com Setor Comercial !!!')
		return .f.
	Endif

Return

Static Function EncProd(_dDt,_nTi)

	//Local Retorno := 0
	//Local _cProces := 0
	/* Descrição de Informações
	_dDt - Data do Lançamento da Solicitação
	_nTi - Tipo de Solicitação   EX. 1 - Ambas  2 - Caixaria  3 - Pendurados
	*/

	_cChave  :=  FWxfilial('ZZU') + DTOS(_dDt)
	DbSelectArea('ZZU')
	DbSelectArea('ZZV')
	ZZU->(DbGoTop())
	ZZU->(DbSetOrder(2))

	GeraTMP()
	if ZZU->(MsSeek(_cChave)) 
		while ZZU->(!eof()) .AND. (ZZU->ZZU_DATA = _dDt)  
			If ZZU->ZZU_STATUS $ 'BF'
				// fazer
			Endif

			ZZV->(DbGoTop())
			ZZV->(DbSetOrder(1))
			if ZZV->(MsSeek(FWxfilial('ZZV')+alltrim(ZZU->ZZU_NUM)))
				while ZZV->(!eof())  .AND. _nTi = 1 .AND. alltrim(ZZV->ZZV_NUM) = alltrim(ZZU->ZZU_NUM)
					reclock('TMP',.t.)
						//TMP->U_NUM 		:= ZZU->ZZU_NUM
						TMP->U_NUM 		:= 	confirmsx8()						
						TMP->U_DATA   	:= ZZU->ZZU_DATA
						TMP->U_CIDADE 	:= ZZU->ZZU_CIDADE
						TMP->U_STTIP 	:= ZZU->ZZU_STTIP
						TMP->U_TIPPRO 	:= ZZU->ZZU_TIPPRO
						TMP->V_CIDADE 	:= ZZU->ZZU_CIDADE
						TMP->V_NUM 		:= ZZV->ZZV_NUM
						TMP->V_COD  	:= ZZV->ZZV_COD	
						TMP->V_ITEM 	:= ZZV->ZZV_ITEM
						TMP->V_DESC  	:= ZZV->ZZV_DESC
						TMP->V_QPESO	:= ZZV->ZZV_QPESO
						TMP->V_QCAIX 	:= ZZV->ZZV_QCAIX	
						TMP->V_CONTRO  	:= ZZV->ZZV_CONTRO	
						TMP->V_OBS  	:= ZZV->ZZV_OBS	
					msunlock()
					ZZV->(DbSkip())
				Enddo
			else
				alert('708 - não Pegou iíndice no ZZV')
			Endif

			reclock('ZZU',.F.)
				ZZU->ZZU_STATUS := 'F'
				ZZU->ZZU_FECH := '1'
			msunlock()
			ZZU->(DbSkip())
		enddo
	Else
		alert('701 - Não localizou no MsSeek da ZZU')
	endif

Return 

Static Function GeraTMP()

	//If Select("TMP")<>0
	//	TMP->(dbCloseArea())
	//Endif

	//cArq  := CriaTrab( Nil, .F. )                      
	aStru := dbStruct()                                                         

	aadd(aStru,{"U_NUM"     , "C",  06, 0})
	aadd(aStru,{"U_DATA" , "D",  08, 0})
	aadd(aStru,{"U_CIDADE"  , "C",  40, 0})
	aadd(aStru,{"U_STTIP" , "C",  1, 0})
	aadd(aStru,{"U_TIPPRO" , "C",  1, 0})
	aadd(aStru,{"V_NUM"     , "C",  06, 0})
	aadd(aStru,{"V_COD" , "C",  6, 0})
	aadd(aStru,{"V_ITEM" , "C",  3, 0})
	aadd(aStru,{"V_QCAIX"  , "N",  05, 0})
	aadd(aStru,{"V_QPESO"   , "N",  15, 3})
	aadd(aStru,{"V_CONTRO" , "C",  1, 0})
	aadd(aStru,{"V_OBS" , "C",  60, 0})
	aadd(aStru,{"V_CIDADE"  , "C",  40, 0})
	aadd(aStru,{"V_DESC" , "C",  40, 0})

	//dbcreate(cArq,aStru)	
	//dbUseArea( .T.,,cArq,'TMP', .F. , .F. )               //cria temp

	_aArqTrb :={}
	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	dbSelectarea('TMP')
	TMP->(dbGotop())

return


Static Function GrvEnc(_dDa)
	Local _nCount := 0 // Inicializa o contador
	Local _cItem := 1
	Local _cNumer := space(6)

	TMP->(dbgotop())   
	_cNumer := GETSX8NUM('ZZU','ZZU_NUM')
	ConfirmSX8()   
	/* Regravar na ZZU e ZZV como uma nova Produção */
	while TMP->(!eof())
		_cIT := padl(cValToChar(_cItem),3,'0')
		if _nCount = 0 // Inicializa o contador
			//ZZU->ZZU_NUM	 := Campo preenche automático
			RecLock("ZZU",.T.)
				ZZU->ZZU_FILIAL	:= FWxFilial("ZZU")
				ZZU->ZZU_NUM	:= _cNumer
				ZZU->ZZU_DATAF  := date()
				ZZU->ZZU_DATA  := _dDa
				ZZU->ZZU_CIDADE := 'DIVERSAS'
				ZZU->ZZU_STTIP 	:= TMP->U_STTIP 
				ZZU->ZZU_STATUS := 'F'
				ZZU->ZZU_TIPPRO := 'A'
				ZZU->ZZU_FECH  	:= '1'
				ZZU->ZZU_GERAU  := '1'
			MsUnLock()    
		Endif		

		RecLock("ZZV",.T.)
			ZZV->ZZV_FILIAL	:= FWxFilial("ZZV")
			ZZV->ZZV_NUM	:= _cNumer        //padl(_cLote,6,'0') 
			ZZV->ZZV_COD 	:= TMP->V_COD
			ZZV->ZZV_ITEM   := _cIT
			ZZV->ZZV_DESC 	:= TMP->V_DESC
			ZZV->ZZV_QPESO 	:= TMP->V_QPESO
			ZZV->ZZV_QCAIX 	:= TMP->V_QCAIX
			ZZV->ZZV_CONTRO := TMP->V_CONTRO
			ZZV->ZZV_OBS 	:= TMP->V_OBS
			ZZV->ZZV_USERAL := cUserName
			ZZV->ZZV_DATAAL := DATE()
			ZZV->ZZV_HORAAL := TIME()
			ZZV->ZZV_CIDADE := TMP->V_CIDADE  
			ZZV->ZZV_TIPPRO := TMP->U_TIPPRO
		MsUnLock()
		_nCount++
		_cItem++
		TMP->(dbskip())
	enddo 

Return


User Function d85val() 
	if !empty(M->ZZV_COD)
		M->ZZV_COD  := padl(alltrim(M->ZZV_COD),6,'0')
	endif
Return .T.

/*/
±± Autor 	³ FLávio Bohrer FLôres		Data 08/07/2019   			º±±
±±ºDescricao³ Relatorio de Resumo Sintético Solicitação de Produção	º±±
±±ºUso      ³ PCP (SIGAPCP) - Produção(SIGAPCP)    By MLR13       	º±±
/*/ 
User Function d85Rel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia de Solicitações de Produção"
	Local cDesc3         := " "
	//Local cPict          := ""
	Local titulo         := "RESUMO SINTÉTICO DE SOLICITAÇÕES DE PRODUÇÃO"
	Local Cabec1         := "                    Produto                  Descr. do Produto                            Qnt. Caixas             Peso "
	Local Cabec2         := ""
	//Local imprime         := .T.
	Local aOrd            := {}  
	Private nLin          := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "DTI85R" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg   	:= "RDTI85"
	//Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI85R" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _nTOTAL    	:= 0.00
	
	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZV',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  
	
	GerQuery(mv_par03)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZZV') // ??????

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	
Return

User Function d85CRel()
Return

Static Function GerQuery (_nTPRel)

	/* _nTPRel = Tipo de Relatório se para Comercial ou PCP
	UsrRetName(RetCodUsr())
	alltrim(cUserName) = alltrim(ZZU->ZZU_USERIN) 
	mv_par03 - define se o relatório vai ser
	*/
	If _nTPRel = 1
		/* Se Relatório gerará para PCP */
		_cQuery := " SELECT  ZZU_DATA AS DATA,ZZV_NUM,ZZV_COD, ZZV_DESC, SUM(ZZV_QPESO) AS PESO,SUM(ZZV_QCAIX) AS CAIXA,ZZU_GERAU,ZZV_TIPPRO AS TPROD,ZZV_OBS "
		_cQuery += " FROM " + RetSQLTab('ZZU') + ", " + RetSQLTab('ZZV')
		_cQuery += " WHERE" + RetSQLFil('ZZU') + " AND " + RetSQLFil('ZZV') + " AND "
		_cQuery += " ZZU_NUM  = ZZV_NUM  AND"
		_cQuery += " ZZU_DATA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
		_cQuery += " AND " + RetSQLDel('ZZU') + " AND " + RetSQLDel('ZZV')
		_cQuery += " AND ZZU_GERAU IN('1')"
		_cQuery += " GROUP BY ZZU_DATA,ZZV_NUM,ZZV_TIPPRO,ZZV_COD, ZZV_DESC,ZZU_GERAU,ZZV_OBS" 
		_cQuery += " ORDER BY ZZU_DATA,ZZV_NUM,ZZV_TIPPRO,ZZV_COD"
	else
		/* Se Relatório gerará para Comercial */
		/* Novo parâmetro para imprimir relatório só com caixa ou só com peça */ 

		_cQuery :="SELECT ZZU_DATA AS DATA ,ZZU_GERAU,ZZV_NUM,ZZV_COD,ZZV_DESC,ZZV_QPESO AS PESO,"
		_cQuery +="ZZV_QCAIX AS CAIXA,ZZU_USERIN AS CUSER,ZZU_HORAIN AS HORA,ZZV_TIPPRO AS TPROD,ZZV_OBS"		
		_cQuery += " FROM " + RetSQLTab('ZZU') + ", " + RetSQLTab('ZZV')
		_cQuery += " WHERE" + RetSQLFil('ZZU') + " AND " + RetSQLFil('ZZV') + " AND "
		_cQuery += " ZZU_NUM  = ZZV_NUM  AND"
		_cQuery += " ZZU_DATA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
		_cQuery += " AND " + RetSQLDel('ZZU') + " AND " + RetSQLDel('ZZV')

		If mv_par04 = 1
			_cQuery += " AND ZZU_USERIN  = '"+cUserName+"'"
		endif

		_cQuery += " AND ZZU_GERAU IN('2')" 
		_cQuery += " ORDER BY ZZU_DATA,ZZV_NUM,ZZV_COD"
	Endif

	_cQuery  := ChangeQuery(_cQuery)

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  Gera_T() })

Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local _dData := date()-2000
	Local _cMostra := mv_par03
	Local nCont := 0
	Local _nZZVnum := ''

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))
	TMP->(dbGoTop())

	While TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
		if nCont = 0
			_cTIPPRO := TMP->TPROD
			_nZZVnum := TMP->ZZV_NUM
			
		Endif

		if _dData <> STOD(TMP->DATA)
			@nlin,010 psay replicate('-',116)			
			@nlin,010 psay "|"				
			@nlin,130 psay "|"	
			nlin++
			@nlin,010 psay "|"
			@nlin,013 psay "Data Prod:"
			@nlin,025 psay STOD(TMP->DATA)				
			@nlin,130 psay "|"      									
			nlin++			
			@nlin,130 psay "|"

			if (_cMostra = 2   .AND. (nCont = 0) )
				@nlin,009 psay "|"				
				@nlin,130 psay "|"	
				nlin++
				@nlin,010 psay "|"	 	
				@nlin,035 psay "Autor:"
				@nlin,043 psay alltrim(TMP->CUSER)
				@nlin,062 psay "Hora Pedido:"
				@nlin,078 psay alltrim(TMP->HORA)
				_nZZVnum := TMP->ZZV_NUM
				@nlin,010 psay "|"				
				@nlin,129 psay "|"	
			endif
			_dData := STOD(TMP->DATA)
		endif

		If  (_cMostra = 2 ) .AND. !(_nZZVnum = TMP->ZZV_NUM) .AND. (nCont > 0)	
			@nlin,010 psay "|"
			@nlin,130 psay "|"	
			nlin++
			@nlin,010 psay "|"
			@nlin,035 psay "Autor:"
			@nlin,043 psay alltrim(TMP->CUSER)
			@nlin,062 psay "Hora Pedido:"
			@nlin,078 psay alltrim(TMP->HORA)
			_nZZVnum := TMP->ZZV_NUM
			@nlin,130 psay "|"
			nlin++
			@nlin,010 psay "|"
			@nlin,130 psay "|"	
			nlin++
		Endif

		if _cMostra = 1
			if !(TMP->TPROD = _cTIPPRO) .OR. (nCont = 0)
				@nlin,010 psay "|"
				@nlin,013 psay "Tipo Prod:"
				if  TMP->TPROD = 'C'
					@nlin,025 psay 'Caixaria'
				Else
					@nlin,025 psay 'Peça'
				endif
				@nlin,130 psay "|"						
				nLin++
				_cTIPPRO := TMP->TPROD
			Endif
		Endif

		@nlin,010 psay "|"
		@nlin,013 psay TMP->ZZV_COD
		@nlin,023 psay substr(TMP->ZZV_DESC,1,25)
		@nlin,050 psay substr(TMP->ZZV_OBS,1,45)
		@nlin,100 psay transform(TMP->CAIXA,'@E 999,999')
		@nlin,107 psay transform(TMP->PESO,'@E 999,999.99')		
		@nlin,130 psay "|"		
		nlin++

		_nZZVnum := TMP->ZZV_NUM
		nCont++
		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo
	@nlin,010 psay replicate('-',116)                                                                                                                            

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

Static Function Gera_T()   

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

Return


User Function TFechProd(_dD)
	_cDataP := Dtos(_dD)
	/* Teste para verificar se a Produção já foi encerrada */
	DbSelectArea('ZZU')
	ZZU->(DbGoTop())
	ZZU->(DbSetOrder(2))

	If MsSeek(FWxFilial("ZZU") + _cDataP)
		while ZZU->(!eof()) .AND. (ZZU->ZZU_DATA = _dD)  
			If ZZU->ZZU_GERAU = '1'
				//_dData := ''
				return	.F.		
			Endif		
			ZZU->(DbSkip())
		enddo
	endif
Return .T.


User Function d85Lib()
	private oFont     := tFont():New("courier new",,-28,,.t.,,,,)
	private oFont2    := tFont():New("courier new",,-24,,.t.,,,,)
	private oFont3    := tFont():New("courier new",,-12,,.t.,,,,)
	private oFont4    := tFont():New("Arial",,-10,,.t.,,,,)
	Private oTxtTitulo 	:= 'Controle Peso Traseiro/Dianteiro'
	Private oTxtRetT  	:= ''
	Private oTxtBlT		:= ''
	Private oTxtRetD  	:= ''
	Private oTxtRetM  	:= ''
	Private oTxtBlD		:= ''
	Private oTxtBlM		:= ''
	Private oTxtRD		:= ''
	Private oTxtRT		:= ''
	Private oTxtLC		:= ''
	Private oTxtBC		:= ''
	Private oTxtEmb		:= ''
	Private oTxtTra		:= ''
	Private oTxtMds		:= ''
	Private oTxtEB 		:= ''
	Private oTxtMS		:= ''
	Private oTxtcos		:= ''
	Private _lVr	:= .F.
	Private _cCor1	:= ''
	Private _cCor2	:= ''
	Private _cCor3	:= ''
	Private _cCor4	:= ''

	_lVr := VldUsr(cUserName)

	If !(_lVr)
		msgbox('Usuário :'+cUserName+' não permitido Acesso a esta Operação!','OPERAÇÃO NEGADA!','STOP')
		return .f.
	Endif

	DEFINE MSDIALOG oAut TITLE 'Acompanhamento da Produção' from 000,000 To 350,915  PIXEL

	/* Objetos da Liberação Traseiro/Dianteiro*/
	oSayTxtBRT  := tSay():New(095,020,{|| oTxtBlT	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	oSayTxtLRT  := tSay():New(095,020,{|| oTxtRetT	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	oSayTxtBRD  := tSay():New(095,020,{|| oTxtBlD 	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)	
	oSayTxtLRD  := tSay():New(095,020,{|| oTxtRetD	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	oSayTxtLC   := tSay():New(095,020,{|| oTxtLC	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	oSayTxtBC   := tSay():New(095,020,{|| oTxtBC	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,400,30)
	oSayTxtLRM  := tSay():New(095,020,{|| oTxtRetM	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	oSayTxtBRM  := tSay():New(095,020,{|| oTxtBlM 	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	oSayTxtRD   := tSay():New(095,020,{|| oTxtRD		},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	oSayTxtRT   := tSay():New(095,020,{|| oTxtRT		},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)

	oSayTxtEB := tSay():New(105,015,{|| oTxtEB		},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,480,30)
	oSayTxtM  := tSay():New(125,015,{|| oTxtMS		},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,480,30)
	/* Objetos das Etiquetas Internas EMB/MDS*/
	/*
	If _cCor1 = 'V'
		oSayTxtE 	:= tSay():New(095,020,{|| oTxtEmb	},oAut,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,400,30)
	Elseif _cCor1 = 'A'
		oSayTxtE 	:= tSay():New(095,020,{|| oTxtEmb	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,400,30)
	Elseif _cCor2 = 'V'
		oSayTM 		:= tSay():New(110,020,{|| oTxtTra	},oAut,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,400,30)
	Elseif _cCor2 = 'A'
		oSayTM 		:= tSay():New(110,020,{|| oTxtTra	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,400,30)
	Elseif _cCor3 = 'V'
		oSayTxtC	:= tSay():New(125,020,{|| oTxtcos	},oAut,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,400,30)
	Elseif _cCor3 = 'A'
		oSayTxtC	:= tSay():New(125,020,{|| oTxtcos	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,400,30)
	Elseif _cCor4 = 'V'	
		oSayTMi		:= tSay():New(140,020,{|| oTxtMds	},oAut,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,400,30)
	Elseif _cCor4 = 'A'
		oSayTMi		:= tSay():New(140,020,{|| oTxtMds	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,400,30)
	Endif
	*/
		oSayTxtE 	:= tSay():New(095,020,{|| oTxtEmb	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,400,30)

		oSayTM 		:= tSay():New(110,020,{|| oTxtTra	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,400,30)

		oSayTxtC	:= tSay():New(125,020,{|| oTxtcos	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,400,30)

		oSayTMi		:= tSay():New(140,020,{|| oTxtMds	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,400,30)

	oGrupoL1 := tGroup():New(05, 10, 80, 335,	'Acompanhamento da Produção', oAut,,, .t.)	
	oGrupoL2 := tGroup():New(85, 10, 170,455,	'MSG', oAut,,, .t.)	
	oGpL3 := tGroup():New(05, 340, 80, 395,		'Prod.Tras/Dian', oAut,,, .t.)
	oGpL4 := tGroup():New(05, 400, 80, 455,		'Pré-Etiq.Liberação', oAut,,, .t.)
	oSayTxtTit 	:= tSay():New(015,035,{|| oTxtTitulo	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,60)//015

	/* Colocar botão */

	_oBtn02 := TButton():New(037, 25, "Liberar Peso Dianteiro"  ,oAut,{|| LD() },60,012,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn04 := TButton():New(054, 25, "Bloqueia Peso Dianteiro" ,oAut,{|| BD() },60,012,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oBtn01 := TButton():New(037, 90,"Liberar Peso Traseiro"	, oAut,{|| LT() },60,012,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn03 := TButton():New(054, 90, "Bloqueia Peso Traseiro"  , oAut,{|| BT() },60,012,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oBtn15 := TButton():New(037, 155,"Liberar Peso Costela"	, oAut,{|| LC() },60,012,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn16 := TButton():New(054, 155, "Bloqueia Peso Costela"  , oAut,{|| BC() },60,012,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oBtn05 := TButton():New(033, 218, "LIMPA MSG"    ,oAut,{|| Lmsg() },40,012,,oFont3,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn06 := TButton():New(048, 218, "STATUS T/D"   ,oAut,{|| Visu() },40,012,,oFont3,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn17 := TButton():New(063, 218, "Lib. Desos."  ,oAut,{|| LibDesos() },40,012,,oFont3,.F.,.T.,.F.,,.F.,,,.F.)

	_oBtn07 := TButton():New(037, 272, "Liberar Peso Miúdos"   ,oAut,{|| LM() },60,012,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn08 := TButton():New(054, 272, "Bloqueia Peso Miúdos"  ,oAut,{|| BM() },60,012,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oBtn09 := TButton():New(020, 343, "Produz Dianteiro"   ,oAut,{|| PD() 	 },48,015,,oFont4,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn10 := TButton():New(038, 343, "STATUS D/T"   		,oAut,{|| Visu2()},48,015,,oFont3,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn11 := TButton():New(056, 343, "Produz Traseiro"    ,oAut,{|| PT() 	 },48,015,,oFont4,.F.,.T.,.F.,,.F.,,,.F.)

	// Liberação da rotina de Pré-Etiqueta
	_oBtn12 := TButton():New(020, 408, "Lib.EMB"   , oAut,{|| Emb() },40,015,,oFont3,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn13 := TButton():New(038, 408, "Vis.Rot."  , oAut,{|| Vis3()},40,015,,oFont3,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtn14 := TButton():New(056, 408, "Lib.MDS"   , oAut,{|| Mds() },40,015,,oFont3,.F.,.T.,.F.,,.F.,,,.F.)

	//_oBtn01:SetColor(CLR_WHITE,CLR_GREEN)
	//_oBtn02:SetColor(CLR_WHITE,CLR_GREEN)
	//_oBtn03:SetColor(CLR_WHITE,CLR_GREEN)
	//_oBtn05:SetColor(CLR_WHITE,CLR_GREEN)	
	//_oBtn04:SetColor(CLR_WHITE,CLR_GREEN)

	ACTIVATE MSDIALOG oAut CENTERED

Return


Static Function LibDesos()

	Local _lBlqDes := GETMV('SI_BLQPCED')
	if FWAlertYesNo("Tem certeza que deseja liberar/bloquear a entrada de costelas na Desossa e dianteiros/traseiros na Costela?", "CONFIRMA")
		if _lBlqDes
			oTxtRetD  := 'Liberado Bloqueio da Desossa/Costela!'
		else
			oTxtRetD  := 'Bloqueada Liberação da Desossa/Costela!'
		endif
		PutMV('SI_BLQPCED', !_lBlqDes)

		oSayTxtLRM:CtrlRefresh()
		oAut:refresh() 

		oTxtRetT  	:= ''
		oTxtBlT	 	:= ''
		oTxtBlM	 	:= ''
		oTxtBlD 	:= ''
		oTxtBC		:= ''
		oTxtLC		:= ''

		oTxtTra:= ''
		oTxtEmb:= ''
		oTxtMds:= ''
		oTxtcos:= ''
	endif

Return

Static Function LM()
	oTxtRetD  := 'Liberada Produção Miúdos!'

	PUTMV('SI_PESMINM',.F.)

	//oSayTxtLRD:CtrlRefresh()

	oSayTxtLRM:CtrlRefresh()
	oAut:refresh() 

	oTxtRetT  	:= ''
	oTxtBlT	 	:= ''
	oTxtBlM	 	:= ''
	oTxtBlD 	:= ''
	oTxtBC		:= ''
	oTxtLC		:= ''

	oTxtTra:= ''
	oTxtEmb:= ''
	oTxtMds:= ''
	oTxtcos:= ''

Return

Static Function BM()
	oTxtBlD  := 'Bloqueada Produção Miúdos!'

	PUTMV('SI_PESMINM',.T.)
	//Refresh para mostrar Bloqueio do Traseiro
	//oSayTxtBRD:CtrlRefresh() 
	oSayTxtBRM:CtrlRefresh()
	oAut:refresh()

	oTxtRetD  := ''
	oTxtRetT  := ''
	oTxtBlT	 := ''
	oTxtBC		:= ''
	oTxtLC		:= ''

	oTxtTra:= ''
	oTxtEmb:= ''
	oTxtMds:= ''
	oTxtcos:= ''
Return


Static Function LD()
	oTxtRetD  := 'Liberada Produção Dianteiro sem Peso!'

	PUTMV('SI_PESMIND',.F.)

	oSayTxtLRD:CtrlRefresh()
	oAut:refresh() 

	oTxtRetT 	:= ''
	oTxtBlT	 	:= ''
	oTxtBlD	 	:= ''
	oTxtBC		:= ''
	oTxtLC		:= ''

	oTxtTra:= ''
	oTxtEmb:= ''
	oTxtMds:= ''
	oTxtcos:= ''

Return


Static Function BD()
	oTxtBlD  := 'Bloqueada Produção do Dianteiro sem Peso!'

	PUTMV('SI_PESMIND',.T.)

	//Refresh para mostrar Bloqueio do Traseiro
	oSayTxtBRD:CtrlRefresh() 

	oAut:refresh()

	oTxtRetD  := ''
	oTxtRetT  := ''
	oTxtBlT	 := ''
	oTxtBC		:= ''
	oTxtLC		:= ''

	oTxtTra:= ''
	oTxtEmb:= ''
	oTxtMds:= ''
	oTxtcos:= ''
Return


Static Function LT()

	oTxtRetT  := 'Liberada Produção do Traseiro sem Peso!'
	PUTMV('SI_PESMINT',.F.)

	//Refresh para mostrar Bloqueio do Traseiro
	oSayTxtLRT:CtrlRefresh() 
	oAut:refresh()
	oTxtRetD 	:= ''
	oTxtBlT	 	:= ''
	oTxtBlD	 	:= ''
	oTxtBC		:= ''
	oTxtLC		:= ''

	oTxtTra:= ''
	oTxtEmb:= ''
	oTxtMds:= ''
	oTxtcos:= ''
Return


Static Function BT()
	oTxtBlT  := 'Bloqueada Produção do Traseiro sem Peso!'

	PUTMV('SI_PESMINT',.T.)
	//Refresh para mostrar Bloqueio do Traseiro
	oSayTxtBRT:CtrlRefresh() 
	oAut:refresh()
	oTxtRetD  	:= ''
	oTxtRetT  	:= ''
	oTxtBlD	 	:= ''
	oTxtBC		:= ''
	oTxtLC		:= ''

	oTxtTra:= ''
	oTxtEmb:= ''
	oTxtMds:= ''
	oTxtcos:= ''
Return


Static Function LC()

	oTxtLC  := 'Liberada Produção do Costela sem Peso!'
	PUTMV('SI_PESMINC',.F.)

	//Refresh para mostrar Bloqueio do Traseiro
	oSayTxtLC:CtrlRefresh() 
	oAut:refresh()
	oTxtRetD 	:= ''
	oTxtBlT	 	:= ''
	oTxtBlD	 	:= ''
	oTxtRetT 	:= ''
	oTxtBC		:= ''

	oTxtTra:= ''
	oTxtEmb:= ''
	oTxtMds:= ''
	oTxtcos:= ''
Return


Static Function BC()
	oTxtBC  := 'Bloqueada Produção do Costela sem Peso!'

	PUTMV('SI_PESMINC',.T.)
	//Refresh para mostrar Bloqueio do Traseiro

	oSayTxtBC:CtrlRefresh() 
	oAut:refresh()
	oTxtRetD  	:= ''
	oTxtRetT  	:= ''
	oTxtBlD	 	:= ''
	oTxtBlT 	:= ''
	oTxtLC		:= ''

	oTxtTra:= ''
	oTxtEmb:= ''
	oTxtMds:= ''
	oTxtcos:= ''
Return


Static Function Lmsg()

	oTxtRetD  	:= ''
	oTxtRetT  	:= ''
	oTxtBlD	 	:= ''
	oTxtBlT		:= ''
	oTxtLC		:= ''
	oTxtBC		:= ''
	oTxtEmb		:= ''
	oTxtTra		:= ''
	oTxtMds		:= ''
	oTxtRD 		:= ''
	oTxtRT  	:= ''
	oTxtEB 		:= ''
	oTxtMS 		:= ''
	oTxtcos		:= ''

Return

Static Function Visu()

	oTxtEmb := ''
	oTxtTra := ''
	oTxtcos := ''
	oTxtMds := ''
	oTxtcos := ''
	oTxtBC	:= ''

	_nEmb 	:= GetMV('SI_PESMIND')
	_nT  	:= GetMV('SI_PESMINT')
	_nC  	:= GetMV('SI_PESMINC')
	_nMds  	:= GetMV('SI_PESMINM')
	/*Visualização da Rotina da Embalagem*/
	If _nEmb
		oTxtEmb  := 'Dianteiro Esta Bloqueado Seu Peso para Produzir !!'
		_cCor1 := 'V'
	else		
		oTxtEmb  := 'Dianteiro Esta Liberado Seu Peso para Produzir !!'	
		_cCor1 := 'A'
	endif
	// Refresh para mostrar o Status da Embalagem
	oSayTxtE:CtrlRefresh() 

	/*Visualização da Rotina dos Miudos*/

	If _nT
		oTxtTra  := 'Traseiro  Esta Bloqueado Seu Peso para Produzir !!'
		_cCor2 := 'V'
	else		
		oTxtTra  := 'Traseiro Esta Liberado Seu Peso para Produzir !!'
		_cCor2 := 'A'	
	endif
	// Refresh para mostrar o Status do Miúdos
	oSayTM:CtrlRefresh() 

	If _nMds
		oTxtMds  := 'Miúdos  Esta Bloqueado Seu Peso para Produzir !!'
		_cCor3 := 'V'
	else		
		oTxtMds  := 'Miúdos Esta Liberado Seu Peso para Produzir !!'
		_cCor3 := 'A'	
	endif
	oSayTMi:CtrlRefresh() 
	// Criar o Status da Costela 
	If _nC
		oTxtcos  := 'Costela  esta Bloqueado Seu Peso para Produzir !!'
		_cCor4 := 'V'
	else		
		oTxtcos  := 'Costela esta Liberado Seu Peso para Produzir !!'
		_cCor4 := 'A'	
	endif
	oSayTxtC:CtrlRefresh() 

	oAut:refresh()
	oTxtRetD  	:= ''
	oTxtRetT  	:= ''
	oTxtBlD	 	:= ''
	oTxtBlT		:= ''
	oTxtRD 		:= ''
	oTxtRT  	:= ''
	oTxtEB 		:= ''
	oTxtMS 		:= ''
	oTxtBC		:= ''
	oTxtLC  	:= ''

Return

// Marca para passar Dianteiro na desossa
Static Function PD()

	oTxtRD  := 'Produção de  dianteiro marcada !!'
	PUTMV('SI_CRTDSO','D')

	//Refresh para mostrar Bloqueio do Traseiro
	oSayTxtRD:CtrlRefresh() 
	oAut:refresh()
	oTxtRetD := ''
	oTxtRetT := ''
	oTxtBlT	 := ''
	oTxtBlD	 := ''
	oTxtTra:= ''
	oTxtEmb:= ''
	oTxtMds:= ''
	oTxtRT  := ''
	oTxtEB := ''
	oTxtMS := ''
	oTxtBC	:= ''
	oTxtLC  	:= ''
Return

// Marca para passar Dianteiro na desossa
Static Function PT()

	oTxtRT  := 'Produção de Traseiro marcada !!'
	PUTMV('SI_CRTDSO','T')

	//Refresh para mostrar Bloqueio do Traseiro
	oSayTxtRT:CtrlRefresh() 
	oAut:refresh()
	oTxtRetD := ''
	oTxtRetT := ''
	oTxtBlT	 := ''
	oTxtBlD	 := ''
	oTxtTra:= ''
	oTxtEmb:= ''
	oTxtMds:= ''
	oTxtRD	:=''
	oTxtEB := ''
	oTxtMS := ''
	oTxtBC	:= ''
	oTxtLC  	:= ''
Return


Static Function Visu2()

	_cVisPRD := GetMV('SI_CRTDSO')

	/*Visualização da Rotina da Embalagem*/
	If _cVisPRD ='D'
		//oSayTxtRD  := tSay():New(095,020,{|| oTxtRD
		oTxtRD  := 'Produção de  dianteiro marcada !!'
		oSayTxtRD:CtrlRefresh() 
	elseif _cVisPRD = 'T'		
		oTxtRT  := 'Produção de Traseiro marcada !!'
		oSayTxtRT:CtrlRefresh() 
	endif
	// Refresh para mostrar o Status da Embalagem
	//oSayTxtE:CtrlRefresh() 

	oAut:refresh()
	oTxtRetD  	:= ''
	oTxtRetT  	:= ''
	oTxtBlD	 	:= ''
	oTxtBlT		:= ''
	oTxtEmb 	:= ''
	oTxtTra 	:= ''
	oTxtMds 	:= ''
	oTxtEB		:= ''
	oTxtMS		:= ''
	oTxtcos		:= ''
	oTxtBC		:= ''
	oTxtLC  	:= ''
Return


Static Function Emb()

	PUTMV('SI_IMPPETQ','')
	oTxtEB  := 'Liberada rotina da Embalagem para produção de Pré-Etiqueta!'
	//oSayTxtE 	:= tSay():New(095,020,{|| oTxtEmb	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)//015 
	oSayTxtEB:CtrlRefresh() 
	oAut:refresh()
	oTxtRetD := ''
	oTxtRetT := ''
	oTxtBlT	 := ''
	oTxtBlD	 := ''
	oTxtTra	 := ''
	oTxtEmb	 := ''
	oTxtMds	 := ''
	oTxtRD	 :=''
	oTxtMS	 := ''
	oTxtcos	 := ''
	oTxtBC	:= ''
	oTxtLC  	:= ''

Return


Static Function Mds()
	oTxtEmb		:= ''	

	PUTMV('SI_IMPETQ2','')
	oTxtMS  := 'Liberada rotina dos Miúdos para produção de  Pré-Etiqueta!'
	//oSayTM 	:= tSay():New(095,020,{|| oTxtMds	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)//015 
	oSayTxtM:CtrlRefresh()

	oAut:refresh()
	oTxtRetD  	:= ''
	oTxtRetT  	:= ''
	oTxtBlD	 	:= ''
	oTxtBlT		:= ''
	oTxtEmb		:= ''
	oTxtEB		:= ''	
	oTxtBC		:= ''
	oTxtLC  	:= ''
Return


Static Function Vis3()

	oTxtEB := ''
	oTxtMS := ''
	_nEmb 	:= GetMV('SI_IMPPETQ')
	_nMDS  	:= GetMV('SI_IMPETQ2')
	/*Visualização da Rotina da Embalagem*/
	If !empty(alltrim(_nEmb))
		//oTxtEmb  := 'Rotina utilizada pela estação :'+_nEmb+' na Embalagem!'
		oTxtEB  := 'Rotina utilizada pela estação :'+_nEmb+' na Embalagem!'	
	else
		//oTxtEmb  := 'Rotina de Produção de Etiquetas sem ser utilizada na Embalagem!'
		oTxtEB  := 'Rotina de Produção de Etiquetas sem ser utilizada na Embalagem!'
	endif
	// Refresh para mostrar o Status da Embalagem
	oSayTxtEB:CtrlRefresh() 

	/*Visualização da Rotina dos Miudos*/
	If !empty(alltrim(_nMDS))	
		//oTxtMds  := 'Rotina utilizada pela estação :'+_nMDS+' nos Miúdos!'	
		oTxtMS  := 'Rotina utilizada pela estação :'+_nMDS+' nos Miúdos!'
	else
		//oTxtMds  := 'Rotina de Produção de Etiquetas sem ser utilizada nos Miúdos!'
		oTxtMS  := 'Rotina de Produção de Etiquetas sem ser utilizada nos Miúdos!'
	endif
	// Refresh para mostrar o Status do Miúdos
	oSayTxtM:CtrlRefresh() 

	oAut:refresh()
	oTxtRetD  	:= ''
	oTxtRetT  	:= ''
	oTxtBlD	 	:= ''
	oTxtBlT		:= ''
	oTxtEmb 	:= ''
	oTxtTra 	:= ''
	oTxtMds 	:= ''
	oTxtcos		:= ''
	oTxtBC		:= ''
	oTxtLC  	:= ''
	oTxtRT  	:= ''
	oTxtRD  	:= ''

Return


User Function d85vk()
	Set Key VK_F10 TO u_dti85sld()     // Consulta saldo de produtos
	Set Key VK_F12 TO u_GJF108()
return


User Function dti85sld()

	oFont    := tFont():New("courier new",,-16,,.t.,,,,)

	if cEmpAnt <> '01'
		msgbox('Rotina inválida para esta empresa','OPERAÇÃO INVALIDA','STOP')
		return
	endif

	nPosDel := Len(aHeader) + 1

	area := getarea()
	prod := GDFieldGet('ZZV_COD')

	DbSelectArea('SB1')
	UM      := GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1') + prod,1)
	_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1') + prod,1)
	_EmpFCaix := 0
	_cPorc := GetAdvFVal('SBM','BM_PORC',FWxfilial('SBM') + _cGrupo,1)

	if UM == 'CX' .OR. _cPorc == 'S'
		//query para trazer o que já está em estoque
		cQuery1 := "SELECT COUNT(*) AS ESTCAIX,SUM(SZ8.Z8_PESO) AS ESTPESO FROM " + RetSqlTab("SZ8")
		cQuery1 += " WHERE " +  RetSqlFil('SZ8')
		cQuery1 += "  AND Z8_FIL = '" + cFilAnt + "'"
		cQuery1 += "  AND Z8_DATAE = ' '"
		cQuery1 += "  AND Z8_DATAS = ' '"
		cQuery1 += "  AND Z8_ENCONTR <> 'N'"
		cQuery1 += "  AND Z8_COD = '" + prod + "'"
		cQuery1 += "  AND  " + RetSqlDel("SZ8")

		//query para trazer a previsao de caixas do produto
		cQuery2 := "SELECT ZU_PRIORI AS PRIORI, SUM(ZU_QPCAIX) AS QPCAIX, SUM(ZU_QRCAIX) AS QRCAIX,"
		cQuery2 += " SUM(ZU_QPPESO) AS QPPESO, SUM(ZU_QRPESO) AS QRPESO "
		cQuery2 += " FROM " + RetSqlTab("SZU")
		cQuery2 += " WHERE " +  RetSqlFil('SZU')
		cQuery2 += "  AND ZU_FECHADO = 'N' "
		cQuery2 += "  AND ZU_DTRPRO = '"+ DTOS(ddatabase)+"'"
		cQuery2 += "  AND ZU_COD = '" + prod + "'"
		cQuery2 += "  AND  " + RetSqlDel("SZU")
		cQuery2 += "  GROUP BY ZU_PRIORI"

		//query para trazer o que já está empenhado em pré-pedidos relativo ao produto
		cQuery3 := "SELECT SUM(ZZ5_QPCAIX) AS QPCAIX, SUM(ZZ5_QRCAIX) AS QRCAIX, ZZ4_DATA AS DTEMP, "
		cQuery3 += " SUM(ZZ5_QPPESO) AS QPPESO, SUM(ZZ5_QRPESO) AS QRPESO
		cQuery3 += " FROM " + RetSqlTab("ZZ5") + "," + RetSqlTab("ZZ4")
		cQuery3 += " WHERE " + RetSqlFil('ZZ5') + " AND " + RetSqlFil('ZZ4')
		cQuery3 += "  AND ZZ5_STATUS <> 'E'
		cQuery3 += "  AND ZZ4_NUM = ZZ5_NUM "
		cQuery3 += "  AND (ZZ4_STATUS <> 'E'"
		cQuery3 += "  AND ZZ4_STATUS <> 'P'"
		cQuery3 += "  AND ZZ4_STATUS <> 'F')"
		cQuery3 += "  AND ZZ4_TPOPER <> 'C'"
		cQuery3 += "  AND ZZ4_DATA = '" + DTOS(ddatabase) + "'"
		cQuery3 += "  AND ZZ5_COD = '" + prod + "'"
		cQuery3 += "  AND  " + RetSqlDel("ZZ4")
		cQuery3 += "  AND  " + RetSqlDel("ZZ5")
		cQuery3 += "  GROUP BY ZZ4_DATA"

		//query para trazer a validade das caixas
		cQuery4 := "SELECT COUNT(*) AS VALIDADE FROM " + RetSqlTab("SZ8")
		cQuery4 += " WHERE " +  RetSqlFil('SZ8')
		cQuery4 += "  AND Z8_FIL = '" + cFilAnt + "'"
		cQuery4 += "  AND Z8_DATAE = ' '"
		cQuery4 += "  AND Z8_DATAS = ' '"
		cQuery4 += "  AND Z8_ENCONTR <> 'N'" 		
		cQuery4 += "  AND Z8_COD = '" + prod + "'"
		cQuery4 += "  AND Z8_DATAVAL BETWEEN '" + DTOS(ddatabase) + "' AND '" + DTOS(ddatabase+15) + "'"
		cQuery4 += "  AND  " + RetSqlDel("SZ8")

		//query para trazer o que já está empenhado em pré-pedidos relativo ao produto do dia anterior
		cQuery5 := "SELECT SUM(ZZ5_QPCAIX) AS QPCAIX, SUM(ZZ5_QRCAIX) AS QRCAIX,
		cQuery5 += " SUM(ZZ5_QPPESO) AS QPPESO, SUM(ZZ5_QRPESO) AS QRPESO
		cQuery5 += " FROM " + RetSqlTab("ZZ5") + "," + RetSqlTab("ZZ4")
		cQuery5 += " WHERE " + RetSqlFil('ZZ5') + " AND " + RetSqlFil('ZZ4')
		cQuery5 += "  AND ZZ5_STATUS <> 'E'
		cQuery5 += "  AND ZZ4_NUM = ZZ5.ZZ5_NUM "
		cQuery5 += "  AND (ZZ4_STATUS <> 'E'"
		cQuery5 += "  AND ZZ4_STATUS <> 'P'"
		cQuery5 += "  AND ZZ4_STATUS <> 'F')"
		cQuery5 += "  AND ZZ4_TPOPER <> 'C'"
		cQuery5 += "  AND ZZ4_DATA = '" + DTOS(ddatabase-1) + "'"
		cQuery5 += "  AND ZZ5_COD = '" + prod + "'"
		cQuery5 += "  AND " + RetSqlDel("ZZ4")
		cQuery5 += "  AND " + RetSqlDel("ZZ5")

		//query para trazer o que já está em estoque Tf e liberado
		cQuery6 := "SELECT COUNT(*) AS ESTCAIX,SUM(SZ8.Z8_PESO) AS ESTPESO FROM " + RetSqlTab("SZ8")
		cQuery6 += " WHERE " +  RetSqlFil('SZ8')
		cQuery6 += "  AND Z8_FIL = '" + cFilAnt + "'"
		cQuery6 += "  AND Z8_DATAE = ' '"
		cQuery6 += "  AND Z8_DATAS = ' '"
		cQuery6 += "  AND Z8_DATAP <= '"  + dtos(ddatabase-13) + "'"
		cQuery6 += "  AND Z8_TF = 'S'"
		cQuery6 += "  AND Z8_ENCONTR <> 'N'"
		cQuery6 += "  AND Z8_COD = '" + prod + "'"
		cQuery6 += "  AND  " + RetSqlDel("SZ8")
		//	cQuery1 := ChangeQuery(cQuery1)

		cQuery1 := ChangeQuery(cQuery1)
		cQuery2 := ChangeQuery(cQuery2)
		cQuery3 := ChangeQuery(cQuery3)
		cQuery5 := ChangeQuery(cQuery5)
		cQuery4 := ChangeQuery(cQuery4)
		cQuery6 := ChangeQuery(cQuery6)

		//	* Mostrar a consulta */
		//	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//	@ 055,005 Get cQuery4 Size 250,080 MEMO Object oMemo
		//	Activate Dialog oDlgMemo

		If Select("QRY1")<>0
			QRY1->(dbCloseArea())
		Endif
		If Select("QRY2")<>0
			QRY2->(dbCloseArea())
		Endif
		If Select("QRY3")<>0
			QRY3->(dbCloseArea())
		Endif
		If Select("QRY4")<>0
			QRY4->(dbCloseArea())
		Endif
		If Select("QRY5")<>0
			QRY5->(dbCloseArea())
		Endif
		If Select("QRY6")<>0
			QRY6->(dbCloseArea())
		Endif

		TCQUERY cQuery1 NEW ALIAS "QRY1"
		estcx := QRY1->ESTCAIX
		estps := QRY1->ESTPESO
		QRY1->(dbclosearea())

		TCQUERY cQuery2 NEW ALIAS "QRY2"
		prevC := 0
		prevP := 0
		while QRY2->(!eof())
			if QRY2->QRCAIX < QRY2->QPCAIX
				prevC += QRY2->(QPCAIX - QRCAIX)
				prevP += QRY2->(QPPESO - QRPESO)
			endif
			QRY2->(dbskip())
		enddo
		QRY2->(dbclosearea())

		TCQUERY cQuery3 NEW ALIAS "QRY3"
		empC   := 0
		empP   := 0
		_demp  := date()

		if (QRY3->QRCAIX < QRY3->QPCAIX)  .or. (QRY3->QRPESO < QRY3->QPPESO)
			empC   := QRY3->(QPCAIX - QRCAIX)
			empP   := QRY3->(QPPESO - QRPESO)
			_demp  := stod(QRY3->DTEMP)
		endif
		QRY3->(dbclosearea())

		TCQUERY cQuery4 NEW ALIAS "QRY4"
		validad := 0
		validad := QRY4->VALIDADE
		QRY4->(dbclosearea())

		TCQUERY cQuery5 NEW ALIAS "QRY5"
		empantC := 0
		empantP := 0

		if (QRY5->QRCAIX < QRY5->QPCAIX) .or. (QRY5->QRPESO < QRY5->QPPESO)
			empantC := QRY5->(QPCAIX - QRCAIX)
			empantP := QRY5->(QPPESO - QRPESO)
		endif
		QRY5->(dbclosearea())

		TCQUERY cQuery6 NEW ALIAS "QRY6"
		estTFcx := QRY6->ESTCAIX
		estTFps := QRY6->ESTPESO
		QRY6->(dbclosearea())

		qCpc := 0
		qCpp := 0
		QTDc := 0
		QTDp := 0

		if  _demp = date()
			saldoC := iif(estTFcx <> 0,(estTFcx + prevC),(estcx + prevC)) - (empC + empantC + QTDc)
			saldoP := iif(estTFps <> 0,(estTFps + prevP),(estps + prevP)) - (empP + empantP + QTDp)
		else
			saldoC := iif(estTFcx <> 0,(estTFcx + prevC),(estcx + prevC)) - empC + empantC
			saldoP := iif(estTFps <> 0,(estTFps + prevP),(estps + prevP)) - empP + empantP
		endif

		_cDesc  	:= 'Posição do Produto'+'[ '+alltrim(prod)+' ]'	

		DEFINE MSDIALOG oSld TITLE _cDesc from 000,000 To 200,380 OF oMainWnd PIXEL

		@ 020,070 SAY  'Caixas'        Object oSay1
		@ 020,110 SAY  ' Peso '        Object oSay2
		@ 030,015 SAY  'Estoque:'      Object oSay3
		@ 040,015 SAY  'Previsão:'     Object oSay4
		@ 050,015 SAY  'Empenho:'      Object oSay5
		@ 070,015 SAY  'Saldo:'        Object oSay6

		@ 030,068 SAY  '[          ]'                                     Object oSay7
		@ 030,070 SAY  transform(estcx,'@E 9,999')                 			Object oSay9
		@ 030,103 SAY  '[                   '+ transform(estps,'@E 999,999.99')+' ]'   Object oSay10
		@ 040,068 SAY  '[          ]'                                     Object oSay11
		@ 040,070 SAY  transform(prevC,'@E 9,999')                 		  Object oSay13
		@ 040,103 SAY  '[                   '+ transform(prevP,'@E 999,999.99')+' ]'   Object oSay14
		@ 050,068 SAY  '[          ]'                                     Object oSay15
		@ 050,070 SAY  transform(empC + empantC + QTDc,'@E 9,999') 		  Object oSay17
		@ 050,103 SAY  '[                   '+ transform(empP + empantP + QTDp,'@E 999,999.99')+' ]'   Object oSay18
		@ 070,068 SAY  '[          ]'                                     Object oSay19

		if saldoC > 0
			oSay1 := tSay():New(070,075,{|| saldoC },oSld,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)				
		else			
			oSay1 := tSay():New(070,072,{|| saldoC },oSld,,oFont,,,,.T.,CLR_HRED,CLR_HRED,350,30)							
		Endif

		if saldoP > 0
			oSay1 := tSay():New(070,102,{|| '['+ transform(saldoP,'@E 999,999.99') +']' },oSld,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)				
		else			
			oSay1 := tSay():New(070,102,{||  '['+ transform(saldoP,'@E 999,999.99') +']'  },oSld,,oFont,,,,.T.,CLR_HRED,CLR_HRED,350,30)							
		Endif

		@ 083,146 BMPBUTTON TYPE 1 ACTION oSld:end() Object Obtn1

		ACTIVATE MSDIALOG oSld

	else
		msgbox('Produto não possui Controle de Estoque!','PRODUTO EM PEÇAS','STOP')
	endif

	_lSldFlag := .f.

Return
