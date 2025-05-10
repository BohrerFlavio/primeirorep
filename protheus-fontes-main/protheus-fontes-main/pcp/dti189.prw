#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI189 º Autor  ³ Adonai Gonçalves      º Data ³  21/10/23 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±            
±±ºDesc.     ³ Controle de Caixas e Manutenção de Estoque (SZW)           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI189()

	lOk         := .f.
	oDesc       := '' 
	vNumPrev    := ''
	aIndSZW   	:= {}					                       // Arquivo e número de índice utilizado
	cCondicao 	:= ""					                       // Condição para a filtragem

	Private cPerg   := "GJF34"

	Private _lRep    := .f.       //Variavel que vai agir e definir se a saída é processo ou reprocesso 
	Private _cMotivo := space(20)

	Private cCadastro := "Controle de Caixas e Manutenção de Estoque (SZW)"
	Private aRotina := {{"Pesquisar" ,"AxPesqui"    ,0,1} ,;
	{"Consultar" ,"u_dti189con " ,0,4},;
	{"Entrada"   ,"u_dti189ent"  ,0,4},;
	{"Baixa"     ,"u_dti189sai " ,0,4},;
	{"Reimprimir","u_dti189imp"  ,0,2},;
	{"Legenda"  , "u_dti189Leg" ,0,1}}

	private cString := "SZW"

	if !pergunte(cPerg,.t.)
		return
	endif

	Private bLegenda1 := "SZW->ZW_TIPOPRO = 'PA'"    // PA
	Private bLegenda2 := "empty(SZW->ZW_PERCRXN)"    // Não passou Raio-X
	Private bLegenda3 := "SZW->ZW_TIPOPRO = 'MP'"    // MP

	Private aCores := {{bLegenda1, 'BR_VERDE'},;     // PA
	{bLegenda2, 'BR_VERMELHO'},;      				 // Não passou Raio-X
	{bLegenda3, 'BR_AZUL'}}      					 // MP

	Private aCores2:= {{'BR_VERDE' ,'PA'},;  		 // PA
	{'BR_VERMELHO' ,'Rejeite Raio-X'},;      		 // Não passou Raio-X
	{'BR_AZUL' ,'MP'}}      					 	 // MP

	SetKey(VK_F11,{|| posicao5()})  			// F11 para scanear novas pré-etiquetas
	SetKey(123,{|| posicao()})      			// F12 para consulta caixa e Histórico

	dbSelectArea(cString)
	SZW->(dbSetOrder(1))

	mBrowse(6, 1, 22, 75,cString,,,,,,aCores,,,,{|x| AutoRefresh(x)})

	DbCloseArea()

Return

User Function dti189Leg(cAlias,nReg,nOpc)
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

return


static function posicao2()
	SZW->(dbsetorder(2))
	if SZW->(Msseek(FWxfilial('SZW')+cCaixa,.t.))
		u_dti189con()
	else
		FWAlertError("Caixa não encontrada!", "ERRO!")
	endif

return


static function preenche()                            //Função que preeche o codigo do produto com zeros
	if !empty(alltrim(cCaixa))
		cCaixa := padl(alltrim(cCaixa),10,"0")
	endif
return .t.


