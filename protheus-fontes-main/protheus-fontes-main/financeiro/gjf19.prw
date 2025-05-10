#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

User Function GJF19()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ GJF19    º Autor ³ Giuliano Forgiariniº Data ³  01.07.10   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Emissao de Notas Promissórias Rurais                       º±±
	±±º          ³                                                            º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Especifico para Frigorifico Silva                          º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	Private _cMark    := ''
	Private lExec     := .F.   
	Private aValorExt := {}

	cPerg := "GJF19"

	DbSelectArea("SE2") 

	If Pergunte(cPerg,.T.) 

		if empty(mv_par01) .or. empty(mv_par02) .or. empty(mv_par03) .or.;
		empty(mv_par04) .or. empty(mv_par05) .or. empty(mv_par06)
			MsgBox("Preenchimento inconsistente de parametros de impressão!" ,"OPERVAÇÃO INVÁLIDA","STOP") 
			return .f.
		endif  

		cIndexName := Criatrab(Nil,.F.) 

		cIndexKey  := "E2_PREFIXO + E2_NUM + E2_PARCELA + DTOS(E2_EMISSAO)" 

		cFilter    := "E2_NPR = 'S' .and. " +;
		"E2_NUM >= '" + mv_par01 + "' .and. E2_NUM <= '" + mv_par02 + "' .and. " + ;   
		"E2_FILIAL = '" + xFilial("SE1") + "'" 

		IndRegua("SE2", cIndexName, cIndexKey,, cFilter, "Aguarde. Selecionando Registros....")
		DbSelectArea("SE2")
		DbGoTop()  

		@ 001,001 TO 400,700 DIALOG oDlg TITLE "Seleção de Titulos" 
		@ 001,001 TO 170,350 BROWSE "SE2" MARK "E2_OK"
		@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
		@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
		ACTIVATE DIALOG oDlg CENTERED

		DbGoTop() 

		If lExec            
			_cMark := ThisMark()
			Processa({|lEnd|MontaRel(_cMark)})
		Endif
		RetIndex("SE2")
		Ferase(cIndexName+OrdBagExt())
	EndIf

	DbSelectArea("SE2")
	RetIndex("SE2")

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao MontaRel()                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function MontaRel(_CM)
	Local oPrn
	Local nX := 0
	Local nI := 1

	Local aDadosEmp := {SM0->M0_NOMECOM                                                            ,; // Nome da Empresa
	SM0->M0_ENDENT                                                             ,; // Endereço
	AllTrim(SM0->M0_BAIRENT)+",  "+AllTrim(SM0->M0_CIDENT)+", "+SM0->M0_ESTENT ,; // Complemento
	"CEP: "+Subs(SM0->M0_CEPENT,1,5)+"-"+Subs(SM0->M0_CEPENT,6,3)              ,; // CEP
	"FONE: "+SM0->M0_TEL                                                       ,; // Telefones
	"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+               ; // CNPJ
	Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+Subs(SM0->M0_CGC,13,2) ,;
	"I.E.: "+ALLTRIM(SM0->M0_INSC)}                                               // Inscricao Estadual

	Local _Bitmap
	Local aDadosTit
	Local aDatSacado
	Local aBolText

	aValorExt := {}

	oPrn:=TMSPrinter():New( "NPR Laser" )
	oPrn:SetPortrait()     // ou SetLandscape()       
	oPrn:StartPage()       // Inicia uma nova página  
	oPrn:SetPaperSize(9)   //Tamanho A4

	DbSelectArea("SE2")

	Do While !Eof()
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2")+SE2->(E2_FORNECE +E2_LOJA),.T.)

		If !Found()
			MsgBox("Atencao! Fornecedor "+SE2->E2_FORNECE+"/"+SE2->E2_LOJA+" Nao Cadastrado." ,"ML_ERRO","STOP")
			DbSelectArea("SE2")
			DbSkip()
			Loop
		Endif

		_Bitmap := "\system\silva.bmp"              // Logo da Empresa 

		_cNumTit  := SE2->E2_NUM + " " + SE2->E2_PARCELA  

		//Definição dos dados

		aDadosTit   := {_cNumTit              ,;        // Número do título
		SE2->E2_EMISSAO       ,;        // Data da emissão do título
		Date()                ,;        // Data da emissão do boleto
		SE2->E2_VENCTO        ,;        // Data do vencimento
		SE2->E2_VALOR	        ,;		 // Valor do título
		SE2->E2_NUMNPR  	     ,;        // Sequencial de impressão da NPR
		SE2->E2_IMPNPR }					 // Numero de impressões realizadas desta NPR

		aDatSacado  := {AllTrim(SA2->A2_NOME)                         ,;     // Razão Social
		AllTrim(SA2->A2_COD )                         ,;     // Código
		SA2->A2_CGC                                    }     // CNPJ

		_cQanim := 0
		SD1->(DbSetOrder(1))
		if SD1->(DBSEEK(xFilial('SD1')+SE2->E2_NUM))

			do while  !Eof() .and. SD1->D1_FILIAL = xFilial('SD1')   .and.;
			SD1->D1_DOC = SE2->E2_NUM         .and.;
			SD1->D1_SERIE = SE2->E2_PREFIXO   .and.;
			SD1->D1_FORNECE = SE2->E2_FORNECE .and.; 
			SD1->D1_LOJA = SE2->E2_LOJA
				_cQanim := _cQanim + SD1->D1_QTSEGUM
				SD1->(DbSkip())
			enddo

		endif 

		_cDia     := substr(dtos(ddatabase),7,2) 
		_cMes     := MesExtenso(ddatabase)
		_cAno     := substr(dtos(ddatabase),1,4) 
		_Data     := alltrim(SM0->M0_CIDENT)  + ', ' + _cDia + ' de ' + _cMes + ' de ' + _cAno

		_cDiaV    := substr(dtos(aDadosTit[4]),7,2) 
		_cMesV    := MesExtenso(aDadosTit[4])
		_cAnoV    := substr(dtos(aDadosTit[4]),1,4) 
		_DataV    :=  'A ' + _cDiaV + ' de ' + _cMesV + ' de ' + _cAnoV

		_Instr1 := _DataV + ' por esta NOTA PROMISSORIA RURAL na praça de '
		_Instr2 := 'Santa Maria - RS pagaremos a '
		_Instr2_1 := alltrim(aDatSacado[1])
		_Instr3 := 'ou à sua ordem, a quantia de :' 
		_Instr4 := 'Valor de compra que lhe(s) fiz(emos) conforme NF nº: ' + aDadosTit[1]
		_Instr5 := 'Entrega que me(nos) foi feita dos seguintes bens da sua propriedade: ' + alltrim(str(_cQanim)) +' animais '
		_Instr6 := 'AVALISTA - ' + mv_par03 
		_Instr7 := 'CPF : ' + transform(mv_par04,'@R 999.999.999-99')
		_Instr8 := 'AVALISTA - ' + mv_par05 
		_Instr9 := 'CPF : ' +  transform(mv_par06,'@R 999.999.999-99')
		_Instr10 := 'EMITENTE: FRIGORIFICO SILVA IND E COM LTDA' 
		_Instr11 := 'ENDEREÇO: BR 392 Km 8, Santa Maria-RS-CEP 97001-970'
		_Instr12 := 'ASSINATURA' 
		_Instr13 := 'CGC: 88728027/0001-46'
		_Instr14 := 'OBSERVAÇÃO: Caso resolva não descontar esta promissória, é preciso remetê-la de volta ao Frigorífico Silva,'
		_Instr15 := 'de modo que a mesma chegue em nossas mãos dois dias úteis antes do vencimento.'    

		aBolText    := {_Instr1  ,;          // 1a. Linha da Instrução Bancária
		_Instr2 ,;          // 2a. Linha da Instrução Bancária
		_Instr3 ,;          // 3a. Linha da Instrução Bancária
		_Instr4 ,;		   // 4a. Linha da Instrução Bancária
		_Instr5 ,;
		_Instr6 ,;          // 
		_Instr7 ,;          // 
		_Instr8 ,;		   // 
		_Instr9 ,;
		_Instr10 ,;          // 
		_Instr11 ,;          // 
		_Instr12 ,;		   // 
		_Instr13 ,;
		_Instr14 ,;          // 
		_Instr15,;
		_Instr2_1 } 

		If SE2->E2_OK <> _CM
			Impress(oPrn,_Data,_DataV,aDadosEmp,aDadosTit,aDatSacado,aBolText,_Bitmap)
			//nX := nX + 1
		EndIf

		DbSelectArea("SE2") 


		DbSkip()
		nI := nI + 1
	EndDo

	oPrn:EndPage()       // Finaliza a página

	oPrn:Preview()    // Visualiza antes de imprimir

	DbSelectArea("SE2")
	RetIndex("SE2")

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao Impress()                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Impress(oPrn,_Data,_DataV,aDadosEmp,aDadosTit,aDatSacado,aBolText,_Bitmap)

	If aDadosTit[7] <> 0
		If !MsgBox("Atencao! A NPR do titulo Nrº " + alltrim(aDadosTit[1]) +;
		" foi impressa " + alltrim(str(aDadosTit[7])) + " vezes. Continuar? (S/N)" ,"VALIDAÇÃO DE IMPRESSÃO","YESNO")
			return
		endif
	endif


	_cValor   := 'R$ ' + alltrim(transform(aDadosTit[5],'@E 999,999.99'))

	_cSeq := iif(empty(aDadosTit[6]), strzero(GETMV("SI_SEQNPR")+1,9) ,aDadosTit[6]) 

	//Parametros de TFont.New()
	//1.Nome da Fonte (Windows)
	//3.Tamanho em Pixels
	//5.Bold (T/F)
	oFont8   := TFont():New("Arial",9,08,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11  := TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont16  := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)

	oFont14n := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)

	oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont18n := TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrn:StartPage()       // Inicia uma Nova Página

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PRIMEIRA PARTE                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	_cExtenso := alltrim(extenso(aDadosTit[5],.f.,1))

	nRow1 := 0 
	nRow2 := 1710
	oPrn:Say(nRow1 + 0050 ,0700 ,'NOTA PROMISSÓRIA RURAL' ,oFont24) 
	oPrn:Say(nRow1 + 0190 ,550 ,'NPR Nº.: '+ _cSeq,oFont10) 

	if aDadosTit[7] > 0
		oPrn:Say(nRow1 + 0230 ,550 ,'[Via de Negociação nº.: '+ alltrim(strzero(aDadosTit[7]+1,3)) + ']',oFont10) 
	endif

	oPrn:SayBitmap(nRow1 + 0100,100,_Bitmap,0350,0245)

	oPrn:Line (nRow1 + 0280,1800,nRow1 + 0350,1800 )  //Vertical 1
	oPrn:Line (nRow1 + 0280,1800,nRow1 + 0280,2300 )
	oPrn:Line (nRow1 + 0350,1800,nRow1 + 0350,2300 )
	oPrn:Line (nRow1 + 0280,2300,nRow1 + 0350,2300 ) 

	oPrn:Say(nRow1 + 0190 ,1500 ,_Data ,oFont14)   
	oPrn:Say(nRow1 + 0290 ,1940 ,_cValor,oFont16)

	oPrn:Say(nRow1 + 0410,0450 ,aBolText[1],oFont14)
	oPrn:Say(nRow1 + 0480,0100 ,aBolText[2],oFont14)   
	oPrn:Say(nRow1 + 0480,0800 ,aBolText[16],oFont14n)
	oPrn:Say(nRow1 + 0560,0100 ,aBolText[3],oFont14)

	/*_i := 42
	_j := 1 
	_k := 0    

	for _k := 1 to len(_cExtenso) 

	if empty(substr(_cExtenso,_i,1))	
	//	alert('Sim1')
	if _j < 41 
	//	alert('Sim2')
	oPrn:Say(nRow1 + 0560 ,0780 ,alltrim(substr(_cExtenso , 1 , 40 + _j)),oFont14n)   
	else 
	//	alert('Nao2')
	oPrn:Say(nRow1 + 0630 ,0100 ,alltrim(substr(_cExtenso , _j , 71)) + '.',oFont14n)  
	endif
	_j += 41
	_k += 41
	_i += 42
	else 
	_j++
	_i++
	endif    
	next

	_j := 1
	*/

	oPrn:Say(nRow1 + 0630 ,100 ,substr(_cExtenso,1,75),oFont14n)   
	oPrn:Say(nRow1 + 0700 ,100 ,substr(_cExtenso,76,75),oFont14n) 

	oPrn:Say(nRow1 + 800,0100 ,aBolText[4],oFont14)  
	oPrn:Say(nRow1 + 870,0100 ,aBolText[5],oFont14)  

	oPrn:Line (nRow1 + 1080,0100,nRow1 + 1080,0850 )   
	oPrn:Say(nRow1 + 1075,0100 ,aBolText[6],oFont12)  
	oPrn:Say(nRow1 + 1135,0120 ,aBolText[7],oFont12)

	oPrn:Line (nRow1 + 1270,0100,nRow1 + 1270,0850 ) 
	oPrn:Say(nRow1 + 1285,0100 ,aBolText[8],oFont12)  
	oPrn:Say(nRow1 + 1345,0120 ,aBolText[9],oFont12)

	oPrn:Say(nRow1 + 1425,0100 ,aBolText[10],oFont14)
	oPrn:Say(nRow1 + 1485,0100 ,aBolText[11],oFont14) 


	oPrn:Line (nRow1 + 1270,1600,nRow1 + 1270,2300 ) 
	oPrn:Say(nRow1 + 1285,01620 ,aBolText[12],oFont12)  
	oPrn:Say(nRow1 + 1345,01640 ,aBolText[13],oFont12)

	oPrn:Say(nRow1 + 1555,0100 ,aBolText[14],oFont12)
	oPrn:Say(nRow1 + 1615,0360 ,aBolText[15],oFont12)
	oPrn:Line (nRow1 + 1705,0100,nRow1 + 1705,2300 )      

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SEGUNDA PARTE                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

	oPrn:Say(nRow2 + 0050 ,0700 ,'NOTA PROMISSÓRIA RURAL' ,oFont24) 
	oPrn:Say(nRow2 + 0190 ,550 ,'NPR Nº.: '+ _cSeq,oFont10) 

	if aDadosTit[7] > 0
		oPrn:Say(nRow2 + 0230 ,550 ,'[Via de Negociação nº.: '+ alltrim(strzero(aDadosTit[7]+1,3)) + ']',oFont10) 
	endif

	oPrn:Say(nRow2 + 0270 ,550 ,'Via Não Negociável',oFont10) 

	oPrn:SayBitmap(nRow2 + 0100,100,_Bitmap,0350,0245)

	oPrn:Line (nRow2 + 0280,1800,nRow2 + 0350,1800 )  //Vertical 1
	oPrn:Line (nRow2 + 0280,1800,nRow2 + 0280,2300 )
	oPrn:Line (nRow2 + 0350,1800,nRow2 + 0350,2300 )
	oPrn:Line (nRow2 + 0280,2300,nRow2 + 0350,2300 ) 

	oPrn:Say(nRow2 + 0190 ,1500 ,_Data ,oFont14)   
	oPrn:Say(nRow2 + 0290 ,1940 ,_cValor,oFont16)

	oPrn:Say(nRow2 + 0410,0450 ,aBolText[1],oFont14)
	oPrn:Say(nRow2 + 0480,0100 ,aBolText[2],oFont14)   
	oPrn:Say(nRow2 + 0480,0800 ,aBolText[16],oFont14n)
	oPrn:Say(nRow2 + 0560,0100 ,aBolText[3],oFont14)
	/*
	_i := 42
	_j := 1 
	_k := 0    

	for _k := 1 to len(_cExtenso)      
	if empty(substr(_cExtenso,_i,1))	
	if _j < 41
	oPrn:Say(nRow2 + 0560 ,0780 ,alltrim(substr(_cExtenso,1,40+_j)),oFont14n)   
	else 
	oPrn:Say(nRow2 + 0630 ,0100 ,alltrim(substr(_cExtenso,_j,71)) + '.',oFont14n)   
	endif
	_j += 41 
	_k += 41
	_i += 42
	else
	_i++ 
	_j++
	endif    
	next
	*/ 
	oPrn:Say(nRow2 + 0630 ,100 ,substr(_cExtenso,1,75),oFont14n)  
	oPrn:Say(nRow2 + 0700 ,100 ,substr(_cExtenso,76,75),oFont14n) 

	oPrn:Say(nRow2 + 800,0100 ,aBolText[4],oFont14)  
	oPrn:Say(nRow2 + 870,0100 ,aBolText[5],oFont14)  

	oPrn:Line (nRow2 + 1080,0100,nRow2 + 1080,0850 )   
	oPrn:Say(nRow2 + 1075,0100 ,aBolText[6],oFont12)  
	oPrn:Say(nRow2 + 1135,0120 ,aBolText[7],oFont12)

	oPrn:Line (nRow2 + 1270,0100,nRow2 + 1270,0850 ) 
	oPrn:Say(nRow2 + 1285,0100 ,aBolText[8],oFont12)  
	oPrn:Say(nRow2 + 1345,0120 ,aBolText[9],oFont12)

	oPrn:Say(nRow2 + 1425,0100 ,aBolText[10],oFont14)
	oPrn:Say(nRow2 + 1485,0100 ,aBolText[11],oFont14) 


	oPrn:Line (nRow2 + 1270,1600,nRow2 + 1270,2300 ) 
	oPrn:Say(nRow2 + 1285,01620 ,aBolText[12],oFont12)  
	oPrn:Say(nRow2 + 1345,01640 ,aBolText[13],oFont12)

	oPrn:Say(nRow2 + 1555,0100 ,aBolText[14],oFont12)
	oPrn:Say(nRow2 + 1615,0360 ,aBolText[15],oFont12)
	oPrn:Line (nRow2 + 1705,0100,nRow2 + 1705,2300 )      


	//impressão de uma box
	//oPrn:box(250,450,700,2000)

	oPrn:EndPage()       // Finaliza a página

	reclock('SE2',.f.)

	if empty(SE2->E2_NUMNPR)
		PUTMV('SI_SEQNPR',val(_cSeq)) 
		SE2->E2_NUMNPR := _cSeq
	endif     

	SE2->E2_IMPNPR := aDadosTit[7] + 1

	msunlock()

	_cSeq := ''

Return

