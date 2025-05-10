#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMLR34     บAutor  ณ Mauricio Roehrs    บ Data ณ  10/03/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa desenvolvido com a finalidade de calcular 20min   บฑฑ
ฑฑบ          ณpor dia de hora-extra para todos os func. da ind. VERBA 197 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function MLR34()

	Private _cDtPeriodo    := GETMV('MV_PAPONTA')//parametro que possui a data de apontamento do ponto
	Private _cDtIni     	  := substr(_cDtPeriodo,1,8)
	Private _cDtFim 	  	  := substr(_cDtPeriodo,10,18)
	Private _dIniPer       := stod("")
	Private _dFimPer	     := stod("")
	Private _dAnoIni    	  := stod("")
	Private _dAnoFim	  	  := stod("")
	Private _cMat		  	  := ''
	Private _dDataCorrente := stod("")
	Private _nDias 		  := 0
	Private _aBat			  := {}
	Private _nTotHr		  := 0
	Private _dDataIni		  := stod("")
	Private _nHorasL		  := 0
	/*se estiver com sim no cadastro do funcionario irแ calcular 
	uma m้dia de 20dias trabalhados para o funcionario*/ 
	if cFilAnt <> '01'

		//if fbuscapd("101,090,091") == 0
		//	return
		//endif                

		if SRA->RA_ACORHE <> 'S'   	
			calcHoras()
		else 
			calcMedia()
		endif
	endif

Return

Static Function calcMedia()

	_nDias := 25 //media de dias sera de 25 dias de acordo com Clailton

	_nTotHr  := calcula(_nDias)
	_nDias   := 0                                               
	_nGratif := fBuscaPd('185') / SRA->RA_HRSMES
	_nHorasL := 0


	/* Inclusใo feita dia 28/12/2016 (por Flแvio) a Pedido de Marilice 
	Verba 224 - Dif de Troca de Roupa
	Objetivo da verba ้ efetuar o pagamento da diferen็a de troca de roupa , atrav้s do lancamento das horas que a Mari Lan็a
	*/  

	/*  Retornando em fevereiro conforme pedido da Marilice 
	SRC->(DbSetOrder(1))
	SRC->(DbGotop())
	while SRC->(!eof())    
	If SRC->RC_PD = '224' 
	_nHorasL := SRC->RC_HORAS
	endif
	SRC->(DbSkip())
	enddo 
	*/   

	//fdelPD('197')                                                  

	//faz os calculos das horas extras com base nos calculos acima
	if SRA->RA_ADCINS = "3" //se insalubridade media diferente de zero      

		_nInsMed := (@VAL_SALMIN * 0.20) / SRA->RA_INSMAX                                  
		/* Altera็ใo de troca de V por H, na verba 197, solicitada pelo Tiago Nardi dia 04/11/2016 (Por Flแvio)
		Teste efetuado o cแlculo da Folha Funcionou */		
		//fGeraVerba("197",((SALHORA) * 1.6) * _nTotHr,_nTotHr,,,"H","I",,,,.T.)


	elseif SRA->RA_ADCINS = "4" //se insalubridade maxima diferente de zero   

		_nInsMax := (@VAL_SALMIN * 0.40) / SRA->RA_INSMAX                  	
		//fGeraVerba("197",((SALHORA) * 1.6) * _nTotHr,_nTotHr,,,"H","I",,,,.T.)	


	elseif SRA->RA_ADCPERI = "2" 

		_nPeric := (SRA->RA_SALARIO * 0.30) / SRA->RA_PERICUL			
		//fGeraVerba("197",((SALHORA) * 1.6) * _nTotHr,_nTotHr,,,"H","I",,,,.T.)			 	

	else                                                    

		//fGeraVerba("197",((SALHORA) * 1.6) * _nTotHr,_nTotHr,,,"H","I",,,,.T.)


	endif

	_nTotHr := 0
return

