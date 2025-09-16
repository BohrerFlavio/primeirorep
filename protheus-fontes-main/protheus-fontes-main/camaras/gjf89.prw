#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF89     º Autor Giuliano Forgiarini    Data ³  01/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao:Controle de armazenagem de caixas. Entrada das camaras       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF89()

	Private _cDescCam := ''
	Private cCadastro := "Controle de Armazenagem de Caixas de PA"
	Private aRotina   := { {"Pesquisar","AxPesqui",0,1} ,;
	{"Movimentar  ","u_gjf88mov",0,2}}
	Private _cGrpPorc := alltrim(GetMV('MV_GRPPORC'))
	Private cUserID	  := alltrim(RetCodUsr())

	cPerg := "GJF89"

	Pergunte(cPerg,.T.)

	if empty(mv_par03)
		FWAlertError('Camara não apontada para movimentação!','ALERTA')
	endif

	dbSelectArea('SZ8')
	SZ8->(DbSetOrder(3))

	cCondicao := " Z8_DATAS = '' AND Z8_HORAS = '' AND Z8_PREPED = '' AND Z8_PRECAR = '' AND Z8_ITEM = '' " +;
	iif(mv_par04 = 1," AND Z8_LOCAL = '" + mv_par03 + "'","")

	mBrowse(6,1,22,75,'SZ8',,,,,,,,,,,,,,cCondicao)

Return

user Function gjf88mov()
	campo1 := space(02)
	campo2 := space(11)
	campo3 := space(14)
	valor1 := space(02)
	valor2 := space(11)
	valor3 := space(14)
	mens1  := space(1)
	mens2  := space(1)
	mens3  := 'Quant. Caixas:'
	_nqtdC := 0.00

	NNR->(DbSetOrder(1))
	if NNR->(MsSeek(FWxfilial('NNR') + mv_par03))
		_cDescCam := alltrim(NNR->NNR_DESCRI)
	endif

	DEFINE MSDIALOG tela FROM 0,0 TO 300,250 PIXEL TITLE "Movimentação de Caixas"
	@ 01,01 SAY "Camara:    " + _cDescCam of tela
	@ 02,01 SAY "Cod. Caixa:" of tela
	@ 03,01 SAY "Cod. Caixa Bizerba:" of tela

	oFont      := tFont():New("courier new",,-16,,.t.,,,,)
	oFont2      := tFont():New("courier new",,-14,,.t.,,,,)
	oSayDesc1  := tSay():New(60,10,{|| mens1 },tela,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,100,30)
	oSayDesc2  := tSay():New(60,10,{|| mens2 },tela,,oFont,,,,.T.,CLR_HRED,CLR_HRED,100,30)
	oSayDesc3  := tSay():New(110,10,{|| mens3 },tela,,oFont2,,,,.T.,,,100,30)

	//@ 12,40 MSGET campo1 VAR valor1 SIZE 20,10 OF tela PIXEL PICTURE "@!" F3 "NNR" VALID valor1 $ 'CA/CB/CC/CD/CE/EB/RI/RL/RM/RN/RE/RF/TA/TB/TC'
	@ 26,40 MSGET campo2 VAR valor2 SIZE 40,10 OF tela PIXEL PICTURE "@!" VALID movimento()
	@ 41,60 MSGET campo3 VAR valor3 SIZE 60,10 OF tela PIXEL PICTURE "@!" VALID movimento()//U_DTI210(valor3, mv_par03)
	@ 128,30 BUTTON botao PROMPT "Fechar" OF tela PIXEL ACTION tela:end()
	ACTIVATE MSDIALOG tela CENTERED
Return

//F
user Function gjf88bai()
	campo1 := space(11)
	valor1 := space(11)
	mens1  := space(1)
	mens2  := space(1)

	DEFINE MSDIALOG tela FROM 0,0 TO 300,250 PIXEL TITLE "Baixa de Caixas das Camaras"
	@ 02,01 SAY "Cod. Caixa:" of tela

	oFont      := tFont():New("courier new",,-16,,.t.,,,,)
	oSayDesc1  := tSay():New(60,10,{|| mens1 },tela,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,100,30)
	oSayDesc2  := tSay():New(60,10,{|| mens2 },tela,,oFont,,,,.T.,CLR_HRED,CLR_HRED,100,30)

	@ 26,40 MSGET campo1 VAR valor1 SIZE 40,10 OF tela PIXEL PICTURE "@!" VALID baixa()
	@ 128,30 BUTTON botao PROMPT "Fechar" OF tela PIXEL ACTION tela:end()
	ACTIVATE MSDIALOG tela CENTERED
Return

