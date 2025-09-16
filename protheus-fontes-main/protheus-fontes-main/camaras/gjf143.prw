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
±±ºPrograma  ³GJF143    ºAutor  ³Giuliano Forgiarini º Data ³  07/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro do endereço de localizações físicas das camaras   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF143()

	Private lOk := .f.
	aObjects := {}                                             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )


	Private cCadastro := "Endereços Físicos de Estocagem em Camaras"
	Private aRotina := { {"Pesquisar"   ,"AxPesqui"   ,0,1} ,;
	{"&Visualizar" ,"AxVisual"   ,0,2} ,;
	{"&Incluir"    ,"u_gjf143i"  ,0,3} ,;
	{"&Alterar"    ,"u_gjf143a"  ,0,4} ,;
	{"E&xcluir"    ,"u_gjf143e"  ,0,5}}


	dbSelectArea('ZZH')
	ZZH->(dbsetorder(1))

	mBrowse(6,1,22,75,'ZZH', ,,,,2,,,,,) 

	DbCloseArea('ZZH')   

return

//INCLUSAO
user function gjf143i()
	Local nCont
	DEFINE MSDIALOG oDlg TITLE 'Endereços Físicos de Estocagem em Camaras' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZH",.T.) 


	obj := MsMGet():New("ZZH" ,ZZH->(RECNO()),3,,,,,aPosObj[1],,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||conf()},{||canc()}) 
	If lOk    
		ConfirmSX8()

		recLock('ZZH',.T.)
		// Grava previsao de producao
		For nCont := 1 To FCount()
			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("ZZH"))
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
User Function gjf143a()  

	Local nCont
	DEFINE MSDIALOG oDlg TITLE 'Endereços Físicos de Estocagem em Camaras' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZH",.F.)

	obj := MsMGet():New("ZZH" ,ZZH->(RECNO()),4   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||Conf()},{||Canc()})

	If lOk
		recLock('ZZH',.F.)
		// Grava previsao de producao
		For nCont := 1 To FCount()
			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("ZZH"))
			Else
				FieldPut(nCont,M->&(FIELDNAME(nCont)))
			Endif
		Next nCont
		MsUnLock()
	endif

return


//EXCLUSAO
User Function gjf143e()  


	DEFINE MSDIALOG oDlg TITLE 'Endereços Físicos de Estocagem em Camaras' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZH",.F.)

	obj := MsMGet():New("ZZH" ,ZZH->(RECNO()),5   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||Conf()},{||Canc()})

	If lOk
		recLock('ZZH',.F.)
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


User Function gjf143d()
	local desc

	desc := M->(ZZH_LOCAL + ZZH_RUA + ZZH_PREDIO + ZZH_ANDAR + ZZH_APTO)

return desc
