#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GLOGERRO
Função para criação de logs de erros ref. aos webservices de integração dos meios de pagamento
@author     Evandro
@since      Nov/2020
@param 		cDocto, 	Caracter, 	Número da Nota Fiscal
			cSerie, 	Caracter, 	Série da Nota Fiscal
			cCliente, 	Caracter, 	Código do Cliente
			cLoja, 		Caracter, 	Loja do Cliente
			cMetodo,	Caracter, 	Nome do Método de WebService
			cTitulo, 	Caracter, 	Título da Mensagem de Log de Erro
			cMensag, 	Caracter, 	Mensagem de Log de Erro
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------

User Function GLogErro(cDocto, cSerie, cCliente, cLoja, cMetodo, cTitulo, cMensag)

	Local aArea	:= GetArea()
	Local cSeq	:= Criavar("ZK3_SEQ")

	Default cDocto	 := ""
	Default cSerie	 := ""
	Default cCliente := ""
	Default cLoja	 := ""
	Default cMetodo	 := ""
	Default cTitulo	 := ""
	Default cMensag	 := ""

	If !Empty(cDocto)

		// Salvando o log de erro
		DbSelectArea("ZK3")
		RecLock("ZK3", .T.)
		ZK3->ZK3_FILIAL := xFilial("ZK3")
		ZK3->ZK3_SEQ	:= NextNumero("ZK3",3,"ZK3_SEQ",.T.)
		ZK3->ZK3_DOC	:= cDocto
		ZK3->ZK3_SERIE	:= cSerie
		ZK3->ZK3_CLIENT	:= cCliente
		ZK3->ZK3_LOJA	:= cLoja
		ZK3->ZK3_METODO	:= cMetodo
		ZK3->ZK3_TITULO	:= cTitulo
		ZK3->ZK3_MENSAG	:= cMensag
		ZK3->ZK3_DTERRO	:= Date()
		ZK3->ZK3_HRERRO	:= Time()
		ZK3->ZK3_USERRO	:= UsrRetName(RetCodUsr())
		MsUnlock()

	EndIf

	RestArea(aArea)

Return
