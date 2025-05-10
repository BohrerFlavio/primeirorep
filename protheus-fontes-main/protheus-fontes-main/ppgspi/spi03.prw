#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SPI03     º Autor ³ Giuliano Forgiariniº Data ³  22/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina destinada a apuração de apontamentos de produção no º±±
±±º          ³ setor de embalagem                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PPGSPI - Giuliano                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SPI03()
	Private _nCount   := 0   //Contador de registros
	Private _nTotal   := 0   //Total de produção em kg
	Private _nTEmb01P := 0
	Private _nTEmb01B := 0   
	Private _nTEmb02P := 0
	Private _nTEmb02B := 0   

	//Private cPerg   := "SPI03"

	if !MSGBOX('Realizar apuração de produção no setor de Embalagem Secundária?(S/N)','Apuração de Produção II','YESNO')
		return
	endif

	MsgRun("Realizando consulta ao Banco de Dados...",,{||ExecQuery()})   

	//Calcula total de registros da query gerada
	QRY->(DbGotop())
	While QRY->(!eof())
		_nCount++
		QRY->(DbSkip())
	enddo     

	Processa({||Calculo()},"PROCESSAMENTO EM EXECUÇÃO","Realizando calculo de produção...")

	Tela()

Return  


//Função destinada a processar query no Banco de Dados
Static Function ExecQuery()
	Local cQuery

	cQuery := " SELECT Z8_COD AS COD, Z8_BALAN AS EMB, SUM(Z8_PESO) AS PESO"
	cQuery += " FROM " + RetSQLTab('SZ8')
	cQuery += " WHERE " + RetSQLFil('SZ8') + " AND Z8_FIL = '" + cFilAnt + "' AND Z8_DATA = '" + DTOS(DDataBase) + "' AND "
	cQuery += " Z8_BALAN LIKE 'EMB%' AND Z8_DATAE = '' AND Z8_TERC = '' AND " + RetSQLDel('SZ8')   
	cQuery += " GROUP BY Z8_COD, Z8_BALAN "         

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


//Função destinada a realização do calculo e distribuição nas faixas da produção
Static Function Calculo()

	ProcRegua(_nCount)

	//Início do processamento do arquivo temporário gerado
	//pela query
	QRY->(DbGotop())
	While QRY->(!eof()) 

		incProc('Processando produto de código: ' + QRY->COD)

		DbSelectArea('SB1')

		_cCodE := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COD,'B1_CTARASE')
		_cEmb  := fBuscaCPO('ZAB',1,xfilial('ZAB')+_cCodE,'ZAB_TARA')

		do case
			case _cEmb < 2.100  .and. QRY->EMB = 'EMB01' //Caixas pardas da EMB01
			_nTEmb01P += QRY->PESO
			case _cEmb >= 2.100 .and. QRY->EMB = 'EMB01' //Caixas brancas da EMB01
			_nTEmb01B += QRY->PESO
			case _cEmb < 2.100  .and. QRY->EMB = 'EMB02' //Caixas pardas da EMB02
			_nTEmb02P += QRY->PESO
			case _cEmb >= 2.100 .and. QRY->EMB = 'EMB02' //Caixas brancas da EMB02
			_nTEmb02B += QRY->PESO
			otherwise    
			alert('Falha produto: ' + QRY->COD + '|   |  Tara :' + str(_cEmb)+ '|   |  Balança :' + QRY->EMB)
		endcase

		_nTotal += QRY->PESO  

		QRY->(DbSkip())
	enddo

return     


//Tela final de exibição do resultado de processamento
Static Function Tela()  
	Local _cMostra := ''

	_cMostra := 'Total de Produção:..........' + transform(_nTotal,'@E 999,999.99') + CHR(13)+CHR(10)

	_cMostra += CHR(13)+CHR(10)

	_cMostra += 'EMB01 Pardas :................' + transform(_nTEmb01P,'@E 999,999.99') +CHR(13)+CHR(10) +;
	'EMB01 Brancas:................' + transform(_nTEmb01B,'@E 999,999.99') +CHR(13)+CHR(10) +;   
	'EMB02 Pardas :................' + transform(_nTEmb02P,'@E 999,999.99') +CHR(13)+CHR(10) +;
	'EMB02 Brancas:................' + transform(_nTEmb02B,'@E 999,999.99') +CHR(13)+CHR(10)

	@ 116,090 To 400,330 Dialog oDlg Title "Resultado"
	@ 005,005 Get _cMostra Size 110,110 MEMO Object oMemo
	Activate Dialog oDlg Centered
return         

