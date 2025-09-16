#INCLUDE "protheus.ch"

user function ob_zd2()
	PRIVATE  aRotina     := {}
	private CCADASTRO  := "Notificacoes"

	//AxCadastro("ZD2","Notificacoes",".T.",".T.")

	AADD(aRotina, { "Pesquisar"       , "AxPesqui"    , 0, 1 })           
	AADD(aRotina, { "Visualizar"      , "AxVisual"    , 0, 2 })
	AADD(aRotina, { "Incluir"         , "AxInclui"    , 0, 3 })
	AADD(aRotina, { "Alterar"         , "AxAltera"    , 0, 4 })
	AADD(aRotina, { "Excluir"         , "axDeleta"    , 0, 5 })
	AADD(aRotina, { "Assin Notif."    , 'u_ob_ZD2TER' , 0, 7 })
	AADD(aRotina, { "Rel. Notif."     , "u_ob_ZD2REL" , 0, 8 })

	MBrowse( 06, 01, 22, 75,"ZD2",,,,,2,)

Return(.T.)

user function ob_zd3()

	PRIVATE  aRotina     := {}

	AxCadastro("ZD3","Tipos de Notificacoes",".T.",".T.")

return
