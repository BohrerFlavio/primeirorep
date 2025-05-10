#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

User Function MT120BRW()

	//Define Array contendo as Rotinas a executar do programa     
	// ----------- Elementos contidos por dimensao ------------    
	// 1. Nome a aparecer no cabecalho                             
	// 2. Nome da Rotina associada                                 
	// 3. Usado pela rotina                                        
	// 4. Tipo de Transao a ser efetuada                         
	//    1 - Pesquisa e Posiciona em um Banco de Dados            
	//    2 - Simplesmente Mostra os Campos                        
	//    3 - Inclui registros no Bancos de Dados                  
	//    4 - Altera o registro corrente                           
	//    5 - Remove o registro corrente do Banco de Dados        
	//    6 - Altera determinados campos sem incluir novos Regs    

	_cUsrCom := GetMV("FS_USRCOM")	// Parโmetro que define os usuแrios do setor de compras que tem acesso a todas rotinas cfe abaixo
	_cUsrRec := GetMV("FS_USRREC")	// Parโmetro que define os usuแrios do setor de recebimento de materiais com acesso a algumas das op็๕es abaixo
	If AllTrim(UPPER(cUserName)) $ AllTrim(UPPER(_cUsrCom))
		aAdd(aRotina, {'Dados DI' 				, 'U_GJFDI()'															  , 0, 4})
		aAdd(aRotina, {'Ajuste PC'				, 'U_GJFAJ()'  															  , 0, 4})
		aAdd(aRotina, {'Ajuste PC XML'			, 'U_GJFAX()'  															  , 0, 4})
		aAdd(aRotina, {'Rateio Item'			, 'U_GJFRT()'  															  , 0, 4})
		aAdd(aRotina, {'Resumo do Pedido'		, 'U_ResPed()'  														  , 0, 4})
		aAdd(aRotina, {'Envia eMail Fornecedor'	, "U_STI_CP50(SC7->C7_FILIAL, SC7->C7_NUM, SC7->C7_FORNECE, SC7->C7_LOJA)", 0, 0, 0, Nil})// "Envia Pedido de Compra ao Fornecedor"	
	elseIf AllTrim(UPPER(cUserName)) $ AllTrim(UPPER(_cUsrRec))
		aAdd(aRotina, {'Dados DI' 				, 'U_GJFDI()'															  , 0, 4})
		aAdd(aRotina, {'Ajuste PC'				, 'U_GJFRC()'  															  , 0, 4})
		aAdd(aRotina, {'Ajuste PC XML'			, 'U_GJFAX()'  															  , 0, 4})
		aAdd(aRotina, {'Rateio Item'			, 'U_GJFRT()'  															  , 0, 4})
		aAdd(aRotina, {'Resumo do Pedido'		, 'U_ResPed()'  														  , 0, 4})
		aAdd(aRotina, {'Envia eMail Fornecedor'	, "U_STI_CP50(SC7->C7_FILIAL, SC7->C7_NUM, SC7->C7_FORNECE, SC7->C7_LOJA)", 0, 0, 0, Nil})// "Envia Pedido de Compra ao Fornecedor"	
	Else
		aAdd(aRotina, {'Dados DI' 				, 'U_GJFDI()'															  , 0, 4})
		aAdd(aRotina, {'Ajuste PC XML'			, 'U_GJFAX()'  															  , 0, 4})
		aAdd(aRotina, {'Rateio Item'			, 'U_GJFRT()'  															  , 0, 4})
		aAdd(aRotina, {'Resumo do Pedido'		, 'U_ResPed()'  														  , 0, 4})
		aAdd(aRotina, {'Envia eMail Fornecedor'	, "U_STI_CP50(SC7->C7_FILIAL, SC7->C7_NUM, SC7->C7_FORNECE, SC7->C7_LOJA)", 0, 0, 0, Nil})// "Envia Pedido de Compra ao Fornecedor"	
	EndIf

Return

