#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "GPER030.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR35  ºAutor  ³Mauricio Roehrs  º Data ³  12/05/14 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Codigo Fonte destinado para geração do arquivo texto para  º±±
±±º          ³ impressão do recibo de pagamento                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Departamento Pessoal                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MLR35()
	Private _aTexto 	:= {}
	Private _cTexto 	:= ''
	Private cIPerg  	:= "MLR35"
	Private aCampos   	:= {}
	Private cArq
	Private aStru     	:= {}
	Private _lOk 		:= .t.
	Private _cQuery   	:= ""

	if !pergunte(cIPerg,.t.)
		return
	endif

	if mv_par02 = 1
		geraQryFol()
	elseif mv_par02 = 2
		geraQry13()
	endif

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	MsgRun("Aguarde... Criando arquivo de trabalho...",,{||  criaArq() })	//função que cria o arquivo de trabalho

	//criaArq()

	//-----------------||----------------------\\
	if _lOk //lista dados para arquivo de caixas
		Processa({||listaDados()},"LISTAGEM DE DADOS","Realizando seleção dos dados de peças..." )
	endif
	if _lOk //Gera o arquivo de caixas
		//	Processa({||geraArq() },"GERAÇÃO DE ARQUIVO","Realizando geração de arquivo..." )
		MsgRun("Aguarde... Gerando arquivo texto...",,{||  geraArq() })
	endif
Return

