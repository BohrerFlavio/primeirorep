#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://portaldogado.vtsis.io/api/v1/ws/frigorifico/romaneiosEditSoap/?wsdl
Gerado em        06/10/19 14:13:16
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _IQIMJDO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRomaneioSoapService
------------------------------------------------------------------------------- */
WSCLIENT WSRomaneioSoapService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD updateData
	WSMETHOD deleteData

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSupdateDatadataArray    AS RomaneioSoapService_RomaneioDataType
	WSDATA   creturn                   AS string
	WSDATA   oWSdeleteDatadataArray    AS RomaneioSoapService_RomaneioDeleteDataType

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRomaneioSoapService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20181218 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRomaneioSoapService
	::oWSupdateDatadataArray := RomaneioSoapService_ROMANEIODATATYPE():New()
	::oWSdeleteDatadataArray := RomaneioSoapService_ROMANEIODELETEDATATYPE():New()
Return

WSMETHOD RESET WSCLIENT WSRomaneioSoapService
	::oWSupdateDatadataArray := NIL 
	::creturn            := NIL 
	::oWSdeleteDatadataArray := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRomaneioSoapService
Local oClone := WSRomaneioSoapService():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:oWSupdateDatadataArray :=  IIF(::oWSupdateDatadataArray = NIL , NIL ,::oWSupdateDatadataArray:Clone() )
	oClone:creturn       := ::creturn
	oClone:oWSdeleteDatadataArray :=  IIF(::oWSdeleteDatadataArray = NIL , NIL ,::oWSdeleteDatadataArray:Clone() )
Return oClone

// WSDL Method updateData of Service WSRomaneioSoapService

WSMETHOD updateData WSSEND oWSupdateDatadataArray WSRECEIVE creturn WSCLIENT WSRomaneioSoapService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateData xmlns:q1="https://portaldogado.vtsis.io/api/v1/ws/frigorifico/romaneiosEditSoap">'
cSoap += WSSoapValue("dataArray", ::oWSupdateDatadataArray, oWSupdateDatadataArray , "RomaneioDataType", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:updateData>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://portaldogado.vtsis.io/api/v1/ws/frigorifico/romaneiosEditSoap#updateData",; 
	"RPCX","https://portaldogado.vtsis.io/api/v1/ws/frigorifico/romaneiosEditSoap",,,; 
	"https://portaldogado.vtsis.io/api/v1/ws/frigorifico/romaneiosEditSoap")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method deleteData of Service WSRomaneioSoapService

WSMETHOD deleteData WSSEND oWSdeleteDatadataArray WSRECEIVE creturn WSCLIENT WSRomaneioSoapService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:deleteData xmlns:q1="https://portaldogado.vtsis.io/api/v1/ws/frigorifico/romaneiosEditSoap">'
cSoap += WSSoapValue("dataArray", ::oWSdeleteDatadataArray, oWSdeleteDatadataArray , "RomaneioDeleteDataType", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:deleteData>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://portaldogado.vtsis.io/api/v1/ws/frigorifico/romaneiosEditSoap#deleteData",; 
	"RPCX","https://portaldogado.vtsis.io/api/v1/ws/frigorifico/romaneiosEditSoap",,,; 
	"https://portaldogado.vtsis.io/api/v1/ws/frigorifico/romaneiosEditSoap")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure RomaneioDataType

WSSTRUCT RomaneioSoapService_RomaneioDataType
	WSDATA   cTCNUMERO                 AS string OPTIONAL
	WSDATA   cTCSTATUS                 AS string OPTIONAL
	WSDATA   cTCDATAADIANTAMENTO       AS string OPTIONAL
	WSDATA   cTCDATAEMBARQUE           AS string OPTIONAL
	WSDATA   cTCPRAZO                  AS string OPTIONAL
	WSDATA   cTCCARCACA                AS string OPTIONAL
	WSDATA   cTCCODBANCO               AS string OPTIONAL
	WSDATA   cTCAGENCIA                AS string OPTIONAL
	WSDATA   cTCCONTA                  AS string OPTIONAL
	WSDATA   cTCNOMEDESTINATARIO       AS string OPTIONAL
	WSDATA   cTCCPFCNPJDESTINATARIO    AS string OPTIONAL
	WSDATA   oWSTCANIMAIS              AS RomaneioSoapService_ArrayOfAnimalDataType OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RomaneioSoapService_RomaneioDataType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RomaneioSoapService_RomaneioDataType
