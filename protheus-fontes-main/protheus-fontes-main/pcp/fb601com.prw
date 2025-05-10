#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "RWMake.ch"

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  PROGRAMA: FB601COM
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// DESCRIÃ‡ÃƒO: Impressão de Etiquetas Pallet
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//     AUTOR: NÍcolas Vartha Chinellato  			DATA: 05/04/2016
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//   CONTATO: nicolas.chinellato@totvs.com.br											
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         ATUALIZACOES SOFRIDAS DESDE A CONStrUCAO INICIAL                  
//+--------------+--------+------------------------------------------------------------------------------------------------------------------------------------------------------
//  Programador  | Data   | Motivo da Alteracao                         
//+--------------+--------+------------------------------------------------------------------------------------------------------------------------------------------------------
//
//+--------------+--------+------------------------------------------------------------------------------------------------------------------------------------------------------

User Function FB601COM(cControl, pesoPallet, taraStrech)
	Local aTags		:= {"01","3102","3302","37","15","11","7030","10","00"} 
	Local cProd		:= ""
	Local _sDtProd	:= ""
	Local _sDtValid	:= ""
	// Parametros para verificao do Numero
	Local cDigExt 	:= GetMV('SI_PADIGEX')
	Local cGln    	:= GetMV('SI_GLN')
	Local cNumero 	:= ""
	Local cIf 		:= GetMv('MV_NUMIf')
	Local cPrinter  := ''
	Local i 		:= 0
	Local j 		:= 0
	Local nSoma   	:= 0
	Local nMult   	:= 3
	Local nDigVerif	:= 0

	Private _pesoPallet := pesoPallet
	Private _taraStrech := taraStrech
	Private _cSeqPa  	:= GetMV('SI_PASEQ')
	Private _cCodBar 	:= ""
	Private _cIa7030	:= ""
	Private _cDescSIf	:= ""
	Private _cDescri	:= ""
	Private _cLote		:= ""
	Private _cSSCC		:= ""
	Private _cPesLiq	:= ""
	Private _cPesBrt	:= ""
	Private _cDtValid	:= ""
	Private _cDtProd	:= ""
	Private _cCodProd	:= ""
	Private _nPesLiq	:= 0
	Private _nPesBrt	:= 0
	Private _nQtdCx		:= 0
	Private _nTaraEmb	:= 0
	Private _nTotTara	:= 0
	Private _dDtValid
	Private _dDtProd
	Private _lTemSSCC := .t.
	Private _sPl 	:= Chr(13) + Chr(10)
	Private _cCmd   := ""

	_cEst := getComputerName()
	/*if _cEst == 'CAM04'
		cPrinter	:= AllTrim(GetMv("PM_ETQZBR")) // \\printserver\gpa - 
	elseif _cEst == 'PEX02'
		cPrinter	:= AllTrim(GetMv("PM_ETQZB5"))// \\printserver\gpapex - 10.7.20.50
	elseif _cEst == 'EXP04' .or. _cEst == 'EXP11'
		cPrinter	:= AllTrim(GetMv("PM_ETQZB6"))// \\printserver\gpaexp04 - 10.6.20.37
	elseif _cEst == 'PORC17'
		cPrinter	:= AllTrim(GetMv("PM_ETQZB7"))//	\\printserver\tstdti - 10.7.20.57
	elseif _cEst == 'DTI08'  .or. _cEst == 'DTI13' .or. _cEst == 'DTI30'	.or. _cEst == 'DTI03'
		cPrinter	:= "\\printserver\impsala" //- 10.7.20.57
	else
		cPrinter	:= AllTrim(GetMv("PM_ETQZB2"))// \\printserver\gpa2 - 10.6.20.1
	endif*/
	cPrinter := Alltrim(GetAdvFVal('ZAM','ZAM_PATHPS',FWxFilial('ZAM')+_cEst,1))

	dbSelectArea("SZP")
	SZP->(dbSetOrder(1))

	If SZP->(MsSeek(FwxFilial('SZP') + cControl) )
		cProd := SZP->ZP_PRODUTO

		if empty(SZP->ZP_SSCC)
			cNumero := AllTrim(cDigExt + cGln + _cSeqPa)

			For i:=1 to Len( cNumero)
				If nMult == 3
					nSoma += Val(SubStr( cNumero, i, 1)) * nMult
					nMult := 1
				Else
					nSoma += Val(SubStr( cNumero, i, 1)) * nMult
					nMult := 3
				EndIf
			Next

			For j := 0 to 9
				If (nSoma + j) % 10 == 0 
					fncMult := nSoma + j
					Exit
				EndIf
			Next

			nDigVerif := (fncMult - nSoma)

			// Calculo digito verificador
			If nDigVerif == 10
				nDigVerif := 0
			EndIf

			// Codigo de serie da unidade logistica, utilizado na rastreabilidade do palete
			_cSSCC := cDigExt + cGln + _cSeqPa + AllTrim(Str( nDigVerif))

			_lTemSSCC := .f.
		else
			_cSSCC := SZP->ZP_SSCC
		endif

		// IdentIficador do Produto
		SB1->(DbSetOrder(1))
		SB1->(MsSeek(FWxfilial('SB1')+cProd))
		//_cCod13  	:= SB1->B1_CODBAR
		_cDescSIf 	:= SB1->B1_DESCSIF
		_cDescri  	:= SB1->B1_DESCRED
		//_cDigVerific:= refazEan('9' + substr(_cCod13,1,12))
		//_cCodBar 	:= alltrim('9' + substr(_cCod13,1,12) + _cDigVerifc)

		// Aglutina pesos e soma quantidades
		SZ8->(dbSetOrder(19))
		SZ8->(dbGoTop())
		If SZ8->(MsSeek(FwxFilial('SZ8') + cFilAnt + SZP->ZP_COD))
			_nPesLiq  := 0.00
			_nPesBrt  := 0.00
			_nQtdCx   := 0 
			_nTaraEmb := 0.00
			_dDtValid := SZ8->Z8_DATAVAL
			_dDtProd  := SZ8->Z8_DATAP
			_cCodProd := SZ8->Z8_COD

			/*if !empty(SZ8->Z8_PREDES)
				SZ2->(DbSetOrder(2))
				if  SZ2->(MsSeek(Fwxfilial('SZ2')+SZ8->Z8_PREDES))
					//_dDtProd := SZ2->Z2_DATAABT 
					// Dia 06/12/22 - Tratando no chamado 2927 , Fizemos essa troca para impressão da etiqueta
					_dDtProd  := SZ8->Z8_DATAP
				endif
			else
				_dDtProd  := SZ8->Z8_DATAP
			endif*/

			While SZ8->(!EoF()) .And. SZ8->(Z8_FILIAL+Z8_FIL+Z8_PALLET) = (Fwxfilial('SZ8') + cFilAnt + AllTrim(SZP->ZP_COD))
				//verifica se está preenchido o valor do peso fixo
				//caso esteja preenchido calcula os valores de acordo com o valor da tabela
				if SZ8->Z8_PESFIX <> 0
					_nPesLiq += SZ8->Z8_PESFIX
					_nPesBrt += SZ8->Z8_PESFIX + SZ8->Z8_TARA
				else
					_nPesLiq += SZ8->Z8_PESO
					_nPesBrt += SZ8->Z8_PESOBR
				endif
				_nTaraEmb+= round(SZ8->Z8_TARA,2)
				_nQtdCx++

				SZ8->(dbSkip())
			EndDo
		else
			msgbox('Sem caixas alocadas no pallet!','MONTE O PALLET!','STOP')
			return
		EndIf

		//Peso Liquido
		//_cPesLiq := AllTrim(StrTran(Str(_nPesLiq),'.',''))
		_cPesLiq := AllTrim(StrTran(transform(_nPesLiq,'@E 999.99'),',',''))

		//Peso Bruto
		_nPesBrt += pesoPallet + taraStrech
		//_cPesBrt := AllTrim(StrTran(Str(_nPesBrt),'.',''))
		_cPesBrt := AllTrim(StrTran(transform(_nPesBrt,'@E 999.99'),',',''))

		//Total de Caixas no Pallet
		_cTotCx := strzero(_nQtdCx,2)

		//Tara Total
		_nTotTara := _nTaraEmb + pesoPallet + taraStrech

		//Data de validade
		_sDtValid := DToS(_dDtValid)
		_cDtValid := AllTrim(SubStr(_sDtValid,3,6))

		//Data de produÃ§Ã£o
		_sDtProd := DToS(_dDtProd)
		_cDtProd := AllTrim(SubStr(_sDtProd,3,6))

		//NÂº de regiStro de processador - NÂº do RegiStro do Fornecedor no SIf com Iso do Pais(076+1733)
		_cIa7030 := '0760' + AllTrim(cIf)

		//Lote das caixas do palete
		_cLote := alltrim(_cDtProd) //AllTrim(DToS(_dDtProd))AllTrim(_cCodProd) +

		if !_lTemSSCC
			//Quando esgotar o campo serial (9999999) muda o dÃ­gito de extensÃ£o pra 1 e recomeÃ§a o campo serial do 0000001
			_nCntSeq := Val(_cSeqPa) + 1

			If _nCntSeq > 9999999
				_cDigExt := Str(Val(cDigExt) + 1)
				PutMV('SI_PADIGEX', AllTrim(cDigExt))
				PutMV('SI_PASEQ', '0000001')
			Else
				PutMV('SI_PASEQ', StrZero(_nCntSeq,7))
			EndIf

			reclock('SZP',.f.)
			SZP->ZP_SSCC := _cSSCC
			msunlock()
		endif

		_cCod13 := SB1->B1_CODBAR
		_cDun14 := SB1->B1_DUN14
		_cUM	:= SB1->B1_UM

		/*cPEan14 := getMV('SI_CDEAN14')
		cPEan142 := getMV('SI_CEAN142')
		cPEan143 := getMV('SI_CEAN143')
		cPEan144 := getMV('SI_CEAN144')
		cPEan145 := getMV('SI_CEAN145')

		//verifica se é um produto que possui DUN14
		//se for gera etiqueta com padrao peso fixo
		if !(alltrim(cProd) $ (Alltrim(cPEan14)+Alltrim(cPEan142)+Alltrim(cPEan143)+Alltrim(cPEan144)+Alltrim(cPEan145)))
			_cod13   := '1' + substr(_cCod13,1,12)
			_cDig    := EAN14(_cod13)
			_cod14   := _cod13 + _cDig
			_cCodBar := _cod14
			//etiqueta caixa peso fixo
			fImpEtiqPf()
		else
			//_cDigVerific := refazEan('9' + substr(_cCod13,1,12))
			//_cCodBar  	 := alltrim('9' + substr(_cCod13,1,12) + _cDigVerifc)
			//etiqueta pallet peso variavel
			fImpEtiqPv()
		endif*/
		fImpEtiqPv()

		// Arquivo da etiqueta
		Memowrite("\etiquetas\etq601com.tmp",_cCmd)
		// Executa .bat
		//cComando := "P:\etq601com.bat "+ 'LPT1'
		//cComando := "P:\etq601com.bat "+ AllTrim(cPrinter)
		//cComando := "P:\TOTVS11\Protheus12_Oficial\protheus_data\etiquetas\etq601com.bat "+ AllTrim(cPrinter)
		cComando := "I:\etq601com.bat "+ AllTrim(cPrinter)
		//MemoWrite("C:\TEMP\cComando.txt", cComando)

		WinExec(cComando)
		sleep(1000)

		SZP->(dbCloseArea())

	EndIf
