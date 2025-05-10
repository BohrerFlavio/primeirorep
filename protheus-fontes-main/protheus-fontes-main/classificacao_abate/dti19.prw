#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI19   º Autor ³ Flávio Bohrer Flôres º Data ³  25/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de Pré - etiqueta Embalagem                      º±±
±±º          ³ OBS - Com Alteração do processo que gera o sequencial      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Embalagem                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function dti19()

	Private _ProdRes   := GETMV('SI_PRODRES')
	Private _PrdQtCx   := alltrim(GETMV('SI_PRDQTCX'))+alltrim(GETMV('SI_PRDQTC2'))+alltrim(GETMV('SI_PRDQTC3'))
	//Inicio Adição de parâmetros inseridos por Lucas Bolzan atendendo chamado 2739
	Private _cUsrEtq   := getMv('SI_USRETQ') //Parâmetro com os códigos dos usuários que podem imprimir pré etiquetas com data maior que DATABASE
	Private _cUsrPorc  := getMv('SI_ETQPRC') //Parâmetro com os códigos dos usuários que podem imprimir pré-etiquetas com um intervalo de datas bem grande
	Private _cUsrLib   := getMv('SI_PETQLIB')
	Private _cCodUser  := retCodUsr()		 //Retorna o código do usuário logado e atribui a _cCodUser
	Private _cProdMDS  := GetMV('MV_GRPMDS')

	dbselectarea('SB1')
	dbsetorder(1)

	aCbx := {'Não','Sim'}

	campoA   := Space(06)  //campo do codigo do produto
	campoB 	 := Space(40)  //campo da descrição do corte
	campoC 	 := 0
	campoE   := stod('')
	campoF   := {space(10),"Congelados","Resfriados"}
	campoG   := 0
	campoH   := {"NAO","  ","SIM"}
	campoI  := stod('')

	valor1 	 := Space(06) //codigo do produto
	valor2 	 := Space(40) //Descrição do corte
	valor3 	 := 0         //Quantidade de etiquet
	valor4   := stod('')  //data de produçao
	valor5   := stod('')  //data de Devoluçao
	valor6   := space(10)
	valor9   := space(5)
	Valor7   := 0
	valor10  := space(3)
	valor11  := stod('')  //data de Abate
	_dDthoje   := date()  //data da produção

	if alltrim(_cCodUser) $ _cUsrEtq
		_dDTMaior   := date() + 7
		_dDTMenor	:= date() - 7
	elseif alltrim(_cCodUser) $ _cUsrPorc
		_dDTMaior   := date() + 365
		_dDTMenor	:= date() - 365
	elseif alltrim(_cCodUser) $ _cUsrLib
		_dDTMaior   := date() + 9999
		_dDTMenor	:= date() - 9999
	else
		_dDTMaior   := date()
		_dDTMenor	:= date() - 7
	endif

	//Fim Adição de parâmetros inseridos por Lucas Bolzan atendendo chamado 2739

	//DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE PRÉ-ETIQUETA P/ EMBALAGEM"
	DEFINE MSDIALOG telaimp FROM 0,0 TO 320,300 PIXEL TITLE "IMPRESSAO DE PRÉ-ETIQUETA P/ EMBALAGEM"
	//vinculação dos campos com os valores

	@ 01,01 SAY "Reprocesso?:" of telaimp
	@ 02,01 SAY "Produto:" of telaimp
	@ 03,01 SAY "Descrição Corte:" of telaimp
	@ 04,01 SAY "Quant. Etiq.:" of telaimp	
	@ 05,01 SAY "Data de Devolução:" of telaimp
	@ 06,01 SAY "Data de Produção:" of telaimp
	@ 07,01 SAY "Data de Abate:" of telaimp
	@ 08,01 SAY "Armazenamento:" of telaimp
	@ 09,01 SAY "Quant. Produto:" of telaimp
	//@ 09,01 SAY "Devolução:" of telaimp

	@ 02,08 MSGET campoA VAR valor1 SIZE 30,10 F3 'SB1' OF telaimp VALID valGrupo(valor1)
	@ 03,08 SAY valor2 of telaimp
	@ 04,08 MSGET campoC VAR valor3 SIZE 20,10  OF telaimp picture '@E 999' VALID valor3 <= 50// quant etiqueta
	@ 05,08 MSGET campoE VAR valor5 SIZE 30,10  OF telaimp picture '99/99/99'
	@ 06,08 MSGET campoI VAR valor4 SIZE 30,10  OF telaimp picture '99/99/99'
	@ 07,08 MSGET campoJ VAR valor11 SIZE 30,10  OF telaimp picture '99/99/99' valid DTABT()

	@ 08,08 MSCOMBOBOX oComboBo1 VAR  valor6  ITEMS campoF SIZE 040, 010 OF telaimp
	@ 01,08 MSCOMBOBOX oComboBox2 VAR valor10 ITEMS aCbx SIZE 040, 010 OF telaimp
	@ 09,08 MSGET campoG VAR valor7 SIZE 20,10 OF telaimp picture '@E 99'
	//@ 09,08 MSCOMBOBOX oComboBo2 VAR valor9 ITEMS campoH SIZE 040, 010 OF telaimp

	@ 135,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 135,90 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()
	campoA:bLostFocus := {|| dti19prc() }
	oComboBox2:bLostFocus := {|| validacombox() }

	oComboBo1:disable()
	oComboBo1:hide()

	campoI:disable()
	campoI:hide()

	ACTIVATE MSDIALOG telaimp CENTERED

