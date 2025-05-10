#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MLR58    ³ Mauricio Roehrs           ³ Data ³ 15/10/2015   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gerenciamento de Refeições                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPE/SIGAPON                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR58()

	Private aCores      := {}
	Private aCores2     := {}
	Private aRotina     := {}
	Private cCondicao   := '' 
	Private _cUser      := alltrim(RetCodUsr())  
	Private cIPerg  	:= "MLR58"                       
	IndSZX              := {} 
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

	if !pergunte(cIPerg,.t.)
		return
	endif

	Private _dDtIni := mv_par01
	Private _dDtFim := mv_par02

	bLegenda1 := "SRA->RA_SITFOLH == ' '"          							 // Normal
	bLegenda2 := "SRA->RA_SITFOLH == 'A'"          							 // Afastado Temp.
	bLegenda3 := "SRA->RA_SITFOLH == 'D' .and. SRA->RA_AFASFGT <> 'N'" // Demitido
	bLegenda4 := "SRA->RA_SITFOLH == 'F'"          							 // Ferias
	bLegenda5 := "SRA->RA_SITFOLH == 'D' .and. SRA->RA_AFASFGT = 'N'"  // Transferido


	aCores := { {bLegenda1, 'BR_VERDE'    },;// Normal
	{bLegenda2, 'BR_AMARELO'  },;// Afastado Temp.
	{bLegenda3, 'BR_VERMELHO' },;// Demitido
	{bLegenda4, 'BR_AZUL'     },;//Ferias
	{bLegenda5, 'BR_PINK'    }}  // Transferido


	aCores2:= { { 'BR_VERDE'    ,'Normal'        },;//Normal
	{ 'BR_AMARELO'  ,'Afastado Temp.'},;//Afastado Temp.
	{ 'BR_VERMELHO' ,'Demitido'      },;//Demitido
	{ 'BR_AZUL'     ,'Ferias'        },;//Ferias
	{ 'BR_PINK'     ,'Transferido'   }} //Transferido


	aRotina := {{ "Pesquisa",  "AxPesqui"  , 	0, 1},; 	     //"Pesquisar"
	{ "Visualizar", "u_mlr58Visu", 	0, 2},;	 //"Visualizar"
	{ "Incluir",    "u_mlr58Incl", 	0, 3},;	 //"Incluir" 
	{ "Alterar",    "u_mlr58Alte", 	0, 4},;	 //"Alterar"
	{ "Excluir",    "u_mlr58Excl", 	0, 5},;  //"Excluir"
	{ "Legenda",    "u_mlr58Leg" , 	0, 1}}   //"Legenda"

	Private cCadastro 	:= "Gerenciamento de Refeições"


	mBrowse(6,1,22,75,"SRA", ,,,,2    ,aCores,,,,{|x| AutoRefresh(x)})


	dbclosearea('SRA')  

Return

//Disponibiliza a legenda
User Function mlr58Leg(cAlias,nReg,nOpc) 
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return

//Visualiza as refeições
User Function mlr58Visu(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL   

	area := GetArea()

	verificaPeriodo()

	if TMP->ACHOU = 0
		alert('Não há lançamentos para este funcionário no periodo selecionado!')		
		return
	endif                        


	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL


	RegToMemory("SRA") 

	mlr58Ahead("ZB8")                                                           //Monta oa vetor aHeader

	nUsado := Len(aHeader)                                                        

	mlr58Acols(nOpc)															//Monta oa vetor aCols      

	oEnc    := MsMGet():New("SRA" ,SRA->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZB8_DATA",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, )

	DbSelectArea('SRA')

	RestArea(area)

Return

//Incluir movimentos de refeições
User Function mlr58Incl(cAlias,nReg,nOpc)
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

	nUsado := mlr58Ahead("ZB8")
	mlr58Acols(nOpc)

	RegtoMemory('SRA')

	oEnc := MsMGet():New("SRA" ,SRA->(RECNO()), 2,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_mlr58LinOk(n,'I')","u_mlr58TudOk","",.T., , ,.F. , 20,,)


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_mlr58TudOk() .and. u_mlr58LinOk(n,'I'), ;
	Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

	If  lOk      
		mlr58Grav(nOpc)      
	Endif


Return

//Alteração das refeições
User Function mlr58Alte(cAlias,nReg,nOpc)

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

	nUsado := mlr58Ahead("ZB8")                                                 //Monta o aHeader

	mlr58Acols(nOpc)                                                            //Monta o Acols

	RegtoMemory('SRA')

	oEnc := MsMGet():New("SRA" ,SRA->(RECNO()), 2,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_mlr58LinOk(n,'A')","u_mlr58TudOk","",.T., , ,.F. ,20 ,,,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_mlr58TudOk().and.u_mlr58LinOk(n,'A');
	,Iif(lOk,oDlg:End(), odlg:refresh())}, {||oDlg:End()}, , aButtons)

	If lOk  

		mlr58Grav(nOpc)
	Endif


Return


//Exclusão das refeições entre as datas selecionadas nos parametros iniciais
User Function mlr58Excl(cAlias,nReg,nOpc)

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
	RegToMemory("SRA") 

	EnChoice( "SRA" ,SRA->(RECNO()), 2, , , , , aPosObj[1], , 3 )
	mlr58Ahead("ZB8") 

	nUsado	:= Len(aHeader)                                                           //Monta o aHeader

	mlr58Acols(nOpc)                                                                  //Monta o Acols

	oGet:= MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||mlr58Dele(),oDlg:End()},{||oDlg:End()},)

