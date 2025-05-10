#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI190    บAutor  ณLucas Bolzan     บ Data ณ  07/11/23      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Relat๓rio de f้rias e afastamanetos                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCP           .                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION DTI190()
    
    LOCAL wnrel     := "DTI190"
    LOCAL cString   := "SR8"
    LOCAL titulo    := "Relatorio de f้rias e afastamentos"
    LOCAL NomeProg  := "DTI190"
    LOCAL Tamanho   := "M"
    PRIVATE aReturn :={"Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
    PRIVATE cPerg   	 := "DTI190"
    PRIVATE nLastKey     := 0    

    Pergunte(cPerg,.F.)
    PRIVATE cMatric := mv_par01

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
    LOCAL cRodaTxt := oemtoansi("Rodap้")
    Local nCntImpr
    Local nTipo
 
    nCntImpr := 0
    li := 80
    m_pag := 1
 
    //ณ Inicializa os codigos de caracter Comprimido da impressora ณ
    nTipo := 15
 
    //ณ Monta os Cabecalhos                                          ณ
    titulo:= oemtoansi("Relatorio de f้rias e afastamentos")
    cabec1:= oemtoansi("MATRอCULA    NOME DO COLABORADOR                                     DATA INICIAL/DATA FINAL        MOTIVO")
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
    
        @ Li,001 PSAY TMP->MATRICULA
        @ Li,010 PSAY TMP->NOME        
        @ Li,070 PSAY SToD(TMP->DATAINI)
        @ Li,080 PSAY SToD(TMP->DATAFIM)
        @ Li,100 PSAY TMP->MOTIVO
    
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
    _cQuery := "SELECT RA_MAT AS MATRICULA,RA_NOME AS NOME,R8_DATAINI AS DATAINI,R8_DATAFIM AS DATAFIM,RCM_DESCRI AS MOTIVO "
    _cQuery += "FROM " +  RetSQLTab('SR8')
    _cQuery += "INNER JOIN " + RetSQLTab('RCM') + "ON RCM_TIPO = R8_TIPOAFA "
    _cQuery += "INNER JOIN " + RetSQLTab('SRA') + "ON R8_MAT = RA_MAT "
    _cQuery += "WHERE R8_MAT = " + cMatric + " AND SR8.D_E_L_E_T_ <> '*' "
	_cQuery += "ORDER BY R8_DATAINI DESC"

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
