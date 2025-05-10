#INCLUDE "rwmake.ch"
User Function A120F4FI()
	Private aFiltro := {} 
	If MsgBox ("Filtra fornecedores?","Escolha","YESNO")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estrutura do array                                           ³
		//³ 1 - String - Filtro no SC1 para ISAM ( Sintaxe xBase )       ³
		//³ 2 - String - Filtro no SC1 para SQL  ( Sintaxe SQL   )       ³
		//³ 3 - String - Filtro no SC3 para ISAM ( Sintaxe xBase )       ³
		//³ 4 - String - Filtro no SC3 para SQL  ( Sintaxe SQL   )       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aFiltro := 	{""," 1=1 ",""," 1=1 " }



	Endif

Return 	aFiltro
