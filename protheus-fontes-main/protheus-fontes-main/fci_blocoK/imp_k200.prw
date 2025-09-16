#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} IMP_K200 
@Type			: Função de Usuário
@Sample			: U_IMP_K200()
@Description	: Rotina para importar os dados a serem inventariados pelo arquivo TXT
                  disponibilizado pelo Robson com os dados dos estoques apurados em outro
				  sistema. Tem o objetivo de ser uma rotina de plano B caso os saldos
				  apurados pelas rotinas MGK_BLK1 a 9 estejam muito divergentes.
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2014
@version		: Protheus 12.1.25 e posteriores
@Comments		: Revisão em Jun/2021 considerando situação atual para rodar em Jan/2022
/*/
//--------------------------------------------------------------------------------------
User Function IMP_K200(lBat,nOpcao)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nOpca     := 0
	Local cCadastro := OemToAnsi("Importa Dados p/ Inventário")
	Local aSays     := {}
	Local aButtons  := {}
	Local lPerg     := .F.

	Private cPerg   := "IMP_K200"

	Pergunte(cPerg,.F.)

	// Carrega texto descritivo do programa, apresentado na tela de entrada
	aAdd(aSays,OemToAnsi("Através deste programa o sistema irá gerar inventário para os   "))
	aAdd(aSays,OemToAnsi("produtos, conforme parâmetros informados pelo usuário e regras. "))
	aAdd(aSays,OemToAnsi("definidas juntamente com o cliente.                             "))

	// Define as funções dos botões da tela de entrada
	AADD(aButtons, { 5,.T.,{|| lPerg := Pergunte(cPerg,.T. ) } } )
	AADD(aButtons, { 1,.T.,{|| nOpca := If(( lPerg .Or. Pergunte(cPerg,.T.)) .And. _TudoOk() , 1, 2 ), If( nOpca == 1, FechaBatch(), Nil ) }})
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

	// Monta tela de entrada mostrando o conteúdo do aSays e com as opções de botões do aButtons
	FormBatch(cCadastro, aSays, aButtons, , 200, 405)

	// Executa o processamento
	If nOpca == 1
		Processa({|lEnd| ProcSB7(), "Gerando Inventário Produtos"})
	Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSB7
Processamento de geração dos dados importados
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function ProcSB7(nOpcao)

	// Carrega variáveis para gerar LOG de inconsistências referente aos PAs não cadastrados nas estruturas de produtos
	cMask  := "Arquivos Texto (*.TXT) |*.txt|"
	cTexto := "Verifique abaixo o resultado da importação referente produtos não importados."+CHR(13)+CHR(10)
	cTexto += Replicate("-",128)+CHR(13)+CHR(10)
	cTexto += "Empresa : "+SM0->M0_CODIGO+" - "+SM0->M0_NOME+CHR(13)+CHR(10)
	cTexto += Space(128)+CHR(13)+CHR(10)
	cTexto += Replicate("-",128)+CHR(13)+CHR(10)

	Private _sArq 	   := ""
	Private _aCab 	   := {}
	Private _aTotIitem := {}
	Private _aItem 	   := {}
	
	_aEstru := {{'_CAMPO','C',1000,0}}
	_sArq   := AllTrim(mv_par01)
	_cArq   := CriaTrab(_aEstru,.t.)
	
	DbUseArea(.t.,,_cArq,'_ARQINV',.t.,.f.)
	DbSelectArea('_ARQINV')

	APPEND FROM &_sArq SDF

	DELETE FOR Empty(_ARQINV->_CAMPO)

	DbGoTop()
	_aArquivo  := {}
	_lProcessa := .F.

	Do While !_ARQINV->(Eof())
		Pergunte(cPerg,.F.)

		_cNewCampo := Alltrim(_ARQINV->_CAMPO)
		_aLinha    := _SeparaCpo(_cNewCampo)

		aAdd(_aArquivo,_aLinha)
		_cConteudo := _aLinha[1]

		_cProduto := PADR(_aLinha[1], 15, " ")
		_cLocPad  := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_LOCPAD")
		_cTipo    := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_TIPO")
		_cGrupo   := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_GRUPO")
		_cUnd     := fBuscaCpo("SB1", 1, xFilial("SB1") + _cProduto, "B1_UM")
		_cDocumen := mv_par03
		_nQuant   := Val(_aLinha[4])
		_dDataInv := mv_par02
		_cCCusto  := mv_par04

		IncProc("Processando Produto ... " + _cProduto)

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1") + _cProduto)
		If Found()
			If SB1->B1_MSBLQL == "1"		// 1=Sim - Produto Bloqueado
				cTexto += "Produto " + AllTrim(_cProduto) + " com Qtde " + Transform(_nQuant, "@E 99,999,999.9999999") + "    está BLOQUEADO no cadastrado e não foi inventariado. Verifique e proceda ajustes." + CHR(13) + CHR(10)
				_lProcessa := .T.
				DbSelectArea("_ARQINV")
				DbSkip()
				Loop
			Endif
			If SB1->B1_RASTRO == "S"		// Possui Rastreabilidade
				cTexto += "Produto " + AllTrim(_cProduto) + " com Qtde " + Transform(_nQuant, "@E 99,999,999.9999999") + "    possui RASTREABILIDADE no cadastrado e não foi inventariado. Verifique e proceda ajustes." + CHR(13) + CHR(10)
				_lProcessa := .T.
				DbSelectArea("_ARQINV")
				DbSkip()
				Loop
			Endif
		Else
			cTexto += "Produto " + AllTrim(_cProduto) + " com Qtde " + Transform(_nQuant, "@E 99,999,999.9999999") + "    NÃO ESTÁ CADASTRADO e não foi inventariado. Verifique e proceda ajustes." + CHR(13) + CHR(10)
			_lProcessa := .T.
			DbSelectArea("_ARQINV")
			DbSkip()
			Loop
		Endif

		lMsHelpAuto := .F.  // se .T. direciona as mensagens de help
		lMsErroAuto := .F.  // necessario a criacao
		_aInvent    := {}
		_aCab 	    := {}
		_aItem 	    := {}
		_aTotIitem  := {}

		/*
		_aInvent	:= {;
					   {"B7_FILIAL"   , xFilial("SB7")      ,Nil},;
					   {"B7_COD"      , _cProduto           ,Nil},;
					   {"B7_LOCAL"    , _cLocPad            ,Nil},;
					   {"B7_TIPO"     , _cTipo              ,Nil},;
					   {"B7_DOC"      , _cDocumen           ,Nil},;
					   {"B7_QUANT"    , _nQuant             ,Nil},;
					   {"B7_DATA"     , _dDataInv           ,Nil},;
					   {"B7_DTVALID"  , _dDataInv           ,Nil} }
		*/

		If mv_par05 == 1
			_aCab  := {;
					  {"D3_TM"          , '002'               ,Nil},;
					  {"D3_CC"          , _cCCusto            ,Nil},;
					  {"D3_EMISSAO"     , _dDataInv           ,Nil}}

			_aItem := {;
					  {"D3_COD"         , _cProduto           ,Nil},;
					  {"D3_LOCAL"       , _cLocPad            ,Nil},;
					  {"D3_QUANT"       , _nQuant             ,Nil},;
					  {"D3_TIPO"        , _cTipo              ,Nil},;
					  {"D3_UM"          , _cUnd               ,Nil},;
					  {"D3_GRUPO"       , _cGrupo             ,Nil}}
		Else
			_aCab  := {;
					  {"D3_TM"          , '502'               ,Nil},;
					  {"D3_CC"          , _cCCusto            ,Nil},;
					  {"D3_EMISSAO"     , _dDataInv           ,Nil}}

			_aItem := {;
					  {"D3_COD"         , _cProduto           ,Nil},;
					  {"D3_LOCAL"       , _cLocPad            ,Nil},;
					  {"D3_QUANT"       , _nQuant             ,Nil},;
					  {"D3_TIPO"        , _cTipo              ,Nil},;
					  {"D3_UM"          , _cUnd               ,Nil},;
					  {"D3_GRUPO"       , _cGrupo             ,Nil}}
		Endif

		aadd(_aTotIitem,_aItem)
		//_aInvent := aClone (U_OrdAuto (_aInvent))        // Ordena campos conforme SX3

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera Automatico                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//DbSelectArea("SB7")
		DbSelectArea("SD3")
		Begin Transaction
			//MSExecAuto({|x,y,z| mata241(x,y,z)},_aInvent,.T.,3)
			MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab,_aTotIitem,3)
			If lMsErroAuto
				MostraErro()
				_log("Erro no Documento " + AllTrim(_cDocumen) + " para o produto / armazém " + AllTrim(_cProduto) + " / " + AllTrim(_cLocPad))
			Else
				_log("Atualizacao realizada com exito no Documento " + AllTrim(_cDocumen) + " para o produto / armazém " + AllTrim(_cProduto) + " / " + AllTrim(_cLocPad))
			EndIf
		End Transaction

		DbSelectArea("_ARQINV")
		DbSkip()
	EndDo

	DbSelectArea("_ARQINV")
	DbCloseArea()
	fErase(_cArq+'.dtc')
	fErase(_cArq+'.cdx')
	fErase(_cArq+'.idx')

	If _lProcessa
		cTexto := "Log de Processamento Imp. Inventário"+CHR(13)+CHR(10)+cTexto
		__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
		DEFINE FONT oFont NAME "Mono AS" SIZE 6,15
		DEFINE MSDIALOG oDlg TITLE "Processamento da Importação do Inventário que Necessitam de Verificação" From 000, 000 to 570,950 PIXEL
		@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 470,245 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		DEFINE SBUTTON FROM 255,395 TYPE 1  ACTION oDlg:End() ENABLE OF oDlg PIXEL                                                               // Apaga
		DEFINE SBUTTON FROM 255,365 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL     // Salva e Apaga   // "Salvar Como..."
		ACTIVATE MSDIALOG oDlg CENTER
	Endif

	Aviso("Atenção","Inventário Finalizado. Agora deverá ser feito os ajustes manuais e após rodado o Acerto de Inventário para que o processo de inventário fique completo.",{"OK"})

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _TudoOk
Valida as pergutnas
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function _TudoOk()

	Local _aArea := GetArea()
	Local _lRet  := .T.

	If _lRet
		If Empty(MV_PAR02)
			MsgInfo("A data do inventário deve ser informada.","Campo Obrigatório")
			_lRet := .F.
		Endif
	Endif

	If _lRet
		If Empty(MV_PAR03)
			MsgInfo("O codigo do documento deve ser informado.","Campo Obrigatório")
			_lRet := .F.
		Endif
	Endif

	If _lRet
		If Empty(MV_PAR04)
			MsgInfo("O codigo do Centro de Custo deve ser informado.","Campo Obrigatório")
			_lRet := .F.
		Endif
	Endif

	If _lRet
		If Empty(MV_PAR05)
			MsgInfo("Deve ser informado se é Entrada ou Saída.","Campo Obrigatório")
			_lRet := .F.
		Endif
	Endif

	RestArea(_aArea)