return

Static Function valGrupo(_prod)

	local _cGrupo 	:= ''

	if empty(_prod)
		dti19clear()
		return .t.
	endif

	if _prod $ _ProdRes
		oComboBo1:enable()
		oComboBo1:show()
		valor6 := space(10)
		telaimp:refresh()
	else
		oComboBo1:disable()
		oComboBo1:hide()
		valor6 := space(10)
		telaimp:refresh()
	endif

	if _prod $ _PrdQtCx
		campoG:enable()
		campoG:show()
		valor7 := 0
		telaimp:refresh()
	else
		campoG:disable()
		campoG:hide()
		valor7 := 0
		telaimp:refresh()
	endif

	_cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxFilial('SB1') + alltrim(_prod),1)

	/*relação dos grupos de miudos*/
	if (_cGrupo $ _cProdMDS)//se entrar aqui é pq o produto é de miudos e não pode ser impressa a etiqueta
		alert('Produto não corresponde ao grupo de produtos de desossa. Verifique se está utilizando a rotina correta ou entre em contato com PCP!')
		dti19clear()
		return .f.
	endif

return .t.

Static Function Imprime()
	_status := GetMV('SI_IMPPETQ')
	
	if !empty(_status)
		alert('Rotina já sendo utilizada pela estação: ' + _status)
		return .f.
	else		
		if (!empty(valor1) .and. !empty(valor3) .and. !empty(valor5))
			PUTMV('SI_IMPPETQ',GetComputerName())
			Processa({||dti19etq() },"IMPRESSAO DE PRE-ETIQUETA","Realizando envio à impressora...")
			PUTMV('SI_IMPPETQ','')		
		else
			MsgInfo("Campos não preenchidos", "AVISO")
		endif
	endif
return

static function dti19prc()

	SB1->(dbsetorder(1))
	if SB1->(dbseek(FWxfilial('SB1')+valor1))
		valor2 := SB1->B1_DESCRED
	else
		alert('Produto inexistente!')
	endif

	if valor1 $ _ProdRes
		oComboBo1:enable()
		oComboBo1:show()
		valor6 := space(10)
		telaimp:refresh()
	else
		oComboBo1:disable()
		oComboBo1:hide()
		valor6 := space(10)
		telaimp:refresh()
	endif

	if valor1 $ _PrdQtCx
		campoG:enable()
		campoG:show()
		valor7 := 0
		telaimp:refresh()
	else
		campoG:disable()
		campoG:hide()
		valor7 := 0
		telaimp:refresh()
	endif

	telaimp:refresh()
return

static function dti19clear()
	valor1   := Space(06)
	valor2   := Space(40)
	valor5	 := STOD('')
	valor3   := 0
	telaimp:refresh()
return

