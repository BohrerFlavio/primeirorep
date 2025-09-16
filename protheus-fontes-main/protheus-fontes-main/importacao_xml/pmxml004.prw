#INCLUDE "Protheus.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"
#INCLUDE "XmlXFun.ch"
#INCLUDE "totvsmail.ch"
#INCLUDE "ap5mail.ch"

User Function PMXML004()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ PMXML004 ³ Autor ³ Gustavo Cornelli      ³ Data ³ dez/2012 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Baixa Mensagens da NF conhecimento de frete                ³±±
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
	Local nTimeOut:= GetMv("MV_RELTIME",,30)
	Local cIniFile   := GetADV97()
	Local cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'CTE\ENTRADA\'
	Local nMessages  := 0
	Local aContas    :={{'cte@frigorificosilva.com.br'}}     // Indica a conta de e-mail para recebimento dos arquivos XML
	Local cEmail     := "cte@frigorificosilva.com.br"
	Local nX
	Local nY
	Local zX

	// Verifica se está rodando via menu ou schedule
	If Select("SX6") == 0
		lWeb := .T.
		RpcSetType(3)
		RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
	EndIf

	if cEmpAnt <> '01'
		Alert("Rotina não será executada para a empresa selecionada.")  
		Return
	Endif

	//cServer  := GetMV("MV_RELSERV") 	             			// Parametro que indica o nome do servidor de e-mail
	cServer  := 'webmail.frigorificosilva.com.br' // Alterado para nova forma e-mail Wellington
	lRelauth := GetNewPar("MV_RELAUTH",.F.)              	// Parametro que indica se existe autenticação no e-mail
	cSenhaa  := "FrigSilva@2018" //"ctecte" Wellington   	// Indica a senha da conta de e-mail para recebimento dos arquivos XML 26/07/18


	// Cria diretórios
	MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'CTE\')

	// Cria diretório de entrada
	MakeDir(Trim(cStartPath))

	//cUser   := 'cte@frigorificosilva.com.br'
	//cPass   := 'ctecte'

	/*_lRet := MailPopOn (cServer, cUser, cPass)

	If _lRet
	ApMsgInfo("Conexão POP Ok")
	Else
	ApMsgInfo("Não conseguiu efetuar a conexão com o servidor POP " + cServer + " Login: " + cUser + " <==> " + cPass)
	EndIf
	*/
	For zX:=1 To Len(aContas)
		cFrom  := aContas[zX][1]
		cConta := aContas[zX][1]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Conta quantas mensagens existem                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CONNECT POP SERVER cServer ;
		ACCOUNT cEmail ;
		PASSWORD cSenhaa ;
		TIMEOUT 30 ;
		RESULT lRet

		//MsgAlert("Acessando: " + AllTrim(cConta))

		POP MESSAGE COUNT nMessages

		If nMessages > 0 .And. lRet
			MsgAlert("A conta " + AllTrim(cConta) + " contém " + StrZero(nMessages,6) + " mensagem(s) a serem recebidas")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Recebe as mensagens e grava os arquivos XML           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nXml := 0
			For nX := 1 to nMessages
				aFileAtch := {}
				//RECEIVE MAIL MESSAGE w FROM aContas TO Contas SUBJECT cSubject BODY cBody ATTACHMENT aFileAtch SAVE IN (cStartPath) DELETE

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
