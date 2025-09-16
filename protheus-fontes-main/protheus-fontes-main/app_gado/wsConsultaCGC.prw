#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWS_LOGON  บAutor  ณMauricio Roehrs    บ Data ณ  21/11/18    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Web Service Server para valida็ใo de Logon no APP do Gado บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//Nessa estrutura vem o dado de entrada
WSSTRUCT dadoCgcEntr
	WSDATA tcCPFCNPJ AS STRING
	WSDATA tcTipo    AS INTEGER
ENDWSSTRUCT

//Cria estrutura com os dados que sใo exibidos no xml do webservice
//Isso ้ o que retornarแ para quem fizer a requisi็ใo
WSSTRUCT dadoCgcSaida

	WSDATA sucesso 		AS INTEGER
	WSDATA tcCodInterno AS STRING
	WSDATA tcNome 		AS STRING
	WSDATA tcEmail	 	AS STRING

ENDWSSTRUCT


//Cria a tag de Webservice
WSSERVICE wsConsultaCGC Description "Servico contendo o metodo para valida็ใo do logon do produtor"

	/*dados para teste
	39530973004
	bruna*/

	//Proriedades
	WSDATA dadosEnt AS dadoCgcEntr 	  //chama a estrutura dos dados de entrada
	WSDATA dadosRet AS dadoCgcSaida     //chama a estrutura dos dados de retorno do pedido

	//Declara os metodos
	WSMETHOD dadosCGC Description "<b> Metodo de rotorno da consuta por CPF/CNPJ</b><br> <u>Retorno</u><br> Codigo, Nome e E-mails

ENDWSSERVICE//fecha o servico

WSMETHOD dadosCGC WSRECEIVE dadosEnt WSSEND dadosRet WSSERVICE wsConsultaCGC
	local aPV    := {}
	local aCab   := {}
	//local aEmil  := {}

	RPCSetType(3) //nใo consome licen็a.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'SA2','SA3'

	aPv := u_pesqCGC(::dadosEnt:tcCPFCNPJ, ::dadosEnt:tcTipo)

	if len(aPv[1]) > 0

		aCab   := aPv[1]

		::dadosRet:sucesso 		:= aCab[1]
		::dadosRet:tcCodInterno := aCab[2]
		::dadosRet:tcNome 		:= aCab[3]
		::dadosRet:tcEmail      := aCab[4]
		
	else

		::dadosRet:sucesso 		:= 0
		::dadosRet:tcCodInterno := ""
		::dadosRet:tcNome 		:= ""
		::dadosRet:tcEmail      := ""


	endif

Return .t.

//Fun็ใo que pesquisa os pedidos de venda
User Function pesqCGC(_cpfcnpj, _nTipo)

	Local aRet    := {}
	Local aCab    := {}

	dbSelectArea('SA2')
	SA2->(dbSetOrder(15))

	dbSelectArea('SA3')
	SA3->(dbSetOrder(3))

	if SA2->(dbSeek(FWxFilial('SA2') + padr(alltrim(_cpfcnpj),14,'') + '2'))  .and. _nTipo = 1

		aadd(aCab,1)
		aadd(aCab,alltrim(SA2->A2_COD))
		aadd(aCab,alltrim(SA2->A2_NOME))
		aadd(aCab,"")

		_cQuery := " SELECT  A2_EMAIL
		_cQuery += " FROM " + retSqlTab('SA2')
		_cQuery += " WHERE " + retSqlFil('SA2')
		_cQuery += " AND A2_COD = '" + SA2->A2_COD + "'"
		_cQuery += " AND A2_MSBLQL = '2'"
		_cQuery += " AND "+retSqlDel('SA2')
		_cQuery += " ORDER BY A2_LOJA"

		_cQuery  := ChangeQuery(_cQuery)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		if Select("TMP") != 0
			TMP->(dbCloseArea())
		endif

		TCQUERY _cQuery NEW ALIAS "TMP"

		TMP->(dbGoTop())
		while TMP->(!eof())

			if !empty(TMP->A2_EMAIL)
				aCab[4] += alltrim(TMP->A2_EMAIL)
			endif
			TMP->(dbSkip())
		enddo

	elseif  SA3->(dbSeek(FWxFilial('SA3') + padr(alltrim(_cpfcnpj),14,''))) .and. _nTipo = 2

		aadd(aCab,1)
		aadd(aCab,alltrim(SA3->A3_COD))
		aadd(aCab,alltrim(SA3->A3_NOME))
		aadd(aCab,"")

		_cQuery := " SELECT A3_EMAIL
		_cQuery += " FROM " + retSqlTab('SA3')
		_cQuery += " WHERE " + retSqlFil('SA3')
		_cQuery += " AND A3_COD = '" + SA3->A3_COD + "'"
		_cQuery += " AND A3_MSBLQL <> '1'"
		_cQuery += " AND "+retSqlDel('SA3')
		//_cQuery += " ORDER BY A2_LOJA"

		_cQuery  := ChangeQuery(_cQuery)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		if Select("TMP") != 0
			TMP->(dbCloseArea())
		endif

		TCQUERY _cQuery NEW ALIAS "TMP"

		TMP->(dbGoTop())
		while TMP->(!eof())

			if !empty(TMP->A3_EMAIL)
				aCab[4] += alltrim(TMP->A3_EMAIL)
			endif

			TMP->(dbSkip())
		enddo
	endif

	aadd(aRet,aCab)

return aRet

