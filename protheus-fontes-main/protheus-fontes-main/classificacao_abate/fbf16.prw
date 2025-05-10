#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF16     ºGiuliano José Forgiarini   º Data ³  30/12/08    º±±
±±º   OBS: Alterado dia 26/02/2010 - por Flávio	 Bohrer					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de carcaças processadas em previsão de produção  º±±
±±º          ³ na entrada da desossa                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Producao (SIGAPCP)                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF16()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio     "
	Local cDesc2         := "de carcaças processadas em uma determinada previsao de "
	Local cDesc3         := "produção para a entrada da desossa                     "
	Local cPict          := ""
	Local titulo       	 := "R6 - QUARTOS PROCESSADOS"
	Local nLin         	 := 80

	Local Cabec1       	 := " 									Dados da Previsão de Produção          "
	Local Cabec2       	 := " Hora   Seq    L  Peça  Cl/Tip Peso   |   "+;
							" Hora  Seq    L  Peça  Cl/Tip Peso      |   "+; 
							"Hora  Seq    L  Peça  Cl/Tip Peso"
	Local imprime      	 := .T.
	Local aOrd := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private Tamanho     := "M"
	Private nomeprog    := "FBF16" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "FBF16"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "FBF16" // Coloque aqui o nome do arquivo usado para impressao em disco

	DbSelectArea('SZN')

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZN',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	// Pesquisa 

	cQuery := " SELECT ZN_PREV AS PREVISAO, ZN_RASTRO AS RASTRO, Z2_DATAABT AS DTABATE,"
	cQuery += "Z2_DESCRI AS TPECA, Z2_CLASSIF AS CLASSIFICACAO,ZN_COD AS COD, ZN_TPTRASE AS VOL,"
	cQuery += "ZN_HORA AS HORA, ZN_LADO AS LADO, ZN_EXPORT AS TIPO,ZN_TIPIFI AS TIPIFIC,"
	CQuery += "ZN_PESOP AS PESOP, Z2_PROGRAM AS PROGRAMA, ZN_DATA AS DTPROD,Z2_NUMAM AS ORDEM "
	cQuery += " FROM " + RetSqlName("SZN") + ", " + RetSqlName("SZ2")
	cQuery += " WHERE SZN010.D_E_L_E_T_ <> '*' 				AND"
	cQuery += "       SZ2010.D_E_L_E_T_ <> '*' 				AND"
	cQuery += "       SZN010.ZN_PREV = SZ2010.Z2_NUM 		AND" 
	cQuery += "       ZN_FILIAL = '" + xFilial("SZN") + "' 	AND "
	cQuery += "       Z2_FILIAL = '" + xFilial("SZ2") + "' 	AND "
	cQuery += "       (ZN_DATA BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "')AND"
	if !empty(mv_par02)
		cQuery += "       (Z2_NUMAM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "')AND"   
	endif
	if empty(mv_par02)
		cQuery += "       Z2_NUMAM = '" + mv_par01 + "' AND "
	endif
	cQuery += "       (ZN_PREV BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "') " 

	if !empty(mv_par07)
		cQuery += " AND      ZN_EXPORT = '" + mv_par07 +"'" 
	endif 
	if !empty(mv_par08)
		cQuery += " AND      ZN_PROGRAM = '" + mv_par08 +"'" 
	endif
	cQuery += " ORDER BY ZN_PREV, ZN_DATA"

	cQuery := ChangeQuery(cQuery)

	If Select("R6") != 0
		R6->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "R6"


	//*******************************
	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZN')

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
	Local _nTotPesoL  := 0
	Local _nTotPeca   := 0
	Local _cCont2     := 0
	Local _nPREV      := ''
	Local _cRastro    := '             '
	Local _nParcPeca  := 0
	Local _lLin 	  := 1
	Local _dDtProd    := ''
	Local _nLinhas	  := 65
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	R6->(dbGoTop())
	R6->(SetRegua(RecCount()))


	//_dDtProd := R6->DTPROD
	While R6->(!EOF())

		incregua()
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > _nLinhas // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		if !empty(mv_par07) 

			if	R6->TIPO <> mv_par07
				R6->(dbskip())
				loop
			endif
		endif    
		// cabeçalho 1 
		if  R6->PREVISAO <> _nPREV  
			_lLin = 1
			if _nParcPeca <> 0 
				nLin++
				@nlin,05 psay 'Quant. Realizada: ' + transform(_nParcPeca, '@E 9,999') 
				nlin++		
			endif 
			if _nPREV <> ''
				nlin ++
				@nlin,15 psay '------------------------------------------------------------------'
				nlin++
			endif
			@nlin,02 psay 'Previsão Nr.: ' + R6->PREVISAO
			nlin++
			@nlin,02 psay 'Ordem de Matança: ' + R6->ORDEM
			nlin++
			@nlin,02 psay 'Data de Abate: ' + DTOC(STOD(R6->DTABATE))
			@nlin,35 psay 'Classificação: ' + R6->CLASSIFICACAO
			@nlin,65 psay 'Programa: ' + iif(!empty(R6->PROGRAMA),fBuscaCPO('SZ6',1,xfilial('SZ6')+R6->PROGRAMA,'Z6_DESC'),'')
			nlin++
			@nlin,02 psay 'Tipo de Peça: ' + R6->TPECA
			nlin++

			_cDataAM := DTOC(STOD(R6->DTABATE))
			_cNUMIF  := _GetParam()
			_cRastro := _cNUMIF + strtran(_cDataAM,'/','') +'0000'
			@nlin,02 psay 'Rastreabilidade: ' + _cRastro
			nLin++


			// Preciso zerar contagem de carcaça parcial 
			_nParcPeca := 0
			_dDtProd	:=''
			_nPREV := R6->PREVISAO
		endif 
		// FIM cabeçalho 1

		if _dDtProd <> R6->DTPROD	

			if _nParcPeca > 0
				nLin ++
				@nlin,02 psay 'Quant. Realizada: ' + transform(_nParcPeca, '@E 9,999')
				_nParcPeca := 0                // contagem das peças
				nLin += 2 
				if nLin > _nLinhas 
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				endif
				@nlin,02 psay 'Data da Produção: ' +  DTOC(STOD(R6->DTPROD))
				_dDtProd := R6->DTPROD
				nlin++
				_lLin = 1
			elseif _nParcPeca = 0
				nLin++
				if nLin > _nLinhas 
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				endif
				@nlin,02 psay 'Data da Produção: ' + DTOC(STOD(R6->DTPROD))
				_dDtProd := R6->DTPROD
				nlin++
			endif 

		endif
		//  cabeçalho 2
		if _lLin = 1
			@nlin,02 psay R6->HORA
			@nlin,08 psay substr(R6->RASTRO,15,6)
			@nlin,15 psay R6->LADO
			if R6->COD = '005020'
				@nlin,18 psay 'Diant.'
			elseif R6->COD = '005016'
				if R6->VOL = 'L'
					@nlin,18 psay 'T.Largo'
				else
					@nlin,18 psay 'T.Estr.'
				endif
			endif
			@nlin,26 psay R6->TIPO
			@nlin,29 psay R6->TIPIFIC
			@nlin,31 psay transform(R6->PESOP,'@E 99.99')
			_lLin := 2
		elseif _lLin = 2     
			@nlin,38 psay '| '
			@nlin,42 psay R6->HORA
			@nlin,50 psay substr(R6->RASTRO,15,6)
			@nlin,57 psay R6->LADO
			if R6->COD = '005020'
				@nlin,60 psay 'Diant.'
			elseif R6->COD = '005016'
				if R6->VOL = 'L'
					@nlin,60 psay 'T.Largo'
				else
					@nlin,60 psay 'T.Estr.'
				endif
			endif
			@nlin,68 psay R6->TIPO
			@nlin,71 psay R6->TIPIFIC
			@nlin,74 psay transform(R6->PESOP,'@E 99.99')	   
			_lLin := 3
		elseif _lLin = 3
			@nlin,82 psay '| '
			@nlin,86 psay R6->HORA
			@nlin,94 psay substr(R6->RASTRO,15,6)
			@nlin,101 psay R6->LADO
			if R6->COD = '005020'
				@nlin,104 psay 'Diant.'
			elseif R6->COD = '005016'
				if R6->VOL = 'L'
					@nlin,104 psay 'T.Largo'
				else
					@nlin,104 psay 'T.Estr.'
				endif
			endif
			@nlin,112 psay R6->TIPO
			@nlin,115 psay R6->TIPIFIC
			@nlin,118 psay transform(R6->PESOP,'@E 99.99')
			_lLin := 1
			nlin++		
		endif

		_nTotPesoL := 	_nTotPesoL + R6->PESOP
		_nParcPeca++
		_nTotPeca++
		//  FIM cabeçalho 2

		R6->(dbSkip()) // Avanca o ponteiro do registro no arquivo 
	enddo 

	if _nParcPeca <> 0
		nLin++
		@nlin,05 psay 'Quant. Realizada: ' + transform(_nParcPeca, '@E 9,999') 
		nlin++		
	endif
	nLin+=2
	@nlin,02 psay "TOTAL DE PEÇAS:     " + transform(_nTotPeca ,'@E 999,999')
	nlin++
	@nlin,02 psay "PESO TOTAL LIQUIDO: " + transform(_nTotPesoL,'@E 999,999.99')



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbCloseArea('R6')
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

Static Function _GetParam()

	_cRet := GetMv("MV_NUMIF")

Return(_cRet)
