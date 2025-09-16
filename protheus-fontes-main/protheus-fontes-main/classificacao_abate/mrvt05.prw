#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT05     º Autor ³Giuliano Forgiariniº ³  31/08/13        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ apontamento de produção na entrada da desossa              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Função para produção na entrada da desossa
User Function MRVT05(_usuario)

	Private _cModelo  := '' 
	Private _cPar01   := '1'   //Tipo de Traseiro: 1 - Estreito | 2 - Largo
	Private _cPar02   := '3.700'  //Tara
	Private _cPar03   := '2'   //Habilita Balança  1 - Sim | 2 - Nao
	Private _cPar04   := '0'   //Destino 1 - Desossa[D] | 2 - Costela[C] | 3 - Carregamento[R]   
	Private _cPar05   := '1'   //Operação 1 - Produção | 2 - Exclusão
	Private _cPar06   := '2'   //1 - SIM 2 - NAO
	Private _lOk      := .t.
	Private prox      := 0
	Private _cUsrDes  := alltrim(GETMV('SI_USRCDES')) // cUserName
	Private _cUsrCos  := alltrim(GETMV('SI_USRCCOS')) // cUserName
	Private _lBlqDes  := GETMV('SI_BLQPCED')		  // Parâmetro de controle de liberação de peças do PCP
	Private _cCorLDes := alltrim(GETMV('SI_CORLDES')) // Parametro com os códigos de cortes liberados para passar na Desossa

	dbSelectArea('SZO')
	SZO->(dbSetorder(1))  // tipo+data+sequen
	SZO->(DbGoTop())
	SZO->(MsSeek(FWxFilial('SZO')+'E'+DTOS(ddatabase)))
	Do While !SZO->(Eof()) .AND. SZO->ZO_DATA == ddatabase .AND. SZO->ZO_TIPO == 'E'
		prox := Val(SZO->ZO_SEQUEN)
		SZO->(dbSkip())
	Enddo
	prox++

	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL04 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif

	//Define o tamanho da Tela
	_cModelo := VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	while _lOk

		@ 01,05 VTSay "PRODUCAO DESOSSA"
		@ 03,05 VTSay "Parametros Iniciais:"

		@ 05,00 VTSay "Ret.Car?:[ ] 1:S|2:N"
		@ 06,00 VTSay "Tipo T:  [ ] 1:L|2:E"
		@ 07,00 VTSay "Tara:    [     ] "
		@ 08,00 VTSay "Pesa?:   [ ] 1:S|2:N"
		@ 09,00 VTSay "Dest.:   [ ] 1:DES|2:COS"
		@ 10,00 VTSay "Operacao:[ ] 1:P|2:E|3:C"
		@ 16,00 VTSay "ESC para Sair"

		@ 05,10 VTGet _cPar06 Pict "@! "   	  valid (_cPar06 $ '12')
		@ 06,10 VTGet _cPar01 Pict "@! "      valid (_cPar01 $ '12')
		@ 07,10 VTGet _cPar02 Pict "@! 9.999" valid (val(_cPar02) > 0.00 .and. val(_cPar02) < 9.99)
		@ 08,10 VTGet _cPar03 Pict "@! "      valid (_cPar03 $ '12')
		@ 09,10 VTGet _cPar04 Pict "@! "   	  valid (_cPar04 $ '12')
		@ 10,10 VTGet _cPar05 Pict "@! "   	  valid (_cPar05 $ '123')
		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		if _cPar05 = '1'      //Produção
			ProcDes(_cPar01,_cPar02,_cPar03,_cPar04)
		elseif _cPar05 = '2'  //Exclusão
			Excluir()        
		else                  //Consulta
			Consulta()
		endif

	enddo

return 

Static Function ProcDes(_cPar01,_cPar02,_cPar03,_cPar04)
	Private _lOk   := .t.
	Private _cCod  := ''

	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod := Space(11)

		//VTRead

		@ 01,05 VTSay "PRODUCAO DESOSSA"
		@ 05,05 VTSay "Codigo da Carcaça"
		@ 06,08 VTSay "[           ]"
		@ 06,09 VTGet _cCod Pict "@!" VALID ValInv01()
		@ 16,00 VTSay "ESC para Sair"
		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		VTClear()
		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

Return

