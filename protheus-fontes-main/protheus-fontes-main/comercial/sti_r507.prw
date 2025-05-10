#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} STI_R507
Relatório em EXCEL contendo informações apresentadas na tela de consulta da consulta de caixas. (GJF40)
@author 	Evandro Mugnol
@since 		Dez/2018
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_R507()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variáveis utilizadas para gerar em Excel                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DO CASE
		CASE MV_PAR01 == 1
			_cTpArm := "RESFRIADO"
		CASE MV_PAR01 == 2
			_cTpArm := "CONGELADO"
		CASE MV_PAR01 == 3
			_cTpArm := "SALGADO"
		CASE MV_PAR01 == 4
			_cTpArm := "TODOS"
	ENDCASE

	_cNomArq := "ESTOQUE_" + _cTpArm + "_EM_" + SUBSTR(dtos(ddatabase),1,4) + "-" + SUBSTR(dtos(ddatabase),5,2) + "-" + SUBSTR(dtos(ddatabase),7,2) + "_AS_" + SUBSTR(Time(),1,2) + "-" + SUBSTR(Time(),4,2) + "_POR_" + Alltrim(cUserName)
	_aCabec	 := {}
	_aDados	 := {}

	If AllTrim(FunName()) == "GJF40"
		RptStatus({|| RptDetail()})
	Else
		MsgAlert("Esta geração em Excel somente pode ser executada pela rotina GJF40 devido aos critérios de geração.")
	Endif

Return


Static Function RptDetail()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totalizadores                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nTotCPrev := 0
	_nTotPPrev := 0
	_nTotCProd := 0
	_nTotPProd := 0
	_nTotCEst  := 0
	_nTotPEst  := 0
	_nTotCCar  := 0
	_nTotPCar  := 0
	_nTotCEmp  := 0
	_nTotPEmp  := 0
	_nTotCSal  := 0
	_nTotPSal  := 0

	DbSelectArea("TMP")
	DbGoTop()
	Do While ! TMP -> (Eof ())

		_nTotCPrev += TMP->C_PREV
		_nTotPPrev += TMP->P_PREV
		_nTotCProd += TMP->C_PROD
		_nTotPProd += TMP->P_PROD
		_nTotCEst  += TMP->C_EST
		_nTotPEst  += TMP->P_EST
		_nTotCCar  += TMP->C_CAR
		_nTotPCar  += TMP->P_CAR
		_nTotCEmp  += TMP->C_EMP
		_nTotPEmp  += TMP->P_EMP
		_nTotCSal  += TMP->C_SAL
		_nTotPSal  += TMP->P_SAL

		AADD(_aDados, { TMP->CODIGO		,;
						TMP->DESCRI		,;
						TMP->C_PREV		,;
						TMP->P_PREV		,;
						TMP->C_PROD		,;
						TMP->P_PROD		,;
						TMP->C_EST 		,;
						TMP->P_EST 		,;
						TMP->C_CAR 		,;
						TMP->P_CAR 		,;
						TMP->C_EMP 		,;
						TMP->P_EMP 		,;
						TMP->C_SAL 		,;
						TMP->P_SAL 		})

		TMP->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 
	EndDo

	AADD(_aDados, { ""         			,;
					"T O T A I S  ==> "	,;
					_nTotCPrev			,;
					_nTotPPrev			,;
					_nTotCProd			,;
					_nTotPProd			,;
					_nTotCEst 			,;
					_nTotPEst 			,;
					_nTotCCar 			,;
					_nTotPCar 			,;
					_nTotCEmp 			,;
					_nTotPEmp 			,;
					_nTotCSal 			,;
					_nTotPSal 			})


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := "                                                                      P R E V I S Ã O     |    P R O D U Ç Ã O     |      E S T O Q U E     |      CARREGAMENTO      |      E M P E N H O     |        S A L D O    "
	cabec2 := "P  R  O  D  U  T  O                                                  CAIXAS        PESO   |   CAIXAS        PESO   |   CAIXAS        PESO   |   CAIXAS        PESO   |   CAIXAS        PESO   |   CAIXAS        PESO"
	//***      XXXXXX X----------------------------------------------------------X XXX.XXX  XXX.XXX,XX      XXX.XXX  XXX.XXX,XX      XXX.XXX  XXX.XXX,XX      XXX.XXX  XXX.XXX,XX      XXX.XXX  XXX.XXX,XX      XXX.XXX  XXX.XXX,XX               
	//***                1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
	//***      012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

	If Len(_aDados) > 0
		AADD( _aCabec, {"PRODUTO",				"C", 02, 0} )
		AADD( _aCabec, {"DESCRICAO",			"C", 10, 0} )
		AADD( _aCabec, {"PREVISAO CAIXAS",		"N", 09, 0} )
		AADD( _aCabec, {"PREVISAO PESO",		"N", 12, 2} )
		AADD( _aCabec, {"PRODUCAO CAIXAS",		"N", 09, 0} )
		AADD( _aCabec, {"PRODUCAO PESO",		"N", 12, 2} )
		AADD( _aCabec, {"ESTOQUE CAIXAS",		"N", 09, 0} )
		AADD( _aCabec, {"ESTOQUE PESO",			"N", 12, 2} )
		AADD( _aCabec, {"CARREGAMENTO CAIXAS",	"N", 09, 0} )
		AADD( _aCabec, {"CARREGAMENTO PESO",	"N", 12, 2} )
		AADD( _aCabec, {"EMPENHO CAIXAS",		"N", 09, 0} )
		AADD( _aCabec, {"EMPENHO PESO",			"N", 12, 2} )
		AADD( _aCabec, {"SALDO CAIXAS",			"N", 09, 0} )
		AADD( _aCabec, {"SALDO PESO",			"N", 12, 2} )
		U_GERAEXCEL(_cNomArq, _aDados, _aCabec, .T.)
	Endif

	// Força posicionamento no início do arquivo temporário
	DbSelectArea("TMP")
	DbGoTop()

Return
