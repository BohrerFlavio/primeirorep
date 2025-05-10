#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³mrVt15     º Autor ³Mauricio Roehrsº   Data ³  03/01/17     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ picking de caixas para carregamento			              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function mrVT15(_usuario)

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
	Private _aCodList	:= {}
	Private _cSeq 		:= '0'

	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL19 <> 'S'
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

		@ 01,05 VTSay "SEPARACAO DE CAIXAS"
		@ 02,05 VTSay "Parametros Iniciais:"
		@ 04,00 VTSay "OPERACAO:     [ ]"
		@ 05,00 VTSay "1 - Separar"
		@ 06,00 VTSay "2 - Consultar"
		@ 07,00 VTSay "3 - Estornar"
		@ 15,00 VTSay "ESC para Sair"

		@ 04,15 VTGet _cPar01 Pict "@! "  valid (_cPar01 $ '123')

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


	if _param01 == '1' .and. _lExecuta
		selecao(ARQ->NUMERO, 1)
	elseif _param01 == '2' .and. _lExecuta
		consultar(ARQ->NUMERO)
	elseif _param01 == '3' .and. _lExecuta
		selecao(ARQ->NUMERO, 2)
	endif

	VTClear()
	VTClearBuffer()

return .f.


static function geraArq()

	//cArq2  := CriaTrab( Nil, .F. )
	_aArqTrb := {}

	aStru2 := {}
	AADD(aStru2,{"NUMERO"     ,"C"	,6  ,0	})
	AADD(aStru2,{"DTCAR"  	  ,"D"	,8  ,0	})
	AADD(aStru2,{"OBS"  	  ,"C"	,15 ,0	})

	//dbcreate(cArq2,aStru2)
	//If Select('ARQ')<>0
	//	ARQ->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArq2,"ARQ", .F. , .F. )

	If Select('ARQ')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		ARQ->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "ARQ", aStru2, {}, @_aArqTrb)

	_cQuery4 := " SELECT ZZ3_NUM AS NUMERO, ZZ3_DTCAR AS DTCAR, ZZ3_OBS AS OBS"
	_cQuery4 += " FROM " + retSqlTab('ZZ3')
	_cQuery4 += " WHERE " + retSqlFil('ZZ3')
	_cQuery4 += " AND ZZ3_DTCAR BETWEEN '"+dtos(ddatabase-1)+"' AND '"+dtos(ddatabase+1)+"'"
	_cQuery4 += " AND ZZ3_STATUS NOT IN ('E','F') AND ZZ3_STPCK<>'B'"
	_cQuery4 += " AND " + retSqlDel('ZZ3')
	_cQuery4 += " ORDER BY ZZ3_NUM"

	_cQuery4  := ChangeQuery(_cQuery4)

	If Select("QRY4") != 0
		QRY4->(dbCloseArea())
	Endif

	TCQUERY _cQuery4 NEW ALIAS "QRY4"

	QRY4->(dbGoTop())
	while QRY4->(!eof())
		DbSelectArea('ARQ')
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

Static Function selecao(_cCarr, _Modo)

	VTClear()
	VTClearBuffer()

	_lOk2 := verStat(_cCarr,2)

	if !_lOk2
		VTAlert('Carreg. Bloq. p/ Separar!','Aviso de Encerramento(01)',.T.,2500,1)
	else
		while _lOk2

			@ 01,05 VTSay "Selecione o modo:"
			@ 02,00 VTSay "1 - Caixas Padrão"
			@ 03,00 VTSay "2 - Caixas Bizerba"
			@ 04,00 VTSay "OPERACAO:     [ ]"
			@ 15,00 VTSay "ESC para Sair"

			@ 04,15 VTGet _cSeq Pict "@! " valid (_cSeq $ '12')

			VTRead

			If (VTLastKey() == 27)
				VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
				exit
			EndIF

			if _Modo = 1
				separar(_cCarr, _cSeq)
			else
				estornar(_cCarr, _cSeq)
			endif

		enddo
	endif
	VTClear()
	VTClearBuffer()

