#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MLR01    ³ Mauricio Roehrs           ³ Data ³ 02.07.12     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Solicitação de Produção                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaoms                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR01()

	Private aCores      := {}
	Private aCores2     := {}
	Private aRotina     := {}
	Private cCondicao   := '' 
	Private _cUser      := alltrim(RetCodUsr())
	IndSZX              := {} 
	aObjects            := {}                                                                 
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           :=aPosObj[1]                                                            
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	bLegenda1 := "SZX->ZX_STATUS == 'P'"          // pendente
	bLegenda2 := "SZX->ZX_STATUS == 'E'"          // encerrado


	aCores := { {bLegenda1, 'BR_VERMELHO'    },;       // pendente
	{bLegenda2, 'BR_VERDE' }}       // encerrado


	aCores2:= { { 'BR_VERMELHO'   ,'Pendente'   },;    // Pendente
	{ 'BR_VERDE'   ,'Encerrado'  }}    // Encerrado


	aRotina := {{ "Pesquisa",  "AxPesqui"  , 	0, 1},; 	     //"Pesquisar"
	{ "Visualizar", "u_mlr01Visu", 	0, 2},;	 //"Visualizar"
	{ "Incluir",    "u_mlr01Incl", 	0, 3},;	 //"Incluir" 
	{ "Alterar",    "u_mlr01Alte", 	0, 4},;	 //"Alterar"
	{ "Encerrar",   "u_mlr01enc" , 	0, 4},;  //"Encerrar"
	{ "Excluir",    "u_mlr01Excl", 	0, 5},;  //"Excluir"
	{ "Legenda",    "u_mlr01Leg" , 	0, 1}}   //"Legenda"

	Private cCadastro 	:= "Solicitacao de Producao"

	cCondicao := "SZX->ZX_USER = '" + _cUser + "'"


	FilBrowse("SZX",@IndSZX,@cCondicao)
	mBrowse(6,1,22,75,"SZX", ,,,,2    ,aCores,,,,{|x| AutoRefresh(x)})


	EndFilBrw("SZX",IndSZX)


	dbclosearea('SZX')  

Return

//Disponibiliza a legenda
User Function mlr01Leg(cAlias,nReg,nOpc) 
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return

//Visualiza Solicitação de Produção
User Function mlr01Visu(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	//Local aButtons	:= {{"POSCLI",{|| a450F4Con()},'Situação do Cliente','Posicao'}}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL   

	area := GetArea()

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL


	RegToMemory("SZX") 

	mlr01Ahead("SZY")                                                           //Monta oa vetor aHeader

	nUsado := Len(aHeader)                                                        

	mlr01Acols(nOpc)															//Monta oa vetor aCols      


	oEnc    := MsMGet():New("SZX" ,SZX->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZY_ITEM",.T.)

	//oGetDad:oBrowse:bChange    := {|| u_mlr01clc() }             //Realiza todos os calculos ao mudar de linha 
	//oGetDad:oBrowse:bLostFocus := {|| u_mlr01clc() }             //Realiza todos os calculos ao perder o foco da linha


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, )

	DbSelectArea('SZX')

	RestArea(area)

Return

//Incluir Solicitação de Produção
User Function mlr01Incl(cAlias,nReg,nOpc)
	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {} 


	SZX->(dbsetorder(2))
	if SZX->(dbseek(xfilial('SZX')+dtos(ddatabase)+_cUser))
		alert('Usuario ja possui solicitacao lançada nesta data') 
		SZX->(dbsetorder(1))
		return .f.
	endif    


	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := mlr01Ahead("SZY")
	mlr01Acols(nOpc)

	RegToMemory("SZX",.T.)

	M->ZX_USER := _cUser


	oEnc := MsMGet():New("SZX" ,SZX->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_mlr01LinOk(n,'I')","u_mlr01TudOk","+ZY_ITEM",.T., , ,.F. , 20,,"u_mlr01Vsp")

	//oGet:oBrowse:bChange    := {|| u_mlr01clc() }             //Realiza todos os calculos ao mudar de linha 
	//oGet:oBrowse:bLostFocus := {|| u_mlr01clc() }             //Realiza todos os calculos ao perder o foco da linha


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_mlr01TudOk().and.Obrigatorio(aGets,aTela).and.u_mlr01LinOk(n,'I'), ;
	Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

	If  lOk  

		confirmsx8()
		mlr01Grav(nOpc)      
	else
		Rollbacksx8()
	Endif


Return

//validador de inclusão de solicitação de produção
User Function mlr01Vsp()


	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL


	while SZY->(!eof()) .and. alltrim(SZY->ZY_COD)
		if SZY->ZY_COD <> empty(ZY_COD)
			msgbox ('teste de inclusão porra')
			return .f.
		endif 
	enddo

	SZY->(dbsetorder(1))
	SZY->(dbseek(xfilial('SZY')+alltrim(ZY_FILIAL+ZY_NUM+ZY_ITEM)))
	SZY->(dbgotop())

return


//Alteração da Solicitaçao de Producao
User Function mlr01Alte(cAlias,nReg,nOpc)

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

	//VERIFICAR POSSIBILIDADE DE ALTERAÇÃO DA SOLICITAÇÃO DE PRODUÇÃO
	if SZX->ZX_STATUS == 'E'                //Verifica o status do pré-pedido
		msgbox('Status não permite Alteração da Solicitação de Produção!','OPERAÇÃO NEGADA!','STOP')
		return
	endif  

	//u_mlr01aj(SZX->SZX_NUM)

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := mlr01Ahead("SZY")                                                 //Monta o aHeader

	mlr01Acols(nOpc)                                                            //Monta o Acols

	RegtoMemory('SZX')

	//M->ZX_STATUS := 'P'                                                        //Já bloqueia novamente a solicitação

	oEnc := MsMGet():New("SZX" ,SZX->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_mlr01LinOk(n,'A')","u_mlr01TudOk","+ZY_ITEM",.T., , ,.F. ,20 ,,,)

	//,"u_mlr01Vdl"
	//oGet:oBrowse:bChange    := {|| u_mlr01clc() }             //Realiza todos os calculos ao mudar de linha 
	//oGet:oBrowse:bLostFocus := {|| u_mlr01clc() }             //Realiza todos os calculos ao perder o foco da linha


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_mlr01TudOk().and.u_mlr01LinOk(n,'A').and.;
	Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(), odlg:refresh())}, {||oDlg:End()}, , aButtons)

	If lOk  

		mlr01Grav(nOpc)
	Endif


