#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI102   º Autor ³ Mauricio Roehrs  º Data ³  29/05/20      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de conferencia de titulos baixados com forma     º±±
±±º          ³ de recebimento cartão de credito - ID 8                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP (SIGAPCP)				                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI102()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2        := "para conferencia de titulos baixados com forma de recebimento "
	Local cDesc3        := "cartao de crédito"
	Local cPict         := "Conf. Baixas Cartao Credito"
	Local titulo       	:= "Conf. Baixas Cartao Credito"
	Local nLin         	:= 80
//		/SELECT E1_NUM, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VALOR, E1_DESCONT, E1_VALLIQ"
	Local Cabec1       	:= 	  "Num.Titulo  Cod.Cliente   Loja  Nome Cliente                           Valor            Desconto     Valor Liquidado"
	Local Cabec2       	:= 	  " "
	Local imprime      	:= .T.
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "M"
	Private nomeprog    := "DTI102" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg  	 	:= "DTI102"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI102" // Coloque aqui o nome do arquivo usado para impressao em disco

	pergunte(cPerg,.F.)


	wnrel := SetPrint('SE1',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT E1_NUM, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VALOR, E1_DESCONT, E1_VALLIQ, E1_PORTADO"
	cQuery += " FROM " + retSqlTab('SE1') + ", " + retSqlTab('SE5')
	cQuery += " WHERE " + retSqlFil('SE1') + " AND " + retSqlFil('SE5')
	cQuery += " AND E1_BAIXA BETWEEN '"+ dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	cQuery += " AND E5_DATA = E1_BAIXA AND E1_CONFCC = 'S'"
	cQuery += " AND E1_NUM = E5_NUMERO"
	cQuery += " AND E1_BAIXA <> '' AND E1_TIPO = 'NF' AND E1_FRMREC = '5'"
	cQuery += " AND " + retSqlDel('SE1')
	cQuery += " AND " + retSqlDel('SE5')
	
	if !empty(mv_par03)
		cQuery += " AND E5_BANCO = '" + mv_par03 + "'"	
	endif
	
	cQuery += " GROUP BY E1_NUM, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VALOR, E1_DESCONT, E1_VALLIQ, E1_PORTADO"
	cQuery += " ORDER BY E1_NUM"
	
//
//	cQuery := " SELECT E1_NUM, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VALOR, E1_DESCONT, E1_VALLIQ, E1_PORTADO"
//	cQuery += " FROM " + retSqlTab('SE1') 
//	cQuery += " WHERE " + retSqlFil('SE1')
//	cQuery += " AND E1_BAIXA BETWEEN '"+ dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
//	cQuery += " AND E1_CONFCC = 'S'"
//	cQuery += " AND E1_BAIXA <> '' AND E1_TIPO = 'NF' AND E1_FRMREC = '5'"
//	cQuery += " AND " + retSqlDel('SE1')
//	
//	cQuery += " ORDER BY E1_NUM"		
//		
		
	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "QRY"

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	local _nTotVal  := 0
	local _nTotDesc := 0
	local _nTotLiq  := 0
	QRY->(dbGoTop())

	QRY->(SetRegua(RecCount()))

	While QRY->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
//		/SELECT E1_NUM, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VALOR, E1_DESCONT, E1_VALLIQ"

		@nlin, 01 PSAY QRY->E1_NUM
		@nlin, 13 PSAY QRY->E1_CLIENTE
		@nlin, 26 PSAY QRY->E1_LOJA
		@nlin, 32 PSAY substr(QRY->E1_NOMCLI,1,25)
		@nlin, 62 PSAY transform(QRY->E1_VALOR,'@E 999,999,999.99')
		@nlin, 80 PSAY transform(QRY->E1_DESCONT,'@E 999,999,999.99')
		@nlin, 98 PSAY transform(QRY->E1_VALLIQ, '@E 999,999,999.99')
		 
		nlin++
		
		_nTotVal  += QRY->E1_VALOR
		_nTotDesc += QRY->E1_DESCONT
		_nTotLiq  += QRY->E1_VALLIQ
		
		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo
	
	@nlin, 50 PSAY 'Totais: '
	@nlin, 62 PSAY transform(_nTotVal,'@E 999,999,999.99')
	@nlin, 80 PSAY transform(_nTotDesc,'@E 999,999,999.99')
	@nlin, 98 PSAY transform(_nTotLiq,'@E 999,999,999.99')
	
	_nTotVal  := 0
	_nTotDesc := 0
	_nTotLiq  := 0

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
