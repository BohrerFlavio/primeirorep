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
WSSTRUCT dadoEntrRom

	WSDATA tcCPFCNPJ_COMPRADOR		AS STRING
	WSDATA tcINSC_ESTADUAL 			AS STRING
	WSDATA tcDataAdiantamento 		AS STRING
	WSDATA tcDataEmbarque 			AS STRING
	WSDATA tcDataCadastro			AS STRING
	WSDATA tcCodBANCO 				AS STRING
	WSDATA tcNomeBanco 				AS STRING
	WSDATA tcAgencia 				AS STRING
	WSDATA tcConta 					AS STRING
	WSDATA tcNomeDestinatario 		AS STRING
	WSDATA tcCPFCNPJDestinatario	AS STRING
	WSDATA tcPrazo 			 		AS STRING
	WSDATA TCCODINTERNO_PRODUTOR    AS STRING
	WSDATA TCCPFCNPJ_PRODUTOR		AS STRING
	WSDATA TCCODINTERNO_COMPRADOR	AS STRING
	WSDATA TCNUMERO					AS STRING
	WSDATA TCCARCACA				AS STRING
	WSDATA TCTAXADESCAVISTA			AS STRING
	WSDATA tcAnimais 				AS Array of aAnimais

ENDWSSTRUCT

WSSTRUCT aAnimais

	/*Lista de categorias
	001 - Novilhos Gordos
	002 - Vacas Gordas
	003 - Touros Gordos
	004 - B๚falos Gordos
	005 - B๚falas Gordas
	006 - Cruza Leite Novilho
	007 - Touruno Novilho
	008 - Vaca Cruza Leite
	*/

	WSDATA tcCategoriaAnimal AS STRING
	WSDATA tcQuantidade 	 AS STRING
	WSDATA tcPrecoBase 		 AS STRING
	WSDATA tcPrecoBonus 	 AS STRING
	WSDATA tcPesoMedio 		 AS STRING
	WSDATA tcPrograma 		 AS STRING
	WSDATA TC_CLQUANTIDADE   AS STRING
	WSDATA TC_CLPRECOBASE    AS STRING
	WSDATA TC_TNQUANTIDADE	 AS STRING
	WSDATA TC_TNPRECOBASE	 AS STRING

ENDWSSTRUCT

//Cria estrutura com os dados que sใo exibidos no xml do webservice
//Isso ้ o que retornarแ para quem fizer a requisi็ใo
WSSTRUCT dadoRetRom

	WSDATA sucesso 		 AS INTEGER
	WSDATA codInterno  	 AS STRING

ENDWSSTRUCT

//Cria a tag de Webservice
WSSERVICE wsCadRomaneio Description "Servico de inclusao de produtor de gado"
	//Proriedades
	WSDATA dadosEnt AS dadoEntrRom //chama a estrutura dos dados de entrada
	WSDATA dadosRet AS dadoRetRom  //chama a estrutura dos dados de retorno

	//Declara os metodos
	WSMETHOD setDadoTabela Description "<b> Metodo de inclusใo de um novo produtor ou uma nova loja do mesmo</b><br> <u>Retorno</u><br>

ENDWSSERVICE//fecha o servico

