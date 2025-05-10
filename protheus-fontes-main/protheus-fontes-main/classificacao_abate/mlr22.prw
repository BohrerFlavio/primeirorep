#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR22    º Autor ³ Mauricio Roehrs º Data ³ 11/09/2013      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ R6 - Relatorio de analise da produção da desossa	          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle de Produção                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR22()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia da produção da desossa"
	Local cDesc3         := ""
	//Local cPict          := ""
	Local titulo         := "R6 - RELATORIO PARA ANALISE DE PROD. DESOSSA"
	Local Cabec1         := ""
	Local Cabec2         := ""
	//Local imprime         := .T.
	Local aOrd            := {}
	Private nLin           := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "MLR22" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg   	  := "MLR22"
	//Private cbtxt      	  := Space(10)
	Private cbcont        := 00
	Private CONTFL        := 01
	Private m_pag         := 01
	Private wnrel         := "MLR22" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aSubTot      := {}

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZAJ',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	if mv_par17 = 1
		Cabec1 += "       HORA     SEQ. ABATE  LOTE     NUM. PEÇA        CORTE         DENT.      PESO       RAÇA        PROGRAMA       CLASSIF. DEST."
	else
		Cabec1 += "                 HORA   SEQ. ABATE     NUM. PEÇA       CORTE         DENT.      PESO       RAÇA       PROGRAMA       CLASSIF. DEST."
	endif

	_cQuery := "SELECT ZAJ_NUMAM AS NUMAM, ZAJ_CORORI AS CORORI,ZAJ_NUM AS NUM,ZAJ_PESO AS PESO,ZAJ_CONTRO AS CONTROL, ZAJ_PREDES AS PREDES, ZK_DESTINO AS DESTINO, ZK_RACA AS RACA,"
	_cQuery += " ZAJ_HORAS AS HRPROD, ZAJ_DATAS AS DTPROD, ZK_PROGRAM AS PROGRAM, ZK_CLASSIF AS CLASSIF, ZK_DENT AS DENT, ZK_CLASESP AS CLASESP, ZK_LOTE AS LOTE, ZK_BLACK AS BLACK"
	_cQuery += " FROM  " + RetSQLTab('ZAJ') + "  ,  " + RetSQLTab('SZK')
	_cQuery += " WHERE " + RetSQLFil('ZAJ') + " AND " + RetSQLFil('SZK')
	_cQuery += " AND ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL = ZAJ_CONTRO"
	_cQuery += " AND ZAJ_HORAS <> '' AND ZAJ_DATAS <> '' AND ZAJ_PREPED = ''"
	_cQuery += " AND ZAJ_PRECAR = '' AND ZAJ_ITEM = ''"
	_cQuery += " AND (ZAJ_DATAS BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + 	"')"
	_cQuery += " AND (ZAJ_HORAS BETWEEN '" +    mv_par03    + "' AND '" +     mv_par04   + 	"')"
	_cQuery += " AND (ZK_DENT   BETWEEN '" +    mv_par05    + "' AND '" +     mv_par06   + 	"')"

	if !empty(mv_par07)
		_cQuery += " AND ZK_CLASSIF = '" + mv_par07 + "'"
	endif

	if !empty(mv_par08)
		_cQuery += " AND ZK_PROGRAM = '" + mv_par08 + "'"
	endif

	if !empty(mv_par11)
		_cQuery += " AND ZK_RACA = '" + mv_par11 + "'"
	endif 

	if !empty(mv_par14)
		_cQuery += " AND ZK_NUMAM = '" + mv_par14 + "'"
	endif

	if mv_par09 <> 4
		_cQuery += " AND ZAJ_CORORI = '" + iif(mv_par09 = 1,'D',iif(mv_par09 = 2, 'T','C')) + "'"
	endif

	if mv_par12 = 1
		_cQuery += " AND ZK_CLASSIF <> 'NE '"// AND ZK_CLASESP = '1'"
	endif

	if mv_par15 = 1 //se finalidade for desossa
		_cQuery += " AND ZAJ_DEST = 'D'"
	elseif mv_par15 = 2	//se finalidade for costela
		_cQuery += " AND ZAJ_DEST = 'C'"
	elseif mv_par15 = 3 //se finalidade for carregamento
		_cQuery += " AND ZAJ_DEST = 'R'"
	endif

	if mv_par16 = 2 //se destino for TF
		_cQuery += " AND ZK_DESTINO = 'T'"
	elseif mv_par16 = 3 //se destino for Conserva
		_cQuery += " AND ZK_DESTINO = 'R'"
	elseif mv_par16 = 4 //se destino for Câmaras
		_cQuery += " AND ZK_DESTINO = 'C'"
	elseif mv_par16 = 5 //se destino for TS
		_cQuery += " AND ZK_DESTINO = 'S'"
	endif

	_cQuery += " AND " + RetSQLDel('ZAJ') + " AND " + RetSQLDel('SZK')

	_cQuery += " GROUP BY ZAJ_DATAS,ZAJ_NUMAM,ZAJ_CONTRO,ZAJ_CORORI,ZAJ_HORAS,ZAJ_COD,ZAJ_DESCRI,ZAJ_NUM,ZK_PROGRAM,ZK_RACA,ZK_CLASSIF, ZK_DENT,ZAJ_PESO,ZK_CLASESP,ZAJ_PREDES,ZK_DESTINO,ZK_LOTE,ZK_BLACK" 

	if mv_par10 = 1   //ordenar por data e horario
		if mv_par18 = 1 //Se quebra por aviso de matança
			_cQuery += " ORDER BY ZAJ_DATAS,ZAJ_HORAS,ZAJ_NUMAM,ZAJ_NUM"
		else
			_cQuery += " ORDER BY ZAJ_DATAS,ZAJ_HORAS,ZAJ_NUM"
		endif
	elseif mv_par10 = 2 //Ordenar por data e programa
		if mv_par18 = 1  //Se quebra por aviso de matança
			_cQuery += " ORDER BY ZAJ_DATAS,ZAJ_NUMAM,ZK_PROGRAM,ZAJ_HORAS,ZAJ_NUM"
		else
			_cQuery += " ORDER BY ZAJ_DATAS,ZK_PROGRAM,ZAJ_HORAS,ZAJ_NUM"
		endif
	elseif mv_par10 = 3 //Ordenar por data e classificação
		if mv_par18 = 1  //Se quebra por aviso de matança
			_cQuery += " ORDER BY ZAJ_DATAS,ZAJ_NUMAM,ZK_CLASSIF,ZAJ_HORAS,ZAJ_NUM"
		else
			_cQuery += " ORDER BY ZAJ_DATAS,ZK_CLASSIF,ZAJ_HORAS,ZAJ_NUM"
		endif
	endif

	_cQuery  := ChangeQuery(_cQuery)
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAJ')

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

	Local i := 0

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	_aRNumam := {} //Informações resumidas por aviso de matança

	_cNumam 	:= ''
	_cData  	:= ''
	_cRaca  	:= ''

	_nAPosCla := 0
	_nAPosCor := 0
	_nQtdPecDia := 0
	_nQtdPesDia := 0
	_nTpecAbD := 0 //Total de Dianteiros do Abate
	_nTpesAbD := 0 //Total de Peso dos Dianteiros
	_nTpecAbT := 0 //Total de Traseiros do Abate
	_nTpesAbT := 0 //Total de Peso dos Traseiros
	_nTpecAbC  := 0 //Total de Costela do Abate
	_nTpesAbC  := 0 //Total de Peso dos Costela
	_nTpecDiaD := 0 //Total de Dianteiros do Dia
	_nTpesDiaD := 0 //Total de Peso dos Dianteiros
	_nTpecDiaT := 0 //Total de Traseiros do Dia
	_nTpesDiaT := 0 //Total de Peso dos Traseiros
	_nTpecDiaC  := 0 //Total de Costela do Dia
	_nTpesDiaC  := 0 //Total de Peso dos Costela
	_nQtdUSA  := 0	 //Quantidade de Animais USA
	_nQtdHK   := 0	 //Quantidade de Animais HK
	_nQtdNE   := 0   //Quantidade de Animais NE
	_nQtdBR   := 0   //Quantidade de Animais BR
	_nQtdRT   := 0   //Quantidade de Animais RT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	While TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if TMP->BLACK = 'S'
			_cProgram := alltrim(GetAdvFVal('SZ6','Z6_DESC',FWxFilial('SZ6') + TMP->PROGRAM,1))
			_cProgram := "BL-" + _cProgram
		else
			_cProgram := alltrim(GetAdvFVal('SZ6','Z6_DESC',FWxFilial('SZ6') + TMP->PROGRAM,1))
		endif

		if _cData <> TMP->DTPROD	
			@nlin,001 psay "Data da Desossa: "
			@nlin,020 psay stod(TMP->DTPROD)
			nlin++
			@nlin,001 psay replicate('-',132)
			nlin++
			_cData := TMP->DTPROD
			_nQtdPecDia++
			_nQtdPesDia += TMP->PESO
		endif

		if mv_par18 = 1  //Se quebrar por aviso de matança
			if _cNumam <> TMP->NUMAM
				@nlin,001 psay replicate('-',132)
				nlin++
				@nlin,001 psay "Aviso de Matança: " + TMP->NUMAM + " - Data de abate : " + dtoc(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+TMP->NUMAM,1))
				nlin++
				@nlin,001 psay replicate('-',132)
				nlin++
				_cNumam := TMP->NUMAM
			endif
		endif

		if mv_par13 = 1 //.AND.  AllTrim(TMP->CLASSIF) = 'HK' .and. TMP->CLASESP = '1'
			_cRaca := substr(GetAdvFVal('ZA8','ZA8_DESC',FWxFilial('ZA8') + TMP->RACA,1,space(8),.T.),1,8)
			//@nlin,002 psay TMP->PREDES
			//@nlin,015 psay " | "
			if mv_par17 = 1
				@nlin,005 psay TMP->HRPROD
				@nlin,013 psay " | " 
				@nlin,017 psay TMP->CONTROL
				@nlin,026 psay " | "
				@nlin,029 psay substr(TMP->LOTE, 5, 2)
				@nlin,032 psay " | "
			else
				@nlin,015 psay TMP->HRPROD
				@nlin,022 psay " | "
				@nlin,025 psay TMP->CONTROL
				@nlin,032 psay " | "
			endif
			@nlin,036 psay TMP->NUM
			@nlin,047 psay " | "
			@nlin,053 psay iif(TMP->CORORI = 'D','DIANTEIRO',iif(TMP->CORORI = 'T','TRASEIRO','COSTELA'))
			@nlin,065 psay " | "
			@nlin,070 psay TMP->DENT
			@nlin,073 psay " | "
			@nlin,078 psay transform(TMP->PESO,'@E 999.99')
			@nlin,086 psay " | "
			@nlin,088 psay _cRaca
			@nlin,097 psay " | "
			@nlin,100 psay substr(_cProgram,1,14)//iif(empty(TMP->PROGRAM .or. TMP->PROGRAM = "013"),'-SEM PROGRAMA-',substr(_cProgram,1,13))
			@nlin,116 psay " | "
			@nlin,118 psay TMP->CLASSIF //+ iif(TMP->CLASESP = '1' .and. AllTrim(TMP->CLASSIF) != 'NE', ' -> UY','')
			@nlin,123 psay " | "
			@nlin,125 psay iif(TMP->DESTINO = 'T', 'TF', iif(TMP->DESTINO = 'R', 'CO', iif(TMP->DESTINO = 'C', 'CA', 'GR')))
			nlin++
		endif

		//Totaliza por Aviso de Matança
		if mv_par18 = 1
			nPos := Ascan(_aRNumam, {|x| x[1] = TMP->NUMAM})
			if nPos = 0
				do case
					case AllTrim(TMP->CLASSIF) = 'USA'
					_nQtdUSA++
					case AllTrim(TMP->CLASSIF) = 'HK'
					_nQtdHK++
					case AllTrim(TMP->CLASSIF) = 'NE'
					_nQtdNE++
					case AllTrim(TMP->CLASSIF) = 'BR'
					_nQtdBR++
					case AllTrim(TMP->CLASSIF) = 'RT'
					_nQtdRT++
				endcase
				Do Case
					Case (TMP->CORORI = 'D')
					_nTpecAbD++ 				//Total de Dianteiros do Abate
					_nTpesAbD += TMP->PESO  	//Total de Peso dos Dianteiros
					Case (TMP->CORORI = 'T')
					_nTpecAbT++ 				//Total de Traseiros do Abate
					_nTpesAbT += TMP->PESO 		//Total de Peso dos Traseiros
					Case (TMP->CORORI = 'C')
					_nTpecAbC++ 				//Total de Costela do Abate
					_nTpesAbC += TMP->PESO 		//Total de Peso dos Costela
				Endcase
				aadd(_aRNumam, {TMP->NUMAM, 1, _nQtdUSA, _nQtdHK, _nQtdNE, _nQtdBR, _nTpecAbD, _nTpesAbD, _nTpecAbT, _nTpesAbT, _nTpecAbC, _nTpesAbC,_nQtdRT})
			else
				do case
					case AllTrim(TMP->CLASSIF) = 'RT'
					_nAPosCla := 2
					case AllTrim(TMP->CLASSIF) = 'USA'
					_nAPosCla := 3
					case AllTrim(TMP->CLASSIF) = 'HK'
					_nAPosCla := 4
					case AllTrim(TMP->CLASSIF) = 'NE'
					_nAPosCla := 5
					case AllTrim(TMP->CLASSIF) = 'BR'
					_nAPosCla := 6

				endcase
				Do Case
					Case (TMP->CORORI = 'D')
					_nAPosCor := 7
					Case (TMP->CORORI = 'T')
					_nAPosCor := 9
					Case (TMP->CORORI = 'C')
					_nAPosCor := 11
				Endcase
				_aRNumam[nPos,2]++
				_aRNumam[nPos,_nAPosCla]++
				_aRNumam[nPos,_nAPosCor]++
				_aRNumam[nPos,(_nAPosCor+1)] += TMP->PESO
			endif
			_nTpecAbD := 0 //Total de Dianteiros do Abate
			_nTpesAbD := 0 //Total de Peso dos Dianteiros
			_nTpecAbT := 0 //Total de Traseiros do Abate
			_nTpesAbT := 0 //Total de Peso dos Traseiros
			_nTpecAbC := 0 //Total de Costela do Abate
			_nTpesAbC := 0 //Total de Peso dos Costela
			_nQtdUSA  := 0 //Quantidade de Animais USA
			_nQtdHK   := 0 //Quantidade de Animais HK
			_nQtdNE   := 0 //Quantidade de Animais NE
			_nQtdBR   := 0 //Quantidade de Animais BR
			_nQtdRT   := 0 //Quantidade de Animais RT
		endif

		Do Case
			Case (TMP->CORORI = 'D')
			_nTpecDiaD++ 					//Total de Dianteiros do Dia
			_nTpesDiaD += TMP->PESO  	//Total de Peso dos Dianteiros
			Case (TMP->CORORI = 'T')
			_nTpecDiaT++ 					//Total de Traseiros do Dia
			_nTpesDiaT += TMP->PESO 	//Total de Peso dos Traseiros
			Case (TMP->CORORI = 'C')
			_nTpecDiaC++ 					//Total de Costela do Dia
			_nTpesDiaC += TMP->PESO 	//Total de Peso dos Costela
		Endcase

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		//Totalizador referenciado nos dias postos nos parametros
		if _cData <> TMP->DTPROD .or. TMP->(eof())

			If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif 

			nlin++
			@nlin,50 psay "P E Ç A S"  
			@nlin,72 psay "P E S O"
			nlin++
			@nlin,05 psay "Total de Dianteiros Produzidos no Dia --->
			@nlin,50 psay transform(_nTpecDiaD,'@E 9999')
			@nlin,70 psay transform(_nTpesDiaD,'@E 999,999.99')
			nlin++

			@nlin,05 psay "Total de Traseiros Produzidos no Dia  --->
			@nlin,50 psay transform(_nTpecDiaT,'@E 9999')
			@nlin,70 psay transform(_nTpesDiaT,'@E 999,999.99')
			nlin++

			@nlin,05 psay "Total de Costelas Produzidos  no Dia  --->
			@nlin,50 psay transform(_nTpecDiaC,'@E 9999')
			@nlin,70 psay transform(_nTpesDiaC,'@E 999,999.99')
			nlin++

			_nTpecDiaD := 0 //Total de Dianteiros do Dia
			_nTpesDiaD := 0 //Total de Peso dos Dianteiros

			_nTpecDiaT := 0 //Total de Traseiros do Dia
			_nTpesDiaT := 0 //Total de Peso dos Traseiros

			_nTpecDiaC := 0 //Total de Costela do Dia
			_nTpesDiaC := 0 //Total de Peso dos Costela

		endif

	EndDo

	//Totaliza por Aviso de Matança
	if mv_par18 = 1
		for i := 1 to len(_aRNumam)
			If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			nlin++
			@nlin,001 psay replicate('=',132)
			nlin++
			@nlin,005 psay "Aviso de Matança: " + _aRNumam[i,1] + " - Data de abate : " + dtoc(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+_aRNumam[i,1],1))
			nlin++
			@nlin,50 psay "P E Ç A S"  
			@nlin,72 psay "P E S O"
			nlin++
			@nlin,05 psay "Total de Dianteiros Produzidos --->
			@nlin,50 psay transform(_aRNumam[i,7],'@E 9999')
			@nlin,70 psay transform(_aRNumam[i,8],'@E 99,999.99')
			nlin++

			@nlin,05 psay "Total de Traseiros Produzidos  --->
			@nlin,50 psay transform(_aRNumam[i,9],'@E 9999')
			@nlin,70 psay transform(_aRNumam[i,10],'@E 99,999.99')
			nlin++

			@nlin,05 psay "Total de Costelas Produzidos   --->
			@nlin,50 psay transform(_aRNumam[i,11],'@E 9999')
			@nlin,70 psay transform(_aRNumam[i,12],'@E 99,999.99')
			nlin++

			@nlin,05 psay 'Nr.Peças no Aviso: ' + transform(_aRNumam[i,2],'@E 9999')
			nlin++
			@nlin,05 psay 'Nr.Peças RT:      ' + transform(_aRNumam[i,13],'@E 9999')
			nlin++
			@nlin,05 psay 'Nr.Peças USA:      ' + transform(_aRNumam[i,3],'@E 9999')
			nlin++
			@nlin,05 psay 'Nr.Peças HK:       ' + transform(_aRNumam[i,4],'@E 9999')
			nlin++
			@nlin,05 psay 'Nr.Peças NE:       ' + transform(_aRNumam[i,5],'@E 9999')
			nlin++
			@nlin,05 psay 'Nr.Peças BR:       ' + transform(_aRNumam[i,6],'@E 9999')
			nlin++
			@nlin,001 psay replicate('=',132)
			nlin++

		next
	endif

	If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

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