Static Function listaDados()

	if !_lOk
		return
	endif

	_nQuant := 0
	_nreg := 0

	//Contagem()
	MsgRun("Aguarde... Realizando contagem de registros...",,{||  Contagem() })

	ProcRegua(_nQuant)

	_cont 	:= 0
	_lGerado := .f.
	_cMat := ''
	TRB->(DbGoTop())
	while TRB->(!eof())
		//_cMat := TRB->MAT
		incproc('Listando matricula:' + TRB->MAT + ' para o arquivo...')
		DbSelectArea('SM0')

		/*verifica a situação e a categoria do funcionario*/
		//		_cSitFunc := fBuscaCPO('SRA',1,TRB->FILIAL + TRB->MAT,'RA_SITFOLH')
		//		_cCatFunc := fBuscaCPO('SRA',1,TRB->FILIAL + TRB->MAT,'RA_CATFUNC')
		//		if !(_cSitFunc $ mv_par11) .or. !(_cCatFunc $ mv_par12)
		//		TRB->(DbSkip())
		//		loop
		//		endif

		SM0->(DbSetORder(1))
		SM0->(DbSeek(cEmpAnt + cFilAnt))
		if _cMat <> TRB->MAT
			/*-----------DADOS DA EMPRESA(REGISTRO TIPO 1)------------*/
			_Identificador := '1'
			_TpDemonst		:= padr(iif(mv_par02 = 1, 'Folha Mensal','13 Salario'),50,'')
			_mesAno			:= padr(mesExtenso(MONTH(mv_par01)) +"/"+ str(year(mv_par01),4),20,'')
			_NomeCom  		:= padr(alltrim(SM0->M0_NOMECOM),60,'')
			_endEmp			:= padr(alltrim(SM0->M0_ENDENT),60,'')
			_bairroEmp		:= padr(alltrim(SM0->M0_BAIRENT),20,'')
			_compEmp		:= padr(alltrim(SM0->M0_COMPCOB),25,'')
			_cidadeEmp		:= padr(alltrim(SM0->M0_CIDENT),60,'')
			_estEmp			:= padr(alltrim(SM0->M0_ESTENT),2,'')
			_cepEmp			:= padr(alltrim(SM0->M0_CEPENT),8,'')
			_cnpjEmp   		:= padr(alltrim(SM0->M0_CGC),14,'')
			_filEmp			:= padr(alltrim(cFilAnt),6,'')
			_nomeFil		:= padr(alltrim(fBuscaCpo('SM0',1,cEmpAnT + cFilAnt,'M0_CIDENT') ),15,'')

			_cTexto := _Identificador + _TpDemonst + _mesAno + _nomeCom + _endEmp + _bairroEmp + _compEmp + _cidadeEmp + _estEmp + _cepEmp + _cnpjEmp + _filEmp + _nomeFil
			Aadd(_aTexto,_cTexto)
			/*--------------------------------------------------------------*/

			/*-----------MENSAGEM DE PAGAMENTO(REGISTRO TIPO 2)------------*/
			_Identificador := '2'
			_MSG1          := space(100)
			_MSG2		   := space(100)
			_MSG3		   := space(100)
			_dtPag		   := alltrim(strzero(day(mv_par01),2)) + "/" + alltrim(strzero(month(mv_par01),2)) + "/" + alltrim(str(year(mv_par01),4))

			_cTexto := _Identificador + _MSG1 + _MSG2 + _MSG3 + _dtPag
			Aadd(_aTexto,_cTexto)
			/*--------------------------------------------------------------*/

			/*-----------DADOS DO FUNCIONARIO(REGITRO TIPO 3)------------*/
			_cCodFunc   := fBuscaCPO('SRA',1,TRB->FILIAL + TRB->MAT,'RA_CODFUNC')
			_dDataAdm 	:= fBuscaCPO('SRA',1,TRB->FILIAL + TRB->MAT,'RA_ADMISSA')

			_Identificador := '3'
			_nomeFunc 		:= padr(alltrim(fBuscaCPO('SRA',1,TRB->FILIAL + TRB->MAT,'RA_NOME')),70,'')
			_descFunc 		:= padr(alltrim(fBuscaCPO('SRJ',1,xFilial('SRJ') + _cCodFunc,'RJ_DESC')),20,'')
			_matFunc  		:= padr(alltrim(TRB->MAT),6,'')
			_nDpSalFam	  	:= strzero(val(alltrim(fBuscaCPO('SRA',1,TRB->FILIAL + TRB->MAT,'RA_DEPSF'))),2)
			_nDpSalIr		:= strzero(val(alltrim(fBuscaCPO('SRA',1,TRB->FILIAL + TRB->MAT,'RA_DEPIR'))),2)
			_centroCusto    := padr(alltrim(TRB->CC),9,'')
			_descCC         := padr(alltrim(fBuscaCPO('CTT',1,xFilial('CTT') + TRB->CC,'CTT_DESC01')),40,'')
			_BcoAgencia		:= strzero(val(alltrim(strtran(fBuscaCPO('SRA',1,TRB->FILIAL + TRB->MAT,'RA_BCDEPSA'),'/',''))),8)
			_numConta		:= strzero(val(alltrim(fBuscaCPO('SRA',1,TRB->FILIAL + TRB->MAT,'RA_CTDEPSA'))),12)
			_salBase		:= padl(alltrim(transform(fBuscaCPO('SRA',1,TRB->FILIAL + TRB->MAT,'RA_SALARIO'),'@E 999999999.99')),12,'')
			_dtAdmiss		:= alltrim(strzero(day(_dDataAdm),2)) + "/" + alltrim(strzero(month(_dDataAdm),2)) + "/" + alltrim(str(year(_dDataAdm),4))

			_cTexto := _Identificador + _nomeFunc + _descFunc + _matFunc + _nDpSalFam + _nDpSalIr + _centroCusto + _descCC + _bcoAgencia +;
				_numConta + _salBase + _dtAdmiss
			Aadd(_aTexto,_cTexto)
			/*--------------------------------------------------------------*/

			/*-----------Descrição Demonstrativo(REGISTRO TIPO 4)------------*/
			_nTotCred  := 0
			_nTotDebt  := 0
			_nValLiq   := 0
			_nCntrInss := 0 //salario contr. INSS
			_nBaseFgts := 0 //base de calc para fgts
			_nFgts     := 0 //base fgts
			_nFgts13   := 0 //base fgts 13º salario
			_nFgtsMes  := 0 //Fgts do mes A recolher
			_nPd731    := 0
			_nPd768    := 0
			_nAliq	   := 0.00 //Aliquota IRRF
			_nBaseIRRF := 0
			_nIrAdi    := 0 //ir adiantamento

			if mv_par02 = 1 //caso folha mensal
				QryPdFol(TRB->MAT,TRB->FILIAL)
			elseif mv_par02 = 2//caso 13º salario
				QryPd13(TRB->MAT,TRB->FILIAL)
			endif

			while TMP2->(!eof())
				_rvTipoCod := alltrim(fBuscaCpo('SRV',1,xFilial('SRV') + TMP2->PD,'RV_TIPOCOD'))
				//if (_rvTipoCod <> '3'  .and. !empty(_rvTipoCod)) .or. (TMP2->PD == '720')
				//if (_rvTipoCod <> '3'  .and. !empty(_rvTipoCod))
				if _rvTipoCod == '1' .or. _rvTipoCod == '2' .or. TMP2->PD == '720' .or. TMP2->PD == '900' .or. TMP2->PD == '901' .or. TMP2->PD == '920'
					_Identificador  := '4'
					_codVerba		:= TMP2->PD
					_descVerba		:= padr(alltrim(fBuscaCpo('SRV',1,xFilial('SRV') + TMP2->PD,'RV_DESC')),20,'')
					_refVerba		:= padl(alltrim(transform(TMP2->HORAS,'@E 999.99')),6,'')
					_valVerba		:= padl(alltrim(transform(iif(_codVerba $ '900/901/920', 0, TMP2->VALOR),'@E 999999999.99')),12,'')
					_tpVerba		:= iif(_rvTipoCod = '1', 'C','D')

					_cTexto := _Identificador + _codVerba + _descVerba + _refVerba + _valVerba + _tpVerba
					Aadd(_aTexto,_cTexto)

					if _rvTipoCod = '1'
						_nTotCred += TMP2->VALOR
					endif

					if _rvTipoCod = '2'
						_nTotDebt += TMP2->VALOR
					endif

				endif

				if mv_par02 = 1//folha
					/*valores diveros conforme as respectivas verbas*/
					if TMP2->PD $ '799/730'
						_nValLiq := TMP2->VALOR

					elseif TMP2->PD = '721'
						_nCntrInss := TMP2->VALOR

					elseif TMP2->PD = '731'
						_nPd731 := TMP2->VALOR

					elseif TMP2->PD = '768'
						_nPd768 := TMP2->VALOR

					elseif TMP2->PD = '766'
						_nFgts := TMP2->VALOR

					elseif TMP2->PD = '797'
						_nFgts13 := TMP2->VALOR

					elseif TMP2->PD $ '706'
						_nBaseIRRF := TMP2->VALOR

					endif

					_nFgtsMes := _nFgts + _nFgts13
					_nBaseFgts := _nPd731 + _nPd768

				elseif mv_par02 = 2//13º
					/*valores diveros conforme as respectivas verbas*/
					if TMP2->PD $ '799/730'
						_nValLiq := TMP2->VALOR

					elseif TMP2->PD $ '721/733'
						_nCntrInss := TMP2->VALOR

					elseif TMP2->PD $ '731/768'
						_nBaseFgts := TMP2->VALOR

					elseif TMP2->PD = '766'
						_nFgts := TMP2->VALOR

					elseif TMP2->PD = '797'
						_nFgts13 := TMP2->VALOR

					elseif TMP2->PD $ '706/726'
						_nBaseIRRF := TMP2->VALOR
					endif

					_nFgtsMes := _nFgts + _nFgts13
				endif

				/*aliquotas do IRRF*/
				if _nBaseIRRF > 1787.77  .and. _nBaseIRRF <= 2679.29
					_nAliq := 7.5

				elseif _nBaseIRRF >= 2679.30 .and. _nBaseIRRF <= 3572.43
					_nAliq := 15

				elseif _nBaseIRRF >= 3572.44 .and. _nBaseIRRF <= 4463.81
					_nAliq := 22.50

				elseif _nBaseIRRF > 4463.81
					_nAliq := 27.50
				endif

				TMP2->(DbSkip())
			enddo
			/*--------------------------------------------------------------*/

			/*-----------Total das Contas(REGISTRO TIPO 5)------------*/
			_Identificador := '5'
			_totProventos  := padl(alltrim(transform(_nTotCred,'@E 999999999.99')) ,12,'')
			_totDescontos  := padl(alltrim(transform(_nTotDebt,'@E 999999999.99')) ,12,'')
			_valLiquido	   := padl(alltrim(transform(_nValLiq ,'@E 999999999.99')) ,12,'')
			_salContrInss  := padl(alltrim(transform(_nCntrInss,'@E 999999999.99')),12,'')
			_CalcFGTS 	   := padl(alltrim(transform(_nBaseFgts,'@E 999999999.99')),12,'')
			_baseCalcIrrf  := padl(alltrim(transform(_nBaseIRRF,'@E 999999999.99')),12,'')
			_fgtsDoMes	   := padl(alltrim(transform(_nFgtsMes,'@E 999999999.99')) ,12,'')
			_aliqIRRF	   := padl(alltrim(transform(_nAliq,'@E 999.99')),6,'')

			_cTexto := _Identificador + _totProventos + _totDescontos + _valLiquido + _salContrInss + _CalcFGTS +  _fgtsDoMes + _baseCalcIrrf  + _aliqIRRF
			Aadd(_aTexto,_cTexto)
			/*--------------------------------------------------------------*/

			/*-----------Mensagens Externas(REGISTRO TIPO 6)------------*/
			_Identificador := '6'
			_msgExt1 	   := space(70)
			_msgExt2 	   := space(70)
			_msgExt3	   := space(70)

			_cTexto := _Identificador + _msgExt1 + _msgExt2 + _msgExt3
			Aadd(_aTexto,_cTexto)
			/*--------------------------------------------------------------*/
			_cMat := TRB->MAT
		endif
		TRB->(DbSkip())
	EndDo

