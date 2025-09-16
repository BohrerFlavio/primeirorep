#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณwcDadosAbate บAutor  ณMauricio Roehrs  บ Data ณ  09/04/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCodigo fonte do JOB para envio dos dados do abate de forma  บฑฑ
ฑฑบ          ณonline para o webservice do app do gado                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROGEPEC									                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function wcDAbt()

	Private oNumam   := ''
	Private oControl := ''
	Private oLote 	 := ''
	Private cCarcaca := ''
	Private oCobGor  := ''
	Private oDent 	 := ''
	Private oIf 	 := ''
	Private oPetotal := 0
	Private _nPesoT  := 0
	Private _lRoda   := .t.
	Private _cCgc    := ''
	Private oHora    := ''
	Private _cLote 	 := ''

	//http://stage0.hotmedia.com.br/portaldogado-api/v1/ws/frigorifico/abatesSoap/?wsdl

	RPCSetType(3) //nใo consome licen็a.

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "PCP"

	while _lRoda
	
		_cQuery1 := " SELECT TOP 1 ZK_NUMAM, ZK_LOTE, ZK_CONTROL, ZK_COBGOR, ZK_DENT, ZK_PETOTAL, ZK_IF, ZK_HORA, ZK_ORDEM
		_cQuery1 += " FROM " + retSqlTab('SZK') + " , " + retSqlTab('SZG')
		_cQuery1 += " WHERE " + retSqlFil('SZK') + " AND " + retSqlFil('SZG')
		_cQuery1 += " AND ZG_DATA = '" + dtos(date()) + "'"
		_cQuery1 += " AND ZG_STATUS = 'A' AND ZG_NUMAM = ZK_NUMAM"
		_cQuery1 += " AND ZK_CONTROL <> '' AND ZK_OK <> ''
		_cQuery1 += " AND " + retSqlDel('SZK') + " AND " + retSqlDel('SZG')
		_cQuery1 += " ORDER BY ZK_NUMAM, ZK_CONTROL DESC

		_cQuery1 := ChangeQuery(_cQuery1)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery1 Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		If Select("VER1")<>0
			VER1->(dbCloseArea())
		Endif

		TCQUERY _cQuery1 NEW ALIAS "VER1"

		DbSelectArea('SB1')

		if VER1->ZK_CONTROL <> oControl

			oControl := VER1->ZK_CONTROL
			oNumam 	 := VER1->ZK_NUMAM
			oLote    := VER1->ZK_LOTE
			oCobGor  := VER1->ZK_COBGOR
			oDent    := VER1->ZK_DENT
			oOrdem   := VER1->ZK_ORDEM

			If VER1->ZK_IF = 'S'
				oIf := 'S'
			Else
				oIf := 'N'
			EndIf

			if _cLote <> VER1->ZK_LOTE
				oHora := SUBSTR(VER1->ZK_HORA,1,5)
				_cLote := VER1->ZK_LOTE
			endif

			cCarcaca := fBuscaCPO("SZE", 2, FWxFilial("SZE") + VER1->ZK_NUMAM + VER1->ZK_LOTE, "ZE_TPCOM")

			If cCarcaca == "Q"
				_nPesoT := VER1->ZK_PETOTAL					 			//Calculo do peso total da carca็a
			Else
				_nPesoT := VER1->ZK_PETOTAL - (VER1->ZK_PETOTAL * 0.02) //Calculo do peso total da carca็a -2% de frio
			EndIf

			oPetotal := transform(_nPesoT,'@E 999.99')

			cAno:= substr(dtos(date()),1,4)
			cMes:= substr(dtos(date()),5,2)
			cDia:= substr(dtos(date()),7,2)

			_cData := cAno + '-' + cMes + '-' + cDia

			_cCodprod 	:= fBuscaCpo('SZ4',1,FWxFilial('SZ4') + oNumam + oLote,'Z4_FORNECE')
			_cLoja 	  	:= fBuscaCpo('SZ4',1,FWxFilial('SZ4') + oNumam + oLote,'Z4_LOJA')
			_nTotalLote := fBuscaCpo('SZ4',1,FWxFilial('SZ4') + oNumam + oLote,'Z4_QUANT')

			_cCgc     := fBuscaCpo('SA2',1,FWxFilial('SA2') + _cCodprod + _cLoja,'A2_CGC')
			


			BEGIN SEQUENCE

				_oWS := WSAbateSoapService():New()

				_oWS:oWSupdateDatadataArray:cTCLOTE 			 := oLote
				_oWS:oWSupdateDatadataArray:cTCCARCACA 			 := cCarcaca
				_oWS:oWSupdateDatadataArray:cTCCPF_CNPJ			 := _cCgc
				_oWS:oWSupdateDatadataArray:cTCDATAABATE 		 := _cData
				_oWS:oWSupdateDatadataArray:cTCHORAABATEINI 	 := oHora
				_oWS:oWSupdateDatadataArray:cTCNUMAM			 := oNumam
				_oWS:oWSupdateDatadataArray:cTCTOTALLOTE		 := transform(_nTotalLote, '@E 999')
				_oWS:oWSupdateDatadataArray:cTCSEQUENCIALABATE   := oControl
				_oWS:oWSupdateDatadataArray:cTCSEQUENCIALLOTE	 := str(oOrdem)
				_oWS:oWSupdateDatadataArray:cTCGORDURA			 := oCobGor
				_oWS:oWSupdateDatadataArray:cTCDENT				 := oDent
				_oWS:oWSupdateDatadataArray:cTCPESO				 := strtran(oPetotal,',','.')
				
				//cTCSEQUENCIALLOTE
				//cTCSEQUENCIALABATE
				//cTCTOTALLOTE
				_oWS:updateData()
				
				oXML := _oWS:creturn
				
			END SEQUENCE

		endif
	enddo
	RESET ENVIRONMENT

Return

