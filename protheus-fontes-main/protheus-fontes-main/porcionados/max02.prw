#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Cad. Mat. Prima de 3º    							    	  º±±
±±ºº Autor ³ Max Müller                              º Data ³  12/11/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE e customizado                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MAX02() 

	Private aCores      := {}
	Private aCores2     := {}
	Private aRotina     := {}
	Private cCondicao   := '' 

	Private cPerg  	:= "MAX02"                       
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

	if !pergunte(Perg,.t.)
		return
	endif

	bLegenda1 := "ZAZ->ZAZ_STATUS == 'A'"          							 // Aberta
	bLegenda2 := "ZAZ->ZAZ_STATUS == 'E'"          							 // Encerrado


	aCores := { {bLegenda1, 'BR_VERDE'},{bLegenda2, 'BR_VERMELHO'}}  
	aCores2:= { { 'BR_VERDE','Aberto'},{ 'BR_VERMELHO','Encerrado'}} 

	aRotina := {{ "Pesquisa",  "AxPesqui"  , 	0, 1},; 	     //"Pesquisar"
	{ "Visualizar", "u_MAX02V", 	0, 2},;	 //"Visualizar"
	{ "Incluir",    "u_MAX02I", 	0, 3},;	 //"Incluir" 
	{ "Alterar",    "u_MAX02A", 	0, 4},;	 //"Alterar"
	{ "Excluir",    "u_MAX02x", 	0, 5},;  //"Excluir"
	{ "Legenda",    "u_MAX02L", 	0, 1}}   //"Legenda"

	Private cCadastro 	:= "Cadastro de Recebimento de MP de Terceiros"


	mBrowse(6,1,22,75,"ZAZ", ,,,,3    ,aCores,,,,{|x| AutoRefresh(x)})


	dbclosearea('ZAZ')  

Return

//Disponibiliza a legenda
User Function MAX02Leg(cAlias,nReg,nOpc) 
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return

//Visualiza as refeições
User Function MAX02Visu(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL   


	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL


	RegToMemory("ZAZ") 

	MAX02Ahead("ZAY")                                                           //Monta oa vetor aHeader

	nUsado := Len(aHeader)                                                        

	MAX02Acols(nOpc)															//Monta oa vetor aCols      

	oEnc    := MsMGet():New("ZAZ" ,ZAZ->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZAY_DATA",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, )

	DbSelectArea('ZAZ')

	RestArea(area)

Return

//Incluir movimentos de refeições
User Function MAX02Incl(cAlias,nReg,nOpc)
	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {} 

	verificaPeriodo()

	if TMP->ACHOU > 0
		alert('Já existem lançamentos para este funcionário no periodo selecionado!')		
		return
	endif                 


	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := MAX02Ahead("ZAY")
	MAX02Acols(nOpc)

	RegtoMemory('ZAZ')

	oEnc := MsMGet():New("ZAZ" ,ZAZ->(RECNO()), 2,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_MAX02LinOk(n,'I')","u_MAX02TudOk","",.T., , ,.F. , 20,,)


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_MAX02TudOk() .and. u_MAX02LinOk(n,'I'), ;
	Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

	If  lOk      
		MAX02Grav(nOpc)      
	Endif


Return

//Alteração das refeições
User Function MAX02Alte(cAlias,nReg,nOpc)

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

	verificaPeriodo()

	if TMP->ACHOU = 0
		alert('Não há lançamentos para este funcionário no periodo selecionado!')		
		return
	endif


	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := MAX02Ahead("ZAY")                                                 //Monta o aHeader

	MAX02Acols(nOpc)                                                            //Monta o Acols

	RegtoMemory('ZAZ')

	oEnc := MsMGet():New("ZAZ" ,ZAZ->(RECNO()), 2,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_MAX02LinOk(n,'A')","u_MAX02TudOk","",.T., , ,.F. ,20 ,,,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_MAX02TudOk().and.u_MAX02LinOk(n,'A');
	,Iif(lOk,oDlg:End(), odlg:refresh())}, {||oDlg:End()}, , aButtons)

	If lOk  

		MAX02Grav(nOpc)
	Endif


Return


//Exclusão das refeições entre as datas selecionadas nos parametros iniciais
User Function MAX02Excl(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	verificaPeriodo()

	if TMP->ACHOU = 0
		alert('Não há lançamentos para este funcionário no periodo selecionado!')		
		return
	endif            

	DbSelectArea(cAlias) 

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("ZAZ") 

	EnChoice( "ZAZ" ,ZAZ->(RECNO()), 2, , , , , aPosObj[1], , 3 )
	MAX02Ahead("ZAY") 

	nUsado	:= Len(aHeader)                                                           //Monta o aHeader

	MAX02Acols(nOpc)                                                                  //Monta o Acols

	oGet:= MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||MAX02Dele(),oDlg:End()},{||oDlg:End()},)

Return


//Montagem do aCols
static Function MAX02Acols(nOpc)
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

		nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZAY_DATA" })
		if nPos > 0          	   
			aCols[1,nPos]	:= stod("")
		endif
		aCols[1,nUsado+1] := .F.
	Else

		RegToMemory("ZAZ")

		dbSelectArea("ZAY")
		ZAY->(dbSetOrder(8))
		ZAY->(dbGoTop())
		//posiciona na data inicial
		if ZAY->(dbSeek(xfilial('ZAY') + ZAZ->RA_MAT))

			While ZAY->(!Eof()) .and. xFilial('ZAY') == ZAY->ZAY_FILIAL .and. ZAY->ZAY_MAT = ZAZ->RA_MAT .and. ZAY->ZAY_DATA <= _dDtFim            

				if ZAY->ZAY_DATA < _dDtIni
					ZAY->(dbSkip())
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

				ZAY->(DbSkip())	
			Enddo
		endif
	Endif

Return

//Monta oa aHeader
Static Function MAX02Ahead(cAlias)

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//DbSeek(cAlias)
	//Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	//	If 	at(Upper(AllTrim(X3_CAMPO)), "ZAY_FILIAL ZAY_MAT") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := cAlias 			// ZAY
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 			 	 .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZAY_FILIAL" .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZAY_MAT")

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

