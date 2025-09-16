#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.0.20.13/bizFSWS/bizFSWS.asmx?WSDL
Gerado em        09/30/15 09:59:20
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
Alterações neste arquivo podem causar funcionamento incorreto
e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _VABSKML ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSbizFSWebService
------------------------------------------------------------------------------- */

WSCLIENT WSbizFSWebService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD dbConnectionTest
	WSMETHOD Version
	WSMETHOD sendLabelID_toDevice
	WSMETHOD setTotal_toDevice
	WSMETHOD setPLUCustomer_toDevice
	WSMETHOD DeletePLUCustomer_toDevice
	WSMETHOD getDataZAU010_QTYProdActive
	WSMETHOD getDataZAU010_LOTEStatus
	WSMETHOD getDataZAU010
	WSMETHOD setDataZAU010_toDevice
	WSMETHOD setDataZAU010_Sample_toDevice
	WSMETHOD setDataZAU010_LOTEStatus
	WSMETHOD delDataZAU010
	WSMETHOD setDevice_Sleep
	WSMETHOD setDevice_ActivateLevel

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSdbConnectionTestResult AS bizFSWebService_ArrayOfString
	WSDATA   oWSVersionResult          AS bizFSWebService_ArrayOfString
	WSDATA   ndeviceID                 AS int
	WSDATA   nvalue                    AS int
	WSDATA   lsendLabelID_toDeviceResult AS boolean
	WSDATA   ntotalID                  AS int
	WSDATA   lsetTotal_toDeviceResult  AS boolean
	WSDATA   nPlu                      AS int
	WSDATA   nCustomerID               AS int
	WSDATA   lsetPLUCustomer_toDeviceResult AS boolean
	WSDATA   lDeletePLUCustomer_toDeviceResult AS boolean
	WSDATA   nZAU_FILIAL               AS int
	WSDATA   nwithSchema               AS int
	WSDATA   oWSgetDataZAU010_QTYProdActiveResult AS SCHEMA
	WSDATA   cZAU_STATUS               AS string
	WSDATA   oWSgetDataZAU010_LOTEStatusResult AS SCHEMA
	WSDATA   nZAU_LINHA                AS int
	WSDATA   nDIAS                     AS int
	WSDATA   cZAU_NUM                  AS string
	WSDATA   nZAU_FLWPL                AS int
	WSDATA   oWSgetDataZAU010Result    AS SCHEMA
	WSDATA   oWSsendData               AS bizFSWebService_ZAU010Data
	WSDATA   nUpdateDataMain           AS int
	WSDATA   oWSsetDataZAU010_toDeviceResult AS bizFSWebService_Response
	WSDATA   cZAU_COD                  AS string
	WSDATA   cZAU_PLU                  AS string
	WSDATA   cZAU_CODCLI               AS string
	WSDATA   nZAU_QPUNI                AS int
	WSDATA   nZAU_QPCAIX               AS int
	WSDATA   nZAU_LAYETQ               AS int
	WSDATA   nZAU_TIPSER               AS int
	WSDATA   cZAU_IMCBAR               AS string
	WSDATA   cZAU_TARA                 AS string
	WSDATA   nMemoryText               AS int
	WSDATA   oWSsetDataZAU010_Sample_toDeviceResult AS bizFSWebService_Response
	WSDATA   oWSsetDataZAU010_LOTEStatusResult AS FSWebService_Response
	WSDATA   oWSdelDataZAU010Result    AS bizFSWebService_Response
	WSDATA   lsetDevice_SleepResult    AS boolean
	WSDATA   clevel                    AS string
	WSDATA   lsetDevice_ActivateLevelResult AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSbizFSWebService
	::Init()
	If !FindFunction("XMLCHILDEX")
		UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150327] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
	EndIf
Return Self

WSMETHOD INIT WSCLIENT WSbizFSWebService
	::oWSdbConnectionTestResult := bizFSWebService_ARRAYOFSTRING():New()
	::oWSVersionResult   := bizFSWebService_ARRAYOFSTRING():New()
	::oWSgetDataZAU010_QTYProdActiveResult := NIL 
	::oWSgetDataZAU010_LOTEStatusResult := NIL 
	::oWSgetDataZAU010Result := NIL 
	::oWSsendData        := bizFSWebService_ZAU010DATA():New()
	::oWSsetDataZAU010_toDeviceResult := bizFSWebService_RESPONSE():New()
	::oWSsetDataZAU010_Sample_toDeviceResult := bizFSWebService_RESPONSE():New()
	::oWSsetDataZAU010_LOTEStatusResult := bizFSWebService_RESPONSE():New()
	::oWSdelDataZAU010Result := bizFSWebService_RESPONSE():New()
Return

