#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI145  บ Autor ณ Mateus Escobar       บ Data ณ  07/03/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao de etiqueta interna desejada                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Desossa                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function DTI145()
	
	//Local _dDataF := Date()
	//Local _dDT := Stod('20201219')
	dbselectarea('ZZ7')
	dbsetorder(1)
	
	/* colocar mensagem para desativar a rotina
	Levantando em quais menus esta rotina ainda esta ativa...
	Fazer regra para usuแrios da desossa e Porcionados
	
	IF _dDataF < _dDT
		alert('Esta Rotina Serแ  desativada em 19/12/19, Favor Entrar em contato com o Setor de DTI Para Mais Exclarescimentos ! Acione o DTI!')
	else 
		alert('Rotina Desativada ! Utilize a nova rotina de Impressใo de Etiquetas Internas')
		Return .T.
	Endif
	*/
	
	campoA  := space(06)  //campo do codigo do produto
	campoB  := space(08) //campo da data da produ็ใo
	campoC 	:= space(40) //campo da descri็ใo do corte
	campoD 	:= space(05) // campo da tara para impressใo na etiqueta
	campoE 	:= 000
	//campoF 	:= {"XXXXX","Macho","Femea","     "}//sexo
	campoG  := {"Interno","Externo"}// Pergunta criada por Fabian Maurer para definir a mensagem do Ministerio 

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

	/*
	_dDTMaior   := date() + 365
	_dDTMenor	:= date() - 365
	*/
	
	
	
	valor1 	:= '      ' 	//codigo do produto
	valor2 	:= date()   	//data de produ็ใo
	valor3 	:= space(40) //Descri็ใo do corte
	//valor4 	:= '   '   //Tara
	valor4 	:= space(05)   //Tara
	valor5 	:= 000     //Quantidade de etiqueta
	valor6 	:= 'XXXXX'  //Sexo
	valor7   := space(07)//Pergunta criada por Fabian Maurer para definir a mensagem do Ministerio   
	valor8	:= date()  //Data de Embalagem

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA INTERNA-Nบ DESEJADO"
	//vincula็ใo dos campos com os valores
	//alert('linha 86')
	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Data Produ็ใo:" of telaimp
	@ 03,01 SAY "Data Embalagem:" of telaimp
	@ 04,01 SAY "Descri็ใo Corte:" of telaimp
	@ 05,01 SAY "Tara:" of telaimp
	@ 06,01 SAY "Quant. Etiquetas:" of telaimp
	//@ 06,01 SAY "Sexo:" of telaimp
	@ 07,01 SAY "Tipo Mercado:" of telaimp

	@ 01,08 MSGET campoA VAR valor1 SIZE 20,10 F3 'ZZ7' OF telaimp VALID iif(!existcpo('ZZ7'),fbf01clear(),.t.)
	@ 02,08 MSGET campoB VAR valor2 SIZE 40,10  OF telaimp valid valor2 >= _dDTMenor .and. valor2 <= _dDTMaior// data producao
	@ 03,08 MSGET campoF VAR valor8 SIZE 40,10  OF telaimp valid valor8 >= _dDTMenor .and. valor8 <= _dDTMaior// data embalagem
	//@ 02,08 SAY valor2 of telaimp
	@ 04,08 SAY valor3 of telaimp // Descri็ใo
	//@ 05,08 MSGET campoD VAR valor4 SIZE 20,10  OF telaimp // Tara
	@ 05,08 SAY valor4 OF telaimp // Tara
	@ 06,08 MSGET campoE VAR valor5 SIZE 20,10  OF telaimp  picture '@E 999'  // quant etiqueta
	//@ 06,08 COMBOBOX valor6 items campoF SIZE 40,08 OF telaimp      // Sexo
	@ 07,08 COMBOBOX valor7 items campoG SIZE 40,08 OF telaimp
	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action fbf01etq()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()
	//@ 20,110 BUTTON btn3 PROMPT "Alterar Data" SIZE 50,15 OF telaimp  pixel action fbf01dat()
	campoA:bLostFocus := {|| fbf01prc() }
	ACTIVATE MSDIALOG telaimp CENTERED

