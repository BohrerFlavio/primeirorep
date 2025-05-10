#INCLUDE "PROTHEUS.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "rwmake.ch"

User Function GJF175()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ GJF175 ³ Autor ³ Giuliano Forgiarini     ³ Data ³ Ago/2013 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Rotina para controle de acionamento do sistema de rejeite  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³Automação embalagens                                        ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local _cEmp := IIF(_cEmpFil==Nil,"01",Substr(_cEmpFil,1,2))
	Local _cFil := IIF(_cEmpFil==Nil,"00",Substr(_cEmpFil,3,2))

	RpcSetType(3) 		// Executa via job para nao consumir licensas

	WFPrepEnv( _cEmp, _cFil,, {"SZV","SZ8"}, "PCP")

	Mensagem()

	//Inicia a DLL para ativação da rele
	_nHd := ExecInDllOpen('rele.dll')  

	if _nHd = -1  
		//falha 4
		return
	endif

	while .t.

		_lRej01  := _LeParam("SI_REJ01")
		_lRej02  := _LeParam("SI_REJ02")

		if _nHd = -1
			//falha 4
			return
		endif

		//Verifica status do rejeite da linha 01
		if _lRej01
			PutMv('SI_REJ01',.F.)
			cRetDLL := ExecInDLLRun( _nHd,1,'')
			sleep(1500)
			cRetDLL := ExecInDLLRun( _nHd,2,'')
		endif

		//Verifica status do rejeite da linha 02
		if _lRej02
			PutMv('SI_REJ02',.F.)
			cRetDLL := ExecInDLLRun( _nHd,3,'')
			sleep(1500)
			cRetDLL := ExecInDLLRun( _nHd,4 ,'')
		endif
	enddo

	MsClosePort(nHdll) 

	RpcClearEnv()

Return


Static Function _LeParam(_cNomPar)

	_Conteudo := GetMV(_cNomPar)

Return(_Conteudo)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da função _Log para histórico das atualizações       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Log (_sTexto)

	Local _nHdl    := 0
	Local _sArqLog := "atualizacao_moedas.log"

	If File (_sArqLog)
		_nHdl = fopen(_sArqLog, 1)
	Else
		_nHdl = fcreate(_sArqLog, 0)
	Endif

	fseek (_nHdl, 0, 2)  		// Encontra final do arquivo
	fwrite (_nHdl, _sTexto + chr (13) + chr (10))
	fclose (_nHdl)

Return



Static Function Mensagem()

	DEFINE MSDIALOG oDlg2 TITLE 'Acionamento de Rejeite - Embalagem' from 000,000 To 150,250 OF oMainWnd PIXEL  
	@ 009,002 SAY  'Data de Produção:' Object oSay1
	@ 021,002 SAY  'Data Real de Produção:' Object oSay2
	@ 033,002 SAY  'Prev. Produção Desossa:' Object oSay3
	ACTIVATE MSDIALOG oDlg2   
