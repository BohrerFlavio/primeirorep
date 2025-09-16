#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF52     ºAutor  ³Giuliano Forgiarini º Data ³  15/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta de pré-carregamentos do dia                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaoms - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF52()

	lOk := .f.
	Private aCores    := {}
	Private aCores2   := {}
	Private cFilAux   := FWxfilial('SE1')
	Private _lSldFlag := .f.    //Para utilizaçao da função gjf28sld()
	Private aBrowse   := {}	     //Especifico para graxaria
	Private _nPesPal  := 0.00     //Peso dos Pallets, especifico Graxaria
	Private _lSalv    := .f.
	aObjects := {}                                            // dimensao janelas
	aPosObj  := {}
	aInfo    := {}

	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 :=  "ZZ3->ZZ3_STATUS == 'A'"
	bLegenda2 :=  "ZZ3->ZZ3_STATUS == 'C'"
	bLegenda3 :=  "ZZ3->ZZ3_STATUS == 'B'"
	bLegenda4 :=  "ZZ3->ZZ3_STATUS == 'E'"
	bLegenda5 :=  "ZZ3->ZZ3_STATUS == 'S'"
	bLegenda6 :=  "ZZ3->ZZ3_STATUS == 'F'"

	aCores2:= { {'BR_VERDE'   ,'Aberto'    },;
	{'BR_AMARELO' ,'Carregando'},;
	{'BR_AZUL'    ,'Bloqueado' },;
	{'BR_VERMELHO','Encerrado' },;
	{'BR_LARANJA' ,'Em Espera' } ,;
	{'BR_PRETO' ,'Faturado ' }}

	aCores := { {bLegenda1, 'BR_VERDE'   },;
	{bLegenda2, 'BR_AMARELO' },;
	{bLegenda3, 'BR_AZUL'    },;
	{bLegenda4, 'BR_VERMELHO'},;
	{bLegenda5, 'BR_LARANJA' },;
	{bLegenda6, 'BR_PRETO'   }}

	Private cCadastro := "Previsão de Gerenciamento de Pré-carregamentos e pré-pedidos"
	Private aRotina  := MenuDef()                             // Chamada da funcao menudef() que contem aRotina
	Private cCondicao := ''
	Private aIndZZ3   	:= {}						                                    //Indice para a filtragem
	Private cString := "ZZ3"
	Private cPerg   := "GJF52"

	if !pergunte(cPerg,.t.)
		return
	endif

	Processa( {|| Filtro(mv_par01,mv_par02)   },"Realizando filtragem de carregamentos..." )

	cCondicao := "(ZZ3_DTCAR >= '" + dtos(mv_par01) + "' AND ZZ3_DTCAR <= '" + dtos(mv_par02) + "')"+;
	" AND ZZ3_FILIAL = '" + FWxfilial('ZZ3') + "'"

	do case
		case mv_par03 = 1
		cCondicao += " AND ZZ3_BLQFIN = 'S' AND ZZ3_STATUS <> 'F'"
		case mv_par03 = 2
		cCondicao += " AND ZZ3_BLQFIN = 'N' AND ZZ3_STATUS <> 'F'"
	endcase

	dbSelectArea(cString)
	ZZ3->(dbSetOrder(1))
	ZZ3->(dbgobottom())

	mBrowse(6,1,22,75,cString, ,,,,2     ,aCores,,,,{|x| AutoRefresh(x)},,,,cCondicao)
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores

	If Select('ZZ3')<>0
		ZZ3->(dbCloseArea())
	Endif

	If Select('ZZ4')<>0
		ZZ4->(dbCloseArea())
	Endif

return

// Função para ativa opção de visualização da legenda
User Function gjf52lPC
	BrwLegenda('Pré-Carregamentos','Legenda',aCores2)
return