return



static Function fbf01etq()

	pos :=0

	if empty(valor1) .or. empty(valor2) .or. empty(valor3) .or. empty(valor4) .or. empty(valor5) .or. empty(valor8)
		Alert('Campos em branco!')
		return
	endif

	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7')+valor1))

	_nQetq  :=  valor5

	_cEst := getComputerName()    
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


	//MSCBPRINTER('S600','IP',,,,,'10.11.20.150') //Impressใo por IP feita por Flแvio para teste
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nQetq,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas VALOR5                           
	//MSCBBEGIN(2,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas VALOR5                           

	// Tamnho dos fontes na etiqueta
	//GeraTamFontes()
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
	//Gera็ใo do cabe็alho da Etiqueta



	GeraCabecalho()
	//Toda estrutura do layout | Fun็ใo criada para imprimir a estrutura da tabela de valor Nutricional 
	GeraLayout()
	//2บ Linha
	Gera2Linha()

	//3ช Linha       
	Gera3Linha()              

	//4ช Linha   
	Gera4Linha()

	//5ช Linha
	Gera5Linha()

	//6ช Linha  
	Gera6Linha()

	MensagemSif(ZZ7->ZZ7_CODPRO)






	MSCBEND()
	MSCBCLOSEPRINTER()
	fbf01clear()

	msgbox('Impressใo de Etiquetas em Andamento!','Impressใo','INFO')

return   


static function fbf01prc()

	Local zabcod

	ZZ7->(dbsetorder(1))
	if ZZ7->(dbseek(xfilial('ZZ7')+valor1))
		valor3 := ZZ7->ZZ7_CORTE
		// Dia 23/06/21 Ajuste de tara
		zabcod  := FBuscaCPO('SB1',1,xfilial('SB1')+ alltrim(valor1),'B1_CTARAP')      		
		valor4 := FBuscaCPO('ZAB',1,xfilial('ZAB')+ alltrim(zabcod),'ZAB_TARA')
		
	endif
	telaimp:refresh()
return

static function fbf01clear()
	valor1   := space(06)
	valor2   := date()
	valor3   := space(20)
	//valor4   := '   '
	valor4 	:= space(05)   //Tara
	valor5   :=000
	valor6   := 'XXXXX'
	valor8   := date()
	telaimp:refresh()
return


