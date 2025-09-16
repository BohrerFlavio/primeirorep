#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"


/****************************************
Controle de horarios - regas
Data: 10/03/2018
Autor: Divair Zarpelon
****************************************/
User Function ZD0_reg()
	Private cCadastro := "regras para controle de horarios"
	Private aRotina   := { }
	Private _aCores   := {}
	private aCabed    := {}
	private aCabec    := {}
	private oCheck    := LoadBitmap( GetResources(), "LBOK" )
	private oNoCheck  := LoadBitmap( GetResources(), "LBNO" )
	private oGreen    := LoadBitmap( GetResources(), "BR_VERDE")
	private oYellow	  := LoadBitmap( GetResources(), "BR_AMARELO")
	private oTFont2   := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
	private nTamBtn   := 50
	private cPath	  := AllTrim(GetTempPath())
	private cAlExc    := GetNextAlias()
	private cArq      := ""
	private _cSay2    := ""
	private oGDF
	private _oSay2


	private cPerPo:= Alltrim(GetMv("MV_PONMES"))
	private _dDPIni := stod(left(cPerPo,8))
	private _dDPFim := stod(right(cPerPo,8))


	aAdd(_aCores, { "empty(ZD0_STATUS)"        ,'BR_VERDE'})
	aAdd(_aCores, { "Alltrim(ZD0_STATUS)=='1'" ,'BR_VERMELHO'})
	aAdd(_aCores, { "Alltrim(ZD0_STATUS)=='2'" ,'BR_AZUL'})



	cPerg :=  "ZD0_RE"
	Pergunte(cPerg,.T.)
	ValidPerg()

	AADD(aRotina, { "Pesquisar"       , "AxPesqui"   , 0, 1 })           
	AADD(aRotina, { "Visualizar"      , "AxVisual"   , 0, 2 })
	AADD(aRotina, { "Incluir"         , "u__incZD0"  , 0, 3 })
	AADD(aRotina, { "Alterar"         , "u__altZD0" , 0, 4 })
	AADD(aRotina, { "Excluir"         , "u__delZD0"  , 0, 6 })
	AADD(aRotina, { "Excecoes"        , "u__regZD0" , 0, 7 })
	AADD(aRotina, { "Resumo Excecoes" , "u__exExl2" , 0, 8 })
	//aAdd(aRotina, { "Legenda"         , "u__ZD0Leg"  , 0, 10 })

	Dbselectarea("ZD0")
	Set Filter To DTOS(ZD0->ZD0_DTAREF) >= DTOS(MV_PAR01) .AND. DTOS(ZD0->ZD0_DTAREF) <= DTOS(MV_PAR02) .AND. ZD0_CC >= MV_PAR03 .AND. ZD0_CC <= MV_PAR04

	MBrowse( 06, 01, 22, 75,"ZD0",,,,,2, _aCores)

	Set Filter To

Return(.T.)


user function _ZD0Leg()
	BrwLegenda (cCadastro, "Legenda", {{"BR_VERDE",    "Inserido sem regra"},;
	{"BR_VERMELHO", "Periodo Fechado"},;
	{"BR_AZUL",     "com excecoes"}})
Return()



/********************
Inclusao ZD0
********************/

user function _incZD0(cAlias,nReg,nOpc)

	nOpc := AxInclui(cAlias,nReg,nOpc,,,,"u_ob_zd0tOK()",)


return

user function ob_zd0tOK()
	Local _lRet := .T.
	if Inclui
		_lRet := Existe(M->ZD0_CC, M->ZD0_TURNO, M->ZD0_DTAREF)
		if !_lRet
			MsgAlert("Atenção!!! Já existe cadastro de regra para essa data, centro de custo e turno.")
		endif
	endif
return(_lRet)


static function Existe(_cCc, _cTurno, _dDtRef)
	Local _cQuery := ""
	Local _nCount := 0
	_cQuery := " SELECT COUNT(*) AS CONT "
	_cQuery += " FROM " + RETSQLNAME ("ZD0") +" AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+_cCc+"' AND ZD0_TURNO = '"+_cTurno+"' "
	_cQuery += " AND ZD0_DTAREF = '"+dtos(_dDtRef)+"' "

	tcquery _cQuery new alias _trbc

	do while !_trbc->(eof())
		_nCount := _trbc->CONT
		dbSelectArea("_trbc")
		dbSkip()
	enddo
	dbSelectArea("_trbc")
	_trbc->(DbCloseArea())

return(_nCount == 0)

/********************
Alteração ZD0
********************/
user function _altZD0()
	if ZD0->ZD0_STATUS == "1"
		MsgAlert("Registro não pode ser alterado")
	else
		axAltera("ZD0", ZD0->(Recno()), 4)
	endif
return


/*******************
excluir ZD0
********************/
User Function _delZD0()

	private _dDPIni := stod(left(cPerPo,8))
	private _dDPFim := stod(right(cPerPo,8))


	if dtos(ZD0->ZD0_DTAREF) >= DTOS(_dDPIni) .AND. dtos(ZD0->ZD0_DTAREF) <= DTOS(_dDPFim)
		if MsgYesNo("Deseja excluir o registro e a geração da regra")

			DbSelectarea('ZD1')
			dbSetOrder(1)
			dbseek(xFilial('ZD1')+ZD0->ZD0_COD,.F.)
			while !Eof() .and.  ZD0->ZD0_COD = ZD1->ZD1_COD
				RecLock("ZD1",.F.)
				DbDelete()
				MsUnlock()
				dbskip()
			Enddo
			RecLock("ZD0",.F.,.T.)
			DbDelete()
			MsUnlock()
		endif
	else
		MsgAlert("<b>EXCLUSAO NAO PERMITIDA</b><br>Data do registro fora do periodo do ponto.", "Atenção")
	endif
return



