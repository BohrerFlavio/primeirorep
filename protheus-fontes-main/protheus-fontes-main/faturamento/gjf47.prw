#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
/*                                                                          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF47     ºAutor  ³Giuliano Forgiarini º Data ³  03/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para pré-faturamento de pré-carregamentos           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaoms - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF47()

	lOk := .f.
	Private aCores   := {}
	Private aCores2  := {}

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

	Private cPerg   := "GJF47"
	Private cCadastro := "Previsão de Gerenciamento de Pré-carregamentos e pré-pedidos"
	Private aRotina  := MenuDef()                             // Chamada da funcao menudef() que contem aRotina
	Private _cFatConv := GETMV('SI_AJCONV')

	if !pergunte(cPerg,.t.)
		return
	endif

	Private area := getarea()

	Private cString := "ZZ3"  

	if _cFatConv = 'S'
		msgbox('Ajuste do fator de conversão nos produtos PA/PR para geração do SPED está ativado!','IMPOSSÍVEL FATURAR!','STOP')
		return
	endif

	aIndZZ3   	:= {}						                                    //Indice para a filtragem

	cCondicao := "ZZ3->ZZ3_DTCAR >= mv_par01 .and. ZZ3->ZZ3_DTCAR <= mv_par02 .and."+;
	" ZZ3->ZZ3_STATUS != 'A' .and. ZZ3->ZZ3_FILIAL = '" + FWxfilial('ZZ3') + "'"  //String para filtro 
	if mv_par03 = 1   
		cCondicao += " .and. ZZ3->ZZ3_STATUS = 'E'
	elseif mv_par03 = 2
		cCondicao += " .and. ZZ3->ZZ3_STATUS = 'F'
	endif

	FilBrowse("ZZ3",@aIndZZ3,@cCondicao)                                        //Aplicação da filtragem

	dbSelectArea(cString)
	ZZ3->(dbSetOrder(1))
	ZZ3->(dbgobottom())

	mBrowse(6,1,22,75,cString, ,,,,2,aCores,,,,{|x| AutoRefresh(x)}) 
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores    

	If ( Len(aIndZZ3)>0 )
		EndFilBrw("ZZ3",aIndZZ3)                                                    //Encerra o filtro e refaz os índices padrões
	endif     

	If Select('ZZ3')<>0                                                           
		ZZ3->(dbCloseArea())
	Endif

	restarea(area)

	aRotina := {}

return


// Função para ativa opção de visualização da legenda
User Function gjf47lPC
	BrwLegenda('Pré-Carregamentos','Legenda',aCores2)
return


Static Function MenuDef()

	Private aRotina := { {"Pesquisar"     , "AxPesqui"      , 0 , 1 , 0 , .F. } ,;
	{"&Gerar"        , "u_gjf47ped"    , 0 , 3 , 0 , NIL } ,;
	{"&Relatorio"    , "u_gjf47rel"    , 0 , 3 , 0 , NIL } ,; 
	{"&Pre-Pedidos"  , "u_gjf47pp('P')", 0 , 2 , 0 , NIL } ,; 
	{"Legenda"       , "u_gjf47lPC"    , 0 , 2 , 0 , NIL } }
Return aRotina


User Function gjf47ped()
	/*
	if !(ZZ3->ZZ3_STATUS $ 'E/F')
	msgbox('Status Impede faturamento!','OPERAÇÃO INVÁLIDA!','STOP')   
	return
	endif
	*/
	if ZZ3->ZZ3_STATUS = 'F' .and. mv_par04 = 1
		msgbox('Pré-carregamento já faturado! Impossível refaturar!','OPERAÇÃO INVÁLIDA!','STOP')   
		return 
	elseif ZZ3->ZZ3_STATUS = 'E' .and. mv_par04 = 2
		msgbox('Pré-carregamento não faturado! Impossível refaturar!','OPERAÇÃO INVÁLIDA!','STOP')   
		return 
	endif 

	ZZ4->(dbgotop()) 
	ZZ4->(MsSeek(FWxfilial('ZZ4')+ZZ3->ZZ3_NUM)) 

	_cPreCar := ZZ3->ZZ3_NUM
	_lOkPre  := .t.
	u_fb_gped2('C',_cPreCar)

	pergunte(cPerg,.f.)
	Dbselectarea('ZZ4')
	ZZ4->(Dbsetorder(1))
	ZZ4->(dbgotop())
	ZZ4->(MsSeek(FWxfilial('ZZ4')+_cPreCar))
	While ZZ4->(!eof()) .and. FWxfilial('ZZ4') = ZZ4->ZZ4_FILIAL .and. ZZ4->ZZ4_PRECAR = _cPreCar
		if ZZ4->ZZ4_STATUS <> 'F' 
			_lOkPre  := .f. 
			exit
		endif
		ZZ4->(dbskip())
	enddo  

	if _lOkPre .and. mv_par04 = 1
		Dbselectarea('ZZ3')
		ZZ3->(DbsetOrder(2))
		ZZ3->(dbgotop())
		if ZZ3->(MsSeek(FWxfilial('ZZ3') + alltrim(_cPreCar)))
			reclock('ZZ3',.f.)
			ZZ3->ZZ3_STATUS := 'F'
			if empty(ZZ3->ZZ3_DTFIM)
				ZZ3->ZZ3_DTFIM := ddatabase
			endif
			if empty(ZZ3->ZZ3_HFIM)
				ZZ3->ZZ3_HFIM := time()
			endif
			msunlock()
			if cEmpAnt = '01'
				//Esse bloco serve para regravar a hora de data de faturamento nas caixas carregadas
				SZ8->(DbSetOrder(5))
				if SZ8->(MsSeek(FWxfilial('SZ8')+cFilial+_cPreCar))
					While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and.;
					SZ8->Z8_FIL = cFilial .and.;
					SZ8->Z8_PRECAR = _cPrecar
						reclock('SZ8',.f.)
						SZ8->Z8_DATAS   := ddatabase
						SZ8->Z8_HORAS   := time()
						SZ8->Z8_DTRANSF := ddatabase
						msunlock()

						//Caso haja registro de tranferencia, ajusta a data dela também
						ZAE->(DbSetOrder(2))
						if ZAE->(MsSeek(FWxfilial('ZAE')+SZ8->(Z8_CONTROL+Z8_PRECAR)+cFilial))
							reclock('ZAE',.f.)
							ZAE->ZAE_DATAM := ddatabase
							msunlock()
						endif
						SZ8->(DbSkip())
					enddo
				endif
				msgbox('A data de saída das caixas foi atualizada com a data de fatura!','CARREGAMENTO FATURADO','INFO')
				u_gjf31his('Carregamento faturado!')  		
				u_devSeparacao(_cPreCar)		
			endif
		endif
	elseif _lOkPre .and. mv_par04 = 2
		u_gjf31his('Carregamento refaturado!') 
	endif

	DbCloseArea('ZZ4')

	FilBrowse("ZZ3",@aIndZZ3,@cCondicao) 

