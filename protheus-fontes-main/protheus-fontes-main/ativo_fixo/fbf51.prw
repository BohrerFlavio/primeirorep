#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF51   º Autor ³ Flavio Bohrer Flores  º Data ³  28/10/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório Creditos de ICMS sobre Bens            		  º±±
±±º          ³ Ajuste chamado 3146 - dia 09/03/23    					  º±±
±±º          ³   														  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Apoio para conferência no CIAP                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF51()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        	:= "Este programa tem como objetivo imprimir relatorio    "
	Local cDesc2        	:= "de Resultado Do cálculo dos Créditos do CIAP "
	Local cDesc3        	:= ""
	//Local cPict         	:= ""
	Local titulo       		:= "Crédito ICMS sobre Bens AT.Imob - "
	Local nLin         		:= 80
	Local Cabec1       		:= "  Produto    Item   Descrição                 CodCIAP  SP       Vlr.Crédito     Vl.CredPer     Vlr.Aprop       Saldo"
	Local Cabec2       		:= "	                           "
	//Local imprime      		:= .T.
	Local aOrd 				:= {}
	Private lEnd        	:= .F.
	Private lAbortPrint 	:= .F.
	Private limite      	:= 80
	Private Tamanho     	:= "M"
	Private nomeprog    	:= "FBF51" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo      	 	:= 18
	Private aReturn     	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    	:= 0
	Private cPerg      	 	:= "FBF51"
	Private m_pag      		:= 01
	Private wnrel      		:= "FBF51" // Coloque aqui o nome do arquivo usado para impressao em disco       
	Private _dData			
	Private	_cFilial 		:= ""
	Private	_cCodigo        := ""

	pergunte(cPerg,.F.) 
	/*
	Esta query refere-se a Bens ativos 
	Nesta query não pode aparecer os Bens Baixados
	Deve aparecer Os Bens que finalizaram a baixa nesse mes, e os Bens que estão depreciando
	*/
	titulo += "Período: ** " +DTOC(mv_par01)+" **" 
	wnrel := SetPrint('SN1',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT 	F9_CBASE AS CODIGO, F9_ITEMB AS ITEM,"
	cQuery += "  		   F9_DESCRI AS DESCRI ," 
	cQuery += "   		   F9_CODIGO AS CODCIAP , F9_SLDPARC AS SALDO, F9_QTDPARC AS QTDP,"
	cQuery += "			   F9_ICMIMOB AS TOTICM, FA_VALOR AS VLRAPROP, "
	cQuery += "          FA_DATA AS DATAAP , F9_DTENTNE AS DTDIGITNFE"
	cQuery += " FROM " +  RetSQLTab('SF9') + "," + RetSQLTab('SFA')    //SF9010, SFA010
	cQuery += " WHERE" + RetSQLDel('SF9') + " AND " + RetSQLDel('SFA')   //SF9010.D_E_L_E_T_ <> '*' AND SFA010.D_E_L_E_T_ <> '*' "
	cQuery += " 	AND " + RetSQLFil('SF9') + " AND " + RetSQLFil('SFA')
	cQuery += " 	AND (F9_CODIGO BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "')"         
	cQuery += " 	AND F9_CODIGO = FA_CODIGO "  	
	cQuery += "     AND F9_MOTIVO = ''  "
	cQuery += " 	AND F9_BXICMS = 0 "  
	cQuery += "     AND FA_DATA = '"+DTOS(MV_PAR01)+"' "    
	cQuery += " ORDER BY F9_DTENTNE ,F9_CODIGO " 

	cQuery := ChangeQuery(cQuery)
	´
	If Select("CIAP") != 0
		CIAP->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "CIAP"       
	//	cQuery += " 	AND F9_SLDPARC > 0 "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SN1')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)


	//Local _cDescriCC  	:= ""
	//Local _cCCusto    	:= ""  
	Local _nSCPrazo 	:= 0
	Local _nSLPrazo 	:= 0 
	Local _nTotICM 		:= 0
	Local _nTotICMP		:= 0
	Local _nVaprop 		:= 0
	Local 	_nSaldo     := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ




	CIAP->(SetRegua(RecCount()))

	CIAP->(dbGoTop())



	While CIAP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if nLin > 70
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		endif

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif              

		if CIAP->SALDO <=11
			//		_nSCPrazo += ((CIAP->TOTICM/48)*CIAP->SALDO)    
			_nSCPrazo += ((CIAP->TOTICM/CIAP->QTDP)*CIAP->SALDO)  

		elseif CIAP->SALDO > 11
			_nSCP := 12
			_nSLP := (CIAP->SALDO-12)
			//_nSCPrazo += ((CIAP->TOTICM/48)*_nSCP) 
			_nSCPrazo += ((CIAP->TOTICM/CIAP->QTDP)*_nSCP) 
			//_nSLPrazo += ((CIAP->TOTICM/48)*_nSLP) 
			_nSLPrazo += ((CIAP->TOTICM/CIAP->QTDP)*_nSLP)
		endif

		@nlin,00  psay CIAP->CODIGO+' '+CIAP->ITEM  	   	
		@nlin,16  psay substr(CIAP->DESCRI,1,30)
		@nlin,47  psay CIAP->CODCIAP	    
		@nlin,55  psay CIAP->SALDO 
		@nlin,58  psay STOD(CIAP->DTDIGITNFE)
		@nlin,67  psay transform(CIAP->TOTICM,'@E 999,999,999.99')
		//@nlin,82  psay transform((CIAP->TOTICM/48),'@E 999,999,999.99')
		@nlin,82  psay transform((CIAP->TOTICM/CIAP->QTDP),'@E 999,999,999.99')
		@nlin,97  psay transform(CIAP->VLRAPROP,'@E 999,999,999.99')
		//@nlin,112 psay transform(((CIAP->TOTICM/48)*CIAP->SALDO),'@E 999,999,999.99')
		@nlin,112 psay transform(((CIAP->TOTICM/CIAP->QTDP)*CIAP->SALDO),'@E 999,999,999.99')

		_nTotICM += CIAP->TOTICM
		//_nTotICMP+=	(CIAP->TOTICM/48)
		_nTotICMP+=	(CIAP->TOTICM/CIAP->QTDP)
		_nVaprop += CIAP->VLRAPROP  
		//_nSaldo  += ((CIAP->TOTICM/48)*CIAP->SALDO)
		_nSaldo    += ((CIAP->TOTICM/CIAP->QTDP)*CIAP->SALDO)
		nLin++



		CIAP->(dbSkip()) // Avanca o ponteiro do registro no arquivo


	EndDo        


	nLin++
	if nLin > 70
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	endif 
	nLin++
	@nlin,00  psay 'Total Curto Prazo:' 
	@nlin,22  psay transform(_nSCPrazo,'@E 999,999,999.99') 
	nLin++
	@nlin,00  psay 'Total Longo Prazo:' 
	@nlin,22  psay transform(_nSLPrazo,'@E 999,999,999.99')	
	nLin++ 
	nLin++ 
	nLin++     
	@nlin,00  psay 'Total Geral:' 
	@nlin,67  psay transform(_nTotICM 	,'@E 999,999,999.99')
	@nlin,82  psay transform(_nTotICMP	,'@E 999,999,999.99')
	@nlin,97  psay transform(_nVaprop	,'@E 999,999,999.99')
	@nlin,112 psay transform(_nSaldo	,'@E 999,999,999.99')	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	DbCloseArea('CIAP')



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
