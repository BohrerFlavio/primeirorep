#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "totvs.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgr³GJF31     ºAutor  ³Giuliano Forgiarini º Data ³  08/04/08        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de carregamento e expedição                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF31()

	lOk := .f.
	//Private aRotina  := {}
	Private aCores   := {}
	Private aCores2  := {}
	Private nTara    := 0.00
	Private _cTipo   := ''
	Private _lBal    := .f.
	Private oObj
	Private nResp    := 0
	Private _cMemo   := ""
	Private _cIpBal  := ""
	Private nTarRol  := getMV("SI_TARAROL")
	Private nTarGan  := getMV("SI_TARAGAN")
	Private cCDec1   := alltrim(getMV("SI_CDPEST1"))
	Private cCDec2   := alltrim(getMV("SI_CDPEST2"))
	Private _aOpSeq	 := {"Padrão","Bizerba"}
	Private _nModSeq := 1
	Private cExecWeb    := 'sndrec32.exe'    
    Private cTmpPath    := GetTempPath(.T.,.F.)
    Private cTempPath   := STrTran(cTmpPath,'Temp','Programs\web-agent')

	bLegenda1 :=  "ZZ3->ZZ3_STATUS == 'A'"
	bLegenda2 :=  "ZZ3->ZZ3_STATUS == 'C'"
	bLegenda3 :=  "ZZ3->ZZ3_STATUS == 'B'"
	bLegenda4 :=  "ZZ3->ZZ3_STATUS == 'E'"
	bLegenda5 :=  "ZZ3->ZZ3_STATUS == 'S'"
	bLegenda6 :=  "ZZ3->ZZ3_STATUS == 'F'"
	bLegenda0 :=  "lCong = .T. .and. !(ZZ3->ZZ3_STATUS $ 'E/F')"

	aCores2:= { { 'BR_VERDE'   ,'Aberto'    },;
	{ 'BR_AMARELO' ,'Carregando'},;
	{ 'BR_AZUL'    ,'Bloqueado' },;
	{ 'BR_VERMELHO','Encerrado' },;
	{ 'BR_LARANJA' ,'Em Espera' },;
	{ 'BR_PRETO'   ,'Faturado'  }}

	aCores :=  {{ bLegenda1, 'BR_VERDE'     },;
	{ bLegenda2, 'BR_AMARELO'   },;
	{ bLegenda3, 'BR_AZUL'      },;
	{ bLegenda4, 'BR_VERMELHO'  },;
	{ bLegenda5, 'BR_LARANJA'   },;
	{ bLegenda6, 'BR_PRETO'     },;
	{ bLegenda0, 'BR_BRANCO'     }}

	Private cPerg   := "GJF31"
	Private cCadastro := "Carregamentos"
	Private aRotina := { {"Pesquisar"  ,"AxPesqui"   ,0,1} ,;
	{"Visualizar" ,"u_gjf31VC"  ,0,2} ,;
	{"Pre-Pedidos","u_gjf31p"   ,0,2} ,;
	{"Encerrar"   ,"u_gjf31enc" ,0,4} ,;
	{"Historico"  ,"u_gjf31vhi" ,0,4} ,;
	{"Obs. Final" ,"u_gjf31obs" ,0,4} ,;
	{"Legenda"    ,"u_gjf31leg" ,0,2}}

	cCondicao := ''

	if !pergunte(cPerg,.t.)
		return
	endif

	SetKey(115,{|| CapT()})
	SetKey(114,{|| gjf31T()})

	Private cString := "ZZ3"
	dbSelectArea(cString)
	ZZ3->(dbSetOrder(1))
	ZZ3->(dbgobottom())

	if mv_par01 = 1
		cCondicao := "(ZZ3_DTCAR = '" + dtos(ddatabase) + "' OR ZZ3_DTCAR = '" + dtos(ddatabase - 1) + "')"+;
		" AND ZZ3_STATUS <> 'B' AND ZZ3_FILIAL = '" + FWxfilial('ZZ3') + "'"
	else
		cCondicao := "(ZZ3_DTCAR = '" + dtos(ddatabase) + "' OR ZZ3_DTCAR = '" + dtos(ddatabase - 1) + "')"+;
		" AND ZZ3_STATUS NOT IN('B','E','F') "+;
		" AND ZZ3_FILIAL = '" + FWxfilial('ZZ3') + "'"
	endif

	mBrowse(6,1,22,75,cString, ,,,,1     ,aCores,,,,{|x| AutoRefresh(x)},,,,cCondicao)
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores

	DbCloseArea()

	Set Key 115 to
	Set Key 114 to

	If Select("SZ8")<>0
		SZ8->(dbCloseArea())
	Endif
	If Select("ZZ2")<>0
		ZZ2->(dbCloseArea())
	Endif
	If Select("ZZ4")<>0
		ZZ4->(dbCloseArea())
	Endif
	If Select("ZZ5")<>0
		ZZ5->(dbCloseArea())
	Endif

Return

//Função para verificar se o Protheus usa o WebAgent
FUNCTION u_remoteType()
  Local cLib
  Local cRmtType := GetRemoteType(@cLib)
  conout("Tipo do remote: " + cValToChar(cRmtType)) // -> Ex: 1=Windows | 2=Linux/MacOS
  conout("Info adicional: " + cLib)                 // -> Exemplo ao utilizar o WebApp: "HTML-9.1.6 LINUX"

  cRet := cLib
RETURN cRet

