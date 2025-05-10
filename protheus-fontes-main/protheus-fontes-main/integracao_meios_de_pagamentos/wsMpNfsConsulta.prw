// Bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================
WSDL Location    http://10.0.0.239:99/ws/wsMpNfsConsulta.apw?WSDL
Gerado em        28/12/2020
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
===============================================================================
*/


// Atributos de Entrada
WSSTRUCT nfcRequest

	WSDATA numero AS STRING
	WSDATA serie  AS STRING

ENDWSSTRUCT


// Atributos com a estrutura com os dados que são exibidos no xml do webservice
// Isso é o que retornará para quem fizer a requisição
WSSTRUCT nfcResponse

	WSDATA call_status	AS BOOLEAN
	WSDATA call_message AS STRING
	WSDATA call_code	AS STRING
	WSDATA cpf_cnpj 	AS STRING
	WSDATA nome     	AS STRING
	WSDATA numero   	AS STRING
	WSDATA serie    	AS STRING
	WSDATA dth_nf   	AS STRING
	WSDATA peso     	AS FLOAT
	WSDATA valor    	AS FLOAT
	WSDATA aNfsCons  	AS Array of Itensc		// Array tipo complexo que montara os Itensc da nota fiscal consultada

ENDWSSTRUCT   

// Array com a lista das notas fiscais
WSSTRUCT Itensc

	WSDATA item   	AS STRING
	WSDATA produto	AS STRING
	WSDATA descric	AS STRING
	WSDATA unidmed 	AS STRING
	WSDATA qtde    	AS FLOAT
	WSDATA vlunit  	AS FLOAT
	WSDATA vltotal 	AS FLOAT

ENDWSSTRUCT

                            
// Cria a tag de Webservice
WSSERVICE wsMpNfsConsulta Description "WebService Meios de Pagamentos - Consulta de uma Nota Fiscal"
	
	// Propriedades
	WSDATA ConsuReq AS nfcRequest		// Chama a estrutura dos dados de requisição
	WSDATA ConsuRes AS nfcResponse     	// Chama a estrutura dos dados de resposta        

	// Declara os metodos
	WSMETHOD getNotas Description "<b> Metodo de retorno da consulta de uma nota fiscal</b><br> <u>Retorno</u><br> Listagem das Notas Fiscais<br> Array dos Itensc da nota fiscal

ENDWSSERVICE	// Fecha o servico

WSMETHOD getNotas WSRECEIVE ConsuReq WSSEND ConsuRes WSSERVICE wsMpNfsConsulta 
	Local aNF   := {}
	Local aCab  := {}
	Local aItem := {}
	Local i

	aNF := U_PesqNfs(::ConsuReq:numero, ::ConsuReq:serie)

	If Len(aNF[1]) > 0 .And. Len(aNF[2]) > 0

		aCab  := aNF[1]
		aItem := aNF[2]

		::ConsuRes:call_status 	:= aCab[1]
		::ConsuRes:call_message	:= aCab[2]
		::ConsuRes:call_code 	:= aCab[3]
		::ConsuRes:cpf_cnpj  	:= aCab[4]
		::ConsuRes:nome      	:= aCab[5]
		::ConsuRes:numero    	:= aCab[6]
		::ConsuRes:serie     	:= aCab[7]
		::ConsuRes:dth_nf    	:= aCab[8]
		::ConsuRes:peso      	:= aCab[9]
		::ConsuRes:valor     	:= aCab[10]

		For i := 1 To Len(aItem)

			AADD(::ConsuRes:aNfsCons, WSClassNew("Itensc"))
			oTemp := aTail( ::ConsuRes:aNfsCons )   

			oTemp:item    := aItem[i][1]
			oTemp:produto := aItem[i][2]
			oTemp:descric := aItem[i][3]
			oTemp:unidmed := aItem[i][4]
			oTemp:qtde 	  := aItem[i][5]
			oTemp:vlunit  := aItem[i][6]
			oTemp:vltotal := aItem[i][7]

		Next i

	Else

		::ConsuRes:call_status 	:= .F.
		::ConsuRes:call_message	:= "Nota fiscal não encontrada na base de dados"
		::ConsuRes:call_code 	:= "404"
		::ConsuRes:cpf_cnpj  	:= "."
		::ConsuRes:nome      	:= "."
		::ConsuRes:numero    	:= "."
		::ConsuRes:serie     	:= "."
		::ConsuRes:dth_nf    	:= "."
		::ConsuRes:peso      	:= 0 
		::ConsuRes:valor     	:= 0

		AADD(::ConsuRes:aNfsCons, WSClassNew("Itensc"))
		oTemp := aTail( ::ConsuRes:aNfsCons )   

		oTemp:item    := "."
		oTemp:produto := "."
		oTemp:descric := "."
		oTemp:unidmed := "."
		oTemp:qtde 	  := 0 
		oTemp:vlunit  := 0 
		oTemp:vltotal := 0

	Endif                                 

Return .T.   


// Função que pesquisa a nota fiscal
User Function PesqNfs(_cDoc, _cSerie)

	Local aRet  := {} 
	Local aCab  := {} 
	Local aItem := {} 

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'OMS' TABLES 'SF2'

	DbSelectArea("SF2")
	DbSetOrder(1)
	If MsSeek(xFilial("SF2") + _cDoc + _cSerie)

		AADD(aCab, .T.)										// resultado da chamada ao método (true/false)
		AADD(aCab, "Nota fiscal consultada com sucesso")	// mensagem da chamada (somente se false)
		AADD(aCab, "200")									// código da chamada (somente se false)
		AADD(aCab, fBuscaCpo("SA1", 1, xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, "A1_CGC"))
		AADD(aCab, fBuscaCpo("SA1", 1, xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, "A1_NOME"))
		AADD(aCab, SF2->F2_DOC)
		AADD(aCab, SF2->F2_SERIE)
		AADD(aCab, FWTimeStamp( 3, SF2->F2_EMISSAO, SF2->F2_HORA + ":00" ))
		AADD(aCab, SF2->F2_PLIQUI)
		AADD(aCab, SF2->F2_VALBRUT)

		cQuery := " SELECT * " 
		cQuery += "   FROM " + RetSqlTab("SD2") 
		cQuery += "  WHERE " + RetSqlFil("SD2") 
		cQuery += "    AND D2_DOC = '" + _cDoc + "' "
		cQuery += "    AND D2_SERIE    = '" + _cSerie + "' "
		cQuery += "    AND " + RetSqlDel("SD2")
		cQuery += "  ORDER BY D2_ITEM + D2_COD"
	
		cQuery := ChangeQuery(cQuery)

		If Select("TMP") != 0
			TMP->(DbCloseArea())
		Endif

		TCQUERY cQuery NEW ALIAS "TMP"	

		DbSelectArea("TMP")
		DbGoTop()
		While TMP->(!Eof())

			AADD(aItem,{TMP->D2_ITEM, TMP->D2_COD, TMP->D2_DESCRI, TMP->D2_UM, D2_QUANT, D2_PRCVEN, D2_TOTAL})

			TMP->(DbSkip())	     	
		EndDo

	Endif

	AADD(aRet,aCab)
	AADD(aRet,aItem)

Return aRet
