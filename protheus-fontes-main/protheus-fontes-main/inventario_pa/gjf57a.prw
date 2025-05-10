#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch" 
#INCLUDE "TOTVS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF57A    บ Autor ณ Giuliano Forgiariniบ Data ณ  25/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRotina de localiza็ใo para inventario de caixas de PA       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ sigapcp                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function GJF57A()
	//Cria a caixa de diแlogo para localizar uma caixa
	Private cCaixa := space(11)
	Private cUser  := ""
	_cTemp := GetTempPath()
	cUser := substr(_cTemp, 1, AT("\AppData", _cTemp))
	_Mens1 := ''
	_Mens2 := ''
	cont   := 0
	campo1 := space(11)

	DEFINE MSDIALOG oDlgR TITLE 'Localiza็ใo de caixas para inventแrio:' from 000,000 To 200,550 OF oMainWnd PIXEL

	@ 011,010 SAY  'Caixa:' Object oSay2
	@ 001,004 MSGET campo1 VAR cCaixa Size 60,11 of oDlgR VALID Localiza()
	oFont   := tFont():New("courier new",,-20,,.t.,,,,)
	oSayD1  := tSay():New(30,10,{|| _Mens1 },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,250,50)
	oSayD2  := tSay():New(30,10,{|| _Mens2 },oDlgR,,oFont,,,,.T.,CLR_HRED,CLR_HRED,250,50)
	oSayD3  := tSay():New(10,160,{|| str(cont) },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
	@ 80,245 BMPBUTTON TYPE 1 ACTION oDlgR:end() Object Obtn1

	ACTIVATE MSDIALOG oDlgR CENTERED 

return

Static Function Localiza()

	_cText := ''
	_lErr  := .F.
	if empty(cCaixa)
		return .t.
	endif

	if len(alltrim(cCaixa)) < 10
		Sinv(3)
		return .f.
	endif

	SZ8->(dbsetorder(3))
	if SZ8->(dbseek(FWxfilial('SZ8') + alltrim(cCaixa)))
		if SZ8->Z8_INV <> 'X'

			_grupo := fBuscaCPO('SB1', 1, FWxfilial('SB1') + SZ8->Z8_COD,'B1_GRUPO')

			_dtValCO := date() + 12
			_dtValSO := date() + 35
			_dtValR  := date() + 30

			if (_grupo $ "0002/0004/0008/0009/0031/0033/0036/0038/5500/6500/6600" .or. substr(_grupo, 1, 2) $ "52/62") .and. SZ8->Z8_DATAVAL <= _dtValCO
				_lErr  := .T.
				_cText := '12'
			elseif (_grupo $ "0001/0003/0006/0030/0032/0037/5510" .or. substr(_grupo, 1, 2) $ "51/61") .and. SZ8->Z8_DATAVAL <= _dtValSO
				_lErr  := .T.
				_cText := '35'
			elseif SZ8->Z8_DATAVAL <= _dtValR .and. alltrim(retCodUsr()) != "000429"
				_lErr  := .T.
				_cText := '30'
			endif

			_cMens1 := alltrim(SZ8->Z8_CONTROL) + ' - ' + alltrim(SZ8->Z8_COD) + ' - ' + alltrim(SZ8->Z8_DESCRI) + '  inventariada!' + ' Pallet: ' + SZ8->Z8_PALLET + ' Endereco: ' + SZ8->Z8_LOCALIZ		           
			_cMens2 := ''

			cont++

			reclock('SZ8',.f.)
			SZ8->Z8_INV := 'X'
			msunlock()

			if _lErr = .T.
				Sinv(4)
				FWAlertWarning('Validade menor ou igual a ' + _cText + ' dias! Separar caixa para carregar!', "ATENวรO!")
			else
				Sinv(1)
			endif
		else
			Sinv(2)
			_cMens2 := 'Caixa jแ inventariada!'
			_cMens1 := ''
		endif

	else
		Sinv(3)
		_cMens1 := ''
		_cMens2 := 'Caixa nใo encontrada!'
	endif

	oSayD1:SetText(_cMens1)
	oSayD2:SetText(_cMens2)
	oSayD3:SetText(str(cont))

	oDlgR:refresh()
	cCaixa := space(11)

return .f.

static function Sinv(t)  //Serve para executar o som ao ler caixa ou pe็a
	do case
		case t = 1		
		WINEXEC(cUser + 'Documents\smartclient\sndrec32.exe /play /close /embedding ' + cUser + 'Documents\smartclient\GE.WAV', 0)
		case t = 2
		WINEXEC(cUser + 'Documents\smartclient\sndrec32.exe /play /close /embedding ' + cUser + 'Documents\smartclient\GEER.WAV', 0)
		case t = 3
		WINEXEC(cUser + 'Documents\smartclient\sndrec32.exe /play /close /embedding ' + cUser + 'Documents\smartclient\GE3.WAV', 0)
		case t = 4
		WINEXEC(cUser + 'Documents\smartclient\sndrec32.exe /play /close /embedding ' + cUser + 'Documents\smartclient\GEEDT.WAV', 0)
	endcase
return

/*User Function gambiarra()
	//Cria a caixa de diแlogo para localizar uma caixa
	Private cCaixa := space(15)
	_Mens1 := ''
	_Mens2 := ''
	cont   := 0
	campo1 := space(15)

	RPCSetType(3) //nใo consome licen็a.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	DEFINE MSDIALOG oDlgR TITLE 'Rotina temporaria para produ็ใo de embalagem:' from 000,000 To 170,500 OF oMainWnd PIXEL
	//@ 010,003 SAY  'Local:' Object oSay1
	//@ 010,025 GET _cLocal PICTURE "@!"   SIZE 20,11  F3 '74' Object oL   

	@ 010,053 SAY  'Caixa:' Object oSay2

	@ 001,010 MSGET campo1 VAR cCaixa Size 60,13 of oDlgR VALID valida()
	oFont      := tFont():New("courier new",,-20,,.t.,,,,)
	oSayD1  := tSay():New(30,10,{|| _Mens1 },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
	oSayD2  := tSay():New(40,10,{|| _Mens2 },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
	oSayD3  := tSay():New(10,100,{|| str(cont) },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
	//@ 010,200 SAY cont Object oSay3
	//oC:setfocus()
	@ 60,220 BMPBUTTON TYPE 1 ACTION odlgR:end() Object Obtn1

	ACTIVATE MSDIALOG oDlgR CENTERED 

	RESET ENVIRONMENT

return

static function valida()

	PUTMV('SI_GAMBI',cCaixa)

	_cod  := substr(cCaixa,1,6)
	_seq  := substr(cCaixa,7,6)
	_cMens1 := cCaixa
	_cMens2 := ''

	oSayD1:SetText(_cMens1)
	oSayD2:SetText(_cMens2)
	oSayD3:SetText(str(cont))

	//oC:setfocus()
	oDlgR:refresh()
	cCaixa := space(15)

return .f.*/

/*User Function AJZAS()
	//Cria a caixa de diแlogo para localizar uma caixa
	Private cCaixa := space(11)
	_Mens1 := ''
	_Mens2 := ''
	cont   := 0
	campo1 := space(11)

	RPCSetType(3) //nใo consome licen็a.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	DEFINE MSDIALOG oDlgR TITLE 'Ajuste de caixas de PA para MP:' from 000,000 To 200,550 OF oMainWnd PIXEL

	@ 011,010 SAY  'Caixa:' Object oSay2
	@ 001,004 MSGET campo1 VAR cCaixa Size 60,11 of oDlgR VALID Ajuste()
	oFont      := tFont():New("courier new",,-20,,.t.,,,,)
	oSayD1  := tSay():New(30,10,{|| _Mens1 },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,250,50)
	oSayD2  := tSay():New(30,10,{|| _Mens2 },oDlgR,,oFont,,,,.T.,CLR_HRED,CLR_HRED,250,50)
	oSayD3  := tSay():New(10,160,{|| str(cont) },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
	@ 80,245 BMPBUTTON TYPE 1 ACTION odlgR:end() Object Obtn1

	ACTIVATE MSDIALOG oDlgR CENTERED

	RESET ENVIRONMENT

return

Static Function Ajuste() // Movimenta uma caixa de PA para MP (Embalagem -> Porcionados)

	_cText := ''
	_lErr  := ''
	if empty(cCaixa)
		return .t.
	endif

	if len(alltrim(cCaixa)) < 10
		Sinv(3)
		return .f.
	endif

	SZ8->(dbsetorder(3))
	if SZ8->(dbseek(FWxfilial('SZ8') + alltrim(cCaixa) ))
		reclock('ZAS',.t.)
		ZAS->ZAS_FILIAL  := FWxfilial('ZAS')
		ZAS->ZAS_CONTRO  := SZ8->Z8_CONTROL
		ZAS->ZAS_COD     := SZ8->Z8_COD
		ZAS->ZAS_DESC    := SZ8->Z8_DESCRI
		ZAS->ZAS_DTPROD  := SZ8->Z8_DATAP
		ZAS->ZAS_VALID   := 10
		ZAS->ZAS_PESOL   := SZ8->Z8_PESO
		ZAS->ZAS_PESOB   := SZ8->Z8_PESOBR
		ZAS->ZAS_TARA    := SZ8->Z8_TARA
		ZAS->ZAS_PREEMB  := SZ8->Z8_NUMPREV
		ZAS->ZAS_PREDES  := SZ8->Z8_PREDES
		ZAS->ZAS_TIPO    := 'MP'
		ZAS->ZAS_TERC    := 'N'
		msunlock()

		reclock('SZ8',.f.)
		DbDelete()
		msunlock()

		_cMens1 := 'CX. convertida de PA p/ MP c/ Sucesso!'
		_cMens2 := ''

		Sinv(1)
	else
		Sinv(3)
		_cMens1 := ''
		_cMens2 := 'Caixa nใo encontrada!'
	endif

	oSayD1:SetText(_cMens1)
	oSayD2:SetText(_cMens2)
	oSayD3:SetText(str(cont))

	oDlgR:refresh()
	cCaixa := space(11)

return .f.*/
