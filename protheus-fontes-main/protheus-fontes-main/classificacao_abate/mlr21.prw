#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR21     ºAutor  ³Mauricio Roehrs º Data ³  20/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para apontamento dos PH's das carcaças              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MLR21()

	Local _cPerg      := "MLR21"
	Private aTela     := {}
	Private aStru     := {}
	Private aCampos   := {}
	Private aMarcas   := {}
	Private _cMarca   := space(3)
	Private cArq
	Private	_cEspNew  := ''
	Private	_cClasAnt := ''
	Private	_cClasNew := ''

	if !pergunte(_cPerg,.t.)
		return
	endif

	_nQuantAbt := GetAdvFval('SZG','ZG_QTDTOT',FwxFilial('SZG') + mv_par01,1,0,.T.)

	Processa({||montabrow(mv_par01)} ,"PROCESSAMENTO DE REGISTROS","montando tela de manutenção de Ph...")

	DbSelectArea('TMP')

	DEFINE MSDIALOG oDlg TITLE 'Análise e Controle de PH' from 0,0 To 400,800 OF oMainWnd PIXEL //To 290,620

	@ 010,005 To 170,400 Browse "TMP" fields aCampos object oBrow

	oBrow:oBrowse:bldBlClick :=  {|| AltPh()}

	@180,140 BUTTON btn01 PROMPT "Salvar" 			OF oDlg  SIZE 40,15 PIXEL ACTION GravPh()
	@180,220 BUTTON btn02 PROMPT "Reclassificar" 	OF oDlg  SIZE 40,15 PIXEL ACTION ReclasPh()
	@180,300 BUTTON btn03 PROMPT "Sair" 			OF oDlg  SIZE 40,15 PIXEL ACTION oDlg:end()

	ACTIVATE MSDIALOG oDlg CENTERED

	TMP->(DbCloseArea())

Return


Static Function montabrow(_cNumam)

	//cArq  := CriaTrab( Nil, .F. )
	_aArqTrb := {}

	aadd(aCampos,{"NUMAM" 		,"Aviso de Matanca"  ,""})
	aadd(aCampos,{"CONTROL"   	,"Sequencial"		 ,""})
	aadd(aCampos,{"PHE"  		,"PH Lado Esquerdo"  ,""})
	aadd(aCampos,{"PHD"  		,"PH Lado Direito"   ,""})
	aadd(aCampos,{"CLASANT"  	,"Classif. Anterior" ,""})
	aadd(aCampos,{"CLASNEW"  	,"Classif. Nova"     ,""})
	aadd(aCampos,{"CLASESP" 	,"Class Esp"	     ,""})
	//aadd(aCampos,{"CLASESPNEW" 	,"Class Esp Nova"    ,""})

	aadd(aStru,{"NUMAM"  	 , "C",  08,  0,   "@!"  , 'Aviso de Matanca  	 '})
	aadd(aStru,{"CONTROL"    , "C",  06,  0,   "@!"  , 'Sequencial			 '})
	aadd(aStru,{"PHE" 		 , "N",  06, 02,   "@!"  , 'PH Lado Esquerdo 	 '})
	aadd(aStru,{"PHD"   	 , "N",  06, 02,   "@!"  , 'PH Lado Direito   	 '})
	aadd(aStru,{"CLASANT"    , "C",  03,  0,   "@!"  , 'Classif. Anterior 	 '})
	aadd(aStru,{"CLASNEW"    , "C",  03,  0,   "@!"  , 'Classif. Nova  		 '})
	aadd(aStru,{"CLASESP" 	 , "C",  01,  0,   "@!"  , 'Class Esp			 '})
	aadd(aStru,{"CLESPAB"    , "C",  01,  0,   "@!"  , 'Class Esp Abate 	 '})

	//dbcreate(cArq,aStru)
	//If Select("TMP") != 0
	//	TMP->(DbCloseArea())
	//endif
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	//TMP->(DbGotop())

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	SZK->(DbSetOrder(4))
	SZK->(DbGoTop())
	if SZK->(MsSeek(Fwxfilial('SZK') + _cNumam))

		ProcRegua(_nQuantAbt)

		While SZK->(!eof()) .and. SZK->ZK_FILIAL = Fwxfilial('SZK') .and. SZK->ZK_NUMAM = _cNumam
			IncProc('Processando dados da carcaça n.º: ' + SZK->ZK_CONTROL)

			_cClasAnt   := GetAdvFval('SZL','ZL_CLASANT',FwxFilial('SZL')+SZK->(ZK_NUMAM + ZK_CONTROL)+'D',1,SZK->ZK_CLASSIF,.T.)

			DbSelectArea('TMP')
			reclock('TMP',.t.)
			TMP->NUMAM   	:= SZK->ZK_NUMAM
			TMP->CONTROL	:= SZK->ZK_CONTROL
			TMP->PHD  		:= GetAdvFval('SZL','ZL_PH',FwxFilial('SZL')+SZK->(ZK_NUMAM + ZK_CONTROL)+'D',1,0.0,.T.)
			TMP->PHE    	:= GetAdvFval('SZL','ZL_PH',FwxFilial('SZL')+SZK->(ZK_NUMAM + ZK_CONTROL)+'E',1,0.0,.T.)
			TMP->CLASANT    := alltrim(iif(empty(_cClasAnt),SZK->ZK_CLASSIF,_cClasAnt))
			TMP->CLASNEW    := GetAdvFval('SZL','ZL_CLASNEW',FwxFilial('SZL')+SZK->(ZK_NUMAM + ZK_CONTROL),1,SZK->ZK_CLASSIF,.T.)
			TMP->CLESPAB    := SZK->ZK_CLESPAB
			TMP->CLASESP 	:= SZK->ZK_CLASESP
			//TMP->CLASESPNEW := SZK->ZK_CLASESP
			msunlock()

			SZK->(DbSkip())
		enddo
	endif

	TMP->(DbGoTop())

