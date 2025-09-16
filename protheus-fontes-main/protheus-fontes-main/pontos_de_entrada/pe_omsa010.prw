#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} OMSA010
@Type			: Ponto de Entrada
@Sample			: U_OMSA010()
@Description	: Ponto de entrada na tabela de preco dos produtos
@Param			: aParam - PARAMIXB
@Return			: .T. ou .F.
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2023
@version		: Protheus 12.1.2210 e posteriores
@Comments		: Por se tratar de um p.e. em MVC, salve o nome do arquivo diferente, 
				  por exemplo, PE_OMSA010.PRW
/*/
//--------------------------------------------------------------------------------------
User Function OMSA010()

	Local _aArea   := FWGetArea()
	Local aParam   := PARAMIXB
	Local lRet 	   := .T.
	Local oObj 	   := Nil
	Local cIdPonto := ""
	Local cIdModel := ""

	// Variáveis usadas na tratativa de percorrer a grid
	Local nLinha     := 0
	Local aAreaDA1   := {}
	Local aSaveLines := {}
	Local nAlterados := 0
	Local oModelPad  := Nil
	Local oModelGrid := Nil
	Local cCodTab    := ""

	Private _oTela, _oConfir, _bOk
	Private _cTitulo    := OemToAnsi("Tabela de Custos de Produtos")
	Private _cTabCus    := Space(04)
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)

	// Rodar somente na empresa 01
	If cEmpAnt == "01"

		// Se tiver parametros
		If aParam != Nil

			// Pega informacoes dos parametros
			oObj 	 := aParam[1]
			cIdPonto := aParam[2]
			cIdModel := aParam[3]

			// Validação ao clicar no Botão Confirmar
			If cIdPonto == "MODELPOS"
				lRet := .T.

				_cTabCus := Space(04)

				DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(100), C(700) PIXEL
				@ C(003), C(035) SAY "Informe a Tabela de Custos de Produtos Para Geração de LOG DE ATUALIZAÇÃO"  Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED PIXEL OF _oTela

				@ C(025), C(010) SAY "Tabela de Custo:" 		       								Size C(080), C(10) FONT _oFtArial24 COLOR CLR_GREEN PIXEL OF _oTela
				@ C(025), C(070) MSGET _cTabCus Picture "@!" When .T. Valid VldTab() F3 "Z05MVC"	Size C(045), C(08) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

				DEFINE SBUTTON FROM C(033), C(290) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

				ACTIVATE MSDIALOG _oTela CENTERED

				_cNumAtu := GETSXENUM("Z08","Z08_NUMATU")
				ConfirmSX8()

				// Define as variáveis que serão usadas
				aAreaDA1   := DA1->(FWGetArea())
				aSaveLines := FWSaveRows()
				nAlterados := 0

				// Pegando os modelos de dados
				oModelPad  := FWModelActive()
				oModelGrid := oModelPad:GetModel('DA1DETAIL')
				cCodTab    := oModelPad:GetValue("DA0MASTER", "DA0_CODTAB")

				DbSelectArea("DA1")
				DA1->(DbSetOrder(3)) //DA1_FILIAL + DA1_CODTAB + DA1_ITEM

				// Percorrendo a grid com os itens
				For nLinha := 1 To oModelGrid:Length()

					// Posicionando na linha atual
					oModelGrid:GoLine(nLinha)

					// Se a linha nao estiver deletada
					If !oModelGRID:IsDeleted()

						// Efetua gravação do logs de atualizacao DA1 X Z07 para utilizacao do BI
						_aDadosSB1 := GetAdvFVal("SB1", {"B1_CODCUS" , "B1_DESC"   }, xFilial("SB1") + oModelGrid:GetValue("DA1_CODPRO") , 1, {Space(TamSx3("B1_CODCUS")[1]) , Space(TamSx3("B1_DESC")[1])} , .T.)
						_aDadosZ07 := GetAdvFVal("Z07", {"Z07_CODCUS", "Z07_PRCCUS"}, xFilial("Z07") + _cTabCus + _aDadosSB1[1] 		 , 2, {Space(TamSx3("Z07_CODCUS")[1]), 0						  } , .T.)
						_cDescrZ03 := GetAdvFVal("Z03", "Z03_DESCUS"                , xFilial("Z03") + _aDadosSB1[1]            		 , 1, Space(TamSx3("Z03_DESCUS")[1]) 							    , .T.)

						DbSelectArea("Z08")
						RecLock("Z08", .T.)
						Z08->Z08_FILIAL := xFilial("Z08")
						Z08->Z08_NUMATU := _cNumAtu
						Z08->Z08_DATATU := DATE()
						Z08->Z08_USUATU := AllTrim(UsrFullName(__CUSERID))
						Z08->Z08_TABDA1 := oModelGrid:GetValue("DA1_CODTAB")
						Z08->Z08_CODDA1 := oModelGrid:GetValue("DA1_CODPRO")
						Z08->Z08_DESDA1 := _aDadosSB1[2]
						Z08->Z08_PRCDA1 := oModelGrid:GetValue("DA1_PRCVEN")
						Z08->Z08_TABZ07 := _cTabCus
						Z08->Z08_CODZ07 := _aDadosZ07[1]
						Z08->Z08_DESZ07 := _cDescrZ03
						Z08->Z08_PRCZ07 := _aDadosZ07[2]
						Z08->Z08_ORIGEM := "PE_OMSA010"
						MsUnLock()
					EndIf
				Next

				FWRestRows(aSaveLines)
				FWRestArea(aAreaDA1)

			EndIf
		EndIf
	EndIf

	FWRestArea(_aArea)

Return lRet


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Consistencia no Vendedor                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VldTab()

	DbSelectArea("Z05")
	DbSeek(xFilial("ZO5") + _cTabCus)
	If Found()
		lVal := .T.
	Else
		lVal := .F.
		MsgAlert("Tabela de Custo Inválida. Informe uma Tabela de Custo Válida!")
	EndIf

Return lVal