Static Function ValInv01()
	//Parametro de classificação especial
	//Local _cClasEsp := GetMv('SI_CLASESP')
	Local _cCodCarc := ""
	_lBlqDes  := GETMV('SI_BLQPCED')
	_cPesoL  := ''
	_cPesoB  := ''
	_NumPrev := ''
	_cClass := ''

	if empty(_cCod)
		return .t.
	else
		_cCodCarc := _cCod
	endif

	SZK->(DbSetorder(4))

	ZAJ->(DbSetOrder(2))
	ZAJ->(DbGoTop())
	if !ZAJ->(MsSeek(FWxfilial('ZAJ')+alltrim(_cCod)))
		u_MR05NA('Carcaça não identificada!')
		rej(1)
		return .f.
	elseif empty(ZAJ->ZAJ_ZAPNUM)

		_cRastro := ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO)
		_cProd   := ZAJ->ZAJ_COD
		_cLado   := ZAJ->ZAJ_LADO
		_cCorOri := ZAJ->ZAJ_CORORI
		
		if !_cPar06 = "1"
			if !SZK->(MsSeek(FWxfilial('SZK') + _cRastro))
				if !(alltrim(ZAJ->ZAJ_COD) $ _cCorLDes)
					//Função que determina os labelas da tela de produção
					u_MR05NA('Carcaça inexistente!')
					rej(2)
					Return .f.
				endif
			endif
		endif		
	endif
	
	if empty(SZK->ZK_CLASSIF) .and. empty(ZAJ->ZAJ_ZAPNUM) .and. (ZAJ->ZAJ_CORORI <> 'C')
		if !(alltrim(ZAJ->ZAJ_COD) $ _cCorLDes)
			//Função que determina os labelas da tela de produção
			u_MR05NA('Sem classificação!')
			rej(2)
			return .f.
		endif	
	endif
	
	_NumPrev := ''

	//Criado parametro para classificação especial genérica em carcaças
	//se por algum motivo em especial precisar classificar as carcaças
	//utiliza-se esse mecanismo para controlar a entrada das peças na
	//desossa com essa classificação   (SI_CLASESP)
	//Não inclui nessa verificação a costela
	/*
	if _cClasEsp = 'S' .and. _cCorOri <> 'C'
	//if SZK->ZK_CLASESP <> '1' .and. AllTrim(SZK->ZK_CLASSIF) = 'NE'
	if SZK->ZK_CLASESP = '2' .or. AllTrim(SZK->ZK_CLASSIF) = 'NE'
	u_MR05NA('Classif. Especial impede produção!')
	Return .f.
	endif
	elseif _cClasEsp = 'N'
	if SZK->ZK_CLASESP = '1' .and. AllTrim(SZK->ZK_CLASSIF) <> 'NE'
	u_MR05NA('Classif. Especial impede produção!')
	Return .f.
	endif
	endif 
	*/

	if _cPar06 = '2'
		if !empty(ZAJ->ZAJ_DATAS) .and. !empty(ZAJ->ZAJ_HORAS)
			u_MR05NA('Já processado ou fora de estoque!')
			rej(1)
			Return .f.
		endif
	else
		reclock('ZAJ',.f.)
			ZAJ->ZAJ_DATAS = SToD('')
			ZAJ->ZAJ_HORAS = ''
		msunlock()
	endif

	if ZAJ->ZAJ_CORORI <> 'C' .and. alltrim(cUserName) $ _cUsrDes .and. !(alltrim(ZAJ->ZAJ_COD) $ _cCorLDes)

		DbSelectArea("SZ2")

		SZ2->(DbSetOrder(2))
		SZ2->(DbGoTop())				
		if SZ2->(MsSeek(FWxfilial('SZ2') + ZAJ->ZAJ_PREDES))//se a carcaça está reservada para a OP
			if date() < SZ2->Z2_DTPROD .or. date() > SZ2->(Z2_DTPROD + Z2_DIASVAL)
				//Função que define os labels na tela de produção
				u_MR05NA('Prev.Prod. inexistente!       ', "OP = " + alltrim(SZ2->Z2_NUM))
				rej(2)
				Return .f.
			endif

			// verifica o limite de peças
			if SZ2->Z2_LIMPEC > 0
				if SZ2->Z2_LIMPEC >= SZ2->Z2_QRPECA
					//Função que define os labels na tela de produção
					u_MR05NA('Lim. de Pec. ja atingidos!')
					rej(2)
					Return .f.
				endif
			endif
			
			if(!ExistCpo("ZY3",ZAJ->ZAJ_NUM,1))
				if SZ2->Z2_STATUS = 'B' 
					//Função que determina os labels da tela de produção
					u_MR05NA('Prev.Prod. bloqueada!         ', "OP = " + alltrim(SZ2->Z2_NUM))
					rej(2)
					// Rotina de gravação de log
					u_dtilog(cFilAnt, "MRVT05", "OP bloqueada! Previsão->" + SZ2->Z2_NUM + " | Peça->" + ZAJ->ZAJ_NUM + " | Carcaça->" + ZAJ->ZAJ_CONTRO, "B")
					Return .f.
				elseif  SZ2->Z2_STATUS = 'E'
					//Função que determina os labels da tela de produção
					u_MR05NA('Prev.Prod. encerrada!         ', "OP = " + alltrim(SZ2->Z2_NUM))
					rej(2)
					// Rotina de gravação de log
					u_dtilog(cFilAnt, "MRVT05", "OP encerrada! Previsão->" + SZ2->Z2_NUM + " | Peça->" + ZAJ->ZAJ_NUM + " | Carcaça->" + ZAJ->ZAJ_CONTRO, "E")
					Return .f.
				endif
			endif

			_NumPrev := ZAJ->ZAJ_PREDES

			//Se não existe reserva de carcaça
		else
			if !empty(ZAJ->ZAJ_ZAPNUM)//se não tiver em branco este campo significa que é uma OP de carcaças de Terceiros
				_cQuery := "  SELECT Z2_DIASVAL AS DIAS, Z2_CORORI AS CORORI,Z2_NUM AS NUM FROM "+RetSqlTab("SZ2")
				_cQuery += "  WHERE " + RetSQLFil('SZ2')
				//verificações iniciais
				//_cQuery += "  AND Z2_RESERV  = 'N'"
				_cQuery += "  AND Z2_STATUS <> 'E' AND Z2_STATUS <> 'B' "
				_cQuery += "  AND Z2_CORORI  = '" + alltrim(ZAJ->ZAJ_CORORI) + "'"
				_cQuery += "  AND Z2_DTPROD <= '" + DTOS(ddatabase) + "'"
				_cQuery += "  AND Z2_PRIORID = 'T' AND Z2_CERTIF = '" + alltrim(ZAJ->ZAJ_ZAPNUM) + "'"
				_cQuery += "  AND " + REtSQLDel('SZ2')
				_cQuery += "  ORDER BY Z2_CORORI, Z2_NUM"

				_cQuery  := ChangeQuery(_cQuery)

				//	* Mostrar a consulta */
				//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
				//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
				//Activate Dialog oDlgMemo

				If Select("DES") != 0
					DES->(dbCloseArea())
				Endif

				TCQUERY _cQuery NEW ALIAS "DES"

			else//senão, é carcaça propria

				do case
					case AllTrim(SZK->ZK_CLASSIF) = 'RT'
						_cClass := "('RT','RU','HK','NE')"
					case AllTrim(SZK->ZK_CLASSIF) = 'RU'
						_cClass := "('HK','RU')"
					case AllTrim(SZK->ZK_CLASSIF) = 'HK'
						_cClass := "('HK')"
					case AllTrim(SZK->ZK_CLASSIF) = 'NE'
						_cClass := "('NE')"
					case AllTrim(SZK->ZK_CLASSIF) = 'BR'
						_cClass := "('BR')"
					case AllTrim(SZK->ZK_CLASSIF) = 'USA'
						_cClass := "('USA')"
				endcase

				//para verificação se existe previsao de produção
				_cQuery := "  SELECT Z2_DIASVAL AS DIAS, Z2_CORORI AS CORORI,Z2_NUM AS NUM FROM "+RetSqlTab("SZ2")
				_cQuery += "  WHERE " + RetSQLFil('SZ2')
				//verificações iniciais
				_cQuery += "  AND Z2_RESERV  = 'N'"
				_cQuery += "  AND Z2_STATUS <> 'E' AND Z2_STATUS <> 'B' "
				_cQuery += "  AND Z2_CORORI  = '" + alltrim(ZAJ->ZAJ_CORORI) + "'"
				_cQuery += "  AND Z2_DTPROD <= '" + DTOS(ddatabase) + "'"
				_cQuery += "  AND Z2_NUMAM   = '" + SZK->ZK_NUMAM + "'"

				//verifica se é apenas por dentição
				_cQuery += "  AND ((Z2_PRIORID  = 'D') OR"
				//verifica se é por rastreabilidade, programa ou ambos
				_cQuery += "  ((  Z2_CLASSIF IN " + _cClass
				_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "'"
				_cQuery += "  AND Z2_PRIORID  = 'R') OR ("
				_cQuery += "      Z2_PRIORID  = 'P'"
				_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "') OR ("
				_cquery += "      Z2_PRIORID  = 'A'"
				_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "'"
				_cQuery += "  AND Z2_CLASSIF IN " + _cClass
				_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "')) OR"

				//inclui na verificação a categoria
				_cQuery += "   (( Z2_CLASSIF IN " + _cClass
				_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "'"
				_cQuery += "  AND Z2_PRIORID  = 'R' AND Z2_CATEG = '" + SZK->ZK_CATEG + "') OR ("
				_cQuery += "      Z2_PRIORID  = 'P' AND Z2_CATEG = '" + SZK->ZK_CATEG + "'"
				_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "') OR ("
				_cquery += "      Z2_PRIORID  = 'A' AND Z2_CATEG = '" + SZK->ZK_CATEG + "'"
				_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "'"
				_cQuery += "  AND Z2_CLASSIF IN " + _cClass
				_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "')) OR"

				//inclui na verificação a camara
				_cQuery += "   (( Z2_CLASSIF IN " + _cClass
				_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "'"
				_cQuery += "  AND Z2_PRIORID  = 'R' AND Z2_CAMARA = '" + SZK->ZK_LOCAL + "') OR ("
				_cQuery += "      Z2_PRIORID  = 'P' AND Z2_CAMARA = '" + SZK->ZK_LOCAL + "'"
				_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "') OR ("
				_cquery += "      Z2_PRIORID  = 'A' AND Z2_CAMARA = '" + SZK->ZK_LOCAL + "'"
				_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "'"
				_cQuery += "  AND Z2_CLASSIF IN " + _cClass
				_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "')) OR"

				//inclui na verificação classificação especial
				_cQuery += "   (Z2_PRIORID  = 'C') OR"

				//incui na verificação carcaças tipo black			
				_cQuery += "   ((Z2_BLACK = 'S' AND Z2_BLACK = '" + SZK->ZK_BLACK + "') OR ("
				_cQuery += "     Z2_BLACK = 'N' AND Z2_BLACK = '" + SZK->ZK_BLACK + "')) OR"

				//inclui na verifiicação a dentição
				_cQuery += "   (( Z2_CLASSIF IN " + _cClass
				_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "'"
				_cQuery += "  AND Z2_PRIORID  = 'R' AND Z2_CATEG = '" + SZK->ZK_CATEG + "' AND Z2_DENT = '" + SZK->ZK_DENT + "') OR ("
				_cQuery += "      Z2_PRIORID  = 'P' AND Z2_CATEG = '" + SZK->ZK_CATEG + "' AND Z2_DENT = '" + SZK->ZK_DENT + "'"
				_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "') OR ("
				_cquery += "      Z2_PRIORID  = 'A' AND Z2_CATEG = '" + SZK->ZK_CATEG + "' AND Z2_DENT = '" + SZK->ZK_DENT + "'"
				_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "'"
				_cQuery += "  AND Z2_CLASSIF IN " + _cClass
				_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "')))"
				_cQuery += "  AND " + REtSQLDel('SZ2')
				_cQuery += "  ORDER BY Z2_CORORI, Z2_NUM"
				_cQuery := ChangeQuery(_cQuery)

				//	* Mostrar a consulta */
				//	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
				//	@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
				//	Activate Dialog oDlgMemo

				If Select("DES")<>0
					DES->(dbCloseArea())
				Endif

				TCQUERY _cQuery NEW ALIAS "DES"
			endif

			DES->(DbGotop())
			while DES->(!eof())
				SZ2->(DbSetOrder(2))
				SZ2->(DbGoTop())
				SZ2->(MsSeek(FWxfilial('SZ2')+DES->NUM))
				// Se OP estiver com data de produção maior que 9 dias sistema não deixa produzir
				if ddatabase > SZ2->(Z2_DTPROD + Z2_DIASVAL)
					DES->(DbSkip())
					loop
				else
					_NumPrev := DES->NUM
					exit
				endif

				DES->(DbSkip())
			enddo

			if empty(_NumPrev)
				//Função que determina os labels da tela de produção
				u_MR05NA('Prev.Prod. nao lançada/encontrada!')
				rej(2)
				// Rotina de gravação de log
				u_dtilog(cFilAnt, "MRVT05", "OP não encontrada! Peça->" + ZAJ->ZAJ_NUM + " | Carcaça->" + ZAJ->ZAJ_CONTRO, "L")
				DES->(dbclosearea())

				return .f.
			endif
		endif
	elseif _lBlqDes .and. !(alltrim(ZAJ->ZAJ_COD) $ _cCorLDes)
		if (ZAJ->ZAJ_CORORI <> 'C' .and. !(alltrim(cUserName) $ _cUsrDes)) // Se passar uma etiqueta da Desossa na Costela
			u_MR05NA('Erro! Etiqueta da Desossa!')
			rej(2)
			// Rotina de gravação de log
			u_dtilog(cFilAnt, "MRVT05", "Etiqueta incorreta! Peça->" + ZAJ->ZAJ_NUM + " | Carcaça->" + ZAJ->ZAJ_CONTRO, "D")

			return .f.
		elseif (ZAJ->ZAJ_CORORI = 'C' .and. !(alltrim(cUserName) $ _cUsrCos)) // Se passar uma etiqueta de Costela na Desossa
			u_MR05NA('Erro! Etiqueta de Costela!')
			rej(2)
			// Rotina de gravação de log
			u_dtilog(cFilAnt, "MRVT05", "Etiqueta incorreta! Peça->" + ZAJ->ZAJ_NUM + " | Carcaça->" + ZAJ->ZAJ_CONTRO, "C")

			return .f.
		endif
	elseif (ZAJ->ZAJ_CORORI = 'T' .and. !(alltrim(cUserName) $ _cUsrDes)) .and. !(alltrim(ZAJ->ZAJ_COD) $ _cCorLDes) // Se passar uma etiqueta da Desossa na Costela
		u_MR05NA('Erro! Etiqueta de Traseiro!')
		rej(2)
		// Rotina de gravação de log
		u_dtilog(cFilAnt, "MRVT05", "Etiqueta incorreta! Peça->" + ZAJ->ZAJ_NUM + " | Carcaça->" + ZAJ->ZAJ_CONTRO, "D")

		return .f.
	endif

	// _mod = 1 -> utilização da função em rotina para PC
	// _mod = 2 -> utilização da função em rotina para coletor de dados

	_cTPTrase := iif(ZAJ->ZAJ_CORORI = 'T',iif(_cPar01 = '1','E','L'),'')
	_cDest    := iif(_cPar04 = '1','D',iif(_cPar04 = '2','C','R'))//D = Desossa | C = Costela | R = Carregamento
	_cClassif := iif(!empty(ZAJ->ZAJ_ZAPNUM),GetAdvFVal('ZAP','ZAP_CLASSI',FWxfilial('ZAP')+ZAJ->ZAJ_ZAPNUM,2),SZK->ZK_CLASSIF)
	_cProgram := iif(!empty(ZAJ->ZAJ_ZAPNUM),GetAdvFVal('ZAP','ZAP_MENS',FWxfilial('ZAP')+ZAJ->ZAJ_ZAPNUM,2),GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6')+SZK->ZK_PROGRAM,1))
	if GetAdvFVal('SZK','ZK_BLACK',FWxfilial('SZK')+ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO),4) = 'S'
		_cBlack   := "SIM"
	else
		_cBlack   := "NAO"
	endif

	u_gjf69pro('2',_cPar03,val(_cPar02),_cTPTrase,_cDest)

	ZAJ->(DbSetOrder(2))
	ZAJ->(DbGoTop())
	ZAJ->(MsSeek(FWxfilial('ZAJ')+alltrim(_cCodCarc)))

	@08,00 VTSay "PEÇA PROCESSADA!"
	@09,00 VTSay "Nr. Peça:    "
	//@11,00 VTSay "Cod.Produto: "
	@10,00 VTSay "Descricao:   "
	@11,00 VTSay "Classif.:    "
	@12,00 VTSay "Programa:    "
	@13,00 VTSay "Peso Liq.:   "
	@14,00 VTSay "Peso Bruto:  "
	@15,00 VTSay "Black:       "
	@16,00 VTSay "OP Desossa:  "
	@09,13 VTSay _cCodCarc
	//@11,13 VTSay PadR(ZAJ->ZAJ_COD, 14, ' ')
	@10,13 VTSay PadR(ZAJ->ZAJ_DESCRI, 17, ' ')
	@11,13 VTSay PadR(_cClassif, 17, ' ')
	@12,13 VTSay PadR(_cProgram, 17, ' ')
	@13,13 VTSay PadR(_cPesoL, 17, ' ')
	@14,13 VTSay PadR(_cPesoB, 17, ' ')
	@15,13 VTSay PadR(_cBlack, 17, ' ')
	@16,13 VTSay PadR(ZAJ->ZAJ_PREDES, 17, ' ')
	VTBeep(1)
	rej(1)
	_cCod := Space(11)
