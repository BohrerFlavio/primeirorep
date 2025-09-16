#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF145    º Autor ³ Giuliano Forgiariniº Data ³  17/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Montagem de Pallets de PA                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAPCP                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF145()

	Private  _cGet1   := space(11)
	Private  _nGet2   := 00.00
	Private aCampos  := {}
	Private aStru    := {}
	Private _aOpcoes := {"Montagem","Desmontagem","Consulta"}
	Private _aOpcoes2:= {"Produto Acabado","Materia Prima"}
	Private cpo8     := ''
	Private cpo9     := space(11)
	Private cpo10     := ''
	Private cpo11    := ''
	Private cpo12     := ''
	Private cpo13     := 00
	Private _Produto := ''
	Private _Caixa   := space(11)
	Private _NrCaix  := 0
	Private _MaxCx   := 000
	Private _nModo   := 1
	Private _nModo2  := 1
	Private _aOpSeq	 := {"Padrão","Bizerba"}
	Private _nModSeq := 1
	Private _Mens1   := ''
	Private _Mens2   := ''
	Private _clocaliz:= space(10)
	Private _cTipoC  := ''
	Private _cTipoP  := ''
	Private cArq
	Private _Codigo := getSX8Num('SZP','ZP_COD')
	Private _cIp    := ''
	Private cPerg   := "GJF145"
	Private _cGrpPorc  := alltrim(GetMV('MV_GRPPORC'))
	Private cUserID	   := alltrim(RetCodUsr())

	if !Pergunte(cPerg,.t.)
		return
	endif

	confirmSX8()

	_aArqTrb := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//RPCSetType(3) //não consome licença.
	//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	DEFINE MSDIALOG oAut TITLE 'MONTAGEM DE PALLETS DE PA' from 000,000 To 600,600  PIXEL

	montabrow()

	@001,001  SAY  "Codigo do Pallet:" OF oAut
	@002,001  MSGET cpo8 VAR _Codigo SIZE 70,11 Picture  OF oAut

	@003,001  SAY  "Codigo do Produto:" OF oAut
	@004,001  MSGET cpo10 VAR _Produto SIZE 70,11 Picture  OF oAut

	//@008,001  MSGET cpo9 VAR _Caixa SIZE 70,11 PICTURE "@!" Valid Leitura() OF oAut

	@005,001  SAY  "Maximo de Caixas:" OF oAut
	@006,001  MSGET cpo13 VAR _MaxCx PICTURE "@E 999" SIZE 70,11  OF oAut Valid !Vazio()

	@005,014  SAY  "Caixas Lidas:" OF oAut
	@006,014  MSGET cpo11 VAR _NrCaix PICTURE "@E 999" SIZE 70,11  OF oAut

	@005,026  SAY  "Localização:" OF oAut
	@006,026  MSGET cpo12 VAR _clocaliz SIZE 70,11  OF oAut

	@007,001  SAY  "Leitura:" OF oAut
	@008,001  MSGET cpo9 VAR _Caixa SIZE 70,11 OF oAut Valid Leitura()

	oFont  := tFont():New("courier new",,-30,,.t.,,,,)
	oSayD1 := tSay():New(126,015,{|| _Mens1 },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,300,100)
	oSayD2 := tSay():New(118,015,{|| _Mens2 },oAut,,oFont,,,,.T.,CLR_HRED,CLR_HRED,300,100)

	@001,010 SAY "Modo:"
	oRadio := TRadMenu():New(025,80,_aOpcoes,{|u| Iif(PCount()==0,_nModo,_nModo:=u)},oAut,,{||Modos()},,,,,,100,40,,,,.T.)

	@001,019 SAY "Tipo:"
	oRadio2:= TRadMenu():New(025,150,_aOpcoes2,{|u| Iif(PCount()==0,_nModo2,_nModo2:=u)},oAut,,{||_codigo := TrataTipo(_codigo)},,,,,,100,40,,,,.T.)

	@001,029 say 'Sequencial:'
	oRadio3 := TRadMenu():New(025,230,_aOpSeq,{|u| Iif(PCount()=0,_nModSeq,_nModSeq:=u)},oAut,,{||ModSeq()},,,,,,100,40,,,,.T.)

	@ 150,010 To 260,290 Browse "TMP4" fields aCampos object oBrow4

	oBrow4:oBrowse:refresh()
	cpo8:disable()
	cpo10:disable()
	cpo11:disable()
	cpo12:disable()
	cpo13:SetFocus()

	@ 270,115  BUTTON 'Imprimir'  SIZE 40,15 ACTION Imprimir()     OBJECT oBtn2
	@ 270,160  BUTTON 'OK'        SIZE 40,15 ACTION Confirmar()    OBJECT oBtn3
	@ 270,205  BUTTON 'Cancelar'  SIZE 40,15 ACTION Cancelar()     OBJECT oBtn4
	@ 270,250  BUTTON 'Sair'      SIZE 40,15 ACTION oAut:end()     OBJECT oBtn5

	ACTIVATE MSDIALOG oAut CENTERED

	If Select('TMP4')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP4->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	RollBackSX8()
	//RESET ENVIRONMENT

Return

