#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"

User Function MT010ALT()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ MT010ALT ³ Autor ³ Evandro Mugnol        ³ Data ³ Nov/2016 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ PE após a inclusão do cadastro de produto (SB1)            ³±±
	±±³          ³ Envia WF para responsável pela liberação do produto criado ³±±
	±±³          ³ Somente será enviado se os produtos forem dos tipos: ME/MP ³±±
	±±³          ³ EM/PP/PA/SP/OI                                             ³±±
	±±³          ³ O produto já é incluído bloqueado e somente será liberado  ³±±
	±±³          ³ pelo responsável definido no parâmetro ML_RESPB1           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Frigorífico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³ Manutencao Efetuada                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local _aAreaAnt := U_ML_SRArea()  	// Função para salvar e restaurar a area atual de todos os arquivos abertos no momento da chamada
	Local _aArea   := FWGetArea()

	If cEmpAnt = "01"
		/*cPEan14 := getMV('SI_CDEAN14')
		cPEan142 := getMV('SI_CEAN142')
		cPEan143 := getMV('SI_CEAN143')
		cPEan144 := getMV('SI_CEAN144')
		cPEan145 := getMV('SI_CEAN145')*/

		U_GJF48()		// Função que gera o codigo de barras(EAN13-B1_CODBAR) de produto para os tipos PA/PR
		if empty(SB1->B1_DUN14) //.and. !(alltrim(SB1->B1_COD) $ (Alltrim(cPEan14)+Alltrim(cPEan142)+Alltrim(cPEan143)+Alltrim(cPEan144)+Alltrim(cPEan145)))
			GeraDUN14()		// Função que gera o DUN14
		endif
	endif

	// Grava o usuario que alterou o cadastro
	Reclock("SB1",.F.)
	SB1->B1_USUALT := cUserName
	MsUnlock()

	// Rotina de gravação de log
	u_dtilog(cFilAnt, "MATA010", "Alteração do produto -> " + alltrim(SB1->B1_COD), "A")

	Processa( {|| _EnviaWF ()} )

	U_ML_SRArea(_aAreaAnt)            	// Restaurar áreas
	FWRestArea(_aArea)

Return    


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função de gravação do DUN14 no cadastro                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GeraDUN14()

	_nCodBar := SB1->B1_CODBAR
	_nCdBarcli := SB1->B1_EANCLI

	if !empty(_nCdBarcli)//bloco para imprimir dun14 do cliente
		_cod13 := '1' + substr(_nCdBarcli, 1, 12)
	elseif !empty(_nCodBar)
		_cod13 := '1' + substr(_nCodBar, 1, 12)
	else
		Return
	endif

	_cDig := EAN14(_cod13)
	_cod14 := _cod13 + _cDig
	RecLock("SB1", .F.)
	SB1->B1_DUN14 := _cod14
	MsUnLock()

Return

Static Function EAN14(cCod13)
	Local nOdd := 0
	Local nEven := 0
	Local nI
	Local nDig
	Local nMul := 10
	For nI := 1 to 13
		If (nI % 2) == 0
			nEven += val(substr(cCod13, nI, 1))
		Else
			nOdd += val(substr(cCod13, nI, 1))
		Endif
	Next
	nDig := nEven + (nOdd * 3)
	While nMul < nDig
		nMul += 10
	Enddo
Return strzero(nMul - nDig, 1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função de envio do workflow                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static function _EnviaWF()
	Local	_cMailDest 	:= GetMv("ML_RESPB1")			
	Local	_cMailCta   := "" //GETMV("MV_EMCONTA")			// Conta de e-mail
	Local	_cMailServ  := alltrim(GETMV("SI_COTSERV"))			// Servidor de e-mail
	Local	_cMailSenha := "" //GETMV("MV_EMSENHA")			// Senha
	Local	_lSmtpAuth  := GetMv("MV_RELAUTH",,.F.)     // Alterado 30/08/2018
	//Local	_lOK        := .T. // Alterado 30/08/2018
	Local	_cError     := ""
	Local	_cMsg       := ""
	Local _cTpProd		:= SB1->B1_TIPO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Obtem dados necessários a conexão                                                |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*_cMailCta   := If(_cMailCta   == NIL,GETMV("MV_EMCONTA"),_cMailCta)
	_cMailServ  := If(_cMailServ  == NIL,GETMV("MV_RELSERV"),_cMailServ)
	_cMailSenha := If(_cMailSenha == NIL,GETMV("MV_EMSENHA"),_cMailSenha)*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Se o parâmetro não estiver definido pega o parâmetro dos relatórios              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( _cMailCta )
		_cMailCta := GETMV("MV_RELFROM",,"")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Se o parâmetro não estiver definido pega o parâmetro dos relatórios              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( _cMailSenha )
		_cMailSenha := alltrim(GETMV("SI_COTPSW"))
	EndIf

	_cMailCtaAut := alltrim(GETMV("SI_COTACNT"))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Caso não exista conta definida, pega o próprio e-mail origem                     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( _cMailCtaAut )
		_cMailCtaAut := _cMailCta
	EndIf
	//alert(_cTpProd)
	//alert('93 - Bohrer')
	If Alltrim(_cTpProd) $ "ME/PR/MP/EM/PP/PA/SP/OI"

		_cMsg := "Produto " + AllTrim(SB1->B1_COD) + " " + AllTrim(SB1->B1_DESC) + " - Cadastro foi alterado e necessita de visualização e confirmação das informações."

		// Conecta no servidor de e-mails para envio
		CONNECT SMTP SERVER _cMailServ ACCOUNT _cMailCtaAut PASSWORD _cMailSenha RESULT _lOk

		//If _lOk		// Efetua a autenticação
		If ( _lSmtpAuth )
			_lOk := MailAuth(_cMailCtaAut,_cMailSenha)
			/*Else
			_lOk := .T.*/
		EndIf

		If _lOk	// Envia o e-mail
			SEND MAIL FROM AllTrim(_cMailCta) TO AllTrim(_cMailDest) SUBJECT "Alteração de Produto - Código: " + AllTrim(SB1->B1_COD) BODY _cMsg RESULT _lOk
			If !_lOk
				GET MAIL ERROR _cError
				MsgInfo(_cError,"Erro ao enviar e-Mail")
			Endif
		Else
			MsgInfo("Erro ao obter autenticação para envio de e-Mail")
		Endif

		// Desconecta do servidor de e-mails
		DISCONNECT SMTP SERVER
		/*Else // 30/08/2018
		MsgInfo("Erro ao obter conexão com o servidor de e-Mails")
		Endif*/

	Endif	

Return
