#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF97   º Autor ³ Giuliano Forgiarini  º Data ³  13/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de estocagem de caixas de PA                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF97()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio    "
	Local cDesc2         := "de estocagem de produtos acabados rastreados, de forma"
	Local cDesc3         := "a identificar a localização física, de denominação do "
	Local titulo       	 := "R8 - ESTOCAGEM DE PA"
	Local nLin           := 80
	Local Cabec1         := "     Localização                                 Numero       Peso    Quant.      Localiz.         Peça        Data        Data         "
	Local Cabec2         := "          Dados do Produto Acabado               Caixas      Liquido  Peças        Fisica         Derivada   Embalagem    Abate       " 
	Local aOrd 			 := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "GJF97" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg      	 := "GJF97"	
	Private cbcont     	 := 00
	Private CONTFL     	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "GJF97" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    	 := 0.00
	Private TotPeso    	 := 0.00
	Private _cGrpMds     := GETMV('MV_GRPMDS')
	Private _cGrpPorc 	 := GetMV('MV_GRPPORC')
	Private _cGrpChar 	 := GetMV('MV_GRPCHRQ')
	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	IF (mv_par11 = 1)
		cQuery := "SELECT Z8_COD, COUNT(Z8_COD) AS CAIX, SUM(Z8_QUANT) AS QUANT, SUM(Z8_PESO) AS PESO, SUM(Z8_PESOBR) AS PESOBR, Z8_LOCAL, Z8_DATAP, B1_DESC, B1_CORORI, Z8_NUMPREV, Z8_PREDES" + iif(mv_par10 = 1,", ZU_LOTEUA, ZU_SHIPPIN","")
	ELSEIF (mv_par11 = 2)
		cQuery := "SELECT Z8_COD, COUNT(Z8_COD) AS CAIX, SUM(B1_QTBCAIX) AS QUANT, SUM(Z8_PESO) AS PESO, SUM(Z8_PESOBR) AS PESOBR, Z8_LOCAL, Z8_DATAP, B1_DESC, B1_CORORI, Z8_NUMPREV, Z8_PREDES" + iif(mv_par10 = 1,", ZU_LOTEUA, ZU_SHIPPIN","")
	ENDIF

	cQuery += " FROM " + retSqlTab("SZ8")
	cQuery += " INNER JOIN " + retSqlTab("SB1") + " ON (B1_COD = Z8_COD)"
	// Se precisa mostrar somente produtos com lote dos EUA
	if mv_par10 = 1
		cQuery += " INNER JOIN"  + RetSqlTab("SZU") + " ON (Z8_NUMPREV = ZU_NUM)"
	endif
	// Se precisa filtrar por aviso de matança, une com a SZ2
	if !empty(mv_par04)
		cQuery += " INNER JOIN"  + RetSqlTab("SZ2") + " ON (Z8_PREDES = Z2_NUM AND Z2_DATAABT = '" + DTOS(mv_par04) + "')"
	endif
	cQuery += " WHERE Z8_FIL = '" + cFilAnt + "' AND " + retSqlFil("SB1") + " AND "
	// Se precisa mostrar somente produtos com lote dos EUA
	if mv_par10 = 1
		cQuery += RetSqlFil("SZU") + " AND "
		cQuery += " LEN(ZU_LOTEUA) <= 16 AND "
		cQuery += RetSQLDel('SZU') + " AND "
	endif
	// Se precisa filtrar por aviso de matança, une com a SZ2
	if !empty(mv_par04)
		cQuery += RetSqlFil("SZ2") + " AND "
	endif
	cQuery += " (B1_TIPO = 'PA' OR B1_TIPO = 'PR') "
	if !empty(mv_par01) .and. !empty(mv_par02)
		cQuery += " AND (Z8_COD BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "')"
	endif
	if !empty(mv_par03)
		cQuery += " AND Z8_LOCAL = '" + mv_par03 + "'"
	endif
	cQuery += " AND (Z8_DATAP BETWEEN '" + DTOS(mv_par07) + "' AND '" + DTOS(mv_par08) + "')"
	cQuery += " AND ((Z8_DATAE = ' ' AND Z8_DATAS = ' ' AND Z8_ITEM = ' ' AND Z8_HORAS = ' ' AND Z8_PREPED = ' ' AND Z8_PRECAR = ' ')"
	cQuery += " OR (Z8_PRECAR IN ('SEQUEST','COLETA'))) AND "
	cQuery += retSqlDel('SZ8') + " AND " + retSqlDel('SB1') + iif(!empty(mv_par04), " AND " + RetSQLDel('SZ2'), "") // Se precisa filtrar por aviso de matança, une com a SZ2
	// Se precisa mostrar somente produtos com lote dos EUA
	if mv_par10 = 1
		cQuery += " GROUP BY ZU_SHIPPIN, ZU_LOTEUA, Z8_PREDES, Z8_LOCAL, Z8_COD, Z8_DATAP, B1_DESC, B1_CORORI, Z8_NUMPREV"
		cQuery += " ORDER BY ZU_SHIPPIN, ZU_LOTEUA, Z8_PREDES, Z8_LOCAL, Z8_COD, Z8_DATAP"
	else
		cQuery += " GROUP BY Z8_PREDES, Z8_LOCAL, Z8_COD, Z8_DATAP, B1_DESC, B1_CORORI, Z8_NUMPREV"
		cQuery += " ORDER BY Z8_PREDES, Z8_LOCAL, Z8_COD, Z8_DATAP"
	endif

	cQuery := ChangeQuery(cQuery)

	if mv_par05 = 4
		Cabec2 := "          Dados do Produto Acabado               Caixas      Liquido  Peças        Fisica         Derivada   Embalagem    Estufa      " 
	endif

	// ************Modificação
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("TEMP") != 0
		TEMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TEMP"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ8')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local _TotCaix := 0.00
	Local _TotPesL := 0.00
	Local _TotPesB := 0.00
	Local _cLocal  := ''
	//Local _cRastro := ''
	Local _cPeca   := ''
	Local _cLote   := "_"
	Local _aShipM  := {}
	Local _nPos	   := 0
	Local i 	   := 0
	Local _aTotSM  := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TEMP->(dbGoTop())

	TEMP->(SetRegua(RecCount()))

	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif 

	While TEMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxFilial('SB1') + TEMP->Z8_COD,1)
		if mv_par05 = 1//se for desossa
			if (_cGrupo $ _cGrpMds) .or. (_cGrupo $ _cGrpPorc) .or. (_cGrupo $ _cGrpChar)
				TEMP->(dbSkip())
				loop
			endif
		elseif mv_par05 = 2// se for miudos
			if !(_cGrupo $ _cGrpMds)
				TEMP->(dbSkip())
				loop
			endif
		elseif mv_par05 = 3 //se for porcionados
			if !(_cGrupo $ _cGrpPorc)
				TEMP->(dbSkip())
				loop
			endif
		elseif mv_par05 = 4 //se for charque
			if !(_cGrupo $ _cGrpChar)
				TEMP->(dbSkip())
				loop
			endif
		endif

		if mv_par10 = 1
			if _cLote != TEMP->ZU_LOTEUA
				@nlin,01 psay replicate('=', limite)
				nlin++
				@nlin,05 psay "Lote EUA -> " + alltrim(TEMP->ZU_LOTEUA) + iif(!empty(TEMP->ZU_SHIPPIN), " | Shipping Mark -> " + alltrim(TEMP->ZU_SHIPPIN), "")
				_cLote := TEMP->ZU_LOTEUA

				if !empty(TEMP->ZU_SHIPPIN)
					_nPos := aScan(_aShipM,{|aVal| aVal = TEMP->ZU_SHIPPIN})
					if _nPos = 0
						aadd(_aShipM, TEMP->ZU_SHIPPIN)
					endif
				endif

				nlin++
				@nlin,01 psay replicate('=', limite)
				nlin++
			endif
		endif

		if _cLocal <> TEMP->Z8_LOCAL
			@nlin,005 psay 'Camara: ' + TEMP->Z8_LOCAL 
			_cLocal := TEMP->Z8_LOCAL
			nlin++
		endif

		if TEMP->B1_CORORI = 'T'
			_cPeca := 'Traseiro'
		elseif TEMP->B1_CORORI = 'D'
			_cPeca = 'Dianteiro'
		elseif TEMP->B1_CORORI = 'C'
			_cPeca = 'Costela'
		elseif TEMP->B1_CORORI = 'M'
			_cPeca = 'Miudos'
		else
			_cPeca = 'Recorte'
		endif

		@nlin,001 psay TEMP->Z8_COD
		@nlin,011 psay substr(B1_DESC,1,30)
		@nlin,050 psay transform(TEMP->CAIX,'@E 9,999')
		@nlin,060 psay transform(TEMP->PESO,'@E 999,999.99') 
		@nlin,070 psay transform(TEMP->QUANT,'@E 9,999')
		@nlin,085 psay TEMP->Z8_LOCAL
		@nlin,100 psay _cPeca
		@nlin,111 psay stod(TEMP->Z8_DATAP)
		if mv_par05 = 4 //se for charque
			@nlin,121 psay dtoc(GetAdvFVal("SZU",'ZU_DTEST',FWxfilial('SZU')+TEMP->Z8_NUMPREV,2))
		else
			@nlin,121 psay dtoc(GetAdvFVal('SZ2','Z2_DATAABT',FWxfilial('SZ2')+TEMP->Z8_PREDES,2))
		endif

		nlin++
		@nlin,00 psay replicate('-',limite)
		nlin++ 

		//se for analitico
		if mv_par06 == 2
			cQuery2 := " SELECT Z8_COD AS COD, Z8_CONTROL AS CONTROL, Z8_DATAP AS DATAP, Z8_DATAVAL AS DATAVAL, Z8_PREDES, Z8_NUMPREV,"
			cQuery2 += " Z8_LOCAL AS LOCALI, Z8_LOCALIZ AS LOCALIZ, Z8_PESO AS PESOL, Z8_PESOBR AS PESOBR" + iif(mv_par10 = 1,", ZU_LOTEUA, ZU_SHIPPIN","")
			cQuery2 += " FROM " + retSqlTab("SZ8")
			// Se precisa mostrar somente produtos com lote dos EUA
			if mv_par10 = 1
				cQuery2 += " INNER JOIN"  + RetSqlTab("SZU") + " ON (Z8_NUMPREV = ZU_NUM)"
			endif
			cQuery2 += " WHERE Z8_FIL = '" + cFilAnt + "'"
			// Se precisa mostrar somente produtos com lote dos EUA
			if mv_par10 = 1
				cQuery2 += " AND " + RetSqlFil("SZU")
				cQuery2 += " AND LEN(ZU_LOTEUA) <= 16 "
				cQuery2 += " AND " + RetSQLDel('SZU')
				cQuery2 += " AND ZU_LOTEUA = '"  + TEMP->ZU_LOTEUA + "'"
			endif
			cQuery2 += " AND Z8_PREDES = '" + TEMP->Z8_PREDES + "'"
			cQuery2 += " AND Z8_DATAP = '" + TEMP->Z8_DATAP + "'"
			cQuery2 += " AND ((Z8_DATAE = ' ' AND Z8_DATAS = ' ' AND Z8_ITEM = ' ' AND Z8_HORAS = ' ' AND Z8_PREPED = ' ' AND Z8_PRECAR = ' ')"
			cQuery2 += " OR (Z8_PRECAR IN ('SEQUEST','COLETA')))"
			cQuery2 += " AND Z8_COD = '" + TEMP->Z8_COD + "' AND Z8_LOCAL = '" + TEMP->Z8_LOCAL + "' AND "
			cQuery2 += retSqlDel('SZ8')
			// Se precisa mostrar somente produtos com lote dos EUA
			if mv_par10 = 1
				cQuery2 += " ORDER BY ZU_SHIPPIN, ZU_LOTEUA, Z8_CONTROL, Z8_DATAP"
			else
				cQuery2 += " ORDER BY Z8_CONTROL, Z8_DATAP"
			endif

			cQuery2 := ChangeQuery(cQuery2)

			//	* Mostrar a consulta */
			//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			//@ 055,005 Get cQuery2 Size 250,080 MEMO Object oMemo
			//Activate Dialog oDlgMemo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a interface padrao com o usuario...                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If Select("TEMP2") != 0
				TEMP2->(dbCloseArea())
			Endif

			TCQUERY cQuery2 NEW ALIAS "TEMP2"

			TEMP2->(DbGoTop())

			nlin++

			if mv_par05 = 4
				@nlin,01 psay " Num.Caixa        Dt.Emba.     Dt.Valid.    Local    Localiz.       Peso Liq.   Peso Bruto   Dt. Estufa"
			else
				@nlin,01 psay " Num.Caixa        Dt.Emba.     Dt.Valid.    Local    Localiz.       Peso Liq.   Peso Bruto   Dt. Abate"
			endif

			nlin++
			while TEMP2->(!eof())

				If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif

				_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxFilial('SB1') + TEMP2->COD,1)
				if mv_par05 = 1//se for desossa
					if (_cGrupo $ _cGrpMds) .or. (_cGrupo $ _cGrpPorc) .or. (_cGrupo $ _cGrpChar)
						TEMP2->(dbSkip())
						loop
					endif
				elseif mv_par05 = 2// se for miudos
					if !(_cGrupo $ _cGrpMds)
						TEMP2->(dbSkip())
						loop
					endif
				elseif mv_par05 = 3 //se for porcionados
					if !(_cGrupo $ _cGrpPorc)
						TEMP2->(dbSkip())
						loop
					endif
				elseif mv_par05 = 4 //se for charque
					if !(_cGrupo $ _cGrpChar)
						TEMP2->(dbSkip())
						loop
					endif
				endif

				@nlin,001 psay  TEMP2->CONTROL
				@nlin,018 psay  STOD(TEMP2->DATAP)
				@nlin,032 psay  STOD(TEMP2->DATAVAL)
				@nlin,046 psay  TEMP2->LOCALI
				@nlin,053 psay  TEMP2->LOCALIZ
				@nlin,071 psay  transform(TEMP2->PESOL,'@E 999.99')
				@nlin,083 psay  transform(TEMP2->PESOBR,'@E 999.99')
				if mv_par05 = 4 //se for charque
					@nlin,095 psay dtoc(GetAdvFVal("SZU",'ZU_DTEST',FWxfilial('SZU')+TEMP2->Z8_NUMPREV,2))
				else
					@nlin,095 psay dtoc(GetAdvFVal('SZ2','Z2_DATAABT',FWxfilial('SZ2')+TEMP2->Z8_PREDES,2))
				endif
				nlin++

				TEMP2->(DbSkip())
			enddo

		endif    
		nlin++
		_TotCaix += TEMP->CAIX
		_TotPesL += TEMP->PESO
		_TotPesB += TEMP->PESOBR

		TEMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo    

	nlin += 2

	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	if !empty(mv_par01) .and. !empty(mv_par02) .and. _TotCaix = 0
		@nlin,00 psay replicate('-',limite)
		nlin++
		@nlin,01 psay alltrim(mv_par01) + " - " + alltrim(GetAdvFVal('SB1','B1_DESC',FWxFilial('SB1') + alltrim(mv_par01),1)) + " | data de embalagem: de " +  dtoc(mv_par07) + " até " + dtoc(mv_par08) + iif(!empty(mv_par04), " | data de abate: " + dtoc(mv_par04), "")
		nlin++
	endif

	@nlin,00 psay replicate('-',limite)
	nlin++
	@nlin,42 psay "Total de Caixas = " + transform(_TotCaix,'@E 999,999') + " | Peso liq. total = " + transform(_TotPesL,'@E 999,999.99') + " | Peso bruto total = " + transform(_TotPesB,'@E 999,999.99')
	nlin++
	@nlin,00 psay replicate('-',limite)
	nlin++

	if mv_par10 = 1
		if !empty(_aShipM)
			for i := 1 to len(_aShipM)
				_aTotSM := SumShipM(_aShipM[i])
				@nlin,05 psay "Shipping Mark: " + _aShipM[i] + " | Total de caixas = " + transform(_aTotSM[1],'@E 999,999') + " | Peso liq. total = " + transform(_aTotSM[2],'@E 999,999.99') + " | Peso bruto total = " + transform(_aTotSM[3],'@E 999,999.99')
				nlin++
			next
		endif
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea()

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

Static Function SumShipM(_cShipM)
	cQuery3 := " SELECT COUNT(Z8_CONTROL) AS CAIXAS, SUM(Z8_PESO) AS PESO, SUM(Z8_PESOBR) AS PESOBR"
	cQuery3 += " FROM " + retSqlTab('SZ8')
	cQuery3 += " INNER JOIN " + retSqlTab('SZU') + "ON (Z8_NUMPREV = ZU_NUM)"
	cQuery3 += " WHERE " + retSqlFil('SZ8') + " AND " + retSqlFil('SZU')
	cQuery3 += " AND Z8_DATAS = '' AND Z8_FIL = '" + cFilAnt + "'"
	cQuery3 += " AND ZU_SHIPPIN = '" + alltrim(_cShipM) + "'"
	cQuery3 += " AND " + retSqlDel('SZ8') + " AND " + retSqlDel('SZU')

	cQuery3 := ChangeQuery(cQuery3)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if Select("TMP") != 0
		TMP->(dbCloseArea())
	endif

	TCQUERY cQuery3 NEW ALIAS "TMP"

Return {TMP->CAIXAS, TMP->PESO, TMP->PESOBR}
