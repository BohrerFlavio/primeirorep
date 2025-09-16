#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³dti35   º Autor ³ Flávio Bohrer Flores º Data ³  11/05/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de Etiqueta interna  Com Tabela Nutricional 	  º±±
±±º          ³ Dia 09/05/22 - Lucineia solicitou ajuste                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Porcionados (Teste de Modelo)                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI35()

	dbselectarea('ZZ7')
	dbsetorder(1)

	campoA  := space(06)  //campo do codigo do produto
	campoB  := space(08)  //campo da data da produção
	campoC 	:= space(40)  //campo da descrição do corte
	campoD 	:= space(05)  //campo da tara para impressão na etiqueta
	campoE 	:= 000
	campoG 	:= space(05)

	_cUsuarios := getMv('SI_USRETQ')//parametro com os codigos dos usuarios que podem imprimir ETQ interna com data maior que DATABASE
	_cCodUser  := retCodUsr()
	if alltrim(_cCodUser) $ _cUsuarios
		_dDTMaior   := date() + 7
		_dDTMenor	:= date() - 7
	else
		_dDTMaior   := date()
		_dDTMenor	:= date() - 7
	endif

	valor1 	:= '      ' 	//codigo do produto
	valor2 	:= date()   	//data de produção
	valor3 	:= space(40) 	//Descrição do corte
	valor4 	:= '   '   		//Tara
	valor5 	:= 000     		//Quantidade de etiqueta
	valor6 	:= 'XXXXX'  	//Sexo
	valor7   := space(07)	//Pergunta criada por Fabian Maurer para definir a mensagem do Ministerio
	valor8	:= date()  		//Data de Embalagem
	//valor9 	:= '   '    //Quantidade de etiqueta

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA INTERNA"
	//vinculação dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Data Produção:" of telaimp
	@ 03,01 SAY "Data Embalagem:" of telaimp
	@ 04,01 SAY "Descrição Corte:" of telaimp
	@ 05,01 SAY "Tara:" of telaimp
	@ 06,01 SAY "Quant. Caixas:" of telaimp
	//@ 07,01 SAY "% de Solução:" of telaimp

	@ 01,08 MSGET campoA VAR valor1 SIZE 20,10 F3 'ZZ7' OF telaimp VALID iif(!existcpo('ZZ7'),dti35clear(),.t.)
	@ 02,08 MSGET campoB VAR valor2 SIZE 40,10  OF telaimp valid valor2 >= _dDTMenor .and. valor2 <= _dDTMaior// data producao
	@ 03,08 MSGET campoF VAR valor8 SIZE 40,10  OF telaimp valid valor8 >= _dDTMenor .and. valor8 <= _dDTMaior// data embalagem

	@ 04,08 SAY valor3 of telaimp
	@ 05,08 SAY valor4 of telaimp // Tara
	//@ 05,08 MSGET campoD VAR valor4 SIZE 20,10  OF telaimp // Tara
	@ 06,08 MSGET campoE VAR valor5 SIZE 20,10  OF telaimp  picture '@E 999'  // quant etiqueta
	//@ 07,08 MSGET campoG VAR valor9 SIZE 20,10  OF telaimp


	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action dti35etq()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	campoA:bLostFocus := {|| dti35prc() }
	ACTIVATE MSDIALOG telaimp CENTERED

return

