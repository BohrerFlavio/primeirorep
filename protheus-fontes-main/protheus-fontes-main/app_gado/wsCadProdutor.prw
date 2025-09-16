#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"   
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWS_TESTE_INC บAutor  ณMauricio Roehrs  บ Data ณ  03/08/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Web Service Server para teste de integra็ใo e inclusใo no บฑฑ
ฑฑบ          ณ  banco de dados                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


//Nessa estrutura vem o dado de entrada
WSSTRUCT dadoEntrProd

	WSDATA senha 			AS STRING
	WSDATA cpf_cnpj 		AS STRING
	WSDATA loja 			AS STRING
	WSDATA inscEstad 		AS STRING
	WSDATA inscMunic    	AS STRING
	WSDATA pessoa_tipo		AS STRING
	WSDATA nome 			AS STRING
	WSDATA nreduz			AS STRING
	WSDATA contato			AS STRING
	WSDATA email			AS STRING
	WSDATA endereco			AS STRING
	WSDATA numero			AS STRING
	WSDATA bairro			AS STRING
	WSDATA estado			AS STRING
	WSDATA municipio   		AS STRING
	WSDATA cep 				AS STRING
	WSDATA telefone1    	AS STRING
	WSDATA telefone2		AS STRING
	WSDATA codBanco1		AS STRING
	WSDATA nomeBanco1		AS STRING
	WSDATA agencia1			AS STRING
	WSDATA conta1 	    	AS STRING
	WSDATA codBanco2		AS STRING
	WSDATA nomeBanco2		AS STRING
	WSDATA agencia2			AS STRING
	WSDATA conta2 	    	AS STRING
	//WSDATA tcInscMunicipal 	AS STRING

ENDWSSTRUCT


//Cria estrutura com os dados que sใo exibidos no xml do webservice 
//Isso ้ o que retornarแ para quem fizer a requisi็ใo                    
WSSTRUCT dadoRetProd

	WSDATA sucesso 		 AS INTEGER  
	WSDATA codInterno  	 AS STRING    
	WSDATA loja  		 AS STRING
	WSDATA nomeReduzido  AS STRING
	WSDATA ativo  		 AS STRING
	    
ENDWSSTRUCT   


//Cria a tag de Webservice
WSSERVICE wsCadProdutor Description "Servico de inclusao de produtor de gado"
	//Proriedades
	WSDATA dadosEnt AS dadoEntrProd //chama a estrutura dos dados de entrada
	WSDATA dadosRet AS dadoRetProd  //chama a estrutura dos dados de retorno        

	//Declara os metodos
	WSMETHOD setDadoTabela Description "<b> Metodo de inclusใo de um novo produtor ou uma nova loja do mesmo</b><br> <u>Retorno</u><br>

ENDWSSERVICE//fecha o servico

