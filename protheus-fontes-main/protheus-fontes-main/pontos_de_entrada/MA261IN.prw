#INCLUDE 'Protheus.ch'


/*/{Protheus.doc} MA261IN 
    (long_description)
    Exibe valores que foram salvos no ponto de entrada "MA261TRD3" de campos na tela - para exibir os campos do aCols inseridos por este ponto de entrada nas operações de 

    @type  Function
    @author Flávio B. Flôres
    @since 17/01/2025
    @version version
    @param ...
    @return c
    @example
    (examples)
    @see (links_or_references)
    https://tdn.totvs.com/display/public/PROT/MA261IN+-+Preenche+valores+de+campos+na+tela+de+estorno

    /*/
User Function MA261IN()

Local nLOTEFOR := aScan(aHeader, {|x| AllTrim(Upper(x[2]))== "D3_LOTEFOR"})
Local nDATAV   := aScan(aHeader, {|x| AllTrim(Upper(x[2]))== "D3_DATAV"})
Local aAreaSD3 := SD3->(GetArea())
//Local aRecSD3 := PARAMIXB[1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Customizacoes de usuario      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   
    
    If Funname() == "MATA261"
       
        IF nLOTEFOR > 0
            aCols[Len(aCols),nLOTEFOR] := IIF(INCLUI,CriaVar("D3_LOTEFOR",.F.),SD3->D3_LOTEFOR)            
        EndIf 
        IF nDATAV > 0
            aCols[Len(aCols),nDATAV] := IIF(INCLUI,CriaVar("D3_DATAV",.F.),SD3->D3_DATAV)
         EndIf                                            
    Endif


    RestArea(aAreaSD3)
    
Return nil 
