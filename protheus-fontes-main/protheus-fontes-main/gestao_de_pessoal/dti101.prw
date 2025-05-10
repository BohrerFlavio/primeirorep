#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI101    ºAutor  ³Flávio Bohrer Flôres º Data ³  22/05/20  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fonte destinado à alteração de Status da SRA , para quando º±±
±±º          ³ vencer os prazos dos atestados/Férias	Chamado 59 	      º±±
±±º          ³ Dia 19/06/20 incluida na gjf170 para rodar diariamente     º±±
±±º          ³ 													 	      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Patrícia/Marcela - RH 		                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function dti101()
	Local _cMat := ''
	Local _cCont := 0
	
	_cQuery := " SELECT RA_MAT,RA_SITFOLH"
	_cQuery += " FROM  " + retSqlTab('SRA')
	_cQuery += " WHERE " + retSqlFil('SRA')
	_cQuery += " AND " + retSqlDel('SRA')
	_cQuery += " AND RA_SITFOLH IN ('A','F')"
	
	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//Return .t.
	
	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	QRY->(dbGoTop())
	While QRY->(!eof())
 
		If _cCont = 0
						
			_cMat := alltrim(QRY->RA_MAT)			
			versr8(alltrim(_cMat))
						
		Endif
		
		if _cMat <> alltrim(QRY->RA_MAT) 
			
			versr8(alltrim(_cMat))			
			_cMat := alltrim(QRY->RA_MAT)
			
		Endif
		
		_cCont++	
		QRY->(DbSkip())
		
	enddo
	
return .T.



Static Function versr8(_cMat)
	
	_cQuery2 := " SELECT TOP 1 * "
	_cQuery2 += " FROM  " + retSqlTab('SR8')
	_cQuery2 += " WHERE " + retSqlFil('SR8')
	_cQuery2 += " AND " + retSqlDel('SR8')
	_cQuery2 += " AND R8_MAT = '" + _cMat + "'"
	_cquery2 += " ORDER BY R8_SEQ DESC"
	
	
	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//Return .t.
	
	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "QRY2"
		
	QRY2->(dbGoTop())
	While QRY2->(!eof())	
					
		if empty(QRY2->R8_DATAFIM)
			
		Else	
			
			if 	QRY2->R8_DATAFIM < dtos(date())
				
					dbSelectArea("SRA")
					SRA->(dbSetOrder(1))
					SRA->(dbSeek(xFilial('SRA')+QRY2->R8_MAT))
					reclock('SRA',.F.)
						SRA->RA_SITFOLH := ''
					msunlock()
						
			endif
			
		endif
		
		QRY2->(DbSkip())
		
	enddo
		
return


