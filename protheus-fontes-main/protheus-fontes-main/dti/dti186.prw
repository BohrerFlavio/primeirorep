#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE "Fileio.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI186    ºAutor  ³Adonai Gabriel   º Data ³  08/09/23     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina temporária para realizar a limpeza de ZAS_INV       º±±
±±º          ³ da ZAS para produtos de tipos específicos.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DTI                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI186()

    MsgRun("Aguarde... Realizando o processamento dos registros...",,{|| GeraTMP()})

    /*ZAS->(DbSetOrder(1))
    ZAS->(DbGoTop())

    _cIp := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+'DTI30',1))

    TMP->(dbGoTop())

    While TMP->(!EOF())

        if ZAS->(MsSeek(FWxfilial('ZAS') + alltrim(TMP->ZAS_CONTRO)))
            //RecLock("ZAS",.F.)
            //ZAS->ZAS_INV := ""
            //ZAS->ZAS_LOCAL := ""
            //MsUnlock()
            u_GJF111k("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_PREDES,ZAS->ZAS_DTPROD,;
					(ZAS->ZAS_DTPROD+ZAS->ZAS_VALID),1,_cIp,ZAS->ZAS_HORA)
        endif

        TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

    enddo*/

    /*_cIp := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+'DTI30',1))

    TMP->(dbGoTop())

    While TMP->(!EOF())

        u_GJF111f("S600","IP",TMP->Z8_CONTROL,TMP->Z8_CODORI,TMP->Z8_QUANT,TMP->Z8_PESOBR,TMP->Z8_PESO,TMP->Z8_TARA,TMP->Z8_PREDES,;
            TMP->Z8_CLASSIF,TMP->Z8_TF,stod(TMP->Z8_DATAP),TMP->Z8_ETIQ,stod(TMP->Z8_DATAVAL),1,TMP->Z8_LOTE,_cIp,TMP->Z8_SEQPETQ,TMP->Z8_HORA)

        TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

    enddo*/

    /*Local nLinha := 1
    Local cFilestr
    Private aItens := {}

    cFilestr := memoread('C:\Users\adonai.gonçalves\Desktop\Docs\Caixas.txt')

    While !empty(clinha := memoline(cFilestr,,nLinha))
        aadd(aItens, padL(alltrim(clinha),10,'0'))
        nLinha++
    Enddo

    SZ8->(DbSetOrder(3))
    SZ8->(DbGoTop())

    _cIp := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxfilial('ZAM')+'DTI30',1))

    for nLinha := 1 to len(aItens)
        if SZ8->(MsSeek(FWxfilial('SZ8') + aItens[nLinha]))
            u_GJF111p("S600","IP",_cIp,SZ8->Z8_CONTROL,,)
            u_FB601COM("PA01069566",20.0,0.0)*/
            /*RecLock("SZ8",.F.)
            SZ8->Z8_DATAS   := stod('')//date()
			SZ8->Z8_HORAS   := ''//time()
			SZ8->Z8_PREPED  := ''
			SZ8->Z8_ITEM    := ''
			SZ8->Z8_PRECAR  := ''
			SZ8->Z8_TPROC   := '1'
			SZ8->Z8_PALLET  := ''
			SZ8->Z8_LOCALIZ := ''
			SZ8->Z8_LOCAL   := ''
            SZ8->Z8_MOTBAIX := "SEQUESTRO"
            SZ8->Z8_OBS     := "Retorno ao estoque - 23/12/24"
            MsUnlock()
            u_gjf17his(2,"SEQUESTRO",.f.,'','','000025',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)*/
        //endif
    //next

    //_ip	:= alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM')+"DTI30",1))

    /*SZ8->(DbSetOrder(3))
    SZ8->(DbGoTop())

    While TMP->(!EOF())

        if SZ8->(MsSeek(FWxfilial('SZ8') + alltrim(TMP->Z8_CONTROL)))
            RecLock("SZ8",.F.)
            SZ8->Z8_DATAS := stod("")
            SZ8->Z8_HORAS := ""
            SZ8->Z8_PRECAR := ""
            SZ8->Z8_PREPED := ""
            SZ8->Z8_ITEM := ""
            SZ8->Z8_LOCAL := ""
            SZ8->Z8_LOCALIZ := ""
            //SZ8->Z8_CARPICK := ""
            //SZ8->Z8_PICKING := ""
            //SZ8->Z8_CHKCARR := ""
            //SZ8->Z8_CHKPCAR := ""
            //SZ8->Z8_USRVAL := ""
            SZ8->Z8_OBS := "Inventário de PA/Congelados/Porcionados - pedido Felipe"
            MsUnlock()
            //u_gjf17his(1,'RETORNO ESTOQUE - 088246',.f.,'','','000030', TMP->Z8_CONTROL)
        endif

        TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

    enddo*/

    /*Local i := 0
    TMP->(DbGoTop())
    SZ8->(DbSetOrder(28))
    SZ8->(DbGoTop())

    While TMP->(!EOF())

        if SZ8->(MsSeek(FWxfilial('SZ8')+TMP->Z8_SEQBIZE))
            for i := 1 to TMP->NUM
                reclock('SZ8',.f.)
                    SZ8->Z8_OBS  := 'Caixas duplicadas - 15/04/24'
                msunlock()
                if i > 1
                    reclock('SZ8',.f.)
                    DbDelete()
                    msunlock()
                endif
                SZ8->(dbSkip()) // Avanca o ponteiro do registro no arquivo
            next
        endif

        TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    enddo*/

    //_cProd := "026494"

    /*ocal nLinha := 1
    Local cFilestr
    Local _cDun14 := ""
    Private aItens := {}

    cFilestr := memoread('C:\Users\adonai.gonçalves\Desktop\Docs\Caixas.txt')

    While !empty(clinha := memoline(cFilestr,,nLinha))
        aadd(aItens, padL(alltrim(clinha),6,'0'))
        nLinha++
    Enddo

    SB1->(DbSetOrder(1))
    SB1->(DbGoTop())

    for nLinha := 1 to len(aItens)
        if SB1->(MsSeek(FWxfilial('SB1')+aItens[nLinha]))
            _cDun14 := alltrim(GeraDUN14())
            FWAlertSuccess("DUN14 do produto (" + aItens[nLinha] + ") = " + _cDun14, "SUCESSO!")
            RecLock("SB1",.F.)
                SB1->B1_DUN14 := _cDun14
            MsUnlock()
        endif
    next*/

    /*Local i := 0
    Local _cCodT := '005016'
	Local _cCodD := '005020'
	Local _cCodC := '005018'

    for i := 1 to 6
        _cLado := iif(i = 1 .or. i = 3 .or. i = 5,'00','01')

        if i <= 2
            _cCodBar := GJF182p('01001425','000010','000679','D',iif(_cLado = '00','D','E'),_cCodD,iif(_cLado = '00','N','N'),'020',108.10,107.40,'N','C')
        elseif i > 2 .AND. i <= 4
            _cCodBar := GJF182p('01001425','000010','000679','T',iif(_cLado = '00','D','E'),_cCodT,'','020',108.10,107.40,'N','C')
        elseif i > 4 .AND. i <=6
            _cCodBar := GJF182p('01001425','000010','000679','C',iif(_cLado = '00','D','E'),_cCodC,'','020',108.10,107.40,'N','C')
        endif

	next*/

    Local nLinha := 1
    Local cFilestr
    Private aItens := {}

    cFilestr := memoread('C:\Users\adonai.gonçalves\Desktop\Docs\Caixas.txt')

    // CADASTRO DE ENDEREÇOS
    /*While !empty(clinha := memoline(cFilestr,,nLinha))
        aadd(aItens, alltrim(clinha))
        nLinha++
    Enddo*/
    While !empty(clinha := memoline(cFilestr,,nLinha))
        aadd(aItens, strtokarr(alltrim(clinha),','))
        nLinha++
    Enddo

    SBE->(DbGoTop())
    SBE->(DbSetOrder(1))
    for nLinha := 1 to len(aItens)
        /*if !SBE->(MsSeek(FWxfilial('SBE')+'04'+aItens[nLinha]))
            RecLock("SBE",.T.)
                SBE->BE_FILIAL  := '00'
                SBE->BE_LOCAL   := '04'
                SBE->BE_LOCALIZ := aItens[nLinha]
                SBE->BE_DESCRIC := ''
                SBE->BE_PRIOR   := 'ZZZ'
                SBE->BE_DATGER  := STOD('20250328')
                SBE->BE_STATUS  := '1'
            MsUnlock()
        endif*/
        if SBE->(MsSeek(FWxfilial('SBE')+'04'+aItens[nLinha,2]))
            RecLock("SBE",.F.)
                SBE->BE_LOCAL := aItens[nLinha,3]
            MsUnlock()
        endif
    next

    /*While !empty(clinha := memoline(cFilestr,,nLinha))
        aadd(aItens, strtokarr(alltrim(clinha),','))
        nLinha++
    Enddo*/

    // ALTERAÇÃO DO CADASTRO DE PRODUTOS
    /*SB1->(DbGoTop())
    SB1->(DbSetOrder(1))
    for nLinha := 1 to len(aItens)
        if SB1->(MsSeek(FWxfilial('SB1')+padL(aItens[nLinha,2],6,'0')))
            RecLock("SB1",.F.)
                SB1->B1_LOCALIZ  := 'S'
            MsUnlock()
        endif
    next*/

    // SALDO INICIAL POR PRODUTO E ENDEREÇO
    /*SB9->(DbGoTop())
    SB9->(DbSetOrder(1))
    SBK->(DbGoTop())
    SBK->(DbSetOrder(1))

    for nLinha := 1 to len(aItens)*/
        /*if !SB9->(MsSeek(FWxfilial('SB9')+padr(padL(aItens[nLinha,1],6,'0'),15,' ')+'R1'))
            RecLock("SB9",.T.)
                SB9->B9_FILIAL  := '00'
                SB9->B9_LOCAL   := 'R1'
				SB9->B9_COD     := padL(aItens[nLinha,1],6,'0')
				//SB9->B9_DATA    := Ctod("28/02/2025")
				SB9->B9_MCUSTD  := "1"
            MsUnlock()
        endif*/
        /*if !SBK->(MsSeek(FWxfilial('SBK')+padr(padL(aItens[nLinha,2],6,'0'),15,' ')+'04'))
            RecLock("SBK",.T.)
                SBK->BK_FILIAL  := '00'
                SBK->BK_LOCAL   := '04'
                SBK->BK_LOCALIZ := aItens[nLinha,1]
				SBK->BK_COD     := padL(aItens[nLinha,2],6,'0')
				//SBK->BK_DATA    := Ctod("28/02/2025")
				SBK->BK_QINI    := 0//val(aItens[nLinha,3])
            MsUnlock()
        endif
    next*/

    // SALDO ATUAL
    /*SB2->(DbGoTop())
    SB2->(DbSetOrder(1))
    SBF->(DbGoTop())
    SBF->(DbSetOrder(2))

    for nLinha := 1 to len(aItens)*/
        /*if !SB2->(MsSeek(FWxfilial('SB2')+padr(padL(aItens[nLinha,1],6,'0'),15,' ')+'R1'))
            RecLock("SB2",.T.)
                SB2->B2_FILIAL  := '00'
                SB2->B2_LOCAL   := 'R1'
				SB2->B2_COD     := padL(aItens[nLinha,1],6,'0')
				SB2->B2_DMOV    := Ctod("28/02/2025")
                SB2->B2_HMOV    := time()
				SB2->B2_LOCALIZ := "ALMOX - REUTILI"
                SB2->B2_TIPO    := "1"
                SB2->B2_QATU    := val(aItens[nLinha,3])
            MsUnlock()
        endif*/
        /*if !SBF->(MsSeek(FWxfilial('SBF')+padr(padL(aItens[nLinha,2],6,'0'),15,' ')+'04'))
            RecLock("SBF",.T.)
                SBF->BF_FILIAL  := '00'
                SBF->BF_LOCAL   := '04'
                SBF->BF_LOCALIZ := aItens[nLinha,1]
				SBF->BF_PRODUTO := padL(aItens[nLinha,2],6,'0')
				SBF->BF_PRIOR   := "ZZZ"
				SBF->BF_QUANT   := val(aItens[nLinha,3])
            MsUnlock()
        endif
    next*/

    // MOVIMENTAÇÕES
    /*SD3->(DbGoTop())
    SD3->(DbSetOrder(1))
    SDB->(DbGoTop())
    SDB->(DbSetOrder(1))

    for nLinha := 1 to len(aItens)
        if !SD3->(MsSeek(FWxfilial('SD3')+aItens[nLinha,1]+'R1'))
            RecLock("SD3",.T.)
                SD3->D3_FILIAL  := '00'
                SD3->D3_LOCAL   := 'R1'
				SD3->D3_COD     := aItens[nLinha,1]
				SD3->D3_DATA    := Ctod("31/12/2024")
				SD3->D3_MCUSTD  := "1"
            MsUnlock()
        endif
        if !SDB->(MsSeek(FWxfilial('SDB')+aItens[nLinha,1]+'R1'))
            RecLock("SDB",.T.)
                SDB->DB_FILIAL  := '00'
                SDB->DB_LOCAL   := 'R1'
                SDB->DB_LOCALIZ := aItens[nLinha,2]
				SDB->DB_COD     := aItens[nLinha,1]
				SDB->DB_DATA    := Ctod("31/12/2024")
				SDB->DB_QINI    := val(aItens[nLinha,3])
            MsUnlock()
        endif
    next*/

    /*SBK->(DbSetOrder(3))
    SBK->(DbGoTop())

    TMP->(dbGoTop())

    While TMP->(!EOF())

        if SBK->(MsSeek(FWxfilial('SBK') + TMP->BK_COD + alltrim(TMP->BK_LOCAL) + alltrim(TMP->BK_DATA)))
            RecLock("SBK",.F.)
                SBK->BK_QINI := TMP->B9_QINI
            MsUnlock()
        endif

        TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

    enddo*/