Return(_lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} _SeparaCpo
Efetua separação dos campos
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function _SeparaCpo(_cNewCampo)

	Local _nI

	_aRet   := {}
	_cCampo := ''
	For _nI := 1 to len(alltrim(_cNewCampo))
		If substr(_cNewCampo,_nI,1) == ';'
			aAdd(_aRet , _cCampo)
			_cCampo := ''
		ElseIf  _nI == len(alltrim(_cNewCampo))
			_cCampo += substr(_cNewCampo,_nI,1)
			aAdd(_aRet , _cCampo)
		Else
			_cCampo += substr(_cNewCampo,_nI,1)
		EndIf
	Next

Return(_aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} _SeparaCpo
Grava arquivo de log para conferencia
@Since      Dez/2014
/*/
//-------------------------------------------------------------------
Static Function _Log(_sTexto)

	Local _nHdl1    := 0
	Local _nHdl2    := 0
	Local _sArqLog1 := "\log_blocok\IMP_K200_processado_em_" + Dtos(ddatabase) + "_as_" + Substr(Time(),1,2)+"-"+Substr(Time(),4,2) + "_por_" + Alltrim(cUserName) + ".txt"
	Local _sArqLog2 := "C:\log_blocok\IMP_K200_processado_em_" + Dtos(ddatabase) + "_as_" + Substr(Time(),1,2)+"-"+Substr(Time(),4,2) + "_por_" + Alltrim(cUserName) + ".txt"

	If file (_sArqLog1)
		_nHdl1 = fOpen(_sArqLog1, 1)
	Else
		_nHdl1 = fCreate(_sArqLog1, 0)
	Endif

	If file (_sArqLog2)
		_nHdl2 = fOpen(_sArqLog2, 1)
	Else
		_nHdl2 = fCreate(_sArqLog2, 0)
	Endif

	fSeek(_nHdl1, 0, 2)      // Encontra final do arquivo
	fWrite(_nHdl1, _sTexto + chr (13) + chr (10))
	fClose(_nHdl1)

	fSeek(_nHdl2, 0, 2)      // Encontra final do arquivo
	fWrite(_nHdl2, _sTexto + chr (13) + chr (10))
	fClose(_nHdl2)

Return
