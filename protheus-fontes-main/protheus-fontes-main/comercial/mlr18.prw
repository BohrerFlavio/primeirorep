#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR15    º Autor ³ Mauricio Roehrs em 09/08/2013            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio para Conf. de Prev. de Produç. X Empenho de Prod.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial      		                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR18()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia da Prev. de Prod. x Empenho"
	Local cDesc3         := ""
	Local cPict          := "vai porra"
	Local titulo         := "RELATORIO PARA CONF. PREV. PROD. / EMPENHO"
	Local Cabec1         := "Data      Codigo                 Produto                      Prev. Prod.   Prev. Prod.     Saldo    Saldo     Empenho    Empenho"
	Local Cabec2         := "                                                                 Caixas        Peso        Caixas     Peso       Caixas       Peso "    
	Local imprime         := .T.
	Local aOrd            := {}  
	Private nLin           := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "MLR18" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg   		 := "MLR18"
	Private cbtxt      	:= Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "MLR18" // Coloque aqui o nome do arquivo usado para impressao em disco    
	pergunte(cPerg,.F.)


	wnrel := SetPrint('SB1',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	_dData := mv_par01  
	_cFarm := iif(mv_par03 = 1,'R',iif(mv_par03 = 2,'C',iif(mv_par03 = 3,'S','')))



	if _dData < ddatabase
		alert('Data de parametro inferior a data base!')
		return 
	endif



	_cQuery := " SELECT B1_COD AS COD, B1_DESCRED AS DESCRED,

	//Previsão de Produção
	_cQuery += " 			(SELECT SUM(ZU_QPCAIX - ZU_QRCAIX) 
	_cQuery += " 			 FROM  " + RetSQLTab('SZU') 
	_cQuery += " 			 WHERE " + RetSQLFil('SZU') + " AND B1_COD = ZU_COD AND ZU_FECHADO <> 'S' AND (ZU_DTRPRO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "')"
	_cQuery += "          AND   " + RetSQLDel('SZU') + ") AS PRODCAIX,

	_cQuery += " 			(SELECT SUM(ZU_QPPESO - ZU_QRPESO) 
	_cQuery += " 			 FROM  " + RetSQLTab('SZU') 
	_cQuery += " 			 WHERE " + RetSQLFil('SZU') + " AND B1_COD = ZU_COD AND ZU_FECHADO <> 'S' AND (ZU_DTRPRO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "')"
	_cQuery += "          AND   " + RetSQLDel('SZU') + ") AS PRODPES,                

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
	_cQuery += "  ZZ4_TPOPER = 'V' AND ZZ4_STATUS NOT IN('E','F') AND (ZZ4_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND " + RetSQLDel('ZZ5')
	_cQuery += "  AND   " + RetSQLDel('ZZ4') + ") AS EMPCAIX,

	_cQuery += " (SELECT SUM(ZZ5_QPPESO - ZZ5_QRPESO) 
	_cQuery += "  FROM  " + RetSQLTab('ZZ5') + "  ,  " + RetSQLTab('ZZ4') 
	_cQuery += "  WHERE " + RetSQLFIl('ZZ5') + " AND " + RetSQLFil('ZZ4') + " AND B1_COD = ZZ5_COD AND ZZ5_NUM = ZZ4_NUM AND"
	_cQuery += "  ZZ4_TPOPER = 'V' AND ZZ4_STATUS NOT IN('E','F') AND (ZZ4_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND " + RetSQLDel('ZZ4') + " 
	_cQuery += "  AND   " + RetSQLDel('ZZ5') + ") AS EMPPES       

	_cQuery += " FROM  " + RetSQLTab('SB1') + "  ,  " + RetSQLTab('SBM')
	_cQuery += " WHERE " + RetSQLFil('SB1') + " AND " + RetSQLFil('SBM') + " AND B1_TIPO = 'PA' AND B1_SEGUM = 'CX' AND B1_MSBLQL = '2' AND" 
	_cQuery += " B1_GRUPO = BM_GRUPO AND"

	if _cFarm <> ''
		_cQuery += " BM_FARM = '" +_cFarm + "' AND "   
	endif 

	if !empty(mv_par04)
		_cQuery += " B1_COD = '" + mv_par04 + "' AND"
	endif   

	_cQuery += " B1_COD IN(SELECT ZU_COD 
	_cQuery += " 			  FROM  " + RetSQLTab('SZU') 
	_cQuery += " 			  WHERE " + RetSQLFil('SZU') + " AND (ZU_DTRPRO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND ZU_FECHADO <> 'S'	AND " + RetSQLDel('SZU')
	_cQuery += " 			  UNION
	_cQuery += " 			  SELECT ZZ5_COD 
	_cQuery += " 			  FROM  " + RetSQLTab('ZZ4') + "  ,  " + RetSQLTab('ZZ5') 
	_cQuery += " 			  WHERE " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ5') + " AND ZZ5_NUM = ZZ4_NUM AND ZZ4_TPOPER = 'V' AND" 
	_cQuery += "           ZZ4_STATUS NOT IN('E','F','P') AND 
	_cQuery += " 			  ZZ4_DATA = '" + dtos(_dData) + "' AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5') + ")
	_cQuery += " AND " + RetSQLDel('SB1')  + " AND " + RetSQLDel('SBM') 
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

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_cCod 		:= ''
	_cData 		:= ''      
	_nSaldoCx	:= 0
	_nSaldoPes  := 0.00

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


		/*  
		if _cData <> dtos(TMP->DDATA)
		@nlin,001 psay replicate('-',132)	 	
		nlin++	 	  
		@nlin,002 psay TMP->DDATA
		nlin++
		@nlin,001 psay replicate('-',132)	 	
		nlin++	
		_cData := dtos(TMP->DDATA)  	 		
		endif 	            
		*/


		_nSaldoCx  := TMP->(ESTC - EMPCAIX)
		_nSaldoPes := TMP->(ESTP - EMPPES) 

		@nlin,012 psay TMP->COD
		@nlin,030 psay substr(TMP->DESCRED,1,30)
		@nlin,065 psay iif(TMP->PRODCAIX < 0, transform(0,'@E 9,999'),transform(TMP->PRODCAIX,'@E 9,999'))
		@nlin,075 psay iif(TMP->PRODPES  < 0.00, transform(0.00,'@E 99,999.99'),transform(TMP->PRODPES,'@E 99,999.99'))
		@nlin,090 psay transform(_nSaldoCx,'@E 9,999')
		@nlin,098 psay transform(_nSaldoPes,'@E 99,999.99')			
		@nlin,113 psay transform(TMP->EMPCAIX,'@E 9,999')
		@nlin,120 psay transform(TMP->EMPPES,'@E 99,999.99')

		nlin++

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

