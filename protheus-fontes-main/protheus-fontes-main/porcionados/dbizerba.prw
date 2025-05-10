#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DBIZERBA          º Autor ³ Lucas Bolzan º Data ³ 25/03/25  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importa do banco de dados da Bizerba as caixas produzidas  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Porcionados                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION DBIZERBA()	
    PRIVATE Enviroment := GetEnvServer()

    IF (Enviroment = 'SCHEDULE')
		aTables := {"ZY4","ZAS"}
		RpcSetEnv("01","00","Administrador","dt1@s1lv4","PCP","DBIZ",aTables)

		U_DBIZ()

		RpcClearEnv()
    ELSE
        PRIVATE tsTop      := 0
        PRIVATE tsLeft     := 0
        PRIVATE tsBottom   := 200
        PRIVATE tsRight    := 300
        PRIVATE tsCaption  := 'Importação de produção BIZERBA.'
        PRIVATE tsClrText  := CLR_BLACK
        PRIVATE tsClrBack  := CLR_WHITE
        PRIVATE tsPixel    := .T.
        PRIVATE dData      := SToD("")        

        oDialog  := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
        oFont    := TFont():New('Arial',, -18, .T.)
        oSay     := TSay():New(025,010,{||'Data de produção a ser importada:'},oDialog,,oFont,,,,.T.,tsClrText,tsClrBack,200,20)
        oTGet    := TGet():New(040,050,{ | u | If( PCount() > 0, dData := u, dData) },oDialog,40,10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t., )        
        oTButton := TButton():New(060, 050, "Importar",oDialog,{||MsAguarde({||U_DBIZ(dData)},'Aguarde',"Aguarde. Esse processo pode demorar alguns minutos.")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )        
        oDialog:Activate(,,,.T.,,,)        
    ENDIF
RETURN

USER FUNCTION DBIZ(dData)
    LOCAL cStrConn  := 'MSSQL/BIZERBA_BRAIN2_Result' //String de conexÃ£o no DBAccess
    LOCAL cHostDBA  := "10.0.10.4" //Servidor do DBAccess
    //LOCAL cHostDBA  := "10.0.20.18" //Servidor do DBAccess
    LOCAL nPortaDBA := 7890 //Porta de coenxÃ£o com DBAccess
    LOCAL nHandle   := 0
    LOCAL aDados    := {}
    LOCAL cData     := DToS(dData)
    LOCAL cDirArq   := CurDir() + '\files_silva\'
    LOCAL cArquivo  := 'ZY4_' + cData + '.txt'
    LOCAL oFWriter  := Nil
    LOCAL nI        := 0

    nHandle := TcLink(cStrConn, cHostDBA, nPortaDBA)

    IF nHandle >= 0     
        IF (cData > DToS(date()))
            MsgAlert("Uma data futura não pode ser informada.","Alerta")
            RETURN .F.
        ELSE
            MsProcTxt("Aguarde. Obtendo dados.")

            cQRYBIZ := "SELECT DISTINCT (CONVERT(VARCHAR(14),CommonText1)) AS NUMCAIXA, PrintedNetWeightValue AS PESO, DeviceMachineNo AS LINHA, CONVERT(VARCHAR,[CreationDate],112) AS DTAPROD, CONVERT(VARCHAR,[CreationDate],108) AS HORAPROD "
            cQRYBIZ += "FROM PackageRecord "
            cQRYBIZ += "WHERE CONVERT(VARCHAR,[CreationDate],112) = " + "'" + cData + "'"

            IF SELECT("QRYBIZ") != 0
                QRYBIZ->(dbCloseArea())
            ENDIF

            TCQUERY cQRYBIZ NEW ALIAS "QRYBIZ"
            QRYBIZ->(dbGoTop())        

            IF File(cDirArq+cArquivo)
                FErase(cDirArq+cArquivo)
            ENDIF
            oFWriter := FWFileWriter():NEW(cDirArq+cArquivo,.T.)
            IF !oFWriter:Create()
                MsgAlert('Erro ao criar o arquivo','Alerta')
            ELSE
                WHILE QRYBIZ->(!EOF())
                    nI++
                    TCSqlToArr(cQRYBIZ, aDados)       
                    
                    cPeso := StrTran(AllTrim(Transform(aDados[nI][2],'@E 999.99')),',','.')

                    IF(Len(cPeso)<5)                                        
                        cPeso := '0' + cPeso
                    ELSE                    
                        cPeso := cPeso
                    ENDIF                

                    oFWriter:Write(AllTrim(aDados[nI][1]) + ";" + cPeso + ";" + "00" + AllTrim(STR(aDados[nI][3])) + ";" + AllTrim(aDados[nI][4]) + ";" + AllTrim(aDados[nI][5]) + CRLF)
                    QRYBIZ->(DbSkip())
                ENDDO
                aDB_BIZERBA := aDados
                oFWriter:Close()                
            ENDIF     
        ENDIF   
    ELSE
        Conout("Não foi possÃ­vel conectar! Erro: " + cValToChar(nHandle))
    ENDIF
    
    TCUNLink(nHandle)
    
    IF Len(aDados) != 0        
        GravaDBProth(cDirArq, cArquivo)
    ENDIF
RETURN

STATIC FUNCTION GravaDBProth(cDirArq, cArquivo)    
    LOCAL cDirArq := cDirArq
    LOCAL cArquivo  := cArquivo

    oFile := FWFileReader():New(cDirArq+cArquivo)
    IF (oFile:Open())
        IF ! (oFile:EoF())
            WHILE (oFile:HasLine())
                _cLinAtu  := oFile:GetLine()

                _cID := GetSx8num('SZ8','Z8_ID')
		        ConfirmSx8()
		        _cControl := '00' + _cID
                _cFilial  := xfilial('ZAS')                
                _cCod     := AllTrim(GetAdvFVal('ZAU','ZAU_COD',FWxfilial('ZAU') + SubSTR(_cLinAtu,1,10),1))
                _cDescri  := AllTrim(GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1') + AllTrim(GetAdvFVal('ZAU','ZAU_COD',FWxfilial('ZAU') + SubSTR(_cLinAtu,1,10),1)),1))
                _dDtaProd := SToD(SubSTR(_cLinAtu,26,8))
                _nValidade:= GetAdvFVal('SB1','B1_VALID',FWxfilial('SB1') + GetAdvFVal('ZAU','ZAU_COD',FWxfilial('ZAU') + SubSTR(_cLinAtu,1,10),1),1)
                _nPesoLiq := VAL(SubSTR(_cLinAtu,16,5)) - GetAdvFVal('ZAU','ZAU_TARAT',FWxfilial('ZAU') + SubSTR(_cLinAtu,1,10),1)
                _nPesoBrt := VAL(SubSTR(_cLinAtu,16,5))
                _nTara    := GetAdvFVal('ZAU','ZAU_TARAT',FWxfilial('ZAU') + SubSTR(_cLinAtu,1,10),1)
                _cLote    := SubSTR(_cLinAtu,1,10)
                _nPesoFix := Val(StrTran(GetAdvFVal('ZAU','ZAU_IPEFIX',FWxfilial('ZAU') + SubSTR(_cLinAtu,1,10),1),',','.'))//VAL(GetAdvFVal('ZAU','ZAU_IPEFIX',FWxfilial('ZAU') + SubSTR(_cLinAtu,1,10),1))
                _cLinha   := SubSTR(_cLinAtu,22,3)                                                                                                     
                _cHoraProd:= SubSTR(_cLinAtu,35,8)                                                                                                     
                _cFamArm  := GetAdvFval('SBM','BM_FARM',FWxfilial('SBM') + GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+GetAdvFVal('ZAU','ZAU_COD',FWxfilial('ZAU') + SubSTR(_cLinAtu,1,10),1),1),1)                
                _cSeqBiz  := SubSTR(_cLinAtu,1,14)
                _nPesMin  := GetAdvFval('SB1','B1_PESOMIN',FWxFilial('SB1') + AllTrim(GetAdvFVal('ZAU','ZAU_COD',FWxfilial('ZAU') + SubSTR(_cLinAtu,1,10),1)),1)
		        _nPesCaix := VAL(SubSTR(_cLinAtu,16,5))

                MsProcTxt("Aguarde. Gravando dados.")
                
                //POPULA A TABELA DE CAIXAS PRODUZIDAS PELA BIZERBA 5 E 6                                            
                DBSelectArea("ZY4")
                ZY4->(DBSetOrder(1))
                IF !(ZY4->(DbSeek(xfilial('ZY4') + _cSeqBiz)))
                    reclock('ZY4',.T.)
                        ZY4->ZY4_FILIAL := xfilial('ZY4')
                        ZY4->ZY4_NUMCXA := _cSeqBiz
                        ZY4->ZY4_PESO   := _nPesoBrt
                        ZY4->ZY4_LINHAB := _cLinha
                        ZY4->ZY4_DTAPRO := _dDtaProd
                        ZY4->ZY4_HORAPR := _cHoraProd
                        ZY4->ZY4_CODPRO := _cCod
                        ZY4->ZY4_PESOMI := _nPesMin
                    msunlock()
                ENDIF
                IF (_nPesoBrt >= _nPesMin) .and. (_nPesoBrt  > _nTara)                   
                    //POPULA A TABELA DE PRODUTOS DO PORCIONADOS                
                    DBSelectArea("ZAS")
                    ZAS->(DBSetOrder(15))
                    IF !(ZAS->(DbSeek(xfilial('ZAS') + _cSeqBiz)))
                        IF !ValExistCx(_cSeqBiz)
                            reclock('ZAS',.T.)
                                ZAS->ZAS_FILIAL := xfilial('ZAS')
                                ZAS->ZAS_CONTRO := _cControl
                                ZAS->ZAS_COD    := _cCod
                                ZAS->ZAS_DESC   := _cDescri
                                ZAS->ZAS_DTPROD := _dDtaProd
                                ZAS->ZAS_VALID  := _nValidade
                                ZAS->ZAS_PESOL  := _nPesoLiq
                                ZAS->ZAS_PESOB  := _nPesoBrt
                                ZAS->ZAS_TARA   := _nTara
                                ZAS->ZAS_TERC   := 'N'                                
                                ZAS->ZAS_TIPO   := 'PA'
                                ZAS->ZAS_LOTE   := _cLote
                                ZAS->ZAS_PESFIX := _nPesoFix
                                ZAS->ZAS_LIN    := _cLinha
                                ZAS->ZAS_HORA   := _cHoraProd
                                ZAS->ZAS_FARM   := _cFamArm
                                ZAS->ZAS_SETPRO := 'P'
                                ZAS->ZAS_SEQBIZ := _cSeqBiz
                                ZAS->ZAS_STRRX  := 'Importacao DBIZERBA'
                            msunlock() 
                        ENDIF                   
                    ENDIF                
                ELSE
                  Conout("Peso da caixa " + _cSeqBiz + " menor ou igual ao peso minimo OU peso da caixa  " + _cSeqBiz + " menor que a tara")                  
                ENDIF             
            ENDDO
            IF (!Enviroment = 'SCHEDULE')
                MsgInfo("Importação concluida.","Aviso")
            ENDIF
        ENDIF
        oFile:Close()
    ELSE
        Conout("O arquivo não pode ser aberto")
    ENDIF
RETURN

STATIC FUNCTION ValExistCx(_cSeqBiz)
    LOCAL _cQuery   := ""
    LOCAL nCount    := 0 
    LOCAL _lRet     := .f.

    _cQuery := "SELECT ZAS.D_E_L_E_T_ AS DELETADO FROM " + RetSqlTab("ZAS")
    _cQuery += "WHERE " + RetSQLFil('ZAS') + " AND ZAS_SEQBIZ = '" + _cSeqBiz + "'"

    cAlias := GetNextAlias()
	TCQuery _cQuery new alias &cAlias

    (cAlias)->(dbGoTop())
    
    Count to nCount

    IF nCount > 0
        _lRet := .t.
    ENDIF

    (cAlias)->(dbCloseArea())
RETURN _lRet
