#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI31   บ Autor ณ Flแvio Bohrer Fl๔res บ Data ณ  11/04/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao de Etiqueta Porcionados                          บฑฑ
ฑฑบ          ณ OBS - Etiquetas SKin (Layout da grแfica)	   			     บฑฑ
ฑฑบ          ณ Em substitui็ใo ao fonte dti23                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Porcionados                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function dti31()

	dbselectarea('SB1')
	dbsetorder(1)

	campoA   := Space(06)  //campo do codigo do produto
	campoB 	:= Space(40)  //campo da descri็ใo do corte
	campoC 	:= 0
	campoE   := stod('')                   

	valor1 	:= Space(06) //codigo do produto
	valor2 	:= Space(40) //Descri็ใo do corte
	valor3 	:= 0         //Quantidade de etiquet
	valor4 	:= 0        //Tara informada Manual
	valor5   := date()  //data de Produ็ใo

	valor11 	:='CARNE RESFRIADA DE BOVINO S/OSSO'

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE PRษ-ETIQUETA P/ Porcionados"
	//vincula็ใo dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Descri็ใo Corte:" of telaimp
	@ 03,01 SAY "Quant. Etiq.:" of telaimp
	@ 04,01 SAY "Data de Produ็ใo:" of telaimp

	@ 01,08 MSGET campoA VAR valor1 SIZE 30,10 F3 'SB1' OF telaimp VALID valGrupo(valor1) //iif(!existcpo('SB1'),ffm01clear(),.t.) .and.
	@ 02,08 SAY valor2 of telaimp
	@ 03,08 MSGET campoC VAR valor3 SIZE 20,10  OF telaimp  picture '@E 999'   VALID valor3 <= 50// quant etiqueta
	@ 04,08 MSGET campoE VAR valor5 SIZE 30,10  OF telaimp  picture '99/99/99' VALID !Vazio()//Data de Produ็ใo

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	campoA:bLostFocus := {|| dti31prc() }

	ACTIVATE MSDIALOG telaimp CENTERED

return

Static Function valGrupo(_prod)

	if empty(_prod)
		dti31clear()
		return .t.
	endif

return .t.

Static Function Imprime()
	Processa({||dti31etq() },"IMPRESSAO DE PRE-ETIQUETA","Realizando envio เ impressora...")

return

static function dti31prc()

	SB1->(dbsetorder(1))
	if SB1->(dbseek(xfilial('SB1')+valor1))
		valor2 := SB1->B1_DESCRED
		_nDval := SB1->B1_VALID  // Trocar parS
	else
		alert('Produto inexistente!')
	endif

	telaimp:refresh()
return

static function dti31clear()

	valor1   := Space(06)
	valor2   := Space(40)
	valor3   := 0
	telaimp:refresh()
return

static Function dti31etq()
	//Local  _despor  := ''
	Local  _descod  := ''
	//Local  _Data    := ''
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
			
			if alltrim(_cEst) == 'PEM01' .or. alltrim(_cEst) == 'PEM02' .or. alltrim(_cEst) == 'PEM03' .or. alltrim(_cEst) == 'DTI03'
				IF _cEst = 'PEM01'					
					_cIp := alltrim(POSICIONE('ZAM',1,FWXFilial('ZAM')+'PEM01','ZAM_IP'))	
					MSGINFO("O PC " + _cEst + " VAI IMPRIMIR E MANDAR PARA O IP " + _cIp ,"")
				ELSEIF _cEst = 'PEM02'
					_cIp := alltrim(POSICIONE('ZAM',1,FWXFilial('ZAM')+'PEM02','ZAM_IP'))	
					MSGINFO("O PC " + _cEst + " VAI IMPRIMIR E MANDAR PARA O IP " + _cIp ,"")
				ELSEIF _cEst = 'PEM03'					
					_cIp := alltrim(POSICIONE('ZAM',1,FWXFilial('ZAM')+'PEM03','ZAM_IP'))
					MSGINFO("O PC " + _cEst + " VAI IMPRIMIR E MANDAR PARA O IP " + _cIp ,"")				
				ELSEIF _cEst = 'DTI03'					
					_cIp := alltrim(POSICIONE('ZAM',1,FWXFilial('ZAM')+'DTI03','ZAM_IP'))
					MSGINFO("O PC " + _cEst + " VAI IMPRIMIR E MANDAR PARA O IP " + _cIp ,"")
				ENDIF
				MSCBPRINTER('S600','IP',,,,,_cIp) //Impressใo por IP
			else
				MSCBPRINTER('S600','LPT1')
			endif  

			MSCBCHKSTATUS(.f.)		
			MSCBBEGIN(1,4,50)  

			_descred    :=  alltrim(SB1->B1_DESCRED)
			_descsif    :=  alltrim(SB1->B1_DESCSIF)
			_descod     :=  alltrim(SB1->B1_COD)
			_dtProd		:=  valor5
			_metq2      :=  alltrim(SB1->B1_MENETQ2)
			_DataVal    :=  valor5+SB1->B1_VALID
			_metq4	   :=  alltrim(SB1->B1_MENETQ4)

			_cfdesc   :=  "30,30"		
			_cfdesc1  :=  "20,20" 
			_cfdesc2  :=  "36,38"
			_cfdesc3  :=  "18,18" 

			MSCBSAY(4,4,substr(_descsif,1,53),"N","0",_cfdesc1)
			MSCBSAY(4,10,substr(_descred,1,35),"N","0",_cfdesc)
			MSCBSAY(14,17,DTOC(_dtProd),"N","0",_cfdesc2) 
			MSCBSAY(41,16,substr(_metq2,1,18),"N","0",_cfdesc3)
			MSCBSAY(41,19,substr(_metq2,19,20),"N","0",_cfdesc3)
			MSCBSAY(16,24,DTOC(_DataVal),"N","0",_cfdesc2)   

			// Ajuste de Tara a Pedido de Lucin้ia para b,uscar do cadastro do Produto (Flแvio - 08/05)  
			_nTaraP := FBuscaCPO('SB1',1,xfilial('SB1')+_descod,'B1_CTARAP')      // Linhas inseridas para buscar"_NTARAp"
			valor4   := FBuscaCPO('ZAB',1,xfilial('ZAB')+alltrim(_nTaraP),'ZAB_TARA')  // os campos de codigo das taras primarias		
			MSCBSAY(61,24,transform(valor4,'@E 9.999')+space(1)+'Kg',"N","0",_cfdesc)      
			MSCBSAY(4,30,"Registro no Minist้rio da Agricultura SIF/DIPOA/sob"+space(2)+_metq4,"N","0",_cfdesc3)

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

		dti31clear()

		msgbox('Impressใo de Etiquetas em Andamento!','Impressใo','INFO')

		_nSeq := 0
		campoA:enable()
		campoC:enable()
		btn1:enable()
		telaimp:refresh()

	endif

return