WSMETHOD RESET WSCLIENT WSbizFSWebService
	::oWSdbConnectionTestResult := NIL 
	::oWSVersionResult   := NIL 
	::ndeviceID          := NIL 
	::nvalue             := NIL 
	::lsendLabelID_toDeviceResult := NIL 
	::ntotalID           := NIL 
	::lsetTotal_toDeviceResult := NIL 
	::nPlu               := NIL 
	::nCustomerID        := NIL 
	::lsetPLUCustomer_toDeviceResult := NIL 
	::lDeletePLUCustomer_toDeviceResult := NIL 
	::nZAU_FILIAL        := NIL 
	::nwithSchema        := NIL 
	::oWSgetDataZAU010_QTYProdActiveResult := NIL 
	::cZAU_STATUS        := NIL 
	::oWSgetDataZAU010_LOTEStatusResult := NIL 
	::nZAU_LINHA         := NIL 
	::nDIAS              := NIL 
	::cZAU_NUM           := NIL 
	::nZAU_FLWPL         := NIL 
	::oWSgetDataZAU010Result := NIL 
	::oWSsendData        := NIL 
	::nUpdateDataMain    := NIL 
	::oWSsetDataZAU010_toDeviceResult := NIL 
	::cZAU_COD           := NIL 
	::cZAU_PLU           := NIL 
	::cZAU_CODCLI        := NIL 
	::nZAU_QPUNI         := NIL 
	::nZAU_QPCAIX        := NIL 
	::nZAU_LAYETQ        := NIL 
	::nZAU_TIPSER        := NIL 
	::cZAU_IMCBAR        := NIL 
	::cZAU_TARA          := NIL 
	::nMemoryText        := NIL 
	::oWSsetDataZAU010_Sample_toDeviceResult := NIL 
	::oWSsetDataZAU010_LOTEStatusResult := NIL 
	::oWSdelDataZAU010Result := NIL 
	::lsetDevice_SleepResult := NIL 
	::clevel             := NIL 
	::lsetDevice_ActivateLevelResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSbizFSWebService
	Local oClone := WSbizFSWebService():New()
	oClone:_URL          := ::_URL 
	oClone:oWSdbConnectionTestResult :=  IIF(::oWSdbConnectionTestResult = NIL , NIL ,::oWSdbConnectionTestResult:Clone() )
	oClone:oWSVersionResult :=  IIF(::oWSVersionResult = NIL , NIL ,::oWSVersionResult:Clone() )
	oClone:ndeviceID     := ::ndeviceID
	oClone:nvalue        := ::nvalue
	oClone:lsendLabelID_toDeviceResult := ::lsendLabelID_toDeviceResult
	oClone:ntotalID      := ::ntotalID
	oClone:lsetTotal_toDeviceResult := ::lsetTotal_toDeviceResult
	oClone:nPlu          := ::nPlu
	oClone:nCustomerID   := ::nCustomerID
	oClone:lsetPLUCustomer_toDeviceResult := ::lsetPLUCustomer_toDeviceResult
	oClone:lDeletePLUCustomer_toDeviceResult := ::lDeletePLUCustomer_toDeviceResult
	oClone:nZAU_FILIAL   := ::nZAU_FILIAL
	oClone:nwithSchema   := ::nwithSchema
	oClone:cZAU_STATUS   := ::cZAU_STATUS
	oClone:nZAU_LINHA    := ::nZAU_LINHA
	oClone:nDIAS         := ::nDIAS
	oClone:cZAU_NUM      := ::cZAU_NUM
	oClone:nZAU_FLWPL    := ::nZAU_FLWPL
	oClone:oWSsendData   :=  IIF(::oWSsendData = NIL , NIL ,::oWSsendData:Clone() )
	oClone:nUpdateDataMain := ::nUpdateDataMain
	oClone:oWSsetDataZAU010_toDeviceResult :=  IIF(::oWSsetDataZAU010_toDeviceResult = NIL , NIL ,::oWSsetDataZAU010_toDeviceResult:Clone() )
	oClone:cZAU_COD      := ::cZAU_COD
	oClone:cZAU_PLU      := ::cZAU_PLU
	oClone:cZAU_CODCLI   := ::cZAU_CODCLI
	oClone:nZAU_QPUNI    := ::nZAU_QPUNI
	oClone:nZAU_QPCAIX   := ::nZAU_QPCAIX
	oClone:nZAU_LAYETQ   := ::nZAU_LAYETQ
	oClone:nZAU_TIPSER   := ::nZAU_TIPSER
	oClone:cZAU_IMCBAR   := ::cZAU_IMCBAR
	oClone:cZAU_TARA     := ::cZAU_TARA
	oClone:nMemoryText   := ::nMemoryText
	oClone:oWSsetDataZAU010_Sample_toDeviceResult :=  IIF(::oWSsetDataZAU010_Sample_toDeviceResult = NIL , NIL ,::oWSsetDataZAU010_Sample_toDeviceResult:Clone() )
	oClone:oWSsetDataZAU010_LOTEStatusResult :=  IIF(::oWSsetDataZAU010_LOTEStatusResult = NIL , NIL ,::oWSsetDataZAU010_LOTEStatusResult:Clone() )
	oClone:oWSdelDataZAU010Result :=  IIF(::oWSdelDataZAU010Result = NIL , NIL ,::oWSdelDataZAU010Result:Clone() )
	oClone:lsetDevice_SleepResult := ::lsetDevice_SleepResult
	oClone:clevel        := ::clevel
	oClone:lsetDevice_ActivateLevelResult := ::lsetDevice_ActivateLevelResult
