#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF29     ºFlávio Bohrer   º Data ³  30/11/10               º±±
±±º   Modificado por Giuliano Forgiarini em 07/06/12             	         ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de carcaças processadas em previsão de produção  º±±
±±º          ³ na entrada da desossa                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico dos Certificadores Angus                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF29()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Esta rotina tem por objetivo a geração de relatório de conferencia"
	Local cDesc2        := "de processamento específico de carcaças no setor de desossa para o"
	Local cDesc3        := "determinado programa apontado nos parametros iniciais da mesma."	
	Local titulo       	:= "QUARTOS PROCESSADOS DESOSSA - PROGRAMAS"
	Local nLin         	:= 80
	Local Cabec1       	:= space(10) + 'Hora' + space(4) + 'Sequencial' + space(4) + 'Av.Matanca' + space(7) + 'Peso'+;  
	space(17) + 'Hora' + space(4) + 'Sequencial' + space(4) + 'Av.Matanca' + space(7) + 'Peso'
	Local Cabec2       	:= ""
	Local aOrd          := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private Tamanho     := "M"
	Private nomeprog    := "FBF29" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "FBF29"
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "FBF29" // Coloque aqui o nome do arquivo usado para impressao em disco 
	Private aTotais     := {}

	DbSelectArea('ZAJ')

	pergunte(cPerg,.F.) 

	wnrel := SetPrint('ZAJ',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	/*if empty(mv_par05) 
	alert('Informe o código do Programa nos parametros iniciais do relatório!')
	return
	endif*/

	cQuery := " SELECT ZAJ_DATAS AS DATAP, (ZAJ_NUMAM+ZAJ_CONTRO) AS RASTRO, ZAJ_NUMAM AS NUMAM, ZAJ_CONTRO AS CONTRO,"
	cQuery += " ZAJ_DEST AS DEST,ZAJ_HORAS AS HORA,ZAJ_COD AS COD,ZAJ_PESO AS PESO,ZK_PROGRAM AS PROGRAM,ZK_RACA AS RACA,ZK_BLACK AS BLACK "
	cQuery += " FROM " + RetSqlTab("SZK") + " (NOLOCK) "
	cQuery += " INNER JOIN " + RetSqlTab("ZAJ") + " (NOLOCK) ON (ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL = ZAJ_CONTRO)"
	cQuery += " INNER JOIN " + RetSqlTab("SZG") + " (NOLOCK) ON (ZK_NUMAM = ZG_NUMAM)"
	cQuery += " WHERE " + RetSQLFil('ZAJ') + " AND " + RetSQLFil('SZK') + " AND " + RetSQLFil('SZG')
	cQuery += " AND " + RetSQLDel('ZAJ') + " AND " + RetSQLDel('SZK') + " AND " + RetSQLDel('SZG')
	cQuery += " AND ZAJ_NUMAM <> '' "
	cQuery += " AND (ZG_DATA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "') "
	cQuery += " AND (ZAJ_DATAS BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "') "
	//cQuery += " AND (ZAJ_NUMAM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "') "
	cQuery += " AND ZAJ_DATAS <> '' AND ZAJ_HORAS <> '' "

	if mv_par09 = 1
		cQuery += " AND ZAJ_PRECAR <> '' AND ZAJ_PREPED <> '' AND ZAJ_ITEM <> '' "
	elseif mv_par09 = 2
		cQuery += " AND ZAJ_PRECAR = '' AND ZAJ_PREPED = '' AND ZAJ_ITEM = '' "
	endif

	if mv_par08 = 2
		if !empty(mv_par05)
			if mv_par05 $ "006/021"
				cQuery += " AND ZK_PROGRAM IN ('006','021')"
			elseif mv_par05 $ "002/022"
				cQuery += " AND ZK_PROGRAM IN ('002','022')"
			else
				cQuery += " AND ZK_PROGRAM = '" + mv_par05 + "'"
			endif
		endif
	endif

	// Removido por Mauro - 03/05/21 pois estava contradizendo com a regra acima linha 79
	/*IF !empty(mv_par06)
		If mv_par06 == '001'
			cQuery += " AND ZK_RACA = '" + mv_par06 + "' AND ZK_PROGRAM <> '006'
		Else 
			cQuery += " AND ZK_RACA = '" + mv_par06 + "'"
		EndIf
	EndIf*/

	If !empty(mv_par06)
		cQuery += " AND ZK_RACA = '" + mv_par06 + "'"
	EndIf

	if mv_par07 = 1
		cQuery += " AND ZK_BLACK = 'N'"
	elseif mv_par07 = 2
		cQuery += " AND ZK_BLACK = 'S'"
	endif

	cQuery += " ORDER BY ZAJ_DATAS,ZAJ_COD,ZAJ_HORAS,ZAJ_CONTRO"

	//	* Mostrar a consulta */
	// @ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	// @ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	// Activate Dialog oDlgMemo

	If nLastKey == 27
		Return
	Endif

	cQuery := ChangeQuery(cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif   

	TCQUERY cQuery NEW ALIAS "QRY"

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local _cDataAM  := ''
	Local _cParte   := ''
	Local _lCol     := .f.
	Local _nPosCod  := 0 
	Local _lProg    := .f.
	Local i

	QRY->(dbGoTop())
	QRY->(SetRegua(RecCount()))

	While QRY->(!EOF())

		incregua()

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		if  !_lProg      
			@nlin,00 psay 'Programa: ' + GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6') + QRY->PROGRAM,1)
			nlin++	
			_lProg := .t.
		endif

		if _cDataAM <> QRY->DATAP 
			if	!_lCol 
				_lCol := .t.
				nlin++
			endif 
			nlin++ 
			@nlin,00 psay 'Produção dia: ' + dtoc(stod(QRY->DATAP))
			nlin++
			_cDataAM := QRY->DATAP
			_cParte  := ''
		endif

		if _cParte <> QRY->COD  
			if	!_lCol 
				_lCol := .t.
				nlin++
			endif    
			@nlin,05 psay 'Peça: ' + alltrim(QRY->COD) + space(5) + GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+QRY->COD,1)
			nlin++
			_cParte := QRY->COD
		endif       

		_cLinha := QRY->(HORA + space(5) + CONTRO + space(5) + NUMAM + space(5) + transform(PESO,"@E 999,999.99")) 

		if _lCol 
			@nlin,10 psay  _cLinha
			_lCol := .f.
		else 
			@nlin,70 psay  _cLinha 
			_lCol := .t.
			nlin++
		endif

		_nPosCod := ASCAN(aTotais,{|aVal|aVal[1] == QRY->COD}) 

		if _nPosCod <> 0
			aTotais[_nPosCod][2]++
			aTotais[_nPosCod][3] += QRY->PESO
		else
			AADD(aTotais,{QRY->COD,1,QRY->PESO})
		endif

		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo 
	enddo 

	nlin += 2

	If nLin+2 > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif 

	@nlin,10 psay 'TOTAL GERAL POR PEÇA:'
	nlin++
	@nlin,10 psay 'Peça' + space(22) + 'Unid.' + space(9) + 'Peso'
	nlin++

	for i := 1 to len(aTotais)  

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		@nlin,10 psay GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+aTotais[i][1],1)
		@nlin,34 psay transform(aTotais[i][2],'@E 999,999') 
		@nlin,40 psay transform(aTotais[i][3],'@E 999,999,999.99')
		nlin++
	next

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

