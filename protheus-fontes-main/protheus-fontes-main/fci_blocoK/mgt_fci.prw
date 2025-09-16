#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function MGT_FCI()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ MGT_FCI  ³ Autor ³ Evandro Mugnol        ³ Data ³ Set/2014 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Rotina para geração de relatório / tabela CFD referente aos³±±
	±±³          ³ cálculos realizados para o FCI                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Frig. Silva                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Data      ³ Programador   ³ Manutencao Efetuada                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL nOpca			 := 0
	LOCAL aSays			 := {}
	Local aButtons		 := {}
	LOCAL cProcessa 	 := ""
	Local cFunction 	 := "MGT_FCI"
	Local cTitle	 	 := "Geração relatório / Tabela CFD para o FCI"
	Local bProcess 

	Local	cDescription := "Rotina responsável pelo processamento das informações para o FCI." + CRLF + ;
	"Para executar o processamento do período de análise selecionado, clique no botão abaixo e aguarde a conclusão do processamento." + CRLF + CRLF +;
	"LOG DE PROCESSOS: Log de todos os processos executados desta rotina" + CRLF + ;
	"GERA RELATÓRIO: Função responsável pela geração do relatório de conferência." + CRLF + ;
	"GERA TABELA: Função responsável pela geração dos dados na tabela CFD após conferência do relatório realizada."

	Local oProcess
	Local __lIsP12   := GetVersao(.F.) == "12"

	Private cPerg		:= "MGT_FCI"
	Private cCadastro := OemToAnsi("Geração relatório / Tabela CFD para o FCI")

	If __lIsP12
		oProcess := tNewProcess():New( cFunction, cTitle, {|oSelf| FCINewPerg ( oSelf ) }, cDescription, cPerg )
	Else
		ProcLogIni( aButtons )
		Pergunte(cPerg,.F.)
		AADD (aSays, OemToAnsi( " Rotina responsável pelo processamento das informações para o FCI." ))
		AADD (aSays, OemToAnsi( "Para executar o processamento do período de análise selecionado,  " ))
		AADD (aSays, OemToAnsi( "clique no botão abaixo e aguarde a conclusão do processamento.    " ))
		AADD (aSays, OemToAnsi( "A rotina irá gerar um relatório ou gerar a tabela CFD conforme    " ))
		AADD (aSays, OemToAnsi( "parâmetros informados pelos usuário.                              " ))

		AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
		AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
		AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )

		FormBatch( cCadastro, aSays, aButtons ,,,420)

		If nOpcA == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o log de processamento   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ProcLogAtu("INICIO")

			Processa({|lEnd| FCIProc()})		  		// Chamada da funcao de processamento

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o log de processamento   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ProcLogAtu("FIM")
		Endif
	EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FCINewPerg³ Autor ³ Evandro Mugnol       ³ Data ³ Set/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento para a utilização do tNewProcess				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FCINewPerg( oSelf )

	FCIProc(.F.,oSelf)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FCIProc   ³ Autor ³ Evandro Mugnol       ³ Data ³ Set/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função que efetua o processamento das informações          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FCIProc( lBat, oSelf )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString 	:= "SD2"
	cDesc1  	:= "Este programa tem como objetivo, imprimir o relatorio"
	cDesc2  	:= "com as informações processadas para o FCI."
	cDesc3  	:= ""
	tamanho 	:= "G"
	aReturn 	:= {"Zebrado", 1,"Administracao", 1, 2, 1, "",1}
	aLinha  	:= {}
	nLastKey	:= 0
	titulo  	:= "Informações Arquivo FCI"
	wnrel   	:= "MGT_FCI"
	nTipo   	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR01 == 1 			// CASO SEJA PARA GERAR RELATÓRIO
		wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.)

		If nLastKey == 27
			Return
		Endif
		SetDefault(aReturn,cString)
		If nLastKey == 27
			Return
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo := IIF(aReturn[4]==1,15,18)
	li    := 80
	m_pag := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1:="R E L A T O R I O     D E     C O N F E R E N C I A     F C I     -     PERIODO DE ANALISE DE " + DTOC(MV_PAR02) + " ATE " + DTOC(MV_PAR03)
	cabec2:="                                                                                                                                                                                                                            "
	//***    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	//***              1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//***    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

	lBat  := If( ValType( lBat ) <> 'L', .F., lBat)
	oSelf := If( ValType( oSelf ) <> 'O', Nil, oSelf)

	cMes		:=	Alltrim(StrZero(Month(mv_par02),2))
	cAno		:=	Alltrim(Str(Year(mv_par02)))
	cAnoCalc	:=	xRetYear(Alltrim(Str(Year(mv_par03))),StrZero(Month(mv_par03),2),1)
	cMesCalc	:=	xRetYear(Alltrim(Str(Year(mv_par03))),StrZero(Month(mv_par03),2),2)

	If !lBat
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula total de registros a serem processados corretamente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT COUNT( R_E_C_N_O_ ) TOTREG "
		cQuery += "  FROM " + RetSQLName("SD2")
		cQuery += " WHERE	D2_FILIAL ='" + xFilial("SD2") + "'"
		cQuery += "   AND D2_EMISSAO BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "'"
		cQuery += "   AND (D2_GRUPO BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "' OR D2_GRUPO BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "')"
		cQuery += "   AND D2_GRUPO NOT IN " + FormatIn(Alltrim(mv_par08),',')
		cQuery += "   AND D2_CF IN " + FormatIn(Alltrim(mv_par09),',')
		cQuery += "   AND D2_EST NOT IN ('RS','EX')"
		cQuery += "   AND D_E_L_E_T_ = ''"

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TRBTOT',.T.,.T.)

		If __lIsP12 .And. oSelf <> Nil
			oSelf:Savelog("INICIO")
			oSelf:SetRegua1(TRBTOT->TOTREG)
			oSelf:SetRegua2(TRBTOT->TOTREG)
		Else
			ProcRegua(TRBTOT->TOTREG)
		EndIf	

		TRBTOT->( DbCloseArea() )
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivo de Trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aArqTrb := {}
	aCampos := {}
	AADD(aCampos,{"PRODUTO", "C", TamSX3("B1_COD")[1], 		TamSX3("B1_COD")[2] 		})
	AADD(aCampos,{"QUANT_S", "N", TamSX3("D2_QUANT")[1], 		TamSX3("D2_QUANT")[2] 	})
	AADD(aCampos,{"VLTOT_S", "N", TamSX3("D2_VALBRUT")[1], 	TamSX3("D2_VALBRUT")[2] })
	AADD(aCampos,{"VLICM_S", "N", TamSX3("D2_VALICM")[1], 	TamSX3("D2_VALICM")[2] 	})
	AADD(aCampos,{"VLRET_S", "N", TamSX3("D2_ICMSRET")[1], 	TamSX3("D2_ICMSRET")[2] })
	AADD(aCampos,{"VLIPI_S", "N", TamSX3("D2_VALIPI")[1], 	TamSX3("D2_VALIPI")[2] 	})
	AADD(aCampos,{"QUANTDV", "N", TamSX3("D1_QUANT")[1], 		TamSX3("D1_QUANT")[2] 	})
	AADD(aCampos,{"VLTOTDV", "N", TamSX3("D1_TOTAL")[1], 		TamSX3("D1_TOTAL")[2] 	})
	AADD(aCampos,{"VLICMDV", "N", TamSX3("D1_VALICM")[1], 	TamSX3("D1_VALICM")[2] 	})
	AADD(aCampos,{"VLRETDV", "N", TamSX3("D1_ICMSRET")[1], 	TamSX3("D1_ICMSRET")[2] })
	AADD(aCampos,{"VLIPIDV", "N", TamSX3("D1_VALIPI")[1], 	TamSX3("D1_VALIPI")[2] 	})
	AADD(aCampos,{"QUANT_E", "N", TamSX3("D1_QUANT")[1], 		TamSX3("D1_QUANT")[2] 	})
	AADD(aCampos,{"VLTOT_E", "N", TamSX3("D1_TOTAL")[1], 		TamSX3("D1_TOTAL")[2] 	})
	AADD(aCampos,{"VLFRE_E", "N", TamSX3("D1_VALFRE")[1], 	TamSX3("D1_VALFRE")[2] 	})
	AADD(aCampos,{"VLSEG_E", "N", TamSX3("D1_SEGURO")[1], 	TamSX3("D1_SEGURO")[2]	})
	AADD(aCampos,{"VL_II_E", "N", TamSX3("D1_II")[1], 			TamSX3("D1_II")[2]	 	})
	AADD(aCampos,{"QUANTDC", "N", TamSX3("D2_QUANT")[1], 		TamSX3("D2_QUANT")[2] 	})
	AADD(aCampos,{"VLTOTDC", "N", TamSX3("D2_VALBRUT")[1], 	TamSX3("D2_VALBRUT")[2] })
	AADD(aCampos,{"VLFREDC", "N", TamSX3("D2_VALFRE")[1], 	TamSX3("D2_VALFRE")[2] 	})
	AADD(aCampos,{"VLSEGDC", "N", TamSX3("D2_SEGURO")[1], 	TamSX3("D2_SEGURO")[2]	})
	AADD(aCampos,{"VL_IIDC", "N", TamSX3("D2_VALTST")[1], 	TamSX3("D2_VALTST")[2] 	})

	//cNomeArq:=CriaTrab(aCampos)
	//dbUseArea( .T.,, cNomeArq, "cNomeArq", If(.F. .OR. .F., !.F., NIL), .F. )
	//IndRegua("cNomeArq",cNomeArq,"PRODUTO",,,OemToAnsi("Selecionando Registros..."))

	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aCampos, {"PRODUTO"}, @_aArqTrb)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivo de Trabalho para gerar tabela CFD               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aArqTrb1 := {}
	aCpos := {}
	AADD(aCpos,{"PERCCFD", "C", TamSX3("CFD_PERCAL")[1], 	TamSX3("CFD_PERCAL")[2] })
	AADD(aCpos,{"PERVCFD", "C", TamSX3("CFD_PERVEN")[1], 	TamSX3("CFD_PERVEN")[2] })
	AADD(aCpos,{"PRD_CFD", "C", TamSX3("CFD_COD")[1], 		TamSX3("CFD_COD")[2] 	})
	AADD(aCpos,{"OP__CFD", "C", TamSX3("CFD_OP")[1], 		TamSX3("CFD_OP")[2] 		})
	AADD(aCpos,{"VPI_CFD", "N", TamSX3("CFD_VPARIM")[1],	TamSX3("CFD_VPARIM")[2] })
	AADD(aCpos,{"VLS_CFD", "N", TamSX3("CFD_VSAIIE")[1],	TamSX3("CFD_VSAIIE")[2] })
	AADD(aCpos,{"CON_CFD", "N", TamSX3("CFD_CONIMP")[1],	TamSX3("CFD_CONIMP")[2] })
	AADD(aCpos,{"COD_CFD", "C", TamSX3("CFD_FCICOD")[1],	TamSX3("CFD_FCICOD")[2] })
	AADD(aCpos,{"FIL_CFD", "C", TamSX3("CFD_FILOP")[1], 	TamSX3("CFD_FILOP")[2] 	})
	AADD(aCpos,{"ORI_CFD", "C", TamSX3("CFD_ORIGEM")[1], 	TamSX3("CFD_ORIGEM")[2] })

	//cNomeArq1:=CriaTrab(aCpos)
	//dbUseArea( .T.,, cNomeArq1, "cNomeArq1", If(.F. .OR. .F., !.F., NIL), .F. )
	//IndRegua("cNomeArq1",cNomeArq1,"PRD_CFD+PERCCFD+PERVCFD",,,OemToAnsi("Selecionando Registros..."))

	If Select('TMP1')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP1->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb1)
	Endif

	U_ArqTrb("Cria", "TMP1", aCpos, {"PRD_CFD","PERCCFD","PERVCFD"}, @_aArqTrb1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Seleção dos movimentos de saídas (SD2)
	cQuery := "SELECT D2_COD, D2_DESCRI, SUM(D2_QUANT) AS QUANT, SUM(D2_VALBRUT) AS VALBRUT, SUM(D2_VALICM) AS VALICM, SUM(D2_ICMSRET) AS ICMSRET, SUM(D2_VALIPI) AS VALIPI "
	cQuery += "  FROM " + RetSQLName("SD2")
	cQuery += " WHERE	D2_FILIAL ='" + xFilial("SD2") + "'"
	cQuery += "   AND D2_EMISSAO BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "'"
	cQuery += "   AND (D2_GRUPO BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "' OR D2_GRUPO BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "')"
	cQuery += "   AND D2_GRUPO NOT IN " + FormatIn(Alltrim(mv_par08),',')
	cQuery += "   AND D2_CF IN " + FormatIn(Alltrim(mv_par09),',')
	cQuery += "   AND D2_EST NOT IN ('RS','EX')"
	cQuery += "   AND D_E_L_E_T_ = ''"
	cQuery += " GROUP BY D2_COD, D2_DESCRI"
	cQuery += " ORDER BY D2_COD"

	cQuery := ChangeQuery(cQuery)

	_log("SAIDAS      ==> " + cQuery)

	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "SAID", .F., .T.)

	SAID->(dbGoTop())
	While SAID->(!Eof())
		If !lBat
			If __lIsP12 .And. oSelf <> Nil
				oSelf:IncRegua1("Selecionando Registros...")
				oSelf:IncRegua2()
			Else	
				IncProc()
			EndIf	
		Endif

		_cProduto := SAID->D2_COD
		_nQuantS  := SAID->QUANT
		_nVlTotS  := SAID->VALBRUT
		_nVlIcmS  := SAID->VALICM
		_nVlRetS  := SAID->ICMSRET
		_nVlIpiS  := SAID->VALIPI

		DbSelectArea("TMP")
		DbSeek(_cProduto)
		If Found()
			Reclock("TMP",.F.)
			Replace QUANT_S With QUANT_S + _nQuantS
			Replace VLTOT_S With VLTOT_S + _nVlTotS
			Replace VLICM_S With VLICM_S + _nVlIcmS
			Replace VLRET_S With VLRET_S + _nVlRetS
			Replace VLIPI_S With VLIPI_S + _nVlIpiS
			MsUnlock()
		Else
			If !Empty(_cProduto)
				Reclock("TMP",.T.)
				Replace PRODUTO With _cProduto
				Replace QUANT_S With _nQuantS
				Replace VLTOT_S With _nVlTotS
				Replace VLICM_S With _nVlIcmS
				Replace VLRET_S With _nVlRetS
				Replace VLIPI_S With _nVlIpiS
				MsUnlock()
			Endif
		Endif

		_log("SAIDAS	     ==> " + SAID->D2_COD + " - " + SAID->D2_DESCRI + "-" + Transform(_nQuantS, "@E 9,999.99") + "-" + Transform(_nVlTotS, "@E 999,999.99") )

		SAID->(DbSkip())
	Enddo

	SAID->(DbCloseArea())


	// Seleção dos movimentos de devolução de vendas (SD1)
	cQuery := "SELECT D1_COD, D1_DESCRI, SUM(D1_QUANT) AS QUANT, SUM(D1_TOTAL) AS TOTAL, SUM(D1_TOTAL) / SUM(D1_QUANT) AS TOTQUANT, SUM(D1_TOTAL) AS VLTOTAL, SUM(D1_VALICM) AS VALICM, SUM(D1_ICMSRET) AS ICMSRET, SUM(D1_VALIPI) AS VALIPI, (SUM(D1_TOTAL) - (SUM(D1_ICMSRET) + SUM(D1_VALICM) + SUM(D1_VALIPI))) / SUM(D1_QUANT) AS VALORDEVOL "
	cQuery += "  FROM " + RetSQLName("SD1")
	cQuery += " WHERE	D1_FILIAL ='" + xFilial("SD1") + "'"
	cQuery += "   AND D1_DTDIGIT BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "'"
	cQuery += "   AND (D1_GRUPO BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "' OR D1_GRUPO BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "')"
	cQuery += "   AND D1_GRUPO NOT IN " + FormatIn(Alltrim(mv_par08),',')
	cQuery += "   AND D1_CF IN " + FormatIn(Alltrim(mv_par10),',')
	cQuery += "   AND D_E_L_E_T_ = ''"
	cQuery += " GROUP BY D1_COD, D1_DESCRI"
	cQuery += " ORDER BY D1_COD"

	cQuery := ChangeQuery(cQuery)

	_log("DEV. VENDAS ==> " + cQuery)

	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "DEVV", .F., .T.)

	DEVV->(dbGoTop())
	While DEVV->(!Eof())
		If !lBat
			If __lIsP12 .And. oSelf <> Nil
				oSelf:IncRegua1("Selecionando Registros...")
				oSelf:IncRegua2()
			Else	
				IncProc()
			EndIf	
		Endif

		_cProduto := DEVV->D1_COD
		_nQuantDV := DEVV->QUANT
		_nVlTotDV := DEVV->TOTAL
		_nVlIcmDV := DEVV->VALICM
		_nVlRetDV := DEVV->ICMSRET
		_nVlIpiDV := DEVV->VALIPI

		DbSelectArea("TMP")
		DbSeek(_cProduto)
		If Found()
			Reclock("TMP",.F.)
			Replace QUANTDV With QUANTDV + _nQuantDV
			Replace VLTOTDV With VLTOTDV + _nVlTotDV
			Replace VLICMDV With VLICMDV + _nVlIcmDV
			Replace VLRETDV With VLRETDV + _nVlRetDV
			Replace VLIPIDV With VLIPIDV + _nVlIpiDV
			MsUnlock()
		Else
			If !Empty(_cProduto)
				Reclock("TMP",.T.)
				Replace PRODUTO With _cProduto
				Replace QUANTDV With _nQuantDV
				Replace VLTOTDV With _nVlTotDV
				Replace VLICMDV With _nVlIcmDV
				Replace VLRETDV With _nVlRetDV
				Replace VLIPIDV With _nVlIpiDV
				MsUnlock()
			Endif
		Endif

		_log("DEVOL. VENDAS ==> " + DEVV->D1_COD + " - " + DEVV->D1_DESCRI + "-" + Transform(_nQuantDV, "@E 9,999.99") + "-" + Transform(_nVlTotDV, "@E 999,999.99") )

		DEVV->(DbSkip())
	Enddo

	DEVV->(DbCloseArea())


	DbSelectArea("TMP")
	DbGotop()
	Do While !Eof()

		If MV_PAR01 == 1 			// CASO SEJA PARA GERAR RELATÓRIO
			If li>56
				cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
				@ li, 000 PSAY "S  A  Í  D  A  S                                |                     V E N D A S                      |                 D E V O L U Ç õ E S                  |                    L Í Q U I D O                   |        "
				li++                                                                                                       
				@ li, 000 PSAY "                                                |                                                      |                                                      |                                                    |        "
				li++
				@ li, 000 PSAY "P R O D U T O                                   |     QTDE   VL TOTAL   VL ICMS  VL ICMS RET    VL IPI |     QTDE   VL TOTAL   VL ICMS  VL ICMS RET    VL IPI |     QTDE   VL TOTAL   VL ICMS  VL ICMS RET   VL IPI|UNITARIO"
				li++         // XXXXXX X--------------------------------------X XXX.XXX,XX XXX.XXX,XX XX.XXX,XX    XX.XXX,XX XX.XXX,XX XXX.XXX,XX XXX.XXX,XX XX.XXX,XX    XX.XXX,XX XX.XXX,XX XXX.XXX,XX XXX.XXX,XX XX.XXX,XX    XX.XXX,XX X.XXX,XX X.XXX,XX
				@ li, 000 PSAY __PrtThinLine()
				li++
			Endif

			_nVlUnit := ((VLTOT_S - VLTOTDV) - (VLRET_S - VLRETDV) - (VLICM_S - VLICMDV) - (VLIPI_S - VLIPIDV)) / (QUANT_S - QUANTDV)

			@ li, 000  PSAY Left(PRODUTO, 6)
			@ li, 007  PSAY Left(fBuscaCpo("SB1", 1, xFilial("SB1") + PRODUTO, "B1_DESC"), 40)
			@ li, 048  PSAY QUANT_S  				Picture "@E 999,999.99"
			@ li, 059  PSAY VLTOT_S  				Picture "@E 999,999.99"
			@ li, 070  PSAY VLICM_S  				Picture "@E 99,999.99"
			@ li, 083  PSAY VLRET_S  				Picture "@E 99,999.99"
			@ li, 093  PSAY VLIPI_S  				Picture "@E 99,999.99"
			@ li, 103  PSAY QUANTDV  				Picture "@E 999,999.99"
			@ li, 114  PSAY VLTOTDV  				Picture "@E 999,999.99"
			@ li, 125  PSAY VLICMDV  				Picture "@E 99,999.99"
			@ li, 138  PSAY VLRETDV  				Picture "@E 99,999.99"
			@ li, 148  PSAY VLIPIDV  				Picture "@E 99,999.99"
			@ li, 158  PSAY QUANT_S - QUANTDV  	Picture "@E 999,999.99"
			@ li, 169  PSAY VLTOT_S - VLTOTDV  	Picture "@E 999,999.99"
			@ li, 180  PSAY VLICM_S - VLICMDV  	Picture "@E 99,999.99"
			@ li, 193  PSAY VLRET_S - VLRETDV  	Picture "@E 99,999.99"
			@ li, 203  PSAY VLIPI_S - VLIPIDV  	Picture "@E 9,999.99"
			@ li, 212  PSAY _nVlUnit			  	Picture "@E 9,999.99"
			li++

			_cProd := PRODUTO

			// Gera Arquivo de Trabalho para gravar tabela CFD
			DbSelectArea("TMP1")
			DbSeek(_cProd + cMesCalc + cAnoCalc + cMes + cAno)
			If Found()
				MsgAlert("verificar gravação do TMP1 quando já existe para saídas " + _cProd +"-"+ cMesCalc + cAnoCalc +"-"+ cMes + cAno+"-")
				Reclock("TMP1",.F.)
				Replace VLS_CFD With _nVlUnit
				MsUnlock()
			Else
				If !Empty(_cProduto)
					Reclock("TMP1",.T.)
					Replace PERCCFD With cMesCalc + cAnoCalc
					Replace PERVCFD With cMes + cAno
					Replace PRD_CFD With _cProd
					Replace VLS_CFD With _nVlUnit
					MsUnlock()
				Endif
			Endif
		Else							// EFETUA A GERAÇÃO DA TABELA CFD
			_nVlUnit := ((VLTOT_S - VLTOTDV) - (VLRET_S - VLRETDV) - (VLICM_S - VLICMDV) - (VLIPI_S - VLIPIDV)) / (QUANT_S - QUANTDV)
			_cProd 	:= PRODUTO

			// Gera Arquivo de Trabalho para gravar tabela CFD
			DbSelectArea("TMP1")
			DbSeek(_cProd + cMesCalc + cAnoCalc + cMes + cAno)
			If Found()
				MsgAlert("verificar gravação do TMP1 quando já existe para saídas " + _cProd +"-"+ cMesCalc + cAnoCalc +"-"+ cMes + cAno+"-")
				Reclock("TMP1",.F.)
				Replace VLS_CFD With _nVlUnit
				MsUnlock()
			Else
				If !Empty(_cProduto)
					Reclock("TMP1",.T.)
					Replace PERCCFD With cMesCalc + cAnoCalc
					Replace PERVCFD With cMes + cAno
					Replace PRD_CFD With _cProd
					Replace VLS_CFD With _nVlUnit
					MsUnlock()
				Endif
			Endif
		Endif

		DbSelectArea("TMP")
		DbSkip()
	Enddo


	// Seleção dos movimentos de entradas (SD1)
	cQuery := "SELECT D1_COD, D1_CF, D1_DESCRI, D1_UM, SUM(D1_QUANT) AS QUANT, SUM(D1_TOTAL) AS TOTAL, SUM(D1_VALFRE) AS VLFRETE, SUM(D1_SEGURO) AS SEGURO, SUM(D1_II) AS II, (((SUM(D1_TOTAL) + SUM(D1_VALFRE) + SUM(D1_SEGURO)) - SUM(D1_II)) / SUM(D1_QUANT)) AS CALCULO "
	cQuery += "  FROM " + RetSQLName("SD1")
	cQuery += " WHERE	D1_FILIAL ='" + xFilial("SD1") + "'"
	cQuery += "   AND D1_DTDIGIT BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "'"
	cQuery += "   AND D1_GRUPO IN " + FormatIn(Alltrim(mv_par11),',')
	cQuery += "   AND D1_CF IN " + FormatIn(Alltrim(mv_par12),',')   
	cQuery += "   AND D1_TES <> '200'"
	cQuery += "   AND D_E_L_E_T_ = ''"
	cQuery += " GROUP BY D1_COD, D1_CF, D1_DESCRI, D1_UM"
	cQuery += " ORDER BY D1_COD"

	cQuery := ChangeQuery(cQuery)

	_log("ENTRADAS    ==> " + cQuery)

	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "ENTR", .F., .T.)

	ENTR->(dbGoTop())
	While ENTR->(!Eof())
		If !lBat
			If __lIsP12 .And. oSelf <> Nil
				oSelf:IncRegua1("Selecionando Registros...")
				oSelf:IncRegua2()
			Else	
				IncProc()
			EndIf	
		Endif

		_cProduto := ENTR->D1_COD
		_nQuantE  := ENTR->QUANT
		_nVlTotE  := ENTR->TOTAL
		_nVlFreE  := ENTR->VLFRETE
		_nVlSegE  := ENTR->SEGURO
		_nVl_IIE  := ENTR->II

		DbSelectArea("TMP")
		DbSeek(_cProduto)
		If Found()
			Reclock("TMP",.F.)
			Replace QUANT_E With QUANT_E + _nQuantE
			Replace VLTOT_E With VLTOT_E + _nVlTotE
			Replace VLFRE_E With VLFRE_E + _nVlFreE
			Replace VLSEG_E With VLSEG_E + _nVlSegE
			Replace VL_II_E With VL_II_E + _nVl_IIE
			MsUnlock()
		Else
			If !Empty(_cProduto)
				Reclock("TMP",.T.)
				Replace PRODUTO With _cProduto
				Replace QUANT_E With _nQuantE
				Replace VLTOT_E With _nVlTotE
				Replace VLFRE_E With _nVlFreE
				Replace VLSEG_E With _nVlSegE
				Replace VL_II_E With _nVl_IIE
				MsUnlock()
			Endif
		Endif

		_log("ENTRADAS 	  ==> " + ENTR->D1_COD + " - " + ENTR->D1_DESCRI + "-" + Transform(_nQuantE, "@E 9,999.99") + "-" + Transform(_nVlTotE, "@E 999,999.99") )

		ENTR->(DbSkip())
	Enddo

	ENTR->(DbCloseArea())

	//===================================================================================================================================//
	// Seleção dos movimentos de devolução de compras (SD2)
	cQuery := "SELECT D2_COD, D2_CF, D2_DESCRI, D2_UM, SUM(D2_QUANT) AS QUANT, SUM(D2_TOTAL) AS TOTAL, SUM(D2_VALFRE) AS VLFRETE, SUM(D2_SEGURO) AS SEGURO, SUM(D2_VALTST) AS II, (SUM(D2_TOTAL) + SUM(D2_VALFRE) + SUM(D2_SEGURO)) / SUM(D2_QUANT) AS CALCULO "
	cQuery += "  FROM " + RetSQLName("SD2")
	cQuery += " WHERE	D2_FILIAL ='" + xFilial("SD2") + "'"
	cQuery += "   AND D2_EMISSAO BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "'"
	cQuery += "   AND D2_GRUPO IN " + FormatIn(Alltrim(mv_par11),',')
	cQuery += "   AND D2_CF IN " + FormatIn(Alltrim(mv_par13),',')
	cQuery += "   AND D_E_L_E_T_ = ''"
	cQuery += " GROUP BY D2_COD, D2_CF, D2_DESCRI, D2_UM"
	cQuery += " ORDER BY D2_COD"

	cQuery := ChangeQuery(cQuery)

	_log("DEV. COMPRAS==> " + cQuery)

	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "DEVC", .F., .T.)

	DEVC->(dbGoTop())
	While DEVC->(!Eof())
		If !lBat
			If __lIsP12 .And. oSelf <> Nil
				oSelf:IncRegua1("Selecionando Registros...")
				oSelf:IncRegua2()
			Else	
				IncProc()
			EndIf	
		Endif

		_cProduto := DEVC->D2_COD
		_nQuantDC := DEVC->QUANT
		_nVlTotDC := DEVC->TOTAL
		_nVlFreDC := DEVC->VLFRETE
		_nVlSegDC := DEVC->SEGURO
		_nVl_IIDC := DEVC->II

		DbSelectArea("TMP")
		DbSeek(_cProduto)
		If Found()
			Reclock("TMP",.F.)
			Replace QUANTDC With QUANTDC + _nQuantDC
			Replace VLTOTDC With VLTOTDC + _nVlTotDC
			Replace VLFREDC With VLFREDC + _nVlFreDC
			Replace VLSEGDC With VLSEGDC + _nVlSegDC
			Replace VL_IIDC With VL_IIDC + _nVl_IIDC
			MsUnlock()
		Else
			If !Empty(_cProduto)
				Reclock("TMP",.T.)
				Replace PRODUTO With _cProduto
				Replace QUANTDC With _nQuantDC
				Replace VLTOTDC With _nVlTotDC
				Replace VLFREDC With _nVlFreDC
				Replace VLSEGDC With _nVlSegDC
				Replace VL_IIDC With _nVl_IIDC
				MsUnlock()
			Endif
		Endif

		_log("DEVOL. COMPRAS==> " + DEVC->D2_COD + " - " + DEVC->D2_DESCRI + "-" + Transform(_nQuantDC, "@E 9,999.99") + "-" + Transform(_nVlTotDC, "@E 999,999.99") )

		DEVC->(DbSkip())
	Enddo

	DEVC->(DbCloseArea())

	li := 80		// Força quebra de página
	_nTLEQtd := 0
	_nTLEVlr := 0
	_nTLEFre := 0
	_nTLESeg := 0
	_nTLE_II := 0
	DbSelectArea("TMP")
	DbGotop()
	Do While !Eof()

		If MV_PAR01 == 1 			// CASO SEJA PARA GERAR RELATÓRIO
			If li>56
				cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
				@ li, 000 PSAY "E  N  T  R  A  D  A  S                          |                    C O M P R A S                    |                  D E V O L U Ç õ E S                |                      L Í Q U I D O                  |         "
				li++                                                                                                       
				@ li, 000 PSAY "                                                |                                                     |                                                     |                                                     |         "
				li++
				@ li, 000 PSAY "P R O D U T O                                   |       QTDE      VL TOTAL  VL FRETE VL SEGUR   VL II |       QTDE      VL TOTAL  VL FRETE VL SEGUR   VL II |       QTDE      VL TOTAL  VL FRETE VL SEGUR   VL II | UNITARIO"
				li++         // XXXXXX X--------------------------------------X X.XXX.XXX,XX XX.XXX.XXX,XX XX.XXX,XX X.XXX,XX XXXX,XX X.XXX.XXX,XX XX.XXX.XXX,XX XX.XXX,XX X.XXX,XX XXXX,XX X.XXX.XXX,XX XX.XXX.XXX,XX XX.XXX,XX X.XXX,XX XXXX,XX   X.XXX,XX
				@ li, 000 PSAY __PrtThinLine()
				li++
			Endif

			_nVlUnit := (((VLTOT_E - VLTOTDC) + (VLFRE_E - VLFREDC) + (VLSEG_E - VLSEGDC)) - (VL_II_E - VL_IIDC)) / (QUANT_E - QUANTDC)

			If QUANT_E > 0
				@ li, 000  PSAY Left(PRODUTO, 6)
				@ li, 007  PSAY Left(fBuscaCpo("SB1", 1, xFilial("SB1") + PRODUTO, "B1_DESC"), 40)
				@ li, 048  PSAY QUANT_E  				Picture "@E 9,999,999.99"
				@ li, 061  PSAY VLTOT_E  				Picture "@E 99,999,999.99"
				@ li, 075  PSAY VLFRE_E  				Picture "@E 99,999.99"
				@ li, 085  PSAY VLSEG_E  				Picture "@E 9,999.99"
				@ li, 094  PSAY VL_II_E  				Picture "@E 9999.99"
				@ li, 102  PSAY QUANTDC  				Picture "@E 9,999,999.99"
				@ li, 115  PSAY VLTOTDC  				Picture "@E 99,999,999.99"
				@ li, 129  PSAY VLFREDC  				Picture "@E 99,999.99"
				@ li, 139  PSAY VLSEGDC  				Picture "@E 9,999.99"
				@ li, 148  PSAY VL_IIDC  				Picture "@E 9999.99"
				@ li, 156  PSAY QUANT_E - QUANTDC  	Picture "@E 9,999,999.99"
				@ li, 169  PSAY VLTOT_E - VLTOTDC  	Picture "@E 99,999,999.99"
				@ li, 183  PSAY VLFRE_E - VLFREDC  	Picture "@E 99,999.99"
				@ li, 193  PSAY VLSEG_E - VLSEGDC  	Picture "@E 9,999.99"
				@ li, 202  PSAY VL_II_E - VL_IIDC  	Picture "@E 9999.99"
				@ li, 212  PSAY _nVlUnit			  	Picture "@E 9,999.99"
				li++

				_nTLEQtd += QUANT_E - QUANTDC
				_nTLEVlr += VLTOT_E - VLTOTDC
				_nTLEFre += VLFRE_E - VLFREDC
				_nTLESeg += VLSEG_E - VLSEGDC
				_nTLE_II += VL_II_E - VL_IIDC
			Endif
		Else							// EFETUA A GERAÇÃO DA TABELA CFD
			_nTLEQtd += QUANT_E - QUANTDC
			_nTLEVlr += VLTOT_E - VLTOTDC
			_nTLEFre += VLFRE_E - VLFREDC
			_nTLESeg += VLSEG_E - VLSEGDC
			_nTLE_II += VL_II_E - VL_IIDC
		Endif

		DbSelectArea("TMP")
		DbSkip()
	Enddo

	If MV_PAR01 == 1 .And. _nTLEQtd > 0			// CASO SEJA PARA GERAR RELATÓRIO e Qtde Total Liquido Entradas maior que Zero
		If li>56
			cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
			@ li, 000 PSAY "E  N  T  R  A  D  A  S                          |                    C O M P R A S                    |                  D E V O L U Ç õ E S                |                      L Í Q U I D O                  |         "
			li++                                                                                                       
			@ li, 000 PSAY "                                                |                                                     |                                                     |                                                     |         "
			li++
			@ li, 000 PSAY "P R O D U T O                                   |       QTDE      VL TOTAL  VL FRETE VL SEGUR   VL II |       QTDE      VL TOTAL  VL FRETE VL SEGUR   VL II |       QTDE      VL TOTAL  VL FRETE VL SEGUR   VL II | UNITARIO"
			li++         // XXXXXX X--------------------------------------X X.XXX.XXX,XX XX.XXX.XXX,XX XX.XXX,XX X.XXX,XX XXXX,XX X.XXX.XXX,XX XX.XXX.XXX,XX XX.XXX,XX X.XXX,XX XXXX,XX X.XXX.XXX,XX XX.XXX.XXX,XX XX.XXX,XX X.XXX,XX XXXX,XX   X.XXX,XX
			@ li, 000 PSAY __PrtThinLine()
			li++
		Endif

		li++
		@ li, 139  PSAY "T O T A L  ==>"
		@ li, 156  PSAY _nTLEQtd  Picture "@E 9,999,999.99"
		@ li, 169  PSAY _nTLEVlr  Picture "@E 99,999,999.99"
		@ li, 183  PSAY _nTLEFre  Picture "@E 99,999.99"
		@ li, 193  PSAY _nTLESeg  Picture "@E 9,999.99"
		@ li, 202  PSAY _nTLE_II  Picture "@E 9999.99"
		@ li, 212  PSAY (_nTLEVlr - _nTLEFre - _nTLESeg -_nTLE_II) / _nTLEQtd Picture "@E 9,999.99"

		li++
	Endif


	//===================================================================================================================================//
	// Seleção dos movimentos de importação (SD1)
	cQuery := "SELECT D1_COD, D1_CF, D1_DESCRI, D1_UM, SUM(D1_QUANT) AS QUANT, SUM(D1_TOTAL) AS TOTAL, SUM(D1_VALFRE) AS VLFRETE, SUM(D1_SEGURO) AS SEGURO, SUM(D1_II) AS II, (((SUM(D1_TOTAL) + SUM(D1_VALFRE) + SUM(D1_SEGURO)) - SUM(D1_II)) / SUM(D1_QUANT)) AS CALCULO "
	cQuery += "  FROM " + RetSQLName("SD1")
	cQuery += " WHERE	D1_FILIAL ='" + xFilial("SD1") + "'"
	cQuery += "   AND D1_DTDIGIT BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "'"
	cQuery += "   AND D1_GRUPO IN " + FormatIn(Alltrim(mv_par11),',')
	cQuery += "   AND D1_CF IN ('3101') "
	cQuery += "   AND D_E_L_E_T_ = ''"
	cQuery += " GROUP BY D1_COD, D1_CF, D1_DESCRI, D1_UM"
	cQuery += " ORDER BY D1_COD"

	cQuery := ChangeQuery(cQuery)

	_log("IMPORTACOES ==> " + cQuery)

	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "IMPO", .F., .T.)

	_nVez := 1
	_nTLIQtd := 0
	_nTLIVlr := 0
	_nTLIFre := 0
	_nTLISeg := 0
	_nTLI_II := 0

	IMPO->(dbGoTop())
	While IMPO->(!Eof())
		If !lBat
			If __lIsP12 .And. oSelf <> Nil
				oSelf:IncRegua1("Selecionando Registros...")
				oSelf:IncRegua2()
			Else	
				IncProc()
			EndIf	
		Endif

		_log("IMPORTACOES	==> " + IMPO->D1_COD + " - " + IMPO->D1_DESCRI + "-" + Transform(IMPO->QUANT, "@E 9,999.99") + "-" + Transform(IMPO->TOTAL, "@E 999,999.99") )

		If MV_PAR01 == 1 			// CASO SEJA PARA GERAR RELATÓRIO
			If _nVez == 1
				li:=li+4
				@ li, 000 PSAY "I  M  P  O  R  T  A  Ç  Ã  O                                                                                                                                |                I M P O R T A Ç Õ E S                |          "
				li++                                                                                                       
				@ li, 000 PSAY "                                                                                                                                                            |                                                     |          "
				li++
				@ li, 000 PSAY "P R O D U T O                                                                                                                                               |       QTDE      VL TOTAL  VL FRETE VL SEGUR   VL II |          "
				li++         // XXXXXX X--------------------------------------X                                                                                                             X.XXX.XXX,XX XX.XXX.XXX,XX XX.XXX,XX X.XXX,XX XXXX,XX
				@ li, 000 PSAY __PrtThinLine()
				li++
				_nVez := 2
			Else
				If li>56
					cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
					@ li, 000 PSAY "I  M  P  O  R  T  A  Ç  Ã  O                                                                                                                                |                I M P O R T A Ç Õ E S                |          "
					li++                                                                                                       
					@ li, 000 PSAY "                                                                                                                                                            |                                                     |          "
					li++
					@ li, 000 PSAY "P R O D U T O                                                                                                                                               |       QTDE      VL TOTAL  VL FRETE VL SEGUR   VL II |          "
					li++         // XXXXXX X--------------------------------------X                                                                                                             X.XXX.XXX,XX XX.XXX.XXX,XX XX.XXX,XX X.XXX,XX XXXX,XX
					@ li, 000 PSAY __PrtThinLine()
					li++
				Endif
			Endif

			@ li, 000  PSAY Left(IMPO->D1_COD, 6)
			@ li, 007  PSAY Left(fBuscaCpo("SB1", 1, xFilial("SB1") + IMPO->D1_COD, "B1_DESC"), 40)
			@ li, 156  PSAY IMPO->QUANT    Picture "@E 9,999,999.99"
			@ li, 169  PSAY IMPO->TOTAL    Picture "@E 99,999,999.99"
			@ li, 183  PSAY IMPO->VLFRETE  Picture "@E 99,999.99"
			@ li, 193  PSAY IMPO->SEGURO   Picture "@E 9,999.99"
			@ li, 202  PSAY IMPO->II       Picture "@E 9999.99"
			li++

			_nTLIQtd += IMPO->QUANT
			_nTLIVlr += IMPO->TOTAL
			_nTLIFre += IMPO->VLFRETE
			_nTLISeg += IMPO->SEGURO
			_nTLI_II += IMPO->II
		Else							// EFETUA A GERAÇÃO DA TABELA CFD
			_nTLIQtd += IMPO->QUANT
			_nTLIVlr += IMPO->TOTAL
			_nTLIFre += IMPO->VLFRETE
			_nTLISeg += IMPO->SEGURO
			_nTLI_II += IMPO->II
		Endif

		IMPO->(DbSkip())
	Enddo

	If MV_PAR01 == 1 .And. _nTLIQtd > 0			// CASO SEJA PARA GERAR RELATÓRIO e Qtde Total Liquido Importações maior que Zero
		If li>56
			cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
			@ li, 000 PSAY "I  M  P  O  R  T  A  Ç  Ã  O                                                                                                                                |                I M P O R T A Ç Õ E S                |          "
			li++                                                                                                       
			@ li, 000 PSAY "                                                                                                                                                            |                                                     |          "
			li++
			@ li, 000 PSAY "P R O D U T O                                                                                                                                               |       QTDE      VL TOTAL  VL FRETE VL SEGUR   VL II |          "
			li++         // XXXXXX X--------------------------------------X                                                                                                             X.XXX.XXX,XX XX.XXX.XXX,XX XX.XXX,XX X.XXX,XX XXXX,XX
			@ li, 000 PSAY __PrtThinLine()
			li++
		Endif

		li++
		@ li, 139  PSAY "T O T A L  ==>"
		@ li, 156  PSAY _nTLIQtd  Picture "@E 9,999,999.99"
		@ li, 169  PSAY _nTLIVlr  Picture "@E 99,999,999.99"
		@ li, 183  PSAY _nTLIFre  Picture "@E 99,999.99"
		@ li, 193  PSAY _nTLISeg  Picture "@E 9,999.99"
		@ li, 202  PSAY _nTLI_II  Picture "@E 9999.99"
		li++
		li++
		li++
		@ li, 156  PSAY (_nTLIQtd / _nTLEQtd) * 100 Picture "@E 9,999,999.99"
		@ li, 170  PSAY "% de MP Importada no Período"
		li++
		li++
		@ li, 156  PSAY (((_nTLEVlr - _nTLEFre - _nTLESeg - _nTLE_II) / _nTLEQtd) * ((_nTLIQtd / _nTLEQtd) * 100)) / 100	Picture "@E 9,999,999.99"
		@ li, 170  PSAY "Vlr Compra p/ Kg Proporcional"
		li++
		@ li, 170  PSAY "ao % Importado no Período"
	Endif

	IMPO->(DbCloseArea())


	li := 80		// Força quebra de página
	DbSelectArea("TMP1")
	DbGotop()
	Do While !Eof()
		If MV_PAR01 == 1 			// CASO SEJA PARA GERAR RELATÓRIO
			If li>56
				cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
				@ li, 000 PSAY "CFD_FILIAL  CFD_PERCAL  CFD_PERVEN  CFD_COD          CFD_OP                CFD_VPARIM         CFD_VSAIIE  CFD_CONIMP  CFD_FCICOD                           CFD_FILOP  CFD_ORIGEM                                            "
				li++         //     XX        XXXXXX      XXXXXX    XXXXXXXXXXXXXXX  XXXXXXXXXXXXX  XX.XXX.XXX.XXX,XX  XX.XXX.XXX.XXX,XX   XXXX,XXXX  X----------------------------------X     XX         X
				@ li, 000 PSAY __PrtThinLine()
				li++
			Endif
			_nCI := (Round(((((_nTLEVlr - _nTLEFre - _nTLESeg - _nTLE_II) / _nTLEQtd) * ((_nTLIQtd / _nTLEQtd) * 100)) / 100),2) / VLS_CFD) * 100		// Valor do Conteúdo da Importação (CFD_CONIMP)
			@ li, 004  PSAY xFilial("CFD")                                                           	
			@ li, 014  PSAY PERCCFD
			@ li, 026  PSAY PERVCFD
			@ li, 036  PSAY PRD_CFD
			@ li, 053  PSAY OP__CFD
			@ li, 068  PSAY ((_nTLEVlr / _nTLEQtd) * ((_nTLIQtd / _nTLEQtd) * 100)) / 100	Picture "@E 99,999,999,999.99"
			@ li, 087  PSAY VLS_CFD  				Picture "@E 99,999,999,999.99"
			@ li, 107  PSAY _nCI						Picture "@E 9999.9999"
			@ li, 118  PSAY COD_CFD
			@ li, 159  PSAY FIL_CFD
			@ li, 170  PSAY xCIOrigem(_nCI)
			li++
		Else
			_nCI := (Round(((((_nTLEVlr - _nTLEFre - _nTLESeg - _nTLE_II) / _nTLEQtd) * ((_nTLIQtd / _nTLEQtd) * 100)) / 100),2) / VLS_CFD) * 100		// Valor do Conteúdo da Importação (CFD_CONIMP)
			_PERCCFD := PERCCFD
			_PERVCFD := PERVCFD
			_PRD_CFD := PRD_CFD
			_OP__CFD := OP__CFD
			_VLS_CFD := VLS_CFD
			_COD_CFD := COD_CFD
			_FIL_CFD := FIL_CFD

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravação da Tabela CFD         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("CFD")
			DbSetOrder(1)
			DbSeek(xFilial("CFD") + _PERCCFD + _PERVCFD + _PRD_CFD)
			If Found()
				//-------------------------------------------------------------
				// Verifico se o produto já não possui código de FCI importado.
				//-------------------------------------------------------------
				If Empty(CFD->CFD_FCICOD)
					RecLock("CFD",.F.)
					DbDelete()
					MsUnLock()

					RecLock("CFD",.T.)
					CFD->CFD_FILIAL := xFilial("CFD")
					CFD->CFD_PERCAL := _PERCCFD
					CFD->CFD_PERVEN := _PERVCFD
					CFD->CFD_COD	 := _PRD_CFD
					CFD->CFD_OP		 := _OP__CFD
					CFD->CFD_VPARIM := (((_nTLEVlr - _nTLEFre - _nTLESeg - _nTLE_II) / _nTLEQtd) * ((_nTLIQtd / _nTLEQtd) * 100)) / 100
					CFD->CFD_VSAIIE := _VLS_CFD
					CFD->CFD_CONIMP := _nCI
					CFD->CFD_FCICOD := _COD_CFD
					CFD->CFD_FILOP	 := _FIL_CFD
					CFD->CFD_ORIGEM := xCIOrigem(_nCI)
					MsUnLock()
				Endif
			Else
				RecLock("CFD",.T.)
				CFD->CFD_FILIAL := xFilial("CFD")
				CFD->CFD_PERCAL := _PERCCFD
				CFD->CFD_PERVEN := _PERVCFD
				CFD->CFD_COD	 := _PRD_CFD
				CFD->CFD_OP		 := _OP__CFD
				CFD->CFD_VPARIM := (((_nTLEVlr - _nTLEFre - _nTLESeg - _nTLE_II) / _nTLEQtd) * ((_nTLIQtd / _nTLEQtd) * 100)) / 100
				CFD->CFD_VSAIIE := _VLS_CFD
				CFD->CFD_CONIMP := _nCI
				CFD->CFD_FCICOD := _COD_CFD
				CFD->CFD_FILOP	 := _FIL_CFD
				CFD->CFD_ORIGEM := xCIOrigem(_nCI)
				MsUnLock()
			Endif
		Endif

		DbSelectArea("TMP1")
		DbSkip()
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga arquivo e indice temporario   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//DbSelectArea("cNomeArq")
	//dbCloseArea()
	//Ferase(cNomeArq+GetDBExtension())
	//Ferase(cNomeArq+OrdBagExt())
	TMP1->(DbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga arquivo e indice temporario 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//DbSelectArea("cNomeArq1")
	//dbCloseArea()
	//Ferase(cNomeArq1+GetDBExtension())
	//Ferase(cNomeArq1+OrdBagExt())
	TMP1->(DbCloseArea())

	If MV_PAR01 == 1 			// CASO SEJA PARA GERAR RELATÓRIO
		If li!=80
			Roda(0,"",Tamanho)
		Endif
		SetPrc(0,0)       	// (Zera o Formulario)
		Set Device To Screen
		If aReturn[5]==1
			Set Printer TO
			dbcommitAll()
			ourspool(wnrel)
		Endif
		MS_FLUSH()   //Libera fila de relatorios em spool (Tipo Rede Netware)
	Endif

	If __lIsP12 .And. oSelf <> Nil
		oSelf:Savelog("FIM")
	EndIf

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função para retorno do Ano ou Mês                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function xRetYear(cAno,cMes,nTipo)
	Local	cNwYear	:=	""
	Default nTipo	:= 1

	// Caso esteja processando Novembro ou Dezembro, atualizo ano posterior
	If nTipo == 1		// Ano
		If cMes $ "11/12"
			cNwYear := Alltrim(Str(Val(cAno)+1))
		Else
			cNwYear := cAno
		Endif
	Else					// Mes
		If cMes == "11"
			cNwYear := "01"
		ElseIf cMes == "12"
			cNwYear := "02"
		Else
			cNwYear := StrZero(Val(cMes)+2,2)
		Endif
	EndIf

Return(cNwYear)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função que retorna o codigo da origem conforme Conteudo de Importacao informado como parametro   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function xCIOrigem(nCI)
	Local	cOrigem	:=	""

	Do Case
		Case nCI == 0
		cOrigem := "0"						// 0 - Nacional, exceto as indicadas nos códigos 3, 4, 5 e 8
		Case nCI == 100
		cOrigem := "1"						// 1 - Estr.(Importacao Direta)
		Case nCI > 40 .And. nCI <= 70
		cOrigem := "3"						// 3 - Nacional-Mer/bem Cont de Import sup 40% e inf/igual 70%
		Case nCI > 0 .And. nCI < 40
		cOrigem := "5"						// 5 - Nacional-Merc/bem com Cont de Import inf ou igual a 40%
		Case nCI > 70
		cOrigem := "8"						// 8 - Nacional-Merc/bem com Cont de Import superior a 70%
	End Case

Return(cOrigem)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo de log para conferencia                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Log(_sTexto)

	Local _nHdl    := 0
	Local _sArqLog := "\mgt_fci.txt"

	If file (_sArqLog)
		_nHdl = fOpen(_sArqLog, 1)
	Else
		_nHdl = fCreate(_sArqLog, 0)
	Endif

	fSeek(_nHdl, 0, 2)      // Encontra final do arquivo
	fWrite(_nHdl, _sTexto + chr (13) + chr (10))
	fClose(_nHdl)

Return
