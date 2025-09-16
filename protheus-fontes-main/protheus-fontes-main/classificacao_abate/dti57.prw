#INCLUDE "rwmake.ch"                           

/*/                                                                                                            
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI57 	  º Autor ³     Fabian Maurerº Data ³  30/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aviso de Matança Para Produtores                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI57()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio   "
	Local cDesc2         := "apresentando os detalhes das cargas e dos pre-pedidos"
	Local cDesc3         := "de acordo com os parametros informados na rotina     "
	Local cPict          := ""
	Local titulo        
	Local nLin           := 80
	Local Cabec1         := " Seq Num   Codigo     Nome                        Localidade             Categ  Class  Prog.                        Quantidade                "
	Local Cabec2         := " Abt Lote  Produtor   Produtor                    Produtor               Lote   Lote  (s/n)                          Animais                    "
	
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.                                              
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI57" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "DTI57"
	
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI57" // Coloque aqui o nome do arquivo usado para impressao em disco 
	Private _CountAE := 0
	Private _CountOC := 0
	Private _CountOV := 0
	//pergunte(cPerg,.F.)

	titulo := "AO SERVICO DE PRODUTORES DE GADO" + GetMv("MV_NUMIF") + ":  ORDEM DE MATANCA "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                        

	wnrel := SetPrint('SZ4',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ4')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	if empty(alltrim(mv_par01))
		FWAlertError("Número do aviso de matança não informado no parâmetro!", "ERRO!")
		Return
	else
		_dDtMat := GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+alltrim(mv_par01),1)	// Data do aviso de matança
		titulo += transform(alltrim(mv_par01),"@R 99.9999/99") + " (" + DTOC(_dDtMat)+ ")"

		dbSelectArea("SZG")
		dbSetOrder(1)
		SZG->(MsSeek(FWxfilial('SZG')+alltrim(mv_par01)))
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	dbSelectArea('SZ4')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SZ4->(SetRegua(RecCount()))
	SZ4->(dbGoTop())   
	SZ4->(DbSetOrder(3))   //Aviso de Matanca+ordem+lote (C2_FILIAL+C2_NUMAM +STRZERO(C2_ORDEM,3)+C2_LOTE)
	SZ4->(MsSeek(FWxfilial('SZ4')+SZG->ZG_NUMAM))

	While SZ4->(!EOF()) .and. SZ4->Z4_FILIAL = FWxfilial('SZ4') .and. SZ4->Z4_NUMAM = SZG->ZG_NUMAM 

		incregua()   

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		_cNumOR   := GetAdvFVal('SZE','ZE_NUMERO',FWxfilial('SZE') + SZ4->(Z4_NUMAM+Z4_LOTE),2)
		_cCodForn := GetAdvFVal('SZD','ZD_FORNECE',FWxfilial('SZD') + _cNumOR,1)
		_cLojForn := GetAdvFVal('SZD','ZD_LOJA',FWxfilial('SZD') + _cNumOR,1)  		
		_cNomForn := GetAdvFVal('SA2','A2_NOME',FWxfilial('SA2') + _cCodForn + _cLojForn,1)
		_cMunForn := GetAdvFVal('SA2','A2_MUN',FWxfilial('SA2') + _cCodForn + _cLojForn,1) 
		_cCodCat  := GetAdvFVal('SZE','ZE_CATEG',FWxfilial('SZE') + SZ4->(Z4_NUMAM+Z4_LOTE),2)
		_cCAt     := substr(GetAdvFVal('SZ5','Z5_DESC',FWxFilial('SZ5') +_cCodCat,1),1,8)
		_cDescPr  := ''
		_cDescPr  := GetAdvFVal('SZ6','Z6_DESC',FWxFilial('SZ6') + SZ4->Z4_PROGRAM,1)
		_cNumGTA  := GetAdvFVal('SZD','ZD_GTA',FWxfilial('SZD') + _cNumOR,1)
		

		_cNumPed  := GetAdvFVal('SC7','C7_NUM',FWxfilial('SC7') + SZ4->(Z4_NUMAM+Z4_LOTE),25)
		_cNumNF   := GetAdvFVal('SD1','D1_DOC',FWxfilial('SD1') + _cNumPed,22)
		_cNumSR   := GetAdvFVal('SD1','D1_SERIE',FWxfilial('SD1') + _cNumPed,22)

		If nLin > 70
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 10
		Endif
		@nlin,01  psay strzero(SZ4->Z4_ORDEM,3)
		@nlin,06  psay Strzero(VAL(SZ4->Z4_LOTE),3)  
		@nlin,11  psay _cCodForn + '-' + _cLojForn
		@nlin,22  psay substr(_cNomForn,1,25)
		@nlin,50  psay substr(_cMunForn,1,20)  
		@nlin,73  psay _cCat  
		@nlin,82  psay AllTrim(SZ4->Z4_CLASSIF)  
		@nlin,88  psay iif(!empty(_cDescPr),_cDescPr,'')
		i := 1   
		@nlin,94  psay substr(_cNumGTA,i,14)
		i += 14  

		@nlin,110 psay 'N. Animais: ' + transform(SZ4->Z4_QUANT,"@E 999")   
		nlin++
		SZE->(DbSetOrder(5))
		SZE->(MsSeek(FWxFilial('SZE')+SZ4->(Z4_NUMAM+Z4_LOTE),.f.))
		_flagLocal := '' 
		_flagGTA   := ''
		_nQtLocal  := 0
		_cNumamLote := ''
		While SZE->(!Eof()) .AND. SZE->(ZE_NUMAM+ZE_LOTE) == SZ4->(Z4_NUMAM+Z4_LOTE)
			if empty(SZE->ZE_RASTRO)

				if !empty(substr(_cNumGTA,i,14))
					@nlin,93 psay substr(_cNumGTA,i,14)
					i += 14
				endif 

				_cHoraAbt := SZE->ZE_HORA  

				@nlin,107 psay 'Curral: '+ SZE->ZE_LOCAL
				if SZE->ZE_LOCAL = 'AE'
					_CountAE += SZE->ZE_QTD1UM
				elseif SZE->ZE_LOCAL = 'OC'
					_CountOC += SZE->ZE_QTD1UM
				elseif SZE->ZE_LOCAL = 'OV'
					_CountOV += SZE->ZE_QTD1UM
				endif
				@nlin,118 psay transform(SZE->ZE_QTD1UM,'@E 999') 
				@nlin,125 psay _cHoraAbt         
				//Posto em comentário por solicitação da Adriana Freire no dia 24/05/16
				@nlin,065 psay 'Serie/Num. GTA: ' + alltrim(SZE->ZE_SERGTA) + '/' + alltrim(SZE->ZE_GTA)
				@nlin,020 psay 'NF-e/Serie: ' + _cNumNF + '/' + _cNumSR
				nlin++ 
			else  // se existir rastro (rastreado)
				if _flagLocal <> SZE->ZE_LOCAL .and. _FlagGTA <> SZE->ZE_GTA 
					If nLin > 70
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 10
					Endif
					
					_cNumamLote := SZE->ZE_NUMAM+SZE->ZE_LOTE
					_flagLocal  := SZE->ZE_LOCAL
					_flagGTA    := SZE->ZE_GTA
					@nlin,090 psay 'Curral: '+ alltrim(_flagLocal)  
					if SZE->ZE_LOCAL = 'AE'
						_CountAE += SZE->ZE_QTD1UM
					elseif SZE->ZE_LOCAL = 'OC'
						_CountOC += SZE->ZE_QTD1UM
					elseif SZE->ZE_LOCAL = 'OV'
						_CountOV += SZE->ZE_QTD1UM
					endif


					_nQtLocal  := ContaLocal(_flagLocal,_cNumamLote)  
					@nlin,101 psay transform(_nQtLocal,'@E 999') 

					@nlin,121 psay alltrim(_flagGTA)
					nlin++
				endif
			endif
			SZE->(dbskip())

		enddo 
		If nLin > 70
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 10
		Endif

		@nlin,00 psay replicate('-',132)
		nlin++
		SZ4->(dbSkip()) // Avanca o ponteiro do registro no arquivo  

	EndDo
	nlin++
	@nlin,05 psay 'RESUMO DO AVISO:'
	nlin++
	_nlinha := nlin
	nlin := SCateg(_nlinha)
	nlin += 4
	if !empty(SZG->ZG_AUTOR)
		@nlin,02 psay replicate('-',24)
		nlin++
		@nlin,06 psay SZG->ZG_AUTOR
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

Static Function NCurral(clocal)   
	cLocal := substr(clocal,2,1)
	do case
		case clocal = 'A' 
		_cNCur := '01'
		case clocal = 'B'
		_cNCur := '02'
		case clocal = 'C'
		_cNCur := '03'
		case clocal = 'D' 
		_cNCur := '04'
		case clocal = 'E'
		_cNCur := '05'
		case clocal = 'F' 
		_cNCur := '06'
		case clocal = 'G' 
		_cNCur := '07'
		case clocal = 'H'
		_cNCur := '08'
		case clocal = 'I'
		_cNCur := '09'
		case clocal = 'J'
		_cNCur := '10'
		case clocal = 'K'
		_cNCur := '11'
		case clocal = 'L'
		_cNCur := '12'
		case clocal = 'M'
		_cNCur := '13'
		case clocal = 'N' 
		_cNCur := '14'
	endcase
Return _cNCur

Static Function ContaLocal(cLocal,_Local2)    
	cloc := 0
	while SZE->(!eof()) .and. SZE->ZE_LOCAL = clocal   .and. (SZE->ZE_NUMAM+SZE->ZE_LOTE = _Local2)
		cloc++
		SZE->(dbskip())
	enddo
return cloc   

Static Function SCateg(nlin)
	_TotAnim := 0
	nlin++
	SZ5->(DbSetOrder(1)) 
	SZ5->(DbGoTop())
	while SZ5->(!eof()) .and. FWxfilial('SZ5') = SZ5->Z5_FILIAL
		SZE->(DbSetOrder(2))     
		SZE->(MsSeek(FWxfilial('SZE')+SZG->ZG_NUMAM))
		_CountCateg := 0
		while SZE->(!eof()) .and. SZE->ZE_NUMAM = SZG->ZG_NUMAM .and. SZE->ZE_FILIAL = FWxfilial('SZE')
			if SZ5->Z5_COD = SZE->ZE_CATEG
				_CountCateg += SZE->ZE_QTD1UM
			endif
			SZE->(dbskip())
		enddo
		if _CountCateg <> 0
			@nlin,05 psay substr(SZ5->Z5_DESC,1,8)
			@nlin,15 psay " :  " + transform(_CountCateg,'@E 999')  
			_TotAnim += _CountCateg
			nlin++  
		endif  
		SZ5->(dbskip())
	enddo
	@nlin,05 psay 'TOTAL' 
	@nlin,15 psay ' :  ' +  transform(_TotAnim,'@E 999')  

	nlin += 4
	@nlin,05 psay 'ABATE DE EMERGENCIA (AE): ' + transform(_CountAE,'@E 999')  	
	nlin++  
	@nlin,05 psay 'OBITO EM CURRAL (OC)    : ' + transform(_CountOC,'@E 999')  
	nlin++  
	@nlin,05 psay 'OBITO EM VIAGEM (OV)    : ' + transform(_CountOV,'@E 999')  

Return nlin
