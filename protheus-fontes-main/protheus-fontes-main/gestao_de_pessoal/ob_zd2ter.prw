#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "FWMVCDef.ch"

USER FUNCTION ob_ZD2TER()

	Private cArqName:= "XXX.pdf"
	Private oPrn    := Nil
	Private nColIni := 100
	Private nTotLin := 3220//2100
	Private nTotCol := 2300//3350
	Private nLin    := 0
	Private nCol    := 0

	oFont3 := TFont():New( "Courier new",,22,,.T.,,,,,.F. )
	oFont4 := TFont():New( "Courier new",,17,,.T.,,,,,.F. )

	private cAcesso := Repl(" ",10)

	// Monta objeto para impressão
	oPrn := TMSPrinter():New()
	oPrn:SetPortrait()
	oPrn:Setup()
	oPrn:StartPage()
	oPrn:SetPaperSize(9)

	//QUADRO 1
	nLin := 60
	nCol := nColIni
	oPrn:Box(nLin, nCol-10, nLin+140, nTotCol)
	//oPrn:Line(nLin,30,nLin, nTotCol) // LINHA NO INICIO
	nLin += 30
	oPrn:SayBitmap(nLin, nCol, "\system\lgrl" + alltrim(SM0->M0_CODIGO) + ".bmp", 350, 100)
	nLin += 20
	oPrn:Say(nLin, nTotCol/2, "- - - - N O T I F I C A Ç Ã O - - - -", oFont3,,,,2)
	nLin += 180
	oPrn:Say(nLin, nCol+10, "MATRICULA: "+ZD2->ZD2_MAT+" - "+POSICIONE("SRA",1,ZD2->ZD2_FILFUN+ZD2->ZD2_MAT,"RA_NOME"), oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "TIPO NOTIFICAÇÃO: "+LEFT(POSICIONE("ZD3",1,XFILIAL("ZD3")+ZD2->ZD2_CODNOT,"ZD3_DESC"),30), oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "DATA NOTIFICAÇÃO "+DTOC(ZD2->ZD2_DTANOT), oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 180
	oPrn:Say(nLin, nTotCol/2, "__________________________,SANTA MARIA,"+DTOC(DDATABASE), oFont4,,,,2)
	nLin += 180
	oPrn:Say(nLin, nTotCol/2, "ASSINATURA", oFont4,,,,2)

	oPrn:EndPage()
	oPrn:Preview()

	/*
	Private cArqName:= "XXX.pdf"
	Private oPrn    := Nil
	Private nColIni := 100
	Private nTotLin := 3220//2100
	Private nTotCol := 2300//3350
	Private nLin    := 0
	Private nCol    := 0

	oFont3 := TFont():New( "Courier new",,22,,.T.,,,,,.F. )
	oFont4 := TFont():New( "Courier new",,17,,.T.,,,,,.F. )

	private cAcesso := Repl(" ",10)

	// Monta objeto para impressão
	oPrn := TMSPrinter():New()
	oPrn:SetPortrait()
	oPrn:Setup()
	oPrn:StartPage()
	oPrn:SetPaperSize(9)

	//QUADRO 1
	nLin := 60
	nCol := nColIni
	oPrn:Box(nLin, nCol-10, nLin+140, nTotCol)
	//oPrn:Line(nLin,30,nLin, nTotCol) // LINHA NO INICIO
	nLin += 30
	oPrn:SayBitmap(nLin, nCol, "\system\lgrl" + alltrim(SM0->M0_CODIGO) + ".bmp", 350, 100)
	nLin += 20
	oPrn:Say(nLin, nTotCol/2, "- - - - N O T I F I C A Ç Ã O - - - -", oFont3,,,,2)
	nLin += 180
	oPrn:Say(nLin, nCol+10, "MATRICULA: "+ZD2->ZD2_MAT+" - "+POSICIONE("SRA",1,XFILIAL("SRA")+ZD2->ZD2_MAT,"RA_NOME"), oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "TIPO NOTIFICAÇÃO: "+LEFT(POSICIONE("ZD3",1,XFILIAL("ZD3")+ZD2->ZD2_CODNOT,"ZD3_DESC"),30), oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "DATA NOTIFICAÇÃO "+DTOC(ZD2->ZD2_DTANOT), oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 110
	oPrn:Say(nLin, nCol+10, "xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx xxxxxxxxx", oFont3,,,,2)
	nLin += 180
	oPrn:Say(nLin, nTotCol/2, "__________________________,SANTA MARIA,"+DTOC(DDATABASE), oFont4,,,,2)
	nLin += 180
	oPrn:Say(nLin, nTotCol/2, "ASSINATURA", oFont4,,,,2)

	oPrn:EndPage()
	oPrn:Preview()
	*/
RETURN


USER FUNCTION ob_ZD2REL()
	Private cString
	aOrd := {}
	Private CbTxt        := ""
	cDesc1               := "Este programa tem como objetivo imprimir relatorio "
	cDesc2               := "de acordo com os parametros informados pelo usuario."
	cDesc3               := "Relacao de notificações"
	cPict                := ""
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "ob_ZD2REL"
	Private nTipo        := 15
	Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        :=  "ob_ZD2REL"
	titulo               := "RELACAO DE NOTIFICAÇÕES"
	nLin                 := 80

	Cabec1               := ""
	Cabec2               := ""
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	imprime              := .T.
	Private wnrel        := "ob_ZD2REL"
	Private cString      := "ZD2"
	Private aTot         := {}

	ValidPerg()

	pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
	
	If nLastKey == 27
		Return
	Endif

	fErase(__RelDir + wnrel + '.##r')
	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)


	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return



Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	
	MsgRun("Consultando base de dados, aguarde...","",{|| CursorWait(), OkProc() ,CursorArrow()})
	
	Cabec1       := " RELACAO DE FUNCIONARIOS EM NOTIFICAÇÕES"
	Cabec2       := " MATRICULA  NOME                            DATA NOTIFICACAO       JUSTIFICATIVA                  DATA INSERÇÃO     USUARIO"

	dbSelectArea("TRB")
	DbGoTop()
	_nT := 0
	While !EOF()

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		_cLin := TRB->ZD2_MAT+SPACE(2)+TRB->RA_NOME+SPACE(10)+DTOC(TRB->ZD2_DTANOT)+SPACE(10)+left(TRB->ZD3_DESC,30)+DTOC(TRB->ZD2_DTAINS)+SPACE(10)+TRB->ZD2_USER

		If aScan(aTot,TRB->ZD2_MAT) > 0 .AND.  mv_par01 == 1
			@ nLin, 01  PSAY _cLin
			_nT := _nT + 1
			nLin+=1
		Endif

		If mv_par01 <> 1
			@ nLin, 01  PSAY _cLin
			_nT := _nT + 1
			nLin+=1
		Endif


		_cMatBKp:= TRB->ZD2_MAT
		_cSitFol:= TRB->RA_SITFOLH

		dbSelectArea("TRB")
		dbSkip()

		if _cMatBKp <> TRB->ZD2_MAT
			if (mv_par01 == 1 .and. _nT >= 3) .or.  mv_par01 <> 1
				@ nLin, 01  PSAY 'notificações '+cvaltochar(_nT) + iif(_nT >= 3," ******* TOTAL EXCEDIDO *******","")+IIF(Alltrim(_cSitFol)<> ''," Situação Folha : "+_cSitFol,"")
				_nT := 0
				nLin+= 2
			endif
		Endif

	EndDo
	
	if (mv_par01 == 1 .and. _nT >= 3) .or.  (mv_par01 <> 1 .and. _nT >= 1)
		@ nLin, 01  PSAY 'notificações '+cvaltochar(_nT) + iif(_nT >= 3," ******* TOTAL EXCEDIDO *******","")+IIF(Alltrim(_cSitFol)<> ''," Situação Folha : "+_cSitFol,"")
	endif
	

	dbSelectArea("TRB")
	dbCloseArea()

	If aReturn[5]==1
		dbCommitAll()
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

