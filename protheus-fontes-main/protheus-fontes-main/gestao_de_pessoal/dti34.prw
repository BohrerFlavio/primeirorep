#INCLUDE "rwmake.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³DTI34     ºAutor  ³Mauricio Roehrs º Data ³  05/05/17	      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.      ³ Gestão de saldo de horas dos funcionarios                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso        ³ SIGAGPE/SIGAPON  		                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI34()

	Private aBrowse1 := {}
	Private _UltOrd  := 0
	Private _cGet1   := space(6)
	Private _oFont   := tFont():New("courier new",,-14,,.t.,,,,)
	Private _cSay    := 'Matricula'
	Private oDlgA    := NIL
	Private oDlgCC   := NIL
	Private nRadio   := 1
	//	Private oBrowse2 := NIL
	aHead    := {'Matricula','Nome','Centro de Custo','Saldo Atual'}
	//Largura das colunas
	aLargCol := {40,   130   ,  60   ,  30 }

	// Vetor com elementos do Brose
	aBrowse1 := {}
	aBrowse2 := {}

	dbSelectArea('ZBB')
	ZBB->(dbSetOrder(1))
	ZBB->(dbGoTop())

	DEFINE DIALOG oDlg TITLE "Saldos de Horas"  FROM 020,50 To 700,1000 PIXEL //000, 000  TO 500, 500 PIXEL
	// Cria Browse
	oBrowse1 := TCBrowse():New(00,60,400,280,,aHead,aLargCol,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	//Opção para exibir ou não os demitidos
	aItems := {'N.Exibir Dem','Exibir Dem'}

	_oSay  := TSay():New(001, 005, {||_cSay}, oDlg,, _oFont,,,, .T.,, CLR_BLACK, 200, 20)
	_oGet1 := TGet():New(010, 005, {|u| If(PCount() > 0, _cGet1:= u, _cGet1)},oDlg,050, 010, "@!",{||buscaNome(_cGet1)}, 0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"_cGet1",,,,.t.)
	oRadio := TRadMenu():New (020,005,aItems,,oDlg,,,,,,,,100,12,,,,.T.)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
	oRadio:bWhen := {|| .T. }
	montabrow()

	TButton():New( 040, 005, 'Filtra Opcao'     , oDlg,{|| montabrow()                    },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 055, 005, "Operar"		    , oDlg,{|| operar(aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],aBrowse1[oBrowse1:nAt,04])},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 065, 005, "Alimenta Saldos"  , oDlg,{|| alimentaSaldos()                 },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 075, 005, "Imprimir"  		, oDlg,{|| imprimir()	                    },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 085, 005, "Folga por CC"		, oDlg,{|| folgaCC()	                    },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 095, 005, "Sair"			    , oDlg,{|| oDlg:end()                       },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	//_oGet1 := TGet():New(005, 009, {|u| If(PCount()== 0, _cGet1,_cGet1:= u )},oDlg,060, 010, "!@",{||buscaNome()}, 0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"_cGet1",,,,.t.)

	ACTIVATE DIALOG oDlg CENTERED

return

Static Function operar(_cMat,_cNome,_cCC,_cSldAtu)

	
	Private aHeader   := {}
	Private aCols	  := {}
	Private nUsado	  := 0
	Private oGet	  := NIL
	Private oDlg2     := NIL
	Private _cSaldo   := _cSldAtu

	ZBB->(DbSetOrder(1))
	ZBB->(MsSeek(FWxfilial('ZBB')+_cMat))

	dbSelectArea('SRA')
	SRA->(dbSetOrder(1))
	SRA->(MsSeek(FWxFilial('SRA') + _cMat))

	_cDescCC    := GetAdvFval('CTT','CTT_DESC01',FWxFilial('CTT') + _cCC,1)
	_cDescTurno := GetAdvFval('SR6','R6_DESC', FWxFilial('SR6') + SRA->RA_TNOTRAB,1)

	aHead2    := {'Matricula','Data da Folga','Horas de Folga','Apontado?'}
	//Largura das colunas
	aLargCol2 := {      20     ,      30      ,       40    ,   40  }

	DEFINE MSDIALOG oDlg2 TITLE 'Controle de Horas' from 00,00 To 570,855 OF oMainWnd PIXEL

	//DADOS DO Funcionario
	oGrupo1  := tGroup():New(05, 10, 40, 390,'Dados do Funcionario', oDlg2,,, .t.)

	@ 01,02 SAY "Matricula: " + _cMat
	@ 01,10 SAY "Nome: " + substr(_cNome,1,30)  of oDlg2
	@ 01,25 SAY "Centro de Custo: " + _cDescCC of oDlg2
	@ 01,37 SAY "Saldo de Horas: " + _cSaldo of oDlg2
	@ 02,02 SAY "Turno: " + _cDescTurno of oDlg2

	oBrowse2 := TCBrowse():New(55,00,427,200,,aHead2,aLargCol2,oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	montabr2(_cMat)

	TButton():New(042, 005, "Incluir"  , oDlg2,{|| Atualizar(_cMat)   },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(042, 055, "Alterar"  , oDlg2,{|| Alterar(aBrowse2[oBrowse2:nAt,01],aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],aBrowse2[oBrowse2:nAt,04])},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(042, 105, "Excluir"  , oDlg2,{|| Excluir(aBrowse2[oBrowse2:nAt,01],aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],aBrowse2[oBrowse2:nAt,04])},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New(270, 330, "Sair"     , oDlg2,{|| oDlg2:end() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	oDlg2:Refresh()

	ACTIVATE MSDIALOG oDlg2 CENTERED

return

static Function alimentaSaldos()

	Processa({||geraSaldos()} ,"PROCESSANDO REGISTROS...","Selecionando Funcionarios...")

return

Static Function geraSaldos()

	Private _cDtPeriodo 		:= GETMV('MV_PAPONTA')//parametro que possui a data de apontamento do ponto
	Private _cUltPer     	    := GETMV('SI_ULTPER')
	Private _cDtIni     		:= substr(_cDtPeriodo,1,8)
	Private _cDtFim 	  		:= substr(_cDtPeriodo,10,8)
	Private _dIniPer       	    := stod("")
	Private _dFimPer	    	:= stod("")
	Private _dAnoIni    		:= stod("")
	Private _dAnoFim	  		:= stod("")
	Private _cMat		  		:= ''
	Private _dDataCorrente	    := stod("")
	Private _nDias 		  	    := 0
	Private _aBat				:= {}
	Private _nTotHr		  	    := 0
	Private _dDataIni			:= stod("")
	Private cPerg   			:= "DTI05"

	if alltrim(_cUltPer) == alltrim(_cDtPeriodo)
		if !msgbox('Saldos do periodo de ' + dtoc(stod(_cDtIni)) + ' até ' + dtoc(stod(_cDtFim)) + ' já gerados, deseja continuar?','Saldos de Horas','YESNO')
			alert('Operação cancelada!')
			return
		endif
	endif

	if !msgbox('Deseja realmente gerar saldos utilizando o periodo de ' + dtoc(stod(_cDtIni)) + ' até ' + dtoc(stod(_cDtFim)) + ' ?','ATENÇÃO!','YESNO')
		alert('Operação cancelada!')
		return
	endif

	if !pergunte(cPerg,.t.)
		return
	endif

	geraQuery()

	dbSelectarea('ZBB')
	ZBB->(dbSetOrder(1))
	ZBB->(dbGoTop())

	ProcRegua(TMP->(RecCount()))

	while TMP->(!eof())

		incproc()

		_nTotHr := 0
		_nDias  := 0

		if cFilAnt <> '01'

			if TMP->RA_ACORHE <> 'S'
				calcHoras(TMP->RA_MAT)
			else
				calcMedia(TMP->RA_MAT)
			endif

			if _nDias > 0 .and. _nTotHr > 0

				//se não encontrar na tabela inclui um registro novo
				if !ZBB->(MsSeek(FWxFilial('ZBB') + TMP->RA_MAT))
					reclock('ZBB',.t.)
					ZBB->ZBB_FILIAL := FWxFilial('ZBB')
					ZBB->ZBB_MAT 	:= TMP->RA_MAT
					ZBB->ZBB_CC     := TMP->RA_CC
					ZBB->ZBB_SLDATU := _nTotHr
					ZBB->ZBB_SLDANT := 0
					ZBB->ZBB_ULTPER := _cDtPeriodo
					msunlock()
				else
					if !empty(ZBB->ZBB_ULTPER)
						_cUltPerIni := substr(ZBB->ZBB_ULTPER,1,8)
						_cUltPerFim := substr(ZBB->ZBB_ULTPER,10,8)

						//se a data do periodo for menor que a data do campo pula o registro
						if stod(_cDtIni) <= stod(_cUltPerIni)
							TMP->(dbSkip())
							loop
						endif

						_nSldAtu := ZBB->ZBB_SLDATU
						reclock('ZBB',.f.)
						ZBB->ZBB_SLDATU := _nSldAtu + _nTotHr
						ZBB->ZBB_SLDANT := _nSldAtu
						ZBB->ZBB_ULTPER := _cDtPeriodo
						msunlock()

					endif
				endif
			endif
		endif

		_nTotHr := 0
		_nDias  := 0
		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	enddo

	//remonta o browse
	montabrow()
	putmv('SI_ULTPER',_cDtPeriodo)//grava no parametro o ultimo periodo

return

Static Function geraQuery()

	Local nS
	
	_cSituacao  := mv_par05
	_cCategoria := mv_par06
	//-- Modifica variaveis para a Query
	cSitQuery := ""
	For nS:=1 to Len(_cSituacao)
		cSitQuery += "'"+Subs(_cSituacao,nS,1)+"'"
		If ( nS+1) <= Len(_cSituacao)
			cSitQuery += ","
		Endif
	Next nS

	cCatQuery := ""
	For nS:=1 to Len(_cCategoria)
		cCatQuery += "'"+Subs(_cCategoria,nS,1)+"'"
		If ( nS+1) <= Len(_cCategoria)
			cCatQuery += ","
		Endif
	Next nS

	_cQuery := " SELECT RA_MAT, RA_NOME, RA_CC, RA_ACORHE
	_cQuery += " FROM " + retSqlTab('SRA')
	_cQuery += " WHERE " +  retSqlFil('SRA')
	_cQuery += " AND RA_MAT BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	_cQuery += " AND RA_CC BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	_cQuery += " AND RA_CATFUNC IN (" + Upper(cCatQuery) + ")"
	_cQuery += " AND RA_SITFOLH IN (" + Upper(cSitQuery) + ")"
	_cQuery += " AND " + retSqlDel('SRA')
	_cQuery += " ORDER BY RA_CC,RA_NOME,RA_MAT

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

//Monta o browse
Static Function montabrow()

	// Vetor com elementos do Browse
	aBrowse1 := {}

	ZBB->(DbSetOrder(1))
	ZBB->(dbGoTop())
	while ZBB->(!eof()) .and. ZBB->ZBB_FILIAL = FWxfilial('ZBB')

		_cNome := GetAdvFval('SRA','RA_NOME',FWxFilial('SRA') + ZBB->ZBB_MAT,1)

		if  ZBB->ZBB_SLDATU < 0
			_cHrTratada	:= StrTran(Transform( fConvHr( ZBB->ZBB_SLDATU * -1,'H') * -1 , '@e 9999.99' ),',',':' )
		else
			_cHrTratada	:= StrTran(Transform( fConvHr( ZBB->ZBB_SLDATU,'H'), '@e 9999.99' ),',',':' )
		endif

		//_cHrTratada	:= StrTran(Transform( fConvHr( ZBB->ZBB_SLDATU,'H'), '@e 9999.99' ),',',':' )
		SRA->(DbSetOrder(1))
		if SRA->(MsSeek(FWxfilial('SRA')+ ZBB->ZBB_MAT))
			if ZBB->ZBB_CC <> SRA->RA_CC //Verifica se houve alteração CC
				reclock('ZBB',.f.)
				ZBB->ZBB_CC := SRA->RA_CC
				msunlock()
			endif
			if nRadio = 1 .and. Empty(SRA->RA_DEMISSA) //Não exibir os demitidos
				aadd(aBrowse1,{ZBB->ZBB_MAT,substr(_cNome,1,25),ZBB->ZBB_CC,_cHrTratada})
			endif
			if nRadio = 2 // Exibir os demitidos*/
				aadd(aBrowse1,{ZBB->ZBB_MAT,substr(_cNome,1,25),ZBB->ZBB_CC,_cHrTratada})
			endif			
		endif

		ZBB->(DbSkip())
	enddo

	if len(aBrowse1) = 0
		aadd(aBrowse1,{'','','',''})
	endif

	// Seta vetor para a browse
	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAT,02],aBrowse1[oBrowse1:nAT,03],aBrowse1[oBrowse1:nAT,04]}}

	oBrowse1:nScrollType := 1
	oBrowse1:bLDblClick  := {|| ordena(oBrowse1:ColPos()) }

	oBrowse1:DrawSelect()
	oBrowse1:refresh()
	oDlg:refresh()

return

Static Function montabr2(_cMat)

	// Vetor com elementos do Browse
	aBrowse2 := {}

	ZBC->(DbSetOrder(1))
	ZBC->(MsSeek(FWxfilial('ZBC') + _cMat))

	while ZBC->(!eof()) .and. ZBC->ZBC_FILIAL = FWxfilial('ZBC') .and. ZBC->ZBC_MAT = _cMat

		_cHrTratada	:= StrTran(Transform( fConvHr( ZBC->ZBC_HRBAIX,'H'), '@e 9999.99' ),',',':' )
		aadd(aBrowse2,{ZBC->ZBC_MAT,ZBC->ZBC_DTREF,_cHrTratada,iif(ZBC->ZBC_APONTA = 'N','NAO',;
		iif(ZBC->ZBC_APONTA = 'S','SIM',;
		iif(ZBC->ZBC_APONTA = 'P','SIM','NAO')))})

		ZBC->(DbSkip())
	enddo

	// Seta vetor para a browse
	oBrowse2:SetArray(aBrowse2)

	// Monta a linha a ser exibina no Browse
	if len(aBrowse2) <= 0 //verifica se tem algo no vetor para não dar error.log
		oBrowse2:bLine := {||{'','','',''}}
	else
		oBrowse2:bLine := {||{aBrowse2[oBrowse2:nAt,01],aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],aBrowse2[oBrowse2:nAt,04]}}
	endif

	oBrowse2:nScrollType := 1
	oBrowse2:DrawSelect()
	oBrowse2:refresh()
	oDlg2:refresh()
return

Static Function Atualizar(_cMat)

	Private _dDtFolga  := date()
	Private _nHoras    := 00.00
	//Private oDlgA      := NIL
	Private _cmpData   := date()
	Private _cmpHoras  := 00.00

	@ 116,010 To 225,300 Dialog oDlgA Title "Lançamento da Folga"

	@ 001,001 SAY 'Data da Folga: '
	@ 011,050 MSGET _cmpData  VAR _dDtFolga PICTURE "99/99/99" SIZE 30,08 of oDlgA PIXEL VALID validData(_cMat,_dDtFolga,'I')

	@ 002,001 SAY 'Horas de Folga: '
	@ 025,050 MSGET _cmpHoras VAR _nHoras PICTURE "@E 99.99" SIZE 30,08 of oDlgA PIXEL VALID validSaldo(_cMat,_nHoras,'I')

	oDlgA:refresh()

	@ 40,010  BUTTON 'Confimar'   SIZE 40,10 ACTION ConfAtu(_cMat,_nHoras,_dDtFolga,1)  OBJECT oBtn10
	@ 40,080  BUTTON 'Cancelar'   SIZE 40,10 ACTION oDlgA:end()  OBJECT oBtn10

	Activate Dialog oDlgA CENTERED
return

Static Function Alterar(_cMat,_dDtFolga,_nHoras,_cApontado)

	Private oDlgA      := NIL
	Private _cmpData   := date()
	Private _cmpHoras  := 00.00

	if _cApontado = 'S'
		alert('Já foi efetuado apontamento desta folga, impossivel alteração!')
		return
	endif

	_nHoras := val(strtran(_nHoras,':','.'))

	@ 116,010 To 225,300 Dialog oDlgA Title "Lançamento da Folga"

	@ 001,001 SAY 'Data da Folga: '
	@ 011,050 MSGET _cmpData  VAR _dDtFolga PICTURE "99/99/99" SIZE 30,08 of oDlgA PIXEL VALID validData(_cMat,_dDtFolga,'A')

	@ 002,001 SAY 'Horas de Folga: '
	@ 025,050 MSGET _cmpHoras VAR _nHoras PICTURE "@E 99.99" SIZE 30,08 of oDlgA PIXEL VALID validSaldo(_cMat,_nHoras,'A')

	oDlgA:refresh()

	@ 40,010  BUTTON 'Confimar'   SIZE 40,10 ACTION ConfAlt(_cMat,_nHoras,_dDtFolga)  OBJECT oBtn10
	@ 40,080  BUTTON 'Cancelar'   SIZE 40,10 ACTION oDlgA:end()  OBJECT oBtn10

	Activate Dialog oDlgA CENTERED

return

Static Function Excluir(_cMat,_dDtFolga,_nHoras,_cApontado)

	Private oDlgA      := NIL
	Private _cmpData   := date()
	Private _cmpHoras  := 00.00

	if _cApontado = 'S'
		alert('Já foi efetuado apontamento desta folga, impossivel exclusão!')
		return
	endif

	_nHoras := val(strtran(_nHoras,':','.'))

	@ 116,010 To 225,300 Dialog oDlgA Title "Lançamento da Folga"

	@ 001,001 SAY 'Data da Folga: '
	@ 011,050 MSGET _cmpData  VAR _dDtFolga PICTURE "99/99/99" SIZE 30,08 of oDlgA PIXEL WHEN .F.

	@ 002,001 SAY 'Horas de Folga: '
	@ 025,050 MSGET _cmpHoras VAR _nHoras PICTURE "@E 99.99" SIZE 30,08 of oDlgA PIXEL WHEN .F.

	oDlgA:refresh()

	@ 40,010  BUTTON 'Confimar'   SIZE 40,10 ACTION ConfExc(_cMat,_nHoras,_dDtFolga)  OBJECT oBtn10
	@ 40,080  BUTTON 'Cancelar'   SIZE 40,10 ACTION oDlgA:end()  OBJECT oBtn10

	Activate Dialog oDlgA CENTERED

return

//Confirma exclusão
Static Function ConfExc(_cMat,_Horas,_dDtFolga)

	ZBC->(dbSetOrder(2))
	ZBC->(MsSeek(FWxFilial('ZBC') + _cMat + dtos(_dDtFolga)))
	ZBB->(dbSetOrder(1))
	ZBB->(MsSeek(FWxFilial('ZBB') + _cMat))

	_nSldAtu := ZBB->ZBB_SLDATU
	_nSldAnt := ZBB->ZBB_SLDANT
	//converte o valor digitado para decimal para poder realizar o calculo
	_nHoraDec := fConvHr(_Horas,'D')

	reclock('ZBC',.f.)
	dbdelete()
	msunlock()

	_nCalcSld := _nSldAtu + _nHoraDec
	reclock('ZBB',.f.)
	ZBB->ZBB_SLDATU := _nCalcSld
	ZBB->ZBB_SLDANT := _nCalcSld
	msunlock()

	oDlgA:end()

	montabrow()
	montabr2(_cMat)

	if _nCalcSld < 0
		_cSaldo := StrTran(Transform( fConvHr( _nCalcSld * -1,'H') * -1 , '@e 9999.99' ),',',':' )
	else
		_cSaldo := StrTran(Transform( fConvHr( _nCalcSld,'H'), '@e 9999.99' ),',',':' )
	endif

	//_cSaldo := StrTran(Transform( fConvHr( _nCalcSld,'H'), '@e 9999.99' ),',',':' )
	oDlg2:Refresh()
return

Static Function validSaldo(_cMat,_nHoras,_opc)

	ZBB->(dbSetOrder(1))
	ZBB->(MsSeek(FWxFilial('ZBB') + _cMat))
	//converte o valor digitado para decimal para poder realizar o calculo
	_nHoraDec := fConvHr(_nHoras,'D')

	//if _nHoraDec <= 0
	//	alert('Valor de horas não pode ser zero!')
	//	return .f.
	//endif

	//se for incluir
	//if _opc = 'I'
	//	if _nHoraDec > ZBB->ZBB_SLDATU
	//		alert('Não há saldo suficiente!')
	//		return .f.
	//	endif
	//endif

	//se for alterar
	if _opc = 'A'

		_nHrBrow  := fConvHr(val(strtran(aBrowse2[oBrowse2:nAt,03],':','.')),'H')
		_nHraCalc := 0

		//se a hora digitada for maior que a já informada
		if _nHoraDec > _nHrBrow

			//refaz o saldo com o valor da linha + o saldo atual
			_nHraCalc := _nHrBrow + ZBB->ZBB_SLDATU
			//se o valor digitado for maior que o saldo
			//if _nHoraDec > _nHraCalc
			//	alert('Não há saldo suficiente!')
			//	return .f.
			//endif
		endif
	endif

return .t.

Static Function validData(_cMat,_dDtFolga,_opc)

	ZBC->(dbSetOrder(2))
	ZBC->(dbGoTop())

	//_dSemana := date() - 30

	//if _dDtFolga < _dSemana
	//	alert('Não é possivel informar folga para data retroativa maior que 30 dias!')
	//	return .f.
	//endif

	//validação somente quando for inclusão
	if _opc = 'I'
		if ZBC->(MsSeek(FWxFilial('ZBC') + _cMat + dtos(_dDtFolga)))
			alert('Já existe lançamento com esta data!')
			return .f.
		endif
	endif

return .t.

//Confirma a Atualização
Static Function ConfAtu(_cMat,_Horas,_dDtFolga,_mod)

	ZBC->(dbSetOrder(1))
	ZBC->(MsSeek(FWxFilial('ZBC') + _cMat))
	ZBB->(dbSetOrder(1))
	ZBB->(MsSeek(FWxFilial('ZBB') + _cMat))

	_nSldAtu := ZBB->ZBB_SLDATU
	_nSldAnt := ZBB->ZBB_SLDANT
	//converte o valor digitado para decimal para poder realizar o calculo
	_nHoraDec := fConvHr(_Horas,'D')

	reclock('ZBC',.t.)
	ZBC->ZBC_FILIAL := FWxFilial('ZBC')
	ZBC->ZBC_MAT    := _cMat
	ZBC->ZBC_DTREF  := _dDtFolga
	ZBC->ZBC_HRBAIX := _nHoraDec
	ZBC->ZBC_APONTA := 'N'
	msunlock()

	_nCalcSld := _nSldAtu - _nHoraDec
	reclock('ZBB',.f.)
	ZBB->ZBB_SLDATU := _nCalcSld
	ZBB->ZBB_SLDANT := _nSldAtu
	msunlock()

	if _mod = 1
		oDlgA:end()
	elseif _mod = 2
		oDlgCC:end()
	endif

	montabrow()
	if _mod = 1
		montabr2(_cMat)
	endif

	if _nCalcSld < 0
		_cSaldo := StrTran(Transform( fConvHr( _nCalcSld * -1,'H') * -1 , '@e 9999.99' ),',',':' )
	else
		_cSaldo := StrTran(Transform( fConvHr( _nCalcSld,'H'), '@e 9999.99' ),',',':' )
	endif

	if _mod = 1
		oDlg2:Refresh()
	endif
return

//confirma a alteração
Static Function ConfAlt(_cMat,_Horas,_dDtFolga)

	_dDtBrow := aBrowse2[oBrowse2:nAt,02]
	_nHrBrow  := fConvHr(val(strtran(aBrowse2[oBrowse2:nAt,03],':','.')),'H')

	ZBC->(dbSetOrder(2))
	ZBC->(MsSeek(FWxFilial('ZBC') + _cMat + dtos(_dDtBrow)))
	ZBB->(dbSetOrder(1))
	ZBB->(MsSeek(FWxFilial('ZBB') + _cMat))

	_nSldAtu := ZBB->ZBB_SLDATU
	_nSldAnt := ZBB->ZBB_SLDANT
	//converte o valor digitado para decimal para poder realizar o calculo
	_nHoraDec := fConvHr(_Horas,'D')

	reclock('ZBC',.f.)
	ZBC->ZBC_DTREF  := _dDtFolga
	ZBC->ZBC_HRBAIX := _nHoraDec
	ZBC->ZBC_APONTA := 'N'
	msunlock()

	//se a hora do browse for maior que a hora informada
	if _nHrBrow > _nHoraDec

		//pega a diferença de horas
		_nCalcHra := _nHrBrow - _nHoraDec
		_nCalcSld := _nSldAtu + _nCalcHra

		//se a hora do browse for menor que a hora informada
	elseif _nHrBrow < _nHoraDec

		//pega a diferença de horas
		_nCalcHra :=  _nHoraDec - _nHrBrow

		_nCalcSld := _nSldAtu - _nCalcHra

	else //senão saldo atual continua o mesmo
		_nCalcSld := _nSldAtu

	endif

	reclock('ZBB',.f.)
	ZBB->ZBB_SLDATU := _nCalcSld
	msunlock()

	oDlgA:end()
	montabrow()
	montabr2(_cMat)

	if _nCalcSld < 0
		_cSaldo := StrTran(Transform( fConvHr( _nCalcSld * -1,'H') * -1 , '@e 9999.99' ),',',':' )
	else
		_cSaldo := StrTran(Transform( fConvHr( _nCalcSld,'H'), '@e 9999.99' ),',',':' )
	endif

	//_cSaldo := StrTran(Transform( fConvHr( _nCalcSld,'H'), '@e 9999.99' ),',',':' )

	oDlg2:Refresh()
return

//função para ordenação do browse
Static Function ordena(_Ord)
	if _Ord = _UltOrd
		aBrowse1 := aSort(aBrowse1,,, {|x, y| x[_Ord] > y[_Ord]})
		_UltOrd := 0
	else
		aBrowse1 := aSort(aBrowse1,,, {|x, y| x[_Ord] < y[_Ord]})
		_UltOrd := _Ord
	endif

	// Seta vetor para a browse
	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAT,02],aBrowse1[oBrowse1:nAT,03],aBrowse1[oBrowse1:nAT,04]}}

	oBrowse1:nScrollType := 1
	oBrowse1:bLDblClick     := {|| ordena(oBrowse1:ColPos()) }

	oBrowse1:DrawSelect()
	oBrowse1:refresh()
	oDlg:refresh()
