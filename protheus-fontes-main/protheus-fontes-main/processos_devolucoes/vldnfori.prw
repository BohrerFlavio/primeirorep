#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} VLDNFORI
@Type			: Função de Usuário
@Sample			: U_VLDNFORI()
@Description	: Função que efetua validação dos campos ZH2_NFORI e ZH2_SERORI na rotina
                  de autorização de devolução (AUTDEV.PRW)
@Param			: Nf Orig Dev, Ser Orig Dev
@Return			: Lógico - .T. ou .F.
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function VLDNFORI(_cNfOrig, _cSerOrig, _cCodCli, _cLojCli)

	Local aArea  := FWGetArea()
	Local _lRet  := .T.
	Local aDados := {}

	DbSelectArea("ZH2")
	DbSetOrder(2)
	If DbSeek(FWxFilial("ZH2") + _cCodCli + _cLojCli + _cNfOrig + _cSerOrig)
		FWAlertWarning("", "Autorização de Devolução já cadastrada com este número/série de nota de origem para este cliente/loja")
		_lRet := .F.
	Else
		cQry := "SELECT F2_DOC,F2_SERIE,F2_EMISSAO,F2_VEND1,F2_CLIENTE,F2_LOJA"
		cQry += "  FROM " + RetSqlTab("SF2")
		cQry += " WHERE " + RetSqlFil("SF2")
		cQry += "   AND F2_CLIENTE = '" + _cCodCli + "' "
		cQry += "   AND F2_LOJA = '" + _cLojCli + "' "
		cQry += "   AND F2_DOC = '"  + _cNfOrig +  "' "
		If !Empty(_cSerOrig)
			cQry += "   AND F2_SERIE = '"  + _cSerOrig +  "' "
		EndIf
		cQry += "   AND " + RetSqlDel("SF2")

		cQry := ChangeQuery(cQry)

		If Select("QF2") != 0
			QF2->(dbCloseArea())
		Endif

		TCQUERY cQry NEW Alias "QF2"

		If !Eof()
			_lRet := .T.
		Else
			ShowHelpDlg(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))															,;
						{"Número de nota fiscal informada '" + _cNfOrig + "' está incorreta!"}								,;
						5																									,;
						{"Verifique se o número da nota digitado corretamente com 9 dígitos."								,;
						"Confira o Código e Loja do cliente informados pois esta nota não existe para este cliente/loja."}	,;
						5																									 )
			_lRet := .F.
		EndIf
		QF2->(DbCloseArea())
	EndIf

	aDados := fGetVend(_cNfOrig)

	If Len(aDados) > 0
		cVend1 	:= aDados[1][1]
		cPedido := aDados[1][2]
		cNomVen	:= Alltrim(Posicione("SA3", 1, FWxFilial("SA3") + cVend1,"A3_NOME"))
		FWFldPut("ZH2_NUMPED", cPedido)
		FWFldPut("ZH2_CODVEN", cVend1)
		FWFldPut("ZH2_NOMVEN", cNomVen)
	EndIf

	FWRestArea(aArea)

Return _lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} fGetVend
Função para pegar informações de pedido e vendedor
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function fGetVend(cNumNfOrig)

	Local aDados :=  {}

	If Select('VENDEDOR') <> 0
		VENDEDOR->(DbCloseArea())
	EndIf

	BeginSql Alias 'VENDEDOR'
		SELECT
			F2_VEND1, D2_PEDIDO
		FROM
			%table:SF2% SF2
		INNER JOIN %table:SD2% SD2
		ON (
			D2_FILIAL = F2_FILIAL
			AND D2_DOC = F2_DOC
			AND D2_SERIE = F2_SERIE
			AND SD2.%notDel%
			)
		WHERE
			F2_FILIAL = %xFilial:SF2%
			AND F2_DOC = %exp:cNumNfOrig%
			AND SF2.%notDel%
	EndSql

	If !VENDEDOR->(Eof())
		aadd(aDados, {VENDEDOR->F2_VEND1, VENDEDOR->D2_PEDIDO})
	EndIf

	If Select('VENDEDOR') <> 0
		VENDEDOR->(DbCloseArea())
	EndIf

Return aDados
