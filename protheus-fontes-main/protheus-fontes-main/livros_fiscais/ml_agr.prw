#INCLUDE "rwmake.ch"

User Function ML_AGR()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ ML_AGR   ³ Autor ³ Alexandre Dalpiaz     ³ Data ³ 08.11.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Exportacao de dados do sistema AGREGAR/RS                  ³±±
	±±³          ³ (Secretaria da Fazenda)                                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Frigorífico Silva                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	cPerg := "ML_AGR"

	Pergunte(cPerg,.F.)

	@ 1, 1 to 200, 420 dialog _oDlgMenu title "ML_AGR - Exporta dados para o sistema Agregar"

	// Objetos fonte e texto para mostrar o titulo. Deve ser declarado dentro do dialogo
	private _oFont1   := TFont():New ("Arial", 06, 20)
	private _oTitulo  := tSay():New (20,       ;  // Coord vert
									75,       ;  // Coord horiz
									,       ;  // Codeblock p/ retornar texto a exibir
									_oDlgMenu,;  // Dialogo onde o obj. serah criado
									,       ;  // Mascara
									_oFont1,  ;  // Objeto tipo fonte
									,       ;  // Reservado
									,       ;  // Reservado
									,       ;  // Reservado
									.T.,       ;  // .T. = pixels; .F. = caracteres
									255,       ;  // Cor do texto (ver include\colors.ch)
									,       ;  // Cor do fundo
									100,       ;  // Largura em pixels
									15        )  // Altura em pixels

	_oTitulo:SetText ("Protheus.  >>> Agregar/RS")

	@ 40,  40  say "Este programa gera dados para o sistema Agregar em arquivo texto" size 140, 30
	@ 080, 80  bmpbutton type 5 action pergunte (cPerg,.t.)
	@ 080, 120 bmpbutton type 1 action MsAguarde({|| _Exporta ()}, "Processando...")
	@ 080, 160 bmpbutton type 2 action Close (_oDlgMenu)
	activate dialog _oDlgMenu centered

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preparacao dos dados para exportacao                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Exporta()
	Local _nI := 0
	Local _nJ
	
	_aHandle := {}
	_aArqTxt := {}
	aAdd(_aArqTxt , 'EMPRESAS.TXT')
	aAdd(_aArqTxt , 'NOTASENT.TXT')
	aAdd(_aArqTxt , 'NOTASEN1.TXT')
	aAdd(_aArqTxt , 'PRODFRIG.TXT')
	aAdd(_aArqTxt , 'CONDENAS.TXT')
	aAdd(_aArqTxt , 'NOTASSAI.TXT')
	aAdd(_aArqTxt , 'NOTASSA1.TXT')

	MsProcTxt('Verificando e atualizando Condenas (SZ1)...')

	GeraCond()

	MsProcTxt('Criando arquivos textos...')

	For _nI := 1 to len(_aArqTxt)
		_nHandle := fCreate (alltrim(mv_par03) + _aArqTxt[_nI], 0)
		If fError() <> 0
			_cLinha := 'Erro na criacao do arquivo ' + alltrim(mv_par03) + _aArqTxt[_nI] + chr(13)
			_cLinha += 'A operacao sera abortada' + chr(13) + chr(13)
			_cLinha += 'Verifique o caminho informado no parametro 4'
			MsgBox(_cLinha,'ATENCAO!!!','STOP')
			For _nJ := 1 to _nI -1
				fClose(_aHandle[_nJ])
			Next          
			Return()
		Else
			aAdd(_aHandle , _nHandle)
		EndIf
	Next

	MsProcTxt('Buscando informacoes referente compra de gado')

	_cQuery := " SELECT C7_TPCOM, 'P' TIPOABATE, C7_GTA, C7_DTABATE,"
	_cQuery += chr(13) + " CASE WHEN ISNULL(Z1_CODCOND,'') = '' THEN 'N' ELSE 'S' END TEMCONDENA,"
	_cQuery += chr(13) + " B1_FILIAL, B1_COD, B1_DESC, B1_CODSEC,"
	_cQuery += chr(13) + " F1_DOC, F1_EMISSAO, F1_VALBRUT, D1_PEDIDO, D1_NFPROD, D1_VUNIT, D1_ITEM, D1_QTSEGUM, D1_CF, D1_PICM,"

	_cQuery += chr(13) + " CASE WHEN C7_TPCOM = 'V' THEN D1_QUANT ELSE ISNULL(C7_PESSEC,0) END KGVIVO,"
	_cQuery += chr(13) + " CASE WHEN C7_TPCOM IN ('R','Q') THEN D1_QUANT ELSE ISNULL(C7_PESSEC,0) END KGREND,"

	_cQuery += chr(13) + " A2_CGC,A2_INSCR, A2_NOME, A2_EST, A2_MUN, CASE WHEN A2_TPFOR = 'R' THEN 'P' ELSE A2_TPFOR END A2_TPFOR,"
	_cQuery += chr(13) + " ISNULL(Z1_CODCOND,'') Z1_CODCOND, ISNULL(Z1_QUANT,0) Z1_QUANT"

	_cQuery += chr(13) + " FROM SF4010 SF4, SB1010 SB1, SA2010 SA2, SF1010 SF1, SD1010 SD1"

	_cQuery += chr(13) + " LEFT JOIN SZ1010 SZ1"
	_cQuery += chr(13) + " ON  SZ1.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND Z1_PEDIDO = D1_PEDIDO"
	_cQuery += chr(13) + " AND Z1_FILIAL = D1_FILIAL AND Z1_FILIAL = '" + xfilial('SZ1') + "'"

	_cQuery += chr(13) + " LEFT JOIN SC7010 SC7"
	_cQuery += chr(13) + " ON  SC7.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND C7_PRODUTO = D1_COD"
	_cQuery += chr(13) + " AND C7_NUM = D1_PEDIDO"
	_cQuery += chr(13) + " AND C7_ITEM = D1_ITEMPC"
	_cQuery += chr(13) + " AND C7_FILIAL = D1_FILIAL AND C7_FILIAL = '" + xfilial('SC7') + "'"

	_cQuery += chr(13) + " WHERE SF4.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND F4_AGREGRS = 'S'"
	_cQuery += chr(13) + " AND F4_CODIGO = D1_TES"
	_cQuery += chr(13) + " AND F4_FILIAL = D1_FILIAL AND F4_FILIAL = '" + xfilial('SF4') + "'"

	_cQuery += chr(13) + " AND SB1.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND B1_TIPO IN ('PA','MP','PR')"
	_cQuery += chr(13) + " AND B1_COD = D1_COD AND B1_FILIAL = '" + xfilial('SB1') + "'"

	_cQuery += chr(13) + " AND SA2.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND A2_COD = F1_FORNECE"
	_cQuery += chr(13) + " AND A2_LOJA = F1_LOJA AND A2_FILIAL = '" + xfilial('SA2') + "'"

	_cQuery += chr(13) + " AND SF1.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND F1_LOJA = D1_LOJA"
	_cQuery += chr(13) + " AND F1_FORNECE = D1_FORNECE"
	_cQuery += chr(13) + " AND F1_SERIE = D1_SERIE"
	_cQuery += chr(13) + " AND F1_DOC = D1_DOC"
	_cQuery += chr(13) + " AND F1_FILIAL = D1_FILIAL AND F1_FILIAL = '" + xfilial('SF1') + "'"

	_cQuery += chr(13) + " AND SD1.D_E_L_E_T_ <> '*'"
	//_cQuery += chr(13) + " AND D1_TES = '" + mv_par04 + "'"
    //_cQuery += chr(13) + " AND D1_TES IN('190','074','192','328','340','341','342','347')" //* solicitado por cristiane para filtrar por grupo 1000
	_cQuery += chr(13) + " AND D1_GRUPO IN('1000')"
	//_cQuery += chr(13) + " AND D1_EMISSAO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += chr(13) + " AND D1_DTDIGIT BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += chr(13) + " AND D1_FILIAL = '" + xFilial('SD1') + "'"

	_cQuery += chr(13) + " ORDER BY A2_NOME, F1_DOC, F1_SERIE"

	//memowrite('c:\agregar\sql1.sql',_cquery)
	DbUseArea(.t.,'TOPCONN',TcGenQry(,,_cQuery),'ENT',.f.,.f.)
	count to _nLast1
	DbGoTop()

	MsProcTxt('Buscando informacoes referente entradas / saidas')

	_cQuery := " SELECT * FROM ("
	_cQuery += " SELECT '1' TIPO, B1_COD, B1_DESC, B1_CODSEC,"
	_cQuery += chr(13) + " F1_DOC DOC, F1_DTDIGIT EMISSAO, F1_VALBRUT VALBRUT, F1_VALICM VALICM, F1_ICMSRET ICMSRET,"
	_cQuery += chr(13) + " D1_QTSEGUM QTSEGUM, D1_QUANT QUANT, D1_VUNIT PRECO, D1_ITEM ITEM, D1_CF CF, D1_PICM PICM,"
	_cQuery += chr(13) + " A1_CGC,A1_INSCR, A1_NOME, A1_EST, A1_MUN, A1_TIPO"

	_cQuery += chr(13) + " FROM SF4010 SF4, SB1010 SB1, SZ3010 SZ3, SA1010 SA1, SF1010 SF1, SD1010 SD1"

	_cQuery += chr(13) + " WHERE SF4.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND F4_AGREGRS = 'S'"
	_cQuery += chr(13) + " AND F4_CODIGO = D1_TES"
	_cQuery += chr(13) + " AND F4_FILIAL = D1_FILIAL AND F4_FILIAL = '" + xfilial('SF4') + "'"

	_cQuery += chr(13) + " AND SB1.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND B1_ESPSIF = Z3_ESPSIF"
	_cQuery += chr(13) + " AND B1_COD = D1_COD AND B1_FILIAL = '" + xfilial('SB1') + "'"

	_cQuery += chr(13) + " AND SZ3.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND Z3_COMEST = 'S' AND Z3_FILIAL = '" + xfilial('SZ3') + "'"

	_cQuery += chr(13) + " AND SA1.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND A1_COD = F1_FORNECE"
	_cQuery += chr(13) + " AND A1_LOJA = F1_LOJA AND A1_FILIAL = '" + xfilial('SA1') + "'"

	_cQuery += chr(13) + " AND SF1.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND F1_LOJA = D1_LOJA"
	_cQuery += chr(13) + " AND F1_FORNECE = D1_FORNECE"
	_cQuery += chr(13) + " AND F1_SERIE = D1_SERIE"
	_cQuery += chr(13) + " AND F1_DOC = D1_DOC"
	_cQuery += chr(13) + " AND F1_FILIAL = D1_FILIAL AND F1_FILIAL = '" + xfilial('SF1') + "'"

	_cQuery += chr(13) + " AND SD1.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND D1_DTDIGIT BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	//_cQuery += chr(13) + " AND D1_TES <> '" + mv_par04 + "'"
	//_cQuery += chr(13) + " AND (D1_TES <> '" + mv_par04 + "' AND D1_TES <> '" + mv_par05 + "')"
	_cQuery += chr(13) + " AND D1_TES NOT IN('190','074','192','328','340','341','342','347')"

	_cQuery += chr(13) + " AND D1_FILIAL = '" + xFilial('SD1') + "'"

	_cQuery += chr(13) + " UNION"

	_cQuery += chr(13) + " SELECT '2' TIPO, B1_COD, B1_DESC, B1_CODSEC,"
	_cQuery += chr(13) + " F2_DOC DOC, F2_EMISSAO EMISSAO, F2_VALBRUT VALBRUT, F2_VALICM VALICM, F2_ICMSRET ICMSRET,"
	_cQuery += chr(13) + " D2_QTSEGUM QTSEGUM, D2_QUANT QUANT, D2_PRCVEN PRECO, D2_ITEM ITEM, D2_CF CF, D2_PICM PICM,"
	_cQuery += chr(13) + " A1_CGC,A1_INSCR, A1_NOME, A1_EST, A1_MUN, A1_TIPO"

	_cQuery += chr(13) + " FROM SF4010 SF4, SB1010 SB1, SZ3010 SZ3, SA1010 SA1, SF2010 SF2, SD2010 SD2"

	_cQuery += chr(13) + " WHERE SF4.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND F4_AGREGRS = 'S'"
	_cQuery += chr(13) + " AND F4_CODIGO = D2_TES"
	_cQuery += chr(13) + " AND F4_FILIAL = D2_FILIAL AND F4_FILIAL = '" + xfilial('SF4') + "'"

	_cQuery += chr(13) + " AND SB1.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND B1_ESPSIF = Z3_ESPSIF"
	_cQuery += chr(13) + " AND B1_COD = D2_COD AND B1_FILIAL = '" + xfilial('SB1') + "'"

	_cQuery += chr(13) + " AND SZ3.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND Z3_COMEST = 'S' AND Z3_FILIAL = '" + xfilial('SZ3') + "'"

	_cQuery += chr(13) + " AND SA1.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND A1_COD = F2_CLIENTE"
	_cQuery += chr(13) + " AND A1_LOJA = F2_LOJA AND A1_FILIAL = '" + xfilial('SA1') + "'"

	_cQuery += chr(13) + " AND SF2.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND F2_LOJA = D2_LOJA"
	_cQuery += chr(13) + " AND F2_CLIENTE = D2_CLIENTE"
	_cQuery += chr(13) + " AND F2_SERIE = D2_SERIE"
	_cQuery += chr(13) + " AND F2_DOC = D2_DOC"
	_cQuery += chr(13) + " AND F2_FILIAL = D2_FILIAL AND F2_FILIAL = '" + xfilial('SF2') + "'"

	_cQuery += chr(13) + " AND SD2.D_E_L_E_T_ <> '*'"
	_cQuery += chr(13) + " AND D2_EMISSAO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += chr(13) + " AND D2_FILIAL = '" + xFilial('SD1') + "') A"
	//_cQuery += chr(13) + " WHERE B1_CODSEC <> ''"

	_cQuery += chr(13) + " ORDER BY TIPO, A1_NOME, DOC"

	//memowrite('c:\agregar\sql2.sql',_cquery)
	DbUseArea(.t.,'TOPCONN',TcGenQry(,,_cQuery),'SAI',.f.,.f.)
	count to _nLast2
	DbGoTop()

	Processa({|| _GeraArq ()}, "Processando...")

	DbSelectArea('SC7')