//Função para encerrar o pré-carregamento
User Function gjf31enc()

	local _nRetChk := 0

	if ZZ3->ZZ3_STATUS = 'E' .or. ZZ3->ZZ3_STATUS = 'C' .or. ZZ3->ZZ3_STATUS = 'F'
		msgbox('Status não permite encerramento!','OPERACAO NEGADA','STOP')
		return
	endif

	ZZ4->(dbsetorder(1))
	if ZZ4->(Msseek(FWxfilial()+ZZ3->ZZ3_NUM))
		while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4') .and. ZZ4->ZZ4_PRECAR = ZZ3->ZZ3_NUM
			if ZZ4->ZZ4_STATUS != 'E' .and. ZZ4->ZZ4_STATUS != 'F'
				msgbox('Existem pré-pedidos ainda não encerrados!','OPERACAO NEGADA','STOP')
				return
			endif
			ZZ4->(dbskip())
		enddo
	endif
	u_gjf31his('Acesso Encerramento de Pre-Carregamento')
	ZZ4->(dbsetorder(1))
	if ZZ4->(Msseek(FWxfilial()+ZZ3->ZZ3_NUM))
		while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4') .and. ZZ4->ZZ4_PRECAR = ZZ3->ZZ3_NUM
			_lFal := .f.
			ZZ5->(dbsetorder(1))
			ZZ5->(Msseek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
			While ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM
				if ZZ5->ZZ5_STATUS != 'E'
					_lFal := .t.
				endif
				ZZ5->(dbskip())
			enddo

			if _lFal
				if !('HTML' $ u_remoteType())
					WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
				else
					WINEXEC(cTempPath + cExecWeb + ' /play /close /embedding ' + cTempPath + 'GEER.WAV',0)
				endif

				msgbox('Pedido ' + alltrim(ZZ4->ZZ4_NUM) + ' encerrado com falta!','ATENÇÃO','INFO')
				//Função de workflow
				u_gjf31wfw(ZZ4->ZZ4_NUM,ZZ4->ZZ4_CODCLI,ZZ4->ZZ4_LOJA,ZZ4->ZZ4_PRECAR,'')				
			endif

			//u_gjf28aj(ZZ4->ZZ4_NUM) //Ajustar o sequencial de itens do pre-pedido

			ZZ4->(dbskip())
		enddo
	endif

	if cFilAnt = '00'
		_nRetChk := u_VerPreCar(ZZ3->ZZ3_NUM)
		if _nRetChk = 1
			if !('HTML' $ u_remoteType())
				WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
			else
				WINEXEC(cTempPath + cExecWeb + ' /play /close /embedding ' + cTempPath + 'GEER.WAV',0)
			endif

			FWAlertWarning('Carregamento possui caixas carregadas incorretamente, verifique no relatório e corrija!','OPERAÇÃO NEGADA!')
			SetMVValue("DTI182", "MV_PAR01", ZZ3->ZZ3_NUM, .T.)
			u_DTI182()
			return
		elseif _nRetChk = 2
			if !('HTML' $ u_remoteType())
				WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
			else
				WINEXEC(cTempPath + cExecWeb + ' /play /close /embedding ' + cTempPath + 'GEER.WAV',0)
			endif

			FWAlertWarning('Carregamento não foi totalmente validado, realize a validação pelo coletor de todas as caixas!','OPERAÇÃO NEGADA!')
			return
		endif
	endif

	if msgbox('Esta operação encerrará o Pré-carregamento! Confirma?','ATENÇÃO!','YESNO')
		reclock('ZZ3',.f.)
		ZZ3->ZZ3_STATUS := 'E'
		ZZ3->ZZ3_DTFIM  := dDataBase
		ZZ3->ZZ3_HFIM   := time()
		ZZ3->ZZ3_USUFIM := cUserName
		msunlock()
		msgbox('Pré-carregamento encerrado!','ENCERRAMENTO','INFO')
		if _lFal
			u_gjf31his('Encerramento de Pre-Carregamento com faltas')
		else
			u_gjf31his('Encerramento de Pre-Carregamento')
		endif

		//Bloco destinado a limpeza das caixas separadas para carregamento e gravacao das mesmas no historico
		u_devSeparacao(ZZ3->ZZ3_NUM)
	endif

	u_gjf31obs()

return

User Function devSeparacao(_preCarreg)

	if cEmpAnt == '01'
		_cQuery := " SELECT Z8_CONTROL
		_cQuery += " FROM " + retSqlTab("SZ8")
		_cQuery += " WHERE " + retSqlFil("SZ8") + " AND Z8_FIL = '" + cFilAnt + "'"
		_cQuery += " AND Z8_DATAS = '' AND Z8_CARPICK = '" + _preCarreg + "'"
		_cQuery += " AND " + retSqlDel("SZ8")
		_cQuery += " ORDER BY Z8_CONTROL

		_cQuery  := ChangeQuery(_cQuery)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		If Select("QRY") != 0
			QRY->(dbCloseArea())
		Endif

		TCQUERY _cQuery NEW ALIAS "QRY"

		QRY->(dbGoTOp())
		while QRY->(!eof())

			SZ8->(dbGoTop())
			SZ8->(dbSetOrder(3))
			if SZ8->(MsSeek(FWxFilial("SZ8") + alltrim(QRY->Z8_CONTROL)))
				if empty(SZ8->Z8_DATAS)
					reclock('SZ8',.f.)
					SZ8->Z8_PICKING := ''
					SZ8->Z8_CARPICK := ''
					msunlock()
					//alert('caixa: ' + SZ8->Z8_CONTROL)
					u_gjf17his(4,'CX SEPARADA E NAO CARREGADA: ' + _preCarreg,.f.,'','','000001',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
				endif
			endif
			QRY->(dbSkip())
		enddo
	endif

return

// Mostra a legenda quando solicitada
User Function gjf31leg()
	BrwLegenda('Carregamentos','Legenda',aCores2)
return

//Rotina que chama os pré-pedidos a serem carregados
User Function gjf31pp()
	area := getarea()
	lOk := .f.
	Private aRotina  := {}
	Private aCores   := {}
	Private aCores2  := {}
	Private aIndZZ4   := {}						           //Indice para a filtragem
	aObjects := {}                                         //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 := "ZZ4->ZZ4_STATUS == 'B'"          //bloqueado
	bLegenda2 := "ZZ4->ZZ4_STATUS == 'C'"          //carregando
	bLegenda3 := "ZZ4->ZZ4_STATUS == 'L'"          //liberado
	bLegenda4 := "ZZ4->ZZ4_STATUS == 'E'"          //encerrado
	bLegenda5 := "ZZ4->ZZ4_STATUS == 'S'"          //em espera
	bLegenda6 := "ZZ4->ZZ4_STATUS == 'F'"          //faturado
	bLegenda0 := "lCong = .T. .and. !(ZZ4->ZZ4_STATUS $ 'E/F')"

	aCores := { {bLegenda1, 'BR_AZUL'},;           // bloqueado
	{bLegenda2, 'BR_AMARELO' },;       // carregando
	{bLegenda3, 'BR_VERDE'   },;       // liberado
	{bLegenda4, 'BR_VERMELHO' },;      // Encerrado
	{bLegenda5, 'BR_LARANJA' },;       // Espera
	{bLegenda6, 'BR_PRETO' },;          // Faturado
	{bLegenda0, 'BR_BRANCO' }}

	aCores2:= { { 'BR_VERDE'    ,'Liberado' },;
	{ 'BR_AMARELO'  ,'Carregando'},;
	{ 'BR_AZUL'     ,'Bloqueado'},;
	{ 'BR_VERMELHO' ,'Encerrado'},;
	{ 'BR_LARANJA'  ,'Em Espera'},;
	{ 'BR_PRETO'    ,'Faturado'}}

	Private cCadastro := "Pré-Pedidos de Venda"
	aRotina := { 	{ "Pesquisa"   ,  "AxPesqui"   , 0, 1},; 	//"Pesquisar"
	{ "Encerrar"   , "u_gjf31epp"  , 0, 4},; 	//"Encerrar Pré-pediddos"
	{ "Visualizar" , "u_gjf31VisP" , 0, 2},; 	//"Visualizar"
	{ "Caixas"     , "u_gjf31Cai"  , 0, 4},; 	//"Caixas"
	{ "Peças"      , "u_gjf31Pec"  , 0, 4},; 	//"Pecas"
	{ "Cons.Caixas", "u_gjf31Ver"  , 0, 4},; 	//"Verificação rápida de caixas"
	{ "Excl.Caixas", "u_gjf31exc"  , 0, 4},; 	//"Exclusão de caixas"
	{ "Relatorio"  , "u_gjf31rel"  , 0, 4},; 	//"Relatório para conferência de caixas com erro"
	{ "Rem. Valid.", "u_gjf31exv"  , 0, 4},; 	//"Botão para excluir da validação de caixas erradas"
	{ "Lib. Ped."  , "u_gjf31lib"  , 0, 4},; 	//"Botão para liberar o carregamento se estiver encerrado"
	{ "Legenda"    , "u_gjf28Leg"  , 0, 1}}     //"Legenda"

	//	{ "Caixas P."  ,  "u_gjf31Ca3" , 0, 4},; 	//"Caixas provisorio"
	cString := 'ZZ4'

	if ZZ3->ZZ3_STATUS = 'A'
		u_gjf31his('Inicio de Carregamento: Acesso Pre-Pedidos')
	else
		u_gjf31his('Acesso Pre-Pedidos')
	endif

	dbSelectArea(cString)
	ZZ4->(dbSetOrder(3))
	ZZ4->(dbgotop())

	cCondicao2 := ''

	cCondicao2 := "ZZ4_PRECAR = ZZ3_NUM AND ZZ4_STATUS <> 'B' AND ZZ4_FILIAL = '" + FWxfilial('ZZ4') + "'"

	mBrowse(6,1,22,75,cString, ,,,,1     ,aCores,,,,{|x| AutoRefresh(x)},,,,cCondicao2)

	If Select("ZZ2")<>0
		ZZ2->(dbCloseArea())
	Endif
	If Select("ZZ4")<>0
		ZZ4->(dbCloseArea())
	Endif
	If Select("ZZ5")<>0
		ZZ5->(dbCloseArea())
	Endif
	If Select("ZZ8")<>0
		ZZ8->(dbCloseArea())
	Endif
	If Select("SZ8")<>0
		SZ8->(dbCloseArea())
	Endif
	If Select("ZZB")<>0
		ZZB->(dbCloseArea())
	Endif
	If Select("ZZA")<>0
		ZZA->(dbCloseArea())
	Endif

	u_gjf31his('Saida Pre-Pedidos.  Retorno tela Pre-Carregamentos')

	restarea(area)

return .t.

//Essa função serve para criar o aHeader da função de alteração das quantidades
Static Function gjf31head1(cAlias)

	Aheader := {}

	aAdd(Aheader,{'Codigo'   ,'ZZ5_COD'     ,'@!'          , 6   , 0 , , , 'C' , cAlias,})
	aAdd(Aheader,{'Descricao','ZZ5_DESC'    ,'@!'          , 20  , 0 , , , 'C' , cAlias,})
	aAdd(Aheader,{'Q.P. Caix','ZZ5_QPCAIX'  ,'@E 999.99'   , 5   , 2 , , , 'N' , cAlias,})
	aAdd(Aheader,{'Q.R. Caix','ZZ5_QRCAIX'  ,'@E 999.99'   , 5   , 2 , , , 'N' , cAlias,})
	aAdd(Aheader,{'Q.P. Peso','ZZ5_QPPESO'  ,'@E 99,999.99', 9   , 2 , , , 'N' , cAlias,})
	aAdd(Aheader,{'Q.R. Peso','ZZ5_QRPESO'  ,'@E 99,999.99', 9   , 2 , , , 'N' , cAlias,})

Return len(aHeader)

// Essa função serve apra criar o aHeader das funções de carregamento
static function gjf31head2(mod)

	do case
		case mod = 1
		Aheader := {}
		aAdd(Aheader,{'Controle'   ,'ZZ6_CONTRO' ,'@!'           , 10   , 0 , , , 'C' ,'SZ8',})
		aAdd(Aheader,{'Cod. Prod.' ,'ZZ6_COD'    ,'@!'           , 06   , 0 , , , 'C' ,'SZ8',})
		aAdd(Aheader,{'Produto '   ,'ZZ6_DESCRI' ,'@!'           , 20   , 0 , , , 'C' ,'SZ8',})
		aAdd(Aheader,{'Peso Br'   ,' ZZ6_PESOBR' ,'@E 999,999.99', 7    , 2 , , , 'N' ,'SZ8',})
		aAdd(Aheader,{'Peso Liq'   ,'ZZ6_PESO'   ,'@E 999.99'    , 6    , 2 , , , 'N' ,'SZ8',})
		case mod = 2
		Aheader := {}
		aAdd(Aheader,{'Num.'       ,'ZZB_NUM'    ,'@!'          , 03   , 0 , , , 'C' ,'ZZB',})
		aAdd(Aheader,{'Cod. Prod.' ,'ZZB_COD'    ,'@!'          , 06   , 0 , , , 'C' ,'ZZB',})
		aAdd(Aheader,{'Produto '   ,'ZZB_DESCRI' ,'@!'          , 20   , 0 , , , 'C' ,'ZZB',})
		aAdd(Aheader,{'Peso Liq.'  ,'ZZB_PESOL'  ,'@E 999.99'   , 06   , 2 , , , 'N' ,'ZZB',})
		case mod = 3
		Aheader := {}
		aAdd(Aheader,{'N.'         ,'ZZA_NUM'    ,'@!'          , 03   , 0 , , , 'C' ,'ZZA',})
		//		aAdd(Aheader,{'Rastro'     ,'ZZA_RASTRO' ,'@!'          , 20   , 0 , , , 'C' ,'ZZA',})
		aAdd(Aheader,{'Cod. Prod.' ,'ZZA_COD'    ,'@!'          , 06   , 0 , , , 'C' ,'ZZA',})
		aAdd(Aheader,{'Produto '   ,'ZZA_DESCRI' ,'@!'          , 15   , 0 , , , 'C' ,'ZZA',})
		aAdd(Aheader,{'Quant.'     ,'ZZA_QUANT'  ,'@E 999'      , 3    , 0 , , , 'N' ,'ZZA',})
		aAdd(Aheader,{'Peso Liq.'  ,'ZZA_PESOL'  ,'@E 999.99'   , 6    , 2 , , , 'N' ,'ZZA',})
	endcase

return len(aHeader)

//Rotina para exclusão de caixas quando já carregadas
static function ExCarga(pos,mod)

	do case
		case mod = 1

			SZ8->(dbsetorder(2))
			if !SZ8->(Msseek(FWxfilial('SZ8') + FWxfilial('SB1') + ZZ4->ZZ4_NUM))
				return .f.
			endif
			if APMsgNOYES('Confirma exclusão de caixa?','EXCLUSAO')
				caixa := GDFieldGet('ZZ6_CONTRO',pos)
				prod  := GDFieldGet('ZZ6_COD',pos)
				if empty(prod)
					return .f.
				endif
				SZ8->(dbsetorder(3))
				if SZ8->(Msseek(FWxfilial('SZ8')+alltrim(caixa))) .and. SZ8->Z8_FIL = FWxfilial('SB1')

					ZZ5->(dbsetorder(1))
					ZZ5->(Msseek(FWxfilial('ZZ5')+alltrim(SZ8->Z8_PREPED+SZ8->Z8_ITEM)))
					reclock('ZZ5',.f.)
					ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX - 1
					ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO - SZ8->Z8_PESO
					ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB - SZ8->Z8_PESOBR
					ZZ5->ZZ5_STATUS := ''
					msunlock()
					if Carc -1 > 0
						CarC -= 1
					endif

					u_GJF134(2,SZ8->Z8_CONTROL,"E",DDATABASE,SZ8->Z8_COD,SZ8->Z8_PESO,SZ8->Z8_PRECAR,SZ8->Z8_FIL,SZ8->Z8_PREPED,SZ8->Z8_ITEM,SZ8->Z8_DATA,'')

					reclock('SZ8',.f.)
					SZ8->Z8_PREPED := ''
					SZ8->Z8_ITEM   := ''
					SZ8->Z8_PRECAR := ''
					SZ8->Z8_DATAS  := STOD('')
					SZ8->Z8_HORAS  := ''
					SZ8->Z8_DEST   := ''
					SZ8->Z8_CHKCARR   := ''
					SZ8->Z8_CHKPCAR   := ''
					if ZZ4->ZZ4_TPOPER = 'T'
						SZ8->Z8_DTRANSF:= STOD('')
					endif
					msunlock()

					ZZ6->(dbsetorder(3))
					ZZ6->(Msseek(FWxfilial('ZZ6')+alltrim(caixa)))

					reclock('ZZ6',.f.)
					ZZ6->ZZ6_PREPED := ''
					ZZ6->ZZ6_DATAS  := STOD('')
					ZZ6->ZZ6_HORAS  := ''
					ZZ6->ZZ6_ITEM   := ''
					ZZ6->ZZ6_PRECAR := ''
					ZZ6->ZZ6_USUAR  := ''
					ZZ6->ZZ6_PALLET := ''
					dbdelete()
					msunlock()
					u_gjf17his(1,'EXCL. PED. ' + ZZ5->ZZ5_NUM,.f.,'','','000013',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

				endif
				aCols := {}
				gjf31col2(1)
				oEnc:refresh()
			endif

		case mod = 2

			ZZB->(dbsetorder(1))

			if !(ZZB->(Msseek(FWxfilial('ZZB') + ZZ4->ZZ4_NUM)))
				return .f.
			endif

			caix   := alltrim(GDFieldGet('ZZB_NUM',pos))

			if empty(caix)
				return .f.
			endif

			if msgbox('Confirma exclusao da caixa?','Confirmação','YESNO')

				ZZB->(dbsetorder(2))

				if ZZB->(Msseek(FWxfilial('ZZB') + ZZ4->ZZ4_NUM + caix))

					ZZ8->(dbsetorder(2))

					if ZZ8->(Msseek(FWxfilial('ZZ8') +ZZ4->ZZ4_NUM + caix))
						reclock('ZZ8',.f.)
						dbdelete()
						msunlock()
					endif

					ZZ5->(dbsetorder(1))
					if ZZ5->(Msseek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM + ZZB->ZZB_ITEM))
						reclock('ZZ5',.f.)
						ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX - 1
						ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO - ZZB->ZZB_PESOL
						ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB - ZZB->ZZB_PESOB
						ZZ5->ZZ5_STATUS := ''
						msunlock()
					endif

					reclock('ZZB',.f.)
					dbdelete()
					msunlock()

				endif
				aCols := {}
				gjf31col2(2)
				oEnc:refresh()
			endif
			return

		case mod = 3
			peca   := ''
			quant  := 0

			ZZA->(dbsetorder(2))
			if !ZZA->(Msseek(FWxfilial('ZZA') + alltrim(ZZ4->ZZ4_NUM)))
				return .f.
			endif

			ZZ2->(dbsetorder(2))
			ZZ5->(dbsetorder(1))

			ZZA->(dbgotop())
			peca   := alltrim(GDFieldGet('ZZA_NUM',pos))
			rastro := alltrim(GDFieldGet('ZZA_RASTRO',pos))
			quant  := GDFieldGet('ZZA_QUANT',pos)
			if empty(peca)
				return .f.
			endif
			ZZA->(Msseek(FWxfilial('ZZA') + ZZ4->ZZ4_NUM + peca))
			if msgbox('Confirma Exclusao da peça?','Confirmação','YESNO')

				if ZZ2->(Msseek(FWxfilial('ZZ2') + ZZ4->ZZ4_NUM + peca,.t.))
					_cOri := GetAdvFVal('SB1','B1_CORORI',FWxfilial('SB1')+ZZ2->ZZ2_COD,1)
					reclock('ZZ2',.f.)
					dbdelete()
					msunlock()
				endif

				if ZZ5->(Msseek(FWxfilial('ZZ5') + ZZ4->ZZ4_NUM + ZZA->ZZA_ITEM))
					reclock('ZZ5',.f.)
					ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX - quant
					ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO - ZZA->ZZA_PESOL
					ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB - ZZA->ZZA_PESOB
					ZZ5->ZZ5_STATUS := ''
					msunlock()
					CarPec  := CarPec - quant
					CarPeso := CarPeso - ZZA->ZZA_PESOL
					atubrow()
				endif

				ZAJ->(DbGoTop())
				ZAJ->(DbSetOrder(3))
				if ZAJ->(MsSeek(FWxfilial('ZAJ')+ZZ3->ZZ3_NUM + ZZ4->ZZ4_NUM + ZZA->ZZA_ITEM) )
					While ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = FWxfilial('ZAJ') .and.;
					ZAJ->ZAJ_PRECAR = ZZ3->ZZ3_NUM   .and.;
					ZAJ->ZAJ_PREPED = ZZ4->ZZ4_NUM   .and.;
					ZAJ->ZAJ_ITEM   = ZZA->ZZA_ITEM
						reclock('ZAJ',.f.)
						ZAJ->ZAJ_DATAS  := ctod('')
						ZAJ->ZAJ_HORAS  := ''
						ZAJ->ZAJ_PRECAR := ''
						ZAJ->ZAJ_PREPED := ''
						ZAJ->ZAJ_ITEM   := ''
						msunlock()

						u_gjf182hs(1,'EXCLUSAO DO PROD.')

						ZAJ->(DbSkip())
					enddo
				endif

				reclock('ZZA',.f.)
				dbdelete()
				msunlock()

				aCols := {}
				gjf31col2(3)
				oEnc:refresh()
			endif
	endcase
return

//Essa função serve para validar o codigo de barras lido da caixa no momento de seu carregamento
Static Function validar(mod)

	Local _nNumCaix := 0
	Local _nPeso    := 0
	Local _nPesoBr  := 0
	Local _cCodPro  := ''
	Local existe    := .f.
	Local atendido  := .f.
	Local encerrado := .f.
	Local _lClass   := .f.
	Local _cPallet  := ''
	//Local _nPallet  := 0
	Local _lCarPal  := GetMv('SI_CARPAL') //parametro que libera ou bloqueia o carregamento por pallet
	Local _cControl := ''
	//Local _nEtqUsa := 0
	s := .f.
	do case
		case mod = 1

			if empty(valor)
				s := .t.
				return s
			endif

			SZ8->(DbGoTop())

			//Se foi um pallet inteiro escaneado....
			if substr(alltrim(valor),1,2) = 'PA'
				if !_lCarPal
					SomErr()
					msgbox('Operação de carregamento por pallet bloqueada!','OPERACAO INVALIDA!','STOP')
					return .f.
				endif

				//Verifica existencia do pallet
				SZP->(DbSetOrder(1))
				if !SZP->(MsSeek(FWxfilial('SZP') + alltrim(valor)))
					SomErr()
					msgbox('Pallet inexistente!','OPERACAO INVALIDA!','STOP')
					return .f.
				endif

				//Verifica existencia das caixas no pallet
				SZ8->(DbSetOrder(19))
				if !SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + alltrim(valor)))
					SomErr()
					msgbox('Caixas não encontradas no Pallet!','OPERACAO INVALIDA!','STOP')
					return .f.
				endif

				_cCodPro := alltrim(SZ8->Z8_COD )

				_nPeso   := 0
				_nPesoBr := 0
				_lClass  := .f.

				While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and. ;
				SZ8->Z8_FIL = cFilAnt .and. ;
				SZ8->Z8_PALLET = alltrim(valor)

					_nNumCaix++
					_nPeso   += SZ8->Z8_PESO
					_nPesoBr += SZ8->Z8_PESOBR

					_lClass  := Classif(alltrim(SZ8->Z8_CLASSIF))
					if !empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS)
						if alltrim(SZ8->Z8_MOTBAIX) $ "COLETA/SEQUESTRO"
							SomErr()
							msgbox('Caixa - '+ SZ8->Z8_CONTROL +' - sequestrada!','OPERACAO INVALIDA!','STOP')
							return .f.
						else
							SomErr()
							msgbox('Caixa - '+ SZ8->Z8_CONTROL +' - fora de Estoque!','OPERACAO INVALIDA!','STOP')
							return .f.
						endif
					elseif SZ8->Z8_ENCONTR = 'N'
						SomErr()
						msgbox('Caixa - '+ SZ8->Z8_CONTROL +' - não encontrada no Estoque!','OPERACAO INVALIDA!','STOP')
						return .f.
					Endif
					SZ8->(DbSkip())
				enddo

				//Verificação se existe o item no pedido
				//Verificação se o item já foi atendido
				//Verifica se o item já foi encerrado
				existe    := .f.
				atendido  := .f.
				encerrado := .f.
				ZZ5->(dbsetorder(1))
				ZZ5->(Msseek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
				do while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. (ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM)
					if alltrim(_cCodPro) = alltrim(ZZ5->ZZ5_COD)
						existe := .t.
						if ZZ5->ZZ5_STATUS = 'E'
							atendido := .t.
						else
							atendido := .f.
							exit
						endif
					endif
					ZZ5->(dbskip())
				enddo

				if  !existe
					SomErr()
					msgbox('Item inexistente!','OPERAÇÃO INVALIDA!','STOP')
					return .f.
				elseif atendido
					SomErr()
					msgbox('Item de pedido já atendido!','OPERAÇÃO INVALIDA!','STOP')
					return .f.
				elseif encerrado
					SomErr()
					msgbox('Item de pedido já encerrado!','OPERAÇÃO INVALIDA!','STOP')
					return .f.
				endif

				_lForaDt := .f.
				_lVenc 	 := .f.
				SZ8->(DbGoTop())
				SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + alltrim(valor)))
				While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and. ;
				SZ8->Z8_FIL = cFilAnt .and. ;
				SZ8->Z8_PALLET = alltrim(valor)

					_lForaDt := ValDP2()

					if SZ8->Z8_DATAVAL <= date()
						_lVenc := .t.
					endif

					SZ8->(DbSkip())
				enddo

				if _lVenc 
					SomErr2()
					msgbox('Existem caixas vencidas!','OPERAÇÃO INVALIDA!','STOP')
					return .f.
				endif

				if _lForaDt
					SomErr2()
					msgbox('Existem caixas fora do intervalo de datas definido!','OPERAÇÃO INVALIDA!','STOP')
					return .f.
				endif

				if 	!_lClass
					SomErr()
					msgbox('Carregamento de exportação requer habilitação de caixa!','HABILITAÇÃO!','STOP')
					return .f.
				endif

				//em faze de testes
				//valida o picking somente para santa maria
				//_cAvisSom := .F.	// Variável para saída de som caso 
				if cFilAnt == '00'
					SZ8->(DbGoTop())
					if SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + alltrim(valor)))
						While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and. SZ8->Z8_FIL = cFilAnt .and. SZ8->Z8_PALLET = alltrim(valor)

							if empty(SZ8->Z8_CARPICK)//verifica se a caixa foi separada
								//SomErr()
								//msgbox('Caixas do pallet nao foram separadas para carregamento!','SEPARAÇÃO DE CAIXAS!','STOP')
								//_cAvisSom := .T.
								u_gjf17his(4,'TENTATIVA DE CARREGAMENTO DO PALLET '+ alltrim(valor) +' NAO SEPARADO, CARREG: ' + ZZ4->ZZ4_PRECAR,.f.,'','','000014',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
								//return .f.
							elseif !empty(SZ8->Z8_CARPICK) //caso a caixa tenha sido separada
								if ZZ4->ZZ4_PRECAR <> SZ8->Z8_CARPICK //verifica se foi separada para o carregamento em questão
									//SomErr()
									//msgbox('Caixas do pallet foram separadas para outro carregamento!','SEPARAÇÃO DE CAIXAS!','STOP')
									//_cAvisSom := .T.
									u_gjf17his(4,'TENTATIVA DE CARREGAMENTO DO PALLET '+ alltrim(valor) +' JA SEPARADO PARA OUTRO CARREG: ' + ZZ4->ZZ4_PRECAR,.f.,'','','000015',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
									//return .f.
								endif
							endif

							SZ8->(dbSkip())
						enddo
						/*if _cAvisSom
							SomErr3()
							FWAlertWarning("Caixas no pallet " + alltrim(valor) + " não separadas ou separadas para outro carregamento!", "AVISO")
						endif*/
					endif
				endif

				do case
					case ZZ5->ZZ5_PRIORI = 'P'
						if ZZ5->ZZ5_QRPESO + _nPeso > (ZZ5->ZZ5_QPPESO * (1 + (ZZ5->ZZ5_TOLERA * 0.01)))
							SomErr()
							msgbox('Excedeu pesagem para carga!','TOLERANCIA ULTRAPASSADA!','STOP')
							return .f.
						endif

						reclock('ZZ5',.f.)                                     //Caso a prioridade do carregamento seja por peso,...
						ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO + _nPeso
						ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB + _nPesoBr
						ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX + _nNumCaix
						msunlock()

						CarC += _nNumCaix

						if ZZ5->ZZ5_QRPESO >= ZZ5->ZZ5_QPPESO
							reclock('ZZ5',.f.)
							ZZ5->ZZ5_STATUS := 'E'
							msunlock()
							encerrado := .t.
							priorP := .t.
						endif
					case ZZ5->ZZ5_PRIORI = 'A'                                    //Caso a prioridade de carregamento seja automatica...

						reclock('ZZ5',.f.)
						ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO + _nPeso
						ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB + _nPesoBr
						ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX + _nNumCaix
						msunlock()

						if (ZZ5->ZZ5_QRPESO >= ZZ5->ZZ5_QPPESO) .or. (ZZ5->ZZ5_QRCAIX >= ZZ5->ZZ5_QPCAIX)
							reclock('ZZ5',.f.)
							ZZ5->ZZ5_STATUS := 'E'
							msunlock()
							encerrado := .t.                                    //Verifica as quantidades do PP para encerra-lo
						endif

						CarC+= _nNumCaix

					case ZZ5->ZZ5_PRIORI = 'C'                                    //Caso a prioridade de carregamento seja por caixa
						if ZZ5->ZZ5_QRCAIX + _nNumCaix > (ZZ5->ZZ5_QPCAIX  * (1 + (ZZ5->ZZ5_TOLERA * 0.01)))
							SomErr()
							msgbox('Excedeu número de caixas para carga!','TOLERANCIA ULTRAPASSADA!','STOP')
							return .f.
						endif

						reclock('ZZ5',.f.)                                     //Caso a prioridade do carregamento seja por peso,...
						ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO + _nPeso
						ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB + _nPesoBr
						ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX + _nNumCaix
						msunlock()

						CarC += _nNumCaix

						if ZZ5->ZZ5_QRCAIX >= ZZ5->ZZ5_QPCAIX
							reclock('ZZ5',.f.)
							ZZ5->ZZ5_STATUS := 'E'
							msunlock()
							encerrado := .t.
							priorP := .t.
						endif
				endcase

				SZ8->(DbSetOrder(19))
				SZ8->(DbGotop())
				SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + alltrim(valor)))
				While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and. ;
				SZ8->Z8_FIL = cFilAnt .and. ;
				SZ8->Z8_PALLET = alltrim(valor)

					reclock('SZ8',.f.)                                               //Grava data do carregamento
					SZ8->Z8_DATAS   := date()                                        //Grava hora do carregamento
					SZ8->Z8_HORAS   := time()                                        //Grava numero e item do PP na caixa
					SZ8->Z8_PREPED  := ZZ5->ZZ5_NUM
					SZ8->Z8_ITEM    := ZZ5->ZZ5_ITEM
					SZ8->Z8_PRECAR  := ZZ4->ZZ4_PRECAR
					SZ8->Z8_TPROC   := '0'
					SZ8->Z8_DEST    := 'E'//destino expedicao
					if ZZ4->ZZ4_TPOPER = 'T'
						SZ8->Z8_DTRANSF := date()
					endif
					msunlock()

					//chama função pra tratar a transferencia
					if ZZ4->ZZ4_TPOPER = 'T'
						u_GJF134(1,SZ8->Z8_CONTROL,'S',date(),SZ8->Z8_COD,SZ8->Z8_PESO,SZ8->Z8_PRECAR,cFilAnt,SZ8->Z8_PREPED,SZ8->Z8_ITEM,SZ8->Z8_DATA,'')
					endif

					u_gjf17his(2,'CARREG. PED. ' + ZZ5->ZZ5_NUM,.f.,'','','000016',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)     //Grava histórico de carregamento da caixa

					AtuZAO(ZZ4->ZZ4_CODCLI,ZZ4->ZZ4_LOJA,SZ8->Z8_NUMPREV,SZ8->Z8_COD,SZ8->Z8_DESCRI)

					reclock('ZZ6',.t.)
					ZZ6->ZZ6_CONTRO := SZ8->Z8_CONTROL
					ZZ6->ZZ6_COD    := SZ8->Z8_COD
					ZZ6->ZZ6_PREPED := SZ8->Z8_PREPED
					ZZ6->ZZ6_ITEM   := SZ8->Z8_ITEM
					ZZ6->ZZ6_PRECAR := SZ8->Z8_PRECAR
					ZZ6->ZZ6_PESO   := SZ8->Z8_PESO
					ZZ6->ZZ6_PESOBR := SZ8->Z8_PESOBR
					ZZ6->ZZ6_TARA   := SZ8->Z8_TARA
					ZZ6->ZZ6_QUANT  := SZ8->Z8_QUANT                                       //Grava data do carregamento
					ZZ6->ZZ6_DATAS  := date()                                        //Grava hora do carregamento
					ZZ6->ZZ6_HORAS  := time()
					ZZ6->ZZ6_DESCRI := SZ8->Z8_DESCRI                                     //Grava numero e item do PP na caixa
					ZZ6->ZZ6_FILIAL := FWxfilial('SB1')
					ZZ6->ZZ6_USUAR  := cUserName
					ZZ6->ZZ6_PALLET := SZ8->Z8_PALLET
					msunlock()

					SB1->(dbclosearea())

					SZ8->(DbSkip())

				enddo

				RecLock('SZP',.f.)
				DbDelete()
				MsUnlock()

				atubrow()

				SZ8->(DbSetOrder(5))
				SZ8->(DbGotop())
				SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + ZZ4->ZZ4_PRECAR + ZZ5->ZZ5_NUM + ZZ5->ZZ5_ITEM))
				While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8')            .and. ;
				SZ8->Z8_FIL = cFilAnt            .and. ;
				SZ8->Z8_PRECAR = ZZ4->ZZ4_PRECAR .and. ;
				SZ8->Z8_PREPED = ZZ5->ZZ5_NUM    .and. ;
				SZ8->Z8_ITEM   = ZZ5->ZZ5_ITEM

					reclock('SZ8',.f.)
					SZ8->Z8_PALLET  := ''  //Desvincula ao Pallet
					SZ8->Z8_LOCALIZ := ''  //Desvincula da localização física
					SZ8->Z8_LOCAL   := ''
					msunlock()

					SZ8->(DbSkip())
				enddo

				execsom()
				mensER := space(1)                                            //Mensagem de pallet carregado
				mensOK := ' PALLET ' + valor + ' CARREGADO!'
				oSayDesc1:SetText(mensOK)
				oSayDesc2:SetText(mensER)
				valor := space(11)

				aCols := {}
				gjf31col2(1)
				//campo:setfocus()
				oCar:refresh()                                               //As linhas abaixo servem para atualizar o grid
				oEnc:refresh()

				oBrow:oBrowse:refresh()

				//Se foi caixa escaneada...
			else
				//valor := padl(alltrim(valor),10,'0')

				if len(alltrim(valor)) < 10
					s := .f.
					//campo:setfocus()
					return s
				endif

				if _nModSeq = 1
					SZ8->(DbSetOrder(3))
				else
					SZ8->(DbSetOrder(28))
				endif
				if (SZ8->(Msseek(FWxfilial('SZ8')+alltrim(valor)))) .and. empty(SZ8->Z8_DATAE)  .and.;
				SZ8->Z8_FIL = cFilAnt .AND. SZ8->Z8_ENCONTR <> 'N' //Se caixa não for excluida e encontrou a caixa, faz isso...

					if empty(SZ8->Z8_DATAS) .or. empty(SZ8->Z8_HORAS)  //Se ela não foi carregada faz isso...
						existe    := .f.
						atendido  := .f.
						encerrado := .f.
						st := .f.
						ZZ5->(dbsetorder(1))
						ZZ5->(Msseek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
						do while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. (ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM)
							if SZ8->Z8_COD = ZZ5->ZZ5_COD
								existe := .t.
								if ZZ5->ZZ5_STATUS = 'E'
									atendido := .t.
								else
									atendido := .f.
									exit
								endif
							endif
							ZZ5->(dbskip())
						enddo

						if  existe .and. !atendido

							_itemP := alltrim(SZ8->Z8_CLASSIF)
							if  !Classif(_itemP)           // verifica se for exportação
								SomErr()
								msgbox('Carregamento de exportação requer habilitação da caixa!','HABILITAÇÃO!','STOP')
								//campo:setfocus()
								return .f.
							endif

							if !Reserv(ZZ5->ZZ5_NUM)
								SomErr()
								msgbox('Essa caixa está reservada ou item requer reserva!','RESERVA DE CAIXAS!','STOP')
								//campo:setfocus()
								return .f.
							endif

							if SZ8->Z8_DATAVAL <= date()
								SomErr()
								msgbox('Essa está fora da data de validade!','VALIDADE!','STOP')
								//campo:setfocus()
								return .f.
							endif

							//Bloco para verificaçao de data de produção da caixa
							if !ValDtP()
								return .f.
							endif

							if SZ8->Z8_AUTOPED <> ZZ4->ZZ4_NUM
								/*incluir informações aqui referente a mensagem e incrementar a validação*/
							endif

							//valida o picking somente para santa maria
							if cFilAnt == '00
								if empty(SZ8->Z8_CARPICK)//verifica se a caixa foi separada
									//SomErr3()
									//msgbox('Caixa nao foi separada para carregamento!','SEPARAÇÃO DE CAIXAS!','STOP')
									u_gjf17his(4,'TENTATIVA DE CARREGAMENTO DE CX NAO SEPARADA, CARREG: ' + ZZ4->ZZ4_PRECAR,.f.,'','','000017',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
									//return .f.
								elseif !empty(SZ8->Z8_CARPICK) //caso a caixa tenha sido separada
									if ZZ4->ZZ4_PRECAR <> SZ8->Z8_CARPICK //verifica se foi separada para o carregamento em questão
										//SomErr3()
										//msgbox('Caixa foi separada para outro carregamento!','SEPARAÇÃO DE CAIXAS!','STOP')
										u_gjf17his(4,'TENTATIVA DE CARREGAMENTO DE CX JA SEPARADA P OUTRO CARREG: ' + ZZ4->ZZ4_PRECAR,.f.,'','','000018',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
										//return .f.
									endif
								endif
							endif

							do case
								case ZZ5->ZZ5_PRIORI = 'P'

									//DbSelectArea(SB1)
									//_cCodProd := ZZ5->ZZ5_COD
									//_cProdGrupo  :=GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+_cCodProd,1)

									//If !(substr(_cProdGrupo,1,2) $ '56')
									if ZZ5->ZZ5_QRPESO + SZ8->Z8_PESO > (ZZ5->ZZ5_QPPESO * (1 + (ZZ5->ZZ5_TOLERA * 0.01)))
										SomErr()
										msgbox('Excedeu pesagem para carga!','TOLERANCIA ULTRAPASSADA!','STOP')
										//campo:setfocus()
										return .f.
									endif

									reclock('ZZ5',.f.)                                     //Caso a prioridade do carregamento seja por peso,...
									ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO + SZ8->Z8_PESO
									ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB + SZ8->Z8_PESOBR
									ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX + 1
									msunlock()
									CarC++

									if ZZ5->ZZ5_QRPESO >= ZZ5->ZZ5_QPPESO
										reclock('ZZ5',.f.)
										ZZ5->ZZ5_STATUS := 'E'
										msunlock()
										encerrado := .t.
										priorP := .t.
									endif

									//Else

									//	if ZZ5->ZZ5_QRPESO + valor5 > (ZZ5->ZZ5_QPPESO * (1 + (ZZ5->ZZ5_TOLERA * 0.01)))
									//		SomErr()
									//		if !msgbox('Peso do Pedido Atingido, Deseja Continuar e usar a Tolerância?!','Peso Pedido Atendido!','YESNO')
									//			reclock('ZZ5',.f.)
									//			ZZ5->ZZ5_STATUS := 'E'
									//			msunlock()
									//			atendido := .t.
									//			return .f.
									//		endif
									//	endif

									//Caso a prioridade do carregamento seja por peso,...

									//	if ZZ5->ZZ5_QRPESO + valor5 >= ZZ5->ZZ5_QPPESO .and.;
									//			ZZ5->ZZ5_QRPESO <= ZZ5->ZZ5_QPPESO + (ZZ5->ZZ5_QPPESO * 0.10)
									//			reclock('ZZ5',.f.)
									//		ZZ5->ZZ5_STATUS := 'S'
									//			msunlock()
									//		atendido := .f.
									//		endif

									//	reclock('ZZ5',.f.)
									//	ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO + valor5
									//	ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB + valor4
									//		ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX + valor3
									//		atendido := .f.
									//		msunlock()
									//EndIf
									//	EndIf

								case ZZ5->ZZ5_PRIORI = 'A'                                    //Caso a prioridade de carregamento seja automatica...

									reclock('ZZ5',.f.)
									ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO + SZ8->Z8_PESO
									ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB + SZ8->Z8_PESOBR
									ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX + 1
									msunlock()

									if (ZZ5->ZZ5_QRPESO >= ZZ5->ZZ5_QPPESO) .or. (ZZ5->ZZ5_QRCAIX >= ZZ5->ZZ5_QPCAIX)
										reclock('ZZ5',.f.)
										ZZ5->ZZ5_STATUS := 'E'
										msunlock()
										encerrado := .t.                                    //Verifica as quantidades do PP para encerra-lo
									endif

									CarC++
								case ZZ5->ZZ5_PRIORI = 'C'                                    //Caso a prioridade de carregamento seja por caixa
									reclock('ZZ5',.f.)
									ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO + SZ8->Z8_PESO
									ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB + SZ8->Z8_PESOBR
									ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX + 1
									msunlock()
									CarC++
									if ZZ5->ZZ5_QRCAIX = ZZ5->ZZ5_QPCAIX
										reclock('ZZ5',.f.)
										ZZ5->ZZ5_STATUS := 'E'
										msunlock()
										encerrado := .t.
									endif
							endcase

							atubrow()

							_cPallet := SZ8->Z8_PALLET

							//execsom()                                                      //Função para executar o som
							reclock('SZ8',.f.)                                               //Grava data do carregamento
							SZ8->Z8_DATAS   := date()                                        //Grava hora do carregamento
							SZ8->Z8_HORAS   := time()                                        //Grava numero e item do PP na caixa
							SZ8->Z8_PREPED  := ZZ5->ZZ5_NUM
							SZ8->Z8_ITEM    := ZZ5->ZZ5_ITEM
							SZ8->Z8_PRECAR  := ZZ4->ZZ4_PRECAR
							SZ8->Z8_PALLET  := ''                                            //Desvincula ao Pallet
							SZ8->Z8_LOCALIZ := ''                                            //Desvincula da localização física
							SZ8->Z8_LOCAL   := ''                                            //Desvincula da Camara
							SZ8->Z8_TPROC   := '0'
							SZ8->Z8_DEST    := 'E'
							if ZZ4->ZZ4_TPOPER = 'T'
								SZ8->Z8_DTRANSF := date()
							endif
							msunlock()

							//chama a função que trata a transferencia
							if ZZ4->ZZ4_TPOPER = 'T'
								u_GJF134(1,SZ8->Z8_CONTROL,'S',date(),SZ8->Z8_COD,SZ8->Z8_PESO,SZ8->Z8_PRECAR,cFilAnt,SZ8->Z8_PREPED,SZ8->Z8_ITEM,SZ8->Z8_DATA,'')
							endif

							/*_nEtqUsa := GetMV("SI_NETQUSA")
							if GetAdvFVal('ZZ3','ZZ3_ISUSA',FWxfilial('ZZ3')+ZZ4->ZZ4_PRECAR,2) = 'S'
								if _nEtqUsa = 1
									putmv("SI_NETQUSA",2)
									EtqShipM(ZZ4->ZZ4_PRECAR, ZZ4->ZZ4_NUM)
								else
									putmv("SI_NETQUSA",1)
								endif
							endif*/

							u_gjf17his(2,'CARREG. PED. ' + ZZ5->ZZ5_NUM,.f.,'','','000016',SZ8->Z8_CONTROL,,,_cPallet)

							//Grava na ZAO correlação caixas plasticas x clientes
							AtuZAO(ZZ4->ZZ4_CODCLI,ZZ4->ZZ4_LOJA,SZ8->Z8_NUMPREV,SZ8->Z8_COD,SZ8->Z8_DESCRI)
							dbselectarea('SB1')

							reclock('ZZ6',.t.)
							ZZ6->ZZ6_CONTRO := SZ8->Z8_CONTROL
							ZZ6->ZZ6_COD    := SZ8->Z8_COD
							ZZ6->ZZ6_PREPED := SZ8->Z8_PREPED
							ZZ6->ZZ6_ITEM   := SZ8->Z8_ITEM
							ZZ6->ZZ6_PRECAR := SZ8->Z8_PRECAR
							ZZ6->ZZ6_PESO   := SZ8->Z8_PESO
							ZZ6->ZZ6_PESOBR := SZ8->Z8_PESOBR
							ZZ6->ZZ6_TARA   := SZ8->Z8_TARA
							ZZ6->ZZ6_QUANT  := SZ8->Z8_QUANT                                       //Grava data do carregamento
							ZZ6->ZZ6_DATAS  := date()                                        //Grava hora do carregamento
							ZZ6->ZZ6_HORAS  := time()
							ZZ6->ZZ6_DESCRI := SZ8->Z8_DESCRI                                     //Grava numero e item do PP na caixa
							ZZ6->ZZ6_FILIAL := FWxfilial('SB1')
							ZZ6->ZZ6_USUAR  := cUserName
							ZZ6->ZZ6_PALLET := _cPallet
							msunlock()

							SB1->(dbclosearea())
							execsom()
							mensER := space(1)                                            //Mensagem de caixa carregada
							mensOK := ' CAIXA ' + valor + ' CARREGADA!'
							oSayDesc1:SetText(mensOK)
							oSayDesc2:SetText(mensER)
							if _nModSeq = 1
								valor := space(11)
							else
								valor := space(15)
							endif
							aCols := {}
							gjf31col2(1)
							//campo:setfocus()
							oCar:refresh()                                               //As linhas abaixo servem para atualizar o grid
							oEnc:refresh()
							oBrow:oBrowse:refresh()

							if  encerrado
								execsom()                                               //Caso o item do PP for totalmente atendido, faz isso...
							//msgbox('Item '+ZZ5->ZZ5_ITEM + ' ('+alltrim(ZZ5->ZZ5_DESC)+') do pedido '+ ZZ5->ZZ5_NUM +;
							//' atendido!','ATENÇÃO','INFO') //removido temporariamente
							endif

							//Para excluir o pallet caso não haja mais caixa nele
							u_gjf31PA(_cPallet)

							return .f.
						else
							if  atendido
								mensER := 'ITEM DE PRODUTO JA ATENDIDO!'
							elseif !existe
								mensER := 'ITEM INEXISTENTE NO PRE-PEDIDO!'
							endif
							if _nModSeq = 1
								valor := space(11)
							else
								valor := space(15)
							endif
							mensOK := ' '
							oSayDesc1:SetText(mensOK)
							oSayDesc2:SetText(mensER)
							//campo:setfocus()
							oEnc:refresh()
							SomErr()
							return .f.
						endif
					else                                                                 //Entra nesse else se a caixa já foi carregada em outro PP
						mensER := 'CAIXA ' + valor +  ' CARREGADA PEDIDO N: ' + substr(SZ8->(Z8_PREPED+Z8_ITEM),1,6)
						mensOK := ' '
						if _nModSeq = 1
							valor := space(11)
						else
							valor := space(15)
						endif
						oSayDesc1:SetText(mensOK)
						oSayDesc2:SetText(mensER)
						//campo:setfocus()
						oEnc:refresh()
						SomErr()
						return .f.
					endif
				elseif SZ8->Z8_ENCONTR = 'N'
					mensER := 'CAIXA ' + valor +  ' NÃO ENCONTRADA NO ESTOQUE!'
					mensOK := ' '
					if _nModSeq = 1
						valor := space(11)
					else
						valor := space(15)
					endif
					oSayDesc1:SetText(mensOK)
					oSayDesc2:SetText(mensER)
					oEnc:refresh()
					SomErr()
					return .f.
				else                                                                     //Se a caixa de fato não existe...
					mensER := 'CAIXA ' + valor +  ' INEXISTENTE!'
					mensOK := ' '
					if _nModSeq = 1
						valor := space(11)
					else
						valor := space(15)
					endif
					oSayDesc1:SetText(mensOK)
					oSayDesc2:SetText(mensER)
					//campo:setfocus()
					oEnc:refresh()
					SomErr()
					return .f.
				endif
			endif
			DBCloseArea()

		case mod = 2                                                                 // Caso seja Caixa de terceiros...

			if empty(valor1)
				s := .t.
				return s
			endif

			valor1 := padl(alltrim(valor1),06,'0')

			_cUniM := GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+alltrim(valor1),1)

			if _cUniM != 'CX' .and. _cUniM != 'SC'
				msgbox('Este produto é embalado em Peças!','NAO É POSSIVEL PRODUZIR!','STOP')
				return s
			endif

			ZZ5->(dbsetorder(1))
			ZZ5->(Msseek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
			do while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. (ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM)
				if (alltrim(valor1) = alltrim(ZZ5->ZZ5_COD)) ;
				.and. ZZ5->ZZ5_STATUS != 'E'  .and. ZZ5->ZZ5_STATUS != 'F' // Verifica se existe e se ainda tem previsao
					s := .t.                                                                // Verifica, se achou cai fora
					exit
				endif
				ZZ5->(dbskip())
			enddo
			if !s
				msgbox('Não há Pré-pedidos para esse produto ou já foi atendido!','ATENÇÃO','STOP')
				return s
			else
				s := .t.
				mens := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+alltrim(valor2),1)
				oSayDesc:SetText(mens)
			endif
			return s

		case mod = 3//Caso seja um carregamento de peças...

			s       := .t.
			carc    := 0
			_nCarc  := 0 //Numero total de peças das carcaças já produzidas da carcaça
			_nCarc2 := 0 //Numero total de peças escaneadas no arquivo temporário TMP2 desta carcaça
			_nScnT  := 0
			_nScnD  := 0
			_lLerLD := .t. //Flag para apontar leitura do mesmo lado

			if empty(valor1)
				return .t.
			endif

			_cCorOri := GetAdvFVal('SB1','B1_CORORI',FWxfilial('SB1')+TMP->COD,1)

			ZAJ->(DbSetOrder(2))
			if !ZAJ->(MsSeek(FWxfilial('ZAJ')+alltrim(valor1)))
				SomErr()
				alert('Codigo de Carcaça não identificado!')
				return .f.
			endif

			if !empty(ZAJ->ZAJ_DATAS)  .and. !empty(ZAJ->ZAJ_HORAS)
				SomErr()
				msgbox('Peça já expedida ou processada!','OPERAÇÃO INVALIDA!','STOP')
				Return .f.
			endif

			_cRastro   := ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO)
			_cNumam    := ZAJ->ZAJ_NUMAM
			_cCodProd  := ZAJ->ZAJ_COD
			_cLado     := ZAJ->ZAJ_LADO
			_cTipo     := ZAJ->ZAJ_CORORI
			_cControl  := alltrim(ZAJ->ZAJ_CONTRO)
			_cNumero   := ZAJ->ZAJ_NUM
			// Tratamento para caso seja carcaça produzida no MRVT17 busca do cadastro By Flávio 04/02/20 - Solicitado pela Henrique
			IF _cControl == ''  .AND. empty(ZAJ->ZAJ_ZAPNUM)
				// Se for carcaça nossa e não for produzida no Abate entra aqui
				_cProgram  := GetAdvFVal('SB1','B1_PROGRAM',FWxfilial('SB1') + _cCodProd,1)
				_cCateg    := GetAdvFVal('SB1','B1_CATEG',FWxfilial('SB1') + _cCodProd,1)
				_nPcarc1I  := GetAdvFVal('SB1','B1_PMPEC',FWxFilial('SB1') + _cCodProd,1)
				_nPcarc2I  := _nPcarc1I
			Else
				_cCateg    := GetAdvFVal('SZK','ZK_CATEG',FWxfilial('SZK')+_cNumam + _cControl,4)
				_cProgram  := GetAdvFVal('SZK','ZK_PROGRAM',FWxfilial('SZK')+_cNumam + _cControl,4)
				_nPcarc1I  := GetAdvFVal('SZK','ZK_PECARC1',FWxFilial('SZK')+_cNumam + _cControl,4)
				_nPcarc2I  := GetAdvFVal('SZK','ZK_PECARC2',FWxFilial('SZK')+_cNumam + _cControl,4)
			Endif

			_nPercTras := GETMV('SI_%TRAS')
			_nPercDian := GETMV('SI_%DIAN')
			_nPercCost := GETMV('SI_%COST')
			_nPcarc1   := _nPcarc1I - (_nPcarc1I * 0.02) // -2% de frio
			_nPcarc2   := _nPcarc2I - (_nPcarc2I * 0.02) // -2% de frio

			do case
				/*caso seja traseiro*/
				case _cTipo = 'T'
				_nPmPeca := _nPercTras * iif(_cLado = 'E',_nPcarc1,_nPcarc2)

				/*caso seja dianteiro*/
				case _cTipo = 'D'
				_nPmPeca := _nPercDian * iif(_cLado = 'E',_nPcarc1,_nPcarc2)

				/*caso seja costela*/
				case _cTipo = 'C'
				_nPmPeca := _nPercCost * iif(_cLado = 'E',_nPcarc1,_nPcarc2)
			endcase

			//Verifica se não estiver apontado o tipo meia-res ou traseiro capote para carregar
			/*
			if  !(_cCorOri $ 'E/P') .and. _cCodProd  $ '006272/006464/007891/006273/006463/007892'

			ZZ5->(DbSetOrder(2))
			if !ZZ5->(MsSeek(FWxfilial('ZZ5') + TMP->NUM + _cCodProd))
			SomErr()
			msgbox('Produto inexistente para carregamento!','OPERAÇÃO INVALIDA!','STOP')
			Return .f.
			else
			_cNum     :=  ZZ5->ZZ5_NUM
			_cItem    :=  ZZ5->ZZ5_ITEM
			_cProduto := _cCodProd
			endif
			else
			*/
			//Verifica se o corte de origem da peça escaneada bate com o tipo que tem que ser carregado
			if _cCorOri $ 'D/T/C'
				if _cCorOri <> _cTipo
					SomErr()
					msgbox('Tipo de peça não condiz com produto a ser carregado!','OPERAÇÃO INVALIDA!','STOP')
					Return .f.
				endif
			endif

			//Codigos de meia-reses
			_cPCatBoi := '000029' //Verificação produto x categoria para meia-res Boi
			_cPCatVac := '003243' //Verificação produto x categoria para meia-res Vaca
			_cPCatTou := '004237' //Verificação produto x categoria para meia-res Touro
			_cPProgCL := '006374' //Verificação produto x programa  para meia-res Cruza Leite
			_cPProgMa := '006375' //Verificação produto x programa  para meia-res Magro
			_cPProgHe := '006271' //Verificação produto x programa  para meia-res Hereford
			_cPProgAn := '006270' //Verificação produto x programa  para meia-res Angus

			//Codigos para traseiro capote
			_cTrasCapBoi := '000385'
			_cTrasCapVac := '003666'
			_cTrasCapAng := '006274'
			_cTrasCapHer := '006275'

			DbSelectArea('SB1')
			SB1->(DbSetOrder(1))
			SB1->(MsSeek(FWxfilial('SB1') + alltrim(TMP->COD)))
			_cDescProg  := GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6') + _cProgram,1)
			_cDescCateg := GetAdvFVal('SZ5','Z5_DESC',FWxfilial('SZ5') + _cCateg,1)

			/*if SB1->B1_PROGRAM <> '013'// PROGRAMA GERAL PODE TUDO
				if SB1->B1_PROGRAM <> '012'//se não for programa generico faz a verificação que sempre fez
					if alltrim(SB1->B1_PROGRAM) <> alltrim(_cProgram)  //.and. !empty(_cProgram) //!empty(SB1->B1_PROGRAM)
						SomErr()
						//alert('Entrou linha 1337')
						msgbox('Programa não condiz com produto!',_cDescProg,'STOP')
						Return .f.
					endif
				else
					if !(_cProgram $ '002/006/021/022')//se for programa generico, verifica se os programas das carcaças são angus ou hereford.
						SomErr()
						msgbox('Só é possivel carregar Angus e Hereford para este produto!',_cDescProg,'STOP')
						Return .f.
					endif
				endif
			endif*/

			if !('013' $ SB1->B1_PROGRAM) .and. !('012' $ SB1->B1_PROGRAM) // PROGRAMA "GERAL" OU "S/ PROGRAMA" PODE TUDO
				if !(_cProgram $ SB1->B1_PROGRAM) // SE NÃO, DEVE RESPEITAR O CADASTRO
					SomErr()
					FWAlertError("Programa (" + alltrim(_cDescProg) + ") não condiz com o produto sendo carregado!", "ERRO!")
					Return .f.
				endif
			endif

			if SB1->B1_CATEG <> alltrim(_cCateg) .and. !empty(SB1->B1_CATEG)
				SomErr()
				msgbox('Categoria não condiz com produto!',_cDescCateg,'STOP')
				Return .f.
			endif

			//verifica se a carcaça escaneada é de terceiro
			if !empty(ZAJ->ZAJ_ZAPNUM)
				if SB1->B1_CARTERC <> 'S'
					SomErr()
					msgbox('Não é permitido carregamento de peça de terceiros, entre em contato com o PCP!','ATENÇÃO!','STOP')
					Return .f.
				endif
			endif

			//Se for meia-res verifica se as peças ja foram processadas
			if _cCorOri = 'E'

				/*
				do case
				//Verifica meia res de programa Cruza Leite
				case  alltrim(TMP->COD) = _cPProgCL
				if alltrim(_cProgram) <> '005'
				SomErr()
				msgbox('Programa não condiz com produto!','PROGRAMA CRUZA LEITE!','STOP')
				Return .f.
				endif

				//Verifica meia res de programa Magro
				case  alltrim(TMP->COD) = _cPProgMa
				if alltrim(_cProgram) <> '001'
				SomErr()
				msgbox('Programa não condiz com produto!','PROGRAMA MAGRO!','STOP')
				Return .f.
				endif

				//Verifica meia res de programa Hereford
				case  alltrim(TMP->COD) = _cPProgHe
				if alltrim(_cProgram) <> '002'
				SomErr()
				msgbox('Programa não condiz com produto!','PROGRAMA HEREFORD!','STOP')
				Return .f.
				endif

				//Verifica meia res de programa Angus
				case  alltrim(TMP->COD) = _cPProgAn
				if alltrim(_cProgram) <> '006'
				SomErr()
				msgbox('Programa não condiz com produto!','PROGRAMA ANGUS!','STOP')
				Return .f.
				endif

				//Verifica meia res de categoria Boi
				case  alltrim(TMP->COD) = _cPCatBoi
				if alltrim(_cCateg) <> '001'
				SomErr()
				msgbox('Categoria não condiz com produto!','CATEGORIA BOI!','STOP')
				Return .f.
				endif

				//Verifica meia res de categoria Vaca
				case  alltrim(TMP->COD) = _cPCatVac
				if alltrim(_cCateg) <> '002'
				SomErr()
				msgbox('Categoria não condiz com produto!','CATEGORIA VACA!','STOP')
				Return .f.
				endif

				endcase
				*/

				_TipMR := ''

				TMP2->(DbGoTop())
				While TMP2->(!eof())
					if TMP2->ZAJ_NUM = alltrim(_cNumero)
						_tipMR := TMP2->ZAJ_CORORI
					endif
					TMP2->(DbSkip())
				enddo

				if _TipMR = _cTipo
					SomErr()
					msgbox('Esta parte da meia-res já foi lida!','OPERAÇÃO INVÁLIDA!','STOP')
					return .f.
				endif

				// Bloco inserido por Fabian , Flavio e Maurício dia 12/01 - Para carregar a meia-rez somente da mesma carcaça
				_lFlag  := .t. //
				TMP2->(DbGoTop())
				While TMP2->(!eof())

					if  _cRastro <> TMP2->(ZAJ_NUMAM+ZAJ_CONTRO)
						_lFlag := .f.
					else
						_lFlag := .t.
						exit
					Endif
					TMP2->(DbSkip())
				enddo

				_nQuantD := 0
				_nQuantT := 0
				_nQuantC := 0

				TMP2->(DbGoTop())
				While TMP2->(!eof())
					if !empty(TMP2->(ZAJ_NUMAM+ZAJ_CONTRO))
						if TMP2->ZAJ_CORORI = 'D'
							_nQuantD++

						elseif  TMP2->ZAJ_CORORI = 'T'
							_nQuantT++
						elseif TMP2->ZAJ_CORORI = 'C'
							_nQuantC++
						endif
					endif
					TMP2->(DbSkip())
				enddo

				if !_lFlag
					SomErr()
					msgbox('Esta parte da meia-res não corresponde a mesma Carcaça!','OPERAÇÃO INVÁLIDA!','STOP')
					return .f.
				elseif _nQuantD >= 1  .and. _cTipo = 'D' .and. _lFlag
					SomErr()
					msgbox('Esta parte da meia-res não corresponde a mesma Carcaça!','OPERAÇÃO INVÁLIDA!','STOP')
					return .f.
				elseif _nQuantT >= 1 .and. _cTipo = 'T' .and. _lFlag
					msgbox('Esta parte da meia-res não corresponde a mesma Carcaça!','OPERAÇÃO INVÁLIDA!','STOP')
					return .f.
				elseif _nQuantC >= 1 .and. _cTipo = 'C' .and. _lFlag
					msgbox('Esta parte da meia-res não corresponde a mesma Carcaça!','OPERAÇÃO INVÁLIDA!','STOP')
					return .f.
				endif

				//Fim Bloco inserido  Fabian , Flavio e Maurício dia 12/01

			endif

			//Se for Traseiro capote verifica se as peças ja foram processadas
			if _cCorOri = 'P'

				_TipMR := ''

				if _cTipo = 'D'
					SomErr()
					msgbox('Peça não condiz com produto!','DIANTEIRO!','STOP')
					Return .f.
				endif
				/*
				do case
				//Verifica traseiro capote boi
				case  alltrim(TMP->COD) = _cTrasCapBoi
				if alltrim(_cCateg) <> '001'
				SomErr()
				msgbox('Categoria não condiz com produto!','CATEGORIA BOI!','STOP')
				Return .f.
				endif

				//Verifica traseiro capote vaca
				case  alltrim(TMP->COD) = _cTrasCapVac
				if alltrim(_cCateg) <> '002'
				SomErr()
				msgbox('Categoria não condiz com produto!','CATEGORIA VACA!','STOP')
				Return .f.
				endif

				//Verifica traseiro capote Hereford
				case  alltrim(TMP->COD) = _cTrasCapHer
				if alltrim(_cProgram) <> '002'
				SomErr()
				msgbox('Programa não condiz com produto!','PROGRAMA HEREFORD!','STOP')
				Return .f.
				endif

				//Verifica traseiro capote Angus
				case  alltrim(TMP->COD) = _cTrasCapAng
				if alltrim(_cProgram) <> '006'
				SomErr()
				msgbox('Programa não condiz com produto!','PROGRAMA ANGUS!','STOP')
				Return .f.
				endif

				endcase
				*/
				TMP2->(DbGoTop())
				While TMP2->(!eof())
					if TMP2->ZAJ_NUM = alltrim(_cNumero)
						_tipMR := TMP2->ZAJ_CORORI
					endif
					TMP2->(DbSkip())
				enddo

				if _TipMR = _cTipo
					SomErr()
					msgbox('Esta parte do traseiro capote já foi lida!','OPERAÇÃO INVÁLIDA!','STOP')
					return .f.
				endif

			endif

			TMP2->(DbGoTop())
			while TMP2->(!eof())
				if TMP2->ZAJ_NUM = ZAJ->ZAJ_NUM
					SomErr()
					msgbox('Peça já lida!','OPERAÇÃO INVALIDA!','STOP')
					Return .f.
				endif
				TMP2->(dBSkip())
			enddo

			//Se for meia-res verifica se as peças ja foram processadas
			if _cCorOri = 'E'

				TMP2->(DbGoTop())
				While TMP2->(!eof())
					if TMP2->ZAJ_NUM = alltrim(_cNumero)
						_tipMR = TMP2->ZAJ_CORORI
					endif
					TMP2->(DbSkip())
				enddo

				if _TipMR = _cTipo
					SomErr()
					msgbox('Esta parte da meia-res já foi lida!','OPERAÇÃO INVÁLIDA!','STOP')
					return .f.
				endif

			endif

			//Se for traseiro capote verifica se as peças ja foram processadas
			if _cCorOri = 'P'

				TMP2->(DbGoTop())
				While TMP2->(!eof())
					if TMP2->ZAJ_NUM = alltrim(_cNumero)
						_tipMR = TMP2->ZAJ_CORORI
					endif
					TMP2->(DbSkip())
				enddo

				if _TipMR = _cTipo
					SomErr()
					msgbox('Esta parte do traseiro capote já foi lida!','OPERAÇÃO INVÁLIDA!','STOP')
					return .f.
				endif
			endif

			_cProduto := TMP->COD
			_cNum     :=  TMP->NUM
			_cItem    :=  TMP->ITEM
			//endif

			/*Verificação do peso minimo da peça para carcaças proprias*/
			//verifica se é de terceiro
			if empty(ZAJ->ZAJ_ZAPNUM)
				ZZ5->(DbSetOrder(1))
				if ZZ5->(MsSeek(FWxFilial('ZZ5') + _cNum + _cItem))
					//verifica se foi informado o peso minimo da peça para validação do peso
					if !empty(ZZ5->ZZ5_PMINP)
						if _nPmPeca < ZZ5->ZZ5_PMINP
							SomErr()
							msgbox('Peso médio da peça é inferior ao peso minimo solicitado no pedido!!','OPERAÇÃO INVÁLIDA!','STOP')
							return .f.
						endif
					endif
				endif
			endif

			TMP2->(DbGoTop())

			reclock('TMP2',.t.)
			TMP2->ZAJ_NUM      := _cNumero
			TMP2->ZAJ_CORORI   := _cTipo
			TMP2->ZAJ_LADO     := _cLado
			TMP2->ZAJ_PRECAR   := ZZ3->ZZ3_NUM
			TMP2->ZAJ_PREPED   := _cNum
			TMP2->ZAJ_ITEM     := _cItem
			TMP2->ZAJ_COD      := _cProduto
			TMP2->ZAJ_NUMAM    := _cNumam
			TMP2->ZAJ_CONTRO   := _cControl
			TMP2->ZAJ_DATAS    := date()
			TMP2->ZAJ_HORAS    := time()
			TMP2->ZK_CATEG     := _cCateg
			msunlock()

			execsom()

			TMP2->(DbGoTop())

			valor1 := space(24)
			//campo1:setfocus()
			oEsc:refresh()
			oBrow2:oBrowse:refresh()

			return .f.

		case mod = 4
			s := .f.
			if GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+alltrim(valor2),1) != 'PC'
				msgbox('Este produto é embalado em caixas!','NAO É POSSIVEL PRODUZIR!','STOP')
				return s
			endif
			ZZ5->(dbsetorder(1))
			ZZ5->(Msseek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
			do while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. (ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM)
				if (alltrim(valor2) = alltrim(ZZ5->ZZ5_COD)) .and. ;
				ZZ5->ZZ5_STATUS != 'E'   // Verifica se existe e se ainda tem previsao
					s := .t.                                                                // Verifica, se achou cai fora
					exit
				endif
				ZZ5->(dbskip())
			enddo
			if !s
				msgbox('Não há Pré-pedidos para esse produto ou já foi atendido!','ATENÇÃO','STOP')
				return s
			else
				mens := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+alltrim(valor2),1)
				oSayDesc:SetText(mens)
			endif
	endcase