Return

Static Function GJF182p(_cNumam,_cLote,_cControl,_cCorOri,_cLado,_cCod,_cDiant,_cProgram,_Peso1,_Peso2,_Black,_Dest)
	local _cNum := ''

	ZAJ->(DbSetOrder(1))
	if !ZAJ->(MsSeek(FWxFilial('ZAJ') + _cNumam + _cControl + _cCorOri + _cLado ))

		_cNum := GetSx8num('ZAJ','ZAJ_NUM')
		ConfirmSX8()

		if _cCorOri = 'T'
			_cDescri := GetAdvFVal('SZ6','Z6_DESREDT',FWxfilial('SZ6') + _cProgram,1)
		elseif _cCorOri = 'D'
			_cDescri := GetAdvFVal('SZ6','Z6_DESREDD',FWxfilial('SZ6') + _cProgram,1)
		elseif _cCorOri = 'C'
			_cDescri := GetAdvFVal('SZ6','Z6_DESREDC',FWxfilial('SZ6') + _cProgram,1)
		endif   

		do case
			case _cCorOri = 'T' .and. empty(_cProgram)  //_cCod = '000030'
			_cDescri := 'TRASEIRO'
			case _cCorOri = 'D' .and. empty(_cProgram)  //_cCod = '000031'
			_cDescri := 'DIANTEIRO'
			case _cCorOri = 'C' .and. empty(_cProgram)  //_cCod = '000032'
			_cDescri := 'COSTELA'
		endcase

		_nPerTras  := GetMV('SI_%TRAS')
		_nPerDian  := GetMV('SI_%DIAN')
		_nPerCost  := GetMV('SI_%COST')

		_nPesoI := iif(_cCorOri = 'T',_nPerTras * iif(_cLado = 'E',_Peso1,_Peso2),;
		iif(_cCorOri = 'D',_nPerDian * iif(_cLado = 'E',_Peso1,_Peso2),;
		_nPerCost * iif(_cLado = 'E',_Peso1,_Peso2))) 

		_nPeso := _nPesoI// - (_nPesoI * 0.02)  // -2% de frio

		if _Dest $ "T/R"
			_Black := "N"
		endif

		reclock('ZAJ',.t.)
		ZAJ->ZAJ_FILIAL  := FWxfilial('ZAJ')
		ZAJ->ZAJ_CONTRO  := _cControl
		ZAJ->ZAJ_COD     := _cCod
		ZAJ->ZAJ_DESCRI  := _cDescri
		ZAJ->ZAJ_CORORI  := _cCorOri
		ZAJ->ZAJ_NUMAM   := _cNumam
		ZAJ->ZAJ_LOTE    := _cLote
		ZAJ->ZAJ_NUM     := _cNum
		ZAJ->ZAJ_LADO    := _cLado
		ZAJ->ZAJ_NIVEL   := 0
		ZAJ->ZAJ_REGORI  := '0000000000'
		ZAJ->ZAJ_CDIAN   := _cDiant
		ZAJ->ZAJ_DATA    := date()
		ZAJ->ZAJ_PESO    := _nPeso
		ZAJ->ZAJ_BLACK	 := _Black
		msunlock()

		u_gjf182hs(1,"PROD. DO ABATE")
	else
		_cNum := ZAJ->ZAJ_NUM 
	endif

