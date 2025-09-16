#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FA110DES
Ponto Entrada FA110DES utilizado no calculo de descontos para o titulo na baixa automatica a receber
@author 	Evandro Mugnol
@since 		16/08/2016
@obs 		N/A
/*/

User Function FA110DES()

	_nDescRap := 0
	_nVlrRap  := SE1->E1_VLRAPEL 

	_cRapelBx := fBuscaCpo("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, "A1_RAPELBX")

	If _cRapelBx == "S"			// Executa somente se no cadastro do cliente o campo A1_RAPELBX estiver com Sim
		If cEmpAnt == "01"		// Executa somente para a empresa 01
			_nDescRap := _nVlrRap
		Endif
	Endif

Return(_nDescRap)