Return

Static Function geraArq()

	Local nTamLin, cLin, cCpo
	Local _x

	Private cString  := ""
	//Private cArqTxt := "C:\FOLHA.txt"
	Private cArqTxt := alltrim(mv_par11) + ".txt"
	Private nHdl    := fCreate(cArqTxt)
	Private cEOL    := "CHR(13)+CHR(10)"

	if !_lOk
		return
	endif

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	cCpo 	:= ""

	For _X := 1 to Len(_aTexto)
		cCpo  := _aTexto[_X]+cEOL
		fWrite(nHdl,cCpo,Len(cCpo))
	Next

	fClose(nHdl)

	msgbox('Arquivo gerado com sucesso!','FIM DE PROCESSAMENTO','INFO')

Return

Static Function Contagem()

	while TRB->(!eof())
		_nQuant++
		TRB->(DbSkip())
	enddo
return

/*FUNÇÃO PARA GERAR QUERY COM RELAÇÃO DAS INFORMAÇÕES DO FUNCIONARIO*/
/*COM BASE NOS CALCULOS DA FOLHA MENSAL*/
/*QUERY UTILIZADA SOMENTE PARA CRIAÇÃO DO ARQUIVO DE TRABALHO função criaArq()*/
Static Function geraQryFol()
	Local _ano := substr(mv_par13,1,2)
	Local _mes := substr(mv_par13,3,2)

	/*se for mensal*/
	if mv_par12 = 1
		_cQuery := " SELECT RC_FILIAL AS FILIAL, RC_MAT AS MAT, RC_PD AS PD, RC_HORAS AS HORAS, RC_VALOR AS VALOR,RC_CC AS CC, RC_DATA AS DATAPG, RA_NOME"
		_cQuery += " FROM " + retSqlTab('SRC') +  " , " + retSqlTab('SRA')
		_cQuery += " WHERE RC_DATA <> '' AND RC_MAT = RA_MAT"
		_cQuery += " AND RC_FILIAL BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
		_cQuery += " AND RA_FILIAL BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
		_cQuery += " AND RC_CC     BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
		_cQuery += " AND RC_MAT    BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
		_cQuery += " AND " + retSqlDel('SRC') + " AND " + retSqlDel('SRA')
		_cQuery += " ORDER BY RC_CC, RA_NOME, RC_MAT, RC_PD

	else

		_cQuery := " SELECT RD_FILIAL AS FILIAL, RD_MAT AS MAT, RD_PD AS PD, RD_HORAS AS HORAS, RD_VALOR AS VALOR,RD_CC AS CC, RD_DATPGT AS DATAPG, RA_NOME"
		_cQuery += " FROM " + retSqlTab('SRD') +  " , " + retSqlTab('SRA')
		_cQuery += " WHERE RD_DATPGT <> '' AND RD_MAT = RA_MAT"
		_cQuery += " AND RD_FILIAL BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
		_cQuery += " AND RA_FILIAL BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
		_cQuery += " AND RD_CC     BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
		_cQuery += " AND RD_MAT    BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
		_cQuery += " AND RD_PERIODO = '" + mv_par13 + "' AND RD_ROTEIR = 'FOL' "
		_cQuery += " AND " + retSqlDel('SRD') + " AND " + retSqlDel('SRA')
		_cQuery += " ORDER BY RD_CC, RA_NOME, RD_MAT, RD_PD

	endif

	_cQuery := ChangeQuery(_cQuery)

