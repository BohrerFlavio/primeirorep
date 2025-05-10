#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GJF39    ³ Giuliano Forgiarini           ³ Data ³ 12.06.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Devoluções                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigapcp                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF39()

	Private aCores     := {}
	Private aCores2    := {}
	Private aRotina    := {}   
	Private cCondicao  := '' 
	Private _cCondBKP  := ''
	Private cArq
	Private IndSZB     := {} 
	aObjects 			 := {}                                                                 
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
	aPosObj[2,1] += 60

	bLegenda1 := "SZB->ZB_STATUS == 'A'"          //Aberta
	bLegenda2 := "SZB->ZB_STATUS == 'E'"          //com pré-nota gerada
	bLegenda3 := "SZB->ZB_STATUS == 'N'"          //Em Analise
	bLegenda4 := "SZB->ZB_STATUS == 'G'"          //Aguardando Visto Diretoria
	bLegenda5 := "SZB->ZB_STATUS == 'D'"          //Vistado Diretoria

	aCores := { {bLegenda1, 'BR_VERDE'    },;      // Aberta
	{bLegenda2, 'BR_PRETO'    },;      //com pré-nota gerada
	{bLegenda3, 'BR_LARANJA'  },;      // Em Analise
	{bLegenda4, 'BR_AMARELO'  },;      // Aguardando Visto Diretoria
	{bLegenda5, 'BR_VERMELHO' }}       // Vistado Diretoria

	aCores2:= { { 'BR_VERDE'    ,'Aberta'            },;    // Aberta
	{ 'BR_PRETO'    ,'Ger.PNF/Encer.'    },;    // Gerada PRF/Encerrada
	{ 'BR_LARANJA'  ,'Em Analise'        },;    // Em Analise
	{ 'BR_AMARELO'  ,'Espera Visto Dir.' },;    // Aguardando Visto Diretoria
	{ 'BR_VERMELHO' ,'Visto Diretoria' }}       // Visto Diretoria

	Private aRotina := { 	{ "Pesquisa",  "AxPesqui"  , 	0, 1},; 	//"Pesquisar"
	{ "Visualizar", "u_gjf39Vis", 	0, 2},; 	//"Visualizar"
	{ "Incluir",    "u_gjf39Inc", 	0, 3},; 	//"Incluir"
	{ "Alterar",    "u_gjf39Alt", 	0, 4},; 	//"Alterar"  
	{ "Excluir",    "u_gjf39Exc", 	0, 5},;  //"Excluir"       
	{ "Estornar",    "u_gjf39est", 	0, 4},;  //"Estornar"   
	{ "Pre-Nota",   "u_gjf39PNF", 	0, 2},;  //"Gerar pré-nota"
	{ "Espelho",    "u_gjf90"   , 	0, 4},;     //"Impressão do espelho"
	{ "Legenda",    "u_gjf39Leg", 	0, 1}}      //"Legenda" 

	Private cCadastro 	:= "Devoluções de Mercadorias"
	Private cPerg        := "GJF39"
	Private _cUserID     := alltrim(RetCodUsr())

	if select('SZB') != 0													
		dbclosearea('SZB')
	endif
	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif
	If Select("TMP")<>0
		TMP->(dbCloseArea())
	Endif

	if !pergunte(cPerg,.t.) 
		return
	endif

	ZA4->(dbsetorder(1))
	if !ZA4->(DbSeek(xfilial('ZA4')+_cUserID))
		alert('Usuario não autorizado a acessar rotina de devoluções!')
		return .f.
	endif

	if mv_par03 = 1
		cCondicao := "SZB->ZB_DATA >= mv_par01 .and. SZB->ZB_DATA <= mv_par02 .and. SZB->ZB_FILIAL = '" + xfilial('SZB') + "'"
	elseif mv_par03 = 2 
		cCondicao := "SZB->ZB_DATA >= mv_par01 .and. SZB->ZB_DATA <= mv_par02 .and. SZB->ZB_STATUS = 'E'"+;
		" .and. SZB->ZB_FILIAL = '" + xfilial('SZB') + "'"
	elseif mv_par03 = 3   
		cCondicao := "SZB->ZB_DATA >= mv_par01 .and. SZB->ZB_DATA <= mv_par02 .and. SZB->ZB_STATUS $ 'A/N'"+;
		" .and. SZB->ZB_FILIAL = '" + xfilial('SZB') + "'"
	elseif mv_par03 = 4   
		cCondicao := "SZB->ZB_DATA >= mv_par01 .and. SZB->ZB_DATA <= mv_par02 .and. SZB->ZB_STATUS = 'G'"+;
		" .and. SZB->ZB_FILIAL = '" + xfilial('SZB') + "'"
	elseif mv_par03 = 5   
		cCondicao := "SZB->ZB_DATA >= mv_par01 .and. SZB->ZB_DATA <= mv_par02 .and. SZB->ZB_STATUS = 'D'"+;
		" .and. SZB->ZB_FILIAL = '" + xfilial('SZB') + "'"
	endif

	_cCondBKP := cCondicao

	DbSelectArea("SZB")
	SZB->(DbSetOrder(1))

	FilBrowse("SZB",@IndSZB,@cCondicao)

	SetKey(115,{|| CapT()})

	mBrowse(6,1,22,75,"SZB", ,,,,,aCores)

	If ( Len(IndSZB)>0 )
		EndFilBrw("SZB",IndSZB)
	endif  

	dbclosearea('SZB') 

	Set Key 115 to

Return

//Disponibiliza a legenda
User Function gjf39Leg(cAlias,nReg,nOpc)
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return  


