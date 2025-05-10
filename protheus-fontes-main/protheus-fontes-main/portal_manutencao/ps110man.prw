#INCLUDE 'TBICONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS110MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  21/06/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Incluir Solicitacao                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS110MAN()
	Local cHtml:= ""
	Local oDlg:= Nil
	Local oTab1:= Nil
	Local oTab2:= Nil
	Local oGet:= Nil
	Local oCombo:= Nil
	Local oCombo:= Nil
	Local oBtn:= Nil
	Local cScript:= ""
	Local oAlert:= Nil
	Local cScript:= ""
	Local nBaixo:= 0
	Local nMedio:= 0
	Local nAlto:= 0

	If ValType(HTTPSESSION->cEMP) == "U" .OR. ValType(HTTPSESSION->cFil) == "U" .OR. ValType(HTTPSESSION->cCC) == "U"
		cHtml:= "  $.ajax({"
		cHtml+= "          async: true,"
		cHtml+= "          method: 'POST',"
		cHtml+= "          url: 'u_ps001man.apw',"
		cHtml+= "         }).done(function(data){eval(data);});"
		Return cHtml
	EndIf

	//RPCSetType(3)
	RESET ENVIRONMENT
	PREPARE ENVIRONMENT EMPRESA HTTPSESSION->cEmp FILIAL HTTPSESSION->cFil

	//parametros para calculo do prazo
	nBaixo:= SuperGetMv("PS_MANBAI", .F., 7)
	nMedio:= SuperGetMv("PS_MANMED", .F., 2)
	nAlto:= SuperGetMv("PS_MANALT", .F., 0)

	//ZP2_DATA:Inclusao:true;ZP2_USER:Usuario:true;ZP2_CODIGO:Codigo:true;ZP2_DESC:Descricao:true;ZP2_PRIOR:Prioridade:true;ZP2_NPRIOR:Nova_Prioridade:true;ZP2_LEGEND:Legenda:true;ZP2_STATUS:Status:true;ZP2_PRAZO:Prazo:true;ZP2_NPRAZO:Novo_Prazo:true;ZP2_TIPO:Tipo:false;ZP2_MAQ:Maquina:false;ZP2_CC:CC:false;ZP2_MAUUSO:Mau_Uso:false;ZP2_PREVEN:Preventiva:false;ZP2_CORRET:Corretiva:false;ZP2_MELHOR:Melhoria:false;ZP2_QUALID:Qualidade:false;ZP2_DTINI:Data_Inicio:false;ZP2_DTFIN:Data_Fim:false;ZP2_HRINI:Hora_Inicio:false;ZP2_HRFIN:Hora_Fim:false;ZP2_DTSC:DT_Sol_Compra:false;ZP2_DTPC:DT_Ped_Compra:false;ZP2_DTLPC:DT_Lib_Ped_Compra:false;ZP2_DTENT:DT_Entrega:false;ZP2_DTFSC:DT_Final_Sol_Compra:false
	oDlg:= PSWebDialog():New("ps110man_dialog_incluir", HTTPSESSION->cLogo+"<br>Incluir Solicitacao", "ps110man_form_incluir",,,,,.T.)

	oTab1:= PSWebTab():New('oTab1', 'Cadastrais', .T.)
	oTab2:= PSWebTab():New('oTab2', 'Atendimento', .F.)

	oGet:= PSWebGet():New("ps100man_get_data", "date", "Data*",,SubStr(DtoS(Date()), 1, 4)+"-"+SubStr(DtoS(Date()), 5, 2)+"-"+SubStr(DtoS(Date()), 7, 2))
	oDlg:AddScript("$('#ps100man_get_data').prop('readonly',true);")
	oTab1:AddControl(oGet)

	oGet:= PSWebGet():New("ps100man_get_sol", "text", "Solicitante*",,HTTPSESSION->cUser)
	oDlg:AddScript("$('#ps100man_get_sol').prop('readonly',true);")
	oTab1:AddControl(oGet)

	oGet:= PSWebGet():New("ps100man_get_desc", "text", "Descricao*")
	oTab1:AddControl(oGet)

	oMulti:= PSWebMultiget():New("ps100man_get_situacao", "Situacao", 5)
	oTab1:AddControl(oMulti)

	oGet:= PSWebGet():New("ps100man_get_maquina", "text", "Cod.Maquina*", .T.)
	oTab1:AddControl(oGet)
	cScript:= "$('#ps100man_get_maquina_F3').click(function(){"
	cScript+= "  $.ajax({"
	cScript+= "          async: false,"
	cScript+= "          method: 'POST',"
	cScript+= "          url: 'u_pswebf3.apw',"
	cScript+= "          data: {'titulo':'Consulta maquina', 'id':'id_dialog', 'emp':'"+HTTPSESSION->cEmp+"', 'fil':'"+HTTPSESSION->cFil+"', 'cols':'ZP3_COD:Codigo;ZP3_NOME:Nome;ZP3_GAR:Garantia;ZP3_CC:CC;CTT_DESC01:Descricao', 'from_':'ZP3,CTT', 'where':'CTT_CUSTO=ZP3_CC AND ZP3_CC IN "+PSWFormat(HTTPSESSION->cCC)+" ','ret':'ps100man_get_maquina:0;ps100man_get_dmaquina:1;ps100man_get_gmaquina:2;ps100man_get_cc:3;ps100man_get_dcc:4'},"
	cScript+= "         }).done(function(data){eval(data);});"
	cScript+= "});"
	oDlg:AddScript(cScript)

	oGet:= PSWebGet():New("ps100man_get_dmaquina", "text", "Desc.Maquina*")
	oDlg:AddScript("$('#ps100man_get_dmaquina').prop('readonly',true);")
	oTab1:AddControl(oGet)

	oGet:= PSWebGet():New("ps100man_get_gmaquina", "date", "Garantia Maquina*")
	oDlg:AddScript("$('#ps100man_get_gmaquina').prop('readonly',true);")
	oTab1:AddControl(oGet)

	oGet:= PSWebGet():New("ps100man_get_cc", "text", "Centro de custo*")
	oDlg:AddScript("$('#ps100man_get_cc').prop('readonly',true);")
	oTab1:AddControl(oGet)

	dbSelectArea("CTT")
	oGet:= PSWebGet():New("ps100man_get_dcc", "text", "Desc.Centro de custo*")
	oDlg:AddScript("$('#ps100man_get_dcc').prop('readonly',true);")
	oTab1:AddControl(oGet)

	oCombo:= PSWebCombo():New("ps100man_combo_maquina_parada", "Maquina Parada*", " =&nbsp;S=SIM;N=NAO")
	oTab1:AddControl(oCombo)

	oCombo:= PSWebCombo():New("ps100man_combo_tipo", "Tipo Solicitacao*", " =&nbsp;M=MECANICA;E=ELETRICA;I=INFORMATICA;L=LIMPEZA;P=MANUTENCAO EXTERNA - PATIO;3=OBRAS ROBSON;1=SERVICO - ISO PAINEL;2=SERVICO - ISOLAMENTO;4=SERVICO - PINTURA;5=SERVICO - PISO;6=SERVICO - TERCEIROS")
	oTab2:AddControl(oCombo)

	oCombo:= PSWebCombo():New("ps100man_combo_prioridade", "Prioridade*", "B=BAIXA;M=MEDIA;A=ALTA")
	cScript:= "$('#ps100man_combo_prioridade').on('change', function() {"
	cScript+= "if (this.value == 'A') {"
	cScript+= "  $('#ps100man_get_prazo').val('"+SubStr(DtoS(Date()+nAlto), 1, 4)+"-"+SubStr(DtoS(Date()+nAlto), 5, 2)+"-"+SubStr(DtoS(Date()+nAlto), 7, 2)+"');"
	cScript+= "}else if (this.value == 'M') {"
	cScript+= "  $('#ps100man_get_prazo').val('"+SubStr(DtoS(Date()+nMedio), 1, 4)+"-"+SubStr(DtoS(Date()+nMedio), 5, 2)+"-"+SubStr(DtoS(Date()+nMedio), 7, 2)+"');"
	cScript+= "}else if (this.value == 'B') {"
	cScript+= "  $('#ps100man_get_prazo').val('"+SubStr(DtoS(Date()+nBaixo), 1, 4)+"-"+SubStr(DtoS(Date()+nBaixo), 5, 2)+"-"+SubStr(DtoS(Date()+nBaixo), 7, 2)+"');"
	cScript+= "}"
	cScript+= "});"
	oDlg:AddScript(cScript)
	oTab2:AddControl(oCombo)

	oGet:= PSWebGet():New("ps100man_get_prazo", "date", "Prazo*",,SubStr(DtoS(Date()+nBaixo), 1, 4)+"-"+SubStr(DtoS(Date()+nBaixo), 5, 2)+"-"+SubStr(DtoS(Date()+nBaixo), 7, 2))
	oTab2:AddControl(oGet)

	oCombo:= PSWebCombo():New("ps100man_combo_mauuso", "Mau Uso*", " =&nbsp;N=NAO;S=SIM")
	oTab2:AddControl(oCombo)

	oCombo:= PSWebCombo():New("ps100man_combo_preventiva", "Preventiva*", " =&nbsp;N=NAO;S=SIM")
	oTab2:AddControl(oCombo)

	oCombo:= PSWebCombo():New("ps100man_combo_corretiva", "Corretiva*", " =&nbsp;N=NAO;S=SIM")
	oTab2:AddControl(oCombo)

	oCombo:= PSWebCombo():New("ps100man_combo_melhoria", "Melhoria*", " =&nbsp;N=NAO;S=SIM")
	oTab2:AddControl(oCombo)

	oCombo:= PSWebCombo():New("ps100man_combo_Qualidade", "Retrabalho da Manutencao*", " =&nbsp;N=NAO;S=SIM")//era Qualidade alterado dia 18/03 por Mauricio 
	oTab2:AddControl(oCombo)

	oDlg:AddTab(oTab1)
	oDlg:Addtab(oTab2)

	oBtn:= PSWebButton():New("ps110man_btn_incluir", "Incluir")
	oDlg:AddButton(oBtn)
	cScript:= "$('#ps110man_btn_incluir').click(function(){"
	cScript+= "$(this).prop('disabled', true);"
	cScript+= "  $.ajax({"
	cScript+= "          async: true,"
	cScript+= "          method: 'POST',"
	cScript+= "          url: 'u_ps111man.apw',"
	cScript+= "          data: $('#ps110man_form_incluir').serialize()"
	cScript+= "         }).done(function(data){$('#ps110man_btn_incluir').prop('disabled', false);eval(data);});"
	cScript+= "});"
	oDlg:AddScript(cScript)

	oBtn:= PSWebButton():New("ps110man_btn_cancelar", "Cancelar")
	oDlg:AddButton(oBtn)
	cScript:= "$('#ps110man_btn_cancelar').click(function(){"
	cScript+= "$(this).prop('disabled', true);"
	cScript+= "  $.ajax({"
	cScript+= "          async: true,"
	cScript+= "          method: 'POST',"
	cScript+= "          url: 'u_ps101man.apw',"
	cScript+= "          data: {'PS100MAN_GET_USER':'"+HTTPSESSION->cUSER+"','PS100MAN_GET_PASS':'"+HTTPSESSION->cPASS+"'}"
	cScript+= "         }).done(function(data){$('#ps110man_btn_cancelar').prop('disabled', false);eval(data);});"
	cScript+= "});"
	//cScript+= "$('#thName').click();"
	oDlg:AddScript(cScript)

	cHtml+= oDlg:Show()

Return cHtml

Static Function PSWFormat(cExp)
	Local cRet:= ""

	cRet:= FormatIn(cExp, ";")
	cRet:= StrTran(cRet, "'", "#")

Return cRet
