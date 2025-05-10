#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF57     º Autor ³ Giuliano Forgiariniº Data ³  25/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de verificação de codigos correlacionados entre as   º±±
±±º          ³unidades de Santa Maria e Rio Grande                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ sigapcp                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function GJF57b()
	local nOpca	   :=0
	local aSays    :={}, aButtons:={}

	Private cCadastro := "Conferencia do Correlacionamento dos Produtos"
	Private cPerg   := "GJF57"
	Private aCampos := {} 
	Private aStru   := {}
	Private _nCaixDev := 0
	Private _nCaixRet := 0       
	Private _nCaixInv := 0
	Private _nCaixTot := 0

	AADD (aSays, "  Esta rotina tem como objetivo validar o inventario realizado    ")  //
	AADD (aSays, "  verificando o correlacionamento entre os produtos para que se   ")  //
	AADD (aSays, "  possa realizar com segurança a rotina de acerto de inventario   ")  //


	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	//AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )
	If nopca == 1    
		Processa({||ProcConf()},"INVENTARIO DE PA","Realizando conferencia de correlacionamento...")
	endif

return 

Static Function ProcConf()
	Local _aArqTrb      := {} // ProcData 04/2023
	
	if  !msgbox('Deseja iniciar a conferencia de correlacionamento?','INICIANDO O PROCESSO','YESNO')
		alert('Operação abortada!')
		return .f.
	endif

	//cArq  := CriaTrab( Nil, .F. )
	aadd(aCampos,{"FIL"     ,"Filial Atual",""})                                                 //Cria arquivo temporário  

	aadd(aStru,{"COD"    , "C",  06, 0,   "@!"          , 'Codigo  '})
	aadd(aStru,{"FIL"    , "C",  02, 0,   "@!"          , 'Filial  '})
	aadd(aStru,{"DESC"   , "C",  20, 0,   "@!"          , 'Descri. '})   

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado 
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)
	
	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
	Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	
	_codP := ' '
	SZ8->(DbSetOrder(9))
	SZ8->(DbSeek(xfilial('SZ8')+'S'))

	While SZ8->(!eof()) .and. SZ8->Z8_INV = 'S' 
		incproc()         

		ZZE->(DbSetOrder(1))
		if !ZZE->(DbSeek(xfilial('ZZE')+'00'+SZ8->Z8_CODORI)) 
			if _codP <> SZ8->Z8_CODORI
				reclock('TMP',.t.)
				TMP->COD    := SZ8->Z8_CODORI
				TMP->FIL    := SZ8->Z8_FILORI
				TMP->DESC   := SZ8->Z8_DESCRI
				msunlock() 
				_codP := SZ8->Z8_CODORI
			endif
		endif
		SZ8->(DbSkip())
	enddo	
	TMP->(DbGoTop()) 
	imprimir()
	
	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 
return     


Static Function imprimir()     


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "dos produtos a serem correlacionados entre filiais "
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo         := "CODIGOS A CORRELACIONAR"	//"RELATORIO DE PREVISAO DE PRODUÇÃO"
	Local nLin           := 75
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local   imprime      := .T.
	Local   aOrd         := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "gjf57imp" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 16
	Private aReturn      := { "Zebrado", 1, "Administracao", 1, 1, 1, "",1 }   


	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "gjf57" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _CorteOrigem :='  '
	Private contador 		:=0

	dbSelectArea("TMP")
	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,'G',nomeprog,.f.)     

	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,'SZ8')
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

	/*Consulta para organizar por tipo de peça*/

	TMP->(dbgotop())  

	while TMP->(!eof())

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		@nlin,10 psay TMP->FIL
		@nlin,20 psay TMP->COD
		@nlin,30 psay TMP->DESC  
		nlin++
		TMP->(dbskip())

	enddo
	TMP->(dbclosearea())


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

