#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} BXRAPCSV
@Type			: Função de Usuário
@Sample			: U_BXRAPCSV()
@Description	: Função para baixar títulos tipo "RAP" no Protheus via planilha .CSV
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Fev/2025
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function BXRAPCSV()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aInfo		   := {}
	Local oProcess
	Local bProcess	   := {|oSelf| ImpCSV ( oSelf ) }
	Local cFunction    := "BXRAPCSV"
	Local cTitle	   := "Baixa de títulos tipo 'RAP' conforme planilha .CSV"
	Local cDescription := "Rotina responsável pela baixa de títulos tipo 'RAP' conforme planilha .CSV" + CRLF + CRLF + ;
						  "Selecione a DATABASE desejada, pois esta será usada para considerar a data da baixa." + CRLF + CRLF + ;
						  "CLIQUE NO BOTÃO ABAIXO, SELECIONE O ARQUIVO .CSV E AGUARDE A CONCLUSÃO DO PROCESSAMENTO."

	//Private cPerg	   := "BXRAPCSV"

	// Botão para visualização do log de processamento
	Aadd(aInfo,{"Históricos de Processamentos", { || ProcLogView(,FunName()) },"WATCH" })

	oProcess := tNewProcess():New( cFunction,;
								cTitle,;
								bProcess,;
								cDescription,;
								Nil,;			// cPerg
								aInfo,;
								.T.,;
								5,;
								"Painel Auxiliar",;
								.T.)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} ImpCSV
