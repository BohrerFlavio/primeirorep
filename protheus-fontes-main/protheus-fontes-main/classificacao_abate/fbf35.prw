#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF35   º Autor ³ Flavio º Data ³  30/12/10					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Destino das Carcaças    											  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Acompanhamento trabalho Certificadores Hereford Braford    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF35()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "que indica o destino das carcaças.   "
	Local cDesc3         := "Se para a produção da desossa ou para expedição.    "
	Local cPict          := ""
	Local titulo         := "DESTINO DE QUARTOS - HEREFORD"
	Local nLin           := 80

	Local Cabec1         := " Dados da Carcaça"                   
	Local Cabec2         := "          Destino        Data     Hora    Descrição           "+;
	"   |     Destino       Data     Hora    Descrição"

	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "FBF35" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "FBF35"
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "FBF35" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZK',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


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

	Local nOrdem  
	Local _lLin  := .t.   



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbSelectArea('SZK')
	SZK->(DbSetOrder(6))
	SZK->(dbGoTop())
	SZK->(DbSeek(xfilial('SZK')+mv_par01)) 

	aDest := CTBCBOX('ZK_DESTINO')

	SZK->(SetRegua(RecCount()))

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9 

	@nlin,02 psay 'Aviso de Matança nr.: ' + SZK->ZK_NUMAM
	nlin += 2 


	While SZK->(!EOF()) .and. SZK->ZK_FILIAL = xfilial('SZK') .and. SZK->ZK_NUMAM = mv_par01

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

		if !empty(mv_par02)
			if mv_par02 <> SZK->ZK_CLASSIF
				SZK->(DbSkip())
				loop	     
			endif
		endif

		if SZK->ZK_PROGRAM <> '002'

			SZK->(DbSkip())
			loop	     

		endif

		if _lLin = .f.
			nlin += 2
			_lLin := .t.  
		else
			nlin++
		endif

		_cDest := space(1)	 

		if SZK->ZK_DESTINO = 'G'
			_cDest := 'Graxaria'
		elseif SZK->ZK_DESTINO = 'T'
			_cDest := 'TF'
		elseif SZK->ZK_DESTINO = 'R'
			_cDest := 'Conserva'
		endif



		@nlin,02 psay 'Carcaça número: ' + SZK->(ZK_NUMAM+ZK_LOTE+ZK_CONTROL) + '   ' + 'Classificação: ' + SZK->ZK_CLASSIF + '   '+;
		iif(SZK->ZK_DESTINO <> 'C','('+_cDest+')','')
		nlin++

		ZAJ->(DbGoTop())
		ZAJ->(DbSetOrder(1))

		if ZAJ->(DbSeek(xfilial('ZAJ')+SZK->(ZK_NUMAM+ZK_CONTROL))) 

			While ZAJ->(!eof()) .AND. ZAJ->ZAJ_FILIAL = xfilial('ZAJ') .and. ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO) = SZK->(ZK_NUMAM+ZK_CONTROL)      

				if empty(ZAJ->ZAJ_DATAS) .and. empty(ZAJ->ZAJ_HORAS)
					ZAJ->(DbSkip())
					loop
				endif

				if ZAJ->ZAJ_REGORI <> '0000000000'
					ZAJ->(DbSkip())
					loop								      
				endif

				if !empty(ZAJ->ZAJ_PRECAR) .and. !empty(ZAJ->ZAJ_PREPED) .and. !empty(ZAJ->ZAJ_ITEM)
					ZAJ->(DbSkip())
					loop
				endif

				_cString := 'Desossa:    ' + dtoc(ZAJ->ZAJ_DATAS) + '   ' + ZAJ->ZAJ_HORAS	+ '   ' + ZAJ->ZAJ_DESCRI  
				if _lLin = .t. 
					@nlin,10 psay _cString 
					_lLin := .f.
				else
					@nlin,65 psay '|     ' + _cString 
					_lLin := .t.  
					nlin++
				endif
				ZAJ->(DbSkip())
			enddo
		endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 75 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif   
		ZAJ->(DbGoTop())
		ZAJ->(DbSetOrder(1))

		if ZAJ->(DbSeek(xfilial('ZAJ')+SZK->(ZK_NUMAM+ZK_CONTROL))) 

			While ZAJ->(!eof()) .AND. ZAJ->ZAJ_FILIAL = xfilial('ZAJ') .and. ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO) = SZK->(ZK_NUMAM+ZK_CONTROL) 
				if ZAJ->ZAJ_REGORI <> '0000000000'
					ZAJ->(DbSkip())
					loop								      
				endif

				if empty(ZAJ->ZAJ_PRECAR) .and. empty(ZAJ->ZAJ_PREPED) .and. empty(ZAJ->ZAJ_ITEM)
					ZAJ->(DbSkip())              
					loop
				endif
				_cString := 'Expedição:  ' + dtoc(ZAJ->ZAJ_DATAS) + '   ' + ZAJ->ZAJ_HORAS	+ '   ' + ZAJ->ZAJ_DESCRI     
				if _lLin = .t.
					@nlin,10 psay _cString
					_lLin := .f.
				else
					@nlin,65 psay '|     ' + _cString
					_lLin := .t.
					nlin++
				endif


				ZAJ->(DbSkip())
			enddo
		endif

		SZK->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('SZK')

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
