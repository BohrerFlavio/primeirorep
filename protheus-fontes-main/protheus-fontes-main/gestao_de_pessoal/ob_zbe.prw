#INCLUDE "rwmake.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*
Cadastro de líderes
*/

User Function OB_ZBE()

	Local aCores     := {}
	Private _lOk := .F.

	if !SM0->M0_CODIGO $ "01"
		MsgAlert("Rotina não disponível para essa empresa.")
		return
	endif

	Private aRotina  := MenuDef()
	Private cCadastro := "Cadastro de líderes"
	
	Dbselectarea("ZBE")
	dBSetOrder(1)
	if DbSeek(xFilial("ZBE")+RetCodUsr(), .T.)
		if ZBE->ZBE_TIPO <> '2'
			MsgAlert("Somente líderes do tipo DP podem acessar esta rotina, verifique.")
			return
		endif
		if ZBE->ZBE_ATIVO <> '1'
			MsgAlert("Somente líderes ativos podem acessar esta rotina, verifique.")
			return
		endif
	else
		MsgAlert("Usuário não cadastrado nos líderes, acesso não permitido.")
		return
	endif
	
	Dbselectarea("ZBE")
	dBSetOrder(1)
	DbGoTop()

	aCores := {{"ZBE_ATIVO=='2' ",'BR_AMARELO'},;
	{"ZBE_ATIVO=='1' ",'ENABLE'}}

	MBrowse( 06, 01, 22, 75,"ZBE",,,,,,aCores,,,,,.F.,,,)

Return

Static Function MenuDef()
	Local aRetorno:= {{ "Legenda"          , "U_OB_ZBELEG"    , 0, 2, 0, NIL},;  //"Legenda"
	{ "Visualizar"         ,"AxVisual" , 0, 2, 0, NIL},;
	{ "Incluir   "         ,"AxInclui" , 0, 3, 0, NIL},;
	{ "Alterar"            ,"AxAltera" , 0, 4, 0, NIL},;
	{ "Excluir"            ,"AxDeleta" , 0, 5, 0, NIL}}

Return aRetorno

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³legenda														 ³
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
user function OB_ZBELEG ()

	BrwLegenda (cCadastro, "Legenda", {{"BR_VERMELHO"   , "Desativado" },;
	{"BR_VERDE"    , "Ativo" }})

Return()