/**************************
Pergunta
***************************/
Static Function ValidPerg()
	Local i
	Local j
	cAlias := Alias()
	aRegs  :={}

	AADD(aRegs,{cPerg,"01","Data de         ?","Data de            ?","Data de            ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Data ate        ?","Data Ate           ?","Data ate           ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","C. Custo de     ?","C. Custo de        ?","C. custo de        ?","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CTT",""})
	AADD(aRegs,{cPerg,"04","C. Custo ate    ?","C. Custo ate       ?","C. custo ate       ?","mv_ch4","C",09,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CTT",""})

	DbSelectArea("SX1")
	DbSetOrder(1)
	For i:=1 to Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j<=Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	DbSelectArea(cAlias)
Return

/**************************
Geracao das execoes
***************************/
user function _regZD0()
	local _cQuery:= ''
	Local oGrpAcoes
	Local oBtnConf
	Local oBtnLimp
	Local oBtnCanc
	Local aArea := GetArea()

	Private nJanLarg := 0800
	Private nJanAltu := 0500
	private aCabec  := {}
	private aCabBKP := {}
	private cGetPesq := Space(100)
	private _nOpc := 0
	Private _dDTAINI := ctod('//')

	private aIteTip := {;
	"Segunda ("+dtoc(ZD0->ZD0_DATA2)+")",;
	"Terça ("+dtoc(ZD0->ZD0_DATA3)+")",;
	"Quarta ("+dtoc(ZD0->ZD0_DATA4)+")",;
	"Quinta ("+dtoc(ZD0->ZD0_DATA5)+")",;
	"Sexta ("+dtoc(ZD0->ZD0_DATA6)+")",;
	"Sábado ("+dtoc(ZD0->ZD0_DATA7)+")",;
	}

	private cCmbTip := aIteTip[1]

	Private cTit := 'Processando'
	Private cMsg := 'Aguarde, processando a rotina'


	Define msdialog oDlgi title "Mes/ano" From 0,0 TO 150 ,240 of oMainWnd pixel

	@ 005,008 SAY "Data" SIZE 090,010 COLOR CLR_BLACK OF oDlgi PIXEL
	@ 015,008 MSCOMBOBOX oCmbTip VAR  cCmbTip ITEMS aIteTip       SIZE 100, 010 OF oDlgi PIXEL

	@ 040,060 BUTTON oBtnCf PROMPT "&Ok" SIZE 50, 013 OF oDlgi ACTION oDlgi:End()    PIXEL

	//set filter to

	ACTIVATE DIALOG oDlgi CENTERED


	Private aBkpRot := aClone(aRotina)


	aRotina := {{ "Pesquisar"      , "AxPesqui" ,0, 1 , 0,NIL},;  //"Pesquisar"
	{ "Visualizar" , "AxVisual" ,0, 2 , 0,NIL},;  //"Visualizar"
	{ "Incluir"    , "u__incZD1" ,0, 3 , 0,NIL},;  //"Incluir"
	{ "Alterar"    , "AxAltera" ,0, 4 , 0,NIL},;  //"Alterar"
	{ "Excluir"    , "AxDeleta" ,0, 5 , 0,NIL}}	 //"Excluir"

	cCadastro := "Exeções"

	DbSelectArea('ZD1')
	if left(cCmbTip,3) == 'Seg'
		set filter to ZD0->ZD0_COD == ZD1->ZD1_COD .AND. ZD1->ZD1_DATA == ZD0->ZD0_DATA2
		_dDTAINI := ZD0->ZD0_DATA2
	endif
	if left(cCmbTip,3) == 'Ter'
		set filter to ZD0->ZD0_COD == ZD1->ZD1_COD .AND. ZD1->ZD1_DATA == ZD0->ZD0_DATA3
		_dDTAINI := ZD0->ZD0_DATA3
	endif
	if left(cCmbTip,3) == 'Qua'
		set filter to ZD0->ZD0_COD == ZD1->ZD1_COD .AND. ZD1->ZD1_DATA == ZD0->ZD0_DATA4
		_dDTAINI := ZD0->ZD0_DATA4
	endif
	if left(cCmbTip,3) == 'Qui'
		set filter to ZD0->ZD0_COD == ZD1->ZD1_COD .AND. ZD1->ZD1_DATA == ZD0->ZD0_DATA5
		_dDTAINI := ZD0->ZD0_DATA5
	endif
	if left(cCmbTip,3) == 'Sex'
		set filter to ZD0->ZD0_COD == ZD1->ZD1_COD .AND. ZD1->ZD1_DATA == ZD0->ZD0_DATA6
		_dDTAINI := ZD0->ZD0_DATA6
	endif
	if left(cCmbTip,3) == 'Sáb'
		set filter to ZD0->ZD0_COD == ZD1->ZD1_COD .AND. ZD1->ZD1_DATA == ZD0->ZD0_DATA7
		_dDTAINI := ZD0->ZD0_DATA7
	endif


	MBrowse( 06, 01, 22, 75,"ZD1",,,,,2,)



	RestArea(aArea)
	aRotina := aClone(aBkpRot)

	Dbselectarea("ZD0")
Return()


/********************
Inclusao ZD1
********************/

user function _incZD1(cAlias,nReg,nOpc)

	nOpc := AxInclui(cAlias,nReg,nOpc,,,,,)
	if  nOpc == 1
		RecLock("ZD0",.F.)
		ZD0->ZD0_STATUS := '2'
		MsUnlock()
	endif



return




//funçao substituida pela _regZD0()
static function  _regZD02()

	FWMsgRun(, {|oSay| _Process( oSay ) }, "Processando", "Efetuando Carga..." )


	DEFINE MSDIALOG oDlgEspe TITLE "Processamento" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Pesquisar
	@ 003, 003 GROUP oGrpPesqui TO 025, (nJanLarg/2)-3 PROMPT "Pesquisar: "	OF oDlgEspe COLOR 0, 16777215 PIXEL
	@ 010, 006 MSGET oGetPesq VAR cGetPesq SIZE (nJanLarg/2)-12, 010 OF oDlgEspe COLORS 0, 16777215     VALID (fVldPesq()) PIXEL

	//Dados
	@ 028, 003 GROUP oGrpDados TO (nJanAltu/2)-28, (nJanLarg/2)-3 PROMPT "Dados: "	OF oDlgEspe COLOR 0, 16777215 PIXEL
	@ 035, 006 LISTBOX oCabec FIELDS HEADER '','','Matricula','Nome','Filial', 'Observação' FIELDSIZES 40,35,35 SIZE 	(nJanLarg/2)-10, (nJanAltu/2)-80 OF oDlgEspe PIXEL
	oCabec:SetArray(aCabec)
	oCabec:bLine:= {|| {If(aCabec[oCabec:nAt,1],oCheck,oNoCheck),If(aCabec[oCabec:nAt,2],oGreen,oYellow),aCabec[oCabec:nAt,3],aCabec[oCabec:nAt,4],aCabec[oCabec:nAt,5], aCabec[oCabec:nAt,6]}}
	oCabec:bLDblClick := {|| aCabec[oCabec:nAt][1] := !aCabec[oCabec:nAt][1],atuAr(),oCabec:DrawSelect(),atullab()}


	@ (nJanAltu/2)-40, 005 SAY _oSay2 var _cSay2 size 200,007 of oDlgEspe PIXEL  FONT oTFont2 COLOR CLR_BLUE
	atullab()
	//Populando os dados da MsNewGetDados
	//fPopula()

	//Ações
	@ (nJanAltu/2)-25, 003 GROUP oGrpAcoes TO (nJanAltu/2)-3, (nJanLarg/2)-3 PROMPT ""	OF oDlgEspe COLOR 0, 16777215 PIXEL


	@ (nJanAltu/2)-23, 005 BITMAP RESNAME "BR_AMARELO" OF oDlgEspe SIZE 20,10 PIXEL NOBORDER
	@ (nJanAltu/2)-23, 015 SAY 'Com regra' OF oDlgEspe PIXEL

	@ (nJanAltu/2)-14, 005 BITMAP RESNAME "BR_VERDE" OF oDlgEspe SIZE 20,10 PIXEL NOBORDER
	@ (nJanAltu/2)-14, 015 SAY 'Sem regras' OF oDlgEspe PIXEL



	@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnCanc PROMPT "Sair"           SIZE nTamBtn, 013 OF oDlgEspe ACTION(_nOpc:= 0,oDlgEspe:End()) pixel
	@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Mostra todos"   SIZE nTamBtn, 013 OF oDlgEspe ACTION(cGetPesq := Space(100),fVldPesq(),oGetPesq:SetFocus())     PIXEL
	@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*3)+12) BUTTON oBtnConf PROMPT "Processar"      SIZE nTamBtn, 013 OF oDlgEspe ACTION(cGetPesq := Space(100),fVldPesq(),fConfirm())     PIXEL
	@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*4)+18) BUTTON oBtnCanc PROMPT "Inverte Sel"    SIZE nTamBtn, 013 OF oDlgEspe ACTION(fMarcAll()) pixel
	@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*5)+22) BUTTON oBtnCanc PROMPT "Desmarca tudo"  SIZE nTamBtn, 013 OF oDlgEspe ACTION(fDesMar()) pixel
	@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*6)+25) BUTTON oBtnCanc PROMPT "Filtra Marcados" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fFilMar()) pixel


	//Ativando a janela
	ACTIVATE MSDIALOG oDlgEspe CENTERED
	if _nOpc == 1

		FWMsgRun(, {|oSay| _grava( oSay ) }, cTit, cMsg )


	endif

