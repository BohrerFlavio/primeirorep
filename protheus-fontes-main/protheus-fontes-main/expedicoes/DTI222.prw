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

	MsgInfo('Serão impressas um total de ' + AllTrim(STR(TMP1->CONT)) + ' caixa(s): ',"Info")

	While TMP->(!EOF())

        if SZ8->(MsSeek(FWxfilial('SZ8') + TMP->Z8_CONTROL))
			MsgInfo('Nº da caixa: '+SZ8->Z8_CONTROL,"Info")
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

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	_cQuery1 := "SELECT COUNT(*) AS CONT"
	_cQuery1 += " FROM  " + RetSQLTab('SZ8')
    _cQuery1 += " WHERE " + retSqlFil('SZ8')
	_cQuery1 += " AND Z8_COD = '"+MV_PAR01+"'"
    _cQuery1 += " AND Z8_PREPED = '"+MV_PAR02+"'"
	_cQuery1 += " AND Z8_SSCC <> ''"  
	_cQuery1 += " AND " + retSqlDel('SZ8')	

	_cQuery1  := ChangeQuery(_cQuery1)

	If Select("TMP1") != 0
		TMP1->(dbCloseArea())
	Endif

	TCQUERY _cQuery1 NEW ALIAS "TMP1"
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

		_dDtProd  := SZ8->Z8_DATAP
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

		etqCxPv()

		// Arquivo da etiqueta
		Memowrite("\etiquetas\etq601com.tmp",_cCmd)

		cComando := "I:\etq601com.bat "+ AllTrim(cPrinter)

		WinExec(cComando)
		sleep(1000)

	endif

return

