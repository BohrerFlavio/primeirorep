#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"                      
#INCLUDE "totvs.ch"
#INCLUDE "colors.ch"   
#INCLUDE "totvsmail.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF171    º Autor ³ Giuliano Forgiariniº Data ³  05/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de liberação de pedidos de compra Silva             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Diretoria/Gerencia Administrativo                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF171()

	aObjects            := {}
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           :=aPosObj[1]
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	Private aBrowse1  := {} 
	Private _cCodUser := RetCodUsr()

	//Cabeçalhos das colunas  
	aHeader1 := {'Emissao','Numero','Forn.','Lj','Nome','Total'}
	//Largura das colunas
	aLargCol1 := {40,30,30,10,160,30}

	SAK->(DbSetOrder(2))
	if !SAK->(MsSeek(FWxfilial('SAK')+_cCodUser))
		alert('Usuario não cadastrado para liberação!')
		return
	endif

	_cCodLib := SAK->AK_COD

	DEFINE DIALOG oDlg TITLE "Liberação de Pedidos de Compra - Específico Silva" FROM 20,50 To 500,850 PIXEL

	oBrowse1 := TCBrowse():New(10,10,330,210,,aHeader1,aLargCol1,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	AtuBrow()

	TButton():New( 020,350, "Visualizar", oDlg,{||VisPC(aBrowse1[oBrowse1:nAt,02])},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 040,350, "Fechar"    , oDlg,{||oDlg:end()                      },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED 

Return

//Função destinada a montagem do array de registros
Static Function MontaArray()
	// Vetor com elementos do Browse 
	aBrowse1 := {}

	//Query para calcular o que está em estoque
	cQuery := " SELECT C7_EMISSAO,C7_NUM,C7_FORNECE, C7_LOJA, SUM(C7_TOTAL - C7_VLDESC + C7_VALIPI + C7_VALSOL + C7_DESPESA) AS TOTAL"
	cQuery += " FROM " + RetSQLTab('SC7') + "," + RetSQLTab('SCR')
	cQuery += " WHERE C7_NUM = CR_NUM AND CR_NIVEL = '01' AND CR_STATUS = '02' AND CR_TIPO = 'PC'"
	cQuery += " AND " + cFilAnt+ " = CR_FILIAL "
	if cEmpAnt = '01'
		cQuery += " AND C7_GRUPO <> '1000'"
	endif
	cQuery += " AND CR_USERLIB = '' AND CR_USER = '" + alltrim(_cCodUser) + "' AND CR_APROV = '" + alltrim(_cCodLib) + "'"
	cQuery += " AND " + RetSQLDel('SC7') + " AND " + RetSQLDel('SCR')
	cQuery += " GROUP BY C7_EMISSAO,C7_NUM,C7_FORNECE,C7_LOJA "
	cQuery += " ORDER BY C7_EMISSAO,C7_NUM,C7_FORNECE,C7_LOJA "

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	QRY->(DbGoTop())
	While QRY->(!eof())

		_cDescForn := GetAdvFval('SA2','A2_NOME',FWxfilial('SA2')+QRY->(C7_FORNECE+C7_LOJA),1)
		aadd(aBrowse1,{stod(QRY->C7_EMISSAO),QRY->C7_NUM,QRY->C7_FORNECE,QRY->C7_LOJA,_cDescForn,QRY->TOTAL})

		QRY->(DbSkip())
	enddo

	if len(aBrowse1) = 0
		aadd(aBrowse1,{'','','','','',0})
	endif

return 

//Função destinada a atualização do browse pelo timer
Static Function AtuBrow()

	MontaArray()

	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],;
	aBrowse1[oBrowse1:nAt,02],;
	aBrowse1[oBrowse1:nAt,03],;
	aBrowse1[oBrowse1:nAt,04],;
	aBrowse1[oBrowse1:nAt,05],;
	transform(aBrowse1[oBrowse1:nAt,06],'@E 999,999,999.99')}}

	oBrowse1:nScrollType := 1
	oBrowse1:bLDblClick  := {|| VisPC(aBrowse1[oBrowse1:nAt,02]) }

	oBrowse1:DrawSelect()
	oBrowse1:refresh()

	oDlg:refresh()