return

Static Function calcHoras(_cMat)

	_dIniPer  := stod(substr(_cDtPeriodo,1,8))
	_dFimPer  := stod(substr(_cDtPeriodo,10,18))
	_dInicial := seekDataIni(_cMat,_dIniPer,_dFimPer)

	DbSelectArea('SP8')
	SP8->(DbSetOrder(2))
	SP8->(DbGoTop())
	if SP8->(MsSeek(FWxFilial('SP8') + _cMat + _dInicial))

		if _dDataIni < _dIniPer
			_dDataIni := _dIniPer
		endif

		//enquanto a data das marcações da SP8 estiverem entre as datas do parametro MV_PAPONTA
		while SP8->(!eof()) .and. FWxFilial('SP8') == SP8->P8_FILIAL .and. alltrim(_cMat) == alltrim(SP8->P8_MAT) .and. SP8->P8_DATAAPO <= _dFimPer

			/*validação extra para filia, estava causando problemas quando havia matriculas iguais nas duas filiais*/
			if SP8->P8_FILIAL <> cFilAnt
				SP8->(DbSkip())
				loop
			endif

			/*esta condição prevê falhas de leitura e apontamento*/
			if empty(SP8->P8_PAPONTA) .or. empty(SP8->P8_ORDEM) .or. empty(SP8->P8_DATAAPO)
				SP8->(DbSkip())
				loop
			endif

			/*Ignora os centros de custos a seguir somente para o frigorifico*/
			if cEmpAnt = '01'
				if (SP8->P8_CC = "1111003") .or. (SP8->P8_CC = "1121001") .or. (SP8->P8_CC = "1121002") //.or. (SP8->P8_CC = "1111001")
					SP8->(DbSkip())
					loop
				endif
			endif

			/*Ignora marcações que foram rejeitadas automaticamente pelo sistema */
			if SP8->P8_TIPOREG = 'O' .and. !empty(SP8->P8_MOTIVRG)
				SP8->(DbSkip())
				loop
			endif

			/*Ignora marcações que foram excluidas manualmente*/
			if SP8->P8_TIPOREG = 'I' .and. (SP8->P8_MOTIVRG $ 'MARC INVERTIDA' .or. SP8->P8_MOTIVRG $ 'MARCACAO INVERTIDA')
				SP8->(DbSkip())
				loop
			endif

			/*Ignora marcações que foram excluidas manualmente*/
			if SP8->P8_TIPOREG = 'I' .and. (SP8->P8_MOTIVRG $ 'MARC INCORRETA' .or. SP8->P8_MOTIVRG $ 'MARCACAO INCORRETA')
				SP8->(DbSkip())
				loop
			endif

			/*Ignora marcações que foram excluidas manualmente*/
			if SP8->P8_TIPOREG = 'I' .and. SP8->P8_MOTIVRG $ 'EXCLUSAO MANUAL'
				SP8->(DbSkip())
				loop
			endif

			//validação do campo caso tenha marcação excluida pelo sistema
			If SP8->P8_TPMCREP = 'D'
				SP8->(DbSkip())
				loop
			endif

			/*Para fazer a contagem de apenas um dia*/
			if _dDataCorrente = SP8->P8_DATAAPO
				SP8->(DbSkip())
				loop
			else
				_dDataCorrente := SP8->P8_DATAAPO
			endif

			//alert(dtoc(SP8->P8_DATAAPO))
			_nDias ++

			//alert('Matricula: ' + SP8->P8_MAT + '     '+'Total de Dias:' + cValToChar(_nDias))

			SP8->(DbSkip())
		enddo
	endif

	_nTotHr := calcula(_nDias)
