/*
Programa..: ML_IAT
Autor.....: Robert Koch
Data......: 08/01/2002
Nota......: Importacao arquivos ativo fixo (SN1, SN2, SN3)
Cliente...: CTA

Historico de alteracoes:

*/


#INCLUDE "rwmake.ch"

// --------------------------------------------------------------------------
User Function ml_iat ()
	local _sArq1 := space (50)
	local _sArq2 := space (50)
	local _sArq3 := space (50)
	_sArq1 = "c:\sn14001               "
	_sArq2 = "c:\sn24001               "
	_sArq3 = "c:\sn34001               "
	@ 150, 030 TO 360, 420 DIALOG oDlg_menu TITLE "ML_SN1 - Importa dados para arq. SN1, SN2, SN3"
	@ 015, 005 Say "Arquivo p/ SN1"
	@ 030, 005 Say "Arquivo p/ SN2"
	@ 045, 005 Say "Arquivo p/ SN3"
	@ 015, 045 Get _sArq1 Picture "@!" SIZE 150, 11
	@ 030, 045 Get _sArq2 Picture "@!" SIZE 150, 11
	@ 045, 045 Get _sArq3 Picture "@!" SIZE 150, 11
	@ 080, 40  BUTTON "SN1" ACTION processa ({|| _Importa (1, _sArq1, _sArq2, _sArq3)}, "Importando arquivo SN1... ")
	@ 080, 80  BUTTON "SN2" ACTION processa ({|| _Importa (2, _sArq1, _sArq2, _sArq3)}, "Importando arquivo SN2... ")  // _Importa (, _sArq2,)
	@ 080, 120 BUTTON "SN3" ACTION processa ({|| _Importa (3, _sArq1, _sArq2, _sArq3)}, "Importando arquivo SN3... ")  // _Importa (,, _sArq3)
	@ 080, 157 BMPBUTTON TYPE 2 ACTION Close (oDlg_menu)
	ACTIVATE DIALOG oDlg_menu
Return




