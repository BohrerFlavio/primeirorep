#INCLUDE "rwmake.ch" 
#INCLUDE "Protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT097BUT  º Autor ³Giuliano Forgiarini º Data ³  27/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Ponto de entrada da rotina de liberação de documentos que   º±±
±±º          ³serve para criar botão específico apra exibição das cotaçõesº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Giuliano Forgiarini                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MT097BUT()

	VisPC2()

return 

/////////Visualização dos itens do pedido


/////////Visualizaçao dos itens de cotação
Static Function VisCot()
	Local _aArqTrb    := {} // inicializa o array do arquivo // ProcData 04/2023
	Local _cMemoC := ''

	area := getarea()

	_cIdent := fBuscaCPO('SC8',8,xfilial('SC8')+QRY->(C7_NUMSC+C7_ITEMSC+C7_NUMCOT),'C8_IDENT')

	//traz o preço do produto da tabela de PC
	cQuery := " SELECT C8_NUM,C8_PRODUTO,C8_FORNECE,C8_LOJA,C8_IDENT,"
	cQuery += " C8_NUMPED,C8_ITEMPED,C8_PRECO,C8_QUANT,C8_TOTAL, "
	cQuery += " C8_DIFALIQ, C8_VALSOL, C8_VALIPI, C8_TOTFRE"
	cQuery += " FROM " + RetSqlTab("SC8")
	cQuery += " WHERE " + RetSQLFil('SC8')
	cQuery += " AND C8_PRODUTO = '" + QRY->C7_PRODUTO + "'" 
	cQuery += " AND C8_IDENT = '" + _cIdent + "'"   
	cQuery += " AND C8_NUM = '" + QRY->C7_NUMCOT + "'"
	cQuery += " AND " + RetSQLDel('SC8')
	cQuery += " ORDER BY C8_NUMPED,C8_ITEMPED"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//
	//Activate Dialog oDlgMemo  

	If Select("QRY2")<>0
		QRY2->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "QRY2" 

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	dbSelectarea('QRY2')

	aStru := dbStruct()                                                           //Pega a estrutura do QRY e atribui a um vetor

	aadd(aStru,{"C8_VENC"    , "C",  20, 0,   "@!"          , 'Vencedor'})     
	aadd(aStru,{"C8_NFOR"    , "C",  30, 0,   "@!"          , 'Nome Forn.'})     

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado                                                                
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)
	
	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
	Endif

	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	QRY2->(dbgotop())

	_cDescProd := ''

	while QRY2->(!eof())  

		if QRY2->C8_NUMPED <> 'XXXXXX' .and. !empty(QRY2->C8_NUMPED)
			_cDescProd := fBuscaCPO('SC7',1,xfilial('SB1')+QRY2->(C8_NUMPED+C8_ITEMPED),'C7_DESCRI')
		endif

		reclock('TMP',.t.) 
		TMP->C8_NUMPED  := QRY2->C8_NUMPED
		TMP->C8_NUM     := QRY2->C8_NUM
		TMP->C8_PRODUTO := QRY2->C8_PRODUTO 
		TMP->C8_QUANT   := QRY2->C8_QUANT
		TMP->C8_TOTAL   := QRY2->C8_TOTAL
		TMP->C8_FORNECE := QRY2->C8_FORNECE 
		TMP->C8_LOJA    := QRY2->C8_LOJA 
		TMP->C8_DIFALIQ := QRY2->C8_DIFALIQ
		TMP->C8_VALSOL  := QRY2->C8_VALSOL
		TMP->C8_VALIPI  := QRY2->C8_VALIPI
		TMP->C8_TOTFRE  := QRY2->C8_TOTFRE
		TMP->C8_NFOR    := fBuscaCPO('SA2',1,xfilial('SA2')+QRY2->(C8_FORNECE+C8_LOJA),'A2_NOME')
		TMP->C8_PRECO   := QRY2->C8_PRECO    
		if QRY2->C8_NUMPED <> 'XXXXXX' .and. !empty(QRY2->C8_NUMPED)
			TMP->C8_VENC := ' << Vencedor >>'
		endif

		msunlock() 
		QRY2->(dbskip())   

	enddo

	TMP->(dbgotop())      

	_nIPI      := 0.00
	_nSusTrib  := 0.00
	_nDifAliq  := 0.00
	_nTotFre   := 0.00

	While TMP->(!Eof())

		_cMemoC +=  TMP->C8_NUM + space(3) + TMP->C8_FORNECE + space(5) + TMP->C8_LOJA + space(5) +  TMP->C8_NFOR + ' ' + alltrim(TMP->C8_VENC) + CRLF
		_cMemoC += space(13) 
		_cMemoC += transform(TMP->C8_QUANT,'@E 999,999.9999') 
		_cMemoC += space(5) + transform(TMP->C8_PRECO,'@E 999,999.99')
		_cMemoC += space(5) + transform(TMP->C8_VALIPI,'@E 999.99')
		_cMemoc += space(5) + transform(TMP->C8_VALSOL,'@E 999,999.99')
		_cMemoC += space(5) + transform(TMP->C8_DIFALIQ,'@E 999.99') 
		_cMemoC += space(5) + transform(TMP->C8_TOTFRE,'@E 999,999.99')
		_cMemoC += space(5) + transform(TMP->(C8_TOTAL+C8_VALIPI+C8_VALSOL+C8_DIFALIQ+C8_TOTFRE),'@E 999.99')   	   	  	
		_cMemoC += CRLF

		if  !empty(TMP->C8_VENC)
			_nIPI      := TMP->C8_VALIPI
			_nSusTrib  := TMP->C8_VALSOL
			_nDifAliq  := TMP->C8_DIFALIQ
			_nTotFre   := TMP->C8_TOTFRE
		endif 

		TMP->(DbSkip())
	enddo

	QRY2->(dbclosearea())
	
	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 

