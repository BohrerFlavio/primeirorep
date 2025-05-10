#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} BLQ_FUS
@Type			: Função de Usuário
@Sample			: BLQ_FUS()
@Description	: Valida se já existe retorno da Fusion ref. a sequenciamento realizado
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2023
@version		: Protheus 12.1.2210 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function BLQ_FUS(_cPreCar)

	Local _aArea := FWGetArea()

	_lBloq   := .F.
	cQuery   := ""
	cQryFS   := GetNextAlias()
	aTitulos := {}

	cQuery := "SELECT COUNT(*) AS TOTREG "
	cQuery += "  FROM " + RetSQLTab("ZZ3")
	cQuery += " INNER JOIN " + RetSqlTab("ZZ4") + " ON ZZ4.ZZ4_FILIAL = '" + xFilial("ZZ4") + "' AND ZZ4.ZZ4_PRECAR = ZZ3.ZZ3_NUM AND ZZ4.D_E_L_E_T_ = '' "
	cQuery += " WHERE " + RetSQLFil("ZZ3")
	cQuery += "   AND ZZ3.ZZ3_NUM = '" + _cPreCar + "'"
	cQuery += "   AND ZZ4.ZZ4_STAFUS = '3'"
	cQuery += "   AND " + RetSQLDel("ZZ3")

	cQuery := ChangeQuery(cQuery)

	//Memowrite("ZZZ_BLQ_FUS", cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryFS, .T., .F. )

	(cQryFS)->(DbGoTop())

	If (cQryFS)->TOTREG > 0
		_lBloq := .T.
	EndIf

	(cQryFS)->(dbCloseArea())

	FWRestArea(_aArea)

Return _lBloq


//--------------------------------------------------------------------------------------
/*/{Protheus.doc} PSW_LIB
@Type			: Função de Usuário
@Sample			: PSW_LIB()
@Description	: Valida se a senha digitada está correta
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2023
@version		: Protheus 12.1.2210 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function PSW_LIB(_cCodigo, _nTipo)

	Local _lRet := .T.

	Private cSenhaOK  := "FUSION"
	Private cCpoSenha := Space(6)
	Private cGetSenha := Space(6)

	_lCancela := .T.
	DEFINE MSDIALOG TelaPsw FROM 0,0 TO 130,350 PIXEL TITLE "Liberação de Acesso"

	@ 01,01 SAY "Informe a senha para o acesso ?" of TelaPsw
	@ 01,12 MSGET cCpoSenha VAR cGetSenha SIZE 30,10 PASSWORD OF TelaPsw

	@ 030,25 BUTTON btn1 PROMPT "Confirmar" SIZE 50,15 OF TelaPsw pixel action (_lCancela := SenhaOK(_cCodigo, _nTipo), TelaPsw:end())
	@ 030,85 BUTTON btn2 PROMPT "Cancelar"  SIZE 50,15 OF TelaPsw pixel action (_lCancela := .F.	  , TelaPsw:end())

	ACTIVATE MSDIALOG TelaPsw CENTERED

	If !_lCancela
		_lRet := .F.
	Else
		_lRet := .T.
	EndIf

Return _lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} SenhaOk
Função que checa se a senha está correta
@author     Evandro Mugnol
@since      Nov/2023
/*/
//----------------------------------------------------------------------
Static Function SenhaOK(_cCod,_cTip)

	If AllTrim(cGetSenha) != cSenhaOK
		FWAlertError("A Senha Não Confere.","Senha INCORRETA.")
		_Ret := .F.
	Else
		If _cTip == 1		// Pré-Carregamento
			_Log("LIBERADO MANUTENCAO DO PRÉ-CARREGAMENTO " + _cCod + " POR " + cUserName + " EM " + DTOC(DDATABASE) + " AS " + TIME())
		Else 				// Pré-Pedido
			_Log("LIBERADO MANUTENCAO DO PRÉ-PEDIDO       " + _cCod + " POR " + cUserName + " EM " + DTOC(DDATABASE) + " AS " + TIME())
		EndIf
		_Ret := .T.
	EndIf

Return _Ret


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo de log para conferencia                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Log(_sTexto)

	Local _nHdl1    := 0
	Local _sArqLog1 := "\log_fusion\desbloqueios_fusion_PERIODO - " + SUBSTR(DTOS(DDATABASE),1,4) + "_" + SUBSTR(DTOS(DDATABASE),5,2)  + ".txt"

	If file (_sArqLog1)
		_nHdl1 = fOpen(_sArqLog1, 1)
	Else
		_nHdl1 = fCreate(_sArqLog1, 0)
	Endif

	fSeek(_nHdl1, 0, 2)      // Encontra final do arquivo
	fWrite(_nHdl1, _sTexto + chr (13) + chr (10))
	fClose(_nHdl1)

Return