return s

Static Function ModSeq()
	if _nModSeq = 1
		valor := space(11)
	elseif _nModSeq = 2
		valor := space(15)
	endif

	campo:refresh()
	oEnc:refresh()
return

/*/{Protheus.doc} EtqShipM()
	Função para imprimir a etiqueta de Shipping Mark
	@type Function
	@author Adonai
	@param _precar, character, pré-carregamento
	@param _preped, character, pré-pedido
	@since 12/03/2024
/*/
/*Static Function EtqShipM(_precar, _preped)

	_cEst := getComputerName()
	_cIp  := ''
	fDesc :=  "65,45"

	ZAM->(dbSetOrder(2))
	if ZAM->(dbSeek(FWxFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	endif

	//se não achou o ip na tabela imprime pela porta paralela
	if empty(_cIp)
		MSCBPRINTER('S600','LPT1')
	else
		MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
	endif

	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,4,50)

	MSCBSAY(10,15,"Shipping Mark","N","0",fDesc)
	MSCBSAY(8,30,_precar+_preped,"N","0",fDesc)
	MSCBSAY(64,15,"Shipping Mark","N","0",fDesc)
	MSCBSAY(62,30,_precar+_preped,"N","0",fDesc)

	MSCBEND()
	MSCBCLOSEPRINTER()

Return*/

//Função de validação de leitura e validação
//das peças (pendurados) carregadas no tendal
Static Function ValPeca()

	s       := .t.                                                                 //Caso seja um carregamento de peças...
	carc    := 0
	_nCarc  := 0 //Numero total de peças das carcaças já produzidas da carcaça
	_nCarc2 := 0 //Numero total de peças escaneadas no arquivo temporário TMP2 desta carcaça
	_nScnT  := 0
	_nScnD  := 0
	_lLerLD := .t. //Flag para apontar leitura do mesmo lado

	if empty(valor1)
		return .t.
	endif

	ZAJ->(DbSetOrder(2))
	if !ZAJ->(MsSeek(FWxfilial('ZAJ')+alltrim(valor1)))
		SomErr()
		alert('Codigo de Carcaça não identificado!')
		return .f.
	endif

	if !empty(ZAJ->ZAJ_DATAS)  .and. !empty(ZAJ->ZAJ_HORAS)
		SomErr()
		msgbox('Peça já expedida ou processada!','OPERAÇÃO INVALIDA!','STOP')
		Return .f.
	endif

	DbSelectArea('SB1')
	_cCorOri  := GetAdvFVal('SB1','B1_CORORI',FWxfilial('SB1')+TMP->COD,1)
	_cRastro  := ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO)
	_cNumam   := ZAJ->ZAJ_NUMAM
	_cCodProd := alltrim(ZAJ->ZAJ_COD)
	_cLado    := ZAJ->ZAJ_LADO
	_cTipo    := ZAJ->ZAJ_CORORI
	_cControl := ZAJ->ZAJ_CONTRO
	_cNumero  := ZAJ->ZAJ_NUM
	_cCateg   := GetAdvFVal('SZK','ZK_CATEG',FWxfilial('SZK')+_cNumam + _cControl,4)
	_cProgram := GetAdvFVal('SZK','ZK_PROGRAM',FWxfilial('SZK')+_cNumam + _cControl,4)
	_nPcarc1  := GetAdvFVal('SZK','ZK_PECARC1',FWxFilial('SZK')+_cNumam + _cControl,4)
	_nPcarc2  := GetAdvFVal('SZK','ZK_PECARC2',FWxFilial('SZK')+_cNumam + _cControl,4)
	_nPmPeca  := ZAJ->ZAJ_PESO
	_cProgP   := ''
	_cCateP   := ''
	_cCodPa   := ''
	//Bloco que verifica o correlacionamento MP/PP/PR/PA
	_lCorrel := .f.

	ZB5->(DbSetOrder(1))
	If ZB5->(MsSeek(FWxfilial('ZB5') + alltrim(TMP->COD)))
		While  ZB5->(!eof()) .and. ZB5->ZB5_FILIAL = FWxfilial('ZB5') .and. alltrim(ZB5->ZB5_CODPA) = alltrim(TMP->COD)

			if _cCodProd = alltrim(ZB5->ZB5_COD)
				_cProgP  := ZB5->ZB5_PROGRA
				//	_cCateP  := ZB5->ZB5_CATEG
				_cCodPa := ZB5->ZB5_CODPA
				_lCorrel := .t.
			endif

			ZB5->(DbSkip())
		enddo

	endif

	if  !_lCorrel
		SomErr()
		msgbox('Correlacionamento inexistente de produto! Entre em contato com o PCP!','OPERAÇÃO INVALIDA!','STOP')
		Return .f.
	Endif
	//Fim do bloco que verifica o correlacionamento MP/PP/PR/PA

	//Verificação de categoria
	if _cCateg <> _cCateP
		SomErr()
		msgbox('Categoria não condiz com produto!','CATEGORIA!','STOP')
		Return .f.
	endif

	//Verificação de programa
	if _cProgram <> _cProgP
		SomErr()
		
		msgbox('Programa não condiz com produto!','PROGRAMA!','STOP')
		Return .f.
	endif

	//Verifica se a peça já foi lida...
	TMP2->(DbGoTop())
	while TMP2->(!eof())
		if TMP2->ZAJ_NUM = ZAJ->ZAJ_NUM
			SomErr()
			msgbox('Peça já lida!','OPERAÇÃO INVALIDA!','STOP')
			Return .f.
		endif
		TMP2->(dBSkip())
	enddo

	//Se for meia-res verifica se as peças ja foram processadas
	if _cCorOri = 'E'

		if _cTipo <> 'E'
			_TipMR := ''

			TMP2->(DbGoTop())
			While TMP2->(!eof())
				if TMP2->ZAJ_NUM = alltrim(_cNumero)
					_tipMR := TMP2->ZAJ_CORORI
				endif
				TMP2->(DbSkip())
			enddo

			if _TipMR = _cTipo
				SomErr()
				msgbox('Esta parte da meia-res já foi lida!','OPERAÇÃO INVÁLIDA!','STOP')
				return .f.
			endif
		endif

	endif

	//Se for Traseiro capote verifica se as peças ja foram processadas
	if _cCorOri = 'P'

		_TipMR := ''

		if _cTipo = 'D'
			SomErr()
			msgbox('Peça não condiz com produto!','DIANTEIRO!','STOP')
			Return .f.
		endif

		if _cTipo <> 'P'

			TMP2->(DbGoTop())
			While TMP2->(!eof())
				if TMP2->ZAJ_NUM = alltrim(_cNumero)
					_tipCa := TMP2->ZAJ_CORORI
				endif
				TMP2->(DbSkip())
			enddo

			if _TipCa = _cTipo
				SomErr()
				msgbox('Esta parte do traseiro capote já foi lida!','OPERAÇÃO INVÁLIDA!','STOP')
				return .f.
			endif
		endif
	endif

	_cProduto :=  TMP->COD
	_cNum     :=  TMP->NUM
	_cItem    :=  TMP->ITEM

	/*Verificação do peso minimo da peça para carcaças proprias*/
	//verifica se é de terceiro
	if empty(ZAJ->ZAJ_ZAPNUM)
		ZZ5->(DbSetOrder(1))
		if ZZ5->(MsSeek(FWxFilial('ZZ5') + _cNum + _cItem))
			//verifica se foi informado o peso minimo da peça para validação do peso
			if !empty(ZZ5->ZZ5_PMINP)
				if _nPmPeca < ZZ5->ZZ5_PMINP
					SomErr()
					msgbox('Peso médio da peça é inferior ao peso minimo solicitado no pedido!!','OPERAÇÃO INVÁLIDA!','STOP')
					return .f.
				endif
			endif
		endif
	endif

	TMP2->(DbGoTop())

	reclock('TMP2',.t.)
	TMP2->ZAJ_NUM      := _cNumero
	TMP2->ZAJ_CORORI   := _cTipo
	TMP2->ZAJ_LADO     := _cLado
	TMP2->ZAJ_PRECAR   := ZZ3->ZZ3_NUM
	TMP2->ZAJ_PREPED   := _cNum
	TMP2->ZAJ_ITEM     := _cItem
	TMP2->ZAJ_COD      := _cProduto
	TMP2->ZAJ_NUMAM    := _cNumam
	TMP2->ZAJ_CONTRO   := _cControl
	TMP2->ZAJ_DATAS    := date()
	TMP2->ZAJ_HORAS    := time()
	TMP2->ZK_CATEG     := _cCateg
	msunlock()

	execsom()

	TMP2->(DbGoTop())

	valor1 := space(24)
	//campo1:setfocus()
	oEsc:refresh()
	oBrow2:oBrowse:refresh()

