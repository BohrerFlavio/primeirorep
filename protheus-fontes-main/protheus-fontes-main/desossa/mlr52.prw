#INCLUDE "PROTHEUS.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"

User Function MLR52()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ MLR52 ³ Autor ³ Mauricio Roehrs     ³ Data ³ 05/08/2015    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Rotina para controle de acionamento do sistema de rejeite  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³desossa				                                      ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/


	//RpcSetType(3) 		// Executa via job para nao consumir licensas

	//WFPrepEnv('01', '00',, {"ZAJ","SZ2"}, "PCP")
	aTables := {'ZAJ','SZ2'}
	RPCSetEnv('01','00','industria','industria',"ACD","U_MLR52",aTables,,,,)

	putmv('SI_REJ05','')	
	putmv('SI_ULTI','')
	//putmv('SI_REJTE2','')//Dia 20/12 - Flávio para teste

	//Inicia a DLL para ativação da rele
	while .t.


		cBuffer1 := "Executando a partir da ExeDllRun1..."
		cBuffer2 := "Executando a partir da ExeDllRun2..."
		// X6_VAR Igual a 'SI_REJTE  ' or X6_VAR Igual a 'SI_REJ05  '
		_cRej  := _GetParam()
	
		if !empty(_cRej)	        
			//liga a rele 1                       
			if alltrim(_cRej) == '2'		                    
				_nHd     := ExecInDllOpen('rele.dll')
				//cRetDLL  := ExeDLLRun3(_nHd,1,@cBuffer1) 
				//conout('Linha 47 acessou')
				cRetDLL := ExecInDllRun3( _nHd, 1, cBuffer1 )	//Dia 20/12 - Flávio para teste
				ExecInDLLClose(_nHd)	
				//conout('Linha 50 -> Executa 1')
				//desliga a rele 1	
			elseif alltrim(_cRej) == '1'
				_nHd     := ExecInDllOpen('rele.dll')
				//cRetDLL  := ExeDLLRun3(_nHd,2,@cBuffer2) 
				cRetDLL := ExecInDllRun3( _nHd, 2, cBuffer2 )	//Dia 20/12 - Flávio para teste
				//conout('Linha 56 -> Executa 2')
				ExecInDLLClose(_nHd)		
			endif  

			//putmv('SI_REJ05','')		
			putmv('SI_REJ05','')		
			
			
			//putmv('SI_REJTE2','')	//Dia 20/12 - Flávio para teste	
		endif           

	enddo

	RpcClearEnv()

Return


Static Function Mensagem()

	DEFINE MSDIALOG oDlg2 TITLE 'Acionamento de Rejeite' from 000,000 To 150,250 OF oMainWnd PIXEL  

	@ 021,002 SAY  'Verificando funcionamento...' Object oSay1

	ACTIVATE MSDIALOG oDlg2       
return     


Static Function _GetParam()

	_cRet := GetMV('SI_REJ05')

Return(_cRet)

