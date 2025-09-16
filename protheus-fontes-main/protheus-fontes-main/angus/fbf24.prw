#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF24   º Autor ³ Flavio Bohrer Flores  º Data ³  31/11/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Produção do setor de embalagem Para Produtos Ag. º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estrito para os Certificadores ANGUS                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF24()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio    "
	Local cDesc2         := "de faltas de produção,apontando o que foi previsto e o"
	Local cDesc3         := "deixou de ser produzido conforme os parametros das Famílias 016 e 107."
	Local cPict          := ""
	Local titulo       	:= "AVALIACAO DE PRODUCAO - ANGUS"
	Local nLin         	:= 80
	Local Cabec1       	:= " Codigo e Descricao do Produto                     Prev.C  Real.C          Prev.P  Real.P    Quant. Peças"
	Local Cabec2       	:= ""
	Local imprime      	:= .T.
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private limite      := 80
	Private Tamanho     := "M"
	Private nomeprog    := "FBF24" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := "FBF24"                                          
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "FBF24" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZU',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem
	cQuery := " SELECT ZU_COD AS COD, ZU_DTRPRO AS DTRPRO, SUM(ZU_QPCAIX) AS QPCAIX, SUM(ZU_QRCAIX) AS QRCAIX,"
	cQuery += " SUM(ZU_QPPESO) AS QPPESO, SUM(ZU_QRPESO) AS QRPESO, SUM(ZU_QRQUANT) AS QUANT"
	cQuery += " FROM SZU010, SB1010 "
	cQuery += " WHERE SZU010.D_E_L_E_T_ <> '*' AND ZU_FILIAL = '" + xfilial('SZU') + "' AND " 
	cQuery += "	SB1010.D_E_L_E_T_ <> '*' AND"
	cQuery += " B1_FILIAL = '" + xfilial('SB1') + "' AND " 
	cQuery += " ZU_COD = B1_COD AND"
	cQuery += " (B1_FAM = '016' OR B1_FAM = '017') AND"
	cQuery += " (ZU_DTRPRO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') " 

	if mv_par03 = 1
		cQuery += " AND ZU_TIPO = 'P' "
	elseif mv_par03 = 2
		cQuery += " AND ZU_TIPO = 'R' "
	endif

	if mv_par04 = 1
		cQuery += " AND ZU_TF = 'S' "
	elseif mv_par04 = 2
		cQuery += " AND ZU_TF = 'N' "
	endif

	if mv_par05 = 1
		cQuery += " AND ZU_ETQ 'PA' "
	elseif mv_par05 = 2
		cQuery += " AND ZU_ETQ = 'ES' "
	endif 

	cQuery += " GROUP BY ZU_COD, ZU_DTRPRO" 
	cQuery += " ORDER BY ZU_COD, ZU_DTRPRO"

	cQuery := ChangeQuery(cQuery)

	If Select("PRO") != 0
		PRO->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "PRO"  

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

	SetDefault(aReturn,'SZU')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if mv_par06 = 1
		cabec2 := "     Previsao       Data     Prev.C  Real.C          Prev.P    Real.P  Prioridade  TF?  Tipo    Data        Hora     Usuario"
	endif



	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	PRO->(SetRegua(RecCount()))

	PRO->(dbGoTop())

	DbSelectArea('SZU')
	SZU->(DbSetOrder(1))

	While PRO->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if nLin > 70
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		endif

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif 

		SZU->(DbSeek(xfilial('SZU') + PRO->DTRPRO + PRO->COD))

		_cProd := fBuscaCPO('SB1',1,xfilial('SB1') + PRO->COD,'B1_DESC')
		@nlin,01 psay substr(PRO->COD,1,6)
		@nlin,10 psay substr(_cProd,1,40) 
		@nlin,55 psay transform(PRO->QPCAIX,'@E 999')
		@nlin,60 psay transform(PRO->QRCAIX,'@E 999')
		@nlin,70 psay transform(PRO->QPPESO,'@E 999,999.99') 
		@nlin,80 psay transform(PRO->QRPESO,'@E 999,999.99')
		@nlin,95 psay transform(PRO->QUANT,'@E 999,999.99') 

		if mv_par06 = 1
			SZU->(DbSeek(xfilial('SZU') + PRO->DTRPRO + PRO->COD))

			While SZU->(!eof()) .and. SZU->ZU_FILIAL = xfilial("SZU") ;
			.and. SZU->ZU_DTRPRO = STOD(PRO->DTRPRO) ; 
			.and. SZU->ZU_COD = alltrim(PRO->COD) 
				nlin++
				@nlin,05 psay SZU->ZU_NUM
				@nlin,20 psay SZU->ZU_DTPROD
				@nlin,32 psay transform(SZU->ZU_QPCAIX,'@E 999')
				@nlin,37 psay transform(SZU->ZU_QRCAIX,'@E 999')
				@nlin,47 psay transform(SZU->ZU_QPPESO,'@E 999,999.99') 
				@nlin,60 psay transform(SZU->ZU_QRPESO,'@E 999,999.99') 
				//@nlin,90 psay transform(PRO->QRQUANT,'@E 999,999.99') 
				if SZU->ZU_PRIORI = 'C'
					@nlin,72 psay 'Caixa'
				elseif SZU->ZU_PRIORI = 'P'
					@nlin,72 psay 'Peso'   
				else
					@nlin,72 psay 'Automatico'   	
				endif
				@nlin,85  psay SZU->ZU_TF
				@nlin,90  psay SZU->ZU_TIPO
				@nlin,95  psay SZU->ZU_DATA
				@nlin,107 psay SZU->ZU_HORA
				@nlin,115 psay SZU->ZU_USUAR

				SZU->(DbSkip())
			enddo 

			nlin += 2 
		else
			nlin++
		endif
		//	endif

		PRO->(dbSkip()) // Avanca o ponteiro do registro no arquivo 


	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('PRO')
	DbCloseArea('SZU')

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

