#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

//Definir contagem separada para congelados, resfriados e salgados
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF238    º Autor ³ Giuliano Forgiariniº Data ³  22/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de processamento de inventário dos MP porcionados    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ sigapcp                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF238()
	local nOpca	:=0
	local aSays:={}, aButtons:={}
	Private cCadastro  := "Processamento de Inventário"
	Private _nCaixDev  := 0
	Private _nCaixRet  := 0
	Private _nCaixInv  := 0
	Private _nCaixTot  := 0
	Private _aEntrada  := {}
	Private _aSaida    := {}
	Private _aSai      := {}
	Private _aEnt      := {}
	Private lInvent    := GetMV('SI_INVENT')

	AADD(aSays, "  Esta rotina tem como objetivo efetivar o inventário realizado ")
	AADD(aSays, "  em caixas de matéria prima.                                   ")

	cPerg := "GJF238"
	Pergunte(cPerg,.f.)

	AADD(aButtons, {1,.T.,{|o| nOpca:= 1,o:oWnd:End()}})
	AADD(aButtons, {2,.T.,{|o| o:oWnd:End()}})
	AADD(aButtons, {5,.T.,{|o| Pergunte(cPerg,.T.)}})

	FormBatch( cCadastro, aSays, aButtons )
	If nopca == 1 .and. lInvent
		if FWAlertYesNo("Você tem certeza que quer realizar o processamento do inventário?" + chr(13) + chr(10) + "Parâmetros:" + CHR(13) + CHR(10) +; 
			"Forma de Armazenamento: " + iif(mv_par01 = 1, "Ambas" + chr(13) + chr(10), iif(mv_par01 = 2, "Congelados" + chr(13) + chr(10), "Resfriados" + chr(13) + chr(10))), "Confirmação")

			Processa({||ProcInv()},"INVENTARIO DE MP","Realizando processamento de inventario...")
		else
			FWAlertWarning("Operação abortada!", "Aviso")
			Return .F.
		endif
	else
        FWAlertWarning("Execução de rotinas de inventario desabilitada! Contate o DTI!", "Aviso")
        Return .F.
	endif

return 

Static Function ProcInv()
	Local i
	Local j
	Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)
	Private _nEntrada := 0
	Private _nSaida   := 0
	Private _ntotInv  := 0
	Private _cFarm    := ''

	DbSelectArea('ZAS') 
	ZAS->(DbSetOrder(1))
	ZAS->(DbGoTop())

	GeraTMP()
	TMP->(dbGoTop())

	while TMP->(!eof())
		if ZAS->(DbSeek(FWxfilial('ZAS')+TMP->ZAS_CONTRO))

			//Faz um total de quantas caixas foram inventariadas
			if ZAS->ZAS_INV = 'X'
				_nTotInv++
			endif

			//////////////////////////////////////////////////
			//INICIO DO PROCESSAMENTO DAS CAIXAS INVENTARIADAS
			//////////////////////////////////////////////////

			//Se a caixa foi inventariada, volta!!!
			if ZAS->ZAS_INV = 'X'
				_cCod := alltrim(ZAS->ZAS_COD)
				if !empty(ZAS->ZAS_DATAS) .or. !empty(ZAS->ZAS_HORAS) .or. !empty(ZAS->ZAS_MOTS)
					reclock('ZAS',.f.)
						ZAS->ZAS_DATAS  := stod('')
						ZAS->ZAS_HORAS  := ' '
						ZAS->ZAS_MOTS   := ' '
					msunlock()
					_nEntrada++
					aadd(_aEntrada,{ZAS->ZAS_CONTRO, ZAS->ZAS_COD})
				endif
				u_gjf17his(1,'INVENTARIO',.f.,'','','000036', alltrim(ZAS->ZAS_CONTRO))
			//Se a caixa não foi inventariada e consta em estoque, sai!!!
			elseif empty(ZAS->ZAS_INV) .and. empty(ZAS->ZAS_DATAS)  .and. empty(ZAS->ZAS_HORAS)
				reclock('ZAS',.f.)
					ZAS->ZAS_DATAS   := ddatabase
					ZAS->ZAS_HORAS   := time()
					ZAS->ZAS_MOTS    := 'INVENTARIO' + dtoc(DDATABASE)
				msunlock()
				_nSaida++
				aadd(_aSaida,{ZAS->ZAS_CONTRO, ZAS->ZAS_COD})
				u_gjf17his(1,'INVENTARIO',.f.,'','','000037', alltrim(ZAS->ZAS_CONTRO))
			endif
		endif

		//////////////////////////////////////
		//FIM DO PROCESSAMENTO DO INVENTARIO
		//////////////////////////////////////

		TMP->(DbSkip())
	enddo

	//Ordena os vetores
	if len(_aSaida) > 0
		_aSai := aSort(_aSaida,,,{|x,y| x[2] < y[2]})
	endif
	if len(_aEntrada) > 0
		_aEnt := aSort(_aEntrada,,,{|x,y| x[2] < y[2]})
	endif

	_cMemo := 'T. Inv. :' + transform(_ntotInv,'@E,999,999')  + chr(13) + chr(10)
	_cMemo += 'Entradas:' + transform(_nEntrada,'@E 999,999') + chr(13) + chr(10)
	_cMemo += 'Saidas  :' + transform(_nSaida,'@E 999,999')   + chr(13) + chr(10)
	_cMemo += "SAIDA DE CAIXAS " + chr(13) + chr(10)

	for i := 1 to len(_aSai)
		_cMemo  += _aSai[i,1] + '   '  + _aSai[i,2] + chr(13) + chr(10)
	next

	_cMemo += "ENTRADA DE CAIXAS " + chr(13) + chr(10)

	for j := 1 to len(_aEnt)
		_cMemo  += _aEnt[j,1] + '   '  + _aEnt[j,2] + chr(13) + chr(10)
	next

	DEFINE DIALOG oDlgR TITLE "Resumo de Inventario" FROM 180,180 TO 750,800 PIXEL

	_oMemo := TMultiget():New(55,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlgR,280,130,_oFont,,,,,.T.,,,,,,.t.)

	_oBtn2 := TButton():New(255,260, "Sair"    , oDlgR,{||oDlgR:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlgR CENTERED
return

Static Function GeraTMP()

	cQuery := "SELECT ZAS_CONTRO"
    cQuery += " FROM " + retSqlTab('ZAS')
    cQuery += " INNER JOIN " + retSqlTab('SB1') + " ON (ZAS.ZAS_COD = SB1.B1_COD)"
    cQuery += " INNER JOIN " + retSqlTab('SBM') + " ON (SB1.B1_GRUPO = SBM.BM_GRUPO)"
    cQuery += " WHERE " + retSqlFil('ZAS') + " AND " + retSqlFil('SB1') + " AND " + retSqlFil('SBM')
    cQuery += " AND ZAS_DATAS = '' AND ZAS_TIPO = 'MP'"
    if mv_par01 = 2
        cQuery += " AND BM_FARM = 'C'"
        //cQuery += " AND ZAS_FARM = 'C'"
    elseif mv_par01 = 3
        cQuery += " AND BM_FARM = 'R'"
        //cQuery += " AND ZAS_FARM = 'R'"
    endif
	cQuery += " AND " + retSqlDel('ZAS') + " AND " + retSqlDel('SB1') + " AND " + retSqlDel('SBM')
	cQuery += " ORDER BY ZAS_CONTRO"

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
