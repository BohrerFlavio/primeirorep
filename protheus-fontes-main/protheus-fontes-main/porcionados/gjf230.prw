#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch' 
#INCLUDE "TOTVS.CH" 
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF230    บ Autor ณ Giuliano Forgiariniบ Data ณ  21/09/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Controle de Produ็ใo de Mat้ria Prima de Porcionados       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCP e Porcionados                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function GJF230()      

	Private aBrowse1  := {}
	Private _cGrpMoi  := GetMV('SI_GRPMOI')
	Private cPerg := "GJF230"


	If !Pergunte(cPerg,.T.)
		Return
	Endif    
	//      1         2          3                4        5         6          
	aHeader1  := {'Codigo','Descri็ใo','Necessidade em ' + dtoc(mv_Par01),'Consumo em '  + dtoc(mv_Par01),'Estoque em ' + dtoc(mv_Par01),'A Produzir em ' + dtoc(mv_Par02)}
	aLargCol1 := {   40   ,80         ,80          ,80          ,80       ,80         }

	DEFINE DIALOG oDlg TITLE "Controle de Produ็ใo de Materia Prima para Porcionados" FROM 020,105 To 350,1020 PIXEL

	oBrowse1 := TCBrowse():New(005,005,450,140,,aHeader1,aLargCol1,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )  

	GeraTMP()

	@ 150,350  BUTTON 'Sair'  SIZE 40,10 ACTION oDlg:end() OBJECT oBtn1

	ACTIVATE DIALOG oDlg CENTERED   



Static Function GeraTMP()
	aBrowse1 := {}

	_cQuery1 := " SELECT ZAU_CODMP AS _COD,SUM(ZAU_QTDMP) AS _MP FROM " + RetSQLTab('ZAU')  + " WHERE " + RetSQLFil('ZAU')
	_cQuery1 += " AND ZAU_DTPROD =  '" + dtos(mv_par01) +  "' "
	_cQuery1 += " AND ZAU_CODMP NOT LIKE 'RECEIT%' AND ZAU_STATUS <> 'E' AND " + RetSQLDel('ZAU')
	_cQuery1 += " GROUP BY ZAU_CODMP "
	_cQuery1 += " UNION "
	_cQuery1 += " SELECT ZAV_COD AS _COD, SUM(ZAV_QPPESO) AS _MP FROM " + RetSQLTab('ZAU') + " , " + RetSQLTab('ZAV')
	_cQuery1 += " WHERE ZAV_NUM = ZAU_NUM AND ZAU_STATUS <> 'E' "
	_cQuery1 += " AND " + RetSQLFil('ZAV') + " AND " + RetSQLFil('ZAU')
	_cQuery1 += " AND ZAU_DTPROD =  '" + dtos(mv_par01) +  "' "
	_cQuery1 += " AND " + RetSQLDel('ZAV') + " AND " + RetSQLDel('ZAU')
	_cQuery1 += " GROUP BY ZAV_COD "

	_cQuery1  := ChangeQuery(_cQuery1)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery1 NEW ALIAS "QRY"

	QRY->(dbgotop())					    

	DbSelectArea('SB1')

	While QRY->(!eof())

		_cDesc := fBuscaCPO('SB1',1,xfilial('SB1') + QRY->_COD,'B1_DESCRED')

		//A produzir
		_cQuery2 := " SELECT SUM(ZU_QPPESO - ZU_QRPESO) AS _APROD"
		_cQuery2 += " FROM " + RetSQLTab('SZU')
		_cQuery2 += " WHERE "+ RetSQLFil('SZU')
		_cQuery2 += " AND ZU_COD = '" + QRY->_COD + "'"
		_cquery2 += " AND ZU_MPPORC = 'S' 
		_cQuery2 += " AND ZU_DTRPRO = '" + dtos(mv_par02) +  "' "
		_cQuery2 += " AND " + RetSQLDel('SZU')

		//Em estoque
		_cQuery3 := " SELECT SUM(ZAS_PESOL) AS _EST"
		_cQuery3 += " FROM " + RetSQLTab('ZAS')
		_cQuery3 += " WHERE "+ RetSQLFil('ZAS')
		_cQuery3 += " AND ZAS_COD = '" + QRY->_COD + "'"
		_cquery3 += " AND ZAS_TIPO = 'MP' AND ZAS_DATAS = '' AND ZAS_HORAS = '' "  
		_cQuery3 +=  " AND " + RetSQLDel('ZAS')

		//Consumida
		_cQuery4 := " SELECT SUM(ZAS_PESOL) AS _CONS"
		_cQuery4 += " FROM " + RetSQLTab('ZAS')
		_cQuery4 += " WHERE "+ RetSQLFil('ZAS')
		_cQuery4 += " AND ZAS_COD = '" + QRY->_COD + "'"
		_cquery4 += " AND ZAS_TIPO = 'MP' AND ZAS_DATAS = '" +  dtos(mv_par01) + "' AND ZAS_HORAS <> '' "  
		_cQuery4 += " AND " + RetSQLDel('ZAS') 	

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

		QRY2->(dbgotop())					    
		QRY3->(dbgotop())
		QRY4->(dbgotop())

		aadd(aBrowse1,{QRY->_COD,;
		_cDesc,;
		transform(QRY->_MP,'@E 999,999.99'),;     //Necessidade  
		transform(QRY4->_CONS,'@E 999,999.99'),;  //Consumida
		transform(QRY3->_EST,'@E 999,999.99'),;  //Estoque  
		transform(iif(QRY2->_APROD <=0,0,QRY2->_APROD),'@E 999,999.99')}) 

		QRY->(DbSkip())
	enddo

	if len(aBrowse1) = 0
		aadd(aBrowse1,{'','','','','','',''})
	endif


	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],;
	aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],aBrowse1[oBrowse1:nAT,06]}}

	oBrowse1:nScrollType := 1
	oBrowse1:DrawSelect()
	oBrowse1:refresh()
	oDlg:refresh()
return

