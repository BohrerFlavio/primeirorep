#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI41   º Autor ³ Fabian Ferreira Maurer º Data ³ 07/08/17  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de etiqueta interna para Cliente confiare        º±±
±±º          ³  OBS - veio do fonte DTI41 ( Solicitado pela Grazi)        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desossa                                                    º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI115()

	dbselectarea('ZZ7')
	dbsetorder(1)

	campoA  := space(06)  //campo do codigo do produto
	campoB  := space(08) //campo da data da produção
	campoC 	:= space(40) //campo da descrição do corte
	campoD 	:= space(05) // campo da tara para impressão na etiqueta
	campoE 	:= 000
	campoG  := {"Interno","Externo"}// Pergunta criada por Fabian Maurer para definir a mensagem do Ministerio
	campoH 	:= 000
	campo1	:= space(06)  //campo do codigo do produto
	campo2	:= space(08) //campo da data da produção
	campo3	:= space(40) //campo da descrição do corte
	campo4	:= 000
	campo5	:= {"Interno","Externo"}// Pergunta criada por Fabian Maurer para definir a mensagem do Ministerio  
	
	_cUsuarios := getMv('SI_USRETQ')//parametro com os codigos dos usuarios que podem imprimir ETQ interna com data maior que DATABASE
	_cUsrPorc  := getMv('SI_ETQPRC')//parametro com os codigos de usuarios que podem imprimir com um intervalo de datas bem grande
	_cCodUser  := retCodUsr()

	private _nQTD   := 0
	private _nQtdCx := 0
	private _nQetq  := 0
	private _nQetq2 := 0

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


	valor1 	:= '      ' 	//codigo do produto
	valor2 	:= date()   	//data de produção
	valor3 	:= space(40) //Descrição do corte
	valor4 	:= 0.000   //Tara
	valor5 	:= 000     //Quantidade de etiqueta
	valor6 	:= 'XXXXX'  //Sexo
	valor7  := space(07)//Pergunta criada por Fabian Maurer para definir a mensagem do Ministerio
	valor8	:= date()  //Data de Embalagem
	valor9  := 000	
	valr1 	:= space(06)//codigo do produto
	valr2 	:= date()   	//data de produção
	valr3 	:= date()  //Data de Embalagem
	valr4 	:= space(40) //Descrição do corte
	valr5 	:= 0.000
	valr6 	:= 000
	valr7 	:= {"Interno","Externo"}// Pergunta criada por Fabian Maurer para definir a mensagem do Ministerio  
	valr8  	:= 000


	
	DEFINE MSDIALOG telaimp2 FROM 0,0 TO 450,260 PIXEL TITLE "IMPRESSAO DE ETIQUETA INTERNA NOVAS"
	//vinculação dos campos com os valores

	T1()
	
	@ 140,15 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp2  pixel action dti115etq()
	@ 140,70 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp2  pixel action telaimp2:end()
	
	ACTIVATE MSDIALOG telaimp2 CENTERED

return


Static Function dti41vl()
	
	_nQTD   := 0
	_nQtdCx := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(valor1),'B1_QCAIX')
	_nQetq  := _nQtdCx * valor5
	_nQTD   := _nQetq
	valor9  := _nQTD

return 

Static Function dti115etq()

	pos :=0
	_cPrevde := 'N'
	_cEst := getComputerName()
	_cIp  := ''
	_cIp2 := ''
	
	//Primeira Tela
	if !empty(valor1)
		
		if empty(valor2) .or. empty(valor3) .or. valor4 <= 0  .or. empty(valor5) .or. empty(valor8)
			
			Alert('Campos Da impressora da esquerda em branco!')
			return
			
		Else
			
			/* Verificação quanto a previsão de produção*/
			_nImpE  := GetMV('SI_DTI411')			
			putmv('SI_DTI411',_nImpE+1)
			//IP1 - Primeira impressora ZAM_IP
			U_QtPrv(valor2,alltrim(valor3),valor8,valor1)
			dbselectarea('ZAM')
			ZAM->(dbSetOrder(2))		
			    			
			if ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
				_nImpE := 0
				_cIp := alltrim(ZAM->ZAM_IP)				
				imp1(_cIp,alltrim(valor1))				
			endif			
		endif
	Endif
	
	/* Verificação quanto a previsão de produção*/
	// Segunda Tela
	if !Empty(alltrim(valr1)) .AND. !Empty(alltrim(valr4)) .AND. !Empty(valr2) .AND. !Empty(valr3)
		
		//_nImpD  := GetMV('SI_DTI412')		
		//putmv('SI_DTI412',_nImpD+1)
		
		U_QtPrv(valr2,alltrim(valr4),valr3,alltrim(valr1))
		//IP1 - Primeira impressora ZAM_IP2
		dbselectarea('ZAM')
		ZAM->(dbSetOrder(3))
		if ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
			
			_nImpD := 0
			_cIp2 := alltrim(ZAM->ZAM_IP2)			 	
			//sleep(1000)			
			imprime2(_cIp2,alltrim(valr1))
			
			
		endif
		
		
	Endif
	
		 
	//_cIp := '10.11.20.43'
	//_cIp2 := '10.11.20.159'
	 
	dti41clear()
	dti41cl2()
	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