return

Static Function VisPC(_cNumPC)

	//area := getarea()

	//traz o preço do produto da tabela de PC
	cQuery := "SELECT C7_NUM, C7_PRODUTO, C7_DESCRI, C7_UM, C7_QUANT, C7_OBS, C7_NUMCOT, C7_ITEM, C7_CC, C7_OBS, C7_VLDESC, C7_VALIPI, C7_VALSOL,"
	cQuery += " C7_PRECO, C7_TOTAL, C7_SOLICIT, C7_QUANT, C7_EMISSAO, C7_DATPRF, C7_COND, C7_TPFRETE, C7_NUMSC, C7_ITEMSC, C7_MOEDA, C7_USER, C7_DESPESA"
	cQuery += " FROM " + RetSqlTab("SC7")
	cQuery += " WHERE (" + RetSQLFil('SC7')
	cQuery += " OR C7_FILIAL = '02') AND C7_NUM = '" + _cNumPC + "'"
	cQuery += " AND " + RetSqlDel('SC7')

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo  

	If Select("QRY2")<>0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY2" 

	_cMemo      := ''

	_cDescCP  := GetAdvFval('SE4','E4_DESCRI',FWxfilial('SE4') + QRY2->C7_COND,1)
	_cTpFrete := iif(QRY2->C7_TPFRETE == 'S','SIF','FOB')
	_cMoeda   := IIF(QRY2->C7_MOEDA == 2, 'DÓLAR', IIF(QRY2->C7_MOEDA == 4, 'EURO', 'REAL'))
	_nTotPC   := 0.00

	_cMemo += replicate('=',96) + CRLF
	_cMemo += 'Condição Pagto: ' + alltrim(_cDescCP) + ' Tipo Frete: ' + _cTpFrete + ' Moeda: ' + _cMoeda + CRLF

	while QRY2->(!eof())

		_cCotacoes := VisCot()

		_cConsMedio := ''
		_cUltCom    := dtoc(GetAdvFval('SB1','B1_UCOM',FWxfilial('SB1')+QRY2->C7_PRODUTO,1))
		_cConsMedio := transform(GetAdvFval('SB3','B3_MEDIA',FWxfilial('SB3')+QRY2->C7_PRODUTO,1),'@E 999,999,999.99')
		_cUltPrc    := transform(GetAdvFval('SB1','B1_UPRC',FWxfilial('SB1')+QRY2->C7_PRODUTO,1),'@E 999,999,999.99')
		_cGrupo		:= alltrim(GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+QRY2->C7_PRODUTO,1))
		_cSolic		:= alltrim(UsrRetName(GetAdvFVal('SC1','C1_XSOL',FWxfilial('SC1')+QRY2->C7_NUMSC,1)))
		_cCompr		:= alltrim(UsrRetName(alltrim(QRY2->C7_USER)))
		_cPedAbe	:= PedAberto(QRY2->C7_PRODUTO, QRY2->C7_NUM)
		//_cSaldo	:= transform(GetAdvFval('SB2','B2_QATU',FWxfilial('SB2')+QRY2->C7_PRODUTO,1),'@E 999,999,999.99')

		// Calcula o saldo do produto de todos almoxarifados conforme solicitação da Gianice em 04/09/2024
		cCursor    := "TRBSLDSB2"
		cFilialSB2 := FWxfilial('SB2')
		cProduto   := QRY2->C7_PRODUTO

		cQueryB2 := "SELECT B2_QATU FROM "+RetSqlName("SB2")+" WHERE "
		cQueryB2 += "B2_FILIAL='"+cFilialSB2+"' AND "
		cQueryB2 += "B2_COD='"+cProduto+"' AND "
		cQueryB2 += "B2_STATUS <> '2' AND "
		cQueryB2 += "D_E_L_E_T_ = ' ' "
		cQueryB2 += "ORDER BY B2_LOCAL "

		cQuery := ChangeQuery(cQuery)
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryB2),cCursor,.T.,.T.)

		dbSelectArea(cCursor)
		_nSaldo := 0
		While ( !Eof() )
			_nSaldo += (cCursor)->B2_QATU

			dbSelectArea(cCursor)
			dbSkip()
		EndDo

		dbSelectArea(cCursor)
		dbCloseArea()

		_cSaldo := Transform(_nSaldo, '@E 999,999,999.99')

		_cMemo += replicate('=',96) + Chr(13) + Chr(10)
		_cMemo += ' Produto: ' + PADC(QRY2->C7_PRODUTO,10,' ') + '   ' + alltrim(QRY2->C7_DESCRI) + '   (' + QRY2->C7_UM + ')' + CRLF
		_cMemo += ' Grupo :..................................... ' + _cGrupo + CRLF
		_cMemo += ' Solicitante :............................... ' + _cSolic + CRLF
		_cMemo += ' Comprador :................................. ' + _cCompr + CRLF
		_cMemo += ' Quantidade :................................ '
		_cMemo +=   transform(QRY2->C7_QUANT,'@E 999,999,999.99') + CRLF
		_cMemo += ' Valor Unitário :............................ '
		_cMemo +=   transform(QRY2->(C7_PRECO),'@E 999,999,999.99') + CRLF
		_cMemo += ' Valor Desconto :............................ '
		_cMemo +=   transform(QRY2->(C7_VLDESC),'@E 999,999,999.99') + CRLF
		_cMemo += ' Valor IPI :................................. '
		_cMemo +=   transform(QRY2->(C7_VALIPI),'@E 999,999,999.99') + CRLF
		_cMemo += ' Valor ICMS ST :............................. '
		_cMemo +=   transform(QRY2->(C7_VALSOL),'@E 999,999,999.99') + CRLF
		_cMemo += ' Valor Despesa :............................. '
		_cMemo +=   transform(QRY2->(C7_DESPESA),'@E 999,999,999.99') + CRLF
		_cMemo += ' Valor Total :............................... '
		_cMemo +=   transform(QRY2->(C7_TOTAL - C7_VLDESC + C7_VALIPI + C7_VALSOL + C7_DESPESA),'@E 999,999,999.99') + CRLF
		_cMemo += ' Emissão :................................... ' + padl(dtoc(stod(QRY2->C7_EMISSAO)),14,' ') + CRLF
		_cMemo += ' Entrega :................................... ' + padl(dtoc(stod(QRY2->C7_DATPRF)),14,' ') + CRLF
		_cMemo += ' Ultima Compra: ............................. ' + padl(_cUltCom,14,' ') + CRLF
		_cMemo += ' Ultimo Preço :.............................. ' + padl(_cUltPrc,14,' ') + CRLF
		_cMemo += ' Cons. Medio: ............................... ' + padl(_cConsMedio,14,' ') + CRLF
		_cMemo += ' Saldo em Estoque: .......................... ' + padl(_cSaldo,14,' ') + CRLF
		_cMemo += ' Ped. em Aberto: ............................ ' + iif(_cPedAbe, "SIM", "NÃO") + CRLF
		_cMemo += ' Centro de Custo: ........................... ' + padl(iif(empty(QRY2->C7_CC),'',GetAdvFval('CTT','CTT_DESC01',FWxfilial('CTT')+QRY2->C7_CC,1)),14,' ') + CRLF
		_cMemo += ' OBS:   ' + alltrim(QRY2->C7_OBS) + CRLF
		_cMemo += replicate('-',96) + Chr(13) + Chr(10)
		_cMemo += 'COTAÇÕES:    |   Quant.   |   Preco   |   IPI   | Sub.Trib. |  Dif.Aliq.  |  Frete  |    Total  ' + CRLF
		_cMemo += _cCotacoes[1]

		_nTotPC += QRY2->(C7_TOTAL - C7_VLDESC) +_cCotacoes[2] +_cCotacoes[3] +_cCotacoes[4] + _cCotacoes[5]

		QRY2->(dbskip())
	enddo

	if QRY2->(eof())
		_cMemo += replicate('=',96) + CRLF
		_cMemo += 'VALOR TOTAL DO PEDIDO:....................................................... ' + Transform(_nTotPC,'@E 999,999,999,999.99') + CRLF
		_cMemo += replicate('=',96) + CRLF
	endif      

	_nTotPC := 0

	DEFINE FONT oFont NAME "Mono AS" SIZE 6,15   //6,15
	DEFINE MSDIALOG oEnc TITLE 'Informações Específicas' from 00,00 to 570,670 OF oMainWnd PIXEL 

	@ 5,5 GET oMemo VAR _cMemo MEMO SIZE 330,250 OF oEnc PIXEL
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:= oFont
	oMemo:lReadOnly := .t.

	@ 265,020  BUTTON 'Liberar'  SIZE 40,15 ACTION Libera(aBrowse1[oBrowse1:nAt,02]) OBJECT oBtn1
	@ 265,080  BUTTON 'Bloquear' SIZE 40,15 ACTION Bloqueia(aBrowse1[oBrowse1:nAt,02]) OBJECT oBtn2
	@ 265,260  BUTTON 'Sair'     SIZE 40,15 ACTION oEnc:end() OBJECT oBtn3 

	ACTIVATE MSDIALOG oEnc     

	QRY2->(dbclosearea())
	//restarea(area)

