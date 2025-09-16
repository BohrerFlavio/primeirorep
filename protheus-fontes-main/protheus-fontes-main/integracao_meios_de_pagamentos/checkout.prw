#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "MSOLE.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} CHECKOUT
Método de envio para execução da cobrança
@author     Evandro
@since      Out/2020
@param 		_cDoc, caracter
			_cSer, caracter
			_cCli, caracter
			_cLoj, caracter
@return     N/A
@obs        N/A
@see 		Abaixo os links usados como referênncia para montagem da funções
			Link 01 - https://tdn.totvs.com/display/tec/Classe+TWsdlManager
			Link 02 - https://tdn.totvs.com/display/tec/SOAP+1.1+e+SOAP+1.2
			Link 03 - https://tdn.totvs.com/display/tec/XmlParser                
			Dúvidas quanto a Parse:
			Link 01 - https://centraldeatendimento.totvs.com/hc/pt-br/articles/360022658731-MP-ADVPL-Peer-certificate-cannot-be-authenticated-with-given-CA-certificates
			Link 02 - https://tdn.totvs.com/display/tec/Acesso+a+Web+Services+que+exigem+certificados+de+CA
			Link 03 - https://tdn.totvs.com/pages/viewpage.action?pageId=223932805
			Link 04 - https://tdn.totvs.com/display/tec/TWsdlManager%3AlSSLInsecure
