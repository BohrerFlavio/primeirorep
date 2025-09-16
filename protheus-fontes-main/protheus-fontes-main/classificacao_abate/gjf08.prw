#INCLUDE "rwmake.ch"           
#INCLUDE "totvs.ch"           
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF08     º Autor Giuliano Forgiarini    Data ³  12/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao: Manutenção da tabela SZK: produção do abate                 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF08()

	Private cPerg   := "GJF08"
	Private cCadastro := "Manutenção da Produção do Abate"
	Private aRotina := {}
	Private _cClassif := ""

	_cCodUser  := retCodUsr()

	if alltrim(_cCodUser) = "000024"
		aRotina := { {"Pesquisar","AxPesqui",0,1},;
		{"Visualizar","AxVisual",0,2},;
		{"Alterar Produção","u_gjf08alp",0,3},;
		{"Alterar Valores","u_gjf08altv",0,4},;
		{"Calc. Porc.","u_gjf08lot",0,5}}
	else
		aRotina := { {"Pesquisar","AxPesqui",0,1},;
		{"Visualizar","AxVisual",0,2},;
		{"Alterar Produção","u_gjf08alp",0,3},;
		{"Alterar Valores","u_gjf08altv",0,4}}
	endif

	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "SZK"

	dbSelectArea(cString)
	dbSetOrder(6)

	ord17 := .T.

	Pergunte(cPerg,.T.)

	SetKey(123,{|| Pergunte(cPerg,.T.)}) // Seta a tecla F12 para acionamento dos parametros

	SET FILTER TO SZK->ZK_NUMAM = MV_PAR01 .AND. SZK->ZK_LOTE = MV_PAR02

	mBrowse(6,1,22,75,cString,,) 

	dbSelectArea(cString)

	Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros
Return  

user Function gjf08altv()
	campo9 := CTBCBOX('ZK_BLACK')
	campo8 := ""
	campo7 := ""
	campo6 := 0 
	campo4 := 0
	campo3 := CTBCBOX('ZK_CONFORM')
	campo2 := CTBCBOX('ZK_DENT')
	campo1 := CTBCBOX('ZK_COBGOR')
	valor1 := SZK->ZK_COBGOR
	valor2 := SZK->ZK_DENT
	valor3 := SZK->ZK_CONFORM
	valor4 := SZK->ZK_PRECOBO
	valor5 := SZK->ZK_RACA
	valor8 := SZK->ZK_PROGRAM
	valor9 := SZK->ZK_BLACK

	SZ4->(DbSetOrder(1))
	//if 
	SZ4->(MsSeek(FWxfilial('SZ4')+mv_par01+mv_par02))
	valor6 := SZ4->Z4_NPREN
	valor7 := SZ4->Z4_NPREAD
	//endif

	DEFINE MSDIALOG tela FROM 0,0 TO 320,250 PIXEL TITLE "Alterar Valores"
	@ 001,01 SAY "Gordura:" of tela 
	@ 002,01 SAY "Dentição:" of tela
	@ 003,01 SAY "Conformação:" of tela 
	@ 004,01 SAY "Bonificação:" of tela
	@ 005,01 SAY "Raça:" of tela
	@ 006,01 SAY "Vacas Prenhas:" of tela
	@ 007,01 SAY "Pren. Adiant.:" of tela
	@ 008,01 SAY "Programa:" of tela
	@ 009,01 SAY "Black:" of tela
	//@ 012,48 MSGET campo1 VAR valor1 SIZE 40,10 OF tela PIXEL PICTURE "@E"
	@ 001,06 COMBOBOX valor1 items campo1 SIZE 40,08
	@ 002,06 COMBOBOX valor2 items campo2 SIZE 40,08
	@ 003,06 COMBOBOX valor3 items campo3 SIZE 40,08
	@ 051,48 MSGET campo4 VAR valor4 SIZE 40,10 OF tela PIXEL PICTURE "@E 999.99"
	@ 064,48 MSGET campo5 VAR valor5 SIZE 40,10 OF tela PIXEL PICTURE "@E" F3 "ZA8"
	@ 077,48 MSGET campo6 VAR valor6 SIZE 40,10 OF tela PIXEL PICTURE "@E 999"
	@ 090,48 MSGET campo7 VAR valor7 SIZE 40,10 OF tela PIXEL PICTURE "@E 999"
	@ 103,48 MSGET campo8 VAR valor8 SIZE 40,10 OF tela PIXEL PICTURE "@E" F3 "SZ6"
	@ 009,06 COMBOBOX valor9 items campo9 SIZE 40,08
	@ 140,05 BUTTON botao1 PROMPT "Salvar" OF tela PIXEL ACTION u_gjf08_1()
	@ 140,65 BUTTON botao2 PROMPT "Fechar" OF tela PIXEL ACTION tela:end()
	ACTIVATE MSDIALOG tela CENTERED
