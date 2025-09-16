#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma base³fbf01   º Autor ³ Flávio Bohrer Flores º Data ³  25/03/08º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de tiqueta interna                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desossa                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MAX06()

	dbselectarea('ZZ7')
	dbsetorder(1)

	campoA  := space(06)  //campo do codigo do produto
	campoB  := space(08) //campo da data da produção
	campoC 	:= space(40) //campo da descrição do corte
	campoD 	:= space(05) // campo da tara para impressão na etiqueta
	campoE 	:= 000
	//campoF 	:= {"XXXXX","Macho","Femea","     "}//sexo
	campoG  := {"Interno","Externo"}// Pergunta criada por Fabian Maurer para definir a mensagem do Ministerio 

	_dDTMaior   := date()
	_dDTMenor	:= date() - 10

	valor1 	:= '      ' 	//codigo do produto
	valor2 	:= date()   	//data de produção
	valor3 	:= space(40) //Descrição do corte
	valor4 	:= '   '   //Tara
	valor5 	:= 000     //Quantidade de etiqueta
	valor6 	:= 'XXXXX'  //Sexo
	valor7   := space(07)//Pergunta criada por Fabian Maurer para definir a mensagem do Ministerio   
	valor8	:= date()  //Data de Embalagem

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA INTERNA"
	//vinculação dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Data Produção:" of telaimp
	@ 03,01 SAY "Data Embalagem:" of telaimp
	@ 04,01 SAY "Descrição Corte:" of telaimp
	@ 05,01 SAY "Tara:" of telaimp
	@ 06,01 SAY "Quant. Caixas:" of telaimp
	//@ 06,01 SAY "Sexo:" of telaimp
	@ 07,01 SAY "Tipo Mercado:" of telaimp

	@ 01,08 MSGET campoA VAR valor1 SIZE 20,10 F3 'ZZ7' OF telaimp VALID iif(!existcpo('ZZ7'),MAX06clear(),.t.)
	@ 02,08 MSGET campoB VAR valor2 SIZE 40,10  OF telaimp valid valor2 >= _dDTMenor .and. valor2 <= _dDTMaior// data producao
	@ 03,08 MSGET campoF VAR valor8 SIZE 40,10  OF telaimp valid valor8 >= _dDTMenor .and. valor8 <= _dDTMaior// data embalagem
	//@ 02,08 SAY valor2 of telaimp
	@ 04,08 SAY valor3 of telaimp
	@ 05,08 MSGET campoD VAR valor4 SIZE 20,10  OF telaimp // Tara
	@ 06,08 MSGET campoE VAR valor5 SIZE 20,10  OF telaimp  picture '@E 999'  // quant etiqueta
	//@ 06,08 COMBOBOX valor6 items campoF SIZE 40,08 OF telaimp      // Sexo
	@ 07,08 COMBOBOX valor7 items campoG SIZE 40,08 OF telaimp
	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action MAX06etq()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()
	//@ 20,110 BUTTON btn3 PROMPT "Alterar Data" SIZE 50,15 OF telaimp  pixel action MAX06dat()
	campoA:bLostFocus := {|| MAX06prc() }
	ACTIVATE MSDIALOG telaimp CENTERED

return

static function MAX06prc()
	ZZ7->(dbsetorder(1))
	if ZZ7->(dbseek(xfilial('ZZ7')+valor1))
		valor3 := ZZ7->ZZ7_CORTE
	endif
	telaimp:refresh()
return

static function MAX06clear()
	valor1   := space(06)
	valor2   := date()
	valor3   := space(20)
	valor4   := '   '
	valor5   :=000
	valor6   := 'XXXXX'
	valor8   := date()
	telaimp:refresh()
return

