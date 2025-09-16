#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "totvs.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF191    ºAutor  ³Giuliano Forgiarini º Data ³  26/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle de descarga de peças de terceiros                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Programador   ³ Mauricio Lopes Roehrs	    º Data ³  26/06/14        ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP/Expedições                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF191()

	aObjects := {}                                             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	Private lOk := .f.
	Private _aAlter := {}
	Private _cNumOP := ''
	Private cCadastro := "Controle de Descarga de Peças de Terceiros"
	Private aRotina := {{"Pesquisar"  		,"AxPesqui",0,1} ,;
						{"&Visualizar"		,"AxVisual",0,2} ,;
						{"&Incluir"   		,"u_gf191I",0,3} ,;
						{"Alterar"    		,"u_gf191A",0,4} ,;
						{"Excluir"    		,"u_gf191X",0,5} ,;
						{"Imprimir"   		,"u_gf191M",0,4} ,;
						{"Baixar Etqs."		,"u_gf191B",0,4} ,;
						{"Gerenciador"		,"u_gf191G",0,4}}

	dbSelectArea('ZAP')
	dbsetorder(3)

	mBrowse(6,1,22,75,'ZAP', ,,,,2,,,,,)

	DbCloseArea()

return

//INCLUSAO
user function gf191I(cAlias,nReg,nOpc)
	Local nCont := 0

	DEFINE MSDIALOG oDlg TITLE '' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZAP",.T.)

	obj := MsMGet():New("ZAP" ,ZAP->(RECNO()),nOpc   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gF191ok()},{||gF191nok()})
	If lOk
		geraOPDes()

		ConfirmSX8()

		recLock('ZAP',.T.)
		// Grava previsao de producao
		For nCont := 1 To FCount()
			If "FILIAL"$Field(nCont)
				FieldPut(nCont,FWxFilial("ZAP"))
			Else
				FieldPut(nCont,M->&(FIELDNAME(nCont)))
			Endif
		Next nCont
		MsUnLock()
	else
		RollBackSx8()
	endif
	ZAJ->(DbGoTop())
return

// Gera OP da Desossa (SZ2) automaticamente ao gerar um certificado
Static Function geraOPDes()
	Local _cCod   := ''
	Local _cDesc  := ''

	do case
		case M->ZAP_CORORI = 'T'
		_cCod := '001340'
		case M->ZAP_CORORI = 'D'
		_cCod := '001502'
		case M->ZAP_CORORI = 'C'
		_cCod := '001450'
	endcase

	_cDesc := GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1')+_cCod,1)

	_cNumOP :=  GetSx8num('SZ2','Z2_NUM')
	ConfirmSx8()

	reclock("SZ2",.T.)
	SZ2->Z2_FILIAL 	:= FWxfilial('SZ2')
	SZ2->Z2_NUM 	:= _cNumOP
	SZ2->Z2_STATUS  := 'B'
	SZ2->Z2_DATA	:= ddatabase
	SZ2->Z2_DTPROD	:= ddatabase
	SZ2->Z2_COD		:= _cCod
	SZ2->Z2_DESCRI  := _cDesc
	SZ2->Z2_RESERV	:= 'S'
	SZ2->Z2_PRIORID := 'T'
	SZ2->Z2_CORORI  := M->ZAP_CORORI
	SZ2->Z2_CLASSIF := M->ZAP_CLASSIF
	SZ2->Z2_CERTIF	:= M->ZAP_NUM
	SZ2->Z2_CERT	:= M->ZAP_CERT
	SZ2->Z2_CLASESP	:= 'N'
	SZ2->Z2_DATAABT := M->ZAP_DATAP
	SZ2->Z2_QPPECA  := M->ZAP_QUANT
	SZ2->Z2_QPPESO  := M->ZAP_PESO
	SZ2->Z2_DIASVAL := 9
	SZ2->Z2_SELRACA := 'NNNNNNNNNNN'
	SZ2->Z2_SELRAST := 'NNNNNNN'
	SZ2->Z2_SELCORT := 'NNN'
	SZ2->Z2_SELTFCS := 'NN'
	msunlock()

Return

//funçao que confirma a inserção da previsao de produção
static function gf191ok()

	lOk := .t.

	Odlg:end()
Return lOk

static function gf191nok()
	lOk := .f.
	Odlg:end()
Return

