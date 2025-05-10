#INCLUDE "rwmake.ch"                           

/*/                                                                                                            
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI127 º Autor ³     Flávio Bohrer FLoresº Data ³  27/09/21 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de carcaças filtradas para cliente específico    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI127()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio   "
	Local cDesc2         := "apresentando os detalhes das etiquetas que vão ser"
	Local cDesc3         := "impressas no abate de acordo com os parametros informados na rotina"
	Local titulo        
	Local nLin           := 80
	Local Cabec1         := Space(5)+" Lote"+space(15)+"Cliente"+Space(26)+"Qtd. "+Space(7)+"Qtd."
	Local Cabec2         := Space(5)+"  --  "+space(15)+" ---  "+Space(25)+"Solic."+Space(5)+"Impressa"
	Local aOrd 			 := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.                                              
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI127" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "DTI127"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI127" // Coloque aqui o nome do arquivo usado para impressao em disco 

	
	pergunte(cPerg,.F.)
	

	titulo := "** RELATÓRIO DE LOTES COM ANIMAIS COM CARACTERÍSTICAS ESPECÍFICAS PARA VENDA **"
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                        

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

	dbSelectArea('SZ4')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



	SZ4->(SetRegua(RecCount()))
	SZ4->(dbGoTop())   
	SZ4->(DbSetOrder(1))   //Aviso de Matanca+ordem+lote (C2_FILIAL+C2_NUMAM +STRZERO(C2_ORDEM,3)+C2_LOTE)
	SZ4->(DbSeek(xfilial('SZ4')+alltrim(mv_par01)))
	//alert(alltrim(mv_par01))
	While SZ4->(!EOF()) .and. SZ4->Z4_FILIAL = xfilial('SZ4') .and. SZ4->Z4_NUMAM = mv_par01 

		incregua()   

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 50 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		_sQtdS := str(SZ4->Z4_IPROD)
		_sQtdI := str(SZ4->Z4_IPROD2)
		If alltrim(SZ4->Z4_VPROD) = "S" 
			@nlin,5  psay Strzero(VAL(SZ4->Z4_LOTE),6)  
			//@nlin,12  psay SZ4->Z4_HORA 
			@nlin,20  psay alltrim(SZ4->Z4_NOMECLI)
			@nlin,60  psay "Qtd.Solic:"+ alltrim(_sQtdS)
			@nlin,80  psay "Qtd.Impressa:"+alltrim(_sQtdI)
			@nlin,100  psay "De Dent.: "+SZ4->Z4_DENT
			@nlin,115  psay  "Até Dent.: "+SZ4->Z4_DENT2
			nlin++
			@nlin,30  psay  "De Raça: "+SZ4->Z4_RACA
			@nlin,45  psay  "Até Raça: "+SZ4->Z4_RACA2
			@nlin,60  psay  "Da Gord.: "+SZ4->Z4_COBGOR
			@nlin,75  psay  "Até Gord.: "+SZ4->Z4_COBGOR2
			
			@nlin,87  psay  "Do Peso : "+transform( SZ4->Z4_PECARC1,'@E 999,999.99')
			@nlin,112  psay  "Até Peso : "+transform( SZ4->Z4_PECARC2,'@E 999,999.99')
			nlin++
			nlin := vcarc(SZ4->Z4_NUMAM,SZ4->Z4_LOTE,nlin)
			@nlin,01 psay replicate('-',132)	
			nlin++



		Endif
		SZ4->(dbSkip()) // Avanca o ponteiro do registro no arquivo  

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

Static Function vcarc(cNumam,cLote,lin)
	
	Local _lLin   := 1
		// Regra 
		// consulta na SZK 
		lin++
		SZK->(DbSetOrder(2))
		SZK->(DbGoTop())
		SZK->(DbSeek(xfilial('SZK')+alltrim(cNumam)+alltrim(cLote)))
		
		Do While SZK->(!eof()) .and. SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE) == xFilial('SZK')+cNumam+cLote
			
			//alert("Sequencial - :"+SZK->ZK_CONTROL) - aviso 01013421
		    
			if  ( SZK->ZK_PETOTAL >= SZ4->Z4_PECARC1 .AND. SZK->ZK_PETOTAL <= SZ4->Z4_PECARC2) 				
				if SZK->ZK_COBGOR >= SZ4->Z4_COBGOR .AND. SZK->ZK_COBGOR <= SZ4->Z4_COBGOR2
					if SZK->ZK_DENT >= SZ4->Z4_DENT .AND. SZK->ZK_DENT <= SZ4->Z4_DENT2
						if SZK->ZK_RACA >= SZ4->Z4_RACA .AND. SZK->ZK_RACA <= SZ4->Z4_RACA2

							if _lLin = 1
								@lin,12 psay SZK->ZK_CONTROL
								_lLin := 2
							elseif _lLin = 2
								@lin,22 psay '| '+SZK->ZK_CONTROL
								_lLin := 3
							elseif _lLin = 3
								@lin,32 psay '| '+SZK->ZK_CONTROL
								_lLin := 4
							elseif _lLin = 4
								@lin,42 psay '| '+SZK->ZK_CONTROL
								_lLin := 5
							elseif _lLin = 5
								@lin,52 psay '| '+SZK->ZK_CONTROL
								_lLin := 6
							elseif _lLin = 6
								@lin,62 psay '| '+SZK->ZK_CONTROL
								_lLin := 7
							elseif _lLin = 7
								@lin,72 psay '| '+SZK->ZK_CONTROL
								_lLin := 8
							elseif _lLin = 8
								@lin,82 psay '| '+SZK->ZK_CONTROL
								_lLin := 9
							elseif _lLin = 9
								@lin,92 psay '| '+SZK->ZK_CONTROL
								_lLin := 10
							elseif _lLin = 10
								@lin,102 psay '| '+SZK->ZK_CONTROL
								_lLin := 11		
							elseif _lLin = 11
								@lin,112 psay '| '+SZK->ZK_CONTROL//86
								_lLin := 1
								lin++
							endif

						Endif
					Endif
				Endif
				
			endif
		
			SZK->(DbSkip())

		Enddo

		lin++
Return lin
