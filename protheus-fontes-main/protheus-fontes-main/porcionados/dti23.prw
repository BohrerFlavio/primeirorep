#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI23   บ Autor ณ Flแvio Bohrer Fl๔res บ Data ณ  20/02/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao de Etiqueta Porcionados                          บฑฑ
ฑฑบ          ณ OBS - Etiquetas SKin												     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Porcionados                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function dti23()

	dbselectarea('SB1')
	dbsetorder(1)

	campoA   := Space(06)  //campo do codigo do produto
	campoB 	:= Space(40)  //campo da descri็ใo do corte
	campoC 	:= 0
	campoE   := stod('')                   

	valor1 	:= Space(06) //codigo do produto
	valor2 	:= Space(40) //Descri็ใo do corte
	valor3 	:= 0         //Quantidade de etiquet
	valor4 	:= 0         //Tara informada Manual
	valor5   := date()  //data de Produ็ใo

	valor11 	:='CARNE RESFRIADA DE BOVINO S/OSSO'

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE PRษ-ETIQUETA P/ Porcionados"
	//vincula็ใo dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Descri็ใo Corte:" of telaimp
	@ 03,01 SAY "Quant. Etiq.:" of telaimp
	@ 04,01 SAY "Data de Produ็ใo:" of telaimp
	@ 05,01 SAY "Tara:" of telaimp

	@ 01,08 MSGET campoA VAR valor1 SIZE 30,10 F3 'SB1' OF telaimp VALID valGrupo(valor1) //iif(!existcpo('SB1'),ffm01clear(),.t.) .and.
	@ 02,08 SAY valor2 of telaimp
	@ 03,08 MSGET campoC VAR valor3 SIZE 20,10  OF telaimp  picture '@E 999'   VALID valor3 <= 50// quant etiqueta
	@ 04,08 MSGET campoE VAR valor5 SIZE 30,10  OF telaimp  picture '99/99/99' VALID !Vazio()//Data de Produ็ใo
	@ 05,08 MSGET nTara  VAR valor4 SIZE 40,10  OF telaimp  PICTURE '@E 999'   VALID !Vazio()

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	campoA:bLostFocus := {|| dti23prc() }

	ACTIVATE MSDIALOG telaimp CENTERED

return

Static Function valGrupo(_prod)

	if empty(_prod)
		dti23clear()
		return .t.
	endif

return .t.

Static Function Imprime()
	Processa({||dti23etq() },"IMPRESSAO DE PRE-ETIQUETA","Realizando envio เ impressora...")

return

static function dti23prc()

	SB1->(dbsetorder(1))
	if SB1->(dbseek(xfilial('SB1')+valor1))
		valor2 := SB1->B1_DESCRED
		_nDval := SB1->B1_VALID  // Trocar para 
	else
		alert('Produto inexistente!')
	endif

	telaimp:refresh()
return

static function dti23clear()

	valor1   := Space(06)
	valor2   := Space(40)
	valor3   := 0
	telaimp:refresh()
return

static Function dti23etq()


	Local  _despor  := ''
	Local  _descod  := ''
	Local  _Data    := ''
	Local i
	_cEst := getComputerName() 
	campoA:disable()
	campoC:disable()
	btn1:disable()
	telaimp:refresh()

	if empty(valor2)
		return .f.
	endif

	ProcRegua(valor3)

	DbSelectArea('SB1')
	SB1->(dbsetorder(1))


	IF SB1->(dbseek(xfilial('SB1')+alltrim(valor1)))
		for i := 1 to valor3

			if empty(valor2)
				exit
			endif

			incproc()

			//MSCBPRINTER('S600','LPT1')
			//MSCBPRINTER('S600','IP',,,,,'10.11.20.25') //Impressใo por IP

			if alltrim(_cEst) == 'PCA02' .or. alltrim(_cEst) == 'PEX01' .or. alltrim(_cEst) == 'PEM01'
				//_cIp := alltrim(fBuscaCpo('ZAM',1,xFilial('ZAM')+'PEM01','ZAM_IP'))
				/*// Solicitado a troca da impressใo pela Lucin้ia dia 28/08/2017 para imprimir na linha 2*/	
				_cIp := alltrim(fBuscaCpo('ZAM',1,xFilial('ZAM')+'BKPOR','ZAM_IP'))
				MSCBPRINTER('S600','IP',,,,,_cIp) //Impressใo por IP
			else
				MSCBPRINTER('S600','LPT1')
			endif  


			MSCBCHKSTATUS(.f.)		
			MSCBBEGIN(1,4,50)  

			_despor     :=  alltrim(SB1->B1_DESCRED)
			_descod     :=  alltrim(SB1->B1_COD)
			_DataVal    :=  valor5+SB1->B1_VALID
			_dtProd		:=  valor5   

			fontedesc   :=  "41,43"		
			fontedesc1  :=  "55,23"
			fontedesc2  :=  "35,40"
			fontedesc3  :=  "23,23" // datas e Tara
			fontedesc4  :=  "25,18" //valor11
			fontedesc5  :=  "36,38"
			_nCont      :=  0
			_nX         :=  0 //7
			_nX2        :=  0 //5



			while  _nCont < 2
				if _nCont <> 0
					_nX += 55 //53
					_nX2 += 52
				endif

				if  _nCont == 0
					_nX  := 3
					_nX2 := 6
				endif


				MSCBSAY(_nX-2,4,substr(_despor,1,18),"N","0",fontedesc)
				MSCBSAY(_nX-2,9,valor11,"N","0",fontedesc3)
				MSCBSAY(_nX-2,17,"Data Producao: "+DTOC(_dtProd),"N","0",fontedesc5)
				MSCBSAY(_nX-2,24,"Data Validade: "+DTOC(_DataVal),"N","0",fontedesc5)
				MSCBSAY(_nX-2,31,"Tara: "+transform(valor4,'@E 999')+ 'Gr',"N","0",fontedesc5)

				_nCont++

			enddo


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

		dti23clear()

		msgbox('Impressใo de Etiquetas em Andamento!','Impressใo','INFO')

		_nSeq := 0
		campoA:enable()
		campoC:enable()
		btn1:enable()
		telaimp:refresh()

	endif

return

