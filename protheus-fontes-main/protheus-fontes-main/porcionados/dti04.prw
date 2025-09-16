#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI04  ºAutor  ³Flávio Bohrer Flôres º Data ³  23/06/16     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     Rastrear a Produção das Bateladas para caso necessitar       º±±
±±º          ³Recolhimento de Lote Produzido							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI04()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo identificar pelas bateladas"
	Local cDesc2        := "as caixas expedidas para caso precise recolhê-las em"
	Local cDesc3        := "um recall."
	Local cPict         := ""
	Local titulo        := "Relatório Exp. Por Batelada"
	Local Cabec1        := ""
	Local Cabec2        := ""
	Local imprime       := .T.
	Local aOrd          := {}
	Private nLin        := 80
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "M"
	Private nomeprog    := "DTI04" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "DTI04"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI04" // Coloque aqui o nome do arquivo usado para impressao em disco
	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZAX',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//  --  Querys  ZAX chamando a Função- //
	//GeraTMP()

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAX')

	If nLastKey == 27
		Return
	Endif
	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

	TMP->(dbGoTop())
	TMP->(SetRegua(RecCount()))
	_nEsp := 5
	nLin := _nEsp
	cNumLote := ''
	_cTemLot := 0

	while TMP->(!EOF()) // da ZAX

		incregua()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := _nEsp
		Endif

		_cTemLot := GeraTMP4(TMP->NUM)

		if _cTemLot > 0

			nlin++
			@nlin,00 psay replicate('-',132)
			nlin++
			@nlin,00 psay "Nr. Batelada      Cod. Produto MP       Descr.Produto   						                DT Produção:"//Localiz.                                      		
			nlin++
			@nlin,02 psay TMP->NUM
			@nlin,20 psay TMP->CODIGOMP
			@nlin,40 psay substr(TMP->DESCRIMP,1,22)
			@nlin,72 psay dtoc(stod(TMP->DTPROD))
			nlin++
			@nlin,00 psay replicate('-',132)
			nlin++

			// Qyery da ZAU
			GeraTMP2()

			QRY2->(dbGoTop())

			while QRY2->(!eof()) // da ZAX

				If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := _nEsp
				Endif

				cNumLote := QRY2->NUM

				// ---- Query na SZ8
				GeraTMP3()
				QRY3->(dbGoTop())

				If nLin <> _nEsp
					@nlin,03 psay  'Nr. Lote: ' // Nr do Lote na Tabela ZAU
					nlin++
					@nlin,04 psay  cNumLote // Nr do Lote na Tabela ZAU
					nlin++
				Endif

				@nlin,07 psay 'Cod.Prod: ' + QRY3->CODIGOPRO
				@nlin,026 psay substr(QRY3->DESCRICAO,1,25)

				nlin++ 
				@nlin,013 psay 'Cod.Cli: -- Loja:'
				@nlin,091 psay 'Pré-Pedido: '
				nlin++
				_cCliente:= ''
				_cPreped := ''   

				while QRY3->(!eof()) // da ZAX

					If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := _nEsp
					Endif

					DbSelectArea('ZZ4')
					_cCliente := fBuscaCPO('ZZ4',2,xfilial('ZZ4') + QRY3->PREPED,'ZZ4_NOME')
					_cCodCli  := fBuscaCPO('ZZ4',2,xfilial('ZZ4') + QRY3->PREPED,'ZZ4_CODCLI')
					_cLojaCli := fBuscaCPO('ZZ4',2,xfilial('ZZ4') + QRY3->PREPED,'ZZ4_LOJA')

					//Quebra por pre-pedido
					if _cPreped <> QRY3->PREPED
						@nlin,30 psay replicate('-',40)															
						nlin++
						@nlin,14 psay  _cCodCli
						@nlin,26 psay  _cLojaCli

						@nlin,35 psay substr(_cCliente,1,25) // Cliente
						@nlin,93 psay QRY3->PREPED   // Preped
						nlin++
						@nlin,27 psay "Cod. Caixa     Dt. Prod.    Dt. Valid.  Peso Liq.   Dt.Expedição     "//Localiz.
						nlin++
						_cPreped := QRY3->PREPED
					endif

					// ---  Campos a visualizar no relatório
					@nlin,027 psay QRY3->CODCAIXA
					@nlin,43 psay dtoc(stod(QRY3->DTPROD))
					@nlin,56 psay dtoc(stod(QRY3->DATAVAL))
					@nlin,67 psay transform(QRY3->PESOL,"@E 999.99")
					@nlin,80 psay dtoc(stod(QRY3->DATAS))
					nlin++

					QRY3->(DbSkip())
				enddo
				// --- Fim Abrir caixas conforme SZ8   ------//

				QRY2->(DbSkip())
			enddo
			//  ---  Fim Abrir caixas conforme ZAU   ------//				
			nlin++
		Endif
		TMP->(DbSkip())
	enddo

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

