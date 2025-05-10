#INCLUDE "rwmake.ch"

User Function ML_VEN1

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ ML_VEN1  ³ Autor ³ Evandro Mugnol        ³ Data ³ 30.11.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Rdmake p/ alterar vendedor na manutencao de comissoes      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Frigorifico Silva Ltda                     ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	_cVendedor := SE3->E3_VEND
	_cPrefixo  := SE3->E3_PREFIXO
	_cNumero   := SE3->E3_NUM
	_cParcela  := SE3->E3_PARCELA
	_cCliente  := SE3->E3_CODCLI
	_cLoja     := SE3->E3_LOJA
	_nBase     := SE3->E3_BASE
	_nPorcent  := SE3->E3_PORC
	_nComiss   := SE3->E3_COMIS

	@ 200,001 TO 360,600 DIALOG oDlg1 TITLE OemToAnsi("Alteracao Vendedor")
	@ 010,005 Say "Prefixo "
	@ 010,087 Say "Numero "
	@ 010,157 Say "Parcela "
	@ 022,005 Say "Cliente "
	@ 022,087 Say "Loja "   
	//@ 034,005 Say "Base Comissao "
	//@ 034,087 Say "% Comis "
	//@ 034,150 Say "Valor Comissao "
	@ 046,005 Say "Vendedor "

	@ 010,050 Get _cPrefixo  When .F.
	@ 010,110 Get _cNumero   When .F.
	@ 010,180 Get _cParcela  When .F.
	@ 022,050 Get _cCliente  When .F.
	@ 022,110 Get _cLoja     When .F.
	//@ 034,050 Get _nBase     When .F. Picture "@E 999,999,999.99"  SIZE 100, 11
	//@ 034,110 Get _nPorcent  When .F. Picture "@E 999.99"          SIZE 100, 11
	//@ 034,200 Get _nComiss   When .F. Picture "@E 999,999,999.99"  SIZE 100, 11
	@ 046,050 Get _cVendedor Picture "@!" Valid .T. F3 "SA3" SIZE 40, 11

	@ 060,220 BMPBUTTON TYPE 01 ACTION Grava()
	@ 060,255 BMPBUTTON TYPE 02 ACTION oDlg1:End()
	Activate Dialog oDlg1 Centered
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Gravacao da Alteracao da Data Emissao                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Grava()
	DbSelectArea("SE3")
	RecLock("SE3",.F.)
	SE3->E3_VEND := _cVendedor
	MsUnlock()
	oDlg1:End()
Return
