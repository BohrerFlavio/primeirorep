#INCLUDE "rwmake.ch"    
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF122  บAutor  ณGiuliano Forgiariniบ    Data ณ  11/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta็ใo de arquivos XML de fornecedores                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณContabilidade                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User FuncTion GJF122()


	cPerg := "GJF122"

	If ( Pergunte( cPerg,.T. ) )
		Processa( {|| Runproc() },"Realizando Query para gera็ใo de arquivos..." )
	EndIf

Return()

//Funcao de Processamento RunPRoc()
Static Function RunPRoc()

	Local _cQuery
	Local _cNomArq 
	Local _cString 
	Local _lOk      := .f.

	_cQuery := "SELECT F1_DOC AS DOC, F1_FORNECE AS FORNECE, F1_LOJA AS LOJA, F1_SERIE AS SERIE FROM "+RetSqlName("SF1")+" SF1 " 
	_cQuery += " WHERE SF1.D_E_L_E_T_ <> '*' "
	_cQuery += " AND SF1.F1_FILIAL = '"         + xFilial( "SF1" ) + "' "  
	_cQuery += " AND SF1.F1_DOC BETWEEN '"      + mv_par01 + "' AND '" + mv_par02 + "' "
	_cQuery += " AND SF1.F1_SERIE BETWEEN '"    + mv_par03 + "' AND '" + mv_par04 + "' "
	_cQuery += " AND SF1.F1_FORNECE BETWEEN '"  + mv_par05 + "' AND '" + mv_par06 + "' " 
	_cQuery += " AND SF1.F1_LOJA BETWEEN '"     + mv_par07 + "' AND '" + mv_par08 + "' " 
	_cQuery += " AND SF1.F1_EMISSAO BETWEEN '"  + DtoS(mv_par09) + "' AND '" + DtoS(mv_par10) + "' "	          
	_cQuery += " AND SF1.F1_DTDIGIT BETWEEN '"  + DtoS(mv_par11) + "' AND '" + DtoS(mv_par12) + "' "
	_cQuery += " ORDER BY SF1.F1_DOC"                                         


	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo


	If Select("QRYAUX")<>0
		QRYAUX->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRYAUX"

	ProcRegua(LastRec())

	dbSelecTarea("QRYAUX")
	dbGoTop()

	While QRYAUX->(!Eof() )

		_cString := '' 
		_cNomArq := QRYAUX->(FORNECE + LOJA + DOC + SERIE)       
		_cString := fBuscaCPO('SF1',1,xfilial('SF1')+QRYAUX->(DOC+SERIE+FORNECE+LOJA),'F1_CODXML')
		if !empty(_cString)
			GeraArquivo(_cNomArq,_cString) 
			_lOk := .t.
		endif  

		QRYAUX->(DbSkip()) 
	EndDo 

	If Select("QRYAUX")<>0
		QRYAUX->(dbCloseArea())
	Endif

	if _lOk
		alert('Arquivos gerados com sucesso!')
	endif

ReTurn

//Para gerar o arquivo   
Static Function GeraArquivo(_Nome,_String)
	Local _cNomeArq  := _Nome + '.xml' 
	Local cArqXML    := alltrim(mv_par13) + _cNomeArq
	Local nHdl       := fCreate(cArqXML)

	fWrite(nHdl,_String,Len(_String))

	fClose(nHdl)

Return
