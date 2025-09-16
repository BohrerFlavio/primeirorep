#INCLUDE "Rwmake.ch"
#INCLUDE "Totvs.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณvtPorc01     บ Autor ณMauricio Roehrsบ   Data ณ  29/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Aplica็ใo para microterminais VT-100 para de p/ selecionar บฑฑ
ฑฑบ          ณ qual rotina serแ executada nos porcionados				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


//Tela de Abertura do coletor
User Function vtPorc01()          
	Private _cModelo := ''
	Private _lOk     := .t.
	Private _cOper   := ''

	//RPCSetType(3) //nใo consome licen็a.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'ACD' TABLES 'ZAA','ZAS','ZAR'

	dGetData := MSDate()
	TRealIni := Time()

	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	aUser     := VTGetsenha(@dGetData,TRealIni) 
	_cCodUser := aUser[1,1]                    

	//VTAlert(aUser[1,1],'Aviso de Encerramento(01)',.T.,500,1)

	DbSelectArea('ZAA')
	ZAA->(DbSetOrder(2))
	if !ZAA->(DbSeek(xfilial('ZAA')+_cCodUser))
		VTAlert('Usuแrio nใo habilitado!','Aviso',.T.,500,1)
		return
	endif

	DbSelectArea('ZAA')
	ZAA->(DbSetOrder(2))
	if ZAA->(DbSeek(xfilial('ZAA')+_cCodUser))
		if ZAA->ZAA_STATUS == 'B'
			VTAlert('Usuแrio Bloqueado!','Aviso',.T.,500,1)  
			return
		endif
	endif	
	VTClear()
	VTClearBuffer()
	while _lOk

		_cOper:=Space(02)
		@ 01,00    VTSay "Digite a op็ใo de opera็ใo   "
		@ 02,00    VTSay "a ser realizada no processo: "     
		@ 03,00    VTSay "                             "    
		@ 04,00    VTSay "                             "  
		_nlin := 5 
		@ _nlin,00 VTSay "OPERAวรO: [  ]               "
		_nlin++                                      	
		/*if ZAA->ZAA_APL13 = 'S' 
			@ _nlin,00 VTSay "01 - Consumo de Mat. Prima"
			_nlin++                                       
		endif*/
		if ZAA->ZAA_APL14 = 'S' 
			@ _nlin,00 VTSay "02 - Consumo p/ Carne Moida"
			_nlin++                                       
		endif

		if ZAA->ZAA_APL15 = 'S' 
			@ _nlin,00 VTSay "03 - Saida do Pulmao"
			_nlin++                                       
		endif

		if ZAA->ZAA_APL19 = 'S'
			@ _nlin,00 VTSay "04 - Separa็ใo de Caixas      "
			_nlin++
		endif


		if ZAA->ZAA_APL20 = 'S'
			@ _nlin,00 VTSay "05 - Apontamento Producao     "
			_nlin++
		endif

		if ZAA->ZAA_APL11 = 'S'
			@ _nlin,00 VTSay "06 - Devolucoes               "
			_nlin++
		endif	

		if ZAA->ZAA_APL26 = 'S'
		//if ZAA->ZAA_APL25 = 'S'
			@ _nlin,00 VTSay "07 - Consumo de PA               "
			_nlin++
		endif	

		@ 16,00 VTSay "ESC para Sair"

		//@ 05,11 VTGet _cOper Pict "@!" VALID (_cOper $ "01/02/03/04/05/06/07")
		@ 05,11 VTGet _cOper Pict "@!" VALID (_cOper $ "02/03/04/05/06/07")

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplica็ใo Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		_cOper := alltrim(_cOper)    
		do case
			/*case _cOper == '01'     //Consumo Materia-Prima
			u_vtPorc02(_cCodUser)*/
			case _cOper == '02'     //Consumo p/ Carne Moida
			u_vtPorc03(_cCodUser) 										
			case _cOper == '03'     //Saida de Carne Refilada/Quebras
			u_vtPorc04(_cCodUser) 											
			case _cOper == '04'     //Separa็ใo de Caixas
			u_mrvt15(_cCodUser)										
			case _cOper == '05'     //Apont.Prod. Final Tavil
			u_vtPorc05(_cCodUser)		 
			case _cOper == '06'     //Devolucoes
			u_mrvt10(_cCodUser)	
			case _cOper == '07'     //Consumo PA
			u_vtPorc07(_cCodUser)											
			otherwise
			VTAlert('Opcao invalida!','ATENCAO!',.T.,500,1)
		endcase

		VTCLear()
		VTClearBuffer()
	enddo

	VTCLear()
	VTClearBuffer()

	RESET ENVIRONMENT
Return  

//Bloco para testes
/*
User Function MRVT00()          
RPCSetType(3) //nใo consome licen็a.
PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'SZG','SZK','SZ4','SZD','SZE','SZ8','SB1','ZAA','SZP'

_cModelo = VTModelo()

if _cModelo <> 'RF'
VTSetSize(2,16)
else
VTSetSize(20,30)
endif

VTClear()
VTClearBuffer() 
_cOper  := space(02)
_cOper2 := space(02)   
while .t.
@ 01,01 VTSay "Teste de Teclado: [  ]"
@ 02,01 VTSay "Teste de Teclado: [  ]"

@ 01,20 VTGet _cOper  Pict "@!"  valid (VTlastkey() <> 0)
@ 02,20 VTGet _cOper2 Pict "@!"  valid TestaKey(_cOper2)
VTRead     


VTAlert('Aplica็ใo Finalizada!',VTlastkey(),.T.,3000,1) 
if !empty(_cOper )
exit
endif	
enddo

//VTAlert('Aplica็ใo Finalizada!',Inkey(),.T.,3000,1) 
RESET ENVIRONMENT
return

static function TestaKey(_cOper2)

_cOper2 = VTlastkey() 

VTAlert('Aplica็ใo Finalizada!',_cOper2,.T.,3000,1) 	

return .f.
*/