Return 

user function gjf08_1()

	if date() = SZK->ZK_DATAABT
		if empty(valor8)
			FWAlertWarning('Utilize o programa 013 para animais sem programa!','ATENÇÃO!')
			campo8:setFocus()
			return
		endif

		ZAJ->(DbSetOrder(1))
		if ZAJ->(MsSeek(FWxfilial('ZAJ') + SZK->ZK_NUMAM + SZK->ZK_CONTROL))
			while ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL   =  FWxfilial('ZAJ') .and. ;
			SZK->ZK_NUMAM   =  ZAJ->ZAJ_NUMAM .and. ;
			SZK->ZK_CONTROL =  ZAJ->ZAJ_CONTRO

				_cDescri := ZAJ->ZAJ_DESCRI

				DbSelectArea('SZ6')
				if ZAJ->ZAJ_CORORI = 'T'
					if valor8 != "008"
						_cDescri := iif(!empty(valor8),GetAdvFVal('SZ6','Z6_DESREDT',FWxfilial('SZ6') + valor8,1),'TRASEIRO')
					else
						_cDescri := iif(!empty(valor8),GetAdvFVal('SZ6','Z6_DESREDT',FWxfilial('SZ6') + "020",1),'TRASEIRO')
					endif
				elseif ZAJ->ZAJ_CORORI = 'D'
					if valor8 != "008"
						_cDescri := iif(!empty(valor8),GetAdvFVal('SZ6','Z6_DESREDD',FWxfilial('SZ6') + valor8,1),'DIANTEIRO')
					else
						_cDescri := iif(!empty(valor8),GetAdvFVal('SZ6','Z6_DESREDD',FWxfilial('SZ6') + "020",1),'DIANTEIRO')
					endif
				elseif ZAJ->ZAJ_CORORI = 'C'
					if valor8 != "008"
						_cDescri := iif(!empty(valor8),GetAdvFVal('SZ6','Z6_DESREDC',FWxfilial('SZ6') + valor8,1),'COSTELA')
					else
						_cDescri := iif(!empty(valor8),GetAdvFVal('SZ6','Z6_DESREDC',FWxfilial('SZ6') + "020",1),'COSTELA')
					endif
				endif

				reclock('ZAJ',.f.)
				ZAJ->ZAJ_DESCRI := _cDescri
				msunlock()

				ZAJ->(DbSkip())
			enddo
		endif

		// Rotina de gravação de log
		u_dtilog(cFilAnt, "GJF08", "Alteração sequencial -> " + SZK->ZK_CONTROL + " | NUMAM -> " + SZK->ZK_NUMAM, "A", SZK->ZK_PROGRAM + "->" + valor8)

		reclock('SZK',.f.)
		SZK->ZK_COBGOR   := valor1
		SZK->ZK_DENT     := valor2
		SZK->ZK_CONFORM  := valor3
		SZK->ZK_PRECOBO  := valor4
		SZK->ZK_RACA     := valor5
		if SZK->ZK_PROGRAM != valor8
			if valor8 != "008"
				SZK->ZK_PROGRAM  := iif(valor8 = "022", "002", iif(valor8 = "021", "006", valor8))
			else
				SZK->ZK_PROGRAM  := "020"
			endif
			SZK->ZK_PROGPGP  := iif(valor8 = "022", "002", iif(valor8 = "021", "006", valor8))
		endif
		//SZK->ZK_BLACK 	 := iif(!(valor8 $ "002/022") .and. valor9 = 'S', "N", valor9)
		SZK->ZK_BLACK 	 := iif(!(valor8 $ "002|022|006|021") .and. valor9 = 'S', "N", valor9)
		msunlock()

		reclock('SZ4',.f.)
		SZ4->Z4_NPREN  := valor6
		SZ4->Z4_NPREAD := valor7
		msunlock()
	else
		FWAlertWarning("Abate não é o atual! Só serão permitidas alterações de preço.", "AVISO!")

		if ZK_PRECOBO != valor4
			// Rotina de gravação de log
			u_dtilog(cFilAnt, "GJF08", "Alteração preço sequencial -> " + SZK->ZK_CONTROL + " | NUMAM -> " + SZK->ZK_NUMAM, "A")
		endif

		reclock('SZK',.f.)
		SZK->ZK_PRECOBO  := valor4
		msunlock()

	endif

	tela:end()
