#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFFM01   บ Autor ณ Fabian Maurer บ Data ณ  02/06/11          บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao de Pr้ - etiqueta Embalagem                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Embalagem                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function FFM01()

	dbselectarea('SB1')
	dbsetorder(1)

	campoA   := Space(06)  //campo do codigo do produto
	campoB 	:= Space(40)  //campo da descri็ใo do corte
	campoC 	:= 0
	//campoD	:= {'Dupla','Tripla','Vertical'}
	campoE   := stod('')                   

	valor1 	:= Space(06) //codigo do produto
	valor2 	:= Space(40) //Descri็ใo do corte
	valor3 	:= 0         //Quantidade de etiquet
	valor4   := Space(07) //Disposi็ใo etiqueta
	valor5   := stod('')  //data de abate

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE PRษ-ETIQUETA P/ DESOSSA"
	//vincula็ใo dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Descri็ใo Corte:" of telaimp
	@ 03,01 SAY "Quant. Etiq.:" of telaimp
	@ 04,01 SAY "Data de Abate:" of telaimp
	//@ 05,01 SAY "Disp. Etiqueta:" of telaimp


	@ 01,08 MSGET campoA VAR valor1 SIZE 30,10 F3 'SB1' OF telaimp VALID valGrupo(valor1) //iif(!existcpo('SB1'),ffm01clear(),.t.) .and.
	@ 02,08 SAY valor2 of telaimp
	@ 03,08 MSGET campoC VAR valor3 SIZE 20,10  OF telaimp  picture '@E 999'   VALID valor3 <= 50// quant etiqueta
	@ 04,08 MSGET campoE VAR valor5 SIZE 30,10  OF telaimp  picture '99/99/99' VALID !Vazio()//Data de Abate
	//@ 05,08 COMBOBOX valor4 items campoD SIZE 40,10 of telaimp  // Disposicao da etiqueta Dupla ou Tripla

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	campoA:bLostFocus := {|| ffm01prc() }

	ACTIVATE MSDIALOG telaimp CENTERED

return

Static Function valGrupo(_prod)

	local _cGrupo 	:= ''
	local _cParam  := GETMV('SI_GRPMDS')

	if empty(_prod)
		ffm01clear()
		return .t.
	endif

	_cGrupo := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(_prod),'B1_GRUPO')

	/*rela็ใo dos grupos de miudos*/
	if (_cGrupo $ _cParam)//se entrar aqui ้ pq o produto ้ de miudos e nใo pode ser impressa a etiqueta
		alert('Produto nใo corresponde ao grupo de produtos de desossa. Verifique se estแ utilizando a rotina correta ou entre em contato com PCP!')
		ffm01clear()
		return .f.
	endif

return .t.

Static Function Imprime()
	Local _Status := ''

	_status := GetMV('SI_IMPPETQ')

	if !empty(_status)
		alert('Rotina jแ sendo utilizada pela esta็ใo: ' + _status)
		return .f.
	else
		PUTMV('SI_IMPPETQ',GetComputerName())
		Processa({||ffm01etq() },"IMPRESSAO DE PRE-ETIQUETA","Realizando envio เ impressora...")
		PUTMV('SI_IMPPETQ','')
	endif
return

static function ffm01prc()

	SB1->(dbsetorder(1))
	if SB1->(dbseek(xfilial('SB1')+valor1))
		valor2 := SB1->B1_DESCRED
	else
		alert('Produto inexistente!')
	endif

	telaimp:refresh()
return

static function ffm01clear()
	valor1   := Space(06)
	valor2   := Space(40)
	valor3   := 0
	valor4   := 'Dupla'
	telaimp:refresh()
return

static Function ffm01etq()
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


	IF SB1->(dbseek(xfilial('SB1')+alltrim(valor1)))
		for i := 1 to valor3

			if empty(valor2)
				exit
			endif

			incproc()

			MSCBPRINTER('S600','LPT1')
			//MSCBPRINTER('S600','IP',,,,,'10.11.20.202') //Impressใo por IP
			MSCBCHKSTATUS(.f.)
			MSCBBEGIN(1,4,50)  // Usar variavel no primeiro campo, para a quantidade de etiquetas

			_despor     :=  alltrim(SB1->B1_DESCRED)
			_descod     :=  SB1->B1_COD
			_Data       :=  DTOC(ddatabase)    
			_dtAbt		:=  DTOC(valor5)
			fontedesc   :=  "38,40"
			fontedesc1  :=  "55,23"
			fontedesc2  :=  "41,27"
			fontedesc3  :=  "20,20"
			fontedesc4  :=  "35,40"
			_nCont      :=  0
			_nX         :=  7
			_nX2        :=  5


			//if valor4 = 'Dupla'    // Monta etiqueta impressa Dupla

			while  _nCont < 2
				if _nCont <> 0
					_nX += 53
					_nX2 += 52

				endif

				if  _nCont == 0
					_nX  := 3
					_nX2 := 6
				endif


				_nSeq := GetSx8num('ZZR','ZZR_NUM')
				ConfirmSX8()
				_cCod   :=  substr(_descod,1,6)

				MSCBSAY(_nX-3,2,substr(_despor,1,18),"N","0",fonteDesc)
				MSCBSAYBAR(_nX2+1,7,alltrim(_nSeq),"N","MB07",18,.F.,.F.,,,3,01,.T.)  //Cod de Barras

				//MSCBSAY(_nX+10,26,_cCod,"N","0",fonteDesc4)
				//MSCBSAY(_nX+28,26,alltrim(_nSeq),"N","0",fonteDesc2)
				MSCBSAY(_nX+5,26,_cCod,"N","0",fonteDesc4)				
				MSCBSAY(_nX+22,26,alltrim(_nSeq),"N","0",fonteDesc2)

				MSCBSAY(_nX+00,11,_Data,"B","0",fonteDesc3)
				MSCBSAY(_nX+43,08,"Dt. Abate "+_dtAbt,"B","0",fonteDesc3)
				_nCont++

				reclock('ZZR',.t.)          
				ZZR->ZZR_FILIAL := xFilial('ZZR')
				ZZR->ZZR_NUM 	 := _nSeq
				ZZR->ZZR_COD 	 := _descod
				ZZR->ZZR_DTABT  := valor5
				ZZR->ZZR_UTIL   := 'N'
				ZZR->ZZR_DTIMP  := date()
				msunlock()

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

		ffm01clear()

		msgbox('Impressใo de Etiquetas em Andamento!','Impressใo','INFO')

		_nSeq := 0
		campoA:enable()
		campoC:enable()
		btn1:enable()
		telaimp:refresh()

	endif

return
