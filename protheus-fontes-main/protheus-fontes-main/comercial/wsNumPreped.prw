#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณwsNumPrePed บAutor  ณMauricio Roehrs  บ Data ณ  03/08/19   บฑฑ
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
WSSTRUCT receivePreped

	WSDATA flag 			AS STRING
	//WSDATA tcInscMunicipal 	AS STRING

ENDWSSTRUCT

//Cria estrutura com os dados que sใo exibidos no xml do webservice
//Isso ้ o que retornarแ para quem fizer a requisi็ใo
WSSTRUCT sendPreped

	WSDATA seqPreped 	AS STRING

ENDWSSTRUCT

//Cria a tag de Webservice
WSSERVICE wsNumPreped Description "Servico de retorno do numero sequencial dos Pre-Pedidos"
	//Proriedades
	WSDATA dadosEnt AS receivePreped //chama a estrutura dos dados de entrada
	WSDATA dadosRet AS sendPreped  //chama a estrutura dos dados de retorno

	//Declara os metodos
	WSMETHOD getPrepedNum Description "<b> Metodo de retorno do numero sequencial dos Pre-Pedidos</b><br> <u>Retorno</u><br>

ENDWSSERVICE//fecha o servico

WSMETHOD getPrepedNum WSRECEIVE dadosEnt WSSEND dadosRet WSSERVICE wsNumPreped

	RPCSetType(3) //nใo consome licen็a.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'ZZ4'

	_cPreped := getSx8Num('ZZ4','ZZ4_NUM')
	ConfirmSx8()
	
	::dadosRet:seqPreped := _cPreped

Return .t.   
