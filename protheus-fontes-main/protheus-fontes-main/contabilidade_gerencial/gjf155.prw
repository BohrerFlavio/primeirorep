#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF155    º Autor ³ Giuliano Forgiarini em 01.10.12         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio para conferencia de receitas                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF155()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia de receitas baseado nos itens dos"
	Local cDesc3         := "livros fiscais."
	Local cPict          := "vai porra"
	Local titulo         := "RELATORIO PARA CONFERENCIA DE RECEITAS"
	Local Cabec1         := "CFOP      Data        NFE   Cod.Produto      Produto                                                    NCM            Total"
	Local Cabec2         := ""
	Local imprime         := .T.
	Local aOrd            := {}  
	Private nLin           := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "GJF155" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg   	:= "GJF155"
	Private cbtxt      	:= Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "GJF155" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _nTOTAL    := 0.00
	Private _lEntrada := .f.
	pergunte(cPerg,.F.)

	wnrel := SetPrint('SFT',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	cQuery := " SELECT FT_EMISSAO, FT_NFISCAL, FT_CFOP, FT_PRODUTO, FT_CSTCOF, FT_CSTPIS, FT_POSIPI, FT_TOTAL, FT_DESCONT , FT_ENTRADA"
	cQuery += " FROM "  + RetSQLTab('SFT')
	cQuery += " WHERE " + RetSQLFil('SFT') "
	if (empty(mv_par06) .and. empty(mv_par07)) .and. (!empty(mv_par01) .and. !empty(mv_par02))  
		cQuery += " AND (FT_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')"
	endif

	if (empty(mv_par01) .and. empty(mv_par02)) .and. (!empty(mv_par06) .and. !empty(mv_par07))
		cQuery += " AND (FT_ENTRADA BETWEEN '" + DTOS(mv_par06) + "' AND '" + DTOS(mv_par07) + "')"
		_lEntrada := .t.
	endif

	cQuery += " AND FT_DTCANC = ''"
	cQuery += " AND FT_CSTCOF = '" + mv_par03 + "'"
	cQuery += " AND FT_CSTPIS = '" + mv_par03 + "'"   
	cQuery += " AND " + RetSQLDel('SFT')

	if mv_par04 = 1
		cQuery += " AND FT_TIPOMOV = 'E'"
	elseif mv_par04 = 2                 
		cQuery += " AND FT_TIPOMOV = 'S'"
	endif


	if mv_par05 = 1
		if _lEntrada 
			cQuery += " ORDER BY FT_CFOP, FT_ENTRADA, FT_NFISCAL "
		else
			cQuery += " ORDER BY FT_CFOP, FT_EMISSAO, FT_NFISCAL "
		endif	
	else
		if _lEntrada
			cQuery += " ORDER BY FT_POSIPI, FT_ENTRADA, FT_NFISCAL "
		else
			cQuery += " ORDER BY FT_POSIPI, FT_EMISSAO, FT_NFISCAL "
		endif
	endif


	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SFT')

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

	Local nOrdem

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_nTotCFOP  := 0.00
	_nTotNCM   := 0.00

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	While TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		DBSelectArea('SB1')
		_cDescPro := fBuscaCPO('SB1',1,xfilial('SB1') + TMP->FT_PRODUTO,'B1_DESC')


		if mv_par05 = 1		
			@nlin,000 psay TMP->FT_CFOP  
			@nlin,006 psay TMP->FT_POSIPI 
		else
			@nlin,000 psay TMP->FT_POSIPI  
			@nlin,010 psay TMP->FT_CFOP 	
		endif
		if _lEntrada
			@nlin,017 psay STOD(TMP->FT_ENTRADA)
		else
			@nlin,017 psay STOD(TMP->FT_EMISSAO)
		endif		
		@nlin,029 psay alltrim(TMP->FT_NFISCAL)
		@nlin,041 psay alltrim(TMP->FT_PRODUTO)
		@nlin,050 psay _cDescPro
		@nlin,115 psay Transform(TMP->FT_TOTAL - TMP->FT_DESCONT,'@E 999,999.99')

		_nTotCFOP += TMP->FT_TOTAL - TMP->FT_DESCONT
		_nTotNCM  += TMP->FT_TOTAL - TMP->FT_DESCONT
		_nTOTAL   += TMP->FT_TOTAL - TMP->FT_DESCONT

		_cCFOP    := TMP->FT_CFOP
		_cPOSIPI  := TMP->FT_POSIPI  

		nlin++

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if mv_par05 = 1
			if TCFOP(nlin)
				nlin++
			endif	
		else
			if TNCM(nlin)    			   
				nlin++
			endif		
		endif

	EndDo

	@nlin,00 psay replicate ('_ _ ',132)
	nlin++

	@nlin,102 psay ('Valor Total:')
	@nlin,115 psay Transform(_nTOTAL,'@E 999,999,999.99')

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


Static Function GeraTMP()   

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP"

return

static function TCFOP(linha)
	local ret := .f.     
	if _cCFOP <> TMP->FT_CFOP    
		@linha,000 psay 'Total CFOP ' + alltrim(_cCFOP) + ': ' + Transform(_nTotCFOP,'@E 999,999,999.99')
		_nTotCFOP := 0   
		ret := .t.
	endif
return ret

static function TNCM(linha)	
	local ret := .f.
	if  _cPOSIPI <> TMP->FT_POSIPI
		@linha,000 psay 'Total NCM ' + alltrim(_cPOSIPI) + ': ' + Transform(_nTotNCM,'@E 999,999,999.99')
		_nTotNCM := 0 
		ret := .t.
	endif              
return  ret