static Function dti19etq()

	Local   _nSeq   := 0
	Local  _despor  := ''
	Local  _descod  := ''
	Local  _Data    := ''
	Local  _nSeqAl2	:= ''
	Local i

	campoA:disable()
	campoC:disable()
	btn1:disable()
	telaimp:refresh()

	if empty(valor2)
		return .f.
	endif
	/*
	valor2 		- DT Produção - Valor digitado pelo usuário - mas com validação - ( Data do abate - )
	alltrim(valor3) - Descrição do corte - ZZ7_CORTE
	valor8		- Data de Embalagem - Valor digitado pelo usuário - mas com validação  (data de hoje - date())
	valor1		- Codigo do Produto - Vem da ZZ7_CODPRO
	*/
	//alert('Passou pelas regras de validação Linha 250 - > IP '+_cIp)
	//return .t.

	/* Valeska não utiliza e pediu para desabilitar - Dia 04/11/22*/
	//U_QtPrv9(alltrim(valor2),_dDthoje,valor1,valor5)
	_cCadasM := GetAdvFVal('SB1','B1_CADMERC',FWXFilial('SB1')+AllTrim(valor1),1)
	IF (_cCadasM <> "U")
		U_QtPrv9(alltrim(valor2),_dDthoje,valor1,valor5)
	ENDIF
	
	ProcRegua(valor3)
	DbSelectArea('SB1')
	SB1->(dbsetorder(1))

	IF SB1->(dbseek(FWxfilial('SB1')+alltrim(valor1)))
		
		for i := 1 to valor3

			if empty(valor2)
				exit
			endif

			incproc()

			_cEst := getComputerName()
			_cIp  := ''

			dbselectarea('ZAM')
			ZAM->(dbSetOrder(2))
			if ZAM->(dbSeek(FWxFilial('ZAM') + alltrim(_cEst)))
				_cIp := alltrim(ZAM->ZAM_IP)
			endif

			//se não achou o ip na tabela imprime pela porta paralela
			if empty(_cIp)
				MSCBPRINTER('S600','LPT1')
			else
				MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
			endif

			MSCBCHKSTATUS(.f.)
			MSCBBEGIN(1,4,50)
			_despor     :=  alltrim(SB1->B1_DESCRED)
			_descod     :=  alltrim(SB1->B1_COD)
			_Data       :=  DTOC(ddatabase)			
			_nQtCx		:= valor7
			fDesc   		:=  "38,40"
			fDesc1  		:=  "55,23"
			fDesc2  		:=  "60,33"
			fDesc2_1		:=  "50,33"
			fDesc3 			:=  "31,31"
			fDesc3_1 		:=  "20,25"
			fDesc4  		:=  "35,40"

			_nCont      :=  0
			_nX         :=  7
			_nX2        :=  5

			while  _nCont < 2

				if _nCont <> 0
					_nX += 53
					_nX2 += 52

				endif

				if  _nCont == 0
					_nX  := 3
					_nX2 := 6
				endif

				if  _nCont == 1
					_nX  := _nX+3
					
				endif

				_nSeq := GetSx8num('ZZR','ZZR_NUM')
				ConfirmSX8()

				_cCod   :=  substr(_descod,1,06)
				/* Ajuste para que na pré-etiqueta inclua um caracter a mais para novo projeto da Embalagem*/

				_cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxFilial('SB1') + alltrim(_cCod),1)
				_cTipo  := GetAdvFval('SB1','B1_TIPO',FWxFilial('SB1') + alltrim(_cCod),1)
				_cFarm  := GetAdvFval('SBM','BM_FARM',FWxFilial('SBM') + alltrim(_cGrupo),1)
				_cFamRX := GetAdvFval('SB1','B1_FAMRX',FWxFilial('SB1') + alltrim(_cCod),1)

				if _cCod $ _ProdRes .and. valor6 == 'Congelados' //controla se um produto Resfriado deve ser impresso com o codigo para os congelados
					_cTP := '01'
					// Verifica se Tipo for congelados ou se produto deve sair como congelados
					// E diferente de _cFarm = 'S'
				ElseIf _cFarm = 'C' .or. (_cTipo = 'PP' .and. _cFarm != 'S' )
					// Se congelados ou porcionados
					_cTP := '01'
				Elseif _cFarm = 'R'
					// Se Resfriados
					_cTP := '02'
				else 
					/* falar para PCP verificar campo B1_GRUPO que deve estar sem ser preenchido,
					pois quando sistema vai burcar campo BM_FARM não acha.
					*/
					_cTP := '99'
				Endif

				If _cCod $ _PrdQtCx
					MSCBSAY(_nX+25,7,"Pecas: ","N","0",fDesc3_1)
					MSCBSAY(_nX+34,3,alltrim(str(_nQtCx)),"N","0",fDesc2)
				EndIf

				if !empty(alltrim(_cFamRX))
					_nSeqAl2 := alltrim(_cTP)+alltrim(_cFamRX)+substr(_nSeq,4,11)
					_nSeqAlt := alltrim(_cTP)+alltrim(_nSeq)
				Else
					_nSeqAlt := alltrim(_cTP)+alltrim(_nSeq)
				Endif
				if _nCont == 1
					MSCBSAY(_nX-1,2,substr(_despor,1,18),"N","0",fDesc)
				else
					MSCBSAY(_nX-3,2,substr(_despor,1,18),"N","0",fDesc)
				Endif

				MSCBSAY(_nX,7,"Data Base: " + _Data,"N","0",fDesc3_1)
				// Dia 19/04/23 - Bruna pediu para mostrar a data de Produção (igual da entiqueta interna)
				//MSCBSAY(_nX+43,11,"DV "+dtoc(valor5),"B","0",fDesc3)//fonteDesc3)
				if _cCodUser != "000476"
					MSCBSAY(_nX+43,11,"DV "+dtoc(valor5),"B","0",fDesc3)//fonteDesc3)
				endif

				if (_cCodUser = '000476')
					MSCBSAY(_nX+41,10,"Dta Abate "+dtoc(valor11),"B","0",fDesc3)
				endif

				if _nCont == 1
					/* Lado direito*/
					IF !empty(alltrim(_cFamRX))						 
						MSCBSAYBAR(_nX2+10,10,alltrim(_nSeqAl2),"N","C",29,.F.,.F., ,  ,2,08,.T.)					
					else
						MSCBSAYBAR(_nX2+10,10,alltrim(_nSeqAlt),"N","C",29,.F.,.F., ,  ,2,08,.T.)
					Endif

				else

					/* Lado Esquerdo*/
					IF !empty(alltrim(_cFamRX))
						MSCBSAYBAR(_nX2-18,10,alltrim(_nSeqAl2),"N","C",29,.F.,.F.,,,2,08,.T.)
					else
						MSCBSAYBAR(_nX2-18,10,alltrim(_nSeqAlt),"N","C",29,.F.,.F.,,,2,08,.T.)
					Endif

				endif

				IF !empty(alltrim(_cFamRX))
					MSCBSAY(_nX-1,40,alltrim(_cCod)+"-"+alltrim(_nSeqAl2),"N","0",fDesc2_1)
				else
					MSCBSAY(_nX-1,40,alltrim(_cCod)+"-"+alltrim(_nSeqAlt),"N","0",fDesc2_1)
				ENDIF

				_nCont++

				reclock('ZZR',.t.)
				ZZR->ZZR_FILIAL := FWxFilial('ZZR')
				ZZR->ZZR_NUM 	:= _nSeqAlt
				ZZR->ZZR_COD 	:= _descod				
				ZZR->ZZR_UTIL   := 'N'
				ZZR->ZZR_DTIMP  := date()
				ZZR->ZZR_QTDCX  := _nQtCx
				ZZR->ZZR_DTDEV  := valor5
				ZZR->ZZR_DTABT  := valor11
				if !empty(campoI)
					ZZR->ZZR_DTPROD  := valor4
				endIf
				IF GetMV('SI_REJEMB') = .T.
					ZZR->ZZR_REJ    := .T.
				ELSE
					ZZR->ZZR_REJ    := .F.
				ENDIF
				msunlock()
			enddo

			/*
			cRotação  = String com o tipo de Rotação (N,R,I,B)
			N-Normal
			R-Cima p/baixo
			I-Invertido
			B-Baixo p/ Cima
			*/

			MSCBEND()
			MSCBCLOSEPRINTER()

			if mod(i,10) = 0
				sleep(1500)
			endif
		next

		dti19clear()

		msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

		_nSeq := 0
		campoA:enable()
		campoC:enable()
		btn1:enable()
		telaimp:refresh()

	endif

