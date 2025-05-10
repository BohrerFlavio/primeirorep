#INCLUDE "rwmake.ch"                                                                   
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"    

/*                                                                          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                        
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³dti24     ºAutor  ³Flávio Bohrer Flôres º Data ³  07/08/17  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa de Controle de Qualidade                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP     - Frigorifico Silva                                º±±
±±ºUso       ³ Utilização - Gerenciamento dos controles de Programas      º±±
±±ºUso       ³ de Quaidade que eram feitos via planilhas, então passaram  º±±
±±ºUso       ³ a ser feitos pela sistema                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function dti24()         

	Private cString 		:= "ZC1"
	Private aCores   		:= {}
	Private aCores2 		:= {} 
	Private aRotina     	:= {}
	Private cCadastro 	:= "Tabela de Controle de Temperatura"
	Private _sDesc   		:= ""
	Private _sDesc2  		:= ""
	Private _vMenu 		:= GetMV('SI_TESTE')
	Private _cVer			:= "2" // Indica se usuário é verificador     1 = Sim   2 = Não

	_VERIF 	:=  ""
	aObjects            	:= {}
	aPosObj             	:= {}
	aInfo               	:= {}
	aSizeAut            	:= MsAdvSize() 

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           :=aPosObj[1]
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60  


	// Ajustar para buscar do cadastro  de usuários das Tabelas da Qualidade
	IF  alltrim(_vMenu) $ cUserName 
		_sDesc:= "Efet.Verificação"
		_sDesc2 := "u_dti24ver" 
		_cVer := "1"
	Else
		_sDesc:= ""
		_sDesc2:=""
	Endif
	//	{ _sDesc , _sDesc2 				, 	0, 4},; // Verificação da Veterinária Qualidade

	aRotina := {{ "Pesquisa"   ,"AxPesqui" , 	0, 1},; //"Pesquisar"				
	{ "Visualizar" ,"u_dti24Visu" , 	0, 2},; //"Visualizar"
	{ "Incluir"    ,"u_dti24Inc" , 	0, 3},; //"Incluir",;  
	{ "Alterar"    ,"u_dti24Alt" 	, 	0, 4},; //"Alterar"
	{ "Excluir",    "u_dti24Exc"	, 	0, 5},; //"Excluir"
	{ "Legenda"    ,"u_dti24Leg"  , 	0, 1}}  //"Legenda"      

	bLegenda1 :=  "ZC1->ZC1_STATUS == 'A'"
	bLegenda2 :=  "ZC1->ZC1_STATUS == 'B'"
	bLegenda3 :=  "ZC1->ZC1_STATUS == 'C'"


	aCores2:= { { 'BR_VERDE'   	,'Verificado'    		},;
	{ 'BR_AMARELO'    ,'Em Verificao' 		},;
	{ 'BR_VERMELHO'	,'Não Verificado' 	}}

	aCores :=  {{ 	bLegenda1, 'BR_VERDE'     },;
	{ 	bLegenda2, 'BR_AMARELO'   },;				
	{ 	bLegenda3, 'BR_VERMELHO'  }}



	//mBrowse(6,1,22,75,cString, ,,,,1     ,aCores(,,,,{|x| AutoRefresh(x)},,,,) 
	mBrowse(6,1,22,75,cString, ,,,,1     ,aCores,,,,,,,,) 
	//LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores     


return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MENUDEF  ³ Autor ³ Evandro Mugnol        ³ Data ³21/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Isola opcoes de menu para que as opcoes da rotina possam   ³±±
±±³          ³ ser lidas pelas bibliotecas framework da Versao 10         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ <Vide Parametros Formais>                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Static Function MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
/*

Private aRotina := { {"Pesquisar"    , "AxPesqui"    , 0 , 1 , 0 , .F. } ,;
{"Visualizar"   , "AxVisual"    , 0 , 2 , 0 , NIL } ,;
{"Incluir"      , "u_dti24inc"  , 0 , 3 , 0 , NIL } ,;
{"Alterar"      , "u_dti24alt"  , 0 , 4 , 0 , NIL } ,;                     
{"Legenda"      , "u_dti24lPC"  , 0 , 2 , 0 , NIL }}

Return aRotina


return
*/

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


User Function dti24inc(cAlias,nReg,nOpc) 
	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}
	Private aHeader:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {}


	area := GetArea()        

	RegToMemory("ZC1",.T.)	

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := dti24Ahead("ZC2")
	dti24Acols(nOpc)

	oEnc := MsMGet():New("ZC1" ,ZC1->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],nOpc,"u_dti24LinOk(n,'I')","u_dti24TudOk","",.T., , ,.F. , 20,,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_dti24TudOk() .and. u_dti24LinOk(n,'I'), ;
	Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)
	//alert('187')
	If  lOk
		dti24Grav(nOpc)
	Endif

	DbSelectArea('ZC1')
	RestArea(area)
