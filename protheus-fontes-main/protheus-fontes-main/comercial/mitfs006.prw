//Bibliotecas
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "colors.ch" 
#INCLUDE "totvs.ch"


/*/{Protheus.doc} mitfs006
    (long_description)
    @type User Function
    @author Mauricio Roehrs
    @since 11/04/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function mitfs006()

    local _aRet     := {}
    Local oGrpLog
	Local oBtnConf
	Private _lRet := .F.
	Private oDlgPvt
	Private oSayUsr
	Private oGetUsr, cGetUsr := Space(25)
	Private oSayPsw
	Private oGetPsw, cGetPsw := Space(20)
	Private oGetErr, cGetErr := ""
	//Dimensões da janela
	Private nJanLarg := 200
	Private nJanAltu := 200

	//Criando a janela
	DEFINE MSDIALOG oDlgPvt TITLE "Login" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		//Grupo de Login
		@ 003, 001 	GROUP oGrpLog TO (nJanAltu/2)-1, (nJanLarg/2)-3 		PROMPT "Login: " 	OF oDlgPvt COLOR 0, 16777215 PIXEL
			//Label e Get de Usuário
			@ 013, 006   SAY   oSayUsr PROMPT "Usuário:"        SIZE 030, 007 OF oDlgPvt                    PIXEL
			@ 020, 006   MSGET oGetUsr VAR    cGetUsr           SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL

			//Label e Get da Senha
			@ 033, 006   SAY   oSayPsw PROMPT "Senha:"          SIZE 030, 007 OF oDlgPvt                    PIXEL
			@ 040, 006   MSGET oGetPsw VAR    cGetPsw           SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL PASSWORD

			//Get de Log, pois se for Say, não da para definir a cor
			@ 060, 006   MSGET oGetErr VAR    cGetErr        SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 NO BORDER PIXEL
			oGetErr:lActive := .F.
			oGetErr:setCSS("QLineEdit{color:#FF0000; background-color:#FEFEFE;}")

			//Botões
			@ (nJanAltu/2)-18, 006 BUTTON oBtnConf PROMPT "Confirmar"             SIZE (nJanLarg/2)-12, 015 OF oDlgPvt ACTION (fVldUsr()) PIXEL
			oBtnConf:SetCss("QPushButton:pressed { background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #dadbde, stop: 1 #f6f7fa); }")
	ACTIVATE MSDIALOG oDlgPvt CENTERED

    If !_lRet
        FWAlertInfo('Encerramento não concluído. Operação cancelada ou usuário inválido!','INFO')
    endif

    _aRet := {_lRet , cGetUsr}

Return _aRet


Static Function fVldUsr()

    Local _cLogUSR  := alltrim(getmv("SI_AUTHXPD")) //parametro com os logins dos usuários que tem permissão para fazer o encerramento
    Local _cSenUSR  := alltrim(getmv("SI_AUTHSPD")) //parametro com as senhas dos usuários que tem permissão para fazer o encerramento

    aLogin := strToKArr(_cLogUSR, ',')
    aSenha := strToKArr(_cSenUSR, ',')

    nPos := aScan(aLogin, {|x| x == alltrim(cGetUsr)})
    if nPos > 0
        if alltrim(cGetPsw) = aSenha[nPos]
            _lRet := .T.
        else
            cGetErr := "Usuário e/ou senha inválidos!"
            oGetErr:Refresh()
            Return
        endif
    else
        cGetErr := "Usuário e/ou senha inválidos!"
        oGetErr:Refresh()
        Return
    endif

	//Se o retorno for válido, fecha a janela
	If _lRet
		oDlgPvt:End()
	EndIf
Return

/*/{Protheus.doc} User Function mitpck001
    (função para verificar se existe picking para o pedido e a caixa ainda encontra-se em estoque)
    @type  Function
    @author Mauricio Roehrs
    @since 27/04/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function mitpck01(_cPrecar)

    local _cQuery   := ""
    local nCount    := 0 
    local _lRet     := .f.

    _cQuery := " SELECT Z8_CONTROL"
    _cQuery += " FROM " + retSqlTab('SZ8') + "(NOLOCK)"
    _cQuery += " INNER JOIN " + retSqlTab('ZZ4') +" (NOLOCK) ON ZZ4_PRECAR = '"+_cPrecar + "' AND " + retSqlDel('ZZ4')
    _cQuery += " INNER JOIN " + retSqlTab('ZZ5') + " (NOLOCK) ON  ZZ4_NUM = ZZ5_NUM AND ZZ5_COD = Z8_COD AND " +retSqlDel('ZZ5')
    _cQuery += " WHERE "+ retSqlFil('SZ8')
    _cQuery += " AND Z8_FIL = '00' AND Z8_DATAS = ''
    _cQuery += " AND Z8_CARPICK = '"+_cPrecar+"'"
    _cQuery += " AND " +retSqlDel('SZ8')

    cAlias := GetNextAlias()
	TCQuery _cQuery new alias &cAlias

    (cAlias)->(dbGoTop())

    //verifica se houve retorno na query
    Count to nCount

    If nCount > 0
        _lRet := .t.
    endif

    (cAlias)->(dbCloseArea())

Return _lRet
