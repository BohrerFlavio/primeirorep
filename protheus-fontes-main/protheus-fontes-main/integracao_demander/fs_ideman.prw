#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "AP5MAIL.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} FS_IDEMAN
@Type			: Função de Usuário
@Sample			: U_FS_IDEMAN()
@Description	: Rotina de Importação dos dados do sistema de vendas Demander
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: 8Bit / Evandro
@Since			: Dez/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Fonte desenvolvido pela 8Bit e convertido para gerar pré-pedidos Silva
/*/
//--------------------------------------------------------------------------------------

#XTranslate .identIficador 		=> 1

// cabeçalho do arquivo
#XTranslate .horaProx 			=> 4

// Dados do pedido
#XTranslate .idPedido 			=> 2
#XTranslate .NumPedido 			=> 3
#XTranslate .CPFPedido 			=> 9
#XTranslate .NumPedCompra		=> 15
#XTranslate .DtEmissao 			=> 16
#XTranslate .ObsIntPedido 		=> 22
#XTranslate .ObsPrePedido 		=> 38

// Dados dos itens do pedido
#XTranslate .CodProdIT   		=> 3
#XTranslate .CodPedIT    		=> 4
#XTranslate .PercDesc    		=> 5
#XTranslate .PercAcres    		=> 6
#XTranslate .PrcSDescIT       	=> 8
#XTranslate .PrcCDescIT       	=> 9
#XTranslate .QuantIT    		=> 10
#XTranslate .ObsIT      	 	=> 12
#XTranslate .VlrDebCredIT  		=> 22


//-----------------------------------------------------------------------
/*/{Protheus.doc} JBDEMAN
Função de importacao dos pré-pedidos da Demander
@author     8Bit / Evandro
/*/
//-----------------------------------------------------------------------
//User Function JBDEMAN(_lAuto)
User Function JBDEMAN(_lAuto)

	//DEFAULT	_lAuto := .T.		// Variável de controle de é processado manualmente ou via schedule

	/*If !_lAuto
		If FWAlertYesNo("", "Confirma Importação dos Pedidos da Demander ?")
			MsAguarde({||U_FS_IDEMAN("A01")}, "Processando ...")
		Endif
	Else*/
		aTables := {"ZZ4","ZZ5","SA1","SA3","SB1","SX5"}
		RpcSetEnv("01","00","Administrador","dt1@s1lv4","OMS","FS_IDEMAN",aTables)

		U_FS_IDEMAN("A01")

		RpcClearEnv()
	//Endif

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} FS_IDEMAN
Função de importacao dos pré-pedidos da Demander
@author     8Bit / Evandro
/*/
//-----------------------------------------------------------------------
User Function FS_IDEMAN(_cChar)

	Local _nX 	:= 0
	Local _xArq := 0

	Private _cEmpresa  := IIF(_cChar==Nil,cEmpAnt,SubStr(_cChar,2,2))
	Private _cCam1 	   := "\arqsdemander\emp"+_cEmpresa+"\"
	Private _cArquivo  := ""
	Private _aLinha    := {}
	Private _cItem     := "000"
	Private _aPedidos  := {}
	Private _aItensPed := {}
	Private _aAuxPed   := {}
	Private _cMenNota  := ""
	Private _aArqImp   := {}
	Private _aArq      := {} 	// array dos arquivos do diretorio
	Private _aCpsAdic  := {} 	// array para campos adicionais
	Private _acpoAgr   := {}

	// Lê diretorio
	_aArqImp := Directory(_cCam1 + "recebidos\"+ "*.txt")

	If Len(_aArqImp) == 0
		ConOut("############ ==> Arquivo nao encontrado em " + _cCam1 + "recebidos\")
		Return
	EndIf

	For _nX := 1 To Len(_aArqImp)
		Aadd(_aArq,{.F.,_aArqImp[_nX][1],_aArqImp[_nX][3],_aArqImp[_nX][4]})
	Next

	_aArq := aSort(_aArq,,,{|x,y| x[3] > y[3]})

	// Passa todos arquivos
	For _xArq := 1 To Len(_aArq)

		// Abre o arquivo
		nHandle := FT_FUse(_cCam1 + "recebidos\" +_aArq[_xArq][2])

		If nHandle = -1
			ConOut("############ ==> Impossivel abrir arquivo")
			Return
		EndIf

		// Posiciona na primeria linha
		FT_FGoTop()
		_aLinha    := {}
		_aPedidos  := {}
		_aItensPed := {}
		_aAuxPed   := {}

		// Passa todo arquivo e cadastra cliente novo (id 18)
		Do While !FT_FEOF()
			IncProc()

			_Linha  := FT_FReadLn()
			_aLinha := StrTokArr2(_Linha,'|',.T.)

			FS_MontaArray()

			// Pula para próxima linha
			FT_FSKIP()

			// Se For final do arquivo cadastra cliente e pedido do arquivo
			If FT_FEOF()
				// Ordena pela ordem do tablet
				ASORT(_aAuxPed, , , { | x,y | x[1]+strzero(x[4],2) < y[1]+strzero(y[4],2) })

				ConOut("############ ==> Cadastrando pre pedidos ...")
				FS_PrePed()
			EndIf
		EndDo

		// Fecha o Arquivo
		FT_FUSE()

		_cFile := AllTrim(_cCam1 + "recebidos\" + AllTrim(_aArq[_xArq,2]) )
		_xFile := AllTrim(_cCam1 + "processados\" + AllTrim(_aArq[_xArq,2]))

		__CopyFile(_cFile, _xFile)

		If File(_xFile)
			fErase(_cFile)
		EndIf

	Next

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} FS_MontaArray
Função que monta o array com os dados da demander
@author     8Bit / Evandro
/*/
//-----------------------------------------------------------------------
Static Function FS_MontaArray()

	Local cPData := ""

	Private _cClie := ""
	Private _cLoja := ""

	// gravo a proxima data a ser utilizada no paramentro
	If _aLinha [.identIficador] == "DADOS_SINCRONIZACAO"
		cPData := _aLinha [.horaProx]
	EndIf

	If _aLinha [.identIficador] == "16" 		// Pré pedidos
		aadd(_aPedidos,{_aLinha [.idPedido]															,;
						_aLinha [.NumPedido]														,;
						Ctod(Substr(_aLinha [.DtEmissao],09,02) + "/ " + Substr(_aLinha [.DtEmissao],06,02) + "/ " + Substr(_aLinha [.DtEmissao],01,04))	,;
						_AjusTxt(AllTrim(_aLinha [.ObsIntPedido]))									,;
						_AjusTxt(AllTrim(_aLinha [.ObsPrePedido]))									,;
						StrTran(StrTran(StrTran(_aLinha [.CPFPedido],'-',''),'.',''),'/','')		,;
						AllTrim(_aLinha [.NumPedCompra])											})
	EndIf

	If _aLinha [.identIficador] == "17" 		// Itens pré pedidos
		aadd(_aItensPed,{_aLinha [.CodProdIT]														,;
						 _aLinha [.CodPedIT]														,;
						 _aLinha [.PrcSDescIT]														,;
						 _aLinha [.PrcCDescIT]														,;
						 _aLinha [.QuantIT]															,;
						 _aLinha [.ObsIT]															,;
						 _aLinha [.VlrDebCredIT]													})

	EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} FS_PrePed
