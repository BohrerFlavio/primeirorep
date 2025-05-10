#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "vkey.ch"
#INCLUDE "colors.ch"
#INCLUDE "TOTVS.CH"

//Definir contagem separada para congelados, resfriados e salgados
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF57d    º Autor ³ Giuliano Forgiariniº Data ³  25/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de processamento de inventário dos PA                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ sigapcp                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF57d()
	local nOpca	:= 0
	local aSays := {}, aButtons := {}

	Private cCadastro  := "Processamento de Inventário"
	Private cPerg      := "GJF57D"
	Private _nCaixDev  := 0
	Private _nCaixRet  := 0
	Private _nCaixInv  := 0
	Private _nCaixTot  := 0
	Private lInvent    := GetMV('SI_INVENT')

	AADD(aSays, "  Esta rotina tem como objetivo efetivar o inventário realizado   ")
	AADD(aSays, "  em caixas de produto acabado.                                   ")

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}})
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End()}})
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. )}})
	FormBatch( cCadastro, aSays, aButtons )

	If nopca = 1 .and. lInvent
		if FWAlertYesNo("Você tem certeza que quer realizar o processamento do inventário?" + chr(13) + chr(10) + "Parâmetros:" + CHR(13) + CHR(10) +; 
			"Forma de Armazenamento: " + iif(mv_par01 = 1, "Todas" + chr(13) + chr(10), iif(mv_par01 = 2, "Congelados" + chr(13) + chr(10), iif(mv_par01 = 3, "Resfriados" + chr(13) + chr(10), "Salgados" + chr(13) + chr(10)))) +;
			"Setor de Produção: " + iif(mv_par02 = 1, "Ambos" + chr(13) + chr(10), iif(mv_par02 = 2, "Embalagem" + chr(13) + chr(10), "Porcionados" + chr(13) + chr(10))) +;
			"Processa Terceiros: " + iif(mv_par03 = 1, "Sim", "Não"), "Confirmação")

			Processa({||ProcInv()},"INVENTARIO DE PA","Realizando processamento de inventario...")
		else
			FWAlertWarning("Operação abortada!", "Aviso")
			Return .F.
		endif
	else
        FWAlertWarning("Execução de rotinas de inventario desabilitada! Contate o DTI!", "Aviso")
		Return .F.
	endif

	u_gjf17his(3,'INVENTARIO PROCESSAMENTO',.f.,'','','0'+cValToChar(mv_par01)+'0'+cValToChar(mv_par02)+'0'+cValToChar(mv_par03), '9999999999')

return