Static Function montabrow()

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário
	_aArqTrb := {}

	aadd(aCampos,{"NUMERO" ,"Nr.Caixa",""})
	aadd(aCampos,{"COD"    ,"Codigo"  ,""})
	aadd(aCampos,{"DESCRI" ,"Produto" ,""})
	aadd(aCampos,{"DATAP"  ,"Data"    ,""})
	aadd(aCampos,{"TIPO"   ,"Tipo"    ,""})

	aadd(aStru,{"NUMERO" , "C",  10, 0,   "@!"          , 'Nr.Caixa'})
	aadd(aStru,{"COD"    , "C",  06, 0,   "@!"          , 'Codigo  '})
	aadd(aStru,{"DESCRI" , "C",  30, 0,   "@!"          , 'Produto '})
	aadd(aStru,{"DATAP"  , "D",  08, 0,   "99/99/99"    , 'Data Pr.'})
	aadd(aStru,{"TIPO"   , "C",  02, 0,   "@!"          , 'Tipo    '})

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP4 criado
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP4", .F. , .F. )

	If Select('TMP4')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP4->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP4", aStru, {}, @_aArqTrb)

	TMP4->(DbGotop())

Return

//Leitura das caixas/pallets
Static Function Leitura()

	if empty(_caixa)
		Return .t.
	endif

	//Modo = 1: Montagem de pallets
	//Modo = 2: Desmontagem de pallets
	//Modo = 3: Consulta de pallets
	//Modo2 = 1: Produto Acabado
	//Modo2 = 2: Materia Prima

	//Se for caixa e modo = 1 (montagem)...
	if !(substr(_caixa,1,2) $ 'PA/MP') .and. _nModo = 1 //Se for caixa e modo = 1...
		ZAS->(DbSetOrder(1))
		ZAS->(DbGoTop())
		SZ8->(DbGoTop())
		if _nModSeq = 1
			SZ8->(DbSetOrder(3))
			_lSZ8 := SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(_caixa)))
		else
			SZ8->(DbSetOrder(28))
			if SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(_caixa)))
				_caixa := SZ8->Z8_CONTROL
				_lSZ8 := .T.
			else
				_cControl := U_DTI210(_caixa, "")
				if !empty(_cControl)
					u_gjf17his(1,'ENTRADA ESTOQUE - LINHA 005',.f.,'','','000012', _cControl)
					_caixa := alltrim(_cControl)
					SZ8->(DbSetOrder(3))
					_lSZ8 := SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(_caixa)))
				else
					_lSZ8 := .F.
				endif
			endif
		endif

		_lZAS := ZAS->(MsSeek(FWxfilial('ZAS')+alltrim(_caixa)))

		if _lSZ8
			_cTipoC := 'PA'
		elseif _lZAS
			if ZAS->ZAS_TIPO = 'MP'
				_cTipoC := 'MP'
			elseif ZAS->ZAS_TIPO = 'PA'
				_cTipoC := 'PO'  //PA industria porcionados
			endif
		else
			SomErr()
			_Mens1 := ''
			_Mens2 := 'Caixa não identificada!'
			oSayD1:SetText(_Mens1)
			oSayD2:SetText(_Mens2)
			oAut:refresh()
			return .f.
		endif

		_lErroTipo := .f.

		if _cTipoC $ 'PA/PO' .and. _nModo2 == 2
			_lErroTipo := .t.
		elseif _cTipoC == 'MP' .and. _nModo2 == 1
			_lErroTipo := .t.
		endif

		if _lErroTipo
			SomErr()
			_Mens1 := ''
			_Mens2 := 'Tipo de produto inválido!'
			oSayD1:SetText(_Mens1)
			oSayD2:SetText(_Mens2)
			oAut:refresh()
			return .f.
		endif

		if _lSZ8
			_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+SZ8->Z8_COD,1)
			if _cGrupo $ _cGrpPorc .and. SZ8->Z8_DATAVAL < (date()+7)
				SomErr()
			elseif !(_cGrupo $ _cGrpPorc) .and. SZ8->Z8_DATAVAL < (date()+30)
				SomErr()
				FWAlertWarning("Caixa a menos de 30 dias da validade!", "ALERTA")
			endif
		endif

		//Se for Produto Acabado
		if _cTipoC == 'PA'
			if SZ8->Z8_FIL <> cFilAnt
				SomErr()
				_Mens1 := ''
				_Mens2 := 'Caixa em estoque fora da unidade!'
				oSayD1:SetText(_Mens1)
				oSayD2:SetText(_Mens2)
				oAut:refresh()
				return .f.
			endif

			//if !empty(SZ8->Z8_PALLET)
			//	SomErr()
			//	_Mens1 := ''
			//	_Mens2 := 'Caixa já pertence ao pallet: ' + SZ8->Z8_PALLET
			//	oSayD1:SetText(_Mens1)
			//	oSayD2:SetText(_Mens2)
			//	oAut:refresh()
			//	return .f.
			//endif

			if cUserID != "000914"
				if (!empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS) .or. !empty(SZ8->Z8_PRECAR) .or. !empty(SZ8->Z8_PREPED) .or. !empty(SZ8->Z8_ITEM)) .and. !(SZ8->Z8_MOTBAIX $ "COLETA/SEQUESTRO")
					SomErr()
					_Mens1 := ''
					_Mens2 := 'Caixa fora de estoque!'
					oSayD1:SetText(_Mens1)
					oSayD2:SetText(_Mens2)
					oAut:refresh()
					return .f.
				endif
			endif
			//Se for Materia Prima
		elseif _cTipoC == 'MP'
			if cUserID != "000914"
				if (!empty(ZAS->ZAS_DATAS) .or. !empty(ZAS->ZAS_HORAS)) .and. !(ZAS->ZAS_MOTS $ "COLETA/SEQUESTRO")
					SomErr()
					_Mens1 := ''
					_Mens2 := 'Caixa fora de estoque!'
					oSayD1:SetText(_Mens1)
					oSayD2:SetText(_Mens2)
					oAut:refresh()
					return .f.
				endif
			endif

			/*if !empty(ZAS->ZAS_PALLET)
			SomErr()
			_Mens1 := ''
			_Mens2 := 'Caixa já pertence ao pallet: ' + ZAS->ZAS_PALLET
			oSayD1:SetText(_Mens1)
			oSayD2:SetText(_Mens2)
			oAut:refresh()
			return .f.
			endif*/
			//Se for Materia Prima

		elseif _cTipoC == 'PO'
			if cUserID != "000914"
				if (!empty(ZAS->ZAS_DATAS) .or. !empty(ZAS->ZAS_HORAS)) .and. !(ZAS->ZAS_MOTS $ "COLETA/SEQUESTRO")
					SomErr()
					_Mens1 := ''
					_Mens2 := 'Caixa fora de estoque!'
					oSayD1:SetText(_Mens1)
					oSayD2:SetText(_Mens2)
					oAut:refresh()
					return .f.
				endif
			endif
		endif

		TMP4->(DbGoTop())
		While TMP4->(!eof())
			if TMP4->NUMERO = alltrim(_Caixa)
				SomErr()
				_Mens1 := ''
				_Mens2 := 'Caixa ' + alltrim(_Caixa) + ' já lida!'
				oSayD1:SetText(_Mens1)
				oSayD2:SetText(_Mens2)
				TMP4->(DbGoTop())
				oAut:refresh()
				return .f.
			endif
			TMP4->(DbSkip())
		enddo

		//verifica se o grupo de produto permite 30 ou 40 caixas no pallet
		_cProduto := iif(_cTipoC == 'PA',SZ8->Z8_COD,ZAS->ZAS_COD)

		_cGrupo   := GetAdvFVal('SB1','B1_GRUPO',FWxFilial('SB1') + _cProduto,1)
		_nTotCx   := contar('TMP4','!empty(TMP4->NUMERO)')
		_cMerc    := alltrim(GetAdvFVal('SB1','B1_DESTINO',FWxFilial('SB1') + _cProduto,1))
		_cTaraS   := GetAdvFVal('SB1','B1_CTARASE',FWxFilial('SB1') + _cProduto,1)

		//se for do grupo de porcionados permite 40 caixas
		if substr(_cGrupo,1,2) $ '56'
			//verifica a quantidade inserida no campo bem como a quantidade já escaneada
			if _cTaraS = '000065'
				if _MaxCx > 115
					SomErr()
					_Mens1 := ''
					_Mens2 := 'O max. de caixas para este prod. é 115!'
					oSayD1:SetText(_Mens1)
					oSayD2:SetText(_Mens2)
					oAut:refresh()
					return .f.
				endif
			else
				if _MaxCx > 81
					SomErr()
					_Mens1 := ''
					_Mens2 := 'O max. de caixas para este prod. é 81!'
					oSayD1:SetText(_Mens1)
					oSayD2:SetText(_Mens2)
					oAut:refresh()
					return .f.
				endif
			endif
		else
			if _cTaraS $ '000058/000057'//se for miudos o maximo de caixa é 49
				if _MaxCx > 56
					SomErr()
					_Mens1 := ''
					_Mens2 := 'O max. de caixas para este prod. é 56!'
					oSayD1:SetText(_Mens1)
					oSayD2:SetText(_Mens2)
					oAut:refresh()
					return .f.
				endif
			else
				if _cMerc = 'MI'//se for mercado interno 40 caixas
					//verifica a quantidade inserida no campo
					if _MaxCx > 49
						SomErr()
						_Mens1 := ''
						_Mens2 := 'O max. de caixas para este prod. é 49!'
						oSayD1:SetText(_Mens1)
						oSayD2:SetText(_Mens2)
						oAut:refresh()
						return .f.
					endif
				elseif _cMerc = 'ME'//se for mercado externo 35 caixas
					//verifica a quantidade inserida no campo
					if _MaxCx > 49
						SomErr()
						_Mens1 := ''
						_Mens2 := 'O max. de caixas para este prod. é 49!'
						oSayD1:SetText(_Mens1)
						oSayD2:SetText(_Mens2)
						oAut:refresh()
						return .f.
					endif
				endif
			endif
		endif

		if _nTotCx >= _MaxCx
			SomErr()
			_Mens1 := ''
			_Mens2 := 'Pallet já atingiu o maximo de caixas informado!'
			oSayD1:SetText(_Mens1)
			oSayD2:SetText(_Mens2)
			oAut:refresh()
			return .f.
		endif

		if _NrCaix = 0 .or. empty(_produto)
			_produto := iif(_cTipoC == 'PA',SZ8->Z8_COD,ZAS->ZAS_COD)
			cpo10:refresh()
			cpo11:refresh()
		endif

		_cProdCaixaLida := iif(_cTipoC == 'PA',SZ8->Z8_COD,ZAS->ZAS_COD)
		if _cProdCaixaLida <> _produto
			SomErr()
			_Mens1 := ''
			_Mens2 := 'Produto incorreto!'
			oSayD1:SetText(_Mens1)
			oSayD2:SetText(_Mens2)
			oAut:refresh()
			return .f.
		endif

		DbSelectArea('TMP4')
		reclock('TMP4',.t.)
		TMP4->NUMERO := iif(_cTipoC == 'PA',SZ8->Z8_CONTROL,ZAS->ZAS_CONTRO)
		TMP4->COD    := iif(_cTipoC == 'PA',SZ8->Z8_COD,ZAS->ZAS_COD)
		TMP4->DESCRI := iif(_cTipoC == 'PA',SZ8->Z8_DESCRI,ZAS->ZAS_DESC)
		TMP4->DATAP  := iif(_cTipoC == 'PA',SZ8->Z8_DATA,ZAS->ZAS_DTPROD)
		TMP4->TIPO   := iif(_cTipoC $ 'PA/PO','PA','MP')
		msunlock()

		_NrCaix := contar('TMP4','!empty(TMP4->NUMERO)')

		TMP4->(DbGoTop())

		ExecSom()
		_Mens1 := 'Caixa ' + alltrim(iif(_cTipoC == 'PA',SZ8->Z8_CONTROL,ZAS->ZAS_CONTRO))
		_Mens2 := ''
		oSayD1:SetText(_Mens1)
		oSayD2:SetText(_Mens2)

		cpo11:refresh()
		oBrow4:oBrowse:refresh()
		oAut:refresh()

		_caixa := space(11)

		//Se for caixa e modo 2 ou 3 (desmontagem ou consulta)...
	elseif !(substr(_Caixa,1,2) $ 'PA/MP') .and. (_nModo = 2 .or. _nModo = 3)

		SomErr()
		_Mens1 := ''
		_Mens2 := 'Modo de operação irregular'
		oSayD1:SetText(_Mens1)
		oSayD2:SetText(_Mens2)
		TMP4->(DbGoTop())
		oAut:refresh()
		return .f.

		//Se for pallet e modo = 1 (montagem)...
	elseif substr(_Caixa,1,2) $ 'PA/MP' .and. _nModo = 1
		SomErr()
		_Mens1 := ''
		_Mens2 := 'Operação irregular!'
		oSayD1:SetText(_Mens1)
		oSayD2:SetText(_Mens2)
		TMP4->(DbGoTop())
		oAut:refresh()
		return .f.

		//Se for pallet e modo = 3 (consulta) ou modo = 2 (desmontagem)...
	elseif substr(_Caixa,1,2) $ 'PA/MP' .and. (_nModo = 3 .or. _nModo = 2)

		_aArqTrb := {}

		//If Select("TMP4") != 0
		//	TMP4->(DbCloseArea())
		//	dbcreate(cArq,aStru)
		//	dbUseArea( .T.,,cArq,"TMP4", .F. , .F. )
		//	TMP4->(DbGotop())
		//	oBrow4:oBrowse:refresh()
		//	oAut:refresh()
		//Endif

		If Select('TMP4')<>0                               		// Se um tmp com alias TMP existir, fecha-o
			TMP4->(dbCloseArea())
			u_arqtrb ("FechaTodos",,,, @_aArqTrb)

			U_ArqTrb("Cria", "TMP4", aStru, {}, @_aArqTrb)
			TMP4->(DbGotop())
			oBrow4:oBrowse:refresh()
			oAut:refresh()
		Endif

		SZP->(DbSetOrder(1))
		SZP->(DbGoTop())
		if !SZP->(MsSeek(FWxfilial('SZP')+alltrim(_Caixa)))
			SomErr()
			_Mens1 := ''
			_Mens2 := 'Pallet não identificado!'
			oSayD1:SetText(_Mens1)
			oSayD2:SetText(_Mens2)
			oAut:refresh()
			return .f.
		endif

		if SZP->ZP_FIL <> cFilAnt
			SomErr()
			_Mens1 := ''
			_Mens2 := 'Pallet em estoque fora da unidade!'
			oSayD1:SetText(_Mens1)
			oSayD2:SetText(_Mens2)
			oAut:refresh()
			return .f.
		endif

		_Codigo   :=  SZP->ZP_COD
		_Produto  :=  SZP->ZP_PRODUTO
		_cLocaliz :=  SZP->ZP_LOCALIZ
		_cTipoP   :=  SZP->ZP_TIPO

		//Se for PA...
		if _cTipoP == 'PA'
			SZ8->(DbSetOrder(19))
			SZ8->(DbGoTop())

			if SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + alltrim(_Caixa) ))
				While SZ8->(!eof()) .and.  SZ8->(Z8_FILIAL+Z8_FIL+Z8_PALLET) = (FWxfilial('SZ8') + cFilAnt + alltrim(_Caixa))
					DbSelectArea('TMP4')
					reclock('TMP4',.t.)
					TMP4->NUMERO := SZ8->Z8_CONTROL
					TMP4->COD    := SZ8->Z8_COD
					TMP4->DESCRI := SZ8->Z8_DESCRI
					TMP4->DATAP  := SZ8->Z8_DATA
					msunlock()
					_NrCaix++
					SZ8->(DbSkip())
				enddo
			endif

			//Se for MP...
		elseif _cTipoP = 'MP'
			ZAS->(DbSetOrder(6))
			ZAS->(DbGoTop())

			if ZAS->(MsSeek(FWxfilial('ZAS') + alltrim(_Caixa)))
				While ZAS->(!eof()) .and. ZAS->(ZAS_FILIAL + ZAS_PALLET) = (FWxfilial('ZAS') + alltrim(_Caixa))
					DbSelectArea('TMP4')
					reclock('TMP4',.t.)
					TMP4->NUMERO := ZAS->ZAS_CONTRO
					TMP4->COD    := ZAS->ZAS_COD
					TMP4->DESCRI := ZAS->ZAS_DESC
					TMP4->DATAP  := ZAS->ZAS_DTPROD
					msunlock()
					_NrCaix++
					ZAS->(DbSkip())
				enddo
			endif

		endif

		TMP4->(DbGoTop())

		ExecSom()
		_Mens1 := 'Pallet ' + alltrim(_Codigo)
		_Mens2 := ''
		oSayD1:SetText(_Mens1)
		oSayD2:SetText(_Mens2)

		cpo8:refresh()
		cpo10:refresh()
		cpo11:refresh()
		cpo12:refresh()
		oBrow4:oBrowse:refresh()
		oAut:refresh()

		_caixa := space(11)

	endif

