#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT140LOK
Ponto Entrada para validar as informações preenchidas no aCols de cada item da pré-nota de entrada.
@author     Evandro
@since      04/06/2020
@param		PARAMIXB[1] - [Variável lógica que valida o conteúdo da linha do aCols para prosseguir ou impedir que prossiga adiante]
			PARAMIXB[2] - [Vetor de valores contendo os totais calculados no pré-documento de entrada]
			PARAMIXB[3] - [Vetor de valores contendo as despesas calculadas no pré-documento de entrada]
@return     lRet(lógico) - Variável lógica de retorno para continuar a alteração da linha ou impedir o sistema de prosseguir com a operação
@obs        N/A
/*/

User Function MT140LOK()

	Local lRet	  := ParamIXB[1]
	Local aTotais := ParamIXB[2]
	Local aDesp	  := ParamIXB[3] 
	Local cDir	  := "C:\TempNF\"
	Local cArq	  := CNFISCAL + CSERIE + CA100FOR + CLOJA + ".txt"

	// Recupera o Environment utilizado para verificar se faz validações ou não
	cEnv := Upper(GetEnvServer())

	// Somente efetua validações se for ambiente 'DANFE'
	If AllTrim(cEnv) == "DANFE2"

		_dDtEmiss := dDEmissao		// Data da Emissão do cabeçalho
		_cFornece := cA100For		// Código do Fornecedor do cabeçalho
		_cLojaFor := cLoja			// Loja do Fornecedor do cabeçalho
		_cTipoNF  := cTipo			// Tipo da Nota Fiscal
		_cCodUsua := RetCodUsr()	// Código do Usuário logado
	
		MakeDir(cDir,,.F.)
	
		If _cTipoNF == "N"			// Somente processa notas do tipo NORMAL
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// Caso não tenha encontrado o usuário que está logado na tabela de amarração usuários por fornecedor (tabela ZLP)        ³
			// sempre irá efetuar as validações correspondentes abaixo, pois se ele encontrar, está liberado para lançar sem efetuar  ³
			// validações de PC, Qtde e Vlr. Unitário                                                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("ZLP")
			DbSetOrder(1)
			DbSeek(xFilial("ZLP") + _cFornece + _cLojaFor + _cCodUsua)
			If !Found()
	
				If !GDDeleted( n )		// Valida se a linha não estiver deletada
	
					_cProduto := GDFieldGet( "D1_COD"     , n )
					_cItemNF  := GDFieldGet( "D1_ITEM"    , n )
					_nQuantNF := GDFieldGet( "D1_QUANT"   , n )
					_nVlUniNF := GDFieldGet( "D1_VUNIT"   , n )
					_nVlDesNF := GDFieldGet( "D1_VALDESC" , n )
					_nVlSolNF := GDFieldGet( "D1_ICMSRET" , n )
					_nAlIPINF := GDFieldGet( "D1_IPI" 	  , n )
					_cPedido  := GDFieldGet( "D1_PEDIDO"  , n )
					_cItemPC  := GDFieldGet( "D1_ITEMPC"  , n )
	
					// Verifica se existe pedido de compra informado
					If Empty(_cPedido)
	
						// Alimenta a variável com conteúdo da mensagem em HTML
						cMsgHTML := '<h1><font color="#0000FF">Atenção</font></h1>'
						cMsgHTML += '<h2><br><font color="#FF0000"><b>É obrigatorio que seja informado o pedido de compra.</font></b></h2>'
	
						MsgAlert(cMsgHTML)
	
						cLine := "É obrigatorio que seja informado o pedido de compra" + CRLF
						//MemoWrite( cDir + cArq, cLine )
	
						lRet := .F.
						Return lRet
	
					Else
	
						DbSelectArea("SC7")
						DbSetOrder(4)
						DbSeek(xFilial("SC7") + _cProduto + _cPedido + _cItemPC)
						If Found()
	
							_nPrecoPC := xMoeda(SC7->C7_PRECO, SC7->C7_MOEDA, 1, _dDtEmiss, TamSX3("D1_VUNIT")[2], SC7->C7_TXMOEDA)
							_nVlDesPC := xMoeda(SC7->C7_VLDESC, SC7->C7_MOEDA, 1, _dDtEmiss, TamSX3("D1_VALDESC")[2], SC7->C7_TXMOEDA)
							_nVlSolPC := xMoeda(SC7->C7_VALSOL, SC7->C7_MOEDA, 1, _dDtEmiss, TamSX3("D1_ICMSRET")[2], SC7->C7_TXMOEDA)
	
							//MsgAlert("Preço Unitário: " + Transform(SC7->C7_PRECO, "@E 999,999,999.9999999") + "  Preço Unitário Moeda" + Str(SC7->C7_MOEDA,2) + ": "  + Transform(_nPrecoPC, "@E 999,999,999.9999999") + chr(13) + ;
							//         "Valor Desconto: " + Transform(SC7->C7_VLDESC, "@E 999,999,999.99") + "  Valor Desconto Moeda" + Str(SC7->C7_MOEDA,2) + ": "  + Transform(_nVlDesPC, "@E 999,999,999.99") + chr(13) + ;
							//         "Valor ICMS-ST : " + Transform(SC7->C7_VALSOL, "@E 999,999,999.99") + "  Valor ICMS-ST Moeda" + Str(SC7->C7_MOEDA,2) + ": "  + Transform(_nVlSolPC, "@E 999,999,999.99") )
	
							// Verifica a qtde digitada com a qtde do pedido de compras
							If _nQuantNF > ( SC7->C7_QUANT - SC7->C7_QUJE - SC7->C7_QTDACLA )
	
								// Alimenta a variável com conteúdo da mensagem em HTML
								cMsgHTML := '<h3><font color="#0000FF">Atenção</font></h3>'
								cMsgHTML += '<h3><font color="#FF0000"><b>Quantidade Informada na NF é MAIOR que (Qtde - Qtde Entregue - Qtde a Classificar) do Pedido de Compras.</font></h3>'
								cMsgHTML += '<h4>Produto / Item NF: <font color="#0000FF">' + AllTrim(_cProduto + " / " + _cItemNF) + '</font></h4>'
								cMsgHTML += '<h4>Qtde Informada NF: <font color="#0000FF">' + AllTrim(Transform(_nQuantNF, "@E 999,999,999.9999999")) + '</font></h4>'
								cMsgHTML += '<h4>Qtde PC: <font color="#0000FF">' + AllTrim(Transform(SC7->C7_QUANT, "@E 999,999,999.9999999")) + '</font></h4>'
								cMsgHTML += '<h4>Qtde Entregue PC: <font color="#0000FF">' + AllTrim(Transform(SC7->C7_QUJE, "@E 999,999,999.9999999")) + '</font></h4>'
								cMsgHTML += '<h4>Qtde a Classificar PC: <font color="#0000FF">' + AllTrim(Transform(SC7->C7_QTDACLA, "@E 999,999,999.9999999")) + '</font></h4>'
	
								MsgAlert(cMsgHTML)
	
								cLine := "Quantidade Informada na NF é MAIOR que (Qtde - Qtde Entregue - Qtde a Classificar) do Pedido de Compras" + CRLF
								cLine += "Produto / Item NF: " + AllTrim(_cProduto) + " / " + _cItemNF + CRLF
								cLine += "Qtde Informada NF: " + AllTrim(Transform(_nQuantNF, "@E 999,999,999.9999999")) + CRLF
								cLine += "Qtde PC: " + AllTrim(Transform(SC7->C7_QUANT, "@E 999,999,999.9999999")) + CRLF
								cLine += "Qtde Entregue PC: " + AllTrim(Transform(SC7->C7_QUJE, "@E 999,999,999.9999999")) + CRLF
								cLine += "Qtde a Classificar PC: " + AllTrim(Transform(SC7->C7_QTDACLA, "@E 999,999,999.9999999")) + CRLF
								//MemoWrite( cDir + cArq, cLine )
	
								lRet:= .F.
								Return lRet
	
							EndIf
	
							// Verifica o valor unitário digitado com o valor unitário do pedido de compras
							If NoRound(_nVlUniNF, 2) > NoRound(_nPrecoPC, 2)
	
								// Alimenta a variável com conteúdo da mensagem em HTML
								cMsgHTML := '<h3><font color="#0000FF">Atenção</font></h3>'
								cMsgHTML += '<h3><font color="#FF0000"><b>Valor Unitário Informado na NF é MAIOR que oo Valor Unitário do Pedido de Compras.</font></h3>'
								cMsgHTML += '<h4>Produto / Item NF: <font color="#0000FF">' + AllTrim(_cProduto + " / " + _cItemNF) + '</font></h4>'
								cMsgHTML += '<h4>Vlr. Unitário Informado NF: <font color="#0000FF">' + AllTrim(Transform(_nVlUniNF, "@E 999,999,999.9999999")) + '</font></h4>'
								cMsgHTML += '<h4>Vlr. Unitário Informado PC: <font color="#0000FF">' + AllTrim(Transform(_nPrecoPC, "@E 999,999,999.9999999")) + '</font></h4>'
	
								MsgAlert(cMsgHTML)
	
								cLine := "Valor Unitário Informado na NF é MAIOR que oo Valor Unitário do Pedido de Compras" + CRLF
								cLine += "Produto / Item NF: " + AllTrim(_cProduto) + " / " + _cItemNF + CRLF
								cLine += "Vlr. Unitário Informado NF: " + AllTrim(Transform(_nVlUniNF, "@E 999,999,999.9999999")) + CRLF
								cLine += "Vlr. Unitário Informado PC: " + AllTrim(Transform(_nPrecoPC, "@E 999,999,999.9999999")) + CRLF
								//MemoWrite( cDir + cArq, cLine )
	
								lRet:= .F.
								Return lRet
	
							EndIf
	
							// Verifica o valor desconto digitado com o valor do desconto do pedido de compras
							If _nVlDesNF < _nVlDesPC
	
								// Alimenta a variável com conteúdo da mensagem em HTML
								cMsgHTML := '<h3><font color="#0000FF">Atenção</font></h3>'
								cMsgHTML += '<h3><font color="#FF0000"><b>Valor Desconto Informado na NF é MENOR que o Valor Desconto do Pedido de Compras.</font></h3>'
								cMsgHTML += '<h4>Produto / Item NF: <font color="#0000FF">' + AllTrim(_cProduto + " / " + _cItemNF) + '</font></h4>'
								cMsgHTML += '<h4>Vlr. Desconto Informado NF: <font color="#0000FF">' + AllTrim(Transform(_nVlDesNF, "@E 999,999,999.99")) + '</font></h4>'
								cMsgHTML += '<h4>Vlr. Desconto Informado PC: <font color="#0000FF">' + AllTrim(Transform(_nVlDesPC, "@E 999,999,999.99")) + '</font></h4>'
	
								MsgAlert(cMsgHTML)
	
								cLine := "Valor Desconto Informado na NF é MENOR que o Valor Desconto do Pedido de Compras" + CRLF
								cLine += "Produto / Item NF: " + AllTrim(_cProduto) + " / " + _cItemNF + CRLF
								cLine += "Vlr. Desconto Informado NF: " + AllTrim(Transform(_nVlDesNF, "@E 999,999,999.99")) + CRLF
								cLine += "Vlr. Desconto Informado PC: " + AllTrim(Transform(_nVlDesPC, "@E 999,999,999.99")) + CRLF
								//MemoWrite( cDir + cArq, cLine )
	
								lRet:= .F.
								Return lRet
	
							EndIf
	
							// Verifica o valor ICMS ST digitado com o valor do ICMS ST do pedido de compras
							If _nVlSolNF > _nVlSolPC
	
								// Alimenta a variável com conteúdo da mensagem em HTML
								cMsgHTML := '<h3><font color="#0000FF">Atenção</font></h3>'
								cMsgHTML += '<h3><font color="#FF0000"><b>Valor ICMS-ST Informado na NF é MAIOR que o Valor ICSM-ST do Pedido de Compras.</font></h3>'
								cMsgHTML += '<h4>Produto / Item NF: <font color="#0000FF">' + AllTrim(_cProduto + " / " + _cItemNF) + '</font></h4>'
								cMsgHTML += '<h4>Vlr. ICMS-ST Informado NF: <font color="#0000FF">' + AllTrim(Transform(_nVlSolNF, "@E 999,999,999.99")) + '</font></h4>'
								cMsgHTML += '<h4>Vlr. ICMS-ST Informado PC: <font color="#0000FF">' + AllTrim(Transform(_nVlSolPC, "@E 999,999,999.99")) + '</font></h4>'
	
								MsgAlert(cMsgHTML)
	
								cLine := "Valor ICMS-ST Informado na NF é MAIOR que o Valor ICSM-ST do Pedido de Compras" + CRLF
								cLine += "Produto / Item NF: " + AllTrim(_cProduto) + " / " + _cItemNF + CRLF
								cLine += "Vlr. ICMS-ST Informado NF: " + AllTrim(Transform(_nVlSolNF, "@E 999,999,999.99")) + CRLF
								cLine += "Vlr. ICMS-ST Informado PC: " + AllTrim(Transform(_nVlSolPC, "@E 999,999,999.99")) + CRLF
								//MemoWrite( cDir + cArq, cLine )
	
								lRet:= .F.
								Return lRet
	
							EndIf
	
							// Verifica a alíquota IPI digitada com a aliquota IPI do pedido de compras
							If _nAlIPINF > SC7->C7_IPI
	
								// Alimenta a variável com conteúdo da mensagem em HTML
								cMsgHTML := '<h3><font color="#0000FF">Atenção</font></h3>'
								cMsgHTML += '<h3><font color="#FF0000"><b>Alíquota IPI Informado na NF é MAIOR que Alíquota IPI do Pedido de Compras.</font></h3>'
								cMsgHTML += '<h4>Produto / Item NF: <font color="#0000FF">' + AllTrim(_cProduto + " / " + _cItemNF) + '</font></h4>'
								cMsgHTML += '<h4>Alíquota IPI Informado NF: <font color="#0000FF">' + AllTrim(Transform(_nAlIPINF, "@E 999.99")) + '</font></h4>'
								cMsgHTML += '<h4>Alíquota IPI Informado PC: <font color="#0000FF">' + AllTrim(Transform(SC7->C7_IPI, "@E 999.99")) + '</font></h4>'
	
								MsgAlert(cMsgHTML)
	
								cLine := "Alíquota IPI Informado na NF é MAIOR que Alíquota IPI do Pedido de Compras" + CRLF
								cLine += "Produto / Item NF: " + AllTrim(_cProduto) + " / " + _cItemNF + CRLF
								cLine += "Alíquota IPI Informado NF: " + AllTrim(Transform(_nAlIPINF, "@E 999.99")) + CRLF
								cLine += "Alíquota IPI Informado PC: " + AllTrim(Transform(SC7->C7_IPI, "@E 999.99")) + CRLF
								//MemoWrite( cDir + cArq, cLine )
	
								lRet:= .F.
								Return lRet
	
							EndIf
	
						Endif
	
					EndIf
	
				Endif
	
			Endif
		
		Endif

	Endif
Return lRet
