#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

User Function DTI17()
	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³DTI17   º Autor ³ Flávio Bohrer Flores º Data ³  16/12/16   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Emissao de Notas Promissórias Rurais - V2 (old - gjf19)    º±±
	±±ºPaíses    ³                                                            º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Diretor Cleber , Progepec                                  º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	Local _aArqTrb      := {}
	Local _aArqTrb2     := {}
	Local oPrn 
	Local _Data
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

		cIndexKey  := "E2_PREFIXO + E2_NUM + E2_PARCELA + DTOS(E2_EMISSAO)+ E2_FORNECE + E2_LOJA" 	
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
	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 
	u_arqtrb ("FechaTodos",,,, @_aArqTrb2)

return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao MontaRel() - Montagem da NPR                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function MontaRel(_CM)


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


	//Local aBolText 	:= {}

	Private aStru    	:= {}
	Private aCampos  	:= {}
	Private aStru2    	:= {}
	Private aCampos2  	:= {}


	geraTmp()
	aValorExt := {}

	oPrn:=TMSPrinter():New( "NPR Laser" )
	oPrn:SetPortrait()     // ou SetLandscape()       
	oPrn:StartPage()       // Inicia uma nova página  
	oPrn:SetPaperSize(9)   //Tamanho A4

	DbSelectArea("SE2")


	Do While !Eof()  

		PrepDados(_CM)	 	

		DbSkip()
		nI := nI + 1

	EndDo

	geraTmp2()

	soma(_CM)

	//Imprime a 
	//Impress(_CM)
	Impress()


Return



Static Function soma(sm)


	//geraTmp2()

	_nCont := 1		
	_lentrou := .f.
	TMP->(DbGoTop())

	While TMP->(!Eof()) 
		// se fornecedor/loja for Diferente entra
		IF  TMP->VAROK <> sm

			//Percorre a TMP2 , e se tiver Soma 
			TMP2->(DbGoTop())
			While TMP2->(!Eof()) 
				NUMTIT2 := ''
				VALOR	:= 0
				QTDANIM := 0 

				If TMP2->FORNLOJA2	= TMP->FORNLOJA 

					// Soma com o que já tem  	              	
					NUMTIT2 := alltrim(TMP2->NUMTIT22)
					VALOR	:= TMP2->VALOR2
					QTDANIM := TMP2->QTDANIM2

					result := NUMTIT2 + ', ' + TMP->NUMTIT
					reclock('TMP2',.F.)

					TMP2->NUMTIT22  := NUMTIT2 +', '+ alltrim(TMP->NUMTIT)						
					TMP2->VALOR2  	+= TMP->VALOR				// Valor do título						
					TMP2->QTDANIM2 := QTDANIM + TMP->QTDANIM
					TMP2->MARC    := 'S'
					msunlock()	 
					_lentrou := .t.

					exit
				Endif
				TMP2->(DbSkip())
			EndDo
			// Se não tiver na TMP2 cria registro

			If !_lentrou 

				reclock('TMP2',.t.)

				TMP2->PREFIXO2  := TMP->PREFIXO
				TMP2->NUMTIT12 	:= TMP->NUMTIT
				TMP2->NUMTIT22 	:= TMP->NUMTIT
				TMP2->EMISSAO2 	:= TMP->EMISSAO
				TMP2->DTBOL2 	:= TMP->DTBOL
				TMP2->DTVENC2 	:= TMP->DTVENC
				TMP2->VALOR2 	:= TMP->VALOR
				TMP2->NUMNPR2 	:= TMP->NUMNPR
				TMP2->IMPNPR2 	:= TMP->IMPNPR
				TMP2->FORNLOJA2 := TMP->FORNLOJA
				TMP2->QTDANIM2 	:= TMP->QTDANIM
				TMP2->A2NOME2 	:= TMP->A2NOME
				TMP2->A2COD2		:= TMP->A2COD
				TMP2->A2CGC2		:= TMP->A2CGC
				TMP2->DATAI2	 	:= TMP->DATAI
				TMP2->DATAVI2	:= TMP->DATAVI
				TMP2->ABTEXT12 	:= TMP->ABTEXT1
				TMP2->ABTEXT22 	:= TMP->ABTEXT2
				TMP2->ABTEXT32 	:= TMP->ABTEXT3
				TMP2->ABTEXT42 	:= TMP->ABTEXT4
				TMP2->ABTEXT52 	:= TMP->ABTEXT5
				TMP2->ABTEXT62 	:= TMP->ABTEXT6
				TMP2->ABTEXT72 	:= TMP->ABTEXT7
				TMP2->ABTEXT82 	:= TMP->ABTEXT8
				TMP2->ABTEXT92 	:= TMP->ABTEXT9
				TMP2->ABTEXT102 := TMP->ABTEXT10
				TMP2->ABTEXT112 := TMP->ABTEXT11
				TMP2->ABTEXT122 := TMP->ABTEXT12
				TMP2->ABTEXT132 := TMP->ABTEXT13
				TMP2->ABTEXT142 := TMP->ABTEXT14
				TMP2->ABTEXT152 := TMP->ABTEXT15
				TMP2->ABTEXT162 := TMP->ABTEXT16
				TMP2->VAROK2		:= TMP->VAROK
				TMP2->BITMAPI2	:= TMP->BITMAPI
				TMP2->CSEQI2		:= TMP->CSEQI
				TMP2->CVALORI2	:= TMP->CVALORI
				TMP2->L3482		:= TMP->L348
				TMP2->L3492		:= TMP->L349
				TMP2->L3522		:= TMP->L352
				TMP2->L4072		:=	TMP->L407	            	
				msunlock()

			Endif

		Endif
		TMP->(DbSkip())
		_nCont := _nCont + 1
		_lentrou := .f.	
	EndDo