return .f.

Static Function Imprimir()

	//Inicio do bloco de inserção de peso Pallet feito por Fabian Maurer 16/02/17
	_lInfo := infoPesP()

	if !_lInfo .or. _nGet2 <= 0
		MsgBox("Informe o Peso do Pallet", "ATENÇÃO!", "STOP")
		_cGet1 := space(11)
		_nGet2 := 00.00
		return .f.
	endif
	//Fim do bloco de inserção de peso Pallet feito por Fabian Maurer 16/02/17

	if _nModo < 3
		SomErr()
		_Mens1 := ''
		_Mens2 := 'Modo de operação irregular!'
		oSayD1:SetText(_Mens1)
		oSayD2:SetText(_Mens2)
		oAut:refresh()
		return .f.
	endif

	if mv_par01 = 1//SE FOR PORTA PARALELA
		_cIP := ''
		u_GJF111d('S600','LPT1',_codigo, _produto,_cIp,_nGet2)
		//u_GJF111d('S600','LPT1',_codigo, _produto,_cIp)

	elseif mv_par01 = 2
		_cEst := getComputerName()
		dbselectarea('ZAM')
		ZAM->(dbSetOrder(2))
		if ZAM->(MsSeek(FWxFilial('ZAM') + alltrim(_cEst)))
			_cIp := alltrim(ZAM->ZAM_IP)
		endif
		//if alltrim(_cEst) == 'PAC01'
		//	_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM')+'IPAL2',1))
		//else
		//	_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP', FWxFilial('ZAM')+'IPAL1',1))
		//endif

		u_GJF111d('S600','IP',_codigo, _produto,_cIp,_nGet2)
		//u_GJF111d('S600','IP',_codigo, _produto,_cIp)
	endif

	/*if mv_par01 = 1    //se for LPT1
	_cIP := ''
	u_GJF111d('S600','LPT1',_codigo, _produto,_cIp)

	elseif mv_par01 = 2  //se for ip
	_cEst := getComputerName()
	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	if _cEst == 'CAMXX' //pc da camara que não tera impressora
	_cEst := 'CAMXX'
	endif

	if ZAM->(MsSeek(FWxFilial('ZAM') + _cEst))
	_cIp := alltrim(ZAM->ZAM_IP)
	endif

	if alltrim(_cEst) == 'PAC01'
	_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM')+'IPAL2',1))
	else
	_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM')+'IPAL1',1))
	endif

	u_GJF111d('S600','IP',_codigo, _produto,_cIp)
	endif   */

