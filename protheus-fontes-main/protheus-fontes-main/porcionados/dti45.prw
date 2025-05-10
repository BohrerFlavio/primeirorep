#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI45      ºAutor  ³Flavio Bohrer Flôres º Data ³  30/09/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Relatorio de conferencia do conteúdo de materia-prima a  º±±
±±º          ³   ser recebida na camara de estocagem de MP (Ref gjf228)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Porcionados Expedições e câmaras                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function DTI45()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatório"
	Local cDesc2         := "de conferencias de caixas de MP a serem recebidas "
	Local cDesc3         := "pela indústria de pordionados de Terceiros"
	Local cPict          := ""
	//Local titulo         := "P04 - CONFERENCIA DE RECEBIMENTO DE MATÉRIA-PRIMA PROPRIA"
	Local titulo         := "CONFERENCIA DE RECEBIMENTO DE MATÉRIA-PRIMA TERCEIRO"
	Local Cabec1         := " Cod.Produto        Descrição Produto   "
	Local Cabec2         := space(21)+"Nr. Caixa     Dt. Produção  Dt. Validade       Peso liq.              Local"
	Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI45"             // DTI45
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0

	//Vai usar o mesmo grupo de produtos GJF222
	Private cPerg   		:= "DTI45"

	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI45"
	Private _aBatidas  	:= {}

	pergunte(cPerg,.F.)

	if mv_par07 == 2
		Cabec1         := " Cod.Produto    Descrição Produto                Dt Recebimento             Caixas              Peso liq.           Sif"
		Cabec2         := ""
	endif

	wnrel := SetPrint('ZAS',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAS')

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
	Local _COD 			:= ""
	Local _nContCaix 	:= 0
	Local prim 			:=	1
	Local _nQtdPeso1	:= 0

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea('SB1')
	ZAS->(SetRegua(RecCount()))
	ZAS->(DbSetOrder(5))
	ZAS->(dbGoTop())
	ZAS->(DbSeek(xfilial('ZAS') + dtos(mv_par01),.t.))

	while ZAS->(!eof())  .and. ZAS->ZAS_FILIAL = xfilial('ZAS') .and. ZAS->ZAS_DTPROD <= mv_par02

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if !(alltrim(ZAS->ZAS_PREEMB) = "MANUAL" .AND. alltrim(ZAS->ZAS_TERC) = "S" .AND. alltrim(ZAS->ZAS_TIPO) = "MP")
			ZAS->(DbSkip())
			loop
		endif

		//verifica código de produto
		if !empty(mv_par03)
			if alltrim(ZAS->ZAS_COD3) <> alltrim(mv_par03)
				ZAS->(DbSkip())
				loop
			endif
		endif

		//verifica código da caixa
		if !empty(mv_par04)
			if alltrim(ZAS->ZAS_CONTRO) <> alltrim(mv_par04)
				ZAS->(DbSkip())
				loop
			endif
		endif

		//data de produção
		if !empty(dtos(mv_par05))
			if ZAS->ZAS_DTABAT <> mv_par05
				ZAS->(DbSkip())
				loop
			endif
		endif

		//verifica sif
		if !empty(mv_par06)
			if alltrim(ZAS->ZAS_SIF) <> alltrim(mv_par06)
				ZAS->(DbSkip())
				loop
			endif
		endif

		If prim = 1
			_COD := alltrim(ZAS->ZAS_COD3)
			if mv_par07 == 1
				@nlin,001 psay alltrim(ZAS->ZAS_COD3)
				_cDescTerc := fBuscaCpo('SB1',1,xFilial('SB1') + ZAS->ZAS_COD3,'B1_IMPCOM')
				@nlin,016 psay substr(_cDescTerc,1,25)
				//@nlin,015 psay substr(ZAS->ZAS_DESC,1,25)
				@nlin,045 psay "Data Rec.:"
				@nlin,055 psay ZAS->ZAS_DTPROD

				if !empty(alltrim(ZAS->ZAS_SIF))
					@nlin,107 psay "SIF: -" + alltrim(ZAS->ZAS_SIF)
				Endif
				nlin++
			else
				@nlin,001 psay alltrim(ZAS->ZAS_COD3)
				_cDescTerc := fBuscaCpo('SB1',1,xFilial('SB1') + ZAS->ZAS_COD3,'B1_IMPCOM')
				@nlin,016 psay substr(_cDescTerc,1,25)
				@nlin,055 psay ZAS->ZAS_DTPROD
				@nlin,115 psay alltrim(ZAS->ZAS_SIF)

			endif
			prim++
		Endif

		//"Cod. Produto"    "Descrição do Produto"    "Data Recebimento"   "Qtde Caixas"   "Total em Kg"   "SIF"

		if !(ZAS->ZAS_COD3 = _COD)
			if mv_par07 == 1
				nlin++

				@nlin,029 psay 'Total --->'
				@nlin,045 psay Transform(_nContCaix,'@E 999,999')   +' - Caixas'
				@nlin,070 psay Transform(_nQtdPeso1,'@E 999,999,999.99')+ ' - kg'
				nlin++

				@nlin,00 psay replicate('-',132)
				nlin++
				@nlin,001 psay alltrim(ZAS->ZAS_COD3)
				_cDescTerc := fBuscaCpo('SB1',1,xFilial('SB1') + ZAS->ZAS_COD3,'B1_IMPCOM')
				@nlin,016 psay substr(_cDescTerc,1,25)
				@nlin,045 psay "Data Rec.:"
				@nlin,055 psay ZAS->ZAS_DTPROD
				if !empty(alltrim(ZAS->ZAS_SIF))
					@nlin,107 psay "SIF: - " + alltrim(ZAS->ZAS_SIF)
				Endif
				nlin++
			else
				@nlin,070 psay Transform(_nContCaix,'@E 999,999')   +' - Caixas'
				@nlin,090 psay Transform(_nQtdPeso1,'@E 999,999,999.99')+ ' - kg'
				nlin++
				nlin++
				If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif
				@nlin,001 psay alltrim(ZAS->ZAS_COD3)
				_cDescTerc := fBuscaCpo('SB1',1,xFilial('SB1') + ZAS->ZAS_COD3,'B1_IMPCOM')
				@nlin,016 psay substr(_cDescTerc,1,25)
				@nlin,055 psay ZAS->ZAS_DTPROD
				@nlin,115 psay alltrim(ZAS->ZAS_SIF)
			endif

			_COD := ZAS->ZAS_COD3
			_nContCaix := 0
			_nQtdPeso1 := 0

		Endif

		if mv_par07 == 1
			If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif
			_dValid := ZAS->ZAS_DTABAT + ZAS->ZAS_VALID
			@nlin,020 psay ZAS->ZAS_CONTRO
			@nlin,035 psay ZAS->ZAS_DTABAT
			@nlin,055 psay DTOC(_dValid)
			@nlin,070 psay transform(ZAS->ZAS_PESOL,'@E 999.99')
			@nlin,094 psay ZAS->ZAS_LOCAL
			nlin++
		endif

		_nQtdPeso1 += ZAS->ZAS_PESOL
		_nContCaix++

		ZAS->(DbSkip())

	enddo

	if mv_par07 == 1
		nlin++
		@nlin,029 psay 'Total --->'
		@nlin,045 psay Transform(_nContCaix,'@E 999,999')   +' - Caixas'
		@nlin,060 psay Transform(_nQtdPeso1,'@E 999,999,999.99')+ ' - kg'
	else
		@nlin,070 psay Transform(_nContCaix,'@E 999,999')   +' - Caixas'
		@nlin,090 psay Transform(_nQtdPeso1,'@E 999,999,999.99')+ ' - kg'
	endif
	nlin++

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
