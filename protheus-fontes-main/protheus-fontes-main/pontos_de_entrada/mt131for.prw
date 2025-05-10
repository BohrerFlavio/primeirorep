#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} MT131FOR
Ponto de Entrada que permite alterar os fornecedores envolvidos no processo de cotação.
@author     Evandro
@since      09/06/2020
@param		PARAMIXB[1] - Array contendo todos os dados dos fornecedores (obrigatório)
@example	aFornec[1,1] - Codigo Fornecedor
			aFornec[1,2] - Loja Fornecedor
			aFornec[1,3] - Criterio
			aFornec[1,4] - Alias
			aFornec[1,5] - Recno (Alias) 
@return     aRet - Array contendo todos os dados dos fornecedores, deve ser no mesmo padrão do PARAMIXB (obrigatório)
/*/

User Function MT131FOR()

	Local aFornec := PARAMIXB[1]
	Local nX
	

	If cEmpAnt $ "01/07/08"

		If GetMV("FS_PARAMCT") == "2"		// Mostra telas de filtro segmento e fornecedores filtrados Somente Uma Vez

			If GetMV("FS_ZLSFORN") == "1"
				// Busca dados para montar 'aFornec' da tabela ZLS
				aFornec := {}
				
				cQuery := "SELECT * "
				cQuery += "  FROM " + RetSQLTab("ZLS")
				cQuery += " WHERE " + RetSQLFil("ZLS")
				cQuery += "   AND " + RetSQLDel("ZLS")
			
				cQuery := ChangeQuery(cQuery)
			
				DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "TRB", .F., .T.)
			
				TRB->(dbGoTop())
				While TRB->(!Eof())
					aAdd(aFornec, { TRB->ZLS_FORNEC, TRB->ZLS_LOJA, TRB->ZLS_CRITER, TRB->ZLS_TABELA, TRB->ZLS_REG } )
					TRB->(DbSkip())
				Enddo
			
				TRB->(DbCloseArea())
				
			Else

				aFornec := {}
				_cSeg := FiltSeg()									// Tela para seleção de segmentos de fornecedores para filtragem
	
				aFornec := U_STI_SEGF(_cSeg, SC1->C1_PRODUTO)		// Tela com fornecedores filtrados com base nos segmentos selecionados
				
				// Grava dados do 'aFornec' na tabela ZLS
				For nX :=1 To Len(aFornec)
					DbSelectArea("ZLS")
					RecLock("ZLS",.T.)
					ZLS->ZLS_FILIAL := xFilial("ZLS")
					ZLS->ZLS_FORNEC := aFornec[nX][1]
					ZLS->ZLS_LOJA   := aFornec[nX][2]
					ZLS->ZLS_CRITER := aFornec[nX][3]
					ZLS->ZLS_TABELA := aFornec[nX][4]
					ZLS->ZLS_REG    := aFornec[nX][5]
					MsUnlock()
				Next nX
				
				PUTMV("FS_ZLSFORN", "1")							// Atualiza parâmetro no SX6 para buscar dados na tabela ZLS
			Endif

		Else								// Mostra telas de filtro segmento e fornecedores filtrados Item a Item

			If MsgYesNo('<p><span style="color: #0000ff;"><strong>Deseja efetuar a seleção de fornecedores para cotação por Segmentos para o PRODUTO: ' + AllTrim(SC1->C1_PRODUTO) + ' - ' + AllTrim(SC1->C1_DESCRI) + ' ?</strong></span></p>' , "Segmentos de Fornecedores para Cotação?")
				aFornec := {}
				_cSeg := FiltSeg()								// Tela para seleção de segmentos de fornecedores para filtragem
	
				aFornec := U_STI_SEGF(_cSeg, SC1->C1_PRODUTO)	// Tela com fornecedores filtrados com base nos segmentos selecionados
			EndIf

		Endif
	
	Endif

Return aFornec


//-------------------------------------------------------------------
/*/{Protheus.doc} FiltSeg
Tela com o cadastro de segmentos para que o usuário possa selecionar quais deseja filtrar
@author     Evandro
@since      09/06/2020
@return     String formatada como um comando FORMATIN do SQL. Ex.: 001,002,003
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function FiltSeg()  

	Local nX
	Local _cAlias 	   := Alias()
	Local oOk    	   := LoadBitmap(GetResources(), "LBOK")
	Local oNo    	   := LoadBitmap(GetResources(), "LBNO")
	Local oQual
	Local cVar   	   := "  "
	Local nOpca
	Local oDlg
	Local aSegmen      := {}
	Local lRunDblClick := .T.
	Local cCad  	   := "Selecionar SEGMENTOS"
	Local _cSeg 	   := ""
	Local _j

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a tabela de Segmentos                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("ZLQ")
	DbSeek(xFilial("ZLQ"))
	DbGoTop()
	Do While !Eof() .And. ZLQ->ZLQ_FILIAL = xFilial("ZLQ")
		AADD(aSegmen,{.F., ZLQ_CODSEG + "  -  " + ZLQ_DESSEG } )
		DbSkip()
	Enddo

	If Len(aSegmen) > 0

		DEFINE MSDIALOG oDlg TITLE cCad FROM 001, 001 TO 40, 80 OF oMainWnd
		@ 0.5, 01 TO 20, 38.5 LABEL cCad OF oDlg

		@ 1.2, 02 LISTBOX oQual VAR cVar Fields HEADER "",OemToAnsi("Segmentos de Fornecedores")  SIZE 285, 230 ON DBLCLICK (aSegmen:=Troca(oQual:nAt, aSegmen), oQual:Refresh()) NOSCROLL
		oQual:SetArray(aSegmen)
		oQual:bLine := { || {if(aSegmen[oQual:nAt, 1], oOk, oNo),aSegmen[oQual:nAt, 2]}}
		oQual:bHeaderClick := {|oObj,nCol| If(lRunDblClick .And. nCol==1, aEval(aSegmen, {|e| e[1] := !e[1]}),Nil), lRunDblClick := !lRunDblClick, oQual:Refresh()}

		DEFINE SBUTTON FROM 260, 230  TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 260, 270  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

		ACTIVATE MSDIALOG oDlg CENTERED 

		If nOpca == 1
			aCods := Aclone(aSegmen)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a string de tipos para filtrar o arquivo               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCods := ""
			For nX := 1 To Len(aSegmen)
				If aCods[nX,1]
					cCods += SubStr(aSegmen[nX,2],1,3)+"/"
				Endif
			Next nX

		Endif

		DeleteObject(oOk)
		DeleteObject(oNo)

	Endif                  

	If Len(aSegmen) > 0
		For _j:= 1 to len(aSegmen)
			If aSegmen[_j, 1] == .t.
				_cSeg := _cSeg + Left(aSegmen[_j, 2], 3) + ","
			Endif
		Next
	Endif                                    

	If _cSeg != ""
		_cSeg:= left(_cSeg, len(_cSeg)-1)      
	Endif

	DbSelectArea(_cAlias)

Return(_cSeg)


//-------------------------------------------------------------------
/*/{Protheus.doc} Troca
Função de troca
@author     Evandro
@since      09/06/2020
@return     Array
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function Troca(nIt, aArray)

	aArray[nIt, 1]:= !aArray[nIt, 1]

Return(aArray)
