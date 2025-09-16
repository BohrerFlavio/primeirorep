#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF27     º Autor ³ Flavio Bohrer      º Data ³  30/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Posição de Estoque de PA Angus                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Controle dos Certificadores Angus			                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF27()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "de Posição de Estoque de Produto Acabado (Caixas) "
	Local cDesc3         := "produzidas, estocadas e expedidas "
	Local cPict          := ""
	Local titulo         := "POSICAO DE ESTOQUE CAIXAS - ANGUS"
	Local nLin           := 80

	Local Cabec1       := "     Produto                      Posição Anterior              Entrada         "+;
	"          Saida              Posição Atual"
	Local Cabec2       := "Codigo    Descrição               Caixas      Peso         Caixas      Peso     "+;
	"   Caixas      Peso         Caixas      Peso"
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private tamanho          := "M"
	Private nomeprog         := "FBF27" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   		:= "FBF27"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "FBF27" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    	:= 0.00
	Private TotPeso    	:= 0.00 
	Private _QUANT     	:= 0
	Private _PESO      	:= 0
	Private _QUANT2    := 0
	Private _PESO2     := 0

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	do case
		case mv_par03 = 1
		fArm := 'R'
		case mv_par03 = 2
		fArm := 'C'
		case mv_par03 = 3
		fArm := 'S'
		otherwise
		fArm := 'T'
	endcase            

	//para verificação se existe previsao de pesagem
	cQuery := " SELECT  BM_FARM AS FARM, B1_GRUPO AS GRUPO, B1_COD AS COD, "
	cQuery += "       (SELECT COUNT(Z8_COD)FROM SZ8010 WHERE SZ8010.D_E_L_E_T_ <> '*' AND   SZ8010.Z8_DATAE = '' AND  "    //anterior  
	cQuery += "       ((Z8_DATAS > '" + dtos(mv_par01-1) + "' AND Z8_DATA <= '" + dtos(mv_par01-1) + "') OR" 
	cQuery += "        (Z8_DATAS = ''                         AND Z8_DATA <= '" + dtos(mv_par01-1) + "')) "
	cQuery += "         AND Z8_FILIAL = '"+ xfilial("SZ8") + "' AND  Z8_FIL = '"+ xfilial("SB1") + "' AND     " 
	cQuery += "         SB1010.B1_COD = SZ8010.Z8_COD) AS POS_ANT_CAIX, " 

	cQuery += "       (SELECT SUM(Z8_PESO)FROM SZ8010 WHERE SZ8010.D_E_L_E_T_ <> '*' AND   SZ8010.Z8_DATAE = '' AND  "    //anterior  
	cQuery += "       ((Z8_DATAS > '" + dtos(mv_par01-1) + "' AND Z8_DATA <= '" + dtos(mv_par01-1) + "') OR" 
	cQuery += "        (Z8_DATAS = ''                         AND Z8_DATA <= '" + dtos(mv_par01-1) +"')) "
	cQuery += "         AND Z8_FILIAL = '"+ xfilial("SZ8") + "' AND  Z8_FIL = '"+ xfilial("SB1") + "' AND     " 
	cQuery += "         SB1010.B1_COD = SZ8010.Z8_COD) AS POS_ANT_PESO, " 

	cQuery += "        (SELECT COUNT(Z8_COD)FROM SZ8010 WHERE SZ8010.D_E_L_E_T_ <> '*' AND  Z8_FILIAL = '"+ xfilial("SZ8") + "' AND  "
	cQuery += "         Z8_FIL = '"+ xfilial("SB1") + "' AND SZ8010.Z8_DATAE = '' AND 
	cQuery += "         (SZ8010.Z8_DATA BETWEEN '" + dtos(mv_par01) +    " ' AND '" + dtos(mv_par02) + "') AND "
	cQuery += "          SB1010.B1_COD = SZ8010.Z8_COD) AS ENT_CAIX,"           

	cQuery += "        (SELECT SUM(Z8_PESO)FROM SZ8010 WHERE SZ8010.D_E_L_E_T_ <> '*' AND  Z8_FILIAL = '"+ xfilial("SZ8") + "' AND  "
	cQuery += "         Z8_FIL = '"+ xfilial("SB1") + "' AND SZ8010.Z8_DATAE = '' AND 
	cQuery += "         (SZ8010.Z8_DATA BETWEEN '" + dtos(mv_par01) +    " ' AND '" + dtos(mv_par02) + "') AND "
	cQuery += "          SB1010.B1_COD = SZ8010.Z8_COD) AS ENT_PESO,"           

	cQuery += "        (SELECT COUNT(Z8_COD)FROM SZ8010 WHERE SZ8010.D_E_L_E_T_ <> '*' AND  "
	cQuery += "         Z8_FILIAL = '"+ xfilial("SZ8") + "' AND Z8_FIL = '"+ xfilial("SB1") + "' AND "  
	cQuery += "         SZ8010.Z8_DATAE = '' AND (SZ8010.Z8_DATAS BETWEEN '" + dtos(mv_par01) +   " '" 
	cQuery += "         AND '" + dtos(mv_par02) + "')AND SZ8010.Z8_COD = SB1010.B1_COD) AS SAI_CAIX, "  

	cQuery += "        (SELECT SUM(Z8_PESO)FROM SZ8010 WHERE SZ8010.D_E_L_E_T_ <> '*' AND  "
	cQuery += "         Z8_FILIAL = '"+ xfilial("SZ8") + "' AND Z8_FIL = '"+ xfilial("SB1") + "' AND "  
	cQuery += "         SZ8010.Z8_DATAE = '' AND (SZ8010.Z8_DATAS BETWEEN '" + dtos(mv_par01) +   " '" 
	cQuery += "         AND '" + dtos(mv_par02) + "')AND SZ8010.Z8_COD = SB1010.B1_COD) AS SAI_PESO "  


	cQuery += " FROM " + RetSqlName("SB1") + ", " + RetSqlName("SBM") +" WHERE SB1010.D_E_L_E_T_ <> '*'   " 
	cQuery += " AND B1_TIPO IN('PA','PR') AND B1_FILIAL = '" + xFilial("SB1") + "' AND SBM010.D_E_L_E_T_ <> '*'  " 
	cQuery += " AND BM_FILIAL = '"+ xfilial("SBM") + "'"
	cQuery += " AND BM_GRUPO = B1_GRUPO AND (B1_SEGUM = 'CX' OR B1_SEGUM = 'SC') AND B1_MSBLQL = 2 "


	if fArm != 'T'
		cQuery  += " AND BM_FARM = '" +fArm + "'"  
	endif

	cQuery  += " AND (B1_FAM = '016' OR B1_FAM = '017')"    



	cQuery  +=  " ORDER BY BM_FARM,BM_GRUPO,B1_COD"

	cQuery  := ChangeQuery(cQuery)


	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("POS") != 0
		POS->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "POS"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ8')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	POS->(SetRegua(RecCount()))

	POS->(dbGoTop())

	cGrupo := '' 
	_cFarm := ''

	While POS->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		if   mv_par04 = 2
			if  empty(POS->POS_ANT_CAIX) .and. empty(POS->ENT_CAIX) .and. empty(POS->SAI_CAIX)
				POS->(dbskip())
				loop  
			endif
		endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif      

		if _cFarm != POS->FARM
			nlin++    
			do case
				case POS->FARM = 'C'
				@nlin,001 psay 'CONGELADOS:'
				nlin++
				_cFarm := POS->FARM 
				case POS->FARM = 'R'
				@nlin,001 psay 'RESFRIADOS:'
				nlin++
				_cFarm := POS->FARM
				case POS->FARM = 'S'
				@nlin,001 psay 'SALGADOS:'
				nlin++
				_cFarm := POS->FARM  
			endcase
		endif

		if cGrupo != POS->GRUPO	
			nlin++
			@nlin,001 psay 'Grupo:  '+ POS->GRUPO + '  ' + fBuscaCPO('SBM',1,xfilial('SBM')+POS->GRUPO,'BM_DESC')
			nlin++
			cGrupo := POS->GRUPO
		endif     

		Transfere(alltrim(POS->COD))
		DbSelectArea('SB1')

		@nlin,001 psay alltrim(POS->COD)
		@nlin,008 psay substr(fBuscaCPO('SB1',1,xfilial('SB1')+POS->COD,'B1_DESCRED'),1,20) 
		@nlin,030 psay transform(POS->POS_ANT_CAIX + _QUANT                ,'@E 9,999')
		@nlin,040 psay transform(POS->POS_ANT_PESO + _PESO                 ,'@E 999,999.99') + '  |'
		@nlin,055 psay transform(POS->ENT_CAIX + _QUANT2                   ,'@E 9,999')
		@nlin,065 psay transform(POS->ENT_PESO + _PESO2                    ,'@E 999,999.99') + '  |'  
		@nlin,080 psay transform(POS->SAI_CAIX + _QUANT                    ,'@E 9,999')
		@nlin,090 psay transform(POS->SAI_PESO + _PESO                     ,'@E 999,999.99') + '  |'
		@nlin,105 psay transform(POS->(POS_ANT_CAIX +  ENT_CAIX - SAI_CAIX),'@E 9,999')
		@nlin,115 psay transform(POS->(POS_ANT_PESO +  ENT_PESO - SAI_PESO),'@E 999,999.99') + '  |'
		nlin++	 
		POS->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

