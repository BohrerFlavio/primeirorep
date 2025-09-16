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
±±ºPrograma  ³MLR50   º Autor ³ Mauricio Roehrsº Data ³  10/07/2015		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de controle de automação das linhas de porcionados   º±±
±±º          ³ISHIDA                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAPCP                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//////////////////////////////////////////////////////////
////////////////Funções para JOB /////////////////////////
//////////////////////////////////////////////////////////

//Função que vai fazer a pesagem das caixas via conexão socket (ethernet)
Static Function CaptIP(_nTempo)
	local _cString  := ''
	local _cStr     := ''

	nQtd := oObj:Receive(_cStr,_nTempo)
	_cString += alltrim(_cStr)

return _cString

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

Static Function Etq(_lin)
	Local _cModo  := iif(_lin = '001',GetMV('SI_MODISH1'),GetMV('SI_MODISH2'))
	//Local _cIpImp := ''

	if _lin = '001'
		_cIpImp1 := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'IISH1',1))
	elseif _lin = '003'
		_cIpImp2 := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'IISH2',1))
	endif

	_cIpImpBkP := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'BKPO2',1))

	ZAS->(DbSetOrder(1))
	if ZAS->(MsSeek(FWxfilial('ZAS')+_cControl))
		_dDataAtu := ZAS->ZAS_DTPROD
		if _lin = '001'
			if _cModo = '1'//se for modo automação
				u_GJF111m("S600" ,"IP"  ,ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImp1)
			else//senão é manual
				u_GJF111O("S600" ,"IP"  ,ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImp1,ZAS->ZAS_HORA)

				//u_GJF111O("S600" ,"IP"  ,ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImp1)
			endif
		elseif _lin = '003'
			if _cModo = '1'//se for modo automação
				u_GJF111m("S600" ,"IP"  ,ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImp2)
			else//senão é manual
				u_GJF111O("S600" ,"IP"  ,ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImp2,ZAS->ZAS_HORA)

				//u_GJF111O("S600" ,"IP"  ,ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImp2)
			endif
		endif
	endif

return .t.

//Faz a verificação de previsão
Static Function Prev(_lin)
	Local _lRet := .t.

	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+_lin))

		if ZAU->ZAU_STATT == 'E'

			_me1 := 'Produção já atendida!(03)'
			_me2 := 'Rejeite acionado'
			RegEv(_me1,'FA',_me2,3,_cStrBal,_cCodPro,_lin,0,0)
			//sleep(_nTime)
			_lRet := .f.

			u_gjf111L('S600','IP',_ip,_lin,_cLote,_me1)
			conout("Rotina MLR50 - Linha 121" + " IP: "+ _ip + " Linha: "+ _lin + " Lote: "+ _cLote +  " Mensagem: "+ _me1)
		endif
	endif

return _lRet

//Função realiza o registro da produção
//na tabela SZ8 e demais tabelas
Static Function Registro(_lin)
	//Local _cNumBal
	Local _nDiasVal
	Local _cDesc
	//Local _cClassif

	//Setar a previsão de produção
	ZAU->(DbSetOrder(4))
	if !ZAU->(MsSeek(FWxfilial('SZU')+_lin))
		return .f.
	endif

	//Setar o cadastro do produto
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	if !SB1->(MsSeek(FWxfilial('SB1')+_cCodPro))
		return .f.
	endif

	_nDiasVal  := SB1->B1_VALID
	_cDesc     := SB1->B1_DESCRED

	//Bloco para pegar os dados de previsao de embalagem e previsao de desossa
	_cPreEmb := ''
	_cPreDes := ''
	ZAR->(DbSetOrder(4))
	ZAR->(DbGoTop())
	if ZAR->(MsSeek(FWxFilial('ZAR') + ZAU->ZAU_NUM))
		_cPreEmb := ZAR->ZAR_PREEMB

		SZU->(DbSetOrder(2))
		SZU->(DbGoTop())
		if SZU->(MsSeek(FWxFilial('SZU') + _cPreEmb))
			_cPreDes	:= SZU->ZU_PREDES
		endif

	endif

	_cID :=  GetSx8num('SZ8','Z8_ID')
	ConfirmSx8()

	_cControl := '00' + _cID

	reclock('ZAS',.t.)
	ZAS->ZAS_FILIAL  := FWxfilial('ZAS')
	ZAS->ZAS_CONTRO  := _cControl
	ZAS->ZAS_COD     := _cCodPro
	ZAS->ZAS_DESC    := _cDesc
	ZAS->ZAS_DTPROD  := ZAU->ZAU_DTPROD
	ZAS->ZAS_VALID   := _nDiasVal
	ZAS->ZAS_PESOL   := _nPesoL
	ZAS->ZAS_PESOB   := _nPeso
	ZAS->ZAS_TARA    := _nTara
	ZAS->ZAS_LOTE    := ZAU->ZAU_NUM
	ZAS->ZAS_BATEL   := ZAU->ZAU_BATEL
	ZAS->ZAS_TIPO    := 'PA'
	ZAS->ZAS_TERC    := 'N'
	ZAS->ZAS_PREEMB  := _cPreEmb
	ZAS->ZAS_PREDES  := _cPreDes
	ZAS->ZAS_LIN	 := _lin
	ZAS->ZAS_HORA    := time()
	if SB1->B1_PESFIX <> 0
		ZAS->ZAS_PESFIX := SB1->B1_PESFIX
	endif
	msunlock()

	u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Produção Caixas Porcionados", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

	qRealP	 := ZAU->ZAU_QPCAIX
	qRealC    := ZAU->ZAU_QRCAIX

	reclock('ZAU',.f.)
	ZAU->ZAU_QRCAIX  := qRealC + 1
	ZAU->ZAU_QRPESO  += _nPesoL
	msunlock()

	//grava o histórico da caixa
	u_gjf17his(1,'PRODUCAO PORCIONADOS',.f.,'','','000012', _cControl)