Return

/*/
//Função criada para validação de exclusão de linha na rotina de 
//alterar solicitação de produção
User Function mlr01Vdl() 
local ret    := .t.  
local	RCaix  := 0
local	RPeso  := 0  

RCaix := FBuscaCPO('SZY',1,xfilial('SZY')+M->ZX_NUM + StrZero(n,3),'ZY_QCAIX')
RPeso := FBuscaCPO('SZY',1,xfilial('SZY')+M->ZX_NUM + StrZero(n,3),'ZY_QPESO')    

if RCaix <> 0 .or. RPeso <> 0   
msgbox('Exclua todos itens dessa solicitação para exclui-la.','ITEM PARCIALMENTE ATENDIDO!','STOP')
ret := .f.
endif             

Return ret    

/*/

//Exclusão de Pré-Pedidos de venda
User Function mlr01Excl(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	if SZX->ZX_STATUS == 'E'   
		msgbox('Status não permite exclusão de Pré-Pedido!','OPERAÇÃO NEGADA!','STOP')
		return .f.
	endif     

	SZY->(dbsetorder(1))
	SZY->(dbseek(xfilial('SZY')+alltrim(SZX->ZX_NUM)))
	SZY->(dbgotop())  

	/*
	while SZY->(!eof()) .and. alltrim(SZY->ZY_NUM) == alltrim(SZX->SX_NUM) .and.;
	SZY->ZY_FILIAL = xfilial('SZY')       

	if SZY->SZY_QRCAIX <> 0 .or. SZY->SZY_QRPESO <> 0                      
	msgbox('Status não permite exclusão de Pré-Pedido!','CARREGAMENTO JÁ INICIADO!','STOP')
	return
	endif
	SZY->(dbskip())
	enddo
	*/
	DbSelectArea(cAlias) 

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("SZX") 

	EnChoice( "SZX" ,SZX->(RECNO()), nOpc, , , , , aPosObj[1], , 3 )
	mlr01Ahead("SZY") 

	nUsado	:= Len(aHeader)                                                           //Monta o aHeader

	mlr01Acols(nOpc)                                                                  //Monta o Acols

	oGet:= MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZY_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||mlr01Dele(),oDlg:End()},{||oDlg:End()},)

Return

//Encerra a Solicitação de Produção
user function mlr01enc         
	/*/
	if SZX->ZX_STATUS == 'C' .or. SZX->SZX_STATUS == 'F'
	msgbox('Status impede encerramento do Pré-Pedido!','OPERAÇÃO NEGADA!','STOP')//Verifica o status do Pré-Pedido
	return                                                                       
	endif          
	/*/
	if APMSGNOYES('Confirma encerramento da Solicitação de Produção?','ATENÇÃO')                  //Confirmação do encerramento 

		begin transaction                                                           
			reclock('SZX',.f.)
			SZX->ZX_STATUS := 'E'
			msunlock()              
		end transaction
	endif

return

//Montagem do aCols
static Function mlr01Acols(nOpc)
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

		nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZY_ITEM" })
		if nPos > 0
			aCols[1,nPos]	:= StrZero(len(acols)+1,Len(aCols[1,nPos]))
		endif
		aCols[1,nUsado+1] := .F.
	Else

		RegToMemory("SZX")

		dbSelectArea("SZY")
		dbSetOrder(1)
		dbSeek(xFilial('SZY')+SZX->ZX_NUM,.T.)

		Do While SZY->(!Eof()) .and. xFilial('SZY') ==  SZY->ZY_FILIAL .and. SZY->ZY_NUM == SZX->ZX_NUM
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

			SZY->(DbSkip())	
		Enddo

	Endif

