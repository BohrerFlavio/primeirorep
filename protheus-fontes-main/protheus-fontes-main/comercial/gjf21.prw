#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

User Function GJF21()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	LOCAL nOpca	:=0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL aSays:={}, aButtons:={}
	Private cCadastro := "Cálculo do Preço Médio de Venda"
	PRIVATE quant := 0
	PRIVATE preco := 0
	PRIVATE media := 0
	PRIVATE prod  := ""
	PRIVATE cod   := ""
	PRIVATE maior := 0
	PRIVATE menor := 9.99
	PRIVATE nfmaior := ""
	PRIVATE nfmenor := ""

	cPerg := "GJF21"
	Pergunte(cPerg,.f.)

	AADD (aSays, "  Este programa tem como objetivo calcular e apresentar o preço médio  ")  //
	AADD (aSays, "  dos produtos acabados vendidos pela empresa de acordo com o          ")  //
	AADD (aSays, "  período definido nos parametros da rotina.                           ")  //

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 6,.T.,{|o| nOpca:= 2,o:oWnd:End()}} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )
	If nopca == 1
		Processa({|lEnd| u_gjf21A()})
		u_gjf21C()
	elseif nopca == 2
		u_gjf21B()
	Endif
Return

user Function gjf21A()

	SD2->(dbsetorder(5))
	SD2->(dbgotop())
	SD2->(dbseek(xfilial()+dtos(mv_par02),.t.))

	while !eof() .and. SD2->D2_EMISSAO <= mv_par03
		if SD2->D2_TES = "524"
			SD2->(dbskip())
			loop
		endif
		if SD2->D2_TP != "PA"
			SD2->(dbskip())
			loop
		endif
		if SD2->D2_COD != mv_par01
			SD2->(dbskip())
			loop
		endif
		prod := SD2->D2_DESCRI
		cod  := SD2->D2_COD
		quant++
		preco := preco + SD2->D2_PRCVEN
		if SD2->D2_PRCVEN >= maior
			maior := SD2->D2_PRCVEN
			nfmaior := Sd2->D2_DOC
		endif
		if SD2->D2_PRCVEN <= menor
			menor := SD2->D2_PRCVEN
			nfmenor:= SD2->D2_DOC
		endif
		SD2->(dbskip())
	enddo
	media := preco/quant
	if empty(prod)
		alert("Produto não localizado!")
		return
	endif
return

User Function gjf21C()
	DEFINE MSDIALOG tela FROM 0,0 TO 300,280 PIXEL TITLE "Preço Médio de Venda:"
	@ 01,01 SAY alltrim(cod)+" "+prod size 300,14 Color CLR_HBLUE of tela
	@ 02,01 SAY "De "+transform(mv_par02,"@E ##/##/####")+"     Até "+transform(mv_par03,"@E ##/##/####")  of tela
	@ 03,01 SAY "MAIOR PRECO:         " + transform(maior,"@E 99.99")+"          NF "+nfmenor of tela
	@ 04,01 SAY "MENOR PRECO:        " + transform(menor,"@E 99.99")+"          NF "+nfmaior of tela
	@ 06,01 SAY "PRECO MEDIO DO PERÍODO: " + transform(media,"@E 999.99") Size 100,14 Color CLR_HRED  of tela

	@ 112,50 BUTTON botao1 PROMPT "Relatório" OF tela size 40,15 PIXEL ACTION Eval({||u_gjf21b(),tela:end()})
	@ 130,50 BUTTON botao2 PROMPT "Fechar" OF tela size 40,15 PIXEL ACTION tela:end()
	ACTIVATE MSDIALOG tela CENTERED
Return

