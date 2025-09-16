#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} TMCALFRE 
@Type			: Ponto de Entrada
@Sample			: U_TMCALFRE()
@Description	: Ponto de Entrada, localizado no TMSXFUNB (Funções utilizadas pelo TMS),
                  possibilita ao usuário calcular componentes de frete com valores específicos..
@Param			: aComp - Array utilizado para passar os components a serem calculados e seus
                          respectivos valores
@Return			: aRet - Vetor - Retorna os componentes e seus respectivos valores específicos
                                 a serem calculados.
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro
@Since			: Ago/2022
@version		: Protheus 12
@Comments		: Utilizado para efetuar o rateio do frete conforme regras do Frig. Silva
/*/
//--------------------------------------------------------------------------------------
User Function TMCALFRE()

	Local aParam := PARAMIXB
	Local aRet   := {}

    If DT3->DT3_TIPFAI == "07"          // Calculo do Frete Informado
       
        _CodCompon := aParam[1][1][3]		// Código do Componente
        _nFretInf  := aParam[1][1][2]		// Valor do Frete Informado
        aAdd(aRet,{_CodCompon, _nFretInf}) 

    Else

        // Query para calcular o PESO TOTAL do Lote que está sendo calculado
        cQuery := "SELECT SUM(DTC_PESO) AS PESOTOT "
        cQuery += "  FROM " + RetSQLTab("DTC")
        cQuery += " WHERE " + RetSQLFil("DTC")
        cQuery += "   AND DTC_LOTNFC = '" + aParam[29] + "'"
        cQuery += "   AND " + RetSQLDel("DTC")

        cQuery := ChangeQuery(cQuery)

        If Select("QRY") <> 0
            QRY->(DbCloseArea())
        Endif

        TCQUERY cQuery NEW ALIAS "QRY"
        
        _nPesoTot := QRY->PESOTOT

        QRY->(DbCloseArea())

        _cCalcUnit := "N"
        _nVlrUnit  := 0
        _ValAteAnt := 0
        _nFretCalc := 0

        If Len(aParam) > 0
            if Len(aParam[1]) <= 0
                FWAlertHelp("Componentes não encontrados!", "Tente novamente mais tarde...")
                Return .F.
            endif
            
            // Componentes do Frete por TIPO DO VEÍCULO
            _CodCompon := aParam[1][1][3]		// Código do Componente
            _CodOrigem := aParam[1][1][7]		// Código da Região de Origem
            _CodDestin := aParam[1][1][8]		// Código da Região de Destino
            _CodTabela := aParam[1][1][9]		// Código da Tabela de Frete
            _CodTipTab := aParam[1][1][10]		// Código do Tipo da Tabela de Frete

            // Tabela de Frete
            DbSelectArea("DT0")
            DbSetOrder(1)
            If DbSeek(xFilial("DT0") + _CodTabela + _CodTipTab + _CodOrigem + _CodDestino)
                _CodTabTar := DT0->DT0_TABTAR
            Else
                _CodTabTar := aParam[1][1][9]
            EndIf

            // Itens de Tabela de Tarifas
            DbSelectArea("DTG")
            DbSetOrder(1)
            DbSeek(xFilial("DTG") + _CodTabela + _CodTipTab + _CodTabTar + _CodCompon)
            While !Eof() .And. DTG->DTG_FILIAL + DTG->DTG_TABFRE + DTG->DTG_TIPTAB + DTG->DTG_TABTAR + DTG->DTG_CODPAS == xFilial("DTG") + _CodTabela + _CodTipTab + _CodTabTar + _CodCompon
                If _nPesoTot <= DTG->DTG_VALATE .And. DTG->DTG_ITEM == "01"
                    _cCalcUnit := "N"
                    _nVlrUnit  := DTG->DTG_VALOR
                EndIf

                If _nPesoTot > _ValAteAnt .And. _nPesoTot <= DTG->DTG_VALATE .And. DTG->DTG_ITEM <> "01"
                    _cCalcUnit := "S"
                    _nVlrUnit  := DTG->DTG_VALOR
                    Exit
                EndIf

                _ValAteAnt := DTG->DTG_VALATE	// Guarda valor para comparar a partir do item 02

                DbSelectArea("DTG")
                DbSkip()
            EndDo

            If _cCalcUnit == "S"	// Executa recálculo pelo Valor Unitário
                _nPesoReal := aParam[4]
                _nFretCalc := Round(_nPesoReal * _nVlrUnit, 2)
                
                aAdd(aRet,{_CodCompon, _nFretCalc}) 
            Else
                _nPesoReal := aParam[4]
                _nPercRate := Round(((_nPesoReal * 100) / _nPesoTot), 2)
                _nFretCalc := Round(((_nVlrUnit * _nPercRate) / 100), 2)
                    
                aAdd(aRet,{_CodCompon, _nFretCalc}) 
            EndIf

            // Componentes do Frete por TAXA DO VEÍCULO (Caso tenha taxa)
            If Len(aParam[1]) >= 2
                _TaxCompon := aParam[1][2][3]		// Taxa do Componente
                _TaxOrigem := aParam[1][2][7]		// Taxa da Região de Origem
                _TaxDestin := aParam[1][2][8]		// Taxa da Região de Destino
                _TaxTabela := aParam[1][2][9]		// Taxa da Tabela de Frete
                _TaxTipTab := aParam[1][2][10]		// Taxa do Tipo da Tabela de Frete

                // Tabela de Frete
                DbSelectArea("DT0")
                DbSetOrder(1)
                If DbSeek(xFilial("DT0") + _TaxTabela + _TaxTipTab + _TaxOrigem + _TaxDestino)
                    _TaxTabTar := DT0->DT0_TABTAR
                Else
                    _TaxTabTar := aParam[1][2][9]
                EndIf

                // Itens de Tabela de Tarifas
                DbSelectArea("DTG")
                DbSetOrder(1)
                If DbSeek(xFilial("DTG") + _TaxTabela + _TaxTipTab + _TaxTabTar + _TaxCompon)
                    _nValTaxa := DTG->DTG_VALOR
                Else
                    _nValTaxa := 0
                EndIf
            
                _nPesoReal := aParam[4]
                _nPerRatTx := Round(((_nPesoReal * 100) / _nPesoTot), 2)
                _nTaxaCalc  := Round(((_nValTaxa * _nPerRatTx) / 100), 2)
                    
                aAdd(aRet,{_TaxCompon, _nTaxaCalc}) 
            EndIf
        EndIf
    
    EndIf

Return aRet
