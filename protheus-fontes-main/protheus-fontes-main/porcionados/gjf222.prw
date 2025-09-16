#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF222     ºAutor  ³Giuliano Forgiariniº Data ³  18/08/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Relatorio para analise de peças de terceiro em estoque   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function GJF222()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "de rendimento de produção de lotes de PAs produzidos"
	Local cDesc3         := "na indústria de porcionados."
	Local cPict          := ""
	Local titulo         := "P01 - LOTES DE PRODUÇÃO"
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}  
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "GJF222" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "GJF222"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF222" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _aBatidas  	:= {}      
	Private _cGrpmoi     := GetMV('SI_GRPMOI')
	pergunte(cPerg,.F.)


	Cabec1 := 'Da data ' + dtoc(mv_par01)
	Cabec2 := 'Até data ' + dtoc(mv_par01)

	wnrel := SetPrint('ZAU',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAU')

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

	ZAU->(SetRegua(RecCount()))

	ZAU->(DbSetOrder(2))
	ZAU->(dbGoTop())
	ZAU->(DbSeek(xfilial('ZAU') + dtos(mv_par01),.t.))
	while ZAU->(!eof())  .and. ZAU->ZAU_FILIAL = xfilial('ZAU') .and. ZAU->ZAU_DTPROD <= mv_par02

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin + 15 > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		_cDescri := fBuscaCPO('SB1',1,xfilial('ZAU') + ZAU->ZAU_COD,'B1_DESC')
		_cDescMP := fBuscaCPO('SB1',1,xfilial('ZAU') + ZAU->ZAU_COD,'B1_DESC')
		_cGrupo  := fBuscaCPO('SB1',1,xfilial('ZAU') + ZAU->ZAU_COD,'B1_GRUPO')

		@nlin,001 psay 'DATA: ' + dtoc(ZAU->ZAU_DTPROD) + ' - LOTE DE PRODUÇÃO NR.: ' + ZAU->ZAU_NUM + '  Status: ' + ZAU->ZAU_STATUS 
		nlin++
		@nlin,001 psay alltrim(ZAU->ZAU_COD) + ' [' +  alltrim(_cDescri) + ']'        
		nlin++                                                                                                           
		@nlin,001 psay 'Data de Abate : ' + dtoc(ZAU->ZAU_DTABAT) + ' - Layout :' + ZAU->ZAU_LAYETQ 
		nlin++
		@nlin,001 psay 'Previsão Peso:     [' + transform(ZAU->ZAU_QPPESO,'@E 999,999.99') + ']kg  Realizado Peso:     [' + transform(ZAU->ZAU_QRPESF,'@E 999,999.99') + ']kg' 
		nlin++                                                                                                                                                     
		@nlin,001 psay 'Previsao Caixas:   [' + transform(ZAU->ZAU_QPCAIX,'@E 999,999.99') + ']cx  Realizado Caixas:   [' + transform(ZAU->ZAU_QRCAIF,'@E 999,999.99') + ']cx' 
		nlin++                                                                                                                                                     
		@nlin,001 psay 'Previsao Unidades: [' + transform(ZAU->ZAU_QPUNI,'@E 999,999.99') +  ']un  Realizado Unidades: [' + transform(ZAU->ZAU_QRUNI,'@E 999,999.99') + ']un' 
		nlin++
		@nlin,001 psay 'Materia Prima: ' + ZAU->ZAU_CODMP + ' - ' + _cDescMP
		nlin++
		@nlin,001 psay 'Previsão Consumo:  [' + transform(ZAU->ZAU_QTDMP,'@E 999,999.99') +  ']kg  Realizado Consumo:  [' + transform(ZAU->ZAU_QTDMPC,'@E 999,999.99') + ']kg' 

		if   _cGrupo $ _cGrpMoi
			ZAV->(DbSetOrder(1))
			if ZAV->(DbSeek(xfilial('ZAV') + ZAU->ZAU_NUM))
				while ZAV->(!eof())  .and. ZAV->ZAV_FILIAL = xfilial('ZAV') .and. ZAV->ZAV_NUM = ZAU->ZAU_NUM  
					nlin++                              
					_cDescMoi := fBuscaCPO('SB1',1,xfilial('SB1') + ZAV->ZAV_COD,'B1_DESCRED')
					@nlin,001 psay 'Item: ' + ZAV->ZAV_ITEM + '   ' + alltrim(ZAV->ZAV_COD) + '   ' + alltrim(_cDescMoi) 
					nlin++
					@nlin,001 psay 'Previsão Consumo:  [' + transform(ZAV->ZAV_QPPESO,'@E 999,999.99') +  ']kg  Realizado Consumo:  [' + transform(ZAV->ZAV_QRPESO,'@E 999,999.99') + ']kg' 

					ZAV->(DbSkip())
				enddo
			endif
		endif

		jlin := 1  	   

		ZAR->(DbSetOrder(4))
		if ZAR->(DbSeek(xfilial('ZAR') + ZAU->ZAU_NUM))
			while ZAR->(!eof()) .and. ZAR->ZAR_FILIAL = xfilial('ZAR') .and. ZAR->ZAR_LOTE = ZAU->ZAU_NUM
				nlin++
				@nlin,01 psay 'Ordens de Produção:'
				nlin++  
				@nlin,jlin psay ZAR->ZAR_NUM

				jlin += 12

				if jlin > 49
					jlin := 1
					nlin++
				endif

				ZAR->(DbSkip())
			enddo 
			nlin++
		else
			nlin++
		endif
		nlin++  

		If nLin > 65 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif


		ZAU->(DbSkip())			  

	enddo
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


