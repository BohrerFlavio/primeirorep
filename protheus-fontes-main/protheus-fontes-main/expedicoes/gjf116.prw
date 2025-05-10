#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF116     บAutor  ณGiuliano Forgiariniบ Data ณ  29/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Consulta de Manifesto de Carga                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Diversas rotinas                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GJF116()


	Private cPerg       := "FBF07b"
	Private _nTotCaix   := 0
	Private _nTotPesCai := 0
	Private _nTotPec    := 0
	Private _nTotPesPec := 0
	if !pergunte("FBF07b",.t.)
		return
	endif

	_area  := getarea()

	MsgRun("Aguarde... Processando Consulta...",,{||  gjf116pr() })

return

Static Function gjf116pr()

	cQuery := " SELECT B1_SEGUM AS SEGUM, ZZ5_COD AS COD,SUM(ZZ5_QRCAIX) AS CAIX,"
	cQuery += " SUM(ZZ5_QRPESB) AS PESOB,SUM(ZZ5_QRPESO) AS PESO" 
	cQuery += " FROM " + RetSqlName("ZZ4") + " ZZ4," + RetSqlName("ZZ5") + " ZZ5," + RetSqlName("SB1") + " SB1"
	cQuery += " WHERE " + RetSQLFil('SB1') + " AND " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ5') 
	cQuery += "  AND  ZZ4_PRECAR = '" + mv_par01 + "'" 
	cQuery += "  AND  ZZ4_NUM = ZZ5_NUM "     
	cQuery += "  AND  ZZ4_TPOPER <> 'C' "     
	cQuery += "  AND  ZZ5_COD = B1_COD " 
	cQuery += "  AND  B1_TIPO IN ('PR','PA')
	cQuery += "  AND " + RetSQLDel('ZZ5') + " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('SB1')
	cQuery += " GROUP BY B1_SEGUM,ZZ5_COD" 
	cQuery += " ORDER BY B1_SEGUM,ZZ5_COD"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery := ChangeQuery(cQuery)

	If Select("CAR")<>0
		CAR->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "CAR"

	area := getarea()                                  

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporแrio

	dbSelectarea('CAR')

	_aArqTrb := {}
	aStru := dbStruct()                                                           
	aadd(aStru,{"PRO"    , "C", 06,  0,   "" , 'Cod'})
	aadd(aStru,{"DESCRI" , "C", 40,  0,   "" , 'Descricao'})
	
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
		DbSelectArea('TMP')
		reclock('TMP',.t.) 	            
		TMP->SEGUM    := CAR->SEGUM
		TMP->DESCRI   := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(CAR->COD),'B1_DESC')
		TMP->PRO      := alltrim(CAR->COD)
		TMP->PESO     := CAR->PESO
		TMP->PESOB    := CAR->PESOB
		TMP->CAIX     := CAR->CAIX
		msunlock() 

		if TMP->SEGUM = 'CX'

			_nTotCaix 	  += CAR->CAIX
			_nTotPesCai  += CAR->PESO

		else

			_nTotPec    += CAR->CAIX
			_nTotPesPec += Car->PESO

		endif

		CAR->(dbskip())   

	enddo 

	aCampos := {}   
	aadd(aCampos,{"SEGUM "      ,"Unid.Med"  ,"@!"          })
	aadd(aCampos,{"PRO "     ,"Codigo"    ,"@!"          })
	aadd(aCampos,{"DESCRI"   ,"Descricao" ,"@!"           })
	aadd(aCampos,{"CAIX"    ,"Quantid."  ,"@!"           })
	aadd(aCampos,{"PESO"     ,"Peso Lq."  ,"@E 999,999.99"})
	aadd(aCampos,{"PESOB"    ,"Peso Br."  ,"@E 999,999.99"})

	TMP->(dbgotop()) 

	_cPlaca := fBuscaCPO('ZZ3',2,xfilial('ZZ3')+mv_par01,'ZZ3_PLACA')
	_cDtCar := dtoc(fBuscaCPO('ZZ3',2,xfilial('ZZ3')+mv_par01,'ZZ3_DTCAR') )
	_cObs   := fBuscaCPO('ZZ3',2,xfilial('ZZ3')+mv_par01,'ZZ3_OBS')
	_cResp  := fBuscaCPO('ZZ3',2,xfilial('ZZ3')+mv_par01,'ZZ3_USUAR') 
	_stat   := fBuscaCPO('ZZ3',2,xfilial('ZZ3')+mv_par01,'ZZ3_STATUS') 

	if _stat = 'A'
		_cStatus := '[Aberto]'
	elseif _stat = 'S'
		_cStatus := '[Espera]'
	elseif _stat = 'C'
		_cStatus := '[Carregando...]'
	else
		_cStatus := '[Encerrado]'
	endif

	DEFINE MSDIALOG oCon TITLE 'Consulta Manifesto de Carga' from 00,00 to 500,700 OF oMainWnd PIXEL

	@ 001,005 say 'Placa: ' + padr(_cPlaca,15,' ') + 'Carregar em: ' + padr(_cDtCar,15,' ') + padr(_cObs,30,' ') + 'Resp.: ' + padr(_cResp,15,' ') 
	@ 002,005 say _cStatus

	@ 035,015 To 225,340 Browse "TMP"  fields aCampos object oiBrowse  

	@ 018,002 say 'Caixas:' + transform(_nTotCaix,'@E 999,999')
	@ 018,007 say 'Peso Caixas: ' + transform(_nTotPesCai,'@E 999,999.99')
	@ 018,019 say 'Pecas:' + transform(_nTotPec,'@E 999,999')
	@ 018,024 say 'Peso Pecas: ' + transform(_nTotPesPec,'@E 999,999.99')
	@ 230,308  BUTTON 'Sair'  SIZE 40,15 ACTION oCon:end() OBJECT oBtn 
	ACTIVATE MSDIALOG oCon

	TMP->(dbclosearea())
	CAR->(dbclosearea())		

	restarea(_area)

return
