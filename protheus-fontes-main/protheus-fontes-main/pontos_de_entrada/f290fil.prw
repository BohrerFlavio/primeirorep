#INCLUDE "TOTVS.CH"
#INCLUDE "COLORS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F290FIL
Ponto de Entrada executado após confirmar a tela de faturas a pagar e  utilizado na montagem do filtro da Indregua. 
Caso o ponto de entrada exista, o filtro retornado é anexado ao filtro padrão.
@author     Evandro
@since      Nov/2020
@return     cFiltro, Expressão caracter com o filtro desejado.
@obs        N/A
/*/
//-------------------------------------------------------------------

User Function F290FIL()  

	Local aArea   := FWGetArea()
	Local cFiltro := ""

	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Parâmetros Complementares - Geração de Faturas")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _dVencDe    := Ctod("")
	Private _dVencAte	:= Ctod("")
	Private _dCtbDe    	:= Ctod("")
	Private _dCtbAte  	:= Ctod("")
	
	//alert('Linha 30 - carregamdno PE')
	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(350), C(450) PIXEL
	@ C(015), C(010) SAY "Informe abaixo as datas correspondentes para considerar"	Size C(500), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela
	@ C(030), C(010) SAY "como complemento de filtro para geração de faturas"		Size C(500), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela

	@ C(050), C(010) SAY "Do Vencimento"                                  	  		Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(050), C(100) MSGET _dVencDe         	           	               			Size C(050), C(10) FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF _oTela
	@ C(070), C(010) SAY "Até o Vencimento"                        	   				Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(070), C(100) MSGET _dVencAte										   		Size C(050), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(090), C(010) SAY "Da Data Contabilização"             		            	Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(090), C(100) MSGET _dCtbDe                      	                  		Size C(050), C(10) FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF _oTela
	@ C(110), C(010) SAY "Até a Data Contabilização"		                    	Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(110), C(100) MSGET _dCtbAte                                         		Size C(050), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(150), C(130) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED                                                                        

	cFiltro := " E2_VENCTO BETWEEN '" + dtos(_dVencDe) + "' AND '" + dtos(_dVencAte) + "' AND E2_EMIS1 BETWEEN '" + dtos(_dCtbDe) + "' AND '" + dtos(_dCtbAte) + "'"	// + "' AND E2_NATUREZ = '" + cNat + "'"    

	FWRestArea(aArea)
	
Return cFiltro
