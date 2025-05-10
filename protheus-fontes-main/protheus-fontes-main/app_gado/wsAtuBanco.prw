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
ฑฑบDesc.     ณ  Web Service Server para teste de integra็ใo e altera็ใo noบฑฑ
ฑฑบ          ณ  banco de dados                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//Nessa estrutura vem o dado de entrada
WSSTRUCT getDadosBanco

	WSDATA tcCPFCNPJ 	AS STRING
	WSDATA codBanco1	AS STRING
	WSDATA nomeBanco1	AS STRING
	WSDATA agencia1		AS STRING
	WSDATA conta1 	    AS STRING
	WSDATA codBanco2	AS STRING
	WSDATA nomeBanco2	AS STRING
	WSDATA agencia2		AS STRING
	WSDATA conta2 	    AS STRING

ENDWSSTRUCT

//Cria estrutura com os dados que sใo exibidos no xml do webservice
//Isso ้ o que retornarแ para quem fizer a requisi็ใo
WSSTRUCT retSetBanco

	WSDATA sucesso 	AS INTEGER

ENDWSSTRUCT

//Cria a tag de Webservice
WSSERVICE wsAtuBanco Description "Servico de altera็ใo de dado em tabela do sistema"
	//Proriedades
	WSDATA dadosEnt AS getDadosBanco //chama a estrutura dos dados de entrada
	WSDATA dadosRet AS retSetBanco  //chama a estrutura dos dados de retorno

	//Declara os metodos
	WSMETHOD setDadosBco Description "<b> Metodo de altera็ใo de dados em uma determinada tabela</b><br> <u>Retorno</u><br>

ENDWSSERVICE//fecha o servico

WSMETHOD setDadosBco WSRECEIVE dadosEnt WSSEND dadosRet WSSERVICE wsAtuBanco

	RPCSetType(3) //nใo consome licen็a.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'COM' TABLES 'SA2'

	
	SA2->(dbSetOrder(3))
	SA2->(dbGoTop())

	if SA2->(dbSeek(FWxFilial('SA2') +  padr(alltrim(dadosEnt:tcCPFCNPJ),14,'')))
		
		while SA2->(!eof())  .and. SA2->A2_CGC == padr(alltrim(dadosEnt:tcCPFCNPJ),14,'') .and. SA2->A2_FILIAL == FWxFilial('SA2')
			
			if SA2->A2_MSBLQL = '1'
				SA2->(dbSkip())
				loop
			endif
			
			reclock('SA2',.f.)
			SA2->A2_BANCO 	:= ::dadosEnt:codBanco1
			SA2->A2_AGENCIA := ::dadosEnt:agencia1
			SA2->A2_NUMCON  := ::dadosEnt:conta1
			SA2->A2_BCO2 	:= ::dadosEnt:codBanco2
			SA2->A2_AGEN2   := ::dadosEnt:agencia2
			SA2->A2_CTA2	:= ::dadosEnt:conta2
			msunlock()
			
			SA2->(dbSkip())
		enddo
		::dadosRet:sucesso 	:= 1
	else

		::dadosRet:sucesso 	:= 0

	endif

Return .t.   