//Grava as refeições
Static Function MAX02Grav(nOpc)

	Local nIt
	Local nCont
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                                       	// Indica se todas as gravacoes obtiveram sucesso


	Begin Transaction


		ZAY->(DbGoTop())
		ZAY->(dbSetOrder(9))

		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				//NUMERO       
				If ZAY->(DbSeek(xFilial("ZAY") + aCols[nIt,10]))

					//Função que cancela as reservas de caixas
					//quando um item de um pre-pedido é excluído

					RecLock("ZAY",.F.)
					DbDelete()
					MsUnlock()
				Endif					      
			Endif     
		Next nIt                            


		For nIt := 1 To Len(aCols)

			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado		          
				//numero            	                                                                            
				If ZAY->(DbSeek(xFilial("ZAY") + aCols[nIt,10]))			
					RecLock("ZAY",.F.)
				Else                                  
					_cNum := GetSx8num('ZAY','ZAY_NUM')
					ConfirmSX8()                                                   
					aCols[nIt,10] := _cNum
					RecLock("ZAY",.T.)                 		  		
				Endif                           

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"		
						ZAY->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				ZAY->ZAY_FILIAL := xFilial('ZAY')
				ZAY->ZAY_MAT    := M->RA_MAT				

				MsUnlock()
			Endif
		Next nIt


	End Transaction

Return lGraOk

//Exclusão das refeições do periodo escolhido nos parametros iniciais
Static Function MAX02Dele()


	dbSelectArea("ZAY")
	ZAY->(dbSetOrder(8))
	ZAY->(dbGoTop())
	if ZAY->(dbSeek(xfilial('ZAY') + ZAZ->RA_MAT))

		While ZAY->(!Eof()) .and. xFilial('ZAY') == ZAY->ZAY_FILIAL .and. ZAY->ZAY_MAT = ZAZ->RA_MAT .and. ZAY->ZAY_DATA <= _dDtFim            

			if ZAY->ZAY_DATA < _dDtIni
				ZAY->(dbSkip())
				loop					
			endif

			reclock('ZAY',.f.)
			dbDelete()
			msunlock() 

			ZAY->(dbSkip())	   	
		enddo
	endif


Return