/*/
//-------------------------------------------------------------------

User Function CHECKOUT(_cDoc, _cSer, _cCli, _cLoj, _nVBrut)

	// Processa todos os cartões de crédito do cliente, iniciando pelo Preferencial
	// Quando encontrar o primeíro cartão de crédito processado como AUTHORIZED, PAID ou WAITTING não executa os demais
	_cCCPrefer := "1"	// Cartão de Crédito Preferencial (1=Sim;2=Não)
	_cStatCall := ""
	_TodosCanc := .F.

	DbSelectArea("ZK1")
	DbSetOrder(2)
	MsSeek(xFilial("ZK1") + _cCli + _cLoj + _cCCPrefer)
	While !Eof() .And. ZK1->ZK1_FILIAL + ZK1->ZK1_CODCLI + ZK1->ZK1_LOJCLI == xFilial("ZK1") + _cCli + _cLoj

		_cStatCall := _EnvRet(_cDoc, _cSer, _cCli, _cLoj, _nVBrut) 

		If Upper(AllTrim(_cStatCall)) == "DECLINED" .Or. Upper(AllTrim(_cStatCall)) == "CANCELED"
			_TodosCanc := .T.
			//MsgAlert("Cartão " + ZK1->ZK1_CCRED + "  |Status: " + _cStatCall)
			DbSelectArea("ZK1")
			DbSkip()
		Else
			_TodosCanc := .F.
			//MsgAlert("Cartão " + ZK1->ZK1_CCRED + "  |Status: " + _cStatCall)
			Exit
		Endif

	EndDo

	If _TodosCanc
		If MsgYesNo("Todos cartões de crédito do cliente foram recusados." + CHR(13) + CHR(10) + "Deseja abrir site do PAGSEGURO para gerar Link?")
			_LinkPAGS()
		EndIf
	Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _EnvRet
Função que executa o método do Checkout (Envio e Retorno)
@author     Evandro
@since      Out/2020
@param 		_cDoc, _cSer, _cCli, _cLoj, Dados da nota fiscal
@return 	cStatus, Status do retorno da transação 
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function _EnvRet(_cDoc, _cSer, _cCli, _cLoj, _nVBrut)

	Local aArea      := GetArea()
	Local lRet       := .T.
	//Local cURL     := "https://hml.portaldocliente.hotmedia.com.br/api/v1/ws/frigorifico/paymentSoap?wsdl"	// Ambiente Homologação
	Local cURL       := "https://portaldocliente.hotmedia.com.br/api/v1/ws/frigorifico/paymentSoap?wsdl"		// Ambiente Produção
	Local cSoapSend  := ""
	Local cSoapRet   := ""
	Local oWsdl      := Nil
	Local cError     := ""
	Local cWarning   := ""
	Local cXmlGet  	 := ""
	Local lContinua  := .T.
	Local _cDocto    := _cDoc
	Local _cSerie    := _cSer
	Local _cCliente  := _cCli
	Local _cLojaCli  := _cLoj
	Local _nValBrut  := Val(Str(_nVBrut*100,9))
	Local aZK1Campos := {}
	Local cStatus	 := ""

	Local oJson 	 := Nil
	Local StrJson 	 := ''
	Local LenStrJson := 0
	Local JsonFields := Nil
	Local nRetParser := 0
	Local lRetJson 	 := .F.
	
	Private aDadosSM0:= FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_CODFIL"} ) 
	Private oXmlDoc

	// Instância a classe, setando as parametrizações necessárias
	oWsdl := TWsdlManager():New()

	oWsdl:cSSLCACertFile := "\certs\000001_ca.pem"		// Obtém o arquivo de certificado de CA usado para conexão SSL com o servidor que receberá a mensagem SOAP
	oWsdl:cSSLCertFile   := "\certs\000001_cert.pem"	// Obtém o arquivo de certificado cliente usado para conexão SSL com o servidor que receberá a mensagem SOAP
	oWsdl:cSSLKeyFile    := "\certs\000001_key.pem"		// Obtém o arquivo de chave primária usado para conexão SSL com o servidor que receberá a mensagem SOAP
	oWsdl:cSSLKeyPwd     := "99756969"					// Obtém a senha para o certificado usado para conexão SSL com o servidor que receberá a mensagem SOAP
	oWsdl:nSSLVersion    := "0"							// Define ou recupera a versão do protocolo SSL/TLS utilizado. 
														// 0 - O programa tenta descobrir a versão do protocolo, isto é, se a versão do protocolo remoto é SSLv3 ou TLSv1
														// 1 - Força a utilização do TLSv1
														// 2 - Força a utilização do SSLv2
														// 3 - Força a utilização do SSLv3
	oWsdl:lSSLInsecure   := .T.							// Define se fará a conexão SSL com o servidor de forma anônima, ou seja, sem verificação de certificados ou chaves
	oWsdl:nTimeout       := 120							// Obtém o valor de timeout em segundos para envio e recebimento dos documentos SOAP


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Método Checkout  		                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Se for continuar o processamento
	If lContinua
		// Tenta fazer o Parse da URL
		lRet := oWsdl:ParseURL(cURL)
		If !lRet 
			_cMsg := oWsdl:cError
			U_GLogErro( _cDocto						,;		// Número da Nota Fiscal
						_cSerie						,;		// Série da Nota Fiscal
						_cCliente					,;		// Código do Cliente
						_cLojaCli					,;		// Loja do Cliente
						"CHECKOUT"					,;		// Nome do Método de WebService
						"ENVRET - Erro ParseURL: "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 )		// Mensagem de Log de Erro
			lContinua := .F.
		EndIf
	EndIf

	// Se for continuar o processamento
	If lContinua
		// Tenta definir a operação
		lRet := oWsdl:SetOperation("checkout")
		If !lRet 
			_cMsg := oWsdl:cError
			U_GLogErro( _cDocto							,;		// Número da Nota Fiscal
						_cSerie							,;		// Série da Nota Fiscal
						_cCliente						,;		// Código do Cliente
						_cLojaCli						,;		// Loja do Cliente
						"CHECKOUT"						,;		// Nome do Método de WebService
						"ENVRET - Erro SetOperation: "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 )		// Mensagem de Log de Erro
			lContinua := .F.
		EndIf
	EndIf

	// Se for continuar
	If lContinua
		
		// Ajustar aqui problema quando primeiro cartão é DECLINED e não está posicionando no segundo cartão que é o correto
		aZK1Campos := GetAdvFVal("ZK1", {"ZK1_CGCCLI", "ZK1_CODINT", "ZK1_TPCART", "ZK1_NPARC", "ZK1_CCRED", "ZK1_NOMTIT", "ZK1_MESEXP", "ZK1_ANOEXP", "ZK1_CODCVV", "ZK1_CTOKEN"}, xFilial("ZK1") + _cCliente + _cLojaCli, 2) 
		_NumSerNF  := _cDocto + _cSerie
		_cMoeda	   := "BRL"
		_DesCheck  := _cDocto + _cSerie + _cCliente + _cLojaCli

		_Pass := "1q2w3e"
		_User := "frigo"
		_Crea := FWTimeStamp( 6, Date(), Time() )

		If aZK1Campos[3] == "1"			// Se checkout_type = 1 (CARTÃO DE CRÉDITO)

			//cSoapSend := '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="https://hml.portaldocliente.hotmedia.com.br/api/v1/ws/frigorifico/paymentSoap" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns2="https://hml.portaldocliente.hotmedia.com.br/api/v1" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'   + CRLF
			cSoapSend := '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="https://portaldocliente.hotmedia.com.br/api/v1/ws/frigorifico/paymentSoap" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns2="https://portaldocliente.hotmedia.com.br/api/v1" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'   + CRLF
			cSoapSend += '   <SOAP-ENV:Header>'																								+ CRLF
			cSoapSend += '      <ns2:authToken>'																							+ CRLF
			cSoapSend += '         <Password>' + AllTrim( _Pass ) + '</Password>'															+ CRLF
			cSoapSend += '         <Username>' + AllTrim( _User ) + '</Username>'															+ CRLF
			cSoapSend += '         <Created>' + AllTrim( _Crea ) + '</Created>'																+ CRLF
			cSoapSend += '      </ns2:authToken>'																							+ CRLF
			cSoapSend += '   </SOAP-ENV:Header>'																							+ CRLF
			cSoapSend += '   <SOAP-ENV:Body>'																								+ CRLF
			cSoapSend += '      <ns1:checkout>'																								+ CRLF
			cSoapSend += '         <dataArray xsi:type="ns1:CheckoutDataType">'																+ CRLF
			cSoapSend += '            <cliente_id xsi:type="xsd:string">' + AllTrim( aZK1Campos[1] ) + '</cliente_id>'							+ CRLF
			cSoapSend += '            <integradora xsi:type="xsd:int">' + AllTrim( aZK1Campos[2] ) + '</integradora>'						+ CRLF
			cSoapSend += '   	      <checkout_type xsi:type="xsd:int">' + AllTrim( aZK1Campos[3] ) + '</checkout_type>'					+ CRLF
			cSoapSend += '	          <pay_installments xsi:type="xsd:int">' + AllTrim( Str( aZK1Campos[4], 2 ) ) + '</pay_installments>'	+ CRLF
			cSoapSend += '	          <reference_id xsi:type="xsd:string">' + AllTrim( _NumSerNF ) + '</reference_id>'						+ CRLF
			cSoapSend += '	          <valor xsi:type="xsd:int">' + AllTrim( Str( _nValBrut, 9 ) ) + '</valor>'								+ CRLF
			cSoapSend += '	          <currency xsi:type="xsd:string">' + AllTrim( _cMoeda ) + '</currency>'								+ CRLF
			cSoapSend += '	          <description xsi:type="xsd:string">' + AllTrim( _DesCheck ) + '</description>'						+ CRLF
			cSoapSend += '	          <card_id xsi:type="xsd:string"></card_id>'															+ CRLF
			cSoapSend += '	          <card_number xsi:type="xsd:string">' + AllTrim( aZK1Campos[5] ) + '</card_number>'					+ CRLF
			cSoapSend += '	          <card_name xsi:type="xsd:string">' + AllTrim( aZK1Campos[6] ) + '</card_name>'						+ CRLF
			cSoapSend += '	          <card_mes_exp xsi:type="xsd:int">' + AllTrim( Str( aZK1Campos[7], 2 ) ) + '</card_mes_exp>'			+ CRLF
			cSoapSend += '	          <card_ano_exp xsi:type="xsd:int">' + AllTrim( Str( aZK1Campos[8], 4 ) ) + '</card_ano_exp>'			+ CRLF
			cSoapSend += '	          <card_cvv xsi:type="xsd:string">' + AllTrim( aZK1Campos[9] ) + '</card_cvv>'								+ CRLF
			cSoapSend += '         </dataArray>'																							+ CRLF
			cSoapSend += '      </ns1:checkout>'																							+ CRLF
			cSoapSend += '   </SOAP-ENV:Body>'																								+ CRLF
			cSoapSend += '</SOAP-ENV:Envelope>'																								+ CRLF

		ElseIf aZK1Campos[3] == "2"		// Se checkout_type = 2 (CARTÃO TOKENIZADO)

			//cSoapSend := '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="https://hml.portaldocliente.hotmedia.com.br/api/v1/ws/frigorifico/paymentSoap" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns2="https://hml.portaldocliente.hotmedia.com.br/api/v1" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'   + CRLF
			cSoapSend := '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="https://portaldocliente.hotmedia.com.br/api/v1/ws/frigorifico/paymentSoap" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns2="https://portaldocliente.hotmedia.com.br/api/v1" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'   + CRLF
			cSoapSend += '   <SOAP-ENV:Header>'																								+ CRLF
			cSoapSend += '      <ns2:authToken>'																							+ CRLF
			cSoapSend += '         <Password>' + AllTrim( _Pass ) + '</Password>'															+ CRLF
			cSoapSend += '         <Username>' + AllTrim( _User ) + '</Username>'															+ CRLF
			cSoapSend += '         <Created>' + AllTrim( _Crea ) + '</Created>'																+ CRLF
			cSoapSend += '      </ns2:authToken>'																							+ CRLF
			cSoapSend += '   </SOAP-ENV:Header>'																							+ CRLF
			cSoapSend += '   <SOAP-ENV:Body>'																								+ CRLF
			cSoapSend += '      <ns1:checkout>'																								+ CRLF
			cSoapSend += '         <dataArray xsi:type="ns1:CheckoutDataType">'																+ CRLF
			cSoapSend += '            <cliente_id xsi:type="xsd:string">' + AllTrim( aZK1Campos[1] ) + '</cliente_id>'							+ CRLF
			cSoapSend += '            <integradora xsi:type="xsd:int">' + AllTrim( aZK1Campos[2] ) + '</integradora>'						+ CRLF
			cSoapSend += '   	      <checkout_type xsi:type="xsd:int">' + AllTrim( aZK1Campos[3] ) + '</checkout_type>'					+ CRLF
			cSoapSend += '	          <pay_installments xsi:type="xsd:int">' + AllTrim( Str( aZK1Campos[4], 2 ) ) + '</pay_installments>'	+ CRLF
			cSoapSend += '	          <reference_id xsi:type="xsd:string">' + AllTrim( _NumSerNF ) + '</reference_id>'						+ CRLF
			cSoapSend += '	          <valor xsi:type="xsd:int">' + AllTrim( Str( _nValBrut, 9 ) ) + '</valor>'								+ CRLF
			cSoapSend += '	          <currency xsi:type="xsd:string">' + AllTrim( _cMoeda ) + '</currency>'								+ CRLF
			cSoapSend += '	          <description xsi:type="xsd:string">' + AllTrim( _DesCheck ) + '</description>'						+ CRLF
			cSoapSend += '	          <card_id xsi:type="xsd:string">' + AllTrim( aZK1Campos[10] ) + '</card_id>'							+ CRLF
			cSoapSend += '	          <card_number xsi:type="xsd:string"></card_number>'													+ CRLF
			cSoapSend += '	          <card_name xsi:type="xsd:string"></card_name>'														+ CRLF
			cSoapSend += '	          <card_mes_exp xsi:type="xsd:int">' + AllTrim( Str( 0, 1 ) ) + '</card_mes_exp>'						+ CRLF
			cSoapSend += '	          <card_ano_exp xsi:type="xsd:int">' + AllTrim( Str( 0, 1 ) ) + '</card_ano_exp>'						+ CRLF
			cSoapSend += '	          <card_cvv xsi:type="xsd:string">' + AllTrim( aZK1Campos[9] ) + '</card_cvv>'								+ CRLF
			cSoapSend += '         </dataArray>'																							+ CRLF
			cSoapSend += '      </ns1:checkout>'																							+ CRLF
			cSoapSend += '   </SOAP-ENV:Body>'																								+ CRLF
			cSoapSend += '</SOAP-ENV:Envelope>'																								+ CRLF

		Endif

		//memowrite("ZZZ_CHECKOUT.TXT",cSoapSend)

		// Envia uma mensagem SOAP personalizada ao servidor
		lRet := oWsdl:SendSoapMsg(cSoapSend)
		If !lRet 
			_cMsg := oWsdl:cError
			U_GLogErro( _cDocto							,;		// Número da Nota Fiscal
						_cSerie							,;		// Série da Nota Fiscal
						_cCliente						,;		// Código do Cliente
						_cLojaCli						,;		// Loja do Cliente
						"CHECKOUT"						,;		// Nome do Método de WebService
						"ENVRET - Erro SendSoapMsg: "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 )		// Mensagem de Log de Erro

			_cMsg := oWsdl:cFaultCode
			U_GLogErro( _cDocto									,;		// Número da Nota Fiscal
						_cSerie									,;		// Série da Nota Fiscal
						_cCliente								,;		// Código do Cliente
						_cLojaCli								,;		// Loja do Cliente
						"CHECKOUT"								,;		// Nome do Método de WebService
						"ENVRET - Erro SendSoapMsg FaultCode: "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 		 )		// Mensagem de Log de Erro
			lContinua := .F.
		EndIf
	EndIf

	// Se for continuar
	If lContinua
		// Pega a resposta do SOAP
		cSoapRet := oWsdl:GetSoapResponse()

		// Transforma a resposta em um objeto
		oXmlDoc := XmlParser(cSoapRet, "_", @cError, @cWarning)

		// Se existir Warning, mostra no console.log
		If !Empty(cWarning)
			_cMsg := cWarning
			U_GLogErro( _cDocto							,;		// Número da Nota Fiscal
						_cSerie							,;		// Série da Nota Fiscal
						_cCliente						,;		// Código do Cliente
						_cLojaCli						,;		// Loja do Cliente
						"CHECKOUT"						,;		// Nome do Método de WebService
						"ENVRET - Alerta cWarning: "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 )		// Mensagem de Log de Erro
		EndIf

		// Se houve erro, não permitirá prosseguir
		If !Empty(cError)
			_cMsg := cError
			U_GLogErro( _cDocto							,;		// Número da Nota Fiscal
						_cSerie							,;		// Série da Nota Fiscal
						_cCliente						,;		// Código do Cliente
						_cLojaCli						,;		// Loja do Cliente
						"CHECKOUT"						,;		// Nome do Método de WebService
						"ENVRET - Erro cError: "		,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 )		// Mensagem de Log de Erro
			lContinua := .F.
		EndIf
	EndIf

	// Se for continuar
	If lContinua
		If (Type("oXmlDoc:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CHECKOUTRESPONSE:_RETURN:TEXT") != "U")

			// Pega tag que contém XML
			cXmlGet := oXmlDoc:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CHECKOUTRESPONSE:_RETURN:TEXT

			oJson := tJsonParser():New()
			   
			StrJson    := cXmlGet
			LenStrJson := Len(StrJson)
			JsonFields := {}
			lRetJson   := oJson:Json_Parser(StrJson, LenStrJson, @JsonFields, @nRetParser)

			If lRetJson
				cStatus := JsonFields[1][2][2][2][7][2]				// status do retorno
				  
				  // Somente grava se retorno do call_status do método checkout for verdadeiro
			  	If JsonFields[1][2][2][2][1][2]
			  		cChkOutID := JsonFields[1][2][2][2][5][2]					// checkout_id
			  		cIntegrad := StrZero(JsonFields[1][2][2][2][4][2],2,0)		// integradora
					
					DbSelectArea("ZK2")
					RecLock("ZK2",.T.)
					ZK2->ZK2_FILIAL	:= xFilial("ZK2")
					ZK2->ZK2_CALLST := JsonFields[1][2][2][2][1][2]					// call_status
					ZK2->ZK2_CALLMS := JsonFields[1][2][2][2][2][2]					// call_message
					ZK2->ZK2_CALLCD := JsonFields[1][2][2][2][3][2]					// call_code             
					ZK2->ZK2_CODINT := StrZero(JsonFields[1][2][2][2][4][2],2,0)	// integradora  
					ZK2->ZK2_NOMINT := GetAdvFVal("ZK0", "ZK0_NOMINT", xFilial("ZK0") + StrZero(JsonFields[1][2][2][2][4][2],2,0), 1, Space(TamSx3("ZK0_NOMINT")[1]), .T.)	// integradora  
					ZK2->ZK2_CHKID  := JsonFields[1][2][2][2][5][2]					// checkout_id 
					ZK2->ZK2_REFID  := JsonFields[1][2][2][2][6][2]					// reference_id
					ZK2->ZK2_STATUS := JsonFields[1][2][2][2][7][2]					// status      
					ZK2->ZK2_DTTRAN := JsonFields[1][2][2][2][8][2]					// created_at  
					ZK2->ZK2_DTPGTO := JsonFields[1][2][2][2][9][2]					// paid_at     
					ZK2->ZK2_IDEMCC := JsonFields[1][2][2][2][10][2]				// payres_message
					ZK2->ZK2_STEMCC := JsonFields[1][2][2][2][11][2]				// payres_reference
					ZK2->ZK2_MTPGTO := JsonFields[1][2][2][2][12][2]				// paymethod_type
					ZK2->ZK2_NPARC  := JsonFields[1][2][2][2][13][2]				// paymethod_installments
					ZK2->ZK2_VLACOB := JsonFields[1][2][2][2][14][2] / 100			// amount_valor
					ZK2->ZK2_VLTCOB := JsonFields[1][2][2][2][15][2] / 100			// sumary_total
					ZK2->ZK2_VLPCOB := JsonFields[1][2][2][2][16][2] / 100			// sumary_paid 
					ZK2->ZK2_VLDCOB := JsonFields[1][2][2][2][17][2] / 100			// sumary_refunded
					ZK2->ZK2_CTOKEN := JsonFields[1][2][2][2][18][2]				// card_id     
					ZK2->ZK2_BANDCC := JsonFields[1][2][2][2][19][2]				// card_brand  
					ZK2->ZK2_CCRED4 := JsonFields[1][2][2][2][20][2]				// last_digits 
					ZK2->ZK2_NOMTIT := JsonFields[1][2][2][2][21][2]				// card_name
					MsUnlock()
				
					// Atualizar Informações na ZK1
					If aZK1Campos[3] == "1" .And. Empty(aZK1Campos[10])		// Se tipo do cartão 1=Cartão de Crédito e Cartão Tokenizado em branco
						ZK1->(dbSetOrder(1))
						If ZK1->(MsSeek(xFilial("ZK1") + _cCliente + _cLojaCli + aZK1Campos[5]))
							RecLock("ZK1",.F.)
							ZK1->ZK1_TPCART := "2" 									// tipo do cartão tokenizado
							ZK1->ZK1_CTOKEN := JsonFields[1][2][2][2][18][2]		// cartão tokenizado
							MsUnlock()
						EndIf
					EndIf
						
					// Atualizar Informações Cabeçalho da Nota Fiscal quando CALL_STATUS = .T.
					SF2->(dbSetOrder(1))
					If SF2->(MsSeek(xFilial("SF2") + _cDocto + _cSerie + _cCliente + _cLojaCli))
						RecLock("SF2",.F.)
						SF2->F2_CHKID   := JsonFields[1][2][2][2][5][2]					// checkout_id
						SF2->F2_CODINT  := StrZero(JsonFields[1][2][2][2][4][2],2,0)	// integradora
						SF2->F2_STATRET := JsonFields[1][2][2][2][7][2]					// status
						MsUnlock()
					EndIf
					
					// Atualizar Informações dos títulos no contas a receber quando CALL_STATUS = .T.
					SE1->(DbSetOrder(1))
					SE1->(MsSeek(xFilial("SE1") + Left(aDadosSM0[1][2],3) + _cDocto, .T.))		// Busca dados do SM0, pois grava prefixo do título com filial de origem
					While !Eof() .And. SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM == xFilial("SE1") + Left(aDadosSM0[1][2],3) + _cDocto
						// Verifica o cliente
						If (SE1->E1_CLIENTE + SE1->E1_LOJA <> _cCliente + _cLojaCli)
							SE1->(DbSkip())
							Loop
						Endif

						Reclock("SE1",.F.)
						SE1->E1_CHKID   := JsonFields[1][2][2][2][5][2]					// checkout_id
						SE1->E1_INTEGRA := StrZero(JsonFields[1][2][2][2][4][2],2,0)	// integradora
						SE1->E1_STATRET := JsonFields[1][2][2][2][7][2]					// status
						MsUnlock()
						
						SE1->(DbSkip())
					EndDo
				Else
					_cMsg := "Retorno do metodo foi 'FALSO' e por esse motivo a transação não foi aprovada. "
					U_GLogErro( _cDocto								,;		// Número da Nota Fiscal
								_cSerie								,;		// Série da Nota Fiscal
								_cCliente							,;		// Código do Cliente
								_cLojaCli							,;		// Loja do Cliente
								"CHECKOUT"							,;		// Nome do Método de WebService
								"JSON PARSER - Call Status False "	,;		// Título da Mensagem de Log de Erro
								_cMsg						 	 	 )		// Mensagem de Log de Erro

					// Atualizar Informações Cabeçalho da Nota Fiscal quando CALL_STATUS = .F.
					SF2->(dbSetOrder(1))
					If SF2->(MsSeek(xFilial("SF2") + _cDocto + _cSerie + _cCliente + _cLojaCli))
						RecLock("SF2",.F.)
						SF2->F2_CHKID   := JsonFields[1][2][2][2][5][2]					// checkout_id
						SF2->F2_CODINT  := StrZero(JsonFields[1][2][2][2][4][2],2,0)	// integradora
						SF2->F2_STATRET := JsonFields[1][2][2][2][7][2]					// status
						MsUnlock()
					EndIf

					// Atualizar Informações dos títulos no contas a receber quando CALL_STATUS = .F.
					SE1->(DbSetOrder(1))
					SE1->(MsSeek(xFilial("SE1") + Left(aDadosSM0[1][2],3) + _cDocto, .T.))		// Busca dados do SM0, pois grava prefixo do título com filial de origem
					While !SE1->(Eof()) .And. SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM == xFilial("SE1") + Left(aDadosSM0[1][2],3) + _cDocto
						// Verifica o cliente
						If (SE1->E1_CLIENTE + SE1->E1_LOJA <> _cCliente + _cLojaCli)
							SE1->(DbSkip())
							Loop
						Endif
						
						Reclock("SE1",.F.)
						SE1->E1_CHKID   := JsonFields[1][2][2][2][5][2]					// checkout_id
						SE1->E1_INTEGRA := StrZero(JsonFields[1][2][2][2][4][2],2,0)	// integradora
						SE1->E1_STATRET := JsonFields[1][2][2][2][7][2]					// status
						MsUnlock("SE1")
						
						SE1->(DbSkip())
					EndDo
				EndIf
			Else
				_cMsg := "Tamanho da mensagem: " + AllTrim(Str(LenStrJson)) + " - Bytes lidos: " + AllTrim(Str(nRetParser)) + CRLF
				_cMsg += "Erro a partir: " + SubStr(StrJson, (nRetParser + 1))
				U_GLogErro( _cDocto							,;		// Número da Nota Fiscal
							_cSerie							,;		// Série da Nota Fiscal
							_cCliente						,;		// Código do Cliente
							_cLojaCli						,;		// Loja do Cliente
							"CHECKOUT"						,;		// Nome do Método de WebService
							"JSON ERROR - Parser com Erro "	,;		// Título da Mensagem de Log de Erro
							_cMsg						 	 )		// Mensagem de Log de Erro
			EndIf

			FreeObj(oJson)

		Else
			_cMsg := "Ocorreu algum problema no momento de leitura do retorno do metodo referente a TAG " + CRLF
			_cMsg += "oXmlDoc:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CHECKOUTRESPONSE:_RETURN:TEXT"
			U_GLogErro( _cDocto										,;		// Número da Nota Fiscal
						_cSerie										,;		// Série da Nota Fiscal
						_cCliente									,;		// Código do Cliente
						_cLojaCli									,;		// Loja do Cliente
						"CHECKOUT"									,;		// Nome do Método de WebService
						"ENVRET - Retorno leitura TAG com Erro "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 			 )		// Mensagem de Log de Erro
		Endif
	EndIf

	RestArea(aArea)

Return cStatus


//-------------------------------------------------------------------
/*/{Protheus.doc} _LinkPAGS
Realiza a abertura da página para geração do link do PAGSEGURO
@author     Evandro
@since      Out/2020
@return 	N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function _LinkPAGS()

	Local oDlg		  := Nil
	Local aAdvSize	  := {}
	Local cUrl		  := "https://pagseguro.uol.com.br/para-seu-negocio/online/link-de-pagamento#rmcl"
	Local oWebEngine  := Nil
	Local oWebChannel := Nil
	Local nPort		  := 00000
	
	aAdvSize :=	MsAdvSize()
	
	oMainWnd:CoorsUpdate()	// Atualiza as corrdenadas da Janela MAIN
	nMyWidth:=oMainWnd:nClientWidth-10
	nMyHeight:=oMainWnd:nClientHeight-30
	
	If !GetRPORelease() <= "12.1.017"
	
		oWebChannel := TWebChannel():New()
		nPort       := oWebChannel:connect() 	// Efetua conexão e retorna a porta do WebSocket
		
		DEFINE DIALOG oDlg TITLE "LINK PAGSEGURO" From aAdvSize[7],00 To nMyHeight,nMyWidth PIXEL
		    
		// Cria componente
		oWebEngine := TWebEngine():New(oDlg, 05, 05, nMyHeight-250, nMyWidth-820, cUrl, nPort)
		oWebEngine:navigate(cUrl)
		oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
		  
		ACTIVATE DIALOG oDlg CENTERED
	Else
	 	ShellExecute("Open", cUrl, "", "", 1 )  
	EndIf

Return
