#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF216    º Autor ³ Giuliano Forgiariniº Data ³  27/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de gerenciamento e acompanhamento das produções dos º±±
±±º          ³ lotes de produção                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Porcionados                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF216()

	aObjects            := {}
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           :=aPosObj[1]
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	Private _lFOpen := .F.

	Private _cMemo0  := ""
	Private _cMemo1  := ""
	Private _cMemo2  := ""
	Private _cMemo3  := ""
	Private _cMemo4  := ""
	Private _cMemo5  := ""
	Private _cMemo6  := ""

	Private _cSayPorc := ''
	Private _cSayLin0 := 'Linha 0:'
	Private _cSayLin1 := 'Linha 1:'
	Private _cSayLin2 := 'Linha 2:'
	Private _cSayLin3 := 'Linha 3:'
	Private _cSayLin4 := 'Linha 4:'
	Private _cSayLin5 := 'Linha 5:'
	Private _cSayLin6 := 'Linha 6:'

	_cSayW := 'Lote de Produção WPL:'
	_cSayT := 'Lote de Produção Testeira:'

	_cPorc := GetMV('SI_MPPORC')
	if _cPorc = 'S'
		_cSayPorc := 'Ativado'
	else
		_cSayPorc := 'Desativado'
	endif

	//Variáveis de controle do RadioButton
	//de ativação da WPL
	Private _nModoW0 := 2
	Private _nModoW1 := 2
	Private _nModoW3 := 2
	Private _nModoW5 := 2
	Private _nModoW6 := 2

	//Variáveis de controle do RadioButton
	//de ativação da testeira
	Private _nModoT0 := 2
	Private _nModoT1 := 2
	Private _nModoT2 := 2
	Private _nModoT3 := 2
	Private _nModoT4 := 2
	Private _nModoT5 := 2
	Private _nModoT6 := 2

	//Variáveis de controle do campo
	//de apontamento do lote na ativação
	//da WPL
	Private VlLoW0 := space(10)
	Private CpLoW0 := space(10)

	Private VlLoW1 := space(10)
	Private CpLoW1 := space(10)

	Private VlLoW3 := space(10)
	Private CpLoW3 := space(10)

	Private VlLoW5 := space(10)
	Private CpLoW5 := space(10)

	Private VlLoW6 := space(10)
	Private CpLoW6 := space(10)

	//Variáveis de controle do campo
	//de apontamento do lote na ativação
	//da testeira
	Private VlLoT0 := space(10)
	Private CpLoT0 := space(10)

	Private VlLoT1 := space(10)
	Private CpLoT1 := space(10)

	Private VlLoT2 := space(10)
	Private CpLoT2 := space(10)

	Private VlLoT3 := space(10)
	Private CpLoT3 := space(10)

	Private VlLoT4 := space(10)
	Private CpLoT4 := space(10)

	Private VlLoT5 := space(10)
	Private CpLoT5 := space(10)

	Private VlLoT6 := space(10)
	Private CpLoT6 := space(10)

	Private _aOpcoes  := {"Produção","Ociosa"}

	Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)
	Private _oFont2   := tFont():New("courier new",,-12,,.t.,,,,)

	Private _cGrpMoi := GetMV('SI_GRPMOI')
	Private _cGrupo  := ''
	//Private _cEst := getComputerName()
	Private _cUserID := alltrim(RetCodUsr())
	/*
	Private _cEstH1 := GetMV('SI_POR0002')
	Private _cEstH2 := GetMV('SI_POR0003')
	Private _cEstH3 := GetMV('SI_POR0004')
	Private _cEstH4 := GetMV('SI_POR0005')
	*/
	Private _cEstH0 := GetMV('SI_POR0000')
	Private _cEstH1 := GetMV('SI_POR0006')
	Private _cEstH2 := GetMV('SI_POR0007')
	Private _cEstH3 := GetMV('SI_POR0008')
	Private _cEstH4 := GetMV('SI_POR0009')
	Private _cEstH5 := GetMV('SI_POR0011')
	Private _cEstH6 := GetMV('SI_POR0012')
	Private _cUserM := GetMV('SI_POR0010') // Para usuários Martes
	Private _cLinha := ''

	DEFINE DIALOG oDlg TITLE "Acompanhamento de produção" from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] PIXEL

	oScroll := TScrollArea():New(oDlg,01,01,100,100,.T.,.T.,.T.)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT

	If _cUserID $ _cUserM

		// Cria painel
		@ 000,000 MSPANEL oPanel OF oScroll SIZE 400,600 COLOR CLR_HRED
		// Define objeto painel como filho do scroll
		oScroll:SetFrame(oPanel)
		/* Sistema completo de controle de Produção */

		oTimer := TTimer():New(01,{||ValTela()}, oDlg)
		oTimer:Activate()
		
		//Linha de produção 001
		_oSayLin1 := TSay():New(001,200, {|| _cSayLin1}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

		_oRadW1   := TRadMenu():New(010,070,_aOpcoes,{|u| Iif(PCount()==0,_nModoW1,_nModoW1:=u)},oPanel,,{||Modos2('001','W')},,,,,,100,12,,,,.T.)
		_oSayw1   := TSay():New(010,115, {|| _cSayW}, oPanel,, _oFont,,,, .T.,, CLR_WHITE,080,020)
		@ 10,190 MSGET CpLoW1 VAR VlLoW1 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUw" VALID ValLoW('001')

		_oRadT1   := TRadMenu():New(010,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT1,_nModoT1:=u)},oPanel,,{||Modos('001','T')},,,,,,100,12,,,,.T.)
		_oSayLo1  := TSay():New(010,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE,080,020)
		@ 10,395 MSGET CpLoT1 VAR VlLoT1 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('001')

		_oBtn01 := TButton():New(000, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(1) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

		_oMemo1   := TMultiget():New(040,60,{|u|if(Pcount()>0,_cMemo1:=u,_cMemo1)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)

		_oRadT1:disable()
		CpLoT1:disable()
		_oRadT1:refresh()
		CpLoT1:refresh()

		//Linha de produção 002
		_oSayLin2 := TSay():New(100,200, {|| _cSayLin2}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

		_oRadT2   := TRadMenu():New(110,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT2,_nModoT2:=u)},oPanel,,{||Modos('002','T')},,,,,,100,12,,,,.T.)
		_oSayLo2  := TSay():New(110,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
		@ 110,395 MSGET CpLoT2 VAR VlLoT2 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('002')

		_oBtn02 := TButton():New(099, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(2) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

		_oMemo2   := TMultiget():New(140,60,{|u|if(Pcount()>0,_cMemo2:=u,_cMemo2)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)

		//Linha de produção 003
		_oSayLin3 := TSay():New(200,200, {|| _cSayLin3}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

		_oRadW3   := TRadMenu():New(210,070,_aOpcoes,{|u| Iif(PCount()==0,_nModoW3,_nModoW3:=u)},oPanel,,{||Modos2('003','W')},,,,,,100,12,,,,.T.)
		_oSayW3   := TSay():New(210,115, {|| _cSayW}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
		@ 210,190 MSGET CpLoW3 VAR VlLoW3 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUw" VALID ValLoW('003')

		_oRadT3   := TRadMenu():New(210,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT3,_nModoT3:=u)},oPanel,,{||Modos('003','T')},,,,,,100,12,,,,.T.)
		_oSayLo3  := TSay():New(210,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
		@ 210,395 MSGET CpLoT3 VAR VlLoT3 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('003')

		_oBtn03 := TButton():New(199, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(3) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

		_oMemo3   := TMultiget():New(240,60,{|u|if(Pcount()>0,_cMemo3:=u,_cMemo3)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)

		_oRadT3:disable()
		CpLoT3:disable()
		_oRadT3:refresh()
		CpLoT3:refresh()

		//Linha de produção 004
		_oSayLin4 := TSay():New(300,200, {|| _cSayLin4}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

		_oRadT4   := TRadMenu():New(310,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT4,_nModoT4:=u)},oPanel,,{||Modos('004','T')},,,,,,100,12,,,,.T.)
		_oSayLo4  := TSay():New(310,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
		@ 310,395 MSGET CpLoT4 VAR VlLoT4 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('004')

		_oBtn04 := TButton():New(299, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(4) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

		_oMemo4   := TMultiget():New(340,60,{|u|if(Pcount()>0,_cMemo4:=u,_cMemo4)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)		

		//Linha de produção 005
		_oSayLin5 := TSay():New(400,200, {|| _cSayLin5}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

		_oRadW5   := TRadMenu():New(410,070,_aOpcoes,{|u| Iif(PCount()==0,_nModoW5,_nModoW5:=u)},oPanel,,{||Modos2('005','W')},,,,,,100,12,,,,.T.)
		_oSayW5   := TSay():New(410,115, {|| _cSayW}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
		@ 410,190 MSGET CpLoW5 VAR VlLoW5 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUw" VALID ValLoW('005')

		_oRadT5   := TRadMenu():New(410,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT5,_nModoT5:=u)},oPanel,,{||Modos('005','T')},,,,,,100,12,,,,.T.)
		_oSayLo5  := TSay():New(410,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
		@ 410,395 MSGET CpLoT5 VAR VlLoT5 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('005')

		_oBtn05 := TButton():New(399, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(5) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

		_oMemo5   := TMultiget():New(440,60,{|u|if(Pcount()>0,_cMemo5:=u,_cMemo5)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)

		_oRadT5:disable()
		CpLoT5:disable()
		_oRadT5:refresh()
		CpLoT5:refresh()

		//Linha de produção 006
		_oSayLin6 := TSay():New(500,200, {|| _cSayLin6}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

		_oRadW6   := TRadMenu():New(510,070,_aOpcoes,{|u| Iif(PCount()==0,_nModoW6,_nModoW6:=u)},oPanel,,{||Modos2('006','W')},,,,,,100,12,,,,.T.)
		_oSayw6   := TSay():New(510,115, {|| _cSayW}, oPanel,, _oFont,,,, .T.,, CLR_WHITE,080,020)
		@ 510,190 MSGET CpLoW6 VAR VlLoW6 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUw" VALID ValLoW('006')

		_oRadT6   := TRadMenu():New(510,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT6,_nModoT6:=u)},oPanel,,{||Modos('006','T')},,,,,,100,12,,,,.T.)
		_oSayLo6  := TSay():New(510,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE,080,020)
		@ 510,395 MSGET CpLoT6 VAR VlLoT6 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('006')

		_oBtn06 := TButton():New(499, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(1) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

		_oMemo6   := TMultiget():New(540,60,{|u|if(Pcount()>0,_cMemo6:=u,_cMemo6)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)

		_oRadT6:disable()
		CpLoT6:disable()
		_oRadT6:refresh()
		CpLoT6:refresh()

		InicVal()
	Else 

		// Cria painel
		@ 000,000 MSPANEL oPanel OF oScroll SIZE 400,250 COLOR CLR_HRED
		// Define objeto painel como filho do scroll
		oScroll:SetFrame(oPanel)

		IF _cUserID $ _cEstH0
			oTimer := TTimer():New(01,{||ValT0()}, oDlg)

			oTimer:Activate()
			_cLinha := '000'
			//Linha de testes			
			_oSayLin0 := TSay():New(001,200, {|| _cSayLin0}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

			_oRadW0   := TRadMenu():New(010,070,_aOpcoes,{|u| Iif(PCount()==0,_nModoW0,_nModoW0:=u)},oPanel,,{||Modos2('000','W')},,,,,,100,12,,,,.T.)
			_oSayW0   := TSay():New(010,115, {|| _cSayW}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
			@ 010,190 MSGET CpLoW0 VAR VlLoW0 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUw" VALID ValLoW('000')

			_oRadT0   := TRadMenu():New(010,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT0,_nModoT0:=u)},oPanel,,{||Modos('000','T')},,,,,,100,12,,,,.T.)
			_oSayLo0  := TSay():New(010,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
			@ 010,395 MSGET CpLoT0 VAR VlLoT0 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('000')

			_oBtn00 := TButton():New(000, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(0) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

			_oMemo0   := TMultiget():New(040,60,{|u|if(Pcount()>0,_cMemo0:=u,_cMemo0)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)

			_oRadT0:disable()
			CpLoT0:disable()
			_oRadT0:refresh()
			CpLoT0:refresh()

			InicV0(_cLinha)

		endif
		//IF _cEst $ _cEstH1
		IF _cUserID $ _cEstH1 
			oTimer := TTimer():New(01,{||ValT1()}, oDlg)

			oTimer:Activate()
			_cLinha := '001'
			//Linha de produção 001
			_oSayLin1 := TSay():New(001,200, {|| _cSayLin1}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

			_oRadW1   := TRadMenu():New(010,070,_aOpcoes,{|u| Iif(PCount()==0,_nModoW1,_nModoW1:=u)},oPanel,,{||Modos2('001','W')},,,,,,100,12,,,,.T.)
			_oSayw1   := TSay():New(010,115, {|| _cSayW}, oPanel,, _oFont,,,, .T.,, CLR_WHITE,080,020)
			@ 10,190 MSGET CpLoW1 VAR VlLoW1 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUw" VALID ValLoW('001')

			_oRadT1   := TRadMenu():New(010,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT1,_nModoT1:=u)},oPanel,,{||Modos('001','T')},,,,,,100,12,,,,.T.)
			_oSayLo1  := TSay():New(010,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE,080,020)
			@ 10,395 MSGET CpLoT1 VAR VlLoT1 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('001')

			_oBtn01 := TButton():New(000, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(1) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

			_oMemo1   := TMultiget():New(040,60,{|u|if(Pcount()>0,_cMemo1:=u,_cMemo1)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)

			_oRadT1:disable()
			CpLoT1:disable()
			_oRadT1:refresh()
			CpLoT1:refresh()

			InicV1(_cLinha)

		endif
		//IF _cEst $ _cEstH2
		IF _cUserID $ _cEstH2
			oTimer := TTimer():New(01,{||ValT2()}, oDlg)
			oTimer:Activate()

			//Linha de produção 002
			_cLinha := '002'
			_oSayLin2 := TSay():New(100,200, {|| _cSayLin2}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

			_oRadT2   := TRadMenu():New(110,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT2,_nModoT2:=u)},oPanel,,{||Modos('002','T')},,,,,,100,12,,,,.T.)
			_oSayLo2  := TSay():New(110,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
			@ 110,395 MSGET CpLoT2 VAR VlLoT2 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('002')

			_oBtn02 := TButton():New(099, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(2) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

			_oMemo2   := TMultiget():New(140,60,{|u|if(Pcount()>0,_cMemo2:=u,_cMemo2)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)

			InicV2(_cLinha)

		Endif
		//IF _cEst $ _cEstH3
		IF _cUserID $ _cEstH3

			oTimer := TTimer():New(01,{||ValT3()}, oDlg)
			oTimer:Activate()

			//Linha de produção 003
			_cLinha := '003'
			_oSayLin3 := TSay():New(001,200, {|| _cSayLin3}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

			_oRadW3   := TRadMenu():New(010,070,_aOpcoes,{|u| Iif(PCount()==0,_nModoW3,_nModoW3:=u)},oPanel,,{||Modos2('003','W')},,,,,,100,12,,,,.T.)
			_oSayW3   := TSay():New(010,115, {|| _cSayW}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
			@ 10,190 MSGET CpLoW3 VAR VlLoW3 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUw" VALID ValLoW('003')

			_oRadT3   := TRadMenu():New(010,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT3,_nModoT3:=u)},oPanel,,{||Modos('003','T')},,,,,,100,12,,,,.T.)
			_oSayLo3  := TSay():New(010,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
			@ 10,395 MSGET CpLoT3 VAR VlLoT3 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('003')

			_oBtn03 := TButton():New(000, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(3) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

			_oMemo3   := TMultiget():New(040,60,{|u|if(Pcount()>0,_cMemo3:=u,_cMemo3)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)

			_oRadT3:disable()
			CpLoT3:disable()
			_oRadT3:refresh()
			CpLoT3:refresh()

			InicV3(_cLinha)

		Endif
		//IF _cEst $ _cEstH4
		IF _cUserID $ _cEstH4

			oTimer := TTimer():New(01,{||ValT4()}, oDlg)
			oTimer:Activate()

			//Linha de produção 004
			_cLinha := '004'

			_oSayLin4 := TSay():New(100,200, {|| _cSayLin4}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

			_oRadT4   := TRadMenu():New(110,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT4,_nModoT4:=u)},oPanel,,{||Modos('004','T')},,,,,,100,12,,,,.T.)
			_oSayLo4  := TSay():New(110,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
			@ 110,395 MSGET CpLoT4 VAR VlLoT4 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('004')

			_oBtn04 := TButton():New(099, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(4) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

			_oMemo4   := TMultiget():New(140,60,{|u|if(Pcount()>0,_cMemo4:=u,_cMemo4)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)

			InicV4(_cLinha)

		Endif
		//
		IF _cUserID $ _cEstH5

			oTimer := TTimer():New(01,{||ValT5()}, oDlg)
			oTimer:Activate()

			//Linha de produção 005
			_cLinha := '005'
			_oSayLin5 := TSay():New(001,200, {|| _cSayLin5}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

			_oRadW5   := TRadMenu():New(010,070,_aOpcoes,{|u| Iif(PCount()==0,_nModoW5,_nModoW5:=u)},oPanel,,{||Modos2('005','W')},,,,,,100,12,,,,.T.)
			_oSayW5   := TSay():New(010,115, {|| _cSayW}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
			@ 10,190 MSGET CpLoW5 VAR VlLoW5 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUw" VALID ValLoW('005')

			_oRadT5   := TRadMenu():New(010,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT5,_nModoT5:=u)},oPanel,,{||Modos('005','T')},,,,,,100,12,,,,.T.)
			_oSayLo5  := TSay():New(010,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
			@ 10,395 MSGET CpLoT5 VAR VlLoT5 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('005')

			_oBtn05 := TButton():New(000, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(5) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

			_oMemo5   := TMultiget():New(040,60,{|u|if(Pcount()>0,_cMemo5:=u,_cMemo5)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)

			_oRadT5:disable()
			CpLoT5:disable()
			_oRadT5:refresh()
			CpLoT5:refresh()

			InicV5(_cLinha)

		Endif
		IF _cUserID $ _cEstH6
			oTimer := TTimer():New(01,{||ValT6()}, oDlg)

			oTimer:Activate()
			_cLinha := '006'
			//Linha de produção 006 - IQF
			_oSayLin6 := TSay():New(001,200, {|| _cSayLin6}, oPanel,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

			_oRadW6   := TRadMenu():New(010,070,_aOpcoes,{|u| Iif(PCount()==0,_nModoW6,_nModoW6:=u)},oPanel,,{||Modos2('006','W')},,,,,,100,12,,,,.T.)
			_oSayw6   := TSay():New(010,115, {|| _cSayW}, oPanel,, _oFont,,,, .T.,, CLR_WHITE,080,020)
			@ 10,190 MSGET CpLoW6 VAR VlLoW6 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUw" VALID ValLoW('006')

			_oRadT6   := TRadMenu():New(010,270,_aOpcoes,{|u| Iif(PCount()==0,_nModoT6,_nModoT6:=u)},oPanel,,{||Modos('006','T')},,,,,,100,12,,,,.T.)
			_oSayLo6  := TSay():New(010,315, {|| _cSayT}, oPanel,, _oFont,,,, .T.,, CLR_WHITE,080,020)
			@ 10,395 MSGET CpLoT6 VAR VlLoT6 SIZE 50,10 OF oPanel PIXEL PICTURE "@!" F3 "CoZAUt" VALID ValLoT('006')

			_oBtn06 := TButton():New(000, 235, "Reiniciar Testeira"    , oPanel,{|| reinicia(6) },60,010,,,.F.,.T.,.F.,,.F.,,,.F. )

			_oMemo6   := TMultiget():New(040,60,{|u|if(Pcount()>0,_cMemo6:=u,_cMemo6)},oPanel,500,050,_oFont,,,,,.T.,,,,,,.t.)

			_oRadT6:disable()
			CpLoT6:disable()
			_oRadT6:refresh()
			CpLoT6:refresh()

			InicV6(_cLinha)

		endif
	Endif

	ACTIVATE DIALOG oDlg CENTERED

Return


//Inicialização dos valores nos campos
Static Function InicVal(_cRLi)
	IF _cUserID $ _cEstH0	
		if _cRLi = '000'
			//Inicialização das variáveis WPL
			ZAU->(DbSetOrder(3))
			if ZAU->(MsSeek(FWxfilial('ZAU')+'000'))
				VlLoW0 := ZAU->ZAU_NUM
				_oRadW0:SetOption(1)					
			endif
		else
			_oRadW0:disable()
		endif	
	ENDIF

	if _cRLi = '001'
		//Inicialização das variáveis WPL
		ZAU->(DbSetOrder(3))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'001'))
			VlLoW1 := ZAU->ZAU_NUM
			_oRadW1:SetOption(1)					
		endif
	else
		_oRadW1:disable()
	endif	

	if _cRLi = '003'

		ZAU->(DbSetOrder(3))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'003'))
			VlLoW3 := ZAU->ZAU_NUM
			_oRadW3:SetOption(1)
		Endif

	else
		_oRadW3:disable()
	endif

	if _cRLi = '005'
		//Inicialização das variáveis WPL
		ZAU->(DbSetOrder(3))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'005'))
			VlLoW5 := ZAU->ZAU_NUM
			_oRadW5:SetOption(1)					
		endif
	else
		_oRadW5:disable()
	endif

	if _cRLi = '006'
		//Inicialização das variáveis WPL
		ZAU->(DbSetOrder(3))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'006'))
			VlLoW6 := ZAU->ZAU_NUM
			_oRadW6:SetOption(1)					
		endif
	else
		_oRadW6:disable()
	endif		

	if _cRLi = '002'
		//Inicialização das variáveis testeira

		ZAU->(DbSetOrder(4))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'002'))
			VlLoT2 := ZAU->ZAU_NUM
			_oRadT2:SetOption(1)
		endif
	else
		_oRadT2:disable()
	Endif

	if _cRLi = '004'
		ZAU->(DbSetOrder(4))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'004'))
			VlLoT4 := ZAU->ZAU_NUM
			_oRadT4:SetOption(1)					
		endif
	Else
		_oRadT4:disable()
	endif	

	//desabilita os botões da testeira na linha3
	_oRadT1:disable()
	CpLoT1:disable()
	_oRadT3:disable()
	CpLoT3:disable()

	_oRadW1:refresh()
	_oRadW3:refresh()

	_oRadT1:refresh()
	_oRadT2:refresh()
	_oRadT3:refresh()
	_oRadT4:refresh()

	CpLoW1:refresh()
	CpLoW3:refresh()
return

//Inicialização dos valores nos campos
Static Function InicV0(_cRLi)

	if _cRLi = '000'
		//Inicialização das variáveis WPL
		ZAU->(DbSetOrder(3))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'000'))
			VlLoW0 := ZAU->ZAU_NUM
			_oRadW0:SetOption(1)					
		endif
	else
		_oRadW0:disable()
	endif

	//desabilita os botões da testeira na linha3
	_oRadW0:refresh()

return

Static Function InicV1(_cRLi)

	if _cRLi = '001'
		//Inicialização das variáveis WPL
		ZAU->(DbSetOrder(3))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'001'))
			VlLoW1 := ZAU->ZAU_NUM
			_oRadW1:SetOption(1)					
		endif
	else
		_oRadW1:disable()
	endif	

	//desabilita os botões da testeira na linha3
	_oRadW1:refresh()

return

Static Function InicV2(_cRLi)

	if _cRLi = '002'
		//Inicialização das variáveis WPL
		ZAU->(DbSetOrder(4))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'002'))
			VlLoT2 := ZAU->ZAU_NUM
			_oRadT2:SetOption(1)				
		endif
	else
		_oRadT2:disable()
	endif	

	_oRadT2:refresh()

return

Static Function InicV3(_cRLi)

	if _cRLi = '003'
		//Inicialização das variáveis WPL
		ZAU->(DbSetOrder(3))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'003'))
			VlLoW3 := ZAU->ZAU_NUM
			_oRadW3:SetOption(1)			
		endif
	else
		_oRadW3:disable()
	endif	

	_oRadW3:refresh()

return

Static Function InicV4(_cRLi)

	if _cRLi = '004'
		//Inicialização das variáveis WPL
		ZAU->(DbSetOrder(4))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'004'))
			VlLoT4 := ZAU->ZAU_NUM
			_oRadT4:SetOption(1)			
		endif
	else
		_oRadT4:disable()
	endif	

	_oRadT4:refresh()

return

Static Function InicV5(_cRLi)

	if _cRLi = '005'
		//Inicialização das variáveis WPL
		ZAU->(DbSetOrder(3))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'005'))
			VlLoW5 := ZAU->ZAU_NUM
			_oRadW5:SetOption(1)			
		endif
	else
		_oRadW5:disable()
	endif	

	_oRadW5:refresh()

return

Static Function InicV6(_cRLi)

	if _cRLi = '006'
		//Inicialização das variáveis WPL
		ZAU->(DbSetOrder(3))
		if ZAU->(MsSeek(FWxfilial('ZAU')+'006'))
			VlLoW6 := ZAU->ZAU_NUM
			_oRadW6:SetOption(1)					
		endif
	else
		_oRadW6:disable()
	endif	

	//desabilita os botões da testeira na linha3
	_oRadW6:refresh()
return
//Atualização dos valores de tela
Static Function ValTela()
	//Linha de teste
	_cMemo0 := ''

	//WPL
	ZAU->(DbSetOrder(3))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'000'))
		_cMemo0 += AtuMW()
	endif

	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'000'))
		_cMemo0 += AtuMT()
	endif

	if empty(_cMemo0)
		_cMemo0 :='[ LINHA OCIOSA ]'
	endif

	//Linha1
	_cMemo1 := ''

	//WPL
	ZAU->(DbSetOrder(3))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'001'))
		_cMemo1 += AtuMW()
	endif

	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'001'))
		_cMemo1 += AtuMT()
	endif

	if empty(_cMemo1)
		_cMemo1 :='[ LINHA OCIOSA ]'
	endif

	//Linha2
	_cMemo2 := ''

	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'002'))
		_cMemo2 += AtuMT()
	endif

	if empty(_cMemo2)
		_cMemo2 :='[ LINHA OCIOSA ]'
	endif

	//Linha3
	_cMemo3 := ''

	//WPL
	ZAU->(DbSetOrder(3))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'003'))
		_cMemo3 += AtuMW()
	endif
	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'003'))
		_cMemo3 += AtuMT()
	endif

	if empty(_cMemo3)
		_cMemo3 :='[ LINHA OCIOSA ]'
	endif

	//Linha4
	_cMemo4 := ''

	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'004'))
		_cMemo4 += AtuMT()
	endif

	if empty(_cMemo4)
		_cMemo4 :='[ LINHA OCIOSA ]'
	endif

	//Linha5
	_cMemo5 := ''

	//WPL
	ZAU->(DbSetOrder(3))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'005'))
		_cMemo5 += AtuMW()
	endif

	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'005'))
		_cMemo5 += AtuMT()
	endif

	if empty(_cMemo5)
		_cMemo5 :='[ LINHA OCIOSA ]'
	endif

	//Linha6
	_cMemo6 := ''

	//WPL
	ZAU->(DbSetOrder(3))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'006'))
		_cMemo6 += AtuMW()
	endif

	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'006'))
		_cMemo6 += AtuMT()
	endif

	if empty(_cMemo6)
		_cMemo6 :='[ LINHA OCIOSA ]'
	endif

	IF _cUserID $ _cEstH0
		_oMemo0:refresh()
	ENDIF
	_oMemo1:refresh()
	_oMemo2:refresh()
	_oMemo3:refresh()
	_oMemo4:refresh()
	_oMemo5:refresh()
	oDlg:Refresh()

