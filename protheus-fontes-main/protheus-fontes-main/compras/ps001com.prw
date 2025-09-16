#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPS001COM  บAutor  ณEzequiel Pianegonda บ Data ณ  19/04/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface de geracao do documento de entrada da empresa 07  บฑฑ
ฑฑบ          ณTransportadora para a matriz                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function PS001COM()
	Local nOpc:= 0
	Local aSays:= {}
	Local aButtons:= {}

	Private cPerg:= "PS001COM"

	AADD(aSays, "  Esta rotina tem como objetivo realizar a importa็ใo das notas de frete da      ")
	AADD(aSays, "  empresa Transp Silva para a empresa Frig. Silva. Confirma o processamento?     ")

	AADD(aButtons, {1, .T., {|o| nOpc:= 1, o:oWnd:End()}})
	AADD(aButtons, {2, .T., {|o| o:oWnd:End()}})
	AADD(aButtons, {5, .T., {|o| Pergunte(cPerg, .T.)}})

	FormBatch("Importa็ใo Dc. Frete", aSays, aButtons,,200)

	If nOpc != 0
		Pergunte(cPerg, .F.)
		Processa({|| Import()}, "")
	Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImport    บAutor  ณEzequiel Pianegonda บ Data ณ  19/04/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de processamento. Chama o job de importacao das      บฑฑ
