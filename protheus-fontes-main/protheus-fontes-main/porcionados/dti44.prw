#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI44    º Autor ³ Mauricio Roehrsº Data ³  18/09/17 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de recebimento de matéria prima através da leitura  º±±
±±º          ³ de códigos de barras com determinado padrão  			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Recebimento de MP de Terc. Porcionados                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI44()

	Private  _cMemo   := ""
	Private  _cGet1   := space(45)
	Private  _cGet2   := space(45)
	Private  _cGet3   := space(4)
	Private  _cGet4   := '0.000'
	Private  _cGet5   := '0.000'
	Private _aItComb  := {}
	Private _aItComb2 := {}
	Private _cCombo1  := ''
	Private _cCombo2  := ''
	Private cPerg     := "DTI44"
	Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)
	Private _nModo    := 1
	Private _aOpcoes  := {"Marfrig ","Minerva ","Frigol ","Iguatemi ","Friboi"}
	Private _nMaxApto := 0
	Private _cSay4    := 'Codigo Produto MP/PP:'
	Private _cSay7    := 'Prod. Terc.: '
	Private _nPesLiq  := 0
	Private _nPesBrt  := 0
	Private _nTara    := 0

	if !pergunte(cPerg,.t.)
		return
	endif

	//Monta vetor com os códigos dos produtos de MP para o ComboBox...
	//Somente com os produtos dos grupos 1003, 1004, 4004 e 4005
	MontaCmb()
	MontaCmb2()

	DEFINE DIALOG oDlg TITLE "Recebimento de Matéria Prima para Porcionados" FROM 180,180 TO 750,800 PIXEL

	_oSay0   := TSay():New(05,20, {|| "Fornecedores:"}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oRadio  := TRadMenu():New(11,20,_aOpcoes,{|u| Iif(PCount()==0,_nModo,_nModo:=u)},oDlg,,{||Modos()},,,,,,150,12,,,,.T.,.T.)

	//Informação do SIF
	_oSay1   := TSay():New(05,145, {|| 'SIF:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet3   := TGet():New(05,170, {|u| If(PCount() > 0, _cGet3:= u, _cGet3)}, oDlg,, 009, "@!",{||ValSIF()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet3,,,,.t.,)

	_oSay2   := TSay():New(05,260, {|| "Câmara: " + mv_par01}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

	_oMemo   := TMultiget():New(40,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg,280,130,_oFont,,,,,.T.,,,,,,.t.)

	_oSay3   := TSay():New(180,015, {|| 'Codigo da Caixa:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet1   := TGet():New(180,090, {|u| If(PCount() > 0, _cGet1:= u, _cGet1)}, oDlg,200, 009, "@!",{||Leitura(1)}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet1,,,,.t.,)
	_oGet2   := TGet():New(200,090, {|u| If(PCount() > 0, _cGet2:= u, _cGet2)}, oDlg,200, 009, "@!",{||Leitura(2)}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet2,,,,.t.,)

	//Informação da tara embalagem
	_oSay5   := TSay():New(200,015, {|| 'Tara Embalagem: '}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet4   := TGet():New(200,090, {|u| If(PCount() > 0, _cGet4:= u, _cGet4)}, oDlg,, 009, "@E 9,999",{||vTaraEmb()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet4,,,,.t.,)

	_oSay6   := TSay():New(200,140, {|| 'Tara Interna: '}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet5   := TGet():New(200,215, {|u| If(PCount() > 0, _cGet5:= u, _cGet5)}, oDlg,, 009, "@E 9,999",{||vTaraInt()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet5,,,,.t.,)

	_oSay4   := TSay():New(220,015, {||_cSay4}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oSay7   := TSay():New(240,015, {||_cSay7}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

	_oCombo1 := TComboBox():New(220,140,{|u|if(PCount()>0,_cCombo1:=u,_cCombo1)}, _aItComb,150,20,oDlg,,{||SetProd(_cCombo1)},,,,.T.,,,,,,,,,'_cCombo1')
	_oCombo2 := TComboBox():New(240,140,{|u|if(PCount()>0,_cCombo2:=u,_cCombo2)}, _aItComb2,150,20,oDlg,,{||SetProd2(_cCombo2)},,,,.T.,,,,,,,,,'_cCombo2')

	SetProd(_cCombo1)
	SetProd2(_cCombo2)

	_oSay1:lVisibleControl  := .F. //"SIF
	_oGet3:lVisibleControl  := .F. //SIF

	_oSay5:lVisibleControl  := .F. //tara emb
	_oGet4:lVisibleControl  := .F. //tara emb

	_oSay6:lVisibleControl  := .F. //tara interna
	_oGet5:lVisibleControl  := .F. //tara interna

	_oBtn2 := TButton():New(270,260, "Sair"    , oDlg,{||oDlg:end()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED

Return

//Opções do radiobutton
Static Function Modos()

	_cGet1 := space(43)
	_cGet2 := space(45)
	_cGet3 := space(4)
	_cGet4 := '0.000'
	_nGet5 := '0.000'
	_cMemo := ''

	_oGet1:lVisibleControl  := .T. //leitura
	_oGet2:lVisibleControl  := .T. //leitura 2

	_oSay1:lVisibleControl  := .F. //"SIF
	_oGet3:lVisibleControl  := .F. //SIF

	_oSay6:lVisibleControl  := .F. //tara interna
	_oGet5:lVisibleControl  	:= .F. //tara interna

	_oSay5:lVisibleControl  := .F. //"tara emb
	_oGet4:lVisibleControl  := .F. //tara emb

	if _nModo = 1 //Produção Matéria-prima Marfrig
		_cGet1 := space(45)
		_cGet2 := space(45)
		_cGet3 := space(4)
		_cGet4 := '0.000'
		_nGet5 := '0.000'

		_oSay1:lVisibleControl  := .F. //"SIF

		_oSay5:lVisibleControl  := .F. //"tara emb

		_oGet1:lVisibleControl  := .T.
		_oGet2:lVisibleControl  := .T.
		_oGet3:lVisibleControl  := .F. //SIF
		_oGet4:lVisibleControl  := .F. //tara emb
		_oSay6:lVisibleControl  := .F. //tara interna
		_oGet5:lVisibleControl  := .F. //tara interna

		_oGet1:CtrlRefresh()
		_oGet2:CtrlRefresh()
		_oGet3:CtrlRefresh()
		_oGet4:CtrlRefresh()
		_oGet5:CtrlRefresh()

	elseif _nModo = 2 //Produção Matéria-prima Minerva

		_cGet1 := space(49)
		_cGet2 := space(45)
		_cGet3 := space(4)
		_cGet4 := '0.000'
		_nGet5 := '0.000'

		_oSay1:lVisibleControl  := .T. //"SIF
		_oSay5:lVisibleControl  := .F. //"tara emb

		_oGet1:lVisibleControl  := .T.
		_oGet2:lVisibleControl  := .F.
		_oGet3:lVisibleControl  := .T. //SIF
		_oGet4:lVisibleControl  := .F. //tara emb

		_oSay6:lVisibleControl  := .F. //tara interna
		_oGet5:lVisibleControl  := .F. //tara interna

		_oGet1:CtrlRefresh()
		_oGet2:CtrlRefresh()
		_oGet3:CtrlRefresh()
		_oGet4:CtrlRefresh()
		_oGet5:CtrlRefresh()
		_oGet3:SetFocus()
	elseif _nModo = 3 //Frigol
		_cGet1 := space(45)
		_cGet2 := space(45)
		_cGet3 := space(4)
		_cGet4 := '0.000'
		_nGet5 := '0.000'

		_oSay1:lVisibleControl  := .T. //"SIF
		_oSay5:lVisibleControl  := .F. //"tara emb

		_oGet1:lVisibleControl  := .T.
		_oGet2:lVisibleControl  := .T.
		_oGet3:lVisibleControl  := .T. //SIF
		_oGet4:lVisibleControl  := .F. //tara emb

		_oSay6:lVisibleControl  := .F. //tara interna
		_oGet5:lVisibleControl  := .F. //tara interna

		_oGet1:CtrlRefresh()
		_oGet2:CtrlRefresh()
		_oGet3:CtrlRefresh()
		_oGet4:CtrlRefresh()
		_oGet5:CtrlRefresh()
		_oGet3:SetFocus()
	elseif _nModo = 4 //Produção Matéria-prima Iguatemi
		_cGet1 := space(49)
		_cGet2 := space(45)
		_cGet3 := space(4)
		_cGet4 := '0.000'
		_nGet5 := '0.000'

		_oSay1:lVisibleControl  := .T. //"SIF
		_oSay5:lVisibleControl  := .T. //"tara emb

		_oGet1:lVisibleControl  := .T.
		_oGet2:lVisibleControl  := .F.
		_oGet3:lVisibleControl  := .T. //SIF
		_oGet4:lVisibleControl  := .T. //tara emb

		_oSay6:lVisibleControl  := .T. //tara interna
		_oGet5:lVisibleControl  := .T. //tara interna

		_oGet1:CtrlRefresh()
		_oGet2:CtrlRefresh()
		_oGet3:CtrlRefresh()
		_oGet4:CtrlRefresh()
		_oGet5:CtrlRefresh()
		_oGet3:SetFocus()
		
	elseif _nModo = 5 //Produção Matéria-prima Friboi
		_cGet1 := space(45)
		_cGet2 := space(45)
		_cGet3 := space(4)
		_cGet4 := '0.000'
		_nGet5 := '0.000'

		_oSay1:lVisibleControl  := .F. //"SIF

		_oSay5:lVisibleControl  := .F. //"tara emb

		_oGet1:lVisibleControl  := .T.
		_oGet2:lVisibleControl  := .T.
		_oGet3:lVisibleControl  := .F. //SIF
		_oGet4:lVisibleControl  := .F. //tara emb
		_oSay6:lVisibleControl  := .F. //tara interna
		_oGet5:lVisibleControl  := .F. //tara interna

		_oGet1:CtrlRefresh()
		_oGet2:CtrlRefresh()
		_oGet3:CtrlRefresh()
		_oGet4:CtrlRefresh()
		_oGet5:CtrlRefresh()		

	endif

	_oGet1:CtrlRefresh()
	_oGet2:CtrlRefresh()
	_oMemo:refresh()
	oDlg:refresh()
return

Static Function valSif()

	if empty(_cGet3)
		SomErr()
		Help(" ",1,"ERRO",,"Obrigatório informar o SIF!",4,1)
		return .f.
	endif

return .t.

Static Function vTaraEmb()


	if val(strtran(_cGet4,',','.')) <= 0
		SomErr()
		Help(" ",1,"ERRO",,"Obrigatório informar a Tara da Embalagem!",4,1)
		return .f.
	endif

return .t.

Static Function vTaraInt()

	if val(strtran(_cGet5,',','.')) <= 0
		SomErr()
		Help(" ",1,"ERRO",,"Obrigatório informar a Tara Interna!",4,1)
		return .f.
	endif

return .t.

//Função de validação da leitura
//_nOpc é um valor que diferencia de qual campo de código de barras está sendo escaneado
Static Function Leitura(_nOpc)
	_lret := .f.
	if _nModo == 1 //se for Marfrig

		_lret := marfrig(_nOpc)

	elseif _nModo == 2 //se for minerva

		_lret := minerva(_nOpc)

	elseif _nModo == 3//se for frigol

		_lret:= frigol(_nOpc)

	elseif _nModo == 4//se for iguatemi

		//alert('em desenvolvimento')
		//return .f.
		_lret:= iguatemi(_nOpc)
	elseif _nModo == 5 //se for Friboi
		_lRet := friboi(_nOpc)
	endif

return _lret

//Função que monta os itens da ComboBox para produção de MPs
//para as opções 2 e 3 do RadioButton
Static Function MontaCmb()

	Local _cQuery := ''
	Local _cGrupo := "'4007','4006'"

	_cQuery := " SELECT * FROM " + RetSQLTab('SB1') + " WHERE " + RetSQLFil('SB1')
	_cQuery += " AND B1_TIPO IN('MP','PP') AND B1_GRUPO IN(" + _cGrupo + ") "
	_cQuery += " AND " + RetSQLDel('SB1') + " ORDER BY B1_DESC "

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

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

return

//Função que monta os itens da ComboBox para produção de MPs
//para as opção 3 do RadioButton
Static Function MontaCmb2()

	Local _cQuery := ''
	_cQuery := " SELECT * FROM " + RetSQLTab('SB1') + " WHERE " + RetSQLFil('SB1')
	_cQuery += " AND B1_TIPO IN('MP','PP') AND B1_GRUPO IN('1004') "
	_cQuery += " AND " + RetSQLDel('SB1') + " ORDER BY B1_DESC "

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

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
	Local _ip 	   := ''

	_cEst := getComputerName()
	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	If ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
		_ip := alltrim(ZAM->ZAM_IP)
	Endif

	u_GJF111i('S600','IP',_ip,_cCod)

return

//Função destinada a produção de MP
Static Function Produzir(_nPesLiq,_nPesBrt,_nTara,_dDtProd,_nDiasVal,_cSif)
				

	_cID :=  GetSx8num('SZ8','Z8_ID')
	ConfirmSx8()

	_cContro := '00' + _cID

	DbSelectArea('SB1')
	DbSetOrder(1)
	if DbSeek(xfilial('SB1')+_cCombo1)

		reclock('ZAS',.t.)
		ZAS->ZAS_FILIAL  := xfilial('ZAS')
		ZAS->ZAS_CONTRO  := _cContro
		ZAS->ZAS_COD     := _cCombo1
		ZAS->ZAS_DESC    := SB1->B1_DESCRED
		ZAS->ZAS_DTPROD  := ddatabase
		ZAS->ZAS_VALID   := iif(_nDiasVal == 0,SB1->B1_VALID - 7 ,_nDiasVal)
		ZAS->ZAS_PESOL   := _nPesLiq //val(_cGet2) - mv_par02
		ZAS->ZAS_PESOB   := _nPesBrt //val(_cGet2)
		ZAS->ZAS_TARA    := _nTara   //mv_par02
		ZAS->ZAS_PREEMB  := 'MANUAL'
		ZAS->ZAS_TIPO    := 'MP'
		ZAS->ZAS_TERC    := 'S'
		ZAS->ZAS_COD3    := _cCombo2
		ZAS->ZAS_LOCAL   := mv_par01
		ZAS->ZAS_DTABAT  := _dDtProd
		ZAS->ZAS_SIF     := iif(empty(_cSif),alltrim(_cGet3),alltrim(_cSif))
		ZAS->ZAS_DTRMP   := ddatabase
		msunlock()
		
		u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Produção MP Terceiros", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

		_cMemo :=  padc('[ RECEBIMENTO DE CAIXA DE MP DE TERC. ]',68,' ')	+ chr(13) + chr(10)
		_cMemo += Replicate("=",68) + chr(13) + chr(10)
		_cMemo += "Codigo Caixa:   " + ZAS->ZAS_CONTRO + chr(13) + chr(10)
		_cMemo += "Codigo Produto: " + ZAS->ZAS_COD + chr(13) + chr(10)
		_cMemo += iif(!empty(ZAS->ZAS_COD3),"Cod. MP Terc.:  " + ZAS->ZAS_COD3 + chr(13) + chr(10),'')
		_cMemo += "Descrição:      " + ZAS->ZAS_DESC + chr(13) + chr(10)
		_cMemo += "Data Recebimento:  " + dtoc(ZAS->ZAS_DTPROD) + chr(13) + chr(10)
		_cMemo += "Data Produção:  " + dtoc(ZAS->ZAS_DTABAT) + chr(13) + chr(10)
		_cMemo += "Peso Bruto:     " + transform(ZAS->ZAS_PESOB,"@ 999.99") + chr(13) + chr(10)
		_cMemo += "Tara:           " + transform(ZAS->ZAS_TARA ,"@ 9.999") + chr(13) + chr(10)
		_cMemo += "Peso Liquido:   " + transform(ZAS->ZAS_PESOL,"@ 999.99") + chr(13) + chr(10)
		_cMemo += "Origem:         " + iif(ZAS->ZAS_TERC = 'S','Terceiro','Propria') + chr(13) + chr(10)
		_cMemo += Replicate("=",68) + chr(13) + chr(10)

		_oMemo:refresh()
		Imprime(_cContro)
		execsom()

		if _nModo == 1	//se for marfrig
			_cGet1 := space(45)
			_oGet1:CtrlRefresh()
			_cGet2 := space(45)
			_oGet2:CtrlRefresh()
			_oGet1:setFocus()
		elseif _nModo == 2 //se for minerva
			_cGet1 := space(49)
			_oGet1:CtrlRefresh()
			_oGet1:setFocus()
		elseif _nModo == 3 //se for frigol
			_cGet1 := space(45)
			_oGet1:CtrlRefresh()
			_cGet2 := space(45)
			_oGet2:CtrlRefresh()
			_oGet1:setFocus()
		elseif _nModo == 4 //se for iguatemi
			_cGet1 := space(49)
			_oGet1:CtrlRefresh()
			_oGet1:setFocus()
		elseif _nModo == 5	//se for friboi
			_cGet1 := space(45)
			_oGet1:CtrlRefresh()
			_cGet2 := space(45)
			_oGet2:CtrlRefresh()
			_oGet1:setFocus()			

		endif
	else
		SomErr()
		Help(" ",1,"CADASTRO",,"Problemas com o cadastro de produto!",4,1)
	endif

return

static function execsom()

	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)

return

Static Function SomErr()

	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)

return

static function marfrig(_nOpc)

	if (empty(_cGet1) .and. _nOpc == 1) .or. (empty(_cGet2) .and. _nOpc == 2)
		return .t.
	else

		//Se o tamanho do codigo for menor que 42 digitos ou 44 digitos
		if (len(alltrim(_cGet1)) < 42 .and. _nOpc == 1) .or. (len(alltrim(_cGet2)) < 40 .and. _nOpc == 2)
			SomErr()
			Help(" ",1,"ERRO",,"Falha na leitura!",4,1)
			if _nOpc == 1
				_cGet1 := space(45)
				_oGet1:CtrlRefresh()
			elseif _nOpc == 2
				_cGet2 := space(45)
				_oGet2:CtrlRefresh()
			endif
			return .f.
		else

			if _nOpc == 1//se a leitura for no primeiro campo
				_cPrd := substr(_cGet1,1,2)
				if _cPrd <> '01'//verifica se está lendo o código de barras correto
					SomErr()
					Help(" ",1,"ERRO",,"Código de barras incorreto!",4,1)
					_cGet1 := space(45)
					_oGet1:CtrlRefresh()

					return .f.
				else

					_nPesLiq := val(substr(_cGet1,21,6)) / 1000
					_nPesBrt := val(substr(_cGet1,31,6)) / 1000
					_nTara   := _nPesBrt - _nPesLiq

				endif

			elseif _nOpc == 2 //no segundo código chama a função de produzir

				_cDt := substr(_cGet2,1,2)
				if _cDt <> '15'
					SomErr()
					Help(" ",1,"ERRO",,"Código de barras incorreto!",4,1)
					_cGet2 := space(45)
					_oGet2:CtrlRefresh()
					return .f.
				elseif len(alltrim(_cGet1)) < 42
					SomErr()
					Help(" ",1,"ERRO",,"Primeira leitura não realizada!",4,1)
					_cGet2 := space(45)
					_oGet2:CtrlRefresh()
					return .f.
				else

					_cAnoVal  := substr(_cGet2,3,2)
					_cMesVal  := substr(_cGet2,5,2)
					_cDiaVal  := substr(_cGet2,7,2)

					_cAnoPrd  := substr(_cGet2,11,2)
					_cMesPrd  := substr(_cGet2,13,2)
					_cDiaPrd  := substr(_cGet2,15,2)

					_dDtValid := ctod(_cDiaVal + '/' + _cMesVal + '/' + _cAnoVal)
					_dDtProd  := ctod(_cDiaPrd + '/' + _cMesPrd + '/' + _cAnoPrd)
					_nDiasVal := DateDiffDay(_dDtValid,_dDtProd)
					_cSif     := substr(_cGet2,25,4)

					//pesoliq  pesobrt tara  dtemb   diasvalid(vai zero pq vai pegar do cadastro) SIF(vai em branco pq a informação é manual
					produzir(_nPesLiq,_nPesBrt,_nTara,_dDtProd,_nDiasVal,_cSif)

				endif
			endif
		endif
	endif

return .t.

static function minerva(_nOpc)

	if empty(_cGet1)
		return .t.
	else
		//Se o tamanho do codigo for menor que 46 digitos
		if len(substr(alltrim(_cGet1),1,46)) < 46
			SomErr()
			Help(" ",1,"ERRO",,"Falha na leitura!",4,1)
			_cGet1 := space(49)
			_oGet1:CtrlRefresh()
			return .f.

		elseif empty(_cGet3)//valida o sif
			SomErr()
			Help(" ",1,"ERRO",,"Obrigatório informar o SIF!",4,1)
			return .f.

		else
			_nPesLiq := val(substr(_cGet1,26,4)) / 100
			_nTara   := val(substr(_cGet1,43,4)) / 1000
			_nPesBrt := _nPesLiq + _nTara

			_cDiaEmb  := substr(_cGet1,30,2)
			_cMesEmb  := substr(_cGet1,32,2)
			_cAnoEmb  := substr(_cGet1,34,4)

			_dDtEmb  := ctod(_cDiaEmb + '/' + _cMesEmb + '/' + _cAnoEmb)

			//         pesoliq  pesobrt tara  dtemb   diasvalid(vai zero pq vai pegar do cadastro) SIF(vai em branco pq a informação é manual
			produzir(_nPesLiq,_nPesBrt,_nTara,_dDtEmb,0,'')
		endif
	endif

return .t.

static function frigol(_nOpc)

	if (empty(_cGet1) .and. _nOpc == 1) .or. (empty(_cGet2) .and. _nOpc == 2)
		return .t.
	else

		//Se o tamanho do codigo for menor que 40 digitos ou 37 digitos
		if (len(alltrim(_cGet1)) < 40 .and. _nOpc == 1) .or. (len(alltrim(_cGet2)) < 36 .and. _nOpc == 2)
			SomErr()
			Help(" ",1,"ERRO",,"Falha na leitura!",4,1)
			if _nOpc == 1
				_cGet1 := space(45)
				_oGet1:CtrlRefresh()
			elseif _nOpc == 2
				_cGet2 := space(45)
				_oGet2:CtrlRefresh()
			endif
			return .f.
		else

			if _nOpc == 1//se a leitura for no primeiro campo
				_cPrd := substr(_cGet1,1,2)
				if _cPrd <> '01'//verifica se está lendo o código de barras correto
					SomErr()
					Help(" ",1,"ERRO",,"Código de barras incorreto!",4,1)
					_cGet1 := space(45)
					_oGet1:CtrlRefresh()

					return .f.
				else

					_nPesLiq := val(substr(_cGet1,21,6)) / 1000
					_nPesBrt := val(substr(_cGet1,31,6)) / 1000
					_nTara   := _nPesBrt - _nPesLiq

				endif

			elseif _nOpc == 2 //no segundo código chama a função de produzir

				_cDt := substr(_cGet2,1,2)
				if _cDt <> '15'
					SomErr()
					Help(" ",1,"ERRO",,"Código de barras incorreto!",4,1)
					_cGet2 := space(45)
					_oGet2:CtrlRefresh()
					return .f.
				elseif len(alltrim(_cGet1)) < 40
					SomErr()
					Help(" ",1,"ERRO",,"Primeira leitura não realizada!",4,1)
					_cGet2 := space(45)
					_oGet2:CtrlRefresh()
					return .f.
				else

					_cAnoVal  := substr(_cGet2,3,2)
					_cMesVal  := substr(_cGet2,5,2)
					_cDiaVal  := substr(_cGet2,7,2)

					_cAnoPrd  := substr(_cGet2,11,2)
					_cMesPrd  := substr(_cGet2,13,2)
					_cDiaPrd  := substr(_cGet2,15,2)

					_dDtValid := ctod(_cDiaVal + '/' + _cMesVal + '/' + _cAnoVal)
					_dDtProd  := ctod(_cDiaPrd + '/' + _cMesPrd + '/' + _cAnoPrd)
					_nDiasVal := DateDiffDay(_dDtValid,_dDtProd)
					_cSif     := substr(_cGet2,26,3) + '0'

					//pesoliq  pesobrt tara  dtemb   diasvalid(vai zero pq vai pegar do cadastro) SIF(vai em branco pq a informação é manual
					produzir(_nPesLiq,_nPesBrt,_nTara,_dDtProd,_nDiasVal,'')

				endif
			endif
		endif
	endif

return .t.

static function iguatemi(_nOpc)

	if empty(_cGet1)
		return .t.
	else
		//Se o tamanho do codigo for menor que 34 digitos
		if len(substr(alltrim(_cGet1),1,34)) < 34
			SomErr()
			Help(" ",1,"ERRO",,"Falha na leitura!",4,1)
			_cGet1 := space(49)
			_oGet1:CtrlRefresh()
			return .f.

		elseif empty(_cGet3)//valida o sif
			SomErr()
			Help(" ",1,"ERRO",,"Obrigatório informar o SIF!",4,1)
			return .f.
		elseif val(strtran(_cGet4,',','.')) <= 0 .or. val(strtran(_cGet5,',','.')) <= 0
			SomErr()
			Help(" ",1,"ERRO",,"Obrigatório informar as Taras!",4,1)
			return .f.
		else
			_nPesLiq := val(substr(_cGet1,23,4)) / 100
			_nTara   := val(strtran(_cGet4,',','.')) + val(strtran(_cGet5,',','.')) //val(substr(_cGet1,43,4)) / 1000
			_nPesBrt := round(_nPesLiq + _nTara,2)

			_cDiaVal  := substr(_cGet1,33,2)//33
			_cMesVal  := substr(_cGet1,31,2)
			_cAnoVal  := substr(_cGet1,29,2)//29

			_dDtVal  := ctod(_cDiaVal + '/' + _cMesVal + '/' + _cAnoVal)

			_dDtEmb := _dDtVal - 90 

			//         pesoliq  pesobrt tara  dtemb   diasvalid(vai zero pq vai pegar do cadastro) SIF(vai em branco pq a informação é manual
			//produzir(_nPesLiq,_nPesBrt,_nTara,_dDtEmb,_dDtVal,'')
			produzir(_nPesLiq,_nPesBrt,_nTara,_dDtEmb,0,'')
		endif
	endif

return .t.


static function friboi(_nOpc)

	if (empty(_cGet1) .and. _nOpc == 1) .or. (empty(_cGet2) .and. _nOpc == 2)
		return .t.
	else

		//alert(_cGet1)
		//alert(len(alltrim(_cGet1)))
		//alert(_cGet2)
		//alert(len(alltrim(_cGet2)))
		
		//alert(_nOpc)
		//alert(_nModo)
		//Se o tamanho do codigo for menor que 42 digitos ou 44 digitos
		if (len(alltrim(_cGet1)) < 41 .and. _nOpc == 1) .or. (len(alltrim(_cGet2)) < 40 .and. _nOpc == 2)
			SomErr()
			Help(" ",1,"ERRO",,"Falha na leitura!",4,1)
			if _nOpc == 1
				_cGet1 := space(45)
				_oGet1:CtrlRefresh()
			elseif _nOpc == 2
				_cGet2 := space(45)
				_oGet2:CtrlRefresh()
			endif
			return .f.
		else

			if _nOpc == 1//se a leitura for no primeiro campo
				_cPrd := substr(_cGet1,1,2)
				if _cPrd <> '01'//verifica se está lendo o código de barras correto
					SomErr()
					Help(" ",1,"ERRO",,"Código de barras incorreto!",4,1)
					_cGet1 := space(45)
					_oGet1:CtrlRefresh()

					return .f.
				else

					_nPesLiq := val(substr(_cGet1,21,6)) / 100
					_nPesBrt := val(substr(_cGet1,31,6)) / 100
					_nTara   := _nPesBrt - _nPesLiq
					
//					alert(_nPesLiq)
//					alert(_nPesBrt)
//					alert(_nTara)
				endif

			elseif _nOpc == 2 //no segundo código chama a função de produzir

				_cDt := substr(_cGet2,1,2)
				if _cDt <> '15'
					SomErr()
					Help(" ",1,"ERRO",,"Código de barras incorreto!",4,1)
					_cGet2 := space(45)
					_oGet2:CtrlRefresh()
					return .f.
				elseif len(alltrim(_cGet1)) < 41
					SomErr()
					Help(" ",1,"ERRO",,"Primeira leitura não realizada!",4,1)
					_cGet2 := space(45)
					_oGet2:CtrlRefresh()
					return .f.
				else

					_cAnoVal  := substr(_cGet2,3,2)
					_cMesVal  := substr(_cGet2,5,2)
					_cDiaVal  := substr(_cGet2,7,2)

					_cAnoPrd  := substr(_cGet2,11,2)
					_cMesPrd  := substr(_cGet2,13,2)
					_cDiaPrd  := substr(_cGet2,15,2)

					_dDtValid := ctod(_cDiaVal + '/' + _cMesVal + '/' + _cAnoVal)
					_dDtProd  := ctod(_cDiaPrd + '/' + _cMesPrd + '/' + _cAnoPrd)
					_nDiasVal := DateDiffDay(_dDtValid,_dDtProd)
					_cSif     := substr(_cGet2,25,4)
					
					
//					alert(_dDtValid)
//					alert(_dDtProd)
//					alert(_nDiasVal)
//					alert(_cSif)

					//pesoliq  pesobrt tara  dtemb   diasvalid(vai zero pq vai pegar do cadastro) SIF(vai em branco pq a informação é manual
					produzir(_nPesLiq,_nPesBrt,_nTara,_dDtProd,_nDiasVal,_cSif)

				endif
			endif
		endif
	endif

return .t. //.t.
