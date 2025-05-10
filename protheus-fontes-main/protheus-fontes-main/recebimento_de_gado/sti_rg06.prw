#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"

/*/{Protheus.doc} STI_RG06
TCBrowse para geração dos pedidos de compra e notas de entrada com base nos registros de fechamento de compra de gado
@author 	Evandro Mugnol.
@since 		Set/2017
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_RG06(_cTipo)

	Local aSize	   := MsAdvSize()
	Local aObjects := {}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj  := {}

	Private _oDlg	:= Nil
	Private _oBrw   := Nil
	Private _aDados := {}
	Private cPerg   := "STI_RG06"

	Private ofont1,oObj1
	ofont1 := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)

	nOpc := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas no Arquivo SX1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(_cTipo)
		If !Pergunte(cPerg,.T.)
			Return
		EndIf
	Else
		Pergunte(cPerg,.F.)		// Deve chamar para carregar conteúdo das perguntas, para simular refresh da tela
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query para seleção das informações                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasTMP := GetNextAlias()
	_aDados   := {}

	cQuery := "SELECT ZAG_FILIAL, ZAG_NUMAM, ZAG_FORNEC, ZAG_LOJA"
	cQuery += "  FROM " + RetSQLTab("ZAG")
	cQuery += " WHERE " + RetSQLFil("ZAG")
	cQuery += "   AND ZAG_NUMAM = '" + mv_par01 + "'"
	cQuery += "   AND ZAG_STATUS <> 'E' "
	cQuery += "   AND " + RetSQLDel("ZAG")
	cQuery += " GROUP BY ZAG_FILIAL, ZAG_NUMAM, ZAG_FORNEC, ZAG_LOJA"
	cQuery += " ORDER BY ZAG_FILIAL, ZAG_NUMAM, ZAG_FORNEC, ZAG_LOJA"

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasTMP, .F., .T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nTotal := 0
	While !(cAliasTMP)->(Eof())
		AADD(_aDados,{(cAliasTMP)->ZAG_NUMAM,;
		(cAliasTMP)->ZAG_FORNEC,;
		(cAliasTMP)->ZAG_LOJA,;
		AllTrim(GetAdvFVal("SA2", "A2_NOME", FWxFilial("SA2") + (cAliasTMP)->ZAG_FORNEC + (cAliasTMP)->ZAG_LOJA, 1))})

		(cAliasTMP)->(DbSkip())
	EndDo

	(cAliasTMP)->(DbCloseArea())

	If Len(_aDados) == 0
		AADD(_aDados,{''	,;
					  ''	,;
					  ''	,;
					  ''	})
	EndIf

	AADD(aObjects,{450,50,.T.,.T.,.T.})
	AADD(aObjects,{450,50,.T.,.T.,.T.})
	AAdd(aObjects,{100,15,.T.,.F.})
	aPosObj := MsObjSize(aInfo,aObjects)

	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{005,050,110,165,225,280}} )
	nGetLin := aPosObj[3,1]

	_oDlg:= MSDIALOG():New(000, 000, 450, 850, "Produtores para Geração PC e NF",,,,,,,,,.T.)
	_oDlg:lMaximized:= .T.

	_oBrw:= TCBrowse():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]+100, , {'Número Aviso', 'Produtor', 'Loja', 'N  o  m  e'}, {60, 40, 20, 100}, _oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)

	_oBrw:SetArray(_aDados)
	_oBrw:bLine:= {||{_aDados[_oBrw:nAt, 01],;
	_aDados[_oBrw:nAt, 02],;
	_aDados[_oBrw:nAt, 03],;
	_aDados[_oBrw:nAt, 04]}}
	_oBrw:Refresh()

	TButton():New(nGetLin,aPosGet[1,2], "Excluir"     		, _oDlg, {|| Exclu(_oBrw:nAt)	, nOpc := 1}, 50, 010,,,.F.,.T.,.F.,,.F.,,,.F.)
	TButton():New(nGetLin,aPosGet[1,4], "Complemento" 		, _oDlg, {|| Compl(_oBrw:nAt)	, nOpc := 1}, 50, 010,,,.F.,.T.,.F.,,.F.,,,.F.)
	TButton():New(nGetLin,aPosGet[1,6], "Sair" 				, _oDlg, {|| _oDlg:End()		, nOpc := 0}, 50, 010,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oDlg:Activate()

	If nOpc == 0
		If MsgYesNo("Deseja chamar a rotina para transmissão das Notas Fiscais geradas?","Confirma?")
			RG06SPED()		// CHAMADA ROTINA PARA TRANSMISSÃO NF-e
		Endif
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Exclu    º Autor ³ Evandro Mugnol     º Data ³ 20/02/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que exclui a linha que está posicionada para poder  º±±
±±º          ³ permitir gerar novamente o pré-pedido                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Exclu(nLinE)

	DbSelectArea("ZAG")
	DbSetOrder(3)
	MsSeek(FWxFilial("ZAG") + _aDados[nLinE, 1])
	While !Eof() .And. ZAG->ZAG_FILIAL + ZAG->ZAG_NUMAM == FWxFilial("ZAG") + _aDados[nLinE, 1]
		If ZAG->ZAG_FORNEC + ZAG->ZAG_LOJA == _aDados[nLinE, 2] + _aDados[nLinE, 3] .And. ZAG->ZAG_STATUS == "A"
			DbSelectArea("ZAG")
			RecLock("ZAG",.F.)
			DbDelete()
			MsUnlock()
		Endif

		DbSelectArea("ZAG")
		DbSkip()
	Enddo

	_oDlg:End()		// Fecha janela principal do browse

	U_STI_RG06(2)	// Reabre TCBrowse principal executando refresh na janela principal do browse

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Compl    º Autor ³ Evandro Mugnol     º Data ³ 20/02/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que monta tela para informar dados complementares e º±±
±±º          ³ gerar pedido de compra e nota fiscal para o produtor       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Compl(nLin)

	Local oBrwZAG
	Local aSize    := MsAdvSize()
	Local oSize
	Local aObjects := {}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj  := {}
	Local nOpt	   := 0
	Local nY

	Private aItens   := {}
	Private aCond 	 := {}
	Private oTotBois
	Private oTotVaca
	Private oTotTour
	Private oTotBufo
	Private oTotBufa
	Private nTotBois := 0
	Private nTotVaca := 0
	Private nTotTour := 0
	Private nTotBufo := 0
	Private nTotBufa := 0
	Private oNomFor
	Private cNomFor  := _aDados[nLin, 2] + " / " + _aDados[nLin, 3] + "  -  " + _aDados[nLin, 4]
	Private oNumAm
	Private cNumAm   := _aDados[nLin, 1]
	DbSelectArea("SZG")
	Private oAbate
	Private dAbate   := GetAdvFVal("SZG", "ZG_DATA", FWxFilial("SZG") + _aDados[nLin, 1], 1)

	DEFINE FONT oFnt  	NAME "Arial" Size 10,15
	DEFINE FONT oFnt1   NAME "Arial" Size 5,10

	// Carrega Dados Complementares
	_cChave := _aDados[nLin, 2] + _aDados[nLin, 3] + _aDados[nLin, 1]		// Fornecedor + Loja + Numero Aviso

	DbSelectArea("ZF1")
	DbSetOrder(1)
	If MsSeek(FWxFilial("ZF1") + _cChave)
		Private cPlaca := ZF1->ZF1_PLACA

		Private cNFP01 := ZF1->ZF1_NFPN01
		Private cSER01 := ZF1->ZF1_NFPS01
		Private cNFP02 := ZF1->ZF1_NFPN02
		Private cSER02 := ZF1->ZF1_NFPS02
		Private cNFP03 := ZF1->ZF1_NFPN03
		Private cSER03 := ZF1->ZF1_NFPS03
		Private cNFP04 := ZF1->ZF1_NFPN04
		Private cSER04 := ZF1->ZF1_NFPS04
		Private cNFP05 := ZF1->ZF1_NFPN05
		Private cSER05 := ZF1->ZF1_NFPS05
		Private cNFP06 := ZF1->ZF1_NFPN06
		Private cSER06 := ZF1->ZF1_NFPS06
		Private cNFP07 := ZF1->ZF1_NFPN07
		Private cSER07 := ZF1->ZF1_NFPS07
		Private cNFP08 := ZF1->ZF1_NFPN08
		Private cSER08 := ZF1->ZF1_NFPS08
		Private cNFP09 := ZF1->ZF1_NFPN09
		Private cSER09 := ZF1->ZF1_NFPS09
		Private cNFP10 := ZF1->ZF1_NFPN10
		Private cSER10 := ZF1->ZF1_NFPS10

		Private cNFP11 := ZF1->ZF1_NFPN11
		Private cSER11 := ZF1->ZF1_NFPS11
		Private cNFP12 := ZF1->ZF1_NFPN12
		Private cSER12 := ZF1->ZF1_NFPS12
		Private cNFP13 := ZF1->ZF1_NFPN13
		Private cSER13 := ZF1->ZF1_NFPS13
		Private cNFP14 := ZF1->ZF1_NFPN14
		Private cSER14 := ZF1->ZF1_NFPS14
		Private cNFP15 := ZF1->ZF1_NFPN15
		Private cSER15 := ZF1->ZF1_NFPS15
		Private cNFP16 := ZF1->ZF1_NFPN16
		Private cSER16 := ZF1->ZF1_NFPS16
		Private cNFP17 := ZF1->ZF1_NFPN17
		Private cSER17 := ZF1->ZF1_NFPS17
		Private cNFP18 := ZF1->ZF1_NFPN18
		Private cSER18 := ZF1->ZF1_NFPS18
		Private cNFP19 := ZF1->ZF1_NFPN19
		Private cSER19 := ZF1->ZF1_NFPS19
		Private cNFP20 := ZF1->ZF1_NFPN20
		Private cSER20 := ZF1->ZF1_NFPS20

		Private cNFP21 := ZF1->ZF1_NFPN21
		Private cSER21 := ZF1->ZF1_NFPS21
		Private cNFP22 := ZF1->ZF1_NFPN22
		Private cSER22 := ZF1->ZF1_NFPS22
		Private cNFP23 := ZF1->ZF1_NFPN23
		Private cSER23 := ZF1->ZF1_NFPS23
		Private cNFP24 := ZF1->ZF1_NFPN24
		Private cSER24 := ZF1->ZF1_NFPS24
		Private cNFP25 := ZF1->ZF1_NFPN25
		Private cSER25 := ZF1->ZF1_NFPS25
		Private cNFP26 := ZF1->ZF1_NFPN26
		Private cSER26 := ZF1->ZF1_NFPS26
		Private cNFP27 := ZF1->ZF1_NFPN27
		Private cSER27 := ZF1->ZF1_NFPS27
		Private cNFP28 := ZF1->ZF1_NFPN28
		Private cSER28 := ZF1->ZF1_NFPS28
		Private cNFP29 := ZF1->ZF1_NFPN29
		Private cSER29 := ZF1->ZF1_NFPS29
		Private cNFP30 := ZF1->ZF1_NFPN30
		Private cSER30 := ZF1->ZF1_NFPS30

		Private cNFP31 := ZF1->ZF1_NFPN31
		Private cSER31 := ZF1->ZF1_NFPS31
		Private cNFP32 := ZF1->ZF1_NFPN32
		Private cSER32 := ZF1->ZF1_NFPS32
		Private cNFP33 := ZF1->ZF1_NFPN33
		Private cSER33 := ZF1->ZF1_NFPS33
		Private cNFP34 := ZF1->ZF1_NFPN34
		Private cSER34 := ZF1->ZF1_NFPS34
		Private cNFP35 := ZF1->ZF1_NFPN35
		Private cSER35 := ZF1->ZF1_NFPS35
		Private cNFP36 := ZF1->ZF1_NFPN36
		Private cSER36 := ZF1->ZF1_NFPS36
		Private cNFP37 := ZF1->ZF1_NFPN37
		Private cSER37 := ZF1->ZF1_NFPS37
		Private cNFP38 := ZF1->ZF1_NFPN38
		Private cSER38 := ZF1->ZF1_NFPS38
		Private cNFP39 := ZF1->ZF1_NFPN39
		Private cSER39 := ZF1->ZF1_NFPS39
		Private cNFP40 := ZF1->ZF1_NFPN40
		Private cSER40 := ZF1->ZF1_NFPS40

		Private cMens01:= ZF1->ZF1_MENS01
		Private cMens02:= ZF1->ZF1_MENS02
		Private cMens03:= ZF1->ZF1_MENS03
		Private cMens04:= ZF1->ZF1_MENS04
		Private cMens05:= ZF1->ZF1_MENS05

		Private cTES   := ZF1->ZF1_TES
		Private oGerNPR
		Private cGerNPR:= ZF1->ZF1_GERNPR
		Private dVencto:= ZF1->ZF1_VENCTO
		Private oInfNNF
		Private cInfNNF:= "1"
	Else
		Private cPlaca := Space(08)

		Private cNFP01 := cNFP02 := cNFP03 := cNFP04 := cNFP05 := cNFP06 := cNFP07 := cNFP08 := cNFP09 := cNFP10 := Space(09)
		Private cSER01 := cSER02 := cSER03 := cSER04 := cSER05 := cSER06 := cSER07 := cSER08 := cSER09 := cSER10 := Space(03)
		Private cNFP11 := cNFP12 := cNFP13 := cNFP14 := cNFP15 := cNFP16 := cNFP17 := cNFP18 := cNFP19 := cNFP20 := Space(09)
		Private cSER11 := cSER12 := cSER13 := cSER14 := cSER15 := cSER16 := cSER17 := cSER18 := cSER19 := cSER20 := Space(03)
		Private cNFP21 := cNFP22 := cNFP23 := cNFP24 := cNFP25 := cNFP26 := cNFP27 := cNFP28 := cNFP29 := cNFP30 := Space(09)
		Private cSER21 := cSER22 := cSER23 := cSER24 := cSER25 := cSER26 := cSER27 := cSER28 := cSER29 := cSER30 := Space(03)
		Private cNFP31 := cNFP32 := cNFP33 := cNFP34 := cNFP35 := cNFP36 := cNFP37 := cNFP38 := cNFP39 := cNFP40 := Space(09)
		Private cSER31 := cSER32 := cSER33 := cSER34 := cSER35 := cSER36 := cSER37 := cSER38 := cSER39 := cSER40 := Space(03)

		Private cMens01:= Space(80)
		Private cMens02:= Space(180)
		Private cMens03:= Space(180)
		Private cMens04:= Space(180)
		Private cMens05:= Space(200)

		DbSelectArea("SA2")
		Private cTES   := IIF(Len(AllTrim(GetAdvFVal("SA2", "A2_CGC", FWxFilial("SA2") + _aDados[nLin, 2] + _aDados[nLin, 3], 1)))==14,"192","190")   // Se PJ=192, Se PF=190
		Private oGerNPR
		Private cGerNPR:= "2"
		Private dVencto:= dAbate + 29		// Deve ser somado 29 dias, pois deve considerar a data do abate para calcular os 30 dias
		Private oInfNNF
		Private cInfNNF:= "1"
		Private _cPosEmp := GetAdvFVal("SA2", "A2_POSEMP", FWxFilial("SA2") + _aDados[nLin, 2] + _aDados[nLin, 3], 1)

		if cTES == '190' .and. _cPosEmp == '1'
			cTES := '328'
		endif
	Endif

	// Carrega Dados para o TCColumn
	DbSelectArea("ZAG")
	DbSetOrder(2)
	MsSeek(FWxFilial("ZAG") + _aDados[nLin, 2] + _aDados[nLin, 3] + _aDados[nLin, 1])
	While !Eof() .And. ZAG->ZAG_FILIAL + ZAG->ZAG_FORNEC + ZAG->ZAG_LOJA + ZAG->ZAG_NUMAM == FWxFilial("ZAG") + _aDados[nLin, 2] + _aDados[nLin, 3] + _aDados[nLin, 1]
		If ZAG->ZAG_STATUS <> "E"
			Aadd(aItens, {ZAG_STATUS, ZAG_NUM, ZAG_LOTE, ZAG_PRODUT, ZAG_DESCRI, ZAG_QUANT, ZAG_SLDQ, ZAG_PESO, ZAG_SLDP, ZAG_PRECO, ZAG_TOTAL, ZAG_COMISS, ZAG_PESOR, ZAG_COMPR})
			DO CASE
				CASE AllTrim(ZAG_PRODUT) == "000230"	// Boi
					nTotBois += ZAG_QUANT
				CASE AllTrim(ZAG_PRODUT) == "000231"	// Vaca
					nTotVaca += ZAG_QUANT
				CASE AllTrim(ZAG_PRODUT) == "001075"	// Touro
					nTotTour += ZAG_QUANT
				CASE AllTrim(ZAG_PRODUT) == "001073"	// Búfalo
					nTotBufo += ZAG_QUANT
				CASE AllTrim(ZAG_PRODUT) == "001074"	// Búfala
					nTotBufa += ZAG_QUANT
			ENDCASE
		Endif
		DbSelectArea("ZAG")
		DbSkip()
	EndDo

	// Faz o calculo automatico de dimensoes de objetos
	oSize := FwDefSize():New(.T.)

	oSize:lLateral := .F.
	oSize:lProp		:= .T. // Proporcional

	oSize:AddObject( "1STROW" ,  100, 007, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "2NDROW" ,  100, 053, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "3RDROW" ,  100, 035, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "4THROW" ,  100, 005, .T., .T. ) // Totalmente dimensionavel

	oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

	oSize:Process() 						// Dispara os calculos

	a1stRow := {oSize:GetDimension("1STROW","LININI"),;
	oSize:GetDimension("1STROW","COLINI"),;
	oSize:GetDimension("1STROW","LINEND"),;
	oSize:GetDimension("1STROW","COLEND")}

	a2ndRow := {oSize:GetDimension("2NDROW","LININI"),;
	oSize:GetDimension("2NDROW","COLINI"),;
	oSize:GetDimension("2NDROW","LINEND"),;
	oSize:GetDimension("2NDROW","COLEND")}

	a3rdRow := {oSize:GetDimension("3RDROW","LININI"),;
	oSize:GetDimension("3RDROW","COLINI"),;
	oSize:GetDimension("3RDROW","LINEND"),;
	oSize:GetDimension("3RDROW","COLEND")}

	a4thRow := {oSize:GetDimension("4THROW","LININI"),;
	oSize:GetDimension("4THROW","COLINI"),;
	oSize:GetDimension("4THROW","LINEND"),;
	oSize:GetDimension("4THROW","COLEND")}

	AADD(aObjects,{450,50,.T.,.T.,.T.})
	AADD(aObjects,{450,50,.T.,.T.,.T.})
	AAdd(aObjects,{100,15,.T.,.F.})
	aPosObj := MsObjSize(aInfo,aObjects)

	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{005,050,110,165,225,280}} )
	nGetLin := aPosObj[3,1]

	DEFINE MSDIALOG oDlg TITLE "COMPLEMENTOS DADOS PRODUTOR PARA GERAÇÃO DE PC e NF" From oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

	@ a1stRow[1] + 000,a1stRow[2] + 005 TO a1stRow[3],a1stRow[4] OF oDlg PIXEL
	@ a1stRow[1] + 006,a1stRow[2] + 010 SAY "Placa" 			OF oDlg PIXEL
	@ a1stRow[1] + 004,a1stRow[2] + 035 MSGET cPlaca 			OF oDlg PIXEL PICTURE "@!" SIZE 30, 9 When .T.

	@ a1stRow[1] + 006,a1stRow[2] + 080 SAY "Aviso Matança:" OF oDlg PIXEL
	@ a1stRow[1] + 006,a1stRow[2] + 120	SAY oNumAm  VAR cNumAm  PICTURE "@!" OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE

	@ a1stRow[1] + 006,a1stRow[2] + 170 SAY "Data Abate:"	 	OF oDlg PIXEL
	@ a1stRow[1] + 006,a1stRow[2] + 200	SAY oAbate  VAR dAbate  PICTURE "@D" OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE

	@ a1stRow[1] + 006,a1stRow[2] + 250	SAY oNomFor VAR cNomFor PICTURE "@!" OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE

	@ a2ndRow[1] + 000,a2ndRow[2] + 005 TO a2ndRow[3] + 040,a2ndRow[4] OF oDlg PIXEL LABEL "N O T A S    F I S C A I S    D O    P R O D U T O R"
	@ a2ndRow[1] + 007,a2ndRow[2] + 010 SAY "Número NFP" 	OF oDlg PIXEL
	@ a2ndRow[1] + 007,a2ndRow[2] + 055 SAY "Série" 		OF oDlg PIXEL
	@ a2ndRow[1] + 015,a2ndRow[2] + 010 MSGET cNFP01  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 015,a2ndRow[2] + 055 MSGET cSER01  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 025,a2ndRow[2] + 010 MSGET cNFP02  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 025,a2ndRow[2] + 055 MSGET cSER02  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 035,a2ndRow[2] + 010 MSGET cNFP03  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 035,a2ndRow[2] + 055 MSGET cSER03  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 045,a2ndRow[2] + 010 MSGET cNFP04  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 045,a2ndRow[2] + 055 MSGET cSER04  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 055,a2ndRow[2] + 010 MSGET cNFP05  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 055,a2ndRow[2] + 055 MSGET cSER05  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 065,a2ndRow[2] + 010 MSGET cNFP06  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 065,a2ndRow[2] + 055 MSGET cSER06  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 075,a2ndRow[2] + 010 MSGET cNFP07  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 075,a2ndRow[2] + 055 MSGET cSER07  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 085,a2ndRow[2] + 010 MSGET cNFP08  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 085,a2ndRow[2] + 055 MSGET cSER08  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 095,a2ndRow[2] + 010 MSGET cNFP09  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 095,a2ndRow[2] + 055 MSGET cSER09  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 105,a2ndRow[2] + 010 MSGET cNFP10  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 105,a2ndRow[2] + 055 MSGET cSER10  	OF oDlg PIXEL SIZE 10, 9 When .T.

	@ a2ndRow[1] + 007,a2ndRow[2] + 130 SAY "Número NFP" 	OF oDlg PIXEL
	@ a2ndRow[1] + 007,a2ndRow[2] + 175 SAY "Série" 		OF oDlg PIXEL
	@ a2ndRow[1] + 015,a2ndRow[2] + 130 MSGET cNFP11  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 015,a2ndRow[2] + 175 MSGET cSER11  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 025,a2ndRow[2] + 130 MSGET cNFP12  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 025,a2ndRow[2] + 175 MSGET cSER12  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 035,a2ndRow[2] + 130 MSGET cNFP13  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 035,a2ndRow[2] + 175 MSGET cSER13  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 045,a2ndRow[2] + 130 MSGET cNFP14  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 045,a2ndRow[2] + 175 MSGET cSER14  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 055,a2ndRow[2] + 130 MSGET cNFP15  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 055,a2ndRow[2] + 175 MSGET cSER15  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 065,a2ndRow[2] + 130 MSGET cNFP16  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 065,a2ndRow[2] + 175 MSGET cSER16  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 075,a2ndRow[2] + 130 MSGET cNFP17  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 075,a2ndRow[2] + 175 MSGET cSER17  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 085,a2ndRow[2] + 130 MSGET cNFP18  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 085,a2ndRow[2] + 175 MSGET cSER18  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 095,a2ndRow[2] + 130 MSGET cNFP19  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 095,a2ndRow[2] + 175 MSGET cSER19  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 105,a2ndRow[2] + 130 MSGET cNFP20  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 105,a2ndRow[2] + 175 MSGET cSER20  	OF oDlg PIXEL SIZE 10, 9 When .T.

	@ a2ndRow[1] + 007,a2ndRow[2] + 250 SAY "Número NFP" 	OF oDlg PIXEL
	@ a2ndRow[1] + 007,a2ndRow[2] + 295 SAY "Série" 		OF oDlg PIXEL
	@ a2ndRow[1] + 015,a2ndRow[2] + 250 MSGET cNFP21  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 015,a2ndRow[2] + 295 MSGET cSER21  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 025,a2ndRow[2] + 250 MSGET cNFP22  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 025,a2ndRow[2] + 295 MSGET cSER22  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 035,a2ndRow[2] + 250 MSGET cNFP23  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 035,a2ndRow[2] + 295 MSGET cSER23  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 045,a2ndRow[2] + 250 MSGET cNFP24  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 045,a2ndRow[2] + 295 MSGET cSER24  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 055,a2ndRow[2] + 250 MSGET cNFP25  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 055,a2ndRow[2] + 295 MSGET cSER25  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 065,a2ndRow[2] + 250 MSGET cNFP26  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 065,a2ndRow[2] + 295 MSGET cSER26  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 075,a2ndRow[2] + 250 MSGET cNFP27  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 075,a2ndRow[2] + 295 MSGET cSER27  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 085,a2ndRow[2] + 250 MSGET cNFP28  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 085,a2ndRow[2] + 295 MSGET cSER28  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 095,a2ndRow[2] + 250 MSGET cNFP29  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 095,a2ndRow[2] + 295 MSGET cSER29  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 105,a2ndRow[2] + 250 MSGET cNFP30  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 105,a2ndRow[2] + 295 MSGET cSER30  	OF oDlg PIXEL SIZE 10, 9 When .T.

	@ a2ndRow[1] + 007,a2ndRow[2] + 370 SAY "Número NFP" 	OF oDlg PIXEL
	@ a2ndRow[1] + 007,a2ndRow[2] + 415 SAY "Série" 		OF oDlg PIXEL
	@ a2ndRow[1] + 015,a2ndRow[2] + 370 MSGET cNFP31  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 015,a2ndRow[2] + 415 MSGET cSER31  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 025,a2ndRow[2] + 370 MSGET cNFP32  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 025,a2ndRow[2] + 415 MSGET cSER32  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 035,a2ndRow[2] + 370 MSGET cNFP33  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 035,a2ndRow[2] + 415 MSGET cSER33  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 045,a2ndRow[2] + 370 MSGET cNFP34  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 045,a2ndRow[2] + 415 MSGET cSER34  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 055,a2ndRow[2] + 370 MSGET cNFP35  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 055,a2ndRow[2] + 415 MSGET cSER35  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 065,a2ndRow[2] + 370 MSGET cNFP36  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 065,a2ndRow[2] + 415 MSGET cSER36  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 075,a2ndRow[2] + 370 MSGET cNFP37  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 075,a2ndRow[2] + 415 MSGET cSER37  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 085,a2ndRow[2] + 370 MSGET cNFP38  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 085,a2ndRow[2] + 415 MSGET cSER38  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 095,a2ndRow[2] + 370 MSGET cNFP39  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 095,a2ndRow[2] + 415 MSGET cSER39  	OF oDlg PIXEL SIZE 10, 9 When .T.
	@ a2ndRow[1] + 105,a2ndRow[2] + 370 MSGET cNFP40  	OF oDlg PIXEL SIZE 30, 9 When .T.
	@ a2ndRow[1] + 105,a2ndRow[2] + 415 MSGET cSER40  	OF oDlg PIXEL SIZE 10, 9 When .T.

	@ a2ndRow[1] + 122,a2ndRow[2] + 010 SAY "Mensagens para Danfe" 	OF oDlg PIXEL
	@ a2ndRow[1] + 130,a2ndRow[2] + 010 MSGET cMens01 	OF oDlg PIXEL SIZE 480, 9 When .T.
	@ a2ndRow[1] + 140,a2ndRow[2] + 010 MSGET cMens02 	OF oDlg PIXEL SIZE 480, 9 When .F.
	@ a2ndRow[1] + 150,a2ndRow[2] + 010 MSGET cMens03 	OF oDlg PIXEL SIZE 480, 9 When .F.
	@ a2ndRow[1] + 160,a2ndRow[2] + 010 MSGET cMens04 	OF oDlg PIXEL SIZE 480, 9 When .F.
	@ a2ndRow[1] + 170,a2ndRow[2] + 010 MSGET cMens05 	OF oDlg PIXEL SIZE 480, 9 When .T.

	@ a2ndRow[1] + 132,a2ndRow[2] + 500 SAY "TES"   	OF oDlg PIXEL
	@ a2ndRow[1] + 130,a2ndRow[2] + 565 MSGET cTES   	OF oDlg PIXEL F3 "SF4" SIZE 30, 9 When .T. Valid VldTES()

	@ a2ndRow[1] + 147,a2ndRow[2] + 500 SAY "Vencimento" 	OF oDlg PIXEL
	@ a2ndRow[1] + 145,a2ndRow[2] + 565 MSGET dVencto 		OF oDlg PIXEL SIZE 45, 9 When .T.

	@ a2ndRow[1] + 162,a2ndRow[2] + 500 SAY "Gera NPR" 		OF oDlg PIXEL
	@ a2ndRow[1] + 160,a2ndRow[2] + 565 MSCOMBOBOX oGerNPR 	VAR cGerNPR ITEMS {"1=Sim", "2=Não"} OF oDlg PIXEL SIZE 38, 9  When .T.

	@ a2ndRow[1] + 177,a2ndRow[2] + 500 SAY "Informa Número NF" OF oDlg PIXEL
	@ a2ndRow[1] + 175,a2ndRow[2] + 565 MSCOMBOBOX oInfNNF 		VAR cInfNNF ITEMS {"1=Sim", "2=Não"} OF oDlg PIXEL SIZE 38, 9  When .T.

	oBrwZAG := TCBrowse():New(a3rdRow[1] + 040,a3rdRow[2] + 005,aPosObj[1,3] - 003,aPosObj[1,4] - 075,,,,oBrwZAG,,,,,,,,,,,,.T.,"",.T.,{|| .T.},,,,)

	oBrwZAG:AddColumn(TCColumn():New("Status"			,{|| IIF(aItens[oBrwZAG:nAt,1] == "A", "Aberto", IIF(aItens[oBrwZAG:nAt,1] == "E", "Encerrado", "Parcial")) },,,,"LEFT",35,.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Número"			,{|| aItens[oBrwZAG:nAt,2]},					,,,"LEFT" ,30,	.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Lote"				,{|| aItens[oBrwZAG:nAt,3]},					,,,"LEFT" ,25,	.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Produto"			,{|| aItens[oBrwZAG:nAt,4]},					,,,"LEFT" ,30,	.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Descrição"		,{|| aItens[oBrwZAG:nAt,5]},					,,,"LEFT" ,40,	.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Cabeças"			,{|| aItens[oBrwZAG:nAt,6]}, "@E 99999"			,,,"RIGHT",30,	.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Saldo Cabeças"	,{|| aItens[oBrwZAG:nAt,7]}, "@E 99999" 		,,,"RIGHT",45,	.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Peso"				,{|| aItens[oBrwZAG:nAt,8]}, "@E 999,999.99" 	,,,"RIGHT",30,	.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Saldo Peso"		,{|| aItens[oBrwZAG:nAt,9]}, "@E 999,999.99"  	,,,"RIGHT",35,	.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Preço Unitário"	,{|| aItens[oBrwZAG:nAt,10]},"@E 999,999.99"	,,,"RIGHT",45,	.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Total"			,{|| aItens[oBrwZAG:nAt,11]},"@E 999,999.999" 	,,,"RIGHT",35,	.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Comissão"			,{|| aItens[oBrwZAG:nAt,12]},"@E 999,999.99"	,,,"RIGHT",35,	.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Peso Real"		,{|| aItens[oBrwZAG:nAt,13]},"@E 999,999.99" 	,,,"RIGHT",35,	.F.,.F.,,,,,))
	oBrwZAG:AddColumn(TCColumn():New("Comprador"		,{|| aItens[oBrwZAG:nAt,14]+" - "+AllTrim(GetAdvFVal("SA3", "A3_NOME", FWxFilial("SA3") + aItens[oBrwZAG:nAt,14], 1))},,,,"LEFT" ,60,.F.,.F.,,,,,))

	oBrwZAG:lAutoEdit := .F.
	oBrwZAG:lReadOnly := .F.
	oBrwZAG:SetArray(aItens)

	@ a4thRow[1] + 005,a4thRow[2] + 010	SAY "Total Boi" 	OF oDlg PIXEL
	@ a4thRow[1] + 005,a4thRow[2] + 040	SAY oTotBois VAR nTotBois PICTURE "@E 99999" OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE
	@ a4thRow[1] + 015,a4thRow[2] + 010	SAY "Total Vaca" 	OF oDlg PIXEL
	@ a4thRow[1] + 015,a4thRow[2] + 040	SAY oTotVaca VAR nTotVaca PICTURE "@E 99999" OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE
	@ a4thRow[1] + 005,a4thRow[2] + 110	SAY "Total Touro" OF oDlg PIXEL
	@ a4thRow[1] + 005,a4thRow[2] + 140	SAY oTotTour VAR nTotTour PICTURE "@E 99999" OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE
	@ a4thRow[1] + 005,a4thRow[2] + 210	SAY "Total Búfalo" OF oDlg PIXEL
	@ a4thRow[1] + 005,a4thRow[2] + 240	SAY oTotBufo VAR nTotBufo PICTURE "@E 99999" OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE
	@ a4thRow[1] + 015,a4thRow[2] + 210	SAY "Total Búfala" OF oDlg PIXEL
	@ a4thRow[1] + 015,a4thRow[2] + 240	SAY oTotBufa VAR nTotBufa PICTURE "@E 99999" OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE

	DEFINE SBUTTON  FROM a4thRow[1] + 010, a4thRow[2] + 350 TYPE 13 ACTION (nOpt:=1,IIF(SalvaZF1(),oDlg:End(),nOpt:=0)) ENABLE OF oDlg PIXEL    // Salvar
	DEFINE SBUTTON  FROM a4thRow[1] + 010, a4thRow[2] + 400 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg PIXEL 												  // Cancelar

	ACTIVATE MSDIALOG oDlg CENTER

	If nOpt == 1
		If MsgYesNo("Deseja gerar o Pedido de Compra e Nota Fiscal para o produtor " + AllTrim(cNomFor) + " ?","Confirma?")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GERAÇÃO DO PEDIDO DE COMPRA		                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_lIncl    := .F.
			_aComis   := {} 		// Vetor para aglutinar comissoes
			_cForn    := ""
			_cContato := ""
			_dData    := DDATABASE
			_aPedGer  := {}

			For nY := 1 To Len(aItens)
				DbSelectArea("ZAG")
				DbSetOrder(1)
				If ZAG->(MsSeek(FWxFilial("ZAG") + aItens[nY,2]))
					If _cForn <> ZAG->ZAG_FORNEC + ZAG->ZAG_LOJA
						_cForn  := ZAG->ZAG_FORNEC + ZAG->ZAG_LOJA
						_cNumPC := GetSxeNum("SC7","C7_NUM")
						ConfirmSX8()

						aAdd(_aPedGer, {_cNumPC})		// Salva número do pedido de compra gerado para gerar nota fiscal

						_nItem      := 1
						_cTP        := GetAdvFVal("SA2", "A2_TIPORUR", FWxFilial("SA2") + _cForn, 1)
						_cContato   := GetAdvFVal("SA2", "A2_CONTATO", FWxFilial("SA2") + _cForn, 1)
						_dData      := GetAdvFVal("SZG", "ZG_DATA", FWxFilial("SZG") + ZAG->ZAG_NUMAM, 1)
						_nTotComiss := 0
						_nTotBase   := 0
					Endif

					DbSelectArea("SB1")
					_cGrupo := GetAdvFVal("SB1", "B1_GRUPO", FWxFilial("SB1") + ZAG->ZAG_PRODUT, 1)
					_cCusto	:= GetAdvFVal("SB1", "B1_CC", FWxFilial("SB1") + ZAG->ZAG_PRODUT, 1)

					// Busca conta contábil
					If GetAdvFVal("SF4", "F4_ESTOQUE", FWxFilial("SF4") + cTES, 1) == "S"
						_CtaContab := GetAdvFVal("SB1", "B1_ESTOQUE", FWxFilial("SB1") + ZAG->ZAG_PRODUT, 1)
					Else
						_CtaContab := GetAdvFVal("SB1", "B1_CONSUMO", FWxFilial("SB1") + ZAG->ZAG_PRODUT, 1)
					Endif

					_nValCom := ZAG->ZAG_COMISS / ZAG->ZAG_QUANT
					_nValCom := _nValCom * ZAG->ZAG_QUANT

					// Apura o peso vivo do item/produto (macho ou femea)
					_nTPesVivo := 0
					DbSelectArea("SZK")
					DbOrderNickName("NUMRECNZAG")
					DbSeek(FWxFilial("SZK") + Str(ZAG->( Recno() ),10,0))
					While !Eof() .And. SZK->ZK_FILIAL + STR(SZK->ZK_RECNZAG) == FWxFilial("SZK") + Str(ZAG->( Recno() ))
						_nTPesVivo := _nTPesVivo + SZK->ZK_PESVIVO
						DbSelectArea("SZK")
						DbSkip()
					EndDo

					DbSelectArea("SC7")
					RecLock("SC7",.T.)
					SC7->C7_FILIAL  := FWxFilial("SC7")
					SC7->C7_NUM     := _cNumPC
					SC7->C7_FORNECE := ZAG->ZAG_FORNEC
					SC7->C7_LOJA    := ZAG->ZAG_LOJA
					SC7->C7_COND    := ZAG->ZAG_COND
					SC7->C7_CONTATO := _cContato
					SC7->C7_EMISSAO := _dData
					SC7->C7_PRODUTO := ZAG->ZAG_PRODUT
					SC7->C7_TIPO    := 1
					SC7->C7_ITEM    := StrZero(_nItem,4)
					SC7->C7_DESCRI  := ZAG->ZAG_DESCRI
					SC7->C7_UM      := "KG"
					SC7->C7_SEGUM   := "CB"
					SC7->C7_QUANT   := _nTPesVivo											// ZAG->ZAG_PESO - conteúdo anterior
					SC7->C7_QTSEGUM := ZAG->ZAG_QUANT
					SC7->C7_PRECO   := (ZAG->ZAG_PESO * ZAG->ZAG_PRECO) / _nTPesVivo		// ZAG->ZAG_PRECO - conteúdo anterior
					SC7->C7_TOTAL   := ZAG->ZAG_PESO * ZAG->ZAG_PRECO
					SC7->C7_DATPRF  := _dData
					SC7->C7_DTABATE := _dData
					SC7->C7_CONTA   := _CtaContab
					If _cGrupo == "1000"
						SC7->C7_CC	:= _cCusto
					Endif
					SC7->C7_TXMOEDA := 1
					SC7->C7_MOEDA   := 1
					SC7->C7_LOCAL   := "01"
					SC7->C7_CONAPRO := "L"
					SC7->C7_DTABATE := _dData
					SC7->C7_TPCOM   := ZAG->ZAG_TPCOM
					SC7->C7_FILENT  := FWxFilial("SC7")
					SC7->C7_COMPR   := ZAG->ZAG_COMPR
					SC7->C7_GRUPO   := _cGrupo
					SC7->C7_NUMAM   := ZAG->ZAG_NUMAM
					SC7->C7_LOTE    := ZAG->ZAG_LOTE
					SC7->C7_TES     := cTES
					SC7->C7_TPFRETE := "C"
					SC7->C7_FLUXO   := "S"
					SC7->C7_MOEDA   := 1
					SC7->C7_COMISS  := _nValCom
					SC7->C7_TPCOM   := ZAG->ZAG_TPCOM
					SC7->C7_NUMFCG  := ZAG->ZAG_NUM
					SC7->C7_PCNOTA  := "SPED"
					SC7->C7_ORIGEM  := "STI_RG06"
					SC7->C7_QTDREND := ZAG->ZAG_PESO						// Qtde Rendimento
					SC7->C7_PRCREND := ZAG->ZAG_PRECO						// Preço Rendimento
					SC7->C7_TOTREND := ZAG->ZAG_PESO * ZAG->ZAG_PRECO		// Total Rendimento
					MsUnlock()

					_lIncl := .T.

					// Tratamento da comissão
					_nPos := aScan(_aComis,{|aVal|aVal[1] == _cNumPC})
					If _nPos <> 0
						_aComis[_nPos,6] += _nValCom                       	// somatorio para o total de comissao do PC
						_aComis[_nPos,7] += ZAG->ZAG_PESO * ZAG->ZAG_PRECO 	// somatorio para o total da base de comissao do PC
					Else
						aAdd(_aComis,{_cNumPc,_dData,ZAG->ZAG_FORNEC,ZAG->ZAG_LOJA,ZAG->ZAG_COMPR,_nValCom,ZAG->ZAG_PESO * ZAG->ZAG_PRECO})
					Endif

					// Atualiza saldos e status na ZAG
					RecLock("ZAG",.F.)
					ZAG->ZAG_SLDQ   -= ZAG->ZAG_QUANT
					ZAG->ZAG_SLDP   -= ZAG->ZAG_PESO
					ZAG->ZAG_STATUS := "E"
					MsUnlock()

					_nItem++
				Else
					MsgAlert("Registro não encontrado na geração do Pedido de Compra. Favor entrar em contato com a DTI e informar essa mensagem.")
				Endif
			Next

			MsgRun("Gerando Nota de Entrada..." ,,{|| GeraNFe(cNFP01,cSER01)})
			MsgRun("Gerando Comissões..." ,,{|| GeraCom()})

			If _lIncl
				MsgBox("Inclusão do pedido e NOTA FISCAL / SÉRIE => " + cDocto + " / " + cSerie + " efetivada com sucesso!","Fechamento Compra de Gado","INFO")
			Else
				MsgBox("Não ha operação a ser realizada!","Fechamento Compra de Gado","STOP")
			Endif

		Endif
	Endif

	_oDlg:End()		// Fecha janela principal do browse

	U_STI_RG06(2)	// Reabre TCBrowse principal executando refresh na janela principal do browse

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função que valida o TES                                                ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VldTES()

	Local aArea := GetArea()
	Local lRet  := .T.

	If !Empty(cTES)
		DbSelectArea("SF4")
		SF4->(DbGoTop())
		If SF4->(MsSeek(FWxFilial("SF4") + cTES))
			If SF4->F4_TIPO == "S"
				lRet := .F.
				Help(" ",1,"STI_RG06TESE",,"A TES utilizada deve ser de entrada!",1,0)
			EndIf
		Else
			lRet := .F.
			Help(" ",1,"STI_RG06TESNENC",,"TES não encontrada!",1,0)
		EndIf
	Else
		lRet := .F.
		Help(" ",1,"STI_RG06TESOBRIG",,"Preencha o campo TES!",1,0)
	EndIf

	RestArea(aArea)

Return(lRet)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função que salva os dados informados na tela de complementos          	³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function SalvaZF1()
	Local nX
	lRet := .T.

	If Empty(cPlaca)
		MsgAlert("É obrigatório informar a Placa. Verifique!")
		Return(.F.)
	Endif

	DbSelectArea("ZF1")
	DbSetOrder(1)
	If MsSeek(FWxFilial("ZF1") + _cChave)
		RecLock("ZF1",.F.)
	Else
		RecLock("ZF1",.T.)
	Endif
	ZF1->ZF1_FILIAL := FWxFilial("ZF1")
	ZF1->ZF1_CHAVE	:= _cChave
	ZF1->ZF1_PLACA  := cPlaca
	ZF1->ZF1_NFPN01 := cNFP01
	ZF1->ZF1_NFPS01 := cSER01
	ZF1->ZF1_NFPN02 := cNFP02
	ZF1->ZF1_NFPS02 := cSER02
	ZF1->ZF1_NFPN03 := cNFP03
	ZF1->ZF1_NFPS03 := cSER03
	ZF1->ZF1_NFPN04 := cNFP04
	ZF1->ZF1_NFPS04 := cSER04
	ZF1->ZF1_NFPN05 := cNFP05
	ZF1->ZF1_NFPS05 := cSER05
	ZF1->ZF1_NFPN06 := cNFP06
	ZF1->ZF1_NFPS06 := cSER06
	ZF1->ZF1_NFPN07 := cNFP07
	ZF1->ZF1_NFPS07 := cSER07
	ZF1->ZF1_NFPN08 := cNFP08
	ZF1->ZF1_NFPS08 := cSER08
	ZF1->ZF1_NFPN09 := cNFP09
	ZF1->ZF1_NFPS09 := cSER09
	ZF1->ZF1_NFPN10 := cNFP10
	ZF1->ZF1_NFPS10 := cSER10
	ZF1->ZF1_NFPN11 := cNFP11
	ZF1->ZF1_NFPS11 := cSER11
	ZF1->ZF1_NFPN12 := cNFP12
	ZF1->ZF1_NFPS12 := cSER12
	ZF1->ZF1_NFPN13 := cNFP13
	ZF1->ZF1_NFPS13 := cSER13
	ZF1->ZF1_NFPN14 := cNFP14
	ZF1->ZF1_NFPS14 := cSER14
	ZF1->ZF1_NFPN15 := cNFP15
	ZF1->ZF1_NFPS15 := cSER15
	ZF1->ZF1_NFPN16 := cNFP16
	ZF1->ZF1_NFPS16 := cSER16
	ZF1->ZF1_NFPN17 := cNFP17
	ZF1->ZF1_NFPS17 := cSER17
	ZF1->ZF1_NFPN18 := cNFP18
	ZF1->ZF1_NFPS18 := cSER18
	ZF1->ZF1_NFPN19 := cNFP19
	ZF1->ZF1_NFPS19 := cSER19
	ZF1->ZF1_NFPN20 := cNFP20
	ZF1->ZF1_NFPS20 := cSER20
	ZF1->ZF1_NFPN21 := cNFP21
	ZF1->ZF1_NFPS21 := cSER21
	ZF1->ZF1_NFPN22 := cNFP22
	ZF1->ZF1_NFPS22 := cSER22
	ZF1->ZF1_NFPN23 := cNFP23
	ZF1->ZF1_NFPS23 := cSER23
	ZF1->ZF1_NFPN24 := cNFP24
	ZF1->ZF1_NFPS24 := cSER24
	ZF1->ZF1_NFPN25 := cNFP25
	ZF1->ZF1_NFPS25 := cSER25
	ZF1->ZF1_NFPN26 := cNFP26
	ZF1->ZF1_NFPS26 := cSER26
	ZF1->ZF1_NFPN27 := cNFP27
	ZF1->ZF1_NFPS27 := cSER27
	ZF1->ZF1_NFPN28 := cNFP28
	ZF1->ZF1_NFPS28 := cSER28
	ZF1->ZF1_NFPN29 := cNFP29
	ZF1->ZF1_NFPS29 := cSER29
	ZF1->ZF1_NFPN30 := cNFP30
	ZF1->ZF1_NFPS30 := cSER30
	ZF1->ZF1_NFPN31 := cNFP31
	ZF1->ZF1_NFPS31 := cSER31
	ZF1->ZF1_NFPN32 := cNFP32
	ZF1->ZF1_NFPS32 := cSER32
	ZF1->ZF1_NFPN33 := cNFP33
	ZF1->ZF1_NFPS33 := cSER33
	ZF1->ZF1_NFPN34 := cNFP34
	ZF1->ZF1_NFPS34 := cSER34
	ZF1->ZF1_NFPN35 := cNFP35
	ZF1->ZF1_NFPS35 := cSER35
	ZF1->ZF1_NFPN36 := cNFP36
	ZF1->ZF1_NFPS36 := cSER36
	ZF1->ZF1_NFPN37 := cNFP37
	ZF1->ZF1_NFPS37 := cSER37
	ZF1->ZF1_NFPN38 := cNFP38
	ZF1->ZF1_NFPS38 := cSER38
	ZF1->ZF1_NFPN39 := cNFP39
	ZF1->ZF1_NFPS39 := cSER39
	ZF1->ZF1_NFPN40 := cNFP40
	ZF1->ZF1_NFPS40 := cSER40
	ZF1->ZF1_TES    := cTES
	ZF1->ZF1_GERNPR := cGerNPR
	ZF1->ZF1_VENCTO := dVencto

	_cMensagem := "REF. NFPs"
	For nX := 1 To 40
		If !Empty( &("ZF1->ZF1_NFPN" + StrZero(nX,2,0)) )
			_cMensagem += " " + AllTrim(&("ZF1->ZF1_NFPN" + StrZero(nX,2,0)))
		Endif
		If !Empty( &("ZF1->ZF1_NFPS" + StrZero(nX,2,0)) )
			_cMensagem += "/" + AllTrim(&("ZF1->ZF1_NFPS" + StrZero(nX,2,0)))
		Endif
	Next

	ZF1->ZF1_MENS01 := cMens01
	ZF1->ZF1_MENS02 := Substr(_cMensagem, 001, 180)
	ZF1->ZF1_MENS03 := Substr(_cMensagem, 181, 180)
	ZF1->ZF1_MENS04 := Substr(_cMensagem, 361, 180)
	ZF1->ZF1_MENS05 := cMens05
	MsUnlock()

Return(lRet)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função GeraNFe para gerar nota de entrada ref. ao pedido gerado	       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GeraNFe(_cNFP01,_cSER01)

	Local aCabec 	:= {}
	Local aItens 	:= {}
	Local aLinha 	:= {}
	Local _nPLiqui  := 0
	Local _nPBruto  := 0
	Local _nVolume  := 0
	Local nX 	 	:= 0

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Public cSerie 	  := ""
	Public cDocto 	  := ""

	
	_cFSCTRASC := GetMv("FS_CTRASC")
	For nX := 1 To Len(_aPedGer)
		lMsErroAuto := .F.
		lMsHelpAuto := .T.

		aItens   := {}
		_nPLiqui := 0
		_nPBruto := 0
		_nVolume := 0

		SC7->(DbSetOrder(1))
		SC7->(DbGoTop())
		SC7->(MsSeek(FWxFilial("SC7") + alltrim(_aPedGer[nX,1])))
		While !SC7->(Eof()) .And. SC7->C7_FILIAL + SC7->C7_NUM == FWxFilial("SC7") + alltrim(_aPedGer[nX,1])
			If SC7->C7_ITEM == "0001"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Função PADRÃO NxtSX5Nota - Verifica o próximo número de nota fiscal disponível  ³
				//³ ------------------------------------------------------------------------------- ³
				//³ Parametros - ExpC1: Série da Nota fiscal                                        ³
				//³              ExpL3: Tipo de numeração de nota fiscal de saída                   ³
				//³                     [1] Numeracao controla pelo SX5                             ³
				//³                     [2] Numeracao controla pelo SXE/SXF                         ³
				//³                     [3] Numeracao controla pelo SD9                             ³
				//³              ExpL4: Indicador de alteração do Número da NF sugerida             ³
				//³ ------------------------------------------------------------------------------- ³
				//³ Retorno    - ExpC1: Número da Nota Fiscal                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cSerie  := "50 "
				cDocSX5 := NxtSX5Nota(cSerie)

				// Abre tela para informar número da nota fiscal conforme resposta da pergunta na tela de complemento
				If cInfNNF == "1"
					cDocto := _InfNumNF(cDocSX5)
				Else
					cDocto := cDocSX5
				Endif

				cForne := SC7->C7_FORNECE
				cLoja  := SC7->C7_LOJA
				cNome  := GetAdvFVal("SA2", "A2_NOME", FWxFilial("SA2") + cForne + cLoja, 1)
				//alert('Fornecedor/Loja ->'+cForne+' - '+cLoja)
				//alert('Fornecedor ->'+cDocto)
				// Array contendo os dados do cabeçalho da nota fiscal de entrada
				aCabec := {}
				aAdd(aCabec,{"F1_FILIAL"	, FWxFilial("SF1")							, Nil})
				aAdd(aCabec,{"F1_TIPO" 		, "N" 										, Nil})
				aAdd(aCabec,{"F1_FORMUL"	, "S" 										, Nil})
				aAdd(aCabec,{"F1_DOC" 		, cDocto									, Nil})
				aAdd(aCabec,{"F1_SERIE" 	, cSerie									, Nil})
				aAdd(aCabec,{"F1_EMISSAO" 	, DDATABASE 								, Nil})
				aAdd(aCabec,{"F1_FORNECE" 	, SC7->C7_FORNECE							, Nil})
				aAdd(aCabec,{"F1_LOJA" 		, SC7->C7_LOJA								, Nil})
				aAdd(aCabec,{"F1_ESPECIE" 	, SC7->C7_PCNOTA							, Nil})
				aAdd(aCabec,{"F1_COND" 		, SC7->C7_COND								, Nil})
				aAdd(aCabec,{"F1_MOEDA" 	, 1 										, Nil})
				aAdd(aCabec,{"F1_MENDFE1"	, GetAdvFVal("ZF1", "ZF1_MENS01", FWxFilial("ZF1") + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_NUMAM, 1)	, Nil})
				aAdd(aCabec,{"F1_MENDFE2"	, GetAdvFVal("ZF1", "ZF1_MENS02", FWxFilial("ZF1") + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_NUMAM, 1)	, Nil})
				aAdd(aCabec,{"F1_MENDFE3"	, GetAdvFVal("ZF1", "ZF1_MENS03", FWxFilial("ZF1") + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_NUMAM, 1)	, Nil})
				aAdd(aCabec,{"F1_MENDFE4"	, GetAdvFVal("ZF1", "ZF1_MENS04", FWxFilial("ZF1") + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_NUMAM, 1)	, Nil})
				aAdd(aCabec,{"F1_MENDFE5"	, GetAdvFVal("ZF1", "ZF1_MENS05", FWxFilial("ZF1") + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_NUMAM, 1)	, Nil})
				aAdd(aCabec,{"F1_PLACA" 	, GetAdvFVal("ZF1", "ZF1_PLACA" , FWxFilial("ZF1") + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_NUMAM, 1) , Nil})
				aAdd(aCabec,{"F1_TRANSP"	, _cFSCTRASC								, Nil})
				aAdd(aCabec,{"F1_NUMAM"		, SC7->C7_NUMAM     						, Nil})
				aAdd(aCabec,{"F1_LOTE"  	, SC7->C7_LOTE      						, Nil})
				aAdd(aCabec,{"F1_INDPRES"  	, "0"			      						, Nil})
				aAdd(aCabec,{"F1_CODA1U"  	, ""			      						, Nil})

			Endif

			// Array contendo os itens da nota fiscal de entrada
			aLinha := {}
			aAdd(aLinha,{"D1_FILIAL"	, FWxFilial("SD1")					, Nil})
			aAdd(aLinha,{"D1_COD" 		, SC7->C7_PRODUTO					, Nil})
			aAdd(aLinha,{"D1_DESCRI"	, SC7->C7_DESCRI					, Nil})
			aAdd(aLinha,{"D1_QUANT" 	, SC7->C7_QUANT						, Nil})
			aAdd(aLinha,{"D1_VUNIT" 	, SC7->C7_PRECO						, Nil})
			aAdd(aLinha,{"D1_TOTAL" 	, SC7->C7_TOTAL						, Nil})
			aAdd(aLinha,{"D1_TES" 		, SC7->C7_TES						, Nil})
			aAdd(aLinha,{"D1_CONTA"		, SC7->C7_CONTA						, Nil})
			aAdd(aLinha,{"D1_CC"		, SC7->C7_CC						, Nil})
			aAdd(aLinha,{"D1_PEDIDO"   	, SC7->C7_NUM                       , NIL})
			aAdd(aLinha,{"D1_ITEMPC"   	, SC7->C7_ITEM                      , NIL})
			aAdd(aLinha,{"D1_ITEMORI"  	, "0001"                            , NIL})
			aAdd(aLinha,{"D1_NFORI"    	, _cNFP01                           , NIL})
			aAdd(aLinha,{"D1_SERIORI"  	, _cSER01                           , NIL})
			aAdd(aLinha,{"AUTDELETA" 	, "N" 								, Nil}) // Incluir sempre no último elemento do array de cada item
			aAdd(aItens,aLinha)

			_nPLiqui += SC7->C7_QTDREND
			_nPBruto += SC7->C7_QUANT
			_nVolume += SC7->C7_QTSEGUM

			SC7->(DbSkip())
		EndDo

		If Len(aCabec) > 0 .And. Len(aItens) > 0
			// Complementa array com informações do cabeçalho da nota fiscal
			aAdd(aCabec,{"F1_PLIQUI"	, _nPLiqui										, Nil})
			aAdd(aCabec,{"F1_PBRUTO"	, _nPBruto										, Nil})
			aAdd(aCabec,{"F1_ESPECI1"	, "CABECA"       								, Nil})
			aAdd(aCabec,{"F1_VOLUME1"	, _nVolume										, Nil})

			MATA103(aCabec,aItens,3,,,,,,,,) 	//	Opção desejada: 3-Inclusão; 4-Alteração ; 5-Exclusão

			If !lMsErroAuto
			Else
				MostraErro()
			EndIf
		Endif
	Next

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função GeraCom para gerar comissões                                    ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GeraCom()
	Local k
	// GERA COMISSÃO PELO TOTAL DO LOTE SEGUINDO AS REGRAS DAS COMISSÕES
	For k:=1 To Len(_aComis)
		RecLock("SE3",.T.)
		SE3->E3_FILIAL  := FWxFilial("SE3")
		SE3->E3_VEND    := _aComis[k,5]
		SE3->E3_NUM     := _aComis[k,1]
		SE3->E3_EMISSAO := _aComis[k,2]
		SE3->E3_SERIE   := ""
		SE3->E3_CODCLI  := _aComis[k,3]
		SE3->E3_LOJA    := _aComis[k,4]
		SE3->E3_BASE    := _aComis[k,7]
		SE3->E3_PORC    := 0.00
		SE3->E3_COMIS   := _aComis[k,6]
		SE3->E3_PREFIXO := ""
		SE3->E3_TIPO    := "CG"
		SE3->E3_BAIEMI  := "E"
		SE3->E3_PEDIDO  := " "
		SE3->E3_ORIGEM  := "C"
		SE3->E3_VENCTO  := _aComis[k,2]
		MsUnlock()
	Next
Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função RG06SPED para chamar rotina de transmissão da NF-e              ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RG06SPED()

	Local nModOld := nModulo
	Local cModOld := cModulo
	Local lRet    := .T.

	nModulo := 5 		// SIGAFAT
	cModulo := "FAT"

	SPEDNFE()

	nModulo := nModOld
	cModulo := cModOld

Return lRet

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³ Função InfNumNF para informar número da nota a Ser Gerada              ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _InfNumNF(cDocSX5)

	Local _aArea  := GetArea()
	Local _cNumNF := cDocSX5

	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Número da Nota Fiscal")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)

	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(250), C(700) PIXEL
	@ C(005), C(090) SAY "NÚMERO   DA   NOTA   FISCAL   A   SER   GERADO"	Size C(300), C(12) FONT _oFtArial30 COLOR CLR_GREEN PIXEL OF _oTela

	@ C(015), C(010) SAY "Número NF"   		       				Size C(080), C(10) FONT _oFtArial24 COLOR CLR_BLUE PIXEL OF _oTela
	@ C(024), C(010) MSGET _cNumNF Picture "@!" When .T. 		Size C(050), C(08) FONT _oFCourier  COLOR CLR_BLUE PIXEL OF _oTela

	@ C(050), C(010) SAY "A T E N Ç Ã O:"  						Size C(150), C(10) FONT _oFtArial24 COLOR CLR_HRED PIXEL OF _oTela
	@ C(060), C(010) SAY "================"  					Size C(150), C(10) FONT _oFtArial24 COLOR CLR_HRED PIXEL OF _oTela
	@ C(070), C(010) SAY "Informe um número de nota fiscal válido e ainda não calculado para evitar que na finalização do processo"  Size C(300), C(10) FONT _oFtArial24 COLOR CLR_HRED	PIXEL OF _oTela
	@ C(085), C(010) SAY "desta nota fiscal não gere qualquer tipo de erro."  														 Size C(300), C(10) FONT _oFtArial24 COLOR CLR_HRED	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(110), C(290) TYPE 1 OBJECT _oCancel ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED

	RestArea(_aArea)

Return _cNumNF