static Function MAX06etq()
	if empty(valor1) .or. empty(valor2) .or. empty(valor3) .or. empty(valor4) .or. empty(valor5) .or. empty(valor8)
		Alert('Campos em branco!')
		return
	endif

	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7')+valor1))

	_nQtdCx   := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(valor1),'B1_QCAIX') 
	_cCodBar  := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(valor1),'B1_CODBAR') 

	if empty(_cCodbar)
		alert('Produto sem codigo de barras cadastrado')
		return
	endif	

	_nQetq := _nQtdCx * valor5

	_cEst  := getComputerName()    
	_cIp   := ''	

	if alltrim(_cEst) == 'DTI03'
		_cIp := alltrim(fBuscaCpo('ZAM',1,xFilial('ZAM')+'IDTI1','ZAM_IP'))	
		MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
	else
		MSCBPRINTER('S600','LPT1')
	endif
	//MSCBPRINTER('S600','IP',,,,,'10.0.0.32') //Impressão por IP
	//modelo porta        ip
	//MSCBPRINTER('S600','COM1:4800,e,7,2')
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas VALOR5


	dtVALID := valor2+ZZ7->ZZ7_DVALID // Data de validade
	fontecorte      :="22,29"
	fontedesc       :="22,29"
	fonteNomeCorte  :="28,35"
	fonteNomeCorte1 :="18,35"
	fonteData       :="16,35"
	fonteMesTemp    :="22,15"
	fonteMesTemp1   :="19,13"
	fonteInscSIF    :="19,16"
	fonteInfNutri1  :="16,25"
	fonteInfNutri2  :="16,18"
	fonteNutri3     :="16,9"
	fonteNutri4     :="19,10"
	fontelinha9     :="14,14"
	fonte3          :="16,13"
	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=42-t
	MSCBSAY(2,pos,ZZ7->ZZ7_DESC,"B","0",fonteDesc)
	pos2:=0
	t2:=len(alltrim(valor3))
	pos2:=42-t2  
	DbSelectArea('SB1') 
	_cDestMerc := alltrim(valor7) //Criado por Fabian Maurer para definir tipo de mensagem de Autorização do Ministerio 19/12/11 

	MSCBSAY(9,pos2,alltrim(valor3),"B","0",fontecorte) // nome do corte
	MSCBSAY(16,52,substr(dtos(valor2),7,2)+'/'+substr(dtos(valor2),5,2)+'/'+substr(dtos(valor2),3,2),"B","0",fonteData) //Data da producao

	_sif04 := GetMV('SI_SIFET04')
	_sif07 := GetMV('SI_SIFET07')
	_sif07_2 := GetMv('SI_SIFTE07')
	_sif12 := GetMV('SI_SIFET12')
	_sif18 := GetMV('SI_SIFET18')
	_MSIF  := substr(ZZ7->ZZ7_MSIF,1,4)

	if (_MSIF $ _sif07) .or. (_MSIF $ _sif07_2)
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif12
		MSCBSAY(15,5,'MANTER CONGELADA A -12 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif18
		MSCBSAY(15,5,'MANTER CONGELADA A -18 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif04
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 4 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	endif 


	//MSCBSAY(21,52,substr(dtos(dtVALID),7,2)+'/'+substr(dtos(dtVALID),5,2)+'/'+substr(dtos(dtVALID),3,2),"B","0",fonteData) //Data validade
	MSCBSAY(21,49,dtoc(dtVALID),"B","0",fonteData) //Data validade
	MSCBSAY(21,24,valor6,"B","0",fonteNomeCorte1)// Sexo
	MSCBSAY(21,13,alltrim(valor4)+'g',"B","0",fonteNomeCorte1)//tara
	//Criado Fabian Maurer para identificar o tipo de mensagem do Ministerio 19/12/11 
	if alltrim(_cDestMerc) $ "Externo"
		MSCBSAY(24,02,'USO AUTORIZADO PELO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)
	else 	
		MSCBSAY(24,07,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)//REGISTRO NO 
	endif  
	//Box Grande
	//MSCBBOX(26,6,53,70,4)
	//MSCBBOX(26,6,56,70,4)


	//CODIGO DE BARRAS
	MSCBSAYBAR(30,03,_cCodBar,"B","MB07",10,.F.,.T.,.F.,"C",2,1,.F.)

	//1º Titulo
	MSCBSAY(27,41,'INFORMACOES NUTRICIONAIS',"B","0",fonteInfNutri1)
	//MSCBSAY(27,07,'Porcao de 100g de parte comestivel',"B","0",fonteInfNutri1)//MSCBBOX(34,6,34,70,3) 
	MSCBSAY(27,07,ZZ7->ZZ7_PRTCOM,"B","0",fonteInfNutri1)
	//MSCBBOX(29,6,29,70,3)
	//2º Linha
	MSCBSAY(30,49,'Quantidade por Porcao',"B","0",fonteInfNutri2)
	//MSCBLineH(29,45,37,3,"B")//1ª Barra vertical
	MSCBSAY(30,38,'%VD(*)',"B","0",fonteInfNutri2)
	//MSCBLineH(29,37,37,3,"B")//2ª Barra vertical

	//3ª Linha           ENERGETICO
	MSCBSAY(32,56,'Valor energ.',"B","0",fonteInfNutri2)
	//MSCBLineH(32,55,44,3,"B")//1ª Barra vertical
	MSCBSAY(32,46,ZZ7->ZZ7_CALQTP,"B","0",fonteInfNutri2)
	//MSCBLineH(37,45,40,3,"B")//2ª Barra vertical
	MSCBSAY(32,38,ZZ7->ZZ7_CALVD,"B","0",fonteInfNutri2)
	//MSCBLineH(32,37,40,3,"B")//3ª Barra vertical

	//4ª Linha
	MSCBSAY(34,56,'Carb.',"B","0",fonteInfNutri2)
	//MSCBLineH(32,55,44,3,"B")//1ª Barra vertical
	MSCBSAY(34,47,ZZ7->ZZ7_CARQTP,"B","0",fonteNutri4)
	//MSCBLineH(37,45,43,3,"B")//2ª Barra vertical
	MSCBSAY(34,38,ZZ7->ZZ7_CARVD,"B","0",fonteInfNutri2)
	//MSCBLineH(34,37,43,3,"B")//3ª Barra vertical

	//5ª Linha
	MSCBSAY(36,56,'Prot.',"B","0",fonteInfNutri2)
	//MSCBLineH(43,56,44,3,"B")//1ª Barra vertical
	MSCBSAY(36,48,ZZ7->ZZ7_PROQTP,"B","0",fonteInfNutri2)
	//MSCBLineH(43,45,44,3,"B")//2ª Barra vertical
	MSCBSAY(36,38,ZZ7->ZZ7_PROVD,"B","0",fonteInfNutri2)
	//MSCBLineH(36,37,44,3,"B")//3ª Barra vertical

	//6ª Linha
	MSCBSAY(38,56,'Gord. Totais',"B","0",fonteInfNutri2)
	//MSCBLineH(42,55,44,3,"B")//1ª Barra vertical
	MSCBSAY(38,48,ZZ7->ZZ7_GTQTP,"B","0",fonteInfNutri2)
	//MSCBLineH(42,45,43,3,"B")//2ª Barra vertical
	MSCBSAY(38,38,ZZ7->ZZ7_GTVD,"B","0",fonteInfNutri2)
	//MSCBLineH(38,37,44,3,"B")//3ª Barra vertical

	//7ª Linha
	MSCBSAY(40,56,'Gord. Satur.',"B","0",fonteInfNutri2)
	//MSCBLineH(45,55,44,3,"B")//4ª Barra vertical
	MSCBSAY(40,48,ZZ7->ZZ7_GSQTP,"B","0",fonteInfNutri2)
	//MSCBLineH(45,45,43,3,"B")//5ª Barra vertical
	MSCBSAY(40,38,ZZ7->ZZ7_GSVD,"B","0",fonteInfNutri2) 
	//MSCBLineH(40,37,44,3,"B")//2ª Barra vertical
	//MSCBLineH(45,39,44,3,"B")//3ª Barra vertical
	//MSCBLineV(44,6,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)

	//8ª Linha
	MSCBSAY(42,56,'Sodio',"B","0",fonteInfNutri2)
	//MSCBLineH(47,55,44,3,"B")//4ª Barra vertical
	MSCBSAY(42,48,ZZ7->ZZ7_SODQTP,"B","0",fonteInfNutri2)
	//MSCBLineH(47,45,43,3,"B")//5ª Barra vertical
	MSCBSAY(42,38,ZZ7->ZZ7_SODVD,"B","0",fonteInfNutri2)
	//MSCBLineH(42,37,44,3,"B")//2ª Barra vertical

	//9ª Linha
	MSCBSAY(44,56,'Fibra Alim.',"B","0",fonteInfNutri2)
	//MSCBLineH(49,55,44,3,"B")//4ª Barra vertical
	MSCBSAY(44,48,ZZ7->ZZ7_FIAQTP,"B","0",fonteNutri4)
	//MSCBLineH(49,45,43,3,"B")//5ª Barra vertical
	MSCBSAY(44,38,ZZ7->ZZ7_FIAVD,"B","0",fonteInfNutri2)
	//MSCBLineH(49,37,44,3,"B")//2ª Barra vertical

	//10ª Linha
	MSCBSAY(46,56,'Gord. Trans.',"B","0",fonteInfNutri2)
	//MSCBLineH(51,55,44,3,"B")//4ª Barra vertical
	MSCBSAY(46,48,ZZ7->ZZ7_GTRTP,"B","0",fonteInfNutri2)
	//MSCBLineH(51,45,43,3,"B")//5ª Barra vertical
	MSCBSAY(46,38,ZZ7->ZZ7_GTRVD,"B","0",fonteInfNutri2)
	//MSCBLineH(51,37,44,3,"B")//2ª Barra vertical
	//MSCBLineV(48,6,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)

	MSCBSAY(48,12,'(*)VALORES DIARIOS DE REFERENCIA COM BASE EM UMA DIETA DE 2.000kcal,',"B","0",fontelinha9)
	MSCBSAY(50,16,'OU 8400 kj.SEUS VALORES DIARIOS PODEM SER MAIORES OU MENORES',"B","0",fontelinha9)
	MSCBSAY(52,29,'DEPENDENDO DE SUAS NECESSIDADES ENERGETICAS.',"B","0",fontelinha9)
	// MSCBSAY(54,38,'APOS ABERTO CONSUMIR EM ATE 2 DIAS.',"B","0",fontelinha9) -Alterado para satisfazer a condição abaixo

	_exmetq   := GetMV('SI_EXMETQ')
	_cod      := ZZ7->ZZ7_CODPRO

	if (!_cod $ _exmetq)
		MSCBSAY(54,38,'APOS ABERTO CONSUMIR EM ATE 2 DIAS.',"B","0",fontelinha9)
	endif

	MSCBEND()
	MSCBCLOSEPRINTER()
	MAX06clear()

	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')


return


/*Blocos de Comando Para Calcio Criados por Flavio Bohrer. Removidos e armazenados aqui por Mauricio, para possivel reutilização futura.
//MSCBSAY(39,30,'Calcio',"B","0",fonteInfNutri2)

MSCBLineH(41,24,46,3,"B")//4ª Barra vertical 

//if alltrim(ZZ7->ZZ7_CACQTP) == 'Qtd n signif'
//	MSCBSAY(39,16,ZZ7->ZZ7_CACQTP,"B","0",fonte3)
//else
//	MSCBSAY(39,17,ZZ7->ZZ7_CACQTP,"B","0",fonteInfNutri2) //numero de rastro
//Endif

MSCBLineH(43,15,46,3,"B")//5ª Barra vertical      

//if alltrim(ZZ7->ZZ7_CACVD) == 'Qtd n signif'
//	MSCBSAY(39,7,ZZ7->ZZ7_CACVD,"B","0",fonte3)
//else
//	MSCBSAY(39,8,ZZ7->ZZ7_CACVD,"B","0",fonteInfNutri2) //numero de rastro
//Endif

MSCBLineV(41,6,70,3,"B")



//7ª Linha
//MSCBSAY(45,55,'Gorduras Satur.',"B","0",fonteInfNutri2)
//MSCBLineH(45,55,47,3,"B")//1ª Barra vertical
//MSCBSAY(45,48,ZZ7->ZZ7_GSQTP,"B","0",fonteInfNutri2)
//MSCBLineH(45,45,47,3,"B")//2ª Barra vertical
//MSCBSAY(45,39,ZZ7->ZZ7_GSVD,"B","0",fonteInfNutri2)
//MSCBLineH(45,37,47,3,"B")//3ª Barra vertical
//MSCBSAY(45,30,'Sodio',"B","0",fonteInfNutri2)
//MSCBLineH(45,24,47,3,"B")//4ª Barra vertical
//MSCBSAY(45,18,ZZ7->ZZ7_SODQTP,"B","0",fonteInfNutri2)
//MSCBLineH(45,15,47,3,"B")//5ª Barra vertical
//MSCBSAY(45,9,ZZ7->ZZ7_SODVD,"B","0",fonteInfNutri2)
//MSCBLineV(47,6,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)
//8ª Linha






*/
