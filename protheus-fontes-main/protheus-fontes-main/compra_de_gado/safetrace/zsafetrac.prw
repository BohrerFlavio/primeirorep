#include 'protheus.ch'
#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#include "colors.ch"


User Function zSafetr()  //u_zSafetr()
	local lcont         := .f.
	Private _cNota		:= ""
	Private _aArray 	:= {}
	private oSize      	:= nil
	private aPosDialog 	:= nil
	private aPosPanel  	:= nil
	Private aSize 		:= MsAdvSize(.F.)
	Private nJanLarg 	:= aSize[5]
	Private nJanAltu 	:= aSize[6]
	private oTable
	private aCampS 		:= {}
	private aCampT 		:= {}
	private cMrca  		:= GetMark()
	PRIVATE aCorCab1 	:= {}
	PRIVATE aCorCab2	:= {}
	PRIVATE aCorDet1	:= {}
	PRIVATE aCorDet2	:= {}
	private lprim 		:= .t.
	private _CFIL 		:= ''
	private oCabec
	private _cLScab    := 'Notas fiscais de saida'
	private _cLSite    := 'Itens Notas fiscais de saida'
	private oFolder
	private oBtn5
	private _cLEcab    := 'Notas fiscais de entrada (Produtor)'
	private _cLEite    := 'Itens Notas fiscais de entrada'
	private oTree

	private _cREai    := 'Vinculos'
	DEFINE FONT oFnt   NAME "Arial" SIZE 12,14 BOLD

	//delTab()

	cPerg      :=  padr("ZSAFTRC",len(SX1->X1_GRUPO)," ")
	private cCodSafe := ''

	//FWAlertSuccess("zsafetrac -> data compilacao: 28/02/2024 13:42", "Dados da rotina")

	ValidPerg()

	if Pergunte(cPerg,.T.)
		lcont := .t.
	endif


	if lcont
		aAdd(aCorCab1,{"Alltrim(TRB1->F2_RELACA) == ''","BR_VERDE"})
		aAdd(aCorCab1,{"Alltrim(TRB1->F2_RELACA) <> ''","BR_AZUL"})

		aAdd(aCorCab2,{"Alltrim(TRB3->F1_RELACA) == ''","BR_VERDE"})
		aAdd(aCorCab2,{"Alltrim(TRB3->F1_RELACA) <> ''","BR_AZUL"})

		aAdd(aCorDet1,{"Alltrim(TRB2->D2_RELACA) == ''","BR_VERDE"})
		aAdd(aCorDet1,{"Alltrim(TRB2->D2_RELACA) <> ''","BR_AZUL"})

		aAdd(aCorDet2,{"Alltrim(TRB4->D1_RELACA) == ''","BR_VERDE"})
		aAdd(aCorDet2,{"Alltrim(TRB4->D1_RELACA) <> ''","BR_AZUL"})
		//aCoors := FWGetDialogSize()
		//Faz o calculo automatico de dimensoes de objetos
		oSize := FwDefSize():New(.T.)
		oSize:lLateral := .F.
		oSize:lProp	:= .T. // Proporcional
		oSize:AddObject( "BROWSE" ,75 ,100 ,.T. ,.T. ) // Totalmente dimensionavel
		oSize:Process() // Dispara os calculos
		aPosDialog:={oSize:aWindSize[1]*0.75,oSize:aWindSize[2]*0.75,oSize:aWindSize[3]*0.75,oSize:aWindSize[4]*0.75}
		aPosPanel := aPosDialog

		//       DEFINE MSDIALOG oDlg TITLE 'cTitle' FROM aPosDialog[1],aPosDialog[2] TO aPosDialog[3],aPosDialog[4] Of oMainWnd   PIXEL

		DEFINE MSDIALOG oDlg TITLE 'safetrace ' FROM 0, 0 TO nJanAltu, nJanLarg  Of oMainWnd   PIXEL

		//u_showarray(aPosPanel)
		@ 0,10 FOLDER oFolder SIZE nJanAltu, nJanLarg OF oDlg  PIXEL
		oFolder:AddItem("Dados",.T.)
		oFolder:AddItem("Geracao",.T.)

		oFolder:SetOption(1)
		//primeira posicao posiÃ§Ã£o vertical,
		//segunda horizontal,
		//terceira largura
		//quarta altura
		//oPanel1     := TPanel():New(aPosPanel[3] * 0.3  , aPosPanel[2]*2 , "", oDlg ,, .T., .T., , , aPosPanel[4] * 0.7 , aPosPanel[3] * 0.29)
		@ aPosPanel[1],05  Say  _oLScab  var _cLScab  size 250,08 OF oFolder:aDialogs[1] PIXEL FONT oFnt


		oPanel1     := TPanel():New(aPosPanel[1]+14    , aPosPanel[2] , "", oFolder:aDialogs[1] ,, .T., .T., , , aPosPanel[4]*0.28 ,aPosPanel[3] *  0.165)

		DbSelectArea('SX3')
		DbSetOrder(2)
		DbSeek('F2_DOC')       ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('F2_SERIE')     ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('F2_CLIENTE')   ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('F2_LOJA')      ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('A1_NOME')      ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('F2_EMISSAO')   ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('F2_FILIAL')    ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		AADD(aCampS,{"F2_RELACA","","Associa��es  ",""})
		DbSeek('F2_CHVNFE')    ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})

		FWMsgRun(, {|oSay| CriaCab( oSay,1) }, 'Buscando notas de venda (SF2)', 'Aguarde...' )

		oCabec1 := MsSelect():New("TRB1"				,;	//Alias	do Arquivo de Filtro
		""		,;	//Campo para controle do mark
		""	,;	//Condicao para o Mark // "!E2_SALDO"
		aCampS		,;	//Array com os Campos para o Browse
		NIL	,;	//?
		,;	//Conteudo a Ser Gravado no campo de controle do Mark
		{2, 2, 100,100}	,;	//Coordenadas do Objeto
		NIL					,;  //?
		NIL					,;	//?
		oPanel1	 ;	//Objeto Dialog
		,,aCorCab1)


		oCabec1:oBrowse:lhasMark := .t.
		oCabec1:oBrowse:lCanAllmark := .f.
		oCabec1:oBrowse:Refresh()
		oCabec1:oBrowse:lAllMark := .F.

		oCabec1:oBrowse:bChange    := {||FWMsgRun(, {|oSay| filterT1( oSay ),filterT2( oSay ) }, 'Filtrando', 'Aguarde...' )}  // Executa quando troca de linha.
		//oCabec:oBrowse:bLDblClick := {||U_DblClNfeXml( 1 )}  // Duplo clique expande consulta.

		oCabec1:oBrowse:acolumns[1]:lbitmap := .T.
		oCabec1:oBrowse:acolumns[1]:lnolite := .T.
		oCabec1:oBrowse:acolumns[1]:ledit := .f.

		oCabec1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		//primeira posicao posiÃ§Ã£o vertical,
		//segunda horizontal,
		//terceira largura
		//quarta altura

		@ aPosPanel[1],((aPosPanel[4])*0.28) +10  Say  _oLEcab  var _cLEcab  size 250,08 OF oFolder:aDialogs[1] PIXEL FONT oFnt

		oPanel3     := TPanel():New(aPosPanel[1]+14    ,((aPosPanel[4])*0.28) +10, "", oFolder:aDialogs[1] ,, .T., .T., , , aPosPanel[4]*0.28,aPosPanel[3] *  0.165)

		aCampS := {}
		DbSelectArea('SX3')
		DbSetOrder(2)
		DbSeek('F1_FILIAL')    ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('F1_DOC')       ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('F1_SERIE')     ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('F1_FORNECE')   ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('A2_NOME')      ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('F1_LOJA')      ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('F1_EMISSAO')   ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		AADD(aCampS,{"F1_RELACA","","AssociaÃ§Ãµes  ",""})
		DbSeek('F1_CHVNFE')   ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('A2_LAT')   ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('A2_LON')   ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})


		FWMsgRun(, {|oSay| CriaCab(oSay,2) }, 'Buscando notas de entrada produtor (SF1)', 'Aguarde...' )

		oCabec3 := MsSelect():New("TRB3"				,;	//Alias	do Arquivo de Filtro
		""		,;	//Campo para controle do mark
		""	,;	//Condicao para o Mark // "!E2_SALDO"
		aCampS		,;	//Array com os Campos para o Browse
		NIL	,;	//?
		,;	//Conteudo a Ser Gravado no campo de controle do Mark
		{2, 2, 100,100}	,;	//Coordenadas do Objeto
		NIL					,;  //?
		NIL					,;	//?
		oPanel3	 ;	//Objeto Dialog
		,,aCorCab2)


		oCabec3:oBrowse:lhasMark := .t.
		oCabec3:oBrowse:lCanAllmark := .f.
		oCabec3:oBrowse:Refresh()
		oCabec3:oBrowse:lAllMark := .F.

		oCabec3:oBrowse:bChange    := {||FWMsgRun(, {|oSay| filterT2( oSay ) }, 'Filtrando', 'Aguarde...' )}

		oCabec3:oBrowse:acolumns[1]:lbitmap := .T.
		oCabec3:oBrowse:acolumns[1]:lnolite := .T.
		oCabec3:oBrowse:acolumns[1]:ledit := .f.

		oCabec3:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


		@ (aPosPanel[3] *  0.2 ) , 05  Say  _oLSite  var _cLSite  size 250,08 OF oFolder:aDialogs[1] PIXEL FONT oFnt

		oPanel2     := TPanel():New((aPosPanel[3] *  0.2 ) + 10, aPosPanel[2] , "", oFolder:aDialogs[1] ,, .T., .T., , , aPosPanel[4]*0.28 , aPosPanel[3] *  0.165)
		//https://tdn.totvs.com/display/public/framework/FwBrowse

		//https://terminaldeinformacao.com/2020/07/03/migrando-do-msnewgetdados-para-fwbrowse-e-mvc/

		aCampS := {}
		//AADD(aCampt,{"F2_OKMS","","  ",""})
		DbSelectArea('SX3')
		DbSetOrder(2)
		DbSeek('D2_COD')       ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('B1_DESC')      ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D2_QUANT')     ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D2_TOTAL')     ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D2_FILIAL')    ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D2_ITEM')      ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D2_DOC')       ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D2_SERIE')     ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D2_CLIENTE')   ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D2_LOJA')      ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D2_EMISSAO')   ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		AADD(aCampS,{"D2_RELACA","","AssociaÃ§Ãµes  ",""})
		DbSeek('D2_PEDIDO')   ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})


		FWMsgRun(, {|oSay| CriaDet( oSay,1 ) }, 'Buscando itens nota de venda (SD2)', 'Aguarde...' )

		oCabec2 := MsSelect():New("TRB2"				,;	//Alias	do Arquivo de Filtro
		""		,;	//Campo para controle do mark
		""	,;	//Condicao para o Mark // "!E2_SALDO"
		aCampS		,;	//Array com os Campos para o Browse
		NIL	,;	//?
		@cMrca,;	//Conteudo a Ser Gravado no campo de controle do Mark
		{2, 2, 100,100}	,;	//Coordenadas do Objeto
		NIL					,;  //?
		NIL					,;	//?
		oPanel2	 ;	//Objeto Dialog
		,,aCorDet1)


		oCabec2:oBrowse:lhasMark := .t.
		oCabec2:oBrowse:lCanAllmark := .f.
		oCabec2:oBrowse:Refresh()
		oCabec2:oBrowse:lAllMark := .F.

		//oCabec2:oBrowse:bChange    := {||FWMsgRun(, {|oSay| filterT( oSay ) }, 'Filtrando', 'Aguarde...' )}  // Executa quando troca de linha.
		//oCabec2:oBrowse:bLDblClick := {||U_DblClNfeXml( 1 )}  // Duplo clique expande consulta.

		oCabec2:oBrowse:acolumns[1]:lbitmap := .T.
		oCabec2:oBrowse:acolumns[1]:lnolite := .T.
		oCabec2:oBrowse:acolumns[1]:ledit := .f.

		oCabec2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		@ (aPosPanel[3] *  0.2 ) , ((aPosPanel[4])*0.28) + 10  Say  _oLEite  var _cLEite  size 250,08 OF oFolder:aDialogs[1] PIXEL FONT oFnt

		oPanel4     := TPanel():New((aPosPanel[3] *  0.2)+10, ((aPosPanel[4])*0.28) + 10, "", oFolder:aDialogs[1] ,, .T., .T., , , aPosPanel[4]*0.28 , aPosPanel[3] *  0.165)
		//https://tdn.totvs.com/display/public/framework/FwBrowse

		//https://terminaldeinformacao.com/2020/07/03/migrando-do-msnewgetdados-para-fwbrowse-e-mvc/

		aCampS := {}
		AADD(aCampS,{"D1_OKMS","","  ",""})
		DbSelectArea('SX3')
		DbSetOrder(2)
		DbSeek('D1_COD')       ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('B1_DESC')      ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D1_QUANT')     ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D1_TOTAL')     ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D1_FILIAL')    ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D1_ITEM')      ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D1_DOC')       ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D1_SERIE')     ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D1_FORNECE')   ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D1_LOJA')      ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		DbSeek('D1_EMISSAO')   ; AADD(aCampS,{X3_CAMPO,"",X3_TITULO,X3_PICTURE})
		AADD(aCampS,{"D1_RELACA","","AssociaÃ§Ãµes  ",""})




		FWMsgRun(, {|oSay| CriaDet( oSay,2 ) }, 'Buscando itens notas produtor (SD1)', 'Aguarde...' )

		oCabec4 := MsSelect():New("TRB4"				,;	//Alias	do Arquivo de Filtro
		"D1_OKMS"		,;	//Campo para controle do mark
		""	,;	//Condicao para o Mark // "!E2_SALDO"
		aCampS		,;	//Array com os Campos para o Browse
		NIL	,;	//?
		@cMrca,;	//Conteudo a Ser Gravado no campo de controle do Mark
		{2, 2, 100,100}	,;	//Coordenadas do Objeto
		NIL					,;  //?
		NIL					,;	//?
		oPanel4	 ;	//Objeto Dialog
		,,aCorDet2)


		oCabec4:oBrowse:lhasMark := .t.
		oCabec4:oBrowse:lCanAllmark := .f.
		oCabec4:bMark := {| | Disp(),ATUTR9() }

		oCabec4:oBrowse:Refresh()
		oCabec4:oBrowse:lAllMark := .F.

		oCabec4:oBrowse:acolumns[1]:lbitmap := .T.
		oCabec4:oBrowse:acolumns[1]:lnolite := .T.
		oCabec4:oBrowse:acolumns[1]:ledit := .f.

		oCabec4:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


		@ aSize[4] * 0.89 ,01  BUTTON oBtn4    PROMPT OemToAnsi('Preparar envio')    SIZE 50,13  ACTION {|| MsgRun ("Selecionando registros...", "Aguarde", {||_montaTree(.F.)})} OF oFolder:aDialogs[1]  PIXEL


		//oPanelR    := TPanel():New( aPosPanel[1]  + 4   ,aPosPanel[4] * 0.45 , "", oFolder:aDialogs[2] ,, .T., .T., , , aPosPanel[4] * 0.3 , aPosPanel[3] * 0.165)

		oPanelR    := TPanel():New( aPosPanel[1]+14    , aPosPanel[2] , "", oFolder:aDialogs[2] ,, .T., .T., , , aPosPanel[4] * 0.2 ,aPosPanel[3] * 0.48)

		MENU oMenu POPUP

		MENUITEM 'Ver cadastro (SZ4)'  Action ALTERA(Right(Alltrim(oTree:GetPrompt()),6))
		MENUITEM 'Excluir Item'        Action delitem()
		MENUITEM 'Filtrar NFe'         Action FILTER(.T.)
		MENUITEM 'Limpar Filtro'       Action FILTER(.F.)
		MENUITEM 'Gerar Safe'          Action _GeraSafe(Right(Alltrim(oTree:GetPrompt()),6),.t.,oTree:GetCargo())
		MENUITEM 'Gerar JSON'          Action _Gjson(Right(Alltrim(oTree:GetPrompt()),6))
		ENDMENU

		@ 2 ,2  BUTTON oBtn5    PROMPT OemToAnsi('Enviar')    SIZE 50,13  ACTION {|| MsgRun ("Selecionando registros...", "Aguarde", {||fEnviar(.F.)})} OF oFolder:aDialogs[2]  PIXEL
		oBtn5:Disable()

		oTree := dbTree():New(10     , 2      , aSize[6] * 0.34    , aSize[4] * 0.5   ,oPanelR,           ,/*{|| msgalert(oTree:GetCargo())}*/,.T.)
		oTree:bRClicked  := { |o,x,y| _mPopup(o,x ,y -150,oMenu) }
		//oTree:bChange := {|| _abrepanel(oTree:GetCargo())}
		_montaTree(.t.)

		@ ((aPosPanel[3] *  0.4) ) , 05  Say  _oREai  var _cREai  size 250,08 OF oFolder:aDialogs[1] PIXEL FONT oFnt
		oPanel5     := TPanel():New((aPosPanel[3] *  0.4) + 10, aPosPanel[2], "", oFolder:aDialogs[1] ,, .T., .T., , , aPosPanel[4]*0.55,aPosPanel[3] *  0.165)
		//https://tdn.totvs.com/display/public/framework/FwBrowse

		//https://terminaldeinformacao.com/2020/07/03/migrando-do-msnewgetdados-para-fwbrowse-e-mvc/

		aCampS := {}
		DbSelectArea('SX3')
		DbSetOrder(2)
		DbSeek('D1_FILIAL')    	; AADD(aCampS,{X3_CAMPO,"",'Filial NF Entrada',X3_PICTURE})
		DbSeek('D1_DOC')       	; AADD(aCampS,{X3_CAMPO,"",'Doc Entrada'      ,X3_PICTURE})
		DbSeek('D1_SERIE')     	; AADD(aCampS,{X3_CAMPO,"",'Serie Entrada'    ,X3_PICTURE})
		DbSeek('D1_FORNECE')   	; AADD(aCampS,{X3_CAMPO,"",'Fornecedor'       ,X3_PICTURE})
		DbSeek('D2_FILIAL')   	; AADD(aCampS,{X3_CAMPO,"",'Filial NF saida'  ,X3_PICTURE})
		DbSeek('D2_DOC')   		; AADD(aCampS,{X3_CAMPO,"",'Doc saida'        ,X3_PICTURE})
		DbSeek('D2_SERIE')   	; AADD(aCampS,{X3_CAMPO,"",'Serie Saida'      ,X3_PICTURE})
		DbSeek('D2_CLIENTE')   	; AADD(aCampS,{X3_CAMPO,"",'Cliente'          ,X3_PICTURE})
		DbSeek('D2_COD')      	; AADD(aCampS,{X3_CAMPO,"",'Produto venda'    ,X3_PICTURE})
		DbSeek('D2_ITEM')       ; AADD(aCampS,{X3_CAMPO,"",'Item venda'       ,X3_PICTURE})
		DbSeek('D2_LOJA')       ; AADD(aCampS,{X3_CAMPO,"",'Loja cli'         ,X3_PICTURE})
		DbSeek('D1_COD')        ; AADD(aCampS,{X3_CAMPO,"",'Produto Entrada'  ,X3_PICTURE})
		DbSeek('D1_ITEM')       ; AADD(aCampS,{X3_CAMPO,"",'Item Entrada'     ,X3_PICTURE})
		DbSeek('D1_LOJA')       ; AADD(aCampS,{X3_CAMPO,"",'Loja fornecedor'  ,X3_PICTURE})
		DbSeek('ZS4_CODSAF')    ; AADD(aCampS,{X3_CAMPO,"",'Codigo Safe'    ,X3_PICTURE})  //CODIGO DA TABELA SAFE
		DbSeek('D2_PEDIDO')     ; AADD(aCampS,{X3_CAMPO,"",'Pedido venda'     ,X3_PICTURE})
		DbSeek('F2_CHVNFE')     ; AADD(aCampS,{X3_CAMPO,"",'Chave NF saida'   ,X3_PICTURE})
		DbSeek('F1_CHVNFE')     ; AADD(aCampS,{X3_CAMPO,"",'Chave NF entrada' ,X3_PICTURE})
		DbSeek('F1_EMISSAO')    ; AADD(aCampS,{X3_CAMPO,"",'Emissao nf ent'    ,X3_PICTURE})
		DbSeek('D2_QUANT')      ; AADD(aCampS,{X3_CAMPO,"",'Quantidade'       ,X3_PICTURE})

		FWMsgRun(, {|oSay| CriaRes( oSay ) }, 'Criando estrutura auxiliar', 'Aguarde...' )

		oCabec5 := MsSelect():New("TRB9"				,;	//Alias	do Arquivo de Filtro
		""		,;	//Campo para controle do mark
		""	,;	//Condicao para o Mark // "!E2_SALDO"
		aCampS		,;	//Array com os Campos para o Browse
		NIL	,;	//?
		@cMrca,;	//Conteudo a Ser Gravado no campo de controle do Mark
		{2, 2, 100,100}	,;	//Coordenadas do Objeto
		NIL					,;  //?
		NIL					,;	//?
		oPanel5	 ;	//Objeto Dialog
		,,)


		oCabec5:oBrowse:lhasMark := .t.
		oCabec5:oBrowse:lCanAllmark := .f.
		oCabec5:bMark := {| | Disp()}

		oCabec5:oBrowse:Refresh()
		oCabec5:oBrowse:lAllMark := .F.

		oCabec5:oBrowse:acolumns[1]:lbitmap := .T.
		oCabec5:oBrowse:acolumns[1]:lnolite := .T.
		oCabec5:oBrowse:acolumns[1]:ledit := .f.

		oCabec5:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		//oPanel:Align := CONTROL_ALIGN_ALLCLIENT
		ACTIVATE MSDIALOG oDlg CENTERED

		TRB1->(DbCloseArea())
		TRB2->(DbCloseArea())
		TRB3->(DbCloseArea())
		TRB4->(DbCloseArea())
		TRB9->(DbCloseArea())
	endif