return


static function atullab()
	local nMar := 0
	local ntot  := len (aCabec)
	local _y
	for _y:= 1 to len (aCabec)
		if aCabec[_y][1]
			nMar += 1
		Endif
	next
	_cSay2 := 'Total marcados ('+cvaltochar(nMar) + ') de ('+cvaltochar(ntot)+')'
	_oSay2:Refresh()

return


static function _grava(oSay)
	Local _x
	DbSelectarea('ZD1')
	dbSetOrder(3)
	for _x:= 1 to len(aCabec)

		oSay:cCaption := ("Processando  "+ZD0->ZD0_COD)
		ProcessMessages()

		dbseek(xFilial("ZD1")+aCabec[_x][3]+ DTOS(ZD0->ZD0_DATA),.F.)
		If found()
			If !aCabec[_x][1]
				RecLock("ZD1",.F.)
				DbDelete()
				MsUnlock()
			endif
		else
			If aCabec[_x][1]
				RecLock("ZD1",.T.)
				ZD1_COD    := ZD0->ZD0_COD
				ZD1_MAT    := aCabec[_x][3]
				ZD1_DATA   := ZD0->ZD0_DATA
				ZD1_FILFUN := aCabec[_x][5]
				MsUnlock()
			endif
		endif


	next
return


static function fConfirm()
	local _nd:= 0
	local _st:= ""
	local _y
	
	_nOpc:= 1
	oDlgEspe:End()

	//se todos os funcionarios do centro de custo em questao tiverem regras
	//eu coloco um status diferente
	for _y:= 1 to len (aCabBKP)
		if aCabBKP[_y][1]
			_nd += 1
		endif

	next

	if len (aCabBKP) <> _nd
		_st := '3'
	else
		_st := '2'
	endif

	if _nd = 0
		_st := ''
	endif


	RecLock("ZD0",.F.)
	ZD0->ZD0_STATUS := _st
	MsUnlock()


return


