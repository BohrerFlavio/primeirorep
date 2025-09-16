#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR41     ºAutor  ³Mauricio Roehrs     º Data ³  14/01/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Fonte destinado para calculo do desconto dos              º±±
±±º          ³  do vale-transporte dos funcionarios                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MLR41()


	Local _nPercDesc := fBuscaCpo('SRV',1,xFilial('SRV') + '493','RV_PERC')/*Busca o percentual de desconto no cadastro de verbas*/
	Local _nPercSal  := SRA->RA_SALARIO * (_nPercDesc / 100) /*Calcula 6% do salario*/
	Local _nValATU   := SRA->RA_VALATU /*Valor dos vales-transporte creditados na ATU*/
	local _cMes := ''
	local _nAno := 0

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

	/*Se recebe vale-transporte para ATU e não recebe intermunicipal*/

	//if SRA->RA_RECVALE == 'S' .and. SRA->RA_INTMUN != 'S'
	//	if _nPercSal > _nValATU /*Se 6% do salario for maior que o valor integral dos vales, desconta o valor integral dos vales*/
	//		fGeraVerba("493",_nValATU)	
	//	else/*senão desconta somente os 6% do salario*/
	//		fGeraVerba("493",_nPercSal)	
	//	endif
	/*senão se recebe intermunicipal e não recebe vale-transporte para ATU*/
	//elseif SRA->RA_INTMUN == 'S' .and. SRA->RA_RECVALE != 'S'
	//	fGeraVerba("493",_nPercSal)
	//endif

return
