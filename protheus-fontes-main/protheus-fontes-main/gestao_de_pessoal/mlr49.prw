#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR49     ºAutor  ³ Mauricio Roehrs    º Data ³  10/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa desenvolvido com a finalidade de calcular a verba º±±
±±º          ³  de gratificação para férias com base no					     º±±
±±º          ³  historico de salario do funcionario add no roteiro 761    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MLR49()


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


			//aPd[fLocaliaPd("185"),5] :=(_nSalario/30)*fBuscaPd('126','H')
			//aPd[fLocaliaPd("185"),5] :=(_nSalario/30)*SRH->RH_DFERIAS

			//caso não tenha encontrado aumento no historico calcula com o salario atual do periodo		
		else

			//aPd[fLocaliaPd("185"),5] :=((SALMES * 0.40)/30)*SRH->RH_DFERIAS
		endif				   	

	else//caso o funcionario faça parte de uma excessão, será calculado em cima da base da gratificação

		//aPd[fLocaliaPd("185"),5] :=((SRA->RA_GRATIFG * 0.40)/30)*SRH->RH_DFERIAS

	endif	                

return