return 

user Function gjf08alp()
	campoA     := CTBCBOX('ZK_DESTINO')
	campoB     := ""
	campoC     := ""//CTBCBOX('ZK_TIPIFI')
	campoD     := ""
	campoE     := CTBCBOX('ZK_CLASESP')
	campoF     := CTBCBOX('ZK_IF')
	valorA     := SZK->ZK_DESTINO 
	valorB     := SZK->ZK_LOCAL
	valorC     := SZK->ZK_CLASSIF
	valorD     := SZK->ZK_MATURA
	valorE     := SZK->ZK_CLASESP
	valorF     := SZK->ZK_IF
	_cClassif  := SZK->ZK_CLASSIF
	_Usr       := RetCodUsr()
	_cOldVA    := valorA
	_cOldVB    := valorB
	_cOldVC    := valorC
	_cOldVD    := valorD
	_cOldVE    := valorE
	_cOldVF    := valorF

	DEFINE MSDIALOG tela2 FROM 0,0 TO 230,250 PIXEL TITLE "Alterar Valores"
	@ 01,01 SAY "Destino:" of tela2
	@ 02,01 SAY "Local:" of tela2
	@ 03,01 SAY "Classif.:" of tela2
	@ 04,01 SAY "Maturação:" of tela2
	if !(alltrim(_Usr) $ '000751')
		@ 05,01 SAY "Class. Esp:" of tela2
		@ 06,01 SAY "IF?:" of tela2
	Endif

	@ 01,06 COMBOBOX valorA items campoA SIZE 40,08
	@ 27,48 MSGET campoB VAR valorB SIZE 20,8 OF tela2 PIXEL PICTURE "@E" F3 "NNR"
	@ 39,48 MSGET campoC VAR valorC F3 "ZP6MVC" SIZE 20,8 OF tela2 PIXEL PICTURE "@E"
	@ 52,48 MSGET campoD VAR valorD SIZE 10,8 OF tela2 PIXEL PICTURE "@E"
	if !(alltrim(_Usr) $ '000751')
		@ 05,06 COMBOBOX valorE items campoE SIZE 40,08 
		@ 06,06 COMBOBOX valorF items campoF SIZE 40,08 
	endif
	@ 98,05 BUTTON botao1 PROMPT "Salvar" OF tela2 PIXEL ACTION u_gjf08_2()
	@ 98,65 BUTTON botao2 PROMPT "Fechar" OF tela2 PIXEL ACTION tela2:end()
	ACTIVATE MSDIALOG tela2 CENTERED
Return 

