#Include 'PROTHEUS.ch'
 
User Function PRODMNT1() 
    //Altera solicitação de compras
    Local aProdutos := PARAMIXB[1]
    Local nX

    //MsgInfo("Chamado o PE PRODMNT1","")
    
    If !Empty(aProdutos) .And. aProdutos[1] == "TERCEIROS"
        For nX := 1 To Len(aProdutos)
            aProdutos[nX] := M->TL_XPROFO
        Next nX
    EndIf
Return aProdutos
