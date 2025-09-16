// Bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"

/*
===============================================================================
WSDL Location    http://10.0.0.239:99/ws/wsMpNotificacaoIntegradora.apw?WSDL
Gerado em        04/01/2021
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
===============================================================================
*/


// Atributos de Entrada
WSSTRUCT notifRequest

	WSDATA date_n	 				AS STRING		//DATETIME
	WSDATA checkout_id				AS STRING
	WSDATA type_n					AS INTEGER
	WSDATA status					AS INTEGER
	WSDATA lastEventDate			AS STRING		//DATETIME
	WSDATA paymethod_type			AS INTEGER
	WSDATA paymethod_code			AS INTEGER
	WSDATA grossAmount				AS FLOAT
	WSDATA discountAmount			AS FLOAT
	WSDATA installmentFeeAmount		AS FLOAT
	WSDATA intermediationRateAmount	AS FLOAT
	WSDATA intermediationFeeAmount	AS FLOAT
	WSDATA netAmount				AS FLOAT
	WSDATA extraAmount				AS FLOAT
	WSDATA escrowEndDate			AS STRING		//DATETIME
	WSDATA installmentCount			AS INTEGER

ENDWSSTRUCT


// Atributos com a estrutura com os dados que são exibidos no xml do webservice
// Isso é o que retornará para quem fizer a requisição
WSSTRUCT notifResponse

	WSDATA call_status	AS BOOLEAN
	WSDATA call_message AS STRING
	WSDATA call_code	AS STRING

ENDWSSTRUCT


// Cria a tag de Webservice
WSSERVICE wsMpNotificacaoIntegradora Description "WebService Meios de Pagamentos - Notificacao Integradora"

	// Propriedades
	WSDATA notifReq AS notifRequest 	 // Chama a estrutura dos dados de requisição
	WSDATA notifRes AS notifResponse     // Chama a estrutura dos dados de resposta

	// Declara os metodos
	WSMETHOD infoNOTIF Description "<b> Metodo de retorno da notificacao da integradora</b><br> <u>Retorno</u><br> call_status, call_message e call_code  

ENDWSSERVICE	// Fecha o servico


WSMETHOD infoNOTIF WSRECEIVE notifReq WSSEND notifRes WSSERVICE wsMpNotificacaoIntegradora
	
	Local aPv   := {}
	Local aDad  := {}

	RPCSetType(3) 	// Não Consome Licença
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'OMS' TABLES 'SA1'

	aPv := U_MailNI(::notifReq:date_n, ::notifReq:checkout_id, ::notifReq:type_n, ::notifReq:status, ::notifReq:lastEventDate, ::notifReq:paymethod_type, ::notifReq:paymethod_code, ::notifReq:grossAmount, ::notifReq:discountAmount,;
					::notifReq:installmentFeeAmount, ::notifReq:intermediationRateAmount, ::notifReq:intermediationFeeAmount, ::notifReq:netAmount, ::notifReq:extraAmount, ::notifReq:escrowEndDate, ::notifReq:installmentCount)

	If Len(aPv[1]) > 0

		aDad := aPv[1]

		::notifRes:call_status  := aDad[1]
		::notifRes:call_message := aDad[2]
		::notifRes:call_code	:= aDad[3]
		
	Else

		::notifRes:call_status  := aDad[1]
		::notifRes:call_message := aDad[2]
		::notifRes:call_code	:= aDad[3]

	Endif

Return .T.