// --------------------------------------------------------------------------
Static function _Importa (_nArq, _sArq1, _sArq2, _sArq3)
	local _nHandle  := 0
	local _sLinha   := ""
	local _nReg     := 0
	local _nJa_cad  := 0
	local _nLinha   := 0
	local _sCbase   := ""
	local _sItem    := ""
	local _sCCDepr  := ""
	local _sCDeprec := ""

	sn1 -> (dbsetorder (1))
	si1 -> (dbsetorder (1))

	if _nArq == 1
		procregua (25)
		sn1 -> (dbsetorder (1))
		_nHandle := fopen (_sArq1, 0)
		_nReg    = 0
		_nJa_cad = 0
		_nLinha  = 1
		fseek (_nHandle, 0, 0)
		Do While .T.
			incproc ()
			_sLinha = ""
			fread (_nHandle, @_sLinha, 239)
			If left (_sLinha, 1) == "@"
				fClose (_nHandle)
				alert ("SN1: " + alltrim (str (_nReg)) + " registros importados; " + alltrim (str (_nJa_cad)) + " jah cadastrados")
				return
			Endif
			if substr (_sLinha, 238, 1) != chr (13)
				alert ("Tamanho da linha " + alltrim (str (_nLinha)) + " invalido!")
				return
			endif
			_sCbase = substr (_sLinha, 3, 10)
			_sItem  = substr (_sLinha, 13, 4)
			if sn1 -> (dbseek (xfilial ("SN1") + _sCbase + _sItem, .F.))
				_nJa_cad ++
				loop
			endif
			Reclock ("SN1", .T.)
			sn1 -> n1_filial  = xfilial("SN1")
			sn1 -> n1_cbase   = substr (_sLinha, 3, 10)
			sn1 -> n1_item    = substr (_sLinha, 13, 4)
			sn1 -> n1_aquisic = stod   (substr (_sLinha, 17, 8))
			sn1 -> n1_descric = substr (_sLinha, 25, 40)
			sn1 -> n1_quantd  = val    (substr (_sLinha, 65, 9)) / 1000
			sn1 -> n1_baixa   = stod   (substr (_sLinha, 74, 8))
			sn1 -> n1_chapa   = substr (_sLinha, 82,  6)
			sn1 -> n1_fornec  = substr (_sLinha, 145, 6)
			sn1 -> n1_loja    = substr (_sLinha, 151, 2)
			sn1 -> n1_local   = substr (_sLinha, 153, 6)
			sn1 -> n1_patrim  = substr (_sLinha, 205, 1)
			sn1 -> n1_icmsapr = val    (substr (_sLinha, 212, 18)) / 100
			sn1 -> n1_dtbloq  = stod   (substr (_sLinha, 230,  8))
			MsUnLock ()
			_nReg ++
			_nLinha ++
		Enddo
	endif


	if _nArq == 2
		procregua (25)
		_nHandle := fopen (_sArq2, 0)
		_nReg    =  0
		_nLinha  = 1
		fseek (_nHandle, 0, 0)
		Do While .T.
			incproc ()
			_sLinha = ""
			fread (_nHandle, @_sLinha, 60)
			If left (_sLinha, 1) == "@"
				fClose (_nHandle)
				alert ("SN2: " + alltrim (str (_nReg)) + " registros importados")
				return
			Endif
			if substr (_sLinha, 59, 1) != chr (13)
				alert ("Tamanho da linha " + alltrim (str (_nLinha)) + " invalido!")
				return
			endif
			_sCbase = substr (_sLinha, 3, 10)
			_sItem  = substr (_sLinha, 13, 4)
			if ! sn1 -> (dbseek (xfilial ("SN1") + _sCbase + _sItem, .F.))
				if msgbox ("Bem/item " + _sCbase + "/" + _sItem + " nao cadastrado. Abandonar processo?", "Erro", "YESNO")
					return
				endif
				loop
			endif
			Reclock ("SN2", .T.)
			sn2 -> n2_filial  = xfilial("SN2")
			sn2 -> n2_cbase   = substr (_sLinha, 3,   10)
			sn2 -> n2_item    = substr (_sLinha, 13,   4)
			sn2 -> n2_sequenc = substr (_sLinha, 17,   2)
			sn2 -> n2_histor  = substr (_sLinha, 19,  40)
			MsUnLock ()
			_nReg ++
			_nLinha ++
		Enddo
	endif


	if _nArq == 3
		procregua (25)
		_nHandle := fopen (_sArq3, 0)
		_nReg    = 0
		_nLinha  = 1
		fseek (_nHandle, 0, 0)
		Do While .T.
			incproc ()
			_sLinha = ""
			fread (_nHandle, @_sLinha, 483)
			If left (_sLinha, 1) == "@"
				fClose (_nHandle)
				alert ("SN3: " + alltrim (str (_nReg)) + " registros importados")
				return
			Endif
			if substr (_sLinha, 482, 1) != chr (13)
				alert ("Tamanho da linha " + alltrim (str (_nLinha)) + " invalido!")
				return
			endif
			_sCbase = substr (_sLinha, 3, 10)
			_sItem  = substr (_sLinha, 13, 4)
			_sItem = iif (_sItem == "0095", "0000", _sItem)  // Desconsiderar item = 0095.
			if ! sn1 -> (dbseek (xfilial ("SN1") + _sCbase + _sItem, .F.))
				if msgbox ("Bem/item " + _sCbase + "/" + _sItem + " nao cadastrado. Abandonar processo?", "Erro", "YESNO")
					return
				endif
				loop
			endif
			_sCC      = alltrim (substr (_sLinha, 80, 9))
			_sConta   = alltrim (substr (_sLinha, 60, 20))
			if ! si1 -> (dbseek (xfilial ("SI1") + _sConta, .F.))
				if msgbox ("Conta " + _sConta + " nao cadastrada. Abandonar processo?", "Erro", "YESNO")
					return
				endif
				loop
			endif
			_Contas (_sCC, _sConta, @_sCDeprec, @_sCCDepr)
			if ! si1 -> (dbseek (xfilial ("SI1") + _sCDeprec, .F.))
				if msgbox ("Conta " + _sCDeprec + " nao cadastrada. Abandonar processo?", "Erro", "YESNO")
					return
				endif
				loop
			endif
			if ! si1 -> (dbseek (xfilial ("SI1") + _sCDeprec, .F.))
				if msgbox ("Conta " + _sCDeprec + " nao cadastrada. Abandonar processo?", "Erro", "YESNO")
					return
				endif
				loop
			endif
			Reclock ("SN3", .T.)
			sn3 -> n3_filial  = xfilial("SN3")
			sn3 -> n3_cbase   = _sCbase
			sn3 -> n3_item    = _sItem
			sn3 -> n3_tipo    = substr (_sLinha, 17,   2)
			sn3 -> n3_baixa   = substr (_sLinha, 19,   1)
			sn3 -> n3_histor  = substr (_sLinha, 20,  40)
			sn3 -> n3_ccontab = substr (_sLinha, 60,  20)
			sn3 -> n3_custbem = substr (_sLinha, 80,   9)
			sn3 -> n3_cdeprec = _sCDeprec
			sn3 -> n3_ccusto  = substr (_sLinha, 109,  9)
			sn3 -> n3_ccdepr  = _sCCDepr
			sn3 -> n3_cdesp   = substr (_sLinha, 138, 20)
			sn3 -> n3_ccorrec = substr (_sLinha, 158, 20)
			sn3 -> n3_dindepr = stod   (substr (_sLinha, 178,  8))
			sn3 -> n3_dexaust = stod   (substr (_sLinha, 186,  8))
			sn3 -> n3_vorig1  = val    (substr (_sLinha, 194, 16)) / 100
			sn3 -> n3_txdepr1 = val    (substr (_sLinha, 210,  8)) / 10000
			sn3 -> n3_vorig2  = val    (substr (_sLinha, 218, 16)) / 10000
			sn3 -> n3_txdepr2 = val    (substr (_sLinha, 234,  8)) / 10000
			sn3 -> n3_vorig3  = val    (substr (_sLinha, 242, 16)) / 10000
			sn3 -> n3_txdepr3 = val    (substr (_sLinha, 258,  8)) / 10000
			sn3 -> n3_vrdacm1 = val    (substr (_sLinha, 346, 16)) / 100
			sn3 -> n3_vrdacm2 = val    (substr (_sLinha, 362, 16)) / 10000
			sn3 -> n3_vrdacm3 = val    (substr (_sLinha, 378, 16)) / 10000
			sn3 -> n3_vrdacm4 = val    (substr (_sLinha, 394, 16)) / 10000
			sn3 -> n3_vrdacm5 = val    (substr (_sLinha, 410, 16)) / 10000
			sn3 -> n3_indice1 = val    (substr (_sLinha, 426,  8)) / 10000
			sn3 -> n3_indice2 = val    (substr (_sLinha, 434,  8)) / 10000
			sn3 -> n3_indice3 = val    (substr (_sLinha, 442,  8)) / 10000
			sn3 -> n3_indice4 = val    (substr (_sLinha, 450,  8)) / 10000
			sn3 -> n3_indice5 = val    (substr (_sLinha, 458,  8)) / 10000
			sn3 -> n3_dtbaixa = stod   (substr (_sLinha, 466,  8))
			sn3 -> n3_aquisic = stod   (substr (_sLinha, 474,  8))
			MsUnLock ()
			_nReg ++
			_nLinha ++
		Enddo
	endif
