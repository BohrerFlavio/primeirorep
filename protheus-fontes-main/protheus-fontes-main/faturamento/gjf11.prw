#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"
#INCLUDE "msserial.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF11    ºAutor  ³Giuliano Forgiarini º Data ³  08/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesagem de cargas                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaoms - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF11()
/* Config campo Balança - COM1:4800,e,7,2 */
	lOk := .f.
	aObjects := {}                                             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	cPerg := "GJF11"

	If !Pergunte(cPerg,.T.)
		Return
	Endif

	SetMVValue("GJF11", "MV_PAR02", ddatabase, .T.)

	//cCom   := mv_par03                                    //comunicacao balanca
	//nDec   := mv_par04                                    //precisao balanca

	bLegenda1 :=  "u_gjf11stat()==1"
	bLegenda2 :=  "u_gjf11stat()==2"
	aCores2:= { { 'BR_AMARELO','Parcial' },{ 'BR_VERDE'    ,'Completa'} }           // parcial

	aCores := { {bLegenda1, 'BR_AMARELO'},{ bLegenda2, 'BR_VERDE'    } }
	// aberto                  parcial                    completa
	Private cPerg   := "GJF11"
	Private cCadastro := "Pesagens de Veículos - Balança Rodoviaria"
	If (!retCodUsr() = '000021')
		Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
		{"Visualizar","AxVisual",0,2} ,;
		{"1ª Pesagem","u_gjf11inc",0,4} ,;
		{"2ª Pesagem","u_gjf11alt",0,4} ,;
		{"Imprimir","u_GJF11COM",0,2} ,;	//{"Imprimir","u_gjf11imp",0,2} ,;
		{"Relatorio","u_dti206",0,2} ,;	//{"Relatorio","u_gjf25",0,2} ,;
		{"Manut.Pes.","u_gjf11man",0,4} ,;
		{"Legenda","u_gjf11leg",0,2}} //,;
		//{"Excluir","AxDeleta",0,5} }
	Else
		Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
		{"Visualizar","AxVisual",0,2} ,;
		{"1ª Pesagem","u_gjf11inc",0,4} ,;
		{"2ª Pesagem","u_gjf11alt",0,4} ,;
		{"Imprimir","u_GJF11COM",0,2} ,;	//{"Imprimir","u_gjf11imp",0,2} ,;
		{"Imprimir (Versao Antigo)","u_gjf11imp",0,2} ,;
		{"Relatorio","u_dti206",0,2} ,;	//{"Relatorio","u_gjf25",0,2} ,;
		{"Manut.Pes.","u_gjf11man",0,4} ,;
		{"Legenda","u_gjf11leg",0,2}} //,;
		//{"Excluir","AxDeleta",0,5} }
	EndIf

	Private cString := "SZT"

	dbSelectArea("SZT")
	SZT->(dbSetOrder(3))
	SZT->(dbgobottom())
	SET FILTER TO SZT->ZT_DATAE >= mv_par01 .and. SZT->ZT_DATAE <= mv_par02
	mBrowse(6      ,1      ,22     ,75     ,cString, ,,,,1     ,aCores,,,,{|x| AutoRefresh(x)})
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores

	Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros

Return

USer Function gjf11stat()
	Local nRet := 1 // 1parc  2 fech
	IF SZT->ZT_PESOE != 0 .and. empty(SZT->ZT_PESOS)
		nRet := 1
	Endif
	If !empty(SZT->ZT_PESOE) .and. !empty(SZT->ZT_PESOS)
		nRet := 2
	Endif

Return nRet

