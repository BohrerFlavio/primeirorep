#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI112 ºAutor  ³ FLávio BOhrer Flôres º Data ³  14/11/20      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa, Consulta e reimpressão de Caixas sem data de Abate º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI112()


	lOk         := .f.
	oDesc       := ''
	vNumPrev    := ''
	aIndSZ8   	:= {}					                                                               	// Arquivo e número de índice utilizado
	cCondicao 	:= ""					                                                               	// Condição para a filtragem

	Private cPerg   := "GJF34"

	Private _lRep    := .f.       //Variavel que vai agir e definir se a saída é processo ou reprocesso
	Private _cMotivo := space(20)

	Private cCadastro := "Controle de Caixas e Manutenção de Estoque"

	Private aRotina := { {"Pesquisar" ,"AxPesqui"    ,0,1} ,;
	{"Consultar" ,"u_dti112co2 " ,0,4},;
	{"Reimprimir","u_dti112im2"  ,0,2},;
	{"Legenda"  , "u_Leg112" ,0,1}}


	private cString := "SZ8"
	//{"Reimprimir","u_gjf34imp"  ,0,4},;
	if !pergunte(cPerg,.t.)
		return
	endif

	Private bLegenda1 := "empty(SZ8->Z8_DATAS) .and. SZ8->Z8_FIL = xfilial('SB1')"             // em estoque
	Private bLegenda2 := "!empty(SZ8->Z8_DATAS)"         // expedida
	Private bLegenda3 := "empty(SZ8->Z8_DATAS) .and. SZ8->Z8_FIL <> xfilial('SB1')"         // em estoque


	Private aCores := {{bLegenda1, 'BR_VERDE'   },;      // em estoque
	{bLegenda2, 'BR_VERMELHO'},;      // expedida
	{bLegenda3, 'BR_AMARELO'}}      // expedida

	Private aCores2:= {{'BR_VERDE' ,'Em Estoque' },;      // bloqueado
	{'BR_VERMELHO' ,'Expedida'},;      // carregando
	{'BR_AMARELO' ,'Em Filial'}}      // carregando

	SetKey(123,{|| posicao()})

	dbSelectArea(cString)
	SZ8->(dbSetOrder(1))


	mBrowse( 6, 1, 22, 75,cString,,,,,,aCores,,,,{|x| AutoRefresh(x)})

	Set Key 123 To 																	// Desativa a tecla F12 do acionamento dos parametros

	DbCloseArea('SZ8')

Return

User Function Leg112(cAlias,nReg,nOpc)
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return


static function posicao()                    //Cria a caixa de diálogo para localizar uma caixa
	cCaixa := space(10)
	DEFINE MSDIALOG oDlg2 TITLE 'Localizar Caixa:' from 000,000 To 100,250 OF oMainWnd PIXEL
	@ 010,003 SAY  'Numero:' Object oSay1
	@ 010,025 GET cCaixa PICTURE "@!"   SIZE 40,11  VALID preenche() Object oCaixa
	@ 010,80 BMPBUTTON TYPE 1 ACTION posicao2() Object Obtn1
	@ 025,80 BMPBUTTON TYPE 2 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2

	//oDlg2:end()

return

static function posicao2()
	SZ8->(dbsetorder(3))
	if SZ8->(dbseek(xfilial('SZ8')+cCaixa,.t.))
		u_dti112co2('C')
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

