#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR23  ºAutor  ³Mauricio Roehrs  º Data ³  25/09/13  		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Arquivo para Rastreabilidade utilizado com a empresa       º±±
±±º          ³ Paripassu                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial/Qualidade                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

User Function MLR23()
	Private _aTexto 	:= {}
	Private _cTexto 	:= ''
	Private _aTexto2 	:= {}
	Private _cTexto2 	:= ''
	Private cIPerg  	:= "MLR23"
	Private aCampos   := {}
	Private cArq
	Private aStru     := {}
	Private _lOk 		:= .t.

	if !pergunte(cIPerg,.t.)
		return
	endif

	criaArq() //função que cria o arquivo de trabalho

	_cQuery := " SELECT Z2_NUMAM,Z2_NUM,Z2_DTPROD, Z8_NUMPREV, Z8_COD, Z8_DESCRI,Z8_PESO,Z8_CONTROL,C5_NOTA"
	_cQuery += " FROM  " + RetSQLTab('ZZ4') + "  ,  " + RetSQLTab('SZ8') + " , " + RetSQLTab('SZ2') + " , " + RetSQLTab('SC5')
	_cQuery += " WHERE " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('SZ8') + " AND " + RetSQLFil('SZ2') + "AND " + RetSQLFil('SC5')
	_cQuery += " AND Z8_PREDES = Z2_NUM AND Z8_PREPED  = ZZ4_NUM AND ZZ4_NUMPED = C5_NUM 
	_cQuery += " AND ZZ4_CODCLI = '" + mv_par01 + "' AND ZZ4_DATA = '" + dtos(mv_par02) + "'"
	_cQuery += " AND ZZ4_TPOPER = 'V' AND ZZ4_STATUS = 'F'" 
	_cQuery += " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('SZ2') + " AND " + RetSQLDel('SC5')
	_cQuery += " ORDER BY Z2_NUMAM, Z2_NUM

	_cQuery := ChangeQuery(_cQuery)

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })	

	TMP->(DbGoTop())	
	_cPredes := ''
	while TMP->(!eof())

		_cQuery2 := " SELECT ZK_NUMAM, ZK_LOTE, ZK_ORDEM, ZK_CONTROL, ZK_RACA, ZK_SEXO, ZK_DENT, ZK_COBGOR, ZK_PETOTAL,
		_cQuery2 += " Z2_DATAABT, Z2_COD, Z2_DESCRI, Z2_NUM, Z2_DTPROD
		_cQuery2 += " FROM  " + RetSQLTab('SZK') + "  ,  " + RetSQLTab('SZ2')
		_cQuery2 += " WHERE " + RetSQLFil('SZK') + " AND " + RetSQLFil('SZ2')	
		_cQuery2 += " AND ZK_NUMAM  = '" + TMP->Z2_NUMAM + "'"
		_cQuery2 += " AND Z2_NUM    = '" + TMP->Z2_NUM + "'"
		_cQuery2 += " AND " + RetSQLDel('SZK') + " AND " + RetSQLDel('SZ2')
		_cQuery2 += " ORDER BY ZK_NUMAM,ZK_LOTE,ZK_ORDEM,ZK_CONTROL         

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		If Select("TMP2")<>0
			TMP2->(dbCloseArea())
		Endif 

		_cQuery2 := ChangeQuery(_cQuery2)
		TCQUERY _cQuery2 NEW ALIAS "TMP2" 

		if _cPredes <> TMP->Z2_NUM			
			while TMP2->(!eof())		
				reclock('TRB',.t.)

				TRB->NUMAM 		:= TMP2->ZK_NUMAM
				TRB->LOTE  		:= TMP2->ZK_LOTE
				TRB->ORDEM 		:= TMP2->ZK_ORDEM
				TRB->CONTROL   := TMP2->ZK_CONTROL
				TRB->RACA 		:= TMP2->ZK_RACA
				TRB->SEXO 		:= TMP2->ZK_SEXO       
				TRB->DENT		:= TMP2->ZK_DENT
				TRB->COBGOR		:= TMP2->ZK_COBGOR
				TRB->PETOTAL	:= TMP2->ZK_PETOTAL
				TRB->DTABT		:= stod(TMP2->Z2_DATAABT)
				TRB->CODPEC		:= TMP2->Z2_COD
				TRB->DESCPEC	:= TMP2->Z2_DESCRI
				TRB->OPDES		:= TMP2->Z2_NUM
				TRB->DTDES		:= stod(TMP2->Z2_DTPROD)

				msunlock()
				TMP2->(DbSkip())
			enddo
			_cPredes := TMP->Z2_NUM 
		endif
		TMP->(DbSkip())       
	enddo

	//-----------------||----------------------\\  
	if _lOk //lista dados para arquivo de peças
		Processa({||ListPec()},"LISTAGEM DE DADOS","Realizando seleção dos dados de peças..." )        
	endif
	if _lOk //gera arquivo de peças
		Processa({||GerPec() },"GERAÇÃO DE ARQUIVO","Realizando geração de arquivo..." )   
	endif 

	//-----------------||----------------------\\
	if _lOk //lista dados para arquivo de caixas
		Processa({||ListCaix()},"LISTAGEM DE DADOS","Realizando seleção dos dados de caixas..." )        
	endif
	if _lOk //Gera o arquivo de caixas
		Processa({||GerCaix() },"GERAÇÃO DE ARQUIVO","Realizando geração de arquivo..." )   
	endif  		
