#INCLUDE "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SIRHFOR9º Giuliano Forgiarini           Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de Fórmulas Para cálculo da verba 117 do Dissídio   º±±
±±º          ³ 			    											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10 IDE                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION  SIRHFOR8()

	Private _nVal105		:= 0
	Private _nVal106		:= 0
	Private _nValor			:= 0

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

	_nHrs111 := fBuscaPD("111","H")
	_nHrs113 := fBuscaPD("113","H")
	_nHrs136 := fBuscaPD("136","H")
	_nHrs110 := fBuscaPD("110","H")
	_nHrs112 := fBuscaPD("112","H")
	_nHrs115 := fBuscaPD("115","H")
	_nHrs192 := fBuscaPD("192","H")
	_nHrs118 := fBuscaPD("118","H")
	_nHrs117 := fBuscaPD("117","H")
	_nHrs910 := fBuscaPD("910","H")
	_nHrs101 := fBuscaPD("101","H")
	if _nHrs117 <> 0
		aPd[fLocaliaPd("117"),5] :=  ((( ((_nHrs111*(SALMES + _nVal105 + _nVal106)  / SRA->RA_HRSMES) * 1.6)  +;   //verba 111
		((_nHrs113*(SALMES + _nVal105 + _nVal106)  / SRA->RA_HRSMES) * 2.0)  +;   //verba 113
		((_nHrs136*(SALMES + _nVal105 + _nVal106)  / SRA->RA_HRSMES) * 1.5)  +;   //verba 136
		((_nHrs110*(SALMES + _nVal105 + _nVal106)  / SRA->RA_HRSMES) * 0.2)  +;   //verba 110
		iif(SRA->RA_SALEXPE <=ZZM->ZZM_FXVL4F,((_nHrs192*(_nValor+_nVal105+_nVal106)/SRA->RA_HRSMES)*1.5),0)  +;   //verba 192
		iif(SRA->RA_SALEXPE <=ZZM->ZZM_FXVL4F,((_nHrs115*(_nValor+_nVal105+_nVal106)/SRA->RA_HRSMES)*2.0),0)  +;   //verba 115
		iif(SRA->RA_SALEXPE <=ZZM->ZZM_FXVL4F,((_nHrs118*(_nValor+_nVal105+_nVal106)/SRA->RA_HRSMES)*0.2),0)  +;   //verba 118
		iif(SRA->RA_SALEXPE <=ZZM->ZZM_FXVL4F,((_nHrs112*(_nValor+_nVal105+_nVal106)/SRA->RA_HRSMES)*1.6),0)) / ;  //verba 112
		NHrsTrab) * nHrsDesc)
	endif

	if empty(fBuscaPd('091'))
		if  !empty(_nHrs101)    // se existir 101
			aPd[fLocaliaPd("101"),5] := SALMES/30*fBuscaPD("101","H")
		elseif  !empty(fBuscaPd('091'))
			aPd[fLocaliaPd("101"),5] := 0.00

		endif

	else
		fdelpd('101')		
	endif


	if (SRA->RA_ADCINS = "3") .and. (fBuscaPD("126") > 0)

		aPd[fLocaliaPd("126"),5] := (SALMES/30*fBuscaPD("126","H"))+(622/30*0.20*fbuscapd("126","H"))

	elseif (SRA->RA_ADCINS = "4") .and. (fBuscaPD("126") > 0)

		aPd[fLocaliaPd("126"),5] := (SALMES/30*fBuscaPD("126","H"))+(622/30*0.40*fbuscapd("126","H"))

	endif	


RETURN