user function gjf08_2()

	local _aPredesA := {}	// Previsão anterior
	local _aPredesP := {}	// Previsão posterior
	local _nQppeca := 0
	local _nQppeso := 0
	local i := 0
	local nPos := 0

	if _cOldVA = valorA .and. _cOldVB = valorB .and. _cOldVC = valorC .and. _cOldVD = valorD .and. _cOldVE = valorE .and. _cOldVF = valorF
		tela2:end()
		Return
	endif

	SZ2->(DbSetOrder(2))
	ZAJ->(DbSetOrder(1))

	if ZAJ->(MsSeek(FWxFilial('ZAJ') + SZK->(ZK_NUMAM + ZK_CONTROL)))
		while ZAJ->(!eof()) .and. ZAJ->ZAJ_NUMAM = SZK->ZK_NUMAM .and. ZAJ->ZAJ_CONTRO = SZK->ZK_CONTROL
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

			if (_cClassOP <> valorC)
				if GeraOP(valorC, SZK->ZK_PROGRAM, ZAJ->ZAJ_COD, SZK->ZK_NUMAM, alltrim(GetAdvFval('SZ2','Z2_OBS',FWxFilial('SZ2') + ZAJ->ZAJ_PREDES,2)), SZK->ZK_BLACK)
					TMP->(dbGoTop())
					reclock('ZAJ',.f.)
					ZAJ->ZAJ_PREDES := TMP->Z2_NUM
					msunlock()

					nPos := Ascan(_aPredesP, {|x| x[1] = TMP->Z2_NUM})
					if nPos = 0 .and. !empty(TMP->Z2_NUM)
						aadd(_aPredesP, {TMP->Z2_NUM, 1, ZAJ->ZAJ_PESO})
					else
						_aPredesP[nPos,2]++
						_aPredesP[nPos,3] += ZAJ->ZAJ_PESO
					endif
				else
					reclock('ZAJ',.f.)
					ZAJ->ZAJ_PREDES := ""
					msunlock()
					FWAlertWarning('Sem OP para a nova Classificação!','AVISE O PCP!')
				endif
			endif

			ZAJ->(DbSkip())
		enddo
	endif

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

	if alltrim(_Usr) $ '000751'
		reclock('SZK',.f.)	
		SZK->ZK_DESTINO  := valorA
		SZK->ZK_LOCAL    := valorB
		SZK->ZK_CLASSIF  := valorC
		SZK->ZK_CLASSPH  := valorC
		SZK->ZK_MATURA   := valorD
	else
		reclock('SZK',.f.)	
		SZK->ZK_DESTINO  := valorA
		SZK->ZK_LOCAL    := valorB
		SZK->ZK_CLASSIF  := valorC
		SZK->ZK_CLASSPH  := valorC
		SZK->ZK_MATURA   := valorD
		SZK->ZK_CLASESP  := valorE
		SZK->ZK_CLESPAB  := valorE
		SZK->ZK_IF 		 := valorF
	Endif

	if valorA $ 'T/I/R/G'
		SZK->ZK_IF = 'S'
	endif

	msunlock()

	u_dtilog(cFilAnt, "GJF08", "Reclassificação manual do abate " + alltrim(mv_par01), "R")
	tela2:end()
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

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP"

	//verifica se houve retorno na query
    Count to nCount

    If nCount > 0
        Return .T.
    endif

return .F.

user Function gjf08lot()

	if !Pergunte(cPerg,.T.)
		return .f.
	endif

	if msgbox('Tem certeza de que voce quer alterar os valores Selecionados nos Parâmetros ?','OPERAÇÃO DE ALTERAÇÃO DEFINITIVA!','YESNO')

		Private _nEntrada := ''
		Private _nSaida   := ''
		Private _nPecarc1 := ''
		Private _nPecarc2 := ''
		Private _nPetotal := ''

		if empty(mv_par01) 
			msgbox('Campo Aviso Em branco ','OPERAÇÃO INVÁLIDA!','STOP')
			return
		elseif empty(mv_par02)
			msgbox('Campo LOTE em branco ','OPERAÇÃO INVÁLIDA!','STOP')
			return
		elseif empty(mv_par03)
			msgbox('Campo Fórmula Em branco ','OPERAÇÃO INVÁLIDA!','STOP')
			return
		endif

		DbSelectArea('SZK') 
		SZK->(DbSetOrder(5))
		SZK->(DbGoTop())
		SZK->(MsSeek(FWxfilial('SZK')+mv_par01+mv_par02))

		ProcRegua(SZK->(RecCount()))

		_cCONT:=0
		while SZK->(!eof()) .AND. FWxfilial('SZK') = SZK->ZK_FILIAL .AND.;
		SZK->ZK_NUMAM = mv_par01 .and. SZK->ZK_LOTE = mv_par02

			incproc()

			_nPecarc1 :='SZK->ZK_PECARC1'+mv_par03
			_nPecarc2 :='SZK->ZK_PECARC2'+mv_par03
			_nPetotal :='SZK->ZK_PETOTAL'+mv_par03

			reclock('SZK',.f.)
			SZK->ZK_PECARC1 :=  &_nPecarc1
			SZK->ZK_PECARC2 :=  &_nPecarc2
			SZK->ZK_PETOTAL :=  &_nPetotal
			msunlock()
			SZK->(DbSkip())
		enddo
	else	
		return .f.
	endif

return
