#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} MA131QSC
Ponto de Entrada executado no início da rotina de processamento das solicitações de compra
que devem gerar cotação, permitindo incluir um bloco de código que realizará as quebras das solicitações de compras.
@author     Evandro
@since      09/06/2020
@param		PARAMIXB[1] - Bloco de código padrão utilizado para quebra das solicitações de compras que devem gerar cotações
@return     PARAMIXB[1] - Bloco de código definido pelo operador para realizar as quebras das solicitações de compras que devem gerar cotações
/*/

User Function MA131QSC()

	Local _bQuebra := PARAMIXB[1]

	Private _cPerg := "MA131QSC"

	_DeleZLS()						// Deleta tabela ZLS para nova carga de dados

	PUTMV("FS_ZLSFORN", "")			// Limpa parâmetro no início do processamento da cotação

	Pergunte(_cPerg,.F.)

	PUTMV("FS_PARAMCT", MV_PAR01)	// Atualiza parâmetro no SX6 com resposta informada para o usuário logado

Return _bQuebra



//-------------------------------------------------------------------
/*/{Protheus.doc} _DeleZLS
Deleta dados da tabela ZLS para nova carga de dados de fornecedores por segmento para a cotação
@author     Evandro
@since      29/06/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function _DeleZLS()

	_cQuery := "DELETE FROM " + RetSqlName("ZLS")
	_cQuery += " WHERE ZLS_FILIAL = '" + xFilial("ZLS") + "'" 

	If TcSQLExec(_cQuery) < 0	
		MsgStop(TcSqlError())
	Endif

Return
