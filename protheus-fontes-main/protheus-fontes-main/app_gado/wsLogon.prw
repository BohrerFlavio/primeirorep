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
WSSTRUCT lgEntrada
	WSDATA tcCPFCNPJ AS STRING
	WSDATA tcSenha 	 AS STRING
	WSDATA tcTipo    AS INTEGER
ENDWSSTRUCT

//Cria estrutura com os dados que sใo exibidos no xml do webservice
//Isso ้ o que retornarแ para quem fizer a requisi็ใo
WSSTRUCT lgResposta

	WSDATA sucesso 		AS INTEGER
	WSDATA codigo 		AS STRING
	WSDATA tipo 		AS INTEGER
	WSDATA cpf_cnpj 	AS STRING
	WSDATA ativo		AS STRING
	WSDATA percDesconto AS FLOAT //CRIAR PARAMETRO COM PERCENTUAL

	WSDATA aProdutor AS Array of aLojas//Array tipo complexo que montara todas lojas do usuario logado

ENDWSSTRUCT

//Array com os itens do pedido de venda
WSSTRUCT aLojas

	WSDATA loja 		AS STRING
	WSDATA inscEstad 	AS STRING
	WSDATA inscMunic    AS STRING
	WSDATA pessoa_tipo	AS STRING
	WSDATA nome 		AS STRING
	WSDATA nreduz		AS STRING
	WSDATA contato		AS STRING
	WSDATA email		AS STRING
	WSDATA endereco		AS STRING
	WSDATA numero		AS STRING
	WSDATA bairro		AS STRING
	WSDATA estado		AS STRING
	WSDATA municipio   	AS STRING
	WSDATA cep 			AS STRING
	WSDATA telefone1    AS STRING
	WSDATA telefone2	AS STRING
	WSDATA codBanco1	AS STRING
	WSDATA nomeBanco1	AS STRING
	WSDATA agencia1		AS STRING
	WSDATA conta1 	    AS STRING
	WSDATA codBanco2	AS STRING
	WSDATA nomeBanco2	AS STRING
	WSDATA agencia2		AS STRING
	WSDATA conta2 	    AS STRING

ENDWSSTRUCT


//Cria a tag de Webservice
WSSERVICE wsLogon Description "Servico contendo o metodo para valida็ใo do logon do produtor"

	/*dados para teste
	39530973004
	bruna*/

	//Proriedades
	WSDATA dadosEnt AS lgEntrada 	  //chama a estrutura dos dados de entrada
	WSDATA dadosRet AS lgResposta     //chama a estrutura dos dados de retorno do pedido

	//Declara os metodos
	WSMETHOD dadosLg Description "<b> Metodo de rotorno do logon</b><br> <u>Retorno</u><br> Nome do usuario e Tipo(Produtor ou Comprador)

ENDWSSERVICE//fecha o servico

