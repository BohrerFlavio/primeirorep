#INCLUDE "RWMAKE.CH"       
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"

User Function SPDRECBRUT()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ SPDRECBRUT ³ Autor ³ Evandro Mugnol      ³ Data ³ Nov/2017 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Ponto Entrada com o objetivo de retornar ao Sped Pis/Cofins³±±
	±±³          ³ os valores das receitas brutas unificadas por filial para  ³±±
	±±³          ³ geração do registro 0111.                                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ Array do registro. Sendo:                                  ³±±
	±±³          ³ 1a pos ref receitas brutas cumulativas                     ³±±
	±±³          ³ 2a pos ref receitas brutas não cumulativas - não tributadas³±±
	±±³          ³ 3a pos ref receitas brutas não cumulativas - tributadas    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Frigorífico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Private _oTela, _oConfirm
	Private _cTitulo    := OemToAnsi("Valores Ref. Receitas Brutas")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial34 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _nRBCum     := 0
	Private _nRBNCumNT  := 0
	Private _nRBNCumT   := 0

	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(230), C(650) PIXEL
	@ C(005), C(075) SAY "INFORME OS VALORES PARA O REGISTRO 0111"     	   			Size C(300), C(12) FONT _oFtArial34 COLOR CLR_HRED 	PIXEL OF _oTela

	@ C(030), C(005) SAY "Valor Receita Bruta Cumulativa"                          	Size C(300), C(10) FONT _oFtArial24 COLOR CLR_HBLUE	PIXEL OF _oTela
	@ C(030), C(200) MSGET _nRBCum 	  Valid Positivo() Picture "@E 999,999,999.99"	Size C(120), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

	@ C(050), C(005) SAY "Valor Receita Bruta Não Cumulativa - Não Tributada"    	Size C(300), C(10) FONT _oFtArial24 COLOR CLR_HBLUE	PIXEL OF _oTela
	@ C(050), C(200) MSGET _nRBNCumNT Valid Positivo() Picture "@E 999,999,999.99"  Size C(120), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

	@ C(070), C(005) SAY "Valor Receita Bruta Não Cumulativa - Tributada"           Size C(300), C(10) FONT _oFtArial24 COLOR CLR_HBLUE	PIXEL OF _oTela
	@ C(070), C(200) MSGET _nRBNCumT  Valid Positivo() Picture "@E 999,999,999.99"  Size C(120), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(095), C(265) TYPE 1 OBJECT _oConfirm ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED                                                                        

	aRetRecB := {_nRBCum, _nRBNCumNT, _nRBNCumT}

Return aRetRecB
