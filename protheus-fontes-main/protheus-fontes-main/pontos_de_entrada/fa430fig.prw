#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F260LJCON
Ponto de Entrada ermite modificar o CNPJ obtido da leitura do arquivo de retorno DDA, de modo que a tabela SA2
seja posicionada através do CNPJ modificado neste ponto de entrada.
@author     Evandro
@since      Nov/2020
@param		PARAMIXB - recebe como parâmetros um array com 5 posições
			PARAMIXB[1] - CNPJ do arquivo de recepção do DDA
			PARAMIXB[2] - Fornecedor do cadastro (SA2)
			PARAMIXB[3] - Prefixo
			PARAMIXB[4] - Título
			PARAMIXB[5] - Parcela
@return     cCNPJ
@obs        N/A
/*/
//-------------------------------------------------------------------

User Function FA430FIG()

	Local cCNPJ 	:= ParamIXB[1]
	Local _cFornec	:= Posicione("SA2", 3, xFilial("SA2") + cCNPJ, "A2_COD")
	Local _nReg		:= 0
	Local _cValpgto
	Local _cVencto

	// Tratamentos Valor e Data
	_cValpgto := nValPgto			// Valor de Pagamento 	- Origem fonte FINA430
	_cVencto  := Dtos(dBaixa)		// Vencimento 			- Origem fonte FINA430

	IF(SELECT("QSE2")<>0)
		QSE2->(DBCLOSEAREA())
	ENDIF

	// Monta Query
	BEGINSQL ALIAS "QSE2"

		SELECT * FROM %TABLE:SE2% SE2
		JOIN %TABLE:SA2% SA2 ON A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA AND A2_TIPO <> 'X' AND SA2.%NOTDEL%
		WHERE E2_FORNECE = %EXP:_cFornec%
		AND E2_VALOR = %EXP:_cValpgto%
		AND E2_VENCREA = %EXP:_cVencto%
		AND E2_BAIXA = ' '
		AND SE2.%NOTDEL%

	ENDSQL

	//MsgAlert(GetLastQuery()[2])

	DbSelectArea("QSE2")

	// Conta Numero de Registros
	Count TO _nReg
	QSE2->(DbGoTop())

	// Verifica condicoes conforme numero de registros
	If _nReg == 0
		_Log("contador zero: " + cCNPJ + " - Fornecedor: " + QSE2->E2_FORNECE + "/" + QSE2->E2_LOJA)
	ElseIf _nReg == 1
		_Log("INICIO ========================================================")
		_Log(GetLastQuery()[2])
		_Log("---------------------------------------------------------------")
		_Log("CNPJ Antes : " + cCNPJ)
		cCNPJ := Posicione("SA2", 1, xFilial("SA2") + QSE2->E2_FORNECE + QSE2->E2_LOJA, "A2_CGC")
		_Log("CNPJ Depois: " + cCNPJ)
		_Log("FINAL =========================================================")
	ElseIf _nReg >= 2
		_Log("contador maior ou igual a 2: " + cCNPJ + " - Fornecedor: " + QSE2->E2_FORNECE + "/" + QSE2->E2_LOJA + "  - e poderia ser: " + Posicione("SA2", 1, xFilial("SA2") + QSE2->E2_FORNECE + QSE2->E2_LOJA, "A2_CGC"))
	Endif

	QSE2->(DbCloseArea())

Return cCNPJ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo de log para conferencia                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Log(_sTexto)

	Local _nHdl    := 0
	Local _sArqLog := "zzz_import_dda.log"

	If file (_sArqLog)
		_nHdl = fOpen(_sArqLog, 1)
	Else
		_nHdl = fCreate(_sArqLog, 0)
	Endif

	fSeek(_nHdl, 0, 2)      // Encontra final do arquivo
	fWrite(_nHdl, _sTexto + chr (13) + chr (10))
	fClose(_nHdl)

Return 