//Teste de validação da linha do grid
User Function MAX02LinOk(n,op)       

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

	if lRetorno              
		_dData   := GDFieldGet('ZAY_DATA',n)
		_cHora   := GDFieldGet('ZAY_HORA',n)
		_cCodRef := GDFieldGet('ZAY_CODREF',n)
		_cTpRef  := GDFieldGet('ZAY_TPREF',n)

		ZB6->(dbSetOrder(1))
		ZB6->(dbGoTop())
		ZB6->(dbSeek(xFilial('ZB6') + _cCodRef))

		ZB7->(dbSetOrder(1))
		ZB7->(dbGoTop())
		ZB7->(dbSeek(xFilial('ZB7') + _cTpRef))


		if empty(_dData) .or. empty(_cHora) .or. empty(_cCodRef) .or. empty(_cTpRef)	                    
			msgbox('Campos em branco!','OPERAÇÃO INVÁLIDA!','STOP')
			return .f.
		endif

		if _dData < _dDtIni
			msgbox('Data inferior a data do periodo selecionado!','OPERAÇÃO INVÁLIDA!','STOP')
			return .f.
		endif	 

		if _dData > _dDtFim	  
			msgbox('Data superior a data do periodo selecionado!','OPERAÇÃO INVÁLIDA!','STOP')
			return .f.
		endif

		if _cCodRef <> '005'
			if _cHora < ZB6->ZB6_HRINI 
				msgbox('Hora inferior a hora cadastrada para esta refeição!','OPERAÇÃO INVÁLIDA!','STOP')
				return .f.
			endif

			if _cHora > ZB6->ZB6_HRFIM
				msgbox('Hora superior a hora cadastrada para esta refeição!','OPERAÇÃO INVÁLIDA!','STOP')
				return .f.
			endif
		else      

			if _cHora < ZB6->ZB6_HRINI  .and. _cHora > ZB6->ZB6_HRFIM
				msgbox('Hora diverge da hora cadastrada para esta refeição!','OPERAÇÃO INVÁLIDA!','STOP')
				return .f. 
			endif   	 	

		endif                    

		if _cCodRef $ '002/004' .and. _cTpRef <> '006'
			msgbox('Codigo da refeição diverge do tipo de refeição selecionado!','OPERAÇÃO INVÁLIDA!','STOP')
			return .f.
		endif

	endif

Return lRetorno


//Testa todo aCols
User Function MAX02TudOk()

	Local lRetorno	:= .T.
	Local nIt 		:= 0
	Local nTot		:= 0
	Local nPosDel  	:= Len(aHeader) + 1
	Local nX
	
	_nTam := Len(aCols)

	for nX := 1 To _nTam

		_dData   := GDFieldGet('ZAY_DATA',nX)
		_cHora   := GDFieldGet('ZAY_HORA',nX)
		_cCodRef := GDFieldGet('ZAY_CODREF',nX)
		_cTpRef  := GDFieldGet('ZAY_TPREF',nX)

		ZB6->(dbSetOrder(1))
		ZB6->(dbGoTop())
		ZB6->(dbSeek(xFilial('ZB6') + _cCodRef))

		ZB7->(dbSetOrder(1))
		ZB7->(dbGoTop())
		ZB7->(dbSeek(xFilial('ZB7') + _cTpRef))


		if empty(_dData) .or. empty(_cHora) .or. empty(_cCodRef) .or. empty(_cTpRef)	                    
			msgbox('Campos em branco!','OPERAÇÃO INVÁLIDA!','STOP')
			lRetorno := .F.
			exit
		endif

		if _dData < _dDtIni
			msgbox('Data inferior a data do periodo selecionado!','OPERAÇÃO INVÁLIDA!','STOP')
			lRetorno := .F.
			exit
		endif	 

		if _dData > _dDtFim	  
			msgbox('Data superior a data do periodo selecionado!','OPERAÇÃO INVÁLIDA!','STOP')
			lRetorno := .F.
			exit
		endif

		if _cCodRef <> '005'
			if _cHora < ZB6->ZB6_HRINI
				msgbox('Hora inferior a hora cadastrada para esta refeição!','OPERAÇÃO INVÁLIDA!','STOP')
				lRetorno := .F.
				exit  	
			endif

			if _cHora > ZB6->ZB6_HRFIM
				msgbox('Hora superior a hora cadastrada para esta refeição!','OPERAÇÃO INVÁLIDA!','STOP')
				lRetorno := .F.
				exit  	
			endif
		else
			if _cHora < ZB6->ZB6_HRINI  .and. _cHora > ZB6->ZB6_HRFIM
				msgbox('Hora diverge da hora cadastrada para esta refeição!','OPERAÇÃO INVÁLIDA!','STOP')
				return .f. 
				exit
			endif   	 	  	  	
		endif               

		if _cCodRef $ '002/004' .and. _cTpRef <> '006'
			msgbox('Codigo da refeição diverge do tipo de refeição selecionado!','OPERAÇÃO INVÁLIDA!','STOP')
			lRetorno := .F.
			exit		  	
		endif

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

