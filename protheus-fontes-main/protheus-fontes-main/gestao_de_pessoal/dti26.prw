#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI26     ºAutor  ³Flávio Bohrer Flôresº Data ³  13/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fonte destinado à visualização do horario de entrada       º±±
±±º          ³ dos funcionários antes de efetuar a alteração			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Direçao				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function dti26()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia das horas antes do ajuste da rotina 'DTI22'."
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo         := "RELAT. DE HORAS DO DO PROCESSO DE AJUSTE"
	Local Cabec1         := ""
	//Local Cabec1         := ""
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "DTI26" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "DTI26"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI26" // Coloque aqui o nome do arquivo usado para impressao em disco

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SP8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SP8')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local nOrdem

	//Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	//nLin := 9

	TMP->(SetRegua(RecCount()))
	TMP->(dbGoTop())

	_cCC := ''

	While TMP->(!EOF())

		incregua()


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		
		//If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
		//	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		//	nLin := 9
		//Endif

		//--- mostrar aqui
		DbSelectArea('SRA')
		SRA->(DbSetOrder(1))

		If (SRA->(DbSeek(xfilial('SRA')+TMP->P8_MAT))) .AND.  cFilAnt == '00'

			_nHraEnt := fConvHr(SRA->RA_HRAENT,'D')//SRA->RA_HRAENT
			_nHraP8  := fConvHr(TMP->P8_HORA,'D')
			_nDif  	 := _nHraEnt - _nHraP8

			if _nHraEnt == 0
				TMP->(dbSkip())
				loop
			endif

			if _nHraP8 >= _nHraEnt
				TMP->(dbSkip())
				loop
			endif
			//if SRA->RA_MAT == '014839'
			//alert(_nDif)
			//alert(fConvHr( _nDif,'H'))
			//endif

			//validação adicionada dia 22/10/18
			if _nDif <= 0.14 //0.14 em decimal é igual a 0.08 em hexasegimal(hora)
				TMP->(dbSkip())
				loop
			endif
			
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9

			//If alltrim(_cCC) <> alltrim(TMP->P8_CC)

				nlin+=2
				_cCC := TMP->P8_CC
				_cDescCC := fBuscaCpo('CTT',1,xFilial('CTT') + _cCC,'CTT_DESC01')
				@nlin,01 psay "Centro de Custo: " + _cCC + _cDescCC
				nlin+=2

			//Endif

			@nlin,01 psay SRA->RA_MAT
			@nlin,12 psay substr(SRA->RA_NOME,1,35)
			nlin++
			@nlin,01 psay "Data        	Horário a Bater		      		     Horário da Batida   			        Dif. Horas"
			nlin++
			@nlin,01 psay STOD(TMP->P8_DATA)
			@nlin,18 psay StrTran(Transform( fConvHr(_nHraEnt,'H'), '@e 9999.99' ),',',':' )
			@nlin,44 psay StrTran(Transform( fConvHr(_nHraP8,'H'), '@e 9999.99' ),',',':' )

			@nlin,66 psay StrTran(Transform( fConvHr( _nDif,'H'), '@e 9999.99' ),',',':' )

			//If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
			//	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			//	nLin := 9
			//Endif

			nlin+=3

			@nlin,01 psay padc("NOTIFICAÇÃO",limite,'')
			nlin++
			@nlin,01 psay padc("Frigorífico Silva Ind. e Com. Ltda, inscrita no CNPJ sob o n°",limite,'')
			nlin++
			@nlin,01 psay padc("88.728.027/0001-46, notifica o empregado acima, o qual, nesta data, registrou sua",limite,'')
			nlin++
			@nlin,01 psay padc("entrada junto ao relógio ponto antes do início efetivo das atividades laborais, ",limite,'')
			nlin++
			@nlin,01 psay padc("que o registro será devidamente corrigido.",limite,'')
			nlin+=2
			@nlin,01 psay padc("Assim, o empregado declara ter recebido, novamente, as devidas orientações",limite,'')
			nlin++
			@nlin,01 psay padc("sobre o correto registro de sua jornada de trabalho, estando ciente de ",limite,'')
			nlin++
			@nlin,01 psay padc("que a repetição de registro incorreto irá contribuir desfavoravelmente em seu",limite,'')
			nlin++
			@nlin,01 psay padc("progresso na empresa, além de poder acarretar-lhe penalidades mais severas. ",limite,'')
			nlin+=2
			@nlin,01 psay padc("Santa Maria, ____ de ____________________ de 20____.",limite,'')
			nlin+=3
			@nlin,01 psay padc("Ciente: _______________________",limite,'')
			
	

		Endif

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		//Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		//nLin := 9
	EndDo

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

	_cQuery := " SELECT P8_MAT, P8_DATA, P8_HORA, P8_CC
	_cQuery += " FROM  " + retSqlTab('SP8')
	_cQuery += " WHERE " + retSqlFil('SP8')
	_cQuery += " AND P8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += " AND P8_CC >= '" + mv_par03 + "' AND P8_CC <= '" + mv_par04 + "'"
	_cQuery += " AND P8_TPMCREP <> 'D' AND " + retSqlDel('SP8')
	_cQuery += " ORDER BY P8_CC, P8_DATA, P8_MAT, P8_HORA

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