//PRE-PEDIDOS DO PRE-CARREGAMENTO SELECIONADO
User Function gjf52pp()

	area := getarea()
	lOk := .f.

	Private aRotina  := {}
	Private aCores3  := {}
	Private aCores4  := {}

	aObjects := {}
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 := "ZZ4->ZZ4_STATUS == 'B' .and. (ZZ4->ZZ4_SIBLQL = '2' .and. ZZ4->ZZ4_LIMCRE = 'L')"         // bloqueado
	bLegenda2 := "ZZ4->ZZ4_STATUS == 'C'"         // carregando
	bLegenda3 := "ZZ4->ZZ4_STATUS == 'L'"         // liberado
	bLegenda4 := "ZZ4->ZZ4_STATUS == 'E'"         // encerrado
	bLegenda5 := "ZZ4->ZZ4_STATUS == 'S'"         // em espera
	bLegenda6 := "ZZ4->ZZ4_STATUS == 'F'"         // Faturado
	bLegenda7 := "ZZ4->ZZ4_STATUS == 'B' .and. (ZZ4->ZZ4_SIBLQL = '1' .or. ZZ4->ZZ4_LIMCRE = 'B')"         // Bloq. Financeiro

	aCores4:= { {'BR_AZUL'   ,'Bloqueado'  },;
	{'BR_AMARELO' ,'Carregando'},;
	{'BR_VERDE'   ,'Liberado' },;
	{'BR_VERMELHO','Encerrado' },;
	{'BR_LARANJA' ,'Em Espera' } ,;
	{'BR_PRETO' ,'Faturado ' },;
	{'BR_CINZA' ,'Bloq.Financ. '}}

	aCores3 := {{bLegenda1, 'BR_AZUL'     },;     // bloqueado
	{bLegenda2, 'BR_AMARELO'  },;     // carregando
	{bLegenda3, 'BR_VERDE'    },;     // erado
	{bLegenda4, 'BR_VERMELHO' },;     // Encerrado
	{bLegenda5, 'BR_LARANJA'  },;     // Em Espera
	{bLegenda6, 'BR_PRETO'    },;     //Faturado
	{bLegenda7, 'BR_CINZA'    }}      // Faturado

	Private cCadastro := "Pré-Pedidos de Venda"
	Private aRotina := {{"Pesquisa",  "AxPesqui"  ,  0, 1},; 	//"Pesquisar"
	{"Visualizar", "u_gjf52U",0, 2},; 	//"Visualizar"
	{"Produtos",  "u_gjf52Visp", 0, 2},; 	//"Consultar"
	{"Legenda",    "u_gjf52L", 0, 1}}      //"Legenda"
	Private cString := 'ZZ4'
	Private cCondicao1 := "ZZ4_PRECAR = '"+ZZ3->ZZ3_NUM+"' AND ZZ4_FILIAL = '" + FWxfilial('ZZ4') + "'"
	Private cCondicao2 := "ZZ4->ZZ4_PRECAR = '"+ZZ3->ZZ3_NUM+"' .and. ZZ4->ZZ4_FILIAL = '" + FWxfilial('ZZ4') + "'"

	pergunte(cPerg,.f.)

	ProcFiltro(ZZ3->ZZ3_NUM,.t.)

	do case
		case mv_par03 = 1
		cCondicao1 += "	AND (ZZ4_SIBLQL = '1' OR ZZ4_LIMCRE = 'B')"
		cCondicao2 += " .and. (ZZ4->ZZ4_SIBLQL = '1' .or. ZZ4->ZZ4_LIMCRE = 'B')"
		case mv_par03 = 2
		cCondicao1 += " AND (ZZ4_SIBLQL = '2' AND ZZ4_LIMCRE = 'L')"
		cCondicao2 += " .and. (ZZ4->ZZ4_SIBLQL = '2' .and. ZZ4->ZZ4_LIMCRE = 'L')"
	endcase

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a Filtragem                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea(cString)
	ZZ4->(dbSetOrder(1))

	Set Key VK_F8 to u_gjf52f()

	mBrowse(6,1,22,75,cString, ,,,,1     ,aCores3,,,,{|x| AutoRefresh(x),u_gjf52f()},,,,cCondicao1)
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores

	DbSelectArea('ZZ4')

	//SET FILTER TO
	pergunte(cPerg,.f.)

	restarea(area)

