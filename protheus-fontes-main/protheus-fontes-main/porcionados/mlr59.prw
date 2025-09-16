#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "apvt100.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR59  ºAutor  ³Mauricio Roehrs º Data ³  22/10/15          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     Relatório de Controle de estoque de MP, PP, PA, QR, QF da    º±±
±±º          ³ indústria de porcionados   		   				          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MLR59()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia do balanco de producao dos"
	Local cDesc3         := "porcionados."
	//Local cPict         := ""
	Local titulo         := ""
	Local Cabec1         := "             Produto             Descriçao                      Tipo    MP Terceiro?  Qtd. Caixas    Qtd. Peso   %. Carne"
	Local Cabec2         := ""
	//Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "MLR59" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "MLR59"
	//Private cbtxt      	 := Space(10)
	Private cbcont     	 := 00
	Private CONTFL     	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "MLR59" // Coloque aqui o nome do arquivo usado para impressao em disco
	pergunte(cPerg,.F.)

	//u_mlr05b()

	wnrel := SetPrint('ZAS',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_nQtdCaix1 := 0
	_nQtdPeso1 := 0.00

	if mv_par03 == 1
		titulo := 'ESTOQUE PORCIONADOS MATERIA-PRIMA'
	elseif mv_par03 == 2
		titulo := 'ESTOQUE PORCIONADOS REFILE'
	elseif mv_par03 == 3
		titulo := 'ESTOQUE PORCIONADOS QUEBRAS'
	elseif mv_par03 == 4
		titulo := 'ESTOQUE PORCIONADOS PRODUTO ACABADO'
	endif

	//Se estiver selecionado o filtro para
	//MP ou PP somente
	if mv_par03 <= 3
		_nVal := val(mv_par09)
		_cCodMP   := u_GF211MP(mv_par05) //Achou o codigo da matéria-prima
		_cCodAlt  := u_GF211AL(_cCodMP)  //Achou o codigo da matéria-prima alternativa

		IF _nVal > 0
			_cQuery1 := " SELECT ZAS_COD AS _COD, ZAS_TIPO AS _TIPO,ZAS_TERC AS _TERC, COUNT(*) AS _QUANT, SUM(ZAS_PESOL) AS _PESOT"
			_cQuery1 += " FROM " + RetSQLTab('ZAS') + " WHERE " + RetSQLFil('ZAS')
			_cQuery1 += " AND ZAS_DTPROD BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
			_cQuery1 += " AND ZAS_DATAS = '' AND ZAS_HORAS = '' "

			if _nVal > 0 .AND. _nVal < 70
				_cQuery1 += " AND ZAS_PERCCX BETWEEN " + STR(1) + " AND " + STR(69)
			elseif _nVal > 69 .AND. _nVal < 75
				_cQuery1 += " AND ZAS_PERCCX BETWEEN " + STR(69) + " AND  " + STR(75)
			elseif _nVal > 74 .AND. _nVal < 80
				_cQuery1 += " AND ZAS_PERCCX BETWEEN " + STR(74) + " AND  " + STR(80)
			elseif _nVal > 79 .AND. _nVal < 85
				_cQuery1 += " AND ZAS_PERCCX BETWEEN " + STR(80) + " AND  " + STR(85)
			elseif _nVal > 84 .AND. _nVal < 101
				_cQuery1 += " AND ZAS_PERCCX BETWEEN " + STR(84) + " AND " + STR(101)
			endif
			/*criar uma forma de leitura para identificar em qual range a caixa está...*/
			if !empty(mv_par07)
				_cQuery1 += " AND ZAS_LOCAL = '" + mv_par07 +"'  AND ZAS_LOCAL <> '' "
			endif
			_cQuery1 += iif(mv_par03 = 1 ,"AND ZAS_TIPO = 'MP' ",iif(mv_par03 = 2," AND ZAS_TIPO = 'PP' ", " AND ZAS_TIPO IN('QR','QF','M1','M2','M3','TU','GR') "))
			_cQuery1 += iif(mv_par04 = 1," AND ZAS_TERC = 'N' "   ,iif(mv_par04 = 2," AND ZAS_TERC = 'S' " ,""))
			_cQuery1 += iif(!empty(mv_par06)," AND ZAS_COD = '" + mv_par06 + "' ","")
			_cQuery1 += iif(!empty(mv_par05),iif(!empty(_cCodAlt)," AND (ZAS_COD = '" +_cCodMP+"' OR ZAS_COD = '"+_cCodAlt+"')"," AND ZAS_COD ='"+_cCodMP+"'"),"")
			_cQuery1 += "AND " + RetSQLDel('ZAS')
			_cQuery1 += " GROUP BY ZAS_COD, ZAS_TIPO, ZAS_TERC "
			_cQuery1 += " ORDER BY ZAS_COD "
			//	* Mostrar a consulta */
			//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			//@ 055,005 Get _cQuery1 Size 250,080 MEMO Object oMemo
			//Activate Dialog oDlgMemo
		else
			_cQuery1 := " SELECT ZAS_COD AS _COD, ZAS_TIPO AS _TIPO,ZAS_TERC AS _TERC, COUNT(*) AS _QUANT, SUM(ZAS_PESOL) AS _PESOT"
			_cQuery1 += " FROM " + RetSQLTab('ZAS') + " WHERE " + RetSQLFil('ZAS')
			_cQuery1 += " AND ZAS_DTPROD BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
			_cQuery1 += " AND ZAS_DATAS = '' AND ZAS_HORAS = '' "
			if !empty(mv_par07)
				_cQuery1 += " AND ZAS_LOCAL = '" + mv_par07 +"'  AND ZAS_LOCAL <> '' "
			endif	
			_cQuery1 += iif(mv_par03 = 1 ,"AND ZAS_TIPO = 'MP' ",iif(mv_par03 = 2," AND ZAS_TIPO = 'PP' ", " AND ZAS_TIPO IN('QR','QF','M1','M2','M3','TU','GR') "))
			_cQuery1 += iif(mv_par04 = 1," AND ZAS_TERC = 'N' "   ,iif(mv_par04 = 2," AND ZAS_TERC = 'S' " ,""))
			_cQuery1 += iif(!empty(mv_par06)," AND ZAS_COD = '" + mv_par06 + "' ","")
			_cQuery1 += iif(!empty(mv_par05),iif(!empty(_cCodAlt)," AND (ZAS_COD = '" +_cCodMP+"' OR ZAS_COD = '"+_cCodAlt+"')"," AND ZAS_COD ='"+_cCodMP+"'"),"")
			_cQuery1 += "AND " + RetSQLDel('ZAS')
			_cQuery1 += " GROUP BY ZAS_COD, ZAS_TIPO, ZAS_TERC "
			_cQuery1 += " ORDER BY ZAS_COD "
		endif

		//se estiver selecionado para PA
	else
		_cQuery1 := " SELECT Z8_COD AS _COD, Z8_TERC AS _TERC, COUNT(*) AS _QUANT, SUM(Z8_PESO) AS _PESOT"//, Z8_LOTEPOR AS LOTEPOR "
		_cQuery1 += " FROM " + RetSQLTab('SZ8') + " WHERE " + RetSQLFil('SZ8')
		_cQuery1 += " AND  Z8_FIL = '00' AND Z8_DATAS = '' AND Z8_HORAS = '' AND Z8_DATAP BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		_cQuery1 += " AND Z8_LOTEPOR <> '' "
		if !empty(mv_par07)
			_cQuery1 += " AND Z8_LOCAL = '" + mv_par07 + "'"
		endif
		_cQuery1 += iif(!empty(mv_par06)," AND Z8_COD = '" + mv_par06 + "' ","")
		_cQuery1 += "AND " + RetSQLDel('SZ8')
		_cQuery1 += " GROUP BY Z8_COD, Z8_TERC"//, Z8_LOTEPOR "
		_cQuery1 += " ORDER BY Z8_COD "

	endif

	_cQuery1 := ChangeQuery(_cQuery1)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAS')

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

	//Local nOrdem

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	EST1->(SetRegua(RecCount()))

	_cBatel    := ''
	_nTotPesF  := 0
	_nQtdPeso2 := 0
	_nTPSif := 0
	_nTCSif := 0
	EST1->(dbGoTop())

	@nlin,01 psay 'Inicio da  Produção: ' + dtoc(mv_par01)
	nlin++
	@nlin,01 psay 'Final da Produção: ' + dtoc(mv_par02)
	nlin++
	@nlin,65 psay iif(mv_par03 = 4,'PRODUTO ACABADO',iif(mv_par03 = 1,'MATERIA PRIMA',''))
	nlin++

	While EST1->(!EOF())

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
			nLin := 9
		Endif

		@nlin,01 psay replicate('-',132)
		nlin++
		@nlin,15 psay EST1->_COD
		DbSelectArea('SB1')
		_cDesc := fBuscaCPO('SB1',1,xfilial('SB1') + EST1->_COD,'B1_DESC')
		@nlin,30 psay substr(_cDesc,1,25)
		@nlin,65 psay iif(mv_par03 = 4,'PA',EST1->_TIPO)
		@nlin,76 psay iif(EST1->_TERC = 'S','Sim','Nao')
		@nlin,83 psay transform(EST1->_QUANT,"@E 999,999")
		@nlin,97 psay transform(EST1->_PESOT,"@E 999,999.99")
		nlin++

		_nQtdCaix1 += EST1->_QUANT
		_nQtdPeso1 += EST1->_PESOT

		//se for analitico
		if mv_par08 == 1
			buscaCaix(EST1->_COD)
			@nlin,25 psay "Cod. Caixa     Dt. Prod.    Dt. Valid.  Peso Liq.           Dt. Abate         "//Localiz.
			nlin++
			_cSif := ''
			While EST2->(!eof())

				If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif

				if mv_par03 == 1 //se for materia prima
					if mv_par04 = 2//se for de terceiros
						_dtValid := EST2->_DATAVAL + stod(EST2->_DTABAT)
					else
						_dtValid := EST2->_DATAVAL + stod(EST2->_DTPROD)
					endif
				endif

				if mv_par04 == 2
					if _cSif <> EST2->_SIF
						@nlin,01 psay replicate('-',132)
						nlin++
						@nlin,07 psay 'SIF: ' + EST2->_SIF
						nlin++
						@nlin,01 psay replicate('-',132)
						nlin++
						_cSif := EST2->_SIF
					endif
				endif
				/*   Início do Processo  de impressão da % de Carne */

				@nlin,25 psay EST2->_CONTRO
				@nlin,40 psay iif(mv_par04==2,dtoc(stod(EST2->_DTABAT)),dtoc(stod(EST2->_DTPROD)))

					ZAS->(DbSetOrder(1))
					if ZAS->(DbSeek(xfilial('ZAS')+EST2->_CONTRO))
						SZ2->(DbSetOrder(2))
						if  SZ2->(DbSeek(xfilial('SZ2')+EST2->_PREDES))// se houver o apontamento de OP...
						_dtValid := SZ2->Z2_DATAABT + ZAS->ZAS_VALID
						//_dtValid1:= SZ2->Z2_DTPROD + ZAS->ZAS_VALID
						_dtValid1:= ZAS->ZAS_DTPROD + ZAS->ZAS_VALID
						ENDIF

					ENDIF
				If mv_par03 == 4
					@nlin,53 psay (mv_par03==4,dtoc(stod(EST2->_DATAVAL)))
				EndIf
				If mv_par03 == 1
					//@nlin,53 psay (mv_par03==1,dtoc(_dtValid))
					@nlin,53 psay (mv_par03==1,dtoc(_dtValid1))
				EndIf

				@nlin,64 psay transform(EST2->_PESOL,"@E 999.99")
				@nlin,77 psay EST2->_PALLET
				@nlin,90 psay fbuscaCpo('SZ2',2,xFilial('SZ2') + EST2->_PREDES,'Z2_DATAABT')
				cCarne := fBuscaCPO('ZAS',1,xfilial('ZAS')+ alltrim(EST2->_CONTRO),'ZAS_PERCCX')
				@nlin,112 psay cCarne
				If mv_par03 = 4
					@nlin,110 psay 'Lote: ' + EST2->_LOTEPOR
				EndIf
				if mv_par04 == 2//se for terceiros
					@nlin,110 psay 'SIF: ' + EST2->_SIF
					_nTPSif += EST2->_PESOL //total de peso por sif
					_nTCSif ++ 			    //total de caixas por sif
				endif
				nlin++

				_nQtdPeso2 += EST2->_PESOL

				/*   Fim do Processo  de impressão da % de Carne */

				EST2->(DbSkip())

				if mv_par04 == 2
					if _cSif <> EST2->_SIF .or. EST2->(eof())
						@nlin,25 psay 'Total do SIF --->'
						@nlin,40 psay Transform(_nTCSif,'@E 999,999')   +' Caixas'
						@nlin,55 psay Transform(_nTPSif,'@E 999,999,999.99')+ 'kg'
						nlin++
						_nTPSif := 0
						_nTCSif := 0
					endif
				endif
			enddo

		endif
		EST1->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo

	nlin++
	@nlin,25 psay 'Total --->'
	@nlin,35 psay Transform(_nQtdCaix1,'@E 999,999')   +' Caixas'
	@nlin,50 psay Transform(_nQtdPeso1,'@E 999,999,999.99')+ 'kg'

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

Static Function GeraTMP()

	_cQuery1  := ChangeQuery(_cQuery1)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("EST1") != 0
		EST1->(dbCloseArea())
	Endif

	TCQUERY _cQuery1 NEW ALIAS "EST1"

return

//Gera segundo arquivo temporário
Static Function buscaCaix(_cod)

	_nQtdCaix2 := 0

	//Se estiver selecionado o filtro para
	//MP ou PP somente
	
	if mv_par03 < 4
		_nVal := val(mv_par09)
		
			IF _nVal > 0 
				_cQuery2 := " SELECT ZAS_CONTRO AS _CONTRO, ZAS_DTPROD AS _DTPROD,ZAS_VALID AS _DATAVAL,ZAS_PESOL AS _PESOL, ZAS_PALLET AS _PALLET, ZAS_LOCALI AS _LOCALIZ, ZAS_DTABAT AS _DTABAT, ZAS_SIF AS _SIF, ZAS_PREDES AS _PREDES "
				_cQuery2 += " FROM " + RetSQLTab('ZAS') + " WHERE " + RetSQLFil('ZAS')
				_cQuery2 += " AND ZAS_DTPROD BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
				_cQuery2 += " AND ZAS_DATAS = '' AND ZAS_HORAS = '' AND ZAS_COD = '" + _cod + "'"

				if _nVal > 0 .AND. _nVal < 70
					_cQuery2 += " AND ZAS_PERCCX BETWEEN " + STR(1) + " AND " + STR(69)
				elseif _nVal > 69 .AND. _nVal < 75
					_cQuery2 += " AND ZAS_PERCCX BETWEEN " + STR(69) + " AND " + STR(75)
				elseif _nVal > 74 .AND. _nVal < 80
					_cQuery2 += " AND ZAS_PERCCX BETWEEN " + STR(74) + " AND " + STR(80)
				elseif _nVal > 79 .AND. _nVal < 85
					_cQuery2 += " AND ZAS_PERCCX BETWEEN " + STR(80) + " AND " + STR(85)
				elseif _nVal > 84 .AND. _nVal < 101
					_cQuery2 += " AND ZAS_PERCCX BETWEEN " + STR(84) + " AND " + STR(101) 
				endif
				/*criar uma forma de leitura para identificar em qual range a caixa está...*/
				if !empty(mv_par07)
					_cQuery2 += " AND ZAS_LOCAL = '" + mv_par07 +"'  AND ZAS_LOCAL <> '' "
				endif	
				_cQuery2 += iif(mv_par03 = 1 ,"AND ZAS_TIPO = 'MP' ",iif(mv_par03 = 2," AND ZAS_TIPO = 'PP' ", " AND ZAS_TIPO IN('QR','QF','M1','M2','TU','GR') "))
				_cQuery2 += iif(mv_par04 = 1," AND ZAS_TERC = 'N' "   ,iif(mv_par04 = 2," AND ZAS_TERC = 'S' " ,""))
				_cQuery2 += "AND " + RetSQLDel('ZAS')
				_cQuery2 += " ORDER BY ZAS_SIF, ZAS_CONTRO "

			else
				_cQuery2 := " SELECT ZAS_CONTRO AS _CONTRO, ZAS_DTPROD AS _DTPROD,ZAS_VALID AS _DATAVAL,ZAS_PESOL AS _PESOL, ZAS_PALLET AS _PALLET, ZAS_LOCALI AS _LOCALIZ, ZAS_DTABAT AS _DTABAT, ZAS_SIF AS _SIF, ZAS_PREDES AS _PREDES "
				_cQuery2 += " FROM " + RetSQLTab('ZAS') + " WHERE " + RetSQLFil('ZAS')
				_cQuery2 += " AND ZAS_DTPROD BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
				_cQuery2 += " AND ZAS_DATAS = '' AND ZAS_HORAS = '' AND ZAS_COD = '" + _cod + "'"
				if !empty(mv_par07)
					_cQuery2 += " AND ZAS_LOCAL = '" + mv_par07 +"'  AND ZAS_LOCAL <> '' "
				endif
				_cQuery2 += iif(mv_par03 = 1 ,"AND ZAS_TIPO = 'MP' ",iif(mv_par03 = 2," AND ZAS_TIPO = 'PP' ", " AND ZAS_TIPO IN('QR','QF','M1','M2','TU','GR') "))
				_cQuery2 += iif(mv_par04 = 1," AND ZAS_TERC = 'N' "   ,iif(mv_par04 = 2," AND ZAS_TERC = 'S' " ,""))
				_cQuery2 += "AND " + RetSQLDel('ZAS')
				_cQuery2 += " ORDER BY ZAS_SIF, ZAS_CONTRO "
			endif
		//se estiver selecionado para PA
	else
		_cQuery2 := " SELECT Z8_CONTROL AS _CONTRO, Z8_DATAP AS _DTPROD, Z8_PESO AS _PESOL,Z8_DATAVAL AS _DATAVAL, Z8_PALLET AS _PALLET, Z8_LOCALIZ AS _LOCALIZ, Z8_LOTEPOR AS _LOTEPOR, Z8_PREDES AS _PREDES  "
		_cQuery2 += " FROM " + RetSQLTab('SZ8') + " WHERE " + RetSQLFil('SZ8')
		_cQuery2 += " AND Z8_FIL = '00' AND Z8_DATAS = '' AND Z8_HORAS = '' AND Z8_DATAP BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		if !empty(mv_par07)
			_cQuery2 += " AND Z8_LOCAL = '" +mv_par07+"'"
		endif
		_cQuery2 += " AND Z8_LOTEPOR <> '' AND Z8_CODORI = '" + _cod + "'"
		_cQuery2 += " AND " + RetSQLDel('SZ8')
	endif

	_cQuery2 := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("EST2") != 0
		EST2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "EST2"

return
