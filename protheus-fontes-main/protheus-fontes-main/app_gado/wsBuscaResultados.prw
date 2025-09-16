#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณwsBuscaResultados  บAutorณMauricio Roehrs บ Data ณ  01/05/19 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Web Service Server para listar resultados de um produtor  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//Nessa estrutura vem o dado de entrada
WSSTRUCT brEntrada
	WSDATA TCCODINTERNO_PRODUTOR AS STRING
	WSDATA TCDATAINICIO 		 AS STRING
	WSDATA TCDATAFIM 	 		 AS STRING
	WSDATA TCTIPO				 AS INTEGER
	WSDATA TCCPF_CNPJ			 AS STRING
ENDWSSTRUCT

//Cria estrutura com os dados que sใo exibidos no xml do webservice
//Isso ้ o que retornarแ para quem fizer a requisi็ใo
WSSTRUCT brResposta

	WSDATA SUCESSO     	  AS INTEGER
	WSDATA TCARRAYRESULT  AS Array of arrayResultados

ENDWSSTRUCT

WSSTRUCT arrayResultados

	WSDATA TCNUMAM 					AS STRING
	WSDATA TCCODLOTE 				AS STRING
	WSDATA TCCODINTERNO_PRODUTOR 	AS STRING
	WSDATA TCLOJAPRODUTOR 			AS STRING
	WSDATA TCDATAABATE 				AS STRING
	WSDATA TCGTA 					AS STRING
	WSDATA TCTOTALLOTE 				AS STRING
	WSDATA TCNOMEPRODUTOR			AS STRING
	WSDATA TCCPFCNPJ_PRODUTOR		AS STRING
	WSDATA TCPRCBASE				AS STRING
	WSDATA TCCATEGORIA				AS STRING
	WSDATA TCORIGEM					AS STRING
	WSDATA TCINSCRICAOESTADUAL		AS STRING
	WSDATA TCCOMPRADOR				AS STRING

ENDWSSTRUCT

//Cria a tag de Webservice
WSSERVICE wsBuscaResultados Description "Servico contendo o metodo para buscar resultados de abate"

	//Proriedades
	WSDATA dadosEnt AS brEntrada 	  //chama a estrutura dos dados de entrada
	WSDATA dadosRet AS brResposta     //chama a estrutura dos dados de retorno do pedido

	//Declara os metodos
	WSMETHOD dadosBR Description "<b> Metodo de rotorno dos restudos de abate</b><br> <u>Retorno</u><br> lotes do produtor informado, dentro de um intervalo de datas"

ENDWSSERVICE//fecha o servico

WSMETHOD dadosBR WSRECEIVE dadosEnt WSSEND dadosRet WSSERVICE wsBuscaResultados
	local aBR    := {}
	local i
	RPCSetType(3) //nใo consome licen็a.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'SZ4'

	aBR := u_pesqResult(::dadosEnt:TCCODINTERNO_PRODUTOR, ::dadosEnt:TCDATAINICIO, ::dadosEnt:TCDATAFIM, ::dadosEnt:TCTIPO, ::dadosEnt:TCCPF_CNPJ)

	if len(aBR) > 0

		::dadosRet:SUCESSO := 1

		for i := 1 to len(aBr)

			aadd(::dadosRet:TCARRAYRESULT, WSClassNew("arrayResultados"))
			oTemp := aTail( ::dadosRet:TCARRAYRESULT )
			//oTemp :=  ::dadosRet:aProdutor

			//oTemp:TCSEQLOTE 	:= aListAnimais[i][1]

			cAno:= substr(aBR[i][5],1,4)
			cMes:= substr(aBR[i][5],5,2)
			cDia:= substr(aBR[i][5],7,2)

			oTemp:TCNUMAM 					:= aBR[i][1]
			oTemp:TCCODLOTE 				:= aBR[i][2]
			oTemp:TCCODINTERNO_PRODUTOR		:= aBR[i][3]
			oTemp:TCLOJAPRODUTOR 			:= aBR[i][4]
			oTemp:TCDATAABATE 				:= cAno + '-' + cMes + '-' + cDia //aBR[i][5]
			oTemp:TCGTA 					:= aBR[i][6]
			oTemp:TCTOTALLOTE 				:= transform(aBR[i][7], '@E 999')
			oTemp:TCNOMEPRODUTOR			:= fBuscaCpo('SA2',1,FWxFilial('SA2') + aBR[i][3] + aBR[i][4],'A2_NOME')//aBr[i][8]
			oTemp:TCCPFCNPJ_PRODUTOR		:= fBuscaCpo('SA2',1,FWxFilial('SA2') + aBR[i][3] + aBR[i][4],'A2_CGC')
			oTemp:TCPRCBASE					:= aBR[i][9]
			oTemp:TCCATEGORIA				:= aBR[i][10]
			oTemp:TCORIGEM					:= aBR[i][11]
			oTemp:TCINSCRICAOESTADUAL		:= aBR[i][12]
			oTemp:TCCOMPRADOR				:= aBR[i][13]

		next i

	else

		::dadosRet:SUCESSO := 0

		aadd(::dadosRet:TCARRAYRESULT, WSClassNew("arrayResultados"))
		oTemp := aTail( ::dadosRet:TCARRAYRESULT )

		oTemp:TCNUMAM 					:= ""
		oTemp:TCCODLOTE 				:= ""
		oTemp:TCCODINTERNO_PRODUTOR		:= ""
		oTemp:TCLOJAPRODUTOR 			:= ""
		oTemp:TCDATAABATE 				:= ""
		oTemp:TCGTA 					:= ""
		oTemp:TCTOTALLOTE 				:= ""
		oTemp:TCNOMEPRODUTOR			:= ""
		oTemp:TCCPFCNPJ_PRODUTOR		:= ""
		oTemp:TCPRCBASE					:= ""
		oTemp:TCCATEGORIA				:= ""
		oTemp:TCORIGEM					:= ""
		oTemp:TCINSCRICAOESTADUAL		:= ""
		oTemp:TCCOMPRADOR				:= ""

	endif