Return

Static Function Impress()

	TMP2->(DbGoTop())

	Do While TMP2->(!Eof())



		If TMP2->IMPNPR2 <> 0
			If !MsgBox("Atencao! A NPR do titulo Nrº " + alltrim(TMP2->NUMTIT12) +;
			" foi impressa " + alltrim(str(TMP2->IMPNPR2)) + " vezes. Continuar? (S/N)" ,"VALIDAÇÃO DE IMPRESSÃO","YESNO")
				return
			endif
		endif

		/* Inicio da Impressão   */
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
		nRow1 := 0 
		nRow2 := 1710

		oPrn:Say(nRow1 + 0050 ,0700 ,TMP2->L3482,oFont24)      //'NOTA PROMISSÓRIA RURAL'
		oPrn:Say(nRow1 + 0190 ,550 ,TMP2->L3492,oFont10)       //'NPR Nº.: ' + _cSeq

		if TMP2->IMPNPR2 > 0
			oPrn:Say(nRow1 + 0230 ,550 ,TMP2->L3522,oFont10)    //oPrn:Say(nRow1 + 0230 ,550 ,'[Via de Negociação nº.: '+ alltrim(strzero(TMP->IMPNPR+1,3)) + ']',oFont10) 
		endif

		oPrn:SayBitmap(nRow1 + 0100,100,TMP2->BITMAPI2,0350,0245) // Imagem	   

		oPrn:Line (nRow1 + 0280,1800,nRow1 + 0350,1800 )  //Vertical 1 ( Quadrado do Valor da Promissória )
		oPrn:Line (nRow1 + 0280,1800,nRow1 + 0280,2300 )
		oPrn:Line (nRow1 + 0350,1800,nRow1 + 0350,2300 )
		oPrn:Line (nRow1 + 0280,2300,nRow1 + 0350,2300 )

		//oPrn:Say(nRow1 + 0190 ,1500 ,TMP2->DATAI2 ,oFont14)
		oPrn:Say(nRow1 + 0190 ,1200 ,alltrim(TMP2->DATAI2),oFont14)
		oPrn:Say(nRow1 + 0290 ,1890 ,'R$ ' + alltrim(transform(TMP2->VALOR2,'@E 999,999,999.99')),oFont16)   

		oPrn:Say(nRow1 + 0410,0450 ,alltrim(TMP2->ABTEXT12),oFont14) //  _DataV + ' por esta NOTA PROMISSORIA RURAL na praça de ' // 85_DataV    :=  'A ' + _cDiaV + ' de ' + _cMesV + ' de ' + _cAnoV
		oPrn:Say(nRow1 + 0480,0100 ,TMP2->ABTEXT22,oFont14)   //aBolText[2],oFont14)    'Santa Maria - RS pagaremos a '   
		oPrn:Say(nRow1 + 0480,0850 ,alltrim(alltrim(TMP2->A2NOME2)),oFont14n) //aBolText[16],oFont14n) 
		oPrn:Say(nRow1 + 0560,0100 ,TMP2->ABTEXT42,oFont14)  //,aBolText[4],oFont14)  'ou à sua ordem, a quantia de :' 

		oPrn:Say(nRow1 + 0630 ,100 ,substr(alltrim(extenso(TMP2->VALOR2,.f.,1)),1,75),oFont14n)   //substr(_cExtenso,1,75),oFont14n)   
		oPrn:Say(nRow1 + 0700 ,100 ,substr(alltrim(extenso(TMP2->VALOR2,.f.,1)),76,75),oFont14n) //,substr(_cExtenso,76,75),oFont14n) 

		If TMP2->MARC = 'S'
			oPrn:Say(nRow1 + 0770,0100 ,'Valor de compra que lhe(s) fiz(emos) conforme NFs nº: ' + substr(alltrim(TMP2->NUMTIT22),1,122),oFont14)
		Else
			oPrn:Say(nRow1 + 0770,0100 ,'Valor de compra que lhe(s) fiz(emos) conforme NF nº: ' + substr(alltrim(TMP2->NUMTIT22),1,122),oFont14)
		Endif
		oPrn:Say(nRow1 + 0840,0100 ,substr(alltrim(TMP2->NUMTIT22),123,180),oFont14)
		oPrn:Say(nRow1 + 0910,0100 ,'Entrega que me(nos) foi feita dos seguintes bens da sua propriedade: ' + alltrim(str(TMP2->QTDANIM2)) +' animais ',oFont12)  

		oPrn:Line (nRow1 + 1080,0100,nRow1 + 1080,0850 ) 	   
		oPrn:Say(nRow1 + 1105,0120 ,alltrim(TMP2->ABTEXT72),oFont12)  //'AVALISTA - ' + mv_par03  
		oPrn:Say(nRow1 + 1147,0100 ,TMP2->ABTEXT82,oFont12) // 'CPF : ' + transform(mv_par04,'@R 999.999.999-99') 		   

		oPrn:Line (nRow1 + 1270,0100,nRow1 + 1270,0850 )
		oPrn:Say(nRow1 + 1267,0120 ,TMP2->ABTEXT92,oFont12) //'AVALISTA - ' + mv_par05 	
		oPrn:Say(nRow1 + 1309,0100 ,TMP2->ABTEXT102,oFont14) //'CPF : ' +  transform(mv_par06,'@R 999.999.999-99')

		oPrn:Say(nRow1 + 1485,0100 ,TMP2->ABTEXT112,oFont14)	// 'EMITENTE: FRIGORIFICO SILVA IND E COM LTDA'	
		oPrn:Say(nRow1 + 1555,0100 ,TMP2->ABTEXT122,oFont12) //'ENDEREÇO: BR 392 Km 8, Santa Maria-RS-CEP 97001-970' 


		oPrn:Line (nRow1 + 1270,1600,nRow1 + 1270,2300 )
		oPrn:Say(nRow1 + 1285,01620 ,TMP2->ABTEXT132,oFont12)	// 'ASSINATURA' 
		oPrn:Say(nRow1 + 1345,01640 ,TMP2->ABTEXT142,oFont12)  // 'CGC: 88728027/0001-46'
		oPrn:Say(nRow1 + 1615,0100 ,TMP2->ABTEXT152,oFont12)  //'OBSERVAÇÃO: Caso resolva não descontar esta promissória, é preciso remetê-la de volta ao Frigorífico Silva,' 
		oPrn:Say(nRow1 + 1675,0100 ,TMP2->ABTEXT162,oFont12)
		oPrn:Line (nRow1 + 1725,0100,nRow1 + 1725,2300 )


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ SEGUNDA PARTE                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

		oPrn:Say(nRow2 + 0050 ,0700 ,TMP2->L3482,oFont24) 
		oPrn:Say(nRow2 + 0190 ,550 ,TMP2->L3492,oFont10) 

		if TMP2->IMPNPR2 > 0
			oPrn:Say(nRow2 + 0230 ,550 ,TMP2->L3522,oFont10)    //oPrn:Say(nRow1 + 0230 ,550 ,'[Via de Negociação nº.: '+ alltrim(strzero(TMP->IMPNPR+1,3)) + ']',oFont10) 
		endif

		oPrn:SayBitmap(nRow2 + 0100,100,TMP2->BITMAPI2,0350,0245) // Imagem	   

		oPrn:Line (nRow2 + 0280,1800,nRow2 + 0350,1800 )  //Vertical 1 ( Quadrado do Valor da Promissória )
		oPrn:Line (nRow2 + 0280,1800,nRow2 + 0280,2300 )
		oPrn:Line (nRow2 + 0350,1800,nRow2 + 0350,2300 )
		oPrn:Line (nRow2 + 0280,2300,nRow2 + 0350,2300 )


		oPrn:Say(nRow2 + 0190 ,1200 ,alltrim(TMP2->DATAI2),oFont14)
		oPrn:Say(nRow2 + 0290 ,1890 ,'R$ ' + alltrim(transform(TMP2->VALOR2,'@E 999,999,999.99')),oFont16)   

		oPrn:Say(nRow2 + 0410,0450 ,alltrim(TMP2->ABTEXT12),oFont14) //  _DataV + ' por esta NOTA PROMISSORIA RURAL na praça de ' // 85_DataV    :=  'A ' + _cDiaV + ' de ' + _cMesV + ' de ' + _cAnoV
		oPrn:Say(nRow2 + 0480,0100 ,TMP2->ABTEXT22,oFont14)   //aBolText[2],oFont14)    'Santa Maria - RS pagaremos a '   
		oPrn:Say(nRow2 + 0480,0850 ,alltrim(alltrim(TMP2->A2NOME2)),oFont14n) //aBolText[16],oFont14n) 
		oPrn:Say(nRow2 + 0560,0100 ,TMP2->ABTEXT42,oFont14)  //,aBolText[4],oFont14)  'ou à sua ordem, a quantia de :' 

		oPrn:Say(nRow2 + 0630 ,100 ,substr(alltrim(extenso(TMP2->VALOR2,.f.,1)),1,75),oFont14n)   //substr(_cExtenso,1,75),oFont14n)   
		oPrn:Say(nRow2 + 0700 ,100 ,substr(alltrim(extenso(TMP2->VALOR2,.f.,1)),76,75),oFont14n) //,substr(_cExtenso,76,75),oFont14n) 

		If TMP2->MARC = 'S'
			oPrn:Say(nRow2 + 0770,0100 ,'Valor de compra que lhe(s) fiz(emos) conforme NFs nº: ' + substr(alltrim(TMP2->NUMTIT22),1,122),oFont14)
		Else
			oPrn:Say(nRow2 + 0770,0100 ,'Valor de compra que lhe(s) fiz(emos) conforme NF nº: ' + substr(alltrim(TMP2->NUMTIT22),1,122),oFont14)
		Endif
		oPrn:Say(nRow2 + 0840,0100 ,substr(alltrim(TMP2->NUMTIT22),123,180),oFont14)
		oPrn:Say(nRow2 + 0910,0100 ,'Entrega que me(nos) foi feita dos seguintes bens da sua propriedade: ' + alltrim(str(TMP2->QTDANIM2)) +' animais ',oFont12)  

		oPrn:Line (nRow2 + 1080,0100,nRow2 + 1080,0850 ) 	   
		oPrn:Say(nRow2 + 1105,0120 ,alltrim(TMP2->ABTEXT72),oFont12)  //'AVALISTA - ' + mv_par03  
		oPrn:Say(nRow2 + 1147,0100 ,TMP2->ABTEXT82,oFont12) // 'CPF : ' + transform(mv_par04,'@R 999.999.999-99') 		   

		oPrn:Line (nRow2 + 1270,0100,nRow2 + 1270,0850 )
		oPrn:Say(nRow2 + 1267,0120 ,TMP2->ABTEXT92,oFont12) //'AVALISTA - ' + mv_par05 	
		oPrn:Say(nRow2 + 1309,0100 ,TMP2->ABTEXT102,oFont14) //'CPF : ' +  transform(mv_par06,'@R 999.999.999-99')

		oPrn:Say(nRow2 + 1485,0100 ,TMP2->ABTEXT112,oFont14)	// 'EMITENTE: FRIGORIFICO SILVA IND E COM LTDA'	

		oPrn:Say(nRow2 + 1555,0100 ,TMP2->ABTEXT122,oFont12) //'ENDEREÇO: BR 392 Km 8, Santa Maria-RS-CEP 97001-970' 
		oPrn:Line (nRow2 + 1270,1600,nRow2 + 1270,2300 )
		oPrn:Say(nRow2 + 1285,01620 ,TMP2->ABTEXT132,oFont12)	// 'ASSINATURA' 
		oPrn:Say(nRow2 + 1345,01640 ,TMP2->ABTEXT142,oFont12)  // 'CGC: 88728027/0001-46'
		oPrn:Say(nRow2 + 1615,0100 ,TMP2->ABTEXT152,oFont12)  //'OBSERVAÇÃO: Caso resolva não descontar esta promissória, é preciso remetê-la de volta ao Frigorífico Silva,' 
		oPrn:Say(nRow2 + 1675,0100 ,TMP2->ABTEXT162,oFont12)
		oPrn:Line (nRow2 + 1725,0100,nRow2 + 1725,2300 )



		oPrn:EndPage()       // Finaliza a página



		TMP2->(DbSkip())

	EndDo


	oPrn:Preview()    // Visualiza antes de imprimir

	DbSelectArea("SE2")
	RetIndex("SE2")

