#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

User Function FB_GPED2(_tipo)
	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ FB_GPED2  ³ Autor ³ Evandro Mugnol       ³ Data ³09/07/2008³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Unidade   ³ Serra Gaucha     ³Contato ³ evandrom@totvs.com.br          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Geracao de pedido de venda automaticamente no processo de  ³±±
	±±³          ³ encerramento do carregamento.                              ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Frigorifico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ESTE FONTE É UMA COPIA DE FB_GPED FEITA POR Giuliano Forgiarini        ³±±
	±±³              ³  /  /  ³      ³                                        ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	Private _lGerou    := .F.
	Private _cBon      := 'N'

	DbSelectArea("ZZ4")

	if _Tipo = 'C'
		_Chave  := FWxFilial("ZZ4") + ZZ3->ZZ3_NUM
		_Chave2 := "ZZ4->(ZZ4_FILIAL + ZZ4_PRECAR)"
		ZZ4->(DbSetOrder(1))
	else
		_Chave  := FWxFilial("ZZ4") + ZZ4->ZZ4_NUM
		_Chave2 := "ZZ4->(ZZ4_FILIAL + ZZ4_NUM)"
		ZZ4->(DbSetOrder(2))
	endif

	_nCont := 0

	if MsSeek(_Chave)
		While !Eof() .And. &_Chave2 = _Chave
			_nCont++
			ZZ4->(DbSkip())
		enddo
		ZZ4->(DbGoTop())
	endif

	if MsSeek(_Chave)
		ProcRegua(_nCont)
		While !Eof() .And. &_Chave2 = _Chave
			IncProc("Processando GERAÇÃO DOS PEDIDOS...")

			If ZZ4->ZZ4_TPOPER = 'C'
				msgbox('Pre-Pedido de numero: '+ alltrim(ZZ4->ZZ4_NUM) +;
				' não faturado por ser operação de compra!','OPERACAO NEGADA','stop')
				ZZ4->(dbskip())
				loop
			Endif

			If !(ZZ4->ZZ4_STATUS $ 'F/E')
				ZZ4->(dbskip())
				loop
			Endif

			if mv_par04 = 1
				if ZZ4->ZZ4_STATUS = 'F'
					ZZ4->(DbSkip())
					loop
				endif
			endif

			_cPlaca   := ZZ3->ZZ3_PLACA
			_cPreC    := ZZ3->ZZ3_NUM
			_cPrePed  := ZZ4->ZZ4_NUM
			_cCliente := ZZ4->ZZ4_CODCLI
			_cLojaCli := ZZ4->ZZ4_LOJA
			_cMarca   := IIF(Empty(ZZ4->ZZ4_MARCA), ZZ4->ZZ4_MARCA, "MARCA "+ZZ4->ZZ4_MARCA)
			_nVlDesc  := ZZ4->ZZ4_DESC
			_cTpOper  := ZZ4->ZZ4_TPOPER
			_nComisPP := ZZ4->ZZ4_COMIS
			_cPCompra := ZZ4->ZZ4_PCOMPR
			_dDtEnt   := ZZ4->ZZ4_DTENT
			_cHrEnt   := ZZ4->ZZ4_HRENT   

			//BLOCO NOVO PARA LEVAR O PESO TOTAL PARA O CABEÇALHO DO PEDIDO DE VENDA NA SC5
			ZZ5->(dbSetOrder(1))
			ZZ5->(dbGoTOp())
			_nPesLiqTot := 0
			_nPesBrtTot := 0
			if ZZ5->(MsSeek(FWxFilial('ZZ5') + ZZ4->ZZ4_NUM))
				while ZZ5->(!eof()) .and. ZZ5->ZZ5_NUM == ZZ4->ZZ4_NUM .and. FWxFilial('ZZ5') == ZZ5->ZZ5_FILIAL
					_nPesLiqTot  += ZZ5->ZZ5_QRPESO
					_nPesBrtTot  += ZZ5->ZZ5_QRPESB
					ZZ5->(dbSkip())
				enddo
			endif
			//Tratamento de loja especifico para caixas do zaffari, caixas da Loja Sao Paulo
			//Faturao por Porto Alegre
			_cLojEnvEmb:= iif(_cCliente = '000221' .and. _cLojaCli = '25','01',_cLojaCli)

			if cEmpAnt = '01'
				_cRedis  := ZZ4->ZZ4_REDIS
			endif

			//_nTipCod  := ZZ4->ZZ4_TIPCOD
			//_cOBS     := substr(alltrim(ZZ4->ZZ4_OBS),1,70) + iif(!empty(_cPCompra),'PEDIDO DE COMPRA NR: ' + alltrim(_cPCompra),'')
			//Comentado por Fabian Maurer para alterar tamanho de caracter do campo "ZZ4_OBS" para não cortar mensagem dia 23/03/15

			if cEmpAnt = '01'

				if ZZ4->ZZ4_REDIST == '1' 
					_cCodTransp := ZZ4->ZZ4_REDIS
					_cNomeTransp := GetAdvFVal('SA4','A4_NOME',FWxFilial('SA4') + _cCOdTransp,1)
					_cCgcTransp  := GetAdvFVal('SA4','A4_CGC',FWxFilial('SA4') + _cCOdTransp,1)
					_cEndTransp  := GetAdvFVal('SA4','A4_END',FWxFilial('SA4') + _cCOdTransp,1)

					_cNomeTransp := substr(alltrim(_cNomeTransp),1,25)
					_cCgcTransp  := alltrim(_cCgcTransp)
					_cEndTransp  := substr(alltrim(_cEndTransp),1,40)

					//_cZz4OBS := iif(!empty(ZZ4->ZZ4_OBS),substr(alltrim(ZZ4->ZZ4_OBS),1,100),'')
					/* Alteração feita dia 20/07/21 - solicitada por Mateheus Ribeiro - com aval de Clailton - aumento de campo*/
					//_cOBS     := alltrim(iif(!empty(ZZ4->ZZ4_OBS),substr(alltrim(ZZ4->ZZ4_OBS),1,100),'') +;
					_cOBS := alltrim(iif(!empty(ZZ4->ZZ4_OBS),substr(alltrim(ZZ4->ZZ4_OBS),1,111),'') +;
									iif(!empty(_cPCompra)   ,'PEDIDO DE COMPRA NR: ' + alltrim(_cPCompra),'') +;
									iif(!empty(_cNomeTransp),' Redistribuido por: '  + _cNomeTransp,'') +;
									iif(!empty(_cCgcTransp) ,' CNPJ: ' 			  	 + _cCgcTransp,'') +;
									iif(!empty(_cEndTransp) ,' END: ' 				 + _cEndTransp,''))
				else
					_cOBS := substr(alltrim(ZZ4->ZZ4_OBS),1,100) + iif(!empty(_cPCompra),'PEDIDO DE COMPRA NR: ' + alltrim(_cPCompra),'')									 
				endif
			else
				_cOBS := substr(alltrim(ZZ4->ZZ4_OBS),1,100) + iif(!empty(_cPCompra),'PEDIDO DE COMPRA NR: ' + alltrim(_cPCompra),'')	
			endif

			If GetAdvFVal('SA1','A1_MSBLQL',FWxfilial('SA1')+ZZ4->(ZZ4_CODCLI+ZZ4_LOJA),1) = '1'
				msgbox('Pedido de número ' + ZZ4->ZZ4_NUM + ' do cliente ' + ZZ4->ZZ4_CODCLI + '/' + ZZ4->ZZ4_LOJA +;
				'não foi gerado por estar bloqueado!', 'BLOQUEIO DE CLIENTES','STOP')
				DbSelectArea("ZZ4")
				DbSkip()
				Loop
			Endif

			_aAutoSC5 := {}        // Array com os dados do cabeçalho do pedido de venda  
			_aSC5_Emb := {}        // Array com os dados do cabeçalho do pedido de venda para embalagens retornáveis
			_aAutoSC6 := {}        // Array com os dados dos itens do pedido de venda
			_aSC6_Emb := {}        // Array com os dados dos itens do pedido de venda para embalagens retornáveis		
			// Função que monta tela e gera pedidos das caixas plásticas
			//Função que monta o vetor de produtos e caixas
			VerSZ8(_cPreC,_cPrePed,_cCliente,_cLojEnvEmb)
			//_aSC6_Emb := VerSZ8(_cPreC,_cPrePed,_cCliente)

			//Fim do Bloco para verificar as caixas do pre-pedido
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Array com o cabecalho do pedido de venda                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SC5")
			/*admin	
			_cNumPed := GetSx8Num("SC5","C5_NUM")
			confirmsx8()
			*/   
			_lGerEmb   := .f.

			_nComis    := 0
			_nComis1   := 0
			_nComis2   := 0
			_cVend2    := ''
			_cTipoPed  := "N"
			_cTipoCli  := GetAdvFVal("SA1", "A1_TIPO", FWxFilial("SA1") + _cCliente + _cLojaCli, 1)
			_cCondPgt  := GetAdvFVal("SA1", "A1_COND", FWxFilial("SA1") + _cCliente + _cLojaCli, 1)
			_cTabela   := GetAdvFVal("SA1", "A1_TABELA", FWxFilial("SA1") + _cCliente + _cLojaCli, 1)
			_cVend1    := GetAdvFVal("SA1", "A1_VEND", FWxFilial("SA1") + _cCliente + _cLojaCli, 1)
			_nComisCli := GetAdvFVal("SA1", "A1_COMIS", FWxFilial("SA1") + _cCliente + _cLojaCli, 1)
			_nComisVen := GetAdvFVal('SA3','A3_COMIS', FWxfilial('SA3') + _cVend1, 1)
			_nMoeda	   := IIF(GetAdvFVal("SA1", "A1_EST", FWxFilial("SA1") + _cCliente + _cLojaCli, 1)=="EX",2,1)
			_cTpFrete  := GetAdvFVal("SA1", "A1_TPFRET", FWxFilial("SA1") + _cCliente + _cLojaCli, 1)

			//Verifica se existe sub-vendedor e o aponta para o pedido de venda
			//O campo _cVend2 levara comissao para o responsavel do vendedor que
			//efetuou a venda de fato
			SA3->(DbSetOrder(1))
			if SA3->(MsSeek(FWxfilial('SA3')+_cVend1))
				if !empty(SA3->A3_GEREN)
					_cVend2  := SA3->A3_GEREN
					_nComis2 := iif(_nComisCli <> 0 ,_nComisCli,GetAdvFVal('SA3','A3_COMIS',FWxfilial('SA3')+_cVend2,1))
				endif
			endif
			// Fim da verificação dos sub-vendedores

			/*
			//Verifica se a comissao do cadastro do cliente esta em branco
			//Se ela nao estiver, entao assume o valor de comissao do cadastro
			//senao pega o percentual de comissao do cadastro do vendedor (variavel _nComissVen)
			if _nComisCli <> 0
			//	alert('Atribuiu comissão do cadastro do cliente: '+transform(_nComisCli,'@E 9.99'))
			_nComis1 := _nComisCli
			else
			//	alert('Atribuiu comissão do cadastro do vendedor: '+ transform(_nComisVen,'@E 9.99'))
			_nComis1 := _nComisVen
			endif

			//Verifica se o pessoal do comercial alterou a comissao no Pre-Pedido
			//Se isso foi feito entao assume o valor da comissao do pre-pedido
			//sobrepondo o valor de comissao do cadastro
			if _nComisPP <> 0
			//	alert('Atribuiu comissão do pré-pedido: '+ transform(_nComisPP,'@E 9.99'))
			_nComis1 := _nComisPP
			endif
			*/
			//{"C5_NUM"     , _cNumPed         , Nil },;
			if cEmpAnt = '01'
				_aAutoSC5 := { 	{"C5_FILIAL", FWxFilial("SC5") , Nil },;
								{"C5_TIPO"    , _cTipoPed      , Nil },;
								{"C5_CLIENTE" , _cCliente      , Nil },;
								{"C5_LOJACLI" , _cLojaCli      , Nil },;
								{"C5_CLIENT " , _cCliente      , Nil },;
								{"C5_LOJAENT" , _cLojaCli      , Nil },;
								{"C5_TIPOCLI" , _cTipoCli      , Nil },;
								{"C5_CONDPAG" , _cCondPgt      , Nil },;
								{"C5_TABELA"  , _cTabela       , Nil },;
								{"C5_VEND1"   , _cVend1        , Nil },;
								{"C5_VEND2"   , _cVend2        , Nil },;
								{"C5_COMIS1"  , _nComisPP      , Nil },;
								{"C5_COMIS2"  , _nComis2       , Nil },;
								{"C5_MOEDA"   , _nMoeda        , Nil },;
								{"C5_TPFRETE" , _cTpFrete      , Nil },;
								{"C5_MARCA"   , _cMarca        , Nil },;
								{"C5_DESCONT" , _nVlDesc       , Nil },;
								{"C5_PRECAR"  , _cPreC         , Nil },;
								{"C5_PREPED"  , _cPrePed       , Nil },;
								{"C5_PLACA"   , _cPlaca        , Nil },;
								{"C5_TPOPER"  , _cTpOper       , Nil },;
								{"C5_BONIF"   , _cBon          , Nil },;
								{"C5_MENNOTA" , _cOBS          , Nil },;
								{"C5_PCOMPRA" , _cPCompra      , Nil },;
								{"C5_FECENT"  , DDATABASE      , Nil },;
								{"C5_DTENT"   , _dDtEnt        , Nil },; 
								{"C5_REDIS"   , _cRedis        , Nil },;//Mesmo
								{"C5_HRENT"   , _cHrEnt        , Nil },;
								{"C5_PESOL"   , _nPesLiqTot    , Nil },;
								{"C5_PBRUTO"  , _nPesBrtTot    , Nil }}
				/*_nPesLiqTot  += ZZ5->ZZ5_QRPESO
				_nPesBrtTot  += ZZ5->ZZ5_QRPESB*/

				//	{"C5_TIPCOD"  , _nTipCod       , Nil },;
			else
				_aAutoSC5 := { 	{"C5_FILIAL", FWxFilial("SC5") , Nil },;
								{"C5_TIPO"    , _cTipoPed      , Nil },;
								{"C5_CLIENTE" , _cCliente      , Nil },;
								{"C5_LOJACLI" , _cLojaCli      , Nil },;
								{"C5_CLIENT " , _cCliente      , Nil },;
								{"C5_LOJAENT" , _cLojaCli      , Nil },;
								{"C5_TIPOCLI" , _cTipoCli      , Nil },;
								{"C5_CONDPAG" , _cCondPgt      , Nil },;
								{"C5_TABELA"  , _cTabela       , Nil },;
								{"C5_VEND1"   , _cVend1        , Nil },;
								{"C5_VEND2"   , _cVend2        , Nil },;
								{"C5_COMIS1"  , _nComisPP      , Nil },;
								{"C5_COMIS2"  , _nComis2       , Nil },;
								{"C5_MOEDA"   , _nMoeda        , Nil },;
								{"C5_TPFRETE" , _cTpFrete      , Nil },;
								{"C5_MARCA"   , _cMarca        , Nil },;
								{"C5_DESCONT" , _nVlDesc       , Nil },;
								{"C5_PRECAR"  , _cPreC         , Nil },;
								{"C5_PREPED"  , _cPrePed       , Nil },;
								{"C5_PLACA"   , _cPlaca        , Nil },;
								{"C5_TPOPER"  , _cTpOper       , Nil },;
								{"C5_BONIF"   , _cBon          , Nil },;
								{"C5_MENNOTA" , _cOBS          , Nil },;
								{"C5_PCOMPRA" , _cPCompra      , Nil },;
								{"C5_DTENT"   , _dDtEnt        , Nil },; 
								{"C5_HRENT"   , _cHrEnt        , Nil }}
							//	{"C5_TIPCOD"  , _nTipCod       , Nil },;
			endif

			//Gera array para pedido de venda de caixas retornaveis
			if _lGerEmb
				_aSC5_Emb  := {	{"C5_FILIAL", FWxFilial("SC5") , Nil },;
								{"C5_TIPO"    , _cTipoPed      , Nil },;//Mesmo
								{"C5_CLIENTE" , _cCliente      , ".T." },;//Mesmo
								{"C5_LOJACLI" , _cLojaCli      , Nil },;//Mesmo
								{"C5_CLIENT " , _cCliente      , ".T." },;//Mesmo
								{"C5_LOJAENT" , _cLojaCli      , Nil },;//Mesmo
								{"C5_TIPOCLI" , _cTipoCli      , Nil },;//Mesmo
								{"C5_CONDPAG" , _cCondPgt      , Nil },;//Mesmo
								{"C5_TABELA"  , _cTabela       , Nil },;//Mesmo
								{"C5_VEND1"   , _cVend1        , Nil },;//Mesmo
								{"C5_VEND2"   , _cVend2        , Nil },;//Mesmo
								{"C5_COMIS1"  , 0.00           , Nil },;
								{"C5_COMIS2"  , 0.00           , Nil },;
								{"C5_MOEDA"   , _nMoeda        , Nil },;//Mesmo
								{"C5_TPFRETE" , _cTpFrete      , Nil },;//Mesmo
								{"C5_MARCA"   , _cMarca        , Nil },;//Mesmo
								{"C5_DESCONT" , _nVlDesc       , Nil },;//Mesmo
								{"C5_PRECAR"  , _cPreC         , Nil },;//Mesmo
								{"C5_PREPED"  , _cPrePed       , Nil },;//Mesmo
								{"C5_PLACA"   , _cPlaca        , Nil },;//Mesmo
								{"C5_TPOPER"  , _cTpOper       , Nil },;//Mesmo
								{"C5_FECENT"  , DDATABASE      , Nil },;
								{"C5_BONIF"   , _cBon          , Nil },;//Mesmo
								{"C5_MENNOTA" , _cOBS          , Nil }}
			endif

			_cItem   := "01"
			_nTipCod := 0

			ZZ5->(dbgotop())

			//Bloco para verificar se há bonificação no pedido que está sendo processado
			ZZ5->(dbsetorder(1))
			if ZZ5->(MsSeek(FWxfilial('ZZ5') + alltrim(_cPrePed)))
				while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ZZ5->ZZ5_NUM = _cPrePed

					if ZZ5->ZZ5_TPBONI = 'D'
						_cBon := 'S'
						exit
					endif

					ZZ5->(dbskip())
				enddo
			endif

			ZZ5->(dbgotop())

			if ZZ5->(MsSeek(FWxFilial("ZZ5") + alltrim(_cPrePed)))

				Do While !Eof() .And. ZZ5->ZZ5_FILIAL = FWxFilial("ZZ5") .and. ZZ5->ZZ5_NUM =  alltrim(_cPrePed)

					if ZZ5->ZZ5_QRCAIX = 0 .or. ZZ5->ZZ5_QRPESO = 0
						ZZ5->(dbskip())
						loop
					endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Array com o cabecalho do pedido de venda                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					_nVlDesU  := 0.00
					_cProduto := ZZ5->ZZ5_COD
					_cItem    := substr(ZZ5->ZZ5_ITEM,2,2)
					_nQtde1Um := 0.00
					_nQtde2Um := Round(ZZ5->ZZ5_QRCAIX,2)    // Quantidade em CX               

					_cUmPri   := GetAdvFVal("SB1", "B1_UM", FWxFilial("SB1") + _cProduto, 1)

					//Para determinar a primeira unidade de medida, faz uma verificação:
					// - se for charque ou tubete de moida, então pega a segunda unidade de medida (caixa) e multiplica por unidades dentro da caixa
					// - se não for charque nem tubete de moída, então pega a quantidade em peso normal
					If cEmpAnt == '01'
						DbSelectArea('SB1')
						QtdCaix := GetAdvFVal('SB1','B1_QCAIX',FWxfilial('SB1') + alltrim(_cProduto),1)					

						//BLOCO COMENTADO POIS FOI FEITA ALTERACAO PARA RELACIONAR OS CODIGOS EM UM UNICO PARAMETRO
						/*if alltrim(_cProduto) $ '001786|001784|001788|008896|008897'    //Charque
						_nQtde1Um := _nQtde2Um * QtdCaix
						_cUmPri   := 'UN'
						elseif alltrim(_cProduto) $ '010825|011086|011789|011755|011756|012600|012601|012902|010892|010882'   //Tubete moida
						_nQtde1Um := _nQtde2Um * QtdCaix 
						_cUmPri   := 'UN'
						elseif alltrim(_cProduto) $ '012300|012301'    //Moida Zaffari
						_nQtde1Um := _nQtde2Um * QtdCaix 
						_cUmPri   := 'UN'
						elseif alltrim(_cProduto) $ '011969|011971|012736|013143|013144'    //Moida Peso Fixo 500g
						_nQtde1Um := _nQtde2Um * QtdCaix 
						_cUmPri   := 'UN'		  
						elseif alltrim(_cProduto) $ '013268|013266|013269'    //Hamburguer Peso Fixo 300g
						_nQtde1Um := _nQtde2Um * QtdCaix 
						_cUmPri   := 'UN'*/            
						_PrdUnid := _GetPar1()
						_PrdUni2 := _Getpar2()
						_PrdUni3 := _Getpar3()
						_PrdUni4 := _Getpar4()
						_PrdUni5 := _Getpar5()
						_PrdUni6 := _Getpar6()
						if  (alltrim(_cProduto) $ _PrdUnid) .or. (alltrim(_cProduto) $ alltrim(_PrdUni2)) .or. (alltrim(_cProduto) $ alltrim(_PrdUni3)) .or. (alltrim(_cProduto) $ alltrim(_PrdUni4)) .or. (alltrim(_cProduto) $ alltrim(_PrdUni5)).or. (alltrim(_cProduto) $ alltrim(_PrdUni6))
							_nQtde1Um := _nQtde2Um * QtdCaix 
							_cUmPri   := 'UN'		  												  												
						else
							_nQtde1Um := Round(ZZ5->ZZ5_QRPESO,2)
						endif
					else
						_nQtde1Um := Round(ZZ5->ZZ5_QRPESO,2)
					Endif
					_nVlLista := Round(ZZ5->ZZ5_PRECO,5)     // Preço Unitário de Lista
					_nVlBonif := Round(ZZ5->ZZ5_BONIF,5)     // Valor da Bonificação e/ou Acréscimo  

					If ZZ5->ZZ5_TPBONI == "D"                // Tipo da Bonificação igual a "Desconto"
						_nVlUnit := _nVlLista - _nVlBonif
						_nVlDesU := _nVlBonif
					ElseIf ZZ5->ZZ5_TPBONI == "A"            // Tipo da Bonificação igual a "Acrescimo"
						_nVlUnit := _nVlLista + _nVlBonif
					Else
						_nVlUnit := _nVlLista
					Endif  

					_nTVenda  := Round((_nQtde1Um * _nVlUnit),2)
					_cDescPrd := GetAdvFVal("SB1", "B1_DESC", FWxFilial("SB1") + _cProduto, 1)
					_cUmSeg   := GetAdvFVal("SB1", "B1_SEGUM", FWxFilial("SB1") + _cProduto, 1)
					_cLocal   := GetAdvFVal("SB1", "B1_LOCPAD", FWxFilial("SB1") + _cProduto, 1)
					_cGrupo   := GetAdvFVal("SB1", "B1_GRUPO", FWxFilial("SB1") + _cProduto, 1)
					_cTesProd := GetAdvFVal("SB1", "B1_TS", FWxFilial("SB1") + _cProduto, 1)
					If cEmpAnt == "08"		// Especifico para Graxaria
						_cTesPed := _BuscaTES(_cCliente, _cLojaCli, _cProduto)
					Else
						_cTesPed := u_gjf47TES(_cCliente + _cLojaCli,_cProduto) //Funçao que retorna o TES tratando se o cliente for consumidor final
					EndIf
					_cCtCtb   := u_gjf47Ct(_cCliente + _cLojaCli,_cProduto) //Funçao que retorna a Conta Contabil tratando se o cliente for consumidor final

					_nTipCod  := ZZ5->ZZ5_TIPCOD             // Tipo de Codigo. Específico para EDI

					AADD(_aAutoSC6,{{"C6_FILIAL"  , FWxFilial("SC6")  	, Nil },;
									{"C6_ITEM"    , _cItem          	, Nil },;
									{"C6_PRODUTO" , _cProduto       	, Nil },;
									{"C6_GRUPO"   , _cGrupo         	, Nil },;
									{"C6_DESCRI"  , _cDescPrd       	, Nil },;
									{"C6_UM"      , _cUmPri         	, Nil },;
									{"C6_QTDVEN"  , _nQtde1Um       	, Nil },;
									{"C6_PRCVEN"  , _nVlUnit        	, Nil },;
									{"C6_VALOR"   , _nTVenda        	, Nil },;
									{"C6_QTDLIB"  , _nQtde1Um       	, Nil },;
									{"C6_SEGUM"   , _cUmSeg         	, Nil },;
									{"C6_UNSVEN"  , _nQtde2Um       	, Nil },;
									{"C6_TES"     , _cTesPed        	, Nil },;
									{"C6_LOCAL"   , _cLocal         	, Nil },;
									{"C6_VLDESU"  , _nVlDesU        	, Nil },;
									{"C6_NUMPCOM" , _cPCompra       	, Nil },;
									{"C6_ITEMPC"  , _cItem          	, Nil },;
									{"C6_TIPCOD"  , _nTipCod        	, Nil },;
									{"C6_PRECAR"  , _cPreC        		, Nil },;
									{"C6_CONTA"   , _cCtCtb         	, Nil }})    

					DbSelectArea("ZZ5")
					ZZ5->(DbSkip())
				Enddo

			else
				alert('Falha na captura dos itens do pré-pedido!')
				return
			endif

			//Bloco para geração do pedido de venda para caixa retornável
			if _lGerEmb		
				lMsHelpAuto := .F.  // se .t. direciona as mensagens de help
				lMsErroAuto := .F.  // necessario a criacao

				If Len(_aSC5_Emb) > 0 .and. Len(_aSC6_Emb) > 0
					DbSelectArea("SC5")
					Begin Transaction
						MsExecAuto({|x,y,z|MATA410(x,y,z)},_aAutoSC5,_aAutoSC6,3)

						If lMsErroAuto
							MostraErro()
							DisarmTransaction()
						EndIf

					End Transaction

					lMsHelpAuto := .F.  // se .t. direciona as mensagens de help
					lMsErroAuto := .F.  // necessario a criacao

				EndIf

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a inclusão do pedido de venda via rotina automática  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lMsHelpAuto := .F.  // se .t. direciona as mensagens de help
			lMsErroAuto := .F.  // necessario a criacao
			If Len(_aAutoSC5) > 0 .and. Len(_aAutoSC6) > 0
				DbSelectArea("SC5")
				Begin Transaction

					MsExecAuto({|x,y,z|MATA410(x,y,z)},_aAutoSC5,_aAutoSC6,3)

					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
					Else
						_cNumPed := SC5->C5_NUM
						DbSelectArea("ZZ4")
						RecLock("ZZ4",.F.)
						ZZ4->ZZ4_DATAPV := dDataBase
						ZZ4->ZZ4_NUMPED := _cNumPed
						MsUnlock()

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Realiza a liberação do pedido de venda incluso               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						_aPvlNfs := {}
						DbSelectArea("SC9")
						DbSetOrder(2)
						ProcRegua(SC9->(RecCount()))
						MsSeek(FWxFilial("SC9") + _cCliente + _cLojaCli + _cNumPed)
						RecnoSC9 := SC9->(Recno())
						While !Eof() .And. SC9->C9_FILIAL + SC9->C9_CLIENTE + SC9->C9_LOJA + SC9->C9_PEDIDO == FWxFilial("SC9") + _cCliente + _cLojaCli + _cNumPed
							IncProc("Processando LIBERAÇÃO DO PEDIDO...")

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Posiciona os registros                                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea("SB1")
							dbSetOrder(1)
							MsSeek(FWxFilial("SB1")+SC9->C9_PRODUTO)

							dbSelectArea("SC5")
							dbSetOrder(1)
							MsSeek(FWxFilial("SC5")+SC9->C9_PEDIDO)

							dbSelectArea("SC6")
							dbSetOrder(1)
							MsSeek(FWxFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)

							dbSelectArea("SB2")
							dbSetOrder(1)
							MsSeek(FWxFilial("SB2")+SC6->C6_PRODUTO+SC9->C9_LOCAL)

							dbSelectArea("SF4")
							dbSetOrder(1)
							MsSeek(FWxFilial("SF4")+SC6->C6_TES)

							dbSelectArea("SE4")
							dbSetOrder(1)
							MsSeek(FWxFilial("SE4")+SC5->C5_CONDPAG)

							AADD(_aPvlNfs,{	SC9->C9_PEDIDO   ,;       // Número da pedido de venda liberado
											SC9->C9_ITEM     ,;       // Item do pedido de venda liberado
											SC9->C9_SEQUEN   ,;       // Sequencia
											SC9->C9_QTDLIB   ,;       // Quantidade liberada
											SC9->C9_PRCVEN   ,;       // Preço de venda
											SC9->C9_PRODUTO  ,;       // Código do produto liberado
											SF4->F4_ISS=="S" ,;
											SC9->(RecNo())   ,;       // Recno() da tabela SC9
											SC5->(RecNo())   ,;       // Recno() da tabela SC5
											SC6->(RecNo())   ,;       // Recno() da tabela SC6
											SE4->(RecNo())   ,;       // Recno() da tabela SE4
											SB1->(RecNo())   ,;       // Recno() da tabela SB1
											SB2->(RecNo())   ,;       // Recno() da tabela SB2
											SF4->(RecNo())   ,;       // Recno() da tabela SF4
											SB2->B2_LOCAL    ,;       // Almoxarifado do produto
											DAK->(RecNo())   ,;       // Recno() da tabela DAK
											SC9->C9_QTDLIB2  })       // Quantidade liberada da 2a. unidade medida

							DbSelectArea("SC9")
							RecLock("SC9",.F.)
							SC9->C9_BLEST  := ""
							SC9->C9_BLCRED := ""
							MsUnlock()

							SC9->(DbSkip())
						Enddo
						_lGerou := .T.
					Endif
				End Transaction
			Endif

			DbSelectArea("ZZ4")

			reclock('ZZ4',.f.)
			ZZ4->ZZ4_STATUS := 'F'
			msunlock()

			ZZ4->(DbSkip())
		Enddo

		If _lGerou
			MsgAlert("Geração dos Pedidos de Venda Finalizados com Sucesso!")        

			if cEmpAnt = '01'
				/*ZZ6->(dbsetorder(5))
				if 	ZZ6->(MsSeek(FWxfilial('ZZ6')+ZZ3->ZZ3_NUM,.t.))
					while ZZ6->(!eof()) .and. ZZ6->ZZ6_FILIAL = FWxfilial('ZZ6') .and. ZZ6->ZZ6_PRECAR = ZZ3->ZZ3_NUM
						if GetAdvFVal('ZZ4','ZZ4_STATUS',FWxfilial('ZZ4')+ZZ6->ZZ6_PREPED,2) = 'F'
							reclock('ZZ6',.f.)
							dbDelete()
							msunlock()
						endif
						ZZ6->(dbskip())
					enddo
				endif*/

				ZZA->(dbsetorder(4))
				if ZZA->(MsSeek(FWxfilial('ZZA')+ZZ3->ZZ3_NUM,.t.))
					while ZZA->(!eof()) .and. ZZA->ZZA_PRECAR = ZZ3->ZZ3_NUM
						if GetAdvFVal('ZZ4','ZZ4_STATUS',FWxfilial('ZZ4')+ZZA->ZZA_PREPED,1) = 'F'
							reclock('ZZA',.f.)
							dbDelete()
							msunlock()
						endif
						ZZA->(dbskip())
					enddo
				endif
			endif                  

		Else
			MsgAlert("Não Houveram Pedidos de Venda para Serem Processados no Pré-Carregamento Selecionado!")
		Endif

		if select('SC5')<>0
			DbSelectArea('SC5')
			SC5->(DbCloseArea())
		endif
		if select('SC6')<>0
			DbSelectArea('SC6')
			SC6->(DbCloseArea())
		endif
		if select('SC9')<>0
			DbSelectArea('SC9')
			SC9->(DbCloseArea())
		endif
	endif

