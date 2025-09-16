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
±±ºPrograma  ³MLR43   º Autor ³ Mauricio Roehrsº Data ³  23/05/2015		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de controle de automação das linhas de porcionados   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAPCP                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function Lin00()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	private oFont     := tFont():New("courier new",,-36,,.t.,,,,)
	private oFont2    := tFont():New("courier new",,-24,,.t.,,,,)
	private oFont3    := tFont():New("courier new",,-24,,,,,,)
	Private oCod1     := ''
	Private oCod2     := ''
	Private oDescri1  := ''
	Private oDescri2  := ''
	Private oPB1      := ''
	Private oPB2      := ''
	Private oTa1      := ''
	Private oTa2      := ''
	Private oPL1      := ''
	Private oPL2      := ''
	Private oM11  	  := ''
	Private oM21  	  := ''
	Private oMens1_2  := ''
	Private oMens2_2  := ''
	Private oString1  := ''
	Private oString2  := ''
	Private nHdll     := 0
	Private _nID01    := 0
	Private _nID02    := 0

	//RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "ACD" //TABLES "SA1", "SB1"
	//aTables := {'ZAJ','SZ2'}
	//RPCSetEnv('01','00','industria','industria',"ACD","U_lin00",aTables,,,,)



	DEFINE MSDIALOG oAut TITLE 'AUTOMAÇÃO DE PESAGEM E ETIQUETAGEM DE CAIXAS DE PA' from 000,000 To 600,800  PIXEL

	oTimerE01 := TTimer():New(02, {|| Exib1()}, oAut)  //Timer para exibição da produção da EMB01
	oTimerE02 := TTimer():New(02, {|| Exib2()}, oAut)  //Timer para exibição da produção da EMB02

	oGrupoLIN01 := tGroup():New(05, 10, 140, 390,'LINHA PORCIONADOS 01', oAut,,, .t.)

	oSayCod1     := tSay():New(015,020,{|| oCod1   },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayDesc1    := tSay():New(035,020,{|| oDescri1},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
	oSayPB1      := tSay():New(070,020,{|| oPB1    },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
	oSayTa1      := tSay():New(070,160,{|| oTa1    },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
	oSayPL1      := tSay():New(070,320,{|| oPL1    },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
	oSayM11  	 := tSay():New(095,020,{|| oM11    },oAut,,oFont2,,,,.T.,,,350,30)
	oSayM21  	 := tSay():New(095,020,{|| oM21    },oAut,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,350,30)
	oSayStr1     := tSay():New(120,020,{|| oString1},oAut,,oFont2,,,,.T.,,,350,30)

	oGrupoLIN02 := tGroup():New(150, 10, 285, 390,'LINHA PORCIONADOS 02', oAut,,, .t.)

	oSayCod2     := tSay():New(160,020,{|| oCod2   },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayDesc2    := tSay():New(180,020,{|| oDescri2},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
	oSayPB2      := tSay():New(215,002,{|| oPB2    },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
	oSayTa2      := tSay():New(215,160,{|| oTa2    },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
	oSayPL2      := tSay():New(215,302,{|| oPL2    },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)
	oSayMens1_2  := tSay():New(247,020,{|| oMens1_2},oAut,,oFont2,,,,.T.,,,350,30)
	oSayMens2_2  := tSay():New(247,020,{|| oMens2_2},oAut,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,350,30)
	oSayStr2     := tSay():New(265,020,{|| oString2},oAut,,oFont2,,,,.T.,,,350,30)

	oTimerE01:Activate()
	oTimerE02:Activate()

	ACTIVATE MSDIALOG oAut CENTERED

	RESET ENVIRONMENT

Return

//Funções para buscar último registro da tabela de logs ZAF
Static Function Exib1()
	//4º Verificar se existe previsão de produção do produto
	_cQuery1 := " SELECT ZAF_ID,ZAF_PROD, ZAF_PESOB, ZAF_TARA, ZAF_STRING, ZAF_DESC, ZAF_STATUS "
	_cQuery1 += " FROM " + RetSqlTab("ZAF")
	_cQuery1 += " WHERE ZAF_ID = (SELECT MAX(ZAF_ID)"
	_cQuery1 += " FROM " + RetSqlTab("ZAF")
	_cQuery1 += " WHERE " + RetSQLFil("ZAF")
	_cQuery1 += " AND ZAF_DATA = '" + DTOS(date()) + "'"
	_cQuery1 += " AND " + RetSQLDel("ZAF") + ")"

	_cQuery1 := ChangeQuery(_cQuery1)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("VER1")<>0
		VER1->(dbCloseArea())
	Endif

	TCQUERY _cQuery1 NEW ALIAS "VER1"

	if VER1->ZAF_ID <> _nID01
		_nID01 := VER1->ZAF_ID
		oCod1    := VER1->ZAF_PROD
		oDescri1 := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1') + oCod1,1)
		oPB1     := transform(VER1->ZAF_PESOB,'@E 999.99')
		oTa1     := transform(VER1->ZAF_TARA,'@E 9.999')
		oPL1     := transform(VER1->(ZAF_PESOB - ZAF_TARA),'@E 999.99')

		if VER1->ZAF_STATUS = 'OK'
			oM11 := alltrim(VER1->ZAF_DESC)
			oM21 := ''
		else
			oM11 := ''
			oM21 := alltrim(VER1->ZAF_DESC)
		endif
		oString1 := alltrim(VER1->ZAF_STRING)

		oSayCod1:SetText(oCod1)
		oSayDesc1:SetText(oDescri1)
		oSayPB1:SetText(oPB1)
		oSayTa1:SetText(oTa1)
		oSayPL1:SetText(oPL1)
		oSayM11:SetText(oM11)
		oSayM21:SetText(oM21)
		oSayStr1:SetText(oString1)
		oAut:refresh()
	endif
Return

Static Function Exib2()
	//4º Verificar se existe previsão de produção do produto
	_cQuery2 := " SELECT ZAF_ID,ZAF_PROD, ZAF_PESOB, ZAF_TARA, ZAF_STRING, ZAF_DESC, ZAF_STATUS "
	_cQuery2 += " FROM " + RetSqlTab("ZAF")
	_cQuery2 += " WHERE ZAF_ID = (SELECT MAX(ZAF_ID)"
	_cQuery2 += " FROM " + RetSqlTab("ZAF")
	_cQuery2 += " WHERE " + RetSQLFil("ZAF")
	_cQuery2 += " AND ZAF_DATA = '" + DTOS(date()) + "'"
	_cQuery2 += " AND " + RetSQLDel("ZAF") + ")"

	_cQuery2 := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("VER2")<>0
		VER2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "VER2"

	if VER2->ZAF_ID <> _nID02

		_nID02 := VER2->ZAF_ID
		oCod2    := VER2->ZAF_PROD
		oDescri2 := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1') + oCod2,1)
		oPB2     := transform(VER2->ZAF_PESOB,'@E 999.99')
		oTa2     := transform(VER2->ZAF_TARA,'@E 9.999')
		oPL2     := transform(VER2->(ZAF_PESOB - ZAF_TARA),'@E 999.99')

		if VER2->ZAF_STATUS = 'OK'
			oMens1_2 := alltrim(VER2->ZAF_DESC)
			oMens2_2 := ''
		else
			oMens1_2 := ''
			oMens2_2 := alltrim(VER2->ZAF_DESC)
		endif
		oString2 := alltrim(VER2->ZAF_STRING)

		oSayCod2:SetText(oCod2)
		oSayDesc2:SetText(oDescri2)
		oSayPB2:SetText(oPB2)
		oSayTa2:SetText(oTa2)
		oSayPL2:SetText(oPL2)
		oSayMens1_2:SetText(oMens1_2)
		oSayMens2_2:SetText(oMens2_2)
		oSayStr2:SetText(oString2)
		oAut:refresh()
	endif
Return

//////////////////////////////////////////////////////////
////////////////Funções para JOB /////////////////////////
//////////////////////////////////////////////////////////

//Função que vai fazer a pesagem das caixas via conexão socket (ethernet)
Static Function CaptIP()
	local _cString  := ''

	nQtd := oObj:Receive(_cString,500)

return _cString

//Função que acessa os parametros de rejeite
Static Function Rej(_lin)

	do case
		case _lin = '002'

		PutMV('SI_REJ03',.T.)

		case _lin = '004'

		PutMV('SI_REJ04',.T.)

	endcase

return

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
	Local _cModo  := iif(_lin = '002',GetMV('SI_MODLIN2'),GetMV('SI_MODLIN4'))
	//Local _cIpImp := ''

	if _lin = '002'
		_cIpImp1 := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'ILIN2',1))

	elseif _lin = '004'
		
		/*
		Se parâmtro SI_MODLIN4 estiver com 1 (1 = Automacao ) , então sistema identifica estação "ILIN5"
		Criado dia 18/06/21 - validar e colocar para rodar
		
		if alltrim(SI_MODLIN4) = '1'
			_cIpImp2 := alltrim(GetAdvFVal('ZAM',1,FWxfilial('ZAM')+'ILIN5','ZAM_IP'))
		Elseif alltrim(SI_MODLIN4) = '2'
			_cIpImp2 := alltrim(GetAdvFVal('ZAM',1,FWxfilial('ZAM')+'ILIN4','ZAM_IP'))
		endif

		*/
		_cIpImp2 := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'ILIN4',1))
	endif

	_cIpImpBkP := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'BKPOR',1))
	
	ZAS->(DbSetOrder(1))
	if ZAS->(MsSeek(FWxfilial('ZAS')+_cControl))
		_dDataAtu := ZAS->ZAS_DTPROD
		if _lin = '002'
		
			If ZAS->ZAS_TIPO = 'MP'
				u_GJF111i('S600','IP',_cIpImp1,_cControl,_hora)
			Else			
				if _cModo = '1'
					u_GJF111k("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,date()+ZAS->ZAS_VALID,1,ZAS->ZAS_LOTE,_cIpImp1,ZAS->ZAS_HORA)
				else
					u_GJF111O("S600" ,"IP"  ,ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImp1,ZAS->ZAS_HORA)
				endif
			EndIf
			
		elseif _lin = '004'
		
			If ZAS->ZAS_TIPO = 'MP'
				u_GJF111i('S600','IP',_cIpImp2,_cControl,_hora)
			Else
				if _cModo = '1'
					//. de alguma forma identificar os códigos 021900 , 022363 , 021902 , 021908 para impressão das etiquetas no modelo espanhol
					//u_GJF111j("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImp2,ZAS->ZAS_HORA)
					// de alguma forma identificar os códigos 021900 , 022363 , 021902 , 021908 para impressão das etiquetas no modelo Uruguay
					if ZAS->ZAS_COD = '021900' .or. ZAS->ZAS_COD = '022363' .or. ZAS->ZAS_COD = '021902' .or. ZAS->ZAS_COD = '021908' .or. ZAS->ZAS_COD = '022473'
						u_GJF111v("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImp2,ZAS->ZAS_HORA)		
					else
						u_GJF111j("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImp2,ZAS->ZAS_HORA)		
					endif
					//u_GJF111j("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImp2,ZAS->ZAS_HORA)

				else
					u_GJF111O("S600" ,"IP" ,ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImpBkP,ZAS->ZAS_HORA)
					//u_GJF111O("S600" ,"IP"  ,ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,(_dDataAtu+ZAS->ZAS_VALID),1,ZAS->ZAS_LOTE,_cIpImp2)
					//u_GJF111l("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_DTPROD,date()+ZAS->ZAS_VALID,1,ZAS->ZAS_LOTE,_cIpImpBkP)
				endif
			EndIf	
		endif
	endif
	

return .t.

//Faz a verificação de previsão
static function prev(_lin)

	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+_lin))

		if ZAU->ZAU_STATT == 'E'

			_me1 := 'Produção já atendida!(01)'
			_me2 := 'Atencão!'//'Rejeite acionado'
			//rej(_lin)
			RegEv(_me1,'FA',_me2,1,_cStrBal,_cCodPro,_lin,0,0)

			sleep(_nTime)
			//return .f.
		endif

	endif

return .t.

//Função realiza o registro da produção
//na tabela ZAS e demais tabelas
Static Function Registro(_lin)
//	Local _cNumBal
	Local _nDiasVal
	Local _cDesc
//	Local _cClassif

	//Setar o cadastro do produto
	SB1->(DbSetOrder(1))
	if SB1->(MsSeek(FWxfilial('SB1')+_cCodPro))

		_nDiasVal  := SB1->B1_VALID
		_cDesc     := SB1->B1_DESCRED
		_nQuant 	  := SB1->B1_QCAIX

		_cID :=  GetSx8num('SZ8','Z8_ID')
		ConfirmSx8()

		//Setar a previsão de produção novamente
		ZAU->(DbSetOrder(4))
		if ZAU->(MsSeek(FWxfilial('ZAU')+_lin))

			//Bloco para pegar os dados de previsao de embalagem e previsao de desossa
			_cPreEmb := ''
			ZAR->(DbSetOrder(4))
			ZAR->(DbGoTop())
			if ZAR->(MsSeek(FWxFilial('ZAR') + ZAU->ZAU_NUM))
				_cPreEmb := ZAR->ZAR_PREEMB

				_cPreDes := ''
				SZU->(DbSetOrder(2))
				SZU->(DbGoTop())
				if SZU->(MsSeek(FWxFilial('SZU') + _cPreEmb))
					_cPreDes	:= SZU->ZU_PREDES
				endif

			endif

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
			ZAS->ZAS_TIPO    := iif(ZAU->ZAU_TIPOPR = 'MP','MP','PA')
			ZAS->ZAS_TERC    := 'N'
			ZAS->ZAS_PREEMB  := _cPreEmb
			ZAS->ZAS_PREDES  := iif(ZAU->ZAU_TIPOPR = 'MP','',_cPreDes)
			ZAS->ZAS_LIN 	  := _lin
			ZAS->ZAS_HORA     := time()
			if SB1->B1_PESFIX <> 0
				ZAS->ZAS_PESFIX := SB1->B1_PESFIX
			endif
			msunlock()

			u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Produção Caixas Porcionados", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

			reclock('ZAU',.f.)
			ZAU->ZAU_QRCAIX++
			ZAU->ZAU_QRPESO  += _nPesoL
			ZAU->ZAU_QRUNI   += _nQuant
			msunlock()

			//grava o histórico da caixa
			u_gjf17his(1,'PRODUCAO PORCIONADOS',.f.,'','','000012', _cControl)
		endif

	endif

return .t.

//Função destinada a executar o processo
//Captura do codigo, pesagem, atualização da previsão e
//registro de produção

Static Function PrLIN(_lin)

	_cString := ''

	//Limpeza das variáveis principais
	_cCodPro  := ''
	_cControl := ''
	_nQuant   := 0
	_nPMPec   := 0.00
	_nPeso    := 0.00
	_nPesoL   := 0.00
	_nTara    := 0.00
	_cStrBal  := ''
	_cFim     := ''

	//Captura peso e código
	_cString := CaptIP()

	//Para armazenar o string coletado sem tratamento
	_cStrBal := _cString

	//Verifica se houve leitura de peso da caixa
	//na função leitura() tratando a string já
	//validada com os dados do codigo do produto
	//e retirando o valor numerico do peso

	if empty(_cString)
		return .f.
	else

		if _lin = '002'
			_nPeso := val(substr(_cString,5,6))
		elseif _lin = '004'
			_nPeso := val(substr(_cString,5,6))
		endif

		_cLimpa   := ''

		//Se peso zerado exclui a leitura do codigo
		//do produto invalidando a pesagem
		if _nPeso <= 0

			_me1 := 'Peso Inexistente!(02)'
			_me2 := 'Rejeite acionado'
			rej(_lin)

			RegEv(_me1,'FA',_me2,2,_cStrBal,_cCodPro,_lin,0,0)

			_cLimpa := CaptIP()

			sleep(_nTime)
			return .f.

		else

			ZAU->(dbGoTop())
			ZAU->(DbSetOrder(4))
			if !ZAU->(MsSeek(FWxFilial('ZAU')+_lin))
				_me1 := 'Produção inexistente!(03)'
				_me2 := 'Rejeite acionado'
				rej(_lin)
				RegEv(_me1,'FA',_me2,3,_cStrBal,_cCodPro,_lin,0,0)

				_cLimpa := CaptIP()

				sleep(_nTime)
				return .f.
			else

				_cCodPro := ZAU->ZAU_COD

				SB1->(DbSetOrder(1))
				if !SB1->(MsSeek(FWxfilial('SB1')+_cCodPro))
					//Se entrou nessa condição é porque houve falha
					//então o rejeite deve ser acionado pois a caixa
					//já passou
					_me1 := 'Não há produção para este produto!(04)'
					_me2 := 'Rejeite acionado'
					rej(_lin)
					RegEv(_me1,'FA',_me2,4,_cStrBal,_cCodPro,_emb,0,0)
					sleep(_nTime)

					return .f.
				endif

				_nPesMax := GetMV('SI_PESMAX')

				if _nPeso > _nPesMax
					_me1 := 'Excesso de Peso ('+_nPesMax+'kg)!(01)'
					_me2 := 'Rejeite acionado'
					rej(_lin)
					RegEv(_me1,'FA',_me2,6,_cStrBal,_cCodPro,_lin,_nPeso,_nTara)
					sleep(_nTime)
					return .f.
				endif

				_nQuant := SB1->B1_QCAIX
				_nPMPec := SB1->B1_PMPEC       												 //Busca o peso médio por peças
				_nTaraS := SB1->B1_CTARASE     												 //Linhas inseridas para buscar
				_nTS    := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTaraS),1)  // os campos de codigo das taras secundaria

				_nTaraP := SB1->B1_CTARAP     												 // Linhas inseridas para buscar"_NTARAp"
				_nTP    := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTaraP),1)  // os campos de codigo das taras primarias
				_nTara  := _nTS + (_nTP * _nQuant)

				_nPesoL := _nPeso - _nTara

				//Linha para determinar a quantidade de peças por caixa conforme o peso médio de peças
				//Se o campo B1_PMPEC (Cadastro de produtos - pasta Silva) estiver preenchido, faz o calculo
				_nQuant := iif(_nPMPec <> 0.00,round(_nPesoL/_nPMPec,0),_nQuant)

				if _nPesoL <= 0
					_me1 := 'Peso Inconsistente por tara!(06)'
					_me2 := 'Rejeite acionado'
					rej(_lin)
					RegEv(_me1,'FA',_me2,6,_cStrBal,_cCodPro,_lin,_nPeso,_nTara)
					sleep(_nTime)
					return .f.
				endif

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

				//verifica se não for do grupo de moida cai fora
				//_cGrupo := SB1->B1_GRUPO

				//Bloco para validar o peso capturado com a tara da embalagem
				do case
					//Caixa pequena 18 Tubetes
					case (_nTS >= 0.01 .and. _nTS <= 0.26)
						if !(_nPesoL >= SB1->B1_PESMAX .and. _nPesoL <= SB1->B1_PESMAX)
							_me1 := 'Peso Inconsistente por tara!(13)'
							_me2 := 'Rejeite acionado'
							rej(_lin)
							RegEv(_me1,'FA',_me2,13,_cStrBal,_cCodPro,_lin,_nPeso,_nTara)
							sleep(_nTime)
							return .f.
						endif

					case (_nTS >= 0.200 .and. _nTS <= 0.790)
						if !(_nPesoL >= SB1->B1_PESOMIN .and. _nPesoL <= SB1->B1_PESMAX)
							_me1 := 'Peso Inconsistente por tara!(09)'
							_me2 := 'Rejeite acionado'
							rej(_lin)
							RegEv(_me1,'FA',_me2,9,_cStrBal,_cCodPro,_lin,_nPeso,_nTara)
							sleep(_nTime)
							return .f.
						endif
					//Caixa grande
					case (_nTS >= 0.800 .and. _nTS <= 1.100)
						if !(_nPesoL >= SB1->B1_PESOMIN .and. _nPesoL <= SB1->B1_PESMAX) //anteriormente era 12kgs o minimo //Lucas e Henrique alteraram _nPesoL >= de 8 p/ 4
							_me1 := 'Peso Inconsistente por tara!(10)'
							_me2 := 'Rejeite acionado'
							rej(_lin)
							RegEv(_me1,'FA',_me2,10,_cStrBal,_cCodPro,_lin,_nPeso,_nTara)
							sleep(_nTime)
							return .f.
						endif
					//Caixa plástica
					case (_nTS >= 1.900 .and. _nTS <= 2.355)
						if !(_nPesoL >= SB1->B1_PESOMIN .and. _nPesoL <= SB1->B1_PESMAX) //dia 29/09/17 lucineia disse para por peso minimo de 5kg para caixas brancas
							_me1 := 'Peso Inconsistente por tara!(11)'
							_me2 := 'Rejeite acionado'
							rej(_lin)
							RegEv(_me1,'FA',_me2,11,_cStrBal,_cCodPro,_lin,_nPeso,_nTara)
							sleep(_nTime)
							return .f.
						endif
					//Caso não haja nenhuma situação prevista de tara
					otherwise
						_me1 := 'Tara desconhecida!(12)'
						_me2 := 'Rejeite acionado'
						rej(_lin)
						RegEv(_me1,'FA',_me2,12,_cStrBal,_cCodPro,_lin,0,0)
						sleep(_nTime)
						return .f.
				endcase
				//Fim do bloco de validação do peso pela tara das embalagem

				if Prev(_lin)     //Função que verifica e atualiza a Previsão de Produção

					Registro(_lin)//Função que realiza o registro da pesagem

					Etq(_lin)     //função que realiza a impressão da etiqueta

					RegEv('Registro efetivado','OK','Etiqueta enviada',0,_cStrBal,_cCodPro,_lin,_nPeso,_nTara)
				endif

				ZAF->(DbGotop())

				sleep(_nTime)
			endif
		endif
	endif

