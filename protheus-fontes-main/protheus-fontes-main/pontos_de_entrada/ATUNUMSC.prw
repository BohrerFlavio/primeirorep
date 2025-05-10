#include 'protheus.ch'      
 
User Function ATUNUMSC()    
    Local cCodPro := ParamIXB[1]
    Local cAlmoxa := ParamIXB[2]

    MsgInfo("Chamado o PE ATUNUMSC","")
 
    If STL->TL_TIPOREG == 'T'
 
        If Empty( STL->TL_NUMSC ) .And. Empty( STL->TL_ITEMSC ) .And. AllTrim( cCodPro ) == Alltrim( STL->TL_XPROFO ) .And.;
            AllTrim( cAlmoxa ) == Alltrim( STL->TL_XLOCPR ) .And. STL->TL_SEQRELA == PadR( '0', TamSX3( 'TL_SEQRELA' )[1] )
 
            RecLock( 'STL', .F. )
                STL->TL_NUMSC  := SC1->C1_NUM
                STL->TL_ITEMSC := SC1->C1_ITEM
            MsUnLock()
        EndIf 
    EndIf     
Return
