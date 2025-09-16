#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI10    º Autor ³ Fabian Maurer º Data ³ 28/07/16          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de analise da produção da desossa de Terceiros	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle de Produção                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI10()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia da produção da desossa de terceiros"
	Local cDesc3         := " "
	//Local cPict          := " "
	Local titulo         := "(R20) RELATORIO PARA ANALISE DE PROD. DESOSSA DE TERCEIROS"
	Local Cabec1         := "  CERTIFICADO        SEQ. ABATE             NUM. PEÇA         PESO"
	Local Cabec2         := "" 
	//Local imprime         := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "DTI10" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI10"
	//Private cbtxt      	  := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI10" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aSubTot     := {}
	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZAJ',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cQuery := "SELECT ZAJ_CORORI AS CORORI,ZAJ_NUM AS NUM,ZAJ_PESO AS PESO, ZAJ_HORAS AS HRPROD, ZAJ_DATAS AS DTPROD, ZAJ_DEST AS DEST,"
	_cQuery += " ZAP_NUM, ZAP_CERT AS CERT, ZAP_DATAP AS DATAP, ZAP_CLASSI AS CLASSI, ZAP_CORORI AS CODORI, ZAP_MENS AS MENS"
	_cQuery += " FROM  " + retSQLTab('ZAJ')
	_cQuery += " INNER JOIN " + retSqlTab('ZAP') + " ON (ZAJ_ZAPNUM = ZAP_NUM)"
	_cQuery += " WHERE " + retSQLFil('ZAJ') + " AND " + retSqlFil('ZAP')
	_cQuery += " AND ZAJ_NUMAM = '' AND ZAJ_ZAPNUM <> ''"
	_cQuery += " AND ZAJ_DATAS <> ''"
	_cQuery += " AND (ZAJ_DATAS BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + 	"')"
	_cQuery += " AND (ZAJ_HORAS BETWEEN '" + iif(empty(mv_par08), '00:00', StrTran(padL(alltrim(transform(mv_par08, "@E 99.99")), 5, '0'), ',', ':')) + "' AND '" + iif(empty(mv_par09), '23:59', StrTran(padL(alltrim(transform(mv_par09, "@E 99.99")), 5, '0'), ',', ':')) + "')"

	if mv_par03 <> 5
		_cQuery += " AND ZAJ_CORORI = '" + iif(mv_par03 = 1,'D',iif(mv_par03 = 2, 'T',iif(mv_par03 = 3, 'C','0'))) + "'"
	endif

	if !empty(mv_par04)
		_cQuery += " AND ZAP_NUM = '" + mv_par04 + "'"
	endif

	if !empty(mv_par05)
		_cQuery += " AND ZAP_CLASSI = '" + mv_par05 + "'"
	endif

	if mv_par06 = 1 //se destino for desossa
		if mv_par11 = 1
			_cQuery += " AND ((ZAJ_DEST = 'O' AND ZAJ_PRECAR <> '') OR (ZAJ_DEST = 'D' AND ZAJ_PRECAR = ''))"
		else
			_cQuery += " AND ZAJ_DEST = 'D' AND ZAJ_PRECAR = ''"
		endif
	elseif mv_par06 = 2 //se destino for costela
		if mv_par11 = 1
			_cQuery += " AND ((ZAJ_DEST = 'O' AND ZAJ_PRECAR <> '') OR (ZAJ_DEST = 'C' AND ZAJ_PRECAR = ''))"
		else
			_cQuery += " AND ZAJ_DEST = 'C' AND ZAJ_PRECAR = ''"
		endif
	elseif mv_par06 = 3 //se destino for carregamento
		if mv_par11 = 1
			_cQuery += " AND ((ZAJ_DEST = 'O' AND ZAJ_PRECAR <> '') OR (ZAJ_DEST = 'R' AND ZAJ_PRECAR <> ''))"
		else
			_cQuery += " AND ZAJ_DEST = 'R' AND ZAJ_PRECAR <> ''"
		endif
	endif

	_cQuery += " AND " + retSQLDel('ZAJ') + " AND " + retSQLDel('ZAP')

	if mv_par10 = 1
		_cQuery += " ORDER BY ZAJ_DATAS, ZAJ_HORAS, ZAP_DATAP, ZAP_CERT"
	else
		_cQuery += " ORDER BY ZAP_DATAP, ZAP_CERT"
	endif

	_cQuery  := ChangeQuery(_cQuery)

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAJ')

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
	Local i

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	_cNumam 		:= ''
	_cDtDes  		:= ''
	_cDtAbt			:= ''
	_cCert 			:= ''
	_aCertif        := {}

	//_nQtdPecDia := 0
	//_nQtdPesDia := 0

	_nTpecAbD := 0 //Total de Dianteiros do Abate
	_nTpesAbD := 0 //Total de Peso dos Dianteiros

	_nTpecAbT := 0 //Total de Traseiros do Abate
	_nTpesAbT := 0 //Total de Peso dos Traseiros

	_nTpecAbC  := 0 //Total de Costela do Abate
	_nTpesAbC  := 0 //Total de Peso dos Costela

	_nTpecDiaD := 0 //Total de Dianteiros do Dia
	_nTpesDiaD := 0 //Total de Peso dos Dianteiros

	_nTpecDiaT := 0 //Total de Traseiros do Dia
	_nTpesDiaT := 0 //Total de Peso dos Traseiros

	_nTpecDiaC  := 0 //Total de Costela do Dia
	_nTpesDiaC  := 0 //Total de Peso dos Costela

	_nQTD     := 0          //Quantidade de animais por aviso 
	_nQtdHK   := 0	         //Quantidade de Animais HK
	_nQtdNE   := 0          //Quantidade de Animais NE
	_nQtdRU   := 0			   //Quantidade de Animais RU
	_nQtdRT   := 0 		   //Quantidade de Animais RT
	_nQtHKUy  := 0 		   //Quantidade de Animais HK - UY
	_nQtRuUy  := 0			   //Quantidade de Animais RU - UY

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

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if _cDtDes <> TMP->DTPROD
			@nlin,001 psay replicate('=',132)
			nlin++
			@nlin,001 psay "Data da Desossa: "
			@nlin,020 psay stod(TMP->DTPROD)
			nlin++
			@nlin,001 psay replicate('=',132)
			nlin++
			_cDtDes := TMP->DTPROD
			//_nQtdPecDia++      
			//_nQtdPesDia += TMP->PESO
		endif

		if _cDtAbt <> TMP->DATAP
			@nlin,001 psay replicate('-',132)
			nlin++
			@nlin,001 psay "Data de Abate: "
			@nlin,020 psay stod(TMP->DATAP)
			nlin++
			@nlin,001 psay replicate('-',132)
			nlin++
			_cDtAbt := TMP->DATAP
		endif

		if _cCert <> TMP->CERT
			@nlin,001 psay 'Certificado: '
			@nlin,020 psay TMP->CERT
			@nlin,042 psay " | "
			@nlin,045 psay TMP->CLASSI 
			@nlin,050 psay " | "
			@nlin,053 psay TMP->MENS
			nlin+=2
			_cCert := TMP->CERT
		endif

		_nPos := aScan(_aCertif,{|aVal|aVal[1] = TMP->CERT+TMP->CORORI})
		if _nPos <> 0
			_aCertif[_npos,2] += TMP->PESO
			_aCertif[_npos,3] := TMP->CORORI
			_aCertif[_npos,4] ++
		else
			aadd(_aCertif,{TMP->CERT+TMP->CORORI,TMP->PESO,TMP->CORORI,1})
		endif

		if mv_par07 = 1
			@nlin,020 psay TMP->HRPROD
			@nlin,027 psay " | "   
			@nlin,041 psay TMP->NUM
			@nlin,053 psay " | "
			@nlin,060 psay iif(TMP->CORORI = 'D','Dianteiro',iif(TMP->CORORI = 'T','Traseiro',iif(TMP->CORORI = 'C','Costela',''))) 
			@nlin,068 psay " | "
			@nlin,073 psay transform(TMP->PESO,'@E 999.99')
			if TMP->DEST = 'O'
				@nlin,080 psay " | "
				@nlin,085 psay "BAIXA"
			endif
			nlin++
		endif   

		Do Case	                  
			Case (TMP->CORORI = 'D')
			_nTpecAbD++ 					//Total de Dianteiros do Abate
			_nTpesAbD += TMP->PESO  	//Total de Peso dos Dianteiros

			_nTpecDiaD++ 					//Total de Dianteiros do Dia
			_nTpesDiaD += TMP->PESO  	//Total de Peso dos Dianteiros			

			Case (TMP->CORORI = 'T') 
			_nTpecAbT++ 					//Total de Traseiros do Abate
			_nTpesAbT += TMP->PESO 	//Total de Peso dos Traseiros

			_nTpecDiaT++ 					//Total de Traseiros do Dia
			_nTpesDiaT += TMP->PESO 	//Total de Peso dos Traseiros

			Case (TMP->CORORI = 'C') 
			_nTpecAbC++ 					//Total de Costela do Abate
			_nTpesAbC += TMP->PESO 	//Total de Peso dos Costela

			_nTpecDiaC++ 					//Total de Costela do Dia
			_nTpesDiaC += TMP->PESO 	//Total de Peso dos Costela			
		Endcase		

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo    
		if _cCert <> TMP->CERT .or. TMP->(eof())

			for i:=1 to len(_aCertif)
				@nlin,005 psay substr(_aCertif[i,1],1,11)
				@nlin,095 psay transform(_aCertif[i,2], '@E 999,999')
				@nlin,050 psay transform(_aCertif[i,4], '@E 999,999')
				@nlin,030 psay iif(_aCertif[i,3] = 'D','Dianteiro',iif(_aCertif[i,3] = 'T','Traseiro','Costela'))
				nlin++
			next

			_aCertif := {}

		endif

		//Totalizador referenciado nos dias postos nos parametros
		if _cDtDes <> TMP->DTPROD .or. TMP->(eof())

			If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif 

			nlin++
			@nlin,50 psay "P E Ç A S"
			@nlin,72 psay "P E S O"
			nlin++

			@nlin,05 psay "Total de Dianteiros Produzidos no Dia --->
			@nlin,50 psay transform(_nTpecDiaD,'@E 9999')
			@nlin,70 psay transform(_nTpesDiaD,'@E 999,999.99')
			nlin++

			@nlin,05 psay "Total de Traseiros Produzidos no Dia  --->
			@nlin,50 psay transform(_nTpecDiaT,'@E 9999')
			@nlin,70 psay transform(_nTpesDiaT,'@E 999,999.99')
			nlin++

			@nlin,05 psay "Total de Costelas Produzidos  no Dia  --->
			@nlin,50 psay transform(_nTpecDiaC,'@E 9999')
			@nlin,70 psay transform(_nTpesDiaC,'@E 999,999.99')
			nlin++

			_nTpecDiaD := 0 //Total de Dianteiros do Dia
			_nTpesDiaD := 0 //Total de Peso dos Dianteiros

			_nTpecDiaT := 0 //Total de Traseiros do Dia
			_nTpesDiaT := 0 //Total de Peso dos Traseiros

			_nTpecDiaC := 0 //Total de Costela do Dia
			_nTpesDiaC := 0 //Total de Peso dos Costela

		endif

	EndDo 

	If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

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

//	//	* Mostrar a consulta */
//	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
//	@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
//	Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return
