#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} BOLLSR3
@Type			: Função de Usuário
@Sample			: U_BOLLSR3()
@Description	: Rotina de impressão de boletos bancários
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Ago/2024
@version		: Protheus 12.1.2210 e posteriores
@Comments		: Convertido do BOLLSR2 para ser impresso em meia página
/*/
//--------------------------------------------------------------------------------------
User Function BOLLSR3()

	Private lExec := .F.

	// VERIFICA SE TEM ALGUM USUÁRIO JÁ UTILIZANDO A ROTINA E NÃO DEIXA ACESSAR
	
	// Função utilizada para criar um semáforo no servidor de licenças ou em disco
	// A LockByName trabalha em conjunto com a chave SpecialKey, que pode ser informada no arquivo de configuração do servidor no ambiente corrente, para distinguir os diversos ambientes (produção e homologação)
	// Em versões que não possuem Servidor de Licenças o semáforo é criado automaticamente em disco
	If !LockByName('BOLLSR3', .F., .F.)		// Lock no ambiente inteiro, pois não considera empresa nem filial
		FWAlertInfo("Tente novamente mais tarde.", "Esta rotina já está sendo utilizada por outra sessão !!!")
		Return
	EndIf

	cPerg := "BOLLSR"
	Pergunte(cPerg, .F.)    // Pergunta no SX1

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
	If Pergunte(cPerg, .T.)
		_cBanco   := ''
		_cCodCed  := ''
		_cBmpLogo := ''
		_cAgencia := ''

		DbSelectArea('SA6')
		SA6->(DbSetOrder(1))
		SA6->(MsSeek(FWxFilial('SA6') + mv_par05))
		While SA6->(!Eof()) .And. SA6->A6_FILIAL + SA6->A6_COD == FWxFilial('SA6') + mv_par05

			If SA6->A6_PORTBOL == 'S'
				_cBanco   := SA6->A6_COD
				_cCodCed  := SA6->A6_CEDBOL
				_cBmpLogo := SA6->A6_BMPBOL
				_cAgencia := SA6->A6_AGENCIA
				Exit
			Endif

			SA6->(DbSkip())
		EndDo

		If Empty(_cBanco) .or. Empty(_cCodCed)
			MsgBox("Banco ainda não liberado ou campos não preenchidos em seu cadastro!","ATENÇÃO!!!","STOP")
			Return
		Endif

		If cEmpAnt == "01"
			_cCedente := "350050622178"
		ElseIf cEmpAnt == "08"
			_cCedente := "350132927074"
		Else
			MsgBox("Empresa sem CEDENTE para impressão de boletos. Favor contactar DTI.","ATENÇÃO!!!","STOP")
			Return
		EndIf

		cIndexName := Criatrab(Nil,.F.)
		cIndexKey  := "E1_PREFIXO + E1_NUM + E1_PARCELA + DTOS(E1_EMISSAO)"
		cFilter    := "E1_PREFIXO >= '" + MV_PAR01 + "' .And. E1_PREFIXO <= '" + MV_PAR02 + "' .And. " + ;
					  "E1_NUM >= '" + MV_PAR03 + "' .And. E1_NUM <= '" + MV_PAR04 + "' .And. " + ;
					  "(E1_PORT2 = '" + _cBanco + "' .or. Empty(E1_PORT2)) .And. " + ;
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

//-----------------------------------------------------------------------
/*/{Protheus.doc} MontaRel
Função de montagem do relatório
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function MontaRel(aMarked)

	Local nX := 0
	Local nI := 1
	Local cAlias  := GetNextAlias()
	Local cArqPDF := "boletos" + cAlias
	Local cPath   := "C:\Temp\"

	Local aDadosEmp := {SM0->M0_NOMECOM                                                            ,; // Nome da Empresa
						SM0->M0_ENDENT                                                             ,; // Endereço
						AllTrim(SM0->M0_BAIRENT)+",  "+AllTrim(SM0->M0_CIDENT)+", "+SM0->M0_ESTENT ,; // Complemento
						"CEP: "+Subs(SM0->M0_CEPENT,1,5)+"-"+Subs(SM0->M0_CEPENT,6,3)              ,; // CEP
						"FONE: "+SM0->M0_TEL                                                       ,; // Telefones
						Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+               			; // CNPJ
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

	Private oPrn

	// Verificar se o arquivo já existe, se existir excluir para garantir que não seja utilizado um arquivo gerado anteriormente
	If File(cPath + cArqPDF + ".pdf")
		FErase(cPath + cArqPDF + ".pdf")
	EndIf

	oPrn := FWMSPrinter():New(cArqPDF, IMP_PDF, .F.,, .T., , , , , , .F., )	
	oPrn:cPathPDF := cPath
	oPrn:SetResolution(78) 
	oPrn:SetPortrait()
	oPrn:SetPaperSize(DMPAPER_A4)
	oPrn:SetMargin(60,60,60,60)	

	PixelX  := oPrn:nLogPixelX()
	PixelY  := oPrn:nLogPixelY()

	If MV_PAR06 == 2		// Papel de Impressão A4
		_lQuebraPag := .F.
	Else					// Papel de Impressão A5
		_lQuebraPag := .T.
	EndIf
	_zTitulo := "############"
	_nVez    := 1
	
	DbSelectArea("SE1")
	Do While !Eof()
		_cTitulo := SE1->E1_PREFIXO + SE1->E1_NUM

		DbSelectArea("SA1")
		DbSetOrder(1)
		MsSeek(FWxFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
		If !Found()
			MsgBox("Atenção! Cliente "+SE1->E1_CLIENTE+"/"+SE1->E1_LOJA+" Não Cadastrado." ,"ML_ERRO","STOP")
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
			MsgBox("Atenção! Não Encontrado Dados Parametros Bancos CNAB "+SE1->E1_PORT2,"ML_ERRO","STOP")
			DbSelectArea("SE1")
			DbSkip()
			Loop
		Endif

		If _NumBco < SEE->EE_BOLINI .Or. _NumBco > SEE->EE_BOLFIN
			MsgBox("Atenção! InterValo Seq. Boleto Inválida Banco "+SE1->E1_PORT2,"ML_ERRO","STOP")
			DbSelectArea("SE1")
			DbSkip()
			Loop
		Endif

		If SE1->E1_BOLIMP == "S"
			If MsgYesNo("Boleto "+ALLTRIM(SE1->E1_NUMBCO)+" Título "+SE1->E1_NUM+" Já Impresso. Confirma Reimpressao?")
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
			CASE _cBanco == '001'
				_cNumTit  := SE1->(E1_NUM+E1_PARCELA)
				_cAgen    := AllTrim(SA6->A6_AGENCIA)+'-'+SA6->A6_DVAGE
				_cAgenCed := Substr(SA6->A6_AGEBOL,1,4)+'-'+SA6->A6_DVAGE
				_cParcTit := SE1->E1_PARCELA
			CASE _cBanco == '041'
				_cNumTit  := SE1->E1_NUM+" "+SE1->E1_PARCELA
				_cAgen    := SA6->A6_AGENCIA
				_cAgenCed := SA6->A6_AGEBOL
				_cParcTit := SE1->E1_PARCELA
			CASE _cBanco == '033'
				_cNumTit  := SE1->E1_NUM+" "+SE1->E1_PARCELA
				_cAgen    := SA6->A6_AGENCIA
				_cAgenCed := SA6->A6_AGEBOL
				_cParcTit := SE1->E1_PARCELA
		ENDCASE

		If cEmpAnt == "01"
			aDadosBanco := {SA6->A6_COD_BC     ,;             // Numero do Banco
							SA6->A6_NREDUZ     ,;             // Nome do Banco
							_cAgen             ,;
							SA6->A6_NUMCON     ,;             // Conta Corrente
							SA6->A6_CARTEIR    ,;             // Codigo Carteira
							_cAgenCed          ,;             // Agencia Beneficiário  A6_AGEBOL
							SA6->A6_CEDBOL		}			  // Codigo Beneficiário
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

		// ValOR DOS TITULOS TIPO "AB-"
		_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

		If Empty(SE1->E1_NUMBCO)
			If _cBanco == '033'
				CB_RN := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",Subs(aDadosBanco[3],1,4),aDadosBanco[4],aDadosBanco[5],aDadosBanco[6],AllTrim(E1_NUM)+AllTrim(E1_PARCELA),;
										(E1_SALDO-_nVlrAbat-E1_DECRESC),SE1->E1_VENCTO,SEE->EE_CODEMP,SEE->EE_BOLATU,Iif(SE1->E1_DECRESC > 0,.t.,.f.),SE1->E1_PARCELA,aDadosBanco[3])
			Endif
		Else
			cCodBarra := SE1->E1_CODBAR
			cLinDig   := SE1->E1_CODDIG
			cNossoNum := SE1->E1_NUMBCO
			CB_RN  	  := {cCodBarra,cLinDig,cNossoNum}
		Endif

		If _cBanco == '033'
			If Empty(SE1->E1_NUMBCO)
				DbSelectArea("SEE")
				RecLock("SEE",.F.)
				SEE->EE_BOLATU := SEE->EE_BOLATU + 1     			// INCREMENTA P/ TODOS OS BANCOS
				MsUnlock()

				DbSelectArea("SE1")
				RecLock("SE1",.F.)
				SE1->E1_CODBAR := CB_RN[1]                        	// GRAVA CODIGO DE BARRAS CALCULADO NO TITULO
				SE1->E1_CODDIG := CB_RN[2]                          // GRAVA LINHA DIGITAVEL CALCULADA NO TITULO
				SE1->E1_NUMBCO := CB_RN[3]                          // GRAVA NOSSO NUMERO NO TITULO
				SE1->E1_BOLIMP := "S"
				MsUnlock()
			Endif
		Endif

		aDadosTit := {_cNumTit                		,;        // Número do título
					  SE1->E1_EMISSAO         		,;        // Data da emissão do título
					  Date()                  		,;        // Data da emissão do boleto
					  SE1->E1_VENCTO          		,;        // Data do vencimento
					  SE1->E1_VALOR           		,;        // Valor do título
					  ALLTRIM(SE1->E1_NUMBCO) 		,;        // Nosso número (Ver fórmula para calculo)
					  SE1->E1_VALJUR          		,;        // Valor dos juros diários
					  NoRound(SE1->E1_VLRAPEL,2)	,;        // Valor dos descontos financeiros p/ grandes redes (ALTERADO PARA DESCONTO RAPEL EM 01/05/2013)
					  _cParcTit						 }		  // Parcela do Título
		If Marked("E1_OK")

			If MV_PAR06 == 2		// Papel de Impressão A4
				// Efetua tratamentos e validações para quebra de página em papel A4
				If _zTitulo <> _cTitulo .And. Empty(SE1->E1_PARCELA)
					_lQuebraPag := .T.
					_nVez := 0
				ElseIf _zTitulo <> _cTitulo .And. !Empty(SE1->E1_PARCELA)
					If _nVez == 1
						_lQuebraPag := .T.
					ElseIf _nVez == 2
						_lQuebraPag := .F.
						_nVez := 0
					EndIf
				ElseIf _zTitulo == _cTitulo .And. !Empty(SE1->E1_PARCELA)
					If _nVez == 2
						_lQuebraPag := .F.
						_nVez := 0
					Else
						_lQuebraPag := .T.
						_nVez := 0
					EndIf
				Else
				EndIf
				_zTitulo := _cTitulo
				_nVez := _nVez+1
			Else					// Papel de Impressão A5
				_lQuebraPag := .T.
			EndIf

			Impress(oPrn,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,_lQuebraPag)
			nX := nX + 1
		Endif

		nI := nI + 1
		DbSelectArea("SE1")
		DbSkip()
	EndDo

	oPrn:EndPage()      // Finaliza a página
	oPrn:Preview()    	// Visualiza antes de imprimir
	FreeObj(oPrn)		// Finalizar o Objeto do Boleto PDF

	DbSelectArea("SE1")
	RetIndex("SE1")

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} Impress
Função de impressão do boleto
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function Impress(oPrn,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,_lQuebraPag)
	
	Local HMARGEM := 070
	Local NLINHA1 := IIF(_lQuebraPag, 000, 455)
	Local NLINBAR := IIF(_lQuebraPag, 34.1, 72.4)

	STR_NUM := ARRAY(99)	//{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}  //ARRAY[99]
	AFILL(STR_NUM,0)
	_XXA := ARRAY(5) 		//{0,0,0,0,0}
	_XXB := ARRAY(5) 		//{0,0,0,0,0}
	AFILL(_XXA,"A")
	AFILL(_XXB,"A")

	If _cBanco <> "033"
		CB_RN := CODIGOBARRAS(aDadosBanco[1],aDadosBanco[3])
	Endif
	
	oFont07    := TFont():New("Arial", ,-06,.F.,.T.)
	oFont10    := TFont():New("Arial", ,-09,.F.,.T.)
	oFont12    := TFont():New("Arial", ,-11,.F.,.T.)
	oFont12N   := TFont():New("Arial", ,-11,.T.,.T.)
	oFont14N   := TFont():New("Arial", ,-12,.T.,.T.)
	oFont15N   := TFont():New("Arial", ,-15,.T.,.F.)
	oFont16    := TFont():New("Courier new", ,-16,.T.)
	oFont18N   := TFont():New("Arial", ,-17,.T.,.T.)
	oFont24N   := TFont():New("Arial Black", ,-24,.T.,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ INICIA UMA NOVA PÁGINA                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _lQuebraPag
		oPrn:StartPage()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DESENHA O RECIBO DO PAGADOR                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _lQuebraPag
		oPrn:Box(NLINHA1+HMARGEM-20,030,028,144)
		oPrn:Box(NLINHA1+HMARGEM   ,030,048,144)
		oPrn:Box(NLINHA1+HMARGEM   ,030,091,144)
		
		oPrn:Box(NLINHA1+HMARGEM-20,144,028,289)
		oPrn:Box(NLINHA1+HMARGEM   ,144,048,433)
		oPrn:Box(NLINHA1+HMARGEM   ,144,091,289)

		oPrn:Box(NLINHA1+HMARGEM-22,289,028,433)
		oPrn:Box(NLINHA1+HMARGEM   ,289,091,433)

		oPrn:Box(NLINHA1+HMARGEM-20,433,028,578)
		oPrn:Box(NLINHA1+HMARGEM   ,433,048,578)
		oPrn:Box(NLINHA1+HMARGEM   ,433,091,578)
	Else
		oPrn:Say(NLINHA1-11,030, Replicate("-",177), oFont12)		// Pontilhado do meio da página A4

		oPrn:Box(NLINHA1+HMARGEM-20,030,NLINHA1+028,144)
		oPrn:Box(NLINHA1+HMARGEM   ,030,NLINHA1+048,144)
		oPrn:Box(NLINHA1+HMARGEM   ,030,NLINHA1+091,144)

		oPrn:Box(NLINHA1+HMARGEM-20,144,NLINHA1+028,289)
		oPrn:Box(NLINHA1+HMARGEM   ,144,NLINHA1+048,433)
		oPrn:Box(NLINHA1+HMARGEM   ,144,NLINHA1+091,289)

		oPrn:Box(NLINHA1+HMARGEM-22,289,NLINHA1+028,433)
		oPrn:Box(NLINHA1+HMARGEM   ,289,NLINHA1+091,433)

		oPrn:Box(NLINHA1+HMARGEM-20,433,NLINHA1+028,578)
		oPrn:Box(NLINHA1+HMARGEM   ,433,NLINHA1+048,578)
		oPrn:Box(NLINHA1+HMARGEM   ,433,NLINHA1+091,578)
	EndIf

	// Logo do Banco
	oPrn:SayBitmap(NLINHA1+001, 030, aBitmap[1], 090, 020)

	// Banco
	oPrn:Say(NLINHA1+021,130, " | " + aDadosBanco[1] + " | "									, oFont18N)
	oPrn:Say(NLINHA1+021,488, "Recibo do Pagador"												, oFont12N)

	// Títulos e dados da primeira linha de boxes
	oPrn:Say(NLINHA1+034,032, "Vencimento"														, oFont07)
	oPrn:Say(NLINHA1+046,035, FormDate(aDadosTit[4],.T.)										, oFont12)

	oPrn:Say(NLINHA1+034,146, "Agência/Código do Beneficiario"									, oFont07)
	oPrn:Say(NLINHA1+046,149, Alltrim(aDadosBanco[6])+"/"+aDadosBanco[7]						, oFont12)

	oPrn:Say(NLINHA1+034,291, "Nro. Documento"													, oFont07)
	oPrn:Say(NLINHA1+046,294, aDadosTit[1] 														, oFont12)

	oPrn:Say(NLINHA1+034,435, "Nosso Número"													, oFont07)
	oPrn:Say(NLINHA1+046,438, aDadosTit[6]														, oFont12)

	// Títulos e dados da segunda linha de boxes
	oPrn:Say(NLINHA1+054,032, "Espécie"															, oFont07)
	oPrn:Say(NLINHA1+066,035, "R$"																, oFont12)

	oPrn:Say(NLINHA1+054,146, "Beneficiário"													, oFont07)
   	oPrn:Say(NLINHA1+061,149, aDadosEmp[1]														, oFont10)
   	oPrn:Say(NLINHA1+069,149, AllTrim(aDadosEmp[8])+"  CEP: " + AllTrim(aDadosEmp[11])+"  "+AllTrim(aDadosEmp[9])+" - "+aDadosEmp[10]	, oFont10)

	oPrn:Say(NLINHA1+054,435, "CNPJ/CPF Beneficiário"											, oFont07)
   	oPrn:Say(NLINHA1+066,438, aDadosEmp[6]														, oFont12)

	// Títulos e dados da terceira linha de boxes
	oPrn:Say(NLINHA1+076,032, "(=) Valor do Documento"											, oFont07)
	oPrn:Say(NLINHA1+088,075, Transform(aDadosTit[5], "@E 99,999,999.99")						, oFont12)

	oPrn:Say(NLINHA1+076,146, "(-) Descontos"													, oFont07)
	DO CASE
		CASE _cBanco $ '041/033' .And. aDadosTit[8] <> 0
	    	oPrn:Say(NLINHA1+086,189, Transform(aDadosTit[8], "@E 99,999,999.99")				, oFont12)
		CASE _cBanco == '001'
	    	oPrn:Say(NLINHA1+086,189, Transform(aDadosTit[8], "@E 99,999,999.99")				, oFont12)
	ENDCASE

	oPrn:Say(NLINHA1+076,291, "(+) Acréscimos"													, oFont07)

	oPrn:Say(NLINHA1+076,435, "(=) Valor Cobrado"												, oFont07)

	oPrn:Say(NLINHA1+109,435, "Parcela: "														, oFont24N)
	If Empty(aDadosTit[9])
		oPrn:Say(NLINHA1+109,535, "1"															, oFont24N)
	Else
		oPrn:Say(NLINHA1+109,535, aDadosTit[9]													, oFont24N)
	EndIf

	// Dados do Pagador
	oPrn:Say(NLINHA1+097,032, "Pagador"															, oFont07)
	oPrn:Say(NLINHA1+099,070, aDatSacado[1]+" ("+aDatSacado[2]+")"								, oFont10)	// Razão Social + Código
	oPrn:Say(NLINHA1+107,070, aDatSacado[3]														, oFont10)	// Endereço + Bairro
	oPrn:Say(NLINHA1+115,070, aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5]			, oFont10)	// CEP + Cidade + Estado

	If Len(AllTrim(aDatSacado[7])) == 14
		oPrn:Say(NLINHA1+123,070, "CNPJ: "+Transform(aDatSacado[7],"@R 99.999.999/9999-99")		, oFont10) 	// CNPJ
	Else
		oPrn:Say(NLINHA1+123,070, "CPF: " +Transform(aDatSacado[7],"@R 999.999.999-99")    		, oFont10) 	// CPF
	Endif

	If _cBanco == '033'
		oPrn:Say(NLINHA1+128,032, "Beneficiário Final"											, oFont07)
	Else
		oPrn:Say(NLINHA1+128,032, "Sacador/AValista"											, oFont07)
	EndIf

	// Autenticação Mecânica
	oPrn:Line(NLINHA1+129,030,NLINHA1+129,578, 0, "-4")
	oPrn:Say(NLINHA1+135,450,"Autenticação Mecânica"											, oFont07)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DESENHA O BOLETO (FICHA DE COMPENSAÇÃO)                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Logo do Banco
	oPrn:SayBitmap(NLINHA1+140, 030, aBitmap[1], 090, 020)

	// Banco e Linha Digitável
	oPrn:Say(NLINHA1+160,130, " | " + aDadosBanco[1] + " | "									, oFont18N)
	If _cBanco == "001"
		oPrn:Say(NLINHA1+160,205, Alltrim(CB_RN[2]) 											, oFont15N)
	Else
		oPrn:Say(NLINHA1+160,215, Alltrim(CB_RN[2]) 											, oFont15N)
	EndIf

	// Box Geral
	oPrn:Box(NLINHA1+165,030,NLINHA1+390,578)

	// Coluna Principal
	oPrn:Line(NLINHA1+165,415,NLINHA1+345,415, 0, "-4")

	// Linhas do Box Geral
	oPrn:Line(NLINHA1+185,030,NLINHA1+185,578, 0, "-4")		// 1a. linha
	oPrn:Line(NLINHA1+205,030,NLINHA1+205,578, 0, "-4")		// 2a. linha
	oPrn:Line(NLINHA1+225,030,NLINHA1+225,578, 0, "-4")		// 3a. linha
	oPrn:Line(NLINHA1+245,030,NLINHA1+245,578, 0, "-4")		// 4a. linha
	oPrn:Line(NLINHA1+265,415,NLINHA1+265,578, 0, "-4")		// 5a. linha
	oPrn:Line(NLINHA1+285,415,NLINHA1+285,578, 0, "-4")		// 6a. linha
	oPrn:Line(NLINHA1+305,415,NLINHA1+305,578, 0, "-4")		// 7a. linha
	oPrn:Line(NLINHA1+325,415,NLINHA1+325,578, 0, "-4")		// 8a. linha
	oPrn:Line(NLINHA1+345,030,NLINHA1+345,578, 0, "-4")		// 9a. linha

	// Colunas do Box Geral
	oPrn:Line(NLINHA1+205,125,NLINHA1+245,125, 0, "-4")		// 1a. coluna
	oPrn:Line(NLINHA1+225,175,NLINHA1+245,175, 0, "-4")		// 2a. coluna
	oPrn:Line(NLINHA1+205,220,NLINHA1+245,220, 0, "-4")		// 3a. coluna
	oPrn:Line(NLINHA1+205,280,NLINHA1+225,280, 0, "-4")		// 4a. coluna
	oPrn:Line(NLINHA1+205,315,NLINHA1+245,315, 0, "-4")		// 5a. coluna

	// Títulos e dados da 1a. linha de boxes
	oPrn:Say(NLINHA1+171,032, "Local de Pagamento"																			, oFont07)
	If _cBanco = '001'
		oPrn:Say(NLINHA1+182,035, "PAGÁVEL EM QUALQUER BANCO"																, oFont10)
	ElseIf _cBanco = '033'
		oPrn:Say(NLINHA1+182,035, "PAGÁVEL PREFERENCIALMENTE NO BANCO SANTANDER"											, oFont10)
	ElseIf _cBanco = '041'
		oPrn:Say(NLINHA1+182,035, "PAGÁVEL PREFERENCIALMENTE NA REDE INTEGRADA BANRISUL"									, oFont10)
	Else
		oPrn:Say(NLINHA1+182,035, "ATÉ O VENCIMENTO PAGAR NA REDE BANCÁRIA"													, oFont10)
	EndIf

	oPrn:Say(NLINHA1+171,417, "Vencimento"														, oFont07)
	oPrn:Say(NLINHA1+182,420, FormDate(aDadosTit[4],.T.)										, oFont12)

	// Títulos e dados da 2a. linha de boxes
	oPrn:Say(NLINHA1+191,032, "Beneficiario"																							, oFont07)
   	oPrn:Say(NLINHA1+197,035, aDadosEmp[1] + Space(15) + "CNPJ: " + aDadosEmp[6]														, oFont10)
   	oPrn:Say(NLINHA1+204,035, AllTrim(aDadosEmp[8])+"  CEP: " + AllTrim(aDadosEmp[11])+"  "+AllTrim(aDadosEmp[9])+" - "+aDadosEmp[10]	, oFont10)

	oPrn:Say(NLINHA1+191,417, "Agência/Código do Beneficiario"									, oFont07)
	oPrn:Say(NLINHA1+202,420, Alltrim(aDadosBanco[6])+"/"+aDadosBanco[7]						, oFont12)

	// Títulos e dados da 3a. linha de boxes
	oPrn:Say(NLINHA1+211,032, "Data do Documento"												, oFont07)
	oPrn:Say(NLINHA1+222,035, FormDate(aDadosTit[2],.T.)										, oFont12)

	oPrn:Say(NLINHA1+211,127, "Nro. Documento"													, oFont07)
	oPrn:Say(NLINHA1+222,130, aDadosTit[1]														, oFont12)

	oPrn:Say(NLINHA1+211,222, "Espécie Doc."													, oFont07)
	DO CASE
		CASE _cBanco == '041'
			oPrn:Say(NLINHA1+222,225, "R$"														, oFont12)
		CASE _cBanco $ '001/033'
			oPrn:Say(NLINHA1+222,225, "DM"														, oFont12)
	ENDCASE

	oPrn:Say(NLINHA1+211,282, "Aceite"															, oFont07)
	oPrn:Say(NLINHA1+222,285, "N"																, oFont12)

	oPrn:Say(NLINHA1+211,317, "Data do Processamento"											, oFont07)
	oPrn:Say(NLINHA1+222,320, FormDate(aDadosTit[3],.T.)										, oFont12)

	oPrn:Say(NLINHA1+211,417, "Nosso Número"													, oFont07)
	oPrn:Say(NLINHA1+222,420, aDadosTit[6]														, oFont12)

	// Títulos e dados da 4a. linha de boxes
	oPrn:Say(NLINHA1+231,032, "Uso do Banco"													, oFont07)

	oPrn:Say(NLINHA1+231,127, "Carteira"														, oFont07)
	oPrn:Say(NLINHA1+242,130, aDadosBanco[5]													, oFont12)

	oPrn:Say(NLINHA1+231,177, "Espécie"															, oFont07)
	oPrn:Say(NLINHA1+242,180, "R$"																, oFont12)

	oPrn:Say(NLINHA1+231,222, "Quantidade"														, oFont07)

	oPrn:Say(NLINHA1+231,317, "Valor"															, oFont07)

	oPrn:Say(NLINHA1+231,417, "(=) Valor do Documento"											, oFont07)
	oPrn:Say(NLINHA1+242,420, Transform(aDadosTit[5], "@E 99,999,999.99")						, oFont12)


	// Títulos e dados das instruções bancárias e demais campos do bloco a direita das instruções bancárias
	If _cBanco == '033'
		oPrn:Say(NLINHA1+251,032, "Mensagem / Instruções (Texto de REsponsabilidade do Beneficiário)"								, oFont07)
	Else
		oPrn:Say(NLINHA1+251,032, "Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)"	, oFont07)
	EndIf
	DO CASE
		CASE _cBanco $ '001/033'
			oPrn:Say(NLINHA1+272,035, AllTrim(aBolText[1]) + " R$ " + AllTrim(Transform(aDadosTit[7],"@E 999,999.99"))	, oFont10)
		CASE _cBanco == '041'
			oPrn:Say(NLINHA1+262,035, "JUROS AO DIA DE R$ "+AllTrim(Transform(aDadosTit[7],"@E 999,999,999.99"))		, oFont10)
			oPrn:Say(NLINHA1+272,035, AllTrim(aBolText[1])																, oFont10)
		OTHERWISE
			oPrn:Say(NLINHA1+272,035, AllTrim(aBolText[1])																, oFont10)
	ENDCASE
	oPrn:Say(NLINHA1+282,035, AllTrim(aBolText[2])																		, oFont10)
	oPrn:Say(NLINHA1+282,035, AllTrim(aBolText[3])																		, oFont10)
	oPrn:Say(NLINHA1+282,035, AllTrim(aBolText[4])																		, oFont10)
	oPrn:Say(NLINHA1+282,035, AllTrim(aBolText[5])																		, oFont10)

	oPrn:Say(NLINHA1+251,417, "(-) Desconto/Abatimento"											, oFont07)
	DO CASE
		CASE _cBanco $ '041/033' .And. aDadosTit[8] <> 0
			oPrn:Say(NLINHA1+262,420, Transform(aDadosTit[8], "@E 99,999,999.99")				, oFont12)
		CASE _cBanco == '001'
			oPrn:Say(NLINHA1+262,420, Transform(aDadosTit[8], "@E 99,999,999.99")				, oFont12)
	ENDCASE

	oPrn:Say(NLINHA1+271,417, "(-) Outras Deduções"												, oFont07)
	oPrn:Say(NLINHA1+291,417, "(+) Mora/Multa"													, oFont07)

	oPrn:Say(NLINHA1+311,417, "(+) Outros Acréscimos"											, oFont07)
	If _cBanco <> '001'
		oPrn:Say(NLINHA1+322,420, Alltrim(Transform(GetMv("ML_TXBOL"),"@E@Z 99,999,999.99"))	, oFont12)
	EndIf

	oPrn:Say(NLINHA1+331,417, "(=) Valor Cobrado"												, oFont07)

	oPrn:Say(NLINHA1+340,260, "Parcela: "														, oFont24N)
	If Empty(aDadosTit[9])
		oPrn:Say(NLINHA1+340,360, "1"															, oFont24N)
	Else
		oPrn:Say(NLINHA1+340,360, aDadosTit[9]													, oFont24N)
	EndIf

	oPrn:Say(NLINHA1+351,032, "Pagador"															, oFont07)
	oPrn:Say(NLINHA1+353,070, aDatSacado[1]+" ("+aDatSacado[2]+")"								, oFont10)	// Razão Social + Código
	oPrn:Say(NLINHA1+361,070, aDatSacado[3]														, oFont10)	// Endereço + Bairro
	oPrn:Say(NLINHA1+369,070, aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5]			, oFont10)	// CEP + Cidade + Estado

	If Len(AllTrim(aDatSacado[7])) == 14
		oPrn:Say(NLINHA1+377,070, "CNPJ: "+Transform(aDatSacado[7],"@R 99.999.999/9999-99")		, oFont10) 	// CNPJ
	Else
		oPrn:Say(NLINHA1+377,070, "CPF: " +Transform(aDatSacado[7],"@R 999.999.999-99")    		, oFont10) 	// CPF
	Endif

	If _cBanco == '033'
		oPrn:Say(NLINHA1+385,032, "Beneficiário Final"											, oFont07)
	Else
		oPrn:Say(NLINHA1+385,032, "Sacador/AValista"											, oFont07)
	EndIf

	// Código de Barras
	oPrn:FWMsBar("INT25", NLINBAR, 2.5, CB_RN[1], oPrn,.F. ,Nil ,Nil ,0.025 ,0.8 ,Nil ,Nil ,"A" ,.F.)

	// Autenticação
	oPrn:Say(NLINHA1+397,440, "Autenticação Mecânica - Ficha de Compensação"					, oFont07)

	// Finaliza a Página
	oPrn:EndPage()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} CODIGOBARRAS
