// Bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================
WSDL Location    http://10.0.0.239:99/ws/wsMpCartoesLista.apw?WSDL
Gerado em        28/12/2020
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
===============================================================================
*/


// Atributos de Entrada
WSSTRUCT cclRequest

	WSDATA cliente_id AS STRING

ENDWSSTRUCT


// Atributos com a estrutura com os dados que são exibidos no xml do webservice
// Isso é o que retornará para quem fizer a requisição
WSSTRUCT cclResponse

	WSDATA call_status	AS BOOLEAN
	WSDATA call_message AS STRING
	WSDATA call_code	AS STRING
	WSDATA aCclLis  	AS Array of Itensccl		// Array tipo complexo que montara a lista dos cartões de crédito

ENDWSSTRUCT   

// Array com a lista das notas fiscais
WSSTRUCT Itensccl

	WSDATA card_cod 		AS STRING
	WSDATA card_flag		AS STRING
	WSDATA card_last_digits	AS STRING
	WSDATA card_mes_exp 	AS INTEGER
	WSDATA card_ano_exp 	AS INTEGER
	WSDATA card_default 	AS BOOLEAN

ENDWSSTRUCT

                            
// Cria a tag de Webservice
WSSERVICE wsMpCartoesLista Description "WebService Meios de Pagamentos - Consulta Lista Cartoes de Credito"
	
	// Propriedades
	WSDATA lisccReq AS cclRequest		// Chama a estrutura dos dados de requisição
	WSDATA lisccRes AS cclResponse     	// Chama a estrutura dos dados de resposta        

	// Declara os metodos
	WSMETHOD getCartoes Description "<b> Metodo de retorno da lista de cartoes de credito</b><br> <u>Retorno</u><br> Listagem dos Cartoes de Credito
ENDWSSERVICE	// Fecha o servico

WSMETHOD getCartoes WSRECEIVE lisccReq WSSEND lisccRes WSSERVICE wsMpCartoesLista 
	Local aCC   := {}
	Local aCab  := {}
	Local aItem := {}
	Local i

	aCC := U_PesqCC(::lisccReq:Cliente_ID)

	If Len(aCC[1]) > 0 .And. Len(aCC[2]) > 0

		aCab  := aCC[1]
		aItem := aCC[2]

		::lisccRes:call_status 	:= aCab[1]
		::lisccRes:call_message	:= aCab[2]
		::lisccRes:call_code 	:= aCab[3]

		For i := 1 To Len(aItem)

			AADD(::lisccRes:aCclLis, WSClassNew("Itensccl"))
			oTemp := aTail( ::lisccRes:aCclLis )   

			oTemp:card_cod 		   := aItem[i][1]
			oTemp:card_flag  	   := aItem[i][2]
			oTemp:card_last_digits := aItem[i][3]
			oTemp:card_mes_exp	   := aItem[i][4]
			oTemp:card_ano_exp	   := aItem[i][5]
			oTemp:card_default	   := IIF(aItem[i][6] == "1", .T., .F.)

		Next i

	Else

		::lisccRes:call_status 	:= .F.
		::lisccRes:call_message	:= "Cliente não possui cartões de crédito informados na base de dados"
		::lisccRes:call_code 	:= "404"

		AADD(::lisccRes:aCclLis, WSClassNew("Itensccl"))
		oTemp := aTail( ::lisccRes:aCclLis )   

		oTemp:card_cod 		   := "."
		oTemp:card_flag  	   := "."
		oTemp:card_last_digits := "."
		oTemp:card_mes_exp	   := 0
		oTemp:card_ano_exp	   := 0
		oTemp:card_default	   := .F.

	Endif                                 

Return .T.   


// Função que lista os cartões de crédito do cliente
User Function PesqCC(_cCNPJCPF)

	Local aRet  := {} 
	Local aCab  := {} 
	Local aItem := {} 

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'OMS' TABLES 'ZK1'

	DbSelectArea("SA1")
	DbSetOrder(3)
	If MsSeek(xFilial("SA1") + _cCNPJCPF)
		cCliente := SA1->A1_COD
		cLojaCli := SA1->A1_LOJA

		AADD(aCab, .T.)											// resultado da chamada ao método (true/false)
		AADD(aCab, "Cartões de crédito listados com sucesso")	// mensagem da chamada (somente se false)
		AADD(aCab, "200")										// código da chamada (somente se false)

		cQuery := " SELECT * " 
		cQuery += "   FROM " + RetSqlTab("ZK1") 
		cQuery += "  WHERE " + RetSqlFil("ZK1") 
		cQuery += "    AND ZK1_CODCLI = '" + cCliente + "' "
		cQuery += "    AND ZK1_LOJCLI = '" + cLojaCli + "' "
		cQuery += "    AND " + RetSqlDel("ZK1")
		cQuery += "  ORDER BY ZK1_CCPREF"
	
		cQuery := ChangeQuery(cQuery)

		If Select("TMP") != 0
			TMP->(DbCloseArea())
		Endif

		TCQUERY cQuery NEW ALIAS "TMP"	

		DbSelectArea("TMP")
		DbGoTop()
		While TMP->(!Eof())

			AADD(aItem,{AllTrim(TMP->ZK1_CARDCD), AllTrim(TMP->ZK1_BANDEI), Right(AllTrim(TMP->ZK1_CCRED),4), TMP->ZK1_MESEXP, TMP->ZK1_ANOEXP, TMP->ZK1_CCPREF})
			
			TMP->(DbSkip())	     	
		EndDo

	Endif

	AADD(aRet,aCab)
	AADD(aRet,aItem)

Return aRet