return
//Atualização dos valores de tela
Static Function ValT0()

	//Linha de testes
	_cMemo0 := ''

	//WPL
	ZAU->(DbSetOrder(3))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'000'))
		_cMemo0 += AtuMW()
	endif

	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'000'))
		_cMemo0 += AtuMT()
	endif

	if empty(_cMemo0)
		_cMemo0 :='[ LINHA OCIOSA ]'
	endif

	_oMemo0:refresh()
	oDlg:Refresh()

return

Static Function ValT1()

	//Linha1
	_cMemo1 := ''

	//WPL
	ZAU->(DbSetOrder(3))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'001'))
		_cMemo1 += AtuMW()
	endif

	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'001'))
		_cMemo1 += AtuMT()
	endif

	if empty(_cMemo1)
		_cMemo1 :='[ LINHA OCIOSA ]'
	endif

	_oMemo1:refresh()
	oDlg:Refresh()
return

Static Function ValT2()

	_cMemo2 := ''

	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'002'))
		_cMemo2 += AtuMT()
	endif

	if empty(_cMemo2)
		_cMemo2 :='[ LINHA OCIOSA ]'
	endif

	_oMemo2:refresh()
	oDlg:Refresh()

return

Static Function ValT3()

	//Linha3
	_cMemo3 := ''

	//WPL
	ZAU->(DbSetOrder(3))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'003'))
		_cMemo3 += AtuMW()
	endif
	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'003'))
		_cMemo3 += AtuMT()
	endif

	if empty(_cMemo3)
		_cMemo3 :='[ LINHA OCIOSA ]'
	endif

	_oMemo3:refresh()
	oDlg:Refresh()

