#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
±±ºPrograma  ³DTI12     ºAutor  ³Mauricio Lopes Roehrs ?Data ? 27/08/16   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ³Realiza  alteração da datas de vencimentos dos titulos de umº±?
±±?         ³cliente com base na data de emissão do titulo                º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±ºUso       ³Financeiro                                                  º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/

User Function DTI12()
	Local _aArqTrb      := {}
	Private _aTexto 	:= {}
	Private _cTexto 	:= ''
	Private aTela    	:= {}
	Private aStru    	:= {}
	Private aCampos  	:= {}
	Private cArq
	Private cMark    	:= GetMark()
	Private oMark
	Private marc      	:= .f.
	Private lInverte	:= .f.
	Private aButtons  	:= {}
	Private _lConf    	:= .f.
	Private lOk			:= .F.
	Private cPerg  		:= "DTI12"
	Private _dDtVcto   	:= date()

	aObjects            := {}
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	if !pergunte(cPerg,.t.)
		return
	endif

	Processa({||montabrow()} ,"PROCESSAMENTO DE REGISTROS","montando tela com os clientes...")

	//bloco para ajustar tamanho da tela conforme a resolução do monitor.
	pixTela1 := 0
	pixTela2 := 0

	if aSizeAut[6] >= 696
		pixTela1 := aSizeAut[6] - 400 // 500 / 370
	else
		pixTela1 := aSizeAut[6] - 350 // 450 / 298
	endif

	if aSizeAut[5] >= 1538 
		pixTela2 := aSizeAut[5] - 780 //780
	else
		pixTela2 := aSizeAut[5] - 655 //655
	endif

	DbSelectArea('TMP')
	TMP->(dbGoTop())
	DEFINE MSDIALOG oDlg TITLE 'Gerenciamento de Desbloqueio de Clientes' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	//oMark  := MsSelect():New("TMP","OK","",aCampos,@lInverte,@cMark,{aSizeAut[7],01,pixTela1,pixTela2})  //275 298-655 assim estava desconfigurada os itens da tela
	oMark  := MsSelect():New("TMP","OK","",aCampos,@lInverte,@cMark,{30,01,pixTela1,pixTela2})  //275 298-655
	oMark:bMark := {| | Disp()}

	Aadd( aButtons, {"MARCATODOS", {|| MarkAll(1)}, "Marca Todos", "Marca Todos" , {|| .T.}} )
	Aadd( aButtons, {"DESMARCTDS", {|| MarkAll(2)}, "Desmarca Todos", "Desmarca Todos" , {|| .T.}} )
	Aadd( aButtons, {"APONTAVCTO", {|| apontaVct()},"Informa Vncto.", "Informa Vncto." , {|| .T.}} )

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||verifVct()},{||lOk := .f., oDlg:End()},,@aButtons))

	TMP->(DbCloseArea())

	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FECHATODOS",,,, @_aArqTrb)
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

