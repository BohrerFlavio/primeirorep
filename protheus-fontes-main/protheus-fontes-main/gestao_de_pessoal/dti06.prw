#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI06     ºAutor  ³ Mauricio Roehrs    º Data ³  05/07/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa desenvolvido com a finalidade de calcular o       º±±
±±º          ³ o desconto das refeições e lanches dos funcionarios        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function DTI06()

	Private _cDtPeriodo    := GETMV('MV_PAPONTA')//parametro que possui a data de apontamento do ponto
	//Private _cDtIni     	  := substr(_cDtPeriodo,1,8)
	//Private _cDtFim 	  	  := substr(_cDtPeriodo,10,18)

	Private _cDiaIni     	  := substr(_cDtPeriodo,7,2)
	Private _cDiaFim 	  	  := substr(_cDtPeriodo,16,2)
	Private _sDtIni :=  left(dtos(stod(cPeriodo+"01") - 1),6)+_cDiaIni
	Private _sDtFim :=  cPeriodo+_cDiaFim

	Private _dIniPer       := stod("")
	Private _dFimPer	     := stod("")
	Private _dAnoIni    	  := stod("")
	Private _dAnoFim	  	  := stod("")
	Private _cMat		  	  := ''
	Private _dDataCorrente := stod("")
	Private _nDias 		  := 0
	Private _aBat			  := {}
	Private _nTotHr		  := 0
	Private _dDataIni		  := stod("")
	Private _nVal425       := 0
	Private _nVal502		  := 0

	//função que calcula os descontos
	calcDesc()

Return


Static Function calcDesc()

	//_dIniPer := stod(substr(_cDtPeriodo,1,8))
	//_dFimPer := stod(substr(_cDtPeriodo,10,18))
	_dIniPer := stod(_sDtIni)
	_dFimPer := stod(_sDtFim)


	_cQuery := " SELECT ZB8_VLDSC, ZB8_PD
	_cQuery += " FROM " + retSqlTab("ZB8")
	_cQuery += " WHERE " + retSqlFil("ZB8")
	_cQuery += " AND ZB8_MAT = '" + SRA->RA_MAT + "'"
	_cQuery += " AND ZB8_DATA BETWEEN '" + dtos(_dIniPer) + "' AND '" + dtos(_dFimPer) + "'"
	_cQuery += " AND " + retSqlDel("ZB8")
	_cQuery += " ORDER BY ZB8_PD   


	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	TMP->(DbGoTop())
	while TMP->(!eof())

		if TMP->ZB8_PD == '502'
			_nVal502 += TMP->ZB8_VLDSC							
		endif

		if TMP->ZB8_PD == '425'
			_nVal425 += TMP->ZB8_VLDSC		       
		endif			

		TMP->(dbSkip())	
	enddo

	//deleta a verba de refeições
	fdelPD('425')
	//deleta a verba de lanches
	fdelPD('502')

	//gera a verba de refeições
	fGeraVerba("425",_nVal425,,,,"V","I",,,,.T.) 
	//gera a verba de lanches
	fGeraVerba("502",_nVal502,,,,"V","I",,,,.T.) 
	
	_nVal425 := 0
	_nVal502 := 0

return