user function gf191M()

	campoA    := 0000
	_nQtdEtq  := 0000

	_nMult    := iif(ZAP->ZAP_CORORI = 'D',1,;
	iif(ZAP->ZAP_CORORI = 'T',1,;
	iif(ZAP->ZAP_CORORI = 'C',1,;
	iif(ZAP->ZAP_CORORI = 'E',3,2))))

	_nTot 	 := _nMult * ZAP->ZAP_QUANT

	_nEtqGer  := 0

	//6 * ZAP->ZAP_QUANT

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA"
	_nGerada := geradas(ZAP->ZAP_NUM)
	_nAGerar := aGerar(ZAP->ZAP_NUM) 
	//_nInserido := inserido(ZAP->ZAP_NUM)

	@ 01,01 SAY "Nr. Certificado:" of telaimp
	@ 02,01 SAY "Sif:" of telaimp
	@ 02,12 SAY "Classif:" of telaimp
	@ 03,01 SAY "Fornecedor:" of telaimp
	@ 03,12 SAY "Loja:" of telaimp
	@ 04,01 SAY "Nome:" of telaimp
	@ 06,01 SAY "Data de Produção:" of telaimp
	@ 07,01 SAY "Quantidade:" of telaimp
	@ 07,12 SAY "Peso Liquido:" of telaimp
	@ 08,01 SAY "Regs. Inseridos:" of telaimp
	@ 09,01 SAY "Etqs. a Gerar:" of telaimp
	@ 09,12 SAY "Etqs. Geradas:" of telaimp
	@ 10,01 SAY "Qtd. a Gerar:" of telaimp

	@ 01,07 SAY ZAP->ZAP_CERT of telaimp
	@ 02,07 SAY ZAP->ZAP_SIF of telaimp
	@ 02,17 SAY ZAP->ZAP_CLASSI of telaimp
	@ 03,07 SAY ZAP->ZAP_FORN of telaimp
	@ 03,17 SAY ZAP->ZAP_LOJA of telaimp
	@ 04,07 SAY ZAP->ZAP_DESCF of telaimp
	@ 06,07 SAY ZAP->ZAP_DATAP of telaimp
	@ 07,07 SAY ZAP->ZAP_QUANT of telaimp
	@ 07,17 SAY transform(ZAP->ZAP_PESO,'@E 999,999.99') of telaimp
	@ 08,07 SAY ZAP->ZAP_QTDREG of telaimp
	@ 09,07 SAY _nAGerar of telaimp
	@ 09,17 SAY _nGerada of telaimp
	@ 10,06 MSGET campoA VAR _nQtdEtq SIZE 20,10 of telaimp picture '@E 9999' VALID valQtd(_nQtdEtq,ZAP->ZAP_QTDREG,ZAP->ZAP_QUANT,_nAGerar,ZAP->ZAP_CORORI) 

	@ 200,005 BUTTON btn1 PROMPT "Gerar" SIZE 50,15 OF telaimp  pixel action gf191Proc(_nTot,ZAP->ZAP_NUM,ZAP->ZAP_QTDREG,ZAP->ZAP_DATAP,ZAP->ZAP_CORORI,ZAP->ZAP_DERIV,ZAP->ZAP_PESPEC)
	@ 200,060 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action procImp(_nQtdEtq,ZAP->ZAP_NUM,ZAP->ZAP_SIF,ZAP->ZAP_CLASSI,ZAP->ZAP_CERT,ZAP->ZAP_MENS,ZAP->ZAP_RACA,ZAP->ZAP_CLASES)
	@ 200,120 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	ACTIVATE MSDIALOG telaimp CENTERED

return

static function valQtd(_nQtdEtq,_nRegs,_nQuant,_nAGerar,_cCorOri)
	local _lOk 		:= .t.
	/*local _nMult	:= iif(_cCorOri = 'D',1,;
	iif(_cCorOri = 'T',1,;
	iif(_cCorOri = 'C',1,;
	iif(_cCorOri = 'E',3,2))))
	local _nTotEtq := _nMult * _nQuant
	local _nFalta  := _nTotEtq - _nRegs*/

	if _nQtdEtq > 25 
		FWAlertError('Quantidade limite de etiquetas a serem impressas é 25!!','ERRO!')
		_lOK := .f.	
	endif

	if (_nQtdEtq > _nAGerar)
		FWAlertError('Quantidade de etiquetas informadas excede a quantidade possivel de registros','ERRO!')
		_lOK := .f.
	endif

return _lOk

static Function gf191Proc(_nTotRegs,_cZapNum, _nRegs, _dDataP,_cCorOri,_cDeriv,_nPesPec)

	Processa({||geraZaj(_nTotRegs,_cZapNum, _nRegs, _dDataP,_cCorOri,_cDeriv,_nPesPec) },"GRAVANDO REGISTROS","Realizando processamento das peças...")

return

