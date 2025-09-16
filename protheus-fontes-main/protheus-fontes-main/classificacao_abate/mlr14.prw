#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR14  º Autor ³ Mauricio Roehrs  º Data ³    07/05/13      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de produções especiais do Abate                  º±±
±±º          ³ Com destino aos certificadores                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR14()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2        := "de produção analitico do abate, mediante parametros  "
	Local cDesc3        := "apontados pelo usuário"
	//Local cPict          := ""
	Local titulo       	:= "ANALISE DE PRODUCAO DO ABATE(MOD.2)"
	Local nLin         	:= 80
	Local Cabec1        := " Aviso de Matança e Lote "
	Local Cabec2        := "                Sequencial     Peso      Gord.  Dent.   Raça      Destino     Hora     Classif.  IF?      Programa"
	//Local imprime        := .T.
	Local aOrd          := {}
	Local _dDtAbt1		:= stod('')
	Local _dDtAbt2		:= stod('')
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "MLR14" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "MLR14"
	//Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "MLR14" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _aClassif   := {}

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZK',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_dDtAbt1 := dtos(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+mv_par01,1))
	_dDtAbt2 := dtos(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+mv_par02,1))

	_cQuery := "SELECT ZK_NUMAM AS NUMAM, ZK_LOTE AS LOTE, ZK_CONTROL AS CONTROL, ZK_PETOTAL AS PETOTAL,"
	_cQuery += " ZK_HORA AS HORA, ZK_COBGOR AS COBGOR, ZK_DENT AS DENT, ZK_DESTINO AS DESTINO, ZK_RACA AS RACA,"
	_cQuery += " ZK_CLASABA AS CLASSIF, ZK_IF AS DIF, ZK_PROGPGP AS PROGRAM, Z4_NOME AS NOME"
	_cQuery += " FROM " + RetSqlTab('SZK')
	_cQuery += " INNER JOIN " + RetSqlTab('SZ4') + " ON (Z4_NUMAM = ZK_NUMAM AND Z4_LOTE = ZK_LOTE)"
	_cQuery += " WHERE " + RetSQLFil('SZK') + " AND " + RetSQLFil('SZ4')
	//_cQuery += " Z4_COMPRA <> '' AND" //linha removida a pedido do Diogo Soccal;
	_cQuery += " AND ZK_DATAABT BETWEEN '" + _dDtAbt1 + "' AND '" + _dDtAbt2 + "'"
	_cQuery += " AND ZK_LOTE BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	if !empty(mv_par05)
		_cQuery += " AND ZK_RACA = '" + mv_par05 + "'" 
	endif
	if !empty(mv_par06)
		if mv_par06 $ "006/021"
			_cQuery += " AND ZK_PROGPGP IN ('006','021')"
		elseif mv_par06 $ "002/022"
			_cQuery += " AND ZK_PROGPGP IN ('002','022')"
		else
			_cQuery += " AND ZK_PROGPGP = '" + mv_par06 + "'"
		endif
	endif
	Do Case
		case mv_par07 = 2
			_cQuery += " AND ZK_DESTINO = 'C'"
		case mv_par07 = 3
			_cQuery += " AND ZK_DESTINO = 'T'"
		case mv_par07 = 4
			_cQuery += " AND ZK_DESTINO = 'R'"
		case mv_par07 = 5
			_cQuery += " AND ZK_DESTINO = 'G'"
	EndCase 
	_cQuery += " AND " + RetSQLDel('SZK') + " AND " + RetSQLDel('SZ4')
	_cQuery += " ORDER BY ZK_NUMAM, ZK_LOTE, ZK_CONTROL"

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("ABT") != 0
		ABT->(dbCloseArea())
	Endif            

	TCQUERY _cQuery NEW ALIAS "ABT"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZK')

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

	Local i
	//Local nOrdem  
	Local _cNumam := ''
	Local _cLote  := ''
	//Local _cConf  := ''
	Local _cDest  := ''  
	Local _cRaca  := '' 
	Local _nPesoL := 0.00
	Local _nQuant := 0.00 
	Local _nPesoP := 0.00 
	//Local _nPesoP2 := 0.00 
	Local _nPesoDesc := 0.00 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	ABT->(dbGoTop())
	ABT->(SetRegua(RecCount()))

	While ABT->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 75 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif                                                                    

		_dtAbt 		:= dtoc(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+ABT->NUMAM,1))
		_cRaca  	:= GetAdvFVal('ZA8','ZA8_DESC',FWxfilial('ZA8')+ABT->RACA,1)
		_cPrograma  := GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6')+ABT->PROGRAM,1)	   
		//_nPesoP2   := ABT->PETOTAL * 0.98 
		_nPesoP  	:= ABT->PETOTAL

		/*if ABT->DIF = 'S'
			if _nPesoP2 > 200 
				_nPesoP2 := _nPesoP2 - 10
			elseif _nPesoP2 <=200
				_nPesoP2 := _nPesoP2 - 7.5
			endif    
		endif*/

		_nPesoDesc  := 0.0
		//_nPesoP 	:= _nPesoP2

		_nPos := aScan(_aClassif,{|aVal|aVal[1] = ABT->CLASSIF})

		if _nPos <> 0
			_aClassif[_npos,2]++
			_aClassif[_npos,3]+= (_nPesoP - _nPesoDesc)
		else
			aadd(_aClassif,{ABT->CLASSIF,1,_nPesoP})
		endif 

		if _cNumam <> ABT->NUMAM
			@nlin,01 psay ABT->NUMAM + '   Abate do dia:  ' + _dtAbt
			_cNumam := ABT->NUMAM
			nlin++
		endif 

		if _cLote <> ABT->LOTE 
			@nlin,00 psay replicate('-',132)
			nlin++
			@nlin,01 psay 'Lote nr.: ' + ABT->LOTE 
			@nlin,18 psay '- ' + substr(ABT->NOME,1,30)
			_cLote := ABT->LOTE
			nlin++
		endif

		Do Case
			case ABT->DESTINO = 'C'
			_cDest := 'Camara'
			case ABT->DESTINO = 'R'
			_cDest := 'Conserva'
			case ABT->DESTINO = 'G'
			_cDest := 'Graxaria'
			case ABT->DESTINO = 'T'
			_cDest := 'TF'
			case ABT->DESTINO = 'I'
			_cDest := 'IF'
		EndCase 

		@nlin,017 psay ABT->CONTROL
		@nlin,030 psay transform(_nPesoP - _nPesoDesc,'@E 999.99')
		@nlin,042 psay ABT->COBGOR
		@nlin,049 psay ABT->DENT
		@nlin,054 psay substr(_cRaca,1,10)
		@nlin,066 psay _cDest
		@nlin,078 psay ABT->HORA
		@nlin,089 psay ABT->CLASSIF
		@nlin,097 psay iif(ABT->DIF = 'S','Sim','Nao')
		@nlin,106 psay _cPrograma  

		nlin++ 

		_nPesoL += (_nPesoP - _nPesoDesc)
		_nQuant ++  

		ABT->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

		if(_cLote <> ABT->LOTE) .or. ABT->(eof())
			nlin++
			@nlin,01 psay "Quant. Animais do Lote: "
			@nlin,26 psay _nQuant
			nlin++
			@nlin,01 psay "Peso Total do Lote: "
			@nlin,24 psay transform(_nPesoL,'@E 999,999.99')
			nlin++
			_nQuant := 0  
			_nPesoL := 0
		endif

	EndDo    

	_nTotAni := 0
	_nTotPes := 0
	If nLin > 70 // Salto de Página. Neste caso o formulario tem 75 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif   

	nlin++
	@nlin,00 psay replicate('-',132)
	nlin++ 

	for i := 1 to len(_aClassif)
		@nlin,01 psay alltrim(_aClassif[i,1])
		@nlin,04 psay transform(_aClassif[i,2],'@E 999')
		nlin++
		_nTotPes +=   _aClassif[i,3]
		_nTotAni +=   _aClassif[i,2]
	next

	nlin++
	@nlin,01 psay alltrim("Peso total dos Animais abatidos: ")
	@nlin,33 psay transform(_nTotPes,'@E 999,999,999.99')
	nlin++
	@nlin,01 psay "Total de Animais Abatidos: " 
	@nlin,37 psay _nTotAni
	//ÚÄn ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea()

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
