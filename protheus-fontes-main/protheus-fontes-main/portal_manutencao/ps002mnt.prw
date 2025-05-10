#INCLUDE "PROTHEUS.CH"

//CADASTRO DE MÁQUINAS - TABELA ZP3
//Silva 

User Function PS002MNT()

	PRIVATE cCadastro  := "Cadastro de Máquinas - Tabela ZP3"
	PRIVATE aRotina     := {}

	AxCadastro("ZP3", OemToAnsi(cCadastro), 'Allwaystrue()')

Return