return .f.

User Function gjf31epp()

	local _lValUsr := getmv('SI_LVALUSR')
	local _aRetPsw := {}
	local _lretPck
	local _nPesFlt := getmv('SI_EXPFLT') //peso de falta da expedicao

	if ZZ4->ZZ4_STATUS = 'C' .or. ZZ4->ZZ4_STATUS = 'F' .or. ZZ4->ZZ4_STATUS = 'E'
		msgbox('Status não permite essa operação!','OPERAÇÃO IRREGULAR','ERRO')
		return
	endif

	_lFal := .f.
	ZZ5->(dbsetorder(1))
	if ZZ5->(Msseek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
		While ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM
			if ZZ5->ZZ5_STATUS != 'E' 
				if  ZZ5->ZZ5_PRIORI == 'P' .and. (ZZ5->ZZ5_QPPESO - ZZ5->ZZ5_QRPESO) >= _nPesFlt //quando for prioridade peso e estiver faltando 24kg ou mais considera falta
					if "CX" = GetAdvFVal('SB1','SB1_SEGUM',FWxfilial('SB1') + ZZ5->ZZ5_COD,1)
						FWAlertWarning("Faltando " + alltrim(transform((ZZ5->ZZ5_QPPESO - ZZ5->ZZ5_QRPESO),'@E 999.99')) + " kg no item " + ZZ5->ZZ5_ITEM + "!", "ATENÇÃO")
					endif
					_lFal := .t.
				elseif ZZ5->ZZ5_PRIORI <> 'P'
					_lFal := .t.
				endif
			endif
			ZZ5->(dbskip())
		enddo
	endif
	if _lFal
		if !('HTML' $ u_remoteType())
			WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
		else
			WINEXEC(cTempPath + cExecWeb + ' /play /close /embedding ' + cTempPath + 'GEER.WAV',0)
		endif

		if !msgbox('Pedido ' + alltrim(ZZ4->ZZ4_NUM) + ' será encerrado com falta! Continuar?','ATENÇÃO','YESNO')
			Return
		else
			if _lValUsr

				_lretPck := u_mitpck01(ZZ4->ZZ4_PRECAR)
				if _lretPck
					if !('HTML' $ u_remoteType())
						WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
					else
						WINEXEC(cTempPath + cExecWeb + ' /play /close /embedding ' + cTempPath + 'GEER.WAV',0)
					endif

					if !msgbox('Carregamento possui uma caixa com picking realizado e que não está carregada, deseja continuar?','ATENÇÃO','YESNO')
						return
					endif
				endif

				//solicita autorização para encerrar o prépedido caso haja falta
				_aRetPsw := u_mitfs006()
				if !_aRetPsw[1]
					return
				endif
			endif	

			//u_gjf31wfw(ZZ4->ZZ4_NUM,ZZ4->ZZ4_CODCLI,ZZ4->ZZ4_LOJA,ZZ4->ZZ4_PRECAR,_aRetPsw[2])
		endif
	endif

	u_gjf28CRes(ZZ4->ZZ4_NUM)

	reclock('ZZ4',.f.)
	ZZ4->ZZ4_DTFIM  := date()
	ZZ4->ZZ4_HFIM   := time()
	ZZ4->ZZ4_STATUS := 'E'
	msunlock()

	if _lFal
		u_gjf31his('Pre-pedido ' + alltrim(ZZ4->ZZ4_NUM) + ' encerrado com falta',,_lFal)

		u_gjf31wfw(ZZ4->ZZ4_NUM,ZZ4->ZZ4_CODCLI,ZZ4->ZZ4_LOJA,ZZ4->ZZ4_PRECAR,_aRetPsw[2])
	else
		u_gjf31his('Pre-pedido ' + alltrim(ZZ4->ZZ4_NUM) + ' encerrado')
	endif

	msgbox('Pedido encerrado com sucesso!','OPERAÇÃO REALIZADA','INFO')

	If Select("ZZ5")<>0
		ZZ5->(dbCloseArea())
	Endif

return

Static Function atubrow()

	DbSelectArea('TMP')

	TMP->(DbGoTop())
	while TMP->(!eof())
		if alltrim(TMP->COD) = alltrim(ZZ5->ZZ5_COD)
			TMP->CREAL := ZZ5->ZZ5_QRCAIX
			TMP->PREAL := ZZ5->ZZ5_QRPESO
		endif
		TMP->(DbSkip())
	enddo
	TMP->(DbGoTop())

	/*TMP->(DbGoTop())
	while TMP->(!eof())
	if alltrim(TMP->COD) = alltrim(ZZ5->ZZ5_COD)
	exit
	endif
	TMP->(DbSkip())
	enddo */

return

Static Function montabrow(_Un)

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	aadd(aCampos,{"COD"    ,"Codigo  ",""})
	aadd(aCampos,{"DESCRI"   ,"Produto ",""})
	aadd(aCampos,{"CPREV"  ,"Caixa P.",""})
	aadd(aCampos,{"CREAL"  ,"Caixa R.",""})
	aadd(aCampos,{"PPREV"  ,"Peso P. ",""})
	aadd(aCampos,{"PREAL"  ,"Peso R. ",""})
	aadd(aCampos,{"PBREAL"  ,"Peso Brt. R. ",""})
	aadd(aCampos,{"PRIOR"  ,"Priorid.",""})
	aadd(aCampos,{"OBS"    ,"Observ. ",""})
	aadd(aCampos,{"RESERV" ,"Reserva?",""})
	aadd(aCampos,{"DTPINI" ,"Prod.Ini",""})
	aadd(aCampos,{"DTPFIM" ,"Prod.Fim",""})
	aadd(aCampos,{"PRDALT" ,"Prod.Alt",""})

	aStru := {}
	aadd(aStru,{"NUM"    , "C",  06, 0, })
	aadd(aStru,{"ITEM"   , "C",  03, 0, })
	aadd(aStru,{"COD"    , "C",  06, 0, })
	aadd(aStru,{"DESCRI"   , "C",  30, 0, })
	aadd(aStru,{"CPREV"  , "N",  04, 0, })
	aadd(aStru,{"CREAL"  , "N",  04, 0, })
	aadd(aStru,{"PPREV"  , "N",  10, 2, })
	aadd(aStru,{"PREAL"  , "N",  10, 2, })
	aadd(aStru,{"PBREAL" , "N",  10, 2, })
	aadd(aStru,{"PRIOR"  , "C",  10, 0, })
	aadd(aStru,{"OBS"    , "C",  60, 0, })
	aadd(aStru,{"RESERV" , "C",  03, 0, })
	aadd(aStru,{"DTPINI" , "D",  08, 0, })
	aadd(aStru,{"DTPFIM" , "D",  08, 0, })
	aadd(aStru,{"PRDALT" , "C",  06, 0, })

	/*
	aadd(aStru,{"NUM"    , "C",  06, 0,   "@!"          , 'Pre-Ped.'})
	aadd(aStru,{"ITEM"   , "C",  03, 0,   "@!"          , 'Item    '})
	aadd(aStru,{"COD"    , "C",  06, 0,   "@!"          , 'Codigo  '})
	aadd(aStru,{"DESCRI"   , "C",  30, 0,   "@!"          , 'Produto '})
	aadd(aStru,{"CPREV"  , "N",  04, 0,   "@E 9,999"    , 'Caixa P.'})
	aadd(aStru,{"CREAL"  , "N",  04, 0,   "@E 9,999"    , 'Caixa R.'})
	aadd(aStru,{"PPREV"  , "N",  10, 2,   "@E 9,999.99" , 'Peso P. '})
	aadd(aStru,{"PREAL"  , "N",  10, 2,   "@E 9,999.99" , 'Peso R. '})
	aadd(aStru,{"PBREAL" , "N",  10, 2,   "@E 9,999.99" , 'Peso Brt. R. '})
	aadd(aStru,{"PRIOR"  , "C",  10, 0,   "@!"          , 'Priorid.'})
	aadd(aStru,{"OBS"    , "C",  60, 0,   "@!"          , 'Observ. '})
	aadd(aStru,{"RESERV" , "C",  03, 0,   "@!"          , 'Reserva?'})
	aadd(aStru,{"DTPINI" , "D",  08, 0,   "99/99/9999"  , 'Prod.Ini'})
	aadd(aStru,{"DTPFIM" , "D",  08, 0,   "99/99/9999"  , 'Prod.Fim'})
	aadd(aStru,{"PRDALT" , "C",  06, 0,   "@!"          , 'Prod.Alt'})
	*/

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	_aArqTrb := {}
	If Select('TMP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	DbSelectArea('ZZ5')

	ZZ5->(dbsetorder(1))
	DbGoTop()
	ZZ5->(MsSeek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))

	While ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM
		if _Un = 'C'
			if !(GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+ZZ5->ZZ5_COD,1) $ 'CX/SC')
				ZZ5->(DbSkip())
				loop
			endif
		elseif _Un = 'P'
			if GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+ZZ5->ZZ5_COD,1) <> 'PC'
				ZZ5->(DbSkip())
				loop
			endif
		endif

		reclock('TMP',.t.)
		TMP->NUM   := ZZ5->ZZ5_NUM
		TMP->ITEM  := ZZ5->ZZ5_ITEM
		TMP->COD   := ZZ5->ZZ5_COD
		TMP->DESCRI:= ZZ5->ZZ5_DESC
		TMP->CPREV := ZZ5->ZZ5_QPCAIX
		TMP->CREAL := ZZ5->ZZ5_QRCAIX
		TMP->PPREV := ZZ5->ZZ5_QPPESO
		TMP->PREAL := ZZ5->ZZ5_QRPESO
		TMP->OBS   := ZZ5->ZZ5_OBS
		TMP->DTPINI:= ZZ5->ZZ5_DTPINI
		TMP->DTPFIM:= ZZ5->ZZ5_DTPFIM
		TMP->PRDALT:= ZZ5->ZZ5_PRDALT
		TMP->PBREAL:= ZZ5->ZZ5_QRPESB

		Do Case
			case ZZ5->ZZ5_PRIORI = 'A'
			TMP->PRIOR := 'AUTOMATICO'
			case ZZ5->ZZ5_PRIORI = 'P'
			TMP->PRIOR := 'PESO'
			case ZZ5->ZZ5_PRIORI = 'C'
			TMP->PRIOR := 'CAIXA'
		endcase

		if ZZ5->ZZ5_RESERV = 'S'
			TMP->RESERV := 'SIM'
		else
			TMP->RESERV := 'NAO'
		endif

		msunlock()
		ZZ5->(DbSkip())
	enddo
	TMP->(DbGotop())
Return

//CARREGAMENTO DE CAIXAS PROPRIAS
User Function gjf31cai(cAlias,nReg)
	//Local lOk 		 := .F.
	//Local aCposAlt	 := {}
	Private aHeader := {}
	Private aCols	 := {}
	Private nUsado	 :=	0
	Private campo   := space(11)
	Private valor   := space(11)
	Private mensOK := ''
	Private mensER := ''
	Private TotC := 0
	Private TotP := 0
	Private CarC := 0
	Private CarP := 0
	Private _lAlert := .f.
	Private aCampos := {}
	Private aStru   := {}
	Private cUsrReimp := getMV("SI_UETQUSA")
	_nModSeq := 1

	ZZ5->(dbsetorder(1))
	ZZ5->(Msseek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))

	dbSelectarea('SB1')
	while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ZZ4->ZZ4_NUM = ZZ5->ZZ5_NUM
		if GetAdvFVal("SB1","B1_SEGUM",FWxfilial("SB1")+ZZ5->ZZ5_COD,1) = "CX"
			TotC := TotC + ZZ5->ZZ5_QPCAIX
			TotP := TotP + ZZ5->ZZ5_QPPESO
			CarC := CarC + ZZ5->ZZ5_QRCAIX
			CarP := CarP + ZZ5->ZZ5_QRPESO

			if !empty(ZZ5->ZZ5_OBS)
				_lAlert := .t.
			endif

		endif
		ZZ5->(dbskip())
	enddo

	if !u_gjf31stt(1)                                                                 //Verifica e atualiza os status dos Pre-carregamentos
		return                                                                        //e dos pré-pedidos
	endif

	nUsado := gjf31head2(1)
	//Monta o aHeader para o grid
	gjf31col2(1)                                                                      //Monta o corpo das colunas do grif

	u_gjf31his('Acesso Pre-Ped. ' + ZZ4->ZZ4_NUM + ' carreg. caixas')

	if _lAlert
		alert('Existem observações nos itens do Pré-pedido!')
	endif

	montabrow('C')

	DEFINE MSDIALOG oEnc TITLE "Carregando..." from 0,0 To 580,580 OF oMainWnd PIXEL

	@ 05,02 To 80,290 Browse "TMP" fields aCampos object oBrow

	oCar  := MSGetDados():New (100,2,170,290,2,,,,.F.,,,.F.,,,,,,oEnc)

	@ 014,03   SAY  "Cod. Caixa:" OF oEnc
	@ 014,07   MSGET campo VAR valor SIZE 60,11 OF oEnc VALID validar(1)

	@ 014,25 say 'Sequencial:'
	oRadio 	   := TRadMenu():New(180,235,_aOpSeq,{|u| Iif(PCount()=0,_nModSeq,_nModSeq:=u)},oEnc,,{||ModSeq()},,,,,,100,40,,,,.T.)

	@ 019,03   SAY  "Total Caixas Carreg.: " +  transform(CarC,'@E 9,999') + "   de " + transform(TotC,'@E 9,999') OF oEnc
	oFont      := tFont():New("courier new",,-22,,.t.,,,,)
	oSayDesc1  := tSay():New(200,15,{|| mensOK },oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,250,30)
	oSayDesc2  := tSay():New(200,15,{|| mensER },oEnc,,oFont,,,,.T.,CLR_HRED,CLR_HRED,250,30)

	//campo:setfocus()
	oBrow:oBrowse:refresh()
	/*if cUserName $ cUsrReimp .and. GetAdvFVal('ZZ3','ZZ3_ISUSA',FWxfilial('ZZ3')+ZZ4->ZZ4_PRECAR,2) = 'S'
		@ 200,235  BUTTON 'Ship. Mark'   SIZE 40,15 ACTION EtqShipM(ZZ4->ZZ4_PRECAR, ZZ4->ZZ4_NUM) OBJECT oBtn5
	endif*/
	@ 220,235  BUTTON 'Consultar'   		SIZE 40,15 ACTION u_GJF108() OBJECT oBtn2
	@ 240,235  BUTTON 'Prod. Altern.'    	SIZE 40,15 ACTION prdAlt(TMP->NUM,TMP->ITEM,TMP->COD,TMP->PRDALT) 	 OBJECT oBtn3
	@ 260,235  BUTTON 'Pallets'        		SIZE 40,15 ACTION u_dti73(ZZ4->ZZ4_PRECAR, ZZ4->ZZ4_NUM) OBJECT oBtn4
	@ 280,235  BUTTON 'Sair'        		SIZE 40,15 ACTION oEnc:end() OBJECT oBtn1
	
	//TButton():New( 105, 005, "Pallets"    , oDlg,{|| u_dti73(ZZ3->ZZ3_NUM, aBrowse[oBrowse:nAt,02])  },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oEnc CENTERED VALID u_gjf31stt(2)                               //Ao fechar a janela da rotina, atualiza o status

	If Select("ZZ5")<>0
		ZZ5->(dbCloseArea())
	Endif
	If Select("SZ8")<>0
		SZ8->(dbCloseArea())
	Endif
	If Select("ZZ6")<>0
		ZZ6->(dbCloseArea())
	Endif

Return

Static Function prdAlt(_cNum, _cItem,_cProd,_cPrdAlt)

	if empty(_cPrdAlt)
		msgbox('Não há produto alternativo selecionado!','OPERAÇÃO INVÁLIDA!','STOP')
		return
	endif

	ZZ5->(dbSetOrder(1))
	if ZZ5->(MsSeek(FWxFilial('ZZ5') + _cNum + _cItem))

		if ZZ5->ZZ5_STATUS = 'E'
			msgbox('Item já atendido!!','OPERAÇÃO INVÁLIDA!','STOP')
			return
		endif

		if msgbox('Tem certeza que deseja utilizar o produto alternativo?','OPERAÇÃO DEFINITIVA!!','YESNO')

			//Backup dos valores da tabela
			_cCodPrd := ZZ5->ZZ5_COD
			_nPesR   := ZZ5->ZZ5_QRPESO
			_nCaixR  := ZZ5->ZZ5_QRCAIX
			_nPesP   := ZZ5->ZZ5_QPPESO
			_nCaixP  := ZZ5->ZZ5_QPCAIX
			_nPrc    := ZZ5->ZZ5_PRECO
			_cPriori := ZZ5->ZZ5_PRIORI
			_nTolera := ZZ5->ZZ5_TOLERA
			_cUserIn := ZZ5->ZZ5_USERIN
			_cTpBoni := ZZ5->ZZ5_TPBONI
			_nBonif  := ZZ5->ZZ5_BONIF
			_nPrcFin := ZZ5->ZZ5_PRCFIN
			_cObs    := ZZ5->ZZ5_OBS
			_cReserv := ZZ5->ZZ5_RESERV
			_dDtpIni := ZZ5->ZZ5_DTPINI
			_dDtpFim := ZZ5->ZZ5_DTPFIM
			_cTipCod := ZZ5->ZZ5_TIPCOD
			_cUsrAl  := ZZ5->ZZ5_USERAL
			_dDataAl := ZZ5->ZZ5_DATAAL
			_cHraAl  := ZZ5->ZZ5_HORAAL
			_nPminP  := ZZ5->ZZ5_PMINP
			_nPrcCli := ZZ5->ZZ5_PRCCLI
			_nSldPor := ZZ5->ZZ5_SLDPOR
			_cLote   := ZZ5->ZZ5_LOTE
			_cGPorc  := ZZ5->ZZ5_GPORC
			_cSolPro := ZZ5->ZZ5_SOLPRO
			_dDtsPor := ZZ5->ZZ5_DTSPOR

			_cItem := strzero(retItens(_cNum)+1,3)

			//se não houve nenhuma caixa carrega apenas altera o registro atual com o código do produto alternativo
			if _nPesR == 0 .or. _nCaixR == 0

				altPrdAlt(.t.,_cNum, _cItem,_cProd,_cPrdAlt)//altera produto alternativo

			else //senão encerra o item atual e cria um novo registro com os dados do produto alternativo

				altPrdAlt(.f.,_cNum, _cItem,_cProd,_cPrdAlt)//inclui produto alternativo

			endif

		endif

	endif

	oCar:refresh()                                               //As linhas abaixo servem para atualizar o grid
	oEnc:refresh()
	oBrow:oBrowse:refresh()
	TMP->(dbGoTOp())

return

//função para incluir ou alterar o produto alternativo
Static Function altPrdAlt(_lAlt,_cNum, _cItem,_cProd,_cPrdAlt) // altera produto alternativo

	if _lAlt //altera a linha

		reclock('ZZ5',.f.)
		ZZ5->ZZ5_COD      := _cPrdAlt
		ZZ5->ZZ5_DESC     := GetAdvFVal('SB1','B1_DESCRED',FWxFilial('SB1') + _cPrdAlt,1)
		ZZ5->ZZ5_PRDALT   := _cCodPrd
		msunlock()

		reclock('TMP',.f.)
		TMP->COD    := _cPrdAlt
		TMP->DESCRI   := GetAdvFVal('SB1','B1_DESCRED',FWxFilial('SB1') + _cPrdAlt,'B1_DESCRED',1)
		TMP->PRDALT := _cCodPrd
		msunlock()

	else //inclui uma linha nova

		reclock('ZZ5',.f.)
		ZZ5->ZZ5_STATUS 	:= 'E'
		ZZ5->ZZ5_QPPESO 	:= _nPesR
		ZZ5->ZZ5_QPCAIX 	:= _nCaixR
		msunlock()

		reclock('TMP',.f.)
		TMP->CPREV  := _nCaixR
		TMP->PPREV  := _nPesR
		msunlock()

		reclock('ZZ5',.t.)
		ZZ5->ZZ5_FILIAL  	:= FWxFilial('ZZ5')
		ZZ5->ZZ5_NUM     	:= _cNum
		ZZ5->ZZ5_ITEM    	:= _cItem
		ZZ5->ZZ5_COD     	:= _cPrdAlt
		ZZ5->ZZ5_QPCAIX 	:= (_nCaixP - _nCaixR)
		ZZ5->ZZ5_QPPESO 	:= (_nPesP  - _nPesR)
		ZZ5->ZZ5_PRECO   	:= _nPrc
		ZZ5->ZZ5_PRIORI  	:= _cPriori
		ZZ5->ZZ5_TOLERA 	:= _nTolera
		ZZ5->ZZ5_DESC    	:= GetAdvFVal('SB1','B1_DESCRED',FWxFilial('SB1') + _cPrdAlt,1)
		ZZ5->ZZ5_USERIN 	:= _cUserIn
		ZZ5->ZZ5_TPBONI 	:= _cTpBoni
		ZZ5->ZZ5_BONIF 	    := _nBonif
		ZZ5->ZZ5_PRCFIN 	:= _nPrcFin
		ZZ5->ZZ5_OBS 		:= _cObs
		ZZ5->ZZ5_RESERV 	:= _cReserv
		ZZ5->ZZ5_DTPINI     := _dDtpIni
		ZZ5->ZZ5_DTPFIM     := _dDtpFim
		ZZ5->ZZ5_TIPCOD 	:= _cTipCod
		ZZ5->ZZ5_USERAL 	:= _cUsrAl
		ZZ5->ZZ5_DATAAL 	:= _dDataAl
		ZZ5->ZZ5_HORAAL 	:= _cHraAl
		ZZ5->ZZ5_PMINP 	    := _nPminP
		ZZ5->ZZ5_PRCCLI 	:= _nPrcCli
		ZZ5->ZZ5_SLDPOR 	:= 0
		ZZ5->ZZ5_LOTE 		:= _cLote
		ZZ5->ZZ5_GPORC 	    := _cGPorc
		ZZ5->ZZ5_SOLPRO 	:= _cSolPro
		ZZ5->ZZ5_DTSPOR 	:= _dDtsPor
		ZZ5->ZZ5_PRECAR 	:= GetAdvFVal('ZZ4','ZZ4_PRECAR',FWxFilial('ZZ4') + _cNum,2)
		msunlock()

		reclock('TMP',.t.)
		TMP->NUM    := _cNum
		TMP->ITEM   := _cItem
		TMP->COD    := _cPrdAlt
		TMP->DESCRI   := GetAdvFVal('SB1','B1_DESCRED',FWxFilial('SB1') + _cPrdAlt,1)
		TMP->CPREV  := (_nCaixP - _nCaixR)
		TMP->CREAL  := 0
		TMP->PPREV  := (_nPesP  - _nPesR)
		TMP->PREAL  := 0
		TMP->OBS    := _cObs
		TMP->DTPINI := _dDtpIni
		TMP->DTPFIM := ZZ5->ZZ5_DTPFIM
		TMP->PRDALT := ''

		Do Case
			case ZZ5->ZZ5_PRIORI = 'A'
			TMP->PRIOR := 'AUTOMATICO'
			case ZZ5->ZZ5_PRIORI = 'P'
			TMP->PRIOR := 'PESO'
			case ZZ5->ZZ5_PRIORI = 'C'
			TMP->PRIOR := 'CAIXA'
		endcase

		if ZZ5->ZZ5_RESERV = 'S'
			TMP->RESERV := 'SIM'
		else
			TMP->RESERV := 'NAO'
		endif

		msunlock()
	endif
Return

Static Function retItens(_num)

	_cQry := " SELECT COUNT(ZZ5_NUM) AS ITEM
	_cQry += " FROM  " + retSqlTab('ZZ5')
	_cQry += " WHERE " + retSqlFil('ZZ5')
	_cQry += " AND ZZ5_NUM = '" + _num + "'"
	_cQry += " AND " + retSqlDel('ZZ5')

	_cQry := ChangeQuery(_cQry)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQry Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("ITM")<>0
		ITM->(dbCloseArea())
	Endif

	TCQUERY _cQry NEW ALIAS "ITM"

	ITM->(dbGoTop())

return ITM->ITEM

