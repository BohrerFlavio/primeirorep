#INCLUDE 'protheus.ch'
#INCLUDE "TOPCONN.CH"
/*
Este Ponto de Entrada permite adicionar opções ao Menu.
Programa Fonte
GPEA010.PRX; GPEA265.PRX; TRMA100.PRW
*/

User Function GPE10MENU()
aAdd(aRotina, { "Líder", "u_ob_lider", 0, 7, 0, Nil })
Return(Nil)

user function ob_lider()
Private _nOpca := 0
Private oLider
Private oLider2 
private _cLider  := SRA->RA_LIDER
Private _cNomeLid:= UsrRetName(SRA->RA_LIDER)
private _cLider2 := SRA->RA_LIDER2
Private _cNomeL2 := UsrRetName(SRA->RA_LIDER2)
private oDlg

DEFINE MSDIALOG oDlg TITLE "Alteração de líder" From 9,0 To 140,450 pixel //OF oMainWnd  pixel

@ 15 ,10 Say "Líder 1" FONT oDlg:oFont PIXEL Of oDlg
@ 15 ,50 MSGET oLider var _cLider size 040,010 OF oDlg PIXEL valid (lValInf().or.empty(_cLider)) PICTURE "@E" F3 "ZBE"
@ 15 ,100 Say _cNomeLid FONT oDlg:oFont PIXEL Of oDlg 

@ 30 ,10 Say "Líder 2" FONT oDlg:oFont PIXEL Of oDlg
@ 30 ,50 MSGET oLider2 var _cLider2 size 040,010 OF oDlg PIXEL valid (lValInf2().or.empty(_cLider2)) PICTURE "@E" F3 "ZBE"
@ 30 ,100 Say _cNomeL2 FONT oDlg:oFont PIXEL Of oDlg 
	
DEFINE SBUTTON FROM 50,080  TYPE 1 ACTION (_nOpca := 1,oDlg:End() )  ENABLE OF oDlg
DEFINE SBUTTON FROM 50,120  TYPE 2 ACTION (_nOpca := 2,oDlg:End()) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED

if _nOpca == 1
	DbSelectArea("SRA")
	RecLock("SRA",.F.)
	SRA->RA_LIDER  := _cLider
	SRA->RA_LIDER2 := _cLider2
	MsUnlock()
endif
return


static functio lValInf()
Local _lRet := .T.
if empty(_cLider)
	_cNomeLid:= space(30)
else
	DbSelectArea('ZBE')
	DbSetOrder(1)
	if !dbSeek(xFilial('ZBE')+ _cLider,.T.)
		_lRet := .F.
		MsgAlert("Lider inválido, verifique.")
	else
		if !ZBE->ZBE_ATIVO == "1"
			_lRet := .F.
			MsgAlert("Lider desativado, verifique.")
		endif
	endif
	if _lRet
		_cNomeLid:= UsrRetName(_cLider)
		//_nOpca := 1
		//oDlg:End()
	endif
endif
return(_lRet)

static functio lValInf2()
Local _lRet := .T.
if empty(_cLider2)
	_cNomeL2:= space(30)
else
	DbSelectArea('ZBE')
	DbSetOrder(1)
	if !dbSeek(xFilial('ZBE')+ _cLider2,.T.)
		_lRet := .F.
		MsgAlert("Lider inválido, verifique.")
	else
		if !ZBE->ZBE_ATIVO == "1"
			_lRet := .F.
			MsgAlert("Lider desativado, verifique.")
		endif
	endif
	if _lRet
		_cNomeL2:= UsrRetName(_cLider2)
		//_nOpca := 1
		//oDlg:End()
	endif
endif
return(_lRet)
