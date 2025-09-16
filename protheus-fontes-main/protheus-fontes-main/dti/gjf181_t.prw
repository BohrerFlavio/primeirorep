#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF181_T   ºAutor  ³Adonai Gabriel   ºData  ³  15/08/24     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina temporária para realizar a testes de produção       º±±
±±º          ³ da embalagem secundária como a GJF181.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DTI                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//////////////////////////////////////////////////////////
////////////////Funções para JOB /////////////////////////
//////////////////////////////////////////////////////////

//Função que vai fazer a pesagem das caixas via conexão socket (ethernet)
Static Function CaptIP()
	local _cString  := ''

	//nQtd = oObj:Receive(_cString,500)
    _cString  := FWInputBox("Informe o sequencial da pré-etiqueta:", "")

return _cString

//Função que acessa os parametros de rejeite
Static Function Rej(_emb,_msg1,_msg2)

	do case
	case _emb = 'EMB01'

		//Com DLL
		//PutMV('SI_REJ01',.T.)
        FWAlertError("Rejeite 1 acionado!"+chr(13)+chr(10)+_msg1+chr(13)+chr(10)+_msg2,"REJEITE")

	case _emb = 'EMB02'

		//Com DLL
		//PutMV('SI_REJ02',.T.)
        FWAlertError("Rejeite 2 acionado!"+chr(13)+chr(10)+_msg1+chr(13)+chr(10)+_msg2,"REJEITE")

	endcase