Return

//Monta oa aHeader
Static Function mlr01Ahead(cAlias)

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//DbSeek(cAlias)
	//Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	//	If 	at(Upper(AllTrim(X3_CAMPO)), "SZY_FILIAL SZY_NUM") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := cAlias			// SZY
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 				.And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZY_FILIAL" .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZY_NUM")

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
Static Function mlr01Grav(nOpc)

	Local nIt
	Local nCont
	Local nNumItem
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                                       	// Indica se todas as gravacoes obtiveram sucesso

	Begin Transaction

		DbSelectArea("SZX")
		DbSetOrder(1)
		If INCLUI             
			//Se a opção foi de incluir registros, faz isso    
			RecLock("SZX",.T.)
		Else                                                             //Senão...
			RecLock("SZX",.F.)                                             
		Endif

		For nCont := 1 To FCount()

			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("SZX"))
			Else
				FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
			Endif

		Next nCont

		MsUnLock()

		DbSelectArea("SZY")
		DbSetOrder(1)

		nNumItem := 1  // Contador para os Itens
		qCaixa  := 0
		qPeso   := 0 
		_nTotal := 0.00
		_nBoni  := 0.00
		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				If DbSeek(xFilial("SZY") + M->ZX_NUM + StrZero(nIt,3)) 

					//Função que cancela as reservas de caixas
					//quando um item de um pre-pedido é excluído

					RecLock("SZY",.F.)
					DbDelete()
					MsUnlock()
				Endif
			Endif     
		Next

		For nIt := 1 To Len(aCols)

			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

				If ALTERA 
					If DbSeek(xFilial("SZY")+ M->ZX_NUM + StrZero(nIt,3))
						RecLock("SZY",.F.)
					Else 
						RecLock("SZY",.T.)
					Endif
				Else  
					RecLock("SZY",.T.)
				Endif

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"
						SZY->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				SZY->ZY_FILIAL	 := xFilial("SZY")
				SZY->ZY_NUM	 := SZX->ZX_NUM                           //Atribui o numero do PP ao item                                
				SZY->ZY_ITEM    := strzero(nNumItem,3)

				nNumItem++
				qCaixa += SZY->ZY_QCAIX                                  //Calcula o somatorio de caixas do PP
				qPeso += SZY->ZY_QPESO                                  //Calcula o somatorio de pesos  
				MsUnlock()
			Endif
		Next nIt


	End Transaction

Return lGraOk

//Exclusão das Solicitações de Produção
Static Function mlr01Dele()

	DbSelectArea("SZY")
	SZY->(DbSetOrder(1))

	DbSeek(xFilial("SZY") + SZX->ZX_NUM,.t.)

	Do While SZY->(!Eof()) .and. xFilial("SZY") == SZY->ZY_FILIAL .AND. SZX->ZX_NUM == SZY->ZY_NUM  // Exclui os itens do PP 

		RecLock("SZY",.f.)
		DbDelete()
		MsUnLock()
		SZY->(DbSkip())
	Enddo

	DbSelectArea("SZX")


	RecLock("SZX",.f.)
	DbDelete()
	MsUnLock()

Return

//Teste de validação da linha do grid
User Function mlr01LinOk(n,op)       

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

	_cProd  := GDFieldGet('ZY_COD',n)

	dbselectarea('SB1')
	dbsetorder(1)
	if !dbseek(xfilial('SB1')+_cProd) 
		return .F.
	endif


	for i:=1 to len(aCols)    
		if _cProd = aCols[i][1]  .and.  i <> n
			alert('produto repetido')
			lRetorno := .F.
			exit
		endif
	next

Return lRetorno


//Testa todo aCols
User Function mlr01TudOk()

	Local lRetorno	:= .T.
	Local nIt 		:= 0
	Local nTot		:= 0
	Local nPosDel  	:= Len(aHeader) + 1


	SZX->(dbsetorder(2))
	if SZX->(dbseek(xfilial('SZX')+dtos(ddatabase)+M->ZX_USER))
		alert('Usuario ja possui solicitacao lançada nesta data')
		lRetorno	:= .f.
	endif    

	SZX->(dbsetorder(1))

Return lRetorno


User Function mlr01pmc()
	pmedio := 0
	prod 	:= GDFieldGet('ZY_COD',n)
	SB1->(dbsetorder(1))
	if SB1->(Dbseek(xfilial('SB1')+prod))
		pmc    := SB1->B1_PMCAIX
		pmedio := (M->ZY_QCAIX * pmc)
	endif
return pmedio


//Função inversa a de cima
User Function mlr01cmp()
	caixas := 0
	prod   := GDFieldGet('ZY_COD',n)
	peso   := M->ZY_QPESO

	SB1->(dbsetorder(1))

	if SB1->(Dbseek(xfilial('SB1')+prod))
		cmp   := SB1->B1_PMCAIX
		ncaix := round(peso/cmp,0)
		return ncaix
	endif

return caixas


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
