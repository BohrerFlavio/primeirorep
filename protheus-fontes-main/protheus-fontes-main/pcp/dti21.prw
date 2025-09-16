#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI21    บ Autor ณ Mauricio Roehrsบ Data ณ  01/02/17		  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Acompanhamento do picking de caixas On-line                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCP		                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function DTI21()  

	aObjects            := {}                                                                 
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           :=aPosObj[1]                                                            
	aX[3]        +=60                                                    
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	Private aBrowse1 := {}

	//Cabe็alhos das colunas  
	aHeader1 := {'Status		',;
	'Stat. Picking ',;
	'Dt. Carreg.   ',;
	'Pre-Carreg.	',;
	'Obs.		 	',;
	'Usuario		',;
	'% Separada	'}
	//Largura das colunas
	aLargCol1 := {20,20,10,10,60,10,10}


	DEFINE DIALOG oDlg TITLE "Acompanhamento Picking" FROM aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] PIXEL		
	// Cria Browse		
	oBrowse1 := TCBrowse():New(00,20,530,280,,aHeader1,aLargCol1,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )			

	MsgRun("Aguarde... Realizando contagem dos registros...",,{||AtuBrow()})	

	TButton():New( 010,600, "Atualizar" 	, oDlg,{||MsgRun("Aguarde... Realizando contagem dos registros...",,{||AtuBrow(1)})},50,010,,,.F.,.T.,.F.,,.F.,,,.F. ) 	 
	TButton():New( 025,600, "Bloquear"  	, oDlg,{||bloquear(aBrowse1[oBrowse1:nAt,04])  },50,010,,,.F.,.T.,.F.,,.F.,,,.F. )	                            
	TButton():New( 040,600, "Liberar"   	, oDlg,{||liberar(aBrowse1[oBrowse1:nAt,04])   },50,010,,,.F.,.T.,.F.,,.F.,,,.F. )	                            
	TButton():New( 055,600, "Relatorio" 	, oDlg,{||u_dti30() },50,010,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New( 070,600, "Fechar"    	, oDlg,{||oDlg:end()   },50,010,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New( 100,600, "Somente Porc." , oDlg,{||MsgRun("Aguarde... Realizando contagem dos registros...",,{||AtuBrow(2)})},50,010,,,.F.,.T.,.F.,,.F.,,,.F. ) 
	TButton():New( 115,600, "Remove  Porc." , oDlg,{||MsgRun("Aguarde... Realizando contagem dos registros...",,{||AtuBrow(3)})},50,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 130,600, "Todos" 		, oDlg,{||MsgRun("Aguarde... Realizando contagem dos registros...",,{||AtuBrow(1)})},50,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 145,600, "Resumo de carga" 	, oDlg,{||u_gjf41() },50,010,,,.F.,.T.,.F.,,.F.,,,.F. )   

	ACTIVATE DIALOG oDlg CENTERED 

Return 


//Fun็ใo destinada a montagem do array de registros
Static Function montaArray(_nOpc)  

	Local _cCondicao := " "
	// Vetor com elementos do Browse
	aBrowse1 := {}		

	if _nOpc == 2
		_cCondicao := " INNER JOIN " + retSqlTab('ZZ4') + " (NOLOCK) ON ZZ4_PRECAR = ZZ3_NUM AND " +retSqlDel('ZZ4')
		_cCondicao += " INNER JOIN " + retSqlTab('ZZ5') + " (NOLOCK) ON ZZ4_NUM = ZZ5_NUM AND " +retSqlDel('ZZ5')
		_cCondicao += " INNER JOIN " + retSqlTab('SB1') + " (NOLOCK) ON B1_COD = ZZ5_COD AND SUBSTRING(B1_GRUPO,1,2) = '56' AND B1_SEGUM = 'CX'"
	elseif _nOpc == 3
		_cCondicao := " INNER JOIN " + retSqlTab('ZZ4') + " (NOLOCK) ON ZZ4_PRECAR = ZZ3_NUM AND " +retSqlDel('ZZ4')
		_cCondicao += " INNER JOIN " + retSqlTab('ZZ5') + " (NOLOCK) ON ZZ4_NUM = ZZ5_NUM AND " +retSqlDel('ZZ5')
		_cCondicao += " INNER JOIN " + retSqlTab('SB1') + " (NOLOCK) ON B1_COD = ZZ5_COD AND SUBSTRING(B1_GRUPO,1,2) <> '56' AND B1_SEGUM = 'CX'"
 	endif

	_cQuery := " SELECT ZZ3_NUM AS NUMERO, ZZ3_DTCAR AS DTCAR,ZZ3_OBS AS OBS,ZZ3_STPCK AS STPCK, ZZ3_USRPCK AS USRPCK
	_cQuery += " FROM " + retSqlTab('ZZ3') + "(NOLOCK)"
	_cQuery += _cCondicao
	_cQuery += " WHERE " + retSqlFil('ZZ3')
	_cQuery += " AND ZZ3_DTCAR BETWEEN '"+dtos(ddatabase-1)+"' AND '"+dtos(ddatabase+1)+"'"
	_cQuery += " AND ZZ3_STATUS NOT IN ('E','F')
	_cQuery += " AND " + retSqlDel('ZZ3')
	_cQuery += " GROUP BY ZZ3_NUM, ZZ3_DTCAR, ZZ3_OBS, ZZ3_STPCK, ZZ3_USRPCK"
	_cQuery += " ORDER BY ZZ3_DTCAR, ZZ3_NUM

	_cQuery  := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"      

	QRY->(dbGoTop())
	while QRY->(!eof())										

		aadd(aBrowse1,{RetCores(QRY->STPCK),;
		retStat(QRY->STPCK),;
		stod(QRY->DTCAR),;
		QRY->NUMERO,;
		QRY->OBS,;
		QRY->USRPCK,;
		transform(round(percent(QRY->NUMERO,_nOpc),0),'@E 999')+'%'})	  

		QRY->(dbSkip())			
	enddo

return 


//Fun็ใo destinada a atualiza็ใo do browse pelo timer
Static Function AtuBrow(_nOpc) //_nOpc = 1 Todos, _nOpc = 2 S๓ Porcionados

	montaArray(_nOpc)

	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],;
	aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],aBrowse1[oBrowse1:nAT,06],aBrowse1[oBrowse1:nAT,07]}}

	oBrowse1:nScrollType := 1
	oBrowse1:bLDblClick  := {|| pckDet(aBrowse1[oBrowse1:nAt,04],_nOpc) }

	oBrowse1:DrawSelect()
	oBrowse1:refresh()	

	oDlg:refresh()