return


static function dti41prc()    

	ZZ7->(dbsetorder(1))
	if ZZ7->(dbseek(xfilial('ZZ7')+valor1))
		valor3 := ZZ7->ZZ7_CORTE	
	endif

	dbSelectArea('SB1')

	// Inicio bloco inserido por Fabian Maurer para levar a tara automatica do cadastro de produto, solicitação Matheus Silva dia 07/08/17
	_nTaraP := FBuscaCPO('SB1',1,xfilial('SB1')+ alltrim(valor1),'B1_CTARAP')      // Linhas inseridas para buscar"_NTARAp"
	_nTP    := FBuscaCPO('ZAB',1,xfilial('ZAB')+alltrim(_nTaraP),'ZAB_TARA')  // os campos de codigo das taras primarias
	//valor4  := transform(_nTP,'@E 9.999')
	valor4  := (_nTP * 1000)
	// Fim do bloco inserido por Fabian Maurer
	telaimp2:refresh()
return

static function dti41clear()
	valor1   := space(06)
	valor2   := date()
	valor3   := space(20)
	valor4   := 0.000
	valor5   :=000
	valor6   := 'XXXXX'
	valor8   := date()
	telaimp2:refresh()
return


static function dti41cl2()
	valr1   := space(06)
	valr2   := date()
	valr3   := date()
	valr4   := space(20)
	valr5   := 000
	valr6   := 0.000
	valr8   := 000
	
	telaimp2:refresh()
	
return


Static Function GeraCab1()

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

	_sif01 := GetMV('SI_SIFET01')
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
	elseif _MSIF $ _sif01
		MSCBSAY(15,5,'MANTER RESFRIADA DE -1 a 1 GRAUS CELSIUS',"B","0",fonteMesTemp1)	
	endif

	MSCBSAY(21,49,dtoc(dtVALID),"B","0",fonteData) //Data validade
	MSCBSAY(21,24,valor6,"B","0",fonteNomeCorte1)// Sexo
	MSCBSAY(21,8,str(val(strtran(valor4,'.','')))+'g',"B","0",fonteNomeCorte1)//tara
	//Criado Fabian Maurer para identificar o tipo de mensagem do Ministerio 19/12/11
	if alltrim(_cDestMerc) $ "Externo"
		MSCBSAY(24,14,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fontelinha9)//REGISTRO NO
		//MSCBSAY(24,9,'USO AUTORIZADO PELO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fontelinha9) //COMENTADO DIA 21/10/19 e incluido a frase acima por solicitação da Valeska 
	else
		MSCBSAY(24,14,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fontelinha9)//REGISTRO NO
	endif

	
	MSCBSAY(26,46,'INFORMACOES NUTRICIONAIS',"B","0",fontelinha9)
	MSCBSAY(26,15,ZZ7->ZZ7_PRTCOM,"B","0",fontelinha9)

return


