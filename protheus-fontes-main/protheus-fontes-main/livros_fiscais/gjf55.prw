#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF55     º Autor ³ Giuliano Forgiariniº Data ³  10/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de ajuste do fator de conversão no cadastro de      º±±
±±º          ³ produtos para geração de arquivos de SPED                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF55()
	Private nOpca	 :=0
	Private _lProc  := .f.
	Private _lOk    := .t.


	DEFINE MSDIALOG oDlg TITLE "Ajuste do Fator de Conversão para SPED" From 9,0 To 200,400 PIXEL

	TButton():New(040,050,  "Ajustar" , oDlg,{|| _lProc := .t.,oDlg:end() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(040,110, "Sair"   , oDlg,{|| oDlg:end() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED

	if _lProc
		Processa({||Ajustar(SB1->B1_COD)},"FATOR DE CONVERSÃO","Realizando ajuste no cadastro de produtos..." )
	endif

return

Static Function Ajustar()

	_cStatus := GetMV('SI_AJCONV')
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())

	ProcRegua(SB1->(RecCount()))

	while SB1->(!eof())

		incProc()

		if !(SB1->B1_TIPO $ 'PA/PR')
			SB1->(DbSkip())
			loop
		endif

		if _cStatus = 'N'
			_nFatConv     := SB1->B1_CONV2
			reclock('SB1',.f.)
			SB1->B1_CONV  := _nFatConv

			SB1->B1_CONV2 := 0

			msunlock()

		else
			_nFatConv := SB1->B1_CONV

			reclock('SB1',.f.)
			SB1->B1_CONV2 := _nFatConv
			SB1->B1_CONV  := 0
			msunlock()

		endif


		SB1->(DbSkip())
	enddo

	PUTMV('SI_AJCONV',iif(_cStatus = 'N','S','N'))

Return