return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MENUDEF  ³ Autor ³ Evandro Mugnol        ³ Data ³21/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Isola opcoes de menu para que as opcoes da rotina possam   ³±±
±±³          ³ ser lidas pelas bibliotecas framework da Versao 10         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ <Vide Parametros Formais>                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo as Rotinas a executar do programa      ³
	//³ ----------- Elementos contidos por dimensao ------------     ³
	//³ 1. Nome a aparecer no cabecalho                              ³
	//³ 2. Nome da Rotina associada                                  ³
	//³ 3. Usado pela rotina                                         ³
	//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	//³    2 - Simplesmente Mostra os Campos                         ³
	//³    3 - Inclui registros no Bancos de Dados                   ³
	//³    4 - Altera o registro corrente                            ³
	//³    5 - Remove o registro corrente do Banco de Dados          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aRotina := { {"Pesquisar"    , "AxPesqui"    , 0 , 1 , 0 , .F. } ,;
	{"Pre-Pedidos"  , "u_gjf52pp"   , 0 , 2 , 0 , NIL } ,;
	{"Produtos"     , "u_gjf31VC"   , 0 , 2 , 0 , NIL } ,;
	{"Historico"    , "u_gjf31vhi"  , 0,  2 , 0 , NIL } ,; 	//"Consultar"
	{"Legenda"      , "u_gjf52lPC"  , 0 , 2 , 0 , NIL } }

Return aRotina

Static Function AutoRefresh(oDlg)
	Local oTimer
	oTimer := TTimer():New(2, {|| PBrow() }, oDlg)
	oTimer:Activate()
Return .T.

Static Function PBrow()
	oBrowse := getObjBrow()
	oBrowse:default()
	oBrowse:refresh()
Return

User Function gjf52VisP()

	area := getarea()

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	cQuery := "SELECT ZZ5_COD AS COD,ZZ5_DESC AS DESCRI, SUM(ZZ5_QPCAIX) AS PCAIX, SUM(ZZ5_QRCAIX) AS RCAIX, "+;
	" SUM(ZZ5_QPPESO) AS PPESO, SUM(ZZ5_QRPESO) AS RPESO                                       "+;
	" FROM ZZ5010                                                                             "+;
	" WHERE ZZ5010.D_E_L_E_T_ <> '*' AND ZZ5_NUM = '" + ZZ4->ZZ4_NUM + "'                     "+;
	" AND ZZ5_FILIAL = '" + FWxfilial('ZZ5') + "'" +;
	" GROUP BY ZZ5_COD, ZZ5_DESC"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	aCampos := {}

	aadd(aCampos,{"COD"    ,"Codigo ",""                  })
	aadd(aCampos,{"DESCRI" ,"Descricao   ",""             })
	aadd(aCampos,{"PCAIX"  ,"Prev. Caixas","@E 9,999"     })
	aadd(aCampos,{"RCAIX"  ,"Real. Caixas","@E 9,999"     })
	aadd(aCampos,{"PPESO"  ,"Prev. Peso"  ,"@E 999,999.99"})
	aadd(aCampos,{"RPESO"  ,"Real. Peso"  ,"@E 999,999.99"})

	_nTotCaix  := 0
	_nTotPeca  := 0
	_nTotPCaix := 0
	_nTotPPeca := 0

	cQuery := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	dbSelectarea('QRY')

	_aArqTrb := {}
	aStru := dbStruct()                                                           //Pega a estrutura do QRY e atribui a um vetor

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	QRY->(dbgotop())

	SBM->(dbsetorder(1))

	while QRY->(!eof())
		reclock('TMP',.t.)
		TMP->COD    := QRY->COD
		TMP->DESCRI := QRY->DESCRI
		TMP->PCAIX  := QRY->PCAIX
		TMP->RCAIX  := QRY->RCAIX
		TMP->PPESO  := QRY->PPESO
		TMP->RPESO  := QRY->RPESO
		msunlock()
		QRY->(dbskip())

	enddo

	TMP->(dbgotop())

	while TMP->(!eof())

		if GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+TMP->COD) = 'CX'
			_nTotCaix  += TMP->RCAIX
			_nTotPCaix += TMP->RPESO
		endif

		if GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+TMP->COD,1) = 'PC'
			_nTotPeca  += TMP->RCAIX
			_nTotPPeca += TMP->RPESO
		endif

		TMP->(dbskip())
	enddo

	TMP->(dbgotop())

	DEFINE MSDIALOG oEnc TITLE 'Consulta por Itens do Pedido' from 00,00 to 240,835 OF oMainWnd PIXEL

	@ 005,005 To 90,420 Browse "TMP"  fields aCampos object oiBrowse
	@ 103,350  BUTTON 'Sair'        SIZE 40,15 ACTION oEnc:end() OBJECT oBtn
	@ 007,05 SAY 'Total Caixas: '+ Transform(_nTotCaix,'@E 999,999')
	@ 008,05 SAY 'Total Peças:  '+ Transform(_nTotPeca,'@E 999,999')
	@ 007,20 SAY 'Total Peso: ' + Transform(_nTotPCaix,'@E 999,999.99')
	@ 008,20 SAY 'Total Peso: ' + Transform(_nTotPPeca,'@E 999,999.99')

	ACTIVATE MSDIALOG oEnc

	If Select("TMP")<>0
		TMP->(dbCloseArea())
	Endif

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	restarea(area)

