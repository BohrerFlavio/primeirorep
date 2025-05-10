#INCLUDE "rwmake.ch" 
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF137    º Autor ³ Giuliano Forgiariniº Data ³  26/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de calculo de peso médio por caixa de PA            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF137()
	local nOpca	:=0
	local aSays:={}, aButtons:={}

	Private cCadastro := "Calculo da Posição de Estoque de PA"
	Private _lOk      := .t.

	AADD (aSays, "  Esta rotina tem como objetivo realizar o calculo e compor   ")  //
	AADD (aSays, "  o peso médio das caixas para cada produto acabado no periodo")  //
	AADD (aSays, "  dos ultimos 30 dias, de acordo com sua data base            ")  //

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )                                                                 
	FormBatch( cCadastro, aSays, aButtons )
	If nopca == 1  
		Processa({||Calcula() },"CALCULO DO PESO MÉDIO POR CAIXA","Realizando processamento por valores...")  
	endif

return 

Static Function Calcula()

	ProcRegua(SB1->(RecCount()))

	incproc()

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))

	if SB1->(DbSeek(xfilial('SB1')))
		While  SB1->(!eof()) .and. SB1->B1_FILIAL = xfilial('SB1')

			incproc()

			if SB1->B1_TIPO <> 'PA' .or. SB1->B1_MSBLQL = '1' .or. SB1->B1_SEGUM <> 'CX'
				SB1->(DbSkip())
				loop
			endif

			_nPMedio := CalcPeso(SB1->B1_COD)

			if SB1->B1_DTALTAR < (DDATABASE - 30) .or. empty(SB1->B1_DTALTAR)
				if _nPMedio > 0
					reclock('SB1',.f.)
					SB1->B1_PMCAIX := _nPMedio
					msunlock() 
				endif
			endif

			SB1->(DbSkip())
		enddo
	endif  

Return

Static Function CalcPeso(_cProd) 
	Local _nMedia := 0

	cQuery := " SELECT AVG(Z8_PESO) AS PESO "
	cQuery += " FROM " + RetSqlName("SZ8") + " SZ8 "
	cQuery += " WHERE SZ8.D_E_L_E_T_ <> '*' " 
	cQuery += " AND SZ8.Z8_FILORI = '" + cFilAnt + "'"
	cQuery += " AND SZ8.Z8_CODORI = '" + _cProd + "'"
	cQuery += "  AND SZ8.Z8_DATA BETWEEN '" + dtos(DDATABASE - 30) + "' AND '" + dtos(DDATABASE) + "'" 

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("PES") != 0
		PES->(dbCloseArea())
	Endif 

	TCQUERY cQuery NEW ALIAS "PES"

	_nMedia := PES->PESO

	PES->(DbCloseArea())

return _nMedia
