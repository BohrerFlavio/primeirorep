#INCLUDE 'TBICONN.CH'
#INCLUDE "Fileio.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS180MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  25/03/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exportacao Excel - relatorio gerencial                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS180MAN()
	Local cHtml:= ""
	Local cSol:= HTTPPOST->SOLICITACOES
	Local aSol:= StrTokArr(cSol, ",")
	Local nX:= 0
	Local oAlert:= Nil
	Local aFile:= {}
	Local cLinha:= ""
	Local cFile:= "\web\relatorios\"+HTTPSESSION->cUser+".csv"
	Local nHandle:= -1

	If ValType(HTTPSESSION->cEMP) == "U" .OR. ValType(HTTPSESSION->cFil) == "U" .OR. ValType(HTTPSESSION->cCC) == "U"
		cHtml:= "  $.ajax({"
		cHtml+= "          async: true,"
		cHtml+= "          method: 'POST',"
		cHtml+= "          url: 'u_ps001man.apw',"
		cHtml+= "         }).done(function(data){eval(data);});"
		Return cHtml
	EndIf

	RESET ENVIRONMENT
	PREPARE ENVIRONMENT EMPRESA HTTPSESSION->cEmp FILIAL HTTPSESSION->cFil

	nHandle:= FCREATE(cFile)
	If nHandle == -1
		oAlert:= PSWebAlert():New("ps180man_alert", "Erro ao criar arquivo - ferror " + Str(Ferror()), HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	Else
																																													//era Qualidade
		cLinha:= "Solicitacao;Inclusao;Usuario;Descricao;Prioridade;Nova_Prioridade;Prazo;Novo_Prazo;Tipo;Maquina;Maq_Parada;CC;Mau_Uso;Novo_Mau_Uso;Preventiva;Corretiva;Melhoria;Retrabalho_Manut;Data_Inicio;Data_Fim;Hora_Inicio;Hora_Fim;DT_Sol_Compra;DT_Ped_Compra;DT_Lib_Ped_Compra;DT_Entrega;DT_Final_Sol_Compra;DT_Fim_Solicitacao;HR_Fim_Solicitacao;Manutentor"
		AADD(aFile, cLinha)
		For nX:= 1 To Len(aSol)

			ZP2->(dbSetOrder(1))
			If ZP2->(DbSeek(xFilial("ZP2")+aSol[nX]))

				cLinha:= chr(160)+ZP2->ZP2_CODIGO+";"
				cLinha+= DtoS(ZP2->ZP2_DATA)+";"
				cLinha+= chr(160)+ZP2->ZP2_USER+";"
				cLinha+= chr(160)+ZP2->ZP2_DESC+";"
				cLinha+= chr(160)+ZP2->ZP2_PRIOR+";"
				cLinha+= chr(160)+ZP2->ZP2_NPRIOR+";"
				cLinha+= DtoS(ZP2->ZP2_PRAZO)+";"
				cLinha+= DtoS(ZP2->ZP2_NPRAZO)+";"
				cLinha+= chr(160)+ZP2->ZP2_TIPO+";"
				cLinha+= chr(160)+ZP2->ZP2_MAQ+";"
				cLinha+= chr(160)+ZP2->ZP2_MAQPAR+";"
				cLinha+= chr(160)+ZP2->ZP2_CC+";"
				cLinha+= chr(160)+ZP2->ZP2_MAUUSO+";"
				cLinha+= chr(160)+ZP2->ZP2_NMAUUS+";"
				cLinha+= chr(160)+ZP2->ZP2_PREVEN+";"
				cLinha+= chr(160)+ZP2->ZP2_CORRET+";"
				cLinha+= chr(160)+ZP2->ZP2_MELHOR+";"
				cLinha+= chr(160)+ZP2->ZP2_QUALID+";"
				cLinha+= DtoS(ZP2->ZP2_DTINI)+";"
				cLinha+= DtoS(ZP2->ZP2_DTFIN)+";"
				cLinha+= chr(160)+ZP2->ZP2_HRINI+";"
				cLinha+= chr(160)+ZP2->ZP2_HRFIN+";"
				cLinha+= DtoS(ZP2->ZP2_DTSC)+";"
				cLinha+= DtoS(ZP2->ZP2_DTPC)+";"
				cLinha+= DtoS(ZP2->ZP2_DTLPC)+";"
				cLinha+= DtoS(ZP2->ZP2_DTENT)+";"
				cLinha+= DtoS(ZP2->ZP2_DTFSC)+";"
				cLinha+= DtoS(ZP2->ZP2_DTRFIM)+";"
				cLinha+= chr(160)+ZP2->ZP2_HRRFIM+";"
				cLinha+= chr(160)+ZP2->ZP2_MANUTE+";"
				AADD(aFile, cLinha)
			EndIf
		Next nX

		For nX:= 1 To Len(aFile)
			FWrite(nHandle, aFile[nX]+Chr(13)+Chr(10))
		Next nX

		FClose(nHandle)

	EndIf

	oAlert:= PSWebAlert():New("ps180man_alert", "<a href="+"relatorios/"+HTTPSESSION->cUser+".csv"+">Baixar o arquivo CSV</a>", HTTPSESSION->cLogo)
	cHtml:= oAlert:show()
Return cHtml