Static Function ProcInv()

	Private _nEntrada := 0 
	Private _nSaida   := 0  
	Private _ntotInv  := 0
	Private _nTotFora := 0
	Private _cNum     := ''
	Private _dData    := date()
	Private _cFarm    := ''
	Private _cTerc    := ''
	Private _cAuxCod  := ''

	if empty(mv_par01) .or. empty(mv_par02) .or. empty(mv_par03)
		alert('Parametros em branco!')
		return .f.
	endif

	dbSelectArea("SZ8")
    SZ8->(DbSetOrder(3))
    SZ8->(dbGoTop())

    GeraTMP()
	TMP->(dbGoTop())

    while TMP->(!EOF())
        if SZ8->(MsSeek(xfilial('SZ8')+TMP->Z8_CONTROL))

			//Faz um total de quantas caixas foram inventariadas
			if SZ8->Z8_INV = 'X'
				_nTotInv++
			endif

			//Determina se as caixas de 3º serão processadas ou não
			if mv_par03 = 1
				_cTerc := 'S'
			elseif mv_par03 = 2
				_cTerc := 'N'
			else
				_cTerc := 'A'
			endif

			//Se a caixa não foi inventariada e não é da filial em questão cai fora
			if SZ8->Z8_INV <> 'X' .and. SZ8->Z8_FIL <> cFilAnt
				SZ8->(DbSkip())
				loop
			endif

			//////////////////////////////////////////////////
			//INICIO DO PROCESSAMENTO DAS CAIXAS INVENTARIADAS
			//////////////////////////////////////////////////

			//Se a caixa foi inventariada, volta!!!
			if SZ8->Z8_INV = 'X'
				_cAuxCod := GetAdvFVal('ZZE','ZZE_CODDES',FWxfilial('ZZE')+alltrim(SZ8->Z8_FILORI)+alltrim(SZ8->Z8_CODORI)+alltrim(cFilAnt),1)
				if !empty(_cAuxCod)
					_cCod := alltrim(_cAuxCod)
					_cAuxCod := ''
				else
					_cCod := alltrim(SZ8->Z8_COD)
				endif

				if !empty(SZ8->Z8_DATAS)  .or.;
				!empty(SZ8->Z8_HORAS)  .or.;
				!empty(SZ8->Z8_PREPED) .or.;
				!empty(SZ8->Z8_PRECAR) .or.;
				!empty(SZ8->Z8_ITEM)
					reclock('SZ8',.f.)
					SZ8->Z8_FIL    := cFilAnt
					SZ8->Z8_DATAS  := ctod(' ')
					SZ8->Z8_HORAS  := ' '
					SZ8->Z8_PREPED := ' '
					SZ8->Z8_PRECAR := ' '
					SZ8->Z8_ITEM   := ' '
					SZ8->Z8_COD    := _cCod
					SZ8->Z8_ENCONTR := 'S'
					msunlock()
					_nEntrada++
					if mv_par02 = 3
						u_gjf17his(1,'INVENTARIO',.f.,'','','000036', alltrim(SZ8->Z8_CONTROL))
					else
						u_gjf17his(1,'INVENTARIO',.f.,'','','000021', alltrim(SZ8->Z8_CONTROL))
					endif
				else
					reclock('SZ8',.f.)
					SZ8->Z8_ENCONTR := 'I'
					msunlock()
					if mv_par02 = 3
						u_gjf17his(1,'INVENTARIO',.f.,'','','000036', alltrim(SZ8->Z8_CONTROL))
					else
						u_gjf17his(1,'INVENTARIO',.f.,'','','000033', alltrim(SZ8->Z8_CONTROL))
					endif
				endif

			//Se a caixa não foi inventariada e consta em estoque, sai!!!
			elseif SZ8->Z8_INV <> 'X' .and. empty(SZ8->Z8_DATAS)  .and. empty(SZ8->Z8_HORAS)  .and.;
				empty(SZ8->Z8_PREPED)  .and. empty(SZ8->Z8_PRECAR) .and.;
				empty(SZ8->Z8_ITEM)    .and. SZ8->Z8_FIL = cFilAnt
				reclock('SZ8',.f.)
				SZ8->Z8_DATAS   := ddatabase
				SZ8->Z8_HORAS   := time()
				SZ8->Z8_PREPED  := 'INVENT'
				SZ8->Z8_PRECAR  := 'INVENT'
				SZ8->Z8_ITEM    := 'INV'
				SZ8->Z8_PALLET  := ' '
				SZ8->Z8_LOCALIZ := ' '
				SZ8->Z8_ENCONTR := 'N'
				msunlock()
				if mv_par02 = 3
					u_gjf17his(2,'INVENTARIO',.f.,'','','000037', alltrim(SZ8->Z8_CONTROL))
				else
					u_gjf17his(2,'INVENTARIO',.f.,'','','000022', alltrim(SZ8->Z8_CONTROL))
				endif

				_nSaida++
			endif
		endif

		//////////////////////////////////////
		//FIM DO PROCESSAMENTO DO INVENTARIO
		//////////////////////////////////////

		TMP->(DbSkip())
	end

	if mv_par01 = 2
		_cFarm := 'C'
	elseif mv_par01 = 3
		_cFarm := 'R' 
	elseif mv_par01 = 4 
		_cFarm := 'S'
	else
		_cFarm := 'T'
	endif

	_cNum := getsx8num('ZZK','ZZK_NUM')
	confirmSX8()

	reclock('ZZK',.t.)
	ZZK->ZZK_FILIAL := cFilAnt
	ZZK->ZZK_FARM   := _cFarm
	ZZK->ZZK_TERC   := _cTerc
	ZZK->ZZK_NUM    := _cNum
	ZZK->ZZK_DATA   := _dData
	ZZK->ZZK_TOTINV := _ntotInv
	ZZK->ZZK_TOTENT := _nEntrada
	ZZK->ZZK_TOTSAI := _nSaida
	ZZK->ZZK_USER   := cUserName
	msunlock()

	DEFINE MSDIALOG oDlgR TITLE 'Resumo de Inventario:' from 000,000 To 150,400 OF oMainWnd PIXEL
	@ 001,003 SAY  'Inventariadas :' + transform(_ntotInv,'@E,999,999')
	@ 002,003 SAY  'Incluídas :' + transform(_nEntrada,'@E 999,999')
	@ 003,003 SAY  'Baixadas :' + transform(_nSaida,'@E 999,999')

	@ 60,160 BMPBUTTON TYPE 1 ACTION odlgR:end() Object Obtn1

	ACTIVATE MSDIALOG oDlgR

return     

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

return
