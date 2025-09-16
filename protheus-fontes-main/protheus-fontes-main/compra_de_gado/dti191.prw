#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI191  ºAutor  ³ Adonai Gabriel       º Data ³  25/10/23  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍLÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualizar avisos de matança e alterar prenhez por lote    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI191()

	Private lInverte := .f.
	Private cMark    := GetMark()
	Private oMark

	Private aRotina := {{ "Pesquisar" ,"AxPesqui"     , 0, 1,  , .F. } ,;	// "Pesquisar"
						{ "Visualizar","AxVisual"     , 0, 2,  , .F. } ,;	// "Visualizar"
						{ "Detalhes"  ,"U_GJF80()"    , 0, 4,  , .F. } ,; 	// "Detalhes"
                        { "Prenhez"   ,"U_DTI191P()"  , 0, 4,  , .F. } ,; 	// "Altera prenhez por lote"
						{ "Imprimir"  ,"U_GJF75()"    , 0, 4,  , .F. }} 	// "Imprimir"

	cString := "SZG"
	cCadastro := 'Ordens de matança'

	dbSelectArea("SZG")
	dbSetOrder(1)
	mBrowse(6,1,22,75,cString)

Return

User Function DTI191P()

    Private campoLote := Space(6)
    Private campoPren := 0
    Private campoPread := 0
    Private cLote := Space(6)
    Private nPren := 0
    Private nPread := 0

    DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "ALTERAÇÃO DE PRENHEZ POR LOTE"

	@ 01,01 SAY "Lote:" of telaimp
	@ 02,01 SAY "Vacas Prenhas:" of telaimp
	@ 03,01 SAY "Pren. Adiant.:" of telaimp
	@ 01,10 MSGET campoLote VAR cLote SIZE 30,10 OF telaimp VALID (!empty(cLote) .and. ValidLote(1)) PICTURE "@!"
	@ 02,10 MSGET campoPren VAR nPren SIZE 40,10 OF telaimp VALID ValidLote(2) PICTURE "@E 999"
	@ 03,10 MSGET campoPread VAR nPread SIZE 40,10 OF telaimp VALID ValidLote(2) PICTURE "@E 999"

	@ 200,25 BUTTON btn1 PROMPT "Salvar" SIZE 50,15 OF telaimp pixel action Salva()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp pixel action telaimp:end()

	ACTIVATE MSDIALOG telaimp CENTERED

Return


Static Function Salva()

    reclock('SZ4',.f.)
    SZ4->Z4_NPREN  := nPren
    SZ4->Z4_NPREAD := nPread
    msunlock()

    FWAlertSuccess('Prenhez do lote alterada com sucesso!','SUCESSO!')

    // Rotina de gravação de log
	u_dtilog(cFilAnt, "U_GJF08", "Alteração prenhez lote -> " + SZ4->Z4_LOTE + " | NUMAM -> " + SZ4->Z4_NUMAM, "A")

    campoLote:setFocus()

Return


Static Function ValidLote(_nOpc)

    Local lRet := .F.

    SZ4->(DbSetOrder(1))

    if _nOpc = 1
        if len(cLote) != 6
            FWAlertError('Número de lote inválido!','ERRO!')
            Return lRet
        endif
        SZ4->(MsSeek(FWxfilial('SZ4')+SZG->ZG_NUMAM))
        while SZ4->(!eof()) .and. SZG->ZG_NUMAM = SZ4->Z4_NUMAM
            if cLote = SZ4->Z4_LOTE
                Return .T.
            endif

            SZ4->(DbSkip())
        end
        FWAlertError('Lote não encontrado!','ERRO!')
    else
        SZ4->(MsSeek(FWxfilial('SZ4')+SZG->ZG_NUMAM+cLote))
        if nPren > SZ4->Z4_QTREAL
            FWAlertError('Numero digitado é maior que a quantidade animais do lote!','ERRO!')
        elseif nPread > SZ4->Z4_QTREAL
            FWAlertError('Numero digitado é maior que a quantidade animais do lote!','ERRO!')
        else
            lRet := .T.
        endif
    endif

Return lRet
