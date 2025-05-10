#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI36   º Autor ³ Flávio Bohrer Flôres  º Data ³  06/06/17  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório gGerado de um agrupamento dos relatórios da qua- º±±
±±º          ³ lidade (R3,R4,R5 e R6)                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qualidade  Exportação                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI36()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Relatório gerado de um agrupamento dos relatórios (R3,R4,R5 e R6) da"
	Local cDesc2         := "qualidade, para visualizar a Produção de exportação "
	Local cDesc3         := "..."
	Local cPict          := ""
	Local titulo         := "R10 - RESUMO ESPECÍFICO DE PRODUÇÃO EXPORTAÇÃO"
	Local nLin           := 80

	Local Cabec1         := space(3)+"Data de Abate"+space(10)+"Carc."+space(10)+"Peças"+space(10)+"Prod."+space(8)+"Data Prod."+space(7)+"Cod."+space(11)+ "Quant." +space(4)+ "Total" +space(6)+ "Quant."                                    
	Local Cabec2         := space(24)+"Maturadas "+space(7)+"( UY/CN )"+space(7)+"Desossa"+space(9)+"Desossa"+space(7)+"Produto"+space(9)+"Peças"+space(3)+ "Acem/Paleta" +space(2)+ "Peças\Est."                                          
	Local imprime        := .T.
	Local aOrd 				:= {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI36" 
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "DTI36"
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "DTI36" 
	Private _cNUMAM     := ''
	Private _cPreDes    := '' 
	Private _cClassif   := ''
	Private _cTipifi    := ''
	Private _cDescCort  := '' 
	Private _cDescProd  := ''
	Private _nQtPecas   := 0.00
	Private _cCorte	  := ''
	Private _nTpp       := 0
	Private aCores   := {}
	Private cString := "SZ8"              



	pergunte(cPerg,.F.)

	titulo         += " - de ( "+DTOC(mv_par01)+" até "+DTOC(mv_par02)+" )"

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	query()

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ8')

	If nLastKey == 27
		Return
	Endif


	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)    

Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	EMB->(dbGoTop())

	EMB->(SetRegua(RecCount()))

	_cNUMAM := ''
	_nSpa := 0
	_nSpp := 0 
	_nTppt:= 0    
	_nini := 1
	/*Data de Abate*/



	While EMB->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif  

		If _nini = 1  
			//@nlin,05 psay "Período em que foi gerado o relatório foi de "+DTOC(mv_par01)+" até "+DTOC(mv_par02)
			//nLin += 3   
			_nini++  
		Endif  

		if _cNUMAM <> EMB->NUMAM         //Z2_NUMAM AS NUMAM
			_cNUMAM   := EMB->NUMAM

			_dDtAbate := dtoc(fBuscaCPO('SZG',1,xfilial('SZG') + _cNUMAM,'ZG_DATA'))

			/*Data de Abate*/
			@nlin,05 psay _dDtAbate

			cgjf13(_cNUMAM)
			/* Carc. Maturadas*/
			@nlin,26 psay MATURA->QTDPEC
			_ntot := 2 * MATURA->QTDPEC

			/* Peças UY */
			@nlin,43 psay  _ntot			
		endif  

		if _cPreDes <> EMB->PREDES
			_cPreDes  := EMB->PREDES         
		endif

		if (EMB->COD = '008060' .or. EMB->COD = '008061' .or. EMB->COD = '010626' .or. EMB->COD = '010627') //(EMB->COD $ '10212/012021')
			//Dianteiro			
			_cCorte 	:= 'D'
			_nTppd		:= cmlr22(_cNUMAM,EMB->PREDES,EMB->DATAPROD,_cCorte)	  		
		Elseif  EMB->COD = '001443'	     
			//Traseiro 		 
			_cCorte 	:= 'T' 
			_nTppt 	:= cmlr22(_cNUMAM,EMB->PREDES,EMB->DATAPROD,_cCorte)
		Else
			_cCorte := ''
		Endif

		/*Prod. Desossa*/
		@nlin,56 psay  (_nTppd +_nTppt)
		_nTppd := 0
		_nTppt := 0
		//_nSpa	 := 0
		//_nSpp  := 0

		/*Data Pro. Desossa*/
		@nlin,70 psay stod(EMB->DATAPROD)
		/*Cod. Produto*/
		@nlin,85 psay alltrim(EMB->COD)  
		/* Quant. Peças  */
		@nlin,102 psay EMB->QUANT


		/*Inicio Somatório da quantidade de Acem  e Paleta*/
		If EMB->COD = '008060' 
			/* Total Paleta */
			_nSpp := _nSpp + EMB->QUANT 			
		Elseif EMB->COD = '010626' 			
			_nSpp := _nSpp + EMB->QUANT			
			/* Total Paleta */
			@nlin,112 psay  _nSpp      			
		Elseif EMB->COD = '008061'   
			_nSpa := _nSpa + EMB->QUANT
		Elseif EMB->COD = '010627' 		
			_nSpa := _nSpa + EMB->QUANT
			/* Total Acem/Paleta */
			@nlin,112 psay  _nSpa
		Elseif EMB->COD = '001443'	
			_nSpt := _nSpt + EMB->QUANT
			/* Total Acem/Paleta */
			@nlin,112 psay  _nSpt
		Endif	  	
		/*Fim Somatório da quantidade de Acem  e Paleta*/

		/*Incluir a quantidade de Peças em estoque  */
		_nNro := calcEst(EMB->COD)	 
		/* Quant. Peças\Est. */
		@nlin,123 psay _nNro



		nlin++    
		EMB->(dbSkip()) // Avanca o ponteiro do registro no arquivo 
		if EMB->PREDES <> _cPreDes
			@nlin,00 psay replicate('-',132)
			nlin++                             
			_nSpa	 := 0
			_nSpp  := 0
		endif 

	EndDo

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