return


Static Function Confirmar()
	Local i
	_lPassou := .f.
	//Se for montagem
	if _nModo = 1

		if contar('TMP4','!empty(TMP4->NUMERO)') = 0
			return
		endif

		//Inicio do bloco de inserção de peso Pallet feito por Fabian Maurer 16/02/17
		_lInfo := infoPesP()

		if !_lInfo .or. _nGet2 <= 0
			MsgBox("Informe o Peso do Pallet", "ATENÇÃO!", "STOP")
			_cGet1 := space(11)
			_nGet2 := 00.00
			return
		endif
		//Fim do bloco de inserção de peso Pallet feito por Fabian Maurer 16/02/17

		//Bloco para validar a quantidade de caixas no pallet, se não estiver ok enviará um e-mail para o Sr. Matheus Silva
		_nTotCx  := contar('TMP4','!empty(TMP4->NUMERO)')
		_nTotPal := getMv('SI_MAXPAL')

		if _nTotCx > _MaxCx
			MsgBox("Pallet ultrapassou o limite de "+ alltrim(str(_MaxCx)) +" caixas!", "ATENÇÃO!", "STOP")
			return
		elseif _nTotCx < _MaxCx
			//if !msgBox("Pallet com menos de " + alltrim(str(_MaxCx)) + " caixas, deseja continuar?","MONTAGEM DE PALLETS","YESNO")
			//	return
			//endif
			_lPassou := .t.
		endif

		_codigo  := GetCod(_codigo)

		reclock('SZP',.t.)
		SZP->ZP_FILIAL  := FWxfilial('SZP')
		SZP->ZP_FIL     := cFilAnt
		SZP->ZP_DATA    := date() 
		//SZP->ZP_DATA    := date()+1
		SZP->ZP_COD     := _codigo
		SZP->ZP_PRODUTO := _produto
		SZP->ZP_TIPO    := iif(_nModo2 == 1,'PA','MP')
		msunlock()

		TMP4->(DbGoTop())
		while TMP4->(!eof())
			//SE FOR PALLET 'PA'
			if _nModo2 == 1
				SZ8->(DbSetOrder(3))
				if SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(TMP4->NUMERO)))

					reclock('SZ8',.f.)
					if cUserID = "000914"	// Usuário "inventario"
						SZ8->Z8_DATAS := stod("")
					endif
					SZ8->Z8_PALLET := _codigo
					SZ8->Z8_INV	   := 'X'
					SZ8->Z8_CHKCARR := ''
					SZ8->Z8_CHKPCAR := ''
					msunlock()

					u_gjf17his(3,'AGREGADO AO PALLET ' + _codigo,.f.,'','','000005',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

					//Procura por PA na ZAS (porcionados)
				elseif ZAS->(MsSeek(FWxfilial('ZAS')+alltrim(TMP4->NUMERO)))

					//inclui na SZ8 como PA
					SZ8->(DbSetOrder(3))
					if !SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(TMP4->NUMERO)))

						SB1->(DbSetOrder(1))
						SB1->(MsSeek(FWxfilial('SB1')+ZAS->ZAS_COD))

						reclock('SZ8',.t.)
						if cUserID = "000914"	// Usuário "inventario"
							SZ8->Z8_DATAS := stod("")
						endif
						SZ8->Z8_FILORI    := cFilAnt
						SZ8->Z8_FIL       := cFilAnt
						SZ8->Z8_FILIAL    := FWxfilial('SZ8')
						SZ8->Z8_ID        := substr(ZAS->ZAS_CONTRO,3,8)
						SZ8->Z8_CONTROL   := ZAS->ZAS_CONTRO
						SZ8->Z8_CODORI    := ZAS->ZAS_COD
						SZ8->Z8_COD       := ZAS->ZAS_COD
						SZ8->Z8_DATA      := ZAS->ZAS_DTPROD
						SZ8->Z8_DATAP     := ZAS->ZAS_DTPROD
						SZ8->Z8_HORA      := ZAS->ZAS_HORA//time()
						SZ8->Z8_TIPO      := 'P'
						SZ8->Z8_TF        := 'N'
						SZ8->Z8_QUANT     := SB1->B1_QTBCAIX
						SZ8->Z8_PESO      := ZAS->ZAS_PESOL
						SZ8->Z8_TARA      := ZAS->ZAS_TARA
						SZ8->Z8_PESOBR    := ZAS->ZAS_PESOB
						SZ8->Z8_ETIQ      := 'P'
						SZ8->Z8_DATAVAL   := ZAS->ZAS_DTPROD + SB1->B1_VALID
						SZ8->Z8_DESCRI    := SB1->B1_DESCRED
						SZ8->Z8_DTENTES   := date()
						SZ8->Z8_LOTEPOR   := ZAS->ZAS_LOTE
						SZ8->Z8_BATEL     := ZAS->ZAS_BATEL
						SZ8->Z8_PALLET    := _codigo
						SZ8->Z8_PREPORC   := ZAS->ZAS_PREPOR
						SZ8->Z8_NUMPREV   := ZAS->ZAS_PREEMB
						SZ8->Z8_PREDES    := ZAS->ZAS_PREDES
						SZ8->Z8_INV 	  := 'X'
						SZ8->Z8_PESFIX    := ZAS->ZAS_PESFIX
						SZ8->Z8_ORIGEM    := 'P'
						SZ8->Z8_BALAN     := ZAS->ZAS_LIN
						SZ8->Z8_SETPRO    := ZAS->ZAS_SETPRO
						SZ8->Z8_FARM      := ZAS->ZAS_FARM
						SZ8->Z8_CHKCARR   := ''
						SZ8->Z8_CHKPCAR   := ''
						msunlock()

						SZW->(dbsetorder(2))
						SZW->(DbGoTop())
						if SZW->(Msseek(FWxfilial('SZW') + alltrim(ZAS->ZAS_CONTRO)))
							reclock('SZW',.f.)
							SZW->ZW_HORAS   := time()
							SZW->ZW_DATAS   := date()
							SZW->ZW_OPERA   := cUserName
							msunlock()
						endif

						ZAU->(DbSetOrder(1))
						if ZAU->(MsSeek(FWxfilial('ZAU')+SZ8->Z8_LOTEPOR))
							reclock('ZAU',.f.)
							ZAU->ZAU_QRPESF += SZ8->Z8_PESO
							ZAU->ZAU_QRCAIF++

							if ZAU->ZAU_QRPESF >= ZAU->ZAU_QPPESO
								ZAU->ZAU_STATUS := 'E'
								ZAU->ZAU_WFW    := 'E'
								ZAU->ZAU_STATT  := 'E'
							endif
							msunlock()
						endif
						//u_gjf17his(1,'PROD.PORCION.',.f.,'','','000006',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
						u_gjf17his(3,'AGREG.PALLET ' + _codigo,.f.,'','','000005',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

						reclock('ZAS',.f.)
						DbDelete()
						msunlock()

						//Registra na ZAS a paletização do PA encontrado
						//reclock('ZAS',.f.)

						//msunlock()
					endif
				endif
			else
				ZAS->(DbSetOrder(1))
				if ZAS->(MsSeek(FWxfilial('ZAS')+alltrim(TMP4->NUMERO)))

					reclock('ZAS',.f.)
					ZAS->ZAS_PALLET := _codigo
					msunlock()

				endif
			endif
			TMP4->(DbSkip())
		enddo

		ExecSom()

		if mv_par01 = 1//se for paralela
			_cIP := ''
			u_GJF111d('S600','LPT1',_codigo, _produto,_cIp,_nGet2)
			//u_GJF111d('S600','LPT1',_codigo, _produto,_cIp)
		elseif mv_par01 = 2
			_cEst := getComputerName()
			dbselectarea('ZAM')
			ZAM->(dbSetOrder(2))
			if ZAM->(MsSeek(FWxFilial('ZAM') + alltrim(_cEst)))
				_cIp := alltrim(ZAM->ZAM_IP)
			endif
			//if alltrim(_cEst) == 'PAC01'
			//	_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM')+'IPAL2',1))
			//else
			//	_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP', FWxFilial('ZAM')+'IPAL1',1))
			//endif

			u_GJF111d('S600','IP',_codigo, _produto,_cIp,_nGet2)
			//u_GJF111d('S600','IP',_codigo, _produto,_cIp)
		endif

		dbSelectArea('SB1')
		_cDescri := GetAdvFVal('SB1','B1_DESCRED',FWxFilial('SB1') + alltrim(_produto),1)

		if _lPassou
			// Dia 26/09 - Matheus não quer mais receber e-mail da montagem de Pallet - Só comentei para ele não receber  - Flávio
			//enviaEmail(_codigo,_produto,_nTotCx,_cDescri)
		endif

		_codigo  := getCod('')
		_produto := ''
		_caixa   := space(11)
		_Mens1 := 'Pallet ' + SZP->ZP_COD + ' Montado!'
		_Mens2 := ''
		oSayD1:SetText(_Mens1)
		oSayD2:SetText(_Mens2)
	endif

	//Se for desmontagem
	if _nModo = 2

		_aCaixas := {}
		//	i := 1

		SZP->(DbSetOrder(1))
		if SZP->(MsSeek(FWxfilial('SZP')+alltrim(_codigo)))
			TMP4->(DbGoTop())

			//while para separar as caixas...
			while TMP4->(!eof())
				//Se for PA...
				if SZP->ZP_TIPO == 'PA'
					SZ8->(DbSetOrder(3))
					if SZ8->(MsSeek(FWxfilial('SZ8') + TMP4->NUMERO)) .and. SZ8->Z8_PALLET = SZP->ZP_COD
						aadd(_aCaixas,SZ8->Z8_CONTROL)
					endif

					//Se for MP...
				elseif SZP->ZP_TIPO == 'MP'
					ZAS->(DbSetOrder(1))
					if ZAS->(MsSeek(FWxfilial('ZAS') + TMP4->NUMERO)) .and. ZAS->ZAS_PALLET = SZP->ZP_COD
						//alert(ZAS->ZAS_CONTRO)
						aadd(_aCaixas,ZAS->ZAS_CONTRO)
					endif
				endif

				TMP4->(DbSkip())
			enddo

			//Laço para fazer a desvinculação das caixas
			For i := 1 to len(_aCaixas)

				//Se for PA...
				if _cTipoP = 'PA'
					SZ8->(DbSetOrder(3))
					if SZ8->(MsSeek(FWxfilial('SZ8') + _aCaixas[i]))

						reclock('SZ8',.f.)
						if cUserID = "000914"	// Usuário "inventario"
							SZ8->Z8_DATAS := stod("")
						endif
						SZ8->Z8_LOCALIZ := ''
						SZ8->Z8_PALLET  := ''
						SZ8->Z8_INV	    := ''
						SZ8->Z8_CHKCARR := ''
						SZ8->Z8_CHKPCAR := ''
						msunlock()

						u_gjf17his(3,'PALLET ' + _codigo + ' DESMONTADO',.f.,'','','000007',SZ8->Z8_CONTROL)
					endif

					//Se for MP...
				elseif _cTipoP = 'MP'

					ZAS->(DbSetOrder(1))
					if ZAS->(MsSeek(FWxfilial('ZAS') + _aCaixas[i]))

						reclock('ZAS',.f.)
						ZAS->ZAS_LOCALIZ := ''
						ZAS->ZAS_PALLET  := ''
						msunlock()

					endif
				endif

			next

			reclock('SZP',.f.)
			DbDelete()
			msunlock()

			_produto  := ''
			_NrCaix   := 0
			_cLocaliz := ''
			_caixa    := space(11)
			_Mens1 	 := ''
			_Mens2 	 := 'Pallet ' + SZP->ZP_COD + ' Desmontado!'
			oSayD1:SetText(_Mens1)
			oSayD2:SetText(_Mens2)
		endif
	endif

	HabBrow()

	cpo8:refresh()
	cpo9:refresh()
	cpo10:refresh()
	cpo11:refresh()
	cpo12:refresh()
	cpo13:setfocus()
	oBrow4:oBrowse:refresh()
	oAut:refresh()

return

//Funções de Som
static function ExecSom()
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)
return

