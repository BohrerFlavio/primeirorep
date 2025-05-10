#include "protheus.ch"
#include "totvs.ch"
#include "topconn.ch"

 
User Function FC010BTN()
    //https://tdn.totvs.com/pages/releaseview.action?pageId=653134391

    Private aParamixb:= PARAMIXB[1]    

    If Paramixb[1] == 1// Deve retornar o nome a ser exibido no botão
        Return "Últ. 10 Prod. Comprados"    
    ElseIf Paramixb[1] == 3// Deve retornar a ação do botão
        U_FC010LNF()        
    endif      
Return

User Function FC010LNF()
    Local aArea := GetArea()
    //Objetos da Janela
    Private oDlgPvt
    Private oMsGetQRY
    Private aHeadQRY := {}
    Private aColsQRY := {}
    Private oBtnFech
    //Tamanho da Janela
    Private    nJanLarg    := 700
    Private    nJanAltu    := 300//500
    //Fontes
    Private    cFontUti   := "Tahoma"
    Private    oFontAno   := TFont():New(cFontUti,,-38)
    Private    oFontSub   := TFont():New(cFontUti,,-20)
    Private    oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
    Private    oFontBtn   := TFont():New(cFontUti,,-14)
     
    //Criando o cabeçalho da Grid
    //              Título               Campo           Máscara   Tamanho                   Decimal                   Valid     Usado  Tipo    F3     Combo
    aAdd(aHeadQRY, {"Documento",      "QRY->DOCUMENTO",  "@E 999999999",       TamSX3("D2_DOC")[01],       0,          "",       ".T.", "C",    "",    ""} )
    aAdd(aHeadQRY, {"Cód. Produto",   "QRY->CODPROD",    "@E 999999"   ,       TamSX3("D2_COD")[01],       0,          "",       ".T.", "C",    "",    ""} )
    aAdd(aHeadQRY, {"Descrição",      "QRY->DESCPROD",   "@!"          ,       TamSX3("D2_DESCRI")[01],    0,          "",       ".T.", "C",    "",    ""} )
    aAdd(aHeadQRY, {"Data Faturam",   "QRY->DTAEMISSAO", "  "          ,       TamSX3("D2_EMISSAO")[01],   0,          "",       ".T.", "D",    "",    ""} )
    aAdd(aHeadQRY, {"Valor",          "QRY->VALOR",      "@E 999,999.99",      TamSX3("D2_PRCVEN")[01],    0,          "",       ".T.", "N",    "",    ""} )
    aAdd(aHeadQRY, {"Peso (Kg)" ,      "QRY->PESO",      "@E 999,999.99",      TamSX3("D2_PRCVEN")[01],    0,          "",       ".T.", "N",    "",    ""} )
 
    Processa({|| fCarAcols()}, "Processando")
 
    //Criação da tela com os dados que serão informados
    DEFINE MSDIALOG oDlgPvt TITLE "Últimos 10 produtos comprados" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL        
        //Botões
        @ 006, (nJanLarg/2-001)-(0067*01) BUTTON oBtnFech  PROMPT "Fechar"        SIZE 065, 018 OF oDlgPvt ACTION (oDlgPvt:End())                               FONT oFontBtn PIXEL
         
        //Grid dos grupos
        oMsGetQRY := MsNewGetDados():New(    029,;                //nTop      - Linha Inicial
                                            003,;                //nLeft     - Coluna Inicial
                                            (nJanAltu/2)-3,;     //nBottom   - Linha Final
                                            (nJanLarg/2)-3,;     //nRight    - Coluna Final
                                            ,;                   //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
                                            "AllwaysTrue()",;    //cLinhaOk  - Validação da linha
                                            ,;                   //cTudoOk   - Validação de todas as linhas
                                            "",;                 //cIniCpos  - Função para inicialização de campos
                                            {},;                 //aAlter    - Colunas que podem ser alteradas
                                            ,;                   //nFreeze   - Número da coluna que será congelada
                                            9999,;               //nMax      - Máximo de Linhas
                                            ,;                   //cFieldOK  - Validação da coluna
                                            ,;                   //cSuperDel - Validação ao apertar '+'
                                            ,;                   //cDelOk    - Validação na exclusão da linha
                                            oDlgPvt,;            //oWnd      - Janela que é a dona da grid
                                            aHeadQRY,;           //aHeader   - Cabeçalho da Grid
                                            aColsQRY)            //aCols     - Dados da Grid
                                             
        //Desativa as manipulações
        oMsGetQRY:lActive := .F.
         
    ACTIVATE MSDIALOG oDlgPvt CENTERED
     
    RestArea(aArea)
Return
 
Static Function fCarAcols()
    Local aArea  := GetArea()    
    Local nAtual := 0
    Local nTotal := 0
     
    //Seleciona dados do documento de entrada
    _cQry := " SELECT TOP 10 D2_DOC AS DOCUMENTO, D2_COD AS CODPROD, D2_DESCRI AS DESCPROD, D2_EMISSAO AS DTAEMISSAO, D2_PRCVEN AS VALOR, F2_PBRUTO AS PESO "
	_cQry += " FROM " + retSqlTab('SD2')
    _cQry += " INNER JOIN "  + retSqlTab('SF2') + " ON F2_DOC = D2_DOC"
	_cQry += " WHERE " + retSqlFil('SD2')    
    _cQry += " AND " + retSqlDel('SD2')
    _cQry += " AND " + retSqlDel('SF2')
	_cQry += " AND D2_CLIENTE = '" + SA1->A1_COD + "'"
	_cQry += " AND D2_LOJA = '" + SA1->A1_LOJA + "'"
	_cQry += " ORDER BY D2_EMISSAO DESC "
    TCQUERY _cQry NEW ALIAS "QRY"
     
    //Setando o tamanho da régua
    Count To nTotal
    ProcRegua(nTotal)
     
    //Enquanto houver dados
    QRY->(DbGoTop())
    While ! QRY->(EoF())
     
        //Atualizar régua de processamento
        nAtual++
        IncProc("Adicionando " + Alltrim(QRY->DOCUMENTO) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
         
        //Adiciona o item no aCols
        aAdd(aColsQRY, { ;
            QRY->DOCUMENTO,;
            QRY->CODPROD,;
            QRY->DESCPROD,;
            SToD(QRY->DTAEMISSAO),;
            QRY->VALOR,;
            QRY->PESO,;
            .F.;
        })
         
        QRY->(DbSkip())
    EndDo
    QRY->(DbCloseArea())
     
    RestArea(aArea)
Return
