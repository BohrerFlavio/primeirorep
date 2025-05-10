#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF07     º Autor ³ Giuliano Forgiariniº Data ³  05/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CALCULO DE PRODUCAO KG/HORA/HOMEM                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
/*/

User Function GJF07()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de cálculo de horas trabalhadas por centro de custo."
	Local cDesc3         := "CALCULO DE PRODUCAO KG/HORA/HOMEM"
	Local cPict          := ""
	Local titulo       := "CALCULO DE PRODUÇÃO POR KG/HORA/HOMEM"
	Local nLin         := 80

	Local Cabec2       := ""
	Local Cabec1       := "Matrícula    Funcionário                   Evento               Horas "
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "GJF07" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF07"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF07" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "SPC"

	dbSelectArea("SPC")
	SPC->(dbSetOrder(3))

	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	dbSelectArea(cString)
	dbSetOrder(3)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetRegua(SPC->(RecCount()))
	cc        := ' '
	hora      := 0  
	hora996   := 0
	hora105   := 0
	hora106   := 0
	hora107   := 0     
	hora108   := 0
	hora113   := 0
	minuto    := 0
	minutos   := 0
	minutos996 := 0
	minutos105 := 0
	minutos106 := 0
	minutos107 := 0
	minutos108 := 0
	minutos113 := 0
	minuto996 := 0
	minuto105 := 0
	minuto106 := 0
	minuto107 := 0 
	minuto108 := 0
	minuto113 := 0
	horas     := 0 
	quant     := 0
	PD996     := 0
	PD105     := 0
	PD106     := 0
	PD107     := 0
	PD108     := 0
	PD113     := 0
	kgentrada := 0
	kgsaida   := 0
	kg        := 0
	matricula := ' '

	SPC->(dbGoTop())
	While SPC->(!EOF())

		if SPC->PC_CC !="1131005"  .and. SPC->PC_CC != "1131006"
			SPC->(dbskip())
			loop
		endif

		if SPC->PC_DATA < mv_par01 .or. SPC->PC_DATA > mv_par02
			SPC->(dbskip())
			loop
		endif

		if !(SPC->PC_PD $ '105/106/107/108/113/996')
			SPC->(dbskip())
			loop
		endif   

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif  
		if cc != SPC->PC_CC 
			nlin++
			cCusto := posicione('CTT',1,xfilial('CTT')+SPC->PC_CC,'CTT_DESC01')
			@nlin,01 psay SPC->PC_CC + '  '+ cCusto
			nlin++
			@nlin,00 psay '+' + replicate('-',80) + '+'
			nlin++ 
			cc := SPC->PC_CC
		endif  
		if matricula != SPC->PC_MAT
			quant++ 
			@nlin,01 psay SPC->PC_MAT
			@nlin,12 psay substr(posicione('SRA',1,xfilial()+SPC->PC_MAT,'RA_NOME'),1,25)
			matricula := SPC->PC_MAT
		endif
		if SPC->PC_PD == '996'
			@nlin,43 psay 'Hora Normal'
		elseif SPC->PC_PD == '105'
			@nlin,43 psay 'Hora Extra 60%'
		elseif SPC->PC_PD == '106'
			@nlin,43 psay 'Hora Extra 100%'
		elseif SPC->PC_PD == '107'
			@nlin,43 psay 'H.Extra 60% Comp.'
		elseif SPC->PC_PD == '108'
			@nlin,43 psay 'H.Extra 100% Fer.'
		elseif SPC->PC_PD == '113'
			@nlin,43 psay 'H.Extra 100% Fer.Not.'
		endif


		@nlin,67 psay SPC->PC_QUANTC  picture '@E 99.99'

		hora    := val(str(SPC->PC_QUANTC,2))
		minuto  := SPC->PC_QUANTC - hora
		horas   += hora
		minutos += minuto

		if SPC->PC_PD = "996"
			hora996    := val(str(SPC->PC_QUANTC,2))
			minuto996  := SPC->PC_QUANTC - hora996
			PD996   += hora996
			minutos996 += minuto996
		endif
		if SPC->PC_PD = "105"
			hora105    := val(str(SPC->PC_QUANTC,2))
			minuto105  := SPC->PC_QUANTC - hora105
			PD105   += hora105
			minutos105 += minuto105
		endif
		if SPC->PC_PD = "106"
			hora106    := val(str(SPC->PC_QUANTC,2))
			minuto106  := SPC->PC_QUANTC - hora106
			PD106      += hora106
			minutos106 += minuto106
		endif
		if SPC->PC_PD = "107"
			hora107    := val(str(SPC->PC_QUANTC,2))
			minuto107  := SPC->PC_QUANTC - hora107
			PD107      += hora107
			minutos107 += minuto107
		endif     
		nlin++  
		if SPC->PC_PD = "108"
			hora108    := val(str(SPC->PC_QUANTC,2))
			minuto108  := SPC->PC_QUANTC - hora108
			PD108      += hora108
			minutos108 += minuto108
		endif     
		if SPC->PC_PD = "113"
			hora113    := val(str(SPC->PC_QUANTC,2))
			minuto113  := SPC->PC_QUANTC - hora113
			PD113      += hora113
			minutos113 += minuto113
		endif     


		incregua()  

		SPC->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	EndDo
	SZO->(dbsetorder(2))
	SZO->(dbgotop())
	SZO->(dbseek(xfilial()+DTOS(mv_par01)+"E"+"D",.t.))
	while SZO->(!eof()) .and. SZO->ZO_DATA <= mv_par02 .and. SZO->ZO_TIPO = "E" .and. SZO->ZO_DEST = "D"
		kgentrada += SZO->ZO_PESOL
		SZO->(dbskip())
	enddo
	SZO->(dbgotop())
	SZO->(dbseek(xfilial()+DTOS(mv_par01)+"S",.t.))
	while SZO->(!eof()) .and. SZO->ZO_DATA <= mv_par02 .and. SZO->ZO_TIPO = "S"
		kgsaida += SZO->ZO_PESOL 
		SZO->(dbskip())
	enddo
	kg := kgentrada - kgsaida

	horas += ((minutos*100)/60) 
	PD996 += ((minutos996*100)/60)
	PD105 += ((minutos105*100)/60)
	PD106 += ((minutos106*100)/60)
	PD107 += ((minutos107*100)/60)
	PD108 += ((minutos108*100)/60)
	PD113 += ((minutos113*100)/60)
	Cabec1 := '------------------------------- RESUMO DE CALCULOS ------------------------------'
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
	@nlin,20 PSAY "Horas normais:................"+transform(PD996,"@E ###,###.##")
	nlin += 2
	@nlin,20 PSAY "Horas extras 60%:............."+transform(PD105,"@E ###,###.##")
	nlin += 2
	@nlin,20 PSAY "Horas extras 100%:............"+transform(PD106,"@E ###,###.##")
	nlin += 2
	@nlin,20 PSAY "Horas extras 60%:............"+transform(PD107,"@E ###,###.##")
	nlin += 2
	@nlin,20 PSAY "Horas extras 100% feriado:..."+transform(PD108,"@E ###,###.##")
	nlin += 2
	@nlin,20 PSAY "Horas extras 100% fer.not.:.."+transform(PD113,"@E ###,###.##")

	nlin += 4

	@nlin,20 PSAY "TOTAL DE HORAS (embal./des.):."+transform(horas,"@E ###,###.##")
	nlin += 2    
	if mv_par04 !=  0
		@nlin,20 PSAY "TOTAL HORAS FUNC. DESLOC.:...."+transform(mv_par04,'@E ###,###.##')
		nlin += 2 
	endif

	@nlin,20 PSAY "FUNCIONÁRIOS (embal./des.):...       "+transform(quant,'@E ###')
	nlin += 2 
	if mv_par03 !=  0
		@nlin,20 PSAY "FUNCIONÁRIOS DESLOCADOS:......       "+transform(mv_par03,'@E ###')
		nlin += 2 
	endif    
	MedHoraH := (horas+mv_par04)/(quant+mv_par03)
	@nlin,20 PSAY "MÉDIA GERAL DE HORAS/FUNC.:..."+transform(MedHoraH,"@E ###,###.##")
	nlin += 2
	@nlin,20 PSAY "PRODUÇÃO EM KG NO DIA:........"+transform(kg,"@E ###,###.##")

	nlin += 4 
	@nlin,00 psay '+--------------------------------------------------------------------------------+'  
	nlin++
	@nlin,20 PSAY "PRODUÇÃO KG/HORA/HOMEM:......."+transform((kg/MedHoraH)/(quant+mv_par03),"@E ###,###.##") 
	nlin++
	@nlin,00 psay '+--------------------------------------------------------------------------------+'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return