return
/*
---Função responsável   por realizar a leitura do codigo do produto
-Verifica se capturou string em branco
-Verifica se o codigo do produto é válido
-Verifica se os demais dados do produto são válidos
-Verifica ser há previsão de produção para esse produto
*/
Static Function Ler(_cString,_emb)

	_cNumPrev := ''
	_cPreDes  := ''
	_St1 := ''
	_St2 := ''
	_St3 := ''
	_St4 := ''
	_St5 := ''
	_St6 := ''
	_cSeq3:= ''
	_cSeq4 := ''
	_sFpre := ''
	_dDatdev := stod('')
	/* Buscar código da ZZR*/
	_cSeqPETQ := alltrim(substr(_cString,1,14))    //Sequencial da pré-etiqueta

	if empty(_cSeqPETQ)
		return .f.
	endif

	_sFpre := alltrim(substr(_cString,4,3)) 
	IF _sFpre != '000' 
		If ((len(alltrim(_cSeqPETQ)) < 14) .and. !empty(_cSeqPETQ))
			// Se tring for menor que 14 esta errada, então não fazer a troca de string
		elseIf  "*****************************" $ alltrim(_cString)
			//valida a String, se foi enviada incorretamente não usar
		else
			/* Bloco para o ajuste na string para validar na tabela ZZR
				OBS - Feito este ajuste para que a alteração na pré etiqueta 
				não afete o processo de produção.*/
			_St1 := alltrim(substr(_cString,1,2)) 
			_St2 := '000'
			_St3 := alltrim(substr(_cString,6,9))
			_cSeq3 := alltrim(_St1)+alltrim(_St2)+alltrim(_St3)
			/* Após ler o sequencial da etiqueta, retirar a familia da string para não dar problema na produção em geral.*/
			_cSeqPETQ := _cSeq3
			/* Gravar a string sem a Família para manter leitura como estava. */
			//_St4 := alltrim(substr(_cString,2,2)) 
			//_St5 := '000'
			//_St6 := alltrim(substr(_cString,7,30))
			//_cString :=  alltrim(_St4)+alltrim(_St5)+alltrim(_St6)
			/* Variáveis _cSeq3 e _cString deven ficar com o valor na string sem os 3 caracteres da familia .*/
			_cStrBal := _cString
		Endif
	Endif

	DbSelectArea('ZZR')
	ZZR->(DbSetOrder(3))	
	If ZZR->(MsSeek(FWxfilial('ZZR')+alltrim(_cSeqPETQ)))
		_cCodPro   := ZZR->ZZR_COD
		_dDataAbt  := ZZR->ZZR_DTABT
		_nQtCx	   := ZZR->ZZR_QTDCX
		_dDatdev   := ZZR->ZZR_DTDEV
	endif

	_cID      := ''

	if ((len(alltrim(_cSeqPETQ)) < 14) .and. !empty(_cSeqPETQ))

		_me1 := 'Erro de Leitura!'
		_me2 := 'Rejeite acionado'
		Rej(_emb,_me1,_me2)

		RegEv(_me1,'FA',_me2,1,_cString,_cCodPro,_emb,0,0)

		//_cLimpa := CaptIP()

		sleep(_nTime)

		return .f.

	elseif "*****************************" $ alltrim(_cString) //valida a String se foi enviada corretamente
		_me1 := 'Erro de Leitura!'
		_me2 := 'Rejeite acionado'
		Rej(_emb,_me1,_me2)

		RegEv(_me1,'FA',_me2,1,_cString,_cCodPro,_emb,0,0)

		//_cLimpa := CaptIP()

		sleep(_nTime)

		return .f.
	elseIf(ZZR->ZZR_REJ)
		// se variável True , então códigos de produtos diferentes. E sistema obrigatoriamente rejeita
		_me1 := 'Produto Errado na Caixa!'
		_me2 := 'Rejeite acionado'
		Rej(_emb,_me1,_me2)
		RegEv(_me1,'FA',_me2,1,_cString,_cCodPro,_emb,0,0)

		reclock('ZZR',.F.)
		ZZR->ZZR_REJ := .F.
		msunlock()

		//_cLimpa := CaptIP()

		sleep(_nTime)
		return .f.

	elseIf(ZZR->ZZR_CONTRO = 'xxxxxxxxxx')
		_me1 := 'Pre-bloqueada!'
		_me2 := 'Rejeite acionado'
		Rej(_emb,_me1,_me2)

		RegEv(_me1,'FA',_me2,1,_cString,_cCodPro,_emb,0,0)

		//_cLimpa := CaptIP()

		sleep(_nTime)

		return .f.
	endif

	//Verificação se o produto existe
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	if !SB1->(MsSeek(FWxfilial('SB1')+_cCodPro))
		_me1 := 'Producao Inexistente!'
		_me2 := 'Rejeite acionado'
		Rej(_emb,_me1,_me2)

		RegEv(_me1,'FA',_me2,2,_cStrBal,_cCodPro,_emb,0,0)

		//_climpa := CaptIP()

		sleep(_nTime)

		return .f.
	endif

	// regra para verificar se produto (_cCodPro) bate com registro da ZZR 

	_cSegUM := SB1->B1_SEGUM

	if _cSegUM = 'PC'
		_me1 := 'Este produto não é embalado em caixas!'
		_me2 := 'Rejeite acionado'

		Rej(_emb,_me1,_me2)
		RegEv(_me1,'FA',_me2,3,_cStrBal,_cCodPro,_emb,0,0)

		//_cLimpa := CaptIP()

		sleep(_nTime)
		return .f.
	endif

	// 3 ºVerificar se a caixa já foi pesada no dia
	//Em caso positivo, manda apenas re-imprimir
	//a etiqueta testeira. Em caso negativo, continua o processo de
	//produção da caixa
	/*
	quando produzir uma caixa nova, grava na ZZR o numero da caixa
	antes de produzir a caixa, preciso verificar na ZZR se o campo control já está preenchido, caso já esteja preenchido este campo na ZZR
	eu pego o valor do campo, posiciono na SZ8 pelo indice(3) e chamo de cara a função de impressão
	*/

	SZ8->(DbSetOrder(3))
	ZAS->(DbSetOrder(1))

	if SZ8->(MsSeek(FWxfilial('SZ8') + ZZR->ZZR_CONTRO)) .and. !empty(ZZR->ZZR_CONTRO)
		// Se entrou aqui a caixa já existe , então encaminhar para reimpressão
		_lProduz  := .f.
		_lPorc    := .f.
		_cControl := SZ8->Z8_CONTROL

		//Verifica se é produção de matéria-prima par porcionado
	elseif ZAS->(MsSeek(FWxfilial('ZAS') + ZZR->ZZR_CONTRO)) .and. !empty(ZZR->ZZR_CONTRO)
		// Se entrou aqui a caixa já existe , então encaminhar para reimpressão
		_lProduz  := .f.
		_lPorc    := .t.
		_cControl := ZAS->ZAS_CONTRO

	else
		/* Adaptação para mudar query de busc   */ 
		//4º Verificar se existe previsão de produção do produto.
		IF !empty(_dDatdev)
			_cQuery := "SELECT COUNT(ZU_COD) AS CONTA, ZU_COD AS CODIGO,ZU_NUM AS NUM, ZU_PREDES AS PREDES, ZU_MPPORC AS MPPORC"
			_cQuery += " FROM "+RetSqlTab("SZU")
			_cQuery += " WHERE " + RetSQLFil("SZU")
			_cQuery += " AND ZU_COD     = '"  + _cCodPro + "'"
			_cQuery += " AND ZU_FECHADO = 'N'"
			_cQuery += " AND ZU_PREDES <> ''"
			_cQuery += " AND ZU_DTDEV = '" + dtos(_dDatdev) + "'"
			_cQuery += " AND ZU_DTABT = '" + dtos(_dDataAbt) + "'"
			_cQuery += " AND (ZU_TIPO = 'P' OR (ZU_TIPO = 'R' AND ZU_REPAUT = 'S'))"
			_cQuery += " AND " + RetSQLDel("SZU")
			_cQuery += " GROUP BY ZU_COD, ZU_NUM, ZU_PREDES, ZU_MPPORC"
			_cQuery := ChangeQuery(_cQuery)			
		elseif !empty(_dDataAbt)
			_cQuery := "SELECT COUNT(ZU_COD) AS CONTA, ZU_COD AS CODIGO,ZU_NUM AS NUM, ZU_PREDES AS PREDES, ZU_MPPORC AS MPPORC"
			_cQuery += " FROM " + RetSqlTab("SZU")
			_cQuery += " WHERE " + RetSQLFil("SZU")
			_cQuery += " AND ZU_COD = '" + _cCodPro + "'"
			_cQuery += " AND ZU_FECHADO = 'N'"
			_cQuery += " AND ZU_DTDEV = ''"
			_cQuery += " AND ZU_PREDES <> ''"
			_cQuery += " AND ZU_DTPROD = '" + dtos(dDatabase) + "'"			
			_cQuery += " AND ZU_DTABT = '" + dtos(_dDataAbt) + "'"
			_cQuery += " AND (ZU_TIPO = 'P' OR (ZU_TIPO = 'R' AND ZU_REPAUT = 'S'))"
			_cQuery += " AND " + RetSQLDel("SZU")
			_cQuery += " GROUP BY ZU_COD, ZU_NUM, ZU_PREDES, ZU_MPPORC"
			_cQuery := ChangeQuery(_cQuery)
		Else
			_cQuery := "SELECT COUNT(ZU_COD) AS CONTA, ZU_COD AS CODIGO, ZU_NUM AS NUM, ZU_PREDES AS PREDES, ZU_MPPORC AS MPPORC"
			_cQuery += " FROM "+RetSqlTab("SZU")
			_cQuery += " WHERE " + RetSQLFil("SZU")
			_cQuery += " AND ZU_COD = '" + _cCodPro + "'"
			_cQuery += " AND ZU_FECHADO = 'N'"
			_cQuery += " AND ZU_DTDEV = ''"
			_cQuery += " AND ZU_PREDES <> ''"
			_cQuery += " AND ZU_DTPROD = '" + dtos(dDatabase) + "'"			
			_cQuery += " AND (ZU_TIPO = 'P' OR (ZU_TIPO = 'R' AND ZU_REPAUT = 'S'))"
			_cQuery += " AND " + RetSQLDel("SZU")
			_cQuery += " GROUP BY ZU_COD, ZU_NUM, ZU_PREDES, ZU_MPPORC"
			_cQuery := ChangeQuery(_cQuery)				
		Endif
		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		If Select("VER")<>0
			VER->(dbCloseArea())
		Endif

		TCQUERY _cQuery NEW ALIAS "VER"
		if VER->CONTA = 0
			_me1 := 'Producao Inexistente!'
			_me2 :=	'Rejeite acionado'

			Rej(_emb,_me1,_me2)
			RegEv(_me1,'FA',_me2,4,_cStrBal,_cCodPro,_emb,0,0)
			//_cLimpa := CaptIP()
			sleep(_nTime)
			return .f.
		endif

		_cPreEmb := VER->NUM
		_cPreDes := VER->PREDES

		//Vai usar essa variável lá na impressão de etiqueta...
		_lPorc := iif(VER->MPPORC == 'S',.t.,.f.)

		VER->(dbclosearea())

	endif

	//5º Coletar os dados necessários do produto para registro de produção
