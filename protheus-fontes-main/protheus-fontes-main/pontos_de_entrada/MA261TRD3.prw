#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MA261TRD3 
@Type			: Função de Usuário
@Sample			: U_MA261TRD3()
@Description	: Grava os dados dos campos D3_LOTEFOR e D3_DATAV no banco na movimentação interna 
                de transferência modelo II - MATA261.
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Flavio B.
@Since			: Jan/2015
@version		: Protheus 12.1.25 e posteriores.
@Comments		: Processa para incluir 2 campos na interface, anterado em 27/01/25
/*/
//--------------------------------------------------------------------------------------
User Function MA261TRD3()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebe os identificadores Recno() gerados na tabela SD3      ³
//³ para que seja feito o posicionamento                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local aRecSD3 := PARAMIXB[1]
	Local nX := 1
    Local _cLotefor
    Local _dDATAV
    Local _nQuant
    Local _cNums    
    Local _cSD3Doc 
    Local cScan  := Ascan(AHEADER,{ |x| x[2] == 'D3_LOTEFOR'})
    Local cScan2 := Ascan(AHEADER,{ |x| x[2] == 'D3_DATAV'})

    For nX := 1 To Len(aRecSD3)

        SD3->(DbGoto(aRecSD3[nX][1])) 
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Customizacoes de usuario      ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
        IF cScan > 0
            RecLock('SD3', .F.)                
                SD3->D3_LOTEFOR := aCols[nX,cScan]
                SD3->D3_DATAV := aCols[nX,cScan2]                                                          
            MsUnlock()
            _cSD3Doc := SD3->D3_DOC                      

        Endif
               
    Next nX
    
    SD3->(DbSetOrder(2)) // ou 18
    SD3->(dbgotop())
    SD3->(MsSeek(FWxfilial('SD3')+_cSD3Doc))
       
    while SD3->D3_DOC == _cSD3Doc
          
        if Sd3->D3_TM == '999'   
            _nQuant := 0          
            _cLotefor := SD3->D3_LOTEFOR 
            _dDATAV   := SD3->D3_DATAV
            _nQuant   := SD3->D3_QUANT
            _cNums    := SD3->D3_NUMSERI
            
        Endif
        
        if Sd3->D3_TM == '499'     
            RecLock('SD3', .F.)     
                       
                    SD3->D3_LOTEFOR := _cLotefor
                    SD3->D3_DATAV   := _dDATAV
                    SD3->D3_QUANT   := _nQuant                                                       
                    SD3->D3_NUMSERI := _cNums
            MsUnlock()            
        Endif
        
        SD3->(DbSkip())
    Enddo
Return nil
