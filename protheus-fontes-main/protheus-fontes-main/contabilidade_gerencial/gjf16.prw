#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁGJF16    ╨ Autor Giuliano Forgiarini ╨ Data Ё  11/06/07   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Lista as divergencias entre PC e NF de entrada             ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6 IDE                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

User Function GJF16()

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de Variaveis                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := "de divergencias entre PC e NF de entrada, excluindo"
	Local cDesc3        := "PCs de gado, de acordo com sua parametrizaГЦo.     "
	Local cPict         := ""
	Local titulo       	:= "DIVERGENCIAS PC x NF"
	Local nLin         	:= 80
	Local Cabec1       	:= "Pedido: Item: EmissЦo: Fornecedor:"
	Local Cabec2       	:= ""
	Local imprime      	:= .T.
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "P"
	Private nomeprog    := "GJF16" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := "GJF16"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF16" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString 	:= "SC7"

	Pergunte(cPerg,.F.)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta a interface padrao com o usuario...                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Processamento. RPTSTATUS monta janela com a regua de processamento. Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	dbSelectArea(cString)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё SETREGUA -> Indica quantos registros serao processados para a regua Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	SetRegua(RecCount())
	SC7->(DbSetOrder(1))
	SC7->(DbGoTop())
	SC7->(Dbseek(xFilial("SC7") + mv_par01, .T.))
	While SC7->(!Eof()) .And. SC7->C7_NUM <= mv_par02
		total := 0

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica o cancelamento pelo usuario...                             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Impressao do cabecalho do relatorio. . .                            Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nLin > 55 // Salto de PАgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif  

		If SC7->C7_GRUPO = '1000'
			SC7->(DbSkip())
			Loop
		Endif 

		If SC7->C7_EMISSAO < mv_par03 .Or. SC7->C7_EMISSAO > mv_par04
			SC7->(DbSkip())
			Loop
		Endif 

		pedido := SC7->C7_NUM
		item   := SC7->C7_ITEM

		@ nlin, 00 PSAY SC7->C7_NUM
		@ nlin, 08 PSAY SC7->C7_ITEM
		@ nlin, 13 PSAY SC7->C7_EMISSAO
		@ nlin, 23 PSAY SC7->C7_FORNECE
		@ nlin, 31 PSAY SC7->C7_LOJA

		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial('SA2') + SC7->C7_FORNECE + SC7->C7_LOJA, .T.))
		
		@ nlin, 34 PSAY SA2->A2_NOME
		nlin++
		
		@ nlin, 00 PSAY "Prod: " + Transform(SC7->C7_PRODUTO,"@E ######") + "  " + Substr(SC7->C7_DESCRI,1,30) + "  " + "Quant: " + Transform(SC7->C7_QUANT,"@E ###,###.##")
		nlin++

		@ nlin, 00 PSAY "Notas:"
		nlin++

		If SC7->C7_ORIGEM == "AJUPCXML"

			SD1->(DbOrderNickname('SD1PCITEM'))
			If SD1->(DBSeek( xFilial('SD1') + pedido, .T.))
				While SD1->(!Eof()) .And. SD1->D1_PEDIDO = pedido

					If SD1->D1_COD == SC7->C7_PRODUTO 
						@ nlin, 05 PSAY SD1->D1_DOC
						@ nlin, 13 PSAY "Quant: " + Transform(SD1->D1_QUANT,"@E ###,###.##")
						@ nlin, 40 PSAY "EmissЦo: " + Transform(SD1->D1_EMISSAO,"@E ##/##/##")
						total := total + SD1->D1_QUANT
						
						If total > SC7->C7_QUANT
							nlin++
							@ nlin, 25 PSAY "***RECEBIMENTO EXCEDIDO***"
						Endif
					Endif

					SD1->(DbSkip())
					nlin++
				EndDo  
			Endif

		Else

			SD1->(DbOrderNickname('SD1PCITEM'))
			If SD1->(DBSeek(xFilial('SD1') + pedido + item, .T.))
				While SD1->( !Eof()) .And. SD1->D1_PEDIDO = pedido .And. SD1->D1_ITEMPC = item

					@ nlin, 05 PSAY SD1->D1_DOC
					@ nlin, 13 PSAY "Quant: " + Transform(SD1->D1_QUANT,"@E ###,###.##")
					@ nlin, 40 PSAY "EmissЦo: " + Transform(SD1->D1_EMISSAO,"@E ##/##/##")
					total := total + SD1->D1_QUANT

					If total > SC7->C7_QUANT
						nlin++
						@ nlin, 25 PSAY "***RECEBIMENTO EXCEDIDO***"
					Endif

					SD1->(DbSkip())
					nlin++
				EndDo  
			Endif
		Endif

		@ nlin, 00 PSAY Replicate('_',80)
		nlin++

		DbSkip() // Avanca o ponteiro do registro no arquivo
	EndDo

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Finaliza a execucao do relatorio...                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SET DEVICE TO SCREEN

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se impressao em disco, chama o gerenciador de impressao...          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return
