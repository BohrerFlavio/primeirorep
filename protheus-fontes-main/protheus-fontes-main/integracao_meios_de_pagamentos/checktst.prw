#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"

User Function CHECKTST()

	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Parâmetros para Testes - Checkout")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _cCarga     := Space(06)
	Private _cDoc    	:= Space(09)
	Private _cSerie    	:= Space(03)
	Private _cClie    	:= Space(06)
	Private _cLoja     	:= Space(02)

	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(350), C(800) PIXEL
	@ C(019), C(170) SAY "Digite a Carga ou Dados do Documento"					Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela
	@ C(020), C(010) SAY "Nr. da Carga"                             	   		Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(020), C(080) MSGET _cCarga 											 	Size C(050), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

	@ C(050), C(010) SAY "Nota Fiscal"                                  	  	Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(050), C(080) MSGET _cDoc            	           	               		Size C(080), C(10) FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF _oTela
	@ C(070), C(010) SAY "Série"                                	   			Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(070), C(080) MSGET _cSerie 											   	Size C(030), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(090), C(010) SAY "Cliente"             		                       	   	Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(090), C(080) MSGET _cClie                       	                  	Size C(050), C(10) FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF _oTela
	@ C(110), C(010) SAY "Loja"		                                	   		Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(110), C(080) MSGET _cLoja                                           	Size C(020), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(150), C(080) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _Process())
	DEFINE SBUTTON FROM C(150), C(150) TYPE 2 OBJECT _oCancel ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED                                                                        

Return

// Efetua Processamento dos Dados Informados
Static Function _Process()

	If !Empty(_cCarga)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processamento dos Dados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Seleção das notas faturadas como cartão de crédito e que ainda não tenham "checkout_id": Identificador da transação de cobrança do integrador
		_cQuery := "SELECT F2_CARGA, F2_SEQCAR, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FRMREC, F2_CHKID, F2_CODINT, F2_VALBRUT "
		_cQuery += "  FROM " + RetSQLTab("SF2")
		_cQuery += " WHERE	" + RetSQLFil("SF2")
		_cQuery += "   AND F2_CARGA = '" + _cCarga + "'"
		_cQuery += "   AND F2_FRMREC = '5'"					// Somente Forma de Recebimento igual a Cartão de Crédito
		_cQuery += "   AND F2_CHKID = ''"
		_cQuery += "   AND F2_CODINT = ''"
		_cQuery += "   AND " + RetSQLDel("SF2")
		_cQuery += " ORDER BY F2_CARGA, F2_SEQCAR, F2_DOC, F2_SERIE "
	
		_cQuery := ChangeQuery(_cQuery)
	
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), "TRB", .F., .T.)
	
		//memowrite("ZZZ_CHECKTST.TXT",_cQuery)
	
		TRB->(dbGoTop())
		While TRB->(!Eof())
			//MsgAlert("Processando Documento: " + TRB->F2_DOC + "-" + TRB->F2_SERIE + "-" + TRB->F2_CLIENTE + "-" + TRB->F2_LOJA + "     => da carga: " + _cCarga)
			U_CHECKOUT(TRB->F2_DOC, TRB->F2_SERIE, TRB->F2_CLIENTE, TRB->F2_LOJA, TRB->F2_VALBRUT)		// Chama Método Checkout
			TRB->(DbSkip())
		Enddo
	
		TRB->(DbCloseArea())

	Else

		DbSelectArea("SF2")
		DbSetOrder(1)
		MsSeek(xFilial("SF2") + _cDoc + _cSerie + _cClie + _cLoja)
		If Found()
			// Somente se for forma de recebimento igual a cartão de crédito e não tiver Checkout ID preenchido
			If SF2->F2_FRMREC == "5" .And. Empty(SF2->F2_CHKID) .And. Empty(SF2->F2_CODINT)
				//MsgAlert("Processando Documento " + _cDoc + "-" + _cSerie + "-" + _cClie + "-" + _cLoja)
				U_CHECKOUT(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_VALBRUT)		// Chama Método Checkout
			Endif
		Endif
	Endif

	_oTela:End()

Return