//CARREGAMENTO DE CAIXAS DE TERCEIROS
User Function gjf31ca3(cAlias,nReg)
	//Local lOk 		:= .F.
	//Local aCposAlt	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	 :=	0
	Private mod      := 0
	Private mensagem := ''

	Private cpo1     := space(06)
	Private valor1   := space(06)
	Private cpo2     := 0.00
	Private valor2   := 0.00
	Private cpo3     := 0.00
	Private valor3   := 0.00
	Private mens     := ''
	Private CarC     := 0

	Private aCampos := {}

	aadd(aCampos,{"ZZ5_COD"     ,"Cod",""})
	aadd(aCampos,{"ZZ5_DESC"    ,"Descricao   ",""})
	aadd(aCampos,{"ZZ5_QPCAIX"  ,"Caixas Prev.",""  })
	aadd(aCampos,{"ZZ5_QRCAIX"  ,"Caixas Real.",""  })
	aadd(aCampos,{"ZZ5_QPPESO"  ,"Peso Prev.  ",""})
	aadd(aCampos,{"ZZ5_QRPESO"  ,"Peso Real.  ",""})
	aadd(aCampos,{"ZZ5_PRIORI"  ,"Prioridade  ",""})

	_lFt := .t.

	ZZB->(dbsetorder(1))
	ZZB->(Msseek(FWxfilial('ZZB')+ZZ4->ZZ4_NUM))
	while ZZB->(!eof()) .and. ZZB->ZZB_FILIAL = FWxfilial('ZZB') .and. ZZ4->ZZ4_NUM = ZZB->ZZB_PREPED
		CarC++
		ZZB->(dbskip())
	enddo

	if !u_gjf31stt(1)																   		//Verifica e atualiza os status dos Pre-carregamentos
		return                                                               //e dos pre-pedidos
	endif
	//Monta o aHeader do grid
	nUsado := gjf31head2(2)                                                            //Monta o corpo das colunas

	gjf31col2(2)

	DbSelectArea('ZZ5')

	SET FILTER TO ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM .and.;
	ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ;
	(GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+ZZ5->ZZ5_COD,1) = 'CX' .or. ;
	GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+ZZ5->ZZ5_COD,1) = 'SC')
	dbsetorder(1)

	DEFINE MSDIALOG oEnc TITLE "Carregando..." from 0,0 To 580,580 OF oMainWnd PIXEL

	@ 05,02 To 80,290 Browse "ZZ5" fields aCampos object oBrow

	@ 014,03   SAY  "Codigo Prod.:"          OF oEnc
	@ 015,03   SAY  "Peso Bruto  :"          OF oEnc
	@ 016,03   SAY  "Peso Líquido:"          OF oEnc

	oCar := MSGetDados():New (100,2,170,290,2,,,,.F.,,,.F.,,,,,,oEnc)

	@ 014,10   MSGET cpo1 VAR valor1 SIZE 20,11    VALID validar(2)      F3 'SB1' OF oEnc
	@ 015,10   MSGET cpo2 VAR valor2 SIZE 35,11  PICTURE "@E 999,999.99" VALID iif(valor2 != 0,valor3 := valor2 - nTara,.t.)  OF oEnc
	@ 016,10   MSGET cpo3 VAR valor3 SIZE 35,11  PICTURE "@E 999,999.99"          OF oEnc

	//cpo3:disable()

	oFont      := tFont():New("courier new",,-22,,.t.,,,,)
	oSayDesc   := tSay():New(160,15,{|| mens },oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	@ 020,08   SAY  "Total Caixas Carreg.: " +  transform(CarC,'@E 9,999')
	@ 021,08   SAY  "Tara: " + transform(nTara,'@E 999.99') OF oEnc
	@ 021,14   SAY "[F4] Cap. Tara"
	@ 021,20   SAY "[F3] Tara Manual"

	//cpo2:setfocus()
	@ 250,005  BUTTON 'Capturar'    SIZE 40,15 ACTION Cap3()        OBJECT oBt1
	@ 270,005  BUTTON 'Confirmar'   SIZE 40,15 ACTION Cop3()        OBJECT oBt2
	@ 230,240  BUTTON 'Consultar'   SIZE 40,15 ACTION u_gjf31Con()  OBJECT oBt3
	@ 250,240  BUTTON 'Excluir'     SIZE 40,15 ACTION ExCarga(n,2)  OBJECT oBt4
	@ 270,240  BUTTON 'Sair'        SIZE 40,15 ACTION oEnc:end()    OBJECT oBt5

	ACTIVATE MSDIALOG oEnc CENTERED VALID u_gjf31stt(2)                              //Atualiza os status no momento do fechamento da rotina

	If Select("ZZ5")<>0
		ZZ5->(dbCloseArea())
	Endif
	If Select("ZZ8")<>0
		ZZ8->(dbCloseArea())
	Endif
	If Select("ZZB")<>0
		ZZB->(dbCloseArea())
	Endif

Return

//CARREGAMENTO DE PEÇAS
User Function gjf31pec(cAlias,nReg)
	//Local lOk 		:= .F.
	//Local aCposAlt	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private campo1    := space(23)
	Private valor1    := space(23)
	Private campo2    := space(06)
	Private valor2    := space(06)
	Private campo3    := 000
	Private valor3    := 0
	Private _nValAux  := 0
	Private campo4    := 0.00
	Private valor4    := 0.00
	Private campo5    := 0.00
	Private valor5    := 0.00
	Private mens      := ''
	Private comboPro  := {""}
	Private TotPec    := 0
	Private CarPec    := 0
	Private TotPeso   := 0
	Private CarPeso   := 0
	Private _cRastro  := ''
	Private _cLado    := ''
	Private _lAlert   := .f.
	Private aCampos   := {}
	Private aStru     := {}

	ZZ5->(dbsetorder(1))
	ZZ5->(Msseek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
	while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ZZ4->ZZ4_NUM = ZZ5->ZZ5_NUM
		if GetAdvFVal("SB1","B1_SEGUM",FWxfilial("SB1")+ZZ5->ZZ5_COD,1) = "PC"
			aadd(comboPro,alltrim(ZZ5->ZZ5_COD))
			TotPec  := TotPec + ZZ5->ZZ5_QPCAIX
			TotPeso := TotPeso + ZZ5->ZZ5_QPPESO
			CarPec  := CarPec + ZZ5->ZZ5_QRCAIX
			CarPeso := TotPeso + ZZ5->ZZ5_QRPESO

			if !empty(ZZ5->ZZ5_OBS)
				_lAlert := .t.
			endif
		endif
		ZZ5->(dbskip())
	enddo

	if !u_gjf31stt(1)
		return                                                                        //Verifica e atualiza os status dos pre-pedidos e
	endif                                                                             //e pre-carregamentos

	nUsado := gjf31head2(3)                                                           //Monta o aHeader do grid da rotina

	gjf31col2(3)                                                                      //Monta o aCols do header da rotina

	u_gjf31his('Acesso Pre-Ped. ' + ZZ4->ZZ4_NUM + ' carreg. peças')

	if _lAlert
		alert('Existem obervações nos itens do Pré-pedido!')
	endif

	montabrow('P')
	_lFt := .t.
	_cMensScn := ' '

	DEFINE MSDIALOG oEnc TITLE "Carregando..." from 0,0 To 580,580 OF oMainWnd PIXEL

	@ 05,02 To 80,290 Browse "TMP" fields aCampos object oBrow

	oCar := MSGetDados():New(100,2,170,290,2,,,,.F.,,,.F.,,,,,,oEnc)

	@ 015,16   SAY  _cMensScn                OF oEnc
	@ 016,16   SAY  "Quant. :"               OF oEnc
	@ 016,03   SAY  "Peso Bruto  :"          OF oEnc
	@ 017,03   SAY  "Peso Líquido:"          OF oEnc
	@ 020,11   SAY  "Total Peças Carreg.: " +transform(CarPec,'@E 9,999') + "   de " + Transform(TotPec,'@E 9,999')
	@ 021,11   SAY  "Tara: " + transform(nTara,'@E 999.99') OF oEnc
	@ 021,17   SAY "[F4] Cap. Tara"
	@ 021,23   SAY "[F3] Tara Manual" //gjf31T()

	@ 016,18   MSGET campo3 VAR valor3 SIZE 12,11  PICTURE "@E 999"   VALID ValInp() OF oEnc
	@ 016,10   MSGET campo4 VAR valor4 SIZE 25,11  PICTURE "@E 999.99" VALID iif(valor3 != 0,;
	valor5 := valor4 - nTara,.t.) OF oEnc                               //Calculo do peso líquido
	@ 017,10   MSGET campo5 VAR valor5 SIZE 25,11  PICTURE "@E 999.99"   OF oEnc

	campo4:disable()
	campo5:disable()

	oFont      := tFont():New("courier new",,-22,,.t.,,,,)
	oSayDesc   := tSay():New(160,15,{|| mens },oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)

	//campo3:setfocus()
	@ 250,005  BUTTON 'Escanear'    SIZE 40,15 ACTION Escanear()     OBJECT oBtn8
	@ 270,005  BUTTON 'Capturar'    SIZE 40,15 ACTION CaPeca()       OBJECT oBtn7
	@ 250,240  BUTTON 'Excluir'     SIZE 40,15 ACTION ExCarga(n,3)   OBJECT oBtn9
	@ 270,240  BUTTON 'Sair'        SIZE 40,15 ACTION oEnc:end()     OBJECT oBtn10

	ACTIVATE MSDIALOG oEnc CENTERED VALID u_gjf31stt(2)                               //A fechar a tela atualiza os status

	If Select("ZZ5")<>0
		ZZ5->(dbCloseArea())
	Endif
	If Select("ZZ2")<>0
		ZZ2->(dbCloseArea())
	Endif
	If Select("ZZA")<>0
		ZZA->(dbCloseArea())
	Endif

Return

//Essa função serve para montar o aCols da rotina de alteração das quantidades
static Function gjf31col1(nOpc)
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
		Do While ZZ5->(!Eof()) .and.;
		FWxFilial('ZZ5') ==  ZZ5->ZZ5_FILIAL .and.;
		ZZ5->ZZ5_NUM == ZZ4->ZZ4_NUM
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
			DbSkip()
		Enddo
	Endif
Return

//Essa função serve para montar o aCols da rotina de carregamento
static Function gjf31col2(mod)
	Local nI//, nPos
	do case
		case mod = 1                                                                 //Para montar o aCols das caixas próprias
		RegToMemory("ZZ4")

		dbSelectArea("ZZ6")
		ZZ6->(dbSetOrder(2))
		if ZZ6->(MsSeek(FWxFilial('ZZ6')+ZZ4->ZZ4_NUM,.t.))
			//Do While ZZ6->(!Eof()) .and. ZZ6->ZZ6_FILIAL = FWxfilial('ZZ6')
			while ZZ6->(!eof()) .and. ZZ6->ZZ6_FILIAL = FWxFilial('ZZ6') .and. ZZ6->ZZ6_PREPED == ZZ4->ZZ4_NUM
				if ZZ6->ZZ6_PREPED != ZZ4->ZZ4_NUM
					ZZ6->(dbskip())
					loop
				endif
				aAdd(aCols,Array(nUsado+1))

				For nI := 1 to nUsado
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Next nI

				aCols[Len(aCols),nUsado+1] := .F.

				ZZ6->(DbSkip())

			Enddo
		endif
		case mod = 2                                                                  //Para montar o aCols das caixas de terceiros
		ZZB->(dbSetOrder(2))
		if ZZB->(MsSeek(FWxFilial('ZZB') + alltrim(ZZ4->ZZ4_NUM),.t.))
			ord := 1
			while ZZB->(!eof()) .and. ZZB->ZZB_FILIAL = FWxfilial('ZZB') .and. ZZB->ZZB_PREPED == ZZ4->ZZ4_NUM
				reclock('ZZB',.f.)
				ZZB->ZZB_NUM := strzero(ord,3)
				msunlock()
				ord++
				ZZB->(dbskip())
			enddo
			if ZZB->(MsSeek(FWxFilial('ZZB') + ZZ4->ZZ4_NUM,.T.))
				Do While ZZB->(!eof()) .and. ZZB->ZZB_FILIAL = FWxfilial('ZZB') .and. ZZB->ZZB_PREPED == ZZ4->ZZ4_NUM
					aAdd(aCols,Array(nUsado+1))
					For nI := 1 to nUsado
						aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
					Next nI
					aCols[Len(aCols),nUsado+1] := .F.
					ZZB->(DbSkip())
				enddo
			endif

			ZZ8->(dbSetOrder(2))
			if ZZ8->(MsSeek(FWxFilial('ZZ8')+alltrim(ZZ4->ZZ4_NUM),.t.))
				ord := 1
				while ZZ8->(!eof()) .and. ZZ8->ZZ8_FILIAL = FWxfilial('ZZ8') .and. ZZ8->ZZ8_PREPED == ZZ4->ZZ4_NUM
					reclock('ZZ8',.f.)
					ZZ8->ZZ8_NUM := strzero(ord,3)
					msunlock()
					ord++
					ZZ8->(dbskip())
				enddo
			endif
		endif

		case mod = 3                                                                  //Para montar o aCols das peças carregadas
		dbSelectArea("ZZA")
		ZZA->(dbSetOrder(1))
		if ZZA->(MsSeek(FWxFilial('ZZA')+alltrim(ZZ4->ZZ4_NUM),.t.))
			ord := 1
			ZZA->(dbSetOrder(2))
			ZZA->(MsSeek(FWxFilial('ZZA') + alltrim(ZZ4->ZZ4_NUM),.t.))
			while ZZA->(!eof()) .and. ZZA->ZZA_FILIAL = FWxfilial('ZZA') .and. ZZA->ZZA_PREPED == ZZ4->ZZ4_NUM

				reclock('ZZA',.f.)
				ZZA->ZZA_NUM := strzero(ord,3)
				msunlock()
				ord++
				ZZA->(dbskip())
			enddo
			if ZZA->(MsSeek(FWxFilial('ZZA') + ZZ4->ZZ4_NUM,.t.))
				Do While ZZA->(!eof()) .and. ZZA->ZZA_FILIAL = FWxfilial('ZZA') .and. ZZA->ZZA_PREPED == ZZ4->ZZ4_NUM
					aAdd(aCols,Array(nUsado+1))
					For nI := 1 to nUsado
						aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
					Next nI
					aCols[Len(aCols),nUsado+1] := .F.
					ZZA->(DbSkip())
				enddo
			endif
		endif

		ZZ2->(dbSetOrder(1))
		if ZZ2->(MsSeek(FWxFilial('ZZ2')+alltrim(ZZ4->ZZ4_NUM),.t.))
			ord := 1
			ZZ2->(dbSetOrder(2))
			ZZ2->(MsSeek(FWxFilial('ZZ2') + ZZ4->ZZ4_NUM,.t.))
			while ZZ2->(!eof()) .and. ZZ2->ZZ2_FILIAL = FWxfilial('ZZ2') .and. ZZ2->ZZ2_PREPED = ZZ4->ZZ4_NUM
				reclock('ZZ2',.f.)
				ZZ2->ZZ2_NUM := strzero(ord,3)
				msunlock()
				ord++
				ZZ2->(dbskip())
			enddo
		endif

	endcase
Return

static function execsom()                                                           //Serve para executar o som ao ler caixa ou peça
	do case
		case mv_par02 == 1
			if !('HTML' $ u_remoteType())
				WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)
			else
				WINEXEC(cTempPath + cExecWeb + ' /play /close /embedding ' + cTempPath + 'GE.WAV',0)
			endif
		case mv_par02 == 2
			if !('HTML' $ u_remoteType())
				WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE2.WAV',0)
			else
				WINEXEC(cTempPath + cExecWeb + ' /play /close /embedding ' + cTempPath + 'GE2.WAV',0)
			endif
		case mv_par02 == 3
			if !('HTML' $ u_remoteType())
				WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE3.WAV',0)
			else
				WINEXEC(cTempPath + cExecWeb + ' /play /close /embedding ' + cTempPath + 'GE3.WAV',0)
			endif
	endcase	
return

Static Function SomErr()
	if !('HTML' $ u_remoteType())
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
	else
		WINEXEC(cTempPath + cExecWeb + ' /play /close /embedding ' + cTempPath + 'GEER.WAV',0)
	endif
return

Static Function SomErr2()
	if !('HTML' $ u_remoteType())
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEEDT.WAV',0)
	else
		WINEXEC(cTempPath + cExecWeb + ' /play /close /embedding ' + cTempPath + 'GEEDT.WAV',0)
	endif
return

Static Function SomErr3()
	if !('HTML' $ u_remoteType())
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\TF050.WAV',0)
	else
		WINEXEC(cTempPath + cExecWeb + ' /play /close /embedding ' + cTempPath + 'TF050.WAV',0)
	endif
return

//Função para calcular o peso medio por caixa e o peso medio a produzir
User Function gjf31pmc()
	pmedio := 0
	prod 	:= GDFieldGet('ZZ5_COD',n)
	SB1->(dbsetorder(1))
	if SB1->(Msseek(FWxfilial('SB1')+prod))
		pmc    := SB1->B1_PMCAIX
		pmedio := (M->ZZ5_QPCAIX * pmc)
	endif
return pmedio

//Função inversa a de cima
User Function gjf31cmp()
	caixas := 0
	prod   := GDFieldGet('ZZ5_COD',n)
	peso   := M->ZZ5_QPPESO

	SB1->(dbsetorder(1))

	if SB1->(Msseek(FWxfilial('SB1')+prod))
		cmp   := SB1->B1_PMCAIX
		ncaix := round(peso/cmp,0)
		return ncaix
	endif

return caixas

Static Function newCapBal()

	local _nTam     := getMv('SI_QTPESXP')//parametro com valor total de strings de peso a serem armazenadas para tratamento
	local _nMS      := getMV('SI_QTMSXP') //parametro com a velocidade em milissegundos para capturas de peso
	//local _nStrOk   := 0
	local aStrings  := {}
	local aPesos    := {}
	local nPeso 	:= 0
	local _nMaior   := 0
	local _nCont    := 0
	local cPeso     := ""
	local cC        := ""
	local _cBuffer  := ""
	//local _nPesosOk := 0
	local i
	local j
	local _cEst 	:= getComputerName()
	local _nCDec 	:= 0
	valor4 := 0

	if _cEst $ cCDec1
		_nCDec := 1
	elseif _cEst $ cCDec2
		_nCDec := 2
	endif

	conectBal()

	//bloco que armazena as strings que tiverem o peso estável
	for i:=1 to _nTam//bloco para multiplcas capturas
		_cBuffer := ""
		nQtd 	 = oObj:Receive( _cBuffer, _nMS )
		if ("ph" $ alltrim(_cBuffer)) .or. ("p`" $ alltrim(_cBuffer)) //SE TIVER "PH" NA STRING QUER DIZER QUE É UM PESO ESTAVEL			
			aAdd(aStrings,_cBuffer)
		endif
	next

	//verifica se o buffer não esta sendo retornado em branco, caso esteja reconecta na balança
	//if empty(_cBuffer)
	//	conectBal()
	//endif

	//bloco para tratamento das strings com peso estável
	for i:= 1 to len(aStrings)
		do Case
			Case at("ph",aStrings[i])> 0
			cPeso := substr(aStrings[i],at("ph",aStrings[i])+2,6)
			cC := "h"
			Case at("p`",aStrings[i])> 0						
			cPeso := substr(aStrings[i],at("p`",aStrings[i])+2,6)			
			cC := "`"
			Case at("h",aStrings[i]) > 0
			cPeso := substr(aStrings[i],at("h",aStrings[i])+1,6)
			cC := "h"
			Case at("p ",aStrings[i])> 0
			cPeso := substr(aStrings[i],at("p ",aStrings[i])+2,6)
			cC := " "
			Otherwise
			cPeso :='000000'
			cC := ""
		Endcase

		cPeso := substr(aStrings[i],at("`",aStrings[i])+1,6)				
		cPeso := substr(aStrings[i],at(cC,aStrings[i])+1,6)
		nPeso := val(cPeso)/(10**_nCDec)
		if nPeso > 0 //adiciona no vetor de pesos ok somente pesos acima de zero
			aAdd(aPesos,nPeso)
		endif
	next

	//bloco para tratamento de incidencias, ou seja, utiliza somente o peso que tiver mais incidencias dentro do vetor
	for i:= 1 to len(aPesos)//_nPesosOk
		//alert(aPesos[i])
		_nCont := 0
		for j:=1 to len(aPesos)//_nPesosOk
			if aPesos[i] == aPesos[j]
				_nCont++
			endif
		next

		if _nCont > _nMaior
			nPeso   := aPesos[i]
			_nMaior := _nCont
		endif
	next

	oObj:CloseConnection()
	//alert('Peso da balanca: '+ transform(nPeso,'@E 999.99'))

	//alert(nPeso)

return nPeso

//Função para capturar o peso
Static Function capbal()

	local _cEst 	:= getComputerName()
	local _nCDec 	:= 0

	if _cEst $ cCDec1
		_nCDec := 1
	elseif _cEst $ cCDec2
		_nCDec := 2
	endif

	nHdll := 0

	if !MSOpenPort(nHdll,mv_par03)
		msgbox("Não foi possível pegar informações da porta!",,"STOP")
		lOk := .f.
		Return 0
	endif

	cText := space(15)
	if !MsRead(nHdll,@cText)
		msgbox("Não foi possível pegar informações da porta!",,"STOP")
		lOk := .f.
		Return 0
	endif

	inkey(1)
	if empty(cText)
		inkey(1)
		cText := space(15)
		MsRead(nHdll,@cText)
	endif

	do Case
		Case at("p`",cText)> 0
		cPeso := substr(cText,at("p`",cText)+2,6)
		cC := "`"

		Case at("`",cText) > 0
		cPeso := substr(cText,at("`",cText)+1,6)
		cC := "`"

		Case at("p ",cText)> 0
		cPeso := substr(cText,at("p ",cText)+2,6)
		cC := " "

		Otherwise
		cPeso :='000000'
		cC := ""
	Endcase

	cPeso := substr(cText,at("`",cText)+1,6)
	cPeso := substr(cText,at(cC,cText)+1,6)

	nPeso := val(cPeso)/(10**_nCDec)

	if valtype(nPeso) == 'N'
		v := npeso
	else
		v     := 0
		nPeso := 0
	endif
	msClosePort(nHdll)
	lOk := .t.
Return nPeso

//Função para captura na balança das pesagens das peças
static function CaPeca()
	if valor3 = 0
		alert('ERRO')
		return .f.
	endif

	if valor4 = 0
		//valor4 := digitaPeso()//capbal() //putamerda
		valor4 := newCapBal()
		//valor4 := 34.00
		if valor4 <= 0
			alert('ERRO')
		else
			valor5 := valor4 - nTara
		endif
	else
		valor5 := valor4 - nTara
	endif

	if msgbox(transform(valor4,'@E 999.99'),'CONFIRMA? (S/N)','YESNO')
		CoPeca()
		valor5 := 0
		valor4 := 0
	else
		return
	endif

return .t.

Static Function digitaPeso()

	Local _nPeso := 0

	DEFINE MSDIALOG oDlg2 TITLE 'Peso da Caixa' from 000,000 To 100,250 PIXEL
	@ 010,002 SAY  'Peso Caixa:' Object oSayPes
	@ 010,035 GET _nPeso PICTURE "@E 999.99" SIZE 30,6  VALID !empty(_nPeso) .and. _nPeso > 0 Object oGet2
	@ 010,95 BMPBUTTON TYPE 1 ACTION (_lOk := .t.,odlg2:end()) Object ObtnPes1
	@ 025,95 BMPBUTTON TYPE 2 ACTION odlg2:end() Object ObtnPes2
	ACTIVATE MSDIALOG oDlg2 CENTERED

return _nPeso

//Função para a confirmação das pesagens e carregamentos das peças
Static Function CoPeca()
	Local _cCOri := ''
	//Local _cPrecar := ''

	area := getarea()
	ZZ5->(MsSeek(FWxfilial('ZZ5')+TMP->(NUM+ITEM)))

	if ZZ5->ZZ5_STATUS = 'E'
		SomErr()
		msgbox('Item de Pré-pedido já encerrado!','OPERAÇAO IRREGULAR!','STOP')
		return
	endif

	nPedItem  := ZZ5->(ZZ5_NUM + ZZ5_ITEM)

	valor2 := alltrim(ZZ5->ZZ5_COD)

	if  empty(valor3) .or. empty(valor4)
		msgbox('Existem campos em branco!','OPERAÇAO IRREGULAR!','STOP')
		return
	endif

	if valor4 < valor5 .or. valor4 < 0 .or. valor5 <= 0
		msgbox('Valores incorretos','OPERAÇAO IRREGULAR!','STOP')
		return
	endif

	DbSelectArea('SB1')
	prod   := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+alltrim(valor2),1)
	_Scan  := GetAdvFVal('SB1','B1_SCAN',FWxfilial('SB1')+alltrim(valor2),1)
	_PMax  := GetAdvFVal('SB1','B1_PESMAX',FWxfilial('SB1')+alltrim(valor2),1)
	_cCOri := GetAdvFVal('SB1','B1_CORORI',FWxfilial('SB1')+alltrim(valor2),1)
	_PM    := valor5/valor3 //Peso médio da peça carregada

	ord := 1

	If Select('TMP2') = 0 .and. _Scan = 'S'
		SomErr()
		msgbox('Leitura obrigatória por Scanner!','OPERAÇAO IRREGULAR!','STOP')
		Return
	endif

	if _cCOri = 'E'  //Tratamento especial para quando for meia-res
		_ND := 0
		_NT := 0
		_NC := 0
		If Select('TMP2') <> 0
			if TMP2->(RecCount()) <> 0  .and. TMP2->ZAJ_COD = alltrim(valor2) //Se um tmp com alias TMP2 existir,
				TMP2->(DbGoTop())
				while TMP2->(!eof())
					if TMP2->ZAJ_CORORI = 'D'
						_ND++
					elseif TMP2->ZAJ_CORORI = 'T'
						_NT++
					elseif TMP2->ZAJ_CORORI = 'C'
						_NC++
					endif
					TMP2->(DbSkip())
				enddo
			else
				DbCloseArea()
			endif
		Else
			DbSelectArea('TMP')
		Endif
		if  _ND <> _NT .or. _ND <> _NC .or. _NT <> _NC   //Verifica se a meia-rez teve partes escaneadas em numero diferente uma da outra
			SomErr()
			msgbox('Inconsistencia na leitura das partes!','OPERAÇAO IRREGULAR!','STOP')
			valor3 := 0
			TMP2->(DbCloseArea())
			return
		endif
		valor3 := valor3/3
	endif

	if _cCOri = 'P'  //Tratamento especial para quando for traseiro capote
		_NT := 0
		_NC := 0
		If Select('TMP2') <> 0
			if TMP2->(RecCount()) <> 0  .and. TMP2->ZAJ_COD = alltrim(valor2) //Se um tmp com alias TMP2 existir,
				TMP2->(DbGoTop())
				while TMP2->(!eof())
					if TMP2->ZAJ_CORORI = 'T'
						_NT++
					elseif TMP2->ZAJ_CORORI = 'C'
						_NC++
					endif
					TMP2->(DbSkip())
				enddo
			else
				DbCloseArea()
			endif
		Else
			DbSelectArea('TMP')
		Endif
		if  _NT <> _NC   //Verifica se o traseiro capote teve partes escaneadas em numero diferente uma da outra
			SomErr()
			msgbox('Inconsistencia na leitura das partes!','OPERAÇAO IRREGULAR!','STOP')
			valor3 := 0
			TMP2->(DbCloseArea())
			return
		endif
		valor3 := valor3/2
	endif

	if _PM > _PMax
		SomErr()
		msgbox('Peso máximo por peça incorreto!','OPERAÇAO IRREGULAR!','STOP')
		return
	endif

	//Validação apenas para verficiar a tolerancia caso a prioridade de carregamento seja por peso
	if ZZ5->ZZ5_PRIORI = 'P' .and. (ZZ5->ZZ5_QRPESO + valor5) > (ZZ5->ZZ5_QPPESO * (1 + (ZZ5->ZZ5_TOLERA * 0.01)))
		SomErr()
		msgbox('Excedeu pesagem para carga!','TOLERANCIA ULTRAPASSADA!','STOP')
		return
	endif

	//Validação apenas para verficiar a tolerancia caso a prioridade de carregamento seja por caixa
	if ZZ5->ZZ5_PRIORI = 'C' .and. (ZZ5->ZZ5_QRCAIX + valor3) > (ZZ5->ZZ5_QPCAIX * (1 + (ZZ5->ZZ5_TOLERA * 0.01)))
		SomErr()
		msgbox('Excedeu quantidade para carga!','TOLERANCIA ULTRAPASSADA!','STOP')
		return
	endif

	If Select('TMP2') <> 0
		TMP2->(DbGoTop())
		if TMP2->(RecCount()) = 0 .or. TMP2->ZAJ_COD <> alltrim(valor2)            //Se um tmp com alias TMP2 existir,
			SomErr()
			Alert('Houve troca de codigo entre a leitura das carcaças e a pesagem. Leitura descartada!')
			DbCloseArea()
			valor3 := 0
			Return
		endif
	Else
		DbSelectArea('TMP')
	Endif

	dbSelectArea('ZAA')
	ZZA->(dbsetorder(2))
	if ZZA->(Msseek(FWxfilial()+ZZ5->ZZ5_NUM + '001'))
		reclock('ZZA',.f.)
		while ZZA->(!eof()) .and. ZZA->ZZA_FILIAL = FWxfilial('ZZA') .and. ZZA->ZZA_PREPED == ZZ5->ZZ5_NUM
			ZZA->ZZA_NUM := strzero(ord,3)
			ord++
			ZZA->(dbskip())
		enddo
		msunlock()
	endif

	do case
		case ZZ5->ZZ5_PRIORI = 'P'

			//Este bloco já foi escrito ali em cima, mas deixa repetir, tava funcionando...
			if ZZ5->ZZ5_QRPESO + valor5 > (ZZ5->ZZ5_QPPESO * (1 + (ZZ5->ZZ5_TOLERA * 0.01)))
				SomErr()
				msgbox('Excedeu pesagem para carga!','TOLERANCIA ULTRAPASSADA!','STOP')
				return
			endif

			//Caso a prioridade do carregamento seja por peso,...

			if ZZ5->ZZ5_QRPESO + valor5 >= ZZ5->ZZ5_QPPESO .and. ZZ5->ZZ5_QRPESO <= ZZ5->ZZ5_QPPESO + (ZZ5->ZZ5_QPPESO * 0.10)
				reclock('ZZ5',.f.)
				ZZ5->ZZ5_STATUS := 'E'
				msunlock()
				atendido := .t.
			endif
			reclock('ZZ5',.f.)
			ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO + valor5
			ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB + valor4
			ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX + valor3
			atendido := .f.
			msunlock()

		case ZZ5->ZZ5_PRIORI = 'A'                                    //Caso a prioridade de carregamento seja automatica...
			reclock('ZZ5',.f.)
			ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO + valor5
			ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB + valor4
			ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX + valor3
			atendido := .f.
			if (ZZ5->ZZ5_QRPESO >= ZZ5->ZZ5_QPPESO) .or. (ZZ5->ZZ5_QRCAIX >= ZZ5->ZZ5_QPCAIX)
				ZZ5->ZZ5_STATUS := 'E'                                      //Verifica as quantidades do PP para encerra-lo
				atendido := .t.
			endif
		msunlock()

		case ZZ5->ZZ5_PRIORI = 'C'                                    //Caso a prioridade de carregamento seja por caixa
			reclock('ZZ5',.f.)
			ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO + valor5
			ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB + valor4
			ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX + valor3
			atendido := .f.
			if ZZ5->ZZ5_QRCAIX >= ZZ5->ZZ5_QPCAIX
				ZZ5->ZZ5_STATUS := 'E'
				atendido := .t.
			endif
			msunlock()
	endcase

	atubrow()

	reclock('ZZA',.t.)
	ZZA->ZZA_FILIAL := FWxfilial('ZZA')
	ZZA->ZZA_NUM    := strzero(ord,3)
	ZZA->ZZA_DATAC  := date()
	ZZA->ZZA_HORAC  := time()
	ZZA->ZZA_PREPED := ZZ5->ZZ5_NUM
	ZZA->ZZA_ITEM   := ZZ5->ZZ5_ITEM
	ZZA->ZZA_COD    := alltrim(valor2)
	ZZA->ZZA_QUANT  := valor3
	ZZA->ZZA_DESCRI := prod
	ZZA->ZZA_PESOB  := valor4
	ZZA->ZZA_TARA   := nTara
	ZZA->ZZA_PESOL  := valor5
	ZZA->ZZA_PRECAR := ZZ4->ZZ4_PRECAR
	ZZA->ZZA_LADO   := _cLado
	msunlock()

	_nPesoBM := valor4/valor3
	_nPesoLM := valor5/valor3

	If Select('TMP2') <> 0 .and. TMP2->(RecCount()) <> 0
		if TMP2->ZAJ_COD <> alltrim(valor2)
			DbCloseArea()
		endif
	endif

	reclock('ZZ2',.t.)
	ZZ2->ZZ2_FILIAL := FWxfilial('ZZ2')
	ZZ2->ZZ2_NUM    := strzero(ord,3)
	ZZ2->ZZ2_DATAC  := date()
	ZZ2->ZZ2_HORAC  := time()
	ZZ2->ZZ2_PREPED := ZZ5->ZZ5_NUM
	ZZ2->ZZ2_ITEM   := ZZ5->ZZ5_ITEM
	ZZ2->ZZ2_PRECAR := ZZ4->ZZ4_PRECAR
	ZZ2->ZZ2_COD    := alltrim(valor2)
	ZZ2->ZZ2_QUANT  := valor3
	ZZ2->ZZ2_DESCRI := prod
	ZZ2->ZZ2_PESOB  := valor4
	ZZ2->ZZ2_TARA   := nTara
	ZZ2->ZZ2_PESOL  := valor5
	ZZ2->ZZ2_LADO   := _cLado
	msunlock()

	SZ2->(DbSetOrder(2))
	_cPredes := ""

	If Select('TMP2') <> 0 .and. TMP2->(RecCount()) <> 0
		TMP2->(DbGoTop())
		While TMP2->(!eof())
			ZAJ->(DbSetOrder(2))
			if ZAJ->(MsSeek(FWxfilial('ZAJ')+TMP2->ZAJ_NUM))

				//_nPesoBM := valor4/valor3
				//_nPesoLM := valor5/valor3

				_SITras := _GetPar1()
				_nPercTras := _SITras
				_SIDian := _GetPar2()
				_nPercDian := _SIDian
				_SICost := _GetPar3()
				_nPercCost := _SICost
				//_nPercCapo := GETMV('SI_%CAPO')

				if _cCOri = 'E'
					if ZAJ->ZAJ_CORORI = 'T'
						_nPesoBM := (valor4 * _nPercTras)/valor3
						_nPesoLM := (valor5 * _nPercTras)/valor3
					elseif ZAJ->ZAJ_CORORI = 'D'
						_nPesoBM := (valor4 * _nPercDian)/valor3
						_nPesoLM := (valor5 * _nPercDian)/valor3
					else
						_nPesoBM := (valor4 * _nPercCost)/valor3
						_nPesoLM := (valor5 * _nPercCost)/valor3
					endif
				elseif _cCOri = 'P'

					/*_nValPercC := (_nPercCost * 100)/_nPercTras  //% da costela num traseiro capote
					_nValPercT := 100 - _nValPercC               //% do traseiro num traseiro capote

					if ZAJ->ZAJ_CORORI = 'T'
					_nPesoBM := (valor4 * _nValPercT)/valor3
					_nPesoLM := (valor5 * _nValPercT)/valor3
					elseif ZAJ->ZAJ_CORORI = 'C'
					_nPesoBM := (valor4 * _nValPercC)/valor3
					_nPesoLM := (valor5 * _nValPercC)/valor3
					endif
					*/

					if ZAJ->ZAJ_CORORI = 'T'
						_nPesoBM := (valor4 * _nPercTras)/valor3
						_nPesoLM := (valor5 * _nPercTras)/valor3
					elseif ZAJ->ZAJ_CORORI = 'C'
						_nPesoBM := (valor4 * _nPercCost)/valor3
						_nPesoLM := (valor5 * _nPercCost)/valor3
					endif

				endif

				_cCodPa := GetAdvFVal('ZZ5','ZZ5_COD',FWxFilial('ZZ5') + TMP2->ZAJ_PREPED + TMP2->ZAJ_ITEM,1)
				_cPredes := ZAJ->ZAJ_PREDES

				reclock('ZAJ',.f.)
				ZAJ->ZAJ_PRECAR  := TMP2->ZAJ_PRECAR
				ZAJ->ZAJ_PREPED  := TMP2->ZAJ_PREPED
				ZAJ->ZAJ_ITEM    := TMP2->ZAJ_ITEM
				ZAJ->ZAJ_PREDES  := ""
				ZAJ->ZAJ_DATAS   := TMP2->ZAJ_DATAS
				ZAJ->ZAJ_HORAS   := TMP2->ZAJ_HORAS
				ZAJ->ZAJ_PESOB   := _nPesoBM
				ZAJ->ZAJ_PESO    := _nPesoLM
				ZAJ->ZAJ_TARA    := nTara
				ZAJ->ZAJ_CODPA   := _cCodPa
				ZAJ->ZAJ_DEST    := 'R'
				msunlock()

				if SZ2->(MsSeek(FWxFilial('SZ2') + _cPredes))
					reclock('SZ2',.f.)
					SZ2->Z2_QPPECA -= 1
					SZ2->Z2_QPPESO -= ZAJ->ZAJ_PESO
					msunlock()
				endif

				u_gjf182hs(2,"CARREG." + ZAJ->ZAJ_PREPED)

				gravDtCort(TMP2->ZAJ_NUM)
				ZAJ->(dbGoTop())
			endif
			TMP2->(DbSkip())
		enddo
	endif

	//a função estava aqui
	execsom()

	ZZ5->(dbsetorder(1))
	ZZ5->(Msseek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
	CarPec := 0
	CarPeso:= 0
	DbSelectArea('SB1')
	while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ZZ4->ZZ4_NUM = ZZ5->ZZ5_NUM
		if GetAdvFVal("SB1","B1_SEGUM",FWxfilial("SB1")+ZZ5->ZZ5_COD,1) = "PC"
			CarPec  := CarPec + ZZ5->ZZ5_QRCAIX
			CarPeso := TotPeso + ZZ5->ZZ5_QRPESO
		endif
		ZZ5->(dbskip())
	enddo

	ZZ5->(Msseek(FWxfilial('ZZ5')+nPedItem))

	valor1 := space(23)
	//valor2 := space(06)
	valor3 := 0
	valor4 := 0
	valor5 := 0
	If Select('TMP2') <> 0
		TMP2->(dbCloseArea())
	Endif

	aCols := {}
	gjf31col2(3)
	oCar:refresh()
	mens := ''
	oSayDesc:SetText(mens)
	oEnc:refresh()

	if  atendido
		msgbox('Item '+ZZ5->ZZ5_ITEM + ' ('+ alltrim(ZZ5->ZZ5_DESC) +') do pedido '+ ZZ5->ZZ5_NUM + ' atendido!','ATENÇÃO','INFO')
	endif

	if !empty(_cMensScn)
		_cMensScn := 'Ok!'
		oEnc:refresh()
	endif

	restarea(area)
return

Static Function gravDtCort(_codBar)

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(9)) //num + numam + control
	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_codBar))) .and. len(alltrim(_codBar)) = 10
		if empty(ZAJ->ZAJ_ZAPNUM)
			if empty(ZAJ->ZAJ_DTCORT)
				_cNumam 	 := ZAJ->ZAJ_NUMAM
				_cControl := ZAJ->ZAJ_CONTRO
				_cLado    := ZAJ->ZAJ_LADO

				ZAJ->(dbSetOrder(1))
				ZAJ->(MsSeek(FWxFilial('ZAJ') + _cNumam + _cControl))
				while ZAJ->(!eof()) .and. (FWxFilial('ZAJ') == ZAJ->ZAJ_FILIAL) .and. (ZAJ->ZAJ_NUMAM == _cNumam) .and. (ZAJ->ZAJ_CONTRO == _cControl)

					if ZAJ->ZAJ_LADO != _cLado
						ZAJ->(dbSkip())
						loop
					endif

					reclock('ZAJ',.f.)
					ZAJ->ZAJ_DTCORT := dDataBase
					msunlock()
					ZAJ->(dbSkip())
				enddo
			endif
		else
			if empty(ZAJ->ZAJ_DTCORT)
				reclock('ZAJ',.f.)
				ZAJ->ZAJ_DTCORT := dDataBase
				msunlock()
			endif
		endif
	endif