/*metodo para gerar os dados para que sejam gravados na ZAJ*/
static function geraZaj(_nTotRegs,_cZapNum, _nRegs, _dDataP,_cCorOri,_cDeriv,_nPesPec)
	Local i
	_nImp := iif(_cCorOri $ 'D/T/C',1,iif(_cCorOri = 'E',3,2))

	//_nImp  := 6
	_nCont     := 0
	_cCodDeriv := ''

	if _nRegs < _nTotRegs

		procregua(_nTotRegs)

		while(_nCont < _nTotRegs)

			//incproc('Processando peça nº:' + str(_nCont))
			incproc()

			//Busca codigo de produto derivado (caso exista)
			_cCodDeriv := GetAdvFVal('ZB4','ZB4_COD',FWxfilial('ZB4')+_cDeriv,1)

			//Codigos de dianteiros, traseiros e costelas de fora
			_cCod := iif(_cCorOri = 'D','001502',iif(_cCorOri = 'T','001989','001450'))

			//Se for dianteiro ou traseiro ou costela
			if _cCorOri $ 'T/D/C'

				//Se o codigo de produto derivativo não vier em branco assume  o codigo do produto para imressão
				if !empty(_cCodDeriv)
					_cCod := _cCodDeriv
				endif

				_nCodBar := grava(_cCorOri,_cCod,_cZapNum,_dDataP,_nPesPec, _nCont)

			else

				/*Senão se for Meia-Rez*/
				if _cCorOri = 'E'
					for i := 1 to _nImp
						if i = 1
							_nCodBar := grava('D','001502',_cZapNum,_dDataP,_nPesPec,_nCont)
						elseif i = 2
							_nCodBar := grava('T','001989',_cZapNum,_dDataP,_nPesPec,_nCont)
						elseif i = 3
							_nCodBar := grava('C','001450',_cZapNum,_dDataP,_nPesPec,_nCont)
						endif
					next

					/*Senão se for Traseiro Capote*/
				elseif _cCorOri = 'O'
					for i := 1 to _nImp
						if i = 1
							_nCodBar := grava('T','001989',_cZapNum,_dDataP,_nPesPec,_nCont)
						elseif i = 2
							_nCodBar := grava('C','001450',_cZapNum,_dDataP,_nPesPec,_nCont)
						endif
					next
				endif
			endif

			/*
			if _cCorOri = 'D'
			_nCodBar := grava('D','001502',_cZapNum,_dDataP)
			elseif _cCorOri = 'T'
			_nCodBar := grava('T','001989',_cZapNum,_dDataP)
			elseif _cCorOri = 'C'
			_nCodBar := grava('C','001450',_cZapNum,_dDataP)
			*/

			_nCont += _nImp

			reclock('ZAP',.f.)
			ZAP->ZAP_QTDREG := _nCont
			msunlock()
		enddo

	else
		FWAlertWarning('Registros já incluidos!','ALERTA!')
	endif

	_nGerada := geradas(ZAP->ZAP_NUM)
	_nAGerar := aGerar(ZAP->ZAP_NUM)
	telaimp:refresh()

return

/*metodo que grava na zaj*/
Static Function grava(_cCorOri,_cCod,_cZapNum,_dDataP,_nPesPec,_nSeque)
	local _cNum := ''
	_nSeque := _nSeque + 1
	//local area := getarea()

	_cNum := GetSx8num('ZAJ','ZAJ_NUM')
	ConfirmSX8()

	do case 
		case _cCod = '001502' //'001542'
		_cDescri := 'Diant.Terc.
		case _cCod = '001450' //'000452'
		_cDescri := 'Cost.Terc.'
		case _cCod = '001989' // '001340'
		_cDescri := 'Tras.Terc.' 
		otherwise
		_cDescri := GetAdvFVal('ZB4','ZB4_DESC',FWxfilial('ZB4')+_cCod,1)
	endcase   		

	_cortOrig := GetAdvFVal('ZAP','ZAP_CORORI',FWxFilial('ZAP') + _cZapNum,3)

	_nPercPeso := GetAdvFVal('SB1','B1_PERCQTD',FWxFilial('SB1')+_cCod,1)

	_cNumOP := buscaOPDes(_cCorOri,_cZapNum)

	if _cortOrig $ "C/T/D"
		_nPeso := _nPesPec
	else
		_nPeso := (_nPercPeso / 100) * _nPesPec
	endif

	reclock('ZAJ',.t.)
	ZAJ->ZAJ_FILIAL  := FWxfilial('ZAJ')
	ZAJ->ZAJ_COD     := _cCod
	ZAJ->ZAJ_DESCRI  := _cDescri
	ZAJ->ZAJ_CORORI  := _cCorOri
	ZAJ->ZAJ_NUM     := _cNum
	ZAJ->ZAJ_NIVEL   := 0
	ZAJ->ZAJ_REGORI  := '0000000000' 
	ZAJ->ZAJ_DATA    := _dDataP//date()
	ZAJ->ZAJ_ZAPNUM  := _cZapNum
	ZAJ->ZAJ_IMP	  := 'N'	
	ZAJ->ZAJ_PESO    := _nPeso
	ZAJ->ZAJ_PESOES  := _nPeso
	ZAJ->ZAJ_SEQETQ  := cValToChar(_nSeque)
	ZAJ->ZAJ_PREDES  := _cNumOP
	msunlock()

	//restarea(area)

Return _cNum

