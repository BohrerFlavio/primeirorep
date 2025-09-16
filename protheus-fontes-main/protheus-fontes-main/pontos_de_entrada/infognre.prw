#INCLUDE "protheus.ch" 


User Function INFOGNRE()
	/* Ponto de entrada que permite a inclusão de dados na tabela SF6, 
	no momento da inclusão de uma nota fiscal de saída, configurada para que seja gerada a guia de recolhimento.

	E quando for várias ??
	*/
	Local lTeste := .T.	        

	//RecLock("SF6",.T.)	
	/*
	RecLock("SF6",.F.)		
	SF6->F6_CODPROD := 29
	SF6->F6_CODREC  := '100099'	
	SF6->(MsUnlock())
	*/
Return(lTeste)

/*
User Function INFOGNRE
Local lTeste := .T.	        
RecLock("SF6",.T.)	
SF6_FILIAL :=xFilial("SF6")	
SF6->(MsUnlock())
Return(lTeste)
*/