static Function dti35etq()

	pos :=0

	if empty(valor1) .or. empty(valor2) .or. empty(valor3) .or. empty(valor4) .or. empty(valor5) .or. empty(valor8)
		Alert('Campos em branco!')
		return
	endif

	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7')+valor1))

	_nQtdCx := Posicione('SB1',1,xFilial('SB1') + alltrim(valor1),'B1_QCAIX') 
	_nQetq  := _nQtdCx * valor5

	_cEst := getComputerName()
	_cIp  := ''	

	_cEst := getComputerName()
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

	//if alltrim(_cEst) == 'PAC02' .or. alltrim(_cEst) == 'PEX01' .or. alltrim(_cEst) == 'PORC02' .or. alltrim(_cEst) == 'PORC01'
	//	_cIp := alltrim(Posicione('ZAM',1,xFilial('ZAM')+'IPAL1','ZAM_IP'))	
	//	MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
	//else
	//	MSCBPRINTER('S600','LPT1')
	//endif

	//MSCBPRINTER('S600','IP',,,,,'10.11.22.85') //Impressão por IP feita por Flávio para teste
	MSCBCHKSTATUS(.f.)
	//alert(_nQetq)  
	MSCBBEGIN(_nQetq,6,15)// Usar variavel no primeiro campo, para a quantidade de etiquetas VALOR5 
	//MSCBBEGIN(2,6,15)

	dtVALID := valor2+ZZ7->ZZ7_DVALID // Data de validade
	fontecorte      :="22,29"
	fontedesc       :="17,20"
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
	//Geração do cabeçalho da Etiqueta

	GeraCab1()
	GetqExt()

	MSCBEND()
	MSCBCLOSEPRINTER()
	dti35clear()

	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

return

static function dti35prc()
	_cTaraP := Posicione('SB1',1,xfilial('SB1')+alltrim(valor1),'B1_CTARAP')      // Código da tara primária no cadastro - B1_CTARASE
	_nTP    := Posicione('ZAB',1,xfilial('ZAB')+alltrim(_cTaraP),'ZAB_TARA')  		// Valor da tara primária pela tabela ZAB - _nTS
	valor4  := alltrim(str(_nTP))

	ZZ7->(dbsetorder(1))
	if ZZ7->(dbseek(xfilial('ZZ7')+valor1))
		valor3 := ZZ7->ZZ7_CORTE
	endif
	telaimp:refresh()
return

static function dti35clear()
	valor1   := space(06)
	valor2   := date()
	valor3   := space(20)
	valor4   := '   '
	valor5   := 000
	valor6   := 'XXXXX'
	valor8   := date()
	//valor9	 := '   '
	telaimp:refresh()
return

