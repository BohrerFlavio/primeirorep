#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "apvt100.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} VT-100
Rotina que efetua rendimento da costela
@author     Mauro Rodrigues
@since      04/01/2021
@return     .T.
/*/

User Function MRVT19(_usuario)

	Private _lOk     := .T.
	Private _cCorte  := ''  //B1_COD
	Private _cApont  := ''  //1 - entrada, 2 - saida
	Private nPeso   := 0.0 
	Private oObj     := Nil
	Private _ZK_C1   := 0
	Private _cIpBal  := ''
	Private _nTara   := 0.0
	Private _cIpImp  := ''
	Private _lBal    := .f.
	Private nResp    := 0

	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL24 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .T.
	endif

	//Define o tamanho da tela
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

	//Interface inicial de parametros da rotina
	while _lOk

		VTClear()
		VTClearBuffer()

		_cCorte:= Space(6)
		_cApont:= Space(1)

		@ 01,05 VTSay "RENDIMENTO COSTELA"
		@ 02,05 VTSay "Parametros Iniciais:"
		@ 03,00 VTSay "                     "
		@ 04,00 VTSay "Corte:       [      ]"
		@ 05,00 VTSay "Apontamento: [ ] 1:Ent.|2:Saí."
		@ 06,00 VTSay "                     "
		@ 10,00 VTSay "ESC para Sair"

		@ 04,14 VTGet _cCorte Pict "@!" VALID iif(LEN(alltrim(_cCorte)) == 6, .T., .F.)	
		@ 05,14 VTGet _cApont Pict "@!" VALID (_cApont $ '1/2')

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,1000,1)
			exit
		EndIF

		SB1->(DbSetOrder(1))   
		if !SB1->(MsSeek(FWxfilial('SB1')+_cCorte))
			VTAlert('Corte não encontrado!','Aviso de Encerramento(02)',.T.,1000,1)
			VTClear()
			VTClearBuffer()
		endif

		if allTrim(_cApont) <> ''
			if SB1->(MsSeek(FWxfilial('SB1')+_cCorte))
				nPeso := Pesar()
				if (nPeso > 0)
					VTAlert('Peso Capt.: ' + transform(nPeso,'@E 999.99'),'Aviso',.T.,2000,1)

					RegisTab(_cCorte, _cApont, nPeso)

					nPeso    := 0.0
					_cApont  := ''
					_cCorte  := ''
				endif
			endif
		endif
	enddo

	VTClear()
	VTClearBuffer()

Return .T.

//Função auxiliar para captura de peso
Static Function Pesar()

	@ 08,00 VTSay 'Capturando Peso  '

	conectBal()
	_nPeso := newCaptura()

	if _nPeso <= 0.0
		VTAlert('Peso Invalido![' + allTrim(transform(_nPeso,'@E 999.99')) + ']','Aviso de Encerramento(03)',.T.,1500,1)
		return
	endif

return _nPeso

//função separada para capturar peso com a balança nova
Static Function newCaptura()

	Local _nTam     := getMv('SI_QTSTR')//parametro com valor total de strings de peso a serem armazenadas para tratamento
	Local aStrings  := {}
	Local aPesos    := {}
	Local nPeso 	:= 0
	Local _nMaior   := 0
	Local _nCont    := 0
	Local _cBuffer  := ""
	Local i
	Local j

	//bloco que armazena as strings que tiverem o peso estável
	for i:=1 to _nTam
		_cBuffer := ""
		@ 08,17 VTSay '(' + allTrim(STR(i)) + ')'
		nQtd 	 := oObj:Receive( @_cBuffer, 1000 )

		//removendo o ultimo caractere (K) e adicionando somente o peso no vetor de String's
		if empty(_cBuffer)
			aAdd(aStrings, STR(0))
		else
			aAdd(aStrings, StrTran(allTrim(substr(allTrim(_cBuffer), 1, LEN(allTrim(_cBuffer)) - 1)), ",", "."))
		endif
	next

	//verifica se o buffer não esta sendo retornado em branco, caso esteja reconecta na balança
	if empty(_cBuffer)
		conectBal()
	endif

	for i := 1 to LEN(aStrings)		
		if VAL(aStrings[i]) > 0 //adiciona no vetor de pesos ok somente pesos acima de zero
			aAdd(aPesos, VAL(aStrings[i]))
		endif
	next

	//bloco para tratamento de incidencias, ou seja, utiliza somente o peso que tiver mais incidencias dentro do vetor
	for i:= 1 to LEN(aPesos)
		_nCont := 0
		for j:=1 to LEN(aPesos)
			if aPesos[i] == aPesos[j]
				_nCont++
			endif
		next

		if _nCont > _nMaior
			nPeso   := aPesos[i]
			_nMaior := _nCont
		endif
	next

return nPeso

Static Function conectBal()

	//Define o IP da balança a se utilizada
	_cIpBal := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + 'COST',1))

	if empty(_cIpBal)
		vtalert('Endereço IP da balança não encontrado!')
		return
	endif

	//Se a balança já estiver conectada, disconecta...
	if _lBal
		oObj:CloseConnection()
	endif

	//conout(_cIpBal) 
	oObj  := tSocketClient():New()
	nResp := oObj:Connect( 9000, _cIpBal,1000)  //9000
	nResp := oObj:Send( 'Teste' )

	_lBal := .t.

return


Static Function RegisTab(cCorte, cApont, nPeso)
	reclock('R10', .T.)

	R10_FILIAL := FWxFilial()
	R10_CORTE  := cCorte
	R10_APONTA := cApont
	R10_DATA   := Date()
	R10_HORA   := TIME()
	R10_PESO   := nPeso
	R10_USUAR  := cUserName

	msunlock()
return 
