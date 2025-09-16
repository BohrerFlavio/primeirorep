// Bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================
WSDL Location    http://10.0.0.239:99/ws/wsMpClienteUpdate.apw?WSDL
Gerado em        04/01/2021
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
===============================================================================
*/


// Atributos de Entrada
WSSTRUCT infoRequest

	WSDATA cliente_id 	AS STRING
	WSDATA endereco		AS STRING
	WSDATA cidade		AS STRING
	WSDATA estado		AS STRING
	WSDATA cep			AS STRING
	WSDATA responsavel	AS STRING
	WSDATA telefone		AS STRING
	WSDATA email		AS STRING

ENDWSSTRUCT


// Atributos com a estrutura com os dados que são exibidos no xml do webservice
// Isso é o que retornará para quem fizer a requisição
WSSTRUCT infoResponse

	WSDATA call_status	AS BOOLEAN
	WSDATA call_message AS STRING
	WSDATA call_code	AS STRING

ENDWSSTRUCT


// Cria a tag de Webservice
WSSERVICE wsMpClienteUpdate Description "WebService Meios de Pagamentos - Update Dados Cliente"

	// Propriedades
	WSDATA infoReq AS infoRequest 	  	// Chama a estrutura dos dados de requisição
	WSDATA infoRes AS infoResponse     	// Chama a estrutura dos dados de resposta

	// Declara os metodos
	WSMETHOD infoCNPJCPF Description "<b> Metodo de retorno do update por cliente_ID</b><br> <u>Retorno</u><br> call_status, call_message e call_code  

ENDWSSERVICE	// Fecha o servico


WSMETHOD infoCNPJCPF WSRECEIVE infoReq WSSEND infoRes WSSERVICE wsMpClienteUpdate
	
	Local aPv   := {}
	Local aDad  := {}

	RPCSetType(3) 	// Não Consome Licença
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'OMS' TABLES 'SA1'

	aPv := U_UpdateID(::infoReq:Cliente_ID, ::infoReq:endereco, ::infoReq:cidade, ::infoReq:estado, ::infoReq:cep, ::infoReq:responsavel, ::infoReq:telefone, ::infoReq:email)

	If Len(aPv[1]) > 0

		aDad := aPv[1]

		::infoRes:call_status  := aDad[1]
		::infoRes:call_message := aDad[2]
		::infoRes:call_code	   := aDad[3]
		
	Else

		::infoRes:call_status  := aDad[1]
		::infoRes:call_message := aDad[2]
		::infoRes:call_code	   := aDad[3]

	Endif

Return .T.


// Função que pesquisa e realiza update no cliente
User Function UpdateID(_CNPJCPF, _Endereco, _Cidade, _Estado, _CEP, _Respons, _Fone, _Email)

	Local aRet := {}
	Local aDad := {}

	DbSelectArea("SA1")
	DbSetOrder(3)

	If MsSeek(xFilial("SA1") + AllTrim(_CNPJCPF))

		//If SA1->A1_MSBLQL == "2"	// Cliente Ativo
			AADD(aDad, .T.)											// resultado da chamada ao método (true/false)
			AADD(aDad, "Dados do cliente atualizado com sucesso")	// mensagem da chamada (somente se false)
			AADD(aDad, "200")										// código da chamada (somente se false)
			
			// Atualiza informações do cliente (SA1), recebidas na requisição
			RecLock("SA1",.F.)
			If !Empty(_Endereco)
				SA1->A1_END   	:=	AllTrim(_Endereco)			// endereço do cliente
			Endif
			If !Empty(_Cidade)
				SA1->A1_MUN   	:=	AllTrim(_Cidade)			// cidade do cliente
			Endif
			If !Empty(_Estado)
				SA1->A1_EST   	:=	AllTrim(_Estado)			// estado do cliente
			Endif
			If !Empty(_CEP)
				SA1->A1_CEP		:=	AllTrim(_CEP)				// CEP do cliente
			Endif
			If !Empty(_Respons)
				SA1->A1_CONTATO :=	AllTrim(_Respons)			// responsável do cliente
			Endif
			If !Empty(_Fone)
				SA1->A1_DDD		:=  Left(AllTrim(_Fone), 2)					// DDD do telefone do cliente
				SA1->A1_TEL		:=	AllTrim(Substr(AllTrim(_Fone),3,15))	// telefone do cliente
			Endif
			If !Empty(_Email)
				SA1->A1_EMAIL  	:=	AllTrim(_Email)				// e-mail do cliente
			Endif
			MsUnlock()
		//Else						// Cliente Inativo
		//	AADD(aDad, .F.)										// resultado da chamada ao método (true/false)
		//	AADD(aDad, "Dados do cliente não foram atualizados, pois o mesmo esta inativo na base de dados")	// mensagem da chamada (somente se false)
		//	AADD(aDad, "406")									// código da chamada (somente se false)
		//Endif
	Else
		AADD(aDad, .F.)										// resultado da chamada ao método (true/false)
		AADD(aDad, "Update não executado, pois cliente inexistente na base de dados")	// mensagem da chamada (somente se false)
		AADD(aDad, "404")									// código da chamada (somente se false)
	Endif
	
	AADD(aRet,aDad)

Return aRet