return

Static Function calcMedia(_mat)

	SRA->(dbSetOrder(1))
	SRA->(MsSeek(FWxFilial('SRA') + alltrim(_mat)))

	_nDias   := SRA->RA_DIASFOL //media de dias sera de 21 dias de acordo com Patricia Lopes
	_nTotHr  := calcula(_nDias)

return

Static Function calcula(_nDias)

	Local _nTotal := 0

	_nTotal := _nDias * 0.33333333

return _nTotal

Static Function seekDataIni(cMat,_dtIni,_dtFim)

	_cQuery2 := " SELECT TOP 1 P8_DATAAPO"
	_cQuery2 += " FROM " + retSqlTab('SP8')
	_cQuery2 += " WHERE " + retSqlFil('SP8')
	_cQuery2 += " AND P8_DATAAPO BETWEEN '" + dtos(_dtIni) + "' AND '" + dtos(_dtFim) + "'"
	_cQuery2 += " AND P8_MAT = '" + cMat + "'"
	_cQuery2 += " AND " + retSqlDel('SP8')
	_cQuery2 += " ORDER BY P8_DATAAPO"

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"
	TMP2->(dbGoTOp())

return TMP2->P8_DATAAPO

Static Function imprimir()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3       	:= "Saldo de horas da troca de roupas"
	
	Local titulo       	:= "Saldo de Horas da Troca de Roupas"
	Local nLin         	:= 80

	Local Cabec1       	:= "Matricula           Nome        	            Saldo de Horas"
	Local Cabec2       	:= ""
	
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "P"
	Private nomeprog    := "DTI34" // Coloque aqui o nome do programa para impressao no cabecalho
	Private cPerg       := ''
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI34" // Coloque aqui o nome do arquivo usado para impressao em disco

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//wnrel := SetPrint('ZAS',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	wnrel := SetPrint('SRA',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	//SetDefault(aReturn,'ZAS')
	SetDefault(aReturn,'SRA')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  28/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