return

//Função que chama a telinha de alteração de marca
Static Function AltPh()
	Local _PhD    := 0.00
	Local _Campo1 := 0.00
	Local _PhE    := 0.00
	Local _Campo2 := 0.00
	Local _Campo3 := space(6)
	Private _cSeq   := TMP->CONTROL

	DEFINE MSDIALOG oDlg2 TITLE 'Valores de PH' from 000,000 To 150,200 OF oMainWnd PIXEL

	@ 015,002 SAY  'Sequencial' Object oSay1
	@ 001,005 MSGET _Campo3 VAR _cSeq SIZE 35,11 VALID Completa() OF oDlg2

	@ 030,002 SAY  'PH Direito' Object oSay2
	@ 002,005 MSGET _Campo1 VAR _PHD SIZE 35,11  PICTURE "@E 99.99"  OF oDlg2

	@ 045,002 SAY  'PH Esquerdo' Object oSay3
	@ 003,005 MSGET _Campo2 VAR _PHE SIZE 35,11  PICTURE "@E 99.99"  OF oDlg2

	@ 060,008 BMPBUTTON TYPE 1 ACTION CnfPh(_PHD,_PHE) Object Obtn1
	@ 060,040 BMPBUTTON TYPE 3 ACTION DesPh(_PHD,_PHE) Object Obtn2
	@ 060,073 BMPBUTTON TYPE 2 ACTION oDlg2:end() Object Obtn3

	ACTIVATE MSDIALOG oDlg2 CENTERED

return