Return        

//Teste de validação da linha do grid
User Function dti24LinOk(n,op)

	Local lRetorno 	:= .T.
	Local nPosDel 	:= Len(aHeader) + 1
	Local nCpo


	if  lRetorno
		lRetorno := .F.
		If !aCols[n, nPosDel]                                                  // Verifica se o item foi deletado
			For nCpo := 2 To Len(aHeader)                                      // Ignora o  Item
				If !Empty(aCols[n, nCpo]) .and. ValType(aCols[n, nCpo]) <> "D"
					lRetorno := .T.
				Endif
			Next nCpo
		Else
			lRetorno := .T.
		Endif
	endif

Return lRetorno


//Testa todo aCols
User Function dti24TudOk()

	Local lRetorno	:= .T.
	Local nIt 		:= 0
	Local nTot		:= 0
	Local nPosDel  	:= Len(aHeader) + 1

	If INCLUI
		If ZC1->(dbSeek( XFILIAL("ZC1") + ZC1->ZC1_NUM) )
			lRetorno := .F.
			Help(" ",1,"Registro Duplicado")  // Campo ja Existe
		Endif
	Endif

Return lRetorno


//Grava cabecalho e itens
Static Function dti24Grav(nOpc)        

	Local nIt   	
	Local nCont
	Local lGraOk 		:= .T.      
	Local nNumItem
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local _VERIF 		:= "N" 


	Begin Transaction

		DbSelectArea("ZC1") 
		DbSetOrder(1)

		If INCLUI	
			//Se a opção foi de incluir registros, faz isso
			RecLock("ZC1",.T.)
			ZC1->ZC1_FILIAL  :=  ZC1->(xfilial('ZC1'))	
		Else                                                             //Senão...
			RecLock("ZC1",.F.)
		Endif        

		For nCont := 1 To FCount()

			If "FILIAL"$Field(nCont)  			
				FieldPut(nCont,xFilial("ZC1")) 			
			Else         

				IF  alltrim(_vMenu) $ cUserName 
					// Altera o campo ZC1_VERIF conforme ajuste na interface     	        
				Else							
					ZC1->ZC1_VERIF := _VERIF
					//ZC1->ZC1_DATCRI := _VERIF

				Endif

				FieldPut(nCont,M->&(EVAL(bCampo,nCont)))  

			Endif

		Next nCont              
		// Grava automaticamente o usuário responsável (compilar e testar)
		ZC1->ZC1_RESP    	:= cUserName 

		MsUnLock()

		DbSelectArea("ZC2")
		DbSetOrder(1)

		nNumItem := 1  // Contador para os Itens   

		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				If DbSeek(xFilial("ZC2") + M->ZC1_NUM + StrZero(nIt,3))			
					RecLock("ZC2",.F.)
					DbDelete()
					MsUnlock()
				Endif
			Endif
		Next nIt       

		For nIt := 1 To Len(aCols)		
			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

				If DbSeek(xFilial("ZC2")+ M->ZC1_NUM + StrZero(nIt,3))
					RecLock("ZC2",.F.)
				Else
					RecLock("ZC2",.T.)
				Endif						  

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"
						ZC2->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				ZC2->ZC2_FILIAL		:= xFilial("ZC2")
				ZC2->ZC2_NUMTAB	 	:= ZC1->ZC1_NUM                           //Atribui o numero do PP ao item
				ZC2->ZC2_NUMITE    	:= strzero(nNumItem,3)
				ZC2->ZC2_MONITO    	:= cUserName 			

				if ALTERA
					ZC2->ZC2_USERAL := cUserName                          //Grava o nome do usuario
					if alltrim(ZC2->ZC2_USERIN) == ''
						ZC2->ZC2_USERIN := cUserName
					endif
				else
					ZC2->ZC2_USERIN  := cUserName
				endif

				nNumItem++			
				MsUnlock()

				DbSelectArea('ZC2')
			Endif
		Next nIt

	End Transaction

Return lGraOk




//Visualiza Pré-Pedidos de Venda

