#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁGJF67     ╨Giuliano JosИ ta Forgiarini   ╨ Data Ё  30/09/08    ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Relatorio de AvaliaГЦo de ProduГЦo                         ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Comercial e expediГУes (SIGAPCP e SIGAOMS)                 ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

User Function GJF67()


	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de Variaveis                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio    "
	Local cDesc2         := "de faltas de produГЦo,apontando o que foi previsto e o"
	Local cDesc3         := "deixou de ser produzido conforme os parametros.       "
	//Local cPict          := ""
	Local titulo       	:= "RELATORIO DE AVALIACAO DE PRODUCAO"
	Local nLin         	:= 80
	Local Cabec1       	:= " Codigo e Descricao do Produto                     Prev.C  Real.C          Prev.P  Real.P    Quant. PeГas"
	Local Cabec2       	:= ""
	//Local imprime      	:= .T.
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private limite      := 80
	Private Tamanho     := "M"
	Private nomeprog    := "GJF67" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := "GJF67"
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF67" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZU',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificaГЦo se existe previsao de pesagem
	cQuery := " SELECT ZU_COD AS COD, ZU_DTRPRO AS DTRPRO, SUM(ZU_QPCAIX) AS QPCAIX, SUM(ZU_QRCAIX) AS QRCAIX,"
	cQuery += " SUM(ZU_QPPESO) AS QPPESO, SUM(ZU_QRPESO) AS QRPESO, SUM(ZU_QRQUANT) AS QUANT, B1_DESC AS DESCRI"
	cQuery += " FROM " + RetSQLTab('SZU')
	cQuery += " INNER JOIN " + RetSQLTab('SB1') + " ON (B1_FILIAL = ZU_FILIAL AND B1_COD = ZU_COD)"
	cQuery += " WHERE " + RetSQLFil('SZU') + " AND " + RetSQLFil('SB1')
	cQuery += " AND (ZU_DTRPRO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "')" 

	if mv_par03 = 1
		cQuery += " AND ZU_TIPO = 'P'"
	elseif mv_par03 = 2
		cQuery += " AND ZU_TIPO = 'R'"
	endif

	if mv_par04 = 1
		cQuery += " AND ZU_TF = 'S'"
	elseif mv_par04 = 2
		cQuery += " AND ZU_TF IN ('N', '')"
	endif

	if mv_par05 = 1
		cQuery += " AND ZU_ETIQ = 'PA'"
	elseif mv_par05 = 2
		cQuery += " AND ZU_ETIQ = 'ES'"
	endif

	if mv_par07 = 2
		cQuery += " AND (B1_DESC LIKE '%(AU)%' OR B1_DESC LIKE '% AU %' OR B1_DESC LIKE '%ANGUS%')"
	elseif mv_par07 = 3
		cQuery += " AND (B1_DESC LIKE '%(HE)%' OR B1_DESC LIKE '% HE %' OR B1_DESC LIKE '%HEREFORD%')"
	endif 

	cQuery += " AND " + RetSQLDel('SZU')
	cQuery += " AND " + RetSQLDel('SB1')
	cQuery += " GROUP BY ZU_COD, ZU_DTRPRO, B1_DESC" 
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

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta a interface padrao com o usuario...                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZU')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Processamento. RPTSTATUS monta janela com a regua de processamento. Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	if mv_par06 = 1
		cabec2 := "     Previsao       Data     Prev.C  Real.C          Prev.P    Real.P  Prioridade  TF?  Tipo    Data        Hora     Usuario"
	endif



	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//Local nOrdem

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё SETREGUA -> Indica quantos registros serao processados para a regua Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	PRO->(SetRegua(RecCount()))
	PRO->(dbGoTop())
	SZU->(DbSetOrder(1))

	While PRO->(!EOF())

		incregua()

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica o cancelamento pelo usuario...                             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		if nLin > 70
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		endif

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif 

		@nlin,01 psay substr(PRO->COD,1,6)
		@nlin,10 psay substr(PRO->DESCRI,1,40)
		@nlin,55 psay transform(PRO->QPCAIX,'@E 999')
		@nlin,60 psay transform(PRO->QRCAIX,'@E 999')
		@nlin,70 psay transform(PRO->QPPESO,'@E 999,999.99') 
		@nlin,80 psay transform(PRO->QRPESO,'@E 999,999.99')
		@nlin,95 psay transform(PRO->QUANT,'@E 999,999.99') 

		if mv_par06 = 1
			SZU->(MsSeek(FWxfilial('SZU') + PRO->DTRPRO + PRO->COD))

			While SZU->(!eof()) .and. SZU->ZU_FILIAL = FWxfilial("SZU") ;
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

		PRO->(dbSkip()) // Avanca o ponteiro do registro no arquivo 


	EndDo

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Finaliza a execucao do relatorio...                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	DbCloseArea()

	SET DEVICE TO SCREEN

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se impressao em disco, chama o gerenciador de impressao...          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

