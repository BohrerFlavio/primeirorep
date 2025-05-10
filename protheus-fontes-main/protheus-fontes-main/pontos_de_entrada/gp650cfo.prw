#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} GP650CFO
Ponto de entrada criado antes da execução da "ExecAuto" do cadastro de fornecedores automático na geração
de títulos com o objetivo de adicionar mais campos ao "array" passado para o cadastro de fornecedores para
serem levados mais dados do funcionário para o novo fornecedor cadastrado.

IMPORTANTE:
O ponto de entrada deve SEMPRE retornar um array que contenha os dados já existentes no array aDadosAuto,
passado como referência, mais os campos que o usuário desejar adicionar, com seu devido conteúdo, conforme
exemplo mais abaixo. O array retornado deve SEMPRE retornar no mínimo os campos já existentes no parâmetro
passado como referência, não podendo ser retirado nenhum campo, apenas adicionado.
@author     Evandro
@since      13/10/2020
@param		PARAMIXB - Array contendo todos os dados dos fornecedores (obrigatório)
@return     aCampos - Array contendo todos os dados complementares dos fornecedores
/*/
User Function GP650CFO()

	Local aCampos := PARAMIXB

	aAdd(aCampos,{'A2_COD_MUN' 	, SRA->RA_CODMUN  	, Nil})
	aAdd(aCampos,{'A2_DDD' 	    , "54"			  	, Nil})
	aAdd(aCampos,{'A2_TEL' 	    , "9"			  	, Nil})
	aAdd(aCampos,{'A2_EMAIL'    , "."			  	, Nil})
	aAdd(aCampos,{'A2_INSCR' 	, "ISENTO"  		, Nil})
	aAdd(aCampos,{'A2_PAIS' 	, "105"			  	, Nil})

	DO CASE
        CASE cCodTit == "FER"	// Férias
            aAdd(aCampos,{'A2_NATUREZ' 	, "120205" 	, Nil})
        CASE cCodTit == "PEN" 	// Pensão Alimentícia
            aAdd(aCampos,{'A2_NATUREZ' 	, "120213" 	, Nil})
        OTHERWISE				// Fornecedores Diversos
            aAdd(aCampos,{'A2_NATUREZ' 	, "120102" 	, Nil})
	ENDCASE

	aAdd(aCampos,{'A2_COND' 	, "001"			  	, Nil})

	If AllTrim(cEmpAnt) <> "07"
		aAdd(aCampos,{'A2_TPFOR', "D"				, Nil})
	Else
		aAdd(aCampos,{'A2_CEP' 	, "99999999"		, Nil})
		aAdd(aCampos,{'A2_CONTA', "2109011001"		, Nil})
	Endif

	aAdd(aCampos,{'A2_CODPAIS' 	, "01058"		  	, Nil})
	aAdd(aCampos,{'A2_FOMEZER' 	, "2"			  	, Nil})
	aAdd(aCampos,{'A2_CDPAIS' 	, "311"			  	, Nil})
	aAdd(aCampos,{'A2_SIMPNAC' 	, "2"			  	, Nil})

Return aCampos
