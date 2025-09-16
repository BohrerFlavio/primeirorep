#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI199  บ Autor ณ Lucas Bolzan         บ Data ณ  18/12/23   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio de pesagens por nota fiscal                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Logistica                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

USER FUNCTION DTI199()
    
    LOCAL wnrel     := "DTI199"
    LOCAL cString   := "SF2"
    LOCAL titulo    := "Relatorio de fรฉrias e afastamentos"
    LOCAL NomeProg  := "DTI199"
    LOCAL Tamanho   := "M"
    PRIVATE aReturn :={"Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
    PRIVATE cPerg   	 := "DTI199"

    PRIVATE nLastKey     := 0
    PRIVATE nTipo        := 18

    Pergunte(cPerg,.F.)
    PRIVATE cDtaIni := mv_par01
    PRIVATE cDtaFim := mv_par02

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,"", "", "",.F.,.F.,.F.,Tamanho,,.F.)

    MsgRun("Aguarde... Realizando contagem de registros...",,{||  ConsultaDB() })
    
	IF nLastKey <> 27
        SetDefault(aReturn,cString)
        IF nLastKey <> 27
            RptStatus({|lEnd| Relatorio(@lEnd,wnRel,cString,Tamanho,NomeProg)},titulo)
        ENDIF
    ENDIF    
RETURN

STATIC FUNCTION Relatorio(lEnd,WnRel,cString,Tamanho,NomeProg)
    LOCAL cabec1,cabec2
    LOCAL cRodaTxt := oemtoansi("Rodapรฉ")
    Local nCntImpr
    Local nTipo
 
    nCntImpr := 0
    li := 80
    m_pag := 1
 
    //ยณ Inicializa os codigos de caracter Comprimido da impressora ยณ
    nTipo := 15
 
    //ยณ Monta os Cabecalhos                                          ยณ
    titulo:= oemtoansi("Informacoes de NFes")
    cabec1:= oemtoansi("DOCUMENTO   DATA DE EMISSAO   PESO LIQUIDO   PESO BRUTO")
    cabec2:=""       
 
    dbSelectArea("SA1")
 
    TMP->(dbGoTop())
 
    TMP->(SetRegua(LastRec()))
 
    WHILE TMP->(!EOF())
        IncRegua()
 
        IF Li > 60
            cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
            @ Li,0 PSAY __PrtThinLine()                
        ENDIF   
    
        nCntImpr++     
        Li++   
    
        @ Li,001 PSAY TMP->NOTA
        @ Li,015 PSAY SToD(TMP->DTAEMISSAO)
        @ Li,030 PSAY TMP->PESOLIQUIDO
        @ Li,045 PSAY TMP->PESOBRUTO
    
        IF Li > 60       
            Li:=66   
        ENDIF          
    
        TMP->(DBSKIP())
    
    ENDDO
 
    IF li != 80    
        Roda(nCntImpr,cRodaTxt,Tamanho)
    ENDIF
    
    Set Device to Screen
    IF aReturn[5] = 1      
        Set Printer To     
        dbCommitAll()      
        OurSpool(wnrel)
    ENDIF
    MS_FLUSH()
RETURN

STATIC FUNCTION ConsultaDB()
    _cQuery := "SELECT F2_DOC AS NOTA, F2_EMISSAO AS DTAEMISSAO, F2_PLIQUI AS PESOLIQUIDO, F2_PBRUTO AS PESOBRUTO "
    _cQuery += "FROM" +  RetSQLTab('SF2')
    IF(!EMPTY(mv_par01) .AND. !EMPTY(mv_par02) .AND. !EMPTY(mv_par03) .AND. !EMPTY(mv_par04))
        _cQuery += "WHERE" + retSqlFil('SF2') + " AND" + retSqlDel('SF2') + "AND (F2_EMISSAO BETWEEN " + DToS(mv_par01) + ' AND ' + DToS(mv_par02) + ")"
        _cQuery += "OR (F2_DOC BETWEEN " + "'" + mv_par03 + "'" + ' AND ' + "'" + mv_par04 + "'" + ")"
    ELSEIF(!EMPTY(mv_par01) .AND. !EMPTY(mv_par02) .AND. EMPTY(mv_par03) .AND. EMPTY(mv_par04))
        _cQuery += "WHERE" + retSqlFil('SF2') + " AND" + retSqlDel('SF2') + "AND (F2_EMISSAO BETWEEN " + DToS(mv_par01) + ' AND ' + DToS(mv_par02) + ")"
    ELSEIF(EMPTY(mv_par01) .AND. EMPTY(mv_par02) .AND. !EMPTY(mv_par03) .AND. !EMPTY(mv_par04))
        _cQuery += "WHERE" + retSqlFil('SF2') + " AND" + retSqlDel('SF2') + "AND  (F2_DOC BETWEEN " + "'" + mv_par03 + "'" + ' AND ' + "'" + mv_par04 + "'" + ")"
    ELSEIF(EMPTY(mv_par01) .AND. EMPTY(mv_par02) .AND. EMPTY(mv_par03) .AND. EMPTY(mv_par04))
        MSGALERT("Informe pelo menos um dos valores acima", "Aviso" )
        RETURN .F.
    ENDIF

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"
RETURN
