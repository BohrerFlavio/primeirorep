#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI46    º Autor ³ Mauricio Roehrs em    11/01/18           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de conferencia do que foi solicitado produção    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Porcionados   		                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI46()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia das solicitações de produção de"
	Local cDesc3         := "porcionados."
	Local cPict          := "vai porra"
	Local titulo         := "RELATORIO SOLICITAÇÃO PRODUÇÃO"
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "DTI46" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI46"
	Private cbtxt      	 := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI46" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aPrd 		 := {}
	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cQuery := " SELECT ZZ3_NUM, ZZ3_DTCAR, ZZ3_OBS, ZZ4_NUM, ZZ4_CODCLI, ZZ4_LOJA, ZZ4_NOME, ZZ5_COD, ZZ5_QPCAIX, ZZ5_QPPESO,"
	_cQuery += " ZZ5_SOLPRO, ZZ5_DTSPOR, ZZ5_USRSOL, B1_COD, B1_DESC"
	_cQuery += " FROM  "+ retSqlTab('ZZ5') +", "+ retSqlTab('SB1') +", "+ retSqlTab('SBM') +", "+ retSqlTab('ZZ4') +", "+  retSqlTab('ZZ3')
	_cQuery += " WHERE "+ retSqlFil('ZZ5') +" AND "+ retSqlFil('SB1') +" AND "+ retSqlFil('SBM') +" AND "+ retSqlFil('ZZ4') +" AND "+ retSqlFil('ZZ3')
	_cQuery += " AND ZZ4_PRECAR = ZZ3_NUM AND ZZ4_NUM = ZZ5_NUM"
	_cQuery += " AND ZZ5_COD = B1_COD AND B1_GRUPO = BM_GRUPO AND BM_PORC = 'S'"
	_cQuery += " AND ZZ3_DTCAR BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02)+ "'"
	_cQuery += " AND ZZ3_NUM BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	_cQuery += " AND B1_COD BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
	_cQuery += " AND "+ retSqlDel('ZZ5') +" AND "+ retSqlDel('SB1') +" AND "+ retSqlDel('SBM') +" AND "+ retSqlDel('ZZ4') +" AND "+ retSqlDel('ZZ3')
	_cQuery += " ORDER BY ZZ3_NUM, ZZ4_NUM, ZZ5_COD"

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
	Local i

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 5

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	_cPP 	 := ''
	_cPrecar := ''

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
			nLin := 5
		Endif

		if _cPrecar <> TMP->ZZ3_NUM
			@nlin,01 psay replicate('-',132)
			nlin++
			@nlin,00 psay 'Pre-Carreg.   Data Carreg.            Obs.'
			nlin++	
			@nlin,00 psay TMP->ZZ3_NUM
			@nlin,15 psay dtoc(stod(TMP->ZZ3_DTCAR))
			@nlin,30 psay substr(TMP->ZZ3_OBS,1,25)
			nlin++
			_cPrecar := TMP->ZZ3_NUM
		endif

		if _cPP <> TMP->ZZ4_NUM
			@nlin,01 psay replicate('-',132)
			nlin++
			@nlin,05 psay 'Pre-Ped.  Codigo   Loja                         Cliente'
			nlin++
			@nlin,05 psay TMP->ZZ4_NUM
			@nlin,15 psay TMP->ZZ4_CODCLI
			@nlin,25 psay TMP->ZZ4_LOJA
			@nlin,40 psay substr(TMP->ZZ4_NOME,1,40)
			nlin++
			@nlin,01 psay replicate('-',132)
			nlin++
			@nlin,10 psay 'Codigo              Produto                   Caixas       Peso         Solicit?    Dt.Solic.   Usuario'
			nlin+=2
			_cPP := TMP->ZZ4_NUM
		endif

		if TMP->ZZ5_SOLPRO = 'S'		
			_npos := aScan(_aPrd,{|aVal|aVal[1] = TMP->ZZ5_COD})
			if _npos <> 0
				_aPrd[_npos,3]+= TMP->ZZ5_QPCAIX
				_aPrd[_npos,4]+= TMP->ZZ5_QPPESO
			else
				aAdd(_aPrd,{TMP->ZZ5_COD, substr(TMP->B1_DESC,1,30),TMP->ZZ5_QPCAIX, TMP->ZZ5_QPPESO})
			endif			
		endif

		@nlin,010 psay TMP->ZZ5_COD
		@nlin,020 psay substr(TMP->B1_DESC,1,30)
		@nlin,055 psay transform(TMP->ZZ5_QPCAIX,'@E 9,999')
		@nlin,065 psay transform(TMP->ZZ5_QPPESO,'@E 999,999.99')
		@nlin,085 psay iif(TMP->ZZ5_SOLPRO = 'S','Sim','Nao')
		@nlin,095 psay dtoc(stod(TMP->ZZ5_DTSPOR))
		@nlin,105 psay TMP->ZZ5_USRSOL
		nlin++

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nlin := 5

	@nlin,01 psay replicate('_',132)
	nlin++
	@nlin,50 psay 'TOTAL DOS PRODUTOS'
	nlin++
	@nlin,10 psay 'Codigo              Produto                     Caixas       Peso'
	nlin+=2

	_aPrd := ASort(_aPrd, , , {|x,y|x[1] < y[1]})//ordena o vetor por código de produto

	for i:=1 to len(_aPrd)

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 5

			@nlin,01 psay replicate('_',132)
			nlin++
			@nlin,50 psay 'TOTAL DOS PRODUTOS'
			nlin++
			@nlin,10 psay 'Codigo              Produto                     Caixas       Peso'
			nlin+=2
		Endif

		@nlin,010 psay _aPrd[i,1] //codigo
		@nlin,020 psay _aPrd[i,2] //descricao
		@nlin,055 psay transform(_aPrd[i,3],'@E 9,999,999')   //caixas
		@nlin,065 psay transform(_aPrd[i,4],'@E 9,999,999.99') //peso
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
