#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'REPORT.CH'

/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: GPER980.PRW    Autor: Leandro Drumond	   :19/08/2016 		    ***
***********************************************************************************
***Descrição..: Imprime o relatório de Histórico de Afastamentos                ***
***********************************************************************************
***Parâmetros.:				    								                ***
***********************************************************************************
***Retorno....:                                                                 ***
***********************************************************************************
***					Alterações feitas desde a construção inicial       	 	    ***
***********************************************************************************
***RESPONSÁVEL.|DATA....|CÓDIGO|BREVE DESCRIÇÃO DA CORREÇÃO.....................***
***********************************************************************************
***         ...|        |      |                                                ***
***Cícero Alves|08/09/16|TVXPEZ|Ajuste para verificar se existe o grupo de perg.***
**********************************************************************************/

/*/{Protheus.doc} GPER980
	Função responsável pela impressão do relatório de Funcionários por Cargos
@author Leandro Drumond
@since 19/08/2016
@version P11
@return Nil, Valor Nulo
/*/


/*
Dia 13/7/20 - Vou desativar este fonte , porque vou trocar pelo DTI04.prw
 Chamado ID 157
*/


User Function HISTAFAS()
Local	aArea 	:= GetArea()
Local	oReport	:= Nil

oReport := ReportDef()

oReport:PrintDialog()

RestArea(aArea)	

Return Nil

/*/{Protheus.doc} ReportDef
	Define o Objeto da Classe TReport utilizado na impressão do relatório
@author Leandro Drumond
@since 19/08/2016
@version P11
@return oReport, instância da classe TReport
/*/
Static Function ReportDef()	
Local oReport	:= Nil
Local oSecFil	:= Nil
Local oSecCab	:= Nil
Local cRptTitle	:= OemToAnsi("Relatório de Histórico de Afastamentos")
Local cRptDescr	:= OemToAnsi("Este programa emite a Impressão do Relatório de Histórico de Afastamentos.")
Local aOrderBy	:= {}
Local cNomePerg	:=	"GPER980"
Local cMyAlias	:= GetNextAlias()	

aAdd(aOrderBy, OemToAnsi('1 - Filial + Matrícula'))
aAdd(aOrderBy, OemToAnsi('2 - Filial + Nome'))
aAdd(aOrderBy, OemToAnsi('3 - Filial + Centro de Custo'))

//--Verifica se o grupo de perguntas existe na base
dbSelectarea("SX1")
DbSetOrder(1)
If ! dbSeek(cNomePerg)
	Help(" ",1,"NOPERG")
	Return 
EndIf
Pergunte(cNomePerg,.F.)

DEFINE REPORT oReport NAME "HISTAFAS" TITLE cRptTitle PARAMETER cNomePerg ACTION {|oReport| PrintReport(oReport,cNomePerg,cMyAlias)} DESCRIPTION cRptDescr	TOTAL IN COLUMN


DEFINE SECTION oSecFil OF oReport TITLE "Cabeçalho" 	TABLES "SRA" TOTAL IN COLUMN ORDERS aOrderBy
	DEFINE CELL NAME "RA_FILIAL" OF 	oSecFil ALIAS "SRA" SIZE Max(6,Len(xFilial("SRA")))
	DEFINE CELL NAME "RA_MAT" 	 OF 	oSecFil ALIAS "SRA" SIZE 22
	DEFINE CELL NAME "RA_NOME" 	 OF 	oSecFil ALIAS "SRA" SIZE 30
	DEFINE CELL NAME "R8_DATAINI"OF 	oSecFil ALIAS "SR8" SIZE 12
	DEFINE CELL NAME "R8_DATAFIM"OF 	oSecFil ALIAS "SR8" SIZE 12
	DEFINE CELL NAME "MOTIVO"	 OF 	oSecFil BLOCK {|| (cMyAlias)->MOTIVO + " " + FDesc("RCM",(cMyAlias)->MOTIVO,"RCM_DESCRI",60)} SIZE 65 TITLE "Motivo de Afastamento"	
	DEFINE CELL NAME "RA_CC" 	 OF 	oSecFil BLOCK {|| (cMyAlias)->RA_CC + " " + (cMyAlias)->CTT_DESC01 } SIZE 40
	

