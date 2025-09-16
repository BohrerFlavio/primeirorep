#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI167    ºAutor  ³Adonai Gabriel   º Data ³  14/02/23      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Relatório com o manifesto de carga analítico ordenado     º±±
±±º          ³  por certificado e com resumo                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI167()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "de manifesto de carga analítico listando as caixas ou"
	Local cDesc3         := "peças por certificado que formaram esta carga."	
	Local titulo         := "MANIFESTO DE CARGA ANALÍTICO POR CERTIFICADO"
	Local Cabec1         := "                            Caixas/Peças       Quantidade       Peso Líq.      Peso Bru.    Data Emb.     Data Valid.   Data Transf."
	Local Cabec2         := ""
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := Space(10)
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI167" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI167"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI167" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aDados 	 := {}
	Private _aCabec		 := {}

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

    MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	SetDefault(aReturn,'SZ8')

	If nLastKey == 27
		Return
	Endif

    Cabec2 += 'Pré-carregamento: ' + alltrim(mv_par01) + ' | Pré-pedido: ' + alltrim(mv_par02)

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	_nCont := 0
	_lCont := .T.
    _cCod := ""
    _cDesc := ""
    _cCodTran := TMP->Z8_CODTRAN
    _cCertif := ""
	_nCaix  := 0
	_nPesoL := 0
	_nPesoB := 0
	_dDtPAnt := TMP->Z8_DATAP
	_dDtVAnt := TMP->Z8_DATAVAL
	_dDtTAnt := TMP->Z8_DTRANSF
	_nDtCaix := 1
	_nDtPesoL := TMP->Z8_PESO
	_nDtPesoB := TMP->Z8_PESOBR
    _nTotCaix := 0
    _nTotPesoL := 0
    _nTotPesoB := 0

	while TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		if lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		endif

		if nLin > 80 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		endif

		if mv_par03 = 1
            _dDtAbate := dtos(GetAdvFVal('SZ2','Z2_DATAABT', FWxFilial('SZ8') + TMP->Z8_PREDES, 2))
            _dDatE := iif(Empty(TMP->Z8_PREDES), TMP->Z8_DATAP, _dDtAbate)
        else
            _dDatE := TMP->Z8_DATAP
        endif

        if mv_par04 = 1
            if _dDtPAnt = _dDatE .and. !_lCont
				_nDtCaix += 1
				_nDtPesoL += TMP->Z8_PESO
				_nDtPesoB += TMP->Z8_PESOBR
			elseif _dDtPAnt = _dDatE .and. _lCont
				_nDtCaix := 1
				_nDtPesoL := TMP->Z8_PESO
				_nDtPesoB := TMP->Z8_PESOBR
				_lCont := .F.
			else
				@nLin,047 psay transform(_nDtCaix,'@E 999,999')
				@nLin,062 psay transform(_nDtPesoL,'@E 999,999.99')
				@nLin,077 psay transform(_nDtPesoB,'@E 999,999.99')
				@nLin,092 psay dtoc(stod(_dDtPAnt))
				@nLin,107 psay dtoc(stod(_dDtVAnt))
				// Adiciona os dados para Excel
				if mv_par05 = 1
					aadd(_aDados, {"", "", alltrim(str(_nDtCaix)), alltrim(str(_nDtPesoL)), alltrim(str(_nDtPesoB)), dtoc(stod(_dDtPAnt)), dtoc(stod(_dDtVAnt)), ""})
					_nCont++
				endif
				if cFilAnt = '01'
					@nLin,122 psay dtoc(stod(_dDtTAnt))
					if mv_par05 = 1
						_aDados[_nCont,8] := dtoc(stod(_dDtTAnt))
					endif
				endif
				_dDtPAnt := _dDatE
				_dDtVAnt := TMP->Z8_DATAVAL
				_dDtTAnt := TMP->Z8_DTRANSF
				_nDtCaix := 1
				_nDtPesoL := TMP->Z8_PESO
				_nDtPesoB := TMP->Z8_PESOBR
				nLin++
			endif
		endif

		if _cCodTran != TMP->Z8_CODTRAN
            _cCertif := GetAdvFVal('ZAC','ZAC_CERCSN', FWxFilial('SZ8') + _cCodTran, 1)
            @nLin,01 psay replicate('-', limite)
            nLin++
            @nLin,05 psay "Certificado: " + alltrim(_cCertif) + " -> Caixas = " + transform(_nCaix,'@E 999,999') + " | Peso Liq. = " + transform(_nPesoL,'@E 999,999,999.99') + " kg | Peso Bru. = " + transform(_nPesoB,'@E 999,999,999.99') + " kg"
            nLin++
            @nLin,01 psay replicate('-', limite)
			nLin++
			// Adiciona os dados para Excel
			if mv_par05 = 1
				aadd(_aDados, {"Certificado: " + alltrim(_cCertif) + " -> Caixas = " + alltrim(str(_nCaix)) + " | Peso Liq. = " + alltrim(str(_nPesoL)) + " kg | Peso Bru. = " + alltrim(str(_nPesoB)) + " kg", "", "", "", "", "", "", ""})
				_nCont++
			endif
			_cCodTran := TMP->Z8_CODTRAN
            _nTotCaix += _nCaix
            _nTotPesoL += _nPesoL
            _nTotPesoB += _nPesoB
            _nCaix := 0
            _nPesoL := 0
            _nPesoB := 0
        endif

		if _cCod != TMP->Z8_COD
            _cCod := TMP->Z8_COD
            _cDesc := alltrim(GetAdvFVal('SB1', 'B1_DESC', FWxfilial('SB1')+alltrim(TMP->Z8_COD), 1))
            @nLin,01 psay replicate('=', limite)
            nLin++
            @nLin,05 psay "Produto -> " + alltrim(_cCod) + "  -  " + _cDesc
            nLin++
            @nLin,01 psay replicate('=', limite)
			nLin++
			// Adiciona os dados para Excel
			if mv_par05 = 1
				aadd(_aDados, {"Produto -> " + alltrim(_cCod) + "  -  " + _cDesc, "", "", "", "", "", "", ""})
				_nCont++
			endif
        endif

        if mv_par04 = 2
            @nLin,030 psay TMP->Z8_CONTROL
            @nLin,050 psay 1
            @nLin,065 psay transform(TMP->Z8_PESOBR,'@E 999.99')
            @nLin,080 psay transform(TMP->Z8_PESO,'@E 999.99')
            @nLin,092 psay dtoc(stod(_dDatE))
            @nLin,107 psay dtoc(stod(TMP->Z8_DATAVAL))
			// Adiciona os dados para Excel
			if mv_par05 = 1
				aadd(_aDados, {"", TMP->Z8_CONTROL, '1', alltrim(str(TMP->Z8_PESOBR)), alltrim(str(TMP->Z8_PESO)), dtoc(stod(_dDatE)), dtoc(stod(TMP->Z8_DATAVAL)), ""})
				_nCont++
			endif
			if cFilAnt = '01'
                @nLin,122 psay dtoc(stod(TMP->Z8_DTRANSF))
				if mv_par05 = 1
					_aDados[_nCont,8] := dtoc(stod(TMP->Z8_DTRANSF))
				endif
            endif
			nLin++
        endif

        _nCaix += 1
        _nPesoL += TMP->Z8_PESO
        _nPesoB += TMP->Z8_PESOBR

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	end

	if mv_par04 = 1
		@nLin,047 psay transform(_nDtCaix,'@E 999,999')
		@nLin,062 psay transform(_nDtPesoL,'@E 999,999.99')
		@nLin,077 psay transform(_nDtPesoB,'@E 999,999.99')
		@nLin,092 psay dtoc(stod(_dDtPAnt))
		@nLin,107 psay dtoc(stod(_dDtVAnt))
		// Adiciona os dados para Excel
		if mv_par05 = 1
			aadd(_aDados, {"", "", alltrim(str(_nDtCaix)), alltrim(str(_nDtPesoL)), alltrim(str(_nDtPesoB)),'@E 999,999.99', dtoc(stod(_dDtPAnt)), dtoc(stod(_dDtVAnt)), ""})
			_nCont++
		endif
		if cFilAnt = '01'
			@nLin,122 psay dtoc(stod(_dDtTAnt))
			if mv_par05 = 1
				_aDados[_nCont,8] := dtoc(stod(_dDtTAnt))
			endif
		endif
		nLin++
	endif

    _nTotCaix += _nCaix
    _nTotPesoL += _nPesoL
    _nTotPesoB += _nPesoB

    _cCertif := GetAdvFVal('ZAC','ZAC_CERCSN', FWxFilial('SZ8') + _cCodTran, 1)
    @nLin,01 psay replicate('-', limite)
    nLin++
    @nLin,05 psay "Certificado: " + alltrim(_cCertif) + " -> Caixas = " + transform(_nCaix,'@E 999,999') + " | Peso Liq. = " + transform(_nPesoL,'@E 999,999,999.99') + " kg | Peso Bru. = " + transform(_nPesoB,'@E 999,999,999.99') + " kg"
    nLin++
    @nLin,01 psay replicate('-', limite)
    nLin++
	// Adiciona os dados para Excel
	if mv_par05 = 1
		aadd(_aDados, {"Certificado: " + alltrim(_cCertif) + " -> Caixas = " + alltrim(str(_nCaix)) + " | Peso Liq. = " + alltrim(str(_nPesoL)) + " kg | Peso Bru. = " + alltrim(str(_nPesoB)) + " kg", "", "", "", "", "", "", ""})
		_nCont++
	endif

    @nlin,00 psay replicate("-", limite)
    nlin++
    @nlin,015 psay "Total de Volumes: " + transform(_nTotCaix, "@E 999,999,999") + " caixas"
    nlin++
	if mv_par05 = 1
		// Adiciona os dados para Excel
		aadd(_aDados, {"Total de Volumes: " + alltrim(str(_nTotCaix)) + " caixas", "", "", "", "", "", "", ""})
	endif
    @nlin,015 psay "Peso Bruto Total: " + transform(_nTotPesoB, "@E 999,999,999.99") + " kg"
    nlin++
	if mv_par05 = 1
		// Adiciona os dados para Excel
		aadd(_aDados, {"Peso Bruto Total: " + alltrim(str(_nTotPesoB)) + " kg", "", "", "", "", "", "", ""})
	endif
    @nlin,015 psay "Peso Líquido Total: " + transform(_nTotPesoL, "@E 999,999,999.99") + " kg"
    nlin++
	if mv_par05 = 1
		// Adiciona os dados para Excel
		aadd(_aDados, {"Peso Líquido Total: " + alltrim(str(_nTotPesoL)) + " kg", "", "", "", "", "", "", ""})
	endif
    @nlin,00 psay replicate("-", limite)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	If Len(_aDados) > 0		// Gera e mostra no Excel
		AADD( _aCabec, {"         ", "C", 50, 0} )
		AADD( _aCabec, {"Caixas/Peças", "C", 20, 0} )
		AADD( _aCabec, {"Quantidade", "N", 4, 0} )
		AADD( _aCabec, {"Peso Líq", "N", 9, 2} )
		AADD( _aCabec, {"Peso Bru", "N", 9, 2} )
		AADD( _aCabec, {"Data Embagem", "C", 10, 0} )
		AADD( _aCabec, {"Data Validade", "C", 10, 0} )
		AADD( _aCabec, {"Data Transferência", "C", 10, 0} )
		U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
	Endif

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

Static Function GeraTMP()

	cQuery := "SELECT Z8_CONTROL, Z8_PESOBR, Z8_PESO, Z8_DATAP, Z8_DATAVAL, Z8_DTRANSF, Z8_PREDES, Z8_COD, Z8_CODTRAN, Z8_ITEM"
    cQuery += " FROM  " + retSqlTab('SZ8')
    cQuery += " WHERE " + retSqlFil('SZ8')
	cQuery += " AND Z8_FIL = '" + cFilAnt + "'"
    cQuery += " AND Z8_PRECAR = '" + mv_par01 + "'"
    cQuery += " AND Z8_PREPED = '" + mv_par02 + "'"
	cQuery += " AND " + retSqlDel('SZ8')
	cQuery += " ORDER BY Z8_ITEM, Z8_COD, Z8_CODTRAN, Z8_DATAP"

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP"

return