WSMETHOD setDadoTabela WSRECEIVE dadosEnt WSSEND dadosRet WSSERVICE wsCadRomaneio
	local i
	RPCSetType(3) //nใo consome licen็a.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'ZAQ'

	_cStatus := 'B'

	SA2->(dbSetOrder(12))
	SA2->(dbGoTOp())
	SA2->(dbSeek(FWxFilial('SA2') + alltrim(::dadosEnt:tcINSC_ESTADUAL)))

	_codComprador := ''
	
	if !empty(::dadosEnt:TCCODINTERNO_COMPRADOR)
		_codComprador := padl(alltrim(::dadosEnt:TCCODINTERNO_COMPRADOR),6,'0')
	endif

	SA3->(dbSetOrder(1))
	SA3->(dbGoTop())
	SA3->(dbSeek(FWxFilial('SA3') + _codComprador))
	
	if empty(::dadosEnt:TCNUMERO)
		_cNum := GETSX8NUM('ZAQ','ZAQ_NUM')
		Confirmsx8()
		reclock('ZAQ',.t.)
	else

		_cNum := padl(alltrim(::dadosEnt:TCNUMERO),10,'0')

		ZAQ->(dbSetOrder(1))
		ZAQ->(dbGoTop())
		ZAQ->(dbSeek(FWxFilial('ZAQ') + _cNum))

		reclock('ZAQ',.f.)

		//fazer dbseek na tabela ZAQ
	endif

	/******CABEวALHO******/
	ZAQ->ZAQ_FILIAL 	:= FWxFilial('ZAQ')
	ZAQ->ZAQ_STATUS 	:= _cStatus
	ZAQ->ZAQ_NUM 		:= _cNum
	//ZAQ->ZAQ_DATA   	:= date()
	ZAQ->ZAQ_DATA 		:= stod(::dadosEnt:tcDataCadastro)
	ZAQ->ZAQ_DATAEM  	:= stod(::dadosEnt:tcDataEmbarque)
	ZAQ->ZAQ_CODPRO		:= SA2->A2_COD
	ZAQ->ZAQ_DESCP 		:= SA2->A2_NOME
	ZAQ->ZAQ_CNPJ       := ::dadosEnt:TCCPFCNPJ_PRODUTOR
	ZAQ->ZAQ_INSCR		:= ::dadosEnt:tcINSC_ESTADUAL
	ZAQ->ZAQ_END		:= SA2->A2_END
	ZAQ->ZAQ_MUN		:= SA2->A2_MUN
	ZAQ->ZAQ_TEL		:= SA2->A2_TEL
	ZAQ->ZAQ_CEP		:= SA2->A2_CEP
	ZAQ->ZAQ_EMAIL		:= SA2->A2_EMAIL
	
	if !empty(::dadosEnt:TCCODINTERNO_COMPRADOR)
		ZAQ->ZAQ_CODCOM		:= _codComprador
		ZAQ->ZAQ_NOMECO     := SA3->A3_NOME
	endif
	/******ANIMAIS******/

	for i := 1 to len(::dadosEnt:tcAnimais)

		_cCategAnimal := padl(alltrim(::dadosEnt:TcAnimais[i]:tcCategoriaAnimal),3,'0')

		if  _cCategAnimal == '001' //Novilhos

			ZAQ->ZAQ_NGQTD 	:= val(::dadosEnt:TcAnimais[i]:tcQuantidade)
			ZAQ->ZAQ_NGPRC	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBase,',','.'))
			ZAQ->ZAQ_NGPRCB	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBonus,',','.'))
			ZAQ->ZAQ_NGPES 	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPesoMedio,',','.'))
			ZAQ->ZAQ_NGPROG	:= ::dadosEnt:TcAnimais[i]:tcPrograma

			//cruza leite
			ZAQ->ZAQ_NGQMES := val(::dadosEnt:TcAnimais[i]:TC_CLQUANTIDADE)
			ZAQ->ZAQ_NGPMES	:= val(strtran(::dadosEnt:TcAnimais[i]:TC_CLPRECOBASE,',','.'))

			//touruno
			ZAQ->ZAQ_NGQTOU	:= val(::dadosEnt:TcAnimais[i]:TC_TNQUANTIDADE)
			ZAQ->ZAQ_NGPTOU	:= val(strtran(::dadosEnt:TcAnimais[i]:TC_TNPRECOBASE,',','.'))

		elseif _cCategAnimal == '002' //Vacas

			ZAQ->ZAQ_VGQTD	:= val(::dadosEnt:TcAnimais[i]:tcQuantidade)
			ZAQ->ZAQ_VGPRC	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBase,',','.'))
			ZAQ->ZAQ_VGPRCB	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBonus,',','.'))
			ZAQ->ZAQ_VGPES	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPesoMedio,',','.'))
			ZAQ->ZAQ_VGPROG	:= ::dadosEnt:TcAnimais[i]:tcPrograma

			//cruza leite
			ZAQ->ZAQ_VGQMES	:= val(::dadosEnt:TcAnimais[i]:TC_CLQUANTIDADE)
			ZAQ->ZAQ_VGPMES	:= val(strtran(::dadosEnt:TcAnimais[i]:TC_CLPRECOBASE,',','.'))

		elseif _cCategAnimal == '003' //Touros

			ZAQ->ZAQ_TGQTD	:= val(::dadosEnt:TcAnimais[i]:tcQuantidade)
			ZAQ->ZAQ_TGPRC	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBase,',','.'))
			ZAQ->ZAQ_TGPRCB	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBonus,',','.'))
			ZAQ->ZAQ_TGPES	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPesoMedio,',','.'))
			ZAQ->ZAQ_TGPROG	:= ::dadosEnt:TcAnimais[i]:tcPrograma

		elseif _cCategAnimal == '004' //Bufalos

			ZAQ->ZAQ_BGQTD	:= val(::dadosEnt:TcAnimais[i]:tcQuantidade)
			ZAQ->ZAQ_BGPRC	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBase,',','.'))
			ZAQ->ZAQ_BGPRCB	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBonus,',','.'))
			ZAQ->ZAQ_BGPES	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPesoMedio,',','.'))
			ZAQ->ZAQ_BGPROG := ::dadosEnt:TcAnimais[i]:tcPrograma

		elseif _cCategAnimal == '005' //Bufalas

			ZAQ->ZAQ_BAQTD	:= val(::dadosEnt:TcAnimais[i]:tcQuantidade)
			ZAQ->ZAQ_BAPRC	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBase,',','.'))
			ZAQ->ZAQ_BAPRCB := val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBonus,',','.'))
			ZAQ->ZAQ_BAPES	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPesoMedio,',','.'))
			ZAQ->ZAQ_BAPROG := ::dadosEnt:TcAnimais[i]:tcPrograma

			/*
			elseif _cCategAnimal == '006' //cruza leite novilho

			ZAQ->ZAQ_NGQMES := val(::dadosEnt:TcAnimais[i]:tcQuantidade)
			ZAQ->ZAQ_NGPMES	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBase,',','.'))

			elseif _cCategAnimal == '007' //touruno novilho

			ZAQ->ZAQ_NGQTOU	:= val(::dadosEnt:TcAnimais[i]:tcQuantidade)
			ZAQ->ZAQ_NGPTOU	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBase,',','.'))

			elseif _cCategAnimal == '008' //vaca cruza leite

			ZAQ->ZAQ_VGQMES	:= val(::dadosEnt:TcAnimais[i]:tcQuantidade)
			ZAQ->ZAQ_VGPMES	:= val(strtran(::dadosEnt:TcAnimais[i]:tcPrecoBase,',','.'))
			*/
		endif

	next

	/******DADOS DEPOSITO******/

	ZAQ->ZAQ_PRAZO 	:= iif(val(::dadosEnt:tcPrazo) = 99, 30, val(::dadosEnt:tcPrazo))//se vier 99 grava 30, senใo grava o prazo
	ZAQ->ZAQ_DTADIA := ::dadosEnt:tcDataAdiantamento
	ZAQ->ZAQ_NOMEDE := ::dadosEnt:tcNomeDestinatario
	ZAQ->ZAQ_CGCDEP := ::dadosEnt:tcCPFCNPJDestinatario
	ZAQ->ZAQ_BANCO	:= ::dadosEnt:tcNomeBanco
	ZAQ->ZAQ_AGENC  := ::dadosEnt:tcAgencia
	ZAQ->ZAQ_CC		:= ::dadosEnt:tcConta
	ZAQ->ZAQ_TXDESC := val(strtran(::dadosEnt:TCTAXADESCAVISTA,',','.'))
	ZAQ->ZAQ_CDBCOD	:= ::dadosEnt:tcCodBANCO
	ZAQ->ZAQ_NPR	:= iif(val(::dadosEnt:tcPrazo) = 99, '1', '2')
	ZAQ->ZAQ_TPCOM  := ::dadosEnt:TCCARCACA

	msunlock()

	::dadosRet:sucesso 		:= 1
	::dadosRet:codInterno 	:= _cNum

Return .t.
