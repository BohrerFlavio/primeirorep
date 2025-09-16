#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF165     º Autor ³ Giuliano Forgiarini Data ³  06/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Relatorio de analise e formação de preço para produtos da   º±±
±±º          ³graxaria                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Diretoria, Compra de Gado, Diretoria                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF165


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       := "para análise e formação de preço dos produtos      "
	Local cDesc3       := "industrializados na Graxaria.                      "
	Local cPict        := ""
	Local titulo       := "FORMAÇÃO DE PRECO - GRAXARIA"
	Local nLin         := 80
	Local Cabec1       := ""
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Local i
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "GJF165" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private cPerg        := "GJF165"
	Private wnrel        := "GJF165" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _nQtAnim     := 0 
	Private _nCont       := 0
	Private _nPesoT      := 0.00                             
	Private _nPesoM      := 0.00 
	Private _nProducao   := 0.00
	Private _nCustoT     := 0.00   
	Private _nCusOpera   := 0.00
	Private _nCusRej     := 0.00
	Private _nCusPCab    := 0.00  
	Private _nFatServ    := 0.00 
	Private _nRecLiqServ := 0.00  
	Private _nRecTotal   := 0.00  
	Private _nResTotal   := 0.00
	Private _nResCab     := 0.00
	Private _aRec        := {}

	AADD(_aRec,{'FCO',0,0,0,0,0,0,0,0,0})
	AADD(_aRec,{'FS',0,0,0,0,0,0,0,0,0})
	AADD(_aRec,{'S',0,0,0,0,0,0,0,0,0})

	if !pergunte(cPerg,.t.)
		return
	endif

	SZK->(DbSetOrder(4))
	SZK->(DbGoTop())
	if !SZK->(DbSeek(xfilial('SZK') + mv_par01))   
		return
	endif     

	SZG->(DbSetOrder(1))
	SZG->(DbSeek(xfilial('SZG')+mv_par01))

	_nCont := SZG->ZG_QTDTOT

	Processa({||ProcCarc()} ,"PROCESSAMENTO DE VALORES","Executando processamento de valores base...")

	_nPesoM := _nPesoT/_nQtAnim

	dbSelectArea('ZAH')
	dbSetOrder(1)      
	if !ZAH->(DbSeek(xfilial('ZAH') + mv_par02))
		alert('Parametros de rendimento não localizados!')
		return
	endif

	Cabec1 := ' Aviso de Matança n.º: ' + SZG->ZG_NUMAM
	Cabec2 := ' Realizado em: ' + dtoc(SZG->ZG_DATA)

	_nProducao   := _nPesoM * ZAH->ZAH_PREND    
	_nProdTot    := _nProducao * _nQtAnim
	_nCusRej     := _nProdTot * ZAH->ZAH_COMPKG  
	_nCusOpera   := ZAH->ZAH_OPERCA * _nQtAnim
	_nCustoT     := _nCusRej + _nCusOpera   
	_nCusPCab    := _nCustoT/_nQtAnim 
	_nFatServ    := ZAH->ZAH_PRCCAB * _nQtAnim  
	_nRecLiqServ := _nFatServ *(100 - (ZAH->(ZAH_IRPJ+ZAH_CSLL+ZAH_PISCOF)))/100

	//Calculo das receitas FCO
	_nPos := aScan(_aRec,{|aVal|aVal[1] = 'FCO'})

	_aRec[_nPos,02] := ZAH->ZAH_PREND2 
	_aRec[_nPos,03] := (_aRec[_nPos,2] * _nPesoM)/100
	_aRec[_nPos,04] := ZAH->ZAH_PVEND1
	_aRec[_nPos,05] := _aRec[_nPos,4] * _aRec[_nPos,3]
	_aRec[_nPos,06] := _nQtAnim * _aRec[_nPos,5]
	_aRec[_nPos,07] := ZAH->ZAH_IRPJ2
	_aRec[_nPos,08] := ZAH->ZAH_CSLL2
	_aRec[_nPos,09] := ZAH->ZAH_PISCO2
	_aRec[_nPos,10] := _aRec[_nPos,06] * (100 -(_aRec[_nPos,07] + _aRec[_nPos,08] + _aRec[_nPos,09])) / 100

	//Calculo das receitas FS
	_nPos := aScan(_aRec,{|aVal|aVal[1] = 'FS'}) 

	_aRec[_nPos,02] := ZAH->ZAH_PREND3
	_aRec[_nPos,03] := (_aRec[_nPos,2]*_nPesoM)/100  
	_aRec[_nPos,04] := ZAH->ZAH_PVEND2
	_aRec[_nPos,05] := _aRec[_nPos,4] * _aRec[_nPos,3]
	_aRec[_nPos,06] := _nQtAnim * _aRec[_nPos,5]
	_aRec[_nPos,07] := ZAH->ZAH_IRPJ3
	_aRec[_nPos,08] := ZAH->ZAH_CSLL3
	_aRec[_nPos,09] :=	ZAH->ZAH_PISCO3
	_aRec[_nPos,10] := _aRec[_nPos,06] * (100 -(_aRec[_nPos,07] + _aRec[_nPos,08] + _aRec[_nPos,09])) / 100

	//Calculo das receitas S
	_nPos := aScan(_aRec,{|aVal|aVal[1] = 'S'}) 

	_aRec[_nPos,02] := ZAH->ZAH_PREND4
	_aRec[_nPos,03] := (_aRec[_nPos,2]*_nPesoM)/100
	_aRec[_nPos,04] := ZAH->ZAH_PVEND4                
	_aRec[_nPos,05] := _aRec[_nPos,4] * _aRec[_nPos,3]
	_aRec[_nPos,06] := _nQtAnim * _aRec[_nPos,5]
	_aRec[_nPos,07] := ZAH->ZAH_IRPJ4
	_aRec[_nPos,08] := ZAH->ZAH_CSLL4
	_aRec[_nPos,09] := ZAH->ZAH_PISCO4
	_aRec[_nPos,10] := _aRec[_nPos,06] * (100 -(_aRec[_nPos,07] + _aRec[_nPos,08] + _aRec[_nPos,09])) / 100

	for i := 1 to len(_aRec)                            
		_nRecTotal +=  _aRec[i,10]    
	next
	_nRecTotal += _nRecLiqServ 
	_nResTotal := _nRecTotal  - _nCustoT 
	_nResCab   := _nResTotal/_nQtAnim

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint('ZAH',NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAH')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  06/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem
	Local i

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	@ nlin,00 psay '| VALORES BASE:  '
	nlin++

	@nlin,05 psay 'Cabeças abatidas: ' + transform(_nQtAnim,'@E 999,999,999')
	nlin++
	@nlin,05 psay 'Peso Total(kg):   ' + transform(_nPesoT,'@E 999,999,999.99')
	nlin++                                                                        
	@nlin,05 psay 'Peso Médio(kg):   ' + transform(_nPesoM,'@E 999,999,999.99')  
	nlin++
	@nlin,00 psay replicate('=',80)
	nlin++
	@nlin,00 psay '| CUSTOS:          '
	nlin++      
	@nlin,00 psay '| Compra Rejeitos: '
	nlin++
	@nlin,05 psay 'Rendimento(%):    ' + transform(ZAH->ZAH_PREND,'@E 999,999,999.99')  
	nlin++
	@nlin,05 psay 'Produção(kg/cab): ' + transform(_nProducao,'@E 999,999,999.99')  
	nlin++
	@nlin,05 psay 'Compra(R$/kg):    ' + transform(ZAH->ZAH_COMPKG,'@E 999,999,999.99')  
	nlin++      
	@nlin,05 psay 'Prod.Total(kg):   ' + transform(_nProdTot,'@E 999,999,999.99')  
	nlin++
	@nlin,05 psay 'Custo Total(R$):  ' + transform(_nCusRej,'@E 999,999,999.99')  
	nlin++      
	@nlin,00 psay '| Custo Operacional: '
	nlin++
	@nlin,05 psay 'Operação(R$/cab): ' + transform(ZAH->ZAH_OPERCA,'@E 999,999,999.99')  
	nlin++    
	@nlin,05 psay 'Custo Total(R$):  ' + transform(_nCusOpera,'@E 999,999,999.99')  
	nlin++  
	@nlin,00 psay '| Custo Final: '
	nlin++
	@nlin,05 psay 'Por Cabeça(R$):   ' + transform(_nCusPCab,'@E 999,999,999.99')  
	nlin++    
	@nlin,05 psay 'Custo Total(R$):  ' + transform(_nCustoT,'@E 999,999,999.99')  
	nlin++  
	@nlin,00 psay replicate('=',80)
	nlin++
	@nlin,00 psay '| RECEITAS: '
	nlin++
	@nlin,00 psay '| Serviços ao Frigorífico: '
	nlin++                                         
	@nlin,00 psay replicate('-',80)
	nlin++
	@nlin,00 psay 'Preço Cab.(R$):   ' + transform(ZAH->ZAH_PRCCAB,'@E 999,999,999.99')  
	nlin++ 
	@nlin,00 psay 'Faturamento(R$):  ' + transform(_nFatServ,'@E 999,999,999.99')  
	nlin++ 
	@nlin,00 psay 'IRPJ(%):          ' + transform(ZAH->ZAH_IRPJ,'@E 999,999,999.99')  
	nlin++ 
	@nlin,00 psay 'CSLL(%):          ' + transform(ZAH->ZAH_CSLL,'@E 999,999,999.99')  
	nlin++ 
	@nlin,00 psay 'PIS e COFINS(%):  ' + transform(ZAH->ZAH_PISCOF,'@E 999,999,999.99')  
	nlin++ 
	@nlin,00 psay 'Rec. Liquida(%):  ' + transform(_nRecLiqServ,'@E 999,999,999.99')  
	nlin+=2
	@nlin,00 psay '| Produtos: '
	nlin++                                         
	@nlin,00 psay replicate('-',80)
	nlin++
	_Col := 0
	for i:= 1 to len(_aRec)
		_cDescProd := '['+iif(_aRec[i,01] = 'FCO','Farinha Carne OSSO (FCO)',iif(_aRec[i,01] = 'FS','Farinha de Sangue (FS)','Sebo (S)'))+']'
		@nlin,_Col    psay _cDescProd    //Produto
		_Col += 27
	next

	nlin++

	_Col := 0
	for i:= 1 to len(_aRec)
		@nlin,_Col psay 'Rendim.(%):    ' + transform(_aRec[i,02],'@E 999,999.99')           //Rendimento %
		_Col += 27
	next

	nlin++              

	_Col := 0	                                                                                 
	for i:= 1 to len(_aRec)
		@nlin,_Col psay 'Prod.(kg/cab): ' + transform(_aRec[i,03],'@E 999,999.99')           //Produção kg/cab
		_Col += 27
	next

	nlin++   

	_Col := 0
	for i:= 1 to len(_aRec)
		@nlin,_Col psay 'P.Vend.(R$/kg):' + transform(_aRec[i,04],'@E 999,999.99')           //Preço venda R$/kg
		_Col += 27
	next

	nlin++              

	_Col := 0
	for i:= 1 to len(_aRec)
		@nlin,_Col psay 'Fatur.(R$/cab):' + transform(_aRec[i,05],'@E 999,999.99')           //Faturamento R$/cab                                              
		_Col += 27
	next

	nlin++              

	_Col := 0
	for i:= 1 to len(_aRec)	
		@nlin,_Col psay 'Fat. Total(R$):' +transform(_aRec[i,06],'@E 999,999.99')   //Faturamento total
		_Col += 27
	next

	nlin++              

	_Col := 0
	for i:= 1 to len(_aRec)	
		@nlin,_Col psay 'IRPJ (%):      ' + transform(_aRec[i,07],'@E 999,999.99')           //IRPJ
		_Col += 27
	next

	nlin++              

	_Col := 0
	for i:= 1 to len(_aRec)	
		@nlin,_Col psay 'CSLL (%):      ' + transform(_aRec[i,08],'@E 999,999.99')           //CSLL
		_Col += 27
	next

	nlin++              

	_Col := 0
	for i:= 1 to len(_aRec)	
		@nlin,_Col psay 'PIS/COFINS(%): ' + transform(_aRec[i,09],'@E 999,999.99')          //PIS e COFINS  
		_Col += 27
	next

	nlin++              

	_Col := 0
	for i:= 1 to len(_aRec)	
		@nlin,_Col psay 'Rec.Liq.(R$):  ' + transform(_aRec[i,10],'@E 999,999.99')   //Receita liquida total      
		_Col += 27
	next

	nlin++  
	@nlin,00 psay replicate('=',80)
	nlin++
	@nlin,00 psay '| RESULTADO: '  
	nlin++
	@nlin,05 psay 'Receita Total(R$):' + transform(_nRecTotal,'@E 999,999,999.99')  
	nlin++    
	@nlin,05 psay 'Custo Total(R$):  ' + transform(_nCustoT,'@E 999,999,999.99')  
	nlin++     
	@nlin,05 psay 'Resultado(R$/cab):' + transform(_nResCab,'@E 999,999,999.99')  
	nlin++    
	@nlin,05 psay 'Res. Total(R$):   ' + transform(_nResTotal,'@E 999,999,999.99')  


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


//Função para o tratamento do peso
Static Function ProcPeso(_ps,_if)

	//Penalização caso desviado a IF
	if _if = 'S' 
		if _ps > 200 
			_ps -= 10
		elseif _ps <=200
			_ps -= 7.5
		endif    
	endif                    

	//Somatorio dos pesos com desconto de 2%
	_ps := _ps * 0.98       

return  _ps


Static Function ProcCarc()

	ProcRegua(_nCont)

	SZK->(DbGoTop())
	SZK->(DbSeek(xfilial('SZK') + mv_par01))   
	While SZK->(!eof())  .and. SZK->ZK_FILIAL = xfilial('SZK') .and. SZK->ZK_NUMAM = mv_par01
		IncProc('Processando dados da carcaça n.º: ' + SZK->ZK_CONTROL)

		_nPesoT += ProcPeso(SZK->ZK_PETOTAL,SZK->ZK_IF)
		_nQtAnim++     

		SZK->(DbSkip())
	enddo

return