return .t.

//Função destinada a executar o processo
//Captura do codigo, pesagem, atualização da previsão e
//registro de produção
Static Function PrLIN(_lin)

	//Limpeza das variáveis principais
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
	_cString1 := ''
	_cString2 := ''
	_cString3 := ''
	_cString4 := ''
	_cString5 := ''
	_cString6 := ''
	_cLote    := ''

	//seta os ips para imprimir a etiqueta de rejeite, caso necessario
	if _lin = '001'
		_ip := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'IISH1',1))
	elseif _lin = '003'
		_ip := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'IISH2',1))
	endif

	///////////////////////////////
	//Bloco bruxaria para validar
	//a captura do peso da balança
	//////////////////////////////

	_cString1 := CaptIP(500)

	if 'E' $ _cString1

		_cStrT := alltrim(_cString1)
		_cString2 := CaptIP(1000)
		if  !empty(_cString2)
			_cStrT += alltrim(_cString2)
			_cString3 := CaptIP(1000)

			if !empty(_cString3)
				_cStrT += alltrim(_cString3)
			endif
		endif
	endif

	_cStrT := alltrim(_cStrT)

	if !empty(_cStrT)
		//Para armazenar o string coletado sem tratamento
		_cStrBal := _cStrT

		//Para definir a posição inicial de tratamento da string
		_Char := substr(_cStrT,1,1)
		if _Char = 'E'
			_nPos := 1
		else
			_Char := substr(_cStrT,2,1)
			if _Char = 'E'
				_nPos := 2
			endif
		endif

		//Para identificar a mensagem que vem da balança
		_cMens  := substr(_cStrT,_nPos,3)

		if _cMens == 'E20' .or. _cMens == 'E21'

			_lOk := .t.

		elseif _cMens == 'E30'
			_lOk := .f.

		elseif _cMens == 'E=0'
			_lOk := .f.

		elseif _cMens == 'E10'
			_lOk := .f.
		else
			_lOk := .f.
		endif
	endif

	if _lOk

		_cTam := alltrim(substr(_cStrT, _nPos,7))

		//Verifica o tamanho do fonte
		if len(_cTam) < 6
			_lOk := .f.
		else
			if _cMens == 'E20'
				_nPeso := ( val(substr(_cStrT, _nPos + 3,4)) ) / 1000
			elseif _cMens == 'E21'
				_nPeso := ( val(substr(_cStrT, _nPos + 2,5)) ) / 1000
			endif
		endif
	endif

	///////////////////////////////
	//Fim do bloco bruxaria para
	//validar a captura do peso
	//////////////////////////////

	//Se estiver tudo OK com o peso...
	if !_lOk
		return .f.
	else

		if _nPeso <= 1
			//Falha 1
			_me1 := 'Peso inconsistente(01)'
			_me2 := 'Rejeite acionado'
			RegEv(_me1,'FA',_me2,1,_cStrBal,_cCodPro,_lin,_nPeso,_nTara)

			//função de impressão da etiqueta de rejeite
			u_gjf111L('S600','IP',_ip,_lin,_cLote,_me1)
			conout("Rotina MLR50 - Linha 333" + " IP: "+ _ip + " Linha: "+ _lin + " Lote: "+ _cLote +  " Mensagem: "+ _me1)
		else

			//Varifica se existe produção
			ZAU->(dbGoTop())
			ZAU->(DbSetOrder(4))
			if ZAU->(MsSeek(FWxFilial('ZAU')+_lin))

				_cLote := ZAU->ZAU_NUM
				//Se entrou nessa condição é porque não houve falha
				//na localização do lote para produzir

				_cCodPro := ZAU->ZAU_COD

				SB1->(DbSetOrder(1))
				SB1->(MsSeek(FWxfilial('SB1')+_cCodPro))

				_nQuant := SB1->B1_QCAIX
				_nPMPec := SB1->B1_PMPEC												     // Busca o peso médio por peças
				_nTaraS := SB1->B1_CTARASE												     // Linhas inseridas para buscar
				_nTS    := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTaraS),1)  // os campos de codigo das taras secundaria

				_nTaraP := SB1->B1_CTARAP												     // Linhas inseridas para buscar"_NTARAp"
				_nTP    := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTaraP),1)  // os campos de codigo das taras primarias
				_nTara  := _nTS + (_nTP * _nQuant)
				_nPesoL := _nPeso - _nTara

				// Inicio do bloco inserido por Daniel no dia 17/11/21 glpi: 1796 para verificar Peso(Min/Max) dos produtos moida.
				if SB1->B1_PESMAX > 0.00 .and. SB1->B1_PESOMIN > 0.00
					if !(_nPesoL >= SB1->B1_PESOMIN .and. _nPesoL <= SB1->B1_PESMAX)
						_me1 := 'Peso Liq. deve estar entre:('+transform(SB1->B1_PESOMIN,'@E 99.99')+' e '+transform(SB1->B1_PESMAX,'@E 99.99')+')(14)'
						_me2 := 'Rejeite acionado'
						rej(_lin)
						RegEv(_me1,'FA',_me2,7,_cStrBal,_cCodPro,_lin,_nPeso,_nTara)
						sleep(_nTime)
						return .f.
					endif
				endif
				// Fim d Bloco inserido por Daniel

				//Varificação da Previsão de Produção (Se o lote está OK!)
				if Prev(_lin)

					Registro(_lin)     //Função que realiza o registro da pesagem

					Etq(_lin)     //função que realiza a impressão da etiqueta

					RegEv('Registro efetivado','OK','Etiqueta enviada',0,_cStrBal,_cCodPro,_lin,_nPeso,_nTara)
				endif

				ZAF->(DbGotop())

			else
				//Falha 2
				_me1 := 'Não há produção para este produto!(02)'
				_me2 := 'Rejeite acionado'
				RegEv(_me1,'FA',_me2,2,_cStrBal,_cCodPro,_lin,0,0)

				//função de impressão da etiqueta de rejeite
				u_gjf111L('S600','IP',_ip,_lin,_cLote,_me1)
				conout("Lucas - Rotina MLR50 - Linha 406" + " IP: "+ _ip + " Linha: "+ _lin + " Lote: "+ _cLote +  " Mensagem: "+ _me1)
			endif
		endif
	endif

