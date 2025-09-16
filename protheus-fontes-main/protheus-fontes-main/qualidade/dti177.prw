#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI177            º Autor ³ Lucas Bolzan º Data ³ 18/06/23  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de valores de tabela nutricional                  º±±
±±º          ³ para etiquetas internas                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Costela/Desossa/Porcionados                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION DTI177()
    tsTop      := 0
    tsLeft     := 0
    tsBottom   := 500
    tsRight    := 500
    tsCaption  := 'Impressão de etiquetas identificadoras de produtos.'
    tsClrText  := CLR_BLACK
    tsClrBack  := CLR_WHITE
    tsPixel    := .T.

    PRIVATE _cAlias := 'ZBH'
    PRIVATE cCadastro := "Informações para tabela nutricional"
	PRIVATE aRotina := { {"Pesquisar"   ,"AxPesqui"       ,0,1} ,;  
	{"&Visualizar"  ,"AxVisual"        ,0,2},;
	{"Incluir"		,"AxInclui"		   ,0,3},;  
	{"Alterar"    	,"AxAltera"  	   ,0,4},;  
	{"Excluir"    	,"AxDeleta"  	   ,0,5},;
    {"Visualizar informações"  	,"u_Visualiza"     ,0,5}}
    
	dbSelectArea(_cAlias)
	ZBH->(dbsetorder(1))

	mBrowse(6,1,22,75,_cAlias,,,,,2,,,,,) 

	DbCloseArea(_cAlias)
RETURN

