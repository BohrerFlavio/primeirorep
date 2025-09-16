#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWSAlteraSenha บAutor ณMauricio Roehrs    บ Data ณ  27/05/19  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Web Service Server para alterarsenha do produtor/compradorบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//Nessa estrutura vem o dado de entrada
WSSTRUCT dadoPwsEntr
	WSDATA tcCPFCNPJ		AS STRING
	WSDATA tcSenhaNova		AS STRING	
	WSDATA tcTipo 	 		AS INTEGER

ENDWSSTRUCT

//Cria estrutura com os dados que sใo exibidos no xml do webservice
//Isso ้ o que retornarแ para quem fizer a requisi็ใo
WSSTRUCT dadoPwsResp

	WSDATA sucesso 	AS INTEGER
	WSDATA tcSenhaNova AS STRING
	
ENDWSSTRUCT


//Cria a tag de Webservice
WSSERVICE wsAlteraSenha Description "Servico contendo o metodo para alterar a senha de produtores/compradores"

	/*dados para teste
	39530973004 - cnpj
	0921022476  - inscri */

	//Proriedades
	WSDATA dadosEnt AS dadoPwsEntr 	  //chama a estrutura dos dados de entrada
	WSDATA dadosRet AS dadoPwsResp     //chama a estrutura dos dados de retorno do pedido

	//Declara os metodos
	WSMETHOD alteraPsw Description " <b> Metodo de busca de produtores</b><br><u>Entrada: </u><br>Cnpj/Cpf, flag para diferenciar produtor de comprador e nova senha <br> <u>Retorno: </u><br> Flag de sucesso"

ENDWSSERVICE//fecha o servico

WSMETHOD alteraPsw WSRECEIVE dadosEnt WSSEND dadosRet WSSERVICE wsAlteraSenha

//	local aPV    := {}
//	local aCab   := {}
//	local aItem  := {}

	//aPv := pesqPRd(::dadosEnt:tcCPFCNPJ,::dadosEnt:tcTipo)
	
	RPCSetType(3) //nใo consome licen็a.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'SA2','SA3'
	
	_cpfcnpj :=  padr(alltrim(::dadosEnt:tcCPFCNPJ),14,'')
	
	dbSelectArea('SA2')
	SA2->(dbSetOrder(3))
	
	dbSelectArea('SA3')
	SA3->(dbSetOrder(3))
	
	if SA2->(dbSeek(FWxFilial('SA2') + _cpfcnpj))  .and. ::dadosEnt:tcTipo = 1
		while SA2->(!eof()) .and. FWxFilial('SA2') == SA2->A2_FILIAL .and. SA2->A2_CGC == _cpfcnpj
		
			reclock('SA2',.f.)
			SA2->A2_SENHAP := alltrim(::dadosEnt:TcSenhaNova)
			msunlock()	
			
			SA2->(dbSkip())
		enddo
		
		::dadosRet:sucesso := 1
		::dadosRet:tcSenhaNova := alltrim(::dadosEnt:TcSenhaNova)
		
	elseif  SA3->(dbSeek(FWxFilial('SA3') + _cpfcnpj))  .and. ::dadosEnt:tcTipo = 2
	
		reclock('SA3',.f.)
		SA3->A3_SENHAP := alltrim(::dadosEnt:TcSenhaNova)
		msunlock()
		
		::dadosRet:sucesso 	   := 1
		::dadosRet:tcSenhaNova := alltrim(::dadosEnt:TcSenhaNova)
	else
		::dadosRet:sucesso 	   := 0
		::dadosRet:tcSenhaNova := ""
	endif
	
Return .t.



