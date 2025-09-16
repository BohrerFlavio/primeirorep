#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"

USER FUNCTION RBTSRV
    private oFont10   := tFont():New("arial new",,-18,,.t.,,,,)
	
    //PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "ACD" //TABLES "SA1", "SB1"

    DEFINE MSDIALOG oAut TITLE 'REINICIA SERVIÇOS DE AUTOMAÇÃO' from 000,000 To 150,400  PIXEL
		_oBtn01 := TButton():New(010, 030, "Reiniciar Serviço da Linha Parda da Emabalagem" , oAut, {|| reinicia(1) }, 150, 015, , , .F., .T., .F., , .F., , , .F.)
		_oBtn02 := TButton():New(030, 030, "Reiniciar Serviço da Linha Branca da Emabalagem", oAut, {|| reinicia(2) }, 150, 015, , , .F., .T., .F., , .F., , , .F.)
		_oBtn03 := TButton():New(050, 030, "Reiniciar Serviço do Pistão da Desossa"         , oAut, {|| reinicia(3) }, 150, 015, , , .F., .T., .F., , .F., , , .F.)
		//_oBtn03 := TButton():New(030, 075, "Reiniciar Desossa" 		, oAut,{|| reinicia(3) },70,015,,oFont10,.F.,.T.,.F.,,.F.,,,.F. )
    ACTIVATE MSDIALOG oAut CENTERED
RETURN

STATIC FUNCTION reinicia(_linha)
	MsgRun("Aguarde... Reiniciando o serviço...",,{||  resetServ(_linha) })
RETURN

STATIC FUNCTION resetServ(_linha)
    DO CASE
        CASE _linha = 1
            WaitRunSrv( "taskkill /f /im appserver-EMB1.exe" , .T. , "e:\" )


			//sleep(10000)
			Sleep(5000)

			retorno := WaitRunSrv( "net start TotvsProtheusOficialEMB1" , .T. , "e:\" )

			IF retorno = .T.
				MSGINFO("Serviço da linha parda reiniciado com sucesso!", "Informação")
			ELSE
				ALERT("Erro ao iniciar o serviço da linha parda! ")
			ENDIF
        CASE _linha = 2
            WaitRunSrv( "taskkill /f /im appserver-EMB2.exe" , .T. , "e:\" )

			//sleep(10000)
			Sleep(5000)

			retorno := WaitRunSrv( "net start TotvsProtheusOficialEMB2" , .T. , "e:\" )

			IF retorno = .T.
				MSGINFO("Serviço da linha branca reiniciado com sucesso!", "Informação")
			ELSE
				ALERT("Erro ao iniciar o serviço da linha branca! ")
			ENDIF
        CASE _linha = 3
            WaitRunSrv( "taskkill /f /im appserver-DSOLIN.exe" , .T. , "e:\" )

			//sleep(10000)
			Sleep(5000)

			retorno := WaitRunSrv( "net start TotvsProtheusOficialDSOLIN" , .T. , "e:\" )

			IF retorno = .T.        		
				MSGINFO("Serviço da desossa reiniciado com sucesso!", "Informação")
			ELSE
				ALERT("Erro ao iniciar o serviço da desossa! ")
			ENDIF
        OTHERWISE
    ENDCASE
RETURN