user Function gjf88con()
	campo1 := space(11)
	valor1 := space(11)
	mens1  := space(1)
	mens2  := space(1)
	mens3  := "Quant. Caixas:"

	DEFINE MSDIALOG tela FROM 0,0 TO 300,250 PIXEL TITLE "Consulta de Caixas"
	@ 02,01 SAY "Cod. Caixa:" of tela

	oFont      := tFont():New("courier new",,-16,,.t.,,,,)
	oSayDesc1  := tSay():New(60,10,{|| mens1 },tela,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,100,30)
	oSayDesc2  := tSay():New(60,10,{|| mens2 },tela,,oFont,,,,.T.,CLR_HRED,CLR_HRED,100,30)

	@ 26,40 MSGET campo1 VAR valor1 SIZE 40,10 OF tela PIXEL PICTURE "@!" VALID Y()
	@ 128,30 BUTTON botao PROMPT "Fechar" OF tela PIXEL ACTION tela:end()
	ACTIVATE MSDIALOG tela CENTERED
Return

//Função para movimentação entre camaras
Static Function movimento()

	Local _lSZ8 := .f.
	Local _lZAS := .f.
	Local _cControl := ""

	if empty(valor2) .and. empty(valor3)
		return .t.
	elseif !empty(valor2) .and. !empty(valor3)
		SomErr()
		mens1 := 'Caixa padrão ou bizerba.'
		mens2 := 'Utilize um campo por vez!'
		mens3 := ''
		oSayDesc1:SetText(mens1)
		oSayDesc2:SetText(mens2)
		oSayDesc3:SetText(mens3)
		tela:refresh()
		return .f.
	endif

	SZ8->(DbGoTop())
	ZAS->(DbSetOrder(1))
	ZAS->(DbGoTop())
	if !empty(valor3)
		SZ8->(DbSetOrder(28))
		if SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(valor3)))
			_lSZ8 := .T.
		else
			_cControl := U_DTI210(valor3, "")
			_cLinha   := GetAdvFVal('ZAS','ZAS_LIN',FWxFilial('ZAS') + _cControl,1)
			if !empty(_cControl)
				u_gjf17his(1,'ENTRADA ESTOQUE - ' + _cLinha,.f.,'','','000012', _cControl)
				SZ8->(DbSetOrder(3))
				_lSZ8 := SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(_cControl)))
			else
				_lSZ8 := .F.
			endif
		endif
	else
		SZ8->(DbSetOrder(3))
		_lSZ8 := SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(valor2)))
	endif

	if _lSZ8
	elseif ZAS->(MsSeek(FWxfilial('ZAS')+alltrim(valor2)))
		_lZAS := .t.
	else
		SomErr()
		mens2 := 'Caixa não encontrada!'
		mens1 := ''
		mens3 := 'Quant. Caixas:'
		oSayDesc1:SetText(mens1)
		oSayDesc2:SetText(mens2)
		oSayDesc3:SetText(mens3)
		tela:refresh()
		return .f.
	endif

	if _lZAS
		if !empty(mv_par02)
			if ZAS->ZAS_COD <> alltrim(mv_par02)
				SomErr()
				if  !msgbox('Caixa de produto diferente ao apontado nos parametros iniciais! Continua?(S/N)','PRODUTO INCONSISTENTE!','YESNO')
					return .f.
				endif
			endif
		endif
	elseif _lSZ8
		if !empty(mv_par02)
			if SZ8->Z8_COD <> alltrim(mv_par02)
				SomErr()
				if  !msgbox('Caixa de produto diferente ao apontado nos parametros iniciais! Continua?(S/N)','PRODUTO INCONSISTENTE!','YESNO')
					return .f.
				endif
			endif
		endif
	endif

	// Se a caixa for armazenada em câmaras incorretas - MP em câmara PA ou PA em câmara MP
	if _lSZ8
		if mv_par03 = '21'
			SomErr()
			FWAlertError('Produto acabado destinado a camara incorreta!','ALERTA')
			return .f.
		endif
	elseif _lZAS
		if ZAS->ZAS_TIPO = 'MP' .and. mv_par03 = '23'
			SomErr()
			FWAlertError('Matéria prima destinada a camara incorreta!','ALERTA')
			return .f.
		elseif ZAS->ZAS_TIPO = 'PA' .and. mv_par03 = '21'
			SomErr()
			FWAlertError('Produto acabado destinado a camara incorreta!','ALERTA')
			return .f.
		endif
	endif

	if _lZAS
		_cCamArm := GetAdvFVal('NNR','NNR_FARM',FWxFilial('NNR')+mv_par03,1)
		_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+ZAS->ZAS_COD,1)
	elseif _lSZ8
		_cCamArm := GetAdvFVal('NNR','NNR_FARM',FWxFilial('NNR')+mv_par03,1)
		_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+SZ8->Z8_COD,1)
	endif
	_cFarm  := GetAdvFVal('SBM','BM_FARM',FWxfilial('SBM')+_cGrupo,1)

	if _lZAS
		if alltrim(_cFarm) <> alltrim(_cCamArm) .and. !empty(mv_par03)
			SomErr()
			FWAlertError('Produto porcionado ' + iif(_cFarm = 'C', 'congelado', iif(_cFarm = 'R', 'resfriado', 'salgado')) + ' destinado a camara incorreta!','ALERTA')
			return .f.
		endif
	elseif _lSZ8
		if alltrim(_cFarm) <> alltrim(_cCamArm) .and. !empty(mv_par03)
			SomErr()
			FWAlertError('Produto ' + iif(_cFarm = 'C', 'congelado', iif(_cFarm = 'R', 'resfriado', 'salgado')) + ' destinado a camara incorreta!','ALERTA')
			return .f.
		endif
	endif

	_lLocal := .t.

	if _lZAS
		if ZAS->ZAS_LOCAL = alltrim(mv_par03)
			_lLocal := .f.
		endif
	elseif _lSZ8
		if SZ8->Z8_LOCAL = alltrim(mv_par03)
			_lLocal := .f.
		endif
	endif

	if !_lLocal
		SomErr()
		mens2 := 'Caixa já encontra-se no local apontado!'
		mens1 := ''
		mens3 := ''
		oSayDesc1:SetText(mens1)
		oSayDesc2:SetText(mens2)
		oSayDesc3:SetText(mens3)
		tela:refresh()
		return .f.
	endif

	_lFora := .f.

	if _lZAS
		if (!empty(ZAS->ZAS_DATAS) .or. !empty(ZAS->ZAS_HORAS)) .and. !(ZAS->ZAS_MOTS $ "COLETA/SEQUESTRO")
			_lFora := .t.
		endif
	elseif _lSZ8
		if (!empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS) .or. !empty(SZ8->Z8_PRECAR) .or. !empty(SZ8->Z8_PREPED) .or. !empty(SZ8->Z8_ITEM)) .and. !(SZ8->Z8_MOTBAIX $ "COLETA/SEQUESTRO")
			_lFora := .t.
		endif
	endif

	if cUserID != "000914"
		if _lFora
			SomErr()
			mens2 := 'Caixa já encontra-se fora do estoque!'
			mens1 := ''
			mens3 := ''
			oSayDesc1:SetText(mens1)
			oSayDesc2:SetText(mens2)
			oSayDesc3:SetText(mens3)

			tela:refresh()
			return .f.
		endif
	endif

	_lFilial := .t.

	if _lSZ8
		_cControl := SZ8->Z8_CONTROL
		reclock('SZ8',.f.)
		if cUserID = "000914" // Usuário "inventario"
			SZ8->Z8_DATAS := stod("")
		endif
		SZ8->Z8_LOCAL := mv_par03
		SZ8->Z8_INV   := 'X'
		msunlock()
		//u_gjf17his(1,'PROD.EMBALAGEM',.f.,'','','000006',SZ8->Z8_CONTROL,mv_par03)
	elseif _lZAS
		_cControl := ZAS->ZAS_CONTRO
		if ZAS->ZAS_TIPO = 'PA'

			_cCostPrc := getMV('SI_COSTPRC')

			_dDtAbate := GetAdvFval('ZAU','ZAU_DTABAT',FWxFilial('ZAU') + ZAS->ZAS_LOTE,1) //GetAdvFval('SZ2','Z2_DATAABT',FWxFilial('SZ2') + ZAS->ZAS_PREDES,2)

			reclock('SZ8',.t.)
			SZ8->Z8_FILORI    := cFilAnt
			SZ8->Z8_FIL       := cFilAnt
			SZ8->Z8_FILIAL    := FWxfilial('SZ8')
			SZ8->Z8_ID        := substr(ZAS->ZAS_CONTRO,3,8)
			SZ8->Z8_CONTROL   := ZAS->ZAS_CONTRO
			SZ8->Z8_CODORI    := ZAS->ZAS_COD
			SZ8->Z8_COD       := ZAS->ZAS_COD
			SZ8->Z8_DATA      := ZAS->ZAS_DTPROD
			SZ8->Z8_DATAP     := ZAS->ZAS_DTPROD
			SZ8->Z8_HORA      := ZAS->ZAS_HORA//time()
			SZ8->Z8_TIPO      := 'P'
			SZ8->Z8_TF        := 'N'
			SZ8->Z8_QUANT     := GetAdvFval('SB1','B1_QTBCAIX',FWxfilial('SB1')+ZAS->ZAS_COD,1)
			SZ8->Z8_PESO      := ZAS->ZAS_PESOL
			SZ8->Z8_TARA      := ZAS->ZAS_TARA
			SZ8->Z8_PESOBR    := ZAS->ZAS_PESOB
			SZ8->Z8_ETIQ      := 'P'
			SZ8->Z8_LOCAL     := mv_par03
			SZ8->Z8_DATAVAL   := iif(alltrim(ZAS->ZAS_COD) $ _cCostPrc,_dDtAbate + ZAS->ZAS_VALID, ZAS->ZAS_DTPROD + ZAS->ZAS_VALID) //ZAS->ZAS_DTPROD + ZAS->ZAS_VALID
			SZ8->Z8_DESCRI    := GetAdvFval('SB1','B1_DESCRED',FWxfilial('SB1')+ZAS->ZAS_COD,1)
			SZ8->Z8_DTENTES   := date()
			SZ8->Z8_LOTEPOR   := ZAS->ZAS_LOTE
			SZ8->Z8_BATEL     := ZAS->ZAS_BATEL
			SZ8->Z8_PREPORC   := ZAS->ZAS_PREPOR
			SZ8->Z8_NUMPREV   := ZAS->ZAS_PREEMB
			SZ8->Z8_PREDES    := ZAS->ZAS_PREDES
			SZ8->Z8_PESFIX    := ZAS->ZAS_PESFIX
			SZ8->Z8_ORIGEM    := 'P'
			SZ8->Z8_BALAN     := ZAS->ZAS_LIN
			SZ8->Z8_INV    	  := 'X'
			SZ8->Z8_SETPRO    := ZAS->ZAS_SETPRO
			SZ8->Z8_FARM      := ZAS->ZAS_FARM
			msunlock()

			SZW->(dbsetorder(2))
			SZW->(DbGoTop())
			if SZW->(Msseek(FWxfilial('SZW') + alltrim(ZAS->ZAS_CONTRO)))
				reclock('SZW',.f.)
				SZW->ZW_HORAS   := time()
				SZW->ZW_DATAS   := date()
				SZW->ZW_OPERA   := cUserName
				msunlock()
			endif

			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU') + SZ8->Z8_LOTEPOR))
				reclock('ZAU',.f.)
				ZAU->ZAU_QRPESF += SZ8->Z8_PESO
				ZAU->ZAU_QRCAIF++

				if ZAU->ZAU_QRPESF >= ZAU->ZAU_QPPESO
					ZAU->ZAU_STATT  := 'E'
					ZAU->ZAU_STATUS := 'E'
					ZAU->ZAU_WFW    := 'E'
				endif
				msunlock()
			endif

			reclock('ZAS',.f.)
			DbDelete()
			msunlock()

		else
			reclock('ZAS',.f.)
			ZAS->ZAS_LOCAL := mv_par03
			msunlock()
		endif

		//u_gjf17his(1,'PROD.PORCION.',.f.,'','','000006',ZAS->ZAS_CONTRO,mv_par03)
	endif

	u_gjf17his(3,'MOV.P/ CAMARA - ' + alltrim(mv_par03),.f.,'','','000002',_cControl,mv_par03)
	_nqtdC++
	mens1 := "Movimento para Camara " + mv_par03
	mens2 := ''
	mens3 := 'Quant. Caixas: ' + transform(_nqtdC,'@E 999')
	execsom()

	oSayDesc1:SetText(mens1)
	oSayDesc2:SetText(mens2)
	oSayDesc3:SetText(mens3)
	tela:refresh()

