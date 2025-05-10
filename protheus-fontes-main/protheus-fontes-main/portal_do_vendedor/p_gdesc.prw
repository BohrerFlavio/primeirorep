#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_gdesc(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	Local cRet:= ""
	Local cTab:= ""
	Local i:= 0
	Local cProd:= ""
	Local nCaixas:= ""
	Local cCli := ""
	Local cLoja := ""
	Local cTab := ""

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	For i := 1 To Len(__aProcParms)  
		If Alltrim(__aProcParms[i, 1]) == 'produto'
			cProd:= alltrim(__aProcParms[i, 2])
		EndIf   
		If Alltrim(__aProcParms[i, 1]) == 'tabela'
			cTab:= alltrim(__aProcParms[i, 2])
		EndIf    

	Next i

	If !Empty(cProd) .and. len(cProd) = 6  

		dbselectArea("DA1")
		DA1->(dbSetOrder(1))
		if DA1->(dbseek(xfilial('DA1')+strzero(val(cTab),3)+cProd)) .and. DA1->DA1_VISUAL = 'S'
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			if SB1->(dbseek(xFilial("SB1")+cProd))
				//cRet:= padr(substr(SB1->B1_DESCRED,1,20),30,"")+transform(DA1->DA1_PRCVEN, "@e 999,999,999.99")
				cRet:= padr(substr(SB1->B1_DESC,1,20),30,"")+transform(DA1->DA1_PRCVEN, "@e 999,999,999.99")
			else
				cRet := '' //'ERRO3'
			EndIf
		else
			cRet := '' // xfilial('DA1')+cProd+strzero(val(cTab),3)

		endif

	EndIf


	RESET ENVIRONMENT

Return cRet
