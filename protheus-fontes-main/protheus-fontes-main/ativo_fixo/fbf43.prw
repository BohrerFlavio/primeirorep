#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF43      º Autor flavio				    º Data ³  02/08/10º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³				   								 			  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ativo Conferência tabela ZB2  -Bohrer                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF43()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este relatório tem por objetivo visualizar os créditos de PIS COFINS/Fração "
	Local cDesc2         := "Para eventuais conferências "
	Local cDesc3         := " "
	Local titulo         := "Crédito Pis/Cofins Fração "
	Local nLin           := 80
	Local Cabec1         := "  "
	Local Cabec2         := "  "
	Local aOrd           := {}

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "FBF43" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "FBF43"
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "FBF43" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _nT1         := 0 
	Private _nT2         := 0
	Private _nT3         := 0
	Private _nT4         := 0
	Private _nT5         := 0
	Private _nT6         := 0
	Private _nT7         := 0 
	Private _nTT1        := 0
	Private _nTT2        := 0
	Private _nTT3        := 0
	Private _nTT4        := 0
	Private _nTT5        := 0
	Private _nTT6        := 0
	Private _nTT7        := 0
	Private cString 	 := "ZB2"
	Private cQuery 		 := ""  
	Private _cContaC	 := ""
	Private _ncont		 := 0
	Private _cDContaC	 := ""    
	Private _nSLPARC	 := '00' 
	Private _nSCPrazoP   := 0 
	Private _nSLPrazoP   := 0 
	Private _nSCPrazoC   := 0 
	Private	_nSLPrazoC   := 0 

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZB2',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cPer 		:= DTOS(MV_PAR01)    
	_cPeriodo	:= SUBSTR(_cPer,1,6)  
	_nYear 		:= year(MV_PAR01)
	//_dDataini	:= year(STOD('20110630'))

	if mv_par04 = 1 .AND. !Empty(_cPer)  	// Analítico   Buscando por período fixo

		cQuery := " SELECT ZB2_CBASE AS CODIGO, ZB2_ITEM AS ITEM, ZB2_DESCRI AS DESCRICAO,"
		cQuery += " 	   ZB3_PERIOD AS PERIODO, N3_CCONTAB AS CONTAC,N3_CUSTBEM AS CUSTBEM, N3_BAIXA AS BAIXA,"
		cQuery += " 	   ZB2_MESCPI AS MESCPI, ZB2_VLAQUI AS VLAQUI, ZB2_VLPIST AS VLPIST,"
		cQuery += " 	   ZB2_VLCOFT AS VLCOFT, ZB2_VLRPIS AS VLRPIS, ZB2_VLRCOF AS VLRCOF,"
		cQuery += " 	   ZB3_PARCEL AS PCRED, ZB3_SLDPIS AS SLDPIS, ZB3_SLDCOF  AS SLDCOF,"
		cQuery += " 	   ZB2_SLDTOT AS SLDTOT, ZB2_AQUISI AS AQUISI,ZB2_PCRED AS PCRED2"
		cQuery += "   FROM ZB2010, SN3010, ZB3010 "
		cQuery += "  WHERE ZB2010.D_E_L_E_T_ <> '*' "
		cQuery += "    AND ZB3010.D_E_L_E_T_ <> '*'"
		cQuery += "    AND SN3010.D_E_L_E_T_ <> '*'" 
		cQuery += "    AND ZB2_FILIAL = '" + xfilial('ZB2') + "'  AND ZB3_FILIAL = '" + xfilial('ZB3') + "'"   
		cQuery += "    AND N3_FILIAL = '" + xfilial('SN3') + "'"
		cQuery += "    AND ZB2_CBASE = ZB3_CBASE "	
		cQuery += "    AND ZB2_ITEM = ZB3_ITEM "
		cQuery += "    AND ZB2_CBASE = N3_CBASE "	
		cQuery += "    AND ZB2_ITEM = N3_ITEM "
		cQuery += "    AND N3_BAIXA = '0' "
		cQuery += "    AND (ZB2_AQUISI BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "' ) "  
		cQuery += "    AND ZB3_PERIOD = '" + _cPeriodo + "'"   
		cQuery += "  ORDER BY N3_CCONTAB, ZB2_AQUISI, ZB2_CBASE, ZB2_ITEM, N3_BAIXA "

	elseif  mv_par04 = 2 

		cQuery := " SELECT N3_CUSTBEM AS CUSTBEM ,sum( ZB2_VLAQUI) AS BASE,"
		cQuery += "	       sum( ZB2_VLPIST) AS PIST ,sum( ZB2_VLCOFT) AS COFT," 
		cQuery += "        sum( ZB2_VLRPIS) AS VLRPIS ,sum( ZB2_VLRCOF) AS VLRCOF,"
		cQuery += "        sum( ZB3_SLDPIS) AS SLDPIS ,sum( ZB3_SLDCOF) AS SLDCOF,"
		cQuery += "        CTT_DESC01 AS DESCCC "
		cQuery += "   FROM ZB2010, SN3010, ZB3010, CTT010 "
		cQuery += "  WHERE ZB2010.D_E_L_E_T_ <> '*' "
		cQuery += "    AND ZB3010.D_E_L_E_T_ <> '*' "
		cQuery += "    AND SN3010.D_E_L_E_T_ <> '*' "   
		cQuery += "    AND CTT010.D_E_L_E_T_ <> '*' " 
		cQuery += "    AND ZB2_FILIAL = '" + xfilial('ZB2') + "'  AND ZB3_FILIAL  = '" + xfilial('ZB3') + "'"   
		cQuery += "    AND N3_FILIAL = '" + xfilial('SN3') + "'  AND CTT_FILIAL 	= '" + xfilial('CTT') + "'"
		cQuery += "    AND ZB2_CBASE = ZB3_CBASE AND ZB2_ITEM = ZB3_ITEM  "
		cQuery += "	   AND ZB2_CBASE =  N3_CBASE AND ZB2_ITEM =  N3_ITEM "
		cQuery += "	   AND N3_CUSTBEM = CTT_CUSTO "	
		cQuery += "	   AND (ZB2_AQUISI BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "' ) "
		cQuery += "	   AND ZB3_PERIOD = '" + _cPeriodo + "' "  
		cQuery += "  GROUP BY N3_CUSTBEM, CTT_DESC01 "
		cQuery += "  ORDER BY N3_CUSTBEM"

	endif	 

	cQuery := ChangeQuery(cQuery)
	
	//memowrite("ZZZ_FBF43.TXT",cQuery)

	If Select("AT1") != 0
		AT1->(dbCloseArea())
	Endif
	
	TCQUERY cQuery NEW ALIAS "AT1"   


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Titulo += "Perído: ** " +DTOC(mv_par01)+" **"  

	Cabec1 := "NºPatrim.   Item  PT / PC    Base           Tot.Pis      Tot.Cof         VLR Pis        VLR Cof      SLD Pis        SLD Cof"
	Cabec2 := "  C.Custo    Descrição             Data"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AT1->(SetRegua(RecCount()))
	AT1->(dbGoTop())       

	_cContaC := ""
	Do While AT1->(!EOF())  

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif 

		If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...

			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		//alert(AT1->CODIGO+' '+AT1->ITEM)
		//alert(_cPeriodo)
		//alert(SUBSTR(AT1->PERIODO,1,6))
		// _cPeriodo  = SUBSTR(DTOS(AT1->PERIODO DTOS))

		if mv_par04 = 1    
			if _cContaC != AT1->CONTAC 
				IF _nT1 > 0  .and. _nT2 > 0    

					nlin++ 
					@nLin,01  Psay "Tot.Conta C :"				
					@nlin,22  psay transform(_nT1,'@E 999,999,999.99')
					@nlin,37  psay alltrim(transform(_nT2,'@E 999,999,999.99'))
					@nlin,52  psay alltrim(transform(_nT3,'@E 999,999,999.99'))
					@nlin,67  psay alltrim(transform(_nT4,'@E 999,999,999.99'))
					@nlin,82  psay alltrim(transform(_nT5,'@E 999,999,999.99'))   
					@nlin,97  psay alltrim(transform(_nT6,'@E 999,999,999.99'))
					@nlin,112 psay alltrim(transform(_nT7,'@E 999,999,999.99'))
					_nTT1 += _nT1
					_nTT2 += _nT2
					_nTT3 += _nT3
					_nTT4 += _nT4
					_nTT5 += _nT5
					_nTT6 += _nT6
					_nTT7 += _nT7
					_nT1  := 0
					_nT2  := 0
					_nT3  := 0
					_nT4  := 0
					_nT5  := 0
					_nT6  := 0
					_nT7  := 0  			
					nLin++
					nLin++         

					If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
					Endif   

				ENDIF	

				_cDContaC := fbuscaCPO('CT1',1,xfilial('CT1')+AT1->CONTAC,'CT1_DESC01') 

				@nlin,00  psay AT1->CONTAC
				@nlin,17  psay _cDContaC

				_cContaC := AT1->CONTAC 

				nLin++  

				If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif 

			endif   
			// linha 1

			If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			@nlin,00  psay AT1->CODIGO+' '+AT1->ITEM  	   	
			@nlin,16  psay AT1->MESCPI
			@nlin,19  psay AT1->PCRED 	   
			@nlin,22  psay transform(AT1->VLAQUI,'@E 999,999,999.99')
			@nlin,37  psay transform(AT1->VLPIST,'@E 999,999,999.99')
			@nlin,52  psay transform(AT1->VLCOFT,'@E 999,999,999.99')
			@nlin,67  psay transform(AT1->VLRPIS,'@E 999,999,999.99')	  
			@nlin,82  psay transform(AT1->VLRCOF,'@E 999,999,999.99')   
			@nlin,97  psay transform(AT1->SLDPIS,'@E 999,999,999.99')
			@nlin,112 psay transform(AT1->SLDCOF,'@E 999,999,999.99')

			If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif   

			nLin++  // linha 2
			@nlin,01  psay AT1->CUSTBEM	 
			@nlin,12  psay substr(AT1->DESCRICAO,1,20) 
			@nlin,33  psay STOD(AT1->AQUISI )


			_nT1 := _nT1+AT1->VLAQUI
			_nT2 := _nT2+AT1->VLPIST
			_nT3 := _nT3+AT1->VLCOFT
			_nT4 := _nT4+AT1->VLRPIS
			_nT5 := _nT5+AT1->VLRCOF
			_nT6 := _nT6+AT1->SLDPIS
			_nT7 := _nT7+AT1->SLDCOF         
			nlin++           

			/*calculo Curto e Longo Prazo*/      
			_nSLPARC := 48 - val(AT1->PCRED)
			_nVSLPARC := _nSLPARC
			/*
			if _nVSLPARC <= 11
			_nSCPrazoP += ((AT1->VLPIST/48)*_nVSLPARC)
			_nSCPrazoC += ((AT1->VLCOFT/48)*_nVSLPARC)

			elseif _nVSLPARC > 11
			_nSCP := 12
			_nSLP := _nVSLPARC-12
			alert(_nSLP)
			_nSCPrazoP += ((AT1->VLPIST/48)*_nSCP) 
			_nSLPrazoP += ((AT1->VLPIST/48)*_nSLP) 
			_nSCPrazoC += ((AT1->VLCOFT/48)*_nSCP) 
			_nSLPrazoC += ((AT1->VLCOFT/48)*_nSLP) 
			endif
			*/
			/* Fim Calculo*/

		elseif mv_par04 = 2

			If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif      

			@nlin,01  psay AT1->CUSTBEM	 
			@nlin,11  psay substr(AT1->DESCCC,1,10)  	   	     
			@nlin,22  psay transform(AT1->BASE,'@E 999,999,999.99')
			@nlin,37  psay transform(AT1->PIST,'@E 999,999,999.99')
			@nlin,52  psay transform(AT1->COFT,'@E 999,999,999.99')
			@nlin,67  psay transform(AT1->VLRPIS,'@E 999,999,999.99')	  
			@nlin,82  psay transform(AT1->VLRCOF,'@E 999,999,999.99')   
			@nlin,97  psay transform(AT1->SLDPIS,'@E 999,999,999.99')
			@nlin,112 psay transform(AT1->SLDCOF,'@E 999,999,999.99')
			_nTT1  += AT1->BASE
			_nTT2  += AT1->PIST
			_nTT3  += AT1->COFT
			_nTT4  += AT1->VLRPIS
			_nTT5  += AT1->VLRCOF
			_nTT6  += AT1->SLDPIS
			_nTT7  += AT1->SLDCOF  
			nlin++
		endif


		AT1->(dbSkip()) 
	EndDo  


	If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif 

	nlin++
	if mv_par04 = 1     

		nlin++ 
		@nLin,03  Psay "Total CC :"
		@nlin,22  psay transform(_nT1,'@E 999,999,999.99')
		@nlin,37  psay alltrim(transform(_nT2,'@E 999,999,999.99'))
		@nlin,52  psay alltrim(transform(_nT3,'@E 999,999,999.99'))
		@nlin,67  psay alltrim(transform(_nT4,'@E 999,999,999.99'))
		@nlin,82  psay alltrim(transform(_nT5,'@E 999,999,999.99'))   
		@nlin,97  psay alltrim(transform(_nT6,'@E 999,999,999.99'))
		@nlin,112 psay alltrim(transform(_nT7,'@E 999,999,999.99'))
		_nTT1 += _nT1
		_nTT2 += _nT2
		_nTT3 += _nT3
		_nTT4 += _nT4
		_nTT5 += _nT5
		_nTT6 += _nT6
		_nTT7 += _nT7
		nLin++
		nLin++  

		If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 
		/*	
		@nLin,01  Psay "Total C.Prazo Pis:"
		@nlin,22  psay transform(_nSCPrazoP,'@E 999,999,999.99')   

		@nLin,37  Psay "Total C.Prazo Cof:"
		@nlin,58  psay transform(_nSCPrazoC,'@E 999,999,999.99')     

		If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
		Endif        

		nLin++ 
		@nLin,01  Psay "Total L.Prazo Pis:"
		@nlin,22  psay transform(_nSLPrazoP,'@E 999,999,999.99') 
		@nLin,37  Psay "Total L.Prazo Pis:"
		@nlin,58  psay transform(_nSLPrazoC,'@E 999,999,999.99')  	 
		*/           

		If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif  

		nLin++
		@nLin,01  Psay "Total Geral:"
		@nlin,22  psay transform(_nTT1,'@E 999,999,999.99')
		@nlin,37  psay alltrim(transform(_nTT2,'@E 999,999,999.99'))
		@nlin,52  psay alltrim(transform(_nTT3,'@E 999,999,999.99'))
		@nlin,67  psay alltrim(transform(_nTT4,'@E 999,999,999.99'))
		@nlin,82  psay alltrim(transform(_nTT5,'@E 999,999,999.99'))   
		@nlin,97  psay alltrim(transform(_nTT6,'@E 999,999,999.99'))
		@nlin,112 psay alltrim(transform(_nTT7,'@E 999,999,999.99')) 



	elseif mv_par04 = 2  

		If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		@nLin,03  Psay "Total Geral:"                    
		@nlin,22  psay alltrim(transform(_nTT1,'@E 999,999,999.99'))
		@nlin,37  psay alltrim(transform(_nTT2,'@E 999,999,999.99'))
		@nlin,52  psay alltrim(transform(_nTT3,'@E 999,999,999.99'))
		@nlin,67  psay alltrim(transform(_nTT4,'@E 999,999,999.99'))
		@nlin,82  psay alltrim(transform(_nTT5,'@E 999,999,999.99'))   
		@nlin,97  psay alltrim(transform(_nTT6,'@E 999,999,999.99'))
		@nlin,112 psay alltrim(transform(_nTT7,'@E 999,999,999.99'))

		// total do sintético
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
