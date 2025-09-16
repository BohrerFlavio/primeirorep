/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  LBP02              บ Autor ณ Lucas Bolzan บ Data ณ 24/07/24  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Corrige valores de peso das caixas bizerba termoformadora  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Porcionados                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.ch"

USER FUNCTION LBP02()
    nCount := 0

    cQueryZAS := "SELECT ZAS_SEQBIZ AS SEQBIZ, ZAS_PESOL AS PESOLIQ "
    cQueryZAS += "FROM " + RetSQLTab('ZAS')
    cQueryZAS += "WHERE" + RetSQLFil('ZAS') + " AND ZAS_SEQBIZ <> ''  AND ZAS_PESOL < 0"

    IF SELECT("QRYZAS") != 0
        QRYZAS->(dbCloseArea())
    ENDIF

    TCQUERY cQueryZAS NEW ALIAS "QRYZAS"
    QRYZAS->(dbGoTop())

    WHILE QRYZAS->(!EOF()) .AND. QRYZAS->PESOLIQ < 0
        //SEQUENCIAL DA CAIXA BIZERBA
        a := AllTrim(QRYZAS->SEQBIZ)
        //PESO DA CAIXA VINDO DO BANCO DE DADOS DA BIZERBA
        b := QRYBIZ(a)
        //Alert(Alltrim("O nบ da caixa Bizerba ้: " + a + ' do tipo ' + ValType(a))) 
        IF (b > 0)            
            //Alert("O peso capturado vindo do BD Bizerba ้: " + cValToChar(b) + ' do tipo ' + ValType(b))
            cQuery1 := " UPDATE ZAS010"
            cQuery1 += " SET ZAS_PESOL = " + "'" + AllTrim(STR(b)) + "'"
            cQuery1 += " WHERE " + RetSQLFil('ZAS') + " AND " + " ZAS_SEQBIZ = " + "'" + a + "'"
            TcSqlExec(cQuery1)
        
            cQuery2 := " UPDATE SZ8010"
            cQuery2 += " SET Z8_PESO = " + "'" + AllTrim(STR(b)) + "'"
            cQuery2 += " WHERE " + RetSQLFil('SZ8') + " AND " + " Z8_SEQBIZE = " + "'" + a + "'"
            TcSqlExec(cQuery2)
        ENDIF
        
        nCount := nCount + 1

        QRYZAS->(DbSkip())
    ENDDO

    MsgInfo(cValToChar(nCount) + " registros modificados", "INFO")
RETURN

STATIC FUNCTION QRYBIZ(cSeqBiz)    
    cStrConn  := 'MSSQL/BIZERBA_BRAIN2_Result' //String de conexรฃo no DBAccess
    cHostDBA  := "10.0.10.4" //Servidor do DBAccess
    nPortaDBA := 7890 //Porta de coenxรฃo com DBAccess
    nHandle   := 0    
    cReturn   := " "

	nHandle := TcLink(cStrConn, cHostDBA, nPortaDBA)

    IF nHandle >= 0
        cQuery := "SELECT PrintedNetWeightValue AS PESO "
        cQuery += "FROM PackageRecord "
        cQuery += "WHERE CommonText1 = '" + Alltrim(cSeqBiz) + "'"

        IF SELECT("QRY") != 0
            QRY->(dbCloseArea())
        ENDIF

        TCQUERY cQuery NEW ALIAS "QRY"
        QRY->(dbGoTop())

        cReturn := (QRY->PESO)

    ELSE
        MsgAlert("Nใo foi possรญvel conectar! Erro: " + cValToChar(nHandle), "Aten็ใo")
    ENDIF
    
    TCUNLink(nHandle)
RETURN cReturn
