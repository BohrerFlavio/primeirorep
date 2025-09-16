#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF83   º Autor ³ Giuliano Forgiarini  º Data ³  25/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Estoque detalhados de Caixas de PA           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF83()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         	:= "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         	:= "de estoque de caixas de produto acabado detalhado   "
	Local cDesc3         	:= "por caixas"
	Local cPict          	:= "Relatorio de Estoque de Caixas Detalhado "
	Local titulo       		:= "ESTOQUE DETALHADO DE CAIXAS DE PA"
	Local nLin         		:= 80

	Local Cabec1       		:= 	  "  Codigo       Quant.      Peso        Peso    Tara      Data"+;
	"     Hora     Data     Balança    Operador     TF?        Local"                   
	Local Cabec2       		:= 	  "  Caixa        Peças       Liq.        Bruto   Caixa     Real"+;
	"     Prod.    Prod.     Prod.     Balança                Armazen."

	Local imprime      		:= .T.
	Local aOrd := {}
	Private lEnd         	:= .F.
	Private lAbortPrint  	:= .F.
	Private CbTxt        	:= ""
	Private limite           := 80
	Private tamanho          := "M"
	Private nomeprog         := "GJF83" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   := "GJF83"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "GJF83" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.)

	//para verificação se existe previsao de pesagem 

	u_mlr05b()

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT Z8_CONTROL AS CONTROL, Z8_COD AS COD, Z8_DATA AS DATAR,Z8_TF AS TF,"
	cQuery += " Z8_DATAP AS DATAP,Z8_HORA AS HORA, Z8_QUANT AS QUANT, Z8_PESO AS PESO,Z8_OPERA AS OPERA,"
	cQuery += " Z8_TARA AS TARA, Z8_PESOBR AS PESOBR, Z8_DATAVAL AS DATAVAL,Z8_BALAN AS BALAN, Z8_LOCAL AS CAMARA" 
	cQuery += " FROM " + RetSQLTab('SZ8')
	cQuery += " WHERE " + RetSQLFil('SZ8') + " AND Z8_FIL = '" + cFilAnt  + "' AND "
	cQuery += " (Z8_COD BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "') AND"
	cQuery += " (Z8_DATA BETWEEN '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "') AND"
	cQuery += " (Z8_DATAP BETWEEN '" + dtos(mv_par05) + "' AND '" + dtos(mv_par06) + "') AND" 
	cQuery += " (Z8_HORA BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "') AND" 
	cQuery += " Z8_DATAS = ' ' AND Z8_HORAS = ' ' AND Z8_PRECAR = ' ' AND Z8_PREPED = ' ' AND Z8_ITEM = ' '" 

	if !empty(mv_par09)
		cQuery += " AND Z8_BALAN = '" + mv_par09 + "'"
	endif

	if !empty(mv_par12)
		cQuery += " AND Z8_LOCAL = '" + mv_par12 + "'"
	endif


	if mv_par13 = 2
		cQuery += " AND Z8_LOTEPOR <> ''"
	endif

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

		if !empty(mv_par10)
			_cFam := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(QRY->COD),'B1_FAM')
			if mv_par10 <> _cFam
				QRY->(DbSkip())
				loop
			endif   
		endif  

		if mv_par11 = 1
			_cDest := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(QRY->COD),'B1_DESTINO')
			if _cDest <> 'MI'
				QRY->(DbSkip())
				loop
			endif   
		elseif mv_par11 = 2 
			_cDest := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(QRY->COD),'B1_DESTINO')
			if _cDest <> 'ME'
				QRY->(DbSkip())
				loop
			endif   
		endif

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

		_cCaixa := QRY->CONTROL  + '   ' + 	transform(QRY->QUANT,'@E 999') + '   ' + transform(QRY->PESO,'@E 999,999.99') +;
		'   ' +  transform(QRY->PESOBR,'@E 999,999.99') + '   ' + transform(QRY->TARA,'@E 9.999') +;
		'   ' + DTOC(STOD(QRY->DATAR)) + '   ' + QRY->HORA + '   '+ DTOC(STOD(QRY->DATAP)) +;
		'   ' + alltrim(QRY->BALAN) +;
		'   ' + QRY->OPERA + '   ' + iif(QRY->TF = 'S','Sim','  ') + '   ' + QRY->CAMARA    

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

	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif 
	@nlin,02 psay 'Total Geral Caixas: ' + transform(_nTotGerCaix,'@E 999,999')+ '   '+;
	'Total Geral Peso: '+ transform(_nTotGerPeso,'@E 999,999.99')	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('QRY')

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