Return


//Montagem do aCols
static Function mlr58Acols(nOpc)
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

		nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZB8_DATA" })
		if nPos > 0          	   
			aCols[1,nPos]	:= stod("")
		endif
		aCols[1,nUsado+1] := .F.
	Else

		RegToMemory("SRA")

		dbSelectArea("ZB8")
		ZB8->(dbSetOrder(8))
		ZB8->(dbGoTop())
		//posiciona na data inicial
		if ZB8->(dbSeek(xfilial('ZB8') + SRA->RA_MAT))

			While ZB8->(!Eof()) .and. xFilial('ZB8') == ZB8->ZB8_FILIAL .and. ZB8->ZB8_MAT = SRA->RA_MAT .and. ZB8->ZB8_DATA <= _dDtFim            

				if ZB8->ZB8_DATA < _dDtIni
					ZB8->(dbSkip())
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

				ZB8->(DbSkip())	
			Enddo
		endif
	Endif

Return

//Monta oa aHeader
Static Function mlr58Ahead(cAlias)

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//DbSeek(cAlias)
	//Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	//	If 	at(Upper(AllTrim(X3_CAMPO)), "ZB8_FILIAL ZB8_MAT") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := cAlias 			// ZB8
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 			 	 .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZB8_FILIAL" .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZB8_MAT")

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
Static Function mlr58Grav(nOpc)

	Local nIt
	Local nCont
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                                       	// Indica se todas as gravacoes obtiveram sucesso


	Begin Transaction


		ZB8->(DbGoTop())
		ZB8->(dbSetOrder(9))

		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				//NUMERO       
				If ZB8->(DbSeek(xFilial("ZB8") + aCols[nIt,10]))

					//Função que cancela as reservas de caixas
					//quando um item de um pre-pedido é excluído

					RecLock("ZB8",.F.)
					DbDelete()
					MsUnlock()
				Endif					      
			Endif     
		Next nIt                            


		For nIt := 1 To Len(aCols)

			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado		          
				//numero            	                                                                            
				If ZB8->(DbSeek(xFilial("ZB8") + aCols[nIt,10]))			
					RecLock("ZB8",.F.)
				Else                                  
					_cNum := GetSx8num('ZB8','ZB8_NUM')
					ConfirmSX8()                                                   
					aCols[nIt,10] := _cNum
					RecLock("ZB8",.T.)                 		  		
				Endif                           

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"		
						ZB8->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				ZB8->ZB8_FILIAL := xFilial('ZB8')
				ZB8->ZB8_MAT    := M->RA_MAT				

				MsUnlock()
			Endif
		Next nIt


	End Transaction

Return lGraOk

//Exclusão das refeições do periodo escolhido nos parametros iniciais
Static Function mlr58Dele()


	dbSelectArea("ZB8")
	ZB8->(dbSetOrder(8))
	ZB8->(dbGoTop())
	if ZB8->(dbSeek(xfilial('ZB8') + SRA->RA_MAT))

		While ZB8->(!Eof()) .and. xFilial('ZB8') == ZB8->ZB8_FILIAL .and. ZB8->ZB8_MAT = SRA->RA_MAT .and. ZB8->ZB8_DATA <= _dDtFim            

			if ZB8->ZB8_DATA < _dDtIni
				ZB8->(dbSkip())
				loop					
			endif

			reclock('ZB8',.f.)
			dbDelete()
			msunlock() 

			ZB8->(dbSkip())	   	
		enddo
	endif


Return

//Teste de validação da linha do grid
User Function mlr58LinOk(n,op)       

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
		_dData   := GDFieldGet('ZB8_DATA',n)
		_cHora   := GDFieldGet('ZB8_HORA',n)
		_cCodRef := GDFieldGet('ZB8_CODREF',n)
		_cTpRef  := GDFieldGet('ZB8_TPREF',n)

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
User Function mlr58TudOk()

	Local lRetorno	:= .T.
	Local nIt 		:= 0
	Local nTot		:= 0
	Local nPosDel  	:= Len(aHeader) + 1
	Local nX
	
	_nTam := Len(aCols)

	for nX := 1 To _nTam

		_dData   := GDFieldGet('ZB8_DATA',nX)
		_cHora   := GDFieldGet('ZB8_HORA',nX)
		_cCodRef := GDFieldGet('ZB8_CODREF',nX)
		_cTpRef  := GDFieldGet('ZB8_TPREF',nX)

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

static function verificaPeriodo()


	_cQuery := " SELECT count(ZB8_MAT) AS ACHOU
	_cQuery += " FROM  " + retSqlTab('ZB8')
	_cQuery += " WHERE " + retSqlFil('ZB8')
	_cQuery += " AND ZB8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += " AND " + retSqlDel('ZB8')   


	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return
