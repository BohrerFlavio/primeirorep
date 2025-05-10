#INCLUDE "rwmake.ch"
User Function A120PIDF()
	Private aFiltro := {" " , " "} 
	If MsgBox ("Filtra fornecedores?","Escolha","YESNO")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estrutura do array                                           ³
		//³ 1 - String - Filtro no SC1 para ISAM ( Sintaxe xBase )       ³
		//³ 2 - String - Filtro no SC1 para SQL  ( Sintaxe SQL   )       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//	aFiltro := 	{""," '"+CA120FORN+"' = C1_FORNECE " }
		aFiltro := 	{" C1_FORNECE = '"+CA120FORN+"'"," !EMPTY(C1_NUM) " }
	Endif

Return 	aFiltro
