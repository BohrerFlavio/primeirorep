#INCLUDE "TOTVS.CH"

// Programa...: ArqTrb
// Autor......: Robert Koch
// Data.......: 19/09/2002
// Descricao..: Cria ou deleta arquivos de trabalho e seus indices.
// Parametros: operacao -> "CRIA"        = cria novo arquivo de trabalho c/ o alias especificado
//                         "FECHA"       = fecha o arq. trab. com o alias especificado
//                         "FECHATODOS"  = fecha todos os arq. trab. criados por esta rotina.
//                         "DEIXAABERTO" = Elimina este arq. de trabalho da lista interna sem fecha-lo.
//             alias    -> Alias pelo qual o arq. trabalho vai ser acessado
//             campos   -> Array com estrutura de campos no modelo dbstruct()
//             indices  -> Array de strings com as expressoes para indices. Se nao informada,
//                         nao sera criado nenhum indice.
//             arqlist  -> Array local do programa chamador onde serao guardados os nomes fisicos dos
//                         de arquivos de dados e indices criados. Deve ser passada pelo programa
//                         chamador por referencia (com @ no inicio)
//
// Historico de alteracoes:
// 02/04/2003 - Robert - Possibilita a criacao de mais de um indice
// 28/05/2003 - Robert - Aceita a chamada sem o vetor de indices
// 17/09/2003 - Robert - Criado parametro 'DeixaAberto'
// 25/02/2004 - Robert - Passado de static para user function
// 13/04/2023 - Claudia - Ajustada a criação das tabelas para a função FWTemporaryTable
//
// --------------------------------------------------------------------------
user function ArqTrb(_sOperacao, _sAlias, _aCampos, _aIndices, _aArqList)
	local _nArq     := 0   // Contador de arquivos
	local _nIndice  := 0   // Contador de indices
	local _sIndice  := ''
	local _aIndAux  := {}
	local _oTempTbl := NIL

	if _aIndices == NIL
		_aIndices := {}
	endif

	if _aArqList == NIL
		msgalert('Erro ' + procname() + ": Variavel para lista de arquivos nao informada. Verifique programa chamador: " + procname(1))
		return
	endif

	do case
		case upper(_sOperacao) == "CRIA"
			if ascan(_aArqList, {|_aVal| _aVal[1] == _sAlias}) > 0
				msgbox('Erro ' + procname() + ": Alias " + _sAlias + " ja existe. Verifique programa chamador: " + procname(1))
				return .F.
			endif

			// Ajustada a criação das tabelas para a função FWTemporaryTable
			_oTempTbl := FWTemporaryTable():New(_sAlias)
			_oTempTbl:SetFields(_aCampos)

			// Transforma a lista de indices (campos concatenados com '+') para o formato exigido pela classe.
			for _nIndice = 1 to len(_aIndices)
				_sIndice = strtran(_aIndices[_nIndice], ' ', '')  // Remove espacos

				if '(' $ _sIndice .or. ')' $ _sIndice
					//msgalert ('Erro ' + procname () + ': Nao eh suportado o uso de funcoes na definicao dos indices. Revisar: ' + _sIndice)
					return .F.
				endif

				_aIndAux = StrTokArr(_sIndice, '+')
				_oTempTbl:AddIndex(strzero(_nIndice, 2), _aIndAux)
			next

			_oTempTbl:Create()

			// Guarda o arq. criado e seus indices na lista geral de arq. criados.
			aadd(_aArqList, {_sAlias, _oTempTbl})

		// Fecha o alias informado e seus indices
		case upper(_sOperacao) == "FECHA"
			_nArq = ascan(_aArqList, {|_aVal| _aVal[1] == _sAlias})
			if _nArq != 0
				_oTempTbl = _aArqList[_nArq, 2]
				_oTempTbl:Delete()
				afill(_aArqList[_nArq], "")
			endif

		// Fecha todos os arq. criados e seus indices
		case upper(_sOperacao) == "FECHATODOS"
			for _nArq = 1 to len(_aArqList)
				if _aArqList[_nArq, 1] != ""
					_oTempTbl = _aArqList[_nArq, 2]
					_oTempTbl:Delete()
				endif
			next
			_aArqList = {}

		// 'Esquece' este arquivo de trabalho. Elimina-o da lista, deixando-o aberto.
		case upper(_sOperacao) == "DEIXAABERTO"
			_nArq = ascan(_aArqList, {|_aVal| _aVal[1] == _sAlias})
			if _nArq != 0
				afill(_aArqList [_nArq], "")
			endif
	endcase
return .T.