return   

//retorna as cores  
Static Function RetCores(_Stt)
	local ret   := 	iif(_Stt = 'B', LoadBitmap(GetResources(),'br_azul'),iif(_Stt = 'L',LoadBitmap(GetResources(),'br_verde'),;
	iif(_Stt = 'P', LoadBitmap(GetResources(),'br_amarelo'),iif(_Stt = 'S',LoadBitmap(GetResources(),'br_laranja'),;
	iif(_Stt = 'E', LoadBitmap(GetResources(),'br_vermelho'),iif(_Stt = 'F',LoadBitmap(GetResources(),'br_preto'),''))))))



return  ret 

//retorna o status
Static Function retStat(_Stt)

	local St    :=  iif(_Stt = 'B', 'Bloqueado',iif(_Stt = 'L','Liberado',;
	iif(_Stt = 'P', 'Picking  ',iif(_Stt = 'S','Espera  ',;
	iif(_Stt = 'E', 'Encerrado',iif(_Stt = 'F','Faturado',''))))))


return St

//Fun็ใo para picking detalhado 
Static Function pckDet(_carreg,_nOpc)

	aBrowse2 := {}

	//Cabe็alhos das colunas  
	aHeader2 := {'Codigo       ',;
	'Descri็ใo    ',;
	'Prev. Caixa  ',;
	'Realiz. Caixa'}
	//Largura das colunas
	aLargCol2 := {30,100,20,20}

	MsgRun("Aguarde... Realizando contagem do carreg " + _carreg ,,{||MontaA2(_carreg,_nOpc)})

	DEFINE DIALOG oDlg2 TITLE "Detalhes do Picking" FROM aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] PIXEL		

	// Cria Browse		
	oBrowse2 := TCBrowse():New(00,20,550,280,,aHeader2,aLargCol2,oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )		

	AtuBrow2()

	TButton():New( 015,600, "Atualizar"  , oDlg2,{||Atualiza(_carreg,_nOpc)},40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) 	 
	TButton():New( 060,600, "Fechar"     , oDlg2,{||oDlg2:end()   },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )   

	ACTIVATE DIALOG oDlg2 CENTERED 

Return 


//Fun็ใo destinada a atualiza็ใo do 2บ browse de detalhamento
Static Function AtuBrow2()

	oBrowse2:SetArray(aBrowse2)

	// Monta a linha a ser exibina no Browse                                       
	if len(aBrowse2) <= 0 //verifica se tem algo no vetor para nใo dar error.log
		oBrowse2:bLine := {||{'','',0,0}}	
	else
		oBrowse2:bLine := {||{aBrowse2[oBrowse2:nAt,01],aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],aBrowse2[oBrowse2:nAT,04]}}
	endif      

	oBrowse2:nScrollType := 1

	oBrowse2:DrawSelect()
	oBrowse2:refresh()

return       

//Fun็ใo que faz o calculo de produto a produto
Static Function Calculo(preCarr,_cod) 

	_cQuery3 := " SELECT COUNT(Z8_PICKING) AS SEPARADO 
	_cQuery3 += " FROM " + retSqlTab('SZ8') 
	_cQuery3 += " WHERE " + retSqlFil('SZ8')
	_cQuery3 += " AND Z8_CARPICK = '" + preCarr + "' AND Z8_FIL = '"+cFilAnt+"'"
	_cQuery3 += " AND Z8_COD = '" + _cod + "' AND Z8_PICKING = 'S'"
	_cQuery3 += " AND " + retSqlDel('SZ8')

	_cQuery3  := ChangeQuery(_cQuery3)

	If Select("QRY3") != 0
		QRY3->(dbCloseArea())
	Endif

	TCQUERY _cQuery3 NEW ALIAS "QRY3"                                                

	QRY3->(dbGoTop())