Static Function SomErr()
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
return

//Função que limpa o browse
//executada nas operações de mudança
//de modo de operação e na conclusão
//de uma operação
Static Function HabBrow()
	_aArqTrb := {}

	//If Select("TMP4") != 0
	//	TMP4->(DbCloseArea())
	//	dbcreate(cArq,aStru)
	//	dbUseArea( .T.,,cArq,"TMP4", .F. , .F. )
	//	TMP4->(DbGotop())

	//	_Caixa  := space(11)
	//	_cTipoC := ''

	//	cpo13:SetFocus()
	//	cpo8:refresh()
	//	oBrow4:oBrowse:refresh()
	//	oAut:refresh()
	//Endif

	If Select('TMP4')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP4->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)

		U_ArqTrb("Cria", "TMP4", aStru, {}, @_aArqTrb)
		TMP4->(DbGotop())

		_Caixa  := space(11)
		_cTipoC := ''

		cpo13:SetFocus()
		cpo8:refresh()
		oBrow4:oBrowse:refresh()
		oAut:refresh()
	Endif

return

//Função executada no botão Cancelar
Static Function Cancelar()

	HabBrow()

	_Mens1 := ''
	_Mens2 := ''

	oSayD1:SetText(_Mens1)
	oSayD2:SetText(_Mens2)

	cpo10:refresh()
	oBrow4:oBrowse:refresh()
	oAut:refresh()