// Tela com informa็๕es resumidas de compras
User Function ResPed()

	Local aUsrCot := StrTokArr(GetAdvFVal('SC8','C8_MAILUSR',FWxfilial('SC8')+SC7->C7_NUMCOT,1),'@')

	@ 000, 000 To 300, 450 DIALOG oDlg2 TITLE "Resumo do Pedido"
	@ 005, 005 SAY "Solicita็ใo: " + SC7->C7_NUMSC + " - " + UsrRetName(GetAdvFVal('SC1','C1_XSOL',FWxfilial('SC1')+SC7->C7_NUMSC,1))
	@ 020, 005 SAY "Cota็ใo: " + SC7->C7_NUMCOT + " - " + aUsrCot[1]
	@ 035, 005 SAY "Pedido: " + SC7->C7_NUM + " - " + UsrRetName(alltrim(SC7->C7_USER))

	@ 135, 025 BMPBUTTON TYPE 1 ACTION oDlg2:end()

	ACTIVATE DIALOG oDlg2 CENTERED

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ GFJDI    บ Autor ณ                    บ Data ณ             บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Informa็ใo dos Dados da DI                                 บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
User Function GJFDI()  
	_cNDI    := SC7->C7_NDI
	_dDDI    := SC7->C7_DDI
	_cLocDes := SC7->C7_LOCDES
	_cUFDes  := SC7->C7_UFDESEM
	_dDtDes  := SC7->C7_DTDES
	_cExport := SC7->C7_EXPORT  

	_lCancela := .T.
	@ 000, 000 To 200, 290 DIALOG oDlg1 TITLE "Dados da DI para Importa็ใo"
	@ 005, 005 SAY "Numero DI"
	@ 015, 005 SAY "Data DI" 
	@ 025, 005 SAY "Local Desemb." 
	@ 035, 005 SAY "UF Desemb." 
	@ 045, 005 SAY "Data Desemb." 
	@ 055, 005 SAY "Cod. Export." 

	@ 005, 050 GET _cNDI     SIZE 040, 11
	@ 015, 050 GET _dDDI     SIZE 040, 11  
	@ 025, 050 GET _cLocDes  SIZE 080, 11  
	@ 035, 050 GET _cUFDes   SIZE 020, 11  
	@ 045, 050 GET _dDtDes   SIZE 040, 11  
	@ 055, 050 GET _cExport  SIZE 080, 11  

	@ 070, 025 BMPBUTTON TYPE 1 ACTION (_lCancela := .F., Close(oDlg1))
	@ 070, 055 BMPBUTTON TYPE 2 ACTION (_lCancela := .T., Close(oDlg1))

	ACTIVATE DIALOG oDlg1 CENTERED

	If !_lCancela 
		_cQuery := "UPDATE " + RetSqlName('SC7')
		_cQuery += " SET C7_NDI      = '" + _cNDI + "', "
		_cQuery +=     " C7_DDI      = '" + dtos(_dDDI) + "',"
		_cQuery +=     " C7_LOCDES   = '" + _cLocDes + "',"
		_cQuery +=     " C7_UFDESEM  = '" + _cUFDes + "',"
		_cQuery +=     " C7_DTDES    = '" + dtos(_dDtDes) + "',"
		_cQuery +=     " C7_EXPORT   = '" + _cExport + "'"
		_cQuery += " WHERE D_E_L_E_T_ <> '*'"
		_cQuery += " AND C7_NUM = '" + SC7->C7_NUM + "'"
		_cQuery += " AND C7_FILIAL = '" + FWxFilial('SC7') + "'"
		TcSqlExec(_cQuery)
	EndIf                               

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ GFJDI    บ Autor ณ                    บ Data ณ             บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Informa็ใo de Ajustes do Pedido de Compras                 บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
User Function GJFAJ()   
	if SC7->C7_RESIDUO = 'S'
		alert('Resํduio eliminado!')
		return
	endif

	if SC7->C7_CONAPRO <> 'L'
		alert('Pedido de Compra deve jแ estar liberado!')
		return
	endif

	_cCampForn := ""
	_cForn     := SC7->C7_FORNECE

	_cCampLoja := ""
	_cLoja     := SC7->C7_LOJA

	_cCampDForn:= ""
	_cDescForn := GetAdvFVal('SA2','A2_NOME',FWxfilial('SA2') + _cForn + _cLoja,1)

	_cCampCPag := ""
	_cCPag     := SC7->C7_COND

	_cCampDCond:= ""
	_cDescCond := GetAdvFVal('SE4','E4_DESCRI',FWxfilial('SE4') + _cCPag,1)

	_cCampProd := ""
	_cProd     := SC7->C7_PRODUTO

	_cCampDPro := ""
	_cDPro     := SC7->C7_DESCRI

	_dCampDEnt := ""
	_dDEnt     := SC7->C7_DATPRF

	_aComboDEn := {"Somente este item","Todos os itens"}
	_cModoDEn  := ""

	_cItemSC   := SC7->C7_ITEMSC
	_cSC       := SC7->C7_NUMSC
	_cTipo     := SC7->C7_TIPO
	_cGrupo    := SC7->C7_GRUPO

	_aComboFr  := {" ","C-CIF","F-FOB","T-Por Conta Terceiros","R-Por Conta Remetente","D-Por Conta Destinatแrio","S-Sem Frete"}
	_cTpFrete  := CmbTpFrete(SC7->C7_TPFRETE)

	_lCancela := .T.
	@ 000, 000 To 300, 450 DIALOG oDlg2 TITLE "Ajustes no Pedido de Compra"
	@ 005, 005 SAY "Fornecedor"
	@ 020, 005 SAY "Loja"
	@ 035, 005 SAY "Nome Forn."
	@ 050, 005 SAY "Cond.Pgto."
	@ 065, 005 SAY "Desc.Pgto."
	@ 080, 005 SAY "Produto"
	@ 095, 005 SAY "Desc.Prod."
	@ 110, 005 SAY "Dt. Entrega"
	@ 110, 108 SAY "==>"
	@ 125, 005 SAY "Tp. Frete"

	@ 005, 050 MSGET _cCampForn  VAR _cForn     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!"  F3 'SA2A'
	@ 020, 050 MSGET _cCampLoja  VAR _cLoja     SIZE 010,10 OF oDlg2 PIXEL PICTURE "@!"
	@ 035, 050 MSGET _cCampDForn VAR _cDescForn SIZE 155,10 OF oDlg2 PIXEL PICTURE "@!"
	@ 050, 050 MSGET _cCampCPag  VAR _cCPag     SIZE 015,10 OF oDlg2 PIXEL PICTURE "@!"  F3 'SE4'
	@ 065, 050 MSGET _cCampDCond VAR _cDescCond SIZE 100,10 OF oDlg2 PIXEL PICTURE "@!"
	@ 080, 050 MSGET _cCampProd  VAR _cProd     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!"  F3 'SB1'
	@ 095, 050 MSGET _cCampDPro  VAR _cDPro     SIZE 155,10 OF oDlg2 PIXEL PICTURE "@!"
	@ 110, 050 MSGET _dCampDEnt  VAR _dDEnt     SIZE 050,10 OF oDlg2 PIXEL
	@ 110, 120 MSCOMBOBOX oCmbBox1 VAR _cModoDEn ITEMS _aComboDEn SIZE 075,10 OF oDlg2 PIXEL
	@ 125, 050 MSCOMBOBOX oCmbBox2 VAR _cTpFrete ITEMS _aComboFr SIZE 075,10 OF oDlg2 PIXEL

	@ 140, 025 BMPBUTTON TYPE 1 ACTION (_lCancela := .F., Close(oDlg2))
	@ 140, 055 BMPBUTTON TYPE 2 ACTION (_lCancela := .T., Close(oDlg2))

	_cCampDForn:disable()
	_cCampDCond:disable()
	_cCampLoja:bLostFocus := {|| EscrForn() }
	_cCampCPag:bLostFocus := {|| EscrCp() }
	_cCampProd:bLostFocus := {|| EscrProd() }

	ACTIVATE DIALOG oDlg2 CENTERED

	If !_lCancela
		reclock('SC7',.f.)
		SC7->C7_PRODUTO := _cProd
		SC7->C7_DESCRI  := _cDPro
		SC7->C7_GRUPO   := _cGrupo
		if _cModoDEn = _aComboDEn[1]
			SC7->C7_DATPRF  := _dDEnt
		endif
		msunlock()

		_cQuery := "UPDATE " + RetSqlName('SC7')
		_cQuery += " SET C7_FORNECE  = '" + _cForn + "',"
		_cQuery +=     " C7_LOJA     = '" + _cLoja + "',"
		_cQuery +=     " C7_COND     = '" + _cCPag + "',"
		if _cModoDEn = _aComboDEn[2]
			_cQuery +=     " C7_DATPRF     = '" + dtos(_dDEnt) + "',"
		endif
		_cQuery +=     " C7_TPFRETE  = '" + RetTpFrete(_cTpFrete) + "'"
		_cQuery += " WHERE D_E_L_E_T_ <> '*'"
		_cQuery += " AND C7_NUM = '" + SC7->C7_NUM + "'"
		_cQuery += " AND C7_FILIAL = '" + FWxFilial('SC7') + "'"
		TcSqlExec(_cQuery)

		SC1->(DbSetOrder(6))
		if SC1->(MsSeek(FWxfilial('SC1')+SC7->(C7_NUM+C7_ITEM+C7_PRODUTO)))
			reclock('SC1',.f.)
			SC1->C1_PRODUTO := _cProd 
			SC1->C1_DESCRI  := _cDPro
			msunlock()
		endif

		_cQuery2 := "UPDATE " + RetSqlName('SC1')
		_cQuery2 += " SET C1_FORNECE  = '" + _cForn + "',"
		_cQuery2 +=     " C1_LOJA     = '" + _cLoja + "'"
		_cQuery2 += " WHERE D_E_L_E_T_ <> '*'"
		_cQuery2 += " AND C1_PEDIDO  = '" + SC7->C7_NUM + "'"
		_cQuery2 += " AND C1_FILIAL  = '" + FWxFilial('SC1') + "'"
		TcSqlExec(_cQuery2)
	EndIf

Return

Static Function RetTpFrete(cFrete)

	Local cRet := ""

	cFrete := allTrim(cFrete)

	If cFrete == "C-CIF"
		cRet := "C"
	ElseIf cFrete == "F-FOB"
		cRet := "F"
	ElseIf cFrete == "T-Por Conta Terceiros"
		cRet := "T"
	ElseIf cFrete == "R-Por Conta Remetente"
		cRet := "R"
	ElseIf cFrete == "D-Por Conta Destinatแrio"
		cRet := "D"
	ElseIf cFrete == "S-Sem Frete"
		cRet := "S"
	Else
		cRet := ""
	EndIf

Return cRet

Static Function CmbTpFrete(cFrete)

	Local cRet := ""

	cFrete := allTrim(cFrete)

	If cFrete == "C"
		cRet := "C-CIF"
	ElseIf cFrete=="F"
		cRet := "F-FOB"
	ElseIf cFrete=="T"
		cRet := "T-Por Conta Terceiros"
	ElseIf cFrete=="R"
		cRet := "R-Por Conta Remetente"
	ElseIf cFrete=="D"
		cRet := "D-Por Conta Destinatแrio"
	ElseIf cFrete=="S"
		cRet := "S-Sem Frete"
	Else
		cRet := ""
	EndIf

Return cRet