Return


// Função para definir como será o pedido de venda de movimentação de saída das caixas plásticas
// Define o codigo de caixa plastica a ser utilizado, produtos e clientes
Static Function VerSZ8(_PreCar,_PrePed,_Cli,_Loj)

	Local _aProd  			:= {}
	Local _aItens 			:= {}
	Local nOpc				:= 0
	Local nX				:= 0
	//Local nRegua	 		:= 0
	Local i
	Local nY
	Private oDlg			:= Nil
	Private oCheckMarca		:= Nil
	Private LCHECKMARCA		:= .F.
	Private LCHECKINV		:= .F.
	Private aObjects   		:= {}
	Private aPosObj    		:= {}
	Private aSize		 	:= MsAdvSize()
	Private aInfo      		:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Private oOkSelct		:= LoadBitmap(GetResources(), "LBTIK")
	Private oNoSelct		:= LoadBitmap(GetResources(), "LBNO")
	Private oBrw			:= Nil
	Private oBrwT			:= Nil
	Private cCodCaix		:= ""

	If cEmpAnt <> '01'
		Return _aItens
	Endif

	// Flag que determinará a geração do pedido de venda para embalagens retornáveis
	_lGerCxs := .F.

	cCodCaix := _buscaCodCx()

	// Bloco para verificar a existencia de caixas plasticas no pre-pedido e definir os itens das Nfs de saída/retorno
	SZ8->(dbgotop())
	SZ8->(DbSetOrder(5))
	if SZ8->(MsSeek(FWxFilial("SZ8") + cFilAnt + alltrim(_Precar) + alltrim(_PrePed)))

		Do While SZ8->(!Eof()) .And. SZ8->Z8_FILIAL + SZ8->Z8_FIL + SZ8->Z8_PRECAR + SZ8->Z8_PREPED == FWxFilial("SZ8") + cFilAnt + _PreCar + _PrePed  

			_cCodTara := ''
			//_nTaraS   := 0
			_cCodTara := GetAdvFVal('SB1','B1_CTARASE',FWxfilial('SB1') + PADR(SZ8->Z8_COD, 15," "),1)
			//_nTaraS   := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB') + _cCodTara,1)
			_cProdut  := GetAdvFVal('ZAB','ZAB_PRODUT',FWxfilial('ZAB') + _cCodTara,1)

			//NOVO CODIGO COM BASE NO CODIGO DE PRODUTO DAS CAIXAS CADASTRADO NA ZAB - GIULIANO
			/*
			If _nTaraS >= 1.500
			_nPos := aScan(_aProd,{|aVal|aVal[1] = _Cli+_Loj .and. aVal[3] = _cProdut})

			If _nPos <> 0
			_aProd[_nPos,4]++
			Else
			AADD(_aProd,{_Cli+_Loj,PADR(SZ8->Z8_COD, 15," "),_cProdut,1})
			Endif                 

			if len(_aProd) <> 0
			_lGerCxs := .T.
			endif
			endif
			*/
			//FIM DO NOVO CODIGO - GIULIANO

			//BLOCO DO CODIGO ANTIGO
			/*If _nTaraS >= 1.500
				_nPos := 0

				ZAO->(DbSetOrder(1))
				If ZAO->(MsSeek(FWxFilial('ZAO') + _Cli + _Loj + PADR(SZ8->Z8_COD, 15," ")))
					_nPos := aScan(_aProd,{|aVal|aVal[1] = _Cli+_Loj .and. aVal[3] = GetAdvFVal('ZAO','ZAO_CODCX',FWxfilial('ZAO') + PADR(SZ8->Z8_COD, 15," "),2)})

					If _nPos <> 0
						_aProd[_nPos,4]++
					Else
						AADD(_aProd,{_Cli+_Loj,PADR(SZ8->Z8_COD, 15," "),ZAO->ZAO_CODCX,1})
					Endif

					_lGerCxs := .T.
				Endif
			Endif*/
			//FIM DO BLOCO DO CODIGO ANTIGO

			if SZ8->Z8_TARA >= 1.9

				_nPos := aScan(_aProd,{|aVal|aVal[1] = _Cli+_Loj .and. aVal[3] = _cProdut})

				If _nPos <> 0
					_aProd[_nPos,4]++
				Else
					AADD(_aProd,{_Cli+_Loj, PADR(SZ8->Z8_COD, 15," "), _cProdut, 1})
				Endif

				_lGerCxs := .T.

			endif

			SZ8->(DbSkip())
		Enddo
	Endif

	If _lGerCxs
		AADD(aObjects,{450,50,.T.,.T.,.T.})
		AADD(aObjects,{450,50,.T.,.T.,.T.})
		aPosObj := MsObjSize(aInfo,aObjects)

		oDlg:= MSDIALOG():New(aSize[7], 0, aSize[6], aSize[5], "Itens do Pedido de Venda - Caixas Plásticas",,,,,,,,,.T.)

		aDados := {}  

		For i := 1 to len(_aProd)
			_cDesc := GetAdvFVal("SB1", "B1_DESC", FWxFilial("SB1")+_aProd[i,3], 1)
			_cNome := GetAdvFVal("SA1", "A1_NOME", FWxFilial("SA1")+_aProd[i,1], 1)
			aadd(aDados,{PADR(_aProd[i,3], 15," "),;
			_cDesc,;
			Transform(_aProd[i,4],'@E 999,999'),;
			IIF(_aProd[i,3] $ cCodCaix,Transform(_aProd[i,4],'@E 999,999'),Transform(0,'@E 999,999')),;
			Substr(_aProd[i,1],1,6)+"-"+Substr(_aProd[i,1],7,2)+"  "+_cNome})
		Next

		aDadosT := {}

		For nX := 1 To Len(aDados)
			If !(AllTrim(aDados[nX,1]) $ cCodCaix)
				DbSelectArea("SB6")
				DbSetOrder(1)
				MsSeek(FWxFilial("SB6") + PADR(aDados[nX,1], 15," ") + Substr(aDados[nX,5],1,6) + Substr(aDados[nX,5],8,2))
				While !Eof() .And. SB6->B6_FILIAL + SB6->B6_PRODUTO + SB6->B6_CLIFOR + SB6->B6_LOJA == FWxFilial("SB6") + PADR(aDados[nX,1], 15," ") + Substr(aDados[nX,5],1,6) + Substr(aDados[nX,5],8,2)

					If SB6->B6_SALDO > 0
						If SB6->B6_TIPO == "E"
							_cTipo := "Em Terceiros"
						Else
							_cTipo := "De Terceiros"
						Endif

						If SB6->B6_PODER3 == "R"
							_cPoder3 := "Remessa"
						Else
							_cPoder3 := "Devolução"
						Endif

						_cItem := GetAdvFVal('SD1','D1_ITEM',FWxFilial('SD1') + SB6->(B6_PRODUTO+B6_LOCAL+B6_IDENT),5)
						aadd(aDadosT,{SB6->B6_PRODUTO, SB6->B6_LOCAL, SB6->B6_DOC+" / "+SB6->B6_SERIE+_cItem, Dtoc(SB6->B6_EMISSAO), Transform(SB6->B6_SALDO,'@E 999,999'), SB6->B6_TES, _cTipo, _cPoder3, Transform(0,'@E 999,999'), SB6->B6_IDENT})
					Endif

					DbSelectArea("SB6")
					DbSkip()
				Enddo 
			Else
				_cEst := GetAdvFVal('SA1','A1_EST',FWxfilial('SA1')+Substr(aDados[nX,5],1,6) + Substr(aDados[nX,5],8,2),1)
				aadd(aDadosT,{aDados[nX,1], "01", "", dDataBase, Transform(999,'@E 999,999'), iif(_cEst = "RS","547","647"), "", "", Transform(0,'@E 999,999'), ""})
			Endif
		Next

		If Len(aDadosT) == 0  
			aadd(aDadosT,{Space(15), Space(02), Space(15), Space(10), Transform(0,'@E 999,999'), Space(03), Space(15), Space(10), Transform(0,'@E 999,999'), Space(06)})
		Endif

		// Define os títulos dos campos no cabeçalho Poder Terceiros
		_aHeadT  := {}
		AADD(_aHeadT,  'Produto' )
		AADD(_aHeadT,  'Armazém' )
		AADD(_aHeadT,  'Documento / Serie' )
		AADD(_aHeadT,  'Emissao' )
		AADD(_aHeadT,  'Saldo' )
		AADD(_aHeadT,  'TES' )
		AADD(_aHeadT,  'Tipo' )
		AADD(_aHeadT,  'Poder Terc.' )
		AADD(_aHeadT,  'Qtde a Gerar' )
		AADD(_aHeadT,  'Ident. Poder3' )

		// Define a largura das colunas Poder Terceiros
		_aColSzT := {}
		AADD(_aColSzT, '80' )
		AADD(_aColSzT, '30' )
		AADD(_aColSzT, '100')
		AADD(_aColSzT, '80' )
		AADD(_aColSzT, '80' )
		AADD(_aColSzT, '20' )
		AADD(_aColSzT, '50' )
		AADD(_aColSzT, '50' )
		AADD(_aColSzT, '80' )
		AADD(_aColSzT, '60' )

		oBrwT:= TCBrowse():New(aPosObj[2,1]-45,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]-45, , _aHeadT, _aColSzT, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
		oBrwT:SetArray(aDadosT)

		// Monta a linha a ser exibina no Browse
		oBrwT:bLine := {||{ aDadosT[oBrwT:nAt,01],;
		aDadosT[oBrwT:nAt,02],;
		aDadosT[oBrwT:nAt,03],;
		aDadosT[oBrwT:nAt,04],;
		aDadosT[oBrwT:nAt,05],;
		aDadosT[oBrwT:nAt,06],;
		aDadosT[oBrwT:nAt,07],;
		aDadosT[oBrwT:nAt,08],;
		aDadosT[oBrwT:nAt,09],;
		aDadosT[oBrwT:nAt,10]}}

		oBrwT:bLDblClick:= { || QtdeInf() }

		// Define os títulos dos campos no cabeçalho Caixas
		_aHeaders  := {}
		AADD(_aHeaders,  'Cod. Caixa' )
		AADD(_aHeaders,  'Descrição' )
		AADD(_aHeaders,  'Quantidade' )
		AADD(_aHeaders,  'Qtde Retorno' )
		AADD(_aHeaders,  'C l i e n t e' )

		// Define a largura das colunas Caixas
		_aColSizes := {}
		AADD(_aColSizes, '20' )
		AADD(_aColSizes, '100' )
		AADD(_aColSizes, '70')
		AADD(_aColSizes, '70' )
		AADD(_aColSizes, '100' )

		oBrw:= TCBrowse():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]-50, , _aHeaders, _aColSizes, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
		oBrw:SetArray(aDados)

		// Monta a linha a ser exibina no Browse
		oBrw:bLine := {||{ aDados[oBrw:nAt,01],;
		aDados[oBrw:nAt,02],;
		aDados[oBrw:nAt,03],;
		aDados[oBrw:nAt,04],;
		aDados[oBrw:nAt,05]}}

		TButton():New(aPosObj[1,4]+140, 440, "Gerar Pedido" , oDlg, {|| oDlg:End(), nOpc:= 1}, 50, 010,,,.F.,.T.,.F.,,.F.,,,.F.)
		TButton():New(aPosObj[1,4]+140, 510, "Sair"         , oDlg, {|| oDlg:End(), nOpc:= 0}, 50, 010,,,.F.,.T.,.F.,,.F.,,,.F.)
		oDlg:Activate()

		If nOpc != 0
			_aSC5_Emb := {}        // Array com os dados do cabeçalho do pedido de venda para embalagens retornáveis
			_aSC6_Emb := {}        // Array com os dados dos itens do pedido de venda para embalagens retornáveis
			_cItemEmb := "00"
			_nVez		 := 1

			For nX:= 1 To Len(aDados)
				If Val(aDados[nX, 4]) > 0  					// Caso a Qtde Retorno seja maior que 0 (Zero)
					_cTipoCli  := GetAdvFVal("SA1", "A1_TIPO", FWxFilial("SA1") + Substr(aDados[nX,5],1,6) + Substr(aDados[nX,5],8,2), 1)
					_cCondPgt  := GetAdvFVal("SA1", "A1_COND", FWxFilial("SA1") + Substr(aDados[nX,5],1,6) + Substr(aDados[nX,5],8,2), 1)
					_cTabela   := GetAdvFVal("SA1", "A1_TABELA", FWxFilial("SA1") + Substr(aDados[nX,5],1,6) + Substr(aDados[nX,5],8,2), 1)

					If _nVez == 1		// Monta array do cabeçalho do pedido somente uma vez

						_LojPedCaix :=  iif( (Substr(aDados[nX,5],1,6) = '000221' .and. Substr(aDados[nX,5],8,2) = '25'),'01',Substr(aDados[nX,5],8,2) )

						_aSC5_Emb  := {	{"C5_FILIAL"  , FWxFilial("SC5")   				, Nil },;
										{"C5_TIPO"    , "N"          					, Nil },;
										{"C5_CLIENTE" , Substr(aDados[nX,5],1,6)     	, ".T." },;
										{"C5_LOJACLI" , _LojPedCaix                  	, Nil },;
										{"C5_CLIENT " , Substr(aDados[nX,5],1,6)     	, ".T." },;
										{"C5_LOJAENT" , _LojPedCaix                  	, Nil },;
										{"C5_TIPOCLI" , _cTipoCli      					, Nil },;
										{"C5_CONDPAG" , _cCondPgt      					, Nil },;
										{"C5_TABELA"  , _cTabela       					, Nil },;
										{"C5_EMISSAO" , dDataBase      					, Nil },;
										{"C5_MOEDA"   , 1              					, Nil },;
										{"C5_FECENT"  , DDATABASE 					    , Nil },;
										{"C5_PRECAR"  , _PreCar 					    , Nil },;
										{"C5_TPFRETE" , "C"            					, Nil }}
						_nVez := 2
					Endif

					For nY:= 1 To Len(aDadosT)
						If aDados[nX, 1] == aDadosT[nY,01] .And. Val(aDadosT[nY,09]) > 0		// Se produto igual a produto da tela superior e Qtde a Gerar maior que 0 (ZERO)

							_cItemEmb := Soma1(_cItemEmb)
							_nPrcTab  := 30		// GetAdvFVal("DA1","DA1_PRCVEN",FWxFilial("DA1") + _cTabela + aDadosT[nY,01],1)

							DO CASE
								CASE AllTrim(aDadosT[nY,01]) == "010441"		// CAIXA ZAFFARI (NOVA)
								_cTES := "546"						
								CASE AllTrim(aDadosT[nY,01]) == "008409"		// CAIXA ZAFFARI ALTA
								_cTES := "546"
								CASE AllTrim(aDadosT[nY,01]) == "008410"		// CAIXA ZAFFARI BAIXA
								_cTES := "546"
								_nPrcTab  := 19.95
								CASE AllTrim(aDadosT[nY,01]) == "008411"		// CAIXA HIPPO
								_cTES := "546"
								CASE AllTrim(aDadosT[nY,01]) == "008412"		// CAIXA PETISKEIRA
								_cTES := "546"
								CASE AllTrim(aDadosT[nY,01]) == "008413"		// CAIXA CARREFOUR
								_cTES := "546"
								CASE AllTrim(aDadosT[nY,01]) == "008414"		// CAIXA WALLMART
								_cTES := "546"
								CASE AllTrim(aDadosT[nY,01]) == "008415"		// CAIXA FRIGORÍFICO SILVA
								_cTES := "547"
								CASE AllTrim(aDadosT[nY,01]) == "008062"		// CAIXA ANGELONI
								_cTES := "547"
								OTHERWISE
								_cTES := "???"
							ENDCASE

							AADD(_aSC6_Emb,{{"C6_FILIAL"  , FWxFilial("SC6")													, Nil },;
											{"C6_ITEM"    , _cItemEmb															, Nil },;
											{"C6_PRODUTO" , aDadosT[nY,01]														, Nil },;
											{"C6_DESCRI"  , GetAdvFVal("SB1", "B1_DESC", FWxFilial("SB1") + aDadosT[nY,01], 1)	, Nil },;
											{"C6_UM"      , GetAdvFVal("SB1", "B1_UM", FWxFilial("SB1") + aDadosT[nY,01], 1)	, Nil },;
											{"C6_QTDVEN"  , Val(aDadosT[nY,09])													, Nil },;
											{"C6_PRCVEN"  , _nPrcTab															, Nil },;
											{"C6_VALOR"   , Val(aDadosT[nY,09]) * _nPrcTab										, Nil },;
											{"C6_QTDLIB"  , Val(aDadosT[nY,09])													, Nil },;
											{"C6_GRUPO"   , GetAdvFVal("SB1", "B1_GRUPO", FWxFilial("SB1") + aDadosT[nY,01], 1)	, Nil },;
											{"C6_TES"     , _cTES																, Nil },;
											{"C6_LOCAL"   , GetAdvFVal("SB1", "B1_LOCPAD", FWxFilial("SB1") + aDadosT[nY,01], 1), Nil },;
											{"C6_NFORI"   , Substr(aDadosT[nY,03],01,9)											, Nil },;
											{"C6_IDENTB6" , aDadosT[nY,10]														, Nil },;
											{"C6_SERIORI" , Substr(aDadosT[nY,03],13,3)											, Nil },;
											{"C6_PRECAR"  , _PreCar        														, Nil },;
											{"C6_ITEMORI" , Substr(aDadosT[nY,03],16,4)											, Nil }})
						Endif
					Next nY

				EndIf
			Next nX

			lMsHelpAuto := .F.  // se .t. direciona as mensagens de help
			lMsErroAuto := .F.  // necessario a criacao

			If Len(_aSC5_Emb) > 0 .And. Len(_aSC6_Emb) > 0
				DbSelectArea("SC5")
				Begin Transaction
					MsExecAuto({|x,y,z|MATA410(x,y,z)},_aSC5_Emb,_aSC6_Emb,3)

					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
					EndIf

				End Transaction
			EndIf

		Else
			MsgInfo("Processo foi cancelado pelo usuário e nenhum pedido de venda será gerado.")
		Endif

	Endif

