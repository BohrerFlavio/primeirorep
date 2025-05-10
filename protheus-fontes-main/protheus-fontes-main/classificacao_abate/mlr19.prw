#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  º Autor  ³ Mauricio Roehrs       º Data ³  26/08/13		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle de Peças e Manutenção de Estoque                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MLR19()

	cString     := "ZAJ"
	lOk         := .f.
	oDesc       := ''
	aIndSZ8   	:= {}					// Arquivo e número de índice utilizado
	cCondicao 	:= ""
	_cDest		:= ""
	dbSelectArea(cString)

	// Condição para a filtragem
	Private cPerg   := "MLR19"

	Private _cMotivo := space(20)

	Private cCadastro := "Controle de Peças e Manutenção de Estoque"
	Private aRotina := { {"Pesquisar" ,"AxPesqui",0,1},;
	{"Consultar" ,"u_mlr19Cons " ,0,4},;
	{"Entrada"   ,"u_mlr19Ent"  	,0,4},;
	{"Baixa"     ,"u_mlr19Sai " 	,0,4},;
	{"Baixa P/Dia","u_mlr192" 	,0,4},;
	{"Reimprimir","u_mlr19Imp" ,0,4},;
	{"Legenda"   ,"u_mlr19Leg" 	,0,1}}

	if !pergunte(cPerg,.t.)
		return
	endif

	Private bLegenda1 := "empty(ZAJ->ZAJ_DATAS) .and. empty(ZAJ->ZAJ_HORAS)"      // em estoque
	Private bLegenda2 := "!empty(ZAJ->ZAJ_PREPED) .and. !empty(ZAJ->ZAJ_PRECAR)"  // expedida
	Private bLegenda3 := "(!empty(ZAJ->ZAJ_DATAS) .and. !empty(ZAJ->ZAJ_HORAS)) .and. (empty(ZAJ->ZAJ_PREPED) .and. empty(ZAJ->ZAJ_PRECAR))" 		// Entrada desossa

	Private aCores := {{bLegenda1, 'BR_VERDE'  },; // em estoque
	{bLegenda2, 'BR_VERMELHO'},; // expedida
	{bLegenda3, 'BR_AMARELO'}}   //Entrada Desossa

	Private aCores2:= {{'BR_VERDE' ,'Em Estoque' },;      // em estoque
	{'BR_VERMELHO' ,'Carregada'},;      // carregando
	{'BR_AMARELO' ,'Entrada Desossa'}} //Entrada Desossa

	mBrowse( 6, 1, 22, 75,cString,,,,,,aCores,,,,{|x| AutoRefresh(x)})

	Set Key 123 To 							// Desativa a tecla F12 do acionamento dos parametros

	DbCloseArea()

Return


User Function mlr19Leg(cAlias,nReg,nOpc)
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return


static function preenche()                            //Função que preeche o codigo do produto com zeros
	if !empty(alltrim(cCaixa))
		cCaixa := padl(alltrim(cCaixa),10,"0")
	endif
return .t.