WSMETHOD setDadoTabela WSRECEIVE dadosEnt WSSEND dadosRet WSSERVICE wsCadProdutor 

	local _lValidInscr := .t.
	local _nLoja := 1
	local _cLoja := ''
	
	RPCSetType(3) //nใo consome licen็a.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'SA2'
	
	SA2->(dbSetOrder(3))
	SA2->(dbGoTop())

	//Conout("====== I N I C I O =======================================")

	//Conout("Antes CPF / CNPJ: " + padr(alltrim(dadosEnt:cpf_cnpj),14,''))

	if SA2->(dbSeek(FWxFilial('SA2') +  padr(alltrim(dadosEnt:cpf_cnpj),14,''))) //se achar o CNPJ valida as inscri็๕es estaduais
	
		_cCodForn := SA2->A2_COD

		//Conout("Depois CPF / CNPJ: " + padr(alltrim(dadosEnt:cpf_cnpj),14,''))

		while SA2->(!eof())  .and. SA2->A2_FILIAL + SA2->A2_CGC == FWxFilial('SA2') + padr(alltrim(dadosEnt:cpf_cnpj),14,'')

			//Conout("Comparacao 1: " + SA2->A2_FILIAL + SA2->A2_CGC)
			//Conout("Comparacao 2: " + FWxFilial('SA2') + padr(alltrim(dadosEnt:cpf_cnpj),14,''))
			//Conout("CGC Fornecedor: " + SA2->A2_CGC)			
			//Conout("INSCRICAO: " + padr(alltrim(dadosEnt:inscEstad),18,''))
			//Conout("INCRICAO Fornecedor: " + SA2->A2_INSCR)
			
			if padr(alltrim(dadosEnt:inscEstad),18,'') == SA2->A2_INSCR //se achar a inscri็ใo estadual, marca flag como false para nใo gravar nada
				_lValidInscr 		  	:= .f.	
				::dadosRet:sucesso 	  	:= 1
				::dadosRet:codInterno 	:= _cCodForn
				::dadosRet:loja 	  	:= SA2->A2_LOJA
				::dadosRet:nomeReduzido := SA2->A2_NREDUZ
				::dadosRet:ativo 		:= SA2->A2_MSBLQL
			endif
			
			_nLoja++
			_cLoja := SA2->A2_LOJA
			SA2->(dbSkip())
		enddo
		
		//Conout("Flag: " + _lValidInscr)

		if _lValidInscr //se nใo encontrou inscri็ใo cadastra uma nova loja
		
			_nLoja := val(_cLoja) + 1
			reclock('SA2',.t.)
			SA2->A2_COD 	:= _cCodForn
			SA2->A2_LOJA 	:= strzero(_nLoja,2)
			SA2->A2_NOME	:= upper(::dadosEnt:nome) //(RAZAO)
			SA2->A2_NREDUZ 	:= upper(::dadosEnt:nreduz) //(NOME FANTASIA)
			SA2->A2_END 	:= upper(::dadosEnt:endereco)
			SA2->A2_BAIRRO 	:= upper(::dadosEnt:bairro)
			SA2->A2_MUN 	:= upper(::dadosEnt:municipio)
			SA2->A2_EST 	:= ::dadosEnt:estado
			SA2->A2_TIPO 	:= ::dadosEnt:pessoa_tipo
			SA2->A2_CGC 	:= ::dadosEnt:cpf_cnpj
			SA2->A2_INSCR 	:= ::dadosEnt:inscEstad
			SA2->A2_CONTATO := upper(::dadosEnt:contato)
			SA2->A2_EMAIL 	:= ::dadosEnt:email
			SA2->A2_NR_END 	:= ::dadosEnt:numero
			SA2->A2_MSBLQL 	:= '1'
			SA2->A2_PAIS 	:= '105'
			SA2->A2_NATUREZ := '120101'
			SA2->A2_TPFOR 	:= 'M'
			SA2->A2_CEP 	:= ::dadosEnt:cep
			SA2->A2_TEL 	:= ::dadosEnt:telefone1
			SA2->A2_CELULAR := ::dadosEnt:telefone2
			SA2->A2_BANCO 	:= ::dadosEnt:codBanco1
			SA2->A2_AGENCIA := ::dadosEnt:agencia1
			SA2->A2_NUMCON  := ::dadosEnt:conta1
			SA2->A2_BCO2 	:= ::dadosEnt:codBanco2
			SA2->A2_AGEN2   := ::dadosEnt:agencia2
			SA2->A2_CTA2	:= ::dadosEnt:conta2
			SA2->A2_SENHAP  := ::dadosEnt:senha
			SA2->A2_INSCRM  := ::dadosEnt:inscMunic
			SA2->A2_STATUSP := 'B'
			SA2->A2_CODPAIS := '01058'
			
			SA2->A2_CONTA	:= '2101011001'
			SA2->A2_VINCULA := '1'
			SA2->A2_ID_REPR := '2'
			SA2->A2_B2B     := '2'
			SA2->A2_PLCRRES := 'N'
			SA2->A2_PLFIL   := 'N'
			SA2->A2_RECPIS	:= '2'
			SA2->A2_RECCOFI := '2'
			SA2->A2_RECCSLL := '2'
			//campos
			msunlock()

			::dadosRet:sucesso 		:= 1
			::dadosRet:codInterno 	:= SA2->A2_COD
			::dadosRet:loja 		:= SA2->A2_LOJA
			::dadosRet:nomeReduzido := SA2->A2_NREDUZ
			::dadosRet:ativo 		:= SA2->A2_MSBLQL
		endif	
		
	else //senใo cadastra novo fornecedor
		
		//Conout("ENTREI NO ELSE")

		_cCodForn := getSx8Num('SA2','A2_COD')
		ConfirmSx8()
		reclock('SA2',.t.)				
		SA2->A2_COD 	:= _cCodForn
		SA2->A2_LOJA 	:= '01'
		SA2->A2_NOME	:= upper(::dadosEnt:nome) //(RAZAO)
		SA2->A2_NREDUZ 	:= upper(::dadosEnt:nreduz) //(NOME FANTASIA)
		SA2->A2_END 	:= upper(::dadosEnt:endereco)
		SA2->A2_BAIRRO 	:= upper(::dadosEnt:bairro)
		SA2->A2_MUN 	:= upper(::dadosEnt:municipio)
		SA2->A2_EST 	:= ::dadosEnt:estado
		SA2->A2_TIPO 	:= ::dadosEnt:pessoa_tipo
		SA2->A2_CGC 	:= ::dadosEnt:cpf_cnpj
		SA2->A2_INSCR 	:= ::dadosEnt:inscEstad
		SA2->A2_CONTATO := upper(::dadosEnt:contato)
		SA2->A2_EMAIL 	:= ::dadosEnt:email
		SA2->A2_NR_END 	:= ::dadosEnt:numero
		SA2->A2_MSBLQL 	:= '1'
		SA2->A2_PAIS 	:= '105'
		SA2->A2_NATUREZ := '120101'
		SA2->A2_TPFOR 	:= 'M'
		SA2->A2_CEP 	:= ::dadosEnt:cep
		SA2->A2_TEL 	:= ::dadosEnt:telefone1
		SA2->A2_CELULAR := ::dadosEnt:telefone2
		SA2->A2_BANCO 	:= ::dadosEnt:codBanco1
		SA2->A2_AGENCIA := ::dadosEnt:agencia1
		SA2->A2_NUMCON  := ::dadosEnt:conta1
		SA2->A2_BCO2 	:= ::dadosEnt:codBanco2
		SA2->A2_AGEN2   := ::dadosEnt:agencia2
		SA2->A2_CTA2	:= ::dadosEnt:conta2
		SA2->A2_SENHAP  := ::dadosEnt:senha
		SA2->A2_INSCRM  := ::dadosEnt:inscMunic	
		SA2->A2_STATUSP := 'B'
		SA2->A2_CODPAIS := '01058'

		SA2->A2_CONTA	:= '2101011001'
		SA2->A2_VINCULA := '1'
		SA2->A2_ID_REPR := '2'
		SA2->A2_B2B     := '2'
		SA2->A2_PLCRRES := 'N'
		SA2->A2_PLFIL   := 'N'
		SA2->A2_RECPIS	:= '2'
		SA2->A2_RECCOFI := '2'
		SA2->A2_RECCSLL := '2'		
		msunlock()
		
		::dadosRet:sucesso 		:= 1
		::dadosRet:codInterno 	:= SA2->A2_COD
		::dadosRet:loja 		:= SA2->A2_LOJA
		::dadosRet:nomeReduzido := SA2->A2_NREDUZ
		::dadosRet:ativo 		:= SA2->A2_MSBLQL
	endif
	
	//Conout("====== F I N A L =========================================")
	
Return .t.   
