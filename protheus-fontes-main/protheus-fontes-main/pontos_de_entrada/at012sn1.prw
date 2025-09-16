#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} TM200FIM
@Type			: Ponto de Entrada
@Sample			: U_AT012SN1()
@Description	: O ponto de entrada AT012SN1 permite a utilização dos critérios definidos
                  no MVC alterando o conteúdo dos campos do objeto, do item posicionado.	
@Return			: Retorna .T. (true) se permite a utilização dos critérios definidos no MVC
                  alterando o conteúdo dos campos do objeto ou .F. (false) mantém o padrão.
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Jul/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Utilizado tanto para o Cadastro de Ativos Imobilizados como também na
                  Classificação de um Ativo.
/*/
//--------------------------------------------------------------------------------------
User Function AT012SN1()

	Local oSN1 := PARAMIXB[1]

	// Define campos específicos que permitirão alteração
	oSN1:SetProperty("N1_ALIQPIS"  , MODEL_FIELD_WHEN , {|oModel| .T. } )
	oSN1:SetProperty("N1_ALIQCOF"  , MODEL_FIELD_WHEN , {|oModel| .T. } )

Return .T.
