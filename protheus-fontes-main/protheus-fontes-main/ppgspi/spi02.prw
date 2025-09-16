#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SPI02     º Autor ³ Giuliano Forgiariniº Data ³  22/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina destinada a apuração de apontamentos de produção porº±±
±±º          ³faixas de complexidade de produção                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PPGSPI - Giuliano                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SPI02()
	Private _nCount    := 0   //Contador de registros
	Private _lVer      := .t. //Verificador de integridade de processo
	Private _aLog      := {}  //Vetor que serve de log para codigos sem integridade
	Private _aProducao := {}  //Vetor para armazenamento da apuração da produção por classes de complexidade   
	Private _nTotal    := 0   //Total de produção em kg

	if !MSGBOX('Realizar apuração de produção no setor de Embalagem Secundária?(S/N)','Apuração de Produção','YESNO')
		return
	endif

	MsgRun("Realizando consulta ao Banco de Dados...",,{||ExecQuery()})   

	//Calcula total de registros da query gerada
	QRY->(DbGotop())
	While QRY->(!eof())
		_nCount++
		QRY->(DbSkip())
	enddo     

	if _nCount <> 0
		Processa({||Verifica()},"INÍCIO DE PROCESSO","Realizando consistencia dos produtos...")  
		if len(_aLog) = 0  
			Processa({||Calculo()},"PROCESSAMENTO EM EXECUÇÃO","Realizando calculo de produção...")
		else
			alert('Inconsistencia de dados') 
			TelaLog()
			_lVer := .f.
		endif
	else
		alert('Produção não foi encontrada nesta data base!')
		_lVer := .f.
	endif

	if _lVer
		Tela()
	endif

Return  


//Função destinada a processar query no Banco de Dados
Static Function ExecQuery()
	Local cQuery

	cQuery := " SELECT Z8_COD AS COD, SUM(Z8_PESO) AS PESO"
	cQuery += " FROM " + RetSQLTab('SZ8')
	cQuery += " WHERE " + RetSQLFil('SZ8') + " AND Z8_FIL = '" + cFilAnt + "' AND Z8_DATA = '" + DTOS(DDataBase) + "' AND "
	cQuery += " Z8_BALAN LIKE 'EMB%' AND Z8_DATAE = '' AND Z8_TERC = '' AND " + RetSQLDel('SZ8')   
	cQuery += " GROUP BY Z8_COD "         

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

//Função destinada a verificação do cadastro de produtos
Static Function Verifica()
	Local _cFlag := ''
	Local _nFlag := 0

	QRY->(DbGotop())
	While QRY->(!eof())

		//Verificação do campo B1_LIMPEZA do cadastro de produtos
		_nFlag := 0
		_nFlag := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COD,'B1_LIMPEZA')
		if _nFlag = 0
			aadd(_aLog,{QRY->COD,'B1_LIMPEZA'})
		else
			_nFlag := 0
		endif

		//Verificação do campo B1_PADRAO do cadastro de produtos
		_nFlag := 0
		_nFlag := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COD,'B1_PADRAO')
		if _nFlag = 0
			aadd(_aLog,{QRY->COD,'B1_PADRAO'})
		else
			_nFlag := 0
		endif

		//Verificação do campo B1_TARAP do cadastro de produtos     
		_cCodT := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COD,'B1_CTARAP')
		_cFlag := ''
		_cFlag := fBuscaCPO('ZAB',1,xfilial('ZAB')+_cCodT,'ZAB_FORMA')
		if empty(_cFlag)
			aadd(_aLog,{QRY->COD,'ZAB_FORMA'})
		else
			_cFlag := ''
		endif

		//Verificação do campo X5_DESCENG da tabela de Famílias de Produtos
		_cCodF := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COD,'B1_FAM')    
		_cFlag := ''
		_cFlag := fBuscaCPO('SX5',1,xfilial('SX5')+'PS'+_cCodF,'X5_DESCENG')
		if empty(_cFlag)
			aadd(_aLog,{QRY->COD,'X5_DESCENG'})
		else
			_cFlag := ''
		endif

		QRY->(DbSkip())
	enddo 

return


