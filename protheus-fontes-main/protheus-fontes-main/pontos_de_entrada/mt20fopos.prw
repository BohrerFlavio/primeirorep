#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

User Function CUSTOMERVENDOR()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ""
	Local cIdPonto := ""
	Local cIdModel := ""
	Local lIsGrid := .F.
	Local nLinha := 0
	Local nQtdLinhas := 0
	Local cMsg := ""

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid := (Len(aParam) > 3)

		If cIdPonto == "MODELCOMMITNTTS"
//			ApMsgInfo("Chamada após a gravação total do modelo e fora da transação.")
//			alert(SA2->A2_COD)
//			alert(SA2->A2_LOJA)
//			alert(SA2->A2_MSBLQL)
			if alltrim(SA2->A2_NATUREZ) = '120101'
				BEGIN SEQUENCE

					_oWS := WSUsuarioSoapService():New()
					_oWS:oWSupdateDatadataArray:cTCCODIGO  := SA2->A2_COD
					_oWS:oWSupdateDatadataArray:cTCSTATUS  := SA2->A2_MSBLQL
					_oWS:updateData()

					oXML := _oWS:creturn

					//alert(oXML)
					
//					if oXML = '{"sucesso":true}'
//						ApMsgInfo('Registro alterado com sucesso no aplicativo')
//					else
//					
//					endif

//					alert(getwscerror(1))
//					alert(getwscerror(2))
//					alert(getwscerror(3))

				END SEQUENCE
			endif
		endif

	EndIf

Return xRet