Return

Static Function ListPec()		

	if !_lOk
		return                                       
	endif

	_nQuant := 0  

	_nreg := 0  

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  Contagem() })

	ProcRegua(_nQuant)

	DbSelectArea('SM0')
	SM0->(DbSetOrder(1))
	_CNPJ := SM0->M0_CGC  

	TRB->(DbGoTop())                                   
	while TRB->(!eof())

		_cRaca      := fBuscaCPO('ZA8',1,xFilial('ZA8') + TRB->RACA,'ZA8_DESC')
		_cNomeProd  := fBuscaCPO('SZ4',1,xFilial('SZ4') + TRB->(NUMAM + LOTE),'Z4_NOME')
		_SZENum     := fBuscaCPO('SZE',2,xFilial('SZE') + TRB->(NUMAM + LOTE),'ZE_NUMERO')                                                                                
		_SZDFornec  := fBuscaCPO('SZD',1,xFilial('SZD') + _SZENum,'ZD_FORNECE')
		_SZDLoja    := fBuscaCPO('SZD',1,xFilial('SZD') + _SZENum,'ZD_LOJA')              
		_cProdRaz   := fBuscaCPO('SA2',1,xFilial('SA2') + _SZDFornec + _SZDLoja,'A2_NOME')
		_cProdNome  := fBuscaCPO('SA2',1,xFilial('SA2') + _SZDFornec + _SZDLoja,'A2_NREDUZ')
		_cPfisica   := fBuscaCPO('SA2',1,xFilial('SA2') + _SZDFornec + _SZDLoja,'A2_TIPO')
		_cCNPJ_Cpf  := fBuscaCPO('SA2',1,xFilial('SA2') + _SZDFornec + _SZDLoja,'A2_CGC')  
		_cUfPropri  := fBuscaCPO('SA2',1,xFilial('SA2') + _SZDFornec + _SZDLoja,'A2_EST')  
		_cMunPropri := fBuscaCPO('SA2',1,xFilial('SA2') + _SZDFornec + _SZDLoja,'A2_MUN')  

		incproc('Listando sequencia de itens para o arquivo... ' + TRB->CONTROL)

		_Identificador := '1;'
		_Numero_Pedido	:= TRB->NUMAM + ';'
		_Data_Abate    := dtoc(TRB->DTABT) + ';'
		_Lote_Abate    := TRB->LOTE + ';'
		_Seq_Abt_Lote	:= cValtoChar(TRB->ORDEM) + ';'
		_Seq_Abt_Dia	:= TRB->CONTROL + ';'
		_Sisbov 			:= ''+';' //space(10) + 
		_Raca 			:= _cRaca + ';'
		_Sexo   			:= iif(TRB->SEXO = 'F', 'FEMEA','MACHO') + ';'
		_Qtd_Dente  	:= TRB->DENT + ';'
		_Id_Banda      := ''+';'
		_Acabamento    := iif(TRB->COBGOR = '1','ESCASSO',iif(TRB->COBGOR = '2','MEDIANA','EXCESSIVA')) + ';'
		_Conformidade  := space(10) + ';' //TIRAR DUVIDA COM PARIPASSU
		_Contusao      := ''+';' //space(10) + 
		_Habilitacao   := 'DIF' + ';'
		_Peso_Carc     := transform(round(TRB->PETOTAL,0),'@E9999') + ';'
		_Ph_Carc			:= ''+';'
		_Data_Desos    := dtoc(TRB->DTDES)  + ';'
		_Lote_Desos 	:= TRB->OPDES + ';'
		_Cod_Quarto		:= TRB->CODPEC + ';'
		_Nome_Quarto 	:= TRB->DESCPEC + ';'
		_Sif_Frigo 		:= '1733' + ';'
		_RazaoSocial   := 'Frigorifico Silva Ind. e Com. LTDA' + ';'
		_Cnpj_Frigo    := _CNPJ + ';'
		_Uf_Frigo		:= 'RS' + ';'
		_Mun_Frigo		:= 'Santa Maria' + ';'
		_Nome_Prod     := _cProdNome + ';'
		_Razao_Soc     := _cProdRaz + ';'
		_CPF_Prod  		:= iif(_cPfisica == 'F',_cCNPJ_Cpf+';',''+';') //space(11)
		_CNPJ_Prod		:= iif(_cPfisica == 'J',_cCNPJ_Cpf+';',''+';') //space(14)
		_Cod_Prod 		:= _SZDFornec + _SZDLoja + ';'
		_Nome_Propri   := ''+';' //space(20) + 
		_Razao_Propri  := ''+';' //space(20) + 
		_Cnpj_Propri   := ''+';' //space(14) +
		_Uf_Propri     := _cUfPropri + ';'
		_Mun_Propri    := _cMunPropri + ';'
		_Cod_Propri    := _SZDLoja 

		_cTexto := _Identificador 			+ alltrim(_Numero_Pedido) 	+ alltrim(_Data_Abate) 	 + alltrim(_Lote_Abate) + alltrim(_Seq_Abt_Lote) 
		_cTexto += alltrim(_Seq_Abt_Dia) + alltrim(_Sisbov) 			+ alltrim(_Raca) 			 + alltrim(_Sexo) 		+ alltrim(_Qtd_Dente)  
		_cTexto += alltrim(_Id_Banda)    + alltrim(_Acabamento) 		+ alltrim(_Conformidade) + alltrim(_Contusao) 	+ alltrim(_Habilitacao)
		_cTexto += alltrim(_Peso_Carc) 	+ alltrim(_Ph_Carc) 			+ alltrim(_Data_Desos) 	 + alltrim(_Lote_Desos) + alltrim(_Cod_Quarto) + alltrim(_Nome_Quarto)
		_cTexto += alltrim(_Sif_Frigo) 	+ alltrim(_RazaoSocial) 	+ alltrim(_Cnpj_Frigo) 	 + alltrim(_Uf_Frigo) 	+ alltrim(_Mun_Frigo) 
		_cTexto += alltrim(_Nome_Prod) 	+ alltrim(_Razao_Soc) 		+ alltrim(_CPF_Prod) 	 + alltrim(_CNPJ_Prod) 	+ alltrim(_Cod_Prod)
		_cTexto += alltrim(_Nome_Propri) + alltrim(_Razao_Propri) 	+ alltrim(_Cnpj_Propri)  + alltrim(_Uf_Propri) 	+ alltrim(_Mun_Propri) + alltrim(_Cod_Propri) 

		Aadd(_aTexto,_cTexto)

		TRB->(DbSkip())

	EndDo
