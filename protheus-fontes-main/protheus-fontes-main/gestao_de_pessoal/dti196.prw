#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI196    ºAutor  ³Adonai Gabriel   º Data ³  13/11/23     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório para conferência de apontamentos de              º±±
±±º          ³ colaboradores.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Departamento Pessoal                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI196()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir um relatório"
	Local cDesc2         := "para conferência de apontamentos de colaboradores."
	Local cDesc3         := ""
	Local titulo         := "APONTAMENTOS POR COLABORADOR"
	Local Cabec1         := ""
	Local Cabec2         := "              MATRÍCULA          NOME                        QTDE. ABONADA        C. CUSTO"
	Local aOrd           := {}
	Private nlin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI196" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI196"
	Private cbcont     	 := 00
	Private CONTFL    	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "DTI196" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aDados 	 := {}
	Private _aCabec		 := {}

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SPC',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	while empty(mv_par01) .or. empty(mv_par02)
		FWAlertError('Por favor, informe um intervalo da data!','ALERTA!')
		pergunte(cPerg,.T.)
	end

	Cabec1 += 'De data de apontamento - ' +  DTOC(mv_par01) + " - até - " + DTOC(mv_par02) + " | Motivo: " + alltrim(GetAdvFVal('SP6','P6_DESC',FWxFilial('SP6')+mv_par07,1))

	MsgRun("Aguarde... Realizando o processamento dos registros...",,{|| GeraTMP()})

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SPC')

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nlin) },Titulo)

Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nlin)

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nlin := 9

    TMP->(dbGoTop())
	TMP->(SetRegua(RecCount()))

	_cData := ""
	_cNome := ""
	_cCCDesc := ""

    While TMP->(!EOF())

		incregua()

        If lAbortPrint
            @nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
            Exit
        Endif

        If nlin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
            Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
            nlin := 9
        Endif

		if _cData <> TMP->PC_DATA
			@nlin,00 psay replicate('-',132)
			nlin++
			@nlin,05 psay 'Data de Apontamento: ' + dtoc(stod(TMP->PC_DATA))
			nlin++
			@nlin,00 psay replicate('-',132)
			nlin++
			_cData := TMP->PC_DATA
		endif

		_cNome := substr(GetAdvFVal('SRA','RA_NOME',FWxFilial('SRA')+TMP->PC_MAT,1),1,30)
		_cCCDesc := substr(GetAdvFVal('CTT','CTT_DESC01',FWxFilial('CTT') + TMP->PC_CC,1),1,25)

		if mv_par08 = 2
			aadd(_aDados, {dtoc(stod(TMP->PC_DATA)), TMP->PC_MAT, _cNome, TMP->PC_QTABONO, _cCCDesc})
		endif
		@nlin,15 psay TMP->PC_MAT
		@nlin,30 psay _cNome
		@nlin,65 psay TMP->PC_QTABONO
		@nlin,80 psay _cCCDesc
		nlin++

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    enddo

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	if mv_par08 = 2
		If Len(_aDados) > 0		// Gera e mostra no Excel
			AADD( _aCabec, {"DATA", "D", 10, 0} )
			AADD( _aCabec, {"MATRÍCULA", "C", 6, 0} )
			AADD( _aCabec, {"NOME", "C", 30, 0} )
			AADD( _aCabec, {"QUANTIDADE", "N", 6, 0} )
			AADD( _aCabec, {"C. CUSTO",	"C", 9, 0} )
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

Static Function GeraTMP()

	_cQuery := "SELECT PC_DATA, PC_CC, PC_MAT, PC_ABONO, PC_QTABONO"
	_cQuery += " FROM  " + RetSQLTab('SPC')
	_cQuery += " WHERE " + RetSQLFil('SPC')
	_cQuery += " AND (PC_DATA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')"
	_cQuery += " AND (PC_CC BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "')"
	_cQuery += " AND (PC_MAT BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "')"
	_cQuery += " AND PC_ABONO = '" + mv_par07 + "'"
	_cQuery += " AND " + RetSQLDel('SPC')
	_cQuery += " ORDER BY PC_DATA, PC_CC, PC_MAT"

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