//ADIÇÃO DE REGISTRO - 1ª pesagem
user function gjf11inc()
	Local nCont
	lOk := .f.
	DEFINE MSDIALOG oDlg TITLE 'Captura 1ª Pesagem' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	begin transaction
		recLock('SZT',.T.)
		RegToMemory("SZT",.T.)
		M->ZT_COD   := GetSx8num('SZT','ZT_COD')
		M->ZT_DATAE := date()
		M->ZT_HORAE := time()
		M->ZT_OPERE := cUserName

		obj := MsMGet():New("SZT" ,SZT->(RECNO()),3   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )
		// inst.  obj.     met. alias,registro      ,oper,p.res,p.res,p.res,vet.campos,vet.coord.,vet.campos.alt, ,
		@ aPosObj[2,1],005      BUTTON 'Captura'   SIZE 47,20 ACTION  U_gjf11ca1()  OBJECT oBtn1
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||u_gjf11oki()},{||u_gjf11nok()})
		If lOk
			// Grava pesagem          e
			M->ZT_STATUS := 'PA'
			M->ZT_PESOS  := 0
			For nCont := 1 To FCount()
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,FWxFilial("SZT"))
				Else
					FieldPut(nCont,M->&(FIELDNAME(nCont)))
				Endif
			Next nCont

			ConfirmSx8()
			MsUnLock()
			u_gjf11imp()
		else
			DisarmTransaction()
			RollBackSx8()
		endif
	end transaction
return


//ALTERACAO DE REGISTRO - 2 PESAGEM
user function gjf11alt()
	Local nCont
	lOk := .f.
	rec := SZT->(RECNO())
	DEFINE MSDIALOG oDlg TITLE 'Captura 2ª Pesagem' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	begin transaction
		recLock('SZT',.F.)
		regtomemory('SZT')
		M->ZT_HORAS := time()
		M->ZT_DATAS := date()
		M->ZT_OPERS := cUserName

		obj := MsMGet():New("SZT" ,rec      ,4   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )
		// inst.  obj.     met. alias,registro      ,oper,p.res,p.res,p.res,vet.campos,vet.coord.,vet.campos.alt, ,
		@ aPosObj[2,1],005      BUTTON 'Captura'   SIZE 47,20 ACTION  U_gjf11ca2()  OBJECT oBtn1
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||u_gjf11oka()},{||u_gjf11nok()})
		If lOk
			// Grava pesagem
			M->ZT_STATUS := 'OK'
			For nCont := 1 To FCount()
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,FWxFilial("SZT"))
				Else
					FieldPut(nCont,M->&(FIELDNAME(nCont)))
				Endif
			Next nCont
			MsUnLock()
			u_gjf11imp()
		else
			DisarmTransaction()
		endif
	end transaction
return


User function gjf11oki()
	if !empty(M->ZT_PLACA) .and. !empty(M->ZT_PESOE) .and. !empty(M->ZT_COD) .and. !empty(M->ZT_TPCARGA) .and. !empty(M->ZT_DATAE)
		lOk := .t.
		Odlg:end()
	else
		Alert('Campos em branco!')
		lOk := .f.
	endif

	_cTransf := M->ZT_TRANSF  //Validação incluida por Fabian Maurer 25/08/12, para verificar se o caminhao
	//é de transf., se SIM nao faz a validaçao abaixo pois a 1º pesagem é feita com Veiculo carregado,
	if _cTransf == 'N'        //se NAO, faz a validaçao pois o Veiculo sera pesado vazio.

		DA3->(DbSetOrder(3))

		if DA3->(MsSeek(FWxfilial('DA3')+M->ZT_PLACA))

			if DA3->DA3_TARA = 0.00  .and. DA3->DA3_FROVEI = '1'
				msgbox('Tara do veículo não cadastrada!','DADOS DO VEICULO INSUFICIENTES','STOP')
				lOk := .f.
			endif

			if DA3->DA3_FROVEI = '1'
				if (M->ZT_PESOE > (DA3->DA3_TARA + 10)) .or. (M->ZT_PESOE < (DA3->DA3_TARA - 10))          //Alteração feita no dia 11/01/14
					//solicitação Matheus Silva(remoção do limite de taras)
					msgbox('Diferença de peso excede 10kg!','LIBERAÇÃO NAO AUTORIZADA','STOP')
					lOk := .f.
				endif
			endif
		endif
	endif

Return lOk

User function gjf11oka()
	if !empty(M->ZT_PLACA) .and. !empty(M->ZT_PESOS) .and. !empty(M->ZT_COD) .and. !empty(M->ZT_TPCARGA)
		lOk := .t.
		Odlg:end()
	else
		Alert('Campos em branco!')
		lOk := .f.
	endif lOk

Return

User function gjf11nok()

	lOk := .f.
	oDlg:end()

Return lOk

user function gjf11ca1()

	if M->ZT_STATUS != 'PA'
		M->ZT_PESOE := u_gjf11cap()
		M->ZT_STATUS := 'PA'
		if M->ZT_PESOE != 0
			//apmsginfo(M->ZT_PESOE,'Pesagem')
		endif
	else
		alert('1ª Pesagem já informada!')
	endif

return

user function gjf11ca2()
	if M->ZT_STATUS != 'OK'
		M->ZT_PESOS := u_gjf11cap()
		M->ZT_STATUS := 'OK'
		if M->ZT_PESOS != 0
			//apmsginfo(M->ZT_PESOS,'Pesagem')
		endif
	else
		alert('2ª Pesagem já informada!')
	endif
return


user Function gjf11cap()

	//se for conexão serial
	if mv_par05 = 1

		nHdll := 0	

		if !MSOpenPort(nHdll,alltrim(mv_par03))
			msgbox("Não foi possível pegar informações da porta(1)!",,"STOP")
			Return 0	 
		endif

		cText := space(15)

		//mswrite(nHdll,"cText")

		if !MsRead(nHdll,@cText)
			msgbox("Não foi possível pegar informações da porta(2)!",,"STOP")
			Return 0
		endif

		inkey(1)
		if empty(cText)
			inkey(1)
			cText := space(15)
			MsRead(nHdll,@cText)		
		endif

		if mv_par06 = 1 //se for portaria antiga	
			do Case
				Case at("p`",cText)> 0
				cPeso := substr(cText,at("p`",cText)+2,6)
				cC := "`"

				Case at("`",cText) > 0
				cPeso := substr(cText,at("`",cText)+1,6)
				cC := "`"

				Case at("p ",cText)> 0
				cPeso := substr(cText,at("p ",cText)+2,6)
				cC := " "

				Otherwise
				cPeso :='000000'
				cC := ""
			Endcase

			cPeso := substr(cText,at("`",cText)+1,6)
			cPeso := substr(cText,at(cC,cText)+1,6)
			nPeso := val(cPeso)/(10** val(mv_par04))

			if valtype(nPeso) == 'N'
				v := npeso
			else
				v     := 0
				nPeso := 0
			endif

		else //senão portaria nova

			cText:= alltrim(cText)

			do Case 

				Case at(")0",cText) > 0
				cPeso := substr(cText,at(")0",cText)+3,7)
				cC := ")0"

				Otherwise
				cPeso :='000000'
				cC := ""   

			Endcase

			//cPeso := substr(cText,at(")",cText)+1,6)
			//cPeso := substr(cText,at(cC,cText)+2,6)
			nPeso := val(cPeso)/(10** val(mv_par04))

			if valtype(nPeso) == 'N'
				v := npeso
			else
				v     := 0
				nPeso := 0
			endif

		endif
		msClosePort(nHdll)

	else//senão é conexão IP

		_cString := PesaIp()

		do Case 

			Case at(")",_cString) > 0
			if mv_par06 == 1
				cPeso := substr(_cString,at(")",_cString)+3,6)
				cC := ")"
			else
				cPeso := substr(_cString,at(")",_cString)+2,7)
				cC := ")"
			endif
			Otherwise
			cPeso :='000000'
			cC := ""   

		Endcase

		nPeso  := val(cPeso)
		v      := npeso 

	endif

	oDlg:Refresh()

Return nPeso

USer Function gjf11leg
	BrwLegenda('Pesagem de Veículos',"Legenda",aCores2)
return

User Function gjf11imp

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "RELATÓRIO DE PESAGEM DE VEICULO"
	//Local cPict          := ""
	Local titulo       := "RELATORIO DE PESAGEM DE VEICULO"
	Local nLin         := 80
	Local Cabec1       := "                   FRIGORIFICO SILVA INDUSTRIA E COMERCIO LTDA."
	Local Cabec2       := "              BR-392 Km 08 - Santa Maria - RS    Fone: (55)2103-2525"
	Local Cabec3       := "                   INDUSTRIA DE RACOES PASSO DAS TROPAS LTDA."       // Criado por Fabian Maurer dia 24/09/12
	//Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private nomeprog         := "gjf11imp" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	//Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "gjf11" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString := "SZT"

	dbSelectArea("SZT")
	SZT->(dbSetOrder(3))

	wnrel := SetPrint(cString,NomeProg,,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,'P',,.F.,,,.F.,)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if cEmpAnt == '01'                                         //	Criado por Fabian Maurer para inserir o nome da graxaria no relatorio dia 24/09/12
		RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

	else
		RptStatus({|| RunReport(Cabec3,Cabec2,Titulo,nLin) },Titulo)
	endif

Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//Local nOrdem
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,'P',nTipo)
	nlin := 11

	@nlin,05 psay 'PLACA: '
	@nlin,45 psay 'COD. PESAGEM:      '+ SZT->ZT_COD
	@nlin,12 psay SZT->ZT_PLACA
	nlin += 2
	@nlin,05 psay 'DATA ENTRADA:      ' + transform(SZT->ZT_DATAE,'@E ##/##/##')
	@nlin,45 psay 'DATA SAIDA:          ' + transform(SZT->ZT_DATAS,'@E ##/##/##')
	nlin++
	@nlin,05 psay 'HORA ENTRADA:         ' + SZT->ZT_HORAE
	@nlin,45 psay 'HORA SAIDA:             ' + SZT->ZT_HORAS
	nlin++
	@nlin,05 psay 'OPERADOR ENTRADA:  ' +SZT->ZT_OPERE
	@nlin,45 psay 'OPERADOR SAIDA:      ' +SZT->ZT_OPERS
	nlin += 2
	@nlin,00 psay '+-----------------------------------------------------------------------------+'
	nlin++
	@nlin,05 psay 'PESO ENTRADA:    ' + transform(SZT->ZT_PESOE,'@E ###,###.##')
	@nlin,45 psay 'PESO SAIDA:    ' + transform(SZT->ZT_PESOS,'@E ###,###.##')
	nlin++
	@nlin,00 psay '+-----------------------------------------------------------------------------+'
	nlin += 3
	@nlin,05 psay 'PESO LIQUIDO: ' + transform((SZT->ZT_PESOS) - (SZT->ZT_PESOE),'@E ###,###.##')
	@nlin,45 psay 'TIPO DE CARGA: ' + iif(SZT->ZT_TPCARGA = 'CO', 'Couro',iif(SZT->ZT_TPCARGA = 'OS', 'OSSO/SANGUE',iif(SZT->ZT_TPCARGA = 'PA', 'PROD.ACAB.',;
	iif(SZT->ZT_TPCARGA = 'GA', 'GADO',iif(SZT->ZT_TPCARGA = 'SE', 'SEBO',iif(SZT->ZT_TPCARGA = 'BI', 'BILIS',;
	iif(SZT->ZT_TPCARGA = 'LE', 'LENHA',iif(SZT->ZT_TPCARGA = 'OU', 'OUTROS',iif(SZT->ZT_TPCARGA = 'FO', 'FAR/OSSO',;
	iif(SZT->ZT_TPCARGA = 'FS', 'FAR/SANGUE',iif(SZT->ZT_TPCARGA = 'LE', 'LENHA',;
	iif(SZT->ZT_TPCARGA = 'BA', 'BARRIGADA', 'MUC'))))))))))))

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
	SZT->(dbsetorder(3))
Return

