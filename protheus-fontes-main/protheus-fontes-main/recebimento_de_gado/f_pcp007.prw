#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³f_pcp007  º Autor ³ AP6 IDE            º Data ³  20/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Geracao da ordem de recebimento                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User function F_PCP007()
	cPerg := "PCP007"

	if !Pergunte(cPerg,.t.) 
		return()
	endif

	Processa({||gerar(),"Aguarde","Gerando ordem de recebimento..."})

Return
//
//
//
Static Function gerar()
	Local ix
	Private codFor

	ProcRegua(3)

	Begin Transaction

		SZA->( dbSetOrder(1) )
		SZA->( dbSeek( xFilial('SZA')+mv_par01 ) ) 

		While ! SZA->( Eof() ) .AND. SZA->ZA_NUMERO <= mv_par02

			codFor := SZA->ZA_CODFOR+SZA->ZA_LOJA //novo aviso de recebimento por produtor
			SA2->( dbSetOrder(1))
			SA2->( dbSeek(xFilial('SA2')+codFor  ) )  // codigo

			Private numero := GetSx8num('SZD','ZD_NUMERO')
			Private item      := 1
			Private nAnimais  := 0

			mObs := ''

			While ! SZA->(eof()) .AND. SZA->ZA_NUMERO <=mv_par02  .and. codFor == SZA->ZA_CODFOR+SZA->ZA_LOJA
				if SZA->ZA_ABATE < mv_par03 .or. SZA->ZA_ABATE > mv_par04
					SZA->(DbSkip())
					loop
				endif

				//Verifica se para esta Sc não foi gravado a Ordem de recebimento
				If !Empty(SZA->ZA_ORDREC)
					SZA->( dbSkip() )
					Loop
				Endif

				//Percorre os itens da Sc
				SZ9->( dbSetOrder(1))
				SZ9->( dbSeek(xFilial('SZ9')+SZA->ZA_NUMERO  ) ) //filial+Sc

				mObs += SZA->ZA_OBS

				While !SZ9->(Eof()) .AND. SZ9->Z9_NUMERO == SZA->ZA_NUMERO

					//Grava itens, caso rastreado - abre para cada qtde. unitaria
					Private qtos := If( SZ9->Z9_RASTRO <> 'S', 1, SZ9->Z9_QUANT )
					//Private ix

					For ix := 1 To qtos
						SB1->( dbSeek( xFilial('SB1')+SZ9->Z9_PRODUTO ) )
						//Grava itens
						dbSelectArea('SZE')
						RecLock('SZE',.T.)
						SZE->ZE_FILIAL     := xFilial('SZD')
						SZE->ZE_NUMERO     := numero
						SZE->ZE_ITEM       := Strzero(item,3)
						SZE->ZE_PRODUTO    := SZ9->Z9_PRODUTO
						SZE->ZE_DESCRI     := SB1->B1_DESC
						SZE->ZE_RASTRO     := SPACE(18)
						SZE->ZE_QTD1UM     := If( SZ9->Z9_RASTRO == 'S', 1, SZ9->Z9_QUANT )
						SZE->ZE_UM         := SZ9->Z9_UM
						//SZE->ZE_QTD2UM     := SZ9->Z9_PESO
						SZE->ZE_SEGUM      := 'KG
						SZE->ZE_LOCAL      := SZ9->Z9_LOCAL
						SZE->ZE_CATEG      := SZ9->Z9_CATEG
						SZE->ZE_RACA       := SZ9->Z9_RACA
						SZE->ZE_NUMSC      := SZ9->Z9_NUMERO
						SZE->ZE_ITEMSC     := SZ9->Z9_ITEM
						SZE->ZE_TPCOM      := SZA->ZA_TPCOM
						SZE->ZE_OBS        := '0'  //inicia como ok
						SZE->ZE_PROGRAM    := SZ9->Z9_PROGRAM
						Msunlock()
						item++
						nAnimais += If( SZ9->Z9_RASTRO == 'S', 1, SZ9->Z9_QUANT )

					Next ix

					//Atualiza a qtde entregue da Sc
					dbSelectArea('SZ9')
					RecLock('SZ9',.F.)
					SZ9->Z9_QTDENT := SZ9->Z9_QUANT
					MsUnlock()
					SZ9->(dbSkip()) //proximo item sc
				Enddo

				//Atualizao o numero da ordem de recebimento na SC
				dbSelectArea('SZA')
				RecLock('SZA',.F.)
				SZA->ZA_ORDREC := numero
				MsUnlock()

				SZA->( dbSkip() ) // proxima SC
				IncProc()

			Enddo

			//Grava cabecalho da ordem de recebimento
			dbSelectArea('SZD')
			RecLock('SZD',.T.)
			SZD->ZD_FILIAL     :=  xFilial('SZD')
			SZD->ZD_NUMERO     :=  numero
			SZD->ZD_FORNECE    :=  SA2->A2_COD
			SZD->ZD_LOJA       :=  SA2->A2_LOJA
			SZD->ZD_DATA       :=  CTOD('')
			SZD->ZD_HORA       :=  '00:00'
			SZD->ZD_MUN        :=  SA2->A2_MUN
			//	SZD->ZD_GTA        :=  ''
			//	SZD->ZD_PESOANT    :=  0.00
			//	SZD->ZD_PESODEP    :=  0.00
			//	SZD->ZD_FRETE      :=  ordFrete
			SZD->ZD_QTDTOT     :=  nAnimais

			SZD->ZD_OBSC       :=  mobs

			MsUnlock()

			confirmsx8()
			// proxima ordem de recebimento
		Enddo

	End Transaction
Return


//
//Calcula valor do frete
//
User Function PCP007VL()
	Local l
	Local v
	nVal := 0
	SZH->(dbSetOrder(2))

	if M->ZD_TPFRETE == 'C'
		return 0
	Endif

	For v:=1 to 3  // veiculos
		cVei := &('M->ZD_VEIC'+str(v,1))
		nVei := &('M->ZD_QTVE'+str(v,1))
		nVl  := 0
		cMd  := ''
		IF !empty(cVei) .and. SZH->(dbseek(xFilial('SZH')+M->ZD_TRANSP+cVei))
			for l:=1 to 6  //limites de peso
				nKm := &('SZH->ZH_KM'+str(l,1))
				nVl := &('SZH->ZH_VL'+str(l,1))
				cMd := &('SZH->ZH_CALC'+str(l,1))

				if  nVl == 0 .or. nKm == 0 .or. nkm > M->(ZD_DASFPRE+ZD_DCHPREV)
					EXIT
				endif

			next
		Endif

		If cMd == 'M'
			nVal += nVl*(M->(ZD_DASFPRE+ZD_DCHPREV))*nVei
			nVeic :=  nVl*(M->(ZD_DASFPRE+ZD_DCHPREV))*nVei
		else
			nVal  += nVl*nVei
			nVeic := nVl*nVei
		Endif
		&('M->ZD_VAVE'+str(v,1)) := nVeic
		//M->ZD_VAVE1 := nVeic
	Next

Return nVal                        


