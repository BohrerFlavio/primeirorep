#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR26     ºAutor  ³Mauricio Roehrs     º Data ³  11/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Relatorio para analise de armazenamento de pallets       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function mlr26()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para analise de armazenamento de pallets."
	Local cDesc3         := ""
	Local cPict          := "vai porra"
	Local titulo         := "ANALISE DE ARMAZENAMENTO DE PALLETS"
	Local Cabec1         := "          Data      Hora"
	Local Cabec2         := "               Cod. Pallet  Cod. Prod.  Desc. Prod."
	Local Cabec3 			:= "TESTE"
	Local imprime        := .T.
	Local aOrd           := {}  
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "MLR26" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "MLR26"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "MLR26" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _aBatidas  	:= {}
	pergunte(cPerg,.F.)


	wnrel := SetPrint('SZP',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  


	_cQuery := " SELECT ZP_COD,ZP_DATA,ZP_HORA,ZP_LOCALIZ,Z8_COD,Z8_CONTROL,Z8_DESCRI 
	_cQuery += " FROM  " + RetSQLTab('SZP') + "  ,  " + RetSQLTab('SZ8')
	_cQuery += " WHERE " + RetSQLFil('SZP') + " AND " + RetSQLFil('SZ8')
	_cQuery += " AND ZP_COD = Z8_PALLET AND ZP_PRODUTO = Z8_COD"
	_cQuery += " AND ZP_FIL = '" + cFilAnt + "' AND Z8_FIL = '" + cFilAnt + "'"            
	_cQuery += " AND Z8_HORAS = '' AND Z8_DATAS = ''"
	_cQuery += " AND ZP_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"  
	_cQuery += " AND ZP_HORA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"              
	if !empty(mv_par06)
		_cQuery += " AND SUBSTRING(ZP_LOCALIZ,1,2) = '" + mv_par06 + "'"
	endif
	_cQuery += " AND " + RetSQLDel('SZP') + " AND " + RetSQLDel('SZ8')
	_cQuery += " ORDER BY ZP_COD


	_cQuery  := ChangeQuery(_cQuery)


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
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())
	_cPallet 	:= '' 
	_dData 		:= ''
	_cHora 		:= ''
	_cDescri 	:= ''   
	_cCod 		:= ''
	_nCol 		:= 3  //para gerenciar as colunas
	_nTotPallet := 0

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


		if _cHora <> TMP->ZP_HORA 
			if	_nCol = 3
				_nCol = 1
				nlin++
			endif 
			@nlin,010 psay stod(TMP->ZP_DATA)
			@nlin,023 psay TMP->ZP_HORA  
			nlin++
			_cHora	:= TMP->ZP_HORA
		endif

		if _cPallet <> TMP->ZP_COD
			if	_nCol = 3
				_nCol := 1
				nlin++
			endif   			
			@nlin,014 psay TMP->ZP_COD
			@nlin,027 psay TMP->Z8_COD
			@nlin,037 psay alltrim(TMP->Z8_DESCRI)		
			nlin++                                

			@nlin,016 psay 'Camara: ' + substr(TMP->ZP_LOCALIZ,1,2)
			@nlin,040 psay 'Rua: ' + substr(TMP->ZP_LOCALIZ,3,2)
			@nlin,060 psay 'Predio: ' + substr(TMP->ZP_LOCALIZ,5,2)
			@nlin,080 psay 'Andar: ' + substr(TMP->ZP_LOCALIZ,7,2)
			@nlin,100 psay 'Apto: ' + substr(TMP->ZP_LOCALIZ,9,2)  
			nlin++ 

			if mv_par05 = 1 //se for detalhado
				@nlin,017 psay 'Caixas:'
				nlin++
			endif

			_nTotPallet++
			_cPallet := TMP->ZP_COD
		endif  

		if mv_par05 = 1 //se for detalhado
			if _nCol = 1
				@nlin,20 psay  TMP->Z8_CONTROL
				_nCol := 2
			elseif _nCol = 2
				@nlin,60 psay  TMP->Z8_CONTROL
				_nCol := 3    	
			elseif _nCol = 3
				@nlin,100 psay  TMP->Z8_CONTROL
				_nCol := 1
				nlin++  	
			endif
		endif				                        	

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if _cHora <> TMP->ZP_HORA .or. TMP->(eof())
			nlin++
			@nlin,01 psay replicate('=',132)
			nlin++
		endif

	EndDo 

	@nlin,01 psay 'Total de Pallets: ' + transform(_nTotPallet,'@E 99999')


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


