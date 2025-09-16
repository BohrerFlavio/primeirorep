#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR48     ºAutor  ³Mauricio Roehrs     º Data ³  15/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Relatorio para analise de peças de terceiro em estoque   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MLR48()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para analise de peças de terceiro em estoque."
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo         := "PECAS DE TERCEIRO EM ESTOQUE"
	Local Cabec1         := "Certificado    Data Abate    Dianteiro   Traseiro    Costela"
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "MLR48" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	:= "MLR48"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "MLR48" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aBatidas  	:= {}
	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZP',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cQuery := " SELECT ZAP_NUM, ZAP_CERT, ZAP_DATAP, ZAP_CLASSI
	_cQuery += " FROM  " + retSqlTab("ZAP")
	_cQuery += " WHERE " + retSqlFil("ZAP")
	_cQuery += " AND ZAP_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02+"'"
	_cQuery += " AND " + retSqlDel("ZAP")
	_cQuery += " GROUP BY ZAP_NUM,ZAP_CERT, ZAP_DATAP, ZAP_CLASSI
	_cQuery += " ORDER BY ZAP_CERT, ZAP_CLASSI

	_cQuery  := ChangeQuery(_cQuery)

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

	_cCert    := ''
	_cCertAux := TMP->ZAP_CERT
	_nCol     := 5
	_nDiant   := 0
	_nCost    := 0
	_nTras    := 0
	_cClas	  := ''
	While TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if _cCert <> TMP->ZAP_CERT
			@nlin,01 psay alltrim(TMP->ZAP_CERT)
			@nlin,15 psay stod(TMP->ZAP_DATAP)
			nlin++
			@nlin,26 psay alltrim(TMP->ZAP_CLASSI)
			_cCert := TMP->ZAP_CERT
		endif
		
		if _cCertAux == TMP->ZAP_CERT

			filtraCortes(TMP->ZAP_NUM)

			while QRY->(!eof())
				if QRY->CORORI == 'D'
					_nDiant += QRY->QUANT
				elseif QRY->CORORI == 'T'
					_nTras += QRY->QUANT
				elseif QRY->CORORI == 'C'
					_nCost += QRY->QUANT
				endif
				QRY->(dbSkip())
			enddo
		endif
		

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if _cCertAux != TMP->ZAP_CERT

			
			@nlin,30 psay transform(_nDiant,'@E 999999')
			@nlin,40 psay transform(_nTras,'@E 999999')
			@nlin,50 psay transform(_nCost,'@E 999999')
			nlin++
			@nlin,01 psay replicate('=',60)
			nlin++
			_nDiant := 0
			_nTras  := 0
			_nCost  := 0
			_cCertAux := TMP->ZAP_CERT
		endif

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

Static Function filtraCortes(_cNum)

	_cQuery2 := " SELECT COUNT(ZAJ_CORORI) AS QUANT,ZAJ_CORORI AS CORORI
	_cQuery2 += " FROM  " + retSqlTab("ZAJ")
	_cQuery2 += " WHERE " + retSqlFil("ZAJ")
	_cQuery2 += " AND ZAJ_ZAPNUM = '" +_cNum + "'"
	_cQuery2 += " AND ZAJ_DATAS = '' AND ZAJ_HORAS = '' AND ZAJ_PREPED = '' AND ZAJ_PRECAR = '' AND ZAJ_ITEM = ''"
	_cQuery2 += " AND " + retSqlDel("ZAJ")
	_cQuery2 += " GROUP BY ZAJ_CORORI
	_cQuery2 += " ORDER BY ZAJ_CORORI

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "QRY"

return

/*_cQuery := " SELECT COUNT(ZAJ_CORORI) AS QUANT,ZAJ_CORORI AS CORORI
_cQuery += " FROM  " + retSqlTab("ZAJ")
_cQuery += " WHERE " + retSqlFil("ZAJ")
_cQuery += " AND ZAJ_ZAPNUM IN (SELECT ZAP_NUM FROM " + retSQlTab("ZAP")
_cQuery += "                    WHERE " + retSqlFil("ZAP") + "
_cQuery += "                    AND ZAP_CERT BETWEEN '" + mv_par01 + "' AND '" +mv_par02 + "'"
_cQuery += "                    AND " + retSqlDel("ZAP") + ")"
_cQuery += " AND ZAJ_DATAS = '' AND ZAJ_HORAS = '' AND ZAJ_PREPED = '' AND ZAJ_PRECAR = '' AND ZAJ_ITEM = ''"
_cQuery += " AND " + retSqlDel("ZAJ")
_cQuery += " GROUP BY ZAJ_CORORI
_cQuery += " ORDER BY ZAJ_CORORI    */