// Busca OP da Desossa 
Static Function buscaOPDes(_cCorOri,_cZapNum)

	Local cRet := ""

	_cQuery := "SELECT Z2_NUM"
	_cQuery += " FROM " + retSqlTab('SZ2')
	_cQuery += " WHERE " + retSqlFil('SZ2')
	_cQuery += " AND Z2_CORORI = '" + _cCorOri + "'"
	_cQuery += " AND Z2_CERTIF = '" + _cZapNum + "'"
	_cQuery += " AND Z2_PRIORID = 'T'"
	_cQuery += " AND " + retSqlDel('SZ2')

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	if QRY->(!eof())
		cRet := QRY->Z2_NUM
	endif

Return cRet

Static Function procImp(_nQtd,_cNum,_cSif,_cClassif,_cCertif,_cMens,_cRa,_clasesp)

	Processa({||imprime(_nQtd,_cNum,_cSif,_cClassif,_cCertif,_cMens,_cRa,_clasesp) },"IMPRIMINDO REGISTROS","Realizando impressão das etiquetas...")

Return
/*metodo de impressão de etiquetas*/
static function imprime(_nQtd,_cNum,_cSif,_cClassif,_cCertif,_cMens,_ccRaca,_clasesp)

	//local _nCont := 0
	local _cIp	 := ''

	_cQuery := " SELECT TOP "+str(_nQtd)+"  ZAJ_NUM, ZAJ_IMP, ZAJ_ZAPNUM 
	_cQuery += " FROM  " + retSqlTab('ZAJ')
	_cQuery += " WHERE " + retSqlFil('ZAJ')
	_cQuery += " AND ZAJ_ZAPNUM = '" + _cNum + "' AND ZAJ_IMP = 'N'"
	_cQuery += " AND " + retSqlDel('ZAJ')
	_cQuery += " ORDER BY ZAJ_NUM

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	ZAJ->(DbSetOrder(2))
	ZAJ->(DbGoTop())
	procRegua(TMP->(RecCount()))	
	while TMP->(!eof())
		incproc()
		if ZAJ->(MsSeek(FWxFilial('ZAJ') + TMP->ZAJ_NUM))
			u_geraEtq191(ZAJ->ZAJ_NUM,ZAJ->ZAJ_COD,ZAJ->ZAJ_DESCRI,ZAJ->ZAJ_LADO,ZAJ->ZAJ_DATA,_cSif,_cClassif,_cCertif,_cMens,_cIp,_clasesp,_ccRaca,ZAJ->ZAJ_SEQETQ)
			reclock('ZAJ',.f.)
			ZAJ->ZAJ_IMP := 'S'
			msunlock()
		endif

		TMP->(DbSkip())
	enddo


	_nGerada := geradas(ZAP->ZAP_NUM)
	_nAGerar := aGerar(ZAP->ZAP_NUM) 
	telaimp:refresh()	
	msgbox('Todas as peças foram impressas!',"CONFIRMAÇÃO","INFO")  
return 

/*metodo para contagem de registros de etiquetas já geradas*/
static function geradas(_cNum)

	local _nRegs := 0

	_cQuery := " SELECT ZAJ_NUM, ZAJ_IMP, ZAJ_ZAPNUM 
	_cQuery += " FROM  " + retSqlTab('ZAJ')
	_cQuery += " WHERE " + retSqlFil('ZAJ')
	_cQuery += " AND ZAJ_ZAPNUM = '" + _cNum + "' AND ZAJ_IMP = 'S'"
	_cQuery += " AND " + retSqlDel('ZAJ')
	_cQuery += " ORDER BY ZAJ_NUM

	_cQuery  := ChangeQuery(_cQuery)


	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	while TMP->(!eof())
		_nRegs ++
		TMP->(dbSkip())

	enddo

	telaimp:refresh()
return _nRegs

/*metdodo para Contagem de registros de etiquetas que ainda podem ser geradas*/
static function aGerar(_cNum)

	local _nRegs := 0

	_cQuery := " SELECT ZAJ_NUM, ZAJ_IMP, ZAJ_ZAPNUM 
	_cQuery += " FROM  " + retSqlTab('ZAJ')
	_cQuery += " WHERE " + retSqlFil('ZAJ')
	_cQuery += " AND ZAJ_ZAPNUM = '" + _cNum + "' AND ZAJ_IMP = 'N'"
	_cQuery += " AND " + retSqlDel('ZAJ')
	_cQuery += " ORDER BY ZAJ_NUM

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	while TMP->(!eof())

		_nRegs ++
		TMP->(dbSkip())

	enddo

	telaimp:refresh()
return _nRegs

User Function gf191X()

	local _lOk := .t.

	ZAJ->(DbSetOrder(8)) 
	ZAJ->(DbGoTop())
	if ZAJ->(MsSeek(FWxFilial('ZAJ') + ZAP->ZAP_NUM))// .or. ZAP->ZAP_QTDREG > 0
		FWAlertError('Os registros de carcaças já foram gerados, é necessário realizar a baixa total dos registros! Impossivel excluir!', 'ERRO!')
	else         
		if !msgbox('Deseja realmente excluir este certificado? Continua(S/N)','EXCLUSÃO DE CERTIFICADO','YESNO')
			_lOk := .f.
		endif

		if _lOk
			reclock('ZAP',.f.)
			dbdelete()
			msunlock()
		endif
	endif

