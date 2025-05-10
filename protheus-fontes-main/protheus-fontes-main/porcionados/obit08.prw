#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"

/*
Validação de produtos alternativos
*/
user function Obit08(_cProdP, _cProdLido)
	Local _lRet := .F.
	if ALLTRIM(_cProdP) == ALLTRIM(_cProdLido)
		_lRet := .T.
	elseif consulta(_cProdP, _cProdLido)
		_lRet := .T.
	endif

return _lRet


static function consulta(_cOri, _cAlter)
	Local _cQuery := ""
	Local _lRet2  := .F.

	_cQuery += " SELECT COUNT(*) AS QTDE "
	_cQuery += " FROM " + RETSQLNAME("SGI") +" SGI "
	_cQuery += " WHERE SGI.D_E_L_E_T_ = '' AND GI_FILIAL = '"+xfilial('SGI')+"' AND GI_PRODORI = '"+_cOri+"' AND GI_PRODALT = '"+_cAlter+"' "

	_cQuery  := ChangeQuery(_cQuery)

	TCQUERY _cQuery NEW ALIAS "TRB"

	//Enquanto houver registros, adiciona na temporária
	While !TRB->(EoF())
		if TRB->QTDE > 0
			_lRet2 := .T.
		endif
		TRB->(DbSkip())
	EndDo
	TRB->(DbCloseArea())

return (_lRet2)
