#INCLUDE "RWMAKE.CH"                           
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} STI_RG50
Relatório para relação dos lotes de abate ref. ao aviso de matança 
@author 	Evandro Mugnol
@since 		Set/2017.
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_RG50()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cString := "SZ4"
	Local cDesc1  := "Este programa tem como objetivo, imprimir o relatório"
	Local cDesc2  := "relação lotes de abate conforme parâmetros informados."
	Local cDesc3  := ""
	Local Cabec1  := "NUM.                                                        QTDE  PREÇO   PREÇO    VLR   Contr."
	Local Cabec2  := "LOTE FORNECEDOR NOME PRODUTOR                        CATE.  ANIM.  BASE   BONUS  Acresc. Social F.RURAL      COMPRADOR"
	//          XXXX XXXXXX/XX  X---------------------------------X X-------X   XXX    XXX,XX  XXX,XX    XXX  XXXXXX X----------------------------X
	// *****              1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	// *****    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	Local aOrd    := {}

	Private lAbortPrint  := .F.                                              
	Private tamanho      := "M"
	Private nomeprog     := "STI_RG50" 		// Coloque aqui o nome do programa para impressao no cabecalho
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "STI_RG50"
	Private nTipo        := 18
	Private li			 := 80
	Private m_pag        := 01
	Private wnrel        := "STI_RG50" 		// Coloque aqui o nome do arquivo usado para impressao em disco 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas no Arquivo SX1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.T.)

	DbSelectArea("SZG")
	DbSetOrder(1)
	MsSeek(FWxFilial("SZG") + mv_par01)

	cTitulo := "RELAÇÃO DOS LOTES DE ABATE REF. ORDEM DE MATANÇA " + Transform(SZG->ZG_NUMAM,"@R 99.9999/99") + " (" + DTOC(SZG->ZG_DATA)+ ")"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := SetPrint(cString,NomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,cTitulo,li) },cTitulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RunReport ³ Autor ³ Evandro Mugnol       ³ Data ³ Set/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria perguntas no SX1. Se a pergunta ja existir, atualiza. ³±±
