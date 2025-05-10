#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"



//-------------------------------------------------------------------
/*/{Protheus.doc} F240TDOK
Ponto de entrada para validar as informações para geração do borderô
@author 	Evandro Mugnol
@since 		Set/2021
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/
//-------------------------------------------------------------------

User Function F240TDOK()

	Local _aArea := GetArea()
	Local _lRet  := .T.

	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Data para pagamento no cnab a pagar")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _dDtPgto  	:= Date()

																				  // Comando abaixo inibi botão X
	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(210), C(370) PIXEL STYLE DS_MODALFRAME
	_oTela:lEscClose := .F. 	// Desabilita a tecla ESCape pra fechar a janela
	@ C(005), C(010) SAY "Informe a data para pagamento que será considerada"		Size C(300), C(12) FONT _oFtArial30 COLOR CLR_CYAN 	PIXEL OF _oTela
	@ C(015), C(010) SAY "nos títulos deste borderô e processada na geração"		Size C(300), C(12) FONT _oFtArial30 COLOR CLR_CYAN 	PIXEL OF _oTela
	@ C(025), C(010) SAY "do arquivo de cnab de pagamentos para o banco."			Size C(300), C(12) FONT _oFtArial30 COLOR CLR_CYAN 	PIXEL OF _oTela

	@ C(050), C(050) SAY "Data para Pagamento"                             	  		Size C(150), C(10) FONT _oFtArial24 COLOR CLR_HBLUE PIXEL OF _oTela
	@ C(065), C(055) MSGET _dDtPgto VALID NaoVazio() .And. _VldData()          		Size C(060), C(10) FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(090), C(150) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_lRet := .T., _Process())

	ACTIVATE MSDIALOG _oTela CENTERED                                                                        

	RestArea(_aArea)

Return(_lRet)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua Processamento da Data Informada						³
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
Static Function _Process()

	// Atualiza parâmetro no SX6 para data de pagamento na geração do borderô
	PUTMV("FS_FDTPGTO", _dDtPgto)

	_oTela:End()

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua Consistencia na Data Informada                       ³
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
Static Function _VldData()

	_lRet := .T.

	If _dDtPgto < Date()
		MsgAlert("Data informada não pode ser menor que data do sistema.","Atenção")
		_lRet := .F.
	Else
		_dDtPgto := DataValida(_dDtPgto, .T.)
	Endif

Return(_lRet)
