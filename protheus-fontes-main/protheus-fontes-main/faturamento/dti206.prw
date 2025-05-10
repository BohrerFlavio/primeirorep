#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI206    บAutor  ณLucas Bolzan     บ Data ณ  27/02/24      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Relat๓rio de pesagens de veํculos                         บฑฑ
ฑฑบ          ณ  Substitui rotina GJF25                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCP           .                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION DTI206()
    
    LOCAL wnrel     := "DTI206"
    LOCAL cString   := "SZT"
    LOCAL titulo    := "Relat๓rio de pesagens de veํculos"
    LOCAL NomeProg  := "DTI206"
    LOCAL Tamanho   := "M"
    PRIVATE aReturn :={"Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
    PRIVATE cPerg   	 := "GJF25"
    PRIVATE nLastKey     := 0    

    Pergunte(cPerg,.F.) 

    _aDados	 := {}   
    _aCabec	 := {}

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
    titulo:= oemtoansi("Relat๓rio de pesagens de veํculos")
    cabec1:= oemtoansi("Codigo     Placa   Tipo Carga    Data e Horarios Entrada/Saida          Pesos Entrada/Saida(kg)         Peso Lํquido(kg)")
    cabec2:=""
 
    QRY->(dbGoTop())
 
    QRY->(SetRegua(LastRec()))
 
    WHILE QRY->(!EOF())
        IncRegua()
 
        IF Li > 60
            cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
            @ Li,0 PSAY __PrtThinLine()                
        ENDIF   
    
        nCntImpr++     
        Li++   
    
        @ Li,001 PSAY QRY->ZT_COD
        @ Li,010 PSAY QRY->ZT_PLACA        
        //@ Li,070 PSAY SToD(QRY->DATAINI)
        //@ Li,080 PSAY SToD(QRY->DATAFIM)
        //@ Li,100 PSAY QRY->MOTIVO
		do case
			case QRY->ZT_TPCARGA = 'PA'
			@ Li,020 psay 'Produto Acabado'
			case QRY->ZT_TPCARGA = 'CO'
			@ Li,020 psay 'Couro'
			case QRY->ZT_TPCARGA = 'OS'
			@ Li,020 psay 'Osso/Sangue'
			case QRY->ZT_TPCARGA = 'GA'
			@ Li,020 psay 'Gado'
			case QRY->ZT_TPCARGA = 'SE'
			@ Li,020 psay 'Sebo'
			case QRY->ZT_TPCARGA = 'BI'
			@ Li,020 psay 'Bilis'
			otherwise
			@ Li,020 psay 'Outros'
		endcase
		if empty(QRY->ZT_HORAS)			
            @ Li,30 psay DToC(SToD(QRY->ZT_DATAE)) + ' - ' + QRY->ZT_HORAE
		else
			@ Li,30 psay DToC(SToD(QRY->ZT_DATAE)) + ' - ' + QRY->ZT_HORAE + ' | ' + DToC(SToD(QRY->ZT_DATAS)) + ' - ' + QRY->ZT_HORAS
		endif
		if empty(QRY->ZT_PESOS)
			@ Li,70 psay transform(QRY->ZT_PESOE, "@E 999,999.99")
		else
			@ Li,70 psay transform(QRY->ZT_PESOE, "@E 999,999.99") + ' | ' + transform(QRY->ZT_PESOS, "@E 999,999.99")
		endif

        if (!Empty(QRY->ZT_PESOS))
            @ Li,105 PSAY transform(QRY->ZT_PESOS - QRY->ZT_PESOE, "@E 999,999.99")
        endif
    
        IF Li > 60       
            Li:=66   
        ENDIF
        //Cria o array para colocar no arquivo excel
        if (!Empty(QRY->ZT_PESOS))
            aAdd(_aDados, { QRY->ZT_COD,;
                            QRY->ZT_PLACA,;
                            QRY->ZT_TPCARGA,;
                            SToD(QRY->ZT_DATAE),;
                            QRY->ZT_HORAE,;
                            SToD(QRY->ZT_DATAS),;
                            QRY->ZT_HORAS,;
                            QRY->ZT_PESOE,;
                            QRY->ZT_PESOS,;
                            QRY->ZT_PESOS - QRY->ZT_PESOE,;
                           })
        else
            aAdd(_aDados, { QRY->ZT_COD,;
                            QRY->ZT_PLACA,;
                            QRY->ZT_TPCARGA,;
                            SToD(QRY->ZT_DATAE),;
                            QRY->ZT_HORAE,;
                            SToD(QRY->ZT_DATAS),;
                            QRY->ZT_HORAS,;
                            QRY->ZT_PESOE,;
                            QRY->ZT_PESOS,;
                           })
        endif

        QRY->(DBSKIP())
    ENDDO
 
    IF li != 80    
        Roda(nCntImpr,cRodaTxt,Tamanho)
    ENDIF
    
    //GeraCSV()    

    Set Device to Screen

    //Gera o arquivo excel
    If Len(_aDados) > 0
		aAdd(_aCabec, {"C๓digo"         , "C", 8, 0})
		aAdd(_aCabec, {"Placa"          , "C", 7, 0})
		aAdd(_aCabec, {"Tipo de carga"  , "C", 2, 0})
		aAdd(_aCabec, {"Data de entrada", "D", 8, 2})
		aAdd(_aCabec, {"Hora de entrada", "C", 5, 2})
        aAdd(_aCabec, {"Data de saํda"  , "D", 8, 2})
		aAdd(_aCabec, {"Hora de saํda"  , "C", 5, 2})
        aAdd(_aCabec, {"Peso de entrada", "N", 8, 2})
        aAdd(_aCabec, {"Peso de saํda"  , "N", 8, 2})
        aAdd(_aCabec, {"Peso liquido"   , "N", 8, 2})

		U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
	Endif	

    IF aReturn[5] = 1      
        Set Printer To     
        dbCommitAll()      
        OurSpool(wnrel)
    ENDIF
    MS_FLUSH()
RETURN

STATIC FUNCTION ConsultaDB()
    cQuery := "SELECT ZT_COD, ZT_PLACA, ZT_TPCARGA, ZT_DATAE, ZT_DATAS, ZT_HORAE, ZT_HORAS, ZT_PESOE, ZT_PESOS "
	cQuery += "FROM " +  RetSqlName("SZT")
	cQuery += " WHERE" + RetSQLFil('SZT')
	cQuery += " AND ZT_DATAE >= '" + DToS(mv_par01) + "' AND ZT_DATAS <= '" + DToS(mv_par02) + "'"
	if mv_par03 = 1
		cQuery += " AND ZT_STATUS = 'PA'
	endif
	if mv_par03 = 2
		cQuery += " AND ZT_STATUS = 'OK'
	endif
	if mv_par04 = 2
		cQuery += " AND (ZT_PLACA = 'IQB2J34' OR ZT_PLACA = 'IXV3H62' OR ZT_PLACA = 'EQT6F69' OR ZT_PLACA = 'IVD0I57' OR ZT_PLACA = 'IUG2089' OR ZT_PLACA = 'IOI5B78' OR ZT_PLACA = 'IXU1385' OR ZT_PLACA = 'IXU0416' )"
	endif

	cQuery := ChangeQuery(cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "QRY"
RETURN

STATIC FUNCTION GeraCSV()
    aCampos := {}

    aAdd(aCampos, {"C๓digo"         , QRY->ZT_COD})
    aAdd(aCampos, {"Placa"          , QRY->ZT_PLACA})
    aAdd(aCampos, {"Tipo de carga"  , QRY->ZT_TPCARGA})
    aAdd(aCampos, {"Data de entrada", QRY->ZT_DATAE})
    aAdd(aCampos, {"Hora de entrada", QRY->ZT_HORAE})
    aAdd(aCampos, {"Data de saํda"  , QRY->ZT_DATAS})
    aAdd(aCampos, {"Hora de saํda"  , QRY->ZT_HORAS})

    DlgToExcel({{"TABELA","Titulo",aCampos,"QRY"}})
RETURN