//Visualiza Devolução
User Function gjf39Vis(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL   


	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("SZB") 

	gjf39Ahead("SZC")                                                           //Monta oa vetor aHeader

	nUsado := Len(aHeader)                                                        

	gjf39Acols(nOpc)															//Monta oa vetor aCols      

	oEnc := MsMGet():New("SZB" ,SZB->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZC_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, , aButtons)

	FilBrowse("SZB",@IndSZB,@cCondicao)

Return

//Incluir Devolução
User Function gjf39Inc(cAlias,nReg,nOpc)
	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {} 

	AADD(aButtons, { 'BMPORD'  ,{||LerCaix(), oDlg:Refresh() }, 'Leitura de Caixa' , 'Caixas'  } )

	If Select("TMP")<>0
		TMP->(dbCloseArea())
	Endif

	if ZA4->ZA4_VPCP <> 'S' .and. ZA4->ZA4_VCOM <> 'S'
		msgbox('Usuário não pertence ao Setor de PCP ou Comercial!','OPERAÇÃO INVALIDA!','STOP')
		return
	endif

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := gjf39Ahead("SZC")

	gjf39Acols(nOpc)

	RegToMemory("SZB",.T.)

	M->ZB_STATUS := 'A'

	oEnc := MsMGet():New("SZB" ,SZB->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_gjf39LinOk(n,'I')","u_gjf39TudOk","+ZZ5_ITEM",.T., , ,.F.  ,,,,,"u_gjf39grc(2)",)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_gjf39TudOk().and.Obrigatorio(aGets,aTela).and.u_gjf39LinOk(n,'I'), ;
	Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

	If lOk   
		DefUsr() 
		u_gjf39grc(0)
		confirmsx8()
		gjf39Grav(nOpc) 
		DefStt()    
	else
		Rollbacksx8()
	Endif

	FilBrowse("SZB",@IndSZB,@cCondicao)

Return

//Alteração de Pré-Pedido
User Function gjf39Alt(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aCposAlt	:= {}
	Local aButtons	:= {}
	Private aHeader:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {}

	if SZB->ZB_STATUS $ 'E/D'
		msgbox('Status não permite alteração!','OPERACAO CANCELADA!','ERRO')
		return .f.
	endif

	DbSelectArea(cAlias)

	AADD(aButtons, { 'BMPORD'  ,{||LerCaix(), oDlg:Refresh() }, 'Leitura de Caixa' , 'Caixas'  } )

	If Select("TMP")<>0
		TMP->(dbCloseArea())
	Endif

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := gjf39Ahead("SZC")                                                 //Monta o aHeader

	gjf39Acols(nOpc)                                                            //Monta o Acols

	RegtoMemory('SZB')

	oEnc := MsMGet():New("SZB" ,SZB->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_gjf39LinOk(n,'A')","u_gjf39TudOk","+SZC_ITEM",.T., , ,.F.  ,,,,,"u_gjf39grc(2)",)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_gjf39TudOk().and.u_gjf39LinOk(n,'A').and.;
	Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(), odlg:refresh())}, {||oDlg:End()}, , aButtons)

	If lOk
		DefUsr() 
		u_gjf39grc(0)
		gjf39Grav(nOpc)
		DefStt()
	Endif

	FilBrowse("SZB",@IndSZB,@cCondicao)

Return

//Exclusão da devolução
User Function gjf39Exc(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	if ZA4->ZA4_VPCP <> 'S' .and. ZA4->ZA4_VCOM <> 'S' 
		msgbox('Usuário não pertence ao Setor de PCP ou Comercial!','OPERAÇÃO INVALIDA!','STOP')
		return
	endif

	if ZA4->ZA4_VCOM = 'S' .and. !(SZB->ZB_DESTINO $ 'D/F')
		msgbox('Usuário do Setor Comercial impossibilitado de excluir devolução!','OPERAÇÃO INVALIDA!','STOP')
		return
	endif

	if SZB->ZB_STATUS <> 'A'
		msgbox('Status não permite exclusão!','OPERACAO CANCELADA!','ERRO')
		return .f.
	endif

	DbSelectArea(cAlias) 

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("SZB") 

	gjf39Ahead("SZC") 

	nUsado	:= Len(aHeader)                                                           //Monta o aHeader

	gjf39Acols(nOpc)  
	//Monta o Acols
	oEnc := MsMGet():New("SZB" ,SZB->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZC_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gjf39Dele(),oDlg:End()},{||oDlg:End()}, , aButtons)

	FilBrowse("SZB",@IndSZB,@cCondicao)

Return


//Montagem do aCols
static Function gjf39Acols(nOpc)
	Local nI, nPos
	If nOpc == 3

		aCols := Array(1,nUsado+1)

		For nI := 1 To Len(aHeader)
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

		nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZC_ITEM" })
		if nPos > 0
			aCols[1,nPos]	:= StrZero(len(acols)+1,Len(aCols[1,nPos]))
		endif
		aCols[1,nUsado+1] := .F.
	Else

		RegToMemory("SZB")

		dbSelectArea("SZC")
		dbSetOrder(1)
		dbSeek(xFilial('SZC')+SZB->ZB_NUM,.T.)

		Do While SZC->(!Eof()) .and. xFilial('SZC') ==  SZC->ZC_FILIAL .and. SZC->ZC_NUM == SZB->ZB_NUM
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

			SZC->(DbSkip())	
		Enddo

	Endif

Return

//Monta oa aHeader
Static Function gjf39Ahead(cAlias)

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//DbSeek(cAlias)
	//Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	//	If 	at(Upper(AllTrim(X3_CAMPO)), "ZC_FILIAL ZC_NUM") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := cAlias			// SZC
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 				.And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZC_FILIAL" .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZC_NUM")

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


Static Function gjf39Dele()

	u_gjf39grc(1)

	DbSelectArea("SZC")
	SZC->(DbSetOrder(1))

	DbSeek(xFilial("SZC") + SZB->ZB_NUM,.t.)

	Do While SZC->(!Eof()) .and. xFilial("SZC") == SZC->ZC_FILIAL .AND. SZB->ZB_NUM == SZC->ZC_NUM
		RecLock("SZC",.f.)
		DbDelete()
		MsUnLock()
		SZC->(DbSkip())
	Enddo

	DbSelectArea("SZB")

	RecLock("SZB",.f.)
	DbDelete()
	MsUnLock()

	FilBrowse("SZB",@IndSZB,@cCondicao)

