#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI208    ºAutor  ³Adonai Gabriel   º Data ³  13/11/23     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório para conferência de apontamentos de              º±±
±±º          ³ colaboradores.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Departamento Pessoal                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI208()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir um relatório"
	Local cDesc2         := "para conferência de apontamentos manuais de colaboradores."
	Local cDesc3         := ""
	Local titulo         := "APONTAMENTOS MANUAIS"
	Local Cabec1         := ""
	Local Cabec2         := "                TIPO DE MARC.          CENTRO DE CUSTO        DATA DE APONT.      MOTIVO"
	Local aOrd           := {}
	Private nlin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI208" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI208"
	Private cbcont     	 := 00
	Private CONTFL    	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "DTI208" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aDados 	 := {}
	Private _aCabec		 := {}

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SP8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	while empty(mv_par01) .or. empty(mv_par02)
		FWAlertError('Por favor, informe um intervalo da data!','ALERTA!')
		pergunte(cPerg,.T.)
	end

	Cabec1 += 'De data de apontamento - ' +  DTOC(mv_par01) + " - até - " + DTOC(mv_par02)

	MsgRun("Aguarde... Realizando o processamento dos registros...",,{|| GeraTMI()})

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SP8')

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nlin) },Titulo)

Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nlin)

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nlin := 9

    TMI->(dbGoTop())
	TMI->(SetRegua(RecCount()))

	_cMat := ""
	_cCCDesc := ""
	_cTPMarca := ""

    While TMI->(!EOF())

		incregua()

        If lAbortPrint
            @nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
            Exit
        Endif

        If nlin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
            Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
            nlin := 9
        Endif

		if _cMat <> TMI->P8_MAT
			@nlin,00 psay replicate('-',132)
			nlin++
			@nlin,05 psay 'Matrícula: ' + TMI->P8_MAT + ' | ' + alltrim(TMI->RA_NOME)
			nlin++
			@nlin,00 psay replicate('-',132)
			nlin++
			_cMat := TMI->P8_MAT
		endif

		_cCCDesc := substr(GetAdvFVal('CTT','CTT_DESC01',FWxFilial('CTT') + TMI->P8_CC,1),1,25)
		do case
			case TMI->P8_TPMARCA = '1E'
				_cTPMarca := "Primeira entrada"
			case TMI->P8_TPMARCA = '1S'
				_cTPMarca := "Primeira saída"
			case TMI->P8_TPMARCA = '2E'
				_cTPMarca := "Segunda entrada"
			case TMI->P8_TPMARCA = '2S'
				_cTPMarca := "Segunda saída"
			otherwise
				_cTPMarca := "Sem tipo"
		endcase

		if mv_par07 = 2
			aadd(_aDados, {TMI->P8_MAT, substr(TMI->RA_NOME,1,30), _cTPMarca, _cCCDesc, dtoc(stod(TMI->P8_DATAAPO)), alltrim(P8_MOTIVRG)})
		endif
		@nlin,15 psay _cTPMarca
		@nlin,40 psay substr(_cCCDesc,1,30)
		@nlin,65 psay dtoc(stod(TMI->P8_DATAAPO))
		@nlin,80 psay alltrim(P8_MOTIVRG)
		nlin++

		TMI->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    enddo

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	if mv_par07 = 2
		If Len(_aDados) > 0		// Gera e mostra no Excel
			AADD( _aCabec, {"MATRÍCULA", "C", 6, 0} )
			AADD( _aCabec, {"NOME", "C", 30, 0} )
			AADD( _aCabec, {"TIPO MARC.", "C", 10, 0} )
			AADD( _aCabec, {"C. CUSTO",	"C", 9, 0} )
			AADD( _aCabec, {"DATA", "D", 10, 0} )
			AADD( _aCabec, {"MOTIVO", "C", 10, 0} )
			U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
		Endif
	endif

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

Static Function GeraTMI() // Query de tipo de marcações I (registro manual)

	_cQuery := "SELECT P8_MAT, RA_NOME, P8_DATAAPO, P8_MOTIVRG, P8_CC, P8_TPMARCA"
	_cQuery += " FROM  " + RetSQLTab('SP8') + " (NOLOCK)"
	_cQuery += " INNER JOIN  " + RetSQLTab('SRA') + " (NOLOCK) ON (P8_MAT = RA_MAT)"
	_cQuery += " WHERE " + RetSQLFil('SP8') + " AND " + RetSQLFil('SRA')
	_cQuery += " AND (P8_DATAAPO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')"
	_cQuery += " AND (P8_MAT BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "')"
	_cQuery += " AND (P8_CC BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "')"
	_cQuery += " AND P8_TIPOREG = 'I'"
	_cQuery += " AND " + RetSQLDel('SP8') + " AND " + RetSQLDel('SRA')
	_cQuery += " ORDER BY P8_MAT, P8_DATAAPO"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMI") != 0
		TMI->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMI"

return

Static Function GeraTMF() // Query de tipo de marcações faltantes

	_cQuery := "SELECT P8_MAT, RA_NOME, P8_DATAAPO, P8_MOTIVRG, P8_CC, P8_TPMARCA"
	_cQuery += " FROM  " + RetSQLTab('SP8') + " (NOLOCK)"
	_cQuery += " INNER JOIN  " + RetSQLTab('SRA') + " (NOLOCK) ON (P8_MAT = RA_MAT)"
	_cQuery += " WHERE " + RetSQLFil('SP8') + " AND " + RetSQLFil('SRA')
	_cQuery += " AND (P8_DATAAPO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')"
	_cQuery += " AND (P8_MAT BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "')"
	_cQuery += " AND (P8_CC BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "')"
	_cQuery += " AND P8_TIPOREG = 'I'"
	_cQuery += " AND " + RetSQLDel('SP8') + " AND " + RetSQLDel('SRA')
	_cQuery += " ORDER BY P8_MAT, P8_DATAAPO"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMF") != 0
		TMF->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMF"

return