return


User Function  QtPrv9(_cDescri,_dDataEmb,_cCodP,_DtDev)
	LOCAL _nCont := 0
	LOCAL _nCont2 := 0
	LOCAL _nNvinc := 0
	LOCAL _nMark := 'N'
	IF !empty(_DtDev)
		// Se tem data de devolução
		_cQuery := " SELECT ZU_NUM,ZU_COD,ZU_DTPROD,ZU_DTDEV AS DEVOLUCAO "
		_cQuery += " FROM " + retSqlTab('SZU')
		_cQuery += " WHERE " + retSqlFil('SZU')
		_cQuery += " AND " + retSqlDel('SZU')		
		_cQuery += " AND ZU_DTDEV = '" + dtos(_DtDev) + "' "
		_cQuery += " AND ZU_DTABT = '" + dtos(valor11) + "' "
		_cQuery += " AND ZU_COD = '" + alltrim(_cCodP) + "' "	

		_cQuery  := ChangeQuery(_cQuery)
	else
		_cQuery := " SELECT ZU_NUM,ZU_COD,ZU_DTPROD,ZU_DTDEV AS DEVOLUCAO "
		_cQuery += " FROM " + retSqlTab('SZU')
		_cQuery += " WHERE " + retSqlFil('SZU')
		_cQuery += " AND " + retSqlDel('SZU')
		_cQuery += " AND ZU_DTPROD = '" + dtos(_dDataEmb) + "' "
		_cQuery += " AND ZU_ETIQ <> 'PO' "	
		_cQuery += " AND ZU_COD = '" + alltrim(_cCodP) + "' "	

		_cQuery  := ChangeQuery(_cQuery)
	endif

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"	

	SZ2->(DbGoTop()) 
	SZ2->(dbSetOrder(2))

	TMP->(dbGoTop())		
	While TMP->(!EOF())
			// Se prev embalagem  não tiver prev desossa vinculada cai aqui
			//alert('Prev. da Enbalagem não vinculada com Prev. da Desossa  !! Enviado e-mail para o PCP')					
			_nCont2++
			_nNvinc++
		_nCont++
		TMP->(dbSkip())
	Enddo

	// caso não tenha previsão
	If _nMark = 'N'
		If _nCont = 0 .AND. _nCont2 = 0
			//alert('Produto não possui previsão de Embalagem Lançada !! Enviado e-mail para o PCP')
			_nNvinc:= 999
			// Criando Previsão de Produção da Embalagem
			gjf41wfw(_cCodP,_nNvinc,_cDescri,_dDataEmb,_DtDev)
		elseif _nCont > 0
		 	// caso não tenha previsão correta ,  descrever no e-mail situações visualizadas
			//alert(_nCont)
			//alert(_nCont2)
			if _nCont =_nCont2		 				
	 			//alert('Data do Abate diferente da Data lançada na produção das Etiqueta Internas ')	 			
				gjf41wfw(_cCodP,_nNvinc,_cDescri,_dDataEmb,_DtDev)
			Endif
		Endif
	else
		//alert('761 Tem uma Previsão que esta correta!! ') Então não vai workflow
	Endif