User Function GJFRC()

	if SC7->C7_RESIDUO = 'S'
		alert('Resํduio eliminado!')
		return
	endif

	if SC7->C7_CONAPRO <> 'L'
		alert('Pedido de Compra deve jแ estar liberado!')
		return
	endif

	_aComboDEn := {"Somente este item","Todos os itens"}
	_cModoDEn  := ""

	_dCampDEnt := ""
	_dDEnt     := SC7->C7_DATPRF

	_cCampForn := ""
	_cForn     := SC7->C7_FORNECE

	_cCampLoja := ""
	_cLoja     := SC7->C7_LOJA

	_cCampDForn:= ""
	_cDescForn := GetAdvFVal('SA2','A2_NOME',FWxfilial('SA2') + _cForn + _cLoja,1)

	_lCancela := .T.
	@ 000, 000 To 300, 450 DIALOG oDlg2 TITLE "Ajustes no Pedido de Compra"
	if AllTrim(UPPER(cUserName)) = 'PATRICIA.PETTERINI'
		@ 005, 005 SAY "Fornecedor"
		@ 020, 005 SAY "Loja"
		@ 035, 005 SAY "Nome Forn."
		@ 050, 005 SAY "Dt. Entrega"
		@ 050, 108 SAY "==>"

		@ 005, 050 MSGET _cCampForn  VAR _cForn     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!"  F3 'SA2A'
		@ 020, 050 MSGET _cCampLoja  VAR _cLoja     SIZE 010,10 OF oDlg2 PIXEL PICTURE "@!"
		@ 035, 050 MSGET _cCampDForn VAR _cDescForn SIZE 155,10 OF oDlg2 PIXEL PICTURE "@!"
		@ 050, 050 MSGET _dCampDEnt  VAR _dDEnt     SIZE 050,10 OF oDlg2 PIXEL
		@ 050, 120 MSCOMBOBOX oCmbBox1 VAR _cModoDEn ITEMS _aComboDEn SIZE 075,10 OF oDlg2 PIXEL

		@ 135, 025 BMPBUTTON TYPE 1 ACTION (_lCancela := .F., Close(oDlg2))
		@ 135, 055 BMPBUTTON TYPE 2 ACTION (_lCancela := .T., Close(oDlg2))

		_cCampDForn:disable()
		_cCampLoja:bLostFocus := {|| EscrForn() }
	else
		@ 005, 005 SAY "Fornecedor"
		@ 020, 005 SAY "Loja"
		@ 035, 005 SAY "Nome Forn."

		@ 005, 050 MSGET _cCampForn  VAR _cForn     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!"  F3 'SA2A'
		@ 020, 050 MSGET _cCampLoja  VAR _cLoja     SIZE 010,10 OF oDlg2 PIXEL PICTURE "@!"
		@ 035, 050 MSGET _cCampDForn VAR _cDescForn SIZE 155,10 OF oDlg2 PIXEL PICTURE "@!"

		@ 135, 025 BMPBUTTON TYPE 1 ACTION (_lCancela := .F., Close(oDlg2))
		@ 135, 055 BMPBUTTON TYPE 2 ACTION (_lCancela := .T., Close(oDlg2))

		_cCampDForn:disable()
		_cCampLoja:bLostFocus := {|| EscrForn() }
	endif

	ACTIVATE DIALOG oDlg2 CENTERED

	If !_lCancela

		if AllTrim(UPPER(cUserName)) = 'PATRICIA.PETTERINI'
			if _cModoDEn = _aComboDEn[1]
				reclock('SC7',.f.)
					SC7->C7_DATPRF  := _dDEnt
					SC7->C7_FORNECE := _cForn
					SC7->C7_LOJA    := _cLoja
				msunlock()
			elseif _cModoDEn = _aComboDEn[2]
				_cQuery := "UPDATE " + RetSqlName('SC7')
				_cQuery += " SET C7_DATPRF = '" + dtos(_dDEnt) + "',"
				_cQuery += " C7_FORNECE  = '" + _cForn + "',"
				_cQuery += " C7_LOJA     = '" + _cLoja + "'"
				_cQuery += " WHERE D_E_L_E_T_ <> '*'"
				_cQuery += " AND C7_NUM = '" + SC7->C7_NUM + "'"
				_cQuery += " AND C7_FILIAL = '" + FWxFilial('SC7') + "'"
				TcSqlExec(_cQuery)

				_cQuery2 := "UPDATE " + RetSqlName('SC1')
				_cQuery2 += " SET C1_FORNECE  = '" + _cForn + "',"
				_cQuery2 += " C1_LOJA     = '" + _cLoja + "'"
				_cQuery2 += " WHERE D_E_L_E_T_ <> '*'"
				_cQuery2 += " AND C1_PEDIDO  = '" + SC7->C7_NUM + "'"
				_cQuery2 += " AND C1_FILIAL  = '" + FWxFilial('SC1') + "'"
				TcSqlExec(_cQuery2)
			endif
		else
			_cQuery := "UPDATE " + RetSqlName('SC7')
			_cQuery += " SET C7_FORNECE  = '" + _cForn + "',"
			_cQuery +=     " C7_LOJA     = '" + _cLoja + "'"
			_cQuery += " WHERE D_E_L_E_T_ <> '*'"
			_cQuery += " AND C7_NUM = '" + SC7->C7_NUM + "'"
			_cQuery += " AND C7_FILIAL = '" + FWxFilial('SC7') + "'"
			TcSqlExec(_cQuery)

			_cQuery2 := "UPDATE " + RetSqlName('SC1')
			_cQuery2 += " SET C1_FORNECE  = '" + _cForn + "',"
			_cQuery2 +=     " C1_LOJA     = '" + _cLoja + "'"
			_cQuery2 += " WHERE D_E_L_E_T_ <> '*'"
			_cQuery2 += " AND C1_PEDIDO  = '" + SC7->C7_NUM + "'"
			_cQuery2 += " AND C1_FILIAL  = '" + FWxFilial('SC1') + "'"
			TcSqlExec(_cQuery2)
		endif
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ GFJAX    บ Autor ณ                    บ Data ณ             บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Informa็ใo de Ajustes do Pedido de Compras ref. XML        บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
User Function GJFAX()   
	Private oOperac
	Private cOperac := "I"

	If SC7->C7_RESIDUO = 'S'
		alert('Resํduio eliminado!')
		Return
	Endif

	//If SC7->C7_CONAPRO <> 'L'
	//	alert('Pedido de Compra deve jแ estar liberado!')
	//	return
	//Endif

	_cCampProd := ""
	_cProd     := SC7->C7_PRODUTO

	_cCampDPro := ""
	_cDPro     := SC7->C7_DESCRI 

	_nCampTQtS := 0 
	_nTQtS     := SC7->C7_QUANT

	_nCampTQtD := 0 
	_nTQtD     := 0

	// GUARDA CONTEฺDOS DO ITEM POSICIONADO PARA POSTERIORMENTE UTILIZAR NO PROCESSO DE INSERIR OU DELETAR PRODUTOS
	_Filial    := SC7->C7_FILIAL
	_Tipo      := SC7->C7_TIPO
	_Item      := SC7->C7_ITEM
	_Grupo     := SC7->C7_GRUPO
	_Produto   := SC7->C7_PRODUTO
	_Descri    := SC7->C7_DESCRI
	_Um        := SC7->C7_UM
	_Segum     := SC7->C7_SEGUM
	_Quant     := SC7->C7_QUANT
	_Qtsegum   := SC7->C7_QTSEGUM
	_Preco     := SC7->C7_PRECO
	_Total     := SC7->C7_TOTAL
	_TES       := SC7->C7_TES
	_Datprf    := SC7->C7_DATPRF
	_Tpcom     := SC7->C7_TPCOM
	_Comp      := SC7->C7_COMPR
	_CC        := SC7->C7_CC
	_Cond      := SC7->C7_COND
	_Contato   := SC7->C7_CONTATO
	_Ipi       := SC7->C7_IPI
	_Numsc     := SC7->C7_NUMSC
	_Emissao   := SC7->C7_EMISSAO
	_Num       := SC7->C7_NUM
	_Itemsc    := SC7->C7_ITEMSC
	_Local     := SC7->C7_LOCAL
	_Obs       := SC7->C7_OBS
	_Fornece   := SC7->C7_FORNECE
	_Loja      := SC7->C7_LOJA
	_Filent    := SC7->C7_FILENT
	_Desc1     := SC7->C7_DESC1
	_Desc2     := SC7->C7_DESC2
	_Desc3     := SC7->C7_DESC3
	_Quje      := SC7->C7_QUJE
	_Emitido   := SC7->C7_EMITIDO
	_Tpfrete   := SC7->C7_TPFRETE
	_Qtdreem   := SC7->C7_QTDREEM
	_Numcot    := SC7->C7_NUMCOT
	_Ipibrut   := SC7->C7_IPIBRUT
	_Vldesc    := SC7->C7_VLDESC
	_Fluxo     := SC7->C7_FLUXO
	_Aprov     := SC7->C7_APROV
	_Conapro   := SC7->C7_CONAPRO
	_Grupcom   := SC7->C7_GRUPCOM
	_User      := SC7->C7_USER
	_Qtdsol    := SC7->C7_QTDSOL
	_Txmoeda   := SC7->C7_TXMOEDA
	_Valipi    := SC7->C7_VALIPI
	_Valicm    := SC7->C7_VALICM
	_Picm      := SC7->C7_PICM
	_Baseicm   := SC7->C7_BASEICM
	_Baseipi   := SC7->C7_BASEIPI
	_Valfre    := SC7->C7_VALFRE
	_Moeda     := SC7->C7_MOEDA
	_Icmsret   := SC7->C7_ICMSRET
	_Basesol   := SC7->C7_BASESOL
	_Valsol    := SC7->C7_VALSOL
	_Grade	   := SC7->C7_GRADE
	_Rateio    := SC7->C7_RATEIO
	_Dinicq    := SC7->C7_DINICQ
	_Dinitra   := SC7->C7_DINITRA
	_Dinicom   := SC7->C7_DINICOM
	_Fiscori   := SC7->C7_FISCORI

	_lConf := .T.
	@ 000, 000 To 300, 450 DIALOG oDlg2 TITLE "Ajustes no Pedido de Compra XML"
	@ 005, 005 SAY "Produto" 
	@ 020, 005 SAY "Desc. Produto" 
	@ 035, 005 SAY "Qtde Saldo" 
	@ 050, 005 SAY "Opera็ใo"
	@ 065, 005 SAY "Qtde a Distribuir" 

	@ 005, 050 MSGET _cCampProd  	VAR _cProd     									SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!"  F3 'SB1'
	@ 020, 050 MSGET _cCampDPro  	VAR _cDPro     									SIZE 155,10 OF oDlg2 PIXEL PICTURE "@!"  
	@ 035, 050 MSGET _nCampTQtS  	VAR _nTQtS     									SIZE 080,10 OF oDlg2 PIXEL PICTURE "@E 9,999,999.9999999"  
	@ 050, 050 MSCOMBOBOX oOperac 	VAR cOperac ITEMS {"I=Inserir", "D=Deletar"}  	SIZE 050,10 OF oDlg2 PIXEL When .T.
	@ 065, 050 MSGET _nCampTQtD  	VAR _nTQtD     									SIZE 080,10 OF oDlg2 PIXEL PICTURE "@E 9,999,999.9999999"  

	@ 135, 025 BMPBUTTON TYPE 1 ACTION (_lConf := _VldQtde() )
	@ 135, 055 BMPBUTTON TYPE 2 ACTION (_lConf := .T., Close(oDlg2))

	_cCampProd:disable()   
	_cCampDPro:disable()
	_nCampTQtS:disable()   

	ACTIVATE DIALOG oDlg2 CENTERED

	If _lConf       
		If _nTQtD > _nTQtS .And. (cOperac == 'I' .Or. _nTQtD <= 0)
			MsgAlert("Qtde a Distribuir Informada nใo Permitida. Verifique!")
		Else
			If cOperac == 'I'
				If _nTQtD == 0
					MsgAlert("Nใo ้ permitido Inserir linhas com Qtde a Distribuir igual a 0 (zero).")
				Else
					// Somente deixar inserir se qtde saldo for maior que 1
					If _nTQtS > 1	
						// Atualiza Qtde do item posicionado
						DbSelectArea("SC7")
						Reclock("SC7", .F.)
						SC7->C7_QUANT := SC7->C7_QUANT - _nTQtD
						SC7->C7_TOTAL := SC7->C7_QUANT * SC7->C7_PRECO
						MsUnlock()
	
						// Busca maior numero de pedido e soma 1
						_ProxNum := Val(_UltNUM(_Num)) + 1 
						_ProxIte := StrZero(_ProxNum,4,0)
						
						DbSelectArea("SC7")
						Reclock("SC7", .T.)
						SC7->C7_FILIAL  := _Filial
						SC7->C7_TIPO    := _Tipo
						SC7->C7_ITEM    := _ProxIte
						SC7->C7_GRUPO   := _Grupo
						SC7->C7_PRODUTO := _Produto
						SC7->C7_DESCRI  := _Descri
						SC7->C7_UM		:= _Um
						SC7->C7_QUANT   := _nTQtD
						SC7->C7_PRECO	:= _Preco
						SC7->C7_TOTAL	:= _nTQtD * _Preco 
						SC7->C7_TES		:= _TES
						SC7->C7_DATPRF	:= _Datprf 
						SC7->C7_TPCOM	:= _Tpcom
						SC7->C7_COMPR	:= _Comp
						SC7->C7_CC		:= _CC
						SC7->C7_COND	:= _Cond
						SC7->C7_CONTATO	:= _Contato
						SC7->C7_IPI		:= _Ipi 
						SC7->C7_NUMSC   := _Numsc
						SC7->C7_EMISSAO	:= _Emissao
						SC7->C7_NUM		:= _Num
						SC7->C7_ITEMSC	:= _Itemsc
						SC7->C7_LOCAL	:= _Local
						SC7->C7_OBS		:= _Obs
						SC7->C7_FORNECE	:= _Fornece
						SC7->C7_LOJA	:= _Loja 
						SC7->C7_FILENT	:= _Filent
						SC7->C7_DESC1	:= _Desc1
						SC7->C7_DESC2	:= _Desc2
						SC7->C7_DESC3	:= _Desc3
						SC7->C7_QUJE	:= _Quje 
						SC7->C7_EMITIDO := _Emitido 
						SC7->C7_TPFRETE := _Tpfrete
						SC7->C7_QTDREEM	:= _Qtdreem
						SC7->C7_NUMCOT	:= _Numcot
						SC7->C7_IPIBRUT := _Ipibrut
						SC7->C7_VLDESC  := _Vldesc
						SC7->C7_FLUXO	:= _Fluxo
						SC7->C7_APROV	:= _Aprov
						SC7->C7_CONAPRO	:= _Conapro
						SC7->C7_GRUPCOM	:= _Grupcom
						SC7->C7_USER	:= _User
						SC7->C7_QTDSOL	:= _Qtdsol
						SC7->C7_TXMOEDA	:= _Txmoeda
						SC7->C7_VALIPI	:= _Valipi
						SC7->C7_VALICM	:= _Valicm
						SC7->C7_PICM	:= _Picm
						SC7->C7_BASEICM	:= _Baseicm
						SC7->C7_BASEIPI	:= _Baseipi
						SC7->C7_VALFRE	:= _Valfre
						SC7->C7_MOEDA	:= _Moeda
						SC7->C7_ICMSRET	:= _Icmsret
						SC7->C7_BASESOL	:= _Basesol
						SC7->C7_VALSOL	:= _Valsol
						SC7->C7_GRADE	:= _Grade
						SC7->C7_RATEIO	:= _Rateio
						SC7->C7_DINICQ	:= _Dinicq
						SC7->C7_DINITRA := _Dinitra
						SC7->C7_DINICOM	:= _Dinicom
						SC7->C7_FISCORI	:= _Fiscori
						MsUnlock()
						
						//MsgAlert("pr๓ximo item ้ " + _ProxIte + chr(13) + ;
						//         "serแ incluํdo uma nova linha com " + Str(_nTQtD) + chr(13) + ;
						//         "saldo atual do item ficarแ em " + Str((_nTQtS - _nTQtD)) )
					Else
						MsgAlert("Nใo ้ permitido inserir linhas, pois a qtde saldo do item posicionado deve ser maior que 1.")
					Endif
				Endif
			Else
				// Somente deixar deletar se existir outro item igual
				cQuery := " SELECT COUNT(C7_PRODUTO) AS QTDPROD "
				cQuery += "   FROM " + RetSqlTab("SC7")
				cQuery += "  WHERE " + RetSqlFil("SC7")
				cQuery += "    AND C7_PRODUTO = '" + _Produto + "'"
				cQuery += "    AND C7_NUM = '" + _Num + "'"
				cQuery += "    AND " + RetSqlDel("SC7")
	
				cQuery := ChangeQuery(cQuery)
	
				If Select("TRB1") != 0
					TRB1 -> (DbCloseArea())
				Endif
	
				TCQUERY cQuery NEW ALIAS "TRB1"
	
				_nQtdProd := 0
				DbSelectArea("TRB1")
				DbGoTop()
				Do While ! TRB1 -> (Eof ())
					_nQtdProd := TRB1->QTDPROD
					TRB1->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 
				EndDo
	
				TRB1 -> (DbCloseArea())

				If _nQtdProd > 1
					// DELETA REGISTRO POSICIONADO NO ITEM DO PEDIDO DE COMPRA
					cQuery := " UPDATE " + RetSqlName("SC7") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
					cQuery += "  WHERE C7_FILIAL = '" + FWxFilial("SC7") + "' "
					cQuery += "   AND C7_NUM = '" + _Num + "' "
					cQuery += "   AND C7_ITEM = '" + _Item + "' "
					cQuery += "   AND C7_PRODUTO = '" + _Produto + "' "
					cQuery += "   AND C7_FORNECE = '" + _Fornece + "' "
					cQuery += "   AND C7_LOJA = '" + _Loja + "' "
					cQuery += "   AND D_E_L_E_T_ = ' ' "
					TCSqlExec( cQuery ) 
					
					//MsgAlert("serแ deletado a linha atual no item/produto " + SC7->C7_ITEM + "/" + AllTrim(SC7->C7_PRODUTO) + " de qtde " + Str(_nTQtS))
	
					DbSelectArea("SC7")
					DbSetOrder(4)
					DbGoTop()
					MsSeek(FWxFilial("SC7") + _Produto + _Num)
					If Found()
						DbSelectArea("SC7")
						Reclock("SC7", .F.)
						SC7->C7_QUANT   := SC7->C7_QUANT + _nTQtS
						SC7->C7_TOTAL   := SC7->C7_QUANT * SC7->C7_PRECO			// SC7->C7_TOTAL + _Total
						SC7->C7_QUJE    := SC7->C7_QUJE + _Quje
						SC7->C7_VLDESC  := SC7->C7_VLDESC + _Vldesc
						SC7->C7_BASEICM := SC7->C7_TOTAL							// SC7->C7_BASEICM + _Baseicm
						SC7->C7_VALICM  := (SC7->C7_BASEICM * SC7->C7_PICM) / 100	// SC7->C7_VALICM + _Valicm
						SC7->C7_BASEIPI := SC7->C7_TOTAL							// SC7->C7_BASEIPI + _Baseipi
						SC7->C7_VALIPI  := (SC7->C7_BASEIPI * SC7->C7_IPI) / 100	// SC7->C7_VALIPI + _Valipi
						SC7->C7_VALFRE  := SC7->C7_VALFRE + _Valfre
						SC7->C7_QTDSOL  := SC7->C7_QTDSOL + _Qtdsol
						SC7->C7_BASESOL := SC7->C7_BASESOL + _Basesol
						SC7->C7_VALSOL  := SC7->C7_VALSOL + _Valsol
						SC7->C7_ICMSRET := SC7->C7_ICMSRET + _Icmsret
						SC7->C7_ORIGEM  := "AJUPCXML"
						SC7->C7_ENCER   := " " 
						MsUnlock()
						//MsgAlert("serแ somado no item/produto " + SC7->C7_ITEM + "/" + AllTrim(SC7->C7_PRODUTO) + " a qtde " + Str(_nTQtS))
					Else
						MsgAlert("Nใo encontrou " + FWxFilial("SC7") + _Produto + _Num + ". Verificar com DTI. Fonte MT120BROW")
					Endif
					
				Else
					MsgAlert("Nใo ้ permitido deletar esta linha, pois nใo existe outra linha com o mesmo produto para poder distribuir quantidades.")
				Endif
			Endif
		Endif
	EndIf                               

