#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF146    º Autor ³ Giuliano Forgiariniº Data ³  21/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta de estoque de produto para localização física     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Camaras/PCP                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF146()

	Local _nCont     := 0

	Private cPerg2 := "GJF144"
	Private _cLocal    := ''
	Private _Produto   := space(07)
	Private _Mens1     := ''
	Private aCampos    := {}
	Private aCampos2   := {}
	Private cArq
	Private cArq2
	Private cArq3
	Private aStru      := {}
	Private aStru2     := {}
	Private cpo13

	if !Pergunte(cPerg2,.t.)
		return
	endif

	_cLocal    := mv_par01

	Montabrow()

	DEFINE DIALOG oDlg2 TITLE "Consulta de Estoque em Localização Física de PA" FROM 180,180 TO 800,800 PIXEL

	@001,002 say 'Pallets:'
	@007,002 say 'Caixas:'
	@013,002 say 'Caixas Sortidas:'

	@020,002 say 'Leitura:' //@013,019 say 'Leitura:'
	@021,002  MSGET cpo13 VAR _Produto SIZE 50,11 VALID Leitura() F3 'SB1' OF oDlg2

	@ 025,010 To 080,300 Browse "TMP6" fields aCampos object oBrow6
	oBrow6:oBrowse:bldBlClick :=  {|| ClcBrow()}

	@ 100,010 To 160,300 Browse "TMP7" fields aCampos2 object oBrow7

	@ 180,010 To 257,300 Browse "TMP8" fields aCampos2 object oBrow5

	oFont  := tFont():New("courier new",,-20,,.t.,,,,)
	oSayCons1 := tSay():New(270,100,{|| _Mens1 },oDlg2,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,50)

	@290,250 BUTTON btn02 PROMPT "Fechar" OF oDlg2 PIXEL ACTION oDlg2:end()

	ACTIVATE DIALOG oDlg2 CENTERED

	If Select("TMP6") != 0
		TMP6->(DbCloseArea())
	endif
	If Select("TMP7") != 0
		TMP7->(DbCloseArea())
	endif
	If Select("TMP8") != 0
		TMP8->(DbCloseArea())
	endif

Return


//Leitura das caixas/pallets
Static Function Leitura()

	if empty(_Produto)
		return .t.
	endif

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())
	If !SB1->(MsSeek(FWxfilial('SB1')+_Produto))
		Alert('Produto não encontrado!')
		return .f.
	else
		If SB1->B1_MSBLQL = '1'
			alert('Produto bloqueado!')
			return .f.
		endif
		If !(SB1->B1_TIPO $ 'PA/MP')
			alert('Produto inválido!')
			return .f.
		endif
		If !(SB1->B1_SEGUM $ 'CX/SC')
			alert('Produto não é embalado em caixas!')
			return .f.
		endif
	Endif

	_cMens1 := SB1->B1_DESC
	oSayCons1:SetText(_cMens1)

	oDlg2:refresh()

	AtuBrow(_Produto)

Return .t.


//Função para a montagem dos dois browses
Static Function montabrow()

	//cArq  := CRIATrab( Nil, .F. )
	//cArq2 := CRIATrab( Nil, .F. )
	//cArq3 := CRIATrab( Nil, .F. )

	_aArqTrb := {}
	_aArqTrb2 := {}
	_aArqTrb3 := {}

	aadd(aCampos,{"NUMERO" ,"Pallet"    ,""})
	aadd(aCampos,{"CXS"  ,"Qtd.Cxs."  ,""})
	aadd(aCampos,{"COD"    ,"Produto"   ,""})
	aadd(aCampos,{"DESCRI" ,"Descricao" ,""})
	aadd(aCampos,{"DATAP"  ,"Data"      ,""})
	aadd(aCampos,{"RUA"    ,"Rua"       ,""})
	aadd(aCampos,{"PREDIO" ,"Predio"    ,""})
	aadd(aCampos,{"ANDAR"  ,"Andar"     ,""})
	aadd(aCampos,{"APTO"   ,"Apto"      ,""})
	aadd(aCampos,{"LOCALIZ","Localiz."  ,""})

	aadd(aCampos2,{"CONTROL" ,"Caixa"     ,""})
	aadd(aCampos2,{"COD"     ,"Produto"   ,""})
	aadd(aCampos2,{"DESCRI"  ,"Descricao" ,""})
	aadd(aCampos2,{"DATAP"   ,"Dt. Prod." ,""})
	aadd(aCampos2,{"DATAV"   ,"Dt. Val."  ,""})
	aadd(aCampos2,{"RUA"    ,"Rua"       ,""})
	aadd(aCampos2,{"PREDIO" ,"Predio"    ,""})
	aadd(aCampos2,{"ANDAR"  ,"Andar"     ,""})
	aadd(aCampos2,{"APTO","Apto"         ,""})
	aadd(aCampos2,{"LOCALIZ","Localiz."  ,""})

	aadd(aStru,{"NUMERO"   , "C",  10, 0,   "@!"                 , 'Pallet   '})
	aadd(aStru,{"CXS"      , "N",  02, 0,   "@E99"               , 'Qtd.Cxs. '})
	aadd(aStru,{"COD"      , "C",  06, 0,   "@!"                 , 'Produto  '})
	aadd(aStru,{"DESCRI"   , "C",  30, 0,   "@!"                 , 'Descricao'})
	aadd(aStru,{"DATAP"    , "D",  08, 0,   "99/99/99"           , 'Data Pr. '})
	aadd(aStru,{"RUA"      , "C",  02, 0,   "@!"                 , 'Rua'      })
	aadd(aStru,{"PREDIO"   , "C",  02, 0,   "@!"                 , 'Predio'   })
	aadd(aStru,{"ANDAR"    , "C",  02, 0,   "@!"                 , 'Andar'    })
	aadd(aStru,{"APTO"     , "C",  02, 0,   "@!"                 , 'Apto.    '})
	aadd(aStru,{"LOCALIZ"  , "C",  10, 0,   "@R !!.!!.!!.!!.!!"  , 'Localiz. '})

	aadd(aStru2,{"CONTROL" , "C",  10, 0,   "@!"                 ,'Caixa     '})
	aadd(aStru2,{"COD"     , "C",  06, 0,   "@!"                 ,'Produto   '})
	aadd(aStru2,{"DESCRI"  , "C",  30, 0,   "@!"                 ,'Descricao '})
	aadd(aStru2,{"DATAP"   , "D",  08, 0,   "99/99/99"           ,'Dt. Prod. '})
	aadd(aStru2,{"DATAV"   , "D",  08, 0,   "99/99/99"           ,'Dt. Val.  '})
	aadd(aStru2,{"RUA"      , "C",  02, 0,   "@!"                , 'Rua'     })
	aadd(aStru2,{"PREDIO"   , "C",  02, 0,   "@!"                , 'Predio  '})
	aadd(aStru2,{"ANDAR"    , "C",  02, 0,   "@!"                , 'Andar   '})
	aadd(aStru2,{"APTO"     , "C",  02, 0,   "@!"                , 'Apto.   '})
	aadd(aStru2,{"LOCALIZ"  , "C",  10, 0,   "@R !!.!!.!!.!!.!!" , 'Localiz.'})

	//dbcreate(cArq,aStru)
	//dbcreate(cArq2,aStru2)
	//dbcreate(cArq3,aStru2)
	//dbUseArea( .T.,,cArq,"TMP6", .F. , .F. )
	//dbUseArea( .T.,,cArq2,"TMP7", .F. , .F. )
	//dbUseArea( .T.,,cArq3,"TMP8", .F. , .F. )

	If Select('TMP6')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP6->(dbCloseArea())
		u_arqtrb("FECHATODOS",,,, @_aArqTrb)
	Endif
	U_ArqTrb("CRIA", "TMP6", aStru, {}, @_aArqTrb)

	If Select('TMP7')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP7->(dbCloseArea())
		u_arqtrb("FECHATODOS",,,, @_aArqTrb2)
	Endif
	U_ArqTrb("CRIA", "TMP7", aStru2, {}, @_aArqTrb2)

	If Select('TMP8')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP8->(dbCloseArea())
		u_arqtrb("FECHATODOS",,,, @_aArqTrb3)
	Endif
	U_ArqTrb("CRIA", "TMP8", aStru2, {}, @_aArqTrb3)

	TMP6->(DbGotop())
	TMP7->(DbGotop())
	TMP8->(DbGotop())

