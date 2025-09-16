#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI69   บ Autor ณ Fabian Maurer บ Data ณ  27/09/18          บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao de ETIQUETA NOVA GRAZIELLE(QUALIDADE)            บฑฑ
ฑฑบ          ณ 										                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Porcionados                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function DTI69()

	dbselectarea('SB1')
	dbsetorder(1)

	campoA  := Space(6)  // Campo do Codigo do Produto
	campoB 	:= 0          // Quantidade de Etiqueta             

	valor1 	:= Space(6)  // Codigo do Produto
	valor2 	:= 0          // Quantidade de Etiqueta

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA NOVA GRAZI"
	//vincula็ใo dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Quant. Etiq.:" of telaimp

	@ 01,08 MSGET campoA VAR valor1 SIZE 30,10 F3 'SB1' OF telaimp 
	@ 02,08 MSGET campoF VAR valor2 SIZE 20,10  OF telaimp  picture '@E 999'   VALID valor2 <= 50// quant etiqueta

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()



	ACTIVATE MSDIALOG telaimp CENTERED

return


Static Function Imprime()

	Processa({||dti69etq() },"IMPRESSAO DE ETIQUETA","Realizando envio เ impressora...")

return


static function dti69clear()
	valor2 	:= 0          // Quantidade de Etiqueta
	telaimp:refresh()
return