//Função destinada a realização do calculo e distribuição nas faixas da produção
Static Function Calculo()
	Local _nSkn   := 0  		//Quantitativo para skinner 
	Local _cSkn   := '' 		//Qualitativo para skinner
	Local _nLmp   := 0  		//Quantitativo para limpeza
	Local _nMnf   := 0  		//Quantitativo para manufatura  
	Local _cMnf   := '' 		//Qualitativo para manufatura
	Local _nPdr   := 0  		//Quantitativo para padronização
	Local _nCor   := 0  		//Quantitativo para corte de origem
	Local _cCor   := '' 		//Qualitativo para corte de origem
	Local _nEmb   := 0  		//Quantitativo para embalagem
	Local _cEmb   := '' 		//Qualitativo para embalagem   
	Local _cCodE  := '' 		//Auxiliar para apuração da embalagem 
	Local _nFam   := 0  		//Quantitativo para família de produto
	Local _cFam   := '' 		//Qualitativo para família de produto   
	Local _cCodF  := '' 		//Auxiliar para apuração da família 
	Local _nIdx   := 0  		//Indice de complexidade  
	Local _nNivel := 0      //Nível de complexidade

	ProcRegua(_nCount)


	//Início do processamento do arquivo temporário gerado
	//pela query
	QRY->(DbGotop())
	While QRY->(!eof()) 

		incProc('Processando produto de código: ' + QRY->COD)

		DbSelectArea('SB1')

		//Apuraçao do valor - Embalagem  - peso 1
		_cCodE := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COD,'B1_CTARAP')
		_cEmb  := fBuscaCPO('ZAB',1,xfilial('ZAB')+_cCodE,'ZAB_FORMA')
		_nEmb := iif(_cEmb = 'V',3,iif(_cEmb = 'I',2,1)) * 0.33333333             //Apuração do valor normalizado
		_nEmb := _nEmb * 1                                                //Atribuição do peso ao atributo   
		//Apuraçao do valor - Manufatura - peso 2       
		_cMnf := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COD,'B1_MANUFAT')
		_nMnf := iif(_cMnf = 'P',1,0)                                              //Apuração do valor normalizado
		_nMnf := _nMnf * 2                                                //Atribuição do peso ao atributo
		//Apuraçao do valor - Skinner - peso 3 
		_cSkn := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COD,'B1_SKINNER') 
		_nSkn := iif(_cSkn = 'S',1,0)                                            //Apuração do valor normalizado
		_nSkn := _nSkn * 3                                                //Atribuição do peso ao atributo
		//Apuraçao do valor - Corte de Origem - peso 4     
		_cCor := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COD,'B1_CORORI')
		_nCor := iif(_cCor = 'T',3,iif(_cCor = 'C',2,1)) * 0.33333333             //Apuração do valor normalizado
		_nCor := _nCor * 4                                                //Atribuição do peso ao atributo
		//Apuraçao do valor - Limpeza - peso 5
		_nLmp := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COD,'B1_LIMPEZA') * 0.25    //Apuração do valor normalizado
		_nLmp := _nLmp * 5                                                //Atribuição do peso ao atributo
		//Apuraçao do valor - Padronização - peso 6       
		_nPdr := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COD,'B1_PADRAO') * 0.25     //Apuração do valor normalizado
		_nPdr := _nPdr * 6                                                //Atribuição do peso ao atributo
		//Apuraçao do valor - Famílias de produtos - peso 7
		_cCodF := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COD,'B1_FAM')
		_cFam  := fBuscaCPO('SX5',1,xfilial('SX5')+'PS'+_cCodF,'X5_DESCENG')
		_nFam := val(_cFam) * 0.2                                                    //Apuração do valor normalizado
		_nFam := _nFam * 7                                                //Atribuição do peso ao atributo  

		//Construção do índice de complexidade do produto em processamento (utilizando calculo de média ponderada)
		_nIdx := (_nFam + _nPdr + _nLmp + _nCor + _nSkn + _nMnf + _nEmb)/28
		//Pesos:          7        6      5       4       3       2       1

		//Determina o nível de complexidade de produção e faz o 
		//somatório dos valores produzidos em peso
		do case
			case _nIdx >= 0.257738095  .and. _nIdx < 0.341592262               //Nivel 01
			_nPos := aScan(_aProducao,{|aVal|aVal[1] = '01'})		
			if _nPos <> 0
				_aProducao[_nPos,2] += QRY->PESO
				_aProducao[_nPos,3] += '|'+QRY->COD
			else
				aadd(_aProducao,{'01',QRY->PESO,'|' + QRY->COD})
			endif   
			_nNivel := 1      
			case _nIdx >= 0.341592262  .and. _nIdx < 0.425446429              //Nivel 02
			_nPos := aScan(_aProducao,{|aVal|aVal[1] = '02'})		
			if _nPos <> 0
				_aProducao[_nPos,2] += QRY->PESO      
				_aProducao[_nPos,3] += '|'+QRY->COD            
			else
				aadd(_aProducao,{'02',QRY->PESO,'|' + QRY->COD})
			endif    
			_nNivel := 2

			case _nIdx >= 0.425446429  .and. _nIdx < 0.509300595             //Nivel 03
			_nPos := aScan(_aProducao,{|aVal|aVal[1] = '03'})		
			if _nPos <> 0
				_aProducao[_nPos,2] += QRY->PESO        
				_aProducao[_nPos,3] += '|'+QRY->COD            
			else
				aadd(_aProducao,{'03',QRY->PESO,'|' + QRY->COD})
			endif
			_nNivel := 3

			case _nIdx >= 0.509300595  .and. _nIdx < 0.593154762            //Nivel 04
			_nPos := aScan(_aProducao,{|aVal|aVal[1] = '04'})		
			if _nPos <> 0
				_aProducao[_nPos,2] += QRY->PESO     
				_aProducao[_nPos,3] += '|'+QRY->COD            
			else
				aadd(_aProducao,{'04',QRY->PESO,'|' + QRY->COD})
			endif       
			_nNivel := 4


			case _nIdx >= 0.593154762  .and. _nIdx < 0.677008929            //Nivel 05
			_nPos := aScan(_aProducao,{|aVal|aVal[1] = '05'})		
			if _nPos <> 0
				_aProducao[_nPos,2] += QRY->PESO
				_aProducao[_nPos,3] += '|'+QRY->COD                        
			else
				aadd(_aProducao,{'05',QRY->PESO,'|' + QRY->COD})
			endif       
			_nNivel := 5

			case _nIdx >= 0.677008929 .and. _nIdx < 0.760863095            //Nivel 06
			_nPos := aScan(_aProducao,{|aVal|aVal[1] = '06'})		
			if _nPos <> 0
				_aProducao[_nPos,2] += QRY->PESO        
				_aProducao[_nPos,3] += '|'+QRY->COD                        
			else
				aadd(_aProducao,{'06',QRY->PESO,'|' + QRY->COD})
			endif       
			_nNivel := 6         

			case _nIdx >= 0.760863095  .and. _nIdx < 0.844717262            //Nivel 07
			_nPos := aScan(_aProducao,{|aVal|aVal[1] = '07'})		
			if _nPos <> 0
				_aProducao[_nPos,2] += QRY->PESO 
				_aProducao[_nPos,3] += '|'+QRY->COD                        
			else
				aadd(_aProducao,{'07',QRY->PESO,'|' + QRY->COD})       	         
			endif
			_nNivel := 7

			case _nIdx >= 0.844717262 .and. _nIdx <= 0.928571430              //Nivel 08
			_nPos := aScan(_aProducao,{|aVal|aVal[1] = '08'})		
			if _nPos <> 0
				_aProducao[_nPos,2] += QRY->PESO        
				_aProducao[_nPos,3] += '|'+QRY->COD                        
			else
				aadd(_aProducao,{'08',QRY->PESO,'|' + QRY->COD})
			endif
			_nNivel := 8

			otherwise
			//Caso haja erro de calculo de faixa, mostra mensagem para ajuste
			alert('Erro de faixa produto: ' + QRY->COD + '   ' + 'Faixa: ' + str(_nIdx) + CHR(13) + CHR(10)+;
			'|Emb: ' + str(_nEmb/1) + '|Mnf: ' + str(_nMnf/2) + '|Skn: '+ str(_nSkn/3) +;
			'|Cor: ' + str(_nCor/4) + '|Lmp: ' + str(_nLmp/5) + '|Pdr: ' +str(_nPdr/6) + '|Fam: '+ str(_nFam/7))
			_nNivel := 0

		endcase


		DbSelectArea('SB1')
		SB1->(DbSetOrder(1))
		if SB1->(DbSeek(xfilial('SB1')+QRY->COD))
			reclock('SB1',.f.)
			SB1->B1_NIVEL := _nNivel
			msunlock()
		endif


		//Totalizador de produção
		_nTotal += QRY->PESO

		QRY->(DbSkip())
	enddo

	if len(_aProducao) = 0
		alert('Retorno de valores inválidos!')
		_lVer := .f.
	endif