User Function gjf21B()
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Relação de Situação de Clientes"
	Local cPict          := ""
	Local titulo       := "PRECO MEDIO DE PRODUTO ACABADO (Kg)"
	Local nLin         := 80
	Local Cabec1       := "      Emissão:      Média:    Maior:    Ult. NF:    Menor:    Ult. NF:"
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private tamanho          := "P"
	Private nomeprog         := "GJF21" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg       := "GJF21"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "GJF21B" // Coloque aqui o nome do arquivo usado para impressao em disco

	pergunte(cPerg,.F.)
	wnrel := SetPrint("SD2",NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,"SD2")
	If nLastKey == 27
		Return
	Endif
	nTipo := If(aReturn[4]==1,15,18)
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local nOrdem
	Rpreco  := 0
	RprecoT := 0
	RmediaT := 0
	RmenorT := 9.99
	RmaiorT := 0
	RvalorT := 0
	Rvalor  := 0
	Rmedia  := 0
	Rcod    := 0
	Rdesc   := ""
	NFmaiorT := ""
	NFmenorT := ""

	dbSelectArea("SD2")
	SD2->(dbSetOrder(5))
	SetRegua(RecCount())
	SD2->(dbGoTop())
	SD2->(dbseek(xfilial()+dtos(mv_par02),.t.))
	flag := .f.
	While !EOF() .and. SD2->D2_EMISSAO <= mv_par03
		Remissao := SD2->D2_EMISSAO
		Rmaior   := 0
		Rmenor   := 9.99
		While !EOF() .and. SD2->D2_EMISSAO <= mv_par03 .and. Remissao = SD2->D2_EMISSAO
			if SD2->D2_TP != "PA"
				SD2->(dbskip())
				loop
			endif
			if SD2->D2_COD != mv_par01
				dbskip()
				loop
			endif
			if SD2->D2_TES = "524"
				SD2->(dbskip())
				loop
			endif
			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
			If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			Endif
			if flag = .f.
				@nlin,03 psay alltrim(SD2->D2_COD)+"  " + SD2->D2_DESCRI
				nlin += 2
				flag := .t.
			endif
			Rvalor  := Rvalor + SD2->D2_PRCVEN
			RvalorT := RvalorT + SD2->D2_PRCVEN
			Rpreco++
			RprecoT++
			Rmedia  := Rvalor/Rpreco
			if SD2->D2_PRCVEN >= Rmaior
				Rmaior := SD2->D2_PRCVEN
				NFmaior := SD2->D2_DOC
			endif
			if SD2->D2_PRCVEN <= Rmenor
				Rmenor := SD2->D2_PRCVEN
				NFmenor := SD2->D2_DOC
			endif
			if SD2->D2_PRCVEN >= RmaiorT
				RmaiorT  := SD2->D2_PRCVEN
				NFmaiorT := SD2->D2_DOC
			endif
			if SD2->D2_PRCVEN <= RmenorT
				RmenorT  := SD2->D2_PRCVEN
				NFmenorT := SD2->D2_DOC
			endif
			SD2->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		EndDo
		if Rmaior != 0.00
			@nlin,05 psay Remissao
			@nlin,20 psay Rmedia picture "@E 9.99"
			@nlin,30 psay Rmaior picture "@E 9.99"
			@nlin,40 psay NFmaior
			@nlin,52 psay Rmenor picture "@E 9.99"
			@nlin,62 psay NFmenor
			Rvalor := 0
			Rpreco := 0
			nlin++
		endif
	enddo
	RmediaT := RvalorT/RprecoT
	nlin++
	@nlin,03 psay "MAIOR PREÇO NO PERIODO:    "+transform(RmaiorT,"@E 9.99") + "  " + "Ultima NF: " + NFmaiorT
	nlin++
	@nlin,03 psay "MENOR PRECO NO PERIODO:    "+transform(RmenorT,"@E 9.99") + "  " + "Ultima NF: " + NFmenorT
	nlin++
	@nlin,03 psay "MEDIA DE PRECO NO PERIODO: "+transform(RmediaT,"@E 9.99")
	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	MS_FLUSH()

Return
