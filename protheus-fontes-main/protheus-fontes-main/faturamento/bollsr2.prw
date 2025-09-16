#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "totvs.ch"

User Function BOLLSR2()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ BOLLSR   º Autor ³ Evandro Mugnol     º Data ³  29.07.04   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Emissao de Boletos Bancarios                               º±±
	±±º          ³                                                            º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Especifico para Frigorifico Silva                          º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßß3ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Private lExec := .F.

	cPerg := "BOLLSR"
	//ValidPerg() - Dia 25/05/23 Tivemos que comentar porque ao acessar o sistema as perguntas eram duplicadas
	Pergunte(cPerg,.F.)    // Pergunta no SX1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01           // Do Prefixo                             ³
	//³ mv_par02           // Ate o Prefixo                          ³
	//³ mv_par03           // Do Titulo                              ³
	//³ mv_par04           // Ate o Titulo                           ³
	//³ mv_par05           // Banco p/ Emissão                       ³
	//³ mv_par06           // Papel de Impressão                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbSelectArea("SE1")
	If Pergunte (cPerg,.T.)
		_cBanco   := ''
		_cCODCED  := ''
		_cBmpLogo := ''
		_cAgencia := ''

		DbSelectArea('SA6')
		SA6->(DbSetOrder(1))
		SA6->(MsSeek(FWxFilial('SA6') + mv_par05))
		While SA6->(!Eof()) .And. SA6->A6_FILIAL == FWxFilial('SA6') .And. SA6->A6_COD == mv_par05

			If SA6->A6_PORTBOL = 'S'
				_cBanco  := SA6->A6_COD
				_cCODCED  := SA6->A6_CEDBOL
				_cBmpLogo := SA6->A6_BMPBOL
				_cAgencia := SA6->A6_AGENCIA
				Exit
			Endif

			SA6->(DbSkip())
		EndDo

		If empty(_cBanco) .or. empty(_cCODCED) //.or. empty(_cBmpLogo)
			MsgBox("Banco ainda nao liberado ou campos não preenchidos em seu cadastro!","ATENCAO!!!","STOP")
			Return
		Endif

		If cEmpAnt == "01"
			_cCedente := "350050622178"
		ElseIf cEmpAnt == "08"
			_cCedente := "350132927074"
		Else
			MsgBox("Empresa sem CEDENTE para impressão de boletos. Favor contactar DTI.","ATENCAO!!!","STOP")
			Return
		EndIf

		cIndexName := Criatrab(Nil,.F.)
		cIndexKey  := "E1_PREFIXO + E1_NUM + E1_PARCELA + DTOS(E1_EMISSAO)"
		cFilter    := "E1_PREFIXO >= '" + MV_PAR01 + "' .And. E1_PREFIXO <= '" + MV_PAR02 + "' .And. " + ;
					  "E1_NUM >= '" + MV_PAR03 + "' .And. E1_NUM <= '" + MV_PAR04 + "' .And. " + ;
					  "(E1_PORT2 = '" + _cBanco + "' .or. empty(E1_PORT2)) .And. " + ;
					  "E1_FILIAL = '" + FWxFilial("SE1")+"' .And. E1_SALDO > 0 "+" .And. E1_FRMREC = '3' "
		
		IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde. Selecionando Registros....")
		DbSelectArea("SE1")
		DbGoTop()
		@ 001,001 TO 400,700 DIALOG oDlg TITLE "Seleção de Titulos"
		@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
		@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
		@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
		ACTIVATE DIALOG oDlg CENTERED

		DbGoTop()
		If lExec
			Processa({|lEnd|MontaRel()})
		Endif
		RetIndex("SE1")
		Ferase(cIndexName+OrdBagExt())
	Endif

	DbSelectArea("SE1")
	RetIndex("SE1")

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao MontaRel()                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function MontaRel(aMarked)
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
						"I.E.: "+ALLTRIM(SM0->M0_INSC)                                             ,; // Inscricao Estadual
						AllTrim(SM0->M0_ENDENT)+" - "+AllTrim(SM0->M0_BAIRENT)                     ,; // Endereço+Bairro
						SM0->M0_CIDENT															   ,; // Cidade
						SM0->M0_ESTENT															   ,; // Estado
						SM0->M0_CEPENT															   ,; // CEP
						SM0->M0_CGC   															    } // CNPJ

	Local aBitmap
	Local aDadosTit
	Local aDadosBanco
	Local aDatSacado
	Local aBolText

	oPrn:=TMSPrinter():New( "Boleto Laser" )
	oPrn:SetPortrait()     // ou SetLandscape()
	oPrn:StartPage()       // Inicia uma nova página
	oPrn:SetPaperSize(9)   // Tamanho A4

	DbSelectArea("SE1")
	Do While !Eof()
		DbSelectArea("SA1")
		DbSetOrder(1)
		MsSeek(FWxFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
		If !Found()
			MsgBox("Atencao! Cliente "+SE1->E1_CLIENTE+"/"+SE1->E1_LOJA+" Nao Cadastrado." ,"ML_ERRO","STOP")
			DbSelectArea("SE1")
			DbSkip()
			Loop
		Endif

		DbSelectArea("SE1")
		Reclock("SE1",.F.)
		SE1->E1_PORT2 := _cBanco
		MsUnlock()

		DbSelectArea("SEE")
		DbSetOrder(1)
		MsSeek(FWxFilial("SEE")+SE1->E1_PORT2+_cAgencia)
		If Found()
			_NumBco := SEE->EE_BOLATU
			_Instr1 := SEE->EE_INSTRU1
			_Instr2 := SEE->EE_INSTRU2
			_Instr3 := SEE->EE_INSTRU3
			_Instr4 := SEE->EE_INSTRU4
			_Instr5 := SEE->EE_INSTRU5
		Else
			MsgBox("Atencao! Nao Encontrado Dados Param. Bancos CNAB "+SE1->E1_PORT2,"ML_ERRO","STOP")
			DbSelectArea("SE1")
			DbSkip()
			Loop
		Endif

		If _NumBco < SEE->EE_BOLINI .Or. _NumBco > SEE->EE_BOLFIN
			MsgBox("Atencao! Intervalo Seq. Boleto Invalida Banco "+SE1->E1_PORT2,"ML_ERRO","STOP")
			DbSelectArea("SE1")
			DbSkip()
			Loop
		Endif

		If SE1->E1_BOLIMP == "S"
			If MsgYesNo("Boleto "+ALLTRIM(SE1->E1_NUMBCO)+" Titulo "+SE1->E1_NUM+" Ja Impresso Confirma Reimpressao?")
				nOpc := 1
			Else
				nOpc := 3
			Endif
			DO CASE
				CASE nOpc == 2
					DbSelectArea("SE1")
					DbSkip()
					Loop
				CASE nOpc==3
					DbSelectArea("SE1")
					DbSkip()
					Loop
			ENDCASE
		Endif

		DbSelectArea("SE1")

		If Empty(SE1->E1_NUMBCO) .and. _cBanco <> "033"
			NossoNum()
		Endif

		aBitmap := {"\system\" + _cBmpLogo ,;                  // Logo do Banco
					"\system\silva.bmp"     }                  // Logo da Empresa

		// Definição dos dados de cada banco
		DO CASE
			CASE _cBanco = '001'
				_cNumTit  := SE1->(E1_NUM+E1_PARCELA)
				_cAgen    := AllTrim(SA6->A6_AGENCIA)+'-'+SA6->A6_DVAGE
				_cAgenCed := substr(SA6->A6_AGEBOL,1,4)+'-'+SA6->A6_DVAGE
			CASE _cBanco = '041'
				_cNumTit  := SE1->E1_NUM+" "+SE1->E1_PARCELA
				_cAgen    := SA6->A6_AGENCIA
				_cAgenCed := SA6->A6_AGEBOL
			CASE _cBanco = '033'
				_cNumTit  := SE1->E1_NUM+" "+SE1->E1_PARCELA
				_cAgen    := SA6->A6_AGENCIA
				_cAgenCed := SA6->A6_AGEBOL
		ENDCASE

		If cEmpAnt == "01"
			aDadosBanco := {SA6->A6_COD_BC     ,;             // Numero do Banco
							SA6->A6_NREDUZ     ,;             // Nome do Banco
							_cAgen             ,;
							SA6->A6_NUMCON     ,;             // Conta Corrente
							SA6->A6_CARTEIR    ,;             // Codigo Carteira
							_cAgenCed          ,;             // Agencia Beneficiário  A6_AGEBOL
							SA6->A6_CEDBOL}//IIF(SE1->E1_EMISSAO >= CTOD("01/05/2022"), "20000X    ", "050622097 ")}  // Codigo Beneficiário
		Else
			aDadosBanco := {SA6->A6_COD_BC     ,;             // Numero do Banco
							SA6->A6_NREDUZ     ,;             // Nome do Banco
							_cAgen             ,;
							SA6->A6_NUMCON     ,;             // Conta Corrente
							SA6->A6_CARTEIR    ,;             // Codigo Carteira
							_cAgenCed          ,;             // Agencia Beneficiário  A6_AGEBOL
							"132927074      "	}  			  // Codigo Beneficiário
		EndIf
		aDatSacado  := {AllTrim(SA1->A1_NOME)                         ,;     // Razão Social
						AllTrim(SA1->A1_COD )                         ,;     // Código
						AllTrim(SA1->A1_END )+" "+SA1->A1_BAIRRO      ,;     // Endereço
						AllTrim(SA1->A1_MUN )                         ,;     // Cidade
						SA1->A1_EST                                   ,;     // Estado
						LEFT(SA1->A1_CEP,5)+"-"+RIGHT(SA1->A1_CEP,3)  ,;     // CEP
						SA1->A1_CGC                                   ,;     // CNPJ
						SA1->A1_PESSOA                                 }     // PESSOA

		aBolText    := {_Instr1  ,;          // 1a. Linha da Instrução Bancária
						_Instr2  ,;          // 2a. Linha da Instrução Bancária
						_Instr3  ,;          // 3a. Linha da Instrução Bancária
						_Instr4  ,;          // 4a. Linha da Instrução Bancária
						_Instr5   }          // 5a. Linha da Instrução Bancária

		// VALOR DOS TITULOS TIPO "AB-"
		_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

		if Empty(SE1->E1_NUMBCO)
			if _cBanco == '033'
				CB_RN := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",Subs(aDadosBanco[3],1,4),aDadosBanco[4],aDadosBanco[5],aDadosBanco[6],AllTrim(E1_NUM)+AllTrim(E1_PARCELA),;
							(E1_SALDO-_nVlrAbat-E1_DECRESC),SE1->E1_VENCTO,SEE->EE_CODEMP,SEE->EE_BOLATU,Iif(SE1->E1_DECRESC > 0,.t.,.f.),SE1->E1_PARCELA,aDadosBanco[3])
			endif
		Else
			cCodBarra := SE1->E1_CODBAR
			cLinDig   := SE1->E1_CODDIG
			cNossoNum := SE1->E1_NUMBCO
			CB_RN  := {cCodBarra,cLinDig,cNossoNum}
		endif

		if _cBanco == '033'
			If Empty(SE1->E1_NUMBCO)
				DbSelectArea("SEE")
				RecLock("SEE",.F.)
				SEE->EE_BOLATU := SEE->EE_BOLATU + 1     // INCREMENTA P/ TODOS OS BANCOS
				DbUnlock()

				DbSelectArea("SE1")
				RecLock("SE1",.F.)
				SE1->E1_CODBAR := CB_RN[1]                             // GRAVA CODIGO DE BARRAS CALCULADO NO TITULO
				SE1->E1_CODDIG := CB_RN[2]                             // GRAVA LINHA DIGITAVEL CALCULADA NO TITULO
				SE1->E1_NUMBCO := CB_RN[3]                             // GRAVA NOSSO NUMERO NO TITULO
				SE1->E1_BOLIMP := "S"
				DbUnlock()
			Endif
		endif

		aDadosTit   := {_cNumTit                ,;        // Número do título
						SE1->E1_EMISSAO         ,;        // Data da emissão do título
						Date()                  ,;        // Data da emissão do boleto
						SE1->E1_VENCTO          ,;        // Data do vencimento
						SE1->E1_VALOR           ,;        // Valor do título
						ALLTRIM(SE1->E1_NUMBCO) ,;        // Nosso número (Ver fórmula para calculo)
						SE1->E1_VALJUR          ,;        // Valor dos juros diários
						NoRound(SE1->E1_VLRAPEL,2)}       // Valor dos descontos financeiros p/ grandes redes (ALTERADO PARA DESCONTO RAPEL EM 01/05/2013)

		If Marked("E1_OK")
			Impress(oPrn,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText)
			nX := nX + 1
		Endif

		DbSelectArea("SE1")
		DbSkip()
		nI := nI + 1
	EndDo

	oPrn:EndPage()       // Finaliza a página
	oPrn:Preview()    	// Visualiza antes de imprimir

	DbSelectArea("SE1")
	RetIndex("SE1")

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao Impress()                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Impress(oPrn,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText)
	Local nI

	STR_NUM := ARRAY(99) //{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}  //ARRAY[99]
	AFILL(STR_NUM,0)
	_XXA := ARRAY(5) //{0,0,0,0,0}		//ARRAY[5]
	_XXB := ARRAY(5) //{0,0,0,0,0}		//ARRAY[5]
	AFILL(_XXA,"A")
	AFILL(_XXB,"A")

	if _cBanco <> "033"
		CB_RN := CODIGOBARRAS(aDadosBanco[1],aDadosBanco[3])
	endif

	//Parametros de TFont.New()
	//1.Nome da Fonte (Windows)
	//3.Tamanho em Pixels
	//5.Bold (T/F)
	oFont8   := TFont():New("Arial",9,08,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrn:StartPage()       // Inicia uma Nova Página

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PRIMEIRA PARTE                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRow1 := 0
	oPrn:Say(nRow1+0170 ,0750 ,aDadosEmp[1] ,oFont14)
	oPrn:Say(nRow1+0250 ,1600 ,aDadosEmp[2] ,oFont10)
	oPrn:Say(nRow1+0300 ,1600 ,aDadosEmp[3] ,oFont10)
	oPrn:Say(nRow1+0350 ,1600 ,aDadosEmp[4] ,oFont10)
	oPrn:Say(nRow1+0400 ,1600 ,aDadosEmp[5] ,oFont10)
	oPrn:Say(nRow1+0450 ,1600 ,aDadosEmp[6] ,oFont10)
	oPrn:Say(nRow1+0500 ,1600 ,aDadosEmp[7] ,oFont10)

	oPrn:SayBitmap(nRow1+0100 ,100 ,aBitmap[2] ,0420 ,0350)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SEGUNDA PARTE                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRow2 := 50

	//Pontilhado separador
	For nI := 100 to 2300 step 50
		oPrn:Line(nRow2+0580, nI,nRow2+0580, nI+30)
	Next nI

	oPrn:Line (nRow2+0710,100,nRow2+0710,2300)
	oPrn:Line (nRow2+0710,500,nRow2+0630, 500)
	oPrn:Line (nRow2+0710,710,nRow2+0630, 710)

	oPrn:Say  (nRow2+0644,100,aDadosBanco[2]     ,oFont11 )       // [2]Nome do Banco
	oPrn:Say  (nRow2+0635,513,aDadosBanco[1]     ,oFont21 )       // [1]Numero do Banco

	If _cBanco = '041'
		oPrn:Say  (nRow2+0630,0900,"SAC BANRISUL: 0800.646.1515"		,oFont10)
		oPrn:Say  (nRow2+0670,0900,"OUVIDORIA BANRISUL: 0800.644.2200"	,oFont10)
	endif

	oPrn:Say  (nRow2+0644,1800,"Recibo do Pagador",oFont10)

	oPrn:Line (nRow2+0810,100,nRow2+0810,2300 )
	oPrn:Line (nRow2+0910,100,nRow2+0910,2300 )
	oPrn:Line (nRow2+0980,100,nRow2+0980,2300 )
	oPrn:Line (nRow2+1050,100,nRow2+1050,2300 )

	oPrn:Line (nRow2+0910,500,nRow2+1050,500)
	oPrn:Line (nRow2+0980,750,nRow2+1050,750)
	oPrn:Line (nRow2+0910,1000,nRow2+1050,1000)
	oPrn:Line (nRow2+0910,1300,nRow2+0980,1300)
	oPrn:Line (nRow2+0910,1480,nRow2+1050,1480)

	oPrn:Say  (nRow2+0710,100 ,"Local de Pagamento"                     ,oFont8)

	If _cBanco = '001'
		oPrn:Say  (nRow2+0765,100 ,"Pagável em qualquer banco até o vencimento. Após, atualize o boleto no site bb.com.br.",oFont10)
	elseif _cBanco = '033'
		oPrn:Say  (nRow2+0765,100 ,"PAGÁVEL PREFERENCIALMENTE NO BANCO SANTANDER",oFont10)
	Else
		oPrn:Say  (nRow2+0765,100 ,"ATÉ O VENCIMENTO PAGAR NA REDE BANCÁRIA",oFont10)
	Endif

	oPrn:Say  (nRow2+0710,1810,"Vencimento"                             ,oFont8)
	cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol := 1810+(374-(len(cString)*22))
	oPrn:Say  (nRow2+0750,nCol,cString,oFont11c)

	oPrn:Say  (nRow2+0810,100 ,"Beneficiário"                                   ,oFont8)
	oPrn:Say  (nRow2+0838,100 ,aDadosEmp[1]+"                  "+aDadosEmp[6]   ,oFont10) 															// NOME+CNPJ
	oPrn:Say  (nRow2+0868,100 ,AllTrim(aDadosEmp[8])+"  CEP: " + AllTrim(aDadosEmp[11])+"  "+AllTrim(aDadosEmp[9])+" - "+aDadosEmp[10]	,oFont10)	// ENDEREÇO+BAIRRO+CEP+CIDADE+ESTADO

	oPrn:Say  (nRow2+0810,1810,"Agência/Código do Beneficiário",oFont8)
	oPrn:Say  (nRow2+0850,nCol,alltrim(aDadosBanco[6])+"/"+aDadosBanco[7],oFont11c)

	oPrn:Say  (nRow2+0910,100 ,"Data do Documento"                              ,oFont8)
	oPrn:Say  (nRow2+0940,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)

	oPrn:Say  (nRow2+0910,505 ,"Nro.Documento"                                  ,oFont8)
	oPrn:Say  (nRow2+0940,605 ,aDadosTit[1]                                     ,oFont10) //Prefixo+Numero+Parcela

	oPrn:Say  (nRow2+0910,1005,"Espécie Doc."                                   ,oFont8)

	DO CASE
		CASE _cBanco = '041'
		oPrn:Say  (nRow2+0940,1050,"R$"                                          ,oFont10) //Tipo do Titulo
		CASE _cBanco $ '001/033'
		oPrn:Say  (nRow2+0940,1050,"DM"                                          ,oFont10) //Tipo do Titulo
	ENDCASE

	oPrn:Say  (nRow2+0910,1305,"Aceite"                                         ,oFont8)
	oPrn:Say  (nRow2+0940,1400,"N"                                              ,oFont10)

	oPrn:Say  (nRow2+0910,1485,"Data do Processamento"                          ,oFont8)
	oPrn:Say  (nRow2+0940,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao

	oPrn:Say  (nRow2+0910,1810,"Nosso Número"                                   ,oFont8)
	oPrn:Say  (nRow2+0940,1850,aDadosTit[6]                                     ,oFont11c)

	oPrn:Say  (nRow2+0980,100 ,"Uso do Banco"                                   ,oFont8)

	oPrn:Say  (nRow2+0980,505 ,"Carteira"                                       ,oFont8)
	oPrn:Say  (nRow2+1010,555 ,aDadosBanco[5]                                   ,oFont10)

	oPrn:Say  (nRow2+0980,755 ,"Espécie"                                        ,oFont8)
	oPrn:Say  (nRow2+1010,805,"R$"                                             ,oFont10) //Tipo do Titulo

	oPrn:Say  (nRow2+0980,1005,"Quantidade"                                     ,oFont8)
	oPrn:Say  (nRow2+0980,1485,"Valor"                                          ,oFont8)

	oPrn:Say  (nRow2+0980,1810,"(=)Valor do Documento"                          ,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol := 1810+(374-(len(cString)*22))
	oPrn:Say  (nRow2+1010,nCol,cString ,oFont11c)

	if _cBanco = '033'
		oPrn:Say  (nRow2+1050,100 ,"Mensagem / Instruções (Texto de Responsabilidade do Beneficiário)",oFont8)
	else
		oPrn:Say  (nRow2+1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
	endif

	DO CASE
		CASE _cBanco $ '001/033'
		oPrn:Say  (nRow2+1150,100 ,alltrim(aBolText[1]) + ' R$ ' + AllTrim(Transform(aDadosTit[7],"@E 999,999.99")) ,oFont10)
		CASE _cBanco = '041'
		oPrn:Say  (nRow2+1100,100 ,"JUROS AO DIA DE R$ "+AllTrim(Transform(aDadosTit[7],"@E 999,999,999.99")) ,oFont10)
		oPrn:Say  (nRow2+1150,100 ,alltrim(aBolText[1]),oFont10)
		OTHERWISE
		Prn:Say  (nRow2+1150,100 ,alltrim(aBolText[1]),oFont10)
	ENDCASE

	oPrn:Say  (nRow2+1200,100 ,aBolText[2]                                      ,oFont10)
	oPrn:Say  (nRow2+1250,100 ,aBolText[3]                                      ,oFont10)
	oPrn:Say  (nRow2+1300,100 ,aBolText[4]                                      ,oFont10)
	oPrn:Say  (nRow2+1350,100 ,aBolText[5]                                      ,oFont10)

	oPrn:Say  (nRow2+1050,1810,"(-)Desconto/Abatimento"                         ,oFont8)
	DO CASE
		CASE _cBanco $ '041/033' .and. aDadosTit[8] <> 0
		cString := Alltrim(Transform(aDadosTit[8],"@E 99,999,999.99"))
		CASE _cBanco = '001'
		//Conforme e-mail Clailton 04/01/16 - alterado por Giuliano
		cString := Alltrim(Transform(aDadosTit[8],"@E 99,999,999.99"))
		OTHERWISE
		cString := ''
	ENDCASE

	nCol := 1810+(374-(len(cString)*22))
	oPrn:Say  (nRow2+1080,nCol,cString ,oFont11c)
	oPrn:Say  (nRow2+1120,1810,"(-)Outras Deduções"                             ,oFont8)
	oPrn:Say  (nRow2+1190,1810,"(+)Mora/Multa"                                  ,oFont8)
	oPrn:Say  (nRow2+1260,1810,"(+)Outros Acréscimos"                           ,oFont8)

	DO CASE
		CASE _cBanco = '041'
		cString := Alltrim(Transform(GetMv("ML_TXBOL"),"@E@Z 99,999,999.99"))
		CASE _cBanco = '001'
		cString := Alltrim(Transform(GetMv("SI_TXBB"),"@E@Z 99,999,999.99"))
		OTHERWISE
		cString := ''
	ENDCASE

	nCol := 1810+(374-(len(cString)*22))
	oPrn:Say  (nRow2+1290,nCol,cString ,oFont11c)
	oPrn:Say  (nRow2+1330,1810,"(=)Valor Cobrado"                               ,oFont8)

	oPrn:Say  (nRow2+1400,100 ,"Pagador"                                         ,oFont8)
	oPrn:Say  (nRow2+1430,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
	oPrn:Say  (nRow2+1483,400 ,aDatSacado[3]                                    ,oFont10)
	oPrn:Say  (nRow2+1536,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

	If Len(AllTrim(aDatSacado[7]))==14
		oPrn:Say  (nRow2+1589,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
	Else
		oPrn:Say  (nRow2+1589,400 ,"CPF: " +TRANSFORM(aDatSacado[7],"@R 999.999.999-99")    ,oFont10) // CPF
	Endif

	oPrn:Say  (nRow2+1589,1850,aDadosTit[6]           ,oFont10)

	if _cBanco = '033'
		oPrn:Say  (nRow2+1605,100 ,"Beneficiário Final"     ,oFont8)
	else
		oPrn:Say  (nRow2+1605,100 ,"Sacador/Avalista"     ,oFont8)
	endif
	oPrn:Say  (nRow2+1645,1500,"Autenticação Mecânica",oFont8)

	oPrn:Line (nRow2+0710,1800,nRow2+1400,1800 )
	oPrn:Line (nRow2+1120,1800,nRow2+1120,2300 )
	oPrn:Line (nRow2+1190,1800,nRow2+1190,2300 )
	oPrn:Line (nRow2+1260,1800,nRow2+1260,2300 )
	oPrn:Line (nRow2+1330,1800,nRow2+1330,2300 )
	oPrn:Line (nRow2+1400,100 ,nRow2+1400,2300 )
	oPrn:Line (nRow2+1640,100 ,nRow2+1640,2300 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TERCEIRA PARTE                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRow3 := 150

	For nI := 100 to 2300 step 50
		oPrn:Line(nRow3+1850, nI, nRow3+1850, nI+30)
	Next nI

	DO CASE
		CASE aDadosBanco[1] = '041-8'
		oPrn:SayBitmap(nRow3+1890 ,100 ,aBitmap[1] ,0390 ,0110)
		CASE aDadosBanco[1] = '001-9'
		oPrn:SayBitmap(nRow3+1890 ,100 ,aBitmap[1] ,0400 ,0110)
		CASE aDadosBanco[1] = '033-7'
		oPrn:SayBitmap(nRow3+1890 ,100 ,aBitmap[1] ,0400 ,0110)
	ENDCASE

	oPrn:Line (nRow3+2000,100,nRow3+2000,2300)
	oPrn:Line (nRow3+2000,500,nRow3+1920,0500)
	oPrn:Line (nRow3+2000,710,nRow3+1920,0710)

	DO CASE
		CASE aDadosBanco[1] = '041-8'
		oPrn:Say  (nRow3+1925,513,aDadosBanco[1]     ,oFont21 )   //  [1]Numero do Banco
		oPrn:Say  (nRow3+1934,755,alltrim(CB_RN[2])  ,oFont15n)   //  Linha Digitavel do Codigo de Barras
		CASE aDadosBanco[1] = '001-9'
		oPrn:Say  (nRow3+1925,513,aDadosBanco[1]     ,oFont21 )   //  [1]Numero do Banco
		oPrn:Say  (nRow3+1934,800,alltrim(CB_RN[2])  ,oFont15n)   //  Linha Digitavel do Codigo de Barras
		CASE aDadosBanco[1] = '033-7'
		oPrn:Say  (nRow3+1925,513,aDadosBanco[1]     ,oFont21 )   //  [1]Numero do Banco
		oPrn:Say  (nRow3+1934,800,alltrim(CB_RN[2])  ,oFont15n)   //  Linha Digitavel do Codigo de Barras
	ENDCASE

	oPrn:Line (nRow3+2100,100,nRow3+2100,2300 )
	oPrn:Line (nRow3+2200,100,nRow3+2200,2300 )
	oPrn:Line (nRow3+2270,100,nRow3+2270,2300 )
	oPrn:Line (nRow3+2340,100,nRow3+2340,2300 )

	oPrn:Line (nRow3+2200,500 ,nRow3+2340,500 )
	oPrn:Line (nRow3+2270,750 ,nRow3+2340,750 )
	oPrn:Line (nRow3+2200,1000,nRow3+2340,1000)
	oPrn:Line (nRow3+2200,1300,nRow3+2270,1300)
	oPrn:Line (nRow3+2200,1480,nRow3+2340,1480)

	oPrn:Say  (nRow3+2000,100 ,"Local de Pagamento",oFont8)

	If _cBanco = '001'
		oPrn:Say  (nRow3+2055,100 ,"Pagável em qualquer banco até o vencimento. Após, atualize o boleto no site bb.com.br.",oFont10)
	elseif _cBanco = '033'
		oPrn:Say  (nRow3+2055,100 ,"PAGÁVEL PREFERENCIALMENTE NO BANCO SANTANDER",oFont10)
	Else
		oPrn:Say  (nRow3+2055,100 ,"ATÉ O VENCIMENTO PAGAR NA REDE BANCÁRIA",oFont10)
	Endif

	oPrn:Say  (nRow3+2000,1810,"Vencimento",oFont8)
	cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol := 1810+(374-(len(cString)*22))
	oPrn:Say  (nRow3+2040,nCol,cString,oFont11c)

	oPrn:Say  (nRow3+2100,100 ,"Beneficiário",oFont8)
	oPrn:Say  (nRow3+2128,100 ,aDadosEmp[1]+"                  "+aDadosEmp[6]   ,oFont10) 																				// NOME+CNPJ
	oPrn:Say  (nRow3+2158,100 ,AllTrim(aDadosEmp[8])+"  CEP: " + AllTrim(aDadosEmp[11])+"  "+AllTrim(aDadosEmp[9])+" - "+aDadosEmp[10]	,oFont10)	// ENDEREÇO+BAIRRO+CEP+CIDADE+ESTADO

	oPrn:Say  (nRow3+2100,1810,"Agência/Código do Beneficiário",oFont8)
	oPrn:Say  (nRow3+2140,nCol,alltrim(aDadosBanco[6])+"/"+aDadosBanco[7],oFont11c)

	oPrn:Say  (nRow3+2200,100 ,"Data do Documento"                              ,oFont8)
	oPrn:Say  (nRow3+2230,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)

	oPrn:Say  (nRow3+2200,505 ,"Nro.Documento"                                  ,oFont8)
	oPrn:Say  (nRow3+2230,605 ,aDadosTit[1]                                                ,oFont10) //Prefixo +Numero+Parcela

	oPrn:Say  (nRow3+2200,1005,"Espécie Doc."                                   ,oFont8)

	DO CASE
		CASE _cBanco = '041'
		oPrn:Say  (nRow3+2230,1050,"R$"                                             ,oFont10) //Tipo do Titulo
		CASE _cBanco $ '001/033'
		oPrn:Say  (nRow3+2230,1050,"DM"                                             ,oFont10) //Tipo do Titulo
	ENDCASE

	oPrn:Say  (nRow3+2200,1305,"Aceite"                                         ,oFont8)
	oPrn:Say  (nRow3+2230,1400,"N"                                              ,oFont10)

	oPrn:Say  (nRow3+2200,1485,"Data do Processamento"                          ,oFont8)
	oPrn:Say  (nRow3+2230,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao

	oPrn:Say  (nRow3+2200,1810,"Nosso Número"                                   ,oFont8)
	oPrn:Say  (nRow3+2230,1835,aDadosTit[6]                                     ,oFont11c)

	oPrn:Say  (nRow3+2270,100 ,"Uso do Banco"                                   ,oFont8)

	oPrn:Say  (nRow3+2270,505 ,"Carteira"                                       ,oFont8)
	oPrn:Say  (nRow3+2300,555 ,aDadosBanco[5]                                   ,oFont10)

	oPrn:Say  (nRow3+2270,755 ,"Espécie"                                        ,oFont8)

	oPrn:Say  (nRow3+2300,805 ,"R$"                                             ,oFont10) //Tipo do Titulo

	oPrn:Say  (nRow3+2270,1005,"Quantidade"                                     ,oFont8)
	oPrn:Say  (nRow3+2270,1485,"Valor"                                          ,oFont8)

	oPrn:Say  (nRow3+2270,1810,"(=)Valor do Documento"                          ,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol := 1810+(374-(len(cString)*22))
	oPrn:Say  (nRow3+2300,nCol,cString,oFont11c)

	if _cBanco = '033'
		oPrn:Say  (nRow3+2340,100 ,"Mensagem / Instruções (Texto de Responsabilidade do Beneficiário)",oFont8)
	else
		oPrn:Say  (nRow3+2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
	endif

	DO CASE
		CASE _cBanco $ '001/033'
		oPrn:Say  (nRow3+2440,100 ,alltrim(aBolText[1]) + ' R$ ' + AllTrim(Transform(aDadosTit[7],"@E 999,999.99")) ,oFont10)
		CASE _cBanco = '041'
		oPrn:Say  (nRow3+2390,100 ,"JUROS AO DIA DE R$ "+AllTrim(Transform(aDadosTit[7],"@E 999,999,999.99")) ,oFont10)
		oPrn:Say  (nRow3+2440,100 ,alltrim(aBolText[1]),oFont10)
		OTHERWISE
		oPrn:Say  (nRow3+2390,100 ,alltrim(aBolText[1]),oFont10)
	ENDCASE

	oPrn:Say  (nRow3+2490,100 ,aBolText[2]                                      ,oFont10)
	oPrn:Say  (nRow3+2540,100 ,aBolText[3]                                      ,oFont10)
	oPrn:Say  (nRow3+2590,100 ,aBolText[4]                                      ,oFont10)
	oPrn:Say  (nRow3+2640,100 ,aBolText[5]                                      ,oFont10)

	oPrn:Say  (nRow3+2340,1810,"(-)Desconto/Abatimento"                         ,oFont8)

	DO CASE
		CASE _cBanco $ '041/033' .and. aDadosTit[8] <> 0
		cString := Alltrim(Transform(aDadosTit[8],"@E 99,999,999.99"))
		CASE _cBanco = '001'
		cString := Alltrim(Transform(aDadosTit[8],"@E 99,999,999.99"))
		OTHERWISE
		cString := ''
	ENDCASE

	nCol := 1810+(374-(len(cString)*22))
	oPrn:Say  (nRow3+2370,nCol,cString ,oFont11c)
	oPrn:Say  (nRow3+2410,1810,"(-)Outras Deduções"                             ,oFont8)
	oPrn:Say  (nRow3+2480,1810,"(+)Mora/Multa"                                  ,oFont8)
	oPrn:Say  (nRow3+2550,1810,"(+)Outros Acréscimos"                           ,oFont8)

	DO CASE
		CASE _cBanco = '041'
		cString := Alltrim(Transform(GetMv("ML_TXBOL"),"@E@Z 99,999,999.99"))
		CASE _cBanco = '001'
		cString := ''
		OTHERWISE
		cString := Alltrim(Transform(GetMv("ML_TXBOL"),"@E@Z 99,999,999.99"))
	ENDCASE

	nCol := 1810+(374-(len(cString)*22))
	oPrn:Say  (nRow3+2580,nCol,cString ,oFont11c)
	oPrn:Say  (nRow3+2620,1810,"(=)Valor Cobrado"                               ,oFont8)

	oPrn:Say  (nRow3+2690,100 ,"Pagador"                                         ,oFont8)
	oPrn:Say  (nRow3+2700,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)

	If Len(AllTrim(aDatSacado[7]))==14
		oPrn:Say  (nRow3+2700,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
	Else
		oPrn:Say  (nRow3+2700,1750,"CPF: " +TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10)     // CPF
	Endif

	oPrn:Say  (nRow3+2753,400 ,aDatSacado[3]                                         ,oFont10)
	oPrn:Say  (nRow3+2806,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10)       // CEP+Cidade+Estado

	oPrn:Say  (nRow3+2806,1750,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)       ,oFont10)

	if _cBanco = '033'
		oPrn:Say  (nRow2+2815,100 ,"Beneficiário Final"     ,oFont8)
	else
		oPrn:Say  (nRow3+2815,100 ,"Sacador/Avalista"		,oFont8)
	endif
	oPrn:Say  (nRow3+2855,1500,"Autenticação Mecânica - Ficha de Compensação"        ,oFont8)

	oPrn:Line (nRow3+2000,1800,nRow3+2690,1800 )
	oPrn:Line (nRow3+2410,1800,nRow3+2410,2300 )
	oPrn:Line (nRow3+2480,1800,nRow3+2480,2300 )
	oPrn:Line (nRow3+2550,1800,nRow3+2550,2300 )
	oPrn:Line (nRow3+2620,1800,nRow3+2620,2300 )
	oPrn:Line (nRow3+2690,100 ,nRow3+2690,2300 )
	oPrn:Line (nRow3+2850,100 ,nRow3+2850,2300 )

	//MSBAR("INT25",13.8,0.9,CB_RN[1],oPrn,.F.,Nil,Nil,0.013,0.9,Nil,Nil,"A",.F.)
	if _cBanco = '033'
		MSBAR("INT25",27.9,1.5,CB_RN[1],oPrn,.F.,,,0.0253,1.6,,,,.F.)
	else
		MSBAR("INT25",26.5,1.3,CB_RN[1],oPrn,.F.,,,0.0253,1.6,,,,.F.)
	endif

	oPrn:EndPage()       // Finaliza a página

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Perguntas no SX1                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValidPerg()
	Local i
	Local j

	cAlias := Alias()
	aRegs  :={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	AADD(aRegs,{cPerg,"01","Prefixo De         ?","Prefixo De         ?","Prefixo De         ?","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Prefixo Ate        ?","Prefixo Ate        ?","Prefixo Ate        ?","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Titulo De          ?","Titulo De          ?","Titulo De          ?","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Titulo Ate         ?","Titulo Ate         ?","Titulo Ate         ?","mv_ch4","C",09,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Banco p/ Emissao   ?","Banco p/ Emissao   ?","Banco p/ Emissao   ?","mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA6",""})

	DbSelectArea("SX1")
	DbSetOrder(1)
	For i:=1 to Len(aRegs)
		If !MsSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
		Else
			RecLock("SX1",.F.)
		Endif
		For j:=1 to FCount()
			// Campos CNT nao sao gravados para preservar conteudo anterior.
			If j<=Len(aRegs[i]) .and. left (fieldname (j), 6) != "X1_CNT" .and. fieldname (j) != "X1_PRESEL"
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Next
	DbSelectArea(cAlias)
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHAMADA DA FUNCAO MODULO10()                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Modulo10(cData)

	Local L,D,P := 0
	Local B     := .F.
	L := Len(cData)       // TAMANHO DE BYTES DO CARACTER
	B := .T.   
	D := 0                // DIGITO VERIFICADOR
	While L > 0 
		P := Val(SubStr(cData, L, 1))
		If (B) 
			P := P * 2
			If P > 9 
				P := P - 9
			Endif
		Endif
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	Endif

Return(D)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHAMADA DA FUNCAO MODULO11()                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Modulo11(cData,cBanc,cTpPeso)
	Local L, D, P := 0  

	If cBanc == "041"        // BANCO BANRISUL

		If cTpPeso == "7"
			L := Len(cdata)
			D := 0
			P := 1
			While L > 0
				P := P + 1
				D := D + (Val(Substr(cData, L, 1)) * P)
				If P = 7
					P := 1
				Endif
				L := L - 1
			End
			D := 11 - (mod(D,11))
			If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
				D := 1
			Endif
			D := AllTrim(Str(D))
		ElseIf cTpPeso == "9"
			L := Len(cdata)
			D := 0
			P := 1
			While L > 0
				P := P + 1
				D := D + (Val(Substr(cData, L, 1)) * P)
				If P = 9
					P := 1
				Endif
				L := L - 1
			End
			D := 11 - (mod(D,11))
			If (D == 0 .Or. D == 1)
				D := 1
			Endif
			D := AllTrim(Str(D))
		EndIf

	ElseIf cBanc == "033"    // SANTANDER

		L := Len(cdata)
		D := 0
		P := 1
		While L > 0
			P := P + 1
			D := D + (Val(Substr(cData, L, 1)) * P)
			If P = 9
				P := 1
			Endif
			L := L - 1
		End
		D := 11 - (mod(D,11))
		If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
			D := 1
		Endif
		D := AllTrim(Str(D))

	Endif

Return(D)   


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao CODIGOBARRAS()                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function CODIGOBARRAS(cCodBco,cCodAge)

	Local I

	_xCodbar := ""
	_ccodbar := ""

	DO CASE
		CASE SE1->E1_PORT2 == "041"  // Banrisul
			i:=1
			Do While i<= 44
				STR_NUM[i] := 1
				i:=i+1
			EndDo
			/*if SE1->E1_VENCTO >= CTOD("22/02/2025")  // Regra que verifica o fator de vencimento a partir de 2025
				_FV := str(SE1->E1_VENCTO - CtoD("22/02/2025") + 1000,4)
			else
				_FV := str(SE1->E1_VENCTO - ctod('07/10/1997'),4)
			endif
			_XX := _FV + strzero(SE1->E1_VALOR*100,10,0)*/
			_XX := str(SE1->E1_VENCTO - ctod('07/10/1997'),4) + strzero(SE1->E1_VALOR*100,10,0)
			STR_NUM[1]:=0
			STR_NUM[2]:=4
			STR_NUM[3]:=1
			STR_NUM[4]:=9    // MOEDA
			STR_NUM[6]:=VAL(SUBSTR(_XX,1,1))
			STR_NUM[7]:=VAL(SUBSTR(_XX,2,1))
			STR_NUM[8]:=VAL(SUBSTR(_XX,3,1))
			STR_NUM[9]:=VAL(SUBSTR(_XX,4,1))
			STR_NUM[10]:=VAL(SUBSTR(_XX,5,1))
			STR_NUM[11]:=VAL(SUBSTR(_XX,6,1))
			STR_NUM[12]:=VAL(SUBSTR(_XX,7,1))
			STR_NUM[13]:=VAL(SUBSTR(_XX,8,1))
			STR_NUM[14]:=VAL(SUBSTR(_XX,9,1))
			STR_NUM[15]:=VAL(SUBSTR(_XX,10,1))
			STR_NUM[16]:=VAL(SUBSTR(_XX,11,1))
			STR_NUM[17]:=VAL(SUBSTR(_XX,12,1))
			STR_NUM[18]:=VAL(SUBSTR(_XX,13,1))
			STR_NUM[19]:=VAL(SUBSTR(_XX,14,1))
			STR_NUM[20]:=2
			STR_NUM[21]:=1
			_XX:=SEE->EE_AGENCIA
			STR_NUM[22]:=VAL(SUBSTR(_XX,1,1))
			STR_NUM[23]:=VAL(SUBSTR(_XX,2,1))
			STR_NUM[24]:=VAL(SUBSTR(_XX,3,1))
			STR_NUM[25]:=VAL(SUBSTR(_XX,4,1))
			_XX:=substr(_cCedente,4,7)
			STR_NUM[26]:=VAL(SUBSTR(_XX,1,1))
			STR_NUM[27]:=VAL(SUBSTR(_XX,2,1))
			STR_NUM[28]:=VAL(SUBSTR(_XX,3,1))
			STR_NUM[29]:=VAL(SUBSTR(_XX,4,1))
			STR_NUM[30]:=VAL(SUBSTR(_XX,5,1))
			STR_NUM[31]:=VAL(SUBSTR(_XX,6,1))
			STR_NUM[32]:=VAL(SUBSTR(_XX,7,1))
			_XX:=SUBSTR(SE1->E1_NUMBCO,1,8)
			STR_NUM[33]:=VAL(SUBSTR(_XX,1,1))
			STR_NUM[34]:=VAL(SUBSTR(_XX,2,1))
			STR_NUM[35]:=VAL(SUBSTR(_XX,3,1))
			STR_NUM[36]:=VAL(SUBSTR(_XX,4,1))
			STR_NUM[37]:=VAL(SUBSTR(_XX,5,1))
			STR_NUM[38]:=VAL(SUBSTR(_XX,6,1))
			STR_NUM[39]:=VAL(SUBSTR(_XX,7,1))
			STR_NUM[40]:=VAL(SUBSTR(_XX,8,1))
			STR_NUM[41]:=4
			STR_NUM[42]:=0

			//-------------------------------------------- DIG MOD 10
			_AA1:=20
			_XX1:=0
			_BB1:=2
			Do While _AA1<=42
				_XX1:=_XX1+(STR_NUM[_AA1]*_BB1-IIF(STR_NUM[_AA1]*_BB1>9,9,0))
				If _BB1==1
					_BB1:=2
				Else
					_BB1:=1
				Endif
				_AA1:=_AA1+1
			EndDo
			If _XX1<10
				_YY:=_XX1
			Else
				_YY:=mod(_XX1,10)
			Endif
			If _YY==0
				_XX1:=0
			Else
				_XX1:=10-_YY
			Endif
			STR_NUM[43]:=_XX1

			//-------------------------------------------- DIG MOD 11
			_xx:=43
			_yy:=2
			_ZZ:=0
			Do While _XX>=20
				If _yy>7
					_YY:=2
				Endif
				_ZZ:=_ZZ+(STR_NUM[_xx]*_YY)
				_YY:=_YY+1
				_XX:=_XX-1
			EndDo
			If _ZZ<11
				_XX2:=_ZZ
			Else
				_XX2:=MOD(_ZZ,11)
			Endif
			If _XX2==1
				If STR_NUM[43]+1==10
					STR_NUM[43]:=0
				Else
					STR_NUM[43]:=STR_NUM[43]+1
				Endif
				_xx:=43
				_yy:=2
				_ZZ:=0
				Do While _XX>=20
					If _yy>7
						_YY:=2
					Endif
					_ZZ:=_ZZ+(STR_NUM[_xx]*_YY)
					_YY:=_YY+1
					_XX:=_XX-1
				EndDo
				If _ZZ<11
					_XX2:=_ZZ
				Else
					_XX2:=MOD(_ZZ,11)
				Endif
			Endif
			If _XX2<>0
				_XX2:=11-_XX2
			Endif
			STR_NUM[44]:=_XX2

			//--------------------------------- CALCULO DIGITO POS. 5
			_xx:=44
			_yy:=2
			_ZZ:=0
			Do While _XX<>0
				If _yy>9
					_YY:=2
				Endif
				If _XX==5
					_XX:=_XX-1
				Endif
				_ZZ:=_ZZ+(STR_NUM[_xx]*_YY)
				_YY:=_YY+1
				_XX:=_XX-1
			EndDo
			If _ZZ<11
				_DIG5:=_ZZ
			Else
				_DIG5:=MOD(_ZZ,11)
			Endif
			If _DIG5<>0
				_DIG5:=11-_DIG5
			Endif
			If _DIG5==10
				_DIG5:=1
			Endif
			If _DIG5==11
				_DIG5:=1
			Endif
			If _DIG5==0
				_DIG5:=1
			Endif
			STR_NUM[5]:=_DIG5

			//---------------------------------- DIGITO VERIFICADOR 1
			_XX:=(0*2)+(4*1)+(1*2)+(9*1)+(2*2)+(1*1)
			_XX:=_XX+VAL(SUBS(SEE->EE_AGENCIA,1,1))*2-IIF(VAL(SUBS(SEE->EE_AGENCIA,1,1))*2>9,9,0)
			_XX:=_XX+VAL(SUBS(SEE->EE_AGENCIA,2,1))*1-IIF(VAL(SUBS(SEE->EE_AGENCIA,2,1))*1>9,9,0)
			_XX:=_XX+VAL(SUBS(SEE->EE_AGENCIA,3,1))*2-IIF(VAL(SUBS(SEE->EE_AGENCIA,3,1))*2>9,9,0)
			If _XX<10
				_YY:=_XX
			Else
				_YY:=mod(_XX,10)
			Endif
			If _YY==0
				_XX:=0
			Else
				_XX:=10-_YY
			Endif

			//---------------------------------- DIGITO VERIFICADOR 2
			_XX1:=     VAL(SUBS(_cCedente,03,1))*2-IIF(VAL(SUBS(_cCedente,03,1))*2>9,9,0)
			_XX1:=_XX1+VAL(SUBS(_cCedente,04,1))*1-IIF(VAL(SUBS(_cCedente,04,1))*1>9,9,0)
			_XX1:=_XX1+VAL(SUBS(_cCedente,05,1))*2-IIF(VAL(SUBS(_cCedente,05,1))*2>9,9,0)
			_XX1:=_XX1+VAL(SUBS(_cCedente,06,1))*1-IIF(VAL(SUBS(_cCedente,06,1))*1>9,9,0)
			_XX1:=_XX1+VAL(SUBS(_cCedente,07,1))*2-IIF(VAL(SUBS(_cCedente,07,1))*2>9,9,0)
			_XX1:=_XX1+VAL(SUBS(_cCedente,08,1))*1-IIF(VAL(SUBS(_cCedente,08,1))*1>9,9,0)
			_XX1:=_XX1+VAL(SUBS(_cCedente,09,1))*2-IIF(VAL(SUBS(_cCedente,09,1))*2>9,9,0)
			_XX1:=_XX1+VAL(SUBS(_cCedente,10,2))*1-IIF(VAL(SUBS(_cCedente,10,1))*1>9,9,0)
			_XX1:=_XX1+VAL(Left(Substr(SE1->E1_NUMBCO,1,8),2))*2-IIF(VAL(Left(Substr(SE1->E1_NUMBCO,1,8),2))*2>9,9,0)

			/*	CAMPO 2:
			//	DDDDDD = Restante do Nosso Numero
			//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
			//	   FFF = Tres primeiros numeros que identificam a agencia
			//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
			s    := SUBSTR(_cNossoNum,3,6) + SUBSTR(_cNossoNum,9,1) + SUBSTR(cAgencia, 1, 3)
			dv   := modulo10(s)
			RN   := RN + SUBSTR(s, 1, 5) + '.' + SUBSTR(s, 6, 5) + AllTrim(Str(dv)) + '  '*/

			s := Substr(_cCedente,3,5)+Substr(_cCedente,8,3)+Left(Substr(SE1->E1_NUMBCO,1,8),2)
			_nDigito := Modulo10(s)

			If _XX1<10
				_YY:=_XX1
			Else
				_YY:=mod(_XX1,10)
			Endif
			If _YY==0
				_XX1:=0
			Else
				_XX1:=10-_YY
			Endif

			//---------------------------------- DIGITO VERIFICADOR 3
			_XX2:=     VAL(SUBS(SUBSTR(SE1->E1_NUMBCO,1,8),3,1))*1-IIF(VAL(SUBS(SUBSTR(SE1->E1_NUMBCO,1,8),3,1))*1>9,9,0)
			_XX2:=_XX2+VAL(SUBS(SUBSTR(SE1->E1_NUMBCO,1,8),4,1))*2-IIF(VAL(SUBS(SUBSTR(SE1->E1_NUMBCO,1,8),4,1))*2>9,9,0)
			_XX2:=_XX2+VAL(SUBS(SUBSTR(SE1->E1_NUMBCO,1,8),5,1))*1-IIF(VAL(SUBS(SUBSTR(SE1->E1_NUMBCO,1,8),5,1))*1>9,9,0)
			_XX2:=_XX2+VAL(SUBS(SUBSTR(SE1->E1_NUMBCO,1,8),6,1))*2-IIF(VAL(SUBS(SUBSTR(SE1->E1_NUMBCO,1,8),6,1))*2>9,9,0)
			_XX2:=_XX2+VAL(SUBS(SUBSTR(SE1->E1_NUMBCO,1,8),7,1))*1-IIF(VAL(SUBS(SUBSTR(SE1->E1_NUMBCO,1,8),7,1))*1>9,9,0)
			_XX2:=_XX2+VAL(SUBS(SUBSTR(SE1->E1_NUMBCO,1,8),8,1))*2-IIF(VAL(SUBS(SUBSTR(SE1->E1_NUMBCO,1,8),8,1))*2>9,9,0)
			_XX2:=_XX2+(4*1)+(0*2)
			_XX2:=_XX2+STR_NUM[43]*1-IIF(STR_NUM[43]*1>9,9,0)
			_XX2:=_XX2+STR_NUM[44]*2-IIF(STR_NUM[44]*2>9,9,0)
			If _XX2<10
				_YY:=_XX2
			Else
				_YY:=mod(_XX2,10)
			Endif
			If _YY==0
				_XX2:=0
			Else
				_XX2:=10-_YY
			Endif

			_xCodbar := "04192.1" + Substr(SEE->EE_AGENCIA,1,3) + Str(_XX,1,0) + "  "		
			_xCodbar += Substr(_cCedente,3,5)+"."+Substr(_cCedente,8,3)+Left(Substr(SE1->E1_NUMBCO,1,8),2)+Str(_nDigito,1,0)+"  "
			_xCodbar += Substr(Substr(SE1->E1_NUMBCO,1,8),3,5)+ "." + Substr(Substr(SE1->E1_NUMBCO,1,8),8,1)+ "40" +Str(STR_NUM[43],1,0)+Str(STR_NUM[44],1,0)+Str(_XX2,1,0)+"  "+STR(STR_NUM[5],1,0)+"  "		
			/*if SE1->E1_VENCTO >= CTOD("22/02/2025")  // Regra que verifica o fator de vencimento a partir de 2025
				_FV := str(SE1->E1_VENCTO - CtoD("22/02/2025") + 1000,4)
			else
				_FV := str(SE1->E1_VENCTO - ctod('07/10/1997'),4)
			endif
			_xCodbar += _FV + Strzero(SE1->E1_VALOR*100,10,0)*/
			_xCodbar += str(SE1->E1_VENCTO - ctod('07/10/1997'),4) + Strzero(SE1->E1_VALOR*100,10,0)

			_Flag1:=1
			_ccodbar:=""
			For I:=1 to 44
				_ccodbar:=_ccodbar+STR(STR_NUM[i],1,0)
			Next

		CASE SE1->E1_PORT2 == "001"       //Banco do Brasil
			i:=1
			Do While i<= 44
				STR_NUM[i] := 1
				i:=i+1
			EndDo
			/*if SE1->E1_VENCTO >= CTOD("22/02/2025")  // Regra que verifica o fator de vencimento a partir de 2025
				_XX := str(SE1->E1_VENCTO - CtoD("22/02/2025") + 1000,4)
			else
				_XX := str(SE1->E1_VENCTO - ctod('07/10/1997'),4)
			endif*/
			_XX := str(SE1->E1_VENCTO-ctod('07/10/1997'),4)
			STR_NUM[01]:=0
			STR_NUM[02]:=0
			STR_NUM[03]:=1
			STR_NUM[04]:=9                          // MOEDA
			STR_NUM[06]:= VAL(SUBSTR(_XX,01,1))     //Fator de vencimento
			STR_NUM[07]:= VAL(SUBSTR(_XX,02,1))     //Fator de vencimento
			STR_NUM[08]:= VAL(SUBSTR(_XX,03,1))     //Fator de vencimento
			STR_NUM[09]:= VAL(SUBSTR(_XX,04,1))     //Fator de vencimento
			_XX := strzero(SE1->E1_VALOR*100,10,0)
			STR_NUM[10]:= VAL(SUBSTR(_XX,01,1))    //Valor
			STR_NUM[11]:= VAL(SUBSTR(_XX,02,1))    //Valor
			STR_NUM[12]:= VAL(SUBSTR(_XX,03,1))    //Valor
			STR_NUM[13]:= VAL(SUBSTR(_XX,04,1))    //Valor
			STR_NUM[14]:= VAL(SUBSTR(_XX,05,1))    //Valor
			STR_NUM[15]:= VAL(SUBSTR(_XX,06,1))    //Valor
			STR_NUM[16]:= VAL(SUBSTR(_XX,07,1))    //Valor
			STR_NUM[17]:= VAL(SUBSTR(_XX,08,1))    //Valor
			STR_NUM[18]:= VAL(SUBSTR(_XX,09,1))    //Valor
			STR_NUM[19]:= VAL(SUBSTR(_XX,10,1))    //Valor
			STR_NUM[20]:= 0
			STR_NUM[21]:= 0
			STR_NUM[22]:= 0
			STR_NUM[23]:= 0
			STR_NUM[24]:= 0
			STR_NUM[25]:= 0
			_XX := SE1->E1_NUMBCO                  //Nosso Numero: 17 digitos
			STR_NUM[26]:=VAL(SUBSTR(_XX,01,1))
			STR_NUM[27]:=VAL(SUBSTR(_XX,02,1))
			STR_NUM[28]:=VAL(SUBSTR(_XX,03,1))
			STR_NUM[29]:=VAL(SUBSTR(_XX,04,1))
			STR_NUM[30]:=VAL(SUBSTR(_XX,05,1))
			STR_NUM[31]:=VAL(SUBSTR(_XX,06,1))
			STR_NUM[32]:=VAL(SUBSTR(_XX,07,1))
			STR_NUM[33]:=VAL(SUBSTR(_XX,08,1))
			STR_NUM[34]:=VAL(SUBSTR(_XX,09,1))
			STR_NUM[35]:=VAL(SUBSTR(_XX,10,1))
			STR_NUM[36]:=VAL(SUBSTR(_XX,11,1))
			STR_NUM[37]:=VAL(SUBSTR(_XX,12,1))
			STR_NUM[38]:=VAL(SUBSTR(_XX,13,1))
			STR_NUM[39]:=VAL(SUBSTR(_XX,14,1))
			STR_NUM[40]:=VAL(SUBSTR(_XX,15,1))
			STR_NUM[41]:=VAL(SUBSTR(_XX,16,1))
			STR_NUM[42]:=VAL(SUBSTR(_XX,17,1))
			STR_NUM[43]:=VAL(SUBSTR(SA6->A6_CARTEIR,01,1)) // conforme email clailton 04/01/16    carteia    //	 //Nosso Numero
			STR_NUM[44]:=VAL(SUBSTR(SA6->A6_CARTEIR,02,1)) // conforme email clailton 04/01/16    carteira   //	 //Nosso Numero

			//--------------------------------- CALCULO DIGITO POS. 5
			_xx := 44                             //44 digitos do codigo de barras
			_yy := 2
			_zz := 0

			Do While _xx <> 0                     //multiplicar  cada algrismo que compoe o numero pelo seu respectivo multiplicador (peso)
				If _yy > 9                         //iniciando-se pelas 44 posição e seltando a 5. os multiplicadores variam de 2 a 9
					_yy := 2                        //o primeiro digito da esquerda deverá ser multiplicado por 2, o segundo por 3 e assim por diante
				Endif

				If _xx == 5
					_xx :=_xx - 1
				Endif

				_zz := _zz + (STR_NUM[_xx] * _yy)      //nessa linha o resultado das multiplicações vai sendo somado
				_yy := _yy + 1
				_xx := _xx - 1
			EndDo

			//o total deve ser dividido por 11, então ele verifica: se for menor que 11, fica com o 11
			If _zz < 11
				_DIG5 := _zz
			Else
				_DIG5 := MOD(_zz,11)
			Endif

			//o resto da divisão deve ser substraído de 11
			If _DIG5 <> 0
				_DIG5 := 11 - _DIG5
			Endif

			//se ficar 2 casas vai ser 1
			If _DIG5 == 10
				_DIG5 := 1
			Endif

			//se ficar 2 casas vai ser 1
			If _DIG5 == 11
				_DIG5 := 1
			Endif

			//se ficar 0 vai ser 1
			If _DIG5 == 0
				_DIG5 := 1
			Endif

			STR_NUM[5] := _DIG5

			//-------------------------------------------- DIG MOD 10  (_nDv01)
			_nDv01 := 0
			_Vlr   := 0
			_Str   := ''
			_nDez  := 0
			_cDez  := ''

			_lFlag := .t.

			For I := 1 to 24
				If (I <= 4) .or. (I >= 20 .and. I <= 24)
					If _lFlag                   //Se o flag for positivo
						_nVlr := STR_NUM[I] * 2 //multiplica por dois
						If _nVlr >= 10          //se for maior ou igual a 10 soma os algarismos
							_Str := str(_nVlr,2)
							_nDv01 += (val(substr(_Str,1,1)) + val(substr(_Str,2,1)))
						Else                   //se não for maior ou igual a 10
							_nDv01 += _nVlr	   //apenas soma
						Endif
						_lFlag := !(_lFlag)    //inverte o flag para multiplicar por 1
					Else                       //Senão, se o flag for negativo faz o mesmo que o bloco de cima, mas multiplicado por 1
						_nVlr := STR_NUM[I] * 1
						If _nVlr >= 10
							_Str := str(_nVlr,2)
							_nDv01 += (val(substr(_Str,1,1)) + val(substr(_Str,2,1)))
						Else
							_nDv01 += _nVlr
						Endif
						_lFlag := !(_lFlag)
					Endif
				Endif
			Next
			_nDez  := _nDv01 + 10
			_nDez  := round(_nDez / 10,0)
			_cDez  := str(_nDez,1)+'0'
			_nDez  := VAL(_cDez)

			_nDv01 := _nDez - MOD(_nDv01,10)
			If _nDv01 > 10
				_Str   := substr(str(_nDv01,2),2,1)
				_nDv01 := val(_Str)
			Endif
			If _nDv01 = 10
				_nDv01 := 0
			Endif

			//-------------------------------------------- DIG MOD 10  (_nDv02)
			_nDv02 := 0
			_Vlr   := 0
			_Str   := ''
			_nDez  := 0
			_cDez  := ''

			_lFlag := .t.

			For I := 25 to 34
				If _lFlag                   //Se o flag for positivo
					_nVlr := STR_NUM[I] * 1 //multiplica por um
					If _nVlr >= 10          //se for maior ou igual a 10 soma os algarismos
						_Str := str(_nVlr,2)
						_nDv02 += (val(substr(_Str,1,1)) + val(substr(_Str,2,1)))
					Else                   //se não for maior ou igual a 10
						_nDv02 += _nVlr	   //apenas soma
					Endif
					_lFlag := !(_lFlag)    //inverte o flaga para multiplicar por 2
				Else                       //Senão, se o flag for negativo faz o mesmo que o bloco de cima, mas multiplicado por 1
					_nVlr := STR_NUM[I] * 2
					If _nVlr >= 10
						_Str := str(_nVlr,2)
						_nDv02 += (val(substr(_Str,1,1)) + val(substr(_Str,2,1)))
					Else
						_nDv02 += _nVlr
					Endif
					_lFlag := !(_lFlag)
				Endif
			Next

			_nDez  := _nDv02 + 10
			_nDez  := round(_nDez / 10,0)
			_cDez  := str(_nDez,1)+'0'
			_nDez  := VAL(_cDez)

			_nDv02 := _nDez - MOD(_nDv02,10)
			If _nDv02 > 10
				_Str   := substr(str(_nDv02,2),2,1)
				_nDv02 := val(_Str)
			Endif
			If _nDv02 = 10
				_nDv02 := 0
			Endif

			//-------------------------------------------- DIG MOD 10  (_nDv03)
			_nDv03 := 0
			_Vlr   := 0
			_Str   := ''
			_nDez  := 0
			_cDez  := ''

			_lFlag := .t.

			For I := 35 to 44
				If _lFlag                   //Se o flag for positivo
					_nVlr := STR_NUM[I] * 1 //multiplica por um
					If _nVlr >= 10          //se for maior ou igual a 10 soma os algarismos
						_Str := str(_nVlr,2)
						_nDv03 += (val(substr(_Str,1,1)) + val(substr(_Str,2,1)))
					Else                   //se não for maior ou igual a 10
						_nDv03 += _nVlr	   //apenas soma
					Endif
					_lFlag := !(_lFlag)    //inverte o flaga para multiplicar por 2
				Else                       //Senão, se o flag for negativo faz o mesmo que o bloco de cima, mas multiplicado por 1
					_nVlr := STR_NUM[I] * 2
					If _nVlr >= 10
						_Str := str(_nVlr,2)
						_nDv03 += (val(substr(_Str,1,1)) + val(substr(_Str,2,1)))
					Else
						_nDv03 += _nVlr
					Endif
					_lFlag := !(_lFlag)
				Endif
			Next

			_nDez  := _nDv03 + 10
			_nDez  := round(_nDez / 10,0)
			_cDez  := str(_nDez,1)+'0'
			_nDez  := VAL(_cDez)

			_nDv03 := _nDez - MOD(_nDv03,10)
			If _nDv03 > 10
				_Str   := substr(str(_nDv03,2),2,1)
				_nDv03 := val(_Str)
			Endif
			If _nDv03 = 10
				_nDv03 := 0
			Endif

			//Campo 1
			_xCodbar := STR(STR_NUM[01],1,0) + STR(STR_NUM[02],1,0) + STR(STR_NUM[03],1,0) + STR(STR_NUM[04],1,0) + STR(STR_NUM[20],1,0) + "."
			_xCodBar += STR(STR_NUM[21],1,0) + STR(STR_NUM[22],1,0) + STR(STR_NUM[23],1,0) + STR(STR_NUM[24],1,0) + STR(_nDv01 ,1,0) + '  '
			//Campo 2
			_xCodbar += STR(STR_NUM[25],1,0) + STR(STR_NUM[26],1,0) + STR(STR_NUM[27],1,0) + STR(STR_NUM[28],1,0) + STR(STR_NUM[29],1,0) + "."
			_xCodbar += STR(STR_NUM[30],1,0) + STR(STR_NUM[31],1,0) + STR(STR_NUM[32],1,0) + STR(STR_NUM[33],1,0) + STR(STR_NUM[34],1,0) + STR(_nDv02,1,0)
			_xCodBar += '  '
			//Campo 3
			_xCodbar += STR(STR_NUM[35],1,0) + STR(STR_NUM[36],1,0) + STR(STR_NUM[37],1,0) + STR(STR_NUM[38],1,0) + STR(STR_NUM[39],1,0) + "."
			_xCodbar += STR(STR_NUM[40],1,0) + STR(STR_NUM[41],1,0) + STR(STR_NUM[42],1,0) + STR(STR_NUM[43],1,0) + STR(STR_NUM[44],1,0) + STR(_nDv03,1,0)
			_xCodBar += '  '
			//Campo 4
			_xCodBar += STR(STR_NUM[5],1,0) + '  '
			//Campo 5
			_xCodbar += STR(STR_NUM[06],1,0) + STR(STR_NUM[07],1,0) + STR(STR_NUM[08],1,0) + STR(STR_NUM[09],1,0)
			_xCodBar += STR(STR_NUM[10],1,0) + STR(STR_NUM[11],1,0) + STR(STR_NUM[12],1,0) + STR(STR_NUM[13],1,0) + STR(STR_NUM[14],1,0)
			_xCodBar += STR(STR_NUM[15],1,0) + STR(STR_NUM[16],1,0) + STR(STR_NUM[17],1,0) + STR(STR_NUM[18],1,0) + STR(STR_NUM[19],1,0)

			//Aqui forma o string com o codigo de barras a ser impresso
			_ccodbar:=""
			For I := 1 to 44
				_ccodbar := _ccodbar + str(STR_NUM[i],1,0)
			Next

		OTHERWISE
			If SE1->E1_PORT2 <> "099"
				MsgBox("Banco / Tipo Formulario Nao Disponivel!","ML_ERRO","STOP")
			Endif
	ENDCASE

	// _ccodbar -> codigo de barra impresso
	// _XCODBAR -> linha digitavel impressa
	DbSelectArea("SE1")
	RecLock("SE1",.F.)
	SE1->E1_CODBAR := _cCodbar
	SE1->E1_CODDIG := _xCodbar
	MsUnlock()

Return({_ccodbar,_xCODBAR})


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao NOSSONUM()                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function NOSSONUM()

	DbSelectArea("SE1")
	RecLock("SE1",.F.)
	DO CASE
		CASE SE1->E1_PORT2 == "041"                 //Banrisul
			_char2 := StrZero(_NumBco,08,0)
			Z_DVBCO()
			SE1->E1_NUMBCO := StrZero(_NumBco,08,0)+"-"+_char2
			_NumBco := _NumBco + 1

		CASE SE1->E1_PORT2 == "001"                //Banco do Brasil
			NN_BB := ARRAY(11) //{0,0,0,0,0,0,0,0,0,0,0}  //ARRAY[11]
			NNxBB := ARRAY(11) //{0,0,0,0,0,0,0,0,0,0,0}  //ARRAY[11]

			_xNumBco := alltrim(SEE->EE_CODEMP) + strzero(_NumBco,10,0)

			SE1->E1_NUMBCO := _xNumBco
			_NumBco := _NumBco + 1
	ENDCASE

	SE1->E1_PORT2  := SE1->E1_PORT2
	SE1->E1_BOLIMP := "S"
	MsUnlock()

	DbSelectArea("SEE")
	RecLock("SEE",.F.)
	SEE->EE_BOLATU:=_NumBco
	MsUnlock()

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao Z_DVBCO()                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Syntax: Z_DVBCO( <expC1>,<expC2> )  && cod. banco e Nosso Numero
// Return: Retorna <expN1> - Retorna Digito Verificador p/ Banco
Static Function Z_DVBCO()

	DO CASE
		CASE SE1->E1_PORT2=="041"    // P/ BANRISUL
			_num3 := (val(subs(_char2,1,1)) * 1) - IIF(val(subs(_char2,1,1)) * 1 >9,9,0) +;
					(val(subs(_char2,2,1)) * 2) - IIF(val(subs(_char2,2,1)) * 2 >9,9,0) +;
					(val(subs(_char2,3,1)) * 1) - IIF(val(subs(_char2,3,1)) * 1 >9,9,0) +;
					(val(subs(_char2,4,1)) * 2) - IIF(val(subs(_char2,4,1)) * 2 >9,9,0) +;
					(val(subs(_char2,5,1)) * 1) - IIF(val(subs(_char2,5,1)) * 1 >9,9,0)
					_num3:=_num3+ (val(subs(_char2,6,1)) * 2) - IIF(val(subs(_char2,6,1)) * 2 >9,9,0) +;
					(val(subs(_char2,7,1)) * 1) - IIF(val(subs(_char2,7,1)) * 1 >9,9,0) +;
					(val(subs(_char2,8,1)) * 2) - IIF(val(subs(_char2,8,1)) * 2 >9,9,0)

			If _num3<10
				_num2:=_num3
			Else
				_num2 := mod(_num3,10)
			Endif

			If _num2 == 0
				_num4 := 0
			Else
				_num4 := 10 - _num2
			Endif

			_char2 := _char2+str(_num4,1)
			_num3 := (val(subs(_char2,1,1)) * 4) +;
					(val(subs(_char2,2,1)) * 3) + (val(subs(_char2,3,1)) * 2) +;
					(val(subs(_char2,4,1)) * 7) + (val(subs(_char2,5,1)) * 6) +;
					(val(subs(_char2,6,1)) * 5) + (val(subs(_char2,7,1)) * 4) +;
					(val(subs(_char2,8,1)) * 3) + (val(subs(_char2,9,1)) * 2)

			If _num3<11
				_num2:=_num3
			Else
				_num2 := mod(_num3,11)
			Endif

			If _num2 == 1
				If VAL(RIGHT(_CHAR2,1))+1==10
					_CHAR2:=LEFT(_CHAR2,8)+"0"
				Else
					_CHAR2:=LEFT(_CHAR2,8)+STR(VAL(RIGHT(_CHAR2,1))+1,1)
				Endif
				_num3 := (val(subs(_char2,1,1)) * 4) +;
						(val(subs(_char2,2,1)) * 3) + (val(subs(_char2,3,1)) * 2) +;
						(val(subs(_char2,4,1)) * 7) + (val(subs(_char2,5,1)) * 6) +;
						(val(subs(_char2,6,1)) * 5) + (val(subs(_char2,7,1)) * 4) +;
						(val(subs(_char2,8,1)) * 3) + (val(subs(_char2,9,1)) * 2)
				If _num3<11
					_num2:=_num3
				Else
					_num2 := mod(_num3,11)
				Endif
			Endif

			If _num2 == 0
				_num4 := 0
			Else
				_num4 := 11 - _num2
			Endif

			_char2 := right(_char2,1)+str(_num4,1)
	ENDCASE

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHAMADA DA FUNCAO RET_CBARRA()                                  ³
//³ Retorna os strings para inpressão do Boleto                     ³
//³ CB = String para o cód.barras, RN=String com o número digitável ³
//³ Cobrança não identificada, número do boleto = Título + Parcela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,dvencimento,cConvenio,cSequencial,_lTemDesc,_cParcela,_cAgCompleta)

	//Local cCodEmp      := StrZero(Val(SubStr(cConvenio,1,6)),6)
	//Local cNumSeq      := Strzero(val(cSequencial),5)
	//Local bldocnufinal := cAgencia+Strzero(val(cNroDoc),7)
	Local blvalorfinal := Strzero(nValor*100,10)
	Local cNNumSDig    := cCpoLivre := cCBSemDig := cCodBarra := cNNum := cFatVenc := ''
	Local cNossoNum
	//Local _cDigito     := ""
	//Local _cSuperDig   := ""

	_cParcela := NumParcela(_cParcela)
	If dvencimento >= CTOD("22/02/2025")  // Regra que verifica o fator de vencimento a partir de 2025 
		// 22/02/2025 = Fator 1000 
		// 23/02/2025 = Fator 1001 
		cFatVenc := STRZERO(dvencimento - CtoD("22/02/2025") + 1000,4)  // acha a diferenca em dias para o fator de vencimento
	Else 
		cFatVenc := STRZERO(dvencimento - CtoD("07/10/1997"),4)			// acha a diferenca em dias para o fator de vencimento
	Endif
	//cFatVenc  := STRZERO(dvencimento - CtoD("07/10/1997"),4)                    // Fator Vencimento - POSICAO DE 06 A 09

	//Campo Livre (Definir campo livre com cada banco)
	cNNumSDig := Strzero(cSequencial,12)                                          // Nosso Numero sem digito
	cNNum     := cNNumSDig + modulo11(cNNumSDig,SubStr(cBanco,1,3))                    // Nosso Numero
	cNossoNum := cNNumSDig + "-"+ modulo11(cNNumSDig,SubStr(cBanco,1,3))               // Nosso Numero para impressao
	cCpoLivre := "9"+Strzero(Val(SubStr(cConvenio,1,7)),7)+cNNum+"0"+"101"

	cCBSemDig := cBanco + cFatVenc + blvalorfinal + cCpoLivre                                                // Dados para Calcular o Dig Verificador Geral
	cCodBarra := cBanco + Modulo11(cCBSemDig,SubStr(cBanco,1,3)) + cFatVenc + blvalorfinal + cCpoLivre       // Codigo de Barras Completo

	cPrCpo   := cBanco+"9"+SubStr(cCodBarra,21,4)                                         // Digito Verificador do Primeiro Campo
	cDvPrCpo := AllTrim(Str(Modulo10(cPrCpo)))

	cSgCpo   := SubStr(cCodBarra,25,10)                                                   // Digito Verificador do Segundo Campo
	cDvSgCpo := AllTrim(Str(Modulo10(cSgCpo)))

	cTrCpo   := SubStr(cCodBarra,35,10)                                                   // Digito Verificador do Terceiro Campo
	cDvTrCpo := AllTrim(Str(Modulo10(cTrCpo)))

	cDvGeral := SubStr(cCodBarra,5,1)                                                     // Digito Verificador Geral do Quarto Campo

	cQrCpo   := SubStr(cCodBarra,06,14)                                                   // Digito Verificador do Quinto Campo
	cDvQrCpo := AllTrim(Str(Modulo10(cQrCpo)))

	//Linha Digitavel
	cLinDig := SubStr(cPrCpo,1,09) + "." + cDvPrCpo + " "                                 // Primeiro campo
	cLinDig += SubStr(cSgCpo,1,10) + "." + cDvSgCpo + " "                                 // Segundo campo
	cLinDig += SubStr(cTrCpo,1,10) + "." + cDvTrCpo + " "                                 // Terceiro campo
	cLinDig += cDvGeral + " "                                                             // Dig verificador geral Quarto campo
	cLinDig += SubStr(cQrCpo,1,14)                                                        // Quinto campo

	//MsgAlert("Cod. Barra = "+cCodBarra+CHR(13)+CHR(13)+"Linha Digitavel = "+cLinDig+CHR(13)+CHR(13)+"Nosso Numero = "+cNossoNum)

Return ({cCodBarra,cLinDig,cNossoNum})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHAMADA DA FUNCAO NUMPARCELA()                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function NumParcela(_cParcela)
	Local _cRet := ""
	If ASC(_cParcela) >= 65 .Or. ASC(_cParcela) <= 90
		_cRet := StrZero(Val(Chr(ASC(_cParcela)-16)),2)
	Else
		_cRet := StrZero(Val(_cParcela),2)
	Endif
Return(_cRet)
