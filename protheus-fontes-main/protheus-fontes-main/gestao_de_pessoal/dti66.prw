#INCLUDE 'protheus.ch'
#INCLUDE 'topconn.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI66    º Autor ³ Wellington Felisberto em    16/06/18      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório para conferencia refeições   	                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE/SIGAPON   	                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI66()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "de listagem de funcionarios que marcaram "
	Local cDesc3         := "as refeições."
	//Local cPict          := ""
	Local titulo         := "Acompanhamento das Refeições "
	//                       12345678901234567890123456790123456790123456790123456790123456790123456790123456790
	Local Cabec1         := " Matricula Funcionário                        Data     Hora   Seq  Descrição                    Valor Refeição     Verba "
	Local Cabec2         := ""
	//Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI66" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI66"
	//Private cbtxt      	 := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI66" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aBatidas    := {}
	
	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZB8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If MV_PAR06 = 1
		_cQuery := " SELECT ZB8.ZB8_MAT, SRA.RA_NOME, ZB8.ZB8_DATA, ZB8.ZB8_HORA, ZB8.ZB8_CODREF, ZB8.ZB8_DSCREF, ZB8.ZB8_VLREF, ZB8.ZB8_PD"
		_cQuery += " FROM " + RetSqlName('ZB8') + " ZB8 "
		_cQuery += " INNER JOIN "+ RetSqlName("SRA") + " SRA"
		_cQuery += " ON (ZB8.ZB8_FILIAL = SRA.RA_FILIAL AND ZB8.ZB8_MAT = SRA.RA_MAT)"
		_cQuery += " WHERE SRA.D_E_L_E_T_ <> '*' AND ZB8.ZB8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' "
		_cQuery += " AND ZB8.ZB8_MAT BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 +"' "
		_cQuery += " AND " + retSqlDel('ZB8')
		If MV_PAR05 = 2
			_cQuery += " AND ZB8.ZB8_PD = '425' "
		EndIf
		If MV_PAR05 = 3
			_cQuery += " AND ZB8.ZB8_PD = '502' "
		EndIf
		_cQuery += " ORDER BY ZB8.ZB8_MAT, ZB8.ZB8_DATA, ZB8.ZB8_CODREF"
	EndIf

	If MV_PAR06 = 2
		_cQuery := " SELECT ZB8.ZB8_MAT, SRA.RA_NOME, SUM(ZB8.ZB8_VLREF) ZB8_VLREF, ZB8.ZB8_PD"
		_cQuery += " FROM " + RetSqlName('ZB8') + " ZB8 "
		_cQuery += " INNER JOIN "+ RetSqlName("SRA") + " SRA"
		_cQuery += " ON (ZB8.ZB8_FILIAL = SRA.RA_FILIAL AND ZB8.ZB8_MAT = SRA.RA_MAT)"
		_cQuery += " WHERE SRA.D_E_L_E_T_ <> '*' AND ZB8.ZB8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' "
		_cQuery += " AND ZB8.ZB8_MAT BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 +"' "
		_cQuery += " AND " + retSqlDel('ZB8')
		If MV_PAR05 = 2
			_cQuery += " AND ZB8.ZB8_PD = '425' "
		EndIf
		If MV_PAR05 = 3
			_cQuery += " AND ZB8.ZB8_PD = '502' "
		EndIf
		_cQuery += " GROUP BY ZB8.ZB8_MAT, SRA.RA_NOME, ZB8.ZB8_PD "
		_cQuery += " ORDER BY ZB8.ZB8_MAT, ZB8.ZB8_PD"
	EndIf

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZB8')

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

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())
	nLin    := 7
	_cMat   := ''
	_nVrRef := 0
	_cPri   := '*'
	_nTRef  := 0
	_cCont  := 0
	While TMP->(!EOF())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 70 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 7
		Endif
		//123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		//Matricula Funcionário                        Data     Hora   Seq  Descrição                    Valor Refeição     Verba

		if _cMat <> TMP->ZB8_MAT			
			@nlin,01 psay replicate('-',132)
			nlin++
			if _cPri = '*'
				_cPri := ''
			else
				@nlin,11 psay 'Marcações:' + cValtoChar(_cCont)
				@nlin,62 psay 'Sub Total '
				@nlin,99 psay transform(_nVrRef,'@E 999.99')
				nLin++
				@nlin,01 psay replicate('-',132)
				nLin++
				_nVrRef := 0
			endif	    
			@nLin,02 PSAY TMP->ZB8_MAT
			@nlin,11 psay TMP->RA_NOME 
			//nLin++                       
			_cMat := TMP->ZB8_MAT
			_nVrRef := 0
			_cCont := 0
		endif	

		If MV_PAR06 = 1
			@nlin,45 psay dtoc(stod(TMP->ZB8_DATA))
			@nlin,55 psay strtran(transform(TMP->ZB8_HORA,'@E 99.99'),',',':')
			@nlin,62 psay TMP->ZB8_CODREF
			@nlin,67 psay Left(TMP->ZB8_DSCREF,18)
		EndIf
		If MV_PAR06 = 2
			If TMP->ZB8_PD = '425'
				@nlin,67 psay 'Almoço/Janta'
			EndIf
			If TMP->ZB8_PD = '502'
				@nlin,67 psay 'Café manhã/tarde'
			EndIf		
		EndIf
		@nlin,99 psay transform(TMP->ZB8_VLREF,'@E 999.99')
		@nlin,116 psay TMP->ZB8_PD
		//@nlin,120 psay cValToChar(MV_PAR05)

		_nVrRef := _nVrRef + TMP->ZB8_VLREF
		_nTRef := _nTRef + TMP->ZB8_VLREF 
		If MV_PAR06 = 1
			_cCont++
		Else
			_cCont := 0
			If TMP->ZB8_PD = '425'
				_cCont += TMP->ZB8_VLREF/8.3 
			EndIf
			If TMP->ZB8_PD = '502'
				_cCont += TMP->ZB8_VLREF/2.7
			EndIf
		EndIf
		nlin++	

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo	
	@nlin,01 psay replicate('-',132)
	nlin++
	@nlin,11 psay 'Marcações:' + cValtoChar(_cCont)
	@nlin,62 psay 'Sub Total '
	@nlin,99 psay transform(_nVrRef,'@E 999.99')
	nlin++
	@nlin,01 psay replicate('-',132)
	nlin++
	@nlin,62 psay 'Total Geral'
	@nlin,96 psay transform(_nTRef,'@E 99,999.99')

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
