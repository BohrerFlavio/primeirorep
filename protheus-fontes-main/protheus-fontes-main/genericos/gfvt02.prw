#INCLUDE "Rwmake.ch"  
#INCLUDE "Protheus.ch"   
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"   
#INCLUDE "tbiconn.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GFVT02     º Autor ³Giuliano Forgiariniº Data ³  29/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para determinar os menus iniciais para apontamento  º±±
±±º          ³rotina a ser utilizada pelos microterminais VT100           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function VT_MAIN()

	//Prepara o ambiente para a rotina
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'SZG','SZK','SC2','SZ4','SC2','SZD','SZE'

	//Define o tamanho da tela
	VTSetSize(2,18)


	VTSet Key 27 to sair()

	_senha := VTGetSenha(@Date(),time())

	VTClear screen

	_lOk := .t.

	While _lOk

		_cOpc := space(1)

		VTClear screen
		VTClearBuffer() 	 		                       

		@ 00,00 VTSay GetClientIP()//"1:ABT" 
		@ 00,06 VTSay "2:DSO" 
		@ 01,00 VTSay "3:CAM"   
		@ 01,06 VTSay "4:EMB"  

		@ 01,12 VTSay "->" VTGet _cOpc  valid Sair() Pict "@!" 

		VTRead 

		_cOpc := alltrim(_cOpc)

		Do Case
			case _cOpc = '1' 
			u_VT_ABT() 
			VTClear screen
			VTClearBuffer() 	 		                       
			case _cOpc = '2'
			VTAlert('Em construção!:2','Atencao',.T.,2000,1)  
			loop
			case _cOpc = '3'                                     
			VTAlert('Em construção!:3','Atencao',.T.,2000,1) 
			loop
			case _cOpc = '4'
			VTAlert('Em construção!:4','Atencao',.T.,2000,1)
			loop            
		endcase

	EndDo      

	_lOk := .t.

	VTClear()
	@ 00,00 VTPause 'Termino Normal '
Return


//Menu específico para as rotinas
//que serão utilizadas no abate      
User Function VT_ABT()


	//Define o tamanho da tela
	VTSetSize(2,18)

	VTSet Key 27 to sair()

	_lOk := .t.

	While _lOk

		_cOpc := space(1)

		VTClear()
		VTClearBuffer()

		@ 00,00 VTSay "1:BRI"
		@ 00,06 VTSay "2:TIP"
		@ 01,00 VTSay "3:PRO"
		@ 01,06 VTSay "4:BAL"

		@ 01,12 VTSay "->" VTGet _cOpc  Pict "@!"

		VTRead

		_cOpc := alltrim(_cOpc)

		Do Case
			case _cOpc = '1'
			VTAlert('Em construção!:3','Atencao',.T.,2000,1)
			exit
			case _cOpc = '2'
			u_GFVT01()
			case _cOpc = '3'
			VTAlert('Em construção!:3','Atencao',.T.,2000,1)
			exit
			case _cOpc = '4'
			VTAlert('Em construção!:4','Atencao',.T.,2000,1)
			exit

		endcase
	EndDo      

	_lOk := .t.

Return