return

/*FUNÇÃO PARA GERAR QUERY COM RELAÇÃO DAS INFORMAÇÕES DO FUNCIONARIO*/
/*COM BASE NOS CALCULOS DO 13º SALARIO*/
/*QUERY UTILIZADA SOMENTE PARA CRIAÇÃO DO ARQUIVO DE TRABALHO função criaArq()*/
Static Function geraQry13()
	Local _ano := substr(mv_par13,1,2)
	Local _mes := substr(mv_par13,3,2)

	/*se for mensal*/
	if mv_par12 = 1

		_cQuery := " SELECT RI_FILIAL AS FILIAL, RI_MAT AS MAT, RI_PD AS PD, RI_HORAS AS HORAS, RI_VALOR AS VALOR, RI_CC AS CC, RI_DATA AS DATAPG, RA_NOME"
		_cQuery += " FROM " + retSqlTab('SRI') +  " , " + retSqlTab('SRA')
		_cQuery += " WHERE RI_DATA <> '' AND RI_MAT = RA_MAT"
		_cQuery += " AND RI_FILIAL BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
		_cQuery += " AND RA_FILIAL BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
		_cQuery += " AND RI_CC     BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
		_cQuery += " AND RI_MAT    BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
		_cQuery += " AND " + retSqlDel('SRI') + " AND " + retSqlDel('SRA')
		_cQuery += " ORDER BY RI_CC, RA_NOME, RI_MAT, RI_PD

	else

		_cQuery := " SELECT RD_FILIAL AS FILIAL, RD_MAT AS MAT, RD_PD AS PD, RD_HORAS AS HORAS, RD_VALOR AS VALOR,RD_CC AS CC, RD_DATPGT AS DATAPG, RA_NOME"
		_cQuery += " FROM " + retSqlTab('SRD') +  " , " + retSqlTab('SRA')
		_cQuery += " WHERE RD_DATPGT <> '' AND RD_MAT = RA_MAT"
		_cQuery += " AND RD_FILIAL BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
		_cQuery += " AND RA_FILIAL BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
		_cQuery += " AND RD_CC     BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
		_cQuery += " AND RD_MAT    BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
		_cQuery += " AND RD_PERIODO = '" + mv_par13 + "' AND RD_ROTEIR = '132' "
		_cQuery += " AND " + retSqlDel('SRD') + " AND " + retSqlDel('SRA')
		_cQuery += " ORDER BY RD_CC, RA_NOME, RD_MAT, RD_PD

	endif

	_cQuery := ChangeQuery(_cQuery)