user Function gjf11man()
	campo0 := ''
	campo1 := 0
	campo2 := 0
	campo3 := ''
	campo4 := ''
	valor1 := SZT->ZT_PESOE
	valor2 := SZT->ZT_PESOS
	Valor0 := SZT->ZT_PLACA
	valor3 := SZT->ZT_HORAE
	valor4 := SZT->ZT_HORAS
	DEFINE MSDIALOG t01 FROM 0,0 TO 200,250 PIXEL TITLE "Mantutenção de Pesagem"
	//@ 01,01 SAY "Pesagem E:" of t01
	//@ 02,01 SAY "Pesagem S:" of t01
	@ 03,01 SAY "Placa:    " of t01
	@ 04,01 SAY "Hora E:    " of t01
	@ 05,01 SAY "Hora S:    " of t01
	//@ 12,48 MSGET campo1 VAR valor1 SIZE 40,10 OF t01 PIXEL PICTURE "@E 999,999.99"
	//@ 24,48 MSGET campo2 VAR valor2 SIZE 40,10 OF t01 PIXEL PICTURE "@E 999,999.99"
	@ 36,48 MSGET campo0 VAR valor0 SIZE 40,10 OF t01 PIXEL PICTURE "@!"
	@ 48,48 MSGET campo3 VAR valor3 SIZE 40,10 OF t01 PIXEL PICTURE "@!"
	@ 60,48 MSGET campo3 VAR valor4 SIZE 40,10 OF t01 PIXEL PICTURE "@!"
	@ 82,5 BUTTON botao1 PROMPT "Salvar" OF t01 PIXEL ACTION u_gjf11m()
	@ 82,65 BUTTON botao2 PROMPT "Fechar" OF t01 PIXEL ACTION t01:end()
	ACTIVATE MSDIALOG t01 CENTERED
Return

user function gjf11m()
	begin transaction
		reclock('SZT',.f.)
		SZT->ZT_PESOE  := valor1
		SZT->ZT_PESOS  := valor2
		SZT->ZT_PLACA  := valor0
		SZT->ZT_HORAE  := valor3
		SZT->ZT_HORAS  := valor4
		msunlock()
	end transaction
	t01:end()
return

user function gjf11v()
	P := M->ZT_PLACA
	_cQuery := "SELECT COUNT(ZT_PLACA) VER FROM "+RetSqlName("SZT")+" SZT " +;
	" WHERE SZT.D_E_L_E_T_ <> '*' " +;
	" AND SZT.ZT_STATUS    = 'PA' AND SZT.ZT_PLACA = '"+P+"'"

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	If Select("QRYAUX")<>0
		QRYAUX->(dbCloseArea())
	Endif
	TCQUERY _cQuery NEW ALIAS "QRYAUX"
	if QRYAUX->VER != 0
		alert('Placa com pesagem em aberto!',,'STOP')
		return .f.
	endif
	QRYAUX->(dbclosearea())
	dbselectarea('SZT')

return(.T.)

////Funções para atualização do mBrowse////
Static Function AutoRefresh(oDlg)
	Local oTimer
	oTimer := TTimer():New(2, {|| PBrow() }, oDlg)
	oTimer:Activate()
Return .T.

////Funções para atualização do mBrowse////
Static Function PBrow()
	oBrowse := getObjBrow()
	oBrowse:default()
	oBrowse:refresh()
Return

Static Function PesaIp()

	Local oObj := tSocketClient():New()

	if mv_par06 == 1

		_cIpBal2 := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + 'BPOR2',1))

		if empty(_cIpBal2)
			alert('Endereço IP da balança não encontrado!')
			return
		endif

		nResp2 := oObj:Connect( 9093, _cIpBal2, 1000 )
		//nResp := oObj:Connect(50104, _cIpBal, 1000 )//50104

	else
		_cIpBal := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + 'BPOR1',1))

		//if empty(_cIpBal)
		if empty(_cIpBal)
			alert('Endereço IP da balança não encontrado!')
			return
		endif

		nResp := oObj:Connect( 8881, _cIpBal, 1000 )
		//nResp := oObj:Connect(50104, _cIpBal, 1000 )//50104
	endif

	sleep(500)  

	cBuffer := ""
	nQtd := oObj:Receive( cBuffer, 10000 )//10000

	oObj:CloseConnection()

	if(oObj:IsConnected())	
		alert( "Ops! Ainda estou conectado" )
	endif