DEFINE SECTION oSecCab OF oSecFil 	TITLE 'Itens' TABLES "SRA","SR8" TOTAL IN COLUMN
	DEFINE CELL NAME "RA_FILIAL" 	OF 	oSecCab ALIAS "SRA" TITLE "" SIZE Max(6,Len(xFilial("SRA")))
	DEFINE CELL NAME "RA_MAT" 	 	OF 	oSecCab ALIAS "SRA" TITLE "" SIZE 22
	DEFINE CELL NAME "RA_NOME" 	 	OF 	oSecCab ALIAS "SRA" TITLE "" SIZE 30
	DEFINE CELL NAME "R8_DATAINI" 	OF 	oSecCab ALIAS "SR8" TITLE "" SIZE 12
	DEFINE CELL NAME "R8_DATAFIM"	OF 	oSecCab ALIAS "SR8" TITLE "" SIZE 12
	DEFINE CELL NAME "MOTIVO"		OF 	oSecCab BLOCK {|| (cMyAlias)->MOTIVO + " " + FDesc("RCM",(cMyAlias)->MOTIVO,"RCM_DESCRI",60)} SIZE 65 TITLE ""//"Motivo de Afastamento"
	DEFINE CELL NAME "RA_CC" 	 	OF 	oSecCab BLOCK {|| (cMyAlias)->RA_CC + " " + (cMyAlias)->CTT_DESC01 } SIZE 40  TITLE ""

Return oReport

/*/{Protheus.doc} PrintReport
	Realiza a impressão do relatório
@author Leandro Drumond
@since 18/08/2016
@version P11
@param oReport, objeto, instância da classe TReport
@param cNomePerg, caractere, Nome do Pergunte
@param cMyAlias, caractere, Alias utilizado p/ consulta
@return nil, valor nulo
/*/
Static Function PrintReport(oReport, cNomePerg, cMyAlias)
Local oSecFil		:= oReport:Section(1)
Local oSecCab		:= oSecFil:Section(1)
Local oBreakFil		:= Nil
Local oBreakUni		:= Nil
Local oBreakEmp		:= Nil
Local oBreakCC		:= Nil
Local cTitFil		:= ""
Local cTitUniNeg	:= ""
Local cTitEmp		:= ""
Local cJoinCTT		:= ""
Local cCatQuery		:= ""
Local cOrder		:= ""
Local cCategoria	:= MV_PAR03
Local dDataDe		:= MV_PAR05
Local dDataAte		:= MV_PAR06
Local dDFimAf		:= MV_PAR10
Local cSitF			:= MV_PAR07
Local cMot1			:= MV_PAR08
Local cMot2			:= MV_PAR09
Local lCorpManage	:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado
Local cLayoutGC 	:= ''
Local nStartEmp		:= 0
Local nStartUnN		:= 0
Local nEmpLength	:= 0
Local nUnNLength	:= 0
Local nReg			:= 0
Local nOrdem		:= oSecFil:GetOrder()
Local nS

If nOrdem == 1
	cOrder := "%SRA.RA_FILIAL,SRA.RA_MAT,SR8.R8_DATAINI%"
ElseIf nOrdem == 2
	cOrder := "%SRA.RA_FILIAL,SRA.RA_NOME,SR8.R8_DATAINI%"
ElseIf nOrdem == 3
	cOrder := "%SRA.RA_FILIAL,SRA.RA_CC,SRA.RA_MAT,SR8.R8_DATAINI%"
EndIf

If lCorpManage
	cLayoutGC 	:= FWSM0Layout(cEmpAnt)
	nStartEmp	:= At("E",cLayoutGC)
	nStartUnN	:= At("U",cLayoutGC)
	nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
	nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))	
EndIf	


/* Inclusão da categoria (MV_PAR07) - By Flávio*/
cSitQuery := ""
	For nS:=1 to Len(cSitF)
		cSitQuery += "'"+Subs(cSitF,nS,1)+"'"
		If ( nS+1) <= Len(cSitF)
			cSitQuery += ","
		Endif
	Next nS
cSitQuery := "%" + cSitQuery + "%"

cCatQuery := ""
For nReg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += "," 
	Endif
Next nReg        
cCatQuery := "%" + cCatQuery + "%"

cJoinCTT := "%" + FWJoinFilial("CTT", "SRA") + "%"

MakeSqlExpr(cNomePerg)


/*
Dia 12/02/20 - Por Flavio
Efetuando alterações na query para filtrar  marcando o que não for aparecer 
SitFolh
e Código do Afastamento

 SRA.RA_SITFOLH = %MV_PAR07% AND
*/


