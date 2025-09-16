#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF119    ºAutor  ³Giuliano Forgiarini º Data ³  10/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±ºDesc.     ³ Rotina de cadastro de usuários do Portal do Vendedor        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial - Frigorifico Silva                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF119()

	lOk := .f.
	Private aRotina  := {}
	Private aCores   := {}  

	aObjects := {}                                            // dimensao janelas
	aPosObj  := {}
	aInfo    := {}

	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 :=  "ZZJ->ZZJ_STATUS == 'L'"
	bLegenda2 :=  "ZZJ->ZZJ_STATUS == 'B'"

	aCores :=     { { bLegenda1, 'BR_VERDE'     },;
	{ bLegenda2, 'BR_AZUL'      }}

	Private cCadastro := "Carregamentos"
	Private aRotina := { {"Pesquisar"  ,"AxPesqui"   ,0,1} ,;  
	{"Visualizar" ,"AxVisual"   ,0,2} ,;
	{"Incluir"    ,"u_gjf119i"  ,0,3} ,;
	{"Alterar"    ,"AxAltera"   ,0,4} ,;  
	{"Excluir"    ,"AxDeleta"   ,0,5}}

	dbSelectArea("ZZJ")
	ZZJ->(dbSetOrder(1))
	ZZJ->(dbgotop())

	mBrowse(6,1,22,75,'ZZJ', ,,,,1     ,aCores,,,,) 
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores     

	DbCloseArea('ZZJ')   

Return


User Function gjf119i()
	Local nCont
	lOk := .f.                       

	DEFINE MSDIALOG oDlg TITLE 'Usuários Portal do Vendedor' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("ZZJ",.T.)
	obj := MsMGet():New("ZZJ" ,ZZJ->(RECNO()),3   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )
	// inst.  obj.     met. alias,registro      ,oper,p.res,p.res,p.res,vet.campos,vet.coord.,vet.campos.alt, ,
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gjf119ok()},{||gjf119nok()})

	If lOk
		begin transaction
			recLock('ZZJ',.T.)
			// Grava pré-carregamento
			For nCont := 1 To FCount()
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,xFilial("ZZJ"))
				Else
					FieldPut(nCont,M->&(FIELDNAME(nCont)))
				Endif
			Next nCont
			ConfirmSx8()
			MsUnLock()
		end transaction
	else
		RollBackSx8()
	endif

return


static function gjf119ok()
	lOk := .t.
	oDlg:end()
return lOk

static function gjf119nok()
	lOk := .f.
	Odlg:end()
Return lOk