Return _aItens


/*/{Protheus.doc} _buscaCodCx
	Função que busca os códigos de produto relativos à caixas brancas próprias e retornáveis, concatenando em uma única string
	@type Function
	@author Adonai Gabriel
	@since 16/01/2024
	@return character, String dos códigos de produto relativos à caixas brancas próprias e retornáveis
/*/
Static Function _buscaCodCx()

	_cCod := ""

	_cQuery := "SELECT DISTINCT ZAB_PRODUT"	
	_cQuery += " FROM  " + RetSQLTab('ZAB')
	_cQuery += " WHERE " + RetSQLFil('ZAB')
	_cQuery += " AND ZAB_RETORN = 'S'"
	_cQuery += " AND ZAB_POSSE = 'P'"
	_cQuery += " AND " + RetSQLDel('ZAB')
	_cQuery += " ORDER BY ZAB_PRODUT"

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

    While QRY->(!EOF())
		_cCod += alltrim(QRY->ZAB_PRODUT) + "/"

		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    enddo

Return _cCod


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ QtdeInf  º Autor ³ Evandro Mugnol     º Data ³ 22/01/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Funcao para informar qtde a gerar                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QtdeInf()

	_cProd 	 := aDadosT[oBrwT:nAt,01]
	_nQtdeInf := Val(aDadosT[oBrwT:nAt,09])

	DEFINE MSDIALOG oDlg1 FROM 0,0 TO 150,250 PIXEL TITLE "Quantidade a Gerar"

	@ 015, 005 SAY   oSay VAR "Qtde a Gerar " OF oDlg1 PIXEL
	@ 015, 045 MSGET oGet VAR _nQtdeInf PICTURE "@E 999,999" VALID _Qtde() OF oDlg1 SIZE 50,009 PIXEL

	@ 040, 035 BMPBUTTON TYPE 1 ACTION _Atualiza(_cProd)
	@ 040, 065 BMPBUTTON TYPE 2 ACTION (oDlg1:End ())

	ACTIVATE DIALOG oDlg1 CENTERED

