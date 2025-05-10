#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fileio.ch"

User Function PMXML900()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ PMXML900 ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2013 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Exclui tabelas SDS, SDT e SDV caso ainda não tenha sido    ³±±
	±±³          ³ gerado pré-nota.                                           ³±±
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define variaveis locais                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local oDlg
	Local cCadastro := "Exclui movtos tabelas SDS, SDT e SDV"
	Local nOpca     := 0
	Local aSays     := {}
	Local aButtons  := {}

	Private _aLog:= {}

	// Verifica usuários que podem executar esta rotina
	_cCodUsr := RetCodUsr()
	_cUsers := GETMV('SI_RECUSER')     
	If !(_cCodUsr $ _cUsers)
		MsgAlert("Você não tem acesso para executar estar rotina. Favor entrar em contato com Fabiane Pozzer.")
		Return
	Endif 

	/*
	If AllTrim(cUserName) <> "patricia.rodrigues" .And. AllTrim(cUserName) <> "Administrador" .And. Alltrim(cUserName) <> "ana.maidana".And. Alltrim(cUserName) <> "tiago.ramos"
	MsgAlert("Você não tem acesso para executar estar rotina. Favor entrar em contato com Patrícia Rodrigues.")
	Return
	Endif
	*/
	cPerg := "PMXML900"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Pergunte(cPerg,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicoes de tela                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aSays,OemToAnsi(" Este programa tem como objetivo efetuar a exclusão dos     "))
	AADD(aSays,OemToAnsi(" movimentos importados do arquivo XML para notas de entrada "))
	AADD(aSays,OemToAnsi(" das tabelas SDS, SDT e SDV caso ainda não processadas.     "))

	AADD(aButtons, {5, .T. ,{|| Pergunte(cPerg,.T. ) } } )
	AADD(aButtons, {1, .T. ,{|o| nOpca:= 1, o:oWnd:End()}})
	AADD(aButtons, {2, .T. ,{|o| o:oWnd:End()}})

	FormBatch(cCadastro, aSays, aButtons ,, 220, 380)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpca == 1
		Processa({|lEnd| ProcExcl()})
		If Len(_aLog) > 0
			MostraLog()
		EndIf
	Endif

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProcExcl ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processamento                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PMXML900                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcExcl()

	Local _Flag 	 := .F.
	Local cMsgError := ""

	// Cabecalho importação XML NF-e
	DbSelectArea("SDS")
	DbSetOrder(1)
	DbSeek(xFilial("SDS") + MV_PAR01 + MV_PAR02 + MV_PAR03 + MV_PAR04)
	While !Eof() .And. SDS->DS_FILIAL + SDS->DS_DOC + SDS->DS_SERIE + SDS->DS_FORNEC + SDS->DS_LOJA == xFilial("SDS") + MV_PAR01 + MV_PAR02 + MV_PAR03 + MV_PAR04
		_cDoc		:= SDS->DS_DOC
		_cSerie	:= SDS->DS_SERIE
		_cFornec	:= SDS->DS_FORNEC
		_cLoja	:= SDS->DS_LOJA

		// Processa somente se ainda não foi gerado pré-nota
		If Empty(SDS->DS_STATUS) .Or. SDS->DS_STATUS $ "DQ"
			BEGIN TRANSACTION

				_Flag := .T.

				// Itens importação XML NF-e
				DbSelectArea("SDT")
				DbSetOrder(2)
				DbSeek(xFilial("SDT") + _cFornec + _cLoja + _cDoc + _cSerie)
				While !Eof() .And. SDT->DT_FILIAL + SDT->DT_FORNEC + SDT->DT_LOJA + SDT->DT_DOC + SDT->DT_SERIE == xFilial("SDT") + _cFornec + _cLoja + _cDoc + _cSerie

					Reclock("SDT",.F.)
					If !FKDelete(@cMsgError)
						RollBackDelTran(cMsgError)
					EndIf
					MsUnlock()

					SDT->(DbSKip())
				Enddo

				// Item NF Entrada X Ped. Compra
				DbSelectArea("SDV")
				DbSetOrder(1)
				DbSeek(xFilial("SDV") + _cFornec + _cLoja + _cDoc + _cSerie)
				While !Eof() .And. SDV->DV_FILIAL + SDV->DV_FORNEC + SDV->DV_LOJA + SDV->DV_DOC + SDV->DV_SERIE == xFilial("SDV") + _cFornec + _cLoja + _cDoc + _cSerie

					Reclock("SDV",.F.)
					If !FKDelete(@cMsgError)
						RollBackDelTran(cMsgError)
					EndIf
					MsUnlock()

					SDV->(DbSKip())
				Enddo

				DbSelectArea("SDS")
				Reclock("SDS",.F.)
				If !FKDelete(@cMsgError)
					RollBackDelTran(cMsgError)
				EndIf
				MsUnlock()

			END TRANSACTION
		Else
			MsgAlert("Documento não será excluído, pois está com Status de Bloqueado p/ Liberação, Documento Gerado ou Cancelado pela Receita")
		Endif

		SDS->(DbSKip())
	Enddo

	If _Flag
		MsgInfo("Movimentação das Tabelas Envolvidas Excluídas com Sucesso!")
	Endif

Return
