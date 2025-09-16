#INCLUDE "PROTHEUS.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"

User Function GJF180()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ GJF180 ³ Autor ³ Giuliano Forgiarini     ³ Data ³ Ago/2013 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Rotina para controle de acionamento do sistema de rejeite  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³Automação embalagens                                        ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/


	//RpcSetType(3) 	// Executa via job para nao consumir licensas

	WFPrepEnv('01', '00',, {"SZV","SZ8"}, "ACD")
	
	aTables := {'SZV','SZ8'}
	RPCSetEnv('01','00',,,"ACD","U_GJF180",aTables,,,,)
	

	//Inicia a DLL para ativação da rele


	while .t.

		cBuffer1 := "Executando a partir da ExeDllRun1..."
		cBuffer2 := "Executando a partir da ExeDllRun2..." 
		cBuffer3 := "Executando a partir da ExeDllRun3..."
		cBuffer4 := "Executando a partir da ExeDllRun4..."

		_lRej01  := _LeParam("SI_REJ01")
		_lRej02  := _LeParam("SI_REJ02")

		//Verifica status do rejeite da linha 01
		if  _lRej01
			PutMv('SI_REJ01',.F.)
			_nHd := ExecInDllOpen('rele.dll')
			cRetDLL := ExecInDllRun3( _nHd, 1, cBuffer1 )
			ExecInDLLClose(_nHd)
		endif
		//Verifica status do rejeite da linha 02
		if _lRej02
			PutMv('SI_REJ02',.F.)
			_nHd := ExecInDllOpen('rele.dll')
			cRetDLL := ExecInDllRun3( _nHd, 3, cBuffer3 )
			ExecInDLLClose(_nHd)	
		endif

		//Se alguma relé for ativada, aguarda 1500 milissegundos
		if _lRej01 .or. _lRej02
			sleep(1500)            
		endif

		//Desliga relé linha 01
		if  _lRej01
			_nHd := ExecInDllOpen('rele.dll')			
			cRetDLL := ExecInDllRun3( _nHd, 2, cBuffer2 )
			ExecInDLLClose(_nHd)
		endif

		//Desliga relé linha 02
		if _lRej02               
			_nHd := ExecInDllOpen('rele.dll')			
			cRetDLL := ExecInDllRun3( _nHd, 4, cBuffer4 )	
			ExecInDLLClose(_nHd)	 
		endif

	enddo

	RpcClearEnv()

Return


Static Function _LeParam(_cNomPar)

	_Conteudo := GetMV(_cNomPar)

Return(_Conteudo)


Static Function Mensagem()

	DEFINE MSDIALOG oDlg2 TITLE 'Acionamento de Rejeite' from 000,000 To 150,250 OF oMainWnd PIXEL  

	@ 021,002 SAY  'Verificando funcionamento...' Object oSay1

	ACTIVATE MSDIALOG oDlg2       
return
