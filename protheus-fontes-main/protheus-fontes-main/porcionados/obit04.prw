#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OBIT04  º Autor ³ clei@8bit.inf.br     º Data ³ 21/10/2023  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Controle de consumo de materia prima   º±±
±±º          ³Porcionados                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP Porcionados                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    
User Function OBIT04()
	Private oDlg      := nil
	Private oBrowse1  := nil
	Private	oFont     := tFont():New("arial",,-12,,.t.)
	Private	oFont2    := tFont():New("arial",,-14,,.t.)
	Private aBrowse1  := {}
	Private nQtdCaix1 := 0
	Private nQtdPeso1 := 0.00
	Private nLastKey  := 0
	Private cTotCaixa := 'Total de Caixas: '
	Private cTotPeso  := 'Total de Peso Caixas: '
	Private cPerg	  := 'OBIT04'

	DbSelectArea('ZAA')
	ZAA->(DbSetOrder(2))
	If ZAA->(MsSeek(FWxfilial('ZAA')+__cUserID))
		If ZAA->ZAA_STATUS == 'B'
			FWAlertError("Usuario bloqueado!", "Consome MP")
			Return
		EndIf
		If ZAA->ZAA_APL13 <> 'S'
			FWAlertError("Opção negada para o usuario!", "Consome MP")
			Return
		EndIf
	Else
		FWAlertError("Usuario não habilitado!", "Consome MP")
		Return
	EndIf

	Pergunte(cPerg,.t.)

	//aObjects := {}    //dimensao janelas
	//aPosObj  := {}
	//aInfo    := {}

	//aSizeAut := MsAdvSize()

	//AAdd( aObjects, { 315, 50, .T., .T. } )
	//AAdd( aObjects, { 100, 100, .T., .T. } )
	//aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	//aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aHeader1  := {'','Batelada','Código MP','Descriçao','Peso Prod.','Qtd. Caixas','Peso Cons.'}
	aLargCol1 := {5,   40    ,    40  ,        120        ,  50    ,        50      ,    50     }

	DEFINE DIALOG oDlg TITLE "Consumo de Materia Prima - "+DTOC(dDataBase) FROM 020,050 To 600, 1200 PIXEL

	oBrowse1 := TCBrowse():New(005,005,500,260,,aHeader1,aLargCol1,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.F.)

	//Busca Dados
	If !GrTrbZax()
		FWAlertError("Não há dados para o dia "+DTOC(dDataBase), "Consome MP")
		Return
	EndIf

	// Seta vetor para a browse
	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],aBrowse1[oBrowse1:nAT,06],aBrowse1[oBrowse1:nAT,07]}}

	oBrowse1:bLDblClick  := {|| ConsomeCaixas(aBrowse1[oBrowse1:nAt,02]) }
	//codigo,descricao,tipo,terc,caixas,peso

	// Posiciona na primeira linha
	oBrowse1:GoTop()

	oSayTotC :=  tSay():New(280, 230,{||cTotCaixa},oDlg,,oFont,,,,.T.,,,200,30)
	oSayTotP :=  tSay():New(280, 330,{||cTotPeso },oDlg,,oFont,,,,.T.,,,200,30)

	oBtn1 := TButton():New(020, 520, "Lê Caixas"   , oDlg,{|| ConsomeCaixas(aBrowse1[oBrowse1:nAt,02])},040,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn2 := TButton():New(040, 520, "Lê Pallet"   , oDlg,{|| ConsomePallet(aBrowse1[oBrowse1:nAt,02])},040,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn3 := TButton():New(060, 520, "Estorna"     , oDlg,{|| RetornaCaixas(aBrowse1[oBrowse1:nAt,02])},040,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn4 := TButton():New(080, 520, "Detalhes"    , oDlg,{|| DetalhesBatelada(aBrowse1[oBrowse1:nAt,02])},040,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn5 := TButton():New(100, 520, "Sair"        , oDlg,{|| oDlg:end()                                 },040,015,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED

Return

//Gera lista de lotes
Static Function GrTrbZax()
	Local cQuery    := ""

	nQtdCaix1 := 0
	nQtdPeso1 := 0.00

	cQuery := " SELECT ZAX_NUM AS BATEL, ZAX_DESCRI AS DESCRI, ZAX_CODMP AS CODMP, ZAX_QTDMP AS QTDMP, COUNT(*) AS QUANT, SUM(ZAS_PESOL) AS PESO, ZAX_STATUS AS STATUS
	cQuery += " FROM  "+retSqlTab('ZAX')
	cQuery += " LEFT JOIN "+retSqlTab('ZAS')+" ON ZAS_FILIAL = ZAX_FILIAL AND ZAS_BATEL = ZAX_NUM AND "+retSqlDel('ZAS')
	cQuery += " WHERE "+retSqlFil('ZAX')
	cQuery += " AND ZAX_DTPROD = '" + DTOS(dDataBase) + "'"
	if mv_par01 = 1
		cQuery += " AND ZAX_REC = 'S'"
	elseif mv_par01 = 2
		cQuery += " AND ZAX_REC = 'N'"
	endif
	cQuery += " AND "+retSqlDel('ZAX')
	cQuery += " GROUP BY ZAX_NUM, ZAX_DESCRI, ZAX_CODMP, ZAX_QTDMP, ZAX_STATUS "
	cQuery += " ORDER BY ZAX_NUM, ZAX_CODMP"
	cQuery := ChangeQuery(cQuery)

	If Select("TRBZAX") != 0
		TRBZAX->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TRBZAX"

	aBrowse1 := {}

	While TRBZAX->(!eof())
		aadd(aBrowse1,{RetCor(TRBZAX->STATUS),;
			TRBZAX->BATEL,;
			TRBZAX->CODMP,;
			PADR(TRBZAX->DESCRI,50," "),;
			PADL(transform(TRBZAX->QTDMP,"@E 999,999.99"),30," "),;
			PADL(transform(TRBZAX->QUANT,"@E 999,999"),20," "),;
			PADL(transform(TRBZAX->PESO,"@E 999,999.99"),30," ")})

		nQtdCaix1 += TRBZAX->QUANT
		nQtdPeso1 += TRBZAX->PESO

		TRBZAX->(DbSkip())
	EndDo

	If len(aBrowse1) == 0
		Return .F.
	EndIf

	cTotCaixa := "Total de Caixas: "+ Transform(nQtdCaix1,'@E 999,999')
	cTotPeso  := "Peso Total de Caixas: "+ Transform(nQtdPeso1,'@E 999,999,999.99')
Return .T.

//Consome a Caixa
Static Function ConsomeCaixas(cBatel)
	Private nQtdCx  := 0
	Private nPesMPCx:= 0
	Private aCaixas := {{"","","","",0.00}}
	Private oBCaixa := nil
	Private lOk     := .T.
	Private lProduz := .F.
	Private oDl     := nil
	Private cCaixa  := Space(11)
	Private cMsgOk  := ""

	While lOk
		lProduz  := .F.
		cCaixa   := Space(11)

		@ 000,000 TO 380, 550 DIALOG oDl TITLE "Consumo de Materia Prima"
		oTSay1 := tSay():New(003, 005,{||'Código da Caixa'},oDl,,oFont,,,,.T.)
		oTGet1 := TGet():New(013, 005,{|u|if(PCount()==0,cCaixa,cCaixa:=u)},oDl,050,010,"@!",{||ValidaCaixa(cCaixa, @oDl, cBatel)},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cCaixa)
		oTBtn1 := TButton():New(013, 230, "Sair", oDl,{|| lOk:=.F., oDl:End()},040,015,,,.F.,.T.,.F.,,.F.,,,.F. )
		oTSAvs := tSay():New(030, 005,{|| '' },oDl,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,350,20)
		oTSOk  := tSay():New(030, 005,{|| cMsgOk},oDl,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,20)
		//Browse
		oBCaixa:= TCBrowse():New(042, 001, 280, 135,,{'Caixa','Codigo','Produto','Data','Peso'},{30,20,70,30,30}, oDl,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.F.)
		oBCaixa:SetArray(aCaixas)
		oBCaixa:bLine := {||{aCaixas[oBCaixa:nAt,01],aCaixas[oBCaixa:nAt,02],aCaixas[oBCaixa:nAt,03],aCaixas[oBCaixa:nAt,04],aCaixas[oBCaixa:nAT,05]}}
		//Total
		oTSay2 := tSay():New(180, 100,{||'Nro. Caixas:'+Transform(nQtdCx,'@E 999,999') },oDl,,oFont,,,,.T.)
		oTSay3 := tSay():New(180, 180,{||'Peso Consumido:'+Transform(nPesMPCx,'@E 999,999,999.99') },oDl,,oFont,,,,.T.)

		Activate MsDialog oDl Centered

		If Empty(cCaixa) .OR. nLastKey == 27
			lOk := .F.
			//oDl:End()
		ElseIf !Empty(cCaixa) .AND. lProduz
			ProduzCaixa(cBatel, cCaixa, ZAS->ZAS_PESOL)
			nQtdCx++
			nPesMPCx += ZAS->ZAS_PESOL
			If nQtdCx == 1
				aCaixas := {}
			EndIf
			AADD(aCaixas,{ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_DESC,DTOC(ZAS->ZAS_DTPROD),Transform(ZAS->ZAS_PESOL,'@E 999,999.99')})
			cMsgOk := "Caixa MP: " + Alltrim(ZAS->ZAS_DESC) + " CONSUMIDA!
			SomOk()
		EndIf
	EndDo
	//Atualiza a Grid Principal
	If nQtdCx > 0
		GrTrbZax()
		oBrowse1:Refresh()
		oBrowse1:DrawSelect()
		oDlg:Refresh()
	EndIf
Return

//Consome Pappet
Static Function ConsomePallet(cBatel)
	Local cPallet  := Space(10)
	//Local cPesoMPC := 0
	Local cDescri  := ""
	Local nCnt     := 0

	Private lProduz := .F.
	Private oDl     := nil
	Private cMsgOk  := ""

	cPallet  := Space(10)
	//cPesoMPC := BuscaPeso(cBatel)

	@ 000,000 TO 140,400 DIALOG oDl TITLE "Consumo de Materia Prima - Pallet"
	oTSay1 := tSay():New(003, 005,{||'Código do Pallet'},oDl,,oFont,,,,.T.)
	oTGet1 := TGet():New(013, 005,{|u|if(PCount()==0,cPallet,cPallet:=u)},oDl,050,010,"@!",{||ValidaPallet(cPallet)},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPallet)
	//otSay2 := tSay():New(030, 005,{||'Peso Consumido:'+Transform(cPesoMPC,'@E 999,999,999.99') },oDl,,oFont,,,,.T.)
	oTSAvs := tSay():New(030, 010,{|| '' },oDl,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,250,20)
	oTSOk  := tSay():New(030, 010,{|| cMsgOk},oDl,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,250,20)
	oTBtn1 := TButton():New(050, 160, "Sair", oDl,{|| cPallet:="", oDl:End() },040,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	Activate MsDialog oDl Centered

	If nLastKey == 27
		oDl:End()
	ElseIf !Empty(cPallet)
		ZAS->(dbSetOrder(6))
		ZAS->(dbGoTop())
		If ZAS->(MsSeek(FWxFilial('ZAS')+cPallet))
			While ZAS->(!Eof()) .AND. ZAS->ZAS_FILIAL = FWxFilial('ZAS') .AND. ZAS->ZAS_PALLET = cPallet
				cMsgOk := "Consumindo caixa... - "+Alltrim(ZAS->ZAS_CONTRO)
				oDl:Refresh()
				If ValidaCaixa(ZAS->ZAS_CONTRO, @oDl, cBatel)
					nCnt++
					cDescri := Alltrim(ZAS->ZAS_DESC)
					ProduzCaixa(cBatel, ZAS->ZAS_CONTRO, ZAS->ZAS_PESOL)
				EndIf
				ZAS->(DbSkip())
			EndDo
			Aviso("Lê Pallet", "MP: " + cDescri + " consumida, "+Alltrim(Str(nCnt))+" caixas lidas!",,1,,,,.F.,1500)
			SomOk()
			oDl:End()
		EndIf
		//Atualiza a Grid Principal
		GrTrbZax()
		oBrowse1:Refresh()
		oBrowse1:DrawSelect()
		oDlg:Refresh()
	EndIf
Return

//Retorna Caixas
Static Function RetornaCaixas(cBatel)
	Local cUsrMP    := getmv('SI_USRMP')
	Private cCaixa  := Space(11)
	//Local cPesoMPC:= 0
	Private lOk     := .T.
	Private lEstorna:= .F.
	Private oDl     := nil
	Private cMsgOk  := ""
	Private nQtdCx  := 0

	If !(__cUserID $ cUsrMP)
		Aviso("Estorna Caixa", "Usuário sem premissão!",,1,,,,.F.,1000)
		Return
	EndIf

	While lOk
		lEstorna := .F.
		cCaixa   := Space(11)
		//cPesoMPC := BuscaPeso(cBatel)

		@ 000,000 TO 140,400 DIALOG oDl TITLE "Estorno de Materia Prima"
		oTSay1 := tSay():New(003, 005,{||'Código da Caixa'},oDl,,oFont,,,,.T.)
		oTGet1 := TGet():New(013, 005,{|u|if(PCount()==0,cCaixa,cCaixa:=u)},oDl,050,010,"@!",{||ValidaEstorno(cBatel, cCaixa, @oDl)},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cCaixa)
		//otSay2 := tSay():New(030, 005,{||'Peso Consumido:'+Transform(cPesoMPC,'@E 999,999,999.99') },oDl,,oFont,,,,.T.)
		oTSAvs := tSay():New(030, 010,{|| '' },oDl,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,250,20)
		oTSOk  := tSay():New(030, 010,{|| cMsgOk},oDl,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,250,20)
		oTBtn1 := TButton():New(050, 160, "Sair", oDl,{|| lOk:=.F., cCaixa:="", oDl:End()},040,015,,,.F.,.T.,.F.,,.F.,,,.F. )
		Activate MsDialog oDl Centered

		If Empty(cCaixa) .OR. nLastKey == 27
			lOk := .F.
			//oDl:End()
		ElseIf !Empty(cCaixa) .AND. lEstorna
			nQtdCx++
			EstornaCaixa(cBatel, cCaixa, ZAS->ZAS_PESOL)
			cMsgOk := "Caixa MP: "+Alltrim(ZAS->ZAS_DESC)+" ESTORNADA!"
			SomOk()
		EndIf
	EndDo
	//Atualiza a Grid Principal
	If nQtdCx > 0
		GrTrbZax()
		oBrowse1:Refresh()
		oBrowse1:DrawSelect()
		oDlg:Refresh()
	EndIf
Return

//Valida a caixa lida
Static Function ValidaCaixa(cCaixa, oDl, _cBat)
	Local cGrpMoi := getMv('SI_GRPMOI')
	Local cGrupo  := ""

	If Empty(cCaixa)
		If !Empty(oDl)
			oDl:End()
		EndIf
		Return .T.
	EndIf

	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	If !ZAS->(MsSeek(FWxFilial('ZAS')+cCaixa))
		VldCxAviso("Caixa Inexistente - "+cCaixa+"!", oDl)
		Return .F.
	Else
		If !empty(ZAS->ZAS_DATAS) .or. !empty(ZAS->ZAS_HORAS)
			VldCxAviso("Caixa fora de estoque - "+cCaixa+"!", oDl)
			Return .F.
		EndIf

		/*If empty(ZAS->ZAS_DTRMP)
			VldCxAviso("Não foi feito recebimento da MP - "+cCaixa+"", oDl)
			Return .F.
		EndIf*/

		If !empty(ZAS->ZAS_DTBLOQ)
			VldCxAviso("Caixa bloqueada para consumo. Somente com autorização do PCP - "+cCaixa+"!", oDl)
			Return .F.
		EndIf

		//***ver*** código da caixa como código de produto?
		cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+cCaixa,1)
		If (cGrupo $ cGrpMoi)
			VldCxAviso("Erro, produto pertence ao grupo de moída - "+cCaixa+"!", oDl)
			Return .F.
		EndIf
		//valida produto alternativo
		if len(alltrim(ZAX->ZAX_CODMP)) > 4
			ZAX->(DbSetOrder(1))
			ZAX->(dbGoTop())
			If ZAX->(MsSeek(FWxFilial('ZAX') + _cBat))
				if !u_Obit08(ZAX->ZAX_CODMP, ZAS->ZAS_COD)
					VldCxAviso("Erro, não há relação do produto lido "+ALLTRIM(ZAS->ZAS_COD)+" com o produto da batelada "+ALLTRIM(ZAX->ZAX_CODMP)+"!", oDl)
					Return .F.
				endif
			endif
		endif

		lProduz := .T.
		If !Empty(oDl)
			oDl:End()
		EndIf
	EndIf
Return .T.

Static Function VldCxAviso(sMensagem, oDl)
	If Empty(oDl)
		Aviso("Valida Caixa", sMensagem,,1,,,,.F.,1000)
	Else
		oTSOk:SetText("")
		oTSAvs:SetText(sMensagem)
		oDl:Refresh()
	EndIf
	SomError()
	cCaixa := Space(11)
Return

//Valida a pallet lido
Static Function ValidaPallet(cPallet)
	ZAS->(dbSetOrder(6))
	ZAS->(dbGoTop())
	If !Empty(cPallet) .AND. !ZAS->(MsSeek(FWxFilial('ZAS')+cPallet))
		//Aviso("Valida Pallet", "Pallet Inexistente!",,1,,,,.F.,1000)
		oTSAvs:SetText("Pallet Inexistente - "+cPallet+"!")
		oDl:Refresh()
		SomError()
		cPallet := ""
		Return .F.
	EndIf

//****ver demais validações
Return .T.

//Valida estorno caixa
Static Function ValidaEstorno(cBatel, cCaixa, oDl)
	Local cGrpMoi := getMv('SI_GRPMOI')
	Local cGrupo  := ""

	If Empty(cCaixa)
		If !Empty(oDl)
			oDl:End()
		EndIf
		Return .T.
	EndIf

	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	If !ZAS->(MsSeek(FWxFilial('ZAS')+cCaixa))
		VldEstAviso("Caixa Inexistente!", oDl)
		Return .F.
	Else
		If empty(ZAS->ZAS_DATAS) .or. empty(ZAS->ZAS_HORAS)
			VldEstAviso("Caixa já se encontra em estoque!", oDl)
			Return .F.
		EndIf

		/*If empty(ZAS->ZAS_DTRMP)
			VldEstAviso("Não foi feito recebimento da MP!", oDl)
			Return .F.
		EndIf*/

		//***ver*** código da caixa como código de produto?
		cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+cCaixa,1)
		If (cGrupo $ cGrpMoi)
			VldEstAviso("Erro, produto pertence ao grupo de moída!", oDl)
			Return .F.
		EndIf

		If !alltrim(ZAS->ZAS_DTPROD) == alltrim(ZAX->ZAX_DTPROD)
			VldEstAviso("Data da MP diverge da batelada!", oDl)
			Return .F.
		EndIf

		If !alltrim(cBatel) == alltrim(ZAS->ZAS_BATEL)
			VldEstAviso("Caixa não pertence a batelada!", oDl)
			Return .F.
		EndIf

		//***ver essa validacao
		//If !alltrim(ZAS->ZAS_COD) == alltrim(ZAX->ZAX_CODMP)
		//	VldEstAviso("Código da MP diverge da batelada!", oDl)
		//	Return .F.
		//EndIf

		lEstorna := .T.
		If !Empty(oDl)
			oDl:End()
		EndIf
	EndIf
Return .T.

Static Function VldEstAviso(sMensagem, oDl)
	If Empty(oDl)
		Aviso("Valida Estorno", sMensagem,,1,,,,.F.,1000)
	Else
		oTSOk:SetText("")
		oTSAvs:SetText(sMensagem)
		oDl:Refresh()
	EndIf
	SomError()
	cCaixa := Space(11)
Return

//Busta peso consumido da batelada
Static Function BuscaPeso(cBatelada)
	Local nPeso := 0
	ZAX->(DbSetOrder(1))
	If ZAX->(MsSeek(FWxfilial('ZAX') + cBatelada))
		nPeso := ZAX->ZAX_QTDMPC
	EndIf
Return nPeso

//Produzir a caixa
Static Function ProduzCaixa(cBatelada, cCaixa, nPeso)
	//atualiza a caixa
	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	If ZAS->(MsSeek(FWxFilial('ZAS')+cCaixa))
		Reclock('ZAS',.F.)
		ZAS->ZAS_DATAS  := date()
		ZAS->ZAS_HORAS  := time()
		ZAS->ZAS_BATEL  := cBatelada
		MsUnlock()

		//incrementa a quantidade de peso na batelada
		ZAX->(DbSetOrder(1))
		ZAX->(dbGoTop())
		If ZAX->(MsSeek(FWxFilial('ZAX') + cBatelada))
			Reclock('ZAX',.F.)
			ZAX->ZAX_QTDMPC += nPeso
			If ZAX->ZAX_QTDMPC <> 0 .and. ZAX->ZAX_QTDMPC < ZAX->ZAX_QTDMP
				ZAX->ZAX_STATUS := 'R'
			ElseIf ZAX->ZAX_QTDMPC >= ZAX->ZAX_QTDMP
				ZAX->ZAX_STATUS := 'E'
			EndIf
			MsUnlock()
		EndIf
		GrvHistCaxa(cCaixa, "Produção de Caixa")
	EndIf
Return

//Estorna a caixa
Static Function EstornaCaixa(cBatelada, cCaixa, nPeso)
	//atualiza a caixa
	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	If ZAS->(MsSeek(FWxFilial('ZAS')+cCaixa))
		Reclock('ZAS',.F.)
		ZAS->ZAS_DATAS  := stod('')
		ZAS->ZAS_HORAS  := ''
		ZAS->ZAS_BATEL  := ''
		//retira a caixa do pallet
		ZAS->ZAS_PALLET := ''
		MsUnlock()

		//incrementa a quantidade de peso na batelada
		ZAX->(DbSetOrder(1))
		ZAX->(dbGoTop())
		If ZAX->(MsSeek(FWxFilial('ZAX') + cBatelada))
			Reclock('ZAX',.F.)
			ZAX->ZAX_QTDMPC -= nPeso
			If ZAX->ZAX_QTDMPC <> 0 .and. ZAX->ZAX_QTDMPC < ZAX->ZAX_QTDMP
				ZAX->ZAX_STATUS := 'R'
			EndIf
			MsUnlock()
		EndIf
		GrvHistCaxa(cCaixa, "Estorno de Caixa")
	EndIf
Return

//Gera arquivo com detalhes da batelada
Static Function GrTrbZas(cBatelada)
	Local cQuery
	Local nQtdCaix2 := 0.00
	Local nQtdPeso2 := 0.00

	cQuery := " SELECT ZAS_CONTRO AS CONTRO, ZAS_COD AS COD, ZAS_DESC AS DESCRI, ZAS_COD3 AS COD3,"
	cQuery += " ZAS_TIPO AS TIPO, ZAS_TERC AS TERC,  ZAS_PESOL AS PESO, ZAS_DTABAT AS DTABAT, "
	cQuery += " (dateadd(day, ZAS_VALID, CONVERT(DATE, ZAS_DTABAT))) AS DATAVAL, ZAS_PALLET AS PALLET, ZAS_LOCALI AS LOCALIZ, ZAS_PREDES AS PREDES "
	cQuery += " FROM " + RetSQLTab('ZAS') + " WHERE " + RetSQLFil('ZAS') + " AND  ZAS_BATEL = '" + cBatelada + "'"
	cQuery += "   AND " + RetSQLDel('ZAS')
	cQuery += " ORDER BY R_E_C_N_O_ DESC "//ZAS_DTABAT, ZAS_DESC, ZAS_COD DESC"
	cQuery := ChangeQuery(cQuery)

	If Select("TRBZAS") != 0
		TRBZAS->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TRBZAS"

	aBrowse2 := {}

	While TRBZAS->(!Eof())
		aadd(aBrowse2,{TRBZAS->CONTRO,;
			TRBZAS->COD,;
			PADR(ALLTRIM(TRBZAS->DESCRI),50," "),;
			TRBZAS->COD3,;
			dtoc(stod(TRBZAS->DTABAT)),;
			TRBZAS->DATAVAL,;
			PADL(transform(TRBZAS->PESO,"@E 999.999"),8," "),;
			TRBZAS->PALLET,;
			transform(TRBZAS->LOCALIZ,"@R !!.!!.!!.!!.!!"),;
			GetAdvFval('SZ2','Z2_DATAABT',FWxFilial('SZ2') + TRBZAS->PREDES,2)})

		nQtdCaix2 ++
		nQtdPeso2 += TRBZAS->PESO

		TRBZAS->(DbSkip())
	EndDo

	If len(aBrowse2) == 0
		Return .F.
	EndIf

	// Seta vetor para a browse
	oBrowse2:SetArray(aBrowse2)

	// Monta a linha a ser exibina no Browse
	oBrowse2:bLine := {||{aBrowse2[oBrowse2:nAt,01],aBrowse2[oBrowse2:nAt,02],;
		aBrowse2[oBrowse2:nAt,03],aBrowse2[oBrowse2:nAT,04],;
		aBrowse2[oBrowse2:nAt,05],aBrowse2[oBrowse2:nAT,06],;
		aBrowse2[oBrowse2:nAT,07],aBrowse2[oBrowse2:nAT,08],;
		aBrowse2[oBrowse2:nAT,09],aBrowse2[oBrowse2:nAT,10]}}

	oSayTotC2:SetText(oTotQ2 + Transform(nQtdCaix2,'@E 999,999'))
	oSaytotP2:SetText(oTotP2 + Transform(nQtdPeso2,'@E 999,999,999.99'))

Return .T.

//Segunda tela
//Para exibição do estoque detalhado
//por cada caixa de produto
Static Function DetalhesBatelada(cBatelada)
	Local aHeader2  := {'Codigo','Produto','Descriçao   ','Cod. Terc.','Data Prod.','Data Valid.','Peso','Pallet','Localização','Data Abate'}
	Local aLargCol2 := {  40    ,   30    ,  50         ,    30      ,  30        ,    30       , 30   ,   40    ,     40    ,      30     }
	Private aBrowse2  := {}

	Private oTotQ2  := 'Total de Caixas: '
	Private oTotP2  := 'Total de Peso Liquido: '

	DEFINE DIALOG oDlg2 TITLE "Controle de Estoque Industria Porcionados - Detalhamento Produto " + cBatelada FROM 020,50 To 600,1200 PIXEL

	// Cria Browse
	oBrowse2 := TCBrowse():New(003,003,560,270,,aHeader2,aLargCol2,oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.F.)

	oSayTotC2 :=    tSay():New(280, 030,{||oTotQ2},oDlg2,,oFont,,,,.T.,,,200,30)
	oSayTotP2 :=    tSay():New(280, 130,{||oTotP2},oDlg2,,oFont,,,,.T.,,,200,30)
	oBtn1     := tButton():New(275, 480, "Sair"   ,oDlg2,{|| oDlg2:end()   },040,015,,,.F.,.T.,.F.,,.F.,,,.F. )

	If !GrTrbZas(cBatelada)
		FWAlertError("Não há dados para o batelada "+cBatelada, "Detalhes")
		Return
	EndIf

	ACTIVATE DIALOG oDlg2 CENTERED

Return

//Retorno das cores da grid
Static Function RetCor(cStatus)
	Local ret
	If !Alltrim(cStatus) == "E"
		ret := LoadBitmap(GetResources(),'br_verde')
		//ElseIf nCor == 2
		//	ret := LoadBitmap(GetResources(),'br_azul')
	Else
		ret := LoadBitmap(GetResources(),'br_vermelho')
	EndIf
Return ret

Static Function SomOk()
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)
Return

Static Function SomError()
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
Return

//Gravar o log da caixa
Static Function GrvHistCaxa(cCaixa, cMensagem)
	u_obit02(cCaixa, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, cMensagem, ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))
//Gravar o log da caixa
//...
//u_gjf31his('Encerramento de Pre-Carregamento com faltas')
//ver a gravação na tabela zlh

//sz8 ver -tabela que entra no estoque
Return



