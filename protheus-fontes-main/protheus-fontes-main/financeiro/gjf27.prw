#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF27     º Autor Giuliano Forgiarini  º Data ³  02/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de Controle de Carteiras								  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF27()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este relatório tem por objetivo Buscar a posição "
	Local cDesc2         := "das Carteiras por banco e por data do vencimetno"
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo         := "POSICAO DE CARTEIRAS DE COBRANCA"
	Local nLin           := 75

	Local Cabec2         := "            Banco             Quant. Títulos       Valor Total"
	Local Cabec1         := ""
	Local Cabec3         := " "
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "GJF27" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF27"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF27" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "SE1"

	dbSelectArea("SE1")

	pergunte(cPerg,.F.)

	Cabec1 := "    Período de Apuração: de "+ dtoc(mv_par03) + " até " + dtoc(mv_par04)

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local _cPrev 	:= ' '
	Local _cCont 	:= 0
	Local _lLin 	:= 1   
	Local cNumTit  := 0
	Local cValTot  := 0 
	Local cPortador:= 0
	Local i
	Local j

	SE1->(dbsetorder(6)) 
	SE1->(dbGoTop())

	_cFiltro  := ''
	_aPortado := {}
	_nPos     := 0
	_cBanco   := 0

	if !empty(mv_par03)
		SE1->(DbSeek(xfilial('SE1')+dtos(mv_par03),.t.)) 
	endif

	do While SE1->(!EOF()) .and. SE1->E1_FILIAL = xfilial('SE1') .and. SE1->E1_EMISSAO < mv_par04   


		if SE1->E1_TIPO != 'NF' 
			SE1->(dbskip())
			loop
		endif           

		if  SE1->E1_EMISSAO < mv_par03 .or. (SE1->E1_EMISSAO > mv_par04 .and. empty(SE1->E1_BAIXA))
			SE1->(dbskip())
			loop
		endif

		if !empty(SE1->E1_BAIXA) .and. SE1->E1_BAIXA < mv_par04 
			SE1->(dbskip())
			loop
		endif

		if SE1->E1_PORTADO < mv_par01 .or. SE1->E1_PORTADO > mv_par02 
			SE1->(dbskip())
			loop
		endif

		_nPos := aScan(_aPortado,{|X| X[1] == SE1->E1_PORTADO})

		if  _nPos > 0  
			_aPortado[_nPos,2] += SE1->E1_VALOR 
			_aPortado[_nPos,3]++
		else   
			AADD(_aPortado,{SE1->E1_PORTADO,SE1->E1_VALOR,1})
		endif

		SE1->(dbSkip()) 
	EndDo  

	_aPortOrd  := {'',0,0}

	for i:= 1 to len(_aPortado)
		for j := 1 to i-1
			if _aPortado[j,1] > _aPortado[j+1,1]  

				_aPortOrd[1]  := _aPortado[j,1]  
				_aPortOrd[2]  := _aPortado[j,2] 
				_aPortOrd[3]  := _aPortado[j,3]  

				_aPortado[j,1] := _aPortado[j+1,1]
				_aPortado[j,2] := _aPortado[j+1,2]
				_aPortado[j,3] := _aPortado[j+1,3]

				_aPortado[j+1,1] := _aPortOrd[1] 
				_aPortado[j+1,2] := _aPortOrd[2] 
				_aPortado[j+1,3] := _aPortOrd[3] 
			endif
		next
	next    

	SetRegua(len(_aPortado))

	for i:= 1 to len(_aPortado)

		incregua() 

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 60 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)                                                             
			nLin := 9
		endif 

		_cBanco := FBuscaCPO('SA6',1,xfilial('SA6')+_aPortado[i,1],'A6_NREDUZ')

		@nlin,02 psay iif(empty(_aPortado[i,1]),'000',_aPortado[i,1])
		@nlin,08 psay iif(empty(_cBanco),'CARTEIRA',_cBanco)
		@nlin,33 psay transform(_aPortado[i,3],'@E 9,999')
		@nlin,48 psay transform(_aPortado[i,2],'@E 999,999,999.99')

		nlin++    

	next

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