user function dti112co2()
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	//RegToMemory("SZ8",.f.)

	descP := fBuscaCPO('SB1',1,SZ8->(Z8_FILORI+Z8_CODORI),'B1_DESC')

	campo1 := space(20)
	valor1 := space(20)
	campo2 := CTBCBOX('ZV_TIPO')                                                   //Aponta o tipo de operação a ser feita
	valor2 := space(10)

	_cRua    := substr(SZ8->Z8_LOCALIZ,3,2)
	_cPredio := substr(SZ8->Z8_LOCALIZ,5,2)
	_cAndar  := substr(SZ8->Z8_LOCALIZ,7,2)
	_cApto   := substr(SZ8->Z8_LOCALIZ,9,2)

	if !empty(SZ8->Z8_PREDES)                                                            // se houver o apontamento de OP...
		vNUMAM   := fBuscaCPO('SZ2',2,xfilial('SZ2')+SZ8->Z8_PREDES,'Z2_NUMAM')          //numero aviso de matança

		dtAbate  := fBuscaCPO('SZG',1,xfilial('SZG')+vNUMAM,'ZG_DATA')             //data do aviso de matança
		vTIP     := fBuscaCPO('SZ2',2,xfilial('SC2')+SZ8->Z8_PREDES,'Z2_TIPIFI')          //numero aviso de matança
	endif

	DEFINE MSDIALOG oDlg TITLE 'Consulta de Pesagens' from 0,0 To 600,511 PIXEL

	oFont      := tFont():New("courier new",,-18,,.t.,,,,)
	oFont2     := tFont():New(,,,,.t.,,,,)
	oFont3     := tFont():New(,,-16,,.t.,,,,)
	oSayLabel1 := tSay():New(010,10,{|| 'Caixa nº:'},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayCont   := tSay():New(008,40,{|| SZ8->Z8_CONTROL },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayLabel2 := tSay():New(010,120,{|| 'Produto:'},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayCod    := tSay():New(008,150,{|| SZ8->Z8_COD },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayDesc   := tSay():New(020,10,{|| SZ8->Z8_DESCRI },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayDataP  := tSay():New(035,10,{|| descP},oDlg,,oFont2,,,,.T.,,,200,30)

	do case
		case empty(SZ8->Z8_DATAS) .and. empty(SZ8->Z8_DATAE)
		oSaySit   := tSay():New(050,10,{|| 'Caixa disponível!' },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
		case !empty(SZ8->Z8_DATAS) .and. empty(SZ8->Z8_DATAE)
		oSaySit   := tSay():New(050,10,{|| 'Caixa já carregada ou fora de estoque!' },oDlg,,oFont,,,,.T.,CLR_HRED,CLR_HRED,220,35)
	endcase

	oSayLabel3  := tSay():New(090,10,{|| 'Data Real de Produção:'},oDlg,,,,,,.T.,,,200,30)
	oSayData    := tSay():New(090,70,{|| SZ8->Z8_DATA},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel4  := tSay():New(100,10,{|| 'Data de Produção:'},oDlg,,,,,,.T.,,,200,30)
	oSayDataP   := tSay():New(100,70,{|| SZ8->Z8_DATAP},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel5  := tSay():New(110,10,{|| 'Data de Validade:'},oDlg,,,,,,.T.,,,200,30)
	oSayDataV   := tSay():New(110,70,{|| SZ8->Z8_DATAVAL},oDlg,,oFont2,,,,.T.,,,200,30)

	if !empty(SZ8->Z8_PREDES) .and. empty(SZ8->Z8_LOTEPOR)
		oSayLabel23 := tSay():New(120,10,{|| 'Data de Abate:'},oDlg,,,,,,.T.,,,200,30)
		oSaydtAbt   := tSay():New(120,70,{|| dtAbate},oDlg,,oFont2,,,,.T.,,,200,30)
	endif

	oSayLabel6 := tSay():New(130,10,{|| 'Quantidade de Peças:'},oDlg,,,,,,.T.,,,200,30)
	oSayQuant  := tSay():New(130,70,{|| transform(SZ8->Z8_QUANT,'@E 99')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel7 := tSay():New(140,10,{|| 'Peso Bruto:'},oDlg,,,,,,.T.,,,200,30)
	oSayPesoB  := tSay():New(140,70,{|| transform(SZ8->Z8_PESOBR,'@E 99.999')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel8 := tSay():New(150,10,{|| 'Tara:'},oDlg,,,,,,.T.,,,200,30)
	oSayTara   := tSay():New(150,70,{|| transform(SZ8->Z8_TARA,'@E 9.999')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel9 := tSay():New(170,10,{|| 'Peso Líquido:'},oDlg,,oFont3,,,,.T.,,,200,30)
	oSayPesoL  := tSay():New(170,70,{|| transform(SZ8->Z8_PESO,'@E 99.999')},oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)

	if !empty(SZ8->Z8_PREDES)
		oSayLabel22 := tSay():New(185,10,{|| 'Tipificação:'},oDlg,,,,,,.T.,,,200,30)
		oSayTIP     := tSay():New(185,70,{|| vTIP},oDlg,,oFont2,,,,.T.,,,200,30)
	endif
	oSayLabel11 := tSay():New(160,10,{|| 'Tipo de Produção:'},oDlg,,,,,,.T.,,,200,30)//90//140
	oSayTipo    := tSay():New(160,70,{|| iif(SZ8->Z8_TIPO == 'P','Processo','Reprocesso')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel14 := tSay():New(090,140,{|| 'Tratamento a Frio?'},oDlg,,,,,,.T.,,,200,30)
	oSayTF      := tSay():New(090,200,{|| iif(SZ8->Z8_TF == 'S','Sim','Nao')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel15 := tSay():New(100,140,{|| 'Tipo de Etiqueta:'},oDlg,,,,,,.T.,,,200,30)
	oSayEtiq    := tSay():New(100,200,{|| SZ8->Z8_ETIQ},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel16 := tSay():New(110,140,{|| 'Mensagem Despojo?'},oDlg,,,,,,.T.,,,200,30)
	oSayDesp    := tSay():New(110,200,{|| iif(SZ8->Z8_MDESP == 'S','Sim','Nao')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel20 := tSay():New(120,140,{|| 'Camara:'},oDlg,,,,,,.T.,,,200,30)
	oSayLocal   := tSay():New(120,200,{|| SZ8->Z8_LOCAL},oDlg,,oFont2,,,,.T.,,,200,30)
	if !empty(SZ8->Z8_LOCALIZ)
		//oSayLabel20 := tSay():New(130,140,{|| 'Localização:'},oDlg,,,,,,.T.,,,200,30)
		oSayLocaliz   := tSay():New(130,140,{|| 'Rua: '    + _cRua    + '  ' +;
		'Predio: ' + _cPredio + '  ' +;
		'Andar: '  + _cAndar  + '  ' +;
		'Apto: '   + _cApto},oDlg,,oFont2,,,,.T.,,,200,30)
	endif

	oSayLabel17 := tSay():New(140,140,{|| 'Operador:'},oDlg,,,,,,.T.,,,200,30)
	oSayOper    := tSay():New(140,200,{|| SZ8->Z8_OPERA},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel18 := tSay():New(150,140,{|| 'Estação'},oDlg,,,,,,.T.,,,200,30)
	oSayBal     := tSay():New(150,200,{|| SZ8->Z8_BALAN},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel19 := tSay():New(160,140,{|| 'Hora:'},oDlg,,,,,,.T.,,,200,30)
	oSayHora    := tSay():New(160,200,{|| SZ8->Z8_HORA},oDlg,,oFont2,,,,.T.,,,200,30)


	nUsado := gjf34head()
	gjf34col()

	oEnc  := MSGetDados():New (220,2,266,256,2,,,,.F.,,,.F.,len(aCols),,,,,oDlg)

	@ 275,190  BUTTON 'Fechar'   SIZE 45,15 ACTION ODlg:end()  OBJECT oBtn2
	ACTIVATE MSDIALOG oDlg CENTERED
return


static function gjf34head                                                      //Monta o Header das operações registradas no historico
	Aheader := {}
	aAdd(Aheader,{'Movimento' ,'ZV_TIPO' ,'@!'        , 1    , 0 , ,, 'C' ,'SZV',})
	aAdd(Aheader,{'Data     ' ,'ZV_DATA' ,'99/99/9999', 08   , 0 , ,, 'D' ,'SZV',})
	aAdd(Aheader,{'Hora     ' ,'ZV_HORA' ,'99:99'     , 05   , 0 , ,, 'C' ,'SZV',})
	aAdd(Aheader,{'Descrição' ,'ZV_DESC' ,'@!'        , 20   , 0 , ,, 'C' ,'SZV',})
	aAdd(Aheader,{'Usuario  ' ,'ZV_USAR' ,'@!'        , 10   , 0 , ,, 'C' ,'SZV',})
	aAdd(Aheader,{'Estação  ' ,'ZV_EST'  ,'@!'        , 05   , 0 , ,, 'C' ,'SZV',})
return len(aHeader)

static Function gjf34col()                                                     //Monta o aCols dos históricos da caixa (SZV)
	Local nI, nPos
	dbselectarea('SZV')
	SZV->(dbSetOrder(1))
	if SZV->(dbSeek(xFilial('SZV')+SZ8->Z8_CONTROL,.t.))
		Do While SZV->(!Eof()) .and. SZV->ZV_FILIAL = xfilial('SZV') .and. alltrim(SZV->ZV_CONTROL) == alltrim(SZ8->Z8_CONTROL)
			aAdd(aCols,Array(nUsado+1))
			For nI := 1 to nUsado
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Next nI
			aCols[Len(aCols),nUsado+1] := .F.
			SZV->(DbSkip())
		Enddo
	endif
return

//Reimpressão da etiqueta
User Function dti112im2()


	if SZ8->Z8_TERC = 'S'
		msgbox('Caixa de produt/ de terceiros!','IMPRESSÃO IMPOSSÍVEL!','ERRO')
		return
	endif
                
	_cEst := getComputerName() 	    	    
	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	if ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	else 
		_cIp := "" 
		alert('Estação não cadastrada para impressão  !! - Verificar com seu Lider')			
	endif


	u_GJF111u(mv_par01,mv_par02,SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,;
	SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIp,SZ8->Z8_SEQPETQ,SZ8->Z8_LOTEPOR)


return

//Funçao destinada a realizar movimentações no SD3
Static Function MovSD3(mov)

	if !msgbox('Deseja que seja feito acerto com movimentação Interna (SD3)? S/N','REALIZAR MOVIMENTAÇÃO INTERNA','YESNO')
		return .f.
	endif

	cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)           //Busca a numeração sequencial

	if mov = 'E'                                     //Se o TMP2 for maior que zero, deverá haver uma devolução

		aMata240 :={{"D3_FILIAL",xfilial('SD3'),NIL},;
		{"D3_TM" ,"002"                  ,NIL},;
		{"D3_LOCAL"   ,'C0'              ,NIL},;
		{"D3_COD"     ,SZ8->Z8_COD       ,NIL},;
		{"D3_QUANT"   ,SZ8->Z8_PESO      ,NIL},;
		{"D3_EMISSAO" ,ddatabase         ,NIL},;
		{"D3_PRDNUM"  ,'XXXXXX'          ,NIL},;
		{"D3_DOC"     ,cNumDoc           ,NIL},;
		{"D3_UM"      ,'KG'              ,NIL},;
		{"D3_SEGUM"   ,'CX'              ,NIL},;
		{"D3_CC"      ,'1131002'         ,NIL},;
		{"D3_PRDITEM" ,'XX'              ,NIL} }

		msExecAuto({|x,Y| Mata240(x,Y)},aMata240,3)

	elseif 	mov = 'S'												//Se o TMP2 for menor que zero, deverá haver uma requisição

		aMata240 :={{"D3_FILIAL",xfilial('SD3'),NIL},;
		{"D3_TM" ,"502"                  ,NIL},;
		{"D3_LOCAL"   ,'C0'              ,NIL},;
		{"D3_COD"     ,SZ8->Z8_COD       ,NIL},;
		{"D3_QUANT"   ,SZ8->Z8_PESO      ,NIL},;
		{"D3_EMISSAO" ,ddatabase         ,NIL},;
		{"D3_PRDNUM"  ,'XXXXXX'          ,NIL},;
		{"D3_DOC"     ,cNumDoc           ,NIL},;
		{"D3_UM"      ,'KG'              ,NIL},;
		{"D3_SEGUM"   ,'CX'              ,NIL},;
		{"D3_CC"      ,'1131002'         ,NIL},;
		{"D3_PRDITEM" ,'XX'              ,NIL} }

		msExecAuto({|x,Y| Mata240(x,Y)},aMata240,3)

	endif
	dbclosearea()
	dbselectarea('SZ8')

Return  .t.

/*
User Function gjf34ent()
Local _lMot := .f.

if SZ8->Z8_FIL = cFilAnt
if empty(SZ8->Z8_DATAS) .and. empty(SZ8->Z8_HORAS)
msgbox('Esta caixa já encontra-se em estoque!','OPERACAO IRREGULAR','STOP')
return
endif

_lMot := DescMot('E')

if _lMot
reclock('SZ8',.f.)
SZ8->Z8_DATAS   := stod('')
SZ8->Z8_HORAS   := ''
SZ8->Z8_PREPED  := ''
SZ8->Z8_ITEM    := ''
SZ8->Z8_PRECAR  := ''
SZ8->Z8_RESERVA := ''
SZ8->Z8_DTENTES := ddatabase
SZ8->Z8_CARPICK := ''
SZ8->Z8_PICKING := ''
msunlock()

u_gjf17his(1,_cMotivo,_lRep,'','','000024')

u_gjf34wfw(SZ8->Z8_CONTROL)

//MovSD3('E')

endif
else
ZZE->(DbSetOrder(1))
if ZZE->(DbSeek(xfilial('ZZE') + SZ8->Z8_FILORI + SZ8->Z8_CODORI + xfilial('SB1')))
_cFilDes := ZZE->ZZE_FILDES
_cCodDes := ZZE->ZZE_CODDES
else
_cFilDes := xfilial('SB1')
_cCodDes := SZ8->Z8_COD
endif

_lMot := DescMot('E')

if !empty(_lMot)

reclock('SZ8',.f.)
SZ8->Z8_FIL     := _cFilDes
SZ8->Z8_COD     := _cCodDes
SZ8->Z8_DATAS   := stod('')
SZ8->Z8_HORAS   := ''
SZ8->Z8_PREPED  := ''
SZ8->Z8_ITEM    := ''
SZ8->Z8_PRECAR  := ''
SZ8->Z8_DTENTES := ddatabase
SZ8->Z8_CARPICK := ''
SZ8->Z8_PICKING := ''
msunlock()

u_gjf17his(1,_cMotivo + ' '+xfilial('SB1'),_lRep,'','','000024')

endif
endif

return


User Function gjf34sai()
Local _lMot := .f.

if SZ8->Z8_FIL = cFilAnt
if !empty(SZ8->Z8_DATAS) .and. !empty(SZ8->Z8_HORAS)
msgbox('Esta caixa já encontra-se fora de estoque!','OPERACAO IRREGULAR','STOP')
return
endif

_lMot := DescMot('S')

if _lMot
reclock('SZ8',.f.)
SZ8->Z8_DATAS   := date()
SZ8->Z8_HORAS   := time()
SZ8->Z8_PREPED  := 'ACERTO'
SZ8->Z8_ITEM    := 'EST'
SZ8->Z8_PRECAR  := 'ACERTO'
SZ8->Z8_TPROC   := '1'
SZ8->Z8_PALLET  := ''
SZ8->Z8_LOCALIZ := ''
SZ8->Z8_LOCAL   := ''
msunlock()

u_gjf17his(2,_cMotivo,_lRep,'','','000025')

//MovSD3('S')
endif
else
ZZE->(DbSetOrder(1))
if ZZE->(DbSeek(xfilial('ZZE') + SZ8->Z8_FILORI + SZ8->Z8_CODORI + xfilial('SB1')))
_cFilDes := ZZE->ZZE_FILDES
_cCodDes := ZZE->ZZE_CODDES
else
_cFilDes := xfilial('SB1')
_cCodDes := SZ8->Z8_COD
endif

_lMot := DescMot('S')

if _lMot

reclock('SZ8',.f.)
SZ8->Z8_FIL    := _cFilDes
SZ8->Z8_COD    := _cCodDes
SZ8->Z8_DATAS  := date()
SZ8->Z8_HORAS  := time()
SZ8->Z8_PREPED := 'ACERTO'
SZ8->Z8_ITEM   := 'EST'
SZ8->Z8_PRECAR := 'ACERTO'
msunlock()


u_gjf17his(1,_cMotivo + ' '+xfilial('SB1'),_lRep,'','','000024')
endif
endif

return
*/

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



//Workflow para controle de datas de produção no carregamento
User Function wfw112(_caixa)
	local _area
	local _cDest := ''
	local _user  := cUserName
	local _est   := GetComputerName()
	local _data  := dDatabase
	local _hora  := time()
	local i

	if substr(_est,1,3) <> 'PCP'
		if !empty(_cDest)
			_cDest += ','
		endif
		_cDest += 'pcp@frigorificosilva.com.br;logistica2@frigorificosilva.com.br'
	endif

	if !empty(_cDest)

		_area := getarea()

		_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
		_cMens += 'Na data e hora da emissão deste email,ocorreu uma operação de entrada de estoque' + chr(13) + chr(10)
		_cMens += 'foi realizada.' + chr(13) + chr(10)
		_cMens +=   chr(13) + chr(10)
		_cMens += 'Caixa nr.: ' + alltrim(_caixa) + chr(13) + chr(10)
		_cMens += 'Operador: '  + alltrim(_User) + chr(13) + chr(10)
		_cMens += 'Estação: '   + alltrim(_est) + chr(13) + chr(10)
		_cMens += 'Data: '      + alltrim(dtoc(_data)) + chr(13) + chr(10)
		_cMens += 'Hora: '      + alltrim(_hora) + chr(13) + chr(10)
		_cTit  := 'Workflow Frigorífico Silva: Controle de entrada e saída de caixas do estoque'

		_aEmail := u_GJF54(_cMens,_cTit,_cDest)

		for i := 1 to len(_aEmail)
			if !_aEmail[i]
				alert('ERRO WORKFLOW ('+ str(i) +')')
			endif
		next

		restarea(_area)

	endif

return
