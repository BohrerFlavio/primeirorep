#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI143   º Autor ³ Flávio  º Data ³  17/02/2022             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Produção de PA Do Porcionados Sainda da Embalagemº±±
±±º          ³   Feito as pressas para Valeska(PCP ) controlar MP que vai º±±
±±º          ³   para porcioandos      									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP    Embalagem                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI143()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este relatório tem como objetivo imprimir Produção de PA    "
	Local cDesc2         := "dos Porcionados antes de dar entrada em estoque"
	Local cDesc3         := " "
	//Local cPict          := " "
	Local titulo       	 := "Relat. Prod. Pa Porc."
	Local nLin           := 80

	Local Cabec1         := "      Control       Codigo                    Descrição	             Data Prod.   Peso Liq.	         Peso Bruto       	   Lote	"                   
	Local Cabec2         := " " 

	//Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 132
	Private tamanho          := "M"
	Private nomeprog         := "DTI03" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   := "DTI03"
	//Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "DTI03" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _cCod      := ''
	Private _cNome     := ''
	pergunte(cPerg,.F.)


	wnrel := SetPrint('ZAS',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT ZAS_CONTRO AS CONTRO, ZAS_COD AS COD, ZAS_DESC AS DESCRI, ZAS_DTPROD AS DTPROD, ZAS_PESOL AS PESOL, ZAS_PESOB AS BRUTO, ZAS_LOTE AS LOTE"
	cQuery += " FROM " + RetSqlTab("ZAS")
	cQuery += " WHERE " + retSqlFil("ZAS")
	//cQuery += " AND ZAS_TIPO = 'MP'"
	//cQuery += " AND ZAS_HORAS = ''"
	If !empty(mv_par01)
		cQuery += " AND ZAS_CONTRO = '" + mv_par01 + "'"
	EndIf

	cQuery += " AND ZAS_COD BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "'"
	cQuery += " AND ZAS_DTPROD BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "'"

	If !empty(mv_par06)
		cQuery += " AND ZAS_LOTE = '" + mv_par06 + "'"
	EndIf           

	cQuery += " AND " +retSqlDel("ZAS")

	//cQuery += " GROUP BY ZAS_CONTRO, ZAS_COD, ZAS_DESC, ZAS_DTPROD, ZAS_PESOL, ZAS_PESOB, ZAS_LOTE"
	//cQuery += " ORDER BY ZAS_COD, ZAS_DESC, ZAS_DTPROD, ZAS_PESOL, ZAS_PESOB, ZAS_LOTE" 

	cQuery := ChangeQuery(cQuery) 
	// ************Modificação

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("TEMP") != 0
		TEMP->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "TEMP"


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAS')

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local _cCod
	//local _cNome


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TEMP->(dbGoTop())

	TEMP->(SetRegua(RecCount()))

	_cCod    := ''
	_TotPesL := 0.00
	_TotPesB := 0.00

	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif 
cont:=0
	While TEMP->(!EOF())

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

		if _cCod <> TEMP->COD 
			@nlin,00 psay replicate('-',132)
			nlin++
			_cCod := TEMP->COD
			@nlin,005 psay TEMP->COD
			@nlin,013 psay substr(TEMP->DESCRI,1,25)
			nlin++
			nlin++
			cont:=0
		endif   
		@nlin,005 psay TEMP->CONTRO
		@nlin,020 psay TEMP->COD
		@nlin,033 psay substr(TEMP->DESCRI,1,25)
		@nlin,068 psay TEMP->DTPROD
		@nlin,082 psay TEMP->PESOL
		@nlin,101 psay TEMP->BRUTO
		@nlin,115 psay TEMP->LOTE
		nlin++ 
		If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 
		cont++
		_TotPesL += TEMP->PESOL
		_TotPesB += TEMP->BRUTO
		TEMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
/*
		if _cCod <> TEMP->COD 
			nlin++
			@nlin,035 psay '---------------> TOTAL DE:'
			@nlin,073 psay 'Peso Liq.:'		
			@nlin,080 psay  + transform(_TotPesL,'@E 999,999')
			@nlin,092 psay 'Peso Bruto:'
			@nlin,095 psay  + transform(_TotPesB,'@E 999,999,999.99')
			nlin++
			_TotPesL := 0
			_TotPesB := 0
			nlin++
		endif   

		//TEMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo 
*/
	EndDo    


	nlin++	
			@nlin,015 psay '---------------> TOTAL DE:'
			@nlin,053 psay 'Tot.CX.: '+alltrim(str(cont))
			@nlin,073 psay 'Peso Liq.:'	+ alltrim(transform(_TotPesL,'@E 999,999')	)
			//@nlin,080 psay  + transform(_TotPesL,'@E 999,999')
			@nlin,092 psay 'Peso Bruto:'+ alltrim(transform(_TotPesB,'@E 999,999,999.99'))
			//@nlin,095 psay  + transform(_TotPesB,'@E 999,999,999.99')
			nlin++
			_TotPesL := 0
			_TotPesB := 0
			nlin++
	nlin += 2

	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif 


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('TEMP')

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
