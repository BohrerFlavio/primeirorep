#INCLUDE "PROTHEUS.CH"

/*/´
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SIGMB ³ Autor ³ Giuliano Forgiarini                         ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alternativa para o FsGmb2004                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: [1] Total da coluna Valor Contabil                   ³±±
±±³          ³ExpA1: [2] Total da coluna Base de ICMS                     ³±±
±±³          ³ExpA1: [3] Total da coluna Isentas                          ³±±
±±³          ³ExpA1: [4] Total da coluna Outras                           ³±±
±±³          ³ExpA1: [5] Total da coluna ICMS Retido                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
User Function SIGMB()
	Local _aArqTrb  := {} // ProcData 04/2023
	Local cAliasSF3 := "SF3"
	Local nIndex    := 0
	Local cQuery    := ""
	Local cArqTrab  := ""
	Local cArq      := ""
	Local cArq1     := ""
	Local cKey      := ""
	Local cChave    := ""
	Local cCondicao := ""
	Local aStru     := {}
	Local cCfoComp  := "1101/1102/1116/1117/1118/1122/1151/1152/1451/1556"
	Local cCodMuni  := SuperGetMv("MV_CODMGMB")
	Local nX        := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria arquivos temporarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStru,{"CODMUN"  ,"C",003,0})
	AADD(aStru,{"VALCONT" ,"N",014,2})
	AADD(aStru,{"IEPRODUT","C",010,0})

	//ProcData 04/2023 
	//cArq :=	CriaTrab(aStru)
	//dbUseArea(.T.,__LocalDriver,cArq,"TR2")
	
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TR2", aStru, {}, @_aArqTrb)
	
	
	//IndRegua("TR2",cArq,"IEPRODUT") 

	dbSelectArea("SF3")
	dbSetOrder(3)
	#IFDEF TOP
	cAliasSF3 := "GMBSF3"
	aStru  := SF3->(dbStruct())
	cQuery := "SELECT F3_CFO, F3_VALCONT, F3_CLIEFOR, F3_LOJA, F3_ISENICM, F3_OUTRICM "
	cQuery += "FROM "+RetSqlName("SF3")+" "
	cQuery += "WHERE F3_FILIAL='"+xFilial("SF3")+"' AND "
	cQuery += "F3_EMISSAO >='"+Dtos(dDmainc)+"' AND "
	cQuery += "F3_EMISSAO <='"+Dtos(dDmaFin)+"' AND "	
	cQuery	+= "(F3_CFO LIKE '1%' OR F3_CFO LIKE '2%' OR F3_CFO LIKE '3%') AND "
	cQuery += "F3_DTCANC = '"+Space(Len(Dtos(SF3->F3_DTCANC)))+"' AND "
	cQuery += "F3_OBSERV NOT LIKE '%CANCELAD%' AND "
	cQuery += "D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY "+SqlOrder(SF3->(IndexKey()))

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)

	For nX := 1 To Len(aStru)
		If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
			TcSetField(cAliasSF3,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
	#ELSE 
	cArqTrab  := CriaTrab(NIL,.F.)
	cKey	   := SF3->(IndexKey())
	cCondicao := 'F3_FILIAL=="'+xFilial("SF3")+'".And.'
	cCondicao += 'DTOS(F3_EMISSAO)>="'+DTOS(dDmainc)+'".And.DTOS(F3_EMISSAO)<="'+DTOS(dDmaFin)+'"'
	cCondicao += '.And. SubStr(F3_CFO,1,1)$"1,2,3"'
	cCondicao += '.And. Empty(F3_DTCANC) .And. !("CANCELAD"$F3_OBSERV)'

	IndRegua(cAliasSF3,cArqTrab,cKey,,cCondicao)
	nIndex := RetIndex("SF3")
	dbSelectArea("SF3")
	dbSetIndex(cArqTrab+OrdBagExt())

	dbSetOrder(nIndex+1)
	dbGoTop()
	#ENDIF	

	dbSelectArea(cAliasSF3)

	While (cAliasSF3)->(!Eof())

		If AllTrim((cAliasSF3)->F3_CFO) $ AllTrim(cCfoComp) .And. (cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM > 0
			dbSelectArea("SA2")
			dbSetOrder(1)
			If dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA) .And. !Empty(SA2->A2_TIPORUR)
				If !Empty(cCodMuni) .AND. !Empty(SA2->&(cCodMuni))
					dbSelectArea("TR2")
					cChave := Left(ARETDIG(SA2->A2_INSCR,.F.),10)
					If !dbSeek(cChave)
						Reclock("TR2",.T.)
						TR2->CODMUN   := Left(SA2->&(cCodMuni),3)
						TR2->IEPRODUT := cChave
					Endif
					Reclock("TR2",.F.)	
					TR2->VALCONT  += (cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM
					MsUnlock()
				Endif
			Endif
		Endif
		(cAliasSF3)->(dbSkip())
	Enddo

	#IFDEF TOP
	dbSelectArea(cAliasSF3)
	dbCloseArea()
	#ELSE 
	dbSelectArea("SF3")
	RetIndex("SF3")
	dbClearFilter()
	Ferase(cArqTrab+OrdBagExt())
	#ENDIF	
	
	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 
Return(cArq)
