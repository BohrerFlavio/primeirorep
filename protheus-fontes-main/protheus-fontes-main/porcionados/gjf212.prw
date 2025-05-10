#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF212  º Autor ³ Giuliano Forgiraini  º Data ³ 30/01/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de controle de estoque de matéria prima (tipo MP)    º±±
±±º          ³ e produto em processo (tipo PP)                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP porcionados                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    
User Function GJF212()
	Local _aArqTrb    := {} // inicializa o array do arquivo
	private aRotina   :={}
	Private lInverte  := .f.
	Private cMark     := GetMark()
	Private oMark
	Private _dDataProd:= ddatabase
	Private _nQtdEmpF := 0.00                                     //Quantidade de empenho faltante
	Private _nQtdEmpA := 0.00                                     //Quantidade de empenho atual
	Private _nPercQ   := round(ZAR->(ZAR_QTDPI/ZAR_QTDMP),2)     //Percentual de quebra MP X PP
	Private _cGrpMoi  := GetMV('SI_GRPMOI')
	Private _cGrupo   := ''

	DbSelectArea('SB1')
	_cGrupo := fBuscaCPO('SB1',1,xfilial('SB1')+ZAR->ZAR_COD,'B1_GRUPO')

	if _cGrupo $_cGrpMoi
		Help(" ",1,"PRODUTO",,"Tipo do PA impede esta operação!",4,1)
	else

		//Verifica se a OP em questão não está em algum lote ainda
		//if empty(ZAR->ZAR_LOTE)

		//Bloco para apurar a quantidade atual de empenho
		ZAS->(DbSetOrder(2))
		if ZAS->(DbSeek(xfilial('ZAS')+ZAR->ZAR_NUM))
			while ZAS->(!eof()) ;
					.and. ZAS->ZAS_FILIAL = xfilial('ZAS') ;
					.and. ZAS->ZAS_PREPOR = ZAR->ZAR_NUM
				_nQtdEmpA += iif(ZAS->ZAS_TIPO = 'PP',(ZAS->ZAS_PESOL/_nPercQ),ZAS->ZAS_PESOL)
				ZAS->(DbSkip())
			enddo
		endif

		aObjects := {}    //dimensao janelas
		aPosObj  := {}
		aInfo    := {}
		aSizeAut := MsAdvSize()

		AAdd( aObjects, { 315, 50, .T., .T. } )
		AAdd( aObjects, { 100, 100, .T., .T. } )
		aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )

		area := GetArea()

		cPerg1 := "GJF211"
		cPerg2 := "GJF212"

		If !Pergunte(cPerg2,.T.)
			RestArea( area )
			Return
		Endif

		GeraTMP()

		aCampos  := {}
		AADD(aCampos,{"ZAS_OK"      ,,"OK"         ,"@!" })
		AADD(aCampos,{"ZAS_CONTRO"  ,,"Codigo"  	 ,"@!" })
		AADD(aCampos,{"ZAS_COD"     ,,"Produto"    ,"@!" })
		AADD(aCampos,{"ZAS_DESC"	 ,,"Descricao"  ,"@!" })
		AADD(aCampos,{"ZAS_DATAP"   ,,"Data.Prod." ,"99/99/99" })
		AADD(aCampos,{"ZAS_VAL"     ,,"Validade"   ,"99/99/99" })
		AADD(aCampos,{"ZAS_PESOL"   ,,"Peso Liq."  ,"@E 999.99" })
		AADD(aCampos,{"ZAS_TIPO"    ,,"Tipo"       ,"@!" })
		AADD(aCampos,{"ZAS_PREPOR"  ,,"Prev.Porc." ,"@!" })
		AADD(aCampos,{"ZAS_PREEMB"  ,,"Prev.Des."  ,"@!" })

		oFont   := tFont():New("arial",,-12,,.t.,,,,)
		_oEmp1  := 'Quantidade empenhada(kg):
		_oEmp2  :=  iif(ZAR->ZAR_QTDMP >= _nQtdEmpA,Transform(_nQtdEmpA,'@E 999,999.99'),"")
		_oEmp3  :=  iif(ZAR->ZAR_QTDMP <  _nQtdEmpA,Transform(_nQtdEmpA,'@E 999,999.99'),"")
		_oEmp4  := 'Empenho necessário de MP(kg): ' + Transform(ZAR->ZAR_QTDMP,'@E 999,999.99')

		DEFINE MSDIALOG oDlg2 TITLE "Selecionar" From 9,0 To 380,1100 PIXEL

		oMark := MsSelect():New("TMP","ZAS_OK","",aCampos,@lInverte,@cMark,{15,5,155,540},,,,,)

		oMark:bMark := {| | Disp()}

		oBtn1 := TButton():New(160, 020, "Marcar/Desmarcar", oDlg2,{|| Selecionar()} ,60,020,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtn2 := TButton():New(160, 090, "Empenhar"        , oDlg2,{|| Empenhar()  } ,60,020,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtn3 := TButton():New(160, 200, "Sair"            , oDlg2,{|| oDlg2:end() } ,60,020,,,.F.,.T.,.F.,,.F.,,,.F. )
		oSayEmp1 :=  tSay():New(170, 300,{|| _oEmp1 },oDlg2,,oFont,,,,.T.,,,200,30)
		oSayEmp2 :=  tSay():New(170, 375,{|| _oEmp2 },oDlg2,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
		oSayEmp3 :=  tSay():New(170, 375,{|| _oEmp3 },oDlg2,,oFont,,,,.T.,CLR_HRED,CLR_HRED,200,30)
		oSayEmp4 :=  tSay():New(170, 420,{|| _oEmp4 },oDlg2,,oFont,,,,.T.,,,200,30)

		ACTIVATE MSDIALOG oDlg2 CENTERED

		Pergunte(cPerg1,.f.)

		If Select('TMP')<>0
			TMP->(dbCloseArea())
		Endif

		If Select('MAT')<>0
			MAT->(dbCloseArea())
		Endif

		//else
		//	Help(" ",1,"LOTE",,"Ordem de Produção já possui vínculo a um lote!",4,1)
		//endif

	endif
	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb)
Return .T.

//Função que marca a caixa de MP e 
//faz a atualização do valor de empenho
Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("ZAS_OK")
		TMP->ZAS_OK := iif(lInverte,"",cMark)
		CalcEmp(.t.)
	Else
		TMP->ZAS_OK := iif(lInverte,cMark,"")
		CalcEmp(.f.)
	Endif
	msunlock()

	oSayEmp2:SetText(iif(ZAR->ZAR_QTDMP >= _nQtdEmpA,Transform(_nQtdEmpA,'@E 999,999.99'),""))
	oSayEmp3:SetText(iif(ZAR->ZAR_QTDMP <  _nQtdEmpA,Transform(_nQtdEmpA,'@E 999,999.99'),""))

	oMark:oBrowse:Refresh()

Return()


//Função estática para calculo dinamico do empenho
Static Function CalcEmp(_x)
	if _x
		_nQtdEmpA += iif(TMP->ZAS_TIPO = 'PP',(TMP->ZAS_PESOL/_nPercQ),TMP->ZAS_PESOL)
	else
		_nQtdEmpA -= iif(TMP->ZAS_TIPO = 'PP',(TMP->ZAS_PESOL/_nPercQ),TMP->ZAS_PESOL)
	endif
return



Static Function Selecionar()
	TMP->(dbgotop())

	while TMP->(!eof())
		reclock('TMP',.f.)
		TMP->ZAS_OK := iif(empty(TMP->ZAS_OK),cMark,"")
		msunlock()

		If Marked("ZAS_OK")
			CalcEmp(.t.)
		Else
			CalcEmp(.f.)
		Endif

		TMP->(dbskip())
	enddo

	TMP->(dbgotop())

	oSayEmp2:SetText(iif(ZAR->ZAR_QTDMP >= _nQtdEmpA,Transform(_nQtdEmpA,'@E 999,999.99'),""))
	oSayEmp3:SetText(iif(ZAR->ZAR_QTDMP <  _nQtdEmpA,Transform(_nQtdEmpA,'@E 999,999.99'),""))

	oMark:oBrowse:Refresh()
return .t.


//Função para Gerar a Previsão de Produção
Static Function Empenhar()

	if ZAR->ZAR_EMP == 'S'
		TMP->(DbGoTop())

		While TMP->(!eof())

			ZAS->(DbSetOrder(1))
			if ZAS->(DbSeek(xfilial('ZAS')+TMP->ZAS_CONTRO))
				reclock('ZAS',.f.)
				ZAS->ZAS_PREPOR := iif(!empty(TMP->ZAS_OK),ZAR->ZAR_NUM,'')
				msunlock()

				u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, iif(!empty(ZAS->ZAS_PREPOR), "Empenho para PPP "+alltrim(ZAS->ZAS_PREPOR),"Cancelado Empenho PPP"), ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))
			
			endif

			TMP->(DbSkip())
		EndDo

		GeraTMP()

		oMark:oBrowse:Refresh()

	else
		Help(" ",1,"EMPENHO",,"OP Bloqueada para empenho/produção de OP!",4,1)
	endif

	oDlg2:end()

