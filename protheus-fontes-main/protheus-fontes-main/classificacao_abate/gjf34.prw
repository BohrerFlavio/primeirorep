#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF34  ºAutor  ³Giuliano Forgiarini º Data ³  02/05/08      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±            
±±ºDesc.     ³ Controle de Caixas e Manutenção de Estoque                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF34()
	Private aRotina
	Private _cUsrReim := alltrim(getMv('SI_USRREIM')) //Lista de usuários liberados para reimprimir
	Private _cUsrbxcx := alltrim(getMv('SI_USRBXCX')) //Lista de usuários liberados para dar baixa
	Private _cCodUser := retCodUsr()
	Private cPerg   := "GJF34"
	Private _lRep    := .f.       //Variavel que vai agir e definir se a saída é processo ou reprocesso 
	Private _cMotivo := space(20) 
	Private _cMotivoBxa := space(100) 

	lOk         := .f.
	oDesc       := '' 
	vNumPrev    := ''
	aIndSZ8   	:= {}					                                                               	// Arquivo e número de índice utilizado
	cCondicao 	:= ""					                                                               	// Condição para a filtragem

	Private cCadastro := "Controle de Caixas e Manutenção de Estoque"
	if _cCodUser $ _cUsrReim
		aRotina := {{"Pesquisar" ,"AxPesqui"    ,0,1},;
					{"Consultar" ,"u_gjf34con"  ,0,4},;
					{"Reimprimir","u_gjf34imp"  ,0,2},;
					{"Legenda"   ,"u_gjf34Leg"  ,0,1}}
	elseif _cCodUser $ _cUsrbxcx
		aRotina := {{"Pesquisar" ,"AxPesqui"    ,0,1},;
					{"Consultar" ,"u_gjf34con"  ,0,4},;
					{"Entrada"   ,"u_gjf34ent"  ,0,4},;
					{"Baixa"     ,"u_gjf34sai " ,0,4},;	//{"Baixa Emb.","u_gjf34szw " ,0,4},;
					{"Excluir"   ,"u_gjf34exc"  ,0,5},;
					{"Cx. Nao Encontrada"   ,"u_gjf34nao"  ,0,2},;
					{"Coleta/Sequestro"   ,"u_gjf34seq"  ,0,4},;
					{"Legenda"   ,"u_gjf34Leg"  ,0,1}}
	else
		aRotina := {{"Pesquisar" ,"AxPesqui"    ,0,1},;
					{"Consultar" ,"u_gjf34con " ,0,4},;
					{"Legenda"  , "u_gjf34Leg"  ,0,1}}
	endif

	private cString := "SZ8"

	if !pergunte(cPerg,.t.)
		return
	endif

	Private bLegenda1 := "empty(SZ8->Z8_DATAS) .and. SZ8->Z8_FIL = FWxfilial('SB1') .and. SZ8->Z8_ENCONTR <> 'N'"             // em estoque
	Private bLegenda2 := "!empty(SZ8->Z8_DATAS)"         // expedida   
	Private bLegenda3 := "empty(SZ8->Z8_DATAS) .and. SZ8->Z8_FIL <> FWxfilial('SB1')"         // em estoque
	Private bLegenda4 := "empty(SZ8->Z8_DATAS) .and. SZ8->Z8_ENCONTR = 'N' .and. SZ8->Z8_FIL = FWxFilial('SB1')"         // Não Encontrada acrescentado no dia 12/11/18 por Fabian Maurer

	Private aCores := {{bLegenda1, 'BR_VERDE'   },;      // em estoque
	{bLegenda2, 'BR_VERMELHO'},;      // expedida
	{bLegenda3, 'BR_AMARELO'},;      // expedida
	{bLegenda4, 'BR_AZUL'}}      // nao encontrada acrescentado no dia 12/11/18 por Fabian Maurer

	Private aCores2:= {{'BR_VERDE' ,'Em Estoque' },;      // bloqueado
	{'BR_VERMELHO' ,'Expedida'},;      // carregando
	{'BR_AMARELO' ,'Em Filial'},;      // carregando
	{'BR_AZUL' ,'Nao Enc'}}      // Caixa Não Encontrada acrescentado no dia 12/11/18 por Fabian Maurer

	SetKey(VK_F11,{|| posicao5()})  // F11 para scanear novas pré-etiquetas
	SetKey(123,{|| posicao()})      // F12 para consulta caixa e Histórico

	dbSelectArea(cString)
	SZ8->(dbSetOrder(1))

	mBrowse( 6, 1, 22, 75,cString,,,,,,aCores,,,,{|x| AutoRefresh(x)}) 

	DbCloseArea()

