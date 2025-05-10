#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF154  ºAutor  ³Giuliano Forgiarini   º Data ³  25/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao de Arquivo de conciliação de estoque LogFrio - SP  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

User Function GJF154()
	Private _aTexto := {}
	Private _cTexto := ''
	Private cIPerg  := "GJF154"
	Private _lOk := .t.

	if !pergunte(cIPerg,.t.)
		return
	endif

	u_gjf153(ddatabase-1)

	if _lOk
		Processa({||Listar()},"LISTAGEM DE DADOS","Realizando seleção dos dados..." )        
	endif
	if _lOk
		Processa({||Gerar() },"GERAÇÃO DE ARQUIVO","Realizando geração de arquivo..." )   
	endif
Return

Static Function Listar()		

	if !_lOk
		return
	endif

	//Identificação

	DbSelectArea('SB1')
	SB1->(DbSetOrder(2))  
	SB1->(DbGoTop())
	SB1->(DbSeek(xfilial('SB1')+'PA'))                    

	_nQuant := 0    

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  Contagem() })

	ProcRegua(_nQuant)

	_Identificador := padr('REG_CLI',10,'')
	_CNPJ     		:= padr(alltrim(SM0->M0_CGC),14,'')
	_Data_Arq 		:= alltrim(strzero(day(DdataBase),2)) + alltrim(strzero(month(DdataBase),2)) + alltrim(str(year(DdataBase)))

	_cTexto := _Identificador + _CNPJ + _Data_Arq
	Aadd(_aTexto,_cTexto)

	//Para Saldo do dia anterior		
	SB1->(DbGoTop())
	SB1->(DbSeek(xfilial('SB1')+'PA'))                    

	while SB1->(!eof()) .and. SB1->B1_FILIAL = xfilial('SB1') .and. (SB1->B1_TIPO $ 'PA/PR')

		incproc('Listando saldo anterior do produto ' + SB1->B1_COD)

		if !(SB1->B1_TIPO $ 'PA/PR')
			SB1->(DbSkip())
			loop
		endif

		if SB1->B1_MSBLQL = '1'
			SB1->(DbSkip())
			loop
		endif

		_nSldPrim  := 0
		_nSldSegu  := 0

		//Saldo do início do dia (saldo do dia anterior)

		ZZN->(DbSetOrder(2)) 
		if ZZN->(DbSeek(xfilial('ZZN') + dtos(ddatabase-1) + SB1->B1_COD)) 	   
			_nSldPrim := ZZN->ZZN_QTCAIX
			_nSldSegu := ZZN->ZZN_QTPESO  	 	   

			_Identificador   := padr('REG_EST',10,'')
			_Cod_Produto     := padr(alltrim(ZZN->ZZN_COD),20,'')   
			_Qtde_Volumes    := cValToChar(strzero(_nSldPrim * 10000,12)) 
			_Qtde_Fracionado := cValToChar(strzero(_nSldSegu * 10000,12))
			_Qtde_Peso 		  := cValToChar(strzero(_nSldSegu * 10000,12))

			_cTexto := _Identificador + _Cod_Produto + _Qtde_Volumes + _Qtde_Fracionado + _Qtde_Peso
			Aadd(_aTexto,_cTexto)  
		endif    

		SB1->(DbSkip())

	EndDo

	//Para Entradas 

	ProcRegua(_nQuant)

	SB1->(DbGoTop())
	SB1->(DbSeek(xfilial('SB1')+'PA'))                    

	while SB1->(!eof()) .and. SB1->B1_FILIAL = xfilial('SB1') .and. (SB1->B1_TIPO $ 'PA/PR')

		incproc('Listando entradas do produto ' + SB1->B1_COD)

		if !(SB1->B1_TIPO $ 'PA/PR')
			SB1->(DbSkip())
			loop
		endif

		if SB1->B1_MSBLQL = '1'
			SB1->(DbSkip())
			loop
		endif

		If Select("ENT")<>0
			ENT->(dbCloseArea())
		Endif

		//Calcula quantidade de entrada 
		cQuery2 := "SELECT SUM(D2_QUANT) AS QUANT_ENT, SUM(D2_QTSEGUM) AS QTSEGUM_ENT FROM " + RetSQLTab('SD2') + " WHERE " + RetSQLFil('SD2') + " AND "
		cQuery2 += " D2_CLIENTE = '011150' AND D2_LOJA = '01' AND  D2_EMISSAO = '" + DTOS(ddatabase) + "' AND "
		cQuery2 += " D2_TES IN ('608','627')  AND D2_COD = '" + SB1->B1_COD + "' AND " + RetSQLDel('SD2')

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		cQuery2 := ChangeQuery(cQuery2)
		TCQUERY cQuery2 NEW ALIAS "ENT"

		_nEntrada1 := 0
		_nEntrada2 := 0

		//Entrada do dia	
		dbSelectarea('ENT')
		_nEntrada1 := ENT->QUANT_ENT
		_nEntrada2 := ENT->QTSEGUM_ENT

		_Identificador2 	:= padr('REG_ENT',10,'')
		_Cod_Produto2   	:= padr(alltrim(SB1->B1_COD),20,'')   
		_Qtde_Volumes2  	:= strzero(_nEntrada2 * 10000,12)
		_Qtde_Fracionad2  := strzero(_nEntrada1 * 10000,12)
		_Qtde_Peso2		   := strzero(_nEntrada1 * 10000,12)

		if !empty(_nEntrada1) .and. !empty(_nEntrada2)
			_cTexto := _Identificador2 + _Cod_Produto2 + _Qtde_Volumes2 + _Qtde_Fracionado2 + _Qtde_Peso2
			Aadd(_aTexto,_cTexto)
		endif

		SB1->(DbSkip())

	EndDo

	//Para Saídas
	SB1->(DbGoTop())
	SB1->(DbSeek(xfilial('SB1')+'PA'))                    

	ProcRegua(_nQuant)

	while SB1->(!eof()) .and. SB1->B1_FILIAL = xfilial('SB1') .and. (SB1->B1_TIPO $ 'PA/PR')

		incproc('Listando saídas do produto ' + SB1->B1_COD)

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

		//Calcula quantidade de saída
		cQuery1 := "SELECT SUM(D1_QUANT) AS QUANT_SAI FROM " + RetSQLTab('SD1') + " WHERE " + RetSQLFil('SD1') + " AND "
		cQuery1 += " D1_FORNECE = '011150' AND D1_LOJA = '01' AND  D1_EMISSAO = '" + DTOS(ddatabase) + "' AND "
		cQuery1 += " D1_TES IN ('160','177')  AND D1_COD = '" + SB1->B1_COD + "' AND " + RetSQLDel('SD1')

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		cQuery1 := ChangeQuery(cQuery1)
		TCQUERY cQuery1 NEW ALIAS "SAI"

		_nSaida1   := 0
		_nSaida2   := 0

		dbSelectarea('SAI')
		_nSaida1   := SAI->QUANT_SAI
		_nSaida2   := round(_nSaida1/SB1->B1_PMCAIX,0)
		if  _nSaida1 <> 0 
			_lOk := .t.	
		endif

		_Identificador3 	:= padr('REG_SAI',10,'')
		_Cod_Produto3   	:= padr(alltrim(SB1->B1_COD),20,'')   
		_Qtde_Volumes3  	:= strzero(_nSaida2 * 10000,12)
		_Qtde_Fracionad3  := strzero(_nSaida1 * 10000,12)
		_Qtde_Peso3		   := strzero(_nSaida1 * 10000,12)

		if !empty(_nSaida1) //.and. !empty(_nSaida2)
			_cTexto := _Identificador3 + _Cod_Produto3 + _Qtde_Volumes3 + _Qtde_Fracionado3 + _Qtde_Peso3
			Aadd(_aTexto,_cTexto)
		endif   

		SB1->(DbSkip())

	EndDo

Return

//Função destinada a gerar o txt 
//com base no vetor criado
Static Function Gerar()

	Local nTamLin, cLin, cCpo 
	Local _x
	Private cString  := ""
	//Unid|Diret|tipo | |   Data  | |Doc+Serie| |  Sequencial
	Private cArqTxt := alltrim(mv_par01)
	Private nHdl    := fCreate(cArqTxt)
	Private cEOL    := "CHR(13)+CHR(10)"

	if !_lOk
		return
	endif

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif 

	cCpo 	:= ""  

	For _X := 1 to Len(_aTexto)
		cCpo  := _aTexto[_X]+cEOL
		fWrite(nHdl,cCpo,Len(cCpo))
	Next 

	fClose(nHdl)

	msgbox('Arquivo gerado com sucesso!','FIM DE PROCESSAMENTO','INFO')

Return    

Static Function Contagem()
	while SB1->(!eof()) .and. SB1->B1_FILIAL = xfilial('SB1') .and. (SB1->B1_TIPO $ 'PA/PR')
		_nQuant++
		SB1->(DbSkip())
	enddo
return
