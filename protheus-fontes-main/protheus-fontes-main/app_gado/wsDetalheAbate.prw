#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณwsDetalheAbate  บAutor  ณMauricio Roehrs บ Data ณ  14/06/19 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ webservice para apresentar os detalhes do abate 			  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//Nessa estrutura vem o dado de entrada
WSSTRUCT dtlheEntrada
	WSDATA TCNUMAM 	AS STRING
	WSDATA TCCODIGO	AS STRING
ENDWSSTRUCT

//Cria estrutura com os dados que sใo exibidos no xml do webservice
//Isso ้ o que retornarแ para quem fizer a requisi็ใo
WSSTRUCT dtlheResposta

	WSDATA SUCESSO     	AS INTEGER
	WSDATA aTotaisAbate AS Array of aTotaisLote
	WSDATA aItensAbate  AS Array of aAnimaisLote//Array tipo complexo que montara todas lojas do usuario logado
	WSDATA aTotGord     AS Array of aTotaisGordura
	WSDATA aTotProg		AS Array of aTotaisPrograma
	WSDATA aTotAFPad	AS Array of aTotaisForaPadrao
	WSDATA aTotDiagDoen AS Array of aTotaisDiagDoenca
	WSDATA aItemPCompra AS Array of aItensPedCompra
	WSDATA aInfFinal    AS Array of aInformacoesFinais

ENDWSSTRUCT

WSSTRUCT aInformacoesFinais

	WSDATA TCPRECOMEDIOFINAL AS STRING
	WSDATA TCTOTALFUNDESA	 AS STRING
	WSDATA TCPREVISOCIAL	 AS STRING
	WSDATA TCFUNRURAL		 AS STRING
	WSDATA TCTOTALARECEBER   AS STRING

ENDWSSTRUCT

WSSTRUCT aItensPedCompra

	WSDATA TCNUMPEDIDO   AS STRING
	WSDATA TCQUANTPEDIDO AS STRING
	WSDATA TCPESOPEDIDO  AS STRING
	WSDATA TCPRECOPEDIDO AS STRING
	WSDATA TCSUBTOTPED	 AS STRING

ENDWSSTRUCT

WSSTRUCT aTotaisDiagDoenca

	WSDATA TCDESCRIDOENCA AS STRING
	WSDATA TCTOTCABDOENCA AS STRING

ENDWSSTRUCT

WSSTRUCT aTotaisForaPadrao

	WSDATA TCDESCRICAO  AS STRING
	WSDATA TCTOTCATEG  AS STRING

ENDWSSTRUCT

WSSTRUCT aTotaisPrograma

	WSDATA TCCODPROG     AS STRING
	WSDATA TCTOTCABPROG  AS STRING
	WSDATA TCDESCPROG	 AS STRING

ENDWSSTRUCT

WSSTRUCT aAnimaisLote

	WSDATA TCSEQLOTE 		AS STRING
	WSDATA TCSECABATE 		AS STRING
	WSDATA TCPESCARCFRIA    AS STRING
	WSDATA TCIDADEDENT		AS STRING
	WSDATA TCCLASSEGORD 	AS STRING
	WSDATA TCCODCONTUS		AS STRING
	WSDATA TCCARCRASTR		AS STRING //CARCAวA RASTREADA
	WSDATA TCDENTCARC		AS STRING
	WSDATA TCPRECO			AS STRING
	WSDATA TCRACA			AS STRING
	WSDATA TCPROGRAMA		AS STRING
	WSDATA TCTIPOCARC		AS STRING

ENDWSSTRUCT

WSSTRUCT aTotaisLote

	WSDATA TCPESOPROP 		 AS STRING
	WSDATA TCPESOMEDORIG 	 AS STRING
	WSDATA TCRENDIMORIG 	 AS STRING
	WSDATA TCPESOLOTE 		 AS STRING
	WSDATA TCPESMEDLOTE		 AS STRING
	WSDATA TCRENDILOTE		 AS STRING
	WSDATA TCPTOTCARCFRIA 	 AS STRING
	WSDATA TCQUEBRATRANSP 	 AS STRING
	WSDATA TCPMEDCARCFRIA	 AS STRING
	WSDATA TCTOTPRENHEZ 	 AS STRING
	WSDATA TCQUEBRAPESTRANSP AS STRING
	WSDATA TCPRENHEZADIANT 	 AS STRING

ENDWSSTRUCT

WSSTRUCT aTotaisGordura

	WSDATA TCGORD	 	 AS STRING
	WSDATA TCDESCGORD 	 AS STRING
	WSDATA TCTOTCABGORD  AS STRING

ENDWSSTRUCT

//Cria a tag de Webservice
WSSERVICE wsDetalheAbate Description "Servico contendo o metodo para detalhes de um determinado lote"

	/*dados para teste
	39530973004
	bruna*/

	//Proriedades
	WSDATA dadosEnt AS dtlheEntrada 	  //chama a estrutura dos dados de entrada
	WSDATA dadosRet AS dtlheResposta     //chama a estrutura dos dados de retorno

	//Declara os metodos
	WSMETHOD detalheAbate Description "<b> Metodo de rotorno do detalhe do abate</b><br>