Return


//Grava cabecalho e itens
Static Function gjf39Grav(nOpc)

	Local nIt
	Local nCont
	Local nNumItem
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                                      	// Indica se todas as gravacoes obtiveram sucesso

	//Verifica primeiramente se o usuário tem acesso a operação
	if INCLUI
		if ZA4->ZA4_VPCP <> 'S' .and. ZA4->ZA4_VCOM <> 'S'
			msgbox('Usuário não autorizado a executar operação!','OPERAÇÃO INVALIDA!','STOP')
			return .f.
		endif 
	Endif


	Begin Transaction

		DbSelectArea("SZB")
		DbSetOrder(1)

		If INCLUI                                                          //Se a opção foi de incluir registros, faz isso
			RecLock("SZB",.T.)
		Else                                                               //Senão...
			RecLock("SZB",.F.)                                             
		Endif

		For nCont := 1 To FCount()

			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("SZB"))
			Else
				FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
			Endif

		Next nCont

		MsUnLock()

		DbSelectArea("SZC")
		DbSetOrder(1)

		nNumItem := 1  // Contador para os Itens
		qCaixa := 0
		qPeso  := 0
		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				If DbSeek(xFilial("SZC")+ M->ZB_NUM + StrZero(nIt,3))
					RecLock("SZC",.F.)
					DbDelete()
					MsUnlock()   
				Endif
			Endif
		Next

		For nIt := 1 To Len(aCols)

			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

				If ALTERA
					If DbSeek(xFilial("SZC")+ M->ZB_NUM + StrZero(nIt,3))
						RecLock("SZC",.F.)
					Else
						RecLock("SZC",.T.)
					Endif
				Else
					RecLock("SZC",.T.)
				Endif

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"
						SZC->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				SZC->ZC_FILIAL	 := xFilial("SZC")
				SZC->ZC_NUM  	 := SZB->ZB_NUM                           
				SZC->ZC_ITEM    := strzero(nNumItem,3)

				nNumItem++
				MsUnlock()
			Endif
		Next nIt

	End Transaction

Return lGraOk


Static Function gjf39Del()

	DbSelectArea("SZC")
	SZC->(DbSetOrder(1))

	DbSeek(xFilial("SZC") + SZC->ZC_NUM,.t.)

	Do While SZC->(!Eof()) .and. xFilial("SZC") == SZB->ZB_FILIAL .AND. SZB->ZB_NUM == SZC->ZC_NUM  // Exclui os itens do PP
		RecLock("SZC",.f.)
		DbDelete()
		MsUnLock()
		SZC->(DbSkip())
	Enddo

	DbSelectArea("SZB")

	RecLock("SZB",.f.)
	DbDelete()
	MsUnLock()

	FilBrowse("SZB",@IndSZB,@cCondicao)

Return

//Testa todo aCols
User Function gjf39TudOk()

	Local lRetorno	:= .T.
	Local nIt 		:= 0
	Local nTot		:= 0
	Local nPosDel  	:= Len(aHeader) + 1
	/*
	If Empty(M->ZZ4_NUM) .or. nTot == Len(aCols)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
	EndIf
	*/
	If INCLUI
		If SZB->(dbSeek(XFILIAL("SZB")+M->ZB_NUM) )
			lRetorno := .F.
			Help(" ",1,"JAGRAVADO")  // Campo ja Existe
		Endif
	Endif

	//For nI := 1 To Len(aCols)
	//	if empty(aCols[nI,1]) .or. empty(aCols[nI,5]) .and. !aCols[nI,nPosDel]
	//		alert('Campos em branco nos itens da devolução!')
	//		lRetorno := .F.
	//		exit
	//	endif
	//Next nI  


	if !empty(M->ZB_NFENTRA) .and. !gjf39NF1()
		lRetorno := .F.
	endif

Return lRetorno

//Teste de validação da linha do grid
User Function gjf39LinOk(n,op)       

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

	if empty(aCols[n,6]) .and. !empty(aCols[n,1])
		alert('Valor unitário deve ser informado!')
		lRetorno := .f.
	endif

	lRetorno := .t.

Return  lRetorno

