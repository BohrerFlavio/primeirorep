#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI192  ºAutor  ³ Adonai Gabriel       º Data ³  04/11/23  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍLÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para alterar Centro de Custo e Conta Contábil de    º±±
±±º          ³ um documento de entrada.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigactb - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI192()

	Private lInverte := .f.
    Private cCondicao := ""
	Private cMark    := GetMark()
	Private oMark

	Private aRotina := {{ "Pesquisar"       ,"AxPesqui"     , 0, 1,  , .F. } ,;	// "Pesquisar"
						{ "Visualizar"      ,"AxVisual"     , 0, 2,  , .F. } ,;	// "Visualizar"
                        { "Alterar C.C."    ,"U_DTI192CC()" , 0, 4,  , .F. }} 	// "Alterar Centro de Custo"

	cString := "SD1"
	cCadastro := 'Documentos de entrada'

    cPerg := "DTI192"

	if !pergunte(cPerg,.t.)
		return
	endif

    if !empty(mv_par01)
        cCondicao := "D1_DTDIGIT = '" + dtos(mv_par01) + "'"
    endif

    if !empty(mv_par02) .and. !empty(mv_par01)
        cCondicao += " AND D1_DOC = '" + alltrim(mv_par02) + "'"
    elseif !empty(mv_par02) .and. empty(mv_par01)
        cCondicao := "D1_DOC = '" + alltrim(mv_par02) + "'"
    endif

	dbSelectArea("SD1")
	dbSetOrder(1)
	mBrowse(6,1,22,75,cString,,,,,,,,,,,,,,cCondicao)

Return

User Function DTI192CC()

    Private campoCCust  := Space(9)
    Private campoCCont  := Space(20)
    Private cCCust      := SD1->D1_CC
    Private cCCont      := SD1->D1_CONTA

    DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "ALTERAÇÃO DE CENTRO DE CUSTO"

	@ 01,01 SAY "Centro de Custo:" of telaimp
	@ 02,01 SAY "Conta Contábil:" of telaimp
	@ 01,10 MSGET campoCCust VAR cCCust SIZE 30,10 F3 'CTT' OF telaimp VALID ValidCC(1)
	@ 02,10 MSGET campoCCont VAR cCCont SIZE 50,10 F3 'CT1' OF telaimp VALID ValidCC(2)

	@ 200,25 BUTTON btn1 PROMPT "Salvar" SIZE 50,15 OF telaimp pixel action Salva()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp pixel action telaimp:end()

	ACTIVATE MSDIALOG telaimp CENTERED

Return


Static Function Salva()

    reclock('SD1',.f.)
    SD1->D1_CC := cCCust
    SD1->D1_CONTA := cCCont
    msunlock()

    FWAlertSuccess('Centro de Custo e Conta Contábil alterados com sucesso!','SUCESSO!')

    // Rotina de gravação de log
    //u_dtilog(cFilAnt, "DTI192", "Centro de Custo e Conta Contábil do Doc -> " + SD1->D1_DOC + " | Data -> " + dtoc(SD1->D1_EMISSAO), "A")

Return


Static Function ValidCC(_nOpc)

    Local lRet := .T.

    if _nOpc = 1
        if !empty(cCCust)
            CTT->(DbSetOrder(1))
            if !CTT->(MsSeek(FWxfilial('CTT')+alltrim(cCCust)))
                FWAlertError('Centro de Custo não encontrado!','ERRO!')
                Return .F.
            endif
        endif
    else
        if !empty(cCCont)
            CT1->(DbSetOrder(1))
            if !CT1->(MsSeek(FWxfilial('CT1')+alltrim(cCCont)))
                FWAlertError('Conta Contábil não encontrado!','ERRO!')
                Return .F.
            endif
        endif
    endif

Return lRet
