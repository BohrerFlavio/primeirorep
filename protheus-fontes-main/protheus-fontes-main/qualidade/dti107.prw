#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI107   º Autor ³ Flávio Bohrer	     º Data ³  20/07/09                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ R11 - Relatorio de Rastreabilidade - Destino das Carcaças    		   º±±
±±ºChamado   ³http://chamados.frigorificosilva.com.br/glpi/front/ticket.form.php?id=358º±±
±±º          ³                                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qualidade e PCP (SIGAPCP)                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI107()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "que lista o destino das carcaças proprias, se para  "
	Local cDesc3         := "a produção da desossa ou para expedição.            "

	Local titulo         := "DESTINO DE QUARTOS"
	Local nLin           := 80

	Local Cabec1         := " Dados da Carcaça"                   
	Local Cabec2         := "          Data     Hora    Descrição           "+;
	"                |     Data     Hora    Descrição"

	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI107" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "DTI107"
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "DTI107" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZAJ',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cQuery := " SELECT ZAJ_NUMAM , ZAJ_LOTE ,ZAJ_CONTRO, ZAJ_NUM ,ZAJ_COD , ZAJ_DESCRI , ZAJ_CORORI , ZAJ_DATAS , ZAJ_HORAS , ZAJ_PRECAR , ZAJ_PREPED , ZAJ_ITEM" 
	_cQuery += " FROM  " + RetSqlTab('ZAJ')
	_cQuery += " WHERE " + RetSQLFil('ZAJ')
	_cQuery += " AND ZAJ_NUMAM = '"+alltrim(mv_par01)+"' " 		
	_cQuery += " AND ZAJ_DATAS <> '' AND ZAJ_HORAS <> ''"  
	_cQuery += " AND ZAJ_REGORI = '0000000000' 
	If mv_par03 = 2
		// Dianteiro
		_cQuery += " AND ZAJ_COD = '005020'
	Elseif mv_par03 = 3
		//Traseiro
		_cQuery += " AND ZAJ_COD = '005016'
	Elseif  mv_par03 = 4
		// Costela
		_cQuery += " AND ZAJ_COD = '005018'
	Else
		// Todos juntos
	endif
	IF mv_par02 = 2 
		// Desossa		  
		_cQuery += " AND ZAJ_PRECAR = '' AND ZAJ_PREPED = '' AND ZAJ_ITEM = '' AND ZAJ_PREDES <> '' "		
		Cabec1 += ": Desossa"	
	Elseif mv_par02 = 3
		// Expedição
		  
		_cQuery += " AND ZAJ_PRECAR <> '' AND ZAJ_PREPED <> '' AND ZAJ_ITEM <> ''"
		_cQuery += " AND ZAJ_PRECAR <> 'ACERTO' AND ZAJ_PREPED <> 'ACERTO' AND ZAJ_ITEM <> '999'"
		Cabec1 += ": Expedição"	
	Else
		// Todas carcaças
		Cabec1 += ": Desossa/Expedição"	
	endif	 
	_cQuery += " AND " + RetSQLDel('ZAJ')	
	_cQuery += " ORDER BY ZAJ_NUMAM , ZAJ_LOTE ,ZAJ_CONTRO , ZAJ_NUM ,ZAJ_COD , ZAJ_DESCRI , ZAJ_CORORI , ZAJ_DATAS , ZAJ_HORAS , ZAJ_PRECAR , ZAJ_PREPED , ZAJ_ITEM"
	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	
	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif
	TCQUERY _cQuery NEW ALIAS "QRY"
	
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

	Local nOrdem  
	Local _lLin  := .t.  
	Local nCont := 1 
	Private _nCont := 0
	Private _nCont2 := 0
	Private _nCont3 := 0
	Private _nNumLC := ""
	Private _nDtAvis

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	QRY->(SetRegua(RecCount()))
	
	While QRY->(!EOF()) 

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
		If _nCont2 = 0
			_nDtAvis := fBuscaCPO('SZG',1,xfilial('SZG')+alltrim(QRY->ZAJ_NUMAM),'ZG_DATA')
			@nlin,01 psay 'Aviso de Matança nr.: ' + alltrim(QRY->ZAJ_NUMAM) + " Data: " + DTOC(_nDtAvis)			
			nlin += 3 
		Endif
		If	QRY->(ZAJ_NUMAM+ZAJ_LOTE+ZAJ_CONTRO) <> _nNumLC
			
			If _nCont > 0
				nlin++
			endif
			_lLin = .t.
			@nlin,02 psay 'Carcaça número: ' + QRY->(ZAJ_NUMAM+ZAJ_LOTE+ZAJ_CONTRO)
			_nNumLC := QRY->(ZAJ_NUMAM+ZAJ_LOTE+ZAJ_CONTRO)
			_nCont++
			
			nlin++
		Endif
				
		_cString := substr(QRY->ZAJ_DATAS,7,2) + '/' + substr(QRY->ZAJ_DATAS,5,2) + '/' + substr(QRY->ZAJ_DATAS,1,2) + '   ' + QRY->ZAJ_HORAS	+ '   ' + QRY->ZAJ_DESCRI
		_nCont2++
		
		
		if _lLin = .t. 
			@nlin,10 psay _cString 
			_lLin := .f.
		
		else
			@nlin,65 psay '|     ' + _cString 
			_lLin := .t.  
			nlin++
		endif
		
		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo
	
	If nLin > 70 // Salto de Página. Neste caso o formulario tem 75 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif   

	nlin++
	@nlin,03 psay replicate('-',130)
	nlin++
	@nlin,005 psay 'Quantidade total de Peças :   ' + transform(_nCont2,'@E 999,999')
	nlin++  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('QRY')

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
