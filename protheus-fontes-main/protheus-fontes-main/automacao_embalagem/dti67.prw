#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI67  บ Autor ณ Fabian Maurer บ Data ณ  20/08/18           บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao de Etiqueta do Charque - Prod./Valid.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Almoxarifado/Charque                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function dti67()

	Private _cOpera     := UsrRetName(retCodUsr())    
    Private DtaMin7   := DDATABASE-7
    Private DtaMin14  := DDATABASE-14
    Private DtaMin30  := DDATABASE-30
    Private DtaMin365 := DDATABASE-365
    Private DtaMax7   := DDATABASE+7
    Private DtaMax14  := DDATABASE+14
    Private DtaMax30  := DDATABASE+30
    Private DtaMax365 := DDATABASE+365

	campoA  := stod('')  
	campoB 	:= stod('')  
	campoC 	:= 0

	dtEst 	  := stod('')  //Data de estufa
	dtProd 	  := stod('')
	dtVal 	  := stod('')
	qtdEtq 	  := 0         //Quantidade de etiqueta

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA CHARQUE PROD./VALID."
	//vincula็ใo dos campos com os valores

	@ 01,01 SAY "Data de Estufa:" of telaimp
	@ 02,01 SAY "Data de Produ็ใo:" of telaimp
	@ 03,01 SAY "Data de Validade:" of telaimp
	@ 04,01 SAY "Quant. Etiq.:" of telaimp

	@ 01,08 MSGET campoA VAR dtEst SIZE 30,10  OF telaimp picture '99/99/99' VALID valDtEst()
	@ 02,08 MSGET campoB VAR dtProd SIZE 30,10 OF telaimp picture '99/99/99' VALID valDtProd()
	@ 03,08 SAY dtVal of telaimp picture '99/99/99'
	@ 04,08 MSGET campoC VAR qtdEtq SIZE 20,10  OF telaimp  picture '@E 999' VALID qtdEtq <= 50// quant etiqueta

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	campoB:bLostFocus := {|| dti67prc() }

	ACTIVATE MSDIALOG telaimp CENTERED

return

Static Function Imprime()
	Processa({||dti67etq() },"IMPRESSAO DE PRE-ETIQUETA","Realizando envio เ impressora...")	
return

static function valDtEst()
	if empty(dtEst)
		FWAlertError("Data de estufa deve ser preenchida!", "ERRO!")
		Return .F.
	endif

	IF ((_cOpera $ GetMV('SI_USRN1')) .OR. (_cOpera $ GetMV('SI_USRN2')) .OR. (_cOpera $ GetMV('SI_USRN3')) .OR. (_cOpera $ GetMV('SI_USRN4')))
		IF ((_cOpera $ GetMV('SI_USRN1')))
			IF (dtEst < DtaMin365)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de estufa anterior a 1 (um) ano","Aviso")
				RETURN .F.
			ENDIF
		ELSEIF ((_cOpera $ GetMV('SI_USRN2')))
			IF (dtEst < DtaMin30)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de estufa anterior a 30 (trinta) dias","Aviso")
				RETURN .F.
			ENDIF
		ELSEIF ((_cOpera $ GetMV('SI_USRN3')))
			IF (dtEst < DtaMin14)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de estufa anterior a 14 (quatorze) dias","Aviso")
				RETURN .F.
			ENDIF
		ELSEIF ((_cOpera $ GetMV('SI_USRN4')))
			IF (dtEst < DtaMin7)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de estufa anterior a 7 (sete) dias","Aviso")
				RETURN .F.
			ENDIF
		ENDIF
	ELSE
		IF ((_cOpera $ GetMV('SI_USRN1.1')))
			IF (dtEst < DtaMin365)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de estufa anterior a 1 (um) ano","Aviso")
				RETURN .F.
			ENDIF
		ELSEIF ((_cOpera $ GetMV('SI_USRN2.1')))
			IF (dtEst < DtaMin30)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de estufa anterior a 30 (trinta) dias","Aviso")
				RETURN .F.
			ENDIF
		ELSEIF ((_cOpera $ GetMV('SI_USRN3.1')))
			IF (dtEst < DtaMin14)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de estufa anterior a 14 (quatorze) dias","Aviso")
				RETURN .F.
			ENDIF
		ELSE
			IF (dtEst < DDATABASE-7)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de estufa com mais de 7 dias","Aviso")
				RETURN .F.
			ENDIF
		ENDIF
	ENDIF
return .T.

