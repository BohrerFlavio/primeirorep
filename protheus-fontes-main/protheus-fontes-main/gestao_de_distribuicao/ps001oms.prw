#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*                                                                                             
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS001OMS  ºAutor  ³Ezequiel Pianegonda º Data ³  09/02/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Geracao de lotes/doc de entrada no TMS                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS001OMS()

	Local nOpc  := 0
	//Local nOpc1 := 0
	Local nOpc2 := 0
	Local nOpc3 := 0
	//Local nOpc4 := 0

	Private _oCombo := Nil
	Private _oComb1 := Nil
	Private _oComb2 := Nil
	Private _oComb3 := Nil
	Private _oComb4 := Nil
	Private _oGet1  := Nil
	Private _oGet2	:= Nil
	Private _oGet3	:= Nil
	Private _oGet4	:= Nil
	Private _oDlg	:= Nil
	Private _oFont	:= Nil
	Private _oSay1	:= Nil
	Private _oSay2	:= Nil
	Private _oSay3	:= Nil
	Private _oSay4	:= Nil
	Private _oSay5	:= Nil
	Private _oSay6	:= Nil
	Private _oSay7	:= Nil
	Private _oGroup	:= Nil
	Private _oBtn1	:= Nil
	Private _oBtn2	:= Nil
	Private _oBtn3	:= Nil
	Private _oBtn4	:= Nil
	Private _cCombo	:= ""
	Private _cComb1	:= ""
	Private _cComb2	:= ""
	Private _cComb3	:= ""
	Private _cComb4	:= ""
	Private _cGet1	:= Space(Len(SF2->F2_CARGA))
	Private _cGet2	:= Space(Len(SF2->F2_CARGA))
	Private _cGet3	:= Space(Len(SF2->F2_SERIE))
	Private _aItems	:= {'Carga', 'Nota Fiscal'}
	//Private _aItems1:= {'Truck', 'Toco', 'Mercedinha','Carreta RG'}
	
	Private cTipoVei:= Space(TamSX3("DUT_TIPVEI")[1])
	Private _aItems2:= {'Outros', 'Santa Maria'}
	Private _aItems3:= {'Outros', 'Santa Maria'}
	//Private _aItems4:= {'RS', 'PR e outros','Unico RS','SC','Unico SC'}
	Private cTbTarif:= Space(TamSX3("DTF_TABFRE")[1])
	cTbTarif := '0003'
	_oDlg:= TDialog():New(0, 0, 315, 420,'Gerar Lote/Dc.Entrada no TMS - Empresa Transportadora',,,,, CLR_BLACK, CLR_WHITE,,, .T.)

	_oFont:= TFont():New('Courier new',, -14, .T.)

	_oGroup:= TGroup():New(02, 02, 130, 200, '', _oDlg,,, .T.)

	_oSay1:= TSay():New(10, 10, {|| 'Tipo processamento'}, _oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_cCombo:= _aItems[1]
	_oCombo:= TComboBox():New(10, 90, {|u| If(PCount() > 0, _cCombo:= u, _cCombo)}, _aItems, 50, 20, _oDlg,, {|| ComboSel()},,,,.T.,,,,,,,,,'_cCombo')

	_oSay1:= TSay():New(25, 10, {|| 'Tipo veículo'}, _oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	//_cCombo1:= _aItems1[1]
	//_oCombo1:= TComboBox():New(25, 90, {|u| If(PCount() > 0, _cCombo1:= u, _cCombo1)}, _aItems1, 50, 20, _oDlg,, {||},,,,.T.,,,,,,,,,'_cCombo1')
	oGet := TGet():New(27,90,bSETGET(cTipoVei),_oDlg,60,10,"@!",{|| ExistCPO("DUT", cTipoVei) },,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cTipoVei",,,,.T.)
	oGet:cF3 := "DUTSLV"

	_oSay5:= TSay():New(40, 10, {|| 'Reg. Origem'}, _oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_cCombo2:= _aItems2[1]
	_oCombo2:= TComboBox():New(40, 90, {|u| If(PCount() > 0, _cCombo2:= u, _cCombo2)}, _aItems2, 50, 20, _oDlg,, {||},,,,.T.,,,,,,,,,'_cCombo2')

	_oSay6:= TSay():New(55, 10, {|| 'Reg. Destino'}, _oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_cCombo3:= _aItems3[1]
	_oCombo3:= TComboBox():New(55, 90, {|u| If(PCount() > 0, _cCombo3:= u, _cCombo3)}, _aItems3, 50, 20, _oDlg,, {||},,,,.T.,,,,,,,,,'_cCombo3')

	_oSay7:= TSay():New(70, 10, {|| 'Tab. Tarifas'}, _oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	//_cCombo4:= _aItems4[1]
	//_oCombo4:= TComboBox():New(70, 90, {|u| If(PCount() > 0, _cCombo4:= u, _cCombo4)}, _aItems4, 50, 20, _oDlg,, {||},,,,.T.,,,,,,,,,'_cCombo4')
	oGet1 := TGet():New(72,90,bSETGET(cTbTarif),_oDlg,60,10,"@!",{|| ExistCPO("DTF", cTbTarif) },,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cTbTarif",,,,.T.)
	oGet1:cF3 := "DTFSLV"

	_oSay2:= TSay():New(087, 10, {|| 'Carga de'}, _oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet1:= TGet():New(087, 90, {|u| If(PCount() > 0, _cGet1:= u, _cGet1)}, _oDlg,, 009, "@!",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet1,,,,)
	_oSay3:= TSay():New(100, 10, {|| 'Carga até'}, _oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet2:= TGet():New(100, 90, {|u| If(PCount() > 0, _cGet2:= u, _cGet2)}, _oDlg,, 009, "@!",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet2,,,,)
	_oSay4:= TSay():New(113, 10, {|| 'Série'}, _oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet3:= TGet():New(113, 90, {|u| If(PCount() > 0, _cGet3:= u, _cGet3)}, _oDlg,, 009, "@!",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet3,,,,)
	_oSay4:lVisibleControl:= .F.
	_oGet3:lVisibleControl:= .F.

	//_oBtn1:= TButton():New(135, 190-70, "OK", _oDlg, {|| (nOpc:= _oCombo:nAt, nOpc1:= _oCombo1:nAt, nOpc2:= _oCombo2:nAt, nOpc3:= _oCombo3:nAt, nOpc4:= _oCombo4:nAt, _oDlg:End())}, 30, 15,,, .F., .T., .F.,, .F.,,, .F.)
	_oBtn1:= TButton():New(135, 190-70, "OK", _oDlg, {|| (nOpc:= _oCombo:nAt, cTipoVei, nOpc2:= _oCombo2:nAt, nOpc3:= _oCombo3:nAt, cTbTarif, _oDlg:End())}, 30, 15,,, .F., .T., .F.,, .F.,,, .F.)
	_oBtn2:= TButton():New(135, 190-30, "Cancelar", _oDlg, {|| (nOpc:= 0, _oDlg:End(), _oDlg:End())}, 30, 15,,, .F., .T., .F.,, .F.,,, .F.)

	_oDlg:Activate(,,,.T.,,,)

	If nOpc != 0		
		//Processa({|| RunExec(nOpc, nOpc1, nOpc2, nOpc3, nOpc4)})
		Processa({|| RunExec(nOpc, cTipoVei, nOpc2, nOpc3, cTbTarif)})
	Else
		MsgInfo("Cancelado pelo usuário.")
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RunExec   ºAutor  ³Ezequiel Pianegonda º Data ³  09/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de processamento... '                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RunExec(nOpc, cTipVei, nCDRori, nCDRdes, cTabTar)
	Local cQuery:= ""
	Local aArea	:= GetArea()
	Local cAli	:= GetNextAlias()
	Local cAli2	:= GetNextAlias()
	Local aNotas:= {}
	Local cMsg	:= ""
	
	cQuery := " SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_VOLUME1+F2_VOLUME2+F2_VOLUME3+F2_VOLUME4 VOLUME, F2_PBRUTO, F2_VALBRUT, F2_CARGA, F2_COTTMS,F2_CHVNFE "
	cQuery += " FROM  "+RetSqlTab("SF2")
	cQuery += " WHERE "+RetSqlFil("SF2")+" AND"
	cQuery += "         $WHERE$ "
	cQuery += "       "+RetSqlDel("SF2")

	Do Case
		Case nOpc == 1	//processa carga
			cQuery:= StrTran(cQuery, "$WHERE$", "F2_CARGA BETWEEN '"+_cGet1+"' AND '"+_cGet2+"' AND ")
		Case nOpc == 2	//processa doc.entrada
			cQuery:= StrTran(cQuery, "$WHERE$", "F2_DOC BETWEEN '"+_cGet1+"' AND '"+_cGet2+"' AND F2_SERIE = '"+_cGet3+"' AND ")
		Otherwise
			MsgInfo("Opção inválida, verifique.")
			Return
	EndCase

	TCQuery ChangeQuery(cQuery) New Alias &(cAli)

	//bloco para verfificar e já foi transmitida as NF-e para poder gerar os CT-e

	_lOk := .t.
	Do While !&(cAli)->(EOF())
		
		if  empty(&(cAli)->(F2_CHVNFE))
			_lOk := .f.
		endif

		&(cAli)->(dbSkip())
	EndDo

//Em caso de não transmissão, não gera doc CT-e

	if _lOk
		&(cAli)->(dbgotop())
		Do While !&(cAli)->(EOF())
			//verifico se existe relacao entre os clientes da empresa XX com a 07, via cnpj
			cQuery:= " SELECT TOP 1 A1_COD, A1_LOJA "
			cQuery+= " FROM SA1070 "
			cQuery+= " WHERE SA1070.A1_FILIAL = '' AND "
			cQuery+= "       SA1070.A1_CGC = "
			cQuery+= "       ("
			cQuery+= "       SELECT A1_CGC "
			cQuery+= "       FROM  "+RetSqlTab("SA1")
			cQuery+= "       WHERE "+RetSqlFil("SA1")+" AND "
			cQuery+= "               A1_COD = '"+&(cAli)->(F2_CLIENTE)+"' AND "
			cQuery+= "               A1_LOJA = '"+&(cAli)->(F2_LOJA)+"' AND "
			cQuery+= "             "+RetSqlDel("SA1")
			cQuery+= "       ) AND "
			cQuery+= "      SA1070.D_E_L_E_T_ = '' AND SA1070.A1_MSBLQL <> '1' "
			TCQuery ChangeQuery(cQuery) New Alias &(cAli2)

			If Empty(&(cAli)->(F2_COTTMS))
				If !Empty(&(cAli2)->(A1_COD))
					//		   alert("1º: " + (cAli)->(F2_CHVNFE))
					AADD(aNotas, {&(cAli)->(F2_DOC),;
						&(cAli)->(F2_SERIE),;
						&(cAli2)->(A1_COD),;
						&(cAli2)->(A1_LOJA),;
						&(cAli)->(VOLUME),;
						&(cAli)->(F2_PBRUTO),;
						&(cAli)->(F2_VALBRUT),;
						&(cAli)->(F2_CARGA),;
						&(cAli)->(F2_CHVNFE)})
				Else
					Alert("O cliente "+&(cAli)->(F2_CLIENTE)+"/"+&(cAli)->(F2_LOJA)+" não possui relação com a empresa Transportadora pelo CNPJ.")
				EndIf
			Else
				If nOpc == 1
					Alert("Carga " + &(cAli)->(F2_CARGA) + "já foi processada e não irá gerar cotação na empresa Transportadora.")
				Else
					Alert("Nota Fiscal " + &(cAli)->(F2_DOC) + " / " + &(cAli)->(F2_SERIE) + "já foi processada e não irá gerar cotação na empresa Transportadora.")
				Endif
			Endif
			&(cAli2)->(dbCloseArea())
			&(cAli)->(dbSkip())
		EndDo
		
		If Len(aNotas) > 0
			MemoWrite("U_PS001TMS.TXT", "")

			MsAguarde({|| aRetorno := StartJob("U_PS001TMS", GetEnvServer(), .T., "07", "00", aNotas,;
						  {cEmpAnt, cFilAnt},;
						  cTipVei,;				// PADL(cValToChar(iif(nTipVei == 4,15,nTipVei)), 2, "0"), ;
						  nCDRori,;
						  nCDRdes,;
						  cTabTar)}, "Processando...")
			
			cMsg := MemoRead("U_PS001TMS.TXT")

			If !Empty(cMsg)
				Alert(cMsg)
			EndIf
		Else
			MsgInfo("A consulta não retornou registros, verifique.")
		EndIf

		&(cAli)->(dbCloseArea())
		RestArea(aArea)
		MsgInfo("Processo finalizado.")		
	else
		MsgInfo("Não foi possível criar os documentos, pois as Notas não foram transmitidas. Verifique!")
	endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ComboSel  ºAutor  ³Ezequiel Pianegonda º Data ³  09/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao executada qualdo um item do combo e selecionado, paraº±±
±±º          ³alterar a descricao dos parametros.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ComboSel()
	If _oCombo:nAt == 1
		_oSay2:SetText("Carga de")
		_oSay3:SetText("Carga até")
		_oSay4:lVisibleControl:= .F.
		_oGet3:lVisibleControl:= .F.
		_cGet1:= Space(Len(SF2->F2_CARGA))
		_cGet2:= Space(Len(SF2->F2_CARGA))
		_cGet3:= ""
	Else
		_oSay2:SetText("Nota fiscal de")
		_oSay3:SetText("Nota fiscal até")
		_oSay4:lVisibleControl:= .T.
		_oGet3:lVisibleControl:= .T.
		_cGet1:= Space(Len(SF2->F2_DOC))
		_cGet2:= Space(Len(SF2->F2_DOC))
		_cGet3:= Space(Len(SF2->F2_SERIE))
	EndIf
	_oGet1:CtrlRefresh()
	_oGet2:CtrlRefresh()
	_oGet3:CtrlRefresh()
Return