//função para gerar etiqueta da caixa peso variavel pão de açucar
Static Function etqCxPv()
	Local _cDmatrix1 := ""
	Local _cDmatrix2 := ""
	Local _cDmatrix3 := ""
	Local _cDmatrix4 := ""

	_cTotCx := '01'

	_cDmatrix1 := "01"+AllTrim(_cDun14)+"17"+_cDtValid+"11"+_cDtProd+"30"+_cTotCx
	_cDmatrix2 := "3102"+StrZero(Val(_cPesLiq),6)+"3302"+StrZero(Val(_cPesBrt),6)+"10"+_cLote
	_cDmatrix3 := "7030"+_cIa7030
	_cDmatrix4 := "00"+AllTrim(_cSSCC)
	_cNumPrev  := SZ8->Z8_NUMPREV
	_dDtAbt    := GetAdvFVal('SZU','ZU_DTABT',FWxFilial('SZU')+_cNumPrev,2)
	_cSIF      := GetAdvFVal('ZZ7','ZZ7_MSIF',FWxFilial('ZZ7')+SZ8->Z8_COD,1)
	_cGrpProd  := GetAdvFval('SB1','B1_GRUPO',FWxFilial('SB1')+SZ8->Z8_COD,1)

	_cCmd += "" + _sPl

	// Setup Etiqueta em ZPL
	_cCmd += "CT~~CD,~CC^~CT~" + _sPl
	_cCmd += "^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR2,2~SD15^JUS^LRN^CI27^PA0,1,1,0^XZ" + _sPl
	_cCmd += "^XA" + _sPl
	_cCmd += "^MMT" + _sPl
	_cCmd += "^PW831" + _sPl
	_cCmd += "^LL1678" + _sPl
	_cCmd += "^LS0" + _sPl

	//#1: (01)
	_cCmd += "^BY2,3,100^FT375,1296^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>801" + AllTrim(_cDun14) + "3102" + StrZero(Val(_cPesLiq),6) + "3302" + StrZero(Val(_cPesBrt),6) + "30>6" + _cTotCx +"^FS" + _sPl
	_cCmd += "^FT405,1296^A0B,25,24^FD(01)" + AllTrim(_cDun14) + "(3102)" + StrZero(Val(_cPesLiq),6) + "(3302)" + StrZero(Val(_cPesBrt),6) + "(30)" + _cTotCx + "^FS" + _sPl	

	//#2: (17)
	_cCmd += "^BY2,3,97^FT520,1296^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>817" + _cDtValid + "11" + _cDtProd + "7030" + _cIa7030 + ">810>6" + _cLote + "^FS" + _sPl
	_cCmd += "^FT545,1296^A0B,25,24^FD(17)" + _cDtValid + "(11)" + _cDtProd + "(7030)" + _cIa7030 + "(10)" + _cLote + "^FS" + _sPl

	//#3: (00)
	_cCmd += "^BY2,3,107^FT675,1296^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>800" + AllTrim(_cSSCC) + "^FS" + _sPl
	_cCmd += "^FT700,1296^A0B,25,24^FD(00)" + AllTrim(_cSSCC) + "^FS" + _sPl

	//#4: GTIN
	_cCmd += "^BY3,3,60^FT770,1296^BCB,,N,N,,N^FD>;" + AllTrim(_cDun14) + "^FS" + _sPl
	_cCmd += "^FT795,1296^A0B,28,28^FH\^FDGTIN: " + AllTrim(_cDun14) + "^FS" + _sPl

	//#5: Matrix
	_cCmd += "^FT570,907^BXN,6,200,0,0,1,_,1" + _sPl
	_cCmd += "^FH\^FD_1" + _cDmatrix1 + "_1" + _cDmatrix2 + "_1" + _cDmatrix3 + "_1" + _cDmatrix4 + "^FS" + _sPl

	_cCmd += "^BY2,3,60^FT785,277^BCB,,Y,N,,N^FD>;" + SZ8->Z8_CONTROL + "^FS" + _sPl

	_cCmd += "^FT715,232^A0B,20,19^FH\^FDPE:" + SZ8->Z8_SEQPETQ + "^FS" + _sPl

	_cCmd += "^FT65,1296^A0B,25,24^FH\^FD" + _cDescSif + "^FS" + _sPl
	_cCmd += "^FT95,1296^A0B,25,24^FH\^FD" + _cDescri + "^FS" + _sPl	
	_cCmd += "^FT125,1296^A0B,25,24^FH\^FD" + AllTrim(_cMensTemp) + "^FS" + _sPl
	_cCmd += "^FT155,1296^A0B,25,24^FH\^FDREGISTRO NO MINISTÉRIO DA AGRICULTURA SIF/DIPOA" + "^FS" + _sPl	
	_cCmd += "^FT185,1296^A0B,25,24^FH\^FDSOB Nº " + AllTrim(_cSIF) + "^FS" + _sPl	
	_cCmd += "^FT215,1296^A0B,25,24^FH\^FDINDÚSTRIA BRASILEIRA | NÃO CONTÉM GLÚTEN" + "^FS" + _sPl
	_cCmd += "^FT245,1296^A0B,25,24^FH\^FDRastreabilidade:" + "1733" + STRTRAN(DToC(_dDtProd),"/", "",) + "0000" + "^FS"+ _sPl

	if !_cGrpProd $ GetMV('MV_GRPPORC')
		_cCmd += "^FT65,611^A0B,25,24^FH\^FDData de abate / Slaughter date: " + DToC(_dDtAbt) + "^FS" + _sPl
		_cCmd += "^FT95,611^A0B,25,24^FH\^FDData de producao/Lote / Production date/Batch: " + DToC(_dDtProd) + "^FS" + _sPl
		_cCmd += "^FT125,611^A0B,25,24^FH\^FDData de validade/Expiry date: " + DToC(_dDtValid) + "^FS" + _sPl
	else
		_cCmd += "^FT65,611^A0B,25,24^FH\^FDData de producao/Lote / Production date/Batch: " + DToC(_dDtProd) + "^FS" + _sPl
		_cCmd += "^FT95,611^A0B,25,24^FH\^FDData de validade/Expiry date: " + DToC(_dDtValid) + "^FS" + _sPl
	endif

	_cCmd += "^FT200,611^A0B,25,24^FH\^FDPeso bruto/Gross weight:^FS" + _sPl
	_cCmd += "^FT255,611^A0B,50,49^FH\^FD" + AllTrim(Transform(_nPesBrt,"@E 999,999.99")) + " Kg" + "^FS" + _sPl
	_cCmd += "^FT300,611^A0B,25,24^FH\^FDPeso liquido/Net weight:^FS" + _sPl
	_cCmd += "^FT355,611^A0B,50,49^FH\^FD" + AllTrim(Transform(_nPesLiq,"@E 999,999.99")) + " Kg" + "^FS" + _sPl

	_cCmd += "^FT400,611^A0B,25,24^FH\^FDTara primária/Primary packing tare:^FS" + _sPl
	_cCmd += "^FT455,611^A0B,50,49^FH\^FD"  + AllTrim(Transform(_nTaraEmb,"@E 999.999")) + " Kg" + "^FS" + _sPl
	_cCmd += "^FT500,611^A0B,25,24^FH\^FDTara da caixa/Carton tare:^FS" + _sPl
	_cCmd += "^FT555,611^A0B,50,49^FH\^FD"  + AllTrim(Transform(_nTaraCx,"@E 999.999")) + " Kg" + "^FS" + _sPl
	_cCmd += "^FT600,611^A0B,25,24^FH\^FDTara total/Total tare:^FS" + _sPl
	_cCmd += "^FT655,611^A0B,50,49^FH\^FD" + AllTrim(Transform(_nTotTara,"@E 999,999.999")) + " Kg" + "^FS" + _sPl

	_cCmd += "^FT670,261^A0B,50,49^FH\^FD" + SZ8->Z8_COD + "^FS" + _sPl
	_cCmd += "^FT710,611^A0B,25,24^FH\^FDPROCESSOR/Processador:" + _cIa7030 + "^FS" + _sPl
	_cCmd += "^FT740,611^A0B,25,24^FH\^FDSSCC" + AllTrim(_cSSCC) + "^FS" + _sPl
	_cCmd += "^FT770,611^A0B,25,24^FH\^FDHora: " + AllTrim(SZ8->Z8_HORA) + "^FS" + _sPl
	
	_cCmd += "^FO155,131^GB0,493,3^FS" + _sPl
	_cCmd += "^FO685,131^GB0,493,3^FS" + _sPl
	
	_cCmd += "^PQ1,0,1,Y^XZ" + _sPl
return
