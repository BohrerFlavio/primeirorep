#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} OM200US
Ponto de Entrada que permite incluir botões no menu padrão da rotina 
de Montagem de Carga (OMSA200)
@author 	FUSION
@param      aRotina	- Array contendo os botões do menu padrão
@return 	aRotina	- Array contendo os botões do menu padrão
@obs 		Localizado no início da rotina, após a carga dos botões 
            padrões da rotina e antes da exibição da tela.
/*/
//-------------------------------------------------------------------

User Function OM200US()

	Local _aArea  := GetArea()
    Local aRotina := ParamIxb

    Aadd(aRotina, {OemToAnsi("Integrar Fusiontrak"), "U_JOBFUSIONT(cFilAnt)", 0 , 2, 0, NIL})

	RestArea(_aArea)
 
Return(aRotina)