return

Static Function ValT4()

	//Linha4
	_cMemo4 := ''

	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'004'))
		_cMemo4 += AtuMT()
	endif

	if empty(_cMemo4)
		_cMemo4 :='[ LINHA OCIOSA ]'
	endif

	_oMemo4:refresh()
	oDlg:Refresh()

return

Static Function ValT5()

	//Linha5
	_cMemo5 := ''

	//WPL
	ZAU->(DbSetOrder(3))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'005'))
		_cMemo5 += AtuMW()
	endif
	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'005'))
		_cMemo5 += AtuMT()
	endif

	if empty(_cMemo5)
		_cMemo5 :='[ LINHA OCIOSA ]'
	endif

	_oMemo5:refresh()
	oDlg:Refresh()

return

Static Function ValT6()

	//Linha6
	_cMemo6 := ''

	//WPL
	ZAU->(DbSetOrder(3))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'006'))
		_cMemo6 += AtuMW()
	endif

	//TESTEIRA
	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+'006'))
		_cMemo6 += AtuMT()
	endif

	if empty(_cMemo6)
		_cMemo6 :='[ LINHA OCIOSA ]'
	endif

	_oMemo6:refresh()
	oDlg:Refresh()
return

//Validação do campo de lote   para WPL
Static Function ValLoW(_linha)
	do case
		case _linha = '000'
		if !empty(VlLoW0)
			_oRadW0:enable()
		endif

		case _linha = '001'
		if !empty(VlLoW1)
			_oRadW1:enable()
		endif

		case _linha = '003'
		if !empty(VlLoW3)
			_oRadW3:enable()
		endif

		case _linha = '005'
		if !empty(VlLoW5)
			_oRadW5:enable()
		endif

		case _linha = '006'
		if !empty(VlLoW6)
			_oRadW6:enable()
		endif
	endcase

	oDlg:refresh()

