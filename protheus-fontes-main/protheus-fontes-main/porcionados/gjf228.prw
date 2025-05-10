#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF228     ºAutor  ³Giuliano Forgiariniº Data ³  18/09/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Relatorio de conferencia do conteúdo de materia-prima a  º±±
±±º          ³   ser recebida na camara de estocagem de MP                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Porcionados Expedições e câmaras                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function GJF228()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatório"
	Local cDesc2         := "de conferencias de caixas de MP a serem recebidas "
	Local cDesc3         := "pela indústria de pordionados"
	Local cPict          := ""
	Local titulo         := "P04 - CONFERENCIA DE RECEBIMENTO DE MATÉRIA-PRIMA PROPRIA"
	Local Cabec1         := " Num. OP        Dt. Prod.    Produto           Descrição              Peso Prev.    Peso Real.     Caixas Prev.  Caixas Real.    "
	Local Cabec2         := " Cod.Caixa      Produto         Descrição                      Peso liq.     Dt. Recebim.    Local      Visto       "
	Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "GJF228"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0

	//Vai usar o mesmo grupo de produtos GJF222
	Private cPerg   		:= "GJF228"

	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF228"
	Private _aBatidas  	:= {}
	
	
	
	
	

	pergunte(cPerg,.F.)


	wnrel := SetPrint('SZU',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZU')

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
	Local 	nCont := 0
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_sif := alltrim(GETMV('MV_NUMIF'))

	SZU->(SetRegua(RecCount()))

	SZU->(DbSetOrder(1))
	SZU->(dbGoTop())
	SZU->(DbSeek(xfilial('SZU') + dtos(mv_par01),.t.))
	while SZU->(!eof())  .and. SZU->ZU_FILIAL = xfilial('SZU') .and. SZU->ZU_DTRPRO <= mv_par02 //.AND. SZU->ZU_QRCAIX <> 0
			
		incregua()
		
		IF SZU->ZU_QRCAIX > 0
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
			
			
			if empty(alltrim(SZU->ZU_MPPORC))
				SZU->(DbSkip())
				loop
			endif
			
			_cData  := dtoc(fbuscaCPO('SZ2',2,xfilial('SZ2')+SZU->ZU_PREDES,'Z2_DATAABT'))
	
			@nlin,00 psay replicate('-',132)
			nlin++
	
			@nlin,001 psay SZU->ZU_NUM
			@nlin,016 psay SZU->ZU_DTRPRO 
			@nlin,029 psay alltrim(SZU->ZU_COD)
			@nlin,040 psay substr(SZU->ZU_DESC,1,25)
			@nlin,068 psay transform(SZU->ZU_QPPESO,'@E 999,999.99')
			@nlin,081 psay transform(SZU->ZU_QRPESO,'@E 999,999.99')
			@nlin,098 psay transform(SZU->ZU_QPCAIX,'@E 999,999')
			@nlin,112 psay transform(SZU->ZU_QRCAIX,'@E 999,999')
	
			nlin++
	
			@nlin,001 psay 'Código de Rastreabilidade:   ' + _sif + '' + strtran(_cData, '/','') + '0000'
			nlin++
			nlin++
			
			if mv_par03 = 1
	
				ZAS->(DbSetOrder(4))
				if ZAS->(DbSeek(xfilial('ZAS') + SZU->ZU_NUM))
				
					while ZAS->(!eof()) .and. ZAS->ZAS_PREEMB = SZU->ZU_NUM
	
						If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif
						If mv_par04 = 1 .and. !empty(ZAS->ZAS_DTRMP)
							@nlin,001 psay ZAS->ZAS_CONTRO
							@nlin,016 psay ZAS->ZAS_COD
							@nlin,026 psay substr(ZAS->ZAS_DESC,1,25)
							@nlin,065 psay transform(ZAS->ZAS_PESOL,'@E 999.99')
							@nlin,080 psay dtoc(ZAS->ZAS_DTRMP)
							@nlin,095 psay ZAS->ZAS_LOCAL
							@nlin,105 psay '[ OK ]'
							nlin++
							nCont++
						ELSEIf mv_par04 = 2 .and. empty(ZAS->ZAS_DTRMP)	
							@nlin,001 psay ZAS->ZAS_CONTRO
							@nlin,016 psay ZAS->ZAS_COD
							@nlin,026 psay substr(ZAS->ZAS_DESC,1,25)
							@nlin,065 psay transform(ZAS->ZAS_PESOL,'@E 999.99')
							@nlin,080 psay dtoc(ZAS->ZAS_DTRMP)
							@nlin,095 psay ZAS->ZAS_LOCAL
							@nlin,105 psay '[  ]'
							nlin++
							nCont++
						

						elseif mv_par04 = 3

							ZAS->(DbSetOrder(4))
							if ZAS->(DbSeek(xfilial('ZAS') + SZU->ZU_NUM))

								while ZAS->(!eof()) .and. ZAS->ZAS_PREEMB = SZU->ZU_NUM

								If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
								Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
								nLin := 9
								Endif

								@nlin,001 psay ZAS->ZAS_CONTRO
								@nlin,016 psay ZAS->ZAS_COD
								@nlin,026 psay substr(ZAS->ZAS_DESC,1,25)
								@nlin,065 psay transform(ZAS->ZAS_PESOL,'@E 999.99')
								@nlin,080 psay dtoc(ZAS->ZAS_DTRMP)
								@nlin,095 psay ZAS->ZAS_LOCAL
								@nlin,105 psay iif(!empty(ZAS->ZAS_DTRMP), '[ OK ]','[    ]')
								nlin++

								ZAS->(DbSkip())
								enddo

								nlin++

							endif
						endif
						
						
								

												
	
						ZAS->(DbSkip())
					enddo
					
					nlin++
	
				endif
			endif
			
		
			
			/* Novo 
			
			IF nCont > 0
					_sif := alltrim(GETMV('MV_NUMIF'))
				_cData  := dtoc(fbuscaCPO('SZ2',2,xfilial('SZ2')+SZU->ZU_PREDES,'Z2_DATAABT'))
				
		
				@nlin,00 psay replicate('-',132)
				nlin++
		
				@nlin,001 psay SZU->ZU_NUM
				@nlin,016 psay SZU->ZU_DTRPRO 
				@nlin,029 psay alltrim(SZU->ZU_COD)
				@nlin,040 psay substr(SZU->ZU_DESC,1,25)
				@nlin,068 psay transform(SZU->ZU_QPPESO,'@E 999,999.99')
				@nlin,081 psay transform(SZU->ZU_QRPESO,'@E 999,999.99')
				@nlin,098 psay transform(SZU->ZU_QPCAIX,'@E 999,999')
				@nlin,112 psay transform(SZU->ZU_QRCAIX,'@E 999,999')
		
		
				nlin++
		
				@nlin,001 psay 'Código de Rastreabilidade:   ' + _sif + '' + strtran(_cData, '/','') + '0000'
				nlin++
				nlin++
			endif
			*/
			
		
		Endif
			SZU->(DbSkip())
	enddo
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


