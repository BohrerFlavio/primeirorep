#INCLUDE "topconn.ch"   
#INCLUDE "tbiconn.ch"                                                                                                              
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF139    ºAutor  ³Giuliano Forgiarini º Data ³  30/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Regras de distribuição de carcaças para desossa            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF139()

	Private lOk := .f.
	aObjects := {}                                             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 :=  "ZZ8->ZZ8_STATUS = 'A' .and. ZZ8->ZZ8_FILIAL = '" + xfilial('ZZ8')+"'"
	bLegenda2 :=  "ZZ8->ZZ8_STATUS = 'D' .and. ZZ8->ZZ8_FILIAL = '" + xfilial('ZZ8')+"'"

	aCores2:= { { 'BR_VERDE'    ,'Ativada'   },;
	{ 'BR_VERMELHO' ,'Desativada'}}   

	aCores := { {bLegenda1, 'BR_VERDE'},{ bLegenda2, 'BR_VERMELHO'}}

	Private cCadastro := "Regras de distribuição de carcaças - Embalagem"
	Private aRotina := { {"Pesquisar"   ,"AxPesqui"   ,0,1} ,;
	{"&Visualizar" ,"AxVisual"   ,0,2} ,;
	{"&Incluir"    ,"u_gjf139i"  ,0,3} ,;
	{"&Alterar"    ,"u_gjf139a"  ,0,4} ,;
	{"E&xcluir"    ,"u_gjf139e"  ,0,5} ,;
	{"Ativar"      ,"u_gjf139t"  ,0,4} ,;
	{"Desativar"   ,"u_gjf139d"  ,0,4} ,;
	{"Legenda"     ,"u_gjf139l"  ,0,2}}


	dbSelectArea('ZZ8')
	ZZ8->(dbsetorder(1))

	mBrowse(6,1,22,75,'ZZ8', ,,,,2,aCores,,,,{|x| AutoRefresh(x)}) 

	DbCloseArea('ZZ8')   

return

//INCLUSAO
user function gjf139i()
	Local nCont
	DEFINE MSDIALOG oDlg TITLE 'Regras de distribuição de carcaças' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZ8",.T.) 

	M->ZZ8_STATUS := 'D'  

	obj := MsMGet():New("ZZ8" ,ZZ8->(RECNO()),3,,,,,aPosObj[1],,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||conf()},{||canc()}) 
	If lOk    
		ConfirmSX8()

		recLock('ZZ8',.T.)
		// Grava previsao de producao
		For nCont := 1 To FCount()
			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("ZZ8"))
			Else
				FieldPut(nCont,M->&(FIELDNAME(nCont)))
			Endif
		Next nCont

		MsUnLock()
	else
		RollBackSx8()
	endif
return

//ALTERAÇÃO
User Function gjf139a()  

	Local nCont
	DEFINE MSDIALOG oDlg TITLE 'Previsão de Gerenciamento de Producao' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZ8",.F.)

	obj := MsMGet():New("ZZ8" ,ZZ8->(RECNO()),4   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||Conf()},{||Canc()})

	If lOk
		recLock('ZZ8',.F.)
		// Grava previsao de producao
		For nCont := 1 To FCount()
			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("ZZ8"))
			Else
				FieldPut(nCont,M->&(FIELDNAME(nCont)))
			Endif
		Next nCont
		MsUnLock()
	endif

return


//EXCLUSAO
User Function gjf139e()  


	DEFINE MSDIALOG oDlg TITLE 'Previsão de Gerenciamento de Producao' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZ8",.F.)

	obj := MsMGet():New("ZZ8" ,ZZ8->(RECNO()),5   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||Conf()},{||Canc()})

	If lOk
		recLock('ZZ8',.F.)
		Dbdelete()
		MsUnLock()
	endif

return

static function Conf() //Verifica se existe campos em branco  
	lOk := .t.
	Odlg:end()
Return lOk


static function Canc()
	lOk := .f.
	Odlg:end()
Return

user Function gjf139l()
	BrwLegenda('Status das regras',"Legenda",aCores2)
return 


//ATIVA A DISTRIBUIÇÃO DE CARCAÇAS
User Function gjf139t()  
	local area := getarea()
	if ZZ8->ZZ8_STATUS <> 'A'
		reclock('ZZ8',.f.)
		ZZ8->ZZ8_STATUS := 'A'
		msunlock() 
		if eof()
			DbGoBottom()
		endif	
	endif   
	restarea(area)
return .t.

//ATIVA A DISTRIBUIÇÃO DE CARCAÇAS
User Function gjf139d() 

	local area := getarea()

	if ZZ8->ZZ8_STATUS <> 'D'
		reclock('ZZ8',.f.)
		ZZ8->ZZ8_STATUS := 'D'
		msunlock() 
		if eof()
			DbGoBottom()
		endif
	endif  

	restarea(area)
return .t.

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

