#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://portaldogado.vtsis.io/api/v1/ws/frigorifico/usuariosEditSoap/?wsdl
Gerado em        06/10/19 14:03:21
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KNLMLJC ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSUsuarioSoapService
------------------------------------------------------------------------------- */

WSCLIENT WSUsuarioSoapService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD updateData

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSupdateDatadataArray    AS UsuarioSoapService_UsuarioDataType
	WSDATA   creturn                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSUsuarioSoapService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20181218 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSUsuarioSoapService
	::oWSupdateDatadataArray := UsuarioSoapService_USUARIODATATYPE():New()
Return

WSMETHOD RESET WSCLIENT WSUsuarioSoapService
	::oWSupdateDatadataArray := NIL 
	::creturn            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSUsuarioSoapService
Local oClone := WSUsuarioSoapService():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:oWSupdateDatadataArray :=  IIF(::oWSupdateDatadataArray = NIL , NIL ,::oWSupdateDatadataArray:Clone() )
	oClone:creturn       := ::creturn
Return oClone

// WSDL Method updateData of Service WSUsuarioSoapService

WSMETHOD updateData WSSEND oWSupdateDatadataArray WSRECEIVE creturn WSCLIENT WSUsuarioSoapService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateData xmlns:q1="https://portaldogado.vtsis.io/api/v1/ws/frigorifico/usuariosEditSoap">'
cSoap += WSSoapValue("dataArray", ::oWSupdateDatadataArray, oWSupdateDatadataArray , "UsuarioDataType", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:updateData>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://portaldogado.vtsis.io/api/v1/ws/frigorifico/usuariosEditSoap#updateData",; 
	"RPCX","https://portaldogado.vtsis.io/api/v1/ws/frigorifico/usuariosEditSoap",,,; 
	"https://portaldogado.vtsis.io/api/v1/ws/frigorifico/usuariosEditSoap")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure UsuarioDataType

WSSTRUCT UsuarioSoapService_UsuarioDataType
	WSDATA   cTCCODIGO                 AS string OPTIONAL
	WSDATA   cTCSTATUS                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UsuarioSoapService_UsuarioDataType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UsuarioSoapService_UsuarioDataType
Return

WSMETHOD CLONE WSCLIENT UsuarioSoapService_UsuarioDataType
	Local oClone := UsuarioSoapService_UsuarioDataType():NEW()
	oClone:cTCCODIGO            := ::cTCCODIGO
	oClone:cTCSTATUS            := ::cTCSTATUS
Return oClone

WSMETHOD SOAPSEND WSCLIENT UsuarioSoapService_UsuarioDataType
	Local cSoap := ""
	cSoap += WSSoapValue("TCCODIGO", ::cTCCODIGO, ::cTCCODIGO , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCSTATUS", ::cTCSTATUS, ::cTCSTATUS , "string", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap


