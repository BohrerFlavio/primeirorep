#INCLUDE "rwmake.ch"

User Function M460PROC()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ M460FIM  ³ Autor ³ Evandro Mugnol        ³ Data ³ 28.07.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³                                                            ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Frigorifico Silva                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Private _cNomePar	:= "PS_PLACARB"
	Private _PlacaRbq := Space(07)

	If !Empty(SC9->C9_CARGA)
		@ 150, 030 TO 450, 660 DIALOG oDlg1 TITLE "Placa do Reboque da Carga " + SC9->C9_CARGA
		@ 010, 005 SAY "INFORMAR PLACA DO REBOQUE DA CARGA CASO EXISTA"
		@ 011, 005 SAY "_________________________________________________"
		@ 050, 005 SAY "Placa Reboque "
		@ 050, 045 GET _PlacaRbq  Picture "@!"        When .T. SIZE 040, 11

		@ 120, 275 BMPBUTTON TYPE 1 ACTION (oDlg1:End ())
		ACTIVATE DIALOG oDlg1 CENTERED
	Endif

	//202304 - removido a criação do parametro.
/* 	DbSelectArea("SX6")
	DbSetOrder(1)
	If !DbSeek(xFilial("SX6")+_cNomePar)
		RecLock("SX6",.T.)
		SX6->X6_FIL		 := xFilial("SX6")
		SX6->X6_VAR		 := _cNomePar
		SX6->X6_TIPO	 := "C"
		SX6->X6_DESCRIC  := "Placa do Reboque a ser gravada na tabela SF2"
		SX6->X6_DSCSPA	 := "Placa do Reboque a ser gravada na tabela SF2"
		SX6->X6_DSCENG	 := "Placa do Reboque a ser gravada na tabela SF2"
		SX6->X6_DESC1 	 := "que é informada na geracao de documento por"
		SX6->X6_DSCSPA1  := "que é informada na geracao de documento por"
		SX6->X6_DSCENG1  := "que é informada na geracao de documento por"
		SX6->X6_DESC2 	 := "carga"
		SX6->X6_DSCSPA2  := "carga"
		SX6->X6_DSCENG2  := "carga"
		SX6->X6_CONTEUD  := _PlacaRbq
		SX6->X6_CONTSPA  := _PlacaRbq
		SX6->X6_CONTENG  := _PlacaRbq
		SX6->X6_PROPRI  := "U"
		SX6->(MsUnlock())
	Else */
		//RecLock("SX6",.F.)
		//SX6->X6_CONTEUD := _PlacaRbq
		//SX6->X6_CONTSPA := _PlacaRbq
		//SX6->X6_CONTENG := _PlacaRbq
		//SX6->(MsUnlock())
		PutMv(_cNomePar,_PlacaRbq) // ProcData 04/2023
/* 	Endif */

Return(.T.)
