#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR33    º Autor ³ Mauricio Roehrs em  27/01/2014           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio para Conf. Empenho x Estoque	.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial      		                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR33()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia de Empenho de produtos maior que"
	Local cDesc3         := "o que há em estoque."
	Local cPict          := "vai porra"
	Local titulo         := "RELATORIO PARA CONF. ESTOQUE / EMPENHO"
	Local Cabec1         := "                 Codigo                 Produto                        Estoque      Estoque                   Empenho   Empenho"
	Local Cabec2         := "                                                                       Caixas        Peso                     Caixas     Peso  "
	Local imprime         := .T.
	Local aOrd            := {}  
	Private nLin           := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "MLR33" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg   		 := "MLR33"
	Private cbtxt      	:= Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "MLR33" // Coloque aqui o nome do arquivo usado para impressao em disco    
	pergunte(cPerg,.F.)


	wnrel := SetPrint('SB1',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	_dData := mv_par01  
	_cFarm := iif(mv_par03 = 1,'R',iif(mv_par03 = 2,'C',iif(mv_par03 = 3,'S','')))



	_cQuery := " SELECT B1_COD AS COD, B1_DESCRED AS DESCRED,


	//Estoque                                   
	_cQuery += " 			(SELECT COUNT(Z8_COD) "
	_cQuery += " 			 FROM " + RetSQLTab('SZ8') 
	_cQuery += " 			 WHERE " + RetSQLFil('SZ8') 
	_cQuery += " 			 AND Z8_FIL = '" + cFilAnt + "' AND B1_COD = Z8_COD "
	_cQuery += " 			 AND Z8_DATAS = '' AND Z8_HORAS = '' AND Z8_PREPED = '' AND Z8_PRECAR = '' AND Z8_ITEM = '' AND B1_MSBLQL = '2' "
	_cQuery += " 			 AND " + RetSQLDel('SZ8') +") AS ESTC, 

	_cQuery += " 			(SELECT SUM(Z8_PESO) "
	_cQuery += " 			 FROM " + RetSQLTab('SZ8') 
	_cQuery += " 			 WHERE " + RetSQLFil('SZ8') 
	_cQuery += " 			 AND Z8_FIL = '" + cFilAnt + "' AND B1_COD = Z8_COD  "
	_cQuery += " 			 AND Z8_DATAS = '' AND Z8_HORAS = '' AND Z8_PREPED = '' AND Z8_PRECAR = '' AND Z8_ITEM = '' AND B1_MSBLQL = '2' "
	_cQuery += " 			 AND " + RetSQLDel('SZ8') +") AS ESTP, 

	//Empenho
	_cQuery += " (SELECT SUM(ZZ5_QPCAIX - ZZ5_QRCAIX) 
	_cQuery += "  FROM  " + RetSQLTab('ZZ5') + "  ,  " + RetSQLTab('ZZ4') 
	_cQuery += "  WHERE " + RetSQLFil('ZZ5') + " AND " + RetSQLFil('ZZ4') + " AND B1_COD = ZZ5_COD AND ZZ5_NUM = ZZ4_NUM AND"
	_cQuery += "  ZZ4_TPOPER = 'V' AND ZZ4_STATUS NOT IN('E','F') AND (ZZ4_PRECAR BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "') AND " + RetSQLDel('ZZ5')
	_cQuery += "  AND   " + RetSQLDel('ZZ4') + ") AS EMPCAIX,

	_cQuery += " (SELECT SUM(ZZ5_QPPESO - ZZ5_QRPESO) 
	_cQuery += "  FROM  " + RetSQLTab('ZZ5') + "  ,  " + RetSQLTab('ZZ4') 
	_cQuery += "  WHERE " + RetSQLFIl('ZZ5') + " AND " + RetSQLFil('ZZ4') + " AND B1_COD = ZZ5_COD AND ZZ5_NUM = ZZ4_NUM AND"
	_cQuery += "  ZZ4_TPOPER = 'V' AND ZZ4_STATUS NOT IN('E','F') AND (ZZ4_PRECAR BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "') AND " + RetSQLDel('ZZ4') + " 
	_cQuery += "  AND   " + RetSQLDel('ZZ5') + ") AS EMPPES       

	_cQuery += " FROM  " + RetSQLTab('SB1') + "  ,  " + RetSQLTab('SBM') + ", " + RetSQLTab('ZZ4') + " , " + RetSQLTab('ZZ5') + " 
	_cQuery += " WHERE " + RetSQLFil('SB1') + " AND " + RetSQLFil('SBM') + " AND " + RetSQLFil('ZZ5') + " AND " + RetSQLFil('ZZ4') + " 
	_cQuery += " AND B1_TIPO = 'PA' AND B1_SEGUM = 'CX' AND B1_MSBLQL = '2'" 
	_cQuery += " AND ZZ4_NUM = ZZ5_NUM AND ZZ5_COD = B1_COD AND ZZ4_TPOPER = 'V' AND ZZ4_STATUS NOT IN('E','F') AND "
	_cQuery += " (ZZ4_PRECAR BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "') AND 
	_cQuery += " B1_GRUPO = BM_GRUPO AND"

	if _cFarm <> ''
		_cQuery += " BM_FARM = '" +_cFarm + "' AND "   
	endif 

	if !empty(mv_par04)
		_cQuery += " B1_COD = '" + mv_par04 + "' AND"
	endif   

	_cQuery += " B1_COD IN(SELECT ZZ5_COD 
	_cQuery += " 			  FROM  " + RetSQLTab('ZZ4') + "  ,  " + RetSQLTab('ZZ5') 
	_cQuery += " 			  WHERE " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ5') + " AND ZZ5_NUM = ZZ4_NUM AND ZZ4_TPOPER = 'V' AND" 
	_cQuery += "           ZZ4_STATUS NOT IN('E','F','P') AND 
	_cQuery += " 			  (ZZ4_PRECAR BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "') AND  " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5') + ")
	_cQuery += " AND " + RetSQLDel('SB1','SBM','ZZ4','ZZ5')
	_cQuery += " GROUP BY B1_COD, B1_DESCRED,B1_MSBLQL
	_cQuery += " ORDER BY B1_COD

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraQRY() })



	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SB1')

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
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_cCod 		:= ''
	_cPrecars   := ''          
	_aPrecars   := {}
	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	_cCod := TMP->COD

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

		if TMP->EMPCAIX > TMP->ESTC		

			//_cPrecars := VerPreCar(TMP->COD)
			_aPrecars := VerPreCar(TMP->COD)

			@nlin,012 psay TMP->COD
			@nlin,030 psay substr(TMP->DESCRED,1,30)
			@nlin,070 psay transform(TMP->ESTC,'@E 9,999')
			@nlin,082 psay transform(TMP->ESTP,'@E 99,999.99')			
			@nlin,110 psay transform(TMP->EMPCAIX,'@E 9,999')
			@nlin,118 psay transform(TMP->EMPPES,'@E 99,999.99')	
			nlin+=2                                                
			@nlin,012 psay 'Pre-Carregamentos: ' 
			nlin++
			for i := 1 to len(_aPrecars)
				@nlin,015 psay _aPrecars[i]
				nlin++
			next                  
			@nlin,001 psay replicate('-',132)
			nlin++
		endif 	 				
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