return

Static Function gjf41wfw(_nProd,_nNvinc,_cDes,_dDtEmb,_DtDv)
	Local _cOper   := UsrRetName(retcodusr())
	Local _cMens := ''
	Local _cAtivaR := GetMV('SI_LIBR88')

	_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)

	//Produto não tem previsão de produção da embalagem lançada, então criando
	//Previsão de Produção da Embalagem 
	If  _nNvinc = 999
		IF _cAtivaR = '1'					
			U_DTI19PPE(1,_nProd,_dDtEmb,_DtDv,_cOper)
		Endif			
		//_cMens += 'O Produto :'+_nProd+' - '+_cDes+' Produto não possui previsão de Embalagem Lançada  !!'+ chr(13) + chr(10)				
	Elseif _nNvinc > 0
		//_cMens += 'O Produto :'+_nProd+' - '+_cDes+' esta com '+cValtoChar(_nNvinc)+' Previsões da Enbalagem NÃO vinculada com Prev. da Desossa   !!'+ chr(13) + chr(10)
	Endif

	//_cMens += 'Na Data do Abate de :'+ dtoc(_dDataABT) + chr(13) + chr(10)
	//_cMens +=   chr(13) + chr(10)
	//_cTit  := 'Workflow Frigorífico Silva: Aviso de Produção na EMBALAGEM/DESOSSA  ' 

