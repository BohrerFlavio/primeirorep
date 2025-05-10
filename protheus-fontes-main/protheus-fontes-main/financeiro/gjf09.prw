#INCLUDE "topconn.ch"  
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch" 
/*
±±ºPrograma  ³GJF09     ºAutor  ³Giuliano Forgiarini º Data ³  26/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza bloqueio para movimentação comercial e financeira   º±±
±±º          ³dos clientes avaliados junto ao seu cadastro                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Financeiro                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF09()

	LOCAL nOpca	:=0
	LOCAL aSays:={}, aButtons:={}                            

	Private _nDUltCom := 0           //Número de dias da ultima compra         
	Private _dEmiss   := ddatabase   //data de emissao de titulo
	Private _nDiasAtr := 0           //Número de dias de atrazo para comparar com data de vencimento   
	Private _periodo  := ctod('')     

	Private cCadastro := "Bloqueio de Clientes"

	cPerg := "GJF09"
	Pergunte(cPerg,.f.)
	AADD (aSays, "  Este programa tem como objetivo bloquear os clientes que possuem  ")  //
	AADD (aSays, "  títulos em atraso, conforme o número de dias, a data de emissão   ")  //
	AADD (aSays, "  dos títulos a receber ou os dias da ultima venda definidos nos    ")
	AADD (aSays, "  parâmetros dessa rotina.                                          ")  //

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )
	If nopca == 1  
		Processa({|| RunProc()}, "Aguarde...", "Verificando situação de clientes...",.T.)     
	Endif
Return

//Rotina de processamento
Static Function RunProc()

	//Determina os parametros para
	//verificação pela última compra
	if mv_par01 = 1    
		DEFINE MSDIALOG oDlg2 TITLE 'Ultima Compra' from 000,000 To 150,250 OF oMainWnd PIXEL  

		@ 009,002 SAY  'Periodo de Verificação:' Object oSay1
		@ 009,065 GET _nDUltCom  SIZE 50,10 PICTURE "@E 99"  Object oUltCom

		@ 055,090 BMPBUTTON TYPE 1 ACTION odlg2:end() Object Obtn2
		ACTIVATE MSDIALOG oDlg2   
	endif

	//Determina os parametros para
	//verificação pelo vencimento
	//dos títulos
	if mv_par02 = 1   
		DEFINE MSDIALOG oDlg2 TITLE 'Vencimento Titulos:' from 000,000 To 150,250 OF oMainWnd PIXEL  

		@ 009,002 SAY  'Data de Emissao:'    Object oSay1 
		@ 021,002 SAY  'Nr. Dias de Atraso:' Object oSay2
		@ 009,065 GET _dEmiss    SIZE 50,10 PICTURE "@E 99/99/99"  Object oEmiss
		@ 021,065 GET _nDiasAtr  SIZE 50,10 PICTURE "@E 99"        Object oDiasAtr  


		@ 055,090 BMPBUTTON TYPE 1 ACTION odlg2:end() Object Obtn2
		ACTIVATE MSDIALOG oDlg2   
	endif

	//Determina os parametros para
	//verificação da condição de pagamento
	if mv_par03 = 1      

	endif

	dbselectarea("SA1")
	SA1->(dbsetorder(1))
	SA1->(dbgotop())

	ProcRegua(SA1->(RecCount()) ) 

	while SA1->(!Eof()) 

		incproc('Cliente ' + alltrim(SA1->A1_COD) + ' loja ' + alltrim(SA1->A1_LOJA) + '...')  

		// Não processa cliente VT Sistemas (Hotmedia), pois é cliente de testes dos meios de pagamento
		if SA1->A1_COD == "021350" .And. SA1->A1_LOJA == "01"
			SA1->(DbSkip())
			Loop
		endif
		
		//a linha de baixo serve tanto apra a primeira
		//verificação quanto para a segunda...
		_periodo := ddatabase - SA1->A1_ULTCOM

		if mv_par01 = 1  
			Proc01()   
		endif
		if mv_par02 = 1
			Proc02()   
		endif
		if mv_par03 = 1  
			Proc03()   
		endif
		if mv_par04 = 1  
			Proc04()   
		endif

		SA1->(DbSkip())
	enddo

return

//Função de processamento 01:
//bloqueio pela data da ultima compra
//conforme o número de dias de atraso determinado
Static Function Proc01()

	if  !empty(SA1->A1_ULTCOM) .and. _nDUltCom <> 0  
		if _periodo >= _nDUltCom
			reclock('SA1',.f.)
			SA1->A1_SIBLQL  := "1"
			SA1->A1_SIMOTBL := 'ULTIMA COMPRA'
			SA1->A1_SIDTBL  := ddatabase

			SA1->A1_MSBLQL  := "1"
			SA1->A1_MOTBLQL := 'ULTIMA COMPRA'
			SA1->A1_DTBLQL  := ddatabase

			SA1->A1_POBLQL  := "1"      
			SA1->A1_POMOTBL := 'ULTIMA COMPRA'
			SA1->A1_PODTBL  := ddatabase
			msunlock()
		endif

		//end 
	elseif empty(SA1->A1_ULTCOM)
		reclock('SA1',.f.)
		SA1->A1_SIBLQL  := "1"
		SA1->A1_SIMOTBL := 'NENHUMA COMPRA EFETUADA'
		SA1->A1_SIDTBL  := ddatabase

		SA1->A1_MSBLQL  := "1"
		SA1->A1_MOTBLQL := 'NENHUMA COMPRA EFETUADA'
		SA1->A1_DTBLQL  := ddatabase

		SA1->A1_POBLQL  := "1"      
		SA1->A1_POMOTBL := 'NENHUMA COMPRA EFETUADA'
		SA1->A1_PODTBL  := ddatabase
		msunlock()

	endif			

Return


//Função de processamento 02:
//bloqueio pela data de vencimento dos títulos
//conforme o número de dias de atraso determinado
Static function Proc02()

	if !empty(_dEmiss)



		_cQuery := " SELECT *  FROM " + RetSQLTab('SE1')
		_cQuery += " WHERE " + RetSQLFil('SE1')
		_cQuery += " AND E1_CLIENTE = '" + SA1->A1_COD + "' AND  E1_LOJA = '" + SA1->A1_LOJA + "' AND E1_BAIXA = '' AND E1_TIPO NOT IN ('NCC','RA') "
		_cQuery += " AND E1_EMISSAO >= '" + dtos(_dEmiss) + "'"
		_cQuery += " AND " + RetSQLDel('SE1')

		_cQuery := ChangeQuery(_cQuery)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		If Select("VER")<>0
			VER->(dbCloseArea())
		Endif

		TCQUERY _cQuery NEW ALIAS "VER"

		VER->(DbGoTop())
		while VER->(!eof())

			_atraso := ddatabase - stod(VER->E1_VENCREA)

			if _atraso >= _nDiasAtr

				reclock('SA1',.f.)
				SA1->A1_MSBLQL  := "1"
				SA1->A1_MOTBLQL := 'TITULOS VENCIDOS'
				SA1->A1_DTBLQL  := ddatabase

				SA1->A1_POBLQL  := "2"

				msunlock()

				exit
//			else			
//				reclock('SA1',.f.)
//				SA1->A1_MSBLQL  := "2"
//				SA1->A1_MOTBLQL := ''
//				SA1->A1_DTBLQL  := stod('')
//				SA1->A1_POBLQBL  := "2"
//				msunlock()
			endif

			VER->(DbSkip())
		enddo

	endif

return



//Função de processamento 03:
//Bloqueio de acordo com a condição de pagamento
//apontada no cadastro do cliente
Static Function Proc03()


	if SA1->A1_COND $ '001/141'
		reclock('SA1',.F.)

		SA1->A1_SIBLQL  := "2"
		//SA1->A1_SIMOTBL := 'CONDICAO PAGAMENTO'
		//SA1->A1_SIDTBL  := ddatabase
		SA1->A1_SIMOTBL := ''
		SA1->A1_SIDTBL  := STOD('')

		SA1->A1_MSBLQL  := "1"
		SA1->A1_MOTBLQL := 'CONDICAO PAGAMENTO'
		SA1->A1_DTBLQL  := ddatabase

		msunlock()
	endif

Return



//Função de processamento 04:
//Bloqueio de acordo com a situação no SEFAZ
Static Function Proc04()
	Local sit := ''


	if SA1->A1_EST = 'RS' .and. !(SA1->A1_INSCR $ 'ISENTO')

		sit := u_GJF173(SA1->A1_COD,SA1->A1_LOJA,3)
		if sit = 'B'
			reclock('SA1',.f.)
			SA1->A1_SIBLQL  := "1"
			SA1->A1_SIMOTBL := 'SEFAZ'
			SA1->A1_SIDTBL  := ddatabase

			SA1->A1_MSBLQL  := "1"
			SA1->A1_MOTBLQL := 'SEFAZ'
			SA1->A1_DTBLQL  := ddatabase

			SA1->A1_POBLQL  := "1"      
			SA1->A1_POMOTBL := 'SEFAZ'
			SA1->A1_PODTBL  := ddatabase
			msunlock()
		endif

	endif

Return