Return oClone

// WSDL Method dbConnectionTest of Service WSbizFSWebService

WSMETHOD dbConnectionTest WSSEND NULLPARAM WSRECEIVE oWSdbConnectionTestResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<dbConnectionTest xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += "</dbConnectionTest>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/dbConnectionTest",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::oWSdbConnectionTestResult:SoapRecv( WSAdvValue( oXmlRet,"_DBCONNECTIONTESTRESPONSE:_DBCONNECTIONTESTRESULT","ArrayOfString",NIL,NIL,NIL,NIL,NIL,NIL) )

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method Version of Service WSbizFSWebService

WSMETHOD Version WSSEND NULLPARAM WSRECEIVE oWSVersionResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<Version xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += "</Version>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/Version",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::oWSVersionResult:SoapRecv( WSAdvValue( oXmlRet,"_VERSIONRESPONSE:_VERSIONRESULT","ArrayOfString",NIL,NIL,NIL,NIL,NIL,NIL) )

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method sendLabelID_toDevice of Service WSbizFSWebService

WSMETHOD sendLabelID_toDevice WSSEND ndeviceID,nvalue WSRECEIVE lsendLabelID_toDeviceResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<sendLabelID_toDevice xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("deviceID", ::ndeviceID, ndeviceID , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("value", ::nvalue, nvalue , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += "</sendLabelID_toDevice>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/sendLabelID_toDevice",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::lsendLabelID_toDeviceResult :=  WSAdvValue( oXmlRet,"_SENDLABELID_TODEVICERESPONSE:_SENDLABELID_TODEVICERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method setTotal_toDevice of Service WSbizFSWebService

WSMETHOD setTotal_toDevice WSSEND ndeviceID,ntotalID,nvalue WSRECEIVE lsetTotal_toDeviceResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<setTotal_toDevice xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("deviceID", ::ndeviceID, ndeviceID , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("totalID", ::ntotalID, ntotalID , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("value", ::nvalue, nvalue , "double", .T. , .F., 0 , NIL, .F.) 
		cSoap += "</setTotal_toDevice>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/setTotal_toDevice",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::lsetTotal_toDeviceResult :=  WSAdvValue( oXmlRet,"_SETTOTAL_TODEVICERESPONSE:_SETTOTAL_TODEVICERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method setPLUCustomer_toDevice of Service WSbizFSWebService

WSMETHOD setPLUCustomer_toDevice WSSEND ndeviceID,nPlu,nCustomerID WSRECEIVE lsetPLUCustomer_toDeviceResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<setPLUCustomer_toDevice xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("deviceID", ::ndeviceID, ndeviceID , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("Plu", ::nPlu, nPlu , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("CustomerID", ::nCustomerID, nCustomerID , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += "</setPLUCustomer_toDevice>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/setPLUCustomer_toDevice",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::lsetPLUCustomer_toDeviceResult :=  WSAdvValue( oXmlRet,"_SETPLUCUSTOMER_TODEVICERESPONSE:_SETPLUCUSTOMER_TODEVICERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method DeletePLUCustomer_toDevice of Service WSbizFSWebService

WSMETHOD DeletePLUCustomer_toDevice WSSEND ndeviceID,nPlu,nCustomerID WSRECEIVE lDeletePLUCustomer_toDeviceResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<DeletePLUCustomer_toDevice xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("deviceID", ::ndeviceID, ndeviceID , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("Plu", ::nPlu, nPlu , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("CustomerID", ::nCustomerID, nCustomerID , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += "</DeletePLUCustomer_toDevice>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/DeletePLUCustomer_toDevice",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::lDeletePLUCustomer_toDeviceResult :=  WSAdvValue( oXmlRet,"_DELETEPLUCUSTOMER_TODEVICERESPONSE:_DELETEPLUCUSTOMER_TODEVICERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method getDataZAU010_QTYProdActive of Service WSbizFSWebService

WSMETHOD getDataZAU010_QTYProdActive WSSEND nZAU_FILIAL,nwithSchema WSRECEIVE oWSgetDataZAU010_QTYProdActiveResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<getDataZAU010_QTYProdActive xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("ZAU_FILIAL", ::nZAU_FILIAL, nZAU_FILIAL , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("withSchema", ::nwithSchema, nwithSchema , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += "</getDataZAU010_QTYProdActive>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/getDataZAU010_QTYProdActive",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::oWSgetDataZAU010_QTYProdActiveResult :=  WSAdvValue( oXmlRet,"_GETDATAZAU010_QTYPRODACTIVERESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method getDataZAU010_LOTEStatus of Service WSbizFSWebService

WSMETHOD getDataZAU010_LOTEStatus WSSEND nZAU_FILIAL,cZAU_STATUS,nwithSchema WSRECEIVE oWSgetDataZAU010_LOTEStatusResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<getDataZAU010_LOTEStatus xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("ZAU_FILIAL", ::nZAU_FILIAL, nZAU_FILIAL , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_STATUS", ::cZAU_STATUS, cZAU_STATUS , "string", .F. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("withSchema", ::nwithSchema, nwithSchema , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += "</getDataZAU010_LOTEStatus>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/getDataZAU010_LOTEStatus",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::oWSgetDataZAU010_LOTEStatusResult :=  WSAdvValue( oXmlRet,"_GETDATAZAU010_LOTESTATUSRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method getDataZAU010 of Service WSbizFSWebService

WSMETHOD getDataZAU010 WSSEND nZAU_FILIAL,nZAU_LINHA,nDIAS,cZAU_NUM,nZAU_FLWPL,nwithSchema WSRECEIVE oWSgetDataZAU010Result WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<getDataZAU010 xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("ZAU_FILIAL", ::nZAU_FILIAL, nZAU_FILIAL , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_LINHA", ::nZAU_LINHA, nZAU_LINHA , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("DIAS", ::nDIAS, nDIAS , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_NUM", ::cZAU_NUM, cZAU_NUM , "string", .F. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_FLWPL", ::nZAU_FLWPL, nZAU_FLWPL , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("withSchema", ::nwithSchema, nwithSchema , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += "</getDataZAU010>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/getDataZAU010",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::oWSgetDataZAU010Result :=  WSAdvValue( oXmlRet,"_GETDATAZAU010RESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method setDataZAU010_toDevice of Service WSbizFSWebService

WSMETHOD setDataZAU010_toDevice WSSEND oWSsendData,nUpdateDataMain WSRECEIVE oWSsetDataZAU010_toDeviceResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<setDataZAU010_toDevice xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("sendData", ::oWSsendData, oWSsendData , "ZAU010Data", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("UpdateDataMain", ::nUpdateDataMain, nUpdateDataMain , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += "</setDataZAU010_toDevice>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/setDataZAU010_toDevice",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::oWSsetDataZAU010_toDeviceResult:SoapRecv( WSAdvValue( oXmlRet,"_SETDATAZAU010_TODEVICERESPONSE:_SETDATAZAU010_TODEVICERESULT","Response",NIL,NIL,NIL,NIL,NIL,NIL) )

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method setDataZAU010_Sample_toDevice of Service WSbizFSWebService

WSMETHOD setDataZAU010_Sample_toDevice WSSEND nDeviceID,cZAU_NUM,cZAU_COD,cZAU_PLU,cZAU_CODCLI,nZAU_QPUNI,nZAU_QPCAIX,nZAU_LAYETQ,nZAU_TIPSER,cZAU_IMCBAR,cZAU_TARA,nMemoryText,nUpdateDataMain WSRECEIVE oWSsetDataZAU010_Sample_toDeviceResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<setDataZAU010_Sample_toDevice xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("DeviceID", ::nDeviceID, nDeviceID , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_NUM", ::cZAU_NUM, cZAU_NUM , "string", .F. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_COD", ::cZAU_COD, cZAU_COD , "string", .F. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_PLU", ::cZAU_PLU, cZAU_PLU , "string", .F. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_CODCLI", ::cZAU_CODCLI, cZAU_CODCLI , "string", .F. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_QPUNI", ::nZAU_QPUNI, nZAU_QPUNI , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_QPCAIX", ::nZAU_QPCAIX, nZAU_QPCAIX , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_LAYETQ", ::nZAU_LAYETQ, nZAU_LAYETQ , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_TIPSER", ::nZAU_TIPSER, nZAU_TIPSER , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_IMCBAR", ::cZAU_IMCBAR, cZAU_IMCBAR , "string", .F. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_TARA", ::cZAU_TARA, cZAU_TARA , "string", .F. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("MemoryText", ::nMemoryText, nMemoryText , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("UpdateDataMain", ::nUpdateDataMain, nUpdateDataMain , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += "</setDataZAU010_Sample_toDevice>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/setDataZAU010_Sample_toDevice",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::oWSsetDataZAU010_Sample_toDeviceResult:SoapRecv( WSAdvValue( oXmlRet,"_SETDATAZAU010_SAMPLE_TODEVICERESPONSE:_SETDATAZAU010_SAMPLE_TODEVICERESULT","Response",NIL,NIL,NIL,NIL,NIL,NIL) )

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method setDataZAU010_LOTEStatus of Service WSbizFSWebService

WSMETHOD setDataZAU010_LOTEStatus WSSEND nZAU_FILIAL,cZAU_NUM,cZAU_STATUS,nDeviceID WSRECEIVE oWSsetDataZAU010_LOTEStatusResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<setDataZAU010_LOTEStatus xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("ZAU_FILIAL", ::nZAU_FILIAL, nZAU_FILIAL , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_NUM", ::cZAU_NUM, cZAU_NUM , "string", .F. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_STATUS", ::cZAU_STATUS, cZAU_STATUS , "string", .F. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("DeviceID", ::nDeviceID, nDeviceID , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += "</setDataZAU010_LOTEStatus>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/setDataZAU010_LOTEStatus",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::oWSsetDataZAU010_LOTEStatusResult:SoapRecv( WSAdvValue( oXmlRet,"_SETDATAZAU010_LOTESTATUSRESPONSE:_SETDATAZAU010_LOTESTATUSRESULT","Response",NIL,NIL,NIL,NIL,NIL,NIL) )

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method delDataZAU010 of Service WSbizFSWebService

WSMETHOD delDataZAU010 WSSEND nZAU_FILIAL,cZAU_NUM WSRECEIVE oWSdelDataZAU010Result WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<delDataZAU010 xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("ZAU_FILIAL", ::nZAU_FILIAL, nZAU_FILIAL , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("ZAU_NUM", ::cZAU_NUM, cZAU_NUM , "string", .F. , .F., 0 , NIL, .F.) 
		cSoap += "</delDataZAU010>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/delDataZAU010",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::oWSdelDataZAU010Result:SoapRecv( WSAdvValue( oXmlRet,"_DELDATAZAU010RESPONSE:_DELDATAZAU010RESULT","Response",NIL,NIL,NIL,NIL,NIL,NIL) )

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method setDevice_Sleep of Service WSbizFSWebService

WSMETHOD setDevice_Sleep WSSEND ndeviceID WSRECEIVE lsetDevice_SleepResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<setDevice_Sleep xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("deviceID", ::ndeviceID, ndeviceID , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += "</setDevice_Sleep>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/setDevice_Sleep",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::lsetDevice_SleepResult :=  WSAdvValue( oXmlRet,"_SETDEVICE_SLEEPRESPONSE:_SETDEVICE_SLEEPRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method setDevice_ActivateLevel of Service WSbizFSWebService

WSMETHOD setDevice_ActivateLevel WSSEND ndeviceID,clevel WSRECEIVE lsetDevice_ActivateLevelResult WSCLIENT WSbizFSWebService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<setDevice_ActivateLevel xmlns="http://ws.bizerba.br/bizFSWS/">'
		cSoap += WSSoapValue("deviceID", ::ndeviceID, ndeviceID , "int", .T. , .F., 0 , NIL, .F.) 
		cSoap += WSSoapValue("level", ::clevel, clevel , "string", .F. , .F., 0 , NIL, .F.) 
		cSoap += "</setDevice_ActivateLevel>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://ws.bizerba.br/bizFSWS/setDevice_ActivateLevel",; 
		"DOCUMENT","http://ws.bizerba.br/bizFSWS/",,,; 
		"http://10.0.20.13/bizFSWS/bizFSWS.asmx")

		::Init()
		::lsetDevice_ActivateLevelResult :=  WSAdvValue( oXmlRet,"_SETDEVICE_ACTIVATELEVELRESPONSE:_SETDEVICE_ACTIVATELEVELRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfString

WSSTRUCT bizFSWebService_ArrayOfString
	WSDATA   cstring                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT bizFSWebService_ArrayOfString
	::Init()
Return Self

WSMETHOD INIT WSCLIENT bizFSWebService_ArrayOfString
	::cstring              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT bizFSWebService_ArrayOfString
	Local oClone := bizFSWebService_ArrayOfString():NEW()
	oClone:cstring              := IIf(::cstring <> NIL , aClone(::cstring) , NIL )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT bizFSWebService_ArrayOfString
	Local oNodes1 :=  WSAdvValue( oResponse,"_STRING","string",{},NIL,.T.,"S",NIL,"a") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::cstring ,  x:TEXT  ) } )
Return

// WSDL Data Structure ZAU010Data

WSSTRUCT bizFSWebService_ZAU010Data
	WSDATA   nDeviceID                 AS int
	WSDATA   cZAU_FILIAL               AS string OPTIONAL
	WSDATA   cZAU_NUM                  AS string OPTIONAL
	WSDATA   cZAU_DTPROD               AS string OPTIONAL
	WSDATA   cZAU_COD                  AS string OPTIONAL
	WSDATA   cZAU_PLU                  AS string OPTIONAL
	WSDATA   cZAU_LINHA                AS string OPTIONAL
	WSDATA   cZAU_STATUS               AS string OPTIONAL
	WSDATA   cZAU_PRCCLI               AS string OPTIONAL
	WSDATA   cZAU_QPPESO               AS string OPTIONAL
	WSDATA   cZAU_QRPESO               AS string OPTIONAL
	WSDATA   cZAU_QPUNI                AS string OPTIONAL
	WSDATA   cZAU_QRUNI                AS string OPTIONAL
	WSDATA   cZAU_QPCAIX               AS string OPTIONAL
	WSDATA   cZAU_QRCAIX               AS string OPTIONAL
	WSDATA   cZAU_TARA                 AS string OPTIONAL
	WSDATA   cZAU_IMCBAR               AS string OPTIONAL
	WSDATA   cZAU_PESBAN               AS string OPTIONAL
	WSDATA   cZAU_CODCLI               AS string OPTIONAL
	WSDATA   cZAU_TIPSER               AS string OPTIONAL
	WSDATA   cZAU_IMLOTE               AS string OPTIONAL
	WSDATA   cZAU_IMPROD               AS string OPTIONAL
	WSDATA   cZAU_IMTARA               AS string OPTIONAL
	WSDATA   cZAU_IMVAL                AS string OPTIONAL
	WSDATA   cZAU_IMPRC                AS string OPTIONAL
	WSDATA   cZAU_IMPCOM               AS string OPTIONAL
	WSDATA   cZAU_LAYETQ               AS string OPTIONAL
	WSDATA   cZAU_FLERP                AS string OPTIONAL
	WSDATA   cZAU_FLWPL                AS string OPTIONAL
	/*INICIO - Adicionado por Lucas Bolzan*/
	WSDATA   cZAU_ADD0                 AS string OPTIONAL
	WSDATA   cZAU_ADD1                 AS string OPTIONAL
	WSDATA   cZAU_ADD2                 AS string OPTIONAL
	WSDATA   cZAU_ADD3                 AS string OPTIONAL
	WSDATA   cZAU_ADD4                 AS string OPTIONAL
	WSDATA   cZAU_TX4                  AS string OPTIONAL
	WSDATA   cZAU_TX5                  AS string OPTIONAL
	WSDATA   cZAU_TX6                  AS string OPTIONAL
	WSDATA   cZAU_TX7                  AS string OPTIONAL
	WSDATA   cZAU_TX8                  AS string OPTIONAL
	WSDATA   cZAU_TX9                  AS string OPTIONAL
	/*		
	WSDATA   cZAU_TX10                 AS string OPTIONAL
	WSDATA   cZAU_TX11                 AS string OPTIONAL
	WSDATA   cZAU_TX12                 AS string OPTIONAL
	WSDATA   cZAU_TX13                 AS string OPTIONAL
	WSDATA   cZAU_TX14                 AS string OPTIONAL
	WSDATA   cZAU_TX15                 AS string OPTIONAL
	WSDATA   cZAU_TX16                 AS string OPTIONAL
	WSDATA   cZAU_TX17                 AS string OPTIONAL
	WSDATA   cZAU_TX18                 AS string OPTIONAL
	WSDATA   cZAU_TX19                 AS string OPTIONAL
	WSDATA   cZAU_TX20                 AS string OPTIONAL
	*/
	/*FIM - Adicionado por Lucas Bolzan*/
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT bizFSWebService_ZAU010Data
	::Init()
Return Self

WSMETHOD INIT WSCLIENT bizFSWebService_ZAU010Data
Return

WSMETHOD CLONE WSCLIENT bizFSWebService_ZAU010Data
	Local oClone := bizFSWebService_ZAU010Data():NEW()
	oClone:nDeviceID            := ::nDeviceID
	oClone:cZAU_FILIAL          := ::cZAU_FILIAL
	oClone:cZAU_NUM             := ::cZAU_NUM
	oClone:cZAU_DTPROD          := ::cZAU_DTPROD
	oClone:cZAU_COD             := ::cZAU_COD
	oClone:cZAU_PLU             := ::cZAU_PLU
	oClone:cZAU_LINHA           := ::cZAU_LINHA
	oClone:cZAU_STATUS          := ::cZAU_STATUS
	oClone:cZAU_PRCCLI          := ::cZAU_PRCCLI
	oClone:cZAU_QPPESO          := ::cZAU_QPPESO
	oClone:cZAU_QRPESO          := ::cZAU_QRPESO
	oClone:cZAU_QPUNI           := ::cZAU_QPUNI
	oClone:cZAU_QRUNI           := ::cZAU_QRUNI
	oClone:cZAU_QPCAIX          := ::cZAU_QPCAIX
	oClone:cZAU_QRCAIX          := ::cZAU_QRCAIX
	oClone:cZAU_TARA            := ::cZAU_TARA
	oClone:cZAU_IMCBAR          := ::cZAU_IMCBAR
	oClone:cZAU_PESBAN          := ::cZAU_PESBAN
	oClone:cZAU_CODCLI          := ::cZAU_CODCLI
	oClone:cZAU_TIPSER          := ::cZAU_TIPSER
	oClone:cZAU_IMLOTE          := ::cZAU_IMLOTE
	oClone:cZAU_IMPROD          := ::cZAU_IMPROD
	oClone:cZAU_IMTARA          := ::cZAU_IMTARA
	oClone:cZAU_IMVAL           := ::cZAU_IMVAL
	oClone:cZAU_IMPRC           := ::cZAU_IMPRC
	oClone:cZAU_IMPCOM          := ::cZAU_IMPCOM
	oClone:cZAU_LAYETQ          := ::cZAU_LAYETQ
	oClone:cZAU_FLERP           := ::cZAU_FLERP
	oClone:cZAU_FLWPL           := ::cZAU_FLWPL
	/*INICIO - Adicionado por Lucas Bolzan*/
	oClone:cZAU_ADD0           := ::cZAU_ADD0
	oClone:cZAU_ADD1           := ::cZAU_ADD1
	oClone:cZAU_ADD2           := ::cZAU_ADD2
	oClone:cZAU_ADD3           := ::cZAU_ADD3
	oClone:cZAU_ADD4           := ::cZAU_ADD4
	oClone:cZAU_TX4            := ::cZAU_TX4	
	oClone:cZAU_TX5            := ::cZAU_TX5
	oClone:cZAU_TX6            := ::cZAU_TX6
	oClone:cZAU_TX7            := ::cZAU_TX7
	oClone:cZAU_TX8            := ::cZAU_TX8
	oClone:cZAU_TX9            := ::cZAU_TX9
	/*	
	oClone:cZAU_TX10           := ::cZAU_TARAT
	oClone:cZAU_TX11           := ::cZAU_TARAT
	oClone:cZAU_TX12           := ::cZAU_TARAT
	oClone:cZAU_TX13           := ::cZAU_TARAT
	oClone:cZAU_TX14           := ::cZAU_TARAT
	oClone:cZAU_TX15           := ::cZAU_TARAT
	oClone:cZAU_TX16           := ::cZAU_TARAT
	oClone:cZAU_TX17           := ::cZAU_TARAT
	oClone:cZAU_TX18           := ::cZAU_TARAT
	oClone:cZAU_TX19           := ::cZAU_TARAT
	oClone:cZAU_TX20           := ::cZAU_TARAT
	*/
	/*FIM - Adicionado por Lucas Bolzan*/
Return oClone

WSMETHOD SOAPSEND WSCLIENT bizFSWebService_ZAU010Data
	Local cSoap := ""
	cSoap += WSSoapValue("DeviceID", ::nDeviceID, ::nDeviceID , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_FILIAL", ::cZAU_FILIAL, ::cZAU_FILIAL , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_NUM", ::cZAU_NUM, ::cZAU_NUM , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_DTPROD", ::cZAU_DTPROD, ::cZAU_DTPROD , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_COD", ::cZAU_COD, ::cZAU_COD , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_PLU", ::cZAU_PLU, ::cZAU_PLU , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_LINHA", ::cZAU_LINHA, ::cZAU_LINHA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_STATUS", ::cZAU_STATUS, ::cZAU_STATUS , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_PRCCLI", ::cZAU_PRCCLI, ::cZAU_PRCCLI , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_QPPESO", ::cZAU_QPPESO, ::cZAU_QPPESO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_QRPESO", ::cZAU_QRPESO, ::cZAU_QRPESO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_QPUNI", ::cZAU_QPUNI, ::cZAU_QPUNI , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_QRUNI", ::cZAU_QRUNI, ::cZAU_QRUNI , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_QPCAIX", ::cZAU_QPCAIX, ::cZAU_QPCAIX , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_QRCAIX", ::cZAU_QRCAIX, ::cZAU_QRCAIX , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_TARA", ::cZAU_TARA, ::cZAU_TARA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_IMCBAR", ::cZAU_IMCBAR, ::cZAU_IMCBAR , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_PESBAN", ::cZAU_PESBAN, ::cZAU_PESBAN , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_CODCLI", ::cZAU_CODCLI, ::cZAU_CODCLI , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_TIPSER", ::cZAU_TIPSER, ::cZAU_TIPSER , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_IMLOTE", ::cZAU_IMLOTE, ::cZAU_IMLOTE , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_IMPROD", ::cZAU_IMPROD, ::cZAU_IMPROD , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_IMTARA", ::cZAU_IMTARA, ::cZAU_IMTARA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_IMVAL", ::cZAU_IMVAL, ::cZAU_IMVAL , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_IMPRC", ::cZAU_IMPRC, ::cZAU_IMPRC , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_IMPCOM", ::cZAU_IMPCOM, ::cZAU_IMPCOM , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_LAYETQ", ::cZAU_LAYETQ, ::cZAU_LAYETQ , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_FLERP", ::cZAU_FLERP, ::cZAU_FLERP , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_FLWPL", ::cZAU_FLWPL, ::cZAU_FLWPL , "string", .F. , .F., 0 , NIL, .F.) 
	/*INICIO - Adicionado por Lucas Bolzan*/
	cSoap += WSSoapValue("ZAU_ADD0", ::cZAU_ADD0, ::cZAU_ADD0 , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_ADD1", ::cZAU_ADD1, ::cZAU_ADD1 , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_ADD2", ::cZAU_ADD2, ::cZAU_ADD2 , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_ADD3", ::cZAU_ADD3, ::cZAU_ADD3 , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_ADD4", ::cZAU_ADD4, ::cZAU_ADD4 , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ZAU_TX4",  ::cZAU_TX4,  ::cZAU_TX4  , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("ZAU_TX5",  ::cZAU_TX5,  ::cZAU_TX5  , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("ZAU_TX6",  ::cZAU_TX6,  ::cZAU_TX6  , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("ZAU_TX7",  ::cZAU_TX7,  ::cZAU_TX7  , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("ZAU_TX8",  ::cZAU_TX8,  ::cZAU_TX8  , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("ZAU_TX9",  ::cZAU_TX9,  ::cZAU_TX9  , "string", .F. , .F., 0 , NIL, .F.)
	/*FIM - Adicionado por Lucas Bolzan*/
Return cSoap

// WSDL Data Structure Response

WSSTRUCT bizFSWebService_Response
	WSDATA   cWSName                   AS string OPTIONAL
	WSDATA   cSTART                    AS string OPTIONAL
	WSDATA   oWSRESULT                 AS bizFSWebService_ArrayOfResult OPTIONAL
	WSDATA   cEND                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT bizFSWebService_Response
	::Init()
Return Self

WSMETHOD INIT WSCLIENT bizFSWebService_Response
Return

WSMETHOD CLONE WSCLIENT bizFSWebService_Response
	Local oClone := bizFSWebService_Response():NEW()
	oClone:cWSName              := ::cWSName
	oClone:cSTART               := ::cSTART
	oClone:oWSRESULT            := IIF(::oWSRESULT = NIL , NIL , ::oWSRESULT:Clone() )
	oClone:cEND                 := ::cEND
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT bizFSWebService_Response
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cWSName            :=  WSAdvValue( oResponse,"_WSNAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTART             :=  WSAdvValue( oResponse,"_START","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode3 :=  WSAdvValue( oResponse,"_RESULT","ArrayOfResult",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSRESULT := bizFSWebService_ArrayOfResult():New()
		::oWSRESULT:SoapRecv(oNode3)
	EndIf
	::cEND               :=  WSAdvValue( oResponse,"_END","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfResult

WSSTRUCT bizFSWebService_ArrayOfResult
	WSDATA   oWSResult                 AS bizFSWebService_Result OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT bizFSWebService_ArrayOfResult
	::Init()
Return Self

WSMETHOD INIT WSCLIENT bizFSWebService_ArrayOfResult
	::oWSResult            := {} // Array Of  bizFSWebService_RESULT():New()
Return

WSMETHOD CLONE WSCLIENT bizFSWebService_ArrayOfResult
	Local oClone := bizFSWebService_ArrayOfResult():NEW()
	oClone:oWSResult := NIL
	If ::oWSResult <> NIL 
		oClone:oWSResult := {}
		aEval( ::oWSResult , { |x| aadd( oClone:oWSResult , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT bizFSWebService_ArrayOfResult
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RESULT","Result",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSResult , bizFSWebService_Result():New() )
			::oWSResult[len(::oWSResult)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Result

WSSTRUCT bizFSWebService_Result
	WSDATA   cPROCESS                  AS string OPTIONAL
	WSDATA   cKEY_ID1                  AS string OPTIONAL
	WSDATA   cKEY_ID2                  AS string OPTIONAL
	WSDATA   cKEY_ID3                  AS string OPTIONAL
	WSDATA   lRESULT                   AS boolean
	WSDATA   nITEMS                    AS int
	WSDATA   cMSG                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT bizFSWebService_Result
	::Init()
Return Self

WSMETHOD INIT WSCLIENT bizFSWebService_Result
Return

WSMETHOD CLONE WSCLIENT bizFSWebService_Result
	Local oClone := bizFSWebService_Result():NEW()
	oClone:cPROCESS             := ::cPROCESS
	oClone:cKEY_ID1             := ::cKEY_ID1
	oClone:cKEY_ID2             := ::cKEY_ID2
	oClone:cKEY_ID3             := ::cKEY_ID3
	oClone:lRESULT              := ::lRESULT
	oClone:nITEMS               := ::nITEMS
	oClone:cMSG                 := ::cMSG
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT bizFSWebService_Result
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cPROCESS           :=  WSAdvValue( oResponse,"_PROCESS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cKEY_ID1           :=  WSAdvValue( oResponse,"_KEY_ID1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cKEY_ID2           :=  WSAdvValue( oResponse,"_KEY_ID2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cKEY_ID3           :=  WSAdvValue( oResponse,"_KEY_ID3","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lRESULT            :=  WSAdvValue( oResponse,"_RESULT","boolean",NIL,"Property lRESULT as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nITEMS             :=  WSAdvValue( oResponse,"_ITEMS","int",NIL,"Property nITEMS as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cMSG               :=  WSAdvValue( oResponse,"_MSG","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