// Função que envia e-mail referente a notificação da integradora recebida
User Function MailNI(_Data, _ChkID, _Tipo, _Status, _DtUlEv, _MetPgto, _CodPgto, _VlrBrut, _VlrDesc, _VlrTxParc, _VlrTxIntR, _VlrTxIntF, _VlrLiq, _VlrExtra, _DtFimGar, _NumParc)

	Local lEnv := .F.
	Local aRet := {}
	Local aDad := {}
	Local _cAssunto := "Evento de Notificação da PAGSEGURO"
	Local _cTexto	:= ""
	Local _cMail    := "clailton.soares@frigorificosilva.com.br" 
	Local _cMailCC  := "" 
	//Local _cMail    := "technical@hotmedia.com.br" 
	//Local _cMailCC  := "roberto.trevisan@hotmedia.com.br" 

	//_Var01 := Substr(_Data,9,2) + "/" + Substr(_Data,6,2) + "/" + Substr(_Data,1,4) + " as " + Substr(_Data,12,8) + "hs"
	_Var01 := _Data
	_Var02 := _ChkID
	_Var03 := cValToChar(_Tipo)
	_DescVar03 := "Pagamento"
	_Var04 := cValToChar(_Status)
	DO CASE
		CASE _Var04 == "1"
			_DescVar04 := "Aguardando pagamento"
		CASE _Var04 == "2"
			_DescVar04 := "Em análise"
		CASE _Var04 == "3"
			_DescVar04 := "Paga"
		CASE _Var04 == "4"
			_DescVar04 := "Disponível"
		CASE _Var04 == "5"
			_DescVar04 := "Em disputa"
		CASE _Var04 == "6"
			_DescVar04 := "Devolvida"
		CASE _Var04 == "7"
			_DescVar04 := "Cancelada"
		CASE _Var04 == "8"
			_DescVar04 := "Debitado"
		CASE _Var04 == "9"
			_DescVar04 := "Retenção temporária"
		OTHERWISE
			_DescVar04 := "STATUS INEXISTENTE"
	ENDCASE
	//_Var05 := Substr(_DtUlEv,9,2) + "/" + Substr(_DtUlEv,6,2) + "/" + Substr(_DtUlEv,1,4) + " as " + Substr(_DtUlEv,12,8) + "hs"
	_Var05 := _DtUlEv
	_Var06 := cValToChar(_MetPgto)
	_DescVar06 := "Cartão de Crédito"
	_Var07 := cValToChar(_CodPgto)
	DO CASE
		CASE _Var07 == "101"
			_DescVar07 := "Cartão de crédito Visa"
		CASE _Var07 == "102"
			_DescVar07 := "Cartão de crédito MasterCard"
		CASE _Var07 == "103"
			_DescVar07 := "Cartão de crédito American Express"
		CASE _Var07 == "104"
			_DescVar07 := "Cartão de crédito Diners"
		CASE _Var07 == "105"
			_DescVar07 := "Cartão de crédito Hipercard"
		CASE _Var07 == "106"
			_DescVar07 := "Cartão de crédito Aura"
		CASE _Var07 == "107"
			_DescVar07 := "Cartão de crédito Elo"
		CASE _Var07 == "108"
			_DescVar07 := "Cartão de crédito PLENOCard"
		CASE _Var07 == "109"
			_DescVar07 := "Cartão de crédito PersonalCard"
		CASE _Var07 == "110"
			_DescVar07 := "Cartão de crédito JCB"
		CASE _Var07 == "111"
			_DescVar07 := "Cartão de crédito Discover"
		CASE _Var07 == "112"
			_DescVar07 := "Cartão de crédito BrasilCard"
		CASE _Var07 == "113"
			_DescVar07 := "Cartão de crédito FORTBRASIL"
		CASE _Var07 == "114"
			_DescVar07 := "Cartão de crédito CARDBAN"
		CASE _Var07 == "115"
			_DescVar07 := "Cartão de crédito VALECARD"
		CASE _Var07 == "116"
			_DescVar07 := "Cartão de crédito Cabal"
		CASE _Var07 == "117"
			_DescVar07 := "Cartão de crédito Mais"
		CASE _Var07 == "118"
			_DescVar07 := "Cartão de crédito Avista"
		CASE _Var07 == "119"
			_DescVar07 := "Cartão de crédito GRANDCARD"
		CASE _Var07 == "120"
			_DescVar07 := "Cartão de crédito Sorocred"
		CASE _Var07 == "122"
			_DescVar07 := "Cartão de crédito Up Policard"
		CASE _Var07 == "123"
			_DescVar07 := "Cartão de crédito Banese Card"
		CASE _Var07 == "201"
			_DescVar07 := "Boleto Bradesco"
		CASE _Var07 == "202"
			_DescVar07 := "Boleto Santander"
		CASE _Var07 == "301"
			_DescVar07 := "Débito online Bradesco"
		CASE _Var07 == "302"
			_DescVar07 := "Débito online Itaú"
		CASE _Var07 == "303"
			_DescVar07 := "Débito online Unibanco"
		CASE _Var07 == "304"
			_DescVar07 := "Débito online Banco do Brasil"
		CASE _Var07 == "305"
			_DescVar07 := "Débito online Banco Real"
		CASE _Var07 == "306"
			_DescVar07 := "Débito online Banrisul"
		CASE _Var07 == "307"
			_DescVar07 := "Débito online HSBC"
		CASE _Var07 == "401"
			_DescVar07 := "Saldo PagSeguro"
		CASE _Var07 == "501"
			_DescVar07 := "Oi Paggo"
		CASE _Var07 == "701"
			_DescVar07 := "Depósito em conta - Banco do Brasil"
		OTHERWISE
			_DescVar07 := "CÓDIGO MEIO DE PAGAMENTO INEXISTENTE"
	ENDCASE
	_Var08 := Transform(_VlrBrut, '@E 999,999.99')
	_Var09 := Transform(_VlrDesc, '@E 999,999.99')
	_Var10 := Transform(_VlrTxParc, '@E 999,999.99')
	_Var11 := Transform(_VlrTxIntR, '@E 999,999.99')
	_Var12 := Transform(_VlrTxIntF, '@E 999,999.99')
	_Var13 := Transform(_VlrLiq, '@E 999,999.99')
	_Var14 := Transform(_VlrExtra, '@E 999,999.99')
	//_Var15 := Substr(_DtFimGar,9,2) + "/" + Substr(_DtFimGar,6,2) + "/" + Substr(_DtFimGar,1,4) + " as " + Substr(_DtFimGar,12,8) + "hs"
	_Var15 := _DtFimGar
	_Var16 := cValToChar(_NumParc)

	// Montagem do texto do corpo do e-mail
	_cTexto := '<html>'
	_cTexto += '<body>'
	_cTexto += '<div style="width: 776px;"><img src="http://portais.frigorificosilva.com.br:91/vendedor/imagens/pagseguro.jpg" alt="" /></div>'
	_cTexto += '<div style="width: 776px;">&nbsp;</div>'
	_cTexto += '<h3 style="width: 776px;">Foi recebido um evento de notificação de status de uma cobrança, gerada pela integradora contendo as informações abaixo:</h3>'
	_cTexto += '<h4><span style="background-color: #ffcc00;">Data da criação da transação:</span> ' + _Var01 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffcc00;">Identificador da transação (Checkout ID):</span> ' + _Var02 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffcc00;">Tipo da transação:</span> ' + _Var03 + ' - ' + _DescVar03 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffcc00;">Status da transação:</span> ' + _Var04 + ' - ' + _DescVar04 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffcc00;">Data do último evento:</span> ' + _Var05 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffcc00;">Tipo do meio de pagamento:</span> ' + _Var06 + ' - ' + _DescVar06 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffcc00;">Código identificador do meio de pagamento:</span> ' + _Var07 + ' - ' + _DescVar07 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffffff;"><span style="background-color: #ffcc00;">Valor bruto da transação:</span> R$</span> ' + _Var08 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffffff;"><span style="background-color: #ffcc00;">Valor de desconto dado:</span> R$</span> ' + _Var09 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffffff;"><span style="background-color: #ffcc00;">Valor total das taxas cobradas:</span> R$</span> ' + _Var10 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffffff;"><span style="background-color: #ffcc00;">Valor da taxa de intermediação:</span> R$</span> ' + _Var11 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffffff;"><span style="background-color: #ffcc00;">Valor da taxa de intermediação:</span> R$</span> ' + _Var12 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffffff;"><span style="background-color: #ffcc00;">Valor líquido da transação:</span> R$</span> ' + _Var13 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffcc00;">Valor extra somado ou subtraído da transação:</span> ' + _Var14 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffcc00;">Data em que o crédito estará disponível:</span> ' + _Var15 + '</h4>'
	_cTexto += '<h4><span style="background-color: #ffcc00;">Número de parcelas:</span> ' + _Var16 + '</h4>'
	_cTexto += '</body>'
	_cTexto += '</html>'
	
  	lEnv := _EnviaMail(_cMail, _cMailCC, _cAssunto, _cTexto, _ChkID)	

  	If lEnv
		AADD(aDad, .T.)										// resultado da chamada ao método (true/false)
		AADD(aDad, "e-Mail de evento de notificação de status da cobrança gerado pela integradora processado com sucesso")	// mensagem da chamada (somente se false)
		AADD(aDad, "200")									// código da chamada (somente se false)
	Else
		AADD(aDad, .F.)										// resultado da chamada ao método (true/false)
		AADD(aDad, "e-Mail de evento de notificação de status da cobrança gerado pela integradora não foi processado")	// mensagem da chamada (somente se false)
		AADD(aDad, "500")									// código da chamada (somente se false)
	Endif
	
	AADD(aRet,aDad)

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_EnviaMailº Autor ³ Evandro Mugnol	 º Data ³  Jan/2021   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍ¼ÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que Envia o E-mail.                 				  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _EnviaMail(_cMailDest, _cPara, _cAssunto, _cTexto, _CheckoutID)

