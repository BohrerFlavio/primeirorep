#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF108     ºAutor  ³Giuliano Forgiariniº Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de Consulta de caixas de acordo com o período de     º±±
±±º          ³produção ou validade estipulado e o produto em si apontado  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Diversas rotinas                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF108()

	_dtIni      := ''
	_dtFim      := ''
	_dtValIni   := ''
	_dtValFim   := ''
	_dDataAbate := space(8)
	aStru 		:= {}

	if FunName() = 'GJF40'
		_prod    := TMP->CODIGO
		_dtValIni	:= date()
		_dtValFim	:= date() + mv_par07 
	elseif FunName() $ 'GJF28/GJF26/GJF52'
		_prod  	:= GDFieldGet('ZZ5_COD')
		_dtIni 	:= GDFieldGet('ZZ5_DTPINI')
		_dtFim 	:= GDFieldGet('ZZ5_DTPFIM') 
	elseif FunName() = 'GJF31'
		_prod  	:= alltrim(TMP->COD)
		_dtIni 	:= TMP->DTPINI
		_dtFim 	:= TMP->DTPFIM
	elseif FunName() = 'DTI85'
		_prod  	:= GDFieldGet('ZZV_COD')
	endif

	cQuery := " SELECT Z8_CONTROL AS CONTROL,Z8_COD AS COD, Z8_DESCRI AS DESCRI, "
	cquery += " Z8_DATAP AS DATAP, Z8_QUANT AS QUANT, Z8_DATAVAL AS DATAVAL, Z8_PESO AS PESO,Z8_PREDES AS PREDES" 
	cQuery += " FROM " + RetSqlName("SZ8") + " SZ8" 
	cQuery += " WHERE SZ8.D_E_L_E_T_ <> '*' AND SZ8.Z8_COD = '" + alltrim(_prod) + "'"
	cQuery += " AND SZ8.Z8_DATAS = '' AND SZ8.Z8_HORAS = '' AND SZ8.Z8_PREPED = '' AND SZ8.Z8_ENCONTR <> 'N' "
	cQuery += " AND SZ8.Z8_PRECAR = '' AND SZ8.Z8_ITEM = '' AND SZ8.Z8_FIL = '" + cFilAnt + "'"
	if !empty(_dtIni) .and. !empty(_dtFim)
		cQuery += " AND (SZ8.Z8_DATAP BETWEEN '" + dtos(_dtIni) + "' AND '" + dtos(_dtFim)+"')"  
	endif
	if !empty(_dtValIni) .and. !empty(_dtValFim)
		cQuery += " AND (SZ8.Z8_DATAVAL BETWEEN '" + dtos(_dtValIni) + "' AND '" + dtos(_dtValFim)+"')" 
	endif
	cQuery += " ORDER BY Z8_DATAP"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery := ChangeQuery(cQuery)

	//memowrite("ZZZ_GJF108.TXT",cQuery)

	If Select("PRO")<>0
		PRO->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "PRO"

	area := getarea()

	//dbSelectarea('PRO')

	aStru := dbStruct()
	aadd(aStru,{"DTV"    , "D",  8, 0,   "" , 'Data Val.'  })
	aadd(aStru,{"DTA"    , "D",  8, 0,   "" , 'Data Abate' })
	aadd(aStru,{"DTP"    , "D",  8, 0,   "" , 'Data Prod.' })

	_aArqTrb    := {}

	//dbcreate(cArq,aStru)
	If Select('TMPP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMPP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	// ProcData 04/2023 - Chamada para criar arquivo de trabalho
	U_ArqTrb("Cria", "TMPP", aStru, {}, @_aArqTrb)

	//If Select("TMPP")!=0                                  //Se um tmp com alias TMP existir, fecha-o
	//	TMPP->(dbCloseArea())
	//Endif

	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMPP", .F. , .F. )
	//DbSelectArea('TMPP')

	_nTotPeso := 0
	_nTotCaix := 0
	PRO->(dbGoTop())
	while PRO->(!eof())
		// Inclusão feita por Flávio  para busca da data do Abate
		//_dDtAbt  := fBuscaCPO('SZ2',2,FWxfilial('SZ2')+PRO->PREDES,'Z2_DATAABT')
		_dDtAbt  := GetAdvFVal("SZ2", "Z2_DATAABT", FWxFilial("SZ2") + PRO->PREDES, 2, Space(TamSx3("Z2_DATAABT")[1]), .T.)

		DbSelectArea('TMPP')
		reclock("TMPP",.t.)
		TMPP->CONTROL  := PRO->CONTROL
		TMPP->COD      := PRO->COD
		TMPP->DESCRI   := PRO->DESCRI

		If !empty(_dDtAbt) // buscar a data do abate da SZ2 ()
			TMPP->DTA   := _dDtAbt
		else
			TMPP->DTA   := STOD('')
		endif

		TMPP->DTP      := STOD(PRO->DATAP)
		TMPP->QUANT    := PRO->QUANT
		TMPP->DTV      := STOD(PRO->DATAVAL)
		TMPP->PESO     := PRO->PESO
		msunlock()

		_nTotPeso += PRO->PESO
		_nTotCaix++

		PRO->(dbskip())
	enddo

	aCampos := {}

	aadd(aCampos,{"CONTROL" ,"Caixa    " ,""   })
	aadd(aCampos,{"COD"     ,"Prod.    " ,"@!" })
	aadd(aCampos,{"DESCRI"  ,"Descricao" ,"@!" })
	aadd(aCampos,{"DTA"     ,"Dt.Abate " ,"@!" })// Inclusão feita por Flávio 
	aadd(aCampos,{"DTP"     ,"Dt.Prod. " ,"@!" })
	aadd(aCampos,{"QUANT"   ,"Quant.   " ,""   })
	aadd(aCampos,{"DTV"     ,"Dt.Valid." ,""   })
	aadd(aCampos,{"PESO"    ,"Peso     " ,""   })

	TMPP->(dbgotop())

	DEFINE MSDIALOG oCon from 00,00 to 240,835 PIXEL TITLE 'Consulta Caixas Estoque'

	@ 005,005 To 90,420 Browse "TMPP"  fields aCampos object oiBrowse
	@ 008,005 say 'Total de Caixas: ' + transform(_nTotCaix,'@E 999,999')
	@ 008,030 say 'Total de Peso: '   + transform(_nTotPeso,'@E 999,999,999.99')

	@ 100,350  BUTTON oBtn PROMPT 'Sair' OF oCon PIXEL ACTION oCon:end()
	ACTIVATE MSDIALOG oCon

	//dbclosearea("TMPP")
	//dbclosearea('PRO')

	/*If Select("PRO")<>0
		PRO->(dbCloseArea())
	Endif
	If Select('TMPP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMPP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif*/
	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho

return