return

User Function gjf52L(cAlias,nReg,nOpc)
	BrwLegenda(cCadastro,"Legenda",aCores4)
Return

//Visualiza Pré-Pedidos de Venda
User Function gjf52U(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	//Local aButtons	:= {{"POSCLI",{|| a450F4Con()},'Situação do Cliente','Posicao'}}
	//Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	Local aButtons	:= {{"POSCLI",{|| u_gjf28con()},'Situação do Cliente','Posicao'}}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private _dDtPes	:= ZZ4->ZZ4_DATA
	Private _lOk      := .f.
	aBrowse := {}
	area := GetArea()

	//bloco para gerar vetor para o TCBROWSE
	//da vinculação das pesagens

	_cPlaca := GetAdvFVal('ZZ3','ZZ3_PLACA',FWxfilial('ZZ3')+ZZ4->ZZ4_PRECAR,2)

	SZT->(DbSetOrder(4))
	if SZT->(MsSeek(FWxfilial('SZT') + dtos(_dDtPes)))
		while SZT->(!eof()) .and. SZT->ZT_FILIAL = FWxfilial('SZT') .and. SZT->ZT_DATAS = _dDtPes
			If SZT->ZT_STATUS = 'PA'
				SZT->(DbSkip())
				loop
			endif

			If SZT->ZT_TRANSF = 'S'
				SZT->(DbSkip())
				loop
			endif

			if  _cPlaca <> SZT->ZT_PLACA
				SZT->(DbSkip())
				loop
			endif

			aadd(aBrowse,{RetCores(),;
			SZT->ZT_COD,;
			SZT->ZT_PLACA,;
			SZT->ZT_DATAE,;
			SZT->ZT_HORAE,;
			SZT->ZT_PESOE,;
			SZT->ZT_DATAS,;
			SZT->ZT_HORAS,;
			SZT->ZT_PESOS,;
			SZT->ZT_PREPED,;
			SZT->ZT_ITEM})

			SZT->(DbSkip())
		enddo
	endif

	//fim do bloco para gerar vetor para o TCBROWSE

	AADD(aButtons, {"AUTOM" ,{|| u_gjf28lCl()},'Liberar cliente financeiro'  ,'Liberar' } )
	AADD(aButtons, {"PRODUTO"  ,{|| u_gjf52pes()},'Vinc. Pesagem'  ,'Pesagem' } )
	//Clailton solicitou a exclusão de itens do menu "Outras ações" para usuários do setor Financeiro (06/02/23)
	if !(AllTrim(RetCodUsr()) $ "000001/000230/000307/000347/000567")
		AADD(aButtons, {"EDIT"  ,{|| u_GJF173(M->ZZ4_CODCLI,M->ZZ4_LOJA,2)} ,'Informações do Sefaz' ,'Sefaz'} )
		AADD(aButtons, {"FORM"  ,{|| u_gjf28sld() , oDlg:Refresh() },'Consulta saldo de produtos'   , 'Saldo'  } )
		AADD(aButtons, {"BMPORD",{|| u_GJF108()},'Consulta Caixas','Caixas'} )
	endif
	AADD(aButtons, {"EDIT"  ,{|| u_gjf28cad()} ,'Informações do Cadastro' ,'Cadastro'} )
	AADD(aButtons, {"BUDGET",{|| u_GJF85C() , oDlg:Refresh() },'Consulta Credito'   , 'Credito'  } )
	AADD(aButtons, {"EDIT"  ,{|| u_gjf52orc()},'Orçamento','Orcamento'} )

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZ4")

	gjf52Ahead("ZZ5")                                                           //Monta oa vetor aHeader

	nUsado := Len(aHeader)

	gjf52Acols(nOpc)															//Monta oa vetor aCols

	DbSelectArea('SA1')
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(FWxfilial('SA1')+M->(ZZ4_CODCLI+ZZ4_LOJA)))

	oEnc    := MsMGet():New("ZZ4" ,ZZ4->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZZ5_ITEM",.T.)

	oGetDad:oBrowse:bChange    := {|| u_gjf28clc() }             //Realiza todos os calculos ao mudar de linha
	oGetDad:oBrowse:bLostFocus := {|| u_gjf28clc() }             //Realiza todos os calculos ao perder o foco da linha

	u_gjf28ke('V','A')

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||_lOk := .T.,oDlg:End()}, {||oDlg:End()}, , aButtons)
	if _lOk
		u_gjf52lok()
	endif

	DbSelectArea('ZZ4')
	DbSelectArea('ZZ3')
	RestArea(area)

	u_gjf28ke('V','D')

	reclock('ZZ3',.f.)
	if ProcFiltro(ZZ3->ZZ3_NUM,.t.)
		ZZ3->ZZ3_BLQFIN := 'S'
	else
		ZZ3->ZZ3_BLQFIN := 'N'
	endif
	msunlock()

