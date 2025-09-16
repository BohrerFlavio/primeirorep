#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SIRHFOR11º Autor Flávio Bohrer           Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de Fórmulas para o cálculo da salário hora P/Dissídioº±±
±±º          ³  Retroativo  											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10 IDE                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/     

USER FUNCTION  SIRHFO11()
	Private _cVERBA := ''
	Private _nValor := 0.00

	DbSelectArea('RHH')
	RHH->(dbSetOrder(2))
	RHH->(DbSeek(xfilial('RHH')+RHH->(RHH_MAT+RHH_DATA+RHH_MESANO+RHH_VB+RHH_CC+RHH_ITEM+RHH_CLVL)))                     
	/* Query*/
	_cQuery := "SELECT R_E_C_N_O_,RHH_VB AS VERBA,RHH_VALOR AS VALOR FROM "+RetSqlName("RHH")+" RHH "
	_cQuery += " WHERE RHH_MAT    	= '" + RHH->RHH_MAT
	_cQuery += "' AND  RHH_DATA     = '" + RHH->RHH_DATA
	_cQuery += "' AND  RHH_VB   	= '122' "
	_cQuery += "  AND  RHH_FILIAL 	= '" + xfilial("RHH") + "'"   
	_cQuery += "  ORDER BY R_E_C_N_O_ DESC "

	_cQuery := ChangeQuery(_cQuery)


	If Select("DISS")<>0
		DISS->(dbCloseArea())
	Endif            

	TCQUERY _cQuery NEW ALIAS "DISS"
	/*grava variável aqui*/     

	DISS->(DbGoTop())

	if !empty(DISS->VERBA)
		_cVERBA := DISS->VERBA
		_nValor := DISS->VALOR 
		_nValor2 := (_nValor/3)
		fGeraVerba("211",_nValor2,,,,"V","I",,,,.T.) 
	endif

	DISS->(dbclosearea())

	/*Fim query*/

RETURN 
