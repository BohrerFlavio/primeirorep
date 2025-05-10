#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch" 
#INCLUDE "tbiconn.ch"



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF237     บ Autor ณ Giuliano Forgiariniบ Data ณ  25/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRotina de localiza็ใo para inventario de caixas de MP       บฑฑ
ฑฑบ          ณporcionados                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ sigapcp                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function C_MP_POR()
	//Cria a caixa de diแlogo para localizar uma caixa
	Private cCaixa := space(11)
	Private lInvent    := GetMV('SI_INVENT')
	_Mens1 := ''
	_Mens2 := ''
	cont   := 0
	campo1 := space(11)

	// RPCSetType(3) - Era utlizado para nใo consumir licen็a junto com 'PREPARE ENVIRONMENT'

	DEFINE MSDIALOG oDlgR TITLE 'Localiza็ใo de caixas para inventแrio:' from 000,000 To 200,550 OF oMainWnd PIXEL

	@ 011,010 SAY  'Caixa:' Object oSay2

	@ 001,004 MSGET campo1 VAR cCaixa Size 60,11 of oDlgR VALID ConsC()

	oFont      := tFont():New("courier new",,-20,,.t.,,,,)
	oSayD1  := tSay():New(30,10,{|| _Mens1 },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,250,50)
	oSayD2  := tSay():New(30,10,{|| _Mens2 },oDlgR,,oFont,,,,.T.,CLR_HRED,CLR_HRED,250,50)
	oSayD3  := tSay():New(10,160,{|| str(cont) },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)

	@ 80,245 BMPBUTTON TYPE 1 ACTION oDlgR:end() Object Obtn1
	@ 80,214 BMPBUTTON TYPE 2 ACTION oDlgR:end() Object Obtn1

	ACTIVATE MSDIALOG oDlgR CENTERED 

	//oDlgR:end()
return 

Static Function ConsC()

	if !lInvent
        FWAlertWarning("Execu็ใo de rotinas de inventario desabilitada! Contate o DTI!", "Aviso")
        Return .F.
	endif

	_cErr  := ''
	if empty(cCaixa)
		return .t.
	endif

	if len(alltrim(cCaixa)) < 10
		Sinv(2)
		return .f.
	endif

	ZAS->(dbsetorder(1))
	if ZAS->(dbseek(xfilial('ZAS') + alltrim(cCaixa)))

		if ZAS->ZAS_TIPO <> 'MP'
			Sinv(2)
			_cMens2 := 'Caixa nใo ้ de MP!'
			_cMens1 := ''
		else
			if ZAS->ZAS_INV <> 'X'
				Sinv(1)
				_cMens1 := alltrim(ZAS->ZAS_CONTRO) + '  ' + alltrim(ZAS->ZAS_COD) + '  ' + alltrim(ZAS->ZAS_DESC) + '  inventariada!'
				_cMens2 := ''
				cont++
				reclock('ZAS',.f.)
					ZAS->ZAS_INV := 'X'
					ZAS->ZAS_DATAS := stod('')
				msunlock()

			else
				Sinv(2)
				_cMens2 := 'Caixa jแ inventariada!'
				_cMens1 := ''
			endif
		endif
	else
		Sinv(2)
		_cMens1 := ''
		_cMens2 := 'Caixa nใo encontrada!'
	endif

	oSayD1:SetText(_cMens1)
	oSayD2:SetText(_cMens2)
	oSayD3:SetText(str(cont))

	//oC:setfocus()
	oDlgR:refresh()
	cCaixa := space(11)

	//oC:setfocus()  

return .f.

static function Sinv(t) //Serve para executar o som ao ler caixa ou pe็a
	do case
		case t = 1
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)
		case t = 2
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
		case t = 3
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE3.WAV',0)
	endcase
return