ฑฑบ          ณnotas de frete da empresa 07 para a 01                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Import()
	Local nOpc:= 0
	Local nX:= 0
	Local nCount:= 0
	Local cMsg:= ""
	Local aDados:= {}
	Local aCab:= {}
	Local aIten:= {}
	Local aItens:= {}
	Local cQuery:= ""
	Local aArea:= GetArea()
	Local cAli:= GetNextAlias()
	Local oDlg:= Nil
	Local oBrw:= Nil
	Local oCheckMarca:= Nil
	Local oOkSelct:= LoadBitmap(GetResources(), "LBTIK")
	Local oNoSelct:= LoadBitmap(GetResources(), "LBNO")
	Local LCHECKMARCA:= .F.
	Local LCHECKINV:= .F.

	Private lMsErroAuto:= .F.
	Private lMsHelpAuto:= .T.
	Private lAutoErrNoFile:= .T.

	//busco da empresa 07 os doc saida emitidos que nao foram lancados na empresa de origem
	//preciso chumbar a empresa 07 na query para nao usar um job pois o prepare environment vai consumir uma licenca
	cQuery:= " SELECT DTC_EMPORI, DTC_EMPFIL, DTC_LOTNFC, DTC_DOC, DTC_SERIE, DTC_CLIDES, DTC_LOJDES, DTC_NUMNFC, DTC_SERNFC, DTC.R_E_C_N_O_ DTCRECNO "
	cQuery+= " FROM DTC070 DTC, SF2070 SF2 "
	cQuery+= " WHERE DTC_FILIAL = '  ' AND F2_FILIAL = '00' AND "
	cQuery+= "       DTC_DOC = F2_DOC AND "
	cQuery+= "       DTC_SERIE = F2_SERIE AND "
	cQuery+= "       DTC_LOTNFC BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	cQuery+= "       DTC_DOC <> '' AND "
	cQuery+= "       DTC_DTIMP = '' AND "
	cQuery+= "       DTC_EMPORI <> '' AND "
	cQuery+= "       DTC.D_E_L_E_T_ = '' AND SF2.D_E_L_E_T_ = ''"

	TCQuery ChangeQuery(cQuery) New Alias &(cAli)

	Count To nCount
	&(cAli)->(dbGoTop())
	ProcRegua(nCount)

	Do While !&(cAli)->(EOF())

		IncProc(&(cAli)->(DTC_EMPORI)+&(cAli)->(DTC_EMPFIL)+&(cAli)->(DTC_LOTNFC)+&(cAli)->(DTC_DOC)+&(cAli)->(DTC_SERIE))

		dbSelectArea("SF2")
		dbSetOrder(1)
		dbSeek(&(cAli)->(DTC_EMPFIL)+&(cAli)->(DTC_NUMNFC)+&(cAli)->(DTC_SERNFC))
		If Found()
			dbSelectArea("SD2")
			dbSetOrder(3)
			dbSeek(&(cAli)->(DTC_EMPFIL)+&(cAli)->(DTC_NUMNFC)+&(cAli)->(DTC_SERNFC))
			If Found()
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
				If Found()
					AADD(aDados, {.T., ;
					&(cAli)->(DTC_EMPORI), ;
					&(cAli)->(DTC_EMPFIL), ;
					&(cAli)->(DTC_LOTNFC), ;
					&(cAli)->(DTC_DOC), ;
					&(cAli)->(DTC_SERIE), ;
					&(cAli)->(DTC_NUMNFC), ;
					&(cAli)->(DTC_SERNFC), ;
					SD2->D2_TES, ;
					SA1->A1_NOME, ;
					&(cAli)->(DTCRECNO)})
				Else
					MsgInfo("Cliente nใo encontrado "+SF1->F2_CLIENTE+SF2->F2_LOJA)
				EndIf
			Else
				MsgInfo("Nใo foram encontrados itens para o documento "+SF1->F2_CLIENTE+SF2->F2_LOJA)
			EndIf
		Else
			MsgInfo("Nใo foi encontrado a NF "+&(cAli)->(DTC_NUMNFC)+&(cAli)->(DTC_SERNFC))
		EndIf
		&(cAli)->(dbSkip())
	EndDo

	&(cAli)->(dbCloseArea())

	If Len(aDados) > 0

		oDlg:= MSDIALOG():New(000, 000, 450, 800, "Sele็ใo de Ct-e",,,,,,,,,.T.)
		oBrw:= TCBrowse():New(01, 01, 400, 200, , {'', 'Empresa', 'Filial', 'Lote', 'Dc.Cliente', 'Ser.Cliente', 'Dc.Origem', 'Ser.Origem', 'TES', 'Cliente'}, {10, 30, 20, 30, 40, 20, 40, 30, 20, 40}, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
		oBrw:SetArray(aDados)
		oBrw:bLine:= {||{IIF(aDados[oBrw:nAt, 01], oOkSelct, oNoSelct),;
		aDados[oBrw:nAt,02],;
		aDados[oBrw:nAt,03],;
		aDados[oBrw:nAt,04],;
		aDados[oBrw:nAt,05],;
		aDados[oBrw:nAt,06],;
		aDados[oBrw:nAt,07],;
		aDados[oBrw:nAt,08],;
		aDados[oBrw:nAt,09],;
		aDados[oBrw:nAt,10]}}
		oBrw:bLDblClick:= {|| aDados[oBrw:nAt, 01]:= !aDados[oBrw:nAt, 01]}
		@ 210, 120 CHECKBOX oCheckMarca VAR lCheckMarca PROMPT "Marcar Todos" SIZE 62, 10 OF oDlg PIXEL
		oCheckMarca:blClicked:= {|| AEval(aDados, {|x, y| x[1]:= lCheckMarca, If(lCheckMarca, (lCheckInv:= .F., oCheckInv:Refresh()), )})}
		@ 210, 180 CHECKBOX oCheckInv VAR lCheckInv PROMPT "Inverter Marca" SIZE 62, 10 OF oDlg PIXEL
		oCheckInv:blClicked:= {|| AEval(aDados, {|x, y| x[1]:= !x[1]}), lCheckMarca:= (Ascan(aDados, {|x| !x[1]}) == 0), oCheckMarca:Refresh()}
		TButton():New(210, 240, "OK"	 , oDlg, {|| oDlg:End(), nOpc:= 1}, 40, 010,,,.F.,.T.,.F.,,.F.,,,.F.)
		TButton():New(210, 290, "Cancela", oDlg, {|| oDlg:End(), nOpc:= 0}, 40, 010,,,.F.,.T.,.F.,,.F.,,,.F.)
		oDlg:Activate()

		If nOpc != 0
			ProcRegua(Len(aDados))
			For nX:= 1 To Len(aDados)
				IncProc("Processando documento "+aDados[nX, 5]+aDados[nX, 6])
				If aDados[nX, 1]
					lMsErroAuto:= .F.
					lMsHelpAuto:= .T.
					aCab:= {}

					//preciso buscar as informacoes na empresa 07
					//nao uso prepare environmet para poupar uma licenca
					cQuery:= " SELECT * "
					cQuery+= " FROM SF2070 "
					cQuery+= " WHERE F2_FILIAL = '00' AND "
					cQuery+= "       F2_DOC = '"+aDados[nX, 5]+"' AND "
					cQuery+= "       F2_SERIE = '"+aDados[nX, 6]+"' AND "
					cQuery+= "       F2_CHVNFE <> '' AND "
					cQuery+= "       D_E_L_E_T_ = ''"
					TCQuery ChangeQuery(cQuery) New Alias &(cAli)

					If !&(cAli)->(EOF())
						dbSelectArea("SF1")
						Posicione("SA2", 1, xFilial("SA2")+"005766"+"01", "A2_NOME")

						aCab:= {{"F1_FILIAL"	,aDados[nX, 3]					, Nil},;
						{"F1_DOC"		,&(cAli)->(F2_DOC)				, Nil},;
						{"F1_SERIE"		,&(cAli)->(F2_SERIE)			, Nil},;
						{"F1_FORMUL"	,"N"							, Nil},;
						{"F1_FORNECE"	,"005766"						, Nil},;
						{"F1_LOJA"		,"01"							, Nil},;
						{"F1_COND"		,"009"							, Nil},;
						{"F1_ESPECIE"	,"CTE"							, Nil},;
						{"F1_TIPO"		,"N"							, Nil},;
						{"F1_EMISSAO"	,StoD(&(cAli)->(F2_EMISSAO))	, Nil},;
						{"F1_DTDIGIT"	,dDataBase						, Nil},;
						{"F1_CHVNFE"	,&(cAli)->(F2_CHVNFE)			, Nil},;
						{"F1_EST"		,SA2->A2_EST					, Nil},;
						{"F1_INDPRES"	,"0"							, Nil},;
						{"F1_CODA1U"	,""								, Nil}}

						//apenas um item
						aItens:= {}
						aItem:={{"D1_FILIAL"	,aDados[nX, 3]															, Nil},;
						{"D1_ITEM"		,"0001"			  														, Nil},;
						{"D1_COD"		,IIF(Alltrim(aDados[nX, 9]) == '524', "900020", "900002")				, Nil},;
						{"D1_QUANT"		,1																		, Nil},;
						{"D1_VUNIT" 	,&(cAli)->(F2_VALMERC)													, Nil},;
						{"D1_TES" 		,IIF(Alltrim(aDados[nX, 9]) == '524', "103", "105")						, Nil},;
						{"D1_CONTA" 	,IIF(Alltrim(aDados[nX, 9]) == '524', "4103023019", "4103023021")		, Nil},;
						{"D1_CC" 		,"1121002"																, Nil},;
						{"D1_DTDIGIT" 	,dDataBase																, Nil}}
						AADD(aItens, aItem)

						&(cAli)->(dbCloseArea())

						MSExecAuto({|x, y, z| MATA103 (x, y, z)}, aCab, aItens, 3)

						If lMsErroAuto
							MostraErro()
						Else
							//se no deu erro atualizo o campo DTC_DTIMP com a data
							TCSQLExec("UPDATE DTC070 SET DTC_DTIMP = '"+DtoS(Date())+"' WHERE R_E_C_N_O_ = "+cValToChar(aDados[nX, 11]))
						EndIf
					Else
						MsgInfo("A pesquisa nใo retornou registros, verifique se a nota fiscal "+aDados[nX, 5]+aDados[nX, 6]+" foi transmitida e possui o campo F2_CHVNFE preenchido.")
					EndIf
				EndIf
			Next nX
		Else
			MsgInfo("Cancelado pelo usuแrio.")
		EndIf
	Else
		MsgInfo("A pesquisa nใo retornou resultados, verifique os parโmetros e tente novamente.")
	EndIf

	RestArea(aArea)
Return
