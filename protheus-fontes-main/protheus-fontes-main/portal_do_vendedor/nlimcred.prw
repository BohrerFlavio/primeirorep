#INCLUDE "PROTHEUS.CH"

//calculo do limite de credito
User Function nLimCred(_cli,_lj)
	Local _VlrTit  := 0           //Valor dos titulos
	Local _VlrPP   := 0           //Valor dos pre-pedidos
	Local _LimCre  := 0           //Valor do limite de credito  
	Local _nSaldo  := 0           //Valor do saldo                                       

	_LimCre := fBuscaCPO('SA1',1,xfilial('SA1')+_cli+_lj,'A1_LC')

	dbSelectArea("SE1")
	SE1->(dbSetOrder(8))
	SE1->(DbGotop())
	SE1->(DbSeek(xfilial('SE1')+_cli+_lj+'A'))

	while SE1->(!eof()) .and. SE1->E1_FILIAL = xfilial('SE1') ;
	.and. SE1->E1_CLIENTE = _cli ;
	.and. SE1->E1_LOJA = _lj ;
	.and. SE1->E1_STATUS = 'A'

		if !empty(SE1->E1_BAIXA)
			SE1->(DbSkip())
			loop
		endif

		if SE1->E1_TIPO <> "NF"
			dbskip()
			loop
		endif

		_VlrTit += SE1->E1_SALDO

		SE1->(DbSkip())
	enddo              

	area := getarea()
	DbSelectArea('ZZ4')
	ZZ4->(DbSetOrder(4))
	ZZ4->(DbGoTop()) 
	if ZZ4->(DbSeek(xfilial('ZZ4')+_cli+_lj))

		while ZZ4->(!eof()) .and. xfilial('ZZ4') = ZZ4->ZZ4_FILIAL ;
		.and. ZZ4->ZZ4_CODCLI = _cli ;
		.and. ZZ4->ZZ4_LOJA = _lj 

			if ZZ4->ZZ4_STATUS $ 'E/F/C'
				ZZ4->(DbSkip())
				loop
			endif

			_VlrPP += ZZ4->ZZ4_TOTAL

			ZZ4->(DbSkip())
		enddo   

	endif      

	restarea(area)  

	_nSaldo := _LimCre - (_VlrPP + _VlrTit)

Return _nSaldo
