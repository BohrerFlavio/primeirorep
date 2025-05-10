#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI100   º Autor ³ Mauricio Roehrsº Data ³  08/04/2020      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de controle de automação de pesagem de carcaças na   º±±
±±º          ³desossa                                                     º±±
±±º          ³ Dia 10/08/21 ajuste feito por Flavio por troca de balança  º±±
±±º          ³   OBS - Henrique do Custos utilizava para procedimento     º±±
±±º          ³ Dia 13/06/22 ajuste feito por Flavio para emitir som após  º±± 
±±º          ³ gravar peso											      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAPCP                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//////////////////////////////////////////////////////////
////////////////Funções para JOB /////////////////////////
//////////////////////////////////////////////////////////

//Função destinada a gravar os eventos da automação
Static Function RegEv(_desc,_status,_resp,_cod,_string,_prod,_lin,_pesob,_tara)

	Local _nID := ZAF->(RecCount()) + 1

	ZAF->(DbSetOrder(1))

	reclock('ZAF',.t.)
	ZAF->ZAF_FILIAL := FWxfilial('ZAF')
	ZAF->ZAF_ID     := _nID
	ZAF->ZAF_DESC   := _desc
	ZAF->ZAF_DATA   := date()
	ZAF->ZAF_HORA   := time()
	ZAF->ZAF_STATUS := _status
	ZAF->ZAF_COD    := _cod
	ZAF->ZAF_RESP   := _resp
	ZAF->ZAF_STRING := _String
	ZAF->ZAF_PROD   := _prod
	ZAF->ZAF_LIN    := _lin
	ZAF->ZAF_PESOB  := _pesob
	ZAF->ZAF_TARA   := _tara
	msunlock()

return

//Função realiza o registro da produção
//na tabela SZ8 e demais tabelas
Static Function Registro()
	Private cExecWeb    := 'sndrec32.exe'    
    Private cTmpPath    := GetTempPath(.T.,.F.)
    Private cTempPath   := STrTran(cTmpPath,'Temp','Programs\web-agent')

	_cHora := time()	
	_cNum := getSx8Num('ZC9','ZC9_NUM')
	ConfirmSX8()
	//conout("Vai gravar na ZC9")
	reclock('ZC9',.t.)
		ZC9_FILIAL := FWxFilial('ZC9')
		ZC9_DATA   := date()
		ZC9_HORA   := _cHora
		ZC9_CORORI := "T"//_cCorte
		ZC9_PESO   := _nPesoMedio
		ZC9_NUM    := _cNum
		ZC9_STATUS := 'OK'
		ZC9_STRING := 'Gravando Peso Médio ok!!'
	msunlock()
	conout("Gravou na ZC9")

	/* Ativar aviso Sonoro */
	if !('HTML' $ u_remoteType())
		WINEXEC("C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV",0)
	else
		WINEXEC(cTempPath + cExecWeb + ' /play /close /embedding ' + cTempPath + 'GEER.WAV',0)
	endif	
return .t.

//Função destinada a executar o processo
//Captura do codigo, pesagem, atualização da previsão e
//registro de produção
Static Function prDSO()
	local aPesos := {} 
	_lOk := .f.
	_cCodPro  := ''
	_cControl := ''
	_nQuant   := 0
	_nPMPec   := 0.00
	_nPeso    := 0.00
	_nPesoL   := 0.00
	_nTara    := 0.00
	_cStrBal  := ''
	_cFim     := ''
	_cStrT    := ''
	cB		  := ''
	cPeso := 0
	_cString1 := ''
	_cString2 := ''
	_cString3 := ''
	_cString4 := ''
	_cString5 := ''
	_cString6 := ''
	_cSti1 := ''
	_cSti2 := ''
	_cSti3 := ''
	_cSti4 := ''
	_cSti5 := ''
	_cSti6 := ''
	_cSti7 := ''
	_cLote    := ''
	aPesos := {}
	_nMaior := 0
	_cValStr := ''
	_me1 := ''
	_cHora := time()

	if( !oObj:IsConnected() )
		conout("--> Falha na conexão")

		oObj  := tSocketClient():New()
		nResp := oObj:Connect(9000, '10.6.20.85', 1000 )
		nResp := oObj:Send( 'Teste' )
		_cString := CaptIP()
	else
		conout("--> Conexão OK")
	endif

	_cString1 := CaptIP()

	_D1 := strtran(substr(alltrim(_cString1),1,5),',','.')	
	_nDados := val(_D1)

	if  'E' $  alltrim(_cString1)
		_cValStr := 'E'
	elseif   'I' $  alltrim(_cString1)
		_cValStr := 'I'
	endif

	// Aqui é a regra de peso da string
	if _cValStr = 'E' 
		if _nDados > 14 .and. _nCont < 5
			_nSomaPeso += _nDados
			_nCont++
		elseif _nDados > 14 .and. _nCont >= 5
			_lOk := .t.
		endif
	elseif _cValStr = 'I'
		_nCont := 0
		_nSomaPeso := 0
	endif
	if _nDados <= 0
		lGrav := .t.
	endif
	conout("_cString1==>" + _cString1)
	//conout("_cValStr==>" + _cValStr)
	conout("Inicia o teste lógico _lOK")
	if _lOk .and. lGrav
		conout("Termina o teste lógico _lOK com resultado positivo")
		_nPesoMedio := _nSomaPeso / _nCont
		_nSomaPeso := 0
		_nCont := 0
		lGrav := .f.

		if _nPesoMedio > 14
			Registro()
		endif
	else
		//conout('##### 204 - não validou a gravação ######'+ _cString1)
	endif	
