#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR03   º Autor ³ Mauricio Lopes Roehrs º Data ³  17/01/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³             Impressão de etiqueta interna                  º±±
±±º          ³                    Novo Layout                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desossa                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR03()

	dbselectarea('ZZ7')
	dbsetorder(1)

	//campos
	campoA   := space(06)  									//codigo do produto
	campoB   := space(08) 									//data de produção
	campoC 	:= space(40) 									//descrição do corte
	campoD 	:= space(05) 									//tara da embalagem
	campoE 	:= 000         								//quantidade de etiquetas
	campoG   := {"Merc. Interno","Merc. Externo"}	//tipo de Mercado(Define o Tipo de Mensagem)

	//variaveis
	_cCod 	   := space(06) 	//codigo do produto
	_dDtProd	   := date()   	//data de produção
	_cDesc 	   := space(40)	//Descrição do corte
	_cTara 	   := space(03)   //Tara
	_nQtdEtq    := 000      	//Quantidade de etiqueta
	_cSexo 	   := 'XXXXX'  	//Sexo
	_cDestMerc  := space(13)	//Mensagem do Ministerio

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³      			   Montagem do Browse                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA INTERNA"
	//vinculação dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Data Produção:" of telaimp
	@ 03,01 SAY "Descrição Corte:" of telaimp
	@ 04,01 SAY "Tara:" of telaimp
	@ 05,01 SAY "Quant. Etiq.:" of telaimp
	@ 07,01 SAY "Tipo Mercado:" of telaimp

	@ 01,08 MSGET campoA VAR _cCod SIZE 20,10 F3 'ZZ7' OF telaimp VALID iif(!existcpo('ZZ7'),mlr03clear(),.t.)
	@ 02,08 MSGET campoB VAR _dDtProd SIZE 40,10  OF telaimp // data producao
	@ 03,08 SAY _cDesc of telaimp
	@ 04,08 MSGET campoD VAR _cTara SIZE 20,10  OF telaimp // Tara
	@ 05,08 MSGET campoE VAR _nQtdEtq SIZE 20,10  OF telaimp  picture '@E 999'  // quant etiqueta
	@ 07,08 COMBOBOX _cDestMerc items campoG SIZE 40,08 OF telaimp
	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action mlr03etq()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	campoA:bLostFocus := {|| mlr03prc() }
	ACTIVATE MSDIALOG telaimp CENTERED

return


static function mlr03prc()
	ZZ7->(dbsetorder(1))
	if ZZ7->(dbseek(xfilial('ZZ7')+_cCod))
		_cDesc := ZZ7->ZZ7_CORTE
	endif
	telaimp:refresh()
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³     Função que limpa os campos apos a impressão      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

static function mlr03clear()
	_cCod   	 	 := space(06)
	_dDtProd   	 := date()
	_cDesc   	 := space(20)
	_cTara   	 := space(03)
	_nQtdEtq 	 := 000
	_cSexo   	 := 'XXXXX'
	_cDestMerc   := space(13)
	telaimp:refresh()
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  		  Função para impressão de etiquetas 	 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

