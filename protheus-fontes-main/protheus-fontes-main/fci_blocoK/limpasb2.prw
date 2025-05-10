#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} LIMPASB2
@Type			: Função BACA para limpar SB2
@Sample			: U_LIMPASB2()
@Description	: Rotina para ser utilizada durante período de homologação dos processos
                  a fim de limpar os dados do SB2 e validar mais facilmente
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------

User Function LIMPASB2()

	MsgAlert("Início do processamento de limpeza para grupo de produtos 1000")
	DbSelectArea("SB1")
	DbSelectArea("SB2")
	SB1->(DbSetOrder(4))
	SB2->(DbSetOrder(1))

	SB1->(DbGoTop())
	SB2->(DbGoTop())
	If SB1->(DbSeek(xFilial("SB1") + "1000"))
		While SB1->(!Eof()) .And. SB1->B1_FILIAL = xFilial("SB1") .And. SB1->B1_GRUPO = "1000"
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "01"))
				RecLock("SB2",.F.)
				SB2->B2_QATU     := 0.00
				SB2->B2_VATU1    := 0.00
				SB2->B2_VATU2    := 0.00
				SB2->B2_VATU3    := 0.00
				SB2->B2_VATU4    := 0.00
				SB2->B2_VATU5    := 0.00
				SB2->B2_CM1      := 0.00
				SB2->B2_CM2      := 0.00
				SB2->B2_CM3      := 0.00
				SB2->B2_CM4      := 0.00
				SB2->B2_CM5      := 0.00
				SB2->B2_QEMP     := 0.00
				SB2->B2_QTSEGUM  := 0.00
				SB2->B2_SALPEDI  := 0.00
				SB2->B2_SALPEDI2 := 0.00
				MsUnlock()
			Endif

			SB1->(DbSkip())
		Enddo
	Endif


	MsgAlert("Início do processamento de limpeza para grupo de produtos 1002")
	DbSelectArea("SB1")
	DbSelectArea("SB2")
	SB1->(DbSetOrder(4))
	SB2->(DbSetOrder(1))

	SB1->(DbGoTop())
	SB2->(DbGoTop())
	If SB1->(DbSeek(xFilial("SB1") + "1002"))
		While SB1->(!Eof()) .And. SB1->B1_FILIAL = xFilial("SB1") .And. SB1->B1_GRUPO = "1002"
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "01"))
				RecLock("SB2",.F.)
				SB2->B2_QATU     := 0.00
				SB2->B2_VATU1    := 0.00
				SB2->B2_VATU2    := 0.00
				SB2->B2_VATU3    := 0.00
				SB2->B2_VATU4    := 0.00
				SB2->B2_VATU5    := 0.00
				SB2->B2_CM1      := 0.00
				SB2->B2_CM2      := 0.00
				SB2->B2_CM3      := 0.00
				SB2->B2_CM4      := 0.00
				SB2->B2_CM5      := 0.00
				SB2->B2_QEMP     := 0.00
				SB2->B2_QTSEGUM  := 0.00
				SB2->B2_SALPEDI  := 0.00
				SB2->B2_SALPEDI2 := 0.00
				MsUnlock()
			Endif

			SB1->(DbSkip())
		Enddo
	Endif

	MsgAlert("Início do processamento de limpeza para grupo de produtos 1100")
	DbSelectArea("SB1")
	DbSelectArea("SB2")
	SB1->(DbSetOrder(4))
	SB2->(DbSetOrder(1))

	SB1->(DbGoTop())
	SB2->(DbGoTop())
	If SB1->(DbSeek(xFilial("SB1") + "1100"))
		While SB1->(!Eof()) .And. SB1->B1_FILIAL = xFilial("SB1") .And. SB1->B1_GRUPO = "1100"
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "01"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "02"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "06"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif

			SB1->(DbSkip())
		Enddo
	Endif

	MsgAlert("Início do processamento de limpeza para grupo de produtos 1200")
	DbSelectArea("SB1")
	DbSelectArea("SB2")
	SB1->(DbSetOrder(4))
	SB2->(DbSetOrder(1))

	SB1->(DbGoTop())
	SB2->(DbGoTop())
	If SB1->(DbSeek(xFilial("SB1") + "1200"))
		While SB1->(!Eof()) .And. SB1->B1_FILIAL = xFilial("SB1") .And. SB1->B1_GRUPO = "1200"
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "01"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "02"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "06"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif

			SB1->(DbSkip())
		Enddo
	Endif

	MsgAlert("Início do processamento de limpeza para grupo de produtos 1201")
	DbSelectArea("SB1")
	DbSelectArea("SB2")
	SB1->(DbSetOrder(4))
	SB2->(DbSetOrder(1))

	SB1->(DbGoTop())
	SB2->(DbGoTop())
	If SB1->(DbSeek(xFilial("SB1") + "1201"))
		While SB1->(!Eof()) .And. SB1->B1_FILIAL = xFilial("SB1") .And. SB1->B1_GRUPO = "1201"
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "01"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "02"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "06"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif

			SB1->(DbSkip())
		Enddo
	Endif

	MsgAlert("Início do processamento de limpeza para grupo de produtos 1202")
	DbSelectArea("SB1")
	DbSelectArea("SB2")
	SB1->(DbSetOrder(4))
	SB2->(DbSetOrder(1))

	SB1->(DbGoTop())
	SB2->(DbGoTop())
	If SB1->(DbSeek(xFilial("SB1") + "1202"))
		While SB1->(!Eof()) .And. SB1->B1_FILIAL = xFilial("SB1") .And. SB1->B1_GRUPO = "1202"
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "01"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "02"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "06"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif

			SB1->(DbSkip())
		Enddo
	Endif

	MsgAlert("Início do processamento de limpeza para grupo de produtos 1203")
	DbSelectArea("SB1")
	DbSelectArea("SB2")
	SB1->(DbSetOrder(4))
	SB2->(DbSetOrder(1))

	SB1->(DbGoTop())
	SB2->(DbGoTop())
	If SB1->(DbSeek(xFilial("SB1") + "1203"))
		While SB1->(!Eof()) .And. SB1->B1_FILIAL = xFilial("SB1") .And. SB1->B1_GRUPO = "1203"
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "01"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "02"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "06"))
				RecLock("SB2",.F.)
				SB2->B2_QEMP := 0.00
				MsUnlock()
			Endif

			SB1->(DbSkip())
		Enddo
	Endif

	MsgAlert("Início do processamento de limpeza para grupo de produtos 3000")
	SB1->(DbGoTop())
	SB2->(DbGoTop())
	If SB1->(DbSeek(xFilial("SB1") + "3000"))
		While SB1->(!Eof()) .and. SB1->B1_FILIAL = xFilial("SB1") .And. SB1->B1_GRUPO = "3000"
			SG1->(DbSetOrder(2))
			If SG1->(DbSeek(xFilial("SG1") + SB1->B1_COD))
				While SG1->(!Eof()) .And. SG1->G1_FILIAL  = xFilial("SG1") .And. SG1->G1_COMP = SB1->B1_COD
					If SB2->(DbSeek(xFilial("SB2") + SG1->G1_COD + "01"))
						Reclock("SB2",.F.)
						SB2->B2_QATU     := 0.00
						SB2->B2_VATU1    := 0.00
						SB2->B2_VATU2    := 0.00
						SB2->B2_VATU3    := 0.00
						SB2->B2_VATU4    := 0.00
						SB2->B2_VATU5    := 0.00
						SB2->B2_CM1      := 0.00
						SB2->B2_CM2      := 0.00
						SB2->B2_CM3      := 0.00
						SB2->B2_CM4      := 0.00
						SB2->B2_CM5      := 0.00
						SB2->B2_QEMP     := 0.00
						SB2->B2_QTSEGUM  := 0.00
						SB2->B2_SALPEDI  := 0.00
						SB2->B2_SALPEDI2 := 0.00
						Msunlock()
					Endif
					SG1->(DbSkip())
				Enddo
			Endif

			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "01"))
				Reclock("SB2",.F.)
				SB2->B2_QATU     := 0.00
				SB2->B2_VATU1    := 0.00
				SB2->B2_VATU2    := 0.00
				SB2->B2_VATU3    := 0.00
				SB2->B2_VATU4    := 0.00
				SB2->B2_VATU5    := 0.00
				SB2->B2_CM1      := 0.00
				SB2->B2_CM2      := 0.00
				SB2->B2_CM3      := 0.00
				SB2->B2_CM4      := 0.00
				SB2->B2_CM5      := 0.00
				SB2->B2_QEMP     := 0.00
				SB2->B2_QTSEGUM  := 0.00
				SB2->B2_SALPEDI  := 0.00
				SB2->B2_SALPEDI2 := 0.00
				Msunlock()
			Endif

			SB1->(DbSkip())
		Enddo
	Endif

	MsgAlert("Início do processamento de limpeza para grupo de produtos 4001")
	SB1->(DbGoTop())
	SB2->(DbGoTop())
	If SB1->(DbSeek(xFilial("SB1") + "4001"))
		While SB1->(!Eof()) .And. SB1->B1_FILIAL = xFilial("SB1") .And. SB1->B1_GRUPO = "4001"
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "01"))
				Reclock("SB2",.F.)
				SB2->B2_QATU     := 0.00
				SB2->B2_VATU1    := 0.00
				SB2->B2_VATU2    := 0.00
				SB2->B2_VATU3    := 0.00
				SB2->B2_VATU4    := 0.00
				SB2->B2_VATU5    := 0.00
				SB2->B2_CM1      := 0.00
				SB2->B2_CM2      := 0.00
				SB2->B2_CM3      := 0.00
				SB2->B2_CM4      := 0.00
				SB2->B2_CM5      := 0.00
				SB2->B2_QEMP     := 0.00
				SB2->B2_QTSEGUM  := 0.00
				SB2->B2_SALPEDI  := 0.00
				SB2->B2_SALPEDI2 := 0.00
				Msunlock()
			Endif

			SB1->(DbSkip())
		Enddo
	Endif

	MsgAlert("Início do processamento de limpeza para grupo de produtos 9000")
	SB1->(DbGoTop())
	SB2->(DbGoTop())
	If SB1->(DbSeek(xFilial("SB1") + "9000"))
		While SB1->(!Eof()) .And. SB1->B1_FILIAL = xFilial("SB1") .And. SB1->B1_GRUPO = "9000"
			If SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + "01"))
				Reclock("SB2",.F.)
				SB2->B2_QATU     := 0.00
				SB2->B2_VATU1    := 0.00
				SB2->B2_VATU2    := 0.00
				SB2->B2_VATU3    := 0.00
				SB2->B2_VATU4    := 0.00
				SB2->B2_VATU5    := 0.00
				SB2->B2_CM1      := 0.00
				SB2->B2_CM2      := 0.00
				SB2->B2_CM3      := 0.00
				SB2->B2_CM4      := 0.00
				SB2->B2_CM5      := 0.00
				SB2->B2_QEMP     := 0.00
				SB2->B2_QTSEGUM  := 0.00
				SB2->B2_SALPEDI  := 0.00
				SB2->B2_SALPEDI2 := 0.00
				Msunlock()
			Endif

			SB1->(DbSkip())
		Enddo
	Endif

	MsgAlert("Final do processamento de limpeza")

Return