Return .f.                                           


User Function MR05NA(_cMens,_cMens2)
	if empty(_cMens2)
		_cMens2 := Space(30)
	endif
	@08,00 VTSay Space(30)
	@09,00 VTSay "Nr. Peça:    "+Space(17)
	@10,00 VTSay _cCod
	@10,11 VTSay Space(30)
	@11,00 VTSay Space(30)
	@12,00 VTSay Space(30)
	@13,00 VTSay Space(30)
	@14,00 VTSay Space(30)
	@11,00 VTSay PadR(_cMens, 30, ' ') //+ Space(30)
	@12,00 VTSay PadR(_cMens2, 30, ' ')
	@15,00 VTSay Space(30)
	@16,00 VTSay Space(30)
	//@17,00 VTSay Space(30)
	//@18,00 VTSay Space(30)
	_cCod := Space(11)
return .f.


Static Function Excluir()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(17,30)
	endif

	_lOk := .t.

	while _lOk

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(03)',.T.,100,1)
			exit
		EndIf

		_cCod := Space(11)

		@ 01,05 VTSay "EXCLUSAO PRODUCAO DESOSSA"
		@ 05,05 VTSay "Codigo da Carcaça"
		@ 06,08 VTSay "[           ]"
		@ 06,09 VTGet _cCod Pict "@!" VALID ValExcl()
		@ 16,00 VTSay "ESC para Sair"
		VTRead

		VTClear()
		VTClearBuffer()

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(05)',.T.,100,1)
			exit
		else
			VTAlert('Confirma exclusão? (Enter:Sim,Esc:Nao)','Atencao',.T.)

			If (VTLastKey() == 27)
				VTAlert('Operação Cancelada!','Aviso de Encerramento(04)',.T.,100,1)
				exit
			else
				VTAlert('Exclusão da Peça: ' + ZAJ->ZAJ_NUM,'Operação Realizada',.T.,2000,1)
				u_gjf69del('2', ZAJ->ZAJ_NUM)

				_cProg := GetAdvFVal('SZK','ZK_PROGRAM',FWxfilial('SZK')+ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO),4)
				_cDescProg := GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6')+_cProg,1)
				if GetAdvFVal('SZK','ZK_BLACK',FWxfilial('SZK')+ZAJ->(ZAJ_NUMAM+ZAJ_CONTRO),4) = 'S'
					_cBlack   := "SIM"
				else
					_cBlack   := "NAO"
				endif

				@08,00 VTSay "PEÇA EXCLUIDA!"
				@09,00 VTSay "Nr. Peça:    "
				@10,00 VTSay "Descricao:   "
				@11,00 VTSay "Programa:    "
				@12,00 VTSay "Black:       "
				@13,00 VTSay "OP Desossa:  "
				@09,13 VTSay _cCod
				@10,13 VTSay PadR(ZAJ->ZAJ_DESCRI, 17, ' ')
				@11,13 VTSay PadR(_cDescProg, 17, ' ')
				@12,13 VTSay PadR(_cBlack, 17, ' ')
				@13,13 VTSay PadR(ZAJ->ZAJ_PREDES, 17, ' ')
			endif
		endif

	enddo

