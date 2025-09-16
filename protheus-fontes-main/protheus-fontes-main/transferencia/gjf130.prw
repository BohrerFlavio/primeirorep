#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF130    º Autor ³ Giuliano Forgiariniº Data ³  03/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de transferencia de PA                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ sigapcp                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF130()
	//Cria a caixa de diálogo para localizar uma caixa
	cCaixa := space(11)
	_Mens1 := ''
	_Mens2 := ''
	cont := 0
	campo := space(11)

	DEFINE MSDIALOG oDlgR TITLE 'Localização de caixas para transferencia:' from 000,000 To 150,400 OF oMainWnd PIXEL
	@ 010,003 SAY  'Caixa:' Object oSay1
	//@ 010,025 GET cCaixa PICTURE "@!"   SIZE 60,11  valid ConsC() Object oC   
	@ 01,04   MSGET campo VAR cCaixa SIZE 60,11 OF oDlgR VALID ConsC()
	oFont   := tFont():New("courier new",,-20,,.t.,,,,)
	oSayD1  := tSay():New(30,10,{|| _Mens1 },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
	oSayD2  := tSay():New(30,10,{|| _Mens2 },oDlgR,,oFont,,,,.T.,CLR_HRED,CLR_HRED,200,35)
	@ 010,60 SAY cont
	//oC:setfocus()
	@ 60,160 BMPBUTTON TYPE 1 ACTION odlgR:end() Object Obtn1
	//@ 055,160  BUTTON 'Sair'   SIZE 40,15 ACTION oDlgR:end() OBJECT Obtn1

	ACTIVATE MSDIALOG oDlgR
return

Static Function ConsC()
	if empty(cCaixa)
		return .t.
	endif

	SZ8->(dbsetorder(3))
	if SZ8->(dbseek(xfilial('SZ8') + alltrim(cCaixa)))
		if SZ8->Z8_FIL = cFilAnt 
			Sinv(2)
			_cMens1 := ''
			_cMens2 := 'Caixa já encontra-se na filial de destino!'
		else

			ZAD->(DbSetorder(2))
			if !ZAD->(DbSeek(xfilial('ZAD')+cFilAnt+SZ8->(Z8_PRECAR+Z8_PREPED+Z8_ITEM)))
				Sinv(2)
				_cMens1 := ''
				_cMens2 := 'Sem transferencia para este produto(1)!'

			else
				ZAC->(DbSetOrder(1))
				ZAC->(DbSeek(xfilial('ZAC')+ZAD->ZAD_NUM))
				if SZ8->Z8_CODTRAN = ZAC->ZAC_NUM
					Sinv(2)
					_cMens1 := ''
					_cMens2 := 'Caixa já transferida!'

				else
					if  !(ZAC->ZAC_STATUS $ "L/C")
						Sinv(2)
						_cMens1 := ''
						_cMens2 := 'Transferencia desabilitada(2)!'

					else
						//alert("Precar-"+ ZAD->ZAD_PRECAR+"- ZAD_CODORI"+ZAD->ZAD_CODORI)
						if  ZAD->ZAD_QTREAL >= ZAD->ZAD_QUANT
							Sinv(2)
							_cMens1 := ''
							_cMens2 := 'Prod. Totalmente Transf.!'

						else
							_codProdDes := ''
							area := getarea()
							DbSelectArea('ZZE')
							if  SZ8->Z8_FILORI <> cFilAnt
								_codProdDes := fBuscaCPO('ZZE',1,xfilial('ZZE') + SZ8->Z8_FILORI + SZ8->Z8_CODORI + cFilAnt,'ZZE_CODDES') 
							elseif SZ8->Z8_FILORI = cFilAnt
								_codProdDes := SZ8->Z8_CODORI  
							endif

							restarea(area)

							_cFilOri  := SZ8->Z8_FIL
							_cFilDes  := cFilAnt  
							_cIteTran := SZ8->Z8_ITEM

							if !u_GJF134(1,SZ8->Z8_CONTROL,'E',DDATABASE,; 
							SZ8->Z8_COD,SZ8->Z8_PESO,SZ8->Z8_PRECAR,;
							_cFilOri,SZ8->Z8_PREPED,SZ8->Z8_ITEM,SZ8->Z8_DATA,_cFilDes)
								Sinv(2)
								_cMens1 := ''
								_cMens2 := 'Caixa já lida para esta transferencia(3)!'
							endif

							reclock('SZ8',.f.)
							SZ8->Z8_DATAS   := stod('')                                                       //...devolve para o estoque
							SZ8->Z8_HORAS   := ''
							SZ8->Z8_DTRANSF := ddatabase 
							SZ8->Z8_DTENTES := ddatabase
							SZ8->Z8_PRECAR  := ''
							SZ8->Z8_PREPED  := ''
							SZ8->Z8_ITEM    := ''
							SZ8->Z8_CODTRAN := ZAC->ZAC_NUM
							SZ8->Z8_ITETRAN := _cIteTran
							if SZ8->Z8_FIL <> _cFilDes
								if  !empty(_codProdDes)
									SZ8->Z8_COD := _codProdDes
								endif
								SZ8->Z8_FIL := cFilAnt
							endif
							msunlock()

							reclock('ZAD',.f.)
							ZAD->ZAD_QTREAL := ZAD->ZAD_QTREAL + 1
							msunlock()

							u_gjf17his(1,'TRANSF.FIL. ' + _cFilOri + ' P/ '+ _cFilDes,.f.,_cFilOri,_cFilDes,'000026',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

							Sinv(1)

							_cMens1 := alltrim(SZ8->Z8_CONTROL) + '  ' + alltrim(SZ8->Z8_COD) + '  ' + alltrim(SZ8->Z8_DESCRI) + ' transferida!'
							_cMens2 := ''

							_lOk := .t. 

							ZAD->(DbSetOrder(1))
							ZAD->(DbSeek(xfilial('ZAD')+ZAC->ZAC_NUM))
							while ZAD->(!eof()) .and. xfilial('ZAD')+ZAD->ZAD_NUM = ZAC->(ZAC_FILIAL+ZAC_NUM)
								if ZAD->ZAD_QTREAL < ZAD->ZAD_QUANT
									_lOk := .f.
									exit
								endif
								ZAD->(DbSkip())
							enddo 

							reclock('ZAC',.f.)
							if _lOk
								ZAC->ZAC_STATUS := 'E'
							else
								ZAC->ZAC_STATUS := 'C'
							endif
							msunlock()

						endif
					endif
				endif
			endif
		endif
	else
		Sinv(2)
		_cMens1 := ''
		_cMens2 := 'Caixa não encontrada!'
	endif



	oSayD1:SetText(_cMens1)
	oSayD2:SetText(_cMens2)

	//oC:setfocus()

	oDlgR:refresh()

	//cCaixa := space(11)

	//oC:setfocus()

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


