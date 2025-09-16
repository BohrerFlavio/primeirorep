#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

User Function PS601FIN()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ PS601FIN ³ Autor ³ Evandro Mugnol        ³ Data ³ Abr/2013 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Relatório Gerencial de Controle de Descontos em Rapel      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Frigorífico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01     // ..........                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString := "SE1"
	cDesc1  := "Este programa tem como objetivo, imprimir o relatorio"
	cDesc2  := "gerencial de controle de descontos em rapel."
	cDesc3  := ""
	tamanho := "G"
	aReturn := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1}
	aLinha  := {}
	nLastKey:= 0
	cPerg   := "PS601FIN"
	titulo  := "Controle Descontos em Rapel"
	wnrel   := "PS601FIN"
	nTipo   := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas no Arquivo SX1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.)

	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif

	RptStatus({|| RptDetail()})

Return

Static Function RptDetail()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa regua de impressao                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(LastRec())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo := IIF(aReturn[4]==1,15,18)
	li    := 80
	m_pag := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1:="PREF   TITULO       PARC  C L I E N T E                                         EMISSAO     VENCIMENTO          VLR TITULO    VLR DESC RAPEL        VLR DESC      VLR DESC RAPEL       VLR LIQUIDO"
	cabec2:="                                                                                                                   NOMINAL      PROVISIONADO      VERBA EXTRA          EFETIVADO                  "
	//***    XXX    XXXXXXXXX    XX    XXXXXX - XX X--------------------------------------X  XX/XX/XXXX  XX/XX/XXXX  XXX.XXX.XXX.XXX,XX    XXX.XXX.XXX,XX   XXX.XXX.XXX,XX  XXX.XXX.XXX,XX
	//***              1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//***    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

	_cQuery := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_VLRAPEL, E1_PVBAEXT, E1_VVBAEXT"
	_cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	_cQuery += " WHERE E1_CLIENTE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR03 + "' AND "
	_cQuery += " E1_LOJA BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "' AND "
	_cQuery += " E1_EMISSAO BETWEEN '" + Dtos(MV_PAR05) + "' AND '" + Dtos(MV_PAR06) + "' AND "
	_cQuery += " E1_VLRAPEL > 0 AND "
	_cQuery += " " + RetSqlCond("SE1")
	_cQuery += " ORDER BY E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA "

	_cQuery := ChangeQuery(_cQuery)

	TCQuery _cQuery new alias Query

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_zCliente  := "########"
	_nTotCli1  := 0
	_nTotCli2  := 0
	_nTotCli3  := 0
	_nTotCli4  := 0
	_nTotGCli1 := 0
	_nTotGCli2 := 0
	_nTotGCli3 := 0
	_nTotGCli4 := 0
	While !Query->(EOF())

		_cCliente := Query->E1_CLIENTE + Query->E1_LOJA
		If _zCliente <> _cCliente
			If _zCliente <> "########"
				@ li, 104 PSAY Replicate("-",69)
				li:=li+1
				@ li, 080 PSAY "TOTAL  DO  CLIENTE      ==> "
				@ li, 105 PSAY _nTotCli1  Picture "@E 999,999,999,999.99"
				@ li, 127 PSAY _nTotCli2  Picture "@E 999,999,999.99"
				@ li, 144 PSAY _nTotCli3  Picture "@E 999,999,999.99"
				@ li, 160 PSAY _nTotCli4  Picture "@E 999,999,999.99"
				li:=li+2
			Endif
			If li>56
				cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
			Endif
			_nTotCli1 := 0
			_nTotCli2 := 0
			_nTotCli3 := 0
			_nTotCli4 := 0
			_zCliente := _cCliente
		Endif

		If li>56
			cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
		Endif

		@ li, 000 PSAY Query->E1_PREFIXO
		@ li, 007 PSAY Query->E1_NUM
		@ li, 020 PSAY Query->E1_PARCELA
		@ li, 026 PSAY Query->E1_CLIENTE + " - " + Query->E1_LOJA
		@ li, 038 PSAY Left(GetAdvFval("SA1", "A1_NOME", FWxFilial("SA1") + Query->E1_CLIENTE + Query->E1_LOJA, 1), 40)
		@ li, 080 PSAY Dtoc(Stod(Query->E1_EMISSAO))
		@ li, 092 PSAY Dtoc(Stod(Query->E1_VENCREA))
		@ li, 103 PSAY Transform(Query->E1_VALOR, "@E 999,999,999,999.99")
		@ li, 125 PSAY Transform(Query->E1_VLRAPEL, "@E 999,999,999.99")
		@ li, 147 PSAY Transform(Query->E1_VVBAEXT, "@E 999,999,999.99")

		// Busca no SE5 baixas com desconto rapel
		_nRapelE5 := 0
		DbSelectArea("SE5")
		DbSetOrder(7)
		MsSeek(FWxFilial("SE5") + Query->E1_PREFIXO + Query->E1_NUM + Query->E1_PARCELA + Query->E1_TIPO + Query->E1_CLIENTE + Query->E1_LOJA)
		While !Eof() .And. SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO == FWxFilial("SE5") + Query->E1_PREFIXO + Query->E1_NUM + Query->E1_PARCELA + Query->E1_TIPO
			If SE5->E5_CLIFOR + SE5->E5_LOJA != Query->E1_CLIENTE + Query->E1_LOJA
				SE5->(dbSkip())
				Loop
			Endif

			// Imprime somente registro que for desconto em rapel
			If AllTrim(SE5->E5_HISTOR) == "Desconto Rapel s/Receb.Titulo"
				_nRapelE5 += SE5->E5_VALOR
			Endif

			SE5->(dbSkip())
		Enddo

		@ li, 159 PSAY Transform(_nRapelE5, "@E 999,999,999.99")
		@ li, 180 PSAY Transform(Query->E1_VLRAPEL - _nRapelE5 + Query->E1_VVBAEXT, "@E 999,999,999.99")
		li:=li+1

		_nTotCli1  += Query->E1_VALOR
		_nTotCli2  += Query->E1_VLRAPEL
		_nTotCli3  += _nRapelE5
		_nTotCli4  += (Query->E1_VLRAPEL - _nRapelE5 + Query->E1_VVBAEXT)
		_nTotGCli1 += Query->E1_VALOR
		_nTotGCli2 += Query->E1_VLRAPEL
		_nTotGCli3 += _nRapelE5
		_nTotGCli4 += (Query->E1_VLRAPEL - _nRapelE5 + Query->E1_VVBAEXT)

		Query->(DBSkip())

	EndDo

	If _nTotGCli1 > 0
		If li>56
			cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
		Endif
		@ li, 104 PSAY Replicate("-",90)
		li:=li+1
		@ li, 080 PSAY "TOTAL  DO  CLIENTE      ==> "
		@ li, 104 PSAY Transform(_nTotCli1, "@E 999,999,999,999.99")
		@ li, 126 PSAY Transform(_nTotCli2, "@E 999,999,999.99")
		@ li, 160 PSAY Transform(_nTotCli3, "@E 999,999,999.99")
		@ li, 182 PSAY Transform(_nTotCli4, "@E 999,999,999.99")
		li:=li+2
		If li>56
			cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
		Endif
		@ li, 080 PSAY "T O T A L  G E R A L    ==> "
		@ li, 104 PSAY Transform(_nTotGCli1, "@E 999,999,999,999.99")
		@ li, 126 PSAY Transform(_nTotGCli2, "@E 999,999,999.99")
		@ li, 160 PSAY Transform(_nTotGCli3, "@E 999,999,999.99")
		@ li, 182 PSAY Transform(_nTotGCli4, "@E 999,999,999.99")
	Endif

	Query->(DBCloseArea())

	If li!=80
		Roda(0,"",Tamanho)
	Endif

	SetPrc(0,0)       // (Zera o Formulario)

	Set Device To Screen

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()   //Libera fila de relatorios em spool (Tipo Rede Netware)

Return
