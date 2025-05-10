// Bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================
WSDL Location    http://10.0.0.239:99/ws/wsMpClienteConsulta.apw?WSDL
Gerado em        28/12/2020
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
===============================================================================
*/


// Atributos de Entrada
WSSTRUCT CgcRequest

	WSDATA cliente_id AS STRING

ENDWSSTRUCT


// Atributos com a estrutura com os dados que são exibidos no xml do webservice
// Isso é o que retornará para quem fizer a requisição
WSSTRUCT CgcResponse

	WSDATA call_status	AS BOOLEAN
	WSDATA call_message AS STRING
	WSDATA call_code	AS STRING
	WSDATA cliente_id	AS STRING
	WSDATA cliente_tipo	AS STRING
	WSDATA cpf_cnpj		AS STRING
	WSDATA nome			AS STRING
	WSDATA endereco		AS STRING
	WSDATA cidade		AS STRING
	WSDATA estado		AS STRING
	WSDATA cep			AS STRING
	WSDATA responsavel	AS STRING
	WSDATA telefone		AS STRING
	WSDATA email		AS STRING

ENDWSSTRUCT


// Cria a tag de Webservice
WSSERVICE wsMpClienteConsulta Description "WebService Meios de Pagamentos - Consulta Dados Cliente"

	// Propriedades
	WSDATA dadosReq AS CgcRequest 	  	// Chama a estrutura dos dados de requisição
	WSDATA dadosRes AS CgcResponse     	// Chama a estrutura dos dados de resposta

	// Declara os metodos
	WSMETHOD dadosCNPJCPF Description "<b> Metodo de retorno da consulta por cliente_ID</b><br> <u>Retorno</u><br> call_status, call_message, call_code, cliente_id, cliente_tipo, cpf_cnpj, nome, endereco, cidade, estado, cep, responsavel, telefone e email  

ENDWSSERVICE	// Fecha o servico


WSMETHOD dadosCNPJCPF WSRECEIVE dadosReq WSSEND dadosRes WSSERVICE wsMpClienteConsulta
	
	Local aPv   := {}
	Local aDad  := {}

	RPCSetType(3) 	// Não Consome Licença

	aPv := U_PesqID(::dadosReq:Cliente_ID)

	If Len(aPv[1]) > 0

		aDad := aPv[1]

		::dadosRes:call_status	:= aDad[1]
		::dadosRes:call_message := aDad[2]
		::dadosRes:call_code	:= aDad[3]
		::dadosRes:cliente_id   := aDad[4]
		::dadosRes:cliente_tipo := aDad[5]
		::dadosRes:cpf_cnpj   	:= aDad[6]
		::dadosRes:nome			:= aDad[7]
		::dadosRes:endereco		:= aDad[8]
		::dadosRes:cidade		:= aDad[9]
		::dadosRes:estado		:= aDad[10]
		::dadosRes:cep			:= aDad[11]
		::dadosRes:responsavel	:= aDad[12]
		::dadosRes:telefone		:= aDad[13]
		::dadosRes:email		:= aDad[14]
		
	Else

		::dadosRes:call_status	:= aDad[1]
		::dadosRes:call_message := aDad[2]
		::dadosRes:call_code	:= aDad[3]
		::dadosRes:cliente_id   := aDad[4]
		::dadosRes:cliente_tipo := aDad[5]
		::dadosRes:cpf_cnpj   	:= aDad[6]
		::dadosRes:nome			:= aDad[7]
		::dadosRes:endereco		:= aDad[8]
		::dadosRes:cidade		:= aDad[9]
		::dadosRes:estado		:= aDad[10]
		::dadosRes:cep			:= aDad[11]
		::dadosRes:responsavel	:= aDad[12]
		::dadosRes:telefone		:= aDad[13]
		::dadosRes:email		:= aDad[14]

	Endif

Return .T.