s±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	
	Local i

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetRegua(len(aBrowse1))

	_cCC := ''
	for i:=1 to len(aBrowse1)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		_cSitfol := GetAdvFval('SRA','RA_SITFOLH',FWxFilial('SRA') + alltrim(aBrowse1[i,01]),1)

		if _cSitFol = 'D'
			loop
		endif

		if _cCC <> aBrowse1[i,03]
			_descCC := GetAdvFval('CTT','CTT_DESC01',FWxFilial('CTT') + aBrowse1[i,03],1)
			@nlin,01 psay replicate('-',80)
			nlin++
			@nlin,02 psay 'Centro de Custo: ' + _descCC
			nlin++
			@nlin,01 psay replicate('-',80)
			nlin++
			_cCC := aBrowse1[i,03]
		endif

		@nlin,02 psay aBrowse1[i,01]
		@nlin,15 psay substr(aBrowse1[i,02],1,35)
		//@nlin,30 psay aBrowse1[i,03]
		@nlin,50 psay aBrowse1[i,04]

		nlin++

	next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1

		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

Static Function buscaNome(_cMat)

	local _lAchou := .f.
	Local i

	for i:=1 to len(aBrowse1)

		if (padl(alltrim(_cMat),6,'0') == alltrim(aBrowse1[i,01]))
			_lAchou := .t.
			oBrowse1:GoPosition(i)
			oBrowse1:DrawSelect()
			oBrowse1:refresh()
			oDlg:refresh()
			exit
		endif

	next

	if !_lAchou
		alert('Matricula não encontrada!')
	endif

