#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "MSOLE.CH" 
#INCLUDE "COLORS.CH"

#DEFINE BR Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} VIEW
Método de consulta de uma cobrança
@author     Evandro
@since      Jan/2021
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
User Function VIEW()

	Local nOpcA	   := 0
	Local aSize    := {}
	Local aObjects := {} 
	Local aInfo    := {} 
	Local aPosObj  := {} 
	Local bOk 	   := {|| IIF(_TudOk(), ( nOpcA := 1, _oTela:End() ), ) }
	Local bCancel  := {|| nOpcA := 2, _oTela:End() }
	Local oFont	   := NIL
	Local cButton := "QPushButton {" ;
	 						+ BR + " background: #FF8C00;";							 	// Cor do fundo
	 						+ BR + " border: 1px solid #096A82;";						// Cor da borda
	 						+ BR + " outline:0;";
	 						+ BR + " border-radius: 5px;"; 								// Arrerondamento da borda
	 						+ BR + " font: normal 15px Arial Black;"; 
	 						+ BR + " padding: 6px;";
	 						+ BR + " color: #000000;";									// Cor da fonte
	 						+ BR + " }";
	 						+ BR + " QPushButton:pressed {";							// Ações quando pressionado botão
	 						+ BR + " background-color: #FF8C00;border-style: inset;"; 
	 						+ BR + " border-color: #FF8C00;";
	 						+ BR + " color: #000000;";
	 						+ BR + " }"

	aSize := MsAdvSize(.F.)
	/*
	aSize[1] = 1 -> Linha inicial área trabalho.
	aSize[2] = 2 -> Coluna inicial área trabalho.
	aSize[3] = 3 -> Linha final área trabalho.
	aSize[4] = 4 -> Coluna final área trabalho.
	aSize[5] = 5 -> Coluna final dialog (janela).
	aSize[6] = 6 -> Linha final dialog (janela).
	aSize[7] = 7 -> Linha inicial dialog (janela).
	*/
	Aadd( aObjects, { 100, 100, .T., .T. } )
	Aadd( aObjects, { 315,  70, .T., .T. } )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .F. ) 

	Private _cInteg   := Space(02)
	Private _cDescr	  := Space(30)
	Private _cChkID   := Space(41)
	Private _CallStat := Space(10)
	Private _CallMess := Space(100)
	Private _CallCode := Space(03)
	Private _Integrad := Space(02)
	Private _DescInte := Space(30)
	Private _Checkout := Space(41)
	Private _Referenc := Space(64)
	Private _Status   := Space(64)
	Private _Crea_at  := Space(28)
	Private _Paid_at  := Space(28)
	Private _Payres_m := Space(100)
	Private _Payres_r := Space(20)
	Private _Paymet_t := Space(20)
	Private _Paymet_i := Space(02)
	Private _Amount_v := 0
	Private _Sumary_t := 0
	Private _Sumary_p := 0
	Private _Sumary_r := 0
	Private _Card_id  := Space(41)
	Private _Card_bra := Space(20)
	Private _Last_dig := Space(04)
	Private _Card_nam := Space(30)

	DEFINE FONT oFont  NAME "Arial" SIZE 0,-18 Bold
	
	//Se não utilizar o MsAdvSize, pode-se utilizar a propriedade lMaximized igual a T para maximizar a janela
	//Usando o estilo STYLE DS_MODALFRAME, remove o botão X
	DEFINE MSDIALOG _oTela TITLE OemToAnsi("Consulta de uma Cobrança") STYLE DS_MODALFRAME FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
	_oTela:lMaximized := .T. 	// Maximiza a janela

	_cDescCab := "Informe a Integradora e o Checkout ID para realizar a consulta de uma cobrança com a posição real da mesma"
	@ (aPosObj[1,1] + 030),(aPosObj[2,2] + 005) Say _cDescCab 													Size 900 , 012 Of _oTela Pixel Font oFont COLOR CLR_BLACK  

	@ (aPosObj[1,1] + 050),(aPosObj[2,2] + 005) Say OemToAnsi("Integradora")									Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_MAGENTA
	@ (aPosObj[1,1] + 050),(aPosObj[2,2] + 060) MsGet _cInteg When .T. VALID !Vazio() .And. _VldInt() F3 "ZK0"	Size 025 , 011 Of _oTela Pixel Font oFont
	@ (aPosObj[1,1] + 050),(aPosObj[2,2] + 100) MsGet _cDescr When .F.											Size 310 , 011 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 065),(aPosObj[2,2] + 005) Say OemToAnsi("Checkout ID")									Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_MAGENTA
	@ (aPosObj[1,1] + 065),(aPosObj[2,2] + 060) MsGet _cChkID When .T. VALID !Vazio()							Size 350 , 011 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 090),(aPosObj[2,2] + 005) Say OemToAnsi("Status da chamada")						Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 090),(aPosObj[2,2] + 200) MsGet _CallStat	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont
	
	@ (aPosObj[1,1] + 102),(aPosObj[2,2] + 005) Say OemToAnsi("Mensagem da chamada")					Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 102),(aPosObj[2,2] + 200) MsGet _CallMess	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 114),(aPosObj[2,2] + 005) Say OemToAnsi("Código da chamada")						Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 114),(aPosObj[2,2] + 200) MsGet _CallCode	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 126),(aPosObj[2,2] + 005) Say OemToAnsi("Código da integradora")					Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 126),(aPosObj[2,2] + 200) MsGet _Integrad	When .F.								Size 025 , 010 Of _oTela Pixel Font oFont
	@ (aPosObj[1,1] + 126),(aPosObj[2,2] + 240) MsGet _DescInte	When .F.								Size 510 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 138),(aPosObj[2,2] + 005) Say OemToAnsi("Identificador da transação")				Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 138),(aPosObj[2,2] + 200) MsGet _Checkout	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 150),(aPosObj[2,2] + 005) Say OemToAnsi("Número da nota fiscal")					Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 150),(aPosObj[2,2] + 200) MsGet _Referenc	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 162),(aPosObj[2,2] + 005) Say OemToAnsi("Status da cobrança")						Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 162),(aPosObj[2,2] + 200) MsGet _Status  	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 174),(aPosObj[2,2] + 005) Say OemToAnsi("Data da criação da transação")			Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 174),(aPosObj[2,2] + 200) MsGet _Crea_at 	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 186),(aPosObj[2,2] + 005) Say OemToAnsi("Data da efetivação do pagamento")		Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 186),(aPosObj[2,2] + 200) MsGet _Paid_at 	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 198),(aPosObj[2,2] + 005) Say OemToAnsi("Identificador do emissor do cartão")		Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 198),(aPosObj[2,2] + 200) MsGet _Payres_m	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 210),(aPosObj[2,2] + 005) Say OemToAnsi("Status do emissor do cartão")			Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 210),(aPosObj[2,2] + 200) MsGet _Payres_r	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 222),(aPosObj[2,2] + 005) Say OemToAnsi("Método de pagamento")					Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 222),(aPosObj[2,2] + 200) MsGet _Paymet_t	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 234),(aPosObj[2,2] + 005) Say OemToAnsi("Número de parcelas")						Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 234),(aPosObj[2,2] + 200) MsGet _Paymet_i	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 246),(aPosObj[2,2] + 005) Say OemToAnsi("Valor a ser cobrado")					Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 246),(aPosObj[2,2] + 180) Say OemToAnsi("R$")                   					Size 030 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 246),(aPosObj[2,2] + 200) MsGet Transform(_Amount_v, "@E 9,999,999.99") When .F.	Size 060 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 258),(aPosObj[2,2] + 005) Say OemToAnsi("Valor total da cobrança")				Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 258),(aPosObj[2,2] + 180) Say OemToAnsi("R$")                   					Size 030 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 258),(aPosObj[2,2] + 200) MsGet Transform(_Sumary_t, "@E 9,999,999.99") When .F.	Size 060 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 270),(aPosObj[2,2] + 005) Say OemToAnsi("Valor que foi pago da cobrança")			Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 270),(aPosObj[2,2] + 180) Say OemToAnsi("R$")                   					Size 030 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 270),(aPosObj[2,2] + 200) MsGet Transform(_Sumary_p, "@E 9,999,999.99") When .F.	Size 060 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 282),(aPosObj[2,2] + 005) Say OemToAnsi("Valor que foi devolvido da cobrança")	Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 282),(aPosObj[2,2] + 180) Say OemToAnsi("R$")                   					Size 030 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 282),(aPosObj[2,2] + 200) MsGet Transform(_Sumary_r, "@E 9,999,999.99") When .F.	Size 060 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 294),(aPosObj[2,2] + 005) Say OemToAnsi("Cartão tokenizado")						Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 294),(aPosObj[2,2] + 200) MsGet _Card_id 	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 306),(aPosObj[2,2] + 005) Say OemToAnsi("Bandeira do cartão de crédito")			Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 306),(aPosObj[2,2] + 200) MsGet _Card_bra	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 318),(aPosObj[2,2] + 005) Say OemToAnsi("Últimos 4 dígitos do cartão de crédito")	Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 318),(aPosObj[2,2] + 200) MsGet _Last_dig	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	@ (aPosObj[1,1] + 330),(aPosObj[2,2] + 005) Say OemToAnsi("Nome do portador do cartão de crédito")	Size 300 , 010 Of _oTela Pixel Font oFont COLOR CLR_CYAN
	@ (aPosObj[1,1] + 330),(aPosObj[2,2] + 200) MsGet _Card_nam	When .F.								Size 550 , 010 Of _oTela Pixel Font oFont

	oButton1:= TButton():New( (aPosObj[1,1] + 063), (aPosObj[2,2] + 450), "CONSULTAR",_oTela,{|| _ConsMet(_cInteg,_cChkID)}, 65, 16,,,.F.,.T.,.F.,,.F.,,,.F. ) 
	oButton1:SetCss(cButton)
	
	ACTIVATE MSDIALOG _oTela ON INIT EnchoiceBar(_oTela, bOk , bCancel) CENTERED

	// Deixado esta validação caso seja necessário implementar quando clicado na confirmação ou cancelamento da tela
	If nOpcA == 1
	Else
	Endif
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _VldInt
Função que efetua a consistência na integradora informada
@author     Evandro
@since      Jan/2021
@return 	_lRet, .T. ou .F. 
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function _VldInt()

	_lRet := .T.

	DbSelectArea("ZK0")
	DbSeek(xFilial("ZK0") + _cInteg)
	If Found()
		_cDescr := ZK0->ZK0_NOMINT
	Else
		MsgAlert("Integradora Informada Não Existe. Verifique!")
		_lRet := .F.
	Endif