Return

/*metodo para alterar o certificado*/
User Function gf191A()

	Local nCont
	lOk := .f.

	DEFINE MSDIALOG oDlg TITLE 'Certificados' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("ZAP",.f.)

	/*vetor com o nome dos campos que podem ser alterados*/ 
	_aAlter := {'ZAP_CERT','ZAP_SIF','ZAP_FORN','ZAP_LOJA','ZAP_DOC','ZAP_SERIE','ZAP_DATAP','ZAP_CLASSI','ZAP_DATAR','ZAP_OBS'}

	obj := MsMGet():New("ZAP" ,ZAP->(RECNO()),4   ,     ,     ,     ,          ,aPosObj[1],  _aAlter       ,,,,,oDlg,,,.F. )
	// inst.  obj.     met. alias,registro      ,oper,p.res,p.res,p.res,vet.campos,vet.coord.,vet.campos.alt, ,
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gf191Ok()},{||gf191nOk()})

	If lOk
		begin transaction
			recLock('ZAP',.f.)
			For nCont := 1 To FCount()
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,FWxFilial("ZAP"))
				Else
					FieldPut(nCont,M->&(FIELDNAME(nCont)))
				Endif
			Next nCont
			MsUnLock()
		end transaction
	endif

return

/*função de baixa de etiquetas*/
User Function gf191B()

	Private _cCod := space(11) 
	//Private _cLocal := space(02) 
	_Mens1 := ''
	_Mens2 := ''
	cont := 0

	DEFINE MSDIALOG oDlgR TITLE 'Baixa de etiquetas' from 000,000 To 170,500 OF oMainWnd PIXEL

	@ 010,013 SAY  'Codigo de Barras:' Object oSay2
	@ 010,075 GET _cCod PICTURE "@!"   SIZE 60,11  valid Cons() Object oC   
	oFont      := tFont():New("courier new",,-20,,.t.,,,,)
	oSayD1  := tSay():New(30,10,{|| _Mens1 },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
	oSayD2  := tSay():New(30,10,{|| _Mens2 },oDlgR,,oFont,,,,.T.,CLR_HRED,CLR_HRED,200,35)
	@ 010,60 SAY cont
	oC:setfocus()  
	@ 60,220 BMPBUTTON TYPE 1 ACTION odlgR:end() Object Obtn1

	ACTIVATE MSDIALOG oDlgR CENTERED 

return 

/*Metodo para validação do codigo de barras da etiqueta de terceiro*/
Static Function Cons()

	if empty(_cCod)
		return .t.
	endif

	ZAJ->(dbsetorder(2))
	if ZAJ->(MsSeek(FWxfilial('ZAJ') + alltrim(_cCod) ))
		if empty(ZAJ->ZAJ_DATAS) .and. !empty(ZAJ->ZAJ_ZAPNUM)
			Sinv(1)
			_cMens1 := alltrim(ZAJ->ZAJ_NUM) + '  ' + alltrim(ZAJ->ZAJ_COD) + '  ' + alltrim(ZAJ->ZAJ_DESCRI) + '  baixada!'
			_cMens2 := ''
			reclock('ZAJ',.f.)
			DbDelete()
			msunlock()
		elseif empty(ZAJ->ZAJ_ZAPNUM)
			Sinv(2)
			_cMens2 := 'Esta peça não é de terceiro, impossivel realizar a baixa!'
			_cMens1 := ''
		else
			Sinv(2)
			_cMens2 := 'Peça já se encontra fora de estoque!'
			_cMens1 := ''
		endif
	else
		Sinv(2)
		_cMens1 := ''
		_cMens2 := 'Já foi realizada a baixa desta etiqueta!'
	endif

	oSayD1:SetText(_cMens1)
	oSayD2:SetText(_cMens2)

	oC:setfocus()

	oDlgR:refresh()

	_cCod := space(11)

	oC:setfocus()

return .f.

static function Sinv(t)                                                           //Serve para executar o som ao ler caixa ou peça 
	do case
		case t = 1
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)
		case t = 2
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
		case t = 3
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE3.WAV',0) 
	endcase

return