Return

// Função utilizada para mostrar informações do pedido de forma resumida
// Pedido do Rodrigo para envio de PrintScreens
User Function gjf52orc()
	Local aIPPed := {}
	Local _cCodCli  	:= ZZ4->ZZ4_CODCLI
	Local _cNomeCli 	:= ZZ4->ZZ4_NOME
	Local _cLoja     	:= ZZ4->ZZ4_LOJA
	Local _nTotal     	:= 0.0
	Local _cFiltro		:= ""

	_cFiltro := "ZZ5_NUM = '" + ZZ4->ZZ4_NUM + "'"
	ZZ5->(DbSetOrder(1))
	ZZ5->(DbSetFilter({||&_cFiltro}, _cFiltro))
	ZZ5->(dbGoTop())
	while (ZZ5->(!EOF()))
		Aadd(aIPPed, {ZZ5->ZZ5_COD, ZZ5->ZZ5_DESC, transform(ZZ5->ZZ5_QPCAIX, '@E 999,999'), transform(ZZ5->ZZ5_QPPESO, '@E 999,999.99') + " kg", "R$ " + transform(ZZ5->ZZ5_PRCFIN, '@E 999,999.99')})
		_nTotal += (ZZ5->ZZ5_QPPESO * ZZ5->ZZ5_PRCFIN)
		ZZ5->(dbSkip())
	end

	if empty(aIPPed) .or. Len(aIPPed) = 0
		Aadd(aIPPed, {"------", " ", "0", "0,0" + " kg", "R$ " + "0,00"})
	endif

	@ 116,010 To 425,425 Dialog oDlgO Title "Orçamento"

	@ 01,01 SAY 'CLIENTE: ' + _cNomeCli
	@ 02,01 SAY 'CÓD. CLI.: ' + _cCodCli + ' -  LOJA: ' + _cLoja
	@ 09,01 SAY 'TOTAL PEDIDO: R$ ' + transform(_nTotal, '@E 999,999,999.99')

	oBrowse2 := TWBrowse():New(41, 01, 210, 60,,{'CODIGO','DESCRIÇÃO', 'QPCAIX  ', 'QPPESO ', 'PRCFIN '},{10,30,15,15,15},oDlgO,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowse2:SetArray(aIPPed)
	oBrowse2:bLine := {||{aIPPed[oBrowse2:nAt,01],aIPPed[oBrowse2:nAt,02],aIPPed[oBrowse2:nAt,03],aIPPed[oBrowse2:nAt,04],aIPPed[oBrowse2:nAt,05]}} 

	@ 131,90 BMPBUTTON TYPE 2 ACTION oDlgO:end() Object Obtn2
	Activate Dialog oDlgO CENTERED

Return

//Função utilizada para vincular peso de carga ao pré-pedido
//Específico para Graxaria
User Function gjf52pes()

	Local ret   := .t.
	Local aList := {}
	//Cabeçalhos das colunas
	Local aHeader  := {  '' ,'Codigo','Placa','Dt.Entr.','Hr.Entr.','Ps.Entr.','Dt.Saida','Hr.Saida','Ps.Saida','Pre-Ped.','Item'}
	//Largura das colunas
	Local aLargCol := { 20,  20   ,   20  ,   30     ,  30      ,  30      ,  30      ,   30       ,  30       ,    30    , 20  }
	// Vetor com elementos do Browse
	Local _cCodSebo := getmv('SI_CODSEBO')

	if (cEmpAnt <> '08') .and. (cEmpAnt = '01' .and. !(alltrim(GDFieldGet('ZZ5_COD',n)) $ alltrim(_cCodSebo)))
		msgbox('Operação exclusiva para empresa 08 ou Código do produto não previsto!','OPERAÇÃO INVÁLIDA','STOP')
		return
	endif

	if (ZZ4->ZZ4_STATUS <> 'L')
		alert("Status do Pre-Pedido ou do Pre-Carregamento não permite operação!")
		return
	endif

	if len(aBrowse) <> 0
		DEFINE MSDIALOG oCar TITLE "Pesagens de Caminhões" FROM 20,20 To 300,570 PIXEL  //300,530

		// Cria Browse
		oBrowse := TCBrowse():New(05,05,250,100,,aHeader,aLargCol,oCar,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

		@ 115,180 BUTTON botao1 PROMPT "Fechar" OF oCar PIXEL ACTION oCar: end()
		@ 115,55 MSGET  campo1 VAR _nPesPal SIZE 40,10 OF oCar PIXEL PICTURE "@E 999,999.99"
		@ 09,01 SAY "Peso dos Pallets:" of oCar
		// Seta vetor para a browse
		oBrowse:SetArray(aBrowse)

		// Monta a linha a ser exibina no Browse

		oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],;
		aBrowse[oBrowse:nAt,02],;
		aBrowse[oBrowse:nAt,03],;
		aBrowse[oBrowse:nAT,04],;
		aBrowse[oBrowse:nAT,05],;
		transform(aBrowse[oBrowse:nAT,06],'@E 999,999.99'),;
		aBrowse[oBrowse:nAT,07],;
		aBrowse[oBrowse:nAT,08],;
		transform(aBrowse[oBrowse:nAT,09],'@E 999,999.99'),;
		aBrowse[oBrowse:nAT,10],;
		aBrowse[oBrowse:nAT,11]}}

		// Evento de clique no cabeçalho da browse
		//	oBrowse:bHeaderClick := {|| alert('bHeaderClick') }

		// Evento de duplo click na celula
		oBrowse:bLDblClick   := {|| VinCar() }

		//	campo1:bLostFocus := {|| alert(len(aCols)) }
		ACTIVATE MSDIALOG oCar CENTERED

	endif

