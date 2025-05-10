#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} OS460NOT
Ponto de Entrada localizado na função que efetua o processamento das Notas Fiscais após processar todas as filiais e todas as cargas selecionadas.
@author 	Evandro Mugnol
@since 		Out/2020
@param		_aCargas, Array com as cargas que foram selecionadas
@return 	Nil, Função não tem retorno
@obs 		Este Ponto de Entrada se torna necessário para os casos nos quais o OMS está parametrizado como modo Operador Logístico
			e uma carga pode possuir pedidos de diferentes filiais. Caso contrário, se for apenas de uma filial, o Ponto de Entrada
			M460NOTA terá comportamento semelhante, porém, não recebe as cargas marcadas na tela
/*/
//-------------------------------------------------------------------

User Function OS460NOT()

	//Local _aCargas := PARAMIXB[1]
	//Local _cCarga  := ""
	//Local nX      := 0

	// Somente Executa para Empresa Frigorífico Silva
	//Chamada desabilitada dia 04/07/24 pois serviço foi descontinuado
	/*If cEmpAnt == "01"

		// Percorre todas as cargas que foram faturadas
		For nX := 1 to Len(_aCargas)
			// Processa os dados da carga
			_cCarga := _aCargas[nX]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processamento dos Dados                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Seleção das notas faturadas como cartão de crédito e que ainda não tenham "checkout_id": Identificador da transação de cobrança do integrador
			_cQuery := "SELECT F2_CARGA, F2_SEQCAR, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FRMREC, F2_CHKID, F2_CODINT, F2_VALBRUT "
			_cQuery += "  FROM " + RetSQLTab("SF2")
			_cQuery += " WHERE	" + RetSQLFil("SF2")
			_cQuery += "   AND F2_CARGA = '" + _cCarga + "'"
			_cQuery += "   AND F2_FRMREC = '5'"					// Somente Forma de Recebimento igual a Cartão de Crédito
			_cQuery += "   AND F2_CHKID = ''"
			_cQuery += "   AND F2_CODINT = ''"
			_cQuery += "   AND " + RetSQLDel("SF2")
			_cQuery += " ORDER BY F2_CARGA, F2_SEQCAR, F2_DOC, F2_SERIE "

			_cQuery := ChangeQuery(_cQuery)

			DbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), "TRB", .F., .T.)

			//memowrite("ZZZ_OS460NOT.TXT",_cQuery)

			TRB->(dbGoTop())
			While TRB->(!Eof())

				U_CHECKOUT(TRB->F2_DOC, TRB->F2_SERIE, TRB->F2_CLIENTE, TRB->F2_LOJA, TRB->F2_VALBRUT)		// Chama Método Checkout

				TRB->(DbSkip())
			Enddo

			TRB->(DbCloseArea())

		Next nX

	Endif*/

Return