//Função que confirma a inserção do ph
Static Function CnfPh(_PHD,_PHE)

	if  (_PhD < 0.00 .or. _PhD > 14) .or. (_PhE < 0.00 .or. _PhE > 14)
		FWAlertError('Valores de Ph Inválidos!', 'ERRO')
		return .f.
	endif

	TMP->(DbGoTop())
	while TMP->(!eof())
		if _cSeq = TMP->CONTROL
			//_cClasEsp  := GetAdvFval('SZK',4,FwxFilial('SZK') + TMP->NUMAM + TMP->CONTROL,'ZK_CLASESP')
			_cClasEsp  := TMP->CLASESP
			_cEspNew   := TMP->CLASESP

			_cClasAnt  := TMP->CLASANT
			_cClasNew  := TMP->CLASANT

			if _cClasAnt $ 'USA/RT'
				if _PHD >= 5.98 .or. _PHE >= 5.98
					_cClasNew := 'HK'
				else
					if _cClasAnt = 'USA'
						_cClasNew := 'USA'
					else
						_cClasNew := 'RT'
					endif
				endif
			endif

			/*if AllTrim(_cClasAnt) <> 'NE'
				if _cClasEsp <> '1'//se NÃO for classificação especial
					if _PhD >= 6.4 .or. _PhE >= 6.4
						if AllTrim(_cClasAnt) <> 'HK'
							_cClasNew := 'HK'
						else
							_cClasNew := 'NE'
						endif
					else
						_cClasNew := _cClasAnt
					endif
				else //senão será classificação especial
					//if (_PhD >= 6 .and. _PhD < 6.4) .or. (_PhE >= 6 .and. _PhE < 6.4)//se entrar aqui somente deixa de ser classificação especial
					if (_PhD >= 5.97 .and. _PhD < 6.4) .or. (_PhE >= 5.97 .and. _PhE < 6.4)
						_cEspNew  := '2'
						_cClasNew := _cClasAnt
					elseif _PhD >= 6.4 .or. _PhE >= 6.4//senão se entrar aqui, deixa de ser clasesp e se torna NE
						_cClasNew := 'NE'
						_cEspNew  := '2'
					else
						_cClasNew := _cClasAnt
					endif
				endif
			else
				_cClasNew := _cClasAnt
				_cEspNew  := '2'
			endif*/

			reclock('TMP',.f.)
			TMP->CLASNEW    := _cClasNew
			TMP->PHD        := _PHD
			TMP->PHE        := _PHE
			TMP->CLASESP    := _cEspNew
			msunlock()
			exit
		else
			TMP->(DbSkip())
		endif

	enddo
	//comentando aqui por segurança
	//iif(TMP->CLASANT <> 'NE',iif(_PHD >=6 .or. _PHE >= 6,iif(TMP->CLASANT <> 'HK','HK','NE'),TMP->CLASANT),TMP->CLASANT)//modificado por solicitação da Russaica
	oBrow:oBrowse:refresh()
	oDlg:refresh()
	odlg2:end()
return .t.


Static Function DesPh(_PHD,_PHE)

	reclock('TMP',.f.)
	TMP->CLASNEW 	:= TMP->CLASANT
	TMP->PHD     	:= 0.0
	TMP->PHE     	:= 0.0
	TMP->CLASESP    := TMP->CLESPAB
	msunlock()

	oBrow:oBrowse:refresh()
	oDlg:refresh()
	odlg2:end()
return  .t.


Static Function Completa()

	if !empty(_cSeq)
		_cSeq  := padl(alltrim(_cSeq),6,'0')
	endif

	oDlg2:refresh()
return .t.


Static Function GravPh()
	Processa({||Gravar()} ,"PROCESSAMENTO DE REGISTROS","Efetivando a gravação da digitação do Ph...")
return


Static Function Gravar()

	Local i
	Local j
	TMP->(DbGoTop())

	ProcRegua(_nQuantAbt)

	while TMP->(!eof())

		incproc('Processando registro de carcaça ' + TMP->CONTROL)

		SZL->(DbSetOrder(1))
		if SZL->(MsSeek(Fwxfilial('SZL')+TMP->(NUMAM+CONTROL)))
			if TMP->PHD > 0.0 .and. TMP->PHE > 0.0
				for i:= 1 to 2
					if  SZL->(MsSeek(Fwxfilial('SZL')+TMP->(NUMAM+CONTROL) + iif(i = 1,'D','E') ))
						reclock('SZL',.f.)
						SZL->ZL_PH      := iif(i = 1,TMP->PHD,TMP->PHE)
						SZL->ZL_SEQPH   := iif(i = 1,'D','E')
						SZL->ZL_CLASNEW := TMP->CLASNEW
						msunlock()
					endif
				next
			endif
		else
			if TMP->PHD > 0.0 .and. TMP->PHE > 0.0
				for j:= 1 to 2
					reclock('SZL',.t.)
					SZL->ZL_FILIAL  := Fwxfilial('SZL')
					SZL->ZL_NUMAM   := TMP->NUMAM
					SZL->ZL_SEQUEN  := TMP->CONTROL
					SZL->ZL_PH      := iif(j = 1,TMP->PHD,TMP->PHE)
					SZL->ZL_SEQPH   := iif(j = 1,'D','E')
					SZL->ZL_CLASANT := TMP->CLASANT
					SZL->ZL_CLASNEW := TMP->CLASNEW
					msunlock()
				next
			endif
		endif

		SZK->(dbSetOrder(4))
		SZK->(dbGoTop())
		if SZK->(MsSeek(FwxFilial('SZK') + TMP->NUMAM + TMP->CONTROL))
			_cClass := SZK->ZK_CLASSIF
			reclock('SZK',.f.)		
			SZK->ZK_CLASESP := TMP->CLASESP
			SZK->ZK_CLASSPH := iif(!empty(SZL->ZL_CLASNEW),SZL->ZL_CLASNEW,_cClass)//_cClasNew		
			msunlock()	
		endif

		TMP->(DbSkip())
	enddo
	TMP->(DbGoTop())

	FWAlertSuccess('Apontamentos do PH Salvos com Sucesso!!', 'SUCESSO')