Return

//Função que trata o novo codigo de um pallet
Static Function GetCod(_cod)

	if empty(_cod)
		_cod := getSX8Num('SZP','ZP_COD')
		confirmSX8()
	endif

	if _nModo2 = 1
		_cod := 'PA' + substr(_cod,3,8)
	else
		_cod := 'MP' + substr(_cod,3,8)
	endif

	cpo8:refresh()
	cpo10:refresh()
	cpo11:refresh()
	oBrow4:oBrowse:refresh()
	oAut:refresh()

Return _cod

//Função executada na mudança dos modos de operação (Radio Button)
Static Function Modos()

	HabBrow()

	_NrCaix := contar('TMP4','!empty(TMP4->NUMERO)')

	_Mens1 := ''
	_Mens2 := ''

	oSayD1:SetText(_Mens1)
	oSayD2:SetText(_Mens2)

	if _nModo = 1
		RollBackSX8()
		_Codigo := GetCod()
	elseif _nModo = 2 .or. _nModo = 3
		_Codigo := ''
	endif

	cpo8:refresh()
	cpo10:refresh()
	cpo11:refresh()
	oBrow4:oBrowse:refresh()
	oAut:refresh()

Return

Static Function ModSeq()
	if _nModSeq = 1
		_Caixa := space(11)
	elseif _nModSeq = 2
		_Caixa := space(15)
	endif

	cpo9:refresh()
	oAut:refresh()
