#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LIMPACOT
Função para limpeza do F2_COTTMS a partir da carga informada
@author 	Evandro Mugnol
@since 		Jun/2022
@return 	Nil, Função não tem retorno
@obs 		Nenhuma
/*/
//-------------------------------------------------------------------

User Function LIMPACOT()

	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Carga p/ limpeza F2_COTTMS")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _cCarga    	:= Space(06)

	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(300), C(410) PIXEL

	@ C(015), C(010) SAY "Informe o número da carga abaixo para efetuar a "			Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela
	@ C(025), C(010) SAY "limpeza do código da cotação."							Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela
	@ C(045), C(010) SAY "Ao executar esse procedimento o sistema irá liberar"		Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela
	@ C(055), C(010) SAY "as notas fiscais para executar a rotina de geração"		Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela
	@ C(065), C(010) SAY "de lotes / docto de entrada no TMS."						Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela

	@ C(095), C(010) SAY "Número da Carga"		                           	   		Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(095), C(080) MSGET _cCarga Picture "@!" F3 'DAK'         		           	Size C(040), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(125), C(120) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _Process())
	DEFINE SBUTTON FROM C(125), C(170) TYPE 2 OBJECT _oCancel ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED                                                                        

Return

// Efetua Processamento dos Dados Informados
Static Function _Process()
	_lClose := .T.

	If !Empty(_cCarga)
		DbSelectArea("SF2")
		DbSetOrder(5)
		DbSeek(xFilial("SF2") + _cCarga)
		While !Eof() .And. SF2->F2_FILIAL + SF2->F2_CARGA == xFilial("SF2") + _cCarga
			Reclock("SF2", .F.)
			SF2->F2_COTTMS := ""
			MsUnlock()
			
			SF2->(DbSkip())
		EndDo
	Else
		// Alimenta a variável com conteúdo da mensagem em HTML
		cMsgHTML := '<h1><font color="#0000FF">Atenção</font></h1>'
		cMsgHTML += '<h3><br><font color="#FF0000"><b>Número da Carga deve ser preenchidos.</font></b></h3>'

		MsgAlert(cMsgHTML)
		_lClose := .F.
	Endif

	If _lClose
		MsgAlert("Procedimento Efetuado com SUCESSO!")		
		_oTela:End()
	EndIf

Return
