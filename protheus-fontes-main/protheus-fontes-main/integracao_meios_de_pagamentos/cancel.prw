#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CANCEL
Método de envio e retorno para execução do CANCELAMENTO da cobrança
@author     Evandro
@since      Nov/2020
@param 		_cDoc,   caracter
			_cSer,   caracter
			_cCli,   caracter
			_cLoj,   caracter
			_nVlr,   caracter
			_cChkID, caracter
			_cInteg, caracter
			_cCliID, caracter
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

User Function CANCEL(_cDoc, _cSer, _cCli, _cLoj, _nVlr, _cChkID, _cInteg, _cCliID)

	_cStatCall := _EnvRet(_cDoc, _cSer, _cCli, _cLoj, _nVlr, _cChkID, _cInteg, _cCliID) 

	//MsgAlert("NFiscal: " + _cDoc + "/" + _cSer + "  |Cartão Tokenizado: " + _cChkID + "  |Status: " + _cStatCall)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _EnvRet
Função que executa o método do Cancel (Envio e Retorno)
@author     Evandro
@since      Nov/2020
@param 		_cDoc, _cSer, _cCli, _cLoj, _nVlr, _cChkID, _cInteg, _cCliID, 	Dados da nota fiscal
@return 	cStatus, Status do retorno da transação 
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function _EnvRet(_cDoc, _cSer, _cCli, _cLoj, _nVlr, _cChkID, _cInteg, _cCliID)

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
	Local _nValBrut  := Val(Str(_nVlr*100,9))
	Local _cCheckID	 := _cChkID
	Local _cIntegra  := _cInteg
	Local _cClienID  := _cCliID
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
	//³ Método Cancel	  		                                            ³
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
						"CANCEL"					,;		// Nome do Método de WebService
						"ENVRET - Erro ParseURL: "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 )		// Mensagem de Log de Erro
			lContinua := .F.
		EndIf
	EndIf

	// Se for continuar o processamento
	If lContinua
		// Tenta definir a operação
		lRet := oWsdl:SetOperation("cancel")
		If !lRet 
			_cMsg := oWsdl:cError
			U_GLogErro( _cDocto							,;		// Número da Nota Fiscal
						_cSerie							,;		// Série da Nota Fiscal
						_cCliente						,;		// Código do Cliente
						_cLojaCli						,;		// Loja do Cliente
						"CANCEL"						,;		// Nome do Método de WebService
						"ENVRET - Erro SetOperation: "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 )		// Mensagem de Log de Erro
			lContinua := .F.
		EndIf
	EndIf

	// Se for continuar
	If lContinua
		_Pass := "1q2w3e"
		_User := "frigo"
		_Crea := FWTimeStamp( 6, Date(), Time() )

		//cSoapSend := '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="https://hml.portaldocliente.hotmedia.com.br/api/v1/ws/frigorifico/paymentSoap" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns2="https://hml.portaldocliente.hotmedia.com.br/api/v1" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'	+ CRLF
		cSoapSend := '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="https://portaldocliente.hotmedia.com.br/api/v1/ws/frigorifico/paymentSoap" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns2="https://portaldocliente.hotmedia.com.br/api/v1" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'	+ CRLF
		cSoapSend += '	 <SOAP-ENV:Header>'																			+ CRLF
		cSoapSend += '	    <ns2:authToken>'																		+ CRLF
		cSoapSend += '	       <Password>' + AllTrim( _Pass ) + '</Password>'										+ CRLF
		cSoapSend += '	       <Username>' + AllTrim( _User ) + '</Username>'										+ CRLF
		cSoapSend += '	       <Created>' + AllTrim( _Crea ) + '</Created>'											+ CRLF
		cSoapSend += '	    </ns2:authToken>'																		+ CRLF
		cSoapSend += '	 </SOAP-ENV:Header>'																		+ CRLF
		cSoapSend += '	 <SOAP-ENV:Body>'																			+ CRLF
		cSoapSend += '	    <ns1:cancel>'																			+ CRLF
		cSoapSend += '	       <dataArray xsi:type="ns1:ChargeCancelDataType">'										+ CRLF
		cSoapSend += '		   	  <cliente_id xsi:type="xsd:string">' + AllTrim( _cClienID ) + '</cliente_id>'			+ CRLF
		cSoapSend += '			  <integradora xsi:type="xsd:int">' + AllTrim( _cIntegra ) + '</integradora>'		+ CRLF
		cSoapSend += '			  <checkout_id xsi:type="xsd:string">' + AllTrim( _cCheckID ) + '</checkout_id>'	+ CRLF
		cSoapSend += '			  <valor xsi:type="xsd:int">' + AllTrim( Str( _nValBrut, 9 ) ) + '</valor>'			+ CRLF
		cSoapSend += '	       </dataArray>'																		+ CRLF
		cSoapSend += '		</ns1:cancel>'																			+ CRLF
		cSoapSend += '	 </SOAP-ENV:Body>'																			+ CRLF
		cSoapSend += '</SOAP-ENV:Envelope>'																			+ CRLF

		// Envia uma mensagem SOAP personalizada ao servidor
		lRet := oWsdl:SendSoapMsg(cSoapSend)
		If !lRet 
			_cMsg := oWsdl:cError
			U_GLogErro( _cDocto							,;		// Número da Nota Fiscal
						_cSerie							,;		// Série da Nota Fiscal
						_cCliente						,;		// Código do Cliente
						_cLojaCli						,;		// Loja do Cliente
						"CANCEL"						,;		// Nome do Método de WebService
						"ENVRET - Erro SendSoapMsg: "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 )		// Mensagem de Log de Erro

			_cMsg := oWsdl:cFaultCode
			U_GLogErro( _cDocto									,;		// Número da Nota Fiscal
						_cSerie									,;		// Série da Nota Fiscal
						_cCliente								,;		// Código do Cliente
						_cLojaCli								,;		// Loja do Cliente
						"CANCEL"								,;		// Nome do Método de WebService
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
						"CANCEL"						,;		// Nome do Método de WebService
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
						"CANCEL"						,;		// Nome do Método de WebService
						"ENVRET - Erro cError: "		,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 )		// Mensagem de Log de Erro
			lContinua := .F.
		EndIf
	EndIf

	// Se for continuar
	If lContinua
		If (Type("oXmlDoc:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CANCELRESPONSE:_RETURN:TEXT") != "U")

			// Pega tag que contém XML
			cXmlGet := oXmlDoc:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CANCELRESPONSE:_RETURN:TEXT

			oJson := tJsonParser():New()
			   
			StrJson    := cXmlGet
			LenStrJson := Len(StrJson)
			JsonFields := {}
			lRetJson   := oJson:Json_Parser(StrJson, LenStrJson, @JsonFields, @nRetParser)

			If lRetJson
			  	// Somente grava se retorno do call_status do método cancel for verdadeiro
			  	If JsonFields[1][2][2][2][1][2]
			  		cStatus   := JsonFields[1][2][2][2][7][2]					// status do retorno
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
					ZK2->ZK2_DTPGTO := ""											// paid_at     
					ZK2->ZK2_IDEMCC := JsonFields[1][2][2][2][9][2]					// payres_message
					ZK2->ZK2_STEMCC := JsonFields[1][2][2][2][10][2]				// payres_reference
					ZK2->ZK2_MTPGTO := JsonFields[1][2][2][2][11][2]				// paymethod_type
					ZK2->ZK2_NPARC  := JsonFields[1][2][2][2][12][2]				// paymethod_installments
					ZK2->ZK2_VLACOB := JsonFields[1][2][2][2][13][2] / 100			// amount_valor
					ZK2->ZK2_VLTCOB := JsonFields[1][2][2][2][14][2] / 100			// sumary_total
					ZK2->ZK2_VLPCOB := JsonFields[1][2][2][2][15][2] / 100			// sumary_paid 
					ZK2->ZK2_VLDCOB := JsonFields[1][2][2][2][16][2] / 100			// sumary_refunded
					ZK2->ZK2_BANDCC := JsonFields[1][2][2][2][17][2]				// card_brand  
					ZK2->ZK2_CTOKEN := ""											// card_id     
					ZK2->ZK2_CCRED4 := JsonFields[1][2][2][2][18][2]				// last_digits 
					ZK2->ZK2_NOMTIT := JsonFields[1][2][2][2][19][2]				// card_name
					MsUnlock()
				
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
						MsUnlock("SE1")
						
						SE1->(DbSkip())
					EndDo
				Else
					_cMsg := "Retorno do metodo foi 'FALSO' e por esse motivo a transação não foi aprovada. "
					U_GLogErro( _cDocto								,;		// Número da Nota Fiscal
								_cSerie								,;		// Série da Nota Fiscal
								_cCliente							,;		// Código do Cliente
								_cLojaCli							,;		// Loja do Cliente
								"CANCEL"							,;		// Nome do Método de WebService
								"JSON PARSER - Call Status False "	,;		// Título da Mensagem de Log de Erro
								_cMsg						 	 	 )		// Mensagem de Log de Erro

					/*
					// NÃO Atualizar Informações Cabeçalho da Nota Fiscal quando CALL_STATUS = .F.
					// Isso devido a estrutura de retorno do JsonFields ser diferente
					SF2->(dbSetOrder(1))
					If SF2->(MsSeek(xFilial("SF2") + _cDocto + _cSerie + _cCliente + _cLojaCli))
						RecLock("SF2",.F.)
						SF2->F2_CHKID   := JsonFields[1][2][2][2][5][2]					// checkout_id
						SF2->F2_CODINT  := StrZero(JsonFields[1][2][2][2][4][2],2,0)	// integradora
						SF2->F2_STATRET := JsonFields[1][2][2][2][7][2]					// status
						MsUnlock()
					EndIf

					// NÃO Atualizar Informações dos títulos no contas a receber quando CALL_STATUS = .F.
					// Isso devido a estrutura de retorno do JsonFields ser diferente
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
					*/
				EndIf
			Else
				_cMsg := "Tamanho da mensagem: " + AllTrim(Str(LenStrJson)) + " - Bytes lidos: " + AllTrim(Str(nRetParser)) + CRLF
				_cMsg += "Erro a partir: " + SubStr(StrJson, (nRetParser + 1))
				U_GLogErro( _cDocto							,;		// Número da Nota Fiscal
							_cSerie							,;		// Série da Nota Fiscal
							_cCliente						,;		// Código do Cliente
							_cLojaCli						,;		// Loja do Cliente
							"CANCEL"						,;		// Nome do Método de WebService
							"JSON ERROR - Parser com Erro "	,;		// Título da Mensagem de Log de Erro
							_cMsg						 	 )		// Mensagem de Log de Erro
			EndIf

			FreeObj(oJson)

		Else
			_cMsg := "Ocorreu algum problema no momento de leitura do retorno do metodo referente a TAG " + CRLF
			_cMsg += "oXmlDoc:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CANCELRESPONSE:_RETURN:TEXT"
			U_GLogErro( _cDocto										,;		// Número da Nota Fiscal
						_cSerie										,;		// Série da Nota Fiscal
						_cCliente									,;		// Código do Cliente
						_cLojaCli									,;		// Loja do Cliente
						"CANCEL"									,;		// Nome do Método de WebService
						"ENVRET - Retorno leitura TAG com Erro "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 			 )		// Mensagem de Log de Erro
		Endif
	EndIf

	RestArea(aArea)

Return cStatus
