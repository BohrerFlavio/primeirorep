#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF70     ºGiuliano José Forgiarini   º Data ³  30/12/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de carcaças processadas em previsão de produção  º±±
±±º          ³ na entrada da desossa                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Producao (SIGAPCP)                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF70()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio     "
	Local cDesc2         := "de carcaças processadas em uma determinada previsao de "
	Local cDesc3         := "produção para a entrada da desossa                     "
	Local cPict          := ""
	Local titulo       	 := "R6 - QUARTOS PROCESSADOS"
	Local nLin         	 := 80

	Local Cabec1       	 := " Dados da Previsão de Produção"
	Local Cabec2       	 := " Hora   Seq    L  Peça  Cl/Tip Peso   |   "+;
	" Hora  Seq    L  Peça  Cl/Tip Peso      |   "+; 
	"Hora  Seq    L  Peça  Cl/Tip Peso"
	Local imprime      	:= .T.
	Local aOrd := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private Tamanho     := "M"
	Private nomeprog    := "GJF70" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   		:= "GJF70"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF70" // Coloque aqui o nome do arquivo usado para impressao em disco

	DbSelectArea('ZAJ')

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZAJ',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAJ')

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
	Local _nTotPesoL  := 0
	Local _nTotPeca   := 0
	Local _cCont      := 'F'
	Local _cCont2     := 0
	alert('Este relatório deverá ser revisado!')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SZ2->(DbSetOrder(4))
	SZ2->(DbSeek(xfilial('SZ2')+mv_par01))

	while SZ2->(!eof()) .and. SZ2->Z2_FILIAL = xfilial('SZ2') .and. SZ2->Z2_NUMAM = mv_par01

		if !empty(mv_par07)
			if  SZ2->Z2_CLASSIF <> mv_par07
				SZ2->(dbskip())
				loop
			endif
		endif

		If nLin > 70  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if _cCont2 <> 0
			nlin-=2
			@nlin,01 psay 'Quant. Realizada: ' + transform(_cCont2, '@E 9,999')
			_cCont2 := 0                 // contagem das peças
			nlin+= 2
		endif

		If nLin > 70  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif


		@nlin,02 psay 'Previsão Nr.: ' + SZ2->Z2_NUM
		nlin++

		If nLin > 70  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		@nlin,02 psay 'Ordem de Matança: ' + SZ2->Z2_NUMAM
		//@nlin,35 psay 'Data de Abate: ' + dtoc(SZ2->Z2_DTPROD)
		nlin++

		@nlin,02 psay 'Data de Abate: ' + dtoc(SZ2->Z2_DATAABT)
		@nlin,35 psay 'Classificação: ' + SZ2->Z2_CLASSIF
		@nlin,65 psay 'Programa: ' + iif(!empty(SZ2->Z2_PROGRAM),fBuscaCPO('SZ6',1,xfilial('SZ6')+SZ2->Z2_PROGRAM,'Z6_DESC'),'')
		if !empty(SZ2->Z2_TIPIFI)
			@nlin,50 psay 'Tipif.: ' + SZ2->Z2_TIPIFI
		endif
		nlin++

		If nLin > 70  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif



		@nlin,02 psay 'Tipo de Peça: ' + SZ2->Z2_DESCRI
		nlin++

		_cDataAM := dtoc(SZ2->Z2_DATAABT)

		_cNUMIF  := _GetParam()
		_cRastro := _cNUMIF + strtran(_cDataAM,'/','') +'0000'
		_dDtProd := ctod('')
		_lCol    := 1

		@nlin,02 psay 'Rastreabilidade: ' + _cRastro
		//@nlin,35 psay 'Quant. Realizada: ' + transform(SZ2->Z2_QRPECA, '@E 9,999')
		nlin += 2

		ZAJ->(DbSetOrder(4))
		ZAJ->(DbSeek(xfilial('ZAJ')+SZ2->Z2_NUM))

		While ZAJ->(!EOF()) .and. ZAJ->ZAJ_FILIAL = xfilial('ZAJ') .and. ZAJ->ZAJ_PREDES = SZ2->Z2_NUM

			//incregua()

			if empty(ZAJ->ZAJ_DATAS) .and. empty(ZAJ->ZAJ_HORAS)
				ZAJ->(DbSkip())
				loop
			endif    

			if !empty(ZAJ->ZAJ_PRECAR) .and. !empty(ZAJ->ZAJ_PREPED) .and. !empty(ZAJ->ZAJ_ITEM)
				ZAJ->(DbSkip())
				loop
			endif    


			if ZAJ->ZAJ_REGORI <> '0000000000'
				ZAJ->(DbSkip())
				loop
			endif

			if ZAJ->ZAJ_DATAS < mv_par04 .or. ZAJ->ZAJ_DATAS > mv_par05
				ZAJ->(dbskip())
				loop
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o cancelamento pelo usuario...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif

			If nLin > 70  // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			if _dDtProd <> ZAJ->ZAJ_DATAS	
				if _cCont2 > 0
					nlin += 2
					@nlin,01 psay 'Quant. Realizada: ' + transform(_cCont2, '@E 9,999')
					_cCont2 := 0                 // contagem das peças

					nlin += 2

					@nlin,01 psay 'Data da Produção: ' + dtoc(ZAJ->ZAJ_DATAS)
					_dDtProd := ZAJ->ZAJ_DATAS
					nlin++
					_lCol := 1
					_cCont := 'V'
				endif
			endif

			if _lCol = 1

				@nlin,01 psay ZAJ->ZAJ_HORAS
				@nlin,08 psay ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO)
				@nlin,23 psay ZAJ->ZAJ_LADO

				if ZAJ->ZAJ_CORORI = 'D'
					@nlin,26 psay 'Diant.'
				elseif ZAJ->ZAJ_CORORI = 'T'
					if ZAJ->ZAJ_TPTRASE = 'L'
						@nlin,26 psay 'T.Largo'
					elseif ZAJ->ZAJ_TPTRASE = 'L'
						@nlin,26 psay 'T.Estr.'
					else
						@nlin,26 psay 'Tras.'
					endif  

				endif

				_cClassif := fBuscaCPO('SZK',4,xfilial('SZK')+ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO),'ZK_CLASSIF')
				//	_cTip     := fBuscaCPO('SZK',4,xfilial('SZK')+ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO),'ZK_TIPIFI')

				@nlin,35 psay _cClassif
				//@nlin,29 psay _cTip

				//@nlin,32 psay transform(ZAJ->ZAJ_PESO,'@E 99.99')

				//_nTotPesoL += ZAJ->ZAJ_PESO
				_nTotPeca++

				_lCol := 2
				_cCont2++
			elseif _lCol = 2
				@nlin,38 psay '|'

				@nlin,42 psay ZAJ->ZAJ_HORAS
				@nlin,50 psay ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO)
				@nlin,66  psay ZAJ->ZAJ_LADO

				if ZAJ->ZAJ_COORI = 'D'
					@nlin,70 psay 'Diant.'
				elseif ZAJ->ZAJ_CORORI = 'T'
					if ZAJ->ZAJ_TPTRASE = 'L'
						@nlin,70 psay 'T.Largo'
					elseif ZAJ->ZAJ_TPTRASE = 'E' 
						@nlin,70 psay 'T.Estr.'  
					else
						@nlin,70 psay 'Tras.'  					
					endif
				endif

				_cClassif := fBuscaCPO('SZK',4,xfilial('SZK')+ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO),'ZK_CLASSIF')
				//	_cTip     := fBuscaCPO('SZK',4,xfilial('SZK')+ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO),'ZK_TIPIFI')

				@nlin,78 psay _cClassif
				//@nlin,71 psay _cTip

				//@nlin,76 psay transform(ZAJ->ZAJ_PESO,'@E 99.99')

				//_nTotPesoL += ZAJ->ZAJ_PESO
				_nTotPeca++
				_lCol := 3
				_cCont2++
			elseif _lCol = 3
				@nlin,82 psay '|'

				@nlin,86 psay ZAJ->ZAJ_HORAS
				@nlin,94 psay ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO)
				@nlin,110  psay ZAJ->ZAJ_LADO

				if ZAJ->ZAJ_COORI = 'D'
					@nlin,112 psay 'Diant.'
				elseif ZAJ->ZAJ_COORI = 'T'
					if ZAJ->ZAJ_TPTRASE = 'L'
						@nlin,112 psay 'T.Largo'
					elseif ZAJ->ZAJ_TPTRASE = 'E' 
						@nlin,112 psay 'T.Estr.' 
					else                        
						@nlin,112 psay 'Tras.' 
					endif
				endif

				_cClassif := fBuscaCPO('SZK',4,xfilial('SZK')+ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO),'ZK_CLASSIF')
				//_cTip     := fBuscaCPO('SZK',4,xfilial('SZK')+ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO),'ZK_TIPIFI')

				@nlin,120 psay _cClassif
				//@nlin,115 psay _cTip
				//@nlin,118 psay transform(ZAJ->ZAJ_PESO,'@E 99.99')

				//_nTotPesoL += ZAJ->ZAJ_PESO
				_nTotPeca++
				_lCol := 1
				nlin++
				_cCont2++
			endif


			ZAJ->(dbSkip()) // Avanca o ponteiro do registro no arquivo


		EndDo

		nlin += 3
		SZ2->(dbskip())

	enddo
	nlin-=2
	@nlin,01 psay 'Quant. Realizada: ' + transform(_cCont2, '@E 9,999')


	If nLin > 70  // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif  

	nlin+=3

	@nlin,02 psay "TOTAL DE PEÇAS:     " + transform(_nTotPeca ,'@E 999,999')

	nlin++

	//@nlin,02 psay "PESO TOTAL LIQUIDO: " + transform(_nTotPesoL,'@E 999,999.99')


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

Static Function _GetParam()

	_cRet := GetMv("MV_NUMIF")

Return(_cRet)