Return


Static Function _VldQtde()
	Local _lRet := .T.

	If _nTQtD == _nTQtS 
		Aviso("ATENวรO" ,"Qtde a Distribuir nใo pode ser igual a Qtde Saldo" + Chr(13) + Chr(10) + "Favor Alterar Qtde a Distribuir", { "Fechar" }, 2, )
		_lRet := .F.
	Else
		Close(oDlg2)
	Endif
	
Return(_lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ GFJRT    บ Autor ณ                    บ Data ณ             บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Informa็ใo de Rateio do Item Posicionado                   บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
User Function GJFRT()   
	If SC7->C7_RESIDUO = 'S'
		alert('Resํduio eliminado!')
		Return
	Endif

	If SC7->C7_CONAPRO <> 'L'
		alert('Pedido de Compra deve jแ estar liberado!')
		return
	Endif

	_cCampForn := ""
	_cForn     := SC7->C7_FORNECE   

	_cCampLoja := ""
	_cLoja     := SC7->C7_LOJA

	_cCampDForn:= ""
	_cDescForn := GetAdvFVal('SA2','A2_NOME',FWxfilial('SA2') + _cForn + _cLoja,1) 

	_cCampProd := ""
	_cProd     := SC7->C7_PRODUTO

	_cCampDPro := ""
	_cDPro     := SC7->C7_DESCRI 

	_cCampItem := ""
	_cItem     := SC7->C7_ITEM

	_nCampP01  := 0 
	_nPerc01   := 0
	_nCampP02  := 0 
	_nPerc02   := 0
	_nCampP03  := 0 
	_nPerc03   := 0
	_nCampP04  := 0 
	_nPerc04   := 0
	_nCampP05  := 0 
	_nPerc05   := 0
	_nCampP06  := 0 
	_nPerc06   := 0
	_nCampP07  := 0 
	_nPerc07   := 0
	_nCampP08  := 0 
	_nPerc08   := 0
	_nCampP09  := 0 
	_nPerc09   := 0
	_nCampP10  := 0 
	_nPerc10   := 0
	_nCampP11  := 0 
	_nPerc11   := 0
	_nCampP12  := 0 
	_nPerc12   := 0
	_nCampP13  := 0 
	_nPerc13   := 0
	_nCampP14  := 0 
	_nPerc14   := 0
	_nCampP15  := 0 
	_nPerc15   := 0
	_nCampP16  := 0 
	_nPerc16   := 0
	_nCampP17  := 0 
	_nPerc17   := 0
	_nCampP18  := 0 
	_nPerc18   := 0
	_nCampP19  := 0 
	_nPerc19   := 0
	_nCampP20  := 0 
	_nPerc20   := 0
	_nCampP21  := 0 
	_nPerc21   := 0
	_nCampP22  := 0 
	_nPerc22   := 0
	_nCampP23  := 0 
	_nPerc23   := 0
	_nCampP24  := 0 
	_nPerc24   := 0
	_nCampP25  := 0 
	_nPerc25   := 0
	_nCampP26  := 0 
	_nPerc26   := 0
	_nCampP27  := 0 
	_nPerc27   := 0
	_nCampP28  := 0 
	_nPerc28   := 0
	_nCampP29  := 0 
	_nPerc29   := 0
	_nCampP30  := 0 
	_nPerc30   := 0
	_nCampP31  := 0 
	_nPerc31   := 0
	_nCampP32  := 0 
	_nPerc32   := 0
	_nCampP33  := 0 
	_nPerc33   := 0

	_cCampCC01 := CriaVar("C7_CC") 
	_cCC01     := CriaVar("C7_CC")
	_cCampCC02 := CriaVar("C7_CC") 
	_cCC02     := CriaVar("C7_CC")
	_cCampCC03 := CriaVar("C7_CC") 
	_cCC03     := CriaVar("C7_CC")
	_cCampCC04 := CriaVar("C7_CC") 
	_cCC04     := CriaVar("C7_CC")
	_cCampCC05 := CriaVar("C7_CC") 
	_cCC05     := CriaVar("C7_CC")
	_cCampCC06 := CriaVar("C7_CC") 
	_cCC06     := CriaVar("C7_CC")
	_cCampCC07 := CriaVar("C7_CC") 
	_cCC07     := CriaVar("C7_CC")
	_cCampCC08 := CriaVar("C7_CC") 
	_cCC08     := CriaVar("C7_CC")
	_cCampCC09 := CriaVar("C7_CC") 
	_cCC09     := CriaVar("C7_CC")
	_cCampCC10 := CriaVar("C7_CC") 
	_cCC10     := CriaVar("C7_CC")
	_cCampCC11 := CriaVar("C7_CC") 
	_cCC11     := CriaVar("C7_CC")
	_cCampCC12 := CriaVar("C7_CC") 
	_cCC12     := CriaVar("C7_CC")
	_cCampCC13 := CriaVar("C7_CC") 
	_cCC13     := CriaVar("C7_CC")
	_cCampCC14 := CriaVar("C7_CC") 
	_cCC14     := CriaVar("C7_CC")
	_cCampCC15 := CriaVar("C7_CC") 
	_cCC15     := CriaVar("C7_CC")
	_cCampCC16 := CriaVar("C7_CC") 
	_cCC16     := CriaVar("C7_CC")
	_cCampCC17 := CriaVar("C7_CC") 
	_cCC17     := CriaVar("C7_CC")
	_cCampCC18 := CriaVar("C7_CC") 
	_cCC18     := CriaVar("C7_CC")
	_cCampCC19 := CriaVar("C7_CC") 
	_cCC19     := CriaVar("C7_CC")
	_cCampCC20 := CriaVar("C7_CC") 
	_cCC20     := CriaVar("C7_CC")
	_cCampCC21 := CriaVar("C7_CC") 
	_cCC21     := CriaVar("C7_CC")
	_cCampCC22 := CriaVar("C7_CC") 
	_cCC22     := CriaVar("C7_CC")
	_cCampCC23 := CriaVar("C7_CC") 
	_cCC23     := CriaVar("C7_CC")
	_cCampCC24 := CriaVar("C7_CC") 
	_cCC24     := CriaVar("C7_CC")
	_cCampCC25 := CriaVar("C7_CC") 
	_cCC25     := CriaVar("C7_CC")
	_cCampCC26 := CriaVar("C7_CC") 
	_cCC26     := CriaVar("C7_CC")
	_cCampCC27 := CriaVar("C7_CC") 
	_cCC27     := CriaVar("C7_CC")
	_cCampCC28 := CriaVar("C7_CC") 
	_cCC28     := CriaVar("C7_CC")
	_cCampCC29 := CriaVar("C7_CC") 
	_cCC29     := CriaVar("C7_CC")
	_cCampCC30 := CriaVar("C7_CC") 
	_cCC30     := CriaVar("C7_CC")
	_cCampCC31 := CriaVar("C7_CC") 
	_cCC31     := CriaVar("C7_CC")
	_cCampCC32 := CriaVar("C7_CC") 
	_cCC32     := CriaVar("C7_CC")
	_cCampCC33 := CriaVar("C7_CC") 
	_cCC33     := CriaVar("C7_CC")

	DbSelectArea("SCH")
	DbSetOrder(1)
	MsSeek(FWxFilial("SCH") + SC7->C7_NUM + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_ITEM)	// CH_FILIAL+CH_PEDIDO+CH_FORNECE+CH_LOJA+CH_ITEMPD
	If Found()
		While !Eof() .And. SCH->CH_FILIAL + SCH->CH_PEDIDO + SCH->CH_FORNECE + SCH->CH_LOJA + SCH->CH_ITEMPD == FWxFilial("SCH") + SC7->C7_NUM + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_ITEM 
			If SCH->CH_ITEM == "01"
				_nPerc01 := SCH->CH_PERC
				_cCC01	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "02"
				_nPerc02 := SCH->CH_PERC
				_cCC02	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "03"
				_nPerc03 := SCH->CH_PERC
				_cCC03	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "04"
				_nPerc04 := SCH->CH_PERC
				_cCC04	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "05"
				_nPerc05 := SCH->CH_PERC
				_cCC05	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "06"
				_nPerc06 := SCH->CH_PERC
				_cCC06	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "07"
				_nPerc07 := SCH->CH_PERC
				_cCC07	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "08"
				_nPerc08 := SCH->CH_PERC
				_cCC08	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "09"
				_nPerc09 := SCH->CH_PERC
				_cCC09	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "10"
				_nPerc10 := SCH->CH_PERC
				_cCC10	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "11"
				_nPerc11 := SCH->CH_PERC
				_cCC11	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "12"
				_nPerc12 := SCH->CH_PERC
				_cCC12	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "13"
				_nPerc13 := SCH->CH_PERC
				_cCC13	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "14"
				_nPerc14 := SCH->CH_PERC
				_cCC14	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "15"
				_nPerc15 := SCH->CH_PERC
				_cCC15	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "16"
				_nPerc16 := SCH->CH_PERC
				_cCC16	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "17"
				_nPerc17 := SCH->CH_PERC
				_cCC17	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "18"
				_nPerc18 := SCH->CH_PERC
				_cCC18	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "19"
				_nPerc19 := SCH->CH_PERC
				_cCC19	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "20"
				_nPerc20 := SCH->CH_PERC
				_cCC20	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "21"
				_nPerc21 := SCH->CH_PERC
				_cCC21	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "22"
				_nPerc22 := SCH->CH_PERC
				_cCC22	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "23"
				_nPerc23 := SCH->CH_PERC
				_cCC23	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "24"
				_nPerc24 := SCH->CH_PERC
				_cCC24	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "25"
				_nPerc25 := SCH->CH_PERC
				_cCC25	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "26"
				_nPerc26 := SCH->CH_PERC
				_cCC26	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "27"
				_nPerc27 := SCH->CH_PERC
				_cCC27	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "28"
				_nPerc28 := SCH->CH_PERC
				_cCC28	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "29"
				_nPerc29 := SCH->CH_PERC
				_cCC29	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "30"
				_nPerc30 := SCH->CH_PERC
				_cCC30	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "31"
				_nPerc31 := SCH->CH_PERC
				_cCC31	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "32"
				_nPerc32 := SCH->CH_PERC
				_cCC32	 := SCH->CH_CC
			Endif
			If SCH->CH_ITEM == "33"
				_nPerc33 := SCH->CH_PERC
				_cCC33	 := SCH->CH_CC
			Endif
			DbSelectArea("SCH")
			DbSkip()
		EndDo
	Endif

	_lConfirma := .F.
	@ 000, 000 To 550, 1220 DIALOG oDlg2 TITLE "Rateio do Item Pedido de Compra"
	@ 005, 005 SAY "Fornecedor" 
	@ 020, 005 SAY "Loja" 
	@ 035, 005 SAY "Nome Fornecedor" 
	@ 050, 005 SAY "Produto" 
	@ 050, 100 SAY "Item" 
	@ 065, 005 SAY "Desc. Produto"
	@ 095, 005 SAY "% Rateio"
	@ 095, 205 SAY "% Rateio"
	@ 095, 405 SAY "% Rateio"
	@ 110, 005 SAY "% Rateio"
	@ 110, 205 SAY "% Rateio"
	@ 110, 405 SAY "% Rateio"
	@ 125, 005 SAY "% Rateio"
	@ 125, 205 SAY "% Rateio"
	@ 125, 405 SAY "% Rateio"
	@ 140, 005 SAY "% Rateio"
	@ 140, 205 SAY "% Rateio"
	@ 140, 405 SAY "% Rateio"
	@ 155, 005 SAY "% Rateio"
	@ 155, 205 SAY "% Rateio"
	@ 155, 405 SAY "% Rateio"
	@ 170, 005 SAY "% Rateio"
	@ 170, 205 SAY "% Rateio"
	@ 170, 405 SAY "% Rateio"
	@ 185, 005 SAY "% Rateio"
	@ 185, 205 SAY "% Rateio"
	@ 185, 405 SAY "% Rateio"
	@ 200, 005 SAY "% Rateio"
	@ 200, 205 SAY "% Rateio"
	@ 200, 405 SAY "% Rateio"
	@ 215, 005 SAY "% Rateio"
	@ 215, 205 SAY "% Rateio"
	@ 215, 405 SAY "% Rateio"
	@ 230, 005 SAY "% Rateio"
	@ 230, 205 SAY "% Rateio"
	@ 230, 405 SAY "% Rateio"
	@ 245, 005 SAY "% Rateio"
	@ 245, 205 SAY "% Rateio"
	@ 245, 405 SAY "% Rateio"
	@ 095, 100 SAY "Centro Custo"
	@ 095, 300 SAY "Centro Custo"
	@ 095, 500 SAY "Centro Custo"
	@ 110, 100 SAY "Centro Custo"
	@ 110, 300 SAY "Centro Custo"
	@ 110, 500 SAY "Centro Custo"
	@ 125, 100 SAY "Centro Custo"
	@ 125, 300 SAY "Centro Custo"
	@ 125, 500 SAY "Centro Custo"
	@ 140, 100 SAY "Centro Custo"
	@ 140, 300 SAY "Centro Custo"
	@ 140, 500 SAY "Centro Custo"
	@ 155, 100 SAY "Centro Custo"
	@ 155, 300 SAY "Centro Custo"
	@ 155, 500 SAY "Centro Custo"
	@ 170, 100 SAY "Centro Custo"
	@ 170, 300 SAY "Centro Custo"
	@ 170, 500 SAY "Centro Custo"
	@ 185, 100 SAY "Centro Custo"
	@ 185, 300 SAY "Centro Custo"
	@ 185, 500 SAY "Centro Custo"
	@ 200, 100 SAY "Centro Custo"
	@ 200, 300 SAY "Centro Custo"
	@ 200, 500 SAY "Centro Custo"
	@ 215, 100 SAY "Centro Custo"
	@ 215, 300 SAY "Centro Custo"
	@ 215, 500 SAY "Centro Custo"
	@ 230, 100 SAY "Centro Custo"
	@ 230, 300 SAY "Centro Custo"
	@ 230, 500 SAY "Centro Custo"
	@ 245, 100 SAY "Centro Custo"
	@ 245, 300 SAY "Centro Custo"
	@ 245, 500 SAY "Centro Custo"

	@ 005, 050 MSGET _cCampForn  VAR _cForn     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!"  F3 'SA2A' 
	@ 020, 050 MSGET _cCampLoja  VAR _cLoja     SIZE 010,10 OF oDlg2 PIXEL PICTURE "@!"  
	@ 035, 050 MSGET _cCampDForn VAR _cDescForn SIZE 250,10 OF oDlg2 PIXEL PICTURE "@!"  
	@ 050, 050 MSGET _cCampProd  VAR _cProd     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!"  F3 'SB1'
	@ 050, 120 MSGET _cCampItem  VAR _cItem     SIZE 025,10 OF oDlg2 PIXEL PICTURE "@!"
	@ 065, 050 MSGET _cCampDPro  VAR _cDPro     SIZE 250,10 OF oDlg2 PIXEL PICTURE "@!"  
	@ 095, 050 MSGET _nCampP01 	 VAR _nPerc01	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 095, 150 MSGET _cCampCC01  VAR _cCC01     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC01) When .T.
	@ 095, 250 MSGET _nCampP02 	 VAR _nPerc02	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 095, 350 MSGET _cCampCC02  VAR _cCC02     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC02) When .T.
	@ 095, 450 MSGET _nCampP03 	 VAR _nPerc03	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 095, 550 MSGET _cCampCC03  VAR _cCC03     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC03) When .T.
	@ 110, 050 MSGET _nCampP04 	 VAR _nPerc04	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 110, 150 MSGET _cCampCC04  VAR _cCC04     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC04) When .T.
	@ 110, 250 MSGET _nCampP05 	 VAR _nPerc05	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 110, 350 MSGET _cCampCC05  VAR _cCC05     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC05) When .T.
	@ 110, 450 MSGET _nCampP06 	 VAR _nPerc06	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 110, 550 MSGET _cCampCC06  VAR _cCC06     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC06) When .T.
	@ 125, 050 MSGET _nCampP07 	 VAR _nPerc07	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 125, 150 MSGET _cCampCC07  VAR _cCC07     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC07) When .T.
	@ 125, 250 MSGET _nCampP08 	 VAR _nPerc08	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 125, 350 MSGET _cCampCC08  VAR _cCC08     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC08) When .T.
	@ 125, 450 MSGET _nCampP09 	 VAR _nPerc09	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 125, 550 MSGET _cCampCC09  VAR _cCC09     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC09) When .T.
	@ 140, 050 MSGET _nCampP10 	 VAR _nPerc10	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 140, 150 MSGET _cCampCC10  VAR _cCC10     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC10) When .T.
	@ 140, 250 MSGET _nCampP11 	 VAR _nPerc11	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 140, 350 MSGET _cCampCC11  VAR _cCC11     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC11) When .T.
	@ 140, 450 MSGET _nCampP12 	 VAR _nPerc12	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 140, 550 MSGET _cCampCC12  VAR _cCC12     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC12) When .T.
	@ 155, 050 MSGET _nCampP13 	 VAR _nPerc13	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 155, 150 MSGET _cCampCC13  VAR _cCC13     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC13) When .T.
	@ 155, 250 MSGET _nCampP14 	 VAR _nPerc14	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 155, 350 MSGET _cCampCC14  VAR _cCC14     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC14) When .T.
	@ 155, 450 MSGET _nCampP15 	 VAR _nPerc15	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 155, 550 MSGET _cCampCC15  VAR _cCC15     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC15) When .T.
	@ 170, 050 MSGET _nCampP16 	 VAR _nPerc16	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 170, 150 MSGET _cCampCC16  VAR _cCC16     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC16) When .T.
	@ 170, 250 MSGET _nCampP17 	 VAR _nPerc17	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 170, 350 MSGET _cCampCC17  VAR _cCC17     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC17) When .T.
	@ 170, 450 MSGET _nCampP18 	 VAR _nPerc18	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 170, 550 MSGET _cCampCC18  VAR _cCC18     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC18) When .T.
	@ 185, 050 MSGET _nCampP19 	 VAR _nPerc19	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 185, 150 MSGET _cCampCC19  VAR _cCC19     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC19) When .T.
	@ 185, 250 MSGET _nCampP20 	 VAR _nPerc20	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 185, 350 MSGET _cCampCC20  VAR _cCC20     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC20) When .T.
	@ 185, 450 MSGET _nCampP21 	 VAR _nPerc21	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 185, 550 MSGET _cCampCC21  VAR _cCC21     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC21) When .T.
	@ 200, 050 MSGET _nCampP22 	 VAR _nPerc22	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 200, 150 MSGET _cCampCC22  VAR _cCC22     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC22) When .T.
	@ 200, 250 MSGET _nCampP23 	 VAR _nPerc23	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 200, 350 MSGET _cCampCC23  VAR _cCC23     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC23) When .T.
	@ 200, 450 MSGET _nCampP24 	 VAR _nPerc24	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 200, 550 MSGET _cCampCC24  VAR _cCC24     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC24) When .T.
	@ 215, 050 MSGET _nCampP25 	 VAR _nPerc25	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 215, 150 MSGET _cCampCC25  VAR _cCC25     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC25) When .T.
	@ 215, 250 MSGET _nCampP26 	 VAR _nPerc26	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 215, 350 MSGET _cCampCC26  VAR _cCC26     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC26) When .T.
	@ 215, 450 MSGET _nCampP27 	 VAR _nPerc27	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 215, 550 MSGET _cCampCC27  VAR _cCC27     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC27) When .T.
	@ 230, 050 MSGET _nCampP28 	 VAR _nPerc28	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 230, 150 MSGET _cCampCC28  VAR _cCC28     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC28) When .T.
	@ 230, 250 MSGET _nCampP29 	 VAR _nPerc29	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 230, 350 MSGET _cCampCC29  VAR _cCC29     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC29) When .T.
	@ 230, 450 MSGET _nCampP30 	 VAR _nPerc30	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 230, 550 MSGET _cCampCC30  VAR _cCC30     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC30) When .T.
	@ 245, 050 MSGET _nCampP31 	 VAR _nPerc31	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 245, 150 MSGET _cCampCC31  VAR _cCC31     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC31) When .T.
	@ 245, 250 MSGET _nCampP32 	 VAR _nPerc32	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 245, 350 MSGET _cCampCC32  VAR _cCC32     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC32) When .T.
	@ 245, 450 MSGET _nCampP33 	 VAR _nPerc33	SIZE 040,10 OF oDlg2 PIXEL PICTURE "@E 999.99"  
	@ 245, 550 MSGET _cCampCC33  VAR _cCC33     SIZE 040,10 OF oDlg2 PIXEL PICTURE "@!" F3 'CTT' Valid Vazio() .Or. ExistCpo('CTT',_cCC33) When .T.

	@ 035, 400 BMPBUTTON TYPE 1 ACTION (_lConfirma := _VldPerc() )
	@ 035, 455 BMPBUTTON TYPE 2 ACTION (_lConfirma := .T., Close(oDlg2))

	_cCampForn:disable()
	_cCampLoja:disable()
	_cCampDForn:disable()   
	_cCampProd:disable()
	_cCampItem:disable()
	_cCampDPro:disable()

	ACTIVATE DIALOG oDlg2 CENTERED

	If _lConfirma       
		// DELETA TODAS INFORMAวีES DO PEDIDO/FORNECEDOR/ITEM ANTES DA GRAVAวรO
		_cQuery := "DELETE FROM " + RetSqlName("SCH")
		_cQuery += " WHERE CH_FILIAL = '" + FWxFilial("SCH") + "'" 
		_cQuery += "   AND CH_PEDIDO = '" + SC7->C7_NUM + "'"
		_cQuery += "   AND CH_FORNECE = '" + SC7->C7_FORNECE + "'"
		_cQuery += "   AND CH_LOJA = '" + SC7->C7_LOJA + "'"
		_cQuery += "   AND CH_ITEMPD = '" + SC7->C7_ITEM + "'"

		TCSQLEXEC(_cQuery)   

		// ATUALIZA INFORMAวีES DO ITEM NA TABELA SC7
		DbSelectArea("SC7")
		Reclock("SC7",.F.)
		SC7->C7_RATEIO := "1"
		SC7->C7_CC 	   := CriaVar("C7_CC",.F.)

		// GRAVA RATEIOS INFORMADOS NA TABELA DE RATEIOS DO PEDIDO DE COMPRA
		If _nPerc01 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "01"
			SCH->CH_PERC    := _nPerc01
			SCH->CH_CC      := _cCC01
			MsUnlock()
		Endif
		If _nPerc02 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "02"
			SCH->CH_PERC    := _nPerc02
			SCH->CH_CC      := _cCC02
			MsUnlock()
		Endif
		If _nPerc03 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "03"
			SCH->CH_PERC    := _nPerc03
			SCH->CH_CC      := _cCC03
			MsUnlock()
		Endif
		If _nPerc04 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "04"
			SCH->CH_PERC    := _nPerc04
			SCH->CH_CC      := _cCC04
			MsUnlock()
		Endif
		If _nPerc05 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "05"
			SCH->CH_PERC    := _nPerc05
			SCH->CH_CC      := _cCC05
			MsUnlock()
		Endif
		If _nPerc06 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "06"
			SCH->CH_PERC    := _nPerc06
			SCH->CH_CC      := _cCC06
			MsUnlock()
		Endif
		If _nPerc07 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "07"
			SCH->CH_PERC    := _nPerc07
			SCH->CH_CC      := _cCC07
			MsUnlock()
		Endif
		If _nPerc08 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "08"
			SCH->CH_PERC    := _nPerc08
			SCH->CH_CC      := _cCC08
			MsUnlock()
		Endif
		If _nPerc09 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "09"
			SCH->CH_PERC    := _nPerc09
			SCH->CH_CC      := _cCC09
			MsUnlock()
		Endif
		If _nPerc10 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "10"
			SCH->CH_PERC    := _nPerc10
			SCH->CH_CC      := _cCC10
			MsUnlock()
		Endif
		If _nPerc11 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "11"
			SCH->CH_PERC    := _nPerc11
			SCH->CH_CC      := _cCC11
			MsUnlock()
		Endif
		If _nPerc12 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "12"
			SCH->CH_PERC    := _nPerc12
			SCH->CH_CC      := _cCC12
			MsUnlock()
		Endif
		If _nPerc13 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "13"
			SCH->CH_PERC    := _nPerc13
			SCH->CH_CC      := _cCC13
			MsUnlock()
		Endif
		If _nPerc14 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "14"
			SCH->CH_PERC    := _nPerc14
			SCH->CH_CC      := _cCC14
			MsUnlock()
		Endif
		If _nPerc15 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "15"
			SCH->CH_PERC    := _nPerc15
			SCH->CH_CC      := _cCC15
			MsUnlock()
		Endif
		If _nPerc16 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "16"
			SCH->CH_PERC    := _nPerc16
			SCH->CH_CC      := _cCC16
			MsUnlock()
		Endif
		If _nPerc17 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "17"
			SCH->CH_PERC    := _nPerc17
			SCH->CH_CC      := _cCC17
			MsUnlock()
		Endif
		If _nPerc18 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "18"
			SCH->CH_PERC    := _nPerc18
			SCH->CH_CC      := _cCC18
			MsUnlock()
		Endif
		If _nPerc19 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "19"
			SCH->CH_PERC    := _nPerc19
			SCH->CH_CC      := _cCC19
			MsUnlock()
		Endif
		If _nPerc20 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "20"
			SCH->CH_PERC    := _nPerc20
			SCH->CH_CC      := _cCC20
			MsUnlock()
		Endif
		If _nPerc21 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "21"
			SCH->CH_PERC    := _nPerc21
			SCH->CH_CC      := _cCC21
			MsUnlock()
		Endif
		If _nPerc22 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "22"
			SCH->CH_PERC    := _nPerc22
			SCH->CH_CC      := _cCC22
			MsUnlock()
		Endif
		If _nPerc23 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "23"
			SCH->CH_PERC    := _nPerc23
			SCH->CH_CC      := _cCC23
			MsUnlock()
		Endif
		If _nPerc24 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "24"
			SCH->CH_PERC    := _nPerc24
			SCH->CH_CC      := _cCC24
			MsUnlock()
		Endif
		If _nPerc25 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "25"
			SCH->CH_PERC    := _nPerc25
			SCH->CH_CC      := _cCC25
			MsUnlock()
		Endif
		If _nPerc26 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "26"
			SCH->CH_PERC    := _nPerc26
			SCH->CH_CC      := _cCC26
			MsUnlock()
		Endif
		If _nPerc27 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "27"
			SCH->CH_PERC    := _nPerc27
			SCH->CH_CC      := _cCC27
			MsUnlock()
		Endif
		If _nPerc28 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "28"
			SCH->CH_PERC    := _nPerc28
			SCH->CH_CC      := _cCC28
			MsUnlock()
		Endif
		If _nPerc29 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "29"
			SCH->CH_PERC    := _nPerc29
			SCH->CH_CC      := _cCC29
			MsUnlock()
		Endif
		If _nPerc30 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "30"
			SCH->CH_PERC    := _nPerc30
			SCH->CH_CC      := _cCC30
			MsUnlock()
		Endif
		If _nPerc31 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "31"
			SCH->CH_PERC    := _nPerc31
			SCH->CH_CC      := _cCC31
			MsUnlock()
		Endif
		If _nPerc32 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "32"
			SCH->CH_PERC    := _nPerc32
			SCH->CH_CC      := _cCC32
			MsUnlock()
		Endif
		If _nPerc33 > 0
			DbSelectArea("SCH")
			Reclock("SCH",.T.)
			SCH->CH_FILIAL  := FWxFilial("SCH")
			SCH->CH_PEDIDO  := SC7->C7_NUM
			SCH->CH_FORNECE := SC7->C7_FORNECE
			SCH->CH_LOJA    := SC7->C7_LOJA
			SCH->CH_ITEMPD  := SC7->C7_ITEM
			SCH->CH_ITEM    := "33"
			SCH->CH_PERC    := _nPerc33
			SCH->CH_CC      := _cCC33
			MsUnlock()
		Endif
	Endif
	
