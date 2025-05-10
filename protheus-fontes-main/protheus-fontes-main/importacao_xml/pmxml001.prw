#INCLUDE "Protheus.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"
#INCLUDE "XmlXFun.ch"

User Function PMXML001()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ PMXML001 ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Baixa Mensagens da NF Entrada                              ³±±
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

	Local _aArea     := FWGetArea()
	Local lWeb       := .F.
	Local aFileAtch  := {}
	Local cServer
	Local lOk        := .T.
	Local lRelauth
	Local lRet       := .F.
	Local cFrom
	Local cConta
	Local cSenhaa
	Local cIniFile   := GetADV97()
	Local cStartPath := ""
	Local nMessages  := 0
	Local aContas    := {}				// Indica a conta de e-mail para recebimento dos arquivos XML
	Local nX
	Local nY
	Local zX

	// Verifica se está rodando via menu ou schedule
	If Select("SX6") == 0
		lWeb := .T.
		RpcSetType(3)
		RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
	EndIf

	// Cria diretórios
	MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\')

	If cEmpAnt == '01'   
		MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\01\')
		cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\01\ENTRADA\'	                          
		aContas    := {{'nfef@frigorificosilva.com.br'}}     // Indica a conta de e-mail para recebimento dos arquivos XML	
		cSenhaa    := "FrigSilva@2018" //"nfenfe" Wellington  // Indica a senha da conta de e-mail para recebimento dos arquivos XML 26/07/18	
	ElseIf cEmpAnt == '07'                                                              
		MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\07\')               
		cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\07\ENTRADA\'	
		aContas    := {{'nfet@frigorificosilva.com.br'}}     // Indica a conta de e-mail para recebimento dos arquivos XML		      
		cSenhaa    := "FrigSilva@2018" //"nfenfe" Wellington // Indica a senha da conta de e-mail para recebimento dos arquivos XML	26/07/18	
	ElseIf cEmpAnt == '08'                                                           
		MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\08\')      
		cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\08\ENTRADA\'	
		aContas    := {{'nfeg@frigorificosilva.com.br'}}     // Indica a conta de e-mail para recebimento dos arquivos XML		      
		cSenhaa    := "FrigSilva@2018" //"nfenfe" Wellington // Indica a senha da conta de e-mail para recebimento dos arquivos XML 26/07/18		
	Else 
		Alert("Rotina não será executada para a empresa selecionada.")
		Return
	Endif

	//cServer  := GetMV("MV_RELSERV") 	             			// Parametro que indica o nome do servidor de e-mail
	lRelauth := GetNewPar("MV_RELAUTH",.F.)              	// Parametro que indica se existe autenticação no e-mail
	cServer := 'webmail.frigorificosilva.com.br'
	// Cria diretório de entrada
	MakeDir(Trim(cStartPath))

	/*    
	// Bloco que testa a conexão com a conta de E-mail
	//==================================================
	cServer := 'mail.frigorificosilva.com.br'
	cUser   := 'nfef@frigorificosilva.com.br'
	cPass   := 'nfenfe'
	_lRet   := .F.

	_lRet := MailPopOn (cServer, cUser, cPass)

	If _lRet
	ApMsgInfo("Conexão POP Ok")
	Else
	ApMsgInfo("Não conseguiu efetuar a conexão com o servidor POP")
	EndIf
	//==================================================
	*/ 
	For zX:=1 To Len(aContas)
		cFrom  := aContas[zX][1]
		cConta := aContas[zX][1]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Conta quantas mensagens existem                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CONNECT POP SERVER cServer ;
		ACCOUNT cConta ;
		PASSWORD cSenhaa ;
		TIMEOUT 30 ;
		RESULT lRet

		POP MESSAGE COUNT nMessages

		If nMessages > 0 .And. lRet
			MsgAlert("A conta " + AllTrim(cConta) + " contém " + StrZero(nMessages,6) + " mensagem(s) a serem recebidas")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Recebe as mensagens e grava os arquivos XML           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nXml := 0
			For nX := 1 to nMessages
				aFileAtch := {}

				MsAguarde({|| MailReceive(nX,,,,,,,aFileAtch,cStartPath,.T.)},"Aguarde","Efetuando recepção dos e-Mails da caixa postal...",.F.)

				For nY := 1 to Len(aFileAtch)  
					If ".XML" $ Upper(aFileAtch[nY][1])
						nXml++

						cStrAtch := Memoread(aFileAtch[nY][1]) 

						If Substr(cStrAtch,1,13) $ "<?xml version"
							CREATE oXML XMLSTRING cStrAtch
						Else
							MsgAlert("Arquivo " + AllTrim(aFileAtch[nY][1]) + " com problemas no layout do XML será ajustado automaticamente.")
							cStrAtch := '<?xml version="1.0"?>' + cStrAtch
							CREATE oXML XMLSTRING cStrAtch
						Endif

						// Quando tiver 500 XML sai da rotina, senão estoura o array do XML
						If nXml == 500
							Return
						EndIf
					Else                  
						Ferase(aFileAtch[nY][1])
					Endif
				Next nY
			Next nX
		Else
			MsgAlert("Não existem arquivos a serem recebidos da conta " + AllTrim(cConta))
		Endif

		DISCONNECT POP SERVER
	Next

	If lWeb
		RpcClearEnv()
	EndIf

	FWRestArea(_aArea)

Return
