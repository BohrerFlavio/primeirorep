#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR45     ºAutor  ³ Mauricio Roehrs    º Data ³  10/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa desenvolvido com a finalidade de calcular a verba º±±
±±º          ³  de gratificação para a folha de pagamento com base no     º±±
±±º          ³  historico de salario do funcionario add no roteiro 761    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MLR45()        

/*  Dia 03/06/19 - Desabilitei o bloco abaixo para testar p cálculo dos 6% Vale transporte

	//tratar a gratificação de função para folha de pagamento                         	
	if SRA->RA_GRATIFG > 0 .and. SRA->RA_GRATIFG <= 1 //para garantir que o valor do campo seja 1

		SR3->(dbSetOrder(2))
		SR3->(dbGoTop())
		if SR3->(dbSeek(xFilial('SR3') + SRA->RA_MAT))//busca o ultimo salario do funcionario para calcular a gratificação   		
			while SR3->(!eof()) .and. SR3->R3_FILIAL == xFilial('SR3') .and. SRA->RA_MAT == SR3->R3_MAT			

				if MesAno(SR3->R3_DATA) <= MesAno(dDataBase)
					_nSalario := SR3->R3_VALOR * 0.40								
				endif				
				SR3->(dbSkip())
			enddo    	
			//fGeraVerba("185",_nSalario)      

			//caso não tenha encontrado aumento no historico calcula com o salario atual do periodo		
		else       

			//fGeraVerba("185",SALMES * 0.40)
		endif				   	

	else//caso o funcionario faça parte de uma excessão, será calculado em cima da base da gratificação

		//fGeraVerba("185",SRA->RA_GRATIFG * 0.40)

	endif	                

testando o BLoco abaixo 6% Vale transporte
*/
			                
	Local _nPercDesc := fBuscaCpo('SRV',1,xFilial('SRV') + '493','RV_PERC')/*Busca o percentual de desconto no cadastro de verbas*/
	Local _nPercSal  := SRA->RA_SALARIO * (_nPercDesc / 100) /*Calcula 6% do salario*/
	Local _nValATU   := SRA->RA_VALATU /*Valor dos vales-transporte creditados na ATU*/
	local _cMes := ''
	local _nAno := 0

	/*Verificar se verbas foram geradas */
	RGB->(dbSetOrder(1))
	RGB->(dbGoTop())
	if RGB->(dbSeek(xFilial('RGB') + RGB->RGB_MAT))
		while RGB->(!eof()) .and. RGB->RGB_FILIAL == xFilial('RGB') .and.  SRA->RA_MAT = RGB->RGB_MAT
				
				//if RGB->RGB_PD = '409' .or. RGB->RGB_PD = '900' .or. RGB->RGB_PD = '901' 
				if RGB->RGB_PD = '994' .or. RGB->RGB_PD = '900' .or. RGB->RGB_PD = '901'
					/* Fazer o procedimento */	
					// Se Estiverem as verbas 409 , 900 ou 901 geradas então o sistema calcula  6% do salario para descontar do funcionário	
					if FunName() = 'GPEM020'
						
						_cMes	:= substr(dtoc(mv_par09),4,2)
						_nAno	:= year(mv_par09)
		
						ZZQ->(DbSetOrder(1))
						ZZQ->(DbGoTop())
						if ZZQ->(DbSeek(xFilial('ZZQ')+ SRA->RA_MAT +_cMes + alltrim(str(_nAno))))		
							if ZZQ->ZZQ_VLVAL > 0
								if _nPercSal > ZZQ->ZZQ_VLVAL 		
									fGeraVerba("493",ZZQ->ZZQ_VLVAL)		
								else             
									fGeraVerba("493",_nPercSal)			
								endif
							endif
						endif                   
				
					endif
											
				endif				
				RGB->(dbSkip())
				
		enddo
		  
	Endif
	


	
return