Return {_cMemoC , _nIPI , _nSusTrib , _nDifAliq , _nTotFre}


Static Function VisPC2()

	_cNumPC := alltrim(SCR->CR_NUM)

	area := getarea()

	//traz o preço do produto da tabela de PC
	cQuery := " SELECT C7_NUM,C7_PRODUTO,C7_DESCRI,C7_UM,C7_QUANT,C7_OBS, C7_NUMCOT,C7_ITEM, C7_CC, C7_OBS,C7_VLDESC, C7_MOEDA" 
	cQuery += " C7_PRECO, C7_TOTAL ,C7_SOLICIT, C7_QUANT,C7_EMISSAO,C7_DATPRF, C7_COND, C7_TPFRETE,C7_NUMSC, C7_ITEMSC,"
	cquery += " ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), C7_OBSM)),'') AS C7OBSM"
	cQuery += " FROM "+RetSqlTab("SC7")
	cQuery += " WHERE " + RetSQLFil('SC7')
	cQuery += " AND SC7.C7_NUM = '" + _cNumPC + "'"
	cQuery += " AND " + RetSqlDel('SC7')

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//
	//Activate Dialog oDlgMemo  

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif                                    

	TCQUERY cQuery NEW ALIAS "QRY" 

	dbSelectarea('QRY')
	//dBGoTop()

	_cMemo      := ''

	_cDescCP  := fBuscaCPO('SE4',1,xfilial('SE4') + QRY->C7_COND,'E4_DESCRI')  
	_cTpFrete := iif(QRY->C7_TPFRETE = 'S','SIF','FOB') 
	_cMoeda   := IIF(QRY2->C7_MOEDA == 2, 'DÓLAR', IIF(QRY2->C7_MOEDA == 4, 'EURO', 'REAL'))
	_nTotPC   := 0.00

	_cMemo += replicate('=',105) + CRLF
	_cMemo += 'Condição Pagto: ' + _cDescCP + ' Tipo Frete: ' + _cTpFrete + ' Moeda: ' + _cMoeda + CRLF 

	while QRY->(!eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializacao da Observacao do Pedido.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLinObs := 0
		cObs01  := ""
		If !Empty(QRY->C7OBSM) .And. nLinObs < 5 .And. !(QRY->C7_OBS $ QRY->C7OBSM)
			nLinObs++
			cVar:="cObs"+StrZero(nLinObs,2)
			Eval(MemVarBlock(cVar),QRY->C7OBSM)
		Endif

		_cCotacoes := VisCot()

		_cConsMedio := ''
		_cUltCom    := dtoc(fBuscaCPO('SB1',1,xfilial('SB1')+QRY->C7_PRODUTO,'B1_UCOM')) 
		_cConsMedio := transform(fBuscaCPO('SB3',1,xfilial('SB3')+QRY->C7_PRODUTO,'B3_MEDIA'),'@E 999,999.99')
		_cUltPrc    := transform(fBuscaCPO('SB1',1,xfilial('SB1')+QRY->C7_PRODUTO,'B1_UPRC'),'@E 999,999.99')

		_cMemo += replicate('=',105) + Chr(13) + Chr(10)                            
		_cMemo += ' Produto: ' + PADC(QRY->C7_PRODUTO,10,' ') + '   ' + alltrim(QRY->C7_DESCRI) + '   (' + QRY->C7_UM + ')' + CRLF 
		_cMemo += ' Quantidade :............................................................................  ' 
		_cMemo +=   padl(ltrim(transform(QRY->C7_QUANT,'@E 999,999.99')),10,'') + CRLF
		_cMemo += ' Valor :.................................................................................  ' 
		_cMemo +=   padl(ltrim(transform(QRY->(C7_PRECO - (C7_VLDESC/C7_QUANT) ),'@E 999,999.9999')),10,'') + CRLF                                                   
		_cMemo += ' Total :.................................................................................  ' 
		_cMemo +=   padl(ltrim(transform(QRY->(C7_TOTAL-C7_VLDESC) +_cCotacoes[2] +_cCotacoes[3] +_cCotacoes[4] + _cCotacoes[5],'@E 999,999.99')),10,'') + CRLF
		_cMemo += ' Emissão :................................... ' + dtoc(stod(QRY->C7_EMISSAO)) + CRLF
		_cMemo += ' Entrega :................................... ' + dtoc(stod(QRY->C7_DATPRF)) + CRLF
		_cMemo += ' Ultima Compra: ............................. ' + _cUltCom + CRLF
		_cMemo += ' Ultimo Preço :.............................. ' + _cUltPrc + CRLF
		_cMemo += ' Cons. Medio: ............................... ' + _cConsMedio  + CRLF              
		_cMemo += ' Centro de Custo: ........................... ' + iif(empty(QRY->C7_CC),'',fBuscaCPO('CTT',1,xfilial('CTT')+QRY->C7_CC,'CTT_DESC01')) + CRLF 
		_cMemo += ' OBS:   ' + QRY->C7_OBS + CRLF   
		If !Empty(cObs01)
			_cMemo += ' DESCR. SERVIÇO:   ' + cObs01 + CRLF
		Endif
		_cMemo += replicate('-',105) + Chr(13) + Chr(10)                                  
		_cMemo += 'COTAÇÕES:        |   Quant.    |   Preco   |   IPI   |  Sub.Trib. |  Dif.Aliq.  |  Frete   |   Total  ' + CRLF
		_cMemo += _cCotacoes[1]

		_nTotPC += QRY->(C7_TOTAL - C7_VLDESC) +_cCotacoes[2] +_cCotacoes[3] +_cCotacoes[4] + _cCotacoes[5]

		QRY->(dbskip())  	  
	enddo


	if QRY->(eof())
		_cMemo += replicate('=',105) + CRLF
		_cMemo += 'VALOR TOTAL DO PEDIDO:....................................................... ' + Transform(_nTotPC,'@E 999,999,999.99') + CRLF
		_cMemo += replicate('=',105) + CRLF
	endif      

	_nTotPC := 0

	DEFINE FONT oFont NAME "Mono AS" SIZE 6,15   //6,15
	DEFINE MSDIALOG oEnc TITLE 'Informações Específicas' from 00,00 to 570,670 OF oMainWnd PIXEL 

	@ 5,5 GET oMemo VAR _cMemo MEMO SIZE 330,250 OF oEnc PIXEL
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:= oFont
	oMemo:lReadOnly := .t.

	@ 265,020  BUTTON 'Imprimir' SIZE 40,15 ACTION u_ML_110(QRY->C7_NUM) OBJECT oBtn 
	@ 265,260  BUTTON 'Sair'     SIZE 40,15 ACTION oEnc:end() OBJECT oBtn2 

	ACTIVATE MSDIALOG oEnc     


	QRY->(dbclosearea())
	restarea(area)

Return