Return   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ _Qtde    º Autor ³ Evandro Mugnol     º Data ³ 22/01/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Funcao para validar a quantidade informada e atualizar o   º±±
±±º          ³ browse inferior                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _Qtde()
	Local nY
	_lRet  := .T.
	If _nQtdeInf > Val(aDadosT[oBrwT:nAt,05])
		MsgAlert("Quantidade Informada Maior que Saldo. Favor Informar Quantidade Disponível Conforme Saldo!")
		_lRet := .F.
	Endif

	aDadosT[oBrwT:nAt,09] := Str(_nQtdeInf)
	oBrwT:Refresh()

	If _lRet
		_nTQtdeInf := 0
		For nY:= 1 To Len(aDadosT)
			If _cProd == aDadosT[nY,01]
				_nTQtdeInf += Val(aDadosT[nY,09])
			Endif
		Next

		For nY:= 1 To Len(aDados)
			If _cProd == aDados[nY,01]
				If _nTQtdeInf > Val(aDados[nY,03])
					MsgAlert("Somatório das Quantidades Informadas para o produto " + AllTrim(_cProd) + " Maior que Qtde de Caixas. Favor Informar Quantidade Menor ou Igual a Qtde de Caixas!")
					_lRet := .F.
				Endif
			Endif
		Next
	Endif

