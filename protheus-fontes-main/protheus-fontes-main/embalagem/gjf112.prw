#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF112     บAutor  ณGiuliano Forgiariniบ Data ณ  27/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Consulta de produ็ใo de caixas                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Diversas rotinas                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GJF112()

	Private cPerg := "GJF43"

	if !pergunte("GJF43",.t.)
		return
	endif

	_area   := getarea()

	if !empty(mv_par04)
		cQuery := " SELECT Z8_BALAN AS BALAN, BM_FARM AS FARM, BM_GRUPO AS GRUPO, Z8_CODORI AS COD,"   
	else
		cQuery := " SELECT BM_FARM AS FARM, BM_GRUPO AS GRUPO, Z8_CODORI AS COD,"   
	endif

	cQuery += " Z8_DESCRI AS DESCRI, COUNT(Z8_CODORI) AS CAIX,"
	cQuery += " SUM(Z8_PESO) AS PESO, "
	cQuery += " SUM(Z8_QUANT) AS QUANT "
	cQuery += " FROM " + RetSqlName("SZ8") + ", " + RetSqlName("SBM")  + ", " + RetSqlName("SB1") + ", " + RetSqlName("SZU")
	cQuery += " WHERE SB1010.D_E_L_E_T_ <> '*' AND "
	cQuery +="        SZ8010.D_E_L_E_T_ <> '*' AND "
	cQuery +="        SBM010.D_E_L_E_T_ <> '*' AND "
	cQuery +="        SZU010.D_E_L_E_T_ <> '*' AND "
	cQuery +=" B1_TIPO IN('PR','PA') AND "
	cQuery +=" B1_FILIAL = '" + xFilial("SB1") + "' AND"
	cQuery +=" BM_FILIAL = '" + xFilial("SBM") + "' AND"
	cQuery +=" Z8_FILIAL = '" + xFilial("SZ8") + "' AND" 
	cQuery +=" Z8_FILORI = '" + xFilial("SB1") + "' AND"
	cQuery +=" ZU_FILIAL = '" + xFilial("SZU") + "' AND" 
	cQuery +=" (Z8_DATA BETWEEN '" + DTOS(mv_par01) +"' AND '" + DTOS(mv_par02) + "') AND"     
	cQuery +=" (Z8_DATAP BETWEEN '" + DTOS(mv_par05) +"' AND '" + DTOS(mv_par06) + "') AND"  
	cQuery +=" Z8_DATAE = ' ' AND"      
	cQuery +=" ZU_NUM   = Z8_NUMPREV AND" 
	cQuery +=" BM_GRUPO = B1_GRUPO AND B1_COD = Z8_CODORI"

	if mv_par10 = 1 
		cQuery += " AND Z8_TERC = 'S'"
	elseif mv_par10 = 2     
		cQuery += " AND Z8_TERC <> 'S'"
	endif

	if mv_par11 = 1 
		cQuery += " AND ZU_TIPO = 'P'"
	elseif mv_par11 = 2     
		cQuery += " AND ZU_TIPO = 'R'"
	endif


	do case
		case mv_par03 = 1
		_Farm := 'R'
		case mv_par03 = 2
		_Farm := 'C'
		case mv_par03 = 3
		_Farm := 'S'
		otherwise
		_Farm := 'T'
	endcase     

	if _Farm != 'T'
		cQuery += " AND BM_FARM = '" +_Farm + "'"    
	endif

	if !empty(mv_par07)
		cQuery += " AND B1_FAM = '" +mv_par07 + "'"    
	endif

	do case
		case mv_par08 = 1
		cQuery += " AND Z8_TF = 'S'"    
		case mv_par08 = 2
		cQuery += " AND Z8_TF = 'N'"    
	endcase

	do case
		case mv_par09 = 1
		cQuery += " AND B1_DESTINO = 'MI'"    
		case mv_par09 = 2
		cQuery += " AND B1_DESTINO = 'ME'"    
	endcase


	if !empty(mv_par04)
		cQuery += " AND Z8_BALAN = '" +mv_par04 + "'"    
		cQuery += " GROUP BY Z8_BALAN, BM_FARM, BM_DESC, Z8_CODORI, Z8_DESCRI"
		cQuery += " ORDER BY Z8_BALAN, BM_GRUPO, Z8_CODORI"  
	else
		cQuery +=  " GROUP BY BM_FARM, BM_GRUPO, Z8_CODORI, Z8_DESCRI" 
		cQuery +=  " ORDER BY BM_FARM, BM_GRUPO, Z8_CODORI" 
	endif

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery := ChangeQuery(cQuery)

	If Select("EMB")<>0
		EMB->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "EMB"

	area := getarea()                                  


	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporแrio

	dbSelectarea('EMB')

	_aArqTrb := {}
	aStru := dbStruct()                                                           
	aadd(aStru,{"ARM"  , "C", 10, 0,   "" , 'Armaz.' })
	aadd(aStru,{"GRP"  , "C", 25, 0,   "" , 'Grupo ' })
	aadd(aStru,{"PROD" , "C", 06, 0,   "" , 'Produto'})
	
	//dbcreate(cArq,aStru)                                                          
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	If Select('TMP')<>0                               //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)


	while EMB->(!eof()) 
		DbSelectArea('TMP')
		reclock('TMP',.t.) 

		if !empty(mv_par04)
			TMP->BALAN  := EMB->BALAN  
		endif 

		if EMB->FARM = 'R'
			TMP->ARM := 'Resfriado'
		elseif EMB->FARM = 'C'
			TMP->ARM := 'Congelado'  
		elseif EMB->FARM = 'S'
			TMP->ARM := 'Salgado'
		else
			TMP->ARM := 'Todos'
		endif    

		TMP->GRP      := EMB->GRUPO + ' ' + fBuscaCPO('SBM',1,xfilial('SBM')+EMB->GRUPO,'BM_DESC')
		TMP->PROD     := alltrim(EMB->COD)
		TMP->DESCRI   := EMB->DESCRI
		TMP->CAIX     := EMB->CAIX
		TMP->PESO     := EMB->PESO
		TMP->QUANT    := EMB->QUANT
		msunlock()
		EMB->(dbskip())   

	enddo 

	_nTotal := TMP->(RecCount())    

	aCampos := {}   
	if !empty(mv_par04)                                      
		aadd(aCampos,{"BALAN" ,"Balan็a " ,""             }) 
	endif
	aadd(aCampos,{"ARM"     ,"Armazen." ,"@!"           })
	aadd(aCampos,{"GRP"    ,"Grupo"    ,"@!"           })
	aadd(aCampos,{"PROD"    ,"Codigo"   ,"@!"           })
	aadd(aCampos,{"DESCRI"  ,"Descri็ใo","@!"           })
	aadd(aCampos,{"CAIX"    ,"Caixa"    ,"@E 999,999"   })
	aadd(aCampos,{"PESO"    ,"Peso"     ,"@E 999,999.99"})
	aadd(aCampos,{"QUANT"   ,"Quant"    ,"@E 999,999"   })

	TMP->(dbgotop()) 

	DEFINE MSDIALOG oCon TITLE 'Consulta Produ็ใo Estoque' from 00,00 to 600,835 OF oMainWnd PIXEL

	@ 005,005 To 265,415 Browse "TMP"  fields aCampos object oiBrowse  
	@ 022,005 say 'Total de Caixas: ' + transform(_nTotal,'@E 999,999')

	@ 280,300  BUTTON 'Sair'        SIZE 40,15 ACTION oCon:end() OBJECT oBtn 
	ACTIVATE MSDIALOG oCon

	TMP->(dbclosearea())
	EMB->(dbclosearea())	

	restarea(_area)

return
