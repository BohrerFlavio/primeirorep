#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "apvt100.ch"
#include 'TOTVS.ch'


/*/{Protheus.doc} obit02
Grava histórico de movimentação das etiquetas
@type function
@author André R. Lerner
@since 10/29/2023
/*/


//MUDAR  oEnc  := MSGetDados():New (220,2,266,256,2,,,,.F.,,,.F.,len(aCols),,,,,oDlg)



user function obit02(_cControl, _cUser, _cLocal, _cLocaliz, _cTipoMov, _cPallet, _cTabori, _cRotina)
	Local _aArea   := GetArea()
	default _cRotina := FUNNAME()
	reclock('ZLH',.T.)
	ZLH->ZLH_CONTRO := _cControl
	ZLH->ZLH_DATA   := date()
	ZLH->ZLH_HORA   := time()
	ZLH->ZLH_USER   := _cUser
	ZLH->ZLH_LOCAL  := _cLocal
	ZLH->ZLH_LOCALI := _cLocaliz
	ZLH->ZLH_TIPOMO := left(_cTipoMov,30)
	ZLH->ZLH_PALLET := _cPallet
	ZLH->ZLH_TABORI := _cTabori
	ZLH->ZLH_ROTINA := _cRotina
	MsUnLock()
	RestArea(_aArea)

return



User Function obit02ZLH()

	Private cCaixa := space(10)
	lOk         := .f.
	oDesc       := ''
	vNumPrev    := ''
	aIndSZ8   	:= {}
	cCondicao 	:= ""

	Private _lRep    := .f.       //Variavel que vai agir e definir se a saída é processo ou reprocesso
	Private _cMotivo := space(20)
	Private cCadastro := "Controle de Caixas e Manutenção de Estoque"

	Private aRotina := { {"Pesquisar" ,"AxPesqui"    ,0,1} ,;
		{"Consultar" ,"u_gjf34co2 " ,0,4},;
		{"Legenda"  , "u_Leg" ,0,1}} //{"Reimprimir","u_gjf34im2"  ,0,2},; Mudança para remover reimpressão - 21/06/23
	private cString := "ZAS"

	dbSelectArea('ZAS')
	posicao()		// Desativa a tecla F12 do acionamento dos parametros

Return

static function posicao()                    //Cria a caixa de diálogo para localizar uma caixa
	cCaixa := space(10)
	DEFINE MSDIALOG oDlg2 TITLE 'Localizar Caixa:' from 000,000 To 100,250 OF oMainWnd PIXEL
	@ 010,003 SAY  'Código:' Object oSay1
	@ 010,025 GET cCaixa PICTURE "@!"   SIZE 40,11  VALID preenche() Object oCaixa
	@ 010,80 BMPBUTTON TYPE 1 ACTION posicao2() Object Obtn1
	@ 025,80 BMPBUTTON TYPE 2 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2

return

static function posicao2()
	ZAS->(dbsetorder(1))
	if ZAS->(dbseek(xfilial('ZAS')+cCaixa,.t.))
		u_obit02Hist()
	else
		msgbox('Caixa não encontrada!','OPERAÇÃO INCONSISTENTE!','STOP')
	endif

return


//Função para busca de caixa através da pre-etiqueta
static function posicao3()                    //Cria a caixa de diálogo para localizar uma caixa
	cPreETQ := space(06)
	DEFINE MSDIALOG oDlg2 TITLE 'Localizar Caixa:' from 000,000 To 100,250 OF oMainWnd PIXEL
	@ 010,003 SAY  'Pre-Etiqueta:' Object oSay1
	@ 010,030 GET cPreETQ PICTURE "@!"   SIZE 20,11  Object oCaixa
	@ 010,80 BMPBUTTON TYPE 1 ACTION posicao4() Object Obtn1
	@ 025,80 BMPBUTTON TYPE 2 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2

return

static function posicao4()
	SZ8->(dbsetorder(16))
	if !SZ8->(dbseek(xfilial('SZ8')+cPreETQ))
		msgbox('Caixa não encontrada!','OPERAÇÃO INCONSISTENTE!','STOP')
	endif
	odlg2:end()
	SZ8->(dbsetorder(3))
return


static function preenche()                            //Função que preeche o codigo do produto com zeros
	if !empty(alltrim(cCaixa))
		cCaixa := padl(alltrim(cCaixa),10,"0")
	endif