Return()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da funcao _GeraArq()                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _GeraArq()
	Local _nI  := 0
	
	_aEstru  := {{'CAMPO','C',200,0}}                                 // estrutura padrao para os arquivos temporarios

	//_aLen    := {106, 78, 128, 68, 49, 88, 115}
	_aLen    := {106, 85, 128, 68, 52, 88, 115}                       // tamanho das linhas para cada arquivo txt
	_aAlias  := {'EMPR','NFE1','NFE2','PROD','COND','NFS1','NFS2' }   // alias que serao criados: empresas, cab NFE, det NFE, produtos, condenas, cab NFS, det NFS
	_aEnt    := {'EMPR','NFE1','NFE2','PROD','COND' }                 // arquivos atualizados para NFs de entrada
	//_aChaveE := { 28, 28, 95, 14, 30 }                               // tamanho da chave de pesquisa para cada alias de entrada
	_aChaveE := { 28, 28, 95, 14, 33 }
	_aSai    := {'EMPR','NFS1','NFS2','PROD' }                        // arquivos atualizados para NFs de saida
	_aChaveS := { 28, 28, 42, 14 }                                    // tamanho da chave de pesquisa para cada alias de saida
	_aArqs   := {}													 // nomes dos arquivos temporarios

	_aLinEnt := {}
	_cLinha  := 'left(ENT->A2_CGC,14) + left(ENT->A2_INSCR,14) + left(ENT->A2_NOME,40) + left(ENT->A2_MUN+space(30),35) + ENT->A2_EST + ENT->A2_TPFOR'
	aAdd(_aLinEnt , _cLinha )       // EMPRESAS - FORNECEDORES
	_cLinha  := 'strzero(val(ENT->F1_DOC),9) + ENT->F1_EMISSAO + left(ENT->A2_CGC,14) + IF(ENT->C7_TPCOM = "Q", "R", ENT->C7_TPCOM) + strzero(Round(ENT->F1_VALBRUT,2),15,2) + '
	_cLinha  += 'strzero(val(ENT->C7_GTA),6) + strzero(val(left(ENT->D1_NFPROD,6)),6) + strzero(val(right(alltrim(ENT->D1_NFPROD),6)),6) + ENT->TEMCONDENA + ENT->TIPOABATE + left(ENT->A2_INSCR,14)'
	aAdd(_aLinEnt , _cLinha )	// NOTAS FISCAIS DE ENTRADA - CABECALHO                                                        
	_cLinha  := 'strzero(val(ENT->F1_DOC),9) + ENT->F1_EMISSAO + left(ENT->A2_CGC,14) + left(ENT->B1_COD,14) + '
	_cLinha  += 'strzero(ENT->D1_QTSEGUM,5) + strzero(ENT->KGVIVO,15,3) + strzero(ENT->KGREND,15,3) + '
	_cLinha  += 'strzero(ENT->D1_VUNIT,15,3) + strzero(val(ENT->D1_ITEM),3) + left(ENT->A2_INSCR,14)+ ENT->C7_DTABATE + '
	_cLinha  += 'IF(ENT->C7_TPCOM = "Q", "R", ENT->C7_TPCOM) + alltrim(ENT->D1_CF) + strzero(ENT->D1_PICM,6,2)'
	aAdd(_aLinEnt , _cLinha )	// NOTAS FISCAIS DE ENTRADA - DETALHE
	_cLinha := 'left(ENT->B1_COD,14) + left(ENT->B1_DESC,40) + left(ENT->B1_CODSEC,14)'
	aAdd(_aLinEnt , _cLinha )	// PRODUTOS DO FRIGORIFICO
	_cLinha := 'strzero(val(ENT->F1_DOC),9) + ENT->F1_EMISSAO + left(ENT->A2_CGC,14) + ENT->Z1_CODCOND + strzero(ENT->Z1_QUANT,5) + left(ENT->A2_INSCR,14)' //+C7_DTABATE+C7_TPCOM'
	aAdd(_aLinEnt , _cLinha )	// CONDENAS

	_aLinSai := {}
	_cLinha  := 'left(SAI->A1_CGC,14) + left(SAI->A1_INSCR,14) + left(SAI->A1_NOME,40) + left(SAI->A1_MUN+space(30),35) + SAI->A1_EST + "V"'
	aAdd(_aLinSai , _cLinha )	// EMPRESAS - CLIENTES
	_cLinha  := 'strzero(val(SAI->DOC),9) + SAI->EMISSAO + left(SAI->A1_CGC,14) + strzero(Round(SAI->VALBRUT,2),15,2) + '
	_cLinha  += 'strzero(Round(SAI->VALICM,2),15,2) + strzero(Round(SAI->ICMSRET,2),15,2) + iif(substr(SAI->CF,1,1) $ "1/2" ,"E","S") + left(SAI->A1_INSCR,14)'
	aAdd(_aLinSai , _cLinha )	// NOTAS FISCAIS DE SAIDA - CABECALHO
	_cLinha  := 'strzero(val(SAI->DOC),9) + SAI->EMISSAO + left(SAI->A1_CGC,14) + left(SAI->B1_COD,14) + '
	_cLinha  += 'strzero(SAI->QTSEGUM,15,3) + strzero(SAI->QUANT,15,3) + strzero(SAI->PRECO,15,2) + iif(substr(SAI->CF,1,1) $ "1/2" ,"E","S") + '
	_cLinha  += 'strzero(val(SAI->ITEM),3) + left(SAI->A1_INSCR,14) + alltrim(SAI->CF) + strzero(SAI->PICM,6,2)'
	aAdd(_aLinSai , _cLinha )	// NOTAS FISCAIS DE SAIDA - DETALHE
	_cLinha := 'left(SAI->B1_COD,14) + left(SAI->B1_DESC,40) + left(SAI->B1_CODSEC,14)'
	aAdd(_aLinSai , _cLinha )	// PRODUTOS

	For _nI := 1 to len(_aAlias)
		_nI2 := _nI
		aAdd(_aArqs, CriaTrab(_aEstru,.T.))
		DbUseArea(.t.,,_aArqs[_nI2],_aAlias[_nI2],.t.,.f.)
		IndRegua(_aAlias[_nI2], _aArqs[_nI2],"left(CAMPO,_aLen[_nI2])",,,"Indexando Arquivo...")
	Next

	MsAguarde({|| _RunProc()}, "Processando...")

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da funcao _RunProc()                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _RunProc
	Local _nI  := 0
	Local _nJ
	
	_ncont   := 0                                                     
	_nTotReg := ((_nLast1 + _nLast2) + 2 * (len(_aEnt) + len(_aSai))) * 4

	For _nJ := 1 to 2		// 1 = entradas   2 = saidas
		DbSelectArea(iif(_nJ == 1, 'ENT', 'SAI') )
		DbGoTop()

		Do While !eof()
			For _nI := 1 to len(iif(_nJ == 1, _aEnt, _aSai))
				DbSelectArea(iif(_nJ == 1, _aEnt[_nI], _aSai[_nI]))
				_cLinha := iif(_nJ == 1, _aLinEnt[_nI], _aLinSai[_nI])
				_cLinha := &_cLinha

				MsProcTxt(str(++_ncont) + ' / ' + alltrim(str(_nTotReg)))

				If !DbSeek(left(_cLinha,iif(_nJ == 1, _aChaveE[_nI], _aChaveS[_nI])))	
					RecLock(iif(_nJ == 1, _aEnt[_nI], _aSai[_nI]),.t.)
					(iif(_nJ == 1, _aEnt[_nI], _aSai[_nI]))->CAMPO := _cLinha
					MsUnLock()
				Else
					If _nJ == 1 .and. _nI == 2  // cabecalho das notas fiscais de entrada
						_cTpCom   := substr(NFE1->CAMPO,29,1)           // define de é vivo, rendimento ou ambos
						_cTpCom   := iif(_cTpCom <> substr(_cLinha,29,1),'A',_cTpCom)
						_cGTA     := strzero(iif(min(val(substr(NFE1->CAMPO,45,6)),val(substr(_cLinha,45,6)))==0,max(val(substr(NFE1->CAMPO,45,6)),val(substr(_cLinha,45,6))),min(val(substr(NFE1->CAMPO,45,6)),val(substr(_cLinha,45,6)))) ,6)
						_cNFProdI := strzero(iif(min(val(substr(NFE1->CAMPO,51,6)),val(substr(_cLinha,51,6)))==0,max(val(substr(NFE1->CAMPO,51,6)),val(substr(_cLinha,51,6))),min(val(substr(NFE1->CAMPO,51,6)),val(substr(_cLinha,51,6)))) ,6)
						_cNFProdF := strzero(max(val(substr(NFE1->CAMPO,57,6)),val(substr(_cLinha,57,6))),6)
						_cLinha   := left(_cLinha,28) + _cTpCom + substr(_cLinha,30,15) + _cGTA + _cNFProdI + _cNFProdF + substr(_cLinha,63)
						RecLock('NFE1',.f.)
						NFE1->CAMPO := _cLinha
						MsUnLock()
					EndIf
				EndIf
			Next _nI
			DbSelectArea(iif(_nJ == 1, 'ENT', 'SAI') )
			IncProc()
			DbSkip()
		EndDo
	Next _nJ

	MsAguarde({|| _Gravatxt ()}, "Salvando arquivos txt ...")

	ENT->(DbCloseArea())
	SAI->(DbCloseArea())

