#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF101   º Autor ³ Giuliano Forgiarini  º Data ³  13/01/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Avaliação de Expedição de PA                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Expedições e Comercial (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF101()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este relatorio tem por objetivo listar de forma     "
	Local cDesc2         := "analítica as caixas de PA expedidas com suas        "
	Local cDesc3         := "respectivas informações de acordo com os parametros "
	//Local cPict          := ""
	Local titulo         := "AVALIAÇÃO DE EXPEDIÇÃO DE PA"
	Local nLin           := 80
	Local Cabec1         := "       Codigo e Descrição do Produto"                   
	Local Cabec2         := "               Num.Caixa    Quant.       Tara      Peso        Dt. Prod.      Hora Prod.     Dt.Validade"
	//Local imprime        := .T.
	Local aOrd 			 := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "GJF101" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF101"
	//Private cbtxt      := Space(10)
	Private cbcont     	 := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF101" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem

	cQuery := "SELECT ZZ4_NUM, ZZ4_DATA,ZZ4_CODCLI,ZZ4_LOJA,ZZ4_PRECAR,ZZ4_OBS,Z8_CONTROL, Z8_DATAP,B1_DESC, Z8_HORA, "
	cQuery += "Z8_COD,Z8_PESO,Z8_QUANT,Z8_TARA,Z8_DATAS,Z8_DATAVAL,Z8_PRECAR,Z8_PREPED,Z8_ITEM,Z8_FIL, B1_COD"
	cQuery += " FROM " + RetSqlName("SZ8") + ", " + RetSqlName("SB1")  + ", " + RetSqlName("ZZ4")
	cQuery += " WHERE SB1010.D_E_L_E_T_ <> '*' AND "
	cQuery +="        SZ8010.D_E_L_E_T_ <> '*' AND "
	cQuery +="        ZZ4010.D_E_L_E_T_ <> '*' AND "
	cQuery +=" B1_TIPO  IN('PR','PA') AND "
	cQuery +=" B1_MSBLQL  <> '1' AND "
	//cQuery +=" B1_FAM     = '" + mv_par03 + "' AND" 
	cQuery +=" B1_FILIAL  = '" + FWxFilial("SB1") + "' AND"
	cQuery +=" ZZ4_FILIAL = '" + FWxFilial("ZZ4") + "' AND"
	cQuery +=" B1_COD     = Z8_CODORI AND"
	cQuery +=" Z8_FIL     = '" + cFilAnt + "' AND"
	cQuery +=" Z8_FILIAL  = '" + FWxFilial("SZ8") + "' AND"
	cQuery +=" ZZ4_PRECAR = Z8_PRECAR AND"
	cQuery +=" ZZ4_NUM    = Z8_PREPED AND"
	cQuery +=" Z8_PREPED <> '' AND"
	cQuery +=" Z8_PRECAR <> '' AND"

	If !empty(mv_par03)
		if mv_par03 = '017'
			cQuery += " B1_FAM IN ('017','016','027','036','037','026') AND "
		elseif mv_par03 = '019'
			cQuery += " B1_FAM IN ('019','003','027','037','026') AND "
		else
			cQuery += " B1_FAM = '" + MV_PAR03 + "' AND "
		endif
	Endif

	If !empty(mv_par06)
		cQuery +=" B1_COD = '"+ MV_PAR06 + "' AND "
	Endif

	If !empty(mv_par07)
		cQuery +=" ZZ4_CODCLI = '"+ MV_PAR07 + "' AND "
	Endif

	cQuery +=" Z8_DATAP BETWEEN '" + dtos(mv_par04) + "' AND '" + dtos(mv_par05) + "' AND"
	cQuery +=" Z8_DATAS BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	cQuery +=" ORDER BY ZZ4_DATA, ZZ4_CODCLI, ZZ4_LOJA, B1_DESC"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("EXP") != 0
		EXP->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "EXP"

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

	//Local nOrdem    
	Local _dData    := ctod('')
	Local _cCodCli  := ''
	Local _cDescPro := ''

	Local _nQuant   := 0
	Local _nPeso    := 0 
	Local _nCaix    := 0 

	Local _nPQuant  := 0
	Local _nPPeso   := 0
	Local _nPCaix   := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	EXP->(dbGoTop())

	EXP->(SetRegua(RecCount()))

	While EXP->(!EOF())

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

		if _dData <> stod(EXP->ZZ4_DATA)
			@nlin,01 psay STOD(EXP->ZZ4_DATA)
			_dData := STOD(EXP->ZZ4_DATA)
			nlin++
		endif

		if _cCodCli <> EXP->(ZZ4_CODCLI+ZZ4_LOJA)
			_descCli := GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1')+EXP->(ZZ4_CODCLI+ZZ4_LOJA),1)
			@nlin,00 psay replicate('-',limite)
			nlin++
			@nlin,05 psay EXP->ZZ4_CODCLI + '/' + EXP->ZZ4_LOJA + '  ' + _descCli
			_cCodCli := EXP->(ZZ4_CODCLI+ZZ4_LOJA)
			nlin++
			@nlin,00 psay replicate('-',limite)
			nlin++
		endif

		if _cDescPro <> EXP->B1_DESC
			nlin++
			@nlin,10 psay EXP->B1_COD + ' ' + EXP->B1_DESC
			_cDescPro := EXP->B1_DESC
			nlin++
		endif

		@nlin,15 psay EXP->Z8_CONTROL
		@nlin,30 psay transform(EXP->Z8_QUANT,'@E 999')
		@nlin,40 psay transform(EXP->Z8_TARA,'@E 9.999')
		@nlin,50 psay transform(EXP->Z8_PESO,'@E 999.99')
		@nlin,65 psay STOD(EXP->Z8_DATAP)
		@nlin,80 psay EXP->Z8_HORA
		@nlin,93 psay STOD(EXP->Z8_DATAVAL)
		nlin++

		_nQuant+= EXP->Z8_QUANT
		_nCaix++
		_nPeso += EXP->Z8_PESO

		_nPCaix++
		_nPPeso  += EXP->Z8_PESO
		_nPQuant += EXP->Z8_QUANT

		EXP->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

		if _cCodCli <> EXP->(ZZ4_CODCLI+ZZ4_LOJA)
			nlin++
			@nlin,00 psay replicate('-',limite)
			nlin++
			@nlin,05 psay ' TOTAIS CAIXAS: ' + transform(_nCaix,'@E 9,999') + '     ' +;
			' TOTAIS PESO:   ' + transform(_nPeso,'@E 999,999.99') + '     ' +;
			' TOTAIS PEÇAS:  ' + transform(_nQuant,'@999,999')
			nlin++
			@nlin,00 psay replicate('-',limite)
			nlin++ 

			_nCaix  := 0
			_nPeso  := 0
			_nQuant := 0
		endif 

		if _cDescPro <> EXP->B1_DESC 
			nlin++
			@nlin,30 psay ' CAIXAS: ' + transform(_nPCaix,'@E 9,999') + '     ' +;
			' PESO: ' + transform(_nPPeso,'@E 999,999.99') + '     ' +;
			' PEÇAS: ' + transform(_nPQuant,'@999,999')
			nlin++  

			_nPCaix  := 0
			_nPPeso  := 0
			_nPQuant := 0
		endif

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('PROD')

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
