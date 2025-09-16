#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF215    º Autor ³ Giuliano Forgiariniº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de recebimento, produção manual e re-iimpressão de  º±±
±±º          ³ etiquetas de caixas de matéria-prima                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Recebimento Porcionados                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF215()

	Private  _cMemo   := ""
	Private  _cGetRu  := space(02)
	Private  _cGetPr  := space(02)
	Private  _cGetAn  := space(02)
	Private  _cGetAp  := space(02)
	Private  _cGet1   := space(11)
	Private  _cGet2   := space(06)
	Private  _cGet10  := "1  "
	Private  _dGet3   := stod("")
	Private  _cGet4   := '21'
	Private  _cGet5   := space(04)
	Private _aItComb  := {}
	Private _aItComb2 := {}
	Private _cCombo1  := ''
	Private _cCombo2  := ''
	Private cPerg     := "GJF215"
	Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)
	Private _nModo    := 1
	Private _nModo2   := 2
	Private _aOpcoes  := {"Recebimento MP Própria","Produção MP Própria","Produção MP Terceiros","Re-impressão Etiqueta" }
	Private _aOpcoes2 := {"Sim","Não"}
	Private _nMaxApto := 0
	Private _cSay4    := 'Codigo Produto MP/PP:'
	Private _cSay5    := 'Peso Bruto Caixa:'
	Private _cSay6    := 'Tara Caixa: '
	Private _cSay10   := 'Qtde: '
	Private _cSay7    := 'Prod. Terc.: '
	Private _cSay8    := 'Data de'
	Private _cSay9    := 'SIF:'

	if !pergunte(cPerg,.t.)
		return
	endif

	_cSay6 += transform(mv_par01,'@E 9.999')

	//Monta vetor com os códigos dos produtos de MP para o ComboBox...
	//Somente com os produtos dos grupos 1003, 1004, 4004 e 4005

	MontaCmb()
	MontaCmb2()

	//Numero máximo de aptos por andar...
	_nMaxApto := u_gjf144NL(_cGet4)

	DEFINE DIALOG oDlg TITLE "Recebimento de Matéria Prima para Porcionados" FROM 180,180 TO 750,800 PIXEL

	_oSay0   := TSay():New(05,20, {|| "Operação:"}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oRadio  := TRadMenu():New(10,60,_aOpcoes,{|u| Iif(PCount()==0,_nModo,_nModo:=u)},oDlg,,{||Modos()},,,,,,100,12,,,,.T.)

	_oSay1   := TSay():New(05,140, {|| "Endereçamento?"}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oRadio2 := TRadMenu():New(10,200,_aOpcoes2,{|u| Iif(PCount()==0,_nModo2,_nModo2:=u)},oDlg,,{||Modos2()},,,,,,100,12,,,,.T.)

	_oSay2   := TSay():New(05,220, {|| "Local Destino: "}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet4   := TGet():New(05,280, {|u| If(PCount() > 0, _cGet4:= u, _cGet4)}, oDlg,, 009,PesqPict("NNR","NNR_CODIGO"),{||ValCam()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,"NNR", _cGet4,,,,.t.,.f.)

	_oMemo   := TMultiget():New(55,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg,280,130,_oFont,,,,,.T.,,,,,,.t.)

	_oSayRu  := TSay():New(40,160, {|| "Endereço:"}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGetRu  := TGet():New(40,200, {|u| If(PCount() > 0, _cGetRu:= u, _cGetRu)}, oDlg,, 009, "@!",{||ValRua()   }, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGetRu,,,,)
	_oGetPr  := TGet():New(40,220, {|u| If(PCount() > 0, _cGetPr:= u, _cGetPr)}, oDlg,, 009, "@!",{||ValPredio()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGetPr,,,,)
	_oGetAn  := TGet():New(40,240, {|u| If(PCount() > 0, _cGetAn:= u, _cGetAn)}, oDlg,, 009, "@!",{||ValAndar() }, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGetAn,,,,)
	_oGetAp  := TGet():New(40,260, {|u| If(PCount() > 0, _cGetAp:= u, _cGetAp)}, oDlg,, 009, "@!",{||ValApto()  }, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGetAp,,,,)

	_oSayRu:lVisibleControl:= .F.
	_oGetRu:lVisibleControl:= .F.
	_oGetPr:lVisibleControl:= .F.
	_oGetAn:lVisibleControl:= .F.
	_oGetAp:lVisibleControl:= .F.

	_oSay3   := TSay():New(220,005, {|| 'Codigo da Caixa/Pallet:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oSay4   := TSay():New(220,015, {||_cSay4}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oSay7   := TSay():New(240,015, {||_cSay7}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oSay5   := TSay():New(200,015, {||_cSay5}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oSay6   := TSay():New(200,150, {||_cSay6}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oSay10  := TSay():New(200,230, {||_cSay10}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oSay8   := TSay():New(255,015, {||_cSay8}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 100)
	_oSay9   := TSay():New(270,015, {||_cSay9}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 100)

	_oGet1   := TGet():New(220,140, {|u| If(PCount() > 0, _cGet1:= u, _cGet1)}, oDlg,, 009, "@!",{||Leitura()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet1,,,,.t.,)
	_oGet2   := TGet():New(200,100, {|u| If(PCount() > 0, _cGet2:= u, _cGet2)}, oDlg,, 009, "@E 999.99",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet2,,,,.t.,)
	_oGet10  := TGet():New(200,260, {|u| If(PCount() > 0, _cGet10:= u,_cGet10)},oDlg,, 009, "@E 999"   ,, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet10,,,,.t.,)

	_oCombo1 := TComboBox():New(220,140,{|u|if(PCount()>0,_cCombo1:=u,_cCombo1)}, _aItComb ,150,20,oDlg,,{||SetProd(_cCombo1)},,,,.T.,,,,,,,,,'_cCombo1')
	_oCombo2 := TComboBox():New(240,140,{|u|if(PCount()>0,_cCombo2:=u,_cCombo2)}, _aItComb2,150,20,oDlg,,{||SetProd2(_cCombo2)},,,,.T.,,,,,,,,,'_cCombo2')

	_oGet3   := TGet():New(255,085, {|u| If(PCount() > 0,_dGet3:=u,_dGet3)}, oDlg,, 009, "@D",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,,"_dGet3",,,,.t.,)
	_oGet5   := TGet():New(270,085, {|u| If(PCount() > 0, _cGet5:= u, _cGet5)}, oDlg,, 009, "@!",{||ValSIF()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet5,,,,.t.,)

	_oSay4:lVisibleControl   := .F.
	_oSay5:lVisibleControl   := .F.
	_oSay6:lVisibleControl   := .F.
	_oSay10:lVisibleControl  := .F.
	_oSay7:lVisibleControl   := .F.
	_oCombo1:lVisibleControl := .F.
	_oCombo2:lVisibleControl := .F.
	_oGet2:lVisibleControl   := .F.
	_oGet10:lVisibleControl  := .F.

	_oSay8:lVisibleControl   := .F.
	_oGet3:lVisibleControl   := .F.
	_oGet5:lVisibleControl   := .F.
	_oSay9:lVisibleControl   := .F.

	_oBtn1 := TButton():New(260,200, "Produzir", oDlg,{||Produzir()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn2 := TButton():New(260,260, "Sair"    , oDlg,{||oDlg:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	_oBtn1:lVisibleControl:= .F.

	ACTIVATE DIALOG oDlg CENTERED

Return

//Opções do radiobutton
Static Function Modos()

	_cGet1 := space(11)
	_cMemo := ''

	_oSayRu:lVisibleControl := .F.
	_oGetRu:lVisibleControl := .F.
	_oGetAp:lVisibleControl := .F.
	_oGetAn:lVisibleControl := .F.
	_oGetPr:lVisibleControl := .F.
	_oRadio2:lVisibleControl:= .F.
	_oSay1:lVisibleControl  := .F. //"Endereçamento"
	_oSay3:lVisibleControl  := .F. //"Codigo da Caixa/Pallet"
	_oSay4:lVisibleControl  := .F.
	_oSay5:lVisibleControl  := .F. //Peso bruto do produto
	_oSay6:lVisibleControl  := .F. //Parametro de tara
	_oSay10:lVisibleControl := .F.
	_oSay7:lVisibleControl  := .F.
	_oGet1:lVisibleControl  := .F.
	_oGet2:lVisibleControl  := .F.
	_oGet10:lVisibleControl := .F.
	_oCombo1:lVisibleControl:= .F.
	_oBtn1:lVisibleControl  := .F.

	_oSay8:lVisibleControl  := .F.
	_oGet3:lVisibleControl  := .F.
	_oGet5:lVisibleControl  := .F.
	_oSay9:lVisibleControl  := .F.

	do case
	case _nModo = 1
		//Recebimento materia-propria
		_oRadio2:lVisibleControl := .T.
		_oSay1:lVisibleControl   := .T.
		_oSay3:lVisibleControl   := .T.
		_oSay7:lVisibleControl   := .F.
		_oGet1:lVisibleControl   := .T.
		_oCombo2:lVisibleControl := .F.

		_oSay8:lVisibleControl  := .F.
		_oGet3:lVisibleControl  := .F.
		_oGet5:lVisibleControl  := .F.
		_oSay9:lVisibleControl  := .F.
		_dGet3   := stod("")
		_cGet5   := space(04)
		_oGet3:CtrlRefresh()
		_oGet5:CtrlRefresh()
	case _nModo = 2
		//Produção matéria-prima própria
		_nModo2 := 2
		Modos2()
		_oSay4:lVisibleControl  := .T.
		_oSay5:lVisibleControl  := .T.
		_oSay6:lVisibleControl  := .T.
		_oSay10:lVisibleControl := .T.

		_oSay8:lVisibleControl  := .T.
		_oGet3:lVisibleControl  := .T.
		_oGet10:lVisibleControl := .T.
		_oSay8:SetText(_cSay8 + " Abate:")

		_oGet5:lVisibleControl  := .F.
		_oSay9:lVisibleControl  := .F.
		_cGet5   := space(04)
		_oGet5:CtrlRefresh()

		_oSay7:lVisibleControl  := .F.
		_oCombo1:lVisibleControl:= .T.
		_oCombo2:lVisibleControl:= .F.
		MontaCmb()
		_oCombo1:SetItems(_aItComb)
		_oCombo2:lVisibleControl:= .F.
		_oBtn1:lVisibleControl  := .T.
		_oGet2:lVisibleControl  := .T.
	case _nModo = 3
		//Produção Matéria-prima terceiros
		_nModo2 := 2
		Modos2()
		_oCombo1:lVisibleControl:= .T.
		_oCombo2:lVisibleControl:= .T.
		MontaCmb()
		MontaCmb2()
		_oSay4:lVisibleControl  := .T.
		_oSay5:lVisibleControl  := .T.
		_oSay6:lVisibleControl  := .T.
		_oSay10:lVisibleControl := .T.
		_oSay7:lVisibleControl  := .T.
		_oCombo1:SetItems(_aItComb)
		_oCombo2:SetItems(_aItComb2)
		_oBtn1:lVisibleControl  := .T.
		_oGet2:lVisibleControl  := .T.
		_oGet10:lVisibleControl := .T.

		_oSay8:lVisibleControl  := .T.
		_oGet3:lVisibleControl  := .T.
		_oSay8:SetText(_cSay8 + " Producao:")

		_oGet5:lVisibleControl  := .T.
		_oSay9:lVisibleControl  := .T.
		_dGet3   := stod("")
		_oGet3:CtrlRefresh()

		_cGet5   := space(04)
		_oGet5:CtrlRefresh()
	case _nModo = 4
		//RE-impressão de etiquetas
		_nModo2 := 2
		_oSay3:lVisibleControl  := .T.
		_oSay7:lVisibleControl  := .F.
		_oGet1:lVisibleControl  := .T.
		_oCombo2:lVisibleControl:= .F.

		_oSay8:lVisibleControl  := .F.
		_oGet3:lVisibleControl  := .F.
		_dGet3   := stod("")
		_oGet3:CtrlRefresh()

		_oGet5:lVisibleControl  := .F.
		_oSay9:lVisibleControl  := .F.
		_cGet5   := space(04)
		_oGet5:CtrlRefresh()

		Modos2()

	endcase

	_oSayRu:CtrlRefresh()
	_oGetRu:CtrlRefresh()
	_oGetAp:CtrlRefresh()
	_oGetAn:CtrlRefresh()
	_oGetPr:CtrlRefresh()
	_oSay1:CtrlRefresh()
	_oGet1:CtrlRefresh()
	_oGet10:CtrlRefresh()
	_oGet2:CtrlRefresh()
	_oRadio2:Refresh()
	_oMemo:refresh()
	_oCombo1:refresh()
	oDlg:refresh()

return

//Se tem endereçamento ou não
Static function Modos2()

	if _nModo2 = 1
		_oSayRu:lVisibleControl:= .T.
		_oGetRu:lVisibleControl:= .T.
		_oGetAp:lVisibleControl:= .T.
		_oGetAn:lVisibleControl:= .T.
		_oGetPr:lVisibleControl:= .T.
	else
		_oSayRu:lVisibleControl:= .F.
		_oGetRu:lVisibleControl:= .F.
		_oGetAp:lVisibleControl:= .F.
		_oGetAn:lVisibleControl:= .F.
		_oGetPr:lVisibleControl:= .F.
	endif

	_cGetRu := space(02)
	_cGetPr := space(02)
	_cGetAn := space(02)
	_cGetAp := space(02)
	_cGet1  := space(11)
	_cMemo  := ''

	_oSayRu:CtrlRefresh()
	_oGetRu:CtrlRefresh()
	_oGetAp:CtrlRefresh()
	_oGetAn:CtrlRefresh()
	_oGetPr:CtrlRefresh()
	_oGet1:CtrlRefresh()
	_oMemo:refresh()

return

//Funções de validação do endereçamento
//Funcao que valida a Rua
Static Function ValRua()
	if empty(_cGetRu)
		return .f.
	endif

	ZZH->(DbSetOrder(1))
	ZZH->(DbGoTop())
	if !ZZH->(DbSeek(xfilial('ZZH') + alltrim(_cGet4) + alltrim(_cGetRu)))
		Help(" ",1,"ENDEREÇAMENTO",,"Rua inválida!",4,1)
		return .f.
	endif
return

//Funcao que valida o Predio
Static Function ValPredio()
	if empty(_cGetPr)
		return .f.
	endif

	ZZH->(DbSetOrder(1))
	ZZH->(DbGoTop())
	if !ZZH->(DbSeek(xfilial('ZZH') + alltrim(_cGet4) + alltrim(_cGetRu) + alltrim(_cGetPr)))
		Help(" ",1,"ENDEREÇAMENTO",,"Predio inválido!",4,1)
		return .f.
	endif
return

//Funcao que valida o Andar
Static Function ValAndar()
	if empty(_cGetAn)
		return .f.
	endif

	ZZH->(DbSetOrder(1))
	ZZH->(DbGoTop())
	if !ZZH->(DbSeek(xfilial('ZZH') + alltrim(_cGet4) + alltrim(_cGetRu) + alltrim(_cGetPr) + alltrim(_cGetAn)))
		Help(" ",1,"ENDEREÇAMENTO",,"Andar Inválido!",4,1)
		return .f.
	endif
return

//Funcao que valida o Apartamento
Static Function ValApto()
	if empty(_cGetAp)
		return .f.
	endif

	ZZH->(DbSetOrder(1))
	ZZH->(DbGoTop())
	if !ZZH->(DbSeek(xfilial('ZZH') + alltrim(_cGet4) +;
			alltrim(_cGetRu) +;
			alltrim(_cGetPr) +;
			alltrim(_cGetAn) +;
			alltrim(_cGetAp))) .and. _cGetAp <> '00'
		Help(" ",1,"ENDEREÇAMENTO",,"Apartamento inválido!",4,1)
		return .f.
	endif
return

//Fim das funções de validação do endereçamento

//função de som
static function execsom()                                                         //Serve para executar o som ao ler caixa ou peça

	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE3.WAV',0)

return

Static Function SomErr()
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
return

//Função de validação das leituras de caixas e pallets
Static Function Leitura()
	Local _lRet := .f.

	//Se o campo estiver em branco
	if empty(_cGet1)
		_lRet := .t.
	else

		execsom()

		//Se o tamanho do codigo for menor que 10 digitos
		if len(alltrim(_cGet1)) < 10
			SomErr()
			alert('Falha na leitura!')
			_lRet := .f.
		else

			//Se for com localização física...
			if  _nModo2 = 1

				//Monta o endereço apontado
				_DispEnd :=  alltrim(_cGet4) + alltrim(_cGetRu) + alltrim(_cGetPr) + alltrim(_cGetAn) + iif(empty(_cGetAp),'00',alltrim(_cGetAp))

				//Calcula o total de pallets por apartamento/andar
				_nPal1 := contagem("SZP","ZP_LOCALIZ = '" + alltrim(_DispEnd) + "'")
				_nPal2 := contagem("SZP","ZP_LOCALIZ LIKE '%" +substr(alltrim(_DispEnd),1,8) + "%'")

				//Se o apartamento foi apontado como '00' (ou seja, considera apenas o andar)...
				if _cGetAp == '00'
					if _nPal2 >= _nMaxApto
						SomErr()
						Help(" ",1,"ANDAR CHEIO!",,"Esta operação não é possível para Pallets!",4,1)
						return .f.
					endif

					//Se o apartamento foi devidamente apontado...
				else
					if _nPal1 >= _nMaxApto
						SomErr()
						Help(" ",1,"ANDAR CHEIO!",,"Esta operação não é possível para Pallets!",4,1)
						return .f.
					endif
				endif
			endif

			//Se for pallet...
			if substr(_cGet1,1,2) == 'MP'
				SZP->(DbSetOrder(1))
				SZP->(DbGoTop())

				//Verifica se, afinal, o bagulho existe ou não
				if !SZP->(DbSeek(xfilial('SZP')+alltrim(_cGet1)))
					SomErr()
					Help(" ",1,"ERRO!",,"Pallet não identificado!",4,1)
					return .f.
				endif

				//Verifica se o pallet não tá lá na puta que pariu...
				if SZP->ZP_FIL <> cFilAnt
					SomErr()
					Help(" ",1,"ERRO",,"Pallet em outra filial!",4,1)
					return .f.
				endif

				ZAS->(DbSetOrder(6))
				ZAS->(DbGoTop())

				if _nModo = 1
					//Depois das verificações, faz os apontamentos devidos de entrada:
					//Primeiro as caixas...
					ZAS->(DbSetOrder(6))
					if ZAS->(DbSeek(xfilial('ZAS') + alltrim(_cGet1)))
						while ZAS->(!eof()) .and. ZAS->ZAS_FILIAL = xfilial('ZAS') .and. ZAS->ZAS_PALLET = alltrim(_cGet1)

							reclock('ZAS',.f.)
							ZAS->ZAS_LOCALI := iif(_nModo2 = 1,_DispEnd,'')
							ZAS->ZAS_LOCAL  := iif(_nModo2 = 1,substr(_DispEnd,1,2),_cGet4)
							msunlock()

							u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Recebimento Pallet", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

							ZAS->(DbSkip())
						enddo
					endif

					//Depois grava a localização no pallet...
					reclock('SZP',.f.)
					SZP->ZP_LOCALIZ :=iif(_nModo2 = 1,_DispEnd,'')
					SZP->ZP_HORA    := time()
					msunlock()

				elseif _nModo = 4
					Imprime(_cGet1)
				endif

				_cMemo :=  padc('[ ENTRADA  EM  ESTOQUE  DE  PALLET ]',280,' ')	+ chr(13) + chr(10)
				_cMemo += Replicate("=",68) + chr(13) + chr(10)
				_cMemo += "Codigo:      " + SZP->ZP_COD + chr(13) + chr(10)
				_cMemo += "Produto:     " + SZP->ZP_PRODUTO + chr(13) + chr(10)
				_cMemo += "Descrição:   " + Posicione('SB1',1,xfilial('SB1') + SZP->ZP_PRODUTO,'B1_DESC') + chr(13) + chr(10)
				_cMemo += "Localização: " + transform(SZP->ZP_LOCALIZ,"@R !!.!!.!!.!!.!!") + chr(13) + chr(10)
				_cMemo += Replicate("=",68) + chr(13) + chr(10)

				_oMemo:refresh()

			Elseif _nModo = 5
				Alert('!! Rotina de Recebimento de PA Prório !!')
			else
				//Se for caixa de MP ...
				ZAS->(DbSetOrder(1))
				if !ZAS->(DbSeek(xfilial("ZAS")+alltrim(_cGet1)))
					SomErr()
					Help(" ",1,"ERRO",,"Caixa de MP não encontrada!",4,1)
				else
					//Verifica se a caixa ainda está em estoque
					if !empty(ZAS->ZAS_DATAS) .and. !empty(ZAS->ZAS_HORAS)
						SomErr()
						Help(" ",1,"NÃO PERMITIDO!",,"Caixa já encontra-se fora de estoque!",4,1)
					elseif _nModo = 1 .and. !empty(dtos(ZAS->ZAS_DTRMP)) //.and. !empty(ZAS->ZAS_LOCAL) .and. ZAS->ZAS_LOCAL == _cGet4
						SomErr()
						//Help(" ",1,"NÃO PERMITIDO!",,"Caixa já recebida neste local destino em '"+dtoc(ZAS->ZAS_DTRMP)+"'!",4,1)
					else
						if _nModo = 1
							reclock('ZAS',.f.)
							ZAS->ZAS_LOCALI := iif(_nModo2 = 1,_DispEnd,'')
							ZAS->ZAS_LOCAL  := iif(_nModo2 = 1,substr(_DispEnd,1,2),_cGet4)
							ZAS->ZAS_DTRMP  := ddatabase
							msunlock()

							u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Recebimento Caixas", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

						elseif _nModo = 4
							Imprime(_cGet1)
						endif
						/* Processo Novo Início*/
						//cGrupop := Posicione('SB1',1,xfilial('SB1') + alltrim(ZAS->ZAS_COD),' B1_GRUPO')
						_cProd := GetMV('SI_PRODRX')
						// Se for do grupo estipulado pelo André e Wilian manda imprimir
						/* Dia 14/02/22 - início da gravação da % de carne valendo, e  ajustado para que só imprima
						etiquetas compridas se estiverem cadastradas no parâmetro */
						// 12/06/23 - Willian solicitou a remoção dessa funcionalidade, visto que o Raio X foi abandonado e estão disperdiçando etiquetas
						if alltrim(ZAS->ZAS_COD) $ _cProd
							U_GJF111x(alltrim(ZAS->ZAS_CONTRO))
						endif
						_cMemo :=  padc('[ ENTRADA  EM  ESTOQUE  DE CAIXA DE MP ]',280,' ')	+ chr(13) + chr(10)
						_cMemo += Replicate("=",68) + chr(13) + chr(10)
						_cMemo += "Codigo Caixa:   " + ZAS->ZAS_CONTRO + chr(13) + chr(10)
						_cMemo += "Codigo Produto: " + ZAS->ZAS_COD + chr(13) + chr(10)
						_cMemo += "Descrição:      " + ZAS->ZAS_DESC + chr(13) + chr(10)
						_cMemo += "Data Produção:  " + dtoc(ZAS->ZAS_DTPROD) + chr(13) + chr(10)
						_cMemo += "Peso Bruto:     " + transform(ZAS->ZAS_PESOB,"@ 999.99") + chr(13) + chr(10)
						_cMemo += "Tara:           " + transform(ZAS->ZAS_TARA,"@ 9.999") + chr(13) + chr(10)
						_cMemo += "Peso Liquido:   " + transform(ZAS->ZAS_PESOL,"@ 999.99") + chr(13) + chr(10)
						_cMemo += "Origem:         " + iif(ZAS->ZAS_TERC = 'S','Terceiro','Propria') + chr(13) + chr(10)
						_cMemo += "OP Porcionado:  " + ZAS->ZAS_PREPOR + chr(13) + chr(10)
						_cMemo += "Local Destino:  " + ZAS->ZAS_LOCAL + chr(13) + chr(10)
						_cMemo += iif(_nModo2 = 1,"Endereço:       " + ZAS->ZAS_LOCALI + chr(13) + chr(10),'')
						_cMemo += Replicate("=",68) + chr(13) + chr(10)
						_oMemo:refresh()
					endif
				endif
			endif
		endif
	endif

	_cGet1 := space(11)
	_oGet1:CtrlRefresh()
return _lRet

//Função de contagem espefícia para validar campos
//do endereçamento
Static Function Contagem(_cAlias,_regra)
	Local _nCont

	cQuery := " SELECT COUNT(*) AS CONTAGEM FROM " + REtSQLTab(_cAlias)
	cQuery += " WHERE " + RetSQLFil(_cAlias) + " AND " +  _regra + " AND "  +  RetSQLDel(_cAlias)

	cQuery := ChangeQuery(cQuery)

	If Select("CON") != 0
		CON->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "CON"

	_nCont := CON->CONTAGEM

return _nCont

//Função que monta os itens da ComboBox para produção de MPs
//para as opções 2 e 3 do RadioButton
Static Function MontaCmb()

	Local _cQuery := ''
	Local _cGrupo := "'4007','4006','4008'" //iif(_nModo = 2,"'4007','4006'","'1004'")
	if _nModo <> 1
		_cQuery := " SELECT * FROM " + RetSQLTab('SB1') + " WHERE " + RetSQLFil('SB1')
		_cQuery += " AND B1_TIPO IN('MP','PP') AND B1_GRUPO IN(" + _cGrupo + ") "
		_cQuery += " AND " + RetSQLDel('SB1') + " ORDER BY B1_DESC "

		_cQuery := ChangeQuery(_cQuery)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a interface padrao com o usuario...                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If Select("CMB") != 0
			CMB->(dbCloseArea())
		Endif

		TCQUERY _cQuery NEW ALIAS "CMB"

		CMB->(DbGotop())

		_aItComb := {}

		while CMB->(!eof())
			aadd(_aItComb,alltrim(CMB->B1_COD)+'='+CMB->B1_DESC)
			CMB->(DBSkip())
		enddo

		_cCombo1  := _aItComb[1]
	endif

return

//Função que monta os itens da ComboBox para produção de MPs
//para as opção 3 do RadioButton
Static Function MontaCmb2()

	Local _cQuery := ''
	//Local _cGrupo := "'4007','4006'" //iif(_nModo = 2,"'4007','4006'","'1004'")
	if _nModo <> 1
		_cQuery := " SELECT * FROM " + RetSQLTab('SB1') + " WHERE " + RetSQLFil('SB1')
		_cQuery += " AND B1_TIPO IN('MP','PP') AND B1_GRUPO IN('1004') "
		_cQuery += " AND " + RetSQLDel('SB1') + " ORDER BY B1_DESC "

		_cQuery := ChangeQuery(_cQuery)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a interface padrao com o usuario...                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If Select("CMB") != 0
			CMB->(dbCloseArea())
		Endif

		TCQUERY _cQuery NEW ALIAS "CMB"

		CMB->(DbGotop())

		_aItComb2 := {}

		while CMB->(!eof())

			aadd(_aItComb2,alltrim(CMB->B1_COD)+'='+CMB->B1_DESC)

			CMB->(DBSkip())
		enddo

		_cCombo2  := _aItComb2[1]
	endif

return

//Aponta o produto escolhido na ComboBox para as opções de produção
// de produto (Modo 2 e 3  do RadioButton)
Static Function SetProd(cProd)

	_oSay4:SetText(_cSay4 + cProd)

return

Static Function SetProd2(cProd)

	_oSay7:SetText(_cSay7 + cProd)

return

//Função destinada a fazer a re-impressão de etiquetas
Static Function Imprime(_cCod)
	Local _produto := ''
	Local _ip 		:= ''
	_cEst := getComputerName()

	//verifica se é caixa
	if !(substr(_cCod,1,2) $ 'PA/MP')
		dbselectarea('ZAM')
		ZAM->(dbSetOrder(2))
		If ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
			_ip := alltrim(ZAM->ZAM_IP)
		Endif
		//_ip	:= alltrim(Posicione('ZAM',1,xFilial('ZAM')+'IPOR1','ZAM_IP'))
		u_GJF111i('S600','IP',_ip,_cCod,'')
	else
		_produto := alltrim(Posicione('SZP',1,xFilial('SZP')+_cCod,'ZP_PRODUTO'))
		_ip      := alltrim(Posicione('ZAM',1,xFilial('ZAM')+'IPAL1','ZAM_IP'))
		u_GJF111d('S600','IP',_cCod,_produto,_ip)
	endif

return

//Função destinada a produção de MP
Static Function Produzir()
Local _nX := 0

	_nPesoL := val(_cGet2) - mv_par01
	
	DbSelectArea('SB1')
	DbSetOrder(1)
	if DbSeek(xfilial('SB1')+_cCombo1) .and. _nPesoL > 0
		for _nX:=1 to val(_cGet10)
			_cID :=  GetSx8num('SZ8','Z8_ID')
			ConfirmSx8()

			_cContro := '00' + _cID
			reclock('ZAS',.t.)
			ZAS->ZAS_FILIAL  := xfilial('ZAS')
			ZAS->ZAS_CONTRO  := _cContro
			ZAS->ZAS_COD     := _cCombo1
			ZAS->ZAS_DESC    := SB1->B1_DESCRED
			ZAS->ZAS_DTPROD  := ddatabase
			ZAS->ZAS_VALID   := SB1->B1_VALID
			ZAS->ZAS_PESOL   := _nPesoL//val(_cGet2) - mv_par01
			ZAS->ZAS_PESOB   := val(_cGet2)
			ZAS->ZAS_TARA    := mv_par01
			ZAS->ZAS_PREEMB  := 'MANUAL'
			ZAS->ZAS_TIPO    := 'MP'
			ZAS->ZAS_TERC    := iif(_nModo = 3,'S','N')
			ZAS->ZAS_COD3    := iif(_nModo = 3,_cCombo2,'')
			ZAS->ZAS_LOCAL   := _cGet4
			ZAS->ZAS_DTRMP   := ddatabase
			//se for produção materia-prima propria ou de terceiros
			if _nModo == 2 .or. _nModo == 3
				ZAS->ZAS_DTABAT  := _dGet3
			endif

			if _nModo == 3
				ZAS->ZAS_SIF    := _cGet5
			endif
			msunlock()

			_cMemo :=  padc('[ PRODUÇÃO DE CAIXA DE MP ]',68,' ')	+ chr(13) + chr(10)
			_cMemo += Replicate("=",68) + chr(13) + chr(10)
			_cMemo += "Codigo Caixa:   " + ZAS->ZAS_CONTRO + chr(13) + chr(10)
			_cMemo += "Codigo Produto: " + ZAS->ZAS_COD + chr(13) + chr(10)
			_cMemo += iif(!empty(ZAS->ZAS_COD3),"Cod. MP Terc.:  " + ZAS->ZAS_COD3 + chr(13) + chr(10),'')
			_cMemo += "Descrição:      " + ZAS->ZAS_DESC + chr(13) + chr(10)
			_cMemo += "Data Produção:  " + dtoc(ZAS->ZAS_DTPROD) + chr(13) + chr(10)
			_cMemo += "Peso Bruto:     " + transform(ZAS->ZAS_PESOB,"@ 999.99") + chr(13) + chr(10)
			_cMemo += "Tara:           " + transform(ZAS->ZAS_TARA,"@ 9.999") + chr(13) + chr(10)
			_cMemo += "Peso Liquido:   " + transform(ZAS->ZAS_PESOL,"@ 999.99") + chr(13) + chr(10)
			_cMemo += "Origem:         " + iif(ZAS->ZAS_TERC = 'S','Terceiro','Propria') + chr(13) + chr(10)
			_cMemo += iif(_nModo2 = 1,"Endereço:       " + ZAS->ZAS_LOCALI + chr(13) + chr(10),'')
			_cMemo += Replicate("=",68) + chr(13) + chr(10)

			_oMemo:refresh()
			Imprime(_cContro)
		next _nX
	else
		Help(" ",1,"CADASTRO",,"Problemas com o cadastro de produto ou peso informado inválido!",4,1)
	endif

return

static function valcam()

	if _cGet4 <> '21'
		if msgbox('Tem certeza de que você deseja utilizar a câmara selecionada?','ATENÇÃO!','YESNO')
			//Numero máximo de aptos por andar...
			_nMaxApto := u_gjf144NL(_cGet4)
			return .t.
		else
			_cGet4 := '21'
			_oGet4:CtrlRefresh()
			return .f.
		endif
	endif

return  .t.

Static Function valSif()

	if empty(_cGet5)
		Help(" ",1,"ERRO",,"Obrigatório informar o SIF!",4,1)
		return .f.
	endif

return .t.
