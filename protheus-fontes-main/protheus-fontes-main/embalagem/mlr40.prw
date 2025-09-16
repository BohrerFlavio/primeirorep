#INCLUDE "rwmake.ch"	
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMLR40   บ Autor ณ Mauricio Roehrs บ Data ณ  04/11/2014      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao de Pr้ - etiqueta Miudos                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Embalagem                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


User Function MLR40()

	dbselectarea('SB1')
	dbsetorder(1)

	campoA   := Space(06)  //campo do codigo do produto
	campoB 	:= Space(40)  //campo da descri็ใo do corte
	campoC 	:= 0

	_cProd 	:= Space(06) //codigo do produto
	valor2 	:= Space(40) //Descri็ใo do corte
	valor3 	:= 0         //Quantidade de etiquet

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE PRษ-ETIQUETA P/ MIUDOS"
	//vincula็ใo dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Descri็ใo Corte:" of telaimp
	@ 03,01 SAY "Quant. Etiq.:" of telaimp

	@ 01,08 MSGET campoA VAR _cProd SIZE 30,10 F3 'SB1' OF telaimp VALID  valGrupo(_cProd) //iif(!existcpo('SB1'),mlr40Clear(),.t.) .and.
	@ 02,08 SAY valor2 of telaimp
	@ 03,08 MSGET campoC VAR valor3 SIZE 20,10  OF telaimp  picture '@E 999'  VALID valor3 <= 50// quant etiqueta

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	campoA:bLostFocus := {|| mlr40Prc() }

	ACTIVATE MSDIALOG telaimp CENTERED

return

Static Function valGrupo(_prod)

	local _cGrupo  := ''  
	local _cParam  := GETMV('SI_GRPMDS')

	if empty(_prod)
		mlr40Clear()
		return .t.
	endif              

	_cGrupo := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(_prod),'B1_GRUPO')
	/*verifica se o grupo do produto ้ de miudos*/
	if !(_cGrupo $ _cParam)
		alert('Produto nใo corresponde ao grupo de produtos de miudos. Verifique se estแ utilizando a rotina correta ou entre em contato com PCP!')
		mlr40Clear()
		return .f.
	endif                                                                

return .t.

Static Function Imprime() 
	Local _Status := ''

	SB1->(dbsetorder(1))
	if !SB1->(dbseek(xfilial('SB1')+_cProd))
		alert('Produto inexistente!')	
	endif

	_status := GetMV('SI_IMPETQ2') 

	if !empty(_status)
		alert('Rotina jแ sendo utilizada pela esta็ใo: ' + _status)
		return .f.
	else
		PUTMV('SI_IMPETQ2',GetComputerName())
		Processa({||mlr40Etq() },"IMPRESSAO DE PRE-ETIQUETA","Realizando envio เ impressora...")  
		PUTMV('SI_IMPETQ2','')
	endif
return

static function mlr40Prc()

	SB1->(dbsetorder(1))
	if SB1->(dbseek(xfilial('SB1')+_cProd))
		valor2 := SB1->B1_DESCRED
	endif

	telaimp:refresh()
return

static function mlr40Clear()
	_cProd   := Space(06)
	valor2   := Space(40)
	valor3   := 0
	telaimp:refresh()
return

static Function mlr40Etq()
	Local   _nSeq   := 0
	Local  _nUltSeq := 0
	Local   _nREtq  := 0
	Local  _despor  := ''
	Local  _descod  := ''
	Local  _Data    := ''
	Local i

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


	IF SB1->(dbseek(xfilial('SB1')+alltrim(_cProd)))
		for i := 1 to valor3

			if empty(valor2)
				exit
			endif

			incproc()

			//MSCBPRINTER('S600','LPT1') - alterado por flavio

			_cIp  := ''
			_cEst := getComputerName()    
			dbselectarea('ZAM')		   
			ZAM->(dbSetOrder(2))
			if ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
				_cIp := alltrim(ZAM->ZAM_IP)
			endif	

			//se nใo achou o ip na tabela imprime pela porta paralela
			if empty(_cIp)
				MSCBPRINTER('S600','LPT1')  		
			else
				MSCBPRINTER('S600','IP',,,,,_cIp) //Impressใo por IP    		 		
			endif




			//MSCBPRINTER('S600','IP',,,,,'10.11.20.186') //Impressใo por IP
			MSCBCHKSTATUS(.f.)
			MSCBBEGIN(1,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas*/

			_despor     :=  alltrim(SB1->B1_DESCRED)
			_descod     :=  SB1->B1_COD
			_Data       :=  DTOC(date())
			fontedesc   :=  "38,40"
			fontedesc1  :=  "55,23"
			fontedesc2  :=  "35,40"
			fontedesc3  :=  "20,20"
			_nCont      :=  0
			_nX         :=  7
			_nX2        :=  2


			while  _nCont < 2
				if _nCont <> 0
					_nX += 53
					_nX2 += 52				
				endif

				if  _nCont == 0
					_nX  := 3
					_nX2 := 3
				endif

				_cNum := GetSx8num('ZZP','ZZP_NUM')
				ConfirmSX8()

				_cCod   :=  substr(_descod,1,06) + space(03) + _cNum			
				MSCBSAY(_nX+1,7,substr(_despor,1,18),"N","0",fonteDesc)		
				//MSCBSAYBAR(_nX2+9,6,alltrim(_cNum),"N","MB07",18,.F.,.F.,,,3,01,.T.)  //Cod de Barras 
				MSCBSAYBAR(_nX2+9,12,alltrim(_cNum),"N","C",29,.F.,.F.,,,3,08,.T.)
				MSCBSAY(_nX-1,45,_cCod,"N","0",fonteDesc2)
				MSCBSAY(_nX+02,20,_Data,"B","0",fonteDesc3)
				_nCont++ 

				reclock('ZZP',.t.)
				ZZP->ZZP_FILIAL   := xFilial('ZZP')
				ZZP->ZZP_NUM 		:= _cNum	
				ZZP->ZZP_PROD  	:= _cProd
				ZZP->ZZP_DTIMP 	:= date()
				msunlock()
			enddo		

			MSCBEND()
			MSCBCLOSEPRINTER()

			if mod(i,10) = 0
				sleep(1500)
			endif		
		next

		mlr40Clear()

		msgbox('Impressใo de Etiquetas em Andamento!','Impressใo','INFO')


		_nSeq := 0
		campoA:enable()
		campoC:enable()
		btn1:enable()
		telaimp:refresh()

	endif

return    