Static Function GeraTMP()

	cQuery := "SELECT ZAX_NUM AS NUM, ZAX_DTPROD AS DTPROD,"
	cQuery += "ZAX_CODMP AS CODIGOMP, ZAX_DESCRI AS DESCRIMP"
	cQuery += " FROM " + RetSqlTab("ZAX")
	cQuery += " WHERE ZAX_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery += " AND " + RetSqlDel('ZAX')
	cQuery := ChangeQuery(cQuery)

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP"


return


Static Function GeraTMP2()

	//  ---  Abrir caixas da ZAU   ------//

	cQuery2 := "SELECT ZAU_NUM AS NUM , ZAU_BATEL AS BATELADA, ZAU_QRCAIF AS QRCAIF"
	cQuery2 += " FROM " + RetSqlTab("ZAU")
	cQuery2 += " WHERE " + RetSqlFil("ZAU")
	cQuery2 += " AND ZAU_BATEL = '" + TMP->NUM  + "' AND ZAU_QRCAIF > 0"
	cQuery2 += " AND " + RetSqlDel('ZAU')
	cQuery2 += " ORDER BY ZAU_NUM"
	cQuery2 := ChangeQuery(cQuery2)


	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo2 Title "Consulta2"
	//@ 055,005 Get cQuery2 Size 250,080 MEMO Object oMemo2
	//Activate Dialog oDlgMemo2

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY cQuery2 NEW ALIAS "QRY2"

return


Static Function GeraTMP3()

	//  ---  Abrir caixas conforme SZ8   ------//

	cQuery3 := "SELECT Z8_CONTROL AS CODCAIXA, Z8_COD AS CODIGOPRO , Z8_DESCRI AS DESCRICAO, Z8_LOTEPOR AS LOTE, Z8_PREPED AS PREPED"
	cQuery3 += ", Z8_DATAP AS DTPROD, Z8_PESO AS PESOL,Z8_DATAVAL AS DATAVAL, Z8_DATAS AS DATAS"
	cQuery3 += " FROM  " + RetSqlTab("SZ8")
	cQuery3 += " WHERE " + RetSqlFil("SZ8") + " AND Z8_FIL = '" + cFilAnt + "'"
	cQuery3 += " AND Z8_LOTEPOR = '" + QRY2->NUM  + "'"
	cQuery3 += " AND Z8_PRECAR <> '' AND Z8_PREPED <> ''"
	cQuery3 += " AND Z8_HORAS  <> '' AND Z8_DATAS  <> ''"
	cQuery3 += " AND " + RetSqlDel('SZ8')
	cQuery3 += " ORDER BY Z8_PREPED, Z8_CONTROL"

	cQuery3 := ChangeQuery(cQuery3)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo3 Title "Consulta3"
	//@ 055,005 Get cQuery3 Size 250,080 MEMO Object oMemo3
	//Activate Dialog oDlgMemo3

	If Select("QRY3") != 0
		QRY3->(dbCloseArea())
	Endif

	TCQUERY cQuery3 NEW ALIAS "QRY3"

return


Static Function GeraTMP4(_cBatel)

	cQuery4 := "SELECT COUNT(ZAU_BATEL) AS QUANT"
	cQuery4 += " FROM " + RetSqlTab("ZAU")
	cQuery4 += " WHERE " + RetSqlFil("ZAU")
	cQuery4 += " AND ZAU_BATEL = '" + _cBatel  + "' AND ZAU_QRCAIF > 0"
	cQuery4 += " AND " + RetSqlDel('ZAU')
	cQuery4 := ChangeQuery(cQuery4)


	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo2 Title "Consulta2"
	//@ 055,005 Get cQuery2 Size 250,080 MEMO Object oMemo2
	//Activate Dialog oDlgMemo2

	If Select("QRY4") != 0
		QRY4->(dbCloseArea())
	Endif

	TCQUERY cQuery4 NEW ALIAS "QRY4"


	QRY4->(dbGoTop())

return QRY4->QUANT