/**************************
Função que retorna a query
***************************/
Static Function OkProc()
	local cQuery := ""
	cQuery := " SELECT ZD2_MAT,RA_NOME,ZD2_DTANOT,ZD3_DESC,ZD2_DTAINS,ZD2_USER,RA_SITFOLH "
	cQuery += " FROM "+RetSqlName("ZD2") "
	cQuery += " INNER JOIN "+RetSqlName("ZD3")+" ON ZD2_CODNOT = ZD3_CODIGO AND "+RetSqlName("ZD3")+".D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN "+RetSqlName("SRA")+" ON RA_MAT = ZD2_MAT AND "+RetSqlName("SRA")+".D_E_L_E_T_ = '' "  
	cQuery += " AND RA_FILIAL = ZD2_FILFUN"
	if mv_par02 <> 1
		cQuery += " AND RA_SITFOLH <> 'D' "
	Endif

	cQuery += " WHERE "+RetSqlName("ZD2")+".D_E_L_E_T_ = '' order by ZD2_MAT "

	TCQUERY cQuery NEW ALIAS "TRB"
	
	
	TcSetField("TRB","ZD2_DTANOT","D")
	TcSetField("TRB","ZD2_DTAINS","D")

	if mv_par01 == 1
		cQuery := " SELECT ZD2_MAT,count(*) AS NTOT FROM  "+RetSqlName("ZD2")
		cQuery += " INNER JOIN "+RetSqlName("ZD3")+" ON ZD2_CODNOT = ZD3_CODIGO AND "+RetSqlName("ZD3")+".D_E_L_E_T_ = '' "
		cQuery += " INNER JOIN "+RetSqlName("SRA")+" ON RA_MAT = ZD2_MAT AND "+RetSqlName("SRA")+".D_E_L_E_T_ = '' AND RA_FILIAL = ZD2_FILFUN "
		if mv_par02 <> 1
			cQuery += " AND RA_SITFOLH <> 'D' "
		Endif
		cQuery += " WHERE "+RetSqlName("ZD2")+".D_E_L_E_T_ = '' "
		cQuery += " GROUP BY ZD2_MAT"
		cQuery += " ORDER BY ZD2_MAT"
		TCQUERY cQuery NEW ALIAS "TRB2"

		DbSelectarea('TRB2')
		DbGoTop()
		while !eof()
			if TRB2->NTOT >=3
				aadd(aTot,TRB2->ZD2_MAT)
			Endif

			DbSkip()
		Enddo
		dbSelectArea("TRB2")
		dbCloseArea()

	Endif


