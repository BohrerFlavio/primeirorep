#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} MT094END
O ponto de entrada MT094END trás as seguintes informações: Número do Documento, Tipo do Documento, Operação 
que está sendo executada (Aprovação, Transferência e/ou Superior) e filial do documento com controle de alçadas,
para serem usadas conforme necessidade do usuário. O mesmo não possui retorno e tem por finalidade somente mostrar as informações.
Este Ponto de Entrada é executado antes da conclusão do tipo de operação que está em andamento (Liberar o Documento, Transferência
do Documento, Transferência para Superior)
@author 	Evandro Mugnol
@since 		29/01/2019
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function MT094END()

Local _aArea     := GetArea()
Local _aAreaSA2  := GetArea("SA2")
Local _aAreaSCR  := GetArea("SCR")
Local _aAreaSC7  := GetArea("SC7")	
Local _cDocto    := PARAMIXB[1]		// Número do Documento
Local _cTipoDoc  := PARAMIXB[2]		// Tipo do documento (PC, NF, SA, IP, AE)
Local _nOpcao    := PARAMIXB[3]		// Operação a ser executada (1-Aprovar, 2-Estornar, 3-Aprovar pelo Superior, 4-Transferir para Superior, 5-Rejeitar, 6-Bloquear)
Local _cFilDoc   := PARAMIXB[4]		// Filial do documento

// Liberacao do Documento
If((_nOpcao == 1) .AND. (_cTipoDoc == 'PC'))
	
	// Somente mostra tela de envio de e-mail para fornecedor se aprovador for diferente do Ivon (código de usuário 000037)
	If AllTrim( RetCodUsr() ) <> "000037" 

		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek(xFilial("SC7") + Left(_cDocto, 6))		// Deve pegar somente as 6 primeiras posições, pois o _cDocto tem 50 caracteres
		If Found()
			// Gera e Envia o Pedido de Compra por e-Mail
			U_STI_CP50(SC7->C7_FILIAL, SC7->C7_NUM, SC7->C7_FORNECE, SC7->C7_LOJA)
		Else
			MsgAlert("Não foi encontrado pedido de compra para enviar por e-mail. Favor mostrar esta mensagem para a DTI.")
		Endif

	Endif

EndIf	

Restarea(_aArea) 
Restarea(_aAreaSA2)	
Restarea(_aAreaSCR)
Restarea(_aAreaSC7)

Return()
