#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF57c    º Autor ³ Giuliano Forgiariniº Data ³  25/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de transferencia manual dos PA                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ sigapcp                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF57c()
	//Cria a caixa de diálogo para localizar uma caixa
	cCaixa := space(11)
	_Mens1 := ''
	_Mens2 := ''
	cont := 0

	DEFINE MSDIALOG oDlgR TITLE 'Localização de caixas para transferencia:' from 000,000 To 150,400 OF oMainWnd PIXEL
	@ 010,003 SAY  'Caixa:' Object oSay1
	@ 010,025 GET cCaixa PICTURE "@!"   SIZE 60,11  valid ConsC() Object oC
	oFont      := tFont():New("courier new",,-20,,.t.,,,,)
	oSayD1  := tSay():New(30,10,{|| _Mens1 },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
	oSayD2  := tSay():New(30,10,{|| _Mens2 },oDlgR,,oFont,,,,.T.,CLR_HRED,CLR_HRED,200,35)
	@ 010,60 SAY cont
	oC:setfocus()
	@ 60,160 BMPBUTTON TYPE 1 ACTION odlgR:end() Object Obtn1

	ACTIVATE MSDIALOG oDlgR
return

Static Function ConsC()
	if empty(cCaixa)
		return .t.
	endif

	SZ8->(dbsetorder(3))
	if SZ8->(dbseek(xfilial('SZ8') + alltrim(cCaixa) ))

		_codProdDes := ''
		area := getarea()
		DbSelectArea('ZZE')
		if  SZ8->Z8_FILORI <> cFilAnt
			_codProdDes := fBuscaCPO('ZZE',1,xfilial('ZZE') + SZ8->Z8_FILORI + SZ8->Z8_CODORI + cFilAnt,'ZZE_CODDES')
		endif
		restarea(area) 




		_cFilDes := cFilAnt
		_cFilDes := SZ8->Z8_FILORI
		// GJF134(_oper,_caixa         ,_movim,_datam   ,_cod       ,_peso       ,_precar       ,_filial ,_preped       ,_item       ,_data       ,_FilDes)
		u_GJF134(1     ,SZ8->Z8_CONTROL,'E'   ,DDATABASE,SZ8->Z8_COD,SZ8->Z8_PESO,SZ8->Z8_PRECAR,SZ8->Z8_FILORI,SZ8->Z8_PREPED,SZ8->Z8_ITEM,SZ8->Z8_DATA,cFilAnt)
		//u_GJF134(1     ,SZ8->Z8_CONTROL,'E'   ,DDATABASE,SZ8->Z8_COD,SZ8->Z8_PESO,SZ8->Z8_PRECAR,_cFilOri,SZ8->Z8_PREPED,SZ8->Z8_ITEM,SZ8->Z8_DATA,cFilAnt)	

		reclock('SZ8',.f.)
		SZ8->Z8_DATAS   := stod('')                                                       //...devolve para o estoque
		SZ8->Z8_HORAS   := ''
		SZ8->Z8_DTRANSF := DDATABASE
		SZ8->Z8_PRECAR  := ''
		SZ8->Z8_PREPED  := ''
		SZ8->Z8_ITEM    := ''

		if SZ8->Z8_FIL <> cFilAnt

			if  !empty(_codProdDes)
				SZ8->Z8_COD := _codProdDes


			endif

			SZ8->Z8_FIL := cFilAnt
		endif
		alert(_codProdDes)
		msunlock()
		u_gjf17his(1,'TR.MAN.FIL. ' + SZ8->Z8_FILORI + ' P/ '+ _cFilDes,.f.,SZ8->Z8_FILORI,_cFilDes,'000020')
		//u_gjf17his(1,'TR.MAN.FIL. ' + _cFiloRI + ' P/ '+ _cFilDes,.f.,_cFilOri,_cFilDes)  					  

		Sinv(1)
		_cMens1 := alltrim(SZ8->Z8_CONTROL) + '  ' + alltrim(SZ8->Z8_COD) + '  ' + alltrim(SZ8->Z8_DESCRI) + ' transferida!'
		_cMens2 := ''

	else
		Sinv(3)
		_cMens1 := ''
		_cMens2 := 'Caixa não encontrada!'
	endif


	oSayD1:SetText(_cMens1)
	oSayD2:SetText(_cMens2)

	oC:setfocus()

	oDlgR:refresh()

	cCaixa := space(11)

	oC:setfocus()

return .f.

static function Sinv(t)                                                           //Serve para executar o som ao ler caixa ou peça
	do case
		case t = 1
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)
		case t = 2
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
		case t = 3
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GNENC.WAV',0)
	endcase
return


