#INCLUDE 'Protheus.ch'
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)


/* {Protheus.doc} MA261CPO
    (long_description)
    Inclui 2 campos para digitação na tela 
    
    @type  Function
    @author Flávio B. Flôres
    @since 17/01/2025
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)

    https://tdn.totvs.com/pages/releaseview.action?pageId=6087616

    */
user Function MA261CPO()
Local aTam := {}
Local aTam2 := {}


aTam := TamSx3("D3_LOTEFOR")
Aadd(aHeader, {'Lote Fornec', 'D3_LOTEFOR', PesqPict('SD3', 'D3_LOTEFOR', aTam[1]), aTam[1], aTam[2], '', USADO, 'C', 'SD3', ''})
  
aTam2 := TamSx3("D3_DATAV")
Aadd(aHeader, {'Valid.Lotes', 'D3_DATAV', PesqPict('SD3', 'D3_DATAV', aTam2[1]), aTam2[1], aTam2[2], '', USADO, 'D', 'SD3', ''})


Return Nil
