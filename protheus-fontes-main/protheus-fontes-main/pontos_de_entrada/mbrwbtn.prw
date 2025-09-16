#INCLUDE "protheus.ch"

User Function MBRWBTN()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ MBRWBTN  ³ Autor ³ Evandro Mugnol        ³ Data ³ 29/11/12 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Ponto de Entrada para controlar um botao pressionado na    ³±±
	±±³          ³ MBROWSE. Sera acessado em qualquer programa que utilize    ³±±
	±±³          ³ esta funcao.                                               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ Enviado ao Ponto de Entrada um vetor com 4 informacoes:    ³±±
	±±³          ³ PARAMIXB[1] = Variável com o alias da rotina;              ³±±
	±±³          ³ PARAMIXB[2] = Variável com o conteúdo do recno do registro ³±±
	±±³          ³               atual selecionado no Browse;                 ³±±
	±±³          ³ PARAMIXB[3] = Variável com o conteúdo da opção da rotina   ³±±
	±±³          ³               selecionada. Exemplo: Rotina de Incluir,     ³±±
	±±³          ³               nOption = 3.                                 ³±±
	±±³          ³ PARAMIXB[4] = Variável com o nome da rotina selecionada;   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ Se retornar .T. executa a funcao relacionada ao botao.     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Frigorifico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   DATA   ³ Programador   ³ Manutencao Efetuada                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local _aArea   := GetArea()
	Local _cText   := ""
	Local _lRet    := .T.
	Local cFunName := AllTrim(FunName())
	Local nRec_SM0 := 0
	//Local nRec_SM0 -- Ajustado por flávio , variável não inicializada - dia 19/01

	//_cText := "Alias  [ " + PARAMIXB[1] + " ]" + CRLF
	//_cText += "Recno  [ " + AllTrim(Str(PARAMIXB[2])) + " ]" + CRLF
	//_cText += "Opção  [ " + AllTrim(Str(PARAMIXB[3])) + " ]" + CRLF
	//_cText += "Rotina [ " + PARAMIXB[4] + " ]" + CRLF

	//_lRet := MsgYesNo(_cText,"Deseja Executar?")

	If cFunName == "MATA030"		// Cadastro de Clientes
		If ParamIxb[3] == 3	 		// Opcao Incluir
			If cEmpAnt == "07"
				nRec_SM0 := SM0->(RecNo())
				SM0->(dbSeek("0100", .F.))
				MsgStop("Operação não permitida nesta empresa." + chr(13) + "Utilize a empresa " + AllTrim(SM0->M0_NOME) + " / " + AllTrim(SM0->M0_FILIAL) + " para incluir clientes!")
				_lRet := .F.
				SM0->(dbGoTo(nRec_SM0))
			EndIf
		EndIf
	EndIf

	RestArea(_aArea)

Return(_lRet)