IF !empty(dDFimAf)

	BEGIN REPORT QUERY oSecFil	
	
		BeginSql alias cMyAlias		
			SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CC, RA_SITFOLH, R8_DATAINI, R8_DATAFIM, R8_TIPOAFA AS MOTIVO, CTT_DESC01
			FROM %table:SRA% SRA
			INNER JOIN %table:SR8% SR8 ON SR8.%notDel% AND R8_FILIAL = RA_FILIAL AND R8_MAT = RA_MAT 
			
			LEFT JOIN %table:CTT% CTT ON CTT.%notDel% AND %exp:cJoinCTT% AND CTT_CUSTO = RA_CC
			WHERE
			
			SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%) AND
			SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%) AND
			SR8.R8_DATAINI >= (%exp:DtoS(dDataDe)%) AND
			SR8.R8_DATAINI <= (%exp:DtoS(dDataAte)%) AND
			SR8.R8_DATAFIM <= (%exp:DtoS(dDFimAf)%) AND
			SR8.R8_TIPOAFA	>=	(%exp:Upper(cMot1)%) AND
			SR8.R8_TIPOAFA	<=	(%exp:Upper(cMot2)%) AND
			SRA.%notDel%
			ORDER BY %exp:cOrder%	
		EndSql	
	
	END REPORT QUERY oSecFil PARAM MV_PAR01, MV_PAR02, MV_PAR04

Else
	
	BEGIN REPORT QUERY oSecFil	

		BeginSql alias cMyAlias		
			SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CC, RA_SITFOLH, R8_DATAINI, R8_DATAFIM, R8_TIPOAFA AS MOTIVO, CTT_DESC01
			FROM %table:SRA% SRA
			INNER JOIN %table:SR8% SR8 ON SR8.%notDel% AND R8_FILIAL = RA_FILIAL AND R8_MAT = RA_MAT 
			
			LEFT JOIN %table:CTT% CTT ON CTT.%notDel% AND %exp:cJoinCTT% AND CTT_CUSTO = RA_CC
			WHERE
			
			SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%) AND
			SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%) AND
			SR8.R8_DATAINI >= (%exp:DtoS(dDataDe)%) AND
			SR8.R8_DATAINI <= (%exp:DtoS(dDataAte)%) AND
			SR8.R8_TIPOAFA	>=	(%exp:Upper(cMot1)%) AND
			SR8.R8_TIPOAFA	<=	(%exp:Upper(cMot2)%) AND
			SRA.%notDel%
			ORDER BY %exp:cOrder%	
		EndSql	

	END REPORT QUERY oSecFil PARAM MV_PAR01, MV_PAR02, MV_PAR04

Endif

//QUEBRA CENTRO DE CUSTO
If nOrdem == 3
	DEFINE BREAK oBreakCC OF oReport WHEN {|| (cMyAlias)->RA_FILIAL + (cMyAlias)->RA_CC}
	oBreakCC:OnBreak({|x|cTitFil := "Total de Afastamentos no Centro de Custos " + x, oReport:ThinLine(),oSecFil:SetHeaderSection(.T.)}) 		
	oBreakCC:SetTotalText({||cTitFil})
	oBreakCC:SetTotalInLine(.F.)
	DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("RA_MAT")  FUNCTION COUNT BREAK oBreakCC NO END SECTION NO END REPORT
EndIf

//QUEBRA FILIAL
DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->RA_FILIAL }		
oBreakFil:OnBreak({|x|cTitFil := "Total de Afastamentos na Filial " + x, oReport:ThinLine(),oSecFil:SetHeaderSection(.T.)})
oBreakFil:SetTotalText({||cTitFil})
oBreakFil:SetTotalInLine(.F.)
DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("RA_MAT")  FUNCTION COUNT BREAK oBreakFil NO END SECTION NO END REPORT

