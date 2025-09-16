#INCLUDE "topconn.ch"   
#INCLUDE "tbiconn.ch"                                                                                                              
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"   
#INCLUDE "MATA380.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF141    ºAutor  ³Giuliano Forgiarini º Data ³  02/05/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gerenciamento de Distribuição de Carçacas                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF141()

	lOk := .f.
	aObjects := {}                                             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 :=  "ZZB->ZZB_STATUS = 'A' .and. ZZB->ZZB_FILIAL = '" + xfilial('ZZB')+"'"
	bLegenda2 :=  "ZZB->ZZB_STATUS = 'P' .and. ZZB->ZZB_FILIAL = '" + xfilial('ZZB')+"'"
	bLegenda3 :=  "ZZB->ZZB_STATUS = 'E' .and. ZZB->ZZB_FILIAL = '" + xfilial('ZZB')+"'"

	aCores2:= { { 'BR_VERDE'   ,'Aberta'   },;
	{ 'BR_AMARELO' ,'Em produção'},;
	{ 'BR_VERMELHO','Encerrada'}}

	aCores := { {bLegenda1, 'BR_VERDE'    },;
	{bLegenda2, 'BR_AMARELO'  },;
	{bLegenda3, 'BR_VERMELHO' }}
	// aberto                                     fechado                    iniciada

	Private cPerg   := "GJF141"
	Private cCadastro := "Gerenciamento de Distribuição de Carcaças"
	Private aRotina := { {"Pesquisar"   ,"AxPesqui"   ,0,1} ,;
	{"&Visualizar" ,"AxVisual"   ,0,2} ,;
	{"Resumo"      ,"u_gjf141r"  ,0,2} ,;
	{"Processa"    ,"u_GJF140"   ,0,3} ,;
	{"&Alterar"    ,"u_gjf141a"  ,0,4} ,;
	{"En&cerrar"   ,"u_gjf141e"  ,0,4} ,;
	{"E&xcluir"    ,"u_gjf141d"  ,0,5} ,;
	{"Limpeza "    ,"u_GJF138"   ,0,5} ,;
	{"Legenda"     ,"u_gjf141l"  ,0,2}}
	/*
	if !pergunte(cPerg,.t.)
	return
	endif
	*/
	dbSelectArea("ZZB")
	ZZB->(dbsetorder(1))

	mBrowse(6,1,22,75,"ZZB", ,,,,2    ,aCores,,,,{|x| AutoRefresh(x)}) 

	DbCloseArea("ZZB")   

return

//ALTERAÇÃO DISTRIBUIÇÃO DE CARCAÇAS
User Function gjf141a()  
	Local nCont
	if ZZB->ZZB_STATUS = 'E'
		Alert("Distribuição com produção já encerrada!")
		return
	endif


	DEFINE MSDIALOG oDlg TITLE 'Gerenciamento de Distribuição de Carcaças' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZB",.F.)

	obj := MsMGet():New("ZZB" ,ZZB->(RECNO()),4   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gjf141y()},{||gjf141n()}, ,)

	If lOk
		recLock('ZZB',.F.)
		// Grava previsao de producao
		For nCont := 1 To FCount()
			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("ZZB"))
			Else
				FieldPut(nCont,M->&(FIELDNAME(nCont)))
			Endif
		Next nCont
		MsUnLock()
	endif

return

//EXCLUSÃO DA DISTRIBUIÇÃO DE CARCAÇAS
User Function gjf141d()  

	if ZZB->ZZB_STATUS = 'E'
		Alert("Distribuição com produção já encerrada!")
		return
	endif

	DEFINE MSDIALOG oDlg TITLE 'Gerenciamento de Distribuição de Carcaças' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZB",.F.)

	obj := MsMGet():New("ZZB" ,ZZB->(RECNO()),5   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gjf141y()},{||gjf141n()}, , )

	If lOk
		recLock('ZZB',.F.)
		DbDelete()
		MsUnLock()
	endif

return


//ENCERRA A DISTRIBUIÇÃO DE CARCAÇAS
User Function gjf141e()
	if msgbox('ENCERRAMENTO DE DISTRIBUIÇÃO','Deseja realmente encerrar esta distribuição?','YESNO')
		reclock('ZZB',.f.)
		ZZB->ZZB_STATUS := 'E'
		msunlock()
	endif
return .t.

static function gjf141y()
	lOk := .t.
	Odlg:end()
Return lOk


static function gjf141n()
	lOk := .f.
	Odlg:end()
Return


user Function gjf141l()
	BrwLegenda('Previsão de Produção',"Legenda",aCores2)
return 

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


