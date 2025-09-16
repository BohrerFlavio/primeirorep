#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} STI_PROT
RelatСrio de protocolo de notas fiscais para contabilidade.
@author 	Evandro Mugnol
@since 		Mar/2019
@return 	Nil, FunГЦo nЦo tem retorno
@obs 		N/A
/*/

User Function STI_PROT()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Variaveis obrigatorias dos programas de relatorio            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cString  := "ZDT"
	cDesc1   := "Este programa tem como objetivo, Imprimir o relatСrio de "
	cDesc2   := "protocolo de notas fiscais para contabilidade conforme   "
	cDesc3   := "parБmetros definidos pelo usuАrio."
	tamanho  := "M"
	aReturn  := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1}
	aLinha   := {}
	nLastKey := 0
	cPerg    := "STI_PROT"
	titulo   := "Notas Fiscais para Contabilidade"
	wnrel    := "STI_PROT"
	nTipo    := 0

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Perguntas no Arquivo SX1                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Pergunte(cPerg,.F.)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё VariАveis utilizadas para gerar em Excel                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_cNomArq := "NFS_CONTABILIDADE_DE_" + SUBSTR(dtos(mv_par01),1,4) + "-" + SUBSTR(dtos(mv_par01),5,2) + "-" + SUBSTR(dtos(mv_par01),7,2) + "_ATE_" + SUBSTR(dtos(mv_par02),1,4) + "-" + SUBSTR(dtos(mv_par02),5,2) + "-" + SUBSTR(dtos(mv_par02),7,2)
	_aCabec	 := {}
	_aDados	 := {}

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Envia controle para a funcao SETPRINT                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.)

	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif

	RptStatus({|| RptDetail()})

Return


Static Function RptDetail()

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa regua de impressao                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SetRegua(LastRec())

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa os codigos de caracter Comprimido/Normal da impressora Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTipo  := IIF(aReturn[4]==1,15,18)
	nLin   := 80
	m_pag  := 1
	titulo := "Notas Fiscais para Contabilidade de " + DTOC(MV_PAR01) + " AtИ " + DTOC(MV_PAR02) 

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cria o cabecalho.                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cabec1 := "NOTA FISCAL  SERIE  FORNECEDOR                                         RECEBIDA            RECEBIDA POR          "
	cabec2 := "                                                                         DIA                                     "
	//***       XXXXXXXXX    XXX   XXXXXX-XX X-------------------------------------X  XX/XX/XX  X------------------------------X            
	//***                1         2         3         4         5         6         7         8         9        10        11  
	//***      01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё SeleГЦo de dados                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cQuery1 := "SELECT ZDT_DOC, ZDT_SERIE, ZDT_FORNEC, ZDT_LOJA" 
	cQuery1 += "  FROM " + RetSQLTab("ZDT")
	cQuery1 += " WHERE " + RetSQLFil("ZDT")
	cQuery1 += "   AND ZDT_DTPROT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
	cQuery1 += "   AND ZDT_PROT <> ''"
	cQuery1 += "   AND " + RetSQLDel("ZDT")
	cQuery1 += "  GROUP BY ZDT_DOC, ZDT_SERIE, ZDT_FORNEC, ZDT_LOJA"
	cQuery1 += "  ORDER BY ZDT_DOC, ZDT_SERIE, ZDT_FORNEC, ZDT_LOJA"

	cQuery1 := ChangeQuery(cQuery1)
	
	//memowrite("ZZZ_STI_PROT.TXT",cQuery1)

	If Select("TRB1") != 0
		TRB1 -> (DbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "TRB1"

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё ImpressЦo dos Dados                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("TRB1")
	DbGoTop()
	SetRegua(RecCount())
	Do While ! TRB1 -> (Eof ())
		IncRegua()

		If nLin > 75
			Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
			nLin := 9
		Endif 

		_cDocto := TRB1->ZDT_DOC
		_cSerie := TRB1->ZDT_SERIE
		_cForn  := TRB1->ZDT_FORNEC
		_cLoja  := TRB1->ZDT_LOJA

		@ nLin, 001 PSAY _cDocto 
		@ nLin, 014 PSAY _cSerie                    
		@ nLin, 020 PSAY _cForn + "-" + _cLoja + " " + Left(fBuscaCPO('SA2', 1, xFilial('SA2') + _cForn + _cLoja, 'A2_NOME'),40)
		@ nLin, 071 PSAY Dtoc(fBuscaCPO('ZDT', 3, xFilial('ZDT') + _cDocto + _cSerie + _cForn + _cLoja, 'ZDT_DTPROT')) 
		@ nLin, 081 PSAY Replicate("_", 32)
		nLin++

		If mv_par03 == 1	// Gera e Mostra no Excel
			AADD(_aDados, { _cDocto  																								,;
							_cSerie                                                        									    	,;
							_cForn + "-" + _cLoja + " " + Left(fBuscaCPO('SA2', 1, xFilial('SA2') + _cForn + _cLoja, 'A2_NOME'),40)	,;
							fBuscaCPO('ZDT', 3, xFilial('ZDT') + _cDocto + _cSerie + _cForn + _cLoja, 'ZDT_DTPROT')					,;
							Replicate("_",32)																						})
		Endif

		TRB1->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 

	EndDo

	TRB1 -> (DbCloseArea())

	Set Device To Screen

	If Len(_aDados) > 0
		AADD( _aCabec, {"NFISCAL",		"C", 09, 0} )
		AADD( _aCabec, {"SERIE",		"C", 03, 0} )
		AADD( _aCabec, {"FORNECEDOR",	"C", 60, 0} )
		AADD( _aCabec, {"RECEBIDO_DIA",	"D", 08, 0} )
		AADD( _aCabec, {"RECEBIDA_POR",	"C", 32, 0} )
		U_GERAEXCEL(_cNomArq, _aDados, _aCabec, .T.)
	Endif

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()   // Libera fila de relatorios em spool (Tipo Rede Netware)
Return
