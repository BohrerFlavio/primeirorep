#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} STI_R502
Relatório de roteiro de carga.
@author 	Evandro Mugnol
@since 		Out/2018
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_R502()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString  := "SZ8"
	cDesc1   := "Este programa tem como objetivo, Imprimir o relatório de "
	cDesc2   := "roteiro de carga.                                        "
	cDesc3   := ""
	tamanho  := "M"
	aReturn  := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1}
	aLinha   := {}
	nLastKey := 0
	cPerg    := "STI_R502"
	titulo   := "Roteiro de Carga"
	wnrel    := "STI_R502"
	nTipo    := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas no Arquivo SX1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa regua de impressao                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(LastRec())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo  := IIF(aReturn[4]==1,15,18)
	nLin   := 80
	m_pag  := 1
	titulo := "Roteiro de Carga Ref. Pré-Carregamento " + MV_PAR01

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := "                                        ROTEIRO DE CARGA                                                        "
	cabec2 := "MARCA  C  L  I  E  N  T  E                                         PESO    CAIXAS                               "
	//***       XXX   XXXXXX XX X--------------------------------------X    XXX.XXX,XX   XXX.XXX                          
	//***                1         2         3         4         5         6         7         8         9        10        11  
	//***      01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção de dados                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery1 := " SELECT *" 
	cQuery1 += "   FROM " + RetSqlTab("ZZ4") 
	cQuery1 += "  WHERE " + RetSqlFil("ZZ4") 
	cQuery1 += "    AND ZZ4_PRECAR = '" + MV_PAR01 + "'"
	DO CASE
	   CASE MV_PAR02 == 1
		   cQuery1 += "    AND ZZ4_TIPOPR = 'D'"
	   CASE MV_PAR02 == 2
		   cQuery1 += "    AND ZZ4_TIPOPR = 'P'"
	ENDCASE 
	cQuery1 += "    AND " + RetSqlDel("ZZ4")
	cQuery1 += "  ORDER BY ZZ4_MARCA"

	cQuery1 := ChangeQuery(cQuery1)

	If Select("TRB1") != 0
		TRB1 -> (DbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "TRB1"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressão dos Dados                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nTotPeso := 0
	_nTotCxs  := 0

	DbSelectArea("TRB1")
	DbGoTop()
	SetRegua(RecCount())
	Do While ! TRB1 -> (Eof ())
		IncRegua()

		If nLin > 75
			Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
			nLin := 9
		Endif 

		@ nLin, 001 PSAY TRB1->ZZ4_MARCA
		@ nLin, 007 PSAY TRB1->ZZ4_CODCLI
		@ nLin, 014 PSAY TRB1->ZZ4_LOJA
		@ nLin, 017 PSAY TRB1->ZZ4_NOME
		@ nLin, 061 PSAY Transform(TRB1->ZZ4_QPPESO, '@E 999,999.99')
		@ nLin, 074 PSAY Transform(TRB1->ZZ4_QPCAIX, '@E 999,999')
		nLin++ 

		_nTotPeso += TRB1->ZZ4_QPPESO
		_nTotCxs  += TRB1->ZZ4_QPCAIX

		TRB1->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 
	EndDo

	TRB1 -> (DbCloseArea())

	If nLin > 75
		Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
		nLin := 9
	Endif 

	@ nLin, 060 PSAY "====================="
	nLin++
	@ nLin, 040 PSAY "T O T A L  ==> "
	@ nLin, 061 PSAY Transform(_nTotPeso,'@E 999,999.99')
	@ nLin, 074 PSAY Transform(_nTotCxs,'@E 999,999')

	Set Device To Screen

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()   // Libera fila de relatorios em spool (Tipo Rede Netware)
Return