user function mlr19Cons()
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0

	campo1 := space(20)
	valor1 := space(20)
	campo2 := CTBCBOX('ZAK_TIPO')                       //Aponta o tipo de operação a ser feita
	valor2 := space(10)

	descP 		:= ZAJ->ZAJ_DESCRI
	cNumam      := ZAJ->ZAJ_NUMAM
	cLote       := ZAJ->ZAJ_LOTE
	cControl    := ZAJ->ZAJ_CONTRO

	SZK->(DbSetOrder(4))
	SZK->(MsSeek(FWxfilial('SZK') + cNUMAM + cControl))
	dtAbate     := GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG') + cNUMAM,1)
	cTF 		:= SZK->ZK_DESTINO
	cCam        := SZK->ZK_LOCAL
	cHour 	    := SZK->ZK_HORA
	cCobGor     := SZK->ZK_COBGOR
	cDent       := SZK->ZK_DENT
	cProgram  	:= GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6') + SZK->ZK_PROGRAM,1)
	cClassif  	:= SZK->ZK_CLASSIF
	cClasAba  	:= SZK->ZK_CLASABA
	cRaca     	:= GetAdvFVal('ZA8','ZA8_DESC',FWxfilial('ZA8') + SZK->ZK_RACA,1)
	cCateg 	 	:= GetAdvFVal('SZ5','Z5_DESC',FWxfilial('SZ5') + SZK->ZK_CATEG,1)
	cClasEsp  	:= SZK->ZK_CLASESP
	cConform  	:= SZK->ZK_CONFORM
	cTipifi   	:= SZK->ZK_TIPIFI
	cRastro   	:= SZK->ZK_RASTRO
	cBlack		:= SZK->ZK_BLACK

	DEFINE MSDIALOG oDlg TITLE 'Consulta de Peças' from 0,0 To 600,511 PIXEL

	oFont      := tFont():New("courier new",,-18,,.t.,,,,)
	oFont2     := tFont():New(,,,,.t.,,,,)
	oFont3     := tFont():New(,,-16,,.t.,,,,)
	oSayLabel1 := tSay():New(010,10,{|| 'Peça nº:'},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayCont   := tSay():New(008,40,{|| ZAJ->ZAJ_NUM },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayLabel2 := tSay():New(010,120,{|| 'Produto:'},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayCod    := tSay():New(008,150,{|| ZAJ->ZAJ_COD },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayDesc   := tSay():New(020,10,{||  ZAJ->ZAJ_DESCRI },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayDataP  := tSay():New(035,10,{||  descP},oDlg,,oFont2,,,,.T.,,,200,30)

	do case
		case empty(ZAJ->ZAJ_DATAS) .and. empty(ZAJ->ZAJ_HORAS)
		oSaySit   := tSay():New(050,10,{|| 'Peça em Estoque' },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)

		case (!empty(ZAJ->ZAJ_DATAS) .and. !empty(ZAJ->ZAJ_HORAS)) .and. (empty(ZAJ->ZAJ_PREPED) .and. empty(ZAJ->ZAJ_PRECAR))
		oSaySit   := tSay():New(050,10,{|| 'Peça Produzida na Desossa!' },oDlg,,oFont,,,,.T.,CLR_HRED,CLR_HRED,220,35)

		case (!empty(ZAJ->ZAJ_PREPED) .and. !empty(ZAJ->ZAJ_PRECAR)) .and. (!empty(ZAJ->ZAJ_DATAS) .and. !empty(ZAJ->ZAJ_HORAS))
		oSaySit   := tSay():New(050,10,{|| 'Peça carregada ou Fora de Estoque!' },oDlg,,oFont,,,,.T.,CLR_HRED,CLR_HRED,220,35)

	endcase

	oSayLabel3  := tSay():New(090,10,{|| 'Aviso de Matanca:'},oDlg,,,,,,.T.,,,200,30)
	oSayNumam   := tSay():New(090,70,{|| ZAJ->ZAJ_NUMAM},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel4  := tSay():New(100,10,{|| 'Lote:'},oDlg,,,,,,.T.,,,200,30)
	oSayLote   	:= tSay():New(100,70,{|| ZAJ->ZAJ_LOTE},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel5  := tSay():New(110,10,{|| 'Sequencial:'},oDlg,,,,,,.T.,,,200,30)
	oSayControl := tSay():New(110,70,{|| ZAJ->ZAJ_CONTRO},oDlg,,oFont2,,,,.T.,,,200,30)

	oSayLabel6 	:= tSay():New(120,10,{|| 'Data de Abate:'},oDlg,,,,,,.T.,,,200,30)
	oSayDtAbt   := tSay():New(120,70,{|| dtAbate},oDlg,,oFont2,,,,.T.,,,200,30)

	oSayLabel7  := tSay():New(130,10,{|| 'Peça de Origem:'},oDlg,,,,,,.T.,,,200,30)
	oSayCorOri  := tSay():New(130,70,{|| iif(ZAJ->ZAJ_CORORI = 'D', 'Dianteiro',iif(ZAJ->ZAJ_CORORI = 'T','Traseiro','Costela'))},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel8  := tSay():New(140,10,{|| 'Cob. de Gordura:'},oDlg,,,,,,.T.,,,200,30)
	oSayCobGor  := tSay():New(140,70,{|| cCobGor},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel9  := tSay():New(150,10,{|| 'Dentição'},oDlg,,,,,,.T.,,,200,30)
	oSayDent    := tSay():New(150,70,{|| cDent},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel10 := tSay():New(160,10,{|| 'Programa'},oDlg,,,,,,.T.,,,200,30)
	oSayProgram := tSay():New(160,70,{|| cProgram},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel10 := tSay():New(170,10,{|| 'Black'},oDlg,,,,,,.T.,,,200,30)
	oSayProgram := tSay():New(170,70,{|| iif(cBlack = 'S',"Sim","Não")},oDlg,,oFont2,,,,.T.,,,200,30)

	oSayLabel11 := tSay():New(100,140,{|| 'Tratamento a Frio?'},oDlg,,,,,,.T.,,,200,30)
	oSayTF      := tSay():New(100,200,{|| iif(cTF == 'T','Sim','Nao')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel12 := tSay():New(110,140,{|| 'Camara:'},oDlg,,,,,,.T.,,,200,30)
	oSayLocal   := tSay():New(110,200,{|| cCam},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel13 := tSay():New(120,140,{|| 'Hora de Produção:'},oDlg,,,,,,.T.,,,200,30)
	oSayHora    := tSay():New(120,200,{|| cHour},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel14 := tSay():New(130,140,{|| 'Classificação:'},oDlg,,,,,,.T.,,,200,30)
	oSayClassif := tSay():New(130,200,{|| cClassif},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel15 := tSay():New(140,140,{|| 'Raca:'},oDlg,,,,,,.T.,,,200,30)
	oSayRaca	   := tSay():New(140,200,{|| cRaca},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel16 := tSay():New(150,140,{|| 'Lado da Carcaça:'},oDlg,,,,,,.T.,,,200,30)
	oSayLado    := tSay():New(150,200,{|| iif(ZAJ->ZAJ_LADO = 'D','Direito','Esquerdo')},oDlg,,oFont2,,,,.T.,,,200,30)
	if ZAJ->ZAJ_CORORI = 'D' .and. ZAJ->ZAJ_CDIAN != ''
		oSayLabel17 := tSay():New(160,140,{|| 'Condição do Dianteiro:'},oDlg,,,,,,.T.,,,200,30)
		oSayCdian   := tSay():New(160,200,{|| iif(ZAJ->ZAJ_CDIAN = 'C','Conforme','Não Conforme')},oDlg,,oFont2,,,,.T.,,,200,30)
	endif

	nUsado := mlr19head()
	mlr19col()

	oEnc  := MSGetDados():New (220,2,266,256,2,,,,.F.,,,.F.,len(aCols),,,,,oDlg)

	@ 275,190  BUTTON 'Fechar'   SIZE 45,15 ACTION oDlg:end()  OBJECT oBtn2
	ACTIVATE MSDIALOG oDlg CENTERED
return


static function mlr19Head                                                      //Monta o Header das operações registradas no historico
	Aheader := {}
	aAdd(Aheader,{'Movimento' ,'ZAK_TIPO' ,'@!'        , 1    , 0 , ,, 'C' ,'ZAK',})
	aAdd(Aheader,{'Data     ' ,'ZAK_DATA' ,'99/99/9999', 08   , 0 , ,, 'D' ,'ZAK',})
	aAdd(Aheader,{'Hora     ' ,'ZAK_HORA' ,'99:99'     , 05   , 0 , ,, 'C' ,'ZAK',})
	aAdd(Aheader,{'Descrição' ,'ZAK_DESC' ,'@!'        , 20   , 0 , ,, 'C' ,'ZAK',})
	aAdd(Aheader,{'Usuario  ' ,'ZAK_USAR' ,'@!'        , 10   , 0 , ,, 'C' ,'ZAK',})
	aAdd(Aheader,{'Estação  ' ,'ZAK_EST'  ,'@!'        , 05   , 0 , ,, 'C' ,'ZAK',})
return len(aHeader)


static Function mlr19Col()                                                     //Monta o aCols dos históricos da peça (ZAK)

	Local nI := 0

	dbselectarea('ZAK')
	ZAK->(dbSetOrder(1))
	if ZAK->(MsSeek(FWxFilial('ZAK')+ZAJ->ZAJ_NUM,.t.))
		Do While ZAK->(!Eof()) .and. ZAK->ZAK_FILIAL = FWxfilial('ZAK') .and. alltrim(ZAK->ZAK_CONTRO) == alltrim(ZAJ->ZAJ_NUM)
			aAdd(aCols,Array(nUsado+1))
			For nI := 1 to nUsado
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Next nI
			aCols[Len(aCols),nUsado+1] := .F.
			ZAK->(DbSkip())
		Enddo
	endif

return

//Reimpressão da etiqueta
User Function mlr19Imp()

	_Font01 	:= "60,60"
	_Font02 	:= "70,70"
	_nCont		:=	1
	_nImp 		:= 6
	cMod 		:= mv_par01
	cPor 		:= mv_par02
	cNumam      := ZAJ->ZAJ_NUMAM
	cLote       := ZAJ->ZAJ_LOTE
	cControl    := ZAJ->ZAJ_CONTRO

	SZK->(DbSetOrder(4))
	SZK->(MsSeek(FWxfilial('SZK') + cNUMAM + cControl))
	dtAbate     := GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG') + cNUMAM,1)
	cTF 		:= SZK->ZK_DESTINO
	cCam        := SZK->ZK_LOCAL
	cHour 	    := SZK->ZK_HORA
	cCobGor     := SZK->ZK_COBGOR
	cDent       := SZK->ZK_DENT
	cProgram  	:= GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6') + SZK->ZK_PROGRAM,1)
	cClassif  	:= SZK->ZK_CLASSIF
	cClasAba  	:= SZK->ZK_CLASABA
	cRaca     	:= GetAdvFVal('ZA8','ZA8_DESC',FWxfilial('ZA8') + SZK->ZK_RACA,1)
	cCateg 	 	:= GetAdvFVal('SZ5','Z5_DESC',FWxfilial('SZ5') + SZK->ZK_CATEG,1)
	cClasEsp  	:= SZK->ZK_CLASESP
	cConform  	:= SZK->ZK_CONFORM
	cTipifi   	:= SZK->ZK_TIPIFI
	cRastro   	:= SZK->ZK_RASTRO

	/************************Impressão das Etiquetas***************************/
	//Impressão via LPT1
	MSCBPRINTER(cMod,cPor)
	//Impressão por rede
	//MSCBPRINTER(cMod,cPor,,,,,'10.0.0.3')
	MSCBCHKSTATUS(.t.)
	MSCBBEGIN(1,6)

	MSCBBOX(01,16,60,33)

	//Lado
	MSCBSAY(50, 17,ZAJ->ZAJ_LADO,"N","0","100,100")

	//Codigo de Barras
	MSCBSAYBAR(08,17,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,2,2,.t.)

	MSCBBOX(01,35,14,48)
	MSCBSAY(3, 36,'Gord',"N","E","8,8")
	MSCBSAY(6, 40,SZK->ZK_COBGOR,"N","0",_Font01)

	MSCBBOX(17, 35,31,48)
	MSCBSAY(20, 36,'Dent',"N","E","8,8")

	// Alteração efetuada para norma de exportação para o Egito
	if cClasEsp = '1' .AND. SZK->ZK_DENT = '8'
		MSCBSAY(23, 40,'7',"N","0",_Font01)
	elseif cClasEsp = '1' .AND. SZK->ZK_DENT != '8'
		MSCBSAY(23, 40,iif(cDent = '1','DL',SZK->ZK_DENT),"N","0",_Font01)
	elseif cClasEsp = '2'
		MSCBSAY(23, 40,'8',"N","0",_Font01)
	endif

	MSCBBOX(34, 35,46,48)
	MSCBSAY(35, 36,'Conf',"N","E","8,8")
	MSCBSAY(40, 40,cConform,"N","0",_Font01)

	MSCBBOX(48, 35,60,48)
	MSCBSAY(50, 36,'Tip',"N","E","8,8")
	MSCBSAY(50, 40,cTipifi,"N","0",_Font01)

	MSCBBOX(02,50,60,70)
	MSCBLINEV(39,50,70)
	MSCBLINEH(39,60,60)

	MSCBSAY(03, 52,'SEQ.',"N","E","8,8")
	MSCBSAY(13, 52,ZAJ->ZAJ_CONTRO,"N","0",_Font02)

	MSCBSAY(03, 62,iif(ZAJ->ZAJ_COD = '000030','TRASEIRO',iif(ZAJ->ZAJ_COD = '000031','DIANTEIRO','COSTELA')),"N","0",_Font01)

	MSCBSAY(40, 52,'Abate',"N","E","8,8")
	MSCBSAY(40, 55,ZAJ->ZAJ_NUMAM,"N","E","8,8")

	MSCBSAY(40, 62,'Lote',"N","E","8,8")
	MSCBSAY(40, 66,ZAJ->ZAJ_LOTE,"N","E","8,8")

	MSCBBOX(02,72,60,77)
	MSCBSAY(02,73, GetMv("MV_NUMIF") + strtran(dtoc(dtAbate),'/','') +'0000',"N","E","8,8")

	MSCBBOX(02,79,30,89)
	MSCBSAY(03,80,'SIF',"N","E","8,8")
	MSCBSAY(07,84,GetMv("MV_NUMIF"), "N","E","28,15")

	MSCBBOX(32,79,60,89)
	MSCBSAY(33,80,'Data Abate',"N","E","8,8")
	MSCBSAY(37,84,dtoc(dtAbate),"N","E","28,15")

	nL := 125

	MSCBBOX(02,93,60,98)
	If SZK->ZK_OBS == '0'  //ok
		MSCBSAY(03,94, 'SISBOV:'+ cRastro ,"N","E","8,8")
	Endif

	if SZK->ZK_PROGRAM = '006'
		MSCBBOX(02,100,60,109)
		MSCBSAY(03,101,_cCateg,"N","0",_Font01)// *** Verificar campo novo
		MSCBBOX(02,110,60,120)

		MSCBSAY(10,111,'ANGUS',"N","0","90,105")

		MSCBBOX(02,124,60,144)// quadrado
		MSCBSAY(10,125,cClasAba,"N","0","180,300")
	else
		MSCBBOX(02,100,60,109)
		MSCBSAY(03,101,cCateg,"N","0",_Font01)
		MSCBBOX(02,110,60,130)
		MSCBSAY(12,111,cClasAba,"N","0","162,270")
		If !Empty(cProgram) .and.   cProgram != '001'
			MSCBSAY(03,138,substr(cProgram,1,10), "N","0","100,80")// aqui esta sendo modificado
		endif
	endif

	//Aqui imprime a Classificação Especial
	if cClasEsp = '1' .and. AllTrim(cClasAba) != 'NE'
		MSCBBOX(16,155,45,130)
		MSCBSAY(17,157,'CE',"N","0","200,200")
	endif

	//****************************  FIM  *****************************************
	MSCBSAY(13,285,"DTI","N","0","100,190")

	MSCBEND()
	MSCBCLOSEPRINTER()

return

User Function mlr19Ent()
	Local _lMot := .f.

	if empty(ZAJ->ZAJ_DATAS) .and. empty(ZAJ->ZAJ_HORAS)
		msgbox('Esta peça já encontra-se em estoque!','OPERACAO IRREGULAR','STOP')
		return
	endif

	_lMot := DescMot('E')

	IF mv_par03 = 1
		//Desossa
		_cDest := 'D'
	Elseif mv_par03 = 2
		//Costela
		_cDest := 'C'
	Elseif mv_par03 = 3
		//Carregamento
		_cDest := 'A'
	else
		//Outros
		_cDest := 'O'
	Endif

	if _lMot
		reclock('ZAJ',.f.)
		ZAJ->ZAJ_DATAS   := stod('')
		ZAJ->ZAJ_HORAS   := ''
		ZAJ->ZAJ_PREPED  := ''
		ZAJ->ZAJ_ITEM    := ''
		ZAJ->ZAJ_PRECAR  := ''
		ZAJ->ZAJ_DEST 	 := _cDest
		msunlock()

		u_gjf182hs(1,_cMotivo)

		u_mlr19Wflow(ZAJ->ZAJ_NUM)

	endif

return


User Function mlr19Sai()
	Local _lMot := .f.

	if (!empty(ZAJ->ZAJ_DATAS) .and. !empty(ZAJ->ZAJ_HORAS)) .and. (empty(ZAJ->ZAJ_PREPED) .and. empty(ZAJ->ZAJ_PRECAR))
		msgbox('Esta peça já foi produzida nada Desossa!','OPERACAO IRREGULAR','STOP')
		return
	elseif (!empty(SZ8->Z8_DATAS) .and. !empty(SZ8->Z8_HORAS)) .and. (!empty(ZAJ->ZAJ_PREPED) .and. !empty(ZAJ->ZAJ_PRECAR))
		msgbox('Esta peça já foi carregada!','OPERACAO IRREGULAR','STOP')
		return
	endif

	_lMot := DescMot('S')

	IF mv_par03 = 1
		//Desossa
		_cDest := 'D'
	Elseif mv_par03 = 2
		//Costela
		_cDest := 'C'
	Elseif mv_par03 = 3
		//Carregamento
		_cDest := 'A'
	else
		//Outros
		_cDest := 'O'
	Endif

	if _lMot

		reclock('ZAJ',.f.)
		ZAJ->ZAJ_DATAS  := date()
		ZAJ->ZAJ_HORAS  := time()
		ZAJ->ZAJ_PREPED := 'ACERTO'
		ZAJ->ZAJ_ITEM   := 'EST'
		ZAJ->ZAJ_PRECAR := 'ACERTO'
		ZAJ->ZAJ_DEST := _cDest

		msunlock()

		u_gjf182hs(2,_cMotivo)

	endif

return


static function DescMot(cMot)

	Local _lOk := .f.

	_cMotivo := space(20)
	_lRep    := .f.

	DEFINE MSDIALOG oDlg TITLE 'Motivo da Movimentação:' from 000,000 To 100,260 OF oMainWnd PIXEL
	@ 010,003 SAY  'Historico:' Object oSay1
	@ 010,025 GET _cMotivo PICTURE "@!"   SIZE 60,11  Object oCaixa

	@ 010,100 BMPBUTTON TYPE 1 ACTION (_lOk := .t.,oDlg:end()) Object Obtn1
	@ 025,100 BMPBUTTON TYPE 2 ACTION oDlg:end() Object Obtn2

	ACTIVATE MSDIALOG oDlg

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
User Function mlr19Wflow(_peca)
	local _area
	local _cDest := ''
	local _user  := cUserName
	local _est   := GetComputerName()
	local _data  := dDatabase
	local _hora  := time()
	Local i

	if substr(_est,1,3) <> 'PCP'
		if !empty(_cDest)
			_cDest += ','
		endif
		_cDest += 'pcp@frigorificosilva.com.br'//;logistica2@frigorificosilva.com.br'
	endif

	if !empty(_cDest)

		_area := getarea()

		_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
		_cMens += 'Na data e hora da emissão deste email,ocorreu uma operação de entrada de estoque' + chr(13) + chr(10)
		_cMens += 'foi realizada.' + chr(13) + chr(10)
		_cMens +=   chr(13) + chr(10)
		_cMens += 'Peca nr.: ' 	+ alltrim(_peca) + chr(13) + chr(10)
		_cMens += 'Operador: '  + alltrim(_User) + chr(13) + chr(10)
		_cMens += 'Estação: '   + alltrim(_est) + chr(13) + chr(10)
		_cMens += 'Data: '      + alltrim(dtoc(_data)) + chr(13) + chr(10)
		_cMens += 'Hora: '      + alltrim(_hora) + chr(13) + chr(10)
		_cTit  := 'Workflow Frigorífico Silva: Controle de entrada e saída de peças do estoque'

		_aEmail := u_GJF54(_cMens,_cTit,_cDest)

		for i := 1 to len(_aEmail)
			if !_aEmail[i]
				alert('ERRO WORKFLOW ('+ str(i) +')')
			endif
		next

		restarea(_area)

	endif

return


User Function mlr192()
	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Parâmetros para Baixa de Peças ")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _dData  	:= date() // Data da Baixa

	_lMot := .f.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query para seleção das informações                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasTMP := GetNextAlias()
	_aDados   := {}

	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(210), C(370) PIXEL
	@ C(005), C(010) SAY "Esta rotina tem como objetivo efetuar a baixa de Peças"	Size C(300), C(12) FONT _oFtArial30 COLOR CLR_CYAN 	PIXEL OF _oTela
	@ C(015), C(010) SAY "que estejam no estoque conforme  dia selecionado"			Size C(300), C(12) FONT _oFtArial30 COLOR CLR_CYAN 	PIXEL OF _oTela
	
	@ C(050), C(010) SAY "Data da Baixa"                                  	  		Size C(100), C(10) FONT _oFtArial24 COLOR CLR_HBLUE PIXEL OF _oTela
	@ C(050), C(070) MSGET _dData                               	           		Size C(060), C(10) FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(090), C(100) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _Process())
	DEFINE SBUTTON FROM C(090), C(140) TYPE 2 OBJECT _oCancel ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED   
Return

// Efetua Processamento dos Dados Informados
Static Function _Process()

	If !Empty(_dData) 
		//cQuery += "   AND (ZAJ_COD = '005020' OR ZAJ_COD = '005016' OR ZAJ_COD = '005018' OR ZAJ_COD = '001502' OR ZAJ_COD = '001340' OR ZAJ_COD = '001989' OR ZAJ_COD = '001450')"
		cQuery := "SELECT * "
		cQuery += "  FROM " + RetSQLTab("ZAJ")
		cQuery += " WHERE " + RetSQLFil("ZAJ")
		cQuery += "   AND ZAJ_DATA = '"+ DTOS(_dData)+"'  "
		cQuery += "   AND ZAJ_DATAS = '"+DTOS(STOD(''))+"'"
		cQuery += "   AND " + RetSQLDel("ZAJ")
		
		cQuery := ChangeQuery(cQuery)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo
	
		DbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasTMP, .F., .T. )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processamento dos Dados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//_nTotal := 0
		_lMot := DescM('S')

		if _lMot
			While !(cAliasTMP)->(Eof())

					IF mv_par03 = 1
						//Desossa
						_cDest := 'D'
					Elseif mv_par03 = 2
						//Costela
						_cDest := 'C'
					Elseif mv_par03 = 3
						//Carregamento
						_cDest := 'A'
					else
						//Outros
						_cDest := 'O'
					Endif
					ZAJ->(DbSetOrder(2))
					ZAJ->(DbGoTop())
					if ZAJ->(MsSeek(FWxfilial('ZAJ')+(cAliasTMP)->ZAJ_NUM))

							reclock('ZAJ',.f.)
							ZAJ->ZAJ_DATAS  := date()
							ZAJ->ZAJ_HORAS  := time()
							ZAJ->ZAJ_PREPED := 'ACERTO'
							ZAJ->ZAJ_ITEM   := 'EST'
							ZAJ->ZAJ_PRECAR := 'ACERTO'
							ZAJ->ZAJ_DEST := _cDest
							ZAJ->ZAJ_USUALT := cUserName
							msunlock()

						u_gjf182hs(2,_cMotivo)
					Endif
				(cAliasTMP)->(DbSkip())
			EndDo
		Endif

		MsgAlert("Baixas do Dia - " + DTOC(_dData) + " efetuado com Sucesso.")
	Else
		MsgAlert("Campo de Data Não Preenchidos. Baixa Não Será Efetuada.")
	Endif

	_oTela:End()

	U_mlr192()

Return


static function DescM(cMot)

	Local _lOk := .f.

	_cMotivo := space(20)
	_lRep    := .f.

	DEFINE MSDIALOG oDlg TITLE 'Motivo da Movimentação:' from 000,000 To 100,260 OF oMainWnd PIXEL
	@ 010,003 SAY  'Historico:' Object oSay1
	@ 010,025 GET _cMotivo PICTURE "@!"   SIZE 60,11  Object oCaixa

	@ 010,100 BMPBUTTON TYPE 1 ACTION (_lOk := .t.,oDlg:end()) Object Obtn1
	@ 025,100 BMPBUTTON TYPE 2 ACTION oDlg:end() Object Obtn2

	ACTIVATE MSDIALOG oDlg

return _lOk