Tratamento para a utilização do tNewProcess
@author     Evandro Mugnol
@since      Fev/2025
/*/
//----------------------------------------------------------------------
Static Function ImpCSV( oSelf )

	Processa( .F., oSelf )

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} ImpCSV
Função que efetua o processamento das informações
@author     Evandro Mugnol
@since      Fev/2025
/*/
//----------------------------------------------------------------------
Static Function Processa( lBat, oSelf )

	Local cDirLog  := GetTempPath()
	Local cArqLog  := "BaixaRAP_" + DTOS(Date()) + "_" + StrTran(Time(), ':', '-') + ".Log"
	Local cDiret
	Local cLinha   := ""
	Local lPrimlin := .T.
	Local aCampos  := {}
	Local aDados   := {}
	Local nX

	Private aDadosSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt, {"M0_NOMECOM", ;
	                                                                "M0_ENDENT",  ;
																	"M0_BAIRENT", ;
																	"M0_CEPENT",  ;
																	"M0_CIDENT",  ;
																	"M0_ESTENT",  ;
																	"M0_CGC"	 }) 

	cDiret := cGetFile( 'Arquito CSV|*.csv| Arquivo TXT|*.txt| Arquivo XML|*.xml',; //[ cMascara],
						'Seleção de Arquivo',;                  					//[ cTitulo],
						0,;                                      					//[ nMascpadrao],
						'C:\',;   		                         					//[ cDirinicial],
						.F.,;                                    					//[ lSalvar],
						GETF_LOCALHARD  + GETF_NETWORKDRIVE,;    					//[ nOpcoes],
						.T.)

	Private nHandle := FT_FUSE(cDiret)

	// Carrega variaveis para gerar LOG de processamento
	cMask  := "Arquivos Texto (*.TXT) |*.txt|"
	cTexto := "Verifique abaixo o resultado do processamento"+CHR(13)+CHR(10)
	cTexto += Replicate("-",128) + CHR(13)+CHR(10)
	cTexto += "Empresa / Filial ... " + cEmpAnt + " / " + cFilAnt + " => " + AllTrim(aDadosSM0[1][2]) + CHR(13)+CHR(10)
	cTexto += Space(128) + CHR(13)+CHR(10)
	cTexto += Replicate("-",128) + CHR(13)+CHR(10)

	If nHandle == -1
		Return
	EndIf

	FT_FGOTOP()

	While !FT_FEOF()

		oSelf:IncRegua1("Baixando pelo arquivo CSV ... ")
		oSelf:IncRegua2()

		cLinha := FT_FREADLN()

		If lPrimlin
			aCampos := Separa(cLinha,";",.T.)
			lPrimlin := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MUDA PARÂMETRO DE CONTABILIZA ON LINE PARA 'NÃO' NOS PARÂMETROS DA FINA070  ³
	//³ ANTES DA ROTINA AUTOMÁTICA PARA NÃO CONTABILIZAR OS TÍTULOS DE RAPEL        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("FIN070", .F.) 	// Carrega as MV_PAR's sem exibir a tela
	// Enviar o 4º parâmetro como .T. para atualizar no SX1/Profile
	SetMVValue("FIN070", "MV_PAR04", 2, .T.) 	// Contabiliza On Line ?   1=Sim ; 2=Não

	_lProcessa := .F.
	For nX:=1 to Len(aDados)

		oSelf:IncRegua1("Baixando ...   Título: " + aDados[nX,1] + " Prefixo: " + aDados[nX,2])
		oSelf:IncRegua2()

		_cNumTit  := PADR(AllTrim(aDados[nX,1]) , 09, "")
        _cPrefixo := PADR(AllTrim(aDados[nX,2]) , 03, "")
		_cClieTit := GetAdvFVal("SF2", "F2_CLIENTE", FWxFilial("SF2") + _cNumTit + _cPrefixo, 1, Space(TamSx3("F2_CLIENTE")[1]), .T.)
		_cLojaTit := GetAdvFVal("SF2", "F2_LOJA"   , FWxFilial("SF2") + _cNumTit + _cPrefixo, 1, Space(TamSx3("F2_LOJA")[1])   , .T.)
        _nVlrBaix := Val(StrTran(aDados[nX,3], ",", "."))
		_cHisBaix := AllTrim(aDados[nX,4])

		DbSelectArea("SE1")
		DbSetOrder(2)
		If DbSeek(FWxFilial("SE1") + _cClieTit + _cLojaTit + "R  " + _cNumTit + "  " + "RAP")
			If SE1->E1_SALDO != 0
				aBaixa := {}
				aBaixa := {	{"E1_PREFIXO"  , "R  "          	,Nil    },;
							{"E1_NUM"      , _cNumTit   	    ,Nil    },;
							{"E1_PARCELA"  , "  "   	        ,Nil    },;
							{"E1_TIPO"     , "RAP" 	            ,Nil    },;
							{"E1_CLIENTE"  , _cClieTit			,Nil 	},;
							{"E1_LOJA"     , _cLojaTit  		,Nil 	},;
							{"E1_NATUREZ"  , "110207"   		,Nil 	},;
							{"AUTMOTBX"    , "NOR"              ,Nil    },;
							{"AUTBANCO"    , "RAP"              ,Nil    },;
							{"AUTAGENCIA"  , "001"              ,Nil    },;
							{"AUTCONTA"    , "00001"           	,Nil    },;
							{"AUTDTBAIXA"  , dDataBase          ,Nil    },;
							{"AUTDTCREDITO", dDataBase          ,Nil    },;
							{"AUTHIST"     , _cHisBaix     		,Nil    },;
							{"AUTJUROS"    , 0            		,Nil,.T.},;
							{"AUTDESCONT"  , 0				    ,Nil,.T.},;
							{"AUTVALREC"   , _nVlrBaix          ,Nil    } }
			
				lMsErroAuto := .F.
				
				Begin Transaction

				MSExecAuto({|x,y| Fina070(x,y)}, aBaixa, 3)

				If lMsErroAuto
					cTexto += "Titulo NÃO BAIXADO      -> Titulo: " + SE1->E1_NUM + " Prefixo: " + SE1->E1_PREFIXO + " Parcela: " + SE1->E1_PARCELA + " Tipo: " + SE1->E1_TIPO + " Cliente: " + SE1->E1_CLIENTE  + " Loja: " + SE1->E1_LOJA + " Saldo RS " + Transform(SE1->E1_SALDO, "@E 999,999.99") + " Valor Baixa RS " + Transform(_nVlrBaix, "@E 999,999.99") + CHR(13) + CHR(10)
					MostraErro()
					DisarmTransaction()
				Else
					cTexto += "Titulo BAIXADO          -> Titulo: " + SE1->E1_NUM + " Prefixo: " + SE1->E1_PREFIXO + " Parcela: " + SE1->E1_PARCELA + " Tipo: " + SE1->E1_TIPO + " Cliente: " + SE1->E1_CLIENTE  + " Loja: " + SE1->E1_LOJA + " Saldo RS " + Transform(SE1->E1_SALDO, "@E 999,999.99") + " Valor Baixa RS " + Transform(_nVlrBaix, "@E 999,999.99") + CHR(13) + CHR(10)
				EndIf

				End Transaction
			Else
				cTexto += "Titulo NÃO POSSUI SALDO -> Titulo: " + SE1->E1_NUM + " Prefixo: " + SE1->E1_PREFIXO + " Parcela: " + SE1->E1_PARCELA + " Tipo: " + SE1->E1_TIPO + " Cliente: " + SE1->E1_CLIENTE  + " Loja: " + SE1->E1_LOJA + CHR(13) + CHR(10)
			EndIf
			_lProcessa := .T.
		Else
			cTexto += "Titulo NÃO ENCONTRADO   -> Titulo: " + _cNumTit + " Prefixo: " + "R  " + " Parcela: " + "  " + " Tipo: " + "RAP" + " Cliente: " + _cClieTit  + " Loja: " + _cLojaTit + CHR(13) + CHR(10)
			_lProcessa := .T.
		EndIf

	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MUDA PARÂMETRO DE CONTABILIZA ON LINE PARA 'SIM' NOS PARÂMETROS DA FINA070  ³
	//³ DEPOIS DA ROTINA AUTOMÁTICA PARA PODER VOLTAR A CONTABILIZAÇÃO PELO PADRÃO  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("FIN070", .F.) 	// Carrega as MV_PAR's sem exibir a tela
	// Enviar o 4º parâmetro como .T. para atualizar no SX1/Profile
	SetMVValue("FIN070", "MV_PAR04", 1, .T.) 	// Contabiliza On Line ?   1=Sim ; 2=Não

	FWAlertSuccess("Baixa de títulos tipo 'RAP' conforme planilha CSV finalizado. Verifique o Log na próxima tela.","Fim. Concluído PROCESSAMENTO.")

	If _lProcessa
		// Se tiver log, mostra ele
		If !Empty(cTexto)
			MemoWrite(cDirLog + cArqLog, cTexto)
			ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
		EndIf
	EndIf

Return
