#INCLUDE "PROTHEUS.CH"


	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ AJCMU ³ Autor ³ Flávio BOhrer Flôres     ³ Data ³ Fev/2020 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Rotina feita para eliminar os registros que  estiverem com ³±±
	±±³          ³ o campo CMU_VLGILR = zero                                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Frigorífico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Data      ³ Programador   ³ Manutencao Efetuada                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

User Function AJCMU()
	
	Local aArea := GetArea()
	Local oBrowse
	Local cNum := ''
	Local _nCont := 0 
	Local _nDesconto := 0 
	Local nVAqui := 0 
	Private cPerg	:= "AJCMD"
	// Criar parâmetros  Fintro da CMU_IP e també cuidar para atualizar a tabela CMT
	if !pergunte(cPerg,.t.)
		ret
	endif
		
	CMU->(dbGoTop())
	CMU->(DbSetOrder(1))
	CMU->(DbSeek(xFilial("CMU") + alltrim(MV_PAR01)))

	While CMU->(!EOF()) .AND. CMU->CMU_ID = alltrim(MV_PAR01)
	
		If CMU->CMU_VLGILR = 0
			_nDesconto := _nDesconto + CMU->CMU_VLBRUT
			RecLock("CMU",.F.)
			DbDelete()
			MsUnlock()
			_nCont++
		Endif
		RecLock("CMU",.F.)
			CMU->CMU_INDCP := '1'	
		MsUnlock()
		
		CMU->(DbSkip())
		
	Enddo
	
	CMT->(dbGoTop())
	CMT->(DbSetOrder(1))
	
	if CMT->(DbSeek(xFilial("CMT") + alltrim(MV_PAR01)))
	
		nVAqui := CMT->CMT_VLAQUI
		RecLock("CMT",.F.)
			CMT->CMT_VLAQUI := nVAqui - _nDesconto	
		MsUnlock()
	Endif
	
Return Nil
