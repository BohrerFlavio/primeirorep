#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} REENVCC
Função para cadastro e manutenção de integradoras - Modelo 1 em MVC
@author 	Evandro Mugnol
@since 		Out/2020
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas
/*/
//-------------------------------------------------------------------

User Function REENVCC()

	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Parâmetros p/ Reenvio Cobrança CC - Checkout")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _cDoc    	:= Space(09)
	Private _cSerie    	:= Space(03)
	Private _cClie    	:= Space(06)
	Private _cLoja     	:= Space(02)

	If AllTrim(UPPER(cUserName)) == UPPER("Administrador") .Or. AllTrim(UPPER(cUserName)) == UPPER("clailton.soares") .Or. AllTrim(UPPER(cUserName)) == UPPER("patricia.almeida")
	   
		DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(350), C(600) PIXEL

		@ C(015), C(010) SAY "Informe os parâmetros abaixo para reenvio da"			Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela
		@ C(030), C(010) SAY "autorização de cobrança via CC - Checkout   "			Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela

		@ C(050), C(010) SAY "Nota Fiscal"                                  	  	Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
		@ C(050), C(080) MSGET _cDoc            	           	               		Size C(080), C(10) FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF _oTela
		@ C(070), C(010) SAY "Série"                                	   			Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
		@ C(070), C(080) MSGET _cSerie 											   	Size C(030), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela
		@ C(090), C(010) SAY "Cliente"             		                       	   	Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
		@ C(090), C(080) MSGET _cClie                       	                  	Size C(050), C(10) FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF _oTela
		@ C(110), C(010) SAY "Loja"		                                	   		Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
		@ C(110), C(080) MSGET _cLoja                                           	Size C(020), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

		DEFINE SBUTTON FROM C(150), C(080) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _Process())
		DEFINE SBUTTON FROM C(150), C(150) TYPE 2 OBJECT _oCancel ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

		ACTIVATE MSDIALOG _oTela CENTERED                                                                        
	Else
		// Alimenta a variável com conteúdo da mensagem em HTML
		cMsgHTML := '<h1><font color="#0000FF">Atenção</font></h1>'
		cMsgHTML += '<h3><br><font color="#FF0000"><b>Somente usuários Administrador, Patricia.Almeida e Clailton.Soares podem utilizar esta rotina.</font></b></h3>'

		MsgAlert(cMsgHTML)
	Endif

Return

// Efetua Processamento dos Dados Informados
Static Function _Process()
	_lClose := .T.

	If !Empty(_cDoc) .And. !Empty(_cSerie) .And. !Empty(_cClie) .And. !Empty(_cLoja)
		DbSelectArea("SF2")
		DbSetOrder(1)
		MsSeek(xFilial("SF2") + _cDoc + _cSerie + _cClie + _cLoja)
		If Found()
			// Somente limpa campos se status do retorno for DECLINED
			If AllTrim(Upper(SF2->F2_STATRET)) == "DECLINED" .Or. Empty(SF2->F2_STATRET)
				// Verifica se possui títulos baixados no contas a receber
				_lBaixas := .F.
				SE1->(DbSetOrder(1))
				SE1->(MsSeek(xFilial("SE1") + _cSerie + _cDoc, .T.))
				While !Eof() .And. SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM == xFilial("SE1") + _cSerie + _cDoc
					// Verifica o cliente
					If (SE1->E1_CLIENTE + SE1->E1_LOJA <> _cClie + _cLoja)
						SE1->(DbSkip())
						Loop
					Endif

					If !Empty(SE1->E1_BAIXA) 
						_lBaixas := .T.
					EndIf

					SE1->(DbSkip())
				EndDo

				If _lBaixas
					// Alimenta a variável com conteúdo da mensagem em HTML
					cMsgHTML := '<h1><font color="#0000FF">Atenção</font></h1>'
					cMsgHTML += '<h3><br><font color="#FF0000"><b>Nota Fiscal já possui título(s) baixado(s) e reenvio não será processado.</font></b></h3>'

					MsgAlert(cMsgHTML)
					_lClose := .F.
				Else
					// Limpa campos dos títulos no contas a receber somente se título não sofreu baixas
					SE1->(DbSetOrder(1))
					SE1->(MsSeek(xFilial("SE1") + _cSerie + _cDoc, .T.))
					While !Eof() .And. SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM == xFilial("SE1") + _cSerie + _cDoc
						// Verifica o cliente
						If (SE1->E1_CLIENTE + SE1->E1_LOJA <> _cClie + _cLoja)
							SE1->(DbSkip())
							Loop
						Endif

						Reclock("SE1",.F.)
						SE1->E1_CHKID   := ""			// checkout_id
						SE1->E1_INTEGRA := ""			// integradora
						SE1->E1_STATRET := ""			// status
						MsUnlock()
						
						SE1->(DbSkip())
					EndDo

					// Limpa campos do SF2 para poder reenviar cobrança via checkout
					RecLock("SF2",.F.)
					SF2->F2_CHKID   := ""			// checkout_id
					SF2->F2_CODINT  := ""			// integradora
					SF2->F2_STATRET := ""			// status
					MsUnlock()

					// Somente se for forma de recebimento igual a cartão de crédito e não tiver Checkout ID preenchido
					If SF2->F2_FRMREC == "5" .And. Empty(SF2->F2_CHKID) .And. Empty(SF2->F2_CODINT)
						//MsgAlert("Reenviando Processando Documento " + SF2->F2_DOC + "-" + SF2->F2_SERIE + "-" + SF2->F2_CLIENTE + "-" + SF2->F2_LOJA)
						U_CHECKOUT(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_VALBRUT)		// Chama Método Checkout
					Endif
				Endif
			Else
				// Alimenta a variável com conteúdo da mensagem em HTML
				cMsgHTML := '<h1><font color="#0000FF">Atenção</font></h1>'
				cMsgHTML += '<h3><br><font color="#FF0000"><b>Nota Fiscal não pode ser reenviada para cobrança, pois status não é DECLINED.</font></b></h3>'

				MsgAlert(cMsgHTML)
				_lClose := .F.
			Endif
		Else
			// Alimenta a variável com conteúdo da mensagem em HTML
			cMsgHTML := '<h1><font color="#0000FF">Atenção</font></h1>'
			cMsgHTML += '<h3><br><font color="#FF0000"><b>Não encontrado Nota Fiscal/Série para Cliente/Loja informado.</font></b></h3>'

			MsgAlert(cMsgHTML)
			_lClose := .F.
		Endif
	Else
		// Alimenta a variável com conteúdo da mensagem em HTML
		cMsgHTML := '<h1><font color="#0000FF">Atenção</font></h1>'
		cMsgHTML += '<h3><br><font color="#FF0000"><b>Todos os parâmetros devem estar preenchidos.</font></b></h3>'

		MsgAlert(cMsgHTML)
		_lClose := .F.
	Endif

	If _lClose
		_oTela:End()
	EndIf

Return
