#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_gcaixa(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	Local nRet:= 0
	Local i:= 0
	Local cProd:= ""
	Local nPeso:= ""

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	For i := 1 To Len(__aProcParms)  
		If Alltrim(__aProcParms[i, 1]) == 'produto'
			cProd:= __aProcParms[i, 2]
		EndIf
		If Alltrim(__aProcParms[i, 1]) == 'peso'
			nPeso:= StrTran(StrTran(__aProcParms[i, 2], '.', ''), ',', '.')
		EndIf
	Next i

	If !Empty(cProd) .AND. !Empty(nPeso)
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbseek(xFilial("SB1")+cProd)
		If Found()
			nRet:= Round(Val(nPeso)/SB1->B1_PMCAIX, 0)
		EndIf
	EndIf

	RESET ENVIRONMENT

Return Transform(nRet, "@e 999999999")
