#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT08     º Autor ³Mauricio Roehrsº ³ Data ³09/09/13	     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ Impressão de etiqueta Interna						      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MRVT08(_usuario)

	Private _cModelo  := ''
	Private _cPar01   := space(06) 		  	//Codigo do Produto
	Private _cPar02   := date()//dtoc(dDataBase)  	//Data de produção
	Private _cPar03   := space(40)   		//Descrição do Produto
	//Private _cPar04   := '  '		 			//Tara
	Private _cPar04   := space(05)		 			//Tara alterado por Fabian Maurer dia 10/08/17
	Private _cPar05   := space(03)      	//Quantidade de etiquetas
	Private _cPar06   := '1'   		   	//Mercado Destino
	Private _cPar07   := 'XXXXX'        	//Sexo
	Private _cPar08 	:= date()            //Data de Embalagem
	Private _cPar09	:= '1'					//Tipo de Etiqueta
	Private _cIpImp   := ''
	Private _lOk      := .t.
	Private _cUsuarios := getMv('SI_USRETQ')//parametro com os codigos dos usuarios que podem imprimir ETQ interna com data maior que DATABASE
	Private _cUsrPorc  := getMv('SI_ETQPRC')//parametro com os codigos de usuarios que podem imprimir com um intervalo de datas bem grande
	Private _cCodUser  := retCodUsr()
	
	ZAA->(DbSetOrder(2))
	ZAA->(DbSeek(xfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL09 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif

	//Define o tamanho da Tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()
	/* Novo bloco de validação de dias para a impressão. By Flávio - Dia 09/09/20 */
	
	if alltrim(_cCodUser) $ _cUsuarios
		_dDTMaior   := date() + 7
		_dDTMenor	:= date() - 7

	Elseif alltrim(_cCodUser) $ _cUsrPorc
		_dDTMaior   := date() + 365
		_dDTMenor	:= date() - 365

	else 
		_dDTMaior   := date()
		_dDTMenor	:= date() - 7
	endif


	while _lOk

		@ 01,05 VTSay "IMPRESSAO ETQ. INTERNA"
		@ 03,05 VTSay "Parametros Iniciais:"
		@ 05,00 VTSay "Produto:      [      ]"         //_cPar01
		@ 06,00 VTSay "Dt. Produc.:  [        ]"       //_cPar02
		@ 07,00 VTSay "Dt. Embala.:  [        ]"       //_cPar08
		@ 08,00 VTSay "Desc. Prod.:" + space(40)       //_cPar03
		@ 09,00 VTSay "Tara:       " + space(05)       //_cPar04 alterado por Fabian Maurer dia 10/08/17
		@ 10,00 VTSay "Qtd. Caixas:  [   ]"            //_cPar05
		@ 11,00 VTSay "Tp. Mercado:  [ ]1:I|2:E"       //_cPar06
		@ 12,00 VTSay "Tp. Etiqueta: [ ]1:Normal|2:GO" //_cPar09
		@ 13,17 VTSay                  "3:TERNEZ "

		@ 16,00 VTSay "ESC para Sair"

		@ 05,15 VTGet _cPar01 Pict "@! "        	valid getProd()
		//@ 06,15 VTGet _cPar02 Pict "@! 99/99/99"	valid !empty(_cPar02)//Data Producao comentado por Fabian Maurer 09/01/17  colocar limite de data solic. Matheus Silva
		//@ 07,15 VTGet _cPar08 Pict "@! 99/99/99"	valid !empty(_cPar08)//Data Embalagem comentado por Fabian Maurer 09/01/17 colocar limite de data solic. Matheus Silva
		@ 06,15 VTGet _cPar02 Pict "@! 99/99/99"	valid _cPar02 >= _dDTMenor .and. _cPar02 <= _dDTMaior// data Producao
		@ 07,15 VTGet _cPar08 Pict "@! 99/99/99"  valid _cPar08 >= _dDTMenor .and. _cPar08 <= _dDTMaior// data Embalagem
		//@ 08,15 VTGet _cPar03 Pict "@! "
		//@ 09,15 VTGet _cPar04 Pict "@! "   	   	valid (val(_cPar04) > 0) .or. !empty(_cPar04) comentado por Fabian Maurer dia 10/08/17
		@ 10,15 VTGet _cPar05 Pict "@! "   	   	valid ((val(_cPar05) > 0) .and. (val(_cPar05) < 200)) .and. !empty(_cPar05)
		@ 11,15 VTGet _cPar06 Pict "@! "   	   	valid (_cPar06 $ '12')
		@ 12,15 VTGet _cPar09 Pict "@! "   	   	valid (_cPar09 $ '123') .and. !empty(_cPar09)
		VTRead

		/*
		_dDTMaior := date()
		_dDTMenor	:= date() - 7
		valid _cPar02 >= _dDTMenor .and. _cPAR02 <= _dDTMaior// data producao
		valid _cPar08 >= _dDTMenor .and. _cPar08 <= _dDTMaior// data producao
		*/

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		/*se for 1 imprime etiqueta interna normal*/
		if _cPar09 = '1'
			//Cod.Prod,Dt.Prod,Desc Prod,Tara,Qtd.Etq,Tp.Merc, Sexo , Dt.Embala
			impNorm(_cPar01,_cPar02,_cPar03,_cPar04,_cPar05,_cPar06,_cPar07,_cPar08)

			/*se for 2 imprime etiqueta interna GO*/
		elseif _cPar09 = '2'
			//Cod.Prod,Dt.Prod,Desc Prod,Tara   ,Qtd.Etq,Tp.Merc, Sexo  , Dt.Embala
			impGO(_cPar01,_cPar02,_cPar03  ,_cPar04,_cPar05,_cPar06,_cPar07,_cPar08)

			/*se for 3 imprime etiqueta interna TERNEZ*/
		elseif _cPar09 = '3'
			//Cod.Prod,Dt.Prod,Desc Prod,Tara  ,Qtd.Etq,Tp.Merc, Sexo  , Dt.Embala
			impTERNEZ(_cPar01,_cPar02,_cPar03  ,_cPar04,_cPar05,_cPar06,_cPar07,_cPar08)
			
		endif

		_cPar01   := space(06) 		//Codigo do Produto
		_cPar02   := date()//dtoc(dDataBase)	//Data de produção
		_cPar08   := date()//dtoc(dDataBase)	//Data de embalagem
		_cPar03   := space(40)   		//Descrição do Produto
		_cPar04   := space(05)		 		//Tara
		_cPar05   := space(03)    	//Quantidade de etiquetas
		_cPar06   := '1'   		   	//Mercado Destino
		_cPar09   := '1'             //tipo de etiqueta
	enddo

return

Static Function getProd()

	_lOk := .f.
	/*
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())
	if SB1->(DbSeek(xFilial('SB1') + padl(alltrim(_cPar01),6,'0')))
	if SB1->B1_TIPO $ 'PA/PR' .and. SB1->B1_MSBLQL = '2'
	_cPar01 := padl(alltrim(_cPar01),6,'0')
	@ 05,15 VTSay _cPar01

	_cPar03 := substr(SB1->B1_DESCRED,1,15)
	@ 07,13 VTSay _cPar03

	_lOk := .t.
	endif
	endif
	*/
	ZZ7->(DbGoTop())
	ZZ7->(DbSetOrder(1))
	if ZZ7->(DbSeek(xFilial('ZZ7') + padl(alltrim(_cPar01),6,'0')))

		_cPar01 := padl(alltrim(_cPar01),6,'0')
		@ 05,15 VTSay _cPar01

		_cPar03 := ZZ7->ZZ7_CORTE
		@ 08,13 VTSay _cPar03

		// Inicio bloco inserido por Fabian Maurer para levar a tara automatica do cadastro de produto, solicitação Matheus Silva dia 07/08/17
		_nTaraP := FBuscaCPO('SB1',1,xfilial('SB1')+ alltrim(_cPar01),'B1_CTARAP')      // Linhas inseridas para buscar"_NTARAp"
		_nTP    := FBuscaCPO('ZAB',1,xfilial('ZAB')+alltrim(_nTaraP),'ZAB_TARA')  // os campos de codigo das taras primarias
		//_cPar04 := transform(_nTP * 1000,'@E 9.999')
		_cPar04 := str(_nTP * 1000)
		//_cPar04  := str(_nTP)
		@ 09,15 VTSay _cPar04
		// Fim do bloco inserido por Fabian Maurer

		_lOk := .t.
	endif

return _lOk

/*Imprime etiqueta interna normal*/
Static Function impNorm(_cod,_cDtprod,_desc,_tara,_quant,_merc,_sexo,_cDtEmbala)

	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7')+_cod))

	_cIpImp := alltrim(fBuscaCPO('ZAM',1,xFilial('ZAM') + 'IDSO1','ZAM_IP'))

	if empty(_cIpImp)
		VTAlert('IP da impressora nao encontrado!!','Aviso de Encerramento(01)',.T.,2000,1)
		return
	endif

	_nQtdCx := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(_cod),'B1_QCAIX')
	_nQetq  := _nQtdCx * val(_quant)

	//Impressão por rede
	//MSCBPRINTER('S600','IP',,,,,_cIpImp)
	//_cIpImp := '10.11.20.167'
	MSCBPRINTER('S600','IP',,,,,_cIpImp)
	MSCBCHKSTATUS(.t.)
	MSCBBEGIN(_nQetq,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas val(_quant)

	dtVALID := _cDtProd+ZZ7->ZZ7_DVALID // Data de validade
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
	pos:=38-t
	MSCBSAY(2,pos,ZZ7->ZZ7_DESC,"B","0",fonteDesc)
	pos2:=0
	t2:=len(alltrim(_desc))
	pos2:=42-t2

	DbSelectArea('SB1')

	MSCBSAY(9,pos2,alltrim(_desc),"B","0",fontecorte) // nome do corte
	MSCBSAY(16,52,dtoc(_cDtprod),"B","0",fonteData) //Data Producao
	//MSCBSAY(16,52,substr(_cDtprod,7,2)+'/'+substr(_cDtprod,5,2)+'/'+substr(_cDtprod,3,2),"B","0",fonteData) //Data da producao

	_sif04   := GetMV('SI_SIFET04')
	_sif07 	 := GetMV('SI_SIFET07')
	_sif07_2 := GetMv('SI_SIFTE07')
	_sif12 	 := GetMV('SI_SIFET12')
	_sif18   := GetMV('SI_SIFET18')
	_MSIF    := substr(ZZ7->ZZ7_MSIF,1,4)

	if (_MSIF $ _sif07) .or. (_MSIF $ _sif07_2)
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif12
		MSCBSAY(15,5,'MANTER CONGELADA A -12 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif18
		MSCBSAY(15,5,'MANTER CONGELADA A -18 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif04
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 4 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	endif

	MSCBSAY(21,49,dtoc(dtVALID),"B","0",fonteData) //Data validade
	MSCBSAY(21,24,_sexo,"B","0",fonteNomeCorte1)// Sexo
	//MSCBSAY(21,13,alltrim(_tara)+'g',"B","0",fonteNomeCorte1)//tara
	MSCBSAY(21,13,str(val(strtran(_tara,'.',''))) + "g","B","0",fonteNomeCorte1)//tara

	//identificar o tipo de mensagem do Ministerio
	if _merc = "2" //se for mercado externo
		MSCBSAY(24,02,'USO AUTORIZADO PELO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)
	else
		MSCBSAY(24,07,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)//REGISTRO NO
	endif

	//Box Grande
	MSCBBOX(26,6,53,70,4)
	//1º Titulo
	MSCBSAY(27,41,'INFORMACOES NUTRICIONAIS',"B","0",fonteInfNutri1)
	MSCBSAY(27,07,ZZ7->ZZ7_PRTCOM,"B","0",fonteInfNutri1)//MSCBBOX(34,6,34,70,3)
	MSCBBOX(29,6,29,70,3)

	//2º Linha
	MSCBSAY(30,49,'Quantidade por Porcao',"B","0",fonteInfNutri2)
	MSCBLineH(29,45,37,3,"B")//1ª Barra vertical
	MSCBSAY(30,38,'%VD(*)',"B","0",fonteInfNutri2)
	MSCBLineH(29,37,37,3,"B")//2ª Barra vertical
	MSCBSAY(30,16,'Quantidade por Porcao',"B","0",fonteInfNutri2)
	MSCBLineH(29,15,37,3,"B")   //3ª barra vertical   (y1,x1,x2)
	MSCBSAY(30,8,'%VD(*)',"B","0",fonteInfNutri2)
	MSCBLineV(32,6,70,3,"B")// essa linha esta fazendo a horizontal (Y,X1,X2)

	//3ª Linha           ENERGETICO
	MSCBSAY(33,57,'Valor energ.',"B","0",fonteInfNutri2)
	MSCBLineH(32,55,40,3,"B")//1ª Barra vertical
	MSCBSAY(33,46,ZZ7->ZZ7_CALQTP,"B","0",fonteInfNutri2)
	MSCBLineH(37,45,40,3,"B")//2ª Barra vertical
	MSCBSAY(33,39,ZZ7->ZZ7_CALVD,"B","0",fonteInfNutri2)
	MSCBLineH(37,37,40,3,"B")//3ª Barra vertical
	MSCBSAY(33,26,'Gord. Trans.',"B","0",fonteInfNutri2)
	MSCBLineH(32,24,40,3,"B")//4ª Barra vertical
	MSCBSAY(33,18,ZZ7->ZZ7_GTRTP,"B","0",fonteInfNutri2)
	MSCBLineH(37,15,40,3,"B")//5ª Barra vertical
	MSCBSAY(33,9,ZZ7->ZZ7_GTRVD,"B","0",fonteInfNutri2)
	MSCBLineV(35,6,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)

	//4ª Linha
	MSCBSAY(36,58,'Carboidratos',"B","0",fonteInfNutri2)
	MSCBLineH(32,55,43,3,"B")//1ª Barra vertical
	MSCBSAY(36,47,ZZ7->ZZ7_CARQTP,"B","0",fonteNutri4)
	MSCBLineH(37,45,43,3,"B")//2ª Barra vertical
	MSCBSAY(36,39,ZZ7->ZZ7_CARVD,"B","0",fonteInfNutri2)
	MSCBLineH(37,37,43,3,"B")//3ª Barra vertical
	MSCBSAY(36,25,'Fibra Alim.',"B","0",fonteInfNutri2)
	MSCBLineH(32,24,43,3,"B")//4ª Barra vertical
	MSCBSAY(36,18,ZZ7->ZZ7_FIAQTP,"B","0",fonteNutri4)
	MSCBLineH(37,15,43,3,"B")//5ª Barra vertical
	MSCBSAY(36,9,ZZ7->ZZ7_FIAVD,"B","0",fonteInfNutri2)
	MSCBLineV(38,6,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)

	//5ª Linha
	MSCBSAY(39,61,'Proteinas',"B","0",fonteInfNutri2)
	MSCBLineH(43,55,44,3,"B")//1ª Barra vertical
	MSCBSAY(39,48,ZZ7->ZZ7_PROQTP,"B","0",fonteInfNutri2)
	MSCBLineH(43,45,44,3,"B")//2ª Barra vertical
	MSCBSAY(39,39,ZZ7->ZZ7_PROVD,"B","0",fonteInfNutri2)
	MSCBLineH(43,37,44,3,"B")//3ª Barra vertical
	MSCBSAY(39,30,'Sodio',"B","0",fonteInfNutri2)
	MSCBLineH(41,24,44,3,"B")//4ª Barra vertical
	MSCBSAY(39,18,ZZ7->ZZ7_SODQTP,"B","0",fonteInfNutri2)
	MSCBLineH(43,15,44,3,"B")//5ª Barra vertical
	MSCBSAY(39,9,ZZ7->ZZ7_SODVD,"B","0",fonteInfNutri2)
	MSCBLineV(41,6,70,3,"B")

	//6ª Linha
	MSCBSAY(42,55,'Gorduras Totais',"B","0",fonteInfNutri2)
	MSCBLineH(42,55,44,3,"B")//1ª Barra vertical
	MSCBSAY(42,48,ZZ7->ZZ7_GTQTP,"B","0",fonteInfNutri2)
	MSCBLineH(42,45,43,3,"B")//2ª Barra vertical
	MSCBSAY(42,39,ZZ7->ZZ7_GTVD,"B","0",fonteInfNutri2)
	MSCBLineH(42,37,44,3,"B")//3ª Barra vertical
	MSCBSAY(42,26,'Gord. Satur.',"B","0",fonteInfNutri2)
	MSCBLineH(42,24,44,3,"B")//4ª Barra vertical
	MSCBSAY(42,18,ZZ7->ZZ7_GSQTP,"B","0",fonteInfNutri2)
	MSCBLineH(42,15,44,3,"B")//5ª Barra vertical
	MSCBSAY(42,9,ZZ7->ZZ7_GSVD,"B","0",fonteInfNutri2)
	MSCBLineV(44,6,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)

	MSCBSAY(45,12,'(*)VALORES DIARIOS DE REFERENCIA COM BASE EM UMA DIETA DE 2.000kcal,',"B","0",fontelinha9)
	MSCBSAY(47,16,'OU 8400 kJ.SEUS VALORES DIARIOS PODEM SER MAIORES OU MENORES',"B","0",fontelinha9)
	MSCBSAY(49,29,'DEPENDENDO DE SUAS NECESSIDADES ENERGETICAS.',"B","0",fontelinha9)
	// MSCBSAY(51,38,'APOS ABERTO CONSUMIR EM ATE 2 DIAS.',"B","0",fontelinha9) - Removido para atender a lógica abaixo

	_exmetq   := GetMV('SI_EXMETQ')

	if (!_cod $ _exmetq)
		MSCBSAY(51,38,'APOS ABERTO CONSUMIR EM ATE 2 DIAS.',"B","0",fontelinha9)
	endif
	
	MSCBEND()
	MSCBCLOSEPRINTER()

return

static Function impGO(_cod,_cDtprod,_desc,_tara,_quant,_merc,_sexo,_cDtEmbala)

	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7')+_cod))

	_cIpImp := alltrim(fBuscaCPO('ZAM',1,xFilial('ZAM') + 'IDSO1','ZAM_IP'))

	if empty(_cIpImp)
		VTAlert('IP da impressora nao encontrado!!','Aviso de Encerramento(01)',.T.,2000,1)
		return
	endif

	_nQtdCx := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(_cod),'B1_QCAIX')
	_nQetq  := _nQtdCx * val(_quant)

	//Impressão por rede
	//MSCBPRINTER('S600','IP',,,,,_cIpImp)
	MSCBPRINTER('S600','IP',,,,,_cIpImp)
	MSCBCHKSTATUS(.t.)
	MSCBBEGIN(_nQetq,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas val(_quant)

	dtVALID := _cDtProd+ZZ7->ZZ7_DVALID // Data de validade
	fontecorte      :="22,29"
	fontedesc       :="22,29"
	fonteNomeCorte  :="28,35"
	fonteNomeCorte1 :="18,35"
	fonteData       :="16,35"
	fonteMesTemp    :="22,15"
	fonteMesTemp1   :="19,13"
	fonteInscSIF    :="19,16"
	fonteInfNutri1  :="8,10"
	fonteInfNutri2  :="16,18"
	fonteNutri3     :="16,9"
	fonteNutri4     :="19,10"
	fontelinha9     :="14,14"
	fonte3          :="16,13"

	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=42-t
	MSCBSAY(2,pos,ZZ7->ZZ7_DESC,"B","0",fonteDesc)
	pos2:=0
	t2:=len(alltrim(_desc))
	pos2:=42-t2

	MSCBSAY(9,pos2,alltrim(_desc),"B","0",fontecorte) // nome do corte
	MSCBSAY(16,52,dtoc(_cDtprod),"B","0",fonteData) //Data Producao
	//MSCBSAY(16,52,substr(dtos(valor2),7,2)+'/'+substr(dtos(valor2),5,2)+'/'+substr(dtos(valor2),3,2),"B","0",fonteData) //Data da producao

	_sif07 := GetMV('SI_SIFET07')
	_sif12 := GetMV('SI_SIFET12')
	_sif18 := GetMV('SI_SIFET18')
	_MSIF  := substr(ZZ7->ZZ7_MSIF,1,4)

	if _MSIF $ _sif07
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif12
		MSCBSAY(15,5,'MANTER CONGELADA A -12 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif18
		MSCBSAY(15,5,'MANTER CONGELADA A -18 GRAUS CELSIUS',"B","0",fonteMesTemp)
	endif

	MSCBSAY(21,49,dtoc(dtVALID),"B","0",fonteData) //Data validade
	MSCBSAY(21,23,_sexo,"B","0",fonteNomeCorte1)// Sexo
	//MSCBSAY(21,13,alltrim(_tara)+'g',"B","0",fonteNomeCorte1)//tara
	MSCBSAY(21,11,str(val(strtran(_tara,'.',''))) + "g","B","0",fonteNomeCorte1)//tara
	MSCBSAY(24,9,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)
	//       Y  X
	// Primeira linha
	MSCBSAY(32,26,ZZ7->ZZ7_GOVE,"B","0",fonteInfNutri1) //QUANTO MAIOR O X MAIS PRA FRENTE
	MSCBSAY(32,37,ZZ7->ZZ7_GOKCAL,"B","0",fonteInfNutri1)
	MSCBSAY(32,02,ZZ7->ZZ7_GOGS,"B","0",fonteInfNutri1)
	MSCBSAY(32,19,ZZ7->ZZ7_GOGSG,"B","0",fonteInfNutri1)

	//       Y  X
	// Segunda linha
	MSCBSAY(38,27,ZZ7->ZZ7_GOC,"B","0",fonteInfNutri1)
	MSCBSAY(38,37,ZZ7->ZZ7_GOCG,"B","0",fonteInfNutri1)
	MSCBSAY(38,02,ZZ7->ZZ7_GOGT,"B","0",fonteInfNutri1)
	MSCBSAY(38,19,ZZ7->ZZ7_GOGTG,"B","0",fonteInfNutri1)

	//       Y  X
	// Terceira linha
	MSCBSAY(44,26,ZZ7->ZZ7_GOP,"B","0",fonteInfNutri1)
	MSCBSAY(44,43,ZZ7->ZZ7_GOPG,"B","0",fonteInfNutri1)
	MSCBSAY(44,02,ZZ7->ZZ7_GOFA,"B","0",fonteInfNutri1)
	MSCBSAY(44,19,ZZ7->ZZ7_GOFAG,"B","0",fonteInfNutri1)

	//       Y  X
	// Quarta linha
	MSCBSAY(50,26,ZZ7->ZZ7_GOGTO,"B","0",fonteInfNutri1)
	MSCBSAY(50,46,ZZ7->ZZ7_GOGTOG,"B","0",fonteInfNutri1)
	MSCBSAY(50,02,ZZ7->ZZ7_GOS,"B","0",fonteInfNutri1)
	MSCBSAY(50,19,ZZ7->ZZ7_GOSG,"B","0",fonteInfNutri1)

	MSCBEND()
	MSCBCLOSEPRINTER()
return
	
static Function impTERNEZ (_cod,_cDtprod,_desc,_tara,_quant,_merc,_sexo,_cDtEmbala)

	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7')+_cod))
	
	/* OBS - Setar a SB1 para usar a descrição reduzida
		Dia 31/10/19 - Ajuste feito por Flávio , inclusão das 2 linhas abaixo para setar a SB1	
	*/
	SB1->(dbsetorder(1))
	SB1->(dbseek(xfilial('SB1')+padr(_cod,15,'')))
	
	_cIpImp := alltrim(fBuscaCPO('ZAM',1,xFilial('ZAM') + 'IDSO1','ZAM_IP'))

	if empty(_cIpImp)
		VTAlert('IP da impressora nao encontrado!!','Aviso de Encerramento(01)',.T.,2000,1)
		return
	endif

	
	_nQtdCx := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(_cod),'B1_QCAIX')
	_nQetq  := _nQtdCx * val(_quant)

	//conout(_nQetq)
	
//		MSCBPRINTER('S600','IP',,,,,"10.11.22.248")
		MSCBPRINTER('S600','IP',,,,,_cIpImp)
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nQetq,1,1)	// Usar variavel no primeiro campo, para a quantidade de etiquetas
		
		dtVALID := _cDtProd+ZZ7->ZZ7_DVALID // Data de validade
		fonteTit   :=  "30,25"
		fontedesc  :=  "30,30"
		fonteinf   :=  "20,20"
		fonteinfdt :=  "20,15"
		fontedata  :=  "25,25"
		fonteMesTemp1 := "28,23"
		//fonteNomeCorte1 := "25,25""    
		
		

				
		//Inicio Bloco Titulo
		MSCBSAY(4,6,ZZ7->ZZ7_DESC,"N","0",fonteTit)
		MSCBSAY(10,9,SB1->B1_DESCRED,"N","0",fonteDesc)
		//Fim Bloco Titulo
		
		//ajuste para imprimir costela - feito por Daniel 04-09-19
//		
		//Inicio Segundo Bloco
		MSCBSAY(2,16,"MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS","N","0",fonteMesTemp1)
		MSCBSAY(2,20,"Data de Abate/Produção/Lote:","N","0",fonteinfdt)
		MSCBSAY(29,20,dtoc(_cDtprod),"N","0",fonteData)
		MSCBSAY(2,23,"Data de Embalagem:","N","0",fonteinfdt)
		MSCBSAY(29,23,dtoc(_cDtEmbala),"N","0",fontedata)
		MSCBSAY(2,26,"Data de Validade:","N","0",fonteinfdt)
		MSCBSAY(29,26,dtoc(dtVALID),"N","0",fontedata)
		MSCBSAY(2,29,"Peso da Embalagem:","N","0",fonteinfdt)
		MSCBSAY(29,29,(_tara) + "g","N","0",fontedata)
		//Fim do Segundo Bloco


		//Inicio do Bloco com as linhas CNPJ e Contem Glutem

		//Inicio Terceiro Bloco
		MSCBSAY(2,33,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N " + ZZ7->ZZ7_MSIF,"N","0",fonteinfdt)
		MSCBSAY(2,36,"CNPJ 88.728.027.0001-46 - WWW.FRIGORIFICOSILVA.COM.BR","N","0",fonteinfdt)
		MSCBSAY(2,40,"NAO CONTEM GLUTEN","N","0",fonteinf)
		//Fim Terceiro Bloco

		//Inicio Quarto Bloco
		MSCBSAY(2,44,"INFORMACOES NUTRICIONAIS PORCAO DE 100G (1BIFE):","N","0",fonteinf)
		MSCBSAY(2,47,"Valor Energetico " + Alltrim(ZZ7->ZZ7_CALQTP) + "(" + Alltrim(ZZ7->ZZ7_CALVD) + ");" + "Carboidratos " + Alltrim(ZZ7->ZZ7_CARQTP) + "(" + Alltrim(ZZ7->ZZ7_CARVD) + ");","N","0",fonteinfdt)
		MSCBSAY(2,50,"Proteinas " + Alltrim(ZZ7->ZZ7_PROQTP) + "(" + Alltrim(ZZ7->ZZ7_PROVD) + ");" + "Gorduras Totais " + Alltrim(ZZ7->ZZ7_GTQTP) + "(" + Alltrim(ZZ7->ZZ7_GTVD) + ");" + "Gorduras Saturadas " + Alltrim(ZZ7->ZZ7_GSQTP) + "(" + Alltrim(ZZ7->ZZ7_GSVD) + ");","N","0",fonteinfdt)
		MSCBSAY(2,53,"Gorduras Trans 0g(0%VD);" + "Fibra Alimentar " + Alltrim(ZZ7->ZZ7_FIAQTP) + "(" + Alltrim(ZZ7->ZZ7_FIAVD) + ");" + "Sodio " + Alltrim(ZZ7->ZZ7_SODQTP) + "(" + Alltrim(ZZ7->ZZ7_SODVD) + ");","N","0",fonteinfdt)
		MSCBSAY(2,56,"*%Valores diarios de referencia com base em uma dieta de 2.000Kcal ou","N","0",fonteinfdt)
		MSCBSAY(2,59,"8.400kJ. Seus valores diarios podem ser maiores ou menores dependendo","N","0",fonteinfdt)
		MSCBSAY(2,61,"de suas necessidades energeticas.","N","0",fonteinfdt)
		//Fim do Quarto Bloco

		//Inicio Quinto Bloco
		// MSCBSAY(2,70,"Apos aberto consumir em ate 2 dias.","N","0",fonteinf) - Alterado para satisfazer a condição abaixo

		_exmetq   := GetMV('SI_EXMETQ')

		if (!_cod $ _exmetq)
			MSCBSAY(2,70,"Apos aberto consumir em ate 2 dias.","N","0",fonteinf)
		endif
		//Fim Quinto Bloco
		
	    //ajuste para imprimir costela - feito por Daniel 04-09-19
		//Inicio Codigo de Barras
		//MSCBSAYBAR(10,74,SB1->B1_CODBAR,"N","MB07",10,.F.,.T.,.F.,"C",2,1,.F.)
		MSCBSAYBAR(10,72,SB1->B1_CODBAR,"N","MB07",10,.F.,.T.,.F.,"C",2,1,.F.)
		//Fim Codigo de Barras
	
		MSCBEND()
		MSCBCLOSEPRINTER()
return