Função que gera pré pedido de venda
@author     8Bit / Evandro
/*/
//-----------------------------------------------------------------------
Static Function FS_PrePed()

	Local _cIdDeman := ""
	Local _cPedDem  := ""
	Local _n3 	    := 0
	Local _n6 	    := 0
	Local _aDCli	:= {}

	For _n3 := 1 To Len(_aPedidos)
		_cMenNota := ""
		_cIdDeman := _aPedidos[_n3][01] 
		_cPedDem  := _aPedidos[_n3][02]
		_VlrTit   := 0           // Valor dos titulos
		_VlrPP    := 0           // Valor dos pre-pedidos
		_LimCre   := 0           // Valor do limite de credito
		_VenCre   := Ctod("")    // Data do limite de credito
		_nSaldo   := 0           // Valor do saldo
		_nTPPAtu  := 0           // Valor do pre-pedido atual
		_cCtrlZZ4 := ""

		If !ExisteZZ4(_cPedDem)

			_cCNPJ := _aPedidos[_n3][06]

			if testCGC(_cCNPJ)
				_aDCli := cliAtivo(_cCNPJ)
				_cClie := _aDCli[1]
				_cLoja := _aDCli[2]
				_CliStat := _aDCli[3]
				_CliBlqM := _aDCli[4]
				_CliBlqP := _aDCli[5]
			else
				_cClie   := GetAdvFVal("SA1","A1_COD", FWxFilial("SA1") + _cCNPJ, 3, Space(TamSx3("A1_COD")[1]), .T.)
				_cLoja   := GetAdvFVal("SA1","A1_LOJA", FWxFilial("SA1") + _cCNPJ, 3, Space(TamSx3("A1_LOJA")[1]), .T.)
				_CliStat := GetAdvFVal("SA1","A1_MSBLQL",FWxfilial("SA1") + _cClie + _cLoja, 1, Space(TamSx3("A1_MSBLQL")[1]) , .T.)	// Status do Cliente 	 - 1=Inativo ; 2=Ativo
				_CliBlqM := GetAdvFVal("SA1","A1_SIBLQL",FWxfilial("SA1") + _cClie + _cLoja, 1, Space(TamSx3("A1_SIBLQL")[1]) , .T.)	// Bloqueio Movimentação - 1=Sim ; 2=Não
				_CliBlqP := GetAdvFVal("SA1","A1_POBLQL",FWxfilial("SA1") + _cClie + _cLoja, 1, Space(TamSx3("A1_POBLQL")[1]) , .T.)	// Bloqueio Portal 		 - 1=Sim ; 2=Não
			endif

			//If _CliStat == "1" .Or. _CliBlqM == "1" .Or. _CliBlqP == "1" 
			If _CliBlqM == "1" .Or. _CliBlqP == "1"
				// Geração do Log
				DbSelectArea("ZLD")
				RecLock("ZLD",.T.)
				ZLD->ZLD_FILIAL := FWxFilial("ZLD")
				ZLD->ZLD_IDDEM  := _cIdDeman 
				ZLD->ZLD_PVDEM  := _cPedDem
				ZLD->ZLD_PREPED := ""
				ZLD->ZLD_DATLOG := Date()
				ZLD->ZLD_HORLOG := Time()
				ZLD->ZLD_SEVERI := "3"		// 1=Informativo ; 2=Alerta ; 3=Crítico
				ZLD->ZLD_DESCRI := "CLIENTE/LOJA BLOQUEADO PARA IMPORTAÇÃO/MOVIMENTAÇÃO. NÃO É PERMITIDO IMPORTAÇÃO/MOVIMENTAÇÃO PARA O CLIENTE/LOJA " + _cClie + "/" + _cLoja + ". APONTE OUTRO CLIENTE/LOJA OU CONSULTE O SETOR FINANCEIRO."
				MsUnlock()
			Else
				_cNumPPed := GETSXENUM("ZZ4","ZZ4_NUM")
				ConfirmSx8()

				//---------------------------------------------------------------------------------------------------
				// GRAVAÇÃO DOS ITENS DOS PRÉ PEDIDOS RECEBIDOS DO FORÇA DE VENDAS DEMANDER							|
				// Efetua antes a gravação dos itens para gerar totalizadores para campos do cabeçalho (tabela ZZ4)	|
				//---------------------------------------------------------------------------------------------------
				_nTotaZZ5 := 0
				_nQtdeZZ5 := 0
				_cItem    := "000"
				_nQTDCaix := 0
				_nQTDPeso := 0
				_nvTotal  := 0
				_nTGeral  := 0
				_lTpP := .F.
				_lTpD := .F.

				// Totaliza a quantide de itens de cada pedido
				For _n6 := 1 To Len(_aItensPed)
					If _cPedDem == _aItensPed[_n6][2]		// Enquanto for o mesmo pedido do Demander
						_nTotaZZ5 := _nTotaZZ5 + 1
					EndIf
				Next _n6

				For _n6 := 1 To Len(_aItensPed)
					If _cPedDem == _aItensPed[_n6][2]		// Enquanto for o mesmo pedido do Demander
						_cItem := Soma1(_cItem)

						DbSelectArea("ZZ5")
						RecLock("ZZ5",.T.)
						ZZ5->ZZ5_FILIAL := FWxFilial("ZZ5") 
						ZZ5->ZZ5_NUM    := _cNumPPed
						ZZ5->ZZ5_ITEM   := _cItem
						ZZ5->ZZ5_COD    := _aItensPed[_n6][1]
						ZZ5->ZZ5_DESC   := GetAdvFVal("SB1", "B1_DESCRED", FWxFilial("SB1") + _aItensPed[_n6][1], 1, Space(TamSx3("B1_DESCRED")[1]), .T.)
						ZZ5->ZZ5_USERIN := "Demander"
						nQPCaix := Val(_aItensPed[_n6][5])
						ZZ5->ZZ5_QPCAIX := nQPCaix
						// Calcula "Qtde Prevista Peso em Caixa" e "Saldo a ser Produzido Porc."
						nPesMedio := 0
						If SB1->(Msseek(FWxFilial("SB1") + _aItensPed[_n6][1]))
							nPesMedCx := SB1->B1_PMCAIX
							nPesMedio := (nQPCaix * nPesMedCx)
						Else
							nPesMedio := 1
						EndIf
						ZZ5->ZZ5_QPPESO := nPesMedio
						nPrecoO := Round(Val(_aItensPed[_n6][3]) / nPesMedCx, 2)
						nPrecoD := Round(Val(_aItensPed[_n6][4]) / nPesMedCx, 2)
						ZZ5->ZZ5_PRECO  := nPrecoO
						ZZ5->ZZ5_PRIORI := "C"
						// Apura o "Tipo Bonificação" e "Valor Bonificação"
						_nVlBoni  := nPrecoD - nPrecoO
						_cTPBoni  := IIF(_nVlBoni == 0, "", IIF(_nVlBoni < 0, "D", "A"))		// D=Desconto ; A=Acréscimo
						_nPrcBoni := IIF(_cTPBoni == "D", _nVlBoni * (-1), _nVlBoni)
						ZZ5->ZZ5_TPBONI := _cTPBoni
						ZZ5->ZZ5_BONIF  := _nPrcBoni
						ZZ5->ZZ5_CCOR   := "0"
						ZZ5->ZZ5_PRCFIN := IIF(_cTPBoni == "A", nPrecoO + _nPrcBoni, IIF(_cTPBoni == "D", nPrecoO - _nPrcBoni, nPrecoO))
						ZZ5->ZZ5_OBS    := Upper(_aItensPed[_n6][6])
						ZZ5->ZZ5_RESERV := "N"
						If Alltrim(_cClie) == "007980"
							ZZ5->ZZ5_TIPCOD := 2
						Else
							ZZ5->ZZ5_TIPCOD := 0
						EndIf
						ZZ5->ZZ5_SLDPOR := nPesMedio
						ZZ5->ZZ5_USERAL := "Demander"
						ZZ5->ZZ5_DATAAL := Date()
						ZZ5->ZZ5_HORAAL := Time()
						MsUnlock()

						// Realiza cálculos necessários para serem inseridos no cabeçalho do Pré Pedido
						//qCaixa    := ZZ5->ZZ5_QPCAIX
						//qPeso     := ZZ5->ZZ5_QPPESO
						_nvTotal  := ZZ5->ZZ5_QPPESO * ZZ5->ZZ5_PRCFIN
						_nQTDCaix += nQPCaix
						_nQTDPeso += nPesMedio
						_nTGeral  += _nvTotal

						_cGrpProd := GetAdvFVal("SB1", "B1_GRUPO", FWxFilial("SB1") + ZZ5->ZZ5_COD, 1, Space(TamSx3("B1_GRUPO")[1]) , .T.)
						If Substr(_cGrpProd,1,2) == "56"
							_lTpP := .T.
						Else
							_lTpD := .T.
						EndIf

						_nQtdeZZ5 := _nQtdeZZ5 + 1
					EndIf
				Next _n6

				//---------------------------------------------------------------------------------------------------
				// GRAVAÇÃO DO CABEÇALHO DOS PRÉ PEDIDOS RECEBIDOS DO FORÇA DE VENDAS DEMANDER						|
				//---------------------------------------------------------------------------------------------------
				_cNomCli := GetAdvFVal("SA1", "A1_NOME" , FWxFilial("SA1") + _cClie + _cLoja, 1, Space(TamSx3("A1_NOME")[1]) , .T.)
				_cMunCli := GetAdvFVal("SA1", "A1_MUN"  , FWxFilial("SA1") + _cClie + _cLoja, 1, Space(TamSx3("A1_MUN")[1])  , .T.)
				_cVen    := GetAdvFVal("SA1", "A1_VEND" , FWxFilial("SA1") + _cClie + _cLoja, 1, Space(TamSx3("A1_VEND")[1]) , .T.)
				_nComVen := GetAdvFVal("SA3", "A3_COMIS", FWxFilial("SA3") + _cVen			, 1, 0							 , .T.)
				_nComCli := GetAdvFVal("SA1", "A1_COMIS", FWxFilial("SA1") + _cClie + _cLoja, 1, 0							 , .T.)
				_cNomRep := GetAdvFVal("SA3", "A3_NOME" , FWxFilial("SA3") + _cVen			, 1, Space(TamSx3("A3_NOME")[1]) , .T.)
				If _nComCli = 0
					_nCom := _nComVen
				Else
					_nCom := _nComCli
				EndIf
				_cDesSegm := ""
				_cSegmCli := GetAdvFVal("SA1", "A1_SATIV1", FWxFilial("SA1") + _cClie + _cLoja, 1, Space(TamSx3("A1_SATIV1")[1]), .T.)
				If !Empty(_cSegmCli)
					_cDesSegm := GetAdvFVal("SX5","X5_DESCRI", FWxFilial("SX5") + "T3" + AllTrim(_cSegmCli), 1, Space(TamSx3("X5_DESCRI")[1]), .T.)
				Endif
				_LimCre := GetAdvFVal("SA1", "A1_LC"    , FWxFilial("SA1") + _cClie + _cLoja, 1, 0						      , .T.)
				_VenCre := GetAdvFVal("SA1", "A1_VENCLC", FWxFilial("SA1") + _cClie + _cLoja, 1, stod('')					  , .T.)
				_Bloq   := GetAdvFVal("SA1", "A1_MSBLQL", FWxFilial("SA1") + _cClie + _cLoja, 1, Space(TamSx3("A1_MSBLQL")[1]), .T.)

				_cCtrlZZ4 := "INIPROC"
				DbSelectArea("ZZ4")
				RecLock("ZZ4",.T.)
				ZZ4->ZZ4_FILIAL := FWxFilial("ZZ4")
				ZZ4->ZZ4_NUM    := _cNumPPed
				ZZ4->ZZ4_STATUS := "B"			// L=Liberado;C=Carregando...;E=Encerrado;S=Espera;B=Bloqueado;F=Faturado;I=Importado;P=Portal;R=Producao
				ZZ4->ZZ4_STAFUS := "1"			// 1=Nao Enviado;2=Enviado;3=Ret. Sequenciado;4=Seq. Cancelado
				ZZ4->ZZ4_ORIGEM := "P"			// E=EDI;P=Portal;D=Digitacao
				ZZ4->ZZ4_MARCA  := ""
				ZZ4->ZZ4_DATA   := _aPedidos[_n3][03]
				ZZ4->ZZ4_DATAC  := Date()
				ZZ4->ZZ4_HORAC  := Time()
				ZZ4->ZZ4_TPOPER := "V"			// V=Venda;T=Transferencia;R=Remessa;C=Compra;B=Bonificacao;E=Exportacao
				ZZ4->ZZ4_CODCLI := _cClie 
				ZZ4->ZZ4_LOJA   := _cLoja
				ZZ4->ZZ4_NOME   := _cNomCli
				ZZ4->ZZ4_MUN    := _cMunCli
				ZZ4->ZZ4_USAR   := "Demander"
				ZZ4->ZZ4_QPPESO := _nQTDPeso
				ZZ4->ZZ4_QPCAIX := _nQTDCaix
				ZZ4->ZZ4_TOTAL  := _nTGeral
				ZZ4->ZZ4_OBS    := Upper(_aPedidos[_n3][04] + " " + _aPedidos[_n3][05])
				ZZ4->ZZ4_CREVIG := _LimCre
				ZZ4->ZZ4_REPRES := _cVen
				ZZ4->ZZ4_NOMREP := _cNomRep
				ZZ4->ZZ4_COMIS  := _nCom
				If Alltrim(_cClie) = "007980"
					ZZ4->ZZ4_TIPCOD := 2
				Else
					ZZ4->ZZ4_TIPCOD := 0
				EndIf
				ZZ4->ZZ4_DTENTR := Ctod("")
				ZZ4->ZZ4_REDIST := "2"
				ZZ4->ZZ4_VFRETE := 0.35
				ZZ4->ZZ4_TIPOPR := IIF(_lTpP .And. _lTpD, '', IIF(_lTpD, "D", "P"))
				ZZ4->ZZ4_SATIV1 := AllTrim(_cSegmCli) + " - " + AllTrim(_cDesSegm) 
				ZZ4->ZZ4_AUTDTP := "N"
				If _LimCre == 0 .Or. Empty(_VenCre)
					ZZ4->ZZ4_LIMCRE := "B"
					ZZ4->ZZ4_SIBLQL := "1"
				EndIf
				ZZ4->ZZ4_PCOMPR := _aPedidos[_n3][07]
				ZZ4->ZZ4_PDEMAN := _cPedDem
				MsUnlock()

				_nTPPAtu := ZZ4->ZZ4_TOTAL

				// Verifica o Saldo dos títulos a receber......nova alt2
				cQuery := " SELECT SUM(E1_SALDO) AS SALDO "
				cQuery += "   FROM " + RetSQLTab("SE1")
				cQuery += "  WHERE " + RetSQLFil("SE1")
				cQuery += "    AND E1_CLIENTE = '" + _cClie + "' AND E1_LOJA = '" + _cLoja + "' AND E1_STATUS = 'A'"
				cQuery += "    AND E1_BAIXA = '' AND E1_TIPO = 'NF'"
				cQuery += "    AND " + RetSQLDel("SE1")

				cQuery := ChangeQuery(cQuery)

				If Select("LIM")<>0
					LIM->(dbCloseArea())
				Endif

				TCQUERY cQuery NEW ALIAS "LIM"

				_VlrTit := LIM->SALDO

				// Verifica o total em pré pedidos
				cQuery := " SELECT SUM(ZZ4_TOTAL) AS TOTAL "
				cQuery += "   FROM " + RetSQLTab("ZZ4")
				cQuery += "  WHERE " + RetSQLFil("ZZ4")
				cQuery += "   AND ZZ4_CODCLI = '" + _cClie + "' AND ZZ4_LOJA = '" + _cLoja + "' AND ZZ4_STATUS NOT IN('E','F','C','P')"
				cQuery += "   AND ZZ4_NUM <> '" + _cNumPPed + "'"
				cQuery += "   AND " + RetSQLDel("ZZ4")

				cQuery := ChangeQuery(cQuery)

				If Select("LIM2")<>0
					LIM2->(dbCloseArea())
				Endif

				TCQUERY cQuery NEW ALIAS "LIM2"

				_VlrPP  := LIM2->TOTAL
				_nSaldo := _LimCre - (_VlrPP + _nTPPAtu +_VlrTit)

				DbSelectArea("ZZ4")
				RecLock("ZZ4",.F.)
				If (_nSaldo < 0) .Or. (Date() > _VenCre)
					ZZ4->ZZ4_LIMCRE := "B"
					ZZ4->ZZ4_SIBLQL := "1"
				Else
					ZZ4->ZZ4_LIMCRE := "L"
					ZZ4->ZZ4_SIBLQL := IIF(_Bloq == "1", "1", "2")
				EndIf
				MsUnlock()
				_cCtrlZZ4 := _cCtrlZZ4 + "FIMPROC"

				If _cCtrlZZ4 == "INIPROCFIMPROC" .And. _nTotaZZ5 == _nQtdeZZ5
					// Geração do Log
					DbSelectArea("ZLD")
					RecLock("ZLD",.T.)
					ZLD->ZLD_FILIAL := FWxFilial("ZLD")
					ZLD->ZLD_IDDEM  := _cIdDeman 
					ZLD->ZLD_PVDEM  := _cPedDem
					ZLD->ZLD_PREPED := _cNumPPed
					ZLD->ZLD_DATLOG := Date()
					ZLD->ZLD_HORLOG := Time()
					ZLD->ZLD_SEVERI := "1"		// 1=Informativo ; 2=Alerta ; 3=Crítico
					ZLD->ZLD_DESCRI := "PRÉ PEDIDO " + _cNumPPed + " GERADO COM SUCESSO."
					MsUnlock()
				Else
					If _cCtrlZZ4 <> "INIPROCFIMPROC"
						// Geração do Log
						DbSelectArea("ZLD")
						RecLock("ZLD",.T.)
						ZLD->ZLD_FILIAL := FWxFilial("ZLD")
						ZLD->ZLD_IDDEM  := _cIdDeman 
						ZLD->ZLD_PVDEM  := _cPedDem
						ZLD->ZLD_PREPED := _cNumPPed
						ZLD->ZLD_DATLOG := Date()
						ZLD->ZLD_HORLOG := Time()
						ZLD->ZLD_SEVERI := "3"		// 1=Informativo ; 2=Alerta ; 3=Crítico
						ZLD->ZLD_DESCRI := "PROBLEMA NA GRAVAÇÃO DOS DADOS DO CABEÇALHO DO PRÉ PEDIDO. VERIFIQUE, POIS OS DADOS PODEM ESTAR INCOMPLETOS."
						MsUnlock()
					EndIf

					If _nTotaZZ5 <> _nQtdeZZ5
						// Geração do Log
						DbSelectArea("ZLD")
						RecLock("ZLD",.T.)
						ZLD->ZLD_FILIAL := FWxFilial("ZLD")
						ZLD->ZLD_IDDEM  := _cIdDeman 
						ZLD->ZLD_PVDEM  := _cPedDem
						ZLD->ZLD_PREPED := _cNumPPed
						ZLD->ZLD_DATLOG := Date()
						ZLD->ZLD_HORLOG := Time()
						ZLD->ZLD_SEVERI := "3"		// 1=Informativo ; 2=Alerta ; 3=Crítico
						ZLD->ZLD_DESCRI := "HOUVE PROBLEMAS NA QTDE DE ITENS GERADOS COM BASE NA QTDE DE ITENS DO FORÇA DE VENDAS. VERIFIQUE, POIS OS DADOS PODEM ESTAR INCOMPLETOS."
						MsUnlock()
					EndIf
				EndIf
			EndIf
		Else
			// Geração do Log
			DbSelectArea("ZLD")
			RecLock("ZLD",.T.)
			ZLD->ZLD_FILIAL := FWxFilial("ZLD")
			ZLD->ZLD_IDDEM  := _cIdDeman 
			ZLD->ZLD_PVDEM  := _cPedDem
			ZLD->ZLD_PREPED := ""
			ZLD->ZLD_DATLOG := Date()
			ZLD->ZLD_HORLOG := Time()
			ZLD->ZLD_SEVERI := "2"		// 1=Informativo ; 2=Alerta ; 3=Crítico
			ZLD->ZLD_DESCRI := "PEDIDO " + _cPedDem + " DO DEMANDER JÁ IMPORTADO."
			MsUnlock()
		EndIf

	Next _n3

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} ExisteZZ4
Função que verIfica se o pedido do Demander já foi importado
@author     8Bit / Evandro
/*/
//-----------------------------------------------------------------------
Static Function ExisteZZ4(_cPVDeman)

	Local _cPVDeman1 := _cPVDeman
	Local _lRet := .F.
	Local _cQuery := ""

	_cQuery := "SELECT COUNT(*) AS QUANT "
	_cQuery += "  FROM " + RetSqlTab("ZZ4")
	_cQuery += " WHERE " + RetSqlFil("ZZ4")
	_cQuery += "   AND ZZ4_PDEMAN = '" + _cPVDeman1 + "' "
	_cQuery += "   AND " + RetSqlDel("ZZ4")

	_cQuery  := ChangeQuery(_cQuery)

	If Select("TMP1") != 0
		TMP1->(DbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP1"

	If TMP1->QUANT > 0
		_lRet := .T.
	EndIf

	TMP1->(DbCloseArea())

Return(_lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} testCGC
Função que verifica se existe mais de um cliente com o mesmo CPF/CNPJ
@author     8Bit / Adonai
/*/
//-----------------------------------------------------------------------
Static Function testCGC(_cCNPJ)

	Local _lRet := .F.
	Local _cQuery := ""

	_cQuery := "SELECT COUNT(*) AS QUANT "
	_cQuery += "  FROM " + RetSqlTab("SA1")
	_cQuery += " WHERE " + RetSqlFil("SA1")
	_cQuery += "   AND A1_CGC = '" + _cCNPJ + "' "
	_cQuery += "   AND " + RetSqlDel("SA1")

	_cQuery  := ChangeQuery(_cQuery)

	If Select("TMP2") != 0
		TMP2->(DbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP2"

	If TMP2->QUANT > 1
		_lRet := .T.
	EndIf

	TMP2->(DbCloseArea())

Return(_lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} cliAtivo
Função que busca os dados do cliente ativo
@author     8Bit / Adonai
/*/
//-----------------------------------------------------------------------
Static Function cliAtivo(_cCNPJ)

	Local _cQuery := ""
	Local _aRet := {}

	_cQuery := "SELECT SA1.A1_COD AS COD, SA1.A1_LOJA AS LOJA, SA1.A1_MSBLQL AS MSBLQL, SA1.A1_SIBLQL AS SIBLQL, SA1.A1_POBLQL AS POBLQL"
	_cQuery += "  FROM " + RetSqlTab("SA1")
	_cQuery += " WHERE " + RetSqlFil("SA1")
	_cQuery += "   AND A1_CGC = '" + _cCNPJ + "' "
	_cQuery += "   AND A1_MSBLQL = '2' "
	_cQuery += "   AND " + RetSqlDel("SA1")

	_cQuery  := ChangeQuery(_cQuery)

	If Select("TMP3") != 0
		TMP3->(DbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP3"

	_aRet := {TMP3->COD,TMP3->LOJA,TMP3->MSBLQL,TMP3->SIBLQL,TMP3->POBLQL}

	TMP3->(DbCloseArea())

Return(_aRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} _AjusTxt
Função que ajusta caracteres especiais de um texto
@author     8Bit / Evandro
/*/
//-----------------------------------------------------------------------
Static Function _AjusTxt(cString)

	Default cString := ''

	cString := StrTran(cString,"-"," ")
	cString := StrTran(cString,"."," ")
	cString := StrTran(cString,"´"," ")
	cString := StrTran(cString,","," ")
	cString := StrTran(cString,"("," ")
	cString := StrTran(cString,")"," ")
	cString := StrTran(cString,"/"," ")
	cString := StrTran(cString,"\"," ")
	cString := StrTran(cString,":"," ")
	cString := StrTran(cString,"^"," ")
	cString := StrTran(cString,"*"," ")
	cString := StrTran(cString,"$"," ")
	cString := StrTran(cString,"#"," ")
	cString := StrTran(cString,"!"," ")
	cString := StrTran(cString,"["," ")
	cString := StrTran(cString,"]"," ")
	cString := StrTran(cString,"?"," ")
	cString := StrTran(cString,";"," ")
	cString := StrTran(cString,"ç","c")
	cString := StrTran(cString,"`"," ")
	cString := StrTran(cString,"á","a")
	cString := StrTran(cString,"ã","a")
	cString := StrTran(cString,"à","a")
	cString := StrTran(cString,"â","a")
	cString := StrTran(cString,"é","e")
	cString := StrTran(cString,"è","e")
	cString := StrTran(cString,"ê","e")
	cString := StrTran(cString,"í","i")
	cString := StrTran(cString,"ì","i")
	cString := StrTran(cString,"ó","o")
	cString := StrTran(cString,"ò","o")
	cString := StrTran(cString,"õ","o")
	cString := StrTran(cString,"ô","o")
	cString := StrTran(cString,"ú","u")
	cString := StrTran(cString,"ù","u")
	cString := StrTran(cString,"Á","A")
	cString := StrTran(cString,"À","A")
	cString := StrTran(cString,"Â","A")
	cString := StrTran(cString,"Ã","A")
	cString := StrTran(cString,"É","E")
	cString := StrTran(cString,"È","E")
	cString := StrTran(cString,"Ê","E")
	cString := StrTran(cString,"Í","I")
	cString := StrTran(cString,"Ì","I")
	cString := StrTran(cString,"Ó","O")
	cString := StrTran(cString,"Ò","O")
	cString := StrTran(cString,"Õ","O")
	cString := StrTran(cString,"Ô","O")
	cString := StrTran(cString,"Ú","U")
	cString := StrTran(cString,"Ç","C")
	cString := StrTran(cString,"@"," ")
	cString := StrTran(cString,"%"," ")
	cString := StrTran(cString,"~"," ")
	cString := StrTran(cString,"¨"," ")
	cString := StrTran(cString,"{"," ")
	cString := StrTran(cString,"}"," ")
	cString := StrTran(cString,"+"," ")
	cString := StrTran(cString,"-"," ")
	cString := StrTran(cString,"="," ")
	cString := StrTran(cString,"_"," ")
	cString := StrTran(cString,"<"," ")
	cString := StrTran(cString,">"," ")
	cString := StrTran(cString,"&","E")
	cString := StrTran(cString,"|"," ")
	cString := StrTran(cString,"Ã§Ã£","ca")

Return(cString)
