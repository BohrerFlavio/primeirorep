#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT18     º Autor ³Mauricio Roehrsº   Data ³  23/03/20     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ pesagem de carcaças na desossa	                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Função para Inventario
User Function MRVT18(_usuario)


	Private _cModelo  := ''
	Private _lOk      := .t.
	Private _cCod 	  := ''
	Private _cCorte	  := ' '
	Private _nPeso    := 0
	Private _nTara    := 3.25
	Private _cPesar   := ' '
	Private _cConfirma := 'S'
	
	Private _lBal      := .f.            //Ativação dos parametros da balança
	Private oObj
	Private nResp      := 0
		
	ZAA->(DbSetOrder(2))
	ZAA->(DbSeek(xfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL23 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif


	//Define o tamanho da Tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()
	
	//chama a função para conctar na balança
	conectBal()

	while _lOk

		//_cCam := space(2)
		//_cCod := Space(11)

		//VTRead

		_KeyD := VTSetKey(53,{|| Pesar() })

		@ 01,00 VTSay "Pesagem de Carcaças"
		@ 05,05 VTSay "Selecione o Corte"
		@ 06,08 VTSay "[ ] 1:Diant.|2:Trasei."
		@ 06,09 VTGet _cCorte Pict "@!" VALID _cCorte $ '1/2'
		@ 07,05 VTSay "Pesar: [ ] 5"
		@ 07,13 vtGet _cPesar Pict "@!" 
		@ 09,05 VTSay 'Confirmar? [ ]' 
		@ 09,17 vtGet _cConfirma  Pict '@!' VALID  _nPeso > 0 //_cConfirma $ 's/S' .and.
		
		@ 08,08 VTSay "["+transform(_nPeso,'999.99')+"]"
		//@ 08,09 VTGet _cCod Pict "@!" VALID ValInv01()

		VTRead

		_KeyD := VTSetKey(53,{|| Pesar() })
		
		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF
		
		if _nPeso > 0
			_cNum := getSx8Num('ZC9','ZC9_NUM')
			ConfirmSX8()
			reclock('ZC9',.t.)
			ZC9_FILIAL := xFilial('ZC9')
			ZC9_DATA   := dDataBase
			ZC9_HORA   := time()
			ZC9_CORORI := iif(_cCorte = '1','D','T')
			ZC9_PESO   := _nPeso
			ZC9_NUM    := _cNum
			msunlock()	

			@10,01 VTSAY 'Gravado peso: ' + transform(_nPeso,'999.99')
			
		endif
		
		_nPeso := 0
		@ 08,08 VTSay "["+transform(_nPeso,'999.99')+"]"
		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

Return



Static Function NaoAchou(_cMens)
	VTBeep(1)
	@09,00 VTSay Space(30)
	@10,00 VTSay "Cod. Carcaca:   "+Space(30)
	@10,11 VTSay _cCod
	@11,00 VTSay Space(30)
	@12,00 VTSay Space(30)
	@13,00 VTSay Space(30)
	@14,00 VTSay Space(30)
	@11,00 VTSay _cMens + Space(30)
	@15,00 VTSay Space(30)
	_cCod := Space(11)
return .f.


Static Function NaoAchou2(_cMens2)
	VTBeep(1)
	@09,00 VTSay Space(30)
	@10,00 VTSay "Cod. Camera:   "+Space(30)
	@10,11 VTSay _cCam
	@11,00 VTSay Space(30)
	@12,00 VTSay Space(30)
	@13,00 VTSay Space(30)
	@14,00 VTSay Space(30)
	@11,00 VTSay _cMens2 + Space(30)
	@15,00 VTSay Space(30)
	_cCam := Space(2)
return .f.

Static Function NaoAchou3(_cMens3)
	VTBeep(1)
	@09,00 VTSay Space(30)
	@10,00 VTSay "Cod. Carcaca:   "+Space(30)
	@10,11 VTSay _cCod
	@11,00 VTSay Space(30)
	@12,00 VTSay Space(30)
	@13,00 VTSay Space(30)
	@14,00 VTSay Space(30)
	@11,00 VTSay _cMens3 + Space(30)
	@15,00 VTSay Space(30)
	_cCod := Space(11)
return .f.



//Função auxiliar para captura de peso
Static Function Pesar()

		
	_nPeso := newCaptura()


	@ 08,08 VTSay "["+transform(_nPeso,'999.99')+"]"

	VTClearBuffer()

return


//função separada para capturar peso com a balança nova
Static Function newCaptura()

	local _nTam     := getMv('SI_QTSTR')//parametro com valor total de strings de peso a serem armazenadas para tratamento
	local _nStrOk   := 0
	local aStrings  := {}
	local aPesos    := {}
	local nPeso 	:= 0
	local _nMaior   := 0
	local _nCont    := 0
	local cPeso     := ""
	local cC        := ""
	local _cBuffer  := ""
	local _nPesosOk := 0
	Local i
	Local j

	//verifica qual tecla foi utilizada e zera as variaveis
	_nPeso := 0

	//bloco que armazena as strings que tiverem o peso estável
	for i:=1 to _nTam
		_cBuffer := ""
		nQtd 	   := oObj:Receive( @_cBuffer, 1000 )
		if "q`" $ alltrim(_cBuffer)//SE TIVER "3P" NA STRING QUER DIZER QUE É UM PESO ESTAVEL
			aAdd(aStrings,_cBuffer)
			_nStrOk++
		endif
	next

	//verifica se o buffer não esta sendo retornado em branco, caso esteja reconecta na balança
	if empty(_cBuffer)
		conectBal()
	endif

	//bloco para tratamento das strings com peso estável
	for i:= 1 to len(aStrings) //_nStrOk
		do Case
			Case at("p`",aStrings[i])> 0
			cPeso := substr(aStrings[i],at("p`",aStrings[i])+2,6)
			cC := "`"

			Case at("`",aStrings[i]) > 0
			cPeso := substr(aStrings[i],at("`",aStrings[i])+1,6)
			cC := "`"

			Case at("p ",aStrings[i])> 0
			cPeso := substr(aStrings[i],at("p ",aStrings[i])+2,6)
			cC := " "

			Otherwise
			cPeso :='000000'
			cC := ""
		Endcase

		cPeso := substr(aStrings[i],at("`",aStrings[i])+1,6)
		cPeso := substr(aStrings[i],at(cC,aStrings[i])+1,6)
		nPeso := val(cPeso)/(100)
		if nPeso > 0 //adiciona no vetor de pesos ok somente pesos acima de zero
			aAdd(aPesos,nPeso)
			_nPesosOk++
		endif
	next

	//bloco para tratamento de incidencias, ou seja, utiliza somente o peso que tiver mais incidencias dentro do vetor
	for i:= 1 to len(aPesos)//_nPesosOk
		_nCont := 0
		for j:=1 to len(aPesos)//_nPesosOk
			if aPesos[i] == aPesos[j]
				_nCont++
			endif
		next

		if _nCont > _nMaior
			nPeso   := aPesos[i] - _nTara
			_nMaior := _nCont
		endif
	next

return nPeso

//função para conectar na balança
Static Function conectBal()

	//Define o IP da balança a se utilizada
	_cIpBal := alltrim(fBuscaCPO('ZAM',1,xFilial('ZAM') +'BDSO1','ZAM_IP'))

	if empty(_cIpBal)
		vtalert('Endereço IP da balança não encontrado!')
		return
	endif

	//Se a balança já estiver conectada, disconecta...
	if _lBal
		oObj:CloseConnection()
	endif
	     
	oObj  := tSocketClient():New()
	nResp := oObj:Connect( 9000, _cIpBal,1000)  //9092  ( Porta , Balança , timeout)	
	nResp := oObj:Send( 'Teste' )
	
	//conout(_cIpBal)
	
	_lBal := .t.

return
