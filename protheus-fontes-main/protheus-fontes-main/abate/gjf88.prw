#INCLUDE "rwmake.ch"           
#INCLUDE "protheus.ch"           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF88     º Autor Giuliano Forgiarini    Data ³  01/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao: Manutenção da tabela SA1: cadastro de clienes               º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF88()

	Private cPerg   := "GJF88"
	Private cCadastro := "Manutenção Parcial do Cadastro de Clientes"

	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
	{"Visualizar","AxVisual",0,2} ,;
	{"Alterar ","u_gjf88alt",0,4} }

	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "SA1"

	dbSelectArea("SA1")
	dbSetOrder(1)

	mBrowse(6,1,22,75,cString,,)

	dbSelectArea(cString)

	//Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros
Return  

User Function gjf88alt()
	campo1  := space(100)
	campo2  := space(15)
	campo3  := space(03)
	campo4  := space(06)
	campo5  := space(06)
	campo6  := 00.00
	campo7  := 00.00
	campo8  := space(18)
	valor1  := SA1->A1_EMAIL
	valor2  := SA1->A1_TEL
	valor3  := SA1->A1_TABELA
	valor4  := SA1->A1_SATIV1
	valor5  := SA1->A1_GRPVEN
	valor6  := SA1->A1_PLOGIST
	valor7  := SA1->A1_PVBAEXT
	valor8  := SA1->A1_INSCR
	_cUsers := GetMV('SI_ALTABPR')
	_Usr    := RetCodUsr()

	DEFINE MSDIALOG tela FROM 0,0 TO 300,250 PIXEL TITLE "Alterar Cadastro"

	@ 01,01 SAY "E-Mail:     "      of tela 
	@ 02,01 SAY "Fone:       "      of tela 
	If _Usr $ _cUsers
		@ 03,01 SAY "Tabela:     " 	   of tela
	else
	Endif
	@ 04,01 SAY "Segmento 1:   " of tela
	@ 05,01 SAY "Grupo Client: " of tela
	@ 06,01 SAY "% Logistica : " of tela
	@ 07,01 SAY "% Verba Extr: " of tela
	@ 08,01 SAY "Inscri. Estad:" of tela

	@ 12,45 MSGET campo1 VAR valor1 SIZE 80,10 OF tela PIXEL PICTURE "@E"
	@ 24,45 MSGET campo2 VAR valor2 SIZE 40,10 OF tela PIXEL PICTURE "@E"
	//@ 36,40 MSGET campo3 VAR valor3 SIZE 20,10 OF tela PIXEL PICTURE "@E" F3 "DA0"  VALID (_Usr $ _cUsers)
	If _Usr $ _cUsers
		@ 36,45 MSGET campo3 VAR valor3 SIZE 20,10 OF tela PIXEL PICTURE "@E" F3 "DA0"
	else
		//@ 36,45 MSGET campo3 VAR valor3 SIZE 20,10 OF tela PIXEL PICTURE "@E" F3 "DA0"
		//@ 36,45 say valor3  OF tela 
	Endif
	@ 49,45 MSGET campo4 VAR valor4 SIZE 20,10 OF tela PIXEL PICTURE "@E" F3 "T3"
	@ 61,45 MSGET campo5 VAR valor5 SIZE 20,10 OF tela PIXEL PICTURE "@E" F3 "ACY
	@ 73,45 MSGET campo6 VAR valor6 SIZE 20,10 OF tela PIXEL PICTURE "@E 99.99"
	@ 85,45 MSGET campo7 VAR valor7 SIZE 20,10 OF tela PIXEL PICTURE "@E 99.99"
	@ 99,45 MSGET campo8 VAR valor8 SIZE 50,10 OF tela PIXEL PICTURE "@E"
	@ 125,05 BUTTON botao1 PROMPT "Salvar" OF tela PIXEL ACTION u_gjf88_1()
	@ 125,65 BUTTON botao2 PROMPT "Fechar" OF tela PIXEL ACTION tela:end()

	ACTIVATE MSDIALOG tela CENTERED
Return 

user function gjf88_1()
	reclock('SA1',.f.)
	SA1->A1_EMAIL   := valor1  
	SA1->A1_TEL     := valor2 
	SA1->A1_TABELA  := valor3
	SA1->A1_SATIV1  := valor4
	SA1->A1_GRPVEN  := valor5
	SA1->A1_PLOGIST := valor6
	SA1->A1_PVBAEXT := valor7
	SA1->A1_INSCR 	:= valor8
	msunlock() 
	tela:end()
return 
