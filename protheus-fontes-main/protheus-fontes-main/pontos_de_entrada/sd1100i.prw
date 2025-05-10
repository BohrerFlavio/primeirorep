#INCLUDE "rwmake.ch"

User Function SD1100I()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ SD1100I  º Autor ³ Mario Zimmermann   º Data ³ 30.06.2004  º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Ponto de Entrada que e executado apos a atualizacao da     º±±
	±±º          ³ tabela SD1 na nota fiscal de entrada.                      º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Especifico para Clientes Microsiga                         º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	_xAlias := { Alias(), IndexOrd(), RecNo()}

	DbSelectArea("SF4")
	_xAliasSf4 := { Alias(), IndexOrd(), RecNo()}

	DbSelectArea("SB1")
	_xAliasSb1 := { Alias(), IndexOrd(), RecNo()}

	DbSelectArea("SD1")
	_xAliasSd1 := { Alias(), IndexOrd(), RecNo()}

	DbSelectArea("SF8")
	_xAliasSf8 := { Alias(), IndexOrd(), RecNo()}

	_nIcm 		:= 0
	_nIpi 		:= 0
	_nSQADIC	:=0   
	_cSQADIC	:=""
	If SD1->D1_TIPO == "N"
		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek(xFilial("SF4")+SD1->D1_TES)
		If Found() .And. (Empty(SF4->F4_UPRC) .Or. SF4->F4_UPRC == "S")
			If SF4->F4_CREDICM =="S"
				_nIcm := SD1->D1_VALICM
			Endif
			If SF4->F4_CREDIPI =="N"
				_nIpi := SD1->D1_VALIPI
			Endif

			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+SD1->D1_COD)
			If Found()
				Reclock("SB1",.F.)
				Replace B1_CUSTD  With Round(SD1->D1_CUSTO / SD1->D1_QUANT, 5)
				Replace B1_DATREF With dDataBase
				Replace B1_MCUSTD With "1"
				MsUnLock()
			EndIf
		EndIf
	ElseIf SD1->D1_TIPO == "C"
		// Poderia ser colocado uma rotina para calculo do custo se for conhecimento de frete, 
		// mas optamos em fazer no ponto de entrada MT116AGR (Logo apos o lancamento do conhecimento do grete)
	EndIf

	DbSelectArea(_xAliasSb1[1])
	DbSetOrder(_xAliasSb1[2])
	DBGoto(_xAliasSb1[3])

	DbSelectArea(_xAliasSd1[1])
	DbSetOrder(_xAliasSd1[2])
	DBGoto(_xAliasSd1[3])

	DbSelectArea(_xAliasSf4[1])
	DbSetOrder(_xAliasSf4[2])
	DBGoto(_xAliasSf4[3])

	DbSelectArea(_xAliasSf8[1])
	DbSetOrder(_xAliasSf8[2])
	DBGoto(_xAliasSf8[3])

	DbSelectArea(_xAlias[1])
	DbSetOrder(_xAlias[2])
	DBGoto(_xAlias[3])


	//Bloco desenvolvido para inserção de registros na tabela CD5 - Complemento de Importação
	//seus registros são necessários para a geração da NF-e de entrada para importação.
	//conforme validação requerida pelo SEFAZ.          
	//O Giuliano fez esse bagulho e conseguiu esquecer. Depois fica procurando feito um retardado...
	_nSQADIC := val(SD1->D1_ITEM)  
	_cSQADIC := str(_nSQADIC)
	SC7->(DbSetOrder(1))
	if SC7->(DbSeek(xfilial('SC7')+SD1->(D1_PEDIDO+D1_ITEMPC)))
		if SC7->C7_EXPORT = 'EX'
			reclock('CD5',.t.)
			CD5->CD5_FILIAL    := xfilial('CD5')
			CD5->CD5_DOC       := SD1->D1_DOC
			CD5->CD5_SERIE     := SD1->D1_SERIE
			CD5->CD5_FORNEC    := SD1->D1_FORNECE
			CD5->CD5_LOJA      := SD1->D1_LOJA
			CD5->CD5_ITEM      := SD1->D1_ITEM
			CD5->CD5_NDI       := SC7->C7_NDI         //Numero do documento de importação
			CD5->CD5_DTDI      := SC7->C7_DDI         //Data do documento de importação
			CD5->CD5_LOCDES    := SC7->C7_LOCDES      //Local de desembarque
			CD5->CD5_UFDES     := SC7->C7_UFDESEM     //UF de desembarque
			CD5->CD5_DTDES     := SC7->C7_DTDES       //Data de desembarque
			CD5->CD5_CODEXP    := SC7->C7_EXPORT      //Codigo do exportador  
			CD5->CD5_VTRANS    := '7'  //1 - Maritimo 2 - fluvial 3 - Lacustre 4 - Aereo  5 - Postal 6 - Ferroviario 7 - Rodoviario 8 - Conduto 9 - Meio proprio 10 - entrada/saida
			CD5->CD5_INTERM    := '1'  //1 - Por conta propria 2 - por conta e ordem 3 - por encomenda 
			CD5->CD5_NADIC     := '1'   
			CD5->CD5_SQADIC    := alltrim(_cSQADIC)
			CD5->CD5_CODFAB    := SD1->D1_FORNECE
			CD5->CD5_BCIMP     := SD1->D1_TOTAL
			CD5->CD5_DSPAD     := 0
			CD5->CD5_VLRII     := 0
			CD5->CD5_VLRIOF    := 0
			CD5->CD5_BSPIS	    := SD1->D1_BASIMP6
			CD5->CD5_ALPIS		 := 1.65
			CD5->CD5_VLPIS		 := SD1->D1_VALIMP6
			CD5->CD5_BSCOF		 := SD1->D1_BASIMP5
			CD5->CD5_ALCOF		 := 7.60
			CD5->CD5_VLCOF		 := SD1->D1_VALIMP5
			CD5->CD5_DTPPIS	 := SC7->C7_DDI       //Data do documento de importação
			CD5->CD5_DTPCOF	 := SC7->C7_DDI       //Data do documento de importação
			msunlock()
		endif
	endif

	//Fim do bloco para Complemento de Importação


	//Função para workflow no recebimento de materiais
	u_gjf61()

Return

