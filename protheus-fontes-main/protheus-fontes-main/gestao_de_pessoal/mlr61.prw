#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch" 
#INCLUDE "tbiconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR61  ºAutor  ³Mauricio Roehrs º Data ³  26/10/15          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de fechamento mensal de refeições                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE/SIGAPON				                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MLR61()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia das refeições para"
	Local cDesc3         := "o fechamento mensal"
	
	Local titulo         := "REFEICOES - FECHAMENTO MENSAL"
	Local Cabec1         := ""
	Local Cabec2         := "    Centro de Custo       Descricao"
	
	Local aOrd           := {}  
	Local nS
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "MLR61" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	:= "MLR61"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "MLR61" // Coloque aqui o nome do arquivo usado para impressao em disco    
	pergunte(cPerg,.F.)


	cabec1 += 'Do período de ' + dtoc(mv_par03) + ' até ' + dtoc(mv_par04)

	wnrel := SetPrint('ZB8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	_cSituacao  := mv_par05
	_cCategoria := mv_par06    
	//-- Modifica variaveis para a Query
	cSitQuery := ""
	For nS:=1 to Len(_cSituacao)
		cSitQuery += "'"+Subs(_cSituacao,nS,1)+"'"
		If ( nS+1) <= Len(_cSituacao)
			cSitQuery += "," 
		Endif
	Next nS        

	cCatQuery := ""
	For nS:=1 to Len(_cCategoria)
		cCatQuery += "'"+Subs(_cCategoria,nS,1)+"'"
		If ( nS+1) <= Len(_cCategoria)
			cCatQuery += "," 
		Endif
	Next nS

	_cQuery := " SELECT ZB8_DATA, ZB8_HORA AS HORA, ZB8_CODREF AS CODREF, ZB8_DSCREF AS DSCREF, ZB8_VLREF AS VLREF, ZB8_VLDSC AS VLDSC,"
	_cQuery += " ZB8_TPREF AS TPREF, ZB8_DESCTP AS DESCTP,"
	_cQuery += " RA_CC AS CC, RA_SITFOLH AS SITFOLH, RA_CATFUNC AS CATFUNC, RA_MAT AS MAT, RA_NOME AS NOME"
	_cQuery += " FROM " + retSqlTab('ZB8') + " , " + retSqlTab('SRA')
	_cQuery += " WHERE " + retSqlFil('ZB8') + " AND " + retSqlFil('SRA')
	_cQuery += " AND ZB8_MAT = RA_MAT"
	_cQuery += " AND RA_CC BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	_cQuery += " AND RA_PROCES BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"
	_cQuery += " AND ZB8_DATA BETWEEN '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "'"
	_cQuery += " AND RA_CATFUNC IN (" + Upper(cCatQuery) + ")" 
	_cQuery += " AND RA_SITFOLH IN (" + Upper(cSitQuery) + ")" 

	if !empty(mv_par08)
		_cQuery += " AND ZB8_CODREF = '" + mv_par08 + "'"
	endif

	if !empty(mv_par11) .AND. !empty(mv_par12)
		_cQuery += " AND RA_MAT BETWEEN '" + AllTrim(mv_par11) + "' AND '" + AllTrim(mv_par12) + "'"
	endif

	_cQuery += " AND " + retSqlDel('ZB8') + " AND " + retSqlDel('SRA')
	_cQuery += " ORDER BY RA_CC, RA_MAT, ZB8_DATA, ZB8_HORA, ZB8_CODREF


	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta 
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo           
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZB8')

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

	
	Local i
	Local j

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop()) 

	_nDescEmp := 0
	_cCC 	    := ''
	_nTotQtd  := 0
	_nTotVlr  := 0
	_nTotDsc  := 0
	_nTotEmp  := 0

	_dData    := ""
	_cMat     := ''

	_nQtdFnc  := 0
	_nVlrFnc  := 0
	_nDscFnc  := 0
	_nEmpFnc  := 0

	_aRef     := {}
	_aRef2    := {}


	While TMP->(!EOF())

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


		/*if(!TMP->SITFOLH $ _cSituacao) .or. !(TMP->CATFUNC $ _cCategoria)
		TMP->(dbSkip())
		loop			
		endif*/

		_nDescEmp := TMP->VLREF - TMP->VLDSC                        		

		if TMP->CC <> _cCC
			_cDscCC := fBuscaCpo('CTT',1,xFilial('CTT') + TMP->CC,'CTT_DESC01')
			@nlin,01 psay replicate('-',132)
			nlin++ 
			@nlin,05 psay TMP->CC
			@nlin,25 psay substr(_cDscCC,1,25)
			_cCC := TMP->CC
			nlin++	   
			@nlin,01 psay replicate('-',132)
			nlin++ 
		endif                         

		//se for analitico
		if mv_par07 = 1
			/*if _dData <> TMP->ZB8_DATA
			@nlin,05 psay stod(TMP->ZB8_DATA)
			nlin++
			_dData := TMP->ZB8_DATA								
			endif*/

			if _cMat <> TMP->MAT
				@nlin,10 psay TMP->MAT
				@nlin,25 psay substr(TMP->NOME,1,25)
				nlin++
				_cMat := TMP->MAT						
				@nlin,16 psay 'Cod.          Descricao          Qtde                Valor(R$)              Desc. Fun(R$)            Desc. Emp(R$)'  
				nlin+=2                 	
			endif

			@nlin,001 psay stod(TMP->ZB8_DATA)
			@nlin,010 psay TMP->HORA
			@nlin,016 psay TMP->TPREF
			@nlin,025 psay substr(TMP->DESCTP,1,16)
			@nlin,044 psay transform(1,'@E 9,999')
			@nlin,066 psay transform(TMP->VLREF,'@E 999,999.99')
			@nlin,088 psay transform(TMP->VLDSC,'@E 999,999.99')
			@nlin,111 psay transform(_nDescEmp,'@E 999,999.99')	

			/*@nlin,010 psay TMP->CODREF
			@nlin,018 psay substr(TMP->DSCREF,1,15)
			@nlin,041 psay transform(1,'@E 9,999')
			@nlin,062 psay transform(TMP->VLREF,'@E 9,999.99')
			@nlin,085 psay transform(TMP->VLDSC,'@E 9,999.99')
			@nlin,108 psay transform(_nDescEmp,'@E 9,999.99')*/
			nlin++ 

			_nQtdFnc += 1
			_nVlrFnc += TMP->VLREF
			_nDscFnc += TMP->VLDSC
			_nEmpFnc += _nDescEmp
		endif

		//Alimenta o vetor que trará descrito os totais de cada tipo de refeição no centro de custo 
		_npos2 := aScan(_aRef2,{|aVal|aVal[1] = TMP->CODREF})

		if _npos2 <> 0
			_aRef2[_npos2,3]+= 1
			_aRef2[_npos2,4]+= TMP->VLREF
			_aRef2[_npos2,5]+= TMP->VLDSC
			_aRef2[_npos2,6]+= _nDescEmp//TMP->DSCEMP	
		else                   
			aAdd(_aRef2,{TMP->CODREF, substr(TMP->DSCREF,1,16),1, TMP->VLREF, TMP->VLDSC,_nDescEmp})
		endif 	

		//Alimenta o vetor que trará descrito os valores totais de cada tipo de refeição para a empresa
		_npos := aScan(_aRef,{|aVal|aVal[1] = TMP->CODREF})

		if _npos <> 0
			_aRef[_npos,3]+= 1
			_aRef[_npos,4]+= TMP->VLREF
			_aRef[_npos,5]+= TMP->VLDSC   
			_aRef[_npos,6]+= _nDescEmp
		else                   
			aAdd(_aRef,{TMP->CODREF, substr(TMP->DSCREF,1,16),1, TMP->VLREF, TMP->VLDSC,_nDescEmp})
		endif 


		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		//se for analitico
		if mv_par07 = 1	                                   
			//total do funcionario            
			if TMP->(eof()) .or. TMP->MAT <> _cMat
				nlin++
				@nlin,018 psay 'TOTAL'
				@nlin,044 psay transform(_nQtdFnc,'@E 999,999')
				@nlin,066 psay transform(_nVlrFnc,'@E 999,999.99')
				@nlin,088 psay transform(_nDscFnc,'@E 999,999.99')
				@nlin,111 psay transform(_nEmpFnc,'@E 999,999.99')
				nlin++                 
				@nlin,01 psay replicate('-',132)
				nlin++ 
				_nQtdFnc := 0
				_nVlrFnc := 0
				_nDscFnc := 0
				_nEmpFnc := 0						
			endif
		endif	            

		//total do centro de custo
		if TMP->(eof()) .or. TMP->CC <> _cCC  
			If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif 

			@nlin,10 psay 'Totais do Centro de Custo: ' + _cCC + ' - ' + substr(_cDscCC,1,25)  
			nlin++
			@nlin,16 psay 'Cod.          Descricao          Qtde                Valor(R$)              Desc. Fun(R$)            Desc. Emp(R$)'  
			nlin+=2                 	

			for j:=1 to len(_aRef2)

				If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif                     

				@nlin,016 psay _aRef2[j,1] //codigo
				@nlin,025 psay _aRef2[j,2] //descricao
				@nlin,044 psay transform(_aRef2[j,3],'@E 999,999')   //quantidade
				@nlin,066 psay transform(_aRef2[j,4],'@E 999,999.99') //valor
				@nlin,088 psay transform(_aRef2[j,5],'@E 999,999.99') //desconto
				@nlin,111 psay transform(_aRef2[j,6],'@E 999,999.99') //desconto empresa
				nlin++

				filRef(_aRef2[j,1],_cCC)

				_nTotQtd += _aRef2[j,3]
				_nTotVlr += _aRef2[j,4]
				_nTotDsc += _aRef2[j,5]
				_nTotEmp += _aRef2[j,6] 

				QRY->(dbGoTop())
				while QRY->(!eof())

					If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
					Endif 

					@nlin,016 psay QRY->ZB8_TPREF
					@nlin,025 psay substr(QRY->ZB8_DESCTP,1,16)
					@nlin,044 psay transform(QRY->QUANT,'@E 999,999')   //quantidade
					@nlin,066 psay transform(QRY->TOTREF,'@E 999,999.99') //valor
					@nlin,088 psay transform(QRY->DSCREF,'@E 999,999.99') //desconto
					@nlin,111 psay transform(QRY->DSCEMP,'@E 999,999.99') //desconto empresa
					nlin++	
					QRY->(dbSkip())			

				enddo		

				nlin++   

			next 

			nlin++
			@nlin,018 psay 'TOTAL'
			@nlin,044 psay transform(_nTotQtd,'@E 999,999')
			@nlin,066 psay transform(_nTotVlr,'@E 999,999.99')
			@nlin,088 psay transform(_nTotDsc,'@E 999,999.99')
			@nlin,111 psay transform(_nTotEmp,'@E 999,999.99')
			nlin+=2
			_nTotQtd := 0
			_nTotVlr := 0
			_nTotDsc := 0		
			_nTotEmp := 0
			_aRef2 := {}
		endif

	EndDo    

	If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif  

	dbSelectArea('SM0')
	@nlin,01 psay replicate('-',132)
	nlin++ 
	@nlin,05 psay 'Filial: ' + cFilAnt + '-'
	@nlin,15 psay SM0->M0_NOMECOM
	nlin++
	@nlin,01 psay replicate('-',132)
	nlin++ 
	@nlin,16 psay 'Cod.          Descricao          Qtde                Valor(R$)              Desc. Fun(R$)            Desc. Emp(R$)'  
	nlin+=2                 	


	_nTotQtd := 0
	_nTotVlr := 0
	_nTotDsc := 0
	_nTotEmp := 0              

	_aTpRef := {}
	for i:=1 to len(_aRef)

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif  

		@nlin,016 psay _aRef[i,1] //codigo
		@nlin,025 psay _aRef[i,2] //descricao
		@nlin,044 psay transform(_aRef[i,3],'@E 9,999,999')   //quantidade
		@nlin,066 psay transform(_aRef[i,4],'@E 9,999,999.99') //valor
		@nlin,088 psay transform(_aRef[i,5],'@E 9,999,999.99') //desconto
		@nlin,111 psay transform(_aRef[i,6],'@E 9,999,999.99') //desconto empresa
		nlin++

		_nTotQtd += _aRef[i,3]
		_nTotVlr += _aRef[i,4]
		_nTotDsc += _aRef[i,5]
		_nTotEmp += _aRef[i,6]

		filRef(_aRef[i,1],'')

		QRY->(dbGoTop())
		while QRY->(!eof())

			@nlin,016 psay QRY->ZB8_TPREF
			@nlin,025 psay substr(QRY->ZB8_DESCTP,1,16)
			@nlin,044 psay transform(QRY->QUANT,'@E 9,999,999')   //quantidade
			@nlin,066 psay transform(QRY->TOTREF,'@E 9,999,999.99') //valor
			@nlin,088 psay transform(QRY->DSCREF,'@E 9,999,999.99') //desconto
			@nlin,111 psay transform(QRY->DSCEMP,'@E 9,999,999.99') //desconto empresa
			nlin++	
			QRY->(dbSkip())			
		enddo		


		@nlin,01 psay replicate('-',132)		 
		nlin++		
	next 


	nlin++
	@nlin,018 psay 'TOTAL'
	@nlin,044 psay transform(_nTotQtd,'@E 9,999,999')
	@nlin,066 psay transform(_nTotVlr,'@E 9,999,999.99')
	@nlin,088 psay transform(_nTotDsc,'@E 9,999,999.99')			
	@nlin,111 psay transform(_nTotEmp,'@E 9,999,999.99')			

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