RETURN

Static Function FILTER(_lFil)
	_cNota := Right(Alltrim(oTree:GetCargo()),9)
	dbselectarea('TRB9')
	TRB9->(dbClearFilter())
	If _lFil
		TRB9->(dbSetFilter( {|| TRB9->D2_DOC==_cNota}, "TRB9->D2_DOC=='"+_cNota+"'" ))
	EndIf
	TRB9->(DBGoTop())
	oCabec5:oBrowse:Refresh(.t.)
Return

Static Function ALTERA(_cCodsf)
	private INCLUI := .f.
	private ALTERA := .f.
	CCADASTRO := "Cadastro safe"

	DbSelectArea("ZS4")
	DbSeek(fwfilial("ZS4")+_cCodsf,.f.)
	If Found()
		AxAltera('ZS4', ZS4->(RecNo()), 4)
	EndIf
Return

Static Function ATUTR9()
	Local _nx := 1
	DbSelectArea("TRB9")
	ZAP
	If Len(_aArray) > 0
		For _nx:=1 To Len(_aArray)
			RecLock("TRB9",.T.)
			TRB9->D1_FILIAL := _aArray[_nx,9]
			TRB9->D1_DOC	:= _aArray[_nx,1]
			TRB9->D1_SERIE  := _aArray[_nx,2]
			TRB9->D1_FORNECE:= _aArray[_nx,3]
			TRB9->D2_FILIAL := _aArray[_nx,10]
			TRB9->D2_DOC    := _aArray[_nx,5]
			TRB9->D2_SERIE  := _aArray[_nx,6]
			TRB9->D2_CLIENTE:= _aArray[_nx,7]
			TRB9->D2_COD    := _aArray[_nx,13]
			TRB9->D2_ITEM   := _aArray[_nx,14]
			TRB9->D2_LOJA   := _aArray[_nx,15]
			TRB9->D1_COD    := _aArray[_nx,16]
			TRB9->D1_ITEM   := _aArray[_nx,17]
			TRB9->D1_LOJA   := _aArray[_nx,18]
			TRB9->ZS4_CODSAF  := ''
			TRB9->D2_PEDIDO := _aArray[_nx,19]
			TRB9->F2_CHVNFE := _aArray[_nx,20]
			TRB9->F1_CHVNFE := _aArray[_nx,21]
			TRB9->F1_EMISSAO:= _aArray[_nx,22]
			TRB9->D2_QUANT  := _aArray[_nx,23]
			MsUnLock()
		Next
	EndIf
	TRB9->(DbGoTop())
	oCabec5:oBrowse:Refresh(.t.)
