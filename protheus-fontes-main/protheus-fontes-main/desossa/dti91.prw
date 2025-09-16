
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º                                                                       º±±
±±ºPrograma  ³DTI91   º Autor ³ Daniel        º Data ³  18/09/19          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressão de Etiqueta URUGUAY                              º±±
±±º          ³ 	   							                              º±±
±±º          ³ Dia 25/06/22 - Ajustado fonte( Adaptação) para impressão   º±±
±±º          ³ de etiquetas que faltaram ser compradas.(MI e ME) .	      º±±
±±º          ³ Solicitante 	Adriana -OBS não foi tratada regra de controleº±±
±±º          ³ De datas     - Avisado Adriana                             º±±
±±º          ³ Dia 04/11/22 - Ajuste Chamado ??? - Flávio                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desossa		                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI91()

	dbselectarea('SB1')
	dbsetorder(1)
	DbSelectArea('ZAB')
	ZAB->(dbsetorder(1))
	
	
		
	campoA  := Space(6)   // Campo do Codigo do Produto
	campoB 	:= 000          // Quantidade de Etiqueta
	campoC 	:= Space(8)   // Data de Abate
	campoD 	:= Space(8)   // Data de Embalagem
	campoE 	:= Space(40)   // Descrição Importador

	/*  Verificando regras de permissão de datas , acompanhar mesmas do dti41 */


	_cUsuarios  := getMv( 'SI_USRETQ' ) //parametro com os codigos dos usuarios que podem imprimir ETQ interna com data maior que DATABASE
	_cUsrPorc   := getMv( 'SI_ETQPRC' ) //parametro com os codigos de usuarios que podem imprimir com um intervalo de datas bem grande
	_cParTabNut := GetMV( 'MV_PARTNEI' ) //Neste parâmetro estão os códigos dos produtos que devem ter as informações nutricionais ocultas

	_cCodUser   := retCodUsr()

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
	valor2 	:= 000        // Quantidade de Etiqueta
	valor3 	:= date()     // Data de Abate
	valor4 	:= date()     // Data de Embalagem
	valor5 	:= Space(40)   // Descrição Importador

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA URUGUAY"
	//vinculação dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Data de Abate:" of telaimp
	//@ 03,01 SAY "Data de Embalagem:" of telaimp
	@ 03,01 SAY "Data de Produção/Lote:" of telaimp
	@ 04,01 SAY "Quant. Caixas:" of telaimp

	@ 01,08 MSGET campoA VAR valor1 SIZE 30,10 F3 'SB1' OF telaimp	
	
	
	/* Dia 06/07/22 - Colocado no silva4 e pedido para PCPs testarem por e-mail - dia 09/07/22 vai para a quente*/
	@ 02,08 MSGET campoC VAR valor3 SIZE 40,10  OF telaimp valid regra(valor3)// data producao
	@ 03,08 MSGET campoD VAR valor4 SIZE 40,10  OF telaimp valid regrab(valor4)// data embalagem
	@ 04,08 MSGET campoB VAR valor2 SIZE 20,10  OF telaimp  picture '@E 999' // Quant Etiqueta
	@ 70,08 MSGET campoE VAR valor5 SIZE 20,10  OF telaimp  picture '' // Importador

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	ACTIVATE MSDIALOG telaimp CENTERED

return

Static Function Imprime()

	Processa({||dti91etq() },"IMPRESSAO DE ETIQUETA","Realizando envio à impressora...")

return

static function dti91clear()
	valor2 	:= 0          // Quantidade de Etiqueta
	telaimp:refresh()
return

