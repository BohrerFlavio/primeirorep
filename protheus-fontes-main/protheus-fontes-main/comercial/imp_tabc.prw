#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} IMP_TABC
@Type			: Ponto de Entrada
@Sample			: IMP_TABC()
@Description	: Função que realiza a importação de CSV para tabela de custos de produtos
                  para o setor comercial.
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Mar/2024
@version		: Protheus 12.1.2210 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function IMP_TABC()

	Local aArea   := FWGetArea()
	Local cDirIni := "C:\Temp\"		// GetTempPath()
	Local cTipArq := "Arquivos com separações (*.csv)"
	Local cTitulo := "Seleção de Arquivo para Processamento"
	Local lSalvar := .F.
	Local cArqSel := ""

	If MsgYesNo("Deseja importar tabela de custos de produtos de planilha CSV a ser selecionada?","Atenção!")

		// Se não estiver sendo executado via job
		If !IsBlind()

			// Chama a função para buscar arquivos
			cArqSel := tFileDialog( ;
                                    cTipArq,;  // Filtragem de tipos de arquivos que serão selecionados
                                    cTitulo,;  // Título da Janela para seleção dos arquivos
                                    ,;         // Compatibilidade
                                    cDirIni,;  // Diretório inicial da busca de arquivos
                                    lSalvar,;  // Se for .T., será uma Save Dialog, senão será Open Dialog
                                    ;          // Se não passar parâmetro, irá pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT será possível pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY será possível selecionar o diretório
                                    )

			// Se tiver o arquivo selecionado e ele existir
			If !Empty(cArqSel) .And. File(cArqSel)
				Processa({|| fImporta(cArqSel) }, "Importando...")
			EndIf
		EndIf

	EndIf

	FWRestArea(aArea)

Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} fImporta
Funcao de importação do arquivo selecionado
@author     Evandro Mugnol
@since      Mar/2024
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function fImporta(cArqSel)

	Local cDirLog    := "C:\Temp\"		// GetTempPath()
	Local cArqLog    := "ImpTABCUS_" + DTOS(Date()) + "_" + StrTran(Time(), ':', '-') + ".Log"
	Local nTotLinhas := 0
	Local cLinAtu    := ""
	Local nLinhaAtu  := 0
	Local aLinha     := {}
	Local oArquivo
	Local aLinhas

	Private _cCodTab := ""
	Private nPosTip  := 1   // Primeira coluna do Excel, será o tipo da linha - TAB ou ITE

	// Posições do Cabeçalho (TAB)
	Private nCabTab := 2    // Z05_CODTAB
	Private nCabDtI := 3    // Z05_DATDE
	Private nCabDtF := 4    // Z05_DATATE

	// Posições dos Itens (ITE)
	Private nIteCEsp := 2   // Z07_CODESP
	Private nIteCCus := 3   // Z07_CODCUS
	Private nItePrec := 4   // Z07_PRCCUS

	// Variáveis da Rotina
 	Private cLog := ""

	// Abre as tabelas que serão usadas
	DbSelectArea("Z07")
	Z07->(DbSetOrder(1))    // Z07_FILIAL + Z07_CODTAB + Z07_CODESP + Z07_CODCUS
	Z07->(DbGoTop())

	// Definindo o arquivo a ser lido
	oArquivo := FWFileReader():New(cArqSel)

	// Se o arquivo pode ser aberto
	If (oArquivo:Open())

		// Se não for fim do arquivo
		If ! (oArquivo:EoF())

			// Definindo o tamanho da régua
			aLinhas := oArquivo:GetAllLines()
			nTotLinhas := Len(aLinhas)
			ProcRegua(nTotLinhas)

			// Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
			oArquivo:Close()
			oArquivo := FWFileReader():New(cArqSel)
			oArquivo:Open()

			// Iniciando controle de transação
			Begin Transaction

				// Enquanto tiver linhas
				While (oArquivo:HasLine())

					// Incrementa na tela a mensagem
					nLinhaAtu++
					IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

					// Pegando a linha atual e transformando em array
					cLinAtu := oArquivo:GetLine()
					aLinha  := StrTokArr(cLinAtu, ";")

					// Se houver posições no array
					If Len(aLinha) > 0
						// Se for cabeçalho
						If Upper(aLinha[nPosTip]) == "TAB"
							
							// Se tiver o mesmo numero de colunas, adiciona no array da TAB, e monta a chave que será pesquisada no seek
							If Len(aLinha) == nCabDtF

                                // Código da tabela de custo
                                aLinha[nCabTab] := PadL(aLinha[nCabTab], TamSX3("Z05_CODTAB")[1] , "0")    // Força preenchimento com zeros a esquerda
								_cCodTab := aLinha[nCabTab]

								// Transforma a data de
								If "/" $ aLinha[nCabDtI]
									aLinha[nCabDtI] := Ctod(aLinha[nCabDtI])
								Else
									aLinha[nCabDtI] := Stod(aLinha[nCabDtI])
								EndIf

								// Transforma a data ate
								If "/" $ aLinha[nCabDtF]
									aLinha[nCabDtF] := Ctod(aLinha[nCabDtF])
								Else
									aLinha[nCabDtF] := Stod(aLinha[nCabDtF])
								EndIf

                                // Efetua gravação do cabeçalho da tabela de custo
                                DbSelectArea("Z05")
                                DbSetOrder(1)       // Z05_FILIAL + Z05_CODTAB
                                If DbSeek(xFilial("Z05") + aLinha[nCabTab])
                                    RecLock("Z05", .F.)
                                    Z05->Z05_CODTAB := aLinha[nCabTab]
                                    Z05->Z05_DATDE  := aLinha[nCabDtI]
                                    Z05->Z05_DATATE := aLinha[nCabDtF]
                                    MsUnLock()
                        			cLog += "Tabela " + aLinha[nCabTab] + " já existente na base foi atualizada." + CRLF
                                Else
                                    RecLock("Z05", .T.)
                                    Z05->Z05_FILIAL := xFilial("Z05")
                                    Z05->Z05_CODTAB := aLinha[nCabTab]
                                    Z05->Z05_DATDE  := aLinha[nCabDtI]
                                    Z05->Z05_DATATE := aLinha[nCabDtF]
                                    MsUnLock()
                        			cLog += "Tabela " + aLinha[nCabTab] + " não existente na base foi criada." + CRLF
                                EndIf

							EndIf

							// Se for itens (e tiver todas as posições)
						ElseIf Upper(aLinha[nPosTip]) == "ITE"
		
                             // Código da especificação
							aLinha[nIteCEsp] := PadL(aLinha[nIteCEsp], TamSX3("Z07_CODESP")[1] , "0")    // Força preenchimento com zeros a esquerda

                            // Código do produto para custo
							aLinha[nIteCCus] := PadL(aLinha[nIteCCus], TamSX3("Z07_CODCUS")[1] , "0")    // Força preenchimento com zeros a esquerda

        					// Preço do produto para custo
                            // Campos numéricos, retira ponto, transforma vírgula em ponto e converte para numérico
							aLinha[nItePrec] := Alltrim(aLinha[nItePrec])
							aLinha[nItePrec] := StrTran(aLinha[nItePrec], ".", "")
							aLinha[nItePrec] := StrTran(aLinha[nItePrec], ",", ".")
							aLinha[nItePrec] := Val(aLinha[nItePrec])

                            // Efetua gravação dos Itens da tabela de custo
                            DbSelectArea("Z07")
                            DbSetOrder(1)       // Z07_FILIAL + Z07_CODTAB + Z07_CODESP + Z07_CODCUS
                            If DbSeek(xFilial("Z07") + _cCodTab + aLinha[nIteCEsp] + aLinha[nIteCCus])
                                RecLock("Z07", .F.)
                                Z07->Z07_CODTAB := _cCodTab
                                Z07->Z07_CODESP := aLinha[nIteCEsp]
                                Z07->Z07_CODCUS := aLinha[nIteCCus]
                                Z07->Z07_PRCCUS := aLinha[nItePrec]
                                MsUnLock()
                        		cLog += "Atualizado Item Tabela: " + _cCodTab + "  Especificação: " + aLinha[nIteCEsp] + "  Produto para Custo: " + aLinha[nIteCCus] + "  com Preço: " + Transform(aLinha[nItePrec], "@E 999,999.99") + CRLF
                            Else
                                RecLock("Z07", .T.)
                                Z07->Z07_FILIAL := xFilial("Z07")
                                Z07->Z07_CODTAB := _cCodTab
                                Z07->Z07_CODESP := aLinha[nIteCEsp]
                                Z07->Z07_CODCUS := aLinha[nIteCCus]
                                Z07->Z07_PRCCUS := aLinha[nItePrec]
                                MsUnLock()
                        		cLog += "Criado Novo Item Tabela: " + _cCodTab + "  Especificação: " + aLinha[nIteCEsp] + "  Produto para Custo: " + aLinha[nIteCCus] + "  com Preço: " + Transform(aLinha[nItePrec], "@E 999,999.99") + CRLF
                            EndIf
						EndIf
					EndIf

				EndDo

			End Transaction

			// Se tiver log, mostra ele
			If !Empty(cLog)
				MemoWrite(cDirLog + cArqLog, cLog)
				ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
			EndIf

		Else

			MsgStop("Arquivo não tem conteúdo!", "Atenção")

		EndIf

		// Fecha o arquivo
		oArquivo:Close()

	Else

		MsgStop("Arquivo não pode ser aberto!", "Atenção")

	EndIf

Return
