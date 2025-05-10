#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSPI04     บ Autor ณ Giuliano Forgiariniบ Data ณ  22/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina destinada a apura็ใo de jornadas de trabalho dos    บฑฑ
ฑฑบ          ณ setores de embalagem e desossa                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PPGSPI - Giuliano                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function SPI04()


	if !MSGBOX('Realizar apura็ใo de produ็ใo no setor de Embalagem Secundแria?(S/N)','Apura็ใo de Produ็ใo II','YESNO')
		return
	endif

	MsgRun("Realizando consulta ao Banco de Dados...",,{||ExecQuery()})   


	Tela()

Return  


//Fun็ใo destinada a processar query no Banco de Dados
Static Function ExecQuery()
	Local cQuery

	cQuery := " SELECT 'DESOSSA' AS SETOR, MIN(ZAJ_HORAS) AS HORA FROM " + RetSQLTab('ZAJ') + " WHERE ZAJ_DATAS = '" + DTOS(DDATABASE) + "' AND " + RetSQLFil('ZAJ') 
	cQuery += " AND ZAJ_PRECAR = '' AND " + RetSQLDel('ZAJ') + " UNION "
	cQuery += " SELECT 'DESOSSA' AS SETOR, MAX(ZAJ_HORAS) AS HORA FROM  " + RetSQLTab('ZAJ') + " WHERE ZAJ_DATAS = '" + DTOS(DDATABASE) + "' AND " + RetSQLFil('ZAJ')
	cQuery += " AND ZAJ_PRECAR = '' AND " + RetSQLDel('ZAJ') + " UNION "
	cQuery += " SELECT 'EMBALAGEM' AS SETOR, MIN(Z8_HORA) AS HORA FROM  " + RetSQLTab('SZ8') + " WHERE Z8_DATA = '" + DTOS(DDATABASE) + "' AND " + RetSQLFil('SZ8') 
	cQuery += " AND " + RetSQLDel('SZ8') + " AND Z8_FIL = '00' AND Z8_BALAN LIKE 'EMB%' UNION "
	cQuery += " SELECT 'EMBALAGEM' AS SETOR, MAX(Z8_HORA) AS HORA FROM  " + RetSQLTab('SZ8') + " WHERE Z8_DATA = '" + DTOS(DDATABASE) + "' AND " + RetSQLFil('SZ8') 
	cQuery += " AND " + RetSQLDel('SZ8') + " AND Z8_FIL = '00' AND Z8_BALAN LIKE 'EMB%'" 

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo 

	cQuery  := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

return


//Tela final de exibi็ใo do resultado de processamento
Static Function Tela()  
	Local _cMostra := ''

	_cMostra := 'INTERVALO DAS JORNADAS:'

	_cMostra += CHR(13)+CHR(10)

	QRY->(DbGoTop())
	while QRY->(!eof())
		_cMostra += QRY->SETOR + ': ' + QRY->HORA + CHR(13) + CHR(10)

		QRY->(DbSkip())
	enddo


	@ 116,090 To 400,330 Dialog oDlg Title "Resultado"
	@ 005,005 Get _cMostra Size 110,110 MEMO Object oMemo
	Activate Dialog oDlg Centered
return         