return

Static Function TrataTipo(_cod)

	HabBrow()

	if _nModo2 = 1
		_cod := 'PA' + substr(_cod,3,8)
	else
		_cod := 'MP' + substr(_cod,3,8)
	endif

	_cTipoC  := ''
	_Produto := ''

	cpo8:refresh()
	cpo10:refresh()
	cpo11:refresh()
	oBrow4:oBrowse:refresh()
	oAut:refresh()

return _cod

//pallet, pro,tot,usuario
Static Function enviaEmail(_num,_prod,_totCaixas,_descri)
	Local i
	_cDest    := "matheus@bestbeef.com.br"
	//_cDest    := "mauricio.lopes@frigorificosilva.com.br"
	_Usuar    := cUserName
	_cEst     := getComputerName()

	_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
	_cMens += 'Na data e hora da emissão deste email, o pallet abaixo foi montado com menos de '+alltrim(str(_MaxCx))+' caixas:' + chr(13) + chr(10)
	_cMens +=   chr(13) + chr(10)
	_cMens += 'Pallet nr.: ' + alltrim(_Num) + chr(13) + chr(10)
	_cMens += 'Cod.Produto: ' + _prod + chr(13) + chr(10)
	_cMens += 'Descri.Produto: ' + _descri + chr(13) + chr(10)
	_cMens += 'Total de caixas no Pallet: ' + str(_totCaixas) + chr(13) + chr(10)
	_cMens += 'Responsável pela montagem: ' + _Usuar + chr(13) + chr(10)
	_cMens += 'Estação de Trabalho: ' + _cEst + chr(13) + chr(10)

	_cTit  := 'Workflow Frigorífico Silva: Aviso do Pallet: ' + alltrim(_Num) +  ', montado com menos de ' +alltrim(str(_MaxCx)) +' caixas

	_aEmail := u_GJF54(_cMens,_cTit,_cDest)

	for i := 1 to len(_aEmail)
		if !_aEmail[i]
			alert('ERRO WORKFLOW ('+ str(i) +')')
		endif
	next

return

//Bloco feito por Fabian Maurer dia 16/02/17 para inserção do peso do pallet
Static Function infoPesP()

	local _lOk := .f.

	DEFINE MSDIALOG oDlg2 TITLE 'Peso do Pallet' from 000,000 To 100,250 PIXEL
	@ 010,002 SAY  'Peso Pallet:' Object oSayPes
	@ 010,035 GET _nGet2 PICTURE "@E 99.99" SIZE 30,6  VALID !empty(_nGet2) .and. _nGet2 > 0 Object oGet2
	@ 010,95 BMPBUTTON TYPE 1 ACTION (_lOk := .t.,odlg2:end()) Object ObtnPes1
	ACTIVATE MSDIALOG oDlg2 CENTERED

Return _lOk
//Fim do bloco feito por Fabian Maurer dia 16/02/17 para inserção do peso do pallet