Static Function GeraCabecalho()
	
	//ZZ7_DESC := fBuscaCPO('ZZ7',1,xfilial('ZZ7') + _cCodp,'ZZ7_DESC')
	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=42-t
	
	
	MSCBSAY(2,7,ZZ7->ZZ7_DESC,"N","0",fonteDesc)
	
	pos2:=0
	t2:=len(alltrim(valor3))
	pos2:=42-t2

	DbSelectArea('SB1')
	_cDestMerc := alltrim(valor7) //Criado por Fabian Maurer para definir tipo de mensagem de Autorização do Ministerio 19/12/11

	
	MSCBSAY(6,10,alltrim(valor3),"N","0",fontecorte) // nome do corte
	MSCBSAY(2,15,'Data de Producao/Lote:'+substr(dtos(valor2),7,2)+'/'+substr(dtos(valor2),5,2)+'/'+substr(dtos(valor2),3,2),"N","0",fonteData) //Data da producao
	_sif01 	 := GetMV('SI_SIFET01')
	_sif04 	 := GetMV('SI_SIFET04')
	_sif07 	 := GetMV('SI_SIFET07')
	_sif07_2 := GetMv('SI_SIFTE07')
	_sif12 	 := GetMV('SI_SIFET12')
	_sif18 	 := GetMV('SI_SIFET18')
	_MSIF  	 := substr(ZZ7->ZZ7_MSIF,1,4)

	
	
	MSCBSAY(2,17,'Data de Validade:'+dtoc(dtVALID),"N","0",fonteData) //Data validade	
	MSCBSAY(2,19,'Data de Embalagem:'+dtoc(date()),"N","0",fonteData) //Data embalagem	
	
	if (_MSIF $ _sif07) .or. (_MSIF $ _sif07_2)		
		MSCBSAY(02,22,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"N","0",fonteMesTemp1)
	elseif _MSIF $ _sif12		
		MSCBSAY(02,22,'MANTER CONGELADA A -12 GRAUS CELSIUS',"N","0",fonteMesTemp)
	elseif _MSIF $ _sif18		
		MSCBSAY(02,22,'MANTER CONGELADA A -18 GRAUS CELSIUS',"N","0",fonteMesTemp)
	elseif _MSIF $ _sif04		
		MSCBSAY(02,22,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"N","0",fonteMesTemp1)
	elseif _MSIF $ _sif01				
		MSCBSAY(02,22,'MANTER RESFRIADA DE -1 a 1 GRAUS CELSIUS',"N","0",fonteMesTemp1)
	endif
	
	
	if alltrim(_cDestMerc) $ "Externo"	
		MSCBSAY(2,24,'USO AUTORIZADO PELO MINISTERIO DA AGRICULTURA/SIF/DIPOA',"N","0",fonteInscSIF)
		MSCBSAY(2,26,' SOB Nr '+ZZ7->ZZ7_MSIF,"N","0",fonteInscSIF)
	else	
		MSCBSAY(2,24,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA',"N","0",fonteInscSIF)//REGISTRO NO
		MSCBSAY(2,26,'SOB Nr '+ZZ7->ZZ7_MSIF,"N","0",fonteInscSIF)//REGISTRO NO
	endif
	
return

Static Function GeraCab2()

	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=42-t
	MSCBSAY(2,pos,ZZ7->ZZ7_DESC,"B","0",fonteDesc)
	pos2:=0
	t2:=len(alltrim(valr4))
	pos2:=42-t2

	DbSelectArea('SB1')
	_cDestMerc := alltrim(valor7) //Criado por Fabian Maurer para definir tipo de mensagem de Autorização do Ministerio 19/12/11

	MSCBSAY(9,pos2,alltrim(valr4),"B","0",fontecorte) // nome do corte
	MSCBSAY(16,52,substr(dtos(valr2),7,2)+'/'+substr(dtos(valr2),5,2)+'/'+substr(dtos(valr2),3,2),"B","0",fonteData) //Data da producao
	_sif01 	 := GetMV('SI_SIFET01')
	_sif04 	 := GetMV('SI_SIFET04')
	_sif07 	 := GetMV('SI_SIFET07')
	_sif07_2 := GetMv('SI_SIFTE07')
	_sif12 	 := GetMV('SI_SIFET12')
	_sif18 	 := GetMV('SI_SIFET18')
	_MSIF  	 := substr(ZZ7->ZZ7_MSIF,1,4)

	if (_MSIF $ _sif07) .or. (_MSIF $ _sif07_2)
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif12
		MSCBSAY(15,5,'MANTER CONGELADA A -12 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif18
		MSCBSAY(15,5,'MANTER CONGELADA A -18 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif04
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif01
		MSCBSAY(15,5,'MANTER RESFRIADA DE -1 a 1 GRAUS CELSIUS',"B","0",fonteMesTemp1)		
	endif

	
	MSCBSAY(21,49,dtoc(dtVALID),"B","0",fonteData) //Data validade
	MSCBSAY(21,24,valor6,"B","0",fonteNomeCorte1)// Sexo
	MSCBSAY(21,13,transform(valr5,'@E 99') + "g","B","0",fonteNomeCorte1)//tara
	
	
	//Criado Fabian Maurer para identificar o tipo de mensagem do Ministerio 19/12/11
	if alltrim(_cDestMerc) $ "Externo"
		MSCBSAY(24,05,'USO AUTORIZADO PELO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)
	else
		MSCBSAY(24,05,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)//REGISTRO NO
	endif

	MSCBSAY(27,41,'INFORMACOES NUTRICIONAIS',"B","0",fonteInfNutri1)
	MSCBSAY(27,03,ZZ7->ZZ7_PRTCOM,"B","0",fonteInfNutri1)

return


Static Function Tabnutri()

	// 012772
	
	Gera3Linha()
	Gera4Linha()
	Gera5Linha()
	Gera6Linha()
	// MensagemSif()



	MSCBBOX(26,2,53,70,4)
	MSCBBOX(29,2,29,70,3)
	MSCBLineH(29,42,44,3,"B")//1ª Barra vertical
	MSCBLineH(32,57,44,3,"B")//1ª Barra vertical
	MSCBLineH(29,33,44,3,"B")//3ª Barra vertical
	MSCBLineH(32,20,44,3,"B")//4ª Barra vertical
	MSCBLineH(29,10,44,3,"B")//5ª Barra vertical
	MSCBLineV(32,3,70,3,"B")// essa linha esta fazendo a horizontal (Y,X1,X2)
	MSCBLineV(35,3,70,3,"B")// essa linha esta fazendo a horizontal (Y,X1,X2)
	MSCBLineV(38,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)
	MSCBLineV(41,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)
	MSCBLineV(44,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)


return


Static Function GeraLa2()

	MSCBBOX(26,2,53,70,4)
	MSCBBOX(29,2,29,70,3)
	MSCBLineH(29,42,44,3,"B")//1ª Barra vertical
	MSCBLineH(32,57,44,3,"B")//1ª Barra vertical
	MSCBLineH(29,33,44,3,"B")//3ª Barra vertical
	MSCBLineH(32,20,44,3,"B")//4ª Barra vertical
	MSCBLineH(29,10,44,3,"B")//5ª Barra vertical
	MSCBLineV(32,3,70,3,"B")// essa linha esta fazendo a horizontal (Y,X1,X2)
	MSCBLineV(35,3,70,3,"B")// essa linha esta fazendo a horizontal (Y,X1,X2)
	MSCBLineV(38,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)
	MSCBLineV(41,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)
	MSCBLineV(44,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)


return


Static Function Gera2L2()

	MSCBSAY(30,49,'Quantidade por Porcao',"B","0",fonteInfNutri2)
	MSCBSAY(30,35,'%VD(*)',"B","0",fonteInfNutri2)
	MSCBSAY(30,12,'Quantidade por Porcao',"B","0",fonteInfNutri2)
	MSCBSAY(30,3,'%VD(*)',"B","0",fonteInfNutri2)

return

Static Function Gera3Linha()
	str2:=''	
		
	MSCBSAY(02,30,'I N F O R M AÇ ÃO N U T R I C I O N A L : P o r ç a o 100 g',"N","0",fonteInscSIF)
	MSCBSAY(02,32,'(1 bife médio)***.'+'Valor energetico '+alltrim(ZZ7->ZZ7_CALQTP),"N","0",fonteInscSIF)
		
	//str2 := +alltrim(ZZ7->ZZ7_CALVD)+';Carboidratos '+alltrim(ZZ7->ZZ7_CARQTP) + ','+alltrim(ZZ7->ZZ7_CARVD)+','+';Proteinas '+alltrim(ZZ7->ZZ7_PROQTP)+','+alltrim(ZZ7->ZZ7_PROVD)+';Gorduras Totais '+alltrim(ZZ7->ZZ7_GTQTP)+alltrim(ZZ7->ZZ7_GTVD)+';Gordura Saturada '+ alltrim(ZZ7->ZZ7_GSQTP) + ','+ alltrim(ZZ7->ZZ7_GSVD)+';Gordura Trans '+alltrim(ZZ7->ZZ7_GTRTP)+alltrim(ZZ7->ZZ7_GTRVD)+';Fibra Alimentar '+alltrim(ZZ7->ZZ7_FIAQTP)+alltrim(ZZ7->ZZ7_FIAVD)+';Sodio '+alltrim(ZZ7->ZZ7_SODQTP)+alltrim(ZZ7->ZZ7_SODVD)
	str2 := '( '+alltrim(ZZ7->ZZ7_CALVD)+' )'+';Carboidratos '+alltrim(ZZ7->ZZ7_CARQTP) + ','+'( '+alltrim(ZZ7->ZZ7_CARVD)+' )' + ','+';Proteinas '+alltrim(ZZ7->ZZ7_PROQTP) + ',' + '( ' +alltrim(ZZ7->ZZ7_PROVD)+ ' )'  +';Gorduras Totais '+alltrim(ZZ7->ZZ7_GTQTP)+'( ' + alltrim(ZZ7->ZZ7_GTVD)+ ' )'  +';Gordura Saturada '+ alltrim(ZZ7->ZZ7_GSQTP) + ','+ '( ' + alltrim(ZZ7->ZZ7_GSVD)+ ' )'  +';Gordura Trans '+alltrim(ZZ7->ZZ7_GTRTP) + '( ' +alltrim(ZZ7->ZZ7_GTRVD)+' )' +';Fibra Alimentar '+alltrim(ZZ7->ZZ7_FIAQTP)+ '( ' + alltrim(ZZ7->ZZ7_FIAVD)+' )' + ';Sodio '+alltrim(ZZ7->ZZ7_SODQTP)+' ( ' +alltrim(ZZ7->ZZ7_SODVD)+' )'
	
	MSCBSAY(02,34,substr(str2,1,58),"N","0",fonteInscSIF)
	MSCBSAY(02,36,substr(str2,59,58),"N","0",fonteInscSIF)
	MSCBSAY(02,38,substr(str2,117,60),"N","0",fonteInscSIF)
	MSCBSAY(02,40,substr(str2,177,50),"N","0",fonteInscSIF)
	
return


Static Function MensagemSif(_cod)
	fontelT  :="16,16"
	_sif04 	 := GetMV('SI_SIFET04')
	
	_MSIF  	 := substr(ZZ7->ZZ7_MSIF,1,4)
	string := 'Comercializado por: WMB Supermercados do Brasil LTDA AV. Tucunaré 126, Barueri-SP CEP : 06460-020 CNPJ: 00.063.960/0001-09 Servico de Atendimento ao cliente: 0800-022-0650'
	_cStr3:= '(*)VALORES DIARIOS DE REFERENCIA COM BASE EM UMA DIETA DE 2.000kcal,OU 8400 kJ.SEUS VALORES DIARIOS PODEM SER MAIORES OU MENORES DEPENDENDO DE SUAS NECESSIDADES ENERGETICAS.**VD NAO ESTABELECIDO.*** Referente a porção comestivel do alimento.'
	

	MSCBSAY(02,42,substr(_cStr3,1,49),"N","0",fonteInscSIF)
	MSCBSAY(02,44,substr(_cStr3,50,50),"N","0",fonteInscSIF)
	MSCBSAY(02,46,substr(_cStr3,100,48),"N","0",fonteInscSIF)
	MSCBSAY(02,48,substr(_cStr3,148,48),"N","0",fonteInscSIF)
	MSCBSAY(02,50,substr(_cStr3,196,48),"N","0",fonteInscSIF)
	
	//-------------
	// MSCBSAY(02,54,'APOS ABERTO CONSUMIR EM ATE 2 DIAS,RESPEITANDO O PRAZO',"N","0",fonteInscSIF) - Alterado para satisfazer a condição abaixo
	_exmetq   := GetMV('SI_EXMETQ')	

	if (!_cod $ _exmetq)
		MSCBSAY(02,54,'APOS ABERTO CONSUMIR EM ATE 2 DIAS,RESPEITANDO O PRAZO',"N","0",fonteInscSIF)
	endif
	
	MSCBSAY(02,56,'DE VALIDADE.',"N","0",fonteInscSIF)
	// 
	IF !(_MSIF $ _sif04)
		//MSCBSAY(02,56,'Conservação Caseira: Refrigerador de 0 a +4 C = 2 dias; ',"N","0",fonteInscSIF)
		MSCBSAY(02,58,'Conservação Caseira: Refrigerador de 0 a +4 graus celsius = 2 dias; ',"N","0",fonteInscSIF)
		//MSCBSAY(02,58,'Congelador de -12 a -8 C = 6 meses;',"N","0",fonteInscSIF)
		MSCBSAY(02,60,'Congelador de -12 a -8 graus celsius = 6 meses;',"N","0",fonteInscSIF)
		//MSCBSAY(02,60,'Freezer -12 C ou mais frio = Conforme validade',"N","0",fonteInscSIF)
		MSCBSAY(02,62,'Freezer -12 graus celsius ou mais frio = Conforme validade',"N","0",fonteInscSIF)
		MSCBSAY(02,64,'impressa na etiqueta.',"N","0",fonteInscSIF)
		MSCBSAY(02,66,'Peso da Embalagem:'+transform(valor4,'@E 99') + "g","N","0",fonteInscSIF)//tara
	else
		MSCBSAY(02,66,'Peso da Embalagem:'+transform(valor4,'@E 99') + "g","N","0",fonteInscSIF)//tara
	endif	
	_cStr4:= 'Modo de preparo: prepare a carne de acordo com a sua preferência, garantindo o cozimento da carne.'
	MSCBSAY(02,68,substr(_cStr4,1,49),"N","0",fonteInscSIF)
	MSCBSAY(02,70,substr(_cStr4,50,49),"N","0",fonteInscSIF)
	
	MSCBSAY(02,74,substr(string,1,52),"N","0",fonteInscSIF)//tara
	MSCBSAY(02,76,substr(string,53,50),"N","0",fonteInscSIF)//tara
	MSCBSAY(02,78,substr(string,103,55),"N","0",fonteInscSIF)//tara
	MSCBSAY(02,80,substr(string,157,50),"N","0",fonteInscSIF)//tara
	
	
return


Static Function GetqExt()

	// Função responsável por gerar a tabela nutricional por extenso conforme solicitação da Lucinéia
	
	_Linha3 := 'Valor energ.'+alltrim(ZZ7->ZZ7_CALQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_CALVD)+' VD);'+'Gord. Trans.'+alltrim(ZZ7->ZZ7_GTRTP)+'(**)'+space(1)+'('+alltrim(ZZ7->ZZ7_GTRVD)+' VD) ;'+'Carboidratos'+alltrim(ZZ7->ZZ7_CARQTP)+'('+alltrim(ZZ7->ZZ7_CARVD)+' VD) ; Fibra Alim.' + alltrim(ZZ7->ZZ7_FIAQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_FIAVD)+' VD);'+'Proteinas'+alltrim(ZZ7->ZZ7_PROQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_PROVD)+' VD) ;'+'Sodio'+alltrim(ZZ7->ZZ7_SODQTP)+space(1)+'('+alltrim(ZZ7->ZZ7_SODVD)+' VD) ; Gorduras Tot.'+alltrim(ZZ7->ZZ7_GTQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_GTVD)+' VD);'+'Gord. Satur.'+alltrim(ZZ7->ZZ7_GSQTP)+space(1)+'('+ alltrim(ZZ7->ZZ7_GSVD)+' VD);'

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
	// MSCBSAY(40,38,'APOS ABERTO CONSUMIR EM ATE 2 DIAS.',"B","0",fontelinha9) - Alterado para satisfazer a condição abaixo

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

	MSCBSAY(48,26,'ADICIONADA DE 10% DE SOLUÇÃO DE ÁGUA E ADITIVOS.',"B","0",fontelinha9)
	MSCBSAY(48,3,'PROIBIDOS FRACIONAMENTO.',"B","0",fontelinha9)

return   


Static Function imp1(_cIp,cod1)
//se não achou o ip na tabela imprime pela porta paralela	
	
	if empty(_cIp)
		MSCBPRINTER('S600','LPT1')
	else
		MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
	endif

	MSCBCHKSTATUS(.f.)

	//MSCBBEGIN(4,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas VALOR5 - para teste
	MSCBBEGIN(_nQetq,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas VALOR5
	
	ZZ7->(dbsetorder(1))
	ZZ7->(dbSeek(xFilial('ZZ7') + cod1))

	
	// Tamnho dos fontes na etiqueta
	
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
	//Geração do cabeçalho da Etiqueta

	
	GeraCabecalho()
	//Toda estrutura do layout | Função criada para imprimir a estrutura da tabela de valor Nutricional
	

	Gera3Linha()

	MensagemSif(ZZ7->ZZ7_CODPRO)

	MSCBEND()
	MSCBCLOSEPRINTER()

return

Static Function imprime2(_cIp2,cod2)

//se não achou o ip na tabela imprime pela porta paralela
	if empty(_cIp2)
		MSCBPRINTER('S600','LPT1')
	else
		MSCBPRINTER('S600','IP',,,,,_cIp2) //Impressão por IP
	endif

	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nQetq2,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas VALOR5
	
	ZZ7->(dbsetorder(1))
	ZZ7->(dbSeek(xFilial('ZZ7') + cod2))
	
	// Tamnho dos fontes na etiqueta	
	dtVALID := valr2+ZZ7->ZZ7_DVALID // Data de validade
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
	fontelT     	:="16,14"
	fonte3          :="16,13"
	//Geração do cabeçalho da Etiqueta



	GeraCab2()
	//Toda estrutura do layout | Função criada para imprimir a estrutura da tabela de valor Nutricional
	GeraLa2()
	//2º Linha
	Gera2L2()

	//3ª Linha
	Gera3L3()

	//4ª Linha
	Gera4L4()

	//5ª Linha
	Gera5L5()

	//6ª Linha
	Gera6L6()

	MensSif2()


	MSCBEND()
	MSCBCLOSEPRINTER()

return


Static Function gjf41wfw(_nProd,_dDataABT,_nNvinc,_nDABT,_cDes,_dDtEmb)
		
	
	local _cDest  := 'valeska.brum@frigorificosilva.com.br,daiane.rossatto@frigorificosilva.com.br'
	//local _VLD := 'N'
	Local _cMens := ''
	Local _cAtivaR := GetMV('SI_LIBR88')
		// gjf41wfw(valor1,valor2,_nNvinc,_nDABT,_cDescri,_dDataEmb)
		_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
	
		//alert(_cAtivaR)
		If  _nNvinc = 999
			IF _cAtivaR = '1'	
				U_DTI88PPE(1,_nProd,_dDataABT,_dDtEmb)
			Endif			
			_cMens += 'O Produto :'+_nProd+' - '+_cDes+' Produto não possui previsão de Embalagem Lançada  !!'+ chr(13) + chr(10)				
					
		Elseif _nNvinc > 0
				
			_cMens += 'O Produto :'+_nProd+' - '+_cDes+' esta com '+cValtoChar(_nNvinc)+' Previsões da Enbalagem NÃO vinculada com Prev. da Desossa   !!'+ chr(13) + chr(10)
			
		elseif _nDABT > 0
			
			IF _cAtivaR = '1'	
				U_DTI88PPE(3,_nProd,_dDataABT,_dDtEmb)
			Endif	
			_cMens += 'O Produto :'+_nProd+' - '+_cDes+' esta com '+cValtoChar(_nDABT)+' Previsões de  Data do Abate diferente da Data lançada na produção das Etiqueta Internas  !!'+ chr(13) + chr(10)
		
		Endif
	
	
		_cMens += 'Na Data do Abate de :'+ dtoc(_dDataABT) + chr(13) + chr(10)
		_cMens +=   chr(13) + chr(10)
		_cTit  := 'Workflow Frigorífico Silva: Aviso de Produção na EMBALAGEM/DESOSSA  ' 
	
		u_GJF54(_cMens,_cTit,_cDest)

		
return


User Function  QtPrv(_dDataABT,_cDescri,_dDataEmb,_cCodP)
	LOCAL _nCont := 0
	LOCAL _nCont2 := 0
	LOCAL _nNvinc := 0
	LOCAL _nDABT := 0
	LOCAL _nMark := 'N'
			
	_cQuery := " SELECT ZU_NUM,ZU_COD,ZU_DTPROD,ZU_PREDES AS PREDES "
	_cQuery += " FROM " + retSqlTab('SZU')
	_cQuery += " WHERE " + retSqlFil('SZU')
	_cQuery += " AND " + retSqlDel('SZU')
	_cQuery += " AND ZU_DTPROD = '" + dtos(_dDataEmb) + "' "
	_cQuery += " AND ZU_COD = '" + alltrim(_cCodP) + "' "	
	
	
	_cQuery  := ChangeQuery(_cQuery)
	
	GeraQUE()
	
	SZ2->(DbGoTop()) 
	SZ2->(dbSetOrder(2))
	
	TMP->(dbGoTop())		
	While TMP->(!EOF())
		_cPrevde := alltrim(TMP->PREDES)	
			
		if  !empty(alltrim(_cPrevde)) .AND. !empty(SZ2->(dbSeek(xFilial('SZ2') + alltrim(_cPrevde))))
					
			if _dDataABT = SZ2->Z2_DATAABT
				
				// Imprime normal a etiqueta sem enviar workflow
				_nCont++
				_nMark := 'S'
				TMP->(dbSkip())
				Loop
										
			else
				
				//alert('Data do Abate diferente da Data lançada na produção das Etiqueta Internas  !! Enviado e-mail para o PCP')							
				_nCont2++
				_nDABT++
						
			endif
			
		else
			
			// Se prev embalagem  não tiver prev desossa vinculada cai aqui
			//alert('Prev. da Enbalagem não vinculada com Prev. da Desossa  !! Enviado e-mail para o PCP')					
			_nCont2++
			_nNvinc++
						
		End
		
		_nCont++
		TMP->(dbSkip())
	Enddo
	
	// caso não tenha previsão
	If _nMark = 'N'
		If _nCont = 0 .AND. _nCont2 = 0
		
			//alert('Produto não possui previsão de Embalagem Lançada !! Enviado e-mail para o PCP')
			// aviso de SZU não lançada 
			//u_gjf41wfw(valor1,valor2 ,'E')
			_nNvinc:= 999
			gjf41wfw(_cCodP,_dDataABT,_nNvinc,_nDABT,_cDescri,_dDataEmb)
			
		elseif _nCont > 0
		 
		 	// caso não tenha previsão correta ,  descrever no e-mail situações visualizadas
		 	if _nCont =_nCont2		 				
	 			//alert('Data do Abate diferente da Data lançada na produção das Etiqueta Internas ')	 			
		 		gjf41wfw(_cCodP,_dDataABT,_nNvinc,_nDABT,_cDescri,_dDataEmb)
		 			
			Endif
		
		Endif
	else
	
		//alert('761 Tem uma Previsão que esta correta!! ') Então não vai workflow
		
	Endif
	
return


Static Function GeraQUE()

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return

Static Function T1()

	
		@ 01,01 SAY "Produto:" of telaimp2
		@ 02,01 SAY "Data Produção\ABT:" of telaimp2
		@ 03,01 SAY "Data Embalagem:" of telaimp2
		@ 04,01 SAY "Descrição Corte:" of telaimp2
		@ 06,01 SAY "Tara:" of telaimp2
		@ 07,01 SAY "Quant. Caixas:" of telaimp2
		@ 08,01 SAY "Tipo Mercado:" of telaimp2
		@ 09,01 SAY "Qtd.Etiquetas:" of telaimp2
	
		@ 01,08 MSGET campoA VAR valor1 SIZE 20,10 F3 'ZZ7' OF telaimp2 //VALID iif(!existcpo('ZZ7'),dti41clear(),.t.)
		@ 02,08 MSGET campoB VAR valor2 SIZE 40,10  OF telaimp2 valid valor2 >= _dDTMenor .and. valor2 <= _dDTMaior// data producao
		@ 03,08 MSGET campoF VAR valor8 SIZE 40,10  OF telaimp2 valid valor8 >= _dDTMenor .and. valor8 <= _dDTMaior// data embalagem
	
		@ 05,01 SAY valor3 of telaimp2
		@ 06,08 SAY transform(valor4,'@E 99') + ' g' of telaimp2
		@ 07,08 MSGET campoE VAR valor5 SIZE 20,10  OF telaimp2  picture '@E 999'  VALID dti41vl(valor5)
		@ 08,08 COMBOBOX valor7 items campoG SIZE 40,08 OF telaimp2
		@ 09,08 SAY	transform(valor9,'@E 999') OF telaimp2
		
		oGrp1 := tGroup():New(04, 03, 135, 115,'!! Impressora da Esquerda !!', telaimp2,,, .t.)
		
		campoA:bLostFocus := {|| dti41prc() }
		
Return