Return(_lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ _Atualizaº Autor ³ Evandro Mugnol     º Data ³ 22/01/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Funcao para atualizar o browse superior na confirmação da  º±±
±±º          ³ quantidade informada                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _Atualiza(_cProd)
	Local nY
	//aDadosT[oBrwT:nAt,09] := Str(_nQtdeInf)
	//oBrwT:Refresh()

	_nTQtdeInf := 0
	For nY:= 1 To Len(aDadosT)
		If _cProd == aDadosT[nY,01]
			//_nTQtdeInf_nTQtdeInf += Val(aDadosT[nY,09])			
			_nTQtdeInf += Val(aDadosT[nY,09])
		Endif
	Next

	For nY:= 1 To Len(aDados)
		If _cProd == aDados[nY,01]
			aDados[nY,04] := Str(_nTQtdeInf)
			oBrw:Refresh()
		Endif
	Next

	oDlg1:End ()

Return

Static Function _GetPar1()
	_cRet := getmv('SI_PRDUNID')
Return(_cRet)

Static Function _GetPar2()
	_cRet := getmv('SI_PRDUNI2')
Return(_cRet)

Static Function _GetPar3()
	_cRet := getmv('SI_PRDUNI3')
Return(_cRet)

Static Function _GetPar4()
	_cRet := getmv('SI_PRDUNI4')
Return(_cRet)

Static Function _GetPar5()
	_cRet := getmv('SI_PRDUNI5')
Return(_cRet)

Static Function _GetPar6()
	_cRet := getmv('SI_PRDUNI6')
Return(_cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} _BuscaTES
Função que define 0 código de TES somente para empresa 08
@Since      Jun/2023
/*/
//-------------------------------------------------------------------
Static Function _BuscaTES(_cCodCli, _cLojCli, _cCodProd)

	_cNCMProd := GetAdvFVal("SB1", "B1_POSIPI", FWxFilial("SB1") + _cCodProd, 1)
	_cSegmCli := GetAdvFVal("SA1", "A1_CODSEG", FWxFilial("SA1") + _cCodCli + _cLojCli, 1)

	If AllTrim(_cNCMProd) == "23011010" .Or. AllTrim(_cNCMProd) == "23011090"
		If AllTrim(_cSegmCli) == "000001" .Or. AllTrim(_cSegmCli) == "000002"
			_cCodTES := "763"
		ElseIf AllTrim(_cSegmCli) == "000003" .Or. AllTrim(_cSegmCli) == "000004"
			_cCodTES := "558"
		Else
			_cCodTES := u_gjf47TES(_cCodCli + _cLojCli, _cCodProd)
		EndIf
	Else
		_cCodTES := u_gjf47TES(_cCodCli + _cLojCli, _cCodProd)
	EndIf

Return(_cCodTES)
