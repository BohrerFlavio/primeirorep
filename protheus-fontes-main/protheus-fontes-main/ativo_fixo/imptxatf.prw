#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} IMPTXATF
Rotina efetua importação da taxa anual depreciação informada em arquivo Excel (.CSV)
@author     Evandro
@since      26/05/2020
@return     Nil
@obs        N/A
/*/

User Function IMPTXATF()

	Private _cArq      :=  Space(500)	
	Private _nNumReg   := 0
	Private _nNumLendo := 0
	Private _nI        := 0
	Private _nJ        := 0
	Private _cLinha    := ""
	Private _lPrim     := .T.
	Private _aCampos   := {}
	Private _aDados    := {}
	Private _cCampo    := ""
	Private _cDlgTab   := "SN3"	
	Private _cNL       := CHR(13) + CHR(10)
	Private _oDlgArq
	Private _oDlgTab

	// Inicio da tela de importacao
	DEFINE MSDIALOG _oDlg FROM 001,001 TO 140,450 TITLE "Importação Taxa Anual Depreciação para Tabela SN3" PIXEL

	@ 001,001 TO 069,226 LABEL "" OF _oDlg PIXEL

	@ 025,010 SAY "Arquivo:"			SIZE 120, 7 PIXEL OF _oDlg
	@ 024,035 MSGET _oDlgArq VAR _cArq	SIZE 165, 7 WHEN .T. PIXEL OF _oDlg
	@ 027,200 BUTTON "..."				SIZE 014, 7 PIXEL OF _oDlg Action (_cArq := cGetFile("*.CSV","Selecione o Arquivo a ser importado...",1,"C:\",.T.,16,.F.))

	DEFINE SBUTTON _oBtn1 FROM 040,035 	TYPE 1 ACTION (Processa({ || _PREPARIMP()}, "Importando dados para a tabela " + _cDlgTab + "...", "por favor, aguarde.", .F.)) ENABLE OF _oDlg
	_oBtn1:cCaption := "Importar"
	_oBtn1:cToolTip := "Importar dados do arquivo para atualizar a taxa anual depreciação na tabela SN3."

	DEFINE SBUTTON _oBtn2 FROM 040,065 TYPE 2 ACTION (_oDlg:End()) ENABLE OF _oDlg
	_oBtn2:cToolTip := "Sair da Rotina"

	ACTIVATE MSDIALOG _oDlg CENTERED

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _PREPARIMP
Função que prepara ambiente para a importacao dos dados da planilha
@author     Evandro
@since      26/05/2020
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _PREPARIMP()

	// Importa os dados do arquivo para um vetor
	Processa({ || _ARQ_VET()}, "Efetuando Carga de Dados. Por Favor, aguarde.", "", .F.)

	// Importa os dados do vetor para a tabela
	If MsgYesNo("Leitura Concluída com Sucesso." + _cNl + "Deseja continuar e realizar a atualização dos registros?")
		Processa({ || _IMPORTA()}, "Importando dados. Por Favor, aguarde.", "", .F.)
		MsgAlert("Importação Concluída com Sucesso!" + _cNl + "Verifique a Situação da Importação no Arquivo de LOG em C:\Temp\LogSN3_Taxas.LOG")
	Else
		MsgAlert("Atualização dos Registros Cancelada pelo Usuário!")	
	EndIf

	// Limpa os dados para importar outro arquivo
	_cArq := Space(500)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _PREPARIMP
Função que importa os dados do arquivo para um vetor
@author     Evandro
@since      26/05/2020
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _ARQ_VET()

	// Verifica se o arquivo existe
	If !File(_cArq)
		MsgStop("O arquivo '" + _cArq + "' não foi encontrado. A importação será abortada.", "[" + FunName() + "] - Atenção!")
		Return
	EndIf

	FT_FUSE(_cArq) 				// Seleciona o arquivo para usar
	ProcRegua(FT_FLASTREC()) 	// Seta a regua para o numero de registros encontrados
	_nNumReg := FT_FLASTREC() 	// Seta o _nNumReg para o numero de registros encontrados, para usar no IncProc
	FT_FGOTOP() 				// Posiciona o arquivo no primeiro registro

	_nNumLendo := 0
	While !FT_FEOF()

		_nNumLendo++

		IncProc("Lendo registro " + cValToChar(_nNumLendo) + " de " + cValToChar(_nNumReg) + "...")

		_cLinha := FT_FREADLN() 	// Joga a linha do arquivo para a variavel

		If _lPrim 					// Se for o primeiro registro entao os dados contem os nomes dos campos que serao inseridos
			_aCampos := Separa(_cLinha, ";", .T.)
			_lPrim := .F.
		Else
			aAdd(_aDados, Separa(_cLinha, ";", .T.))
		EndIf

		FT_FSKIP()

	EndDo

	FT_FUSE() 					// Fecha o arquivo que estava em uso

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _PREPARIMP
Função que importa os dados do vetor para a tabela
@author     Evandro
@since      26/05/2020
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _IMPORTA()

	Local _nPos  	:= 0
	Local _aArea	:= GetArea()
	Local _aAreaSN3 := GetArea("SN3")	

	_nNumReg := Len(_aDados)

	ProcRegua(_nNumReg)

	_nNumLendo := 0

	// Seta o tipo do ativo por empresa
	DO CASE
		CASE cEmpAnt == "01"	// Frigorifico
		_cTipo := "01"
		CASE cEmpAnt == "07"	// Transportadora
		_cTipo := "10"
		CASE cEmpAnt == "08"	// Indústria de Rações (Graxaria)
		_cTipo := "01"
		OTHERWISE				// Caso diferente das empresas acima, seta com "XX" para não encontrar tipo na importação e não processar
		_cTipo := "XX"
	ENDCASE

	For _nPos := 1 To Len(_aDados)

		_nNumLendo++

		IncProc("Alterando registro " + cValToChar(_nNumLendo) + " de " + cValToChar(_nNumReg) + " na tabela SN3...")

		DbSelectArea("SN3")
		SN3->(dbSetOrder(1))
		SN3->(dbGoTop())
		If SN3->(dbSeek(_aDados[_nPos,1] + _aDados[_nPos,2] + _aDados[_nPos,3] + _cTipo + "0")) 

			// Efetua gravação dos dados antes da importação da taxa anual depreciação
			DbSelectArea("SZ0")
			RecLock("SZ0", .T.)				
			SZ0->Z0_FILIAL  := SN3->N3_FILIAL
			SZ0->Z0_CBASE   := SN3->N3_CBASE
			SZ0->Z0_ITEM    := SN3->N3_ITEM
			SZ0->Z0_TIPO    := SN3->N3_TIPO
			SZ0->Z0_TIPREAV := SN3->N3_TIPREAV
			SZ0->Z0_BAIXA   := SN3->N3_BAIXA
			SZ0->Z0_HISTOR  := SN3->N3_HISTOR
			SZ0->Z0_TPSALDO := SN3->N3_TPSALDO
			SZ0->Z0_TPDEPR  := SN3->N3_TPDEPR
			SZ0->Z0_CCONTAB := SN3->N3_CCONTAB
			SZ0->Z0_CUSTBEM := SN3->N3_CUSTBEM
			SZ0->Z0_CDEPREC := SN3->N3_CDEPREC
			SZ0->Z0_CCUSTO  := SN3->N3_CCUSTO
			SZ0->Z0_CCDEPR  := SN3->N3_CCDEPR
			SZ0->Z0_CDESP   := SN3->N3_CDESP
			SZ0->Z0_CCORREC := SN3->N3_CCORREC
			SZ0->Z0_NLANCTO := SN3->N3_NLANCTO
			SZ0->Z0_DLANCTO := SN3->N3_DLANCTO
			SZ0->Z0_DINDEPR := SN3->N3_DINDEPR
			SZ0->Z0_FIMDEPR := SN3->N3_FIMDEPR
			SZ0->Z0_DEXAUST := SN3->N3_DEXAUST
			SZ0->Z0_VORIG1  := SN3->N3_VORIG1
			SZ0->Z0_TXDEPR1 := SN3->N3_TXDEPR1
			SZ0->Z0_VORIG2  := SN3->N3_VORIG2
			SZ0->Z0_TXDEPR2 := SN3->N3_TXDEPR2
			SZ0->Z0_VORIG3  := SN3->N3_VORIG3
			SZ0->Z0_TXDEPR3 := SN3->N3_TXDEPR3
			SZ0->Z0_VORIG4  := SN3->N3_VORIG4
			SZ0->Z0_TXDEPR4 := SN3->N3_TXDEPR4
			SZ0->Z0_VORIG5  := SN3->N3_VORIG5
			SZ0->Z0_TXDEPR5 := SN3->N3_TXDEPR5
			SZ0->Z0_VRCBAL1 := SN3->N3_VRCBAL1
			SZ0->Z0_VRDBAL1 := SN3->N3_VRDBAL1
			SZ0->Z0_VRCMES1 := SN3->N3_VRCMES1
			SZ0->Z0_VRDMES1 := SN3->N3_VRDMES1
			SZ0->Z0_VRCACM1 := SN3->N3_VRCACM1
			SZ0->Z0_VRDACM1 := SN3->N3_VRDACM1
			SZ0->Z0_VRDBAL2 := SN3->N3_VRDBAL2
			SZ0->Z0_VRDMES2 := SN3->N3_VRDMES2
			SZ0->Z0_VRCACM2 := SN3->N3_VRCACM2
			SZ0->Z0_VRDBAL3 := SN3->N3_VRDBAL3
			SZ0->Z0_VRDMES3 := SN3->N3_VRDMES3
			SZ0->Z0_VRCACM3 := SN3->N3_VRCACM3
			SZ0->Z0_VRDBAL4 := SN3->N3_VRDBAL4
			SZ0->Z0_VRDMES4 := SN3->N3_VRDMES4
			SZ0->Z0_VRCACM4 := SN3->N3_VRCACM4
			SZ0->Z0_VRDBAL5 := SN3->N3_VRDBAL5
			SZ0->Z0_VRDMES5 := SN3->N3_VRDMES5
			SZ0->Z0_VRCACM5 := SN3->N3_VRCACM5
			SZ0->Z0_INDICE1 := SN3->N3_INDICE1
			SZ0->Z0_INDICE2 := SN3->N3_INDICE2
			SZ0->Z0_INDICE3 := SN3->N3_INDICE3
			SZ0->Z0_INDICE4 := SN3->N3_INDICE4
			SZ0->Z0_INDICE5 := SN3->N3_INDICE5
			SZ0->Z0_AQUISIC := SN3->N3_AQUISIC
			SZ0->Z0_DTBAIXA := SN3->N3_DTBAIXA
			SZ0->Z0_VRCDM1  := SN3->N3_VRCDM1
			SZ0->Z0_VRCDB1  := SN3->N3_VRCDB1
			SZ0->Z0_VRCDA1  := SN3->N3_VRCDA1
			SZ0->Z0_PERDEPR := SN3->N3_PERDEPR
			SZ0->Z0_VMXDEPR := SN3->N3_VMXDEPR
			SZ0->Z0_VLSALV1 := SN3->N3_VLSALV1
			SZ0->Z0_DEPREC  := SN3->N3_DEPREC
			SZ0->Z0_CALCDEP := SN3->N3_CALCDEP
			SZ0->Z0_PRODANO := SN3->N3_PRODANO
			SZ0->Z0_PRODMES := SN3->N3_PRODMES
			SZ0->Z0_OK      := SN3->N3_OK
			SZ0->Z0_SEQ     := SN3->N3_SEQ
			SZ0->Z0_CCDESP  := SN3->N3_CCDESP
			SZ0->Z0_CCCDEP  := SN3->N3_CCCDEP
			SZ0->Z0_CCCDES  := SN3->N3_CCCDES
			SZ0->Z0_CCCORR  := SN3->N3_CCCORR
			SZ0->Z0_SUBCTA  := SN3->N3_SUBCTA
			SZ0->Z0_SUBCCON := SN3->N3_SUBCCON
			SZ0->Z0_SUBCDEP := SN3->N3_SUBCDEP
			SZ0->Z0_SUBCCDE := SN3->N3_SUBCCDE
			SZ0->Z0_SUBCDES := SN3->N3_SUBCDES
			SZ0->Z0_SUBCCOR := SN3->N3_SUBCCOR
			SZ0->Z0_BXICMS  := SN3->N3_BXICMS
			SZ0->Z0_SEQREAV := SN3->N3_SEQREAV
			SZ0->Z0_AMPLIA1 := SN3->N3_AMPLIA1
			SZ0->Z0_AMPLIA2 := SN3->N3_AMPLIA2
			SZ0->Z0_AMPLIA3 := SN3->N3_AMPLIA3
			SZ0->Z0_AMPLIA4 := SN3->N3_AMPLIA4
			SZ0->Z0_AMPLIA5 := SN3->N3_AMPLIA5
			SZ0->Z0_CODBAIX := SN3->N3_CODBAIX
			SZ0->Z0_FILORIG := SN3->N3_FILORIG
			SZ0->Z0_CLVL    := SN3->N3_CLVL
			SZ0->Z0_CLVLCON := SN3->N3_CLVLCON
			SZ0->Z0_CLVLDEP := SN3->N3_CLVLDEP
			SZ0->Z0_CLVLCDE := SN3->N3_CLVLCDE
			SZ0->Z0_CLVLDES := SN3->N3_CLVLDES
			SZ0->Z0_CLVLCOR := SN3->N3_CLVLCOR
			SZ0->Z0_IDBAIXA := SN3->N3_IDBAIXA
			SZ0->Z0_LOCAL   := SN3->N3_LOCAL
			SZ0->Z0_NOVO    := SN3->N3_NOVO
			SZ0->Z0_QUANTD  := SN3->N3_QUANTD
			SZ0->Z0_PERCBAI := SN3->N3_PERCBAI
			SZ0->Z0_NODIA   := SN3->N3_NODIA
			SZ0->Z0_DIACTB  := SN3->N3_DIACTB
			SZ0->Z0_DTACELE := SN3->N3_DTACELE
			SZ0->Z0_VLACEL1 := SN3->N3_VLACEL1
			SZ0->Z0_VLACEL2 := SN3->N3_VLACEL2
			SZ0->Z0_VLACEL3 := SN3->N3_VLACEL3
			SZ0->Z0_VLACEL4 := SN3->N3_VLACEL4
			SZ0->Z0_VLACEL5 := SN3->N3_VLACEL5
			SZ0->Z0_CODRAT  := SN3->N3_CODRAT
			SZ0->Z0_RATEIO  := SN3->N3_RATEIO
			SZ0->Z0_PRODACM := SN3->N3_PRODACM
			SZ0->Z0_VRDACM2 := SN3->N3_VRDACM2
			SZ0->Z0_VRDACM3 := SN3->N3_VRDACM3
			SZ0->Z0_VRDACM4 := SN3->N3_VRDACM4
			SZ0->Z0_VRDACM5 := SN3->N3_VRDACM5
			SZ0->Z0_VRCDA2  := SN3->N3_VRCDA2
			SZ0->Z0_VRCDA3  := SN3->N3_VRCDA3
			SZ0->Z0_VRCDA4  := SN3->N3_VRCDA4
			SZ0->Z0_VRCDA5  := SN3->N3_VRCDA5
			SZ0->Z0_CRIDEPR := SN3->N3_CRIDEPR
			SZ0->Z0_CALDEPR := SN3->N3_CALDEPR
			SZ0->Z0_PERCDEP := SN3->N3_PERCDEP
			SZ0->Z0_CODPOOL := SN3->N3_CODPOOL
			SZ0->Z0_VLIMPER := SN3->N3_VLIMPER
			SZ0->Z0_CODIND  := SN3->N3_CODIND
			SZ0->Z0_ATFCPR  := SN3->N3_ATFCPR
			SZ0->Z0_ATVORIG := SN3->N3_ATVORIG
			SZ0->Z0_INTP    := SN3->N3_INTP
			SZ0->Z0_DATAIMP := DDATABASE
			SZ0->Z0_HORAIMP := Time()
			SZ0->Z0_NOMEUSU := AllTrim(cUserName)
			MsUnlock()
			
			DbSelectArea("SN3")
			RecLock("SN3", .F.)				
			SN3->N3_TXDEPR1 := Val( StrTran( AllTrim(_aDados[_nPos,4]), ",", "." ) )
			SN3->N3_TXDEPR2 := Val( StrTran( AllTrim(_aDados[_nPos,4]), ",", "." ) )
			SN3->N3_TXDEPR3 := Val( StrTran( AllTrim(_aDados[_nPos,4]), ",", "." ) )
			SN3->N3_TXDEPR4 := Val( StrTran( AllTrim(_aDados[_nPos,4]), ",", "." ) )
			SN3->N3_TXDEPR5 := Val( StrTran( AllTrim(_aDados[_nPos,4]), ",", "." ) )
			MsUnlock()

			_LOG("SUCESSO            => FILIAL: " + _aDados[_nPos,1] + " - CODIGO BEM: " + _aDados[_nPos,2] + " - ITEM: " + _aDados[_nPos,3] + " - TAXA ANUAL DEPREC. ATUALIZADA: " +  _aDados[_nPos,4] )
		Else
			_LOG("NÃO ENCONTRADO SN3 => FILIAL: " + _aDados[_nPos,1] + " - CODIGO BEM: " + _aDados[_nPos,2] + " - ITEM: " + _aDados[_nPos,3] + " - TAXA ANUAL DEPREC. ATUALIZADA: " +  _aDados[_nPos,4] )
		EndIf

		dbCloseArea()

	Next _nPos

	RestArea(_aArea)
	RestArea(_aAreaSN3)	 

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _PREPARIMP
Função que Grava arquivo de log para conferência
@author     Evandro
@since      26/05/2020
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _LOG(_sTexto)

	Local _nHdl     := 0
	Local _cDir     := "C:\Temp\"
	Local _cNomeArq := "LogSN3_Taxas_Empresa_" + cEmpAnt + ".LOG"
	Local _sArqLog  := ""

	_sArqLog := AllTrim(_cDir) + AllTrim(_cNomeArq)

	If file (_sArqLog)
		_nHdl = fOpen(_sArqLog, 1)
	Else
		_nHdl = fCreate(_sArqLog, 0)
	Endif

	fSeek(_nHdl, 0, 2)      // Encontra final do arquivo
	fWrite(_nHdl, _sTexto + chr (13) + chr (10))
	fClose(_nHdl)

Return
