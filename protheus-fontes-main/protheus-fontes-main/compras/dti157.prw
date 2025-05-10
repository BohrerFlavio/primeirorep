#INCLUDE 'RWMAKE.ch'
#INCLUDE 'TOPCONN.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI157    º Autor ³ Adonai Gonçalves   º Data ³  10/11/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio para CSI - Pedido do Philip                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Classificação Abate                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION DTI157()
    Local cDesc1       	:= "Este programa tem como objetivo imprimir um relatorio "
	Local cDesc2       	:= "de acordo com os parametros informados pelo usuario."                  
	Local titulo       	:= "Relatório para CSI"
	Local nLin           := 80
	Local Cabec1       	:= "      Data de Produção/Data de Validade                                                                                                           N° CSN              N° Volumes         Peso Bruto (kg)   Peso Líquido(kg)"
	//Local Cabec1       	:= "       Data de Produção                    Data de Validade                  N° CSN         N° Volumes          Peso Bruto (kg)   Peso Líquido(kg)"
    Local Cabec2         := ""
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "G"
	Private nomeprog     := "DTI157" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "DTI157"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI157" // Coloque aqui o nome do arquivo usado para impressao em disco     
	//Private _cData       := Ctod("") 
	
	Private nNumReg := 0	//Armazena número de registros no relatório	
	
	Private cString := "ZZ3"

	dbSelectArea("ZZ3")
	dbSetOrder(1)

	pergunte(cPerg,.F.)
	_aDados	 := {}
	_aCabec	 := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc2,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey = 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey = 27
		Return
	Endif

	nTipo := If(aReturn[4]=1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cQuery := "SELECT B1_DESC AS PRODUTO, CAST(FORMAT(CAST(Z8_DATAP AS DATE), 'dd/MM/yyyy')AS VARCHAR) AS DATA_PR, CAST(FORMAT(CAST(Z8_DATAVAL AS DATE), 'dd/MM/yyyy')AS VARCHAR) AS DATA_VAL, COUNT(Z8_QUANT) AS VOLUMES, SUM(Z8_PESOBR) AS PESO_BR, "
    cQuery += "SUM(Z8_PESO) AS PESO_LIQ, ZZ5_QRCAIX AS TOT_VOL, ZZ5_QRPESB AS PESBR_T, ZZ5_QRPESO AS PESLIQ_T" + iif(!empty(mv_par03),", ZAC_CERCSN AS NRO_CSN ", "")
    cQuery += "FROM  " + retSqlTab('ZZ3') + " "
    cQuery += "INNER JOIN " + retSqlTab('ZZ4') + " ON (ZZ3.ZZ3_NUM = ZZ4.ZZ4_PRECAR) "
	cQuery += "INNER JOIN " + retSqlTab('ZZ5') + " ON (ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM) "
	cQuery += "INNER JOIN " + retSqlTab('SZ8') + " ON (ZZ5.ZZ5_COD = SZ8.Z8_COD) "
    cQuery += "INNER JOIN " + retSqlTab('SB1') + " ON (SZ8.Z8_COD = SB1.B1_COD) "
	cQuery += iif(!empty(mv_par03), "INNER JOIN " + retSqlTab('ZAC') + " ON (SZ8.Z8_CODTRAN = ZAC.ZAC_NUM) ", "")
    cQuery += "WHERE " + retSqlFil('ZZ5') + " AND " + retSqlFil('ZZ4') + " AND " + retSqlFil('ZZ3') + " AND " + retSqlFil('SB1') + " AND " + retSqlFil('SZ8')
	cQuery += "AND ZZ5_QRPESO <> 0 "

	if empty(mv_par03)
		cQuery += "AND ZZ3_NUM = '" + mv_par01 + "' "
		cQuery += "AND ZZ4_NUM = '" + mv_par02 + "' "
		cQuery += "AND SZ8.Z8_PREPED = '" + mv_par02 + "' "
	else
		cQuery += "AND ZAC_CERCSN = '" + mv_par03 + "' "
	endif

	cQuery += "AND " + retSqlDel('ZZ3') + " AND " + retSqlDel('ZZ4') + " AND " + retSqlDel('ZZ5') + " AND " + retSqlDel('SB1') + " AND " + retSqlDel('SZ8') + iif(!empty(mv_par03), " AND " + retSqlDel('ZAC'), "")
    cQuery += "GROUP BY B1_DESC, Z8_DATAP, Z8_DATAVAL, ZZ5_QRCAIX, ZZ5_QRPESB, ZZ5_QRPESO" + iif(!empty(mv_par03), ", ZAC_CERCSN ", "")
	cQuery += "ORDER BY Z8_DATAP"

    cQuery := ChangeQuery(cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	/*
	//Mostrar a consulta
	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	Activate Dialog oDlgMemo
	*/

	QRY->(dbgotop())

	SetRegua(QRY->(RecCount()))

	cDataProd := ""
	cDataVal := ""
	cDataProdDias := ""
	cDataValDias := ""
	nCountVol := 0
    nSumPesoBr := 0.0
	nSumPesoLi := 0.0
	lProduto := .F.

	While QRY->(!EOF())
		IncRegua()

		If lAbortPrint
			@nLin,00 psay "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

        if !lProduto
            lProduto := .T.
            @nlin,00 psay replicate("-", 215)
            nlin++
            @nlin,010 psay "Produto: " + QRY->PRODUTO
            @nlin,060 psay "Total de Volumes: " + transform(QRY->TOT_VOL, "@E 999,999") + " caixas"
            @nlin,100 psay "Peso Bruto Total: " + transform(QRY->PESBR_T, "@E 999,999.99") + " kg"
            @nlin,140 psay "Peso Líquido Total: " + transform(QRY->PESLIQ_T, "@E 999,999.99") + " kg"
            nlin++
            @nlin,00 psay replicate("-", 215)
            nlin++
            if mv_par04 = 1
                AADD(_aDados, { "Produto: ",;
				                QRY->PRODUTO,;
				                ,;
				                ,;
				                ,;
				                ,;
		        })
            endif
        endif

		cDataProd := alltrim(QRY->DATA_PR)
		aDataProdDias := {}
		Aadd(aDataProdDias, SubStr(cDataProd, 1, 2))
		cDataVal := alltrim(QRY->DATA_VAL)
		aDataValDias := {}
		Aadd(aDataValDias, SubStr(cDataVal, 1, 2))
		nCountVol := QRY->VOLUMES
		nSumPesoBr := QRY->PESO_BR
		nSumPesoLi := QRY->PESO_LIQ
		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		while SubStr(cDataProd, 4, 5) = SubStr(alltrim(QRY->DATA_PR), 4, 5)
			Aadd(aDataProdDias, SubStr(cDataProd, 1, 2))
			CheckMonth(@aDataValDias, cDataVal)						
			cDataProd := alltrim(QRY->DATA_PR)
			cDataVal := alltrim(QRY->DATA_VAL)
			nCountVol += QRY->VOLUMES
			nSumPesoBr += QRY->PESO_BR
			nSumPesoLi += QRY->PESO_LIQ
			QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		end

		Aadd(aDataProdDias, cDataProd)		// Adiciona o último dia/mês/ano no array
		CheckMonth(@aDataValDias, cDataVal)
		Atail(aDataValDias) += SubStr(cDataVal, 3)

		cDataProd := ArrToStr(aDataProdDias)		// Converte para uma única string com todos os valores do array
		cDataVal := ArrToStr(aDataValDias)

        @nlin,005 psay cDataProd
		nlin++
		if !empty(mv_par03)
			@nlin,145 psay QRY->NRO_CSN
		endif
        @nlin,165 psay transform(nCountVol, "@E 999,999")
        @nlin,190 psay transform(nSumPesoBr, "@E 999,999.99")
        @nlin,205 psay transform(nSumPesoLi, "@E 999,999.99")
		nlin++
        @nlin,005 psay cDataVal
		nlin++
		@nlin,00 psay replicate("-", 215)
        nlin++

		If mv_par04 = 1	// Gera e mostra no Excel
			AADD(_aDados, { cDataProd ,;
							cDataVal ,;
							iif(!empty(mv_par03), QRY->NRO_CSN, "") ,;
							transform(nCountVol, "@E 999,999") ,;
							transform(nSumPesoBr, "@E 999,999.99") ,;
							transform(nSumPesoLi, "@E 999,999.99") ,;
			})
		Endif

	end

    if mv_par04 = 1
        AADD(_aDados, {"Total de Volumes: ",;
				        QRY->TOT_VOL,;
				        "Peso Bruto Total: ",;
				        QRY->PESBR_T,;
				        "Peso Líquido Total: ",;
				        QRY->PESLIQ_T,;
		})
    endif

	DbCloseArea()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	If Len(_aDados) > 0		// Gera e mostra no Excel
		AADD( _aCabec, {"Data de Produção",	"C", 02, 0} )
		AADD( _aCabec, {"Data de Validade",	"C", 10, 0} )
		AADD( _aCabec, {"N° CSN",	"D", 09, 0} )
		AADD( _aCabec, {"N° de Volumes",		"C", 12, 2} )
		AADD( _aCabec, {"Peso Bruto (kg)",	"N", 12, 2} )
		AADD( _aCabec, {"Peso Líquido (R$)",	"N", 12, 2} )
		U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5] = 1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()
Return

/*
*	Checa se a próxima data é do mês seguinte e, se for, adiciona o mês e ano na data anterior
*	Ex.: ["01","10","30","04","15","16/02/2022"] -> ["01","10","30/01/2022","04","15","16/02/2022"]
*/
Static Function CheckMonth(aArray, cString)
	if Val(Atail(aArray)) > Val(SubStr(cString, 1, 2))
		if SubStr(cString, 4, 5) = "01"
			Atail(aArray) += "/12" + SubStr(cString, 6)
			Aadd(aArray, SubStr(cString, 1, 2))
		else
			Atail(aArray) += "/" + PadL(Val(SubStr(cString, 4, 5)) - 1, 2, "0") + SubStr(cString, 6)
			Aadd(aArray, SubStr(cString, 1, 2))
		endif
	else
		Aadd(aArray, SubStr(cString, 1, 2))
	endif

Return

/*
*	Passa cada valor de um array para uma string separada por vírgula
*	Ex.: [1,2,3,4,5,6] -> "1,2,3,4,5,6"
*/
Static Function ArrToStr(aArray)
	Local nCont, cStrFromArray := ""
	for nCont := 1 to Len(aArray) Step 1
		if SubStr(aArray[nCont], 1, 1) = "/"
			aArray[nCont-1] += aArray[nCont]
			aDel(aArray, nCont)
		else
			cStrFromArray := cStrFromArray + "," + aArray[nCont]
		endif
	next nCont

Return SubStr(cStrFromArray, 2)