static Function dti91etq()
	Local  _DtAbt    := valor3
	//Local  _DtEmb    := valor4
	Local  _DtProd    := valor4

	DbSelectArea('ZAB')
	ZAB->(dbsetorder(1))

	
	_cCodTar := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(valor1),'B1_CTARAP')
	_nValTar := fBuscaCpo('ZAB',1,xFilial('ZAB') + _cCodTar,'ZAB_TARA')
	_cTPMerc := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(valor1),'B1_DESTINO')


	btn1:disable()
	telaimp:refresh()

	ProcRegua(valor2)

	DbSelectArea('SB1')
	SB1->(dbsetorder(1))
	DbSelectArea('ZZ7')
	ZZ7->(dbsetorder(1))
	

	SB1->(dbSeek(xfilial('SB1')+ valor1))
	ZZ7->(dbSeek(xfilial('ZZ7')+ valor1))
	
	//_DtVal := valor3 + SB1->B1_VALID // Data de validade	
	_DtVal := valor4 + SB1->B1_VALID // Data de validade
	_nQtdCx := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(valor1),'B1_QCAIX')
	_nQetq  := _nQtdCx * valor2

	

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
		

		MSCBBEGIN(_nQetq,6,15)	// Usar variavel no primeiro campo, para a quantidade de etiquetas

		fonteTit   :=  "22,25"
		fontedesc  :=  "22,30"
		fonteinf   :=  "14,20"
		fonteinfdt :=  "15,15"
		fontedata  :=  "18,25"
		fonteimp   :=  "12,15"


		// Se for Produto cadastrado como exportação gera bloco abaixo
		If _cTPMerc = "ME"
			_nCont      :=  0
		
			MSCBSAY(03,06,ZZ7->ZZ7_DESC,"N","0",fonteTit)
			MSCBSAY(03,10,ZZ7->ZZ7_CORTEE,"N","0",fonteTit)
			MSCBSAY(10,14,ZZ7->ZZ7_CORTE,"N","0",fonteDesc)
			//Fim Bloco Titulo

			//Inicio Segundo Bloco
			MSCBSAY(3,17,SB1->B1_MENETQ2,"N","0",fonteinf)
			//MSCBSAY(3,20,"Data de Abate/Produção/Lote:","N","0",fonteinfdt)	//Comentado por Lucas Bolzan
			MSCBSAY(3,20,"Data de Produção/Lote:","N","0",fonteinfdt)
			MSCBSAY(37,20,DtoC(_DtAbt),"N","0",fontedata)
			
			//MSCBSAY(3,23,"Data de Embalagem:","N","0",fonteinfdt)			
			//MSCBSAY(37,23,DtoC(_DtEmb),"N","0",fontedata)  
			MSCBSAY(3,23,"Data de Producao/Lote:","N","0",fonteinfdt)
			MSCBSAY(37,23,DtoC(_DtProd),"N","0",fontedata) 
			
			MSCBSAY(3,26,"Data de Validade:","N","0",fonteinfdt)
			MSCBSAY(37,26,DtoC(_DtVal),"N","0",fontedata)
			MSCBSAY(3,29,"Peso da Embalagem:","N","0",fonteinfdt)
			MSCBSAY(37,29, Str(_nValTar) + "g","N","0",fontedata)
			//Fim do Segundo Bloco
			
			
			//Inicio do Bloco sem as Linhas de Contem Glutem e CNPJ

			//Inicio Terceiro Bloco
			MSCBSAY(3,32,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N " + ZZ7->ZZ7_MSIF,"N","0",fonteinfdt)
			MSCBSAY(3,35,"SIF de Origem XXXXXX","N","0",fonteinfdt)
			MSCBSAY(3,37,alltrim(ZZ7->ZZ7_OBS),"N","0",fonteinfdt)
			//Fim Terceiro Bloco

			//Inicio Quarto Bloco
			MSCBSAY(3,38,"INFORMACOES NUTRICIONAIS PORCAO DE 100G (1BIFE):","N","0",fonteinf)
			MSCBSAY(3,41,"Valor Energetico " + Alltrim(ZZ7->ZZ7_CALQTP) + "(" + Alltrim(ZZ7->ZZ7_CALVD) + ");" + "Carboidratos " + Alltrim(ZZ7->ZZ7_CARQTP) + "(" + Alltrim(ZZ7->ZZ7_CARVD) + ");","N","0",fonteinfdt)
			MSCBSAY(3,44,"Proteinas " + Alltrim(ZZ7->ZZ7_PROQTP) + "(" + Alltrim(ZZ7->ZZ7_PROVD) + ");" + "Gorduras Totais " + Alltrim(ZZ7->ZZ7_GTQTP) + "(" + Alltrim(ZZ7->ZZ7_GTVD) + ");" + "Gorduras Saturadas " + Alltrim(ZZ7->ZZ7_GSQTP) + "(" + Alltrim(ZZ7->ZZ7_GSVD) + ");","N","0",fonteinfdt)
			MSCBSAY(3,47,"Gorduras Trans 0g(0%VD);" + "Fibra Alimentar " + Alltrim(ZZ7->ZZ7_FIAQTP) + "(" + Alltrim(ZZ7->ZZ7_FIAVD) + ");" + "Sodio " + Alltrim(ZZ7->ZZ7_SODQTP) + "(" + Alltrim(ZZ7->ZZ7_SODVD) + ");","N","0",fonteinfdt)
			MSCBSAY(3,50,"*%Valores diarios de referencia com base em uma dieta de 2.000Kcal ou","N","0",fonteinfdt)
			MSCBSAY(3,53,"8.400kJ. Seus valores diarios podem ser maiores ou menores dependendo","N","0",fonteinfdt)
			MSCBSAY(3,56,"de suas necessidades energeticas.","N","0",fonteinfdt)
			
			//Fim do Quarto Bloco


			//Inicio Quinto Bloco
			_exmetq   := GetMV('SI_EXMETQ')
			_cod      := ZZ7->ZZ7_CODPRO

			if (_cod $ _exmetq)
				MSCBSAY(3,56,"Apos aberto consumir em ate 2 dias.","N","0",fonteinf)
			endif
			//Fim Quinto Bloco
		
			//Inicio Sexto Bloco
				
			MSCBSAY(3,59,"IMPORTADOR:","N","0",fonteinf)
			MSCBSAY(3,61,alltrim(ZZ7-> ZZ7_IMPOR),"N","0",fonteimp)
			MSCBSAY(3,63,(ZZ7-> ZZ7_ENDIMP),"N","0",fonteimp)
			MSCBSAY(3,65,(ZZ7-> ZZ7_RUT),"N","0",fonteimp)
			MSCBSAY(3,67,(ZZ7-> ZZ7_RMONO),"N","0",fonteimp)
			MSCBSAY(3,69,(ZZ7-> ZZ7_RROTU),"N","0",fonteimp)
			MSCBSAYBAR(49,55,ZZ7->ZZ7_CODPRO,"R","C",10,,.t.,,,2,2,.t.)
			
			MSCBSAY(3,63,'RASTREABILIDADE: 1733'+Dtos(_DtAbt),"N","0",fontedata)


		else
			// Se For Mercado Interno  MI
			_nCont      :=  0
			//Inicio Bloco Titulo
			MSCBSAY(3,6,ZZ7->ZZ7_DESC,"N","0",fonteTit)
			MSCBSAY(10,10,ZZ7->ZZ7_CORTE,"N","0",fonteDesc)
			
			//Fim Bloco Titulo

			//Inicio Segundo Bloco
			MSCBSAY(3,17,SB1->B1_MENETQ2,"N","0",fonteinf)
			MSCBSAY(3,20,"Data de Abate/Produção/Lote:","N","0",fonteinfdt)
			MSCBSAY(37,20,DtoC(_DtAbt),"N","0",fontedata)
			
			//MSCBSAY(3,23,"Data de Embalagem:","N","0",fonteinfdt)
			//MSCBSAY(37,23,DtoC(_DtEmb),"N","0",fontedata)
			MSCBSAY(3,23,"Data de Producao/Lote:","N","0",fonteinfdt)
			MSCBSAY(37,23,DtoC(_DtProd),"N","0",fontedata)

			MSCBSAY(3,26,"Data de Validade:","N","0",fonteinfdt)
			MSCBSAY(37,26,DtoC(_DtVal),"N","0",fontedata)
			MSCBSAY(3,29,"Peso da Embalagem:","N","0",fonteinfdt)
			MSCBSAY(37,29, Str(_nValTar) + "g","N","0",fontedata)
			
			MSCBSAY(3,32,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N " + ZZ7->ZZ7_MSIF,"N","0",fonteinfdt)
			MSCBSAY(3,35,"SIF de Origem XXXXXX","N","0",fonteinfdt)			
			MSCBSAY(3,37,alltrim(ZZ7->ZZ7_OBS),"N","0",fonteinfdt)
		
			if alltrim(valor1) $ _cParTabNut
							
			else
				MSCBSAY(3,38,"INFORMACOES NUTRICIONAIS PORCAO DE 100G (1BIFE):","N","0",fonteinf)			
				MSCBSAY(3,41,"Valor Energetico " + Alltrim(ZZ7->ZZ7_CALQTP) + "(" + Alltrim(ZZ7->ZZ7_CALVD) + ");" + "Carboidratos " + Alltrim(ZZ7->ZZ7_CARQTP) + "(" + Alltrim(ZZ7->ZZ7_CARVD) + ");","N","0",fonteinfdt)
				MSCBSAY(3,44,"Proteinas " + Alltrim(ZZ7->ZZ7_PROQTP) + "(" + Alltrim(ZZ7->ZZ7_PROVD) + ");" + "Gorduras Totais " + Alltrim(ZZ7->ZZ7_GTQTP) + "(" + Alltrim(ZZ7->ZZ7_GTVD) + ");" + "Gorduras Saturadas " + Alltrim(ZZ7->ZZ7_GSQTP) + "(" + Alltrim(ZZ7->ZZ7_GSVD) + ");","N","0",fonteinfdt)
				MSCBSAY(3,47,"Gorduras Trans 0g(0%VD);" + "Fibra Alimentar " + Alltrim(ZZ7->ZZ7_FIAQTP) + "(" + Alltrim(ZZ7->ZZ7_FIAVD) + ");" + "Sodio " + Alltrim(ZZ7->ZZ7_SODQTP) + "(" + Alltrim(ZZ7->ZZ7_SODVD) + ");","N","0",fonteinfdt)
				MSCBSAY(3,50,"*%Valores diarios de referencia com base em uma dieta de 2.000Kcal ou","N","0",fonteinfdt)
				MSCBSAY(3,53,"8.400kJ. Seus valores diarios podem ser maiores ou menores dependendo","N","0",fonteinfdt)
				MSCBSAY(3,56,"de suas necessidades energeticas.","N","0",fonteinfdt)
			endif
			
			_exmetq   := GetMV('SI_EXMETQ')
			_cod      := ZZ7->ZZ7_CODPRO

			if (_cod $ _exmetq)
				MSCBSAY(3,56,"Apos aberto consumir em ate 2 dias.","N","0",fonteinf)
			endif		

			//MSCBSAYBAR(45,55,ZZ7->ZZ7_CODPRO,"R","C",10,,.t.,,,2,2,.t.)
			MSCBSAYBAR(49,55,ZZ7->ZZ7_CODPRO,"R","C",10,,.t.,,,2,2,.t.)
			MSCBSAY(3,63,'RASTREABILIDADE: 1733'+Dtos(_DtAbt),"N","0",fontedata)

		Endif
		
		_nCont++

		MSCBEND()
		MSCBCLOSEPRINTER()

	dti91clear()

	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

	btn1:enable()
	telaimp:refresh()

return                   


Static function regra(_data)

	
	_cUsuarios := getMv('SI_USRETQ')//parametro com os codigos dos usuarios que podem imprimir ETQ interna ( para campo Data Abate) com data maior que DATABASE
	_cUsrPorc  := getMv('SI_ETQPRC')//parametro com os codigos de usuarios que podem imprimir  ( para campo Data Abate) com um intervalo de datas bem grande
		//alert('linha 289')
	
	_cCodUser  := retCodUsr()
	_dDTMaior := date()
	_dDTMenor := date() - 30
		
	if empty(_data)
		MsgAlert('Favor preencher campo da Data de Abate !! ', 'PREENCHIMENTO PROIBIDA !!')	
			return .f.
	endif
	/* Devemos cadastrar o usuário somente em um dos  parâmetros, ou no SI_USRETQ ou no SI_ETQPRC*/
	if alltrim(_cCodUser) $ _cUsuarios
		/* Regra para campo - Data Abate - Parametro SI_USRETQ */
		regraa(_data)
	
	Elseif alltrim(_cCodUser) $ _cUsrPorc
		/* Regra para campo - Data Abate - Parametro SI_ETQPRC - Porcionados */
		
		regrac(_data)
	else 
		/* Se não estiver nos parâmetros então cai aqui */
		if _data = _dDTMaior  .or. _data = _dDTMenor			
			return .t.
		else
			MsgAlert('Data Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
			return .f.
		endif
	Endif	
	

Return .t.


Static Function regraa(_data1)
	
	_cCodUser  := retCodUsr()
	//_dDTMaior := date() - ia 07/05/22 ajuste solicitado por deise 
	_dDTMaior := date() - 1
	_dDTMenor := date() - 30

	if _data1 = _dDTMaior 			
		return .t.
	elseif _data1 <= _dDTMaior

		if _data1 >= _dDTMenor
			return .t.
		else
			MsgAlert('1 - Data do Abate Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
			campoB:SETFOCUS()
			return .f.
		endif
	else
		MsgAlert('2 - Data do Abate Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
			campoB:SETFOCUS()
			return .f.
	endif
Return

Static Function regrac(_data2)

	//_dDTMaior   := date() + 365
	//_dDTMenor	:= date() - 365
	_dDTMaior   := date() + 365
	_dDTMenor   := date() - 365

	/*Regras do campo "Data do Abate" para usuários Porcionados - SI_ETQPRC*/	
	
	if _data2 <= _dDTMaior 			
		
		if _data2 >= _dDTMenor 
			return .t.
		else
			MsgAlert('1 - Data do  Abate Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
			campoB:SETFOCUS()	
			return .f.		
		endif
	else
		MsgAlert('2 - Data do Abate Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
		campoB:SETFOCUS()			
		return .f.	
	endif
	
return

Static function regrab(_dVlr8)
	
	_cCodUser  := retCodUsr()
	_dDTEMa   := date() + 5
	_dDTEMe   := date()
	/*Regras do campo "Data do Abate" para usuários Porcionados - SI_ETQPRC*/	
	_cUCemb    := getMv('SI_USRETE')//parametro com os codigos dos usuarios que podem imprimir ETQ interna ( para campo Data Embalagem) com data maior que DATABASE

	if alltrim(_cCodUser) $ _cUCemb	

		if _dVlr8 < _dDTEMa 
		
			if _dVlr8 >= _dDTEMe 
				return .t.
			else
				MsgAlert('1-Data da Embalagem Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
				campoB:SETFOCUS()	
				campoF  := space(08)			
				return .f.		
			endif

		Elseif alltrim(_cCodUser) $ _cUsrPorc
			/* Regra para campo - Data Abate - Parametro SI_ETQPRC - Porcionados */
			_dDTEMa   := date() + 365
			_dDTEMe   := date() - 365
			if _dVlr8 < _dDTEMa 
				if _dVlr8 >= _dDTEMe 
					return .t.
				else
					MsgAlert('2 - Data da Embalagem Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
					campoB:SETFOCUS()	
					//campoF  := space(08)			
					return .f.		
				endif
			else
				MsgAlert('3 - Data da Embalagem Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
				campoB:SETFOCUS()	
				//campoF  := space(08)			
				return .f.	
			Endif

		else
			MsgAlert('4 - Data da Embalagem  Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
			campoB:SETFOCUS()	
			campoF  := space(08)		
			return .f.
		endif
	else
		//Regra para quem não esta cadastrado no parâmetro
		if _dVlr8 = date()   .or.  _dVlr8 = _dDTEMe
			return .t.
		else
			MsgAlert('3 - Data da Embalagem  Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
			campoB:SETFOCUS()			
			return .f.
		endif
	endif
Return