static function valDtProd()
	if empty(dtProd)
		FWAlertError("Data de produ็ใo deve ser preenchida!", "ERRO!")
		Return .F.
	endif

	IF ((_cOpera $ GetMV('SI_USRN1')) .OR. (_cOpera $ GetMV('SI_USRN2')) .OR. (_cOpera $ GetMV('SI_USRN3')) .OR. (_cOpera $ GetMV('SI_USRN4')))
		IF ((_cOpera $ GetMV('SI_USRN1')))
			IF (dtProd > DtaMax365)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de produ็ใo superior a 1 (um) ano","Aviso")
				RETURN .F.
			ENDIF
		ELSEIF ((_cOpera $ GetMV('SI_USRN2')))
			IF (dtProd > DtaMax30)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de produ็ใo superior a 30 (trinta) dias","Aviso")
				RETURN .F.
			ENDIF
		ELSEIF ((_cOpera $ GetMV('SI_USRN3')))
			IF (dtProd > DtaMax14)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de produ็ใo superior a 14 (quatorze) dias","Aviso")
				RETURN .F.
			ENDIF
		ELSEIF ((_cOpera $ GetMV('SI_USRN4')))
			IF (dtProd > DtaMax7)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de produ็ใo superior a 7 (sete) dias","Aviso")
				RETURN .F.
			ENDIF
		ENDIF
	ELSE
		IF ((_cOpera $ GetMV('SI_USRN1.1')))
			IF (dtProd <> DDATABASE)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de produ็ใo diferente do dia atual","Aviso")
				RETURN .F.
			ENDIF
		ELSEIF ((_cOpera $ GetMV('SI_USRN2.1')))
			IF (dtProd <> DDATABASE)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de produ็ใo diferente do dia atual","Aviso")
				RETURN .F.
			ENDIF
		ELSEIF ((_cOpera $ GetMV('SI_USRN3.1')))
			IF (dtProd <> DDATABASE)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de produ็ใo diferente do dia atual","Aviso")
				RETURN .F.
			ENDIF
		ELSE
			IF (dtProd <> DDATABASE)
				MsgAlert("Voc๊ nใo pode imprimir etiquetas com data de produ็ใo diferente do dia atual","Aviso")
				RETURN .F.
			ENDIF
		ENDIF
	ENDIF

return .T.

static function dti67prc()
	dtVal := dtProd +120
	telaimp:refresh()
return

static function dti67clear()
	dtEst    := stod('')
	dtProd   := stod('')
	dtVal    := stod('')
	qtdEtq   := 0
	telaimp:refresh()
return

static Function dti67etq()

	Local _dtEst  := ''
	Local _dtProd := ''
	Local _dtVal  := ''
	Local i

	campoA:disable()
	campoB:disable()
	campoC:disable()
	btn1:disable()
	telaimp:refresh()

	ProcRegua(qtdEtq)

	_cEst := getComputerName()
	_cIp  := ''

	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	if ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	endif

	for i := 1 to qtdEtq

		incproc()

		//MSCBPRINTER('S600','LPT1')
		MSCBPRINTER('S600','IP',,,,,_cIp) //Impressใo por IP
		//MSCBPRINTER('S600','IP',,,,,'10.11.20.139') //Impressใo por IP
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(1,4,50)  // Usar variavel no primeiro campo, para a quantidade de etiquetas

		_dtProd     := dtoc(dtProd)
		_dtEst		:= dtoc(dtEst)
		_dtVal      := dtoc(dtProd + 120)

		fontedesc   :=  "35,30"
		_nX         :=  7

		//Etiqueta 1
		MSCBSAY(_nX-6,5, "Estufa:    "+_dtEst, "N","0",fontedesc)
		MSCBSAY(_nX-6,10,"Prod/Lote: "+_dtProd,"N","0",fontedesc)
		MSCBSAY(_nX-6,15,"Validade:  "+_dtVal, "N","0",fontedesc)
		//Etiqueta 2
		MSCBSAY(_nX-44,5, "Estufa:    "+_dtEst, "N","0",fontedesc)
		MSCBSAY(_nX-44,10,"Prod/Lote: "+_dtProd,"N","0",fontedesc)
		MSCBSAY(_nX-44,15,"Validade:  "+_dtVal, "N","0",fontedesc)
		//Etiqueta 3
		MSCBSAY(_nX-80,5, "Estufa:    "+_dtEst, "N","0",fontedesc)
		MSCBSAY(_nX-80,10,"Prod/Lote: "+_dtProd,"N","0",fontedesc)
		MSCBSAY(_nX-80,15,"Validade:  "+_dtVal, "N","0",fontedesc)

		/*
		cRota็ใo  = String com o tipo de Rota็ใo (N,R,I,B)
		N-Normal
		R-Cima p/baixo
		I-Invertido
		B-Baixo p/ Cima
		*/

		MSCBEND()
		MSCBCLOSEPRINTER()

		if mod(i,10) = 0
			sleep(1500)
		endif
	next

	dti67clear()

	msgbox('Impressใo de Etiquetas em Andamento!','Impressใo','INFO')

	_nSeq := 0
	campoA:enable()
	campoB:enable()
	campoC:enable()
	btn1:enable()
	telaimp:refresh()

return