Return

//Função de validação para exclusão de carcaças
Static Function ValExcl()

	if empty(_cCod)
		return .t.
	endif

	ZAJ->(DbSetOrder(2))
	ZAJ->(DbGoTop())
	if !ZAJ->(MsSeek(FWxfilial('ZAJ')+alltrim(_cCod)))
		u_MR05NA('Carcaça não identificada!')
		rej(1)
		return .f.
	else
		VTBeep(1)
		rej(1)
		return .t.
	endif

Return

//Função para consulta
Static Function Consulta()

	_area   := getarea()
	_aArqTrb := {}

	cQuery := " SELECT ZO_TIPO AS TIPO, ZO_PROD AS PROD, SUM(ZO_QUANT)AS QUANT, SUM(ZO_PESOL) AS PESOL"
	cQuery += " FROM " + RetSqlTab("SZO")
	cQuery += " WHERE "+ RetSqlFil("SZO") + " AND "
	cQuery += " ZO_DEST <> 'R' AND " 
	cQuery += " ZO_DATA = '" + DTOS(DDATABASE) +"' AND " + RetSQLDel('SZO')

	cQuery += " GROUP BY ZO_TIPO, ZO_PROD"
	cQuery += " ORDER BY ZO_TIPO, ZO_PROD"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery := ChangeQuery(cQuery)

	If Select("DSO")<>0
		DSO->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "DSO"

	//area := getarea()

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	dbSelectarea('DSO')

	aStru := dbStruct()
	aadd(aStru,{"TIP"  , "C", 10, 0,   "" , 'Movimento ' })
	aadd(aStru,{"PRO" , "C", 30,  0,   "" , 'Produto'})
	aadd(aStru,{"QTD" , "C", 5,  0,   "" ,  'Quantidade'})

	//dbcreate(cArq,aStru)
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	while DSO->(!eof())
		DbSelectArea('TMP') 
		reclock('TMP',.t.) 	
		TMP->TIP      := iif(DSO->TIPO = 'E','ENTRADA','SAIDA')
		TMP->PRO      := GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1')+alltrim(DSO->PROD),1)
		TMP->PROD     := DSO->PROD
		TMP->PESOL    := DSO->PESOL
		TMP->QUANT    := DSO->QUANT 
		TMP->QTD      := transform(DSO->QUANT,'@E 9,999')
		msunlock()
		DSO->(dbskip())

	enddo 

	TMP->(dbgotop())

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(17,30)
	endif

	aFields := {"TIP","PROD","PESOL","QTD"}
	aHeader := {"TIP","PROD","PESO" ,"QUANT"}
	aSize   := {02,06,05,05}

	_lOk := .t.

	ZZD->(DbGoBottom())

	while _lOk

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(03)',.T.,100,1)
			exit
		EndIf

		nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"TMP",aHeader,aFields,aSize,"u_MCT05E",)

		SET FILTER TO

	enddo	

	//dbclosearea('TMP')
	//dbclosearea('DSO')

	TMP->(dbCloseArea())
	DSO->(dbCloseArea())

	u_arqtrb("FechaTodos",,,, @_aArqTrb)

	restarea(_area)

	VTClear()
	VTClearBuffer()

	_lOk := .t.

