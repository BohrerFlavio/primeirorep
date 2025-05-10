#INCLUDE "rwmake.ch" 
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF03     º Autor ³ Giuliano Forgiariniº Data ³  06/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de calculo da posição de estoque de PA              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF03()
	Local _aArqTrb    := {} // inicializa o array do arquivo // ProcData 04/2023
	local nOpca	:=0
	local aSays:={}, aButtons:={}
	Private _lCalc    := .f.
	Private cCadastro := "Calculo da Posição de Estoque de PA"
	Private _lOk      := .t.
	Private cPerg     := "GJF03"
	Private _lTProc   := GetMV("SI_TIPOPRO")
	Private aCampos   := {}
	Private lInverte := .f.
	Private cMark    := GetMark()  
	Private oMark

	if !Pergunte(cPerg,.T. )
		return
	endif

	CriaTMP()

	//MarkBrow("TMP","OKAY",,aCampos,,'S')                              //Mostra os campos do TMP no MarkBrow
	DEFINE MSDIALOG oDlg TITLE "Calculo da Posição de Estoque de PA" From 9,0 To 400,800 PIXEL
	oMark := MsSelect():New("TMP","OKAY","",aCampos,@lInverte,@cMark,{17,1,160,400},,,,,) 
	oMark:bMark := {| | Disp()}        

	TButton():New(170, 020, "Marcar Todos"    , oDlg,{|| u_gjf03sel() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New(170, 070, "Calcular"        , oDlg,{|| u_gjf03clc() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New(170, 300, "Sair"            , oDlg,{|| oDlg:end() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED 

	if _lCalc
		Processa({||Calcular(TMP->COD) },"PROCESSAMENTO DE ESTOQUE","Realizando calculo de estoque..." )        
		Processa({||Final() },"CONCLUSÃO DO PROCESSO","Encerrando processamento de estoque..." )        

	endif  

	If Select('TMP')<>0                                                         
		TMP->(dbCloseArea())
	Endif

	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 
return 

Static Function Inicio()

	if empty(mv_par01)
		alert('Necessário preencher parâmetro inicial!')
		_lOk := .f.
		return
	endif                                              

	if mv_par01 <= GetMV("MV_ULMES")
		alert('Não se pode processar posição de estoque de PA pois o período está fechado!')
		_lOk := .f.
		return
	endif

	DbSelectArea('ZA2')
	ZA2->(DbSetOrder(1))

Return                  


//Deve-se somar as transferencias aos valores de entrada calculados para a posição de estoque correta
Static Function Entrada(_cCodPro) 
	Local _cTProc := ''

	if ! _lOk
		Return
	endif

	if !_lTProc
		_cTProc := " Z8_TIPO <> 'R'  AND"
	endif

	cQuery := " SELECT  B1_COD AS COD, "

	cQuery += "   (SELECT COUNT(Z8_COD)FROM " + RetSqlName("SZ8") + " SZ8 "
	cQuery += "    WHERE SZ8.D_E_L_E_T_ <> '*' AND  Z8_FILIAL = '"+ xfilial("SZ8") + "' AND  "
	cQuery += "     Z8_FIL = '" + cFilAnt + "' AND Z8_DATAE = '' AND  " +  _cTProc  
	cQuery += "     Z8_CONTROL NOT IN(SELECT ZAE_CONTRO FROM " + RetSqlName("ZAE") + " ZAE WHERE "
	cQuery += "     ZAE.D_E_L_E_T_ <> '*' AND ZAE_FILDES = '" + cFilAnt + "' AND ZAE_DATAM = '" + dtos(mv_par01) + "'"
	cQuery += "     AND ZAE_MOVIM = 'E' AND ZAE_COD = Z8_COD) AND  Z8_DTENTES <> Z8_DATA  AND"
	cQuery += "     Z8_DTENTES = '" + dtos(mv_par01) + "'  AND  (B1_COD = Z8_CODORI OR B1_COD = Z8_COD)) "
	cQuery += " AS ENT_CAIX1,"
	cQuery += "   (SELECT COUNT(Z8_COD)FROM " + RetSqlName("SZ8") + " SZ8 "
	cQuery += "    WHERE SZ8.D_E_L_E_T_ <> '*' AND  Z8_FILIAL = '"+ xfilial("SZ8") + "' AND  "
	cQuery += "     Z8_FILORI = '" + cFilAnt + "' AND Z8_DATAE = ''  AND" +  _cTProc  
	cQuery += "     Z8_DATA = '" + dtos(mv_par01) + "'  AND  B1_COD = Z8_CODORI)
	cQuery += " AS ENT_CAIX2,"           

	cQuery += "   (SELECT SUM(Z8_PESO)FROM " + RetSqlName("SZ8") + " SZ8 "
	cQuery += "    WHERE SZ8.D_E_L_E_T_ <> '*' AND  Z8_FILIAL = '"+ xfilial("SZ8") + "' AND  "
	cQuery += "     Z8_FIL = '" + cFilAnt + "' AND Z8_DATAE = '' AND  " +  _cTProc  
	cQuery += "     Z8_CONTROL NOT IN(SELECT ZAE_CONTRO FROM " + RetSqlName("ZAE") + " ZAE WHERE "
	cQuery += "     ZAE.D_E_L_E_T_ <> '*' AND ZAE_FILDES = '" + cFilAnt + "' AND ZAE_DATAM = '" + dtos(mv_par01) + "'"
	cQuery += "     AND ZAE_MOVIM = 'E' AND ZAE_COD = Z8_COD) AND  Z8_DTENTES <> Z8_DATA  AND"
	cQuery += "     Z8_DTENTES = '" + dtos(mv_par01) + "'  AND  (B1_COD = Z8_CODORI OR B1_COD = Z8_COD)) "
	cQuery += " AS ENT_PESO1,"
	cQuery += "   (SELECT SUM(Z8_PESO)FROM " + RetSqlName("SZ8") + " SZ8 "
	cQuery += "    WHERE SZ8.D_E_L_E_T_ <> '*' AND  Z8_FILIAL = '"+ xfilial("SZ8") + "' AND  "
	cQuery += "     Z8_FILORI = '" + cFilAnt + "' AND Z8_DATAE = ''  AND" +  _cTProc  
	cQuery += "     Z8_DATA = '" + dtos(mv_par01) + "'  AND  B1_COD = Z8_CODORI)
	cQuery += " AS ENT_PESO2"           

	cQuery += " FROM " + RetSqlName("SB1") + " SB1, " + " WHERE SB1.D_E_L_E_T_ <> '*'   " 
	cQuery += " AND B1_TIPO IN('PR','PA') AND B1_FILIAL = '" + xFilial("SB1") + "'" 
	cQuery += " AND (B1_SEGUM = 'CX' OR B1_SEGUM = 'SC') AND B1_MSBLQL = 2 "

	cQuery += " AND B1_COD =  '" + _cCodPro +"'"

	cQuery +=  " ORDER BY B1_COD"

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("POS") != 0
		POS->(dbCloseArea())
	Endif 

	TCQUERY cQuery NEW ALIAS "POS"

	While POS->(!eof()) 

		DbSelectArea('ZA2')
		ZA2->(DbSetOrder(1))
		if !ZA2->(DbSeek(xfilial('ZA2')+dtos(mv_par01)+alltrim(POS->COD)))  

			//	if POS->ENT_CAIX <> 0 
			reclock('ZA2',.t.)
			ZA2->ZA2_FILIAL := xfilial('ZA2')
			ZA2->ZA2_COD    := POS->COD
			ZA2->ZA2_QTENT  := POS->(ENT_CAIX1+ENT_CAIX2)
			ZA2->ZA2_PESENT := POS->(ENT_PESO1+ENT_PESO2)  
			ZA2->ZA2_DATA   := mv_par01
			msunlock()
			//  endif	  
		else          	
			reclock('ZA2',.F.)
			ZA2->ZA2_QTENT  := POS->(ENT_CAIX1+ENT_CAIX2)
			ZA2->ZA2_PESENT := POS->(ENT_PESO1+ENT_PESO2)  
			msunlock()
		endif
		POS->(DbSkip())

	EndDo

Return

//Para o calculo correto da posição de estoque, o valor calculado aqui de transferencia
//deve ser somado ao valor de estoque da posição do dia anterior e na saída do dia
Static Function TransfS(_cCodPro)

	if ! _lOk
		Return
	endif

	cQuery := "SELECT ZAE_COD AS COD,COUNT(*) AS QUANT, SUM(ZAE_PESO) AS PESO " 
	cQuery += " FROM " + RetSqlName("ZAE")+ " ZAE"
	cQuery += " WHERE ZAE.D_E_L_E_T_ <> '*' AND "
	cQuery += " ZAE_FILIAL = '" + xfilial('ZAE') + "' AND "
	cQuery += " ZAE_DATAM = '" + dtos(mv_par01) + "' AND ZAE_MOVIM = 'S' AND " 
	cQuery += " ZAE_FIL = '" + cFilAnt + "'"
	cQuery += " AND ZAE_COD =  '" + _cCodPro + "'"
	cQuery += "  GROUP BY ZAE_COD"

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("POS") != 0
		POS->(dbCloseArea())
	Endif 

	TCQUERY cQuery NEW ALIAS "POS"

	While POS->(!eof())
		DbSelectArea('ZA2')
		ZA2->(DbSetOrder(1))                                                      
		if !ZA2->(DbSeek(xfilial('ZA2')+dtos(mv_par01)+alltrim(POS->COD)))
			//  if  POS->QUANT <> 0

			reclock('ZA2',.t.)
			ZA2->ZA2_FILIAL := xfilial('ZA2')
			ZA2->ZA2_COD    := POS->COD
			ZA2->ZA2_QTRANS := POS->QUANT
			ZA2->ZA2_PTRANS := POS->PESO 
			ZA2->ZA2_DATA   := mv_par01
			msunlock()
			// endif 
		else
			reclock('ZA2',.f.)
			ZA2->ZA2_QTRANS := POS->QUANT
			ZA2->ZA2_PTRANS := POS->PESO 
			msunlock()                 
		endif
		POS->(DbSkip())

	EndDo

Return


//Para o calculo correto da posição de estoque, o valor calculado aqui de transferencia
//deve ser somado junto aos valores de entrada 
Static Function TransfE(_cCodPro) 

	if ! _lOk
		Return
	endif

	cQuery := "SELECT ZAE_COD AS COD,COUNT(*) AS QUANT, SUM(ZAE_PESO) AS PESO " 
	cQuery += " FROM " + RetSqlName("ZAE")+ " ZAE"
	cQuery += " WHERE ZAE.D_E_L_E_T_ <> '*' AND "
	cQuery += " ZAE_FILIAL = '" + xfilial('ZAE') + "' AND "
	cQuery += " ZAE_DATAM = '" + dtos(mv_par01) + "' AND ZAE_MOVIM = 'E' AND " 
	cQuery += " ZAE_FILDES = '" + cFilAnt + "'"
	cQuery += " AND ZAE_COD =  '" + _cCodPro + "'"
	cQuery += " GROUP BY ZAE_COD"

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("POS") != 0
		POS->(dbCloseArea())
	Endif 

	TCQUERY cQuery NEW ALIAS "POS"

	While POS->(!eof())
		DbSelectArea('ZA2')
		ZA2->(DbSetOrder(1))
		if !ZA2->(DbSeek(xfilial('ZA2')+dtos(mv_par01)+alltrim(POS->COD)))      
			//  if POS->QUANT <> 0  

			reclock('ZA2',.t.)
			ZA2->ZA2_FILIAL := xfilial('ZA2')
			ZA2->ZA2_COD    := POS->COD
			ZA2->ZA2_QTRANE := POS->QUANT
			ZA2->ZA2_PTRANE := POS->PESO
			ZA2->ZA2_DATA   := mv_par01  
			msunlock()
			//  endif
		else
			reclock('ZA2',.f.)
			ZA2->ZA2_QTRANE := POS->QUANT
			ZA2->ZA2_PTRANE := POS->PESO
			msunlock()
		endif
		POS->(DbSkip())

	EndDo

Return
//Calcula do que saiu no dia apontado sem levar em consideração as transferencias
Static Function Saida(_cCodPro)

	if ! _lOk
		Return
	endif

	if !_lTProc
		_cTProc := " Z8_TIPO <> 'R'  AND"
	endif

	cQuery := " SELECT  B1_COD AS COD, "

	cQuery += " (SELECT COUNT(Z8_COD) FROM " + RetSqlName("SZ8") + " SZ8 WHERE SZ8.D_E_L_E_T_ <> '*' AND  "
	cQuery += "  Z8_FILIAL = '"+ xfilial("SZ8") + "' AND Z8_FIL = '"+ cFilAnt + "' AND "  
	cQuery += "  Z8_DATAE = '' AND Z8_DATAS = '" + dtos(mv_par01) +  "'" 
	cQuery += "  AND " +  _cTProc  
	cQuery += "  Z8_CONTROL NOT IN(SELECT ZAE_CONTRO FROM " + RetSqlName("ZAE") + " ZAE WHERE "
	cQuery += "  ZAE.D_E_L_E_T_ <> '*' AND ZAE_FIL = '" + cFilAnt + "' AND ZAE_DATAM = '" + dtos(mv_par01) + "'"
	cQuery += "  AND ZAE_MOVIM = 'S' AND ZAE_COD = Z8_COD)"
	cQuery += "  AND Z8_COD = B1_COD) AS SAI_CAIX, "  

	cQuery += " (SELECT SUM(Z8_PESO) FROM " + RetSqlName("SZ8") + " SZ8 WHERE SZ8.D_E_L_E_T_ <> '*' AND  "
	cQuery += "  Z8_FILIAL = '"+ xfilial("SZ8") + "' AND Z8_FIL = '"+ cFilAnt + "' AND "  
	cQuery += "  Z8_DATAE = '' AND Z8_DATAS = '" + dtos(mv_par01) +  "'" 
	cQuery += "  AND " +  _cTProc  
	cQuery += "  Z8_CONTROL NOT IN(SELECT ZAE_CONTRO FROM "  + RetSqlName("ZAE") + " ZAE WHERE "
	cQuery += "  ZAE.D_E_L_E_T_ <> '*' AND ZAE_FIL = '" + cFilAnt + "' AND ZAE_DATAM = '" + dtos(mv_par01) + "'"
	cQuery += "  AND ZAE_MOVIM = 'S' AND ZAE_COD = Z8_COD)"
	cQuery += "  AND Z8_COD = B1_COD) AS SAI_PESO "  

	cQuery += " FROM " + RetSqlName("SB1") + ", " + " WHERE SB1010.D_E_L_E_T_ <> '*'   " 
	cQuery += " AND B1_TIPO IN('PR','PA') AND B1_FILIAL = '" + xFilial("SB1")+ "'"
	cQuery += " AND (B1_SEGUM = 'CX' OR B1_SEGUM = 'SC') AND B1_MSBLQL = 2 "

	cQuery += " AND B1_COD =  '" + _cCodPro + "'"


	cQuery +=  " ORDER BY B1_COD"

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("POS") != 0
		POS->(dbCloseArea())
	Endif 

	TCQUERY cQuery NEW ALIAS "POS"

	While POS->(!eof())
		DbSelectArea('ZA2')
		ZA2->(DbSetOrder(1))
		if !ZA2->(DbSeek(xfilial('ZA2')+dtos(mv_par01)+alltrim(POS->COD))) 
			//  if POS->SAI_CAIX <> 0 

			reclock('ZA2',.t.)
			ZA2->ZA2_FILIAL := xfilial('ZA2')
			ZA2->ZA2_COD    := POS->COD
			ZA2->ZA2_QTSAI  := POS->SAI_CAIX 
			ZA2->ZA2_PESSAI := POS->SAI_PESO 
			ZA2->ZA2_DATA   := mv_par01
			msunlock() 
			//  endif
		else
			reclock('ZA2',.F.)
			ZA2->ZA2_QTSAI  := POS->SAI_CAIX 
			ZA2->ZA2_PESSAI := POS->SAI_PESO 
			msunlock()
		endif
		POS->(DbSkip())

	EndDo

Return

//Calcula o estoque levando em consideração o que foi transferido
//Deve deduzir a transeferencia para se apurar o que realmente estava em estoque
//O que está sendo calculado é o que havia em estoque um dia antes da data apontada no calculo
Static Function Estoque(_cCodPro) 
	Local _nPosAntC := 0
	Local _nPosAntP := 0

	if ! _lOk
		Return
	endif

	cQuery := " SELECT  B1_COD AS COD, "

	cQuery += "  (SELECT COUNT(Z8_COD) FROM " + RetSQLName('SZ8') + " SZ8  "
	cQuery += "    WHERE SZ8.D_E_L_E_T_ <> '*' AND  Z8_FILIAL = '"+ xfilial("SZ8") + "' AND  "
	cQuery += "    Z8_FIL = '"+ cFilAnt + "' AND Z8_DTRANSF <> '" + dtos(mv_par01) + "' AND "
	cQuery += "    (Z8_DATAS = '' OR Z8_DATAS >= '" + dtos(mv_par01) + "') AND "
	cQuery += "    Z8_DTENTES < '" + dtos(mv_par01) + "'  AND  B1_COD = Z8_COD) AS EST_CAIX,"           

	cQuery += "  (SELECT SUM(Z8_PESO) FROM " + RetSQLName('SZ8') + " SZ8  "
	cQuery += "    WHERE SZ8.D_E_L_E_T_ <> '*' AND  Z8_FILIAL = '"+ xfilial("SZ8") + "' AND  "
	cQuery += "    Z8_FIL = '"+ cFilAnt + "' AND Z8_DTRANSF <> '" + dtos(mv_par01) + "' AND "
	cQuery += "   (Z8_DATAS = '' OR Z8_DATAS >= '" + dtos(mv_par01) + "') AND 
	cQuery += "    Z8_DTENTES < '" + dtos(mv_par01) + "'  AND  B1_COD = Z8_COD) AS EST_PESO,"           

	cQuery += "  (SELECT COUNT(DISTINCT ZAE_CONTRO) FROM " + RetSqlName("ZAE") + " ZAE WHERE "
	cQuery += "  ZAE.D_E_L_E_T_ <> '*' AND ZAE_FIL = '" + cFilAnt + "' AND  ZAE_MOVIM = 'S' AND"
	cQuery += "  ZAE_DATAM >= '" + dtos(mv_par01) + "' AND 
	cQuery += "  ZAE_DATA < '" + dtos(mv_par01) + "'"           
	cQuery += "  AND ZAE_COD = B1_COD) AS EST_T_CAIX,"           

	cQuery += " (SELECT SUM(ZAE_PESO) FROM " + RetSqlName("ZAE") + " ZAE WHERE "
	cQuery += "  ZAE.D_E_L_E_T_ <> '*' AND ZAE_FIL = '" + cFilAnt + "' AND  ZAE_MOVIM = 'S' AND"
	cQuery += "  ZAE_DATAM >= '" + dtos(mv_par01) + "' AND "
	cQuery += "  ZAE_DATA < '" + dtos(mv_par01) + "' AND ZAE_CONTRO IN(SELECT DISTINCT ZAE_CONTRO "
	cQuery += "                                                       FROM " + RetSqlName("ZAE") + " ZAE "
	cQuery += "                                                       WHERE ZAE.D_E_L_E_T_ <> '*' AND ZAE_FIL = '" + cFilAnt + "'"
	cQuery += "                                                              AND  ZAE_MOVIM = 'S' AND ZAE_DATAM >= '" + dtos(mv_par01) + "'"
	cQuery += "                                                              AND ZAE_DATA < '" + dtos(mv_par01) + "' AND ZAE_COD = B1_COD)"           
	cQuery += "  AND ZAE_COD = B1_COD) AS EST_T_PESO"           


	cQuery += " FROM " + RetSqlName("SB1") + " SB1 WHERE SB1.D_E_L_E_T_ <> '*'   " 
	cQuery += " AND B1_TIPO IN('PR','PA') AND B1_FILIAL = '" + xFilial("SB1")+ "'" 
	cQuery += " AND (B1_SEGUM = 'CX' OR B1_SEGUM = 'SC') AND B1_MSBLQL = 2 "

	cQuery += " AND B1_COD =  '" + _cCodPro + "'"

	cQuery +=  " ORDER BY B1_COD"

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("POS") != 0
		POS->(dbCloseArea())
	Endif 

	TCQUERY cQuery NEW ALIAS "POS"

	While POS->(!eof())

		DbSelectArea('ZA2')
		ZA2->(DbSetOrder(1)) 

		_nPosAntC := POS->(EST_CAIX + EST_T_CAIX)
		_nPosAntP := POS->(EST_PESO + EST_T_PESO)

		if !ZA2->(DbSeek(xfilial('ZA2')+dtos(mv_par01)+alltrim(POS->COD))) 	
			reclock('ZA2',.t.)
			ZA2->ZA2_FILIAL := xfilial('ZA2')
			ZA2->ZA2_COD    := POS->COD
			ZA2->ZA2_QTEST  := _nPosAntC
			ZA2->ZA2_PESEST := _nPosAntP
			ZA2->ZA2_DATA   := mv_par01
			msunlock() 
		else 
			reclock('ZA2',.F.)
			ZA2->ZA2_QTEST  := _nPosAntC
			ZA2->ZA2_PESEST := _nPosAntP
			msunlock()

		endif    

		POS->(DbSkip())

	EndDo

Return

//Função que cria registros de produtos que não forma processados
Static Function Final()

	if ! _lOk
		Return
	endif

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())

	_NumReg := Contar('SB1',"B1_FILIAL = xfilial('SB1')")

	ProcRegua(_NumReg)

	if SB1->(DbSeek(xfilial('SB1')))

		While SB1->(!eof()) .and. xfilial('SB1') = SB1->B1_FILIAL

			IncProc()

			if SB1->B1_MSBLQL = '1'
				SB1->(DbSkip())
				loop
			endif 

			if SB1->B1_TIPO <> 'PA' .and. SB1->B1_TIPO <> 'PR'
				SB1->(DbSkip())
				loop
			endif

			DbSelectArea('ZA2')
			ZA2->(DbSetOrder(1))

			if !ZA2->(DbSeek(xfilial('ZA2')+dtos(mv_par01)+alltrim(SB1->B1_COD))) 

				reclock('ZA2',.t.)
				ZA2->ZA2_FILIAL := xfilial('ZA2')
				ZA2->ZA2_COD    := SB1->B1_COD
				ZA2->ZA2_DATA   := mv_par01
				msunlock()

			endif

			SB1->(DbSkip())
		enddo
	endif

Return

//Função que cria o arquivo temporário
Static Function  criaTMP()

	If Select('TMP')<>0                                                         
		DbSelectArea('TMP')
		DbCloseArea('TMP')
	endif

	AADD(aCampos,{"OKAY"  ,,"OK"        ,"@!"   })
	aadd(aCampos,{"COD"   ,,"Codigo"    ,"@!"   })
	aadd(aCampos,{"DESCRI",,"Descrição" ,"@!"   })
	aadd(aCampos,{"FARM"  ,,"Armazenam.","@!"   })


	aStru := {}  
	AADD(aStru,{"OKAY"   ,"C"	,02,0	})
	aadd(aStru,{"COD"    ,"C"  ,06,0 })
	aadd(aStru,{"DESCRI" ,"C"  ,60,0 })
	aadd(aStru,{"FARM"   ,"C"  ,10,0 })  

	do case
		case mv_par02 = 1
		_Farm := 'C'
		case mv_par02 = 2
		_Farm := 'R'
		case mv_par02 = 3
		_Farm := 'S'
		otherwise
		_Farm := 'T'
	endcase     

	cQuery := " SELECT B1_COD AS COD, B1_DESC AS DESCRI, BM_FARM AS FARM"
	cQuery += " FROM "  + RetSQLTab('SB1')+ "," + RetSQLTab('SBM')
	cQuery += " WHERE " + RetSQLFil('SB1') + "AND " + RetSQLFil('SBM') + " AND "
	cQuery +=  RetSQLDel('SB1') + " AND " + RetSQLDel('SBM') + " AND B1_MSBLQL <> '1' AND B1_TIPO IN('PA','PR') AND BM_GRUPO = B1_GRUPO "

	if _Farm != 'T'
		cQuery += " AND BM_FARM = '" + _Farm + "'"          
	endif 

	if !empty(mv_par03)
		cQuery += " AND B1_FAM = '" + mv_par03 + "'"   
	endif              


	if mv_par04 = 1
		cQuery += " AND B1_CLEBER <> ''"   
	endif              

	//Filtra desossa, porcionados ou todos
	if mv_par05 = 1
		cQuery += " AND B1_GRUPO NOT IN('5611','5612','5613','5614','5621') "
	elseif  mv_par05 = 2
		cQuery += " AND B1_GRUPO IN('5611','5612','5613','5614','5621') "	   
	endif  

	cQuery += " ORDER BY  B1_COD, B1_DESC "

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	_aArqTrb    := {}
	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	//dbcreate(cArq,aStru)
	//Cria a estrutura do vetor no TMP criado
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	QRY->(DbGoTop())

	While QRY->(!eof())

		reclock('TMP',.t.)
		TMP->COD    := QRY->COD
		TMP->DESCRI := QRY->DESCRI
		TMP->FARM   := iif(QRY->FARM = 'C','Congelado',iif(QRY->FARM = 'R','Resfriado','Salgado'))
		TMP->OKAY   := space(1)
		msunlock()

		QRY->(DbSkip())
	enddo

	TMP->(DbGoTop())

	QRY->(DbCloseArea())

return   

User Function gjf03clc()
	_lCalc := .t.
	oDlg:end()
return

User Function gjf03sel()
	TMP->(dbgotop())   

	while TMP->(!eof())                                                           //O campo com 'S' significa que o registro foi assinalado
		reclock('TMP',.f.)
		TMP->OKAY := cMark
		msunlock()
		TMP->(dbskip())
	enddo      

	TMP->(dbgotop())   

return 

//Função basica que chama todos os calculos
Static Function Calcular()
	TMP->(DbGoTop()) 

	ProcRegua(TMP->(RecCount()))

	While TMP->(!Eof())

		IncProc()

		if !empty(TMP->OKAY) 
			Inicio(TMP->COD)
			Entrada(TMP->COD)
			TransfE(TMP->COD)
			Saida(TMP->COD)
			TransfS(TMP->COD)
			Estoque(TMP->COD)
		endif

		TMP->(DbSkip()) 
	enddo

return


Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("OKAY")	   
		TMP->OKAY := cMark
	Else     
		TMP->OKAY := ""
	Endif             
	msunlock()
	oMark:oBrowse:Refresh()
Return()