Return


Static Function _VldPerc()
	Local _lRet := .T.

	If _nPerc01 + _nPerc02 + _nPerc03 + _nPerc04 + _nPerc05 + _nPerc06 + _nPerc07 + _nPerc08 + _nPerc09 + _nPerc10 + _nPerc11 + ;
	   _nPerc12 + _nPerc13 + _nPerc14 + _nPerc15 + _nPerc16 + _nPerc17 + _nPerc18 + _nPerc19 + _nPerc20 + _nPerc21 + _nPerc22 + ;
	   _nPerc23 + _nPerc24 + _nPerc25 + _nPerc26 + _nPerc27 + _nPerc28 + _nPerc29 + _nPerc30 + _nPerc31 + _nPerc32 + _nPerc33 <> 100
		Aviso("ATENวรO" ,"Soma dos Percentuais nใo Totalizam 100%" + Chr(13) + Chr(10) + "Favor Ajustar Percentuais", { "Fechar" }, 2, )
		_lRet := .F.
	Else
		Close(oDlg2)
	Endif
	
Return(_lRet)


Static Function EscrForn()
	_cDescForn := GetAdvFVal('SA2','A2_NOME',FWxfilial('SA2') + _cForn + _cLoja,1)    
	_cCampDForn:refresh()
	oDlg2:refresh()