Return

User Function gjf34Leg(cAlias,nReg,nOpc)
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
		u_gjf34con()
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

user function gjf34con()
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

	if !empty(SZ8->Z8_PREDES)                                                         //se houver o apontamento de OP
		vNUMAM   := GetAdvFVal('SZ2','Z2_NUMAM',FWxfilial('SZ2')+SZ8->Z8_PREDES,2)    //numero aviso de matança

		dtAbate  := GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+vNUMAM,1)             //data do aviso de matança
		vTIP     := GetAdvFVal('SZ2','Z2_TIPIFI',FWxfilial('SC2')+SZ8->Z8_PREDES,2)   //numero aviso de matança
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
User Function gjf34imp()

	if SZ8->Z8_TERC = 'S'
		msgbox('Caixa de produto de terceiros!','IMPRESSÃO IMPOSSÍVEL!','ERRO')
		return
	endif                                   

	_cEst := getComputerName()
	_cIp := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+_cEst,1))

	If (mv_par03 = 1)
		//EMBALAGEM
		IF mv_par04 = 1//GetMv('SI_VETQEMB') = .F.
			u_GJF111f(mv_par01,mv_par02,SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,;
			SZ8->Z8_CLASSIF,SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIp,SZ8->Z8_SEQPETQ,SZ8->Z8_HORA,"R")
		ELSEIF mv_par04 = 2//GetMv('SI_VETQEMB') = .T.
			if GetAdvFVal('ZZ7','ZZ7_PAIS',FWXFilial('ZZ7')+alltrim(SZ8->Z8_COD),1) $ "607/589/493"
				u_ETQEMB(mv_par01,mv_par02,SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,;
				SZ8->Z8_CLASSIF,SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIp,SZ8->Z8_SEQPETQ,SZ8->Z8_HORA,"R")
			else
				FWAlertError("Produto não cadastrado para essas opções!","ERRO!")
			endif
		ENDIF
	Elseif  (mv_par03 = 2)
		//MIUDOS
		IF mv_par04 = 1
			u_GJF111a(mv_par01,mv_par02,SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,;
			SZ8->Z8_CLASSIF,SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIp,SZ8->Z8_SEQPETQ,SZ8->Z8_LOTEPOR,SZ8->Z8_HORA,"R")
		ELSE
			u_ETQEMBMDS(mv_par01,mv_par02,SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,;
			SZ8->Z8_CLASSIF,SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIp,SZ8->Z8_SEQPETQ,SZ8->Z8_HORA,"R")
		ENDIF
	Elseif  (mv_par03 = 3)
		//PORCIONADOS		
		u_GJF111O(mv_par01,mv_par02,SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_DATAP,(SZ8->Z8_DATAVAL),1,;
		SZ8->Z8_LOTE,_cIp, SZ8->Z8_HORA,"R")
	Endif

	u_dtilog(cFilAnt, "GJF34", "Reimpressão de etiqueta - Caixa -> " + alltrim(SZ8->Z8_CONTROL), "R")

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

//Caixa Não encontrada no Estoque
User Function gjf34nao()
Local _lMot := .f.

if !empty(SZ8->Z8_DATAS) .and. !empty(SZ8->Z8_HORAS)
	msgbox('Esta caixa já foi carregada!','OPERACAO IRREGULAR','STOP')
	return
endif


