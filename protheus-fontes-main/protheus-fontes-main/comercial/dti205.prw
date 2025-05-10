#Include "TOTVS.ch"
#Include "TOPCONN.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI204    บAutor  ณLucas Bolzan     บ Data ณ  20/02/24      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Relatorio de descontos por pre-carregamento               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN           .                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION DTI205()
    Local oReport := ReportDef()

    oReport:PrintDialog()
Return (NIL)

Static Function ReportDef()    
    Local cPerg := "DTI205"
    Local cTitRel := "Relatorio de descontos por pre-carregamento"

    Local oReport := TReport():New(cPerg, cTitRel, cPerg, {|oReport| ReportPrint(oReport, oSection)}, cTitRel)
    Local oSection := TRSection():New(oReport, "Conta Corrente", {"ZZ4"})    

    Pergunte(cPerg,.T.)

    TRCell():New(oSection, "PRE_CARREGAMENTO"    , NIL, "Pr้-Carregamento")
    TRCell():New(oSection, "DATA_CARREGAMENTO"   , NIL, "Data Carregamento")    
    TRCell():New(oSection, "CODIGO_CLIENTE"      , NIL, "C๓d. Cliente")
    TRCell():New(oSection, "LOJA_CLIENTE"        , NIL, "Nบ Loja")
    TRCell():New(oSection, "NOME_CLIENTE"        , NIL, "Nome Cliente")
    TRCell():New(oSection, "MUNICIPIO"           , NIL, "Municํpio")
    TRCell():New(oSection, "CODIGO_REPRESENTANTE", NIL, "C๓d. Representante")
    TRCell():New(oSection, "NOME_REPRESENTANTE"  , NIL, "Nome Representante")
    TRCell():New(oSection, "CODIGO_PRODUTO"      , NIL, "C๓d. Produto")
    TRCell():New(oSection, "DESCRICAO_PRODUTO"   , NIL, "Produto")
    TRCell():New(oSection, "QUANTIDADE_POR_PESO" , NIL, "Qtd. Prev.(Kg)"    , '@E 999,999.99')
    TRCell():New(oSection, "PRECO"               , NIL, "Pre็o(R$)"         , '@E 999,999.99')
    TRCell():New(oSection, "TIPO_BONIFICACAO"    , NIL, "Bonifica็ใo")
    TRCell():New(oSection, "DESCONTO"            , NIL, "Desconto(R$)"      , '@E 99.99')
    TRCell():New(oSection, "PRECO_FINAL"         , NIL, "Pre็o Final(R$)"   , '@E 999,999.99')
    TRCell():New(oSection, "PRECO_SEM_RAPEL"     , NIL, "Pre็o C/ Rapel(R$)", '@E 999,999.99')    
Return (oReport)

