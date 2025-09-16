#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "TBICODE.ch"
#INCLUDE "TOTVS.ch"



/*/{Protheus.doc} User Function MITFS001
	(Rotina para impressão de etiquetas adesivas para processo dos EUA)
	@type  Function
	@author Mauricio Roehrs
	@since 01/03/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
	
USER FUNCTION MITFS001()
    Dbselectarea('SB1')
	Dbsetorder(1)
	DbSelectArea('ZAB')
	ZAB->(dbsetorder(1))

	//VARIAVEIS DOS CAMPOS ONDE VALORES SERÃO INSERIDOS
	campoCodProduto  := Space(6)
	campoDataProducao   := SToD("")
	campoDescCorte := Space(40)
	campoTara := 0
	campoQtdCaixas :=0
	campoQtdEtiquetas :=0
	cpLotePrd := space(25)
	oLotePrd := nil
	oSay := nil
	_cTPCadMerc := ''
	valor1 	:= Space(6)   // Codigo do Produto	
	valor2 	:= SToD("")     // Data de Produção
	valor3 := Space(40)	// Descrição do Corte
	valor4 := 0.000	// Tara
	valor5 := 0 //Quantidade de Caixas
	valor6 := 0 //Quantidade de Etiquetas
	cLotePrd := space(25)


	//PARAMETROS COM CODIGO DOS USUÁRIOS QUE PODEM IMPRIMIR ETIQUETAS COM DATAS DIFERENTES A DATABASE	
	_cUsuarios  := getMv( 'SI_USRETQ' ) //parametro com os codigos dos usuarios que podem imprimir ETQ interna com data maior que DATABASE
	_cUsrPorc   := getMv( 'SI_ETQPRC' ) //parametro com os codigos de usuarios que podem imprimir com um intervalo de datas bem grande
	
	//PARAMETROS COM CODIGO DOS PRODUTOS TEM INFORMAÇÕES DE TABELA NUTRICIONAL OCULTA
	_cParTabNut := GetMV( 'MV_PARTNEI' )

	//VERIFICA OS USUÁRIOS LOGADOS E APLICA REGRAS
	_cCodUser   := retCodUsr()

	IF alltrim(_cCodUser) $ _cUsuarios
		_dDTMaior   := date() + 7
		_dDTMenor	:= date() - 7

	ELSEIF alltrim(_cCodUser) $ _cUsrPorc
		_dDTMaior   := date() + 365
		_dDTMenor	:= date() - 365

	ELSE
		_dDTMaior   := date()
		_dDTMenor	:= date() - 7
	ENDIF	

	//CRIA A INTERFACE GRAFICA
	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA INTERNA EUA"
	
	InterfaceGrafica()

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()
	
	ACTIVATE MSDIALOG telaimp CENTERED
RETURN

STATIC FUNCTION Imprime()

	Processa({||ETIQUETA() },"IMPRESSAO DE ETIQUETA","Realizando envio à impressora...")

RETURN

STATIC FUNCTION Clear()

	valor1 	:= Space(6)
	valor2 	:= date()
	valor3 := Space(40)
	valor4 := 0.000
	valor5 := 0
	valor6 := 0
	cpLotePrd := space(25)
	

	telaimp:refresh()
RETURN

STATIC FUNCTION ETIQUETA()
	LOCAL  _DtAbt    := valor2	
	
	DbSelectArea('ZAB')
	ZAB->(dbsetorder(1))
	
	_cCodTar := fBuscaCpo('SB1',1,FWxFilial('SB1') + alltrim(valor1),'B1_CTARAP')
	_nValTar := fBuscaCpo('ZAB',1,FWxFilial('ZAB') + _cCodTar,'ZAB_TARA')
	_cTPMerc := fBuscaCpo('SB1',1,FWxFilial('SB1') + alltrim(valor1),'B1_DESTINO')
    _cTPCadMerc := fBuscaCpo('SB1',1,FWxFilial('SB1') + alltrim(valor1),'B1_CADMERC')

	btn1:disable()
	telaimp:refresh()

	ProcRegua(valor5)

	DbSelectArea('SB1')
	SB1->(dbsetorder(1))
	DbSelectArea('ZZ7')
	ZZ7->(dbsetorder(1))
	
	SB1->(dbSeek(FWxfilial('SB1')+ valor1))
	ZZ7->(dbSeek(FWxfilial('ZZ7')+ valor1))

	_DtVal := valor2 + SB1->B1_VALID
	_nQtdCx := fBuscaCpo('SB1',1,FWxFilial('SB1') + alltrim(valor1),'B1_QCAIX')
	_nQetq  := _nQtdCx * valor5
	valor6 := _nQetq	

	incproc()
	
	_cEst := getComputerName()
	_cIp  := ''

	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	if ZAM->(dbSeek(FWxFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	endif
	//alert('Linha 137')
	if empty(_cIp)
		MSCBPRINTER('S600','LPT1')
	else
		MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
	endif
	//alert(_cIp)// esse aqui esta imprimindo na tela  
	//COMEÇO DA CONSTRUÇÃO DOS BLOCOS A SEREM IMPRESSOS NA ETIQUETA 

	MSCBCHKSTATUS(.f.)
	
	MSCBLoadGRF("LOGOSIF.GRF")
    MSCBLoadGRF("DADOSIF.GRF")
    MSCBLoadGRF("ICON_CLO.GRF")

	MSCBBEGIN(_nQetq,6,15)	// Usar variavel no primeiro campo, para a quantidade de etiquetas

	//DEFINE TAMANHO DOS TIPOS DE FONTES	
	fonteTipoA_1 := "17.99"
	fonteTipoA_2 := "17.50"
	fonteTipoA_3 := "17.00"	

	fonteTipoB_1 := "18.99"
	fonteTipoB_2 := "18.50"
	fonteTipoB_3 := "18.00"

	fonteTipoC_1 := "19.99"
	fonteTipoC_2 := "19.50"
	fonteTipoC_3 := "19.00"

	fonteTipoD_1 := "20.99"
	fonteTipoD_2 := "20.50"
	fonteTipoD_3 := "20.00"

	fonteTipoE_1 := "21.99"
	fonteTipoE_2 := "21.50"
	fonteTipoE_3 := "21.99"

	fonteTipoF_1 := "22.99"
	fonteTipoF_2 := "22.50"
	fonteTipoF_3 := "22.00"

	fonteTipoG_1 := "23.99"
	fonteTipoG_2 := "23.50"
	fonteTipoG_3 := "23.00"

	fonteTipoH_1 := "24.99"
	fonteTipoH_2 := "24.50"
	fonteTipoH_3 := "24.00"

	fonteTipoI_1 := "25.99"
	fonteTipoI_2 := "25.50"
	fonteTipoI_3 := "25.00"
							

	

	IF (_cTPMerc = "ME" .and. _cTPCadMerc = 'U')    //Produção EUA com controle de lote


		//dados de configuração da etiqueta
		MSCBWrite("^XA")
		MSCBWrite("~TA000")
		MSCBWrite("~JSN")
		MSCBWrite("^LT0")
		MSCBWrite("^MNW")
		MSCBWrite("^MTT")
		MSCBWrite("^PON")
		MSCBWrite("^PMN")
		MSCBWrite("^LH0,0")
		MSCBWrite("^JMA")
		MSCBWrite("^PR6,6")
		MSCBWrite("~SD15")
		MSCBWrite("^JUS")
		MSCBWrite("^LRN")
		MSCBWrite("^CI27")
		MSCBWrite("^PA0,1,1,0")
		MSCBWrite("^XZ")
		MSCBWrite("^XA")
		MSCBWrite("^MMT")
		MSCBWrite("^PW719")
		MSCBWrite("^LL999")
		MSCBWrite("^LS0")

		//descrição do produto
		MSCBWrite("^FT44,999^A0B,34,35^FB905,1,9,C^FH\^CI28^FD"+alltrim(ZZ7->ZZ7_DESC)+"^FS^CI27")
		MSCBWrite("^FT87,999^A0B,34,35^FB905,1,9,C^FH\^CI28^FD"+alltrim(ZZ7->ZZ7_DESCE)+"^FS^CI27")

		//informações adicionais da empresa
		MSCBWrite("^FT558,977^A0B,28,30^FH\^CI28^FDRegistro no Ministério da Agricultura SIF/DIPOA sob Nº "+alltrim(ZZ7->ZZ7_MSIF)+"^FS^CI27")
		MSCBWrite("^FT493,999^A0B,25,25^FB628,1,6,C^FH\^CI28^FDNÃO CONTÉM GLÚTEN / GLUTEN FREE^FS^CI27")
		MSCBWrite("^FT524,999^A0B,25,25^FB628,1,6,C^FH\^CI28^FD"+alltrim(SB1->B1_MENETQ2)+"^FS^CI27")

		//data de produção
		_cMes:= substr(dtos(_DtAbt),3,2)
		_cAno:=	substr(dtos(_DtAbt),7,2)
		_cDia:= substr(dtos(_DtAbt),1,2)
		_dtPrdIng := _cMes +"/"+_cAno+"/"+_cDia
		MSCBWrite("^FT170,981^A0B,28,28^FH\^CI28^FDDATA DE PRODUÇÃO: "+DtoC(_DtAbt)+"^FS^CI27")
		MSCBWrite("^FT205,981^A0B,28,28^FH\^CI28^FDPRODUCTION DATE:"+_dtPrdIng+"^FS^CI27")

		//data de validade
		_cMes:= substr(dtos(_DtVal),3,2)
		_cAno:=	substr(dtos(_DtVal),7,2)
		_cDia:= substr(dtos(_DtVal),1,2)
		_dtValIng := _cMes +"/"+_cAno+"/"+_cDia
		MSCBWrite("^FT240,981^A0B,28,28^FH\^CI28^FDDATA DE VALIDADE:"+DtoC(_DtVal)+"^FS^CI27")
		MSCBWrite("^FT275,981^A0B,28,28^FH\^CI28^FDEXPIRY DATE:"+_dtValIng+"^FS^CI27")

		//lote de produção
		MSCBWrite("^FT452,981^A0B,28,30^FH\^CI28^FDLOTE/LOT: "+alltrim(cLotePrd)+"^FS^CI27")

		//peso da embalagem
		MSCBWrite("^FT390,981^A0B,23,25^FH\^CI28^FDPESO DA EMBALAGEM / PACKING TARE: "+transform(valor4,'@E 99') +"g^FS^CI27")

		MSCBWrite("^FT591,977^A0B,20,23^FH\^CI28^FDFRIGORIFICO SILVA INDUSTRIA E COMERCIO LTDA - Abatedouro e Frigorífico Ind. e ^FS^CI27")
		MSCBWrite("^FT616,977^A0B,20,23^FH\^CI28^FDCom. de Carnes e seus Derivados, BR 392 - KM 8, Passo das Tropas - Santa Maria / RS^FS^CI27")
		MSCBWrite("^FT641,977^A0B,20,23^FH\^CI28^FDBrasil, CEP:97.065-400, CNPJ: 88.728.027/0001-46 IE:109/0096949 INDÚSTRIA BRASILEIRA^FS^CI27")

		//imagem do SIF
		_imagem := getIMG()
		MSCBWrite(_imagem)

		MSCBWrite("^PQ1,,,Y")
		MSCBWrite("^XZ")


		/*
		//imagens e logos
		MSCBGrafic(52, 005, "LOGOSIF")
   		MSCBGrafic(00, 007, "DADOSIF")
    	MSCBGrafic(15, 140, "ICON_CLO")

		//Dados do produto
		MSCBSAY(05,06,ZZ7->ZZ7_DESC,"N","0",fonteTipoF_1)
		MSCBSAY(15,10,ZZ7->ZZ7_DESCE,"N","0",fonteTipoF_1)
		MSCBSAY(05,14,alltrim(ZZ7->ZZ7_CORTE) + "|" + alltrim(ZZ7->ZZ7_CORTEE),"N","0",fonteTipoE_1)		

		MSCBSAY(1,20,SB1->B1_MENETQ5,"N","0",fonteTipoC_1)

		//datas de produção ingles/portugues
		//_cMes:= substr(dtos(_DtAbt),3,2)
		//_cAno:=	substr(dtos(_DtAbt),7,2)
		//_cDia:= substr(dtos(_DtAbt),1,2)
		//_dtPrdIng := _cMes +"/"+_cAno+"/"+_cDia
		MSCBSAY(1,24,"DATA DE PRODUÇÃO","N","0",fonteTipoC_1)
		MSCBSAY(35,24,DtoC(_DtAbt),"N","0",fonteTipoC_1)
		MSCBSAY(1,24,"PRODUCTION DATE","N","0",fonteTipoC_1)
		//MSCBSAY(45,24,_dtPrdIng,"N","0",fonteTipoC_1)

		//datas de validade ingles/portugues
		//_cMes:= substr(dtos(_DtVal),3,2)
		//_cAno:=	substr(dtos(_DtVal),7,2)
		//_cDia:= substr(dtos(_DtVal),1,2)
		//_dtValIng := _cMes +"/"+_cAno+"/"+_cDia
		MSCBSAY(1,28,"DATA DE VALIDADE:","N","0",fonteTipoC_1)
		MSCBSAY(55,28,DtoC(_DtVal),"N","0",fonteTipoC_1)
		MSCBSAY(1,28,"EXPIRY DATE","N","0",fonteTipoC_1)
		//MSCBSAY(65,28,_dtValIng,"N","0",fonteTipoC_1)

		//peso da embalagem
		MSCBSAY(1,32,"PESO DA EMBALAGEM / PACKAGE WEIGHT: ","N","0",fonteTipoC_1)
		MSCBSAY(75,32,transform(valor4,'@E 99') + "g","N","0",fonteTipoC_1)

		//informações adicionais
		MSCBSAY(1,45,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA","N","0",fonteTipoA_1)
		MSCBSAY(20,48,"SOB N" + ZZ7->ZZ7_MSIF,"N","0",fonteTipoA_1)			
		MSCBSAY(1,52,SB1->B1_MENETQ2,"N","0",fonteTipoC_1)
		MSCBSAY(1,55,alltrim(ZZ7->ZZ7_OBS),"N","0",fonteTipoA_1)						
		MSCBSAY(05,60,ZZ7->ZZ7_CODPRO,"N","0",'40.00')

		//lote de produção
		MSCBSAY(05,66,"LOTE/LOT: " + cLotePrd,"N","0",fonteTipoC_1)						
		*/

	ELSE
		MsgAlert("CADASTRO COM PENDÊNCIAS. ENTRE EM CONTATO COM PCP.", "AVISO")
	ENDIF

	MSCBEND()
	MSCBCLOSEPRINTER()

	Clear()

	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

	btn1:enable()
	telaimp:refresh()

