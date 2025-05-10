// Bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================
WSDL Location    http://10.0.0.239:99/ws/wsMpCartaoInclui.apw?WSDL
Gerado em        28/12/2020
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
===============================================================================
*/


// Atributos de Entrada
WSSTRUCT cciRequest

	WSDATA cliente_id 	AS STRING
	WSDATA card_number	AS STRING
	WSDATA card_name  	AS STRING
	WSDATA card_mes_exp AS INTEGER
	WSDATA card_ano_exp	AS INTEGER
	WSDATA card_cvv    	AS STRING
	WSDATA card_flag  	AS STRING

ENDWSSTRUCT


// Atributos com a estrutura com os dados que são exibidos no xml do webservice
// Isso é o que retornará para quem fizer a requisição
WSSTRUCT cciResponse

	WSDATA call_status	AS BOOLEAN
	WSDATA call_message AS STRING
	WSDATA call_code	AS STRING
	WSDATA card_cod 	AS STRING

ENDWSSTRUCT   

                            
// Cria a tag de Webservice
WSSERVICE wsMpCartaoInclui Description "WebService Meios de Pagamentos - Inclui Cartao de Credito"
	
	// Propriedades
	WSDATA ccincReq AS cciRequest		// Chama a estrutura dos dados de requisição
	WSDATA ccincRes AS cciResponse     	// Chama a estrutura dos dados de resposta        

	// Declara os metodos
	WSMETHOD incCartao Description "<b> Metodo de retorno da inclusao do cartao de credito</b><br> <u>Retorno</u><br> call_status, call_message, call_code e card_cod
ENDWSSERVICE	// Fecha o servico

WSMETHOD incCartao WSRECEIVE ccincReq WSSEND ccincRes WSSERVICE wsMpCartaoInclui 

	Local aPv   := {}
	Local aDad  := {}

	RPCSetType(3) 	// Não Consome Licença
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'OMS' TABLES 'ZK1'

	aPv := U_IncluiCC(::ccincReq:Cliente_ID, ::ccincReq:card_number, ::ccincReq:card_name, ::ccincReq:card_mes_exp, ::ccincReq:card_ano_exp, ::ccincReq:card_cvv, ::ccincReq:card_flag)

	If Len(aPv[1]) > 0

		aDad := aPv[1]

		::ccincRes:call_status  := aDad[1]
		::ccincRes:call_message := aDad[2]
		::ccincRes:call_code	:= aDad[3]
		::ccincRes:card_cod 	:= aDad[4]
		
	Else

		::ccincRes:call_status  := aDad[1]
		::ccincRes:call_message := aDad[2]
		::ccincRes:call_code	:= aDad[3]
		::ccincRes:card_cod 	:= aDad[4]

	Endif

Return .T.   


// Função que inclui o cartão de crédito do cliente, associando ao cadastro existente
User Function IncluiCC(_CNPJCPF, _NumCC, NomeTit, _MesExp, _AnoExp, _CodCVV, _Bandeira)

	Local aRet := {}
	Local aDad := {}

	DbSelectArea("SA1")
	DbSetOrder(3)
	If MsSeek(xFilial("SA1") + AllTrim(_CNPJCPF))
		_cCli 	  := SA1->A1_COD
		_cLoj 	  := SA1->A1_LOJA
		_cCardCod := Right(AllTrim(_NumCC),4) + AllTrim(_CodCVV)
		
		// Desabilitado regra de validação de cliente ativo/inativo sempre cadastrando o cartão de crédito
		// conforme definido com Clailton em 09/06/2021
		//If SA1->A1_MSBLQL == "2"	// Cliente Ativo

			// Verifica se cliente já possui algum cartão de crédito cadastrado
			// pois caso não tenha já seta como cartão preferencial
			DbSelectArea("ZK1")
			DbSetorder(1)
			DbGoTop()
			If MsSeek(xFilial("ZK1") + _cCli + _cLoj)
				_CCPref := "2"
			Else
				_CCPref := "1"
			Endif
			
			DbSelectArea("ZK1")
			DbSetOrder(1)
			DbGoTop()
			If MsSeek(xFilial("ZK1") + _cCli + _cLoj + _NumCC)
				AADD(aDad, .F.)																// resultado da chamada ao método (true/false)
				AADD(aDad, "Cartão de crédito já se encontra cadastrado na base de dados")	// mensagem da chamada (somente se false)
				AADD(aDad, "406")															// código da chamada (somente se false)
				AADD(aDad, _cCardCod)														// código do cartão de crédito
			Else
				AADD(aDad, .T.)													// resultado da chamada ao método (true/false)
				AADD(aDad, "Cartão de Crédito do cliente incluído com sucesso")	// mensagem da chamada (somente se false)
				AADD(aDad, "200")												// código da chamada (somente se false)
				AADD(aDad, _cCardCod)											// código do cartão de crédito
				
				// Inclui cartão de crédito do cliente na tabela (ZK1), recebidas na requisição
				DbSelectArea("ZK1")
				RecLock("ZK1",.T.)
				ZK1->ZK1_FILIAL := xFilial("ZK1")
				ZK1->ZK1_CODCLI := _cCli 
				ZK1->ZK1_LOJCLI := _cLoj
				ZK1->ZK1_CGCCLI := _CNPJCPF
				ZK1->ZK1_CCRED  := _NumCC 
				ZK1->ZK1_CCPREF := _CCPref
				ZK1->ZK1_BANDEI := _Bandeira
				ZK1->ZK1_NOMTIT := NomeTit
				ZK1->ZK1_MESEXP := _MesExp
				ZK1->ZK1_ANOEXP := _AnoExp
				ZK1->ZK1_CODCVV := _CodCVV
				ZK1->ZK1_NPARC  := 1
				ZK1->ZK1_CODINT := "01"
				ZK1->ZK1_NOMINT := GetAdvFVal("ZK0", "ZK0_NOMINT", xFilial("ZK0") + "01", 1, Space(TamSx3("ZK0_NOMINT")[1]), .T.)
				ZK1->ZK1_TPCART := "1"
				ZK1->ZK1_CARDCD := _cCardCod
				MsUnlock()
			Endif
		//Else						// Cliente Inativo
		//	AADD(aDad, .F.)																							// resultado da chamada ao método (true/false)
		//	AADD(aDad, "Inclusão de cartão de crédito não executada, pois cliente esta inativo na base de dados")	// mensagem da chamada (somente se false)
		//	AADD(aDad, "406")																						// código da chamada (somente se false)
		//	AADD(aDad, _cCardCod)																					// código do cartão de crédito
		//Endif
	Else
		AADD(aDad, .F.)																							// resultado da chamada ao método (true/false)
		AADD(aDad, "Inclusão de cartão de crédito não executada, pois cliente inexistente na base de dados")	// mensagem da chamada (somente se false)
		AADD(aDad, "404")																						// código da chamada (somente se false)
		AADD(aDad, _cCardCod)																					// código do cartão de crédito
	Endif
	
	AADD(aRet,aDad)

Return aRet
