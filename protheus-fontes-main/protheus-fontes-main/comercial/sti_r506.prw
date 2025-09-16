#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} STI_R506
Relatório contendo informações apresentadas na tela de consulta da consulta de caixas. (GJF40)
@author 	Evandro Mugnol
@since 		Dez/2018
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_R506()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString  := "SB1"
	cDesc1   := "Este programa tem como objetivo, Imprimir o relatório com"
	cDesc2   := "as informações apresentadas na tela de consulta de caixas"
	cDesc3   := "referente ao fonte GJF40."
	tamanho  := "G"
	aReturn  := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1}
	aLinha   := {}
	nLastKey := 0
	titulo   := "Consulta Posição de Estoque Caixas"
	wnrel    := "STI_R506"
	nTipo    := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,,titulo,cDesc1,cDesc2,cDesc3,.F.)

	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif

	If AllTrim(FunName()) == "GJF40"
		RptStatus({|| RptDetail()})
	Else
		MsgAlert("Este relatório somente pode ser executado pela rotina GJF40 devido aos critérios de impressão.")
	Endif

Return


Static Function RptDetail()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa regua de impressao                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(LastRec())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo  := IIF(aReturn[4]==1,15,18)
	nLin   := 80
	m_pag  := 1
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
	titulo := "Consulta Posição de Estoque Caixas " + _cTpArm  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := "                                                                      P R E V I S Ã O     |    P R O D U Ç Ã O     |      E S T O Q U E     |      CARREGAMENTO      |      E M P E N H O     |        S A L D O    "
	cabec2 := "P  R  O  D  U  T  O                                                  CAIXAS        PESO   |   CAIXAS        PESO   |   CAIXAS        PESO   |   CAIXAS        PESO   |   CAIXAS        PESO   |   CAIXAS        PESO"
	//***      XXXXXX X----------------------------------------------------------X XXX.XXX  XXX.XXX,XX      XXX.XXX  XXX.XXX,XX      XXX.XXX  XXX.XXX,XX      XXX.XXX  XXX.XXX,XX      XXX.XXX  XXX.XXX,XX      XXX.XXX  XXX.XXX,XX               
	//***                1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
	//***      012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressão dos Dados                                      ³
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
	SetRegua(RecCount())
	Do While ! TMP -> (Eof ())
		IncRegua()

		If nLin > 75
			Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
			nLin := 9
		Endif 

		@ nLin, 000 PSAY Left(TMP->CODIGO,6) 
		@ nLin, 007 PSAY Left(TMP->DESCRI,60)                    
		@ nLin, 068 PSAY Transform(TMP->C_PREV, "@E 999,999")	
		@ nLin, 077 PSAY Transform(TMP->P_PREV, "@E 999,999.99") 
		@ nLin, 093 PSAY Transform(TMP->C_PROD, "@E 999,999")	
		@ nLin, 102 PSAY Transform(TMP->P_PROD, "@E 999,999.99") 
		@ nLin, 118 PSAY Transform(TMP->C_EST,  "@E 999,999")	
		@ nLin, 127 PSAY Transform(TMP->P_EST,  "@E 999,999.99") 
		@ nLin, 143 PSAY Transform(TMP->C_CAR,  "@E 999,999")	
		@ nLin, 152 PSAY Transform(TMP->P_CAR,  "@E 999,999.99") 
		@ nLin, 168 PSAY Transform(TMP->C_EMP,  "@E 999,999")	
		@ nLin, 177 PSAY Transform(TMP->P_EMP,  "@E 999,999.99") 
		@ nLin, 193 PSAY Transform(TMP->C_SAL,  "@E 999,999")	
		@ nLin, 202 PSAY Transform(TMP->P_SAL,  "@E 999,999.99") 
		nLin++

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

		TMP->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 
	EndDo

	If nLin > 75
		Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
		nLin := 9
	Endif 

	@ nLin, 067 PSAY Replicate("=", 146)
	nLin++
	@ nLin, 050 PSAY "T O T A I S ==>" 

	@ nLin, 068 PSAY Transform(_nTotCPrev, "@E 999,999")	
	@ nLin, 077 PSAY Transform(_nTotPPrev, "@E 999,999.99") 
	@ nLin, 093 PSAY Transform(_nTotCProd, "@E 999,999")	
	@ nLin, 102 PSAY Transform(_nTotPProd, "@E 999,999.99") 
	@ nLin, 118 PSAY Transform(_nTotCEst,  "@E 999,999")	
	@ nLin, 127 PSAY Transform(_nTotPEst,  "@E 999,999.99") 
	@ nLin, 143 PSAY Transform(_nTotCCar,  "@E 999,999")	
	@ nLin, 152 PSAY Transform(_nTotPCar,  "@E 999,999.99") 
	@ nLin, 168 PSAY Transform(_nTotCEmp,  "@E 999,999")	
	@ nLin, 177 PSAY Transform(_nTotPEmp,  "@E 999,999.99") 
	@ nLin, 193 PSAY Transform(_nTotCSal,  "@E 999,999")	
	@ nLin, 202 PSAY Transform(_nTotPSal,  "@E 999,999.99") 

	// Força posicionamento no início do arquivo temporário
	DbSelectArea("TMP")
	DbGoTop()

	Set Device To Screen

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()   // Libera fila de relatorios em spool (Tipo Rede Netware)

Return
