#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE "Fileio.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³gen01  º Autor ³ Flavio Bohrer Flores  º Data ³  25/03/25   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotinas que serve para Reimpressão de Etiqueta GPA 	      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/* Rotina criada para reimpressão de etiquetas GPA - Solicitado pela Adriana e Fábio s*/
User Function DTI222()
    Private aItens := {}
	Private cPerg     := "GEN01"
	
	if !pergunte(cPerg,.t.)
		return
	endif

	MsgRun("Aguarde... Realizando o processamento dos registros...",,{|| GeraTMP()})
								
    _cEst := getComputerName()
	_cIp := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+_cEst,1))

	SZ8->(DbSetOrder(3))
    SZ8->(DbGoTop())
	TMP->(dbGoTop())

	While TMP->(!EOF())
	
        if SZ8->(MsSeek(FWxfilial('SZ8') + TMP->Z8_CONTROL))
           alert('Control -'+SZ8->Z8_CONTROL)
			gen02("S600","IP",_cIp,TMP->Z8_CONTROL,,)
			RecLock("SZ8",.F.)
				SZ8->Z8_OBS := alltrim(MV_PAR03)			
            MsUnlock()
        endif
		TMP->(dbSkip()) 

	Enddo
	MS_FLUSH()

Return


Static Function GeraTMP()


	_cQuery := "SELECT Z8_CONTROL"
	_cQuery += " FROM  " + RetSQLTab('SZ8')
    _cQuery += " WHERE " + retSqlFil('SZ8')
	_cQuery += " AND Z8_COD = '"+MV_PAR01+"'"
    _cQuery += " AND Z8_PREPED = '"+MV_PAR02+"'"
	_cQuery += " AND Z8_SSCC <> ''"  
	_cQuery += " AND " + retSqlDel('SZ8')
	_cQuery += " ORDER BY Z8_CONTROL"

	_cQuery  := ChangeQuery(_cQuery)
	
	//	//	* Mostrar a consulta */
	//	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//	@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//	Activate Dialog oDlgMemo
	

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

Return


