#INCLUDE "PROTHEUS.CH"

User Function GP410DES
	//local _lRet := .f.  
	local _lRet := .t.  


	
	/* Dia 13/07/22 - Solicitado alteração  pelo Sr Claudioir 
	Solicitado pelo Claudioir para retirar o processo abaixo e validado com DP - Marilice */
	/*  
	if !("CAIXA" $ upper(mv_par12))
		return .t.
	endif


	if !empty(SRA->RA_GERALIQ)	 
		_lRet := .t.
	endif
	*/


return _lRet