return


Static Function EscrCp()
	_cDescCond := GetAdvFVal('SE4','E4_DESCRI',FWxfilial('SE4') + _cCPag,1) 
	_cCampDCond:refresh()
	oDlg2:refresh()
return 

Static Function EscrProd()
	_cDPro  := GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1') + _cProd,1) 
	_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1') + _cProd,1) 
	_cCampDPro:refresh()
	oDlg2:refresh()
return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ _UltNUM   ณ Autor ณ                      ณ Data ณ Mar/2019 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Busca maior numero do item do pedido de compra posicionado ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function _UltNUM(_cPedCom)  
Local _Num := 0

cQuery := " SELECT MAX(C7_ITEM) MXITEM"
cQuery += "   FROM " + RETSQLNAME("SC7") + " SC7 "
cQuery += "  WHERE SC7.C7_FILIAL = '" + FWxFilial("SC7") + "'"
cQuery += "    AND SC7.C7_NUM = '" + _cPedCom + "'"
cQuery += "    AND SC7.D_E_L_E_T_ <> '*'"

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'TRBMAX',.F.,.T.)

DbSelectArea("TRBMAX")
DbGoTop()

_NumItem := TRBMAX->MXITEM
  
DbSelectArea("TRBMAX")
DbCloseArea()

Return(_NumItem)
