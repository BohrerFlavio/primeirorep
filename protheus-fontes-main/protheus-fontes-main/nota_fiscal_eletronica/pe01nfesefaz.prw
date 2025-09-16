#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} PE01NFESEFAZ
@Type			: Ponto de Entrada
@Sample			: U_PE01NFESEFAZ()
@Description	: Ponto de entrada localizado na função XmlNfeSef do rdmake NFESEFAZ. 
                  Através deste ponto é possível realizar manipulações nos dados do produto, 
				  mensagens adicionais, destinatário, dados da nota, pedido de venda ou 
				  compra, antes da montagem do XML, no momento da transmissão da NFe
@Param			: aParam	Array of Record	
				  aProd 	 := PARAMIXB[1]
				  cMensCli 	 := PARAMIXB[2]
				  cMensFis 	 := PARAMIXB[3]
				  aDest 	 := PARAMIXB[4]
				  aNota 	 := PARAMIXB[5]
				  aInfoItem  := PARAMIXB[6]
				  aDupl 	 := PARAMIXB[7]
				  aTransp 	 := PARAMIXB[8]
				  aEntrega 	 := PARAMIXB[9]
				  aRetirada  := PARAMIXB[10]
				  aVeiculo 	 := PARAMIXB[11]
				  aReboque 	 := PARAMIXB[12]
				  aNfVincRur := PARAMIXB[13]
				  aEspVol 	 := PARAMIXB[14]
				  aNfVinc 	 := PARAMIXB[15]
				  aDetPag 	 := PARAMIXB[16]
				  aObsCont	 := PARAMIXB[17]
				  aProcRef 	 := PARAMIXB[18]
				  aMed 		 := PARAMIXB[19]
				  aLote 	 := PARAMIXB[20]
@Return			: aRetorno (array_of_record)
				  O retorno deve ser exatamente nesta ordem e passando o conteúdo completo dos arrays
				  pois no rdmake nfesefaz é atribuido o retorno completo para as respectivas variáveis
				  Ordem:
				  aRetorno[1] -> aProd
				  aRetorno[2] -> cMensCli
				  aRetorno[3] -> cMensFis
				  aRetorno[4] -> aDest
				  aRetorno[5] -> aNota
				  aRetorno[6] -> aInfoItem
				  aRetorno[7] -> aDupl
				  aRetorno[8] -> aTransp
				  aRetorno[9] -> aEntrega
				  aRetorno[10] -> aRetirada
				  aRetorno[11] -> aVeiculo
				  aRetorno[12] -> aReboque
				  aRetorno[13] -> aNfVincRur
				  aRetorno[14] -> aEspVol
				  aRetorno[15] -> aNfVinc
				  aRetorno[16] -> AdetPag
				  aRetorno[17] -> aObsCont
				  aRetorno[18] -> aProcRef
				  aRetorno[19] -> aMed
				  aRetorno[20] -> aLote
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Out/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------

User Function PE01NFESEFAZ()
	Local aArea      := FWGetArea()

	Local aProd      := PARAMIXB[1]
	Local cMensCli   := PARAMIXB[2]
	Local cMensFis   := PARAMIXB[3]
	Local aDest      := PARAMIXB[4]
	Local aNota      := PARAMIXB[5]
	Local aInfoItem  := PARAMIXB[6]
	Local aDupl      := PARAMIXB[7]
	Local aTransp    := PARAMIXB[8]
	Local aEntrega   := PARAMIXB[9]
	Local aRetirada  := PARAMIXB[10]
	Local aVeiculo   := PARAMIXB[11]
	Local aReboque   := PARAMIXB[12]
	Local aNfVincRur := PARAMIXB[13]
	Local aEspVol    := PARAMIXB[14]
	Local aNfVinc    := PARAMIXB[15]
	Local AdetPag    := PARAMIXB[16]
	Local aObsCont   := PARAMIXB[17]
	Local aProcRef   := PARAMIXB[18]
	Local aMed       := PARAMIXB[19]
	Local aLote      := PARAMIXB[20]
	Local aRetorno   := {}

	Local cDescProd  := ""
	Local cSeparador := CRLF
	Local nI

	If aNota[4] == "0" 	// Se for nota fiscal de entrada

		// Ajusto as informações do produto
		For nI := 1 To Len(aProd)

			DbSelectArea("SD1")
			SD1->( DbSetOrder(1) )
			SD1->( DbSeek(FWxFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + aProd[nI][2] + aProd[nI][55], .F. ) )

			cDescProd := aProd[nI][4] + cSeparador

			_nPesoLiq := GetAdvFVal("SC7", "C7_QTDREND", FWxFilial("SC7") + SD1->D1_PEDIDO + SD1->D1_ITEMPC, 1, 0, .T.)

			// Adiciona na TAG infadProd
			If SD1->D1_FORMUL == "S" .And. AllTrim(SD1->D1_COD) $ "000230/000231/001073/001074/001075" .And. Len(aProd) > 0
				aProd[nI][25] += PADR("Qtd Cab: " + AllTrim(Transform(SD1->D1_QTSEGUM, "@E 999")) + " Peso Líq.: " + AllTrim(Transform(_nPesoLiq, "@E 999,999.999")) + " KG", 38, "") 	//+ cSeparador
				//aProd[nI][25] += PADR("Rendimento: " + IIF(AllTrim(aProd[nI][2]) $ "000231/001074", AllTrim(Str(GetMv("PV_RDFEMEA"),5,2)), AllTrim(Str(GetMv("PV_RDMACHO"),5,2))) + " %", 38, "")
			EndIf

			// Ajusto a descrição do produto
			aProd[nI][4] := AllTrim(cDescProd)

		Next nI

	EndIf

	aadd(aRetorno,aProd)
	aadd(aRetorno,cMensCli)
	aadd(aRetorno,cMensFis)
	aadd(aRetorno,aDest)
	aadd(aRetorno,aNota)
	aadd(aRetorno,aInfoItem)
	aadd(aRetorno,aDupl)
	aadd(aRetorno,aTransp)
	aadd(aRetorno,aEntrega)
	aadd(aRetorno,aRetirada)
	aadd(aRetorno,aVeiculo)
	aadd(aRetorno,aReboque)
	aadd(aRetorno,aNfVincRur)
	aadd(aRetorno,aEspVol)
	aadd(aRetorno,aNfVinc)
	aadd(aRetorno,AdetPag)
	aadd(aRetorno,aObsCont)
	aadd(aRetorno,aProcRef)
	aadd(aRetorno,aMed)
	aadd(aRetorno,aLote)
  
	FWRestArea(aArea)

Return(aRetorno)
