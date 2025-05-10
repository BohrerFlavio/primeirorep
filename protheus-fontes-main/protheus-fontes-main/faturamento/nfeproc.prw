#INCLUDE "protheus.ch"

User Function NfeProc(cXMLNFe,cXMLProt,cVersao,cNFMod)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³NfeProcNfe³ Autor ³ Eduardo Riera         ³ Data ³13.03.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Montagem do XML de distribuicao da NFe                      ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpC1: XML convertido                                       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1:XML da NFe assinado                                   ³±±
	±±³          ³ExpC2:XML com o protocolo da SEFAZ                          ³±±
	±±³          ³ExpC3:Modelo da NF                                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ 22/01/18 ³               ³ Copiada de fonte padrão e alterado nome da ³±±
	±±³          ³               ³ função, pois tirada do uso pela Totva      ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local aArea     := GetArea()
	Local nAt       := 0      
	Local nAy		:= 0
	Local cXml      := ""
	Local lDistrCanc:=.F.

	cNFMod := IIf(Empty(cNFMod),"55",cNFMod)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da mensagem                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAt := At("?>",cXmlProt)
	If nAt > 0
		nAt +=2
	Else
		nAt := 1
	EndIf
	Do Case
		Case cNFMod == "57"
		If !Empty(cXMLNFe)
			cXml := '<?xml version="1.0" encoding="UTF-8"?>'
			Do Case
				Case cVersao >= "1.03"
				cXml += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/cte procCTe_v1.00.xsd" versao="1.03">'
				OtherWise
				cXml += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/cte procCTe_v1.00.xsd" versao="'+cVersao+'">'
			EndCase
			cXml += cXmlNFe
		Else
			cXml := ""
		EndIf
		Do Case
			Case "retConsSitCTe" $ cXmlProt
			cXml += StrTran(SubStr(cXmlProt,nAt),"retConsSitCTe","protCTe")
			Case "retCancCTe" $ cXmlProt
			cXml += StrTran(SubStr(cXmlProt,nAt),"retCancCTe","protCTe")
			Case "retInutCTe" $ cXmlProt
			cXml += StrTran(SubStr(cXmlProt,nAt),"retInutCTe","protCTe")
			Case "protCTe" $ cXmlProt
			cXml += cXmlProt
			OtherWise
			cXml += "<protCTe>"
			cXml += cXmlProt
			cXml += "</protCTe>"
		EndCase
		If !Empty(cXMLNFe)
			cXml += '</cteProc>
		EndIf	
		OtherWise
		If !Empty(cXMLNFe)
			cXml := '<?xml version="1.0" encoding="UTF-8"?>'
			Do Case
				Case cVersao <= "1.07"
				cXml += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="1.00">'
				Case cVersao >= "2.00" .And. "cancNFe" $ cXmlNfe
				cXml += '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="'+cVersao+'">'
				lDistrCanc:= .T.					
				OtherWise
				cXml += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="'+cVersao+'">'
			EndCase
			cXml += cXmlNFe
		Else
			cXml := ""
		EndIf
		Do Case  
			Case "retConsSitNFe" $ cXmlProt	 .And. cVersao<"2.00"						
			cXmlProt := GeraProtNF(cXmlProt,cVersao,"retConsSitNFe")		
			cXml += cXmlProt
			Case "retCancNFe" $ cXmlProt .And. cVersao<"2.00"
			cXml += StrTran(SubStr(cXmlProt,nAt),"retCancNFe","protNFe")
			Case "retInutNFe" $ cXmlProt .And. cVersao<"2.00"
			cXml += StrTran(SubStr(cXmlProt,nAt),"retInutNFe","protNFe")
			Case "protNFe" $ cXmlProt .And. cVersao<"2.00" 				
			cXmlProt:= GeraProtNF(cXmlProt,cVersao,"retInutNFe")		
			cXml += cXmlProt 
			Case "PROTNFE" $ Upper(cXmlProt) .And. cVersao>="2.00" 				
			nAt:= At("<PROTNFE",Upper(cXmlProt))
			nAy:= RAt("</PROTNFE>",Upper(cXmlProt))       				
			cXmlProt:= SubStr(Upper(cXmlProt),nAt,nAy-nAt+10)
			cXmlProt:= GeraProtNF(cXmlProt,cVersao,"PROTNFE")
			cXml += cXmlProt				 
			Case "RETCANCNFE" $ Upper(cXmlProt) .And. cVersao>="2.00"
			cXmlProt:= GeraProtNF(cXmlProt,cVersao,"RETCANCNFE")
			cXml += cXmlProt				
			Case "RETINUTNFE" $ Upper(cXmlProt) .And. cVersao>="2.00"
			cXml += StrTran(SubStr(cXmlProt,nAt),"RETINUTNFE","protNFe")
			Case "RETCONSSITNFE" $ Upper(cXmlProt)	 .And. cVersao>="2.00"			
			cXml += StrTran(SubStr(cXmlProt,nAt),"RETCONSSITNFE","protNFe")		
			OtherWise
			cXml += "<protNFe>"
			cXml += cXmlProt
			cXml += "</protNFe>"
		EndCase              
		If cVersao < "2.00"
			nAt := At("versao=",cXml)
			cXml := StrTran(cXml,SubStr(cXml,nAt,13),'versao="'+cVersao+'"',,1)
		EndIf
		If !Empty(cXMLNFe)
			If lDistrCanc
				cXml += '</procCancNFe>'				
			Else 
				cXml += '</nfeProc>'
			EndIf
		EndIf
	EndCase

	RestArea(aArea)

Return(AllTrim(cXml))