return

Static Function folgaCC()

	Private _aTexto 	:= {}
	Private _cTexto 	:= ''
	Private aTela    	:= {}
	Private aStru    	:= {}
	Private aCampos  	:= {}
	Private cArq
	Private cMark    	:= GetMark()
	Private oMark
	Private marc      := .f.
	Private lInverte	:= .f.
	Private aButtons  := {}
	Private _lConf    := .f.
	Private lOk			:= .F.	
	Private  _dDtVcto   := date()
	Private  _nHrsFlg   := 00.00

	aObjects            := {}
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	Processa({||montabrwcc()} ,"PROCESSAMENTO DE REGISTROS","montando tela com os centros de custo...")

	//bloco para ajustar tamanho da tela conforme a resolução do monitor.
	//	pixTela1:=0
	//	pixTela2:=0
	//	if aSizeAut[6] >= 696
	//		pixTela1 := aSizeAut[6] - 370
	//	else
	//		pixTela1 := aSizeAut[6] - 298
	//	endif
	//
	//	if aSizeAut[5] >= 1538
	//		pixTela2 := aSizeAut[5] - 780
	//	else
	//		pixTela2 := aSizeAut[5] - 655
	//	endif

	////00,60,400,280
	//020,50 To 700,1000
	DbSelectArea('TMP')
	TMP->(dbGoTop())
	DEFINE MSDIALOG oDlgCC TITLE 'Seleção de Centros de Custo' from 20,50 To 600,1000 OF oMainWnd PIXEL
	oMark  := MsSelect():New("TMP","OK","",aCampos,@lInverte,@cMark,{32,60,280,440})  //275 298-655
	oMark:bMark := {| | Disp()}				

	Aadd( aButtons, {"MARCATODOS", {|| MarkAll(1)}, "Marca Todos", "Marca Todos" , {|| .T.}} )
	Aadd( aButtons, {"DESMARCTDS", {|| MarkAll(2)}, "Desmarca Todos", "Desmarca Todos" , {|| .T.}} )
	Aadd( aButtons, {"APONTAHRS",  {|| apontaHrs()},"Informa Horas", "Informa Horas" , {|| .T.}} )

	ACTIVATE MSDIALOG oDlgCC ON INIT (EnchoiceBar(oDlgCC,{||verifHrs()},{||lOk := .f., oDlgCC:End()},,@aButtons))

	TMP->(DbCloseArea())

