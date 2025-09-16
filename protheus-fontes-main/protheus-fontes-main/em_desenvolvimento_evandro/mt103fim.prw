#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function MT103FIM()

	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³MT103FIM  ºAutor  ³                    º Data ³             º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDesc.     ³O ponto de entrada MT103FIM encontra-se no final da função  º±±
	±±º          ³A103NFISCAL. Após o destravamento de todas as tabelas       º±±
	±±º          ³envolvidas na gravação do documento de entrada, depois de   º±±
	±±º          ³fechar a operação realizada neste, é utilizado para realizarº±±
	±±º          ³alguma operação após a gravação da NFE.                     º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³                                                            º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/

	Local aArea		:= GetArea()
	Local aSD1		:= SD1->(GetArea())
	Local aSC7		:= SC7->(GetArea())
	Local nOpcao    := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina
	Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO
	Local lConfirma := PARAMIXB[2]==1
	Local cPed		:= ""
	Local cItPed	:= ""
	Local cSol		:= ""
	Local cItSol	:= ""
	Local cUpdate	:= ""
	Local cQuery	:= ""
	Local nErro:= 0

	If lConfirma
		If nOpcao == 3 .Or. nOpcao == 4
			SD1->(dbSetOrder(1))
			SD1->(MsSeek(FWxFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
			Do While !SD1->(EOF()) .AND. FWxFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
				cPed:= SD1->D1_PEDIDO
				cItPed:= SD1->D1_ITEMPC
				SC7->(dbSetOrder(1))
				If SC7->(MsSeek(FWxFilial("SC7")+cPed+cItPed))
					cSol:= SC7->C7_NUMSC
					cItSol:= SC7->C7_ITEMSC
					If !Empty(cSol) .AND. !Empty(cItSol)
						cUpdate:= "UPDATE "+RetSqlName("ZP4")+" SET ZP4_DTEPC = '"+DtoS(Date())+"', ZP4_STATUS = '3 - Disponivel' WHERE ZP4_FILIAL = '"+FWxFilial("ZP4")+"' AND ZP4_SOLC = '"+cSol+"' AND ZP4_ITEMSC = '"+cItSol+"' AND D_E_L_E_T_ = ''"
						nErro:= TCSqlExec(cUpdate)
						If nErro < 0
							//MemoWrite('MT120FIM1.TXT', cUpdate+"||"+TCSQLError())
						EndIf
						cQuery:= "SELECT DISTINCT ZP4_CODIGO FROM "+RetSqltAB("ZP4")+" WHERE ZP4_FILIAL = '"+FWxFilial("ZP4")+"' AND ZP4_SOLC = '"+cSol+"' AND ZP4_ITEMSC = '"+cItSol+"' AND D_E_L_E_T_ = ''"
						cUpdate:= "UPDATE "+RetSqlName("ZP2")+" SET ZP2_DTFSC = '"+DtoS(Date())+"', ZP2_DTENT = '"+DtoS(Date())+"' WHERE ZP2_FILIAL = '"+FWxFilial("ZP2")+"' AND ZP2_CODIGO IN ("+cQuery+") AND D_E_L_E_T_ = ''"
						//u_PS100MNT(cSol, "Solicitacao '"+cSol+" ("+"Material disponível"+")", ZP2->ZP2_HIST+"<br>"+"Data "+DtoC(Date())+" as "+Time())
						u_PS100MNT(cSol, "Solicitacao '"+cSol+" ("+"Material disponivel"+")","<br>"+"Data "+DtoC(Date())+" as "+Time(), "almoxarifado@frigorificosilva.com.br")
						nErro:= TCSqlExec(cUpdate)
						If nErro < 0
							//MemoWrite('MT120FIM2.TXT', cUpdate+"||"+TCSQLError())
						EndIf
					EndIf
					if SD1->D1_FORMUL == "S" .and. SD1->D1_SERIE = "50"
						reclock("SD1",.f.)
						SD1->D1_DESCRI := alltrim(SC7->C7_DESCRI)
						msunlock()
					endif
				EndIf
				SD1->(DbSkip())
			Enddo
		EndIf	
	EndIf

	// Customização criada para encerrar a Autorização de Devolução na tabela ZH2
	// --------- Início
	If nConfirma = 1            		// Se confirmou
		If nOpcao == 4         			// Se classificação
			If SF1->F1_TIPO == "D"		// Se devolução
				// Atualiza status na tabela ZH2
				DbSelectArea("ZH2")
				DbSetOrder(1)
				If DbSeek(FWxFilial("ZH2") + SF1->F1_NUMREC)
					DbSelectArea("ZH2")
					RecLock("ZH2", .F.)
					ZH2->ZH2_STATUS := "4"
					MsUnlock()
				EndIf
			EndIf
        EndIf

		If nOpcao == 5         			// Se estorno classificação
			If SF1->F1_TIPO == "D"		// Se devolução
				// Atualiza status na tabela ZH2
				DbSelectArea("ZH2")
				DbSetOrder(1)
				If DbSeek(FWxFilial("ZH2") + SF1->F1_NUMREC)
					DbSelectArea("ZH2")
					RecLock("ZH2", .F.)
					ZH2->ZH2_STATUS := "3"
					MsUnlock()
				EndIf
			EndIf
        EndIf

    EndIf
	// --------- Fim

	RestArea(aSC7)
	RestArea(aSD1)
	RestArea(aArea)

	// Executado devido problema no final da gravação de notas de devolução via opção "Retornar"
	If Select("TMP") != 0
		TMP->(DbCloseArea())
	Endif

Return