Return

// Verifica se existem pedidos em aberto
Static Function PedAberto(_cProd, _cNumPed)

    local _cQuery   := ""
    local nCount    := 0 
    local _lRet     := .f.

    _cQuery := " SELECT *"
    _cQuery += " FROM " + retSqlTab('SC7') + " (NOLOCK)"
    _cQuery += " WHERE "+ retSqlFil('SC7')
    _cQuery += " AND (C7_QUANT-C7_QUJE) > 0"
	_cQuery += " AND C7_RESIDUO = ' '"
    _cQuery += " AND C7_PRODUTO = '"+_cProd+"'"
	_cQuery += " AND C7_NUM <> '"+_cNumPed+"'"
	_cQuery += " AND C7_EMISSAO >= '"+dtos((ddatabase-365))+"'"
    _cQuery += " AND " + retSqlDel('SC7')

    cAlias := GetNextAlias()
	TCQuery _cQuery new alias &cAlias

    (cAlias)->(dbGoTop())

    //verifica se houve retorno na query
    Count to nCount

    If nCount > 0
        _lRet := .t.
    endif

    (cAlias)->(dbCloseArea())

Return _lRet

/////////Visualizaçao dos itens de cotação
Static Function VisCot()

	Local _cMemoC := ''

	//area := getarea()
	_cIdent := GetAdvFval('SC8','C8_IDENT',FWxfilial('SC8')+QRY2->(C7_NUMSC+C7_ITEMSC+C7_NUMCOT),12)

	//traz o preço do produto da tabela de PC
	cQuery := "SELECT C8_NUM,C8_PRODUTO,C8_FORNECE,C8_LOJA,C8_IDENT,"
	cQuery += " C8_NUMPED,C8_ITEMPED,C8_PRECO,C8_QUANT,C8_TOTAL,"
	cQuery += " C8_DIFALIQ, C8_VALSOL, C8_VALIPI, C8_TOTFRE"
	cQuery += " FROM " + RetSqlTab("SC8")
	cQuery += " WHERE " + RetSQLFil('SC8')
	cQuery += " AND C8_PRODUTO = '" + alltrim(QRY2->C7_PRODUTO) + "'"
	cQuery += " AND C8_IDENT = '" + _cIdent + "'"
	cQuery += " AND C8_NUM = '" + QRY2->C7_NUMCOT + "'"
	cQuery += " AND " + RetSQLDel('SC8')
	cQuery += " ORDER BY C8_NUMPED,C8_ITEMPED"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//
	//Activate Dialog oDlgMemo  

	If Select("QRY3")<>0
		QRY3->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "QRY3" 

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	_aArqTrb := {}
	aStru := {}

	aadd(aStru,{"C8_NUMPED" , "C",  6, 0, "@!"          		 	  , 'Num. Pedido'})
	aadd(aStru,{"C8_NUM"    , "C",  6, 0, "@!"          		 	  , 'Num. Cotação'})
	aadd(aStru,{"C8_PRODUTO", "C", 15, 0, "@!"          		 	  , 'Produto'})
	aadd(aStru,{"C8_QUANT"  , "N", 18, 7, "@E 9,999,999,999.9999999"  , 'Quantidade'})
	aadd(aStru,{"C8_XTOTAL" , "N", 15, 2, "@E 999,999,999,999.99"	  , 'Total Item'})
	aadd(aStru,{"C8_FORNECE", "C",  6, 0, "@!"          		 	  , 'Fornecedor'})
	aadd(aStru,{"C8_LOJA"   , "C",  2, 0, "@!"          		 	  , 'Loja'})
	aadd(aStru,{"C8_DIFALIQ", "N",  7, 3, "@E 999.999"                , 'Dif. Aliquot'})
	aadd(aStru,{"C8_VALSOL" , "N", 14, 2, "@E 99,999,999,999.99"      , 'Val.ICMS Sol'})
	aadd(aStru,{"C8_VALIPI" , "N", 14, 2, "@E 99,999,999,999.99"      , 'Vlr. IPI'})
	aadd(aStru,{"C8_TOTFRE" , "N", 14, 2, "@E 99,999,999,999.99"      , 'Frete Total'})
	aadd(aStru,{"C8_VENC"   , "C", 20, 0, "@!"          		 	  , 'Vencedor'})
	aadd(aStru,{"C8_NFOR"   , "C", 30, 0, "@!"          		 	  , 'Nome Forn.'})
	aadd(aStru,{"C8_XPRECO" , "N", 15, 2, "@E 999,999,999,999.99"	  , 'Preço'})

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//TMP->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	QRY3->(dbgotop())

	_cDescProd := ''

	while QRY3->(!eof())  

		if QRY3->C8_NUMPED <> 'XXXXXX' .and. !empty(QRY3->C8_NUMPED)
			_cDescProd := GetAdvFval('SC7','C7_DESCRI',FWxfilial('SB1')+QRY3->(C8_NUMPED+C8_ITEMPED),1)
		endif

		_nTotal := QRY3->C8_TOTAL
		_nPreco := QRY3->C8_PRECO

		reclock('TMP',.t.) 
		TMP->C8_NUMPED  := QRY3->C8_NUMPED
		TMP->C8_NUM     := QRY3->C8_NUM
		TMP->C8_PRODUTO := QRY3->C8_PRODUTO 
		TMP->C8_QUANT   := QRY3->C8_QUANT
		TMP->C8_XTOTAL  := _nTotal
		TMP->C8_FORNECE := QRY3->C8_FORNECE 
		TMP->C8_LOJA    := QRY3->C8_LOJA 
		TMP->C8_DIFALIQ := QRY3->C8_DIFALIQ
		TMP->C8_VALSOL  := QRY3->C8_VALSOL
		TMP->C8_VALIPI  := QRY3->C8_VALIPI
		TMP->C8_TOTFRE  := QRY3->C8_TOTFRE
		TMP->C8_NFOR    := GetAdvFval('SA2','A2_NOME',FWxfilial('SA2')+QRY3->(C8_FORNECE+C8_LOJA),1)
		TMP->C8_XPRECO  := _nPreco
		if QRY3->C8_NUMPED <> 'XXXXXX' .and. !empty(QRY3->C8_NUMPED)
			TMP->C8_VENC := ' << Vencedor >>'
		endif
		msunlock()

		QRY3->(dbskip())
	enddo

	TMP->(dbgotop())

	_nIPI      := 0.00
	_nSusTrib  := 0.00
	_nDifAliq  := 0.00
	_nTotFre   := 0.00

	While TMP->(!Eof())

		_cMemoC +=  TMP->C8_NUM + "   " + TMP->C8_FORNECE + "-" + TMP->C8_LOJA + space(3) +  TMP->C8_NFOR + ' ' + alltrim(TMP->C8_VENC) + CRLF
		_cMemoC += space(10)
		_cMemoC += transform(TMP->C8_QUANT,'@E 999,999.9999')
		_cMemoC += space(3) + transform(TMP->C8_XPRECO,'@E 99,999,999.99')
		_cMemoC += space(4) + transform(TMP->C8_VALIPI,'@E 999.99')
		_cMemoc += space(2) + transform(TMP->C8_VALSOL,'@E 999,999.99')
		_cMemoC += space(5) + transform(TMP->C8_DIFALIQ,'@E 999.99')
		_cMemoC += space(2) + transform(TMP->C8_TOTFRE,'@E 99,999.99')
		_cMemoC += space(1) + transform(TMP->(C8_XTOTAL+C8_VALIPI+C8_VALSOL+C8_DIFALIQ+C8_TOTFRE),'@E 99,999,999.99')
		_cMemoC += CRLF

		if  !empty(TMP->C8_VENC)
			_nIPI      := TMP->C8_VALIPI
			_nSusTrib  := TMP->C8_VALSOL
			_nDifAliq  := TMP->C8_DIFALIQ
			_nTotFre   := TMP->C8_TOTFRE
		endif

		TMP->(DbSkip())
	enddo

	QRY3->(dbclosearea())