return ret

//Rotina para vincular a carga ao item do pre-carregamento
Static Function VinCar()

	_cCod := GDFieldGet('ZZ5_COD',n)

	ZZ5->(DbGoTop())
	ZZ5->(DbSetOrder(2))
	if ZZ5->(MsSeek(FWxfilial('ZZ5') + ZZ4->ZZ4_NUM + _cCod))

		SZT->(DbSetOrder(5))
		if SZT->(MsSeek(FWxfilial('SZT') + ZZ4->ZZ4_NUM + ZZ5->ZZ5_ITEM))
			alert('Pesagem já vinculada no Pre-Pedido ' + ZZ4->ZZ4_NUM + '.')
			return
		endif

		if !empty(ZZ5->ZZ5_PESAGE)
			alert('Produto com pesagem já vinculada!')
			return
		endif

		if ZZ5->ZZ5_QRPESO <> 0
			alert('Produto com carregamento iniciado!')
			return
		endif

		_nPos := aScan(aBrowse,{|aVal| aVal[10] = ZZ5->ZZ5_NUM .and. aVal[11] = ZZ5->ZZ5_ITEM })

		if _nPos = 0
			aBrowse[oBrowse:nAT,01]  :=  LoadBitmap(GetResources(),'br_vermelho')
			aBrowse[oBrowse:nAT,10]  :=  ZZ5->ZZ5_NUM
			aBrowse[oBrowse:nAT,11]  :=  ZZ5->ZZ5_ITEM
		else
			alert('Pesagem já vinculada!')
		endif
	endif

	//oCar:end()

	oBrowse:DrawSelect()