return

Static Function GeraTMP()

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"
return

/*FUNÇÃO PARA GERAR QUERY COM RELAÇÃO DAS VERBAS DO FUNCIONARIO*/
/*COM BASE NOS CALCULOS DA FOLHA MENSAL*/
Static Function QryPdFol(_Matricula,_Filial)

	Local _ano := substr(mv_par13,1,2)
	Local _mes := substr(mv_par13,3,2)

	/*se for mensal*/
	if mv_par12 = 1
		_cQuery2 := " SELECT RC_MAT AS MAT, RC_PD AS PD, RC_HORAS AS HORAS, RC_VALOR AS VALOR
		_cQuery2 += " FROM " + retSqlTab('SRC')
		_cQuery2 += " WHERE RC_MAT  = '" + _Matricula + "'"
		_cQuery2 += " AND RC_FILIAL = '" +   _Filial  + "'"
		_cQuery2 += " AND RC_DATA <> ''"
		_cQuery2 += " AND " + retSQlDel('SRC')
		_cQuery2 += " ORDER BY RC_PD

	else
		_cQuery2 := " SELECT RD_MAT AS MAT, RD_PD AS PD, RD_HORAS AS HORAS, RD_VALOR AS VALOR
		_cQuery2 += " FROM " + retSqlTab('SRD')
		_cQuery2 += " WHERE RD_MAT  = '" + _Matricula + "'"
		_cQuery2 += " AND RD_FILIAL = '" +   _Filial  + "'"
		_cQuery2 += " AND RD_DATPGT <> ''"
		_cQuery2 += " AND RD_PERIODO = '" + mv_par13 + "' AND RD_ROTEIR = 'FOL' "
		_cQuery2 += " AND " + retSQlDel('SRD')
		_cQuery2 += " ORDER BY RD_PD

	endif

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"
return

