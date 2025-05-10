#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF02     º Autor ³ Giuliano           º Data ³  16/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Lista os fretes de determinados abates definidos em        º±±
±±º          ³ parametros.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF02()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de fretes de gado mediante os AM parametrizados.   "
	Local cDesc3         := "FRETES DE GADO"
	Local cPict          := ""
	Local titulo       := "FRETES DE GADO"
	Local nLin         := 80

	Local Cabec1       := "  Placa        Hora       Ordens                                  Tipo    Quant.       Valor       Media      Dist.  "
	Local Cabec2       := "  Veículo      Receb.     Recebimento                             Veic.   Animais      Frete       Val/An.    Perc.  "
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private tamanho          := "M"
	Private nomeprog         := "GJF02" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg       := "GJF02"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private totvaldia  := 00
	Private totnumdia  := 00
	Private valmeddia  := 00
	Private totalval   := 00
	Private totalnum   := 00

	Private wnrel      := "GJF02" // Coloque aqui o nome do arquivo usado para impressao em disco
	pergunte(cPerg,.T.)
	cQuery := " SELECT ZS_NUMERO AS NUMERO,ZD_DATA AS DATAF,ZS_PLACA AS PLACA,ZS_VAVE AS VAVE,"+;
	"  ZS_VEIC AS VEIC,ZS_DCHPREV+ZS_DASFPR AS DIST, ZS_QTANIM AS QTANIM, ZS_HORA AS HORA "+;
	" FROM "+RetSqlName("SZD")+" SZD,  " + RetSqlName("SZS")+" SZS  "+;
	" WHERE " +;
	" SZD.ZD_NUMERO = SZS.ZS_NUMERO AND "+;
	" SZD.ZD_DATA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' " + " AND "+;
	" SZD.D_E_L_E_T_ <> '*' AND "+;
	" SZS.D_E_L_E_T_ <> '*' AND "+;
	" SZD.ZD_FILIAL = '" + xFilial( "SZD" ) + "' AND" +;
	" SZS.ZS_FILIAL = '" + xFilial( "SZS" ) + "' " +;
	" ORDER BY "+;
	" ZD_DATA,ZS_PLACA,ZS_HORA,ZS_NUMERO"

	cQuery := ChangeQuery(cQuery)
	//    * Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'FRE',.T.,.T.)

	dbselectarea("FRE")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
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
	FRE->(dbgotop())  
	ordemf      := ""
	or_num      := ""
	or_placa    := ""
	or_qtd      := 0
	or_valor    := 0
	or_ordem    := ""
	or_tipo     := ""
	or_data     := FRE->DATAF
	or_dist     := 0
	qtd_rec     := 0
	val_rec     := 0
	qtd_total   := 0
	val_total   := 0
	flag := .f.
	while FRE->(!eof())
		or_data  := FRE->DATAF
		flag := .f.
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

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		while FRE->(!eof()) .and. or_data = FRE->DATAF
			or_num   := FRE->NUMERO
			or_placa := FRE->PLACA
			or_tipo  := FRE->VEIC 
			or_hora  := FRE->HORA

			if flag = .f.
				@nlin,02 psay "Recebimento do dia: "+ substr(or_data,7,2)+"/"+substr(or_data,5,2)+"/"+substr(or_data,1,4)
				nlin++
				flag := .t.
			endif 
			//o while abaio determina a viagem por caminhão
			while FRE->(!eof()) .and. FRE->PLACA = or_placa  .and. FRE->VEIC = or_tipo .and. FRE->HORA = or_hora
				//calculando a quantidade transportada da viagem
				or_qtd    += FRE->QTANIM
				qtd_total += FRE->QTANIM
				qtd_rec   += FRE->QTANIM
				if or_num = FRE->NUMERO
					or_valor += FRE->VAVE
					or_dist  += FRE->DIST
				else    
					or_dist  := FRE->DIST
					or_valor := FRE->VAVE 
				endif  
				if empty(ordemf)
					ordemf   += FRE->NUMERO 
				else
					ordemf   := ordemf+"/"+FRE->NUMERO
				endif

				FRE->(dbskip())
			enddo
			@nlin,02 psay or_placa
			@nlin,14 psay or_hora
			@nlin,27 psay substr(ordemf,1,40)
			@nlin,68 psay or_tipo
			@nlin,76 psay or_qtd   picture "@E 999"
			@nlin,83 psay or_valor picture "@E 999,999.99"
			@nlin,99 psay transform(or_valor/or_qtd,"@E 999.99")
			@nlin,113 psay or_dist picture "@E 999"
			val_rec   += or_valor 
			val_total += or_valor	
			or_qtd   := 0
			or_valor := 0
			or_dist  := 0      
			ordemf   := ""
			nlin++

		enddo
		@nlin,02 psay "Valor Total:    "+transform(val_rec,"@E 999,999.99")
		nlin++
		@nlin,02 psay "Quant. Animais:     "+transform(qtd_rec,"@E 999.99")
		nlin++
		@nlin,02 psay "Média Valor/Animal: "+transform(val_rec/qtd_rec,"@E 999.99")
		nlin++

		@nlin,00 psay "+------------------------------------------------------------------------------------"+;
		"-----------------------------------------------+"

		qtd_rec := 0
		val_rec := 0
		nlin++

	enddo
	@nlin,02 psay "VALOR TOTAL:    "+transform(val_total,"@E 999,999.99")
	nlin++
	@nlin,02 psay "QUANT. ANIMAIS:     "+transform(qtd_total,"@E 999.99")
	nlin++
	@nlin,02 psay "MEDIA VALOR/ANIMAL: "+transform(val_total/qtd_total,"@E 999.99")
	nlin++

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
	FRE->(dbclosearea())
Return