return .f.

Static Function movimebiz()

	SZ8->(DbSetOrder(28))
	SZ8->(DbGoTop())

	if empty(valor3)
		return .t.
	endif

	if SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(valor3)))
		SomErr()
		mens2 := 'Caixa já entrou em estoque'
		mens1 := ''
		mens3 := ''
		oSayDesc1:SetText(mens1)
		oSayDesc2:SetText(mens2)
		oSayDesc3:SetText(mens3)
		tela:refresh()
		return .f.
	else
		_cControl := U_DTI210(valor3, mv_par03)

		u_gjf17his(3,'MOV.P/ CAMARA - ' + alltrim(mv_par03),.f.,'','','000002',_cControl,mv_par03)
		_nqtdC++
		mens1 := "Movimento para Camara " + mv_par03
		mens2 := ''
		mens3 := 'Quant. Caixas: ' + transform(_nqtdC,'@E 999')
		execsom()

		oSayDesc1:SetText(mens1)
		oSayDesc2:SetText(mens2)
		oSayDesc3:SetText(mens3)
		tela:refresh()
	endif

return .f.

//Função de execução do som
static function execsom()                                                         //Serve para executar o som ao ler caixa ou peça
	do case
		case mv_par01 == 1
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)
		case mv_par01 == 2
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE2.WAV',0)
		case mv_par01 == 3
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE3.WAV',0)
	endcase
	//WINEXEC('C:\Siga\remote\wmplayer.exe /play /close /embedding c:\GE.WAV',0)
return

Static Function SomErr()
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
return

