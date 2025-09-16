#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI182    ºAutor  ³Adonai Gabriel   º Data ³  13/07/23     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina temporária para resolver um problema de gravação    º±±
±±º          ³ incorreta na SZ8 de produtos do Porcionados                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Expedição                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI182()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia de caixas causando bloqueio de "
	Local cDesc3         := "fechamento de Pré-pedidos."
	Local titulo         := "RELATORIO PARA CONF. DE CAIXAS COM ERRO"
	Local Cabec1         := ""
	Local Cabec2         := "      Caixa         Codigo         Descricao                            Pallet     Pedido     Carregamento     Motivo"
	Local aOrd           := {}
	Private nlin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI182" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI182"
	Private cbcont     	 := 00
	Private CONTFL    	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "DTI182" // Coloque aqui o nome do arquivo usado para impressao em disco

	pergunte(cPerg,.F.)

	cabec1 += 'Pré-carregamento - ' + alltrim(mv_par01)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	MsgRun("Aguarde... Realizando o processamento dos registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ8')

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nlin) },Titulo)

Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nlin)

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nlin := 9

    _nCont := 0

    TMP->(dbGoTop())

	TMP->(SetRegua(RecCount()))

    While TMP->(!EOF())

		incregua()

        If lAbortPrint
            @nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
            Exit
        Endif

        If nlin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
            Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
            nlin := 9
        Endif

        @nlin,05 psay alltrim(TMP->Z8_CONTROL)
        @nlin,20 psay alltrim(TMP->Z8_COD)
        @nlin,30 psay substr(TMP->Z8_DESCRI,1,30)
        @nlin,70 psay alltrim(TMP->Z8_PALLET)
        @nlin,83 psay alltrim(TMP->Z8_PREPED)
        @nlin,97 psay alltrim(TMP->Z8_PRECAR)
        @nlin,108 psay iif(Z8_CHKCARR = '1', "Cx em outro carreg", "Cx em estoque")

        _nCont++
        nlin++

        TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

    enddo

    nlin++
    @nlin,01 psay replicate('-',limite)
    nlin++
    @nlin,01 psay "Quantidade de caixas não carregadas: " + alltrim(str(_nCont))
    nlin++
    @nlin,01 psay replicate('-',limite)
    nlin++

	TotCaix()
	CXS->(dbGoTop())

	nlin++
	@nlin,01 psay replicate('=',limite)
	nlin++

	While CXS->(!EOF())

		If nlin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
            Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
            nlin := 9
        Endif

		@nlin,01 psay "Quantidade de caixas já carregadas pelo usuário " + iif(empty(CXS->ZZ6_USUAR), "----------", alltrim(CXS->ZZ6_USUAR)) + " -> " + alltrim(str(CXS->CAIXAS))
		nlin++

		CXS->(dbSkip()) // Avanca o ponteiro do registro no arquivo

    enddo

	@nlin,01 psay replicate('=',limite)
	nlin++

	CaixFalt()
	FAL->(dbGoTop())

	nlin++
	@nlin,01 psay replicate('=',limite)
	nlin++

	While FAL->(!EOF())

		If nlin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
            Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
            nlin := 9
        Endif

		@nlin,01 psay "Caixa ainda não validada -> " + FAL->Z8_CONTROL + " | Código -> " + alltrim(FAL->Z8_COD) + " | Pedido -> " + FAL->Z8_PREPED
		nlin++

		FAL->(dbSkip()) // Avanca o ponteiro do registro no arquivo

    enddo

	@nlin,01 psay replicate('=',limite)
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

// Função que gera a query no banco de dados conforme o parâmetro informado
Static Function GeraTMP()

	_cQuery := "SELECT Z8_CONTROL, Z8_COD, Z8_DESCRI, Z8_PALLET, Z8_PREPED, Z8_PRECAR, Z8_CHKCARR"
	_cQuery += " FROM  " + RetSQLTab('SZ8')
	_cQuery += " WHERE " + RetSQLFil('SZ8') + " AND Z8_FIL = '" + cFilAnt + "' AND"
	_cQuery += " Z8_CHKPCAR = '" + alltrim(mv_par01) + "' AND"
	_cQuery += " Z8_CHKCARR IN ('1', '2') AND"
	_cQuery += RetSQLDel('SZ8')
	_cQuery += " ORDER BY Z8_CONTROL"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return

// Busca o total de caixas já carregadas no carregamento informado
Static Function TotCaix()

	local _cQuery := ""

	_cQuery := "SELECT COUNT(ZZ6_CONTRO) AS CAIXAS, ZZ6_USUAR"
	_cQuery += " FROM  " + RetSQLTab('ZZ6')
	_cQuery += " WHERE " + RetSQLFil('ZZ6')
	_cQuery += " AND ZZ6_PRECAR = '" + alltrim(mv_par01) + "' AND "
	_cQuery += RetSQLDel('ZZ6')
	_cQuery += " GROUP BY ZZ6_USUAR"
	_cQuery += " ORDER BY ZZ6_USUAR"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("CXS") != 0
		CXS->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "CXS"