Return

Static Function markAll(_opc)

	TMP->(dbgotop())

	while TMP->(!eof())
		reclock('TMP',.f.)
		if _opc = 1//se for 1 marca
			TMP->OK := cMark
		else//senao desmarca
			TMP->OK := ''
		endif
		msunlock()
		TMP->(dbskip())
	enddo

	TMP->(dbgotop())

	oMark:oBrowse:Refresh()

return .t.

Static Function montabrwcc()

	//cArq  := CriaTrab( Nil, .F. )

	aadd(aCampos,{"OK"    	,,"OK" 	     			    ,"@!"})
	aadd(aCampos,{"CC"      ,,"Centro de Custo"			,"@!"})
	aadd(aCampos,{"DESC"	,,"Descrição"   			,"@!"})

	aadd(aStru,{"OK"        , "C",  02,  0,   "@!"         , 'Ok		 	    	  '})
	aadd(aStru,{"CC"		, "C",  09,  0,   "@!"         , 'Centro de Custo		  '})
	aadd(aStru,{"DESC"  	, "C",  40,  0,   "@!" 		   , 'Descrição	  			  '})

	//dbcreate(cArq,aStru)
	//If Select("TMP") != 0
	//	TMP->(DbCloseArea())
	//endif
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	_aArqTrb := {}
	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aCampos, {}, @_aArqTrb)

	filtraCC()

	TMP->(DbGotop())

	QRY->(dbGoTop())
	Procregua(recCount("QRY"))
	While QRY->(!eof())

		IncProc('Processando dados do centro de custo: ' + QRY->CTT_CUSTO)

		reclock('TMP',.t.)
		TMP->CC  := QRY->CTT_CUSTO
		TMP->DESC := QRY->CTT_DESC01
		msunlock()

		QRY->(DbSkip())
	enddo

	TMP->(DbGoTop())

