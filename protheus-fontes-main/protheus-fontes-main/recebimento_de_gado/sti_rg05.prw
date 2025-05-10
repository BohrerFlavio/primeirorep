#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE X_PRECO    1
#DEFINE X_PRODUTO  2
#DEFINE X_DESC     3
#DEFINE X_PESO     4
#DEFINE X_QUANT    5
#DEFINE X_COMISSAO 6
#DEFINE X_TPCOM    7
#DEFINE X_PESOREAL 8

/*/{Protheus.doc} STI_RG05
FWMarkBrowse para realização do fechamento da compra de gado
@author 	Evandro Mugnol
@since 		Set/2017
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_RG05()

	Local oColumn
	Local aColumns	  := {}
	Local aFieldsSZ4  := {}
	Local aCampos	  := {}
	Local cArqTrb
	Local cIndice1    := ""
	Local lMarcar     := .F.
	Local aSeek       := {}

	Private aTolera	  := {}
	Private _lTol := .T. // variável lógica para controle de carcaças que entrarão na regra de tolerância
	Private cPerg     := "STI_RG05"
	//Private aRotina	  := {}
	Private cCadastro := "Seleção dos Lotes para Fechamento"
	Private oMark
	Private aRotina   := MenuDef()
	Private cADesc	  := ""
	Private nPesPren  := GETMV("SI_PNPREN")
	Private nPesPread := GETMV("SI_PNPREAD")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas no Arquivo SX1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.T.)

	_cAm     := mv_par01
	nFC      := mv_par02
	_cBonPro := mv_par03
	_nPena   := mv_par04

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criar a tabela temporária                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aCampos,{"Z4_OK"      ,"C",  02, 0})	// Este campo será usado para marcar/desmarcar
	aAdd(aCampos,{"Z4_NUMAM"   ,"C",  08, 0})
	aAdd(aCampos,{"Z4_LOTE"    ,"C",  06, 0})
	aAdd(aCampos,{"Z4_NUM"     ,"C",  10, 0})
	aAdd(aCampos,{"Z4_DATA"    ,"D",  08, 0})
	aAdd(aCampos,{"Z4_QUANT"   ,"N",  07, 0})
	aAdd(aCampos,{"Z4_FORNECE" ,"C",  06, 0})
	aAdd(aCampos,{"Z4_LOJA"    ,"C",  02, 0})
	aAdd(aCampos,{"Z4_NOME"    ,"C",  40, 0})
	aAdd(aCampos,{"Z4_STATUSP" ,"C",  10, 0})

	// Se o alias estiver aberto, fechar para evitar erros com alias aberto
	If (Select("TRB") <> 0)
		DbSelectArea("TRB")
		TRB->(DbCloseArea())
	Endif

	// A função CriaTrab() retorna o nome de um arquivo de trabalho que ainda não existe e dependendo dos parâmetros passados, pode criar um novo arquivo de trabalho.
	cArqTrb := CriaTrab(aCampos,.T.)

	// Criar indices
	cIndice1 := Alltrim(CriaTrab(,.F.))
	cIndice1 := Left(cIndice1,5) + Right(cIndice1,2) + "A"

	// Se indice existir excluir
	If File(cIndice1+OrdBagExt())
		FErase(cIndice1+OrdBagExt())
	EndIf

	// A função dbUseArea abre uma tabela de dados na área de trabalho atual ou na primeira área de trabalho disponível
	DbUseArea(.T.,,cArqTrb,"TRB",Nil,.F.)

	// A função IndRegua cria um índice temporário para o alias especificado, podendo ou não ter um filtro
	IndRegua("TRB", cIndice1, "Z4_NUMAM+Z4_LOTE"	,,, "Indice Aviso Matança + Lote ...")

	// Fecha todos os índices da área de trabalho corrente.
	DbClearIndex()

	// Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
	DbSetIndex(cIndice1+OrdBagExt())

	// Popula a tabela temporária
	SZ4->(DbSetorder(1))
	SZ4->(MsSeek(FWxFilial("SZ4") + _cAm))
	While !SZ4->(Eof()) .And. SZ4->Z4_FILIAL + SZ4->Z4_NUMAM = FWxFilial("SZ4") + _cAm
		// Para gerar PC, verifica se já houve fechamento desse lote. Em caso positivo, ignora o lote
		If nFC > 1
			ZAG->(DbSetOrder(3))
			If ZAG->(MsSeek(FWxFilial("ZAG") + SZ4->Z4_NUMAM + SZ4->Z4_LOTE))
				SZ4->(DbSkip())
				Loop
			Endif
		Endif

		SA2->(DbSetorder(1))
		SZE->(DbSetOrder(2))
		SZE->(Msseek(FWxFilial("SZE") + SZ4->Z4_NUMAM + SZ4->Z4_LOTE))

		SZD->(DbSetOrder(1))
		If SZD->(Msseek(FWxFilial("SZD") + SZE->ZE_NUMERO))
			cProdutor := SZD->ZD_FORNECE + SZD->ZD_LOJA
		Else
			cProdutor := Space(10)
		Endif

		cNomeProd := "AGLUTINADO-OUTROS     "
		If SZ4->Z4_NUMAM + SZ4->Z4_LOTE = SZE->ZE_NUMAM + SZE->ZE_LOTE
			If SZD->(Msseek(FWxFilial("SZD") + SZE->ZE_NUMERO))
				cNomeProd := GetAdvFVal("SA2", "A2_NOME", FWxFilial("SA2") + SZD->ZD_FORNECE + SZD->ZD_LOJA, 1)
			Else
				cNomeProd := ""
			Endif
		Endif

		Reclock("TRB",.T.)
		TRB->Z4_OK    	:= "  "
		TRB->Z4_NUMAM   := SZ4->Z4_NUMAM
		TRB->Z4_LOTE    := SZ4->Z4_LOTE
		TRB->Z4_NUM     := SZ4->Z4_NUM
		TRB->Z4_QUANT   := SZ4->Z4_QUANT
		TRB->Z4_DATA    := SZ4->Z4_DATA
		TRB->Z4_FORNECE := Substr(cProdutor,1,6)
		TRB->Z4_LOJA    := Substr(cProdutor,7,2)
		TRB->Z4_NOME    := cNomeProd
		TRB->Z4_STATUSP := IIF(Empty(SZ4->Z4_STATUSP) .Or. SZ4->Z4_STATUSP = "B","Bloqueado","Liberado")
		MsUnlock()

		SZ4->(DbSkip())
	Enddo

	TRB->(DbGoTop())

	If TRB->(!Eof())
		// Irei criar a pesquisa que será apresentada na tela
		aAdd(aSeek,{"Aviso Matança + Lote"	,{{"","C",012,0,"Aviso Matança + Lote"	,"@!"}} } )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Construindo o FWMarkBrowse  			  							   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oMark:= FWMarkBrowse():New()

		oMark:SetAlias("TRB") 					// Define a tabela do MarkBrowse
		oMark:SetSemaphore(.F.)					// Define se utiliza marcacao exclusiva
		oMark:SetDescription(cCadastro)			// Define o titulo do MarkBrowse
		oMark:SetFieldMark("Z4_OK")				// Define o campo utilizado para a marcacao
		oMark:oBrowse:SetDBFFilter(.T.)
		oMark:oBrowse:SetUseFilter(.T.) 		// Habilita a utilização do filtro no Browse
		oMark:oBrowse:SetFixedBrowse(.T.)
		oMark:SetTemporary() 					// Indica que o Browse utiliza tabela temporária
		oMark:oBrowse:SetSeek(.T.,aSeek) 		// Habilita a utilização da pesquisa de registros no Browse
		oMark:oBrowse:SetFilterDefault("") 		// Indica o filtro padrão do Browse

		// Setando Legenda
		oMark:AddLegend("U_StatPCP()[1]=1",	"BR_VERMELHO",  "Aberto"	)
		oMark:AddLegend("U_StatPCP()[1]=2",	"BR_VERDE",		"Fechado"	)
		oMark:AddLegend("U_StatPCP()[1]=3",	"BR_AZUL",		"Parcial"	)
		oMark:AddLegend("U_StatPCP()[1]=4",	"BR_AMARELO",	"Pendente"	)

		aColumns := {{"Ok"				,,"C","@!"			, ,02,0,.F.},;
					 {"Número Aviso"	,,"C","@!"			, ,08,0,.F.},;
					 {"Lote"			,,"C","@!"			, ,06,0,.F.},;
					 {"Número"			,,"C","@!"			, ,10,0,.F.},;
					 {"Data Abate"		,,"D","@D"			, ,08,0,.F.},;
					 {"Quantidade"		,,"C","@E 9999999"	, ,07,0,.F.},;
					 {"Produtor"		,,"C","@!"			, ,06,0,.F.},;
					 {"Loja"			,,"C","@!"			, ,02,0,.F.},;
					 {"Nome"			,,"C","@!"			, ,40,0,.F.},;
					 {"Portal"			,,"C","@!"			, ,10,0,.F.} }

		oColumn:= FWBrwColumn():New()
		oColumn:SetData( {|| TRB->Z4_NUMAM })
		oColumn:SetTitle( "Número Aviso" )
		oColumn:SetSize( 8 )
		oColumn:SetDecimal( 0 )
		oColumn:SetPicture( "@!" )
		oColumn:SetAlign( "LEFT" )
		aAdd(aFieldsSZ4, oColumn)

		oColumn:= FWBrwColumn():New()
		oColumn:SetData( {|| TRB->Z4_LOTE })
		oColumn:SetTitle( "Lote" )
		oColumn:SetSize( 6 )
		oColumn:SetDecimal( 0 )
		oColumn:SetPicture( "@!" )
		oColumn:SetAlign( "LEFT" )
		aAdd(aFieldsSZ4, oColumn)

		oColumn:= FWBrwColumn():New()
		oColumn:SetData( {|| TRB->Z4_NUM })
		oColumn:SetTitle( "Número" )
		oColumn:SetSize( 10 )
		oColumn:SetDecimal( 0 )
		oColumn:SetPicture( "@!" )
		oColumn:SetAlign( "LEFT" )
		aAdd(aFieldsSZ4, oColumn)

		oColumn:= FWBrwColumn():New()
		oColumn:SetData( {|| TRB->Z4_DATA })
		oColumn:SetTitle( "Data Abate" )
		oColumn:SetSize( 8 )
		oColumn:SetDecimal( 0 )
		oColumn:SetPicture( "@D" )
		oColumn:SetAlign( "CENTER" )
		aAdd(aFieldsSZ4, oColumn)

		oColumn:= FWBrwColumn():New()
		oColumn:SetData( {|| TRB->Z4_QUANT })
		oColumn:SetTitle( "Quantidade" )
		oColumn:SetSize( 7 )
		oColumn:SetDecimal( 0 )
		oColumn:SetPicture( "@E 9999999" )
		oColumn:SetAlign( "RIGHT" )
		aAdd(aFieldsSZ4, oColumn)

		oColumn:= FWBrwColumn():New()
		oColumn:SetData( {|| TRB->Z4_FORNECE })
		oColumn:SetTitle( "Produtor" )
		oColumn:SetSize( 6 )
		oColumn:SetDecimal( 0 )
		oColumn:SetPicture( "@!" )
		oColumn:SetAlign( "LEFT" )
		aAdd(aFieldsSZ4, oColumn)

		oColumn:= FWBrwColumn():New()
		oColumn:SetData( {|| TRB->Z4_LOJA })
		oColumn:SetTitle( "Loja" )
		oColumn:SetSize( 2 )
		oColumn:SetDecimal( 0 )
		oColumn:SetPicture( "@!" )
		oColumn:SetAlign( "LEFT" )
		aAdd(aFieldsSZ4, oColumn)

		oColumn:= FWBrwColumn():New()
		oColumn:SetData( {|| TRB->Z4_NOME })
		oColumn:SetTitle( "Nome" )
		oColumn:SetSize( 40 )
		oColumn:SetDecimal( 0 )
		oColumn:SetPicture( "@!" )
		oColumn:SetAlign( "LEFT" )
		aAdd(aFieldsSZ4, oColumn)

		oColumn:= FWBrwColumn():New()
		oColumn:SetData( {|| TRB->Z4_STATUSP })
		oColumn:SetTitle( "Portal" )
		oColumn:SetSize( 10 )
		oColumn:SetDecimal( 0 )
		oColumn:SetPicture( "@!" )
		oColumn:SetAlign( "LEFT" )
		aAdd(aFieldsSZ4, oColumn)

		// Adiciona uma coluna no Browse em tempo de execução
		oMark:SetColumns(aFieldsSZ4)

		// Indica o Code-Block executado no clique do header da coluna de marca/desmarca
		oMark:bAllMark := { || STIRG05Inv(oMark:Mark(),lMarcar := !lMarcar ), oMark:Refresh(.T.)  }

		// Ativando a janela
		oMark:Activate()

		// Seta o foco na grade
		oMark:oBrowse:Setfocus()
	Else
		MsgAlert("Nenhuma informação selecionada para processamento. Verifique parâmetros!")
		Return
	EndIf

	// Limpar o arquivo temporário
	If !Empty(cArqTrb)
		Ferase(cArqTrb+GetDBExtension())
		Ferase(cArqTrb+OrdBagExt())
		cArqTrb := ""
		TRB->(DbCloseArea())
	Endif

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função para marcar/desmarcar todos os registros do grid 	 		   ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function STIRG05Inv(cMarca,lMarcar)

	Local cAliasSZ4 := "TRB"
	Local aAreaSZ4  := (cAliasSZ4)->(GetArea())

	dbSelectArea(cAliasSZ4)
	(cAliasSZ4)->(DbGoTop())
	While !(cAliasSZ4)->(Eof())
		RecLock((cAliasSZ4),.F.)
		(cAliasSZ4)->Z4_OK := IIf(lMarcar, cMarca, "  ")
		MsUnlock()
		(cAliasSZ4)->(DbSkip())
	Enddo

	RestArea(aAreaSZ4)

Return .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função Fechto para gerar o fechamento de compra de gado				   ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function Fechto()

	Local nCont	:= 0
	Local aArea := GetArea()
	Local ix
	Local nPrcTou := 0.0

	Private numFC := ""

	SZE->(DbSetOrder(2)) 	// Aviso + Lote + Categoria
	SZD->(DbSetOrder(1)) 	// Numero
	SZA->(DbSetOrder(1)) 	// Numero
	SA2->(DbSetOrder(1)) 	// Codigo
	SZK->(dbSetOrder(2)) 	// Aviso + Lote
	SZ9->(dbSetOrder(1))
	SZ4->(dbSetOrder(1))

	If U_StatPCP()[1] <> 2
		MsgAlert("Não é possível executar o fechamento deste lote, pois o mesmo ainda não está FECHADO. Aguarde o mesmo estar fechado.")
		Return
	Endif

	// Função para geração de array da regra de tolerancia (solicitação Progepec 23/05/23 - chamado 3315)
	if mv_par06 = 1
		Tolerancia(mv_par01)
	endif

	// Percorrendo os registros da TRB
	TRB->(DbSetOrder(1))
	TRB->(DbGoTop())
	While !TRB->(Eof())
		If !Empty(TRB->Z4_OK) 	// Se diferente de vazio, é porque foi marcado

			cAviso 	  := TRB->Z4_NUMAM  			  			// 1a quebra pelo aviso de matança
			cFornec   := TRB->Z4_FORNECE + TRB->Z4_LOJA	  		// 2a quebra pelo produtor - gerar PC
			cLote     := TRB->Z4_LOTE
			noItens   := 0   									// controlar os itens
			bonusRast := 0   									// valor total do bonus de rastro
			qtRast    := 0   									// quantidade de rastreados
			nRecnoZAG := 0

			While !TRB->(Eof()) .And. TRB->Z4_NUMAM = cAviso .And. TRB->Z4_FORNECE + TRB->Z4_LOJA = cFornec .and. !Empty(TRB->Z4_OK)

				SZ4->(MsSeek(FWxFilial("SZ4") + TRB->Z4_NUMAM + TRB->Z4_LOTE))
				SZE->(MsSeek(FWxFilial("SZE") + SZ4->Z4_NUMAM + SZ4->Z4_LOTE))      // item ord rec
				SB1->(MsSeek(FWxFilial("SB1") + SZE->ZE_PRODUTO))             		// animal
				SZ9->(MsSeek(FWxFilial("SZ9") + SZE->ZE_NUMSC + SZE->ZE_ITEMSC))		// item da Sc
				SZA->(MsSeek(FWxFilial("SZA") + SZE->ZE_NUMSC))	              		// cab Sc
				SA3->(MsSeek(FWxFilial("SA3") + SZA->ZA_COMPRA))              		// comprador

				// Dados do cabecalho
				If  noItens = 0
					cCond    := SZA->ZA_CONDPG
					cContato := GetAdvFVal("SA2", "A2_CONTATO", FWxFilial("SA2") + TRB->Z4_FORNECE + TRB->Z4_LOJA, 1)
					dEmissao := SZ4->Z4_DATA
					cFilent  := SZA->ZA_FILIAL
					cCompra  := SZA->ZA_COMPRA
					cTpcom   := SZA->ZA_TPCOM
					nTxmoed  := 1  					// Real
					dAbate   := SZ4->Z4_DATA
				Endif

				// Valor definido para o peso leve de carcaça
				_nPesoLeve := 180		// Solicitado alteração pelo Fabiano dia 01/03/2017 - antes era 165 e agora 180

				//Preço base definido no processo de compras
				precBase := SZ9->Z9_PRECO

				//Inicialização do precoAcr
				precoAcr := 0.0

				//Inicialização do precoAcr
				precoBon := SZ9->Z9_PRECOBN

				// Valor pago somente pelo couro
				valCouro := _GetPar1()

				// Verifica O Sexo
				SZ5->(MsSeek(FWxFilial("SZ5") + SZE->ZE_CATEG))		// Procura pela categoria
				cSexo := SZ5->Z5_SEXO

				// Criar matriz para os itens
				aItens := {}

				// Criar matriz para separar as gorduras para o calculo de comissão
				aComis := {}

				SZK->(MsSeek(FWxFilial("SZK") + SZ4->Z4_NUMAM + SZ4->Z4_LOTE))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ INÍCIO DO PROCESSAMENTO PARA FECHAMENTO - INÍCIO BONIFICAÇÃO           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SZE->ZE_TPCOM = "V"  	//  SE FOR VIVO
					precoAtu  := precBase
					_cProduto := SZE->ZE_PRODUTO
					_nQtdVivo := 0

					SZR->(DbSetOrder(1))
					If SZR->(MsSeek(FWxFilial("SZR") + SZE->ZE_NUMERO + SZE->ZE_CATEG))
						_nPesoVivo := SZR->ZR_PESO
					Else
						_nPesoVivo := 0
					Endif

					While SZE->(!Eof()) .And. SZE->ZE_FILIAL + SZE->ZE_NUMAM + SZE->ZE_LOTE = FWxFilial("SZE") + TRB->Z4_NUMAM + TRB->Z4_LOTE
						_nQtdVivo += SZE->ZE_QTD1UM
						SZE->(DbSkip())
					EndDo

					If nFC > 1 		// Somente se gera PC
						AAdd(aItens, { precoAtu							,;  	// preco   				1
										SZE->ZE_PRODUTO         			,;      // produto  			2
										SB1->B1_DESC            			,;      // Descri     			3
										_nPesoVivo              			,;      // peso total         	4
										_nQtdVivo               			,;      // quantidade unitaria 	5
										0.00                    			,;      // comissao R$         	6
										If(SZE->ZE_TPCOM="V","V","R")	,;		// Tipo de compra 		7
										0  								})
					Endif
				Else				// SE NÃO FOR VIVO
					While SZK->(!Eof()) .And. SZK->ZK_NUMAM + SZK->ZK_LOTE = SZ4->Z4_NUMAM + SZ4->Z4_LOTE
						precBase := SZ9->Z9_PRECO
						predesc := 0
						// Bonificacoes
						boniPeso := 0
						boniGord := 0
						boniConf := 0
						boniraca := 0

						// Penalizacoes
						penaPeso := 0
						penaGord := 0
						penaConf := 0

						// comissao do comprador
						comiComp := 0

						_BRastro := _GetPar2()
						bonusRast += If(!Empty(SZK->ZK_RASTRO) .And. SZK->ZK_OBS <> "0", _BRastro, 0)  	// Valor Total

						If SZ9->Z9_RASTRO = "S"
							qtRast += If(!Empty(SZK->ZK_RASTRO) .And. SZK->ZK_OBS <> "0", 1, 0)  					// Quantidade
						Endif

						SZR->(DbSetOrder(1))
						If SZR->(MsSeek(FWxFilial("SZR") + SZE->ZE_NUMERO + SZE->ZE_CATEG))
							_nPesoVivo := SZR->ZR_PESO
						Else
							_nPesoVivo := 0
						Endif

						ZCB->(dbSetOrder(3))
						if ZCB->(MsSeek(FWxFilial('ZCB') + SZK->ZK_NUMAM + SZK->ZK_LOTE)) .and. (empty(SZK->ZK_PROGPGP) .or. (SZK->ZK_PROGPGP $ '010/001')) .and. (SZK->ZK_DENT $ '0/2/4')
							precoAcr := precBase + ZCB->ZCB_VLACR
							precoAtu := precoAcr
						else
							if _cBonPro = "006" .and. (SZK->ZK_DENT $ '0/2/4')
								precoAcr := precBase + ZCB->ZCB_VLACR
								precoAtu := precoAcr
							else
								precoAcr := precBase + ZCB->ZCB_VLACR
								//precoAtu := precBase
							endif
						endif

						if mv_par07	= 1		// Se for para calcular pelo peso vivo
							pesoLote := pesoTLote(SZK->ZK_NUMAM,SZK->ZK_LOTE)
							precBase := ((_nPesoVivo - (((SZ4->Z4_NPREN-SZ4->Z4_NPREAD)*nPesPren)+(SZ4->Z4_NPREAD*nPesPread)))*SZ9->Z9_PRECO)/pesoLote
							precoBon := ((_nPesoVivo - (((SZ4->Z4_NPREN-SZ4->Z4_NPREAD)*nPesPren)+(SZ4->Z4_NPREAD*nPesPread)))*SZ9->Z9_PRECOBN)/pesoLote
							precoAcr := ((_nPesoVivo - (((SZ4->Z4_NPREN-SZ4->Z4_NPREAD)*nPesPren)+(SZ4->Z4_NPREAD*nPesPread)))*(SZ9->Z9_PRECO + ZCB->ZCB_VLACR))/pesoLote
						endif
						pesofinal := CalcPeso(1)
						pesofreal := CalcPeso(2)  		// Peso real da carcaça com desconto de apenas 2%

						_lProg := .F.  					// Flag para indicar que pegou programa

						if _cBonPro = "001"
							ClcAng()    				// Calculo de preço para programa Angus
						elseif _cBonPro = "002" 
							ClcHeEs()   				// Calculo de preço para programa Hereford Esalc
						elseif _cBonPro = "003"
							ClcHere()   				// Calculo de preço para programa Hereford
						elseif _cBonPro = "004"
							ClcAng()
							ClcHere()
							ClcBran()
						//elseif _cBonPro = "005"
							//ClcGO()     				// Calculo de preço para programa GO
						elseif _cBonPro = "007"
							ClcBran()   				// Calculo de preço para programa Brangus
						//elseif _cBonPro = "008" .or. _cBonPro = "009"
							//ClcAHer()   				// Calculo de preço para programa Angus 006 /Hereford 002 (dia 11/08/22)
						endif

						_lTol := .T.
						if _cBonPro $ "005/008/009"
							// Regra nova 009 - Chamado 3173
							if _cBonPro = "009" .and. !(SZK->ZK_PROGPGP $ "002/006/005/008/019") .and. SZK->ZK_DENT $ '0/2/4/6' .and. substr(SZK->ZK_COBGOR,1,1) $ '3/4/5'
								precoAtu := precoAcr
								_lTol := .F.
							elseif _cBonPro = "008" .and. SZK->ZK_DENT = '6' .and. (substr(SZK->ZK_COBGOR,1,1) $ '3/4/5') // Regra dos 6 dentes
								precoAtu := precoAcr
								_lTol := .F.
							elseif _cBonPro = "008" .and. SZK->ZK_DENT $ '0/2/4' // Se for Jovem se identifica como Dent 0/2/4
								precoAtu := precoAcr
							// Regra nova 005 - Chamado 4285
							elseif _cBonPro = "005" .and. !(SZK->ZK_PROGPGP $ "002/006/005/008/019") .and. SZK->ZK_DENT $ '0/2/4'
								if SZK->ZK_DENT $ '0/2/4' .and. substr(SZK->ZK_COBGOR,1,1) = '2' .and. SZK->ZK_PROGPGP $ '013/020' // Entra na tolerância
									precoAtu := precoAcr
									_lTol := .T.
								elseif substr(SZK->ZK_COBGOR,1,1) = '1'
									precoAtu := precoAcr * 0.6
									_lTol := .F.
								else
									precoAtu := precoAcr
									_lTol := .F.
								endif
							elseif _cBonPro = "005" .and. !(SZK->ZK_PROGPGP $ "002/006/005/008/019") .and. SZK->ZK_DENT $ '6/8'
								if substr(SZK->ZK_COBGOR,1,1) = '1'
									precoAtu := precBase * 0.6
									_lTol := .F.
								else
									precoAtu := precBase
									_lTol := .F.
								endif
							elseif SZK->ZK_PROGPGP $ "005/008/019" 	// Se for Programa Cruza Leite, Touruno ou Touro
								// Se já tiver recebido preço pela GJF08 ou for um lote de Programa fora do padrão
								nPrcTou := GetAdvFVal('ZAQ','ZAQ_NGPTOU',FWxFilial('ZAQ') + SZ9->Z9_NUMERO,4)
								if SZK->ZK_PROGPGP = "019" .and. SZE->ZE_PRODUTO = "001075"
									precoAtu := precBase
									_lTol := .F.
								elseif SZK->ZK_PROGPGP = "008" .and. nPrcTou > 0.0
									precoAtu := nPrcTou
									_lTol := .F.
								elseif SZK->ZK_PRECOBO > 0.0
									precoAtu := SZK->ZK_PRECOBO
									_lTol := .F.
								else
									precoAtu := 0.0
									_lTol := .F.
									MsgAlert("Lote (" + SZK->ZK_LOTE + "), Sequencial (" + SZK->ZK_CONTROL + "), sem preço cadastrado para o Programa (" + SZK->ZK_PROGPGP + ")!", "Verificar!")
								endif
							elseif SZK->ZK_PROGPGP = "001"	// Se for Magro
								precoAtu := precBase * 0.60
								_lTol := .F.
							elseif SZK->ZK_DENT $ '0/2/4' .and. substr(SZK->ZK_COBGOR,1,1) = '2' .and. SZK->ZK_PROGPGP $ '013/020' // Animais que entram na regra de tolerância
								precoAtu := precBase
								_lTol := .T.
							else
								precoAtu := precBase
								_lTol := .F.
							endif

							precoAtu := ClcAHer(precBase,precoBon,precoAcr)  // Calculo de preço para programa Angus 006/021 e Hereford 002/022

							if SZK->ZK_DESTINO $ 'C/S' // destino câmara ou tratamento salga
								precoAtu := precoAtu	// Redudante, eu sei, é só por legibilidade
							elseif SZK->ZK_DESTINO = "R" // destino conserva
								if (SZK->ZK_PROGPGP $ "002/006") //  Valor do preço Bonus - 90%
									precoAtu := precoAcr * 0.10
								else
									precoAtu := precoAtu * 0.10
								endif
								_lTol := .F.
							elseif SZK->ZK_DESTINO = "G" // destino graxaria
								precoAtu := 0.01
								_lTol := .F.
							elseif SZK->ZK_DESTINO = "T" // destino TF
								if (SZK->ZK_PROGPGP $ "002/006") //  Valor do preço Bonus - 85%
									precoAtu := precoAcr * 0.85
								elseif SZK->ZK_PROGPGP != "001"
									precoAtu := precoAtu * 0.85
								endif
								_lTol := .F.
							endif
						endif

						// Quando definido na parametrização inicial da rotina - Penaliza igual a 'Sim'
						if _nPena = 1
							// Regra para penalização de carcaça magra: paga apenas 95% do preço, exceto alguns programas e destino TF, graxaria ou conserva
							if _cBonPro $ "005/008/009"
								if pesofinal < _nPesoLeve .and. !(SZK->ZK_PROGPGP $ "001/002/006") .and. !(SZK->ZK_DESTINO $ "R/G/T")
									precoAtu := precoAtu * 0.95
									_lTol := .F.
								endif
							endif
						endif

						// Quando definido na parametrização inicial da rotina - Tolerância igual a 'Sim'
						if mv_par06 = 1 .and. _lTol .and. (SZK->ZK_RACA $ "001/002/003") .and. pesofinal >= iif(mv_par05 = 1 .or. SZK->ZK_CATEG = '002', 180, 200)
							_nPos := aScan(aTolera,{|aVal|aVal[1] = SZK->ZK_LOTE})
							if aTolera[_nPos,2] > 0
								precoAtu := precoBon
								aTolera[_nPos,2] -= 1
							endif
						endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ INÍCIO DO PROCESSAMENTO PARA FECHAMENTO - TÉRMINO BONIFICAÇÃO          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						// Atualiza o preço calculado com as bonificações
						If nFC = 1 				    		// "Apenas Bonificar"
							// Verifica se tem cruza leite ou touruno no romaneio para gravar bonificação informada no romaneio
							/*If SZK->ZK_PROGPGP = "005" .Or. SZK->ZK_PROGPGP = "008"		// Cruza Leite ou Touruno
								ZAQ->(DbSelectArea("ZAQ"))
								ZAQ->(DbSetOrder(4))
								ZAQ->(MsSeek(FWxFilial("ZAQ") + SZ9->Z9_NUMERO))
								If Found()
									DO CASE
										CASE Alltrim(SZ9->Z9_PRODUTO) = "000230" .And. ZAQ->ZAQ_NGITSC = SZ9->Z9_ITEM		// BOI
											If SZK->ZK_PROGPGP = "005"		// Cruza Leite
												If ZAQ->ZAQ_NGPMES = 0
													MsgAlert("Preço Cz. Leite para Novilhos Gordos Não Informado no Lote " + SZK->ZK_LOTE + ". Verifique!")
												Else
													DbSelectArea("SZK")
													RecLock("SZK",.F.)
													SZK->ZK_PRECOBO := ZAQ->ZAQ_NGPMES
													MsUnlock()
												Endif
											Endif
											If SZK->ZK_PROGPGP = "008"		//	Touruno
												If ZAQ->ZAQ_NGPTOU = 0
													MsgAlert("Preço Touruno para Novilhos Gordos Não Informado no Lote " + SZK->ZK_LOTE + ". Verifique!")
												Else
													DbSelectArea("SZK")
													RecLock("SZK",.F.)
													SZK->ZK_PRECOBO := ZAQ->ZAQ_NGPTOU
													MsUnlock()
												Endif
											Endif
										CASE Alltrim(SZ9->Z9_PRODUTO) = "000231" .And. ZAQ->ZAQ_VGITSC = SZ9->Z9_ITEM		// VACA
											If SZK->ZK_PROGPGP = "005"		// Cruza Leite
												If ZAQ->ZAQ_VGPMES = 0
													MsgAlert("Preço Cz. Leite para Vacas Gordas Não Informado no Lote " + SZK->ZK_LOTE + ". Verifique!")
												Else
													DbSelectArea("SZK")
													RecLock("SZK",.F.)
													SZK->ZK_PRECOBO := ZAQ->ZAQ_VGPMES
													MsUnlock()
												Endif
											Endif
										OTHERWISE
											DbSelectArea("SZK")
											RecLock("SZK",.F.)
											SZK->ZK_PRECOBO := precoAtu
											MsUnlock()
									ENDCASE
									// Após calculo do preço de bonus (SZK->ZK_PRECOBO), calcula-se os descontos dos destinos
									_nPRECOB := SZK->ZK_PRECOBO
									If SZK->ZK_DESTINO = "R"    
										DbSelectArea("SZK")
										RecLock("SZK",.F.)
											SZK->ZK_PRECOBO := _nPRECOB * 0.10 
										MsUnlock()
									ElseIf SZK->ZK_DESTINO = "G"
										DbSelectArea("SZK")
										RecLock("SZK",.F.)
											SZK->ZK_PRECOBO := 0.01
										MsUnlock()
									ElseIf SZK->ZK_COBGOR = "1"
										DbSelectArea("SZK")
										RecLock("SZK",.F.)
											SZK->ZK_PRECOBO := _nPRECOB * 0.60 
										MsUnlock()
									ElseIf SZK->ZK_DESTINO = "T"
										DbSelectArea("SZK")
										RecLock("SZK",.F.)
											SZK->ZK_PRECOBO := _nPRECOB * 0.85 
										MsUnlock()
									Endif
								Else
									DbSelectArea("SZK")
									RecLock("SZK",.F.)
									SZK->ZK_PRECOBO := precoAtu
									MsUnlock()
								Endif
							Else
								DbSelectArea("SZK")
								RecLock("SZK",.F.)
								SZK->ZK_PRECOBO := precoAtu
								MsUnlock()
							Endif*/
							// Modificação solicitada pela PROGEPEC até que a questão Romaneio esteja definida ou novas regras sejam criadas (06/04/23)
							DbSelectArea("SZK")
							RecLock("SZK",.F.)
							SZK->ZK_PRECOBO := precoAtu
							MsUnlock()
						Else								// "Gerar PC"
							precoAtu := SZK->ZK_PRECOBO
						Endif

						// Cálculo da Comissão
						If SZE->ZE_TPCOM = "R"
							If SA3->A3_TIPO <> "I" .And. substr(SZK->ZK_COBGOR,1,1) <> "1" 	 // Externo
								comiComp := pesofinal * precoatu * 1.5 / 100
							Else
								comiComp := 0
							Endif
						Endif

						// Quebra dos itens no pc
						// Lote + Preco Igual
						// A rastreabilidade deve ser um item separado no pedido de compra
						onde := Ascan( aItens, {|reg| reg[1] = precoAtu } )

						If nFC > 1 								// Somente se gera Pc
							// Para separar comissão por gordura
							aAdd(aComis,{precoAtu,substr(SZK->ZK_COBGOR,1,1), pesofinal})

							if SZK->ZK_DESTINO = "R"
								cADesc := "(CO) - " + transform(precoAtu,"@e 99.99")
							elseif SZK->ZK_DESTINO = "G"
								cADesc := "(GR) - " + transform(precoAtu,"@e 99.99")
							elseif SZK->ZK_DESTINO = "T"
								cADesc := "(TF) - " + transform(precoAtu,"@e 99.99")
							elseif SZK->ZK_DESTINO = "S"
								cADesc := "(TS) - " + transform(precoAtu,"@e 99.99")
							elseif SZK->ZK_PROGPGP = "001"
								cADesc := "(MAGRO) - " + transform(precoAtu,"@e 99.99")
							else
								cADesc := " - " + transform(precoAtu,"@e 99.99")
							endif

							If onde = 0
								// Cria novo item
								AAdd(aItens, { precoAtu							,;		// preco                                 	1
											   	SZE->ZE_PRODUTO					,;		// produto                               	2
												alltrim(SB1->B1_DESC)+cADesc	,;		// Descri                                	3
											   	pesofinal    					,;		// peso total                           	4
											   	1.00           					,;		// quantidade unitaria                   	5
											   	comiComp      					,;		// comissao R$                           	6
											   	IIF(SZE->ZE_TPCOM="V","V","R")	,;		// Tipo de compra                        	7
											   	pesofreal                   	})		// Peso real para movimentação - Bloco K  	8
							Else	
								// Somente adiciona (quant unitaria , peso, comissao)
								aItens[ onde, X_PESO ]     := aItens[ onde, X_PESO ]     + pesofinal
								aItens[ onde, X_QUANT ]    := aItens[ onde, X_QUANT ]    + 1
								aItens[ onde, X_COMISSAO ] := aItens[ onde, X_COMISSAO ] + comiComp
								aItens[ onde, X_PESOREAL ] := aItens[ onde, X_PESOREAL ] + pesofreal
							Endif
						Endif

						SZK->(DbSkip())
					EndDo
				Endif

				If nFC = 2 //se for gerar
					For ix := 1 To Len(aItens)
						numFC := GetSxENum("ZAG","ZAG_NUM")
						ConfirmSX8()

						noItens++

						// Campos de cabecalho (sempre se repetem)
						RecLock("ZAG",.T.)
						ZAG->ZAG_FILIAL  := FWxFilial("ZAG")
						ZAG->ZAG_NUM     := numFC
						ZAG->ZAG_STATUS  := "A"
						ZAG->ZAG_FORNECE := cFornec
						ZAG->ZAG_LOJA    := Right(cFornec,2)
						ZAG->ZAG_COND    := cCond
						ZAG->ZAG_CONTAT  := cContato
						ZAG->ZAG_EMISSA  := dAbate

						pesoLiq := aItens[ix,X_PESO]

						// Campos dos itens
						ZAG->ZAG_PRODUT := aItens[ix,X_PRODUTO]
						ZAG->ZAG_DESCRI := aItens[ix,X_DESC]
						ZAG->ZAG_PESO   := Round(pesoLiq,3)
						ZAG->ZAG_SLDP   := pesoLiq
						ZAG->ZAG_QUANT  := aItens[ix,X_QUANT]
						ZAG->ZAG_SLDQ   := aItens[ix,X_QUANT]
						ZAG->ZAG_PRECO  := aItens[ix,X_PRECO]
						_nTotalZAG      := ZAG->ZAG_PRECO  *  ZAG->ZAG_PESO
						ZAG->ZAG_TOTAL  := Round(_nTotalZAG,2)
						ZAG->ZAG_TPCOM  := cTpcom
						ZAG->ZAG_COMPR  := cCompra
						ZAG->ZAG_NUMAM  := SZ4->Z4_NUMAM
						ZAG->ZAG_LOTE   := SZ4->Z4_LOTE
						ZAG->ZAG_COMISS := IIF(cTpcom = "V",(_nTotalZAG * (1.5/100)),CalcCom(aItens[ix,X_PRECO]))
						ZAG->ZAG_PESOR  := aItens[ix,X_PESOREAL]
						MsUnlock()

						nRecnoZAG := ZAG->( Recno() )		// Guarda o registro para ser gravado na tabela SZK que será usado para o Peso Vivo

						// Função que calcula e faz a gravacao do peso vivo na tabela SZK
						_CalcPV(dAbate, SZ4->Z4_NUMAM, SZ4->Z4_LOTE, cFornec, aItens[ix,X_PRECO], nRecnoZAG)

					Next
				Endif

				// Finaliza este lote, deve gerar os itens necessários
				If Len(aItens) > 0  .and. nFC > 1
					// Marca a quantidade já encerrada, caso tenha escohido gerar Pc
					RecLock("SZ4",.F.)
					SZ4->Z4_COMPRA := "C"
					MsUnlock()
				Endif

				nCont ++

				RecLock("TRB",.F.)
				TRB->(DbDelete())
				MsUnlock()

				TRB->(DbSkip())
			EndDo

		Endif

		//oMark:oBrowse:Refresh(.T.)

		TRB->(DbSkip())
	EndDo

	If nCont = 0
		MsgAlert("Selecione pelo menos um aviso de matança!")
		Return
	Endif

	DbSelectArea("TRB")
	Set Filter To

	If !Empty(numFC) .And. noItens > 0
		MsgAlert("Número do Último Fechamento de Compra Gerado: " + numFC)
	Endif

	oMark:oBrowse:Refresh(.T.)

	Restarea(aArea)

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função para busca de peso total do lote para preço de carcaça quente   ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function pesoTLote(_cNumam,_cLote)

	cQuery := "SELECT SUM(CASE WHEN ZK_IF = 'S' THEN ZK_PETOTAL*0.92 ELSE ZK_PETOTAL END) AS PETOTAL"
	cQuery += " FROM " + retSqlTab('SZK')
	cQuery += " WHERE " + retSqlFil('SZK')
	cQuery += " AND ZK_NUMAM = '" + alltrim(_cNumam) + "'"
	cQuery += " AND ZK_LOTE = '" + alltrim(_cLote) + "'"
	cQuery += " AND " + retSqlDel('SZK')

	cQuery  := ChangeQuery(cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

Return QRY->PETOTAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função para geração de array da regra de tolerancia (chamado 3315)     ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Tolerancia(cNumam)

	_nCont := 0

	cQuery := "SELECT ZK_LOTE, ZK_DENT, ZK_COBGOR, ZK_PROGPGP, ZK_RACA"
	cQuery += " FROM " + retSqlTab('SZK')
	cQuery += " WHERE " + retSqlFil('SZK') + " AND ZK_NUMAM = '" + alltrim(cNumam) + "'"
	cQuery += " AND " + retSqlDel('SZK')
	cQuery += " ORDER BY ZK_CONTROL"

	cQuery  := ChangeQuery(cQuery)

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP"

	TMP->(dbGoTop())

	_cLote := alltrim(TMP->ZK_LOTE)

	while TMP->(!EOF())
		if _cLote != alltrim(TMP->ZK_LOTE)
			if _nCont > 0
				aAdd(aTolera, {_cLote, Round((_nCont*0.1),0)})
			else
				aAdd(aTolera, {_cLote, 0})
			endif
			_nCont := 0
			_cLote := alltrim(TMP->ZK_LOTE)
		endif
		if (TMP->ZK_RACA $ "001/002/003") .and. (TMP->ZK_DENT $ "0/2/4") .and. (TMP->ZK_PROGPGP $ "013/002/006/020")
			if TMP->ZK_PROGPGP = "013" .and. substr(TMP->ZK_COBGOR,1,1) = "2"
				_nCont++
			elseif TMP->ZK_PROGPGP $ "002/006/020"
				_nCont++
			endif
		endif
		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	end
	aAdd(aTolera, {_cLote, Round((_nCont*0.1),0)})

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função Portal para liberar/bloquear lote para visual. no portal do gado³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function Portal()

	Local _aArea := GetArea()

	TRB->(DbSetOrder(1))
	TRB->(DbGoTop())
	While !TRB->(Eof())

		If !Empty(TRB->Z4_OK) 	// Se diferente de vazio, é porque foi marcado
			SZ4->(DbSetOrder(1))
			If SZ4->(MsSeek(FWxFilial("SZ4") + TRB->Z4_NUMAM + TRB->Z4_LOTE))
				Reclock("SZ4",.F.)
				SZ4->Z4_STATUSP := IIF(Empty(SZ4->Z4_STATUSP) .Or. SZ4->Z4_STATUSP = 'B','L','B')
				MsUnlock()
			Endif

			RecLock("TRB",.F.)
			TRB->Z4_STATUSP := IIF(SZ4->Z4_STATUSP = "B","Bloqueado","Liberado")
			MsUnlock()
		Endif

		TRB->(DbSkip())
	EndDo

	DbSelectArea("TRB")
	Set Filter To

	RestArea(_aArea)

	oMark:oBrowse:Refresh(.T.)

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função ClcBlack - Cálculo para a bonificação do Black                  ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ClcBlack()

	If SZK->ZK_PROGPGP = "014" 		// Se for Programa Black
		precBaseP := SZ9->Z9_PRECOBN
		precoAtu  := PrecBaseP

		If precBaseP = 0
			MsgAlert("Preço Base Black não cadastrado!")
			Return
		Endif

		_lProg := .T.
		bonif  := 0

		//If SZK->ZK_DENT $ "1/2/4"
		If SZK->ZK_DENT $ "0/2/4"
			If pesofinal >= 230 .And. pesofinal <= 300
				bonif := precBaseP * 0.12
			Else
				bonif := precBaseP
			Endif
		EndIf

		precoAtu += bonif
	Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função ClcAng - Cálculo para a bonificação do Angus                    ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ClcAng()

	If SZK->ZK_PROGPGP = "006" 		// Se for Programa Angus
		precBaseP := SZ9->Z9_PRECOBN	// Preço Bonus da SC	- antes era	SZ7->Z7_PRCANG
		precoAtu  := PrecBaseP

		If precBaseP = 0
			MsgAlert("Preço Base Angus não cadastrado!")
			Return
		Endif

		_lProg := .T.
		bonif  := 0
		
		DO CASE
			//CASE SZK->ZK_DENT = "1"
			CASE SZK->ZK_DENT = "0"
			If pesofinal >= 180 .And. pesofinal < 200		// Solicitado alteração pelo Diogo dia 13/04/2021 GLPI 1108
				bonif := precBaseP * 0.02
			ElseIf pesofinal >= 200 .And. pesofinal < 220
				bonif := precBaseP * 0.04
			ElseIf pesofinal >= 220 .And. pesofinal < 240
				bonif := precBaseP * 0.06
			ElseIf pesofinal >= 240
				bonif := precBaseP * 0.08
			Endif
			CASE SZK->ZK_DENT = "2"
			If pesofinal >= 180 .And. pesofinal < 220		// Solicitado alteração pelo Diogo dia 13/04/2021 GLPI 1108
				bonif := precBaseP * 0.02
			ElseIf pesofinal >= 220 .And. pesofinal < 240
				bonif := precBaseP * 0.04
			ElseIf pesofinal >= 240 .And. pesofinal < 260
				bonif := precBaseP * 0.06
			ElseIf pesofinal >= 260
				bonif := precBaseP * 0.08
			Endif
			CASE SZK->ZK_DENT = "4"
			If pesofinal >= 180 .And. pesofinal < 240		// Solicitado alteração pelo Diogo dia 13/04/2021 GLPI 1108
				bonif := precBaseP * 0.02
			ElseIf pesofinal >= 240 .And. pesofinal < 260
				bonif := precBaseP * 0.04
			ElseIf pesofinal >= 260 .And. pesofinal < 280
				bonif := precBaseP * 0.06
			ElseIf pesofinal >= 280
				bonif := precBaseP * 0.08
			Endif
		ENDCASE

		precoAtu += bonif

		// Se for carcaça leve, pega o preço base de programa
		If pesofinal < _nPesoLeve
			precoAtu := precBaseP
		Endif
	Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função ClcHeEs - Cálculo para a bonificação do Hereford ESALQ          ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ClcHeEs()

	valCouro := GETMV("MV_COURO") 								// Valor pago somente pelo couro

	If SZK->ZK_PROGPGP = "002" .And. !Empty(SZ9->Z9_TABPREC) .And. SZK->ZK_DESTINO = "C"    // Filtra Programa Here - Tabela preço tem que ser apontada - Tem que ter o destino de camara
		PrecoAtu := SZ9->Z9_PRECOBN	// Preço Bonus da SC	- antes era	SZ7->Z7_MAESALQ		  // Preço máximo ESALQ
	ElseIf (SZK->ZK_RACA = "002" .Or. SZK->ZK_RACA  = "003") .And. !Empty(SZ9->Z9_TABPREC) .And. SZK->ZK_DESTINO = "C"   // Filtra raça Hereford ou Braford - Tabela preço tem que ser apontada - Tem que ter o destino de camara
		PrecoAtu := SZ9->Z9_PRECOBN	// Preço Bonus da SC	- antes era	SZ7->Z7_MEESALQ       // Preco médio ESALQ
	Else
		PrecoAtu := SZ9->Z9_PRECOBN	// Preço Bonus da SC	- antes era	SZ7->Z7_PMFRIGO       // Preço Médio Frigo
	Endif

	precbase := ClcGor()		//ClcGor(PrecoAtu)
	PrecoAtu := Precbase

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função ClcHere - Cálculo para bonificação do Hereford                  ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ClcHere()

	If SZK->ZK_PROGPGP = "002"			// Se for programa Hereford
		precBaseP := SZ9->Z9_PRECOBN	// Preço Bonus da SC	- antes era	SZ7->Z7_PRCANG
		precoAtu  := PrecBaseP

		If precBaseP = 0
			MsgAlert("Preço Base Hereford não cadastrado!")
			Return
		Endif

		_lProg := .T.
		bonif  := 0

		DO CASE
			//CASE SZK->ZK_DENT = "1"
			CASE SZK->ZK_DENT = "0"
				If pesofinal >= 180 .And. pesofinal < 200		// Solicitado alteração pelo Diogo dia 13/04/2021 GLPI 1108
					bonif := precBaseP * 0.02
				ElseIf pesofinal >= 200 .And. pesofinal < 220
					bonif := precBaseP * 0.04
				ElseIf pesofinal >= 220 .And. pesofinal < 240
					bonif := precBaseP * 0.06
				ElseIf pesofinal >= 240
					bonif := precBaseP * 0.08
				Endif
			CASE SZK->ZK_DENT = "2"
				If pesofinal >= 180 .And. pesofinal < 220		// Solicitado alteração pelo Diogo dia 13/04/2021 GLPI 1108
					bonif := precBaseP * 0.02
				ElseIf pesofinal >= 220 .And. pesofinal < 240
					bonif := precBaseP * 0.04
				ElseIf pesofinal >= 240 .And. pesofinal < 260
					bonif := precBaseP * 0.06
				ElseIf pesofinal >= 260
					bonif := precBaseP * 0.08
				Endif
			//CASE SZK->ZK_DENT $ "4/6"//remover os 6 dentes
			CASE SZK->ZK_DENT = "4"
				If pesofinal >= 180 .And. pesofinal < 240		// Solicitado alteração pelo Diogo dia 13/04/2021 GLPI 1108
					bonif := precBaseP * 0.02
				ElseIf pesofinal >= 240 .And. pesofinal < 260
					bonif := precBaseP * 0.04
				ElseIf pesofinal >= 260 .And. pesofinal < 280
					bonif := precBaseP * 0.06
				ElseIf pesofinal >= 280
					bonif := precBaseP * 0.08
				Endif
		ENDCASE

		precoAtu += bonif

		// Se for carcaça leve, pega o preço base de programa
		If pesofinal < _nPesoLeve
			precoAtu := precBaseP
		Endif
	Endif

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função ClcAHer- Cálculo para a bonificação do Angus/Hereford	       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ClcAHer(_nPrecBas,_nPrecBon,_nPrecAcr)

	If SZK->ZK_PROGPGP = "006" 		// Se for Programa Angus
		precoAtu := 0.0
		if mv_par07	= 1		// Se for para calcular pelo peso vivo
			precBase := _nPrecBas
			precBaseP := _nPrecBon
		else
			precBaseP := SZ9->Z9_PRECOBN	// Preço Bonus da SC	- antes era	SZ7->Z7_PRCANG
			precBase := SZ9->Z9_PRECO
		endif

		If precBaseP = 0
			MsgAlert("Preço Base Angus não cadastrado!")
			Return
		Endif

		_lProg := .T.
		bonif  := 0
		bonif2 := 0
		DO CASE
			// Classificado no programa 006 , acima de 180/200 Kg de carcaça ele vai pegar o preço do programa 
			CASE pesofinal >= iif(mv_par05 = 1 .or. SZK->ZK_CATEG = '002', 180, 200)
				bonif := precBaseP
			// Classificado no programa 006 , abaixo de 180/200 Kg de carcaça ele vai pegar o 'Preço do Jovem'
			CASE pesofinal < iif(mv_par05 = 1 .or. SZK->ZK_CATEG = '002', 180, 200)
				ZCB->(DbSetOrder(3))
				if ZCB->(MsSeek(FWxFilial('ZCB') + SZK->ZK_NUMAM + SZK->ZK_LOTE))
					if mv_par07	= 1		// Se for para calcular pelo peso vivo
						bonif := _nPrecAcr
					else
						bonif := precBase + ZCB->ZCB_VLACR
					endif
				else
				// Se no lote não tiver acrescimo
					bonif :=  precBase
				endif
		ENDCASE

		precoAtu += bonif
		_lTol := .F.

	elseIf SZK->ZK_PROGPGP = "002" 		// Se for Programa Hereford
		precoAtu := 0.0
		if mv_par07	= 1		// Se for para calcular pelo peso vivo
			precBase := _nPrecBas
			precBaseP := _nPrecBon
		else
			precBaseP := SZ9->Z9_PRECOBN	// Preço Bonus da SC	- antes era	SZ7->Z7_PRCANG
			precBase := SZ9->Z9_PRECO
		endif

		If precBaseP = 0
			MsgAlert("Preço Base Hereford não cadastrado!")
			Return
		Endif

		_lProg := .T.
		bonif  := 0
		bonif2 := 0
		DO CASE
			// Classificado no programa 006 , acima de 180/200 Kg de carcaça ele vai pegar o preço do programa 
			CASE pesofinal >= iif(mv_par05 = 1 .or. SZK->ZK_CATEG = '002', 180, 200)
				bonif := precBaseP
			// Classificado no programa 006 , abaixo de 180/200 Kg de carcaça ele vai pegar o 'Preço do Jovem'
			CASE pesofinal < iif(mv_par05 = 1 .or. SZK->ZK_CATEG = '002', 180, 200)
				ZCB->(DbSetOrder(3))
				if ZCB->(MsSeek(FWxFilial('ZCB') + SZK->ZK_NUMAM + SZK->ZK_LOTE))
					if mv_par07	= 1		// Se for para calcular pelo peso vivo
						bonif := _nPrecAcr
					else
						bonif := precBase + ZCB->ZCB_VLACR
					endif
				else
					// Se no lote não tiver acrescimo 	chamado  3048
					bonif :=  precBase
				endif
		ENDCASE

		precoAtu += bonif
		_lTol := .F.

	Endif

Return precoAtu

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função ClcBran - Cálculo para bonificação do Brangus                   ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ClcBran()

	If SZK->ZK_PROGPGP = "011" 		// Se for programa Brangus
		precBaseP := SZ9->Z9_PRECOBN	// Preço Bonus da SC	- antes era	SZ7->Z7_PRCANG
		precoAtu  := PrecBaseP

		If precBaseP = 0
			MsgAlert("Preço Base Brangus não cadastrado!")
			Return
		Endif

		_lExc  := .T.
		_lProg := .T.
		bonif  := 0

		DO CASE
			//CASE SZK->ZK_DENT = "1"
			CASE SZK->ZK_DENT = "0"
			If pesofinal >= 180 .And. pesofinal < 200		// Solicitado alteração pelo Diogo dia 13/04/2021 GLPI 1108
				bonif := precBaseP * 0.02
			ElseIf pesofinal >= 200 .And. pesofinal < 220
				bonif :=  precBaseP * 0.04
			ElseIf pesofinal >= 220 .And. pesofinal < 240
				bonif := precBaseP * 0.06
			ElseIf pesofinal >= 240
				bonif := precBaseP * 0.08
			Endif
			CASE SZK->ZK_DENT = "2"
			If pesofinal >= 180 .And. pesofinal < 220		// Solicitado alteração pelo Diogo dia 13/04/2021 GLPI 1108
				bonif := precBaseP * 0.02
			ElseIf pesofinal >= 220 .And. pesofinal < 240
				bonif := precBaseP * 0.04
			ElseIf pesofinal >= 240 .And. pesofinal < 260
				bonif := precBaseP * 0.06
			ElseIf pesofinal >= 260
				bonif := precBaseP * 0.08
			Endif
			CASE SZK->ZK_DENT $ "4/6"
			If pesofinal >= 180 .And. pesofinal < 240		// Solicitado alteração pelo Diogo dia 13/04/2021 GLPI 1108
				bonif := precBaseP * 0.02
			ElseIf pesofinal >= 240 .And. pesofinal < 260
				bonif := precBaseP * 0.04
			ElseIf pesofinal >= 260 .And. pesofinal < 280
				bonif := precBaseP * 0.06
			ElseIf pesofinal >= 280
				bonif := precBaseP * 0.08
			Endif
		ENDCASE

		precoAtu += bonif

		// Se for carcaça leve, pega o preço base de programa
		If pesofinal < _nPesoLeve
			precoAtu := precBaseP
		Endif
	Endif

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função ClcGO - Cálculo da bonificação para GO                          ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ClcGO()

	valCouro := GETMV("MV_COURO") 				// Valor pago somente pelo couro

	If SZK->ZK_PROGPGP $ "004/009" .And. SZE->ZE_TPCOM = "F" .And. !Empty(SZ9->Z9_TABPREC) .And. SZK->ZK_DESTINO = "C"	// Filtra o programa Prog. GO  ou Prog. GOS - Tipo de compra tem que ser fechado - Tabela de preço tem que ser apontada - Tem que ter o destino de camara
		PrecoAtu := SZ9->Z9_PRECOBN				// Preço Bonus da SC	- antes era	SZ7->Z7_MAESALQ		// Preço máximo ESALQ
	Else
		PrecoAtu := SZ9->Z9_PRECOBN				// Preço Bonus da SC	- antes era	SZ7->Z7_PMFRIGO
	Endif

	precbase := ClcGor()		//ClcGor(PrecoAtu)
	PrecoAtu := Precbase

	If SZK->ZK_DESTINO = "R" .And. SZE->ZE_TPCOM = "F"
		PrecoAtu := SZ9->Z9_PRECOBN * 0.35		// Preço Bonus da SC	- antes era	SZ7->Z7_PMFRIGO * 0.35
	ElseIf SZK->ZK_DESTINO = "G" .And. SZE->ZE_TPCOM = "F"
		PrecoAtu := valcouro
	Endif

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função ClcGor 													                  ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ClcGor()

	If substr(SZK->ZK_COBGOR,1,1) = "2" .And. SZK->ZK_DESTINO = "C"
		valor := _nVal * 0.85
	ElseIf substr(SZK->ZK_COBGOR,1,1) = "1" .And. SZK->ZK_DESTINO = "C"
		valor := _nVal * 0.60
	Else
		valor := _nVal
	Endif

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   Analise se a carcaça passou pela If e realiza desconto de peso ³
//³ Função CalcPeso - Aplica 2% de desconto por conta do resfriamento			     ³
//³                   Calcula para peso vivo                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function CalcPeso(_x)

	Private peso      := SZK->ZK_PECARC1 + SZK->ZK_PECARC2
	Private pesoreal  := 0.00
	Private desconto  := 0
	Private _nRetPeso := 0

	SZG->(DbSetOrder(1))
	SZG->(MsSeek(FWxFilial("SZG") + SZK->ZK_NUMAM))

	_dDtPraTras := Ctod("30/06/16")

	// Desconto por passar na If
	If SZK->ZK_IF = "S"
		If SZG->ZG_DATA < _dDtPraTras 								// Se a data do abate for menor que 30/06/16 mantem o calculo antigo
			If (SZK->ZK_PECARC1 + SZK->ZK_PECARC2) > 200	        // carcaça acima de 200Kg
				desconto := 10.00
			ElseIf (SZK->ZK_PECARC1 + SZK->ZK_PECARC2) <= 200   	// carcaça até 200Kg
				desconto := 7.50
			Endif
		else
			desconto := 0.92
		Endif
	Endif

	pesoreal := peso - (peso * 0.02) 		// Apura o peso real das carcaças - tratamento para se gerar movimentação de estoque - Bloco K
	//peso     := peso - desconto
	if desconto > 0
		peso := peso * desconto
	else
		peso := peso - desconto
	endif

	// Se é boi vivo o tipo de compra, o que conta é o peso do animal
	If SZE->ZE_TPCOM = "V"
		_cNum    := SZE->ZE_NUMERO
		_cCateg  := SZE->ZE_CATEG
		_cRastro := IIF(Empty(SZE->ZE_RASTRO),"N","S")
		peso     := PeCat(_cNum,_cCateg,_cRastro)
	ElseIf SZE->ZE_TPCOM = "Q"
		/* Quando for carcaça quente o peso não sofre desconto de 2%*/
	Else
		peso     := peso - (peso * 0.02)				// Desconto de 2% de resfriamento
	Endif

	// _x = 1: processa o peso da carcaça com os descontos de peso do negócio
	// _x = 2: leva o peso real da carcaça para fins de movimentação - Bloco K
	_nRetPeso := IIF(_x = 1,peso,pesoreal)

Return(_nRetPeso)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função PeCat - Cálcula o peso da categoria							   ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function PeCat(_cNum,_cCateg,_cRastro)

	_cChave   := FWxFilial("SZE") + SZE->ZE_NUMAM + SZE->ZE_LOTE
	_nQTDAnim := 0

	SZE->(DbSetOrder(7))
	SZE->(DbGoTop())
	SZE->(MsSeek(FWxFilial("SZE") +SZE->(_cNum+_cCateg)))
	While SZE->(!Eof()) .And. SZE->ZE_FILIAL = FWxFilial("SZE") .And. SZE->ZE_NUMERO = _cNum .And. SZE->ZE_CATEG = _cCateg
		_cRast := IIF(Empty(SZE->ZE_RASTRO),"N","S")
		If _cRast <> _cRastro
			SZE->(DbSkip())
			Loop
		Endif

		_nQTDAnim += SZE->ZE_QTD1UM

		SZE->(DbSkip())
	Enddo

	SZE->(DbSetOrder(2))
	SZE->(DbGoTop())
	SZE->(MsSeek(_cChave))

	_nPesoCateg := GetAdvFVal("SZR", "ZR_PESO", FWxFilial("SZR") + _cNum + _cCateg + _cRastro, 1)
	peso 		:= _nPesoCateg/_nQTDAnim

Return(Peso)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função CalcCom - Cálcula a comissão									   ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function CalcCom(_nPAtu)

	Local ValCom := 0
	Local k

	// Regra a partir de 01/12/2014
	For k := 1 To Len(aComis)
		If aComis[k,1] = _nPAtu
			If aComis[k,2] = "1"
				ValCom += 0
			ElseIf aComis[k,2] = "2"
				ValCom += (aComis[k,3] * aComis[k,1]) * (1.50/100)
			ElseIf aComis[k,2] = "3"
				ValCom += (aComis[k,3] * aComis[k,1]) * (1.50/100)
			ElseIf aComis[k,2] = "4"
				ValCom += (aComis[k,3] * aComis[k,1]) * (1.50/100)
			ElseIf aComis[k,2] = "5"
				ValCom += (aComis[k,3] * aComis[k,1]) * (1.50/100)
			Endif
		Endif
	Next

Return(ValCom)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função StatPCP para mostrar status da legenda	                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function StatPCP()

	aRet:={1,0,0,0,0,0} 	// 1 abe 2 fec 3 parc 4 If, TOTAL OP, JA PROCESSADOS, FALTAM, pend

	SZK->(DbSetOrder(2))
	SZK->(Msseek(FWxFilial("SZK") + TRB->Z4_NUMAM + TRB->Z4_LOTE))
	While SZK->(!Eof()) .And. SZK->ZK_FILIAL + SZK->ZK_NUMAM + SZK->ZK_LOTE = FWxFilial("SZK") + TRB->Z4_NUMAM + TRB->Z4_LOTE
		aRet[2]++

		If SZK->ZK_OK = "S"
			aRet[3]++
		Endif

		If SZK->ZK_OK = " "
			aRet[5]++
		Endif

		If SZK->ZK_OK = "P"
			aRet[6]++
		Endif

		SZK->(DbSkip())
	EndDo

	aRet[4] := aRet[2]-(aRet[3]+aRet[6])

	DO CASE
		CASE aRet[6] > 0
		aRet[1] := 4
		CASE aRet[2] = 0
		aRet[1] := 1
		CASE aRet[4] = 0
		aRet[1] := 2
		OTHERWISE
		aRet[1] := 3
	ENDCASE

Return(aRet)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função Z4Leg para mostrar a legenda  		                           ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function Z4Leg()

	Local aLegenda := {}

	// Monta as cores
	AADD(aLegenda,{"BR_VERMELHO",   	"Aberto" 	})
	AADD(aLegenda,{"BR_VERDE",			"Fechado" 	})
	AADD(aLegenda,{"BR_AZUL",			"Parcial" 	})
	AADD(aLegenda,{"BR_AMARELO",		"Pendente" 	})

	BrwLegenda("Seleção dos Lotes para Fechamento", "Status", aLegenda)

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função MenuDef                            	                           ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function MenuDef()

	Local aRotina :={ {OemToAnsi("Fechamento")	, "U_Fechto()"  , 0 , 	4		},;
	{OemToAnsi("Portal")		, "U_Portal()"  , 0 , 	2		},;
	{OemToAnsi("Legenda")		, "U_Z4Leg()" 	, 0 ,	2,, .F.	} }

Return(aRotina)


Static Function _GetPar1()

	_cRet := GETMV("MV_COURO")

Return(_cRet)


Static Function _GetPar2()

	_cRet := GETMV("MV_BRASTRO")

Return(_cRet)


//-----------------------------------------------------------------------
/*/{Protheus.doc} _CalcPV
Função que calcula e grava peso vivo na tabela SZK
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function _CalcPV(dAbate, cNumAm, cLote, cFornec, nPreco, nRecnoZAG)

	Local nRendFemea := SuperGetMV("PV_RDFEMEA",.F., 51.00) / 100
	Local nRendMacho := SuperGetMV("PV_RDMACHO",.F., 53.00)	/ 100
	Local _dAbate	 := dAbate
	Local _cNumAm    := cNumAm
	Local _cLote	 := cLote
	Local _cFornec	 := Substr(cFornec,1,6)
	Local _cLoja	 := Substr(cFornec,7,2)
	Local _nPreco    := nPreco
	Local _nRecnoZAG := nRecnoZAG

	cQuery := "SELECT ZAG_EMISSA, "
	cQuery += "       ZAG_NUMAM, "
	cQuery += "       ZAG_LOTE, "
	cQuery += "       ZAG_FORNEC, "
	cQuery += "       A2_NOME, "
	cQuery += "       ZAG_LOJA, "
	cQuery += "       ZAG_PRODUT, "
	cQuery += "       B1_DESC, "
	cQuery += "       ZK_ORDEM, "
	cQuery += "       ZK_PRECOBO, "
	cQuery += "       ZK_CONTROL, "
	cQuery += "       ZK_LOCAL, "
	cQuery += "       ZK_PETOTAL, "
	cQuery += "       ZK_PESDESC, "
	cQuery += "       ZK_DESCONT, "
	cQuery += "  CASE WHEN ZK_DESCONT = 'S' THEN ZK_PESDESC "
	cQuery += "       ELSE ZK_PETOTAL "
	cQuery += "   END AS 'PESO_LIQUIDO',"	// Esse CASE serve para identificaro peso correto, desconsiderando as condenas
	// Cálculo de subtotal para rateio pela proporcionalidade em função do peso aferido no abate
	cQuery += "( CASE WHEN ZK_DESCONT = 'S' THEN ZK_PESDESC "
	cQuery += "       ELSE ZK_PETOTAL "
	cQuery += "   END / (SELECT SUM( "
	cQuery += "                 CASE WHEN ZK_DESCONT = 'S' THEN ZK_PESDESC "
	cQuery += "                      ELSE ZK_PETOTAL "
	cQuery += "                  END) AS 'TOTAL' "
	cQuery += "            FROM " + RetSQLName("SZK") + " SZK_SUB3"
	cQuery += "           WHERE SZK_SUB3.ZK_LOTE = '" + _cLote + "'"
	cQuery += "             AND SZK_SUB3.ZK_NUMAM = '" + _cNumAm + "'"
	cQuery += "         ) "
	cQuery += ") AS 'PERCENTUAL', "	// % Estimado para calcular o peso bruto, esse item é uma estimativa baseada no peso da carcaça e com ele será estimado um peso de animal vivo (PESO_BRUTO)
	cQuery += "       ZD_NUMERO AS 'ORDEM_RECEBIMENTO', "
	cQuery += "       ZA_NUMERO AS 'SOLIC_COMPRA', "
	cQuery += "       ZA_CODFOR, "
	cQuery += "       ZA_LOJA, "
	cQuery += "       ZK_SEXO, "
	cQuery += "       ZR_RECEB, "
	cQuery += "       ZR_PESOFRI, "
	// Subconsulta para calcular a quantidade de animais recebidos
	cQuery += "(SELECT SUM(ZE_QTD1UM) "
	cQuery += "   FROM " + RetSQLName("SZE") + " SZE_SUB"
	cQuery += "  INNER JOIN " + RetSQLTab("SZR") + " (NOLOCK) ON ZR_FILIAL = '" + FWxFilial("SZR") + "' AND ZR_RECEB = SZE_SUB.ZE_NUMERO AND ZR_CATEG = SZE_SUB.ZE_CATEG AND " + RetSqlDel("SZR") "
	cQuery += "  WHERE SZE_SUB.ZE_NUMERO = ZE_NUMERO"
	cQuery += "    AND SZE_SUB.ZE_LOTE = '" + _cLote + "'"
	cQuery += "    AND SZE_SUB.ZE_NUMAM = '" + _cNumAm + "'"
	cQuery += "    AND SZE_SUB.D_E_L_E_T_ = '' "
	cQuery += ") AS 'QTD_ANIM_RECEB', "
	// Case para identificar o peso quando o saldo na SZR for igual a zero
	cQuery += "CASE WHEN ZR_PESOFRI = '0' THEN "
	cQuery += "          CASE WHEN ZK_DESCONT = 'S' THEN ZK_PESDESC "
	cQuery += "               WHEN ZK_DESCONT = '' THEN ZK_PETOTAL "
	cQuery += "               ELSE NULL "
	cQuery += "          END "
	cQuery += "    ELSE ROUND(( "
	cQuery += "         ZR_PESOFRI / (SELECT SUM(ZE_QTD1UM) "
	cQuery += "                         FROM " + RetSQLName("SZE") + " SZE_SUB2"
	cQuery += "                        INNER JOIN " + RetSQLTab("SZR") + " (NOLOCK) ON ZR_FILIAL = '" + FWxFilial("SZR") + "' AND ZR_RECEB = SZE_SUB2.ZE_NUMERO AND ZR_CATEG = SZE_SUB2.ZE_CATEG AND " + RetSqlDel("SZR") "
	cQuery += "                        WHERE SZE_SUB2.ZE_NUMERO = ZE_NUMERO"
	cQuery += "                          AND SZE_SUB2.ZE_LOTE = '" + _cLote + "'"
	cQuery += "                          AND SZE_SUB2.ZE_NUMAM = '" + _cNumAm + "'"
	cQuery += "                          AND SZE_SUB2.D_E_L_E_T_ = '' "
	cQuery += "                      ) "
	cQuery += "         ),2) "
	cQuery += "END AS 'PESO_CALCULADO_BALANCA', "		// Esse é o peso resultante da divisão do total da SZR / QTD_ANIM_RECEB
	cQuery += "       SZK.R_E_C_N_O_ SZKRECNO, "
	// PASSO 1 - Cálculo do peso BRUTO "Considerando desconto de peso 
	// Case que direciona o caminho ou considerando o peso apondado no recebimento ou o percentual fixo 
	cQuery += "CASE WHEN (AVG(ZR_PESOFRI)
	cQuery += "          ) > 1 THEN "					// Quando for informado o peso no recebimento de gado fazemos isso abaixo:
	cQuery += "                ROUND((CASE WHEN ZK_DESCONT = 'S' THEN ZK_PESDESC"	// Laço de case que avalia o peso a ser rateado de ZR_PESOFRI para cada carcaça
	cQuery += "                            ELSE ZK_PETOTAL "
	cQuery += "                        END / (SELECT SUM(CASE WHEN ZK_DESCONT = 'S' THEN ZK_PESDESC "	// Case que avalia o percentual da determinada carcaça do universo de LOTE+AVISO DE MATANÇA
	cQuery += "                                               ELSE ZK_PETOTAL "
	cQuery += "                                           END"
	cQuery += "                                         ) AS 'TOTAL' "
	cQuery += "                                 FROM " + RetSQLName("SZK") + " SZK_SUB3"
	cQuery += "                                WHERE SZK_SUB3.ZK_LOTE = '" + _cLote + "'"
	cQuery += "                                  AND SZK_SUB3.ZK_NUMAM = '" + _cNumAm + "'"
	cQuery += "                                  AND SZK_SUB3.D_E_L_E_T_ = '' "
	cQuery += "                              )) * ZR_PESOFRI,2) "
	cQuery += "     ELSE "
	// Peso apurado baseado no sexo
	// Aqui teriamos que elencar a um rendimento médio que pode ser alterado pela PROGEPEC
	// -- UTILIZADO UMA ESTIMATIVA MÉDIA, 51% VACA E 53% BOI, ESSE VALOR SERÁ APLICADO APENAS QUANDO NÃO HOUVER REGISTRO NO CAMPO ZR_PESOFRI
	cQuery += "    ROUND(CASE 
	cQuery += "          WHEN ZK_SEXO = 'F' THEN "
	cQuery += "               CASE "
	cQuery += "                   WHEN ZK_DESCONT = 'S' THEN ZK_PESDESC / " + Str(nRendFemea)
	cQuery += "                   WHEN ZK_DESCONT = '' THEN ZK_PETOTAL / " + Str(nRendFemea)
	cQuery += "                   ELSE NULL "
	cQuery += "               END "
	cQuery += "          WHEN ZK_SEXO = 'M' THEN "
	cQuery += "               CASE "
	cQuery += "                   WHEN ZK_DESCONT = 'S' THEN ZK_PESDESC / " + Str(nRendMacho)
	cQuery += "                   WHEN ZK_DESCONT = '' THEN ZK_PETOTAL / " + Str(nRendMacho)
	cQuery += "                   ELSE NULL "
	cQuery += "               END "
	cQuery += "          ELSE NULL "
	cQuery += "    END,2) END AS 'PESO_BRUTO' "
	cQuery += "  FROM " + RetSQLTab("ZAG") + " (NOLOCK) "
	cQuery += " INNER JOIN " + RetSQLTab("SZK") + " (NOLOCK) ON ZK_NUMAM = ZAG_NUMAM AND ZK_LOTE = ZAG_LOTE AND ZK_PRECOBO = ZAG_PRECO AND " + RetSqlDel("SZK") "
	cQuery += " INNER JOIN " + RetSQLTab("SA2") + " (NOLOCK) ON A2_COD = ZAG_FORNEC AND A2_LOJA = ZAG_LOJA AND " + RetSqlDel("SA2") "
	cQuery += " INNER JOIN " + RetSQLTab("SZD") + " (NOLOCK) ON ZD_FORNECE = ZAG_FORNEC AND ZD_LOJA = ZAG_LOJA AND " + RetSqlDel("SZD") "
	cQuery += " INNER JOIN " + RetSQLTab("SZA") + " (NOLOCK) ON ZD_NUMERO = ZA_ORDREC AND ZA_ABATE = ZAG_EMISSA AND " + RetSqlDel("SZA") "
	cQuery += " INNER JOIN " + RetSQLTab("SB1") + " (NOLOCK) ON B1_FILIAL = '" + FWxFilial("SB1") + "' AND ZAG_PRODUT = B1_COD AND " + RetSqlDel("SB1") "
	cQuery += " INNER JOIN " + RetSQLTab("SZR") + " (NOLOCK) ON ZR_FILIAL = '" + FWxFilial("SZR") + "' AND ZR_RECEB = ZD_NUMERO AND ZR_CATEG = ZK_CATEG AND " + RetSqlDel("SZR") "
	cQuery += " WHERE ZAG_EMISSA = '" + Dtos(_dAbate) + "'"
	cQuery += "   AND ZAG_LOTE = '" + _cLote + "'"
	cQuery += "   AND ZAG_FORNEC = '" + _cFornec + "'"
	cQuery += "   AND ZAG_LOJA = '" + _cLoja + "'"
	cQuery += "   AND ZAG_PRECO = " + AllTrim(Str(_nPreco))
	cQuery += "   AND " + RetSqlDel("ZAG")
	cQuery += " GROUP BY ZAG_EMISSA, ZAG_NUMAM, ZAG_LOTE, ZAG_FORNEC, A2_NOME, ZAG_LOJA, ZAG_PRODUT, B1_DESC, ZK_ORDEM, ZK_PRECOBO, ZK_CONTROL, ZK_LOCAL, ZK_PETOTAL, ZK_PESDESC, ZK_DESCONT, ZA_NUMERO, ZA_CODFOR, ZA_LOJA, ZK_SEXO, ZR_RECEB, ZR_PESOFRI, ZK_NUMAM ,ZK_LOTE, ZD_NUMERO, SZK.R_E_C_N_O_"

	cQuery := ChangeQuery(cQuery)

	If Select("TRBPV") != 0
		TRBPV->(DbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TRBPV"

	DbSelectArea("TRBPV")
	DbGoTop()
	While !TRBPV->(Eof())

		DbSelectArea("SZK")
		SZK->( DbGoTo(TRBPV->SZKRECNO) )
		RecLock("SZK",.F.)
		SZK->ZK_PESVIVO := TRBPV->PESO_BRUTO
		SZK->ZK_RECNZAG := _nRecnoZAG
		MsUnLock()

		TRBPV->(DbSkip())
	EndDo

	TRBPV->(DbCloseArea())

Return
