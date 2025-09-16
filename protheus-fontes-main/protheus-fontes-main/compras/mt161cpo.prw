#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT161CPO
Ponto de Entrada que permite incluir campos customizados nas grids "Produtos" e "Item da Proposta", na rotina Análise de Cotação (MATA161).
@author 	Evandro
@since 		19/11/2019
@param		PARAMIXB[1] - Array - Array contendo os dados das propostas dos fornecedores
			PARAMIXB[2] - Array - Array com os dados da grid "Produtos"
@return 	Array com quatro dimensões contendo:
@return			1 - Os dados das propostas dos fornecedores na mesma estrutura do array recebido como parâmetro PARAMIXB[1], acrescido das informações dos campos incluídos.
@return			2 - Array com o nome dos campos incluídos na grid "Item da Proposta".
@return			3 - Os dados dos produtos  na mesma estrutura do array recebido como parâmetro PARAMIXB[2], acrescido das informações dos campos incluídos.
@return			4 - Array com o nome dos campos incluídos na grid "Produtos".
@obs 		Os nomes dos campos devem ser incluídos nos arrays de retorno na mesma ordem em que foram incluídos nas informações dos produtos e das propostas.
			No array de produtos, todos os produtos devem ter os mesmos campos incluídos e no array de dados das propostas todas as propostas devem ter os mesmos campos incluídos.
			Este ponto de entrada não efetua gravação de campos na tabela SC8 e também não permite editar as informações dos campos customizados na tela, somente exibição das informações.
/*/

User Function MT161CPO()

	Local aPropostas := PARAMIXB[1] 			// Array com os dados das propostas dos Fornecedores
	Local aItens 	 := PARAMIXB[2] 			// Array com os dados da grid "Produtos"
	Local aCampos 	 := {"C8_MARCAC"}			// Array com os campos adicionados na grid "Item da Proposta"
	Local aCposProd  := {} 						// Array com os campos adicionados na grid "Produtos"
	Local aRetorno 	 := {}
	Local nX 		 := 0
	Local nY 		 := 0
	Local nZ 		 := 0
	Local nCount 	 := 0
	Local aAreaSC8 	 := SC8->(GetArea())

	For nX := 1 To Len(aPropostas)
		For nY := 1 To Len(aPropostas[nX])
			For nZ := 1 To Len(aPropostas[nX][nY][2])
				nCount++
				If Len(aPropostas[nX][nY][1]) > 0
					// C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO
					AADD(aPropostas[nX][nY][2][nZ],Posicione("SC8",1,SC8->(C8_FILIAL+C8_NUM)+aPropostas[nX][nY][1][1]+aPropostas[nX][nY][1][2]+aPropostas[nX][nY][2][nZ][2]+aPropostas[nX][nY][2][nZ][12],"C8_MARCAC"))
				Else
					AADD(aPropostas[nX][nY][2][nZ],0)
				EndIf
			next nZ
		Next nY
	Next nX

	For nX := 1 To Len(aItens)
		// C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO
		// AADD(aItens[nX],Posicione("SC8",1,SC8->(C8_FILIAL+C8_NUM)+aItens[nX][10]+aItens[nX][11]+aItens[nX][12]+aItens[nX][13],"C8_XXX"))
	Next nX

	AADD(aRetorno,aPropostas)
	AADD(aRetorno,aCampos)
	AADD(aRetorno,aItens)
	AADD(aRetorno,aCposProd)

	RestArea(aAreaSC8)

Return aRetorno
