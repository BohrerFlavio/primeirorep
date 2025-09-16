#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI82    ºAutor  ³ Flávio    º Data ³  30/10/19   		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de Férias	feito só para importar no Excel	      º±±
±±º          ³ OBS - Layout não fica bem na Folha normal                  º±±
±±º          ³                   				                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestão de Pessoal - Daiana                                 º±±
±±ÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function DTI82()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Declaracao de Variaveis                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "das Férias...."
	Local cDesc3         := ""
	Local titulo         := "RELATÓRIO DE FÉRIAS"
	Local Cabec1         := "Centro C."+space(06)+"Mat."+space(05)+" Nome"+space(30)+"Dt.Ini."+space(03)+"Dt.Fim"+space(02)+" Dia V."+space(01)+"Dias G."+space(08)+" Líq."+space(08)+"T.Vale"
	Local Cabec2         := ''	
	Local imprime        := .T.
	Local aOrd           := {}
	Local titulo         := "RELAT. DE FERIAS"
	Private nLin         := 50
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 50
	Private tamanho      := "M"
	Private nomeprog     := "DTI82R" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "DTI82R"
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI82R" // Coloque aqui o nome do arquivo usado para impressao em disco
	
	 
	pergunte(cPerg,.F.)

	wnrel := SetPrint('SRH',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
 
	MsgRun("Aguarde... Realizando contagem de registros...",,{||  Gquery(mv_par01,mv_par02)})
	 
	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SP8')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,alltrim(mv_par02)) },Titulo) 
	 
	 
		              

return



Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,nPeriod)

	Local nOrdem
	Private nProv := 0
	Private nDesc := 0 
	Private nLiq  := 0  
	
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cNome := ''
	TMP->(SetRegua(RecCount()))
	TMP->(dbGoTop())
	
	While TMP->(!EOF())
	
	
		incregua()

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
	
	
		IF alltrim(_cNome) <> alltrim(TMP->RA_NOME)
			
			@nlin,03 psay alltrim(TMP->RA_CC)
			
			@nlin,12 psay alltrim(TMP->RR_MAT)
			//@nlin,21 psay substr(TMP->RA_NOME,1,55)
			@nlin,21 psay Alltrim(TMP->RA_NOME)
			//nlin++
			
			//@nlin,5 psay 'Base Fer.Ini: '
			//@nlin,59 psay STOD(TMP->RH_DATABAS)       
			//@nlin,30 psay 'Base Fer.Fim: '
			//@nlin,69 psay STOD(TMP->RH_DBASEAT)
			//@nlin,55 psay 'Inic. Ferias: '
			@nlin,59 psay STOD(TMP->RH_DATAINI)
			//@nlin,90 psay 'Fim Férias: '
			//@nlin,59 psay STOD(TMP->RH_DATAFIM)----------------------
			//nlin++
			
			//@nlin,05 psay 'Dt.Rec.Fer.: '
			@nlin,69 psay STOD(TMP->RH_DATAFIM)
			//Nr.Dias Gozo	
			@nlin,80 psay TMP->RH_DFERIAS
			//Dias Vend.
			if TMP->RH_DABONPE = 0
				@nlin,86 psay ' 0'
			else		
					
				//@nlin,115 psay TMP->RH_DABONPE  /// strlen
				@nlin,86 psay PADL(alltrim(str(TMP->RH_DABONPE)),2,'0')   /// strlen
				
			endif
			//@nlin,30 psay 'Salário Mês: R$'
			//@nlin,85 psay transform(TMP->RH_SALMES,'@E 999,999,999.99')
			
			calcPV(TMP->RR_MAT,nPeriod)
					
			//Proventos
			//@nlin,100 psay transform(nProv,'@E 999,999,999.99')
			//Líquido
			@nlin,93 psay transform(nLiq,'@E 999,999,999.99')
			// A=ATU;F=Formigueiro;S=Sao Sepe;V=Fretado;B=Vila Block;T=ATU/Fretado
			If TMP->RA_TPVAL = 'A'
				_cTPVAL := 'ATU'
			Elseif  TMP->RA_TPVAL = 'F'
				_cTPVAL := 'Formigueiro'
			Elseif TMP->RA_TPVAL = 'S'
				_cTPVAL := 'Sao Sepe'
			Elseif TMP->RA_TPVAL = 'V'
				_cTPVAL := 'Fretado'
			Elseif TMP->RA_TPVAL = 'B'
				_cTPVAL := 'Vila Block'
			Elseif TMP->RA_TPVAL = 'T'
				_cTPVAL := 'ATU/Fretado'
			Else
				_cTPVAL := 'S/Tipo Vale'
			Endif
			@nlin,115 psay _cTPVAL
			nlin++
			
			_cNome := alltrim(TMP->RA_NOME)
		Endif
		
			nProv := 0 
			nDesc  := 0 
			nLiq  := 0 
		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	
	Enddo
	
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


