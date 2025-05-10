#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF64     ºGiuliano José Forgiarini   º Data ³  30/10/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de descontos por pre-carregamento                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF64()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio       "
	Local cDesc2        := "de descontos praticados em pré-carregamentos conforme os "
	Local cDesc3        := "parametros definidos pelo usuário.                       "
	Local titulo       	:= "RELATORIO DE DESCONTOS PRATICADOS POR CARGA - PÓS"
	Local nLin         	:= 80
	Local Cabec1       	:= " Carreg.   Placa     Data          Observações                       Usuario  "
	Local Cabec2       	:= " Codigo  Descrição               Quant(Kg)   Preco       Bonificação   P. Final       P.Sem Rapel "
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private Tamanho     := "M"
	Private nomeprog    := "GJF64" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "GJF64"
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF64" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private v3 			:= 0
	Private _nValSemRapel := 0
	Private _aDados 	:= {}
	Private _aCabec		:= {}

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem
	cQuery := " SELECT ZZ3_NUM AS PRECAR,ZZ4_NUM AS PREPED, ZZ5_ITEM AS ITEM, ZZ5_COD AS COD,ZZ5_DESC AS DESCRI, ZZ4_CODCLI AS CODCLI,ZZ4_LOJA AS LOJA,"
	cquery += "ZZ5_PRECO AS PRECO,ZZ5_TPBONI AS TPBONI, ZZ5_BONIF AS BONIF, ZZ4_NUMPED AS NUMPED, ZZ5_QRPESO AS QRPESO"
	cQuery += " FROM " + RetSqlName("ZZ3") + " ZZ3," + RetSqlName("ZZ4") + " ZZ4," + RetSqlName("ZZ5") + " ZZ5 "
	cQuery += " WHERE ZZ3.D_E_L_E_T_ <> '*' AND ZZ4.D_E_L_E_T_ <> '*' AND ZZ5.D_E_L_E_T_ <> '*' "
	cQuery += " AND (ZZ3.ZZ3_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "')"
	cQuery += " AND ZZ3.ZZ3_NUM = ZZ4.ZZ4_PRECAR AND ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM "      
	cQuery += " AND ZZ3_FILIAL = '" + FWxFilial("ZZ3") + "' AND ZZ4_FILIAL = '" + FWxFilial("ZZ4") + "' AND ZZ5_FILIAL = '" + FWxFilial("ZZ5") + "'" 
	cQuery += " AND ZZ5_TPBONI <> '' AND ZZ4_NUMPED <> ''"
	cQuery += " ORDER BY ZZ3_NUM, ZZ4_NUMPED"
	cQuery := ChangeQuery(cQuery)

	If Select("DES") != 0
		DES->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "DES"  

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DES->(SetRegua(RecCount()))

	DES->(dbGoTop())

	_cDiv 	 := ""
	_cPreCar := ' '
	_cNumPed := ' '
	_cNumNF  := ' '
	_nRapel  := 0.00
	_VALOR   := 0.00
	_A1PRAPEL := 00.00
	_nDesc   := 0.00 
	_nPrcFinal:= 00.00
	_nValRapel:= 00.00
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	While DES->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		if _cPreCar != DES->PRECAR
			If nLin > 61  // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif  

			@nlin,00 PSAY replicate('_',132)
			nlin++

			@nLin,01 PSAY DES->PRECAR
			ZZ3->(dbsetorder(2))
			ZZ3->(MsSeek(FWxfilial('ZZ3')+alltrim(DES->PRECAR)))
			@nlin,11 PSAY ZZ3->ZZ3_PLACA
			@nlin,22 PSAY ZZ3->ZZ3_DTCAR
			@nlin,35 PSAY substr(ZZ3->ZZ3_OBS,0,25)
			@nlin,63 PSAY ZZ3->ZZ3_USUAR
			nLin++  
			@nlin,00 PSAY replicate('_',80)
			nlin++

			if mv_par03 = 2
				aadd(_aDados, { DES->PRECAR,;
								ZZ3->ZZ3_PLACA,;
								dtoc(ZZ3->ZZ3_DTCAR),;
								substr(ZZ3->ZZ3_OBS,0,25),;
								ZZ3->ZZ3_USUAR,;
								"",;
								"",;
								""})
			endif

			_cPreCar := DES->PRECAR
		endif

		if _cNumPed != alltrim(DES->NUMPED)
			nlin++    
			If nLin > 61  // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif  
			_cCodCli  := alltrim(DES->CODCLI)
			_cLoja    := alltrim(DES->LOJA)
			_cCodCli  := GetAdvFVal('ZZ4','ZZ4_CODCLI',FWxfilial('ZZ4')+alltrim(DES->PREPED),2)
			_cLoja    := GetAdvFVal('ZZ4','ZZ4_LOJA',FWxfilial('ZZ4')+alltrim(DES->PREPED),2)
			_cNomeCli := GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1')+_cCodCli+_cLoja,1)
			_NumNF 	  := GetAdvFVal('SC5','C5_NOTA',FWxfilial('SC5') + DES->NUMPED,1)

			@nlin,05 psay _NumNF
			@nlin,15 psay _cCodCli + "/" + _cLoja
			@nlin,30 psay _cNomeCli   
			nlin++

			if mv_par03 = 2
				aadd(_aDados, {"","","","","","","",""})
				aadd(_aDados, { _NumNF,;
								_cCodCli + "/" + _cLoja,;
								_cNomeCli,;
								"",;
								"",;
								"",;
								"",;
								""})
				aadd(_aDados, {"","","","","","","",""})
			endif

			_cNumPed := alltrim(DES->NUMPED)
		endif
		If nLin > 61  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif  

		@nlin,01 psay substr(DES->COD,1,6)
		@nlin,09 psay substr(DES->DESCRI,1,20) 
		@nlin,30 psay transform(DES->QRPESO,'@E 999,999.99')
		@nlin,45 psay transform(DES->PRECO,'@E 999.99')

		_nDesc := DES->BONIF
		if DES->TPBONI = 'D'
			@nlin,55 psay 'Desconto'  
			_nDesc := _nDesc * (-1)
		else 
			@nlin,55 psay 'Acrescimo'
		endif
		_A1PRAPEL 	  := GetAdvFVal('SA1','A1_PRAPEL',FWxfilial('SA1') + DES->(CODCLI + LOJA),1)
		_nPRapel 	  := _A1PRAPEL / 100
		_nPrcFinal 	  := DES->(PRECO + _nDesc) 
		v3 			  := _nPrcFinal * _nPRapel
		_nValSemRapel := _nPrcFinal - v3

		@nlin,65 psay transform(DES->BONIF,'@E 999.99')
		@nlin,73 psay transform(DES->(PRECO + _nDesc),'@E 999.99')
		@nlin,85 psay transform(_nValSemRapel ,'@E 999.99')

		// Verifica na tabela ZZ0 se existe a informação da mesma forma que foi impressa
		// e caso não encontre ou exista alguma diferença de valores, aponta como divergência
		DbSelectArea("ZZ0")
		DbSetOrder(1)
		MsSeek(FWxFilial("ZZ0") + DES->PRECAR + DES->PREPED + _cCodCli + _cLoja + DES->ITEM + DES->COD)
		If Found()			// Verifica divergência ref. valores
			If ZZ0->ZZ0_PRECO <> DES->PRECO .Or. ZZ0->ZZ0_VLBONI <> DES->BONIF .Or. ZZ0->ZZ0_PRCFIN <> DES->(PRECO + _nDesc)
				@ nlin, 85 psay "DV"
				_cDiv := " DV"
			Endif
		Else				// É divergência por não ter encontrado na origem do pré-carregamento
			@nlin, 85 psay "DI"
			_cDiv := " DI"
		Endif

		if mv_par03 = 2
			aadd(_aDados, { alltrim(DES->COD),;
							substr(DES->DESCRI,1,30),;
							transform(DES->QRPESO,'@E 999.99'),;
							transform(DES->PRECO,'@E 999.99'),;
							iif(DES->TPBONI = 'D', 'Desconto', 'Acrescimo'),;
							transform(DES->BONIF,'@E 99.99'),;
							transform(_nPrcFinal,'@E 999.99'),;
							transform(_nValSemRapel,'@E 999.99') + _cDiv})
		endif

		nLin++ // Avanca a linha de impressao

		DES->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea()

	SET DEVICE TO SCREEN

	If Len(_aDados) > 0		// Gera e mostra no Excel
		AADD( _aCabec, {"CÓDIGO"		, "C", 6, 0} )
		AADD( _aCabec, {"DESCRIÇÃO"		, "C", 30, 0} )
		AADD( _aCabec, {"PESO"			, "N", 9, 2} )
		AADD( _aCabec, {"PREÇO"			, "N", 3, 2} )
		AADD( _aCabec, {"TIPO BONIF."	, "C", 10, 0} )
		AADD( _aCabec, {"BONIFICAÇÃO"	, "N", 3, 2} )
		AADD( _aCabec, {"PREÇO FINAL"	, "N", 3, 2} )
		AADD( _aCabec, {"PREÇO S/ RAPEL", "N", 3, 2} )
		U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
	Endif

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

