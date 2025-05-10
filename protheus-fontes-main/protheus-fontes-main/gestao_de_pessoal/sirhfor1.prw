#INCLUDE "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SIRHFOR1º Autor Flávio Bohrer           Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de Fórmulas Para o cálculo  da folha de pagamento   º±±
±±º          ³ do Frigorífico silva (SM)								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10 IDE                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/     

USER FUNCTION  SIRHFOR1()
	Private _nHrsPdr111 	:= 0
	Private _nValPdr111 	:= 0
	Private _nValPdr113 	:= 0
	Private _nHrsPdr113 	:= 0
	Private _nValPdr409 	:= 0
	Private _nHrsPdr409 	:= 0
	Private _nValPdr136 	:= 0
	Private _nHrsPdr136 	:= 0
	Private _nValPdr110 	:= 0
	Private _nHrsPdr110 	:= 0
	Private  _nHrsPdr 	:= 0        
	Private _nHrsPdr112	:= 0   
	Private _nValPdr112	:= 0
	Private _nValPdr115 	:= 0
	Private _nHrsPdr115	:= 0    
	Private _nValPdr438 	:= 0
	Private _nHrsPdr438	:= 0  
	Private _nValPdr192 	:= 0
	Private _nHrsPdr192	:= 0 
	Private _nValPdr118 	:= 0
	Private _nHrsPdr118	:= 0 
	Private _nMonth      := 0
	Private _nYear       := 0  
	Private _cTipo 		:= '000'
	Private _nVal105		:= 0 
	Private _nVal106		:= 0 
	Private _nVal108     := 0
	Private _nDias			:= 0
	Private _nVlAdcHr1     := 0 

	_nHrs910:=fBuscaPD("910","H")
	_nHrs911:=fBuscaPD("911","H")	
	_nHrs991:=fBuscaPD("991","H")	
	_nHrs992:=fBuscaPD("992","H")
	_nHrs993:=fBuscaPD("993","H")
	_nHrs994:=fBuscaPD("994","H")
	_nHrs996:=fBuscaPD("996","H")

	_nVal910:=fBuscaPD("910")    


	/*Verificação do Histório do salário do funcionário */
	DbSelectArea('SR3')
	SR3->(dbSetOrder(1))
	if SR3->(DbSeek(xfilial('SR3')+SRA->RA_MAT))
		while SR3->(!eof()) .and. SR3->R3_FILIAL = xfilial('SR3') .and. SRA->RA_MAT = SR3->R3_MAT
			if SR3->R3_TIPO = '005'
				_cTipo := '005'		    
				exit
			endif
			SR3->(DbSkip())
		enddo
	endif 
	/*Calculo da Insalubridade Média */
	if SRA->RA_ADCINS == "3" 
		_nVal105 := @VAL_SALMIN * 0.20        
	endif
	if SRA->RA_ADCINS == "4" 
		_nVal106 := @VAL_SALMIN * 0.40           
	endif

	/*Calculo da Periculosidade */
	if SRA->RA_ADCPERI == "2"
		_nVal108 := SRA->RA_SALARIO * 0.30
	endif


	//calcular adicional por tempo de serviço.	
	if cEmpAnt <> '07' // se for frigorifico ou graxaria
		if cFilAnt = '01'
			_nVlAdcHr1 := (((((INT(((DDATABASE-SRA->RA_ADMISSA)/365)/5))*4)/100) * (SRA->RA_SALARIO)))//se for filial 01				
		else
			_nVlAdcHr1 := (((((INT(((DDATABASE-SRA->RA_ADMISSA)/365)/5))*5)/100) * (SRA->RA_SALARIO)))				
		endif 	
	endif

	/*------- Hora Extra 60% --------*/




	if  _nHrs992 > 0  
		_nValPdr112 := 0
		_nHrsPdr112 := 0
		_nValPdr111 := 0 
		_nHrsPdr111 := 0

		if _cTipo = '005' .AND. MONTH(SRA->RA_VCTEXP2) == MONTH(ddatabase) .AND. year(SRA->RA_VCTEXP2) == YEAR(DDATABASE)
			_nValPdr112 := ((_nHrs992/30)* day(SRA->RA_VCTEXP2))*(((SRA->RA_SALEXPE+_nVal105+_nVal106+_nVal108)/SRA->RA_HRSMES)*1.6)
			_nHrsPdr112 := ((_nHrs992/30)* day(SRA->RA_VCTEXP2))
			fGeraVerba("112",_nValPdr112,_nHrsPdr112,,,"V","I",,,,.T.)		    
		endif
		_nValPdr111 := (_nHrs992-_nHrsPdr112) * (((SRA->RA_SALARIO+_nVal105+_nVal106+_nVal108+_nVlAdcHr1)/SRA->RA_HRSMES)*1.6)
		_nHrsPdr111 := _nHrs992-_nHrsPdr112

		fGeraVerba("111",_nValPdr111,_nHrsPdr111,,,"H","E",,,,.T.)

		//fgeraverba("111",fbuscapd("992"),fbuscapd("992","h"),,,,,,,,.t.)
	endif 


	/*------- Hora Extra 100% --------*/     

	if  _nHrs993 > 0     	
		_nValPdr113 :=0
		_nHrsPdr113 :=0
		_nValPdr115 := 0
		_nHrsPdr115 := 0
		if _cTipo = '005' .AND. MONTH(SRA->RA_VCTEXP2) == MONTH(ddatabase) .AND. year(SRA->RA_VCTEXP2) == YEAR(DDATABASE)
			_nValPdr115 :=	((_nHrs993/30)* day(SRA->RA_VCTEXP2))*(((SRA->RA_SALEXPE+_nVal105+_nVal106+_nVal108)/SRA->RA_HRSMES)*2)
			_nHrsPdr115 :=	((_nHrs993/30)* day(SRA->RA_VCTEXP2))
			fGeraVerba("115",_nValPdr115,_nHrsPdr115,,,"V","I",,,,.T.)

		endif
		_nValPdr113 :=	(_nHrs993-_nHrsPdr115)*(((SRA->RA_SALARIO+_nVal105+_nVal106+_nVal108+_nVlAdcHr1)/SRA->RA_HRSMES)*2)
		_nHrsPdr113 :=	 _nHrs993 - _nHrsPdr115
		fGeraVerba("113",_nValPdr113,_nHrsPdr113,,,"H","E",,,,.T.)
		//fgeraverba("113",fbuscapd("993"),fbuscapd("993","h"),,,,,,,,.t.)
	endif


	/*------- Faltas --------*/        

	if  _nHrs994 > 0
		_nValPdr438 := 0 
		_nHrsPdr438 := 0
		_nValPdr409 := 0
		_nHrsPdr409 := 0         
		if _cTipo = '005' .AND. MONTH(SRA->RA_VCTEXP2) == MONTH(ddatabase) .AND. year(SRA->RA_VCTEXP2) == YEAR(DDATABASE)
			_nValPdr438 :=	((_nHrs994/30)* day(SRA->RA_VCTEXP2))*(((SRA->RA_SALEXPE+_nVal105+_nVal106+_nVal108)/SRA->RA_HRSMES))
			_nHrsPdr438 :=	((_nHrs994/30)* day(SRA->RA_VCTEXP2))
			fGeraVerba("438",_nValPdr438,_nHrsPdr438,,,"V","I",,,,.T.)
		endif
		_nValPdr409  :=	(_nHrs994-_nHrsPdr438)*(((SRA->RA_SALARIO+_nVal105+_nVal106+_nVal108+_nVlAdcHr1)/SRA->RA_HRSMES))
		_nHrsPdr409  :=	 _nHrs994-_nHrsPdr438
		fGeraVerba("409",_nValPdr409,_nHrsPdr409,,,"H","E",,,,.T.)
		//fgeraverba("409",fbuscapd("994"),fbuscapd("994","h"),,,,,,,,.t.)

	endif 


	/*------- Hora Extra 50% --------*/        

	if  _nHrs996 > 0
		_nValPdr192 := 0 
		_nHrsPdr192 := 0
		_nValPdr136 := 0
		_nHrsPdr136 := 0  
		if _cTipo = '005' .AND. MONTH(SRA->RA_VCTEXP2) == MONTH(ddatabase) .AND. year(SRA->RA_VCTEXP2) == YEAR(DDATABASE)
			_nValPdr192 :=	((_nHrs996/30)* day(SRA->RA_VCTEXP2))*(((SRA->RA_SALEXPE+_nVal105+_nVal106+_nVal108)/SRA->RA_HRSMES)*1.5)
			_nHrsPdr192 :=	((_nHrs996/30)* day(SRA->RA_VCTEXP2))
			fGeraVerba("192",_nValPdr192,_nHrsPdr192,,,"V","I",,,,.T.)
		endif

		_nValPdr136  :=	(_nHrs996-_nHrsPdr192)*(((SRA->RA_SALARIO+_nVal105+_nVal106+_nVal108+_nVlAdcHr1)/SRA->RA_HRSMES)*1.5)
		_nHrsPdr136 :=	 _nHrs996-_nHrsPdr192
		fGeraVerba("136",_nValPdr136,_nHrsPdr136,,,"H","E",,,,.T.)
		//fgeraverba("136",fbuscapd("996"),fbuscapd("996","h"),,,,,,,,.t.)
	endif


	/*------- Adicional Noturno --------*/        

	if  _nHrs991 > 0
		_nValPdr118 := 0 
		_nHrsPdr118 := 0
		_nValPdr110 := 0
		_nHrsPdr110 := 0
		if _cTipo = '005' .AND. MONTH(SRA->RA_VCTEXP2) == MONTH(ddatabase) .AND. year(SRA->RA_VCTEXP2) == YEAR(DDATABASE)
			_nValPdr118 :=	((_nHrs991/30)* day(SRA->RA_VCTEXP2))*(((SRA->RA_SALEXPE+_nVal105+_nVal106+_nVal108)/SRA->RA_HRSMES)*0.2)
			_nHrsPdr118 :=	((_nHrs991/30)* day(SRA->RA_VCTEXP2))
			fGeraVerba("118",_nValPdr118,_nHrsPdr118,,,"V","I",,,,.T.)
		endif
		_nValPdr110 :=	(_nHrs991-_nHrsPdr118)*(((SRA->RA_SALARIO+_nVal105+_nVal106+_nVal108+_nVlAdcHr1)/SRA->RA_HRSMES)*0.2)
		_nHrsPdr110 :=	 _nHrs991-_nHrsPdr118	 
		fGeraVerba("110",_nValPdr110,_nHrsPdr110,,,"H","E",,,,.T.)
		//fgeraverba("110",fbuscapd("991"),fbuscapd("991","h"),,,,,,,,.t.)  
	endif

	/*------- Salário Mensal --------*/        

	_nValPdr090 := 0
	_nHrsPdr090 := 0
	_nValPdr091 := 0
	_nHrsPdr091 := 0  

	if  MONTH(SRA->RA_VCTEXP2) == MONTH(ddatabase) .AND. year(SRA->RA_VCTEXP2) == YEAR(ddatabase)
		_nValPdr091 :=	fBuscaPD("090")
		_nValPdr090 :=	fBuscaPD("091")                 

		if !empty(_nValPdr091) .AND. !empty(_nValPdr090)	
			fDelPD("091")   // deletar verba  		
			fDelPD("090")
		endif


		// verificação do dia para não ser maior que 30
		if day(SRA->RA_VCTEXP2) > 30
			_nDias := 30
		else
			_nDias := day(SRA->RA_VCTEXP2)
		endif
		_nValPdr090 :=	(_nDias)*(((SRA->RA_SALEXPE)/30))
		_nHrsPdr090	:=	_nDias

		fGeraVerba("090",_nValPdr090,_nHrsPdr090,,,"V","I",,,,.T.)

		_nValPdr091 :=	(30 -_nHrsPdr090)*(((SRA->RA_SALARIO)/30))
		_nHrsPdr091 :=	 30 -_nHrsPdr090  

		fGeraVerba("091",_nValPdr091,_nHrsPdr091,,,"V","I",,,,.T.)

		fDelPD("101")   // deletar verba 101

	endif           


	if empty(_nValPdr091)
		fGeraVerba("101",_nVal910,_nHrs910,,,"D","C",,,,.T.)  	
		fDelPD("090")   // deletar verba 101

	endif

RETURN 
