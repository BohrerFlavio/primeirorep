#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Rwmake.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"
#INCLUDE "Colors.ch"

#DEFINE ENTER Chr(13)+Chr(10)

User Function PMXML006()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ PMXML006 ³ Autor ³ Evandro Mungol        ³ Data ³ Jun/2013 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Importa os arquivos XML para conhecimento de transporte    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para clientes TOTVS                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local _aArea  		:= FWGetArea()
	Local lWeb          := .F.
	Local aFiles        := {}
	Local nX            := 0                
	Local _i
	Private aContas     := {}
	Private cIniFile    := GetAdv97()
	Private cStartPath  := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "CTEVINC\ENTRADA\"
	Private cStartLido  := Trim(cStartPath) + "OLD\"
	Private cStartLog   := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "CTEVINC\LOG\"
	Private c2StartPath := Trim(cStartLido) + AllTrim(Str(Year(Date()))) + "\" 
	Private c3StartPath := Trim(c2StartPath) + AllTrim(Str(Month(Date()))) + "\"
	Private cStartError := Trim(cStartPath) + "ERRO\"
	Private _sArqLog 	  := alltrim(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ))+"\CTEVINC\LOG\IMPCTEVINC_"+dtos(ddatabase)+"_"+strtran(left(time(),5),":","")+".TXT"
	Private _cLog		  := ""
	Private _nImpOk 	  := 0
	Private cEmailTo    := "" 		     	// Indica a conta de e-mail do campo FROM no envio dos e-mails internos de processamento dos arquivos XML
	Private _cChavCTE   := ""

	// Verifica se está rodando via menu ou schedule
	If Select("SX6") == 0
		lWeb := .T.
		RpcSetType(3)
		RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
	EndIf                     

	If cEmpAnt $ "02/03/04/05/06"
		Alert("Rotina não será executada para a empresa selecionada.")  
		Return
	Endif

	//cEmailto := "evandro.mugnol@gmail.com"		//Alltrim(GetMv("PS_CTEMAIL"))
	cEmailto := Alltrim(GetMv("PS_CTEMAIL"))
	// Cria Diretórios
	MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'CTEVINC\')
	MakeDir(Trim(cStartPath))		// Cria Diretório ENTRADA
	MakeDir(cStartLido)             // Cria Diretório ARQUIVOS IMPORTADOS
	MakeDir(c2StartPath)            // Cria Diretório ANO
	MakeDir(c3StartPath)            // Cria Diretório MES
	MakeDir(cStartError)            // Cria Diretório ERRO
	MakeDir(cStartLog)              // Cria Diretório LOG

	aNotFiles := Directory(cStartPath+"*.*")

	For _i := 1 to len(aNotFiles)
		if upper(right(alltrim(aNotFiles[_i,1]),4)) <> '.XML'	
			FErase(cStartPath+aNotFiles[_i,1])
		Endif
	Next _i

	aFiles := Directory(cStartPath + "*.xml")
	nXml   := 0

	If Len(aFiles) > 0
		_cLog := "IMPORTAÇÃO DE "+transform(Len(aFiles),"@E 999")+" ARQUIVOS DE XML CT-e VINCULADOS A(S) NOTA(S) ORIGINAL(IS)" +ENTER
	Endif
	For nX := 1 To Len(aFiles)
		cFilBk  := cFilAnt
		nRegSM0 := SM0->(Recno())
		nXml++
		MsAguarde({|| _ImpCTEV(alltrim(aFiles[nX,1]),.T.)},"Aguarde","Importando dados do arquivo XML...",.F.)
		SM0->(DbGoTo(nRegSM0))
		cFilAnt := cFilBk
		// Quando tiver 500 XML sai da rotina, senão estoura o array do XML
		If nXml == 500
			Exit
		EndIf
	Next nX

	If !Empty(_cLog)
		_cLog += ENTER
		_cLog += "XML CT-e VINCULADOS IMPORTADOS:     " + Transform(_nImpOK,"@E 999")+ENTER
		_cLog += "XML CT-e VINCULADOS NÃO IMPORTADOS: " + Transform(Len(afiles)-_nImpOK,"@E 999")+ENTER   
		_log(_cLog)
		U_EnvMail1('',cEmailTo,'',_cLog,' LOG Importacao XML CT-e Vinculados' ,"")
	Endif

	If lWeb
		RpcClearEnv()
	Endif

	FWRestArea(_aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ _IMPCTEV ³ Autor ³ Evandro Mugnol        ³ Data ³ Jun/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para leitura de XMLs de CT-e Vinculados e importação³±±
±±³          ³ como conhecimento de transporte                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function _ImpCTEV(cFile,lJob)
	Local cXML      := ""
	Local cError    := ""
	Local cWarning  := ""
	Local cCGC	    := ""
	Local cDoc	    := ""
	Local cSerie    := ""
	Local cLoja	    := ""
	Local lFound    := .F.
	Local lProces   := .T.
	Local nX		    := 0
	Local nY		    := 0
	Local oFullXML  := NIL
	Local oAuxXML   := NIL
	Local oXML	    := NIL
	Local aItens    := {}
	Local oDlg
	Local cMUORITR 	:= ""
	Local cMUDESTR 	:= ""
	Local nCont

	Private _oTela, _oConfir
	Private _cTitulo    := OemToAnsi("TES p/ Docto do Conhec. Frete")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial34 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private cCodTES     := Space(03)
	Private cDescri     := Space(120)

	Default lJob := .T.

	If !File(cStartPath +cFile)
		_cLog += padr("Erro: Arquivo Inexistente.",100)+"Arquivo: "+cFile+ENTER		
		lProces := .F.
	Else
		cXML := MemoRead(cStartPath +cFile)
		//-- Nao processa NFE
		If "</NFE>" $ Upper(cXML)
			FErase(cStartPath+cFile)
			lProces := .F.
			_cLog += padr("Erro: XML referente a NF-e.",100)+"Arquivo: "+cFile+ENTER		
		EndIf     
		if lProces     
			If "</CANCNFE>" $ Upper(cXML) .OR. "</CANCCTE>" $ Upper(cXML)
				FErase(cStartPath+cFile)
				lProces := .F.
				_cLog += padr("Erro: XML referente a cancelamento de NF-e ou CT-e.",100)+"Arquivo: "+cFile+ENTER
			EndIf     
		Endif       	
	EndIf

	If lProces 
		oFullXML := XmlParserFile(cStartPath + cFile,"_",@cError,@cWarning)

		//-- Erro na sintaxe do XML
		If Empty(oFullXML) .Or. !Empty(cError)
			_cLog += padr("Erro: Sintaxe XML.",100)+"Arquivo: "+cFile+ENTER			

			_MoveArq(cFile,1)
			lProces := .F.
		Else
			oXML    := oFullXML
			oAuxXML := oXML

			//-- Resgata o no inicial do CT-e
			While !lFound
				oAuxXML := XmlChildEx(oAuxXML,"_CTE")
				If !(lFound := oAuxXML # NIL)
					For nX := 1 To XmlChildCount(oXML)
						oAuxXML := XmlChildEx(XmlGetchild(oXML,nX),"_CTE")
						lFound := oAuxXML:_INFCTE # Nil
						If lFound
							oXML := oAuxXML
							Exit
						EndIf
					Next nX
				EndIf

				If lFound
					oXML := oAuxXML
					Exit
				EndIf
			EndDo                             

			//VERIFICAR PARA QUAL FILIAL SERA IMPORTADO
			cCNPJRem  := oXML:_INFCTE:_REM:_CNPJ:TEXT			// CNPJ do Remetente
			cCNPJDest := oXML:_INFCTE:_DEST:_CNPJ:TEXT		// CNPJ do Destinatário
			cCNPJTran := oXML:_INFCTE:_EMIT:_CNPJ:TEXT		// CNPJ da Transportadora

			/*  Inclusão Flávio a pedido de Henrique Jardim para complemento no arquivo do SPED*/
			//   oXML:_INFCTE:_Ide:_nCT:Text
			cMUORITR := oXML:_INFCTE:_REM:_ENDERREME:_CMUN:TEXT
			cMUDESTR := oXML:_INFCTE:_DEST:_ENDERDEST:_CMUN:TEXT
			/*Inclusão a pedido do Henrique para complementar Entrada e gerar arquivo SPED Correta - Flávio 14/03/18*/							
			_cMU := alltrim(cMUORITR)
			_cMUR := alltrim(cMUDESTR)
			_cMUO := substr(_cMU,3,7)
			_cMUD := substr(_cMUR,3,7)

			_lAchou := .F.
			dbSelectArea("SM0")
			dbSetOrder(1)
			dbGoTop()
			While !Eof()
				If M0_CGC == cCNPJDest
					_lAchou := .T.
					cFilAnt := M0_CODFIL
					cEmpAnt := M0_CODIGO
					Exit
				EndIf
				dbSkip()
			Enddo

			If !_lAchou
				lProces := .F.
				_cLog += padr("Erro: Destinatário Inválido. CNPJ: "+cCnpjDest,100)+"Arquivo: "+cFile+ENTER
				_MoveArq(cFile,1)
			Endif

			If lProces
				lFound := .F.
				//-- Verifica se este ID ja foi processado
				DbSelectArea("SF1")
				SF1->(DbSetOrder(8))
				lFound := SF1->(DbSeek(xFilial("SF1")+Right(AllTrim(oXML:_INFCTE:_ID:TEXT),44)))		// Filial + Chave do CT-e

				//PEGA A IDENT
				cIdEnt := U_WSAT01GetIdEnt()

				//VERIFICA O STATUS NA RECEITA FEDERAL E EM CASO DE REJEICAO NAO IMPORTA
				aStatus := U_CoNFeChv(Right(AllTrim(oXML:_INFCTE:_ID:TEXT),44),cIdEnt,.T.)

				If aStatus[1]
					_cLog += padr("Erro: Código erro Sefaz: "+alltrim(aStatus[3]),100)+"Arquivo: "+cFile+ENTER
					_MoveArq(cFile,1)			
					lProces := .F.
				EndIf            
			Endif

			If lProces .and. lFound
				_cLog += padr("Erro: ID de CT-e ja registrado na NF "+SF1->(F1_DOC+"/"+F1_SERIE)+" do Fornecedor " +SF1->(F1_FORNECE+"/"+F1_LOJA),100)+"Arquivo: "+cFile+ENTER

				_MoveArq(cFile,1)
				lProces := .F.
			EndIf

			//-- Se ID valido
			//-- Extrai tag _INFCTE:_chave		
			If lProces                
				/*
				If ValType(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE) == "O"
					aItens := {oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT}
				ElseIf ValType(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE) == "U"
					// Fim do bloco Alterado por Fabian Maurer
					_cLog += padr("Erro: TAG _INFCTE:_CHAVE não localizada",100)+"Arquivo: "+cFile+ENTER

					_MoveArq(cFile,1)

					lProces := .F.			
				Else
					aItens := oXML:_INFCTE:_Rem:_INFNFE:_CHAVE:TEXT
				EndIf
				*/
			EndIf
			// ==============================================================================================================================================

			If lProces
				cFornOrig  := Posicione("SA2",3,xFilial("SA2")+cCNPJRem,"A2_COD")
				cLojaOrig  := Posicione("SA2",3,xFilial("SA2")+cCNPJRem,"A2_LOJA")
				cNumConhe  := StrZero(Val(AllTrim(oXML:_INFCTE:_Ide:_nCT:TEXT)),TamSx3("F1_DOC")[1])
				cSerConhe  := PadR(oXML:_INFCTE:_Ide:_Serie:TEXT,TamSX3("F1_SERIE")[1])
				cFornDoc   := Posicione("SA2",3,xFilial("SA2")+cCNPJTran,"A2_COD")
				cLojaDoc   := Posicione("SA2",3,xFilial("SA2")+cCNPJTran,"A2_LOJA")
				cUFFornDoc := Posicione("SA2",1,xFilial("SA2")+cFornDoc+cLojaDoc,"A2_EST")
				cConhec    := cNumConhe + "-" + cSerConhe + "  de  " + AllTrim(Posicione("SA2",1,xFilial("SA2")+cFornDoc+cLojaDoc,"A2_NOME"))

				If Empty(cFornOrig) .or. Empty(cLojaOrig) .or. Empty(cFornDoc) .or. Empty(cLojaDoc)
					_cLog += padr("Erro: CNPJ/CPF Fornecedor Original: " + cCNPJRem + " ou CNPJ/CPF Fornecedor da Nota: " + cCNPJTran + " nao encontrados para a filial: "+cFilAnt,100)+"Arquivo: "+cFile+ENTER

					_MoveArq(cFile,1)
					lProces := .F.
				Endif
			Endif

			If lProces
				_cChavCTE := Iif(ValType("oXML:_INFCTE:_ID")<>"U",Right(AllTrim(oXML:_INFCTE:_ID:Text),44),"")

				aCabecCT := {}
				aItensCT := {}

				DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(200), C(800) PIXEL
				@ C(005), C(010) SAY "Informe o código do TES que será utilizada no documento de conhecimento de frete a ser gerado."   Size C(400), C(12) FONT _oFtArial34 COLOR CLR_HRED 				PIXEL OF _oTela
				@ C(020), C(010) SAY "Conhecimento Frete"																										   Size C(100), C(12) FONT _oFtArial34 COLOR CLR_HBLUE 				PIXEL OF _oTela
				@ C(020), C(080) MSGET cConhec When .F.             															 	            	   	Size C(300), C(10) FONT _oFCourier  COLOR CLR_HBLUE				PIXEL OF _oTela
				@ C(040), C(010) SAY "Código do TES"																                             	   	Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN				PIXEL OF _oTela
				@ C(040), C(080) MSGET cCodTES Valid NaoVazio() .And. _VldTES()																	 		Size C(030), C(10) FONT _oFCourier  COLOR CLR_GREEN F3 "SF4"	PIXEL OF _oTela
				@ C(055), C(010) SAY "Descrição"             															                     	  		Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN				PIXEL OF _oTela
				@ C(055), C(080) MSGET cDescri When .F.             															 	            	   	Size C(300), C(10) FONT _oFCourier  COLOR CLR_HBLUE				PIXEL OF _oTela

				DEFINE SBUTTON FROM C(080), C(300) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

				ACTIVATE MSDIALOG _oTela CENTERED                                                                        

				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega os documentos de origem                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ValType(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE)  =='A')

					For nCont := 1 to len(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE)
						nVlFrete := Round(Val(oXML:_INFCTE:_vPrest:_vTPrest:Text),2)
						cNotaOri := Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nCont]:_CHAVE:TEXT,26,09)
						DO CASE
							CASE Val(Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nCont]:_CHAVE:TEXT,23,03)) <= 9
								cSeriOri := PADR(Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nCont]:_CHAVE:TEXT,25,01),3)
							CASE Val(Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nCont]:_CHAVE:TEXT,23,03)) >= 10 .And. Val(Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nCont]:_CHAVE:TEXT,23,03)) <= 99
								cSeriOri := PADR(Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nCont]:_CHAVE:TEXT,24,02),3)
							OTHERWISE
								cSeriOri := PADR(Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nCont]:_CHAVE:TEXT,23,03),3)
						ENDCASE

						cFornNf := Posicione("SA2",3,xFilial("SA2")+Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nCont]:_CHAVE:TEXT,07,14),"A2_COD")
						cLojaNf := Posicione("SA2",3,xFilial("SA2")+Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nCont]:_CHAVE:TEXT,07,14),"A2_LOJA")

						aadd(aItensCT,{{"PRIMARYKEY",cNotaOri+cSeriOri}})

						// Verifica se existe a nota fiscal de entrada para realizar a vinculação.
						DbSelectArea("SF1")
						DbGoTop()
						DbSetOrder(1)
						DbSeek(xFilial("SF1")+cNotaOri+cSeriOri+cFornNf+cLojaNf)

						If !Found()
							_cLog += padr("Erro:  Conhecimento frete nao sera incluido pois Nota Fiscal " + cNotaOri + "/" + cSeriOri + " nao encontrada para a filial: "+cFilAnt,120)+"Arquivo: "+cFile+ENTER

							_MoveArq(cFile,1)
							lProces := .F.
							Exit
						else
							// Gravar o nome do usuário na tabela SF1 (Solicitação Cristiane Contabilidade 02/05/23)
							RecLock("SF1", .F.)
							SF1->F1_SILVA := AllTrim(UsrFullName(__cUserID))
							MsUnLock()
						Endif

					Next                                                                                   

				Else

					nVlFrete := Round(Val(oXML:_INFCTE:_vPrest:_vTPrest:Text),2)
					cNotaOri := Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,26,09)
					DO CASE
						CASE Val(Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,23,03)) <= 9
							cSeriOri := PADR(Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,25,01),3)
						CASE Val(Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,23,03)) >= 10 .And. Val(Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,23,03)) <= 99
							cSeriOri := PADR(Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,24,02),3)
						OTHERWISE
							cSeriOri := PADR(Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,23,03),3)
					ENDCASE

					cFornNf := Posicione("SA2",3,xFilial("SA2")+Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,07,14),"A2_COD")
					cLojaNf := Posicione("SA2",3,xFilial("SA2")+Substr(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,07,14),"A2_LOJA")

					aadd(aItensCT,{{"PRIMARYKEY",cNotaOri+cSeriOri}})

					// Verifica se existe a nota fiscal de entrada para realizar a vinculação.
					DbSelectArea("SF1")
					DbGoTop()
					DbSetOrder(1)
					DbSeek(xFilial("SF1")+cNotaOri+cSeriOri+cFornNf+cLojaNf)

					If !Found()
						_cLog += padr("Erro:  Conhecimento frete nao sera incluido pois Nota Fiscal " + cNotaOri + "/" + cSeriOri + " nao encontrada para a filial: "+cFilAnt,120)+"Arquivo: "+cFile+ENTER

						_MoveArq(cFile,1)
						lProces := .F.
					else
						// Gravar o nome do usuário na tabela SF1 (Solicitação Cristiane Contabilidade 02/05/23)
						RecLock("SF1", .F.)
						SF1->F1_SILVA := AllTrim(UsrFullName(__cUserID))
						MsUnLock()
					Endif

				EndIf

				/*
				For nX := 1 To Len(aItens)
					nVlFrete	:= Round(Val(oXML:_INFCTE:_vPrest:_vTPrest:Text),2)
					//cNotaOri := Substr(oXML:_INFCTE:_Rem:_InfNfe:_chave:Text,26,09)
					cNotaOri := Substr(oXML:_INFCTE:_INFCTENORM:_infDoc:_infNfe:_chave:Text,26,09)
					DO CASE
						CASE Val(Substr(oXML:_INFCTE:_INFCTENORM:_infDoc:_infNfe:_chave:Text,23,03)) <= 9
						cSeriOri := PADR(Substr(oXML:_INFCTE:_INFCTENORM:_infDoc:_infNfe:_chave:Text,25,01),3)
						CASE Val(Substr(oXML:_INFCTE:_INFCTENORM:_infDoc:_infNfe:_chave:Text,23,03)) >= 10 .And. Val(Substr(oXML:_INFCTE:_INFCTENORM:_infDoc:_infNfe:_chave:Text,23,03)) <= 99
						cSeriOri := PADR(Substr(oXML:_INFCTE:_INFCTENORM:_infDoc:_infNfe:_chave:Text,24,02),3)
						OTHERWISE
						cSeriOri := PADR(Substr(oXML:_INFCTE:_INFCTENORM:_infDoc:_infNfe:_chave:Text,23,03),3)
					ENDCASE

					cFornNf := Posicione("SA2",3,xFilial("SA2")+Substr(oXML:_INFCTE:_INFCTENORM:_infDoc:_infNfe:_chave:Text,07,14),"A2_COD")
					cLojaNf := Posicione("SA2",3,xFilial("SA2")+Substr(oXML:_INFCTE:_INFCTENORM:_infDoc:_infNfe:_chave:Text,07,14),"A2_LOJA")
					aadd(aItensCT,{{"PRIMARYKEY",cNotaOri+cSeriOri}})
					// Fim do bloco alterado por Fabian Maurer 

					// Verifica se existe a nota fiscal de entrada para realizar a vinculação.
					DbSelectArea("SF1")
					DbGoTop()
					DbSetOrder(1)
					DbSeek(xFilial("SF1")+cNotaOri+cSeriOri+cFornNf+cLojaNf)

					//_cLog += padr("Nota: Conhecimento: -" + xFilial("SF1")+"-"+cNotaOri+"-"+cSeriOri+"-"+cFornNf+"-"+cLojaNf+"-" + " Registro: " + Str(Recno()) + "> " + Alias(), 120) + ENTER

					If !Found()
						_cLog += padr("Erro:  Conhecimento frete nao sera incluido pois Nota Fiscal " + cNotaOri + "/" + cSeriOri + " nao encontrada para a filial: "+cFilAnt,120)+"Arquivo: "+cFile+ENTER

						_MoveArq(cFile,1)
						lProces := .F.
						Exit
					else
						// Gravar o nome do usuário na tabela SF1 (Solicitação Cristiane Contabilidade 02/05/23)
						RecLock("SF1", .F.)
						SF1->F1_SILVA := AllTrim(UsrFullName(__cUserID))
						MsUnLock()
					Endif
				Next nX
				*/

				If lProces
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Carrega os parâmetros do conhecimento de transporte                      ³
					//³ NÃO MUDAR A ORDEM ABAIXO, POIS OCORRE ERRO NA ROTINA AUTOMÁTICA          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aadd(aCabecCT,{""				,dDataBase-90})       	// Data Inicial
					aadd(aCabecCT,{""				,dDataBase})          	// Data Final
					aadd(aCabecCT,{""				,2})                  	// Quanto a Nota: 2=Incluir NF de Conhec. Frete ; 1=Excluir NF de Conhec. Frete
					aadd(aCabecCT,{""				,cFornOrig})           	// Fornecedor do documento de origem
					aadd(aCabecCT,{""				,cLojaOrig})           	// Loja de origem
					aadd(aCabecCT,{""				,1})                  	// Considerar tipo da nota de origem: 1=NF Normal ; 2=NF Devol./Benef.
					aadd(aCabecCT,{""				,1})                  	// Aglutina Produtos: 1=Sim ; 2=Nao
					aadd(aCabecCT,{"F1_EST"		,cUFFornDoc})				// UF de Origem do Frete
					aadd(aCabecCT,{""				,nVlFrete})            	// Valor do Conhecimento de Frete
					aadd(aCabecCT,{"F1_FORMUL"	,1})           			// Formulário Próprio: 1=Nao ; 2=Sim
					aadd(aCabecCT,{"F1_DOC"		,cNumConhe})    			// Numero da NF de Conhecimento de Frete
					aadd(aCabecCT,{"F1_SERIE"	,cSerConhe})				// Série da NF de Conhecimento de Frete
					aadd(aCabecCT,{"F1_FORNECE",cFornDoc})					// Fornecedor do documento a ser gerado
					aadd(aCabecCT,{"F1_LOJA"	,cLOjaDoc})					// Loja a ser gerado
					aadd(aCabecCT,{""				,cCodTES})            	// TES Utilizado na Classificação da NF
					aadd(aCabecCT,{"F1_BASERET",0})							// Base do ICMS Retido
					aadd(aCabecCT,{"F1_ICMRET"	,0})							// Valor do ICMS Retido
					aadd(aCabecCT,{"F1_COND"	,"009"})						// Condição de Pagamento
					aadd(aCabecCT,{"F1_EMISSAO",dDataBase})				// Emissão
					aadd(aCabecCT,{"F1_ESPECIE","CTE"})						// Espécie da Nota
					aadd(aCabecCT,{"E2_NATUREZ",""})							// Código da Natureza
					aadd(acabecCT,{"F1_DESPESA",0})							// Valor da Despesa
					aadd(acabecCT,{"F1_DESCONT",0})							// Valor do Desconto
					aadd(acabecCT,{"F1_MUORITR",_cMUO})							// Municiício de Origem
					aadd(acabecCT,{"F1_MUDESTR",_cMUD})							// Municiício de Destino
					//		   _cMU := alltrim(cMUORITR)
					//		   _cMUR := alltrim(cMUDESTR)
					//		   _cMUO := substr(_cMU,3,7)
					//		   _cMUD := substr(_cMUR,3,7)
					//		   

					//cMUORITR := oXML:_INFCTE:_REM:_ENDERREME:_CMUN:TEXT
					//cMUDESTR 

					If Len(aItensCT)>0
						Begin Transaction

							lMsErroAuto := .F.  // necessario a criacao

							MATA116(aCabecCT,aItensCT)

							If lMsErroAuto
								MostraErro()
								DisarmTransaction()	
								_cLog += padr("Erro: CTE Vinculado " + cNumConhe + "/" + cSerConhe + " com problemas na geração automática. ",100)+"Arquivo: "+cFile+ENTER
								_MoveArq(cFile,1)
							Else
								_nImpOk ++
								_cLog += padr("OK: CTE Vinculado " + cNumConhe + "/" + cSerConhe + " gerada com valor de " + Transform(nVlFrete,"@E 999,999,999.99"),100)+"Arquivo: "+cFile+ENTER
								_MoveArq(cFile,2)					
							Endif

						End Transaction
					Else                               
						_cLog += padr("Erro: Dados insuficientes para importação do CTE Vinculado ",100)+"Arquivo: "+cFile+ENTER
						_MoveArq(cFile,1)
					EndIf
				Endif

			EndIf

		EndIf

	EndIf