ENDWSSERVICE//fecha o servico

WSMETHOD detalheAbate WSRECEIVE dadosEnt WSSEND dadosRet WSSERVICE wsDetalheAbate

	//local aCab   		 := {}
	//local aItem  		 := {}
	//local aItem2 		 := {}
	local _aResult 		 := {}
	Local aTotais 		 := {}
	local aListAnimais   := {}
	local aTotGordura    := {}
	local aTotPrograma   := {}
	local aTotForaPadr	 := {}
	local aTotDoencas	 := {}
	local aInfPedComp	 := {}
	local _aInformFinais := {}
	local i
	local j
	local k
	local l

	RPCSetType(3) //nใo consome licen็a. 
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'SZK','SZ4','SZG'

	_aResult := u_listaResult( padl(alltrim(::dadosEnt:TCNUMAM),8,'0'), padl(alltrim(::dadosEnt:TCCODIGO),6,'0'))

	if len(_aResult[1]) > 0

		aListAnimais  := _aResult[1]
		aTotais 	  := _aResult[2]
		aTotGordura   := _aResult[3]
		aTotPrograma  := _aResult[4]
		aTotForaPadr  := _aResult[5]
		aTotDoencas   := _aResult[6]
		aInfPedComp   := _aResult[7]
		_aInformFinais := _aResult[8]

		::dadosRet:SUCESSO := 1

		/*Animais do Sequencial do lote*/
		for i := 1 to len(aListAnimais)

			aadd(::dadosRet:aItensAbate, WSClassNew("aAnimaisLote"))
			oTemp := aTail( ::dadosRet:aItensAbate )

			oTemp:TCSEQLOTE 	:= aListAnimais[i][1]
			oTemp:TCSECABATE 	:= aListAnimais[i][2]
			oTemp:TCPESCARCFRIA := aListAnimais[i][3]
			oTemp:TCIDADEDENT 	:= aListAnimais[i][4]
			oTemp:TCCLASSEGORD 	:= aListAnimais[i][5]
			oTemp:TCCODCONTUS 	:= aListAnimais[i][6]
			oTemp:TCCARCRASTR 	:= aListAnimais[i][7]
			oTemp:TCDENTCARC 	:= aListAnimais[i][8]
			oTemp:TCPRECO 		:= aListAnimais[i][9]
			oTemp:TCRACA 		:= aListAnimais[i][10]
			oTemp:TCPROGRAMA 	:= aListAnimais[i][11]
			oTemp:TCTIPOCARC 	:= aListAnimais[i][12]

		next i

		/*Totais dos lotes*/
		for j:=1 to len(aTotais)

			aadd(::dadosRet:aTotaisAbate, WSClassNew("aTotaisLote"))
			oTemp2 := aTail( ::dadosRet:aTotaisAbate )

			oTemp2:TCPESOPROP 		 := aTotais[j][1]
			oTemp2:TCPESOMEDORIG 	 := aTotais[j][2]
			oTemp2:TCRENDIMORIG 	 := aTotais[j][3]
			oTemp2:TCPESOLOTE 		 := aTotais[j][4]
			oTemp2:TCPESMEDLOTE		 := aTotais[j][5]
			oTemp2:TCRENDILOTE		 := aTotais[j][6]
			oTemp2:TCPTOTCARCFRIA 	 := aTotais[j][7]
			oTemp2:TCQUEBRATRANSP 	 := aTotais[j][8]
			oTemp2:TCPMEDCARCFRIA	 := aTotais[j][9]
			oTemp2:TCTOTPRENHEZ 	 := aTotais[j][10]
			oTemp2:TCQUEBRAPESTRANSP := aTotais[j][11]
			oTemp2:TCPRENHEZADIANT 	 := aTotais[j][12]

		next j

		/*Totais quanto a Gordura*/
		for k:=1 to len(aTotGordura)

			aadd(::dadosRet:aTotGord, WSClassNew("aTotaisGordura"))
			oTemp3 := aTail( ::dadosRet:aTotGord )

			oTemp3:TCGORD 		 := aTotGordura[k][1]
			oTemp3:TCTOTCABGORD  := transform(aTotGordura[k][2],'@E 999')
			oTemp3:TCDESCGORD 	 := aTotGordura[k][3]

		next k

		/*Totais quanto a programa*/
		for l:=1 to len(aTotPrograma)

			aadd(::dadosRet:aTotProg, WSClassNew("aTotaisPrograma"))
			oTemp4 := aTail( ::dadosRet:aTotProg )

			oTemp4:TCCODPROG    := aTotPrograma[l][1]
			oTemp4:TCTOTCABPROG := iif(aTotPrograma[l][1] = 'M', transform(aTotPrograma[l][2],'@E 999.99'),transform(aTotPrograma[l][2],'@E 999'))
			oTemp4:TCDESCPROG   := iif(aTotPrograma[l][1] = 'M',"Pre็o Medio",GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6')+aTotPrograma[l][1],1))

		next l

		/*Animais Fora de Padrใo*/
		for i:=1 to len(aTotForaPadr)

			aadd(::dadosRet:aTotAFPad, WSClassNew("aTotaisForaPadrao"))
			oTemp5 := aTail( ::dadosRet:aTotAFPad )

			oTemp5:TCDESCRICAO	:= GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6')+aTotForaPadr[i][1],1)
			oTemp5:TCTOTCATEG 	:= transform(aTotForaPadr[i][2], '@E 999')

		next i

		/*Diagonostico de Doencas*/
		if len(aTotDoencas) > 0
			for j:=1 to len(aTotDoencas)

				aadd(::dadosRet:aTotDiagDoen, WSClassNew("ATotaisDiagDoenca"))
				oTemp6 := aTail( ::dadosRet:aTotDiagDoen )

				oTemp6:TCDESCRIDOENCA	:= aTotDoencas[j][2]
				oTemp6:TCTOTCABDOENCA 	:= transform(aTotDoencas[j][3],'@E 999')

			next j
		else
			aadd(::dadosRet:aTotDiagDoen, WSClassNew("ATotaisDiagDoenca"))
			oTemp6 := aTail( ::dadosRet:aTotDiagDoen )

			oTemp6:TCDESCRIDOENCA	:= ""
			oTemp6:TCTOTCABDOENCA 	:= ""
		endif
		
		/*Informa็๕es Pedido de Compra*/
		for k:=1 to len(aInfPedComp)

			aadd(::dadosRet:aItemPCompra, WSClassNew("aItensPedCompra"))
			oTemp7 := aTail( ::dadosRet:aItemPCompra )

			oTemp7:TCNUMPEDIDO   := aInfPedComp[k][1]
			oTemp7:TCQUANTPEDIDO := transform(aInfPedComp[k][2], '@E 9999')
			oTemp7:TCPESOPEDIDO  := transform(aInfPedComp[k][3], '@E 999999.99')
			oTemp7:TCPRECOPEDIDO := transform(aInfPedComp[k][4], '@E 99.99')
			oTemp7:TCSUBTOTPED	 := transform(aInfPedComp[k][5], '@E 999999.99')

		next k

		/*Informa็๕es Finais*/
		for l:=1 to len(_aInformFinais)

			aadd(::dadosRet:aInfFinal, WSClassNew("aInformacoesFinais"))
			oTemp8 := aTail( ::dadosRet:aInfFinal )

			oTemp8:TCPRECOMEDIOFINAL := _aInformFinais[l][1]
			oTemp8:TCTOTALFUNDESA	 := _aInformFinais[l][2]
			oTemp8:TCPREVISOCIAL	 := _aInformFinais[l][3]
			oTemp8:TCFUNRURAL		 := _aInformFinais[l][4]
			oTemp8:TCTOTALARECEBER   := _aInformFinais[l][5]

		next l

		//se nใo encontrar manda os valores zerados
	else

		::dadosRet:SUCESSO := 0

		/*Animais do Sequencial do lote*/
		aadd(::dadosRet:aItensAbate, WSClassNew("aAnimaisLote"))
		oTemp := aTail( ::dadosRet:aItensAbate )

		oTemp:TCSEQLOTE 	:= ""
		oTemp:TCSECABATE 	:= ""
		oTemp:TCPESCARCFRIA := ""
		oTemp:TCIDADEDENT 	:= ""
		oTemp:TCCLASSEGORD 	:= ""
		oTemp:TCCODCONTUS 	:= ""
		oTemp:TCCARCRASTR 	:= ""
		oTemp:TCDENTCARC 	:= ""
		oTemp:TCPRECO 		:= ""
		oTemp:TCRACA 		:= ""
		oTemp:TCPROGRAMA 	:= ""
		oTemp:TCTIPOCARC	:= ""

		/*Totais dos lotes*/
		aadd(::dadosRet:aTotaisAbate, WSClassNew("aTotaisLote"))
		oTemp2 := aTail( ::dadosRet:aTotaisAbate )

		oTemp2:TCPESOPROP 		 := ""
		oTemp2:TCPESOMEDORIG 	 := ""
		oTemp2:TCRENDIMORIG 	 := ""
		oTemp2:TCPESOLOTE 		 := ""
		oTemp2:TCPESMEDLOTE		 := ""
		oTemp2:TCRENDILOTE		 := ""
		oTemp2:TCPTOTCARCFRIA 	 := ""
		oTemp2:TCQUEBRATRANSP 	 := ""
		oTemp2:TCPMEDCARCFRIA	 := ""
		oTemp2:TCTOTPRENHEZ 	 := ""
		oTemp2:TCQUEBRAPESTRANSP := ""
		oTemp2:TCPRENHEZADIANT 	 := ""

		/*Totais quanto a Gordura*/
		aadd(::dadosRet:aTotGord, WSClassNew("aTotaisGordura"))
		oTemp3 := aTail( ::dadosRet:aTotGord )

		oTemp3:TCGORD 		 := ""
		oTemp3:TCDESCGORD 	 := ""
		oTemp3:TCTOTCABGORD  := ""

		/*Totais quanto a programa*/
		aadd(::dadosRet:aTotProg, WSClassNew("aTotaisPrograma"))
		oTemp4 := aTail( ::dadosRet:aTotProg )

		oTemp4:TCCODPROG    := ""
		oTemp4:TCTOTCABPROG := ""

		/*Animais Fora de Padrใo*/
		aadd(::dadosRet:aTotAFPad, WSClassNew("aTotaisForaPadrao"))
		oTemp5 := aTail( ::dadosRet:aTotAFPad )

		oTemp5:TCDESCRICAO	:= ""
		oTemp5:TCTOTCATEG 	:= ""

		/*Diagonostico de Doencas*/
		aadd(::dadosRet:aTotDiagDoen, WSClassNew("aTotaisDiagDoenca"))
		oTemp6 := aTail( ::dadosRet:aTotDiagDoen )

		oTemp6:TCDESCRIDOENCA	:= ""
		oTemp6:TCTOTCABDOENCA 	:= ""

		/*Informa็๕es Pedido de Compra*/
		aadd(::dadosRet:aItemPCompra, WSClassNew("aItensPedCompra"))
		oTemp7 := aTail( ::dadosRet:aItemPCompra )

		oTemp7:TCNUMPEDIDO   := ""
		oTemp7:TCQUANTPEDIDO := ""
		oTemp7:TCPESOPEDIDO  := ""
		oTemp7:TCPRECOPEDIDO := ""
		oTemp7:TCSUBTOTPED	 := ""

		/*Informa็๕es Finais*/

		aadd(::dadosRet:aInfFinal, WSClassNew("aInformacoesFinais"))
		oTemp8 := aTail( ::dadosRet:aInfFinal )

		oTemp8:TCPRECOMEDIOFINAL := ""
		oTemp8:TCTOTALFUNDESA	 := ""
		oTemp8:TCPREVISOCIAL	 := ""
		oTemp8:TCFUNRURAL		 := ""
		oTemp8:TCTOTALARECEBER   := ""

	endif

Return .t.

User Function listaResult(_cNumam,_cLote)

	Local nPesPren  := GETMV("SI_PNPREN")
	Local nPesPread := GETMV("SI_PNPREAD")

	nfem          := 0
	npfem         := 0
	nptot         := 0
	nras          := 0
	totPedesc     := 0
	_cNumPren     := 0
	_nTotLote     := 0
	_nPrenhes     := 0
	_nPrenAdi     := 0
	_cDescCat     := ''
	_nPrecoM      := 0.00
	_nTotVal      := 0.00
	_nPSocial     := 0.00
	_nTotNF       := 0.00
	_nTotFUNDESA  := 0.00
	_nFunrural	  := 0.00
	_cProg		  := ""

	_aRet 		:= {}
	_aLote		:= {}
	_aTotReport := {}

	_aTotais 	:= {}
	_aClasProg 	:= {}
	_aPedCom   	:= {}
	_aInfoFinal := {}

	SZ4->(DbSetOrder(1))
	SZG->(DbSetorder(1)) // data
	SZK->(DbSetorder(2)) // av matanca+lote
	SZE->(DbSetorder(2)) //
	SZD->(DbSetorder(1)) //
	SZ9->(DbSetOrder(1)) // numero+item
	SZR->(dbSetOrder(1)) // receb+categ
	SA2->(DbSetOrder(1))
	SA3->(DbSetOrder(1))
	SZA->(DbSetOrder(1))

	SZG->(MsSeek(FWxFilial('SZG')+_cNumam))
	SZE->(MsSeek(FWxFilial('SZE')+_cNumam+_cLote),.f.)
	SZ9->(MsSeek(FWxFilial('SZ9')+SZE->ZE_NUMSC+SZE->ZE_ITEMSC))
	SZD->(MsSeek(FWxFilial('SZD')+SZE->ZE_NUMERO))
	SZR->(MsSeek(FWxFilial('SZR')+SZE->ZE_NUMERO+SZE->ZE_CATEG))
	SZ4->(MsSeek(FWxfilial('SZ4')+_cNumam+_cLote))
	SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_cLote))
	SZA->(MsSeek(FWxfilial('SZA')+SZ9->Z9_NUMERO))
	SA2->(MsSeek(FWxfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA)))
	SA3->(MsSeek(FWxfilial('SA3')+SZA->ZA_COMPRA))

	_nTotLote := SZ4->Z4_QUANT
	_cDescCat := SZ4->Z4_DESCAT
	_nPrenhes := SZ4->Z4_NPREN
	_nPrenAdi := SZ4->Z4_NPREAD

	pesoprop := PesoProp(SZE->ZE_NUMERO,SZE->ZE_CATEG, If(Empty(SZE->ZE_RASTRO),'N','S'))
	pesoprop := pesoprop - iif(pesoprop > 0, (((SZ4->Z4_NPREN-SZ4->Z4_NPREAD)*nPesPren)+(SZ4->Z4_NPREAD*nPesPread)), 0)
	pesofrig := PesoFrig(SZE->ZE_NUMERO,SZE->ZE_CATEG, If(Empty(SZE->ZE_RASTRO),'N','S'))
	_nPercQ  := pesofrig/iif(pesoprop > 0.0, pesoprop, 1.0)
	_nPercQ  := iif(_nPercQ > 0 .and. _nPercQ < 1, _nPercQ, 1.0)
	pesofrig := pesofrig - iif(pesofrig > 0, (((SZ4->Z4_NPREN-SZ4->Z4_NPREAD)*(nPesPren*_nPercQ))+(SZ4->Z4_NPREAD*(nPesPread*_nPercQ))), 0)
	_natprod := GetAdvFVal('SA2','A2_TIPO',FWxfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA),1)

	_aTipGord  := {{'1',0,'aus'},{'2',0,'esc'},{'3',0,'med'},{'4',0,'uni'},{'5',0,'exc'}}  //Tipifica็๕es de gordura
	_aClasProg := {{'002',0,0,0},{'006',0,0,0},{'011',0,0,0},{'014',0,0,0}}            //Classificados em Programas
	_aAnimFPad := {{'005',0,0},{'008',0,0},{'019',0,0},{'001',0,0}}  //Animais fora do padrใo
	_aDiagDoen := {} //Diagnostico de doen็as
	_aImpDet   := {} //Impressใo dos detalhes do resultado
	_aPedCom   := {}

	area := getarea()

	DbSelectArea('ZA3')
	ZA3->(DbSetOrder(1))

	if ZA3->(MsSeek(FWxfilial('ZA3')+_cNumam+_cLote))

		while ZA3->(!eof()) .and. ZA3->ZA3_FILIAL = FWxfilial('ZA3') .and. ;
		ZA3->ZA3_NUMAM = _cNumam .and. ;
		ZA3->ZA3_LOTE  = _cLote

			if AllTrim(ZA3->ZA3_CODCON) $ '01/02/06/09/16/19/24/25/32/37/40/41/42/52/53'
				_nPos := aScan(_aDiagDoen,{|aVal|aVal[1] = ZA3->ZA3_CODCON})
				if _nPos = 0
					aadd(_aDiagDoen,{ZA3->ZA3_CODCON,ZA3->ZA3_DESCON,ZA3->ZA3_QUANT})
				else
					_aDiagDoen[_nPos][3] += ZA3->ZA3_QUANT
				endif
			endif

			ZA3->(DbSkip())
		EndDo

	endif

	restarea(area)

	if SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_cLote))
		While !SZK->(eof()) .and. FWxfilial('SZK')+_cNumam+_cLote == SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE)

			_cTpCom := GetAdvFVal("SZE", "ZE_TPCOM", FWxFilial("SZE") + SZK->ZK_NUMAM + SZK->ZK_LOTE, 2)
			npeso := 0
			_aLote := Det_Report(_cTpCom)  //Detalhamento do relatorio (colunas)

			//Bloco para apurar totais de tipifica็ใo de gordura
			_nPos := 0
			_nPos := aScan(_aTipGord,{|aVal|aVal[1] = substr(SZK->ZK_COBGOR,1,1)})
			if _nPos <> 0
				_aTipGord[_nPos][2]++
			endif

			if SZK->ZK_PROGPGP = "013"
				_cProg := ""
			else
				_cProg := SZK->ZK_PROGPGP
			endif

			//Bloco para apurar totais de animais classificados em programas (006 = Angus 011 = Brangus 002 = Hereford) Acrescentado o Programa Black no dia 30/10/18 por Fabian Maurer
			_nPos := 0
			_nPos := aScan(_aClasProg,{|aVal|aVal[1] = _cProg .and. _cProg $ '002/006/011/014'})
			if _nPos <> 0
				_aClasProg[_nPos][2]++
					//If _cTpCom == "Q"
						_aClasProg[_nPos][3] += SZK->ZK_PRECOBO * npeso
						_aClasProg[_nPos][4] += npeso
					//Else
						//_aClasProg[_nPos][3]+= SZK->ZK_PRECOBO * (npeso-(npeso*0.02))
						//_aClasProg[_nPos][4] += (npeso-(npeso*0.02))
					//Endif
			endif

			//Bloco para apurar totais de animais classificados como fora do padrใo (005 = Cruza Leite 008 = touruno 019 = Touro 001 = magro)
			_nPos := 0
			_nPos := aScan(_aAnimFPad,{|aVal|aVal[1] = SZK->ZK_PROGPGP .and. SZK->ZK_PROGPGP $ '005/008/019/001'})
			if _nPos <> 0
				_aAnimFPad[_nPos][2]++
				_aAnimFPad[_nPos][3]+= SZK->ZK_PRECOBO
			endif

			SZK->(DbSkip())
		Enddo

		aSort(_aTipGord ,,,{|X,Y| X[1]< Y[1]})

		_aTotReport := Tot_Report(_cTpCom)
		_aTotais 	:= _aTotReport[1]
		_aClasProg 	:= _aTotReport[2]
		_aPedCom   	:= _aTotReport[3]
		_aInfoFinal := _aTotReport[4]

	endif

	aadd(_aRet,_aLote)
	aAdd(_aRet,_aTotais)
	aAdd(_aRet,_aTipGord)
	aAdd(_aRet,_aClasProg)
	aAdd(_aRet,_aAnimFPad)
	aAdd(_aRet,_aDiagDoen)
	aAdd(_aRet,_aPedCom)
	aAdd(_aRet,_aInfoFinal)