return

User function DTI19PPE(_nTip,_cProd,_dDtEmba,_DtDev,_cOper) 
	Local _cCodPEs := GETMV('SI_PETQES')
	Local _nPesom := 0
	Local Ret      := 'PA'
	Local _grp		:= ''
	Local _MPPORC	:= ''
	//Local _cPTF		:= 'N'
	//Local _cCodTF	:= GETMV('SI_TFCOD')  

	/*  	
	Chegando então informações que precisamos para gerar a "Prev. de Produção da Embalagem"
	GJF24 - Prev Produção Embalagem
	DTI41 - Impr.Etiquetas Internas 
	_cProd - produto 
	_dDABT - data da Produção/Abate 
	_dDtEmba - Data da Embalagem		
	*/
	/* Regras de Busca de informações 
	*/   

	If _nTip = 1 .OR. _nTip = 3
		/*
		Primeiro caso (_nTip = 1) - O  Produto não possui previsão de Embalagem Lançada 		
		Segundo Caso (_nTip = 3) - 'O Produto  esta com '+cValtoChar(_nDABT)+' Previsões de  Data do Abate diferente da Data lançada na produção das Etiqueta Internas 
		Aqui acho que devo só vincular as previsões ou refazer uma nova ??? ver com a Valeska
		*/
		_nPesom := pmc(10,alltrim(_cProd))
		_cDesc := GetAdvFval('SB1','B1_DESCRED',FWxFilial('SB1') + alltrim(_cProd),1)
		//_cNumP:= BuscaPDes(_cProd,_cPTF,_cCodTF)
		/*  
		Regra para quando for produto que precisa ser preenchido como exportação
		*/
		if alltrim(_cProd) $ _cCodPEs
			Ret := 'ES'
		endif

		/*  Regra para quando for produto para porcionados	*/
		_grp := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+alltrim(_cProd),1)
		if _grp $ '4006/4007/4008/4009'
			_MPPORC  := 'S'			
		endif

		_cCorori := alltrim(GetAdvFval('SB1','B1_CORORI',FWxFilial('SB1') + alltrim(_cProd),1))

		_cQuery2 := "SELECT Z2_NUM AS NUM"
		_cQuery2 += " FROM " + retSqlTab('SZ2')
		_cQuery2 += " WHERE " + retSqlFil('SZ2')
		_cQuery2 += " AND " + retSqlDel('SZ2')
		_cQuery2 += " AND Z2_DATAABT = '" + dtos(valor11) + "' "	
		_cQuery2 += " AND Z2_CORORI IN " + iif(_cCorori = 'D', "('D')", "('C','T')")
		_cQuery2 += " AND Z2_CLASSIF = 'HK' ORDER BY Z2_NUMAM DESC"

		_cQuery2  := ChangeQuery(_cQuery2)	

		If Select("TMP2") != 0
			TMP2->(dbCloseArea())
		Endif

		TCQUERY _cQuery2 NEW ALIAS "TMP2"
		TMP2->(dbGoTop())

		_predes := TMP2->NUM

		_cNumer := GETSX8NUM('SZU','ZU_NUM')
		ConfirmSX8()
		RecLock("SZU",.T.)
			SZU->ZU_FILIAL	:= FWxFilial("SZU")
			SZU->ZU_NUM		:= _cNumer
			SZU->ZU_DATA	:= ddatabase
			SZU->ZU_COD		:= alltrim(_cProd)
			SZU->ZU_DESC 	:= _cDesc
			SZU->ZU_PRIORI 	:= 'C'	
			SZU->ZU_CONTEXA := 'N'	
			SZU->ZU_DTRPRO 	:= ddatabase
			SZU->ZU_DTPROD 	:= valor4
			SZU->ZU_DTDEV 	:= _DtDev
			SZU->ZU_NOTIMP 	:= 'A'
			SZU->ZU_MDESP	:= 'N'
			SZU->ZU_NUMETQ	:= 1
			SZU->ZU_HORA	:= Time()
			SZU->ZU_USUAR	:= 'S_'+_cOper
			SZU->ZU_QPETIQ	:= 30
			SZU->ZU_LISTETQ	:= 'S'
			SZU->ZU_FECHADO := 'B'
			SZU->ZU_TIPO 	:= 'P'
			SZU->ZU_QPCAIX 	:= 10
			SZU->ZU_TOLERA 	:= 10
			SZU->ZU_MPPORC  := _MPPORC
			SZU->ZU_ETIQ 	:= Ret
			SZU->ZU_REPAUT	:= 'S'
			SZU->ZU_QPPESO 	:= _nPesom
			SZU->ZU_DTABT   := valor11
			SZU->ZU_PREDES  := _predes
		MsUnLock()
	Elseif _nTip =2 
	Endif	

