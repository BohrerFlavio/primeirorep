#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF81   º Autor ³ Giuliano Forgiarini  º Data ³  18/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Classificação de Lotes                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Recebimento, abate e qualidade (SIGAPCP)             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                                                                       
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF81()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio     "
	Local cDesc2         := "de de lotes classificados conforme regras estabelecidas"
	Local cDesc3         := "pelo setor de qualidade para com o processo de         "
	//Local cPict          := "rastreabilidade                                        "
	Local titulo         := "R1 - CLASSIFICAÇÃO DE LOTES"
	Local nLin           := 80
	Local Cabec1         := "  Numero   Classif.      Nome                               Categ.         Numero    Lote  "                   
	Local Cabec2         := "  Lote      Lote         Produtor                           Animais         GTA     Rastro"
	//Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "GJF81" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF81"
	//Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "GJF81" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ4',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ4')

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SZ4->(DbSetOrder(1))
	SZ4->(dbGoTop())
	SZ4->(MsSeek(FWxfilial('SZ4')+mv_par01))
	SZ4->(SetRegua(RecCount()))

	_dDtAM := dtoc(GetAdvFval('SZG','ZG_DATA',FWxfilial('SZG')+SZ4->Z4_NUMAM,1))
	_lF := .f.

	While SZ4->(!EOF()) .and. SZ4->Z4_FILIAL = FWxfilial('SZ4') .and. SZ4->Z4_NUMAM = mv_par01

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif  

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif  

		if !_lF
			@nlin,10 psay "AVISO DE MATANÇA NUMERO " + SZ4->Z4_NUMAM + "   (" + _dDtAM + ")"  
			nlin += 2
			_lF := .t.
		endif

		Do Case
			case SZ4->Z4_DECPROD = 'A'
			_cMD := 'Declaração Modelo A'
			case SZ4->Z4_DECPROD = 'B'
			_cMD := 'Declaração Modelo B'
			case SZ4->Z4_DECPROD = 'S'
			_cMD := 'Declaração sem assinatura'
			case SZ4->Z4_DECPROD = 'N'
			_cMD := 'Não possui declaração'
			case SZ4->Z4_DECPROD = 'U'
			_cMD := 'Declaração BR'
			case SZ4->Z4_DECPROD = 'R'
			_cMD := 'Declaração USA'
		endcase

		_cNumAR := GetAdvFval('SZE','ZE_NUMERO',FWxfilial('SZE')+SZ4->(Z4_NUMAM+Z4_LOTE),2)
		_aNumPr := GetAdvFval('SZD',{'ZD_FORNECE','ZD_LOJA'},FWxfilial('SZD')+_cNumAR,1)
		_cTRACE := iif(GetAdvFval('SA2','A2_TRACE',FWxfilial('SA2')+_aNumPr[1]+_aNumPr[2],1)='S','Confere','Não confere')

		_cReg := SZ4->Z4_LOTE + '     ' + SZ4->Z4_CLASSIF + '     ' + padr(SZ4->Z4_NOME,40,'') +;
		SZ4->Z4_DESCAT + '     ' + SZ4->Z4_GTA + '     ' + iif(SZ4->Z4_RASTRO = 'S','Sim','Não')

		@nlin,02 psay _cReg
		nlin++ 
		@nlin,02 psay '- Propriedade TRACE?:                                                       '+;
		'    ' + _cTRACE
		nlin++  
		@nlin,02 psay '- Todos animais possuem elemento de identificação:                          '+;
		'    ' + iif(SZ4->Z4_ELEMID = 'C','Confere','Não confere')   
		nlin++ 
		@nlin,02 psay '- Conferencias da GTA:                                                      '+;
		'    ' + iif(SZ4->Z4_PROPGTA = 'C','Confere','Não confere')
		nlin++  
		@nlin,02 psay '- Conferencias do pre-sumario:                                              '+;
		'    ' + iif(SZ4->Z4_AREAGTA = 'C','Confere','Não confere') 
		nlin++

		@nlin,02 psay '- Declaração do produtor:                                                   '+;
		'    ' + _cMD
		nlin++  

		@nlin,00 psay replicate('-',132)
		nlin++
		SZ4->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SZ4->(DbCloseArea())

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
