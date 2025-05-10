#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"

User function MT100TOK()
 
    Local lRet := .F.
    Local nItem			:= 0
   
    // Valida็ใo a definir
    If Cpaisloc == "BRA"
        lRet := .T.
    Else
        Alert("Pais localizado = " +Cpaisloc+". ok")
    EndIf

/*
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Autor ณ Lucas Bolzan                             บ Data ณ  08/09/23   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ VALIDAวีES PARA LEMRAR USUมRIO DE INSERIR REINF            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
*/
    cDoc := SF1->F1_DOC
    lMsg := .F.
    nNCount := 0
    cDtAtual := Date()
    //QUERY PARA PEGAR O Nบ DO DOCUMENTO DE ENTRADA MAIS ATUAL CASO ELE Jม EXISTA
    SD1->(DbSetOrder(1))
	SD1->(DbGoTop())
    IF SD1->(dbseek(FWxFilial('SD1')+cDoc))
        Query := "SELECT TOP 1 D1_DTDIGIT AS DATA_DIGITACAO "
        Query += "FROM  " + RetSQLTab('SD1') "
        Query += "WHERE " + RetSQLFil('SD1') + " AND D1_DOC = '" + cDoc + "' AND D_E_L_E_T_ <> '*'""
        Query += "ORDER BY D1_DTDIGIT DESC"

        Query := ChangeQuery(Query)

        IF SELECT("TMPP") != 0
            TMPP->(dbCloseArea())
        ENDIF

        TCQUERY Query NEW ALIAS "TMPP"

        cDtAtual := TMPP->DATA_DIGITACAO        
    ENDIF
    
    //QUERY PARA PEGAR OS CODIGOS DOS PRODUTOS DO DOCUMENTO DE ENTRADA
    cQuery := "SELECT D1_COD AS CODIGO "
    cQuery += "FROM  " + RetSQLTab('SD1') "
    
    IF SD1->(dbseek(FWxFilial('SD1')+cDoc))
        cQuery += "WHERE " + RetSQLFil('SD1') + " AND D1_DOC = '" + cDoc + "' AND D_E_L_E_T_ <> '*' AND D1_DTDIGIT =  " + cDtAtual"
    ELSE
    
        cQuery += "WHERE " + RetSQLFil('SD1') + " AND D1_DOC = '" + cDoc + "' AND D_E_L_E_T_ <> '*' ""
    ENDIF

    cQuery  := ChangeQuery(cQuery)

    IF SELECT("TMP") != 0
		TMP->(dbCloseArea())
	ENDIF

	TCQUERY cQuery NEW ALIAS "TMP"
    
    WHILE TMP->(!EOF())

        _cNatRen := GetAdvFval( 'F2Q' , 'F2Q_NATREN' ,FWxFilial( 'F2Q' ) + ALLTRIM(TMP->CODIGO),1)
        _cNaRend := GetAdvFval( 'DHR' , 'DHR_NATREN' ,FWxFilial( 'DHR' ) + ALLTRIM(TMP->CODIGO),1)
        _cIRRF   := GetAdvFval( 'SB1' , 'B1_IRRF' ,FWxFilial( 'SB1' ) + ALLTRIM(TMP->CODIGO),1)
        _cPIS    := GetAdvFval( 'SB1' , 'B1_PIS' ,FWxFilial( 'SB1' ) + ALLTRIM(TMP->CODIGO),1)
        _cCOFINS := GetAdvFval( 'SB1' , 'B1_COFINS' ,FWxFilial( 'SB1' ) + ALLTRIM(TMP->CODIGO),1)
        _cCSLL   := GetAdvFval( 'SB1' , 'B1_CSLL' ,FWxFilial( 'SB1' ) + ALLTRIM(TMP->CODIGO),1)

        IF EMPTY(_cNatRen)
            IF (_cIRRF = 'S')
                lMsg := .T.
                lRet := .F.                
            ELSEIF (_cPIS = '1')
                lMsg := .T.
                lRet := .F.                
            ELSEIF (_cCOFINS = '1')
                lMsg := .T.
                lRet := .F.                
            ELSEIF (_cCSLL = '1')
                lMsg := .T.
                lRet := .F.                
            ENDIF        
        ENDIF

        TMP->(DBSKIP())
        nNCount++
    END

    IF(lMsg = .T.)
        IF !(MSGYESNO("As informa็๕es REINF foram fornecidas? Caso contrแrio, clique em 'Nใo' para corrigir. ", "AVISO"))
            MSGINFO( "Nใo", "" )
            lRet := .F.
        ELSE
            lRet := .T.
        ENDIF
    ENDIF
Return lRet