if SZ8->Z8_FIL = cFilAnt
	if SZ8->Z8_ENCONTR = 'N'
		msgbox('Esta caixa ainda não foi encontrada!','OPERACAO IRREGULAR','STOP')
		return
	endif

	_lMot := DescMot('M')

		if _lMot
			reclock('SZ8',.f.)
			SZ8->Z8_ENCONTR := 'N'
			msunlock()

			u_gjf17his(3,_cMotivo,_lRep,'','','000032',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
		endif
else
	ZZE->(DbSetOrder(1))
	if ZZE->(MsSeek(FWxfilial('ZZE') + SZ8->Z8_FILORI + SZ8->Z8_CODORI + FWxfilial('SB1')))
		_cFilDes := ZZE->ZZE_FILDES
		_cCodDes := ZZE->ZZE_CODDES
	else
		_cFilDes := FWxfilial('SB1')
		_cCodDes := SZ8->Z8_COD
	endif

	_lMot := DescMot('M') 

	if !empty(_lMot)

		reclock('SZ8',.f.)
		SZ8->Z8_ENCONTR := 'N'
		msunlock()

		u_gjf17his(1,_cMotivo + ' '+FWxfilial('SB1'),_lRep,'','','000032',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

	endif		
endif

return

User Function gjf34ent()  
	Local _lMot := .f.

	if SZ8->Z8_FIL = cFilAnt
		//if empty(SZ8->Z8_DATAS) .and. empty(SZ8->Z8_HORAS) Alterado por Fabian Maurer dia 13/11/18
		if empty(SZ8->Z8_DATAS) .and. empty(SZ8->Z8_HORAS) .and. SZ8->Z8_ENCONTR <> 'N'
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
			if SZ8->Z8_ENCONTR = 'N'
				SZ8->Z8_ENCONTR := 'S'
			else
				SZ8->Z8_ENCONTR := ''
			endif	
			msunlock()

			u_gjf17his(1,_cMotivo,_lRep,'','','000024',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

			u_gjf34wfw(SZ8->Z8_CONTROL)

			//MovSD3('E')

		endif
	else
		ZZE->(DbSetOrder(1))
		if ZZE->(MsSeek(FWxfilial('ZZE') + SZ8->Z8_FILORI + SZ8->Z8_CODORI + FWxfilial('SB1')))
			_cFilDes := ZZE->ZZE_FILDES
			_cCodDes := ZZE->ZZE_CODDES
		else
			_cFilDes := FWxfilial('SB1')
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
			if SZ8->Z8_ENCONTR = 'N'
				SZ8->Z8_ENCONTR := 'S'
			else
				SZ8->Z8_ENCONTR := ''
			endif	
			msunlock()

			u_gjf17his(1,_cMotivo + ' '+FWxfilial('SB1'),_lRep,'','','000024',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

		endif
	endif

return            


/*User Function gjf34szw()

	Private cCaixa := space(11)
	_cMens1 := ''
	_cMens2 := ''
	cont   := 0
	campo1 := space(11)

	DEFINE MSDIALOG oDlgR TITLE 'Exclusão de caixas fora de estoque:' from 000,000 To 200,550 OF oMainWnd PIXEL

	@ 011,010 SAY  'Caixa:' Object oSay2

	@ 001,004 MSGET campo1 VAR cCaixa Size 60,11 of oDlgR VALID ValidSZW()

	oFont   := tFont():New("courier new",,-20,,.t.,,,,)
	oSayD1  := tSay():New(30,10,{|| _cMens1 },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,250,50)
	oSayD2  := tSay():New(30,10,{|| _cMens2 },oDlgR,,oFont,,,,.T.,CLR_HRED,CLR_HRED,250,50)
	oSayD3  := tSay():New(10,160,{|| str(cont) },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)

	@ 80,245 BMPBUTTON TYPE 1 ACTION oDlgR:end() Object Obtn1
	@ 80,214 BMPBUTTON TYPE 2 ACTION oDlgR:end() Object Obtn1

	ACTIVATE MSDIALOG oDlgR CENTERED

Return*/

/*Static Function ValidSZW()

	Local lRet := .t.

	if len(alltrim(cCaixa)) < 10
		_cMens2 := 'Código de caixa incorreto!'
		_cMens1 := ''
		lRet := .f.
	endif

	ZAS->(dbsetorder(1))
	ZAS->(DbGoTop())
	SZW->(dbsetorder(2))
	SZW->(DbGoTop())
	if SZW->(Msseek(FWxfilial('SZW') + alltrim(cCaixa)))

		if !(FWAlertYesNo("Tem certeza que deseja excluir esta caixa? (Peso = " + Transform(SZW->ZW_PESO,'@E 999.99') + " kg)", "CONFIRMA"))
			_cMens2 := 'Operação cancelada!'
			_cMens1 := ''
			lRet := .f.
		else
			SZ8->(dbsetorder(3))
			SZ8->(DbGoTop())
			if SZ8->(Msseek(FWxfilial('SZ8') + alltrim(cCaixa))) .and. !empty(SZ8->Z8_DATAS)
				_cMens2 := 'Esta caixa já está fora de estoque!'
				_cMens1 := ''
				lRet := .F.
			else
				if SZW->ZW_TIPOPRO = "MP"
					if ZAS->(Msseek(FWxfilial('ZAS') + alltrim(cCaixa)))
						reclock('ZAS',.f.)
						ZAS->ZAS_DATAS  := date()
						ZAS->ZAS_HORAS  := time()
						ZAS->ZAS_MOREEN := 'BAIXA'
						msunlock()

						reclock('ZAS',.f.)
						DbDelete()
						msunlock()
					else
						_cMens1 := ''
						_cMens2 := 'Caixa não encontrada na ZAS!'
					endif
				endif

				if empty(SZW->ZW_DATAS)
					reclock('SZW',.f.)
					SZW->ZW_HORAE   := time()
					SZW->ZW_DATAE   := date()
					SZW->ZW_OPERE   := cUserName
					SZW->ZW_PALLET  := 'BAIXA'
					SZW->ZW_LOCALIZ := 'BAIXA'
					SZW->ZW_LOCAL   := 'BX'
					SZW->ZW_HORAS   := time()
					SZW->ZW_DATAS   := date()
					SZW->ZW_OPERA   := cUserName
					msunlock()

					u_gjf17his(2,"Baixa manual SZW",.f.,'','','000025',SZW->ZW_CONTROL,,,)
				endif

				if SZ8->(Msseek(FWxfilial('SZ8') + alltrim(cCaixa))) .and. empty(SZ8->Z8_DATAS)
					reclock('SZ8',.f.)
					SZ8->Z8_DATAS   := date()
					SZ8->Z8_HORAS   := time()
					SZ8->Z8_PREPED  := 'BAIXA' //'ACERTO'
					SZ8->Z8_ITEM    := 'EST'
					SZ8->Z8_PRECAR  := 'BAIXA' //'ACERTO'
					SZ8->Z8_TPROC   := '1'
					SZ8->Z8_PALLET  := ''
					SZ8->Z8_LOCALIZ := ''
					SZ8->Z8_LOCAL   := ''
					msunlock()

					u_gjf17his(1,'Baixa manual SZ8',_lRep,'','','000024',SZ8->Z8_CONTROL,,,)
				else
					_cMens1 := ''
					_cMens2 := 'Caixa já baixada!'
					lRet := .f.
				endif
			endif

		endif
	else
		_cMens1 := ''
		_cMens2 := 'Caixa não encontrada!'
		lRet := .f.
	endif

	oSayD1:SetText(_cMens1)
	oSayD2:SetText(_cMens2)
	oSayD3:SetText(str(cont))

	oDlgR:refresh()
	cCaixa := space(11)
	campo1:setfocus()

return lRet*/


User Function gjf34sai()
	Local _lMot  := .f.
	Local nQRealC := 0
	Local nQRealP := 0
	Local nQRealQ := 0
	Local nRealSM := 0

	if SZ8->Z8_FIL = cFilAnt
		if !empty(SZ8->Z8_DATAS)
			msgbox('Esta caixa já está fora de estoque!','OPERACAO IRREGULAR','STOP')
			return
		endif

		_lMot := DescMot('S')
		if _lMot
			IF (Empty(_cMotivoBxa))
				MsgAlert("Obrigatório informar o motivo da baixa","Alerta")
				Return .F.
			ELSE
				reclock('SZ8',.f.)
				SZ8->Z8_DATAS   := date()
				SZ8->Z8_HORAS   := time()
				SZ8->Z8_PREPED  := _cMotivo //'ACERTO'
				SZ8->Z8_ITEM    := 'EST'
				SZ8->Z8_PRECAR  := _cMotivo //'ACERTO'
				SZ8->Z8_TPROC   := '1'
				SZ8->Z8_PALLET  := ''
				SZ8->Z8_LOCALIZ := ''
				SZ8->Z8_LOCAL   := ''
				SZ8->Z8_MOTBAIX := _cMotivoBxa
				msunlock()
			ENDIF

			SZW->(dbsetorder(2))
			SZW->(DbGoTop())
			if SZW->(Msseek(FWxfilial('SZW') + alltrim(SZ8->Z8_CONTROL))) .and. empty(SZW->ZW_DATAS)

				reclock('SZW',.f.)
				SZW->ZW_HORAE   := time()
				SZW->ZW_DATAE   := date()
				SZW->ZW_OPERE   := cUserName
				SZW->ZW_PALLET  := 'BAIXA'
				SZW->ZW_LOCALIZ := 'BAIXA'
				SZW->ZW_LOCAL   := 'BX'
				SZW->ZW_HORAS   := time()
				SZW->ZW_DATAS   := date()
				SZW->ZW_OPERA   := cUserName
				msunlock()

				u_gjf17his(2,"Baixa manual SZW",.f.,'','','000025',SZW->ZW_CONTROL,,,)
			endif

			SZU->(DbSetOrder(2))
			if SZU->(MsSeek(FWxFilial('SZU')+SZ8->Z8_NUMPREV))
				nQRealC := SZU->ZU_QRCAIX
				nQRealP := SZU->ZU_QRPESO
				nQRealQ := SZU->ZU_QRQUANT

				reclock('SZU',.f.)
				SZU->ZU_QRCAIX  := nQRealC - 1
				SZU->ZU_QRPESO  := nQRealP - SZ8->Z8_PESO
				SZU->ZU_QRQUANT := nQRealQ - SZ8->Z8_QUANT
				SZU->ZU_FECHADO := iif(SZU->ZU_FECHADO = 'S', 'B', SZU->ZU_FECHADO)
				msunlock()
				if !empty(SZU->ZU_SHIPPIN)
					ZY2->(DbSetOrder(1))
					if ZY2->(MsSeek(FWxFilial('ZY2')+SZU->ZU_SHIPPIN))
						nRealSM := ZY2->ZY2_QTRCXS
						reclock('ZY2',.f.)
						ZY2->ZY2_QTRCXS := nRealSM - 1
						msunlock()
					endif
				endif
			endif

			u_gjf17his(2,_cMotivo,_lRep,'','','000025',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

			//MovSD3('S')
		endif
	else   
		ZZE->(DbSetOrder(1))
		if ZZE->(MsSeek(FWxfilial('ZZE') + SZ8->Z8_FILORI + SZ8->Z8_CODORI + FWxfilial('SB1')))
			_cFilDes := ZZE->ZZE_FILDES
			_cCodDes := ZZE->ZZE_CODDES
		else
			_cFilDes := FWxfilial('SB1')
			_cCodDes := SZ8->Z8_COD
		endif  

		_lMot := DescMot('S')

		if _lMot

			reclock('SZ8',.f.)
			SZ8->Z8_FIL    := _cFilDes
			SZ8->Z8_COD    := _cCodDes
			SZ8->Z8_DATAS  := date()
			SZ8->Z8_HORAS  := time()
			SZ8->Z8_PREPED := _cMotivo//'ACERTO'
			SZ8->Z8_ITEM   := 'EST'
			SZ8->Z8_PRECAR := _cMotivo//'ACERTO'
			msunlock()

			SZW->(dbsetorder(2))
			SZW->(DbGoTop())
			if SZW->(Msseek(FWxfilial('SZW') + alltrim(SZ8->Z8_CONTROL)))

				reclock('SZW',.f.)
				SZW->ZW_HORAE   := time()
				SZW->ZW_DATAE   := date()
				SZW->ZW_OPERE   := cUserName
				SZW->ZW_PALLET  := 'BAIXA'
				SZW->ZW_LOCALIZ := 'BAIXA'
				SZW->ZW_LOCAL   := 'BX'
				SZW->ZW_HORAS   := time()
				SZW->ZW_DATAS   := date()
				SZW->ZW_OPERA   := cUserName
				msunlock()

				u_gjf17his(2,"Baixa manual SZW",.f.,'','','000025',SZW->ZW_CONTROL,,,)
			endif

			u_gjf17his(1,_cMotivo + ' ',_lRep,'','','000024',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
		endif
	endif

return

// Rotina para realizar sequestro de caixas conforme parâmetros
User Function gjf34seq()

	Local _cPerg := "GJF34SEQ"
	Local _cMotiv := ""
	Local _nCount := 0
	Local _cTipo := ""

	if !pergunte(_cPerg,.t.)
		return
	endif

	if mv_par05 = 1
		_cMotiv := "COLETA"
	else
		_cMotiv := "SEQUESTRO"
	endif

	if mv_par07 = 1
		_cTipo := "PA"
	else
		_cTipo := "MP"
	endif

	if mv_par06 = 1
		if mv_par07 = 1
			_nCount := QuerySeq(1,dtos(mv_par02),mv_par03,mv_par04,mv_par01,_cMotiv,1)
		else 
			_nCount := QuerySeq(1,dtos(mv_par02),mv_par03,mv_par04,mv_par01,_cMotiv,2)
		endif
	else
		if mv_par07 = 1
			_nCount := QuerySeq(2,dtos(mv_par02),mv_par03,mv_par04,mv_par01,_cMotiv,1)
		else 
			_nCount := QuerySeq(2,dtos(mv_par02),mv_par03,mv_par04,mv_par01,_cMotiv,2)
		endif
	endif

	if _nCount <= 0
		if mv_par06 = 1
			FWAlertWarning("Sem caixas para sequestrar nos parâmetros selecionados!","AVISO")
		else
			FWAlertWarning("Sem caixas para retornar nos parâmetros selecionados!","AVISO")
		endif
		return
	endif

	if !FWAlertYesNo("Tem certeza que quer sequestar as caixas nos seguintes parâmetros?"+chr(13)+chr(10)+"Produto: "+mv_par01+chr(13)+chr(10)+"Data de Produção: ";
					+dtoc(mv_par02)+chr(13)+chr(10)+"De hora: "+mv_par03+" Até hora: "+mv_par04+chr(13)+chr(10)+"Motivo: "+_cMotiv;
					+chr(13)+chr(10)+"Total de caixas: "+transform(_nCount,'@E 999')+chr(13)+chr(10)+"Tipo: "+_cTipo, "CONFIRMA")
		return
	endif

	QRY->(dbGoTop())
	if mv_par07 = 1
		SZ8->(dbsetorder(3))
		SZ8->(DbGoTop())
	else 
		ZAS->(dbsetorder(1))
		ZAS->(DbGoTop())
	endif

	While QRY->(!EOF())
		if mv_par07 = 1
			if SZ8->(MsSeek(FWxfilial('SZ8') + alltrim(QRY->CAIXA)))
				if mv_par06 = 1
					reclock('SZ8',.f.)
					SZ8->Z8_DATAS   := date()
					SZ8->Z8_HORAS   := time()
					SZ8->Z8_PREPED  := substr(_cMotiv,1,6)
					SZ8->Z8_ITEM    := substr(_cMotiv,1,3)
					SZ8->Z8_PRECAR  := substr(_cMotiv,1,6)
					SZ8->Z8_MOTBAIX := _cMotiv
					msunlock()
					u_gjf17his(2,_cMotiv,_lRep,'','','000025',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
				else
					reclock('SZ8',.f.)
					SZ8->Z8_DATAS   := stod("")
					SZ8->Z8_HORAS   := ""
					SZ8->Z8_PREPED  := ""
					SZ8->Z8_ITEM    := ""
					SZ8->Z8_PRECAR  := ""
					SZ8->Z8_DTENTES := ddatabase
					msunlock()
					u_gjf17his(1,_cMotiv,_lRep,'','','000024',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
				endif
			endif
		else
			if ZAS->(MsSeek(FWxfilial('ZAS') + alltrim(QRY->CAIXA)))
				if mv_par06 = 1
					reclock('ZAS',.f.)
					ZAS->ZAS_DATAS   := date()
					ZAS->ZAS_HORAS   := time()
					ZAS->ZAS_MOTS	 := _cMotiv
					msunlock()
					u_gjf17his(2,_cMotiv,_lRep,'','','000025',ZAS->ZAS_CONTROL,ZAS->ZAS_LOCAL,,)
				else
					reclock('ZAS',.f.)
					ZAS->ZAS_DATAS   := stod("")
					ZAS->ZAS_HORAS   := ""
					ZAS->ZAS_MOTS	 := ""
					ZAS->ZAS_DTREEN  := date()
					ZAS->ZAS_HRRENT  := time()
					ZAS->ZAS_MOREEN	 := _cMotiv
					msunlock()
					u_gjf17his(1,_cMotiv,_lRep,'','','000024',ZAS->ZAS_CONTROL,ZAS->ZAS_LOCAL,,)
				endif
			endif
		endif

		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    enddo

	if mv_par06 = 1
		FWAlertSuccess("Caixas sequestradas com sucesso!","SUCESSO")
	else
		FWAlertSuccess("Caixas retornadas com sucesso!","SUCESSO")
	endif

Return

// Query para buscar as caixas que serão sequestradas
Static Function QuerySeq(_nModo,_cDataP, _cHoraI, _cHoraf, _cCod,_cMot,_nTipo)

	Local _cQuery := ""
	Local nCount := 0

	if mv_par07 = 1
		if _nModo = 1
			_cQuery := "SELECT Z8_CONTROL AS CAIXA"
			_cQuery += " FROM " + retSqlTab('SZ8')
			_cQuery += " WHERE " + retSqlFil('SZ8')
			_cQuery += " AND Z8_FIL = '" + cFilAnt + "'"
			_cQuery += " AND Z8_DATAP = '" + _cDataP + "'"
			_cQuery += " AND Z8_HORA BETWEEN '" + _cHoraI + "' AND '" + _cHoraf + "'"
			_cQuery += " AND Z8_COD = '" + _cCod + "'"
			_cQuery += " AND Z8_DATAS = ''"
			_cQuery += " AND " + retSqlDel('SZ8')
			_cQuery += " ORDER BY Z8_DATAP, Z8_HORA"
		else
			_cQuery := "SELECT Z8_CONTROL AS CAIXA"
			_cQuery += " FROM " + retSqlTab('SZ8')
			_cQuery += " WHERE " + retSqlFil('SZ8')
			_cQuery += " AND Z8_FIL = '" + cFilAnt + "'"
			_cQuery += " AND Z8_DATAP = '" + _cDataP + "'"
			_cQuery += " AND Z8_COD = '" + _cCod + "'"
			_cQuery += " AND Z8_MOTBAIX = '" + _cMot + "'"
			_cQuery += " AND " + retSqlDel('SZ8')
			_cQuery += " ORDER BY Z8_DATAP, Z8_HORA"
		endif
	else
		if _nModo = 1
			_cQuery := "SELECT ZAS_CONTRO AS CAIXA"
			_cQuery += " FROM " + retSqlTab('ZAS')
			_cQuery += " WHERE " + retSqlFil('ZAS')
			_cQuery += " AND ZAS_DTPROD = '" + _cDataP + "'"
			_cQuery += " AND ZAS_HORA BETWEEN '" + _cHoraI + "' AND '" + _cHoraf + "'"
			_cQuery += " AND ZAS_COD = '" + _cCod + "'"
			_cQuery += " AND ZAS_DATAS = ''"
			_cQuery += " AND " + retSqlDel('ZAS')
			_cQuery += " ORDER BY ZAS_DTPROD, ZAS_HORA"
		else
			_cQuery := "SELECT ZAS_CONTRO AS CAIXA"
			_cQuery += " FROM " + retSqlTab('ZAS')
			_cQuery += " WHERE " + retSqlFil('ZAS')
			_cQuery += " AND ZAS_DTPROD = '" + _cDataP + "'"
			_cQuery += " AND ZAS_COD = '" + _cCod + "'"
			_cQuery += " AND ZAS_MOTS = '" + _cMot + "'"
			_cQuery += " AND " + retSqlDel('ZAS')
			_cQuery += " ORDER BY ZAS_DTPROD, ZAS_HORA"
		endif
	endif

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	QRY->(dbGoTop())

    //verifica se houve retorno na query
    Count to nCount

Return nCount

//Exclusão definitiva de uma pesagem do sistema
User Function gjf34exc()

	Local nQRealC := 0
	Local nQRealP := 0
	Local nQRealQ := 0
	Local nRealSM := 0

	if !u_gjf34CCX(SZ8->Z8_DATA)
		return .f.
	endif

	if !msgbox('Esta operação irá excluir um registro de produção do Sistema. Deseja prosseguir? (S/N)','OPERAÇÃO CRITICA!!','YESNO')   
		return .f.
	endif  


	if SZ8->Z8_FIL <> FWxfilial('SB1')
		msgbox('Caixa estocada em outra filial','OPERAÇÃO IRREGULAR','STOP')
		return .f.
	endif     

	if !empty(SZ8->Z8_DATAS) .and. !empty(SZ8->Z8_HORAS)
		msgbox('Esta caixa já encontra-se fora de estoque!','OPERACAO IRREGULAR','STOP')
		return	
	endif

	SZU->(DbSetOrder(2))
	if SZU->(MsSeek(FWxFilial('SZU')+SZ8->Z8_NUMPREV))
		nQRealC := SZU->ZU_QRCAIX - 1
		nQRealP := SZU->ZU_QRPESO - SZ8->Z8_PESO
		nQRealQ := SZU->ZU_QRQUANT - SZ8->Z8_QUANT

		reclock('SZU',.f.)
		SZU->ZU_QRCAIX  := nQRealC
		SZU->ZU_QRPESO  := nQRealP
		SZU->ZU_QRQUANT := nQRealQ
		SZU->ZU_FECHADO := iif(SZU->ZU_FECHADO = 'S', 'B', SZU->ZU_FECHADO)
		msunlock()
		if !empty(SZU->ZU_SHIPPIN)
			ZY2->(DbSetOrder(1))
			if ZY2->(MsSeek(FWxFilial('ZY2')+SZU->ZU_SHIPPIN))
				nRealSM := ZY2->ZY2_QTRCXS - 1
				reclock('ZY2',.f.)
				ZY2->ZY2_QTRCXS := nRealSM
				msunlock()
			endif
		endif
	endif

	u_gjf17his(2,'EXCLUSAO DA PRODUÇAO',_lRep,'','','000011',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

	reclock('SZ8',.f.)
	SZ8->Z8_DATAE := date()
	SZ8->Z8_HORAE := time()
	msunlock() 

	reclock('SZ8',.f.)
	DbDelete()
	msunlock()      

	//MovSD3('S')	

return            

static function DescMot(Mot)                                                        //Cria a caixa de diálogo para localizar uma caixa
	Local _lOk := .f.

	_cMotivo := space(20)
	_lRep    := .f.

	DEFINE MSDIALOG oDlg2 TITLE 'Motivo da Movimentação:' from 000,000 To 100,260 OF oMainWnd PIXEL
	@ 010,003 SAY  'Historico:' Object oSay1 
	@ 010,025 GET _cMotivo PICTURE "@!" F3 'SX5ES' SIZE 60,11 Object oCaixa

	@ 025,003 SAY  'Motivo da baixa:' Object oSay2
	@ 025,025 GET _cMotivoBxa PICTURE "@!" SIZE 60,11 Object oCaixa
	//@ 010,025 MSGET _cMotivo SIZE 60,11 OF oMainWnd PIXEL PICTURE "@!" F3 'SX5ES'
	
	if Mot = 'S' 
		@ 040,003 checkbox 'Reprocesso?' VAR _lRep Object oCheck   
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

////Função que controla o período apto para excluir caixas////
User Function gjf34CCX(_dDtProd)

	Local _dUlMes := GetMv("MV_ULMES")  
	Local ret     := .t.

	if _dDtProd <= _dUlMes
		msgbox('Data de produção da caixa anterior a data de fechamento do mes!','OPERAÇÃO INVALIDA!','STOP')
		ret := .f.
	endif

Return ret  

//Workflow para controle de datas de produção no carregamento
User Function gjf34wfw(_caixa)
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
// 02000026920775   - 14 caracteres
_c1 := substr(cPreE,1,2)
_c2 := substr(cPreE,3,3)
_c3 := substr(cPreE,6,9)

_CSeqpE := alltrim(_c1)+'000'+alltrim(_c3)
	
	SZ8->(dbsetorder(16))                        
	if SZ8->(Msseek(FWxfilial('SZ8')+alltrim(_CSeqpE),.t.))  
		u_gjf34con()
		//alert('Caixa ->'+SZ8->Z8_CONTROL)
		// Falta chamar a rotina para reimpressão da etiqueta 
		//U_gjf34imp()

	else
		msgbox('Caixa não encontrada!','OPERAÇÃO INCONSISTENTE!','STOP')
	endif   
	
return
