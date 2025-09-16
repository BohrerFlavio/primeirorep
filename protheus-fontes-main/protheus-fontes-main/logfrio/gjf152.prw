#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF152     ºAutor  ³Giuliano Forgiarini º Data ³  24/09/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualização do saldo de estoque em poder da LogFrio       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF152()

	lOk := .f.
	aObjects := {}                                             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )


	Private cCadastro := "Calculo de Saldo - LogFrio"
	Private aRotina := { {"Pesquisar"   ,"AxPesqui"  ,0,1} ,;
	{"&Visualizar" ,"AxVisual"  ,0,2} ,;  
	{"&Incluir"    ,"AxInclui"  ,0,3} ,;      
	{"&Calcular"   ,"u_GJF153"  ,0,3} ,;
	{"&Arquivo"    ,"u_GJF154"  ,0,3} ,;
	{"&Alterar"    ,"AxAltera"  ,0,4} ,;       
	{"&Excluir"    ,"AxExclui"  ,0,5}}

	Private cString := "ZZN" 

	dbSelectArea(cString)
	ZZN->(dbsetorder(1))

	SetKey(123,{|| AlterData()}) 

	mBrowse(6,1,22,75,cString, ,,,,2,,,,,) 

	DbCloseArea('ZZN')   

	Set Key 123 to

return





