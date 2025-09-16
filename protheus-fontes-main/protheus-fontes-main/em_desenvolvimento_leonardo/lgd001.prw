#INCLUDE "PROTHEUS.CH"
#Include "TOPCONN.ch"

USER FUNCTION LGD001()
    Local cUFunc := "LGD001"
    Local cPerg := "LGD001"
    Local cTitRel := "Percentual de gordura na produção"

    Local oReport as Object
    Local oSection as Object

    //Classe TREPORT
    oReport := TReport():New(cUFunc,cTitRel,cPerg,{|oReport|ReportPrint(oReport,oSection)})
    
    //Seção 1 
    oSection := TRSection():New(oReport,'Caixas')

    //Definição das colunas de impressão da seção 1
    TRCell():New(oSection, "Z8_COD" , "TRB", "Cód.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    TRCell():New(oSection, "Z8_CONTROL", "TRB", "Controle" , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    TRCell():New(oSection, "DTABT" , "TRB", "Data Abate"    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    TRCell():New(oSection, "Z8_DATAP" , "TRB", "Data Embalagem"    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    TRCell():New(oSection, "Z8_DATAVAL" , "TRB", "Data Validade"    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    TRCell():New(oSection, "PERCCARNE" , "TRB", "%Carne."    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    TRCell():New(oSection, "PERCGORD" , "TRB", "%Gord."    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    TRCell():New(oSection, "Z8_DESCRI" , "TRB", "Produto", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)

    oReport:PrintGraphic()
    oReport:PrintDialog()

Return

Static Function ReportPrint(oReport,oSection)

    #IFDEF TOP

        Local cAlias := "TRB"
        Local dDataIni := MV_PAR01
        Local dDataFim := MV_PAR02
        Local cCodigos := MV_PAR03
        if(trim(cCodigos) == "")
            cCodigos := "029054/029055/029056/029057/029058/029059/029060/029061/029062/029063/029064/029079/029080/029081/029082/029083/029084/029085/029086/029088/029089/029090/029091/029092/029093/029094"
        endif

        BEGIN REPORT QUERY oSection

            BeginSql alias cAlias 
                SELECT
                    Z8_COD, Z8_CONTROL, 
                    Z8_DESCRI,
                    CONVERT(DATE, ZU_DTABT) AS DTABT,
                    Z8_DATAP,
                    Z8_DATAVAL,
                    CASE
                        WHEN ISNUMERIC(Z8_PERCRXN)=1 AND Z8_PERCRXN > 0 THEN CONVERT(varchar, (Z8_PERCRXN))+'%'
                        ELSE '-'
                    END AS PERCCARNE, 
                    CASE
                        WHEN ISNUMERIC(Z8_PERCRXN)=1 AND Z8_PERCRXN > 0 THEN CONVERT(varchar, (100 - Z8_PERCRXN))+'%'
                        ELSE '-'
                    END AS PERCGORD 
                FROM %table:SZ8%
                LEFT JOIN %table:SZU% ON (%table:SZ8%.Z8_NUMPREV = %table:SZU%.ZU_NUM)
                WHERE
                    (
                        (Z8_DATAP >= %exp:dDataIni% AND Z8_DATAP <= %exp:dDataFim%) OR
                        (ZU_DTABT >= %exp:dDataIni% AND ZU_DTABT <= %exp:dDataFim%)
                    ) AND
                    CHARINDEX(TRIM(Z8_COD), %exp:cCodigos%) > 0
                ORDER BY Z8_DESCRI, Z8_DATAP, Z8_CONTROL
            EndSql

        END REPORT QUERY oSection 
        
        oSection:Print()

    #ENDIF

return
