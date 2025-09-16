#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch" 
#INCLUDE "tbiconn.ch"


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁMLR62  ╨Autor  ЁMauricio Roehrs ╨ Data Ё  28/10/15          ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Relatorio de conferencia de divergencia de refeiГУes       ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SIGAGPE/SIGAPON				                                ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

User Function MLR62()
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de Variaveis                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia das divergencias das"
	Local cDesc3         := "refeiГУes"
	Local cPict          := " - RECALL - "
	Local titulo         := "CONFERENCIA DE DIVERGENCIA DE REFEICOES"
	Local Cabec1         := "Data"
	Local Cabec2         := "           Matricula                Nome                                                               Centro de Custo"
	Local imprime        := .T.
	Local aOrd           := {}  
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "MLR62" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "MLR62"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "MLR62" // Coloque aqui o nome do arquivo usado para impressao em disco        
	Private _cQuery2 := ""
	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZB8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  


	_cQuery := " SELECT  ZB8_DATA,ZB8_MAT,RA_NOME,RA_CC, ZB8_CODREF, ZB8_DSCREF, ZB8_TPREF, ZB8_DESCTP "
	_cQuery += " FROM " + retSqlTab('ZB8') + " , " + retSqlTab('SRA')
	_cQuery += " WHERE " + retSqlFil('ZB8') + " AND " + retSqlFil('SRA')
	_cQuery += " AND ZB8_MAT = RA_MAT"              
	_cQuery += " AND ZB8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += " AND " + retSqlDel('ZB8') + " AND " + retSqlDel('SRA')
	_cQuery += " GROUP BY ZB8_DATA,ZB8_MAT,ZB8_CODREF,ZB8_TPREF,ZB8_DSCREF,ZB8_DESCTP,RA_NOME,RA_CC
	_cQuery += " ORDER BY ZB8_DATA,ZB8_MAT,ZB8_CODREF,ZB8_TPREF

	_cQuery  := ChangeQuery(_cQuery)                         

	//	* Mostrar a consulta 
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo           
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZB8')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Processamento. RPTSTATUS monta janela com a regua de processamento. Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return   


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё SETREGUA -> Indica quantos registros serao processados para a regua Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop()) 

	_dData := ""
	_cMat  := ""
	_cNome := ""
	_cQrb1 := ""
	_cQrb2 := ""      
	codRef := ""
	tpRef  := ""
	_flag  := ""  
	_flag2 := ""
	While TMP->(!EOF())

		incregua()

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica o cancelamento pelo usuario...                             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 // Salto de PАgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif  

		_cNome := fBuscaCPO('CTT',1,xfilial('CTT') + alltrim(TMP->RA_CC),'CTT_DESC01')

		//se o tipo for diferente de refeiГЦo
		if TMP->ZB8_TPREF <> '006' 

			buscCafe(TMP->ZB8_DATA,TMP->ZB8_CODREF,TMP->ZB8_MAT)  

			//CafИ  
			QRY1->(dbGoTop())
			if QRY1->(eof())

			else
			
				

				if _flag2 == TMP->(ZB8_MAT+ZB8_CODREF)		       
					_flag2 := ""
					TMP->(dbSkip())
					loop
				endif

				if TMP->ZB8_DATA <> _dData         
					@nlin,01 psay replicate('-',132)
					nlin++
					@nlin,05 psay stod(TMP->ZB8_DATA)
					nlin++
					_dData := TMP->ZB8_DATA 			
					@nlin,01 psay replicate('-',132)
					nlin++
				endif

				if TMP->ZB8_MAT <> _cMat
					@nlin,10 psay TMP->ZB8_MAT
					@nlin,25 psay substr(TMP -> RA_NOME,1,25)
					@nlin,105 psay alltrim(TMP -> RA_CC)
					nlin++
					@nlin,105 psay alltrim(_cNome)
					nlin++
					_cMat := TMP->ZB8_MAT
					nlin++
					@nlin,23 psay "Quantidade               Tipo                 Descricao                  
					nlin++			
				endif


				while QRY1->(!eof()) 

					
					@nlin,28 psay QRY1->QUANT
					@nlin,48 psay QRY1->ZB8_CODREF
					@nlin,68 psay QRY1->ZB8_DSCREF
					nlin+=2							  	                            

					QRY1->(dbSkip())	
				enddo                    

				_flag2 := TMP->(ZB8_MAT+ZB8_CODREF)		       					
			endif

		else	

			buscRef(TMP->ZB8_DATA,TMP->ZB8_TPREF,TMP->ZB8_MAT)					

			//almoГo/janta	                                   
			QRY2->(dbGoTop())
			if QRY2->(eof())

			else

				if _flag == TMP->(ZB8_MAT+ZB8_TPREF)		       
					_flag := ""
					TMP->(dbSkip())
					loop
				endif

				/*alert('achou algo')
				//mostra a consulta
				@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
				@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
				Activate Dialog oDlgMemo */

				if TMP->ZB8_DATA <> _dData
					@nlin,01 psay replicate('-',132)
					nlin++
					@nlin,05 psay stod(TMP->ZB8_DATA)
					nlin++
					_dData := TMP->ZB8_DATA 
					@nlin,01 psay replicate('-',132)
					nlin++			
				endif

				if TMP->ZB8_MAT <> _cMat
					@nlin,10 psay TMP->ZB8_MAT
					@nlin,25 psay substr(TMP->RA_NOME,1,25)
					@nlin,105 psay alltrim(TMP->RA_CC)
					nlin++
					@nlin,105 psay alltrim(_cNome)
					nlin++
					_cMat := TMP->ZB8_MAT
					nlin++			
					@nlin,23 psay "Quantidade               Tipo                 Descricao               
					nlin++
				endif                 


				while QRY2->(!eof())			  
					//@nlin,05 psay TMP->ZB8_MAT
					//@nlin,15 psay stod(TMP->ZB8_DATA)
					@nlin,28 psay QRY2->QUANT
					@nlin,48 psay QRY2->ZB8_TPREF
					@nlin,68 psay QRY2->ZB8_DESCTP
					nlin+=2				

					QRY2->(dbSkip())	
				enddo                    					      			
				_flag := TMP->(ZB8_MAT+ZB8_TPREF)				
			endif	 
		endif	


		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo    



	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Finaliza a execucao do relatorio...                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	SET DEVICE TO SCREEN

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se impressao em disco, chama o gerenciador de impressao...          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