//Rotina para leitura de caixas que retornarão ao estoque na tabela ZA5
//após a leitura será levado o total para a tabela SZC criando um ítem específico
//da devolução
Static Function lercaix()

	Private	campo1 := space(10)
	Private	valor1 := space(10)
	Private aCampos := {} 
	Private _lSair := .f.

	if ZA4->ZA4_VPCP <> 'S' 
		msgbox('Usuário não pertence ao Setor de PCP!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

	if M->ZB_DESTINO <> 'E'
		msgbox('Lançamento de caixas somente para destino "Estoque"!','DESTINO DA DEVOLUÇÃO INCONSISTENTE','STOP')  
		return
	endif

	criaTMP()

	DEFINE MSDIALOG oEsc TITLE 'Leitura de Caixas' from 00,00 to 240,500 OF oMainWnd PIXEL 
	@ 001,002   SAY  "codigo Caixa: "    OF oEsc
	@ 001,007   MSGET campo1 VAR valor1 SIZE 65,11  VALID ScanC()  OF oEsc
	@ 030,005 To 90,250 Browse "TMP"  fields aCampos object oBrow 
	@ 100,020  BUTTON 'Excluir'  SIZE 40,15 ACTION ExcScn() OBJECT oBtn 
	@ 100,190  BUTTON 'Sair'     SIZE 40,15 ACTION SaiScn() OBJECT oBtn 
	ACTIVATE MSDIALOG oEsc VALID SaiScn2()

return  

//Função utilizada para escanear as caixas
//é habilitada na validação para haver o loop de foco
Static Function ScanC()

	if empty(valor1)
		return .t.
	endif

	SZ8->(dbsetorder(3))
	if !SZ8->(dbseek(xfilial('SZ8')+alltrim(valor1)))
		Som(0)
		msgbox('Caixa inexistente!','ERRO','ERRO')
		return .f.
	elseif empty(SZ8->Z8_DATAS)  .or.;
	empty(SZ8->Z8_HORAS)  .or.;
	empty(SZ8->Z8_PRECAR) .or.;
	empty(SZ8->Z8_PREPED) .or.;
	empty(SZ8->Z8_ITEM)
		Som(0)
		msgbox('Caixa encontra-se em estoque!','ERRO','ERRO')
		return .f.
	endif

	ZA5->(dbsetorder(3))
	if ZA5->(DbSeek(xfilial('ZA5')+alltrim(valor1)))
		Som(0)
		msgbox('Caixa já lançada em devolução de nr.: '+ZA5->ZA5_NUM,'ERRO','ERRO')
		return .f.
	endif

	TMP->(DbGoTop())
	while TMP->(!eof())
		if alltrim(TMP->CONTRO) = alltrim(valor1)
			Som(0)
			msgbox('Caixa já lançada nesta devolução!','ERRO','ERRO')
			return .f.
		endif
		TMP->(Dbskip())
	enddo

	TMP->(DbGoTop())

	reclock('TMP',.t.)
	TMP->NUM    := M->ZB_NUM
	TMP->COD    := SZ8->Z8_COD
	TMP->DESCRI := SZ8->Z8_DESCRI
	TMP->CONTRO := SZ8->Z8_CONTROL   
	TMP->QUANT  := SZ8->Z8_QUANT
	TMP->PESO   := SZ8->Z8_PESO
	msunlock() 

	TMP->(DbGoTop())

	Som(1)
	valor1 := space(10)  
	campo1:setfocus()
	oEsc:refresh()
	oBrow:oBrowse:refresh()

Return .f.

//Função utilizada para exclusão das caixas escaneadas
Static Function ExcScn()      

	if TMP->(reccount()) <> 0
		reclock('TMP',.f.)
		dbdelete()
		msunlock()
	endif                

	valor1 := space(10)  
	campo1:setfocus()
	oEsc:refresh()
	oBrow:oBrowse:refresh()

return 


//Função utilizada par a saída da tela de leitura de caixas
//ao sair deverá gerar ou atualizar item da devolução na 
//tabela SZC
Static Function SaiScn()
	Local _cCod   := ''
	Local _nQuant := 0.00
	Local _nPeso  := 0.00  
	Local _cDesc  := ''
	Local nPosDel := Len(aHeader) + 1
	Local i 
	Private _nCols := len(aCols)

	dbSelectArea('TMP')

	if TMP->(RecCount()) = 0 
		_lSair := .t.
		oEsc:end()
		return
	endif

	//_nTam := len(aCols)

	for i:=1 to _nCols 

		_found := .f. 

		if GDFieldGet('ZC_DESTINO',i) <> 'E'
			loop
		endif    

		TMP->(DbGoTop())
		while TMP->(!eof())

			if GDFieldGet('ZC_COD',i) = TMP->COD .and.;
			GDFieldGet('ZC_DESTINO',i) = 'E'
				_found := .t.                       
				exit
			endif
			TMP->(DbSkip())
		enddo 

		if !_found  .and. !empty(GDFieldGet('ZC_COD',i))
			aCols[i, nPosDel] := .t.
		endif   

	next

	IndRegua("TMP",cArq,"COD+CONTRO",,,) //ordena
	TMP->(dbGotop())

	while TMP->(!eof())
		if _cCod <> TMP->COD
			_cCod    := TMP->COD 
			_nQuant  := 0.00
			_nPeso   := 0.00
			_cDescri := TMP->DESCRI
		endif 

		_nQuant +=  TMP->QUANT
		_nPeso  +=  TMP->PESO  

		TMP->(DbSkip()) 

		if _cCod <> TMP->COD .or. TMP->(eof())
			IncLin(_cCod,_cDescri,_nQuant,_nPeso)
		endif 

	enddo
	_lSair := .t.
	oEsc:end()
Return

//Função para incluir linha nos itens da devolução
//ao sair da tela de leitura de caixas 

Static Function IncLin(_p1,_p2,_p3,_p4)
	Local _Found := .f.
	Local nPosDel := Len(aHeader) + 1 
	Local i
	if empty(_p1)
		return .t.
	endif

	for i := 1 to _nCols
		if _p1 = GDFieldGet("ZC_COD",i) .and.;
		!aCols[i, nPosDel] .and.;
		GDFieldGet("ZC_DESTINO",i) = 'E'
			GDFieldPut("ZC_QUANT"  ,_p3,i)
			GDFieldPut("ZC_PESO"   ,_p4,i)  
			GDFieldPut("ZC_PESORD" ,_p4,i) 
			_Found := .t.
			exit
		endif
	next   

	if !_Found
		if !empty(GDFieldGet("ZC_COD"))
			aadd(aCols,{_p1,_p2,_p3,_p4,_p4,0,0,'E',.t.})
			_nCols++     
			aCols[_nCols, nPosDel] := .f.
		else	 
			GDFieldPut("ZC_COD"    ,_p1)
			GDFieldPut("ZC_DESCRI" ,_p2)
			GDFieldPut("ZC_QUANT"  ,_p3)
			GDFieldPut("ZC_PESO"   ,_p4)
			GDFieldPut("ZC_PESORD" ,_p4) 
			//	GDFieldPut("ZC_TOTAL"  ,_p4 * GDFieldGet("ZC_VUNIT"))
			GDFieldPut("ZC_DESTINO",'E')  
		endif 	
	endif

	aCols[_nCols,7] := aCols[_nCols,4] * aCols[_nCols,6]

return

//Função para gravação, verificação 
//e exclusão de todas as caixas
//devolvidas na operação
User Function gjf39grc(_opc)

	Local _found := .f.
	Local area := getarea()

	//Se for operação de inclusão ou alteração
	//de devoluções, realiza as seguintes operações
	if _opc = 0

		_found := .f.

		If Select("TMP")<>0

			TMP->(DbGoTop())
			//Esse laço verificará se todas as caixas no TMP estão
			//na tabela ZA5
			while TMP->(!eof())

				SZ8->(DbSetOrder(3))
				SZ8->(DbSeek(xfilial('SZ8')+TMP->CONTRO))

				ZA5->(DbSetOrder(3))
				if !ZA5->(DbSeek(xfilial('ZA5')+TMP->CONTRO))
					reclock('ZA5',.t.)
					ZA5->ZA5_FILIAL  := xfilial('ZA5')
					ZA5->ZA5_CONTRO  := SZ8->Z8_CONTROL
					ZA5->ZA5_NUM     := M->ZB_NUM
					ZA5->ZA5_COD     := SZ8->Z8_COD
					ZA5->ZA5_DESC    := SZ8->Z8_DESCRI
					ZA5->ZA5_PESO    := SZ8->Z8_PESO
					ZA5->ZA5_QUANT   := SZ8->Z8_QUANT
					msunlock()
				endif

				//Coloca a caixa em estoque novamente
				reclock('SZ8',.f.)
				SZ8->Z8_DATAS   := stod('')
				SZ8->Z8_HORAS   := ''
				SZ8->Z8_PREPED  := ''
				SZ8->Z8_ITEM    := ''
				SZ8->Z8_PRECAR  := ''
				SZ8->Z8_RESERVA := ''
				msunlock()

				u_gjf17his(1,'DEVOLUÇÃO',.f.,'','','000008',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

				TMP->(DbSkip())
			enddo


			//Laço que verificará se todas as caixas
			//que estão na ZA5 estão na TMP
			//rotina inversa a de cima
			ZA5->(DbSetOrder(1))  
			ZA5->(DbGoTop())
			ZA5->(DbSeek(xfilial('ZA5')+M->ZB_NUM))
			While ZA5->(!eof()) .and. ZA5->ZA5_NUM = M->ZB_NUM

				_found := .f.
				TMP->(DbGoTop())
				While TMP->(!eof())
					if TMP->CONTRO = ZA5->ZA5_CONTRO
						_found := .t.
						exit
					endif
					TMP->(DbSkip())
				enddo

				if !_found
					reclock('ZA5',.f.)
					dbdelete()
					msunlock()

					//Tira novamente a caixa de estoque
					reclock('SZ8',.f.)
					SZ8->Z8_DATAS   := ddatabase
					SZ8->Z8_HORAS   := time()
					SZ8->Z8_PREPED  := 'CNCDEV'
					SZ8->Z8_ITEM    := 'DEV'
					SZ8->Z8_PRECAR  := 'CNCDEV'
					SZ8->Z8_RESERVA := ''
					msunlock()

					u_gjf17his(2,'CANC.DEVOLUÇÃO',.f.,'','','000009',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
				endif

				ZA5->(DbSkip())
			enddo
		endif

		//Se for operação de exclusão
		//de devoluções, realiza as seguintes operações
	elseif _opc = 1

		ZA5->(DbSetOrder(1))
		ZA5->(DbSeek(xfilial('ZA5')+M->ZB_NUM))
		While ZA5->(!eof()) .and. ZA5->ZA5_NUM = M->ZB_NUM

			SZ8->(DbSetOrder(3))
			if SZ8->(DbSeek(xfilial('SZ8')+ZA5->ZA5_CONTRO))
				//Tira novamente a caixa de estoque
				reclock('SZ8',.f.)
				SZ8->Z8_DATAS   := ddatabase
				SZ8->Z8_HORAS   := time()
				SZ8->Z8_PREPED  := 'EXCDEV'
				SZ8->Z8_ITEM    := 'DEV'
				SZ8->Z8_PRECAR  := 'EXCDEV'
				SZ8->Z8_RESERVA := ''
				msunlock()
			endif

			reclock('ZA5',.f.)
			dbdelete()
			msunlock()

			u_gjf17his(2,'EXC.DEVOLUÇÃO',.f.,'','','000010',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

			ZA5->(DbSkip())
		enddo
		restarea(area)

		If Select("TMP")<>0
			DbCloseArea("TMP")
		Endif
		//Quando excluir um item a rotina deverá
		//verificar se existem caixas vinculadas a ele
	elseif _opc = 2  

		if ZA4->ZA4_VPCP <> 'S' 
			msgbox('Usuário não pertence ao Setor de PCP!','OPERAÇÃO INVALIDA!','STOP')
			return .f.
		endif

		_cProd := GDFieldGet('ZC_COD')

		GDFieldGet('ZC_DESTINO') = 'E'

		criaTMP()

		if select('TMP') <> 0

			TMP->(dbGotop())

			While TMP->(!eof())  
				//	alert(TMP->COD)
				if TMP->COD = _cProd   
					reclock('TMP',.f.)
					dbdelete()
					msunlock()
				endif
				TMP->(DbSkip())
			enddo
		endif        

		restarea(area)
		return .t.
	endif
	restarea(area)

Return


//Função que auxilia no preenchimento do campo do codigo do produto
//nos itens da devolução
user function gjf39prd()  
	mod := iif(ZA4->ZA4_VPCP = "S" .or. (ZA4->ZA4_VCOM = "S" .and. M->ZB_DESTINO $ 'F/D'),.t.,.f.)  

	if ZA4->ZA4_VCTB = "S" .and. M->ZB_STATUS = 'E'
		mod := .t.
	endif

	if !empty(M->ZC_COD)
		M->ZC_COD := padl(alltrim(M->ZC_COD),6,'0') 
	endif
return mod  


//Validação do campo ZB_VQUA
Static Function gjf39VQ()

	ZA4->(DbSetOrder(1))
	ZA4->(DbSeek(xfilial('ZA4') + _cUserID))

	if ZA4->ZA4_VQUA <> 'S'
		msgbox('Usuário não autorizado a executar operação!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

	if empty(M->ZB_DESCQUA)
		msgbox('Parecer do setor de Qualidade em branco!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

	if empty(M->ZB_DESTINO)
		msgbox('Destino não apontado!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

Return .t.

//Validação do usuário Comercial
Static Function gjf39VC()

	ZA4->(DbSetOrder(1))
	ZA4->(DbSeek(xfilial('ZA4') + _cUserID))

	if ZA4->ZA4_VCOM <> 'S'
		msgbox('Usuário não autorizado a executar operação!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

	if empty(M->ZB_DESCCOM)
		msgbox('Parecer do setor Comercial em branco!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

	if empty(M->ZB_NFENTRA) .and.  M->ZB_NFPROPR = 'N'
		msgbox('Necessário apontar a Nota Fiscal de Entrada emitida pelo setor de Faturamento!','PENDENCIA COM O SETOR DE FATURAMENTO!','STOP')
		return .f.
	endif

Return .t.

//Validação do usuário PCP
Static Function gjf39VP()

	ZA4->(DbSetOrder(1))
	ZA4->(DbSeek(xfilial('ZA4') + _cUserID))

	if ZA4->ZA4_VPCP <> 'S'
		msgbox('Usuário não autorizado a executar operação!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

	if empty(M->ZB_DESCPCP)
		msgbox('Parecer do setor de PCP em branco!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

Return .t.

//Validação do usuário DIR
Static Function gjf39VD()

	ZA4->(DbSetOrder(1))
	ZA4->(DbSeek(xfilial('ZA4') + _cUserID))

	if ZA4->ZA4_VDIR <> 'S'
		msgbox('Usuário não autorizado a executar operação!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

Return .t.    

//Função para ativar o som
Static Function Som(t)
	if t=1   
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)
	else
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0) 
	endif
return

//Função que determina o registro do tipo
//de usuário que está acessando a rotina
Static Function DefUsr()  


	if ZA4->ZA4_VQUA = 'S' .and. empty(M->ZB_USQUA) .and. M->ZB_VQUA = 'V'
		M->ZB_USQUA   := _cUserID  
		M->ZB_NOMEQUA := cUserName
	endif    

	if ZA4->ZA4_VPCP = 'S' .and. empty(M->ZB_USPCP) .and. M->ZB_VPCP = 'V'
		M->ZB_USPCP   := _cUserID 
		M->ZB_NOMEPCP := cUserName 
	endif   

	if ZA4->ZA4_VCOM = 'S' .and. empty(M->ZB_USCOM) .and. M->ZB_VCOM = 'V'
		M->ZB_USCOM   := _cUserID 
		M->ZB_NOMECOM := cUserName
	endif  

	if ZA4->ZA4_VDIR = 'S' .and. empty(M->ZB_USDIR) .and. M->ZB_VDIR = 'V'
		M->ZB_USDIR   := _cUserID
		M->ZB_NOMEDIR := cUserName
	endif

Return 

//Função para validação do numero
//da nota fiscal de entrada na aba "comercial"
Static Function gjf39NF1() 

	Local _cTES   := GetMV('SI_TESDEV')
	Local _lTES   := .f.


	//Verifica antes o destino da devolução
	if !(M->ZB_DESTINO $ 'F/D')

		//Verifica se a NF é propria do cliente ou não
		if M->ZB_NFPROPR = 'N'
			SF1->(DbSetOrder(2))   
			if !SF1->(DbSeek(xfilial('SF1')+M->(alltrim(ZB_CLIENTE)+alltrim(ZB_LOJA)+alltrim(ZB_NFENTRA)),.t.))    
				msgbox("Nota Fiscal de Entrada não encontrada!","OPERAÇÃO INVÁLIDA!","STOP")
				return .f.
			endif        

			//verifica se entre os itens da nf selecionada existe apontado algum
			//TES para importação, definido no parametro SI_TESDEV
			SD1->(DbSetOrder(1))
			SD1->(DbSeek(xfilial('SD1')+SF1->(F1_DOC+padr(F1_SERIE,3,'')+F1_FORNECE+F1_LOJA)))  
			while SD1->(!eof()) .and. SD1->D1_FILIAL  = xfilial('SD1')  .and.;
			alltrim(SD1->D1_DOC)     = alltrim(SF1->F1_DOC)     .and.;
			alltrim(SD1->D1_SERIE)   = alltrim(SF1->F1_SERIE)   .and.;
			alltrim(SD1->D1_FORNECE) = alltrim(SF1->F1_FORNECE) .and.;
			alltrim(SD1->D1_LOJA)    = alltrim(SF1->F1_LOJA)     

				//Verifica se a nota fiscal de entrada está vinculada a 
				//aguma nf de origem                    
				if alltrim(SD1->D1_NFORI) <> alltrim(M->ZB_NF) .or. alltrim(SD1->D1_SERIORI) <> alltrim(M->ZB_SERIE)     
					SD1->(DbSkip())
					loop
				endif

				//Verifica se o TES do item da nf de entrada em analise
				//encontra-se na relação do parametro
				//Se sim, manda sai e dá o OK!                     
				if SD1->D1_TES $ _cTES 
					return .t.
					exit                 
				endif
				SD1->(DbSkip())
			enddo

			msgbox("NF de Entrada com TES errado ou sem vinculo com NF de origem!","OPERAÇÃO INVÁLIDA!","STOP")
			return .f.
		endif

	endif

return .t.  

User Function gjf39PNF()

	Private lMsErroAuto := .F.
	aCabec := {}
	aItens := {}

	area := getarea()

	if ZA4->ZA4_VCTB <> 'S' 
		msgbox('Usuário não pertence ao Setor de Contabilidade!','OPERAÇÃO INVALIDA!','STOP')
		return
	endif

	If SZB->ZB_STATUS <> 'D'
		msgbox('Aguardando visto da Diretoria','OPERAÇÃO ABORTADA!','STOP')
		return .f.
	elseif SZB->ZB_STATUS = 'E'
		msgbox('Pré-Nota Fiscal já gerada para esta devolução!','OPERAÇÃO ABORTADA!','STOP')
		return .f.
	Endif  

	if SZB->ZB_NFPROPR = 'N'
		msgbox('NCC gerada pelo setor de Faturamento para esta devolução!','OPERAÇÃO ABORTADA!','STOP')
		return .f.
	Endif   

	//Cabeçalho da pré-nota a ser gerada
	//pela rotina automática
	aadd(aCabec,{"F1_FILIAL", xfilial('SF1'), NIL })
	aadd(aCabec,{"F1_TIPO"   ,"D"                 })
	aadd(aCabec,{"F1_FORMUL" ,"N"                 })
	aadd(aCabec,{"F1_DOC"    ,SZB->ZB_NF          })
	aadd(aCabec,{"F1_SERIE"  ,SZB->ZB_SERIE       })
	aadd(aCabec,{"F1_EMISSAO",dDataBase           })
	aadd(aCabec,{"F1_FORNECE",SZB->ZB_CLIENTE     })
	aadd(aCabec,{"F1_LOJA"   ,SZB->ZB_LOJA        })
	aadd(aCabec,{"F1_ESPECIE","NFE"               })
	aadd(aCabec,{"F1_DESCONT",0              , NIL})
	aadd(aCabec,{"F1_SEGURO" ,0              , NIL})
	aadd(aCabec,{"F1_FRETE"  ,0              , NIL})
	aadd(aCabec,{"F1_VALMERC",0              , NIL})
	aadd(aCabec,{"F1_VALBRUT",0              , NIL})
	aadd(aCabec,{"F1_INDPRES","0"            , NIL})
	aadd(aCabec,{"F1_CODA1U" ,""             , NIL})

	//Laço para geração do vetor que vai abrigar
	//os itens da pré-nota
	SZC->(DbSetOrder(1))
	SZC->(DbSeek(xfilial('SZC')+SZB->ZB_NUM))
	while SZC->(!eof()) .and. SZC->ZC_FILIAL = SZB->ZB_FILIAL .and.;
	SZC->ZC_NUM    = SZB->ZB_NUM    
		aLinha := {}                       
		aadd(aLinha,  {'D1_FILIAL' ,xfilial('SD1'), NIL})
		aadd(aLinha,  {'D1_COD'    ,SZC->ZC_COD   , NIL})
		aadd(aLinha,  {'D1_QUANT'  ,SZC->ZC_PESO  , NIL})
		aadd(aLinha,  {'D1_VUNIT'  ,SZC->ZC_VUNIT , NIL})
		aadd(aLinha,  {'D1_TOTAL'  ,SZC->ZC_TOTAL , NIL})

		//Vai adicionar mais uma linha aos itens            
		AAdd(aItens, aLinha)

		SZC->(DbSkip())
	enddo		

	If Len(aItens)>0	

		MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, 3)

		If  lMsErroAuto
			MOSTRAERRO()
		Else

			reclock('SF1',.f.)
			SF1->F1_NUMDEV := SZB->ZB_NUM
			msunlock()

			reclock('SZB',.f.)
			SZB->ZB_STATUS := 'E'
			msunlock()           

			msgbox('Pré-Nota Fiscal de Devolução gerada com sucesso!','OPERAÇÃO CONCLUÍDA!','INFO')  

		EndIf

	Endif

	restarea(area)    

	pergunte(cPerg,.f.)
	DbSelectArea('SZB') 

	cCondicao := _cCondBKP

	/*
	If ( Len(IndSZB)>0 ) 

	cCondicao := _cCondBKP
	alert(cCondicao)
	EndFilBrw("SZB",IndSZB) 

	FilBrowse("SZB",@IndSZB,@cCondicao)
	endif  
	*/

Return

//Rotina para atualizar o
//Status da devolução

Static Function DefStt() 
	//Se os vistos forem todos então Aguardando
	if M->ZB_VQUA = 'A' .and. M->ZB_VCOM = 'A' .and. M->ZB_VPCP = 'A' .and. M->ZB_VDIR = 'A'
		reclock('SZB',.f.)
		SZB->ZB_STATUS := 'A'
		msunlock() 
	endif  
	//Se todos vistados menos diretor, então N = Espera visto do diretor        
	if (M->ZB_VQUA = 'V' .or. M->ZB_VCOM = 'V' .or. M->ZB_VPCP = 'V') .and. M->ZB_VDIR = 'A'    
		reclock('SZB',.f.)
		SZB->ZB_STATUS := 'N'
		msunlock() 
	endif   

	//Se o destino for refaturamento ou aguardando diferença de peso e já foi vistado pelo comercial e está aguardando o 
	//visto da diretoria então status = G = Aguardando visto diretoria e
	//torna os vistos da qualidade e pcp como D = dispensaveis
	if (M->ZB_DESTINO $ 'F/D') .and. M->ZB_VCOM = 'V' .and. M->ZB_VDIR = 'A'    
		reclock('SZB',.f.)
		SZB->ZB_STATUS := 'G'  
		SZB->ZB_VQUA   := 'D'
		SZB->ZB_VPCP   := 'D'
		msunlock() 
	endif  

	//Se vistado pela qualidade, vistado pelo comercial e vistado pelo PCP e  aguardando a diretoria     
	//sem que o destino seja refaturamento ou diferença de peso então o status  é G = Aguardando visto Diretoria    
	if M->ZB_VQUA = 'V' .and. M->ZB_VCOM = 'V' .and. M->ZB_VPCP = 'V' .and. M->ZB_VDIR = 'A' .and. !(M->ZB_DESTINO $ 'F/D')
		reclock('SZB',.f.)
		SZB->ZB_STATUS := 'G'
		msunlock()
	endif   

	//Se vistado pelo comercial e no aguardo do visto da diretoria e o destino for refaturamento ou diferença de peso então 
	//Status G = Aguardando visto da diretoria
	//Nesse caso pula direto os vistos do PCP e da Qualidade, por causa dos destinos 
	if M->ZB_VCOM = 'V'  .and. M->ZB_VDIR = 'A' .and. M->ZB_DESTINO $ 'F/D'
		reclock('SZB',.f.)
		SZB->ZB_STATUS := 'G'
		msunlock()
	endif 

	//Se vistado pela diretoria e com nf do cliente propria então estatus D = Vistado Diretoria   			
	if M->ZB_VDIR = 'V' .and. M->ZB_NFPROPR = 'S'  
		reclock('SZB',.f.)
		SZB->ZB_STATUS := 'D'
		msunlock()    
	endif   

	//Se vistado pela diretoria e sem a nf do cliente propria então estatus E = ENCERRADO
	//Nesse caso não vai precisar gerar pre-nota fiscal
	if M->ZB_VDIR = 'V' .and. M->ZB_NFPROPR = 'N' 
		reclock('SZB',.f.)
		SZB->ZB_STATUS := 'E'
		msunlock()    
	endif   


Return  

//Função que valida a saida da caixa pelo botão X
Static Function SaiScn2() 
	if !_lSair
		alert('Utilize o botão "Sair" para encerrar essa operação!')  
	endif
return _lSair 


//Rotina para criar o arquivo temporário
Static Function  criaTMP()

	aCampos := {}
	aadd(aCampos,{"CONTRO","Caixa    ",""})
	aadd(aCampos,{"COD"   ,"Produto  ",""})
	aadd(aCampos,{"DESCRI","Descricao",""})
	aadd(aCampos,{"QUANT" ,"Quant.   ","@E 999"})
	aadd(aCampos,{"PESO"  ,"Peso     ","@E 9,999.99"})

	If !(Select('TMP')<>0)                                                           //Se um tmp com alias TMP existir, fecha-o

		aStru   := {}
		_aArqTrb := {}
		//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

		aadd(aStru,{"NUM"    , "C",  06, 0,   "@!"          , 'Devol.'})
		aadd(aStru,{"CONTRO" , "C",  10, 0,   "@!"          , 'Caixa '})
		aadd(aStru,{"COD"    , "C",  06, 0,   "@!"          , 'Codigo'})
		aadd(aStru,{"DESCRI" , "C",  30, 0,   "@!"          , 'Descr.'})   
		aadd(aStru,{"QUANT"  , "N",  04, 0,   "@E 999"      , 'Quant.'})
		aadd(aStru,{"PESO"   , "N",  04, 0,   "@E 9,999"    , 'Peso  '})

		//dbcreate(cArq,aStru)
		//Cria a estrutura do vetor no TMP criado
		//Manda usar o TMP
		//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)

		U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

		cQuery := "SELECT ZA5_CONTRO AS CONTRO, ZA5_COD AS COD, ZA5_PESO AS PESO, ZA5_DESC AS DESCRI, ZA5_NUM AS NUM, ZA5_QUANT AS QUANT "
		cQuery += " FROM ZA5010 WHERE ZA5010.D_E_L_E_T_ <> '*' AND ZA5_NUM = '" + M->ZB_NUM + "'"
		cQuery += " AND ZA5_FILIAL = '" + xfilial('ZA5') + "'"

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		cQuery := ChangeQuery(cQuery)

		If Select("QRY")<>0
			QRY->(dbCloseArea())
		Endif

		TCQUERY cQuery NEW ALIAS "QRY"

		QRY->(DbGoTop())

		While QRY->(!eof())

			DbSelectArea('TMP')
			reclock('TMP',.t.)
			TMP->NUM    := QRY->NUM
			TMP->COD    := QRY->COD
			TMP->DESCRI := QRY->DESCRI
			TMP->CONTRO := QRY->CONTRO
			TMP->PESO   := QRY->PESO
			TMP->QUANT  := QRY->QUANT
			msunlock()

			QRY->(DbSkip())	
		enddo 

	else
		TMP->(DbGoTop())
	endif

Return 


//Função para determinar o modo de 
//edição nos campos da SZB
Static Function ModEdt()
	mod := iif(ZA4->ZA4_VQUA = "S" .or. (ZA4->ZA4_VCOM = "S" .and. M->ZB_DESTINO $ 'F/D'),.t.,.f.)
Return mod   

//Função para determinar o modo de 
//edição nos campos da SZB
Static Function ModEdt2()
	mod := iif((M->ZB_DESTINO $ 'F/D' .and. ZA4->ZA4_VCOM = "S") .or. ZA4->ZA4_VQUA = 'S',.t.,.f.)
Return mod   

//Função para determinar o modo de 
//edição nos campos da SZB
Static Function ModEdt3()
	mod := iif(!(M->ZB_DESTINO $ 'F/D') .and. ZA4->ZA4_VPCP = 'S',.t.,.f.)
Return mod   

//Função para determinar o modo de 
//edição nos campos da SZB
Static Function ModEdt4()
	mod := iif(ZA4->ZA4_VPCP = "S" .or. (ZA4->ZA4_VCOM = "S" .and. M->ZB_DESTINO $ 'F/D') .or. ZA4->ZA4_VCTB = "S",.t.,.f.)
Return mod  

//Função para estornar os vistos e status
User Function gjf39est()

	if ZA4->ZA4_VPCP = 'N' .and. ZA4->ZA4_VDIR = 'N' .and. ZA4->ZA4_VCTB = 'N' .and. ZA4->ZA4_VCOM = 'N'
		msgbox('Somente usuário do PCP, Diretoria e Contabilidade podem realizar esta operação!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

	if SZB->ZB_STATUS == 'E' 
		msgbox('Processo desta devolução já está concluído!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

	if !msgbox('Esta operação estornará os vistos e o status desta devolução. Continuar?(S/N)','ATENÇÃO!','YESNO')
		return .f.
	endif

	reclock('SZB',.f.)
	SZB->ZB_VDIR := 'A'
	SZB->ZB_VCOM := 'A'
	SZB->ZB_VPCP := 'A'
	SZB->ZB_VQUA := 'A' 
	msunlock()     

	RegtoMemory('SZB')

	DefStt()    

Return 
