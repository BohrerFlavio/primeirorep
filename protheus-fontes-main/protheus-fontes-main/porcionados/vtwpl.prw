#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³vtWPL     º Autor ³Giuliano Forgiariniº   Data ³  15/01/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para de p/ selecionar º±±
±±º          ³ lotes e aponta-los nas linhas de produção  					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Porcionados                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


//Tela de Abertura do coletor
User Function vtWPL()          
	Private _cModelo := ''
	Private _lOk     := .t.
	Private _cOper   := Space(01) 
	Private _cOper2  := Space(01) 

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'ZAU','ZAS','ZAR'

	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	while _lOk

		_cOper := Space(01)  

		@ 01,00    VTSay "Apontamento e controle de    "
		@ 02,00    VTSay "produção linhas porcionados: "     
		@ 03,00    VTSay "                             "    
		@ 04,00    VTSay "                             "  
		@ 05,00    VTSay "LINHA:     [ ]               "
		@ 06,00    VTSay "                             "    
		@ 07,00    VTSay "Operação:  [ ]               "  	
		@ 08,00    VTSay "1 - Apontamento de lotes WPL "    
		@ 09,00    VTSay "2 - Reinicialização Testeira "  
		@ 16,00 VTSay "ESC para Sair"

		@ 05,12 VTGet _cOper  Pict "@!" VALID (_cOper $ "1/2/3/4")	
		@ 07,12 VTGet _cOper2 Pict "@!" VALID (_cOper $ "1/2")	
		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		_cOper  := alltrim(_cOper)    
		_cOper2 := alltrim(_cOper2)    

		if _cOper2 = '1'
			ProdLin(_cOper) 
		elseif _cOper2 = '2'
			RestLin(_cOper)
		endif     

		VTCLear()
		VTClearBuffer()
	enddo

	VTCLear()
	VTClearBuffer()

	RESET ENVIRONMENT
Return  

//Função de produção das linhas
Static Function ProdLin(_linha)          

	Private _lOk2    := .t.
	Private _cOpc1   := Space(01)   
	Private _cOpc2   := Space(01)   
	Private _loWPL   := space(10)
	Private _loTes   := space(10)
	Private _DesWPL  := space(10)
	Private _DesTes  := space(10)
	Private _StatWPL := space(10)
	Private _StatTes := space(10)
	Private _lRetBrWPL := .t.
	Private _lRetBrTes := .t.

	_lRetBrTes := .t.
	_lRetBrTes := .t.

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer() 

	while _lOk2

		@ 01,00    VTSay "LINHA DE EMBALAGEM 0" + _linha 	


		ZAU->(DbSetOrder(3))
		if ZAU->(DbSeek(xfilial('ZAU') +  '00' + _cOper ))    
			_loWPL    := ZAU->ZAU_NUM
			_DesWPL   := ZAU->ZAU_DESC
			_StatWPL  := 'Produção'   
			_cOpc1    := '1'  
		else
			_loWPL    := space(10)
			_DesWPL   := space(10)
			_StatWPL  := 'Ociosa'
			_cOpc1    := '2'    
		endif

		ZAU->(DbSetOrder(4))
		if ZAU->(DbSeek(xfilial('ZAU') +  '00' + _cOper ))    
			_loTes    := ZAU->ZAU_NUM
			_DesTes   := ZAU->ZAU_DESC
			_StatTes  := 'Produção'
			_cOpc2    := '1'  
		else
			_loTes    := space(10)
			_DesTes   := space(10)
			_StatTes  := 'Ociosa'
			_cOpc2    := '2'
		endif


		TelaProd()

		_OperAntWPL := _cOpc1
		_OperAntTes := _cOpc2

		if _cOper $ '1/3'  
			@ 03,16 VTGet _loWPL Pict "@!" VALID BrowWPL() 
			@ 06,25 VTGet _cOpc1 Pict "@!" VALID OperWPL(ZAU->ZAU_NUM, '00' + _cOper,_cOpc1)

			@ 09,16 VTGet _loTes Pict "@!" VALID BrowTes()
			@ 12,25 VTGet _cOpc2 Pict "@!" VALID OperTes(ZAU->ZAU_NUM, '00' + _cOper,_cOpc2)
			VTRead         
		else  

			@ 03,16 VTGet _loTes Pict "@!" VALID BrowTes()
			@ 06,25 VTGet _cOpc2 Pict "@!" VALID OperTes(ZAU->ZAU_NUM, '00' + _cOper,_cOpc2)
			VTRead    
		endif

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF


		VTCLear()
		VTClearBuffer()
	enddo

	VTCLear()
	VTClearBuffer()