static Function dti69etq()
	//Local  _DescLote  := valor1
	//Local  _DescCod   := valor2
	//Local  _Descri    := valor3
	//Local  _DtProd    := valor4
	//Local  _DtVal     := valor5
	Local i
	
	//campoB:disable()
	btn1:disable()
	telaimp:refresh()

	//if empty(valor1)
	//	return .f.
	//endif

	ProcRegua(valor2)

	DbSelectArea('SB1')
	SB1->(dbsetorder(1))
	DbSelectArea('ZZ7')
	ZZ7->(dbsetorder(1))

	SB1->(dbSeek(xfilial('SB1')+ valor1))
	alert(SB1->B1_COD)
	alert(SB1->B1_CODBAR)
	for i := 1 to valor2

		incproc()

		//MSCBPRINTER('S600','LPT1')
		//MSCBPRINTER('S600','IP',,,,,'10.7.0.58') //Impressใo por IP
		MSCBPRINTER('S600','IP',,,,,'10.11.20.203')
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(1,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas

		fonteTit   :=  "30,25"
		fontedesc  :=  "30,30"
		fonteinf   :=  "20,20"
		fonteinfdt :=  "20,15"
		fontedata  :=  "25,25"

		_nCont      :=  0
		//esq/dir,Cima/Baixo
		//Inicio Bloco Titulo  
		MSCBSAY(0,5,"CARNE RESFRIADA DE BOVINO SEM OSSO","N","0",fonteTit)
		MSCBSAY(0,9,"CARNE ENFRIADA DE BOVINO SIN HUESO","N","0",fonteTit)
		MSCBSAY(14,13,"PATINHO/PECETO","N","0",fonteDesc)
		//Fim Bloco Titulo

		//Inicio Segundo Bloco
		MSCBSAY(0,17,"Manter Resfriada de -1 a 1 C","N","0",fonteinf)
		MSCBSAY(0,20,"Data de Abate/Produ็ใo/Lote/Fecha de Faena:","N","0",fonteinfdt)
		MSCBSAY(37,20,"XX/XX/XXXX","N","0",fontedata)
		MSCBSAY(0,23,"Data de Embalagem/Fecha de Embalaje:","N","0",fonteinfdt)
		MSCBSAY(37,23,"XX/XX/XXXX","N","0",fontedata)			
		MSCBSAY(0,26,"Data de Validade/Fecha de Validad:","N","0",fonteinfdt)
		MSCBSAY(37,26,"XX/XX/XXXX","N","0",fontedata)
		MSCBSAY(0,29,"Peso da Embalagem:","N","0",fonteinfdt)
		MSCBSAY(37,29,"XXg","N","0",fontedata)
		//Fim do Segundo Bloco
		/*	
		//Inicio do Bloco com as linhas CNPJ e Contem Glutem				
		//Inicio Terceiro Bloco
		MSCBSAY(0,33,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N XXXX/1733","N","0",fonteinfdt)
		MSCBSAY(0,36,"CNPJ 88.728.027.0001-46 - WWW.FRIGORIFICOSILVA.COM.BR","N","0",fonteinfdt)
		MSCBSAY(0,39,"NAO CONTEM GLUTEN","N","0",fonteinf)
		//Fim Terceiro Bloco

		//Inicio Quarto Bloco
		MSCBSAY(0,43,"INFORMACOES NUTRICIONAIS PORCAO DE 100G (1BIFE):","N","0",fonteinf)
		MSCBSAY(0,46,"Valor Energetico 130Kcal/794,90 kJ (7%VD);Carboidratos 0g (0%VD);","N","0",fonteinfdt)
		MSCBSAY(0,49,"Proteinas 23g (31%VD);Gorduras Totais 4,5g (8%VD);Gorduras Saturadas 1,5g (7%VD)","N","0",fonteinfdt)
		MSCBSAY(0,52,"Gorduras Trans 0g(0%VD);Fibra Alimentar 0g (0%VD);Sodio 95mg(4%VD)","N","0",fonteinfdt)
		MSCBSAY(0,55,"*%Valores diarios de referencia com base em uma dieta de 2.000Kcal ou","N","0",fonteinfdt)
		MSCBSAY(1,57,"8.400kJ. Seus valores diarios podem ser maiores ou menores dependendo","N","0",fonteinfdt)
		MSCBSAY(1,59,"de suas necessidades energeticas.","N","0",fonteinfdt)
		//Fim do Quarto Bloco

		//Inicio Quinto Bloco
		MSCBSAY(0,62,"Apos aberto consumir em ate 2 dias.","N","0",fonteinf)
		//Fim Quinto Bloco

		//Inicio Sexto Bloco
		MSCBSAY(0,65,"IMPORTADOR: SUCESION DE CARLOS SCHNECK S.A","N","0",fonteinf)
		MSCBSAY(0,68,"Aparicio Saraiva, 4301 Montevideo, UY","N","0",fonteinf)
		MSCBSAY(0,71,"N Reg Monografia MGPA/DGSG/DIA/M...","N","0",fonteinf)
		MSCBSAY(0,74,"N Reg. Rotulo/MGPA/DGSG/DIA/R...","N","0",fonteinf)
		//Fim Sexto Bloco
		//Fim do Bloco com as linhas CNPJ e Contem Glutem
		*/

		//Inicio do Bloco sem as Linhas de Contem Glutem e CNPJ
		//Inicio Terceiro Bloco
		MSCBSAY(0,33,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N XXXX/1733","N","0",fonteinfdt)
		//MSCBSAY(0,36,"CNPJ 88.728.027.0001-46 - WWW.FRIGORIFICOSILVA.COM.BR","N","0",fonteinfdt)
		//MSCBSAY(0,39,"NAO CONTEM GLUTEN","N","0",fonteinf)
		//Fim Terceiro Bloco

		//Inicio Quarto Bloco
		MSCBSAY(0,37,"INFORMACOES NUTRICIONAIS PORCAO DE 100G (1BIFE):","N","0",fonteinf)
		MSCBSAY(0,40,"Valor Energetico 130Kcal/794,90 kJ (7%VD);Carboidratos 0g (0%VD);","N","0",fonteinfdt)
		MSCBSAY(0,43,"Proteinas 23g (31%VD);Gorduras Totais 4,5g (8%VD);Gorduras Saturadas 1,5g (7%VD)","N","0",fonteinfdt)
		MSCBSAY(0,46,"Gorduras Trans 0g(0%VD);Fibra Alimentar 0g (0%VD);Sodio 95mg(4%VD)","N","0",fonteinfdt)
		MSCBSAY(0,50,"*%Valores diarios de referencia com base em uma dieta de 2.000Kcal ou","N","0",fonteinfdt)
		MSCBSAY(1,52,"8.400kJ. Seus valores diarios podem ser maiores ou menores dependendo","N","0",fonteinfdt)
		MSCBSAY(1,54,"de suas necessidades energeticas.","N","0",fonteinfdt)
		//Fim do Quarto Bloco

		//Inicio Quinto Bloco
		// MSCBSAY(0,57,"Apos aberto consumir em ate 2 dias.","N","0",fonteinf) - Alterado para satisfazer a condi็ใo abaixo

		_exmetq  := _GetParam()
		_cod := SB1->B1_COD

		if (!_cod $ _exmetq)
			MSCBSAY(0,57,"Apos aberto consumir em ate 2 dias.","N","0",fonteinf)
		endif
		//Fim Quinto Bloco

		//Inicio Sexto Bloco
		MSCBSAY(0,61,"IMPORTADOR: SUCESION DE CARLOS SCHNECK S.A","N","0",fonteinf)
		MSCBSAY(0,64,"Aparicio Saraiva, 4301 Montevideo, UY","N","0",fonteinf)
		MSCBSAY(0,67,"N Reg Monografia MGPA/DGSG/DIA/M...","N","0",fonteinf)
		MSCBSAY(0,70,"N Reg. Rotulo/MGPA/DGSG/DIA/R...","N","0",fonteinf)
		//Fim Sexto Bloco
		//Fim do Bloco sem as Linhas de Contem Glutem e CNPJ				

		//codigo de barras
		MSCBSAYBAR(0,77,SB1->B1_CODBAR,"N","MB07",10,.F.,.T.,.F.,"C",2,1,.F.)

		_nCont++

		MSCBEND()
		MSCBCLOSEPRINTER()

		if mod(i,10) = 0
			sleep(1500)
		endif
	next

	dti69clear()

	msgbox('Impressใo de Etiquetas em Andamento!','Impressใo','INFO')

	btn1:enable()
	telaimp:refresh()
return                   


Static Function _GetParam()

	_cRet := GetMV('SI_EXMETQ')

Return(_cRet)

