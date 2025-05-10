#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://portaldogado.vtsis.io/api/v1/ws/frigorifico/abatesSoap/?wsdl
Gerado em        06/10/19 14:14:05
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _JLUKBFH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSAbateSoapService
------------------------------------------------------------------------------- */
WSCLIENT WSAbateSoapService

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
	WSDATA   oWSupdateDatadataArray    AS AbateSoapService_AbateDataType
	WSDATA   creturn                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSAbateSoapService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20181218 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSAbateSoapService
	::oWSupdateDatadataArray := AbateSoapService_ABATEDATATYPE():New()
Return

WSMETHOD RESET WSCLIENT WSAbateSoapService
	::oWSupdateDatadataArray := NIL 
	::creturn            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSAbateSoapService
Local oClone := WSAbateSoapService():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:oWSupdateDatadataArray :=  IIF(::oWSupdateDatadataArray = NIL , NIL ,::oWSupdateDatadataArray:Clone() )
	oClone:creturn       := ::creturn
Return oClone

// WSDL Method updateData of Service WSAbateSoapService

WSMETHOD updateData WSSEND oWSupdateDatadataArray WSRECEIVE creturn WSCLIENT WSAbateSoapService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateData xmlns:q1="https://portaldogado.vtsis.io/api/v1/ws/frigorifico/abatesSoap">'
cSoap += WSSoapValue("dataArray", ::oWSupdateDatadataArray, oWSupdateDatadataArray , "AbateDataType", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:updateData>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://portaldogado.vtsis.io/api/v1/ws/frigorifico/abatesSoap#updateData",; 
	"RPCX","https://portaldogado.vtsis.io/api/v1/ws/frigorifico/abatesSoap",,,; 
	"https://portaldogado.vtsis.io/api/v1/ws/frigorifico/abatesSoap")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure AbateDataType
WSSTRUCT AbateSoapService_AbateDataType
	WSDATA   cTCLOTE                   AS string OPTIONAL
	WSDATA   cTCCARCACA                AS string OPTIONAL
	WSDATA   cTCCPF_CNPJ               AS string OPTIONAL
	WSDATA   cTCDATAABATE              AS string OPTIONAL
	WSDATA   cTCHORAABATEINI           AS string OPTIONAL
	WSDATA   cTCNUMAM                  AS string OPTIONAL
	WSDATA   cTCTOTALLOTE              AS string OPTIONAL
	WSDATA   cTCSEQUENCIALLOTE         AS string OPTIONAL
	WSDATA   cTCSEQUENCIALABATE        AS string OPTIONAL
	WSDATA   cTCGORDURA                AS string OPTIONAL
	WSDATA   cTCDENT                   AS string OPTIONAL
	WSDATA   cTCPESO                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AbateSoapService_AbateDataType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AbateSoapService_AbateDataType
Return

WSMETHOD CLONE WSCLIENT AbateSoapService_AbateDataType
	Local oClone := AbateSoapService_AbateDataType():NEW()
	oClone:cTCLOTE              := ::cTCLOTE
	oClone:cTCCARCACA           := ::cTCCARCACA
	oClone:cTCCPF_CNPJ          := ::cTCCPF_CNPJ
	oClone:cTCDATAABATE         := ::cTCDATAABATE
	oClone:cTCHORAABATEINI      := ::cTCHORAABATEINI
	oClone:cTCNUMAM             := ::cTCNUMAM
	oClone:cTCTOTALLOTE         := ::cTCTOTALLOTE
	oClone:cTCSEQUENCIALLOTE    := ::cTCSEQUENCIALLOTE
	oClone:cTCSEQUENCIALABATE   := ::cTCSEQUENCIALABATE
	oClone:cTCGORDURA           := ::cTCGORDURA
	oClone:cTCDENT              := ::cTCDENT
	oClone:cTCPESO              := ::cTCPESO
Return oClone

WSMETHOD SOAPSEND WSCLIENT AbateSoapService_AbateDataType
	Local cSoap := ""
	cSoap += WSSoapValue("TCLOTE", ::cTCLOTE, ::cTCLOTE , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCCARCACA", ::cTCCARCACA, ::cTCCARCACA , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCCPF_CNPJ", ::cTCCPF_CNPJ, ::cTCCPF_CNPJ , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCDATAABATE", ::cTCDATAABATE, ::cTCDATAABATE , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCHORAABATEINI", ::cTCHORAABATEINI, ::cTCHORAABATEINI , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCNUMAM", ::cTCNUMAM, ::cTCNUMAM , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCTOTALLOTE", ::cTCTOTALLOTE, ::cTCTOTALLOTE , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCSEQUENCIALLOTE", ::cTCSEQUENCIALLOTE, ::cTCSEQUENCIALLOTE , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCSEQUENCIALABATE", ::cTCSEQUENCIALABATE, ::cTCSEQUENCIALABATE , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCGORDURA", ::cTCGORDURA, ::cTCGORDURA , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCDENT", ::cTCDENT, ::cTCDENT , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCPESO", ::cTCPESO, ::cTCPESO , "string", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap


