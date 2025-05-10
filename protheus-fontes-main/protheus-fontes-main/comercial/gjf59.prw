#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF59     ºGiuliano José Forgiarini   º Data ³  30/09/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Faltas                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF59()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio       "
	Local cDesc2        := "de Manifesto de carga,discriminando apenas as quantidades"
	Local cDesc3        := "dos produtos em cada carregamento.                       "
	//Local cPict          := ""
	Local titulo       	:= "RELATORIO DE FALTAS EM CARGA"
	Local nLin         	:= 80
	Local Cabec1       	:= "     Pre-ped.  Cliente/Lj         Descrição                     "
	Local Cabec2       	:= "Codigo  Produto           C.Prev. C.Real.  P.Prev.   P.Real.   P.Dif  C.Dif Prior"
	//Local imprime      	:= .T.
	Local aOrd := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private Tamanho     := "P"
	Private nomeprog    := "GJF59" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "GJF59"
	//Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF59" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem
	cQuery := " SELECT ZZ3_NUM AS PRECAR,ZZ4_NUM AS PREPED, ZZ5_COD AS COD,ZZ5_DESC AS DESCRI,ZZ5_PRIORI AS PRIORI,ZZ4_PCOMPR AS PCOMPR,"+;
	" SUM(ZZ5_QRCAIX) AS QRCAIX,SUM(ZZ5_QRPESO) AS QRPESO,"+;
	" SUM(ZZ5_QPCAIX) AS QPCAIX,SUM(ZZ5_QPPESO) AS QPPESO "+;
	" FROM " + RetSqlName("ZZ3") + " ZZ3," +;
	RetSqlName("ZZ4") + " ZZ4," +;
	RetSqlName("ZZ5") + " ZZ5 " +;
	" WHERE ZZ3.D_E_L_E_T_ <> '*' " +;
	" AND ZZ4.D_E_L_E_T_ <> '*' " +;
	" AND ZZ5.D_E_L_E_T_ <> '*' " +;
	" AND (ZZ3.ZZ3_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "')" +;
	" AND ZZ3.ZZ3_NUM = ZZ4.ZZ4_PRECAR " +;
	" AND ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM "+;   
	" AND (ZZ3.ZZ3_STATUS = 'E' OR ZZ3.ZZ3_STATUS = 'F')"+;   
	" AND ZZ5.ZZ5_STATUS <> 'E' AND "+;       
	" ZZ3_FILIAL = '" + FWxFilial("ZZ3") + "' AND"+;  
	" ZZ4_FILIAL = '" + FWxFilial("ZZ4") + "' AND"+;
	" ZZ5_FILIAL = '" + FWxFilial("ZZ5") + "'"+;
	" GROUP BY ZZ3.ZZ3_NUM,ZZ4.ZZ4_NUM,ZZ5.ZZ5_COD,ZZ5.ZZ5_DESC,ZZ5.ZZ5_PRIORI,ZZ4.ZZ4_PCOMPR"+;
	" ORDER BY ZZ3.ZZ3_NUM,ZZ4.ZZ4_NUM,ZZ5.ZZ5_COD,ZZ5.ZZ5_DESC,ZZ5.ZZ5_PRIORI"

	cQuery := ChangeQuery(cQuery)

	If Select("FAL") != 0
		FAL->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "FAL"  

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZZ3')

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FAL->(SetRegua(RecCount()))

	FAL->(dbGoTop())

	_cPreCar := ' '
	_cPrePed := ' '

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	While FAL->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		/*
		_dtAbt 		:= dtoc(GetAdvFVal('SZG',1,FWxfilial('SZG')+ABT->NUMAM,'ZG_DATA'))
		_dData    := ctod('')
		*/

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		ZZ3->(dbsetorder(2))
		ZZ3->(MsSeek(FWxfilial('ZZ3')+alltrim(FAL->PRECAR)))
		// Ajuste inicial	
		IF !empty(mv_par03) .or. !empty(mv_par04)
			If ZZ3->ZZ3_DTCAR < mv_par03 .or. ZZ3->ZZ3_DTCAR > mv_par04			
				FAL->(dbSkip())
				loop
			endif
		Endif
		// Ajuste Final		
		if _cPreCar != FAL->PRECAR
			nlin++
			@nLin,01 PSAY FAL->PRECAR
			@nlin,11 PSAY ZZ3->ZZ3_PLACA
			@nlin,22 PSAY ZZ3->ZZ3_DTCAR
			@nlin,35 PSAY substr(ZZ3->ZZ3_OBS,0,25) 
			@nlin,63 PSAY ZZ3->ZZ3_USUAR
			nlin++
			_cPreCar := FAL->PRECAR
		endif

		If nLin > 59  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if _cPrePed != alltrim(FAL->PREPED)
			nlin++ 
			_cCodCli  := GetAdvFVal('ZZ4','ZZ4_CODCLI',FWxfilial('ZZ4')+alltrim(FAL->PREPED),2)
			_cLoja    := GetAdvFVal('ZZ4','ZZ4_LOJA',FWxfilial('ZZ4')+alltrim(FAL->PREPED),2)
			_cNomeCli := GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1')+_cCodCli+_cLoja,1)

			@nlin,05 psay FAL->PREPED
			@nlin,15 psay _cCodCli + "/" + _cLoja
			@nlin,30 psay _cNomeCli
			@nlin,70 psay FAL->PCOMPR
			nlin++
			_cPrePed := alltrim(FAL->PREPED)
		endif

		@nlin,01 psay FAL->COD
		@nlin,09 psay substr(FAL->DESCRI,1,20)
		@nlin,30 psay transform(FAL->QPCAIX,'@E 999')
		@nlin,35 psay transform(FAL->QRCAIX,'@E 999')
		@nlin,40 psay transform(FAL->QPPESO,'@E 999,999.99')
		@nlin,50 psay transform(FAL->QRPESO,'@E 999,999.99')
		@nlin,60 psay transform(FAL->(QPPESO - QRPESO),'@E 999,999.99')
		@nlin,73 psay transform(FAL->(QPCAIX - QRCAIX),'@E 999')
		@nlin,80 psay FAL->PRIORI

		nLin++ // Avanca a linha de impressao

		FAL->(dbSkip()) // Avanca o ponteiro do registro no arquivo 
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('FAL')

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