Return

Static Function delitem()
	Local _nx := 1
	dbselectarea('TRB2')
	TRB2->(dbClearFilter())
	dbselectarea('TRB4')
	TRB4->(dbClearFilter())
	If MsgYesNo("Deseja excluir?","Atencao")
		_cNota := Substring(Alltrim(oTree:GetCargo()),5,9)

		DbSelectArea("TRB9")
		DbSeek(_cNota)
		Do while !TRB9->(Eof()) .And. _cNota == D2_DOC
			//Aadd(_aArray, {TRB4->D1_DOC, TRB4->D1_SERIE, TRB4->D1_FORNECE, TRB4->(Recno()), TRB2->D2_DOC, TRB2->D2_SERIE, TRB2->D2_CLIENTE, TRB2->(Recno()), TRB4->D1_FILIAL, TRB2->D2_FILIAL, TRB1->(Recno()), TRB3->(Recno())})
			_nPos:=ascan(_aArray, {|_x| _x[1]+_x[2]+_x[3] == TRB9->D1_DOC+TRB9->D1_SERIE+TRB9->D1_FORNECE})
			If _nPos > 0
				DbSelectArea("TRB4")
				DbGoTo(_aArray[_nPos,4])
				//If Found()
				RecLock("TRB4",.F.)
				TRB4->D1_RELACA := strtran(TRB4->D1_RELACA, "<"+Alltrim("TRB4"+Alltrim(Str(_aArray[_nPos,12])))+">", "")
				MSUNLOCK()
				//EndIf
				DbSelectArea("TRB3")
				DbGoTo(_aArray[_nPos,12])
				//If Found()
				RecLock("TRB3",.F.)
				TRB3->F1_RELACA := strtran(TRB3->F1_RELACA, "<"+Alltrim("TRB3"+Alltrim(Str(_aArray[_nPos,8])))+">", "")
				MSUNLOCK()
				//EndIf
				DbSelectArea("TRB2")
				DbGoTo(_aArray[_nPos,8])
				//If Found()
				RecLock("TRB2",.F.)
				TRB2->D2_RELACA := strtran(TRB2->D2_RELACA, "<"+Alltrim("TRB2"+Alltrim(Str(_aArray[_nPos,11])))+">", "")
				MSUNLOCK()
				//EndIf
				DbSelectArea("TRB1")
				DbGoTo(_aArray[_nPos,11])
				//If Found()
				RecLock("TRB1",.F.)
				TRB1->F2_RELACA := strtran(TRB1->F2_RELACA, "<"+Alltrim("TRB1"+Alltrim(Str(_aArray[_nPos,8])))+">", "") //Alltrim(TRB1->F2_RELACA)+"<"+Alltrim(TRB2->D2_DOC+"|"+TRB2->D2_SERIE)+">"
				MSUNLOCK()
				_aCols := AClone(_aArray)
				_aArray:= {}
				For _nx:=1 To Len(_aCols)
					If _nx <> _nPos
						Aadd(_aArray, {_aCols[_nx,1], _aCols[_nx,2], _aCols[_nx,3], _aCols[_nx,4], _aCols[_nx,5], _aCols[_nx,6], _aCols[_nx,7], _aCols[_nx,8], _aCols[_nx,9], _aCols[_nx,10], _aCols[_nx,11], _aCols[_nx,12], _aCols[_nx,13], _aCols[_nx,14], _aCols[_nx,15], _aCols[_nx,16], _aCols[_nx,17],_aCols[_nx,18], _aCols[_nx,19],_aCols[_nx,20], _aCols[_nx,21], _aCols[_nx,22], _aCols[_nx,23]})
					EndIf
				Next
			EndIf
			TRB9->(DbDelete())
			TRB9->(DbSkip())
		EndDo
		oTree:DelItem()
	EndIf
	TRB9->(DbGoTop())
	oCabec1:oBrowse:Refresh(.t.)
	oCabec2:oBrowse:Refresh(.t.)
	oCabec3:oBrowse:Refresh(.t.)
	oCabec4:oBrowse:Refresh(.t.)
	oCabec5:oBrowse:Refresh(.t.)
	filterT1()
	filterT2()
Return

