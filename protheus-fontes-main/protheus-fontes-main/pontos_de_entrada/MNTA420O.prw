#include 'protheus.ch'      
 
User Function MNTA420O()
 
    Local aItens := ParamIXB[1]
    Local aCabec := ParamIXB[2]
    Local nLine  := ParamIXB[3]
    Local aRet   := {}
 
    Local nPProd := GDFieldPos( 'TL_XPROFO' , aCabec )
    Local nPAlmo := GDFieldPos( 'TL_XLOCPR' , aCabec )
    Local nPTipo := GDFieldPos( 'TL_TIPOREG', aCabec )
     
    If aItens[nLine,nPTipo] == 'T'
        aAdd( aRet, aItens[nLine,nPProd] )
        aAdd( aRet, aItens[nLine,nPAlmo] )
    EndIf
Return aRet
