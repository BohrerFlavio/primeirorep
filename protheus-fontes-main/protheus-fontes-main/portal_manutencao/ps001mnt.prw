#INCLUDE "PROTHEUS.CH"

//CADASTRO DE MÁQUINAS - TABELA ZP1
//Silva 

User Function PS001MNT()

	PRIVATE cCadastro  := "Cadastro de Usuarios Portal - Tabela ZP1"
	PRIVATE aRotina     := {}

	AxCadastro("ZP1", OemToAnsi(cCadastro), 'Allwaystrue()')

Return
