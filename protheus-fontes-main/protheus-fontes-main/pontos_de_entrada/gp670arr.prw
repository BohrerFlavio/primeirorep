#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} GP670ARR
Esse Ponto de entrada deve ser utilizado para adicionar, na integração do titulo, campos criados pelo usuario. 
Ele somente será executado quando estiver sendo efetuada a integraçcao do titulo, se isso não ocorrer 
sera apresentado log com os titulos não integrado.
@author     Evandro
@since      13/10/2020
@return     aCposUsr - Array contendo todos os dados complementares do títulos
/*/

User Function GP670ARR()

    Local aCposUsr := {}

    //_cContab := fBuscaCpo("SED", 1, xFilial("SED") + RC1->RC1_NATURE, "ED_CONTA")
    _cContab := GetAdvFVal("SED", "ED_CONTA", xFilial("SED") + RC1->RC1_NATURE, 1, Space(TamSx3("ED_CONTA")[1]), .T.)

    aAdd(aCposUsr,{'E2_CONTA' 	, _cContab  	, Nil})

Return aCposUsr