/*função para gerar a etiqueta*/
User Function geraEtq191(_cNum,_cProd,_cDescri,_cLado,_dDataP,_cSif,_cClassif,_cCertif,_cMens,_cIp,_clasesp,_ccRaca,_cSeque)

	_Font01 	:= "60,60"
	_Font02 	:= "70,70"
	_nCont	:=	1 
	_nPeso   := 0.00

	ZAJ->(dbSetOrder(2))
	ZAJ->(dbGoTop())
	if ZAJ->(MsSeek(FWxFilial('ZAJ') + alltrim(_cNum)))

		SZK->(dbSetOrder(4))
		SZK->(dbGoTop())
		if SZK->(MsSeek(FWxFilial('SZK') + alltrim(ZAJ->ZAJ_NUMAM) + alltrim(ZAJ->ZAJ_CONTRO)))

			_ZK_COBGOR 	:= SZK->ZK_COBGOR
			_ZK_DENT   	:= SZK->ZK_DENT
			_ZK_CONTROL := SZK->ZK_CONTROL
			_ZK_PROGRAM := SZK->ZK_PROGRAM
			_ZK_RASTRO	:= SZK->ZK_RASTRO
			_ZK_OBS		:= SZK->ZK_OBS
			_ZK_CATEG	:= SZK->ZK_CATEG
			_ZK_CLASSIF	:= SZK->ZK_CLASSIF
			_ZK_CLASESP	:= SZK->ZK_CLASESP

			dAbate := GetAdvFVal('SZG','ZG_DATA',FWxFilial('SZG')+ SZK->ZK_NUMAM,1)

		endif 


	/************************Impressão das Etiquetas***************************/

	if empty(_cIp)
		_cIpImp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM')+'ITRC1',1))
		//_cIpImp := alltrim(POSICIONE('ZAM',1,FWxFilial('ZAM')+'DTI03','ZAM_IP'))
	else
		_cIpImp := _cIp		
	endif

	//conout(_cIp)
	//conout(_cIpImp)

	MSCBPRINTER('S600','IP',,,,,_cIpImp) 

	//MSCBPRINTER('S600','IP',,,,,'10.11.20.27')
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,6)	

	MSCBBOX(01,16,60,33)
	//MSCBSAY(010,145,SUBSTR(_cNum,8,3)	,"N","0","200,200")
	MSCBSAY(010,145,_cSeque,"N","0","200,200")

	//Lado
	MSCBSAY(50, 17,_cLado,"N","0","100,100")

	//Codigo de Barras
	MSCBSAYBAR(08,17,_cNum,"N","C",10,,.t.,,,2,2,.t.)

	MSCBBOX(02,50,39,70)
	// inserir campo aqui ZK_CLASESP

	MSCBSAY(03, 52,'COD.',"N","E","8,8")
	MSCBSAY(13, 52,_cProd,"N","0",_Font02)

	MSCBSAY(03, 62,_cDescri,"N","0",_Font01)

	MSCBBOX(02,72,60,77)
	MSCBSAY(03,73, _cSif + strtran(dtoc(_dDataP),'/','') +'0000',"N","E","8,8")

	MSCBBOX(02,79,30,89)
	MSCBSAY(03,80,'SIF',"N","E","8,8")
	MSCBSAY(07,84,_cSif, "N","E","28,15")

	MSCBBOX(32,79,60,89)
	MSCBSAY(33,80,'Data Prod.',"N","E","8,8")
	MSCBSAY(35,84,dtoc(_dDataP),"N","E","28,15")

	nL := 125

	MSCBBOX(02,93,60,98)
	MSCBSAY(03,94, 'CERTIF.:'+ _cCertif ,"N","E","8,8")

	MSCBBOX(02,100,60,109)
	MSCBSAY(03,101,'Prod. de Terceiro',"N","0",_Font01)// 
    /* 2 - Raça (  Raça = Angus ) = Semelhante ao ZK_RACA ( ZA8 )  */
	MSCBBOX(02,110,60,120)

	//MSCBSAY(03,111,_cMens,"N","0",_Font01) Retirada esta linha
	Private _cRaca := GetAdvFVal('ZA8','ZA8_DESC',FWxFilial('ZA8')+alltrim('004'),1)
	If !empty(_cMens)
		MSCBSAY(03,111,_cMens,"N","0",_Font01)
	Elseif !empty(_cRaca)
		MSCBSAY(03,111,_cRaca,"N","0",_Font01) 
	Endif

	MSCBSAY(10,125,_cClassif,"N","0","180,300")
	IF _clasesp = '1' .and. ZK_DENT > 4
		MSCBSAY(10,146,'UY',"N","0","180,300")
	elseif _clasesp = '1' .and. ZK_DENT <= 4
		MSCBSAY(10,146,'CN',"N","0","180,300")
	Endif
	Endif

	//Codigo de Barras - Solicitado inclusão por Henrique dia 29/06/21
	MSCBSAYBAR(08,168,_cNum,"N","C",10,,.t.,,,2,2,.t.)
	MSCBSAYBAR(08,187,_cNum,"N","C",10,,.t.,,,2,2,.t.)
	MSCBSAYBAR(08,207,_cNum,"N","C",10,,.t.,,,3,3,.t.)
	MSCBSAYBAR(45,170,_cNum,"R","C",10,,.t.,,,3,3,.t.)

	//****************************  FIM  *****************************************
	MSCBSAY(13,285,"DTI","N","0","100,190")

	MSCBEND()
	MSCBCLOSEPRINTER()

	sleep(750)

return