Return


//Limpa e habilita o browse.
//Função desenvolvida para a mudança
//de foco da tree
Static Function HabBrow(_opc)

	_aArqTrb := {}
	_aArqTrb2 := {}
	_aArqTrb3 := {}

	if _opc = 1
		/*If Select("TMP6") != 0
			TMP6->(DbCloseArea())
			dbcreate(cArq,aStru)
			dbUseArea( .T.,,cArq,"TMP6", .F. , .F. )
			TMP6->(DbGotop())
			oBrow6:oBrowse:refresh()
			oDlg2:refresh()
		Endif*/

		If Select('TMP6')<>0                               		// Se um tmp com alias TMP existir, fecha-o
			TMP6->(dbCloseArea())
			u_arqtrb("FECHATODOS",,,, @_aArqTrb)

			U_ArqTrb("CRIA", "TMP6", aStru, {}, @_aArqTrb)
			TMP6->(DbGotop())
			oBrow6:oBrowse:refresh()
			oDlg2:refresh()
		Endif

		/*If Select("TMP7") != 0
			TMP7->(DbCloseArea())
			dbcreate(cArq2,aStru2)
			dbUseArea( .T.,,cArq2,"TMP7", .F. , .F. )
			TMP7->(DbGotop())
			oBrow7:oBrowse:refresh()
			oDlg2:refresh()
		Endif*/

		If Select('TMP7')<>0                               		// Se um tmp com alias TMP existir, fecha-o
			TMP7->(dbCloseArea())
			u_arqtrb("FECHATODOS",,,, @_aArqTrb2)

			U_ArqTrb("CRIA", "TMP7", aStru2, {}, @_aArqTrb2)
			TMP7->(DbGotop())
			oBrow7:oBrowse:refresh()
			oDlg2:refresh()
		Endif

		/*If Select("TMP8") != 0
			TMP8->(DbCloseArea())
			dbcreate(cArq3,aStru2)
			dbUseArea( .T.,,cArq3,"TMP8", .F. , .F. )
			TMP8->(DbGotop())
			oBrow5:oBrowse:refresh()
			oDlg2:refresh()
		Endif*/

		If Select('TMP8')<>0                               		// Se um tmp com alias TMP existir, fecha-o
			TMP8->(dbCloseArea())
			u_arqtrb("FECHATODOS",,,, @_aArqTrb3)

			U_ArqTrb("CRIA", "TMP8", aStru2, {}, @_aArqTrb3)
			TMP8->(DbGotop())
			oBrow5:oBrowse:refresh()
			oDlg2:refresh()
		Endif

	elseif _opc = 2

		/*If Select("TMP7") != 0
			TMP7->(DbCloseArea())
			dbcreate(cArq2,aStru2)
			dbUseArea( .T.,,cArq2,"TMP7", .F. , .F. )
			TMP7->(DbGotop())
			oBrow7:oBrowse:refresh()
			oDlg2:refresh()
		Endif*/

		If Select('TMP7')<>0                               		// Se um tmp com alias TMP existir, fecha-o
			TMP7->(dbCloseArea())
			u_arqtrb("FECHATODOS",,,, @_aArqTrb2)

			U_ArqTrb("CRIA", "TMP7", aStru2, {}, @_aArqTrb2)
			TMP7->(DbGotop())
			oBrow7:oBrowse:refresh()
			oDlg2:refresh()
		Endif

	endif

return