/*FUNÇÃO PARA GERAR QUERY COM RELAÇÃO DAS VERBAS DO FUNCIONARIO*/
/*COM BASE NOS CALCULOS DO 13º SALARIO*/
Static Function QryPd13(_Matricula,_Filial)

	Local _ano := substr(mv_par13,1,2)
	Local _mes := substr(mv_par13,3,2)

	/*se for mensal*/
	if mv_par12 = 1

		_cQuery2 := " SELECT RI_MAT AS MAT, RI_PD AS PD, RI_HORAS AS HORAS, RI_VALOR AS VALOR
		_cQuery2 += " FROM " + retSqlTab('SRI')
		_cQuery2 += " WHERE RI_MAT  = '" + _Matricula + "'"
		_cQuery2 += " AND RI_FILIAL = '" +   _Filial  + "'"
		_cQuery2 += " AND RI_DATA <> ''"
		_cQuery2 += " AND " + retSQlDel('SRI')
		_cQuery2 += " ORDER BY RI_PD

	else

		_cQuery2 := " SELECT RD_MAT AS MAT, RD_PD AS PD, RD_HORAS AS HORAS, RD_VALOR AS VALOR
		_cQuery2 += " FROM " + retSqlTab('SRD')
		_cQuery2 += " WHERE RD_MAT  = '" + _Matricula + "'"
		_cQuery2 += " AND RD_FILIAL = '" +   _Filial  + "'"
		_cQuery2 += " AND RD_DATPGT <> ''"
		_cQuery2 += " AND RD_PERIODO = '" + mv_par13 + "' AND RD_ROTEIR = '132' "
		_cQuery2 += " AND " + retSQlDel('SRD')
		_cQuery2 += " ORDER BY RD_PD

	endif

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"
return

/*Função para criar arquivo de trabalho com base nas informações geradas pelas funções geraQryFol() e geraQry13*/
Static Function criaArq()
	//If Select("TRB") != 0
	//	TRB->(dbCloseArea())
	//Endif

	//cArq  := CriaTrab( Nil, .F. )

	aadd(aCampos,{"FILIAL"  ,"FILIAL"		,""})
	aadd(aCampos,{"MAT"    	,"Matricula"   	,""})
	aadd(aCampos,{"PD"   	,"Verba"		,""})
	aadd(aCampos,{"HORAS" 	,"Horas"     	,""})
	aadd(aCampos,{"VALOR" 	,"Valor"      	,""})
	aadd(aCampos,{"CC" 		,"Centro Custo"	,""})
	aadd(aCampos,{"DATAPG" 	,"Datapg"      	,""})

	aadd(aStru,{"FILIAL"	, "C",  02, 0,   "@!"          , 'FILIAL		'})
	aadd(aStru,{"MAT"    	, "C",  06, 0,   "@!"          , 'Matricula		'})
	aadd(aStru,{"PD" 		, "C",  03, 0,   "@!"          , 'Verba			'})
	/*Case palha pq os campos "HORA" das tabelas SRC e SRI tem tamanho diferente(TOTVS FÉLADAPUTA)*/
	do case
	case mv_par02 = 1 /*caso for folha mensal*/
		aadd(aStru,{"HORAS"		, "N",  06, 0,   "@!"    		 , 'Horas 			'})
	case mv_par02 = 2 /*caso for 13º salario*/
		aadd(aStru,{"HORAS"		, "N",  07, 0,   "@!"    		 , 'Horas 			'})
	endcase
	aadd(aStru,{"VALOR"		, "N",  12, 2,   "@!"    		 , 'Valor		 	'})
	aadd(aStru,{"CC"  		, "C",  09, 0,   "@!" 			 , 'Centro Custo	'})
	aadd(aStru,{"DATAPG"	, "D",  08, 0,   "@!"    		 , 'Datapg	 		'})

	//dbcreate(cArq,aStru)
	//dbUseArea( .T.,,cArq,"TRB", .F. , .F. )

	_aArqTrb :={}
	If Select('TRB')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TRB->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TRB", aStru, {}, @_aArqTrb)

	TRB->(DbGotop())
	TMP->(DbGoTop())
	while TMP->(!eof())

		/*verifica a situação e a categoria do funcionario*/
		_cSitFunc := fBuscaCPO('SRA',1,TMP->FILIAL + TMP->MAT,'RA_SITFOLH')
		_cCatFunc := fBuscaCPO('SRA',1,TMP->FILIAL + TMP->MAT,'RA_CATFUNC')
		if !(_cSitFunc $ mv_par09) .or. !(_cCatFunc $ mv_par10)
			TMP->(DbSkip())
			loop
		endif

		DbSelectArea('TRB')
		reclock('TRB',.t.)
		TRB->FILIAL := TMP->FILIAL
		TRB->MAT	:= TMP->MAT
		TRB->PD		:= TMP->PD
		TRB->HORAS	:= TMP->HORAS
		TRB->VALOR	:= TMP->VALOR
		TRB->CC		:= TMP->CC
		TRB->DATAPG := stod(TMP->DATAPG)
		msunlock()
		TMP->(DbSkip())
	enddo

return
