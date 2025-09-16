#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF20     º Autor ³ Giuliano           º Data ³  16/01/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Reletorio de títulos a pagar com retenção de impostos      º±±
±±º          ³ específico para a DIRF.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF20()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de títulos  a pagar com retenção específico para   "
	Local cDesc3         := "conferencia na apuração da DIRF."
	Local cPict          := ""
	Local titulo       := "TITULOS A PAGAR PARA APURAÇÃO DA DIRF"
	Local nLin         := 80

	Local Cabec1       := " Numero  Par.     Data          Data              Valor          Valor         Valor          Valor          Valor"
	Local Cabec2       := " Titulo          Emissão       Vencto.             NF            IRRF           PIS           COFINS          CSLL"
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd       := .F.
	Private lAbortPrint:= .F.
	Private CbTxt      := ""
	Private limite     := 80
	Private tamanho    := "M"
	Private nomeprog   := "GJF20" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo      := 18
	Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey   := 0
	Private cPerg      := "GJF20"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private totvaldia  := 00
	Private totnumdia  := 00
	Private valmeddia  := 00
	Private totalval   := 00
	Private totalnum   := 00

	Private wnrel      := "GJF20" // Coloque aqui o nome do arquivo usado para impressao em disco

	If Select("DIRF")<>0
		DIRF->(dbCloseArea())
	Endif

	pergunte(cPerg,.F.)

	wnrel := SetPrint(,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT E2_FORNECE AS COD,E2_LOJA AS LJ,E2_NOMFOR AS NOME,E2_NUM AS NUM,E2_VENCTO AS VENCTO,F1_DTDIGIT AS ENTRADA, E2_TIPO AS TIPO"
	cQuery += ",E2_VALOR AS VALOR,E2_IRRF AS IRRF,E2_PIS AS PIS,E2_COFINS AS COFINS,E2_CSLL AS CSLL"
	cQuery += ",E2_INSS AS INSS ,E2_PREFIXO AS PREFIXO, E2_DIRF AS DIRF, E2_PARCELA AS PAR"
	cQuery += " FROM "+RetSqlTab('SE2') + "," +RetSQLTab('SF1')
	cQuery += " WHERE "  
	cQuery += RetSQLFil('SE2') + " AND " + RetSQLFil('SF1') + " AND "
	//Sub-Consulta
	cQuery += " E2_FORNECE + E2_LOJA IN(SELECT E2_FORNECE+E2_LOJA "
	cQuery += " FROM " + RetSqlTab('SE2') + "," + RetSQLTab('SF1')
	cQuery += " WHERE "   
	cQuery +=  RetSQLFil('SE2') + " AND " + RetSQLFil('SF1') + " AND "
	cQuery += " F1_DOC = E2_NUM AND F1_PREFIXO = E2_PREFIXO AND F1_FORNECE = E2_FORNECE AND F1_LOJA = E2_LOJA AND "
	cQuery += " (E2_IRRF   <> 0 OR "
	cQuery += "  E2_PIS    <> 0 OR "
	cQuery += "  E2_COFINS <> 0 OR "
	cQuery += "  E2_INSS   <> 0 OR "
	cQuery += "  E2_CSLL   <> 0) AND (F1_DTDIGIT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' " + ")  AND "
	cQuery += "                      (E2_VENCTO BETWEEN ' " + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "' " + ") AND " 
	cQuery += RetSqlDel('SE2') + " AND " + RetSQLDel('SF1') + ") "
	//Fim da sub-consulta
	cQuery += "AND "   
	cQuery += " F1_DOC = E2_NUM AND F1_PREFIXO = E2_PREFIXO AND F1_FORNECE = E2_FORNECE AND F1_LOJA = E2_LOJA AND "
	cQuery += " (F1_DTDIGIT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' " + ") AND "
	cQuery += " (E2_VENCTO BETWEEN ' " + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "' " + ") AND " 
	//cQuery += " E2_FORNECE = '007396' AND "
	cQuery += RetSQLDel('SE2') + " AND " + RetSQLDel('SF1')
	cQuery += " ORDER BY E2_NOMFOR,F1_DTDIGIT"

	MsgRun("Aguarde... Realizando processamento de registros...",,{||  GeraTMP() })


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn)

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


	DIRF->(dbgotop())

	private cCod   := ''
	private CCodigo:= DIRF->COD
	private	Tpis   := 0
	private	Tirrf  := 0
	private	Tcofins:= 0
	private	Tcsll  := 0

	private cLj    := ''
	private Tvalor := 0   
	Private _nTotal := 0
	Private _nIRRF := 0
	Private _nPIS := 0
	Private _nCOFINS := 0
	Private _nCSLL := 0
	Private _TitPro := "''"
	Private _nValorAglut := 0.00
	Private _lAglutinou  := .f.

	DIRF->(SetRegua(RecCount())) 

	_nValorTitTot := 0.00
	_nAglut2      := 0        
	_ValorTot2    := 0

	while DIRF->(!eof())
		incregua()

		while DIRF->(!eof()) .and. DIRF->COD = cCodigo

			_cMes := substr(DIRF->ENTRADA,5,2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o cancelamento pelo usuario...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do cabecalho do relatorio. . .                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			if cCod != DIRF->COD
				@nlin,02  psay DIRF->COD
				@nlin,10  psay DIRF->LJ
				@nlin,14  psay Posicione("SA2", 1, xFilial() + DIRF->COD + DIRF->LJ, "A2_NOME")
				cCod := DIRF->COD
				_lAglutinou := .f.
				nlin++
			endif

			_nValorTitTot := DIRF->(VALOR + IRRF + PIS + COFINS + CSLL + INSS)

			if _nValorTitTot <= mv_par06
				_nValorAglut += DIRF->(IRRF + PIS + COFINS + CSLL + INSS)
			endif

			if !_lAglutinou
				if _nValorTitTot > mv_par06
					_nValorFinal := (_nValorTitTot) + _nValorAglut
					_nValorAglut := 0.00
					_lAglutinou := .t.
				else
					_nValorFinal := DIRF->(VALOR + IRRF + INSS)
				endif 
			else 
				_nValorFinal := _nValorTitTot       
			endif

			//Query para verificar valor total com base no valor de retenção
			cQuery2 := " SELECT COUNT(E2_NUM) AS PARC,SUM(E2_VALOR+ E2_IRRF + E2_PIS + E2_COFINS + E2_CSLL + E2_INSS) AS VALOR
			cQuery2 += " FROM " + RetSqlTab('SE2')
			cQuery2 += " WHERE "
			cQuery2 +=  RetSQLFil('SE2') + " AND "
			cQuery2 += "  SUBSTRING(E2_VENCTO,1,6) = '" + substr(DIRF->VENCTO,1,6) + "' AND "
			cQuery2 += " E2_FORNECE = '" + DIRF->COD + "' AND E2_NUM = '" + DIRF->NUM+ "' AND "
			cQuery2 += RetSqlDel('SE2')

			GeraTMP2()

			if DIRF2->PARC > 1  
				_nAglut2   += DIRF->(IRRF + PIS + COFINS + CSLL + INSS)
				_ValorTot2 += DIRF2->VALOR
				_nValorFinal := iif(_ValorTot2 > mv_par06, DIRF->(VALOR + IRRF + PIS + COFINS + CSLL + INSS),DIRF->(VALOR+INSS+IRRF))	
			endif

			@nlin,02  psay DIRF->NUM
			@nlin,12  psay DIRF->PAR
			@nlin,16  psay STOD(DIRF->ENTRADA)
			@nlin,30  psay STOD(DIRF->VENCTO)
			@nlin,46  psay _nValorFinal picture '@E 999,999.99'
			@nlin,61  psay DIRF->IRRF picture '@E 999,999.99'
			@nlin,76  psay DIRF->PIS picture '@E 999,999.99'
			@nlin,91  psay DIRF->COFINS picture '@E 999,999.99'
			@nlin,106 psay DIRF->CSLL picture '@E 999,999.99'
			@nlin,128 psay iif(!empty(DIRF->DIRF),'OK','')

			Tvalor := Tvalor + _nValorFinal
			Tpis   := Tpis + DIRF->PIS
			Tirrf  := Tirrf + DIRF->IRRF
			Tcofins:= Tcofins + DIRF->COFINS
			Tcsll  := Tcsll + DIRF->CSLL

			if mv_par05 == 1
				ret := Posicione('SA2', 1, xFilial('SA2') + DIRF->(COD + LJ), 'A2_CODRET')
				SE2->(dbgotop())
				SE2->(dbsetorder(6))
				if SE2->(dbseek(xfilial('SE2')+DIRF->(COD + LJ + PREFIXO + NUM )))

					while  SE2->(!eof()) .and. SE2->E2_FILIAL = xfilial('SE2')  .and. SE2->E2_FORNECE == DIRF->COD     .and.;
					SE2->E2_LOJA == DIRF->LJ  .and. SE2->E2_PREFIXO == DIRF->PREFIXO .and.;
					SE2->E2_NUM  == DIRF->NUM .and. SE2->E2_PARCELA == DIRF->PAR

						_dDtEntrada := fBuscaCPO('SF1',1,xfilial('SF1') + SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA),'F1_DTDIGIT')

						if SE2->E2_TIPO != 'TX' .and. (_dDtEntrada <= mv_par01 .or. _dDtEntrada >= mv_par02) .and. ;
						(SE2->E2_VENCTO <= mv_par03 .or. SE2->E2_VENCTO >= mv_par04) //.and. !empty(SE2->E2_CODRET)
							SE2->(dbskip())
							loop
						else
							if empty(SE2->E2_CODRET)
								begin transaction
									reclock('SE2',.f.)
									SE2->E2_DIRF := '2'
									SE2->E2_CODRET := ret
									msunlock()
								end transaction
							endif
						endif
						SE2->(dbskip())
					enddo
					dbselectarea('DIRF')
				endif
			endif
			nlin++
			_nTotal  += _nValorFinal
			_nIRRF   += DIRF->IRRF
			_nPIS    += DIRF->PIS
			_nCOFINS += DIRF->COFINS
			_nCSLL 	+= DIRF->CSLL

			DIRF->(dbskip())

			if (_cMes <> substr(DIRF->ENTRADA,5,2)) .or. DIRF->(eof())
				_lAglutinou := .f.
				@nlin,20  psay "Sub-Total: -------->"
				@nlin,46  psay _nTotal picture '@E 999,999.99'
				@nlin,61  psay _nIRRF picture '@E 999,999.99'
				@nlin,76  psay _nPIS  picture '@E 999,999.99'
				@nlin,91  psay _nCOFINS picture '@E 999,999.99'
				@nlin,106  psay _nCSLL picture '@E 999,999.99'
				nlin++
				_nTotal      := 0
				_nIRRF       := 0
				_nPIS        := 0
				_nCOFINS     := 0
				_nCSLL       := 0   

				_nValorAglut := 0.00 
				_nAglut2     := 0
				_ValorTot2   := 0
			endif

		enddo
		@nlin,000  psay "Totais: ---------------------------->"
		@nlin,046  psay Tvalor picture '@E 999,999.99'
		@nlin,061  psay Tirrf picture '@E 999,999.99'
		@nlin,076  psay Tpis picture '@E 999,999.99'
		@nlin,091  psay Tcofins picture '@E 999,999.99'
		@nlin,106 psay Tcsll picture '@E 999,999.99' 

		nlin += 2         

		Tvalor := 0
		Tpis   := 0
		Tirrf  := 0
		Tcofins:= 0
		Tcsll  := 0
		cCodigo := DIRF->COD
	enddo

	DIRF->(dbclosearea())

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


//Função para gerar arquivo temporário
Static Function GeraTMP()   

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("DIRF") != 0
		DIRF->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "DIRF"

return

//Função para gerar arquivo temporário
Static Function GeraTMP2()   

	cQuery2  := ChangeQuery(cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("DIRF2") != 0
		DIRF2->(dbCloseArea())
	Endif

	TCQUERY cQuery2 NEW ALIAS "DIRF2"

return