return iif(QRY3->SEPARADO > 0, QRY3->SEPARADO, 0)

//Fun็ใo destinada a sele็ใo dos produtos(em caixas) que vใo na consulta
Static Function SeleProd(preCarr,_nOpc)    

	
	_cQuery2 := " SELECT ZZ5_COD, SUM(ZZ5_QPCAIX) AS PREVISTO
	_cQuery2 += " FROM " + retSqlTab('ZZ5') + ", " + retSqlTab('ZZ4') + " , " + retSqlTab('SB1') 
	_cQuery2 += " WHERE " + retSqlFil('ZZ5') + " AND " + retSqlFil('ZZ4') + " AND " + retSqlFil('SB1')
	_cQuery2 += " AND ZZ4_PRECAR = '" + preCarr + "'
	_cQuery2 += " AND ZZ5_NUM = ZZ4_NUM 
	_cQuery2 += " AND B1_COD = ZZ5_COD AND B1_SEGUM = 'CX'
	if _nOpc == 2
		_cQuery2 += " AND SUBSTRING(B1_GRUPO,1,2) = '56'"
	elseif _nOpc == 3
		_cQuery2 += " AND SUBSTRING(B1_GRUPO,1,2) <> '56'"
	endif 
	_cQuery2 += " AND " + retSqlDel('ZZ5') + "  AND " + retSqlDel('ZZ4') +" AND " + retSqlDel('SB1')
	_cQuery2 += " GROUP BY ZZ5_COD
	_cQuery2 += " ORDER BY ZZ5_COD

	_cQuery2  := ChangeQuery(_cQuery2)

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "QRY2"      


return     

//monta array com os produtos do carregamento
Static Function MontaA2(_carreg,_nOpc)

	aBrowse2 := {}

	SeleProd(_carreg,_nOpc)
	QRY2->(dbGoTop())
	while QRY2->(!eof())				

		DbSelectArea('SB1')
		_cDescri := fBuscaCPO('SB1',1,xfilial('SB1')+QRY2->ZZ5_COD,'B1_DESC')
		aadd(aBrowse2,{padl(alltrim(QRY2->ZZ5_COD),6,'0'),;
		padl(substr(_cDescri,1,60),60,' '),;
		transform(QRY2->PREVISTO,'@E 9,999'),;
		transform(Calculo(_carreg,QRY2->ZZ5_COD),'@E 9,999')})

		QRY2->(DbSkip()) 

	enddo

return   

//fun็ใo para atualizar a consulta detalhada
Static Function Atualiza(_carreg,_nOpc)

	MsgRun("Aguarde... Realizando atualiza็ใo do carregamento " + _carreg ,,{||MontaA2(_carreg,_nOpc)}) 

	AtuBrow2()           

return

//liberar para picking
Static Function liberar(_carreg)

	ZZ3->(dbSetOrder(2))
	ZZ3->(dbGoTop())
	if ZZ3->(dbSeek(xFilial('ZZ3') + alltrim(_carreg)))
		if ZZ3->ZZ3_STPCK == 'L'
			alert('Status do Picking jแ encontra-se Liberado!')
		else
			reclock('ZZ3',.f.)
			ZZ3->ZZ3_STPCK  := 'L'
			ZZ3->ZZ3_USRPCK := ''
			ZZ3->ZZ3_LIBPCK := "S"
			msunlock()
			u_gjf31his('Liberado para picking','L')
			alert('Picking liberado com sucesso!')
		endif

	endif

return 

//bloquear o picking
Static Function bloquear(_carreg)

	ZZ3->(dbSetOrder(2))
	ZZ3->(dbGoTop())
	if ZZ3->(dbSeek(xFilial('ZZ3') + alltrim(_carreg)))
		if ZZ3->ZZ3_STPCK == 'B'
			alert('Status do Picking jแ encontra-se Bloqueado!')
		else
			reclock('ZZ3',.f.)
			ZZ3->ZZ3_STPCK  := 'B'
			ZZ3->ZZ3_USRPCK := ''
			ZZ3->ZZ3_LIBPCK := "N"
			msunlock()
			u_gjf31his('Bloqueio do picking','B')
			alert('Picking bloqueado com sucesso!')
		endif
	endif

return


Static Function percent(_carreg,_nOpc)

	local _nPercent  := 0
	local _nPrevisto := 0
	local _nRealiz   := 0

	seleprod(_carreg,_nOpc)

	QRY2->(dbGoTop())
	while QRY2->(!eof())				

		_nRealiz   += Calculo(_carreg,QRY2->ZZ5_COD)
		_nPrevisto += QRY2->PREVISTO			   					
		QRY2->(DbSkip()) 

	enddo

	_nPercent := (_nRealiz * 100) / _nPrevisto

return _nPercent