/*---------------------------------------------------------------------*
| Func:  fVldPesq                                                     |
| Autor: Divair                                                |
| Data:  12/03/2018                                                   |
| Desc:  Função que valida o campo digitado                           |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
Static Function fVldPesq()
	Local lRet := .T.

	//Se tiver apóstrofo ou porcentagem, a pesquisa não pode prosseguir
	If "'" $ cGetPesq .Or. "%" $ cGetPesq
		lRet := .F.
		MsgAlert("<b>Pesquisa inválida!</b><br>A pesquisa não pode ter <b>'</b> ou <b>%</b>.", "Atenção")
	EndIf

	//Se houver retorno, atualiza grid
	If lRet
		fPopula()
	EndIf
	atullab()
Return lRet


/*---------------------------------------------------------------------*
| Func:  fPopula                                                      |
| Autor: Divair                                                       |
| Data:  12/03/2018                                                   |
| Desc:  Função que valida o campo digitado                           |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
Static Function fPopula()
	local _y
	aCabec := {}

	for _y:= 1 to len (aCabBKP)
		if Alltrim(UPPER(cGetPesq)) $ aCabBKP[_y][4]  .and. Alltrim(UPPER(cGetPesq)) <> ""
			Aadd(aCabec,{aCabBKP[_y][1],aCabBKP[_y][2],aCabBKP[_y][3],aCabBKP[_y][4],aCabBKP[_y][5], aCabBKP[_y][6]})
		Endif
	next

	if len(aCabec) == 0
		aCabec := aclone(aCabBKP)
	endif


	oCabec:SetArray(aCabec)
	oCabec:bLine:= {|| {If(aCabec[oCabec:nAt,1],oCheck,oNoCheck),If(aCabec[oCabec:nAt,2],oGreen,oYellow),aCabec[oCabec:nAt,3],aCabec[oCabec:nAt,4],aCabec[oCabec:nAt,5],aCabec[oCabec:nAt,6]}}
	oCabec:DrawSelect()
	oCabec:Refresh()


return


static function fMarcAll()
	local _y
	aCabec := {}

	for _y:= 1 to len (aCabBKP)
		Aadd(aCabec,{!aCabBKP[_y][1],aCabBKP[_y][2],aCabBKP[_y][3],aCabBKP[_y][4],aCabBKP[_y][5], aCabBKP[_y][6]})
	next

	oCabec:SetArray(aCabec)
	oCabec:bLine:= {|| {If(aCabec[oCabec:nAt,1],oCheck,oNoCheck),If(aCabec[oCabec:nAt,2],oGreen,oYellow),aCabec[oCabec:nAt,3],aCabec[oCabec:nAt,4],aCabec[oCabec:nAt,5],aCabec[oCabec:nAt,6]}}
	oCabec:DrawSelect()
	oCabec:Refresh()
	aCabBKP := aclone(aCabec)

	atullab()

return


static function fDesMar()
	local _y

	aCabec := {}

	for _y:= 1 to len (aCabBKP)
		Aadd(aCabec,{.f.,aCabBKP[_y][2],aCabBKP[_y][3],aCabBKP[_y][4],aCabBKP[_y][5], aCabBKP[_y][6]})
	next

	oCabec:SetArray(aCabec)
	oCabec:bLine:= {|| {If(aCabec[oCabec:nAt,1],oCheck,oNoCheck),If(aCabec[oCabec:nAt,2],oGreen,oYellow),aCabec[oCabec:nAt,3],aCabec[oCabec:nAt,4],aCabec[oCabec:nAt,5],aCabec[oCabec:nAt,6]}}
	oCabec:DrawSelect()
	oCabec:Refresh()
	aCabBKP := aclone(aCabec)

	atullab()

return

static function fFilMar()

	local aLarr  := {}
	local _y


	for _y:= 1 to len (aCabec)
		if aCabec[_y][1]
			Aadd(aLarr,{aCabec[_y][1],aCabec[_y][2],aCabec[_y][3],aCabec[_y][4],aCabec[_y][5], aCabec[_y][6]})
		Endif
	next
	aCabec := aclone(aLarr)
	oCabec:SetArray(aCabec)
	oCabec:bLine:= {|| {If(aCabec[oCabec:nAt,1],oCheck,oNoCheck),If(aCabec[oCabec:nAt,2],oGreen,oYellow),aCabec[oCabec:nAt,3],aCabec[oCabec:nAt,4],aCabec[oCabec:nAt,5],aCabec[oCabec:nAt,6]}}
	oCabec:DrawSelect()
	oCabec:Refresh()



return



static function atuAr()

	local _y
	for _y:= 1 to len (aCabBKP)

		if  aCabBKP[_y][3] == aCabec[oCabec:nAt][3]
			aCabBKP[_y][1] := aCabec[oCabec:nAt][1]
		endif
	next


return


user function dz_retsab(_dData,_n)

	local _cDat:= _dData

	While  DOW(_cDat)  <> _n
		_cDat += 1
	Enddo


return (_cDat)


user function _bBresum()
	private aDet   := {}
	Private aObjects   := {},aPosObj :={}
	Private aSize      := MsAdvSize()
	Private aInfo      := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	AADD(aObjects,{1,030,.T.,.F.,.F.})
	AADD(aObjects,{1,100,.T.,.T.,.F.})
	aPosObj:=MsObjSize(aInfo,aObjects)
	oLayer := FWLayer():new()

	private _aHeader := {}
	private aDet   := {}

	
	//DbSelectArea('SX3')
	//DbSetOrder(2)
	//DbSeek("ZD1_COD")    ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_cod", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("ZD1_DATA")   ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_dta", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("ZD0_DATACP") ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_dtc", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("ZD1_MAT")    ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_mat", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("ZD1_FILFUN") ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_fil", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("RA_NOME")    ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_nom", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("ZD0_CC")     ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_ccc", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("CTT_DESC01") ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_ncc", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("ZD0_TURNO")  ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_turn", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("ZD0_QUANTC") ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_qcom", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("ZD0_LINFC")  ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_lifc", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("ZD0_LSUPC")  ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_lisc", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("ZD0_QUANTH") ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_qhex", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("ZD0_LINFH")  ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_life", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})
	//DbSeek("ZD0_LSUPH")  ; AADD(_aHeader,{ TRIM(x3_titulo), "xx_lise", x3_picture,x3_tamanho, x3_decimal,"",x3_usado, x3_tipo, SX3->X3_f3,  SX3->X3_CONTEXT, SX3->X3_cbox, SX3->X3_relacao, ".t."})

	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD1_COD', 'X3_TITULO'))	, "xx_cod", GetSx3Cache('ZD1_COD', 'X3_PICTURE'),GetSx3Cache('ZD1_COD', 'X3_TAMANHO'), GetSx3Cache('ZD1_COD', 'X3_DECIMAL'),"",GetSx3Cache('ZD1_COD', 'X3_USADO'), GetSx3Cache('ZD1_COD', 'X3_TIPO'), GetSx3Cache('ZD1_COD', 'X3_F3'),  GetSx3Cache('ZD1_COD', 'X3_CONTEXT'), GetSx3Cache('ZD1_COD', 'X3_CBOX'), GetSx3Cache('ZD1_COD', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD1_DATA', 'X3_TITULO'))	, "xx_dta", GetSx3Cache('ZD1_DATA', 'X3_PICTURE'),GetSx3Cache('ZD1_DATA', 'X3_TAMANHO'), GetSx3Cache('ZD1_DATA', 'X3_DECIMAL'),"",GetSx3Cache('ZD1_DATA', 'X3_USADO'), GetSx3Cache('ZD1_DATA', 'X3_TIPO'), GetSx3Cache('ZD1_DATA', 'X3_F3'),  GetSx3Cache('ZD1_DATA', 'X3_CONTEXT'), GetSx3Cache('ZD1_DATA', 'X3_CBOX'), GetSx3Cache('ZD1_DATA', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD0_DATACP', 'X3_TITULO')), "xx_dtc", GetSx3Cache('ZD0_DATACP', 'X3_PICTURE'),GetSx3Cache('ZD0_DATACP', 'X3_TAMANHO'), GetSx3Cache('ZD0_DATACP', 'X3_DECIMAL'),"",GetSx3Cache('ZD0_DATACP', 'X3_USADO'), GetSx3Cache('ZD0_DATACP', 'X3_TIPO'), GetSx3Cache('ZD0_DATACP', 'X3_F3'),  GetSx3Cache('ZD0_DATACP', 'X3_CONTEXT'), GetSx3Cache('ZD0_DATACP', 'X3_CBOX'), GetSx3Cache('ZD0_DATACP', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD1_MAT', 'X3_TITULO'))	, "xx_mat", GetSx3Cache('ZD1_MAT', 'X3_PICTURE'),GetSx3Cache('ZD1_MAT', 'X3_TAMANHO'), GetSx3Cache('ZD1_MAT', 'X3_DECIMAL'),"",GetSx3Cache('ZD1_MAT', 'X3_USADO'), GetSx3Cache('ZD1_MAT', 'X3_TIPO'), GetSx3Cache('ZD1_MAT', 'X3_F3'),  GetSx3Cache('ZD1_MAT', 'X3_CONTEXT'), GetSx3Cache('ZD1_MAT', 'X3_CBOX'), GetSx3Cache('ZD1_MAT', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD1_FILFUN', 'X3_TITULO')), "xx_fil", GetSx3Cache('ZD1_FILFUN', 'X3_PICTURE'),GetSx3Cache('ZD1_FILFUN', 'X3_TAMANHO'), GetSx3Cache('ZD1_FILFUN', 'X3_DECIMAL'),"",GetSx3Cache('ZD1_FILFUN', 'X3_USADO'), GetSx3Cache('ZD1_FILFUN', 'X3_TIPO'), GetSx3Cache('ZD1_FILFUN', 'X3_F3'),  GetSx3Cache('ZD1_FILFUN', 'X3_CONTEXT'), GetSx3Cache('ZD1_FILFUN', 'X3_CBOX'), GetSx3Cache('ZD1_FILFUN', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('RA_NOME', 'X3_TITULO'))	, "xx_nom", GetSx3Cache('RA_NOME', 'X3_PICTURE'),GetSx3Cache('RA_NOME', 'X3_TAMANHO'), GetSx3Cache('RA_NOME', 'X3_DECIMAL'),"",GetSx3Cache('RA_NOME', 'X3_USADO'), GetSx3Cache('RA_NOME', 'X3_TIPO'), GetSx3Cache('RA_NOME', 'X3_F3'),  GetSx3Cache('RA_NOME', 'X3_CONTEXT'), GetSx3Cache('RA_NOME', 'X3_CBOX'), GetSx3Cache('RA_NOME', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD0_CC', 'X3_TITULO'))	, "xx_ccc", GetSx3Cache('ZD0_CC', 'X3_PICTURE'),GetSx3Cache('ZD0_CC', 'X3_TAMANHO'), GetSx3Cache('ZD0_CC', 'X3_DECIMAL'),"",GetSx3Cache('ZD0_CC', 'X3_USADO'), GetSx3Cache('ZD0_CC', 'X3_TIPO'), GetSx3Cache('ZD0_CC', 'X3_F3'),  GetSx3Cache('ZD0_CC', 'X3_CONTEXT'), GetSx3Cache('ZD0_CC', 'X3_CBOX'), GetSx3Cache('ZD0_CC', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('CTT_DESC01', 'X3_TITULO')), "xx_ncc", GetSx3Cache('CTT_DESC01', 'X3_PICTURE'),GetSx3Cache('CTT_DESC01', 'X3_TAMANHO'), GetSx3Cache('CTT_DESC01', 'X3_DECIMAL'),"",GetSx3Cache('CTT_DESC01', 'X3_USADO'), GetSx3Cache('CTT_DESC01', 'X3_TIPO'), GetSx3Cache('CTT_DESC01', 'X3_F3'),  GetSx3Cache('CTT_DESC01', 'X3_CONTEXT'), GetSx3Cache('CTT_DESC01', 'X3_CBOX'), GetSx3Cache('CTT_DESC01', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD0_TURNO', 'X3_TITULO'))	, "xx_turn", GetSx3Cache('ZD0_TURNO', 'X3_PICTURE'),GetSx3Cache('ZD0_TURNO', 'X3_TAMANHO'), GetSx3Cache('ZD0_TURNO', 'X3_DECIMAL'),"",GetSx3Cache('ZD0_TURNO', 'X3_USADO'), GetSx3Cache('ZD0_TURNO', 'X3_TIPO'), GetSx3Cache('ZD0_TURNO', 'X3_F3'),  GetSx3Cache('ZD0_TURNO', 'X3_CONTEXT'), GetSx3Cache('ZD0_TURNO', 'X3_CBOX'), GetSx3Cache('ZD0_TURNO', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD0_QUANTC', 'X3_TITULO')), "xx_qcom", GetSx3Cache('ZD0_QUANTC', 'X3_PICTURE'),GetSx3Cache('ZD0_QUANTC', 'X3_TAMANHO'), GetSx3Cache('ZD0_QUANTC', 'X3_DECIMAL'),"",GetSx3Cache('ZD0_QUANTC', 'X3_USADO'), GetSx3Cache('ZD0_QUANTC', 'X3_TIPO'), GetSx3Cache('ZD0_QUANTC', 'X3_F3'),  GetSx3Cache('ZD0_QUANTC', 'X3_CONTEXT'), GetSx3Cache('ZD0_QUANTC', 'X3_CBOX'), GetSx3Cache('ZD0_QUANTC', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD0_LINFC', 'X3_TITULO'))	, "xx_lifc", GetSx3Cache('ZD0_LINFC', 'X3_PICTURE'),GetSx3Cache('ZD0_LINFC', 'X3_TAMANHO'), GetSx3Cache('ZD0_LINFC', 'X3_DECIMAL'),"",GetSx3Cache('ZD0_LINFC', 'X3_USADO'), GetSx3Cache('ZD0_LINFC', 'X3_TIPO'), GetSx3Cache('ZD0_LINFC', 'X3_F3'),  GetSx3Cache('ZD0_LINFC', 'X3_CONTEXT'), GetSx3Cache('ZD0_LINFC', 'X3_CBOX'), GetSx3Cache('ZD0_LINFC', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD0_LSUPC', 'X3_TITULO'))	, "xx_lisc", GetSx3Cache('ZD0_LSUPC', 'X3_PICTURE'),GetSx3Cache('ZD0_LSUPC', 'X3_TAMANHO'), GetSx3Cache('ZD0_LSUPC', 'X3_DECIMAL'),"",GetSx3Cache('ZD0_LSUPC', 'X3_USADO'), GetSx3Cache('ZD0_LSUPC', 'X3_TIPO'), GetSx3Cache('ZD0_LSUPC', 'X3_F3'),  GetSx3Cache('ZD0_LSUPC', 'X3_CONTEXT'), GetSx3Cache('ZD0_LSUPC', 'X3_CBOX'), GetSx3Cache('ZD0_LSUPC', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD0_QUANTH', 'X3_TITULO')), "xx_qhex", GetSx3Cache('ZD0_QUANTH', 'X3_PICTURE'),GetSx3Cache('ZD0_QUANTH', 'X3_TAMANHO'), GetSx3Cache('ZD0_QUANTH', 'X3_DECIMAL'),"",GetSx3Cache('ZD0_QUANTH', 'X3_USADO'), GetSx3Cache('ZD0_QUANTH', 'X3_TIPO'), GetSx3Cache('ZD0_QUANTH', 'X3_F3'),  GetSx3Cache('ZD0_QUANTH', 'X3_CONTEXT'), GetSx3Cache('ZD0_QUANTH', 'X3_CBOX'), GetSx3Cache('ZD0_QUANTH', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD0_LINFH', 'X3_TITULO'))	, "xx_life", GetSx3Cache('ZD0_LINFH', 'X3_PICTURE'),GetSx3Cache('ZD0_LINFH', 'X3_TAMANHO'), GetSx3Cache('ZD0_LINFH', 'X3_DECIMAL'),"",GetSx3Cache('ZD0_LINFH', 'X3_USADO'), GetSx3Cache('ZD0_LINFH', 'X3_TIPO'), GetSx3Cache('ZD0_LINFH', 'X3_F3'),  GetSx3Cache('ZD0_LINFH', 'X3_CONTEXT'), GetSx3Cache('ZD0_LINFH', 'X3_CBOX'), GetSx3Cache('ZD0_LINFH', 'X3_RELACAO'), ".t."})
	AADD(_aHeader,{ TRIM(GetSx3Cache('ZD0_LSUPH', 'X3_TITULO'))	, "xx_lise", GetSx3Cache('ZD0_LSUPH', 'X3_PICTURE'),GetSx3Cache('ZD0_LSUPH', 'X3_TAMANHO'), GetSx3Cache('ZD0_LSUPH', 'X3_DECIMAL'),"",GetSx3Cache('ZD0_LSUPH', 'X3_USADO'), GetSx3Cache('ZD0_LSUPH', 'X3_TIPO'), GetSx3Cache('ZD0_LSUPH', 'X3_F3'),  GetSx3Cache('ZD0_LSUPH', 'X3_CONTEXT'), GetSx3Cache('ZD0_LSUPH', 'X3_CBOX'), GetSx3Cache('ZD0_LSUPH', 'X3_RELACAO'), ".t."})

	_cMesAn := right("0"+cvaltochar(MONTH(DATE())),2) +"/"+  cvaltochar(YEAR(DATE()))

	Define msdialog oDlgi title "Mes/ano" From 0,0 TO 150 ,240 of oMainWnd pixel
	@ 005,008 SAY "Mes/Ano" SIZE 060,010 COLOR CLR_BLACK OF oDlgi PIXEL
	@ 015,008 GET _cMesAn PICTURE '@R 99/9999' SIZE 40,10 COLOR CLR_BLACK OF oDlgi PIXEL
	@ 040,060 BUTTON oBtnCf PROMPT "&Ok" SIZE 50, 013 OF oDlgi ACTION oDlgi:End()    PIXEL


	ACTIVATE DIALOG oDlgi CENTERED


	Define msdialog oDlg1 title "Resumo" From 0,0 TO aSize[6] ,aSize[5] of oMainWnd pixel


	oLayer:init(oDlg1,.T.)

	//Cria as colunas do Layer
	oLayer:addCollumn('Col01',25,.F.)
	oLayer:addCollumn('Col02',75,.F.)

	//Adiciona Janelas as colunas
	oLayer:addWindow('Col01','C1_Win01','Sabado',100,.T.,.F.,,,)
	oLayer:addWindow('Col02','C1_Win02','Regras',30,.T.,.T.,,,)
	oLayer:addWindow('Col02','C1_Win01','Observacoes',70,.T.,.T.,,,)

	oPanel1 := oLayer:GetWinPanel('Col01','C1_Win01')
	oPanel2 := oLayer:GetWinPanel('Col02','C1_Win02')
	oPanel3 := oLayer:GetWinPanel('Col02','C1_Win01')

	//oLayer:setColSplit('Col01',CONTROL_ALIGN_RIGHT,,})

	oTree := DbTree():New(0,0,oPanel1:nwidth-20,oPanel1:nwidth/2,oPanel1,,,.T.)
	oTree:bChange := {|| populaSC(oTree:GetCargo(),oTree:GetPrompt(.T.))}

	_cQuery := " select ZD0_DATACP,ZD0_DATA,ZD0_COD "
	_cQuery += " from " + RETSQLNAME ("ZD0") +" AS ZD0"
	_cQuery += " WHERE ZD0_DATA between '"+right(_cMesAn,4)+left(_cMesAn,2)+'01'+"' and '"+right(_cMesAn,4)+left(_cMesAn,2)+'31'+"' "
	_cQuery += " AND ZD0.D_E_L_E_T_ = '' "
	_cQuery += " GROUP BY ZD0_DATACP,ZD0_DATA,ZD0_COD"
	_cQuery += " ORDER BY ZD0_DATACP,ZD0_COD "

	TCQUERY _cQuery NEW ALIAS "TRB2"
	TcSetField("TRB2","ZD0_DATACP","D")
	TcSetField("TRB2","ZD0_DATA","D")

	_dPrim := ctod('//')
	_cCarg := "A00000"

	dbSelectArea("TRB2")
	DbGoTop()
	while !eof()
		if dtos(_dPrim)<> dtos(TRB2->ZD0_DATACP)
			_cCarg := soma1(_cCarg)
			oTree:AddItem(dtoc(TRB2->ZD0_DATACP),_cCarg, "S4WB014A" ,,,,1)
			oTree:TreeSeek(_cCarg)

			oTree:AddItem(dtoc(TRB2->ZD0_DATA),TRB2->ZD0_COD, "NOTE" ,,,,2)
			_dPrim := TRB2->ZD0_DATACP

		else
			oTree:TreeSeek(_cCarg)
			oTree:AddItem(dtoc(TRB2->ZD0_DATA),TRB2->ZD0_COD, "NOTE" ,,,,2)
		Endif

		dbskip()
	Enddo
	dbSelectArea("TRB2")
	dbCloseArea()


	Aadd(aDet,{'',ctod('//'),ctod('//'),'','','','','','',0.00,0.00,0.00,0.00,0.00,0.00,.f.})

	oGDF:= MsNewGetDados():New(002, 002,oPanel3:NCLIENTHEIGHT-50, oPanel3:NCLIENTWIDTH/2, GD_UPDATE,/*cLinOk*/,/*cTudoOk*/,/*[cIniCpos]*/,/*aAlt*/,/*[lVazio]*/,Len(aDet),/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oPanel3,_aHeader,aDet)
	oTree:TreeSeek("A00001")
	populaSC("A00001",oTree:GetPrompt(.T.))

	msgalert(oTree:GetPrompt(.T.))

	@ 005, (oPanel2:NCLIENTWIDTH/2)-40 BUTTON oBtnEx PROMPT "Excel" SIZE 30, 013 OF oPanel2 ACTION(FWMsgRun(, {|oSay| _exExcel( oSay ) }, 'Processando', 'Aguarde, gerando excel')) pixel
	@ 020, (oPanel2:NCLIENTWIDTH/2)-40 BUTTON oBtnS  PROMPT "Sair"  SIZE 30, 013 OF oPanel2 ACTION(oDlg1:End())     PIXEL



	ACTIVATE DIALOG oDlg1 CENTERED

