

user Function _EmpEmbCa(_sOps)
	Local cAliasArea  := ""
	Local oArqTrb     := Nil
	

	_cQuery := " SELECT D4_OP, D4_COD, D4_QUANT, D4_DATA, D4_QTDEORI, D4_LOCAL "
	_cQuery += " FROM " + RetSQLTab("SD4")
	_cQuery += " WHERE D_E_L_E_T_ = ''"
	_cQuery += " AND D4_OP  in (" +  _sOps  +"'')"
	_cQuery := ChangeQuery(_cQuery)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), "_AJU", .F., .T.)
	While _AJU•->(!Eof())
		DbSelectArea("SD4")
		SD4->(DbSetOrder(2)) 			// D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
		If DbSeek(xFilial("SD4") + _AJU->D4_OP + _AJU->D4_COD) 
			Reclock("SD4",.F.)
			SD4->D4_FSLDANT := _AJU->D4_QUANT
			SD4->D4_FQTDANT := _AJU->D4_QTDEORI	
			MsUnlock()
		endif
		DBSelectArea("_AJU")
		dbskip()
	Enddo

	_AJU->(DbCloseArea())

	// Cria tabela principal com dados do array
	Processa({|| oArqTrb := CriaTRB()}, "Aguarde, carregando informaões", "", .F.)

	cAliasArea := oArqTrb:GetAlias()

	cTabelaTMP :=  oArqTrb:GetRealName() 
	
	// Busca tabela tempoaria
	_cQuery := " SELECT EMISSAO, NUM, ITEM, SEQUEN, PRODUTO, QUANT "
	_cQuery += " FROM " + cTabelaTMP + " TAB1 "
	_cQuery += " WHERE TAB1.D_E_L_E_T_ = '' "
	_cQuery := ChangeQuery(_cQuery)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), "TRA", .F., .T.)



	//buscar todos os empenhos 
	While TRA->(!Eof())	
	_sOP   := TRA->NUM + TRA->ITEM + TRA->SEQUEN

	_dDataOp := DTOS(Posicione('SC2', 1, Xfilial('SC2') + _sOP, 'C2_EMISSAO'))

	_cQuery := " SELECT D4_OP, D4_COD, D4_QUANT, D4_DATA, D4_QTDEORI, D4_LOCAL "
	_cQuery += " FROM " + RetSQLTab("SD4")
	_cQuery += " WHERE D_E_L_E_T_ = '' "
	_cQuery += " AND D4_OP = '" + _sOP + "' "
	_cQuery := ChangeQuery(_cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "_SD4", .F., .T.)

		While _SD4->(!Eof())
	

			_sProd  := alltrim(_SD4->D4_COD)
			_cQuery := " SELECT D4_COD, SUM(D4_FQTDANT)"
			_cQuery += " FROM " + RetSQLTab("SD4")
			_cQuery += " WHERE D_E_L_E_T_ = ''"
			_cQuery += " AND D4_OP  in (" +  _sOps  +"'')"
			_cQuery += " AND D4_COD = '" +  alltrim(_SD4->D4_COD)  +"'"
			_cQuery += " GROUP BY D4_COD"

			

			_nTotalD4 := U_Qry2Array(_cQuery)
	
			//calcula o percentual do produto do empenho em todas as OPS incluidas.
			if len(_nTotalD4) > 0
				_nPercent := ROUND((_SD4->D4_QUANT/_nTotalD4[1,2]) *100,2)
			endif 


			// Busca acumulado do item no Z01 PRINCIPAL
			//_cQuery := " SELECT SUM(Z01_QTDINS)  "
			_cQuery := " SELECT  Z01_QTDINS, Z01_PRDAL1, Z01_QTDAL1, Z01_PRDAL2, Z01_QTDAL2   "
			_cQuery += " FROM " + RetSQLTab("Z01") 
			_cQuery += " WHERE D_E_L_E_T_ = '' "
			_cQuery += " AND Z01_FILIAL = '" + xFilial('Z01')   +"'" 
			_cQuery += " AND Z01_PRDINS = '" + alltrim(_SD4->D4_COD)     +"'"
			_cQuery += " AND Z01_LOCUSO = '1' "
			_cQuery += " AND Z01_DTCONS = '" + _dDataOp  +"'"
			//_cQuery += " GROUP BY Z01_FILIAL, Z01_DTCONS, Z01_PRDINS "
		
			_aZ01 := U_Qry2Array(_cQuery)
			if len(_aZ01) > 0
			
				_cProdAlt1 := _aZ01[1,2] 
				_nProdAlt1 := _aZ01[1,3] 
				_cProdAlt2 := _aZ01[1,4] 
				_nProdAlt2 := _aZ01[1,5] 


				//verifica acumulado Z01
				_nZ01Qtd := 0
				if len(_aZ01) > 0
					_nZ01Qtd := _aZ01[1,1] 
				endif 

				
				If _nZ01Qtd == 0 // Deleta SD4
					DbSelectArea("SD4")
					SD4->(DbSetOrder(2)) // D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
					If DbSeek(xFilial("SD4") + _sOP + _sProd)
						SD4->(RecLock("SD4",.F.))
						SD4->(DbDelete())
						SD4->(MsUnLock())
					EndIf
				Else
					// Realiza gravaÃ§Ã£o de SD4
					_nNovoQnt := (_nZ01Qtd * _nPercent)/100
					_sLocal   := posicione("SB1",1,xfilial("SB1")+TRA->PRODUTO,"B1_LOCCONS")

					// Realiza a gravaÃ§Ã£o da SD4
					DbSelectArea("SD4")
					SD4->(DbSetOrder(2)) 			// D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
					If DbSeek(xFilial("SD4") + _sOP + _sProd) 
						//If EMPTY(SD4->D4_QTDEORI)

							_nQuant := SD4->D4_QUANT
							_cLocalOri := SD4->D4_LOCAL
							_nSaldoOri := SD4->D4_QTDEORI
							Reclock("SD4",.F.)
							//if alltrim(_sLocal) <> alltrim(_cLocalOri)	
							SD4->D4_LOCAL   := _sLocal
							SD4->D4_FLOCANT := _cLocalOri
							//endif	
							SD4->D4_FSLDANT := _nQuant
							SD4->D4_FQTDANT := _nSaldoOri
							SD4->D4_QTDEORI := _nNovoQnt
							SD4->D4_QUANT   := _nNovoQnt	

							MsUnlock()
						//EndIf    D4_LOCAL,D4_QTDEORI,D4_QUANT
					Else
						//CONFORME falado com o evandro não tera essa situação
						//if empty(_sLocal)
						//	_sLocal   := posicione("SB1",1,xfilial("SB1")+TRA->PRODUTO,"B1_LOCPAD")
						//endif
						Reclock("SD4",.T.)
						SD4->D4_FILIAL  := xFilial("SD4")
						SD4->D4_COD     := TRA->PRODUTO
						SD4->D4_OP      := _sOP
						SD4->D4_LOCAL   := _sLocal
						SD4->D4_DATA    := DDATABASE
						SD4->D4_QTDEORI := _nNovoQnt
						SD4->D4_QUANT   := _nNovoQnt
						SD4->D4_DTVALID := DDATABASE
						// gravar esses campo mesmo quando vai criar um empenho
						SD4->D4_FLOCANT := _sLocal
						SD4->D4_FSLDANT := _nNovoQnt
						SD4->D4_FQTDANT := _nNovoQnt

						SD4->D4_ROTBLK  := AllTrim(FunName())
						MsUnlock()
					EndIf
					
					// AJUSTA SB2 produto principal
					_AjustaSB2(_sProd, _sLocal)

					//verifica se existe valor nos alternativos 1
					if !empty(_cProdAlt1)
						_nNovoQnt := (_nZ01Qtd * _nPercent)/100
						_sLocal   := posicione("SB1",1,xfilial("SB1")+_cProdAlt1,"B1_LOCCONS")
						// Realiza a gravaÃ§Ã£o da SD4
						DbSelectArea("SD4")
						SD4->(DbSetOrder(2)) 			// D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
						If DbSeek(xFilial("SD4") + _sOP + _cProdAlt1) 
							//If EMPTY(SD4->D4_QTDEORI)
							_nQuant := SD4->D4_QUANT
							_cLocalOri := SD4->D4_LOCAL
							_nSaldoOri := SD4->D4_QTDEORI
							Reclock("SD4",.F.)
							//if alltrim(_sLocal) <> alltrim(_cLocalOri)	
							SD4->D4_LOCAL   := _sLocal
							SD4->D4_FLOCANT := _cLocalOri
							//endif	
							SD4->D4_FSLDANT := _nQuant
							SD4->D4_FQTDANT := _nSaldoOri
							SD4->D4_QTDEORI := _nNovoQnt
							SD4->D4_QUANT   := _nNovoQnt	
							//EndIf
						Else
							//CONFORME falado com o evandro não tera essa situação
							//if empty(_sLocal)
							//	_sLocal   := posicione("SB1",1,xfilial("SB1")+TRA->PRODUTO,"B1_LOCPAD")
							//endif
							Reclock("SD4",.T.)
							SD4->D4_FILIAL  := xFilial("SD4")
							SD4->D4_COD     := _cProdAlt1
							SD4->D4_OP      := _sOP
							SD4->D4_LOCAL   := _sLocal
							SD4->D4_DATA    := DDATABASE
							SD4->D4_QTDEORI := _nNovoQnt
							SD4->D4_QUANT   := _nNovoQnt
							SD4->D4_DTVALID := DDATABASE
							// gravar esses campo mesmo quando vai criar um empenho
							SD4->D4_FLOCANT := _sLocal
							SD4->D4_FSLDANT := _nNovoQnt
							SD4->D4_FQTDANT := _nNovoQnt

							SD4->D4_ROTBLK  := AllTrim(FunName())
							MsUnlock()
						EndIf
						// AJUSTA SB2 alternativo 1
						_AjustaSB2(_cProdAlt2, _sLocal)
					endif

					//verifica se existe valor nos alternativos 2
					if !empty(_cProdAlt2)
						_nNovoQnt := (_nZ01Qtd * _nPercent)/100
						_sLocal   := posicione("SB1",1,xfilial("SB1")+_cProdAlt2,"B1_LOCCONS")
						// Realiza a gravaÃ§Ã£o da SD4
						DbSelectArea("SD4")
						SD4->(DbSetOrder(2)) 			// D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
						If DbSeek(xFilial("SD4") + _sOP + _cProdAlt2) 
							_nQuant := SD4->D4_QUANT
							_cLocalOri := SD4->D4_LOCAL
							_nSaldoOri := SD4->D4_QTDEORI
							Reclock("SD4",.F.)
							//if alltrim(_sLocal) <> alltrim(_cLocalOri)							
							SD4->D4_LOCAL   := _sLocal
							SD4->D4_FLOCANT := _cLocalOri
							//endif	
							SD4->D4_FSLDANT := _nQuant
							SD4->D4_FQTDANT := _nSaldoOri
							SD4->D4_QTDEORI := _nNovoQnt
							SD4->D4_QUANT   := _nNovoQnt	

						Else
							//CONFORME falado com o evandro não tera essa situação
							//if empty(_sLocal)
							//	_sLocal   := posicione("SB1",1,xfilial("SB1")+TRA->PRODUTO,"B1_LOCPAD")
							//endif
							Reclock("SD4",.T.)
							SD4->D4_FILIAL  := xFilial("SD4")
							SD4->D4_COD     := _cProdAlt2
							SD4->D4_OP      := _sOP
							SD4->D4_LOCAL   := _sLocal
							SD4->D4_DATA    := DDATABASE
							SD4->D4_QTDEORI := _nNovoQnt
							SD4->D4_QUANT   := _nNovoQnt
							SD4->D4_DTVALID := DDATABASE
							// gravar esses campo mesmo quando vai criar um empenho
							SD4->D4_FLOCANT := _sLocal
							SD4->D4_FSLDANT := _nNovoQnt
							SD4->D4_FQTDANT := _nNovoQnt
							SD4->D4_ROTBLK  := AllTrim(FunName())
							MsUnlock()
						EndIf
					endif

					// AJUSTA SB2 alternativo 2
					_AjustaSB2(_cProdAlt2, _sLocal)
					
				endif	
			EndIf

			DBSelectArea("_SD4")
			dbskip()
		Enddo
		_SD4->(DbCloseArea())
		DBSelectArea("TRA")
		dbskip()
	Enddo
	
	TRA->(DbCloseArea())

	_cQuery := " SELECT D4_OP, D4_COD, D4_QUANT, D4_DATA, D4_QTDEORI, D4_LOCAL, D4_FLOCANT "
	_cQuery += " FROM " + RetSQLTab("SD4")
	_cQuery += " WHERE D_E_L_E_T_ = ''"
	_cQuery += " AND D4_OP  in (" +  _sOps  +"'')"
	_cQuery := ChangeQuery(_cQuery)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), "_AJU", .F., .T.)
	While _AJU•->(!Eof())
		DbSelectArea("SD4")
		SD4->(DbSetOrder(2)) 			// D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
		If DbSeek(xFilial("SD4") + _AJU->D4_OP + _AJU->D4_COD) 
			If alltrim(_AJU->D4_FLOCANT) == ''
				Reclock("SD4",.F.)
				SD4->D4_FSLDANT := 0
				SD4->D4_FQTDANT := 0
				MsUnlock()
			Endif
		endif
		DBSelectArea("_AJU")
		dbskip()
	Enddo

	_AJU->(DbCloseArea())
	