Static Function montabrow()
	Local _aArqTrb    := {}

	aadd(aCampos,{"OK"    	,,"OK" 	     		 ,"@!"})
	aadd(aCampos,{"TITULO"  ,,"Titulo"	 		 ,"@!"})
	aadd(aCampos,{"EMISSAO"	,,"Dt. de Emissao"   ,"99/99/99"})
	aadd(aCampos,{"VCTO"	,,"Dt. de Vcto."     ,"99/99/99"})
	aadd(aCampos,{"VCTREAL" ,,"Dt. de Vcto. Real","99/99/99"})
	aadd(aCampos,{"CODCLI"  ,,"Cod. Cliente"     ,"@!"})
	aadd(aCampos,{"LOJA"    ,,"Loja"             ,"@!"})
	aadd(aCampos,{"NOMECLI" ,,"Cliente"          ,"@!"})

	aadd(aStru,{"OK"        , "C",  02,  0,   "@!"         , 'Ok'})
	aadd(aStru,{"TITULO"	, "C",  09,  0,   "@!"         , 'Titulo'})
	aadd(aStru,{"EMISSAO"  	, "D",  08,  0,   "99/99/99"   , 'Dt. Emissao'})
	aadd(aStru,{"VCTO"      , "D",  08,  0,   "99/99/99"   , 'Dt. de Vcto.'})
	aadd(aStru,{"VCTREAL"   , "D",  08,  0,   "99/99/99"   , 'Dt. de Vcto. Real'})
	aadd(aStru,{"CODCLI"    , "C",  06,  0,   "@!"         , 'Cod. Cliente'})
	aadd(aStru,{"LOJA"      , "C",  02,  0,   "@!"         , 'Loja'})
	aadd(aStru,{"NOMECLI"   , "C",  20,  0,   "@!"         , 'Cliente'})

	//dbcreate(cArq,aStru)
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	//DbSelectArea('TMP')

	If Select('TMP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif
	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	filtraCli()

	TMP->(DbGotop())

	QRY->(dbGoTop())
	Procregua(recCount())
	While QRY->(!eof())

		IncProc('Processando dados do titulo n.? ' + QRY->E1_NUM)

		reclock('TMP',.t.)
		TMP->TITULO  := QRY->E1_NUM
		TMP->EMISSAO := stod(QRY->E1_EMISSAO)
		TMP->VCTO    := stod(QRY->E1_VENCTO)
		TMP->VCTREAL := stod(QRY->E1_VENCREA)
		TMP->CODCLI  := QRY->E1_CLIENTE
		TMP->LOJA    := QRY->E1_LOJA
		TMP->NOMECLI := QRY->E1_NOMCLI
		msunlock()

		QRY->(DbSkip())
	enddo

	TMP->(DbGoTop())

return

//Função que chama a telinha de alteração dos vales-transporte
Static Function apontaVct()
	local _Campo2 := date()

	DEFINE MSDIALOG oDlg2 TITLE 'Informe a Data de Vencimento' from 000,000 To 130,200 OF oMainWnd PIXEL

	@ 015,002 SAY  'Dt. Vencto' Object oSay1
	@ 001,005 MSGET _Campo2 VAR _dDtVcto SIZE 35,11 PICTURE '99/99/99' VALID !Vazio() OF oDlg2

	@ 040,040 BMPBUTTON TYPE 1 ACTION cnfDt() Object Obtn1

	ACTIVATE MSDIALOG oDlg2 CENTERED

return

Static Function filtraCli()

	_cQuery := " SELECT E1_NUM, E1_EMISSAO, E1_VENCTO, E1_VENCREA, E1_CLIENTE, E1_LOJA, E1_NOMCLI
	_cQuery += " FROM " + retSqlTab("SE1")
	_cQuery += " WHERE " + retSqlFil("SE1")
	_cQuery += " AND E1_EMISSAO BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "'"
	_cQuery += " AND E1_PREFIXO = '" + cFilAnt + "'"
	_cQuery += " AND E1_CLIENTE = '" + mv_par01 + "' AND E1_TIPO = 'NF' AND E1_SALDO > 0"
	_cQuery += " AND " + retSqlDel("SE1")
	_cQuery += " ORDER BY E1_NUM, E1_EMISSAO,E1_CLIENTE

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

return

//Função que confirma a inserção
Static Function CnfDt()

	_lConf := .t.

	odlg2:end()
return

Static Function GravVcto()
	Processa({||Gravar()} ,"PROCESSAMENTO DE REGISTROS","Efetivando a alteração da data de vencimento dos titulos selecionados...")
return

Static Function Gravar()

	TMP->(dbGoTop())
	procRegua(RecCount())
	While TMP->(!eof())

		IncProc('Processando dados do Titulo n.? ' + TMP->TITULO)
		If !empty(TMP->OK)
			dbSelectArea('SE1')
			SE1->(dbSetOrder(29))
			SE1->(dbGoTop())
			if SE1->(dbSeek(xFilial('SE1') + alltrim(TMP->TITULO)))

				reclock('SE1',.f.)
				SE1->E1_VENCTO  := _dDtVcto
				SE1->E1_VENCREA := _dDtVcto
				msunlock()

				reclock('TMP',.f.)
				DbDelete()
				msunlock()
			endif
		endif
		TMP->(dbSkip())
	enddo	

	alert('Datas de vencimentos alteradas com sucesso!')
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

Static Function verifVct()

	local _lRet := .f.

	if _lConf
		GravVcto()
		_lRet := .t.
		_lConf := .f.
	else
		alert('Confirme a data de vencimento!')	
	endif

return _lRet