user function dti189con()
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0

	descP := GetAdvFVal('SB1','B1_DESC',SZW->(ZW_FILIAL+ZW_COD),1)

	campo1 := space(20)
	valor1 := space(20)
	campo2 := CTBCBOX('ZV_TIPO')                                                   //Aponta o tipo de operação a ser feita
	valor2 := space(10)

	_cRua    := substr(SZW->ZW_LOCALIZ,3,2)
	_cPredio := substr(SZW->ZW_LOCALIZ,5,2)
	_cAndar  := substr(SZW->ZW_LOCALIZ,7,2)
	_cApto   := substr(SZW->ZW_LOCALIZ,9,2)

	if !empty(SZW->ZW_PREDES)                                                         //se houver o apontamento de OP
		vNUMAM   := GetAdvFVal('SZ2','Z2_NUMAM',FWxfilial('SZ2')+SZW->ZW_PREDES,2)    //numero aviso de matança

		dtAbate  := GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+vNUMAM,1)             //data do aviso de matança
		vTIP     := GetAdvFVal('SZ2','Z2_TIPIFI',FWxfilial('SC2')+SZW->ZW_PREDES,2)   //numero aviso de matança
	endif

	DEFINE MSDIALOG oDlg TITLE 'Consulta de Pesagens' from 0,0 To 600,511 PIXEL

	oFont      := tFont():New("courier new",,-18,,.t.,,,,)
	oFont2     := tFont():New(,,,,.t.,,,,)
	oFont3     := tFont():New(,,-16,,.t.,,,,)
	oSayLabel1 := tSay():New(010,10,{|| 'Caixa nº:'},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayCont   := tSay():New(008,40,{|| SZW->ZW_CONTROL },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayLabel2 := tSay():New(010,120,{|| 'Produto:'},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayCod    := tSay():New(008,150,{|| SZW->ZW_COD },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayDesc   := tSay():New(020,10,{|| SZW->ZW_DESCRI },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayDataP  := tSay():New(035,10,{|| descP},oDlg,,oFont2,,,,.T.,,,200,30)

	do case
		case empty(SZW->ZW_DATAS) .and. empty(SZW->ZW_DATAE)
		oSaySit   := tSay():New(050,10,{|| 'Caixa disponível!' },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
		case !empty(SZW->ZW_DATAS) .and. empty(SZW->ZW_DATAE)
		oSaySit   := tSay():New(050,10,{|| 'Caixa já carregada ou fora de estoque!' },oDlg,,oFont,,,,.T.,CLR_HRED,CLR_HRED,220,35)
	endcase

	oSayLabel3  := tSay():New(090,10,{|| 'Data Real de Produção:'},oDlg,,,,,,.T.,,,200,30)
	oSayData    := tSay():New(090,70,{|| SZW->ZW_DATA},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel4  := tSay():New(100,10,{|| 'Data de Produção:'},oDlg,,,,,,.T.,,,200,30)
	oSayDataP   := tSay():New(100,70,{|| SZW->ZW_DATAP},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel5  := tSay():New(110,10,{|| 'Data de Validade:'},oDlg,,,,,,.T.,,,200,30)
	oSayDataV   := tSay():New(110,70,{|| SZW->ZW_DATAVAL},oDlg,,oFont2,,,,.T.,,,200,30)

	if !empty(SZW->ZW_PREDES) .and. empty(SZW->ZW_LOTE)
		oSayLabel23 := tSay():New(120,10,{|| 'Data de Abate:'},oDlg,,,,,,.T.,,,200,30)
		oSaydtAbt   := tSay():New(120,70,{|| dtAbate},oDlg,,oFont2,,,,.T.,,,200,30)
	endif

	oSayLabel6 := tSay():New(130,10,{|| 'Quantidade de Peças:'},oDlg,,,,,,.T.,,,200,30)
	oSayQuant  := tSay():New(130,70,{|| transform(SZW->ZW_QUANT,'@E 99')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel7 := tSay():New(140,10,{|| 'Peso Bruto:'},oDlg,,,,,,.T.,,,200,30)
	oSayPesoB  := tSay():New(140,70,{|| transform(SZW->ZW_PESOBR,'@E 99.999')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel8 := tSay():New(150,10,{|| 'Tara:'},oDlg,,,,,,.T.,,,200,30)
	oSayTara   := tSay():New(150,70,{|| transform(SZW->ZW_TARA,'@E 9.999')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel9 := tSay():New(170,10,{|| 'Peso Líquido:'},oDlg,,oFont3,,,,.T.,,,200,30)
	oSayPesoL  := tSay():New(170,70,{|| transform(SZW->ZW_PESO,'@E 99.999')},oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)

	if !empty(SZW->ZW_PREDES)
		oSayLabel22 := tSay():New(185,10,{|| 'Tipificação:'},oDlg,,,,,,.T.,,,200,30)
		oSayTIP     := tSay():New(185,70,{|| vTIP},oDlg,,oFont2,,,,.T.,,,200,30)
	endif
	oSayLabel11 := tSay():New(160,10,{|| 'Tipo de Produção:'},oDlg,,,,,,.T.,,,200,30)//90//140
	oSayTipo    := tSay():New(160,70,{|| iif(SZW->ZW_TIPO == 'P','Processo','Reprocesso')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel14 := tSay():New(090,140,{|| 'Tratamento a Frio?'},oDlg,,,,,,.T.,,,200,30)
	oSayTF      := tSay():New(090,200,{|| iif(SZW->ZW_TF == 'S','Sim','Nao')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel15 := tSay():New(100,140,{|| 'Tipo de Etiqueta:'},oDlg,,,,,,.T.,,,200,30)
	oSayEtiq    := tSay():New(100,200,{|| SZW->ZW_ETIQ},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel16 := tSay():New(110,140,{|| 'Mensagem Despojo?'},oDlg,,,,,,.T.,,,200,30)
	oSayDesp    := tSay():New(110,200,{|| iif(SZW->ZW_MDESP == 'S','Sim','Nao')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel20 := tSay():New(120,140,{|| 'Camara:'},oDlg,,,,,,.T.,,,200,30)
	oSayLocal   := tSay():New(120,200,{|| SZW->ZW_LOCAL},oDlg,,oFont2,,,,.T.,,,200,30)
	if !empty(SZW->ZW_LOCALIZ)
		//oSayLabel20 := tSay():New(130,140,{|| 'Localização:'},oDlg,,,,,,.T.,,,200,30)
		oSayLocaliz   := tSay():New(130,140,{|| 'Rua: '    + _cRua    + '  ' +;
		'Predio: ' + _cPredio + '  ' +;
		'Andar: '  + _cAndar  + '  ' +;
		'Apto: '   + _cApto},oDlg,,oFont2,,,,.T.,,,200,30)
	endif

	oSayLabel17 := tSay():New(140,140,{|| 'Operador:'},oDlg,,,,,,.T.,,,200,30)
	oSayOper    := tSay():New(140,200,{|| SZW->ZW_OPERA},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel18 := tSay():New(150,140,{|| 'Estação'},oDlg,,,,,,.T.,,,200,30)
	oSayBal     := tSay():New(150,200,{|| SZW->ZW_BALAN},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel19 := tSay():New(160,140,{|| 'Hora:'},oDlg,,,,,,.T.,,,200,30)
	oSayHora    := tSay():New(160,200,{|| SZW->ZW_HORA},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel24 := tSay():New(170,140,{|| 'Tipo:'},oDlg,,,,,,.T.,,,200,30)
	oSayTipopro := tSay():New(170,200,{|| SZW->ZW_TIPOPRO},oDlg,,oFont2,,,,.T.,,,200,30)

	nUsado := dti189head()
	dti189col()

	oEnc  := MSGetDados():New (220,2,266,256,2,,,,.F.,,,.F.,len(aCols),,,,,oDlg)

	@ 275,190  BUTTON 'Fechar'   SIZE 45,15 ACTION ODlg:end()  OBJECT oBtn2
	ACTIVATE MSDIALOG oDlg CENTERED
return


static function dti189head()                                                    //Monta o Header das operações registradas no historico
	Aheader := {}
	aAdd(Aheader,{'Movimento' ,'ZV_TIPO' ,'@!'        , 1    , 0 , ,, 'C' ,'SZV',})
	aAdd(Aheader,{'Data     ' ,'ZV_DATA' ,'99/99/9999', 08   , 0 , ,, 'D' ,'SZV',})
	aAdd(Aheader,{'Hora     ' ,'ZV_HORA' ,'99:99'     , 05   , 0 , ,, 'C' ,'SZV',})
	aAdd(Aheader,{'Descrição' ,'ZV_DESC' ,'@!'        , 20   , 0 , ,, 'C' ,'SZV',})
	aAdd(Aheader,{'Usuario  ' ,'ZV_USAR' ,'@!'        , 10   , 0 , ,, 'C' ,'SZV',})
	aAdd(Aheader,{'Estação  ' ,'ZV_EST'  ,'@!'        , 05   , 0 , ,, 'C' ,'SZV',})
return len(aHeader)


static Function dti189col()                                                     //Monta o aCols dos históricos da caixa (SZV)
	Local nI
	dbselectarea('SZV')
	SZV->(dbSetOrder(1))
	if SZV->(MsSeek(FWxFilial('SZV')+SZW->ZW_CONTROL,.t.))
		Do While SZV->(!Eof()) .and. SZV->ZV_FILIAL = FWxfilial('SZV') .and. alltrim(SZV->ZV_CONTROL) == alltrim(SZW->ZW_CONTROL)
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
User Function dti189imp()

	_cIp  := ''
	_cEst := getComputerName()
	dbselectarea('ZAM')
	ZAM->(DbSetOrder(2))
	if ZAM->(MsSeek(FWxFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	endif

	//EMBALAGEM FRIGORÍFICO
	u_GJF111f("S600","IP",SZW->ZW_CONTROL,SZW->ZW_COD,SZW->ZW_QUANT,SZW->ZW_PESOBR,SZW->ZW_PESO,SZW->ZW_TARA,SZW->ZW_PREDES,SZW->ZW_CLASSIF,SZW->ZW_TF,SZW->ZW_DATAP,SZW->ZW_ETIQ,SZW->ZW_DATAVAL,1,SZW->ZW_LOTE,_cIp,SZW->ZW_SEQPETQ,SZW->ZW_HORA)

return


User Function dti189ent()

	_cCam := ""

	if SZW->ZW_FILIAL = cFilAnt

		if !(FWAlertYesNo("Tem certeza que deseja colocar em estoque esta caixa?", "CONFIRMA"))
			FWAlertInfo("Operação cancelada!", "ATENÇÃO!")
		else
			if SZW->ZW_TIPOPRO = 'PA'

				_cCam := DescCam()

				reclock('SZ8',.t.)
				SZ8->Z8_FILORI    := SZW->ZW_FILIAL
				SZ8->Z8_FIL       := SZW->ZW_FILIAL
				SZ8->Z8_FILIAL    := FWxfilial('SZ8')
				SZ8->Z8_ID        := SZW->ZW_ID
				SZ8->Z8_CONTROL   := SZW->ZW_CONTROL
				SZ8->Z8_CODORI    := SZW->ZW_COD
				SZ8->Z8_COD       := SZW->ZW_COD
				SZ8->Z8_DATA      := SZW->ZW_DATA
				SZ8->Z8_DATAP     := SZW->ZW_DATAP
				SZ8->Z8_HORA      := SZW->ZW_HORA
				SZ8->Z8_TIPO      := SZW->ZW_TIPO
				SZ8->Z8_TF        := SZW->ZW_TF
				SZ8->Z8_QUANT     := SZW->ZW_QUANT
				SZ8->Z8_PESO      := SZW->ZW_PESO
				SZ8->Z8_TARA      := SZW->ZW_TARA
				SZ8->Z8_TARAS     := SZW->ZW_TARAS
				SZ8->Z8_CLASSIF   := SZW->ZW_CLASSIF
				SZ8->Z8_PESOBR    := SZW->ZW_PESOBR
				SZ8->Z8_ETIQ      := SZW->ZW_ETIQ
				SZ8->Z8_DATAVAL   := SZW->ZW_DATAVAL
				SZ8->Z8_DESCRI    := SZW->ZW_DESCRI
				SZ8->Z8_DTENTES   := date()
				SZ8->Z8_LOTE   	  := SZW->ZW_LOTE
				SZ8->Z8_NUMPREV   := SZW->ZW_NUMPREV
				SZ8->Z8_PREDES    := SZW->ZW_PREDES
				SZ8->Z8_PESFIX    := SZW->ZW_PESFIX
				SZ8->Z8_ORIGEM    := SZW->ZW_ORIGEM
				SZ8->Z8_BALAN     := SZW->ZW_BALAN
				SZ8->Z8_SETPRO    := SZW->ZW_SETPRO
				SZ8->Z8_FARM      := SZW->ZW_FARM
				SZ8->Z8_PALLET    := ''
				SZ8->Z8_PERCRXN   := SZW->ZW_PERCRXN
				SZ8->Z8_STRRX 	  := SZW->ZW_STRRX
				SZ8->Z8_INV	      := 'X'
				SZ8->Z8_SEQPETQ   := SZW->ZW_SEQPETQ
				msunlock()

				u_gjf17his(1,'MOV.P/ CAMARA (MANUAL) - ' + alltrim(_cCam),_lRep,'','','000024',SZW->ZW_CONTROL,SZW->ZW_LOCAL)

				reclock('SZW',.f.)
				SZW->ZW_HORAS   := time()
				SZW->ZW_DATAS   := date()
				SZW->ZW_OPERA   := cUserName
				msunlock()

				FWAlertSuccess("Entrada em estoque realizada com sucesso!", "SUCESSO!")
			else
				FWAlertError("Caixa não é de produto acabado!", "ERRO!")
			endif
		endif
	else
		FWAlertError("Caixa encontra-se em outra filial!", "ERRO!")
	endif

return            


User Function dti189sai()

	if !(FWAlertYesNo("Tem certeza que deseja excluir esta caixa? (Peso = " + Transform(SZW->ZW_PESO,'@E 999.99') + " kg)", "CONFIRMA"))
		FWAlertInfo("Operação cancelada!", "ATENÇÃO!")
	else
		if SZW->ZW_TIPOPRO = "MP"
			ZAS->(dbsetorder(1))
			ZAS->(DbGoTop())
			if ZAS->(Msseek(FWxfilial('ZAS') + alltrim(SZW->ZW_CONTROL)))
				reclock('ZAS',.f.)
				ZAS->ZAS_DATAS  := date()
				ZAS->ZAS_HORAS  := time()
				ZAS->ZAS_MOREEN := 'BAIXA'
				msunlock()

				reclock('ZAS',.f.)
				DbDelete()
				msunlock()
			else
				FWAlertWarning("Caixa não encontrada na ZAS!", "ATENÇÃO!")
			endif
		endif
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

		FWAlertSuccess("Baixa manual realizada com sucesso!", "SUCESSO!")
	endif

return            


static function DescCam(Mot)                                                        //Cria a caixa de diálogo para localizar uma caixa

	_cCam := space(20)

	DEFINE MSDIALOG oDlg2 TITLE 'Câmara da Movimentação:' from 000,000 To 100,260 OF oMainWnd PIXEL
	@ 010,003 SAY 'Câmara:' Object oSay1
	@ 010,025 GET _cCam PICTURE "@!" F3 'NNR' SIZE 60,11 Object oCaixa

	@ 010,100 BMPBUTTON TYPE 1 ACTION (_lOk := .t.,odlg2:end()) Object Obtn1
	@ 025,100 BMPBUTTON TYPE 2 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2

return _cCam

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
// 02000026920775   - 14 caracteres
_c1 := substr(cPreE,1,2)
_c2 := substr(cPreE,3,3)
_c3 := substr(cPreE,6,9)

_CSeqpE := alltrim(_c1)+'000'+alltrim(_c3)

	SZW->(dbsetorder(9))
	if SZW->(Msseek(FWxfilial('SZW')+alltrim(_CSeqpE),.t.))
		u_dti189con()
	else
		FWAlertError('Caixa não encontrada!','ERRO!')
	endif   

return