//Função para atualizar o browse
Static Function AtuBrow(_Prod)

	HabBrow(1)

	SZP->(DbSetOrder(4))
	SZP->(DbGoTop())
	if SZP->(MsSeek(FWxfilial('SZP') + alltrim(_Prod)))
		While SZP->(!eof()) .and. SZP->ZP_FILIAL = FWxfilial('SZP') .and. SZP->ZP_PRODUTO = alltrim(_Prod)
			DbSelectArea('TMP6')
			reclock('TMP6',.t.)
			TMP6->NUMERO  := SZP->ZP_COD
			TMP6->COD     := SZP->ZP_PRODUTO
			TMP6->CXS     := qtdCaixas(SZP->ZP_COD)
			TMP6->DESCRI  := SB1->B1_DESC
			TMP6->DATAP   := SZP->ZP_DATA
			TMP6->RUA     := substr(SZP->ZP_LOCALIZ,3,2)
			TMP6->PREDIO  := substr(SZP->ZP_LOCALIZ,5,2)
			TMP6->ANDAR   := substr(SZP->ZP_LOCALIZ,7,2)
			TMP6->APTO    := substr(SZP->ZP_LOCALIZ,9,2)
			TMP6->LOCALIZ := SZP->ZP_LOCALIZ
			msunlock()

			SZP->(DbSkip())
		enddo
	endif

	TMP6->(DbGoTop())

	if SB1->B1_TIPO == 'PA'

		SZ8->(DbSetOrder(21))
		SZ8->(DbGoTop())
		if SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + TMP6->(padr(COD,14,'') + LOCALIZ)))
			While SZ8->(!eof()) .and. SZ8->Z8_FILIAL  = FWxfilial('SZ8') .and.;
			SZ8->Z8_FIL     = cFilAnt .and.;
			SZ8->Z8_COD     =  TMP6->(padr(COD,14,'')) .and. ;
			SZ8->Z8_LOCALIZ =  TMP6->LOCALIZ .AND. !empty(TMP6->LOCALIZ)

				DbSelectArea('TMP7')
				reclock('TMP7',.t.)
				TMP7->CONTROL := SZ8->Z8_CONTROL
				TMP7->COD     := alltrim(SZ8->Z8_COD)
				TMP7->DESCRI  := alltrim(SZ8->Z8_DESCRI)
				TMP7->DATAP   := SZ8->Z8_DATAP
				TMP7->DATAV   := SZ8->Z8_DATAVAL
				TMP7->RUA     := substr(SZ8->Z8_LOCALIZ,3,2)
				TMP7->PREDIO  := substr(SZ8->Z8_LOCALIZ,5,2)
				TMP7->ANDAR   := substr(SZ8->Z8_LOCALIZ,7,2)
				TMP7->APTO    := substr(SZ8->Z8_LOCALIZ,9,2)
				TMP7->LOCALIZ := SZ8->Z8_LOCALIZ
				msunlock()
				SZ8->(DbSkip())
			enddo
		endif

		_cQuery := " SELECT Z8_CONTROL, Z8_COD, Z8_DESCRI, Z8_DATAP, Z8_LOCALIZ, Z8_DATAVAL "
		_cQuery += " FROM " + RetSQLTab('SZ8') + " WHERE " + RetSQLFil('SZ8')
		_cQuery += " AND Z8_FIL = '" + cFilAnt + "'  AND SUBSTRING(Z8_LOCALIZ,1,2) = '" + _cLocal + "'"
		_cQuery += " AND Z8_DATAS = '' AND Z8_HORAS = '' AND Z8_PRECAR = '' AND Z8_PREPED = '' AND Z8_ITEM = '' "
		_cQuery += " AND Z8_PALLET = '' AND Z8_COD = '" + alltrim(_Prod) + "' AND " + RetSQLDel('SZ8')
		_cQuery += " ORDER BY Z8_CONTROL "

	elseif SB1->B1_TIPO == 'MP'


		ZAS->(DbSetOrder(8))
		ZAS->(DbGoTop())
		if ZAS->(MsSeek(FWxfilial('ZAS')  + TMP6->(padr(COD,14,'') + LOCALIZ)))
			While ZAS->(!eof()) .and. ZAS->ZAS_FILIAL  = FWxfilial('ZAS') .and.;
			ZAS->ZAS_COD     =  TMP6->(padr(COD,14,'')) .and. ;
			ZAS->ZAS_LOCALI =  TMP6->LOCALIZ .AND. !empty(TMP6->LOCALIZ)

				DbSelectArea('TMP7')
				reclock('TMP7',.t.)
				TMP7->CONTROL := ZAS->ZAS_CONTRO
				TMP7->COD     := alltrim(ZAS->ZAS_COD)
				TMP7->DESCRI  := alltrim(ZAS->ZAS_DESC)
				TMP7->DATAP   := ZAS->ZAS_DTPROD
				TMP7->DATAV   := (ZAS->ZAS_DTPROD + ZAS->ZAS_VALID)
				TMP7->RUA     := substr(ZAS->ZAS_LOCALI,3,2)
				TMP7->PREDIO  := substr(ZAS->ZAS_LOCALI,5,2)
				TMP7->ANDAR   := substr(ZAS->ZAS_LOCALI,7,2)
				TMP7->APTO    := substr(ZAS->ZAS_LOCALI,9,2)
				TMP7->LOCALIZ := ZAS->ZAS_LOCALI
				msunlock()
				ZAS->(DbSkip())
			enddo
		endif

		_cQuery := " SELECT ZAS_CONTRO, ZAS_COD, ZAS_DESC, ZAS_DTPROD, ZAS_LOCALI, ZAS_VALID "
		_cQuery += " FROM " + RetSQLTab('ZAS') + " WHERE " + RetSQLFil('ZAS')
		_cQuery += " AND SUBSTRING(ZAS_LOCALI,1,2) = '" + _cLocal + "'"
		_cQuery += " AND ZAS_DATAS = '' AND ZAS_HORAS = '' "
		_cQuery += " AND ZAS_PALLET = '' AND ZAS_COD = '" + alltrim(_Prod) + "' AND " + RetSQLDel('ZAS')
		_cQuery += " ORDER BY ZAS_CONTRO "

	endif

	TMP7->(DbGoTop())

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TRB")<>0
		TRB->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TRB"

	While TRB->(!eof())
		DbSelectArea('TMP8')
		reclock('TMP8',.t.)
		TMP8->CONTROL := iif(SB1->B1_TIPO == 'PA',TRB->Z8_CONTROL,TRB->ZAS_CONTRO)
		TMP8->COD     := alltrim(iif(SB1->B1_TIPO == 'PA',TRB->Z8_COD,TRB->ZAS_COD))
		TMP8->DESCRI  := alltrim(iif(SB1->B1_TIPO == 'PA',TRB->Z8_DESCRI,TRB->ZAS_DESC))
		TMP8->DATAP   := stod(iif(SB1->B1_TIPO == 'PA',TRB->Z8_DATAP,TRB->ZAS_DTPROD) )
		TMP8->DATAV   := stod(iif(SB1->B1_TIPO == 'PA',TRB->Z8_DATAVAL,(TRB->ZAS_DTPROD + TRB->ZAS_VALID)) )
		TMP8->RUA     := substr(iif(SB1->B1_TIPO == 'PA',TRB->Z8_LOCALIZ,TRB->ZAS_LOCALI),3,2)
		TMP8->PREDIO  := substr(iif(SB1->B1_TIPO == 'PA',TRB->Z8_LOCALIZ,TRB->ZAS_LOCALI),5,2)
		TMP8->ANDAR   := substr(iif(SB1->B1_TIPO == 'PA',TRB->Z8_LOCALIZ,TRB->ZAS_LOCALI),7,2)
		TMP8->APTO    := substr(iif(SB1->B1_TIPO == 'PA',TRB->Z8_LOCALIZ,TRB->ZAS_LOCALI),9,2)
		TMP8->LOCALIZ := iif(SB1->B1_TIPO == 'PA',TRB->Z8_LOCALIZ,TRB->ZAS_LOCALI)
		msunlock()
		TRB->(DbSkip())
	enddo

	TMP8->(DbGoTop())
	oBrow6:oBrowse:refresh()
	oBrow7:oBrowse:refresh()
	oBrow5:oBrowse:refresh()