return _aRet

//Totaliza็ใo do resultado
Static Function Tot_report(_cTpCom)

	//Local _cRet := ''
	local _aTotais := {}
	Local _aRetTotais := {}
	local _aInfoFinal := {}
	local i

	//Calculo dos rendimentos
	//peso origem
	If pesoprop > 0
		//If _cTpCom == "Q"
			_rendO := (nPtot/pesoprop) * 100   //Rendimento origem
		//Else
			//_rendO := ((nPtot-totPedesc)/pesoprop) * 100   //Rendimento origem
		//Endif
	Else
		_rendO := 0
	Endif
	//peso frigorifico
	If pesofrig > 0
		//If _cTpCom == "Q"
			_rendF := (nPtot/pesofrig) * 100  //Rendimento propriedade
		//Else
			//_rendF := (nPtot-totPedesc)/pesofrig * 100  //Rendimento propriedade
		//Endif
	Else
		_rendF := 0
	Endif

	//Calculo do percentual da quebra por tranporte
	_nQTransp1 := (1 - (pesofrig/pesoprop))*100
	_nQTransp1 := iif(_nQTransp1 > 0,_nQTransp1,0)
	//Calculo kg/Ca da quebra por transporte
	_nQTransp2 := iif(pesoprop <> 0, (pesoprop - pesofrig) / _nTotLote,0)
	_nQTransp2 := iif(_nQTransp2 > 0,_nQTransp2,0)
	//busca N๚meros de prenhez

	if(pesofrig <=0 .or. pesoprop <=0)
		_nQTransp1 := 0
		_nQTransp2 := 0
	endif

	//totais do lote
	_cTCPESOPROP 			:= transform(pesoprop,'@E 999999.99')
	_cTCPESOMEDORIG   		:= transform(pesoprop/_nTotLote,'@E 999999.99')
	_cTCRENDIMORIG 			:= transform(_rendO,'@E 999999.99') //porcentagem

	_cTCPESOLOTE 			:= transform(pesofrig,'@E 999999.99')
	_cTCPESMEDLOTE 			:= transform(pesofrig/_nTotLote,'@E 999999.99')
	_cTCRENDILOTE 			:= transform(_rendF,'@E 999,999.99') //porcentagem

	//If _cTpCom == "Q"
		_cTCPTOTCARCFRIA 	:= transform(( nPtot ),'@E 999999.99')
	//Else
		//_cTCPTOTCARCFRIA 	:= transform(( nPtot - totPedesc ),'@E 999999.99')
	//Endif
	//_cTCQUEBRATRANSP 		:= transform(_nQTransp1,'@E 999999.99')//porcentagem
	_cTCPORCQTRANSP 		:= transform(_nQTransp1,'@E 999999.99')//porcentagem

	//If _cTpCom == "Q"
		_cTCPMEDCARCFRIA 	:= transform(( nPtot )/_nTotLote,"@E 999999.99")
	//Else
		//_cTCPMEDCARCFRIA 	:= transform(( nPtot - totPedesc )/_nTotLote,"@E 999999.99")
	//Endif
	_cTCTOTPRENHEZ 			:= transform(_nPrenhes,'@E 999,999') //cabe็as
	_cTCQUEBRAPESTRANSP		:= transform(_nQTransp2,'@E 999999.99') //kg/cab
	_cTCPRENHEZADIANT 		:= transform(_nPrenAdi,'@E 999999')//prenhez adiantada cabe็as

	aAdd(_aTotais,{_cTCPESOPROP,_cTCPESOMEDORIG,_cTCRENDIMORIG,_cTCPESOLOTE,_cTCPESMEDLOTE,_cTCRENDILOTE,_cTCPTOTCARCFRIA,_cTCPORCQTRANSP,;
	_cTCPMEDCARCFRIA,_cTCTOTPRENHEZ,_cTCQUEBRAPESTRANSP,_cTCPRENHEZADIANT})

	aSort(_aTipGord ,,,{|X,Y| X[1]< Y[1]})

	//Calculo do pre็o m้dio dos animais classificados em programas
	_nPrcProgM   := 0
	_nPrecoProg  := 0
	_nQuantProg  := 0

	for i := 1 to len(_aClasProg)
		if _aClasProg[i][3] <> 0
			_nQuantProg  += _aClasProg[i][4]
			_nPrecoProg  += _aClasProg[i][3]
		endif
	next

	_nPrcProgM := _nPrecoProg / _nQuantProg

	AADD(_aClasProg,{'M',_nPrcProgM,0})

	//Para listar os pedidos de compra
	_aPedCom := ListaPC()

	aSort(_aPedCom ,,,{|X,Y| X[4] > Y[4]})

	_nTotVal := 0

	for i := 1 to len(_aPedCom)
		_nTotVal +=  _aPedCom[i][5]
	next

	//IF _cTpCom == "Q"
		_nPrecoM := round(_nTotVal/( nPtot ),2)
	//Else
		//_nPrecoM := round(_nTotVal/( nPtot - totPedesc ),2)
	//Endif
	//Para listar as informa็๕es finais
	_cEMPREG := GetAdvFVal('SA2','A2_POSEMP',FWxfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA),1)
	if _cEMPREG <> '2'
		_cTotReceber := transform(iif(_natprod <> 'J',_nTotNF-(_nTotFUNDESA+_nPSocial),_nTotNF-_nTotFUNDESA),'@E 9999999999.99')
	else
		_cTotReceber  := transform(iif(_natprod <> 'J',_nTotNF-(_nTotFUNDESA+_nPSocial+_nFunrural),_nTotNF-_nTotFUNDESA),'@E 9999999999.99')
	endif

	aadd(_aInfoFinal, {transform(round(_nPrecoM,2),'@E 99.99'),transform(_nTotFUNDESA,'@E 9999.99'),transform(_nPSocial,'@E 9999.99'),;
	transform(_nFunrural,'@E 9999.99'),_cTotReceber})

	aAdd(_aRetTotais,_aTotais)
	aAdd(_aRetTotais,_aClasProg)
	aAdd(_aRetTotais,_aPedCom)
	aAdd(_aRetTotais,_aInfoFinal)

