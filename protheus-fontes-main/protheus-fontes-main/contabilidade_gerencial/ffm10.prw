#INCLUDE "Matr945.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FFM10   ³ Autor ³ Andressa Fagundes     ³ Data ³18/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao para Contribuicao Seguridade Social                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FFM10()

	Local oReport
	Private cTpRur	:= ""

	If FindFunction("TRepInUse") .And. TRepInUse()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Interface de impressao                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport	:= ReportDef()
		oReport:PrintDialog()
	Else
		FFM10R3()
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Andressa Fagundes      ³ Data ³17/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

	Local oReport
	Local oBreak1
	Local oNfEntr
	Local oNfSaid

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Componente de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//Este programa tem como objetivo,emitir uma relaçäo dos valores referentes a Contribuiçäo Seguridade Social
	oReport := TReport():New("MATR945",STR0020,"MATR945", {|oReport| ReportPrint(oReport)},STR0002+" "+STR0003)

	Pergunte("MTR945",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 1 - Movimentos de Entrada                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oNfEntr:= TRSection():New(oReport,STR0041,{"SF1","SA2","SA1"},{STR0051},/*Campos do SX3*/,/*Campos do SIX*/)
	oNfEntr:SetPageBreak()
	oNfEntr:SetNoFilter({"SA2","SA1"})
	TRCell():New(oNfEntr,"F1_EMISSAO"	,"SF1"	,STR0021 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfEntr,"F1_DTDIGIT"	,"SF1"	,STR0022 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfEntr,"F1_DOC"		,"SF1"	,STR0023 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfEntr,"F1_SERIE"		,"SF1"	,STR0024 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfEntr,"F1_FORNECE"	,"SF1"	,STR0025 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfEntr,"F1_LOJA"		,"SF1"	,STR0026 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfEntr,"A2_NOME"		,"SA2"	,STR0027 ,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfEntr,"A2_TPRUR"		,"SA2"	,STR0028 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfEntr,"A2_CGC"		,"SA2"	,STR0029 ,/*"@R 99.999.999/9999-99"*/,/*20*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfEntr,"F1_VALBRUT"	,"SF1"	,STR0030 ,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfEntr,"F1_CONTSOC"	,"SF1"	,STR0031 ,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfEntr,"F1_TIPO"		,"SF1"	,STR0048 ,"@!",1,/*lPixel*/,/*{|| code-block de impressao }*/)
	//Quebra por Data de Emissao
	oBreak1 := TRBreak():New(oNfEntr,oNfEntr:Cell("F1_EMISSAO"),STR0032,.F.)

	//Totalizadores
	TRFunction():New(oNfEntr:Cell("F1_VALBRUT")	,Nil,"SUM",oBreak1,STR0039,"@E 999,999,999.99",/*uFormula*/,.T.,.F.)
	TRFunction():New(oNfEntr:Cell("F1_CONTSOC")	,Nil,"SUM",oBreak1,STR0040,"@E 999,999,999.99",/*uFormula*/,.T.,.F.)
	oReport:Section(1):SetTotalText(STR0033)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 2 - Movimentos de Saida                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oNfSaid:= TRSection():New(oReport,STR0042,{"SF2","SA1","SA2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oNfSaid:SetPageBreak()            
	oNfSaid:SetNoFilter({"SA2","SA1"})
	TRCell():New(oNfSaid,"F2_EMISSAO"	,"SF2"	,STR0021 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfSaid,"F2_EMISSAO"	,"SF2"	,STR0022 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfSaid,"F2_DOC"		,"SF2"	,STR0023 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfSaid,"F2_SERIE"		,"SF2"	,STR0024 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfSaid,"F2_CLIENTE"	,"SF2"	,STR0034 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfSaid,"F2_LOJA"		,"SF2"	,STR0026 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfSaid,"A1_NOME"		,"SA1"	,STR0035 ,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfSaid,"A1_TIPO"		,"SA1"	,STR0036 ,/*Picture*/,10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfSaid,"A1_CGC"		,"SA1"	,STR0029 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfSaid,"F2_VALBRUT"	,"SF2"	,STR0030 ,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfSaid,"F2_CONTSOC"	,"SF2"	,STR0031 ,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNfSaid,"F2_TIPO"		,"SF2"	,STR0048 ,"@!",1,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Andressa Fagundes     ³ Data ³18/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos  ³±±
±±³          ³os relatorios que poderao ser agendados pelo usuario.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

	Local cAliasSF1	:= "SF1"
	Local cAliasSF2	:= "SF2"
	Local cTipoRur  := ""
	Local cCnpj		:= ""
	Local cNome		:= ""
	//Local cTpRur	:= ""
	Local _cEMPREG := ""
	Local lFirst 	:= .F.

	Local oNfEntr	:= oReport:Section(1)
	Local oNfSaid	:= oReport:Section(2)
	Local oTotaliz
	Local oBreak2
	Local oBreak3

	#IFNDEF TOP
	Local cCondicao :=	""
	#ENDIF

	Private aPFunRur 	:= FunRur()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona Movimentacao de Entrada                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par03 == 1 .Or. mv_par03 == 3 // Notas Fiscais de Entrada

		dbSelectArea("SF1")
		dbSetOrder(1)

		#IFDEF TOP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Transforma parametros Range em expressao SQL   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MakeSqlExpr(oReport:uParam)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query do relatório da secao 1                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:Section(1):BeginQuery()	

		cAliasSF1 := GetNextAlias()                 
		If !Empty(mv_par04) .And. !Empty(mv_par05)  // Tambem filtra pela data de entrada 
			BeginSql Alias cAliasSF1

				SELECT F1_FILIAL, F1_EMISSAO, F1_DOC, F1_SERIE, F1_DTDIGIT,
				F1_FORNECE, F1_LOJA, F1_VALBRUT, F1_VALMERC, F1_CONTSOC, F1_TIPO

				FROM %table:SF1% SF1

				WHERE F1_FILIAL = %xFilial:SF1%
				AND F1_EMISSAO >= %Exp:Dtos(mv_par01)%
				AND F1_EMISSAO <= %Exp:Dtos(mv_par02)%
				AND F1_CONTSOC > 0
				AND F1_DTDIGIT >= %Exp:Dtos(mv_par04)%
				AND F1_DTDIGIT <= %Exp:Dtos(mv_par05)%
				AND SF1.%NotDel%

				ORDER BY %Order:SF1%

			EndSql

		Else	// Nao filtra pela data de entrada 

			BeginSql Alias cAliasSF1

				SELECT F1_FILIAL, F1_EMISSAO, F1_DOC, F1_SERIE, F1_DTDIGIT,
				F1_FORNECE, F1_LOJA, F1_VALBRUT, F1_VALMERC, F1_CONTSOC, F1_TIPO

				FROM %table:SF1% SF1

				WHERE F1_FILIAL = %xFilial:SF1%
				AND F1_EMISSAO >= %Exp:Dtos(mv_par01)%
				AND F1_EMISSAO <= %Exp:Dtos(mv_par02)%
				AND F1_CONTSOC > 0
				AND SF1.%NotDel%

				ORDER BY %Order:SF1%

			EndSql    

		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Metodo EndQuery ( Classe TRSection )                                    ³
		//³                                                                        ³
		//³Prepara o relatório para executar o Embedded SQL.                       ³
		//³                                                                        ³
		//³ExpA1 : Array com os parametros do tipo Range                           ³
		//³                                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

		#ELSE
		MakeAdvplExpr(oReport:uParam)                                              

		cCondicao := "F1_FILIAL == '"+xFilial("SF1")+"' .AND. "
		cCondicao += "Dtos(F1_EMISSAO)>= '"+Dtos(mv_par01)+"' .AND. Dtos(F1_EMISSAO)<= '"+Dtos(mv_par02)+"' .And. "
		cCondicao += "F1_CONTSOC > 0 "
		If !Empty(mv_par04) .And. !Empty(mv_par05)
			cCondicao 	+= " .And. DTOS(F1_DTDIGIT) >='"+DTOS(mv_par04)+"'"
			cCondicao 	+= " .And. DTOS(F1_DTDIGIT) <='"+DTOS(mv_par05)+"'"
		EndIf	                                                        

		oReport:Section(1):SetFilter(cCondicao,IndexKey())

		#ENDIF

	Endif	

	If mv_par03 == 2 .Or. mv_par03 == 3 // Notas Fiscais de Saida

		dbSelectArea("SF2")
		dbSetOrder(1)

		#IFDEF TOP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Transforma parametros Range em expressao SQL   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MakeSqlExpr(oReport:uParam)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query do relatório da secao 1                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:Section(2):BeginQuery()	

		cAliasSF2 := GetNextAlias()
		BeginSql Alias cAliasSF2

			SELECT F2_FILIAL, F2_EMISSAO, F2_DOC, F2_SERIE,	F2_CLIENTE,
			F2_LOJA, F2_VALBRUT, F2_VALMERC, F2_CONTSOC, F2_TIPO

			FROM %table:SF2% SF2

			WHERE F2_FILIAL = %xFilial:SF2%
			AND F2_EMISSAO >= %Exp:Dtos(mv_par01)%
			AND F2_EMISSAO <= %Exp:Dtos(mv_par02)%
			AND F2_CONTSOC > 0
			AND SF2.%NotDel%

			ORDER BY %Order:SF2%

		EndSql
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Metodo EndQuery ( Classe TRSection )                                    ³
		//³                                                                        ³
		//³Prepara o relatório para executar o Embedded SQL.                       ³
		//³                                                                        ³
		//³ExpA1 : Array com os parametros do tipo Range                           ³
		//³                                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:Section(2):EndQuery(/*Array com os parametros do tipo Range*/)
		oNfSaid:SetParentQuery()

		#ELSE
		MakeAdvplExpr(oReport:uParam)

		cChave	  := "DTOS(F2_EMISSAO)+F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE,F2_LOJA"
		cCondicao := "F2_FILIAL == '"+xFilial("SF2")+"' .AND. "
		cCondicao += "Dtos(F2_EMISSAO)>= '"+Dtos(mv_par01)+"' .AND. Dtos(F2_EMISSAO)<= '"+Dtos(mv_par02)+"' .And. "
		cCondicao += "F2_CONTSOC > 0 "

		oReport:Section(2):SetFilter(cCondicao,IndexKey())

		#ENDIF

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Campos a serem impressos - cliente/fornecedor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oNfEntr:Cell("A2_NOME"):SetBlock({|| cNome }) 
	oNfEntr:Cell("A2_TPRUR"):SetBlock({|| cTpRur })
	oNfEntr:Cell("A2_CGC"):SetBlock({|| cCnpj })
	oNfSaid:Cell("A1_NOME"):SetBlock({|| cNome })
	oNfSaid:Cell("A1_TIPO"):SetBlock({|| cTpRur })
	oNfSaid:Cell("A1_CGC"):SetBlock({|| cCnpj })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Totalizadores³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Quebra por Data de Emissao
	oBreak2 := TRBreak():New(oNfSaid,oNfSaid:Cell("F2_EMISSAO"),STR0037,.F.) //"TOTAL DO DIA CONSUMIDOR"
	oBreak3 := TRBreak():New(oNfSaid,oNfSaid:Cell("F2_EMISSAO"),STR0038,.F.) //"TOTAL DO DIA NAO CONSUMIDOR"
	//Totalizadores
	oTotaliz:=TRFunction():New(oNfSaid:Cell("F2_VALBRUT"),Nil,"SUM",oBreak2,STR0044,"@E 999,999,999.99",/*uFormula*/,.T.,.F.)
	oTotaliz:SetCondition({ || Iif(!(cAliasSF2)->F2_TIPO$"D/B",SA1->A1_TIPO == "F",SA2->A2_TIPO == "F") })
	oTotaliz:=TRFunction():New(oNfSaid:Cell("F2_VALBRUT"),Nil,"SUM",oBreak3,STR0045,"@E 999,999,999.99",/*uFormula*/,.T.,.F.)
	oTotaliz:SetCondition({ || Iif(!(cAliasSF2)->F2_TIPO$"D/B",SA1->A1_TIPO != "F",SA2->A2_TIPO != "F") })
	oTotaliz:=TRFunction():New(oNfSaid:Cell("F2_CONTSOC"),Nil,"SUM",oBreak2,STR0046,"@E 999,999,999.99",/*uFormula*/,.T.,.F.)
	oTotaliz:SetCondition({ || Iif(!(cAliasSF2)->F2_TIPO$"D/B",SA1->A1_TIPO == "F",SA2->A2_TIPO == "F") })
	oTotaliz:=TRFunction():New(oNfSaid:Cell("F2_CONTSOC"),Nil,"SUM",oBreak3,STR0047,"@E 999,999,999.99",/*uFormula*/,.T.,.F.)
	oTotaliz:SetCondition({ || Iif(!(cAliasSF2)->F2_TIPO$"D/B",SA1->A1_TIPO != "F",SA2->A2_TIPO != "F") })
	oNfSaid:SetTotalText(STR0043)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da impressao do fluxo do relatório                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nfs Entrada         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par03 == 1 .Or. mv_par03 == 3

		oReport:SetMeter((cAliasSF1)->(LastRec()))
		dbSelectArea(cAliasSF1)
		oReport:Section(1):Init()
		oReport:PrintText(STR0041)
		oReport:SkipLine()

		While !oReport:Cancel() .And. !(cAliasSF1)->(Eof());
		.And. (cAliasSF1)->F1_EMISSAO >= mv_par01;
		.And. (cAliasSF1)->F1_EMISSAO <= mv_par02

			If !(cAliasSF1)->F1_TIPO $ "D/B"
				SA2->(dbSetOrder(1))
				SA2->(dbSeek(xFilial("SA2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
				cCnpj	:= SA2->A2_CGC
				cNome	:= SA2->A2_NOME
				cTpRur	:= Iif(at(SA2->A2_TIPORUR,"FLJ") > 0 ,aPFunRur[at(SA2->A2_TIPORUR,"FLJ")],"")
			Else                                                                                                                
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
				cCnpj 	:= SA1->A1_CGC
				cNome 	:= SA1->A1_NOME
				cTpRur	:= Iif(at(SM0->M0_PRODRUR,"FLJ") > 0 ,aPFunRur[at(SM0->M0_PRODRUR,"FLJ")],"")			     		
			Endif	

			If oReport:Cancel() 
				Exit
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Mascara para impressao - CNPJ/CPF³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If RetPessoa(cCnpj) == "J"
				oNfEntr:Cell("A2_CGC"):SetPicture("@R 99.999.999/9999-99")
			Else
				oNfEntr:Cell("A2_CGC"):SetPicture("@R 999.999.999-99")
			Endif                            

			oNfEntr:Init()
			oReport:IncMeter()
			lFirst := .T.

			If lFirst
				oNfEntr:Cell("F1_EMISSAO"):Show()
				oNfEntr:Cell("F1_DTDIGIT"):Show()
				oNfEntr:Cell("F1_DOC"):Show()
				oNfEntr:Cell("F1_SERIE"):Show()
				oNfEntr:Cell("F1_FORNECE"):Show()
				oNfEntr:Cell("F1_LOJA"):Show()
				oNfEntr:Cell("A2_NOME"):Show()
				oNfEntr:Cell("A2_TPRUR"):Show()
				oNfEntr:Cell("A2_CGC"):Show()
				oNfEntr:Cell("F1_VALBRUT"):Show()
				oNfEntr:Cell("F1_CONTSOC"):Show()
				If F1_TIPO == "D"
					oNfEntr:Cell("F1_TIPO"):Show()
				Else
					oNfEntr:Cell("F1_TIPO"):Hide()
				Endif
				lFirst := .F.
			Else
				oNfEntr:Cell("F1_EMISSAO"):Hide()
				oNfEntr:Cell("F1_DTDIGIT"):Hide()
				oNfEntr:Cell("F1_DOC"):Hide()
				oNfEntr:Cell("F1_SERIE"):Hide()
				oNfEntr:Cell("F1_FORNECE"):Hide()
				oNfEntr:Cell("F1_LOJA"):Hide()
				oNfEntr:Cell("A2_NOME"):Hide()
				oNfEntr:Cell("A2_TPRUR"):Hide()
				oNfEntr:Cell("A2_CGC"):Hide()
				oNfEntr:Cell("F1_VALBRUT"):Hide()
				oNfEntr:Cell("F1_CONTSOC"):Hide()
				oNfEntr:Cell("F1_TIPO"):Hide()
			Endif
			oNfEntr:PrintLine()
			dbSkip()
		Enddo
		oReport:Section(1):Finish()
		oNfEntr:Finish()
		oReport:SkipLine()
		oReport:ThinLine() 
		oReport:IncMeter()

		(cAliasSF1)->(DbCloseArea())
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nfs Saida           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
	If mv_par03 == 2 .Or. mv_par03 == 3

		oReport:SetMeter((cAliasSF2)->(LastRec()))
		dbSelectArea(cAliasSF2)   
		oReport:Section(2):Init()                   
		oReport:PrintText(STR0042)
		oReport:SkipLine()

		While !oReport:Cancel() .And. !(cAliasSF2)->(Eof());
		.And. (cAliasSF2)->F2_EMISSAO >= mv_par01;
		.And. (cAliasSF2)->F2_EMISSAO <= mv_par02

			If oReport:Cancel()
				Exit
			EndIf

			If (cAliasSF2)->F2_TIPO $ "D/B"
				SA2->(dbSetOrder(1))
				SA2->(dbSeek(xFilial("SA2")+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA))
				cCnpj 	:= SA2->A2_CGC
				cNome	:= SA2->A2_NOME 
				cTpRur	:= Iif(SA2->A2_TIPO != "F",STR0013,STR0014)
			Else                                                                                                       
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA))
				cCnpj 	:= SA1->A1_CGC
				cNome	:= SA1->A1_NOME
				cTpRur	:= Iif(SA1->A1_TIPO != "F",STR0013,STR0014)
			Endif	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Mascara para impressao - CNPJ/CPF³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If RetPessoa(cCnpj) == "J"
				oNfSaid:Cell("A1_CGC"):SetPicture("@R 99.999.999/9999-99")
			Else
				oNfSaid:Cell("A1_CGC"):SetPicture("@R 999.999.999-99")
			Endif                            

			oNfSaid:Init()
			oReport:IncMeter()
			lFirst := .T.

			If lFirst
				oNfSaid:Cell("F2_EMISSAO"):Show()
				oNfSaid:Cell("F2_EMISSAO"):Show()
				oNfSaid:Cell("F2_DOC"):Show()
				oNfSaid:Cell("F2_SERIE"):Show()
				oNfSaid:Cell("F2_CLIENTE"):Show()
				oNfSaid:Cell("F2_LOJA"):Show()
				oNfSaid:Cell("A1_NOME"):Show()
				oNfSaid:Cell("A1_TIPO"):Show()
				oNfSaid:Cell("A1_CGC"):Show()
				oNfSaid:Cell("F2_VALBRUT"):Show()
				oNfSaid:Cell("F2_CONTSOC"):Show()
				If F2_TIPO == "D"
					oNfSaid:Cell("F2_TIPO"):Show()
				Else
					oNfSaid:Cell("F2_TIPO"):Hide()
				Endif
				lFirst := .F.
			Else
				oNfSaid:Cell("F2_EMISSAO"):Hide()
				oNfSaid:Cell("F2_EMISSAO"):Hide()
				oNfSaid:Cell("F2_DOC"):Hide()
				oNfSaid:Cell("F2_SERIE"):Hide()
				oNfSaid:Cell("F2_CLIENTE"):Hide()
				oNfSaid:Cell("F2_LOJA"):Hide()
				oNfSaid:Cell("A1_NOME"):Hide()
				oNfSaid:Cell("A1_TIPO"):Hide()
				oNfSaid:Cell("A1_CGC"):Hide()
				oNfSaid:Cell("F2_VALBRUT"):Hide()
				oNfSaid:Cell("F2_CONTSOC"):Hide()
				oNfSaid:Cell("F2_TIPO"):Hide()
			Endif
			oNfSaid:PrintLine()
			dbSkip()
		Enddo
		oReport:Section(1):Finish()
		oNfSaid:Finish()           
		oReport:SkipLine()
		oReport:ThinLine() 
		oReport:IncMeter()               

		(cAliasSF2)->(DbCloseArea())
	Endif    

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FFM10R3 ³ Autor ³ Juan Jose Pereira     ³ Data ³ 13.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao para Contribuicao Seguridade Social                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marcos Simidu³11/02/98³XXXXXX³ Variavel nao existe - NomeProg.        ³±±
±±³ Marcos Simidu³04/11/98³XXXXXX³ Ano com 4 bytes.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FFM10R3()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local wnrel
	Local aFilsCalc := {}

	Private titulo	:= STR0001,; //"Contribui‡„o Seguridade Social - ENTRADAS"
	cDesc1  := STR0002,; //"Este programa tem como objetivo,emitir uma rela‡„o dos"
	cDesc2  := STR0003,; //"valores referentes a Contribui‡„o Seguridade Social"
	cDesc3  := "",;
	cString := "SF2",;
	nomeprog:= "MATR945",;
	cTitulo := STR0020

	Private	aReturn	:= { STR0004, 1,STR0005, 2, 2, 1, "",1 },; //"Zebrado"###"Administra‡„o"
	aLinha	:= { }  , nLastKey := 0,;
	cPerg	:= "MTR945",;
	Tamanho	:= "M"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("MTR945",.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01              Data de                                ³
	//³ mv_par02              Data Ate                               ³
	//³ mv_par03              Movimentos                             ³
	//³ mv_par04              Data de digitacao de                   ³
	//³ mv_par05              Data de digitacao ate                  ³
	//³ mv_par06              Seleciona Filiais?                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := "MATR945"
	wnrel := SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)
	If nLastKey == 27
		dbClearFilter()
		Return
	Endif

	aFilsCalc := MatFilCalc( mv_par06 == 1 )
	If Empty( aFilsCalc )
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		dbClearFilter()
		Return
	Endif

	RptStatus( { |lEnd| R945Imp( @lEnd, wnRel, cString, Tamanho, aFilsCalc ) }, cTitulo )

	dbClearFilter()

	If aReturn[5]==1
		dbCommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R945Imp  ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Relatorio.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R945Imp(lEnd,WnRel,cString,Tamanho,aFilsCalc)

	Local nTotDiaNf	:= 0,;
	nTotDiafu := 0,;
	nTotDiaNfC:= 0,;
	nTotDiaFuC:= 0,;
	nTotDiaNfn:= 0,;
	nTotDiaFun:= 0,;
	nTotEntNf := 0,;
	nTotEntFu := 0,;
	nTotSaiNfN:= 0,;
	nTotSaiFuN:= 0,;
	nTotSaiNfC:= 0,;
	nTotSaiFuC:= 0,;
	lPassa	:= .T.,;
	_nTotEmp := 0,;
	_nTotNEmp := 0,;
	_nTotEmpRur := 0,;
	_nTotNEmpRur := 0,;
	dEmissao	:= Ctod("  /  /  ")

	Local aPFunRur  := {}
	Local nPosPer   := 0
	Local cAliasSF1	:= "SF1"
	Local cAliasSF2	:= "SF2"
	Local cTipoRur  := "" 
	Local _cEMPREG  := ""
	Local lFlag     := .F.

	#IFDEF TOP
	Local cQuery	:=	""
	Local aStruSF1	:=	{}
	Local aStruSF2	:=	{}
	Local nX		:=	0
	#ELSE
	Local cIndex    :=	""
	Local cCondicao :=	""
	#ENDIF

	Local nForFilial
	Local cFilBack := cFilAnt

	Private cbtxt  	:= SPACE(10)
	Private cbcont 	:= 00
	Private li     	:= 80
	Private m_pag  	:= 01   


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta os Cabecalhos                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := STR0006 //"DATA       DATA       NF/SERIE    CODIGO    NOME               PERC.DA      CNPJ                  VALOR TOTAL    VALOR CONTR.  DEV."	
	cabec2 := STR0007 //"EMISSAO    CONTABIL               CLI/FOR  CLIENTE/FORNECEDOR    OPERACAO                             NOTA FISCAL      SEGUR.SOCIAL"

	nTipo:=IIF(aReturn[4]==1,15,18)

	For nForFilial := 1 to Len( aFilsCalc )

		If aFilsCalc[ nForFilial, 1 ]

			cFilAnt := aFilsCalc[ nForFilial, 2 ] 
			titulo	:= STR0001 + Space(01) + STR0050 + cFilAnt //"Contribui‡„o Seguridade Social - ENTRADAS" + "- Filial "

			If mv_par03 == 1 // Notas Fiscais de Entrada
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria Indice de Trabalho       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SF1")
				dbSetOrder(1)
				ProcRegua(LastRec())

				#IFDEF TOP
				If TcSrvType()<>"AS/400"
					lQuery 		:= .T.
					cAliasSF1	:= "SF1_MTR945"
					aStruSF1	:= SF1->(dbStruct())
					cQuery		:= "SELECT SF1.F1_FILIAL, SF1.F1_EMISSAO, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_DTDIGIT,  "
					cQuery		+= "SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_VALBRUT, SF1.F1_VALMERC, SF1.F1_CONTSOC, SF1.F1_TIPO "
					cQuery 		+= "FROM " + RetSqlName("SF1") + " SF1 "
					cQuery 		+= "WHERE SF1.F1_FILIAL = '" + xFilial("SF1") + "' AND "
					cQuery 		+= "SF1.F1_EMISSAO >= '" + Dtos(mv_par01) + "' AND "
					cQuery 		+= "SF1.F1_EMISSAO <= '" + Dtos(mv_par02) + "' AND "
					cQuery 		+= "SF1.F1_CONTSOC > 0 AND "
					cQuery		+= "SF1.D_E_L_E_T_ = ' ' "
					If !Empty(mv_par04) .And. !Empty(mv_par05)
						cQuery 		+= " AND SF1.F1_DTDIGIT >= '" + Dtos(mv_par04) + "' "
						cQuery 		+= " AND SF1.F1_DTDIGIT <= '" + Dtos(mv_par05) + "' "
					Endif
					cQuery 		+= "ORDER BY " + SqlOrder(SF1->(IndexKey()))
					cQuery 		:= ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF1)
					For nX := 1 To len(aStruSF1)
						If aStruSF1[nX][2] <> "C" .And. FieldPos(aStruSF1[nX][1])<>0
							TcSetField(cAliasSF1,aStruSF1[nX][1],aStruSF1[nX][2],aStruSF1[nX][3],aStruSF1[nX][4])
						EndIf
					Next nX
					dbSelectArea(cAliasSF1)	
				Else
					#ENDIF
					cIndex    		:= CriaTrab(NIL,.F.)
					cCondicao 		:= 'F1_FILIAL == "' + xFilial("SF1") + '" .And. '
					cCondicao 		+= 'DTOS(F1_EMISSAO) >= "' + DTOS(mv_par01) + '" .And. DTOS(F1_EMISSAO) <= "' + DTOS(mv_par02) + '" .And. '
					cCondicao 		+= 'F1_CONTSOC > 0 '
					If !Empty(mv_par04) .And. !Empty(mv_par05)
						cCondicao 	+= ' .And. DTOS(F1_DTDIGIT) >="'+DTOS(mv_par04)+'"'
						cCondicao 	+= ' .And. DTOS(F1_DTDIGIT) <="'+DTOS(mv_par05)+'"'
					EndIf	                                                        
					IndRegua(cAliasSF1,cIndex,SF1->(IndexKey()),,cCondicao)
					dbSelectArea(cAliasSF1)
					ProcRegua(LastRec())
					dbGoTop()
					#IFDEF TOP
				Endif
				#ENDIF          

			ElseIf mv_par03 == 2 // Notas Fiscais de Saida
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria Indice de Trabalho       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SF2")
				dbSetOrder(1)
				ProcRegua(LastRec())

				#IFDEF TOP
				If TcSrvType()<>"AS/400"
					lQuery 		:= .T.
					cAliasSF2	:= "SF2_MATR945"
					aStruSF2	:= SF2->(dbStruct())
					cQuery		:= "SELECT SF2.F2_FILIAL, SF2.F2_EMISSAO, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_TIPO, "
					cQuery		+= "SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_VALBRUT, SF2.F2_VALMERC, SF2.F2_CONTSOC "
					cQuery 		+= "FROM " + RetSqlName("SF2") + " SF2 "
					cQuery 		+= "WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
					cQuery 		+= "SF2.F2_EMISSAO >= '" + Dtos(mv_par01) + "' AND "
					cQuery 		+= "SF2.F2_EMISSAO <= '" + Dtos(mv_par02) + "' AND "
					cQuery 		+= "SF2.F2_CONTSOC > 0 AND "
					cQuery		+= "SF2.D_E_L_E_T_ = ' ' "
					cQuery 		+= "ORDER BY " + SqlOrder(SF2->(IndexKey()))
					cQuery 		:= ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2)
					For nX := 1 To len(aStruSF2)
						If aStruSF2[nX][2] <> "C" .And. FieldPos(aStruSF2[nX][1])<>0
							TcSetField(cAliasSF2,aStruSF2[nX][1],aStruSF2[nX][2],aStruSF2[nX][3],aStruSF2[nX][4])
						EndIf
					Next nX
					dbSelectArea(cAliasSF2)	
				Else
					#ENDIF
					cIndex    		:= CriaTrab(NIL,.F.)
					cCondicao 		:= 'F2_FILIAL == "' + xFilial("SF2") + '" .And. '
					cCondicao 		+= 'DTOS(F2_EMISSAO) >= "' + DTOS(mv_par01) + '" .And. DTOS(F2_EMISSAO) <= "' + DTOS(mv_par02) + '" .And. '
					cCondicao 		+= 'F2_CONTSOC > 0 '
					IndRegua(cAliasSF2,cIndex,SF2->(IndexKey()),,cCondicao)
					dbSelectArea(cAliasSF2)
					ProcRegua(LastRec())
					dbGoTop()
					#IFDEF TOP
				Endif
				#ENDIF

			Else // // Notas Fiscais de Entrada e Saida
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria Indice de Trabalho       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SF1")
				dbSetOrder(1)
				ProcRegua(LastRec())

				#IFDEF TOP
				If TcSrvType()<>"AS/400"
					lQuery 		:= .T.
					cAliasSF1	:= "SF1_MTR945"
					aStruSF1	:= SF1->(dbStruct())
					cQuery		:= "SELECT SF1.F1_FILIAL, SF1.F1_EMISSAO, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_DTDIGIT,  "
					cQuery		+= "SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_VALBRUT, SF1.F1_VALMERC, SF1.F1_CONTSOC, SF1.F1_TIPO "
					cQuery 		+= "FROM " + RetSqlName("SF1") + " SF1 "
					cQuery 		+= "WHERE SF1.F1_FILIAL = '" + xFilial("SF1") + "' AND "
					cQuery 		+= "SF1.F1_EMISSAO >= '" + Dtos(mv_par01) + "' AND "
					cQuery 		+= "SF1.F1_EMISSAO <= '" + Dtos(mv_par02) + "' AND "
					cQuery 		+= "SF1.F1_CONTSOC > 0 AND "
					cQuery		+= "SF1.D_E_L_E_T_ = ' ' "
					If !Empty(mv_par04) .And. !Empty(mv_par05)
						cQuery 		+= " AND SF1.F1_DTDIGIT >= '" + Dtos(mv_par04) + "' "
						cQuery 		+= " AND SF1.F1_DTDIGIT <= '" + Dtos(mv_par05) + "' "
					Endif
					cQuery 		+= "ORDER BY " + SqlOrder(SF1->(IndexKey()))
					cQuery 		:= ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF1)
					For nX := 1 To len(aStruSF1)
						If aStruSF1[nX][2] <> "C" .And. FieldPos(aStruSF1[nX][1])<>0
							TcSetField(cAliasSF1,aStruSF1[nX][1],aStruSF1[nX][2],aStruSF1[nX][3],aStruSF1[nX][4])
						EndIf
					Next nX
					dbSelectArea(cAliasSF1)	
				Else
					#ENDIF
					cIndex    		:= CriaTrab(NIL,.F.)
					cCondicao 		:= 'F1_FILIAL == "' + xFilial("SF1") + '" .And. '
					cCondicao 		+= 'DTOS(F1_EMISSAO) >= "' + DTOS(mv_par01) + '" .And. DTOS(F1_EMISSAO) <= "' + DTOS(mv_par02) + '" .And. '
					cCondicao 		+= 'F1_CONTSOC > 0 '
					If !Empty(mv_par04) .And. !Empty(mv_par05)
						cCondicao 	+= ' .And. DTOS(F1_DTDIGIT) >="'+DTOS(mv_par04)+'"'
						cCondicao 	+= ' .And. DTOS(F1_DTDIGIT) <="'+DTOS(mv_par05)+'"'
					EndIf	                                                        
					IndRegua(cAliasSF1,cIndex,SF1->(IndexKey()),,cCondicao)
					dbSelectArea(cAliasSF1)
					ProcRegua(LastRec())
					dbGoTop()
					#IFDEF TOP
				Endif
				#ENDIF

				dbSelectArea("SF2")
				dbSetOrder(1)
				ProcRegua(LastRec())

				#IFDEF TOP
				If TcSrvType()<>"AS/400"
					lQuery 		:= .T.
					cAliasSF2	:= "SF2_MTR945"
					aStruSF2	:= SF2->(dbStruct())
					cQuery		:= "SELECT SF2.F2_FILIAL, SF2.F2_EMISSAO, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_TIPO, "
					cQuery		+= "SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_VALBRUT, SF2.F2_VALMERC, SF2.F2_CONTSOC "
					cQuery 		+= "FROM " + RetSqlName("SF2") + " SF2 "
					cQuery 		+= "WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
					cQuery 		+= "SF2.F2_EMISSAO >= '" + Dtos(mv_par01) + "' AND "
					cQuery 		+= "SF2.F2_EMISSAO <= '" + Dtos(mv_par02) + "' AND "
					cQuery 		+= "SF2.F2_CONTSOC > 0 AND "
					cQuery		+= "SF2.D_E_L_E_T_ = ' ' "
					cQuery 		+= "ORDER BY " + SqlOrder(SF2->(IndexKey()))
					cQuery 		:= ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2)
					For nX := 1 To len(aStruSF2)
						If aStruSF2[nX][2] <> "C" .And. FieldPos(aStruSF2[nX][1])<>0
							TcSetField(cAliasSF2,aStruSF2[nX][1],aStruSF2[nX][2],aStruSF2[nX][3],aStruSF2[nX][4])
						EndIf
					Next nX
					dbSelectArea(cAliasSF2)
				Else
					#ENDIF
					cIndex    		:= CriaTrab(NIL,.F.)
					cCondicao 		:= 'F2_FILIAL == "' + xFilial("SF2") + '" .And. '
					cCondicao 		+= 'DTOS(F2_EMISSAO) >= "' + DTOS(mv_par01) + '" .And. DTOS(F2_EMISSAO) <= "' + DTOS(mv_par02) + '" .And. '
					cCondicao 		+= 'F2_CONTSOC > 0 '
					IndRegua(cAliasSF2,cIndex,SF2->(IndexKey()),,cCondicao)
					dbSelectArea(cAliasSF2)
					ProcRegua(LastRec())
					dbGoTop()
					#IFDEF TOP
				Endif
				#ENDIF
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Arquivos e seleciona Ordens.                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA2")
			dbSetOrder(1)

			dbSelectArea("SA1")
			dbSetOrder(1)

			dbSelectArea(cAliasSF1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Variaveis da regua.                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTamReg:=(mv_par02-mv_par01)*2
			nTamReg:=IIf(nTamReg>0,nTamReg,2)
			SetRegua(nTamReg)
			nDiaAnt:=mv_par01

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nfs Entrada         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While !((cAliasSF1)->(Eof())) .And. (cAliasSF1)->F1_FILIAL == xFilial("SF1") .And. (cAliasSF1)->F1_EMISSAO >= mv_par01 .And. (cAliasSF1)->F1_EMISSAO <= mv_par02 .And. mv_par03 != 2

				IncRegua()

				If Interrupcao(@lEnd)
					Exit
				EndIf

				If nDiaAnt<> (cAliasSF1)->F1_EMISSAO
					nDiaAnt:= (cAliasSF1)->F1_EMISSAO
				Endif

				Somalinha(0)

				@ li,000 PSAY (cAliasSF1)->F1_EMISSAO
				@ li,011 PSAY (cAliasSF1)->F1_DTDIGIT
				@ li,022 PSAY alltrim((cAliasSF1)->F1_DOC) + "/" + alltrim((cAliasSF1)->F1_SERIE)
				@ li,034 PSAY (cAliasSF1)->F1_FORNECE + " " + (cAliasSF1)->F1_LOJA

				If (cAliasSF1)->F1_TIPO$"D/B"
					dbSelectArea("SA1")
					dbSeek(xFilial()+(cAliasSF1)->F1_FORNECE + (cAliasSF1)->F1_LOJA)
				Else
					dbSelectArea("SA2")
					dbSeek(xFilial()+(cAliasSF1)->F1_FORNECE + (cAliasSF1)->F1_LOJA)  
					_cPosEmp := SA2->A2_POSEMP
				End If

				@ li,044 PSAY Iif((cAliasSF1)->F1_TIPO$"D/B",Substr(SA1->A1_NOME,1,20),Substr(SA2->A2_NOME,1,20))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
				//³Retorna a aliquota do FunRural³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
				cTipoRur :=SA2->A2_TIPORUR 
				aPFunRur := FunRur() 

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³aPFunRur[1]  == "F"³
				//³aPFunRur[2]  == "L"³
				//³aPFunRur[3]  == "J"³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				nPosPer  := at(cTipoRur,"FLJ")

				// Inicio Bloco Alterado por Fabian Maurer para inserir a porcentagem de desconto do Funrural
				@ li,066 PSAY Iif(_cPosEmp <> '2','0.2','2.3')   //Iif(nPosPer > 0 ,aPFunRur[nPosPer],"")
				// Final do bloco feito por Fabian Maurerpara inserir a porcentagem de desconto do Funrural

				@ li,077 PSAY Iif((cAliasSF1)->F1_TIPO$"D/B",Transform(SA1->A1_CGC,PicPesFJ(IIF(Len(alltrim(SA1->A1_CGC))<14,"F","J"))),Transform(SA2->A2_CGC,PicPesFJ(IIF(Len(alltrim(SA2->A2_CGC))<14,"F","J"))))	
				@ li,096 PSAY (cAliasSF1)->F1_VALBRUT PICTURE "@E 999,999,999.99" 
				@ li,110 PSAY (cAliasSF1)->F1_CONTSOC PICTURE "@E 999,999,999.99" 
				@ li,129 PSAY Iif((cAliasSF1)->F1_TIPO == "D","D","")

				Somalinha()

				dbSelectArea(cAliasSF1)

				nTotDiaNf	+= (cAliasSF1)->F1_VALBRUT
				nTotDiaFu	+= (cAliasSF1)->F1_CONTSOC
				nTotEntNf	+= (cAliasSF1)->F1_VALBRUT
				nTotEntFu	+= (cAliasSF1)->F1_CONTSOC
				dEmissao	:= (cAliasSF1)->F1_EMISSAO
				// Inicio do bloco feito por Fabian Maurer que aglutina valores de notas conforme for o cadastro (Empregador/ Não empregador)
				if _cPosEmp == '2' //Se caso ele nao possui empregado calcula 2.3
					_nTotNEmp += (cAliasSF1)->F1_VALBRUT	
				endif  
				if _cPosEmp <> '2' // se caso ele possui empregado calcula 0.2
					_nTotEmp += (cAliasSF1)->F1_VALBRUT
				endif
				if _cPosEmp == '2' // Calcula funrural para 2.3 não possui empregado
					_nTotNEmpRur += (cAliasSF1)->F1_CONTSOC	
				endif  
				if _cPosEmp <> '2' // Calcula funrural para 0.2 possui empregado
					_nTotEmpRur += (cAliasSF1)->F1_CONTSOC
				endif
				// Fim do bloco feito por Fabian Maurer que aglutina por tipo de fornecedor
				(cAliasSF1)->(dbSkip())

				If dEmissao != (cAliasSF1)->F1_EMISSAO
					Somalinha()
					@ li,000 PSAY STR0009 //"TOTAL DO DIA....................................................................................."
					@ li,096 PSAY nTotDiaNf PICTURE "@E 999,999,999.99"
					@ li,110 PSAY nTotDiaFu PICTURE "@E 999,999,999.99"
					Somalinha(2)
					nTotDiaNf:=0
					nTotDiaFu:=0
				Endif
				lFlag := .T.
			Enddo

			titulo	:= STR0010 //"Contribuicao Seguridade Social - SAIDAS"
			cabec1	:= STR0011 //"DATA       DATA       NF/SERIE    CODIGO   NOME                  TIPO DO           C.G.C.             VALOR TOTAL      VALOR CONTR."
			cabec2	:= STR0012 //"EMISSAO    CONTABIL               CLI/FOR  CLIENTE/FORNECEDOR    CLIENTE                              NOTA FISCAL      SEGUR.SOCIAL"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nfs Saida           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			dbSelectArea(cAliasSF2)

			While !((cAliasSF2)->(Eof())) .And. (cAliasSF2)->F2_FILIAL == xFilial("SF2") .And. (cAliasSF2)->F2_EMISSAO >= mv_par01 .And. (cAliasSF2)->F2_EMISSAO <= mv_par02 .And. mv_par03 != 1 .and. !lEnd

				IncRegua()
				If Interrupcao(@lEnd)
					Exit
				Endif

				If nDiaAnt<>(cAliasSF2)->F2_EMISSAO
					nDiaAnt:=(cAliasSF2)->F2_EMISSAO
				Endif

				If lPassa
					li := 80
					lPassa := .F.
				Endif

				If (cAliasSF2)->F2_TIPO$"D/B"
					dbSelectArea("SA2")
					dbSeek(xFilial()+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
				Else
					dbSelectArea("SA1")
					dbSeek(xFilial()+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
				End If

				Somalinha(0)

				@ li,000 PSAY (cAliasSF2)->F2_EMISSAO
				@ li,011 PSAY (cAliasSF2)->F2_EMISSAO
				@ li,022 PSAY (cAliasSF2)->F2_DOC + "/" + (cAliasSF2)->F2_SERIE
				@ li,034 PSAY (cAliasSF2)->F2_CLIENTE + " " + (cAliasSF2)->F2_LOJA

				@ li,044 PSAY Iif ((cAliasSF2)->F2_TIPO$"D/B", Substr(SA2->A2_NOME,1,20),Substr(SA1->A1_NOME,1,20))

				@ li,066 PSAY Iif(SA1->A1_TIPO != "F",STR0013,STR0014) //"Nao Cons."###"Consum."
				@ li,077 PSAY Iif((cAliasSF2)->F2_TIPO$"D/B",Transform(SA2->A2_CGC,PicPesFJ(IIF(Len(alltrim(SA2->A2_CGC))<14,"F","J"))),Transform(SA1->A1_CGC,PicPesFJ(IIF(Len(alltrim(SA1->A1_CGC))<14,"F","J"))))	
				@ li,096 PSAY (cAliasSF2)->F2_VALBRUT PICTURE "@E 999,999,999.99"
				@ li,110 PSAY (cAliasSF2)->F2_CONTSOC PICTURE "@E 999,999,999.99"
				@ li,129 PSAY Iif((cAliasSF2)->F2_TIPO == "D","D","")

				Somalinha()
				dbSelectArea(cAliasSF2)

				If SA1->A1_TIPO != "F"
					nTotDiaNfN	+= (cAliasSF2)->F2_VALBRUT     // totais Nao Consumidor
					nTotDiaFuN	+= (cAliasSF2)->F2_CONTSOC
					nTotSaiNfN	+= (cAliasSF2)->F2_VALBRUT
					nTotSaiFuN	+= (cAliasSF2)->F2_CONTSOC
					dEmissao	:= (cAliasSF2)->F2_EMISSAO
				Else
					nTotDiaNfC	+= (cAliasSF2)->F2_VALBRUT      //totais Consumidor
					nTotDiaFuC	+= (cAliasSF2)->F2_CONTSOC
					nTotSaiNfC	+= (cAliasSF2)->F2_VALBRUT
					nTotSaiFuC	+= (cAliasSF2)->F2_CONTSOC
					dEmissao	:= (cAliasSF2)->F2_EMISSAO
				Endif

				(cAliasSF2)->(dbSkip())

				If dEmissao != (cAliasSF2)->F2_EMISSAO
					Somalinha()
					@ li,000 PSAY STR0015 //"TOTAL DO DIA CONSUMIDOR.........................................................................."
					@ li,096 PSAY nTotDiaNfC PICTURE "@E 999,999,999.99"
					@ li,110 PSAY nTotDiaFuC PICTURE "@E 999,999,999.99"
					Somalinha()
					nTotDiaNfC:=0
					nTotDiaFuC:=0
					@ li,000 PSAY STR0016 //"TOTAL DO DIA NAO CONSUMIDOR......................................................................"
					@ li,096 PSAY nTotDiaNfN PICTURE "@E 999,999,999.99"
					@ li,110 PSAY nTotDiaFuN PICTURE "@E 999,999,999.99"
					Somalinha(2)
					nTotDiaNfN:=0
					nTotDiaFuN:=0
				Endif
				lFlag:= .T.
			Enddo

			If !lEnd  .And. lFlag

				If MV_PAR03 # 2

					// Inicio do bloco feito por Fabian Maurer que imprime os valores de entradas conforme o tipo de cliente	
					Somalinha()
					@ li,000 PSAY 				'TOTAL GERAL ENTRADAS EMPREGADORES..............................................................'	
					@ li,096 PSAY _nTotEmp PICTURE "@E 999,999,999.99"
					@ li,110 PSAY _nTotEmpRur PICTURE "@E 999,999,999.99"
					Somalinha()
					Somalinha()
					@ li,000 PSAY 				'TOTAL GERAL ENTRADAS NÃO EMPREGADORES..........................................................'
					@ li,096 PSAY _nTotNEmp PICTURE "@E 999,999,999.99"
					@ li,110 PSAY _nTotNEmpRur PICTURE "@E 999,999,999.99"
					Somalinha()
					Somalinha()
					// Fim do bloco feito por Fabian Maurer que imrpime os valores de entradas	conforme o tipo de cliente

					@ li,000 PSAY STR0017 //"TOTAL GERAL ENTRADAS............................................................................."
					@ li,096 PSAY nTotEntNf PICTURE "@E 999,999,999.99"
					@ li,110 PSAY nTotEntFu PICTURE "@E 999,999,999.99"
					Somalinha()

				Endif

				If MV_PAR03 # 1
					Somalinha()
					@ li,000 PSAY STR0018 //"TOTAL GERAL SAIDAS CONSUMIDOR...................................................................."
					@ li,096 PSAY nTotSaiNfC PICTURE "@E 999,999,999.99"
					@ li,110 PSAY nTotSaiFuC PICTURE "@E 999,999,999.99"
					Somalinha()
					@ li,000 PSAY STR0019 //"TOTAL GERAL SAIDAS NAO CONSUMIDOR................................................................."
					@ li,096 PSAY nTotSaiNfN PICTURE "@E 999,999,999.99"
					@ li,110 PSAY nTotSaiFuN PICTURE "@E 999,999,999.99"
					Somalinha()
				Endif

			Endif


			If Li != 80 .And. !lEnd .And. lFlag
				roda(cbcont,cbtxt,Tamanho)
			EndIF


			If lFlag
				Li  := 80 //Quebra pagina por filial
				lFlag := .F.
			Endif

			dbSelectArea("SB1")
			dbSetOrder(1)

			// Zera os totalizadores para ser utilizado na proxima filial			
			nTotEntNf  := 0
			nTotEntFu  := 0
			nTotSaiNfC := 0
			nTotSaiFuC := 0
			nTotSaiNfN := 0
			nTotSaiFuN := 0			

			If mv_par03 == 1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Excluindo as areas de trabalho SF1 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lQuery
					dbSelectArea(cAliasSF1)
					dbCloseArea()
				Else
					dbSelectArea("SF1")
					RetIndex("SF1")
					dbClearFilter()
					Ferase(cIndex+OrdBagExt())
				Endif	
			ElseIf mv_par03 == 2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Excluindo as areas de trabalho SF2 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lQuery
					dbSelectArea(cAliasSF2)
					dbCloseArea()
				Else
					dbSelectArea("SF2")
					RetIndex("SF2")
					dbClearFilter()
					Ferase(cIndex+OrdBagExt())
				Endif	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Excluindo as areas de trabalho SF1/SF2   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lQuery
					dbSelectArea(cAliasSF1)
					dbCloseArea()
					dbSelectArea(cAliasSF2)
					dbCloseArea()
				Else
					dbSelectArea("SF1")
					RetIndex("SF1")
					dbClearFilter()
					Ferase(cIndex+OrdBagExt())
					dbSelectArea("SF2")
					RetIndex("SF2")
					dbClearFilter()
					Ferase(cIndex+OrdBagExt())
				Endif
			Endif
		Endif	
	Next nForFilial

	// Restaura a filial corrente
	cFilAnt := cFilBack	

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ SomaLinha ³ Autor ³ Luciana Pires        ³ Data ³ 03/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Incrementa linha e controla quebra de pagina               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Somalinha(nInc)

	DEFAULT nInc := 1

	Li	+=	nInc
	If Li > 58
		Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
	EndIf

Return
