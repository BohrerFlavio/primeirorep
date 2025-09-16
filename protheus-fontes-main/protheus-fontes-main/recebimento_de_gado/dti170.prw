#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI170    ºAutor  ³Adonai Gabriel   º Data ³  14/02/23      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Relatório para consulta de CAR de fornecedores de gado.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI170()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir um relatorio"
	Local cDesc2         := "para consulta de CAR de fornecedores de gado."
	Local cDesc3         := ""
	Local titulo         := "RELATÓRIO PARA CONFERÊNCIA DE CAR DE FORNECEDORES"
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local aOrd           := {}
	Private nlin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := Space(10)
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI170" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI170"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI170" // Coloque aqui o nome do arquivo usado para impressao em disco
	
	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

    MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	SetDefault(aReturn,'SZ8')

	If nLastKey == 27
		Return
	Endif

	Cabec1 += " Código  Loja       Nome                   Município                CAR                                    Comprador"

    Cabec2 += 'Parâmetros: De aviso de matança ' + alltrim(mv_par01) + " até " + alltrim(mv_par02)

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nlin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nlin)
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nlin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	_cNumam := ""

	while TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		if lAbortPrint
			@nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		endif

		if nlin > 80 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nlin := 9
		endif

		if SubStr(TMP->NUMAM, 7, 2) < SubStr(mv_par01, 7, 2)
			TMP->(DbSkip())
			loop
		endif

		if _cNumam != TMP->NUMAM
			_cNumam := TMP->NUMAM
			@nlin,01 psay replicate('-', limite)
			nlin++
			@nlin,02 psay "Aviso de matança -> " + alltrim(_cNumam)
			nlin++
			@nlin,01 psay replicate('-', limite)
			nlin++
		endif

		@nlin,001 psay alltrim(TMP->COD)
		@nlin,010 psay alltrim(TMP->LOJA)
		@nlin,014 psay SubStr(TMP->NOME, 1, 25)
		@nlin,042 psay SubStr(TMP->MUN, 1, 23)
		@nlin,067 psay SubStr(TMP->CAR, 1, 35)
		@nlin,105 psay SubStr(TMP->COMPRAD, 1, 25)
		nlin++

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	end

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

    cQuery := "SELECT Z4_NUMAM AS NUMAM, A2_COD AS COD, A2_NOME AS NOME, A2_MUN AS MUN, Z4_LOJA AS LOJA, Z4_LOTE AS LOTE, A2_CAR AS CAR, A3_NOME AS COMPRAD"
    cQuery += " FROM " + retSqlTab('SZ4')
    cQuery += " INNER JOIN " + retSqlTab('SA2') + " ON (SA2.A2_COD = SZ4.Z4_FORNECE AND SZ4.Z4_LOJA = SA2.A2_LOJA)"
	cQuery += " INNER JOIN " + retSqlTab('SA3') + " ON (SA3.A3_COD = SZ4.Z4_COMPRAD)"
    cQuery += " WHERE " + retSqlFil('SZ4')
    cQuery += " AND Z4_NUMAM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
    cQuery += " AND " + retSqlDel('SZ4') + " AND " + retSqlDel('SA2') + " AND " + retSqlDel('SA3')
    cQuery += " ORDER BY Z4_NUMAM, Z4_ORDEM"

	cQuery  := ChangeQuery(cQuery)

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP"

Return
