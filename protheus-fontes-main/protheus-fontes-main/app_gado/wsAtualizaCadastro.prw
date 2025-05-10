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
WSSTRUCT dadoCadEntr

	WSDATA tcCODINTERNO		AS STRING	
	WSDATA tcTipo 	 		AS INTEGER
	WSDATA tcEMAIL			AS STRING
	WSDATA tcTELEFONE		AS STRING

ENDWSSTRUCT

//Cria estrutura com os dados que sใo exibidos no xml do webservice
//Isso ้ o que retornarแ para quem fizer a requisi็ใo
WSSTRUCT dadoCadResp

	WSDATA sucesso 	AS INTEGER
	//WSDATA tcSenhaNova AS STRING
	
ENDWSSTRUCT


//Cria a tag de Webservice
WSSERVICE wsAtualizaCadastro Description "Servico contendo o metodo para atualizar o cadastro de produtores/compradores"

	/*dados para teste
	39530973004 - cnpj
	0921022476  - inscri */

	//Proriedades
	WSDATA dadosEnt AS dadoCadEntr 	  //chama a estrutura dos dados de entrada
	WSDATA dadosRet AS dadoCadResp     //chama a estrutura dos dados de retorno do pedido

	//Declara os metodos
	WSMETHOD atualizaCad Description " <b> Metodo de busca de produtores</b><br><u>Entrada: </u><br>Codigo Interno, flag para diferenciar produtor de comprador, email e telefone <br> <u>Retorno: </u><br> Flag de sucesso"

ENDWSSERVICE//fecha o servico

WSMETHOD atualizaCad WSRECEIVE dadosEnt WSSEND dadosRet WSSERVICE wsAtualizaCadastro

//	local aPV    := {}
//	local aCab   := {}
//	local aItem  := {}

	//aPv := pesqPRd(::dadosEnt:tcCPFCNPJ,::dadosEnt:tcTipo)
	
	RPCSetType(3) //nใo consome licen็a.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'SA2','SA3'
	
	_cCod :=  padl(alltrim(::dadosEnt:tcCODINTERNO),6,'0')
	
	dbSelectArea('SA2')
	SA2->(dbSetOrder(1))
	
	dbSelectArea('SA3')
	SA3->(dbSetOrder(1))
	
	if SA2->(dbSeek(FWxFilial('SA2') + _cCod))  .and. ::dadosEnt:tcTipo = 1
		while SA2->(!eof()) .and. FWxFilial('SA2') == SA2->A2_FILIAL .and. SA2->A2_COD == _cCod
		
			reclock('SA2',.f.)
			SA2->A2_EMAIL := alltrim(::dadosEnt:tcEMAIL)
			SA2->A2_TEL   := alltrim(::dadosEnt:tcTELEFONE)
			msunlock()	
			
			SA2->(dbSkip())
		enddo
		
		::dadosRet:sucesso := 1
		
	elseif  SA3->(dbSeek(FWxFilial('SA3') + _cCod))  .and. ::dadosEnt:tcTipo = 2
	
		reclock('SA3',.f.)
		SA3->A3_EMAIL := alltrim(::dadosEnt:tcEMAIL)
		SA3->A3_TEL   := alltrim(::dadosEnt:tcTELEFONE)
		msunlock()
		
		::dadosRet:sucesso 	   := 1
	else
		::dadosRet:sucesso 	   := 0
	endif
	
Return .t.