return

//Função que retorna a confirmação da vinculação
User Function gjf52lOk()

	Local _cCodSebo := getmv('SI_CODSEBO')

	//if (cEmpAnt <> '08') .and. (cEmpAnt = '01' .and. !(alltrim(GDFieldGet('ZZ5_COD',n)) $ alltrim(_cCodSebo)))

	//if cEmpAnt = '08'

	ZZ5->(dbsetorder(1))
	ZZ5->(Msseek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
	if (cEmpAnt = '08') .or. (cEmpAnt = '01' .and. (alltrim(ZZ5->ZZ5_COD) $ alltrim(_cCodSebo)))
		while ZZ5->(!eof()) .and. ZZ5->ZZ5_NUM == ZZ4->ZZ4_NUM .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5')

			_nPos := aScan(aBrowse,{|aVal|aVal[10] = ZZ4->ZZ4_NUM .and. aVal[11] = ZZ5->ZZ5_ITEM})

			if _nPos <> 0

				_cCarga := alltrim(aBrowse[_nPos,02])
				_nPesoL := aBrowse[_nPos,09] - aBrowse[_nPos,06]
				_nCaix  := 0
				_nFatC  := 0

				DbSelectArea('SB1')
				_nFatC := GetAdvFVal('SB1','B1_CONV',FWxfilial('SB1') + ZZ5->ZZ5_COD,1)

				if _nFatC <> 0
					_nCaix := round(_nPesoL/_nFatC,0)
				else
					_nCaix := 1
				endif

				reclock('ZZ5',.f.)
				ZZ5->ZZ5_PESAGE := _cCarga
				ZZ5->ZZ5_QRPESO := _nPesoL - _nPesPal
				ZZ5->ZZ5_QRPESB := _nPesoL
				ZZ5->ZZ5_QRCAIX := _nCaix
				ZZ5->ZZ5_STATUS := 'E'
				msunlock()

				SZT->(DbSetOrder(3))
				if SZT->(MsSeek(FWxfilial('SZT')+_cCarga))
					reclock('SZT',.f.)
					SZT->ZT_PREPED  := ZZ5->ZZ5_NUM
					SZT->ZT_ITEM    := ZZ5->ZZ5_ITEM
					msunlock()
				endif
			else
				msgbox('Existem itens do pre-pedido sem vinculação com carga!','OPERAÇÃO INCONSISTENTE!','STOP')
				return .f.
			endif

			ZZ5->(dbskip())
		enddo

		reclock('ZZ4',.f.)
		ZZ4->ZZ4_STATUS := 'E'

		msunlock()

		_lEnc := .t.
		ZZ4->(DbSetOrder(1))
		if ZZ4->(Msseek(FWxfilial()+ZZ3->ZZ3_NUM))
			while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4') .and. ZZ4->ZZ4_PRECAR = ZZ3->ZZ3_NUM
				if ZZ4->ZZ4_STATUS <> 'E'
					_lEnc := .f.
					exit
				endif

				ZZ4->(DbSkip())
			enddo
		endif

		if _lEnc
			reclock('ZZ3',.f.)
			ZZ3->ZZ3_STATUS := 'E'
			msunlock()
			u_devSeparacao(ZZ3->ZZ3_NUM)
		endif
	endif

Return .t.

//Montagem do aCols
static Function gjf52Acols(nOpc)
	Local nI, nPos
	If nOpc == 3

		aCols := Array(1,nUsado+1)

		For nI = 1 To Len(aHeader)
			If aHeader[nI,8] == "C"
				aCols[1,nI] := Space(aHeader[nI,4])
			ElseIf aHeader[nI,8] == "N"
				aCols[1,nI] := 0
			ElseIf aHeader[nI,8] == "D"
				aCols[1,nI] := CtoD(" / / ")
			ElseIf aHeader[nI,8] == "M"
				aCols[1,nI] := ""
			Else
				aCols[1,nI] := .F.
			EndIf
		Next nI

		nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZZ5_ITEM" })
		if nPos > 0
			aCols[1,nPos]	:= StrZero(len(acols)+1,Len(aCols[1,nPos]))
		endif
		aCols[1,nUsado+1] := .F.
	Else

		RegToMemory("ZZ4")

		dbSelectArea("ZZ5")
		dbSetOrder(1)
		MsSeek(FWxFilial('ZZ5')+ZZ4->ZZ4_NUM,.T.)

		Do While ZZ5->(!Eof()) .and. FWxFilial('ZZ5') ==  ZZ5->ZZ5_FILIAL .and. ZZ5->ZZ5_NUM == ZZ4->ZZ4_NUM
			aAdd(aCols,Array(nUsado+1))

			For nI := 1 to nUsado
				If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Else										// Campo Virtual
					cCpo := AllTrim(Upper(aHeader[nI,2]))
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Endif
			Next nI

			aCols[Len(aCols),nUsado+1] := .F.

			ZZ5->(DbSkip())
		Enddo

	Endif

Return

//Monta oa aHeader
Static Function gjf52Ahead(cAlias)

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//MsSeek(cAlias)
	//Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	//	If 	at(Upper(AllTrim(X3_CAMPO)), "ZZ5_FILIAL ZZ5_NUM") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := cAlias 			// ZZ5
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 			 	 .And. ;
			AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZZ5_FILIAL" .And. ;
			AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZZ5_NUM")

			aAdd(aHeader, { GetSx3Cache(_aCpoSX3[i], 'X3_TITULO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_PICTURE')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_TAMANHO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_DECIMAL')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_VALID')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_USADO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_TIPO')		,;
							GetSx3Cache(_aCpoSX3[i], 'X3_ARQUIVO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_CONTEXT')	})
		Endif
	Next i

