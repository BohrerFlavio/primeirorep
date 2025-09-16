#INCLUDE "rwmake.ch"

User function custmed()

	_ZeraD3()
	_ZeraD1()
	_ZeraB2()
	_ZeraB9()

	// ----------------------------------------------- Roda Recalculo Custo Medio

	MATA330()

Return


Static Function _ZeraD3()
	DbSelectArea("SD3")
	#IFDEF WINDOWS
	Processa({|| ml_cn1()},"Ajustando custos das moedas 2,3,4,5 no SD3")
Return
Static Function ML_CN1()
	ProcRegua(RecCount())
	#ENDIF

	DbSelectArea("SD3")
	DbSetOrder(6)
	DbSeek(xFilial("SD3")+Dtos(DDATABASE-35),.T.)
	Do While !Eof()
		Incproc("Ajustando SD3. Aguarde....")
		RecLock("SD3",.F.)
		SD3->D3_CUSTO2:=0
		SD3->D3_CUSTO3:=0
		SD3->D3_CUSTO4:=0
		SD3->D3_CUSTO5:=0
		MsUnLock()
		DbSelectArea("SD3")
		DbSkip()
	Enddo                                  

Return

Static Function _ZeraD1()
	DbSelectArea("SD1")
	#IFDEF WINDOWS
	Processa({|| ml_cn2()},"Ajustando custos das moedas 2,3,4,5 no SD1")
Return
Static Function ML_CN2()
	ProcRegua(RecCount())
	#ENDIF

	DbSelectArea("SD1")
	DbSetOrder(6)
	DbSeek(xFilial("SD1")+Dtos(DDATABASE-35),.T.)
	Do While !Eof()
		Incproc("Ajustando SD1. Aguarde....")
		RecLock("SD1",.F.)
		SD1->D1_CUSTO2:=0
		SD1->D1_CUSTO3:=0
		SD1->D1_CUSTO4:=0
		SD1->D1_CUSTO5:=0
		MsUnLock()
		DbSelectArea("SD1")
		DbSkip()
	Enddo

Return

Static Function _ZeraB2()
	DbSelectArea("SB2")
	#IFDEF WINDOWS
	Processa({|| ml_cn3()},"Ajustando custos das moedas 2,3,4,5 no SB2")
Return
Static Function ML_CN3()
	ProcRegua(RecCount())
	#ENDIF

	DbSelectArea("SB2")
	DbGoTop()
	Do While !Eof()
		Incproc("Ajustando SB2. Aguarde....")

		RecLock("SB2",.F.)
		SB2->B2_VFIM1:=0
		SB2->B2_VATU1:=0
		SB2->B2_CM1:=0
		SB2->B2_VFIM2:=0
		SB2->B2_VATU2:=0
		SB2->B2_CM2:=0
		SB2->B2_VFIM3:=0
		SB2->B2_VATU3:=0
		SB2->B2_CM3:=0
		SB2->B2_VFIM4:=0
		SB2->B2_VATU4:=0
		SB2->B2_CM4:=0
		SB2->B2_VFIM5:=0
		SB2->B2_VATU5:=0
		SB2->B2_CM5:=0
		MsUnLock()
		DbSelectArea("SB2")
		DbSkip()
	Enddo

Return

Static Function _ZeraB9()
	DbSelectArea("SB9")
	#IFDEF WINDOWS
	Processa({|| ml_cn4()},"Ajustando custos das moedas 2,3,4,5 no SB9")
Return
Static Function ML_CN4()
	ProcRegua(RecCount())
	#ENDIF

	DbSelectArea("SB9")    
	Set Filter to SB9->B9_DATA >= dDataBase-60
	DbGoTop()
	Do While !Eof()
		Incproc("Ajustando SB9. Aguarde....")

		RecLock("SB9",.F.)
		SB9->B9_VINI2  :=0
		SB9->B9_VINI3  :=0
		SB9->B9_VINI4  :=0
		SB9->B9_VINI5  :=0
		SB9->B9_VINIFF2:=0
		SB9->B9_VINIFF3:=0
		SB9->B9_VINIFF4:=0
		SB9->B9_VINIFF5:=0

		MsUnLock()

		DbSelectArea("SB9")
		DbSkip()
	Enddo
	Set Filter To

Return