Return

//impressão de etiqueta de pallet peso variavel pao de açucar
Static Function fImpEtiqPv()

	Local _cDmatrix1 := "01"+AllTrim(_cDun14)+"17"+_cDtValid+"11"+_cDtProd+"37"+_cTotCx
	Local _cDmatrix2 := "3102"+StrZero(Val(_cPesLiq),6)+"3302"+StrZero(Val(_cPesBrt),6)+"10"+_cLote
	Local _cDmatrix3 := "7030"+_cIa7030
	Local _cDmatrix4 := "00"+AllTrim(_cSSCC)

	_cCmd += "" + _sPl

	// Setup Etiqueta em ZPL
	_cCmd += "CT~~CD,~CC^~CT~" + _sPl
	_cCmd += "^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR2,2~SD15^JUS^LRN^CI27^PA0,1,1,0^XZ" + _sPl
	_cCmd += "^XA" + _sPl
	_cCmd += "^MMT" + _sPl
	_cCmd += "^PW831" + _sPl
	_cCmd += "^LL1678" + _sPl
	_cCmd += "^LS0" + _sPl

	// Código GS1-128  padl(alltrim(_cCod),6,'0')
	_cCmd += "^BY2,3,120^FT175,1320^BCB,,N,N,,N" + _sPl   //1589
	_cCmd += "^FD>;>801" + AllTrim(_cDun14)/*iif(_cUM = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14))*/ + "3102" + StrZero(Val(_cPesLiq),6) + "3302" + StrZero(Val(_cPesBrt),6) + "37>6" + _cTotCx +"^FS" + _sPl
	_cCmd += "^FT210,1320^A0B,25,24^FD(01)" + AllTrim(_cDun14)/*iif(_cUM = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14))*/ + "(3102)" + StrZero(Val(_cPesLiq),6) + "(3302)" + StrZero(Val(_cPesBrt),6) + "(37)" + _cTotCx + "^FS" + _sPl

	_cCmd += "^BY2,3,120^FT375,1320^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>817" + _cDtValid + "11" + _cDtProd + "7030" + _cIa7030 + ">810>6" + _cLote + "^FS" + _sPl
	_cCmd += "^FT410,1320^A0B,25,24^FD(17)" + _cDtValid + "(11)" + _cDtProd + "(7030)" + _cIa7030 + "(10)" + _cLote + "^FS" + _sPl

	_cCmd += "^BY2,3,120^FT575,1320^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>800" + AllTrim(_cSSCC) + "^FS" + _sPl
	_cCmd += "^FT610,1320^A0B,25,24^FD(00)" + AllTrim(_cSSCC) + "^FS" + _sPl

	// GS1 Datamatrix
	_cCmd += "^FT575,825^BXN,6,200,0,0,1,_,1" + _sPl
	_cCmd += "^FH\^FD_1" + _cDmatrix1 + "_1" + _cDmatrix2 + "_1" + _cDmatrix3 + "_1" + _cDmatrix4 + "^FS" + _sPl

	// Detalhes
	_cCmd += "^FT52,476^A0B,20,19^FH\^FDSSCC" + AllTrim(_cSSCC) + "^FS" + _sPl
	_cCmd += "^FT88,476^A0B,23,24^FH\^FDNr. Palete:  " + _cSeqPa + "^FS" + _sPl
	_cCmd += "^FT121,476^A0B,20,19^FH\^FD" + _cDescSIf + "^FS" + _sPl
	_cCmd += "^FT150,476^A0B,17,16^FH\^FDCONTENT/CONTEUDO:^FS" + _sPl
	_cCmd += "^FT187,476^A0B,25,24^FH\^FD" + _cDescri + "^FS" + _sPl

	// Detalhes 2
	_cCmd += "^FT234,497^A0B,20,19^FH\^FDBATCH/LOTE: " + _cLote + "^FS" + _sPl
	_cCmd += "^FT267,497^A0B,20,19^FH\^FDCOUNT/QUANTIDADE: " + TransForm(_nQtdCx,'@E 999') + "^FS" + _sPl
	_cCmd += "^FT301,497^A0B,20,19^FH\^FDPROD.DATE/DATA DE PRODUCAO :  " + DToC(_dDtProd) + "^FS" + _sPl
	_cCmd += "^FT335,498^A0B,20,19^FH\^FDSELL  BY  /  DATA  DE  VALIDADE :  " + DToC(_dDtValid) + "^FS" + _sPl

	// Pesos
	_cCmd += "^FT381,504^A0B,17,16^FH\^FDPACKING TARE/TARA EMBALAGEM:^FS" + _sPl
	_cCmd += "^FT383,176^A0B,20,19^FH\^FD"  + Transform(_nTaraEmb,"@E 999.999") + "^FS" + _sPl
	_cCmd += "^FT423,504^A0B,17,16^FH\^FDPALLET TARE/TARA DO PALLET:^FS" + _sPl
	_cCmd += "^FT424,176^A0B,20,19^FH\^FD"  + Transform(_pesoPallet,"@E 999.999") + "^FS" + _sPl
	_cCmd += "^FT465,504^A0B,17,16^FH\^FDRACK TARE/TARA DO RACK:^FS" + _sPl

	_cCmd += "^FT465,176^A0B,20,19^FH\^FD"  + "000.000" + "^FS" + _sPl
	_cCmd += "^FT507,504^A0B,17,16^FH\^FDSTRECH TARE/TARA DO STRECH:^FS" + _sPl
	_cCmd += "^FT506,176^A0B,20,19^FH\^FD"  + Transform(_taraStrech,"@E 999.999") + "^FS" + _sPl
	_cCmd += "^FT548,504^A0B,17,16^FH\^FDCORNER TARE/TARA DA CANTONEIRA:^FS" + _sPl
	_cCmd += "^FT547,176^A0B,20,19^FH\^FD"  + "000.000" + "^FS" + _sPl

	_cCmd += "^FT593,504^A0B,20,19^FH\^FDTOTAL TARE/TARA TOTAL:^FS" + _sPl
	_cCmd += "^FT591,205^A0B,23,24^FH\^FD" + Transform(_nTotTara,"@E 999,999.99") + "^FS" + _sPl
	_cCmd += "^FT638,504^A0B,20,19^FH\^FDGROSS WEIGHT/PESO BRUTO:^FS" + _sPl
	_cCmd += "^FT637,234^A0B,23,24^FH\^FD" + Transform(_nPesBrt,"@E 999,999.99") + "^FS" + _sPl
	_cCmd += "^FT683,504^A0B,20,19^FH\^FDNET WEIGHT/PESO LIQUIDO:^FS" + _sPl
	_cCmd += "^FT682,234^A0B,23,24^FH\^FD" + Transform(_nPesLiq,"@E 999,999.99") + "^FS" + _sPl

	_cCmd += "^BY3,3,60^FT710,1320^BCB,,N,N,,N^FD>;" + AllTrim(_cDun14) + "^FS" + _sPl

	_cCmd += "^FT740,505^A0B,25,24^FH\^FDPROCESSOR/Processador: " + _cIa7030 + "^FS" + _sPl
	_cCmd += "^FT745,1320^A0B,28,28^FH\^FDGTIN: " + AllTrim(_cDun14)/*iif(_cUM = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14))*/ + "^FS" + _sPl

	_cCmd += "^FT682,67^A0B,23,24^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT384,67^A0B,20,19^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT425,67^A0B,20,19^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT466,67^A0B,20,19^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT507,67^A0B,20,19^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT548,67^A0B,20,19^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT592,67^A0B,23,24^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT637,67^A0B,23,24^FH\^FDkg^FS" + _sPl

	_cCmd += "^FO702,30^GB0,493,2^FS" + _sPl
	_cCmd += "^FO349,30^GB0,493,2^FS" + _sPl
	_cCmd += "^FO202,30^GB0,493,3^FS" + _sPl

	_cCmd += "^PQ1,0,1,Y^XZ" + _sPl

