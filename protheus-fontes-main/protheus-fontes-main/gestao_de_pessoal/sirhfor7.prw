#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SIRHFOR7º Autor Flávio Bohrer           Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de Fórmulas Para cálculo das horas extras e faltas  º±±
±±º          ³ do Dissídio    											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10 IDE                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/     

USER FUNCTION  SIRHFOR7()
	Private _nValPdr111 	   := 0 
	Private _nValPdr113     := 0
	Private _nValPdr409     := 0
	Private _nValPdr136     := 0
	Private _nValPdr110     := 0
	Private _nValPdr192     := 0 
	Private _nValPdr115		:= 0
	Private _nValPdr118		:= 0 
	Private _nValPdr117     := 0
	Private _nValPdr112		:= 0

	Private _nVal105		:= 0 
	Private _nVal106		:= 0 
	Private _nVal108     := 0
	Private _nValor		:= 0

	_nHrs111 := fBuscaPD("111","H")
	_nHrs112 := fBuscaPD("112","H")
	_nHrs113 := fBuscaPD("113","H")
	_nHrs409 := fBuscaPD("409","H")
	_nHrs136 := fBuscaPD("136","H")
	_nHrs110 := fBuscaPD("110","H")
	_nHrs090 := fBuscaPD("090","H")
	_nHrs091 := fBuscaPD("091","H") 
	_nHrs115 := fBuscaPD("115","H") 
	_nHrs438 := fBuscaPD("438","H") 
	_nHrs192 := fBuscaPD("192","H") 
	_nHrs118 := fBuscaPD("118","H") 
	_nHrs117 := fBuscaPD("117","H") 

	/**********************************/

	_nHrs147 := fBuscaPD("147","H")
	_nHrs155 := fBuscaPD("155","H")
	_nHrs160 := fBuscaPD("160","H")
	_nHrs168 := fBuscaPD("168","H")
	_nHrs169 := fBuscaPD("169","H")
	_nHrs182 := fBuscaPD("182","H")
	_nHrs107 := fBuscaPD("107","V")

	/**********************************/

	_nHrs126 := fBuscaPD("126","H")  
	_nHrs159 := fBuscaPD("159","V")


	DbSelectArea('ZZM')
	ZZM->(DbSetOrder(1))
	ZZM->(dbGoTop())                
	//ZZM->(DbSeek(xfilial('ZZM')+ZZM->ZZM_CODIGO))

	if  SRA->RA_SALEXPE <=ZZM->ZZM_FXVL2F  // valor da ultima faixa utilizada
		if SRA->RA_SALEXPE <= ZZM->ZZM_FXVL1
			_nValor := SRA->RA_SALEXPE+ZZM->ZZM_VALOR1
		elseif SRA->RA_SALEXPE >= ZZM->ZZM_FXVL2  .AND. SRA->RA_SALEXPE <= ZZM->ZZM_FXVL2F
			_nValor := SRA->RA_SALEXPE+ZZM->ZZM_VALOR2
		elseif SRA->RA_SALEXPE >= ZZM->ZZM_FXVL3  .AND. SRA->RA_SALEXPE <= ZZM->ZZM_FXVL3F
			_nValor := SRA->RA_SALEXPE+ZZM->ZZM_VALOR3
		elseif SRA->RA_SALEXPE >= ZZM->ZZM_FXVL4  .AND. SRA->RA_SALEXPE <= ZZM->ZZM_FXVL4F
			_nValor := SRA->RA_SALEXPE+ZZM->ZZM_VALOR4
		elseif SRA->RA_SALEXPE >= ZZM->ZZM_FXVL5  .AND. SRA->RA_SALEXPE <= ZZM->ZZM_FXVL5F
			_nValor := SRA->RA_SALEXPE+ZZM->ZZM_VALOR5
		endif
	endif


	if SRA->RA_ADCINS = "3"
		_nVal105 := @VAL_SALMIN * 0.20
	endif 
	if SRA->RA_ADCINS = "4"
		_nVal106 := @VAL_SALMIN * 0.40
	endif                    
	if SRA->RA_ADCPERI = "2"	
		_nVal108 := SALMES * 0.3 //fbuscapd("108")
	endif


	/********************************/                
	fdelpd('147') 

	fdelpd('155')		

	fdelpd('160')     	

	fdelpd('168') 		

	fdelpd('169') 		

	fdelpd('182') 		

	/********************************/

	/*if _nHrs107 <> 0 .and. SRA->RA_MAT = "005715"
	_nValPdr107 := 42.75 
	aPd[fLocaliaPd("107"),5] := _nValPdr107   

	endif*/

	if _nHrs126 <> 0  
		_nValpdr126 := (SALMES / 30) * _nHrs126
		aPd[fLocaliaPd("126"),5] := _nValPdr126
	endif 



	if _nHrs159 <> 0
		_nValPdr159 := _nHrs159 + (_nHrs159 * 0.09)
		aPd[fLocaliaPd("159"),5] := _nValPdr159			

	endif                              

	if _nHrs111 <> 0 
		_nValPdr111 :=(_nHrs111)*(((SALMES + _nVal105 + _nVal106 + _nVal108) / SRA->RA_HRSMES) * 1.6) 
		aPd[fLocaliaPd("111"),5] := _nValPdr111 	

	endif 

	if _nHrs113 <> 0
		_nValPdr113 :=(_nHrs113)*(((SALMES + _nVal105 + _nVal106 + _nVal108) / SRA->RA_HRSMES) * 2.0) 
		aPd[fLocaliaPd("113"),5] := _nValPdr113
	endif

	if _nHrs409 <> 0      //multiplica no final por (-1) por ser uma verba de desconto
		_nValPdr409 :=((_nHrs409)*(((SALMES + _nVal105 + _nVal106 + _nVal108) / SRA->RA_HRSMES)) ) * (-1)
		aPd[fLocaliaPd("409"),5] := _nValPdr409   

	endif

	if _nHrs136 <> 0 
		_nValPdr136 :=(_nHrs136)*(((SALMES + _nVal105 + _nVal106 + _nVal108) / SRA->RA_HRSMES) * 1.5) 
		aPd[fLocaliaPd("136"),5] := _nValPdr136   
	endif

	if _nHrs110 <> 0  
		_nValPdr110 :=(_nHrs110)*(((SALMES + _nVal105 + _nVal106 + _nVal108) / SRA->RA_HRSMES) * 0.2) 
		aPd[fLocaliaPd("110"),5] := _nValPdr110
	endif 

	if  SRA->RA_SALEXPE <=ZZM->ZZM_FXVL2F      // valor da ultima faixa utilizada
		if _nHrs091 <> 0
			_nValPdr091 :=(_nHrs091)*((SALMES) / 30)
			aPd[fLocaliaPd("091"),5] := _nValPdr091
		endif

		if _nHrs090 <> 0
			_nValPdr090 :=(_nHrs090)*(((_nValor) / 30))
			aPd[fLocaliaPd("090"),5] := _nValPdr090
		endif	

		if _nHrs112 <> 0
			_nValPdr112 :=(_nHrs112)*(((_nValor+_nVal105+_nVal106 + _nVal108)/SRA->RA_HRSMES)*1.6)   		
			aPd[fLocaliaPd("112"),5] := _nValPdr112
		endif
		if _nHrs115 <> 0
			_nValPdr115 :=(_nHrs115)*(((_nValor+_nVal105+_nVal106 + _nVal108)/SRA->RA_HRSMES)*2)
			aPd[fLocaliaPd("115"),5] := _nValPdr115
		endif
		if _nHrs438 <> 0
			_nValPdr438 :=(_nHrs438)*(((_nValor+_nVal105+_nVal106 + _nVal108)/SRA->RA_HRSMES))*(-1)
			aPd[fLocaliaPd("438"),5] := _nValPdr438
		endif
		if _nHrs192 <> 0
			_nValPdr192 :=(_nHrs192)*(((_nValor+_nVal105+_nVal106 + _nVal108)/SRA->RA_HRSMES)*1.5)
			aPd[fLocaliaPd("192"),5] := _nValPdr192
		endif
		if _nHrs118 <> 0
			_nValPdr118 :=(_nHrs118)*(((_nValor+_nVal105+_nVal106 + _nVal108)/SRA->RA_HRSMES)*0.2)
			aPd[fLocaliaPd("118"),5] := _nValPdr118
		endif  
	endif

RETURN 