return .t.

//Validação do campo de lote para testeira
Static Function ValLoT(_linha)
	do case
		case _linha = '002'
		if !empty(VlLoT2)
			_oRadT2:enable()
		endif

		case _linha = '004'
		if !empty(VlLoT4)
			_oRadT4:enable()
		endif
	endcase

	oDlg:refresh()

return .t.

//Opções aglutinadas de RadioButton
Static Function Modos2(_Linha,_Opc)

	Modos(_Linha,'W')

	ZAU->(DbSetOrder(4))
	if ZAU->(MsSeek(FWxfilial('ZAU')+_Linha))//procura pela linha e limpa a testeira
		limpaTesteira(_Linha,'','')
		ZAU->(dbSetOrder(4))//reordena para o indice inicial
		ZAU->(MsSeek(FWxfilial('ZAU')+_Linha))
	endif

	if _Linha = '000'
		_nModoT0 := _nModoW0
		VlLoT0   := VlLoW0
		CpLoT0:disable()
		CpLoT0:refresh()
		_oRadT0:disable()
		_oRadT0:refresh()
	elseif _Linha = '001'
		_nModoT1 := _nModoW1
		VlLoT1   := VlLoW1
		CpLoT1:refresh()
		CpLoT1:disable()
		_oRadT1:disable()
		_oRadT1:refresh()
	elseif _Linha = '003'
		_nModoT3 := _nModoW3
		VlLoT3   := VlLoW3
		CpLoT3:disable()
		CpLoT3:refresh()
		_oRadT3:disable()
		_oRadT3:refresh()
	elseif _Linha = '005'
		_nModoT5 := _nModoW5
		VlLoT5   := VlLoW5
		CpLoT5:disable()
		CpLoT5:refresh()
		_oRadT5:disable()
		_oRadT5:refresh()
	elseif _Linha = '006'
		_nModoT6 := _nModoW6
		VlLoT6   := VlLoW6
		CpLoT6:refresh()
		CpLoT6:disable()
		_oRadT6:disable()
		_oRadT6:refresh()
	endif

	Modos(_Linha,'T')
