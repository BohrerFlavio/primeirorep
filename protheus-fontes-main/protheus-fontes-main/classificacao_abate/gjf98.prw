#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF98   º Autor ³ Giuliano Forgiarini  º Data ³  13/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de carregamento de caixas rastreadas             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF98()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio    "
	Local cDesc2        := "de expedição de produtos acabados rastreados, de forma"
	Local cDesc3        := "a identificar o destino das caixas. "
	Local titulo       	:= "R9 - EXPEDIÇÃO DE CAIXAS DE PA"
	Local nLin         	:= 80
	Local Cabec1       	:= " Codigo e Descrição do Produto                      Numero           Peso     Quant. Classif.  Data      Data                Numero"
	Local Cabec2       	:= "                                                    Caixas          Liquido   Peças  Carcaça   Saída     Prod.               Carreg."
	Local aOrd 			:= {}
	Local i 			:= 0
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "GJF98" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "GJF98"
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF98" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private TotCaix    	:= 0.00
	Private TotPeso    	:= 0.00
	Private _cGrpMds    := alltrim(GETMV('MV_GRPMDS'))
	Private _cGrpPorc 	:= alltrim(GetMV('MV_GRPPORC'))
	Private _cGrpChar 	:= alltrim(GetMV('MV_GRPCHRQ'))
	Private _cMPChar 	:= "'001108','009168','009170'"	// MP Charque

	pergunte(cPerg,.f.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	if !empty(mv_par04) .or. (mv_par11 = 1 .or. mv_par11 = 5 .or. mv_par11 = 2)
		Cabec1       	:= " Codigo e Descrição do Produto                       Cod.            Peso     Quant.  Data      Data      Data      Numero   Numero"
		Cabec2       	:= "                                                    Caixas          Liquido   Peças   Saída     Prod.     Abate     Carreg.  Pedido"
	endif

	_cGrupo := ""
	if mv_par11 = 2
		aGrupos := StrTokArr(_cGrpMds, '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	elseif mv_par11 = 3
		aGrupos := StrTokArr(_cGrpPorc, '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	elseif mv_par11 = 4
		aGrupos := StrTokArr(_cGrpChar, '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	else
		aGrupos := StrTokArr((_cGrpMds + "/" + _cGrpPorc + "/" + _cGrpChar), '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	endif

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP(_cGrupo) })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ8')

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

	Local _cRastro := ''  
	Local _cDescri := ''  
	Local _cCod    := ''

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbSelectArea('SB1')

	TEMP->(dbGoTop())

	TEMP->(SetRegua(RecCount()))

	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	if !empty(mv_par04)
		_cDataAbt := DTOC(mv_par04)
		_cNumam := GetAdvFVal('SZG','ZG_NUMAM',FWxfilial('SZG')+dtos(mv_par04),2,"--------",.T.)

		@nlin,05 psay 'Aviso de Matança n.:    ' + _cNumam
		nlin++
		@nlin,05 psay 'Data do Abate:          ' + _cDataAbt
		nlin++

		_cRastro := GetMv("MV_NUMIF") + strtran(_cDataAbt,'/','') +'0000'

		@nlin,05 psay 'Codigo Rastreabilidade: ' +    _cRastro

		nlin += 2
	endif

	nTotCxFin  := 0
	nTotPesFin := 0
	nTotPecFin := 0

	While TEMP->(!EOF())
		TotCaix := 0.00
		TotPeso := 0.00
		TotPec  := 0
		_cCod := TEMP->COD
		_cDescri := GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1')+TEMP->COD,1)

		@nlin,00 psay replicate('-',132)
		nlin++
		@nlin,001 psay TEMP->COD
		@nlin,011 psay _cDescri
		nlin++
		While TEMP->(!eof()) .and. _cCod = TEMP->COD

			incregua()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o cancelamento pelo usuario...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif

			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			@nlin,050 psay TEMP->CONTROL
			@nlin,060 psay transform(TEMP->PESO,'@E 999,999,999.99')
			@nlin,071 psay transform(TEMP->QUANT,'@E 999,999,999')
			@nlin,086 psay stod(TEMP->DATAS)
			@nlin,096 psay stod(TEMP->DATAP)
			if !empty(mv_par04) .or. (mv_par11 = 1 .or. mv_par11 = 5 .or. mv_par11 = 2)
				@nlin,106 psay stod(TEMP->DTABT)
			endif
			@nlin,117 psay TEMP->PRECAR
			@nlin,126 psay TEMP->PREPED

			nlin++
			TotCaix++ 
			TotPeso += TEMP->PESO
			TotPec  += TEMP->QUANT

			nTotCxFin++
			nTotPesFin += TEMP->PESO
			nTotPecFin += TEMP->QUANT

			TEMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo.
		EndDo 
		@nlin,030 psay 'Totais:'	
		@nlin,050 psay transform(TotCaix,'@E 999,999')	
		@nlin,060 psay transform(TotPeso,'@E 999,999,999.99')	
		@nlin,074 psay transform(TotPec,'@E 999,999')  
		nlin++
	enddo

	@nlin,00 psay replicate('=',132)
	nlin++
	@nlin,030 psay 'TOTAL:'
	@nlin,045 psay transform(nTotCxFin,'@E 999,999,999')
	@nlin,060 psay transform(nTotPesFin,'@E 999,999,999,999.99')
	@nlin,080 psay transform(nTotPecFin,'@E 999,999,999')
	nlin++
	@nlin,00 psay replicate('=',132)

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

//Gera arquivo temporário
Static Function GeraTMP(_cGrupo)

	IF (mv_par15 = 1)
		cQuery := "SELECT Z8_CONTROL AS CONTROL, Z8_COD AS COD, Z8_PESO AS PESO, Z8_QUANT AS QUANT, Z8_DATAP AS DATAP,"
	ELSEIF (mv_par15 = 2)
		cQuery := "SELECT Z8_CONTROL AS CONTROL, Z8_COD AS COD, Z8_PESO AS PESO, B1_QTBCAIX AS QUANT, Z8_DATAP AS DATAP,"
	ENDIF

	cQuery += " Z8_DATAS AS DATAS, Z8_CLASSIF AS CLASSIF, Z8_PRECAR AS PRECAR, Z8_PREPED AS PREPED" + iif(!empty(mv_par04) .or. (mv_par11 = 1 .or. mv_par11 = 5 .or. mv_par11 = 2), ", Z2_DATAABT AS DTABT", "")
	cQuery += " FROM " + RetSqlTab("SZ8")
	cQuery += " INNER JOIN " + retSqlTab('SB1') + " ON (SZ8.Z8_COD = SB1.B1_COD)"
    cQuery += " INNER JOIN " + retSqlTab('SBM') + " ON (SB1.B1_GRUPO = SBM.BM_GRUPO)"
	if !empty(mv_par04) .or. (mv_par11 = 1 .or. mv_par11 = 5 .or. mv_par11 = 2)
		cQuery += " INNER JOIN " + retSqlTab('SZ2') + " ON (Z8_PREDES = Z2_NUM)"
	endif
    cQuery += " WHERE " + retSqlFil('SZ8') + " AND Z8_FIL = '" + cFilAnt + "'" + " AND " + retSqlFil('SB1') + " AND " + retSqlFil('SBM')
	if !empty(mv_par04)
		cQuery += " AND " + RetSqlFil("SZ2")
		cQuery += " AND (Z2_DATAABT BETWEEN '" + dtos(mv_par04) + "' AND '" + dtos(mv_par04) + "')"
	elseif (mv_par11 = 1 .or. mv_par11 = 5 .or. mv_par11 = 2)
		cQuery += " AND " + RetSqlFil("SZ2")
	endif
	cQuery += " AND Z8_DATAE = '' AND Z8_DATAS <> '' AND Z8_ITEM <> 'EST'"
	cQuery += " AND Z8_HORAS <> '' AND Z8_PREPED <> '' AND Z8_PRECAR <> ''"

	if !empty(mv_par01) .and. !empty(mv_par02)
		cQuery += " AND (Z8_COD BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "')"
	endif

	if !empty(mv_par06) .and. !empty(mv_par07)
		cQuery += " AND (Z8_PRECAR BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "')"
	endif

	cQuery += " AND (Z8_DATAP BETWEEN '" + DTOS(mv_par08) + "' AND '" + DTOS(mv_par09) + "')"

	// Busca somente produtos da forma de armazenamento selecionada
	if mv_par10 = 2
        cQuery += " AND BM_FARM = 'C'"
    elseif mv_par10 = 3
        cQuery += " AND BM_FARM = 'R'"
    elseif mv_par10 = 4
        cQuery += " AND BM_FARM = 'S'"
    endif

	// Busca somente produtos dos grupos do local de produção selecionado
	if mv_par11 = 4
		cQuery += " AND (B1_GRUPO IN (" + _cGrupo + ") OR B1_COD IN (" + _cMPChar + "))"
	elseif mv_par11 = 2 .or. mv_par11 = 3
		cQuery += " AND B1_GRUPO IN (" + _cGrupo + ")"
	elseif mv_par11 = 1
		cQuery += " AND B1_GRUPO NOT IN (" + _cGrupo + ")"
	endif

	cQuery += " AND (Z8_DATAS BETWEEN '" + DTOS(mv_par12) + "' AND '" + DTOS(mv_par13) + "')"
	cQuery += " AND " + retSqlDel('SZ8') + " AND " + retSqlDel('SB1') + " AND " + retSqlDel('SBM') + iif(!empty(mv_par04) .or. (mv_par11 = 1 .or. mv_par11 = 5 .or. mv_par11 = 2), " AND " + RetSQLDel('SZ2'), "")

	if !empty(mv_par03)
		cQuery += " AND Z8_LOCAL  = '" + mv_par03 + "'"
	endif

	if mv_par14 = 1
		cQuery += " ORDER BY Z8_PRECAR, Z8_PREPED, Z8_COD"
	else
		cQuery += " ORDER BY Z8_COD, Z8_DATAP, Z8_DATAS"
	endif

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TEMP") != 0
		TEMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TEMP"

return