return .t.

//Função destinada a gravar os eventos da automação
Static Function RegEv(_desc,_status,_resp,_cod,_string,_prod,_emb,_pesob,_tara)

	Local _nID := ZA9->(RecCount()) + 1

	ZA9->(DbSetOrder(1))

	reclock('ZA9',.t.)
	ZA9->ZA9_FILIAL := FWxfilial('ZA9')
	ZA9->ZA9_ID     := _nID
	ZA9->ZA9_DESC   := _desc
	ZA9->ZA9_DATA   := date()
	ZA9->ZA9_HORA   := time()
	ZA9->ZA9_STATUS := _status
	ZA9->ZA9_COD    := _cod
	ZA9->ZA9_RESP   := _resp
	ZA9->ZA9_STRING := _String
	ZA9->ZA9_PROD   := _prod
	ZA9->ZA9_EMB    := _emb
	ZA9->ZA9_PESOB  := _pesob
	ZA9->ZA9_TARA   := _tara
	msunlock()

return

Static Function Etq(_emb)
	Local _cModo1  := GetMV('SI_MODEMB1')//modo da linha1
	Local _cModo2  := GetMV('SI_MODEMB2')//modo da linha2

	if _emb = 'EMB01'
		_cIpImp1 := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+_cEst,1))
	elseif _emb = 'EMB02'
		_cIpImp2 := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+_cEst,1))
	endif

	if _lPorc
		//Se é porcionado..
		//Utiliza o registro já setado da tabela ZAS
		ZAS->(DbSetOrder(1))
		if ZAS->(MsSeek(FWxfilial('ZAS')+_cControl))

			//verifica modo na linha 1
			if _emb = 'EMB01'
				if _cModo1 = '1'//se modo for 1 = automação
					u_GJF111g("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_PREDES,ZAS->ZAS_DTPROD,;
					(ZAS->ZAS_DTPROD+ZAS->ZAS_VALID),1,_cIpImp1,ZAS->ZAS_HORA)
				else//manual
					_cIpBkP1 := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+_cEst,1))//bkp linha 1
					u_GJF111k("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_PREDES,ZAS->ZAS_DTPROD,;
					(ZAS->ZAS_DTPROD+ZAS->ZAS_VALID),1,_cIpBkP1,ZAS->ZAS_HORA)
				endif
				//verifica modo na linha2 - Caixas Pardas
			elseif _emb = 'EMB02'
				if _cModo2 = '1'//se modo for 1 = automação
					u_GJF111h("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_PREDES,ZAS->ZAS_DTPROD,;
					(ZAS->ZAS_DTPROD+ZAS->ZAS_VALID),1,_cIpImp2,ZAS->ZAS_HORA)
				else
					_cIpBkp2 := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+_cEst,1))//bkp linha 2
					u_GJF111k("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_PREDES,ZAS->ZAS_DTPROD,;
					(ZAS->ZAS_DTPROD+ZAS->ZAS_VALID),1,_cIpBkP2,ZAS->ZAS_HORA)
				endif
			endif
		endif

		//Se for produção na embalagem
		//Registra a tabela de caixas normal SZ8
	else
		//  Caixas (PA) da Embalagem SZ8
		SZ8->(DbSetOrder(3))
		if SZ8->(MsSeek(FWxfilial('SZ8')+_cControl))

			//verifica modo na linha 1
			if _emb = 'EMB01'
				if _cModo1 = '1'//se modo for 1 = automação
					u_GJF111b("S600","IP",SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,;
					SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIpImp1,SZ8->Z8_SEQPETQ,SZ8->Z8_HORA)
				else //manual

					//U_testeZPL(SZ8->Z8_CONTROL)
					if alltrim(SZ8->Z8_COD) $ getMv('SI_PRDCHIN')
						u_etqZPLExterna(_cControl)
						u_etqZPLInterna()
					else
						cadmerc  := ALLTRIM(GetAdvFVal('SB1','B1_CADMERC',FWXFilial('SB1')+SZ8->Z8_COD,1))
						destino  := ALLTRIM(GetAdvFVal('SB1','B1_DESTINO',FWXFilial('SB1')+SZ8->Z8_COD,1))
						//conout("Impressa etiqueta " + alltrim(SZ8->Z8_CONTROL) + " do produto: " + alltrim(SZ8->Z8_COD) + " PE: " + alltrim(SZ8->Z8_SEQPETQ) +" c/ Destino: " + alltrim(destino) + " e c/ Mercado: " + alltrim(cadmerc))
						IF (destino = 'ME' .AND. cadmerc = 'U')
							//conout("Impressa etiqueta na impressora c/ IP: " + _cIpBkP3 + '/' + SZ8->Z8_CONTROL)						
							_cIpBkp3 := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+_cEst,1))//bkp linha 3
							U_EMBUSA("S600","IP",SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,;
							SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIpBkP3,SZ8->Z8_SEQPETQ,SZ8->Z8_HORA)							
						ELSE
							//conout("Impressa etiqueta na impressora c/ IP: " + _cIpBkP1)
							_cIpBkP1 := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+_cEst,1))//bkp linha 1
							u_GJF111f("S600","IP",SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,;
							SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIpBkP1,SZ8->Z8_SEQPETQ,SZ8->Z8_HORA)
						ENDIF
					endif

				endif
				//verifica modo na linha2
			elseif _emb = 'EMB02'
				if _cModo2 = '1' //se modo for 1 = automação					
					u_GJF111e("S600","IP",SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,;
					SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIpImp2,SZ8->Z8_SEQPETQ,SZ8->Z8_HORA)
				else //manual
						//cadmerc  := ALLTRIM(GetAdvFVal('SB1','B1_CADMERC',FWXFilial('SB1')+SZ8->Z8_COD,1))
						//destino  := ALLTRIM(GetAdvFVal('SB1','B1_DESTINO',FWXFilial('SB1')+SZ8->Z8_COD,1))
						//conout("Impressa etiqueta " + alltrim(SZ8->Z8_CONTROL) + " do produto: " + alltrim(SZ8->Z8_COD) + " PE: " + alltrim(SZ8->Z8_SEQPETQ) +" c/ Destino: " + alltrim(destino) + " e c/ Mercado: " + alltrim(cadmerc))
					_cIpBkp2 := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+_cEst,1))//bkp linha 2
					u_GJF111f("S600","IP",SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,;
					SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIpBkP2,SZ8->Z8_SEQPETQ,SZ8->Z8_HORA)					
				endif
			endif
		else
			FWAlertError('Não achou caixa ' + _cControl,"ERRO")
		endif

	endif