Static Function GeraCab1()

	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=42-t
	MSCBSAY(pos,4,ZZ7->ZZ7_DESC,"N","0",fonteDesc)

	pos2:=0
	t2:=len(alltrim(valor3))
	//pos2:=42-t2  
	pos2:=32-t2  

	DbSelectArea('SB1') 
	_cDestMerc := alltrim(valor7) //Criado por Fabian Maurer para definir tipo de mensagem de Autorização do Ministerio 19/12/11 

	MSCBSAY(pos,6,alltrim(valor3),"N","0",fonteDesc) // nome do corte - alterado por Fabian Maurer no dia 16/08/19

	//MSCBSAY(2,13,'CONTEM '+alltrim(valor9)+'% DE SOLUCAO DE AGUA, SAL E ADITIVOS.',"N","0",fonteDesc)
	//MSCBSAY(pos,13,'CONTEM '+alltrim(valor9)+'% DE SOLUCAO DE AGUA, SAL E ADITIVOS.',"N","0",fonteDesc)
	//MSCBSAY(pos,9,'CONTEM '+alltrim(valor9)+'% DE SOLUCAO DE AGUA, SAL E ADITIVOS.',"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19
	IF !empty(ZZ7->ZZ7_OBS4)
		//MSCBSAY(pos,9,'CONTEM '+alltrim(valor9)+'% DE SOLUCAO DE AGUA, SAL E ADITIVOS.',"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19
		MSCBSAY(pos,9,alltrim(ZZ7->ZZ7_OBS4),"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19
	Endif

	_sif04 := GetMV('SI_SIFET04')
	_sif07 := GetMV('SI_SIFET07')
	_sif07_2 := GetMv('SI_SIFTE07')
	_sif12 := GetMV('SI_SIFET12')
	_sif18 := GetMV('SI_SIFET18')
	_MSIF  := substr(ZZ7->ZZ7_MSIF,1,4)

	MSCBSAY(05,12,'PROIBIDO FRACIONAMENTO / NAO CONTEM GLUTEN',"N","0",fonteDesc)
	MSCBSAY(05,14,'ALERGICOS: PODE CONTER DERIVADOS DE SOJA',"N","0",fonteDesc)

	//MSCBSAY(pos,21,'DATA DE PRODUCAO/LOTE',"N","0",fontelinha9) //Data da producao 
	MSCBSAY(pos,16,'DATA DE PRODUCAO/LOTE',"N","0",fontelinha9) //Data da producao - Alterado por Fabian Maurer no dia 16/08/19
	//MSCBSAY(pos,23,substr(dtos(valor2),7,2)+'/'+substr(dtos(valor2),5,2)+'/'+substr(dtos(valor2),3,2),"N","0",fonteData) //Data da producao
	MSCBSAY(pos,18,substr(dtos(valor2),7,2)+'/'+substr(dtos(valor2),5,2)+'/'+substr(dtos(valor2),3,2),"N","0",fonteData) //Data da producao - Alterado por Fabian Maurer no dia 16/08/19
	//MSCBSAY(30,21,'DATA DE VALIDADE',"N","0",fontelinha9) //Data da producao
	MSCBSAY(30,16,'DATA DE VALIDADE',"N","0",fontelinha9) //Data da producao - Alterado por Fabian Maurer no dia 16/08/19
	//MSCBSAY(29,23,dtoc(dtVALID),"N","0",fonteData) //Data validade
	MSCBSAY(29,18,dtoc(dtVALID),"N","0",fonteData) //Data validade - Alterado por Fabian Maurer no dia 16/08/19

	//MSCBSAY(42,16,'Tara:'+alltrim(valor4)+'g',"N","0",fonteDesc) // tara - Alterado por Fabian Maurer no dia 16/08/19
	MSCBSAY(47,16,'Tara:'+alltrim(valor4)+'g',"N","0",fonteDesc) // tara - Alterado por Fabian Maurer no dia 16/08/19

	_Linha2 := ZZ7->ZZ7_PRTCOM

	//MSCBSAY(pos,28,'Registro no Ministerio da Agricultura/SIF/',"N","0",fonteDesc)//REGISTRO NO
	MSCBSAY(pos,22,'Registro no Ministerio da Agricultura/SIF/',"N","0",fonteDesc)//REGISTRO NO - Alterado por Fabian Maurer no dia 16/08/19
	//MSCBSAY(pos,31,'DIPOA sob nr '+ZZ7->ZZ7_MSIF,"N","0",fonteDesc)//REGISTRO NO  
	MSCBSAY(pos,25,'DIPOA sob nr '+ZZ7->ZZ7_MSIF,"N","0",fonteDesc)//REGISTRO NO - Alterado por Fabian Maurer no dia 16/08/19

// Esse bloco era fontelinha9	
	if (_MSIF $ _sif07) .or. (_MSIF $ _sif07_2)
		//MSCBSAY(pos,35,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"N","0",fonteDesc)
		MSCBSAY(pos,29,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19
	elseif _MSIF $ _sif12
		//MSCBSAY(pos,35,'MANTER CONGELADA A -12 GRAUS CELSIUS',"N","0",fonteDesc)
		MSCBSAY(pos,29,'MANTER CONGELADA A -12 GRAUS CELSIUS',"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19
	elseif _MSIF $ _sif18
		//MSCBSAY(pos,35,'MANTER CONGELADA A -18 GRAUS CELSIUS',"N","0",fonteDesc)
		MSCBSAY(pos,29,'MANTER CONGELADA A -18 GRAUS CELSIUS',"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19
	elseif _MSIF $ _sif04
		//MSCBSAY(pos,35,'MANTER RESFRIADA DE 0 a 4 GRAUS CELSIUS',"N","0",fonteDesc)
		MSCBSAY(pos,29,'MANTER RESFRIADA DE 0 a 4 GRAUS CELSIUS',"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19
	endif 

	//MSCBSAY(pos,39,'Informacoes nutricionais:',"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19
	MSCBSAY(pos,32,'Informacoes nutricionais:',"N","0",fonteDesc)	
	//MSCBSAY(29,32,substr(alltrim(_Linha2),1,18),"N","0",fonteDesc)
	MSCBSAY(38,32,substr(alltrim(_Linha2),1,18),"N","0",fonteDesc)

	//MSCBSAY(pos,41,substr(alltrim(_Linha2),16,38),"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19
	MSCBSAY(pos,34,substr(alltrim(_Linha2),16,38),"N","0",fonteDesc)
	_Linha3 := 'Valor energ.'+alltrim(ZZ7->ZZ7_CALQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_CALVD)+' VD);'+'Gord. Trans.'+alltrim(ZZ7->ZZ7_GTRTP)+space(1)+'('+alltrim(ZZ7->ZZ7_GTRVD)+' VD) ;'+'Carboidratos :'+alltrim(ZZ7->ZZ7_CARQTP)+'('+alltrim(ZZ7->ZZ7_CARVD)+' VD) ; Fibra Alim.' + alltrim(ZZ7->ZZ7_FIAQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_FIAVD)+' VD);'+'Proteinas'+alltrim(ZZ7->ZZ7_PROQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_PROVD)+' VD) ;'+'Sodio'+alltrim(ZZ7->ZZ7_SODQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_SODVD)+' VD) ; Gorduras Tot.'+alltrim(ZZ7->ZZ7_GTQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_GTVD)+' VD);'+'Gord. Satur.'+alltrim(ZZ7->ZZ7_GSQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_GSVD)+' VD);'

	tam4:=len(substr(alltrim(_Linha3),1,51))
	tam5:=len(substr(alltrim(_Linha3),52,50))
	tam6:=len(substr(alltrim(_Linha3),102,47))
	tam7:=len(substr(alltrim(_Linha3),149,50))

	_nposi4 :=48-tam4
	_nposi5 :=47-tam5
	_nposi6 :=45-tam6
	_nposi7 :=51-tam7

	// Nova tentativ de bloco
	_L99 := 'Valor energ.'+alltrim(ZZ7->ZZ7_CALQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_CALVD)+' VD);'+'Gord. Trans.'+alltrim(ZZ7->ZZ7_GTRTP)+space(1)+'('+alltrim(ZZ7->ZZ7_GTRVD)+' VD) ;'
	_L101 :='Carboidratos :'+alltrim(ZZ7->ZZ7_CARQTP)+'('+alltrim(ZZ7->ZZ7_CARVD)+' VD) ;'+' Fibra Alim.' + alltrim(ZZ7->ZZ7_FIAQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_FIAVD)+' VD);'
	_L103 :='Proteinas'+alltrim(ZZ7->ZZ7_PROQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_PROVD)+' VD) ;'+'Sodio'+alltrim(ZZ7->ZZ7_SODQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_SODVD)+' VD) ;'
	_L105 :=' Gorduras Tot.'+alltrim(ZZ7->ZZ7_GTQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_GTVD)+' VD);'+'Gord. Satur.'+alltrim(ZZ7->ZZ7_GSQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_GSVD)+' VD);'

	//MSCBSAY(pos,43,_L99,"N","0",fonteDesc)
	MSCBSAY(pos,36,_L99,"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19
	//MSCBSAY(pos,47,_L101,"N","0",fonteDesc)
	MSCBSAY(pos,40,_L101,"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19
	//MSCBSAY(pos,51,_L103,"N","0",fonteDesc)
	MSCBSAY(pos,44,_L103,"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19
	//MSCBSAY(pos,55,_L105,"N","0",fonteDesc)
	MSCBSAY(pos,48,_L105,"N","0",fonteDesc) // Alterado por Fabian Maurer no dia 16/08/19

	/* Bloco Alterado por Fabian Maurer no dia 16/08/19	
	MSCBSAY(pos,58,'(*)Valores diarios de referencia com base em ',"N","0",fonteDesc)
	MSCBSAY(pos,60,'uma dieta de 2.000kcal, ou 8400 kJ. Seus valores',"N","0",fonteDesc)
	MSCBSAY(pos,62,'diarios podem ser maiores ou menores depen-',"N","0",fonteDesc)
	MSCBSAY(pos,64,'dendo de suas necessidades energeticas. Apos',"N","0",fonteDesc)
	MSCBSAY(pos,66,'aberto consumir em ate 2 dias.',"N","0",fonteDesc)
	*/ 
	MSCBSAY(pos,51,'(*)Valores diarios de referencia com base em ',"N","0",fonteDesc)
	MSCBSAY(pos,53,'uma dieta de 2.000kcal, ou 8400 kJ. Seus valores',"N","0",fonteDesc)
	MSCBSAY(pos,55,'diarios podem ser maiores ou menores depen-',"N","0",fonteDesc)
	MSCBSAY(pos,57,'dendo de suas necessidades energeticas. ',"N","0",fonteDesc)
	MSCBSAY(pos,59,'Apos aberto consumir em ate 2 dias.',"N","0",fonteDesc)

	tam7:=len(substr(alltrim(ZZ7->ZZ7_INGRED),01,49))
	tam8:=len(substr(alltrim(ZZ7->ZZ7_INGRED),50,50))
	tam9:=len(substr(alltrim(ZZ7->ZZ7_INGRED),100,49))
	tam10:=len(substr(alltrim(ZZ7->ZZ7_INGRED),149,51))
	tam11:=len(substr(alltrim(ZZ7->ZZ7_INGRED),200,25))

	posi7 :=48-tam7
	posi8 :=49-tam8
	posi9 :=48-tam9
	posi10:=49-tam10
	posi11:=52-tam11

	//MSCBSAY(pos,69,'INGREDIENTES:',"N","0",fonteDesc)
	MSCBSAY(pos,62,'INGREDIENTES:',"N","0",fonteDesc) //Alterado por Fabian Maurer no dia 16/08/19

	/* Bloco Alterado por Fabian Maurer em 16/08/19
	MSCBSAY(pos,71,substr(alltrim(ZZ7->ZZ7_INGRED),01,50)+'-',"N","0",fonteDesc)
	MSCBSAY(pos,73,substr(alltrim(ZZ7->ZZ7_INGRED),50,50)+'-',"N","0",fonteDesc)
	MSCBSAY(pos,75,substr(alltrim(ZZ7->ZZ7_INGRED),100,49),"N","0",fonteDesc)
	MSCBSAY(pos,77,substr(alltrim(ZZ7->ZZ7_INGRED),149,51),"N","0",fonteDesc)
	MSCBSAY(pos,79,substr(alltrim(ZZ7->ZZ7_INGRED),200,51),"N","0",fonteDesc)
	*/
	MSCBSAY(pos,64,substr(alltrim(ZZ7->ZZ7_INGRED),01,50)+'-',"N","0",fonteDesc)
	MSCBSAY(pos,66,substr(alltrim(ZZ7->ZZ7_INGRED),50,50)+'-',"N","0",fonteDesc)
	MSCBSAY(pos,68,substr(alltrim(ZZ7->ZZ7_INGRED),100,49),"N","0",fonteDesc)
	MSCBSAY(pos,70,substr(alltrim(ZZ7->ZZ7_INGRED),149,51),"N","0",fonteDesc)
	MSCBSAY(pos,72,substr(alltrim(ZZ7->ZZ7_INGRED),200,51),"N","0",fonteDesc)

	/* Bloco Alterado por Fabian Maurer em 16/08/19
	MSCBSAY(pos,81,'PROIBIDO FRACIONAMENTO.',"N","0",fonteDesc)
	MSCBSAY(pos,84,'NÃO CONTEM GLUTEN.',"N","0",fonteDesc)
	MSCBSAY(pos,87,'ALÉRGICOS:PODE CONTER DERIVADOS DE SOJA.',"N","0",fonteDesc) // Feito por Daniel 06-05-19
	//MSCBSAY(pos,87,'NÃO CONTEM ALERGENICOS.',"N","0",fonteDesc)
	*/

	//Inicio de alteração feita por Lucas Bolzan 13/09/22
	MSCBSAY(pos,69, ZZ7->ZZ7_INGRE2,"N","0",fonteDesc)
	//Fim de alteração feita por Lucas Bolzan 13/09/22

	MSCBSAY(pos,74,'PROIBIDO FRACIONAMENTO.',"N","0",fonteDesc)
	MSCBSAY(pos,77,'NÃO CONTEM GLUTEN.',"N","0",fonteDesc)
	MSCBSAY(pos,80,'ALÉRGICOS:PODE CONTER DERIVADOS DE SOJA.',"N","0",fonteDesc)

return

Static Function GetqExt()

	// Função responsável por gerar a tabela nutricional por extenso conforme solicitação da Lucinéia

	_Tabnutr := 'Valor energ.'+alltrim(ZZ7->ZZ7_CALQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_CALVD)+' VD);'+'Gord. Trans.'+alltrim(ZZ7->ZZ7_GTRTP)+space(1)+'('+alltrim(ZZ7->ZZ7_GTRVD)+' VD) ;'+'Carboidratos'+alltrim(ZZ7->ZZ7_CARQTP)+'('+alltrim(ZZ7->ZZ7_CARVD)+' VD) ; Fibra Alim.' + alltrim(ZZ7->ZZ7_FIAQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_FIAVD)+' VD);'+'Proteinas'+alltrim(ZZ7->ZZ7_PROQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_PROVD)+' VD) ;'+'Sodio'+alltrim(ZZ7->ZZ7_SODQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_SODVD)+' VD) ; Gorduras Tot.'+alltrim(ZZ7->ZZ7_GTQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_GTVD)+' VD);'+'Gord. Satur.'+alltrim(ZZ7->ZZ7_GSQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_GSVD)+' VD);'	

	tam4:=len(substr(alltrim(_Tabnutr),1,86))
	tam5:=len(substr(alltrim(_Tabnutr),87,85))
	tam6:=len(substr(alltrim(_Tabnutr),172,85))

	_nposi4 :=89-tam4
	_nposi5 :=88-tam5
	_nposi6 := 75-tam6

	/*
	MSCBSAY(28,_nposi4,substr(_Tabnutr,1,86),"B","0",fontelinha9)
	MSCBSAY(30,_nposi5,substr(_Tabnutr,87,85),"B","0",fontelinha9)
	MSCBSAY(32,_nposi6,substr(_Tabnutr,172,85),"B","0",fontelinha9)

	MSCBSAY(34,12,'(*)VALORES DIARIOS DE REFERENCIA COM BASE EM UMA DIETA DE 2.000kcal,',"B","0",fontelinha9)
	MSCBSAY(36,16,'OU 8400 kJ.SEUS VALORES DIARIOS PODEM SER MAIORES OU MENORES',"B","0",fontelinha9)
	MSCBSAY(38,29,'DEPENDENDO DE SUAS NECESSIDADES ENERGETICAS.',"B","0",fontelinha9)
	MSCBSAY(40,38,'APOS ABERTO CONSUMIR EM ATE 2 DIAS.',"B","0",fontelinha9)

	tam1:=len(substr(alltrim(ZZ7->ZZ7_INGRED),01,75))
	tam2:=len(substr(alltrim(ZZ7->ZZ7_INGRED),77,89))
	tam3:=len(substr(alltrim(ZZ7->ZZ7_INGRED),167,75))

	posi1 :=71-tam1
	posi2 :=85-tam2
	posi3 :=76-tam3

	MSCBSAY(42,58,'INGREDIENTES:',"B","0",fontelinha9) 
	MSCBSAY(42,posi1,substr(alltrim(ZZ7->ZZ7_INGRED),01,75),"B","0",fontelinha9)
	MSCBSAY(44,posi2,substr(alltrim(ZZ7->ZZ7_INGRED),77,89),"B","0",fontelinha9)
	MSCBSAY(46,posi3,substr(alltrim(ZZ7->ZZ7_INGRED),167,75),"B","0",fontelinha9)

	MSCBSAY(48,26,'ADICIONADA DE 10% DE SOLUÇÃO DE ÁGUA E ADITIVOS.',"B","0",fontelinha9)
	MSCBSAY(48,3,'PROIBIDOS FRACIONAMENTO.',"B","0",fontelinha9)
	*/
return   