return


//Opções dos RadioButtons
Static Function Modos(_Linha,_Opc)
	Local _cLote := ""

	do case
		//Linha 000
		case _Linha = '000'
		if _Opc = "W"
			//WPL
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW0))//usa o valor do text field

				_Stat := iif(_nModoW0 = 1,'R',iif(ZAU->ZAU_QRUNI <> 0,'S','A'))				

				if ZAU->ZAU_STATW <> 'E'

					if _nModoW0 = 1//se for produção
						reclock('ZAU',.f.)
						if empty(ZAU->ZAU_LINW)					
							if u_WBiz01(ZAU->ZAU_NUM,3)
								ZAU->ZAU_FLERP := 1
							endif
						endif
						ZAU->ZAU_LINW  := '000'
						ZAU->ZAU_STATW := _Stat
						msunlock()
					else //senão é ociosa
						if !empty(ZAU->ZAU_LINW)
							u_WBiz02(ZAU->ZAU_NUM,3)
							limpaWpl('000',VlLoW0,_Stat)							
							ZAU->(DbSetOrder(1))       
							ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW0))
						endif						 
					endif
				else
					VlLoW0 := space(10)
					CpLoW0:enable()
				endif
			endif
			//Se estiver em produção desabilita o campo da OP
			if _nModoW0 = 1
				CpLoW0:disable()
			else
				CpLoW0:enable()
			endif
		else
			//TESTEIRA
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT0))

				_Stat := iif(_nModoT0 = 1,'R',iif(ZAU->ZAU_QRUNI <> 0,'S','A'))

				if _nModoT0 == 1
					reclock('ZAU',.f.)				
					ZAU->ZAU_LINT  := '000'
					ZAU->ZAU_STATT := _Stat
					msunlock()
				else
					limpaTesteira('000',VlLoT0,_Stat)
					ZAU->(DbSetOrder(1))
					ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT0))
				endif						
			endif
		endif

		//Linha 001
		case _Linha = '001'
		if _Opc = "W"
			//WPL
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW1))//usa o valor do text field

				_Stat := iif(_nModoW1 = 1,'R',iif(ZAU->ZAU_QRUNI <> 0,'S','A'))				

				if ZAU->ZAU_STATW <> 'E'

					if _nModoW1 = 1//se for produção
						reclock('ZAU',.f.)
						if empty(ZAU->ZAU_LINW)							
							if u_WBiz01(ZAU->ZAU_NUM,1)
								ZAU->ZAU_FLERP := 1
							endif
						endif
						ZAU->ZAU_LINW  := '001'
						ZAU->ZAU_STATW := _Stat
						msunlock()
					else //senão é ociosa
						if !empty(ZAU->ZAU_LINW)
							u_WBiz02(ZAU->ZAU_NUM,1)
							limpaWpl('001',VlLoW1,_Stat)
							//ZAU->ZAU_LINW  := ''             
							ZAU->(DbSetOrder(1))       
							ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW1))
						endif      
						//ZAU->(DbSetOrder(1))       
						//ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW1))
						//reclock('ZAU',.f.)
						//ZAU->ZAU_STATW := _Stat
						//msunlock()                  
					endif

				else
					VlLoW1 := space(10)
					CpLoW1:enable()
				endif

			endif

			//Se estiver em produção desabilita o campo da OP
			if _nModoW1 = 1
				CpLoW1:disable()
			else
				CpLoW1:enable()
			endif
		else
			//TESTEIRA
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT1))

				_Stat := iif(_nModoT1 = 1,'R',iif(ZAU->ZAU_QRUNI <> 0,'S','A'))

				//ZAU->ZAU_LINT  := iif(_nModoT1 = 1,'001','')//se for producao coloca a linha,senao limpa
				if _nModoT1 == 1
					reclock('ZAU',.f.)				
					ZAU->ZAU_LINT  := '001'
					ZAU->ZAU_STATT := _Stat
					msunlock()
				else
					limpaTesteira('001',VlLoT1,_Stat)
					ZAU->(DbSetOrder(1))
					ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT1))
				endif
				//ZAU->(DbSetOrder(1))
				//ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT1))
				//ZAU->ZAU_STATT := _Stat
				//msunlock()				
			endif

			//Se estiver em produção desabilita o campo da OP
			//if _nModoT1 = 1
			//	CpLoT1:disable()
			//else
			// CpLoT1:enable()
			//endif
		endif
		
		//Linha 002
		case _Linha = '002'
		if _Opc = 'T'
			//TESTEIRA
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT2))

				_Stat := iif(_nModoT2 = 1,'R',iif(ZAU->ZAU_QRUNI <> 0,'S','A'))

				reclock('ZAU',.f.)
				ZAU->ZAU_LINT  := iif(_nModoT2 = 1,'002','')
				ZAU->ZAU_STATT := _Stat
				msunlock()

			endif

			//Se estiver em produção desabilita o campo do lote
			if _nModoT2 = 1
				CpLoT2:disable()
			else
				CpLoT2:enable()
			endif
		endif
		//Linha 003
		case _Linha = '003'
		if _Opc = 'W'
			//WPL
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW3))

				_Stat := iif(_nModoW3 = 1,'R',iif(ZAU->ZAU_QRUNI <> 0,'S','A'))

				if ZAU->ZAU_STATW <> 'E'

					if _nModoW3 = 1
						reclock('ZAU',.f.)
						if empty(ZAU->ZAU_LINW)						
							if u_WBiz01(ZAU->ZAU_NUM,2)
								ZAU->ZAU_FLERP := 1
							endif
						endif
						ZAU->ZAU_LINW := '003'
						ZAU->ZAU_STATW := _Stat
						msunlock()
					else
						if !empty(ZAU->ZAU_LINW)
							u_WBiz02(ZAU->ZAU_NUM,2)
							limpaWpl('003',VlLoW3,_Stat)
							//ZAU->ZAU_LINW  := ''             
							ZAU->(DbSetOrder(1))
							ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW3))
						endif
						//ZAU->(DbSetOrder(1))
						//ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW3))
						//reclock('ZAU',.f.)
						//ZAU->ZAU_STATW := _Stat
						//msunlock()
					endif

				else
					VlLoW3 := space(10)
					CpLoW3:enable()
				endif
			endif

			//Se estiver em produção desabilita o campo da OP
			if _nModoW3 = 1
				CpLoW3:disable()
			else
				CpLoW3:enable()
			endif
		else
			//TESTEIRA
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT3))

				_Stat := iif(_nModoT3 = 1,'R',iif(ZAU->ZAU_QRUNI <> 0,'S','A'))

				//ZAU->ZAU_LINT  := iif(_nModoT3 = 1,'003','')
				if _nModoT3 == 1
					reclock('ZAU',.f.)
					ZAU->ZAU_LINT := '003'
					ZAU->ZAU_STATT := _Stat
					msunlock()
				else
					limpaTesteira('003',VlLoT3,_Stat)            
					ZAU->(DbSetOrder(1))
					ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT3))				
				endif  
				//ZAU->(DbSetOrder(1))
				//ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT3))				
				//ZAU->ZAU_STATT := _Stat
				//msunlock()				
			endif

			//Se estiver em produção desabilita o campo da OP
			//if _nModoT3 = 1
			//	CpLoT3:disable()
			//else
			//	CpLoT3:enable()
			//endif
		endif
		
		//Linha 004
		case _Linha = '004'
		if _Opc = 'T'
			//TESTEIRA
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAR')+VlLoT4))

				_Stat := iif(_nModoT4 = 1,'R',iif(ZAU->ZAU_QRUNI <> 0,'S','A'))

				reclock('ZAU',.f.)
				ZAU->ZAU_LINT  := iif(_nModoT4 = 1,'004','')
				ZAU->ZAU_STATT := _Stat
				msunlock()

			endif

			//Se estiver em produção desabilita o campo da OP
			if _nModoT4 = 1
				CpLoT4:disable()
			else
				CpLoT4:enable()
			endif
		endif
		
		//Linha 005
		case _Linha = '005'
		if _Opc = "W"			
			//WPL
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW5))//usa o valor do text field

				_Stat := iif(_nModoW5 = 1,'R',iif(ZAU->ZAU_QRUNI <> 0,'S','A'))				

				if ZAU->ZAU_STATW <> 'E'

					if _nModoW5 = 1//se for produção
						reclock('ZAU',.f.)
						if empty(ZAU->ZAU_LINW)					
							if u_WBiz01(ZAU->ZAU_NUM,5)								
								ZAU->ZAU_FLERP := 1								
							endif
						endif
						ZAU->ZAU_LINW  := '005'
						ZAU->ZAU_STATW := _Stat
						msunlock()
						u_WBiz01(ZAU->ZAU_NUM,4)
					else //senão é ociosa
						if !empty(ZAU->ZAU_LINW)
							u_WBiz02(ZAU->ZAU_NUM,5)
							limpaWpl('005',VlLoW5,_Stat)							
							ZAU->(DbSetOrder(1))       
							ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW5))
						endif
						u_WBiz02(ZAU->ZAU_NUM,4)				 
					endif
				else
					VlLoW5 := space(10)
					CpLoW5:enable()
				endif
			endif
			//Se estiver em produção desabilita o campo da OP
			if _nModoW5 = 1
				CpLoW5:disable()
			else
				CpLoW5:enable()
			endif
		else
			//TESTEIRA
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT5))

				_Stat := iif(_nModoT5 = 1,'R',iif(ZAU->ZAU_QRUNI <> 0,'S','A'))

				if _nModoT5 == 1
					reclock('ZAU',.f.)				
					ZAU->ZAU_LINT  := '005'
					ZAU->ZAU_STATT := _Stat
					msunlock()
				else
					limpaTesteira('005',VlLoT5,_Stat)
					ZAU->(DbSetOrder(1))
					ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT5))
				endif						
			endif
		endif	

		//Linha 006
		case _Linha = '006'
		if _Opc = "W"
			//WPL
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW6))//usa o valor do text field

				_Stat := iif(_nModoW6 = 1,'R',iif(ZAU->ZAU_QRUNI <> 0,'S','A'))

				if ZAU->ZAU_STATW <> 'E'

					if _nModoW6 = 1//se for produção
						reclock('ZAU',.f.)
						if empty(ZAU->ZAU_LINW)							
							if u_WBiz01(ZAU->ZAU_NUM,6)
								ZAU->ZAU_FLERP := 1
							endif
						endif
						ZAU->ZAU_LINW  := '006'
						ZAU->ZAU_STATW := _Stat
						msunlock()
					else //senão é ociosa
						if !empty(ZAU->ZAU_LINW)
							u_WBiz02(ZAU->ZAU_NUM,6)
							limpaWpl('006',VlLoW6,_Stat)
							//ZAU->ZAU_LINW  := ''             
							ZAU->(DbSetOrder(1))       
							ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW6))
						endif      
						//ZAU->(DbSetOrder(1))       
						//ZAU->(MsSeek(FWxfilial('ZAU')+VlLoW6))
						//reclock('ZAU',.f.)
						//ZAU->ZAU_STATW := _Stat
						//msunlock()                  
					endif

				else
					VlLoW6 := space(10)
					CpLoW6:enable()
				endif

			endif

			//Se estiver em produção desabilita o campo da OP
			if _nModoW6 = 1
				CpLoW6:disable()
			else
				CpLoW6:enable()
			endif
		else
			//TESTEIRA
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT6))

				_Stat := iif(_nModoT6 = 1,'R',iif(ZAU->ZAU_QRUNI <> 0,'S','A'))

				//ZAU->ZAU_LINT  := iif(_nModoT6 = 1,'006','')//se for producao coloca a linha,senao limpa
				if _nModoT6 == 1
					reclock('ZAU',.f.)				
					ZAU->ZAU_LINT  := '006'
					ZAU->ZAU_STATT := _Stat
					msunlock()
				else
					limpaTesteira('006',VlLoT6,_Stat)
					ZAU->(DbSetOrder(1))
					ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT6))
				endif
				//ZAU->(DbSetOrder(1))
				//ZAU->(MsSeek(FWxfilial('ZAU')+VlLoT6))
				//ZAU->ZAU_STATT := _Stat
				//msunlock()				
			endif

			//Se estiver em produção desabilita o campo da OP
			//if _nModoT6 = 1
			//	CpLoT6:disable()
			//else
			// CpLoT6:enable()
			//endif
		endif	
	endcase

	if _lFOpen .and. _Opc = 'T' .and. (_nModoT1 = 1 .or._nModoT2 = 1 .or._nModoT3 = 1 .or._nModoT4 = 1 .or._nModoT5 = 1 .or._nModoT6 = 1) .and. _Linha <> '000'
		Do Case
			Case _Linha = '001'
				_cLote := VlLoT1
			Case _Linha = '002'
				_cLote := VlLoT2
			Case _Linha = '003'
				_cLote := VlLoT3
			Case _Linha = '004'
				_cLote := VlLoT4
			Case _Linha = '005'
				_cLote := VlLoT5
			Case _Linha = '006'
				_cLote := VlLoT6
		EndCase
		u_dtilog(cFilAnt, "GJF216", "Troca de lote -> " + _cLote + " | Linha -> " + _Linha, "L")
	elseif !_lFOpen .and. _Opc = 'T'
		_lFOpen := .T.
	endif