return

//função para calcular o peso medio por caixa e o peso medio a produzir
Static function pmc(caixas,Codigo)

	if !empty(caixas) .and. !empty(Codigo)
		pmc    := GetAdvFval('SB1','B1_PMCAIX',FWxfilial('SB1')+Codigo,1)
		pmedio := (caixas * pmc)
		return pmedio
	endif
return 0

//Static Function BuscaPDes(_dA,_pro,_Stf,_cTF)
Static Function BuscaPDes(_pro,_Stf,_cTF)

	Local _cN  := ''
	Local _cN2 := ''
	Local _cN3 := '' 
	Local _nCont := 0
	Local _nCont2 := 0
	
	/*
	_dA = Data do Abate
	_pro - Código do Produto que esta sendo impresso
	_Stf = Situação da identificação de TF 
	_cTF = Códigos de produtos identificados como TF que o PCP denomina 
	*/
	If alltrim(_pro) $ alltrim(_cTF)
		_Stf := 'S'
	Endif

	SZ2->(DbGoTop()) 
	SZ2->(dbSetOrder(10))

	/* Se previsão for TF então sistema só busca  previsões comclassificação NE*/
	IF _Stf = 'S'
		//if !empty(SZ2->(dbSeek(FWxFilial('SZ2') + DTOS(_dA))))
		if !empty(SZ2->(dbSeek(FWxFilial('SZ2') + alltrim(_pro))))
			//While SZ2->(!EOF()) .AND.  SZ2->Z2_DATAABT = _dA
			While SZ2->(!EOF())	
				if AllTrim(SZ2->Z2_CLASSIF) = 'NE'
					//alert(_cN3)
					_cN3 :=  SZ2->Z2_NUM	
					//alert(_cN3)
					_cN3 := _cN3+_Stf	
					//alert(_cN3)			
					_nCont++
					Exit
				endif

				SZ2->(dbSkip())
			Enddo
		Endif
	Else		
		// Caso a previsão não esteja marcada como TF então busca aqui	
		//if !empty(SZ2->(dbSeek(FWxFilial('SZ2') + DTOS(_dA))))
		if !empty(SZ2->(dbSeek(FWxFilial('SZ2') + alltrim(_pro))))
			//While SZ2->(!EOF()) .AND.  SZ2->Z2_DATAABT = _dA
			While SZ2->(!EOF())
				if AllTrim(SZ2->Z2_CLASSIF) = 'HK' .AND.  SZ2->Z2_CLASESP = 'S'
					/*  Se tiver previsão que for HK e Classificação especial  */
					_cN :=  SZ2->Z2_NUM
					_nCont++
					Exit
				else
					/*  Se tiver qualquer Previsão da Desossa */			
					_cN2 :=  SZ2->Z2_NUM
					_nCont2++
				Endif			
				SZ2->(dbSkip())
			Enddo

			If _nCont >0 	
				_cN3 := _cN
				_cN3 := _cN3+_Stf
			elseif _nCont2 >0
				_cN3 := _cN2
				_cN3 := _cN3+_Stf
			endif
		Else 
			//alert('Sem Previsão da Desossa Lançada para esta data de Abate, Entrar em contato com PCP !!')
		Endif
	Endif