return .t.

//Faz a verificação de previsão
static function prev(_emb)

	Local _lGrv := .F.
	Local _lFech := .F.
	Local _nQtSM := 0

	SZU->(DbSetOrder(2))
	if !SZU->(MsSeek(FWxfilial('SZU')+_cPreEmb))
		_me1 := 'Producao inexistente!'
		_me2 := 'Rejeite acionado'
		Rej(_emb,_me1,_me2)
		RegEv(_me1,'FA',_me2,5,_cStrBal,_cCodPro,_emb,0,0)

		sleep(_nTime)
		return .f.
	endif

	_cCExat   := SZU->ZU_CONTEXA
	qPrevC    := SZU->ZU_QPCAIX
	qRealC    := SZU->ZU_QRCAIX
	qPrevP    := SZU->ZU_QPPESO
	qRealP    := SZU->ZU_QRPESO
	qPrevQ    := SZU->ZU_QPQUANT
	qRealQ    := SZU->ZU_QRQUANT

	overflow  := .f.
	overflow2 := .f.

	//Implementado campo ZU_TOLERA para tolerancias, onde o valor default é 10%. Caso não queira tolerancia
	//o PCP deverá zerar o campo na Previsão de Produção
	do case
	case SZU->ZU_PRIORI = "C"
		if SZU->(ZU_QPCAIX + round(ZU_QPCAIX *(ZU_TOLERA/100),0)) <= qRealC + 1
			if _cCExat = 'S'                      //Variavel que determina se o cumprimento da previsão deve ser exato ou não
				overflow := .t.                    //se a previsão foi cumprida, então o overflow determina o seu encerramento
			endif
		endif
	case SZU->ZU_PRIORI = "P"
		if SZU->(ZU_QPPESO + ZU_QPPESO * (ZU_TOLERA/100))  <= qRealP + _nPesoL
			if _cCExat = 'S'                      //Variavel que determina se o cumprimento da previsão deve ser exato ou não
				overflow := .t.                    //se a previsão foi cumprida, então o overflow determina o seu encerramento
			endif
		endif
	case SZU->ZU_PRIORI = "A"
		if (SZU->(ZU_QPPESO + ZU_QPPESO * (ZU_TOLERA/100)) <= qRealP + _nPesoL) .or. ;
				(SZU->(ZU_QPCAIX + ZU_QPCAIX * round((ZU_TOLERA/100),0)) <= qRealC + 1)
			if _cCExat = 'S'                      //Variavel que determina se o cumprimento da previsão deve ser exato ou não
				overflow := .t.                    //se a previsão foi cumprida, então o overflow determina o seu encerramento
			endif
		endif
	case SZU->ZU_PRIORI = "E"                //se a previsão for por peças. Não há tolerancia para peças
		if (qRealQ + _nQuant) > qPrevQ
			RegEv('Produção encerrada antecipadamente!','FA','Programação PCP',15,_cStrBal,_cCodPro,_emb,0,0)
			if _cCExat = 'S'                      //Variavel que determina se o cumprimento da previsão deve ser exato ou não
				overflow := .t.                    //se a previsão foi cumprida, então o overflow determina o seu encerramento
			endif
			overflow2 := .t.
		endif
	endcase

	reclock('SZU',.f.)

	if !empty(SZU->ZU_SHIPPIN)	// Controle de quantidade em Shipping Mark
		ZY2->(DbSetOrder(1))
		ZY2->(MsSeek(FWxFilial('ZY2')+SZU->ZU_SHIPPIN))
		if ZY2->ZY2_QTRCXS >= ZY2->ZY2_QTMCXS
			SZU->ZU_FECHADO := 'B'	// Bloqueia a OP ao chegar no número máximo de caixas
			_lFech := .T.
		elseif ZY2->ZY2_STATUS = "E"
			SZU->ZU_FECHADO := 'B'	// Bloqueia a OP se o Shipping Mark estiver encerrado
			_lFech := .T.
		else
			_nQtSM := ZY2->ZY2_QTRCXS + 1
			_lGrv := .T.
		endif
	endif

	if !overflow2 .and. !_lFech
		SZU->ZU_QRCAIX  := qRealC + 1
		SZU->ZU_QRPESO  := qRealP + _nPesoL
		SZU->ZU_QRQUANT := qRealQ + _nQuant
	endif

	if overflow .or. overflow2
		SZU->ZU_FECHADO := 'B'
		//Se for uma produção de MP para porcionados
		if _lPorc
			ZAR->(DbSetOrder(1))
			if ZAR->(MsSeek(FWxfilial('ZAR')+SZU->ZU_PREPORC))
				reclock('ZAR',.f.)
				ZAR->ZAR_EMP := 'N' //Não permite mais empenho de MP para a OP de porcionados
				msunlock()
			endif
		endif
	endif
	MsUnLock()

	if _lGrv	// Soma na quantidade real por Shipping Mark
		reclock('ZY2',.f.)
		ZY2->ZY2_QTRCXS := _nQtSM
		msunlock()
	endif

	if _lFech
		reclock('ZY2',.f.)
		ZY2->ZY2_STATUS := "E"
		msunlock()

		RegEv('OP encerrada! Shipping Mark no máximo.','FA','OP - ' + SZU->ZU_NUM,0,_cStrBal,_cCodPro,_emb,0,0)
	endif

	ret := iif(overflow2 .or. _lFech,.f.,.t.)