WSMETHOD dadosLG WSRECEIVE dadosEnt WSSEND dadosRet WSSERVICE wsLogon
	local aPV    := {}
	local aCab   := {}
	local aItem  := {}
	local aItem2 := {}
	local i

	RPCSetType(3) //nใo consome licen็a.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'SA2','SA3'

	aPv := u_pesqUsr(::dadosEnt:tcCPFCNPJ,::dadosEnt:tcSenha, ::dadosEnt:tcTipo)

	if len(aPv[1]) > 0 .and. len(aPv[2]) > 0

		aCab   := aPv[1]
		aItem  := aPv[2]
		
		aItem2 := aPv[3] 
		
		::dadosRet:sucesso 		:= aCab[1]
		::dadosRet:codigo 		:= aCab[2]
		::dadosRet:tipo 		:= aCab[3]
		::dadosRet:cpf_cnpj 	:= aCab[4]
		::dadosRet:ativo		:= aCab[5]
		::dadosRet:percDesconto := getMv('SI_%DGADO')//percentual de desconto na compra a vista

		for i := 1 to len(aItem)

			aadd(::dadosRet:aProdutor, WSClassNew("aLojas"))
			oTemp := aTail( ::dadosRet:aProdutor )
			//oTemp :=  ::dadosRet:aProdutor 

			oTemp:loja 			:= aItem[i][1]
			oTemp:inscEstad 	:= aItem[i][2]
			oTemp:inscMunic 	:= aItem[i][3]
			oTemp:pessoa_tipo 	:= aItem[i][4]
			oTemp:nome 			:= aItem[i][5]
			oTemp:nreduz 		:= aItem[i][6]
			oTemp:contato 		:= aItem[i][7]
			oTemp:email 		:= aItem[i][8]
			oTemp:endereco 		:= aItem[i][9]
			oTemp:numero 		:= aItem[i][10]
			oTemp:bairro 		:= aItem[i][11]
			oTemp:estado 		:= aItem[i][12]
			oTemp:municipio 	:= aItem[i][13]
			oTemp:cep 			:= aItem[i][14]
			oTemp:telefone1 	:= aItem[i][15]
			oTemp:telefone2 	:= aItem[i][16]
			oTemp:codBanco1	    := aItem[i][17]
			oTemp:nomeBanco1	:= aItem[i][18]
			oTemp:agencia1		:= aItem[i][19]
			oTemp:conta1 	    := aItem[i][20]
			oTemp:codBanco2		:= aItem[i][21]
			oTemp:nomeBanco2	:= aItem[i][22]
			oTemp:agencia2		:= aItem[i][23]
			oTemp:conta2 	    := aItem[i][24]

		next i

	else

		::dadosRet:sucesso 		:= 0
		::dadosRet:codigo 		:= ""
		::dadosRet:tipo 		:= 0
		::dadosRet:cpf_cnpj 	:= ""
		::dadosRet:percDesconto := 0
		::dadosRet:ativo		:= ""

		aadd(::dadosRet:aProdutor, WSClassNew("aLojas"))
		oTemp := aTail( ::dadosRet:aProdutor )

		oTemp:loja 			:= ""
		oTemp:inscEstad 	:= ""
		oTemp:inscMunic 	:= ""
		oTemp:pessoa_tipo 	:= ""
		oTemp:nome 			:= ""
		oTemp:nreduz 		:= ""
		oTemp:contato 		:= ""
		oTemp:email 		:= ""
		oTemp:endereco 		:= ""
		oTemp:numero 		:= ""
		oTemp:bairro 		:= ""
		oTemp:estado 		:= ""
		oTemp:municipio 	:= ""
		oTemp:cep 			:= ""
		oTemp:telefone1 	:= ""
		oTemp:telefone2 	:= ""
		oTemp:codBanco1	    := ""
		oTemp:nomeBanco1	:= ""
		oTemp:agencia1		:= ""
		oTemp:conta1 	    := ""
		oTemp:codBanco2		:= ""
		oTemp:nomeBanco2	:= ""
		oTemp:agencia2		:= ""
		oTemp:conta2 	    := ""

	endif

Return .t.