Return  

Static Function ListCaix()		

	if !_lOk
		return
	endif

	_nQuant := 0  

	_nreg := 0  

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  Contagem() })

	ProcRegua(_nQuant)

	DbSelectArea('SM0')
	SM0->(DbSetOrder(1))
	_CNPJ := SM0->M0_CGC  

	TMP->(DbGoTop())                                   
	while TMP->(!eof())

		incproc('Listando sequencia: ' + TMP->Z8_CONTROL + ' para o arquivo...')		


		_Identificador := '2;'
		_Num_Ped			:= alltrim(TMP->Z8_NUMPREV) + ';'
		_Cod_Prod 		:= alltrim(TMP->Z8_COD) + ';'
		_Desc_Prod		:= alltrim(TMP->Z8_DESCRI) + ';'
		_Pes_Liq			:= transform(round(TMP->Z8_PESO,3),"@E 99.999") + ';'
		_Id_Caix			:= alltrim(TMP->Z8_CONTROL) + ';'
		_Dt_Desos		:= dtoc(stod(TMP->Z2_DTPROD))+';' //day(TMP->Z2_DTPROD) + '/' + month(TMP->Z2_DTPROD) + '/' + year(TMP->Z2_DTPROD) + ';'
		_Lote_Deso		:= alltrim(TMP->Z2_NUM) + ';'
		_Sif				:= '1733' + ';'
		_Nota_Fisc		:= alltrim(TMP->C5_NOTA)                                               

		_cTexto2 := _Identificador + _Num_Ped + _Cod_Prod + _Desc_Prod + _Pes_Liq + _Id_Caix + _Dt_Desos + _Lote_Deso + _Sif + _Nota_Fisc

		Aadd(_aTexto2,_cTexto2)

		TMP->(DbSkip())

	EndDo
Return