Return alltrim(_cN3)

Static function regra(_data)

	_dDTMaior := date()
	_dDTMenor := date() - 30

	if empty(_data)
		//MsgAlert('Favor preencher campo da Data de Abate !! ', 'PREENCHIMENTO PROIBIDA !!')	
		MsgAlert('Favor preencher campo da Data de Produção !! ', 'PREENCHIMENTO PROIBIDA !!')	
		return .f.
	endif
	/* Devemos cadastrar o usuário somente em um dos  parâmetros, ou no SI_USRETQ ou no SI_ETQPRC*/
	if alltrim(_cCodUser) $ _cUsrEtq
		/* Regra para campo - Data Abate - Parametro SI_USRETQ */
		regraa(_data)
	Elseif alltrim(_cCodUser) $ _cUsrPorc
		/* Regra para campo - Data Abate - Parametro SI_ETQPRC - Porcionados */
		regrac(_data)
	Elseif alltrim(_cCodUser) $ _cUsrLib
		/* Regra para campo - Data Abate - Parametro SI_PETQLIB */
		regrad(_data)
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
			campoE:SETFOCUS()
			return .f.
		endif
	else
		MsgAlert('2 - Data do Abate Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
		campoE:SETFOCUS()
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
			campoE:SETFOCUS()
			return .f.
		endif
	else
		MsgAlert('2 - Data do Abate Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
		campoE:SETFOCUS()
		return .f.
	endif

return

//Lucas
Static Function regrad(_data1)

	_dDTMaior := date() - 1
	_dDTMenor := date() - 9999

	if _data1 = _dDTMaior
		return .t.
	elseif _data1 <= _dDTMaior
		if _data1 >= _dDTMenor
			return .t.
		else
			MsgAlert('1 - Data do Abate Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
			campoE:SETFOCUS()
			return .f.
		endif
	else
		MsgAlert('2 - Data do Abate Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')	
		campoE:SETFOCUS()
		return .f.
	endif
Return
//FIM LUCAS

Static function regrab(_dVlr8)

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

Static function validacombox()
	IF valor10 = 'Não'
		campoI:disable()
		campoI:hide()		
	ELSEIF valor10 = 'Sim'
		campoI:enable()
		campoI:show()
	ELSE
		alert('nenhuma das 2')
	ENDIF
Return

// Validação da data de abate. Data deve coincidir com alguma data de abate ou carregamento de terceiros e no máximo 14 dias no passado
STATIC FUNCTION DTABT()

	_dDtAb := GetAdvFval('SZG','ZG_DATA',FWxFilial('SZG') + DTOS(valor11),2)
	_dDtAb2 := GetAdvFval('ZAP','ZAP_DATAP',FWxFilial('ZAP') + DTOS(valor11),4)
	IF (_dDtAb = DDATABASE .and. !(GetAdvFval('SB1','B1_GRUPO',FWxFilial('SB1') + valor1,1) $ _cProdMDS))
		FWAlertError('A data de abate informada não pode ser a data do dia atual  ', 'DATA DE ABATE ERRADA !!')
		campoJ:setFocus()
		return .f.
	ENDIF

	IF empty(_dDtAb) .and. empty(_dDtAb2)
		FWAlertError('Não teve abate neste Dia  !! Colocar outra data de abate!!!  ', 'DATA DE ABATE ERRADA !!')
		campoJ:setFocus()
		return .f.
	elseif valor11 < (ddatabase-15) .and. !(_cCodUser $ "000883/000476")
		FWAlertError('Data de abate muito antiga!! (Mais de 15 dias antes da data atual) ', 'ENTRAR EM CONTATO COM PCP!!')
		campoJ:setFocus()
		return .F.
	else
		return .T.
	endif

RETURN