Return len(aHeader)

//Função para gerar flag de liberação/bloqueio financeiro em pre-carregamentos
//apenas para filtragem no financeiro
Static Function Filtro(_dataIni,_dataFim)
	//Local _lRet := .f.
	ZZ3->(DbGoTop())
	ZZ3->(DbSetOrder(1))
	ZZ3->(MsSeek(FWxfilial('ZZ3')+dtos(_dataIni),.t.))
	While ZZ3->(!eof()) .and. ZZ3->ZZ3_FILIAL = FWxfilial('ZZ3') .and. ZZ3->ZZ3_DTCAR <= _dataFim

		if ZZ3->ZZ3_STATUS $ 'E/F'
			ZZ3->(DbSkip())
			loop
		endif

		if ProcFiltro(ZZ3->ZZ3_NUM,.f.)
			_cBloq := 'S'
		else
			_cBloq := 'N'
		endif

		reclock('ZZ3',.f.)
		ZZ3->ZZ3_BLQFIN := _cBloq
		msunlock()

		ZZ3->(DbSkip())
	enddo
Return

Static Function ProcFiltro(precar,flag)
	Local _lRet := .f.
	Local _Bloq := ''

	dbselectarea('ZZ4')
	ZZ4->(dbsetorder(1))
	ZZ4->(dbgotop())
	ZZ4->(Msseek(FWxfilial('ZZ4')+precar))
	while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4') .and. ZZ4->ZZ4_PRECAR = precar

		if ZZ4->ZZ4_SIBLQL = '1'
			_lRet := .t.
		endif

		_Bloq := GetAdvFVal('SA1','A1_MSBLQL',FWxfilial('SA1')+ZZ4->(ZZ4_CODCLI+ZZ4_LOJA),1)

		if _Bloq = '1'
			if flag
				reclock('ZZ4',.f.)
				ZZ4->ZZ4_SIBLQL := '1'
				msunlock()
			endif
			_lRet := .t.
		endif

		ZZ4->(DbSkip())
	enddo

return _lRet

//Função auxiliar para retorno das cores da legenda
Static Function RetCores()
	local ret   := iif(empty(SZT->ZT_ITEM), LoadBitmap(GetResources(),'br_verde'),LoadBitmap(GetResources(),'br_vermelho'))
return  ret

User Function gjf52f()
	oBrowse := getObjBrow()
	oBrowse:SetFilterDefault(cCondicao2)
	//oBrowse:AddFilter( 'Teste', '!empty(ZZ4->ZZ4_NUM) ')
	//oBrowse:ExecuteFilter()
return
