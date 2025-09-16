#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF114     บAutor  ณGiuliano Forgiariniบ Data ณ  28/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Consulta de validade de caixas                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Diversas rotinas                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GJF114()
	Local _aArqTrb      := {} // ProcData 04/2023
	
	Private cPerg := "GJF58"
	Private _nTotCaix := 0
	Private _nTotPes  := 0

	if !pergunte("GJF58",.t.)
		return
	endif

	_area   := getarea()

	do case
		case mv_par03 = 1
		_Farm := 'C'
		case mv_par03 = 2
		_Farm := 'R'
		case mv_par03 = 3
		_Farm := 'S'
		otherwise
		_Farm := 'T'
	endcase     

	cQuery := " SELECT BM_FARM AS FARM, Z8_COD AS COD,Z8_CONTROL AS CONTROL, Z8_DATAP AS DATAP," 
	cQuery += " Z8_DESCRI AS DESCRI, Z8_QUANT AS QUANT,Z8_PESO AS PESO, Z8_DATAVAL AS DATAVAL, Z8_LOCAL AS CAMARA, B1_FAM AS FAM, Z8_CARPICK AS CARPICK"
	cQuery += " FROM " + RetSqlName("SZ8") + ", " + RetSqlName("SBM")  + ", " + RetSqlName("SB1") 
	cQuery += " WHERE " + RetSqlName("SB1") + ".D_E_L_E_T_ <> '*' AND "
	cQuery +=             RetSqlName("SZ8") + ".D_E_L_E_T_ <> '*' AND "
	cQuery +=             RetSqlName("SBM") + ".D_E_L_E_T_ <> '*' AND "
	cQuery += " B1_TIPO IN('PR','PA') AND "
	cQuery += " B1_FILIAL = '" + xFilial("SB1") + "' AND"
	cQuery += " BM_FILIAL = '" + xFilial("SBM") + "' AND"
	cQuery += " Z8_FILIAL = '" + xFilial("SZ8") + "' AND" 
	cQuery += " Z8_FIL = '" + xFilial("SB1") + "' AND"
	cQuery += " Z8_COD = B1_COD AND"
	cQuery += " Z8_TERC <> 'S' AND" 
	cQuery += " (Z8_DATAVAL BETWEEN '" + DTOS(mv_par01) +"' AND '" + DTOS(mv_par02) + "') AND"  
	cQuery += " (Z8_DATAP BETWEEN '" + DTOS(mv_par08) +"' AND '" + DTOS(mv_par09) + "') AND"  
	cQuery += " Z8_DATAS = '' AND"      

	if _Farm != 'T'
		cQuery += " BM_FARM = '" + _Farm + "' AND"          
	endif 


	if !empty(mv_par04)
		cQuery += " B1_FAM = '" + mv_par04 + "' AND"          
	endif

	if !empty(mv_par06)
		cQuery += " B1_COD = '" + mv_par06 + "' AND"          
	endif        

	if !empty(mv_par07)
		cQuery += " Z8_LOCAL = '" + mv_par07 + "' AND"          
	endif 

	//com endere็amento
	if mv_par11 == 1
		cQuery += " Z8_LOCAL <> '' AND Z8_LOCALIZ <> '' AND
		//sem endere็amento	
	elseif mv_par11 == 2
		cQuery += " Z8_LOCAL = '' AND Z8_LOCALIZ = '' AND
	endif

	//filtra desossa ou porcionados
	if mv_par13 == 2
		cQuery += " Z8_LOTEPOR <> '' AND
	endif

	
	if mv_par15 = 1 //SIM
		cQuery += " Z8_PICKING = 'S' AND"
	elseif mv_par15 = 2 //NAO
		cQuery += " Z8_PICKING = '' AND"
	endif
	
	cQuery+=  " BM_GRUPO = B1_GRUPO AND B1_COD = Z8_COD ORDER BY BM_FARM,Z8_DATAP, Z8_CONTROL, Z8_DESCRI, Z8_COD,Z8_DATAVAL" 

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery := ChangeQuery(cQuery)

	If Select("EMB")<>0
		EMB->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "EMB"

	area := getarea()                                  


	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporแrio

	dbSelectarea('EMB')

	aStru := dbStruct()  
	/*                                                         
	aadd(aStru,{"ARM"  , "C", 10, 0,   "" , 'Armaz.' })
	aadd(aStru,{"DTP"  , "D", 08, 0,   "" , 'Data'   })
	aadd(aStru,{"DTV"  , "D", 08, 0,   "" , 'Valid.' })
	aadd(aStru,{"PROD" , "C", 06, 0,   "" , 'Codigo' })
	*/
	aadd(aStru,{"ARM"  , "C", 10, 0})
	aadd(aStru,{"DTP"  , "D", 08, 0 })
	aadd(aStru,{"DTV"  , "D", 08, 0})
	aadd(aStru,{"PROD" , "C", 06, 0 })

	//dbcreate(cArq,aStru)   
	// ProcData 04/2023 - Chamada para cria็ใo do arquivo de trabalho
	//U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)	

	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	/* Parte nova ajustada na troca de versใo - dia 17/07/23 - */
	_aArqTrb := {}
	If Select('TMP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FECHATODOS",,,, @_aArqTrb)
	Endif
	U_ArqTrb("CRIA", "TMP", aStru, {}, @_aArqTrb)



	while EMB->(!eof()) 

		//bloco para verificar quais familias nใo devem ser aparecer no relatorio 
		if empty(mv_par04) .and. !empty(mv_par12)
			if EMB->FAM $ alltrim(mv_par12)
				EMB->(dbSkip())
				loop		
			endif			
		endif

		reclock('TMP',.t.) 

		if EMB->FARM = 'R'
			TMP->ARM := 'Resfriado'
		elseif EMB->FARM = 'C'
			TMP->ARM := 'Congelado'  
		elseif EMB->FARM = 'S'
			TMP->ARM := 'Salgado'
		else
			TMP->ARM := 'Todos'
		endif    

		TMP->PROD     := alltrim(EMB->COD) 
		TMP->CONTROL  := EMB->CONTROL
		TMP->DTP      := stod(EMB->DATAP)
		TMP->DTV      := stod(EMB->DATAVAL)
		TMP->DESCRI   := EMB->DESCRI
		TMP->PESO     := EMB->PESO
		TMP->QUANT    := EMB->QUANT
		TMP->CAMARA   := EMB->CAMARA
		TMP->CARPICK  := EMB->CARPICK
		msunlock() 

		_nTotCaix++
		_nTotPes += EMB->PESO

		EMB->(dbskip())   

	enddo 

	_nTotal := TMP->(RecCount())    

	aCampos := {}   
	aadd(aCampos,{"ARM"     ,"Armazen."  ,"@!"           })
	aadd(aCampos,{"CONTROL" ,"Cod.Caixa" ,"@!"           })
	aadd(aCampos,{"PROD"    ,"Codigo"    ,"@!"           })
	aadd(aCampos,{"DESCRI"  ,"Descri็ใo" ,"@!"           })
	aadd(aCampos,{"DTP"     ,"Dt.Prod."  ,"99/99/9999"   })
	aadd(aCampos,{"DTV"     ,"Validade"  ,"99/99/9999"   })
	aadd(aCampos,{"PESO"    ,"Peso"      ,"@E 999,999.99"})
	aadd(aCampos,{"QUANT"   ,"Quant"     ,"@E 999,999"   })
	aadd(aCampos,{"CAMARA"  ,"Camara"    ,"@!"           })
	aadd(aCampos,{"CARPICK"  ,"Separado Para"    ,"@!"           })	

	TMP->(dbgotop()) 

	DEFINE MSDIALOG oCon TITLE 'Consulta Validade de Caixas' from 00,00 to 600,835 OF oMainWnd PIXEL

	@ 005,005 To 265,415 Browse "TMP"  fields aCampos object oiBrowse  
	@ 022,005 say 'Total de Caixas: ' + transform(_nTotCaix,'@E 999,999')
	@ 022,015 say 'Total de Peso:   ' + transform(_nTotPes,'@E 999,999.99')

	@ 280,300  BUTTON 'Sair'        SIZE 40,15 ACTION oCon:end() OBJECT oBtn 
	ACTIVATE MSDIALOG oCon

	TMP->(dbclosearea())
	EMB->(dbclosearea())		

	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 
	
	restarea(_area)

return