USER FUNCTION Visualiza()
    _cLinhaReg := ZBH->ZBH_ID

    _cPorcEmb    := GetAdvFval( 'ZBH' , 'ZBH_POREMB' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cPorcPes    := GetAdvFval( 'ZBH' , 'ZBH_PORCPE' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cIngred     := GetAdvFval( 'ZBH' , 'ZBH_TXTING' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cRotulag    := GetAdvFval( 'ZBH' , 'ZBH_TXTROT' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cValEner100 := GetAdvFval( 'ZBH' , 'ZBH_VEN100' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cValEner80  := GetAdvFval( 'ZBH' , 'ZBH_VEN80' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cValEnerVD  := GetAdvFval( 'ZBH' , 'ZBH_VENVD' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cValCarb100 := GetAdvFval( 'ZBH' , 'ZBH_CAR100' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cValCarb800 := GetAdvFval( 'ZBH' , 'ZBH_CAR80' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cValCarbVD  := GetAdvFval( 'ZBH' , 'ZBH_CARVD' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cAcuTot100  := GetAdvFval( 'ZBH' , 'ZBH_ATO100' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cAcuTot80   := GetAdvFval( 'ZBH' , 'ZBH_ATO80' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cAcuTotVD   := GetAdvFval( 'ZBH' , 'ZBH_ATOVD' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cAcuAdd100  := GetAdvFval( 'ZBH' , 'ZBH_AAD100' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cAcuAdd80   := GetAdvFval( 'ZBH' , 'ZBH_ADD80' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cAcuAddVD   := GetAdvFval( 'ZBH' , 'ZBH_ADDVD' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cProtei100  := GetAdvFval( 'ZBH' , 'ZBH_PRO100' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cProtei80   := GetAdvFval( 'ZBH' , 'ZBH_PRO80' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cProteiVD   := GetAdvFval( 'ZBH' , 'ZBH_PROVD' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cGordTot100 := GetAdvFval( 'ZBH' , 'ZBH_GTO100' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cGordTot80  := GetAdvFval( 'ZBH' , 'ZBH_GTO80' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cGordTotVD  := GetAdvFval( 'ZBH' , 'ZBH_GTOVD' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cGordSat100 := GetAdvFval( 'ZBH' , 'ZBH_GSA100' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cGordSat80  := GetAdvFval( 'ZBH' , 'ZBH_GSA80' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cGordSatVD  := GetAdvFval( 'ZBH' , 'ZBH_GSAVD' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cGordTr100  := GetAdvFval( 'ZBH' , 'ZBH_GTR100' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cGordTr80   := GetAdvFval( 'ZBH' , 'ZBH_GTR80' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cGordTrVD   := GetAdvFval( 'ZBH' , 'ZBH_GTRVD' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cFibAlim100 := GetAdvFval( 'ZBH' , 'ZBH_FAL100' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cFibAlim80  := GetAdvFval( 'ZBH' , 'ZBH_FAL80' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cFibAlimVD  := GetAdvFval( 'ZBH' , 'ZBH_FALVD' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cSodio100   := GetAdvFval( 'ZBH' , 'ZBH_SOD100' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cSodio80    := GetAdvFval( 'ZBH' , 'ZBH_SOD80' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)
    _cSodioVD    := GetAdvFval( 'ZBH' , 'ZBH_SODVD' , _cLinhaReg ,1, "Sem retorno de informações" ,.t.)

    oDialog := TDialog():New(tsTop, tsLeft, tsBottom, tsRight, tsCaption, , , , , tsClrText, tsClrBack, , , tsPixel)
        oFont:= TFont():New('Arial',, -12, .T.)
        
        oSay1  := TSay():New(010, 085, {|| 'INFORMAÇÃO NUTRICIONAL' }                                 , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay2  := TSay():New(025, 015, {|| 'Porções por embalagem:' }                                 , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay3  := TSay():New(040, 015, {|| 'Porção:' }                                                , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay4  := TSay():New(055, 120, {|| '100g' }                                                   , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay5  := TSay():New(055, 170, {|| '80g' }                                                    , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay6  := TSay():New(055, 220, {|| '%VD*' }                                                   , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay7  := TSay():New(070, 015, {|| 'Valor Energético (kcal)' }                                , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay8  := TSay():New(085, 015, {|| 'Carboidratos (g):' }                                      , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay9  := TSay():New(100, 015, {|| 'Acúcares totais (g)' }                                    , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay10 := TSay():New(115, 015, {|| 'Açucares adicionados (g):' }                              , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay11 := TSay():New(130, 015, {|| 'Proteínas (g):' }                                         , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay12 := TSay():New(145, 015, {|| 'Gorduras Totais (g):' }                                   , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay13 := TSay():New(160, 015, {|| 'Gordura Saturada (g):' }                                  , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay14 := TSay():New(175, 015, {|| 'Gordura trans (g):' }                                     , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay15 := TSay():New(190, 015, {|| 'Fibras Alimentares (g):' }                                , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay16 := TSay():New(205, 015, {|| 'Sódio (mg):' }                                            , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        //oSay17 := TSay():New(220, 015, {|| 'Ingredientes:' }                                          , oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)

        oSay20 := TSay():New(025, 090, {|| _cPorcEmb }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay21 := TSay():New(040, 090, {|| _cPorcPes }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay22 := TSay():New(070, 115, {|| _cValEner100 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay23 := TSay():New(070, 165, {|| _cValEner80 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay24 := TSay():New(070, 215, {|| _cValEnerVD }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay25 := TSay():New(085, 115, {|| _cValCarb100 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay26 := TSay():New(085, 165, {|| _cValCarb80 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay27 := TSay():New(085, 215, {|| _cValCarbVD }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay28 := TSay():New(100, 115, {|| _cAcuTot100 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay29 := TSay():New(100, 165, {|| _cAcuTot80 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay30 := TSay():New(100, 215, {|| _cAcuTotVD }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay31 := TSay():New(115, 115, {|| _cAcuAdd100 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay32 := TSay():New(115, 165, {|| _cAcuAdd80 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay33 := TSay():New(115, 215, {|| _cAcuAddVD }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay34 := TSay():New(130, 115, {|| _cProtei100 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay35 := TSay():New(130, 165, {|| _cProtei80 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay36 := TSay():New(130, 215, {|| _cProteiVD }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay37 := TSay():New(145, 115, {|| _cGordTot100 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay38 := TSay():New(145, 165, {|| _cGordTot80 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay39 := TSay():New(145, 215, {|| _cGordTotVD }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay40 := TSay():New(160, 115, {|| _cGordSat100 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay41 := TSay():New(160, 165, {|| _cGordSat80 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay42 := TSay():New(160, 215, {|| _cGordSatVD }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay43 := TSay():New(175, 115, {|| _cGordTr100 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay44 := TSay():New(175, 165, {|| _cGordTr80 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay45 := TSay():New(175, 215, {|| _cGordTrVD }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay46 := TSay():New(190, 115, {|| _cFibAlim100 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay47 := TSay():New(190, 165, {|| _cFibAlim80 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay48 := TSay():New(190, 215, {|| _cFibAlimVD }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay48 := TSay():New(205, 115, {|| _cSodio100 }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay50 := TSay():New(205, 165, {|| _cSodio80  }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
        oSay51 := TSay():New(205, 215, {|| _cSodioVD  }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)        
        oSay52 := TSay():New(220, 015, {|| _cIngred  }, oDialog, , oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 20)
    oDialog:Activate(,,,.T.,,,)
RETURN