return

//Função responsável pela geração do arquivo de trabalho TMP
Static Function GeraTMP()

	cQuery := " SELECT *  FROM " + RetSQLTab('ZAS') + " WHERE " + RetSQLFil('ZAS') + " AND "
	cQuery += " ZAS_DATAS = ' ' AND ZAS_HORAS = ' ' AND "

	//Matéria-Prima alocada?
	if mv_par01 = 1
		cQuery += " ZAS_PREPOR = '" + ZAR->ZAR_NUM + "' AND ZAS_COD <> ' ' AND "
	elseif mv_par01 = 2
		cQuery += " ZAS_PREPOR = ' ' AND "
		cQuery += " (ZAS_COD = '" + ZAR->ZAR_CODMP + "'" + iif(!empty(ZAR->ZAR_CODMP2)," OR  ZAS_COD = '" + ZAR->ZAR_CODMP2 + "'","")
		cQuery += " OR ZAS_COD = '" + ZAR->ZAR_CODPI + "') AND "
	else
		cQuery += " (((ZAS_COD = '" + ZAR->ZAR_CODMP + "'" + iif(!empty(ZAR->ZAR_CODMP2)," OR  ZAS_COD = '" + ZAR->ZAR_CODMP2 + "'","")
		cQuery += " OR ZAS_COD = '" + ZAR->ZAR_CODPI + "') AND ZAS_PREPOR = '' ) OR (ZAS_PREPOR = '" + ZAR->ZAR_NUM + "')) AND "
	endif

	//Tipo de Matéria-Prima?
	if mv_par02 = 1
		cQuery += " ZAS_TIPO = 'MP' AND "
	elseif mv_par02 = 2
		cQuery += " ZAS_TIPO = 'PP' AND "
	endif

	//Procedencia
	if mv_par03 = 1
		cQuery += " ZAS_TIPO = 'MP' AND ZAS_TERC = 'N' AND "
	elseif mv_par03 = 2
		cQuery += " ZAS_TIPO = 'MP' AND ZAS_TERC = 'S' AND "
	endif

	cQuery += iif(mv_par04 <> 0," ZAS_DTPROD >= '" + dtos(ddatabase - mv_par04) + "' AND ",'')

	cQuery += RetSqlDel('ZAS')
	cQuery += " ORDER BY ZAS_DTPROD "


	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("MAT") != 0
		MAT->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "MAT"

	MAT->(DbGoTop())

	DbSelectArea('ZAS')
	ZAS->(DbSetOrder(1))

	_aArqTrb    := {}
	//cArq  := CriaTrab( Nil, .F. )

	aStru := dbStruct()

	aadd(aStru,{"ZAS_OK"    , "C",  02, 0})
	aadd(aStru,{"ZAS_VAL"   , "D",  08, 0})
	aadd(aStru,{"ZAS_DATAP" , "D",  08, 0})

	//dbcreate(cArq,aStru)
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TMP", aStru, {"ZAS_FILIAL","ZAS_DTPROD"}, @_aArqTrb)

	If Select('TMP')<>0
		TMP->(dbCloseArea())
	Endif

	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )               //cria temp
	//Index On ZAS_FILIAL+dtos(ZAS_DTPROD) To (cArq)

	While MAT->(!eof())

		reclock('TMP',.t.)
		TMP->ZAS_VAL     := MAT->(stod(ZAS_DTPROD) + ZAS_VALID)
		TMP->ZAS_FILIAL  := cFilAnt
		TMP->ZAS_COD     := MAT->ZAS_COD
		TMP->ZAS_OK      := iif(!empty(MAT->ZAS_PREPOR),cMark,'')
		TMP->ZAS_CONTRO  := MAT->ZAS_CONTRO
		TMP->ZAS_DESC    := MAT->ZAS_DESC
		TMP->ZAS_PESOL   := MAT->ZAS_PESOL
		TMP->ZAS_TARA    := MAT->ZAS_TARA
		TMP->ZAS_PESOB   := MAT->ZAS_PESOB
		TMP->ZAS_PREPOR  := MAT->ZAS_PREPOR
		TMP->ZAS_TIPO    := MAT->ZAS_TIPO
		TMP->ZAS_PREEMB  := MAT->ZAS_PREEMB
		TMP->ZAS_DATAP   := stod(MAT->ZAS_DTPROD)
		msunlock()

		MAT->(DbSkip())
	enddo

	dbSelectarea('TMP')
	IndRegua("TMP",cArq,"ZAS_FILIAL+dtos(ZAS_VAL)",,,"Selecionando Registros...") //ordena
	TMP->(dbGotop())

return