Static Function GeraCab1()

	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=42-t
	MSCBSAY(2,pos,ZZ7->ZZ7_DESC,"B","0",fonteDesc)
	pos2:=0
	t2:=len(alltrim(valor3))
	pos2:=42-t2  

	DbSelectArea('SB1') 
	_cDestMerc := alltrim(valor7) //Criado por Fabian Maurer para definir tipo de mensagem de Autoriza็ใo do Ministerio 19/12/11 

	MSCBSAY(9,pos2,alltrim(valor3),"B","0",fontecorte) // nome do corte
	MSCBSAY(16,52,substr(dtos(valor2),7,2)+'/'+substr(dtos(valor2),5,2)+'/'+substr(dtos(valor2),3,2),"B","0",fonteData) //Data da producao
	_sif01 := GetMV('SI_SIFET01')
	_sif04 := GetMV('SI_SIFET04')
	_sif07 := GetMV('SI_SIFET07')
	_sif07_2 := GetMv('SI_SIFTE07')
	_sif07_3 := GetMv('SI_SIFT307')
	_sif12 := GetMV('SI_SIFET12')
	_sif18 := GetMV('SI_SIFET18')
	_MSIF  := substr(ZZ7->ZZ7_MSIF,1,4)
	alert(_MSIF)
	if (_MSIF $ _sif07) .or. (_MSIF $ _sif07_2) .or. (_MSIF $ _sif07_3)
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif12
		MSCBSAY(15,5,'MANTER CONGELADA A -12 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif18
		MSCBSAY(15,5,'MANTER CONGELADA A -18 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif04
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 4 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif01
		MSCBSAY(15,5,'MANTER RESFRIADA DE -1 a 1 GRAUS CELSIUS',"B","0",fonteMesTemp1)	
	endif 

	MSCBSAY(21,49,dtoc(dtVALID),"B","0",fonteData) //Data validade
	MSCBSAY(21,24,valor6,"B","0",fonteNomeCorte1)// Sexo
	/* Dia 17/06/21 - Ajuste para buscar tara do cadastro
	MSCBSAY(21,13,alltrim(valor4)+'g',"B","0",fonteNomeCorte1)//tara
	*/
	MSCBSAY(21,13,alltrim(valor4)+'g',"B","0",fonteNomeCorte1)//tara
	
	//Criado Fabian Maurer para identificar o tipo de mensagem do Ministerio 19/12/11 
	if alltrim(_cDestMerc) $ "Externo"
		MSCBSAY(24,14,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fontelinha9)//REGISTRO NO
		//MSCBSAY(24,9,'USO AUTORIZADO PELO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fontelinha9)////COMENTADO DIA 21/10/19 e incluido a frase acima por solicita็ใo da Valeska
	else 	
		MSCBSAY(24,14,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fontelinha9)//REGISTRO NO 
	endif

	//MSCBSAY(27,41,'INFORMACOES NUTRICIONAIS',"B","0",fontelinha9)
	//MSCBSAY(27,03,ZZ7->ZZ7_PRTCOM,"B","0",fontelinha9)
	MSCBSAY(26,46,'INFORMACOES NUTRICIONAIS',"B","0",fontelinha9)
	MSCBSAY(26,15,ZZ7->ZZ7_PRTCOM,"B","0",fontelinha9)

return

Static Function GeraCabecalho()

	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=42-t
	MSCBSAY(2,pos,ZZ7->ZZ7_DESC,"B","0",fonteDesc)
	pos2:=0
	t2:=len(alltrim(valor3))
	pos2:=42-t2  

	DbSelectArea('SB1') 
	_cDestMerc := alltrim(valor7) //Criado por Fabian Maurer para definir tipo de mensagem de Autoriza็ใo do Ministerio 19/12/11 

	MSCBSAY(9,pos2,alltrim(valor3),"B","0",fontecorte) // nome do corte
	MSCBSAY(16,52,substr(dtos(valor2),7,2)+'/'+substr(dtos(valor2),5,2)+'/'+substr(dtos(valor2),3,2),"B","0",fonteData) //Data da producao
	_sif01 := GetMV('SI_SIFET01')
	_sif04 := GetMV('SI_SIFET04')
	_sif07 := GetMV('SI_SIFET07')
	_sif07_2 := GetMv('SI_SIFTE07')
	_sif07_3 := GetMv('SI_SIFT307')
	_sif12 := GetMV('SI_SIFET12')
	_sif18 := GetMV('SI_SIFET18')
	_MSIF  := substr(ZZ7->ZZ7_MSIF,1,4)

	if (_MSIF $ _sif07) .or. (_MSIF $ _sif07_2) .or. (_MSIF $ _sif07_3)
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif12
		MSCBSAY(15,5,'MANTER CONGELADA A -12 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif18
		MSCBSAY(15,5,'MANTER CONGELADA A -18 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif04
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 4 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif01
		MSCBSAY(15,5,'MANTER RESFRIADA DE -1 a 1 GRAUS CELSIUS',"B","0",fonteMesTemp1)	
	endif 

	//MSCBSAY(21,52,substr(dtos(dtVALID),7,2)+'/'+substr(dtos(dtVALID),5,2)+'/'+substr(dtos(dtVALID),3,2),"B","0",fonteData) //Data validade
	MSCBSAY(21,49,dtoc(dtVALID),"B","0",fonteData) //Data validade
	MSCBSAY(21,24,valor6,"B","0",fonteNomeCorte1)// Sexo
	
	/* Dia 17/06/21 - Ajuste para buscar tara do cadastro a pedido de Andr้ PCP
	MSCBSAY(21,13,alltrim(valor4)+'g',"B","0",fonteNomeCorte1)//tara
	
	*/
	//MSCBSAY(21,13,alltrim(valor4)+'g',"B","0",fonteNomeCorte1)//tara
	MSCBSAY(21,03,str(valor4)+' kg',"B","0",fonteNomeCorte1)//tara
	
	//Criado Fabian Maurer para identificar o tipo de mensagem do Ministerio 19/12/11 
	if alltrim(_cDestMerc) $ "Externo"
		MSCBSAY(24,05,'USO AUTORIZADO PELO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)	
	else 	
		MSCBSAY(24,07,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)//REGISTRO NO 
	endif

	MSCBSAY(27,41,'INFORMACOES NUTRICIONAIS',"B","0",fonteInfNutri1)
	MSCBSAY(27,03,ZZ7->ZZ7_PRTCOM,"B","0",fonteInfNutri1)


return

Static Function Tabnutri()  

	// 012772
	Gera2Linha()
	Gera3Linha()                 
	Gera4Linha()
	Gera5Linha()  
	Gera6Linha()		
	// MensagemSif()       



	MSCBBOX(26,2,53,70,4)
	MSCBBOX(29,2,29,70,3)
	MSCBLineH(29,42,44,3,"B")//1ช Barra vertical
	MSCBLineH(32,57,44,3,"B")//1ช Barra vertical
	MSCBLineH(29,33,44,3,"B")//3ช Barra vertical         
	MSCBLineH(32,20,44,3,"B")//4ช Barra vertical
	MSCBLineH(29,10,44,3,"B")//5ช Barra vertical                             
	MSCBLineV(32,3,70,3,"B")// essa linha esta fazendo a horizontal (Y,X1,X2)
	MSCBLineV(35,3,70,3,"B")// essa linha esta fazendo a horizontal (Y,X1,X2)
	MSCBLineV(38,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)
	MSCBLineV(41,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)
	MSCBLineV(44,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)


return


Static Function GeraLayout()

	MSCBBOX(26,2,53,70,4)
	MSCBBOX(29,2,29,70,3)
	MSCBLineH(29,42,44,3,"B")//1ช Barra vertical
	MSCBLineH(32,57,44,3,"B")//1ช Barra vertical
	MSCBLineH(29,33,44,3,"B")//3ช Barra vertical         
	MSCBLineH(32,20,44,3,"B")//4ช Barra vertical
	MSCBLineH(29,10,44,3,"B")//5ช Barra vertical                             
	MSCBLineV(32,3,70,3,"B")// essa linha esta fazendo a horizontal (Y,X1,X2)
	MSCBLineV(35,3,70,3,"B")// essa linha esta fazendo a horizontal (Y,X1,X2)
	MSCBLineV(38,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)
	MSCBLineV(41,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)
	MSCBLineV(44,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)


return      

Static Function Gera2Linha()

	MSCBSAY(30,49,'Quantidade por Porcao',"B","0",fonteInfNutri2)
	MSCBSAY(30,35,'%VD(*)',"B","0",fonteInfNutri2)
	MSCBSAY(30,12,'Quantidade por Porcao',"B","0",fonteInfNutri2)
	MSCBSAY(30,3,'%VD(*)',"B","0",fonteInfNutri2)

return      
Static Function Gera3Linha()

	MSCBSAY(33,57,'Valor energ.',"B","0",fonteInfNutri2) 
	MSCBSAY(33,43,ZZ7->ZZ7_CALQTP,"B","0",fonteInfNutri2) 
	MSCBSAY(33,36,ZZ7->ZZ7_CALVD,"B","0",fonteInfNutri2)
	MSCBSAY(33,21,'Gord. Trans.',"B","0",fonteInfNutri2)
	MSCBSAY(33,18,ZZ7->ZZ7_GTRTP,"B","0",fonteInfNutri2)
	MSCBSAY(33,9,ZZ7->ZZ7_GTRVD,"B","0",fonteInfNutri2)


return      
Static Function Gera4Linha()

	MSCBSAY(36,58,'Carboidratos',"B","0",fonteInfNutri2)
	MSCBSAY(36,47,ZZ7->ZZ7_CARQTP,"B","0",fonteNutri4)
	MSCBSAY(36,36,ZZ7->ZZ7_CARVD,"B","0",fonteInfNutri2)
	MSCBSAY(36,20,'Fibra Alim.',"B","0",fonteInfNutri2)
	MSCBSAY(36,14,ZZ7->ZZ7_FIAQTP,"B","0",fonteNutri4)
	MSCBSAY(36,5,ZZ7->ZZ7_FIAVD,"B","0",fonteInfNutri2)


return      
Static Function Gera5Linha()

	MSCBSAY(39,61,'Proteinas',"B","0",fonteInfNutri2)
	MSCBSAY(39,48,ZZ7->ZZ7_PROQTP,"B","0",fonteInfNutri2)
	MSCBSAY(39,36,ZZ7->ZZ7_PROVD,"B","0",fonteInfNutri2)
	MSCBSAY(39,25,'Sodio',"B","0",fonteInfNutri2)
	MSCBSAY(39,12,ZZ7->ZZ7_SODQTP,"B","0",fonteInfNutri2)
	MSCBSAY(39,5,ZZ7->ZZ7_SODVD,"B","0",fonteInfNutri2)

return      
Static Function Gera6Linha()

	MSCBSAY(42,57,'Gorduras Tot.',"B","0",fonteInfNutri2)
	MSCBSAY(42,48,ZZ7->ZZ7_GTQTP,"B","0",fonteInfNutri2)
	MSCBSAY(42,36,ZZ7->ZZ7_GTVD,"B","0",fonteInfNutri2)
	MSCBSAY(42,21,'Gord. Satur.',"B","0",fonteInfNutri2)
	MSCBSAY(42,15,ZZ7->ZZ7_GSQTP,"B","0",fonteInfNutri2)
	MSCBSAY(42,5,ZZ7->ZZ7_GSVD,"B","0",fonteInfNutri2)


return      


Static Function MensagemSif(_cod)

	MSCBSAY(45,12,'(*)VALORES DIARIOS DE REFERENCIA COM BASE EM UMA DIETA DE 2.000kcal,',"B","0",fontelinha9)
	MSCBSAY(47,16,'OU 8400 kJ.SEUS VALORES DIARIOS PODEM SER MAIORES OU MENORES',"B","0",fontelinha9)
	MSCBSAY(49,29,'DEPENDENDO DE SUAS NECESSIDADES ENERGETICAS.',"B","0",fontelinha9)
	// MSCBSAY(51,38,'APOS ABERTO CONSUMIR EM ATE 2 DIAS.',"B","0",fontelinha9) - Alterado para satisfazer a condi็ใo abaixo

	_exmetq   := GetMV('SI_EXMETQ')

	if (!_cod $ _exmetq)
		MSCBSAY(51,38,'APOS ABERTO CONSUMIR EM ATE 2 DIAS.',"B","0",fontelinha9)
	endif

return       

Static Function GetqExt()    

	// Fun็ใo responsแvel por gerar a tabela nutricional por extenso conforme solicita็ใo da Lucin้ia
	/*
	_Linha3 := 'Valor energ.'+alltrim(ZZ7->ZZ7_CALQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_CALVD)+' VD);'+'Gord. Trans.'+alltrim(ZZ7->ZZ7_GTRTP)+space(1)+'('+alltrim(ZZ7->ZZ7_GTRVD)+' VD) ;'+'Carboidratos'+alltrim(ZZ7->ZZ7_CARQTP)+'('+alltrim(ZZ7->ZZ7_CARVD)+' VD) ;'
	//MSCBSAY(29,9,substr(_Linha3,1,63),"B","0",fonteInfNutri2) 
	MSCBSAY(29,9,substr(_Linha3,1,63),"B","0",fontelinha9) 
	_linha4 := substr(_Linha3,64,80)+ 'Fibra Alim.' + alltrim(ZZ7->ZZ7_FIAQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_FIAVD)+' VD);'+'Proteinas'+alltrim(ZZ7->ZZ7_PROQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_PROVD)+' VD) ;'+'Sodio'+alltrim(ZZ7->ZZ7_SODQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_SODVD)+' VD) ;' 
	//MSCBSAY(31,3,substr(_Linha4,1,64)+'-',"B","0",fonteInfNutri2)// (validar com outro produto)
	MSCBSAY(31,3,substr(_Linha4,1,64)+'-',"B","0",fontelinha9)// (validar com outro produto)
	_linha5 := substr(_Linha4,65,90)+'Gorduras Tot.'+alltrim(ZZ7->ZZ7_GTQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_GTVD)+' VD);'+'Gord. Satur.'+alltrim(ZZ7->ZZ7_GSQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_GSVD)+' VD);'
	//MSCBSAY(33,3,substr(_linha5,1,66),"B","0",fonteInfNutri2)
	MSCBSAY(33,3,substr(_linha5,1,66),"B","0",fontelinha9)
	*/
	_Linha3 := 'Valor energ.'+alltrim(ZZ7->ZZ7_CALQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_CALVD)+' VD);'+'Gord. Trans.'+alltrim(ZZ7->ZZ7_GTRTP)+space(1)+'('+alltrim(ZZ7->ZZ7_GTRVD)+' VD) ;'+'Carboidratos'+alltrim(ZZ7->ZZ7_CARQTP)+'('+alltrim(ZZ7->ZZ7_CARVD)+' VD) ; Fibra Alim.' + alltrim(ZZ7->ZZ7_FIAQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_FIAVD)+' VD);'+'Proteinas'+alltrim(ZZ7->ZZ7_PROQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_PROVD)+' VD) ;'+'Sodio'+alltrim(ZZ7->ZZ7_SODQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_SODVD)+' VD) ; Gorduras Tot.'+alltrim(ZZ7->ZZ7_GTQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_GTVD)+' VD);'+'Gord. Satur.'+alltrim(ZZ7->ZZ7_GSQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_GSVD)+' VD);'	

	tam4:=len(substr(alltrim(_Linha3),1,86))
	tam5:=len(substr(alltrim(_Linha3),87,85))
	tam6:=len(substr(alltrim(_Linha3),172,85)) 


	_nposi4 :=89-tam4
	_nposi5 :=88-tam5
	_nposi6 := 75-tam6


	MSCBSAY(28,_nposi4,substr(_Linha3,1,86),"B","0",fontelinha9) 
	MSCBSAY(30,_nposi5,substr(_Linha3,87,85),"B","0",fontelinha9) 
	MSCBSAY(32,_nposi6,substr(_Linha3,172,85),"B","0",fontelinha9) 

	MSCBSAY(34,12,'(*)VALORES DIARIOS DE REFERENCIA COM BASE EM UMA DIETA DE 2.000kcal,',"B","0",fontelinha9)
	MSCBSAY(36,16,'OU 8400 kJ.SEUS VALORES DIARIOS PODEM SER MAIORES OU MENORES',"B","0",fontelinha9)
	MSCBSAY(38,29,'DEPENDENDO DE SUAS NECESSIDADES ENERGETICAS.',"B","0",fontelinha9)
	// MSCBSAY(40,38,'APOS ABERTO CONSUMIR EM ATE 2 DIAS.',"B","0",fontelinha9) - Alterado para satisfazer a condi็ใo abaixo

	_exmetq   := GetMV('SI_EXMETQ')
	_cod      := ZZ7->ZZ7_CODPRO

	if (!_cod $ _exmetq)
		MSCBSAY(40,38,'APOS ABERTO CONSUMIR EM ATE 2 DIAS.',"B","0",fontelinha9)
	endif

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

	MSCBSAY(48,26,'ADICIONADA DE 10% DE SOLUวรO DE มGUA E ADITIVOS.',"B","0",fontelinha9)
	MSCBSAY(48,3,'PROIBIDOS FRACIONAMENTO.',"B","0",fontelinha9)

return   