return

//Funções auxiliares de atualização dos campos memo
Static Function AtuMF()

	Local _cString := ''

	_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+ZAU->ZAU_COD,1)

	if (_cGrupo $ _cGrpMoi)
		_cString :=  '[' + ZAU->ZAU_NUM + ']'  + chr(13) + chr(10)
		_cString += +' ' + alltrim(ZAU->ZAU_DESC) +  chr(13) + chr(10)
		_cString +=  'Receita Moida: ' + chr(13) + chr(10)
		ZAV->(DbSetOrder(2))
		if  ZAV->(MsSeek(FWxfilial('ZAV')+ZAU->ZAU_NUM))
			while ZAV->(!eof()) .and. ZAV->ZAV_FILIAL = FWxfilial('ZAV') .and. ZAV->ZAV_NUM = ZAU->ZAU_NUM
				_cDescRec := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+ZAV->ZAV_COD,1)
				_cString += ZAV->ZAV_ITEM + "   " + alltrim(ZAV->ZAV_COD) + ": " + chr(13) + chr(10)
				_cString +=  alltrim(_cDescRec)  + chr(13) + chr(10)
				_cString += "Previsto: ["  + transform(ZAV->ZAV_QPPESO,'@E 999,999.99') +']'+chr(13) + chr(10)
				_cString += "Realizado:[" + transform(ZAV->ZAV_QRPESO,'@E 999,999.99')  +']'+ chr(13) + chr(10)
				ZAV->(DbSkip())
			enddo
		endif
	else
		_cString := '[' + ZAU->ZAU_NUM + ']'  + chr(13) + chr(10)
		_cString += alltrim(ZAU->ZAU_COD) + ' ' +  chr(13) + chr(10)
		_cString += alltrim(ZAU->ZAU_DESC)  +  chr(13) + chr(10)
		_cString += 'Alocados:  [' + transform(ZAU->ZAU_QTDMP,'@E 999,999.99') + ']' +  chr(13) + chr(10)
		_cString += 'Consumidos:['+transform(ZAU->ZAU_QTDMPC,'@E 999,999.99')+ ']'   + chr(13) + chr(10)

	endif