return



// --------------------------------------------------------------------------
// Converte _sCCDepr e _sCDeprec para o cc/conta informado
static function _Contas (_sCC, _sConta, _sCDeprec, _sCCDepr)

	// Converte _sCCDepr (N3_CCDEPR)
	do case
		case _sConta == "132020100010" ; _sCCDepr = "132020100028"  // 1775
		case _sConta == "132030100012" ; _sCCDepr = "132030100020"  // 1813
		case _sConta == "132030100039" ; _sCCDepr = "132030100047"  // 5320
		case _sConta == "132040100015" ; _sCCDepr = "132040100023"  // 1856
		case _sConta == "132050100018" ; _sCCDepr = "132050100026"  // 1899
		case _sConta == "132060100010" ; _sCCDepr = "132050100026"  // 1937
		case _sConta == "132100100016" ; _sCCDepr = "132100100024"  // 1970
		case _sConta == "132110100019" ; _sCCDepr = "132110100027"  // 2011
		case _sConta == "132150100010" ; _sCCDepr = "132150100028"  // 2054
		case _sConta == "132350100013" ; _sCCDepr = "132350100021"  // 2801
		case _sConta == "133010100018" ; _sCCDepr = "133010100026"  // 2305
		case _sConta == "133200100108" ; _sCCDepr = "133200100205"  // 3190
		case _sConta == "133800100109" ; _sCCDepr = "133800100206"  // 4669
		otherwise
		alert ("Nao encontrei CCDEPR para a conta " + _sConta)
	endcase

	// Converte _sCDeprec (N3_CDEPREC) considerando centro de custo.
	do case
		case _sCC >= "1     " .and. _sCC <= "11ZZZZ"
		do case
			case _sConta == "132020100010" ; _sCDeprec = "316012400109"  // 1775
			case _sConta == "132030100012" ; _sCDeprec = "316012400257"  // 1813
			case _sConta == "132030100039" ; _sCDeprec = "314300700750"  // 5320
			case _sConta == "132040100015" ; _sCDeprec = "314300700300"  // 1856
			case _sConta == "132050100018" ; _sCDeprec = "314300700505"  // 1899
			case _sConta == "132060100010" ; _sCDeprec = "314300700602"  // 1937
			case _sConta == "132100100016" ; _sCDeprec = "310612400150"  // 1970
			case _sConta == "132110100019" ; _sCDeprec = "316012400206"  // 2011
			case _sConta == "132150100010" ; _sCDeprec = "316012400303"  // 2054
			case _sConta == "132350100013" ; _sCDeprec = "314300700858"  // 2801
			case _sConta == "133010100018" ; _sCDeprec = "316012400354"  // 2305
			case _sConta == "133200100108" ; _sCDeprec = "316012000755"  // 3190
			case _sConta == "133800100109" ; _sCDeprec = "314300700904"  // 4669
			otherwise
			alert ("Nao encontrei CDEPREC para o CC/conta " + _sCC + "/" + _sConta)
		endcase

		case _sCC >= "120   " .and. _sCC <= "12ZZZZ"
		do case
			case _sConta == "132020100010" ; _sCDeprec = "316020900107"  // 1775
			case _sConta == "132030100012" ; _sCDeprec = "316020900409"  // 1813
			case _sConta == "132030100039" ; _sCDeprec = "            "  // 5320
			case _sConta == "132040100015" ; _sCDeprec = "            "  // 1856
			case _sConta == "132050100018" ; _sCDeprec = "            "  // 1899
			case _sConta == "132060100010" ; _sCDeprec = "            "  // 1937
			case _sConta == "132100100016" ; _sCDeprec = "316020900204"  // 1970
			case _sConta == "132110100019" ; _sCDeprec = "316020900301"  // 2011
			case _sConta == "132150100010" ; _sCDeprec = "316020900506"  // 2054
			case _sConta == "132350100013" ; _sCDeprec = "            "  // 2801
			case _sConta == "133010100018" ; _sCDeprec = "            "  // 2305
			case _sConta == "133200100108" ; _sCDeprec = "            "  // 3190
			case _sConta == "133800100109" ; _sCDeprec = "            "  // 4669
			otherwise
			alert ("Nao encontrei CDEPREC para o CC/conta " + _sCC + "/" + _sConta)
		endcase

		case _sCC >= "2     " .and. _sCC <= "25ZZZZ"
		do case
			case _sConta == "132020100010" ; _sCDeprec = "314300700106"  // 1775
			case _sConta == "132030100012" ; _sCDeprec = "314300700700"  // 1813
			case _sConta == "132030100039" ; _sCDeprec = "314300700750"  // 5320
			case _sConta == "132040100015" ; _sCDeprec = "314300700300"  // 1856
			case _sConta == "132050100018" ; _sCDeprec = "314300700505"  // 1899
			case _sConta == "132060100010" ; _sCDeprec = "314300700602"  // 1937
			case _sConta == "132100100016" ; _sCDeprec = "314300700203"  // 1970
			case _sConta == "132110100019" ; _sCDeprec = "314300700408"  // 2011
			case _sConta == "132150100010" ; _sCDeprec = "314300700807"  // 2054
			case _sConta == "132350100013" ; _sCDeprec = "314300700858"  // 2801
			case _sConta == "133010100018" ; _sCDeprec = "314300700882"  // 2305
			case _sConta == "133200100108" ; _sCDeprec = "            "  // 3190
			case _sConta == "133800100109" ; _sCDeprec = "314300700904"  // 4669
			otherwise
			alert ("Nao encontrei CDEPREC para o CC/conta " + _sCC + "/" + _sConta)
		endcase

		case _sCC >= "3     " .and. _sCC <= "4     "
		do case
			case _sConta == "132020100010" ; _sCDeprec = "316012400109"  // 1775
			case _sConta == "132030100012" ; _sCDeprec = "314202000304"  // 1813
			case _sConta == "132030100039" ; _sCDeprec = "            "  // 5320
			case _sConta == "132040100015" ; _sCDeprec = "            "  // 1856
			case _sConta == "132050100018" ; _sCDeprec = "            "  // 1899
			case _sConta == "132060100010" ; _sCDeprec = "            "  // 1937
			case _sConta == "132100100016" ; _sCDeprec = "314202000207"  // 1970
			case _sConta == "132110100019" ; _sCDeprec = "314202000401"  // 2011
			case _sConta == "132150100010" ; _sCDeprec = "314202000509"  // 2054
			case _sConta == "132350100013" ; _sCDeprec = "            "  // 2801
			case _sConta == "133010100018" ; _sCDeprec = "            "  // 2305
			case _sConta == "133200100108" ; _sCDeprec = "            "  // 3190
			case _sConta == "133800100109" ; _sCDeprec = "            "  // 4669
			otherwise
			alert ("Nao encontrei CDEPREC para o CC/conta " + _sCC + "/" + _sConta)
		endcase

		case _sCC >= "410   " .and. _sCC <= "410100"
		do case
			case _sConta == "132020100010" ; _sCDeprec = "314212000102"  // 1775
			case _sConta == "132030100012" ; _sCDeprec = "314212000307"  // 1813
			case _sConta == "132030100039" ; _sCDeprec = "314212000706"  // 5320
			case _sConta == "132040100015" ; _sCDeprec = "314212000609"  // 1856
			case _sConta == "132050100018" ; _sCDeprec = "            "  // 1899
			case _sConta == "132060100010" ; _sCDeprec = "            "  // 1937
			case _sConta == "132100100016" ; _sCDeprec = "314212000200"  // 1970
			case _sConta == "132110100019" ; _sCDeprec = "314212000404"  // 2011
			case _sConta == "132150100010" ; _sCDeprec = "314212000501"  // 2054
			case _sConta == "132350100013" ; _sCDeprec = "            "  // 2801
			case _sConta == "133010100018" ; _sCDeprec = "            "  // 2305
			case _sConta == "133200100108" ; _sCDeprec = "            "  // 3190
			case _sConta == "133800100109" ; _sCDeprec = "            "  // 4669
			otherwise
			alert ("Nao encontrei CDEPREC para o CC/conta " + _sCC + "/" + _sConta)
		endcase

		case _sCC >= "410101" .and. _sCC <= "420100"
		do case
			case _sConta == "132020100010" ; _sCDeprec = "314222000105"  // 1775
			case _sConta == "132030100012" ; _sCDeprec = "314222000300"  // 1813
			case _sConta == "132030100039" ; _sCDeprec = "314222000350"  // 5320
			case _sConta == "132040100015" ; _sCDeprec = "314222000601"  // 1856
			case _sConta == "132050100018" ; _sCDeprec = "            "  // 1899
			case _sConta == "132060100010" ; _sCDeprec = "            "  // 1937
			case _sConta == "132100100016" ; _sCDeprec = "314222000202"  // 1970
			case _sConta == "132110100019" ; _sCDeprec = "314222000407"  // 2011
			case _sConta == "132150100010" ; _sCDeprec = "314222000504"  // 2054
			case _sConta == "132350100013" ; _sCDeprec = "            "  // 2801
			case _sConta == "133010100018" ; _sCDeprec = "            "  // 2305
			case _sConta == "133200100108" ; _sCDeprec = "            "  // 3190
			case _sConta == "133800100109" ; _sCDeprec = "            "  // 4669
			otherwise
			alert ("Nao encontrei CDEPREC para o CC/conta " + _sCC + "/" + _sConta)
		endcase

		case _sCC >= "420101" .and. _sCC <= "430100"
		do case
			case _sConta == "132020100010" ; _sCDeprec = "314232000108"  // 1775
			case _sConta == "132030100012" ; _sCDeprec = "314232000302"  // 1813
			case _sConta == "132030100039" ; _sCDeprec = "314232000701"  // 5320
			case _sConta == "132040100015" ; _sCDeprec = "314232000604"  // 1856
			case _sConta == "132050100018" ; _sCDeprec = "            "  // 1899
			case _sConta == "132060100010" ; _sCDeprec = "            "  // 1937
			case _sConta == "132100100016" ; _sCDeprec = "314232000205"  // 1970
			case _sConta == "132110100019" ; _sCDeprec = "314232000400"  // 2011
			case _sConta == "132150100010" ; _sCDeprec = "314232000507"  // 2054
			case _sConta == "132350100013" ; _sCDeprec = "            "  // 2801
			case _sConta == "133010100018" ; _sCDeprec = "            "  // 2305
			case _sConta == "133200100108" ; _sCDeprec = "            "  // 3190
			case _sConta == "133800100109" ; _sCDeprec = "            "  // 4669
			otherwise
			alert ("Nao encontrei CDEPREC para o CC/conta " + _sCC + "/" + _sConta)
		endcase

		case _sCC >= "430101" .and. _sCC <= "510100"
		do case
			case _sConta == "132020100010" ; _sCDeprec = "            "  // 1775
			case _sConta == "132030100012" ; _sCDeprec = "            "  // 1813
			case _sConta == "132030100039" ; _sCDeprec = "            "  // 5320
			case _sConta == "132040100015" ; _sCDeprec = "            "  // 1856
			case _sConta == "132050100018" ; _sCDeprec = "            "  // 1899
			case _sConta == "132060100010" ; _sCDeprec = "            "  // 1937
			case _sConta == "132100100016" ; _sCDeprec = "314300700203"  // 1970
			case _sConta == "132110100019" ; _sCDeprec = "314300700408"  // 2011
			case _sConta == "132150100010" ; _sCDeprec = "314300700807"  // 2054
			case _sConta == "132350100013" ; _sCDeprec = "314300700858"  // 2801
			case _sConta == "133010100018" ; _sCDeprec = "314300700882"  // 2305
			case _sConta == "133200100108" ; _sCDeprec = "            "  // 3190
			case _sConta == "133800100109" ; _sCDeprec = "314300700904"  // 4669
			otherwise
			alert ("Nao encontrei CDEPREC para o CC/conta " + _sCC + "/" + _sConta)
		endcase

		case _sCC >= "510101" .and. _sCC <= "710020"
		do case
			case _sConta == "132020100010" ; _sCDeprec = "314300700106"  // 1775
			case _sConta == "132030100012" ; _sCDeprec = "314300700700"  // 1813
			case _sConta == "132030100039" ; _sCDeprec = "314300700750"  // 5320
			case _sConta == "132040100015" ; _sCDeprec = "314300700300"  // 1856
			case _sConta == "132050100018" ; _sCDeprec = "314300700505"  // 1899
			case _sConta == "132060100010" ; _sCDeprec = "314300700602"  // 1937
			case _sConta == "132100100016" ; _sCDeprec = "            "  // 1970
			case _sConta == "132110100019" ; _sCDeprec = "            "  // 2011
			case _sConta == "132150100010" ; _sCDeprec = "            "  // 2054
			case _sConta == "132350100013" ; _sCDeprec = "            "  // 2801
			case _sConta == "133010100018" ; _sCDeprec = "            "  // 2305
			case _sConta == "133200100108" ; _sCDeprec = "            "  // 3190
			case _sConta == "133800100109" ; _sCDeprec = "            "  // 4669
			otherwise
			alert ("Nao encontrei CDEPREC para o CC/conta " + _sCC + "/" + _sConta)
		endcase
		otherwise
		alert ("CC " + _sCC + " nao consta na tabela de conversao de contas!")
	endcase
return

