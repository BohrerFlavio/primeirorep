#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SPI01     º Autor ³ Giuliano Forgiariniº Data ³  10/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Apuração de número de funcionários do dia - Giuliano       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
/*/

User Function SPI01()

	matricula := ''
	quant     := 0

	cPerg := "SPI01"

	Pergunte(cPerg,.T.) 

	Processa({||Calcula()} ,"CALCULO DE FUNCIONARIOS","Executando calculo das horas...")

return

Static Function Calcula()

	dbSelectArea('SPC')
	dbSetOrder(1)    

	ProcRegua(SPC->(RecCount()))

	SPC->(dbGoTop())
	While SPC->(!EOF())

		incproc('Processando matrícula: ' + SPC->PC_MAT)

		if  (SPC->PC_DATA <> mv_par01) .or.;
		!(SPC->PC_PD $ '105/106/107/108/113/996')
			SPC->(dbskip())
			loop
		else	
			if mv_par02 = 1                                
				if SPC->PC_CC = '1131005'                  //Centro de Custo Embalagem
					if matricula <> SPC->PC_MAT
						quant++
						matricula := SPC->PC_MAT
					endif
				endif
			else
				if SPC->PC_CC = '1131006'                  //Centro de Custo Desossa
					if matricula <> SPC->PC_MAT
						quant++
						matricula := SPC->PC_MAT
					endif
				endif
			endif	
		endif
		SPC->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	EndDo

	msgbox('Total de horas :' + transform(quant,'@E 999,999'),'FIM DE PROCESSAMENTO','INFO')

Return
