#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

User Function ob_rbh()

	Private aRotina := {}
	PRIVATE cCadastro := "Cadastro de regras"

	if SM0->M0_CODIGO == "01" .or. SM0->M0_CODIGO == "08"
		cPerg :=  "OB_RBH"
		if Pergunte(cPerg,.T.)

			cExprFilTop := "ZD4_DATA >= '"+DTOS(MV_PAR01)+"' AND ZD4_DATA <= '"+DTOS(MV_PAR02)+"' AND ZD4_CC >= '"+MV_PAR03+"' AND ZD4_CC <= '"+MV_PAR04+"' "
			MenuDef()

			MBrowse( 06, 01, 22, 75,"ZD4",,,,,,,,,,,,,,cExprFilTop)
		endif
	Else
		MsgBox("Esta empresa nao autorizada a usar esta rotina","ATENCAO","STOP")
	Endif

return()

User Function OB_ZD4(_cOpcao)
	Local _ni
	Local _l 
	Local i
	Private aAltEnchoice:= {"ZD4_DATA","ZD4_CC","ZD4_TURNO","ZD4_DESCBE","ZD4_SANTEC","ZD4_SALFIM"}
	Private nAlturaEnc:= 300	//Altura da Enchoice
//+--------------------------------------------------------------+
//| Opcoes de acesso para a Modelo 3                             |
//+--------------------------------------------------------------+
	Do Case
	Case _cOpcao=="I"; 	nOpcE:=3 ; 	nOpcG:=3
	Case _cOpcao=="A"; 	nOpcE:=4 ; 	nOpcG:=4
	Case _cOpcao=="E"; 	nOpcE:=5 ; 	nOpcG:=5
	Case _cOpcao=="V"; 	nOpcE:=2 ; 	nOpcG:=2
	EndCase
	if _cOpcao=="A"
		aAltEnchoice:= {"ZD4_DESCBE","ZD4_SANTEC","ZD4_SALFIM","ZD4_TOLERA","ZD4_MEDIA"}
	endif
	DbSelectArea("ZD4")

//+--------------------------------------------------------------+
//| Cria variaveis M->????? da Enchoice                          |
//+--------------------------------------------------------------+
	RegToMemory("ZD4",(_cOpcao=="I"))