Return  

Static Function PrepDados(_CM)

	_cSeq := ''
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek(xFilial("SA2")+SE2->(E2_FORNECE +E2_LOJA),.T.)

	If !Found()
		MsgBox("Atencao! Fornecedor "+SE2->E2_FORNECE+"/"+SE2->E2_LOJA+" Nao Cadastrado." ,"ML_ERRO","STOP")
		DbSelectArea("SE2")
		DbSkip()
		//Loop
		Break
	Endif    		

	_cNumTit  := SE2->E2_NUM + " " + SE2->E2_PARCELA  

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
	_cDiaV    := substr(dtos(SE2->E2_VENCTO),7,2) 
	_cMesV    := MesExtenso(SE2->E2_VENCTO)
	_cAnoV    := substr(dtos(SE2->E2_VENCTO),1,4) 
	_DataV    :=  'A ' + _cDiaV + ' de ' + _cMesV + ' de ' + _cAnoV
	_cSeq := iif(empty(SE2->E2_NUMNPR), strzero(GETMV("SI_SEQNPR")+1,9) ,SE2->E2_NUMNPR)

	reclock('TMP',.t.)
	TMP->PREFIXO  	:= SE2->E2_PREFIXO			// Número do título
	TMP->NUMTIT  	:= _cNumTit						// Número do título
	TMP->NUMTIT2	:= _cNumTit
	TMP->EMISSAO 	:= SE2->E2_EMISSAO			// Data da emissão do título
	TMP->DTBOL 		:= Date()						// Data da emissão do boleto
	TMP->DTVENC 	:= SE2->E2_VENCTO 			// Data do vencimento
	TMP->VALOR  	:= SE2->E2_VALOR				// Valor do título
	TMP->NUMNPR 	:= SE2->E2_NUMNPR 			// Sequencial de impressão da NPR
	TMP->IMPNPR 	:= SE2->E2_IMPNPR				// Numero de impressões realizadas desta NPR
	TMP->FORNLOJA 	:= SE2->(E2_FORNECE+E2_LOJA)
	TMP->QTDANIM := _cQanim
	TMP->A2NOME := AllTrim(SA2->A2_NOME)	// Razão Social
	TMP->A2COD	:= AllTrim(SA2->A2_COD) 	// Código
	TMP->A2CGC	:= AllTrim(SA2->A2_CGC)    // CNPJ  

	/* Acrescentar na tem*/

	TMP->DATAI	 := _Data        // 30
	TMP->DATAVI	 := _DataV       // 30
	TMP->ABTEXT1 := _DataV + ' por esta NOTA PROMISSORIA RURAL na praça de ' // 85_DataV    :=  'A ' + _cDiaV + ' de ' + _cMesV + ' de ' + _cAnoV
	TMP->ABTEXT2 := 'Santa Maria - RS pagaremos a '        //35
	TMP->ABTEXT3 := alltrim(TMP->A2NOME)   //100
	TMP->ABTEXT4 := 'ou à sua ordem, a quantia de :'	//35					
	TMP->ABTEXT5 := 'Valor de compra que lhe(s) fiz(emos) conforme NF nº: ' + TMP->NUMTIT // 75
	TMP->ABTEXT6 := 'Entrega que me(nos) foi feita dos seguintes bens da sua propriedade: ' + alltrim(str(TMP->QTDANIM)) +' animais '//105
	TMP->ABTEXT7 := 'AVALISTA - ' + mv_par03  //   140
	TMP->ABTEXT8 := 'CPF : ' + transform(mv_par04,'@R 999.999.999-99') //100
	TMP->ABTEXT9 := 'AVALISTA - ' + mv_par05 	//140		
	TMP->ABTEXT10 := 'CPF : ' +  transform(mv_par06,'@R 999.999.999-99')//100			
	TMP->ABTEXT11 := 'EMITENTE: FRIGORIFICO SILVA IND E COM LTDA'    //48
	TMP->ABTEXT12 := 'ENDEREÇO: BR 392 Km 8, Santa Maria-RS-CEP 97001-970' //  60
	TMP->ABTEXT13 := 'ASSINATURA' // 25
	TMP->ABTEXT14 := 'CGC: 88728027/0001-46' ///35
	TMP->ABTEXT15 	:= 'OBSERVAÇÃO: Caso resolva não descontar esta promissória, é preciso remetê-la de volta ao Frigorífico Silva,' //130
	TMP->ABTEXT16 	:= 'de modo que a mesma chegue em nossas mãos dois dias úteis antes do vencimento.' //100 																	
	TMP->VAROK		:= SE2->E2_OK    // 20
	TMP->BITMAPI	:= '\system\silva.bmp'
	TMP->CSEQI		:= _cSeq
	TMP->CVALORI	:= 'R$ ' + alltrim(transform(SE2->E2_VALOR,'@E 999,999,999.99')) 
	TMP->L348		:= 'NOTA PROMISSÓRIA RURAL'
	TMP->L349		:= 'NPR Nº.: ' + _cSeq
	TMP->L352		:= '[Via de Negociação nº.: '+ alltrim(strzero(SE2->E2_IMPNPR+1,3)) + ']'	
	TMP->L407		:=	'Via Não Negociável'	

	msunlock() 

	/* gravar dados na SE2*/

	reclock('SE2',.f.)

	if empty(SE2->E2_NUMNPR)
		PUTMV('SI_SEQNPR',val(_cSeq)) 
		SE2->E2_NUMNPR := _cSeq
	endif     

	SE2->E2_IMPNPR := TMP->IMPNPR + 1

	msunlock()
	_cSeq := ''