User Function dti24Visu(cAlias,nReg,nOpc)
	Local oDlg		:= NIL
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL


	area := GetArea()
	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZC1")
	dti24Ahead("ZC2")                                                           //Monta oa vetor aHeader
	nUsado := Len(aHeader)

	dti24Acols(nOpc)															//Monta oa vetor aCols

	oEnc    := MsMGet():New("ZC1" ,ZC1->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZC2_NUMITE",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, , )

	RestArea(area)


Return        


//Monta oa aHeader
Static Function dti24Ahead(cAlias)

	Local i
	aHeader := {}   

	//DbSelectArea("SX3")
	//DbSetOrder(1) 
	//DbSeek(cAlias)
	//Do While !Eof() .and. (X3_ARQUIVO == cAlias)  
	//	If at(Upper(AllTrim(X3_CAMPO)), "ZC2_FILIAL ZC2_NUMITE") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++		
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := cAlias 			// ZC2
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 			 	 .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZC2_FILIAL" .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZC2_NUMITE")

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
Static Function dti24Acols(nOpc) 
	Local nI, nPos
	//alert(nOpc)
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

		aCols[1,nUsado+1] := .F.	

	else    
		//alert("00468")
		RegToMemory("ZC1",.T.)	
		dbSelectArea("ZC2")

		ZC2->(dbsetorder(2))
		ZC2->(dbGoTop())
		//if ZC2->(dbSeek(xfilial('ZC2') + alltrim(M->ZC1_NUM)))

		While ZC2->(!Eof()) .and. xFilial('ZC2') == ZC2->ZC2_FILIAL //.and. alltrim(ZC2->ZC2_NUMTAB) == alltrim(M->ZC1_NUM)

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
			ZC2->(DbSkip())

		Enddo					
		//Endif
	endif
	//alert("497")
Return


//Disponibiliza a legenda
User Function dti24Leg(cAlias,nReg,nOpc)
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return

//Alteração de Planilha de Controle de Temperatura
User Function desdti24Alt(cAlias,nReg,nOpc)

	Local oDlg		    := NIL
	Local lOk 		    := .F.
	Local aCposAlt	    := {}
	Local aButtons	    := {}
	Local _cCodigo      := ''
	Private aHeader	    := {}
	Private aCols	    := {}
	Private nUsado	    :=	0
	Private oGet	    := NIL
	Private aGets	    := {}
	Private aTela	    := {}

	DbSelectArea(cAlias)

	//VERIFICAR POSSIBILIDADE DE ALTERAÇÃO DO PRE-PEDIDO
	if ZC1->ZC1_STATUS == 'A' 
		msgbox('Status não permite Alteração da Planilha!','OPERAÇÃO NEGADA!','STOP')
		return
	endif

	if ZC1->ZC1_RESP = cUserName .OR. alltrim(_vMenu) $ alltrim(cUserName)
		//alert(" Mesmo usuário, pode prosseguir !!")
	Else
		msgbox('Usuário logado não permite Alteração neseta Planilha!','OPERAÇÃO NEGADA!','STOP')
		return
	Endif


	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := dti24Ahead("ZC2")                                                 //Monta o aHeader
	dti24Acols(nOpc)                                                            //Monta o Acols

	RegtoMemory('ZC1',.F.)// alteração

	oEnc := MsMGet():New("ZC1" ,ZC1->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_dti24LinOk(n,'A')","u_dti24TudOk","+ZC2_NUMITE",.T., , ,.F. ,20 ,,,,"u_dti24Vdl")


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_dti24TudOk().and.u_dti24LinOk(n,'A').and.;
	Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(), odlg:refresh())}, {||oDlg:End()}, , aButtons)
	// Gravar campo que nao pode ser alterado
	_VERIF := ZC1->ZC1_VERIF
	//_VERIF := ZC1->ZC1_DATCRI

	dti24Grav(nOpc)

Return



//Função criada para validação de exclusão de linha na rotina de
//alterar Planilha de Controle de Temperatura
User Function dti24Vdl()
	local ret    := .t.
	local	RCaix  := 0
	local	RPeso  := 0

	//RCaix := FBuscaCPO('ZZ5',1,xfilial('ZZ5')+M->ZZ4_NUM + StrZero(n,3),'ZZ5_QRCAIX')
	//RPeso := FBuscaCPO('ZZ5',1,xfilial('ZZ5')+M->ZZ4_NUM + StrZero(n,3),'ZZ5_QRPESO')


	// Inclusão de while para contagem de linhas na ZC2
	//if RCaix <> 0 .or. RPeso <> 0
	msgbox('Exclua todas as caixas deste item do carregamento para exclui-lo.','ITEM PARCIALMENTE ATENDIDO!','STOP')
	ret := .f.
	//endif

Return ret           

//Exclusão dos Lançamentos
User Function dti24Dele()


	dbSelectArea("ZC1")
	ZC1->(dbsetorder(1))
	ZC1->(dbGoTop())  


	if ZC1->(dbSeek(xfilial('ZC1') + alltrim(M->ZC1_NUM)))

		While ZC1->(!Eof()) .and. xFilial('ZC1') == ZC1->ZC1_FILIAL .and. alltrim(ZC1->ZC1_NUM) = alltrim(M->ZC1_NUM)

			reclock('ZC1',.f.)
			dbDelete()
			msunlock()		
			ZC1->(dbSkip())

		enddo

		dbSelectArea("ZC2")
		ZC2->(dbsetorder(2))
		ZC2->(dbGoTop())

		if ZC2->(dbSeek(xfilial('ZC2') + alltrim(M->ZC1_NUM) ))

			While ZC2->(!Eof()) .and. xFilial('ZC2') == ZC2->ZC2_FILIAL .and. alltrim(ZC2->ZC2_NUMTAB) = alltrim(M->ZC1_NUM)

				reclock('ZC2',.f.)
				dbDelete()
				msunlock()

				ZC2->(dbSkip())

			enddo

		Endif


	endif