Return lProces

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo de log para conferencia                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Log(_sTexto)
	Local _nHdl    := 0

	If file (_sArqLog)
		_nHdl = fOpen(_sArqLog, 1)
	Else
		_nHdl = fCreate(_sArqLog, 0)
	Endif

	fSeek(_nHdl, 0, 2)      // Encontra final do arquivo
	fWrite(_nHdl, _sTexto + chr (13) + chr (10))
	fClose(_nHdl)

Return


Static Function _MoveArq(cFile,_nTipo)
	//-- Move arquivo para pasta dos erros
	cArqTXT := cStartPath+cFile
	//copia o arquivo antes da transacao
	if _nTipo == 2
		cNomNovArq  := c3StartPath+cFile
	else
		cNomNovArq  := cStartError+cFile
	Endif
	If MsErase(cNomNovArq)
		__CopyFile(cArqTXT,cNomNovArq)
		FErase(cStartPath+cFile)
	EndIf				

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Consistencia no Código do TES                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _VldTES()
	_lRet := .T.

	DbSelectArea("SF4")
	DbSetorder(1)
	If DbSeek(xFilial("SF4") + cCodTES)
		cDescri := "CFOP: " + AllTrim(SF4->F4_CF) + " - " + AllTrim(SF4->F4_DESCRI)
	Else
		cDescri := Replicate("?",120)
		MsgAlert("Nenhum TES encontrado para código informado. Verifique!!!")
		_lRet := .F.
	Endif

Return(_lRet)
