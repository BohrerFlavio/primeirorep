#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} TMA144BUT 
@Type			: Ponto de Entrada
@Sample			: U_TMA144BUT()
@Description	: Ponto de Entrada, localizado no TMSA144 (Geração de Viagens Mod.2),]
                  é utilizado para incluir botões na EnchoiceBar desta rotina.
@Param			: Nenhum
@Return			: aBotoesPE - Vetor - Array contendo os botões a serem adicionados
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro
@Since			: Ago/2022
@version		: Protheus 12
@Comments		: Utilizado para carregar os documentos da viagem pelo lote informado.
/*/
//--------------------------------------------------------------------------------------
User Function TMA144BUT()

	Local aBotoesPe := {}

	Aadd(aBotoesPE, {'PRECO', {|| U_DOCSLOTE() }, 'Doctos por Lote (Silva)'})

Return aBotoesPe

//-----------------------------------------------------------------------------
/*/{Protheus.doc} DOCSLOTE
Funcao de busca dos documentos por lote informado
@author     Evandro Mugnol
@since      Ago/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function DOCSLOTE()

	Local cPerg   := "DOCSLOTE"
	Local cCodbar := Space(Len(DT6->DT6_CHVCTE) + 1)
	Local oGetBar
    Local nX

	If Pergunte(cPerg,.T.)
		cQuery := "SELECT * "
		cQuery += "  FROM " + RetSQLTab("DT6")
		cQuery += " WHERE " + RetSQLFil("DT6")
		cQuery += "   AND DT6_LOTNFC = '" + MV_PAR01 + "'"
		cQuery += "   AND " + RetSQLDel("DT6")

		cQuery := ChangeQuery(cQuery)

		If Select("QRY") <> 0
			QRY->(DbCloseArea())
		Endif

		TCQUERY cQuery NEW ALIAS "QRY"

		QRY->(dbGoTop())
		While QRY->(!Eof())
			cCodBar := QRY->DT6_CHVCTE

			Tmsa210Lot(@cCodBar,@oGetBar)

			QRY->(DbSkip())
		Enddo

		QRY->(DbCloseArea())

        // Percorre aCols para atualizar sequencias
        For nX:=1 To Len(aCols)
            Acols[nx][1] := StrZero(Val(Soma1(cValToChar(nX-1))),3,0)
        Next

	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsa210Lot
Função que realiza a consulta se a chave informada na leitura do
documento existe. 
@author     Evandro Mugnol
@since      Ago/2022
@version    1.0
/*/
//-------------------------------------------------------------------
Static Function Tmsa210Lot(cCodBar,oGetBar)
	Local lRet 	  := .T.
	Local nI 	  := 1
	Local lAddRow := .F.
	
    Default cCodBar	:= ""

	If !Empty(cCodbar)
		DbSelectArea("DT6")

		If FindFunction('TmsVLDSIX') .And. TmsVLDSIX("DT6","I")
			DT6->(dbSetOrder(18))

			If !Empty(cCodBar) .And. DT6->(dbSeek(xFilial("DT6") + cCodBar))

				If Ascan(aCols,{ |x| x[DTA->(GdFieldPos('DTA_FILDOC'))] + x[DTA->(GdFieldPos('DTA_DOC'))] + x[DTA->(GdFieldPos('DTA_SERIE'))] == DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE}) == 0
					nI := Len(aCols)

					If !Empty( aCols[nI][DTA->(GdFieldPos('DTA_FILDOC'))] ) .And.;
					   !Empty( aCols[nI][DTA->(GdFieldPos('DTA_DOC'   ))] ) .And.;
					   !Empty( aCols[nI][DTA->(GdFieldPos('DTA_SERIE' ))] )

						// Adiciona uma nova linha no Acols
						lAddRow := .T.
						aAdd(aCols, Array(Len(aHeader)+1))
						For nI := 1 To Len(aHeader)
							aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
						Next nI

						nI := Len(aCols)

						If cSerTms != StrZero(2,Len(DC5->DC5_SERTMS))                   // Nao for Transporte (Mesma logica utilizada na montagem do aCols no fonte tmsa144)
							If type(aCols[nI][DTA->(GdFieldPos('DTA_SERIE' ))]) != "U"  // Verifica se campo nao nulo
								aCols[nI][DTA->(GdFieldPos('DUD_SEQUEN'))] := StrZero(nI, Len(DUD->DUD_SEQUEN))
							EndIf
						EndIf
						aCols[nI][Len(aHeader)+1] := .F.

						oGetD:oBrowse:nAt := nI
						n:= nI
					EndIf

					GdFieldPut('DTA_FILDOC', DT6->DT6_FILDOC,  nI)
					GdFieldPut('DTA_DOC'   , DT6->DT6_DOC,     nI)
					GdFieldPut('DTA_SERIE' , DT6->DT6_SERIE,   nI)

					M->DTA_FILDOC := DT6->DT6_FILDOC

					If !TmsA210Val('M->DTA_FILDOC')
						If lAddRow
							aDel(aCols,nI)
							aSize(aCols,Len(aCols)-1)
							nI--
							oGetD:oBrowse:nAt := nI
							n:= nI
						Else
							GdFieldPut('DTA_FILDOC', '', nI)
							GdFieldPut('DTA_DOC',    '', nI)
							GdFieldPut('DTA_SERIE' , '', nI)
						EndIf
					Endif

					cCodBar := Space(Len(DT6->DT6_CHVCTE) + 1)
				Else
					Help ("",1,"TMSA21060")     // Documento informado anteriormente.
					lRet := .F.
					cCodBar := Space(Len(DT6->DT6_CHVCTE) + 1)
				Endif
			ElseIf !Empty(cCodBar)
				Help ("",1,"TMSA21059")         // Chave de Documento não localizada ou inválida
				lRet := .F.
				cCodBar := Space(Len(DT6->DT6_CHVCTE) + 1)
			EndIf

			oGetD:oBrowse:Refresh(.T.)
		EndIf
	Else
		cCodBar := Space(Len(DT6->DT6_CHVCTE) + 1)
		lRet := .F.
	EndIf

Return lRet
