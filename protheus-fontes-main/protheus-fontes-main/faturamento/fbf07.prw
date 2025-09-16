#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF07     ºFlávio Bohrer Flores       º Data ³  05/09/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Manifesto de carga                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF07()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio       "
	Local cDesc2        := "de Manifesto de carga,discriminando apenas as quantidades"
	Local cDesc3        := "dos produtos em cada carregamento.                       "
	//Local cPict       := ""
	Local titulo       	:= "MANIFESTO DE CARGA"
	Local nLin         	:= 80
	Local Cabec1       	:= " Numero    Placa      Dt.Carreg.   Observacao                  Responsavel"
	Local Cabec2       	:= " Codigo    Produto                        Quant.      P.Bruto    P.Liq."
	//Local imprime     := .T.
	Local aOrd 			:= {}

	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private Tamanho     := "P"
	Private nomeprog    := "FBF07" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "FBF07"
	//Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "FBF07" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private TotCaix    	:= 0.00
	Private TotCaUn     := 0.00
	Private TotPeso    	:= 0.00
	Private TotPeUn     := 0.00
	Private _cDesc		:= ''
	Private _cBDJ300    := alltrim(GETMV('SI_BDJ300G'))
	Private _cBDJ320    := alltrim(GETMV('SI_BDJ320G'))
	Private _cBDJ360    := alltrim(GETMV('SI_BDJ360G'))
	Private _cBDJ400    := alltrim(GETMV('SI_BDJ400G'))
	Private _cBDJ450    := alltrim(GETMV('SI_BDJ450G'))
	Private _cBDJ480    := alltrim(GETMV('SI_BDJ480G'))
	Private _cBDJ500    := alltrim(GETMV('SI_BDJ500G'))
	Private _cBDJ502    := alltrim(GETMV('SI_BDJ502G'))
	Private _cBDJ503    := alltrim(GETMV('SI_BDJ503G'))
	Private _cBDJ600    := alltrim(GETMV('SI_BDJ600G'))
	Private _cBDJ720    := alltrim(GETMV('SI_BDJ720G'))
	Private _cBDJ800    := alltrim(GETMV('SI_BDJ800G'))
	Private _cBDJ802    := alltrim(GETMV('SI_BDJ8002'))
	Private _cBDJ900    := alltrim(GETMV('SI_BDJ900G'))
	Private _nSomaQuant := 0

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem
	cQuery1 := " SELECT B1_GRUPO AS GRUPO,ZZ4_PRECAR AS NUM,ZZ5_COD AS COD,SUM(ZZ5_QRCAIX) AS CAIX,"
	cQuery1 += " SUM(ZZ5_QRPESB) AS PESOB,SUM(ZZ5_QRPESO) AS PESO"
	cQuery1 += " FROM " + RetSqlTab("ZZ4") + ", " + RetSqlTab("ZZ5") + ", " + RetSqlTab("SB1")
	cQuery1 += " WHERE " + RetSqlFil("SB1")
	cQuery1 += "  AND  " + RetSqlFil("ZZ5")
	cQuery1 += "  AND  " + RetSqlFil("ZZ4")
	cQuery1 += "  AND  SB1.B1_COD = ZZ5.ZZ5_COD "
	cQuery1 += "  AND  ZZ4.ZZ4_PRECAR = '" + mv_par01 + "'"
	cQuery1 += "  AND  ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM "
	cQuery1 += "  AND  SB1.B1_MSBLQL <> '1' "
	cQuery1 += "  AND  SB1.B1_TIPO IN('PA','PR') "
	cQuery1 += "  AND  ZZ4.ZZ4_TPOPER <> 'C' "
	cQuery1 += "  AND  " + RetSqlDel("ZZ4")
	cQuery1 += "  AND  " + RetSqlDel("ZZ5")
	cQuery1 += "  AND  " + RetSqlDel("SB1")
	cQuery1 += " GROUP BY ZZ4.ZZ4_PRECAR, SB1.B1_GRUPO, ZZ5.ZZ5_COD "
	cQuery1 += " ORDER BY ZZ4.ZZ4_PRECAR, SB1.B1_GRUPO, ZZ5.ZZ5_COD "

	cQuery2 := " SELECT ZZ4_PRECAR AS NUM,ZZ5_COD AS COD,SUM(ZZ5_QRCAIX) AS CAIX,"
	cQuery2 += " SUM(ZZ5_QRPESB) AS PESOB,SUM(ZZ5_QRPESO) AS PESO" 
	cQuery2 += " FROM "  + RetSqlTab("ZZ4") + ", " + RetSqlTab("ZZ5")
	cQuery2 += " WHERE " + RetSqlFil("ZZ5")
	cQuery2 += "  AND  " + RetSqlFil("ZZ4")
	cQuery2 += "  AND  ZZ4.ZZ4_PRECAR = '" + mv_par01 + "'"
	cQuery2 += "  AND  ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM "
	cQuery2 += "  AND  ZZ4.ZZ4_TPOPER <> 'C' "
	cQuery2 += "  AND  " + RetSqlDel("ZZ4")
	cQuery2 += "  AND  " + RetSqlDel("ZZ5")
	cQuery2 += " GROUP BY ZZ4.ZZ4_PRECAR, ZZ5.ZZ5_COD"
	cQuery2 += " ORDER BY ZZ4.ZZ4_PRECAR, ZZ5.ZZ5_COD"

	if mv_par03 = 1
		cQuery := ChangeQuery(cQuery1)
	else
		cQuery := ChangeQuery(cQuery2)
	endif

	If Select("CAR") != 0
		CAR->(dbCloseArea())
	Endif

	If nLastKey == 27
		Return
	Endif

	TCQUERY cQuery NEW ALIAS "CAR"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetDefault(aReturn,'ZZ3')

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

	CAR->(dbGoTop())

	CAR->(SetRegua(RecCount()))

	nCarga 		  := ' '
	_nGr   		  := ' '
	TotCaix  	  := 0
	TotCaUn 	  := 0
	TotPeso  	  := 0
	TotPesoB 	  := 0
	//TotPeUn  	  := 0
	//TotPeBUn 	  := 0
	_nSomaQuant   := 0

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	While CAR->(!EOF())

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

		if nCarga != CAR->NUM
			nlin++

			@nLin,01 PSAY CAR->NUM
			ZZ3->(dbsetorder(2))
			ZZ3->(MsSeek(FWxfilial('ZZ3')+alltrim(CAR->NUM)))
			@nlin,11 PSAY ZZ3->ZZ3_PLACA
			@nlin,22 PSAY ZZ3->ZZ3_DTCAR
			@nlin,35 PSAY substr(ZZ3->ZZ3_OBS,0,25)
			@nlin,63 PSAY ZZ3->ZZ3_USUAR
			nlin++

			//seleção de status
			do case
				case ZZ3->ZZ3_STATUS = 'A'
				@nlin,01 PSAY '[Aberto]'
				case ZZ3->ZZ3_STATUS = 'B'
				@nlin,01 PSAY '[Bloqueado]'
				case ZZ3->ZZ3_STATUS = 'C'
				@nlin,01 PSAY '[Carregando]'
				case ZZ3->ZZ3_STATUS = 'S'
				@nlin,01 PSAY '[Espera]'
				case ZZ3->ZZ3_STATUS = 'E'
				@nlin,01 PSAY '[Encerrado]'
				case ZZ3->ZZ3_STATUS = 'F'
				@nlin,01 PSAY '[FATURADO]'
			endcase       //Ver do caminhão                                       // se caminhão não saiu

			dbSelectArea("SZT")
			SZT->(dbSetOrder(3))
			if SZT->(MsSeek(FWxfilial('SZT')+alltrim(mv_par02)))
				//  colocar pesos da carga conforme parametro
				if !empty(mv_par02) .and. alltrim(SZT->ZT_PLACA) = alltrim(ZZ3->ZZ3_PLACA)
					nlin++
					if !empty(SZT->ZT_PESOE)
						@nlin,10 PSAY 'Peso Inicial:'
						@nlin,23 PSAY SZT->ZT_PESOE	picture '@E 999,999.99'
					endif
					if !empty(SZT->ZT_PESOS)
						@nlin,40 PSAY 'Peso Final:'
						@nlin,55 PSAY SZT->ZT_PESOS	picture '@E 999,999.99'
					endif
					nLin++
					@nlin,10 PSAY 'Peso Liquido do Balancao:'
					_liqBalancao := SZT->ZT_PESOS - SZT->ZT_PESOE
					@nlin,51 PSAY _liqBalancao picture '@E 999,999.99'
				endif
			endif

			nLin++
			nCarga := CAR->NUM
		endif

		If nLin > 59  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		_cGrupo  := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+CAR->COD,1)
		_cSegum  := GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+CAR->COD,1)
		_cDescri := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+CAR->COD,1)
		_cUnd    := GetAdvFVal('SB1','B1_UM',FWxfilial('SB1')+CAR->COD,1)
		_nQtdCx  := GetAdvFVal('SB1','B1_QCAIX',FWxfilial('SB1')+CAR->COD,1)
		_nSomaQuant   := 0

		if mv_par03 = 1
			if _nGr != CAR->GRUPO
				nlin++
				@nlin,01 PSAY CAR->GRUPO + '   ' + GetAdvFVal('SBM','BM_DESC',FWxfilial('SBM')+alltrim(CAR->GRUPO),1)
				nlin++
				_nGr := CAR->GRUPO
			endif
		endif

		@nlin,02 PSAY substr(CAR->COD,1,6)

		/*if (_cGrupo >= '6000'.and. _cGrupo <= '6999') .or. (_cGrupo >= '8000'.and. _cGrupo <='8999')       //Terceiros
			_cDesc := substr(_cDescri,1,20)
			_cDesc	+="    (T)"
			@nlin,12 PSAY _cDesc
		else*/
			@nlin,12 PSAY substr(_cDescri,1,20)
		//endif

		If !(_cUnd = 'UN')
			@nlin,42 PSAY transform(CAR->CAIX, '@E 999,999')
		Else
			if substr(CAR->COD,1,6) $ _cBDJ300+_cBDJ320+_cBDJ360+_cBDJ400+_cBDJ450+_cBDJ480+_cBDJ500+_cBDJ502+_cBDJ503+_cBDJ600+_cBDJ720+_cBDJ800+_cBDJ802+_cBDJ900
				@nlin,35 PSAY ('UN') + '(' + alltrim(transform(CAR->CAIX * _nQtdCx,  '@E 999,999')) + ')' + transform(CAR->CAIX,  '@E 999,999')
			endif
			/*If substr(CAR->COD,1,6) $ _cBDJ300
				@nlin,35 PSAY ('UN') + alltrim( transform(CAR->CAIX * _nQtdCx,  '@E 999,999')) + transform(CAR->CAIX,  '@E 999,999')
			ElseIf substr(CAR->COD,1,6) $ _cBDJ360
				@nlin,35 PSAY ('UN') + transform(CAR->CAIX * _nQtdCx,  '@E 999,999') + transform(CAR->CAIX,  '@E 999,999')
			ElseIf substr(CAR->COD,1,6) $ _cBDJ400
				@nlin,35 PSAY ('UN') + transform(CAR->CAIX * _nQtdCx,  '@E 999,999') + transform(CAR->CAIX,  '@E 999,999')
			ElseIf substr(CAR->COD,1,6) $ _cBDJ500 .or. substr(CAR->COD,1,6) $ _cBDJ502
				@nlin,35 PSAY ('UN') + '(' + alltrim(transform(CAR->CAIX * _nQtdCx,  '@E 999,999')) + ')' + transform(CAR->CAIX,  '@E 999,999')
			ElseIf substr(CAR->COD,1,6) $ _cBDJ600
				@nlin,35 PSAY ('UN') + transform(CAR->CAIX * _nQtdCx,  '@E 999,999') + transform(CAR->CAIX,  '@E 999,999')
			ElseIf substr(CAR->COD,1,6) $ _cBDJ800 .or. substr(CAR->COD,1,6) $ _cBDJ802
				@nlin,35 PSAY ('UN') + transform(CAR->CAIX * _nQtdCx,  '@E 999,999') + transform(CAR->CAIX,  '@E 999,999')
			EndIf*/
		EndIf

			TotCaix += CAR->CAIX
			TotPeso += CAR->PESO

		/*do case
			case (_cGrupo >= '6000'.and. _cGrupo <= '6999') .or. (_cGrupo >= '8000'.and. _cGrupo <='8999') ;      //Terceiros
			.and. _cSegum = 'CX' 
			@nlin,51 PSAY transform(CAR->PESO, '@E 999,999.99')
			TotPesoB += CAR->PESOB

			case (_cGrupo < '6000' .or. _cGrupo > '6999') .and. (_cGrupo < '8000'.or. _cGrupo > '8999') ;
			.and. _cSegum = 'PC'  
			@nlin,51 PSAY transform(CAR->PESO, '@E 999,999.99')
			TotPesoB += CAR->PESO

			//Monta coluna de Peso Bruto
			case (_cGrupo < '6000' .or. _cGrupo > '6999') .and. (_cGrupo < '8000'.or. _cGrupo > '8999') ;
			.and. _cSegum = 'CX' 
			@nlin,51 PSAY transform(CAR->PESOB, '@E 999,999.99')
			TotPesoB += CAR->PESOB
		endcase*/

		do case
			case _cSegum = 'PC'
			@nlin,51 PSAY transform(CAR->PESO, '@E 999,999.99')
			TotPesoB += CAR->PESO

			case _cSegum = 'CX'
			@nlin,51 PSAY transform(CAR->PESOB, '@E 999,999.99')
			TotPesoB += CAR->PESOB
		endcase

		@nlin,62 psay transform(CAR->PESO,  '@E 999,999.99')

		nLin++ // Avanca a linha de impressao

		CAR->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo

	If nLin > 59  // Sal to de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	nLin++  // mexi
	@nlin,02 PSAY 'TOTAIS:'
	@nlin,43 PSAY transform(TotCaix,  '@E 9,999')
	@nlin,52 PSAY transform(TotPesoB, '@E 999,999.99')
	@nlin,65 PSAY transform(TotPeso,  '@E 999,999.99')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('CAR')

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