return


Static Function C(nTam)
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)


Static Function populaSC(cCod,cDatS)

	local cCC    := space(TamSX3("ZD0_CC")[1])
	local cTurno := space(TamSX3("ZD0_CC")[1])
	local dDta   := ctod('//')
	local cDtaCp := ctod('//')
	local nQComp := 0.00
	local nLinfc := 0.00
	local nLSupc := 0.00
	local nHext  := 0.00
	local nLinfE := 0.00
	local nLSupE := 0.00
	local cPagEX := ""
	local cPagEC := ""

	local ocCod   := nil
	local ocCC    := nil
	local ocTurno := nil
	local odDta   := nil
	local ocDtaCp := nil
	local onQComp := nil
	local onLinfc := nil
	local onLSupc := nil
	local onHext  := nil
	local onLinfE := nil
	local onLSupE := nil
	local ocPagEX := nil
	local ocPagEC := nil

	dbSelectArea('ZD0')
	dBSetOrder(1)
	dbseek(xFilial('ZD0')+cCod,.F.)
	if found()
		cCod   := ZD0->ZD0_COD //space(TamSX3("ZD0_COD")[1])
		cCC    := ZD0->ZD0_CC //space(TamSX3("ZD0_CC")[1])
		cTurno := ZD0->ZD0_TURNO //space(TamSX3("ZD0_CC")[1])
		dDta   := ZD0->ZD0_DATA //dtoc('//')
		cDtaCp := ZD0->ZD0_DATACP //dtoc('//')
		nQComp := ZD0->ZD0_QUANTC //0.00
		nLinfc := ZD0->ZD0_LINFC //0.00
		nLSupc := ZD0->ZD0_LSUPC //0.00
		nHext  := ZD0->ZD0_QUANTH //0.00
		nLinfE := ZD0->ZD0_LINFH //0.00
		nLSupE := ZD0->ZD0_LSUPH //0.00
		cPagEX := ZD0->ZD0_PGHEX //""
		cPagEC := ZD0->ZD0_PGHEFC//""
	else
		cCod := ''
	endif

	oScr1 := TScrollBox():New(oPanel2,05,01,50,(oPanel2:NCLIENTWIDTH/2)-50,.T.,.T.,.T.)

	@ 05, 006  SAY   osCod    PROMPT "Codigo"     SIZE 080, 010 OF oScr1 PIXEL
	@ 05, 035  MSGET ocCod    VAR    cCod         SIZE 060, 010 OF oScr1 PIXEL
	@ 05, 100  SAY   osCC     PROMPT "CC"         SIZE 080, 010 OF oScr1 PIXEL
	@ 05, 120  MSGET ocCC     VAR    cCC          SIZE 140, 010 OF oScr1 PIXEL
	@ 05, 300  SAY   osTurno  PROMPT "Turno"      SIZE 080, 010 OF oScr1 PIXEL
	@ 05, 320  MSGET ocTurno  VAR    cTurno       SIZE 060, 010 OF oScr1 PIXEL

	@ 20, 006  SAY   osDta    PROMPT "Data"       SIZE 080, 010 OF oScr1 PIXEL
	@ 20, 035  MSGET odDta    VAR    dDta         SIZE 060, 010 OF oScr1 PIXEL
	@ 20, 110  SAY   osDtaCp  PROMPT "Sabado"     SIZE 080, 010 OF oScr1 PIXEL
	@ 20, 129  MSGET ocDtaCp  VAR    cDtaCp       SIZE 060, 010 OF oScr1 PIXEL
	@ 20, 220  SAY   osQComp  PROMPT "Quant comp" SIZE 080, 010 OF oScr1 PIXEL
	@ 20, 270  MSGET onQComp  VAR    nQComp       SIZE 020, 010 OF oScr1 PIXEL

	@ 35, 006  SAY   osLinfc  PROMPT "Limite inf comp"  SIZE 080, 010 OF oScr1 PIXEL
	@ 35, 060  MSGET onLinfc  VAR    nLinfc             SIZE 020, 010 OF oScr1 PIXEL
	@ 35, 100  SAY   osLSupc  PROMPT "Limite sup comp"  SIZE 080, 010 OF oScr1 PIXEL
	@ 35, 180  MSGET onLSupc  VAR    nLSupc             SIZE 020, 010 OF oScr1 PIXEL
	@ 35, 250  SAY   osHext  PROMPT "Quant Hex"         SIZE 080, 010 OF oScr1 PIXEL
	@ 35, 280  MSGET onHext  VAR    nHext               SIZE 020, 010 OF oScr1 PIXEL

	@ 50, 006  SAY   osLinfE  PROMPT "Limite inf H.Extras"  SIZE 080, 010 OF oScr1 PIXEL
	@ 50, 070  MSGET onLinfE  VAR    nLinfE                 SIZE 020, 010 OF oScr1 PIXEL
	@ 50, 110  SAY   osLSupE  PROMPT "Limite sup U.Extras"  SIZE 080, 010 OF oScr1 PIXEL
	@ 50, 180  MSGET onLSupE  VAR    nLSupE                 SIZE 020, 010 OF oScr1 PIXEL
	@ 50, 230  SAY   osPagEX  PROMPT "Paga H.extras"        SIZE 080, 010 OF oScr1 PIXEL
	@ 50, 280  MSGET ocPagEX  VAR    cPagEX                 SIZE 020, 010 OF oScr1 PIXEL
	@ 50, 320  SAY   osPagEC  PROMPT "Paga Sup comps"       SIZE 080, 010 OF oScr1 PIXEL
	@ 50, 380  MSGET ocPagEC  VAR    cPagEC                 SIZE 020, 010 OF oScr1 PIXEL

	aDet   := {}
	if cCod <> ''
		fPopudet(cCod,1)
	else
		fPopudet(cDatS,2)
	Endif

	if len(aDet) == 0
		Aadd(aDet,{'',ctod('//'),ctod('//'),'','','','','',0.00,0.00,0.00,0.00,0.00,0.00,.f.})
	endif

	oGDF:aCols := aClone(aDet)
	oGDF:oBrowse:Refresh()
	oGDF:Refresh()

	ocCod:lActive := .f.
	ocCC:lActive := .f.
	ocTurno:lActive := .f.
	odDta:lActive := .f.
	ocDtaCp:lActive := .f.
	onQComp:lActive := .f.
	onLinfc:lActive := .f.
	onLSupc:lActive := .f.
	onHext:lActive := .f.
	onLinfE:lActive := .f.
	onLSupE:lActive := .f.
	ocPagEX:lActive := .f.
	ocPagEC:lActive := .f.


