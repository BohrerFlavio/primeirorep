#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI128  º Autor ³ Flávio Bohrer Flôres º Data ³  24/10/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de Etiqueta de Porcentagem de Gordura   Raio X   º±±
±±º          ³ 	rotina adaptada para reimpressão da etiqueta de Gordura   º±±
±±º          ³  Dia 07/11/21 . .Ainda trabalhando nela (ref. DTI130)      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Embalagem                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function dti128()

	dbselectarea('SB1')
	dbsetorder(1)

	campoA   := Space(06)  //campo do codigo do produto
	campoB 	 := Space(40)  //campo da descrição do corte
	campoC 	 := 0
	campoE   := stod('')
	
	valor1 	 := Space(06) //codigo do produto
	valor2 	 := Space(40) //Descrição do corte
	valor3 	 := 0         //Quantidade de etiquet
	valor5   := stod('')  //data de abate
	valor6   := space(10)
	Valor7   := 0
	_dDthoje   := date()  //data da produção

	_ProdRes := GETMV('SI_PRODRES')
	_PrdQtCx := GETMV('SI_PRDQTCX')
	_PrQtCx2 := GETMV('SI_PRDQTC2')// Continuação do parâmetro anterior "SI_PRDQTCX"
	
	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE PRÉ-ETIQUETA P/ EMBALAGEM"
	//vinculação dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Descrição Corte:" of telaimp

	@ 04,01 SAY "Data de Abate:" of telaimp


	@ 01,08 MSGET campoA VAR valor1 SIZE 30,10 F3 'SB1' OF telaimp VALID valGrupo(valor1) //iif(!existcpo('SB1'),ffm01clear(),.t.) .and.
	@ 02,08 SAY valor2 of telaimp

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	campoA:bLostFocus := {|| dti128p() }




	ACTIVATE MSDIALOG telaimp CENTERED

return

Static Function valGrupo(_prod)

	
	if empty(_prod)
		dti128c()
		return .t.
	endif

	if _prod $ _ProdRes

		telaimp:refresh()
	else
		telaimp:refresh()
	endif

	if _prod $ _PrdQtCx .OR. _prod $ _PrQtCx2		
		valor7 := 0
		telaimp:refresh()
	else		
		valor7 := 0
		telaimp:refresh()
	endif

return .t.

Static Function Imprime()
	
	Processa({||dti128e() },"IMPRESSAO DE PRE-ETIQUETA de % de Gordura","Realizando envio à impressora...")

return

static function dti128p()

	SB1->(dbsetorder(1))
	if SB1->(dbseek(xfilial('SB1')+valor1))
		valor2 := SB1->B1_DESCRED
	else
		alert('Produto inexistente!')
	endif

	if valor1 $ _ProdRes
		telaimp:refresh()
	else
		telaimp:refresh()
	endif

	if valor1 $ _PrdQtCx .OR. valor1 $ _PrQtCx2		
		valor7 := 0
		telaimp:refresh()
	else
		valor7 := 0
		telaimp:refresh()
	endif

	telaimp:refresh()

return

static function dti128c()
	valor1   := Space(06)
	valor2   := Space(40)	
	telaimp:refresh()
return

static Function dti128e()

	Local   _nSeq   := 0
	Local  _despor  := ''	
	Local  _Data    := ''
	
	campoA:disable()
	btn1:disable()
	telaimp:refresh()

	if empty(valor2)
		return .f.
	endif
	ProcRegua(RecCount())
	DbSelectArea('SB1')
	SB1->(dbsetorder(1))

	IF SB1->(dbseek(xfilial('SB1')+alltrim(valor1)))
			
		incproc()
		
		_cEst := getComputerName()
		_cIp  := ''

		dbselectarea('ZAM')
		ZAM->(dbSetOrder(2))
		if ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
			_cIp := alltrim(ZAM->ZAM_IP)
		endif
				
		if empty(_cIp)
			MSCBPRINTER('S600','LPT1')
		else
			MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
		endif
		
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(1,4,50)
		_despor     :=  alltrim(SB1->B1_DESCRED)			
		_Data       :=  DTOC(ddatabase)
		_dtAbt		:=  DTOC(valor5)
		_nQtCx		:= valor7
		
		
		fDesc2_1		:=  "60,33"
		fDesc2_2		:=  "80,60"
		fDesc2_3		:=  "110,80"
		fDesc2_4		:=  "150,100"
		
		_cCod   :=  substr(alltrim(SB1->B1_COD),1,06)
								
		MSCBSAY(3,08,'Perc. Gord. Produto: ',"N","0",fDesc2_1)
		MSCBSAY(3,15,alltrim(_cCod),"N","0",fDesc2_2)
		MSCBSAY(3,27,'30 %' ,"N","0",fDesc2_4)
			
		MSCBEND()
		MSCBCLOSEPRINTER()

		dti128c()

		msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')
		
		_nSeq := 0
		campoA:enable()
		btn1:enable()
		telaimp:refresh()
		
	endif

return


