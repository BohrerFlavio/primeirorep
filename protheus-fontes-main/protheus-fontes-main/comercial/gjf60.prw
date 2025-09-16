#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF60     ºGiuliano José Forgiarini   º Data ³  09/10/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Saídas por Clientes                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF60()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio       "
	Local cDesc2         := "de Manifesto de carga,discriminando apenas as quantidades"
	Local cDesc3         := "dos produtos em cada carregamento.                       "
	Local cPict          := ""
	Local titulo       	:= "RELATORIO DE SAIDAS POR CLIENTE"
	Local nLin         	:= 80

	Local Cabec1       	:= " Codigo/Loja do Cliente                                                  "
	Local Cabec2       	:= "     Codigo   Produto                                 CX/PC          Peso"
	Local imprime      	:= .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private Tamanho      := "P"
	Private nomeprog     := "GJF60" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "GJF60"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF60" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ4',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


	if empty(mv_par07) .and. empty(mv_par08) 

		cQuery := " SELECT ZZ4_CODCLI AS CODCLI,ZZ5_COD AS COD,ZZ5_DESC AS DESCRI,"+;
		" SUM(ZZ5_QRCAIX) AS QRCAIX,SUM(ZZ5_QRPESO) AS QRPESO"+;
		" FROM " + RetSqlName("ZZ4") + " ZZ4," +;
		RetSqlName("ZZ5") + " ZZ5 " +;
		" WHERE ZZ4.D_E_L_E_T_ <> '*' " +;
		" AND ZZ5.D_E_L_E_T_ <> '*' AND" +; 
		" ZZ4_FILIAL = '" + xFilial("ZZ4") + "' AND"+;  
		" ZZ5_FILIAL = '" + xFilial("ZZ5") + "'"+;
		" AND (ZZ4.ZZ4_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "')" +;
		" AND (ZZ4.ZZ4_DATA BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "')" +;  
		" AND (ZZ4.ZZ4_CODCLI BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "')" +;
		" AND ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM "+;   
		" AND ZZ5.ZZ5_QRCAIX <> 0 "+;  
		" GROUP BY ZZ4.ZZ4_CODCLI,ZZ5.ZZ5_COD,ZZ5.ZZ5_DESC"+;
		" ORDER BY ZZ4.ZZ4_CODCLI,ZZ5.ZZ5_COD,ZZ5.ZZ5_DESC"

	else

		cQuery := " SELECT ZZ4_CODCLI AS CODCLI, ZZ4_LOJA AS LOJA, ZZ5_COD AS COD,ZZ5_DESC AS DESCRI,"+;	
		" SUM(ZZ5_QRCAIX) AS QRCAIX,SUM(ZZ5_QRPESO) AS QRPESO"+;
		" FROM " + RetSqlName("ZZ4") + " ZZ4," +;
		RetSqlName("ZZ5") + " ZZ5 " +;
		" WHERE ZZ4.D_E_L_E_T_ <> '*' " +;
		" AND ZZ5.D_E_L_E_T_ <> '*' AND" +; 
		" ZZ4_FILIAL = '" + xFilial("ZZ4") + "' AND"+;  
		" ZZ5_FILIAL = '" + xFilial("ZZ5") + "'"+;
		" AND (ZZ4.ZZ4_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "')" +;
		" AND (ZZ4.ZZ4_DATA BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "')" +;  
		" AND (ZZ4.ZZ4_CODCLI BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "')" +;
		" AND (ZZ4.ZZ4_LOJA BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "')" +;
		" AND ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM "+;   
		" AND ZZ5.ZZ5_QRCAIX <> 0 "+;  
		" GROUP BY ZZ4.ZZ4_CODCLI,ZZ4.ZZ4_LOJA,ZZ5.ZZ5_COD,ZZ5.ZZ5_DESC"+;
		" ORDER BY ZZ4.ZZ4_CODCLI,ZZ4.ZZ4_LOJA,ZZ5.ZZ5_COD,ZZ5.ZZ5_DESC"

	endif

	cQuery := ChangeQuery(cQuery)

	If Select("CLI") != 0
		CLI->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "CLI"  

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

	SetDefault(aReturn,'ZZ4')

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

	CLI->(SetRegua(RecCount()))

	CLI->(dbGoTop())

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	_cPreped := ''
	_cCodCli := ''    
	_cLoja   := ''   
	_cNomCli := ''
	_dDataP  := ''

	While CLI->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 59  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif  
		if !(empty(mv_par07) .and. empty(mv_par08))
			if _cCodCli != CLI->CODCLI .or. _cLoja != CLI->LOJA
				_cNomCli := fBuscaCPO('SA1',1,xfilial('SA1') + CLI->(CODCLI+LOJA),'A1_NOME')
				If nLin > 59  // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif  
				@nlin,01 psay CLI->CODCLI + "/" + CLI->LOJA 
				@nlin,13 psay _cNomCli
				nlin++
				_cCodCli := CLI->CODCLI   
				_cLoja   := CLI->LOJA
			endif
		else
			if _cCodCli != CLI->CODCLI 
				_cNomCli := fBuscaCPO('SA1',1,xfilial('SA1') + CLI->CODCLI,'A1_NOME')
				If nLin > 59  // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif  
				@nlin,01 psay CLI->CODCLI
				@nlin,13 psay _cNomCli
				nlin++
				_cCodCli := CLI->CODCLI   
			endif
		endif
		/*  
		if _cPreped != CLI->PREPED  
		_dDataP := fBuscaCPO('ZZ4',2,xfilial('ZZ4')+CLI->PREPED,'ZZ4_DATA')
		If nLin > 59  // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
		Endif  
		@nlin,01 psay CLI->PREPED    
		@nlin,10 psay _dDataP
		nlin++
		_cPreped := CLI->PREPED
		endif
		*/   
		@nlin,05 psay CLI->COD
		@nlin,15 psay substr(CLI->DESCRI,1,35)
		@nlin,55 psay transform(CLI->QRCAIX,'@E 9,999')
		@nlin,65 psay transform(CLI->QRPESO,'@E 999,999.99')

		nLin++ // Avanca a linha de impressao

		CLI->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

		if !(empty(mv_par07) .and. empty(mv_par08))
			if _cCodCli != CLI->CODCLI .or. _cLoja != CLI->LOJA
				nlin++
			endif 
		else
			if _cCodCli != CLI->CODCLI 
				nlin++
			endif 
		endif

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('CLI')

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

