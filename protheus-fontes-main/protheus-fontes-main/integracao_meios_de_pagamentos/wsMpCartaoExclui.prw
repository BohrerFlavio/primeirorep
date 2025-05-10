// Bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================
WSDL Location    http://10.0.0.239:99/ws/wsMPCartaoExclui.apw?WSDL
Gerado em        28/12/2020
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
===============================================================================
*/


// Atributos de Entrada
WSSTRUCT cceRequest

	WSDATA card_cod  	AS STRING

ENDWSSTRUCT


// Atributos com a estrutura com os dados que são exibidos no xml do webservice
// Isso é o que retornará para quem fizer a requisição
WSSTRUCT cceResponse

	WSDATA call_status	AS BOOLEAN
	WSDATA call_message AS STRING
	WSDATA call_code	AS STRING

ENDWSSTRUCT   

                            
// Cria a tag de Webservice
WSSERVICE wsMPCartaoExclui Description "WebService Meios de Pagamentos - Exclui Cartao de Credito"
	
	// Propriedades
	WSDATA ccexcReq AS cceRequest		// Chama a estrutura dos dados de requisição
	WSDATA ccexcRes AS cceResponse     	// Chama a estrutura dos dados de resposta        

	// Declara os metodos
	WSMETHOD excCartao Description "<b> Metodo de retorno da exclusao do cartao de credito</b><br> <u>Retorno</u><br> call_status, call_message e call_code
ENDWSSERVICE	// Fecha o servico

WSMETHOD excCartao WSRECEIVE ccexcReq WSSEND ccexcRes WSSERVICE wsMPCartaoExclui 

	Local aPv   := {}
	Local aDad  := {}

	RPCSetType(3) 	// Não Consome Licença
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'OMS' TABLES 'ZK1'

	aPv := U_ExcluiCC(::ccexcReq:card_cod)

	If Len(aPv[1]) > 0

		aDad := aPv[1]

		::ccexcRes:call_status  := aDad[1]
		::ccexcRes:call_message := aDad[2]
		::ccexcRes:call_code	:= aDad[3]
		
	Else

		::ccexcRes:call_status  := aDad[1]
		::ccexcRes:call_message := aDad[2]
		::ccexcRes:call_code	:= aDad[3]

	Endif

Return .T.   


// Função que exclui o cartão de crédito do cliente
User Function ExcluiCC(_cCardCod)

	Local aRet := {}
	Local aDad := {}

	DbSelectArea("ZK1")
	DbSetOrder(4)
	If MsSeek(xFilial("ZK1") + _cCardCod)
		Reclock("ZK1",.F.)		
		DbDelete()
		MsUnlock()    
		
		AADD(aDad, .T.)													// resultado da chamada ao método (true/false)
		AADD(aDad, "Cartão de crédito excluído com sucesso")            // mensagem da chamada (somente se false)
		AADD(aDad, "200")												// código da chamada (somente se false)
	Else
		AADD(aDad, .F.)																						// resultado da chamada ao método (true/false)
		AADD(aDad, "Exclusão de cartão de crédito não executada, pois cartão inexistente na base de dados")	// mensagem da chamada (somente se false)
		AADD(aDad, "404")																					// código da chamada (somente se false)
	Endif
	
	AADD(aRet,aDad)

Return aRet