//+--------------------------------------------------------------+
//| Cria aHeader e aCols da GetDados                             |
//+--------------------------------------------------------------+
	nUsado:=0

	//dbSelectArea("SX3")
	//DbSetOrder(1)
	//DbSeek("ZD5")
	aHeader:={}
	//While !Eof().And.(x3_arquivo=="ZD5")
	//	if alltrim(x3_campo) $ "ZD5_DIA / ZD5_TPEVEN / ZD5_QTDHEI"
	//		nUsado:=nUsado+1
	//		Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
	//			x3_tamanho, x3_decimal,"AllwaysTrue()",;
	//			x3_usado, x3_tipo, x3_arquivo, x3_context } )
	//	Endif
	//	dbSkip()
	//End

	_cAlias  := "ZD5"
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	_cAcols  := "ZD5_DIA/ZD5_TPEVEN/ZD5_QTDHEI"
	For i := 1 To Len(_aCpoSX3)
		If(X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) .And. AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) $ _cAcols)
			nUsado:=nUsado+1
			aAdd(aHeader, { GetSx3Cache(_aCpoSX3[i], 'X3_TITULO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_PICTURE')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_TAMANHO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_DECIMAL')	,;
							"AllwaysTrue()"							,;
							GetSx3Cache(_aCpoSX3[i], 'X3_USADO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_TIPO')		,;
							GetSx3Cache(_aCpoSX3[i], 'X3_ARQUIVO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_CONTEXT')	})
		Endif
	Next i

	If _cOpcao=="I"
		aCols:={Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For _ni:=1 to nUsado
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		Next
	Else
		aCols:={}
		dbSelectArea("ZD5")
		dbSetOrder(2)
		DbSeek(FWxFilial("ZD5")+DTOS(M->ZD4_DATA)+M->ZD4_CC+M->ZD4_TURNO)
		While !eof().and. ZD5->ZD5_DATA == M->ZD4_DATA .AND. alltrim(ZD5->ZD5_CC)==alltrim( M->ZD4_CC);
				.AND. alltrim(ZD5->ZD5_TURNO) == alltrim(M->ZD4_TURNO)
			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
			dbSkip()
		End
	Endif

	//+--------------------------------------------------------------+
	//| Executa a Modelo 3                                           |
	//+--------------------------------------------------------------+
	cTitulo:="Cadastro de regras de banco de horas"
	cAliasEnchoice:="ZD4"
	cAliasGetD:="ZD5"
	cLinOk:="AllwaysTrue()"
	if _cOpcao == "I"
		cTudOk:= "u__ZD4TOk()"
	else
		cTudOk:="AllwaysTrue()"
	endif	
	cFieldOk:="AllwaysTrue()"
	_lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,aAltenchoice,,,,nAlturaEnc)
	//+--------------------------------------------------------------+
	//| Executar processamento                                       |
	//+--------------------------------------------------------------+
	If _lRet
		If _cOpcao $ "IA"
			If _cOpcao $ "A"
				DbSelectArea("ZD4")
				DbSetOrder(1)
				DbSeek(FWxFilial("ZD4")+DTOS(M->ZD4_DATA)+M->ZD4_CC+M->ZD4_TURNO)
				If !Found()
					_lRet := .F.
				Endif
			Endif
			If _lRet
				RecLock("ZD4",INCLUI)
				ZD4->ZD4_FILIAL := FWxFilial("ZD4")
				ZD4->ZD4_DATA   := M->ZD4_DATA
				ZD4->ZD4_CC     := M->ZD4_CC
				ZD4->ZD4_TURNO  := M->ZD4_TURNO
				ZD4->ZD4_DESCBE := M->ZD4_DESCBE
				ZD4->ZD4_SANTEC := M->ZD4_SANTEC
				ZD4->ZD4_SALFIM := M->ZD4_SALFIM
				ZD4->ZD4_TOLERA := M->ZD4_TOLERA
				ZD4->ZD4_MEDIA  := M->ZD4_MEDIA
				DbSelectArea("ZD4")
				MsUnLock()
				_cAnt := ""
				_aCod := {}
				For _l := 1 To Len(aCols)
					If !GDDeleted(_l) .and. !empty(dtos(aCols[_l,01])) .AND. !empty(aCols[_l,02])
						DbSelectArea("ZD5")
						DbSetOrder(2)
						If !DbSeek(FWxFilial("ZD5")+DTOS(M->ZD4_DATA)+M->ZD4_CC+M->ZD4_TURNO+DTOS(aCols[_l,01]))
							RecLock("ZD5",.T.)
						Else
							RecLock("ZD5",.F.)
						Endif						
						ZD5->ZD5_FILIAL  := FWxFilial("ZD5")
						ZD5->ZD5_DATA  := M->ZD4_DATA
						ZD5->ZD5_CC    := M->ZD4_CC
						ZD5->ZD5_TURNO  := M->ZD4_TURNO
						ZD5->ZD5_DIA    := aCols[_l,01]
						ZD5->ZD5_TPEVEN := aCols[_l,02]
						ZD5->ZD5_QTDHEI := aCols[_l,03]
						MsUnLock()
					Else
						DbSelectArea("ZD5")
						DbSetOrder(2)
						If DbSeek(FWxFilial("ZD5")+DTOS(M->ZD4_DATA)+M->ZD4_CC+M->ZD4_TURNO+DTOS(aCols[_l,01]))
							RecLock("ZD5",.F.)
							DbDelete()
							MsUnLock()
						Endif
					Endif
				Next _l
			Endif
		ElseIf _cOpcao $ "E"
			DbSelectArea("ZD4")
			RecLock("ZD4",.F.)
			DbDelete()
			MsUnLock()
			DbSelectArea("ZD5")
			DbSetOrder(1)
			DbSeek(FWxFilial("ZD5")+DTOS(M->ZD4_DATA))
			Do While !EOF() .And. DTOS(ZD5->ZD5_DATA) == DTOS(M->ZD4_DATA)
				if M->ZD4_CC == ZD5->ZD5_CC .AND.  M->ZD4_TURNO == ZD5->ZD5_TURNO
					RecLock("ZD5",.F.)
					DbDelete()
					MsUnLock()
					DbSkip()
				endif	
			EndDo
		Endif
	endif
Return


Static Function MenuDef()
	aRotina:= { { "Pesquisar"    ,"AxPesqui" 					, 0, 1, 0, NIL},;
		{ "Visualizar"   ,'U_OB_ZD4("V")' , 0, 2, 0, NIL},;
		{ "Incluir"      ,'U_OB_ZD4("I")' , 0, 3, 0, NIL},;
		{ "Alterar"      ,'U_OB_ZD4("A")' , 0, 4, 0, NIL},;
		{ "Excluir"      ,'U_OB_ZD4("E")' , 0, 5, 0, NIL},;
		{ "Exceções"     ,'U_OB_ZD1()'    , 0, 6, 0, NIL},;
		{ "Médias BH Neg.",'U_OB_ZD4MED()', 0, 7, 0, NIL} }
Return aRotina


/*
Valida se esse cadastro já existe para data, turno e cc
*/
user function _ZD4TOk()
Local _lRet := .T.
	cQuery := " select count(*) as CONTADOR" 
	cQuery += " from " + retsqlname("ZD4") +" AS ZD4 "
	cQuery += " where ZD4.D_E_L_E_T_ = '' AND ZD4_FILIAL = '"+FWxFilial("ZD4")+"' AND ZD4_CC = '"+M->ZD4_CC+"' "
	cQuery += " AND ZD4_TURNO = '" + M->ZD4_TURNO +"' AND ZD4_DATA = '"+DTOS(M->ZD4_DATA)+"'"

	TcQuery cQuery New ALIAS "TRB"

	DbSelectArea("TRB")
	DbGoTop()
	Do While !Eof()
		if TRB->CONTADOR > 0 
			MsgAlert("Cadastro de data + centro de custo + turno já existente, não possível gravar.")
			_lRet := .F.
		endif
		TRB->(DbSkip())	
	Enddo
	TRB->(DbCloseArea())