Return {_cMemoC , _nIPI , _nSusTrib , _nDifAliq , _nTotFre}

//Função para liberação do PC
Static Function Libera(_cNum)
	SCR->(DbSetOrder(1))
	SCR->(DbGoTop())
	if SCR->(MsSeek(FWxfilial('SCR')+'PC' + _cNum))
		While SCR->(!eof()) .and. SCR->CR_TIPO = 'PC' .and. SCR->CR_NUM = _cNum

			reclock('SCR',.f.)
			if SCR->CR_NIVEL = '01'
				SCR->CR_STATUS  := iif(_cCodUser = SCR->CR_USER ,'03','05')
				SCR->CR_DATALIB := ddatabase
				SCR->CR_APROV   := _cCodLib
				SCR->CR_USERLIB := _cCodUser
				SCR->CR_LIBAPRO := iif(_cCodUser = SCR->CR_USER,_cCodLib,'')
				SCR->CR_TIPOLIM := iif(_cCodUser = SCR->CR_USER,'D','')
				SCR->CR_USERPED := GetAdvFval('SC7','C7_USER',FWxfilial('SC7')+_cNum,1)
			elseif SCR->CR_NIVEL = '02'
				SCR->CR_STATUS  := '02'
				SCR->CR_USERPED := GetAdvFval('SC7','C7_USER',FWxfilial('SC7')+_cNum,1)
			endif
			msunlock()

			SCR->(DbSkip())
		enddo

		AtuBrow()
		oEnc:end()

		gjf171wfw(_cNum,'L')
	else
		//alert('não achou')
	endif