Return _aRetTotais

Static Function ListaPC()

	_cNumam     := SZE->ZE_NUMAM
	_cLote      := SZE->ZE_LOTE
	_aPedCom    := {}

	/*SC7->(DbOrderNickName("C7NUMAMLOT"))
	if SC7->(MsSeek(FWxFilial('SC7')+SZE->ZE_NUMAM+SZE->ZE_LOTE))

		_nTotFUNDESA := 0
		_nTotNF      := 0
		_nPSocial    := 0
		_nFunrural	 := 0

		DO WHILE !SC7->(EOF()) .AND. FWxFilial('SC7')+SZE->ZE_NUMAM+SZE->ZE_LOTE==SC7->(C7_FILIAL+C7_NUMAM+C7_LOTE)
			if SC7->C7_PCNOTA = 'NFP'
				SC7->(DbSkip())
				Loop
			endif

			_nFUNDESA := SC7->C7_QTSEGUM * GetAdvFVal('SB1','B1_FESA',FWxfilial('SB1')+SC7->C7_PRODUTO,1)

			_nTotFUNDESA += _nFUNDESA
			_nTotNF      += SC7->C7_TOTAL

			AADD(_aPedCom,{SC7->C7_NUM,SC7->C7_QTSEGUM,SC7->C7_QUANT,SC7->C7_PRECO,SC7->C7_TOTAL})

			SC7->(DbSkip())
		ENDDO

		_nPSocial := (val(substr(getmv("MV_CONTSOC"),5,3)))/100 * _nTotNF

		// Inicio Bloco Alterado por Fabian Maurer para inserir
		//o valor do FUNRURAL quando fornecedor nao tiver empregado
		_cEMPREG := GetAdvFVal('SA2','A2_POSEMP',FWxfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA),1)

		if _cEMPREG = '2'
			//_nFunrural := 2.1/100 * _nTotNF Ajuste de Porcentagem pedido Diogo dia 30/01/2018
			_nFunrural := 1.3/100 * _nTotNF

		endif

	endif*/

	ZAG->(DbSetOrder(3))
	If ZAG->(MsSeek(FWxFilial("ZAG") + SZE->ZE_NUMAM + SZE->ZE_LOTE))
		_nTotFUNDESA := 0
		_nTotNF      := 0
		_nPSocial    := 0
		_nFunrural	 := 0

		While !ZAG->(Eof()) .And. ZAG->ZAG_FILIAL + ZAG->ZAG_NUMAM + ZAG->ZAG_LOTE == FWxFilial("ZAG") + SZE->ZE_NUMAM + SZE->ZE_LOTE

			_nFUNDESA := ZAG->ZAG_QUANT * GetAdvFVal('SB1','B1_FESA',FWxFilial('SB1')+ZAG->ZAG_PRODUT,1)

			_nTotFUNDESA += _nFUNDESA
			_nTotNF      += ZAG->ZAG_PESO * ZAG->ZAG_PRECO

			AADD(_aPedCom,{"      ", ZAG->ZAG_QUANT, ZAG->ZAG_PESO, ZAG->ZAG_PRECO, ZAG->ZAG_PESO * ZAG->ZAG_PRECO})

			ZAG->(DbSkip())
		EndDo

		_nPSocial := (Val(Substr(GetMv("MV_CONTSOC"),5,3)))/100 * _nTotNF

		// Inicio Bloco Alterado por Fabian Maurer para inserir
		//o valor do FUNRURAL quando fornecedor nao tiver empregado
		_cEMPREG := GetAdvFVal('SA2','A2_POSEMP',FWxfilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA),1)

		If _cEMPREG = '2'
			//_nFunrural := 2.1/100 * _nTotNF --- Ajuste solicitado pelo Diogo e Fabiane dia 15/01/18
			_nFunrural := 1.3/100 * _nTotNF
		Endif
	Endif