Static Function ReportPrint(oReport, oSection)    
    Local cAlias  := GetNextAlias()
    Local _PreCar := ''    

    oSection:BeginQuery()
        BEGINSQL ALIAS cAlias            
            SELECT
                A1_PRAPEL                                                                 as PRECO_RAPEL,
                ZZ3_NUM                                                                   as PRE_CARREGAMENTO,
                ZZ3_PLACA                                                                 as PLACA,
                CONVERT(DATE,ZZ3_DTCAR)                                                   as DATA_CARREGAMENTO,
                ZZ3_OBS                                                                   as OBSERVACAO,
                ZZ3_USUAR                                                                 as CODIGO_USUARIO,
                ZZ4_MUN                                                                   as MUNICIPIO,
                ZZ4_NUM                                                                   as PRE_PEDIDO,
                ZZ4_CODCLI                                                                as CODIGO_CLIENTE,
                ZZ4_LOJA                                                                  as LOJA_CLIENTE,
                ZZ4_NOME                                                                  as NOME_CLIENTE,
                ZZ4_REPRES                                                                as CODIGO_REPRESENTANTE,
                ZZ4_NOMREP                                                                as NOME_REPRESENTANTE,
                ZZ4_NUMPED                                                                as NUMERO_PEDIDO,
                ZZ5_COD                                                                   as CODIGO_PRODUTO,
                ZZ5_ITEM                                                                  as ITEM,
                ZZ5_DESC                                                                  as DESCRICAO_PRODUTO,
                ZZ5_PRECO                                                                 as PRECO,                
                ZZ5_BONIF                                                                 as BONIFICACAO,
                ZZ5_QPPESO                                                                as QUANTIDADE_POR_PESO,
                ZZ5_BONIF*(1)                                                             as DESCONTO,
                ZZ5_PRECO-(ZZ5_BONIF*(1))                                                 as PRECO_FINAL,
                (ZZ5_PRECO-(ZZ5_BONIF*(1))) * (A1_PRAPEL/100)                             as PRECO_COM_RAPEL,
                ZZ5_PRECO-(ZZ5_BONIF*(1)) - (ZZ5_PRECO-(ZZ5_BONIF*(1))) * (A1_PRAPEL/100) as PRECO_SEM_RAPEL,
                IIF(ZZ5_TPBONI = 'D' , 'Desconto' , 'Acrescimo' )                         as TIPO_BONIFICACAO
            FROM %Table:SA1% SA1, %Table:ZZ3% ZZ3, %Table:ZZ4% ZZ4, %Table:ZZ5% ZZ5
            WHERE ZZ3_FILIAL=%xfilial:ZZ3% AND ZZ4_FILIAL=%xfilial:ZZ4% AND ZZ5_FILIAL=%xfilial:ZZ5% AND ZZ3.%notDel% AND ZZ4.%notDel% AND ZZ5.%notDel% AND ZZ3_NUM BETWEEN %exp:mv_par01% AND %exp:mv_par02%  AND ZZ3_NUM = ZZ4_PRECAR AND ZZ4_NUM = ZZ5_NUM AND ZZ5_TPBONI <> '' AND A1_COD = ZZ4_CODCLI  AND A1_LOJA = ZZ4_LOJA
            ORDER BY ZZ3_NUM, ZZ4_NUM,ZZ4_CODCLI,ZZ5_COD
        ENDSQL
    oSection:EndQuery()
    
    (cAlias)->(DbGotop())
    //Alert("Vai entrar no la็o")
    While (cAlias)->(!EOF())        
        If (_PreCar != (cAlias)->PRE_CARREGAMENTO)
            _PreCar := (cAlias)->PRE_CARREGAMENTO
            DbSelectArea("ZZ0")            

            _cQuery := "DELETE FROM " + RetSqlName("ZZ0") + " WHERE ZZ0_PRECAR = " + (cAlias)->PRE_CARREGAMENTO + " AND ZZ0_FILIAL = " + xFilial("ZZ0")
            TCSQLEXEC(_cQuery)
        Endif

        Begin transaction
        RecLock("ZZ0",.T.)
            ZZ0->ZZ0_FILIAL := xFilial("ZZ0")
            ZZ0->ZZ0_PRECAR := (cAlias)->PRE_CARREGAMENTO
            ZZ0->ZZ0_PREPED := (cAlias)->PRE_PEDIDO
            ZZ0->ZZ0_CODCLI := (cAlias)->CODIGO_CLIENTE
            ZZ0->ZZ0_LOJA   := (cAlias)->LOJA_CLIENTE
            ZZ0->ZZ0_ITEM   := (cAlias)->ITEM
            ZZ0->ZZ0_COD    := (cAlias)->CODIGO_PRODUTO
            ZZ0->ZZ0_PRECO  := (cAlias)->PRECO
            ZZ0->ZZ0_TPBONI := (cAlias)->TIPO_BONIFICACAO
            ZZ0->ZZ0_VLBONI := (cAlias)->BONIFICACAO
            ZZ0->ZZ0_PRCFIN := (cAlias)->PRECO_FINAL
        MsUnlock()
        End Transaction
        
        oReport:IncMeter()
        oSection:Init()
        oSection:PrintLine()
        oReport:Line(oReport:Row(), oReport:Col(), oReport:Row(), oReport:Col() + 3400)        
        (cAlias)->(DbSkip())
    EndDo

    oSection:Finish()
Return (NIL)