Return

Static Function fPopudet(_ccod,_n)
	//local d:=1
	local _cqry := ''
	_cqry := " select ZD1_COD,ZD1_DATA,ZD0_DATACP,ZD1_MAT,ZD1_FILFUN,RA_NOME,ZD0_CC,CTT_DESC01, "
	_cqry += " ZD0_TURNO,ZD0_QUANTC,ZD0_LINFC,ZD0_LSUPC,ZD0_QUANTH,ZD0_LINFH,ZD0_LSUPH "
	_cqry += " from " + RETSQLNAME ("ZD1") +" AS ZD1"
	_cqry += " inner join " + RETSQLNAME ("ZD0") +" AS ZD0 ON ZD0_COD = ZD1_COD AND ZD0.D_E_L_E_T_ = '' "
	_cqry += " inner join " + RETSQLNAME ("SRA") +" AS SRA ON ZD1.ZD1_MAT = SRA.RA_MAT AND SRA.D_E_L_E_T_ = ''"
	_cqry += " inner join " + RETSQLNAME ("CTT") +" AS CTT ON ZD0.ZD0_CC = CTT.CTT_CUSTO AND CTT.D_E_L_E_T_ = '' "
	_cqry += " WHERE ZD1.D_E_L_E_T_ = '' "
	if _n == 1
		_cqry += " AND ZD1.ZD1_COD = '"+_ccod+"'"
	else
		_cqry += " AND ZD0.ZD0_DATACP = '"+dtos(ctod(_ccod))+"'"
	endif
	_cqry += " ORDER BY ZD1_COD,ZD0_DATACP,ZD1_DATA "

	TCQUERY _cqry NEW ALIAS "TRB3"
	TcSetField("TRB3","ZD0_DATACP","D")
	TcSetField("TRB3","ZD1_DATA","D")

	DbSelectArea("TRB3")
	dbgotop()
	while !Eof()
		Aadd(aDet,{ZD1_COD,ZD1_DATA,ZD0_DATACP,ZD1_MAT,ZD1_FILFUN,RA_NOME,ZD0_CC,CTT_DESC01,ZD0_TURNO,ZD0_QUANTC,ZD0_LINFC,ZD0_LSUPC,ZD0_QUANTH,ZD0_LINFH,ZD0_LSUPH,.f.})

		dbskip()
	Enddo
	DbcloseArea()


