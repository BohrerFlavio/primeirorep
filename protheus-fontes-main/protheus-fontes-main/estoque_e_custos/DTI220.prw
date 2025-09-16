#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"

/*{Protheus.doc} DTI220
Rotina que abre tela na rotina de transferência múltipla (MATA261)
@author 	Flávio
@since 		Jan/2025
@return 	.T.
@obs 		Preencher campos da SD3 no início da grid
*/

User Function DTI220()
	
	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Parâmetros para Informar Lote Fornec e Valid. Lote")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)	
	Private _cLoteFor   := GdFieldGet("D3_LOTEFOR", n)		
	Private _dDataVld   := GdFieldGet("D3_DATAV"  , n)		
    Private _nQuant     := GdFieldGet("D3_QUANT"  , n)
    Private _cSerien    := GdFieldGet("D3_NUMSERI", n)
	
	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(210), C(370) PIXEL
	@ C(005), C(010) SAY "Favor Preencher Lote Fornec e Valid. Lote"	Size C(300), C(12) FONT _oFtArial30 COLOR CLR_CYAN 	PIXEL OF _oTela
	@ C(015), C(010) SAY "      Inf. muito Importante para Bloco K.."	    Size C(300), C(12) FONT _oFtArial30 COLOR CLR_CYAN 	PIXEL OF _oTela
	
	@ C(035), C(010) SAY "Lote Fornecedor"     	Size C(100), C(10) FONT _oFtArial24 COLOR CLR_HBLUE PIXEL OF _oTela
	@ C(035), C(070) MSGET _cLoteFor 			Size C(060), C(10) FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF _oTela	
	@ C(047), C(010) SAY "Validade Lote"        Size C(100), C(10) FONT _oFtArial24 COLOR CLR_HRED	PIXEL OF _oTela
	@ C(047), C(070) MSGET _dDataVld 			Size C(060), C(10) FONT _oFCourier  COLOR CLR_HRED	PIXEL OF _oTela
	
    @ C(059), C(010) SAY "Quantidade"           Size C(100), C(10) FONT _oFtArial24 COLOR CLR_HBLUE	PIXEL OF _oTela
	@ C(059), C(070) MSGET _nQuant 			    Size C(50) , C(10) PICTURE "@E 999,999.99" FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF _oTela
    @ C(071), C(010) SAY "Série Nota"           Size C(100), C(10) FONT _oFtArial24 COLOR CLR_HRED	PIXEL OF _oTela
	@ C(071), C(070) MSGET _cSerien 		    Size C(060), C(10) FONT _oFCourier  COLOR CLR_HRED	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(090), C(100) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _Process())
	DEFINE SBUTTON FROM C(090), C(140) TYPE 2 OBJECT _oCancel ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED                                                                        

Return .T.

// Efetua Processamento dos Dados Informados
Static Function _Process()
	
		
	GDFieldPut("D3_LOTEFOR", _cLoteFor, n)
	GDFieldPut("D3_DATAV"  , _dDataVld, n)
    GDFieldPut("D3_QUANT"  , _nQuant  , n)
    GDFieldPut("D3_NUMSERI", _cSerien , n)

	_oTela:End()
		
Return 