return  ret

//Função realiza o registro da produção
//na tabela SZ8 e demais tabelas
Static Function Registro(_emb)

	Local _nDiasVal
	Local _cDesc
	Local _cClassif

	//Setar a previsão de produção
	SZU->(DbSetOrder(2))
	if !SZU->(MsSeek(FWxfilial('SZU')+_cPreEmb))
		return .f.
	endif

	//Setar o cadastro do produto
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	if !SB1->(MsSeek(FWxfilial('SB1')+_cCodPro))
		return .f.
	endif

	_nDiasVal  := SB1->B1_VALID
	_cDesc     := SB1->B1_DESCRED
	_cGrupo	   := SB1->B1_GRUPO
	_cFarm 	   := GetAdvFval('SBM','BM_FARM',FWxfilial('SBM')+_cGrupo,1)

	//Verifica se a produção é de Matéria-prima para porcionado
	if SZU->ZU_MPPORC == "S"

		_cID :=  GetSx8num('SZ8','Z8_ID')
		ConfirmSx8()

		_cControl := '00' + _cID

		_cLote := ''
		ZAR->(DbSetOrder(1))
		if ZAR->(MsSeek(FWxfilial('ZAR')+SZU->ZU_PREPORC)) .and. !empty(SZU->ZU_PREPORC)
			_cLote    := ZAR->ZAR_LOTE
			_cPreporc := SZU->ZU_PREPORC
		else
			//Verifica se houve aglutinação de OPs para a deossa/embalagem
			ZAR->(DbSetOrder(6))
			if  ZAR->(MsSeek(FWxfilial('ZAR')+SZU->ZU_NUM))
				_cLote    := ZAR->ZAR_LOTE
				_cPreporc := ZAR->ZAR_NUM
			elseif !empty(SZU->ZU_LOTEPOR)
				_cPreporc := 'MANUAL'
				_cLote  := SZU->ZU_LOTEPOR
			else
				_cPreporc := 'MANUAL'
			endif
		endif

		// Salva na SZW para controle de rastreabilidade
		reclock('SZW',.t.)
		SZW->ZW_FILIAL    := FWxfilial('ZAS')
		SZW->ZW_CONTROL   := _cControl
		SZW->ZW_COD       := _cCodPro
		SZW->ZW_DATA      := date()
		SZW->ZW_DATAP     := SZU->ZU_DTPROD
		SZW->ZW_HORA      := time()
		SZW->ZW_TIPO      := SZU->ZU_TIPO
		SZW->ZW_TF        := SZU->ZU_TF
		if SB1->B1_PESFIX <> 0
			SZW->ZW_PESFIX := SB1->B1_PESFIX
			SZW->ZW_PESO   := SB1->B1_PESFIX
			SZW->ZW_PESOBR := (SB1->B1_PESFIX + _nTara)
		else
			SZW->ZW_PESO      := _nPesoL
			SZW->ZW_PESOBR    := _nPeso
		endif
		SZW->ZW_QUANT     := _nQuant
		SZW->ZW_TARA      := _nTara
		SZW->ZW_VALID	  := _nDiasVal
		SZW->ZW_DATAVAL   := (SZU->ZU_DTPROD + _nDiasVal)
		SZW->ZW_BALAN     := _emb
		SZW->ZW_DESCRI    := _cDesc
		SZW->ZW_OPERA     := cUserName
		SZW->ZW_NUMPREV   := _cPreEmb
		SZW->ZW_PREDES    := _cPreDes
		SZW->ZW_SEQPETQ   := _cSeqPETQ
		SZW->ZW_ORIGEM    := 'P'
		SZW->ZW_SETPRO    := 'P'
		SZW->ZW_FARM      := _cFarm
		SZW->ZW_TIPOPRO	  := 'MP'
		SZW->ZW_PREPOR    := _cPreporc
		SZW->ZW_LOTE      := _cLote
		msunlock()
		// Salva na ZAS para manter o padrão dos outros fontes
		reclock('ZAS',.t.)
		ZAS->ZAS_FILIAL  := FWxfilial('ZAS')
		ZAS->ZAS_CONTRO  := _cControl
		ZAS->ZAS_COD     := _cCodPro
		ZAS->ZAS_DESC    := _cDesc
		ZAS->ZAS_DTPROD  := SZU->ZU_DTPROD
		ZAS->ZAS_VALID   := _nDiasVal
		ZAS->ZAS_PESOL   := _nPesoL
		ZAS->ZAS_PESOB   := _nPeso
		ZAS->ZAS_TARA    := _nTara
		ZAS->ZAS_PREPOR  := _cPreporc
		ZAS->ZAS_PREEMB  := _cPreEmb
		ZAS->ZAS_PREDES  := _cPreDes
		ZAS->ZAS_TIPO    := 'MP'
		ZAS->ZAS_SEQPET  := _cSeqPETQ
		ZAS->ZAS_TERC	 := 'N'
		ZAS->ZAS_LOTE    := _cLote
		ZAS->ZAS_TF      := SZU->ZU_TF
		ZAS->ZAS_HORA    := time()
		ZAS->ZAS_SETPRO  := 'P'
		ZAS->ZAS_FARM    := _cFarm
		ZAS->ZAS_LIN	 := iif(_emb = 'EMB01', 'E01', 'E02')
		msunlock()

	else

		_cClassif  := GetAdvFval('SZ2','Z2_CLASSIF',FWxfilial('SZ2')+_cPreDes,2)

		_cID :=  GetSx8num('SZ8','Z8_ID')
		ConfirmSx8()

		_cControl := '00' + _cID

		// validação feita para confirmar vinda da data de devolução da pré-etiqueta
		If !empty(SZU->ZU_DTDEV)
			_dDtValidade := SZU->ZU_DTDEV + _nDiasVal
		Else
			_dDtValidade := SZU->ZU_DTPROD + _nDiasVal
		Endif

		//Validação para confirmar a existencia de data de abate na OP
		If !empty(SZU->ZU_DTABT)
			// Validade esta sendo formada a partir da data de produção da OP
			_dDtValidade := SZU->ZU_DTPROD + _nDiasVal
		Else
			MsgAlert("Atenção", "A Previsão da desossa atrelada não possui data de abate. Contate o PCP")
		Endif

		reclock('SZ8',.t.)
		SZ8->Z8_FILORI    := cFilAnt
		SZ8->Z8_FIL       := cFilAnt
		SZ8->Z8_FILIAL    := FWxfilial('SZ8')
		SZ8->Z8_ID        := _cID
		SZ8->Z8_CONTROL   := _cControl
		SZ8->Z8_CODORI    := _cCodPro
		SZ8->Z8_COD       := _cCodPro
		SZ8->Z8_DATA      := date()
		SZ8->Z8_DATAP     := SZU->ZU_DTPROD
		SZ8->Z8_HORA      := time()
		SZ8->Z8_TIPO      := SZU->ZU_TIPO
		SZ8->Z8_TF        := SZU->ZU_TF
		SZ8->Z8_QUANT     := _nQuant
		if SB1->B1_PESFIX <> 0
			SZ8->Z8_PESFIX := SB1->B1_PESFIX
			SZ8->Z8_PESO   := SB1->B1_PESFIX
			SZ8->Z8_PESOBR := (SB1->B1_PESFIX + _nTara)
		else
			SZ8->Z8_PESO      := _nPesoL
			SZ8->Z8_PESOBR    := _nPeso
		endif
		SZ8->Z8_TARA      := _nTara
		SZ8->Z8_TARAS     := _nTS
		SZ8->Z8_ETIQ      := 'P'//SZU->ZU_ETIQ
		SZ8->Z8_DATAVAL   := _dDtValidade
		SZ8->Z8_BALAN     := _emb
		SZ8->Z8_DESCRI    := _cDesc
		SZ8->Z8_OPERA     := cUserName
		SZ8->Z8_NUMPREV   := _cPreEmb
		SZ8->Z8_PREDES    := _cPreDes
		SZ8->Z8_MDESP     := 'N'
		SZ8->Z8_CLASSIF   := _cClassif
		SZ8->Z8_SEQPETQ   := _cSeqPETQ
		SZ8->Z8_DTENTES   := date()
		SZ8->Z8_LOTE      := SZU->ZU_LOTE
		SZ8->Z8_ORIGEM    := 'P'
		SZ8->Z8_SETPRO    := 'E'
		SZ8->Z8_FARM      := _cFarm
		msunlock()

		FWAlertInfo("Caixa Salva na SZ8", "INFO")
		//grava o histórico da caixa
		u_gjf17his(1,'PRODUCAO',.f.,'','','000012', _cControl)
	endif

	//grava caixa na pre-etiqueta
	reclock('ZZR',.f.)
	ZZR->ZZR_UTIL := 'S'
	ZZR->ZZR_CONTRO := _cControl
	msunlock()