return .t.

///////////////////FUNÇÃO DE JOB DA LINHA Nº 1////////////////////
User Function lin01()

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
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "ACD" //TABLES "SA1", "SB1"
	//aTables := {'ZAJ','SZ2'}
	//RPCSetEnv('01','00','industria','industria',"ACD","U_lin01",aTables,,,,)

	_cIPLin01 := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'BLIN2',1))

	//Criando conexão ethernet para balança LIN01
	oObj  := tSocketClient():New()
	nResp := oObj:Connect(1703, _cIPLin01, 1000 )
	nResp := oObj:Send( 'Teste' )
	_cString := CaptIP()

	while .t.
		PrLIN('002')
	enddo

	RESET ENVIRONMENT

Return

///////////////////FUNÇÃO DE JOB DA LINHA Nº 2////////////////////
User Function lin02()

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
	Private _cGrpMoi  := ''

	//RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "ACD" //TABLES "SA1", "SB1"
	//aTables := {'ZAJ','SZ2'}
	//RPCSetEnv('01','00','industria','industria',"ACD","U_lin02",aTables,,,,)

	_cGrpMoi  := getMv('SI_GRPMOI')

	_cIPLin02 := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'BLIN4',1))

	//Criando conexão ethernet para balança LIN02
	oObj  := tSocketClient():New()
	nResp := oObj:Connect(1704, _cIPLin02, 1000 ) //era 1702
	nResp := oObj:Send( 'Teste' )
	_cString := CaptIP()

	while .t.
		PrLIN('004')
	enddo

	RESET ENVIRONMENT

Return