Return

Static Function separar(_cCarr, _cSeq)

	VTClear()
	VTClearBuffer()

	regUser(_cCarr,1)
	_lOk2 := verStat(_cCarr,2)

	geraTrab(_cCarr)

	if !_lOk2
		VTAlert('Carreg. Bloq. p/ Separar!','Aviso de Encerramento(01)',.T.,2500,1)
	else
		regStat(_cCarr,1)
		while _lOk2

			if _cSeq = '1'
				_cCod := Space(11)
			else
				_cCod := Space(14)
			endif

			@ 01,05 VTSay "Separacao de Caixas"
			@ 02,05 VTSay "Carreg.: [" +_cCarr + "]"
			@ 03,07 VTSay "Codigo da Caixa/Pallet"
			if _cSeq = '1'
				@ 04,08 VTSay "[           ]"
			else
				@ 04,08 VTSay "[               ]"
			endif
			@ 15,00 VTSay "ESC para Sair"
			@ 04,09 VTGet _cCod Pict "@!" VALID leitura(_cCarr,_cCod, _cSeq)

			VTRead

			If (VTLastKey() == 27)
				VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
				regUser(_cCarr,2)
				regStat(_cCarr,2)
				exit
			EndIF

			VTClearBuffer()
		enddo
	endif
	VTClear()
	VTClearBuffer()

Return

Static Function estornar(_cCarr, _cSeq)

	VTClear()
	VTClearBuffer()

	_lOk2 := verStat(_cCarr,2)

	if !_lOk2
		VTAlert('Carreg. Bloq. ou em Separacao!!','Aviso de Encerramento(01)',.T.,2500,1)
	else
		regStat(_cCarr,1)
		while _lOk2

			if _cSeq = '1'
				_cCod := Space(11)
			else
				_cCod := Space(14)
			endif

			@ 01,05 VTSay "Estorno de Caixas"
			@ 02,05 VTSay "Carreg.: [" +_cCarr + "]"
			@ 03,07 VTSay "Codigo da Caixa/Pallet"
			if _cSeq = '1'
				@ 04,08 VTSay "[           ]"
			else
				@ 04,08 VTSay "[               ]"
			endif
			@ 15,00 VTSay "ESC para Sair"
			@ 04,09 VTGet _cCod Pict "@!" VALID leitEstor(_cCarr,_cCod,_cSeq)//leitura do estorno

			VTRead

			If (VTLastKey() == 27)
				VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
				regUser(_cCarr,2)
				regStat(_cCarr,2)
				exit
			EndIF

			VTClearBuffer()
		enddo

	endif
	VTClear()
	VTClearBuffer()

Return


static function consultar(_cCarr)

	geraTrab(_cCarr)

	aFields := {"COD","QPCAIX","QRCAIX"}
	aHeader := {"PROD","PREVISTO","REALIZ"}
	aSize   := {6,5,5}

	dbselectarea('TRB')

	TRB->(dbgotop())

	//mostra o grid na tela
	nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"TRB",aHeader,aFields,aSize,"u_vtConBrw",)

	if _lExecCons
		showDatas(_cCarr,TRB->COD)
	endif

	VTClear()
	VTClearBuffer()

return


Static Function filProd(preCarr)

	_cQuery := " SELECT ZZ5_COD, SUM(ZZ5_QPCAIX) AS PREVISTO"
	_cQuery += " FROM " + retSqlTab('ZZ5') + ", " + retSqlTab('ZZ4')// + " , " + retSqlTab('SB1')
	_cQuery += " WHERE " + retSqlFil('ZZ5') + " AND " + retSqlFil('ZZ4') //+ " AND " + retSqlFil('SB1')
	_cQuery += " AND ZZ4_PRECAR = '" + preCarr + "'
	_cQuery += " AND ZZ5_NUM = ZZ4_NUM"
	//_cQuery += " AND B1_COD = ZZ5_COD AND B1_SEGUM = 'CX'
	_cQuery += " AND " + retSqlDel('ZZ5') + "  AND " + retSqlDel('ZZ4') //+" AND " + retSqlDel('SB1')
	_cQuery += " GROUP BY ZZ5_COD"
	_cQuery += " ORDER BY ZZ5_COD"
	_cQuery  := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

