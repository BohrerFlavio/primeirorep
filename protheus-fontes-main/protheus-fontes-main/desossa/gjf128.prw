#INCLUDE "rwmake.ch"           
#INCLUDE "protheus.ch"   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF128     บ Autor ณGiuliano Forgiarini บ Data ณ  26/12/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Manuten็ใo de parametro para ativa็ใo do controle de       บฑฑ
ฑฑบ          ณ classifica็ใo especial de carca็as na entrada da desossa   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ sigapcp                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function GJF128()


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Itens1 := {'Liberado','Bloqueado','Desativado'}

	if getmv("SI_CLASESP") = 'S'
		valor1 := 'Liberado'
	elseif getmv("SI_CLASESP") = 'N'
		valor1 := 'Bloqueado'
	else 
		valor1 := 'Desativado'
	endif


	DEFINE MSDIALOG tela FROM 0,0 TO 300,260 PIXEL TITLE "Parametro de Produ็ใo" 
	@ 01,01 SAY "Classif. Especial:       " of tela 
	@ 01,11 COMBOBOX valor1 items Itens1 SIZE 40,08 
	@ 115,05 BUTTON btnOK PROMPT "Salvar" OF tela PIXEL ACTION Confirma()
	@ 115,65 BUTTON btnCa PROMPT "Fechar" OF tela PIXEL ACTION tela:end()
	ACTIVATE MSDIALOG tela CENTERED  

Return 


Static Function Confirma()

	if valor1 = 'Liberado'
		PUTMV("SI_CLASESP",'S')
	elseif valor1 = 'Bloqueado'
		PUTMV("SI_CLASESP",'N') 
	elseif valor1 = 'Desativado'
		PUTMV("SI_CLASESP",'D') 
	endif 

	tela:end()

Return
