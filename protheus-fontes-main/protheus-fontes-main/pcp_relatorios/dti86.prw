#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI86   º Autor ³ Fabian Maurer  º Data ³  01/07/19	      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Estoque detalhados de Caixas                  º±±
±±º          ³ Produto Acabado para Santa Brasa                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP (SIGAPCP)					  	 	                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI86()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         	:= "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         	:= "de estoque de caixas de produto acabado do   "
	Local cDesc3         	:= "Santa Brasa"
	Local cPict          	:= "Relatorio de Estoque de Caixas Santa Brasa "
	Local titulo       		:= "ESTOQUE DE CAIXAS SANTA BRASA"
	Local nLin         		:= 80

	Local Cabec1       		:= 	  "  Codigo             Peso        Data"+;
	"           Data      Local"                   
	Local Cabec2       		:= 	  "  Caixa              Liq.        Prod."+;
	"          Valid.    Armazen."

	Local imprime      		:= .T.
	Local aOrd := {}
	Private lEnd         	:= .F.
	Private lAbortPrint  	:= .F.
	Private CbTxt        	:= ""
	Private limite           := 80
	Private tamanho          := "G"
	Private nomeprog         := "DTI86" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   := "DTI86"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "DTI86" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.)

	//para verificação se existe previsao de pesagem 

	u_mlr05b()

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT Z8_CONTROL AS CONTROL, Z8_COD AS COD, Z8_DATA AS DATAR,Z8_TF AS TF,"
	cQuery += " Z8_DATAP AS DATAP,Z8_HORA AS HORA, Z8_QUANT AS QUANT, Z8_PESO AS PESO,Z8_OPERA AS OPERA,"
	cQuery += " Z8_TARA AS TARA, Z8_PESOBR AS PESOBR, Z8_DATAVAL AS DATAVA,Z8_BALAN AS BALAN, Z8_LOCAL AS CAMARA" 
	cQuery += " FROM " + RetSQLTab('SZ8')
	cQuery += " WHERE " + RetSQLFil('SZ8') + " AND Z8_FIL = '" + cFilAnt  + "' AND "
	cQuery += " Z8_DATAS = ' ' AND Z8_HORAS = ' ' AND Z8_PRECAR = ' ' AND Z8_PREPED = ' ' AND Z8_ITEM = ' ' AND " 
	cQuery += " Z8_COD IN('000252','008693','007270','006504','006495','002339','002168','002069','015378','012104','002144')" 

	cQuery += " AND " +RetSQLDel('SZ8')

	cQuery += " ORDER BY Z8_COD, Z8_DESCRI, Z8_DATA, Z8_HORA, Z8_CONTROL"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "QRY"
	
	
	/////Query para Materia Prima - 005069
	cQuery2 := " SELECT ZAS_CONTRO AS CONTROL2, ZAS_COD AS COD2, ZAS_SIF AS BALAN2, ZAS_COD3 AS OPERA2,"
	cQuery2 += " ZAS_DTPROD AS DATAP2, ZAS_PESOL AS PESO2,ZAS_DTREEN AS DATAR2, ZAS_HORA AS HORA2, ZAS_TERC AS TF2,"
	cQuery2 += " ZAS_TARA AS TARA2, ZAS_PESOB AS PESOBR2, ZAS_VALID AS DATAVAL2, ZAS_LOCAL AS CAMARA2, ZAS_VALID AS VALID2" 
	cQuery2 += " FROM " + RetSQLTab('ZAS')
	cQuery2 += " WHERE " + RetSQLFil('ZAS') + " AND "
	cQuery2 += " ZAS_DATAS = ' ' AND ZAS_HORAS = ' '  AND " 
	cQuery2 += " ZAS_COD = '005069' AND " 
	cQuery2 += " ZAS_TIPO = 'MP' "
	cQuery2 += " AND " +RetSQLDel('ZAS')

	cQuery2 += " ORDER BY ZAS_COD, ZAS_DESC, ZAS_CONTRO"

	cQuery2 := ChangeQuery(cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif
	TCQUERY cQuery2 NEW ALIAS "QRY2"
	
	


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

	Local nOrdem
	Local _ntotCaix
	Local _ntotPeso
	Local _nTotGerCaix := 0
	Local _nTotGerPeso := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cCod := space(6)

	QRY->(dbGoTop())

	QRY->(SetRegua(RecCount()))

	While QRY->(!EOF())

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

		if _cCod <> QRY->COD
			nlin++
			@nlin,02 psay alltrim(QRY->COD) + '   ' + fbuscaCPO('SB1',1,xfilial('SB1')+alltrim(QRY->COD), 'B1_DESCRED')
			nlin++  
			_nTotCaix := 0 
			_nTotPeso := 0
			_cCod := QRY->COD
		endif

		_cCaixa := QRY->CONTROL  +  '   ' + transform(QRY->PESO,'@E 999,999.99') +;
		'      '+ DTOC(STOD(QRY->DATAP)) + '      '+ DTOC(STOD(QRY->DATAVA)) + '      ' + QRY->CAMARA;
		//'   ' + QRY->HORA + '   ' + alltrim(QRY->BALAN) + '   ' + DTOC(STOD(QRY->DATAR)) + '   ' + transform(QRY->TARA,'@E 9.999') + ;
		//'   ' + transform(QRY->QUANT,'@E 999') + '   ' +  transform(QRY->PESOBR,'@E 999,999.99') + '   ' + QRY->OPERA     

		@nlin,02 psay _cCaixa  
		_nTotCaix++
		_nTotPeso += QRY->PESO
		_nTotGerCaix++
		_nTotGerPeso += QRY->PESO
		nlin++              

		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo  

		if _cCod <> QRY->COD 

			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif 

			@nlin,02 psay 'Total Caixas: ' + transform(_nTotCaix,'@E 999,999')+ '   '+ 'Total Peso: '+ transform(_nTotPeso,'@E 999,999.99')
			nlin++ 
		endif
	EndDo 

	nlin++
	
	QRY2->(dbGoTop())

	QRY2->(SetRegua(RecCount()))

	While QRY2->(!EOF())

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

		if _cCod <> QRY2->COD2
			nlin++
			@nlin,02 psay alltrim(QRY2->COD2) + '   ' + fbuscaCPO('SB1',1,xfilial('SB1')+alltrim(QRY2->COD2), 'B1_DESCRED')
			nlin++  
			_nTotCaix := 0 
			_nTotPeso := 0
			_cCod := QRY2->COD2
		endif
		
		_dDtProd  := QRY2->DATAP2
		_dDtValid := STOD(_dDtProd) + QRY2->VALID2

		_cCaixa := QRY2->CONTROL2  + '   ' + transform(QRY2->PESO2,'@E 999,999.99') +;
		'      '+ DTOC(STOD(QRY2->DATAP2)) + '      ' + DTOC(_dDtValid) + '      ' + QRY2->CAMARA2;
		//'   ' +  transform(QRY2->PESOBR2,'@E 999,999.99') + '   ' + transform(QRY2->TARA2,'@E 9.999') +;
		//'   ' + DTOC(STOD(QRY2->DATAR2)) + '   ' + QRY2->HORA2 +'   ' + alltrim(QRY2->BALAN2) +;
		//'   ' + QRY2->OPERA2 + '   ' + iif(QRY2->TF2 = 'S','Sim','  ') + '   ' + QRY2->CAMARA2    

		@nlin,02 psay _cCaixa  
		_nTotCaix++
		_nTotPeso += QRY2->PESO2
		_nTotGerCaix++
		_nTotGerPeso += QRY2->PESO2
		nlin++              

		QRY2->(dbSkip()) // Avanca o ponteiro do registro no arquivo  

		if _cCod <> QRY2->COD2 

			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif 

			@nlin,02 psay 'Total Caixas: ' + transform(_nTotCaix,'@E 999,999')+ '   '+ 'Total Peso: '+ transform(_nTotPeso,'@E 999,999.99')
			nlin++ 
		endif
	EndDo 

	nlin++

	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif 
	@nlin,02 psay 'Total Geral Caixas: ' + transform(_nTotGerCaix,'@E 999,999')+ '   '+;
	'Total Geral Peso: '+ transform(_nTotGerPeso,'@E 999,999.99')	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('QRY2')

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