Static Function gen02(_modelo,_porta,_ip,_cControl,_pesoPallet,_taraStrech)

	Local cPrinter  := ''
	Private _sPl 	:= Chr(13) + Chr(10)
	Private _cCmd   := ""   
	Private _cgrp := getMv('SI_POR0001')

	SZ8->(dbSetOrder(3))
	SZ8->(dbGoTop())
	if SZ8->(MsSeek(FwxFilial('SZ8') + alltrim(_cControl)))
		_nPesLiq  := 0.00
		_nPesBrt  := 0.00
		_nQtdCx   := 0
		_nTaraEmb := 0.00
		_dDtValid := SZ8->Z8_DATAVAL
		cProd := SZ8->Z8_COD

		SB1->(DbSetOrder(1))
		SB1->(MsSeek(FWxfilial('SB1')+cProd))

		/* Dia 24/05/22 Ajuste da regra solicitado por Lucinéia para quando produtos forem dos porcionados imprimam só a data produção do Z8_DATAP */
		_cGRUPO := SB1->B1_GRUPO
		If _cgrp $ alltrim(_cGRUPO)
			// se for produtos dos porcionados (conforme grupo)
			_dDtProd  := SZ8->Z8_DATAP
		else
			if !empty(SZ8->Z8_PREDES)
				SZ2->(DbSetOrder(2))
				if  SZ2->(MsSeek(Fwxfilial('SZ2')+SZ8->Z8_PREDES))					
					/* Dia 06/12/22 - Tratando no chamado 2927 , Fizemos essa troca para impressão da etiqueta */
					_dDtProd  := SZ8->Z8_DATAP
				endif
			else	
				_dDtProd  := SZ8->Z8_DATAP
			endif
		Endif

		//verfica se o campo do peso fixo possui valor
		//se tiver faz os calculos de acordo com o peso informado
		//esse valor é preenchido de acordo com o valor preenchido no cadastro do produto (B1_PESFIX) 
		if SZ8->Z8_PESFIX <> 0
			_nPesLiq  := SZ8->Z8_PESFIX
			_nPesBrt  := SZ8->Z8_PESFIX + SZ8->Z8_TARA
		else
			_nPesLiq  := SZ8->Z8_PESO
			_nPesBrt  := SZ8->Z8_PESOBR
		endif

		_nTaraTot := SZ8->Z8_TARA

		_nQtdCx   := SZ8->Z8_QUANT

		_cEst := getComputerName()
		
		cPrinter := Alltrim(GetAdvFVal('ZAM','ZAM_PATHPS',FWxFilial('ZAM')+_cEst,1))

		//codigo de serie da unidade logistica, utilizado na rastreabilidade do palete
		_cSSCC := GetAdvFVal('SZ8','Z8_SSCC',FwxFilial('SZ8') + alltrim(SZ8->Z8_CONTROL),3)

		// IdentIficador do Produto
		_cCodBar  	:= SB1->B1_CODBAR
		_cDescSif 	:= SB1->B1_DESCSIF
		_cDescri    := SB1->B1_DESCRED
		_codTrEmb   := SB1->B1_CTARAP
		_codTrCx    := SB1->B1_CTARASE
		_cMensTemp  := SB1->B1_MENETQ2
		_nTrEmb 	:= GetAdvFVal('ZAB','ZAB_TARA',FwxFilial('ZAB') + alltrim(_codTrEmb),1)
		_nTaraCx  	:= GetAdvFVal('ZAB','ZAB_TARA',FwxFilial('ZAB') + alltrim(_codTrCx),1)
		_cCod13  	:= SB1->B1_CODBAR
		_cDun14		:= SB1->B1_DUN14
		_cUm		:= SB1->B1_UM

		_nTaraEmb   := _nQtdCx * _nTrEmb

		//Peso Liquido
		_cPesLiq := alltrim(strtran(transform(_nPesLiq,'@E 99.99'),',',''))

		//Peso Bruto
		_cPesBrt := alltrim(strtran(transform(_nPesBrt,'@E 99.99'),',',''))

		//Total de Caixas no Pallet
		_cTotCx := transform(_nQtdCx,'@E 99') //strzero(_nQtdCx,3)

		//Tara Total
		_nTotTara := _nTaraTot

		//Data de validade
		_sDtValid := dtos(_dDtValid)
		_cDtValid := alltrim(substr(_sDtValid,3,6))

		//Data de produção
		_sDtProd := dtos(_dDtProd)
		_cDtProd := alltrim(substr(_sDtProd,3,6))

		//Nº de registro de processador - Nº do Registro do Fornecedor no Sif com Iso do Pais(076+1733)
		_cIf := getMv('MV_NUMIF')
		_cIa7030 := '0760' + alltrim(_cIf)

		//Lote das caixas do palete
		_cLote := alltrim(_cDtProd)

		cPEAN14 := getMV('SI_CDEAN14')
		cPEan142 := getMV('SI_CEAN142')
		cPEan143 := getMV('SI_CEAN143')
		cPEan144 := getMV('SI_CEAN144')
		cPEan145 := getMV('SI_CEAN145')

		//verifica se é um produto que possui DUN14
		//se for gera etiqueta com padrao peso fixo
		if !(alltrim(cProd) $ (Alltrim(cPEan14)+Alltrim(cPEan142)+Alltrim(cPEan143)+Alltrim(cPEan144)+Alltrim(cPEan145)))
			_cEan13  := '1' + substr(_cCod13,1,12)
			_cDig    := EAN14(_cEan13)
			_cod14   := _cEan13 + _cDig
			_cCodBar := _cod14
		endif

		if _cUm = 'UN'
			//etiqueta caixa peso fixo
			etqCxPf()
		else
			//etiqueta caixa peso variavel
			etqCxPv()
		endif

		// Arquivo da etiqueta
		Memowrite("\etiquetas\etq601com.tmp",_cCmd)

		cComando := "I:\etq601com.bat "+ AllTrim(cPrinter)
		
		WinExec(cComando)
		sleep(1000)

	endif

return


static function EAN14(cCod13)
	Local nOdd := 0
	Local nEven := 0 
	Local nI
	Local nDig  
	Local nMul := 10 
	For nI := 1 to 13
		If (nI%2) == 0
			nEven += val(substr(cCod13,nI,1))
		Else
			nOdd += val(substr(cCod13,nI,1))
		Endif
	Next
	nDig := nEven + (nOdd*3)
	While nMul<nDig
		nMul += 10 
	Enddo
Return strzero(nMul-nDig,1)


