#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF32     ºAutor  ³Giuliano Forgiarini º Data ³  11/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³ Destinada a realizar as movimentações internas SD3 - produção  ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ vários módulos - Frigorifico Silva                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User function GJF32(par)

	area := getarea()

	DbSelectArea('SB1')

	SC2->(dbsetorder(12))

	SC2->(dbseek(xfilial('SC2')+par))

	ordemP  := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
	_cLocal := '01'
	_cProd  := alltrim(SC2->C2_PRODUTO)
	_cUM    := SC2->C2_UM

	SZU->(dbsetorder(2))
	SZU->(dbseek(xfilial('SZU')+par))
	_nPeso  := SZU->ZU_QRPESO
	_nCaix  := SZU->ZU_QRCAIX 
	_nFator := SZU->ZU_QPPESO/SZU->ZU_QPCAIX
	_nBPes  := SZU->ZU_QRCAIX * _nFator
	_nCC   := fBuscaCPO('SB1',1,xfilial('SB1')+_cProd,'B1_CC')

	cursorwait()


	aMata250 :={{"D3_OP",ordemP ,NIL},;
	{"D3_TM"      ,"005"        ,NIL},;
	{"D3_LOCAL"   ,_cLocal      ,NIL},;
	{"D3_COD"     ,_cProd       ,NIL},;
	{"D3_QUANT"   ,_nBPes       ,NIL},;
	{"D3_EMISSAO" ,ddatabase    ,NIL},;
	{"D3_CC"      ,_nCC         ,NIL},;
	{"D3_PRDNUM"  ,'XXXXXX'     ,NIL},;
	{"D3_UM"      ,_cUM         ,NIL},;
	{"D3_QTSEGUM" ,_nCaix       ,NIL},;
	{"D3_PREV"    ,par          ,NIL},;
	{"D3_PRDITEM" ,'XX'         ,NIL} }

	lMsErroAuto := .f.

	msExecAuto({|x,Y| Mata250(x,Y)},aMata250,3)

	cursorarrow()

	msgbox('Movimentação de produção efetivada!',,'INFO')

	If lMsErroAuto
		MostraErro()
	Endif

	restarea(area)
return
