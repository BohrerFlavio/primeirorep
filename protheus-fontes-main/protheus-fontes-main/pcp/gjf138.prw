#INCLUDE "rwmake.ch" 
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF138    º Autor ³ Giuliano Forgiariniº Data ³  26¹04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Limpeza de estoque de peças                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF138()
	local nOpca	:=0
	local aSays:={}, aButtons:={}

	Private cCadastro := "Limpeza de Estoque de Peças"
	Private _lOk      := .t.
	Private cPerg     := "GJF138"

	AADD (aSays, "  Esta rotina tem como objetivo realizar o ajuste do estoque de ")  //
	AADD (aSays, "  peças (traseiro, dianteiro e costela) de modo a limpar estes  ")  //
	AADD (aSays, "  dos 10 dias anteriores à data base.                           ")  //
	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )                                                                  
	FormBatch( cCadastro, aSays, aButtons ) 

	Pergunte(cPerg,.f.)

	If nopca == 1  
		Processa({||Limpeza() },"LIMPEZA DE ESTOQUE DE PEÇAS","Realizando processamento dos dados...")  
	endif

return 

Static Function Limpeza()

	DbSelectArea('SZG')
	SZG->(DbSetOrder(2))
	SZG->(DbGoTop())
	SZG->(DbSeek(xfilial('SZG')+dtos(mv_par01-mv_par02),.t.))   

	if mv_par01 >= ddatabase 
		msgbox('A data deverá ser menor que a data base do sistema','DATA INVALIDA!','ERRO')
		return
	endif

	if !msgbox('O processo de limpeza dará início a partir do abate do dia ' + DTOC(SZG->ZG_DATA)+'. Continuar?','INICIO DE PROCESSAMENTO','YESNO')
		return
	endif


	While SZG->(!eof()) .and. SZG->ZG_FILIAL = xfilial('SZG') .and. SZG->ZG_DATA <= mv_par01

		ProcRegua(SZG->ZG_QTDTOT)

		SZK->(DbSetOrder(4))

		if SZK->(DbSeek(xfilial('SZK')+SZG->ZG_NUMAM))
			While  SZK->(!eof()) .and. SZK->ZK_FILIAL = xfilial('SZK') .and. SZK->ZK_NUMAM = SZG->ZG_NUMAM

				incproc('Processando abate nº ' + SZK->ZK_NUMAM + ': carcaça nº: ' + SZK->ZK_CONTROL)

				reclock('SZK',.f.)
				SZK->ZK_PROCD := 2
				SZK->ZK_PROCT := 2
				SZK->ZK_PROCC := 2
				msunlock()

				SZK->(DbSkip())
			enddo
		endif     

		SZG->(DbSkip())
	enddo
Return

