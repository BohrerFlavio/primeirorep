#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF113     บAutor  ณGiuliano Forgiariniบ Data ณ  27/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Consulta de produ็ใo da entrada da desossa        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Diversas rotinas                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GJF113()

	_area   := getarea()

	cQuery := " SELECT ZO_TIPO AS TIPO, ZO_PROD AS PROD, SUM(ZO_QUANT)AS QUANT, SUM(ZO_PESOL) AS PESOL"
	cQuery += " FROM " + RetSqlTab("SZO")
	cQuery += " WHERE "+ RetSqlFil("SZO") + " AND "
	cQuery +="  ZO_DEST <> 'C' AND " 
	cQuery +=" ZO_DATA = '" + DTOS(DDATABASE) +"' AND " + RetSQLDel('SZO')

	cQuery += " GROUP BY ZO_TIPO, ZO_PROD"
	cQuery += " ORDER BY ZO_TIPO, ZO_PROD"  

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery := ChangeQuery(cQuery)

	If Select("DSO")<>0
		DSO->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "DSO"

	area := getarea()                                  

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporแrio

	dbSelectarea('DSO')

	_aArqTrb := {}
	aStru := dbStruct()                                                           
	aadd(aStru,{"TIP"  , "C", 10, 0,   "" , 'Movimento ' })
	aadd(aStru,{"PRO" , "C", 30,  0,   "" , 'Produto'})

	//dbcreate(cArq,aStru)                                                          
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)


	DbSelectArea('SB1')

	while DSO->(!eof()) 
		DbSelectArea('TMP')
		reclock('TMP',.t.) 	
		TMP->TIP      := iif(DSO->TIPO = 'E','ENTRADA','SAIDA')
		TMP->PRO      := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(DSO->PROD),'B1_DESC')
		TMP->PROD     := DSO->PROD
		TMP->PESOL    := DSO->PESOL
		TMP->QUANT    := DSO->QUANT
		msunlock()
		DSO->(dbskip())   

	enddo 

	aCampos := {}   
	aadd(aCampos,{"TIP"     ,"Movimento" ,"@!"          })
	aadd(aCampos,{"PROD"     ,"Codigo"   ,"@!"           })
	aadd(aCampos,{"PRO"      ,"Descri็ใo","@!"           })
	aadd(aCampos,{"PESOL"   ,"Peso"     ,"@E 999,999.99"})
	aadd(aCampos,{"QUANT"   ,"Quant"    ,"@E 999,999"   })

	TMP->(dbgotop()) 

	DEFINE MSDIALOG oCon TITLE 'Consulta Entrada/Saida Desossa' from 00,00 to 250,600 OF oMainWnd PIXEL

	@ 005,005 To 090,300 Browse "TMP"  fields aCampos object oiBrowse  

	@ 100,220  BUTTON 'Sair'        SIZE 40,15 ACTION oCon:end() OBJECT oBtn 
	ACTIVATE MSDIALOG oCon

	//dbclosearea('TMP')
	//dbclosearea('DSO')		

	TMP->(dbCloseArea())
	DSO->(dbCloseArea())
	
	u_arqtrb ("FechaTodos",,,, @_aArqTrb)

	restarea(_area)

return
