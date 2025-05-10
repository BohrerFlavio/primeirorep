//Bibliotecas
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "colors.ch" 
#INCLUDE "totvs.ch"

/*------------------------------------------*\
| Estrutura do array com o cabeçalho da Grid |
|--------------------------------------------|
| aHeader[01] - X3_TITULO  | Título          |
| aHeader[02] - X3_CAMPO   | Campo           |
| aHeader[03] - X3_PICTURE | Picture         |
| aHeader[04] - X3_TAMANHO | Tamanho         |
| aHeader[05] - X3_DECIMAL | Decimal         |
| aHeader[06] - X3_VALID   | Validação       |
| aHeader[07] - X3_USADO   | Usado           |
| aHeader[08] - X3_TIPO    | Tipo            |
| aHeader[09] - X3_F3      | F3              |
| aHeader[10] - X3_CONTEXT | Contexto (R,V)  |
| aHeader[11] - X3_CBOX    | Combobox        |
| aHeader[12] - X3_RELACAO | Inicial. Padrao |
| aHeader[13] - X3_WHEN    | Habilita edicao |
| aHeader[14] - X3_VISUAL  | Alteravel (A,V) |
| aHeader[15] - X3_VLDUSER | Valid de User   |
| aHeader[16] - X3_PICTVAR | Picture         |
| aHeader[17] - X3_OBRIGAT | Obrigatorio     |
\*------------------------------------------*/

/*/{Protheus.doc} User Function mitfs005
    (Função para digitação das datas de produção do pré-pedido de forma manual)
    @type  Function
    @author Mauricio Roehrs
    @since 05/04/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function mitfs005()
    Local aArea := GetArea()
    //Objetos da Janela
    Private oDlgPvt
    Private oMsGetSBM
    Private aHeadSBM := {}
    Private _aHeader := {}
    Private aColsSBM := {}
    Private _aCols   := {}
    Private oBtnSalv
    Private oBtnFech
    Private oBtnLege
    //Tamanho da Janela
    Private nJanLarg    := 1000
    Private nJanAltu    := 800
    //Fontes
    Private cFontUti   := "Tahoma"
    Private oFontAno   := TFont():New(cFontUti,,-38)
    Private oFontSub   := TFont():New(cFontUti,,-20)
    Private oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
    Private oFontBtn   := TFont():New(cFontUti,,-14)
     
    //Criando o cabeçalho da Grid
    //              Título               Campo        Máscara                        Tamanho                   Decimal                   Valid               Usado  Tipo F3     Combo
    aAdd(_aHeader, {"Pré-Pedido",        "ZZ4_NUM",     "", TamSX3("ZZ4_NUM")[01],     0,   ".T.",              ".T.", "C", "",    "","","",".f."} )
    aAdd(_aHeader, {"Cliente",           "ZZ4_CODCLI",  "", TamSX3("ZZ4_CODCLI")[01],  0,   ".T.",              ".T.", "C", "",    "","","",".f."} )
    aAdd(_aHeader, {"Loja",              "ZZ4_LOJA",    "", TamSX3("ZZ4_LOJA")[01],    0,   ".T.",              ".T.", "C", "",    "","","",".f."} )
    aAdd(_aHeader, {"Nome",              "ZZ4_NOME",    "", TamSX3("ZZ4_NOME")[01],    0,   ".T.",              ".T.", "C", "",    "","","",".f."} )
    aAdd(_aHeader, {"Produto",           "ZZ5_COD",     "", TamSX3("ZZ5_COD")[01],     0,   ".T.",              ".T.", "C", "",    "","","",".f."} )
    aAdd(_aHeader, {"Dt Prod. Ini",      "ZZ5_DTPINI",  "", TamSX3("ZZ5_DTPINI")[01],  0,                       ".T.", ".T.", "D", "",""} )
    aAdd(_aHeader, {"Dt Prod. Fim",      "ZZ5_DTPFIM",  "", TamSX3("ZZ5_DTPFIM")[01],  0,                       ".T.", ".T.", "D", "",""} )
    aAdd(_aHeader, {"RECNO",             "RECNO",       "", 18,                        0,   ".T.",              ".T.",  "N","",    "","","",".f."} )

    Processa({|| fCarAcols()}, "Processando")
 
    //Criação da tela com os dados que serão informados
    DEFINE MSDIALOG oDlgPvt TITLE "Grupos de Produto" FROM 000, 000  TO nJanAltu, nJanLarg PIXEL

        //Labels gerais
        @ 004, 050 SAY "Listagem de Pré-Pedidos com" SIZE 200, 030 FONT oFontSub  OF oDlgPvt COLORS RGB(031,073,125) PIXEL
        @ 014, 050 SAY "data de produção em branco"  SIZE 200, 030 FONT oFontSub OF  oDlgPvt COLORS RGB(031,073,125) PIXEL
         
        //Botões
        @ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Fechar"        SIZE 050, 018 OF oDlgPvt ACTION (oDlgPvt:End())                               FONT oFontBtn PIXEL
        @ 006, (nJanLarg/2-001)-(0052*03) BUTTON oBtnSalv  PROMPT "Salvar"        SIZE 050, 018 OF oDlgPvt ACTION (fSalvar())                                   FONT oFontBtn PIXEL
         
        //Grid dos grupos
        oMsGetDts := MsNewGetDados():New(    029,;                //nTop      - Linha Inicial
                                            003,;                //nLeft     - Coluna Inicial
                                            (nJanAltu/2)-3,;     //nBottom   - Linha Final
                                            (nJanLarg/2)-3,;     //nRight    - Coluna Final
                                            GD_UPDATE,;          //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
                                            "AllwaysTrue()",;    //cLinhaOk  - Validação da linha
                                            ,;                   //cTudoOk   - Validação de todas as linhas
                                            "",;                 //cIniCpos  - Função para inicialização de campos
                                            ,;                   //aAlter    - Colunas que podem ser alteradas
                                            ,;                   //nFreeze   - Número da coluna que será congelada
                                            9999,;               //nMax      - Máximo de Linhas
                                            ,;                   //cFieldOK  - Validação da coluna
                                            ,;                   //cSuperDel - Validação ao apertar '+'
                                            ,;                   //cDelOk    - Validação na exclusão da linha
                                            oDlgPvt,;            //oWnd      - Janela que é a dona da grid
                                            _aHeader,;           //aHeader   - Cabeçalho da Grid
                                            _aCols)              //aCols     - Dados da Grid
         
    ACTIVATE MSDIALOG oDlgPvt CENTERED
     
    RestArea(aArea)
Return
 
/*------------------------------------------------*
 | Func.: fCarAcols                               |
 | Desc.: Função que carrega o aCols              |
 *------------------------------------------------*/
 
