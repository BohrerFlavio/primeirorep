#INCLUDE 'TBICONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS101MNT  ºAutor  ³Ezequiel Pianegonda º Data ³  14/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravacao do log de registros das solicitacoes               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS101MNT(cSol, cLog)
	Local cRet:= ""
	Local cHist:= ""
	Local cXml:= ""

	ZP2->(DbSetOrder(1))
	If ZP2->(DbSeek(xFilial("ZP2")+cSol))
		cHist:= ZP2->ZP2_LOG+DtoS(Date())+"|"+Time()+"|"+HTTPSESSION->cUser+"|"+cLog+": "+Alltrim(ZP2->ZP2_STATUS)+"|"
		cXml:= "<SOLICITACAO><NUMERO>"+ZP2->ZP2_CODIGO+"</NUMERO>"
		cXml+= "<CABECALHO>"
		cXml+= "<Status>"+cValToChar(ZP2->ZP2_STATUS)+"</Status>"
		cXml+= "<Codigo>"+cValToChar(ZP2->ZP2_CODIGO)+"</Codigo>"
		cXml+= "<Inclusao>"+cValToChar(ZP2->ZP2_DATA)+"</Inclusao>"
		cXml+= "<Usuario>"+cValToChar(ZP2->ZP2_USER)+"</Usuario>"
		cXml+= "<Descricao>"+cValToChar(ZP2->ZP2_DESC)+"</Descricao>"
		cXml+= "<Prioridade>"+cValToChar(ZP2->ZP2_PRIOR)+"</Prioridade>"
		cXml+= "<Nova_Prioridade>"+cValToChar(ZP2->ZP2_NPRIOR)+"</Nova_Prioridade>"
		cXml+= "<Prazo>"+cValToChar(ZP2->ZP2_PRAZO)+"</Prazo>"
		cXml+= "<Novo_Prazo>"+cValToChar(ZP2->ZP2_NPRAZO)+"</Novo_Prazo>"
		cXml+= "<Tipo>"+cValToChar(ZP2->ZP2_TIPO)+"</Tipo>"
		cXml+= "<Maquina>"+cValToChar(ZP2->ZP2_MAQ)+"</Maquina>"
		cXml+= "<CC>"+cValToChar(ZP2->ZP2_CC)+"</CC>"
		cXml+= "<Mau_Uso>"+cValToChar(ZP2->ZP2_MAUUSO)+"</Mau_Uso>"
		cXml+= "<Novo_Mau_Uso>"+cValToChar(ZP2->ZP2_NMAUUS)+"</Novo_Mau_Uso>"
		cXml+= "<Preventiva>"+cValToChar(ZP2->ZP2_PREVEN)+"</Preventiva>"
		cXml+= "<Corretiva>"+cValToChar(ZP2->ZP2_CORRET)+"</Corretiva>"
		cXml+= "<Melhoria>"+cValToChar(ZP2->ZP2_MELHOR)+"</Melhoria>"
		cXml+= "<Retrabalho_Manut>"+cValToChar(ZP2->ZP2_QUALID)+"</Retrabalho_Manut>"//era Qualidade
		cXml+= "<Data_Inicio>"+cValToChar(ZP2->ZP2_DTINI)+"</Data_Inicio>"
		cXml+= "<Data_Fim>"+cValToChar(ZP2->ZP2_DTFIN)+"</Data_Fim>"
		cXml+= "<Hora_Inicio>"+cValToChar(ZP2->ZP2_HRINI)+"</Hora_Inicio>"
		cXml+= "<Hora_Fim>"+cValToChar(ZP2->ZP2_HRFIN)+"</Hora_Fim>"
		cXml+= "<DT_Sol_Compra>"+cValToChar(ZP2->ZP2_DTSC)+"</DT_Sol_Compra>"
		cXml+= "<DT_Ped_Compra>"+cValToChar(ZP2->ZP2_DTPC)+"</DT_Ped_Compra>"
		cXml+= "<DT_Lib_Ped_Compra>"+cValToChar(ZP2->ZP2_DTLPC)+"</DT_Lib_Ped_Compra>"
		cXml+= "<DT_Entrega>"+cValToChar(ZP2->ZP2_DTENT)+"</DT_Entrega>"
		cXml+= "<DT_Final_Sol_Compra>"+cValToChar(ZP2->ZP2_DTFSC)+"</DT_Final_Sol_Compra>"
		cXml+= "<DT_Fim_Solicitacao>"+cValToChar(ZP2->ZP2_DTRFIM)+"</DT_Fim_Solicitacao>"
		cXml+= "<HR_Fim_Solicitacao>"+cValToChar(ZP2->ZP2_HRRFIM)+"</HR_Fim_Solicitacao>"
		cXml+= "</CABECALHO>"

		cXml+= "<ITENS>"
		ZP4->(dbSetOrder(1))
		ZP4->(dbSeek(xFilial("ZP4")+ZP2->ZP2_CODIGO))
		Do While !SZ4->(EOF()) .AND. xFilial("ZP4")+ZP2->ZP2_CODIGO == ZP4->ZP4_FILIAL+ZP4->ZP4_CODIGO
			cXml+= "<ITEM>"
			cXml+= "<Codigo>"+cValToChar(ZP4->ZP4_CODIGO)+"<Codigo>"
			cXml+= "<Status>"+cValToChar(ZP4->ZP4_STATUS)+"<Status>"
			cXml+= "<Descricao>"+cValToChar(ZP4->ZP4_DESC)+"<Descricao>"
			cXml+= "<Quantidade>"+cValToChar(ZP4->ZP4_QUANT)+"<Quantidade>"
			cXml+= "<Unidade>"+cValToChar(ZP4->ZP4_UM)+"<Unidade>"
			cXml+= "<Cod_Sol_Compra>"+cValToChar(ZP4->ZP4_SOLC)+"<Cod_Sol_Compra>"
			cXml+= "<It_Sol_Compra>"+cValToChar(ZP4->ZP4_ITEMSC)+"<It_Sol_Compra>"
			cXml+= "<Cod_Sol_Armazém>"+cValToChar(ZP4->ZP4_SOLA)+"<Cod_Sol_Armazém>"
			cXml+= "<It_Sol_Armazém>"+cValToChar(ZP4->ZP4_ITEMSA)+"<It_Sol_Armazém>"
			cXml+= "</ITEM>"
			ZP4->(dbSkip())
		EndDo
		cXml+= "</ITENS>"
		cXml+= "</SOLICITACAO>"
		cHist+= cXml+Chr(13)+Chr(10)
		RecLock("ZP2", .F.)
		ZP2->ZP2_LOG:= cHist
		ZP2->(MsUnLock())
	Else
		cRet:= "Solicitacao '"+cSol+"' nao encontrada."
	Endif
Return cRet
