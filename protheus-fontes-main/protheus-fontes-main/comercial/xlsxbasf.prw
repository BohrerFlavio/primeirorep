#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} XLSXBASF
@Type			: Função de Usuário
@Sample			: U_XLSXBASF()
@Description	: Função para gerar excel (XLSX) ref. pré-carregamento selecionado
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Abr/2024
@version		: Protheus 12.1.2210 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function XLSXBASF()

	Local aArea    := FWGetArea()
	Local aPergs   := {}
	Local cPreCarr := Space(TamSX3("ZZ3_NUM")[1])
	Local nVinc	   := 1

	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Pré-Carregamento: ", cPreCarr,  "", ".T.", "ZZ3", ".T.", 80 , .F.})      // MV_PAR01
	aAdd(aPergs, {2, "Busca NF?"		 , nVinc   , {"1=Sim", "2=Não"},090, ".T.", .F.})      // MV_PAR02

	//Se a pergunta for confirma, cria as definicoes do relatorio
	If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)
		Processa({|| fGeraExcel()})
	EndIf

	FWRestArea(aArea)
Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} fGeraExcel
Criação do arquivo excel
@author     Evandro Mugnol
@since      Abr/2024
/*/
//----------------------------------------------------------------------
Static Function fGeraExcel()
	
    Local cQuery     := ""
	Local oFWMsExcel
	Local oExcel
	Local cArquivo   := GetTempPath() + "precarr.xlsx"
	Local cWorkSheet := "PreCarregamento"
	Local cTitulo    := "Listagem do PreCarregamento"
	Local nAtual     := 0
	Local nTotal     := 0

	// Montando consulta de dados
    cQuery := " SELECT * " 
    cQuery += " FROM " + RetSqlTab("ZZ4")
    cQuery += " INNER JOIN " + RetSqlTab("SA1") + " ON A1_FILIAL = '" + FWxFilial("SA1") + "' AND A1_COD = ZZ4_CODCLI AND A1_LOJA = ZZ4_LOJA AND SA1.D_E_L_E_T_ = '' "
	if cValToChar(MV_PAR02) = '1'
		cQuery += " INNER JOIN " + RetSqlTab("SF2") + "  ON ZZ4_NUM = F2_PREPED AND ZZ4_CODCLI = F2_CLIENTE AND F2_LOJA = ZZ4_LOJA "
	endif
    cQuery += " WHERE " + RetSqlFil("ZZ4") 
    cQuery += " AND ZZ4_PRECAR = '" + MV_PAR01 + "'"
    cQuery += " AND " + RetSqlDel("ZZ4")
    cQuery += " ORDER BY ZZ4_PRECAR, ZZ4_NUM"

	// Executando consulta e setando o total da regua
	PlsQuery(cQuery, "QRY_DAD")
	DbSelectArea("QRY_DAD")

	// Cria a planilha do excel
	oFWMsExcel := FWMSExcelXLSX():New()

	// Criando a aba da planilha
	oFWMsExcel:AddworkSheet(cWorkSheet)

	// Criando a tabela
	//oFWMsExcel:AddTable(cWorkSheet,  cTitulo)

	/*
	PARÂMETROS AddColumn
	Nome	    Tipo	    Descrição
	==========================================================================================
	cWorkSheet	Caracteres	Nome da planilha
	cTable	    Caracteres	Nome da planilha
	cColumn	    Caracteres	Titulo da tabela que será adicionada
	nAlign	    Numérico	Alinhamento da coluna ( 1-Left,2-Center,3-Right )
	nFormat	    Numérico	Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
	lTotal	    Lógico	    Indica se a coluna deve ser totalizada
	cPicture	Caracteres	Mascara de picture a ser aplicada. Somente para campos numéricos
	*/

	// Criando as colunas da tabela
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Filial"          , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Numero"          , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Status"          , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "StatusFusion"    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Origem"          , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Loc Carreg."     , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Marca"           , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Data"            , 2, 4, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Tp. Operacao"   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Cod.Cli."       	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Loja"           	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Nome Cli."      	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Endereco"       	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Cidade"         	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "UF"             	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Usuario"        	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Cod.Pre.Carr"   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Dta.Fimal"     	, 2, 4, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Dta.Inicial"    	, 2, 4, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Hora Final"    	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Desconto"      	, 3, 2, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Qt.Prev.Peso"  	, 3, 2, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Qt.Prev.Caix"  	, 3, 2, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Total"         	, 3, 2, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Data"     	   	, 2, 4, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Num.Pedido"      , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Observacao"      , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Hr Inicial 1"    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Hr Final 1"      , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Hr Inicial 2"    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Hr Final 2"      , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Hora Lib."     	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Data lib."     	, 2, 4, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Usu Lib."       	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Lim. Credito"   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Cred.Vigente"   	, 3, 2, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Cod. Repres."   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Nome Repres."   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Valor Comis."   	, 3, 2, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Habilitacao"    	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "N.P. Compra"    	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Dt. Entrada"   	, 2, 4, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Hr  Entrada"    	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Num.Orcamen."   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Tip. Codific"   	, 3, 2, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Email User"    	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Hr.Cad.Porta"   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Dt.Cad.Porta"  	, 2, 4, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Dt. Entrega"    	, 2, 4, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Redistribuic"   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Val do Frete"   	, 3, 2, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Us.Lib.Fin."   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Hr.Us.Lib.Fi"   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Dt.Us.Lib.Fi"   	, 2, 4, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Tp. Producao"   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Segmento 1"   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Data Entrega"   	, 2, 4, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Dtas 1/3 Val"   	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Nota Fiscal"   	, 1, 1, .F.)

	// Definindo o tamanho da regua
	Count To nTotal
	ProcRegua(nTotal)
	QRY_DAD->(DbGoTop())

	// Percorrendo os dados da query
	While !(QRY_DAD->(EoF()))

		// Incrementando a regua
		nAtual++
		IncProc("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

		// Adicionando uma nova linha
		oFWMsExcel:AddRow(cWorkSheet, cTitulo, {;
                                                QRY_DAD->ZZ4_FILIAL     							,;
                                                QRY_DAD->ZZ4_NUM        							,;
                                                QRY_DAD->ZZ4_STATUS     							,;
                                                QRY_DAD->ZZ4_STAFUS     							,;
                                                QRY_DAD->ZZ4_ORIGEM     							,;
                                                QRY_DAD->ZZ4_LOCAR      							,;
                                                QRY_DAD->ZZ4_MARCA      							,;
                                                QRY_DAD->ZZ4_DATA  									,;
                                                QRY_DAD->ZZ4_TPOPER									,;
                                                QRY_DAD->ZZ4_CODCLI									,;
                                                QRY_DAD->ZZ4_LOJA									,;
                                                QRY_DAD->ZZ4_NOME 									,;
                                                QRY_DAD->A1_END	  									,;
                                                QRY_DAD->A1_MUN	  									,;
                                                QRY_DAD->A1_EST	  									,;
                                                QRY_DAD->ZZ4_USAR  									,;
                                                QRY_DAD->ZZ4_PRECAR									,;
                                                QRY_DAD->ZZ4_DTFIM 									,;
                                                QRY_DAD->ZZ4_DTINI									,;
                                                QRY_DAD->ZZ4_HFIM 									,;
                                                QRY_DAD->ZZ4_DESC 									,;
                                                QRY_DAD->ZZ4_QPPESO									,;
                                                QRY_DAD->ZZ4_QPCAIX									,;
                                                QRY_DAD->ZZ4_TOTAL									,;
                                                QRY_DAD->ZZ4_DATAPV									,;
                                                QRY_DAD->ZZ4_NUMPED									,;
                                                QRY_DAD->ZZ4_OBS  									,;
                                                QRY_DAD->ZZ4_HRINI1									,;
                                                QRY_DAD->ZZ4_HRFIN1									,;
                                                QRY_DAD->ZZ4_HRINI2									,;
                                                QRY_DAD->ZZ4_HRFIN2									,;
                                                QRY_DAD->ZZ4_HLIB  									,;
                                                QRY_DAD->ZZ4_DTLIB 									,;
                                                QRY_DAD->ZZ4_USULIB									,;
                                                QRY_DAD->ZZ4_LIMCRE									,;
                                                QRY_DAD->ZZ4_CREVIG									,;
                                                QRY_DAD->ZZ4_REPRES									,;
                                                QRY_DAD->ZZ4_NOMREP									,;
                                                QRY_DAD->ZZ4_COMIS 									,;
                                                QRY_DAD->ZZ4_CLASSI									,;
                                                QRY_DAD->ZZ4_PCOMPR									,;
                                                QRY_DAD->ZZ4_DTENT 									,;
                                                QRY_DAD->ZZ4_HRENT									,;
                                                QRY_DAD->ZZ4_NUMORC									,;
                                                QRY_DAD->ZZ4_TIPCOD									,;
                                                QRY_DAD->ZZ4_EMAILU									,;
                                                QRY_DAD->ZZ4_HORAC 									,;
                                                QRY_DAD->ZZ4_DATAC									,;
                                                QRY_DAD->ZZ4_DTENTR									,;
                                                QRY_DAD->ZZ4_REDIST									,;
                                                QRY_DAD->ZZ4_VFRETE									,;
                                                QRY_DAD->ZZ4_USLIBF									,;
                                                QRY_DAD->ZZ4_HRULFI									,;
                                                QRY_DAD->ZZ4_DTULFI									,;
                                                QRY_DAD->ZZ4_TIPOPR									,;
                                                QRY_DAD->ZZ4_SATIV1									,;
                                                QRY_DAD->ZZ4_DATENT									,;
                                                QRY_DAD->ZZ4_AUTDTP									,;
												iif(cValToChar(MV_PAR02) = '1', QRY_DAD->F2_DOC, "");
                                                })

		QRY_DAD->(DbSkip())
	EndDo

	QRY_DAD->(DbCloseArea())

	// Ativando o arquivo e gerando o xlsx
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	// Abrindo o excel e abrindo o arquivo xlsx
	oExcel := MsExcel():New()
	oExcel:WorkBooks:Open(cArquivo)
	oExcel:SetVisible(.T.)
	oExcel:Destroy()

Return