return .t.

User Function pesDSO()

	Private _cCodPro  	:= ''
	Private _nQuant   	:= 0
	Private _nPeso    	:= 0
	Private _nPesoL   	:= 0
	Private _nTara    	:= 0
	Private _cControl 	:= ''
	Private nHdll     	:= 0
	Private _lFailCon 	:= .f.
	Private _nTamZAF  	:= 0
	Private _cStrBal  	:= ''
	Private _nTime    	:= 1000   //tempo em milissegundos usado para frear o loop de produção
	Private _nSomaPeso 	:= 0
	Private _nCont 		:= 0
	Private _nPesoMedio := 0
	Private _lBal      	:= .f.  
	Private lGrav		:= .f.

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "ACD"

	_cIPBdes := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') +'BDSO1',1))

	oObj  := tSocketClient():New()

	nResp := oObj:Connect(9000, _cIPBdes, 1000 )
	nResp := oObj:Send( 'Teste' )
	_cString := CaptIP()

	while .t.
		PrDSO()
	enddo	

	RESET ENVIRONMENT
Return

//função para conectar na balança
Static Function ctBalDSO()
	Local oObj := tSocketClient():New()
	Local nX := 0
	nPort := 9092

	//Define o IP da balança a se utilizada Para Desossa
	nIp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') +'BEXP2',1))
	// -------------------------------
	// Tenta conectar 3 vezes
	// -------------------------------
	For nX := 1 to 3        
		nResp := oObj:Connect( nPort,nIp,1000 )
		// -------------------------------
		// Se conectou abandona o FOR
		// -------------------------------
		if(nResp == 0 )
			exit
		else
			Sleep(2000)
		endif
	Next  

	// --------------------------------------
	// Verifica se a conexão foi bem sucedida
	// --------------------------------------
	if( !oObj:IsConnected() )
		conout("--> Falha na conexão")
		return
	else
		//conout("--> Conexão OK")
	endif

	//Se a balança já estiver conectada, disconecta... rotina utilizada no abate
	if _lBal
		oObj:CloseConnection()
	endif

	cBuffer := ""
	nQtd = oObj:Receive( cBuffer,1000)

	_lBal := .t.

return


//função para conectar na balança
Static Function cBal()

	//Define o IP da balança a se utilizada
	_cIpBal := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') +'BEXP2',1))

	if empty(_cIpBal)
		vtalert('Endereço IP da balança não encontrado!')
		return
	endif

	//Se a balança já estiver conectada, disconecta...
	if _lBal
		oObj  := tSocketClient():New()
		oObj:CloseConnection()
	endif
	oObj  := tSocketClient():New()
	nResp := oObj:Connect( 9000, _cIpBal,1000)  //9092  10.6.20.53
	nResp := oObj:Send( 'Teste' )

	_lBal := .t.
return


//Função que vai fazer a pesagem das caixas via conexão socket (ethernet)
Static Function CaptIP()
	local _cString  := ""

	nQtd := oObj:Receive(_cString,1000)
	/* 
	Problema - quando se abre um telnet o sistema deixa de receber informações
	verificar  uma forma de capturar uma informação e dar um alert na tela do botão
	*/
return _cString