Função de montagem do código de barras para Banco do Brasil e Banrisul
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function CODIGOBARRAS(cCodBco,cCodAge)

	Local I

	_xCodBar := ""
	_cCodBar := ""

	DO CASE
		CASE SE1->E1_PORT2 == "041"  // Banrisul
			i := 1
			Do While i <= 44
				STR_NUM[i] := 1
				i := i + 1
			EndDo
			/*
			If SE1->E1_VENCTO >= Ctod("22/02/2025")  	// Regra que verifica o fator de vencimento a partir de 2025
				_FV := Str(SE1->E1_VENCTO - Ctod("22/02/2025") + 1000,4)
			Else
				_FV := Str(SE1->E1_VENCTO - Ctod('07/10/1997'),4)
			EndIf
			_XX := _FV + StrZero(SE1->E1_ValOR*100,10,0)
			*/
			_XX := Str(SE1->E1_VENCTO - Ctod('07/10/1997'),4) + StrZero(SE1->E1_ValOR*100,10,0)
			STR_NUM[1] := 0
			STR_NUM[2] := 4
			STR_NUM[3] := 1
			STR_NUM[4] := 9    // MOEDA
			STR_NUM[6] := Val(Substr(_XX,1,1))
			STR_NUM[7] := Val(Substr(_XX,2,1))
			STR_NUM[8] := Val(Substr(_XX,3,1))
			STR_NUM[9] := Val(Substr(_XX,4,1))
			STR_NUM[10] := Val(Substr(_XX,5,1))
			STR_NUM[11] := Val(Substr(_XX,6,1))
			STR_NUM[12] := Val(Substr(_XX,7,1))
			STR_NUM[13] := Val(Substr(_XX,8,1))
			STR_NUM[14] := Val(Substr(_XX,9,1))
			STR_NUM[15] := Val(Substr(_XX,10,1))
			STR_NUM[16] := Val(Substr(_XX,11,1))
			STR_NUM[17] := Val(Substr(_XX,12,1))
			STR_NUM[18] := Val(Substr(_XX,13,1))
			STR_NUM[19] := Val(Substr(_XX,14,1))
			STR_NUM[20] := 2
			STR_NUM[21] := 1
			_XX := SEE->EE_AGENCIA
			STR_NUM[22] := Val(Substr(_XX,1,1))
			STR_NUM[23] := Val(Substr(_XX,2,1))
			STR_NUM[24] := Val(Substr(_XX,3,1))
			STR_NUM[25] := Val(Substr(_XX,4,1))
			_XX := Substr(_cCedente,4,7)
			STR_NUM[26] := Val(Substr(_XX,1,1))
			STR_NUM[27] := Val(Substr(_XX,2,1))
			STR_NUM[28] := Val(Substr(_XX,3,1))
			STR_NUM[29] := Val(Substr(_XX,4,1))
			STR_NUM[30] := Val(Substr(_XX,5,1))
			STR_NUM[31] := Val(Substr(_XX,6,1))
			STR_NUM[32] := Val(Substr(_XX,7,1))
			_XX := Substr(SE1->E1_NUMBCO,1,8)
			STR_NUM[33] := Val(Substr(_XX,1,1))
			STR_NUM[34] := Val(Substr(_XX,2,1))
			STR_NUM[35] := Val(Substr(_XX,3,1))
			STR_NUM[36] := Val(Substr(_XX,4,1))
			STR_NUM[37] := Val(Substr(_XX,5,1))
			STR_NUM[38] := Val(Substr(_XX,6,1))
			STR_NUM[39] := Val(Substr(_XX,7,1))
			STR_NUM[40] := Val(Substr(_XX,8,1))
			STR_NUM[41] := 4
			STR_NUM[42] := 0

			//-------------------------------------------- DIG MOD 10
			_AA1 := 20
			_XX1 := 0
			_BB1 := 2
			Do While _AA1<=42
				_XX1 := _XX1+(STR_NUM[_AA1]*_BB1-IIF(STR_NUM[_AA1]*_BB1>9,9,0))
				If _BB1 == 1
					_BB1 := 2
				Else
					_BB1 := 1
				Endif
				_AA1 := _AA1+1
			EndDo
			If _XX1 < 10
				_YY := _XX1
			Else
				_YY := mod(_XX1,10)
			Endif
			If _YY == 0
				_XX1 := 0
			Else
				_XX1 := 10-_YY
			Endif
			STR_NUM[43] := _XX1

			//-------------------------------------------- DIG MOD 11
			_xx := 43
			_yy := 2
			_ZZ := 0
			Do While _XX >= 20
				If _yy > 7
					_YY := 2
				Endif
				_ZZ := _ZZ+(STR_NUM[_xx]*_YY)
				_YY := _YY+1
				_XX := _XX-1
			EndDo
			If _ZZ < 11
				_XX2 := _ZZ
			Else
				_XX2 := MOD(_ZZ,11)
			Endif
			If _XX2 == 1
				If STR_NUM[43] + 1 == 10
					STR_NUM[43] := 0
				Else
					STR_NUM[43] := STR_NUM[43]+1
				Endif
				_xx := 43
				_yy := 2
				_ZZ := 0
				Do While _XX >= 20
					If _yy > 7
						_YY := 2
					Endif
					_ZZ := _ZZ+(STR_NUM[_xx]*_YY)
					_YY := _YY+1
					_XX := _XX-1
				EndDo
				If _ZZ<11
					_XX2 := _ZZ
				Else
					_XX2 := MOD(_ZZ,11)
				Endif
			Endif
			If _XX2 <> 0
				_XX2 := 11-_XX2
			Endif
			STR_NUM[44] := _XX2

			//--------------------------------- CALCULO DIGITO POS. 5
			_xx := 44
			_yy := 2
			_ZZ := 0
			Do While _XX <> 0
				If _yy > 9
					_YY := 2
				Endif
				If _XX == 5
					_XX := _XX-1
				Endif
				_ZZ := _ZZ+(STR_NUM[_xx]*_YY)
				_YY := _YY+1
				_XX := _XX-1
			EndDo
			If _ZZ < 11
				_DIG5 := _ZZ
			Else
				_DIG5 := MOD(_ZZ,11)
			Endif
			If _DIG5 <> 0
				_DIG5 := 11-_DIG5
			Endif
			If _DIG5 == 10
				_DIG5 := 1
			Endif
			If _DIG5 == 11
				_DIG5 := 1
			Endif
			If _DIG5 == 0
				_DIG5 := 1
			Endif
			STR_NUM[5] := _DIG5

			//---------------------------------- DIGITO VERIFICADOR 1
			_XX := (0*2)+(4*1)+(1*2)+(9*1)+(2*2)+(1*1)
			_XX := _XX+Val(Subs(SEE->EE_AGENCIA,1,1))*2-IIF(Val(Subs(SEE->EE_AGENCIA,1,1))*2>9,9,0)
			_XX := _XX+Val(Subs(SEE->EE_AGENCIA,2,1))*1-IIF(Val(Subs(SEE->EE_AGENCIA,2,1))*1>9,9,0)
			_XX := _XX+Val(Subs(SEE->EE_AGENCIA,3,1))*2-IIF(Val(Subs(SEE->EE_AGENCIA,3,1))*2>9,9,0)
			If _XX < 10
				_YY := _XX
			Else
				_YY := mod(_XX,10)
			Endif
			If _YY == 0
				_XX := 0
			Else
				_XX := 10-_YY
			Endif

			//---------------------------------- DIGITO VERIFICADOR 2
			_XX1 :=      Val(Subs(_cCedente,03,1))*2-IIF(Val(Subs(_cCedente,03,1))*2>9,9,0)
			_XX1 := _XX1+Val(Subs(_cCedente,04,1))*1-IIF(Val(Subs(_cCedente,04,1))*1>9,9,0)
			_XX1 := _XX1+Val(Subs(_cCedente,05,1))*2-IIF(Val(Subs(_cCedente,05,1))*2>9,9,0)
			_XX1 := _XX1+Val(Subs(_cCedente,06,1))*1-IIF(Val(Subs(_cCedente,06,1))*1>9,9,0)
			_XX1 := _XX1+Val(Subs(_cCedente,07,1))*2-IIF(Val(Subs(_cCedente,07,1))*2>9,9,0)
			_XX1 := _XX1+Val(Subs(_cCedente,08,1))*1-IIF(Val(Subs(_cCedente,08,1))*1>9,9,0)
			_XX1 := _XX1+Val(Subs(_cCedente,09,1))*2-IIF(Val(Subs(_cCedente,09,1))*2>9,9,0)
			_XX1 := _XX1+Val(Subs(_cCedente,10,2))*1-IIF(Val(Subs(_cCedente,10,1))*1>9,9,0)
			_XX1 := _XX1+Val(Left(Substr(SE1->E1_NUMBCO,1,8),2))*2-IIF(Val(Left(Substr(SE1->E1_NUMBCO,1,8),2))*2>9,9,0)

			s := Substr(_cCedente,3,5)+Substr(_cCedente,8,3)+Left(Substr(SE1->E1_NUMBCO,1,8),2)
			_nDigito := Modulo10(s)

			If _XX1 < 10
				_YY := _XX1
			Else
				_YY := mod(_XX1,10)
			Endif
			If _YY == 0
				_XX1 := 0
			Else
				_XX1 := 10-_YY
			Endif

			//---------------------------------- DIGITO VERIFICADOR 3
			_XX2 :=      Val(Subs(Substr(SE1->E1_NUMBCO,1,8),3,1))*1-IIF(Val(Subs(Substr(SE1->E1_NUMBCO,1,8),3,1))*1>9,9,0)
			_XX2 := _XX2+Val(Subs(Substr(SE1->E1_NUMBCO,1,8),4,1))*2-IIF(Val(Subs(Substr(SE1->E1_NUMBCO,1,8),4,1))*2>9,9,0)
			_XX2 := _XX2+Val(Subs(Substr(SE1->E1_NUMBCO,1,8),5,1))*1-IIF(Val(Subs(Substr(SE1->E1_NUMBCO,1,8),5,1))*1>9,9,0)
			_XX2 := _XX2+Val(Subs(Substr(SE1->E1_NUMBCO,1,8),6,1))*2-IIF(Val(Subs(Substr(SE1->E1_NUMBCO,1,8),6,1))*2>9,9,0)
			_XX2 := _XX2+Val(Subs(Substr(SE1->E1_NUMBCO,1,8),7,1))*1-IIF(Val(Subs(Substr(SE1->E1_NUMBCO,1,8),7,1))*1>9,9,0)
			_XX2 := _XX2+Val(Subs(Substr(SE1->E1_NUMBCO,1,8),8,1))*2-IIF(Val(Subs(Substr(SE1->E1_NUMBCO,1,8),8,1))*2>9,9,0)
			_XX2 := _XX2+(4*1)+(0*2)
			_XX2 := _XX2+STR_NUM[43]*1-IIF(STR_NUM[43]*1>9,9,0)
			_XX2 := _XX2+STR_NUM[44]*2-IIF(STR_NUM[44]*2>9,9,0)
			If _XX2 < 10
				_YY := _XX2
			Else
				_YY := mod(_XX2,10)
			Endif
			If _YY == 0
				_XX2 := 0
			Else
				_XX2 := 10-_YY
			Endif

			_xCodBar := "04192.1" + Substr(SEE->EE_AGENCIA,1,3) + Str(_XX,1,0) + "  "		
			_xCodBar += Substr(_cCedente,3,5)+"."+Substr(_cCedente,8,3)+Left(Substr(SE1->E1_NUMBCO,1,8),2)+Str(_nDigito,1,0)+"  "
			_xCodBar += Substr(Substr(SE1->E1_NUMBCO,1,8),3,5)+ "." + Substr(Substr(SE1->E1_NUMBCO,1,8),8,1)+ "40" +Str(STR_NUM[43],1,0)+Str(STR_NUM[44],1,0)+Str(_XX2,1,0)+"  "+STR(STR_NUM[5],1,0)+"  "		
			/*
			If SE1->E1_VENCTO >= Ctod("22/02/2025")  // Regra que verifica o fator de vencimento a partir de 2025
				_FV := str(SE1->E1_VENCTO - Ctod("22/02/2025") + 1000,4)
			Else
				_FV := str(SE1->E1_VENCTO - Ctod('07/10/1997'),4)
			EndIf
			_xCodBar += _FV + StrZero(SE1->E1_ValOR*100,10,0)
			*/
			_xCodBar += Str(SE1->E1_VENCTO - Ctod('07/10/1997'),4) + StrZero(SE1->E1_ValOR*100,10,0)

			_Flag1 := 1
			_cCodBar := ""
			For I := 1 To 44
				_cCodBar := _cCodBar + Str(STR_NUM[i],1,0)
			Next

		CASE SE1->E1_PORT2 == "001"       // Banco do Brasil
			i := 1
			Do While i <= 44
				STR_NUM[i] := 1
				i := i + 1
			EndDo

			/*
			If SE1->E1_VENCTO >= Ctod("22/02/2025")  // Regra que verifica o fator de vencimento a partir de 2025
				_XX := str(SE1->E1_VENCTO - Ctod("22/02/2025") + 1000,4)
			Else
				_XX := str(SE1->E1_VENCTO - Ctod('07/10/1997'),4)
			EndIf
			*/
			_XX := Str(SE1->E1_VENCTO-Ctod('07/10/1997'),4)
			STR_NUM[01] := 0
			STR_NUM[02] := 0
			STR_NUM[03] := 1
			STR_NUM[04] := 9                         //MOEDA
			STR_NUM[06] := Val(Substr(_XX,01,1))     //Fator de vencimento
			STR_NUM[07] := Val(Substr(_XX,02,1))     //Fator de vencimento
			STR_NUM[08] := Val(Substr(_XX,03,1))     //Fator de vencimento
			STR_NUM[09] := Val(Substr(_XX,04,1))     //Fator de vencimento
			_XX := StrZero(SE1->E1_ValOR*100,10,0)
			STR_NUM[10] := Val(Substr(_XX,01,1))    //Valor
			STR_NUM[11] := Val(Substr(_XX,02,1))    //Valor
			STR_NUM[12] := Val(Substr(_XX,03,1))    //Valor
			STR_NUM[13] := Val(Substr(_XX,04,1))    //Valor
			STR_NUM[14] := Val(Substr(_XX,05,1))    //Valor
			STR_NUM[15] := Val(Substr(_XX,06,1))    //Valor
			STR_NUM[16] := Val(Substr(_XX,07,1))    //Valor
			STR_NUM[17] := Val(Substr(_XX,08,1))    //Valor
			STR_NUM[18] := Val(Substr(_XX,09,1))    //Valor
			STR_NUM[19] := Val(Substr(_XX,10,1))    //Valor
			STR_NUM[20] := 0
			STR_NUM[21] := 0
			STR_NUM[22] := 0
			STR_NUM[23] := 0
			STR_NUM[24] := 0
			STR_NUM[25] := 0
			_XX := SE1->E1_NUMBCO                  //Nosso Numero: 17 digitos
			STR_NUM[26] := Val(Substr(_XX,01,1))
			STR_NUM[27] := Val(Substr(_XX,02,1))
			STR_NUM[28] := Val(Substr(_XX,03,1))
			STR_NUM[29] := Val(Substr(_XX,04,1))
			STR_NUM[30] := Val(Substr(_XX,05,1))
			STR_NUM[31] := Val(Substr(_XX,06,1))
			STR_NUM[32] := Val(Substr(_XX,07,1))
			STR_NUM[33] := Val(Substr(_XX,08,1))
			STR_NUM[34] := Val(Substr(_XX,09,1))
			STR_NUM[35] := Val(Substr(_XX,10,1))
			STR_NUM[36] := Val(Substr(_XX,11,1))
			STR_NUM[37] := Val(Substr(_XX,12,1))
			STR_NUM[38] := Val(Substr(_XX,13,1))
			STR_NUM[39] := Val(Substr(_XX,14,1))
			STR_NUM[40] := Val(Substr(_XX,15,1))
			STR_NUM[41] := Val(Substr(_XX,16,1))
			STR_NUM[42] := Val(Substr(_XX,17,1))
			STR_NUM[43] := Val(Substr(SA6->A6_CARTEIR,01,1))
			STR_NUM[44] := Val(Substr(SA6->A6_CARTEIR,02,1))

			//--------------------------------- CALCULO DIGITO POS. 5
			_xx := 44                             //44 digitos do codigo de barras
			_yy := 2
			_zz := 0

			Do While _xx <> 0                     //multiplicar  cada algrismo que compoe o numero pelo seu respectivo multiplicador (peso)
				If _yy > 9                        //iniciando-se pelas 44 posição e seltando a 5. os multiplicadores variam de 2 a 9
					_yy := 2                      //o primeiro digito da esquerda deverá ser multiplicado por 2, o segundo por 3 e assim por diante
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

			//o resto da divisão deve ser Substraído de 11
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
							_nDv01 += (Val(Substr(_Str,1,1)) + Val(Substr(_Str,2,1)))
						Else                   //se não for maior ou igual a 10
							_nDv01 += _nVlr	   //apenas soma
						Endif
						_lFlag := !(_lFlag)    //inverte o flag para multiplicar por 1
					Else                       //Senão, se o flag for negativo faz o mesmo que o bloco de cima, mas multiplicado por 1
						_nVlr := STR_NUM[I] * 1
						If _nVlr >= 10
							_Str := str(_nVlr,2)
							_nDv01 += (Val(Substr(_Str,1,1)) + Val(Substr(_Str,2,1)))
						Else
							_nDv01 += _nVlr
						Endif
						_lFlag := !(_lFlag)
					Endif
				Endif
			Next
			_nDez := _nDv01 + 10
			_nDez := round(_nDez / 10,0)
			_cDez := str(_nDez,1)+'0'
			_nDez := Val(_cDez)

			_nDv01 := _nDez - MOD(_nDv01,10)
			If _nDv01 > 10
				_Str   := Substr(str(_nDv01,2),2,1)
				_nDv01 := Val(_Str)
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
						_nDv02 += (Val(Substr(_Str,1,1)) + Val(Substr(_Str,2,1)))
					Else                   //se não for maior ou igual a 10
						_nDv02 += _nVlr	   //apenas soma
					Endif
					_lFlag := !(_lFlag)    //inverte o flaga para multiplicar por 2
				Else                       //Senão, se o flag for negativo faz o mesmo que o bloco de cima, mas multiplicado por 1
					_nVlr := STR_NUM[I] * 2
					If _nVlr >= 10
						_Str := str(_nVlr,2)
						_nDv02 += (Val(Substr(_Str,1,1)) + Val(Substr(_Str,2,1)))
					Else
						_nDv02 += _nVlr
					Endif
					_lFlag := !(_lFlag)
				Endif
			Next

			_nDez := _nDv02 + 10
			_nDez := round(_nDez / 10,0)
			_cDez := str(_nDez,1)+'0'
			_nDez := Val(_cDez)

			_nDv02 := _nDez - MOD(_nDv02,10)
			If _nDv02 > 10
				_Str   := Substr(str(_nDv02,2),2,1)
				_nDv02 := Val(_Str)
			Endif
			If _nDv02 == 10
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
						_nDv03 += (Val(Substr(_Str,1,1)) + Val(Substr(_Str,2,1)))
					Else                   //se não for maior ou igual a 10
						_nDv03 += _nVlr	   //apenas soma
					Endif
					_lFlag := !(_lFlag)    //inverte o flaga para multiplicar por 2
				Else                       //Senão, se o flag for negativo faz o mesmo que o bloco de cima, mas multiplicado por 1
					_nVlr := STR_NUM[I] * 2
					If _nVlr >= 10
						_Str := str(_nVlr,2)
						_nDv03 += (Val(Substr(_Str,1,1)) + Val(Substr(_Str,2,1)))
					Else
						_nDv03 += _nVlr
					Endif
					_lFlag := !(_lFlag)
				Endif
			Next

			_nDez := _nDv03 + 10
			_nDez := round(_nDez / 10,0)
			_cDez := str(_nDez,1)+'0'
			_nDez := Val(_cDez)

			_nDv03 := _nDez - MOD(_nDv03,10)
			If _nDv03 > 10
				_Str   := Substr(str(_nDv03,2),2,1)
				_nDv03 := Val(_Str)
			Endif
			If _nDv03 = 10
				_nDv03 := 0
			Endif

			//Campo 1
			_xCodBar := STR(STR_NUM[01],1,0) + STR(STR_NUM[02],1,0) + STR(STR_NUM[03],1,0) + STR(STR_NUM[04],1,0) + STR(STR_NUM[20],1,0) + "."
			_xCodBar += STR(STR_NUM[21],1,0) + STR(STR_NUM[22],1,0) + STR(STR_NUM[23],1,0) + STR(STR_NUM[24],1,0) + STR(_nDv01 ,1,0) + '  '
			//Campo 2
			_xCodBar += STR(STR_NUM[25],1,0) + STR(STR_NUM[26],1,0) + STR(STR_NUM[27],1,0) + STR(STR_NUM[28],1,0) + STR(STR_NUM[29],1,0) + "."
			_xCodBar += STR(STR_NUM[30],1,0) + STR(STR_NUM[31],1,0) + STR(STR_NUM[32],1,0) + STR(STR_NUM[33],1,0) + STR(STR_NUM[34],1,0) + STR(_nDv02,1,0)
			_xCodBar += '  '
			//Campo 3
			_xCodBar += STR(STR_NUM[35],1,0) + STR(STR_NUM[36],1,0) + STR(STR_NUM[37],1,0) + STR(STR_NUM[38],1,0) + STR(STR_NUM[39],1,0) + "."
			_xCodBar += STR(STR_NUM[40],1,0) + STR(STR_NUM[41],1,0) + STR(STR_NUM[42],1,0) + STR(STR_NUM[43],1,0) + STR(STR_NUM[44],1,0) + STR(_nDv03,1,0)
			_xCodBar += '  '
			//Campo 4
			_xCodBar += STR(STR_NUM[5],1,0) + '  '
			//Campo 5
			_xCodBar += STR(STR_NUM[06],1,0) + STR(STR_NUM[07],1,0) + STR(STR_NUM[08],1,0) + STR(STR_NUM[09],1,0)
			_xCodBar += STR(STR_NUM[10],1,0) + STR(STR_NUM[11],1,0) + STR(STR_NUM[12],1,0) + STR(STR_NUM[13],1,0) + STR(STR_NUM[14],1,0)
			_xCodBar += STR(STR_NUM[15],1,0) + STR(STR_NUM[16],1,0) + STR(STR_NUM[17],1,0) + STR(STR_NUM[18],1,0) + STR(STR_NUM[19],1,0)

			//Aqui forma o string com o codigo de barras a ser impresso
			_cCodBar:=""
			For I := 1 to 44
				_cCodBar := _cCodBar + str(STR_NUM[i],1,0)
			Next

		OTHERWISE

			If SE1->E1_PORT2 <> "099"
				MsgBox("Banco / Tipo Formulario Nao Disponivel!","ML_ERRO","STOP")
			Endif
	
	ENDCASE

	DbSelectArea("SE1")
	RecLock("SE1",.F.)
	SE1->E1_CODBAR := _cCodBar	// _cCodBar -> codigo de barra impresso
	SE1->E1_CODDIG := _xCodBar	// _xCodBar -> linha digitavel impressa
	MsUnlock()