return


static function _Process(oSay)


	oSay:cCaption := ('Efetuando limpeza...')
	ProcessMessages()

	_cQuery := "  DELETE " + RETSQLNAME ("ZD0") +" WHERE D_E_L_E_T_ = '*' "
	if TcSqlExec( _cQuery ) <> 0
		MsgAlert("<b>limpeza nao concluida</b><br>Nao consegui realizar a limpeza na tabela.", "Atenção")
	endif


	oSay:cCaption := ('Selecionando registros...')
	ProcessMessages()

	_cQuery := " SELECT RA_CC,RA_TNOTRAB,RA_MAT,RA_NOME,RA_FILIAL, ISNULL(RCM_DESCRI, '') as RCM_DESCRI "
	_cQuery += " FROM " + RETSQLNAME ("SRA") +" AS SRA "
	_cQuery += " LEFT JOIN " + RETSQLNAME ("SR8") +" AS SR8 ON RA_MAT = R8_MAT AND RA_FILIAL = R8_FILIAL "
	_cQuery += " AND ((R8_DATAINI <= '"+DTOS(ZD0->ZD0_DATA)+"' AND R8_DATAFIM >= '"+DTOS(ZD0->ZD0_DATA)+"') "
	_cQuery += " OR (R8_DATAINI <= '"+DTOS(ZD0->ZD0_DATA)+"' AND R8_DATAFIM = '')) "
	_cQuery += " AND SR8.D_E_L_E_T_ = ''"
	_cQuery += " LEFT  JOIN " + RETSQLNAME ("RCM") +" AS RCM ON RCM_TIPO = R8_TIPOAFA AND RCM.D_E_L_E_T_ = '' "
	_cQuery += " where RA_CC = '"+ZD0->ZD0_CC+"' AND RA_TNOTRAB = '"+ZD0->ZD0_TURNO+"' "
	_cQuery += " AND SRA.D_E_L_E_T_ = '' AND RA_DEMISSA = '' "
	_cQuery += " ORDER BY RA_NOME "

	TCQUERY _cQuery NEW ALIAS "TRB2"

	dbSelectArea("TRB2")
	DbGoTop()

	While !EOF()
		DbSelectarea('ZD1')
		dbSetOrder(3)
		dbseek(xFilial("ZD1") + TRB2->RA_MAT + DTOS(ZD0->ZD0_DATA),.F.)

		If found() // se encontrou em coloco uma legenda diferente
			Aadd(aCabec,{.T.,.F.,TRB2->RA_MAT ,TRB2->RA_NOME,TRB2->RA_FILIAL,TRB2->RCM_DESCRI})
		else
			if Alltrim(TRB2->RCM_DESCRI) <> ''  //se tiver alguma observação no RCM eu nao marco
				Aadd(aCabec,{.F.,.T.,TRB2->RA_MAT ,TRB2->RA_NOME,TRB2->RA_FILIAL,TRB2->RCM_DESCRI})
			else
				Aadd(aCabec,{.T.,.T.,TRB2->RA_MAT ,TRB2->RA_NOME,TRB2->RA_FILIAL,TRB2->RCM_DESCRI})
			endif
		endif

		dbSelectArea("TRB2")
		dbskip()
	Enddo
	dbSelectArea("TRB2")
	dbCloseArea()

	if len(aCabec) == 0
		Aadd(aCabec,{.T.,.F.,'' ,'','', ''})
	Endif

	aCabBKP := aclone(aCabec)