Return


//Exclusão dos produtos alternativos
User Function dti24Exc(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL


	if ZC1->ZC1_STATUS == 'A' .or. ZC1->ZC1_STATUS == 'B'    //Verifica o status da Planilha para exclusão
		msgbox('Status não permite exclusão da Planilha!','OPERAÇÃO NEGADA!','STOP')
		return .f.
	endif


	DbSelectArea(cAlias)
	area := GetArea()

	RegToMemory("ZC1")

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL


	EnChoice( "ZC1" ,ZC1->(RECNO()), 2, , , , , aPosObj[1], , 3 )
	dti24Ahead("ZC2")


	nUsado	:= Len(aHeader)                                                           //Monta o aHeader

	dti24Acols(nOpc)                                                                  //Monta o Acols

	oGet:= MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||dti24Dele(),oDlg:End()},{||oDlg:End()},)

	DbSelectArea('ZC1')
	RestArea(area)

Return   


//Exclusão dos produtos alternativos
User Function dti24ver(cAlias,nReg,nOpc)     

	Local lOk 		:= .F.
	Local aCposAlt	:= {}
	Local aButtons	:= {}
	Local _cCodigo := '' 
	Local oDlg		:= NIL 
	Private aGets	:= {}
	Private aTela	:= {}
	Private aHeader:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL   

	area := GetArea()
	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZC1")
	dti24Ahead("ZC2")                                                           //Monta oa vetor aHeader
	nUsado := Len(aHeader)

	dti24Acols(nOpc)															//Monta oa vetor aCols

	oEnc    := MsMGet():New("ZC1" ,ZC1->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_dti24LinOk(n,'A')","u_dti24TudOk","+ZC2_NUMITE",.T., , ,.F. ,20 ,,,,"u_dti24Vdl")

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_dti24TudOk().and.u_dti24LinOk(n,'A').and.;
	Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(), odlg:refresh())}, {||oDlg:End()}, , aButtons)

	_VERIF := ZC1->ZC1_VERIF
	//_VERIF := ZC1->ZC1_DATCRI

	dti24Grav(nOpc)

	/* 

	if ZC1->ZC1_STATUS == 'A' 
	msgbox('Status não permite Alteração da Planilha!','OPERAÇÃO NEGADA!','STOP')
	return
	endif


	Importado do gjf31 
	DbSelectArea('ZC0')
	ZC0->(DbSetOrder(1)) 

	_cMemo := '' 
	if ZZ3->ZZ3_STATUS <> 'F'
	if msgbox('Deseja registra evento? (S/N)','REGISTRO DE EVENTO','YESNO')
	@ 116,010 To 325,425 Dialog oDlgMemo Title "Registro de Evento"
	@ 001,002 SAY _cEvento
	@ 020,005 Get _cMemo Size 200,040 MEMO Object oMemo  
	@ 090,010 BMPBUTTON TYPE 1 ACTION oDlgMemo:end() Object Obtn1
	@ 090,040 BMPBUTTON TYPE 2 ACTION (_cMemo := '',oDlgMemo:end()) Object Obtn2
	Activate Dialog oDlgMemo CENTERED
	endif
	endif                                          



	_cNumHist := GETSX8NUM('ZC0','ZC0_NUM')                                                                                                      
	confirmSX8()     

	reclock('ZC0',.t.)
	ZC0->ZC0_NUM     := _cNumHist  
	ZC0->ZC0_FILIAL  := xfilial('ZC0')
	ZC0->ZC0_STATUS  := ZZ3->ZZ3_STATUS
	ZC0->ZC0_PRECAR  := ZZ3->ZZ3_NUM
	ZC0->ZC0_DATA    := date()
	ZC0->ZC0_HORA    := time()
	ZC0->ZC0_OPER    := cUserName
	ZC0->ZC0_EVENTO  := _cEvento
	ZC0->ZC0_HIST    := _cMemo
	ZC0->ZC0_STPCK   := _stPck
	msunlock('ZC0')

	DbClosearea('ZC0')

	*/

	/* Incluir o encerramento    
	Para encerrar alterar o Status


	*/


Return   


User Function dti24Alt(cAlias,nReg,nOpc) 
	alert('Nova Função')
Return
