#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch' 
#INCLUDE "TOTVS.CH" 
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF231    บ Autor ณ Giuliano Forgiariniบ Data ณ  29/09/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Consulta de posi็ใo de estoque, produ็ใo e empenhos de     บฑฑ
ฑฑบ          ณ produtos porcionados                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Comercial e Porcionados                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function GJF231()      

	Private aBrowse1     := {}
	Private _cGrpMoi     := GetMV('SI_GRPMOI')
	Private _nItens      := 0
	Private _nTotProCaix := 0
	Private _nTotProPeso := 0
	Private _nTotEstCaix := 0
	Private _nTotEstPeso := 0
	Private _nTotEmpCaix := 0
	Private _nTotEmpPeso := 0

	Private cPerg := "GJF231"


	If !Pergunte(cPerg,.T.)
		Return
	Endif  

	aHeader1  := {'Codigo','Descricao','A produzir(cx)','A produzir(kg)','Estoque(cx)','Estoque(kg)','Empenho(cx)','Empenho(kg)','Saldo(cx)','Saldo(kg)'}
	aLargCol1 := {   30   ,      100   ,         40    ,          40   ,   40        ,  40         ,   40        ,    40       ,    40     ,     40    }

	DEFINE DIALOG oDlg TITLE "Acompanhamento Produ็ใo X Estoque X Empenho Produtos Porcionados" FROM 020,105 To 460,1020 PIXEL

	oBrowse1 := TCBrowse():New(005,005,450,150,,aHeader1,aLargCol1,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )  

	MsgRun("Aguarde... Realizando processamento!" ,,{||GeraTMP()})

	@ 013,001 SAY "Total a produzir: " + transform(_nTotProCaix,"@E 999,999") + "(cx) " + transform(_nTotProPeso,"@E 999,999,999.99")+"(kg)"  of oDlg
	@ 014,001 SAY "Total em estoque: " + transform(_nTotEstCaix,"@E 999,999") + "(cx) " + transform(_nTotEstPeso,"@E 999,999,999.99")+"(kg)"  of oDlg
	@ 015,001 SAY "Total em empenho: " + transform(_nTotEmpCaix,"@E 999,999") + "(cx) " + transform(_nTotEmpPeso,"@E 999,999,999.99")+"(kg)"  of oDlg

	@ 200,350  BUTTON 'Sair'  SIZE 40,10 ACTION oDlg:end() OBJECT oBtn1

	ACTIVATE DIALOG oDlg CENTERED   



Static Function GeraTMP()
	aBrowse1 := {}

	_cQuery  := " SELECT * FROM " + RetSQLTab('SB1') + "," + RetSQLTab('SBM')
	_cQuery  += " WHERE " + RetSQLFil('SB1') + " AND " + RetSQLFil('SBM') + " AND "
	_cQuery  += " B1_GRUPO = BM_GRUPO AND BM_PORC = 'S' AND B1_MSBLQL = '2' "
	_cQuery  += iif(!empty(mv_par01)," AND B1_FAM = '" + mv_par01 + "' "," ")
	_cQuery  += iif(!empty(mv_par02)," AND B1_GRUPO = '" + mv_par02 + "' "," ")
	_cQuery  += " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('SBM')
	_cQuery  += " ORDER BY B1_DESC

	_cQuery := ChangeQuery(_cQuery)

	If Select("QRY") <> 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	QRY->(dbgotop())					    

	Processa({||Processar() },"CALCULOS INICIADOS","Realizando processamento ..." ) 

	if len(aBrowse1) = 0
		aadd(aBrowse1,{'','','','','','','','','',''})
	endif


	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],;
	aBrowse1[oBrowse1:nAt,06],aBrowse1[oBrowse1:nAt,07],aBrowse1[oBrowse1:nAt,08],aBrowse1[oBrowse1:nAT,09],aBrowse1[oBrowse1:nAT,10]}}

	oBrowse1:nScrollType := 1
	oBrowse1:DrawSelect()
	oBrowse1:refresh()
	oDlg:refresh()

return


