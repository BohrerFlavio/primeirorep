#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF236     ºAutor  ³Giuliano Forgiariniº Data ³  05/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Relatorio para analise de peças de terceiro em estoque   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function GJF236()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para rastreabilidade de caixas de PA conforme os "
	Local cDesc3         := "lotes produzidos e bateladas de MP utilizadas."
	Local cPict          := ""
	Local titulo         := "P0X - EXPEDIÇÃO DE PA POR BATELADAS/LOTES"
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}  
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "GJF236" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "GJF236"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF236" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _nTotReg     := 0 
	Private _cQuery      := ''

	pergunte(cPerg,.F.)


	Cabec1 := 'Dt. produção de ' + dtoc(mv_par01) + ' até ' + dtoc(mv_par02) + ' | ' + ' Dt. expedição: ' + dtoc(mv_par03) + ' até ' + dtoc(mv_par04)
	Cabec2 := 'Batelada de ' + mv_par05 + ' ate ' + mv_par06 + ' | ' + ' Lote de ' + mv_par07 + ' ate ' + mv_par08

	wnrel := SetPrint('ZAX',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAX')

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

	MsgRun("Selecionando os registros...",,{|| GeraQuery()})

	SetRegua(_nTotReg)

	_cBatel   := ''
	_cLote    := ''
	_cCodCli  := ''
	while PROD->(!eof())  

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if _cBatel <>  PROD->ZAX_NUM     
			@nlin,00 psay replicate('=',080)
			nlin++  
			@nlin,001 psay 'Batelada nr.: ' + PROD->ZAX_NUM  + ': ' + alltrim(PROD->ZAX_DESCRI)  
			nlin++    
			@nlin,001 psay 'Data consumo: ' + dtoc(stod(PROD->ZAX_DTPROD))      
			nlin++   
			@nlin,00 psay replicate('=',080)
			nlin++
			_cBatel := PROD->ZAX_NUM
		endif


		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if _cLote <> PROD->ZAU_NUM 
			@nlin,011 psay 'Lote nr.: ' + alltrim(PROD->ZAU_IMLOTE) + ': ' + alltrim(PROD->ZAU_DESC)
			nlin++   
			@nlin,00 psay replicate('-',080)
			nlin++
			_cLote := PROD->ZAU_NUM
		endif


		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if _cCodcli <> PROD->(ZZ4_CODCLI + ZZ4_LOJA)                                                                 
			_cTel := fBuscaCPO('SA1',1,xfilial('SA1') + PROD->(ZZ4_CODCLI + ZZ4_LOJA),'A1_TEL')
			_cEnd := fBuscaCPO('SA1',1,xfilial('SA1') + PROD->(ZZ4_CODCLI + ZZ4_LOJA),'A1_END')
			_cMun := fBuscaCPO('SA1',1,xfilial('SA1') + PROD->(ZZ4_CODCLI + ZZ4_LOJA),'A1_MUN')
			@nlin,011 psay 'Cliente: ' + PROD->ZZ4_CODCLI + '/' + PROD->ZZ4_LOJA + '  ' +  alltrim(PROD->ZZ4_NOME)     
			nlin++
			@nlin,011 psay 'End.: ' + _cEnd 
			nlin++
			@nlin,011 psay 'Mun.: ' + _cMun 
			nlin++
			@nlin,011 psay 'Fone: ' + _cTel 	  	  	
			_cCodcli := PROD->(ZZ4_CODCLI + ZZ4_LOJA)
			nlin++
		endif


		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		@nlin,031 psay 'Caixa: ' + PROD->Z8_CONTROL + '   ' + transform(PROD->Z8_PESO,'999.99')  + '   ' + transform(PROD->Z8_TARA,'9.999') 

		nlin++  

		PROD->(DbSkip())			  

	enddo 

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

//Função para gerar a query...
Static Function GeraQuery()

	_cQuery := " SELECT "
	_cQuery += " ZAX_NUM, ZAX_CODMP, ZAX_DTPROD, ZAX_REC,ZAX_DESCRI, "
	_cQuery += " ZAU_NUM, ZAU_COD  , ZAU_DTPROD, ZAU_DESC, ZAU_BATEL, ZAU_IMLOTE,"
	_cQuery += " Z8_CONTROL, Z8_CODORI, Z8_DATAP, Z8_LOTEPOR, Z8_PESO, Z8_TARA, "
	_cQuery += " ZZ4_NUM, ZZ4_CODCLI, ZZ4_LOJA, ZZ4_NOME, ZZ4_DATA, ZZ4_MUN, ZZ4_NOMREP
	_cQuery += " FROM " + RetSqlTab("ZAX") + ", " + RetSqlTab("ZAU")  + ", " + RetSqlTab("SZ8") + ", " + RetSqlTab("ZZ4")
	_cQuery += " WHERE "
	_cQuery += RetSQLFil('ZAX') + " AND " 
	_cQuery += RetSQLFil('ZAU') + " AND " 
	_cQuery += RetSQLFil('SZ8') + " AND " 
	_cQuery += RetSQLFil('ZZ4') + " AND " 
	_cQuery += " Z8_FILORI = '" + cFilAnt + "' AND "
	_cQuery += " ZAX_NUM = ZAU_BATEL AND "
	_cQuery += " ZAU_NUM = Z8_LOTEPOR AND "
	_cQuery += " Z8_PREPED = ZZ4_NUM AND Z8_PRECAR = ZZ4_PRECAR AND ZZ4_TPOPER = 'V' AND "
	_cQuery += " (Z8_DATAP BETWEEN '" + DTOS(mv_par01) +"' AND '" + DTOS(mv_par02) + "') AND "     
	_cQuery += " (ZZ4_DATA BETWEEN '" + DTOS(mv_par03) +"' AND '" + DTOS(mv_par04) + "') AND "     
	_cQuery += " (ZAX_NUM  BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "') AND "
	_cQuery += " (ZAU_NUM  BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "') AND "  
	_cQuery += RetSQLDel('ZAX') + " AND "
	_cQuery += RetSQLDel('ZAU') + " AND "
	_cQuery += RetSQLDel('SZ8') + " AND "
	_cQuery += RetSQLDel('ZZ4') 
	_cQuery += " ORDER BY  ZAX_NUM,ZAU_NUM,ZZ4_NOME,Z8_CONTROL "

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   


	If Select("PROD") != 0
		PROD->(dbCloseArea())
	Endif
	TCQUERY _cQuery NEW ALIAS "PROD" 

	while PROD->(!eof())
		_nTotReg++
		PROD->(DbSkip())
	enddo

	PROD->(DbGoTop())

return