return



static function _exExcel( oSay )

	local oExcel := nil
	local _x
	cPlano:="Regras_funcionarios"
	cTitulo:="Detalhamento"

	oExcel := FWMSEXCEL():New()
	oExcel:SetFontSize(8)
	oExcel:SetFont("Arial")

	oExcel:AddworkSheet(cPlano)
	oExcel:AddTable(cPlano,cTitulo)

	oExcel:AddColumn(cPlano,cTitulo,"Regra",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"Data",1,4)
	oExcel:AddColumn(cPlano,cTitulo,"Compensacao",1,4)
	oExcel:AddColumn(cPlano,cTitulo,"Matricula",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"Filial",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"Nome",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"C.Custo",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"Descricao",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"Turno",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"Quant Comp",2,2)
	oExcel:AddColumn(cPlano,cTitulo,"Lim C inf",2,2)
	oExcel:AddColumn(cPlano,cTitulo,"Lim C sup",2,2)
	oExcel:AddColumn(cPlano,cTitulo,"Quant Extras",2,2)
	oExcel:AddColumn(cPlano,cTitulo,"Lim HE inf",2,2)
	oExcel:AddColumn(cPlano,cTitulo,"Lim HE sup",2,2)



	for _x:=1 to len(aDet)
		oSay:cCaption := ('Gerando ' + StrZero(_x, 6)+ ' de '+ StrZero(len(aDet), 6))
		ProcessMessages()
		oExcel:AddRow(cPlano,cTitulo,{aDet[_x][1],aDet[_x][2],aDet[_x][3],aDet[_x][4],aDet[_x][5],aDet[_x][6],aDet[_x][7],aDet[_x][8],aDet[_x][9],aDet[_x][10],aDet[_x][11],aDet[_x][12],aDet[_x][13],aDet[_x][14],aDet[_x][15]})
	next

	oSay:cCaption := ('Gerando arquivo...')
	cArq:= cPath+cAlExc
	oExcel:Activate()
	oExcel:GetXMLFile(cArq)
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(cArq)
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()


return


user function _exExl2()

	local oExcel := nil
	cPlano:="Excecoes"
	cTitulo:="relacao de funcionarios que nao farao parte das regras"

	oExcel := FWMSEXCEL():New()
	oExcel:SetFontSize(8)
	oExcel:SetFont("Arial")

	oExcel:AddworkSheet(cPlano)
	oExcel:AddTable(cPlano,cTitulo)

	oExcel:AddColumn(cPlano,cTitulo,"Regra",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"Data",1,4)
	oExcel:AddColumn(cPlano,cTitulo,"Matricula",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"Nome",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"Filial",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"C.Custo funcionario",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"Descricao",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"Turno",1,1)
	oExcel:AddColumn(cPlano,cTitulo,"Motivo",1,1)

	_cQuery := " Select ZD1_COD,ZD1_DATA,ZD1_MAT,RA_NOME,ZD1_FILIAL,RA_CC,CTT_DESC01,RA_TNOTRAB, ZD1_MOTIVO FROM "+RETSQLNAME ("ZD1")
	_cQuery += " inner JOIN "+RETSQLNAME ("SRA")+" ON ZD1_MAT = RA_MAT AND ZD1_FILFUN = RA_FILIAL AND "+RETSQLNAME ("SRA")+".D_E_L_E_T_ = '' "
	_cQuery += " INNER JOIN "+RETSQLNAME ("CTT")+" ON RA_CC = CTT_CUSTO AND "+RETSQLNAME("SRA")+".D_E_L_E_T_ = ''"
	_cQuery += " WHERE ZD1_COD = '"+ZD0->ZD0_COD+"'"

	TCQUERY _cQuery NEW ALIAS "TRB4"

	dbSelectArea("TRB4")
	DbGoTop()
	Do while !eof()
		oExcel:AddRow(cPlano,cTitulo,{TRB4->ZD1_COD,TRB4->ZD1_DATA,TRB4->ZD1_MAT,TRB4->RA_NOME,TRB4->ZD1_FILIAL,TRB4->RA_CC,TRB4->CTT_DESC01,TRB4->RA_TNOTRAB})
		dbskip()
	Enddo

	dbSelectArea("TRB4")
	dbCloseArea()

	cArq:= cPath+cAlExc
	oExcel:Activate()
	oExcel:GetXMLFile(cArq)
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(cArq)
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()

return

user function bcczd1(cMt)

	_cQuery := " SELECT count(*) as nQuant"
	_cQuery += " FROM " + RETSQLNAME ("SRA") +" AS SRA "
	_cQuery += " where RA_CC = '"+ZD0->ZD0_CC+"' AND RA_TNOTRAB = '"+ZD0->ZD0_TURNO+"' "
	_cQuery += " AND SRA.D_E_L_E_T_ = '' AND RA_DEMISSA = '' AND RA_MAT = '"+cMt+"'"


	TCQUERY _cQuery NEW ALIAS "TRB3"

	dbSelectArea("TRB3")
	DbGoTop()
	if TRB3->nQuant == 0
		MsgAlert("<b>Funcionario nao pertence a este centro de custo ou turno</b><br>O sistem permite a inserção do mesmo porem ele<br>nao fara parte da regra de excecao", "Atenção")
	endif

	dbCloseArea()

return(.t.)

