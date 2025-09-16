#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณconsLibRom  บAutor  ณMauricio Roehrs บ Data ณ  09/05/19     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  fun็ใo para consumir o webservice wcLiberaRomaneio		  บฑฑ
ฑฑบ          ณ  ้ chamada no fonte sti_rg01                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function consLibRom(cNumRom,cStatus,cDTADIA,dDATAEM,nPrazo,cCodBanco,cAgencia,cConta,cNomeDest,cCGCDest, aAnimais,_flag,cCarcaca)
	
	Local i

	if _flag = 1 //quando altera romaneio

		BEGIN SEQUENCE

			_oWS := WSRomaneioSoapService():New()

			cAno:= substr(cDTADIA,1,4)
			cMes:= substr(cDTADIA,5,2)
			cDia:= substr(cDTADIA,7,2)

			if cStatus = 'A'
				_nStatus := '3'
			else
				_nStatus := '1'
			endif
			
			_cNPR := fBuscaCpo('ZAQ',1,FWxFilial('ZAQ') + cNumRom,'ZAQ_NPR')
			
			_oWS:oWSupdateDatadataArray:cTCNUMERO 				:= cNumRom
			_oWS:oWSupdateDatadataArray:cTCSTATUS 				:= _nStatus
			_oWS:oWSupdateDatadataArray:cTCDATAADIANTAMENTO 	:= cAno + '-' + cMes + '-' + cDia
			_oWS:oWSupdateDatadataArray:cTCDATAEMBARQUE 		:= dtos(dDATAEM)
			_oWS:oWSupdateDatadataArray:cTCPRAZO 				:= iif(_cNPR = '1', '99',alltrim(str(nPrazo)))
			_oWS:oWSupdateDatadataArray:cTCCARCACA 				:= cCarcaca
			_oWS:oWSupdateDatadataArray:cTCCODBANCO 			:= cCodBanco
			_oWS:oWSupdateDatadataArray:cTCAGENCIA 				:= cAgencia
			_oWS:oWSupdateDatadataArray:cTCCONTA 				:= cConta
			_oWS:oWSupdateDatadataArray:cTCNOMEDESTINATARIO 	:= cNomeDest
			_oWS:oWSupdateDatadataArray:cTCCPFCNPJDESTINATARIO  := cCGCDest

			_oWS:oWSupdateDatadataArray:oWSTCANIMAIS := RomaneioSoapService_ArrayOfAnimalDataType():new()

			for i:= 1 to len(aAnimais)

				oAnimais := RomaneioSoapService_AnimalDataType():New()

				if empty(aAnimais[i,6])
					_cProg := 'N'
				else
					_cProg := aAnimais[i,6]
				endif

				oAnimais:cTCCATEGORIAANIMAL 	:= aAnimais[i,1]
				oAnimais:cTCQUANTIDADE			:= transform(aAnimais[i,2],'@E 999')
				oAnimais:cTCPRECOBASE			:= strtran(transform(aAnimais[i,3],'@E 99.99'),',','.')
				oAnimais:cTCPRECOBONUS			:= strtran(transform(aAnimais[i,4],'@E 99.99'),',','.')
				oAnimais:cTCPESOMEDIO			:= transform(aAnimais[i,5],'@E 999')
				oAnimais:cTCPROGRAMA			:= _cProg //aAnimais[i,6]
				oAnimais:cTC_CLQUANTIDADE       := transform(aAnimais[i,7],'@E 999') 					//cruzaleite quantidade
				oAnimais:cTC_CLPRECOBASE        := strtran(transform(aAnimais[i,8],'@E 99.99'),',','.') //cruzaleite pre็o base
				oAnimais:cTC_TNQUANTIDADE       := transform(aAnimais[i,9],'@E 999')					//touruno quantidade
				oAnimais:cTC_TNPRECOBASE        := strtran(transform(aAnimais[i,10],'@E 99.99'),',','.')//touruno pre็o base

				aadd(_oWS:oWSupdateDatadataArray:oWSTCANIMAIS:oWSAnimalDataType, oAnimais)

			next

			if _oWS:updateData()

				oXML := _oWS:creturn
				//alert(oXML)
			else
				//getwscerror(3)
			endif

			//alert(getwscerror(1))
			//alert(getwscerror(2))
			//alert(getwscerror(3))

			//if oXML = '{"sucesso":true}'
			//	ApMsgInfo('Registro alterado com sucesso no aplicativo')
			//else

			//endif

		END SEQUENCE

	elseif _flag = 2//quando exclui romaneio

		BEGIN SEQUENCE
			_oWS := WSRomaneioSoapService():New()

			_oWS:oWSdeleteDatadataArray:cTCNUMERO := cNumRom

			if _oWS:deleteData()

				oXML := _oWS:creturn
				//alert(oXML)
			else
				//getwscerror(3)
			endif

			//alert(getwscerror(1))
			//alert(getwscerror(2))
			//alert(getwscerror(3))

			//if oXML = '{"sucesso":true}'
			//	ApMsgInfo('Registro alterado com sucesso no aplicativo')
			//else

			//endif
		END SEQUENCE
	endif

return
