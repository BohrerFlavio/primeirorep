#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF148    ºAutor  ³Giuliano Forgiarini º Data ³  02/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±ºDesc.     ³ Rotina de cadastro de usuários de coletores de dados        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Abate/camaras - Frigorifico Silva                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF148()

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

	bLegenda1 :=  "ZAA->ZAA_STATUS == 'L'"
	bLegenda2 :=  "ZAA->ZAA_STATUS == 'B'"

	aCores :=     { { bLegenda1, 'BR_VERDE'     },;
	{ bLegenda2, 'BR_AZUL'      }}

	Private cCadastro := "Carregamentos"
	Private aRotina := { {"Pesquisar"  ,"AxPesqui"   ,0,1} ,;  
	{"Visualizar" ,"AxVisual"   ,0,2} ,;
	{"Incluir"    ,"u_gjf148i"  ,0,3} ,;
	{"Alterar"    ,"AxAltera"   ,0,4} ,;  
	{"Excluir"    ,"AxDeleta"   ,0,5}}

	dbSelectArea("ZAA")
	ZAA->(dbSetOrder(1))
	ZAA->(dbgotop())

	mBrowse(6,1,22,75,'ZAA', ,,,,1     ,aCores,,,,) 
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores     

	DbCloseArea('ZAA')   

Return


User Function gjf148i()
	Local ncont
	lOk := .f.                       

	DEFINE MSDIALOG oDlg TITLE 'Usuários de Coletores de Dados' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("ZAA",.T.)
	obj := MsMGet():New("ZAA" ,ZAA->(RECNO()),3   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )
	// inst.  obj.     met. alias,registro      ,oper,p.res,p.res,p.res,vet.campos,vet.coord.,vet.campos.alt, ,
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gjf148ok()},{||gjf148nok()})

	If lOk
		begin transaction
			recLock('ZAA',.T.)
			// Grava pré-carregamento
			For nCont := 1 To FCount()
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,xFilial("ZAA"))
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


static function gjf148ok()
	lOk := .t.
	oDlg:end()
return lOk

static function gjf148nok()
	lOk := .f.
	Odlg:end()
Return lOk