return     


//Tela final de exibição do resultado de processamento
Static Function Tela()  
	Local _cMostra := ''
	Local i
	aSort(_aProducao,,,{|x,y| x[1] < y[1]})

	_cMostra := 'Total de Produção:..........' + transform(_nTotal,'@E 999,999.99') + CHR(13)+CHR(10)

	for i := 1 to len(_aProducao)
		_cMostra += CHR(13)+CHR(10) +  'Produção Nível ' + _aProducao[i,1] + ':..........' +;
		transform(_aProducao[i,2],'@E 999,999.99')+;
		CHR(13)+CHR(10) + _aProducao[i,3] +;
		CHR(13)+CHR(10)
	next

	@ 116,090 To 400,330 Dialog oDlg Title "Resultado"
	@ 005,005 Get _cMostra Size 110,110 MEMO Object oMemo
	Activate Dialog oDlg Centered
return         


//Tela de Logs de inconsistencias encontradas
Static Function TelaLog()  
	Local _cMostra := ''
	Local i
	
	aSort(_aLog)

	for i := 1 to len(_aLog)
		_cMostra += _aLog[i,1] + ':  ' + _aLog[i,2] + CHR(13)+CHR(10)
	next

	//	* Mostrar a consulta */
	@ 116,090 To 416,707 Dialog oDlg Title "Logs"
	@ 055,005 Get _cMostra Size 250,080 MEMO Object oMemo
	Activate Dialog oDlg Centered
return
