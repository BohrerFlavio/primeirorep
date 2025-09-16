#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI76           º Autor ³ Fabian Maurerº Data ³  19/11/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Caixas Não Encontradas no Estoque                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP      								                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI76()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "com as caixas não encontradas no estoque. 		   "
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo         := "RELATORIO DE CAIXAS NAO ENCONTRADAS NO ESTOQUE"
	Local nLin           := 80

	Local Cabec1       := "Codigo        Descricao            Caixa        Data     Hora    Peso  Local   Localiz.     Pallet     Carreg.  Pre-Pedido"
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private tamanho          := "M"
	Private nomeprog         := "DTI76" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   := "DTI76"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "DTI76" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private TotCaix    := 0.00
	Private TotPeso    := 0.00
	Private _QUANT     := 0
	Private _PESO      := 0
	Private _QUANT2    := 0
	Private _PESO2     := 0

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_nQtCai  := 0
	_nQtCai2 := 0
	_nQtCaiT := 0

	//para verificação se existe previsao de pesagem
	cQuery := " SELECT  Z8_CONTROL AS CAIXA, Z8_DATA AS DATA, Z8_HORA AS HORA, Z8_PESO AS PESO, Z8_COD AS COD, Z8_DESCRI AS DESCRI, Z8_LOCAL AS LUGAR, Z8_PALLET AS PALLET, Z8_LOCALIZ AS LOCALIZ, Z8_HORAS AS HORAS, Z8_DATAS AS DATAS, Z8_LOTEPOR, Z8_PRECAR AS PRECAR, Z8_PREPED AS PREPED "
	cQuery += " FROM " + retSqlTab('SZ8') + " ," + retSqlTab('SB1') + " , " +retSqlTab('SBM')
	cQuery += " WHERE " + retSqlFil('SZ8') + " AND " + retSqlFil('SB1') + " AND " + retSqlFil('SBM')
	cQuery += " AND Z8_FIL = '"+ cFilAnt +"' AND Z8_COD = B1_COD AND B1_GRUPO = BM_GRUPO"
	cQuery += " AND Z8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"

	if mv_par03 = 1
		cQuery += " AND BM_FARM = 'R'"
	elseif mv_par03 = 2
		cQuery += " AND BM_FARM = 'C'"
	elseif mv_par03 = 3
		cQuery += " AND BM_FARM = 'S'"
	endif

	if mv_par04 = 1
		cQuery += " AND Z8_ENCONTR = 'S' "

	else
		cQuery += " AND Z8_ENCONTR = 'N' "

	endif

	cQuery += "AND " + retSqlDel('SZ8') + " AND " + retSqlDel('SB1') + " AND " + retSqlDel('SBM')
	
	cQuery  +=  " ORDER BY Z8_COD, Z8_CONTROL, Z8_DATA"

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

	Local nOrdem

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

		
		DbSelectArea('SB1')
				@nlin,001 psay alltrim(POS->COD) + '|'
				@nlin,010 psay substr(fBuscaCPO('SB1',1,xfilial('SB1')+POS->COD,'B1_DESCRED'),1,20) + '|'
				@nlin,033 psay POS->CAIXA + '|'
				@nlin,046 psay POS->DATA + '|'
				@nlin,057 psay POS->HORA + '|'
				@nlin,065 psay POS->PESO
				@nlin,070 psay '|  ' + POS->LUGAR + '|'
				@nlin,078 psay POS->LOCALIZ + '|'
				@nlin,091 psay POS->PALLET + '|'
				@nlin,104 psay POS->PRECAR + '|'
				@nlin,113 psay POS->PREPED

				nlin++

				_nQtCait += 1

				POS->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		

	EndDo

	//if empty(POS->PRECAR)
	//	_nQtCai += 1
	//elseif !empty(POS->PRECAR)
	//	_nQtCai2 += 1
	//endif

	@nlin,001 psay replicate('-',132)
	//	nlin++
	//	@nlin,001 psay 'Caixas Não Encontradas Estoque: '
	//	@nlin,033 psay Transform(_nQtcai,'@E 999,999')
	//	nlin++
	//	@nlin,001 psay 'Caixas Não Encontradas Carregadas: '
	//	@nlin,034 psay Transform(_nQtcai2,'@E 999,999')
	if mv_par04 = 1
		nlin++
		@nlin,001 psay 'Total Caixas Encontradas: '
		@nlin,033 psay Transform(_nQtcait,'@E 999,999')
	elseif mv_par04 = 2
		nlin++
		@nlin,001 psay 'Total Caixas Não Encontradas: '
		@nlin,033 psay Transform(_nQtcait,'@E 999,999')
	endif
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
