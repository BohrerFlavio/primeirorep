#INCLUDE 'TBICONN.CH'
#INCLUDE "Fileio.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS160MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  15/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera os logs da solicitacao (Excel)                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS160MAN()
	Local cHtml:= ""
	Local cSol:= HTTPPOST->SOLICITACOES
	Local aSol:= StrTokArr(cSol, ",")
	Local cTab:= ""
	Local nX:= 0
	Local nY:= 0
	Local nZ:= 0
	Local oAlert:= Nil
	Local aTabela:= {}
	Local aFile:= {}
	Local cLinha:= ""
	Local cFile:= "\web\relatorios\"+HTTPSESSION->cUser+".csv"
	//Local cXml:= "\web\relatorios\"+HTTPSESSION->cUser+".xml"
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
		oAlert:= PSWebAlert():New("ps160man_alert", "Erro ao criar arquivo - ferror " + Str(Ferror()), HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	Else
																																													//era Qualidade	
		cLinha:= "Solicitacao;Inclusao;Usuario;Descricao;Prioridade;Nova_Prioridade;Prazo;Novo_Prazo;Tipo;Maquina;Maq_Parada;CC;Mau_Uso;Novo_Mau_Uso;Preventiva;Corretiva;Melhoria;Retrabalho_Manut;Data_Inicio;Data_Fim;Hora_Inicio;Hora_Fim;DT_Sol_Compra;DT_Ped_Compra;DT_Lib_Ped_Compra;DT_Entrega;DT_Final_Sol_Compra;DT_Fim_Solicitacao;HR_Fim_Solicitacao;Manutentor;Produto;Descricao;Quantidade;UM;Sol_Compra;It_Sol_Compra;Sol_Armazem;It.Sol_Armazem;Historico"
		AADD(aFile, cLinha)
		//For nX:= 1 To Len(aSol)

		ZP2->(dbSetOrder(1))
		ZP2->(dbGoTop())
		Do While !ZP2->(EOF())
			ZP4->(dbSetOrder(1))
			ZP4->(dbSeek(xFilial("ZP4")+ZP2->ZP2_CODIGO))
			Do While !ZP4->(EOF()) .AND. xFilial("ZP4")+ZP2->ZP2_CODIGO == ZP4->ZP4_FILIAL+ZP4->ZP4_CODIGO
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

				cLinha+= chr(160)+ZP4->ZP4_PRODUT+";"
				cLinha+= chr(160)+U_PS002MAN(ZP4->ZP4_DESC)+";"
				cLinha+= cValToChar(ZP4->ZP4_QUANT)+";"
				cLinha+= chr(160)+ZP4->ZP4_UM+";"
				cLinha+= chr(160)+ZP4->ZP4_SOLC+";"
				cLinha+= chr(160)+ZP4->ZP4_ITEMSC+";"
				cLinha+= chr(160)+ZP4->ZP4_SOLA+";"
				cLinha+= chr(160)+ZP4->ZP4_ITEMSA+";"
				cLinha+= Chr(160)+UPPER(StrTran(StrTran(StrTran(U_PS002MAN(ZP2->ZP2_HIST), ";", ""), Chr(13), ""), Chr(10), ""))

				AADD(aFile, cLinha)
				ZP4->(dbSkip())
			EndDo
			ZP2->(dbSkip())
		EndDo
		//Next nX

		For nX:= 1 To Len(aFile)
			FWrite(nHandle, aFile[nX]+Chr(13)+Chr(10))
		Next nX

		FClose(nHandle)

	EndIf

	oAlert:= PSWebAlert():New("ps160man_alert", "<a href="+"relatorios/"+HTTPSESSION->cUser+".csv"+">Baixar o arquivo CSV</a>", HTTPSESSION->cLogo)
	cHtml:= oAlert:show()

	/*
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
	oAlert:= PSWebAlert():New("ps160man_alert", "Erro ao criar arquivo - ferror " + Str(Ferror()), HTTPSESSION->cLogo)
	cHtml:= oAlert:show()
	Else

	cLinha:= 'Solicitacao;Data;Hora;Usuario;Descricao;Situacao'
	AADD(aFile, cLinha)
	For nX:= 1 To Len(aSol)

	ZP2->(dbSetOrder(1))
	If ZP2->(DbSeek(xFilial("ZP2")+aSol[nX]))

	aTabela:= StrTokArr(ZP2->ZP2_LOG, Chr(13)+Chr(10))

	For nY:= 1 To Len(aTabela)
	aLinha:= StrTokArr(aTabela[nY], "|")
	If Len(aLinha) >= 4
	cLinha:= chr(160)+aSol[nX]+";"
	cLinha+= DtoC(StoD(aLinha[1]))+";"
	cLinha+= Left(aLinha[2], 5)+";"
	cLinha+= aLinha[3]+";"
	cLinha+= aLinha[4]+";"
	If Len(aLinha) >= 5
	cLinha+= aLinha[5]
	Else
	cLinha+= ""
	EndIf
	AADD(aFile, cLinha)
	EndIf
	Next nX
	EndIf
	Next nX

	For nX:= 1 To Len(aFile)
	FWrite(nHandle, aFile[nX]+Chr(13)+Chr(10))
	Next nX

	FClose(nHandle)

	EndIf

	nHandle:= FCREATE(cXml)
	If nHandle == -1
	oAlert:= PSWebAlert():New("ps160man_alert", "Erro ao criar arquivo - ferror " + Str(Ferror()), HTTPSESSION->cLogo)
	cHtml:= oAlert:show()
	Else
	aFile:= {}
	cLinha:= '<RELATORIO>'
	AADD(aFile, cLinha)
	cLinha:= "<SOLICITACOES>"
	AADD(aFile, cLinha)

	For nX:= 1 To Len(aSol)

	ZP2->(dbSetOrder(1))
	If ZP2->(DbSeek(xFilial("ZP2")+aSol[nX]))

	cLinha:= "<SOLICITACAO>"
	AADD(aFile, cLinha)

	aTabela:= StrTokArr(ZP2->ZP2_LOG, Chr(13)+Chr(10))

	For nY:= 1 To Len(aTabela)
	aLinha:= StrTokArr(aTabela[nY], "|")
	If Len(aLinha) >= 4

	cLinha:= "<NUMERO>"+aSol[nX]+"</NUMERO>"
	AADD(aFile, cLinha)
	cLinha:= "<DATA>"+DtoC(StoD(aLinha[1]))+"</DATA>"
	AADD(aFile, cLinha)
	cLinha:= "<HORA>"+Left(aLinha[2], 5)+"</HORA>"
	AADD(aFile, cLinha)
	cLinha:= "<USUARIO>"+aLinha[3]+"</USUARIO>"
	AADD(aFile, cLinha)
	cLinha:= "<DESCRICAO>"+aLinha[4]+"</DESCRICAO>"
	AADD(aFile, cLinha)
	cLinha:= "<SITUACAO>"+IIF(Len(aLinha)>= 5, StrTran(StrTran(aLinha[5], Chr(13), "\N"), Chr(10), ""), "")+"</SITUACAO>"
	AADD(aFile, cLinha)
	EndIf
	Next nX

	cLinha:= "</SOLICITACAO>"
	AADD(aFile, cLinha)
	EndIf
	Next nX

	cLinha:= '</SOLICITACOES>'
	AADD(aFile, cLinha)
	cLinha:= '</RELATORIO>'
	AADD(aFile, cLinha)

	For nX:= 1 To Len(aFile)
	FWrite(nHandle, aFile[nX])
	Next nX

	FClose(nHandle)
	EndIf


	oAlert:= PSWebAlert():New("ps160man_alert", "<a href="+"relatorios/"+HTTPSESSION->cUser+".csv"+">Baixar o arquivo CSV</a><br><a href="+"relatorios/"+HTTPSESSION->cUser+".xml"+">Baixar o arquivo XML</a>", HTTPSESSION->cLogo)
	cHtml:= oAlert:show()
	*/
Return cHtml
