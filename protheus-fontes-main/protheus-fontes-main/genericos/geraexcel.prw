#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} STI_R500
Função que mostra os dados gerados em Excel.
@author 	Evandro Mugnol
@since 		Set/2018
@version 	1.0
@return 	Nil, Função não tem retorno
@obs 		N/A
@type 		function

@param 		_cNome, 	 character,	Nome do arquivo a ser gerado.
@param 		_aDados,     array, 	Dados a serem apresentados.
@param 		_aCampos,    array,		Indica o array que contém as informações dos campos que serão utilizados para criar a tabela.
@param 		_lCsv,       lógico,   	Define se gera arquivo CSV.
@param 		_lShow,      lógico,   	Define se apresenta o resultado.
@param 		_cPasta,     character,	Caminho\Pasta a ser gerado, caso informado.

@example 	Abaixo um exemplo de como chamar a função.

U_GERAEXCEL(_cNomArq, _aDados, _aCabec, .T.)
/*/

User Function GERAEXCEL(_cNome, _aDados, _aCampos, _lCsv, _lShow, _cPasta)

	Local _aArea	 := GetArea()
	Local _cExt		 := ".DBF"
	Local cArquivo 	 := ""
	Local cPath		 := AllTrim(GetTempPath())
	Local _cDrvPad	 := DbSetDriver()
	Local oExcelApp
	Local _lOpen	 := .F.
	Local _nHdl    	 := 0
	Local _CRLF		 := chr(13) + chr(10)
	Local _cSeparador:= ";"
	Local _cRegistro := ""
	Local _nLinha
	Local _nColuna

	DEFAULT	_lCsv	 := .T.
	DEFAULT	_lShow	 := .T.
	DEFAULT	_cPasta	 := ""

	If !Empty(_cPasta)
		cPath := AllTrim(_cPasta)
		If Right(cPath, 1) <> "\"
			cPath += "\"
		Endif
	Endif

	If _lCsv
		_lOpen	 :=	.T.
		_cExt	 :=	".CSV"
		cArquivo :=	IIf(_cNome == nil, "planilha", AllTrim(_cNome))
		_nHdl    := FCreate(cPath+cArquivo+_cExt, 0)
		If _nHdl == -1
			MsgAlert( "Erro na gravação do Arquivo, contate o Administrador do Sistema. (" + cArquivo + ")" )
			Return
		Endif

		// Grava a primeira linha referente ao cabeçalho
		If Len(_aCampos) > 0
			_cRegistro	:=	""
			For _nLinha := 1 to Len(_aCampos)
				_cRegistro += AllTrim(_aCampos[_nLinha, 1]) + _cSeparador
			Next
			FWrite(_nHdl, Left(_cRegistro, Len(_cRegistro) - 1) + _CRLF)
		Endif	

		For _nLinha := 1 to Len(_aDados)
			_cRegistro := ""
			For _nColuna := 1 to Len(_aDados[_nLinha])
				If _aDados[_nLinha, _nColuna] == nil
					_cConteudo := " "
				Elseif ValType(_aDados[_nLinha, _nColuna]) == "D"
					_cConteudo := DTOC(_aDados[_nLinha, _nColuna])
				Elseif ValType(_aDados[_nLinha, _nColuna]) == "N"
					_cConteudo := Transform(_aDados[_nLinha, _nColuna], "@E 9,999,999,999.999999")
				Else
					_cConteudo := AllTrim(_aDados[_nLinha, _nColuna])
				Endif
				_cRegistro += _cConteudo + _cSeparador
			Next _nColuna
			FWrite(_nHdl, Left(_cRegistro, Len(_cRegistro) - 1) + _CRLF)
		Next _nLinha

		FClose(_nHdl)		// Fecha o arquivo
	Endif

	If _lOpen .And. _lShow
		If ! ApOleClient( 'MsExcel' )
			MsgStop( 'MsExcel nao instalado' )
		Else
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cPath + cArquivo + _cExt ) 	// Abre uma planilha
			oExcelApp:SetVisible(.T.)
		EndIf
	Endif

	DbSetDriver(_cDrvPad)
	RestArea(_aArea)

Return
