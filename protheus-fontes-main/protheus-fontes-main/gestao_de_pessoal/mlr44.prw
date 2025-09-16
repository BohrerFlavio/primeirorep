#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR44     ºAutor  ³ Mauricio Roehrs    º Data ³  09/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa desenvolvido com a finalidade de calcular  		  º±±
±±º          ³ as verbas 197 e 185 para o Dissidio						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MLR44()                      

	local _nValMin  := GETMV("SI_VALMIN")
	local _nIndc    := GETMV("SI_INDC") 
	local _nSalario := 0                        
	local _nVal105  := 0
	local _nVal106  := 0
	local _nVal108  := 0
	local _nVal185  := 0

	if fbuscapd("101,090,091") == 0
		return
	endif                   

	if fBuscaPd("105,233") > 0 //SRA->RA_INSMED > 0
		_nVal105 := @VAL_SALMIN * 0.20
	endif 
	if fBuscaPd("106") > 0 //SRA->RA_INSMAX > 0
		_nVal106 := @VAL_SALMIN * 0.40
	endif 
	if fBuscaPd("108") > 0 //SRA->RA_PERICUL > 0	
		_nVal108 := fbuscapd("108")
	endif                         

	if fBuscaPd("185") > 0
		_nVal185 := fBuscaPd("185")  
	endif

	//trata verba 197 para dissidio
	if fBuscaPd("197") > 1                                                                                                                                                                  
		//aPd[fLocaliaPd("197"),5] := (((SALMES + _nVal105+_nVal106+_nVal108+_nVal185) / SRA->RA_HRSMES) * fBuscaPD("197","H")) * 1.6
	endif                


	//trata as verbas 121 e 122 se em algum momento da vida do funcionario ele teve aumento				        	
	SR3->(dbSetOrder(1))
	SR3->(dbGoTop())
	if SR3->(dbSeek(xFilial('SR3') + SRA->RA_MAT))   
		while SR3->(!eof()) .and. SR3->R3_FILIAL == xFilial('SR3') .and. SRA->RA_MAT == SR3->R3_MAT			
			if MesAno(SR3->R3_DATA) <= RHH->RHH_DATA								
				_nSalario := SR3->R3_VALOR			
			endif				
			SR3->(dbSkip())
		enddo    	
	endif   

	if cEmpAnt <> '07'	
		if _nSalario == _nValMin
			if fBuscaPd("121") > 0			
				aPd[fLocaliaPd("121"),5] := fBuscaPd("121") * _nIndc
			endif

			if fBuscaPd("122") > 0			
				aPd[fLocaliaPd("122"),5] := fBuscaPd("122") * _nIndc
			endif	
		endif
	elseif cEmpAnt == '07'

		if fBuscaPd("121") > 0			
			aPd[fLocaliaPd("121"),5] := fBuscaPd("121") * _nIndc
		endif

		if fBuscaPd("122") > 0			
			aPd[fLocaliaPd("122"),5] := fBuscaPd("122") * _nIndc
		endif		

	endif	
Return                                 

