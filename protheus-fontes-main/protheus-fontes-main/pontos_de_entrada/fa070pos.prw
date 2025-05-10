#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FA070POS
Ponto de entrada que permite a alteração de variáveis após carga de dados do título a ser baixado,
antes das informações serem mostradas na tela.
@author 	Evandro Mugnol
@since 		16/08/2016
@obs 		N/A
/*/

User Function FA070POS()

	nDescont := SE1->E1_VLRAPEL		// não mudar o nome desta variável, pois é padrão do sistema 

Return
