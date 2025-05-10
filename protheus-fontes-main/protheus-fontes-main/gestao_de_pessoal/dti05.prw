#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI05  ºAutor  ³Mauricio Roehrs º Data ³  28/06/16          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio para exibir as horas do funcionario de acordo comº±±
±± 			 ³	o acordo coletivo com o sindicado (20min por dia)         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI05()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia das horas do acordo coletivo."
	Local cDesc3         := ""
	Local cPict          := "vai porra"
	Local titulo         := "RELAT. DE HORAS DO ACORD. COLETIVO"
	Local Cabec1         := "                                             Matricula                Nome                       Dias        Horas"
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Local nS
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "DTI05" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "DTI05"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI05" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private _cDtPeriodo    := GETMV('MV_PAPONTA')//parametro que possui a data de apontamento do ponto
	Private _cDtIni     	  := substr(_cDtPeriodo,1,8)
	Private _cDtFim 	  	  := substr(_cDtPeriodo,10,18)
	Private _dIniPer       := stod("")
	Private _dFimPer	     := stod("")
	Private _dAnoIni    	  := stod("")
	Private _dAnoFim	  	  := stod("")
	Private _cMat		  	  := ''
	Private _dDataCorrente := stod("")
	Private _nDias 		  := 0
	Private _aBat			  := {}
	Private _nTotHr		  := 0
	Private _dDataIni		  := stod("")

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SP8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


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

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SP8')

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

	Local nOrdem

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())


	_cCC := ''
	While TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		_nTotHr := 0
		_nDias  := 0

		if cFilAnt <> '01'

			if TMP->RA_ACORHE <> 'S'
				calcHoras(TMP->RA_MAT)
			else
				calcMedia()
			endif

			if _nDias > 0 .and. _nTotHr > 0

				if _cCC <> TMP->RA_CC
					@nlin,01 psay replicate('_',132)
					nlin++
					_cDescCC := fBuscaCpo('CTT',1,xFilial('CTT') + TMP->RA_CC,'CTT_DESC01')
					@nlin,05 psay 'Centro de Custo: ' + TMP->RA_CC + ' - ' + _cDescCC
					nlin++
					@nlin,01 psay replicate('_',132)
					nlin++

					_cCC := TMP->RA_CC
				endif

				@nlin,45 psay TMP->RA_MAT
				@nlin,57 psay substr(TMP->RA_NOME,1,35)
				@nlin,97 psay transform(_nDias,'@E 99')
				@nlin,105 psay StrTran(Transform( fConvHr( _nTotHr,'H'), '@e 9999.99' ),',',':' )//fConvHr(_nTotHr,'H')

				//StrTran(Transform( fConvHr( ntHe,'H'), '@e 9999.99' ),',',':' )
				//transform(strtran(str(fConvHr(_nTotHr,'H')),'.',':'),'@! 99:99')

				nlin++

			endif
		endif

		_nTotHr := 0
		_nDias  := 0
		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo

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


Static Function GeraTMP()

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


Static Function calcMedia()

	_nDias := 25 //media de dias sera de 25 dias de acordo com Clailton

	_nTotHr  := calcula(_nDias)

return

Static Function calcHoras(_cMat)

	_dIniPer := stod(substr(_cDtPeriodo,1,8))
	_dFimPer := stod(substr(_cDtPeriodo,10,18))

	DbSelectArea('SP8')
	SP8->(DbSetOrder(2))
	SP8->(DbGoTop())

	if SP8->(DbSeek(xFilial('SP8') + alltrim(_cMat) + dtos(_dIniPer)))
		_dDataIni := SP8->P8_DATA

		if _dDataIni < _dIniPer
			_dDataIni := _dIniPer
		endif

		//enquanto a data das marcações da SP8 estiverem entre as datas do parametro MV_PAPONTA
		//while xFilial('SP8') == SP8->P8_FILIAL .and. alltrim(_cMat) == alltrim(SP8->P8_MAT) .and. (_dDataIni >= _dIniPer .and. SP8->P8_DATA <= _dFimPer)
		while SP8->(!eof()) .and. xFilial('SP8') == SP8->P8_FILIAL .and. alltrim(_cMat) == alltrim(SP8->P8_MAT) .and. SP8->P8_DATA <= _dFimPer

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
				if (SP8->P8_CC = "1111003") .or. (SP8->P8_CC = "1121001") .or. (SP8->P8_CC = "1121002")
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
			if _dDataCorrente = SP8->P8_DATA
				SP8->(DbSkip())
				loop
			else
				_dDataCorrente := SP8->P8_DATA
			endif

			//alert(dtoc(SP8->P8_DATA))
			_nDias ++

			//alert('Matricula: ' + SP8->P8_MAT + '     '+'Total de Dias:' + cValToChar(_nDias))

			SP8->(DbSkip())

		enddo
	endif

	_nTotHr := calcula(_nDias)

return


Static Function calcula(_nDias)

	Local _nTotal := 0

	_nTotal := _nDias * 0.33

return _nTotal