// Parametros para envio de email
Local _cServer    := GETMV('MV_RELSERV') 	// Endereco SMTP
Local _cAccount   := GETMV('MV_RELACNT') 	// Conta
Local _cPassword  := GETMV('MV_RELPSW')  	// Senha
Local _lEnvEmail  := .T. 
Local _lConectou  := .F.
Local _lLogou     := .F.
Local _lEnviou    := .F.
Local _lDesconect := .F.

If !_lEnvEmail
   Return()
EndIF

// Faz a conexao com o servidor
CONNECT SMTP SERVER _cServer ACCOUNT _cAccount PASSWORD _cPassword Result _lConectou
If !_lConectou
	_cMsg := "ATENÇÃO! Não foi possível CONECTAR ao servidor de e-mail referente identificador de transação: " + _CheckoutID
	U_GLogErro( "CONECTAR"						,;		// Número da Nota Fiscal
				""								,;		// Série da Nota Fiscal
				""								,;		// Código do Cliente
				""								,;		// Loja do Cliente
				"wsMpNotificacaoIntegradora"	,;		// Nome do Método de WebService
				"Rotina _EnviaMail"				,;		// Título da Mensagem de Log de Erro
				_cMsg						 	 )		// Mensagem de Log de Erro
EndIf

// Faz o login no servidor
_lLogou := mailAuth(_cAccount, _cPassword)
If !_lLogou
	_cMsg := "ATENÇÃO! Não foi possível LOGAR no servidor de e-mail referente identificador de transação: " + _CheckoutID
	U_GLogErro( "LOGAR"							,;		// Número da Nota Fiscal
				""								,;		// Série da Nota Fiscal
				""								,;		// Código do Cliente
				""								,;		// Loja do Cliente
				"wsMpNotificacaoIntegradora"	,;		// Nome do Método de WebService
				"Rotina _EnviaMail"				,;		// Título da Mensagem de Log de Erro
				_cMsg						 	 )		// Mensagem de Log de Erro
EndIf

// Faz o envio do e-mail
If !Empty(_cPara)
	SEND MAIL FROM _cAccount TO _cMailDest CC _cPara SUBJECT _cAssunto BODY _cTexto FORMAT TEXT RESULT _lEnviou
Else
	SEND MAIL FROM _cAccount TO _cMailDest SUBJECT _cAssunto BODY _cTexto FORMAT TEXT RESULT _lEnviou	
EndIf

If !_lEnviou
	_cMsg := "ATENÇÃO! Não foi possível ENVIAR e-mail referente identificador de transação: " + _CheckoutID
	U_GLogErro( "ENVIAR"						,;		// Número da Nota Fiscal
				""								,;		// Série da Nota Fiscal
				""								,;		// Código do Cliente
				""								,;		// Loja do Cliente
				"wsMpNotificacaoIntegradora"	,;		// Nome do Método de WebService
				"Rotina _EnviaMail"				,;		// Título da Mensagem de Log de Erro
				_cMsg						 	 )		// Mensagem de Log de Erro
EndIf

// Desconecta do servidor
DISCONNECT SMTP SERVER RESULT _lDesconect	 	
		
Return _lEnviou  