return


Static Function ReclasPh()
	Processa({||RecPH()} ,"PROCESSAMENTO DE REGISTROS","Efetivando a gravação da digitação do Ph...")
	u_dtilog(cFilAnt, "MLR21", "Reclassificação manual do abate " + alltrim(mv_par01), "R")
return


Static Function RecPH()
	local _lReclass := .f.
	local _aPredesA := {}	// Previsão anterior
	local _aPredesP := {}	// Previsão posterior
	local _nQppeca := 0
	local _nQppeso := 0
	local i := 0
	local nPos := 0
	local lSOP := .F.

	ProcRegua(_nQuantAbt)

	SZ2->(DbSetOrder(2))
	ZAJ->(DbSetOrder(1))
	SZL->(DbSetOrder(1))
	SZL->(DbGoTop())
	SZK->(DbSetOrder(4))
	SZK->(DbGoTop())
	SZK->(MsSeek(FwxFilial('SZK') + mv_par01))

	while SZK->(!eof()) .and. SZK->ZK_FILIAL = FwxFilial('SZK') .and. SZK->ZK_NUMAM = mv_par01
		//flag para verificar se houve reclassificação
		_lReclass := .f.

		incproc('Processando registro de carcaça ' + SZK->ZK_CONTROL)

		_cClass := SZK->ZK_CLASSIF

		if SZL->(MsSeek(FwxFilial('SZL') + SZK->(ZK_NUMAM + ZK_CONTROL)))
			if SZL->ZL_CLASNEW <> _cClass
				reclock('SZK',.f.)
				SZK->ZK_CLASSIF := SZL->ZL_CLASNEW
				msunlock()
				_lReclass := .T.
			endif
		endif

		if _lReclass

			if ZAJ->(MsSeek(FwxFilial('ZAJ') + SZK->(ZK_NUMAM + ZK_CONTROL)))

				_aPredesA := {}
				_aPredesP := {}

				while ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = FwxFilial('ZAJ') .and. ZAJ->ZAJ_NUMAM = SZK->ZK_NUMAM .and. ZAJ->ZAJ_CONTRO = SZK->ZK_CONTROL

					if empty(ZAJ->ZAJ_PREDES)
						ZAJ->(DbSkip())
						loop
					endif

					_cClassOP := GetAdvFval('SZ2','Z2_CLASSIF',FWxFilial('SZ2') + ZAJ->ZAJ_PREDES,2)

					nPos := Ascan(_aPredesA, {|x| x[1] = ZAJ->ZAJ_PREDES})
					if nPos = 0 .and. !empty(ZAJ->ZAJ_PREDES)
						aadd(_aPredesA, {ZAJ->ZAJ_PREDES, 1, ZAJ->ZAJ_PESO})
					else
						_aPredesA[nPos,2]++
						_aPredesA[nPos,3] += ZAJ->ZAJ_PESO
					endif

					if GeraOP(SZK->ZK_CLASSPH, SZK->ZK_PROGRAM, ZAJ->ZAJ_COD, SZK->ZK_NUMAM, alltrim(GetAdvFval('SZ2','Z2_OBS',FWxFilial('SZ2') + ZAJ->ZAJ_PREDES,2)), SZK->ZK_BLACK)
						QRY->(dbGoTop())
						reclock('ZAJ',.f.)
						ZAJ->ZAJ_PREDES := QRY->Z2_NUM
						msunlock()

						nPos := Ascan(_aPredesP, {|x| x[1] = QRY->Z2_NUM})
						if nPos = 0 .and. !empty(QRY->Z2_NUM)
							aadd(_aPredesP, {QRY->Z2_NUM, 1, ZAJ->ZAJ_PESO})
						else
							_aPredesP[nPos,2]++
							_aPredesP[nPos,3] += ZAJ->ZAJ_PESO
						endif
					else
						reclock('ZAJ',.f.)
						ZAJ->ZAJ_PREDES := ""
						msunlock()
						lSOP := .T.
					endif

					ZAJ->(DbSkip())
				enddo

				if !empty(_aPredesA)
					for i := 1 to len(_aPredesA)
						if SZ2->(MsSeek(FWxFilial('SZ2') + _aPredesA[i,1]))
							_nQppeca := SZ2->Z2_QPPECA - _aPredesA[i,2]
							_nQppeso := SZ2->Z2_QPPESO - _aPredesA[i,3]
							reclock('SZ2',.f.)
							SZ2->Z2_QPPECA := _nQppeca
							SZ2->Z2_QPPESO := _nQppeso
							msunlock()
						endif
					next
				endif

				if !empty(_aPredesP)
					for i := 1 to len(_aPredesP)
						if SZ2->(MsSeek(FWxFilial('SZ2') + _aPredesP[i,1]))
							_nQppeca := SZ2->Z2_QPPECA + _aPredesP[i,2]
							_nQppeso := SZ2->Z2_QPPESO + _aPredesP[i,3]
							reclock('SZ2',.f.)
							SZ2->Z2_QPPECA := _nQppeca
							SZ2->Z2_QPPESO := _nQppeso
							msunlock()
						endif
					next
				endif
			endif
		endif

		SZK->(DbSkip())
	enddo

	if lSOP
		FWAlertWarning('Algumas carcaças ficaram sem OP para a nova Classificação!','AVISE O PCP!')
	endif

	FWAlertSuccess('Reclassificação Efetivada Com Sucesso!!!', 'SUCESSO')