return


Static Function filPicking(preCarr,_cod)

	_cQuery2 := " SELECT COUNT(Z8_PICKING) AS SEPARADO"
	_cQuery2 += " FROM " + retSqlTab('SZ8')
	_cQuery2 += " WHERE " + retSqlFil('SZ8')
	_cQuery2 += " AND Z8_CARPICK = '" + preCarr + "' AND Z8_FIL = '"+cFilAnt+"'"
	_cQuery2 += " AND Z8_COD = '" + _cod + "' AND Z8_PICKING = 'S'"
	_cQuery2 += " AND " + retSqlDel('SZ8')

	_cQuery2  := ChangeQuery(_cQuery2)

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "QRY2"

	QRY2->(dbGoTop())

return iif(QRY2->SEPARADO > 0, QRY2->SEPARADO, 0)


Static Function leitura(_preCar,_cod,_cSeq)

	Local _lProd 	 := .f.
	Local _nNumCaix := 0
	Local _nMaxCaix := 0

	if _cSeq = '1'
		_nMaxCaix := 10
	else
		_nMaxCaix := 14
	endif

	if empty(_cod)
		return .t.
	endif

	_lSt := verStat(_preCar,1)

	if !_lSt
		VTAlert('Carreg. Bloq. para Separacao!!','Aviso de Encerramento(01)',.T.,2500,1)
		_lOk2 := .f.
		return .t.
	endif

	if substr(alltrim(_cod),1,2) = 'PA' //se for pallet
		_nNumCaix := 0
		SZP->(dbSetOrder(1))
		SZP->(dbGoTop())
		if !SZP->(MsSeek(FWxfilial('SZP') + alltrim(_cod))) .or. len(alltrim(_cod)) < 10
			mensagem('Pallet inexistente!',,.T.)
			return .t.
		else
			SZ8->(DbSetOrder(19))
			if !SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + alltrim(_cod)))
				mensagem('Caixas não encontradas no Pallet!',,.T.)
				return .t.
			else
				//percorre as caixas do pallet para verificar a quantidade de caixas no mesmo
				While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and. SZ8->Z8_FIL = cFilAnt .and. SZ8->Z8_PALLET = alltrim(_cod)
					if empty(SZ8->Z8_CARPICK)
						_nNumCaix++
					endif
					if !empty(SZ8->Z8_CARPICK)
						mensagem('Erro!','Ja ha CXs. separadas no Pallet!',.T.)
						return .t.
					endif
					SZ8->(DbSkip())
				enddo

				_lProd := findProd(_preCar,SZP->ZP_PRODUTO) //verifica se o produto escaneado faz parte do carregamento

				if _lProd
					//fazer função para comparar as quantidades do previsto com o separado
					geraTrab(_preCar)//gera o arquivo de trabalho
					TRB->(dbGoTop())
					IndRegua("TRB",cArq,"COD",,,'')//faz um indice temporario com o codigo do produto
					Msseek(SZP->ZP_PRODUTO,.t.)//posiciona
					if found()//se encontrar
						if _nNumCaix > TRB->QPCAIX
							mensagem('Pallet possui mais CXs que o previsto!',,.T.)
							return .t.
						endif
						if TRB->QRCAIX + _nNumCaix > TRB->QPCAIX
							mensagem('Excedeu o numero de caixas previstas!',,.T.)
							return .t.
						endif
						if TRB->QRCAIX >= TRB->QPCAIX//compara o realizado com o previsto
							mensagem('Limite de CXs ja atingido!',,.T.)
							return .t.
						else
							separa(SZP->ZP_COD,_preCar)
							mensagem('Pallet: ' + SZP->ZP_COD + ' separado!',,.F.)
						endif
					endif
				else
					mensagem('Prod. nao pertence ao carreg.',,.T.)
					return .t.
				endif

			endif

		endif

	else //senão é caixa

		if len(alltrim(_cod)) < _nMaxCaix
			mensagem('Erro de leitura!',,.T.)
			return .t.
		endif

		if _cSeq = '1'
			SZ8->(DbSetOrder(3))
		else
			SZ8->(dbSetOrder(28))
		endif
		SZ8->(dbGoTop())

		if !SZ8->(MsSeek(FWxFilial('SZ8')+alltrim(_cod)))
			mensagem('Caixa fora de estoque!',,.T.)
			return .t.
		else
			if !empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS)
				mensagem('Caixa fora de estoque!',,.T.)
				return .t.
			endif

			if !empty(SZ8->Z8_CARPICK)
				mensagem('Erro!','Cx ja separ. p/ carr:'+SZ8->Z8_CARPICK,.T.)
				return .t.
			endif

			_lProd := findProd(_preCar,SZ8->Z8_COD) //verifica se o produto escaneado faz parte do carregamento

			if _lProd
				//fazer função para comparar as quantidades do previsto com o separado
				//geraTrab(_preCar)//gera o arquivo de trabalho
				TRB->(dbGoTop())
				IndRegua("TRB",cArq,"COD",,,'')//faz um indice temporario com o codigo do produto
				Msseek(SZ8->Z8_COD,.t.)//posiciona
				if found()//se encontrar

					if TRB->QRCAIX >= TRB->QPCAIX//compara o realizado com o previsto
						mensagem('Limite de CXs ja atingido!',,.T.)
						return .t.
					else
						separa(SZ8->Z8_CONTROL,_preCar)
						mensagem('Caixa: ' + SZ8->Z8_CONTROL + ' separada!',,.F.)
					endif
				endif
			else
				mensagem('Prod. nao pertence ao carreg.',,.T.)
				return .t.
			endif

		endif

	endif

