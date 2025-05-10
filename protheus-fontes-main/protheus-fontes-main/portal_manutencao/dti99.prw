#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI99     º Autor ³ Fabian Maurer    º Data ³  31/03/2020   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório do histórico Portal Manutenção                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI99()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3       	:= "Historico do Portal da Manutenção"
	//Local cPict        	:= ""
	Local titulo       	:= "Historico do Portal da Manutencao"
	Local nLin         	:= 80
	Local Cabec1       	:= "   Usuario          Prazo       Tipo      Maquina      Maq. Parada      CC      Mau Uso      Nov Mau Uso"
	Local Cabec2       	:= "      Preventiva      Corretiva      Melhoria      Retrabalho      Dt Inicio      Dt Fim      Manutentor"
	//Local imprime      	:= .T.
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "DTI99" // Coloque aqui o nome do programa para impressao no cabecalho
	Private cPerg       := "DTI99"
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	//Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI99" // Coloque aqui o nome do arquivo usado para impressao em disco
	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint('ZP2',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cQuery := "SELECT *"
	_cQuery += " FROM  " + retSqlTab('ZP2')
	_cQuery += " WHERE " + retSqlFil('ZP2')
	_cQuery += " AND ZP2_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"

	if !empty(mv_par03) .and. !empty(mv_par04)
		_cQuery += " AND ZP2_CC BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	endif

	_cQuery += " AND ZP2_PRAZO BETWEEN '" + dtos(mv_par05) + "' AND '" + dtos(mv_par06) + "'"

	if !empty(mv_par07)
		If mv_par07 = 1
			_cQuery += " AND SUBSTRING(ZP2_STATUS,1,30) = '1 - Aberto (Solicitante)'"
		ElseIf mv_par07 = 2
			_cQuery += " AND SUBSTRING(ZP2_STATUS,1,30) = '2 - Sob analise (Manutencao)'"
		ElseIf mv_par07 = 3
			_cQuery += " AND SUBSTRING(ZP2_STATUS,1,30) = '3 - Iniciado (Manutencao)'"
		ElseIf mv_par07 = 4
			_cQuery += " AND SUBSTRING(ZP2_STATUS,1,30) = '4 - Finalizado (Manutencao)'"
		ElseIf mv_par07 = 5
			_cQuery += " AND SUBSTRING(ZP2_STATUS,1,30) = '5 - Finalizado (Solicitante)'"
		EndIf
	endif

	if mv_par08 <> 3
		_cQuery += " AND ZP2_MAUUSO = '" + Iif(mv_par08 = 1, 'S','N') + "'"    
	endif

	if mv_par09 <> 3
		_cQuery += " AND ZP2_PREVEN = '" + Iif(mv_par09 = 1, 'S','N') + "'"    
	endif

	if mv_par10 <> 3
		_cQuery += " AND ZP2_CORRET = '" + Iif(mv_par10 = 1, 'S','N') + "'"    
	endif

	if mv_par11 <> 3
		_cQuery += " AND ZP2_MELHOR = '" + Iif(mv_par11 = 1, 'S','N') + "'"    
	endif

	if mv_par12 < 3
		_cQuery += " AND ZP2_MAQPAR = '" + Iif(mv_par12 = 1, 'S','N') + "'"    
	endif

	if !empty(mv_par13) .and. !empty(mv_par14)
		_cQuery += " AND ZP2_DTFIN BETWEEN '" + dtos(mv_par13) + "' AND '" + dtos(mv_par14) + "'"
	endif

	_cQuery += " AND " + retSqlDel('ZP2')
	_cQuery += " ORDER BY ZP2_CODIGO"

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZP2')

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
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  28/03/17   º±±
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

	//Local nOrdem
	Local _nMauS := 0
	Local _nMauN := 0
	Local _nMunS := 0
	Local _nMunN := 0
	Local _nPreS := 0
	Local _nPreN := 0
	Local _nCorS := 0
	Local _nCorN := 0
	Local _nMelS := 0
	Local _nMelN := 0
	Local _nRetS := 0
	Local _nRetN := 0
	Local _nMqpS := 0
	Local _nMqpN := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetRegua(RecCount())

	_cCod := ''
	TMP->(dbGoTop())

	While TMP->(!EOF())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 70 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		@nlin,01 psay replicate('-',132)
		nlin++
		@nLin,01 PSAY 'Cod. Solicitacao: ' + TMP->ZP2_CODIGO
		nLin++
		nLin++                       
		_cCod := TMP->ZP2_CODIGO

		@nlin,00 psay TMP->ZP2_USER
		@nlin,20 psay dtoc(stod(TMP->ZP2_PRAZO))
		@nlin,34 psay TMP->ZP2_TIPO
		@nlin,44 psay TMP->ZP2_MAQ
		@nlin,60 psay TMP->ZP2_MAQPAR
		@nlin,71 psay TMP->ZP2_CC
		@nlin,84 psay TMP->ZP2_MAUUSO
		@nlin,99 psay TMP->ZP2_NMAUUS
		nLin++
		@nlin,11 psay TMP->ZP2_PREVEN
		@nlin,26 psay TMP->ZP2_CORRET
		@nlin,40 psay TMP->ZP2_MELHOR
		@nlin,56 psay TMP->ZP2_QUALID
		@nlin,68 psay dtoc(stod(TMP->ZP2_DTINI))
		@nlin,82 psay dtoc(stod(TMP->ZP2_DTFIN))
		@nlin,97 psay TMP->ZP2_MANUTE
		//@nlin,65 psay substr(TMP->ZZC_EVENTO,1,25)
		if !empty(TMP->ZP2_DESC)
			nlin++
			@nlin,04 psay 'Descricao: ' + TMP->ZP2_DESC
		endif

		nlin++	

		If TMP->ZP2_MAUUSO = 'S'
			_nMauS++
		EndIf

		If TMP->ZP2_MAUUSO = 'N'  
			_nMauN++
		EndIf

		If TMP->ZP2_NMAUUS = 'S'  
			_nMunS++
		EndIf

		If TMP->ZP2_NMAUUS = 'N'  
			_nMunN++
		EndIf

		If TMP->ZP2_PREVEN = 'S'  
			_nPreS++
		EndIf

		If TMP->ZP2_PREVEN = 'N'  
			_nPreN++
		EndIf

		If TMP->ZP2_CORRET = 'S'  
			_nCorS++
		EndIf	

		If TMP->ZP2_CORRET = 'N'  
			_nCorN++
		EndIf	

		If TMP->ZP2_MELHOR = 'S'  
			_nMelS++
		EndIf	

		If TMP->ZP2_MELHOR = 'N'  
			_nMelN++
		EndIf	

		If TMP->ZP2_QUALID = 'S'  
			_nRetS++
		EndIf

		If TMP->ZP2_QUALID = 'N'  
			_nRetN++
		EndIf

		If TMP->ZP2_MAQPAR = 'S'  
			_nMqpS++
		EndIf	

		If TMP->ZP2_MAQPAR = 'N'  
			_nMqpN++
		EndIf 

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	EndDo

	nlin++ 
	nlin++
	@nlin,00 psay replicate('*',110) 
	nlin++ 
	@nlin,00 psay replicate('*',110) 
	nlin++
	nlin++  
	@nlin,01 psay 'TOTAIS: '
	nlin++

	_nTotMauS := _nMauS + _nMunS
	_nTotMauN := _nMauN + _nMunN

	@nlin,01 psay 'Total Mau Uso "Sim": '	
	@nlin,30 psay transform(_nTotMauS,'@E 9999')
	nlin++
	@nlin,01 psay 'Total Mau Uso "Nao": '
	@nlin,30 psay transform(_nTotMauN,'@E 9999')
	nlin++
	@nlin,01 psay 'Total Preventiva "Sim": '
	@nlin,30 psay transform(_nPreS,'@E 9999')
	nlin++
	@nlin,01 psay 'Total Preventiva "Nao": '
	@nlin,30 psay transform(_nPreN,'@E 9999')
	nlin++
	@nlin,01 psay 'Total Corretiva "Sim": '
	@nlin,30 psay transform(_nCorS,'@E 9999')
	nlin++
	@nlin,01 psay 'Total Corretiva "Nao": '
	@nlin,30 psay transform(_nCorN,'@E 9999')
	nlin++
	@nlin,01 psay 'Total Melhoria "Sim": '
	@nlin,30 psay transform(_nMelS,'@E 9999')
	nlin++
	@nlin,01 psay 'Total Melhoria "Nao": '
	@nlin,30 psay transform(_nMelN,'@E 9999')
	nlin++
	@nlin,01 psay 'Total Retrabalho "Sim": '
	@nlin,30 psay transform(_nRetS,'@E 9999')
	nlin++
	@nlin,01 psay 'Total Retrabalho "Nao": '
	@nlin,30 psay transform(_nRetN,'@E 9999')
	nlin++
	@nlin,01 psay 'Total Maq. Parada "Sim": '
	@nlin,30 psay transform(_nMqpS,'@E 9999')
	nlin++
	@nlin,01 psay 'Total Maq. Parada "Nao": '
	@nlin,30 psay transform(_nMqpN,'@E 9999')

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


Static Function GeraTMP()

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return