return .t.

///////////////////FUNÇÃO DE JOB DA LINHA Nº 1////////////////////
User Function ishida01()

	Private _cCodPro  := ''
	Private _nQuant   := 0
	Private _nPeso    := 0
	Private _nPesoL   := 0
	Private _nTara    := 0
	Private _cControl := ''
	Private nHdll     := 0
	Private _lFailCon := .f.
	Private _nTamZAF  := 0
	Private _cStrBal  := ''
	Private _nTime    := 1000   //tempo em milissegundos usado para frear o loop de produção

	//RPCSetType(3) //não consome licença
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "ACD"
	//aTables := {'ZAJ','SZ2'}
	//RPCSetEnv('01','00','industria','industria',"ACD","U_ishida01",aTables,,,,)

	_cIPLin01 := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'BISH1',1))

	//Criando conexão ethernet para balança ISHIDA1
	oObj  := tSocketClient():New()
	nResp := oObj:Connect(2001, _cIPLin01, 1000 )//1703
	nResp := oObj:Send( 'Teste' )
	_cString := CaptIP(1000)

	while .t.
		PrLIN('001')
	enddo

	RESET ENVIRONMENT

Return

///////////////////FUNÇÃO DE JOB DA LINHA Nº 2////////////////////
User Function ishida02()

	Private _cCodPro  := ''
	Private _nQuant   := 0
	Private _nPeso    := 0
	Private _nPesoL   := 0
	Private _nTara    := 0
	Private _cControl := ''
	Private nHdll     := 0
	Private _lFailCon := .f.
	Private _nTamZAF  := 0
	Private _cStrBal  := ''
	Private _nTime    := 1000   //tempo em milissegundos usado para frear o loop de produção

	//RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "ACD"
	//aTables := {'ZAJ','SZ2'}
	//RPCSetEnv('01','00','industria','industria',"ACD","U_ishida02",aTables,,,,)

	_cIPLin02 := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'BISH2',1))

	//Criando conexão ethernet para balança ISHIDA02
	oObj  := tSocketClient():New()
	nResp := oObj:Connect(2001, _cIPLin02, 1000 )
	nResp := oObj:Send( 'Teste' )
	_cString := CaptIP(1000)

	while .t.
		PrLIN('003')
	enddo

	RESET ENVIRONMENT

Return