return .t.


//Função de validação de leitura da caixa no estorno
Static Function leitEstor(_preCar,_cod,_cSeq)

	//local _lProd := .f.
	Local _nMaxCaix := 0

	if _cSeq = '1'
		_nMaxCaix := 10
	else
		_nMaxCaix := 14
	endif

	if empty(_cod)
		return .t.
	endif

	_lSt := verStat(_preCar,1)

	if !_lSt
		VTAlert('Carreg. Bloq. para Separacao!!','Aviso de Encerramento(01)',.T.,2500,1)
		_lOk2 := .f.
		return .t.
	endif

	//regStat(_preCar,1)

	if substr(alltrim(_cod),1,2) = 'PA' //se for pallet
		_nNumCaix := 0
		SZP->(dbSetOrder(1))
		SZP->(dbGoTop())
		if !SZP->(MsSeek(FWxfilial('SZP') + alltrim(_cod))) .or. len(alltrim(_cod)) < 10
			mensagem('Pallet inexistente!',,.T.)
			return .t.
		else
			SZ8->(DbSetOrder(19))
			if !SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + alltrim(_cod)))
				mensagem('Caixas não encontradas no Pallet!',,.T.)
				return .t.
			else
				//percorre as caixas do pallet para verificar a quantidade de caixas no mesmo
				While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and. SZ8->Z8_FIL = cFilAnt .and. SZ8->Z8_PALLET = alltrim(_cod)

					if !empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS)
						mensagem('Pallet possui Caixa fora de estoque!',,.T.)
						u_gjf17his(4,'TENTATIVA ESTORNO CX JA CARREGADA: ' + _preCar,.f.,'','','000029',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
						return .t.
					endif

					if !empty(SZ8->Z8_CARPICK)
						if SZ8->Z8_CARPICK <> _preCar
							mensagem('Erro, Caixas ja','separaradas p/ carr:'+SZ8->Z8_CARPICK,.T.)
							return .t.
						endif
					else
						mensagem('Erro, Pallet possui','CXs nao separadas!',.T.)
						return .t.
					endif

					reclock('SZ8',.f.)
					SZ8->Z8_PICKING := ''
					SZ8->Z8_CARPICK := ''
					msunlock()
					u_gjf17his(4,'ESTORNO DE SEPARAC. DO CARREG.: ' + _preCar,.f.,'','','000030',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
					SZ8->(DbSkip())
				enddo

				mensagem('Caixas do Pallet: ', SZP->ZP_COD + ' estornadas!',.F.)
			endif

		endif

	else //senao é caixa

		if _cSeq = '1'
			SZ8->(DbSetOrder(3))
		else
			SZ8->(dbSetOrder(28))
		endif
		SZ8->(dbGoTop())
		if !SZ8->(MsSeek(FWxFilial('SZ8')+alltrim(_cod))) .or. len(alltrim(_cod)) < _nMaxCaix
			mensagem('Caixa inexistente!',,.T.)
			return .t.
		else
			if !empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS)
				mensagem('Caixa fora de estoque!',,.T.)
				u_gjf17his(4,'TENTATIVA ESTORNO CX JA CARREGADA: ' + _preCar,.f.,'','','000029',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
				return .t.
			endif

			if !empty(SZ8->Z8_CARPICK)
				if SZ8->Z8_CARPICK <> _preCar
					mensagem('Erro!','Cx ja separ. p/ carr:'+SZ8->Z8_CARPICK,.T.)
					return .t.
				endif
			else
				mensagem('Erro!','Cx nao separada!',.T.)
				return .t.
			endif

			reclock('SZ8',.f.)
			SZ8->Z8_PICKING := ''
			SZ8->Z8_CARPICK := ''
			msunlock()

			reclock('TRB',.f.)
			TRB->QRCAIX := TRB->QRCAIX-1
			msunlock()

			mensagem('Caixa: ' + SZ8->Z8_CONTROL + ' estornada!',,.F.)
			u_gjf17his(4,'ESTORNO DE SEPARAC. DO CARREG.: ' + _preCar,.f.,'','','000030',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

		endif

	endif

return .t.


Static Function separa(_cControl,_cPreCarr)

	Local _cCodProd := ''
	Local _nPos := 0

	if substr(_cControl,1,2) = 'PA' //se for pallet

		SZ8->(DbSetOrder(19))
		if SZ8->(MsSeek(FWxfilial('SZ8') + cFilAnt + alltrim(_cControl)))
			_cCodProd := SZ8->Z8_COD
			While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and. SZ8->Z8_FIL = cFilAnt .and. SZ8->Z8_PALLET = alltrim(_cControl)
				reclock('SZ8',.f.)
				SZ8->Z8_PICKING := 'S'
				SZ8->Z8_CARPICK := _cPreCarr
				msunlock()

				u_gjf17his(4,'SEPARADA PARA O CARREG.: ' + _cPreCarr,.f.,'','','000031',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

				SZ8->(dbSkip())
			enddo
		endif
	else//senão é caixa
		SZ8->(DbSetOrder(3))
		SZ8->(dbGoTop())
		if SZ8->(MsSeek(FWxFilial('SZ8') + _cControl))
			_cCodProd := SZ8->Z8_COD
			reclock('SZ8',.f.)
			SZ8->Z8_PICKING := 'S'
			SZ8->Z8_CARPICK := _cPreCarr
			msunlock()

			reclock('TRB',.f.)
			TRB->QRCAIX := TRB->QRCAIX+1
			msunlock()
			u_gjf17his(4,'SEPARADA PARA O CARREG.: ' + _cPreCarr,.f.,'','','000031',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
		endif
	endif

	_nPos := aScan(_aCodList, {|aVal|aVal[1] = _cCodProd})
	if _nPos = 0
		if buscaDtProd(_cCodProd)
			aAdd(_aCodList,{_cCodProd, dtoc(stod(QRY5->Z8_DATAP)), QRY5->Z8_LOCALIZ})
		endif
	else
		msgDtProd(_aCodList[_nPos,2], _aCodList[_nPos,3])
	endif

return


Static Function buscaDtProd(_cProd)
	Local _lRet := .F.

	_cQuery5 := "SELECT TOP 1 Z8_DATAP, Z8_LOCALIZ"
	_cQuery5 += " FROM " + retSqlTab('SZ8')
	_cQuery5 += " WHERE " + retSqlFil('SZ8')
	_cQuery5 += " AND Z8_FIL = '" + cFilAnt + "'"
	_cQuery5 += " AND Z8_COD = '" + _cProd + "'"
	_cQuery5 += " AND Z8_DATAS = '' AND Z8_HORAS = '' AND Z8_ENCONTR = ''"
	_cQuery5 += " AND Z8_CARPICK = ''"
	_cQuery5 += " AND " + retSqlDel('SZ8')
	_cQuery5 += " ORDER BY Z8_DATAP"

	_cQuery5 := ChangeQuery(_cQuery5)

	If Select("QRY5") != 0
		QRY5->(dbCloseArea())
	Endif

	TCQUERY _cQuery5 NEW ALIAS "QRY5"

	QRY5->(dbGoTop())

	if !empty(QRY5->Z8_DATAP)
		msgDtProd(dtoc(stod(QRY5->Z8_DATAP)), QRY5->Z8_LOCALIZ)
		_lRet := .T.
	endif

return _lRet


Static Function msgDtProd(_cDataP, _cLoc)
	@ 12,00 VTSay space(30)
	@ 13,00 VTSay space(30)
	@ 14,00 VTSay space(30)

	@ 12,00 VTSay "Data de prod mais antiga"
	@ 13,00 VTSay "em estoque é: " + _cDataP
	@ 14,00 VTSay "localizada em: " + _cLoc
Return


Static Function findProd(_cPrecar,_codProd)

	_cQuery3 := "SELECT COUNT(ZZ5_COD) AS QUANT"
	_cQuery3 += " FROM " + retSqlTab('ZZ5') + ", " + retSqlTab('ZZ4')// + ", " + retSqlTab('SB1')
	_cQuery3 += " WHERE " + retSqlFil('ZZ5') + " AND " + retSqlFil('ZZ4')// + " AND " + retSqlFil('SB1')
	_cQuery3 += " AND ZZ4_PRECAR = '" + _cPrecar + "' AND ZZ5_COD = '" + _codProd + "'"
	//_cQuery3 += " AND B1_COD = ZZ5_COD AND B1_SEGUM = 'CX'
	_cQuery3 += " AND ZZ5_NUM = ZZ4_NUM"
	_cQuery3 += " AND " + retSqlDel('ZZ5') + "  AND " + retSqlDel('ZZ4')// + " AND " + retSqlDel('SB1')
	//AND ZZ4_STATUS NOT IN ('E','F')
	_cQuery3  := ChangeQuery(_cQuery3)

	//conout(_cQuery3)

	If Select("QRY3") != 0
		QRY3->(dbCloseArea())
	Endif

	TCQUERY _cQuery3 NEW ALIAS "QRY3"

return iif(QRY3->QUANT > 0, .t., .f.)


Static Function mensagem(_cMens,_cMens2, _lTipo)

	Local _branco := space(50)

	if _lTipo
		VTBeep(1)
	endif
	@lin+4,00 VTSay _branco
	@lin+5,00 VTSay _branco
	@lin+6,00 VTSay _branco
	@lin+7,00 VTSay _branco
	@lin+8,00 VTSay _branco
	@lin+9,00 VTSay _branco
	@lin+10,00 VTSay _branco
	//@lin+11,00 VTSay _branco

	@lin+4,11 VTSay _cCod
	@lin+5,03 VTSay _cMens
	@lin+6,03 VtSay _cMens2

	_cCod := Space(11)

return .t.

//função para gerar o ambiente de trabalho
Static Function geraTRAB(preCarr)

	//cArq  := CriaTrab( Nil, .F. )
	_aArqTrb := {}

	aStru := {}
	AADD(aStru,{"COD"     ,"C"	,6  ,0	})
	AADD(aStru,{"QPCAIX"  ,"N"	,5  ,0	})
	AADD(aStru,{"QRCAIX"  ,"N"	,5	 ,0	})

	//dbcreate(cArq,aStru)
	//If Select('TRB')<>0
	//	TRB->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArq,"TRB", .F. , .F. )

	If Select('TRB')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TRB->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TRB", aStru, {}, @_aArqTrb)

	filProd(preCarr)

	QRY->(dbGoTop())
	while QRY->(!eof())
		DbSelectArea('TRB')
		reclock('TRB',.t.)
		TRB->COD	 := QRY->ZZ5_COD
		TRB->QPCAIX  := QRY->PREVISTO
		TRB->QRCAIX	 := filPicking(preCarr,QRY->ZZ5_COD)
		msunlock()

		QRY->(dbSkip())
	enddo

	aCampos := {}

	AADD(aCampos,{"COD"  	,, "Prod."		,"@!"   		})
	AADD(aCampos,{"QPCAIX" 	,, "Previsto"	,"@E 999"		})
	AADD(aCampos,{"QRCAIX"	,, "Separado"	,"@E 999"		})

return


User Function vtCarBrw(modo)
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,100,1)
		//_lOk  := .f.
		_lOk2 := .f.
		_lExecuta := .f.
		return 0
	elseif VTLastkey()==13
		_lExecuta := .t.
		return 1
	endif
return


User Function vtConBrw(modo)
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,100,1)
		//_lOk  := .f.
		_lOk2 := .f.
		_lExecCons := .f.
		return 0
	elseif VTLastkey()==13
		_lExecCons := .t.
		return 1
	endif
return


Static Function regUser(_carreg,_opc)
	//1 - grava user na ZZ3. 2 - Limpa user na ZZ3
	ZZ3->(dbSetOrder(2))
	ZZ3->(dbGoTop())
	if ZZ3->(MsSeek(FWxFilial('ZZ3') + _carreg))

		reclock('ZZ3',.f.)
		ZZ3->ZZ3_USRPCK := iif(_opc == 1,cUserName,'')
		msunlock()

	endif

return


Static Function regStat(_carreg,_opc)
	//1 - grava stat na ZZ3 - [P]icking. 2 - grava stat na ZZ3 - e[S]pera
	ZZ3->(dbSetOrder(2))
	ZZ3->(dbGoTop())
	if ZZ3->(MsSeek(FWxFilial('ZZ3') + _carreg))

		if ZZ3->ZZ3_STPCK != 'B'
			reclock('ZZ3',.f.)
			ZZ3->ZZ3_STPCK := iif(_opc == 1, 'P','S')
			msunlock()
		endif

		/*if _opc == 1 .and. ZZ3->ZZ3_STPCK <> 'P' //verificação para gravar apenas uma vez no carregamento, pois essa função é chamada em toda leitura de etiqueta
		reclock('ZZ3',.f.)						  //e não há a necessidade de gravar o status em todas as verificações, somente na primeira
		ZZ3->ZZ3_STPCK := 'P'
		msunlock()
		elseif _opc == 2 //Gava como e[S]pera caso saia da opão de separar
		reclock('ZZ3',.f.)
		ZZ3->ZZ3_STPCK := 'S'
		msunlock()
		endif
		*/

	endif

return

Static Function verStat(_carreg,_mod)

	ZZ3->(dbSetOrder(2))
	ZZ3->(dbGoTop())
	if ZZ3->(MsSeek(FWxFilial('ZZ3') + _carreg))

		if _mod == 1//mod = 1 -> no momento da leitura
			if ZZ3->ZZ3_STPCK $ 'B'	//se estiver [B]loqueado
				return .f.
			endif
		elseif _mod == 2 //mod = 2 ->na tentativa de acesso a rotina
			if ZZ3->ZZ3_STPCK $ 'B'	//se estiver [B]loqueado ou se[P]arando(Picking) retorna falso
				return .f.
			endif
		endif

	endif

return .t.

/*/{Protheus.doc} showDatas
	(exibe as datas e a quantidade de caixas referente a cada produto solicitado pelo comercial)
	@type  Static Function
	@author Mauricio Roehrs
	@since 09/03/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function showDatas(_cCarr,_cProd)
	
	VTClear()
	VTClearBuffer()

	arqDatas(_cCarr,_cProd)

	aFields := {"COD","QUANT","DATAP"}
	aHeader := {"PROD","QUANT","DATAP"}
	aSize   := {6,6,10}

	dbselectarea('ARQDT')

	ARQDT->(dbgotop())

	//mostra o grid na tela
	nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"ARQDT",aHeader,aFields,aSize,"u_vtDtPBrw",)


	VTClear()
	VTClearBuffer()

Return 

/*/{Protheus.doc} arqDatas
	(long_description)
	@type  Static Function
	@author Mauricio Roehrs
	@since 09/03/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function arqDatas(_cCarr)

	local _cQuery := ''

	//cArqDt  := CriaTrab( Nil, .F. )
	_aArqTrb := {}

	aStrut := {}
	AADD(aStrut,{"COD"     ,"C"	,6  ,0	})
	AADD(aStrut,{"QUANT"   ,"N"	,5  ,0	})
	AADD(aStrut,{"DATAP"   ,"D"	,8	,0	})

	//dbcreate(cArqDt,aStrut)
	//If Select('ARQDT')<>0
	//	ARQDT->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArqDt,"ARQDT", .F. , .F. )

	If Select('ARQDT')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		ARQDT->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "ARQDT", aStrut, {}, @_aArqTrb)

	/*
	_cQuery := " SELECT Z8_COD, COUNT(Z8_COD) AS QUANT, Z8_DATAP"
	_cQuery += " FROM " + retSqlTab('SZ8')
	_cQuery += " INNER JOIN " + retSqlTab('ZZ4') + " ON ZZ4_PRECAR = '" + _cCarr+"'"
	_cQuery += " "
	*/

	_cQuery := " SELECT Z8_COD, COUNT(Z8_COD) AS QUANT, Z8_DATAP"
	_cQuery += " FROM " +retSqlTab('ZZ4')
	_cQuery += " INNER JOIN " + retSqlTab('SZ8') + " ON Z8_AUTOPED = ZZ4_NUM AND " + retSqlDel('SZ8')
	_cQuery += " INNER JOIN " + retSqlTab('ZZ5') + " ON ZZ5_NUM = ZZ4_NUM AND ZZ5_COD = Z8_COD AND " + retSqlDel('ZZ5')
	_cQuery += " WHERE " + retSqlFil('ZZ4')
	_cQuery += " AND ZZ4_PRECAR = '" +_cCarr+"'"
	_cQuery += " AND " + retSqlDel('ZZ4')
	_cQuery += " GROUP BY Z8_COD, Z8_DATAP"

	cAlias := GetNextAlias()
	TCQuery _cQuery new alias &cAlias

	(cAlias)->(dbGoTop())
	while (cAlias)->(!eof())

		reclock('ARQDT',.t.)
		ARQDT->COD	 	 := (cAlias)->Z8_COD
		ARQDT->QUANT     :=  (cAlias)->QUANT
		ARQDT->DATAP	 := stod((cAlias)->Z8_DATAP)
		ARQDT->(msunlock())

		(cAlias)->(dbSkip())
	enddo

	aFielDT := {}

	AADD(aFielDT,{"COD"  	,, "Prod."		 ,"@!"   		})
	AADD(aFielDT,{"QUANT" 	,, "Previsto"	 ,"@E 99999"	})
	AADD(aFielDT,{"DATAP"	,, "Data. Prod." ,""			})

Return 

User Function vtDtPBrw()
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,100,1)
		//_lOk  := .f.
		_lOk2 := .f.
		return 0
	elseif VTLastkey()==13
		return 1
	endif

return
