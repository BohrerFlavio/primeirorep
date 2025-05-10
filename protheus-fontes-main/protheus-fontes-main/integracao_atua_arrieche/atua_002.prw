#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF Chr(13) + Chr(10)

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ATUA_002
@Type			: Função de Usuário
@Sample			: U_ATUA_002()
@Description	: Rotina de REST para buscar POST do cadastro de Proprietários da Atua Sistemas
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2023
@version		: Protheus 12.1.2210 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function ATUA_002(_cCNPJ,_dDtIni,_dDtFim)

	Local oRest
	Local cUrl 		  := "https://consulta.maisfrete.com.br"
	Local cPath 	  := "/api/contabilidade/index.php"
	Local cPostParams := ''
    Local aHeader     := {}
	Local cBoundary   := '----WebKitFormBoundary7MA4YWxkTrZu0gW'

	_cCNPJReq := _cCNPJ
    _cDataIni := SubStr(FwTimeStamp(5, _dDtIni), 1, 10)
    _cDataFim := SubStr(FwTimeStamp(5, _dDtFim), 1, 10)

    aAdd(aHeader, 'Authorization: Basic ZXZhbmRyby5tdWdub2w6ZXY1NDc0YXR1QA==')
	aAdd(aHeader, 'Cookie: PHPSESSID=j45a50h2m9emkvs7s4oioq33ti')
	aAdd(aHeader, 'Content-Length: 450')
	aAdd(aHeader, 'Content-Type: multipart/form-data; boundary=' + cBoundary)

	oRest := FWRest():New(cUrl)

	oRest:setPath(cPath)

	cPostParams += CRLF
	cPostParams += '--' + cBoundary
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="conjunto_de_dados"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += 'proprietarios'
	cPostParams += CRLF

	cPostParams += '--' + cBoundary
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="cnpj"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += _cCNPJReq
	cPostParams += CRLF

	cPostParams += '--' + cBoundary
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="dt_ini"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += _cDataIni
	cPostParams += CRLF

	cPostParams += '--' + cBoundary
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="dt_fim"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += _cDataFim
	cPostParams += CRLF

	cPostParams += '--' + cBoundary + '--'
	cPostParams += CRLF

	oRest:SetPostParams(cPostParams)

	If oRest:Post(aHeader)
		cError := ""
		nStatus := HTTPGetStatus(@cError)

		If nStatus >= 200 .And. nStatus <= 299
			If Empty(oRest:GetResult())
				MsgInfo(nStatus)
			Else
				MsgInfo(oRest:GetResult())
			EndIf
		Else
			MsgStop(cError)
		EndIf
	Else
		MsgStop(oRest:GetLastError() + CRLF + oRest:GetResult())
	EndIf

	FreeObj(oRest)

Return
