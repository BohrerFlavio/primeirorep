#INCLUDE "topconn.ch"  
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch" 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI26     ºAutor  ³Flávio Bohrer Flôresº Data ³  19/02/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fonte destinado à visualização do horario de intervalo     º±±
±±º          ³ dos funcionários antes de efetuar a alteração			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Direçao	Ivon   	                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  


User Function dti50()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia das horas antes do ajuste da rotina 'DTI51'."
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo         := "RELAT. DE INTERVALO DE HORAS (ANTES AJUSTE )"
	Local Cabec1         := space(25)+"Matrícula     Nome"+space(30)+"Hra Saída"+space(5)+"Hra Entrada "+space(5)+"Intervalo"+space(5)+"Per.Intervalo"
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "DTI50" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "DTI50"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI50" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aBatidas  := {}

	pergunte(cPerg,.F.)               

	wnrel := SetPrint('SP8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)                    

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })                              

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SP8')

	If nLastKey == 27
		Return
	Endif   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local nOrdem

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	TMP->(SetRegua(RecCount()))
	TMP->(dbGoTop())

	_cMat     := TMP->MAT
	_nCont    := 0
	_nBatida  := 0  //utilizado no vetor
	_nHora    := 0  //utilizado no vetor
	_cData    := '' //ctod('//') //utilizado no vetor
	_cCC      := '' //utilizado no vetor

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


		if _cMat = TMP->MAT
			_nCont++ //contador de batidas por funcionario
		else
			_cMat  := TMP->MAT
			_nCont := 1
		endif

		_nPos := aScan(_aBatidas,{|aVal|aVal[1] = TMP->MAT})

		if _nPos <> 0
			if _nCont = 2
				_aBatidas[_npos,2] := _nCont
				_aBatidas[_npos,3] := TMP->HORA
				_aBatidas[_npos,4] := TMP->DATA
				_aBatidas[_npos,5] := TMP->CC
				_aBatidas[_npos,6] := 0  // segunda batida
			elseif _nCont = 3
				//alert(TMP->HORA)
				_aBatidas[_npos,6] := TMP->HORA  
			Endif
		else
			aadd(_aBatidas,{TMP->MAT,_nBatida,_nHora,_cData,_cCC,_nHora})		
		endif
		//if TMP->MAT = '006050' .AND. TMP->DATA = '20180201'
		//alert(_nCont)
		//endif
		if _nCont = 4 //se o funcionario tiver o total de 4 batidas

			_cHoraS := _aBatidas[_npos,3]
			_cHoraE := _aBatidas[_npos,6]


			if (_cData <> _aBatidas[_npos,4])  //quebra por data
				@nlin,01 psay replicate('-',132)
				nlin++
				@nlin,01 psay "Data: "
				@nlin,10 psay stod(_aBatidas[_npos,4])
				nlin++
				@nlin,01 psay replicate('-',132)
				nlin++
				_cData := _aBatidas[_npos,4]

			Endif

			if (_cCC <> _aBatidas[_npos,5])  //quebra por centro de custo

				@nlin,01 psay "Centro de Custo: "
				@nlin,18 psay alltrim(_aBatidas[_npos,5])
				nlin++
				_cCC := _aBatidas[_npos,5]

			Endif
			/*
			_nHraEnt := fConvHr(SRA->RA_HRAENT,'D')//SRA->RA_HRAENT   
			_nDif := _nHraEnt - _nHraP8
			@nlin,115 psay StrTran(Transform( fConvHr( _nDif,'H'), '@e 9999.99' ),',',':' )
			_cHoraS := StrTran(transform(_aBatidas[_npos,3],'@E 99.99'),',',':')
			_cHoraE := StrTran(transform(_aBatidas[_npos,6],'@E 99.99'),',',':')  
			*/
			_nHrInt := fConvHr(fbuscaCpo('SRA',1,xFilial('SRA') + alltrim(TMP->MAT),'RA_HRAINT'),'D')						
			_nHraSc := fConvHr(_cHoraS,'D')// Convertendo hora Saida
			_nHraEc := fConvHr(_cHoraE,'D')// Convertendo hora entrada
			_nDif := _nHraEc - _nHraSc
			@nlin,025 psay TMP->MAT
			@nlin,037 psay substr(TMP->NOME,1,30)
			@nlin,073 psay StrTran(transform(_aBatidas[_npos,3],'@E 9999.99'),',',':')   //intervalo
			@nlin,88 psay StrTran(transform(_aBatidas[_npos,6],'@E 9999.99'),',',':') //StrTran(transform(TMP->HORAA),'@E 9999.99'),',',':') //refeição
			@nlin,103 psay StrTran(Transform( fConvHr(_nDif,'H'), '@e 9999.99' ),',',':' )
			@nlin,118 psay StrTran(Transform( fConvHr(_nHrInt,'H'), '@e 9999.99' ),',',':' )
			nlin++			

		Endif

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

	_cQuery := " SELECT P8_MAT AS MAT, P8_DATA AS DATA, P8_HORA AS HORA, P8_CC AS CC,RA_NOME AS NOME"
	_cQuery += " FROM  " + retSqlTab('SP8')+ ", " + RetSQLTab('SRA')
	_cQuery += " WHERE " + retSqlFil('SP8') + " AND " + RetSQLFil('SRA')
	_cQuery += " AND P8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += " AND P8_CC >= '" + mv_par03 + "' AND P8_CC <= '" + mv_par04 + "'"
	_cQuery += " AND P8_TPMCREP <> 'D'  AND P8_MAT = RA_MAT  AND" + retSqlDel('SP8')  + " AND " + RetSQLDel('SRA')
	_cQuery += " ORDER BY P8_DATA,P8_CC, P8_MAT, P8_HORA


	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	/*@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	Activate Dialog oDlgMemo
	*/
	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"
return

