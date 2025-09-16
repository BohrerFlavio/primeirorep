#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³dti01   º Autor ³ Mauricio Lopes Roehrs º Data ³  07/04/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³             Impressão de etiqueta interna                  º±±
±±º          ³                    WalMart                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desossa                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function dti01()

	dbselectarea('ZZ7')
	dbsetorder(1)

	//campos
	Private campoA    := space(06)  									//codigo do produto
	Private campoB    := space(08) 									//data de produção
	Private campoI	   := space(08)									//data de embalagem
	Private campoC 	:= space(40) 									//descrição do corte
	Private campoD 	:= space(05) 									//tara da embalagem
	Private campoE 	:= 000         								//quantidade de etiquetas
	Private campoG    := {"Merc. Interno","Merc. Externo"}	//tipo de Mercado(Define o Tipo de Mensagem)

	//variaveis
	Private _cCod 	     := space(06) 	//codigo do produto
	Private _dDtProd	  := date()   	//data de produção
	Private _cDesc 	  := space(40)	//Descrição do corte
	Private _cTara 	  := space(03)   //Tara
	Private _nQtdEtq    := 000      	//Quantidade de etiqueta
	Private _cSexo 	  := 'XXXXX'  	//Sexo
	Private _cDestMerc  := space(13)	//Mensagem do Ministerio 
	Private _dDtEmbal	  := date()		//data de embalagem
	Private _dDTMaior   := date()
	Private _dDTMenor   := date()-10

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³      			   Montagem do Browse                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA INTERNA"
	//vinculação dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Data Produção:" of telaimp
	@ 03,01 SAY "Data Embalagem:" of telaimp
	@ 04,01 SAY "Descrição Corte:" of telaimp
	@ 05,01 SAY "Tara:" of telaimp
	@ 06,01 SAY "Quant. Caixas:" of telaimp
	@ 08,01 SAY "Tipo Mercado:" of telaimp

	@ 01,08 MSGET campoA VAR _cCod SIZE 20,10 F3 'ZZ7' OF telaimp VALID iif(!existcpo('ZZ7'),mlr08clear(),.t.)
	@ 02,08 MSGET campoB VAR _dDtProd SIZE 40,10  OF telaimp valid _dDtProd >= _dDTMenor .and. _dDtProd <= _dDTMaior // data producao
	@ 03,08 MSGET campoI VAR _dDtEmbal SIZE 40,10  OF telaimp valid _dDtEmbal >= _dDTMenor .and. _dDtEmbal <= _dDTMaior// data embalagem
	@ 04,08 SAY _cDesc of telaimp
	@ 05,08 MSGET campoD VAR _cTara SIZE 20,10  OF telaimp // Tara
	@ 06,08 MSGET campoE VAR _nQtdEtq SIZE 20,10  OF telaimp  picture '@E 999'  // quant etiqueta
	@ 08,08 COMBOBOX _cDestMerc items campoG SIZE 40,08 OF telaimp
	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action mlr08etq()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	campoA:bLostFocus := {|| mlr08prc() }
	ACTIVATE MSDIALOG telaimp CENTERED

return


static function mlr08prc()
	ZZ7->(dbsetorder(1))
	if ZZ7->(dbseek(xfilial('ZZ7')+_cCod))
		_cDesc := ZZ7->ZZ7_CORTE
	endif
	telaimp:refresh()
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³     Função que limpa os campos apos a impressão      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

static function mlr08clear()
	_cCod   	 	 := space(06)
	_dDtProd   	 := date()
	_cDesc   	 := space(20)
	_cTara   	 := space(03)
	_nQtdEtq 	 := 000
	_cSexo   	 := 'XXXXX'
	//_cDestMerc   := space(13)
	_dDtEmbal	 := date()
	telaimp:refresh()
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  		  Função para impressão de etiquetas 	 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