return .t.

user function obit02Hist()
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0

	descP := ZAS->ZAS_DESC //fBuscaCPO('SB1',1,ZAS->(ZAS_FILIAL+Z8_CODORI),'B1_DESC')

	//campo1 := space(20)
	//valor1 := space(20)
	//campo2 := CTBCBOX('ZV_TIPO')                                                   //Aponta o tipo de operação a ser feita
	//valor2 := space(10)

	_cRua    := substr(ZAS->ZAS_LOCALI,3,2)
	_cPredio := substr(ZAS->ZAS_LOCALI,5,2)
	_cAndar  := substr(ZAS->ZAS_LOCALI,7,2)
	_cApto   := substr(ZAS->ZAS_LOCALI,9,2)

	if !empty(ZAS->ZAS_PREDES)                                                            // se houver o apontamento de OP...
		vNUMAM   := fBuscaCPO('SZ2',2,xfilial('SZ2')+ZAS->ZAS_PREDES,'Z2_NUMAM')          //numero aviso de matança

		dtAbate  := fBuscaCPO('SZG',1,xfilial('SZG')+vNUMAM,'ZG_DATA')             //data do aviso de matança
		vTIP     := fBuscaCPO('SZ2',2,xfilial('SC2')+SZ8->Z8_PREDES,'Z2_TIPIFI')          //numero aviso de matança
	else
		dtAbate := ZAS->ZAS_DTABAT
	endif

	DEFINE MSDIALOG oDlg TITLE 'Consulta de históricos' from 0,0 To 600,911 PIXEL

	oFont      := tFont():New("courier new",,-18,,.t.,,,,)
	oFont2     := tFont():New(,,,,.t.,,,,)
	oFont3     := tFont():New(,,-16,,.t.,,,,)
	oSayLabel1 := tSay():New(010,10,{|| 'Caixa nº:'},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayCont   := tSay():New(008,40,{|| ZAS->ZAS_CONTRO },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayLabel2 := tSay():New(010,120,{|| 'Produto:'},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayCod    := tSay():New(008,150,{|| ZAS->ZAS_COD },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayDesc   := tSay():New(020,10,{|| ZAS->ZAS_DESC },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayDataP  := tSay():New(020,200,{|| descP},oDlg,,oFont2,,,,.T.,,,200,30)

	do case
	case empty(ZAS->ZAS_DATAS) //.and. empty(SZ8->Z8_DATAE)
		oSaySit   := tSay():New(035,10,{|| 'Caixa disponível!' },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
	case !empty(ZAS->ZAS_DATAS) //.and. empty(SZ8->Z8_DATAE)
		oSaySit   := tSay():New(035,10,{|| 'Caixa já carregada ou fora de estoque!' },oDlg,,oFont,,,,.T.,CLR_HRED,CLR_HRED,220,35)
	endcase

	oSayLabel3  := tSay():New(060,10,{|| 'Data Real de Produção:'},oDlg,,,,,,.T.,,,200,30)
	oSayData    := tSay():New(060,70,{|| ZAS->ZAS_DTPROD},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel4  := tSay():New(070,10,{|| 'Data de Produção:'},oDlg,,,,,,.T.,,,200,30)
	oSayDataP   := tSay():New(070,70,{|| ZAS->ZAS_DTPROD},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel5  := tSay():New(080,10,{|| 'Data de Validade:'},oDlg,,,,,,.T.,,,200,30)
	oSayDataV   := tSay():New(080,70,{|| dtAbate + ZAS->ZAS_VALID},oDlg,,oFont2,,,,.T.,,,200,30)

	if !empty(ZAS->ZAS_PREDES) .and. empty(ZAS->ZAS_LOTE)
		oSayLabel23 := tSay():New(090,10,{|| 'Data de Abate:'},oDlg,,,,,,.T.,,,200,30)
		oSaydtAbt   := tSay():New(090,70,{|| dtAbate},oDlg,,oFont2,,,,.T.,,,200,30)
	endif

	//oSayLabel6 := tSay():New(100,10,{|| 'Quantidade de Peças:'},oDlg,,,,,,.T.,,,200,30)
	//oSayQuant  := tSay():New(100,70,{|| transform(0,'@E 99')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel7 := tSay():New(100,10,{|| 'Peso Bruto:'},oDlg,,,,,,.T.,,,200,30)
	oSayPesoB  := tSay():New(100,70,{|| transform(ZAS->ZAS_PESOB,'@E 9,999.999')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel8 := tSay():New(110,10,{|| 'Tara:'},oDlg,,,,,,.T.,,,200,30)
	oSayTara   := tSay():New(110,70,{|| transform(ZAS->ZAS_TARA,'@E 9.999')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel9 := tSay():New(130,10,{|| 'Peso Líquido:'},oDlg,,oFont3,,,,.T.,,,200,30)
	oSayPesoL  := tSay():New(130,70,{|| transform(ZAS->ZAS_PESOL,'@E 9,999.999')},oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)

	if !empty(SZ8->Z8_PREDES)
		oSayLabel22 := tSay():New(145,10,{|| 'Tipificação:'},oDlg,,,,,,.T.,,,200,30)
		oSayTIP     := tSay():New(145,70,{|| vTIP},oDlg,,oFont2,,,,.T.,,,200,30)
	endif
	oSayLabel11 := tSay():New(120,10,{|| 'Tipo de Produção:'},oDlg,,,,,,.T.,,,200,30)//90//140
	oSayTipo    := tSay():New(120,70,{|| ZAS->ZAS_TIPO },oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel14 := tSay():New(060,140,{|| 'Tratamento a Frio?'},oDlg,,,,,,.T.,,,200,30)
	oSayTF      := tSay():New(060,200,{|| iif(ZAS->ZAS_TF == 'S','Sim','Nao')},oDlg,,oFont2,,,,.T.,,,200,30)
	/*
	oSayLabel15 := tSay():New(100,140,{|| 'Tipo de Etiqueta:'},oDlg,,,,,,.T.,,,200,30)
	oSayEtiq    := tSay():New(100,200,{|| SZ8->Z8_ETIQ},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel16 := tSay():New(110,140,{|| 'Mensagem Despojo?'},oDlg,,,,,,.T.,,,200,30)
	oSayDesp    := tSay():New(110,200,{|| iif(SZ8->Z8_MDESP == 'S','Sim','Nao')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel20 := tSay():New(120,140,{|| 'Camara:'},oDlg,,,,,,.T.,,,200,30)
	oSayLocal   := tSay():New(120,200,{|| SZ8->Z8_LOCAL},oDlg,,oFont2,,,,.T.,,,200,30)
	*/
	if !empty(ZAS->ZAS_LOCALI)
		oSayLocaliz   := tSay():New(100,140,{|| 'Rua: '    + _cRua    + '  ' +;
			'Prédio: ' + _cPredio + '  ' +;
			'Andar: '  + _cAndar  + '  ' +;
			'Apto: '   + _cApto},oDlg,,oFont2,,,,.T.,,,200,30)
	endif
/*
	oSayLabel17 := tSay():New(140,140,{|| 'Operador:'},oDlg,,,,,,.T.,,,200,30)
	oSayOper    := tSay():New(140,200,{|| SZ8->Z8_OPERA},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel18 := tSay():New(150,140,{|| 'Estação'},oDlg,,,,,,.T.,,,200,30)
	oSayBal     := tSay():New(150,200,{|| SZ8->Z8_BALAN},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel19 := tSay():New(160,140,{|| 'Hora:'},oDlg,,,,,,.T.,,,200,30)
	oSayHora    := tSay():New(160,200,{|| SZ8->Z8_HORA},oDlg,,oFont2,,,,.T.,,,200,30)
*/

	nUsado := obit02head()
	obit02col()

	oEnc  := MSGetDados():New (160,5,266,450,1,,,,.F.,,,.F.,len(aCols),,,,,oDlg)
	//oEnc  := MSGetDados():New (220,2,266,256,2,,,,.F.,,,.F.,len(aCols),,,,,oDlg)

	@ 275,190  BUTTON 'Fechar'   SIZE 45,15 ACTION ODlg:end()  OBJECT oBtn2
	ACTIVATE MSDIALOG oDlg CENTERED
return


static function obit02Head() //Monta o Header das operações registradas no historico
	Aheader := {}
	aAdd(Aheader,{'Data     ' ,'ZLH_DATA' ,'99/99/9999', 08   , 0 , ,, 'D' ,'ZLH',})
	aAdd(Aheader,{'Hora     ' ,'ZLH_HORA' ,'99:99'     , 05   , 0 , ,, 'C' ,'ZLH',})
	aAdd(Aheader,{'Descrição' ,'ZLH_TIPOMO' ,'@!'      , 30   , 0 , ,, 'C' ,'ZLH',})
	aAdd(Aheader,{'Local'     ,'ZLH_LOCAL'  ,'@!'      , 2   , 0 , ,, 'C' ,'ZLH',})
	aAdd(Aheader,{'Usuario  ' ,'ZLH_USER'   ,'@!'      , 15   , 0 , ,, 'C' ,'ZLH',})
	aAdd(Aheader,{'Rotina   ' ,'ZLH_ROTINA' ,'@!'      , 10   , 0 , ,, 'C' ,'ZLH',})

return len(aHeader)

static Function obit02col()                                                     //Monta o aCols dos históricos da caixa (ZLH)
	Local nI
	dbselectarea('ZLH')
	ZLH->(dbSetOrder(1))
	if ZLH->(dbSeek(xFilial('ZLH')+ZAS->ZAS_CONTRO,.t.))
		Do While ZLH->(!Eof()) .and. ZLH->ZLH_FILIAL = xfilial('ZLH') .and. alltrim(ZLH->ZLH_CONTRO) == alltrim(ZAS->ZAS_CONTRO)
			aAdd(aCols,Array(nUsado+1))
			For nI := 1 to nUsado
				if aHeader[nI,2] == "ZLH_USER"
					aCols[Len(aCols),nI] := UsrRetName(FieldGet(FieldPos(aHeader[nI,2])))
				else
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				endif
			Next nI
			aCols[Len(aCols),nUsado+1] := .F.
			ZLH->(DbSkip())
		Enddo
	endif
	aCols := ASort(aCols, , , {|x,y|dtos(x[1])+x[2]+x[3] > dtos(y[1])+y[2]+y[3]})
return

static function DescMot(Mot)                                                        //Cria a caixa de diálogo para localizar uma caixa
	Local _lOk := .f.

	_cMotivo := space(20)
	_lRep    := .f.

	DEFINE MSDIALOG oDlg2 TITLE 'Motivo da Movimentação:' from 000,000 To 100,260 OF oMainWnd PIXEL
	@ 010,003 SAY  'Historico:' Object oSay1
	@ 010,025 GET _cMotivo PICTURE "@!"   SIZE 60,11  Object oCaixa

	if Mot = 'S'
		@ 025,003 checkbox 'Reprocesso?' VAR _lRep Object oCheck
	endif

	@ 010,100 BMPBUTTON TYPE 1 ACTION (_lOk := .t.,odlg2:end()) Object Obtn1
	@ 025,100 BMPBUTTON TYPE 2 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2
return _lOk

////Funções para atualização do mBrowse////
Static Function AutoRefresh(oDlg)
	Local oTimer
	oTimer := TTimer():New(2, {|| PBrow() }, oDlg)
	oTimer:Activate()
Return .T.

////Funções para atualização do mBrowse////
Static Function PBrow()
	oBrowse := getObjBrow()
	oBrowse:default()
	oBrowse:refresh()
Return



static function posicao5()

	cPreE := space(14)
	DEFINE MSDIALOG oDlg2 TITLE 'Localizar Caixa Por Pré-Etiqueta:' from 000,000 To 100,250 OF oMainWnd PIXEL
	@ 010,003 SAY  'Numero:' Object oSay1
	@ 010,025 GET cPreE PICTURE "@!"   SIZE 50,13  Object oCaixa
	@ 010,80 BMPBUTTON TYPE 1 ACTION posicao6() Object Obtn1
	@ 025,80 BMPBUTTON TYPE 2 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2

return

static function posicao6()

	_c1 := substr(cPreE,1,2)
	_c2 := substr(cPreE,3,3)
	_c3 := substr(cPreE,6,9)

	_CSeqpE := alltrim(_c1)+'000'+alltrim(_c3)

	SZ8->(dbsetorder(16))
	if SZ8->(dbseek(xfilial('SZ8')+alltrim(_CSeqpE),.t.))
		//U_gjf34imp()
		u_gjf34con()
	else
		msgbox('Caixa não encontrada!','OPERAÇÃO INCONSISTENTE!','STOP')
	endif

return