return

//Essa função verifica os status dos pre-carregamentos e dos PP e os atualiza conforme a operação
User Function gjf31stt(mod)
	do case
		case mod == 1
		lib := .f.
		st := GetAdvFVal('ZZ3','ZZ3_STATUS',FWxfilial('ZZ3')+ZZ4->ZZ4_PRECAR,2)
		if st == 'C' .or. st == 'B' .or. st == 'E' .or. st == 'F'
			msgbox('Status do Pré-Carregamento não permite esta operação!','OPERAÇÃO NEGADA!','STOP')
			return .f.
		endif
		if ZZ4->ZZ4_STATUS != 'L' .and. ZZ4->ZZ4_STATUS != 'S'
			msgbox('Status do Pré-Pedido não permite esta operação!','OPERAÇÃO NEGADA!','STOP')
			return .f.
		endif

		reclock('ZZ4',.f.)
		ZZ4->ZZ4_STATUS := 'C'
		ZZ4->ZZ4_LOCAR  := getComputerName()
		msunlock()

		ZZ3->(dbsetorder(2))
		if ZZ3->(Msseek(FWxfilial('ZZ3')+ZZ4->ZZ4_PRECAR))

			reclock('ZZ3',.f.)
			if ZZ3->ZZ3_STATUS = 'A'
				lib := .t.
			endif
			ZZ3->ZZ3_STATUS := 'C'
			ZZ3->ZZ3_LOCAR  := getComputerName()
			if lib
				ZZ3->ZZ3_DTINI := dDataBase
				ZZ3->ZZ3_HINI  := time()
			endif
			msunlock()

		endif
		return .t.

		case mod ==2
		reclock('ZZ4',.f.)
		ZZ4->ZZ4_STATUS := 'S'
		ZZ4->ZZ4_LOCAR := ' '
		msunlock()

		u_gjf31his('Pre-Pedido ' + alltrim(ZZ4->ZZ4_NUM) +' em espera' )

		ZZ3->(dbsetorder(2))
		if ZZ3->(Msseek(FWxfilial('ZZ3')+ZZ4->ZZ4_PRECAR))
			reclock('ZZ3',.f.)
			ZZ3->ZZ3_STATUS := 'S'
			ZZ3->ZZ3_LOCAR := ' '
			msunlock()
		endif

		If Select('TMP2')<>0                                                           //Se um tmp com alias TMP2 existir, fecha-o
			TMP2->(dbCloseArea())
		Endif

		return .t.

		case mod = 4
		if ZZ4->ZZ4_STATUS == 'E' .or. ZZ4->ZZ4_STATUS == 'C' .or. ZZ4->ZZ4_STATUS == 'F'
			msgbox('Status do Pré-Pedido não permite esta operação!','OPERAÇÃO NEGADA!','STOP')
			return .f.
		else
			return .t.
		endif

	endcase

return .t.

//Realiza calculos necessários para serem inseridos no cabeçalho do PP
User Function gjf31clc()
	Local nIt
	QTDCaix := 0
	QTDPeso := 0
	vTotal  := 0
	TGeral  := 0
	vBonif := 0
	tBonif := ''
	vPreco := 0

	nPosDel := Len(aHeader) + 1

	For nIt := 1 To Len(aCols)
		qCaixa  := GDFieldGet('ZZ5_QPCAIX',nIt)
		qPeso   := GDFieldGet('ZZ5_QPPESO',nIt)
		vBonif := GetAdvFVal('ZZ5','ZZ5_BONIF',FWxfilial('ZZ5')+M->ZZ4_NUM + StrZero(nIt,3),1)
		tBonif := GetAdvFVal('ZZ5','ZZ5_TPBONIF',FWxfilial('ZZ5')+M->ZZ4_NUM + StrZero(nIt,3),1)
		vPreco := GetAdvFVal('ZZ5','ZZ5_QRCAIX',FWxfilial('ZZ5')+M->ZZ4_NUM + StrZero(nIt,3),1)

		if M->ZZ4_STATUS != 'E' .and. M->ZZ4_STATUS != 'F'
			if tBonif = 'D'
				vTotal  := GDFieldGet('ZZ5_QPPESO',nIt) * vPreco - vBonif
			elseif tBonif = 'A'
				vTotal  := GDFieldGet('ZZ5_QPPESO',nIt) * vPreco + vBonif
			else
				vTotal  := GDFieldGet('ZZ5_QPPESO',nIt) * vPreco
			endif
		endif

		If !aCols[nIt, nPosDel]
			QTDCaix += qCaixa
			QTDPeso += qPeso
			if M->ZZ4_STATUS != 'E' .and. M->ZZ4_STATUS != 'F'
				TGeral  += vTotal
			endif
		endif

	Next nIt

	M->ZZ4_QPPESO := QTDPeso
	M->ZZ4_QPCAIX := QTDCaix

	if ZZ4->ZZ4_STATUS != 'E' .and. M->ZZ4_STATUS != 'F'
		M->ZZ4_TOTAL  := TGeral
	endif

Return

User Function gjf31VisP()

	area := getarea()

	dbselectarea('SA1')
	dbselectarea('SX5')

	_cSeg  	 :=  GetAdvFVal('SA1','A1_SATIV1',FWxfilial('SA1')+alltrim(ZZ4->ZZ4_CODCLI)+ZZ4->ZZ4_LOJA,1)
	if !empty(_cSeg)
		_cX5Des  := GetAdvFVal('SX5','X5_DESCRI',FWxfilial('SX5')+ 'T3' + alltrim(_cSeg),1)
	endif

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	cQuery := "SELECT ZZ5_COD AS COD,ZZ5_DESC AS DESCRI, SUM(ZZ5_QPCAIX) AS PCAIX, SUM(ZZ5_QRCAIX) AS RCAIX, "+;
	" SUM(ZZ5_QPPESO) AS PPESO, SUM(ZZ5_QRPESO) AS RPESO, ZZ5_PRIORI AS PRIORI                 "+;
	" FROM ZZ5010                                                                             "+;
	" WHERE ZZ5010.D_E_L_E_T_ <> '*' AND ZZ5_NUM = '" + ZZ4->ZZ4_NUM + "'                     "+;
	" AND ZZ5_FILIAL = '" + FWxfilial('ZZ5') + "'" +;
	" GROUP BY ZZ5_COD, ZZ5_DESC, ZZ5_PRIORI"

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
	aadd(aCampos,{"PRIO"   ,"Prioridade"  ,"@!"           })

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

	aStru := dbStruct()                                                           //Pega a estrutura do QRY e atribui a um vetor

	aadd(aStru,{"PRIO"    , "C",  10, 0,   "@!" , 'Prioridadee'  })

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	_aArqTrb := {}
	If Select('TMP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	QRY->(dbgotop())

	SBM->(dbsetorder(1))

	while QRY->(!eof())
		DbSelectArea('TMP')
		reclock('TMP',.t.)
		TMP->COD    := QRY->COD
		TMP->DESCRI := QRY->DESCRI
		TMP->PCAIX  := QRY->PCAIX
		TMP->RCAIX  := QRY->RCAIX
		TMP->PPESO  := QRY->PPESO
		TMP->RPESO  := QRY->RPESO
		TMP->PRIORI := QRY->PRIORI

		if QRY->PRIORI = 'A'
			TMP->PRIO := 'Automatico'
		elseif QRY->PRIORI = 'C'
			TMP->PRIO := 'Caixa'
		else
			TMP->PRIO := 'Peso'
		endif

		msunlock()
		QRY->(dbskip())

	enddo

	TMP->(dbgotop())

	while TMP->(!eof())

		if GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+TMP->COD,1) = 'CX'
			_nTotCaix  += TMP->RCAIX
			_nTotPCaix += TMP->RPESO
		elseif GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+TMP->COD,1) = 'PC'
			_nTotPeca  += TMP->RCAIX
			_nTotPPeca += TMP->RPESO
		endif

		TMP->(dbskip())
	enddo

	TMP->(dbgotop())

	DEFINE MSDIALOG oEnc TITLE 'Consulta por Itens do Pedido' from 00,00 to 265,835 OF oMainWnd PIXEL

	@ 005,005 To 90,420 Browse "TMP"  fields aCampos object oiBrowse
	@ 103,350  BUTTON 'Sair'        SIZE 40,15 ACTION oEnc:end() OBJECT oBtn
	@ 007,05 SAY 'Total Caixas: '+ Transform(_nTotCaix,'@E 999,999')
	@ 008,05 SAY 'Total Peças:  '+ Transform(_nTotPeca,'@E 999,999')
	@ 007,20 SAY 'Total Peso: ' + Transform(_nTotPCaix,'@E 999,999.99')
	@ 008,20 SAY 'Total Peso: ' + Transform(_nTotPPeca,'@E 999,999.99')
	/* Dia 11/11/19 - Inclusão feita a pedido do Rodrigo para visualizar campo ( A1_SATIV1)*/
	if !empty(_cSeg)
	@ 009,05 SAY 'Segmento:'+SPACE(2)+ _cSeg +SPACE(2)+ substr(_cX5Des,1,25)
	endif
	
	
	ACTIVATE MSDIALOG oEnc

	If Select("TMP")<>0
		QRY->(dbCloseArea())
	Endif

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif
	SA1->(dbCloseArea())
	SX5->(dbCloseArea())
	restarea(area)

return

User Function gjf31TotP()
	/*
	cQuery1 := " SELECT COUNT(ZBF_NUM) AS QUANT, SUM(ZBF_PESO) AS TOT "
	cQuery1 += " FROM " + RetSQLTab('ZBF')
	cQuery1 += " WHERE " + RetSQLFil('ZBF') + " AND '" + ZZ3->ZZ3_NUM + "' = '" + ZZ4->ZZ4_PRECAR + "' AND "
	cQuery1 += " '" + ZZ3->ZZ3_NUM + "' = ZBF_PRECAR  AND "
	cQuery1 +=   RetSQLDel('ZBF')
	cQuery1 += " GROUP BY ZBF_NUM, ZBF_PESO "
	*/

	cQuery1 := " SELECT COUNT(ZBF_NUM) AS QUANT, SUM(ZBF_PESO) AS TOT "
	cQuery1 += " FROM " + RetSQLTab('ZBF')
	cQuery1 += " WHERE " + RetSQLFil('ZBF') + " AND "
	cQuery1 += " '" + ZZ3->ZZ3_NUM + "' = ZBF_PRECAR  AND "
	cQuery1 +=   RetSQLDel('ZBF')

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery1 := ChangeQuery(cQuery1)

	If Select("QRY") <> 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "QRY"

	QRY->(dbGoTOp())

	DEFINE MSDIALOG oEnc TITLE 'Consulta Quantidade/Peso Pallet' from 00,00 to 240,835 OF oMainWnd PIXEL

	oFont := TFont():New('Courier new',,-50,.T.)

	oSay1:= TSay():New(20,01,{||'Total De Pallet: '},oEnc,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,400,40)

	oSay2:= TSay():New(60,01,{||'Total Peso Pallet: '},oEnc,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,400,40)

	oSay:= TSay():Create(oEnc,{||Transform(QRY->QUANT,'@E 999,999')},20,250,,oFont,,,,.T.,CLR_GREEN,CLR_WHITE,200,20)

	oSay3:= TSay():Create(oEnc,{||Transform(QRY->TOT,'@E 999,999.99')},60,250,,oFont,,,,.T.,CLR_GREEN,CLR_WHITE,200,20)

	//oSay:CtrlRefresh()
	//oSay3:CtrlRefresh()
	//@ 103,350  BUTTON 'Sair'        SIZE 40,15 ACTION oEnc:end() OBJECT oBtn
	//@ 007,05 SAY 'Total Pallet Carregado: ' + Transform(QRY->QUANT,'@E 999,999') SIZE 200,200 OF oEnc PIXEL
	//@ 015,05 SAY 'Total Peso Pallet Carregado: ' + Transform(QRY->TOT,'@E 999,999.99') SIZE 200,200 OF oEnc PIXEL

	ACTIVATE MSDIALOG oEnc CENTERED

return