return

//Função que chama a telinha de alteração dos vales-transporte
Static Function apontaHrs()
	local 	_Campo2    := date()
	local 	_Campo3    := 00.00

	DEFINE MSDIALOG oDlg2 TITLE 'Informe Data e Hora da folga' from 000,000 To 130,200 OF oMainWnd PIXEL

	@ 015,002 SAY  'Dt. Folga' Object oSay1
	@ 001,005 MSGET _Campo2 VAR _dDtVcto SIZE 35,11 PICTURE '99/99/99' VALID !Vazio() OF oDlg2

	@ 030,002 SAY  'Horas' Object oSay1
	@ 002,005 MSGET _Campo3 VAR _nHrsFlg SIZE 35,11 PICTURE '@E 99.99' VALID !Vazio() OF oDlg2

	@ 040,040 BMPBUTTON TYPE 1 ACTION cnfDt() Object Obtn1

	ACTIVATE MSDIALOG oDlg2 CENTERED

return

Static Function filtraCC()

	_cQuery := " SELECT CTT_CUSTO, CTT_DESC01
	_cQuery += " FROM " + retSqlTab("CTT")
	_cQuery += " WHERE " + retSqlFil("CTT")	
	_cQuery += " AND CTT_CLASSE = '2'"
	_cQuery += " AND " + retSqlDel("CTT")
	_cQuery += " ORDER BY CTT_CUSTO

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

