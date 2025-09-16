#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLBP05            บ Autor ณ Lucas Bolzan บ Data ณ 02/09/24   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Faz conexใo com banco de dados da Bizerba e coleta         บฑฑ
ฑฑ             informa็๕es relativas a caixa                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Porcionados                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION LBP05()   
    LOCAL wnrel     := "LBP05"
    LOCAL cString   := "SZ8"
    LOCAL titulo    := "Relatorio de Caixas Bizerba Termoformadora"
    LOCAL NomeProg  := "LBP05"
    LOCAL Tamanho   := "M"
    PRIVATE aReturn :={"Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
    PRIVATE cPerg   	 := "DTI190"
    PRIVATE nLastKey     := 0    

    Pergunte(cPerg,.F.)
    PRIVATE cMatric := mv_par01

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,"", "", "",.F.,.F.,.F.,Tamanho,,.F.)

    MsgRun("Aguarde... Realizando contagem de registros...",,{||  QueryBiz() })
    
	IF nLastKey <> 27
        SetDefault(aReturn,cString)
        IF nLastKey <> 27
            RptStatus({|lEnd| RelatBiz(@lEnd,wnRel,cString,Tamanho,NomeProg)},titulo)
        ENDIF
    ENDIF
RETURN

STATIC FUNCTION RelatBiz(lEnd,WnRel,cString,Tamanho,NomeProg)
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
    
    DbSelectArea('QRYBIZ')
    
    QRYBIZ->(dbGoTop())
 
    QRYBIZ->(SetRegua(LastRec()))
 
    WHILE QRYBIZ->(!EOF())
        IncRegua()
 
        IF Li > 60
            cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
            @ Li,0 PSAY __PrtThinLine()                
        ENDIF   
    
        nCntImpr++     
        Li++   
    
        @ Li,001 PSAY QRYBIZ->NUMERO_CAIXA
        @ Li,050 PSAY QRYBIZ->PESO        
    
        IF Li > 60       
            Li:=66   
        ENDIF          
    
        QRYBIZ->(DBSKIP())
    
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

STATIC FUNCTION QueryBiz()   
    LOCAL _cStrConn  := 'MSSQL/BIZERBA_BRAIN2_Result' //String de conexรฃo no DBAccess
    LOCAL _cHostDBA  := "10.0.10.4" //Servidor do DBAccess
    LOCAL _nPortaDBA := 7890 //Porta de coenxรฃo com DBAccess
    LOCAL _nHandle   := 0    

	_nHandle := TcLink(_cStrConn, _cHostDBA, _nPortaDBA)

    IF _nHandle >= 0        
        _cQueryBiz := "SELECT DISTINCT(CommonText1) AS NUMERO_CAIXA, Timestamp AS DTA_CRIACAO, PrintedNetWeightValue AS PESO "
        _cQueryBiz += "FROM PackageRecord "
        
        IF SELECT("QRYBIZ") != 0
            QRYBIZ->(dbCloseArea())
        ENDIF
        
        TCQUERY _cQueryBiz NEW ALIAS "QRYBIZ"

        MsgInfo("Conexใo bem sucedida! Ok: " + cValToChar(_nHandle), "Aten็ใo")
    ELSE
        MsgAlert("Nใo foi possรญvel conectar! Erro: " + cValToChar(_nHandle), "Aten็ใo")
    ENDIF
    
    TCUNLink(_nHandle)
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
    
    DbSelectArea('SZ8')
    
    QRYPRO->(dbGoTop())
 
    QRYPRO->(SetRegua(LastRec()))
 
    WHILE QRYPRO->(!EOF())
        IncRegua()
 
        IF Li > 60
            cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
            @ Li,0 PSAY __PrtThinLine()                
        ENDIF   
    
        nCntImpr++     
        Li++   
    
        @ Li,001 PSAY QRYPRO->CAIXAPROTH
        @ Li,050 PSAY QRYPRO->CAIXABIZ
        //@ Li,070 PSAY SToD(QRYPRO->DATAINI)
        //@ Li,080 PSAY SToD(QRYPRO->DATAFIM)
        //@ Li,100 PSAY QRYPRO->MOTIVO
    
        IF Li > 60       
            Li:=66   
        ENDIF          
    
        QRYPRO->(DBSKIP())
    
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

STATIC FUNCTION QuerySZ8()
    _cQueryPro := "SELECT Z8_CONTROL AS CAIXAPROTH, Z8_SEQBIZE AS CAIXABIZ "
    _cQueryPro += "FROM " +  RetSQLTab('SZ8')
    _cQueryPro += "WHERE " + RetSQLFil('SZ8')
    _cQueryPro += "AND " + RetSQLDel('SZ8')
    _cQueryPro += "AND Z8_SEQBIZE <> ''"

    IF SELECT("QRYPRO") != 0
            QRYPRO->(dbCloseArea())
        ENDIF

        TCQUERY _cQueryPro NEW ALIAS "QRYPRO"        
RETURN
