// Bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================
WSDL Location    http://10.0.0.239:99/ws/wsMpCartaoPadraoSet.apw?WSDL
Gerado em        28/12/2020
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
===============================================================================
*/


// Atributos de Entrada
WSSTRUCT ccpRequest

	WSDATA card_cod  	AS STRING

ENDWSSTRUCT


// Atributos com a estrutura com os dados que são exibidos no xml do webservice
// Isso é o que retornará para quem fizer a requisição
WSSTRUCT ccpResponse

	WSDATA call_status	AS BOOLEAN
	WSDATA call_message AS STRING
	WSDATA call_code	AS STRING

ENDWSSTRUCT   

                            
// Cria a tag de Webservice
WSSERVICE wsMpCartaoPadraoSet Description "WebService Meios de Pagamentos - Seta Cartao de Credito Padrao"
	
	// Propriedades
	WSDATA ccpadReq AS ccpRequest		// Chama a estrutura dos dados de requisição
	WSDATA ccpadRes AS ccpResponse     	// Chama a estrutura dos dados de resposta        

	// Declara os metodos
	WSMETHOD setpadCartao Description "<b> Metodo para setar cartao de credito padrao</b><br> <u>Retorno</u><br> call_status, call_message e call_code
ENDWSSERVICE	// Fecha o servico

WSMETHOD setpadCartao WSRECEIVE ccpadReq WSSEND ccpadRes WSSERVICE wsMpCartaoPadraoSet 

	Local aPv   := {}
	Local aDad  := {}

	RPCSetType(3) 	// Não Consome Licença
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'OMS' TABLES 'ZK1'

	aPv := U_SetPadCC(::ccpadReq:card_cod)

	If Len(aPv[1]) > 0

		aDad := aPv[1]

		::ccpadRes:call_status  := aDad[1]
		::ccpadRes:call_message := aDad[2]
		::ccpadRes:call_code	:= aDad[3]
		
	Else

		::ccpadRes:call_status  := aDad[1]
		::ccpadRes:call_message := aDad[2]
		::ccpadRes:call_code	:= aDad[3]

	Endif

Return .T.   


// Função que seta o cartão de crédito padrão do cliente
User Function SetPadCC(_cCardCod)

	Local aRet := {}
	Local aDad := {}

	DbSelectArea("ZK1")
	DbSetOrder(4)
	If MsSeek(xFilial("ZK1") + _cCardCod)
		_cCodCli := ZK1->ZK1_CODCLI
		_cLojCli := ZK1->ZK1_LOJCLI
		
		// Primeiramente seta todos os cartões do cliente como NÃO PREFERENCIAL
		_cQuery := "UPDATE " + RetSQLName("ZK1")
		_cQuery += "   SET ZK1_CCPREF = '2' "
		_cQuery += " WHERE D_E_L_E_T_ <> '*' "
		_cQuery += "   AND ZK1_CODCLI = '" + _cCodCli + "' "
		_cQuery += "   AND ZK1_LOJCLI = '" + _cLojCli + "' "
		_cQuery += "   AND ZK1_FILIAL = '" + xFilial("ZK1") + "' "
		TcSqlExec(_cQuery)

		// Seta cartão padrão conforme seek acima
		Reclock("ZK1",.F.)
		ZK1->ZK1_CCPREF := "1"
		MsUnlock()
	
		AADD(aDad, .T.)																				// resultado da chamada ao método (true/false)
		AADD(aDad, "Card Cod " + AllTrim(_cCardCod) + " setado como cartão preferencial")		    // mensagem da chamada (somente se false)
		AADD(aDad, "200")																			// código da chamada (somente se false)
	Else
		AADD(aDad, .F.)																							// resultado da chamada ao método (true/false)
		AADD(aDad, "Card Cod " + AllTrim(_cCardCod) + " não pôde ser setado como preferencial, pois não encontrado na base de dados")	// mensagem da chamada (somente se false)
		AADD(aDad, "404")																						// código da chamada (somente se false)
	Endif
	
	AADD(aRet,aDad)

Return aRet
