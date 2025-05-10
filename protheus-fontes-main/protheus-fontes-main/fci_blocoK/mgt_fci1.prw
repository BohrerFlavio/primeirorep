#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function MGT_FCI1()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ MGT_FCI1 ³ Autor ³ Evandro Mugnol        ³ Data ³ Nov/2014 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Rotina para geração da tabela para produtos novos.         ³±±
	±±³          ³                                                            ³±±
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
	Local cFunction 	 := "MGT_FCI1"
	Local cTitle	 	 := "Geração Tabela CFD para Produtos Novos"
	Local bProcess 

	Local	cDescription := "Rotina responsável pela geração da tabela CFD para produtos novos." + CRLF + ;
	"Para executar a geração, informe o código do produto novo a ser processado. Clique no botão abaixo e aguarde a conclusão do processamento." + CRLF + CRLF +;
	"LOG DE PROCESSOS: Log de todos os processos executados desta rotina."

	Local oProcess
	Local __lIsP12   := GetVersao(.F.) == "12"

	Private cPerg		:= "MGT_FCI1"
	Private cCadastro := OemToAnsi("Geração Tabela CFD para Produtos Novos")

	If __lIsP12
		oProcess := tNewProcess():New( cFunction, cTitle, {|oSelf| FCINewPerg ( oSelf ) }, cDescription, cPerg )
	Else
		ProcLogIni( aButtons )
		Pergunte(cPerg,.F.)
		AADD (aSays, OemToAnsi( " Rotina responsável pela geração da tabela CFD para produtos novos." ))
		AADD (aSays, OemToAnsi( "Para executar a geração, informe o código do produto novo a ser    " ))
		AADD (aSays, OemToAnsi( "processado.  Clique no botão abaixo e aguarde a conclusão do       " ))
		AADD (aSays, OemToAnsi( "processados.  A rotina irá gerar log de todos os processos         " ))
		AADD (aSays, OemToAnsi( "executados desta rotina.                                           " ))

		AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
		AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
		AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )

		FormBatch( cCadastro, aSays, aButtons ,,,420)

		If nOpcA == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o log de processamento   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ProcLogAtu("INICIO")

			Processa({|lEnd| CFDProc()})		  		// Chamada da funcao de processamento

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
±±³Funcao    ³ FCINewPerg³ Autor ³ Evandro Mugnol       ³ Data ³ Nov/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento para a utilização do tNewProcess				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FCINewPerg( oSelf )

	CFDProc(.F.,oSelf)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CFDProc   ³ Autor ³ Evandro Mugnol       ³ Data ³ Nov/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função que efetua o processamento das informações          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CFDProc( lBat, oSelf )

	lBat  := If( ValType( lBat ) <> 'L', .F., lBat)
	oSelf := If( ValType( oSelf ) <> 'O', Nil, oSelf)

	If !lBat
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula total de registros a serem processados corretamente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT COUNT( R_E_C_N_O_ ) TOTREG "
		cQuery += "  FROM " + RetSQLName("SB1")
		cQuery += " WHERE	B1_FILIAL ='" + xFilial("SB1") + "'"
		cQuery += "   AND B1_COD = '" + mv_par01 + "'"
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Seleção dos movimentos de saídas (SD2)
	cQuery := "SELECT * "
	cQuery += "  FROM " + RetSQLName("SB1")
	cQuery += " WHERE	B1_FILIAL ='" + xFilial("SB1") + "'"
	cQuery += "   AND B1_COD = '" + mv_par01 + "'"
	cQuery += "   AND D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)

	_log("PRODUTO     ==> " + cQuery)

	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "PROD", .F., .T.)

	PROD->(dbGoTop())
	While PROD->(!Eof())
		If !lBat
			If __lIsP12 .And. oSelf <> Nil
				oSelf:IncRegua1("Selecionando Registros...")
				oSelf:IncRegua2()
			Else	
				IncProc()
			EndIf	
		Endif

		_cProduto := PROD->B1_COD
		_cDescPrd := PROD->B1_DESC
		_nPreco   := PROD->B1_PRV1

		If _nPreco > 0
			DbSelectArea("CFD")
			DbSetOrder(1)
			DbGoBottom()		  // Posiciona no último registro físico na ordem ativa
			_cPerCal := CFD->CFD_PERCAL
			_cPerVen := CFD->CFD_PERVEN
			_nVParIm := CFD->CFD_VPARIM

			RecLock("CFD",.T.)
			CFD->CFD_FILIAL := xFilial("CFD")
			CFD->CFD_PERCAL := _cPerCal
			CFD->CFD_PERVEN := _cPerVen
			CFD->CFD_COD	 := _cProduto
			CFD->CFD_OP		 := Space(15)
			CFD->CFD_VPARIM := _nVParIm
			CFD->CFD_VSAIIE := _nPreco
			CFD->CFD_CONIMP := (_nVParIm / _nPreco) * 100
			CFD->CFD_FCICOD := Space(36)
			CFD->CFD_FILOP	 := Space(02)
			CFD->CFD_ORIGEM := xCIOrigem((_nVParIm / _nPreco) * 100)
			MsUnLock()

			_log("PRODUTO     ==> " + _cProduto + " - " + _cDescPrd + "-" + Transform(_nPreco, "@E 999,999.99"))
		Else
			MsgAlert("Campo 'Preço Venda' do cadastro de produtos está ZERO. Rotina não irá gerar informação na tabela CFD para o FCI.")
			_log("PRODUTO     ==> " + _cProduto + " - " + _cDescPrd + "-" + Transform(_nPreco, "@E 999,999.99") + " NAO GERADO NA TABELA CFD")
		Endif	

		PROD->(DbSkip())
	Enddo

	PROD->(DbCloseArea())

	If __lIsP12 .And. oSelf <> Nil
		oSelf:Savelog("FIM")
	EndIf

Return


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
	Local _sArqLog := "\mgt_fci1.txt"

	If file (_sArqLog)
		_nHdl = fOpen(_sArqLog, 1)
	Else
		_nHdl = fCreate(_sArqLog, 0)
	Endif

	fSeek(_nHdl, 0, 2)      // Encontra final do arquivo
	fWrite(_nHdl, _sTexto + chr (13) + chr (10))
	fClose(_nHdl)

Return
