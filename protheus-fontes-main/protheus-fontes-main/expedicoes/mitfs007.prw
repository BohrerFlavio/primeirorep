#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"


/*/{Protheus.doc} User Function mitfs007
	(Aplicação para micro-terminais para realizar validação do que está dentro do caminhão, fisicamente,
	com o que foi escaneado pelo balanceiro na doca)
	@type  Function
	@author Mauricio Roehrs
	@since 28/04/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

User Function mitfs007(_usuario)

	Private _cModelo  	:= ''
	Private _lOk      	:= .t.
	Private _lOk2     	:= .t.
	Private _lExecuta 	:= .t.
	Private _lExecCons  := .t.
	Private _cCod 	   	:= ''
	Private lin 		:= 1
	Private _nSomaPeso  := 0
	Private _cUser    	:= _usuario
	Private _cPar01   	:= '0'    //1- Separa | 2 - Consulta
	Private cArq  		:= CriaTrab( Nil, .F. )
	Private _nCont 		:= 0
	Private lChkcarr	:= .F.
	Private lChkPall	:= .F.
	//Private _cCliPal	:= alltrim(GETMV('SI_CLIPALL'))
	//Private _lCliPal	:= .F.

	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL28 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif

	//Define o tamanho da Tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	while _lOk

		@ 01,05 VTSay "SEPARACAO DE CAIXAS/PA"
		@ 02,05 VTSay "Parametros Iniciais:"
		@ 04,00 VTSay "OPERACAO:     [ ]"
		@ 05,00 VTSay "1 - Validar Caixas/PAs"
		@ 05,00 VTSay "2 - Validar Cxs/Bizerba"
		@ 15,00 VTSay "ESC para Sair"

		@ 04,15 VTGet _cPar01 Pict "@! "  valid (_cPar01 $ '12')

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		browCarr(_cPar01)

		VTClear()
		VTClearBuffer()

	enddo

Return


Static Function browCarr(_param01)

	_lOk2 := .t.

	VTClear()
	VTClearBuffer()

	geraArq()

	ARQ->(dbGoTop())

	aFields := {"NUMERO","DTCAR","OBS"}
	aHeader := {"NUMERO","DTCAR","OBS"}
	aSize   := {6,8,15}

	//mostra o grid na tela
	nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"ARQ",aHeader,aFields,aSize,"u_vtCarBrw",)
	VTClear()

	if _param01 $ '1/2' .and. _lExecuta
		validCx(ARQ->NUMERO, _param01)
	endif

	VTClear()
	VTClearBuffer()

return .f.


static function geraArq()

	cArq2  := CriaTrab( Nil, .F. )

	aStru2 := {}
	AADD(aStru2,{"NUMERO"     ,"C"	,6  ,0	})
	AADD(aStru2,{"DTCAR"  	  ,"D"	,8  ,0	})
	AADD(aStru2,{"OBS"  	  ,"C"	,15 ,0	})

	dbcreate(cArq2,aStru2)

	If Select('ARQ')<>0
		ARQ->(dbCloseArea())
	Endif

	dbUseArea( .T.,,cArq2,"ARQ", .F. , .F. )

	_cQuery4 := " SELECT ZZ3_NUM AS NUMERO, ZZ3_DTCAR AS DTCAR, ZZ3_OBS AS OBS"
	_cQuery4 += " FROM " + retSqlTab('ZZ3')
	_cQuery4 += " WHERE " + retSqlFil('ZZ3')
	_cQuery4 += " AND ZZ3_DTCAR BETWEEN '"+dtos(ddatabase-1)+"' AND '"+dtos(ddatabase)+"'"
	_cQuery4 += " AND ZZ3_STATUS NOT IN ('E','F')"
	_cQuery4 += " AND " + retSqlDel('ZZ3')
	_cQuery4 += " ORDER BY ZZ3_NUM"

	_cQuery4  := ChangeQuery(_cQuery4)

	If Select("QRY4") != 0
		QRY4->(dbCloseArea())
	Endif

	TCQUERY _cQuery4 NEW ALIAS "QRY4"

	QRY4->(dbGoTop())
	while QRY4->(!eof())

		reclock('ARQ',.t.)
		ARQ->NUMERO := QRY4->NUMERO
		ARQ->DTCAR  := STOD(QRY4->DTCAR)
		ARQ->OBS	:= QRY4->OBS
		msunlock()

		QRY4->(dbSkip())
	enddo

	aCampos := {}

	AADD(aCampos,{"NUMERO"	,, "Numero"		,"@!"   		})
	AADD(aCampos,{"DTCAR" 	,, "Dt. Car"	,"99/99/99"		})
	AADD(aCampos,{"OBS"		,, "Obs"		,"@!"			})

return

Static Function ValidCx(_cCarr, _cModo)

	VTClear()
	VTClearBuffer()

	geraTrab(_cCarr)
	Local _lOk2 := .t.
	_nCont := 0

	SZ8->(DbSetOrder(5))
	SZ8->(DbGoTop())
	SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + alltrim(_cCarr)))
	While SZ8->(!eof()) .and. SZ8->(Z8_FILIAL+Z8_FIL+Z8_PRECAR) = (FWxfilial('SZ8') + cFilAnt + alltrim(_cCarr))
		if alltrim(SZ8->Z8_USRVAL) = alltrim(_cUser)
			_nCont++
		endif
		SZ8->(DbSkip())
	end

	while _lOk2

		_cCod := iif(_cModo = '1', Space(11), Space(15))

		@ 01,05 VTSay "Validação de Caixas/PAs"
		@ 02,05 VTSay "Carreg.: [" +_cCarr + "]"
		@ 03,07 VTSay "Codigo da Caixa"
		if _cModo = '1'
			@ 04,08 VTSay "[           ]"
		else
			@ 04,08 VTSay "[               ]"
		endif
		@ 06,05 VTSay "Total -> " + cValToChar(_nCont)
		@ 15,00 VTSay "ESC para Sair"
		@ 04,09 VTGet _cCod Pict "@!" VALID leitura(_cCarr,_cCod, _cModo)

		VTRead
		if lChkcarr
			_nCont++
			lChkcarr := .F.
		endif

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		VTClearBuffer()
	enddo
	VTClear()
	VTClearBuffer()

Return

Static Function leitura(_preCar,_cod,_cModo)

	if empty(_cod)
		return .t.
	endif

	lChkPall := .F.

	if substr(_cod,1,2) = 'PA'

		if !fPallet(_cod)
			mensagem('Pallet não identificado!')
		else
			SZ8->(DbSetOrder(3))
			SZ8->(DbGoTop())
			QRY2->(DbGoTop())

			While QRY2->(!eof())

				if SZ8->(MsSeek(FWxfilial('SZ8') + alltrim(QRY2->Z8_CONTROL)))
					if !empty(SZ8->Z8_PRECAR) .and. SZ8->Z8_PRECAR <> _preCar
						reclock('SZ8',.F.)
						SZ8->Z8_CHKCARR := '1'
						SZ8->Z8_CHKPCAR := _preCar
						lChkPall := .T.
						msunlock()
					elseif !empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS) .and. _preCAR == SZ8->Z8_PRECAR
						reclock('SZ8',.F.)
						SZ8->Z8_USRVAL := _cUser
						SZ8->Z8_CHKCARR := '0'
						SZ8->Z8_CHKPCAR := _preCar
						msunlock()
					elseif empty(SZ8->Z8_PRECAR) .or. empty(SZ8->Z8_DATAS)
						reclock('SZ8',.F.)
						SZ8->Z8_CHKCARR := '2'
						SZ8->Z8_CHKPCAR := _preCar
						lChkPall := .T.
						msunlock()
					endif

					if empty(SZ8->Z8_USRVAL) .or. (alltrim(SZ8->Z8_USRVAL) <> alltrim(_cUser))
						_nCont++
					endif
				else
					mensagem('Pallet vazio!')
				endif

				QRY2->(DbSkip())
			enddo
			if lChkPall
				mensagem('Pallet contém caixas', 'carregadas incorretamente!')
				lChkPall := .F.
			else
				mensagem('Pallet Carregado Corretamente')
				lChkPall := .F.
			endif
		endif
	else
		if _cModo = '1'
			SZ8->(DbSetOrder(3))
		else
			SZ8->(DbSetOrder(28))
		endif
		SZ8->(dbGoTop())
		if !SZ8->(MsSeek(FWxFilial('SZ8')+alltrim(_cod))) .or. len(alltrim(_cod)) < 10
			mensagem('Caixa inexistente!')
			return .t.
		else
			if !empty(SZ8->Z8_PRECAR) .and. SZ8->Z8_PRECAR <> _preCar
				mensagem('CX carreg em outro carregamento: ' + SZ8->Z8_PRECAR)
				reclock('SZ8',.F.)
				SZ8->Z8_CHKCARR := '1'
				SZ8->Z8_CHKPCAR := _preCar
				msunlock()
				return .t.

			elseif !empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS) .and. _preCAR == SZ8->Z8_PRECAR
				mensagem('CX Carregada Corretamente')
				reclock('SZ8',.F.)
				if empty(SZ8->Z8_USRVAL) .or. (alltrim(SZ8->Z8_USRVAL) <> alltrim(_cUser))
					lChkcarr := .T.
				endif
				SZ8->Z8_USRVAL := _cUser
				SZ8->Z8_CHKCARR := '0'
				SZ8->Z8_CHKPCAR := _preCar
				msunlock()
				return .t.

			elseif empty(SZ8->Z8_PRECAR) .or. empty(SZ8->Z8_DATAS)
				mensagem('Atenção! Caixa em estoque!!')
				reclock('SZ8',.F.)
				SZ8->Z8_CHKCARR := '2'
				SZ8->Z8_CHKPCAR := _preCar
				msunlock()
				return .t.
			endif
		endif
	endif

return .t.

Static Function mensagem(_cMens,_cMens2)

	Local _branco := space(50)

	VTBeep(1)
	@lin+4,00 VTSay _branco
	@lin+5,00 VTSay _branco
	@lin+6,00 VTSay _branco
	@lin+7,00 VTSay _branco
	@lin+8,00 VTSay _branco
	@lin+9,00 VTSay _branco
	@lin+10,00 VTSay _branco

	@lin+4,11 VTSay _cCod
	@lin+6,03 VTSay _cMens
	@lin+7,03 VtSay _cMens2

	_cCod := Space(11)

return .f.

//função para gerar o ambiente de trabalho
Static Function geraTRAB(preCarr)

	cArq  := CriaTrab( Nil, .F. )

	aStru := {}
	AADD(aStru,{"COD"     ,"C"	,6  ,0	})
	AADD(aStru,{"QPCAIX"  ,"N"	,5  ,0	})

	dbcreate(cArq,aStru)

	If Select('TRB')<>0
		TRB->(dbCloseArea())
	Endif

	dbUseArea( .T.,,cArq,"TRB", .F. , .F. )

	filProd(preCarr)

	QRY->(dbGoTop())
	while QRY->(!eof())

		reclock('TRB',.t.)
		TRB->COD	 := QRY->ZZ5_COD
		TRB->QPCAIX  := QRY->PREVISTO
		msunlock()

		QRY->(dbSkip())
	enddo

	aCampos := {}

	AADD(aCampos,{"COD"  	,, "Prod."		,"@!"   			})
	AADD(aCampos,{"QPCAIX" 	,, "Previsto"	,"@E 999"		})

return

Static Function filProd(preCarr)

	_cQuery := " SELECT ZZ5_COD, SUM(ZZ5_QPCAIX) AS PREVISTO
	_cQuery += " FROM " + retSqlTab('ZZ5') + ", " + retSqlTab('ZZ4')
	_cQuery += " WHERE " + retSqlFil('ZZ5') + " AND " + retSqlFil('ZZ4')
	_cQuery += " AND ZZ4_PRECAR = '" + preCarr + "'
	_cQuery += " AND ZZ5_NUM = ZZ4_NUM
	_cQuery += " AND " + retSqlDel('ZZ5') + "  AND " + retSqlDel('ZZ4')
	_cQuery += " GROUP BY ZZ5_COD
	_cQuery += " ORDER BY ZZ5_COD
	_cQuery  := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

return

Static Function fPallet(_pallet)

	_lRet := .F.

	_cQuery2 := " SELECT Z8_CONTROL"
	_cQuery2 += " FROM " + retSqlTab('SZ8') 
	_cQuery2 += " INNER JOIN " + retSqlTab('ZZ6') + " ON (Z8_CONTROL = ZZ6_CONTRO)"
	_cQuery2 += " WHERE " + retSqlFil('SZ8') + " AND " + retSqlFil('ZZ6')
	_cQuery2 += " AND ZZ6_PALLET = '" + _pallet + "'"
	_cQuery2 += " AND " + retSqlDel('SZ8') + "  AND " + retSqlDel('ZZ6')
	_cQuery2  := ChangeQuery(_cQuery2)

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "QRY2"

	Count to nCount

    If nCount > 0
        _lRet := .T.
    endif

return _lRet