Static Function CriaCab(oSay,_nQual)

	local aIndex := {}
	local _stru  := {}
	local cquery

	If _nQual == 1
		cquery := " SELECT * FROM SF2010 "
		cquery += "  inner join SA1010 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1_GERSAFT IN ('1','3')  AND SA1010.D_E_L_E_T_ = '' "
		cquery += "  WHERE F2_EMISSAO = '"+dtos(mv_par03)+"' and F2_CLIENTE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'" 
		cquery += "  AND F2_LOJA >= '"+mv_par06+"' AND F2_LOJA <= '"+MV_PAR07+"'"
		cquery += "  AND SF2010.D_E_L_E_T_ = ''  ORDER BY F2_CLIENTE "

		cquery := ChangeQuery(cquery)
		TCQUERY cQuery NEW ALIAS "TRB5"

		TcSetField("TRB5",'F2_EMISSAO',"D")

		oSay:cCaption := ('Gerando arquivo de trabalho...')
		ProcessMessages()

		DbSelectArea('SX3')
		DbSetOrder(2)

		aAdd(_stru,{ GetSx3Cache( "F2_DOC" , "X3_CAMPO" ) 	 , GetSx3Cache( "F2_DOC" , "X3_TIPO" )	  , GetSx3Cache( "F2_DOC" , "X3_TAMANHO" )	  , GetSx3Cache( "F2_DOC" , "X3_DECIMAL" )		} )
		aAdd(_stru,{ GetSx3Cache( "F2_SERIE" , "X3_CAMPO" )  , GetSx3Cache( "F2_SERIE" , "X3_TIPO" )  , GetSx3Cache( "F2_SERIE" , "X3_TAMANHO" )  , GetSx3Cache( "F2_SERIE" , "X3_DECIMAL" )	} )
		aAdd(_stru,{ GetSx3Cache( "F2_CLIENTE" , "X3_CAMPO" ), GetSx3Cache( "F2_CLIENTE" , "X3_TIPO" ), GetSx3Cache( "F2_CLIENTE" , "X3_TAMANHO" ), GetSx3Cache( "F2_CLIENTE" , "X3_DECIMAL" )	} )
		aAdd(_stru,{ GetSx3Cache( "A1_NOME" , "X3_CAMPO" ),    GetSx3Cache( "A1_NOME" , "X3_TIPO" ),    GetSx3Cache( "A1_NOME" , "X3_TAMANHO" ), GetSx3Cache( "A1_NOME" , "X3_DECIMAL" )	} )
		aAdd(_stru,{ GetSx3Cache( "F2_LOJA" , "X3_CAMPO" ),    GetSx3Cache( "F2_LOJA" , "X3_TIPO" ),    GetSx3Cache( "F2_LOJA" , "X3_TAMANHO" ), GetSx3Cache( "F2_CLIENTE" , "X3_DECIMAL" )	} )
		aAdd(_stru,{ GetSx3Cache( "F2_EMISSAO" , "X3_CAMPO" ), GetSx3Cache( "F2_EMISSAO" , "X3_TIPO" ), GetSx3Cache( "F2_EMISSAO" , "X3_TAMANHO" ), GetSx3Cache( "F2_EMISSAO" , "X3_DECIMAL" )	} )
		aAdd(_stru,{ GetSx3Cache( "F2_FILIAL" , "X3_CAMPO" ) , GetSx3Cache( "F2_FILIAL" , "X3_TIPO" ) , GetSx3Cache( "F2_FILIAL" , "X3_TAMANHO" ) , GetSx3Cache( "F2_FILIAL" , "X3_DECIMAL" )	} )
		AADD(_stru,{"F2_RELACA"  ,"C"	,250		,0		})
		aAdd(_stru,{ GetSx3Cache( "F2_CHVNFE" , "X3_CAMPO" ), GetSx3Cache( "F2_CHVNFE" , "X3_TIPO" ), GetSx3Cache( "F2_CHVNFE" , "X3_TAMANHO" ), GetSx3Cache( "F2_CHVNFE" , "X3_DECIMAL" )	} )


		If Select("TRB1") # 0
			TRB1->(dbCloseArea())
		EndIf
		oTable := FWTemporaryTable():New('TRB1')
		oTable:SetFields(_stru)

		aIndex	:=	{'F2_DOC' , 'F2_SERIE' }
		oTable:AddIndex("01", aIndex)

		aIndex	:=	{'F2_CLIENTE' }
		oTable:AddIndex("02", aIndex)

		cArqTab := oTable:GetRealName()
		oTable:Create()

		DBSelectArea("TRB5")
		while !eof()
			DbSelectArea("TRB1")
			RecLock("TRB1",.T.)
			TRB1->F2_FILIAL  :=   TRB5->F2_FILIAL
			TRB1->F2_DOC     :=   TRB5->F2_DOC
			TRB1->F2_SERIE   :=   TRB5->F2_SERIE
			TRB1->F2_CLIENTE :=   TRB5->F2_CLIENTE
			TRB1->F2_LOJA    :=   TRB5->F2_LOJA
			TRB1->A1_NOME    :=   Posicione("SA1",1,fwfilial("SA1") + TRB5->F2_CLIENTE + TRB5->F2_LOJA,"A1_NOME")
			TRB1->F2_EMISSAO :=   TRB5->F2_EMISSAO
			TRB1->F2_RELACA  :=   ""
			TRB1->F2_CHVNFE  :=    TRB5->F2_CHVNFE

			DBSelectArea("TRB5")
			DBSkip()
		enddo
		TRB5->(dbCloseArea())

		DbSelectArea("TRB1")
		TRB1->(DbSetOrder(1))
		TRB1->(dbGotop())
	Else

		//cquery := " SELECT * FROM SF1010 WHERE F1_EMISSAO BETWEEN '"+DTOS(mv_par04)+"' AND '"+DTOS(mv_par05)+"'"
		//cquery += " AND F1_FILIAL = '03' "
		//cquery += " AND D_E_L_E_T_ = '' and F1_CHVNFE <> '' AND F1_TIPO <> 'D' ORDER BY F1_FORNECE "

		cquery := "	SELECT F1_FILIAL, F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_EMISSAO,F1_CHVNFE  FROM SF1010 "
		cquery += " INNER JOIN SD1010 ON D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA =  F1_LOJA "
		cquery += " AND D1_EMISSAO BETWEEN '"+DTOS(mv_par04)+"' AND '"+DTOS(mv_par05)+"' AND D1_TES IN ('190','192','328') AND SD1010.D_E_L_E_T_ = ''  "
		cquery += " INNER JOIN SA2010 ON F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA AND RTRIM(A2_CAR) <> '' AND SA2010.D_E_L_E_T_ = ''  "
		cquery += " WHERE F1_EMISSAO BETWEEN '"+DTOS(mv_par04)+"' AND '"+DTOS(mv_par05)+"'   AND SF1010.D_E_L_E_T_ = '' and F1_CHVNFE <> '' AND F1_TIPO <> 'D'  "
		cquery += " GROUP BY F1_FILIAL, F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_EMISSAO,F1_CHVNFE "
		cquery += " ORDER BY F1_FORNECE "
		cquery := ChangeQuery(cquery)
		TCQUERY cQuery NEW ALIAS "TRB5"

		TcSetField("TRB5",'F1_EMISSAO',"D")

		_stru := {}
		DbSelectArea('SX3')
		DbSetOrder(2)
		aAdd(_stru,{ GetSx3Cache( "F1_FILIAL" , "X3_CAMPO" )  , GetSx3Cache( "F1_FILIAL" , "X3_TIPO" ) , GetSx3Cache( "F1_FILIAL" , "X3_TAMANHO" ) , GetSx3Cache( "F1_FILIAL" , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "F1_DOC" , "X3_CAMPO" )     , GetSx3Cache( "F1_DOC" , "X3_TIPO" )    , GetSx3Cache( "F1_DOC" , "X3_TAMANHO" )    , GetSx3Cache( "F1_DOC" , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "F1_SERIE" , "X3_CAMPO" )   , GetSx3Cache( "F1_SERIE" , "X3_TIPO" )  , GetSx3Cache( "F1_SERIE" , "X3_TAMANHO" )  , GetSx3Cache( "F1_SERIE" , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "F1_FORNECE" , "X3_CAMPO" ) , GetSx3Cache( "F1_FORNECE" , "X3_TIPO" ), GetSx3Cache( "F1_FORNECE" , "X3_TAMANHO" ), GetSx3Cache( "F1_FORNECE" , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "F1_LOJA" , "X3_CAMPO" )    , GetSx3Cache( "F1_LOJA" , "X3_TIPO" )   , GetSx3Cache( "F1_LOJA" , "X3_TAMANHO" )   , GetSx3Cache( "F1_LOJA" , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "A2_NOME" , "X3_CAMPO" )    , GetSx3Cache( "A2_NOME" , "X3_TIPO" )   , GetSx3Cache( "A2_NOME" , "X3_TAMANHO" )   , GetSx3Cache( "A2_NOME" , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "F1_EMISSAO" , "X3_CAMPO" ) , GetSx3Cache( "F1_EMISSAO" , "X3_TIPO" ), GetSx3Cache( "F1_EMISSAO" , "X3_TAMANHO" ), GetSx3Cache( "F1_EMISSAO" , "X3_DECIMAL" )} )
		AADD(_stru,{"F1_RELACA"  ,"C"	,250		,0		})
		aAdd(_stru,{ GetSx3Cache( "F1_CHVNFE" , "X3_CAMPO" ) , GetSx3Cache( "F1_CHVNFE" , "X3_TIPO" ), GetSx3Cache( "F1_CHVNFE" , "X3_TAMANHO" ), GetSx3Cache( "F1_CHVNFE" , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "A2_LAT" , "X3_CAMPO" ), GetSx3Cache( "A2_LAT" , "X3_TIPO" ), GetSx3Cache( "A2_LAT" , "X3_TAMANHO" ), GetSx3Cache( "A2_LAT" , "X3_DECIMAL" )	} )
		aAdd(_stru,{ GetSx3Cache( "A2_LON" , "X3_CAMPO" ), GetSx3Cache( "A2_LON" , "X3_TIPO" ), GetSx3Cache( "A2_LON" , "X3_TAMANHO" ), GetSx3Cache( "A2_LON" , "X3_DECIMAL" )	} )


		If Select("TRB3") # 0
			TRB3->(dbCloseArea())
		EndIf
		oTable := FWTemporaryTable():New('TRB3')
		oTable:SetFields(_stru)

		aIndex	:=	{'F1_DOC' , 'F1_SERIE' }
		oTable:AddIndex("01", aIndex)

		aIndex	:=	{'F1_FORNECE' }
		oTable:AddIndex("02", aIndex)

		cArqTab := oTable:GetRealName()
		oTable:Create()

		DBSelectArea("TRB5")
		while !eof()

			//A2_CAR
			//Posicione("SA2",1,fwfilial("SA2") + TRB9->D1_FORNECE + TRB9->D1_LOJA,"A2_CAR")
			//A2_DATALIN

			DbSelectArea("TRB3")
			RecLock("TRB3",.T.)
			TRB3->F1_FILIAL  := TRB5->F1_FILIAL
			TRB3->F1_DOC     := TRB5->F1_DOC
			TRB3->F1_SERIE   := TRB5->F1_SERIE
			TRB3->F1_FORNECE := TRB5->F1_FORNECE
			TRB3->F1_LOJA    := TRB5->F1_LOJA
			TRB3->A2_NOME    := Posicione("SA2",1,fwfilial("SA2") + TRB5->F1_FORNECE + TRB5->F1_LOJA,"A2_NOME")
			TRB3->F1_EMISSAO := TRB5->F1_EMISSAO
			TRB3->F1_RELACA  := ""
			TRB3->F1_CHVNFE  := TRB5->F1_CHVNFE
			TRB3->A2_LAT     := Posicione("SA2",1,fwfilial("SA2") + TRB5->F1_FORNECE + TRB5->F1_LOJA,"A2_LAT")
			TRB3->A2_LON     := Posicione("SA2",1,fwfilial("SA2") + TRB5->F1_FORNECE + TRB5->F1_LOJA,"A2_LON")


			DBSelectArea("TRB5")
			DBSkip()
		enddo
		TRB5->(dbCloseArea())
		DbSelectArea("TRB3")
		TRB3->(DbSetOrder(1))
		TRB3->(dbGotop())

	endif

Return .T.

Static Function CriaRes(oSay)
	local aIndex := {}
	local _stru  := {}


	If Select("TRB9") # 0
		TRB9->(dbCloseArea())
	EndIf
	DbSelectArea('SX3')
	DbSetOrder(2)
	aAdd(_stru,{ GetSx3Cache( "D1_FILIAL" , "X3_CAMPO" ) 	, GetSx3Cache( "D1_FILIAL" , "X3_TIPO" ) , GetSx3Cache( "D1_FILIAL" , "X3_TAMANHO" ) , GetSx3Cache( "D1_FILIAL" , "X3_DECIMAL" ) } )
	aAdd(_stru,{ GetSx3Cache( "D1_DOC" , "X3_CAMPO" ) 		, GetSx3Cache( "D1_DOC" , "X3_TIPO" )	 , GetSx3Cache( "D1_DOC" , "X3_TAMANHO" )	 , GetSx3Cache( "D1_DOC" , "X3_DECIMAL" )	 } )
	aAdd(_stru,{ GetSx3Cache( "D1_SERIE" , "X3_CAMPO" ) 	, GetSx3Cache( "D1_SERIE" , "X3_TIPO" )  , GetSx3Cache( "D1_SERIE" , "X3_TAMANHO" )	 , GetSx3Cache( "D1_SERIE" , "X3_DECIMAL" )	 } )
	aAdd(_stru,{ GetSx3Cache( "D1_FORNECE" , "X3_CAMPO" ) 	, GetSx3Cache( "D1_FORNECE" , "X3_TIPO" ), GetSx3Cache( "D1_FORNECE" , "X3_TAMANHO" ), GetSx3Cache( "D1_FORNECE" , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "D2_FILIAL" , "X3_CAMPO" ) 	, GetSx3Cache( "D2_FILIAL" , "X3_TIPO" ) , GetSx3Cache( "D2_FILIAL" , "X3_TAMANHO" ) , GetSx3Cache( "D2_FILIAL" , "X3_DECIMAL" ) } )
	aAdd(_stru,{ GetSx3Cache( "D2_DOC" , "X3_CAMPO" ) 		, GetSx3Cache( "D2_DOC" , "X3_TIPO" )	 , GetSx3Cache( "D2_DOC" , "X3_TAMANHO" )	 , GetSx3Cache( "D2_DOC" , "X3_DECIMAL" )	 } )
	aAdd(_stru,{ GetSx3Cache( "D2_SERIE" , "X3_CAMPO" ) 	, GetSx3Cache( "D2_SERIE" , "X3_TIPO" )  , GetSx3Cache( "D2_SERIE" , "X3_TAMANHO" )	 , GetSx3Cache( "D2_SERIE" , "X3_DECIMAL" )  } )
	aAdd(_stru,{ GetSx3Cache( "D2_CLIENTE" , "X3_CAMPO" ) 	, GetSx3Cache( "D2_CLIENTE" , "X3_TIPO" ), GetSx3Cache( "D2_CLIENTE" , "X3_TAMANHO" ), GetSx3Cache( "D2_CLIENTE" , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "D2_COD"  , "X3_CAMPO" )      , GetSx3Cache( "D2_COD"  , "X3_TIPO" )  , GetSx3Cache( "D2_COD"  , "X3_TAMANHO" )  , GetSx3Cache( "D2_COD"  , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "D2_ITEM"  , "X3_CAMPO" )     , GetSx3Cache( "D2_ITEM"  , "X3_TIPO" )  , GetSx3Cache( "D2_ITEM"  , "X3_TAMANHO" )  , GetSx3Cache( "D2_ITEM"  , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "D2_LOJA"  , "X3_CAMPO" )     , GetSx3Cache( "D2_LOJA"  , "X3_TIPO" )  , GetSx3Cache( "D2_LOJA"  , "X3_TAMANHO" )  , GetSx3Cache( "D2_LOJA"  , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "D1_COD"  , "X3_CAMPO" )     , GetSx3Cache( "D1_COD"  , "X3_TIPO" )  , GetSx3Cache( "D1_COD"  , "X3_TAMANHO" )  , GetSx3Cache( "D1_COD"  , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "D1_ITEM"  , "X3_CAMPO" )  , GetSx3Cache( "D1_ITEM"  , "X3_TIPO" )  , GetSx3Cache( "D1_ITEM"  , "X3_TAMANHO" )  , GetSx3Cache( "D1_ITEM"  , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "D1_LOJA"  , "X3_CAMPO" )  , GetSx3Cache( "D1_LOJA"  , "X3_TIPO" )  , GetSx3Cache( "D1_LOJA"  , "X3_TAMANHO" )  , GetSx3Cache( "D1_LOJA"  , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "ZS4_CODSAF"  , "X3_CAMPO" )  , GetSx3Cache( "ZS4_CODSAF"  , "X3_TIPO" )  , GetSx3Cache( "ZS4_CODSAF"  , "X3_TAMANHO" )  , GetSx3Cache( "D1_LOJA"  , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "D2_PEDIDO"  , "X3_CAMPO" )  , GetSx3Cache( "D2_PEDIDO"  , "X3_TIPO" )  , GetSx3Cache( "D2_PEDIDO"  , "X3_TAMANHO" )  , GetSx3Cache( "D2_PEDIDO"  , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "F2_CHVNFE"  , "X3_CAMPO" )  , GetSx3Cache( "F2_CHVNFE"  , "X3_TIPO" )  , GetSx3Cache( "F2_CHVNFE"  , "X3_TAMANHO" )  , GetSx3Cache( "F2_CHVNFE"  , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "F1_CHVNFE"  , "X3_CAMPO" )  , GetSx3Cache( "F1_CHVNFE"  , "X3_TIPO" )  , GetSx3Cache( "F1_CHVNFE"  , "X3_TAMANHO" )  , GetSx3Cache( "F1_CHVNFE"  , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "F1_EMISSAO"  , "X3_CAMPO" )  , GetSx3Cache( "F1_EMISSAO"  , "X3_TIPO" )  , GetSx3Cache( "F1_EMISSAO"  , "X3_TAMANHO" )  , GetSx3Cache( "F1_EMISSAO"  , "X3_DECIMAL" )} )
	aAdd(_stru,{ GetSx3Cache( "D2_QUANT"  , "X3_CAMPO" )    , GetSx3Cache( "D2_QUANT"  , "X3_TIPO" )  , GetSx3Cache( "D2_QUANT"  , "X3_TAMANHO" )  , GetSx3Cache( "D2_QUANT"  , "X3_DECIMAL" )} )

	If Select("TRB9") # 0
		TRB9->(dbCloseArea())
	EndIf
	oTable := FWTemporaryTable():New('TRB9')
	oTable:SetFields(_stru)

	aIndex	:=	{'D2_DOC'}
	oTable:AddIndex("01", aIndex)

	cArqTab := oTable:GetRealName()
	oTable:Create()
