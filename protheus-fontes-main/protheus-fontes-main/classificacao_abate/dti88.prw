#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"   
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI88  º Autor ³ Flávio Bohrer Flôres   º Data ³ 17/07/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³rotina de gerenciamento de Previsões de Produção 			  º±±
±±º          ³ By GJF241                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP Embalagem                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    
User Function DTI88()
	
	private aRotina   := {}
	Private lInverte  := .f.
	Private cMark     := GetMark()
	Private oMark
	Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)
	Private _aProcess := {}    	
	Private _cSay1    := 'Filtrar Grupos'
	Private _cSay2		:= 'Processos de Produção'
	Private cAliasTMP := nil
	Private _nCount   := 0
	Private  oTxtT		:= ''
	private oFont2    := tFont():New("courier new",,-18,,.t.,,,,)
	Private cPerg     := "DTI88"
	Private _cCombo   := ''
	Private _lDiverg  := .F.
	Private _cGrpPORC := GetMV('MV_GRPPORC')

	if !pergunte(cPerg,.t.)
		return
	endif

	aObjects := {}    //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	ProcReg()
	_cCombo := _aProcess[1]
	GeraTMP()

	aCampos  := {} 

	AADD(aCampos,{"ZU_OK"     ,, "OK","@!"})
	AADD(aCampos,{"ZU_NUM"    ,, "Previsão","@!"})
	AADD(aCampos,{"ZU_FECHADO",, "STATUS","@!"})
	AADD(aCampos,{"ZU_COD"    ,, "Codigo","@!"})
	AADD(aCampos,{"ZU_DESC"   ,, "Descricao","@E"})
	AADD(aCampos,{"Z2_DATAABT",, "Data Abate","99/99/99"})
	AADD(aCampos,{"ZU_QPCAIX" ,, "Qtd.Prev.Caixas","@E 999"})
	AADD(aCampos,{"ZU_QRCAIX" ,, "Qtd.Real.Prod","@E 9,999"})
	AADD(aCampos,{"ZU_DTEMB"  ,, "Data Produção/Embalagem","99/99/99"})
	AADD(aCampos,{"ZU_DATAP"  ,, "Data Real/Base","99/99/99"})
	AADD(aCampos,{"ZU_DTDEV"  ,, "Data Devolução","99/99/99"})
	AADD(aCampos,{"ZU_USUAR"  ,, "Usuário","@!"})
	AADD(aCampos,{"B1_GRUPO"  ,, "Grupo de Produtos","@!"})

	U_dti88ke('A','A')// Botão F5

	DEFINE MSDIALOG oDlg TITLE "Gerenciamento de Previsões de Prod. Embalagens" From 02,0 To 600,1280 PIXEL

	oMark := MsSelect():New("TMP","ZU_OK","",aCampos,@lInverte,@cMark,{05,1,250,643},,,,,)
	oMark:bMark := {| | Disp()}

	/*  Aqui trabalhar com filtros on-line*/
	_oSay1    := TSay():New(255,100, {|| _cSay1}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 080,020)  
	_oCombo   := TComboBox():New(265, 100, {|u| If(PCount() > 0, _cCombo:= u, _cCombo)}, _aProcess, 50, 20, oDlg,, {|| ComboSel()},,,,.T.,,,,,,,,,'_cCombo')
	oGrupoL1 := tGroup():New(262, 370, 295, 590,'MSG Retorno', oDlg,,, .t.)

	oSayTxtT  := tSay():New(275,380,{|| oTxtT	},oDlg,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)

	_oButton1 := TButton():New(255, 020, "Marcar/Desmarcar", oDlg,{|| Selecionar()	 } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oButton2 := TButton():New(275, 020, "Divergências", oDlg,{|| Diverg()	 } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oSay2    := TSay():New(255,180, {|| _cSay2}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 110,040)

	_oButton3 := TButton():New(265, 160, "Lib.Prev.Prod"   , oDlg,{|| U_d88lib2()  } ,50,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oButton4 := TButton():New(265, 220, "Block.Prev.Prod"   , oDlg,{|| U_d88blo()  } ,50,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oButton5 := TButton():New(275, 300, "Sair"             , oDlg,{|| oDlg:end()      } ,50,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	_oButton6 := TButton():New(250, 400,"Lib.Prod.Aut.", oDlg,{|| LibPA() },40,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oButton7 := TButton():New(250, 460, "Blk.Prod.Aut.", oDlg,{|| BlPA() 	},40,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oButton8 := TButton():New(250, 520, "Status.Prod.Aut.", oDlg,{|| StPA() 	},44,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oButton9 := TButton():New(252, 300, "Atu.Tela", oDlg,{|| u_dti88atu() 	},44,012,,,.F.,.T.,.F.,,.F.,,,.F. )

	/*if  AllTrim(UPPER(cUserName)) = UPPER("flavio")
		// Antes de usar ajustar o DTI41 para não imprimir etiquetas lá em baixo 
		_oButton2 := TButton():New(265, 592, "Etiq."   , oDlg,{|| u_DTI41()  } ,50,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	endif*/

	ACTIVATE MSDIALOG oDlg CENTERED

Return .T.


Static Function Disp()
	RecLock("TMP",.F.)
	If Marked("ZU_OK")
		TMP->ZU_OK := cMark
	Else     
		TMP->ZU_OK := ""
	Endif
	msunlock()

	oMark:oBrowse:Refresh()
Return


Static Function ComboSel()
	GeraTMP()
	oMark:oBrowse:Refresh()
	oDlg:refresh()
return


Static Function Diverg()
	_lDiverg := !_lDiverg
	GeraTMP()
	oMark:oBrowse:Refresh()
	oDlg:refresh()
return


Static Function Selecionar()
	TMP->(dbgotop())   
	while TMP->(!eof())
		reclock('TMP',.f.)
		TMP->ZU_OK := iif(empty(TMP->ZU_OK),cMark,"")
		msunlock()

		TMP->(dbskip())
	enddo

	TMP->(dbgotop())

	oMark:oBrowse:Refresh()
return .t.

//Função para processar registros
Static Function ProcReg()
	dData := mv_par01
	_aProcess := {}

	cAliasTMP := GetNextAlias()

	BeginSql Alias cAliasTMP
		//column  ZU_QPCAIX as numeric (4,0),ZU_QRCAIX as numeric (4,0)
		SELECT * FROM
		(SELECT ZU_NUM, ZU_COD, ZU_DESC, ZU_QPCAIX, ZU_QRCAIX, ZU_DATA, ZU_DTPROD, ZU_FECHADO, B1_COD, B1_GRUPO,
		CASE WHEN (SUBSTRING(ZU_USUAR, 1, 2) = 'S_' AND ZU_PREDES = '') THEN 'N' ELSE 'S' END AUTOM
		FROM %Table:SZU% SZU 
		INNER JOIN %Table:SB1% SB1 ON (ZU_COD = B1_COD)
		WHERE SZU.ZU_FILIAL = %xFilial:SZU%
		AND SB1.B1_FILIAL = %xFilial:SB1%
		AND ZU_DATA = %Exp:DtoS(dData)%
		AND ZU_COD = B1_COD
		AND ZU_PREDES <> ''
		AND	SZU.%NotDel% AND SB1.%NotDel%) AUX
		WHERE AUX.AUTOM = 'S'
		ORDER BY AUX.B1_GRUPO, AUX.ZU_DATA, AUX.ZU_COD
	EndSql

	aadd(_aProcess,'Todos')

	While (cAliasTMP)->(!eof()) 
		if empty((cAliasTMP)->B1_GRUPO)
			(cAliasTMP)->(DbSkip())
			loop
		endif

		_nPos := aScan(_aProcess,(cAliasTMP)->B1_GRUPO)   

		if _nPos = 0
			aadd(_aProcess,(cAliasTMP)->B1_GRUPO)
		endif

		(cAliasTMP)->(DbSkip())
	enddo

return

//Gera Arquivo Temporário para MSSELECT()
Static Function GeraTMP()

	_aArqTrb  := {} 
	_nCount   := 0

	If Select("TMP")<>0
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	DbSelectArea(cAliasTMP)
	(cAliasTMP)->(DbGotop())

	//cArq  := CriaTrab( Nil, .F. )

	aStru := dbStruct()

	aadd(aStru,{"ZU_OK"     , "C",  2, 0})
	aadd(aStru,{"Z2_DATAABT", "D",  8, 0})
	aadd(aStru,{"ZU_DTEMB"  , "D",  8, 0})
	aadd(aStru,{"ZU_DATAP"  , "D",  8, 0})
	aadd(aStru,{"ZU_DTDEV"  , "D",  8, 0})
	aadd(aStru,{"ZU_USUAR"  , "C", 20, 0})

	//dbcreate(cArq,aStru)
	//dbUseArea( .T.,,cArq,'TMP', .F. , .F. )               //cria temp
	//Index On B1_GRUPO To (cArq)

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	(cAliasTMP)->(DbGoTop())

	While (cAliasTMP)->(!eof())

		if _cCombo <> 'Todos'
			if (cAliasTMP)->B1_GRUPO <> _cCombo
				(cAliasTMP)->(DbSkip())
				loop
			endif
		else
			if (cAliasTMP)->B1_GRUPO $ _cGrpPORC
				(cAliasTMP)->(DbSkip())
				loop
			endif
		endif

		if _lDiverg
			if (cAliasTMP)->ZU_DATA = (cAliasTMP)->ZU_DTPROD
				(cAliasTMP)->(DbSkip())
				loop
			endif
		endif

		_cPredes := GetAdvFval('SZU','ZU_PREDES',FWxfilial('SZU') + (cAliasTMP)->ZU_NUM,2)
		_dDtProd := GetAdvFval('SZ2','Z2_DATAABT',FWxfilial('SZ2') + _cPredes,2)
		_dDtEmb  := GetAdvFval('SZU','ZU_DTPROD',FWxfilial('SZU') + (cAliasTMP)->ZU_NUM,2)
		_dData   := GetAdvFval('SZU','ZU_DATA',FWxfilial('SZU') + (cAliasTMP)->ZU_NUM,2)
		_dDtdev  := GetAdvFval('SZU','ZU_DTDEV',FWxfilial('SZU') + (cAliasTMP)->ZU_NUM,2)
		_cUsuar  := GetAdvFval('SZU','ZU_USUAR',FWxfilial('SZU') + (cAliasTMP)->ZU_NUM,2)

		DbSelectArea('TMP')
		Reclock('TMP',.t.)
		TMP->ZU_FECHADO := (cAliasTMP)->ZU_FECHADO
		TMP->ZU_NUM     := (cAliasTMP)->ZU_NUM
		TMP->ZU_COD     := substr((cAliasTMP)->ZU_COD,1,6)
		TMP->ZU_DESC    := substr((cAliasTMP)->ZU_DESC,1,30)
		TMP->ZU_QPCAIX	:= (cAliasTMP)->ZU_QPCAIX
		TMP->Z2_DATAABT := _dDtProd
		TMP->ZU_DTEMB   := _dDtEmb
		TMP->ZU_DATAP   := _dData
		TMP->ZU_DTDEV	:= _dDtdev
		TMP->ZU_USUAR	:= alltrim(_cUsuar)
		TMP->ZU_QRCAIX  := (cAliasTMP)->ZU_QRCAIX
		TMP->B1_GRUPO   := (cAliasTMP)->B1_GRUPO
		MsUnlock() 

		_nCount++

		(cAliasTMP)->(DbSkip())
	enddo

	dbSelectarea('TMP')

	TMP->(dbGotop())

return


User function DTI88PPE(_nTip,_cProd,_dDtEmba, valor2, _predes)
	Local _cCodPEs := GETMV('SI_PETQES')
	Local _nPesom := 0
	Local Ret      := 'PA'
	Local _grp		:= ''
	Local _MPPORC	:= ''
	LOCAL _cProdGrpPORC := GetMV('MV_GRPPORC')
	Local _cOper   := UsrRetName(retcodusr())
	/*  
	Chegando então informações que precisamos para gerar a "Prev. de Produção da Embalagem"
	GJF24 - Prev Produção Embalagem
	DTI41 - Impr.Etiquetas Internas 
	_cProd - produto 
	_dDABT - data da Produção/Abate 
	_dDtEmba - Data da Embalagem
	*/
	/* Regras de Busca de informações */
	If _nTip = 1 .OR. _nTip = 3
		/*Primeiro caso (_nTip = 1) - O  Produto não possui previsão de Embalagem Lançada 
		Segundo Caso (_nTip = 3) - 'O Produto  esta com '+cValtoChar(_nDABT)+' Previsões de  Data do Abate diferente da Data lançada na produção das Etiqueta Internas 
		Aqui acho que devo só vincular as previsões ou refazer uma nova ??? ver com a Valeska */
		_nPesom := pmc(10,alltrim(_cProd))
		_cDesc := GetAdvFval('SB1','B1_DESCRED',FWxFilial('SB1') + alltrim(_cProd),1)
		//_cNumP:= BuscaPDes(_dDABT,_cProd,_cPTF,_cCodTF)
		/* Regra para quando for produto que precisa ser preenchido como exportação */
		if alltrim(_cProd) $ _cCodPEs
			Ret := 'ES'
		endif
		/* Regra para quando for produto para porcionados ou Miúdos porcionados */
		_grp := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+alltrim(_cProd),1)
		if alltrim(_grp) $ _cProdGrpPORC
			Return .f.
		elseif _grp $ '4006/4007/4008/4009'
			_MPPORC  := 'S'
		endif
		/* 
		Ajuste feito nestas duas linhas a baixo, porque o funcionário da Desossa esta produzindo as etiquetas internas um dia antes para adiantar serviço
		SZU->ZU_DATA	:= ddatabase	Alterado para que as etiquetas sejam impressas um dia antes Alt 07/06/21 Flávio pedido henrique
		SZU->ZU_DTRPRO := date()   Alterado para que as etiquetas sejam impressas um dia antes Alt 07/06/21 Flávio pedido henrique
		*/
		_cNumer := GETSX8NUM('SZU','ZU_NUM')  
		ConfirmSX8() 
		RecLock("SZU",.T.)
			SZU->ZU_FILIAL  := FWxFilial("SZU")
			SZU->ZU_NUM     := _cNumer
			//SZU->ZU_DATA  := date()
			SZU->ZU_DATA    := ddatabase
			SZU->ZU_COD     := alltrim(_cProd)
			SZU->ZU_DESC    := _cDesc
			SZU->ZU_PRIORI  := 'C'
			SZU->ZU_CONTEXA := 'N'
			//SZU->ZU_DTRPRO  := date()
			SZU->ZU_DTRPRO  := ddatabase
			SZU->ZU_DTPROD  := _dDtEmba
			SZU->ZU_NOTIMP  := 'A'
			SZU->ZU_MDESP   := 'N'
			SZU->ZU_NUMETQ  := 1
			SZU->ZU_HORA    := Time()
			SZU->ZU_USUAR   := 'S_' +_cOper
			SZU->ZU_QPETIQ  := 30
			SZU->ZU_LISTETQ := 'S'
			SZU->ZU_FECHADO := 'B'
			SZU->ZU_TIPO    := 'P'
			SZU->ZU_TF      := 'N'
			SZU->ZU_QPCAIX  := 10
			SZU->ZU_TOLERA  := 10
			SZU->ZU_MPPORC  := _MPPORC
			SZU->ZU_ETIQ    := Ret
			SZU->ZU_REPAUT  := 'S'
			SZU->ZU_QPPESO  := _nPesom
			SZU->ZU_DTABT   := valor2
			SZU->ZU_PREDES  := _predes
		MsUnLock()
	Elseif _nTip =2
		/*
		O Produto  esta com '+cValtoChar(_nNvinc)+' Previsões da Enbalagem NÃO vinculada com Prev. da Desossa
		Aqui acho que devo só vincular as previsões ou refazer uma nova ??? ver com a Valeska
		Deixei para caso precise Futuramente
		*/
	End	
return

//função para calcular o peso medio por caixa e o peso medio a produzir
Static function pmc(caixas,Codigo)
	if !empty(caixas) .and. !empty(Codigo)
		pmc    := GetAdvFval('SB1','B1_PMCAIX',FWxfilial('SB1')+Codigo,1)
		pmedio := (caixas * pmc)
		return pmedio
	endif
return 0

//Static Function BuscaPDes(_dA,_pro,_Stf,_cTF)
Static Function BuscaPDes(_pro,_Stf,_cTF)

	Local _cN  := ''
	Local _cN2 := ''
	Local _cN3 := '' 
	Local _nCont := 0
	Local _nCont2 := 0

	/*
	_dA = Data do Abate
	_pro - Código do Produto que esta sendo impresso
	_Stf = Situação da identificação de TF 
	_cTF = Códigos de produtos identificados como TF que o PCP denomina 
	*/
	If alltrim(_pro) $ alltrim(_cTF)
		_Stf := 'S'
	Endif

	SZ2->(DbGoTop()) 
	SZ2->(dbSetOrder(5))

	/* Se previsão for TF então sistema só busca  previsões comclassificação NE*/

	IF _Stf = 'S'
		if !empty(SZ2->(dbSeek(FWxFilial('SZ2') + DTOS(_dA))))
			While SZ2->(!EOF()) .AND.  SZ2->Z2_DATAABT = _dA
					if AllTrim(SZ2->Z2_CLASSIF) = 'NE'
						_cN3 :=  SZ2->Z2_NUM							
						_cN3 := _cN3+_Stf							
						_nCont++
						Exit
					endif
					SZ2->(dbSkip())
			Enddo
		Endif
		
	Else		
		// Caso a previsão não esteja marcada como TF então busca aqui	
		if !empty(SZ2->(dbSeek(FWxFilial('SZ2') + DTOS(_dA))))
			While SZ2->(!EOF()) .AND.  SZ2->Z2_DATAABT = _dA
				if AllTrim(SZ2->Z2_CLASSIF) = 'HK' .AND.  SZ2->Z2_CLASESP= 'S'  
					/*  Se tiver previsão que for HK e Classificação especial  */
					_cN :=  SZ2->Z2_NUM
					_nCont++
					Exit
				else
					/*  Se tiver qualquer Previsão da Desossa */			
					_cN2 :=  SZ2->Z2_NUM
					_nCont2++
				Endif			
				SZ2->(dbSkip())
			Enddo
			If _nCont >0 	
				_cN3 := _cN
				_cN3 := _cN3+_Stf
			elseif _nCont2 >0
				_cN3 := _cN2
				_cN3 := _cN3+_Stf
			endif
		Else 
			//alert('Sem Previsão da Desossa Lançada para esta data de Abate, Entrar em contato com PCP !!')
		Endif
	Endif

Return alltrim(_cN3)


user function d88lib2()  

	TMP->(dbgotop())   
	while TMP->(!eof())  
		If !Empty(TMP->ZU_OK)
			if  TMP->ZU_FECHADO = 'B'                   
				/*Atualização da Interface */
				reclock('TMP',.f.)
				TMP->ZU_FECHADO := 'N'
				msunlock()

				SZU->(DbGoTop()) 
				SZU->(dbSetOrder(2))	

				if !empty(SZU->(dbSeek(FWxFilial('SZU') + alltrim(TMP->ZU_NUM))))
					/*Atualização da Tabela */
					reclock('SZU',.f.)
						SZU->ZU_FECHADO := 'N'
					msunlock()
				Endif
			endif
		endif
		TMP->(dbskip())
	enddo     
	TMP->(dbgotop())   

	oMark:oBrowse:Refresh()	

return


user function d88blo()  

	TMP->(dbgotop())   
	while TMP->(!eof())  
		If !Empty(TMP->ZU_OK)
			if TMP->ZU_FECHADO != 'B'                    
				/*Atualização da Interface */
				reclock('TMP',.f.)
				TMP->ZU_FECHADO := 'B'
				msunlock()

				SZU->(DbGoTop()) 
				SZU->(dbSetOrder(2))	
		
				if !empty(SZU->(dbSeek(FWxFilial('SZU') + alltrim(TMP->ZU_NUM))))
					/*Atualização da Tabela */
					reclock('SZU',.f.)
						SZU->ZU_FECHADO := 'B'
					msunlock()
				Endif					
			endif
		endif
		TMP->(dbskip())
	enddo      

	TMP->(dbgotop())   

	oMark:oBrowse:Refresh()	

return


Static Function LibPA()

	oTxtT  := 'Liberada a Produção Automática!'
	PUTMV('SI_LIBR88','1')

	u_dtilog(cFilAnt, "DTI88", "Liberada a geração de OP automática! -> " + time(), "L")

	oSayTxtT:CtrlRefresh() 
	oDlg:refresh()

Return


Static Function BlPA()

	oTxtT  := 'Bloqueado a Produção Automática!'
	PUTMV('SI_LIBR88','2')

	u_dtilog(cFilAnt, "DTI88", "Bloqueada a geração de OP automática! -> " + time(), "B")

	oSayTxtT:CtrlRefresh() 
	oDlg:refresh()

Return


Static Function StPA()

	_cLibr88	:= GetMV('SI_LIBR88')
	oTxtT  := ''

	If alltrim(_cLibr88) = '1'
		oTxtT  := 'Liberada a Produção Automática!'
	elseif alltrim(_cLibr88) = '2'
		oTxtT  := 'Bloqueada a Produção Automática!'
	endif

	oSayTxtT:CtrlRefresh() 
	oDlg:refresh()

Return

//Função que define o funcionamento de teclas de atalho
User Function dti88ke(_oper,_ac)
	//					I    A
	if _ac = 'A'
		Do case
			case  _oper = 'A'
				Set Key VK_F5 TO u_dti88atu()      // Atualiza saldo da tela de produtos
			case  _oper = 'I'	
				Set Key VK_F6 TO u_d88sld()      // Consulta saldo de produtos para geração da Solicitação de Produção
				/*   Atéomomento consegui gerara tela mas preciso deizxar ela mais dinâmica...*/			
		EndCase	
	else
		Set Key VK_F5  TO		
		Set Key VK_F6  TO
	endif

return


User function dti88atu()

	GeraTMP()
	oDlg:refresh()

Return 

//Consulta ao estoque e previsão de produção para verificar a viabilidade do produto By gjf28sld
User Function d88sld()
	Private _lSldFlag   := .f.    //Para utilizaçao da função gjf28sld()

	if cEmpAnt <> '01'
		msgbox('Rotina inválida para esta empresa','OPERAÇÃO INVALIDA','STOP')
		return
	endif

	if _lSldFlag
		return
	else
		_lSldFlag := .t.
	endif

	/* saldo  vendo aqui */
	nPosDel := Len(aHeader) + 1

	area := getarea()
	prod := GDFieldGet('ZZV_COD')

	DbSelectArea('SB1')

	UM      := GetAdvFval('SB1','B1_SEGUM',FWxfilial('SB1') + prod,1)
	_cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1') + prod,1)
	_EmpFCaix := 0
	_cPorc := GetAdvFval('SBM','BM_PORC',FWxfilial('SBM') + _cGrupo,1)

	if UM == 'CX' .OR. _cPorc == 'S'
		//query para trazer a validade das caixas
		cQuery4 := "SELECT COUNT(*) AS VALIDADE FROM " + RetSqlTab("SZ8")
		cQuery4 += " WHERE " +  RetSqlFil('SZ8')
		cQuery4 += "  AND Z8_FIL = '" + cFilAnt + "'"
		cQuery4 += "  AND Z8_DATAE = ' '"
		cQuery4 += "  AND Z8_DATAS = ' '"
		cQuery4 += "  AND Z8_ENCONTR <> 'N'" 		
		cQuery4 += "  AND Z8_COD = '" + prod + "'"
		cQuery4 += "  AND Z8_DATAVAL BETWEEN '" + DTOS(ddatabase) + "' AND '" + DTOS(ddatabase+15) + "'"
		cQuery4 += "  AND  " + RetSqlDel("SZ8")

		//query para trazer o que já está em estoque
		cQuery1 := "SELECT COUNT(*) AS ESTCAIX,SUM(SZ8.Z8_PESO) AS ESTPESO FROM " + RetSqlTab("SZ8")
		cQuery1 += " WHERE " +  RetSqlFil('SZ8')
		cQuery1 += "  AND Z8_FIL = '" + cFilAnt + "'"
		cQuery1 += "  AND Z8_DATAE = ' '"
		cQuery1 += "  AND Z8_DATAS = ' '"
		cQuery1 += "  AND Z8_ENCONTR <> 'N'"
		cQuery1 += "  AND Z8_COD = '" + prod + "'"
		cQuery1 += "  AND  " + RetSqlDel("SZ8")

		//query para trazer a previsao de caixas do produto
		cQuery2 := "SELECT ZU_PRIORI AS PRIORI, SUM(ZU_QPCAIX) AS QPCAIX, SUM(ZU_QRCAIX) AS QRCAIX,"
		cQuery2 += " SUM(ZU_QPPESO) AS QPPESO, SUM(ZU_QRPESO) AS QRPESO "
		cQuery2 += " FROM " + RetSqlTab("SZU")
		cQuery2 += " WHERE " +  RetSqlFil('SZU')
		cQuery2 += "  AND ZU_FECHADO = 'N' "
		cQuery2 += "  AND ZU_DTRPRO = '"+ DTOS(ddatabase)+"'"
		cQuery2 += "  AND ZU_COD = '" + prod + "'"
		cQuery2 += "  AND  " + RetSqlDel("SZU")
		cQuery2 += "  GROUP BY ZU_PRIORI"

		//query para trazer o que já está empenhado em pré-pedidos relativo ao produto
		cQuery3 := "SELECT SUM(ZZ5_QPCAIX) AS QPCAIX, SUM(ZZ5_QRCAIX) AS QRCAIX, ZZ4_DATA AS DTEMP, "
		cQuery3 += " SUM(ZZ5_QPPESO) AS QPPESO, SUM(ZZ5_QRPESO) AS QRPESO
		cQuery3 += " FROM " + RetSqlTab("ZZ5") + "," + RetSqlTab("ZZ4")
		cQuery3 += " WHERE " + RetSqlFil('ZZ5') + " AND " + RetSqlFil('ZZ4')
		cQuery3 += "  AND ZZ5_STATUS <> 'E'
		cQuery3 += "  AND ZZ4_NUM = ZZ5_NUM "
		cQuery3 += "  AND (ZZ4_STATUS <> 'E'"
		cQuery3 += "  AND ZZ4_STATUS <> 'P'"
		cQuery3 += "  AND ZZ4_STATUS <> 'F')"
		cQuery3 += "  AND ZZ4_TPOPER <> 'C'"
		cQuery3 += "  AND ZZ4_DATA = '" + DTOS(ddatabase) + "'"
		cQuery3 += "  AND ZZ5_COD = '" + prod + "'"
		cQuery3 += "  AND  " + RetSqlDel("ZZ4")
		cQuery3 += "  AND  " + RetSqlDel("ZZ5")
		cQuery3 += "  GROUP BY ZZ4_DATA"

		//query para trazer o que já está empenhado em pré-pedidos relativo ao produto do dia anterior
		cQuery5 := "SELECT SUM(ZZ5_QPCAIX) AS QPCAIX, SUM(ZZ5_QRCAIX) AS QRCAIX,
		cQuery5 += " SUM(ZZ5_QPPESO) AS QPPESO, SUM(ZZ5_QRPESO) AS QRPESO
		cQuery5 += " FROM " + RetSqlTab("ZZ5") + "," + RetSqlTab("ZZ4")
		cQuery5 += " WHERE " + RetSqlFil('ZZ5') + " AND " + RetSqlFil('ZZ4')
		cQuery5 += "  AND ZZ5_STATUS <> 'E'
		cQuery5 += "  AND ZZ4_NUM = ZZ5.ZZ5_NUM "
		cQuery5 += "  AND (ZZ4_STATUS <> 'E'"
		cQuery5 += "  AND ZZ4_STATUS <> 'P'"
		cQuery5 += "  AND ZZ4_STATUS <> 'F')"
		cQuery5 += "  AND ZZ4_TPOPER <> 'C'"
		cQuery5 += "  AND ZZ4_DATA = '" + DTOS(ddatabase-1) + "'"
		cQuery5 += "  AND ZZ5_COD = '" + prod + "'"
		cQuery5 += "  AND " + RetSqlDel("ZZ4")
		cQuery5 += "  AND " + RetSqlDel("ZZ5")

		//query para trazer estoque de produtos alternativos
		cQuery7 := "SELECT ZAL_CODA AS CODA, COUNT(*) AS QUANT,SUM(Z8_PESO) AS PESO "
		cQuery7 += " FROM  " + RetSqlTab("SZ8") + "," + RetSqlTab("ZAL")
		cQuery7 += " WHERE " + RetSqlFil('SZ8') + " AND " + RetSqlFil('ZAL')
		cQuery7 += "  AND Z8_FIL = '" + cFilAnt + "' AND ZAL_FILIAL = '" + cFilAnt + "'"
		cQuery7 += "  AND Z8_COD = ZAL_CODA AND Z8_DATAE = ' '"
		cQuery7 += "  AND Z8_DATAS = ' '"
		cQuery7 += "  AND Z8_ENCONTR <> 'N'"
		cQuery7 += "  AND ZAL_COD = '" + prod + "'"
		cQuery7 += "  AND  " + RetSqlDel("SZ8") + " AND " + RetSqlDel("ZAL")
		cQuery7 += " GROUP BY ZAL_CODA "
		cQuery7 += " ORDER BY ZAL_CODA "

		//query para trazer o que já está carregado em pré-pedidos relativo ao produto
		cQuery8 := "SELECT SUM(ZZ5_QPCAIX) AS QPCAIX, SUM(ZZ5_QRCAIX) AS QRCAIX, ZZ4_DATA AS DTEMP, "
		cQuery8 += " SUM(ZZ5_QPPESO) AS QPPESO, SUM(ZZ5_QRPESO) AS QRPESO
		cQuery8 += " FROM " + RetSqlTab("ZZ5") + "," + RetSqlTab("ZZ4")
		cQuery8 += " WHERE " + RetSqlFil('ZZ5') + " AND " + RetSqlFil('ZZ4')
		cQuery8 += "  AND ZZ5_STATUS <> 'E'
		cQuery8 += "  AND ZZ4_NUM = ZZ5_NUM "
		cQuery8 += "  AND (ZZ4_STATUS <> 'E'"
		cQuery8 += "  AND ZZ4_STATUS <> 'P'"
		cQuery8 += "  AND ZZ4_STATUS <> 'F')"
		cQuery8 += "  AND ZZ4_TPOPER <> 'C'"
		cQuery8 += "  AND ZZ4_DATA = '" + DTOS(ddatabase) + "'"
		cQuery8 += "  AND ZZ5_COD = '" + prod + "'"
		cQuery8 += "  AND  " + RetSqlDel("ZZ4")
		cQuery8 += "  AND  " + RetSqlDel("ZZ5")
		cQuery8 += "  GROUP BY ZZ4_DATA"

		//	cQuery1 := ChangeQuery(cQuery1)
		cQuery2 := ChangeQuery(cQuery2)
		cQuery3 := ChangeQuery(cQuery3)
		cQuery4 := ChangeQuery(cQuery4)
		cQuery5 := ChangeQuery(cQuery5)
		cQuery7 := ChangeQuery(cQuery7)
		cQuery8 := ChangeQuery(cQuery8)

		//	* Mostrar a consulta */
		//	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//	@ 055,005 Get cQuery8 Size 250,080 MEMO Object oMemo
		//	Activate Dialog oDlgMemo

		If Select("QRY1")<>0
			QRY1->(dbCloseArea())
		Endif
		If Select("QRY2")<>0
			QRY2->(dbCloseArea())
		Endif
		If Select("QRY3")<>0
			QRY3->(dbCloseArea())
		Endif
		If Select("QRY4")<>0
			QRY4->(dbCloseArea())
		Endif
		If Select("QRY5")<>0
			QRY5->(dbCloseArea())
		Endif
		If Select("QRY7")<>0
			QRY7->(dbCloseArea())
		Endif
		If Select("QRY8")<>0
			QRY8->(dbCloseArea())
		Endif

			TCQUERY cQuery7 NEW ALIAS "QRY7"

			//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

			aStru := {}
			AADD(aStru,{"OK"      ,"C"	,2		,0	})
			AADD(aStru,{"CODA"    ,"C"	,6		,0	})
			AADD(aStru,{"DESCR"   ,"C"	,20   ,0	})
			AADD(aStru,{"QUANT"   ,"N"	,4		,0 })
			AADD(aStru,{"PESO"    ,"N", 9		,2	})

			//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado

			//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
			//	TMP->(dbCloseArea())
			//Endif

			//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

			_aArqTrb    := {} 
			U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

			QRY7->(DbGotop())

			_nRegAlt := 0

			while QRY7->(!eof())
				DbSelectArea('TMP')
				reclock('TMP',.t.)
				TMP->CODA    :=  QRY7->CODA
				TMP->DESCR   :=  GetAdvFval('SB1','B1_DESCRED',FWxfilial('SB1')+QRY7->CODA,1)
				TMP->QUANT   :=  QRY7->QUANT
				TMP->PESO    :=  QRY7->PESO
				msunlock()

				_nRegAlt++

				QRY7->(DbSkip())
			enddo

			QRY7->(dbclosearea())
			TMP->(DbGoTop())

			aCampos := {}

			AADD(aCampos,{"OK"      ,,"OK "       ,"@!" })
			AADD(aCampos,{"CODA"    ,,"Produto"   ,"@!" })
			AADD(aCampos,{"DESCR"   ,,"Descricao" ,"@!" })
			AADD(aCampos,{"QUANT"   ,,"Quant."    ,"@E 9,999"})
			AADD(aCampos,{"PESO"    ,,"Peso"      ,"@E 999,999.99"})

		TCQUERY cQuery1 NEW ALIAS "QRY1"
		estcx := QRY1->ESTCAIX
		estps := QRY1->ESTPESO
		QRY1->(dbclosearea())
		
		TCQUERY cQuery2 NEW ALIAS "QRY2"
		prevC := 0
		prevP := 0
		while QRY2->(!eof())
			if QRY2->QRCAIX < QRY2->QPCAIX
				prevC += QRY2->(QPCAIX - QRCAIX)
				prevP += QRY2->(QPPESO - QRPESO)
			endif
			QRY2->(dbskip())
		enddo
		QRY2->(dbclosearea())

		TCQUERY cQuery3 NEW ALIAS "QRY3"
		empC   := 0
		empP   := 0
		_demp  := date()

		if (QRY3->QRCAIX < QRY3->QPCAIX)  .or. (QRY3->QRPESO < QRY3->QPPESO)
			empC   := QRY3->(QPCAIX - QRCAIX)
			empP   := QRY3->(QPPESO - QRPESO)
			_demp  := stod(QRY3->DTEMP)
		endif
		QRY3->(dbclosearea())

		TCQUERY cQuery5 NEW ALIAS "QRY5"
		empantC := 0
		empantP := 0

		if (QRY5->QRCAIX < QRY5->QPCAIX) .or. (QRY5->QRPESO < QRY5->QPPESO)
			empantC := QRY5->(QPCAIX - QRCAIX)
			empantP := QRY5->(QPPESO - QRPESO)
		endif
		QRY5->(dbclosearea())

		TCQUERY cQuery4 NEW ALIAS "QRY4"
		validad := 0
		validad := QRY4->VALIDADE
		QRY4->(dbclosearea())

		TCQUERY cQuery8 NEW ALIAS "QRY8"
		empCd   := 0
		empPd   := 0
		_demp  := date()

		if (QRY8->QRCAIX < QRY8->QPCAIX)  .or. (QRY8->QRPESO < QRY8->QPPESO)
			empCd   := QRY8->(QPCAIX - QRCAIX)
			empPd   := QRY8->(QPPESO - QRPESO)
			qCpc	:= QRY8->(QRCAIX)
			qCpp	:= QRY8->(QRPESO)
		endif
		QRY8->(dbclosearea())

		if !(FunName() $ 'GJF30')
			restarea(area)
		endif
		qCpc := 0
		qCpp := 0
		QTDc := 0
		QTDp := 0

		// aqui preciso de uma query para verificar a quantidade já carregada no dia					
		QTDc := empCd
		QTDp := empPd
		dbSelectArea('ZZ5')

		QTDc := iif((QTDc - qCpc)<0,0,(QTDc - qCpc))
		QTDp := iif((QTDp - qCpp)<0,0,(QTDp - qCpp))

		//saldoC := iif(estTFcx <> 0,(estTFcx + prevC),(estcx + prevC)) - (empC + empantC + QTDc)
		saldoC := (estcx + prevC) - (empC + empantC + QTDc)		
		saldoP := iif(estTFps <> 0,(estTFps + prevP),(estps + prevP)) - (empP + empantP + QTDp)

		DEFINE MSDIALOG oSld TITLE 'Posição do Produto' from 000,000 To 400,400 OF oMainWnd PIXEL

		@ 010,070 SAY  'Caixas'        Object oSay1
		@ 010,110 SAY  ' Peso '        Object oSay2
		@ 020,015 SAY  'Estoque:'      Object oSay3
		@ 030,015 SAY  'TF Liberado:'  Object oSay7
		@ 040,015 SAY  'Previsão:'     Object oSay4
		@ 050,015 SAY  'Empenho:'      Object oSay5
		@ 060,015 SAY  'Saldo:'        Object oSay6

		/*  Este ja esta ok */
		@ 020,068 SAY  '[          ]'                                     Object oSay7
		@ 020,103 SAY  '[                  ]'                             Object oSay8
		@ 020,070 SAY  transform(estcx,'@E 9,999')                 		  Object oSay9
		@ 020,105 SAY  transform(estps ,'@E 999,999.99')           		  Object oSay10

		@ 040,068 SAY  '[          ]'                                     Object oSay11
		@ 040,103 SAY  '[                  ]'                             Object oSay12
		@ 040,070 SAY  transform(prevC,'@E 9,999')                 		  Object oSay13
		@ 040,105 SAY  transform(prevP,'@E 999,999.99')            		  Object oSay14

		@ 050,068 SAY  '[          ]'                                     Object oSay15
		@ 050,103 SAY  '[                  ]'                             Object oSay16
		@ 050,070 SAY  transform(empC + empantC + QTDc,'@E 9,999') 		  Object oSay17
		@ 050,105 SAY  transform(empP + empantP + QTDp,'@E 999,999.99')   Object oSay18

		@ 060,068 SAY  '[          ]'                                     Object oSay19
		@ 060,103 SAY  '[                  ]'                             Object oSay20
		@ 060,070 SAY  transform(saldoC,'@E 9,999') 		               	Object oSay21
		@ 060,105 SAY  transform(saldoP,'@E 999,999.99')                  Object oSay22

		@ 075,170 BMPBUTTON TYPE 1 ACTION oSld:end() Object Obtn1

		ACTIVATE MSDIALOG oSld

	else
		msgbox('Produto não possui Controle de Estoque!','PRODUTO EM PEÇAS','STOP')
	endif

	_lSldFlag := .f.

return