return

//Função de usuário para interagir com a VTDBBrowse
User Function MCT05E()
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,100,1) 
		//VTBeep(3)   
		_lOk := .f.
		return 0
	elseif VTLastkey()==13
		return 1
	endif 

return

//Ativa a rele. Funciona em conjunto com o fonte mlr52 que é um "job" rodando em um pc.
static function rej(_mod)
	//se mod = 1 então desliga a rele
	//se mod = 2 entao liga a rele

	//conteudo do parametro = 2 -> ligou rele
	//conteudo do parametro = 1 -> desligou rele
	local _cUlt := getmv('SI_ULTI')

	//se a ultima opção foi ligar e tentar ligar novamente retorna
	if alltrim(_cUlt) == '2' .and. _mod = 2

		return 

	endif      

	//se a ultima opção foi desligar e tentar desligar novamente retorna
	if alltrim(_cUlt) == '1' .and. _mod = 1
		return
	endif

	if _mod == 1 //desliga rele

		putMv('SI_REJ05','1')

		putMv('SI_ULTI','1')

	elseif _mod == 2//liga relé
		
		putMv('SI_REJ05','2')
		putMv('SI_ULTI','2')	

	endif

return


/*	if _mod == 1 //desliga rele

putMv('SI_REJ05','1')

elseif _mod == 2//liga relé

putMv('SI_REJ05','2')

endif               */


/*//se a ultima opcao foi para ligar e deseja desligar desliga 
if _cUlt == '2' .and. _mod == 1                       

putMv('SI_REJ05','1')//desliga rele

putMv('SI_ULTI','1')//marca que a ultima ação foi desligar a rele

//se a ultima opção foi desligar e deseja ligar
elseif _cUlt == '1' .and. _mod == 2		

putMv('SI_REJ05','2')//liga a rele

putMv('SI_ULTI','2')//marca que a ultima ação foi ligar a rele

endif	*/