Static Function Transfere(_cod)
	_des := ''     
	_QUANT  := 0
	_PESO   := 0
	_QUANT2 := 0
	_PESO2  := 0

	DbSelectArea('ZZE')
	DbSelectArea('SZ8')
	ZZE->(DbSetOrder(1))
	SZ8->(DbSetOrder(4))
	SZ8->(DbSeek(xfilial('SZ8')+xfilial('SB1')+_cod))

	if ZZE->(DbSeek(xfilial('ZZE')+ xfilial('SB1') + _cod))
		_des := ZZE->ZZE_CODDES
	else
		_des := _cod
	endif 

	cQuery2 := "SELECT COUNT(*) AS QUANT, SUM(Z8_PESO) AS PESO " +;
	" FROM " + RetSqlName("SZ8") + " WHERE SZ8010.D_E_L_E_T_ <> '*'  " +;
	" AND Z8_FILIAL = '"+ xfilial("SZ8") + "' AND  Z8_FIL <> '"+ xfilial("SB1") + "' AND " +;
	"  SZ8010.Z8_COD = '" + alltrim(_des) + "' AND "+;
	"  (Z8_DTRANSF BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' ) AND "+;
	"  Z8_DTRANSF <> ''" +;
	"  GROUP BY Z8_FILORI "

	cQuery2 := ChangeQuery(cQuery2)

	If Select("POS2") != 0
		POS2->(dbCloseArea())
	Endif

	TCQUERY cQuery2 NEW ALIAS "POS2"
	//Valores que foram transferidos daqui para outra filial
	_QUANT := POS2->QUANT
	_PESO  := POS2->PESO 

	DbCloseArea('POS2') 


	if SZ8->Z8_FILORI <> xfilial('SB1')

		cQuery3 := "SELECT COUNT(*) AS QUANT, SUM(Z8_PESO) AS PESO " +;
		" FROM " + RetSqlName("SZ8") + " WHERE SZ8010.D_E_L_E_T_ <> '*'  " +;
		" AND Z8_FILIAL = '"+ xfilial("SZ8") + "' AND  Z8_FIL = '"+ xfilial("SB1") + "' AND " +;
		"  SZ8010.Z8_COD = '" + alltrim(_cod) + "' AND "+;
		"  (Z8_DTRANSF BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' ) AND "+;
		"  Z8_DTRANSF <> ''"

		cQuery3 := ChangeQuery(cQuery3)
		If Select("POS3") != 0
			POS3->(dbCloseArea())
		Endif

		TCQUERY cQuery3 NEW ALIAS "POS3"
		//Valores que foram transferidos de lá pra cá
		_QUANT2 += POS3->QUANT
		_PESO2  += POS3->PESO 

	endif                               
	If Select("POS3") != 0
		POS3->(dbCloseArea())
	Endif

Return 