Static Function fCarAcols()
    Local aArea  := GetArea()
    Local cQry   := ""
    Local nAtual := 0
    Local nTotal := 0

    cQry := " SELECT ZZ4_NUM, ZZ4_CODCLI, ZZ4_LOJA, ZZ4_NOME, ZZ5_COD, ZZ5_DTPINI, ZZ5_DTPFIM,ZZ5.R_E_C_N_O_ AS ZZ5RECNO "
    cQry += " FROM " + retSqlTab('ZZ4') + " (NOLOCK)"
    cQry += " INNER JOIN " + retSqlTab('ZZ5')+ " (NOLOCK) ON ZZ5_NUM = ZZ4_NUM AND (ZZ5_DTPINI = '' OR ZZ5_DTPFIM = '') AND ZZ5_FILIAL = "+xFilial("ZZ4")+" AND " + retSqlDel("ZZ5")
    cQry += " WHERE ZZ4_PRECAR = '"+ZZ3->ZZ3_NUM +"'"
    cQry += " AND " + retSqlFil("ZZ4")
    cQry += " AND ZZ4_STATUS IN ('B','A','L')
    cQry += " AND " +retSqlDel('ZZ4')

    cAlias := GetNextAlias()
    TCQuery cQry new alias &cAlias
     
    //Setando o tamanho da régua
    Count To nTotal
    ProcRegua(nTotal)
     
    //Enquanto houver dados
    (cAlias)->(DbGoTop())
    While (cAlias)->(!eof())
     
        //Atualizar régua de processamento
        nAtual++
        IncProc("Adicionando " + Alltrim((cAlias)->ZZ4_NOME) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
        
        aAdd(_aCols, { ;
            (cAlias)->ZZ4_NUM,;
            (cAlias)->ZZ4_CODCLI,;
            (cAlias)->ZZ4_LOJA,;
            (cAlias)->ZZ4_NOME,;
            (cAlias)->ZZ5_COD,;
            stod((cAlias)->ZZ5_DTPINI),;
            stod((cAlias)->ZZ5_DTPFIM),;
            (cAlias)->ZZ5RECNO,;
            .F.;
            })
         
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())
     
    RestArea(aArea)
Return
 
/*--------------------------------------------------------*
 | Func.: fSalvar                                         |
 | Desc.: Função que percorre as linhas e faz a gravação  |
 *--------------------------------------------------------*/
Static Function fSalvar()
    Local aColsAux := oMsGetDts:aCols
    Local nPosRec  := aScan(_aHeader, {|x| Alltrim(x[2]) == "RECNO"})
    Local nPosDtIn := aScan(_aHeader, {|x| Alltrim(x[2]) == "ZZ5_DTPINI"})
    Local nPosDtFi := aScan(_aHeader, {|x| Alltrim(x[2]) == "ZZ5_DTPFIM"})
    Local nLinha   := 0
     
    DbSelectArea('ZZ5')
     
    //Percorrendo todas as linhas
    For nLinha := 1 To Len(aColsAux)
     
        //Posiciona no registro
        If aColsAux[nLinha][nPosRec] != 0
            ZZ5->(DbGoTo(aColsAux[nLinha][nPosRec]))
        EndIf
         
        RecLock('ZZ5', .F.)
            ZZ5_DTPINI   := aColsAux[nLinha][nPosDtIn]
            ZZ5_DTPFIM   := aColsAux[nLinha][nPosDtFi]
        ZZ5->(MsUnlock())
         
    Next
     
    MsgInfo("Manipulações finalizadas!", "Atenção")
    oDlgPvt:End()
Return
