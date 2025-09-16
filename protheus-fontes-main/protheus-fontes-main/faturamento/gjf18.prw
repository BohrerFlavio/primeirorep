#INCLUDE "rwmake.ch"           
#INCLUDE "protheus.ch"           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF18     º Autor Giuliano Forgiarini    Data ³  12/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao: Manutenção da tabela SB1: Alteração do FESA                 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF18()

	Private cPerg   := "GJF18"
	Private cCadastro := "Manutenção do FESA"

	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
	{"Visualizar","AxVisual",0,2} ,;   
	{"Alterar FESA","u_altFESA",0,4} } 

	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "SB1"

	dbSelectArea("SB1")
	dbSetOrder(1)

	cPerg   := "GJF18"
	ord17 := .T.
	Pergunte(cPerg,.F.)
	SetKey(123,{|| Pergunte(cPerg,.T.)}) // Seta a tecla F12 para acionamento dos parametros

	mBrowse(6,1,22,75,cString,,) 

	dbSelectArea(cString)

	Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros
Return  

user Function altFESA()
	campo1 := 0
	valor1 := SB1->B1_FESA 
	DEFINE MSDIALOG tela FROM 0,0 TO 200,250 PIXEL TITLE "Alterar FESA"
	@ 01,01 SAY "Valor FESA:" of tela 
	@ 12,48 MSGET campo1 VAR valor1 SIZE 40,10 OF tela PIXEL PICTURE "@E 999.99"
	@ 82,5 BUTTON botao1 PROMPT "Salvar" OF tela PIXEL ACTION u_gjf18_1()
	@ 82,65 BUTTON botao2 PROMPT "Fechar" OF tela PIXEL ACTION tela:end()
	ACTIVATE MSDIALOG tela CENTERED
Return 

user function gjf18_1()
	begin transaction  
		reclock('SB1',.f.)
		SB1->B1_FESA  := valor1
		msunlock()   
	end transaction
	tela:end()   
return 