Return({_cCodBar,_xCodBar})


//-----------------------------------------------------------------------
/*/{Protheus.doc} Modulo10
Função de cálculo do dígito verificador - Módulo 10
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function Modulo10(cData)

	Local L,D,P := 0
	Local B     := .F.

	L := Len(cData)       // TAMANHO DE BYTES DO CARACTER
	B := .T.   
	D := 0                // DIGITO VERIFICADOR
	While L > 0 
		P := Val(Substr(cData, L, 1))
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


//-----------------------------------------------------------------------
/*/{Protheus.doc} Modulo11
Função de cálculo do dígito verificador - Módulo 11
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
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


//-----------------------------------------------------------------------
/*/{Protheus.doc} NOSSONUM
Função de cálculo do Nosso Número
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function NOSSONUM()

	DbSelectArea("SE1")
	RecLock("SE1",.F.)
	DO CASE
		CASE SE1->E1_PORT2 == "041"                 // Banrisul
			_char2 := StrZero(_NumBco,08,0)
			Z_DVBCO()
			SE1->E1_NUMBCO := StrZero(_NumBco,08,0)+"-"+_char2
			_NumBco := _NumBco + 1

		CASE SE1->E1_PORT2 == "001"                // Banco do Brasil
			NN_BB := ARRAY(11) 		// {0,0,0,0,0,0,0,0,0,0,0}
			NNxBB := ARRAY(11) 		// {0,0,0,0,0,0,0,0,0,0,0}

			_xNumBco := AllTrim(SEE->EE_CODEMP) + StrZero(_NumBco,10,0)

			SE1->E1_NUMBCO := _xNumBco
			_NumBco := _NumBco + 1
	ENDCASE
	SE1->E1_PORT2  := SE1->E1_PORT2
	SE1->E1_BOLIMP := "S"
	MsUnlock()

	DbSelectArea("SEE")
	RecLock("SEE",.F.)
	SEE->EE_BOLATU := _NumBco
	MsUnlock()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} Z_DVBCO()
Função que retorna o Digito Verificador para o Banco
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function Z_DVBCO()

	DO CASE
		CASE SE1->E1_PORT2 == "041"    // P/ BANRISUL
			_num3 := (Val(Subs(_char2,1,1)) * 1) - IIF(Val(Subs(_char2,1,1)) * 1 >9,9,0) +;
					 (Val(Subs(_char2,2,1)) * 2) - IIF(Val(Subs(_char2,2,1)) * 2 >9,9,0) +;
					 (Val(Subs(_char2,3,1)) * 1) - IIF(Val(Subs(_char2,3,1)) * 1 >9,9,0) +;
					 (Val(Subs(_char2,4,1)) * 2) - IIF(Val(Subs(_char2,4,1)) * 2 >9,9,0) +;
					 (Val(Subs(_char2,5,1)) * 1) - IIF(Val(Subs(_char2,5,1)) * 1 >9,9,0)
					 _num3:=_num3+ (Val(Subs(_char2,6,1)) * 2) - IIF(Val(Subs(_char2,6,1)) * 2 >9,9,0) +;
					 (Val(Subs(_char2,7,1)) * 1) - IIF(Val(Subs(_char2,7,1)) * 1 >9,9,0) +;
					 (Val(Subs(_char2,8,1)) * 2) - IIF(Val(Subs(_char2,8,1)) * 2 >9,9,0)

			If _num3 < 10
				_num2 := _num3
			Else
				_num2 := mod(_num3,10)
			Endif

			If _num2 == 0
				_num4 := 0
			Else
				_num4 := 10 - _num2
			Endif

			_char2 := _char2+str(_num4,1)
			_num3 := (Val(Subs(_char2,1,1)) * 4) +;
					 (Val(Subs(_char2,2,1)) * 3) + (Val(Subs(_char2,3,1)) * 2) +;
					 (Val(Subs(_char2,4,1)) * 7) + (Val(Subs(_char2,5,1)) * 6) +;
					 (Val(Subs(_char2,6,1)) * 5) + (Val(Subs(_char2,7,1)) * 4) +;
					 (Val(Subs(_char2,8,1)) * 3) + (Val(Subs(_char2,9,1)) * 2)

			If _num3 < 11
				_num2 := _num3
			Else
				_num2 := mod(_num3,11)
			Endif

			If _num2 == 1
				If Val(RIGHT(_CHAR2,1))+1==10
					_CHAR2 := LEFT(_CHAR2,8)+"0"
				Else
					_CHAR2 := LEFT(_CHAR2,8)+STR(Val(RIGHT(_CHAR2,1))+1,1)
				Endif
				_num3 := (Val(Subs(_char2,1,1)) * 4) +;
						 (Val(Subs(_char2,2,1)) * 3) + (Val(Subs(_char2,3,1)) * 2) +;
						 (Val(Subs(_char2,4,1)) * 7) + (Val(Subs(_char2,5,1)) * 6) +;
						 (Val(Subs(_char2,6,1)) * 5) + (Val(Subs(_char2,7,1)) * 4) +;
						 (Val(Subs(_char2,8,1)) * 3) + (Val(Subs(_char2,9,1)) * 2)
				
				If _num3 < 11
					_num2 := _num3
				Else
					_num2 := mod(_num3,11)
				Endif
			Endif

			If _num2 == 0
				_num4 := 0
			Else
				_num4 := 11 - _num2
			Endif

			_char2 := Right(_char2,1)+str(_num4,1)
	ENDCASE

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} Ret_cBarra
Função que retorna os strings para impressão do boleto
@author     Evandro Mugnol
@since      Ago/2024
@Observ		CB = String para o cód.barras
            RN = String com a linha digitável
/*/
//-----------------------------------------------------------------------
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,dvencimento,cConvenio,cSequencial,_lTemDesc,_cParcela,_cAgCompleta)

	Local blValorfinal := StrZero(nValor*100,10)
	Local cNNumSDig    := cCpoLivre := cCBSemDig := cCodBarra := cNNum := cFatVenc := ''
	Local cNossoNum

	_cParcela := NumParcela(_cParcela)
	If dvencimento >= Ctod("22/02/2025")  // Regra que verifica o fator de vencimento a partir de 2025 
		// 22/02/2025 = Fator 1000 
		// 23/02/2025 = Fator 1001 
		cFatVenc := StrZero(dvencimento - Ctod("22/02/2025") + 1000,4)  // acha a diferenca em dias para o fator de vencimento
	Else 
		cFatVenc := StrZero(dvencimento - Ctod("07/10/1997"),4)			// acha a diferenca em dias para o fator de vencimento
	Endif

	//Campo Livre (Definir campo livre com cada banco)
	cNNumSDig := StrZero(cSequencial,12)                                      				// Nosso Numero sem digito
	cNNum     := cNNumSDig + modulo11(cNNumSDig,Substr(cBanco,1,3))                    		// Nosso Numero
	cNossoNum := cNNumSDig + "-"+ modulo11(cNNumSDig,Substr(cBanco,1,3))              		// Nosso Numero para impressao
	cCpoLivre := "9"+StrZero(Val(Substr(cConvenio,1,7)),7)+cNNum+"0"+"101"

	cCBSemDig := cBanco + cFatVenc + blValorfinal + cCpoLivre                                                // Dados para Calcular o Dig Verificador Geral
	cCodBarra := cBanco + Modulo11(cCBSemDig,Substr(cBanco,1,3)) + cFatVenc + blValorfinal + cCpoLivre       // Codigo de Barras Completo

	cPrCpo   := cBanco+"9"+Substr(cCodBarra,21,4)                                         	// Digito Verificador do Primeiro Campo
	cDvPrCpo := AllTrim(Str(Modulo10(cPrCpo)))

	cSgCpo   := Substr(cCodBarra,25,10)                                                   	// Digito Verificador do Segundo Campo
	cDvSgCpo := AllTrim(Str(Modulo10(cSgCpo)))

	cTrCpo   := Substr(cCodBarra,35,10)                                                   	// Digito Verificador do Terceiro Campo
	cDvTrCpo := AllTrim(Str(Modulo10(cTrCpo)))

	cDvGeral := Substr(cCodBarra,5,1)                                                     	// Digito Verificador Geral do Quarto Campo

	cQrCpo   := Substr(cCodBarra,06,14)                                                   	// Digito Verificador do Quinto Campo
	cDvQrCpo := AllTrim(Str(Modulo10(cQrCpo)))

	//Linha Digitavel
	cLinDig := Substr(cPrCpo,1,09) + "." + cDvPrCpo + " "                                 	// Primeiro campo
	cLinDig += Substr(cSgCpo,1,10) + "." + cDvSgCpo + " "                                 	// Segundo campo
	cLinDig += Substr(cTrCpo,1,10) + "." + cDvTrCpo + " "                                 	// Terceiro campo
	cLinDig += cDvGeral + " "                                                             	// Dig verificador geral Quarto campo
	cLinDig += Substr(cQrCpo,1,14)                                                        	// Quinto campo

Return ({cCodBarra,cLinDig,cNossoNum})


//-----------------------------------------------------------------------
/*/{Protheus.doc} NumParcela
Função que valida a qtde de parcelas
@author     Evandro Mugnol
@since      Ago/2024
/*/
//-----------------------------------------------------------------------
Static Function NumParcela(_cParcela)

	Local _cRet := ""

	If ASC(_cParcela) >= 65 .Or. ASC(_cParcela) <= 90
		_cRet := StrZero(Val(Chr(ASC(_cParcela)-16)),2)
	Else
		_cRet := StrZero(Val(_cParcela),2)
	Endif

Return(_cRet)