return

//Função que confirma a inserção
Static Function CnfDt()

	_lConf := .t.

	odlg2:end()
return

Static Function GravHras()
	Processa({||Gravar()} ,"PROCESSAMENTO DE REGISTROS","Efetivando a inclusão das folgas...")
return

Static Function Gravar()

	_lmarcou := .f.
	TMP->(dbGoTop())
	//procRegua(RecCount("TMP"))

	ProcRegua(TMP->(RecCount()))

	While TMP->(!eof())

		IncProc('Processando dados do Centro de Custo: ' + TMP->DESC)

		//IncProc()				
		If !empty(TMP->OK)
			_lMarcou := .t.
			filtraMat(TMP->CC)

			MAT->(dbGoTop())			

			while MAT->(!EOF())

				ZBC->(dbSetOrder(2))
				if ZBC->(MsSeek(FWxFilial('ZBC') + MAT->ZBB_MAT + dtos(_dDtVcto)))
					MAT->(dbSkip())
					loop
				endif	
				if _nHrsFlg > 0
					ConfAtu(MAT->ZBB_MAT,_nHrsFlg,_dDtVcto,2)
				else
					_nVal := SPCMAT(MAT->ZBB_MAT, _dDtVcto)
					if _nVal > 0
						ConfAtu(MAT->ZBB_MAT, fConvHr(_nVal,'H'), _dDtVcto,2)
					endif	
				endif					

				reclock('TMP',.f.)
				DbDelete()
				msunlock()

				MAT->(dbSkip())
			enddo
		endif
		TMP->(dbSkip())
	enddo

	if _lMarcou
		alert('Processo realizado com sucesso!')
	else
		alert('Falha no processamento!')
	endif
	TMP->(dbGoTop())
return

Static Function GeraTMP()

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

return

Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("OK")
		TMP->OK := cMark
	Else
		TMP->OK := ""
	Endif
	msunlock()

	oMark:oBrowse:Refresh()
Return

Static Function verifHrs()

	local _lRet := .f.

	if _lConf
		GravHras()
		_lRet := .t.
		_lConf := .f.
	else
		alert('Confirme a data da folga!')
	endif

return _lRet


static function filtraMat(_cCC)


	_cQry := " SELECT *"
	_cQry += " FROM  " + retSqlTab('ZBB')
	_cQry += " WHERE " + retSqlFil('ZBB')
	_cQry += " AND ZBB_CC = '" +_cCC + "'"
	_cQry += " AND " + retSqlDel('ZBB')
	_cQry += " ORDER BY ZBB_MAT"


	_cQry  := ChangeQuery(_cQry)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQry Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("MAT") != 0
		MAT->(dbCloseArea())
	Endif

	TCQUERY _cQry NEW ALIAS "MAT"

return 

static function SPCMAT(_cMatr, _dDataSPC)
	Local _nRet := 0
	Local _aArea    := GetArea()
	Local _cQry2 := ""
	_cQry2 := " SELECT SUM(CAST(PC_QUANTC AS INTEGER) + (((PC_QUANTC - CAST(PC_QUANTC AS INTEGER))*100) /60)) AS QTDE "
	_cQry2 += " FROM  " + retSqlTab('SPC')
	_cQry2 += " WHERE PC_MAT = '" +_cMatr + "'"
	_cQry2 += " AND " + retSqlFil('SPC') + " AND " + retSqlDel('SPC')
	_cQry2 += " AND PC_DATA = '" + DTOS(_dDataSPC) + "' AND PC_PD IN ('463','409') "

	TCQUERY _cQry2 NEW ALIAS "SPCT"
	while SPCT->(!eof())
		_nRet := SPCT->QTDE
		SPCT->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	enddo
	DbCloseArea('SPCT')
	RestArea(_aArea)
return(_nRet)