Return 


Static Function geraTmp()  
	Local _aArqTrb    := {}    

	aadd(aCampos,{"PREFIXO" 	,"Prefixo Nota"   		   	,"@!"})	                                          		
	aadd(aCampos,{"FORNLOJA" 	,"Forn. Loja"   		   	,"@!"})	                                          
	aadd(aCampos,{"NUMTIT" 		,"Num. Titulo"   				,"@!"})
	aadd(aCampos,{"NUMTIT2" 	,"Num. Todos Títulos"  		,"@!"})
	aadd(aCampos,{"EMISSAO" 	,"Dt. Emiss. Titulo"		  	,"99/99/99"})
	aadd(aCampos,{"DTBOL"   	,"Dt. Emiss. Boleto"			,"99/99/99"})   
	aadd(aCampos,{"DTVENC"	 	,"Dt. Vencimento"			 	,"99/99/99"})         
	aadd(aCampos,{"VALOR"  	   ,"Valor Titulo"				,"@E 999,999,999,999,999.99"})         
	aadd(aCampos,{"NUMNPR"     ,"Seq. Impress. NPR"  		,"@!"})
	aadd(aCampos,{"IMPNPR"     ,"Nr. Impress. Real. NPR"	,"@E 99"})
	aadd(aCampos,{"QTDANIM"    ,"Quant. Animais" 			,"@E 9,999,999,999.9999999"})
	aadd(aCampos,{"A2NOME" 	,"Nome Forn."   		   	,"@!"})	                                          
	aadd(aCampos,{"A2COD" 	,"Codigo Forn."   		   ,"@!"})
	aadd(aCampos,{"A2CGC" 	,"CGC Forn."   		   ,"@R 99.999.999/9999-99"})	                                          	                                          
	// New --   
	aadd(aCampos,{"DATAI" 	,"Data Impressão"   		   	,"@!"})
	aadd(aStru,{"DATAI"  , "C",  80,  0,   "@!"        	 			   	, 'Data Impressão'          	})		
	aadd(aCampos,{"DATAVI" 	,"Data Venc. Impressão"   		   	,"@!"})
	aadd(aStru,{"DATAVI"  , "C",  30,  0,   "@!"        	 			   	, 'Data Venc. Impressão'          	})		  	
	aadd(aCampos,{"ABTEXT1" 	,"Texto1 do Boleto "   		   	,"@!"})
	aadd(aStru,{"ABTEXT1"  , "C",  85,  0,   "@!"        	 			   	, 'Texto1 do Boleto'          	})		
	aadd(aCampos,{"ABTEXT2" 	,"Texto2 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT2"  , "C",  35,  0,   "@!"        	 			   	, 'Texto2 do Boleto'          	})
	aadd(aCampos,{"ABTEXT3" 	,"Texto3 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT3"  , "C",  100,  0,   "@!"        	 			   	, 'Texto3 do Boleto'          	})
	aadd(aCampos,{"ABTEXT4" 	,"Texto4 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT4"  , "C",  35,  0,   "@!"        	 			   	, 'Texto4 do Boleto'          	})
	aadd(aCampos,{"ABTEXT5" 	,"Texto5 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT5"  , "C",  75,  0,   "@!"        	 			   	, 'Texto5 do Boleto'          	})
	aadd(aCampos,{"ABTEXT6" 	,"Texto6 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT6"  , "C",  105,  0,   "@!"        	 			   	, 'Texto6 do Boleto'          	})				
	aadd(aCampos,{"ABTEXT7" 	,"Texto7 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT7"  , "C",  140,  0,   "@!"        	 			   	, 'Texto7 do Boleto'          	})					
	aadd(aCampos,{"ABTEXT8" 	,"Texto8 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT8"  , "C",  100,  0,   "@!"        	 			   	, 'Texto8 do Boleto'          	})					
	aadd(aCampos,{"ABTEXT9" 	,"Texto9 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT9"  , "C",  140,  0,   "@!"        	 			   	, 'Texto9 do Boleto'          	})					
	aadd(aCampos,{"ABTEXT10" 	,"Texto10 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT10"  , "C",  100,  0,   "@!"        	 			   	, 'Texto10 do Boleto'          	})
	aadd(aCampos,{"ABTEXT11" 	,"Texto11 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT11"  , "C",  48,  0,   "@!"        	 			   	, 'Texto11 do Boleto'          	})			
	aadd(aCampos,{"ABTEXT12" 	,"Texto12 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT12"  , "C",  60,  0,   "@!"        	 			   	, 'Texto12 do Boleto'          	})	
	aadd(aCampos,{"ABTEXT13" 	,"Texto13 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT13"  , "C",  25,  0,   "@!"        	 			   	, 'Texto13 do Boleto'          	})	
	aadd(aCampos,{"ABTEXT14" 	,"Texto14 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT14"  , "C",  35,  0,   "@!"        	 			   	, 'Texto14 do Boleto'          	})	
	aadd(aCampos,{"ABTEXT15" 	,"Texto15 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT15"  , "C",  130,  0,   "@!"        	 			   	, 'Texto15 do Boleto'          	})	
	aadd(aCampos,{"ABTEXT16" 	,"Texto11 do Boleto"   		   	,"@!"})
	aadd(aStru,{"ABTEXT16"  , "C",  100,  0,   "@!"        	 			   	, 'Texto11 do Boleto'          	})	
	aadd(aCampos,{"VAROK" 	,"Marcação do Tit. para impressão "   		   	,"@!"})
	aadd(aStru,{"VAROK"  , "C",  10,  0,   "@!"        	 			   	, 'Marcação do Tit. para impressão'          	})	
	aadd(aCampos,{"BITMAPI" 	,"Figura de Impressão"   		   	,"@!"})
	aadd(aStru,{"BITMAPI"  , "C",  20,  0,   "@!"        	 			   	, 'Figura de Impressão'          	})																		
	aadd(aCampos,{"CSEQI" 	,"Sequencial de Impressao"   		   	,"@!"})
	aadd(aStru,{"CSEQI"  , "C",  20,  0,   "@!"        	 			   	, 'Sequencial de Impressao'          	})
	aadd(aCampos,{"CVALORI" 	,"Valor de Impressão"   		   	,"@!"})
	aadd(aStru,{"CVALORI"  , "C",  100,  0,   "@!"        	 			   	, 'Valor de Impressão'          	})
	aadd(aCampos,{"L348" 	,"Valor de Impressão"   		   	,"@!"})
	aadd(aStru,{"L348"  , "C",  45,  0,   "@!"        	 			   	, 'Valor de Impressão'          	})	
	aadd(aCampos,{"L349" 	,"Nr. NPR"   		   	,"@!"})
	aadd(aStru,{"L349"  , "C",  45,  0,   "@!"        	 			   	, 'Nr. NPR'          	})	
	aadd(aCampos,{"L352" 	,"Nr. NPR Int."   		   	,"@!"})
	aadd(aStru,{"L352"  , "C", 95,  0,   "@!"        	 			   	, 'Nr. NPR Int.'          	})			
	aadd(aCampos,{"L407" 	,"Tipo Via"   		   	,"@!"})
	aadd(aStru,{"L407"  , "C",35,  0,   "@!"        	 			   	, 'Tipo Via'          	})		

	// Campos Antigos

	aadd(aStru,{"PREFIXO"  , "C",  03,  0,   "@!"        	 			   	, 'Prefixo Nota'          	})				
	aadd(aStru,{"FORNLOJA"  , "C",  08,  0,   "@!"        	 			   	, 'Forn. Loja'          	})	
	aadd(aStru,{"NUMTIT"  	, "C",  13,  0,   "@!"        	 					, 'Num. Titulo'        		})
	aadd(aStru,{"NUMTIT2"  	, "C",  180,  0,   "@!"        	 					, 'Num. Todos Títulos'  	})
	aadd(aStru,{"EMISSAO"  	, "D",  08,  0,   "99/99/99"    	  					, 'Dt. Emiss. Titulo'  		})
	aadd(aStru,{"DTBOL"   	, "D",  08,  0,   "99/99/99"       					, 'Dt. Emiss. Boleto'  		})
	aadd(aStru,{"DTVENC"		, "D",  08,  0,   "99/99/99"							, 'Dt. Vencimento'     		})
	aadd(aStru,{"VALOR"   	, "N",  17,  2,   "@E 999,999,999,999,999.99"	, 'Valor Titulo'	  	  		})
	aadd(aStru,{"NUMNPR"   	, "C",  09,  0,   "@!"       				   	   , 'Seq. Impress. NPR'  		})
	aadd(aStru,{"IMPNPR"   	, "N",  20,  0,   "@E 999"       				   	, 'Nr. Impress. Real. NPR' })
	aadd(aStru,{"QTDANIM"   , "N",  18,  7,   "@E 9,999,999,999.9999999"    , 'Quant. Animais'  			})	
	aadd(aStru,{"A2NOME"    , "C",  40,  0,   "@!"        	 			   	, 'Forn. Loja'          	})	
	aadd(aStru,{"A2COD"     , "C",  06,  0,   "@!"        	 			   	, 'Codigo Forn'          	})	
	aadd(aStru,{"A2CGC"     , "C",  14,  0,   "@R 99.999.999/9999-99"       , 'CGC Forn'             	})

	If Select('TMP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	//dbcreate(cArq,aStru)
	// ProcData 04/2023 - Chamada para criar arquivo de trabalho
	U_ArqTrb("Cria", "TMP", aStru, {"PREFIXO","NUMTIT"}, @_aArqTrb)

	//DbSelectArea('TMP')
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	TMP->(DbGoTop())
	//IndRegua("TMP",cArq,"PREFIXO+NUMTIT",,,OemToAnsi("Selecionando Registros..."))

return

Static Function geraTmp2()
	Local _aArqTrb2    := {}

	aadd(aCampos2,{"PREFIXO2" 	,"Prefixo Nota"   		   	,"@!"})
	aadd(aCampos2,{"FORNLOJA2" 	,"Forn. Loja"   		   	,"@!"})
	aadd(aCampos2,{"NUMTIT12" 		,"Num. Titulo"   				,"@!"})
	aadd(aCampos2,{"NUMTIT22" 	,"Num. Todos Títulos"  		,"@!"})
	aadd(aCampos2,{"EMISSAO2" 	,"Dt. Emiss. Titulo"		  	,"99/99/99"})
	aadd(aCampos2,{"DTBOL2"   	,"Dt. Emiss. Boleto"			,"99/99/99"})
	aadd(aCampos2,{"DTVENC2"	 	,"Dt. Vencimento"			 	,"99/99/99"})
	aadd(aCampos2,{"VALOR2"  	   ,"Valor Titulo"				,"@E 999,999,999,999,999.99"})
	aadd(aCampos2,{"NUMNPR2"     ,"Seq. Impress. NPR"  		,"@!"})
	aadd(aCampos2,{"IMPNPR2"     ,"Nr. Impress. Real. NPR"	,"@E 999"})
	aadd(aCampos2,{"QTDANIM2"    ,"Quant. Animais" 			,"@E 9,999,999,999.9999999"})
	aadd(aCampos2,{"A2NOME2" 	,"Nome Forn."   		   	,"@!"})
	aadd(aCampos2,{"A2COD2" 	,"Codigo Forn."   		   ,"@!"})
	aadd(aCampos2,{"A2CGC2" 	,"CGC Forn."   		   ,"@R 99.999.999/9999-99"})
	aadd(aCampos2,{"DATAI2" 	,"Data Impressão"   		   	,"@!"})	  
	aadd(aCampos2,{"DATAVI2" 	,"Data Venc. Impressão"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT12" 	,"Texto1 do Boleto "   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT22" 	,"Texto2 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT32" 	,"Texto3 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT42" 	,"Texto4 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT52" 	,"Texto5 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT62" 	,"Texto6 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT72" 	,"Texto7 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT82" 	,"Texto8 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT92" 	,"Texto9 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT102" 	,"Texto10 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT112" 	,"Texto11 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT122" 	,"Texto12 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT132" 	,"Texto13 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT142" 	,"Texto14 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT152" 	,"Texto15 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"ABTEXT162" 	,"Texto11 do Boleto"   		   	,"@!"})
	aadd(aCampos2,{"VAROK2" 	,"Marcação do Tit. para impressão "   		   	,"@!"})
	aadd(aCampos2,{"BITMAPI2" 	,"Figura de Impressão"   		   	,"@!"})
	aadd(aCampos2,{"CSEQI2" 	,"Sequencial de Impressao"   		   	,"@!"})
	aadd(aCampos2,{"CVALORI2" 	,"Valor de Impressão"   		   	,"@!"})
	aadd(aCampos2,{"L3482" 	,"Valor de Impressão"   		   	,"@!"})
	aadd(aCampos2,{"L3492" 	,"Nr. NPR"   		   	,"@!"})
	aadd(aCampos2,{"L3522" 	,"Nr. NPR Int."   		   	,"@!"})
	aadd(aCampos2,{"L4072" 	,"Tipo Via"   		   	,"@!"})
	aadd(aCampos2,{"MARC" 	,"Marc. se Possui + de 1 nota"   		   	,"@!"})

	// New --
	// Campos Antigos

	aadd(aStru2,{"PREFIXO2"    , "C",  03,  0,   "@!"        	 			   	, 'Prefixo Nota'          	})
	aadd(aStru2,{"FORNLOJA2"   , "C",  08,  0,   "@!"        	 			   	, 'Forn. Loja'          	})
	aadd(aStru2,{"NUMTIT12"  	, "C",  13,  0,   "@!"        	 					, 'Num. Titulo'        		})
	aadd(aStru2,{"NUMTIT22"  	, "C",  180,  0,   "@!"        	 					, 'Num. Todos Títulos'  	})
	aadd(aStru2,{"EMISSAO2"  	, "D",  08,  0,   "99/99/99"    	  					, 'Dt. Emiss. Titulo'  		})
	aadd(aStru2,{"DTBOL2"   	, "D",  08,  0,   "99/99/99"       					, 'Dt. Emiss. Boleto'  		})
	aadd(aStru2,{"DTVENC2"		, "D",  08,  0,   "99/99/99"							, 'Dt. Vencimento'     		})
	aadd(aStru2,{"VALOR2"   	, "N",  17,  2,   "@E 999,999,999,999,999.99"	, 'Valor Titulo'	  	  		})
	aadd(aStru2,{"NUMNPR2"   	, "C",  09,  0,   "@!"       				   	   , 'Seq. Impress. NPR'  		})
	aadd(aStru2,{"IMPNPR2"   	, "N",  20,  0,   "@E 999"      				   	, 'Nr. Impress. Real. NPR' })
	aadd(aStru2,{"QTDANIM2"   , "N",  18,  7,   "@E 9,999,999,999.9999999"     , 'Quant. Animais'  			})
	aadd(aStru2,{"A2NOME2"    , "C",  40,  0,   "@!"        	 			   	   , 'Forn. Loja'          	})
	aadd(aStru2,{"A2COD2"     , "C",  06,  0,   "@!"        	 			   	   , 'Codigo Forn'          	})
	aadd(aStru2,{"A2CGC2"     , "C",  14,  0,   "@R 99.999.999/9999-99"        , 'CGC Forn'             	})	
	aadd(aStru2,{"DATAI2"  , "C",  80,  0,   "@!"        	 			   	      , 'Data Impressão'          	})		
	aadd(aStru2,{"DATAVI2"  , "C",  40,  0,   "@!"        	 			   	   , 'Data Venc. Impressão'          	})
	aadd(aStru2,{"ABTEXT12"  , "C",  85,  0,   "@!"        	 			   	   , 'Texto1 do Boleto'          	})
	aadd(aStru2,{"ABTEXT22"  , "C",  35,  0,   "@!"        	 			   	, 'Texto2 do Boleto'          	})
	aadd(aStru2,{"ABTEXT32"  , "C",  100,  0,   "@!"        	 			   	, 'Texto3 do Boleto'          	})
	aadd(aStru2,{"ABTEXT42"  , "C",  35,  0,   "@!"        	 			   	, 'Texto4 do Boleto'          	})
	aadd(aStru2,{"ABTEXT52"  , "C",  75,  0,   "@!"        	 			   	, 'Texto5 do Boleto'          	})
	aadd(aStru2,{"ABTEXT62"  , "C",  105,  0,   "@!"        	 			   	, 'Texto6 do Boleto'          	})
	aadd(aStru2,{"ABTEXT72"  , "C",  140,  0,   "@!"        	 			   	, 'Texto7 do Boleto'          	})
	aadd(aStru2,{"ABTEXT82"  , "C",  100,  0,   "@!"        	 			   	, 'Texto8 do Boleto'          	})
	aadd(aStru2,{"ABTEXT92"  , "C",  140,  0,   "@!"        	 			   	, 'Texto9 do Boleto'          	})
	aadd(aStru2,{"ABTEXT102"  , "C",  100,  0,   "@!"        	 			   	, 'Texto10 do Boleto'          	})
	aadd(aStru2,{"ABTEXT112"  , "C",  48,  0,   "@!"        	 			   	, 'Texto11 do Boleto'          	})
	aadd(aStru2,{"ABTEXT122"  , "C",  60,  0,   "@!"        	 			   	, 'Texto12 do Boleto'          	})
	aadd(aStru2,{"ABTEXT132"  , "C",  25,  0,   "@!"        	 			   	, 'Texto13 do Boleto'          	})
	aadd(aStru2,{"ABTEXT142"  , "C",  35,  0,   "@!"        	 			   	, 'Texto14 do Boleto'          	})
	aadd(aStru2,{"ABTEXT152"  , "C",  130,  0,   "@!"        	 			   	, 'Texto15 do Boleto'          	})
	aadd(aStru2,{"ABTEXT162"  , "C",  100,  0,   "@!"        	 			   	, 'Texto11 do Boleto'          	})
	aadd(aStru2,{"VAROK2"  , "C",  10,  0,   "@!"        	 			   	, 'Marcação do Tit. para impressão'          	})
	aadd(aStru2,{"BITMAPI2"  , "C",  20,  0,   "@!"        	 			   	, 'Figura de Impressão'          	})
	aadd(aStru2,{"CSEQI2"  , "C",  20,  0,   "@!"        	 			   	, 'Sequencial de Impressao'          	})
	aadd(aStru2,{"CVALORI2"  , "C",  100,  0,   "@!"        	 			   	, 'Valor de Impressão'          	})
	aadd(aStru2,{"L3482"  , "C",  45,  0,   "@!"        	 			   	, 'Valor de Impressão'          	})
	aadd(aStru2,{"L3492"  , "C",  45,  0,   "@!"        	 			   	, 'Nr. NPR'          	})
	aadd(aStru2,{"L3522"  , "C", 95,  0,   "@!"        	 			   	, 'Nr. NPR Int.'          	})
	aadd(aStru2,{"L4072"  , "C",35,  0,   "@!"        	 			   	, 'Tipo Via'          	})		
	aadd(aStru2,{"MARC"  , "C",2,  0,   "@!"        	 			   	, 'Marc. se Possui + de 1 nota'          	})

	If Select('TMP2')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP2->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	//dbcreate(cArq2,aStru2) 
	// ProcData 04/2023 - Chamada para criar arquivo de trabalho
	U_ArqTrb("Cria", "TMP2", aStru2, {"PREFIXO2","NUMTIT12"}, @_aArqTrb2)

	//DbSelectArea('TMP2')
	//dbUseArea( .T.,,cArq2,"TMP2", .F. , .F. )                                         

	TMP2->(DbGoTop())
	//IndRegua("TMP2",cArq2,"PREFIXO2+NUMTIT12",,,OemToAnsi("Selecionando Registros da TMP2..."))

return