User Function gf191G()

	Local _cCert 	 := ZAP->ZAP_CERT
	Local _cClassif := ZAP->ZAP_CLASSI
	Local _cSif		 := ZAP->ZAP_SIF

	Private aCampos := {}
	Private lInverte	:= .f.
	Private cMark    	:= GetMark()  
	Private oMark
	Private marc      := .f.

	_aArqTrb := {}

	procArq(ZAP->ZAP_NUM,ZAP->ZAP_CERT)

	dbselectarea('ARQ')

	ARQ->(dbgotop())
	DEFINE MSDIALOG oDlg TITLE "Gerenciamento de Etiquetas" From 9,0 To 400,1000 PIXEL
	oMark := MsSelect():New("ARQ","ZAJ_OK","",aCampos,@lInverte,@cMark,{17,1,160,500},,,,,) 
	oMark:bMark := {| | Disp()}

	TButton():New(170, 020, "Marcar Todos"  	, oDlg,{|| gf191Sel(1)   							},40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 070, "Desmarcar Todos"	, oDlg,{|| gf191Sel(2)   							},45,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 120, "Baixar"        	, oDlg,{|| procBx()		 							},40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 170, "Imprimir"       	, oDlg,{|| gf191Rimp(_cCert,_cClassif,_cSif)	},40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 390, "Sair"            , oDlg,{|| oDlg:end()	   						},40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED

	ARQ->(dbCloseArea())

	u_arqtrb("FechaTodos",,,, @_aArqTrb)

return  

Static Function Disp()

	RecLock("ARQ",.F.)
	if Marked("ZAJ_OK")
		ARQ->ZAJ_OK := cMark
	else          
		ARQ->ZAJ_OK := ""
	endif             
	msunlock() 
	oMark:oBrowse:Refresh()	
Return .t.  


Static Function gf191Sel(_nOp)
	ARQ->(dbgotop())   

	while ARQ->(!eof())
		if _nOp = 1
			reclock('ARQ',.f.)
			ARQ->ZAJ_OK := cMark
			msunlock()
		elseif _nOp = 2
			reclock('ARQ',.f.)
			ARQ->ZAJ_OK := ""
			msunlock()
		endif

		ARQ->(dbskip())
	enddo

	ARQ->(dbgotop())

	oMark:oBrowse:Refresh()	
return .t.

Static Function procBx()

	Processa({||gf191Bx() },"BAIXANDO REGISTROS","Realizando a baixa de registros...")

Return

Static Function gf191Bx()

	ZAJ->(dbsetorder(2))
	ARQ->(dbgotop()) 

	ProcRegua(ARQ->(RecCount()))

	while ARQ->(!eof())
		if !empty(ARQ->ZAJ_OK)
			incproc('Processando Carcaça n.: ' + ARQ->ZAJ_NUM)
			marc := .t.

			ZAJ->(DbSetOrder(2))
			if ZAJ->(MsSeek(FWxfilial('ZAJ')+ARQ->ZAJ_NUM))
				if !empty(ZAJ->ZAJ_DATAS) .or. !empty(ZAJ->ZAJ_HORAS)
					ARQ->(DbSkip())
					loop
				endif
				reclock('ZAJ',.f.)
				dbdelete()
				msunlock()
			endif

		endif
		ARQ->(dbskip())
	enddo

	if marc
		msgbox('Todas as peças selecionadas foram baixadas!',"CONFIRMAÇÃO","INFO")
	else
		msgbox('Não houveram peças selecionadas!',"OPERACAO NULA",'INFO')
	endif

	//oDlg:end()

	ARQ->(DbGoTop())
	gf191sel(2)
	oMark:oBrowse:Refresh()	
	oDlg:Refresh()

return

Static Function gf191Rimp(_cCertif,_cClassif,_cSif)
	local _cIp := ''

	ZAJ->(dbsetorder(2))
	ARQ->(dbgotop()) 

	ProcRegua(ARQ->(RecCount()))

	while ARQ->(!eof()) 
		if !empty(ARQ->ZAJ_OK)
			incproc('Processando Carcaça n.: ' + ARQ->ZAJ_NUM)
			marc := .t.

			ZAJ->(DbSetOrder(2))
			if ZAJ->(MsSeek(FWxfilial('ZAJ')+ARQ->ZAJ_NUM))
				if !empty(ZAJ->ZAJ_DATAS) .or. !empty(ZAJ->ZAJ_HORAS)
					ARQ->(DbSkip())
					loop
				endif

				u_geraEtq191(ZAJ->ZAJ_NUM,ZAJ->ZAJ_COD,ZAJ->ZAJ_DESCRI,ZAJ->ZAJ_LADO,ZAJ->ZAJ_DATA,_cSif,_cClassif,_cCertif,_cIp,,,,ZAJ->ZAJ_SEQETQ)

				reclock('ZAJ',.f.)
				ZAJ->ZAJ_IMP := 'S'
				msunlock()
			endif

		endif
		ARQ->(dbskip())
	enddo

	if marc
		msgbox('Todas as peças selecionadas foram impressas!',"CONFIRMAÇÃO","INFO")  
	else
		msgbox('Não houveram peças selecionadas para impressão!',"OPERACAO NULA",'INFO')  
	endif	

	//oDlg:end()  

	ARQ->(DbGoTop())
	gf191sel(2)
	oMark:oBrowse:Refresh()	
	oDlg:Refresh()

return

Static Function procArq(_cNum,_cCert)

	Processa({||criaArq(_cNum,_cCert) },"SELECIONANDO REGISTROS","Realizando processamento...")

return

Static Function criaArq(_cNum,_cCert)

	_cQuery := " SELECT ZAJ_NUM, ZAJ_COD, ZAJ_DESCRI, ZAJ_DATA, ZAJ_IMP, ZAJ_ZAPNUM, ZAJ_SEQETQ
	_cQuery += " FROM  " + retSqlTab('ZAJ')
	_cQuery += " WHERE " + retSqlFil('ZAJ')
	_cQuery += " AND ZAJ_ZAPNUM = '" + _cNum + "' AND ZAJ_DATAS = '' AND ZAJ_HORAS = ''
	_cQuery += " AND " + retSqlDel('ZAJ')
	_cQuery += " ORDER BY ZAJ_NUM

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	TMP->(DbGoTop())
	//cArq  := CriaTrab( Nil, .F. ) 

	_aArqTrb    := {} 
	aStru := {}
	AADD(aStru,{"ZAJ_OK"  	 ,"C"	,02	,0	})
	AADD(aStru,{"ZAJ_NUM"  	 ,"C"	,10	,0	})
	AADD(aStru,{"ZAJ_COD"	 ,"C"	,06 ,0  })
	AADD(aStru,{"ZAJ_DESCRI" ,"C"	,20	,0	})
	AADD(aStru,{"ZAJ_DATA"	 ,"D"	,08	,0	})
	AADD(aStru,{"ZAJ_IMP"	 ,"C"	,01	,0	})
	AADD(aStru,{"ZAJ_ZAPNUM" ,"C"	,10	,0	})
	AADD(aStru,{"ZAP_CERT"	 ,"C"	,11	,0	})
	AADD(aStru,{"ZAJ_SEQETQ" ,"C"	,3	,0	})

	//dbcreate(cArq,aStru)        //Cria a estrutura do vetor no TMP criado 
	//If Select('ARQ')<>0   		//Se um tmp com alias TMP existir, fecha-o
	//	ARQ->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArq,"ARQ", .F. , .F. )  //Manda usar o TMP     
	//ARQ->(DbGoTop())

	If Select('ARQ')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		ARQ->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "ARQ", aStru, {}, @_aArqTrb)

	procregua(TMP->(RecCount()))

	while TMP->(!eof())

		incproc()

		DbSelectArea('ARQ')
		reclock('ARQ',.t.)
		ARQ->ZAJ_NUM 		:= TMP->ZAJ_NUM
		ARQ->ZAJ_COD		:= TMP->ZAJ_COD
		ARQ->ZAJ_DESCRI 	:= TMP->ZAJ_DESCRI
		ARQ->ZAJ_DATA		:= stod(TMP->ZAJ_DATA)
		ARQ->ZAJ_IMP		:= TMP->ZAJ_IMP
		ARQ->ZAJ_ZAPNUM		:= TMP->ZAJ_ZAPNUM
		ARQ->ZAP_CERT		:= _cCert	
		ARQ->ZAJ_SEQETQ		:= TMP->ZAJ_SEQETQ
		msunlock()

		TMP->(DbSkip())

	enddo

	aCampos := {}

	AADD(aCampos,{"ZAJ_OK"  		,, "Ok?"			,"@!"   })
	AADD(aCampos,{"ZAJ_NUM"  		,, "Cod.Barras"		,"@!"   })
	AADD(aCampos,{"ZAJ_COD"     	,, "Produto"   		,"@!"   })
	AADD(aCampos,{"ZAJ_DESCRI"    	,, "Descricao"		,"@!"   })
	AADD(aCampos,{"ZAJ_DATA"    	,, "Dt.Prod."		,"@!"   })
	AADD(aCampos,{"ZAJ_IMP"    		,, "Impresso?"		,"@!"   })
	AADD(aCampos,{"ZAP_CERT"    	,, "Certificado"	,"@!"   })
	AADD(aCampos,{"ZAJ_SEQETQ"    	,, "Sequencial"		,"@!"   })

	dbselectarea('ARQ')

	ARQ->(dbgotop())


return

////Funções para atualização do mBrowse////
Static Function AutoRefresh(oDlg)
	Local oTimer
	oTimer := TTimer():New(2, {|| PBrow() }, oDlg)
	oTimer:Activate()
Return .T.

////Funções para atualização do mBrowse////
Static Function PBrow()
	oBrowse := getObjBrow()
	oBrowse:default()
	oBrowse:refresh()
Return