//Função destinada a gerar o txt 
//com base no vetor criado
Static Function GerPec()

	Local nTamLin, cLin, cCpo 
	Local _x
	Private cString  := ""
	Private cArqTxt := alltrim(mv_par03) + dtos(mv_par02) + "DESOSSA.txt"
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

	msgbox('Arquivo de Desossa gerado com sucesso!','FIM DE PROCESSAMENTO','INFO')

Return                  


Static Function GerCaix()

	Local nTamLin, cLin, cCpo 
	Local _x
	Private cString  := ""
	Private cArqTxt := alltrim(mv_par03) + dtos(mv_par02) + "CAIXA.txt"
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

	For _X := 1 to Len(_aTexto2)
		cCpo  := _aTexto2[_X]+cEOL
		fWrite(nHdl,cCpo,Len(cCpo))
	Next 

	fClose(nHdl)

	msgbox('Arquivo de Caixa gerado com sucesso!','FIM DE PROCESSAMENTO','INFO')

Return    

Static Function Contagem()
	Local _nQuant := 0

	TMP->(DbGoTop())
	while TMP->(!eof())
		_nQuant++
		TMP->(DbSkip())
	enddo
return      

Static Function criaArq()

	_aArqTrb    := {} // inicializa o array do arquivo
	//cArq  := CriaTrab( Nil, .F. )   

	aadd(aCampos,{"NUMAM"   ,"Av. Matanc"	,""})
	aadd(aCampos,{"LOTE"    ,"Lote"       	,""})
	aadd(aCampos,{"ORDEM"   ,"Ordem"		 	,""})
	aadd(aCampos,{"CONTROL" ,"Control"     ,""}) 
	aadd(aCampos,{"RACA" 	,"Raca"      	,""}) 
	aadd(aCampos,{"SEXO" 	,"Sexo"      	,""}) 
	aadd(aCampos,{"DENT" 	,"Dent"      	,""}) 
	aadd(aCampos,{"COBGOR" 	,"CobGor"      ,""}) 
	aadd(aCampos,{"PETOTAL" ,"Peso Total"  ,""}) 
	aadd(aCampos,{"DTABT" 	,"Dt. Abate"   ,""}) 
	aadd(aCampos,{"CODPEC" 	,"Cod. Peca"   ,""}) 	
	aadd(aCampos,{"DESCPEC" ,"Desc. Peca"  ,""}) 	
	aadd(aCampos,{"OPDES" 	,"Op. Desossa" ,""}) 	
	aadd(aCampos,{"DTDES" 	,"Dt. Desossa" ,""}) 	

	aadd(aStru,{"NUMAM" 		, "C",  08, 0,   "@!"          , 'Av. Matanc	'})
	aadd(aStru,{"LOTE"    	, "C",  06, 0,   "@!"          , 'Lote		  	'})
	aadd(aStru,{"ORDEM" 		, "N",  03, 0,   "@!"          , 'Ordem		'})
	aadd(aStru,{"CONTROL"	, "C",  06, 0,   "@!"    		 , 'Control 	'}) 
	aadd(aStru,{"RACA"  		, "C",  08, 0,   "@!"    		 , 'Raca		 	'}) 
	aadd(aStru,{"SEXO"  		, "C",  01, 0,   "@!" 			 , 'Sexo		 	'}) 
	aadd(aStru,{"DENT"  		, "C",  01, 0,   "@!"    		 , 'Dent.	 	'}) 
	aadd(aStru,{"COBGOR"  	, "C",  01, 0,   "@!"    		 , 'Gordura 	'}) 
	aadd(aStru,{"PETOTAL"  	, "N",  09, 2,   "@E99,999.99" , 'Peso Total '}) 
	aadd(aStru,{"DTABT"  	, "D",  08, 0,   "99/99/99"  	 , 'Data Abt. 	'}) 
	aadd(aStru,{"CODPEC"  	, "C",  14, 0,   "@!"    		 , 'Cod. Peca 	'}) 
	aadd(aStru,{"DESCPEC"  	, "C",  20, 0,   "@!"    		 , 'Desc. Peca	'}) 
	aadd(aStru,{"OPDES"  	, "C",  10, 0,   "@!"    		 , 'Op. Desos 	'}) 
	aadd(aStru,{"DTDES"  	, "D",  08, 0,   "99/99/99"    , 'Data Pr. 	'})      


	//dbcreate(cArq,aStru) 
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TRB", aStru, {}, @_aArqTrb)

	If Select('TRB')<>0
		TRB->(dbCloseArea())
	Endif

	//dbUseArea( .T.,,cArq,"TRB", .F. , .F. )

	TRB->(DbGotop())
return

Static Function GeraTMP()   

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"
return      
