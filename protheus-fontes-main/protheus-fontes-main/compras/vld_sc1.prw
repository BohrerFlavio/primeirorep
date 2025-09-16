#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} VLD_SC1D
Rotina de validação de usuário no campo C1_DATPRF que valida a data da necessidade digitada na tela
@author 	Evandro Mugnol
@since 		01/02/2019
@return 	Lógico
@obs 		N/A
/*/

User Function VLD_SC1()

_lRet := .T.

If ReadVar() == "M->C1_DATPRF"
   If M->C1_DATPRF < SomaPrazo(DDATABASE, + CalcPrazo(GDFieldGet("C1_PRODUTO"),0))
   	  Aviso( "Data de Necessidade Inválida", 'A data de necessidade informada não pode ser menor que a calculada pelo sistema. FAVOR VERIFICAR COM SETOR DE COMPRAS.', {"Fechar"}, 2, )
      _lRet := .F.
   Endif
Endif

Return(_lRet)