return        

//Função para bloqueio do PC
Static Function Bloqueia(_cNum)
	SCR->(DbSetOrder(1))
	SCR->(DbGoTop())    
	if SCR->(MsSeek(FWxfilial('SCR')+'PC' + _cNum))
		While SCR->(!eof()) .and. SCR->CR_TIPO = 'PC' .and. SCR->CR_NUM = _cNum

			reclock('SCR',.f.)
			if SCR->CR_NIVEL = '01'
				SCR->CR_STATUS  := iif(_cCodUser = SCR->CR_USER ,'04','05')
				SCR->CR_DATALIB := ddatabase
				SCR->CR_OBS     := iif(_cCodUser <> SCR->CR_USER,'Doc.Bloq.Usuario: ' + _cCodUser,'')
				SCR->CR_USERLIB := _cCodUser
				SCR->CR_LIBAPRO := _cCodLib
				SCR->CR_USERPED := GetAdvFval('SC7','C7_USER',FWxfilial('SC7')+_cNum,1)
			endif

			msunlock()

			SCR->(DbSkip())
		enddo

		AtuBrow()

		oEnc:end()

		gjf171wfw(_cNum,'B')

	else
		//alert('não achou')
	endif

return        

//workflow para a galera do DTI
Static function gjf171wfw(_numPC,_oper)
	Local i
	//area := getArea()

	//_CodUser := GetAdvFval('SC1','C1_USER',FWxfilial('SC1')+_numPC,6)

	// a dimensao 1 contem os dados cadastrais do usuario
	// a dimensao 2 contem os dados de detalhe
	// a dimensao 3 contem os menus de cada modulo
	/*if _CodUser $ '000046/000315/000049/000712/000498'

		_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
		_cMens += 'Na data e hora da emissão deste email, o pedido de Número ' + _NumPC+ ' foi ' +iif(_oper = 'B', 'bloqueado','liberado') + ':' + chr(13) + chr(10)
		_cMens +=   chr(13) + chr(10)

		SC7->(DbsetOrder(1))
		SC7->(DbGoTop())
		if SC7->(MsSeek(FWxfilial('SC7') + _numPC))

			while SC7->(!eof()) .and. SC7->C7_FILIAL = FWxfilial('SC7') .and. SC7->C7_NUM = _numPC
				_cMens += 'Produto: (' + SC7->C7_PRODUTO  + ') ' + SC7->C7_DESCRI + chr(13) + chr(10)
				_cMens += 'Quantidade: ' + transform(SC7->C7_QUANT,'@E 999,999.999') + chr(13) + chr(10) 
				_cMens += 'Preço Unit: ' + transform(SC7->C7_PRECO,'@E 999,999.999') + chr(13) + chr(10)

				SC7->(DbSkip())
			enddo
		endif
		_cTit  := 'Workflow Frigorífico Silva: Aviso de Liberação/Bloqueio de Pedido de Compra.'
		_cDest := 'compras@frigorificosilva.com.br,compras4@frigorificosilva.com.br,compras2@frigorificosilva.com.br'

		if !empty(_cDest)
			_aEmail := u_GJF54(_cMens,_cTit,_cDest)
		endif

		for i := 1 to len(_aEmail)
			if !_aEmail[i]
				alert('ERRO WORKFLOW ('+ str(i) +')')
			endif
		next
	else*/ //envia tudo pro compras
		_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
		_cMens += 'Na data e hora da emissão deste email, o pedido de Número ' + _NumPC+ ' foi ' +iif(_oper = 'B', 'bloqueado','liberado') + ':' + chr(13) + chr(10)
		_cMens +=   chr(13) + chr(10)

		SC7->(DbsetOrder(1))
		SC7->(DbGoTop())
		if SC7->(MsSeek(FWxfilial('SC7') + _numPC))
			while SC7->(!eof()) .and. SC7->C7_FILIAL = FWxfilial('SC7') .and. SC7->C7_NUM = _numPC
				_cMens += 'Produto: (' + SC7->C7_PRODUTO  + ') ' + SC7->C7_DESCRI + chr(13) + chr(10)
				_cMens += 'Quantidade: ' + transform(SC7->C7_QUANT,'@E 999,999.999') + chr(13) + chr(10)
				_cMens += 'Preço Unit: ' + transform(SC7->C7_PRECO,'@E 999,999.999') + chr(13) + chr(10)

				SC7->(DbSkip())
			enddo
		endif
		_cTit  := 'Workflow Frigorífico Silva: Aviso de Liberação/Bloqueio de Pedido de Compra.'
		_cDest := 'compras@frigorificosilva.com.br,compras4@frigorificosilva.com.br,compras2@frigorificosilva.com.br'

		if !empty(_cDest)
			_aEmail := u_GJF54(_cMens,_cTit,_cDest)
		endif

		for i := 1 to len(_aEmail)
			if !_aEmail[i]
				alert('ERRO WORKFLOW ('+ str(i) +')')
			endif
		next

	//endif
	//restarea(area)

return