RETURN

STATIC FUNCTION DadosProducao()
	local _lFlag := .t.

	ZZ7->(dbsetorder(1))
	IF ZZ7->(dbseek(FWxfilial('ZZ7')+valor1))
		valor3 := ZZ7->ZZ7_CORTE	
	ENDIF

	if !valor1 $ ZZ7->ZZ7_CODPRO		
		MsgAlert("Produto informado não existe, favor cadastrar Et. Interna. Corrija o código inserido", "AVISO")	
		_lFlag := .f.	
		Clear()
		DadosProducao()
		btn1:enable()
	endif

	dbSelectArea('SB1')
	
	_nTaraP := FBuscaCPO('SB1',1,FWxfilial('SB1')+ alltrim(valor1),'B1_CTARAP')      // Linhas inseridas para buscar"_NTARAp"
	_nTP    := FBuscaCPO('ZAB',1,FWxfilial('ZAB')+alltrim(_nTaraP),'ZAB_TARA')  // os campos de codigo das taras primarias
	valor4  := (_nTP * 1000)
	
	
	telaimp:refresh()

RETURN

STATIC FUNCTION QuantEtq()
	
	_nQTD   := 0
	_nQtdCx := fBuscaCpo('SB1',1,FWxFilial('SB1') + alltrim(valor1),'B1_QCAIX')
	_nQetq  := _nQtdCx * valor5
	valor6   := _nQetq