Return _cNum    

Static Function GeraTMP()

	/*_cQuery := "SELECT ZAS_CONTRO, ZAS_INV"
	_cQuery += " FROM " + RetSQLTab('ZAS')
	_cQuery += " INNER JOIN " + retSqlTab('SB1') + " (NOLOCK) ON (ZAS.ZAS_COD = SB1.B1_COD)"
    _cQuery += " INNER JOIN " + retSqlTab('SBM') + " (NOLOCK) ON (SB1.B1_GRUPO = SBM.BM_GRUPO)"
    _cQuery += " WHERE " + retSqlFil('ZAS') + " AND " + retSqlFil('SB1') + " AND " + retSqlFil('SBM')
    _cQuery += " AND ZAS_COD = '010826'"
    _cQuery += " AND ZAS_PREEMB = '0001661490'"
    _cQuery += " AND ZAS_TIPO = 'MP'"
    _cQuery += " AND ZAS_INV = 'X'"
    _cQuery += " AND BM_FARM = 'R'"
	_cQuery += " AND " + retSqlDel('ZAS') + " AND " + retSqlDel('SB1') + " AND " + retSqlDel('SBM')
	_cQuery += " ORDER BY ZAS_CONTRO, ZAS_DTPROD"*/

    /*_cQuery := "SELECT Z8_CONTROL"
	_cQuery += " FROM  " + RetSQLTab('SZ8')
    _cQuery += " WHERE " + retSqlFil('SZ8')
    _cQuery += " AND Z8_PRECAR = '088246'"
	_cQuery += " AND " + retSqlDel('SZ8')
	_cQuery += " ORDER BY Z8_CONTROL"*/

    /*_cQuery := "SELECT Z8_SEQBIZE, COUNT(Z8_SEQBIZE) AS NUM"
	_cQuery += " FROM  " + retSqlTab('SZ8')
    _cQuery += " WHERE " + retSqlFil('SZ8')
    _cQuery += " AND Z8_DATAP BETWEEN '20220101' AND '20241231'"
    _cQuery += " AND Z8_SEQBIZE <> ''"
	_cQuery += " AND " + retSqlDel('SZ8')
	_cQuery += " GROUP BY Z8_SEQBIZE"
    _cQuery += " HAVING COUNT(Z8_SEQBIZE) > 1"*/

    /*_cQuery := "SELECT Z8_CONTROL, COUNT(Z8_CONTROL) AS NUM"
	_cQuery += " FROM  " + retSqlTab('SZ8')
    _cQuery += " WHERE " + retSqlFil('SZ8')
    _cQuery += " AND Z8_DATAP BETWEEN '20220101' AND '20241231'"
	_cQuery += " AND " + retSqlDel('SZ8')
	_cQuery += " GROUP BY Z8_CONTROL"
    _cQuery += " HAVING COUNT(Z8_CONTROL) > 1"*/

    /*_cQuery := "SELECT ZP_COD AS PALLET,"
    _cQuery += " CASE WHEN EXISTS(SELECT *"
	_cQuery += " FROM  " + retSqlTab('SZ8')
    _cQuery += " WHERE " + retSqlFil('SZ8')
    _cQuery += " AND Z8_PALLET = ZP_COD"
	_cQuery += " AND " + retSqlDel('SZ8') + " AND " + retSqlDel('SZP') + ") THEN 'Exist'"
	_cQuery += " ELSE 'Not Exist'"
    _cQuery += " END AS STATUS"
    _cQuery += " FROM  " + retSqlTab('SZP')
    _cQuery += " WHERE " + retSqlFil('SZP')
    _cQuery += " AND " + retSqlDel('SZP')*/

    /*_cQuery := "SELECT ZK_NUMAM AS NUMAM, ZK_CONTROL AS CONTROL, ZK_CLASSIF AS CLASSIF, ZAJ_NUM AS NUM, ZK_PROGRAM AS PROGRAM, ZK_BLACK AS BLACK, ZAJ_COD AS COD,"
    _cQuery += " CASE WHEN ZK_DESTINO = 'R' THEN 'Conserva'"
    _cQuery += " WHEN ZK_DESTINO = 'T' THEN 'TF'"
    _cQuery += " ELSE '' END AS DESTINO"
	_cQuery += " FROM " + retSqlTab('ZAJ')
    _cQuery += " INNER JOIN " + retSqlTab('SZK') + " ON (ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL = ZAJ_CONTRO)"
    _cQuery += " WHERE " + retSqlFil('ZAJ') + " AND " + retSqlFil('SZK')
    _cQuery += " AND ZK_NUMAM IN ('01003424', '01003524') "
    _cQuery += " AND ZAJ_PREDES = '' AND ZAJ_CONTRO <> '' AND ZAJ_COD <> '005018'"
	_cQuery += " AND " + retSqlDel('ZAJ')
    _cQuery += " AND " + retSqlDel('SZK')
	_cQuery += " ORDER BY ZAJ_NUM"*/

    _cQuery := "SELECT BK_COD, BK_LOCAL, BK_DATA, B9_QINI"
	_cQuery += " FROM " + retSqlTab('SBK') + " (NOLOCK)"
    _cQuery += " INNER JOIN " + retSqlTab('SB9') + " (NOLOCK) ON (SBK.BK_COD = SB9.B9_COD AND SBK.BK_LOCAL = SB9.B9_LOCAL)"
    _cQuery += " WHERE " + retSqlFil('SBK') + " AND " + retSqlFil('SB9')
    _cQuery += " AND SBK.BK_LOCAL IN ('04','06','09')"
    _cQuery += " AND SBK.BK_DATA = '20250331'"
    _cQuery += " AND SB9.B9_DATA = '20250331'"
	_cQuery += " AND " + retSqlDel('SBK')
    _cQuery += " AND " + retSqlDel('SB9')

    /*_cQuery := "SELECT Z8_CONTROL, ZP_SSCC"
	_cQuery += " FROM " + RetSQLTab('SZ8')
    _cQuery += " INNER JOIN " + retSqlTab('SZV') + " (NOLOCK) ON (ZV_CONTROL = Z8_CONTROL)"
    _cQuery += " INNER JOIN " + retSqlTab('SZP') + " (NOLOCK) ON (ZP_COD = ZV_PALLET)"
    _cQuery += " WHERE " + retSqlFil('SZ8')
    _cQuery += " AND Z8_FIL = '00'"
    _cQuery += " AND ZV_CODMSG = '000016'"
    _cQuery += " AND Z8_COD IN ('021498', '021511')"
    _cQuery += " AND Z8_CONTROL IN ('0011052432','0011052463','0011052464','0011052466','0011052470','0011052471')"
    _cQuery += " AND Z8_PREPED = 'ABOEKT'"
	_cQuery += " AND " + retSqlDel('SZ8')
    _cQuery += " AND " + retSqlDel('SZV')
	_cQuery += " ORDER BY Z8_CONTROL"*/

    /*_cQuery := "SELECT ZV_CONTROL, ZV_DESC, ZV_DATA, ZV_HORA, Z8_PALLET, ZP_LOCALIZ"
    _cQuery += " FROM " + retSqlTab('SZV')
    _cQuery += " INNER JOIN " + retSqlTab('SZ8') + " (NOLOCK) ON (Z8_CONTROL = ZV_CONTROL)"
    _cQuery += " INNER JOIN " + retSqlTab('SZP') + " (NOLOCK) ON (Z8_COD = ZP_PRODUTO AND ZV_PALLET = ZP_COD)"
    _cQuery += " WHERE " + retSqlFil('SZV') + " AND Z8_FIL = '" + cFilAnt + "'" + " AND " + retSqlFil('SZ8') + " AND " + retSqlFil('SZP')
    _cQuery += " AND ZV_PALLET = 'PA00937656'"
    _cQuery += " AND ZV_DATA >= '20240215'"
    _cQuery += " AND ZV_CODMSG = '000003'"
	_cQuery += " AND " + retSqlDel('SZV') + " AND " + retSqlDel('SZ8') + " AND " + retSqlDel('SZP')
    _cQuery += " GROUP BY ZV_CONTROL, ZV_DESC, ZV_DATA, ZV_HORA, Z8_PALLET, ZP_LOCALIZ"
    _cQuery += " ORDER BY ZV_CONTROL"*/

    /*_cQuery := "SELECT ZZ7_CODPRO"
	_cQuery += " FROM  " + retSqlTab('SB1')
    _cQuery += " INNER JOIN " + retSqlTab('ZZ7') + " (NOLOCK) ON (B1_COD = ZZ7_CODPRO)"
    _cQuery += " WHERE " + retSqlFil('SB1') + " AND " + retSqlFil('ZZ7')
    _cQuery += " AND B1_GRUPO = '4006'"
	_cQuery += " AND " + retSqlDel('SB1')
    _cQuery += " AND " + retSqlDel('ZZ7')
	_cQuery += " ORDER BY B1_COD"*/

    /*_cQuery := "SELECT Z8_CONTROL"
	_cQuery += " FROM " + RetSQLTab('SZ8')
	_cQuery += " INNER JOIN " + retSqlTab('SB1') + " (NOLOCK) ON (SZ8.Z8_COD = SB1.B1_COD)"
    _cQuery += " INNER JOIN " + retSqlTab('SBM') + " (NOLOCK) ON (SB1.B1_GRUPO = SBM.BM_GRUPO)"
    _cQuery += " WHERE " + retSqlFil('SZ8') + " AND " + retSqlFil('SB1') + " AND " + retSqlFil('SBM')
    _cQuery += " AND Z8_FIL = '00'"
    _cQuery += " AND Z8_LOTEPOR <> ''"
    _cQuery += " AND Z8_DATAS = ''"
    _cQuery += " AND Z8_TERC = ''"
    _cQuery += " AND BM_FARM = 'C'"
	_cQuery += " AND " + retSqlDel('SZ8') + " AND " + retSqlDel('SB1') + " AND " + retSqlDel('SBM')
	_cQuery += " ORDER BY Z8_CONTROL"*/

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