Return 


Static Function TelaProd(_linha) 

	VTClear()
	VTClearBuffer() 

	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif  


	if _cOper $ '1/3'

		@ 03,00    VTSay "Lote WPL:      [" + _loWPL + "]" 
		@ 04,00    VTSay "Produto: " + _DesWPL
		@ 05,00    VTSay "Status: " + _StatWPL    
		@ 06,00    VTSay "Operação:               ["+_cOpc1+ "]"	

		@ 09,00    VTSay "Lote Testeira: [" + _loTes + "]" 
		@ 10,00    VTSay "Produto: " + _DesTes
		@ 11,00    VTSay "Status: " + _StatTes       
		@ 12,00    VTSay "Operação:               ["+_cOpc2+ "]"	
	else
		@ 03,00    VTSay "Lote Testeira: [" + _loTes + "]" 
		@ 04,00    VTSay "Produto: " + _DesTes
		@ 05,00    VTSay "Status: " + _StatTes   
		@ 06,00    VTSay "Operação:               [ ]"	
	endif       

	@ 15,00    VTSay "1 - Producao   2 - Ociosa "
	@ 16,00    VTSay "ESC para Sair"

return                     

//VTBrowse para lote na WPL
Static Function BrowWPL()

	//Define o tamanho da Tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	aFields := {"ZAU_NUM","ZAU_COD","ZAU_DTPROD","ZAU_DESC"}
	aHeader := {"NUM","COD","DATA","DESC"}
	aSize   := {10,06,08,20}

	dbselectarea('ZAU')
	ZAU->(dbgotop()) 
	ZAU->(DbSetOrder(2))
	ZAU->(DbSeek(xfilial('ZAU') + dtos(DDATABASE),.f.))
	//mostra o grid na tela  

	SET FILTER TO !(ZAU->ZAU_STATW $ "E/R") .and. ZAU->ZAU_DTPROD = DDATABASE .And. ZAU_STATUS <> 'E'   

	nRetBrow := VTDBBrowse(1,1,16,30,"ZAU",aHeader,aFields,aSize,"u_vtBrWPL",)

	if _lRetBrWPL

		_loWPL   := ZAU->ZAU_NUM
		_DesWPL  := ZAU->ZAU_DESC
		_StatWPL := iif(!empty(ZAU->ZAU_LINW),'Produção','Ociosa')

		_loTes   := ZAU->ZAU_NUM
		_DesTes  := ZAU->ZAU_DESC
		_StatTes := iif(!empty(ZAU->ZAU_LINT),'Produção','Ociosa')
	endif

	VTClear()
	VTClearBuffer()

	TelaProd()

return      