return _aPedCom

Static Function Det_report(_cTpCom)

	npeso  := SZK->ZK_PETOTAL

	_dDtPraTras := ctod('30/06/16')

	if SZK->ZK_IF = 'S'
		if SZG->ZG_DATA < _dDtPraTras //se a data do abate for menor que 30/06/16 mantem o calculo antigo

			if npeso > 200
				npeso -= 10
			elseif npeso <=200
				npeso -= 7.5
			endif

		else
			/*
			if npeso > 200
				npeso -= 20 //era 10 mudan็a solicitada por Gabriel 29/06/16 20
			elseif npeso <=200
				npeso -= 15 //era 7.5 mudan็a solicitada por Gabriel 29/06/16   15
			endif
			*/
			if npeso > 200
				//_ps -= 20
				npeso := npeso * 0.92
			elseif npeso <=200
				//_ps -= 15
				npeso := npeso * 0.92
			endif
			endif
	endif

	/*if SZK->ZK_IF = 'S'
	if npeso > 200
	npeso -= 10
	elseif npeso <=200
	npeso -= 7.5
	endif
	endif*/

	//If _cTpCom == "Q"
		totPedesc  += npeso
	//Else
		//totPedesc  += npeso * 0.02
	//Endif

	Do Case
		Case SZK->ZK_DESTINO = 'R'
		_cDestino :='CO'
		Case SZK->ZK_DESTINO = 'T'
		_cDestino := 'TF'
		Case SZK->ZK_DESTINO = 'G'
		_cDestino := 'GR'
		Case SZK->ZK_DESTINO = 'C' .and. SZK->ZK_IF <> 'S'
		_cDestino := 'CA'
		Case SZK->ZK_IF = 'S'
		_cDestino := 'IF'
	EndCase

	_cPrecoBo := transform(SZK->ZK_PRECOBO, '@E 999.99')
	// Coluna Ra็a

	_cRaca := ''
	_cRaca := GetAdvFVal('ZA8', 'ZA8_DESC', FWxFilial('ZA8')+SZK->ZK_RACA, 1)

	// Coluna Programa
	_cPrograma := ''
	if !(SZK->ZK_PROGPGP $ '013/020')
		_cPrograma := GetAdvFVal('SZ6','Z6_DESC',FWxFilial('SZ6')+SZK->ZK_PROGPGP,1)		
	//else
		//_cPrograma := ''
	endif

	//SZK->ZK_SEXO,;
	AADD(_aImpDet,{strzero(SZK->ZK_ORDEM,3),;
	SZK->ZK_CONTROL,;
	Transform( npeso,'@E 9,999.99'),;//IIF(_cTpCom == "Q",Transform( npeso,'@E 9,999.99') ,Transform( npeso-(npeso*0.02),'@E 9,999.99')),;
	SZK->ZK_DENT,;
	substr(SZK->ZK_COBGOR,1,1),;
	SZK->ZK_CONTUS,;
	iif(empty(SZK->ZK_RASTRO),'N','S'),;
	_cDestino,;
	_cPrecoBo,;
	_cRaca,;
	_cPrograma,;
	_cTpCom})

	// AQUI INFORMAR CARCAวA QUENTE OU FRIA

	if SZK->ZK_SEXO == 'F'
		nFem++
		nPfem += npeso
	endif

	npTot += npeso

	if !empty(SZK->ZK_RASTRO) .AND. SZ9->Z9_RASTRO == 'S'
		nRas++
	endif