return




Static Function ValidPerg()

	Local cAlias := Alias()
	Local aRegs := {}
	Local i,j

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	AADD(aRegs,{cPerg,"01","Somente excedentes   ?","","","mv_ch1","C",01,0,0,"C","","mv_par01","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Considerar demitidos ?","","","mv_ch2","C",01,0,0,"C","","mv_par02","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	DbSetOrder(1)
	//cPerg := PADR(cPerg,6)
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
/*
Private cString
aOrd := {}
Private CbTxt        := ""
cDesc1               := "Este programa tem como objetivo imprimir relatorio "
cDesc2               := "de acordo com os parametros informados pelo usuario."
cDesc3               := "Relacao de advvertencias"
cPict                := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "M"
Private nomeprog     := "OB_ZD2REL"
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        :=  "OB_ZD2REL"
titulo               := "RELACAO DE NOTIFICAÇÕES"
nLin                 := 80

Cabec1               := ""
Cabec2               := ""
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
imprime              := .T.
Private wnrel        := "OB_ZD2REL"
Private cString      := "ZD2"


pergunte(cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == 27
Return
Endif

fErase(__RelDir + wnrel + '.##r')
SetDefault(aReturn,cString)

If nLastKey == 27
Return
Endif

nTipo := If(aReturn[4]==1,15,18)


RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return



Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)


MsgRun("Consultando base de dados, aguarde...","",{|| CursorWait(), OkProc() ,CursorArrow()})

Cabec1       := " RELACAO DE FUNCIONARIOS EM NOTIFICAÇÕES"
Cabec2       := " MATRICULA  NOME                            DATA NOTIFICACAO       JUSTIFICATIVA                  DATA INSERÇÃO     USUARIO"

dbSelectArea("TRB")
DbGoTop()
_nT := 1
While !EOF()

If lAbortPrint
@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
Exit
Endif

If nLin > 55
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 9
Endif

@ nLin, 01  PSAY TRB->ZD2_MAT+SPACE(2)+TRB->RA_NOME+SPACE(10)+DTOC(TRB->ZD2_DTANOT)+SPACE(10)+left(TRB->ZD3_DESC,30)+DTOC(TRB->ZD2_DTAINS)+SPACE(10)+TRB->ZD2_USER

nLin+=1
_cMatBKp:= TRB->ZD2_MAT

dbSelectArea("TRB")
dbSkip()

if _cMatBKp<> TRB->ZD2_MAT
@ nLin, 01  PSAY 'notificações '+cvaltochar(_nT)
_nT := 1
nLin+= 2
else
_nT := _nT + 1
Endif

EndDo
if _nT > 1
@ nLin, 01  PSAY 'notificações '+cvaltochar(_nT)
Endif

dbSelectArea("TRB")
dbCloseArea()

If aReturn[5]==1
dbCommitAll()
OurSpool(wnrel)
Endif

MS_FLUSH()

Return
*/
/**************************
Função que retorna a query
***************************/
/*
Static Function OkProc()
local cQuery := ""
cQuery := " SELECT ZD2_MAT,RA_NOME,ZD2_DTANOT,ZD3_DESC,ZD2_DTAINS,ZD2_USER "
cQuery += " FROM " + RETSQLNAME ("ZD2") +" AS ZD2 "
cQuery += " INNER JOIN " + RETSQLNAME ("ZD3") +" AS ZD3 ON ZD2_CODNOT = ZD3_CODIGO AND ZD3.D_E_L_E_T_ = '' "
cQuery += " INNER JOIN " + RETSQLNAME ("SRA") +" AS SRA ON RA_MAT = ZD2_MAT AND SRA.D_E_L_E_T_ = '' "
cQuery += " WHERE ZD2.D_E_L_E_T_ = '' "
cQuery += " ORDER BY ZD2_MAT "

TCQUERY cQuery NEW ALIAS "TRB"

TcSetField("TRB","ZD2_DTANOT","D")
TcSetField("TRB","ZD2_DTAINS","D")

return
*/