Return


User Function gjf47rel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio de"
	Local cDesc2         := "conferencia de geração de pedidos de venda através da"
	Local cDesc3         := "geração automática pelos pré-pedidos e pré-carregamentos "
	//Local cPict          := "já encerrados."
	Local titulo       	 := "CONFERENCIA DE GERAÇÃO DE PEDIDOS"
	Local nLin         	 := 80
	Local Cabec1       	 := " Codigo   Data        Placa       Observacao"
	Local Cabec2       	 := "    Pedido          Cliente/Loja                  Operacao        Desc. Unit?"
	//Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "GJF47" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	//Private cbtxt      := Space(10)
	Private cbcont     	 := 00
	Private CONTFL     	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "GJF47" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix      := 0.00
	Private TotPeso      := 0.00

	if ZZ3->ZZ3_STATUS != 'F'
		msgbox('Este pre-carregamento ainda não foi faturado!','IMPRESSAO IMPOSSIVEL','STOP')
		return .f.
	endif

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ3',NomeProg,,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,.f.,.f.,)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZZ3')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//Local nOrdem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	ZZ4->(dbsetorder(1))
	ZZ4->(MsSeek(FWxfilial('ZZ4') + ZZ3->ZZ3_NUM))
	ZZ4->(SetRegua(RecCount())) 

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9  

	@nlin,01 psay ZZ3->ZZ3_NUM
	@nlin,10 psay ZZ3->ZZ3_DTCAR
	@nlin,22 psay ZZ3->ZZ3_PLACA
	@nlin,34 psay ZZ3->ZZ3_OBS

	nlin += 2 

	While ZZ4->(!EOF()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4') .and. ZZ4->ZZ4_PRECAR = ZZ3->ZZ3_NUM

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif  

		@nlin,03 psay ZZ4->ZZ4_NUMPED
		@nlin,15 psay ZZ4->ZZ4_CODCLI + "/" + ZZ4->ZZ4_LOJA
		@nlin,26 psay ZZ4->ZZ4_NOME
		do case
			case ZZ4->ZZ4_TPOPER = 'V'
			@nlin,51 psay 'Venda'
			case ZZ4->ZZ4_TPOPER = 'T'
			@nlin,51 psay 'Transferencia'
			case ZZ4->ZZ4_TPOPER = 'R'
			@nlin,51 psay 'Remessa'
			case ZZ4->ZZ4_TPOPER = 'C'
			@nlin,51 psay 'Compra'
			case ZZ4->ZZ4_TPOPER = 'B'
			@nlin,51 psay 'Bonificação'
		endcase 

		ZZ5->(dbsetorder(1)) 
		ZZ5->(MsSeek(FWxfilial('ZZ5') + ZZ4->ZZ4_NUM,.t.))
		_cBo := .f.
		while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM

			if ZZ5->ZZ5_TPBONI = 'D'
				_cBo := .t. 
				exit
			endif

			ZZ5->(dbskip())
		enddo

		ZZ5->(dbgotop())

		if _cBo
			@nlin,68 psay 'Sim'
		else
			@nlin,68 psay 'Nao'
		endif

		nLin++ // Avanca a linha de impressao

		ZZ4->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

//Estas rotinas abaixo são validações nos campos de quantidade dos pedidos de venda
//(SC5 e SC6)para que não se alterem o valor caso estes sejam gerados automaticamente
User Function gjf47vl() 
	//Função para validar a redigitação da quantidade - 1 unidade de medida
	_cNum  := M->C5_NUM
	_cItem := GDFieldGet('C6_ITEM')
	_cProd := GDFieldGet('C6_PRODUTO')  
	_nQuantUlt := GetAdvFVal('SC6','C6_QTDVEN',FWxfilial('SC6')+_cNum + _cItem + _cProd,1)
	_nPrecoUlt := GetAdvFVal('SC6','C6_PRCVEN',FWxfilial('SC6')+_cNum + _cItem + _cProd,1)
	_nQuantNov := M->C6_QTDVEN
	//_nPrecoNov := M->C6_PRCVEN

	if ALTERA
		if empty(M->C5_PRECAR)
			return .t.
		else 
			if _nQuantUlt <> _nQuantNov
				msgbox('Pedido gerado automaticamente!','ALTERAÇAO IMPOSSIVEL','STOP')
				return .f.
			endif 
			/*
			if _nPrecoUlt <> _nPrecoNov
			msgbox('Pedido gerado automaticamente!','ALTERAÇAO IMPOSSIVEL','STOP')
			return .f.
			endif
			*/
		endif
	endif

return .t.

User Function gjf47vl2() 
	//Função para validar a redigitação do preco unitario
	_cNum  := M->C5_NUM
	_cItem := GDFieldGet('C6_ITEM')
	_cProd := GDFieldGet('C6_PRODUTO')  
	_nQuantUlt := GetAdvFVal('SC6','C6_QTDVEN',FWxfilial('SC6')+_cNum + _cItem + _cProd,1)
	_nPrecoUlt := GetAdvFVal('SC6','C6_PRCVEN',FWxfilial('SC6')+_cNum + _cItem + _cProd,1)
	//_nQuantNov := M->C6_QTDVEN
	_nPrecoNov := M->C6_PRCVEN

	if ALTERA
		if empty(M->C5_PRECAR) .or. M->C5_TPOPER = 'E'
			return .t.
		else 
			/*
			if _nQuantUlt <> _nQuantNov
			msgbox('Pedido gerado automaticamente!','ALTERAÇAO IMPOSSIVEL','STOP')
			return .f.
			endif 
			*/

			if _nPrecoUlt <> _nPrecoNov
				msgbox('Pedido gerado automaticamente!','ALTERAÇAO IMPOSSIVEL','STOP')
				return .f.
			endif

		endif
	endif

return .t.


//Função que retorna o TES conforme várias regras 
User Function gjf47TES(_cli,_cProd)
	Local _grp     := ''
	Local _tesP    := ''
	Local _cEstCli := ''
	//Local _cTipCli := ''

	DbSelectarea('SB1')
	_grp      := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+_cProd,1)
	_tesP     := GetAdvFVal('SB1','B1_TS',FWxfilial('SB1')+_cProd,1)
	_cNCM     := GetAdvFVal('SB1','B1_POSIPI',FWxfilial('SB1')+_cProd,1)
	_cEstCli  := GetAdvFVal("SA1","A1_EST",FWxFilial("SA1")+_cli,1)
	_cTipocli := GetAdvFVal("SA1","A1_TIPOCLI",FWxFilial("SA1")+_cli,1)
	_cOrigem  := GetAdvFVal('SB1','B1_ORIGEM',FWxfilial('SB1')+_cProd,1)

	//Se não tem TES padrão então percorre regras 
	//* Alterado conforme MP 609/2013 desde 08/03/2013
	if empty(_tesP)

		//Se for graxaria...
		if cEmpAnt = '08'
			if alltrim(_cProd) $ '000001/000002/000947/000948/000949/001606'
				_TES := IIF(_cEstCli == "RS", "503", "565")
				return _TES
			endif
		endif

		_TES      := GetAdvFVal('SBM','BM_TESCF',FWxfilial('SBM') + _grp,1)
		_TESAlt   := IIF(_cEstCli == "RS", "521", "571")

		if empty(_TES)
			_TES := _TESAlt
		endif

		if substr(_grp,1,1) = '7' .and. _grp <> '7400'
			if _cEstCli = "RS"
				_TES := "521" //"600" *
			elseif _cEstCli $ 'MS/MT/GO/DF/BA/SE/AL/PE/PB/RN/CE/MA/PI/TO/PA/AP/RR/AM/AC/RO/ES' //estados norte/nordeste
				_TES := "507" //"632" *
			else
				_TES := "571" //"597" *
			endif
		endif

		if substr(_grp,1,1) = '8' .and. _grp <> '8400'
			if _cEstCli = "RS"
				_TES :=   "523" //modificado Fabian 13/12/16 estava "642" 
			elseif _cEstCli $ 'MS/MT/GO/DF/BA/SE/AL/PE/PB/RN/CE/MA/PI/TO/PA/AP/RR/AM/AC/RO/ES' //estados norte/nordeste
				_TES := "633" //"626"*
			else
				_TES := "572" //"598"*
			endif
		endif

		if substr(_grp,1,1) = '5' .and. !(_grp $ '5400/5420')
			if _cEstCli = "RS"
				_TES := "521"
			elseif _cEstCli $ 'MS/MT/GO/DF/BA/SE/AL/PE/PB/RN/CE/MA/PI/TO/PA/AP/RR/AM/AC/RO/ES' //estados norte/nordeste
				_TES := "507"
			else
				_TES := "571"
			endif
			/*
			if _grp $ '5134/5135/5136'
			if _cEstCli = "RS"
			_TES := "600"
			else
			_TES := "597"
			endif
			endif
			*/
		endif

		if substr(_grp,1,1) = '6' .and. _grp <> '6400'
			if _cEstCli = "RS"
				_TES := "523" //modificado por Fabian 13/12/16 estava "642"
			elseif _cEstCli $ 'MS/MT/GO/DF/BA/SE/AL/PE/PB/RN/CE/MA/PI/TO/PA/AP/RR/AM/AC/RO/ES' //estados norte/nordeste
				_TES := "633"
			else
				_TES := "572"
			endif
		endif

		//Se tem TES padrão permanece
		// Se o produto tiver NCM de estomago, tripa, bexiga, entre outros
		//if alltrim(_cNCM) $ '02062200/05040011/05040090/05069000' solicitação de Fabiane Pozzer para retirada do ncm 02062200 dia 19/03/15 por Fabian Maurer
		//Retirado codigo 05069000 por solicitação de Fabiane Pozzer no dia 12/05/16 feito por Fabian Maurer
		if alltrim(_cNCM) $ '05040011/05040090'	
			if substr(_grp,1,1) $ '6/8'
				if _cEstCli = "RS"
					_TES := "601" // //modificado por Fabian 13/12/16 estava "643"
				elseif _cEstCli $ 'MS/MT/GO/DF/BA/SE/AL/PE/PB/RN/CE/MA/PI/TO/PA/AP/RR/AM/AC/RO/ES' //estados norte/nordeste/centro-oeste
					_TES := "626"
				else
					_TES := "598"
				endif

			else
				if _cEstCli = "RS"
					//_TES := "600" Alterado solicitação Fabiane Pozzer em 25/05/16 por Fabian Maurer, motivo calculo indevido do ST
					if cFilAnt = '00'
						_TES := "663"
					elseif cFilAnt = '01'
						_TES := "638"								
					endif

				elseif _cEstCli $ 'MS/MT/GO/DF/BA/SE/AL/PE/PB/RN/CE/MA/PI/TO/PA/AP/RR/AM/AC/RO/ES' //estados norte/nordeste
					_TES := "632"
				else
					_TES := "597"
				endif

			endif
		endif

		//verificação do TES para NCM de chifre
		if alltrim(_cNCM) == '05079000'
			if _cEstCli = "RS"
				_TES := "666"
			else
				_TES := "563"
			endif
		endif	

		//Solicitação Fabiane CTB para colocar esta nova verificação feita por Fabian Maurer no dia 05/04/17
		if alltrim(_cNCM) == '16025000'
			if _cEstCli = "RS"
				_TES := "690"
			elseif _cEstCli $ 'SC/MG/PR/MT/AL/AP/DF/SP'
				_TES := "691"
			elseif	_cEstCli = "RJ"
				_TES := "694"
			endif
		endif

		if alltrim(_cNCM) == '15029000'
			if _cEstCli = "RS" .and. substr(_grp,1,1) = '5'
				_TES := "600"
			elseif _cEstCli <> 'RS' .and. substr(_grp,1,1) = '5'
				_TES := "597"
			endif
		endif
		//alterações a partir de 08/03/2013
		//if (_cOrigem = '1' .and. _cEstCli <> 'RS' .and. substr(_grp,1,1) = '8' .and. _grp <> '8400') .or.;
		//if (_cOrigem $ '1/2' .and. _cEstCli <> 'RS' .and. alltrim(_cNCM) $ '02062200/05040011/05040090') Solicitação de Fabiane Pozzer de retirada de NCM 02062200 dia 19/03/15 por Fabian Maurer
		if (_cOrigem $ '1/2' .and. _cEstCli <> 'RS' .and. alltrim(_cNCM) $ '05040011/05040090')
			_TES := '634'
		endif

		if (_cOrigem $ '1/2' .and. _cEstCli <> 'RS' .and. substr(_grp,1,1) $ '6/8' .and. !(_grp $ '6400/8400') )
			_TES := '635'
		endif

		//nova regra criada em 29/08/13 Tratamento para Consumidor final industria no RS
		if  _cTipoCli $ '06/22' .and. _cEstCli = 'RS' .and. _cNCM != '16025000'

			//if substr(_grp,1,1) $ '5/7' .and. !(_grp $ '5400/5420/7400/7420')   .and. !(alltrim(_cNCM) $ '02062200/05040011/05040090/05069000')Solicitação de Fabiane Pozzer de retirada de NCM 02062200 dia 19/03/15 por Fabian Maurer
			if substr(_grp,1,1) $ '5/7' .and. !(_grp $ '5400/5420/7400/7420')   .and. !(alltrim(_cNCM) $ '05040011/05040090/05069000')
				//Dia 23/10/22 - Regra criada pedido por Fabiane para tipo cliente  = 22
				if _cTipoCli = '22'
					_TES := "761"
				else
					_TES := "661"
				Endif
				//elseif alltrim(_cNCM) $ '02062200/05040011/05040090/05069000' Solicitação de Fabiane Pozzer de retirada de NCM 02062200 dia 19/03/15 por Fabian Maurer
			elseif substr(_grp,1,1) $ '6/8' .and. alltrim(_cNCM) $ '05040011/05040090/05069000'
				_TES := "598"
			elseif alltrim(_cNCM) $ '05040011/05040090/05069000'
				if cFilAnt = '00'
					_TES := "663"    
				elseif cFilAnt = '01'
					_TES := "638"   
				endif			
			endif
		endif

	else
		_TES := _tesP
	endif