Return

//impressão de etiqueta de pallet peso fixo pao de açucar
Static Function fImpEtiqPf()

	Local _cQRCode := "01"+AllTrim(_cDun14)+"17"+_cDtValid+"11"+_cDtProd+"30"+_cTotCx+Chr(29)+"3102"+StrZero(Val(_cPesLiq),6)+"3302"+StrZero(Val(_cPesBrt),6)
	_cQRCode += "10"+_cLote+Chr(29)+"7030"+_cIa7030+Chr(29)+"00"+AllTrim(_cSSCC)

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
	_cCmd += "^BY3,3,200^FT233,1575^BCB,,N,N,,N" + _sPl  //1589
	_cCmd += "^FD>;>802" + AllTrim(_cCodBar)/*iif(_cUM = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14))*/ + "17" + _cDtValid +  "11" + _cDtProd +"37>6" + _cTotCx +"^FS" + _sPl
	_cCmd += "^FT268,1575^A0B,25,24^FD(01)" + AllTrim(_cCodBar)/*iif(_cUM = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14))*/ + "(17)" + _cDtValid + "(11)" + _cDtProd + "(37)" + _cTotCx + "^FS" + _sPl

	//	_cCmd += "^FD>;>802" + iif(_cUM = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14)) + "3102" + StrZero(Val(_cPesLiq),6) + "3302" + StrZero(Val(_cPesBrt),6) + "37>6" + _cTotCx +"^FS" + _sPl
	//	_cCmd += "^FT268,1589^A0B,25,24^FD(02)" + iif(_cUM = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14)) + "(3102)" + StrZero(Val(_cPesLiq),6) + "(3302)" + StrZero(Val(_cPesBrt),6) + "(37)" + _cTotCx + "^FS" + _sPl

	_cCmd += "^BY3,3,197^FT496,1575^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>87030" + alltrim(_cIa7030) + ">810>6" + _cLote + "^FS" + _sPl
	_cCmd += "^FT531,1575^A0B,25,24^FD(7030)" + _cIa7030 + "(10)" + _cLote + "^FS" + _sPl

	_cCmd += "^BY5,3,207^FT769,1575^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>800" + AllTrim(_cSSCC) + "^FS" + _sPl
	_cCmd += "^FT802,1575^A0B,25,24^FD(00)" + AllTrim(_cSSCC) + "^FS" + _sPl

	// GS1 Datamatrix
	_cCmd += "^FT575,725^BXN,6,200,0,0,1,_,1^FH\^FD" + _cQRCode + "^FS" + _sPl

	// Detalhes
	_cCmd += "^FT52,476^A0B,20,19^FH\^FDSSCC" + AllTrim(_cSSCC) + "^FS" + _sPl
	_cCmd += "^FT88,476^A0B,23,24^FH\^FDNr. Palete:  " + _cSeqPa + "^FS" + _sPl
	_cCmd += "^FT121,476^A0B,20,19^FH\^FD" + _cDescSIf + "^FS" + _sPl
	_cCmd += "^FT150,476^A0B,17,16^FH\^FDCONTENT/CONTEUDO:^FS" + _sPl
	_cCmd += "^FT187,476^A0B,25,24^FH\^FD" + _cDescri + "^FS" + _sPl

	// Detalhes 2
	_cCmd += "^FT234,497^A0B,20,19^FH\^FDBATCH/LOTE: " + _cLote + "^FS" + _sPl
	_cCmd += "^FT267,497^A0B,20,19^FH\^FDCOUNT/QUANTIDADE: " + TransForm(_nQtdCx,'@E 999') + "^FS" + _sPl
	_cCmd += "^FT301,497^A0B,20,19^FH\^FDPROD.DATE/DATA DE PRODUCAO :  " + DToC(_dDtProd) + "^FS" + _sPl
	_cCmd += "^FT335,498^A0B,20,19^FH\^FDSELL  BY  /  DATA  DE  VALIDADE :  " + DToC(_dDtValid) + "^FS" + _sPl

	// Pesos
	_cCmd += "^FT381,504^A0B,17,16^FH\^FDPACKING TARE/TARA EMBALAGEM:^FS" + _sPl
	_cCmd += "^FT383,176^A0B,20,19^FH\^FD"  + Transform(_nTaraEmb,"@E 999.999") + "^FS" + _sPl
	_cCmd += "^FT423,504^A0B,17,16^FH\^FDPALLET TARE/TARA DO PALLET:^FS" + _sPl
	_cCmd += "^FT424,176^A0B,20,19^FH\^FD"  + Transform(_pesoPallet,"@E 999.999") + "^FS" + _sPl
	_cCmd += "^FT465,504^A0B,17,16^FH\^FDRACK TARE/TARA DO RACK:^FS" + _sPl

	_cCmd += "^FT465,176^A0B,20,19^FH\^FD"  + "000.000" + "^FS" + _sPl
	_cCmd += "^FT507,504^A0B,17,16^FH\^FDSTRECH TARE/TARA DO STRECH:^FS" + _sPl
	_cCmd += "^FT506,176^A0B,20,19^FH\^FD"  + Transform(_taraStrech,"@E 999.999") + "^FS" + _sPl
	_cCmd += "^FT548,504^A0B,17,16^FH\^FDCORNER TARE/TARA DA CANTONEIRA:^FS" + _sPl
	_cCmd += "^FT547,176^A0B,20,19^FH\^FD"  + "000.000" + "^FS" + _sPl

	_cCmd += "^FT593,504^A0B,20,19^FH\^FDTOTAL TARE/TARA TOTAL:^FS" + _sPl
	_cCmd += "^FT591,205^A0B,23,24^FH\^FD" + Transform(_nTotTara,"@E 999,999.99") + "^FS" + _sPl
	_cCmd += "^FT638,504^A0B,20,19^FH\^FDGROSS WEIGHT/PESO BRUTO:^FS" + _sPl
	_cCmd += "^FT637,234^A0B,23,24^FH\^FD" + Transform(_nPesBrt,"@E 999,999.99") + "^FS" + _sPl
	_cCmd += "^FT683,504^A0B,20,19^FH\^FDNET WEIGHT/PESO LIQUIDO:^FS" + _sPl
	_cCmd += "^FT682,234^A0B,23,24^FH\^FD" + Transform(_nPesLiq,"@E 999,999.99") + "^FS" + _sPl

	_cCmd += "^FT740,505^A0B,25,24^FH\^FDPROCESSOR/Processador: " + _cIa7030 + "^FS" + _sPl
	_cCmd += "^FT787,505^A0B,28,28^FH\^FDGTIN: " + AllTrim(_cCodBar)/*iif(_cUM = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14))*/ + "^FS" + _sPl

	//_cCmd += "^FT682,67^A0B,23,24^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT384,67^A0B,20,19^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT425,67^A0B,20,19^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT466,67^A0B,20,19^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT507,67^A0B,20,19^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT548,67^A0B,20,19^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT592,67^A0B,23,24^FH\^FDkg^FS" + _sPl
	//_cCmd += "^FT637,67^A0B,23,24^FH\^FDkg^FS" + _sPl

	_cCmd += "^FO702,30^GB0,493,2^FS" + _sPl
	_cCmd += "^FO349,30^GB0,493,2^FS" + _sPl
	_cCmd += "^FO202,30^GB0,493,3^FS" + _sPl

	_cCmd += "^PQ1,0,1,Y^XZ" + _sPl

Return            

static function refazEan(cCod13)
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
