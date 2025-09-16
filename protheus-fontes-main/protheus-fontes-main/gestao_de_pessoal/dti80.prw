#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI80    º Autor ³ Flávio Bohrer Flôresº Data ³  15/02/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Quantidades de Dias trabalhados               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Departamento Pessoal						                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

user Function DTI80()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2        := "de contagem de dias trabalhados no"
	Local cDesc3        := "Período de apontamento Atual."
	
	Local titulo        := "RELATORIO DE CONTAGEM DE DIAS TRABALHADOS"
	Local nLin          := 80
	Local Cabec1       	:= "Matricula"+space(5)+"NOME"+space(40)+"CC"+space(5)+"Quant. Dias Trab."+space(10)+"Tipo de Vale"
	Local Cabec2       	:= ""
	
	Local aOrd 			:= {}
	
	Private aArea		:= GetArea()
	Private lRetorno	:= .T.
	Private cArqTrab	:= ""
	Private aInd		:= {}	
	Private aCampos		:= {}
	Private aStru     	:= {}
	
	Private _dIniPer    := stod("")
	Private _dFimPer	:= stod("")
	Private _cDtPeriodo := GETMV('MV_PAPONTA')
	Private _dDataIni	:= stod("")
	Private _dDataCorrente := stod("")		
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "M"
	Private nomeprog    := "DTI80" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "DTI80"
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI80" // Coloque aqui o nome do arquivo usado para impressao em disco
	

	pergunte(cPerg,.F.)
	wnrel := SetPrint('SP8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	
	//Monta cQuery
	MsgRun("Aguarde... Realizando contagem de registros...",,{|| mQuery() })
	
	
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

Static Function cHoras(_cMat)
	
	Local _dIni :=  mv_par01
	Local _dFin :=  mv_par02
	Local _nDias := 0
	Local _dDataCorrente := stod("")
	_dIniPer  := _dIni
	_dFimPer  := _dFin
	_dInicial := skDataIni(alltrim(_cMat),_dIniPer,_dFimPer)

	DbSelectArea('SP8')
	SP8->(DbSetOrder(2))
	SP8->(DbGoTop())
	if SP8->(DbSeek(xFilial('SP8') + _cMat + _dInicial))

		if _dDataIni < _dIniPer
			_dDataIni := _dIniPer
		endif

		//enquanto a data das marcações da SP8 estiverem entre as datas do parametro MV_PAPONTA
		while SP8->(!eof()) .and. xFilial('SP8') == SP8->P8_FILIAL .and. alltrim(_cMat) == alltrim(SP8->P8_MAT) .and. SP8->P8_DATAAPO <= _dFimPer
			
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
		
			/*Ignora marcações que foram rejeitadas automaticamente pelo sistema */
			if SP8->P8_TIPOREG = 'O' .and. !empty(alltrim(SP8->P8_MOTIVRG))
				SP8->(DbSkip())
				loop
			endif

			/*Ignora marcações que foram excluidas manualmente*/
			if SP8->P8_TIPOREG = 'I' .and. (SP8->P8_MOTIVRG $ 'MARC INVERTIDA' .or. SP8->P8_MOTIVRG $ 'MARCACAO INVERTIDA')
				SP8->(DbSkip())
				loop
			endif

			/*Ignora marcações que foram Marca*/
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
			
			if _dDataCorrente = SP8->P8_DATAAPO
				SP8->(DbSkip())
				loop
			else
				_dDataCorrente := SP8->P8_DATAAPO
			endif
			
			_nDias ++
			
			SP8->(DbSkip())
		enddo
	endif

	
return (_nDias)

Static Function skDataIni(cMat,_dtIni,_dtFim)

	_cQuery2 := " SELECT TOP 1 P8_DATAAPO
	_cQuery2 += " FROM " + retSqlTab('SP8')
	_cQuery2 += " WHERE " + retSqlFil('SP8')
	_cQuery2 += " AND P8_DATAAPO BETWEEN '" + dtos(_dtIni) + "' AND '" + dtos(_dtFim) + "'"
	_cQuery2 += " AND P8_MAT = '" + cMat + "'"
	_cQuery2 += " AND " + retSqlDel('SP8')
	_cQuery2 += " ORDER BY P8_DATAAPO

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */	 
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	
	
	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"
	TMP2->(dbGoTOp())

return TMP2->P8_DATAAPO


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	
	Local _nD := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))
	TMP->(dbGoTop())
	
	While TMP->(!EOF())

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
		_nD := cHoras(alltrim(TMP->RA_MAT))
	
		if _nD = 0
			TMP->(dbSkip())
			loop
		endif
		
		@nlin,01 psay TMP->RA_MAT
		@nlin,12 psay substr(TMP->RA_NOMECMP,1,35)
		@nlin,55 psay TMP->RA_CC	
		@nlin,70 psay _nD	
		
		// A=ATU;F=Formigueiro;S=Sao Sepe;V=Fretado;B=Vila Block;T=ATU/Fretado                                                             	
		IF TMP->RA_TPVAL = 'A'
			@nlin,95 psay "ATU"
		Elseif TMP->RA_TPVAL = 'F'
		
			@nlin,95 psay "Formigueiro"
			
		Elseif TMP->RA_TPVAL = 'S'
		
			@nlin,95 psay "São Sepé"
		Elseif TMP->RA_TPVAL = 'V'
		
			@nlin,95 psay "Fretado"
		Elseif TMP->RA_TPVAL = 'B'
		
			@nlin,95 psay "Vila Block"
		Elseif TMP->RA_TPVAL = 'T'
		
			@nlin,95 psay "ATU/Fretado"
		Else
			
			@nlin,95 psay "Sem tipo de vale Definido"
		
		Endif
		
		
		nlin++
		
		TMP->(dbSkip())
		
	Enddo
	
	
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


Static Function mQuery()

	
	_cQuery := " SELECT RA_MAT, RA_NOMECMP, RA_CC, RA_ACORHE, RA_TPVAL
	_cQuery += " FROM " + retSqlTab('SRA')
	_cQuery += " WHERE " +  retSqlFil('SRA')
	_cQuery += " AND RA_MAT BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	_cQuery += " AND RA_CC BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"	
	_cQuery += " AND " + retSqlDel('SRA')
	_cQuery += " ORDER BY RA_CC,RA_NOMECMP,RA_MAT

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

//--------------------------


