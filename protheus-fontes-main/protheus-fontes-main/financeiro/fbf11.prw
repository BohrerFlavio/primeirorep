#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF11   º Autor ³ Flavio Bohrer        º Data ³  11/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relação de descontos concedidos                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro (SIGAFIN)                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF11()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de com destino não definido para fins de conferencia"
	Local cDesc3         := " de Baixas do Financeiro     "
	Local cPict          := ""
	Local titulo         := "Relação de Descontos Concedidos"
	Local nLin           := 80                         

	Local Cabec1         := "     Cod.        Cliente"                   
	Local Cabec2         := "                                  Título Nro       Vlr. Título          Vlr. Desc.                 Dt. Baixa "

	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "FBF11" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "FBF11"
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "FBF11" // Coloque aqui o nome do arquivo usado para impressao em disco    


	pergunte(cPerg,.F.)

	wnrel := SetPrint('SE1',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT E1_CLIENTE AS CLIENTE, E1_NUM AS NUMERO, E1_BAIXA AS BAIXA, E1_DESCONT AS DESCONTO, E1_VALOR AS VALOR " 
	cQuery += " FROM " + RetSqlName("SE1") + "," + RetSqlName("SA1") 
	cQuery += " WHERE SE1010.D_E_L_E_T_ <> '*' AND SE1010.E1_FILIAL = '" + xfilial('SE1') + "' AND" 
	cQuery += " SA1010.D_E_L_E_T_ <> '*' AND SA1010.A1_FILIAL = '" + xfilial('SA1') + "' AND" 
	cQuery += " SA1010.A1_COD = SE1010.E1_CLIENTE AND SA1010.A1_LOJA = SE1010.E1_LOJA AND"
	cQuery += " (SA1010.A1_NATUREZ BETWEEN '" + alltrim(mv_par06) + "' AND '" + alltrim(mv_par07) + "') AND"
	cQuery += " (SE1010.E1_CLIENTE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "') AND"
	cQuery += " (SE1010.E1_BAIXA BETWEEN '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "') AND"
	cQuery += " SE1010.E1_DESCONT <> 0 AND SE1010.E1_SALDO = 0"
	cQuery += " ORDER BY E1_CLIENTE,E1_BAIXA,E1_NUM"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   


	If Select("FIN") != 0
		FIN->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "FIN"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SE1')

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

	Local _cCliente := ''
	Local _cNomCli  := ''
	Local _nTotal   := 0
	Local _nDesc    := 0
	Local _nGeral   := 0
	Local _nGerald  := 0
	Local _cCont    := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FIN->(DbGoTop())
	FIN->(SetRegua(RecCount()))

	_cCliente := FIN->CLIENTE 
	_cCliAn   := ''

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9          

	While FIN->(!EOF()) 

		incregua()    	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif   

		if mv_par05 = 1
			if _cCliAn <> FIN->CLIENTE  
				_cNomCli := fBuscaCPO('SA1',1,xfilial('SA1') + _cCliente,'A1_NOME')
				@nlin,02 psay FIN->CLIENTE
				@nlin,12 psay substr(_cNomCli,1,30) 
				_cCliAn := FIN->CLIENTE
				nlin++		
			endif 
			@nlin,35 psay FIN->NUMERO 
			@nlin,47 psay transform(FIN->VALOR,'@E 999,999,999.99') 
			@nlin,67 psay transform(FIN->DESCONTO,'@E 999,999,999.99')  
			@nlin,100 psay stod(FIN->BAIXA) 
			nlin++
		endif           

		_nTotal += FIN->VALOR
		_nDesc  += FIN->DESCONTO

		FIN->(DbSkip())

		if _cCliente <> FIN->CLIENTE .or. FIN->(eof())  
			if mv_par05 = 2
				_cNomCli := fBuscaCPO('SA1',1,xfilial('SA1') + _cCliente,'A1_NOME')     
				@nlin,02 psay _cCliente
				@nlin,15 psay substr(_cNomCli,1,30) 
			endif
			if mv_par05 = 1
				@nlin,34 psay 'T O T A L ==>'
			endif
			@nlin,47 psay transform(_nTotal,'@E 999,999,999.99')       
			@nlin,67 psay transform(_nDesc,'@E 999,999,999.99') 

			_nGeral  += _nTotal
			_nGerald += _nDesc

			_nTotal   := 0
			_nDesc    := 0
			_cCliente := FIN->CLIENTE
			_cCont ++
			nlin++ 
		endif


	EndDo


	if  nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9     
	endif
	nLin +=3
	@nlin,02 psay replicate('-',131)
	nLin ++
	@nlin,34 psay 'T O T A L ==>'
	@nlin,47 psay transform(_nGeral,'@E 999,999,999.99')
	@nlin,67 psay transform(_nGerald,'@E 999,999,999.99')
	nLin ++ 
	@nlin,00 psay replicate('-',132)



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('SE1')

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