return

//Função auxiliar
Static Function GeraOP(_classif, _program, _cod, _numam, _obs, _black)

	cQuery := "SELECT Z2_NUM"
	cQuery += " FROM " + RetSqlTab("SZ2")
	cQuery += " WHERE " + RetSqlFil("SZ2")
	cQuery += " AND Z2_NUMAM = '" + _numam + "'"
    cQuery += " AND Z2_COD = '" + _cod + "'"
    if !empty(_obs)
        cQuery += " AND Z2_OBS = '" + alltrim(_obs) + "'"
    else
        cQuery += " AND Z2_CLASSIF = '" + _classif + "'"
        if _black = 'S'
            cQuery += " AND Z2_PROGRAM = '014'"
        else
            cQuery += " AND Z2_PROGRAM = '" + _program + "'"
        endif
    endif
	cQuery += " AND Z2_STATUS <> 'E'"
	cQuery += " AND " + RetSQLDel('SZ2')

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	//verifica se houve retorno na query
    Count to nCount

    If nCount > 0
        Return .T.
    endif

return .F.

//Função para reclassificar carcaças
//desenvolvida pelo Pai (Giuliano pra quem não sabe)
//_ClasseAtu:  é a classificação atual do objeto
//_ClasseComp: é a classificação usada para comparar a classificação atual
/*User Function GF_Rec(_ClasseAtu,_ClasseComp)
	Local _ClasseNova  := ''
	Local _VlClasA := ValorClasse(_ClasseAtu)
	Local _VlClasC := ValorClasse(_ClasseComp)
	Local _VlClasN := 1

	if _VlClasC > _VlClasA
		_VlClasN := _VlClasC
	else
		_VlClasN := _VlClasA
	endif

	_ClasseNova := ClasseValor(_VlClasN)

return _ClasseNova

//Função auxiliar
Static Function ValorClasse(_classe)
	Local _valor := 0
	do case
		case  AllTrim(_classe) = 'NE'
		_valor := 4
		case  AllTrim(_classe) = 'HK'
		_valor := 3
		case  AllTrim(_classe) = 'RU'
		_valor := 2
		case  AllTrim(_classe) = 'RT'
		_valor := 1
	endcase

return _valor

//Função auxiliar
Static Function ClasseValor(_valor)
	Local _classe := ''
	do case
		case  _valor = 4
		_classe := 'NE'
		case _valor = 3
		_classe := 'HK'
		case _valor = 2
		_classe := 'RU'
		case _valor = 1
		_classe := 'RT'
	endcase
return _classe


User Function TSTREC()
	_teste := u_GF_Rec('NE','HK')
	alert(_teste)
return*/