return(_lRet)

user function OB_ZD1()
	cExpr2 := "ZD1_DATA >= '"+DTOS(MV_PAR01)+"' AND ZD1_DATA <= '"+DTOS(MV_PAR02)+"'  "
	MenuDef2()

	dbSelectArea("ZD1")
	dbSetOrder(1)

	MBrowse( 06, 01, 22, 75,"ZD1",,,,,,,,,,,,,,cExpr2)

	dbSelectArea("ZD4")
	dbSetOrder(1)
	MenuDef()
return

Static Function MenuDef2()
	aRotina:= { { "Pesquisar"    ,"AxPesqui" 					, 0, 1, 0, NIL},;	
		{ "Visualizar"   ,"AxVisual" , 0, 2, 0, NIL},;	
		{ "Incluir"      ,'AxInclui' , 0, 3, 0, NIL},;
		{ "Alterar"      ,'AxAltera' , 0, 4, 0, NIL},;
		{ "Excluir"      ,'AxDeleta' , 0, 5, 0, NIL}}
Return aRotina

user function OB_ZD4MED()
	Local _v := 0 
	cPerg2 :=  "OB_ZD4MED"
	if Pergunte(cPerg2,.T.)
		cQuery := " SELECT PI_CC, RA_TNOTRAB, SUM(POSITIVO) AS POS, SUM(NEGATIVO) AS NEG, SUM(CONT) AS NUMFUN, ZD4_DATA FROM " 
		cQuery += " (SELECT PI_MAT, PI_CC, RA_TNOTRAB, ZD4_DATA, " 
		cQuery += " SUM(CASE WHEN PI_PD < 500 THEN (CAST(PI_QUANT AS INTEGER) + (((PI_QUANT - CAST(PI_QUANT AS INTEGER))*100) /60)) ELSE 0 END) AS POSITIVO, "
		cQuery += "SUM(CASE WHEN PI_PD >= 500 THEN (CAST(PI_QUANT AS INTEGER) + (((PI_QUANT - CAST(PI_QUANT AS INTEGER))*100) /60)) ELSE 0 END) AS NEGATIVO, "
		cQuery += "count(DISTINCT PI_MAT) AS CONT "
		cQuery += "FROM " + retsqlname("SPI") +" AS SPI "
		cQuery += "INNER JOIN " + retsqlname("SRA") +" AS SRA ON RA_FILIAL = PI_FILIAL AND RA_MAT = PI_MAT  AND SRA.D_E_L_E_T_ = '' "
		cQuery += "INNER JOIN " + retsqlname("ZD4") +" AS ZD4 ON ZD4_CC = PI_CC AND ZD4_TURNO = RA_TNOTRAB AND ZD4.D_E_L_E_T_ = '' AND ZD4_SALFIM = 'M' AND ZD4_DATA = '"+DTOS(MV_PAR02)+"' "
		cQuery += "WHERE SPI.D_E_L_E_T_ = '' AND PI_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
		cQuery += " AND PI_CC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
		cQuery += "GROUP BY PI_MAT, PI_CC,  RA_TNOTRAB, ZD4_DATA) AS AAAA "
		cQuery += "GROUP BY PI_CC, RA_TNOTRAB, ZD4_DATA "
		cQuery += "ORDER BY PI_CC, RA_TNOTRAB "
		TcQuery cQuery New ALIAS "TRB"

		DbSelectArea("TRB")
		DbGoTop()
		Do While !Eof()
			DbSelectArea("ZD4")
			DbSetOrder(1)
			DbSeek(FWxFilial("ZD4")+TRB->ZD4_DATA+LEFT(TRB->PI_CC+space(10),TAMSX3("ZD4_CC")[1])+TRB->RA_TNOTRAB)
			If Found()
				RecLock("ZD4",.F.)
				ZD4->ZD4_POSITI := round(TRB->POS,2)
				ZD4->ZD4_NEGATI := round(TRB->NEG,2)
				ZD4->ZD4_SALDO  := round(TRB->POS-TRB->NEG,2)
				ZD4->ZD4_FUNCIO := TRB->NUMFUN
				ZD4->ZD4_MEDIA  := round((TRB->POS-TRB->NEG)/TRB->NUMFUN,2)
				MsUnLock()
				_v++
			endif
			TRB->(DbSkip())
			
		Enddo
		TRB->(DbCloseArea())
		MsgAlert(alltrim(str(_v))+ " regras atualizadas!")
	endif

return
