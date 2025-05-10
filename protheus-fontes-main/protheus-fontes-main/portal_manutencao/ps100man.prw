#INCLUDE "apwebex.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS100MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  20/06/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela de login do portal de manutencoes                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS100MAN()
	Local cHtml:= ""
	Local oDlg:= Nil
	Local oGet1:= Nil
	Local oGet2:= Nil
	Local oBtn1:= Nil

	If ValType(HTTPSESSION->cEMP) == "U" .OR. ValType(HTTPSESSION->cFil) == "U" .OR. ValType(HTTPSESSION->cCC) == "U"
		cHtml:= "  $.ajax({"
		cHtml+= "          async: true,"
		cHtml+= "          method: 'POST',"
		cHtml+= "          url: 'u_ps001man.apw',"
		cHtml+= "         }).done(function(data){eval(data);});"
		Return cHtml
	EndIf

	oDlg:= PSWebDialog():New("ps100man_dialog_login", HTTPSESSION->cLogo, 'ps100man_form_login',,,,,.F.)

	oGet1:= PSWebGet():New("ps100man_get_user", "text", "Usuario",,, "Usuario",)
	oDlg:AddControl(oGet1)

	oGet2:= PSWebGet():New("ps100man_get_pass", "password", "Senha",,, "Senha",)
	oDlg:AddControl(oGet2)

	oBtn1:= PSWebButton():New("ps100man_button_entrar", "Entrar")
	oDlg:AddButton(oBtn1)

	cScript:= "$('#ps100man_button_entrar').click(function(){"
	cScript+= "$(this).prop('disabled', true);"
	cScript+= "  $.ajax({"
	cScript+= "          async: true,"
	cScript+= "          method: 'POST',"
	cScript+= "          url: 'u_ps101man.apw',"
	cScript+= "          data: $('#ps100man_form_login').serialize(),"
	cScript+= "         }).done(function(data){$('#ps100man_button_entrar').prop('disabled', false);eval(data);});"

	cScript+= "});"
	oDlg:AddScript(cScript)

	cHtml:= oDlg:Show()
Return cHtml
