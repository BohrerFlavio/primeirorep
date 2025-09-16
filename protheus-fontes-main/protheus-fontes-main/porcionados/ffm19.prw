#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFFM19   บ Autor ณ Fabian Maurer บ Data ณ  23/03/16          บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao de Etiqueta Porcionados para Identificar Caixas  บฑฑ
ฑฑบ          ณ de Sobra de Produ็ใo dentro das Cameras                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Porcionados                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function FFM19()

	dbselectarea('SB1')
	dbsetorder(1)

	campoA  := Space(10)  // Campo do Codigo do Lote
	campoB 	:= Space(06)  // Campo do Codigo do Produto
	campoC 	:= Space(40)  // Campo da Descri็ใo do Corte
	campoD  := stod('')   // Data do Abate
	campoE  := stod('')   // Data de Validade
	campoF 	:= 0          // Quantidade de Etiqueta             

	valor1 	:= Space(10)  // Codigo do Lote
	valor2 	:= Space(06)  // Codigo do Produto
	valor3 	:= Space(40)  // Descri็ใo do Corte
	valor4   := stod('')  // Data de Abate
	valor5   := stod('')  // Data de Validade 
	valor6 	:= 0          // Quantidade de Etiqueta

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE PRษ-ETIQUETA P/ DESOSSA"
	//vincula็ใo dos campos com os valores

	@ 01,01 SAY "Lote:" of telaimp
	@ 02,01 SAY "Produto:" of telaimp
	@ 03,01 SAY "Descri็ใo Produto:" of telaimp
	@ 04,01 SAY "Data de Abate:" of telaimp
	@ 05,01 SAY "Data de Validade:" of telaimp
	@ 06,01 SAY "Quant. Etiq.:" of telaimp

	@ 01,08 MSGET campoA VAR valor1 SIZE 30,10 F3 'ZAU' OF telaimp 
	@ 02,08 SAY valor2 of telaimp
	@ 03,08 SAY valor3 of telaimp
	@ 04,08 SAY valor4 of telaimp
	@ 05,08 SAY valor5 of telaimp
	//@ 04,08 MSGET campoE VAR valor4 SIZE 30,10  OF telaimp  picture '99/99/99' VALID !Vazio()//Data de Abate
	//@ 05,08 MSGET campoE VAR valor5 SIZE 30,10  OF telaimp  picture '99/99/99' VALID !Vazio()//Data de Validade
	@ 06,08 MSGET campoF VAR valor6 SIZE 20,10  OF telaimp  picture '@E 999'   VALID valor6 <= 50// quant etiqueta

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	campoA:bLostFocus := {|| ffm19prc() }

	ACTIVATE MSDIALOG telaimp CENTERED

return


Static Function Imprime()

	Processa({||ffm19etq() },"IMPRESSAO DE ETIQUETA","Realizando envio เ impressora...")

return

static function ffm19prc()

	ZAU->(dbsetorder(1))
	if ZAU->(dbseek(xfilial('ZAU')+valor1))
		valor2 := ZAU->ZAU_COD
		valor3 := ZAU->ZAU_DESC
		valor4 := ZAU->ZAU_DTPROD
		valor5 := ZAU->ZAU_IMVAL
	else
		alert('Lote Inexistente!')
	endif

	telaimp:refresh()
return

static function ffm19clear()
	valor1 	:= Space(10)  // Codigo do Lote
	valor2 	:= Space(06)  // Codigo do Produto
	valor3 	:= Space(40)  // Descri็ใo do Corte
	valor4   := stod('')  // Data de Abate
	valor5   := stod('')  // Data de Validade 
	valor6 	:= 0          // Quantidade de Etiqueta
	telaimp:refresh()
return

static Function ffm19etq()
	Local  _DescLote  := valor1
	Local  _DescCod   := valor2
	Local  _Descri    := valor3
	Local  _DtProd    := valor4
	Local  _DtVal     := valor5
	Local i

	campoA:disable()
	btn1:disable()
	telaimp:refresh()

	if empty(valor1)
		return .f.
	endif

	ProcRegua(valor6)

	DbSelectArea('ZAU')
	ZAU->(dbsetorder(1))


	IF ZAU->(dbseek(xfilial('ZAU')+alltrim(valor1)))
		for i := 1 to valor6

			if empty(valor1)
				exit
			endif

			incproc()

			//MSCBPRINTER('S600','LPT1')
			//MSCBPRINTER('S600','IP',,,,,'10.7.0.58') //Impressใo por IP
			
			
			_cEst := getComputerName()
			_cIp  := ''
			
			dbselectarea('ZAM')
			ZAM->(dbSetOrder(2))
			if ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
				_cIp := alltrim(ZAM->ZAM_IP)
			endif
			
			MSCBPRINTER('S600','IP',,,,,_cIp)
			
			MSCBCHKSTATUS(.f.)
			MSCBBEGIN(1,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas

			_DescLote   :=  alltrim(valor1)
			_DescCod    :=  alltrim(valor2)
			_Descri     :=  alltrim(valor3)
			_DtProd     :=  valor4    
			_DtVal		:=  valor5
			fontedesc   :=  "60,60"
			fontedesc1  :=  "60,60"
			fontedesc2  :=  "60,60"
			fontedesc3  :=  "60,60"
			_nCont      :=  0
			_nX         :=  7
			_nX2        :=  5

			if  _nCont == 0
				_nX  := 3
				_nX2 := 6
			endif

			// Monta etiqueta impressa
			//	_cCorte :=  substr("("+_despor,1,18)+")"

			// nx=sobe-/desce+,esquerda+/direita-
			_cCod   :=  substr(_DescCod,1,06)+space(06)
			MSCBSAY(_nX+5,93,"Cod. Lote:","B","0",fonteDesc3)
			MSCBSAY(_nX+5,55,_DescLote,"B","0",fonteDesc3)				
			MSCBSAY(_nX+15,83,"Cod. Produto:","B","0",fonteDesc3)   
			MSCBSAY(_nX+15,60,_cCod,"B","0",fonteDesc2)
			MSCBSAY(_nX+25,80,"Desc. Produto:","B","0",fonteDesc3)
			If len(_Descri) > 30
				MSCBSAY(_nX+33,5,substr(_Descri,1,30),"B","0",fonteDesc)
				MSCBSAY(_nX+40,60,substr(_Descri,31,60),"B","0",fonteDesc)
				MSCBSAY(_nX+52,83,"Dt. Producao:","B","0",fonteDesc3)
				MSCBSAY(_nX+52,55,DTOC(_DtProd),"B","0",fonteDesc3)
				MSCBSAY(_nX+62,85,"Dt. Validade:","B","0",fonteDesc3)
				MSCBSAY(_nX+62,56,_DtVal,"B","0",fonteDesc3)
			Else
				MSCBSAY(_nX+33,5,substr(_Descri,1,30),"B","0",fonteDesc)
				MSCBSAY(_nX+42,83,"Dt. Producao:","B","0",fonteDesc3)
				MSCBSAY(_nX+42,60,DTOC(_DtProd),"B","0",fonteDesc3)
				MSCBSAY(_nX+52,85,"Dt. Validade:","B","0",fonteDesc3)
				MSCBSAY(_nX+52,56,_DtVal,"B","0",fonteDesc3)
			EndIf
			_nCont++

			MSCBEND()
			MSCBCLOSEPRINTER()

			if mod(i,10) = 0
				sleep(1500)
			endif
		next

		ffm19clear()

		msgbox('Impressใo de Etiquetas em Andamento!','Impressใo','INFO')


		campoA:enable()
		btn1:enable()
		telaimp:refresh()

	endif

return                   