RETURN 

STATIC FUNCTION InterfaceGrafica()

	
	@ 01,01 SAY "Produto:" of telaimp	
	@ 02,01 SAY "Data de Produção/Lote:" of telaimp
	@ 03,01 SAY "Descrição do Corte"
	@ 05,01 SAY "Tara:"
	@ 06,01 SAY "Quant. Caixas:"
	@ 07,01 SAY "Qtd.Etiquetas:" of telaimp

	@ 01,10 MSGET campoCodProduto VAR valor1 SIZE 30,10 F3 'ZZ7' OF telaimp		
	@ 02,10 MSGET campoDataProducao VAR valor2 SIZE 40,10 OF telaimp valid regra(valor2)
	@ 04,01 SAY valor3  OF telaimp
	@ 05,10 SAY transform(valor4,'@E 99') + ' g' of telaimp	
	@ 06,10 MSGET campoQtdCaixas VAR valor5 SIZE 40,10 OF telaimp picture '@E 999' VALID QuantEtq()
	@ 07,10 SAY	transform(valor6,'@E 999') OF telaimp

	@ 010, 01 SAY oSay PROMPT "Lote de Producao:" SIZE 025, 007 OF telaimp 
	@ 010, 10 MSGET oLotePrd VAR cLotePrd SIZE 100, 010 valid regrad(valor1,cLotePrd) F3 "ZULOTE" OF telaimp 

	campoCodProduto:bLostFocus := {|| DadosProducao() }

