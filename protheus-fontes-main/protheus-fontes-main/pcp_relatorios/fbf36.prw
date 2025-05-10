#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF36     º Autor ³ Flavio Bohrerº Data ³  10/01/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Análise de Produção                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP e Direção                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF36()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "de Análise de Produto Acabado,  "
	Local cDesc3         := "verificando a média de peso por caixa produzida"
	Local cPict          := "período declarado."
	Local titulo         := "RELATORIO DE ANÁLISE DE PRODUÇÃO"
	Local nLin           := 80

	Local Cabec1       := "  Cod.   Desc. Prod.		                      Média       Tara     Data Prod."

	Local Cabec2       := " "

	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         		:= .F.
	Private lAbortPrint  		:= .F.
	Private CbTxt        		:= ""
	Private limite           	:= 80
	Private tamanho          	:= "M"
	Private nomeprog         	:= "FBF36" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            	:= 18
	Private aReturn          	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        	:= 0
	Private cPerg   				:= "FBF36"
	Private cbtxt      			:= Space(10)
	Private cbcont     		:= 00
	Private CONTFL     		:= 01
	Private m_pag      		:= 01
	Private wnrel      		:= "FBF36" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    		:= 0.00
	Private TotPeso    := 0.00 
	Private _QUANT     := 0
	Private _PESO      := 0
	Private _QUANT2    := 0
	Private _PESO2     := 0

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	cQuery  := " SELECT  Z8_COD AS COD, Z8_DESCRI AS DESCRI, B1_TARAS AS TARAS, AVG(Z8_PESO) AS PESO, Z8_DATA AS DATAP "
	cQuery  += " FROM "  + RetSqlName("SZ8") + " , " + RetSqlName("SB1")  
	cQuery  += " WHERE " + RetSqlName("SZ8") + ".D_E_L_E_T_ <> '*' AND "+ RetSqlName("SB1") + ".D_E_L_E_T_ <> '*'AND" 
	cQuery  += " Z8_COD = B1_COD AND"
	cQuery  += " B1_TIPO IN('PR','PA') AND "
	cQuery  += " Z8_FILORI = '00' AND "   
	//Ajeitar codigo de taras
	//if mv_par06 <> 0
	//	cQuery  += " B1_TARAS = "+str(mv_par06)+" AND " 
	//endif                                  
	cQuery  += " Z8_DATAE = '' AND "
	cQuery  += " B1_FILIAL = '" + xFilial("SB1") + "' AND"
	cQuery  += " (Z8_DATA  BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "') AND" 
	cQuery  += " (Z8_COD  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "') " 
	cQuery  +=  " GROUP BY  Z8_DATA,Z8_COD,Z8_DESCRI,B1_TARAS"
	cQuery  +=  " ORDER BY  Z8_DATA,Z8_COD,Z8_DESCRI"

	cQuery  := ChangeQuery(cQuery)


	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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
	Local _nCont:=0
	Local _cTara := 0  
	Local _nTam  := 75

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	POS->(SetRegua(RecCount()))

	POS->(dbGoTop())

	_dData := POS->DATAP


	While POS->(!EOF())

		incregua()


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > _nTam // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 
		_nTS   := FBuscaCPO('SB1',1,xfilial('SB1')+SB1->B1_COD,'B1_CTARASE')
		_nTara := FBuscaCPO('ZAB',1,xfilial('ZAB')+alltrim(_nTS),'ZAB_TARA')
		//_nTara := FBuscaCPO('SB1',1,xfilial('SB1')+POS->COD,'B1_TARAS')
		@nlin,001 psay alltrim(POS->COD)
		@nlin,008 psay substr(POS->DESCRI,1,40) 
		@nlin,052 psay transform(POS->PESO,'@E 999,999.99')  
		@nlin,066 psay transform(_nTara,'@E 999.999')  
		@nlin,078 psay stod(POS->DATAP)

		/* Criar uma outra tabela aqui para armazenar os dados para gerar um resultado final geral total

		*/
		SZ8->(DbsetOrder(4))
		SZ8->(DbSeek(xfilial('SZ8')+'00'+POS->COD+POS->DATAP))
		_nPer := POS->PESO - (POS->PESO * mv_par05)

		while  SZ8->Z8_COD = POS->COD .AND. mv_par05 <> 1

			if  SZ8->Z8_PESO <= _nPer  
				If nLin > _nTam // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif 
				if SZ8->Z8_DATA = stod(POS->DATAP) 	
					nlin++
					@nlin,010 psay SZ8->Z8_CONTROL 
					@nlin,023 psay transform(SZ8->Z8_PESO,'@E 999,999.99') 
					@nlin,038 psay SZ8->Z8_DATA
				endif	
			endif		
			SZ8->(dbskip())
		enddo

		nlin++	 
		POS->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo

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