return

// Busca as caixas que foram carregadas mas não validadas
Static Function CaixFalt()

	local _cQuery := ""

	_cQuery := "SELECT Z8_CONTROL, Z8_COD, Z8_PREPED"
	_cQuery += " FROM  " + RetSQLTab('ZZ6')
	_cQuery += " INNER JOIN " + RetSQLTab('SZ8') + " ON (ZZ6_CONTRO = Z8_CONTROL)"
	_cQuery += " WHERE " + RetSQLFil('ZZ6') + " AND " + RetSQLFil('SZ8')
	_cQuery += " AND Z8_FIL = '" + cFilAnt + "'"
	_cQuery += " AND Z8_CHKPCAR = ''"
	_cQuery += " AND ZZ6_PRECAR = '" + alltrim(mv_par01) + "' AND "
	_cQuery += RetSQLDel('ZZ6') + " AND " + RetSQLDel('SZ8')
	_cQuery += " ORDER BY Z8_CONTROL"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("FAL") != 0
		FAL->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "FAL"

return

// Função para verificar se todas as caixas de um pedido foram carregadas corretamente
User Function VerPreCar(_PreCar)

    local _cQuery1 := ""
	local _cQuery2 := ""
	local _cQuery3 := ""
    local nCount := 0
    local _nRet := 0

	_cQuery1 := "SELECT Z8_CONTROL, Z8_COD, Z8_DESCRI, Z8_PALLET, Z8_LOCAL, Z8_LOCALIZ, Z8_PREPED, Z8_PRECAR"
	_cQuery1 += " FROM  " + RetSQLTab('SZ8')
	_cQuery1 += " INNER JOIN " + RetSQLTab('SB1') + " ON (Z8_COD = B1_COD)"
	_cQuery1 += " WHERE " + RetSQLFil('SZ8') + " AND Z8_FIL = '" + cFilAnt + "'"
	_cQuery1 += " AND " + RetSQLFil('SB1')
	_cQuery1 += " AND Z8_CHKPCAR = '" + _PreCar + "'"
	_cQuery1 += " AND B1_SEGUM <> 'PC'"
	_cQuery1 += " AND Z8_CHKCARR IN ('1', '2')"
	_cQuery1 += " AND Z8_CHKCARR <> '' AND "
	_cQuery1 += RetSQLDel('SZ8') + " AND " + RetSQLDel('SB1')
	_cQuery1 += " ORDER BY Z8_CONTROL"

	_cQuery2 := "SELECT COUNT(Z8_CONTROL) AS CXSZ8"
	_cQuery2 += " FROM  " + RetSQLTab('SZ8')
	_cQuery2 += " INNER JOIN " + RetSQLTab('SB1') + " ON (Z8_COD = B1_COD)"
	_cQuery2 += " WHERE " + RetSQLFil('SZ8') + " AND Z8_FIL = '" + cFilAnt + "'"
	_cQuery2 += " AND " + RetSQLFil('SB1')
	_cQuery2 += " AND Z8_CHKPCAR = '" + _PreCar + "'"
	_cQuery2 += " AND B1_SEGUM <> 'PC' AND "
	_cQuery2 += RetSQLDel('SZ8') + " AND " + RetSQLDel('SB1')

	_cQuery3 := "SELECT SUM(ZZ5_QRCAIX) AS CXZZ5"
	_cQuery3 += " FROM  " + RetSQLTab('ZZ4')
	_cQuery3 += " INNER JOIN " + RetSQLTab('ZZ5') + " ON (ZZ4_NUM = ZZ5_NUM)"
	_cQuery3 += " INNER JOIN " + RetSQLTab('SB1') + " ON (ZZ5_COD = B1_COD)"
	_cQuery3 += " WHERE " + RetSQLFil('ZZ4')
	_cQuery3 += " AND " + RetSQLFil('ZZ5')
	_cQuery3 += " AND " + RetSQLFil('SB1')
	_cQuery3 += " AND ZZ4_PRECAR = '" + _PreCar + "'"
	_cQuery3 += " AND B1_SEGUM <> 'PC' AND "
	_cQuery3 += RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5') + " AND " + RetSQLDel('SB1')

	cAlias1 := GetNextAlias()
	TCQuery _cQuery1 new alias &cAlias1
	(cAlias1)->(dbGoTop())

	//verifica se houve retorno na query
    Count to nCount

    If nCount > 0
        _nRet := 1
    endif

	cAlias2 := GetNextAlias()
	TCQuery _cQuery2 new alias &cAlias2
	(cAlias2)->(dbGoTop())

	cAlias3 := GetNextAlias()
	TCQuery _cQuery3 new alias &cAlias3
	(cAlias3)->(dbGoTop())

	if (cAlias2)->CXSZ8 != (cAlias3)->CXZZ5 .and. _nRet = 0
		_nRet := 2
	endif

    (cAlias1)->(dbCloseArea())
	(cAlias2)->(dbCloseArea())
	(cAlias3)->(dbCloseArea())

Return _nRet