Return()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamda da funcao _Gravatxt()                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Gravatxt()
	Local _nI  := 0
	
	_lTudoOK := .t.
	For _nI := 1 to len(_aArqTxt)
		MsProcTxt('Gravando arquivo ' + _aArqTxt[_nI])

		DbSelectArea(_aAlias[_nI])
		DbGoTop()
		Do While !eof() .and. _lTudoOk
			fWrite(_aHandle[_nI], left(CAMPO,_aLen[_nI]) + chr (13) + chr (10) )
			If fError() <> 0
				MsgBox('Erro na gravacao do arquivo ' + _aArqs[_nI] + chr(13) + 'O processo sera abortado','ATENCAO!!!','STOP')
				_lTudoOk := .f.
			EndIf
			DbSkip()
		EndDo
		(_aAlias[_nI])->(DbCloseArea())
		fErase(_aArqs[_nI] + '.dbf')
		fErase(_aArqs[_nI] + '.idx')
	Next

	For _nI := 1 to len(_aHandle)
		fClose(_aHandle[_nI])
	Next          

Return()


/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH¿
//³Esta função serve para verificar e gerar condenas por pedido³
//³na tabela SZ1.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHÙ
ENDDOC*/
Static Function GeraCond()

	area := getarea()

	DbSelectArea('SD1')
	SD1->(DbSetOrder(6))
	SD1->(DbGoTop())
	SD1->(DbSeek(xfilial('SD1')+dtos(mv_par01),.t.))
	//While SD1->(!eof()) .and. SD1->D1_FILIAL = xfilial('SD1') .and. SD1->D1_EMISSAO <= mv_par02
	While SD1->(!eof()) .and. SD1->D1_FILIAL = xfilial('SD1') .and. SD1->D1_DTDIGIT <= mv_par02

		//if !(SD1->D1_TES $ '001/190/074/162/192/328') //* solicitado por cristiane para filtrar por grupo 1000
		if !(SD1->D1_GRUPO $ '1000')
			SD1->(DbSkip())
			loop
		endif    

		if empty(SD1->D1_PEDIDO)
			SD1->(DbSkip())
			loop	
		endif      

		_cNumamLote := ''

		DbSelectArea('SC7')
		SC7->(DbSetOrder(1))         
		if SC7->(DbSeek(xfilial('SC7')+SD1->D1_PEDIDO))  
			if _cNumamLote <> SC7->(C7_NUMAM+C7_LOTE)
				DbSelectArea('ZA3')
				ZA3->(DbSetOrder(1))
				if  ZA3->(DbSeek(xfilial('ZA3')+SC7->(C7_NUMAM+C7_LOTE)))  
					While ZA3->(!eof()) .and. ZA3->ZA3_NUMAM = SC7->C7_NUMAM .and. ZA3->ZA3_LOTE = SC7->C7_LOTE
						DbSelectArea('SZ1')
						SZ1->(DbSetOrder(1))
						//if !SZ1->(DbSeek(xfilial('SZ1')+SC7->C7_NUM+ZA3->ZA3_CODCOND))
						if !SZ1->(DbSeek(xfilial('SZ1')+SC7->C7_NUM+AllTrim(ZA3->ZA3_CODCOND)))
							reclock('SZ1',.t.)
							SZ1->Z1_FILIAL  := xfilial('SZ1')
							SZ1->Z1_PEDIDO  := SC7->C7_NUM
							SZ1->Z1_CODCOND := ZA3->ZA3_CODCOND
							SZ1->Z1_QUANT   := ZA3->ZA3_QUANT
							msunlock()               
						else
							reclock('SZ1',.f.)
							SZ1->Z1_FILIAL  := xfilial('SZ1')
							SZ1->Z1_PEDIDO  := SC7->C7_NUM
							SZ1->Z1_CODCOND := ZA3->ZA3_CODCOND
							SZ1->Z1_QUANT   := ZA3->ZA3_QUANT
							msunlock()
						endif
						ZA3->(DbSkip())
					enddo
				endif
				_cNumamLote := SC7->(C7_NUMAM+C7_LOTE)
			endif
		endif

		SD1->(DbSkip())
	enddo

	DbCloseArea('SD1')
	DbCloseArea('SC7')
	DbCloseArea('ZA3')
	DbCloseArea('SZ1')

	restarea(area)    

Return
