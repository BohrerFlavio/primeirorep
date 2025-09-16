#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FFM02       ºAutor  ³Fabian Maurer º Data ³  26/04/2012     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±ºDesc.   ³ Rotina de Cadastro de Codigo de Tara Primaria e Secundaria    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso     ³ Planejamento e Controle de Producao - Frigorifico Silva      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FFM02()

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


	Private cCadastro := "Cadastro de Taras"             
	Private aRotina := { {"Pesquisar"  ,"AxPesqui"  ,0,1} ,;  
	{"Visualizar" ,"AxVisual"  ,0,2} ,;
	{"Incluir"    ,"u_FFM02i"  ,0,3} ,;
	{"Alterar"    ,"AxAltera"  ,0,4} ,;  
	{"Excluir"    ,"AxDeleta"  ,0,5}}

	dbSelectArea("ZAB")
	ZZJ->(dbSetOrder(1))
	ZZJ->(dbgotop())

	mBrowse(6,1,22,75,'ZAB', ,,,,1     ,aCores,,,,) 
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores     

	DbCloseArea('ZAB')   

Return


User Function FFM02i()
	Local nCont
	lOk := .f.                       

	DEFINE MSDIALOG oDlg TITLE 'Cadastro de Taras' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("ZAB",.T.)
	obj := MsMGet():New("ZAB" ,ZAB->(RECNO()),3   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )
	// inst.  obj.     met. alias,registro      ,oper,p.res,p.res,p.res,vet.campos,vet.coord.,vet.campos.alt, ,
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||FFM02ok()},{||FFM02nok()})

	If lOk
		begin transaction
			recLock('ZAB',.T.)
			For nCont := 1 To FCount()
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,xFilial("ZAB"))
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


static function FFM02ok()
	lOk := .t.
	oDlg:end()
return lOk

static function FFM02nok()
	lOk := .f.
	Odlg:end()
Return lOk

//Validação do campo da tara P              
User Function ffm02vlp(_cod)
	Local _ret := .T.

	if cEmpAnt <> '01'
		return _ret
	endif

	If M->B1_TIPO <> 'PA'
		Return _ret
	Elseif !(M->B1_SEGUM $ 'CX/SC')
		Return _ret
	Endif

	ZAB->(Dbsetorder(1))
	If ZAB->(Dbseek(xfilial('ZAB')+_cod))
		If ZAB->ZAB_TIPO <> 'P'   
			Alert('Tipo de tara inválida!')
			_ret := .F.
		Endif
	else
		_ret := .T.
	Endif

Return _ret 

//Validação do campo da tara S              
User Function ffm02vls(_cod)
	Local _ret := .T.

	If M->B1_TIPO <> 'PA'
		Return _ret
	Elseif !(M->B1_SEGUM $ 'CX/SC')
		Return _ret
	Endif

	ZAB->(Dbsetorder(1))
	If ZAB->(Dbseek(xfilial('ZAB')+_cod))
		If ZAB->ZAB_TIPO <> 'S'
			Alert('Tipo de tara inválida!')
			_ret := .F.
		Endif
	else
		_ret := .T.
	Endif

Return _ret                               