Static Function GeraQRY()   

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


//Busca os pre-carregamentos
Static Function VerPreCar(_Cod)
	Local _cTexto := ''
	Local _aTexto := {}

	_cQuery2 := " SELECT ZZ4_PRECAR 
	_cQuery2 += " FROM "  + RetSQLTab('ZZ4') + ", " + RetSQLTab('ZZ5')
	_cQuery2 += " WHERE " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ5') + " AND ZZ4_PRECAR BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	_cQuery2 += " AND ZZ5_COD = '" + _Cod + "' AND ZZ4_NUM = ZZ5_NUM"  
	_cQuery2 += " AND ZZ4_TPOPER = 'V' AND ZZ4_STATUS NOT IN('E','F')"          
	_cQuery2 += " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ4') 
	_cQuery2 += " GROUP BY ZZ4_PRECAR 

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"

	TMP2->(DbGoTop())

	while TMP2->(!eof())
		_cCarDesc := fBuscaCPO('ZZ3',2,xFilial('ZZ3')+TMP2->ZZ4_PRECAR,'ZZ3_OBS')
		_cTexto := TMP2->ZZ4_PRECAR + "-> " + substr(_cCarDesc,1,30)
		aadd(_aTexto,_cTexto)
		TMP2->(DbSkip())
	enddo

return _aTexto