±±³          ³ Se houver mais perguntas no SX1 do que as definidas aqui,  ³±±
±±³          ³ deleta as excedentes do SX1.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,cTitulo,li)

	DbSelectArea("SZ4")
	DbSetOrder(3)
	MsSeek(FWxFilial("SZ4") + mv_par01)
	SetRegua(RecCount())
	While !Eof() .And. SZ4->Z4_FILIAL + SZ4->Z4_NUMAM = FWxFilial("SZ4") + mv_par01
		IncRegua()

		_cNumSC   := GetAdvFVal("SZE", "ZE_NUMSC", FWxFilial("SZE") + SZ4->Z4_NUMAM + SZ4->Z4_LOTE, 2)
		_cItemSC  := GetAdvFVal("SZE", "ZE_ITEMSC", FWxFilial("SZE") + SZ4->Z4_NUMAM + SZ4->Z4_LOTE, 2)
		_cProduto := GetAdvFVal("SZE", "ZE_PRODUTO", FWxFilial("SZE") + SZ4->Z4_NUMAM + SZ4->Z4_LOTE, 2)
		_cNumOR   := GetAdvFVal("SZE", "ZE_NUMERO", FWxFilial("SZE") + SZ4->Z4_NUMAM + SZ4->Z4_LOTE, 2)
		_cCodForn := GetAdvFVal("SZD", "ZD_FORNECE", FWxFilial("SZD") + _cNumOR, 1)
		_cLojForn := GetAdvFVal("SZD", "ZD_LOJA", FWxFilial("SZD") + _cNumOR, 1)
		_cNomForn := GetAdvFVal("SA2", "A2_NOME", FWxFilial("SA2") + _cCodForn + _cLojForn, 1)
		_cCodCat  := GetAdvFVal("SZE", "ZE_CATEG", FWxFilial("SZE") + SZ4->Z4_NUMAM + SZ4->Z4_LOTE, 2)
		_cCatego  := Substr(GetAdvFVal("SZ5", "Z5_DESC", FWxFilial("SZ5") + _cCodCat, 1),1,10)
		_cFunRur  := GetAdvFVal("SA2", "A2_POSEMP", FWxFilial("SA2") + _cCodForn + _cLojForn, 1)
		_cTrSoc   := GetAdvFVal("SA2", "A2_TIPORUR", FWxFilial("SA2") + _cCodForn + _cLojForn, 1)
		// Inclusão de campo para visualizar acrescimo
		ZCB->(DbGoTop())
		if !ZCB->(MsSeek(FWxFilial("ZCB") + SZ4->Z4_NUMAM + SZ4->Z4_LOTE))
			_nVlrAcr  := GetAdvFVal("ZCB", "ZCB_VLACR", FWxFilial("ZCB") + SZ4->Z4_NUMAM + SZ4->Z4_LOTE, 3)
		else
			_nVlrAcr := 0
		Endif

		ZAQ->(DbSetOrder(4))
		If ZAQ->(MsSeek(FWxFilial("ZAQ") + _cNumSC))
			DO CASE
				CASE Alltrim(_cProduto) == "000230" .And. ZAQ->ZAQ_NGITSC == _cItemSC		// BOI
				_nPrcBase  := ZAQ->ZAQ_NGPRC
				_nPrcBonus := ZAQ->ZAQ_NGPRCB
				_cCodCompr := ZAQ->ZAQ_CODCOM
				_cNomCompr := ZAQ->ZAQ_NOMECO
				CASE Alltrim(_cProduto) == "000231" .And. ZAQ->ZAQ_VGITSC == _cItemSC		// VACA
				_nPrcBase  := ZAQ->ZAQ_VGPRC
				_nPrcBonus := ZAQ->ZAQ_VGPRCB
				_cCodCompr := ZAQ->ZAQ_CODCOM
				_cNomCompr := ZAQ->ZAQ_NOMECO
				CASE Alltrim(_cProduto) == "001075" .And. ZAQ->ZAQ_TGITSC == _cItemSC		// TOURO
				_nPrcBase  := ZAQ->ZAQ_TGPRC
				_nPrcBonus := ZAQ->ZAQ_TGPRCB
				_cCodCompr := ZAQ->ZAQ_CODCOM
				_cNomCompr := ZAQ->ZAQ_NOMECO
				CASE Alltrim(_cProduto) == "001073" .And. ZAQ->ZAQ_BGITSC == _cItemSC		// BÚFALO
				_nPrcBase  := ZAQ->ZAQ_BGPRC
				_nPrcBonus := ZAQ->ZAQ_BGPRCB
				_cCodCompr := ZAQ->ZAQ_CODCOM
				_cNomCompr := ZAQ->ZAQ_NOMECO
				CASE Alltrim(_cProduto) == "001074" .And. ZAQ->ZAQ_BAITSC == _cItemSC		// BÚFALA
				_nPrcBase  := ZAQ->ZAQ_BAPRC
				_nPrcBonus := ZAQ->ZAQ_BAPRCB
				_cCodCompr := ZAQ->ZAQ_CODCOM
				_cNomCompr := ZAQ->ZAQ_NOMECO
				OTHERWISE
				_nPrcBase  := 0
				_nPrcBonus := 0
				_cCodCompr := "??????"
				_cNomCompr := "??????????????????????????????"
			ENDCASE
		Else
			SZ9->(DbSetOrder(1))
			If SZ9->(MsSeek(FWxFilial("SZ9") + _cNumSC + _cItemSC + _cProduto))
				_nPrcBase  := SZ9->Z9_PRECO
				_nPrcBonus := SZ9->Z9_PRECOBN

				SZA->(DbSetOrder(1))
				If SZA->(MsSeek(FWxFilial("SZA") + _cNumSC))
					_cCodCompr := SZA->ZA_COMPRA
					SA3->(DbSetOrder(1))
					If SA3->(MsSeek(FWxFilial("SA3") + _cCodCompr))
						_cNomCompr := SA3->A3_NOME
					Else
						_cNomCompr := "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"
					Endif
				Else
					_cCodCompr := "XXXXXX"
					_cNomCompr := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
				Endif
			Else
				_nPrcBase  := 0
				_nPrcBonus := 0
				_cCodCompr := "!!!!!!"
				_cNomCompr := "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			Endif
		Endif

		If li > 70
			Cabec(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			li := 10
		Endif

		@ li, 000 PSAY Substr(SZ4->Z4_LOTE,3,4)
		@ li, 003 PSAY _cCodForn + '/' + _cLojForn
		@ li, 016 PSAY Substr(_cNomForn,1,35)
		@ li, 052 PSAY _cCatego
		@ li, 060 PSAY SZ4->Z4_QUANT 	Picture "@E 999"
		@ li, 066 PSAY _nPrcBase  		Picture "@E 999.99"
		@ li, 074 PSAY _nPrcBonus 		Picture "@E 999.99"
		@ li, 081 PSAY _nVlrAcr    		Picture "@E 999.99"
		@ li, 092 PSAY _cTrSoc
		@ li, 097 PSAY iif(_cFunRur = '1','Sim',iif(_cFunRur = '2','Nao',''))
		@ li, 102 PSAY Substr(_cCodCompr,1,6)
		@ li, 109 PSAY Substr(_cNomCompr,1,22)

		li++
		@ li, 000 PSAY Replicate('-',132)
		li++

		DbSelectArea("SZ4")
		DbSkip()
	EndDo

	li++
	@ li, 005 PSAY "RESUMO DO AVISO:"
	li++
	_nlinha := li
	li := SCateg(_nlinha)
	li += 4
	If !Empty(SZG->ZG_AUTOR)
		@ li, 002 PSAY Replicate('-',24)
		li++
		@ li, 006 PSAY SZG->ZG_AUTOR
	Endif

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da função SCateg												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function SCateg(li)

	_TotAnim := 0
	li++

	SZ5->(DbSetOrder(1))
	SZ5->(DbGoTop())
	While SZ5->(!Eof()) .And. FWxFilial("SZ5") = SZ5->Z5_FILIAL
		SZE->(DbSetOrder(2))
		if SZE->(MsSeek(FWxFilial("SZE") + mv_par01))
			_CountCateg := 0
			While SZE->(!eof()) .And. SZE->ZE_FILIAL + SZE->ZE_NUMAM == FWxFilial("SZE") + mv_par01
				If SZ5->Z5_COD = SZE->ZE_CATEG
					_CountCateg += SZE->ZE_QTD1UM
				Endif
				SZE->(dbskip())
			Enddo
		endif

		If _CountCateg <> 0
			@ li, 005 PSAY Substr(SZ5->Z5_DESC,1,8)
			@ li, 015 PSAY " :  " + Transform(_CountCateg, "@E 999")
			_TotAnim += _CountCateg
			li++
		Endif
		SZ5->(DbSkip())
	Enddo

	@ li, 005 PSAY "TOTAL"
	@ li, 015 PSAY " :  " + Transform(_TotAnim, "@E 999")

Return li
