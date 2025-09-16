#Include "TOTVS.ch"
#Include "TOPCONN.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLBP08    บAutor  ณLucas Bolzan     บ Data ณ  25/11/24       บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Relatorio de Solicita็๕es de Servi็os e                   บฑฑ
ฑฑบ          ณ  Ordem de servi็o de manuten็ใo                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN           .                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION LBP08()
    Local oReport := ReportDef()

    oReport:PrintDialog()
Return (NIL)

Static Function ReportDef()
    Local cPerg := "LBP08"
    Local cTitRel := "Relatorio de Solicit. de Servi็os e O.S. de Manuten็ใo"    

    Local oReport := TReport():New(cPerg, cTitRel, cPerg, {|oReport| ReportPrint(oReport, oSection)}, cTitRel)
    Local oSection := TRSection():New(oReport, "Conta Corrente", {"ZZ4"})    

    Pergunte(cPerg,.T.)

    TRCell():New(oSection, "OS_MANUTENCAO"       , NIL, "Nบ OS de Manut",,100)
    TRCell():New(oSection, "SOLICIT_SERVICO"     , NIL, "Nบ Solicit. de Serv",,100)
    TRCell():New(oSection, "COD_BEM"             , NIL, "C๓d. Bem",,100)
    TRCell():New(oSection, "DESC_BEM"            , NIL, "Desc. Bem",,100)
    TRCell():New(oSection, "COD_CC"              , NIL, "C๓d. CC",,100)
    TRCell():New(oSection, "NOME_CC"             , NIL, "Desc. CC",,100)
    TRCell():New(oSection, "FUNCIONARIO_ATRELADO", NIL, "Func. Atrelado",,100)
    TRCell():New(oSection, "SOLICITANTE"         , NIL, "Solicitante",,100)
    TRCell():New(oSection, "SERVICO"             , NIL, "Servi็o",,100)
    TRCell():New(oSection, "SITUACAO"            , NIL, "Situa็ใo",,100)
    TRCell():New(oSection, "DTA_INI_MANUT_PREV"  , NIL, "Dta. Inicio Manut. Prev.",,100)
    TRCell():New(oSection, "HORA_INI_MANUT_PREV" , NIL, "Hora. Inicio Manut. Prev.",,100)
    TRCell():New(oSection, "DTA_FIM_MANUT_PREV"  , NIL, "Dta. Fim Manut. Prev.",,100)
    TRCell():New(oSection, "HORA_FIM_MANUT_PREV" , NIL, "Hora. Fim Manut. Prev.",,100)    
Return (oReport)

Static Function ReportPrint(oReport, oSection)    
    Local cAlias  := GetNextAlias()    

    oSection:BeginQuery()
        /*
        cQry := "SELECT TJ_ORDEM AS OS_MANUTENCAO, TJ_SOLICI AS SOLICIT_SERVICO, TJ_CODBEM AS CODIGO_BEM, T9_NOME AS DESCRICAO_BEM, TJ_CCUSTO AS CENTRO_CUSTO, CTT_DESC01 AS NOME_CENTRO_CUSTO, TQB_CDEXEC AS FUNCIONARIO_ATRELADO, TQB_USUARI AS SOLICITANTE, TJ_SERVICO AS SERVICO,TJ_SITUACA AS SITUACAO, TJ_DTMPINI AS DTA_INI_MANUT_PREV, TJ_HOMPINI AS HORA_INI_MANUT_PREV, TJ_DTMPFIM AS DTA_FIM_MANUT_PREV, TJ_HOMPFIM AS HORA_FIM_MANUT_PREV"
        cQry += "FROM " + retSqlTab('TQB')
        cQry += "INNER JOIN " + retSqlTab('STJ') + " ON TJ_SOLICI = TQB_SOLICI "
        cQry += "INNER JOIN " + retSqlTab('ST9') + " ON T9_CODBEM = TJ_CODBEM "
        cQry += "INNER JOIN " + retSqlTab('CTT') + " ON CTT_CUSTO = TJ_CCUSTO "
        cQry += "WHERE " + retSqlDel('TQB') + " AND " + retSqlDel('STJ') + " AND " + retSqlFil('TQB') + " AND " + retSqlFil('STJ')
        If !Empty(mv_par01) .or. !Empty(mv_par02) .or. !Empty(mv_par03) .or. !Empty(mv_par04)
            If !Empty(mv_par01) .and. !Empty(mv_par02)
                cQry += " AND TJ_ORDEM BETWEEN " + mv_par01 + " AND " + mv_par02
            ElseIf !(mv_par03) .and. !(mv_par04)
                cQry += " AND TJ_SOLICI " + mv_par03 + " AND " + mv_par04
            Else
                MsgAlert("Use apenas a numera็ใo de ordem ou solicita็ใo","Aviso")
            Endif
        Else            
            MsgAlert("Preencha os parametros","Aviso")
        Endif

        cQry := ChangeQuery(cQry)

        If Select(cAlias)<>0
		    cAlias->(dbCloseArea())
	    Endif

	    TCQUERY cQry NEW ALIAS cAlias
        */
        BEGINSQL ALIAS cAlias            
            SELECT
                TJ_ORDEM                 as OS_MANUTENCAO,
                TJ_SOLICI                as SOLICIT_SERVICO,
                TJ_CODBEM                as COD_BEM,
                T9_NOME                  as DESC_BEM,
                TJ_CCUSTO                as COD_CC,
                CTT_DESC01               as NOME_CC,
                TQB_CDEXEC               as FUNCIONARIO_ATRELADO,
                TQB_USUARI               as SOLICITANTE,
                TJ_SERVICO               as SERVICO,
                TJ_SITUACA               as SITUACAO,
                CONVERT(DATE,TJ_DTMPINI) as DTA_INI_MANUT_PREV,
                TJ_HOMPINI               as HORA_INI_MANUT_PREV,
                CONVERT(DATE,TJ_DTMPFIM) as DTA_FIM_MANUT_PREV,
                TJ_HOMPFIM               as HORA_FIM_MANUT_PREV
            FROM %Table:TQB% TQB
            INNER JOIN %Table:STJ% STJ ON TJ_SOLICI = TQB_SOLICI
            INNER JOIN %Table:ST9% ST9 ON T9_CODBEM = TJ_CODBEM
            INNER JOIN %Table:CTT% CTT ON CTT_CUSTO = TJ_CCUSTO
            WHERE TQB_FILIAL=%xfilial:TQB% AND TJ_FILIAL=%xfilial:STJ% AND TQB.%notDel% AND STJ.%notDel% AND ((TJ_ORDEM BETWEEN %exp:mv_par01% AND %exp:mv_par02%)OR(TJ_SOLICI BETWEEN %exp:mv_par03% AND %exp:mv_par04%))
            ORDER BY TJ_ORDEM            
        ENDSQL
        
    oSection:EndQuery()
    
    (cAlias)->(DbGotop())

    While (cAlias)->(!EOF())                
        oReport:IncMeter()
        oSection:Init()
        oSection:PrintLine()
        oReport:Line(oReport:Row(), oReport:Col(), oReport:Row(), oReport:Col() + 3400)        
        (cAlias)->(DbSkip())
    EndDo
   
    oSection:Finish()
Return (NIL)