If(lCorpManage)
	
	//QUEBRA UNIDADE DE NEGÓCIO
	DEFINE BREAK oBreakUni OF oReport WHEN {|| Substr((cMyAlias)->RA_FILIAL, nStartUnN, nUnNLength) }		
	oBreakUni:OnBreak({|x|cTitUniNeg := "Total de Afastamentos na Unidade de Negócio " + x, oReport:ThinLine(),oSecFil:SetHeaderSection(.T.)}) 
	oBreakUni:SetTotalText({||cTitUniNeg})
	oBreakUni:SetTotalInLine(.F.)
	DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("RA_MAT")  FUNCTION COUNT BREAK oBreakUni NO END SECTION NO END REPORT
	
	//QUEBRA EMPRESA
	DEFINE BREAK oBreakEmp OF oReport WHEN {|| Substr((cMyAlias)->RA_FILIAL, nStartEmp, nEmpLength) }		
	oBreakEmp:OnBreak({|x|cTitEmp := "Total de Afastamentos na Empresa " + x, oReport:ThinLine(),oSecFil:SetHeaderSection(.T.)})
	oBreakEmp:SetTotalText({||cTitEmp})
	oBreakEmp:SetTotalInLine(.F.)
	DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("RA_MAT")  FUNCTION COUNT	BREAK oBreakEmp NO END SECTION NO END REPORT
		
EndIf

oSecCab:Cell("RA_FILIAL"):HIDE()
oSecCab:Cell("RA_CC"):HIDE()
oSecCab:Cell("RA_MAT"):HIDE()
oSecCab:Cell("RA_NOME"):HIDE()

oSecFil:Cell("R8_DATAINI"):HIDE()
oSecFil:Cell("R8_DATAFIM"):HIDE()
oSecFil:Cell("MOTIVO"):HIDE()

oSecCab:SetParentQuery()
oSecCab:SetParentFilter({|cParam|If((cMyAlias)->RA_FILIAL+(cMyAlias)->RA_MAT == cParam,(oSecFil:SetHeaderSection(.F.),oReport:OnPageBreak({|| oSecFil:SetHeaderSection(.T.),oSecFil:Init(), oSecFil:PrintLine()}),.T.),.F.)},{||(cMyAlias)->RA_FILIAL+(cMyAlias)->RA_MAT})
oSecFil:Print()

Return Nil


// Cópia da rotina fSituacao()       | Ainda sem utilização|                                          
User Function fSitn(l1Elem,lTipoRet)
	Local cTitulo:=""
	Local MvPar
	Local MvParDef:=""
	Local nTam	:= 0
	Local nZ

	Private aSit:={}
	
	l1Elem := If (l1Elem = Nil , .F. , .T.)
	
	Default lTipoRet := .T.
	
	cAlias := Alias() 					 // Salva Alias Anterior
	
	IF lTipoRet
		MvPar:=Rtrim(&(Alltrim(ReadVar())))			 // Carrega Nome da Variavel do Get em Questao
		mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
		nTam := Len(&mvRet)
	EndIf
	
	dbSelectArea("SX5")
	If dbSeek(cFilial + "0031")
	   cTitulo := Alltrim(Left(X5Descri(), 20))
	EndIf

	If dbSeek(cFilial+"31")
		CursorWait()
			//While !Eof() .AND. SX5->X5_Tabela == "31"
			//	Aadd(aSit,Left(SX5->X5_Chave,1) + " - " + Alltrim(X5Descri()))
			//	MvParDef+=Left(SX5->X5_Chave,1)
			//	dbSkip()
			//Enddo
			aRetSX5 := FWGetSX5("31")
			for nZ:= 1 to len(aRetSX5) 		// Filial, Tabela, Chave, Descricao
				AAdd( aSit, Left(aRetSX5[nZ][3], 1) + " - " + AllTrim(aRetSX5[nZ][4]) )
				MvParDef += Left(aRetSX5[nZ][3], 1)
			Next

		CursorArrow()
	Else
		Help(" ",1, "GPEXSITDEF") // Estou usando situacao Default, nao achei tabela
		aSit := {;
					"  - " + "Normal",;
					"A - " + "Afastado",;
					"D - " + "Demitido",;
					"T - " + "Transferido",;
					"F - " + "Ferias";
				}  
		MvParDef:=" ADTF"
		cTitulo :="Situacao"
	EndIf
	
	IF lTipoRet
		IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,12,49,l1Elem)  // Chama funcao f_Opcoes
			&MvRet := mvpar                                                                          // Devolve Resultado
			If nTam > Len(aSit)
				&MvRet += Replicate("*",nTam-Len(aSit))
			EndIf 
		EndIf	
	EndIf
	
	dbSelectArea(cAlias) 								 // Retorna Alias
Return( IF( lTipoRet , .T. , MvParDef ) )


