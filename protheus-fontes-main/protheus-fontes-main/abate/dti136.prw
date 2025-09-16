#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch" 
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"

/*/
±±ºPrograma  ³DTI136     º Autor ³Mateus Escobarº   Data ³  02/11/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Criação de Impressão Etiqueta Cabeças de Gado              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
/*/

User Function DTI136()

    Private nNum  := 0
	Private nNum2 := 0 
    Private _oFont  := tFont():New("courier new",,-14,,.t.,,,,)

    DEFINE DIALOG oDlg TITLE "NUMERAÇÃO PARA CABEÇA DE GADO" FROM 180,180 TO 400,800 PIXEL
	   	
		_oSay3  := TSay():New(32,040, {||'De:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 100)

		_oGet1  := TGet():New(32,140, {|u| If(PCount() > 0,nNum:=u,nNum)}, oDlg,,,"@E 999",{||}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, "_nGet2",,,,.t.,)
  
		_oSay4  := TSay():New(43,040, {||'Até:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 100)

		_oGet2  := TGet():New(43,140, {|u| If(PCount() > 0,nNum2:=u,nNum2)}, oDlg,,,"@E 999",{||}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, "_nGet2",,,,.t.,)
  
		_oBtn0 := TButton():New(60,200, "Imprimir", oDlg,{|| Imprime() },40,20,,,.F.,.T.,.F.,,.F.,,,.F. )  
        
	    _oBtn2 := TButton():New(60,260, "Sair"    , oDlg,{||oDlg:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 


	ACTIVATE DIALOG oDlg CENTERED        
    
    
Return
 
Static Function Imprime()
	Local _cIp 	:= ''
	Local _cEst := GetComputerName()
    
While(nNum <= nNum2)
	DbSelectArea('ZAM')
	ZAM->(DbSetOrder(1))
	If ZAM->(DbSeek(xFilial('ZAM') + Alltrim(_cEst)))		
		_cIp := Alltrim(ZAM->ZAM_IP)					
			
	Endif	   	
    	u_DTI135('S600','IP',_cIp,nNum)
    		nNum ++
	EndDo
Return