Static Function Processar()
	_nItens := 0
	while QRY->(!eof())
		_nItens++
		QRY->(DbSkip())
	enddo

	ProcRegua(_nItens)

	QRY->(DbgoTop())
	While QRY->(!eof())

		incproc('Calculando saldo do produto:' + QRY->B1_COD)

		//A produzir  - lotes ZAU
		_cQuery2 := " SELECT SUM(ZAU_QPPESO - ZAU_QRPESF) AS _PROPESO, SUM(ZAU_QPCAIX - ZAU_QRCAIF) AS _PROCAIX"
		_cQuery2 += " FROM " + RetSQLTab('ZAU')
		_cQuery2 += " WHERE "+ RetSQLFil('ZAU')
		_cQuery2 += " AND ZAU_COD = '" + alltrim(QRY->B1_COD) + "'"
		_cquery2 += " AND ZAU_STATUS <> 'E' 
		_cQuery2 += " AND ZAU_DTPROD = '" + dtos(DDATABASE) +  "' "
		_cQuery2 += " AND " + RetSQLDel('ZAU')

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		//Em estoque  - caixas SZ8
		_cQuery3 := " SELECT SUM(Z8_PESO) AS _PESO, COUNT(*) AS _CAIXAS"
		_cQuery3 += " FROM " + RetSQLTab('SZ8')
		_cQuery3 += " WHERE "+ RetSQLFil('SZ8')
		_cQuery3 += " AND Z8_COD = '" + alltrim(QRY->B1_COD) + "' AND Z8_FIL = '" + cFilAnt + "'"
		_cquery3 += " AND Z8_LOTEPOR <> '' AND Z8_DATAS = '' AND Z8_HORAS = '' AND Z8_PRECAR = ' ' AND Z8_PREPED = ' ' AND Z8_ITEM = ' '"  
		_cQuery3 += " AND " + RetSQLDel('SZ8')

		//cQuery+= " +"  AND "+RetSqlDel("ZZ5,ZZ4")+" GROUP BY ZZ5_COD) DD ON DD.ZZ5_COD = A.PRODUTO"

		//Empenho - tabela ZZ4 e ZZ5
		_cQuery4 := " SELECT SUM(ZZ5_QPPESO-ZZ5_QRPESO) AS _PESOEMP, SUM(ZZ5_QPCAIX-ZZ5_QRCAIX) AS _CAIXEMP"
		_cQuery4 += " FROM " + RetSQLTab('ZZ5') + "," + RetSQLTab('ZZ4')
		_cQuery4 += " WHERE " + RetSQLFil('ZZ5') + " AND " + RetSQLFil('ZZ4')
		_cQuery4 += " AND ZZ5_COD = '" + alltrim(QRY->B1_COD) + "' AND ZZ5_STATUS <> 'E' AND ZZ5_NUM = ZZ4_NUM "
		_cQuery4 += " AND ZZ4_DATA = '" + DTOS(ddatabase) + "' AND ZZ4_TPOPER = 'V'"
		_cquery4 += " AND ZZ4_STATUS NOT IN('E','F','P')  AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5') 	

		_cQuery2  := ChangeQuery(_cQuery2)
		_cQuery3  := ChangeQuery(_cQuery3)
		_cQuery4  := ChangeQuery(_cQuery4)

		If Select("QRY2")<>0
			QRY2->(dbCloseArea())
		Endif
		If Select("QRY3")<>0
			QRY3->(dbCloseArea())
		Endif
		If Select("QRY4")<>0
			QRY4->(dbCloseArea())
		Endif	         

		TCQUERY _cQuery2 NEW ALIAS "QRY2"
		TCQUERY _cQuery3 NEW ALIAS "QRY3"
		TCQUERY _cQuery4 NEW ALIAS "QRY4"

		_nSaldoC := QRY2->_PROCAIX + QRY3->_CAIXAS - QRY4->_CAIXEMP
		_nSaldoP := QRY2->_PROPESO + QRY3->_PESO - QRY4->_PESOEMP

		if (QRY2->_PROCAIX) <> 0 .or.;
		(QRY3->_CAIXAS) <> 0 .or.;
		(QRY4->_CAIXEMP) <> 0

			aadd(aBrowse1,{QRY->B1_COD,;
			alltrim(QRY->B1_DESC),;
			transform(iif(QRY2->_PROPESO < 0,0,QRY2->_PROPESO),'@E 999,999.99'),;     //a produzir peso
			transform(iif(QRY2->_PROCAIX < 0,0,QRY2->_PROCAIX),'@E 999,999'),;      //a produzir caixa 
			transform(QRY3->_PESO,'@E 999,999.99'),;     //a produzir peso
			transform(QRY3->_CAIXAS,'@E 999,999'),;      //a produzir caixa         
			transform(QRY4->_PESOEMP,'@E 999,999.99'),;     //a produzir peso
			transform(QRY4->_CAIXEMP,'@E 999,999'),;      //a produzir caixa 					   
			transform(_nSaldoP,'@E 999,999.99'),;     
			transform(_nSaldoC,'@E 999,999')})          

			_nTotProCaix += iif(QRY2->_PROCAIX < 0,0,QRY2->_PROCAIX)    
			_nTotProPeso += iif(QRY2->_PROPESO < 0,0,QRY2->_PROPESO)   

			_nTotEstCaix += QRY3->_CAIXAS
			_nTotEstPeso += QRY3->_PESO

			_nTotEmpCaix += QRY4->_CAIXEMP
			_nTotEmpPeso += QRY4->_PESOEMP					
		endif	   

		QRY->(DbSkip())
	enddo

return