User Function gjf31VC()

	cQuery1 := " SELECT ZZ5_COD AS COD,ZZ5_DESC AS DESCRI, SUM(ZZ5_QPCAIX) AS PCAIX, SUM(ZZ5_QRCAIX) AS RCAIX, "
	cQuery1 += " SUM(ZZ5_QPPESO) AS PPESO, SUM(ZZ5_QRPESO) AS RPESO, ZZ5_PRDALT AS PRDALT                      "
	cQuery1 += " FROM " + RetSQLTab('ZZ4') + " , " + RetSQLTab('ZZ5')
	cQuery1 += " WHERE " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ5')  + " AND ZZ5_NUM = ZZ4_NUM AND "
	cQuery1 += " ZZ4_PRECAR = '" + ZZ3->ZZ3_NUM + "' AND "
	cQuery1 +=  RetSQLDel('ZZ5') + " AND " + RetSQLDel('ZZ4')
	cQuery1 += " GROUP BY ZZ5_COD, ZZ5_DESC, ZZ5_PRDALT"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery1 := ChangeQuery(cQuery1)

	If Select("QRY") <> 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "QRY"

	area := getarea()

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	dbSelectarea('QRY')

	aStru := dbStruct()                                                           //Pega a estrutura do QRY e atribui a um vetor

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	_aArqTrb := {}
	If Select('TMP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	QRY->(dbgotop())

	SBM->(dbsetorder(1))

	//Inicio Bloco de Fabian Maurer
	_nPesoCx  := 0.00
	_nPesoPec := 0.00
	_nQtRCx	  := 0
	_nQtdRP   := 0.00
	//Fim Bloco de Fabian Maurer
	while QRY->(!eof())
		DbSelectArea('TMP')
		reclock('TMP',.t.)
		TMP->COD    := QRY->COD
		TMP->DESCRI := QRY->DESCRI
		TMP->PCAIX  := QRY->PCAIX
		TMP->RCAIX  := QRY->RCAIX
		TMP->PPESO  := QRY->PPESO
		TMP->RPESO  := QRY->RPESO
		TMP->PRDALT := QRY->PRDALT
		msunlock()
		//Inicio Bloco de Fabian Maurer
		_cProdMed := GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+QRY->COD,1)

		_nPesoCx += QRY->PPESO
		_nQtRCx += QRY->RCAIX
		_nPesoPec += QRY->PPESO
		_nQtdRP += QRY->RPESO

		//Fim do Bloco de Fabian Maurer

		QRY->(dbskip())

	enddo

	aCampos := {}

	aadd(aCampos,{"COD"   ,"Codigo ",""                  })
	aadd(aCampos,{"DESCRI","Descricao   ",""             })
	aadd(aCampos,{"PCAIX" ,"Prev. Caixas","@E 9,999"     })
	aadd(aCampos,{"RCAIX" ,"Real. Caixas","@E 9,999"     })
	aadd(aCampos,{"PPESO" ,"Prev. Peso"  ,"@E 999,999.99"})
	aadd(aCampos,{"RPESO" ,"Real. Peso"  ,"@E 999,999.99"})
	aadd(aCampos,{"PRDALT","Prod.Alternat.",""           })

	TMP->(dbgotop())

	//Inicio Bloco de Fabian Maurer
	oFont      := tFont():New("courier new",,-12,,.t.,,,,)
	oTxtPesCx  := 'Prev. Caixas(KG):'
	oNumPesCx  := transform(_nPesoCx,'@E 999,999.999')
	oTxtPesPec := 'Prev. Peças(KG):'
	oNumPesPec := transform(_nPesoPec,'@E 999,999.999')
	oTxtPesTot := 'Prev. Total(KG):'
	oNumPesTot := transform(_nPesoCx + _nPesoPec,'@E 999,999.999')
	//Fim Bloco de Fabian Maurer
	/*  Inclusão do resultado de Total real de Caixas e Total real de Peso */
	oTxtTotCx  := 'Tot. Caixas(UN) :' // vem do real de caixas   _nQtRCx
	oNumTotCx  := transform(_nQtRCx,'@E 999,999')
	oTxtTotPes := 'Tot. Peso R(KG):' // vem do real de Peso       _nQtdRP
	oNumTotPes := transform(_nQtdRP,'@E 999,999.999')
	//alert(_nQtdRP)

	//DEFINE MSDIALOG oEnc TITLE 'Consulta por Itens do Carregamento' from 00,00 to 240,810 OF oMainWnd PIXEL
	DEFINE MSDIALOG oEnc TITLE 'Consulta por Itens do Carregamento' from 00,00 to 260,810 OF oMainWnd PIXEL

	@ 005,005 To 100,400 Browse "TMP"  fields aCampos

	@ 103,350  BUTTON 'Sair' SIZE 40,15 ACTION oEnc:end() OBJECT oBtn

	//Inicio Bloco de Fabian Maurer
	oSayTxtPesCx  := tSay():New(103,00,{|| oTxtPesCx	},oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//Peso Previsto de Caixas
	oSayNumPesCx  := tSay():New(103,64,{|| oNumPesCx	},oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//Peso Previsto de Caixas Numero
	oSayTxtPesPec := tSay():New(103,125,{|| oTxtPesPec	},oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//Peso Previsto de Peças
	oSayNumPesPec := tSay():New(103,185,{|| oNumPesPec	},oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//Peso Previsto de Peças Numero
	oSayTxtPesTot := tSay():New(103,240,{|| oTxtPesTot	},oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//Peso Previsto Total
	oSayNumPesTot := tSay():New(103,305,{|| oNumPesTot	},oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//Peso Previsto Total Numero
	/*  Inclusão do resultado de Total real de Caixas e Total real de Peso */
	oSayTxtTotCx := tSay():New(113,00,{|| oTxtTotCx	},oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//Total Real de Caixas
	oSayNumTotCx := tSay():New(113,75,{|| oNumTotCx	},oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//Total Real de Caixas Numero
	oSayTxtTotPes := tSay():New(113,125,{|| oTxtTotPes	},oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//Total Real de Peso
	oSayNumTotPes := tSay():New(113,185,{|| oNumTotPes	},oEnc,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//Total Real de Peso Numero

	//Fim Bloco de Fabian Maurer

	ACTIVATE MSDIALOG oEnc

	//dbclosearea('TMP')
	dbclosearea()

	return

Return
///Fim da função de atualização///

Static Function CapT()
	nTara := CapBal()
	if nTara > 0
		msgbox('Valor da tara capturada (Kg): '+ transform(nTara,'@E 999.999'),'Captura Realizada!','INFO')
	else
		msgbox('Problemas com a captura da Tara!','Valor inconsistente!','ERRO')
	endif

	if valor4 != 0
		valor5 := valor4 - nTara
	endif

Return

Static Function gjf31T()

	nRold := 0
	nGanc := 0
	// Comentado dia 23/11/20 -por Flávio
	//if !_lFt
	//	return
	//endif
	DEFINE MSDIALOG oDlg4 TITLE 'Tara Manual' from 000,000 To 70,300 PIXEL STYLE DS_MODALFRAME
	oDlg4:lEscClose := .F.
	_lFt := .f.
	@ 010,003 SAY 'Roldanas:' Object oSay1
	@ 020,003 SAY 'Gancheiras:' Object oSay1
	@ 010,035 GET nRold PICTURE "@E 999"  valid ValRold(nRold) Object oTara
	@ 020,035 GET nGanc PICTURE "@E 999"  valid nGanc >= 0 Object oTara
	//@ 010,060 BMPBUTTON TYPE 1 ACTION odlg2:end() Object Obtn2
	@ 015,075 BUTTON botao PROMPT "OK" OF oDlg4 PIXEL ACTION oDlg4:end()
	ACTIVATE MSDIALOG oDlg4 CENTERED

	nTara := (nRold * nTarRol) + (nGanc * nTarGan)

	if valor4 != 0
		valor5 := valor4 - nTara
	endif

	_lFt := .t.

return

Static Function ValRold(nRold)

	Local lRet := .T.

	if nRold <= 0
		FWAlertError("Número de roldanas deve ser maior que zero!","ERRO!")
		lRet := .F.
	endif

Return lRet

User  Function gjf31Ver()                                                        //Cria a caixa de diálogo para localizar uma caixa
	cCaixa := space(10)
	_Mens1 := ''
	_Mens2 := ''
	cont := 0

	u_gjf31his('Acesso verific. rapida de caixas')

	DEFINE MSDIALOG oDlgR TITLE 'Verificação Rápida de Caixas:' from 000,000 To 150,360 OF oMainWnd PIXEL
	@ 010,003 SAY  'Caixa:' Object oSay1
	@ 010,025 GET cCaixa PICTURE "@!"   SIZE 60,11  valid ConsC() Object oC
	oFont      := tFont():New("courier new",,-20,,.t.,,,,)
	oSayD1  := tSay():New(30,10,{|| _Mens1 },oDlgR,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,20)
	oSayD2  := tSay():New(30,10,{|| _Mens2 },oDlgR,,oFont,,,,.T.,CLR_HRED,CLR_HRED,200,20)
	@ 010,60 SAY cont
	@ 60,140 BMPBUTTON TYPE 1 ACTION odlgR:end() Object Obtn1

	ACTIVATE MSDIALOG oDlgR

	u_gjf31his('Saida verific. rapida de caixas')

return

User Function gjf31rel()  // Chama a rotina de geração de relatório de caixas com erro

	SetMVValue("DTI182", "MV_PAR01", ZZ3->ZZ3_NUM, .T.)
	pergunte("DTI182", .T.)
	u_DTI182()

return

// Função para liberar carregamento, somente se estiver encerrado, para poupar o comercial
User Function gjf31lib()
	Local cUsrReimp := alltrim(getMV("SI_LIBPCEX"))

	ZZ4->(DbSetOrder(2))

	if cUserName $ cUsrReimp
		if !(ZZ3->ZZ3_STATUS $ 'F/B')
			if FWAlertYesNo("Liberar o carregamento?","CONFIRMA")

				if ZZ4->(MsSeek(FWxfilial('ZZ4')+alltrim(aBrowse[oBrowse:nAt,02])))
					if ZZ4->ZZ4_SIBLQL = '2'
						reclock('ZZ3',.f.)
						ZZ3->ZZ3_STATUS := 'S'
						msunlock()

						reclock('ZZ4',.f.)
						ZZ4->ZZ4_STATUS := 'S'
						msunlock()

						u_dtilog(cFilAnt, "GJF31", "Liberação de pedido -> " + ZZ4->ZZ4_NUM + " | Carregamento -> " + ZZ3->ZZ3_NUM, "L")
					endif
				else
					FWAlertError("Cliente bloqueado!","ERRO!")
				endif

			endif
		else
			FWAlertError("Status do carregamento não permite essa alteração!","ERRO!")
		endif
	else
		FWAlertWarning("Usuário sem premissão! Contate o seu líder!","ATENÇÃO!")
	endif

Return

User Function gjf31exv()  // Chama a rotina de geração de relatório de caixas com erro

	tsTop      := 0
    tsLeft     := 0
    tsBottom   := 300
    tsRight    := 300
    tsCaption  := 'Remover caixa da validação de coletor'
    tsClrText  := CLR_BLACK
    tsClrBack  := CLR_WHITE
    tsPixel    := .T.
    //Variaveis gerais
    _cControl    := Space(10)

    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)

	oFont:= TFont():New('Arial',, -24, .T.)

	oSay1:= TSay():New(010,30,{||'Código da caixa:'},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	oTGet1 := TGet():New(30,30,{ | u | If( PCount() > 0, _cControl := u, _cControl) },oDialog,100,10, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,_cControl,,,,.t., )
	//oTGet1:cF3 := 'ZBF'
	oTGet1:Picture := '@!'
	oTButton1 := TButton():New(50, 30, "Reabilitar caixa",oDialog,{|| RemValid(_cControl)}, 90,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 := TButton():New(65, 30, "Sair",oDialog,{||oDialog:end()}, 90,10,,,.F.,.T.,.F.,,.F.,,,.F. )

    oDialog:Activate(,,,.T.,,,)

return

Static Function RemValid(_cControl)

	if substr(_cControl,1,2) = 'PA'
		SZP->(DbSetOrder(1))
		SZP->(DbGoTop())
		if !SZP->(MsSeek(FWxfilial('SZP')+alltrim(_cControl)))
			mensagem('Pallet não identificado!')
		else
			SZ8->(DbSetOrder(19))
			SZ8->(DbGoTop())

			if SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + alltrim(_cControl)))
				While SZ8->(!eof()) .and. SZ8->(Z8_FILIAL+Z8_FIL+Z8_PALLET) = (FWxfilial('SZ8') + cFilAnt + alltrim(_cControl))
					reclock('SZ8',.F.)
					SZ8->Z8_CHKCARR := ''
					SZ8->Z8_CHKPCAR := ''
					SZ8->(msunlock())

					SZ8->(DbSkip())
				enddo
				FWAlertSuccess('Pallet removido da validação!', 'SUCESSO!')
			else
				FWAlertError('Pallet não carregado!', 'ERRO!')
			endif
		endif
	else
		SZ8->(dbSetOrder(3))
		SZ8->(dbGoTop())
		if !SZ8->(MsSeek(FWxFilial('SZ8')+alltrim(_cControl))) .or. len(alltrim(_cControl)) < 10
			FWAlertError('Caixa inexistente!', 'ERRO!')
			return .t.
		else
			reclock('SZ8',.F.)
			SZ8->Z8_CHKCARR := ''
			SZ8->Z8_CHKPCAR := ''
			SZ8->(msunlock())
			FWAlertSuccess('Caixa removida da validação!', 'SUCESSO!')
			return .t.
		endif
	endif
Return

Static Function ConsC()
	if empty(cCaixa)
		return .t.
	endif

	SZ8->(dbsetorder(3))
	if SZ8->(Msseek(FWxfilial('SZ8') + alltrim(cCaixa) ))  .and. SZ8->Z8_FIL = FWxfilial('SB1')
		if empty(SZ8->Z8_DATAS) .and. empty(SZ8->Z8_HORAS)
			execsom()
			_cMens1 := 'Caixa em Estoque!'
			_cMens2 := ''
			cont++
		elseif !empty(SZ8->Z8_DATAS) .and. !empty(SZ8->Z8_HORAS)
			SomErr()
			if SZ8->Z8_PREPED = ZZ4->ZZ4_NUM
				_cMens2 := 'Caixa carregada nesse pré-pedido!'
			else
				_cMens2 := 'Caixa fora de estoque! (pre-pedido n.: '+SZ8->Z8_PREPED + ' )'
			endif
			_cMens1 := ''
			cont++
		endif
	else
		SomErr()
		SomErr()
		_cMens1 := ''
		_cMens2 := 'Caixa não encontrada!'
	endif
	oSayD1:SetText(_cMens1)
	oSayD2:SetText(_cMens2)

	//oC:setfocus()
	oDlgR:refresh()

	cCaixa := space(10)
return .f.

User Function gjf31his(_cEvento,_stPck,_lFal)

	
	_lRegHist := GetMv("SI_HISTCAR")
	
	if _lRegHist = 'N'
		Return .f.
	endif

	DbSelectArea('ZZC')
	ZZC->(DbSetOrder(1))

	_cMemo := ''
	if ZZ3->ZZ3_STATUS <> 'F'
		if _lFal
			@ 116,010 To 325,425 Dialog oDlgMemo Title "Registro de Evento"
			@ 001,002 SAY _cEvento
			@ 020,005 Get _cMemo Size 200,040 MEMO VALID !empty(_cMemo) .OR. _cMemo <> '' Object oMemo
			//@ 090,010 BMPBUTTON TYPE 1 ACTION oDlgMemo:end() Object Obtn1 
			@ 090,010 BMPBUTTON TYPE 1 ACTION iif(!empty(_cMemo),oDlgMemo:end(),alert('Obrigatório preenchimento da mensagem!')) Object Obtn1 
			//@ 090,040 BMPBUTTON TYPE 2 ACTION (_cMemo := '',oDlgMemo:end()) Object Obtn2
			Activate Dialog oDlgMemo CENTERED

		elseif msgbox('Deseja registra evento? (S/N)','REGISTRO DE EVENTO','YESNO') 
			@ 116,010 To 325,425 Dialog oDlgMemo Title "Registro de Evento"
			@ 001,002 SAY _cEvento
			@ 020,005 Get _cMemo Size 200,040 MEMO Object oMemo
			@ 090,010 BMPBUTTON TYPE 1 ACTION oDlgMemo:end() Object Obtn1
			@ 090,040 BMPBUTTON TYPE 2 ACTION (_cMemo := '',oDlgMemo:end()) Object Obtn2
			Activate Dialog oDlgMemo CENTERED
		endif
	endif

	_cNumHist := GETSX8NUM('ZZC','ZZC_NUM')
	confirmSX8()

	reclock('ZZC',.t.)
	ZZC->ZZC_NUM     := _cNumHist
	ZZC->ZZC_FILIAL  := FWxfilial('ZZC')
	ZZC->ZZC_STATUS  := ZZ3->ZZ3_STATUS
	ZZC->ZZC_PRECAR  := ZZ3->ZZ3_NUM
	ZZC->ZZC_DATA    := date()
	ZZC->ZZC_HORA    := time()
	ZZC->ZZC_OPER    := cUserName
	ZZC->ZZC_EVENTO  := _cEvento
	ZZC->ZZC_HIST    := _cMemo
	ZZC->ZZC_STPCK   := _stPck
	msunlock('ZZC')

	ZZC->(DbCloseArea())
return

User Function gjf31vhi()
	cQuery := "SELECT ZZC_NUM AS NUM,ZZC_DATA AS DATAH, ZZC_HORA AS HORA, ZZC_OPER AS OPER,"+;
	" ZZC_EVENTO AS EVENTO, ZZC_HIST AS HIST                                     "+;
	" FROM ZZC010                                                               "+;
	" WHERE ZZC010.D_E_L_E_T_ <> '*' AND ZZC_PRECAR = '" + ZZ3->ZZ3_NUM + "'    "+;
	" AND ZZC_FILIAL = '" + FWxfilial('ZZC') + "'                                 "+;
	" ORDER BY ZZC_DATA, ZZC_HORA"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	area := getarea()

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	dbSelectarea('QRY')

	aStru := dbStruct()                                                           //Pega a estrutura do QRY e atribui a um vetor

	aadd(aStru,{"DATAM"    , "D",  8, 0,   "" , 'Data'  })

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	_aArqTrb := {}
	If Select('TMP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	QRY->(dbgotop())
	DbSelectArea('TMP')
	reclock('TMP',.t.)
	TMP->NUM    := QRY->NUM
	TMP->DATAM  := ZZ3->ZZ3_DATLIB
	TMP->HORA   := ZZ3->ZZ3_HORLIB
	TMP->OPER   := ZZ3->ZZ3_USULIB
	TMP->EVENTO := "Liberação do pré-carregamento"
	msunlock()

	while QRY->(!eof())
		reclock('TMP',.t.)
		TMP->NUM    := QRY->NUM
		TMP->DATAM  := STOD(QRY->DATAH)
		TMP->HORA   := QRY->HORA
		TMP->OPER   := QRY->OPER
		TMP->EVENTO := QRY->EVENTO
		TMP->HIST   := QRY->HIST
		msunlock()
		QRY->(dbskip())

	enddo

	aCampos := {}

	aadd(aCampos,{"DATAM"  ,"Data ",""          })
	aadd(aCampos,{"HORA"   ,"Hora   ","@!"      })
	aadd(aCampos,{"OPER"   ,"Operador","@!"     })
	aadd(aCampos,{"EVENTO"  ,"Evento","@!"      })
	aadd(aCampos,{"HIST"  ,"Historico"  ,""     })

	TMP->(dbgotop())

	DEFINE MSDIALOG oEnc TITLE 'Consulta Historico de Carga' from 00,00 to 240,835 OF oMainWnd PIXEL

	@ 005,005 To 90,420 Browse "TMP"  fields aCampos object oiBrowse
	@ 103,350  BUTTON 'Sair'        SIZE 40,15 ACTION oEnc:end() OBJECT oBtn
	ACTIVATE MSDIALOG oEnc

	//dbclosearea('TMP')
	dbclosearea()

return

//Rotina que chama a exclusão de caixas
User Function gjf31exc()
	area := getarea()
	lOk := .f.
	Private aRotina  := {}
	aObjects := {}                                                                 //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	Private cCadastro := "Exclusão de Caixas do Pré-Carregamento: " + ZZ3->ZZ3_NUM
	aRotina := { { "Pesquisa", "AxPesqui"   , 0, 1},; 	//"Pesquisar"
	{ "Excluir" , "u_gjf31ecx" , 0, 4}} 	    //"Excluir a caixa"

	cString := 'ZZ6'

	if ZZ3->ZZ3_STATUS <> 'S'
		msgbox('Status do Pré-Carregamento não permite essa operação!','OPERAÇÃO NEGADA!','STOP')
		return .f.
	elseif  ZZ4->ZZ4_STATUS <> 'S'
		msgbox('Status do Pré-Pedido não permite essa operação!','OPERAÇÃO NEGADA!','STOP')
		return .f.
	else
		u_gjf31his('Acesso Exclusão de Caixas')
	endif

	dbSelectArea(cString)
	ZZ6->(dbSetOrder(5))
	ZZ6->(dbgotop())

	cCondicao3 := "ZZ6_FILIAL = '" + FWxfilial('ZZ6') + "' AND ZZ6_PRECAR = '"+ ZZ4->ZZ4_PRECAR + "' AND ZZ6_PREPED = '" + ZZ4->ZZ4_NUM + "'"

	mBrowse(6,1,22,75,'ZZ6',,,,,,,,,,,,,,cCondicao3)

	u_gjf31his('Saida Exclusao de Caixas.  Retorno tela Pre-Carregamentos')

	restarea(area)

return .t.

/*
//Cria a caixa de diálogo para localizar uma caixa
user function gjf31pcx()
cCaixa := space(10)
DEFINE MSDIALOG oDlg2 TITLE 'Localizar Caixa:' from 000,000 To 100,250 OF oMainWnd PIXEL
@ 010,003 SAY  'Numero:' Object oSay1
@ 010,025 GET cCaixa PICTURE "@!"   SIZE 40,11  VALID preenche() Object oCaixa
@ 010,80 BMPBUTTON TYPE 1 ACTION posicao2() Object Obtn1
@ 025,80 BMPBUTTON TYPE 2 ACTION odlg2:end() Object Obtn2
ACTIVATE MSDIALOG oDlg2
return

static function posicao2()
odlg2:end()
ZZ6->(dbsetorder(3))
if !(ZZ6->(Msseek(FWxfilial('ZZ6')+cCaixa,.t.)))
msgbox('Caixa não encontrada!','OPERAÇÃO INCONSISTENTE!','ERRO')
endif
return

static function preenche()                                                      //Função que preeche o codigo do produto com zeros
if !empty(alltrim(cCaixa))
cCaixa := padl(alltrim(cCaixa),10,"0")
endif
return .t.
*/

User Function gjf31ecx()
	if APMsgNOYES('Confirma exclusão de caixa?','EXCLUSAO')
		SZ8->(dbsetorder(3))
		if SZ8->(Msseek(FWxfilial('SZ8')+ZZ6->ZZ6_CONTRO)) .and. SZ8->Z8_FIL = ZZ6->ZZ6_FILIAL

			ZZ5->(dbsetorder(1))
			if ZZ5->(Msseek(FWxfilial('ZZ5')+alltrim(SZ8->Z8_PREPED+SZ8->Z8_ITEM)))
				reclock('ZZ5',.f.)
				ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX - 1
				ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO - SZ8->Z8_PESO
				ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB - SZ8->Z8_PESOBR
				ZZ5->ZZ5_STATUS := ''
				msunlock()
			else
				alert('Item de Pré-pedido não localizado!')
				return
			endif

			u_GJF134(2,SZ8->Z8_CONTROL,'E',DDATABASE,SZ8->Z8_PESO,SZ8->Z8_PRECAR,SZ8->Z8_FIL,SZ8->Z8_PREPED,SZ8->Z8_ITEM,SZ8->Z8_DATA,'')

			u_gjf17his(1,'EXCL. PED. ' + ZZ5->ZZ5_NUM,.f.,'','','000013',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

			u_gjf17his(4,'CAIXA SEPARADA E EXCLUIDA DO PEDIDO: ' + ZZ5->ZZ5_NUM,.f.,'','','000019',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

			reclock('SZ8',.f.)
			SZ8->Z8_PREPED  := ''
			SZ8->Z8_ITEM    := ''
			SZ8->Z8_PRECAR  := ''
			SZ8->Z8_DATAS   := STOD('')
			SZ8->Z8_HORAS   := ''
			SZ8->Z8_DEST    := ''
			SZ8->Z8_PICKING := ''
			SZ8->Z8_CARPICK := ''
			SZ8->Z8_CHKCARR   := ''
			SZ8->Z8_CHKPCAR   := ''
			if ZZ4->ZZ4_TPOPER = 'T'
				SZ8->Z8_DTRANSF:= STOD('')
			endif
			msunlock()

			reclock('ZZ6',.f.)
			dbdelete()
			msunlock()

		endif

	endif
return .t.

Static Function Escanear()

	area := getarea()

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	dbSelectarea('ZAJ')
	aStru  := dbStruct()                                                           //Pega a estrutura do QRY e atribui a um vetor

	aStru3 := aStru

	aadd(aStru,{"ZK_CATEG"   , "C",  03, 0,   "@!"          , 'Categ    '})

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP2 criado
	//Cria a estrutura do vetor no TMP2 criado
	//If Select('TMP2') <> 0                                                        //Se um tmp com alias TMP2 existir, fecha-o
	//	alert('As ultimas carcaças escaneadas serão perdidas! Refaça a leitura destas!')
	//	valor3 := 0
	//	TMP2->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArq,"TMP2", .F. , .F. )

	_aArqTrb := {}
	If Select('TMP2')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		alert('As ultimas carcaças escaneadas serão perdidas! Refaça a leitura destas!')
		valor3 := 0
		TMP2->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP2", aStru, {}, @_aArqTrb)

	aCampos := {}

	aadd(aCampos,{"ZAJ_COD"    ,"Produto      ","@!"  })
	aadd(aCampos,{"ZAJ_NUM"    ,"Codigo Etiq. ","@!"  })
	aadd(aCampos,{"ZAJ_CORORI" ,"Corte Origem ","@!"  })
	aadd(aCampos,{"ZAJ_LADO"   ,"Lado         ","@!"  })
	aadd(aCampos,{"ZK_CATEG"   ,"Categ.       ","@!"  })

	TMP2->(dbgotop())

	campo1 := space(24)
	valor1 := space(24)
	valor2 := space(24)

	DEFINE MSDIALOG oEsc TITLE 'Escanear Carcaças' from 00,00 to 240,500 OF oMainWnd PIXEL
	@ 001,002   SAY  "Rastro Peça :"          OF oEsc
	@ 001,007   MSGET campo1 VAR valor1 SIZE 65,11   VALID validar(3)  OF oEsc //VALID ValPeca() of oEsc //
	@ 030,005 To 90,250 Browse "TMP2"  fields aCampos object oBrow2
	@ 100,020  BUTTON 'Confirmar'  SIZE 40,15 ACTION ConfScn() OBJECT oBtn
	@ 100,190  BUTTON 'Sair'       SIZE 40,15 ACTION SairScn() OBJECT oBtn
	ACTIVATE MSDIALOG oEsc

return

Static Function ConfScn()

	valor3   := RecCount('TMP2')
	_nValAux := valor3

	oEsc:end()
	oEnc:Refresh()
	//campo4:setfocus()
Return

Static Function SairScn()
	_cMensScn := ''
	valor3 := 0
	if  RecCount('TMP2') <> 0
		alert('Atenção! As carcaças escaneadas serão perdidas!')
		DbCloseArea()

	endif
	oEsc:end()
	//campo4:setfocus()
Return

//Determina a habilitação da caixa X carregamento
Static Function Classif(_cC)

	_lClas := .f.

	if empty(ZZ4->ZZ4_CLASSI)
		_lClas := .t.
		return _lClas
	endif

	if (AllTrim(ZZ4->ZZ4_CLASSI) $ 'RT/RU/HK') .and. empty(_cC)      // $ esta contido
		_lClas := .f.
		return _lClas
	endif

	Do Case
		case AllTrim(ZZ4->ZZ4_CLASSI) = 'RT'
		if AllTrim(_cC)  = 'RT'
			_lClas := .t.
		endif
		case AllTrim(ZZ4->ZZ4_CLASSI) = 'RU'
		if AllTrim(_cC) $ 'RT/RU'
			_lClas := .t.
		endif
		case AllTrim(ZZ4->ZZ4_CLASSI) = 'HK'
		if AllTrim(_cC) $ 'RT/RU/HK'
			_lClas := .t.
		endif
		otherwise
		_lClas := .t.
	endcase
Return  _lClas

//Verifica a reserva das caixas para esse pre-pedido
Static Function Reserv(_cPP)
	_ret := .f.
	if !empty(SZ8->Z8_RESERVA)                                 //Se a caixa estiver reservada faz a verificação
		if  SZ8->Z8_RESERVA = _cPP
			_ret := .t.
		else
			_ret := .f.
		endif
	elseif empty(SZ8->Z8_RESERVA) .and. ZZ5->ZZ5_RESERV = 'S'  //Se a caixa não estiver reservada e for obrigatoria a reserva no item...
		_ret := .f.
	elseif empty(SZ8->Z8_RESERVA) .and. ZZ5->ZZ5_RESERV = 'N'  //Se a caixa não for reservada e não for obrigatoria a reserva no item...
		_ret := .t.
	endif
return _ret

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

///Função validadora de input de quantidade no carregamento por peças///
Static Function ValInp()

	DbSelectArea('SB1')
	if GetAdvFVal('SB1','B1_SCAN',FWxfilial('SB1')+TMP->COD,1) = 'S' .and. valor3 <> 0 .and. Select('TMP2') = 0
		alert('Para estes produtos a inclusão de quantidades é somente com a Leitura por Scanner!')
		valor3 := 0
		return .f.
	endif

	if Select('TMP2') <> 0 .and. valor3 <> 0
		valor3 := _nValAux
		Return .t.
	endif

Return .t.

//Função que vai definir se o que foi escaneado será Traseiro ou Dianteiro de uma meia-rez
Static Function DefRez()

	area := getarea()

	campo := CTBCBOX('ZAJ_CORORI')
	valor := ''
	tipo  := ''
	DEFINE MSDIALOG oDlg3 TITLE 'Definição do Corte Lido:' from 000,000 To 80,210 OF oMainWnd PIXEL
	@ 009,002 SAY  'Tipo do Corte:' Object oSay1
	@ 009,035 COMBOBOX valor items campo SIZE 30,08  Object oCombo1
	@ 009,080 BMPBUTTON TYPE 1 ACTION DefRezOK() Object Obtn1
	@ 021,080 BMPBUTTON TYPE 2 ACTION SaiDefRez() Object Obtn2
	ACTIVATE MSDIALOG oDlg3

	restarea(area)

return tipo

Static Function DefRezOK()
	tipo := valor
	odlg3:end()
Return

Static Function SaiDefRez()
	odlg3:end()
	SairScn()
return

User Function gjf31obs()
	Local i
	if ZZ3->ZZ3_STATUS $ 'E/F'
		alert('Status Impede a Operacao')
		return .f.
	Endif

	_cpo   := space(40)
	_cOBS := ZZ3->ZZ3_OBS2

	for i := 1 to 3
		execsom()
		sleep(500)
	next

	@ 116,010 To 225,280 Dialog oDlgOBS Title "Observação Final"
	@ 001,001   MSGET _cpo VAR _cOBS SIZE 100,11  PICTURE "@!"  OF oDlgOBS
	@ 040,010 BMPBUTTON TYPE 1 ACTION oDlgOBS:end() Object Obtn1
	@ 040,040 BMPBUTTON TYPE 2 ACTION (_cOBS := ZZ3->ZZ3_OBS2,oDlgOBS:end()) Object Obtn2
	Activate Dialog oDlgOBS CENTERED

	reclock('ZZ3',.f.)
	ZZ3->ZZ3_OBS2 := _cOBS
	msunlock()

return

//Worflow para faltas
User Function gjf31wfw(_Num,_cliente,_loja,_Precar,_cNomAuth)

	local _area
	local _cCliPP := ''
	local _cMunic := ''
	local _cDest  := ''
	local _placa  := ''
	local _obs    := ''
	local _Usuar  := ''
	Local i
	local _cGetDest := getmv('SI_EXPDEST') //SI_EXPDEST

	dbSelectArea('SA1')

	_cCliPP := alltrim(GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1')+_cliente+_loja,1))
	_cMunic := GetAdvFVal('ZZ4','ZZ4_MUN',FWxfilial('ZZ4')+_Num,2)
	_cDest  := GetAdvFVal('ZZ4','ZZ4_EMAILU',FWxfilial('ZZ4')+_Num,2)
	_cDest  := GetAdvFVal('ZZ4','ZZ4_EMAILU',FWxfilial('ZZ4')+_Num,2)
	_cRepre := GetAdvFVal('ZZ4','ZZ4_REPRES',FWxfilial('ZZ4')+_Num,2)
	_cDesti := GetAdvFVal('SA3','A3_EMAIL',FWxfilial('SA3')+_cRepre,1)
	_cOrige := GetAdvFVal('ZZ4','ZZ4_ORIGEM',FWxfilial('ZZ4')+_Num,2)

	if !empty(_cDest)

		_area := getarea()

		ZZ3->(DbSetOrder(2))
		if  ZZ3->(MsSeek(FWxfilial('ZZ3')+_PreCar))

			_placa := ZZ3->ZZ3_PLACA
			_obs   := ZZ3->ZZ3_OBS
			_Data  := dtoc(ZZ3->ZZ3_DTCAR)
			_Usuar := alltrim(ZZ3->ZZ3_USUAR)
		endif

		_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
		_cMens += 'Na data e hora da emissão deste email, o pre-pedido abaixo foi encerrado por falta:' + chr(13) + chr(10)
		_cMens +=   chr(13) + chr(10)
		_cMens += 'Pre-Pedido nr.: ' + alltrim(_Num) + chr(13) + chr(10)
		_cMens += 'Cliente: ' + _cliente + '/' + _loja + '  ' + _cCliPP + chr(13) + chr(10)
		_cMens += 'Municipio: ' + _cMunic + chr(13) + chr(10)
		_cMens += 'Carregamento: ' + _PreCar + ' (' + _placa + ') ' + alltrim(_obs) + chr(13) + chr(10)
		_cMens += 'Data Carregamento: ' + _Data + chr(13) + chr(10)
		_cMens += 'Responsável Carregamento: ' + _Usuar + chr(13) + chr(10)
		if !empty(_cNomAuth)			
			_cDest += _cGetDest
			_cMens += 'Encerramento Autorizado por: ' + _cNomAuth + chr(13) + chr(10)
			_cMens += 'Motivo do encerramento: ' + _cMemo + chr(13) +chr(10)
		endif					  																			  														   
		_cMens += 'Itens faltantes:'  + chr(13) + chr(10)
		_cTit  := 'Workflow Frigorífico Silva: Aviso do pre-pedido ' + alltrim(_Num) +  ' encerrado com falta'

		//alert(_cMemo)
		ZZ5->(DbSetOrder(1))
		ZZ5->(MsSeek(FWxfilial('ZZ5')+_NUM))
		while ZZ5->(!eof()) .and. FWxfilial('ZZ5') = ZZ5->ZZ5_FILIAL .and. ZZ5->ZZ5_NUM = _Num

			if ZZ5->ZZ5_STATUS != 'E'
				_cMens += ZZ5->('Prod.' + ZZ5_COD + ' Desc.' + alltrim(ZZ5_DESC) + ' Q.P.Caixas:' + transform(ZZ5_QPCAIX,'@E 9,999')+;
				' Q.R.Caixas:' + transform(ZZ5_QRCAIX,'@E 9,999') + ' Q.P.Peso:' + transform(ZZ5_QPPESO,'@E 999,999.99')+;
				' Q.R.Peso:' + transform(ZZ5_QRPESO,'@E 999,999.99') + ' Prioridade:' + ZZ5_PRIORI) + chr(13) + chr(10)
			endif

			ZZ5->(DbSkip())
		enddo

		if AllTrim(_cOrige) = 'P'
			_aEmail := u_GJF54(_cMens,_cTit,alltrim(_cDest)+';'+alltrim(_cDesti))//ENVIA PARA SOLICTANTE DO PEDIDO + REPRESENTANTE
		else
			_aEmail := u_GJF54(_cMens,_cTit,_cDest)//ENVIA PARA SOLICTANTE DO PEDIDO
		endif				

		for i := 1 to len(_aEmail)
			if !_aEmail[i]
				alert('ERRO WORKFLOW ('+ str(i) +')')
			endif
		next

		restarea(_area)

	endif

	//dbCloseArea('SA1')
	//dbCloseArea('ZZ4')
return

//Workflow para controle de datas de produção no carregamento
User Function gjf31wf2(_Num,_cliente,_loja,_Precar)
	local _area
	local _cCliPP := alltrim(GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1')+_cliente+_loja,1))
	local _cMunic := GetAdvFVal('ZZ4','ZZ4_MUN',FWxfilial('ZZ4')+_Num,2)
	local _cDest  := GetAdvFVal('ZZ4','ZZ4_EMAILU',FWxfilial('ZZ4')+_Num,2)
	local _placa  := ''
	local _obs    := ''
	local _Usuar  := ''
	local i
	//local _cRepre := GetAdvFVal('ZZ4','ZZ4_REPRES',FWxfilial('ZZ4')+_Num,2)
	//local _cDesti  := GetAdvFVal('SA3','A3_EMAIL',FWxfilial('SA3')+_cRepre,1)

	if !empty(_cDest)

		_area := getarea()

		ZZ3->(DbSetOrder(2))
		if  ZZ3->(MsSeek(FWxfilial('ZZ3')+_PreCar))

			_placa := ZZ3->ZZ3_PLACA
			_obs   := ZZ3->ZZ3_OBS
			_Data  := dtoc(ZZ3->ZZ3_DTCAR)
			_Usuar := alltrim(ZZ3->ZZ3_USUAR)
			_Prod  := SZ8->Z8_DESCRI
		endif

		_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
		_cMens += 'Na data e hora da emissão deste email, no pre-pedido abaixo houve ocorrência' + chr(13) + chr(10)
		_cMens += 'de carregamento de caixa de produtos com data de produção fora do intervalo' + chr(13) + chr(10)
		_cMens += 'estipulado pelo setor comercial para carregamento.' + chr(13) + chr(10)
		_cMens +=   chr(13) + chr(10)
		_cMens += 'Pre-Pedido nr.: ' + alltrim(_Num) + chr(13) + chr(10)
		_cMens += 'Intervalo de datas de produção: de '+ dtoc(ZZ5->ZZ5_DTPINI) + ' até ' + dtoc(ZZ5->ZZ5_DTPFIM) + chr(13) + chr(10)
		_cMens += 'Cliente: ' + _cliente + '/' + _loja + '  ' + _cCliPP + chr(13) + chr(10)
		_cMens += 'Municipio: ' + _cMunic + chr(13) + chr(10)
		_cMens += 'Carregamento: ' + _PreCar + ' (' + _placa + ') ' + alltrim(_obs) + chr(13) + chr(10)
		_cMens += 'Data Carregamento: ' + _Data + chr(13) + chr(10)
		_cMens += 'Responsável Carregamento: ' + _Usuar + chr(13) + chr(10)
		_cMens += 'Produto: ('+ SZ8->Z8_COD + ') ' + _Prod + chr(13) + chr(10)
		_cMens += 'Caixa: '+ SZ8->Z8_CONTROL + chr(13) + chr(10)
		_cMens += 'Data de Produção: '+ dtoc(SZ8->Z8_DATAP) + chr(13) + chr(10)
		_cTit  := 'Workflow Frigorífico Silva: Controle de data de produção dos produtos em carregamento acionado!

		_aEmail := u_GJF54(_cMens,_cTit,alltrim(_cDest))
		//_aEmail := u_GJF54(_cMens,_cTit,alltrim(_cDest)+';'+alltrim(_cDesti))//ENVIA PARA SOLICTANTE DO PEDIDO + REPRESENTANTE

		for i := 1 to len(_aEmail)
			if !_aEmail[i]
				alert('ERRO WORKFLOW ('+ str(i) +')')
			endif
		next

		restarea(_area)

	endif

return

//Função destinada a verificar se a data de produção não é a mais nova
//e se tem caixas mais antigas a serem carregadas
Static Function ValDtP()
	ret  := .t.
	//Parametro que determina a verificação da caixa
	if GetMV('SI_VERPROD')
		//Verifica se o usuário setou no item do pre-pedido
		//para que seja feita a verificação
		if !empty(ZZ5->ZZ5_DTPINI) .and. !empty(ZZ5->ZZ5_DTPFIM)
			// Teste incluído em 28/02/2022 por solicitação do Mateus Silva
			//If SZ8->Z8_DATAP > ZZ5->ZZ5_DTPFIM + 5
			//	SomErr2()
			//	FWAlertHelp("Caixa fora da tolerância de 5 dias da data limite solicitada.", ;
			//				"Informe uma caixa que a data de produção seja válida.")
			//	ret := .f.
			//else
				if  (SZ8->Z8_DATAP >= ZZ5->ZZ5_DTPINI .and. SZ8->Z8_DATAP <= ZZ5->ZZ5_DTPFIM)
					ret := .t.
				else
					SomErr2()
					if msgbox('Caixa ' + SZ8->Z8_CONTROL + ' com data de produção fora do intervalo de datas '+;
					'de produção estipulado no Pré-pedido! Prossegue?','CONTROLE DE DATA DE PRODUÇÃO ATIVADO','YESNO')
						u_gjf31wf2(ZZ4->ZZ4_NUM,ZZ4->ZZ4_CODCLI,ZZ4->ZZ4_LOJA,ZZ4->ZZ4_PRECAR)
						ret := .t.
					else
						ret := .f.
					endif
				endif
			//endif
		endif
	endif

Return ret

Static Function ValDP2()
	ret  := .f.
	//Parametro que determina a verificação da caixa
	if GetMV('SI_VERPROD')
		//Verifica se o usuário setou no item do pre-pedido
		//para que seja feita a verificação
		if !empty(ZZ5->ZZ5_DTPINI) .and. !empty(ZZ5->ZZ5_DTPFIM)
			if  (SZ8->Z8_DATAP < ZZ5->ZZ5_DTPINI .OR. SZ8->Z8_DATAP > ZZ5->ZZ5_DTPFIM)
				ret := .t.
			endif
		endif
	endif

Return ret

//Novo browser para os pre-pedidos
User Function GJF31P()

	Local cUser := UsrRetName(RetCodUsr())
	Local cUsrPerm := alltrim(GetMv("SI_RETPALL"))	// Usuário com permissão de retornar pallets

	aObjects            := {}
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()
	_lAchou				:= .f.
	cPerg2   			:= "GJF31B"

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           :=aPosObj[1]
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	if !pergunte(cPerg2,.t.)
		return
	endif

	//Cabeçalhos das colunas
	aHeader  := {'','Numero','Status','Doca','Marca','Data','Codigo','Loja','Nome do Cliente','Cidade'}
	//Largura das colunas
	aLargCol := {20,   30   ,   40   ,  30  ,  20   ,  40  ,   30   ,  20  ,      130         ,   40   }

	// Vetor com elementos do Browse
	aBrowse := {}

	//Ordena por pre-carregamento e marcas
	ZZ4->(DbSetOrder(5))
	ZZ4->(MsSeek(FWxfilial('ZZ4') + ZZ3->ZZ3_NUM))
	while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4')  .and. ZZ4->ZZ4_PRECAR = ZZ3->ZZ3_NUM	

		_Stt := ZZ4->ZZ4_STATUS
		lCong := .F.

		//chama a função que filtra os tipos de produtos que serão apresentados na tela de pre-pedidos
		//se for somente caixas, somente peças, peças com caixas ou todos - por Mauricio Roehrs 14/04/15
		_lAchou := filtraProd(mv_par01,ZZ4->ZZ4_NUM)

		cQuery2 := "SELECT B1_COD AS CODIGO, ZZ5_ITEM AS ITEM, BM_GRUPO AS GRUPO"
		cQuery2 += " FROM" + retSqlTab("ZZ5")
		cQuery2 += " INNER JOIN " + retSqlTab("SB1") + " ON (B1_COD = ZZ5_COD)"
		cQuery2 += " INNER JOIN " + retSqlTab("SBM") + " ON (BM_GRUPO = B1_GRUPO)"
		cQuery2 += " WHERE" + retSqlFil('ZZ5') + " AND " + retSqlFil('SB1') + " AND " + retSqlFil('SBM')
		cQuery2 += " AND ZZ5_NUM = '" + ZZ4->ZZ4_NUM + "'"
		cQuery2 += " AND BM_FARM = 'C'"
		cQuery2 += " AND " + retSqlDel('ZZ5') + " AND " + retSqlDel('SB1') + " AND " + retSqlDel('SBM')

		cAlias2 := GetNextAlias()
		TCQuery cQuery2 new alias &cAlias2
		(cAlias2)->(dbGoTop())

		//verifica se houve retorno na query
		Count to nCount

		If nCount > 0
			lCong := .T.
		endif
		(cAlias2)->(dbCloseArea())

		if _lAchou
			aadd(aBrowse,{RetCores(_Stt, lCong),ZZ4->ZZ4_NUM,RetStatus(_Stt),ZZ4->ZZ4_LOCAR,ZZ4->ZZ4_MARCA,;
			ZZ4->ZZ4_DATA,ZZ4->ZZ4_CODCLI,ZZ4->ZZ4_LOJA,ZZ4->ZZ4_NOME,ZZ4->ZZ4_MUN})
		endif

		ZZ4->(DbSkip())

	enddo

	//DEFINE DIALOG oDlg TITLE "Pre-pedidos" FROM aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] PIXEL
	DEFINE DIALOG oDlg TITLE "Pre-pedidos" FROM 020,50 To 700,1000 PIXEL
	// Cria Browse
	oBrowse := TCBrowse():New(00,60,400,280,,aHeader,aLargCol,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	// Seta vetor para a browse
	oBrowse:SetArray(aBrowse)

	// Monta a linha a ser exibina no Browse
	if len(aBrowse) <= 0  //verifica se tem algo no vetor para não dar error.log

		oBrowse:bLine := {||{'','','','','','','','','',''} }

	else

		oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAT,04],;
		aBrowse[oBrowse:nAT,05],aBrowse[oBrowse:nAT,06],aBrowse[oBrowse:nAT,07],;
		aBrowse[oBrowse:nAT,08],aBrowse[oBrowse:nAT,09],aBrowse[oBrowse:nAT,10]} }
	endif

	oBrowse:nScrollType := 1

	TButton():New( 015, 005, "Visualizar",   oDlg,{|| ChamaVC()     },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 030, 005, "Caixas",       oDlg,{|| ChamaCaixas() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 045, 005, "Peças",        oDlg,{|| ChamaPecas()  },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 060, 005, "Cons.Caixas" , oDlg,{|| ChamaCons()   },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 075, 005, "Excl.Caixas" , oDlg,{|| ChamaExc()    },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 090, 005, "Encerrar"    , oDlg,{|| ChamaEnc()    },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 105, 005, "Pallets"     , oDlg,{|| u_dti73(ZZ3->ZZ3_NUM, aBrowse[oBrowse:nAt,02])  },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 120, 005, "Tot. Pallets", oDlg,{|| ChamaTot()    },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 135, 005, "Relatorio",    oDlg,{|| u_gjf31rel()  },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 150, 005, "Rem. Valid.",  oDlg,{|| u_gjf31exv()  },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 165, 005, "Lib. Ped."  ,  oDlg,{|| u_gjf31lib()  },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	if cUser $ cUsrPerm
		TButton():New( 180, 005, "Ret. Pallets",   oDlg,{|| u_dti184()  },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
		TButton():New( 195, 005, "Sair",         oDlg,{|| oDlg:end()    },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	else
		TButton():New( 180, 005, "Sair",         oDlg,{|| oDlg:end()    },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	endif

	ACTIVATE DIALOG oDlg CENTERED

	pergunte(cPerg,.f.)

Return

//Função para filtrar o tipo de produto do pre-pedido
Static Function filtraProd(_nTipo,_cPreped)

	Local _lRet    := .f.
	Local _cTpProd := ''

	ZZ5->(DbSetOrder(1))
	ZZ5->(DbGoTop())
	if ZZ5->(MsSeek(FWxFilial('ZZ5') + ZZ4->ZZ4_NUM))
		while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxFilial('ZZ5') .and. ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM

			_cTpProd := GetAdvFVal('SB1','B1_SEGUM',FWxFilial('SB1') + alltrim(ZZ5->ZZ5_COD),1)

			//se for somente caixas
			if _nTipo = 1
				if alltrim(_cTpProd) == 'CX'
					_lRet := .t.
				endif

				//se for somente peças
			elseif _nTipo = 2
				if alltrim(_cTpProd) == 'PC'
					_lRet := .t.
				endif

				//se for todos
			elseif _nTipo = 3
				_lRet := .t.
			endif

			ZZ5->(dbSkip())
		enddo

	endif

return _lRet

//Função auxiliar para retorno do status dos pre-pedidos e montar o grid
Static Function RetStatus(_Stt)
	Local ret := iif(_Stt = 'B','Bloqueado',;
	iif(_Stt = 'L','Liberado' ,;
	iif(_Stt = 'E','Encerrado',;
	iif(_Stt = 'C','Carregando...',;
	iif(_Stt = 'S','Em Espera',;
	iif(_Stt = 'F','Faturado',''))))))
return ret

//Função auxiliar para retorno das cores da legenda
Static Function RetCores(_Stt, lCong)

	local ret   := iif(lcong = .T. .and. !(_Stt $ 'E/F'), LoadBitmap(GetResources(),'br_branco'),iif(_Stt = 'L',LoadBitmap(GetResources(),'br_verde'),;
	iif(_Stt = 'C', LoadBitmap(GetResources(),'br_amarelo'),iif(_Stt = 'S',LoadBitmap(GetResources(),'br_laranja'),;
	iif(_Stt = 'E', LoadBitmap(GetResources(),'br_vermelho'),iif(_Stt = 'F',LoadBitmap(GetResources(),'br_preto'),;
	iif(_Stt = 'B', LoadBitmap(GetResources(),'br_azul'),'')))))))

return ret

//Função auxiliar para chamar a tela de carregamento de caixas
Static Function ChamaCaixas()

	_cNumPP := aBrowse[oBrowse:nAt,02]

	ZZ4->(DbSelectArea('ZZ4'))
	ZZ4->(DbSetOrder(1))
	ZZ4->(MsSeek(FWxfilial('ZZ4')+ZZ3->ZZ3_NUM+_cNumPP))

	u_gjf31Cai()
return

//Função auxiliar para chamar a tela de carregamento de peças
Static Function ChamaPecas()

	_cNumPP := aBrowse[oBrowse:nAt,02]

	ZZ4->(DbSelectArea('ZZ4'))
	ZZ4->(DbSetOrder(1))
	ZZ4->(MsSeek(FWxfilial('ZZ4')+ZZ3->ZZ3_NUM+_cNumPP))

	u_gjf31Pec()
return

//Função auxiliar para chamar a tela de consulta de caixas
Static Function ChamaCons()

	_cNumPP := aBrowse[oBrowse:nAt,02]

	ZZ4->(DbSelectArea('ZZ4'))
	ZZ4->(DbSetOrder(1))
	ZZ4->(MsSeek(FWxfilial('ZZ4')+ZZ3->ZZ3_NUM+_cNumPP))

	u_gjf31Ver()
return

//Função auxiliar para chamar a tela de exclusão de caixas
Static Function ChamaExc()

	_cNumPP := aBrowse[oBrowse:nAt,02]

	ZZ4->(DbSelectArea('ZZ4'))
	ZZ4->(DbSetOrder(1))
	ZZ4->(MsSeek(FWxfilial('ZZ4') + ZZ3->ZZ3_NUM + _cNumPP))

	u_gjf31Exc()
return

//Função auxiliar para chamar a tela de encerramento
Static Function ChamaEnc()

	_cNumPP := aBrowse[oBrowse:nAt,02]

	ZZ4->(DbSelectArea('ZZ4'))
	ZZ4->(DbSetOrder(1))
	ZZ4->(MsSeek(FWxfilial('ZZ4') + ZZ3->ZZ3_NUM + _cNumPP))

	u_gjf31epp()

	aBrowse[oBrowse:nAt,01] := RetCores(ZZ4->ZZ4_STATUS)
	aBrowse[oBrowse:nAt,03] := RetStatus(ZZ4->ZZ4_STATUS)
	oBrowse:DrawSelect()

return

//Função auxiliar para chamar a tela de visualização de caixas
Static Function ChamaVC()

	_cNumPP := aBrowse[oBrowse:nAt,02]

	ZZ4->(DbSelectArea('ZZ4'))
	ZZ4->(DbSetOrder(1))
	ZZ4->(MsSeek(FWxfilial('ZZ4') + ZZ3->ZZ3_NUM + _cNumPP))

	u_gjf31VisP()

return

//Função auxiliar para chamar a tela de visualização de Tot. Pallets Feito por Fabian Maurer em 21/10/19
Static Function ChamaTot()

	_cNumPP := aBrowse[oBrowse:nAt,02]

	ZZ4->(DbSelectArea('ZZ4'))
	ZZ4->(DbSetOrder(1))
	ZZ4->(MsSeek(FWxfilial('ZZ4') + ZZ3->ZZ3_NUM + _cNumPP))

	u_gjf31TotP()

return

//Funçao para exclusão de pallet caso não haja mais caixas nele
User Function gjf31PA(_Pallet)
	if !empty(_Pallet)
		SZP->(DbSetOrder(1))
		if SZP->(MsSeek(FWxfilial('SZP')+_Pallet))
			do case
				case SZP->ZP_TIPO == 'PA'
				SZ8->(DbSetOrder(19))
				SZ8->(DbGoTop())
				if !SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + SZP->ZP_COD))
					reclock('SZP',.f.)
					DbDelete()
					msunlock()
				endif
				case SZP->ZP_TIPO == 'MP'
				ZAS->(DbSetOrder(6))
				ZAS->(DbGoTop())
				if !ZAS->(MsSeek(FWxFilial('ZAS') + SZP->ZP_COD))
					reclock('SZP',.f.)
					dbDelete()
					msunlock()
				endif
			endcase
		endif
	endif

return

//Função que atualiza tabela ZAO - correlação cliente X caixas plásticas
Static Function AtuZAO(_CodCli,_Lojcli,_CodPrev,_Prod,_DescP)

	Local _CodEmb  := ''
	Local _DescEmb := ''
	Local _CodGrp  := ''

	ZAN->(DbSetOrder(1))
	if ZAN->(MsSeek(FWxfilial('ZAN')+alltrim(_CodPrev)))

		while ZAN->(!eof()) .and. ZAN->ZAN_FILIAL = FWxFilial('ZAN') .and. ZAN->ZAN_PREEMB == alltrim(_CodPrev)
			_CodEmb  := ZAN->ZAN_COD
			_DescEmb := ZAN->ZAN_DESC

			DbSelectArea('SB1')
			_CodGrp := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+_CodEmb,1)

			if _CodGrp $ '1202/1313'
				ZAO->(DbSetOrder(1))
				if !ZAO->(MsSeek(FWxfilial('ZAO')+alltrim(_CodCli)+alltrim(_Lojcli)+alltrim(_Prod)))
					reclock('ZAO',.t.)
					ZAO->ZAO_FILIAL := FWxfilial('ZAO')
					ZAO->ZAO_CODCX  := _CodEmb
					ZAO->ZAO_DESCCX := _DescEmb
					ZAO->ZAO_CLIENT := _CodCli
					ZAO->ZAO_LOJA   := _LojCli
					ZAO->ZAO_PRODUT := _Prod
					ZAO->ZAO_DESCPR := _DescP
					msunlock()
				endif
			endif

			ZAN->(dbSkip())
		enddo
	endif

return

//função para conectar na balança
Static Function conectBal()

	//Define o IP da balança a se utilizada
	_cEst   := getComputerName()
	//_cEst := 'MDS02'

	_cIpBal := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + iif(_cEst = 'EXP00','BEXP0',;
	iif(_cEst = 'EXP01','BEXP1', iif(_cEst = 'EXP02','BEXP2','XXXXX'))),1))

	if empty(_cIpBal)
		alert('Endereço IP da balança não encontrado!')
		return
	endif

	//Se a balança já estiver conectada, desconecta...
	if _lBal
		oObj:CloseConnection()
	endif

	oObj  := tSocketClient():New()
	IF(_cIpBal <> '10.6.20.105')
		nResp := oObj:Connect( 9092, _cIpBal,1000)  //9092
	ELSE
		nResp := oObj:Connect( 9000, _cIpBal,1000)  //9000
	ENDIF
	nResp := oObj:Send( 'Teste' )

	_lBal := .t.
return



/*backup temporario do filtraprod()

//se for somente peças com caixas
elseif _nTipo = 3
if _cTpProd = 'PC'
_lPc := .t.
endif

if _lPc
if _cTpProd = 'CX'
_lCx := .t.
endif
endif

//ultima verificação caso seja somente peças com caixas
if _nTipo = 3
if !_lPc .or. !_lCx
_lRet := .f.
endif
endif

*/

Static Function _GetPar1()

	_cRet := GetMv("SI_%TRAS")

Return(_cRet)

Static Function _GetPar2()

	_cRet := GetMv("SI_%DIAN")

Return(_cRet)

Static Function _GetPar3()

	_cRet := GetMv("SI_%COST")

Return(_cRet)