Static Function calcHoras()

	_dIniPer := stod(substr(_cDtPeriodo,1,8))
	_dFimPer := stod(substr(_cDtPeriodo,10,18))

	_dInicial := seekDataIni(SRA->RA_MAT,_dIniPer,_dFimPer)

	DbSelectArea('SP8')
	SP8->(DbSetOrder(2))
	SP8->(DbGoTop())                 
	if SP8->(DbSeek(xFilial('SP8') + SRA->RA_MAT + _dInicial))
		//alert('ACHOU')
		//if SP8->(DbSeek(xFilial('SP8') + SRA->RA_MAT))

		_dDataIni := SP8->P8_DATA
		_cMat  := SRA->RA_MAT

		if _dDataIni < _dIniPer
			_dDataIni := _dIniPer
		endif
		//	alert(_dDataIni)
		//	alert(_dIniPer) 	     
		//enquanto a data das marca็๕es da SP8 estiverem entre as datas do parametro MV_PAPONTA
		//while xFilial('SP8') = SP8->P8_FILIAL .and. SRA->RA_MAT = SP8->P8_MAT .and. (_dDataIni >= _dIniPer .and. SP8->P8_DATA <= _dFimPer)		
		while SP8->(!eof()) .and. xFilial('SP8') == SP8->P8_FILIAL .and. alltrim(_cMat) == alltrim(SP8->P8_MAT) .and. SP8->P8_DATA <= _dFimPer		

			/*valida็ใo extra para filia, estava causando problemas quando havia matriculas iguais nas duas filiais*/
			if SP8->P8_FILIAL <> cFilAnt
				SP8->(DbSkip())
				loop		
			endif 

			/*esta condi็ใo prev๊ falhas de leitura e apontamento*/
			if empty(SP8->P8_PAPONTA) .or. empty(SP8->P8_ORDEM) .or. empty(SP8->P8_DATAAPO)
				SP8->(DbSkip())
				loop
			endif

			/*Ignora os centros de custos a seguir somente para o frigorifico*/								 
			if cEmpAnt = '01'
				if (SRA->RA_CC = "1111001") .or. (SRA->RA_CC = "1111003") .or. (SRA->RA_CC = "1121001") .or. (SRA->RA_CC = "1121002")		
					SP8->(DbSkip())
					loop
				endif
			endif

			/*Ignora marca็๕es que foram rejeitadas automaticamente pelo sistema */
			if SP8->P8_TIPOREG = 'O' .and. !empty(SP8->P8_MOTIVRG)
				SP8->(DbSkip())
				loop
			endif

			/*Ignora marca็๕es que foram excluidas manualmente*/
			if SP8->P8_TIPOREG = 'I' .and. (SP8->P8_MOTIVRG $ 'MARC INVERTIDA' .or. SP8->P8_MOTIVRG $ 'MARCACAO INVERTIDA')
				SP8->(DbSkip())
				loop
			endif

			/*Ignora marca็๕es que foram excluidas manualmente*/
			if SP8->P8_TIPOREG = 'I' .and. (SP8->P8_MOTIVRG $ 'MARC INCORRETA' .or. SP8->P8_MOTIVRG $ 'MARCACAO INCORRETA')
				SP8->(DbSkip())
				loop
			endif

			/*Ignora marca็๕es que foram excluidas manualmente*/
			if SP8->P8_TIPOREG = 'I' .and. SP8->P8_MOTIVRG $ 'EXCLUSAO MANUAL'
				SP8->(DbSkip())
				loop
			endif  

			//valida็ใo do campo caso tenha marca็ใo excluida pelo sistema
			If SP8->P8_TPMCREP = 'D'
				SP8->(DbSkip())
				loop
			endif

			/*Para fazer a contagem de apenas um dia*/
			if _dDataCorrente = SP8->P8_DATA
				SP8->(DbSkip())
				loop
			else
				_dDataCorrente := SP8->P8_DATA
			endif

			//alert(dtoc(SP8->P8_DATA))
			_nDias ++

			//alert('Matricula: ' + SP8->P8_MAT + '     '+'Total de Dias:' + cValToChar(_nDias))  

			SP8->(DbSkip())

		enddo
	endif

	_nTotHr := calcula(_nDias)
	_nDias  := 0 

	_nGratif := fBuscaPd('185') / SRA->RA_HRSMES

	//fdelPD('197') 


	//transforma de hora centesimal para hora do relogio <nใo ้ utilizado neste caso>
	//_nTotHr := _nTotHr / 0.6
	if cFilAnt <> '01'
		//faz os calculos das horas extras com base nos calculos acima
		if SRA->RA_ADCINS = "3" //se insalubridade media diferente de zero

			_nInsMed := (@VAL_SALMIN * 0.20) / SRA->RA_INSMAX                                                        		
			//fGeraVerba("197",((SALHORA ) * 1.6) * _nTotHr,_nTotHr,,,"H","I",,,,.T.)	 			

		elseif SRA->RA_ADCINS = "4" //se insalubridade maxima diferente de zero

			_nInsMax := (@VAL_SALMIN * 0.40) / SRA->RA_INSMAX                                   
			//fGeraVerba("197",((SALHORA ) * 1.6) * _nTotHr,_nTotHr,,,"V","I",,,,.T.)	 	

		elseif SRA->RA_ADCPERI = "2"
			_nPeric := (SRA->RA_SALARIO * 0.30) / SRA->RA_PERICUL

			//fGeraVerba("197",((SALHORA) * 1.6) * _nTotHr,_nTotHr,,,"H","I",,,,.T.)	 					

		else                                                    		
			//fGeraVerba("197",((SALHORA) * 1.6) * _nTotHr,_nTotHr,,,"H","I",,,,.T.)		 

		endif
	endif
	_nTotHr := 0
return


Static Function calcula(_nDias)

	Local _nTotal := 0

	_nTotal := _nDias * 0.33

return _nTotal



Static Function seekDataIni(cMat,_dtIni,_dtFim)


	_cQuery := " SELECT TOP 1 P8_DATA
	_cQuery += " FROM " + retSqlTab('SP8')
	_cQuery += " WHERE " + retSqlFil('SP8')
	_cQuery += " AND P8_DATA BETWEEN '" + dtos(_dtIni) + "' AND '" + dtos(_dtFim) + "'" 
	_cQuery += " AND P8_MAT = '" + cMat + "'"
	_cQuery += " AND " + retSqlDel('SP8')
	_cQuery += " ORDER BY P8_DATA

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"
	TMP->(dbGoTOp())                 

return TMP->P8_DATA
