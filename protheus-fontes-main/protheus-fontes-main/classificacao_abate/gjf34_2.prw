#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF34_2 ºAutor  ³ FLávio BOhrer Flôres º Data ³  17/08/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa, Consulta e reimpressão de Caixas                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF34_2()

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
	{"Consultar" ,"u_gjf34co2 " ,0,4},;
	{"Legenda"  , "u_Leg" ,0,1}} //{"Reimprimir","u_gjf34im2"  ,0,2},; Mudança para remover reimpressão - 21/06/23

	private cString := "SZ8"

	if !pergunte(cPerg,.t.)
		return
	endif

	Private bLegenda1 := "empty(SZ8->Z8_DATAS) .and. SZ8->Z8_FIL = FWxfilial('SB1')"             // em estoque
	Private bLegenda2 := "!empty(SZ8->Z8_DATAS)"         // expedida
	Private bLegenda3 := "empty(SZ8->Z8_DATAS) .and. SZ8->Z8_FIL <> FWxfilial('SB1')"         // em estoque


	Private aCores := {{bLegenda1, 'BR_VERDE'   },;      // em estoque
	{bLegenda2, 'BR_VERMELHO'},;      // expedida
	{bLegenda3, 'BR_AMARELO'}}      // expedida

	Private aCores2:= {{'BR_VERDE' ,'Em Estoque' },;      // bloqueado
	{'BR_VERMELHO' ,'Expedida'},;      // carregando
	{'BR_AMARELO' ,'Em Filial'}}      // carregando

	SetKey(VK_F11,{|| posicao5()})  // F11 para scanear novas pré-etiquetas
	SetKey(123,{|| posicao()})		// Desativa a tecla F12 do acionamento dos parametros

	dbSelectArea(cString)
	SZ8->(dbSetOrder(1))


	mBrowse( 6, 1, 22, 75,cString,,,,,,aCores,,,,{|x| AutoRefresh(x)})
		

	DbCloseArea('SZ8')

Return

User Function Leg(cAlias,nReg,nOpc)
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
	if SZ8->(Msseek(FWxfilial('SZ8')+cCaixa,.t.))
		u_gjf34co2('C')
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
	if !SZ8->(Msseek(FWxfilial('SZ8')+cPreETQ))
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

user function gjf34co2()
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	//RegToMemory("SZ8",.f.)

	descP := GetAdvFVal('SB1','B1_DESC',SZ8->(Z8_FILORI+Z8_CODORI),1)

	campo1 := space(20)
	valor1 := space(20)
	campo2 := CTBCBOX('ZV_TIPO')                                                   //Aponta o tipo de operação a ser feita
	valor2 := space(10)

	_cRua    := substr(SZ8->Z8_LOCALIZ,3,2)
	_cPredio := substr(SZ8->Z8_LOCALIZ,5,2)
	_cAndar  := substr(SZ8->Z8_LOCALIZ,7,2)
	_cApto   := substr(SZ8->Z8_LOCALIZ,9,2)

	if !empty(SZ8->Z8_PREDES)                                                            // se houver o apontamento de OP...
		vNUMAM   := GetAdvFVal('SZ2','Z2_NUMAM',FWxfilial('SZ2')+SZ8->Z8_PREDES,2)          //numero aviso de matança

		dtAbate  := GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+vNUMAM,1)             //data do aviso de matança
		vTIP     := GetAdvFVal('SZ2','Z2_TIPIFI',FWxfilial('SC2')+SZ8->Z8_PREDES,2)          //numero aviso de matança
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


static function gjf34head()                                                    //Monta o Header das operações registradas no historico
	Aheader := {}
	aAdd(Aheader,{'Movimento' ,'ZV_TIPO' ,'@!'        , 1    , 0 , ,, 'C' ,'SZV',})
	aAdd(Aheader,{'Data     ' ,'ZV_DATA' ,'99/99/9999', 08   , 0 , ,, 'D' ,'SZV',})
	aAdd(Aheader,{'Hora     ' ,'ZV_HORA' ,'99:99'     , 05   , 0 , ,, 'C' ,'SZV',})
	aAdd(Aheader,{'Descrição' ,'ZV_DESC' ,'@!'        , 20   , 0 , ,, 'C' ,'SZV',})
	aAdd(Aheader,{'Usuario  ' ,'ZV_USAR' ,'@!'        , 10   , 0 , ,, 'C' ,'SZV',})
	aAdd(Aheader,{'Estação  ' ,'ZV_EST'  ,'@!'        , 05   , 0 , ,, 'C' ,'SZV',})
