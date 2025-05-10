#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} STI_RG90
Rotina executada no cadastro de fórmulas e que foi informada no cadastro de TES para listar nos livros fiscais
@author 	Evandro Mugnol.
@since 		Out/2017
@return 	Mensagens cadastradas nos campos F1_MENDFE2, F1_MENDFE3, F1_MENDFE4
@obs 		N/A
/*/

User Function STI_RG90()

	_cObsLivros := ""

	SF1->(DbSetOrder(1))
	SF1->(DbSeek(xFilial("SF1") + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))

	If !Empty(SF1->F1_MENDFE2) 
		_cObsLivros += AllTrim(SF1->F1_MENDFE2)
	Endif

	If !Empty(SF1->F1_MENDFE3) 
		_cObsLivros += AllTrim(SF1->F1_MENDFE3)
	Endif

	If !Empty(SF1->F1_MENDFE4) 
		_cObsLivros += AllTrim(SF1->F1_MENDFE4)
	Endif

Return(_cObsLivros)