Static Function etqCxPv()

	_cCmd += "" + _sPl

	// Setup Etiqueta em ZPL
	_cCmd += "CT~~CD,~CC^~CT~" + _sPl
	_cCmd += "^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR2,2~SD15^JUS^LRN^CI0^XZ" + _sPl
	_cCmd += "^XA" + _sPl
	_cCmd += "^MMT" + _sPl
	_cCmd += "^PW831" + _sPl
	_cCmd += "^LL1678" + _sPl
	_cCmd += "^LS0" + _sPl

	// Código GS1-128
	_cCmd += "^BY3,3,200^FT233,1575^BCB,,N,N,,N" + _sPl//1589

	if 	_nQtdCx = 1
		_nTotCx := _cTotCx
	else
		_nTotCx := '01' 
	endif


	_cCmd += "^FD>;>801" + AllTrim(_cDun14)/*iif(_cUm = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14))*/ + "3102" + StrZero(Val(_cPesLiq),6) + "3302" + StrZero(Val(_cPesBrt),6) + "37>6" + _nTotCx +"^FS" + _sPl
	_cCmd += "^FT268,1575^A0B,25,24^FD(01)" + AllTrim(_cDun14)/*iif(_cUm = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14))*/ + "(3102)" + StrZero(Val(_cPesLiq),6) + "(3302)" + StrZero(Val(_cPesBrt),6) + "(37)" + _nTotCx + "^FS" + _sPl
	

	_cCmd += "^BY3,3,197^FT496,1575^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>815" + _cDtValid + "11" + _cDtProd + "7030" + _cIa7030 + ">810>6" + _cLote + "^FS" + _sPl
	_cCmd += "^FT531,1575^A0B,25,24^FD(15)" + _cDtValid + "(11)" + _cDtProd + "(7030)" + _cIa7030 + "(10)" + _cLote + "^FS" + _sPl

	_cCmd += "^BY5,3,207^FT769,1575^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>800" + AllTrim(_cSSCC) + "^FS" + _sPl
	_cCmd += "^FT802,1575^A0B,25,24^FD(00)" + AllTrim(_cSSCC) + "^FS" + _sPl

	// Detalhes
	_cCmd += "^FT65,491^A0B,22,19^FH\^FDSSCC" + AllTrim(_cSSCC) + "^FS" + _sPl
	_cCmd += "^FT102,492^A0B,20,19^FH\^FD" + _cDescSIf + "^FS" + _sPl
	_cCmd += "^FT133,492^A0B,17,16^FH\^FDCONTENT/CONTEUDO:^FS" + _sPl
	_cCmd += "^FT174,492^A0B,25,24^FH\^FD" + _cDescri + "^FS" + _sPl

	// Detalhes 2
	_cCmd += "^FT234,497^A0B,20,19^FH\^FDBATCH/LOTE: " + _cLote + "^FS" + _sPl	
	_cCmd += "^FT301,497^A0B,20,19^FH\^FDPROD.DATE/DATA DE PRODUCAO :  " + DToC(_dDtProd) + "^FS" + _sPl
	_cCmd += "^FT335,498^A0B,20,19^FH\^FDSELL  BY  /  DATA  DE  VALIDADE :  " + DToC(_dDtValid) + "^FS" + _sPl

	// Pesos
	_cCmd += "^FT381,504^A0B,17,16^FH\^FDPACKING TARE/TARA EMBALAGEM:^FS" + _sPl
	_cCmd += "^FT383,176^A0B,20,19^FH\^FD"  + Transform(_nTaraEmb,"@E 999.999") + "^FS" + _sPl
	_cCmd += "^FT430,504^A0B,20,19^FH\^FDBOX TARE/TARA DA CAIXA:^FS" + _sPl
	_cCmd += "^FT429,231^A0B,23,24^FH\^FD"  + Transform(_nTaraCx,"@E 999.999") + "^FS" + _sPl

	_cCmd += "^FT479,504^A0B,20,19^FH\^FDTOTAL TARE/TARA TOTAL:^FS" + _sPl
	_cCmd += "^FT479,231^A0B,23,24^FH\^FD" + Transform(_nTotTara,"@E 999,999.999") + "^FS" + _sPl
	_cCmd += "^FT527,504^A0B,20,16^FH\^FDGROSS WEIGHT/PESO BRUTO:^FS" + _sPl
	_cCmd += "^FT527,234^A0B,23,24^FH\^FD" + Transform(_nPesBrt,"@E 999,999.99") + "^FS" + _sPl
	_cCmd += "^FT576,504^A0B,20,19^FH\^FDNET WEIGHT/PESO LIQUIDO:^FS" + _sPl
	_cCmd += "^FT575,234^A0B,23,24^FH\^FD" + Transform(_nPesLiq,"@E 999,999.99") + "^FS" + _sPl

	_cCmd += "^FT633,505^A0B,25,24^FH\^FDPROCESSOR/Processador: " + _cIa7030 +" ^FS" + _sPl
	_cCmd += "^FT681,505^A0B,20,19^FH\^FD" + AllTrim(_cMensTemp) + "^FS" + _sPl
	_cCmd += "^FT722,505^A0B,28,28^FH\^FDGTIN: " + AllTrim(_cDun14)/*iif(_cUm = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14))*/ + "^FS" + _sPl

	_cCmd += "^BY3,3,60^FT790,505^BCB,,N,N,,N^FD>;" + AllTrim(_cDun14) + "^FS" + _sPl

	_cCmd += "^FT575,67^A0B,23,24^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT384,67^A0B,20,19^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT431,70^A0B,23,24^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT479,67^A0B,23,24^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT527,67^A0B,23,24^FH\^FDkg^FS" + _sPl
	_cCmd += "^FO595,30^GB0,493,3^FS" + _sPl
	_cCmd += "^FO349,30^GB0,493,2^FS" + _sPl
	_cCmd += "^FO202,30^GB0,493,3^FS" + _sPl

	_cCmd += "^PQ1,0,1,Y^XZ" + _sPl

return
