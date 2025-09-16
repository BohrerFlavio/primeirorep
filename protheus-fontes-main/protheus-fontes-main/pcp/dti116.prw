#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "apvt100.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"

/*/{Protheus.doc} Previsão de Produção
Job para leitura de arquivo de previsões de produção
@author     Mauro Rodrigues
@since      21/01/2021
@return     .T.
/*/

User Function DTI116()

	Private _cCaminho := "\arquivos_importacao"
	Private _cCamArq  := "\arquivos_importacao\arquivo.txt"
	Private  oFile    := Nil

	//RpcSetType(3) // nao consome licenca
	aTables := {'SZG'}
	RPCSetEnv('01','00','industria','industria',"ACD","U_DTI116",aTables,,,,)

	while .T.
		if (ExistDir(_cCaminho,,.T.))
			oFile := FWFileReader():New(_cCamArq)
			lerArq(@oFile)
			
			nStatus := FRename(_cCamArq, '\arquivos_importacao\arquivo_' + StrTran(allTrim(DTOC(Date())), '/', '_') + '_' + StrTran(allTrim(Time()), ':', '_') +'.txt')		
			sleep(10000)
		else
			sleep(1000)
		endif
	enddo
Return .T.

/*
Função utilizada para ler o arquivo de informações
@author     Mauro Rodrigues
@since      25/01/2021
@return     Nil
*/
Static Function lerArq(oFile)
	if (oFile:Open())
		while (oFile:hasLine())			
			verifPEnt(oFile:GetLine())
		enddo
	endif

	oFile:Close()
return

/*
Função utilizada para validar os parâmetros de entrada (ZU_CONTEXA, ZU_COD, ZU_QPCAIX, ZU_QPPESO, ZU_DTRPROD,
ZU_NOTIMP, ZU_PRIORI, ZU_NUMETQ)
@author     Mauro Rodrigues
@since      25/01/2021
@return     Nil
*/
Static Function verifPEnt(_cLinha)
	Local aParEnt := {}
	//Local nI      := 0

	aParEnt := StrTokArr(_cLinha, ';')

	errorLog(_cLinha, "Parâmetro Inválido")


return

//mandar array com os erros
Static Function errorLog(_cLinha, _cError)
	Local _cCaminho := '\arquivos_importacao\errorLog.txt'
	Local oFile     := FWFileReader():New(_cCaminho)
	Local oWriter   := FWFileWriter():New(_cCaminho, .F.)
	Local n
	
	if !oFile:Exists()
		oWriter:Create()
		//oFile:Close()
	endif
	for n := 1 to 3	
		oWriter:Write(_cLinha + ' -------> ' + _cError + CRLF)
	next n
	oWriter:Close()	
return