Return .T.

Static Function CriaDet(oSay,_nQual)

	local aIndex := {}
	local _stru  := {}
	local cquery

	if _nQual == 1
		cquery := " SELECT * FROM SD2010 "
		cquery += " inner join SA1010 ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_GERSAFT IN ('1','3')  AND SA1010.D_E_L_E_T_ = '' "
		cquery += " WHERE D2_EMISSAO = '"+dtos(mv_par03)+"' and D2_CLIENTE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
		cquery += " AND D2_LOJA >= '"+mv_par06+"'  AND D2_LOJA <= '"+mv_par07+"'"
		cquery += " AND SD2010.D_E_L_E_T_ = '' "



		cquery:= ChangeQuery(cquery)
		TCQUERY cQuery NEW ALIAS "TRB5"
		TcSetField("TRB5",'D2_EMISSAO',"D")

		oSay:cCaption := ('Gerando arquivo de trabalho...')
		ProcessMessages()
		DbSelectArea('SX3')
		DbSetOrder(2)
		//AADD(_stru,{"D2_OKMS"     ,"C"	,2		,0		})
		aAdd(_stru,{ GetSx3Cache( "D2_COD"    , "X3_CAMPO" )  , GetSx3Cache( "D2_COD"    , "X3_TIPO" )  , GetSx3Cache( "D2_COD"    , "X3_TAMANHO" )  , GetSx3Cache( "D2_COD"    , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "B1_DESC"    , "X3_CAMPO" ) , GetSx3Cache( "B1_DESC"    , "X3_TIPO" )  , GetSx3Cache( "B1_DESC"    , "X3_TAMANHO" )  , GetSx3Cache( "B1_DESC"    , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D2_QUANT"  , "X3_CAMPO" )  , GetSx3Cache( "D2_QUANT"  , "X3_TIPO" )  , GetSx3Cache( "D2_QUANT"  , "X3_TAMANHO" )  , GetSx3Cache( "D2_QUANT"  , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D2_TOTAL"  , "X3_CAMPO" )  , GetSx3Cache( "D2_TOTAL"  , "X3_TIPO" )  , GetSx3Cache( "D2_TOTAL"  , "X3_TAMANHO" )  , GetSx3Cache( "D2_TOTAL"  , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D2_FILIAL" , "X3_CAMPO" )  , GetSx3Cache( "D2_FILIAL" , "X3_TIPO" )  , GetSx3Cache( "D2_FILIAL" , "X3_TAMANHO" )  , GetSx3Cache( "D2_FILIAL" , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D2_ITEM"   , "X3_CAMPO" )  , GetSx3Cache( "D2_ITEM"   , "X3_TIPO" )  , GetSx3Cache( "D2_ITEM"   , "X3_TAMANHO" )  , GetSx3Cache( "D2_ITEM"   , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D2_DOC"    , "X3_CAMPO" )  , GetSx3Cache( "D2_DOC"    , "X3_TIPO" )  , GetSx3Cache( "D2_DOC"    , "X3_TAMANHO" )  , GetSx3Cache( "D2_DOC"    , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D2_SERIE"  , "X3_CAMPO" )  , GetSx3Cache( "D2_SERIE"  , "X3_TIPO" )  , GetSx3Cache( "D2_SERIE"  , "X3_TAMANHO" )  , GetSx3Cache( "D2_SERIE"  , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D2_CLIENTE", "X3_CAMPO" )  , GetSx3Cache( "D2_CLIENTE", "X3_TIPO" )  , GetSx3Cache( "D2_CLIENTE", "X3_TAMANHO" )  , GetSx3Cache( "D2_CLIENTE", "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D2_LOJA", "X3_CAMPO" )     , GetSx3Cache( "D2_LOJA", "X3_TIPO" )     , GetSx3Cache( "D2_LOJA ", "X3_TAMANHO" )  , GetSx3Cache( "D2_LOJA", "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D2_EMISSAO", "X3_CAMPO" )  , GetSx3Cache( "D2_EMISSAO", "X3_TIPO" )  , GetSx3Cache( "D2_EMISSAO", "X3_TAMANHO" )  , GetSx3Cache( "D2_EMISSAO", "X3_DECIMAL" )} )
		AADD(_stru,{"D2_RELACA"  ,"C"	,250		,0		})
		aAdd(_stru,{ GetSx3Cache( "D2_PEDIDO", "X3_CAMPO" )  , GetSx3Cache( "D2_PEDIDO", "X3_TIPO" )  , GetSx3Cache( "D2_PEDIDO", "X3_TAMANHO" )  , GetSx3Cache( "D2_PEDIDO", "X3_DECIMAL" )} )

		If Select("TRB2") # 0
			TRB2->(dbCloseArea())
		EndIf
		oTable := FWTemporaryTable():New('TRB2')
		oTable:SetFields(_stru)
		aIndex	:=	{'D2_DOC' , 'D2_SERIE' }
		oTable:AddIndex("01", aIndex)
		aIndex	:=	{'D2_CLIENTE' }
		oTable:AddIndex("02", aIndex)
		cArqTab := oTable:GetRealName()
		oTable:Create()

		DBSelectArea("TRB5")
		while !eof()
			DbSelectArea("TRB2")
			RecLock("TRB2",.T.)
			//TRB2->D2_OKMS    :=   TRB5->F2_OKMS
			TRB2->D2_FILIAL  :=   TRB5->D2_FILIAL
			TRB2->D2_ITEM	 :=   TRB5->D2_ITEM
			TRB2->D2_COD	 :=   TRB5->D2_COD
			TRB2->B1_DESC    :=   Posicione("SB1",1,fwfilial("SB1") + TRB5->D2_COD,"B1_DESC")
			TRB2->D2_QUANT	 :=   TRB5->D2_QUANT
			TRB2->D2_TOTAL	 :=   TRB5->D2_TOTAL
			TRB2->D2_DOC     :=   TRB5->D2_DOC
			TRB2->D2_SERIE   :=   TRB5->D2_SERIE
			TRB2->D2_CLIENTE :=   TRB5->D2_CLIENTE
			TRB2->D2_LOJA    :=   TRB5->D2_LOJA
			TRB2->D2_EMISSAO :=   TRB5->D2_EMISSAO
			TRB2->D2_RELACA  :=   ""
			TRB2->D2_PEDIDO  :=   TRB5->D2_PEDIDO
			DBSelectArea("TRB5")
			DBSkip()
		enddo
		TRB5->(dbCloseArea())

	else
		cquery := " SELECT '' AS D1_OKMS, * from SD1010
		cquery += " WHERE D1_EMISSAO BETWEEN '"+DTOS(mv_par04)+"' AND '"+DTOS(mv_par05)+"' AND D1_TES IN ('190','192','328') AND SD1010.D_E_L_E_T_ = ''

		cquery:= ChangeQuery(cquery)
		TCQUERY cQuery NEW ALIAS "TRB5"

		TcSetField("TRB5",'D1_EMISSAO',"D")

		oSay:cCaption := ('Gerando arquivo de trabalho...')
		ProcessMessages()
		_stru := {}
		DbSelectArea('SX3')
		DbSetOrder(2)
		AADD(_stru,{"D1_OKMS"     ,"C"	,2		,0		})
		aAdd(_stru,{ GetSx3Cache( "D1_COD"    , "X3_CAMPO" )  , GetSx3Cache( "D1_COD"    , "X3_TIPO" )  , GetSx3Cache( "D1_COD"    , "X3_TAMANHO" )  , GetSx3Cache( "D1_COD"    , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "B1_DESC"    , "X3_CAMPO" ) , GetSx3Cache( "B1_DESC"    , "X3_TIPO" )  , GetSx3Cache( "B1_DESC"    , "X3_TAMANHO" )  , GetSx3Cache( "B1_DESC"    , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D1_QUANT"  , "X3_CAMPO" )  , GetSx3Cache( "D1_QUANT"  , "X3_TIPO" )  , GetSx3Cache( "D1_QUANT"  , "X3_TAMANHO" )  , GetSx3Cache( "D1_QUANT"  , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D1_TOTAL"  , "X3_CAMPO" )  , GetSx3Cache( "D1_TOTAL"  , "X3_TIPO" )  , GetSx3Cache( "D1_TOTAL"  , "X3_TAMANHO" )  , GetSx3Cache( "D1_TOTAL"  , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D1_FILIAL" , "X3_CAMPO" )  , GetSx3Cache( "D1_FILIAL" , "X3_TIPO" )	, GetSx3Cache( "D1_FILIAL" , "X3_TAMANHO" )	 , GetSx3Cache( "D1_FILIAL" , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D1_ITEM"   , "X3_CAMPO" )  , GetSx3Cache( "D1_ITEM"   , "X3_TIPO" )  , GetSx3Cache( "D1_ITEM"   , "X3_TAMANHO" )  , GetSx3Cache( "D1_ITEM"   , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D1_DOC" 	  , "X3_CAMPO" )  , GetSx3Cache( "D1_DOC"    , "X3_TIPO" )	, GetSx3Cache( "D1_DOC"    , "X3_TAMANHO" )	 , GetSx3Cache( "D1_DOC"    , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D1_SERIE"  , "X3_CAMPO" )  , GetSx3Cache( "D1_SERIE"  , "X3_TIPO" )	, GetSx3Cache( "D1_SERIE"  , "X3_TAMANHO" )	 , GetSx3Cache( "D1_SERIE"  , "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D1_FORNECE", "X3_CAMPO" )  , GetSx3Cache( "D1_FORNECE", "X3_TIPO" )	, GetSx3Cache( "D1_FORNECE", "X3_TAMANHO" )  , GetSx3Cache( "D1_FORNECE", "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D1_LOJA", "X3_CAMPO" )     , GetSx3Cache( "D1_LOJA", "X3_TIPO" )	    , GetSx3Cache( "D1_LOJA", "X3_TAMANHO" )     , GetSx3Cache( "D1_LOJA", "X3_DECIMAL" )} )
		aAdd(_stru,{ GetSx3Cache( "D1_EMISSAO", "X3_CAMPO" )  , GetSx3Cache( "D1_EMISSAO", "X3_TIPO" )	, GetSx3Cache( "D1_EMISSAO", "X3_TAMANHO" )  , GetSx3Cache( "D1_EMISSAO", "X3_DECIMAL" )} )
		AADD(_stru,{"D1_RELACA"  ,"C"	,250		,0		})

		If Select("TRB4") # 0
			TRB4->(dbCloseArea())
		EndIf
		oTable := FWTemporaryTable():New('TRB4')
		oTable:SetFields(_stru)

		aIndex	:=	{'D1_DOC' , 'D1_SERIE' }
		oTable:AddIndex("01", aIndex)

		aIndex	:=	{'D1_FORNECE' }
		oTable:AddIndex("02", aIndex)

		cArqTab := oTable:GetRealName()
		oTable:Create()


		DBSelectArea("TRB5")
		while !eof()
			DbSelectArea("TRB4")
			RecLock("TRB4",.T.)
			TRB4->D1_OKMS    :=   TRB5->D1_OKMS
			TRB4->D1_FILIAL  :=   TRB5->D1_FILIAL
			TRB4->D1_ITEM	 :=   TRB5->D1_ITEM
			TRB4->D1_COD	 :=   TRB5->D1_COD
			TRB4->B1_DESC	 :=   Posicione("SB1",1,fwfilial("SB1") + TRB5->D1_COD,"B1_DESC")
			TRB4->D1_QUANT	 :=   TRB5->D1_QUANT
			TRB4->D1_TOTAL	 :=   TRB5->D1_TOTAL
			TRB4->D1_DOC     :=   TRB5->D1_DOC
			TRB4->D1_SERIE   :=   TRB5->D1_SERIE
			TRB4->D1_FORNECE :=   TRB5->D1_FORNECE
			TRB4->D1_LOJA    :=   TRB5->D1_LOJA
			TRB4->D1_EMISSAO :=   TRB5->D1_EMISSAO
			TRB4->D1_RELACA  :=   ""
			DBSelectArea("TRB5")
			DBSkip()
		enddo
		TRB5->(dbCloseArea())
		DbSelectArea("TRB4")
	endif
return

static function filterT1(oSay)
	CursorWait()
	dbselectarea('TRB2')
	TRB2->(dbClearFilter())
	TRB2->(dbSetFilter( {|| TRB2->D2_FILIAL==TRB1->F2_FILIAL .AND. TRB2->D2_DOC ==TRB1->F2_DOC .AND. TRB2->D2_SERIE==TRB1->F2_SERIE .AND. TRB2->D2_CLIENTE==TRB1->F2_CLIENTE }, "TRB2->D2_FILIAL=='"+TRB1->F2_FILIAL+"' .AND. TRB2->D2_DOC=='"+TRB1->F2_DOC+"' .AND. TRB2->D2_SERIE=='"+TRB1->F2_SERIE+"' .AND. TRB2->D2_CLIENTE=='"+TRB1->F2_CLIENTE+"'" ))
	TRB2->(DBGoTop())

	TRB2->(dbGotop())
	dbselectarea('TRB2')
	while !eof()
		if  Alltrim("TRB1"+Alltrim(Str(TRB2->(Recno())))) $ TRB1->F2_RELACA
			//dbselectarea('TRB4')
			//Set Filter To
			//_cfil :=  " TRB4->D1_FILIAL+TRB4->D1_DOC+TRB4->D1_SERIE+TRB4->D1_FORNECE =='"+TRB3->F1_FILIAL+TRB3->F1_DOC+TRB3->F1_SERIE+TRB3->F1_FORNECE+"'"
			//dbselectarea('TRB4')
			//Set Filter To &(Alltrim(_cfil))
			DbSelectArea("TRB4")
			TRB4->(dbClearFilter())
			DbSelectArea("TRB4")
			TRB4->(dbSetFilter( {|| TRB4->D1_FILIAL==TRB3->F1_FILIAL .AND. TRB4->D1_DOC ==TRB3->F1_DOC .AND. TRB4->D1_SERIE==TRB3->F1_SERIE .AND. TRB4->D1_FORNECE==TRB3->F1_FORNECE }, "TRB4->D1_FILIAL=='"+TRB3->F1_FILIAL+"' .AND. TRB4->D1_DOC=='"+TRB3->F1_DOC+"' .AND. TRB4->D1_SERIE=='"+TRB3->F1_SERIE+"' .AND. TRB4->D1_FORNECE=='"+TRB3->F1_FORNECE+"'" ))
			TRB4->(DBGoTop())
			dbselectarea('TRB4')
			while !eof()
				if  Alltrim("TRB4"+Alltrim(Str(TRB3->(Recno())))) $ TRB4->D1_RELACA
					TRB2->(dbGotop())
					dbselectarea('TRB2')
					while !eof()
						If Alltrim("TRB3"+Alltrim(Str(TRB2->(Recno())))) $ TRB3->F1_RELACA .And. Alltrim("TRB1"+Alltrim(Str(TRB2->(Recno())))) $ TRB1->F2_RELACA
							TRB4->D1_OKMS := cMrca
						EndIf
						TRB2->(dbskip())
					EndDo
				else
					TRB4->D1_OKMS := ''
				endif
				dbskip()
			enddo
		else
			//dbselectarea('TRB4')
			//Set Filter To
			//dbselectarea('TRB4')
			//Set Filter To &(Alltrim("TRB4->D1_OKMS <> ' '"))
			//TRB4->(dbGotop())
			//dbselectarea('TRB4')
			DbSelectArea("TRB4")
			TRB4->(dbClearFilter())
			DbSelectArea("TRB4")
			TRB4->(dbSetFilter( {|| TRB4->D1_OKMS <> ' ' }, "TRB4->D1_OKMS <> ' '" ))
			TRB4->(DBGoTop())
			dbselectarea('TRB4')
			while !eof()
				If  !Empty(TRB4->D1_OKMS)
					TRB4->D1_OKMS := ""
				EndIf
				TRB4->(dbskip())
			EndDo
		endif
		TRB2->(dbskip())
	enddo

	//dbselectarea('TRB2')
	//Set Filter To
	//oCabec2:oBrowse:Refresh(.t.)

	//DbSelectArea("TRB2")
	//_cfil :=  " TRB2->D2_FILIAL+TRB2->D2_DOC+TRB2->D2_SERIE+TRB2->D2_CLIENTE =='"+TRB1->F2_FILIAL+TRB1->F2_DOC+TRB1->F2_SERIE+TRB1->F2_CLIENTE+"'"
	//Set Filter To &(Alltrim(_cfil))
	TRB2->(dbGotop())

	oCabec4:oBrowse:Setfocus()
	oCabec2:oBrowse:Refresh(.t.)
	oCabec4:oBrowse:Refresh(.t.)
	CursorArrow()
return

static function filterT2(oSay)
	local nRec

	CursorWait()
	dbselectarea('TRB4')
	TRB4->(dbClearFilter())
	//oCabec4:oBrowse:Setfocus()
	//oCabec4:oBrowse:Refresh(.t.)
	nRec  := TRB2->( Recno () )
	//_cfil :=  " TRB4->D1_FILIAL+TRB4->D1_DOC+TRB4->D1_SERIE+TRB4->D1_FORNECE =='"+TRB3->F1_FILIAL+TRB3->F1_DOC+TRB3->F1_SERIE+TRB3->F1_FORNECE+"'"
	DbSelectArea("TRB4")
	TRB4->(dbSetFilter( {|| TRB4->D1_FILIAL==TRB3->F1_FILIAL .AND. TRB4->D1_DOC ==TRB3->F1_DOC .AND. TRB4->D1_SERIE==TRB3->F1_SERIE .AND. TRB4->D1_FORNECE==TRB3->F1_FORNECE }, "TRB4->D1_FILIAL=='"+TRB3->F1_FILIAL+"' .AND. TRB4->D1_DOC=='"+TRB3->F1_DOC+"' .AND. TRB4->D1_SERIE=='"+TRB3->F1_SERIE+"' .AND. TRB4->D1_FORNECE=='"+TRB3->F1_FORNECE+"'" ))
	TRB4->(DBGoTop())
	//Set Filter To &(Alltrim(_cfil))

	TRB4->(dbGotop())
	dbselectarea('TRB4')
	while !eof()
		if  Alltrim("TRB4"+Alltrim(Str(TRB3->(Recno())))) $ TRB4->D1_RELACA
			TRB2->(dbGotop())
			dbselectarea('TRB2')
			while !eof()
				If Alltrim("TRB3"+Alltrim(Str(TRB2->(Recno())))) $ TRB3->F1_RELACA .And. Alltrim("TRB1"+Alltrim(Str(TRB2->(Recno())))) $ TRB1->F2_RELACA
					TRB4->D1_OKMS := cMrca
				EndIf
				TRB2->(dbskip())
			EndDo
		else
			TRB4->D1_OKMS := ''
		endif
		dbskip()
	enddo

	//TRB2->(dbGotop())
	TRB2->( dbGoto ( nRec ) )
	TRB4->(dbGotop())
	//oCabec4:oBrowse:Setfocus()
	//oCabec1:oBrowse:Refresh(.t.)
	oCabec4:oBrowse:Setfocus()
	oCabec2:oBrowse:Refresh(.t.)
	oCabec4:oBrowse:Refresh(.t.)
	CursorArrow()
return

Static Function Disp(_conte)
	Local _nx := 1
	DbSelectArea("TRB1")
	_nRecno1 := TRB1->(Recno())
	DbSelectArea("TRB2")
	_nRecno2 := TRB2->(Recno())
	DbSelectArea("TRB3")
	_nRecno3 := TRB3->(Recno())
	DbSelectArea("TRB4")
	_nRecno4 := TRB4->(Recno())
	If Marked("D1_OKMS")
		RecLock("TRB4",.F.)
		TRB4->D1_OKMS := cMrca
		TRB4->D1_RELACA := Alltrim(TRB4->D1_RELACA)+"<"+Alltrim("TRB4"+Alltrim(Str(TRB3->(Recno()))))+">"
		MSUNLOCK()
		RecLock("TRB3",.F.)
		TRB3->F1_RELACA := Alltrim(TRB3->F1_RELACA)+"<"+Alltrim("TRB3"+Alltrim(Str(TRB2->(Recno()))))+">"
		MSUNLOCK()
		RecLock("TRB2",.F.)
		TRB2->D2_RELACA := Alltrim(TRB2->D2_RELACA)+"<"+Alltrim("TRB2"+Alltrim(Str(TRB1->(Recno()))))+">"
		MSUNLOCK()
		RecLock("TRB1",.F.)
		TRB1->F2_RELACA := Alltrim(TRB1->F2_RELACA)+"<"+Alltrim("TRB1"+Alltrim(Str(TRB2->(Recno()))))+">"
		MSUNLOCK()
		Aadd(_aArray, { TRB4->D1_DOC,  TRB4->D1_SERIE, TRB4->D1_FORNECE,  TRB4->(Recno()),  TRB2->D2_DOC,  TRB2->D2_SERIE,  TRB2->D2_CLIENTE,  TRB2->(Recno()),  TRB4->D1_FILIAL,  TRB2->D2_FILIAL,  TRB1->(Recno()),  TRB3->(Recno()), TRB2->D2_COD,  TRB2->D2_ITEM, TRB2->D2_LOJA, TRB4->D1_COD, TRB4->D1_ITEM, TRB4->D1_LOJA,TRB2->D2_PEDIDO,TRB1->F2_CHVNFE,TRB3->F1_CHVNFE,TRB3->F1_EMISSAO,TRB2->D2_QUANT})
	Else
		DbSelectArea("TRB4")
		DbGoTo(_nRecno4)
		RecLock("TRB4",.F.)
		TRB4->D1_OKMS := ''
		TRB4->D1_RELACA := strtran(TRB4->D1_RELACA, "<"+Alltrim("TRB4"+Alltrim(Str(TRB3->(Recno()))))+">", "") //Alltrim(TRB4->D1_RELACA)+"<"+Alltrim(TRB3->F1_DOC+"|"+TRB3->F1_SERIE)+">"
		MSUNLOCK()
		DbSelectArea("TRB3")
		DbGoTo(_nRecno3)
		RecLock("TRB3",.F.)
		TRB3->F1_RELACA := strtran(TRB3->F1_RELACA, "<"+Alltrim("TRB3"+Alltrim(Str(TRB2->(Recno()))))+">", "") //Alltrim(TRB3->F1_RELACA)+"<"+Alltrim(TRB2->D2_DOC+"|"+TRB2->D2_SERIE)+">"
		MSUNLOCK()
		DbSelectArea("TRB2")
		DbGoTo(_nRecno2)
		RecLock("TRB2",.F.)
		TRB2->D2_RELACA := strtran(TRB2->D2_RELACA, "<"+Alltrim("TRB2"+Alltrim(Str(TRB1->(Recno()))))+">", "") //Alltrim(TRB2->D2_RELACA)+"<"+Alltrim(TRB1->F2_DOC+"|"+TRB1->F2_SERIE)+">"
		MSUNLOCK()
		DbSelectArea("TRB1")
		DbGoTo(_nRecno1)
		RecLock("TRB1",.F.)
		TRB1->F2_RELACA := strtran(TRB1->F2_RELACA, "<"+Alltrim("TRB1"+Alltrim(Str(TRB2->(Recno()))))+">", "") //Alltrim(TRB1->F2_RELACA)+"<"+Alltrim(TRB2->D2_DOC+"|"+TRB2->D2_SERIE)+">"
		MSUNLOCK()
		_nPos:=ascan(_aArray, {|_x| _x[1]+_x[2]+_x[3]+Alltrim(Str(_x[4])) == TRB4->D1_DOC+TRB4->D1_SERIE+TRB4->D1_FORNECE+Alltrim(Str(TRB4->(Recno())))})
		If _nPos > 0
			_aCols := AClone(_aArray)
			_aArray:= {}
			//aDel(_aArray, _nPos)
			//If ValType(_aArray[1]) <> "A"
			//	_aArray := {}
			//EndIf
			For _nx:=1 To Len(_aCols)
				If _nx <> _nPos
					//Aadd(_aArray, {_aCols[_nx,1], _aCols[_nx,2], _aCols[_nx,3], _aCols[_nx,4], _aCols[_nx,5], _aCols[_nx,6], _aCols[_nx,7], _aCols[_nx,8], _aCols[_nx,9], _aCols[_nx,10]})
					Aadd(_aArray, {_aCols[_nx,1], _aCols[_nx,2], _aCols[_nx,3], _aCols[_nx,4], _aCols[_nx,5], _aCols[_nx,6], _aCols[_nx,7], _aCols[_nx,8], _aCols[_nx,9], _aCols[_nx,10], _aCols[_nx,11], _aCols[_nx,12], _aCols[_nx,13], _aCols[_nx,14], _aCols[_nx,15], _aCols[_nx,16], _aCols[_nx,17],_aCols[_nx,18], _aCols[_nx,19],_aCols[_nx,20], _aCols[_nx,21], _aCols[_nx,22], _aCols[_nx,23]})
				EndIf
			Next
		EndIf
	Endif
	//MSUNLOCK()
	oCabec4:oBrowse:Setfocus()
	oCabec1:oBrowse:Refresh()
	oCabec2:oBrowse:Refresh()
	oCabec3:oBrowse:Refresh()
	oCabec4:oBrowse:Refresh()
	//filterT1()
	//filterT2()
	ATUTR9()
Return()

/*----------------------------------------------------------------------------*/
static function _montaTree(_lPrim)

	if _lPrim
		oTree:BeginUpdate()
		oTree:Reset()
		oTree:TreeSeek("NV1")
		oTree:AddItem("Nota Fiscal"+Space(50),"NVL10000000000000000","FOLDER5","FOLDER6",,,1)
		oTree:EndUpdate()
		oTree:Refresh()
	Else

		gerarTab()
		//oTree:ChangeBmp("BR_VERMELHO","BR_VERMELHO",,,oTree:GetCargo())
		_nX := 1
		oTree:BeginUpdate()
		oTree:Reset()
		DbSelectArea("TRB9")
		DbGoTop()
		Do While !TRB9->(eof())
			If !oTree:TreeSeek("NVL1"+Alltrim(TRB9->D2_DOC))
				oTree:AddItem("NFE: "+Alltrim(TRB9->D2_DOC)+" | Cad. Safe: "+Alltrim(TRB9->ZS4_CODSAF) ,"NVL1"+Alltrim(TRB9->D2_DOC),"FOLDER5","FOLDER6",,,1)
				If oTree:TreeSeek("NVL1"+Alltrim(TRB9->D2_DOC))
					oTree:AddItem("Cadastro Safe: "+TRB9->D2_CLIENTE,"NVL2"+Alltrim(TRB9->ZS4_CODSAF),"FOLDER2","FOLDER2",,,3)
				EndIf
			EndIf
			TRB9->(DbSkip())
		EndDo
		TRB9->(DbGoTop())
		oTree:EndUpdate()
		oTree:Refresh()
		oCabec5:oBrowse:Refresh()


		DbSelectArea("TRB9")
		DbGoTop()
		oFolder:SetOption(2)
		Obtn5:enable()
	Endif



return


static Function _mPopup(oTree,nX,nY,oMenu)

	Local cCargo := oTree:GetCargo()


	/*---------------------------------------------------------------
	Desabilita todos os itens do menu
	---------------------------------------------------------------*/
	AEval( oMenu:aItems, { |x| x:Disable() } )

	if (left(cCargo,4) $ 'NVL1')
		oMenu:aItems[2]:enable()
		oMenu:aItems[3]:enable()
		oMenu:aItems[5]:enable()
	Endif	
	
	if left(cCargo,4) $ 'NVL2'
		//oMenu:aItems[1]:enable()
		oMenu:aItems[1]:enable()
		//oMenu:aItems[3]:enable()
	Endif
	oMenu:aItems[4]:enable()
	oMenu:Activate( nX, nY, oTree )

Return

Static Function ValidPerg

Local cAlias := Alias()
Local aRegs := {}
Local i,j

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Cliente de        ","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"02","Cliente  ate      ","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"03","Data das vendas   ","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Data de Ent notas ","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Data ate Ent notas","","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Loja de           ","","","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"07","Loja ate          ","","","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})

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


static function delTab()

	TCSQLExec (" DELETE FROM " + RETSQLNAME("ZS4") )
	TCSQLExec (" DELETE FROM " + RETSQLNAME("ZS5") )
	TCSQLExec (" DELETE FROM " + RETSQLNAME("ZS6") )



return


static function gerarTab()

	local cCodSa  := ''
	local cPedido := '' 
	
	//preencher ZS4	f
	
	DbSelectArea("TRB9")
	DbGoTop()
	Do While !TRB9->(eof())	
		
		cPedido := TRB9->D2_PEDIDO 

		DbSelectArea("ZS4")
		DbSetOrder(2)
		DbSeek(FWFilial('ZS4') +  cPedido +"N" ,.f.)
		if !found()
			cCodSa  := GETSX8NUM("ZS4","ZS4_CODSAF")
			ConfirmSX8()
			RecLock("ZS4",.t.)
			ZS4_FILIAL  := FWFilial('ZS4')
			ZS4_CODSAF  := cCodSa
			ZS4_ENVIAD  := "N"
			ZS4_PEDIDO  := cPedido
			MsUnLock()	

			DbSelectArea("TRB9")
			RecLock("TRB9",.F.)
			TRB9->ZS4_CODSAF  := cCodSa
			MsUnLock()
			
		else
			cCodSa := ZS4->ZS4_CODSAF
			DbSelectArea("TRB9")
			RecLock("TRB9",.F.)
			TRB9->ZS4_CODSAF  := cCodSa
			MsUnLock()			
		endif	

		TRB9->(DbSkip())
		

	Enddo
	TRB9->(DBGoTop())
	oCabec5:oBrowse:Refresh(.t.)	

	//preencher ZS5
	DbSelectArea("TRB9")
	DbGoTop()
	Do While !TRB9->(eof())	

	   // DbSelectArea("ZS5")
		//DbSetOrder(2)
		//DbSeek(FWFilial('ZS5') +  TRB9->F1_CHVNFE ,.f.)

		lGrav := bZS5(TRB9->F1_CHVNFE,TRB9->ZS4_CODSAF)

		if lGrav
			RecLock("ZS5",.t.)
			
			cNomRed := Posicione("SA2",1,fwfilial("SA2") + TRB9->D1_FORNECE + TRB9->D1_LOJA,"A2_NREDUZ")
			CNomeC  := Posicione("SA2",1,fwfilial("SA2") + TRB9->D1_FORNECE  + TRB9->D1_LOJA,"A2_NOME")
			cEst    := Posicione("SA2",1,fwfilial("SA2") + TRB9->D1_FORNECE + TRB9->D1_LOJA,"A2_EST")
			cMun    := Posicione("SA2",1,fwfilial("SA2") + TRB9->D1_FORNECE + TRB9->D1_LOJA,"A2_MUN")
			cLat    := u_bGtoD(Alltrim(Posicione("SA2",1,fwfilial("SA2") + TRB9->D1_FORNECE + TRB9->D1_LOJA,"A2_LAT")))
			cLong   := u_bGtoD(Alltrim(Posicione("SA2",1,fwfilial("SA2") + TRB9->D1_FORNECE + TRB9->D1_LOJA,"A2_LON")))
			cNirf   := Posicione("SA2",1,fwfilial("SA2") + TRB9->D1_FORNECE + TRB9->D1_LOJA,"A2_NIRF")
			cIe     := Posicione("SA2",1,fwfilial("SA2") + TRB9->D1_FORNECE + TRB9->D1_LOJA,"A2_INSCR")
			cCAr    := Posicione("SA2",1,fwfilial("SA2") + TRB9->D1_FORNECE + TRB9->D1_LOJA,"A2_CAR")
			
			
			ZS5_FILIAL  := FWFilial('ZS5')
			ZS5_CODSAF  := TRB9->ZS4_CODSAF
			ZS5_FAZEND  := TRB9->D1_FORNECE
			ZS5_LOJFAZ  := TRB9->D1_LOJA
			ZS5_NOMRED  := cNomRed
			ZS5_NOMECO  := CNomeC
			ZS5_ESTADO  := cEst
			ZS5_MUNICI  := cMun
			ZS5_LATITU  := iif(alltrim(cLat) == '', '30.847758',cLat)	
			ZS5_LONGIT  := iif(alltrim(cLong) == '', '53.6137636',cLong)
			ZS5_NIRF    := iif(Alltrim(cNirf) == '', '0000012',cNirf)
			ZS5_IE      := cIe
			ZS5_CAR     := cCAr //iif(Empty(cCAr), '009876',cCAr) //VER
			ZS5_CHAVEN  := TRB9->F1_CHVNFE
			//ZS5_GTA     := '000001'// Right( "0000"+  FWInputBox("informe o numero GTA <5 posiÃ§Ãµes>") , 5)   //'988'
			//msgalert('Forneceodr '+ CNomeC)
			ZS5_GTA     :=  '000001' //Right( "0000"+  FWInputBox("GTA nao encontrado. Informe o mesmo (apenas numeros)>") , 6)
			ZS5_SERGTA  := 'Z'
			ZS5_GTAQUA  := 1
			ZS5_DTABAT  := TRB9->F1_EMISSAO
			ZS5_SEXO    := 'MACHO' // sze  
			ZS5_CODGORD := '000089'   // szk
			//ZS5_CODGORD :=  Right( "0000"+  FWInputBox("Cod gordura nao encontrado. Informe o mesmo (apenas numeros)>") , 6)
			ZS5_DTDESO  := TRB9->F1_EMISSAO + 1 //CTOD('16/12/2023') ver 
			ZS5_DOC     := TRB9->D1_DOC
		    ZS5_SERIE	:= TRB9->D1_SERIE
			MsUnLock()
		endif

		DbSelectArea("TRB9")
		TRB9->(DbSkip())
	Enddo


	//preencher ZS6
	DbSelectArea("TRB9")
	DbGoTop()
	Do While !TRB9->(eof())	
		RecLock("ZS6",.t.)
		ZS6_FILIAL  := FWFilial('ZS6')
		ZS6_CODSAF  := TRB9->ZS4_CODSAF
		ZS6_CHVEXP  := TRB9->F2_CHVNFE
		ZS6_CODBAR  := Posicione("SB1",1,fwfilial("SB1") + TRB9->D2_COD,"B1_CODBAR")
		ZS6_DESCPR  := Posicione("SB1",1,fwfilial("SB1") + TRB9->D2_COD,"B1_DESC")
		//ZS6_DTPROD  := CTOD('16/12/2023')  //sz8   pre carregamento zz3, pre pedido zz4 e itens do pre pedido zz5 pedido sc6/sc5
		//ZS6_DTVALI  := CTOD('16/12/2023')  //sz8
		ZS6_DTPROD  := dDatabase  - 3  //sz8   pre carregamento zz3, pre pedido zz4 e itens do pre pedido zz5 pedido sc6/sc5
		ZS6_DTVALI  := dDatabase  + 30//sz8


		ZS6_PESLIQ  := Alltrim(str(TRB9->D2_QUANT))  //QUANTIDADE DO ITEM
		ZS6_IDCAIX  := '001'  //sz8
		ZS6_IDPALE  := '002'  //sz8
		//ZS6_IDCAIX  := Right( "0000"+  FWInputBox("Id da Caixa nao encontrado. Informe o mesmo (apenas numeros)>") , 6)
		//ZS6_IDPALE  := Right( "0000"+  FWInputBox("Id do nao encontrado. Informe o mesmo (apenas numeros)>") , 6)
		
		ZS6_CNPJDE  := Posicione("SA1",1,fwfilial("SA1") + TRB9->D2_CLIENTE + TRB9->D2_LOJA,"A1_CGC")
		ZS6_DOC     := TRB9->D2_DOC
		ZS6_SERIE	:= TRB9->D2_SERIE	

		TRB9->(DbSkip())
	Enddo

	TRB9->(DBGoTop())
	oCabec5:oBrowse:Refresh(.t.)	

return(.t.)


user function bGtoD(cstring)
local cRet := ''
local cGrau,cMin,cSeg

if Alltrim(cstring) <> ''

	cGrau := left(cstring,2)
	cMin  :=  substring(cstring,at("'",cstring)-2,2)
	cSeg  := substring(cstring,at("'",cstring)+1,at('"',cstring)-at("'",cstring)-1)
	cRet := left(alltrim(str(val(cGrau) + (val(cMin)/60) + (val(cSeg)/360)))+'000',9)

endif


return (cRet)

static function _GeraSafe(cCodsafe,lMens,cCargo)
	aREt := {}

    oTree:ChangeBmp("AVG_IOPT","AVG_IOPT",,,cCargo)
	oTree:Refresh()
	
	DbSelectArea("ZS6")
	DbSetOrder(1)
	DbSeek(FWFilial('ZS6') +  cCodsafe ,.f.)

	DbSelectArea("ZS5")
	DbSetOrder(1)
	DbSeek(FWFilial('ZS5') +  cCodsafe ,.f.)

	DbSelectArea("ZS4")
	DbSetOrder(1)
	DbSeek(FWFilial('ZS4') +cCodsafe ,.f.)
	if found()


		IF ZS4->ZS4_ENVIAD == "N"
			aret:=u_SAFETRACE(lMens)
			if aret["status"] == 'success'
				RecLock("ZS4",.F.)
				ZS4->ZS4_ENVIAD  := "S"
				MsUnLock()
				oTree:ChangeBmp("SDUSETDEL_OCEAN","SDUSETDEL_OCEAN",,,cCargo)
			else
				oTree:ChangeBmp("UPDWARNING","UPDWARNING",,,cCargo)
			endif
			
		ENDIF
		
	endif
	
	
	oTree:Refresh()
	
return


static function _Gjson(cCodsafe)
	

return



User Function zMsgLfg(cMsg, cTitulo, nTipo, lEdit)
	Local lRetMens := .F.
	Local oDlgMens
	Local oBtnOk, cTxtConf := ""
	Local oBtnCnc, cTxtCancel := ""
	Local oBtnSlv
	Local oFntTxt := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
	Local oMsg
	Local nIni:=1
	Local nFim:=50
	Default cMsg    := "..."
	Default cTitulo := "zMsgLog"
	Default nTipo   := 1 // 1=Ok; 2= Confirmar e Cancelar
	Default lEdit   := .F.

	//Definindo os textos dos botÃµes
	If(nTipo == 1)
		cTxtConf:='&Ok'
	Else
		cTxtConf:='&Confirmar'
		cTxtCancel:='C&ancelar'
	EndIf
	//Criando a janela centralizada com os botÃµes
	//	DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL
	DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 500, 800 COLORS 0, 16777215 PIXEL
	//Get com o Log
	//@ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
	@ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 315, 240 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
	If !lEdit
		oMsg:lReadOnly := .T.
	EndIf

	//Se for Tipo 1, cria somente o botÃ£o OK
	If (nTipo==1)
		@ 001, 330 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL

		//SenÃ£o, cria os botÃµes OK e Cancelar
	ElseIf(nTipo==2)
		@ 001, 330 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
		@ 020, 330 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
	EndIf

	//BotÃ£o de Salvar em Txt
	@ 030, 330 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 051, 019 ACTION (u__dfSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
	ACTIVATE MSDIALOG oDlgMens CENTERED
Return lRetMens


/*-----------------------------------------------*
| FunÃ§Ã£o: fSalvArq                              |
| Descr.: FunÃ§Ã£o para gerar um arquivo texto    |
*-----------------------------------------------*/
Static Function _dfSalvArq(cMsg, cTitulo)
	Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
	Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
	Local lOk      := .T.
	Local cTexto   := ""

	//Pegando o caminho do arquivo
	cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
	//Se o nome nÃ£o estiver em branco
	If !Empty(cFileNom)
		//Teste de existÃƒÂªncia do diretÃ³rio
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("DiretÃ³rio nÃ£o existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		EndIf

		//Montando a mensagem
		cTexto := "Funcao   - "+ FunName()       + CRLF
		cTexto += "Usuario  - "+ cUserName       + CRLF
		cTexto += "Data     - "+ dToC(dDataBase) + CRLF
		cTexto += "Hora     - "+ Time()          + CRLF
		cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + cQuebra

		//Testando se o arquivo jÃ¡ existe
		If File(cFileNom)
			lOk := MsgYesNo("Arquivo jÃ¡ existe, deseja substituir?", "AtenÃ§Ã£o")
		EndIf

		If lOk
			MemoWrite(cFileNom, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"AtenÃ§Ã£o")
		EndIf
	EndIf
Return


static function  bZS5(cChav,cCodSaf)
	local cQueV := ""
	local lRet := .f.
	local nREG := 0

	cQueV := " SELECT * FROM  "+ RETSQLNAME("ZS5") +" WHERE ZS5_CHAVEN = '"+cChav+"' and ZS5_CODSAF = '"+cCodSaf+"'"

	cQueV:= ChangeQuery(cQueV)
	TCQUERY cQueV NEW ALIAS "TRBV"

	DBSelectArea("TRBV")
	DbGoTop()
	while !eof()
		nREG+=1
		DbSkip()
	enddo
			
	IF nREG == 0
		lRet := .t.		
	endif

	TRBV->(dbCloseArea())	

return lRet 


static function fEnviar()
	local lMs := .f.
	local aZS9 := {}

	if FWAlertNoYes("Deseja visualizar o conteudo a ser enviado ?", "Conteudo json")
		lMs := .t.
	endif
	
	DbSelectArea("TRB9")
	DbGoTop()
	Do While !TRB9->(eof())
		if nPos := aScan(aZS9, {|x| AllTrim(Upper(x)) == TRB9->ZS4_CODSAF}) == 0
			aAdd(aZS9, TRB9->ZS4_CODSAF)
			//oTree:ChangeBmp("AVG_IOPT","AVG_IOPT",,,"NVL1"+Alltrim(TRB9->D2_DOC))
			//oTree:Refresh()
			_GeraSafe(TRB9->ZS4_CODSAF,lMs,"NVL1"+Alltrim(TRB9->D2_DOC))
			//oTree:ChangeBmp("SDUSETDEL_OCEAN","SDUSETDEL_OCEAN",,,"NVL1"+Alltrim(TRB9->D2_DOC))
			//oTree:Refresh()
		endif
		DbSelectArea("TRB9")
		TRB9->(DbSkip())
	EndDo


return