Return _TES

//retorna a conta contabil
User Function gjf47Ct(_cli,_cProd)
	Local _grp     := ''
	Local _tesP    := ''
	Local _cEstCli := ''
	//Local _cTipCli := ''
	Local _cCtCtb  := ''

	DbSelectarea('SB1')
	_grp      := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+_cProd,1)
	_tesP     := GetAdvFVal('SB1','B1_TS',FWxfilial('SB1')+_cProd,1)
	_cNCM     := GetAdvFVal('SB1','B1_POSIPI',FWxfilial('SB1')+_cProd,1)
	_cEstCli  := GetAdvFVal("SA1","A1_EST",FWxFilial("SA1")+_cli,1)
	_cTipocli := GetAdvFVal("SA1","A1_TIPOCLI",FWxFilial("SA1")+_cli,1)
	_cOrigem  := GetAdvFVal('SB1','B1_ORIGEM',FWxfilial('SB1')+_cProd,1)

	if (substr(_grp,1,1) = '5' .or. substr(_grp,1,1) = '7') .and. _cEstCli <> 'EX'
		_cCtCtb := '4101011001'	
	endif

	if (substr(_grp,1,1) = '5' .or. substr(_grp,1,1) = '7') .and. _cEstCli == 'EX'
		_cCtCtb := '4101011002'	
	endif

	if (substr(_grp,1,1) = '6' .or. substr(_grp,1,1) = '8')
		_cCtCtb := '4101011003'	
	endif

