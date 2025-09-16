#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF115     บAutor  ณGiuliano Forgiariniบ Data ณ  28/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Consulta de resumo de carga                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Diversas rotinas                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GJF115()

	Private cPerg := "GJF41b"
	Private _nTotCaix := 0
	Private _nTotPes  := 0

	if !pergunte("GJF41b",.t.)
		return
	endif

	_area   := getarea()


	MsgRun("Aguarde... Processando Consulta...",,{||  gjf115pr() })

return

Static Function gjf115pr()
	cQuery := " SELECT ZZ5_COD AS COD,"
	cQuery += " SUM(ZZ5_QPCAIX)AS CAIX,SUM(ZZ5_QPPESO)AS PESO "   
	cQuery += " FROM " + RetSqlName("ZZ4") + " ZZ4 INNER JOIN " + RetSqlName("ZZ3") + " ZZ3 ON (ZZ3.ZZ3_NUM = ZZ4.ZZ4_PRECAR "  
	cQuery +=                                                    " AND ZZ3.D_E_L_E_T_ <> '*' " 
	cquery +=                                                    " AND ZZ3.ZZ3_FILIAL = '" + xFilial("ZZ3") + "'" 
	cquery +=                                                    " AND ZZ3.ZZ3_DTCAR = '" + dtos(ddatabase) + "'" 
	cQuery +=                                                    " AND ZZ3.ZZ3_NUM = '" + mv_par01 + "' "
	cQuery +=                                                    " AND ZZ4.D_E_L_E_T_ <> '*' AND ZZ4.ZZ4_FILIAL = '" + xFilial("ZZ4") + "')" 
	cQuery +=                                "     INNER JOIN " + RetSqlName("ZZ5") + " ZZ5 ON (ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM " 
	cQuery +=                                                    " AND ZZ5.D_E_L_E_T_ <> '*' "    
	cQuery +=                                                    " AND ZZ5.ZZ5_FILIAL = '" + xFilial("ZZ5") + "')"
	cQuery += " GROUP BY ZZ5.ZZ5_COD"   
	cQuery += " ORDER BY ZZ5.ZZ5_COD"


	cQuery2 := " SELECT ZZ5_NUM AS NUM, ZZ5_COD AS COD,ZZ5_QPCAIX AS CAIX,ZZ4_CODCLI AS CODCLI, ZZ4_LOJA AS LOJA, ZZ5_OBS AS OBS"
	cQuery2 += " FROM " + RetSqlName("ZZ4") + " ZZ4 INNER JOIN " + RetSqlName("ZZ3") + " ZZ3 ON (ZZ3.ZZ3_NUM = ZZ4.ZZ4_PRECAR "  
	cQuery2 +=                                                    " AND ZZ3.D_E_L_E_T_ <> '*' " 
	cquery2 +=                                                    " AND ZZ3.ZZ3_FILIAL = '" + xFilial("ZZ3") + "'" 
	cquery2 +=                                                    " AND ZZ3.ZZ3_DTCAR = '" + dtos(ddatabase) + "'" 
	cQuery2 +=                                                    " AND ZZ3.ZZ3_NUM = '" + mv_par01 + "' "
	cQuery2 +=                                                    " AND ZZ4.D_E_L_E_T_ <> '*' AND ZZ4.ZZ4_FILIAL = '" + xFilial("ZZ4") + "')" 
	cQuery2 +=                                "     INNER JOIN " + RetSqlName("ZZ5") + " ZZ5 ON (ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM " 
	cQuery2 +=                                                    " AND ZZ5.D_E_L_E_T_ <> '*' "    
	cQuery2 +=                                                    " AND ZZ5.ZZ5_OBS <> '' "   
	cQuery2 +=                                                    " AND ZZ5.ZZ5_FILIAL = '" + xFilial("ZZ5") + "')" 

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery  := ChangeQuery(cQuery)
	cQuery2 := ChangeQuery(cQuery2)

	If Select("CAR")<>0
		CAR->(dbCloseArea())
	Endif

	If Select("CAR2")<>0
		CAR2->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "CAR"
	TCQUERY cQuery2 NEW ALIAS "CAR2"

	area := getarea()                                  

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporแrio
	//cArq2 := CriaTrab( Nil, .F. ) 

	//Cria estrutura do primeiro arquivo
	dbSelectarea('CAR')

	_aArqTrb := {}
	_aArqTrb2 := {}

	aStru := {}  	// dbStruct()                                                           
	//aadd(aStru,{"ARM"    , "C", 05, 0,   "" , 'Arm.'    })
	//aadd(aStru,{"PROD"   , "C", 06, 0,   "" , 'Codigo'    })
	//aadd(aStru,{"DESCRI" , "C", 30, 0,   "" , 'Descricao' }) 
	//aadd(aStru,{"SEGUM"  , "C", 02, 0,   "" , 'Seg.UM'    })

	aadd(aStru,{"ARM"    , "C", 05, 0})
	aadd(aStru,{"SEGUM"  , "C", 02, 0})
	aadd(aStru,{"PROD"   , "C", 06, 0})
	aadd(aStru,{"DESCRI" , "C", 30, 0}) 
	aadd(aStru,{"CAIX"   , "N", 05, 0})
	aadd(aStru,{"PESO"   , "N", 09, 2})


	//dbcreate(cArq,aStru)                                                          
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	DbSelectArea('SB1')

	while CAR->(!eof())

		_cGrupo := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(CAR->COD) ,'B1_GRUPO') 
		_cFarm  := FBuscaCPO('SBM',1,xfilial('SBM')+_cGrupo,'BM_FARM')

		DbSelectarea('TMP')
		reclock('TMP',.t.) 

		if _cFarm = 'R'
			TMP->ARM := 'Resf.'
		elseif _cFarm = 'C'
			TMP->ARM := 'Cong.'  
		elseif _cFarm = 'S'
			TMP->ARM := 'Salg.'
		else
			TMP->ARM := 'Todos'
		endif    

		TMP->PROD     := alltrim(CAR->COD) 
		TMP->DESCRI   := alltrim(fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(CAR->COD),'B1_DESC'))
		TMP->PESO     := CAR->PESO
		TMP->CAIX     := CAR->CAIX
		TMP->SEGUM    := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(CAR->COD),'B1_SEGUM')
		msunlock()

		_nTotCaix += TMP->CAIX
		_nTotPes  += TMP->PESO

		CAR->(dbskip())   

	enddo 

	_nTotal := TMP->(RecCount())    

	//Cria estrutura do segundo arquivo
	dbSelectarea('CAR2')

	aStru2 := {}		//dbStruct()                                                           
	//aadd(aStru2,{"PROD"   , "C", 06, 0,   "" , 'Codigo'  })
	//aadd(aStru2,{"CLIENTE", "C", 10, 0,   "" , 'Cliente' }) 

	aadd(aStru2,{"PROD"   , "C", 06, 0})
	aadd(aStru2,{"CLIENTE", "C", 10, 0}) 
	aadd(aStru2,{"CAIX"   , "N", 05, 0})
	aadd(aStru2,{"NUM"    , "C", 06, 0}) 
	aadd(aStru2,{"OBS"    , "C", 40, 0}) 

	//dbcreate(cArq2,aStru2)                                                          
	//If Select('TMP2')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP2->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq2,"TMP2", .F. , .F. )

	If Select('TMP2')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP2->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb2)
	Endif

	U_ArqTrb("Cria", "TMP2", aStru2, {}, @_aArqTrb2)

	DbSelectArea('SB1')

	while CAR2->(!eof())

		DbSelectArea('TMP2')
		reclock('TMP2',.t.) 

		TMP2->PROD     := alltrim(CAR2->COD) 
		TMP2->CLIENTE  := CAR2->(CODCLI+'/'+LOJA)
		TMP2->NUM      := CAR2->NUM
		TMP2->CAIX     := CAR2->CAIX
		TMP2->OBS      := CAR2->OBS
		msunlock()

		CAR2->(dbskip())   

	enddo 

	//Defini็ใo dos campos que vใo aparecer nos browses
	aCampos := {} 
	aadd(aCampos,{"ARM"     ,"Arm."  ,"@!"           }) 
	aadd(aCampos,{"SEGUM"   ,"2UM"       ,"@!"           }) 
	aadd(aCampos,{"PROD"    ,"Codigo"    ,"@!"           })
	aadd(aCampos,{"DESCRI"  ,"Descri็ใo" ,"@!"           })   
	aadd(aCampos,{"CAIX"    ,"Quant."    ,"@E 9,999"   })
	aadd(aCampos,{"PESO"    ,"Peso"      ,"@E 999,999.99"})

	aCampos2 := {} 
	aadd(aCampos2,{"PROD"    ,"Codigo"    ,"@!"           })
	aadd(aCampos2,{"CLIENTE" ,"Cliente"   ,"@!"           })
	aadd(aCampos2,{"CAIX"    ,"Quant"     ,"@E 9,999"   })   
	aadd(aCampos2,{"NUM"     ,"Pedido"    ,"@!"           })
	aadd(aCampos2,{"OBS"     ,"Observ."   ,"@!"           })


	//IndRegua("TMP",cArq,"ARM+SEGUM+DESCRI+PROD",,,"Selecionando Registros...") //ordena

	TMP->(dbgotop()) 
	TMP2->(dbgotop()) 

	_cNum   := mv_par01
	_cData  := dtoc(fBuscaCPO('ZZ3',2,xfilial('ZZ3')+mv_par01,'ZZ3_DTCAR'))
	_cPlaca := fBuscaCPO('ZZ3',2,xfilial('ZZ3')+mv_par01,'ZZ3_PLACA')
	_cObs   := fBuscaCPO('ZZ3',2,xfilial('ZZ3')+mv_par01,'ZZ3_OBS')
	_cUsuar := fBuscaCPO('ZZ3',2,xfilial('ZZ3')+mv_par01,'ZZ3_USUAR')

	DEFINE MSDIALOG oCon TITLE 'Consulta de Resumo de Carga' from 00,00 to 500,900 OF oMainWnd PIXEL

	@ 001,001 say 'Numero: ' + _cNum
	@ 001,010 say 'Data Carreg.: ' + _cData 
	@ 001,020 say 'Placa: ' + _cPlaca
	@ 001,030 say 'Obs.: ' + _cObs     
	@ 002,001 say 'Resumo de Produtos: '
	@ 002,032 say 'Resumo de Observa็๕es por pedido: '

	@ 040,005 To 220,250 Browse "TMP"  fields aCampos object oiBrowse  

	@ 040,251 To 220,450 Browse "TMP2"  fields aCampos2 object oiBrowse  

	@ 018,002 say 'Caixas: ' + transform(_nTotCaix,'@E 999,999')
	@ 018,015 say 'Peso: ' + transform(_nTotPes,'@E 999,999.99')  

	@ 225,340  BUTTON 'Sair'    SIZE 40,15 ACTION oCon:end() OBJECT oBtn 
	ACTIVATE MSDIALOG oCon

	TMP->(dbclosearea())
	TMP2->(dbclosearea())

	restarea(_area)

return
