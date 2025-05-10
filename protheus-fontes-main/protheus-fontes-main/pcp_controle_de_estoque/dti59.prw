#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI59     º Autor ³ Fabian Maurerº Data ³  09/07/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Divergência Embalagem x Camaras                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gerencia Produção						                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI59()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2        := "com a divergência do que foi produzido pela EMB   "
	Local cDesc3        := "e do que foi colocado em estoque e localizado	   "
	Local titulo        := "RELATORIO DE DIVERGENCIA EMBALAGEM X CAMARAS"
	Local nLin          := 80
	Local Cabec1       	:= "Codigo       Descricao          Caixa          Data    Hora   Peso        Local       Localiz.               Pallet"
	Local Cabec2       	:= ""
	Local aOrd 			:= {}
	Local i 			:= 0
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "M"
	Private nomeprog    := "DTI59" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "DTI59"
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI59" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    	:= 0.00
	Private TotPeso    	:= 0.00 
	Private _QUANT     	:= 0
	Private _PESO      	:= 0
	Private _QUANT2    	:= 0
	Private _PESO2     	:= 0
	Private _nQtCai 	:= 0
	Private _cGrpMds    := alltrim(GETMV('MV_GRPMDS'))
	Private _cGrpPorc 	:= alltrim(GetMV('MV_GRPPORC'))
	Private _cGrpChar 	:= alltrim(GetMV('MV_GRPCHRQ'))
	Private _cMPChar 	:= "'001108','009168','009170'"	// MP Charque
	Private aGrupos 	:= {}

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cGrupo := ""
	if mv_par03 = 2
		aGrupos := StrTokArr(_cGrpMds, '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	elseif mv_par03 = 3
		aGrupos := StrTokArr(_cGrpPorc, '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	elseif mv_par03 = 4
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

	GeraPOS()

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	POS->(SetRegua(RecCount()))

	POS->(dbGoTop())

	cGrupo := '' 
	_cFarm := ''

	While POS->(!EOF())

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

		@nlin,001 psay alltrim(POS->COD)
		@nlin,008 psay substr(GetAdvFval('SB1','B1_DESCRED',FWxfilial('SB1')+POS->COD,1),1,20) 
		@nlin,030 psay POS->CAIXA
		@nlin,045 psay POS->DATAP
		@nlin,055 psay POS->HORA
		@nlin,062 psay POS->PESO
		@nlin,070 psay POS->LUGAR  
		@nlin,080 psay POS->LOCALIZ
		@nlin,110 psay POS->PALLET

		nlin++	 

		_nQtCai++

		POS->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo

	@nlin,001 psay replicate('-',132)
	nlin++
	@nlin,001 psay 'Total Caixas: '
	@nlin,016 psay Transform(_nQtcai,'@E 999,999')

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

// Gera query a partir dos parâmetros
Static Function GeraPOS()

	cQuery := "SELECT Z8_CONTROL AS CAIXA, Z8_DATAP AS DATAP, Z8_HORA AS HORA, Z8_PESO AS PESO, Z8_COD AS COD, Z8_DESCRI AS DESCRI, Z8_LOCAL AS LUGAR, Z8_PALLET AS PALLET, Z8_LOCALIZ AS LOCALIZ, Z8_HORAS AS HORAS, Z8_DATAS AS DATAS, Z8_LOTEPOR"
	cQuery += " FROM " + RetSqlTab("SZ8")
	cQuery += " INNER JOIN"  + RetSqlTab("SB1") + " ON (Z8_COD = B1_COD)"
	cQuery += " INNER JOIN"  + RetSqlTab("SBM") + " ON (B1_GRUPO = BM_GRUPO)"
	cQuery += " WHERE " + RetSqlFil("SZ8") + " AND Z8_FIL = '" + cFilAnt + "' AND " + RetSqlFil("SB1") + " AND " + RetSqlFil("SBM")
	cQuery += " AND Z8_DATAP BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	// Busca somente produtos dos grupos do local de produção selecionado
	if mv_par03 = 4
		cQuery += " AND (B1_GRUPO IN (" + _cGrupo + ") OR B1_COD IN (" + _cMPChar + "))"
	elseif mv_par03 = 2 .or. mv_par03 = 3
		cQuery += " AND B1_GRUPO IN (" + _cGrupo + ")"
	elseif mv_par03 = 1
		cQuery += " AND B1_GRUPO NOT IN (" + _cGrupo + ")"
	endif
	// Busca conforme forma de armazenamento escolhida
	if mv_par04 = 2
        cQuery += " AND BM_FARM = 'C'"
    elseif mv_par04 = 3
        cQuery += " AND BM_FARM = 'R'"
    elseif mv_par04 = 4
        cQuery += " AND BM_FARM = 'S'"
    endif
	// Se for selecionado um produto específico
	if !empty(mv_par05)
		cQuery += " AND Z8_COD = '" + mv_par05 + "'"
	endif
	cQuery += iif(mv_par06 = 2, " AND Z8_LOTEPOR = ''", iif(mv_par06 = 3, " AND Z8_LOTEPOR <> ''", ""))
	cQuery += " AND Z8_DATAS = '' AND Z8_LOCAL = '' AND Z8_LOCALIZ = ''"
	cQuery += " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('SBM')
	cQuery += " ORDER BY Z8_COD, Z8_CONTROL, Z8_DATA"

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("POS") != 0
		POS->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "POS"

Return