// Função que pesquisa o cliente
User Function PesqID(_CNPJCPF)

	Local aRet := {}
	Local aDad := {}

	DbSelectArea("SA1")
	DbSetOrder(3)

	If MsSeek(xFilial("SA1") + AllTrim(_CNPJCPF))

		//If SA1->A1_MSBLQL == "2"	// Cliente Ativo
			AADD(aDad, .T.)														// resultado da chamada ao método (true/false)
			AADD(aDad, "Dados do cliente retornado com sucesso")				// mensagem da chamada (somente se false)
			AADD(aDad, "200")													// código da chamada (somente se false)
			AADD(aDad, AllTrim(SA1->A1_CGC))									// CNPJ/CPF do cliente		
			AADD(aDad, IIF(SA1->A1_PESSOA=="J","CNPJ","CPF"))					// tipo do cliente
			AADD(aDad, AllTrim(SA1->A1_CGC))									// número do CNPJ ou CPF		
			AADD(aDad, AllTrim(SA1->A1_NOME))									// nome do cliente
			AADD(aDad, AllTrim(SA1->A1_END))									// endereço do cliente
			AADD(aDad, AllTrim(SA1->A1_MUN))									// cidade do cliente
			AADD(aDad, AllTrim(SA1->A1_EST))									// estado do cliente
			AADD(aDad, AllTrim(SA1->A1_CEP))									// CEP do cliente
			AADD(aDad, AllTrim(SA1->A1_CONTATO))								// responsável do cliente
			AADD(aDad, Right(AllTrim(SA1->A1_DDD),2) + AllTrim(SA1->A1_TEL))	// telefone do cliente
			AADD(aDad, AllTrim(SA1->A1_EMAIL))									// e-mail do cliente
		//Else						// Cliente Inativo
		//	AADD(aDad, .F.)														// resultado da chamada ao método (true/false)
		//	AADD(aDad, "Cliente Inativo, contate o Frigorífico Silva.")			// mensagem da chamada (somente se false)
		//	AADD(aDad, "406")													// código da chamada (somente se false)
		//	AADD(aDad, AllTrim(SA1->A1_CGC))									// CNPJ/CPF do cliente		
		//	AADD(aDad, IIF(SA1->A1_PESSOA=="J","CNPJ","CPF"))					// tipo do cliente
		//	AADD(aDad, AllTrim(SA1->A1_CGC))									// número do CNPJ ou CPF		
		//	AADD(aDad, AllTrim(SA1->A1_NOME))									// nome do cliente
		//	AADD(aDad, AllTrim(SA1->A1_END))									// endereço do cliente
		//	AADD(aDad, AllTrim(SA1->A1_MUN))									// cidade do cliente
		//	AADD(aDad, AllTrim(SA1->A1_EST))									// estado do cliente
		//	AADD(aDad, AllTrim(SA1->A1_CEP))									// CEP do cliente
		//	AADD(aDad, AllTrim(SA1->A1_CONTATO))								// responsável do cliente
		//	AADD(aDad, Right(AllTrim(SA1->A1_DDD),2) + AllTrim(SA1->A1_TEL))	// telefone do cliente
		//	AADD(aDad, AllTrim(SA1->A1_EMAIL))									// e-mail do cliente
		//Endif
	Else
		AADD(aDad, .F.)														// resultado da chamada ao método (true/false)
		AADD(aDad, "Cliente inexistente, contate o Frigorífico Silva.")		// mensagem da chamada (somente se false)
		AADD(aDad, "404")													// código da chamada (somente se false)
		AADD(aDad, ".")														// CNPJ/CPF do cliente		
		AADD(aDad, ".")														// tipo do cliente
		AADD(aDad, ".")														// número do CNPJ ou CPF		
		AADD(aDad, ".")														// nome do cliente
		AADD(aDad, ".")														// endereço do cliente
		AADD(aDad, ".")														// cidade do cliente
		AADD(aDad, ".")														// estado do cliente
		AADD(aDad, ".")														// CEP do cliente
		AADD(aDad, ".")														// responsável do cliente
		AADD(aDad, ".")														// telefone do cliente
		AADD(aDad, ".")														// e-mail do cliente
	Endif
	
	AADD(aRet,aDad)

Return aRet
