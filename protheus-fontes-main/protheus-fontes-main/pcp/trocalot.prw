#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"

/*/{Protheus.doc} TROCALOT
Rotina que efetua troca de lote referente a um determinado aviso de matança
@author 	Evandro Mugnol
@since 		Dez/2020
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function TROCALOT()

	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Parâmetros para Troca de Lotes")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _cAviso  	:= Space(08)
	Private _cLote1    	:= Space(06)
	Private _cLote2    	:= Space(06)

	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(210), C(370) PIXEL
	@ C(005), C(010) SAY "Esta rotina tem como objetivo efetuar a troca de lote"	Size C(300), C(12) FONT _oFtArial30 COLOR CLR_CYAN 	PIXEL OF _oTela
	@ C(015), C(010) SAY "referente ao aviso matança informado abaixo, sendo"		Size C(300), C(12) FONT _oFtArial30 COLOR CLR_CYAN 	PIXEL OF _oTela
	@ C(025), C(010) SAY "que o aviso matança deve estar com status 'ABERTO'"		Size C(300), C(12) FONT _oFtArial30 COLOR CLR_CYAN 	PIXEL OF _oTela

	@ C(050), C(010) SAY "Aviso Matança"                                  	  		Size C(100), C(10) FONT _oFtArial24 COLOR CLR_HBLUE PIXEL OF _oTela
	@ C(050), C(070) MSGET _cAviso VALID _VldAvis() F3 "SZGSTA" 	           		Size C(060), C(10) FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF _oTela
	@ C(070), C(010) SAY "Trocar lote"                            	   				Size C(100), C(10) FONT _oFtArial24 COLOR CLR_HRED	PIXEL OF _oTela
	@ C(070), C(050) MSGET _cLote1 VALID _VldLot1()							   		Size C(035), C(10) FONT _oFCourier  COLOR CLR_HRED	PIXEL OF _oTela
	@ C(070), C(090) SAY "pelo lote"                            	   				Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(070), C(130) MSGET _cLote2 VALID _VldLot2() 						   		Size C(035), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(090), C(100) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _Process())
	DEFINE SBUTTON FROM C(090), C(140) TYPE 2 OBJECT _oCancel ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED                                                                        

Return

// Efetua Processamento dos Dados Informados
Static Function _Process()

	If !Empty(_cLote1) .And. !Empty(_cLote2) 

		// Efetua trocas na tabela SZ4
		DbSelectArea("SZ4")
		DbSetOrder(1)
		DbGoTop()
		If DbSeek(xFilial("SZ4") + _cAviso + _cLote1)
			RecLock("SZ4",.F.)
			SZ4->Z4_LOTE := "999999"
			MsUnlock()
		Endif

		DbSelectArea("SZ4")
		DbSetOrder(1)
		DbGoTop()
		If DbSeek(xFilial("SZ4") + _cAviso + _cLote2)
			RecLock("SZ4",.F.)
			SZ4->Z4_LOTE  := _cLote1
			SZ4->Z4_ORDEM := Val(_cLote1)
			MsUnlock()
		Endif

		DbSelectArea("SZ4")
		DbSetOrder(1)
		DbGoTop()
		If DbSeek(xFilial("SZ4") + _cAviso + "999999")
			RecLock("SZ4",.F.)
			SZ4->Z4_LOTE  := _cLote2
			SZ4->Z4_ORDEM := Val(_cLote2)
			MsUnlock()
		Endif


		// Efetua trocas na tabela SZE
		_cQuery := "UPDATE " + RetSqlName("SZE")
		_cQuery += "   SET ZE_LOTE = '999999' "
		_cQuery += " WHERE D_E_L_E_T_ <> '*'"
		_cQuery += "   AND ZE_NUMAM = '" + _cAviso + "' "
		_cQuery += "   AND ZE_LOTE = '" + _cLote1 + "' "
		_cQuery += "   AND ZE_FILIAL = '" + xFilial("SZE") + "' "
		TCSQLExec(_cQuery)

		_cQuery := "UPDATE " + RetSqlName("SZE")
		_cQuery += "   SET ZE_LOTE = '" + _cLote1 + "' "
		_cQuery += " WHERE D_E_L_E_T_ <> '*'"
		_cQuery += "   AND ZE_NUMAM = '" + _cAviso + "' "
		_cQuery += "   AND ZE_LOTE = '" + _cLote2 + "' "
		_cQuery += "   AND ZE_FILIAL = '" + xFilial("SZE") + "' "
		TCSQLExec(_cQuery)

		_cQuery := "UPDATE " + RetSqlName("SZE")
		_cQuery += "   SET ZE_LOTE = '" + _cLote2 + "' "
		_cQuery += " WHERE D_E_L_E_T_ <> '*'"
		_cQuery += "   AND ZE_NUMAM = '" + _cAviso + "' "
		_cQuery += "   AND ZE_LOTE = '999999' "
		_cQuery += "   AND ZE_FILIAL = '" + xFilial("SZE") + "' "
		TCSQLExec(_cQuery)
		
		MsgAlert("Troca do lote " + _cLote1 + " pelo lote " + _cLote2 + " efetuado com Sucesso.")
	Else
		MsgAlert("Campos de Lote Não Preenchidos. Troca Não Será Efetuada.")
	Endif

	_oTela:End()

	U_TROCALOT()

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Consistencia no Aviso de Matança                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _VldAvis()
_lRet := .T.

DbSelectArea("SZG")
DbSetOrder(1)
If DbSeek(xFilial("SZG") + _cAviso)
	If SZG->ZG_STATUS == "E"
	   MsgAlert("Aviso de matança já está encerrado. Informe um aviso de matança com status 'Aberto'")
   	_lRet := .F.
	Endif
Else
   MsgAlert("Aviso de matança inválido. Verifique!!!")
   _lRet := .F.
Endif

Return(_lRet)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Consistencia no Lote1 informado                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _VldLot1()
_lRet := .T.

DbSelectArea("SZ4")
DbSetOrder(1)
If !DbSeek(xFilial("SZ4") + _cAviso + _cLote1)
   MsgAlert("Lote informado não existe para o aviso de matança ou inválido. Verifique!!!")
   _lRet := .F.
Endif

Return(_lRet)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Consistencia no Lote2 informado                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _VldLot2()
_lRet := .T.

DbSelectArea("SZ4")
DbSetOrder(1)
If !DbSeek(xFilial("SZ4") + _cAviso + _cLote2)
   MsgAlert("Lote informado não existe para o aviso de matança ou inválido. Verifique!!!")
   _lRet := .F.
Endif

Return(_lRet)