static Function mlr08etq()
	if empty(_cCod) .or. empty(_dDtProd) .or. empty(_cDesc) .or. empty(_cTara) .or. empty(_nQtdEtq)
		Alert('Campos em branco!')
		return
	endif
	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7')+_cCod))


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³    Parametros de impressora e Fontes Utilizadas      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_nQtdCx := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(_cCod),'B1_QCAIX') 
	_nQetq  := _nQtdCx * _nQtdEtq

	MSCBPRINTER('S600','IP',,,,,'10.0.0.124')   	 
	//MSCBPRINTER('S600','LPT1')
	//MSCBPRINTER('S600','COM1:4800,e,7,2')
	MSCBCHKSTATUS(.t.)
	MSCBBEGIN(_nQetq,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas _nQtdEtq

	dtVALID := _dDtEmbal + ZZ7->ZZ7_DVALID // Data de validade
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

	_nLin := 2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³           Cabeçalho da Etiqueta                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea('SB1')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³              Descrição do Corte                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=42-t
	MSCBSAY(02+_nlin,pos,alltrim(ZZ7->ZZ7_DESC),"B","0",fonteDesc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³           			Nome do Corte                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	pos2:=0
	t2:=len(alltrim(_cDesc))
	pos2:=42-t2  
	MSCBSAY(09+_nlin,pos2,alltrim(_cDesc),"B","0",fontecorte)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³       Mensagem da Temperatura de Amazenamento        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_sif04 := GetMV('SI_SIFET04')
	_sif07 := GetMV('SI_SIFET07')
	_sif07_2 := GetMv('SI_SIFTE07')
	_sif12 := GetMV('SI_SIFET12')
	_sif18 := GetMV('SI_SIFET18')
	_MSIF  := substr(ZZ7->ZZ7_MSIF,1,4)

	if (_MSIF $ _sif07) .or. (_MSIF $ _sif07_2)
		MSCBSAY(15+_nlin,6,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif12
		MSCBSAY(15+_nlin,6,'MANTER CONGELADA A -12 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif18
		MSCBSAY(15+_nlin,6,'MANTER CONGELADA A -18 GRAUS CELSIUS',"B","0",fonteMesTemp)   
	elseif _MSIF $ _sif04
		MSCBSAY(15+_nlin,6,'MANTER RESFRIADA DE 0 a 4 GRAUS CELSIUS',"B","0",fonteMesTemp)
	endif 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³          Dt. Prod + Dt. Valid. + Sexo + Tara         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	              

	MSCBSAY(15+_nlin,52,substr(dtos(_dDtProd),7,2)+'/'+substr(dtos(_dDtProd),5,2)+'/'+substr(dtos(_dDtProd),3,2),"B","0",fonteData)
	MSCBSAY(21+_nlin,49,dtoc(dtVALID),"B","0",fonteData) 
	MSCBSAY(21+_nlin,24,_cSexo,"B","0",fonteNomeCorte1)
	MSCBSAY(21+_nlin,13,alltrim(_cTara)+'g',"B","0",fonteNomeCorte1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  			 Fim do Cabeçalho da etiqueta  			    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  		  Inicio das Informações Nutricionais         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSCBSAY(24+_nlin,41,'INFORMACAO  NUTRICIONAL: ',"B","0",fonteInfNutri1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                Parte Comestivel                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(24+_nlin,11,ZZ7->ZZ7_PRTCOM + ',' ,"B","0",fonteInfNutri1)
	MSCBSAY(24+_nlin,15,'(1 prato); ',"B","0",fonteInfNutri1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                Valor Energetico                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                  


	//MSCBSAY(24+_nlin,06,'Valor',"B","0",fonteInfNutri2)
	MSCBSAY(26+_nlin,54,'Valor energetico',"B","0",fonteInfNutri2)
	MSCBSAY(26+_nlin,39,alltrim(ZZ7->ZZ7_CALQTP),"B","0",fonteInfNutri2)     
	MSCBSAY(26+_nlin,28,'(' + alltrim(ZZ7->ZZ7_CALVD) + 'VD*); ',"B","0",fonteInfNutri2)

	//MSCBSAY(26+_nlin,58,'Valor energ.',"B","0",fonteInfNutri2)
	//MSCBSAY(26+_nlin,47,alltrim(ZZ7->ZZ7_CALQTP),"B","0",fonteInfNutri2)     
	//MSCBSAY(26+_nlin,38,'(' + alltrim(ZZ7->ZZ7_CALVD) + 'VD*); ',"B","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                    Carboidratos                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(26+_nlin,16,'Carboidratos',"B","0",fonteInfNutri2)
	MSCBSAY(26+_nlin,13,alltrim(ZZ7->ZZ7_CARQTP),"B","0",fonteInfNutri2)  //67
	MSCBSAY(26+_nlin,04,'(' + alltrim(ZZ7->ZZ7_CARVD) + 'VD*); ',"B","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                       Proteinas                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(28+_nlin,60,'Proteinas',"B","0",fonteInfNutri2)
	MSCBSAY(28+_nlin,53,alltrim(ZZ7->ZZ7_PROQTP),"B","0",fonteInfNutri2)    
	MSCBSAY(28+_nlin,40,'(' + alltrim(ZZ7->ZZ7_PROVD) + 'VD*); ',"B","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                   Gorduras Totais                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                   

	MSCBSAY(28+_nlin,22,'Gorduras totais',"B","0",fonteInfNutri2)
	MSCBSAY(28+_nlin,16,alltrim(ZZ7->ZZ7_GTQTP),"B","0",fonteInfNutri2) 
	MSCBSAY(28+_nlin,05,'(' + alltrim(ZZ7->ZZ7_GTVD) + 'VD*); ',"B","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                 Gorduras Saturadas                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(30+_nlin,51,'Gorduras saturadas',"B","0",fonteInfNutri2)
	MSCBSAY(30+_nlin,45,alltrim(ZZ7->ZZ7_GSQTP),"B","0",fonteInfNutri2)
	MSCBSAY(30+_nlin,33,'(' + alltrim(ZZ7->ZZ7_GSVD) + 'VD*); ',"B","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                  Gordura Trans.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(30+_nlin,18,'Gorduras trans',"B","0",fonteInfNutri2)
	MSCBSAY(30+_nlin,15,alltrim(ZZ7->ZZ7_GTRTP),"B","0",fonteInfNutri2)      
	MSCBSAY(30+_nlin,10,'(' + alltrim(ZZ7->ZZ7_GTRVD) + '*); ' ,"B","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                     Colesterol                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                               

	//MSCBSAY(30+_nlin,16,'Colesterol',"B","0",fonteInfNutri2)
	//MSCBSAY(30+_nlin,10,alltrim(ZZ7->ZZ7_COLQTP),"B","0",fonteInfNutri2)      
	//MSCBSAY(30+_nlin,05,'(' + alltrim(ZZ7->ZZ7_COLVD),"B","0",fonteInfNutri2)
	//MSCBSAY(32+_nlin,64,'VD*); ' ,"B","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                   Fibra Alimentar                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(32+_nlin,55,'Fibra alimentar',"B","0",fonteInfNutri2)
	MSCBSAY(32+_nlin,50,alltrim(ZZ7->ZZ7_FIAQTP),"B","0",fonteInfNutri2)
	MSCBSAY(32+_nlin,41,'(' + alltrim(ZZ7->ZZ7_FIAVD) + 'VD*); ',"B","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                         Sodio                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(32+_nlin,35,'Sodio',"B","0",fonteInfNutri2)
	MSCBSAY(32+_nlin,29,alltrim(ZZ7->ZZ7_SODQTP),"B","0",fonteInfNutri2)
	MSCBSAY(32+_nlin,20,'(' + alltrim(ZZ7->ZZ7_SODVD) + 'VD*); ',"B","0",fonteInfNutri2)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   			 Fim das Informações Nutricionais          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Mensagens Adicionais na parte inferior da etiqueta  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(32+_nlin,05,'*% Valores dia',"B","0",fonteInfNutri2)//rios de                                               
	MSCBSAY(34+_nlin,04,'rios de referencia  com  base em uma  dieta de 2.000 kcal, ou 8400 kJ.',"B","0",fonteInfNutri2)
	MSCBSAY(36+_nlin,05,'Seus valores diarios podem  ser maiores ou menores dependendo de',"B","0",fonteInfNutri2) 
	MSCBSAY(38+_nlin,18,'suas necessidades energeticas.**VD nao estabelecido.' ,"B","0",fonteInfNutri2) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³             Mensagens do Ministerio                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if _cDestMerc = "Merc. Externo"
		MSCBSAY(49+_nlin,05,'Uso autorizado pelo Ministerio da Agricultura/SIF/DIPOA sob Nr.'+ZZ7->ZZ7_MSIF ,"B","0",fonteInfNutri2)
		//	MSCBSAY(01,69,'SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)Uso autorizado pelo Ministerio da Agricultura/SIF/DISPOA sob nr.
	else	
		MSCBSAY(49+_nlin,08,'Registro no Ministerio da Agricultura/SIF/DIPOA sob Nr.'+ZZ7->ZZ7_MSIF,"B","0",fonteInfNutri2)
		//MSCBSAY(01,69,'SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF) Registro no Ministerio da Agricultura/SIF/DIPOA sob Nr.
	endif  

	MSCBEND()
	MSCBCLOSEPRINTER()
	mlr08clear()

	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

return
