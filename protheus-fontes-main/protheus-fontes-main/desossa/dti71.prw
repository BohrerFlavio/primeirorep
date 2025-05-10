#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI71   º Autor ³ Fabian Maurer º Data ³  08/10/18          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressão de Etiqueta Nova Para Cliente Ezequiel(CML)      º±±
±±º          ³ 	Ternez   							                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desossa		                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI71()

	dbselectarea('SB1')
	dbsetorder(1)
	DbSelectArea('ZAB')
	ZAB->(dbsetorder(1))

	campoA  := Space(6)   // Campo do Codigo do Produto
	campoB 	:= 000          // Quantidade de Etiqueta
	campoC 	:= Space(8)   // Data de Abate
	campoD 	:= Space(8)   // Data de Embalagem

	_cUsuarios := getMv('SI_USRETQ')//parametro com os codigos dos usuarios que podem imprimir ETQ interna com data maior que DATABASE
	_cUsrPorc  := getMv('SI_ETQPRC')//parametro com os codigos de usuarios que podem imprimir com um intervalo de datas bem grande
	_cCodUser  := retCodUsr()

	if alltrim(_cCodUser) $ _cUsuarios
		_dDTMaior   := date() + 7
		_dDTMenor	:= date() - 7

	elseif alltrim(_cCodUser) $ _cUsrPorc
		_dDTMaior   := date() + 365
		_dDTMenor	:= date() - 365

	else
		_dDTMaior   := date()
		_dDTMenor	:= date() - 7
	endif

	valor1 	:= Space(6)   // Codigo do Produto
	valor2 	:= 000          // Quantidade de Etiqueta
	valor3 	:= date()     // Data de Abate
	valor4 	:= date()     // Data de Embalagem

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA TERNEZ"
	//vinculação dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Data de Abate:" of telaimp
	@ 03,01 SAY "Data de Embalagem:" of telaimp
	@ 04,01 SAY "Quant. Caixas:" of telaimp

	@ 01,08 MSGET campoA VAR valor1 SIZE 30,10 F3 'SB1' OF telaimp
	@ 02,08 MSGET campoC VAR valor3 SIZE 30,10 OF telaimp valid valor3 >= _dDTMenor .and. valor3 <= _dDTMaior// data abate
	@ 03,08 MSGET campoD VAR valor4 SIZE 30,10 OF telaimp valid valor4 >= _dDTMenor .and. valor4 <= _dDTMaior// data embalagem
	@ 04,08 MSGET campoB VAR valor2 SIZE 20,10  OF telaimp  picture '@E 999' // quant etiqueta

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	ACTIVATE MSDIALOG telaimp CENTERED

return

Static Function Imprime()

	Processa({||dti71etq() },"IMPRESSAO DE ETIQUETA","Realizando envio à impressora...")

return

static function dti71clear()
	valor2 	:= 0          // Quantidade de Etiqueta
	telaimp:refresh()
return