Return(_lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} _TudoOk
Função que efetua validação de tudo ok na confirmação da tela
@author     Evandro
@since      Jan/2021
@return 	_lRet, .T. ou .F. 
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function _TudOk()

	Local _lRet := .T.

	// MsgAlert("Aqui implementar validação de tudo ok caso necessário")

Return(_lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} _ConsMet
Função que executa o método de consulta de cobrança (Envio e Retorno)
@author     Evandro
@since      Jan/2021
@param 		_cInteg, Código da integradora
			_cChkID, Identificador da transação
@return 	Nil 
@obs        Serão retornados para consulta os campos conforme definição do método
/*/
//-------------------------------------------------------------------
Static Function _ConsMet(_cInteg, _cChkID)

	Local aArea      := GetArea()
	Local lRet       := .T.
	//Local cURL     := "https://hml.portaldocliente.hotmedia.com.br/api/v1/ws/frigorifico/paymentSoap?wsdl"	// Ambiente HOmologação
	Local cURL       := "https://portaldocliente.hotmedia.com.br/api/v1/ws/frigorifico/paymentSoap?wsdl"		// Ambiente Produção
	Local cSoapSend  := ""
	Local cSoapRet   := ""
	Local oWsdl      := Nil
	Local cError     := ""
	Local cWarning   := ""
	Local cXmlGet  	 := ""
	Local lContinua  := .T.
	Local _cCodInt   := _cInteg
	Local _cCodID    := _cChkID

	Local oJson 	 := Nil
	Local StrJson 	 := ''
	Local LenStrJson := 0
	Local JsonFields := Nil
	Local nRetParser := 0
	Local lRetJson 	 := .F.
	
	Private oXmlDoc

	_CallStat := Space(10)
	_CallMess := Space(100)
	_CallCode := Space(03)
	_Integrad := Space(02)
	_DescInte := Space(30)
	_Checkout := Space(41)
	_Referenc := Space(64)
	_Status   := Space(64)
	_Crea_at  := Space(28)
	_Paid_at  := Space(28)
	_Payres_m := Space(100)
	_Payres_r := Space(20)
	_Paymet_t := Space(20)
	_Paymet_i := Space(02)
	_Amount_v := 0
	_Sumary_t := 0
	_Sumary_p := 0
	_Sumary_r := 0
	_Card_id  := Space(41)
	_Card_bra := Space(20)
	_Last_dig := Space(04)
	_Card_nam := Space(30)

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
	//³ Método View   t  		                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Se for continuar o processamento
	If lContinua
		// Tenta fazer o Parse da URL
		lRet := oWsdl:ParseURL(cURL)
		If !lRet 
			_cMsg := oWsdl:cError
			U_GLogErro( "CONSULTA"					,;		// Número da Nota Fiscal
						""							,;		// Série da Nota Fiscal
						""							,;		// Código do Cliente
						""							,;		// Loja do Cliente
						"VIEW"						,;		// Nome do Método de WebService
						"CONSMET - Erro ParseURL: "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 )		// Mensagem de Log de Erro
			lContinua := .F.
		EndIf
	EndIf

	// Se for continuar o processamento
	If lContinua
		// Tenta definir a operação
		lRet := oWsdl:SetOperation("view")
		If !lRet 
			_cMsg := oWsdl:cError
			U_GLogErro( "CONSULTA"						,;		// Número da Nota Fiscal
						""								,;		// Série da Nota Fiscal
						""								,;		// Código do Cliente
						""								,;		// Loja do Cliente
						"VIEW"							,;		// Nome do Método de WebService
						"CONSMET - Erro SetOperation: "	,;		// Título da Mensagem de Log de Erro
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
		cSoapSend += ' 	 <SOAP-ENV:Header>'																		+ CRLF
		cSoapSend += '	    <ns2:AuthToken>'																	+ CRLF
		cSoapSend += '	       <Password>' + AllTrim( _Pass ) + '</Password>'									+ CRLF
		cSoapSend += '	       <Username>' + AllTrim( _User ) + '</Username>'									+ CRLF
		cSoapSend += '	       <Created>' + AllTrim( _Crea ) + '</Created>'										+ CRLF
		cSoapSend += '	    </ns2:AuthToken>'																	+ CRLF
		cSoapSend += '	 </SOAP-ENV:Header>'																	+ CRLF
		cSoapSend += '	 <SOAP-ENV:Body>'																		+ CRLF
		cSoapSend += '	    <ns1:view>'																			+ CRLF
		cSoapSend += '	       <dataArray xsi:type="ns1:ChargeViewDataType">'									+ CRLF
		cSoapSend += '			  <integradora xsi:type="xsd:int">' + AllTrim( _cCodInt ) + '</integradora>'	+ CRLF
		cSoapSend += '			  <checkout_id xsi:type="xsd:string">' + AllTrim( _cCodID ) + '</checkout_id>'	+ CRLF
		cSoapSend += '	       </dataArray>'																	+ CRLF
		cSoapSend += '	    </ns1:view>'																		+ CRLF
		cSoapSend += '	 </SOAP-ENV:Body>'																		+ CRLF
		cSoapSend += '</SOAP-ENV:Envelope>'																		+ CRLF

		// Envia uma mensagem SOAP personalizada ao servidor
		lRet := oWsdl:SendSoapMsg(cSoapSend)
		If !lRet 
			_cMsg := oWsdl:cError
			U_GLogErro( "CONSULTA"						,;		// Número da Nota Fiscal
						""								,;		// Série da Nota Fiscal
						""								,;		// Código do Cliente
						""								,;		// Loja do Cliente
						"VIEW"							,;		// Nome do Método de WebService
						"CONSMET - Erro SendSoapMsg: "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 )		// Mensagem de Log de Erro

			_cMsg := oWsdl:cFaultCode
			U_GLogErro( "CONSULTA"									,;		// Número da Nota Fiscal
						""											,;		// Série da Nota Fiscal
						""											,;		// Código do Cliente
						""											,;		// Loja do Cliente
						"VIEW"										,;		// Nome do Método de WebService
						"CONSMET - Erro SendSoapMsg FaultCode: "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 			 )		// Mensagem de Log de Erro
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
			U_GLogErro( "CONSULTA"						,;		// Número da Nota Fiscal
						""								,;		// Série da Nota Fiscal
						""								,;		// Código do Cliente
						""								,;		// Loja do Cliente
						"VIEW"							,;		// Nome do Método de WebService
						"CONSMET - Alerta cWarning: "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 )		// Mensagem de Log de Erro
		EndIf

		// Se houve erro, não permitirá prosseguir
		If !Empty(cError)
			_cMsg := cError
			U_GLogErro( "CONSULTA"						,;		// Número da Nota Fiscal
						""								,;		// Série da Nota Fiscal
						""								,;		// Código do Cliente
						""								,;		// Loja do Cliente
						"VIEW"							,;		// Nome do Método de WebService
						"CONSMET - Erro cError: "		,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 )		// Mensagem de Log de Erro
			lContinua := .F.
		EndIf
	EndIf

	// Se for continuar
	If lContinua
		If (Type("oXmlDoc:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_VIEWRESPONSE:_RETURN:TEXT") != "U")

			// Pega tag que contém XML
			cXmlGet := oXmlDoc:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_VIEWRESPONSE:_RETURN:TEXT

			oJson := tJsonParser():New()
			   
			StrJson    := cXmlGet
			LenStrJson := Len(StrJson)
			JsonFields := {}
			lRetJson   := oJson:Json_Parser(StrJson, LenStrJson, @JsonFields, @nRetParser)

			If lRetJson
			  	// Retorna dados para consulta se retorno do call_status do método view for verdadeiro
			  	If JsonFields[1][2][2][2][1][2]
					_CallStat := "VERDADEIRO"
					_CallMess := Upper(JsonFields[1][2][2][2][2][2])
					_CallCode := cValToChar(JsonFields[1][2][2][2][3][2])
					_Integrad := StrZero(JsonFields[1][2][2][2][4][2],2,0)
					_DescInte := GetAdvFVal("ZK0", "ZK0_NOMINT", xFilial("ZK0") + StrZero(JsonFields[1][2][2][2][4][2],2,0), 1, Space(TamSx3("ZK0_NOMINT")[1]), .T.)	// Nome Integradora 
					_Checkout := JsonFields[1][2][2][2][5][2]
					_Referenc := "NF: " + Substr(JsonFields[1][2][2][2][6][2],1,9) + "   Série: " + Substr(JsonFields[1][2][2][2][6][2],10,3)
					_Status   := JsonFields[1][2][2][2][7][2]
					_Crea_at  := JsonFields[1][2][2][2][8][2]
					_Paid_at  := JsonFields[1][2][2][2][9][2]
					_Payres_m := JsonFields[1][2][2][2][10][2]
					_Payres_r := JsonFields[1][2][2][2][11][2]
					_Paymet_t := JsonFields[1][2][2][2][12][2]
					_Paymet_i := cValToChar(JsonFields[1][2][2][2][13][2])
					_Amount_v := JsonFields[1][2][2][2][14][2] / 100
					_Sumary_t := JsonFields[1][2][2][2][15][2] / 100
					_Sumary_p := JsonFields[1][2][2][2][16][2] / 100
					_Sumary_r := JsonFields[1][2][2][2][17][2] / 100
					_Card_id  := cValToChar(JsonFields[1][2][2][2][18][2])
					_Card_bra := Upper(JsonFields[1][2][2][2][19][2])
					_Last_dig := JsonFields[1][2][2][2][20][2]
					_Card_nam := Upper(JsonFields[1][2][2][2][21][2])
				Else
					_CallStat := "FALSO"
					_CallMess := JsonFields[1][2][2][2][2][2]
					_CallCode := cValToChar(JsonFields[1][2][2][2][3][2])
					_Integrad := StrZero(JsonFields[1][2][2][2][4][2],2,0)
					_DescInte := GetAdvFVal("ZK0", "ZK0_NOMINT", xFilial("ZK0") + StrZero(JsonFields[1][2][2][2][4][2],2,0), 1, Space(TamSx3("ZK0_NOMINT")[1]), .T.)	// Nome Integradora 
					_Checkout := JsonFields[1][2][2][2][5][2]

					_cMsg := "Retorno do metodo foi 'FALSO' e por esse motivo a transação não foi aprovada. "
					U_GLogErro( "CONSULTA"							,;		// Número da Nota Fiscal
								""									,;		// Série da Nota Fiscal
								""									,;		// Código do Cliente
								""									,;		// Loja do Cliente
								"VIEW"								,;		// Nome do Método de WebService
								"JSON PARSER - Call Status False "	,;		// Título da Mensagem de Log de Erro
								_cMsg						 	 	 )		// Mensagem de Log de Erro
				EndIf
			Else
				_cMsg := "Tamanho da mensagem: " + AllTrim(Str(LenStrJson)) + " - Bytes lidos: " + AllTrim(Str(nRetParser)) + CRLF
				_cMsg += "Erro a partir: " + SubStr(StrJson, (nRetParser + 1))
				U_GLogErro( "CONSULTA"						,;		// Número da Nota Fiscal
							""								,;		// Série da Nota Fiscal
							""								,;		// Código do Cliente
							""								,;		// Loja do Cliente
							"VIEW"							,;		// Nome do Método de WebService
							"JSON ERROR - Parser com Erro "	,;		// Título da Mensagem de Log de Erro
							_cMsg						 	 )		// Mensagem de Log de Erro
			EndIf

			FreeObj(oJson)

		Else
			_cMsg := "Ocorreu algum problema no momento de leitura do retorno do metodo referente a TAG " + CRLF
			_cMsg += "oXmlDoc:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_VIEWRESPONSE:_RETURN:TEXT"
			U_GLogErro( "CONSULTA"									,;		// Número da Nota Fiscal
						""											,;		// Série da Nota Fiscal
						""											,;		// Código do Cliente
						""											,;		// Loja do Cliente
						"VIEW"										,;		// Nome do Método de WebService
						"CONSMET - Retorno leitura TAG com Erro "	,;		// Título da Mensagem de Log de Erro
						_cMsg						 	 			 )		// Mensagem de Log de Erro
		Endif
	EndIf

	RestArea(aArea)

Return
	