static Function mlr03etq()
	if empty(_cCod) .or. empty(_dDtProd) .or. empty(_cDesc) .or. empty(_cTara) .or. empty(_nQtdEtq)
		Alert('Campos em branco!')
		return
	endif
	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7')+_cCod))


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³    Parametros de impressora e Fontes Utilizadas      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSCBPRINTER('S600','LPT1')
	//MSCBPRINTER('S600','COM1:4800,e,7,2')
	MSCBCHKSTATUS(.t.)
	MSCBBEGIN(_nQtdEtq,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas

	dtVALID := _dDtProd + ZZ7->ZZ7_DVALID // Data de validade
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³           Cabeçalho da Etiqueta                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea('SB1')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³              Descrição do Corte                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=52-t
	MSCBSAY(pos,04,alltrim(ZZ7->ZZ7_DESC),"C","0",fonteDesc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³           			Nome do Corte                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	pos2:=0
	t2:=len(alltrim(_cDesc))
	pos2:=37-t2  
	MSCBSAY(pos2,10,alltrim(_cDesc),"C","0",fontecorte)

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
		MSCBSAY(67,10,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"C","0",fonteMesTemp)
	elseif _MSIF $ _sif12
		MSCBSAY(67,10,'MANTER CONGELADA A -12 GRAUS CELSIUS',"C","0",fonteMesTemp)
	elseif _MSIF $ _sif18
		MSCBSAY(67,10,'MANTER CONGELADA A -18 GRAUS CELSIUS',"C","0",fonteMesTemp)   
	elseif _MSIF $ _sif04
		MSCBSAY(67,10,'MANTER RESFRIADA DE 0 a 4 GRAUS CELSIUS',"C","0",fonteMesTemp)
	endif 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³          Dt. Prod + Dt. Valid. + Sexo + Tara         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	              

	MSCBSAY(03,18,substr(dtos(_dDtProd),7,2)+'/'+substr(dtos(_dDtProd),5,2)+'/'+substr(dtos(_dDtProd),3,2),"C","0",fonteData)
	MSCBSAY(22,18,dtoc(dtVALID),"C","0",fonteData) 
	MSCBSAY(48,18,_cSexo,"C","0",fonteNomeCorte1)
	MSCBSAY(78,18,alltrim(_cTara)+'g',"C","0",fonteNomeCorte1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  			 Fim do Cabeçalho da etiqueta  			    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  		  Inicio das Informações Nutricionais         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSCBSAY(01,51,'INFORMACOES NUTRICIONAIS: ',"C","0",fonteInfNutri1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                Parte Comestivel                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(30,51,substr(ZZ7->ZZ7_PRTCOM,1,23),"C","0",fonteInfNutri1)
	MSCBSAY(01,53,substr(ZZ7->ZZ7_PRTCOM,24,33),"C","0",fonteInfNutri1)
	MSCBSAY(11,53,', (1 bife pequeno); ',"C","0",fonteInfNutri1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                Valor Energetico                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                  

	MSCBSAY(29,53,'Valor energ.',"C","0",fonteInfNutri2)
	MSCBSAY(41,53,alltrim(ZZ7->ZZ7_CALQTP),"C","0",fonteInfNutri2)     
	MSCBSAY(49,53,'(' + alltrim(ZZ7->ZZ7_CALVD) + 'VD*); ',"C","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                  Gordura Trans.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(01,55,'Gord. Trans.',"C","0",fonteInfNutri2)
	MSCBSAY(13,55,alltrim(ZZ7->ZZ7_GTRTP),"C","0",fonteInfNutri2)      
	MSCBSAY(16,55,'(' + alltrim(ZZ7->ZZ7_GTRVD) + '); ' ,"C","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                    Carboidratos                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(20,55,'Carboidratos',"C","0",fonteInfNutri2)
	MSCBSAY(32,55,alltrim(ZZ7->ZZ7_CARQTP),"C","0",fonteInfNutri2)  
	MSCBSAY(41,55,'(' + alltrim(ZZ7->ZZ7_CARVD) + 'VD*); ',"C","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                       Proteinas                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(50,55,'Proteinas',"C","0",fonteInfNutri2)
	MSCBSAY(01,57,alltrim(ZZ7->ZZ7_PROQTP),"C","0",fonteInfNutri2)    
	MSCBSAY(05,57,'(' + alltrim(ZZ7->ZZ7_PROVD) + 'VD*); ',"C","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                   Gorduras Totais                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                   

	MSCBSAY(16,57,'Gorduras Totais',"C","0",fonteInfNutri2)
	MSCBSAY(31,57,alltrim(ZZ7->ZZ7_GTQTP),"C","0",fonteInfNutri2) 
	MSCBSAY(35,57,'(' + alltrim(ZZ7->ZZ7_GTVD) + 'VD*); ',"C","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                   Fibra Alimentar                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(46,57,'Fibra Alim.',"C","0",fonteInfNutri2)
	MSCBSAY(01,59,alltrim(ZZ7->ZZ7_FIAQTP),"C","0",fonteInfNutri2)
	MSCBSAY(11,59,'(' + alltrim(ZZ7->ZZ7_FIAVD) + 'VD*); ',"C","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                         Sodio                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(21,59,'Sodio',"C","0",fonteInfNutri2)
	MSCBSAY(27,59,alltrim(ZZ7->ZZ7_SODQTP),"C","0",fonteInfNutri2)
	MSCBSAY(33,59,'(' + alltrim(ZZ7->ZZ7_SODVD) + 'VD*); ',"C","0",fonteInfNutri2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                 Gorduras Saturadas                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(43,59,'Gord. Satur.',"C","0",fonteInfNutri2)
	MSCBSAY(55,59,alltrim(ZZ7->ZZ7_GSQTP),"C","0",fonteInfNutri2)
	MSCBSAY(01,61,'(' + alltrim(ZZ7->ZZ7_GSVD) + 'VD*); ',"C","0",fonteInfNutri2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   			 Fim das Informações Nutricionais          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Mensagens Adicionais na parte inferior da etiqueta  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MSCBSAY(11,61,'(*)VALORES DIARIOS DE REFERENCIA COM BASE EM UMA DIETA DE',"C","0",fontelinha9)
	MSCBSAY(01,63,'2.000kcal, OU 8400 kj.SEUS VALORES DIARIOS PODEM SER MAIORES OU MENORES',"C","0",fontelinha9)
	MSCBSAY(01,65,'DEPENDENDO DE SUAS NECESSIDADES ENERGETICAS. APOS ABERTO CONSUMIR EM',"C","0",fontelinha9)
	MSCBSAY(01,67,'ATE 2 DIAS.',"C","0",fontelinha9)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³             Mensagens do Ministerio                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if _cDestMerc = "Merc. Externo"
		MSCBSAY(10,67,'USO AUTORIZADO PELO MINISTERIO DA AGRICULTURA/SIF/DIPOA ',"C","0",fonteInscSIF)
		MSCBSAY(01,69,'SOB Nr '+ZZ7->ZZ7_MSIF,"C","0",fonteInscSIF)
	else	
		MSCBSAY(10,67,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA ',"C","0",fonteInscSIF)
		MSCBSAY(01,69,'SOB Nr '+ZZ7->ZZ7_MSIF,"C","0",fonteInscSIF)
	endif  

	MSCBEND()
	MSCBCLOSEPRINTER()
	mlr03clear()

	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

return
