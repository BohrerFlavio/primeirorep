#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF100  º Autor ³ Giuliano Forgiarini  º Data ³  18/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio distribuição de carcaças por classificações      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e PCP (SIGAPCP)                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF32()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio   "
	Local cDesc2         := "de carcaças produzidas no abate distribuidas por suas"
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo         := "Devoluções De Produto Acabado "
	Local nLin         	:= 80

	Local Cabec1       	:= " NR. DEV.     CLIENTE                          DT. ENTRADA "                   
	Local Cabec2       	:= "                                     "

	Local imprime      	:= .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "FBF32" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "FBF32"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "FBF32" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    	:= 0.00
	Private TotPeso    	:= 0.00

	pergunte(cPerg,.F.)

	//para verificação se existe previsao de pesagem

	wnrel := SetPrint('SZB',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


	cQuery := " SELECT ZB_NUM AS NUM, ZB_DTREAL AS ENTRADA, ZB_CLIENTE AS CLI, ZB_LOJA AS LOJA, ZB_NF AS NF, ZB_STATUS AS S,"
	cQuery += " ZB_DESTINO AS DESTINO, ZB_NOME AS NOME, ZB_CIDADE AS CIDADE,ZB_SERIE AS SERIE,"
	cQuery += " ZC_COD AS COD, ZC_DESCRI AS PRODUTO, ZC_QUANT AS QUANT,"
	cQuery += " ZC_PESO AS PESO, ZC_TOTAL AS TOTAL"
	cQuery += " FROM " + RetSqlName("SZB") + ", " + RetSqlName("SZC")  
	cQuery += " WHERE  SZB010.D_E_L_E_T_ <> '*'      AND "
	cQuery += "        SZC010.D_E_L_E_T_ <> '*'      AND "
	cQuery += " ZB_FILIAL = '" + xFilial("SZB") + "' AND "
	cQuery += " ZC_FILIAL = '" + xFilial("SZC") + "' AND " 
	cQuery += " ZB_NUM = ZC_NUM AND"
	cQuery += " ZB_DESTINO <> 'F' AND ZB_DESTINO <> 'D' AND ZB_DESTINO <> '' AND"
	cQuery += " (ZB_DATA   BETWEEN '" +  dtos(mv_par01) + "' AND '" +  dtos(mv_par02) + "') " 
	if mv_par03 = 1   // Menos o E
		cQuery += "AND (ZB_STATUS  = 'A' OR ZB_STATUS  = 'N' OR ZB_STATUS  = 'G' OR ZB_STATUS  = 'D' )"
	elseif mv_par03 = 2    //Finalizado = E                                                            
		cQuery += "AND ZB_STATUS  = 'E' "
	endif
	cQuery += " ORDER BY ZB_DTREAL,ZB_NUM,ZB_CLIENTE,ZB_LOJA,ZC_COD  "
	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("DEV") != 0
		DEV->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "DEV"

	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,'DEV')
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
	Local nOrdem
	Local _cNdev := ''
	Local _cStatus := ''
	Local _cDestino := ''
	Local	_nQuant := 0
	Local	_nPeso  := 0
	Local	_nTotal := 0
	Local _nTam		:= 75 

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	DEV->(dbGoTop())

	DEV->(SetRegua(RecCount()))

	While DEV->(!EOF())

		incregua()	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > _nTam // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif



		if  DEV->NUM != _cNdev 

			do case
				case DEV->S = 'A'
				_cStatus := 'Aberto'
				case DEV->S = 'E'
				_cStatus := 'Encerrado'
				case DEV->S = 'N'
				_cStatus := 'Em Análise' 
				case DEV->S = 'G'
				_cStatus := 'Aguardando Visto Dir.'
				case DEV->S = 'D'
				_cStatus := 'Vistado Diretor'
			endcase 

			do case
				case DEV->DESTINO = 'E'
				_cDestino := 'Estoque'
				case DEV->DESTINO = 'R'
				_cDestino := 'Reprocesso'
				case DEV->DESTINO = 'G'
				_cDestino := 'Graxaria' 
				case DEV->DESTINO = 'C'
				_cDestino := 'Charque'
			endcase 

			@nlin,001 psay DEV->NUM 
			@nlin,010 psay substr(DEV->NOME,1,35) 
			//	@nlin,050 psay 'Dt. Dev:'
			@nlin,050 psay STOD(DEV->ENTRADA)
			nLin++
			@nlin,001 psay 'NF :'+DEV->NF+' '+DEV->SERIE 
			@nlin,022 psay 'Destino:'+_cDestino
			@nlin,052 psay 'Status :'+_cStatus 

			nLin++

			@nlin,00 psay replicate('-',70)
			_cNdev := DEV->NUM                
			nLin++ 
		endif 

		If nLin > _nTam // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		_nQuant := 0
		_nPeso  := 0
		_nTotal := 0 



		While DEV->NUM = _cNdev 
			If nLin > _nTam // Salto de Página. Neste caso o formulario tem 60 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif 

			@nlin,010 psay DEV->COD
			@nlin,018 psay substr(DEV->PRODUTO,1,18) 
			@nlin,039 psay DEV->QUANT 
			@nlin,043 psay transform(DEV->PESO,'@E 9,999.99')
			@nlin,054 psay 'R$'
			@nlin,060 psay transform(DEV->TOTAL,'@E 999,999,999.99')
			// Totalizador
			_nQuant+= DEV->QUANT
			_nPeso += DEV->PESO
			_nTotal += DEV->TOTAL

			nLin++ 

			if  DEV->NUM <> _cNdev 
				_cNdev := DEV->NUM
			endif

			DEV->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		ENDDO 
		If nLin > _nTam // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		@nlin,00 psay replicate('-',70)
		nLin++	
		@nlin,020 psay 'Totais :'
		@nlin,039 psay _nQuant 
		@nlin,043 psay transform(_nPeso,'@E 9,999.99')
		@nlin,054 psay 'R$'
		@nlin,060 psay transform(_nTotal,'@E 999,999,999.99')
		_nQuant 	:=0
		_nPeso 	:=0
		_nTotal 	:=0

		nLin++ 
		@nlin,00 psay replicate('=',60)
		nLin++


		DEV->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo

	DbCloseArea('DEV')

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