//VTBrowse para lote na Tes
Static Function BrowTes()

	//Define o tamanho da Tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	aFields := {"ZAU_NUM","ZAU_COD","ZAU_DTPROD","ZAU_DESC"}
	aHeader := {"NUM","COD","DATA","DESC"}
	aSize   := {10,06,08,20}

	dbselectarea('ZAU')
	ZAU->(dbgotop()) 
	ZAU->(DbSetOrder(2))
	ZAU->(DbSeek(xfilial('ZAU') + dtos(DDATABASE),.f.))
	//mostra o grid na tela  

	SET FILTER TO !(ZAU->ZAU_STATT $ "E/R") .and. ZAU->ZAU_DTPROD = DDATABASE .And. ZAU_STATUS <> 'E'   

	nRetBrow := VTDBBrowse(1,1,16,30,"ZAU",aHeader,aFields,aSize,"u_vtBrTes",)

	if _lRetBrTes
		_loTes   := ZAU->ZAU_NUM
		_DesTes  := ZAU->ZAU_DESC
		_StatTes := iif(!empty(ZAU->ZAU_LINT),'Produção','Ociosa')
	endif

	VTClear()
	VTClearBuffer()

	TelaProd()

return      

//Função do VTBrowse para WPL
User Function vtBrWPL()  
	if VTLastkey()==27  
		_lRetBrWPL := .f.
		return 0
	elseif VTLastkey()==13  
		_lRetBrWPL := .t.
		return 1
	endif
return

//Função do VTBrowse para Testeira
User Function vtBrTes()  
	if VTLastkey()==27    
		_lRetBrTes := .f.
		return 0
	elseif VTLastkey()==13  
		_lRetBrTes := .t.
		return 1
	endif
return       


//Função de validação da operação WPL
Static Function OperWPL(_lote,_linha,_cOpc)
	Local _RetOper := .f.

	_device := iif(_linha  = '1',1,2)

	if _OperAntWPL <> _cOpc
		if _cOpc = '1'
			if u_WBiz03(_lote,_device)  

				reclock('ZAU',.f.)
				ZAU->ZAU_LINW := '00' + _linha
				msunlock()     

				_RetOper := .t.   	
			endif
		elseif _cOpc = '2'
			if u_WBiz04(_lote,_device)

				reclock('ZAU',.f.)
				ZAU->ZAU_LINW := ''
				msunlock()        

				_RetOper := .t.
			endif
		endif
	endif

return _RetOper

//Função de validação da operação Testeira
Static Function OperTes(_cOpc)
	Local _RetOper := .t.

	if _OperAntTes <> _cOpc
		if _cOpc = '1'

			reclock('ZAU',.f.)
			ZAU->ZAU_LINT := '00' + _linha
			msunlock()     

			_RetOper := .t.   	

		elseif _cOpc = '2'

			reclock('ZAU',.f.)
			ZAU->ZAU_LINT := ''
			msunlock()        

			_RetOper := .t.

		endif
	endif

return _RetOper          

//Rotina para Restart das testeiras
Static Function RestLin(_linha)
	do case
		case _linha == 1//reinicia a linha 001

			WaitRunSrv( "taskkill /f /im appserver-PORLIN1.exe" , .T. , "e:\" )

			sleep(25000)

			WaitRunSrv( "net start TotvsProtheusOficialPORLIN1" , .T. , "e:\" )

		case _linha == 2//reinicia a linha 002		

			WaitRunSrv( "taskkill /f /im appserver-PORLIN2.exe" , .T. , "e:\" )

			sleep(25000)

			WaitRunSrv( "net start TotvsProtheusOficialPORLIN2" , .T. , "e:\" )

		case _linha == 3	//reinicia a linha 003	

			WaitRunSrv( "taskkill /f /im appserver-PORLIN3.exe" , .T. , "e:\" )

			sleep(25000)

			WaitRunSrv( "net start TotvsProtheusOficialPORLIN3" , .T. , "e:\" )

		case _linha == 4 //reinicia a linha 004		

			WaitRunSrv( "taskkill /f /im appserver-PORLIN4.exe" , .T. , "e:\" )

			sleep(25000)

			WaitRunSrv( "net start TotvsProtheusOficialPORLIN4" , .T. , "e:\" )

	endcase    

		VTAlert('Reinicialização das Testeiras!','OK!',.T.,3000,1)  
return	