//Fun็ใo que pesquisa os pedidos de venda
User Function pesqUsr(_cpfcnpj,_cSenha, _nTipo)

	Local aRet   := {}
	Local aCab   := {}
	Local aItem  := {}
	local aItem2 := {}

	dbSelectArea('SA2')
	SA2->(dbSetOrder(15))

	dbSelectArea('SA3')
	SA3->(dbSetOrder(3))

	//if SA2->(dbSeek(FWxFilial('SA2') + padr(alltrim(_cpfcnpj),14,'') + '2')) .and. _cSenha == alltrim(SA2->A2_SENHAP) .and. SA2->A2_MSBLQL = '2' .and. _nTipo = 1
	if SA2->(dbSeek(FWxFilial('SA2') + padr(alltrim(_cpfcnpj),14,'') + '2')) .and. _cSenha == alltrim(SA2->A2_SENHAP) .and.  _nTipo = 1

		//if _cSenha == alltrim(SA2->A2_SENHAP) .and. SA2->A2_STATUSP = 'L'

			aadd(aCab,1)
			aadd(aCab,alltrim(SA2->A2_COD))
			aadd(aCab,1)//PRODUTOR
			aadd(aCab,alltrim(SA2->A2_CGC))
			aadd(aCab,SA2->A2_MSBLQL)
			
			_cQuery := " SELECT A2_LOJA, A2_INSCR, A2_INSCRM, A2_TIPO, A2_NOME, A2_NREDUZ, A2_CONTATO, A2_EMAIL, A2_END, A2_NR_END, "
			_cQuery += " A2_BAIRRO, A2_EST, A2_MUN, A2_CEP, A2_TEL, A2_CELULAR,A2_BANCO, A2_AGENCIA, A2_NUMCON, A2_BCO2, A2_AGEN2, A2_CTA2"
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

				_cNomeBco1 := fBuscaCpo('SA6',1,FWxFilial('SA6') + TMP->A2_BANCO,'A6_NOME')
				_cNomeBco2 := fBuscaCpo('SA6',1,FWxFilial('SA6') + TMP->A2_BCO2,'A6_NOME')

				aadd(aItem,{TMP->A2_LOJA, TMP->A2_INSCR, TMP->A2_INSCRM, TMP->A2_TIPO, TMP->A2_NOME, TMP->A2_NREDUZ, TMP->A2_CONTATO,;
							TMP->A2_EMAIL, TMP->A2_END, TMP->A2_NR_END, TMP->A2_BAIRRO, TMP->A2_EST, TMP->A2_MUN, TMP->A2_CEP,;
							TMP->A2_CELULAR, TMP->A2_TEL,TMP->A2_BANCO,_cNomeBco1,TMP->A2_AGENCIA,TMP->A2_NUMCON,;
							TMP->A2_BCO2 ,_cNomeBco2,TMP->A2_AGEN2  ,TMP->A2_CTA2})

				TMP->(dbSkip())
			enddo

	//elseif  SA3->(dbSeek(FWxFilial('SA3') + padr(alltrim(_cpfcnpj),14,''))) .and. _cSenha == alltrim(SA3->A3_SENHAP) .and. SA3->A3_STATUSP = 'L' .and. _nTipo = 2
		elseif  SA3->(dbSeek(FWxFilial('SA3') + padr(alltrim(_cpfcnpj),14,''))) .and. _cSenha == alltrim(SA3->A3_SENHAP) .and. _nTipo = 2		
			
			aadd(aCab,1)
			aadd(aCab,alltrim(SA3->A3_COD))
			aadd(aCab,2)//comprador
			aadd(aCab,alltrim(SA3->A3_CGC))
			aadd(aCab,SA3->A3_MSBLQL)
			
			_cQuery := " SELECT A3_INSCR, A3_INSCRM,  A3_NOME, A3_NREDUZ, A3_EMAIL, A3_END,"
			_cQuery += " A3_BAIRRO, A3_EST, A3_MUN, A3_CEP, A3_TEL, A3_CELULAR, A3_BCO1"
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
			
				_cAgencia  := fBuscaCpo('SA6',1,FWxFilial('SA6') + TMP->A3_BCO1,'A6_AGENCIA')
				_cNomeBco1 := fBuscaCpo('SA6',1,FWxFilial('SA6') + TMP->A3_BCO1,'A6_NOME')
				_cNumCon   := fBuscaCpo('SA6',1,FWxFilial('SA6') + TMP->A3_BCO1,'A6_NUMCON')
		

				aadd(aItem,{'-', TMP->A3_INSCR, TMP->A3_INSCRM, '-', TMP->A3_NOME, TMP->A3_NREDUZ, '-',;
							TMP->A3_EMAIL, TMP->A3_END, '-', TMP->A3_BAIRRO, TMP->A3_EST, TMP->A3_MUN, TMP->A3_CEP,;
							TMP->A3_CELULAR, TMP->A3_TEL,TMP->A3_BCO1,_cNomeBco1,_cAgencia,_cNumCon,;
							'-' ,'-','-' ,'-'})


				TMP->(dbSkip())			
			enddo
	endif

	aadd(aRet,aCab)
	aadd(aRet,aItem)
	
	aadd(aRet,aItem2)

return aRet

