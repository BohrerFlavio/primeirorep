#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "vkey.ch"
#INCLUDE "colors.ch" 
#INCLUDE "TOTVS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF57E    º Autor ³ Adonai Gabriel     º Data ³  13/02/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de preparação dos produtos para inventário (limpeza) º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ sigapcp                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF57E()

    local nOpca	       := 0
	local aSays        := {}, aButtons := {}
	Private cCadastro  := "Preparação de caixas para inventário"
	Private cPerg      := "GJF57E"
    Private lInvent    := GetMV('SI_INVENT')
    Private _cNum      := ''
    Private _nTotInv   := 0

    AADD(aSays, "  Esta rotina tem como objetivo executar a limpeza dos registros  ")
	AADD(aSays, "  de Caixas de Produto Acabado para inventário.                   ")

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}})
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End()}})
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. )}})
	FormBatch(cCadastro, aSays, aButtons)
	if nOpca = 1 .and. lInvent
		Proces()
    else
        FWAlertWarning("Execução de rotinas de inventario desabilitada! Contate o DTI!", "Aviso")
        Return .F.
	endif

Return

Static Function Proces()
    if empty(mv_par01) .or. empty(mv_par02) .or. empty(mv_par03)
		FWAlertWarning("Parametros em branco!", "Aviso")
		Return .F.
	endif
    if FWAlertYesNo("Você tem certeza que quer realizar a preparação do inventário?" + chr(13) + chr(10) + "Parâmetros:" + CHR(13) + CHR(10) +; 
        "Forma de Armazenamento: " + iif(mv_par01 = 1, "Todas" + chr(13) + chr(10), iif(mv_par01 = 2, "Congelados" + chr(13) + chr(10), iif(mv_par01 = 3, "Resfriados" + chr(13) + chr(10), "Salgados" + chr(13) + chr(10)))) +;
        "Setor de Produção: " + iif(mv_par02 = 1, "Ambos" + chr(13) + chr(10), iif(mv_par03 = 2, "Embalagem" + chr(13) + chr(10), "Porcionados" + chr(13) + chr(10))) +;
        "Processa Terceiros: " + iif(mv_par03 = 1, "Sim", "Não"), "Confirmação")

        FWMsgRun(, {|oSay| Limpa(oSay)}, "Processando", "Aguarde...Realizando a limpeza dos registros...")
        sleep(2000)
        FWAlertSuccess('Caixas preparadas com sucesso!', "Sucesso!")
    else
        FWAlertWarning("Operação abortada!", "Aviso")
        Return .F.
    endif
Return

Static Function Limpa(oSay)

    DbSelectArea("SZ8")
    SZ8->(DbSetOrder(3))
    SZ8->(DbGoTop())

    DbSelectArea("SZP")
    SZP->(DbSetOrder(1))
    SZP->(DbGoTop())

    GeraTMP()

	TMP->(dbGoTop())

    while TMP->(!EOF())
        if SZ8->(MsSeek(FWxfilial('SZ8')+TMP->Z8_CONTROL))
            if mv_par01 = 2
                reclock('SZ8',.f.)
                    SZ8->Z8_INV := ''
                    SZ8->Z8_LOCAL := ''
                    SZ8->Z8_LOCALIZ := ''
                msunlock()
                if SZP->(MsSeek(FWxfilial('SZP')+SZ8->Z8_PALLET))
                    reclock('SZP',.f.)
                        SZP->ZP_LOCALIZ := ''
                    msunlock()
                endif
            else
                if SZP->(MsSeek(FWxfilial('SZP')+SZ8->Z8_PALLET))
                    reclock('SZP',.f.)
                        DbDelete()
                    msunlock()
                endif
                reclock('SZ8',.f.)
                    SZ8->Z8_INV := ''
                    SZ8->Z8_LOCAL := ''
                    SZ8->Z8_LOCALIZ := ''
                    SZ8->Z8_PALLET := ''
                msunlock()
            endif
            _nTotInv++
        endif

        TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    end

    oSay:SetText("Preparação finalizada...")
    u_gjf17his(3,'INVENTARIO PREPARACAO',.f.,'','','0'+cValToChar(mv_par01)+'0'+cValToChar(mv_par02)+'0'+cValToChar(mv_par03), '9999999999')

    _cNum := getsx8num('ZZK','ZZK_NUM')
	confirmSX8()

    reclock('ZZK',.t.)
	ZZK->ZZK_FILIAL := cFilAnt
	ZZK->ZZK_FARM   := iif(mv_par01 = 1, "T", iif(mv_par01 = 2, "C", iif(mv_par01 = 3, "R", "S")))
	ZZK->ZZK_TERC   := iif(mv_par03 = 1, "S", "N")
	ZZK->ZZK_NUM    := _cNum
	ZZK->ZZK_DATA   := ddatabase
	ZZK->ZZK_TOTINV := _nTotInv
	ZZK->ZZK_TOTENT := 0
	ZZK->ZZK_TOTSAI := 0
	ZZK->ZZK_USER   := cUserName
	msunlock()

Return

Static Function GeraTMP()

	cQuery := "SELECT Z8_CONTROL"
    cQuery += " FROM " + retSqlTab('SZ8')
    cQuery += " INNER JOIN " + retSqlTab('SB1') + " (NOLOCK) ON (SZ8.Z8_COD = SB1.B1_COD)"
    cQuery += " INNER JOIN " + retSqlTab('SBM') + " (NOLOCK) ON (SB1.B1_GRUPO = SBM.BM_GRUPO)"
    cQuery += " WHERE " + retSqlFil('SZ8') + " AND Z8_FIL = '" + cFilAnt + "'" + " AND " + retSqlFil('SB1') + " AND " + retSqlFil('SBM')
    cQuery += " AND Z8_DATAS = ''"
    if mv_par01 = 2
        cQuery += " AND BM_FARM = 'C'"
        //cQuery += " AND Z8_FARM = 'C'"
    elseif mv_par01 = 3
        cQuery += " AND BM_FARM = 'R'"
        //cQuery += " AND Z8_FARM = 'R'"
    elseif mv_par01 = 4
        cQuery += " AND BM_FARM = 'S'"
        //cQuery += " AND Z8_FARM = 'S'"
    endif
    cQuery += iif(mv_par02 = 2, " AND Z8_LOTEPOR = ''", iif(mv_par02 = 3, " AND Z8_LOTEPOR <> ''", ""))
    //cQuery += iif(mv_par02 = 2, " AND Z8_SETPRO = 'E'", iif(mv_par02 = 3, " AND Z8_SETPRO = 'P'", ""))
    cQuery += iif(mv_par03 = 2, " AND Z8_TERC = ''", "")
	cQuery += " AND " + retSqlDel('SZ8') + " AND " + retSqlDel('SB1') + " AND " + retSqlDel('SBM')
	cQuery += " ORDER BY Z8_CONTROL"

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP"

Return
