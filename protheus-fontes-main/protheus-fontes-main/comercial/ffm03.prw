#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FFM03     ºFabian Maurer   º Data ³  16/11/2011             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de descontos por pre-carregamento mod2           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FFM03()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio       "
	Local cDesc2         := "de descontos praticados em pré-carregamentos conforme os "
	Local cDesc3         := "parametros definidos pelo usuário.                       "
	Local titulo       	:= "RELATORIO DE DESCONTOS PRATICADOS POR CARGA - PRÉ"
	Local nLin         	:= 80
	Local Cabec1       	:= " Carreg.        Placa              Data                Observações                    Usuario     "
	Local Cabec2       	:= " Codigo               Descrição               Quant. Prev(Kg)       Preco                     Bonificação   P. Final   P.Sem Rapel"
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private Tamanho      := "M"
	Private nomeprog     := "FFM03" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "FFM03"
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "FFM03" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aDados 	:= {}
	Private _aCabec		:= {}

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem
	cQuery := " SELECT ZZ3_NUM AS PRECAR,ZZ4_NUM AS PREPED, ZZ5_ITEM AS ITEM, ZZ5_COD AS COD,ZZ5_DESC AS DESCRI, ZZ4_CODCLI AS CODCLI,ZZ4_LOJA AS LOJA,"
	cquery +=  "ZZ5_PRECO AS PRECO,ZZ5_TPBONI AS TPBONI, ZZ5_BONIF AS BONIF, ZZ4_NUMPED AS NUMPED, ZZ5_QPPESO AS QPPESO "
	cQuery += " FROM "  + RetSqlName("ZZ3") + " ZZ3," + RetSqlName("ZZ4") + " ZZ4," + RetSqlName("ZZ5") + " ZZ5 "
	cQuery += " WHERE " + RetSQLFil('ZZ3')  + " AND " + RetSQLFil('ZZ4')  + " AND " + RetSQLFil('ZZ5') 
	cQuery += " AND (ZZ3.ZZ3_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "')"
	cQuery += " AND ZZ3.ZZ3_NUM = ZZ4.ZZ4_PRECAR AND ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM "      
	cQuery += " AND ZZ5_TPBONI <> ''"  
	cQuery += " AND " +  RetSQLDel('ZZ3') + " AND " + RetSQLDel('ZZ4') + " AND  " + RetSQLDel('ZZ5')

	Do Case
		case MV_PAR03 = 1
		cQuery +=" AND ZZ4_ORIGEM = 'P'" 
		case MV_PAR03 = 2
		cQuery +=" AND 	ZZ4_ORIGEM = 'D'"
		case MV_PAR03 = 3
		cQuery +=" AND 	ZZ4_ORIGEM = 'E'"
		otherwise
	endcase 
	cQuery += " ORDER BY ZZ3_NUM, ZZ4_NUM,ZZ4_CODCLI,ZZ5_COD"
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

	//Local nOrdem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DES->(SetRegua(RecCount()))

	DES->(dbGoTop())

	_cPreCar := ' '
	_cNumPed := ' '
	_cCodC   := ' '
	_cNumNF  := ' '
	_nDesc   := 0.00
	_nRapel  := 0.00
	_VALOR   := 0.00
	_A1PRAPEL := 00.00
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	While DES->(!EOF())

		incregua()

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		if _cPreCar != DES->PRECAR
			If nLin > 79
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			@nlin,00 PSAY replicate('-',132)
			nlin++

			@nLin,01 PSAY DES->PRECAR
			ZZ3->(dbsetorder(2))
			ZZ3->(MsSeek(FWxfilial('ZZ3')+alltrim(DES->PRECAR)))
			@nlin,15 PSAY ZZ3->ZZ3_PLACA
			@nlin,33 PSAY ZZ3->ZZ3_DTCAR
			@nlin,50 PSAY substr(ZZ3->ZZ3_OBS,0,25) 
			@nlin,85 PSAY ZZ3->ZZ3_USUAR 
			nLin++
			@nlin,00 PSAY replicate('-',132)
			nlin++

			if mv_par04 = 2
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

			// DELETA TODAS INFORMAÇÕES DO PRE-CARREGAMENTO
			_cQuery := "DELETE FROM " + RetSqlName("ZZ0")
			_cQuery += " WHERE ZZ0_PRECAR = '" + DES->PRECAR + "'"
			_cQuery += "   AND ZZ0_FILIAL = '" + FWxFilial("ZZ0") + "'"

			TCSQLEXEC(_cQuery)
		endif

		if _cCodC != DES->(CODCLI + LOJA)
			nlin++
			If nLin > 79
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			_cCodCli  := alltrim(DES->CODCLI)
			_cLoja    := alltrim(DES->LOJA)
			_cNomeCli := GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1')+_cCodCli+_cLoja,1)
			_cNomeCid := GetAdvFVal('SA1','A1_MUN',FWxfilial('SA1')+_cCodCli+_cLoja,1)
			_NumVend  := GetAdvFVal('SA1','A1_VEND',FWxfilial('SA1')+_cCodCli+_cLoja,1)
			_cNomeRep := GetAdvFVal('SA3','A3_NOME',FWxfilial('SA3')+_NumVend,1)

			@nlin,01 psay _cCodCli + "/" + _cLoja
			@nlin,20 psay _cNomeCli
			@nlin,61 psay substr((_cNomeCid),1,20)
			@nlin,85 psay _NumVend
			@nlin,93 psay _cNomeRep
			nlin++

			if mv_par04 = 2
				aadd(_aDados, {"","","","","","","",""})
				aadd(_aDados, { _cCodCli + "/" + _cLoja,;
								_cNomeCli,;
								substr((_cNomeCid),1,20),;
								_NumVend,;
								_cNomeRep,;
								"",;
								"",;
								""})
				aadd(_aDados, {"","","","","","","",""})
			endif

			_cCodC := DES->(CODCLI + LOJA)
		endif
		If nLin > 79
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		@nlin,01 psay substr(alltrim(DES->COD),1,6)
		_cDescRed := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1') + alltrim(DES->COD),1)
		@nlin,17 psay substr(alltrim(_cDescRed),1,30)
		@nlin,48 psay transform(DES->QPPESO,'@E 999,999.99')
		@nlin,68 psay transform(DES->PRECO,'@E 999.99')

		_nDesc := DES->BONIF
		_A1PRAPEL := GetAdvFVal('SA1','A1_PRAPEL',FWxfilial('SA1') + DES->(CODCLI + LOJA),1)
		_nPRapel:= _A1PRAPEL / 100
		if DES->TPBONI = 'D'
			@nlin,85 psay 'Desconto'
			_nDesc := _nDesc * (-1)
		else 
			@nlin,85 psay 'Acrescimo'
		endif
		_nPrcFinal := DES->(PRECO + _nDesc)
		_nValRapel := _nPrcFinal *_nPRapel
		_nValSemRapel := _nPrcFinal - _nValRapel

		@nLin,01 pSay Chr(27) + Chr(69) // Ativa negrito
		@nlin,98 psay transform(DES->BONIF,'@E 99.99')
		@nlin,112 psay transform(_nPrcFinal,'@E 999.99')
		@nlin,125 psay transform(_nValSemRapel,'@E 999.99')
		nLin++ // Avanca a linha de impressao
		@nLin,01 pSay Chr(27) + Chr(70) // Desativa negrito

		if mv_par04 = 2
			aadd(_aDados, { alltrim(DES->COD),;
							substr(alltrim(_cDescRed),1,30),;
							transform(DES->QPPESO,'@E 999.99'),;
							transform(DES->PRECO,'@E 999.99'),;
							iif(DES->TPBONI = 'D', 'Desconto', 'Acrescimo'),;
							transform(DES->BONIF,'@E 99.99'),;
							transform(_nPrcFinal,'@E 999.99'),;
							transform(_nValSemRapel,'@E 999.99')})
		endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua gravação das informações necessárias na tabela ZZ0 para ser  ³
		//³ utilizado posteriormente no relatório GJF64 e apontar as diferenças ³
		//³                                                                     ³
		//³ Caso já exista a informação antes a mesma deve ser excluída, pois o ³
		//³ relatório pode ser gerado várias vezes com a mesma parametrização.  ³
		//³                                                                     ³
		//³ Chamada da exclusão está no teste de quebra do pré-carregamento.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		// Efetua gravação dos registros do relatório para posterior comparação
		DbSelectArea("ZZ0")
		RecLock("ZZ0",.T.)
		ZZ0->ZZ0_FILIAL := FWxFilial("ZZ0")
		ZZ0->ZZ0_PRECAR := DES->PRECAR
		ZZ0->ZZ0_PREPED := DES->PREPED
		ZZ0->ZZ0_CODCLI := DES->CODCLI
		ZZ0->ZZ0_LOJA   := DES->LOJA
		ZZ0->ZZ0_ITEM   := DES->ITEM
		ZZ0->ZZ0_COD    := DES->COD
		ZZ0->ZZ0_PRECO  := DES->PRECO
		ZZ0->ZZ0_TPBONI := DES->TPBONI
		ZZ0->ZZ0_VLBONI := DES->BONIF
		ZZ0->ZZ0_PRCFIN := DES->(PRECO + _nDesc)
		MsUnlock()

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