Return .t.

//Fun็ใo que pesquisa os pedidos de venda
User Function pesqResult(_produtor,_cDtIni,_cDtFim,_nTipo,_cCGC)

	Local aRet   := {}

	_cDataIni := substr(_cDtIni,1,4) + substr(_cDtIni,6,2) + substr(_cDtIni,9,2)
	_cDatafin := substr(_cDtFim,1,4) + substr(_cDtFim,6,2) + substr(_cDtFim,9,2)


	if _nTipo = 1 //se for produtor

		_cQuery := " SELECT Z4_NUMAM, Z4_LOTE, Z4_FORNECE, Z4_LOJA ,Z4_NOME, Z4_COMPRAD, Z4_DATA, Z4_HORA, Z4_GTA,Z4_QTREAL,Z4_DESCAT, Z4_QUANT "
		_cQuery += " FROM "+RetSqlTab("SZ4")
		_cQuery += " WHERE  " + RetSQLFil('SZ4') + "  AND Z4_DATA BETWEEN  '" + _cDataIni + "' AND '" + _cDatafin + "' AND Z4_STATUSP = 'L'"
		_cQuery += " AND Z4_FORNECE = '" + padl(alltrim(_produtor),6,'0') + "'"
		//_cQuery += " AND Z4_FORNECE = '" + padl(alltrim(_produtor),6,'0') + "' AND Z4_STATUSP = 'L'"
		//_cQuery += " AND " + iif(_nTipo = 1,"Z4_FORNECE = '" + padl(alltrim(_produtor),6,'0') + "'","Z4_COMPRAD = '" + padl(alltrim(_produtor),6,'0') + "'") + " "
		_cQuery += " AND " + RetSQLDel('SZ4')
		_cQuery += " ORDER BY Z4_DATA, Z4_NOME"

		_cQuery  := ChangeQuery(_cQuery)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		if Select("TMP") != 0
			TMP->(dbCloseArea())
		endif

		TCQUERY _cQuery NEW ALIAS "TMP"

	elseif _nTipo = 2 // se for comprador

		_cQuery := " SELECT Z4_NUMAM, Z4_LOTE, Z4_FORNECE, Z4_LOJA ,Z4_NOME, Z4_COMPRAD, Z4_DATA, Z4_HORA, Z4_GTA,Z4_QTREAL,Z4_DESCAT, Z4_QUANT "
		_cQuery += " FROM " + RetSqlTab('SZ4') + ", " + RetSqlTab('SA2')
		_cQuery += " WHERE  " + RetSQLFil('SZ4') + "  AND Z4_DATA BETWEEN  '" + _cDataIni + "' AND '" + _cDatafin + "' AND Z4_STATUSP = 'L'"
		_cQuery += " AND Z4_COMPRAD = '" + padl(alltrim(_produtor),6,'0') + "'"
		_cQuery += " AND Z4_FORNECE = A2_COD AND Z4_LOJA = A2_LOJA"
		if !empty(_cCGC)
			_cQuery += " AND A2_CGC = '" + _cCGC + "'
		endif
		_cQuery += " AND " + RetSQLDel('SZ4')
		_cQuery += " ORDER BY Z4_DATA, Z4_NOME"

		_cQuery  := ChangeQuery(_cQuery)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		if Select("TMP") != 0
			TMP->(dbCloseArea())
		endif

		TCQUERY _cQuery NEW ALIAS "TMP"

	endif



	TMP->(dbGoTop())
	while TMP->(!eof())

		SZE->(DbSetorder(2))
		SZE->(DbSeek(FWxFilial('SZE')+TMP->(Z4_NUMAM+Z4_LOTE)),.F.)
		SZ9->(DbSetOrder(1))
		SZ9->(DbSeek(FWxFilial('SZ9')+SZE->ZE_NUMSC+SZE->ZE_ITEMSC ) )
		SZD->(DbSetorder(1))
		SZD->(DbSeek(FWxFilial('SZD')+SZE->ZE_NUMERO))    

		_cNumComp := fBuscaCPO('SZA',1,FWxfilial('SZA')+SZ9->Z9_NUMERO,'ZA_COMPRA')      
		_cNomeCom := fBuscaCPO('SA3',1,FWxfilial('SA3')+_cNumComp,'A3_NOME')
		POSICIONE("SA2",1,FWXFILIAL("SA2")+SZD->(ZD_FORNECE+ZD_LOJA),"A2_NOME")
		
		aadd(aRet,{TMP->Z4_NUMAM, TMP->Z4_LOTE, TMP->Z4_FORNECE, TMP->Z4_LOJA, TMP->Z4_DATA, TMP->Z4_GTA, TMP->Z4_QUANT,TMP->Z4_NOME, Transform(SZ9->Z9_PRECO, '@E 999.99'), TMP->Z4_DESCAT, AllTrim(SA2->A2_MUN), AllTrim(SA2->A2_INSCR), AllTrim(_cNomeCom)})

		TMP->(dbSkip())
	enddo

return aRet

