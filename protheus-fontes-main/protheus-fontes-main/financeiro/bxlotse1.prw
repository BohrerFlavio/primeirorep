#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} BXLOTSE1
@Type			: Função de Usuário
@Sample			: U_BXLOTSE1()
@Description	: Rotina que realiza baixa em lote conforme dados atualizados em tela
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Out/2023
@version		: Protheus 12.1.33 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function BXLOTSE1()

	Local _aArea := FWGetArea()

	// Rodar somente na empresa 01
	If cEmpAnt <> "01"
		FWAlertWarning("Somente disponível para uso no Frigorífico Silva", "Rotina Inválida para esta Empresa")
		Return
	Endif

	MsAguarde({|| _ProcBX()}, "Processando ...", "Aguarde ...")

	FWRestArea(_aArea)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _ProcBX
Função que processa as baixas conforme títulos marcados
@author     Evandro Mugnol
@since      Out/2023
/*/
//----------------------------------------------------------------------
Static Function _ProcBX()
	// Fontes
	Local cFontUti  := "Tahoma"
	Local oFontAno  := TFont():New(cFontUti,,-38)
	Local oFontSub  := TFont():New(cFontUti,,-20)
	Local oFontSubN := TFont():New(cFontUti,,-20,,.T.)
	Local oFontBtn  := TFont():New(cFontUti,,-14)
    Local _nAtuReg 	:= 0
    Local _nTotReg 	:= 0
	Local nOpca
	Local nX

	Private lMarker  := .T.
	Private aTitulos := {}
    Private nValor   := 0
    Private nQtdTit  := 0

	// Janela e componentes
	Private oDlgGrp
	Private oPanGrid
	Private oGetGrid

	// Tamanho da janela
	Private aTamanho := MsAdvSize()
	Private nJanLarg := aTamanho[5]
	Private nJanAltu := aTamanho[6]

	// Variáveis de contabilização
	Private	_dDatCtb   := Ctod("")
	Private _nValor1   := 0
	Private _nValor2   := 0
	Private _nValor3   := 0
	Private _nValor4   := 0
	Private _nValor5   := 0
	Private _cCtaDeb1  := ""
	Private _cCtaDeb2  := ""
	Private _cCtaDeb3  := ""
	Private _cCtaCred1 := ""
	Private _cCtaCred2 := ""
	Private _cCCusto   := ""
	Private _cHistor1  := ""
	Private _cHistor2  := ""
	Private _cHistor3  := ""
	Private	_nTotal    := 0
	Private _MostrLcto := 1
	Private _AglutLcto := 2

	// Montando os dados, eles devem ser montados antes de ser criado o FWBrowse
	FWMsgRun(, {|oSay| fMontDados(oSay) }, "Processando", "Buscando Títulos ...")

	// Criando a janela
	DEFINE MSDIALOG oDlgGrp TITLE "TITULOS A RECEBER" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

	// Labels gerais
	@ 002, 003 						  SAY "BAIXAS EM LOTE"  SIZE 200, 030 FONT oFontAno  OF oDlgGrp COLORS RGB(031,073,125) PIXEL
    @ 002, (nJanLarg/2-001)-(0400*01) SAY cNomeCli          SIZE 300, 030 FONT oFontSub  OF oDlgGrp COLORS RGB(178,034,034) PIXEL

	// Botões
	@ 006, (nJanLarg/2-001)-(0112*01) BUTTON oBtnFech  PROMPT "Baixar"	SIZE 050, 018 OF oDlgGrp ACTION (nOpca := 1,oDlgGrp:End()) FONT oFontBtn PIXEL
	@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "SAIR"	SIZE 050, 018 OF oDlgGrp ACTION (nOpca := 2,oDlgGrp:End()) FONT oFontBtn PIXEL

	// Dados
	@ 024, 003 GROUP oGrpDad TO (nJanAltu/2-003), (nJanLarg/2-003) PROMPT "Títulos a Receber em Aberto" OF oDlgGrp COLOR 0, 16777215 PIXEL
	oGrpDad:oFont := oFontBtn

	@ 014, (nJanLarg/2-001)-(0400*01) Say "Valor Total:" 										FONT oFontSubN OF oDlgGrp COLORS RGB(149,179,215) PIXEL
	@ 014, (nJanLarg/2-001)-(0350*01) Say oValor VAR nValor Picture PesqPict("SE1","E1_VALOR") 	FONT oFontSub  OF oDlgGrp COLORS RGB( 0, 128, 0 ) PIXEL
	@ 014, (nJanLarg/2-001)-(0220*01) Say "Quantidade:" 										FONT oFontSubN OF oDlgGrp COLORS RGB(149,179,215) PIXEL
	@ 014, (nJanLarg/2-001)-(0160*01) Say oQtda VAR nQtdTit Picture "@E 99999" 					FONT oFontSub  OF oDlgGrp COLORS RGB( 0, 128, 0 ) PIXEL

	oPanGrid := tPanel():New(033, 006, "", oDlgGrp, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13), (nJanAltu/2 - 45))

	oGetGrid := FWBrowse():New()
	oGetGrid:SetOwner(oPanGrid)
    oGetGrid:setDataArray()
    oGetGrid:setArray(aTitulos)
	oGetGrid:DisableConfig()
	oGetGrid:DisableReport()
    oGetGrid:SetLocate() 	// Habilita a Localização de registros

    // Cria coluna de marcacao
    oGetGrid:AddMarkColumns({|| IIf(aTitulos[oGetGrid:nAt,01], "LBOK", "LBNO")},; 	// Code-Block image
							{|| SelectOne(oGetGrid, aTitulos)},; 					// Code-Block Double Click
							{|| SelectAll(oGetGrid, 01, aTitulos) }) 				// Code-Block Header Click


    oGetGrid:addColumn({"Prefixo" 	    	, {||aTitulos[oGetGrid:nAt,02]}, "C", "@!", 			   0, 005, 	  , .F. , 				   , .F., , "aTitulos[oGetGrid:nAt,02]", , .F., .T., , "" })
    oGetGrid:addColumn({"Número"  	    	, {||aTitulos[oGetGrid:nAt,03]}, "C", "@!", 		       0, 010, 	  , .F. , 				   , .F., , "aTitulos[oGetGrid:nAt,03]", , .F., .T., , "" })
    oGetGrid:addColumn({"Parcela" 	    	, {||aTitulos[oGetGrid:nAt,04]}, "C", "@!", 			   0, 005, 	  , .F. , 				   , .F., , "aTitulos[oGetGrid:nAt,04]", , .F., .T., , "" })
    oGetGrid:addColumn({"Tipo" 	   	    	, {||aTitulos[oGetGrid:nAt,05]}, "C", "@!", 			   0, 003, 	  , .F. , 				   , .F., , "aTitulos[oGetGrid:nAt,05]", , .F., .T., , "" })
    oGetGrid:addColumn({"Cliente / Loja"	, {||aTitulos[oGetGrid:nAt,06]}, "C", "@!", 			   0, 010, 	  , .F. , 				   , .F., , "aTitulos[oGetGrid:nAt,06]", , .F., .T., , "" })
    oGetGrid:addColumn({"Natureza" 	    	, {||aTitulos[oGetGrid:nAt,07]}, "C", "@!", 			   0, 003, 	  , .F. , 				   , .F., , "aTitulos[oGetGrid:nAt,07]", , .F., .T., , "" })
    oGetGrid:addColumn({"Vlr Original"  	, {||aTitulos[oGetGrid:nAt,08]}, "N", "@E 999,999,999.99", 2, 012, 002, .F. , 				   , .F., , "aTitulos[oGetGrid:nAt,08]", , .F., .T., , "" })
    oGetGrid:addColumn({"Vlr Saldo"	    	, {||aTitulos[oGetGrid:nAt,09]}, "N", "@E 999,999,999.99", 2, 012, 002, .F. , 				   , .F., , "aTitulos[oGetGrid:nAt,09]", , .F., .T., , "" })
    oGetGrid:addColumn({"Vlr Desc. Rapel"   , {||aTitulos[oGetGrid:nAt,10]}, "N", "@E 999,999,999.99", 2, 012, 002, .T. , {|| _CalcRec() } , .F., , "aTitulos[oGetGrid:nAt,10]", , .F., .T., , "" })
    oGetGrid:addColumn({"Vlr Recebido"  	, {||aTitulos[oGetGrid:nAt,11]}, "N", "@E 999,999,999.99", 2, 012, 002, .T. , 				   , .F., , "aTitulos[oGetGrid:nAt,11]", , .F., .T., , "" })
    oGetGrid:addColumn({"Dt Emissao"    	, {||aTitulos[oGetGrid:nAt,12]}, "D", "", 				   0, 010,    , .F. , 				   , .F., , "aTitulos[oGetGrid:nAt,12]", , .F., .T., , "" })
    oGetGrid:addColumn({"Dt Vencto"     	, {||aTitulos[oGetGrid:nAt,13]}, "D", "", 				   0, 010,    , .F. , 				   , .F., , "aTitulos[oGetGrid:nAt,13]", , .F., .T., , "" })
    oGetGrid:addColumn({"Vlr Desconto"      , {||aTitulos[oGetGrid:nAt,14]}, "N", "@E 999,999,999.99", 2, 012, 002, .F. ,                  , .F., , "aTitulos[oGetGrid:nAt,14]", , .F., .T., , "" })
    oGetGrid:addColumn({"Filial Origem"    	, {||aTitulos[oGetGrid:nAt,15]}, "C", "@!", 			   0, 002, 	  , .F. , 				   , .F., , "aTitulos[oGetGrid:nAt,15]", , .F., .T., , "" })

    oGetGrid:SetEditCell( .T. , { || .T. } ) 	// Ativa edit e code block para validacao

	oGetGrid:Activate()

	ACTIVATE MsDialog oDlgGrp CENTERED

	If nOpca == 1

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ MUDA PARÂMETRO DE CONTABILIZA ON LINE PARA 'NÃO' NOS PARÂMETROS DA FINA070  ³
		//³ ANTES DA ROTINA AUTOMÁTICA PARA PODER CONTABILIZAR TODOS TÍTULOS MARCARDOS  ³
		//³ EM UM ÚNICO DOCUMENTO PELOS LPs 120                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Pergunte("FIN070", .F.) 	// Carrega as MV_PAR's sem exibir a tela
		// Enviar o 4º parâmetro como .T. para atualizar no SX1/Profile
		SetMVValue("FIN070", "MV_PAR04", 2, .T.) 	// Contabiliza On Line ?   1=Sim ; 2=Não

		cArqCTB := ''
		nHdlPrv := HeadProva("008851", "BXLOTSE1", Substr(cUsuario,7,6), @cArqCTB)

		_nTotReg := nQtdTit
		For nX := 1 To Len(aTitulos)
			If aTitulos[nX,1] 		// Se estiver com a linha marcada

				// Incrementa a mensagem na régua
				_nAtuReg++
				MsProcTxt("Processando título marcado " + cValToChar(_nAtuReg) + " de " + cValToChar(_nTotReg) + "...")

				aBaixa := {}
				aBaixa := {	{"E1_PREFIXO"  , aTitulos[nX,02]                ,Nil    },;
							{"E1_NUM"      , aTitulos[nX,03]            	,Nil    },;
							{"E1_PARCELA"  , aTitulos[nX,04]                ,Nil    },;
							{"E1_TIPO"     , aTitulos[nX,05]                ,Nil    },;
							{"E1_CLIENTE"  , Substr(aTitulos[nX,06],01,06)  ,Nil 	},;
							{"E1_LOJA"     , Substr(aTitulos[nX,06],10,02)  ,Nil 	},;
							{"E1_NATUREZ"  , aTitulos[nX,07]   				,Nil 	},;
							{"AUTMOTBX"    , "NOR"                  		,Nil    },;
							{"AUTBANCO"    , _cPortBX                  		,Nil    },;
							{"AUTAGENCIA"  , _cAgenBX               		,Nil    },;
							{"AUTCONTA"    , _cContaBX           			,Nil    },;
							{"AUTDTBAIXA"  , _dBaixa              			,Nil    },;
							{"AUTDTCREDITO", _dBaixa              			,Nil    },;
							{"AUTHIST"     , "VALOR RECEBIDO S/ TITULO"     ,Nil    },;
							{"AUTJUROS"    , 0            					,Nil,.T.},;
							{"AUTDESCONT"  , aTitulos[nX,10]        		,Nil,.T.},;
							{"AUTVALREC"   , aTitulos[nX,11]                ,Nil    } }
			
				lMsErroAuto := .F.
				
				Begin Transaction

				MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)

				If lMsErroAuto
					MostraErro()
					DisarmTransaction()
				Else
					_cEstado := GetAdvFVal("SA1", "A1_EST", xFilial("SA1") + Substr(aTitulos[nX,06],01,06) + Substr(aTitulos[nX,06],10,02), 1, Space(TamSx3("A1_EST")[1]), .T.)
					_cNomCli := GetAdvFVal("SA1", "A1_NOME", xFilial("SA1") + Substr(aTitulos[nX,06],01,06) + Substr(aTitulos[nX,06],10,02), 1, Space(TamSx3("A1_NOME")[1]), .T.)
					_Rapelbx := GetAdvFVal("SA1", "A1_RAPELBX", xFilial("SA1") + Substr(aTitulos[nX,06],01,06) + Substr(aTitulos[nX,06],10,02), 1, Space(TamSx3("A1_RAPELBX")[1]), .T.)

					// Variáveis utilizadas nas regras dos LPs 120
					// Data da contabilização
					_dDatCtb := _dBaixa

					// Valor do lançamento 1
					If aTitulos[nX,05] == "RAP"
						_nValor1 := 0
					ElseIf aTitulos[nX,05] == "NCC"
						_nValor1 := aTitulos[nX,08]
					Else
						_nValor1 := aTitulos[nX,11]
					EndIf

					// Valor do lançamento 2
					If aTitulos[nX,07] == "110105" .Or. aTitulos[nX,05] == "NCC"
						_nValor2 := 0
					Else
						_nValor2 := aTitulos[nX,14] - aTitulos[nX,10]
					EndIf

					// Valor do lançamento 3
					If _Rapelbx == "S"
						If aTitulos[nX,10] <> 0
							_nValor3 := aTitulos[nX,10]
						Else
							_nValor3 := 0
						EndIf
					Else
						_nValor3 := 0
					EndIf

					// Valor do lançamento 4
					If aTitulos[nX,05] == "RAP"
						_nValor4 := 0
					ElseIf aTitulos[nX,05] == "NCC"
						_nValor4 := aTitulos[nX,11]
					Else
						_nValor4 := aTitulos[nX,11] + aTitulos[nX,10]
					EndIf

					// Valor do lançamento 5
					If aTitulos[nX,05] == "NCC"
						_nValor5 := aTitulos[nX,14] - aTitulos[nX,10]
					Else
						_nValor5 := 0
					EndIf

					// Carrega conta débito 1
					If aTitulos[nX,05] == "RA "
						_cCtaDeb1 := "2105011005"
					ElseIf aTitulos[nX,05] == "NCC"
						_cCtaDeb1 := GetAdvFVal("SA1", "A1_CONTA", xFilial("SA1") + Substr(aTitulos[nX,06],01,06) + Substr(aTitulos[nX,06],10,02), 1, Space(TamSx3("A1_CONTA")[1]), .T.)
					Else
						_cCtaDeb1 := GetAdvFVal("SA6", "A6_CONTA", xFilial("SA6") + _cPortBX +_cAgenBX +_cContaBX, 1, Space(TamSx3("A6_CONTA")[1]), .T.)
					EndIf

					// Carrega conta débito 2
					If _cEstado == "EX"
						_cCtaDeb2 := "4106021002"
					Else
						_cCtaDeb2 := "4105011002"
					EndIf

					// Carrega conta débito 3
					_cCtaDeb3 := "4105011008"

					// Carrega conta crédito 1
					If aTitulos[nX,05] $ "RA /NCC"
						_cCtaCred1 := GetAdvFVal("SA6", "A6_CONTA", xFilial("SA6") + _cPortBX +_cAgenBX +_cContaBX, 1, Space(TamSx3("A6_CONTA")[1]), .T.)
					ElseIf aTitulos[nX,05] == "CH "
						_cCtaCred1 := "1102022001"
					ElseIf aTitulos[nX,05] == "CHP"
						_cCtaCred1 := "1102022002"
					Else
						_cCtaCred1 := GetAdvFVal("SA1", "A1_CONTA", xFilial("SA1") + Substr(aTitulos[nX,06],01,06) + Substr(aTitulos[nX,06],10,02), 1, Space(TamSx3("A1_CONTA")[1]), .T.)
					EndIf

					// Carrega conta crédito 2
					If _cEstado == "EX"
						_cCtaCred2 := "4106021002"
					Else
						_cCtaCred2 := "4105012001"
					EndIf

					// Carrega centro de custo
					If aTitulos[nX,15] == "00"
						_cCCusto := "1111001"
					ElseIf aTitulos[nX,15] == "01"
						_cCCusto := "1211001"
					Else
						_cCCusto := ""
					EndIf

					// Carrega histórico 1
					If aTitulos[nX,05] == "CHP"
						_cHistor1 := Left("LIQUIDACAO CHQ. " + aTitulos[nX,03] + " DE " + AllTrim(_cNomCli),40)
					Else
						_cHistor1 := Left("LIQUIDACAO DUPL. " + aTitulos[nX,03] + " DE " + AllTrim(_cNomCli),40)
					EndIf

					// Carrega histórico 2
					If _cEstado == "EX"
						_cHistor2 := Left("VAR. PASSIVA FAT. " + aTitulos[nX,03] + " " + AllTrim(_cNomCli),40)
					ElseIf aTitulos[nX,05] == "NDC"
						_cHistor2 := Left("ESTORNO JUROS A MAIOR DUPL. " + aTitulos[nX,03],40)
					Else
						_cHistor2 := Left("DESC NF. " + aTitulos[nX,03] + " " + AllTrim(_cNomCli),40)
					EndIf

					// Carrega histórico 3
					_cHistor3 := "DESC. RAPEL " + AllTrim(aTitulos[nX,05]) + " " + aTitulos[nX,03] + " DE " + AllTrim(_cNomCli)

					_nTotal += DetProva(nHdlPrv,"120","BXLOTSE1","008851")
				EndIf

				End Transaction
			
			EndIf

		Next nX

		// Grava Rodapé
		RodaProva(nHdlPrv,_nTotal)

		// Envia para Lançamento Contábil
		If _MostrLcto == 1
			lDigita := .T.
		Else
			lDigita := .F.
		EndIf

		If _AglutLcto == 1
			lAglut := .T.
		Else
			lAglut := .F.
		EndIf

		If _nTotal > 0
			cA100Incl(cArqCTB,nHdlPrv,3,"008851",lDigita,lAglut,,_dDatCtb)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ MUDA PARÂMETRO DE CONTABILIZA ON LINE PARA 'SIM' NOS PARÂMETROS DA FINA070  ³
		//³ DEPOIS DA ROTINA AUTOMÁTICA PARA PODER VOLTAR A CONTABILIZAÇÃO PELO PADRÃO  ³
		//³ DO SISTEMA VIA LPs 520                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Pergunte("FIN070", .F.) 	// Carrega as MV_PAR's sem exibir a tela
		// Enviar o 4º parâmetro como .T. para atualizar no SX1/Profile
		SetMVValue("FIN070", "MV_PAR04", 1, .T.) 	// Contabiliza On Line ?   1=Sim ; 2=Não

    EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} fMontaDados
Função que monta os dados da tela
@author     Evandro Mugnol
@since      Out/2023
/*/
//----------------------------------------------------------------------
Static Function fMontDados(oSay)

	Local aArea     := GetArea()
	Local nEspLarg  := 0
	Local oDlg	    := Nil
	Local oPanel    := Nil
	Local nOpca	    := 0
	Local lRet	    := .T.
    Local cOldBanco := ""
    Local cOldAgenc := ""
    Local cOldConta := ""

	Local cQuery as Character
	Local cQryT3 as Character

	Private dVencIni := dDataBase
	Private dVencFim := dDataBase
	Private cClieIni := CRIAVAR("E1_CLIENTE")
	Private cClieFim := CRIAVAR("E1_CLIENTE")
	
	Public _dBaixa   := dDataBase
	Public cNomeCli  := ""
    Public _cPortBX	 := Criavar("EF_BANCO",.F.)
    Public _cAgenBX	 := CriaVar("EF_AGENCIA",.F.)
    Public _cContaBX := Criavar("EF_CONTA",.F.)
 
	//DEFINE MSDIALOG oDlg FROM 143,145 To 157, 190  TITLE OemToAnsi("Parâmetros") 
	DEFINE MSDIALOG oDlg FROM 5,0 To 23, 69  TITLE OemToAnsi("Parâmetros") 
	oDlg:lMaximized := .F.

    oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	//@ 002,002+nEspLarg TO 078,178+nEspLarg PIXEL OF oPanel 
    @ 002, 002 TO 107, 270 OF oPanel PIXEL
			
	@ 004,005+nEspLarg SAY OemToAnsi("Vencimento") 					SIZE 40,08 	PIXEL OF oPanel
	@ 013,005+nEspLarg MSGET dVencIni 								SIZE 45,08  PIXEL OF oPanel HASBUTTON
	@ 013,060+nEspLarg SAY OemToAnsi("Até") 						SIZE 10,08  PIXEL OF oPanel 
	@ 013,080+nEspLarg MSGET dVencFim Valid dVencFim >= dVencIni 	SIZE 50,08  PIXEL OF oPanel HASBUTTON

	@ 028,005+nEspLarg SAY OemToAnsi("Cliente") 					SIZE 40,08 	PIXEL OF oPanel
	@ 037,005+nEspLarg MSGET cClieIni F3 "CLI"  					SIZE 45,08  PIXEL OF oPanel HASBUTTON
	@ 037,060+nEspLarg SAY OemToAnsi("Até") 						SIZE 10,08  PIXEL OF oPanel 
	@ 037,080+nEspLarg MSGET cClieFim F3 "CLI" 						SIZE 45,08  PIXEL OF oPanel HASBUTTON

	@ 055,005+nEspLarg SAY OemToAnsi("Data Baixa")					SIZE 50,08	PIXEL OF oPanel
	@ 065,005+nEspLarg MSGET _dBaixa Picture "@S6" 					SIZE 65,08 	PIXEL OF oPanel HASBUTTON 

	@ 082,005+nEspLarg SAY OemToAnsi("Banco")						SIZE 40, 7 OF oPanel PIXEL
	@ 092,005+nEspLarg MSGET _cPortBX Picture "@!" F3 "SA6" Valid CarregaSa6(_cPortBX, @_cAgenBX, @_cContaBX, .T.,,,,,, @cOldBanco, @cOldAgenc, @cOldConta, "cChmBco")  SIZE 54,8 OF oPanel PIXEL HASBUTTON

	@ 082,095+nEspLarg SAY OemToAnsi("Agência")						SIZE 40, 7 OF oPanel PIXEL
	@ 092,095+nEspLarg MSGET _cAgenBX Picture "@!" Valid CarregaSa6(_cPortBX, _cAgenBX, @_cContaBX, .T.,,,,,, @cOldBanco, @cOldAgenc, @cOldConta, "cChmAge")   SIZE 54,8 OF oPanel PIXEL

	@ 082,185+nEspLarg SAY OemToAnsi("Conta")						SIZE 40, 7 OF oPanel PIXEL
	@ 092,185+nEspLarg MSGET _cContaBX Picture "@!" Valid CarregaSa6(_cPortBX, _cAgenBX, _cContaBX,.T.,,.T.,,,,cOldBanco,cOldAgenc,cOldConta, "cChmCta")        SIZE 62,8 OF oPanel PIXEL

	DEFINE SBUTTON FROM 114, 110 TYPE 1 ACTION (nOpca := 1,If(_TudoOk(),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 114, 140 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 0
		lRet := .F.
	Else
		cNomeCli := GetAdvFVal("SA1", "A1_NOME", xFilial("SA1") + cClieIni, 1, Space(TamSx3("A1_NOME")[1]), .T.)

		// Altera database se necessário
		If _dBaixa <> dDataBase
			dDataBase := _dBaixa
		Endif
		
		cQuery   := ""
		cQryT3   := GetNextAlias()
		aTitulos := {}

		cQuery := "SELECT * "
		cQuery += "  FROM " + RetSQLTab("SE1")
		cQuery += " WHERE " + RetSQLFil("SE1")
		cQuery += "   AND E1_VENCTO BETWEEN '" + DTOS(dVencIni) + "' AND '" + DTOS(dVencFim) + "'"
		cQuery += "   AND E1_CLIENTE BETWEEN '" + cClieIni + "' AND '" + cClieFim + "'"
		cQuery += "   AND E1_SALDO > 0 "
		cQuery += "   AND " + RetSQLDel("SE1")
		cQuery += " ORDER BY E1_PREFIXO, E1_NUM, E1_PARCELA"

		cQuery := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryT3, .T., .F. )
		
		(cQryT3)->(DbGoTop())
		While (cQryT3)->(!EOF())
		
			aadd(aTitulos,{ .F. ,; 
							(cQryT3)->E1_PREFIXO,;
							(cQryT3)->E1_NUM,;
							(cQryT3)->E1_PARCELA,;
							(cQryT3)->E1_TIPO,;
							(cQryT3)->E1_CLIENTE + " / " + (cQryT3)->E1_LOJA,;
							(cQryT3)->E1_NATUREZ,;
							(cQryT3)->E1_VALOR,;
							(cQryT3)->E1_SALDO,;
							(cQryT3)->E1_VLRAPEL,;
							(cQryT3)->E1_SALDO - (cQryT3)->E1_VLRAPEL,;
							Stod((cQryT3)->E1_EMISSAO),;
							Stod((cQryT3)->E1_VENCTO),;
							(cQryT3)->E1_DESCONT,;
							(cQryT3)->E1_MSFIL;
						  })
		
			(cQryT3)->(dbSkip())
		EndDo

		(cQryT3)->(dbCloseArea())
		
		DbSelectArea("SE1")
	EndIf

	RestArea(aArea)

Return lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} _TudoOk
Função para validar os gets da tela inicial do browse
@author     Evandro Mugnol
@since      Out/2023
/*/
//----------------------------------------------------------------------
Static Function _TudoOk()

	Local lRet 	 := .T.

	// Valida todos os gets
	Do Case
		Case !(dVencFim >= dVencIni)
			MsgAlert("Intervalo de vencimentos invalido. Verifique!")
			lRet := .F.
		Case Empty(cClieIni) .Or. Empty(cClieFim)
			MsgAlert("Obrigatorio Informar Cliente De/Ate. Verifique!")
			lRet := .F.
	EndCase

Return lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} SelectOne
Função de marcacao da linha por duplo clique
@author     Evandro Mugnol
@since      Out/2023
/*/
//----------------------------------------------------------------------
Static Function SelectOne(oBrowse, aArquivo)

	aArquivo[oGetGrid:nAt,1] := !aArquivo[oGetGrid:nAt,1]

    If aArquivo[oGetGrid:nAt,1]
        nValor += aArquivo[oGetGrid:nAt,11]
        nQtdTit ++
    Else
        nValor -= aArquivo[oGetGrid:nAt,11]
        nQtdTit --
    EndIf

Return .T.
 
 
//-----------------------------------------------------------------------
/*/{Protheus.doc} SelectAll
Função de marcacao de todas as linhas por duplo clique no topo do browse
@author     Evandro Mugnol
@since      Out/2023
/*/
//----------------------------------------------------------------------
Static Function SelectAll(oBrowse, nCol, aArquivo)

	Local _ni := 1

	For _ni := 1 to len(aArquivo)
		aArquivo[_ni,1] := lMarker
	Next

	lMarker := !lMarker

Return .T.


//-----------------------------------------------------------------------
/*/{Protheus.doc} _CalcRec
Função que calcula o valor recebido quando manipulado o desconto
@author     Evandro Mugnol
@since      Out/2023
/*/
//----------------------------------------------------------------------
Static Function _CalcRec()

	aTitulos[oGetGrid:nAt,11] := aTitulos[oGetGrid:nAt,9] - aTitulos[oGetGrid:nAt,10] 

Return