return len(aHeader)

static Function gjf34col()                                                     //Monta o aCols dos históricos da caixa (SZV)
	Local nI
	dbselectarea('SZV')
	SZV->(dbSetOrder(1))
	if SZV->(MsSeek(FWxFilial('SZV')+SZ8->Z8_CONTROL,.t.))
		Do While SZV->(!Eof()) .and. SZV->ZV_FILIAL = FWxfilial('SZV') .and. alltrim(SZV->ZV_CONTROL) == alltrim(SZ8->Z8_CONTROL)
			if SZV->ZV_CODMSG != '000034'
				aAdd(aCols,Array(nUsado+1))
				For nI := 1 to nUsado
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Next nI
				aCols[Len(aCols),nUsado+1] := .F.
			endif
			SZV->(DbSkip())
		Enddo
	endif
return

//Reimpressão da etiqueta
User Function gjf34im2()

	//RegToMemory("SZ8",.F.)
	if SZ8->Z8_TERC = 'S'
		msgbox('Caixa de produt/ de terceiros!','IMPRESSÃO IMPOSSÍVEL!','ERRO')
		return
	endif

	//u_GJF111b(mv_par01,mv_par02,SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,;
	//	                       SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,'')

	/* 
	_cEst := getComputerName()   
	if alltrim(_cEst) == 'PEX01'
	_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + 'IPAL1',1))
	Elseif  alltrim(_cEst) == 'PAC01'
	_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + 'PAC01',1))
	Elseif  alltrim(_cEst) == 'MDS04'   
	_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + 'IMDS2','ZAM_IP',1))  
	else
	_cIp  := ''
	endif           
	Alterado por Flávio dia  26/03/2018
	*/                       
	_cEst := getComputerName() 	    	    
	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	if ZAM->(MsSeek(FWxFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	else 
		_cIp := "" 
		alert('Estação não cadastrada para impressão  !! - Verificar com seu Lider')			
	endif
	
	IF  'MDS' $ SZ8->Z8_BALAN
		
		u_GJF111a(mv_par01,mv_par02,SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,;
		SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIp,SZ8->Z8_SEQPETQ,SZ8->Z8_HORA) 

	elseif  'EMB' $ SZ8->Z8_BALAN
		
		u_GJF111f(mv_par01,mv_par02,SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,;
		SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIp,SZ8->Z8_SEQPETQ,SZ8->Z8_HORA)
		
		/*
		u_GJF111p(mv_par01,mv_par02,SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,;
		SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIp,SZ8->Z8_HORA)
		*/
	else			
		GJF111O(_modelo,_porta,_control,_cod,_pesob,_pesol,_tara,_datap,_dataval,_nNumEtq,_lote,_IP,_hora)
	Endif
	//alert('linha 308')
	/*		
	u_GJF111O(mv_par01,mv_par02,'0019671986','011769','7.05','7.05','0.001',stod('20220812'),(_dDataAtu+'60'),1,'0000130090','',_cIp) 
	*/

return

//Funçao destinada a realizar movimentações no SD3
Static Function MovSD3(mov)

	if !msgbox('Deseja que seja feito acerto com movimentação Interna (SD3)? S/N','REALIZAR MOVIMENTAÇÃO INTERNA','YESNO')
		return .f.
	endif

	cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)           //Busca a numeração sequencial

	if mov = 'E'                                     //Se o TMP2 for maior que zero, deverá haver uma devolução

		aMata240 :={{"D3_FILIAL",FWxfilial('SD3'),NIL},;
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

		aMata240 :={{"D3_FILIAL",FWxfilial('SD3'),NIL},;
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
User Function wfw(_caixa)
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
	if SZ8->(Msseek(FWxfilial('SZ8')+alltrim(_CSeqpE),.t.))  
		//U_gjf34imp()
		u_gjf34con()
	else
		msgbox('Caixa não encontrada!','OPERAÇÃO INCONSISTENTE!','STOP')
	endif   
	
return
