#Include "TOTVS.ch"
#Include "TOPCONN.ch"
User Function MTA105OK

    Local _area := getarea()
    Local cProduto := aScan(aHeader,{|x| Alltrim(x[2])="CP_CC"})
    Local lRet := .T.
    Local Nx   := 1
    
    //Verifica se foi informado um centro de custo na SA.
    For Nx:= 1 To Len(aCols)        
        if Empty(aCols[Nx,cProduto])
            MsgAlert("Um centro de custo não foi informado","")
            return .f.
        endif
    Next Nx
    //Grava hora da SA
    RecLock('SCP',.f.)
	SCP->CP_HEMISSA := Time()
	MsUnlock() 
    
    RestArea(_area)
Return lRet