return .t.

//Função destinada a executar o processo
//Captura do codigo, pesagem, atualização da previsão e
//registro de produção

Static Function PrEMB(_emb)

	_cString := ''

	//Limpeza das variáveis principais
	_cCodPro  := ''
	_cControl := ''
	_nQuant   := 0
	_nPMPec   := 0.00
	//_nPeso    := 0.00
	//_nPesoL   := 0.00
	_nTara    := 0.00
	_cPreEmb  := ''
	_cPreDes  := ''
	_cStrBal  := ''
	_cSeqPETQ := ''
	_dDataAbt := stod('')
	_lProduz  := .t.
	_lPorc    := .f.
	_cFim     := ''
	_ParCod   := alltrim(GETMV('SI_PRDQTCX'))+alltrim(GETMV('SI_PRDQTC2'))+alltrim(GETMV('SI_PRDQTC3'))

	//Captura peso e código
	_cString := CaptIP()

	//Para armazenar o string coletado sem tratamento
	_cStrBal := _cString

	//Verifica validação da leitura do codigo
	if !Ler(_cString,_emb)
		return .f.
	else

		//Verifica se houve leitura de peso da caixa
		//na função leitura() tratando a string já
		//validada com os dados do codigo do produto
		//e retirando o valor numerico do peso
		// _lProduz: Este flag é para verificar se a caixa deve
		//realmente efetivar uma produção ou apenas reimprimir
		//uma etiqueta, de acordo com a leitura da pré-etiqueta
		// tratar o _lProduz , se caixa ja produzida _lProduz recebe .F.
		if _lProduz

			//_nPeso := val(substr(_cString,17,13))

			/*  Ajuste da leitura do peso*/
			/*_cFim     := substr(_cString,23,1)     //caracter verficador do final do string
			_cLimpa   := ''
			if _cFim <> chr(03)

				_me1 := 'Erro de Leitura' + _cLimpa
				_me2 := 'Rejeite acionado'
				FWAlertWarning(_me1 + ' -> ' + _me2, "ALERTA")
				Rej(_emb,_me1,_me2)

				RegEv(_me1,'FA',_me2,6,_cStrBal,_cCodPro,_emb,0,0)

				//_cLimpa := CaptIP()

				sleep(_nTime)

				return .f.
			endif*/

			//Se peso zerado exclui a leitura do codigo
			//do produto invalidando a pesagem
			if _nPeso <= 0

				_me1 := 'Peso Inexistente!'
				_me2 := 'Rejeite acionado'
				FWAlertWarning(_me1 + ' -> ' + _me2, "ALERTA")
				Rej(_emb,_me1,_me2)

				RegEv(_me1,'FA',_me2,7,_cStrBal,_cCodPro,_emb,0,0)

				//_cLimpa := CaptIP()

				sleep(_nTime)
				return .f.

			else

				DbSelectArea('SB1')
				SB1->(DbSetOrder(1))
				if !SB1->(MsSeek(FWxfilial('SB1')+_cCodPro))
					//Se entrou nessa condição é porque houve falha
					//então o rejeite deve ser acionado pois a caixa
					//já passou
					_me1 := 'Falha na Pesagem!'
					_me2 := 'Rejeite acionado'
					FWAlertWarning(_me1 + ' -> ' + _me2, "ALERTA")
					Rej(_emb,_me1,_me2)
					RegEv(_me1,'FA',_me2,8,_cStrBal,_cCodPro,_emb,0,0)
					sleep(_nTime)

					return .f.
				endif

				If _nQtCx > 0 .and. (alltrim(_cCodPro) $ _ParCod)
					_nQuant := _nQtCx
				Else
					_nQuant := SB1->B1_QCAIX
				EndIf

				_nPMPec := SB1->B1_PMPEC       //Busca o peso médio por peças
				_nTaraS := SB1->B1_CTARASE     //Linhas inseridas para buscar
				_nTS    := GetAdvFval('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTaraS),1)  // os campos de codigo das taras secundaria
				_nTaraP := SB1->B1_CTARAP      // Linhas inseridas para buscar"_NTARAp"
				_nTP    := GetAdvFval('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTaraP),1)  // os campos de codigo das taras primarias

				_nTara  := _nTS + (_nTP * _nQuant)
				_nPesoL := _nPeso - _nTara

				_lPesMinD := getMV('SI_PESMIND') //PARAMETRO QUE ATIVA OU DESATIVA A VALIDAÇÃO DO PESO MINIMO
				_lPesMinT := getMV('SI_PESMINT')
				_lPMC	  := getMV('SI_PESMINC')

				/*----------------------------------------------------
				Verificação de excesso de peso de acordo com intervalos
				de peso mínimo e máximo da SB1
				------------------------------------------------------*/

				_nPMaxSB1 := SB1->B1_PESMAX
				_nPMinSB1 := SB1->B1_PESOMIN
				_lRejLib:= .T.

				if (Empty(_nPMaxSB1))
					_nPMaxSB1:= 0.0
				endif

				if (Empty(_nPMinSB1))
					_nPMinSB1:= 0.0
				endif

				DO CASE
					CASE allTrim(SB1->B1_CORORI) == "D"
					_lRejLib := _lPesMinD

					CASE allTrim(SB1->B1_CORORI) == "T"
					_lRejLib := _lPesMinT

					CASE allTrim(SB1->B1_CORORI) == "C"
					_lRejLib := _lPMC

					OTHERWISE
					_lRejLib := .T.
				ENDCASE
				if (_lRejLib)

					if(_nPMinSB1 == 0.0)
						_me1 := 'Peso Minimo!'
						_me2 := 'Rejeite acionado'
						Rej(_emb,_me1,_me2)

						RegEv(_me1,'FA',_me2,9,_cStrBal,_cCodPro,_emb,0,0)

						//_cLimpa := CaptIP()

						sleep(_nTime)
						return .F.
					endif

					if (_nPMaxSB1 == 0.0)
						_me1 := 'Peso Maximo!'
						_me2 := 'Rejeite acionado'
						Rej(_emb,_me1,_me2)

						RegEv(_me1,'FA',_me2,9,_cStrBal,_cCodPro,_emb,0,0)

						//_cLimpa := CaptIP()

						sleep(_nTime)
						return .F.

					endif

					if (_nPeso < _nPMinSB1)
						_me1 := 'Peso Minimo!'
						_me2 := 'Rejeite acionado'
						Rej(_emb,_me1,_me2)

						RegEv(_me1,'FA',_me2,9,_cStrBal,_cCodPro,_emb,0,0)

						//_cLimpa := CaptIP()

						sleep(_nTime)
						return .F.
					endif

					if (_nPeso > _nPMaxSB1)
						_me1 := 'Peso Maximo!'
						_me2 := 'Rejeite acionado'
						Rej(_emb,_me1,_me2)

						RegEv(_me1,'FA',_me2,9,_cStrBal,_cCodPro,_emb,0,0)

						//_cLimpa := CaptIP()

						sleep(_nTime)
						return .F.
					endif
				endif

				//Linha para determinar a quantidade de peças por caixa conforme o peso médio de peças
				//Se o campo B1_PMPEC (Cadastro de produtos - pasta Silva) estiver preenchido, faz o calculo
				_nQuant := iif(_nPMPec <> 0.00,round(_nPesoL/_nPMPec,0),_nQuant)

				if _nPesoL <= 0
					_me1 := 'Peso Inexistente!'
					_me2 := 'Rejeite acionado'

					Rej(_emb,_me1,_me2)
					RegEv(_me1,'FA',_me2,10,_cStrBal,_cCodPro,_emb,_nPeso,_nTara)
					sleep(_nTime)
					return .f.
				endif

				//Bloco para validar o peso capturado com a tara da embalagem
				do case
					//Caixa pequena
					case (_nTS >= 0.400 .and. _nTS <= 0.520)
					if !(_nPesoL >= 5 .and. _nPesoL <= 18)
						_me1 := 'Peso Inexistente!'
						_me2 := 'Rejeite acionado'
						Rej(_emb,_me1,_me2)
						RegEv(_me1,'FA',_me2,12,_cStrBal,_cCodPro,_emb,_nPeso,_nTara)
						sleep(_nTime)
						return .f.
					endif
					//Caixa grande
					case (_nTS >= 0.600 .and. _nTS <= 1.100)
					if !(_nPesoL >= 0.001 .and. _nPesoL <= 31) //era 6
						_me1 := 'Peso Inexistente!'
						_me2 := 'Rejeite acionado'
						Rej(_emb,_me1,_me2)
						RegEv(_me1,'FA',_me2,13,_cStrBal,_cCodPro,_emb,_nPeso,_nTara)
						sleep(_nTime)
						return .f.
					endif
					//Caixa plástica
					// Pedido de alteração feito por Henrique Jardim
					case (_nTS >= 1.960 .and. _nTS <= 3.5)
					if !(_nPesoL >= 0.001 .and. _nPesoL <= 40)//era 2300
						_me1 := 'Peso Inexistente!'
						_me2 := 'Rejeite acionado'
						Rej(_emb,_me1,_me2)
						RegEv(_me1,'FA',_me2,14,_cStrBal,_cCodPro,_emb,_nPeso,_nTara)
						sleep(_nTime)
						return .f.
					endif
					//Caso não haja nenhuma situação prevista de tara
					otherwise
					_me1 := 'Tara desconhecida!'
					_me2 := 'Rejeite acionado'
					Rej(_emb,_me1,_me2)
					RegEv(_me1,'FA',_me2,15,_cStrBal,_cCodPro,_emb,0,0)
					sleep(_nTime)
					return .f.
				endcase
				//Fim do bloco de validação do peso pela tara das embalagem
			endif

			if Prev(_emb)     //Função que verifica e atualiza a Previsão de Produção
				FWAlertSuccess('Caixa produzida | String = ' + _cStrBal, "SUCESSO")
				Registro(_emb) //Função que realiza o registro da pesagem
				Etq(_emb)      //função que realiza a impressão da etiqueta
				RegEv('Registro efetivado','OK','Etiqueta enviada',0,_cStrBal,_cCodPro,_emb,_nPeso,_nTara)

				ZA9->(DbGotop())
			else
				return .f.
			endif
		//else //Bloco abaixo apenas imprime a etiqueta já impressa
			//Etq(_emb)  //função que realiza a impressão da etiqueta
			//RegEv('Produção já existente!','OK','Re-Impressão de etiqueta',16,_cStrBal,_cCodPro,_emb,0,0)
		endif

	endif
	sleep(_nTime)
return .t.

///////////////////FUNÇÃO DE JOB DA EMBALAGEM Nº 1////////////////////
Static Function EMB01()

	Private _cCodPro  := ''
	Private _cSeqPETQ := ''
	Private _nQuant   := 0
	Private _nPeso    := 22.68 // Variável para simular peso
	Private _nPesoL   := 0
	Private _nTara    := 0
	Private _cPreEmb  := ''
	Private _cPreDes  := ''
	Private _testPes  := 40
	Private _cControl := ''
	Private _cStrBal  := ''
	Private _nTime    := 1000   //tempo em milissegundos usado para frear o loop de produção
	Private _nQtCx 	  := 0
	Private _cEst     := getComputerName()

	ZA9->(DbSetOrder(1))
	ZA9->(DbGoTop())

	//_cString := CaptIP()

	while FWAlertYesNo("Gerar novo registro de caixa na linha 01?","CONFIRMA")
		PrEMB('EMB01')
	enddo
Return

///////////////////FUNÇÃO DE JOB DA EMBALAGEM Nº 2////////////////////
Static Function EMB02()

	Private _cCodPro  := ''
	Private _cSeqPETQ := ''
	Private _nQuant   := 0
	Private _nPeso    := 22.68 // Variável para simular peso
	Private _nPesoL   := 0
	Private _nTara    := 0
	Private _cPreEmb  := ''
	Private _cPreDes  := ''
	Private _testPes  := 40
	Private _cControl := ''
	Private _cStrBal  := ''
	Private _nQtCx    := 0
	Private _nTime    := 1000   //tempo em milissegundos usado para frear o loop
    Private _cEst     := getComputerName()

	ZA9->(DbSetOrder(1))
	ZA9->(DbGoTop())

	//_cString := CaptIP()

	while FWAlertYesNo("Gerar novo registro de caixa na linha 02?","CONFIRMA")
		PrEMB('EMB02')
	enddo

Return


User Function GJF181_T()

    if FWAlertYesNo("Utilizar linha 01 ou 02? (Sim = 01 e Não = 02)","ESCOLHA")
        EMB01()
    else
        EMB02()
    endif

Return