Return _aImpDet

// Peso propriedade da categoria+rastro no receb, modificado para "peso lote origem"
Static Function PesoProp( receb, categ, rastreado  )
	Private nPeso1 := 0
	SZR->( dbSetOrder(1) )
	SZR->( MsSeek(FWxFilial('SZR')+receb+categ ) )
	While !SZR->(Eof()) .and. receb+categ == SZR->( ZR_RECEB+ZR_CATEG )
		if SZR->ZR_RASTRO <> rastreado
			SZR->(DbSkip())
			loop
		endif
		nPeso1 += SZR->ZR_PESO
		SZR->( dbSkip() )
	Enddo
Return nPeso1

// Peso frigorifico da categoria+rastro no receb, modificado para "peso lote frigorifico"
Static Function PesoFrig( receb, categ, rastreado )
	Private nPeso1 := 0
	SZR->( dbSetOrder(1) )
	SZR->( MsSeek(FWxFilial('SZR')+receb+categ ) )
	While !SZR->(Eof()) .and. receb+categ == SZR->( ZR_RECEB+ZR_CATEG)
		if SZR->ZR_RASTRO <> rastreado
			SZR->(DbSkip())
			loop
		endif

		nPeso1 += SZR->ZR_PESOFRI
		SZR->( dbSkip() )
	Enddo
Return nPeso1
