#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} STI_RG01
Este ponto de entrada somente estará em funcionamento no fonte FINA090 a partir da versão 12.1.17 da data 29/08/2017,
pois o mesmo está substituindo o ponto de entrada F090FIL devido a alteração da estrutura de filtro codebase para query
@author 	Evandro Mugnol
@since 		Jan/2018
@return 	Nil, Função não tem retorno
@obs 		cFiltro é Caracter. Sintaxe da cláusula WHERE (SQL) que será utilizado para filtrar os registros
para seleção para a baixa automática é obrigatória
/*/

User Function F090QFIL()

	Local cFiltroAtual := PARAMIXB[1]  	// Recebe a cláusula WHERE atual da rotina
	Local cFiltro      := ""
	Private cFornece   := "      "
	Private cNomeFor   := Space(100)

	@ 65,153 To 230,800 Dialog _oDlg Title OemToAnsi("Filtro Fornecedor")
	@ 10,10 Say OemToAnsi("Fornecedor")
	@ 20,10 Get cFornece Picture "@!" F3 "SA2" Valid Empty(cFornece) .Or. VldFor() Size 40, 10
	@ 35,10 Get cNomeFor Picture "@!" When .F. SIZE 300, 10

	@ 62,70 BMPBUTTON TYPE 1 ACTION Close(_oDlg)

	Activate Dialog _oDlg Centered

	If !Empty(cFornece)
		cFiltro := cFiltroAtual + " AND E2_FORNECE = '" + cFornece + "'"
	Else
		cFiltro := cFiltroAtual
	Endif

Return cFiltro 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Consistencia no Fornecedor                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VldFor()

	cNomeFor := Space(100)

	DbSelectArea("SA2")
	DbSetorder(1)
	DbSeek(xFilial("SA2") + cFornece)
	If Found()
		lVal     := .T.
		cNomeFor := SA2->A2_NOME
	Else
		lVal 	:= .F.
		MsgAlert("Fornecedor Inválido. Informe um Fornecedor Válido!")
	EndIf

Return lVal 
