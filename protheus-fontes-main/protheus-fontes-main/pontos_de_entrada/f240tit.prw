#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F240TIT
Ponto de entrada executado durante a marcação dos títulos que irão 
compor o borderô de pagamento.
@author 	Evandro Mugnol
@since 		Out/2022
@return 	_lRet - Se retornar .T., significa que houve a alteração da
            marcação do t¡tulo, e os acumuladores de valores serão alterados.
@obs 		N/A
/*/
//-------------------------------------------------------------------

User Function F240TIT()

	Local _aArea := GetArea()
	Local _lRet  := .T.

	If cModPgto == "45"				// Pagto via PIX
		cQuery	  := ''
		cAliasQry := GetNextAlias()
		aArea	  := {}

		cQuery := "SELECT F72_TPCHV, F72_CHVPIX, F72_ACTIVE  " 
		cQuery += "  FROM " + RetSQLTab("F72")
		cQuery += " WHERE " + RetSQLFil("F72")
		cQuery += "   AND F72.F72_COD = '" + SE2->E2_FORNECE + "'"
		cQuery += "   AND F72.F72_LOJA = '" + SE2->E2_LOJA + "'"
		cQuery += "   AND F72.F72_ACTIVE = '1' "
		cQuery += "   AND " + RetSQLDel("F72")
		cQuery := ChangeQuery( cQuery ) 
				
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
				
		If (cAliasQry)->(EOF())

			cMsgHTML := '<h1><font color="#0000FF">Atenção</font></h1>'
			cMsgHTML += '<h2><br><font color="#FF0000"><b>Fornecedor do título não possui Chave PIX cadastrada.</font></b></h2>'

			MsgAlert(cMsgHTML)

			_lRet := .F.
		EndIf

		(cAliasQry)->(dbCloseArea())
	EndIf

	RestArea(_aArea)

Return(_lRet)
