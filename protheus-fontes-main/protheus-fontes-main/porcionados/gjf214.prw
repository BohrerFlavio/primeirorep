#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF214    º Autor ³ Giuliano Forgiariniº Data ³  16/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta e controle de caixas de matéria-prima para a      º±±
±±º          ³ industria de porcionados                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP Porcionados                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF214()          

	Private _lExist := .f.
	Private _cMotivo:= space(20)
	Private  _cMemo := ""
	Private  _cGet1 := space(14)
	Private _aItems := {'Testeira','Pre-etiqueta'}
	Private _oFont  := tFont():New("courier new",,-14,,.t.,,,,)
	Private _Usr    := RetCodUsr()

	DEFINE DIALOG oDlg TITLE "Consulta e Controle de Matéria Prima Industria de Porcionados" FROM 180,180 TO 700,800 PIXEL

	_oMemo := TMultiget():New(15,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg,280,185,_oFont,,,,,.T.,,,,,,.t.)

	_oSay0:= TSay():New(220,15, {|| 'Etiqueta'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_cCombo:= _aItems[1]
	_oCombo:= TComboBox():New(220, 60, {|u| If(PCount() > 0, _cCombo:= u, _cCombo)}, _aItems, 50, 20, oDlg,, {|| _oCombo:nAt},,,,.T.,,,,,,,,,'_cCombo')

	_oSay1:= TSay():New(240,15, {|| 'Codigo:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet1:= TGet():New(240,60, {|u| If(PCount() > 0, _cGet1:= u, _cGet1)}, oDlg,, 009, "@!",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet1,,,,)

	_oBtn3 := TButton():New(220, 175, "Consultar" , oDlg,{|| Pesquisa(_cGet1)},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn1 := TButton():New(220, 220, "<< Entrada", oDlg,{|| Movim('E')      },40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn2 := TButton():New(220, 265, "Saida >>"  , oDlg,{|| Movim('S')      },40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn6 := TButton():New(240, 175, "Reimprimir", oDlg,{|| ReimpZAS()      },40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn5 := TButton():New(240, 220, "Excluir"   , oDlg,{|| Exclui()        },40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn4 := TButton():New(240, 265, "Fechar"    , oDlg,{|| oDlg:end()      },40,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED

Return

//Descrição do motivo da movimentação manual
static function DescMot()                                                        //Cria a caixa de diálogo para localizar uma caixa
	Local _lOk := .f.

	_cMotivo := space(20)

	DEFINE MSDIALOG oDlg2 TITLE 'Motivo da Movimentação:' from 000,000 To 100,260 OF oMainWnd PIXEL
	@ 010,003 SAY  'Historico:' Object oSay1
	@ 010,027 GET _cMotivo PICTURE "@!"   SIZE 60,11  Object oCaixa
	@ 010,100 BMPBUTTON TYPE 1 ACTION (_lOk := .t.,odlg2:end()) Object Obtn5
	@ 025,100 BMPBUTTON TYPE 2 ACTION odlg2:end() Object Obtn6
	ACTIVATE MSDIALOG oDlg2

	_cMotivo += ' | ' + cUserName + ' ' + GetComputerName()

return _lOk

//Função para os botões de movimentação de estoque das caixas
Static Function Movim(_mov)
	_lOk := .t.
	if !_lExist
		Help(" ",1,"ERRO PROCURA",,"Caixa não encontrada!",4,1)
	else
		if _mov == 'E'
			if empty(ZAS->ZAS_DATAS) .and. empty(ZAS->ZAS_HORAS)
				Help(" ",1,"OPERAÇÃO",,"Caixa já encontra-se em estoque!",4,1)
				_lOk := .f.
			elseif  !Aviso("Confirma operação?","A reentrada desta caixa irá desvincular o empenho a uma OP!",{"Confirma","Cancela"}) == 1
				_lOk := .f.
			endif
		else
			if !empty(ZAS->ZAS_DATAS) .and. !empty(ZAS->ZAS_HORAS)
				Help(" ",1,"OPERAÇÃO",,"Caixa já encontra-se fora de estoque!",4,1)
				_lOk := .f.
			endif
		endif
		if _lOk
			if DescMot()
				reclock('ZAS',.f.)
				ZAS->ZAS_DATAS  := iif(_mov == 'E',stod(''),date())
				ZAS->ZAS_HORAS  := iif(_mov == 'E','',time())
				ZAS->ZAS_DTREEN := iif(_mov == 'E',date(),ZAS->ZAS_DTREEN)
				ZAS->ZAS_HRRENT := iif(_mov == 'E',time(),ZAS->ZAS_HRRENT)
				ZAS->ZAS_MOREEN := _cMotivo
				msunlock()

				u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Movimentação de Entrada", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

				//se for PA recalcula o realizado de peso e numero de caixas do lote
				if ZAS->ZAS_TIPO == 'PA'
					ZAR->(dbSetOrder(4))
					ZAR->(dbGoTop())
					if ZAR->(MsSeek(FWxFilial('ZAR') + ZAS->ZAS_PREPOR))//se achou a previsao de produção busca o lote
						ZAU->(dbSetOrder(1))
						ZAU->(dbGoTop())
						if ZAU->(MsSeek(FWxFilial('ZAU') + ZAR->ZAR_LOTE))
							reclock('ZAU',.f.)
							if _mov == 'E'
								ZAU->ZAU_QRPESO -= ZAS->ZAS_PESOL
								ZAU->ZAU_QRCAIX--
							elseif _mov == 'S'
								ZAU->ZAU_QRPESO += ZAS->ZAS_PESOL
								ZAU->ZAU_QRCAIX++
							endif
							msunlock()
						endif
					endif
				endif

				_oCombo:nAt := 1
				Pesquisa(ZAS->ZAS_CONTRO)
				_oGet1:SetFocus()
				oDlg:refresh()

			endif
		endif
	endif

return

//Leitura das caixas
Static Function Pesquisa(_caixa)
	if _oCombo:nAt = 1
		ZAS->(DbSetOrder(1))
	else
		ZAS->(DbSetOrder(10))
		_caixa := substr(_caixa,1,2) + '000' + substr(_caixa,6,9)
	endif

	ZAS->(DbGoTop())

	If !ZAS->(MsSeek(FWxfilial('ZAS')+alltrim(_caixa)))
		_cMemo := 'Caixa não encontrada!'
		_lExist := .f.
	else

		_lExist := .t.

		if empty(ZAS->ZAS_DATAS) .and. empty(ZAS->ZAS_HORAS)
			_cMemo :=  padc('[ C A I X A   E M   E S T O Q U E ]',280,' ')	+ chr(13) + chr(10)
		else
			_cMemo :=  padc('[ CAIXA COM SAIDA DE ESTOQUE EM ' + DTOC(ZAS->ZAS_DATAS) + ' ÀS ' +  ZAS->ZAS_HORAS+ ' ]',280,'')	+ chr(13) + chr(10)
		endif

		if !empty(ZAS->ZAS_DTREEN)
			_cMemo +=  padc('[ REENTRADA EM ESTOQUE EM ' + DTOC(ZAS->ZAS_DTREEN) + ' ÀS ' +  ZAS->ZAS_HRRENT+ ' ]',280,'')	+ chr(13) + chr(10)
			_cMemo +=  padc('[ Motivo: ' + ZAS->ZAS_MOREEN + ' ]',280,'')	+ chr(13) + chr(10)
		endif

		_dVenc := iif(empty(ZAS->ZAS_DTABAT), ZAS->(ZAS_DTPROD + ZAS_VALID), ZAS->(ZAS_DTABAT + ZAS_VALID))
		//_dVenc := ZAS->(ZAS_DTPROD + ZAS_VALID)

		_cMemo += Replicate("=",65) + chr(13) + chr(10)
		_cMemo += "Caixa Nr.: " + ZAS->ZAS_CONTRO + chr(13) + chr(10)
		_cMemo += Replicate("=",65) + chr(13) + chr(10)
		_cMemo += "Codigo:        " + ZAS->ZAS_COD + chr(13) + chr(10)
		_cMemo += "Descrição:     " + ZAS->ZAS_DESC + chr(13) + chr(10)
		_cMemo += "Tipo:          " + iif(ZAS->ZAS_TIPO =='MP','MP (Matéria Prima)',;
			iif(ZAS->ZAS_TIPO =='PP','PP (Carne Refilada)',;
			iif(ZAS->ZAS_TIPO =='QR','QR (Quebra Refile)',;
			iif(ZAS->ZAS_TIPO =='QF','QF (Quebra Fatiadoras)',''))))  + chr(13) + chr(10)
		_cMemo += "Procedencia:   " + iif(ZAS->ZAS_TERC = 'S','Terceiro','Propria') + chr(13) + chr(10)
		_cMemo += Replicate("=",65) + chr(13) + chr(10)
		_cMemo += "Peso Bruto:    " + transform(ZAS->ZAS_PESOB,"@E 999.99") + chr(13) + chr(10)
		_cMemo += "Tara:          " + transform(ZAS->ZAS_TARA,"@E 999.99") + chr(13) + chr(10)
		_cMemo += "Peso Liquido:  " + transform(ZAS->ZAS_PESOL,"@E 999.99") + chr(13) + chr(10)
		_cMemo += Replicate("=",65) + chr(13) + chr(10)
		_cMemo += "Data Produção: " + iif(empty(ZAS->ZAS_DTABAT),dtoc(ZAS->ZAS_DTPROD),dtoc(ZAS->ZAS_DTABAT)) + chr(13) + chr(10)
		_cMemo += "Data Validade: " + dtoc(_dVenc) + " (Vencimento em " +  alltrim(str(_dVenc - date())) + " dias)" + chr(13) + chr(10)
		_cMemo += Replicate("=",65) + chr(13) + chr(10)
		_cMemo += "Pallet:        " + ZAS->ZAS_PALLET + chr(13) + chr(10)
		_cMemo += "Localização:   " + transform(ZAS->ZAS_LOCALIZ,"@R !!.!!.!!.!!.!!") + chr(13) + chr(10)

		if !empty(ZAS->ZAS_PREPOR)
			_cMemo += Replicate("=",65) + chr(13) + chr(10)
			_cMemo += "Empenhada na Ordem de Produção de Nr.: " + ZAS->ZAS_PREPOR + chr(13) + chr(10)
			ZAR->(DbSetOrder(1))
			if ZAR->(MsSeek(FWxfilial('ZAR')+ZAS->ZAS_PREPOR))
				_cMemo += ZAR->ZAR_DESC + chr(13) + chr(10)
				_cMemo += "Data Geração: " + dtoc(ZAR->ZAR_DATA)  + chr(13) + chr(10)
			endif
		endif
		if !empty(ZAS->ZAS_PREEMB)
			_cMemo += Replicate("=",65) + chr(13) + chr(10)
			_cMemo += "Produzida na OP de desossa de Nr.: " + ZAS->ZAS_PREEMB + chr(13) + chr(10)
		endif
		_cMemo += Replicate("=",65) + chr(13) + chr(10)
	endif

	oDlg:refresh()

Return .t.

// 
Static Function ReimpZAS()

	if empty(_cGet1) .or. ZAS->(EOF())
		FWAlertWarning("Consulte a caixa antes de reimprimir!","ALERTA")
		Return
	endif

	_cEst := getComputerName()
	_cIp := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+_cEst,1))

	u_GJF111k("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_PREDES,ZAS->ZAS_DTPROD,(ZAS->ZAS_DTPROD+ZAS->ZAS_VALID),1,_cIp,ZAS->ZAS_HORA)

	u_dtilog(cFilAnt, "GJF214", "Reimpressão de etiqueta - Caixa -> " + alltrim(ZAS->ZAS_CONTRO), "R")

	FWAlertSuccess("Reimpressão realizada com sucesso!","SUCESSO")

Return 


Static Function Exclui()

	If alltrim(_Usr) = '000635' .or. alltrim(_Usr) = '000498'
		MsgAlert('Usuário sem permissão de Exclusão, contate o PCP !!', 'Exclusão indevida !!')
	Else
		if DescMot()
			//se for PA recalcula o realizado de peso e numero de caixas do lote
			if ZAS->ZAS_TIPO == 'PA'
				ZAR->(dbSetOrder(4))
				ZAR->(dbGoTop())
				if ZAR->(MsSeek(FWxFilial('ZAR') + ZAS->ZAS_PREPOR))//se achou a previsao de produção busca o lote
					ZAU->(dbSetOrder(1))
					ZAU->(dbGoTop())
					if ZAU->(MsSeek(FWxFilial('ZAU') + ZAR->ZAR_LOTE))
						reclock('ZAU',.f.)
						ZAU->ZAU_QRPESO -= ZAS->ZAS_PESOL
						ZAU->ZAU_QRCAIX--
						msunlock()
					endif
				endif
			endif

			reclock('ZAS',.f.)
			ZAS->ZAS_DATAS  := date()
			ZAS->ZAS_HORAS  := time()
			ZAS->ZAS_DTREEN := ZAS->ZAS_DTREEN
			ZAS->ZAS_HRRENT := ZAS->ZAS_HRRENT
			ZAS->ZAS_MOREEN := _cMotivo
			msunlock()

			u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Exclusão de Caixas", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

			reclock('ZAS',.f.)
			dbDelete()
			msunlock()

			_cMemo := 'Caixa Excluída!'

			_oCombo:nAt := 1
			_oGet1:SetFocus()
			oDlg:refresh()

		endif
	Endif
return