Static Function filRef(_cCodRef,_cc)

	_cQuery := " SELECT ZB8_TPREF, ZB8_DESCTP, SUM(ZB8_VLREF) AS TOTREF , SUM(ZB8_VLDSC) AS DSCREF, COUNT(ZB8_TPREF) AS QUANT, SUM(ZB8_VLREF - ZB8_VLDSC) AS DSCEMP
	_cQuery += " FROM " + retSqlTab('ZB8') + " , " + retSqlTab('SRA') 
	_cQuery += " WHERE " + retSqlFil('ZB8') + " AND " + retSqlFil('SRA')
	_cQuery += " AND ZB8_MAT = RA_MAT
	_cQuery += " AND ZB8_CODREF = '" + _cCodRef + "'"
	if !empty(_cc)
		_cQuery += " AND RA_CC = '" + _cc + "'"
	else
		_cQuery += " AND RA_CC BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	endif

	if !empty(mv_par11) .AND. !empty(mv_par12)
		_cQuery += " AND RA_MAT BETWEEN '" + AllTrim(mv_par11) + "' AND '" + AllTrim(mv_par12) + "'"
	endif

	_cQuery += " AND ZB8_DATA BETWEEN '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "'" 
	_cQuery += " AND RA_PROCES BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'" 
	_cQuery += " AND RA_CATFUNC IN (" + Upper(cCatQuery) + ")" 
	_cQuery += " AND RA_SITFOLH IN (" + Upper(cSitQuery) + ")" 
	_cQuery += " AND " + retSqlDel('ZB8') + " AND " + retSqlDel('SRA')
	_cQuery += " GROUP BY ZB8_TPREF, ZB8_DESCTP, ZB8_VLREF, ZB8_VLDSC"
	_cQuery += " ORDER BY ZB8_TPREF


	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"


return

Static Function GeraTMP()   

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return