return _cString

Static Function AtuMW()

	Local _cString := ''

	_cString :=  '  [  WPL        -  LOTE DE PRODUÇÃO N.: ' + ZAU->ZAU_NUM +'  '+ alltrim(ZAU->ZAU_DESC) + '   ]'  + chr(13) + chr(10)
	_cString +=  '  UNIDADES PA: '+ space(10) + 'Previsto:[' + transform(ZAU->ZAU_QPUNI,'@E 999,999') + ']'+ space(10) + 'Realizado:[' + transform(ZAU->ZAU_QRUNI,'@E 999,999') + ']'+ chr(13) + chr(10)

return _cString


Static Function AtuMT()

	Local _cString := ''

	_cString :=  '  [  TESTEIRAS  -  LOTE DE PRODUÇÃO N.: ' + ZAU->ZAU_NUM +'  '+ alltrim(ZAU->ZAU_DESC) + '   ]'  + chr(13) + chr(10)
	_cString +=  '  PREVISAO PA: '+ space(10) + 'Caixas:  [' + transform(ZAU->ZAU_QPCAIX,' @E 999,999') + ']'+ space(10) +' Peso:[' + transform(ZAU->ZAU_QPPESO,'@E 999,999.99') + ']' + chr(13) + chr(10)
	_cString +=  '  REALIZADO PA:'+ space(10) + 'Caixas:  [' + transform(ZAU->ZAU_QRCAIX,' @E 999,999') + ']'+ space(10) +' Peso:[' + transform(ZAU->ZAU_QRPESO,'@E 999,999.99') + ']' + chr(13) + chr(10)

