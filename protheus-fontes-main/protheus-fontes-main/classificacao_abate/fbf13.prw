#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF13   º Autor ³ Giuliano Forgiarini  º Data ³  14/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de manifesto de cargas analitico                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF13()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de manifesto de carga analítico listando as caixas ou"
	Local cDesc3         := "peças que formaram esta carga."
	Local cPict          := ""
	Local titulo       := "MANIFESTO DE CARGA ANALÍTICO"
	Local nLin         := 80

	Local Cabec1       := "              Frigorifico Silva Industria e Comercio Ltda. - BR 392 Km 8 Passo das Tropas - Santa Maria - RS - Brasil"
	Local Cabec2       := "  Carga    Placa      Data   Observação"

	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 128
	Private tamanho          := "M"
	Private nomeprog         := "FBF13" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   	:= "FBF13"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag       := 01
	Private wnrel       := "FBF13" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private TotCaix    	:= 0.00
	Private TotPeso    	:= 0.00 
	Private _nMes	   	:= ""

	pergunte(cPerg,.F.)

	//para verificação se existe previsao de pesagem

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT ZZ3_NUM AS CARGA, ZZ4_NUM AS PREPED, ZZ4_DTFIM AS DTFIM,ZZ5_ITEM AS NUM_ITEM, ZZ5_COD AS ITEM, ZZ5_QRCAIX AS QRCAIX, ZZ5_QRPESO AS QRPESO"+;
	" FROM " + RetSqlName("ZZ5") + ", " + RetSqlName("ZZ4")  + ", " + RetSqlName("ZZ3") +;
	" WHERE ZZ4010.D_E_L_E_T_ <> '*' AND "+;
	"       ZZ5010.D_E_L_E_T_ <> '*' AND "+;
	"       ZZ3010.D_E_L_E_T_ <> '*' AND "+;
	" ZZ3_NUM = ZZ4_PRECAR AND "+;
	" ZZ4_NUM = ZZ5_NUM AND"+;
	" ZZ3_FILIAL = '" + xFilial("ZZ3") + "' AND"+;
	" ZZ5_FILIAL = '" + xFilial("ZZ5") + "' AND"+;               
	" (ZZ3_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 +"') AND"+;
	" (ZZ4_NUM BETWEEN '" + mv_par03 + "' AND '" + mv_par04 +"') AND"+;
	" ZZ4_FILIAL = '" + xFilial("ZZ4")+ "'"+;
	" ORDER BY ZZ3_NUM,ZZ4_NUM,ZZ5_ITEM"


	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("CAR") != 0
		CAR->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "CAR"


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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	CAR->(dbGoTop())

	CAR->(SetRegua(RecCount()))

	_cPrecar  := ' '
	_cPrecar2 := CAR->CARGA
	_cPreped  := ' '    
	_nTotCaix  := 0 
	_nTotPesoL := 0
	_nTotPesoB := 0
	_lAbt      := .f.
	_lClass    := .f.

	While CAR->(!EOF())



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

		if  CAR->CARGA != _cPrecar 
			@nlin,002 psay CAR->CARGA
			@nlin,010 psay fBuscaCPO('ZZ3',2,xfilial('ZZ3')+alltrim(CAR->CARGA),'ZZ3_PLACA')
			@nlin,020 psay fBuscaCPO('ZZ3',2,xfilial('ZZ3')+alltrim(CAR->CARGA),'ZZ3_DTCAR')
			@nlin,030 psay fBuscaCPO('ZZ3',2,xfilial('ZZ3')+alltrim(CAR->CARGA),'ZZ3_OBS')
			nlin++
			@nlin,00 psay replicate('=',132)
			_cPrecar := CAR->CARGA
			nlin++
		endif

		if CAR->PREPED != _cPreped 
			if !empty(mv_par05)
				cQuery2 := " SELECT COUNT(Z2_NUMAM) AS NUMAM"+;
				" FROM " + RetSqlName("ZZ4") + ", " + RetSqlName("SZ8") + ", " + RetSqlName("SZ2") +;
				" WHERE ZZ4010.D_E_L_E_T_ <> '*' AND "+;
				"       SZ2010.D_E_L_E_T_ <> '*' AND "+;
				"       SZ8010.D_E_L_E_T_ <> '*' AND "+;
				"       ZZ4_NUM    = Z8_PREPED AND "+;
				"       Z8_PREDES = Z2_NUM  AND "+;
				" ZZ4_FILIAL = '" + xFilial("ZZ4") + "' AND"+;             
				" Z8_FIL = '" + xFilial("SB1") + "' AND"+; 
				" Z2_FILIAL = '" + xFilial("SZ2") + "' AND"+;
				" Z2_NUMAM = '" + mv_par05 + "'"
				if !empty(mv_par06)
					cQuery2 += " AND Z2_CLASSIF = '" + mv_par06 + "'"
				endif  

				cQuery2 := ChangeQuery(cQuery2)

				//	* Mostrar a consulta */
				//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
				//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
				//Activate Dialog oDlgMemo

				If Select("CAR2") != 0
					CAR2->(dbCloseArea())
				Endif
				TCQUERY cQuery2 NEW ALIAS "CAR2"

				if CAR2->NUMAM = 0
					CAR->(DbSkip())
					loop
				endif
			endif

			nlin++
			@nlin,010 psay CAR->PREPED
			_cCliente := fBuscaCPO('ZZ4',2,xfilial('ZZ4')+alltrim(CAR->PREPED),'ZZ4_CODCLI')
			_cLoja    := fBuscaCPO('ZZ4',2,xfilial('ZZ4')+alltrim(CAR->PREPED),'ZZ4_LOJA')
			@nlin,020 psay _cCliente + "/" + _cLoja
			@nlin,030 psay fBuscaCPO('SA1',1,xfilial('SA1')+_cCliente + _cLoja,'A1_NOME')
			/*   inclusão da Z4_DTFIM****************************88*/
			_nMes:= substr(CAR->DTFIM,5,6)

			@nlin,90 psay " DT FIM : "+substr(CAR->DTFIM,7,8)+"/"+substr(_nMes,1,2)+"/"+substr(CAR->DTFIM,1,4)
			/* FIM  substr(_cDescri,1,38)   */
			nlin++
			@nlin,00 psay replicate('-',132)
			nlin++
			_cPreped := CAR->PREPED
		endif      



		_cPreItem := alltrim(CAR->PREPED)+alltrim(CAR->NUM_ITEM)
		_c2UM     := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(CAR->ITEM),'B1_SEGUM')
		_cGrupo   := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(CAR->ITEM),'B1_GRUPO')
		_cDescri  := alltrim(fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(CAR->ITEM),'B1_DESC')) + '   ('+_c2UM + ')'

		if fBuscaCPO('ZZ5',1,xfilial('ZZ5')+_cPreItem,'ZZ5_QRCAIX') != 0
			@nlin,020 psay CAR->ITEM
			@nlin,030 psay substr(_cDescri,1,38)  
			@nlin,075 psay 'Caixas/Peças: ' + transform(CAR->QRCAIX,'@E 9,999')
			@nlin,103 psay 'Peso Líquido: ' + transform(CAR->QRPESO,'@E 999,999.99')     
			nlin++
			@nlin,015 psay 'Cod. Caixa'
			@nlin,032 psay 'Quant.'
			@nlin,041 psay 'Peso B.'
			@nlin,055 psay 'Tara'
			@nlin,067 psay 'Peso L.'
			@nlin,080 psay 'Dt. Prod.'
			@nlin,095 psay 'Dt. Valid.'
			@nlin,108 psay 'Dt. Abate'
			@nlin,121 psay 'Classif.'
			if  _c2UM  = 'CX' .and. ((_cGrupo < '6000' .or. _cGrupo > '6999') .and. (_cGrupo < '8000' .or. _cGrupo > '8999'))
				nlin++ 
				SZ8->(dbsetorder(2))
				if	SZ8->(dbseek(xfilial('SZ8') +xfilial('SB1') + _cPreItem,.t.))    
					while  SZ8->(!eof()) .and. SZ8->(Z8_PREPED + Z8_ITEM) = _cPreItem  .and. SZ8->Z8_FIL = xfilial('SB1')    
						_cNumAbt     := ''
						_dDtAbate    := ''  
						_cClassific  := ''  



						_cNumAbt     := fBuscaCPO('SZ2',2,xfilial('SZ2')+SZ8->Z8_PREDES,'Z2_NUMAM')

						if !empty(mv_par05)
							if _cNumAbt <> mv_par05
								SZ8->(DbSkip())
								loop
							endif
						endif  

						_dDtAbate    := fBuscaCPO('SZ2',2,'00'+SZ8->Z8_PREDES,'Z2_DATAABT')   
						_cClassific  := fBuscaCPO('SZ2',2,'00'+SZ8->Z8_PREDES,'Z2_CLASSIF')    

						if !empty(mv_par06)
							if _cClassific <> mv_par06
								SZ8->(DbSkip())
								loop
							endif
						endif


						If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif
						@nlin,015 psay SZ8->Z8_CONTROL
						@nlin,032 psay transform(SZ8->Z8_QUANT,'@E 999')
						@nlin,041 psay transform(SZ8->Z8_PESOBR,'@E 999.99')
						@nlin,055 psay transform(SZ8->Z8_TARA,'@E 9.999')
						@nlin,067 psay transform(SZ8->Z8_PESO,'@E 999.99')
						@nlin,080 psay SZ8->Z8_DATAP
						@nlin,095 psay SZ8->Z8_DATAVAL  



						// @nlin,116 psay 'Abate: ' + 	_cNumPrevDes
						@nlin,110 psay _dDtAbate    
						@nlin,122 psay _cClassific 
						nlin++    
						_nTotCaix++  
						_nTotPesoL += SZ8->Z8_PESO  
						_nTotPesoB += SZ8->Z8_PESOBR
						SZ8->(dbskip())
					enddo
				endif

			elseif _c2UM = 'CX' .and. ((_cGrupo >= '6000' .and. _cGrupo <= '6999') .or. (_cGrupo >= '8000' .and. _cGrupo <= '8999'))    
				nlin++ 
				SZ8->(dbsetorder(2))
				if	SZ8->(dbseek(xfilial('SZ8') + xfilial('SB1') + _cPreItem,.t.))    
					while  SZ8->(!eof()) .and. SZ8->(Z8_PREPED + Z8_ITEM) = _cPreItem  .and. SZ8->Z8_FIL = xfilial('SB1');
					.and. SZ8->Z8_TERC = 'S'
						If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif

						@nlin,15 psay SZ8->Z8_CONTROL
						@nlin,41 psay transform(SZ8->Z8_PESO,'@E 999.99')
						@nlin,67 psay transform(SZ8->Z8_PESO,'@E 999.99')
						@nlin,87 psay "Produto 3°" 
						nlin++  
						_nTotCaix++  
						_nTotPesoL += SZ8->Z8_PESO  
						_nTotPesoB += SZ8->Z8_PESO

						SZ8->(dbskip())
					enddo
				endif

			elseif _c2UM = 'PC'  
				nlin++             
				ZZ2->(dbsetorder(1))
				if ZZ2->(dbseek(xfilial('ZZ2')+_cPreItem,.t.))
					while ZZ2->(!eof()) .and. ZZ2->(ZZ2_PREPED+ZZ2_ITEM) = _cPreItem .and. ZZ2->ZZ2_FILIAL = xfilial('ZZ2')   
						If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif
						@nlin,15 psay 'Peça'
						@nlin,32 psay ZZ2->ZZ2_NUM
						@nlin,41 psay transform(ZZ2->ZZ2_PESOB,'@E 999.99')
						@nlin,55 psay transform(ZZ2->ZZ2_TARA,'@E 9.999')
						@nlin,67 psay transform(ZZ2->ZZ2_PESOL,'@E 999.99')
						nlin++   
						_nTotCaix++  
						_nTotPesoL += ZZ2->ZZ2_PESOL  
						_nTotPesoB += ZZ2->ZZ2_PESOB
						ZZ2->(dbskip())
					enddo    
				endif
			endif
		endif
		nlin++

		CAR->(dbSkip()) // Avanca o ponteiro do registro no arquivo


		if CAR->(eof()) .or.  CAR->CARGA <> _cPrecar2 
			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif  
			nlin++  
			@nlin,00 psay replicate('=',132)
			nlin++
			@nlin,02 psay 'NUMERO TOTAL DE CAIXAS DA CARGA:        ' + transform(_nTotCaix, '@E 999,999')
			nlin += 2
			@nlin,02 psay 'PESO LIQUIDO TOTAL DA CARGA    : ' + transform(_nTotPesoL,'@E 999,999,999.99')
			nlin += 2
			@nlin,02 psay 'PESO BRUTO TOTAL DA CARGA      : ' + transform(_nTotPesoB,'@E 999,999,999.99')
			nlin++   
			@nlin,00 psay replicate('=',132)
			_cPrecar2 := CAR->CARGA
		endif 

	EndDo


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