Static Function query()

	cQuery := " SELECT Z2_NUMAM AS NUMAM, Z2_NUM AS PREDES,Z2_CLASESP AS CLASESP, Z8_COD AS COD, SUM(Z8_PESO) AS PESO"
	cQuery += " ,SUM(Z8_QUANT) AS QUANT, COUNT(Z8_CONTROL) AS CAIXAS,Z8_DATAP AS DATAPROD"
	cQuery += " FROM " + RetSqlTab("SZ8") + ", " + RetSqlTab("SZ2")
	cQuery += " WHERE Z2_FILIAL = '" + xFilial("SZ2") + "'"                                                     
	cQuery += " AND Z8_FILIAL = '" + xFilial("SZ8") + "' AND Z8_FILORI = '" + cFilAnt + "'"    
	cQuery += " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('SZ2')
	cQuery += " AND Z8_PREDES  = Z2_NUM"
	cQuery += " AND (Z8_COD = '008060' OR Z8_COD = '010627' OR Z8_COD = '008061' OR Z8_COD = '010626' OR Z8_COD='001443')"                                                                                                                     
	cQuery += " AND (Z8_DATAP BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')"            
	cQuery += " GROUP BY Z2_NUMAM, Z2_NUM, Z8_COD, Z8_DATAP, Z2_CLASESP"  
	cQuery += " ORDER BY Z2_NUMAM, Z2_NUM, Z8_COD, Z8_DATAP"

	cQuery := ChangeQuery(cQuery)

	/* Mostrar a consulta */
	/*
	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	Activate Dialog oDlgMemo 
	*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       

	If Select("EMB") != 0
		EMB->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "EMB"


Return 



Static Function cgjf13(_cAviso)

	cQuery2 := " SELECT COUNT(ZK_CONTROL) AS QTDPEC
	cQuery2 += " FROM "+retSqlTab('SZK')
	cQuery2 += " WHERE "+retSqlFil('SZK')
	cQuery2 += " AND ZK_NUMAM ="+_cAviso
	cQuery2 += " AND ZK_CLASSIF= 'HK '"
	cQuery2 += " AND ZK_CLASESP = '1'"
	cQuery2 += " AND " + retSqlDel('SZK')
	cQuery2 += " GROUP BY ZK_CLASESP

	cQuery2 := ChangeQuery(cQuery2)  

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Matura"
	//@ 055,005 Get cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo     

	If Select("MATURA") != 0
		MATURA->(dbCloseArea())
	Endif

	TCQUERY cQuery2 NEW ALIAS "MATURA"


Return            

Static Function cmlr22(_cAviso2,_sPredes,_dData,_cDcorte)
	Local _nTpcD := 0                  
	_cQuery4 := " SELECT ZAJ_NUMAM AS NUMAM, ZAJ_CORORI AS CORORI,ZAJ_NUM AS NUM,ZAJ_PESO AS PESO,ZAJ_CONTRO AS CONTROL,ZAJ_PREDES AS PREDES,"
	_cQuery4 += " ZAJ_HORAS AS HRPROD, ZAJ_DATAS AS DTPROD, ZK_PROGRAM AS PROGRAM, ZK_CLASSIF AS CLASSIF, ZK_DENT AS DENT, ZK_CLASESP AS CLASESP,ZK_CONTROL AS SEQ"
	_cQuery4 += " FROM  " + RetSQLTab('ZAJ') + "  ,  " + RetSQLTab('SZK') 
	_cQuery4 += " WHERE " + RetSQLFil('ZAJ') + " AND " + RetSQLFil('SZK') 
	_cQuery4 += " AND ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL = ZAJ_CONTRO"
	_cQuery4 += " AND ZAJ_HORAS <> '' AND ZAJ_DATAS <> '' AND ZAJ_PREPED = ''"
	_cQuery4 += " AND ZAJ_PRECAR = '' AND ZAJ_ITEM = ''"
	_cQuery4 += " AND (ZAJ_DATAS = '" + _dData + "')"
	_cQuery4 += " AND ZK_CLASSIF = 'HK '"
	_cQuery4 += " AND ZK_CLASESP = '1'"
	_cQuery4 += " AND ZAJ_DEST = 'D'"
	_cQuery4 += " AND ZAJ_NUMAM = '"+_cAviso2+"'"
	_cQuery4 += " AND ZAJ_CORORI = '"+_cDcorte+"'"
	_cQuery4 += " AND ZAJ_PREDES = '"+_sPredes+"'"
	_cQuery4 += " AND " + RetSQLDel('ZAJ') + " AND " + RetSQLDel('SZK')
	_cQuery4 += " ORDER BY ZAJ_NUMAM,ZAJ_CORORI"
	_cQuery4  := ChangeQuery(_cQuery4)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "ProDes"
	//@ 055,005 Get _cQuery4 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("PRODES") != 0
		PRODES->(dbCloseArea())
	Endif

	TCQUERY _cQuery4 NEW ALIAS "PRODES"


	PRODES->(SetRegua(RecCount()))

	PRODES->(dbGoTop())


	While PRODES->(!EOF())

		incregua()
		_nTpcD++ 					//Total de Dianteiros do Abate
		PRODES->(dbSkip()) // Avanca o ponteiro do registro no arquivo    

	EndDo 

Return (_nTpcD)           


Static Function calcEst(_cNum)


	cQuery5 := " SELECT SUM(Z8_QUANT) AS QUANT,Z8_DATAP AS DATAPROD"
	cQuery5 += " FROM " + RetSqlTab("SZ8") 
	cQuery5 += " WHERE Z8_FILIAL = '" + xFilial("SZ8") + "' AND Z8_FILORI = '" + cFilAnt + "'"    
	cQuery5 += " AND " + RetSQLDel('SZ8')
	cQuery5 += " AND Z8_COD  =" + _cNum 
	cQuery5 += " AND (Z8_DATAP BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')"            
	cQuery5 += " AND Z8_DATAS = '' AND Z8_HORAS = ''"  
	cQuery5 += " GROUP BY Z8_COD, Z8_DATAP"  
	cQuery5 := ChangeQuery(cQuery5)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery5 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       

	If Select("EMB2") != 0
		EMB2->(dbCloseArea())
	Endif

	TCQUERY cQuery5 NEW ALIAS "EMB2"

	EMB2->(SetRegua(RecCount()))
	EMB2->(dbGoTop())   
	_nqt := 0

	While EMB2->(!EOF())

		incregua()	 	
		_nqt++ // Total de peças nas caixas ainda em estoque	
		EMB2->(dbSkip())   

	EndDo

Return (_nqt)