//Função auxiliar
Static Function GeraOP(_classif, _program, _cod, _numam, _obs, _black)

	cQuery := "SELECT Z2_NUM"
	cQuery += " FROM " + RetSqlTab("SZ2")
	cQuery += " WHERE " + RetSqlFil("SZ2")
    cQuery += " AND Z2_NUMAM = '" + _numam + "'"
    cQuery += " AND Z2_COD = '" + _cod + "'"
    if !empty(_obs)
        cQuery += " AND Z2_OBS = '" + alltrim(_obs) + "'"
    else
        cQuery += " AND Z2_CLASSIF = '" + _classif + "'"
        if _black = 'S'
            cQuery += " AND Z2_PROGRAM = '014'"
        else
            cQuery += " AND Z2_PROGRAM = '" + _program + "'"
        endif
    endif
	//cQuery += " AND Z2_STATUS <> 'E'"
	cQuery += " AND " + RetSQLDel('SZ2')

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	//verifica se houve retorno na query
    Count to nCount

    If nCount > 0
        Return .T.
    endif

return .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função de gravação do DUN14 no cadastro                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GeraDUN14()

	_nCodBar := SB1->B1_CODBAR
	_nCdBarcli := SB1->B1_EANCLI

	if !empty(_nCdBarcli)//bloco para imprimir dun14 do cliente
		_cod13 := '1' + substr(_nCdBarcli, 1, 12)
	elseif !empty(_nCodBar)
		_cod13 := '1' + substr(_nCodBar, 1, 12)
	else
		Return
	endif

	_cDig := EAN14(_cod13)
	_cod14 := _cod13 + _cDig

Return _cod14

Static Function EAN14(cCod13)
	Local nOdd := 0
	Local nEven := 0
	Local nI
	Local nDig
	Local nMul := 10
	For nI := 1 to 13
		If (nI % 2) == 0
			nEven += val(substr(cCod13, nI, 1))
		Else
			nOdd += val(substr(cCod13, nI, 1))
		Endif
	Next
	nDig := nEven + (nOdd * 3)
	While nMul < nDig
		nMul += 10
	Enddo
Return strzero(nMul - nDig, 1)