return


Static Function qtdCaixas(_cCodPal)

	Local _nTotCx := 0

	if SB1->B1_TIPO == 'PA'

		SZ8->(DbSetOrder(19))
		SZ8->(DbGoTop())
		if SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + _cCodPal))
			While SZ8->(!eof()) .and. SZ8->Z8_FILIAL  = FWxfilial('SZ8') .and.;
			SZ8->Z8_FIL     = cFilAnt .and.;
			SZ8->Z8_PALLET  = _cCodPal

				_nTotCx++

				SZ8->(DbSkip())
			enddo
		endif

	elseif SB1->B1_TIPO == 'MP'


		ZAS->(DbSetOrder(6))
		ZAS->(DbGoTop())
		if ZAS->(MsSeek(FWxfilial('ZAS')  + _cCodPal))
			While ZAS->(!eof()) .and. ZAS->ZAS_FILIAL  = FWxfilial('ZAS') .and.;
			ZAS->ZAS_PALLET =  _cCodPal

				_nTotCx++

				ZAS->(DbSkip())
			enddo
		endif

	endif

return _nTotCx

//Função para atualizar o browse
Static Function ClcBrow()

	HabBrow(2)

	//Se for PA...
	if SB1->B1_TIPO == 'PA'

		SZ8->(DbSetOrder(21))
		SZ8->(DbGoTop())
		if SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + TMP6->(padr(COD,14,'') + LOCALIZ)))
			While SZ8->(!eof()) .and. SZ8->Z8_FILIAL  = FWxfilial('SZ8') .and.;
			SZ8->Z8_FIL     = cFilAnt .and.;
			SZ8->Z8_COD     =  TMP6->(padr(COD,14,'')) .and. ;
			SZ8->Z8_LOCALIZ =  TMP6->LOCALIZ

				if alltrim(TMP6->NUMERO) <> alltrim(SZ8->Z8_PALLET) .or. empty(TMP6->NUMERO)
					SZ8->(DbSkip())
					loop
				endif

				DbSelectArea('TMP7')
				reclock('TMP7',.t.)
				TMP7->CONTROL := SZ8->Z8_CONTROL
				TMP7->COD     := alltrim(SZ8->Z8_COD)
				TMP7->DESCRI  := alltrim(SZ8->Z8_DESCRI)
				TMP7->DATAP   := SZ8->Z8_DATAP
				TMP7->DATAV   := SZ8->Z8_DATAVAL
				TMP7->RUA     := substr(SZ8->Z8_LOCALIZ,3,2)
				TMP7->PREDIO  := substr(SZ8->Z8_LOCALIZ,5,2)
				TMP7->ANDAR   := substr(SZ8->Z8_LOCALIZ,7,2)
				TMP7->APTO    := substr(SZ8->Z8_LOCALIZ,9,2)
				TMP7->LOCALIZ := SZ8->Z8_LOCALIZ
				msunlock()
				SZ8->(DbSkip())
			enddo
		endif

		//Se for MP...
	elseif SB1->B1_TIPO == 'MP'

		ZAS->(DbSetOrder(8))
		ZAS->(DbGoTop())
		if ZAS->(MsSeek(FWxfilial('ZAS') + TMP6->(padr(COD,14,'') + LOCALIZ)))
			While ZAS->(!eof()) .and. ZAS->ZAS_FILIAL  = FWxfilial('ZAS') .and.;
			ZAS->ZAS_COD     =  TMP6->(padr(COD,14,'')) .and. ;
			ZAS->ZAS_LOCALI =  TMP6->LOCALIZ

				if alltrim(TMP6->NUMERO) <> alltrim(ZAS->ZAS_PALLET) .or. empty(TMP6->NUMERO)
					ZAS->(DbSkip())
					loop
				endif

				DbSelectArea('TMP7')
				reclock('TMP7',.t.)
				TMP7->CONTROL := ZAS->ZAS_CONTRO
				TMP7->COD     := alltrim(ZAS->ZAS_COD)
				TMP7->DESCRI  := alltrim(ZAS->ZAS_DESC)
				TMP7->DATAP   := ZAS->ZAS_DTPROD
				TMP7->DATAV   := (ZAS->ZAS_DTPROD + ZAS->ZAS_VALID)
				TMP7->RUA     := substr(ZAS->ZAS_LOCALI,3,2)
				TMP7->PREDIO  := substr(ZAS->ZAS_LOCALI,5,2)
				TMP7->ANDAR   := substr(ZAS->ZAS_LOCALI,7,2)
				TMP7->APTO    := substr(ZAS->ZAS_LOCALI,9,2)
				TMP7->LOCALIZ := ZAS->ZAS_LOCALI
				msunlock()
				ZAS->(DbSkip())
			enddo
		endif

	endif

	TMP7->(DbGoTop())

	oBrow6:oBrowse:refresh()
	oBrow7:oBrowse:refresh()

return