static Function dti71etq()
	Local  _DtAbt    := valor3
	Local  _DtEmb    := valor4

	DbSelectArea('ZAB')
	ZAB->(dbsetorder(1))

	

	_cCodTar := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(valor1),'B1_CTARAP')
	_nValTar := fBuscaCpo('ZAB',1,xFilial('ZAB') + _cCodTar,'ZAB_TARA')

	btn1:disable()
	telaimp:refresh()

	ProcRegua(valor2)

	DbSelectArea('SB1')
	SB1->(dbsetorder(1))
	DbSelectArea('ZZ7')
	ZZ7->(dbsetorder(1))

	SB1->(dbSeek(xfilial('SB1')+ valor1))
	ZZ7->(dbSeek(xfilial('ZZ7')+ valor1))
	
	_DtVal := valor3 + SB1->B1_VALID // Data de validade

	_nQtdCx := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(valor1),'B1_QCAIX')
	_nQetq  := _nQtdCx * valor2

	//for i := 1 to valor2

		incproc()
		
		_cEst := getComputerName()
		_cIp  := ''

		dbselectarea('ZAM')
		ZAM->(dbSetOrder(2))
		if ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
			_cIp := alltrim(ZAM->ZAM_IP)
		endif


		//se não achou o ip na tabela imprime pela porta paralela
		if empty(_cIp)
			MSCBPRINTER('S600','LPT1')
		else
			MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
		endif
		

		//MSCBPRINTER('S600','IP',,,,,'10.11.20.83')
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nQetq,6,15)	// Usar variavel no primeiro campo, para a quantidade de etiquetas

		fonteTit   :=  "30,25"
		fontedesc  :=  "30,30"
		fonteinf   :=  "20,20"
		fonteinfdt :=  "20,15"
		fontedata  :=  "25,25"

		_nCont      :=  0
		//esq/dir,Cima/Baixo
		//Inicio Bloco Titulo
		MSCBSAY(0,5,ZZ7->ZZ7_DESC,"N","0",fonteTit)
		MSCBSAY(10,9,SB1->B1_DESCRED,"N","0",fonteDesc)
		//Fim Bloco Titulo

		//Inicio Segundo Bloco
		MSCBSAY(0,17,SB1->B1_MENETQ2,"N","0",fonteinf)
		MSCBSAY(0,20,"Data de Abate/Produção/Lote:","N","0",fonteinfdt)
		MSCBSAY(37,20,DtoC(_DtAbt),"N","0",fontedata)
		MSCBSAY(0,23,"Data de Embalagem:","N","0",fonteinfdt)
		MSCBSAY(37,23,DtoC(_DtEmb),"N","0",fontedata)
		MSCBSAY(0,26,"Data de Validade:","N","0",fonteinfdt)
		MSCBSAY(37,26,DtoC(_DtVal),"N","0",fontedata)
		MSCBSAY(0,29,"Peso da Embalagem:","N","0",fonteinfdt)
		MSCBSAY(37,29, Str(_nValTar) + "g","N","0",fontedata)
		//Fim do Segundo Bloco

		//Inicio do Bloco com as linhas CNPJ e Contem Glutem

		//Inicio Terceiro Bloco
		MSCBSAY(0,33,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N " + ZZ7->ZZ7_MSIF,"N","0",fonteinfdt)
		MSCBSAY(0,36,"CNPJ 88.728.027.0001-46 - WWW.FRIGORIFICOSILVA.COM.BR","N","0",fonteinfdt)
		MSCBSAY(0,39,"NAO CONTEM GLUTEN","N","0",fonteinf)
		//Fim Terceiro Bloco

		//Inicio Quarto Bloco
		MSCBSAY(0,43,"INFORMACOES NUTRICIONAIS PORCAO DE 100G (1BIFE):","N","0",fonteinf)
		MSCBSAY(0,46,"Valor Energetico " + Alltrim(ZZ7->ZZ7_CALQTP) + "(" + Alltrim(ZZ7->ZZ7_CALVD) + ");" + "Carboidratos " + Alltrim(ZZ7->ZZ7_CARQTP) + "(" + Alltrim(ZZ7->ZZ7_CARVD) + ");","N","0",fonteinfdt)
		MSCBSAY(0,49,"Proteinas " + Alltrim(ZZ7->ZZ7_PROQTP) + "(" + Alltrim(ZZ7->ZZ7_PROVD) + ");" + "Gorduras Totais " + Alltrim(ZZ7->ZZ7_GTQTP) + "(" + Alltrim(ZZ7->ZZ7_GTVD) + ");" + "Gorduras Saturadas " + Alltrim(ZZ7->ZZ7_GSQTP) + "(" + Alltrim(ZZ7->ZZ7_GSVD) + ");","N","0",fonteinfdt)
		MSCBSAY(0,52,"Gorduras Trans 0g(0%VD);" + "Fibra Alimentar " + Alltrim(ZZ7->ZZ7_FIAQTP) + "(" + Alltrim(ZZ7->ZZ7_FIAVD) + ");" + "Sodio " + Alltrim(ZZ7->ZZ7_SODQTP) + "(" + Alltrim(ZZ7->ZZ7_SODVD) + ");","N","0",fonteinfdt)
		MSCBSAY(0,55,"*%Valores diarios de referencia com base em uma dieta de 2.000Kcal ou","N","0",fonteinfdt)
		MSCBSAY(1,57,"8.400kJ. Seus valores diarios podem ser maiores ou menores dependendo","N","0",fonteinfdt)
		MSCBSAY(1,59,"de suas necessidades energeticas.","N","0",fonteinfdt)
		//Fim do Quarto Bloco

		//Inicio Quinto Bloco
		// MSCBSAY(0,62,"Apos aberto consumir em ate 2 dias.","N","0",fonteinf) - Alterado para satisfazer a condição abaixo
		
		_exmetq   := GetMV('SI_EXMETQ')
		_cod      := ZZ7->ZZ7_CODPRO

		if (_cod $ _exmetq)
			MSCBSAY(0,62,"Apos aberto consumir em ate 2 dias.","N","0",fonteinf)
		endif
		//Fim Quinto Bloco

		//Fim do Bloco com as linhas CNPJ e Contem Glutem

		/*
		//Inicio do Bloco sem as Linhas de Contem Glutem e CNPJ

		//Inicio Terceiro Bloco
		MSCBSAY(0,33,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N " + ZZ7->ZZ7_MSIF,"N","0",fonteinfdt)
		//MSCBSAY(0,36,"CNPJ 88.728.027.0001-46 - WWW.FRIGORIFICOSILVA.COM.BR","N","0",fonteinfdt)
		//MSCBSAY(0,39,"NAO CONTEM GLUTEN","N","0",fonteinf)
		//Fim Terceiro Bloco

		//Inicio Quarto Bloco
		MSCBSAY(0,43,"INFORMACOES NUTRICIONAIS PORCAO DE 100G (1BIFE):","N","0",fonteinf)
		MSCBSAY(0,46,"Valor Energetico " + Alltrim(ZZ7->ZZ7_CALQTP) + "(" + Alltrim(ZZ7->ZZ7_CALVD) + ");" + "Carboidratos " + Alltrim(ZZ7->ZZ7_CARQTP) + "(" + Alltrim(ZZ7->ZZ7_CARVD) + ");","N","0",fonteinfdt)
		MSCBSAY(0,49,"Proteinas " + Alltrim(ZZ7->ZZ7_PROQTP) + "(" + Alltrim(ZZ7->ZZ7_PROVD) + ");" + "Gorduras Totais " + Alltrim(ZZ7->ZZ7_GTQTP) + "(" + Alltrim(ZZ7->ZZ7_GTVD) + ");" + "Gorduras Saturadas " + Alltrim(ZZ7->ZZ7_GSQTP) + "(" + Alltrim(ZZ7->ZZ7_GSVD) + ");","N","0",fonteinfdt)
		MSCBSAY(0,52,"Gorduras Trans 0g(0%VD);" + "Fibra Alimentar " + Alltrim(ZZ7->ZZ7_FIAQTP) + "(" + Alltrim(ZZ7->ZZ7_FIAVD) + ");" + "Sodio " + Alltrim(ZZ7->ZZ7_SODQTP) + "(" + Alltrim(ZZ7->ZZ7_SODVD) + ");","N","0",fonteinfdt)
		MSCBSAY(0,55,"*%Valores diarios de referencia com base em uma dieta de 2.000Kcal ou","N","0",fonteinfdt)
		MSCBSAY(1,57,"8.400kJ. Seus valores diarios podem ser maiores ou menores dependendo","N","0",fonteinfdt)
		MSCBSAY(1,59,"de suas necessidades energeticas.","N","0",fonteinfdt)
		//Fim do Quarto Bloco

		//Inicio Quinto Bloco
		MSCBSAY(0,57,"Apos aberto consumir em ate 2 dias.","N","0",fonteinf)
		//Fim Quinto Bloco

		//Inicio Sexto Bloco
		MSCBSAY(0,61,"IMPORTADOR: SUCESION DE CARLOS SCHNECK S.A","N","0",fonteinf)
		MSCBSAY(0,64,"Aparicio Saraiva, 4301 Montevideo, UY","N","0",fonteinf)
		MSCBSAY(0,67,"N Reg Monografia MGPA/DGSG/DIA/M...","N","0",fonteinf)
		MSCBSAY(0,70,"N Reg. Rotulo/MGPA/DGSG/DIA/R...","N","0",fonteinf)
		//Fim Sexto Bloco

		//Fim do Bloco sem as Linhas de Contem Glutem e CNPJ
		*/
		//Inicio Codigo de Barras
		MSCBSAYBAR(10,72,SB1->B1_CODBAR,"N","MB07",10,.F.,.T.,.F.,"C",2,1,.F.)
		//Fim Codigo de Barras

		_nCont++

		MSCBEND()
		MSCBCLOSEPRINTER()

	//	if mod(i,10) = 0
	//		sleep(1500)
	//	endif
	//next

	dti71clear()

	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

	btn1:enable()
	telaimp:refresh()

return                   
