#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

user function dti74()
	//Tratativa para reiniciar o TSS quando tiver problemas
	MsgRun("Aguarde... Reiniciando o serviço...",,{||  resetServ() })

	alert("Serviço reiniciado com sucesso!")

return

Static Function resetServ()

		WaitRunSrv( "taskkill /f /im appserver_TSS.exe" , .T. , "E:\TOTVS12\TSS1_Oficial\bin\appserver\" )

		sleep(10000)

		WaitRunSrv( "net start TotvsSpedOficialTSS1" , .T. , "E:\" )
	
return