return _cCtCtb

//PRE-PEDIDOS DO PRE-CARREGAMENTO SELECIONADO
User Function gjf47pp(_Tipo)

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

	bLegenda1 := "ZZ4->ZZ4_STATUS == 'B'"         // bloqueado
	bLegenda2 := "ZZ4->ZZ4_STATUS == 'C'"         // carregando
	bLegenda3 := "ZZ4->ZZ4_STATUS == 'L'"         // liberado
	bLegenda4 := "ZZ4->ZZ4_STATUS == 'E'"         // encerrado
	bLegenda5 := "ZZ4->ZZ4_STATUS == 'S'"         // em espera   
	bLegenda6 := "ZZ4->ZZ4_STATUS == 'F'"         // Faturado

	aCores4:= { {'BR_AZUL'   ,'Bloqueado'  },;
	{'BR_AMARELO' ,'Carregando'},;
	{'BR_VERDE'   ,'Liberado' },;
	{'BR_VERMELHO','Encerrado' },;
	{'BR_LARANJA' ,'Em Espera' } ,;
	{'BR_PRETO' ,'Faturado ' }}

	aCores3 := {{bLegenda1, 'BR_AZUL'     },;     // bloqueado
	{bLegenda2, 'BR_AMARELO'  },;     // carregando
	{bLegenda3, 'BR_VERDE'    },;     // erado
	{bLegenda4, 'BR_VERMELHO' },;     // Encerrado
	{bLegenda5, 'BR_LARANJA'  },;     // Em Espera
	{bLegenda6, 'BR_PRETO'    }}        // Faturado

	Private cCadastro := "Pré-Pedidos de"
	Private aRotinaBKP := aRotina
	Private aRotina    := {	{ "Pesquisa",  "AxPesqui"  ,  0, 1},; 	//"Pesquisar"  
	{ "Faturar",  "u_gjf47rf", 0, 2},; 	//"Consultar"
	{ "Visualizar", "u_gjf28Visu",0, 2},; 	//"Visualizar"
	{ "Legenda",    "u_gjf52L", 0, 1}}      //"Legenda"
	cString := 'ZZ4'  

	aIndZZ4_   	:= {}
	cCondicao3 := "ZZ4->ZZ4_PRECAR = " + "'"+ZZ3->ZZ3_NUM+"' .and. ZZ4->ZZ4_FILIAL = '" + FWxfilial('ZZ4') + "'"
	pergunte(cPerg,.f.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a Filtragem                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FilBrowse("ZZ4",@aIndZZ4_,@cCondicao3)

	dbSelectArea(cString)
	ZZ4->(dbSetOrder(1))

	mBrowse(6,1,22,75,cString, ,,,,1     ,aCores3,,,,{|x| AutoRefresh(x)}) 
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores

	DbSelectArea('ZZ4')

	If ( Len(aIndZZ4_)>0 )
		EndFilBrw("ZZ4",aIndZZ4_)
	endif													//Encerra o filtro e refaz os índices padrões   

	aRotina := aRotinaBKP

	restarea(area)

return


User Function gjf47rf()
	/*
	if !(ZZ3->ZZ3_STATUS $ 'E/F')
	msgbox('Status Impede faturamento!','OPERAÇÃO INVÁLIDA!','STOP')   
	return
	endif
	*/
	if ZZ4->ZZ4_STATUS = 'F' .and. mv_par04 = 1
		msgbox('Pré-pedido já faturado! Impossível refaturar!','OPERAÇÃO INVÁLIDA!','STOP')   
		return 
	elseif ZZ4->ZZ4_STATUS = 'E' .and. mv_par04 = 2
		msgbox('Pré-pedido não faturado! Impossível refaturar!','OPERAÇÃO INVÁLIDA!','STOP')   
		return 
	endif 

	//u_fb_gped2('P',_cPreCar)
	u_fb_gped2('P')

	pergunte(cPerg,.f.)

	_lOkPre := .t.

	Dbselectarea('ZZ4')
	ZZ4->(Dbsetorder(1))
	ZZ4->(dbgotop())
	if ZZ4->(MsSeek(FWxfilial('ZZ4') + ZZ3->ZZ3_NUM)) 
		While ZZ4->(!eof()) .and. FWxfilial('ZZ4') = ZZ4->ZZ4_FILIAL .and. ZZ4->ZZ4_PRECAR = ZZ3->ZZ3_NUM
			if ZZ4->ZZ4_STATUS <> 'F' 
				_lOkPre  := .f. 
				exit
			endif
			ZZ4->(dbskip())
		enddo  
	endif
	if _lOkPre .and. mv_par04 = 1
		reclock('ZZ3',.f.)
		ZZ3->ZZ3_STATUS := 'F'
		if empty(ZZ3->ZZ3_DTFIM)
			ZZ3->ZZ3_DTFIM := ddatabase
		endif
		if empty(ZZ3->ZZ3_HFIM)
			ZZ3->ZZ3_HFIM := time()
		endif
		msunlock()

		//Esse bloco serve para regravar a hora de data de faturamento nas caixas carregadas  
		if cEmpAnt = '01'
			SZ8->(DbSetOrder(5))
			if SZ8->(MsSeek(FWxfilial('SZ8')+cFilial + ZZ3->ZZ3_NUM))
				While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and.;
				SZ8->Z8_FIL = cFilial .and.;
				SZ8->Z8_PRECAR = ZZ3->ZZ3_NUM
					reclock('SZ8',.f.)
					SZ8->Z8_DATAS   := ddatabase
					SZ8->Z8_HORAS   := time()
					SZ8->Z8_DTRANSF := ddatabase
					msunlock()

					//Caso haja registro de tranferencia, ajusta a data dela também
					ZAE->(DbSetOrder(2))
					if ZAE->(MsSeek(FWxfilial('ZAE')+SZ8->(Z8_CONTROL+Z8_PRECAR)+cFilial))
						reclock('ZAE',.f.)
						ZAE->ZAE_DATAM := ddatabase
						msunlock()
					endif
					SZ8->(DbSkip())
				enddo
			endif
			msgbox('A data de saída das caixas foi atualizada com a data de fatura!','CARREGAMENTO FATURADO','INFO')
			u_gjf31his('Carregamento faturado!')  		
			u_devSeparacao(ZZ3->ZZ3_NUM)
		endif
	elseif _lOkPre .and. mv_par04 = 2
		u_gjf31his('Carregamento refaturado!') 
	endif

	FilBrowse("ZZ4",@aIndZZ4_,@cCondicao3)

return

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