return _cString

//Função para atualizar o status da ZAR
Static Function AtuZAR(_Lote,_Stat)
	ZAR->(DbSetOrder(4))
	if  ZAR->(MsSeek(FWxfilial('ZAR')+_Lote))
		While ZAR->(!Eof()) .and. ZAR->ZAR_FILIAL = FWxfilial('ZAR') .and. ZAR->ZAR_LOTE = _Lote
			if !(ZAR->ZAR_STATUS $ 'R/E')
				reclock('ZAR',.f.)
				ZAR->ZAR_STATUS := _Stat
				msunlock()
			endif
			ZAR->(DbSkip())
		enddo
	endif
return

//Função ativada pelo botão
//para ativação do controle de
//saída de MP da camara
Static Function ContMP()
	Local _cPar := GetMV('SI_MPPORC')

	if _cPar = 'S'
		CpLoF1:disable()
		CpLoF2:disable()
		CpLoF3:disable()
		CpLoF4:disable()
		PutMv('SI_MPPORC','N')
		_cSayPorc := 'Desativado'
	else
		CpLoF1:enable()
		CpLoF2:enable()
		CpLoF3:enable()
		CpLoF4:enable()
		PutMv('SI_MPPORC','S')
		_cSayPorc := 'Ativado'
	endif
	_oSayPorc:SetText(_cSayPorc)
	oDlg:refresh()

return

/*
//Fatiadora/Moida
ZAU->(DbSetOrder(5))
if ZAU->(MsSeek(FWxfilial('ZAU')+'004'))
_cMemo4 += AtuMF()
endif
*/

Static Function reinicia(_linha)

	MsgRun("Aguarde... Reiniciando o serviço...",,{||  resetServ(_linha) })

	alert("Serviço reiniciado com sucesso!")

return

Static Function resetServ(_linha)

	do case
		case _linha == 0 //reinicia a linha de testes

			WaitRunSrv( "taskkill /f /im appserver-PORLIN0.exe" , .T. , "e:\" )
			sleep(10000)
			WaitRunSrv( "net start TotvsProtheusOficialPORLIN0" , .T. , "e:\" )

		case _linha == 1//reinicia a linha 001

			WaitRunSrv( "taskkill /f /im appserver-PORLIN1.exe" , .T. , "e:\" )
			sleep(10000)
			WaitRunSrv( "net start TotvsProtheusOficialPORLIN1" , .T. , "e:\" )

		case _linha == 2//reinicia a linha 002

			WaitRunSrv( "taskkill /f /im appserver-PORLIN2.exe" , .T. , "e:\" )
			sleep(10000)
			WaitRunSrv( "net start TotvsProtheusOficialPORLIN2" , .T. , "e:\" )

		case _linha == 3	//reinicia a linha 003

			WaitRunSrv( "taskkill /f /im appserver-PORLIN3.exe" , .T. , "e:\" )
			sleep(10000)
			WaitRunSrv( "net start TotvsProtheusOficialPORLIN3" , .T. , "e:\" )

		case _linha == 4 //reinicia a linha 004

			WaitRunSrv( "taskkill /f /im appserver-PORLIN4.exe" , .T. , "e:\" )
			sleep(10000)
			WaitRunSrv( "net start TotvsProtheusOficialPORLIN4" , .T. , "e:\" )

		case _linha == 5 //reinicia a linha 005

			WaitRunSrv( "taskkill /f /im appserver-PORLIN5.exe" , .T. , "e:\" )
			sleep(10000)
			WaitRunSrv( "net start TotvsProtheusOficialPORLIN5" , .T. , "e:\" )

	endcase

return

//função destinada a limpeza das linhas da bizerba
Static Function limpaWpl(_line,_lote,_status)

	_cQuery := " SELECT ZAU_NUM
	_cQuery += " FROM  " + retSqlTab('ZAU')
	_cQuery += " WHERE " + retSqlFil('ZAU')
	_cQuery += " AND ZAU_LINT = '" + _line + "' OR ZAU_LINW = '" + _line + "'"
	_cQuery += " AND " + retSqlDel('ZAU')

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	TMP->(dbGoTop())
	while TMP->(!eof())
		ZAU->(dbSetOrder(1))
		if ZAU->(MsSeek(FWxFilial('ZAU') + TMP->ZAU_NUM))
			reclock('ZAU',.f.)                          		
			ZAU->ZAU_LINW := ''
			ZAU->ZAU_LINT := ''                         
			if TMP->ZAU_NUM == _lote
				ZAU->ZAU_STATW := _status
			endif                       		
			msunlock()
		endif
		TMP->(dbSkip())
	enddo

return


//função destinada a limpeza das linhas da testeira
Static Function limpaTesteira(_line,_lote,_status)

	_cQuery2 := " SELECT ZAU_NUM
	_cQuery2 += " FROM  " + retSqlTab('ZAU')
	_cQuery2 += " WHERE " + retSqlFil('ZAU')
	_cQuery2 += " AND ZAU_LINT = '" + _line + "'
	_cQuery2 += " AND " + retSqlDel('ZAU')

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"

	TMP2->(dbGoTop())
	while TMP2->(!eof())
		ZAU->(dbSetOrder(1))
		if ZAU->(MsSeek(FWxFilial('ZAU') + TMP2->ZAU_NUM))
			reclock('ZAU',.f.)		
			ZAU->ZAU_LINT := ''
			if TMP2->ZAU_NUM == _lote
				ZAU->ZAU_STATT := _status		
			endif
			msunlock()
		endif
		TMP2->(dbSkip())
	enddo

return