RETURN

STATIC FUNCTION regra(_data)
	_cUsuarios := getMv('SI_USRETQ')//parametro com os codigos dos usuarios que podem imprimir ETQ interna ( para campo Data Abate) com data maior que DATABASE
	_cUsrPorc  := getMv('SI_ETQPRC')//parametro com os codigos de usuarios que podem imprimir  ( para campo Data Abate) com um intervalo de datas bem grande
	
	_cCodUser  := retCodUsr()
	_dDTMaior := date()
	_dDTMenor := date() - 30
		
	IF empty(_data)
		MsgAlert('Favor preencher campo da Data de Produção !! ', 'PREENCHIMENTO PROIBIDA !!')	
			return .f.
	ENDIF
	/* Devemos cadastrar o usuário somente em um dos  parâmetros, ou no SI_USRETQ ou no SI_ETQPRC*/
	if alltrim(_cCodUser) $ _cUsuarios
		/* Regra para campo - Data Abate - Parametro SI_USRETQ */
		regraa(_data)
	
	ELSEIF alltrim(_cCodUser) $ _cUsrPorc
		/* Regra para campo - Data Abate - Parametro SI_ETQPRC - Porcionados */
		
		regrac(_data)
	ELSE 
		/* Se não estiver nos parâmetros então cai aqui */
		IF _data = _dDTMaior  .or. _data = _dDTMenor			
			return .t.
		ELSE
			MsgAlert('Data Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
			return .f.
		ENDIF
	ENDIF
RETURN .t.

STATIC FUNCTION regraa(_data1)
	Local  _cOper   := UsrRetName(retcodusr())
	_cCodUser  := retCodUsr()	
	_dDTMaior := date() - 1
	//_dDTMenor := date() - 30
	_dDTMenor := date() - 15

	if _data1 = _dDTMaior 			
		return .t.
	elseif _data1 <= _dDTMaior

		if _data1 >= _dDTMenor
			return .t.
		else
			MsgAlert('971 - Data de Produção Não permitida para usuário '+_cOper+', Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
			campoB:SETFOCUS()
			return .f.
		endif

	elseif 	_data1 <= _dDTMaior + 4
		// Regra nova implementada para o novo calculo da validade pela data de embalagem
		if _data1 >= _dDTMenor
			return .t.
		else
			MsgAlert('981 - Data de Produção Não permitida para o usuário '+_cOper+', Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
			campoB:SETFOCUS()
			return .f.
		endif
	else	
		MsgAlert('987 - Data de Embalagem Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
			campoB:SETFOCUS()
			return .f.
	endif
RETURN

STATIC FUNCTION regrac(_data2)
	Local  _cOper   := UsrRetName(retcodusr())
	_dDTMaior   := date() + 365
	_dDTMenor   := date() - 365

	/*Regras do campo "Data do Abate" para usuários Porcionados - SI_ETQPRC*/	
	
	if _data2 <= _dDTMaior 			
		
		if _data2 >= _dDTMenor 
			return .t.
		else
			MsgAlert('1006 - Data de Produção não permitida para Usuário '+_cOper+', Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
			campoB:SETFOCUS()	
			return .f.		
		endif
	else
		MsgAlert('1011 - Data de Produção não permitida  para Usuário '+_cOper+', Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
		campoB:SETFOCUS()			
		return .f.	
	endif
RETURN


/*/{Protheus.doc} regrad
	(Função destinada para validar o lote de produção informado)
	@type  Static Function
	@author Mauricio Roehrs
	@since 03/02/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function regrad(_cCodProd,_cLote)
	Local _cCadMerc:= ''

	_cCadMerc := fBuscaCpo('SB1',1,FWxFilial('SB1') + alltrim(_cCodProd),'B1_CADMERC')
	if _cCadMerc == 'U'
		if empty(_cLote)
			MsgAlert('Atenção, é obrigatório o preenchimento do lote para produtos de exportação para os EUA', 'Lote de Produção em Branco!')	
			oLotePrd:setFocus()			
			return .f.
		endif
	endif
	
Return .t.


static function getIMG()

Local _cIMG := ""

_cIMG:="^FO102,3^GFA,7377,24960,52,:Z64:eJztXM1rHEmWj0g5ySLHbqmhTV2kKeFTkwfP/AGNnQM2c5XBQpcq6l/Qgoa+qKnAp6QO8zckPiUxoL3vHjYbpu86uNlLC/dR6NBowMbLInXtey/y48VHlVLHBT27pKrMivjFyxfx4n2FhHigB3qgB3qgB3qgB3qgofRsf1+I/fu1OXx7IMTb+7SolNaVEl"
_cIMG+="rdo8034gd5KuQP98HJhH6mRXQvnF1xKqZCXgxvUQAjFbzSe+DsAM4xvLb+OhxHi0zBS6S6HNxmChgn8DOO64EtRkqrpaoK+LlUA9tIQEkA50SMZT6wTVZmyI8GjqJyYJtZjjizi1rsynpYExAKSAbnm9DLalgb+Yn4eXmUi++G4iAfKi01yEa/L4e1mQMfIq6nIJvT18NwUuBjiTjAC/I0hOTnGriR9"
_cIMG+="a48lovV9WCcVEVlFuloKE78lwZHTGUdD8QpECetNEpnqHxg5RicPZDO8cA2gFNGOOdQQgPbnIJ0ECf+qYY1NIxgtpXLElaPHq7gvgNuEsCRAvXP3RQJ1G2RxjUURfj+bnpEfcsP83zYmJBShfyMNLzo82hAmzG8JkIsPg2HgZVDLz1ULkjb8EqArXx4E4UKDV5FcQ+cJCec+1CZlvDsynu1yVFBD1bSR"
_cIMG+="GmVVvjzPm3kuYSFOVSpGYqqCDA6JY0Wwt10DZsBcNV8yvP13+ypUpUqlMK3hUYq1J1tTuFfQ/JosfpyOAAJN9GMus50Q3e22aV/SPHHFdLtP+9oMQKMrCAVsNS/nQHI2RlaPZspyceSVNrT1erLm68Pv1+tzje3+BamWkYcRMTKe/pZbmyzA1MNlRpws7r9QJdef7ytN7apQE3DbgoM6CvgA2kJQBsZA"
_cIMG+="oPtWt7iu/nqoLkGe9BGHDTYImQn67mI7hDRHkDRpH6y6sUSr37ZiAMKZwQTe8T3t3TzZjdu9LNc8O1t3PEWoqw0+jmzWMg2MhTXBmd+k/PL85sNbVK0QRVaIopf1lcbGAJlgDhyYc8xuciDXyeKNPGTOVMs2sjQKeFM3PF7FzoibqDH0Zk7w5ZX69Q3LJwJ2gMuO3Blla9pk1XACapRb8VEa2fC3rlIc"
_cIMG+="PHE/ujnH8JNFNpt2KG+Uu69wCVDJzhw7NTXAHLNGor0Pvk7UUABhK4R1fB6BezcBu7N62AT2nXosSn/5poH1+4645BpOA7bC7DrRMrusuzeZWHlAzho7PCh5/3dEJO0W6eE0/XOl1GYIVmTYSD7Hscn/d1J7TUQxA8ZB/1a4ao6Cy4hwEHDIOmf0Ns4794HJqEg+ZDxVqF7SsSt67CnCsogsQYua2YohD"
_cIMG+="3vqCJ+gIfGPohK5s2tmXHXxA+O+7zBET1OeMaREydSWCmp2ULhExNKWECnyA8+Nmlm3Jbg3kISmIYpcAKWAcoh0g0/HCcNCOiRmIBbKrZh2NLIArhjG0JIQGmR4fw6wxV0FeAnJKCxSD7D8BfwVhqbR1r80B2HshIdOSMG06UlHz7f+/Gei1ltxCOMzG35hGY2ODvoMBIrDU61tHB8ARkmjBRemkvHaGx"
_cIMG+="3FBAQcBK1Jm9WmisWCyEB0YTartnQZ5ZhIAMCovGeEc5zM3R7Ww0JiFzeCXEwNjjStgsCK4hmmeEgMzhOMCS0gk6bF8kqQN4KwmCBIsnAz/RS4C+lLA48ASUHyIs0SkcGvfmxiwPrBqTSyABZ+9bTaZ67AiYArJeGERQFPLPY3kU9LkEWqOCMjkvpg2v2eDgn02bI6GSjYQqc/e3I+oo3EbDPklgq8ZPKt"
_cIMG+="DvfWjXR0/Fj/AleNjlzP+DmbelRg25TtSwKihYsUbnpQqOtrWwOnAkna3JKF80ymcgF6QN7wk1smAi0gaYRp519bes30S4rhvMEVgs+GdJjk4+/uPpNtIuro1RR+OiyWSbGvlIOjiOgREzA0SHnFPXYGA02W18LTyOg31OZjlAoZJF6/Lg4+RR6TnDAuEyIqdiNIjnTPa3QEzU4VSOktCh4x0sVXSreZlx"
_cIMG+="jl6RvcNQUFt3KJcd52urxluhBGQGggCLzxlqZmXImXExeGwm622jii4uafWUunOBVarSbEkZAI+XjnHnBqzk+EzPezjvY2eHfmHgTjlwCM9521UTvregobral1SZGjWM4WWN7PvImHMbamuffedhKcTcB5GftR4KWTiPnZG2sKnFGgJupeUz9RhM5msbVPKC9Wu3WWYpuoMfVcGnVdtNtNCNXQ7s4MLfa4"
_cIMG+="XYCOsqd71gTu8Ip1j7+VkCuX+doOOqwffytJRB7jjbXpGmFQR3kQ4l+o/EjB/yCvP5G9NOpMQvkiRcc5QsorZAXmFEpfSqb0XvBUc5PUu8BDzMTHm0prh+7bfgCSgty5JRhZaQa8HQTP0/Fy2sa7aLuL8rzb1wcvoAyWj/atqIDbjZfQLviYIpPX64Yjph6wWu+gGCngaFeKjDfWMbHlg++5xHNXXG8Sw7"
_cIMG+="DZ2Cto9gzQfkCykSVkcMAxmLPhOV4G5XHLkxFTjgwXu5az1i3tJb4gqoQB1bHV0XKmWD+DxkM1gI6Rpa2ruH5yxWfu2yf28I1yheQRpZgsJmycHoHFWxthOAKYoo4CUZ3ktugCx/X0sNRCuyBEuMhVz0Os9/S0rDCgou7lCSpxXdicu4oZUNJTRB8Q8pwi6ZoVVZ2cyp69my/x4lMmLFvs53DI9rG7Mi87"
_cIMG+="ufUq1d5z4/RBWyhpuiKYrgfdpmv2iHz/QdjP2gwMJzkGkyoCUb5Fv2ckl/6bBZwcyrALeY4aN8gTgSWW8cPw4kQx0kHrS4o9HYKmylbI/1OBDjIq6UQtEn1aM0XUMFxlMbgj6UQTsjrmRxdU8akvdq9w1jWeFXbCkGbSaerJnxtGGJvjU3X3zQEY53YXbFs/SnYdLe5hTMqCCcF/+es64qvFq3OtC7Ecwc"
_cIMG+="Hnn2y4jostm5OUFpjuwnhoAi6rrg20+9IWo6FQBPqLZ9SvPhgGtMCtnZu2P1xbWDZQYdTYXJBmc/aLCwrZSPbtXHUWQfNBaPkJiaizXFAFGatMyVN/kKq/4u6biLaHOfRrF3rfZw/voVJmPzLqPBtE8VmOJiPQ+MaOvqtXzP4pLb/96q9jnwxkcnvPzc4LBQq37zBmfEjXU/M9R6HYu4tPyW7Worn//7+f"
_cIMG+="wwoXWcu6wwG3Tg7TkXI7kQQTuPb9R5RinmeZqhMg6F+e/F3ZXCamM9le3P8Gbyfrf6RMPpjYox52fDYaYhMo2lQut/Hwb9IBeFEzaXuuU3q2DcCBeoZ3Cm4MdV/IEvAz8rh1PtK9SzY/JwnIZzDv+FOnYRxMp2G+EH5/KHc5td7fuRNkJ9z9MBr26jucEZ6GcCJUImnihk9IK+euclRAEfmfnUI24BQvfk4"
_cIMG+="pRMQocR39wEtT8cZoD3HwZlyixRNas9Ya/xTluHWlseKjrbbpvFPd6xvsQ1Vl57qMv5pVP5Hf11bGx14AiF+DkT8KzPpptaGuqw6frohEj/p5e+/Wvz0HFCuxCGJ5v32rV0iwnCibt+JGD/A0Z/+U/eifyac+opt06a3sCkeMpnX63BEIRq7oFfXI5xvz/9e8PXj4DT8MJv6BPN127Zz77jcBMAtGlw/L1K"
_cIMG+="jdzbh8LDuHszC3UfCamPjNPsMy/Sgo/q8cPhR/JPBcVNkjt4J8eP5CNvqD79aOE6PApOlTuYqcfQBN3hGZuvXZ/0CGRVFAZOus+fW4cxdq1c61RWcHzPfrJCb+aBSqw3HOcBksIi5Fe/EQzycNjzKrGsnHlIoMrfZ/fia+Jnfsn7k19KD4TgZ8WPnsqMs2+/rd5paBHZ/TnZbvKrdmGHnCs8ufn71issnNfY"
_cIMG+="hMMDnE2q2zmAjHK53MPeH8ZvPXmyyi/YvsOqB84MjNVU7/Pnvw+vlZfcVKkXo789/IZy5X0/VzXPCYffT1ryuFOcHd9kXv6se54qFrOJPu4Tz8tyqp8L9549tcOTrw8PvOT8ZRgpM8oeFDKIK9NuLPzU9Z85zm9S7VIk0v+E4pN92Ezvn3PFzVmSknvUVl09ajSrQO783k240GhUMZ4FabYxh0U98vuVUQ7"
_cIMG+="oI6wMsDjP8cO+U9p8X4h9h/Tavm0zW3Fo/NeFIK0jV4VD3lGwEjjog2n9eCDsY292OF1NTwSUXrHaC9lM3xNPhkDuH9kHEGWr4samfb6/BtSE9Fq/6NK1E+2AtjlieNftpesbdHzDp3Po3xhz4ccbeGfcKDuydWrjE7QPd2DuZY187ZEUYp61dNcv7a4GqJzYpCqxJxDd8AZlnqHqLAcjajFocptOe+lXe1"
_cIMG+="mYUdVG3vtdATtuJmPr2aIC8kLz7BXRaM660Cy/0H8SZrJi9c2DhZKVwjU/krBQvV6tu/UTa4udVHqziy22cG16Ct8R0z6XTIFVlJb66YvxcKcZPDJ15SbktmR9bXEoLJ9PaC1aL6D3gbJXsguZG+PzD1MeJf6wP7BrCtxwW9512qN2KSZdVZU2wUcXlcwLaLcAPJlGcFFCHg9EO1fLzrcWPmwLq+MFSis4"
_cIMG+="V6AxS4OdYOC4DwyFt0KiubgGl7xDHzqFaOFudSuk0jeHHpj4eEtFsa1ZLtwOl7997U72P78TkbTc43Q5D8nFoux8laOuixen54UtnaVInfXxHcpwuyLv15XMvsqc5/eqdCoufDseqJm9UXc+PwWkY6XYg+fPPddem8YJ68yEqVR9ACvKDYQrFbyLIuA2IhdL/fZjkux7nfdbF1rysb4tDjhG7Wc9uN+Mkz"
_cIMG+="UETZg5h4avZgAqmFlg2K6VqCwvnC26jJh+/NldPdVesQol2GnRQI/2OyUR1b7OSPAnOLGUbcW3IW1bhPxP8LZkOPH5N+dISK/d6N5EfygF1cXXVZfCIyKdGnGT133V7Uf7cd3oKd1Y2s/v4A3UKKxy1kidNeNTTgaiwJxe9ew3rh+Fs38xrX6cjzhmfYyy9oOHOWeXvUTjYRd5ngLaYDj0Ri3OQkbdH4WB1"
_cIMG+="CaNu2IhY+hSD121xgkU3VHjQRUE4PzdilScBHHGJ5nOvuEG/qQ5neaWWeO7EbXOKOOO6FQLn51TeIoifeyD3BmzTZlJxe0cbg8gNX9PiQLOndRHinz7k7a0ZmN4+zsiEVfBgScsPk1UjHL+EhzLY8l+tQS2/fOmmFwavAccp4dFNBrvngvOTmQCQoyvekk81qeXtbctF3m8+2xiorx0vDJMHyxL/X3URhKI"
_cIMG+="vjgfxKO0m7DF5QIKWq1B6W54Qr/Z+hM8IKyHLcDEvKgLtFiDMfjqnAp46tlKOnFwTYkSCRhksdafWCjb8EWb07eVDlcoSjZ5xr0d3rGzC4Y1TIEKVylFle9yVm021lw+w8phU9Q0rIj4/ZKzJ1bWzfFJaG5QB6jycqOLxg/Sqciq5EvqPCWHmL9Q527flyp3WqWqyYtz/seyD1Mv+GJyZFUeKa24fYAh1xp"
_cIMG+="u0OFifiH2Z+hCy33ocd7oZnIlVFObbO16wKqX6DxMlpQI4Y78xcutd6H/SlPiKGQoJ9FtufcnZagFkqdpysSYKl2qnviq163cMM+18MmcW5Gsnfu06JYpYqtqB4wyAvbW0v2TDxmTutAOObz/WAnNYtfUlR1vTOYyuAiW9oumgHfXs4JiDP60Akmsq9t5x4lUTm73GVmsEnVbkpu5HdhsvOUe50lk38FARz"
_cIMG+="8z5DDhL1eOQxeDUJ3raerIiGeUtTqCIxymvooLxbraRotMm/sbIs+we5VjM10gAfmHcl+W3Cce17EbFSHcToalUdA6WBI5toUpuZhT82rq28tuE7lt2vFKZcNzTml4CoqmVMEOWn/pSuJ4CBb66KloBGWOA57fpC8prM8c1apyF8crohafWF/yCZczUt26BJuPGEUjgLDc8/cftmOcfa3pjxyl8w9voApIB"
_cIMG+="bkYY5rEFEqjvHZ93GkHePL3FwcfWFwKGtzn7k5qqCSr5dgSS+dNgRh4jzSnocX7jsePlhxpjxzwc0GOk4OzDc4H662+MZ7owOMmNx8Dca4LMoGdKhZaVKVK05tuao/bo3FC15TUtH8pv9xTwi0am2o0KR9tKUu3sPz6doHND1ZbX5tebN3l/N1TvTwZA2TBCFocdfwuIB9MJn8BeIwHdBAzp4MGPFDyfyjw"
_cIMG+="ebU5iWPoteH4h+fEYQ64ooHnu9xoo98dwgaZi6JLi2SXmF/R+dzcsnm2z3yBCbLQ3129rzpeYv+CAWKlZPvYpuhBOIp6iPUMHMsx+yuzr8KkgwMn0O9UcacJeLfmEj32AKXqDGzWa10+80YeLStMyvUSxYI9LsrGZfb3mDzvIOrlGAU3OA1sNOxXEKaqyKtKW3u4pfPwHzE8qsDKScCsGJ2sOnFVGJaRoYB"
_cIMG+="f2rdFZ8LHB+vmBNHTo9N/aE4E4ZpxnAVF4laQt7X1qfG5/yw7PNoE5OkXrc8lSqA2tPVRLcYrj4GE574RgS/hHAiISjsvQ+j+7QXF+nADe6b/gkTrTm6IqN7RGbfGMNh6pPSaPLXEZWgQXT0OaAh6p49Jl4cXT0NS48g5DceexBkg1f18DGFL91WLt6Uai5K/Uo50rk5vYwUMMJcZ67KLLjedpZd3+PRfrQ"
_cIMG+="O18EzvGyKZd6KpqRTRanulifRsQzqkJWHOne7z5BLduMwhRf2w7C2SBOE0xvkYP6XD1qWHi9ebjzvgHNhqfeqmvNKg3VVgZuxAl8rwN9B+tPqPTGB+t1s5pQ6nuQlK6p40wIv7Yh6Tmq9XFxcXH1SbhCBSFSTtihgHWzG9neLx+k3CIFizifkTn+D/f0SJCTZq1xm/DTXlHI0yj7nZB3VeHFx9e3dHCFCRq"
_cIMG+="Zc5mCFVUuiocFyhMpyL5snGCBUh76uBuOgEJeXXkGwljommhB3HRUkynUN0q0TtwKOqROY72HTg/1eIJGPD1PXFAb7+rBvxdio4WeEo4ud9f3KAVlL4rvaMLG2ibYnBx7R2R2EDkmoKUtBoVajRSd60eJNBx5DW+tI5MbKaI/ghXWmoU0repKoc0aoK+8/yxrA/ivB7SRuNRBrBNYS8qq6XatMN19Ejm4zw"
_cIMG+="Ri3xX1jvj3MvQhSiNqrTMFHioUZllfoYuTOdx/UTMasCZbvsZujBVaQU4FVj11fNqIM6xrPfEvyHOzsTPOIZJ499G0hXxUw7EmeLfRjo/h1/TvaH8gO7U6rKqQD56KD/jI5DN8fGft+rd3eOB/GQom0prENNmS4dRPIUZV0/fwiKaHgzkZwRTDrMM+BrKjyAR7R5v5bt/3hnID1AFssFpVwW90rU4e9fAz8"
_cIMG+="HuQH4QBxZqleKkG45zIOvxdSL2jp8O52e/4+ceW1FcJ3Vc79VPNhs7nEZoa4MjWQVibmtJigT4mZwHowZrCExT+Idn7oe3IXe1ntRrHZ8QET/6XvwgScw6DZ8HSPvw3EovYXonDd8aWhphmsGtr3qgB3qgB3qg/0/0f9lcJo0=:7450"

return _cIMG