Return
//
// ---------------------------------------------------------------------------------------
// Ajusta SB2
Static Function _AjustaSB2(_sProduto, _sLocal)
	Local _cQuery := ""
	
	_cQuery := " UPDATE SB2010 SET B2_QEMP = COALESCE((SELECT SUM(D4_QUANT) FROM SD4010 "
	_cQuery += " WHERE D_E_L_E_T_ = '' "
	_cQuery += " AND D4_FILIAL = '"+ xFilial('SD4') +"' "
	_cQuery += " AND D4_COD = B2_COD"
	_cQuery += " AND D4_LOCAL = B2_LOCAL"
	_cQuery += " AND D4_QUANT <> 0"
	_cQuery += " AND D4_COD    = '"+ _sProduto +"'"
	//_cQuery += " AND D4_LOCAL  = '"+ _sLocal   +"'"
	_cQuery += " GROUP BY D4_COD  ),0) "
	_cQuery += " WHERE D_E_L_E_T_ = '' AND B2_FILIAL ='"+ xFilial('SB2') +"' "
	TcSqlExec(_cQuery)
Return

//
// ---------------------------------------------------------------------------------------
// Cria tabela temporÃ¡ria
Static Function CriaTRB()

	Local aCampos     := {}
	Local cAliasArea  := ""
	Local oTrb        := Nil
	Local x

    AADD(aCampos,{ "TAB_OK", 	"C", 2,		0 	} )
	AADD(aCampos,{ "NUM", 		"C", 6, 	0 	} )
	AADD(aCampos,{ "ITEM", 		"C", 2, 	0 	} )
	AADD(aCampos,{ "SEQUEN", 	"C", 6, 	0	} )
	AADD(aCampos,{ "EMISSAO", 	"D", 8, 	0	} )
	AADD(aCampos,{ "PRODUTO", 	"C", 15, 	0	} )
	AADD(aCampos,{ "DESCRI", 	"C", 40, 	0	} )
	AADD(aCampos,{ "ARMAZEM", 	"C", 2, 	0	} )
	AADD(aCampos,{ "GRUPO", 	"C", 8, 	0	} )
	AADD(aCampos,{ "UM", 		"C", 2, 	0	} )
	AADD(aCampos,{ "QUANT", 	"N", 18,	7	} )

	oTrb := FWTemporaryTable():New()
	oTrb:SetFields(aCampos)

	oTrb:AddIndex("IDX1", {"NUM"})

	oTrb:Create()
	cAliasArea := oTrb:GetAlias()

	// Grava o arquivo temporÃ¡rio com os registros da selecao da query
	For x:=1 To Len(_aDadosPA)

		RecLock((cAliasArea), .T.)
		(cAliasArea)->NUM     := _aDadosPA[x,1]
		(cAliasArea)->ITEM    := _aDadosPA[x,2]
		(cAliasArea)->SEQUEN  := _aDadosPA[x,3]
		(cAliasArea)->EMISSAO := _aDadosPA[x,4]
		(cAliasArea)->PRODUTO := _aDadosPA[x,5]
		(cAliasArea)->DESCRI  := fBuscaCpo("SB1", 1, xFilial("SB1") + _aDadosPA[x,5], "B1_DESC")
		(cAliasArea)->ARMAZEM := _aDadosPA[x,6]
		(cAliasArea)->GRUPO   := _aDadosPA[x,7]
		(cAliasArea)->UM      := _aDadosPA[x,8]
		(cAliasArea)->QUANT   := _aDadosPA[x,9]
		MsUnlock((cAliasArea))

	Next

Return(oTrb)