Return

WSMETHOD CLONE WSCLIENT RomaneioSoapService_RomaneioDataType
	Local oClone := RomaneioSoapService_RomaneioDataType():NEW()
	oClone:cTCNUMERO            := ::cTCNUMERO
	oClone:cTCSTATUS            := ::cTCSTATUS
	oClone:cTCDATAADIANTAMENTO  := ::cTCDATAADIANTAMENTO
	oClone:cTCDATAEMBARQUE      := ::cTCDATAEMBARQUE
	oClone:cTCPRAZO             := ::cTCPRAZO
	oClone:cTCCARCACA           := ::cTCCARCACA
	oClone:cTCCODBANCO          := ::cTCCODBANCO
	oClone:cTCAGENCIA           := ::cTCAGENCIA
	oClone:cTCCONTA             := ::cTCCONTA
	oClone:cTCNOMEDESTINATARIO  := ::cTCNOMEDESTINATARIO
	oClone:cTCCPFCNPJDESTINATARIO := ::cTCCPFCNPJDESTINATARIO
	oClone:oWSTCANIMAIS         := IIF(::oWSTCANIMAIS = NIL , NIL , ::oWSTCANIMAIS:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT RomaneioSoapService_RomaneioDataType
	Local cSoap := ""
	cSoap += WSSoapValue("TCNUMERO", ::cTCNUMERO, ::cTCNUMERO , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCSTATUS", ::cTCSTATUS, ::cTCSTATUS , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCDATAADIANTAMENTO", ::cTCDATAADIANTAMENTO, ::cTCDATAADIANTAMENTO , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCDATAEMBARQUE", ::cTCDATAEMBARQUE, ::cTCDATAEMBARQUE , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCPRAZO", ::cTCPRAZO, ::cTCPRAZO , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCCARCACA", ::cTCCARCACA, ::cTCCARCACA , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCCODBANCO", ::cTCCODBANCO, ::cTCCODBANCO , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCAGENCIA", ::cTCAGENCIA, ::cTCAGENCIA , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCCONTA", ::cTCCONTA, ::cTCCONTA , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCNOMEDESTINATARIO", ::cTCNOMEDESTINATARIO, ::cTCNOMEDESTINATARIO , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCCPFCNPJDESTINATARIO", ::cTCCPFCNPJDESTINATARIO, ::cTCCPFCNPJDESTINATARIO , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCANIMAIS", ::oWSTCANIMAIS, ::oWSTCANIMAIS , "ArrayOfAnimalDataType", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfAnimalDataType

WSSTRUCT RomaneioSoapService_ArrayOfAnimalDataType
	WSDATA   oWSAnimalDataType         AS RomaneioSoapService_AnimalDataType OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RomaneioSoapService_ArrayOfAnimalDataType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RomaneioSoapService_ArrayOfAnimalDataType
	::oWSAnimalDataType    := {} // Array Of  RomaneioSoapService_ANIMALDATATYPE():New()
Return

WSMETHOD CLONE WSCLIENT RomaneioSoapService_ArrayOfAnimalDataType
	Local oClone := RomaneioSoapService_ArrayOfAnimalDataType():NEW()
	oClone:oWSAnimalDataType := NIL
	If ::oWSAnimalDataType <> NIL 
		oClone:oWSAnimalDataType := {}
		aEval( ::oWSAnimalDataType , { |x| aadd( oClone:oWSAnimalDataType , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT RomaneioSoapService_ArrayOfAnimalDataType
	Local cSoap := ""
	aEval( ::oWSAnimalDataType , {|x| cSoap := cSoap  +  WSSoapValue("AnimalDataType", x , x , "AnimalDataType", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure RomaneioDeleteDataType

WSSTRUCT RomaneioSoapService_RomaneioDeleteDataType
	WSDATA   cTCNUMERO                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RomaneioSoapService_RomaneioDeleteDataType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RomaneioSoapService_RomaneioDeleteDataType
Return

WSMETHOD CLONE WSCLIENT RomaneioSoapService_RomaneioDeleteDataType
	Local oClone := RomaneioSoapService_RomaneioDeleteDataType():NEW()
	oClone:cTCNUMERO            := ::cTCNUMERO
Return oClone

WSMETHOD SOAPSEND WSCLIENT RomaneioSoapService_RomaneioDeleteDataType
	Local cSoap := ""
	cSoap += WSSoapValue("TCNUMERO", ::cTCNUMERO, ::cTCNUMERO , "string", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure AnimalDataType

WSSTRUCT RomaneioSoapService_AnimalDataType
	WSDATA   cTCCATEGORIAANIMAL        AS string OPTIONAL
	WSDATA   cTCQUANTIDADE             AS string OPTIONAL
	WSDATA   cTCPRECOBASE              AS string OPTIONAL
	WSDATA   cTCPRECOBONUS             AS string OPTIONAL
	WSDATA   cTCPESOMEDIO              AS string OPTIONAL
	WSDATA   cTCPROGRAMA               AS string OPTIONAL
	WSDATA   cTC_CLQUANTIDADE          AS string OPTIONAL
	WSDATA   cTC_CLPRECOBASE           AS string OPTIONAL
	WSDATA   cTC_TNQUANTIDADE          AS string OPTIONAL
	WSDATA   cTC_TNPRECOBASE           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RomaneioSoapService_AnimalDataType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RomaneioSoapService_AnimalDataType
Return

WSMETHOD CLONE WSCLIENT RomaneioSoapService_AnimalDataType
	Local oClone := RomaneioSoapService_AnimalDataType():NEW()
	oClone:cTCCATEGORIAANIMAL   := ::cTCCATEGORIAANIMAL
	oClone:cTCQUANTIDADE        := ::cTCQUANTIDADE
	oClone:cTCPRECOBASE         := ::cTCPRECOBASE
	oClone:cTCPRECOBONUS        := ::cTCPRECOBONUS
	oClone:cTCPESOMEDIO         := ::cTCPESOMEDIO
	oClone:cTCPROGRAMA          := ::cTCPROGRAMA
	oClone:cTC_CLQUANTIDADE     := ::cTC_CLQUANTIDADE
	oClone:cTC_CLPRECOBASE      := ::cTC_CLPRECOBASE
	oClone:cTC_TNQUANTIDADE     := ::cTC_TNQUANTIDADE
	oClone:cTC_TNPRECOBASE      := ::cTC_TNPRECOBASE
Return oClone

WSMETHOD SOAPSEND WSCLIENT RomaneioSoapService_AnimalDataType
	Local cSoap := ""
	cSoap += WSSoapValue("TCCATEGORIAANIMAL", ::cTCCATEGORIAANIMAL, ::cTCCATEGORIAANIMAL , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCQUANTIDADE", ::cTCQUANTIDADE, ::cTCQUANTIDADE , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCPRECOBASE", ::cTCPRECOBASE, ::cTCPRECOBASE , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCPRECOBONUS", ::cTCPRECOBONUS, ::cTCPRECOBONUS , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCPESOMEDIO", ::cTCPESOMEDIO, ::cTCPESOMEDIO , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TCPROGRAMA", ::cTCPROGRAMA, ::cTCPROGRAMA , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TC_CLQUANTIDADE", ::cTC_CLQUANTIDADE, ::cTC_CLQUANTIDADE , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TC_CLPRECOBASE", ::cTC_CLPRECOBASE, ::cTC_CLPRECOBASE , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TC_TNQUANTIDADE", ::cTC_TNQUANTIDADE, ::cTC_TNQUANTIDADE , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TC_TNPRECOBASE", ::cTC_TNPRECOBASE, ::cTC_TNPRECOBASE , "string", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap


