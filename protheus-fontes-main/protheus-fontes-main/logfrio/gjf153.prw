#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"         
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF153     ºAutor  ³Giuliano Forgiarini º Data ³  24/09/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para calculo de saldo de estoque  - LogFrio         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ comercial                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF153(_dData)
	Processa({||Calcular(_dData) },"PROCESSAMENTO DE ESTOQUE","Realizando calculo de estoque..." )        
return

Static Function Calcular(_dData)

	DbSelectArea('SB1')
	SB1->(DbSetOrder(2))  
	SB1->(DbGoTop())
	SB1->(DbSeek(xfilial('SB1')+'PA'))                    

	_nQuant := 0    

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  Contagem() })

	ProcRegua(_nQuant)

	SB1->(DbGoTop())
	SB1->(DbSeek(xfilial('SB1')+'PA'))                    

	while SB1->(!eof()) .and. SB1->B1_FILIAL = xfilial('SB1') .and. (SB1->B1_TIPO $ 'PA/PR')

		incproc('Processando produto ' + SB1->B1_COD)

		if !(SB1->B1_TIPO $ 'PA/PR')
			SB1->(DbSkip())
			loop
		endif

		if SB1->B1_MSBLQL = '1'
			SB1->(DbSkip())
			loop
		endif

		If Select("SAI")<>0
			SAI->(dbCloseArea())
		Endif

		If Select("ENT")<>0
			ENT->(dbCloseArea())
		Endif

		//Calcula quantidade de saída
		cQuery1 := "SELECT SUM(D1_QUANT) AS QUANT_SAI FROM " + RetSQLTab('SD1') + " WHERE " + RetSQLFil('SD1') + " AND "
		cQuery1 += " D1_FORNECE = '011150' AND D1_LOJA = '01' AND  D1_EMISSAO <= '" + DTOS(_dData) + "' AND "
		cQuery1 += " D1_TES IN('160','177')  AND D1_COD = '" + SB1->B1_COD + "' AND " + RetSQLDel('SD1')

		//Calcula quantidade de entrada 
		cQuery2 := "SELECT SUM(D2_QUANT) AS QUANT_ENT, SUM(D2_QTSEGUM) AS QTSEGUM_ENT FROM " + RetSQLTab('SD2') + " WHERE " + RetSQLFil('SD2') + " AND "
		cQuery2 += " D2_CLIENTE = '011150' AND D2_LOJA = '01' AND  D2_EMISSAO <= '" + DTOS(_dData) + "' AND "
		cQuery2 += " D2_TES IN ('608','627')  AND D2_COD = '" + SB1->B1_COD + "' AND " + RetSQLDel('SD2')

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		cQuery1 := ChangeQuery(cQuery1)
		TCQUERY cQuery1 NEW ALIAS "SAI"

		cQuery2 := ChangeQuery(cQuery2)
		TCQUERY cQuery2 NEW ALIAS "ENT"

		_nSaida1   := 0
		_nSaida2   := 0
		_nEntrada1 := 0
		_nEntrada2 := 0
		_nSldPrim  := 0
		_nSldSegu  := 0

		dbSelectarea('SAI')
		_nSaida1   := SAI->QUANT_SAI
		_nSaida2   := round(_nSaida1/SB1->B1_PMCAIX,0)

		dbSelectarea('ENT')
		_nEntrada1 := ENT->QUANT_ENT
		_nEntrada2 := ENT->QTSEGUM_ENT

		_nSldPrim  :=  _nEntrada1 - _nSaida1
		_nSldSegu  :=  _nEntrada2 - _nSaida2

		ZZN->(DbSetOrder(2))
		if ZZN->(DbSeek(xfilial('ZZN') + dtos(_dData) + SB1->B1_COD)) 	   
			reclock('ZZN',.f.)
			ZZN->ZZN_QTCAIX  := _nSldSegu
			ZZN->ZZN_QTPESO  := _nSldPrim
			msunlock()
		else 
			if _nSldPrim <> 0 .or. _nSldSegu <> 0
				reclock('ZZN',.t.)     
				ZZN->ZZN_FILIAL  := xfilial('ZZN')
				ZZN->ZZN_COD     := SB1->B1_COD
				ZZN->ZZN_QTCAIX  := _nSldSegu
				ZZN->ZZN_QTPESO  := _nSldPrim
				ZZN->ZZN_DATA    := _dData
				ZZN->ZZN_HORA    := time()
				msunlock()	    
			endif
		endif

		SB1->(DbSkip())
	enddo

return

Static Function Contagem()
	while SB1->(!eof()) .and. SB1->B1_FILIAL = xfilial('SB1') .and. (SB1->B1_TIPO $ 'PA/PR')
		_nQuant++
		SB1->(DbSkip())
	enddo
return
