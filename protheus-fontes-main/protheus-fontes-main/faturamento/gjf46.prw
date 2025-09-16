#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF46 º Autor ³     Giuliano Forgiariniº Data ³  03/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Geral de Cargas                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAOMS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF46()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio   "
	Local cDesc2         := "apresentando os detalhes das cargas e dos pre-pedidos"
	Local cDesc3         := "de acordo com os parametros informados na rotina     "
	//Local cPict          := ""
	Local titulo         := "RELATORIO GERAL DE CARGA"
	Local nLin           := 80

	Local Cabec1         := "   Codigo   Produto                 Qt. Prev.  Qt.Real. Peso Prev.    Peso Real.  Preço Kg   Desconto      Total"
	Local Cabec2         := ""
	//Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.                                              
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "GJF46" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF46"
	//Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF46" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "ZZ3"

	dbSelectArea("ZZ3")
	dbSetOrder(1)

	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//Local nOrdem

	dbSelectArea(cString)
	ZZ3->(dbSetOrder(1))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	ZZ3->(SetRegua(RecCount()))

	ZZ3->(dbGoTop())
	ZZ3->(dbseek(FWxfilial('ZZ3') + DTOS(mv_par01),.t.))

	_nTotCargC   := 0.00
	_TCargPeso   := 0.00   
	_TCargPreco  := 0.00		                                         
	_cNumPreDes := ''
	_cNumPItDes := ''
	While ZZ3->(!EOF()) .and. ZZ3->ZZ3_FILIAL = FWxfilial('ZZ3') .and. ZZ3->ZZ3_DTCAR <= mv_par02
		incregua()

		if ZZ3->ZZ3_NUM < mv_par03 .or. ZZ3->ZZ3_NUM > mv_par04
			ZZ3->(dbskip())
			loop
		endif

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		@nlin,01 psay 'Pre-Carregamento n.: '+ ZZ3->ZZ3_NUM + '   Placa: ' + ZZ3->ZZ3_PLACA + '   Data carregamento: '+ DTOC(ZZ3->ZZ3_DTCAR)
		nlin++
		@nlin,01 psay 'Responsável: '+ ZZ3->ZZ3_USUAR

		if !empty(ZZ3->ZZ3_OBS)
			@nlin,30 psay 'Observações: '+ ZZ3->ZZ3_OBS
		endif
		nlin++

		ZZ4->(dbsetorder(1))
		if ZZ4->(dbseek(FWxfilial('ZZ4')+ZZ3->ZZ3_NUM))
			While ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4') .and. ZZ4->ZZ4_PRECAR = ZZ3->ZZ3_NUM
				If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				Endif

				nlin++       

				_cNumNF := ''
				_cNumNF := fBuscaCPO('SC5',1,FWxfilial('SC5')+ZZ4->ZZ4_NUMPED,'C5_NOTA')

				@nlin,02 psay 'Pedido n.: ' + ZZ4->ZZ4_NUM + ' (NF: ' + _cNumNF + ')  ' + ZZ4->ZZ4_OBS
				nlin++
				@nlin,02 psay ZZ4->ZZ4_CODCLI + '/' + ZZ4->ZZ4_LOJA
				@nlin,15 psay substr(fBuscaCPO('SA1',1,FWxfilial('SA1')+ZZ4->(ZZ4_CODCLI+ZZ4_LOJA),'A1_NOME'),1,20)

				do case
					case  ZZ4->ZZ4_TPOPER = 'V'
					@nlin,45 psay 'Oper.: Venda'
					case  ZZ4->ZZ4_TPOPER = 'T'
					@nlin,45 psay 'Oper.: Transferencia'
					case  ZZ4->ZZ4_TPOPER = 'R'
					@nlin,45 psay 'Oper.: Remessa'
					case  ZZ4->ZZ4_TPOPER = 'C'
					@nlin,45 psay 'Oper.: Compra'
					case  ZZ4->ZZ4_TPOPER = 'B'
					@nlin,45 psay 'Oper.: Bonificação'
				endcase

				_nTotLiqPeso := 0.00
				_nTotLiqCaix := 0.00      
				_nTotPreco   := 0.00

				ZZ5->(dbsetorder(1))
				if ZZ5->(dbseek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
					While ZZ5->(!eof()) .and. ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5')   

						If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 8
						Endif

						nlin++
						@nlin,03 psay substr(ZZ5->ZZ5_COD,1,6)
						@nlin,12 psay substr(ZZ5->ZZ5_DESC,1,20)
						@nlin,35 psay transform(ZZ5->ZZ5_QPCAIX,'@E 999,999')
						@nlin,45 psay transform(ZZ5->ZZ5_QRCAIX,'@E 999,999')
						@nlin,55 psay transform(ZZ5->ZZ5_QPPESO,"@E 999,999.99")
						@nlin,70 psay transform(ZZ5->ZZ5_QRPESO,"@E 999,999.99") 
						@nlin,85 psay transform(ZZ5->ZZ5_PRECO,"@E 999.99")
						_nBoni := 0
						if !empty(ZZ5->ZZ5_BONIF)
							if ZZ5->ZZ5_TPBONI = 'D'
								_nBoni := ZZ5->ZZ5_BONIF * (-1)
							else 
								_nBoni := ZZ5->ZZ5_BONIF
							endif 
						endif
						@nlin,95 psay transform(_nBoni,"@E 99.99")
						@nlin,105 psay transform((ZZ5->ZZ5_PRECO + _nBoni) * ZZ5->ZZ5_QRPESO,"@E 999,999.99")
						if ZZ5->ZZ5_QRPESO = 0
							@nlin,120 psay "Falta!"
						endif
						_nTotLiqCaix += ZZ5->ZZ5_QRCAIX
						_nTotLiqPeso += ZZ5->ZZ5_QRPESO 
						if ZZ5->ZZ5_QRPESO != 0
							_nTotPreco   += (ZZ5->ZZ5_PRECO + _nBoni) * ZZ5->ZZ5_QRPESO 
						endif
						_TCargPeso   += ZZ5->ZZ5_QRPESO 
						_nTotCargC   += ZZ5->ZZ5_QRCAIX  
						if ZZ5->ZZ5_QRPESO != 0
							_TCargPreco  += (ZZ5->ZZ5_PRECO + _nBoni) * ZZ5->ZZ5_QRPESO 
						endif
						ZZ5->(dbskip())
					enddo              
				endif            
				nlin++

				@nlin,03 psay "Totais:"
				@nlin,44 psay transform(_nTotLiqCaix,'@E 999,999')    
				@nlin,68 psay transform(_nTotLiqPeso,'@E 999,999.99')    
				@nlin,105 psay transform(_nTotPreco,'@E 999,999.99')    
				nlin++

				ZZ4->(dbskip())
			enddo
		endif
		nLin += 2

		ZZ3->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	EndDo

	If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif		
	@nlin,03  psay "Totais:"                     
	@nlin,40  psay transform(_nTotCargC,'@E 999,999,999')    
	@nlin,64  psay transform(_TCargPeso,"@E 999,999,999.99")    
	@nlin,101 psay transform(_TCargPreco,"@E 999,999,999.99")    


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return