Static Function Gquery(mv_p01,mv_p02)
	/*
	mv_par01 = Matricula ?                          
	mv_par03 = Período de Pagamento ?  
	*/
	Local _cPer := alltrim(mv_p02)
			
	_cQuery := " SELECT RR_MAT,RA_NOME,RR_PD,RA_CC,RH_DATABAS,RH_DBASEAT,RH_DATAINI,RH_DATAFIM,RH_DTRECIB,RH_SALMES,RH_DFERIAS,RH_DABONPE,RA_TPVAL"
	_cQuery += " FROM " + retSqlTab('SRR')+ " , " + retSqlTab('SRH')+ " , " + retSqlTab('SRA')
	_cQuery += " WHERE " +  retSqlFil('SRR')+ " AND " + retSqlFil('SRH')+ " AND " + retSqlFil('SRA')
	_cQuery += " AND RH_FILIAL = RR_FILIAL "
	_cQuery += " AND RH_FILIAL = RA_FILIAL "
	_cQuery += " AND RA_MAT = RH_MAT "	
	_cQuery += " AND RH_MAT = RR_MAT "
	_cQuery += " AND RH_PERIODO = RR_PERIODO"		
	
	IF !empty(mv_p01)
	
		_cQuery += " AND RH_MAT = '" + mv_p01 + "'"
			
	End	
	_cQuery += " AND RR_PERIODO = '" + alltrim(_cPer) + "'"	
	_cQuery += " AND " + retSqlDel('SRR')+ " AND " + retSqlDel('SRH') 
	_cQuery += " GROUP BY RR_MAT,RA_NOME,RR_PD,RA_CC,RH_DATABAS,RH_DBASEAT,RH_DATAINI,RH_DATAFIM,RH_DTRECIB,RH_SALMES,RH_DFERIAS,RH_DABONPE,RA_TPVAL"
	_cQuery += " ORDER BY RR_MAT,RA_NOME,RR_PD,RA_CC,RH_DATABAS,RH_DBASEAT,RH_DATAINI,RH_DATAFIM,RH_DTRECIB,RH_SALMES,RH_DFERIAS,RH_DABONPE,RA_TPVAL"
	
	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	
	//Return .t.

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

Return

Static Function CalcPV(cMat,cPer)
/*
cMat = Matrícula 
cPer = Período para calculo
*/
// Variáveis
 //nProv := 0
// nDesc := 0 
 //nLiq  := 0 

	
	DbSelectArea('SRR')
	SRR->(DbSetOrder(7))
	SRR->(dbGoTop())
	SRR->(DbSeek(xfilial('SRR') + alltrim(cMat)+alltrim(cPer))) 
	
	While SRR->(!EOF()) 
				
		if cMat != SRR->RR_MAT .OR. SRR->RR_PERIODO != cPer
			Exit
		Endif
				
		RV_TPCOD := fBuscaCPO('SRV',1,xfilial('SRV')+SRR->RR_PD,'RV_TIPOCOD')
		
		if alltrim(SRR->RR_PD) = '497'
			// Valor líquido das férias
			nLiq := SRR->RR_VALOR
		Elseif alltrim(RV_TPCOD) = '1'
			// Proventos
			nProv := nProv + SRR->RR_VALOR
		Elseif alltrim(RV_TPCOD) = '2'
			if SRR->RR_PD > '497' .OR. SRR->RR_PD < '497'
				// Descontos
				nDesc := nDesc + SRR->RR_VALOR
			endif
		Elseif alltrim(RV_TPCOD) = '3'
			
			
		endif
		
		
		SRR->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	
	Enddo


Return 