return cBuffer

USER FUNCTION GJF11COM()
    Local lAdjustToLegacy := .F.
    Local lDisableSetup := .T.
    Local cLocal := "\spool"
    Local cCodEmp := FWCodEmp()
    Local oPrinter
 
    oPrinter := FWMSPrinter():New("gjf11_compr_pesagem.rel", IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )

    oFont1 := TFont():New( "Arial", , -14, .T.)
 
    oPrinter:Say(020,010,"Data: " + DToC(Date()),oFont1)
    oPrinter:Say(030,010,"Horário: " + Time(),oFont1)
    oPrinter:Say(040,010,"Empresa: "+ iif(cCodEmp = '01', "Frig. Silva", "Ind. de Rações Passo das Tropas LTDA."),oFont1)
    oPrinter:Say(050,010,"Filial: " + FwFilialName(),oFont1)
    oPrinter:Say(030,215,"COMPROVANTE DE PESAGEM: ",oFont1)
    oPrinter:Line(055,010,055,900,0,"-1")
    oPrinter:Say(070,170, "FRIGORIFICO SILVA INDUSTRIA E COMERCIO LTDA.:")
    oPrinter:Say(080,170, "BR-392 Km 08 - Santa Maria - RS    Fone: (55)2103-2525")
    oPrinter:Line(085,10,085,900,0,"-2")
    oPrinter:Say(100,050,"Placa: " + AllTrim(SZT->ZT_PLACA))
    oPrinter:Say(100,350,"Cód. da pesagem: " + AllTrim(SZT->ZT_COD))
    oPrinter:Say(120,050,"Data de entrada: " + Transform(SZT->ZT_DATAE,'@E ##/##/##'))    
    oPrinter:Say(130,050,"Hora de entrada: " + AllTrim(SZT->ZT_HORAE))
  	oPrinter:Say(140,050,"Operador de entrada: " + AllTrim(SZT->ZT_OPERE))
	oPrinter:Say(150,050,"Peso de entrada: " + Transform(SZT->ZT_PESOE,'@E ###,###.##') + " Kg")
	oPrinter:Say(120,350,"Data de saída: " + Transform(SZT->ZT_DATAS,'@E ##/##/##'))
	oPrinter:Say(130,350,"Hora de saída: " + AllTrim(SZT->ZT_HORAS))
    oPrinter:Say(140,350,"Operador de saída: " + AllTrim(SZT->ZT_OPERS))
	oPrinter:Say(150,350,"Peso de saída: " + Transform(SZT->ZT_PESOS,'@E ###,###.##') + " Kg")
    oPrinter:Line(155,10,155,900,0,"-2")    
    oPrinter:Say(170,050,"Peso líquido: " + transform((SZT->ZT_PESOS) - (SZT->ZT_PESOE),'@E ###,###.##') + " Kg")
    oPrinter:Say(170,350,"Peso de carga/outros: "+ iif(SZT->ZT_TPCARGA = 'CO', 'Couro',iif(SZT->ZT_TPCARGA = 'OS', 'OSSO/SANGUE',iif(SZT->ZT_TPCARGA = 'PA', 'PROD.ACAB.',;
	iif(SZT->ZT_TPCARGA = 'GA', 'GADO',iif(SZT->ZT_TPCARGA = 'SE', 'SEBO',iif(SZT->ZT_TPCARGA = 'BI', 'BILIS',;
	iif(SZT->ZT_TPCARGA = 'LE', 'LENHA',iif(SZT->ZT_TPCARGA = 'OU', 'OUTROS',iif(SZT->ZT_TPCARGA = 'FO', 'FAR/OSSO',;
	iif(SZT->ZT_TPCARGA = 'FS', 'FAR/SANGUE',iif(SZT->ZT_TPCARGA = 'LE', 'LENHA',;
	iif(SZT->ZT_TPCARGA = 'BA', 'BARRIGADA', 'MUC')))))))))))))
        
    oPrinter:Setup()
    if oPrinter:nModalResult == PD_OK
    oPrinter:Preview()
    EndIf
Return