Static Function buscCafe(_dData,_cCodRef, _cMat)


	_cQuery1 := " SELECT  COUNT(ZB8_CODREF) AS QUANT, ZB8_CODREF,ZB8_DSCREF "
	_cQuery1 += " FROM " + retSqlTab('ZB8') 
	_cQuery1 += " WHERE " + retSqlFil('ZB8')
	_cQuery1 += " AND ZB8_MAT = '" + _cMat + "' AND ZB8_CODREF = '" + _cCodRef +"'"
	_cQuery1 += " AND ZB8_DATA = '" + _dData + "'"
	_cQuery1 += " AND " + retSqlDel('ZB8') + " AND ZB8_TPREF <> '006'"
	_cQuery1 += " GROUP BY ZB8_CODREF, ZB8_DSCREF
	_cQuery1 += " HAVING COUNT(ZB8_CODREF) > 1
	_cQuery1 += " ORDER BY ZB8_CODREF


	_cQuery1  := ChangeQuery(_cQuery1)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY1") != 0
		QRY1->(dbCloseArea())
	Endif

	TCQUERY _cQuery1 NEW ALIAS "QRY1"



return


Static Function buscRef(_dData,_cTpRef,_cMat)



	_cQuery2 := " SELECT  COUNT(ZB8_TPREF) AS QUANT, ZB8_TPREF,ZB8_DESCTP "
	_cQuery2 += " FROM " + retSqlTab('ZB8') 
	_cQuery2 += " WHERE " + retSqlFil('ZB8')
	_cQuery2 += " AND ZB8_MAT = '" + _cMat + "' AND ZB8_TPREF = '006'"
	_cQuery2 += " AND ZB8_DATA = '" + _dData + "'"// AND ZB8_CODREF = '" + _cCodRef +"'"
	_cQuery2 += " AND " + retSqlDel('ZB8')
	_cQuery2 += " GROUP BY ZB8_TPREF, ZB8_DESCTP
	_cQuery2 += " HAVING COUNT(ZB8_TPREF) > 1
	_cQuery2 += " ORDER BY ZB8_TPREF


	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "QRY2"

return


Static Function GeraTMP()   

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return



/*_cQuery := " SELECT  ZB8_DATA,ZB8_MAT,RA_NOME, ZB8_TPREF, ZB8_DESCTP,COUNT(ZB8_TPREF) AS QUANT, ZB8_CODREF "
_cQuery += " FROM " + retSqlTab('ZB8') + " , " + retSqlTab('SRA')
_cQuery += " WHERE " + retSqlFil('ZB8') + " AND " + retSqlFil('SRA')
_cQuery += " AND ZB8_MAT = RA_MAT"              
_cQuery += " AND ZB8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
_cQuery += " AND " + retSqlDel('ZB8') + " AND " + retSqlDel('SRA')
_cQuery += " GROUP BY ZB8_DATA,ZB8_MAT, ZB8_TPREF, ZB8_DESCTP,RA_NOME, ZB8_CODREF
_cQuery += " HAVING COUNT(ZB8_TPREF) > 1
_cQuery += " ORDER BY ZB8_DATA,ZB8_MAT,ZB8_TPREF
*/


/*if TMP->ZB8_MAT == _cMat	                       
TMP->(dbSkip())			
loop
else
buscRef(TMP->ZB8_DATA,TMP->ZB8_TPREF,TMP->ZB8_MAT)					
endif


if TMP->ZB8_TPREF == tpRef
TMP->(dbSkip())			
loop
else
buscRef(TMP->ZB8_DATA,TMP->ZB8_TPREF,TMP->ZB8_MAT)					
tpRef := TMP->ZB8_TPREF
endif	*/	



/*if TMP->ZB8_MAT == _cMat	                       
TMP->(dbSkip())			
loop
else
buscCafe(TMP->ZB8_DATA,TMP->ZB8_CODREF,TMP->ZB8_MAT)
endif

if TMP->ZB8_CODREF == codref
TMP->(dbSkip())			
loop		
else
buscCafe(TMP->ZB8_DATA,TMP->ZB8_CODREF,TMP->ZB8_MAT)
codRef := TMP->ZB8_CODREF
endif */ 


/*	@nlin,05 psay stod(TMP->ZB8_DATA) 
@nlin,15 psay TMP->ZB8_MAT
@nlin,23 psay substr(TMP->RA_NOME,1,25)
@nlin,53 psay TMP->TPREF
@nlin,61 psay substr(TMP->ZB8_DESCTP,1,25)
@nlin,89 psay transform(TMP->QUANT,'@E 9.999')
nlin++   
*/		       		
