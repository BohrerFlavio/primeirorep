#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF52      º Autor Flavio	 Bohrer 	    º Data ³  02/08/10º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³				   				     			              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ativo Conferência tabela ZB2                               º±±
±±º          ³ Seu objetivo é Visualizar Baixas de Bens com crédito de    º±±
±±º          ³                      PIS/COFINS fração                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF52()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := " "
	Local cDesc2         := " "
	Local cDesc3         := " "
	Local cPict          := ""
	Local titulo         := "Baixa de Créditos de PIS/COFINS fração "
	Local nLin           := 80
	Local Cabec1         := "  "
	Local Cabec2         := "  "
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "FBF52" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "FBF52"
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "FBF52" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _nT1          :=0
	Private _nT2          :=0
	Private _nT3          :=0
	Private _nT4          :=0
	Private _nT5          :=0
	Private _nT6          :=0
	Private _nT7          :=0 
	Private _nTT1         :=0
	Private _nTT2         :=0
	Private _nTT3         :=0
	Private _nTT4         :=0
	Private _nTT5         :=0
	Private _nTT6         :=0
	Private _nTT7         :=0
	Private cString 	  := "ZB2"
	Private cQuery 		  := ""  
	Private _cContaC	  := ""
	Private _ncont		  := 0
	Private _cDContaC	  := ""
	Private _dDtBaixa	  := ""

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZB2',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT ZB2_CBASE AS CODIGO, ZB2_ITEM AS ITEM, ZB2_DESCRI AS DESCRICAO,    "
	cQuery += " 		  N3_CCONTAB AS CONTAC,N3_CUSTBEM AS CUSTBEM,N3_DTBAIXA AS BAIXA, "
	cQuery += " 		 ZB2_MESCPI AS MESCPI, ZB2_VLAQUI AS VLAQUI, ZB2_VLPIST AS VLPIST,"
	cQuery += " 		 ZB2_VLCOFT AS VLCOFT, ZB2_VLRPIS AS VLRPIS, ZB2_VLRCOF AS VLRCOF, "
	cQuery += " 		 ZB2_PCRED AS PCRED, ZB2_SLDPIS AS SLDPIS, ZB2_SLDCOF  AS SLDCOF, 	"
	cQuery += " 		 ZB2_SLDTOT AS SLDTOT, ZB2_AQUISI AS AQUISI   "
	cQuery += "FROM  ZB2010, SN3010, ZB3010 "
	cQuery += "WHERE ZB2010.D_E_L_E_T_ <> '*' "
	cQuery += "       AND ZB3010.D_E_L_E_T_ <> '*'"
	cQuery += "       AND SN3010.D_E_L_E_T_ <> '*'" 
	cQuery += "       AND ZB2_FILIAL 	= '" + xfilial('ZB2') + "'  AND ZB3_FILIAL = '" + xfilial('ZB3') + "'"   
	cQuery += "       AND N3_FILIAL 	= '" + xfilial('SN3') + "'"
	cQuery += "       AND ZB2_CBASE 	= ZB3_CBASE "	
	cQuery += "       AND ZB2_ITEM 		= ZB3_ITEM "
	cQuery += "       AND ZB2_CBASE 	= N3_CBASE "	
	cQuery += "       AND ZB2_ITEM 		= N3_ITEM "
	cQuery += "       AND (N3_DTBAIXA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' ) "  
	cQuery += "ORDER BY N3_CCONTAB, ZB2_AQUISI, ZB2_CBASE, ZB2_ITEM "

	cQuery := ChangeQuery(cQuery)

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

	Cabec1       	:= "NºPatrim.   Item  PT / PC    Base           Tot.Pis      Tot.Cof         VLR Pis        VLR Cof      SLD Pis        SLD Cof"
	Cabec2       	:= "  C.Custo    Descrição             Data       DT.Baixa"


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	AT1->(SetRegua(RecCount()))
	AT1->(dbGoTop())       



	_cContaC := ""
	do While AT1->(!EOF())  

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
		//          arrumar a data da baixa		
		_dDtBaixa  := fbuscaCPO('SN3',1,xfilial('SN3')+AT1->CODIGO+AT1->ITEM,'N3_DTBAIXA')
		@nlin,43  psay _dDtBaixa  
		_nT1 := _nT1+AT1->VLAQUI
		_nT2 := _nT2+AT1->VLPIST
		_nT3 := _nT3+AT1->VLCOFT
		_nT4 := _nT4+AT1->VLRPIS
		_nT5 := _nT5+AT1->VLRCOF
		_nT6 := _nT6+AT1->SLDPIS
		_nT7 := _nT7+AT1->SLDCOF         
		nlin++  

		AT1->(dbSkip()) 
	EndDo  


	If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif 

	nlin++


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


	@nLin,01  Psay "Total Geral:"
	@nlin,22  psay transform(_nTT1,'@E 999,999,999.99')
	@nlin,37  psay alltrim(transform(_nTT2,'@E 999,999,999.99'))
	@nlin,52  psay alltrim(transform(_nTT3,'@E 999,999,999.99'))
	@nlin,67  psay alltrim(transform(_nTT4,'@E 999,999,999.99'))
	@nlin,82  psay alltrim(transform(_nTT5,'@E 999,999,999.99'))   
	@nlin,97  psay alltrim(transform(_nTT6,'@E 999,999,999.99'))
	@nlin,112 psay alltrim(transform(_nTT7,'@E 999,999,999.99')) 


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
