// Bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================
WSDL Location    http://10.0.0.239:99/ws/wsMpNfsLista.apw?WSDL
Gerado em        28/12/2020
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
===============================================================================
*/


// Atributos de Entrada
WSSTRUCT nfsRequest

	WSDATA cliente_id AS STRING

ENDWSSTRUCT


// Atributos com a estrutura com os dados que são exibidos no xml do webservice
// Isso é o que retornará para quem fizer a requisição
WSSTRUCT nfsResponse

	WSDATA call_status	AS BOOLEAN
	WSDATA call_message AS STRING
	WSDATA call_code	AS STRING
	WSDATA aNfsLis  	AS Array of Itens		// Array tipo complexo que montara a lista das notas fiscais

ENDWSSTRUCT   

// Array com a lista das notas fiscais
WSSTRUCT Itens

	WSDATA numero 	AS STRING
	WSDATA serie 	AS STRING
	WSDATA dth_nf	AS STRING
	WSDATA valor 	AS FLOAT

ENDWSSTRUCT

                            
// Cria a tag de Webservice
WSSERVICE wsMpNfsLista Description "WebService Meios de Pagamentos - Consulta Lista de Notas Fiscais"
	
	// Propriedades
	WSDATA listaReq AS nfsRequest		// Chama a estrutura dos dados de requisição
	WSDATA listaRes AS nfsResponse     	// Chama a estrutura dos dados de resposta        

	// Declara os metodos
	WSMETHOD getNotas Description "<b> Metodo de retorno da lista de notas fiscais</b><br> <u>Retorno</u><br> Listagem das Notas Fiscais

ENDWSSERVICE	// Fecha o servico

WSMETHOD getNotas WSRECEIVE listaReq WSSEND listaRes WSSERVICE wsMpNfsLista 
	Local aNF   := {}
	Local aCab  := {}
	Local aItem := {}
	Local i

	aNF := U_PesqNf(::listaReq:Cliente_ID)

	If Len(aNF[1]) > 0 .And. Len(aNF[2]) > 0

		aCab  := aNF[1]
		aItem := aNF[2]

		::listaRes:call_status 	:= aCab[1]
		::listaRes:call_message	:= aCab[2]
		::listaRes:call_code 	:= aCab[3]

		For i := 1 To Len(aItem)

			AADD(::listaRes:aNfsLis, WSClassNew("Itens"))
			oTemp := aTail( ::listaRes:aNfsLis )   

			oTemp:numero := aItem[i][1]
			oTemp:serie  := aItem[i][2]
			oTemp:dth_nf := aItem[i][3]
			oTemp:valor	 := aItem[i][4]

		Next i

	Else

		::listaRes:call_status 	:= .F.
		::listaRes:call_message	:= "Cliente não possui notas fiscais na base de dados"
		::listaRes:call_code 	:= "404"

		AADD(::listaRes:aNfsLis, WSClassNew("Itens"))
		oTemp := aTail( ::listaRes:aNfsLis )   

		oTemp:numero := "."
		oTemp:serie  := "."
		oTemp:dth_nf := "."
		oTemp:valor	 := 0

	Endif                                 

Return .T.   


// Função que pesquisa as 10 últimas notas fiscais do cliente
User Function PesqNf(_cCNPJCPF)

	Local aRet  := {} 
	Local aCab  := {} 
	Local aItem := {} 

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'OMS' TABLES 'SF2'

	DbSelectArea("SA1")
	DbSetOrder(3)
	If MsSeek(xFilial("SA1") + _cCNPJCPF)
		cCliente := SA1->A1_COD
		cLojaCli := SA1->A1_LOJA

		AADD(aCab, .T.)										// resultado da chamada ao método (true/false)
		AADD(aCab, "Notas fiscais listadas com sucesso")	// mensagem da chamada (somente se false)
		AADD(aCab, "200")									// código da chamada (somente se false)

		cQuery := " SELECT TOP 10 SF2.R_E_C_N_O_ AS XX_F2RECNO, F2_DOC, F2_SERIE, F2_EMISSAO, F2_HORA, F2_VALBRUT " 
		cQuery += "   FROM " + RetSqlTab("SF2") 
		cQuery += "  WHERE " + RetSqlFil("SF2") 
		cQuery += "    AND F2_CLIENTE = '" + cCliente + "' "
		cQuery += "    AND F2_LOJA    = '" + cLojaCli + "' "
		cQuery += "    AND " + RetSqlDel("SF2")
		cQuery += "  ORDER BY F2_EMISSAO DESC"
	
		cQuery := ChangeQuery(cQuery)

		If Select("TMP") != 0
			TMP->(DbCloseArea())
		Endif

		TCQUERY cQuery NEW ALIAS "TMP"	

		DbSelectArea("TMP")
		DbGoTop()
		While TMP->(!Eof())

			AADD(aItem,{TMP->F2_DOC, TMP->F2_SERIE, FWTimeStamp( 3, STOD(TMP->F2_EMISSAO), TMP->F2_HORA + ":00" ), TMP->F2_VALBRUT})
			
			TMP->(DbSkip())	     	
		EndDo

	Endif

	AADD(aRet,aCab)
	AADD(aRet,aItem)

Return aRet
