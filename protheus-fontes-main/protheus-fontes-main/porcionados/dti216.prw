#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI216            º Autor ³ Lucas Bolzan º Data ³ 28/06/24  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faz conexão com banco de dados da Bizerba e coleta         º±±
±±             informações relativas a pesagem                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Porcionados                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION DTI216(cSeqBiz)    
    PRIVATE cStrConn  := 'MSSQL/BIZERBA_BRAIN2_Result' //String de conexÃ£o no DBAccess
    PRIVATE cHostDBA  := "10.0.10.4" //Servidor do DBAccess
    PRIVATE nPortaDBA := 7890 //Porta de coenxÃ£o com DBAccess
    PRIVATE nHandle   := 0    
    PRIVATE cReturn   := " "

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
        MsgAlert("Não foi possÃ­vel conectar! Erro: " + cValToChar(nHandle), "Atenção")
    ENDIF
    
    TCUNLink(nHandle)
RETURN cReturn
