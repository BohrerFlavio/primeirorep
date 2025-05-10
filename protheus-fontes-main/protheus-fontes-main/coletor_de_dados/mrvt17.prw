#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT17     º Autor ³Mauricio Roehrsº   Data ³  09/09/19     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ apontamento de costelas em processo de producao            º±±
±±º          ³ Data 14/07/20 - Alterado por Flávio - Chamado 143          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MRVT17(_usuario)

	Private _cModelo  := ''
	Private _lOk      := .t.
	Private _cCod 	  := space(6)
	Private _cProgra  := space(3)
	Private _cClassif := space(2)
	Private _cDent    := space(1)
	Private _cCorte   := space(1)
	Private _cSIF     := space(4)
	Private _cNumr	  := space(10)
	Private _cQuant   := space(2)
	Private _cQtdEtq  := space(2)
	Private _dDtAbate := date()
	Private _lTela    := .t.
	Private _cOpera   := UsrRetName(retCodUsr())    
	Private _cHost    := getComputerName()
	
	ZAA->(DbSetOrder(2))
	ZAA->(DbSeek(xfilial('ZAA')+_usuario))
	
	if ZAA->ZAA_APL22 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif

	//Define o tamanho da Tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	
	while _lTela

		_cImp := ' '
		_cAbt := ' '
		VTRead        

		@ 01,05 VTSay "APONTAMENTO DE COSTELAS (  Opção )"
		@ 03,05 VTSay "Selecione a Impressora"
		@ 04,05 VTSay "1:CORT.|2:COS.|3:DES [ ]"
		@ 05,05 VTSay "1-Abt Nosso| 2-Abt Terc.[  ]"    
		@ 16,00 VTSay "ESC para Sair"		   

		@ 04,21 VTGet _cImp Pict "@!" VALID _cImp $ '1/2/3'
		@ 05,30 VTGet _cAbt Pict "@!" VALID _cAbt $ '1/2'
		    

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		//se for Corte
		if _cImp == '1'

			_cIp := alltrim(fBuscaCpo('ZAM',1,xFilial('ZAM') + 'ICRT1','ZAM_IP'))  

		//se for costela              
		elseif _cImp == '2'

			_cIp := alltrim(fBuscaCpo('ZAM',1,xFilial('ZAM') + 'IDSO2','ZAM_IP'))
		
		//se for desossa
		elseif _cImp == '3'					
				_cIp := alltrim(fBuscaCpo('ZAM',1,xFilial('ZAM') + 'IDSO3','ZAM_IP'))									
				//_cIp := '10.11.20.221'						
		endif

		//alert(_cIp)

		VTClear()
		VTClearBuffer()

		
		// Quando for abate nosso
		if _cAbt = '1'
			 
			while _lOk
				
				_cCod   	:= Space(6)				
				_cQuant 	:= space(2)
				_cQtdEtq 	:= space(2)
				_cImp 		:= ' '
				
				VTRead
			
				@ 01,00 VTSay "Apontamento de Costelas"
				@ 02,00 VTSay "Em Processo de producao"
				@ 04,00 VTSay "Data Abate: [        ] "
				@ 05,00 VTSay "Produto:    [      ]	  "
				@ 06,00 VTSay "Quantidade  [  ]       "		
				@ 07,00 VTSay "Programa    [   ] "
				@ 08,00 VTSay "Classific.  [   ]      "
				@ 09,00 VTSay "Dentição    [ ]        "				
						
				@ 04,13 VTGet _dDtAbate Pict "@! 99/99/99" valid !empty(_dDtAbate)
				@ 05,13 VTGet _cCod     Pict "@!"    VALID !empty(_cCod)
				@ 06,13 VTGet _cQuant   Pict "@E 99" VALID !empty(_cQuant) .and. val(_cQuant) > 0		
				@ 07,13 VTGet _cProgra  Pict "@!"    VALID !empty(_cProgra)
				@ 08,13 VTGet _cClassif Pict "@!"    VALID !empty(_cClassif)
				@ 09,13 VTGet _cDent    Pict "@!"    VALID !empty(_cDent)
				
				VTRead
			
				If (VTLastKey() == 27)
					VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
					exit
				EndIF				
				
				vtGrava1()
			
				VTClearBuffer()
			enddo
			
			VTClear()
			VTClearBuffer()
		 	
		 // Quando for Abate de Terceiro
		Elseif _cAbt = '2'
			
			while _lOk
				
				_cCod   := Space(6)
				_cNumr	:= Space(10)
				_cCr	:= Space(10)
				_cQuant := space(2)
				_cQtdEtq := space(2)
				_cImp := ' '
				
				VTRead
				/*
				@ 01,00 VTSay "Apontamento de Costelas de Terc."
				@ 02,00 VTSay "Em Processo de producao"
				//@ 04,00 VTSay "Data Abate: [        ] "
				@ 05,00 VTSay "Produto:    [      ]	  "
				@ 06,00 VTSay "Quantidade  [  ]       "
				@ 07,00 VTSay "Certificado:[          ]"
				
				//@ 04,13 VTGet _dDtAbate Pict "@! 99/99/99" //valid ValCert(_dDtAbate) //!empty(_dDtAbate)		
				@ 05,13 VTGet _cCod     Pict "@!"    VALID !empty(_cCod) 
				@ 06,13 VTGet _cQuant   Pict "@E 99" VALID !empty(_cQuant) .and. val(_cQuant) > 0
				@ 07,13 VTGet _cCr     Pict "@!"    VALID ValCert(_cCr)				
				VTRead
			
				If (VTLastKey() == 27)
					VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
					exit
				EndIF
				*/
				@ 01,00 VTSay "Apontamento de Costelas"
				@ 02,00 VTSay "Em Processo de producao"
				@ 04,00 VTSay "Data Abate: [        ] "
				@ 05,00 VTSay "Produto:    [      ]	  "
				@ 06,00 VTSay "Quantidade  [  ]       "		
				@ 07,00 VTSay "Programa    [   ]      "
				@ 08,00 VTSay "Classific.  [   ]      "
				@ 09,00 VTSay "Dentição    [ ]        "				
				//@ 10,00 VTSay "Corte       [ ]        "		
				@ 10,00 VTSay "SIF         [    ]     "		
						
				@ 04,13 VTGet _dDtAbate Pict "@! 99/99/99" valid !empty(_dDtAbate)
				@ 05,13 VTGet _cCod     Pict "@!"    VALID !empty(_cCod)
				@ 06,13 VTGet _cQuant   Pict "@E 99" VALID !empty(_cQuant) .and. val(_cQuant) > 0		
				@ 07,13 VTGet _cProgra  Pict "@!"    VALID !empty(_cProgra)
				@ 08,13 VTGet _cClassif Pict "@!"    VALID !empty(_cClassif)
				@ 09,13 VTGet _cDent    Pict "@!"    VALID !empty(_cDent)
				//@ 10,13 VTGet _cCorte   Pict "@!"    VALID !empty(_cCorte)
				@ 10,13 VTGet _cSIF     Pict "@!"    VALID !empty(_cSIF)
				
				VTRead
			
				If (VTLastKey() == 27)
					VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
					exit
				EndIF				

				vtGrava2()
			
				VTClearBuffer()
			enddo
			
			VTClear()
			VTClearBuffer()
			
		endif
		
		_cImp := ' '
		_cAbt := ' '

	enddo

	VTClear()
	VTClearBuffer()
	
	
Return

Static Function vtGrava1()
	Local _nQtdReg := 0
	Local i
	
	DbSelectArea('SB1')
		
	if _cCod $ alltrim(getmv('SI_COSDESM'))
		_nQtdReg := 1
	else
		_nQtdReg := val(_cQuant)
	endif
	
	for i := 1 to _nQtdReg
	
		_cNum 	 := GetSx8num('ZAJ','ZAJ_NUM')
		ConfirmSX8()	
			
		_cNumam 	:= fBuscaCpo('SZG',2,xFilial('SZG') + dtos(_dDtAbate),'ZG_NUMAM')			
		_cDescri 	:= fBuscaCPO('SB1',1,xfilial('SB1') + PADL(alltrim(_cCod),6,'0'),"B1_DESC")
		_nPmPec 	:= fBuscaCPO('SB1',1,xfilial('SB1') + PADL(alltrim(_cCod),6,'0'),"B1_PMPEC")
		_nCorori 	:= fBuscaCPO('SB1',1,xfilial('SB1') + PADL(alltrim(_cCod),6,'0'),"B1_CORORI")
		
		_cCosDesm := _GetParam()
		if _cCod $ alltrim(_cCosDesm)
			_nPeso := val(_cQuant) * _nPmPec
		else
			_nPeso := _nPmPec
		endif
						
		cQuery := " SELECT TOP 1 ZY3_NUMAN AS NUMAM, ZY3_CONTRO AS CONTROL, ZY3_CLASSI AS CLASSIFICACAO, ZY3_DENTIC AS DENTICAO"
		cQuery += " FROM " + RetSqlTab('ZY3')				
		cQuery += " WHERE " + retSqlDel('ZY3') + " AND ZY3_NUMAN = '" + _cNumam + "' AND ZY3_CLASSI = '" + _cClassif + "' AND ZY3_DENTIC = '" + _cDent + "'"
		cQuery += " AND ZY3_CONCAR >= 2"
		cQuery += " ORDER BY ZY3_CONTRO DESC "

		cQuery := ChangeQuery(cQuery)

		Conout("MENOR CONTROL RETORNADO NA TABELA ZY3 DE ACORDO COM OS FILTROS INFORMADOS = " + cQuery)

		If Select("TMP2")<>0
			TMP2->(dbCloseArea())
		Endif

		TCQUERY cQuery NEW ALIAS "TMP2"

		TMP2->(dbGoTop())
		
		cQuery3 := " SELECT TOP 1 ZK_CONTROL AS CONTROL "
		cQuery3 += " FROM " + RetSqlTab('SZK')				
		cQuery3 += " WHERE " + retSqlDel('SZK')
		cQuery3 += " AND ZK_DATAABT = '" + DToS(_dDtAbate)  + "'"
		cQuery3 += " AND ZK_CLASSIF = '" + _cClassif + "'"
		cQuery3 += " AND ZK_PROGRAM = '" + _cProgra + "'"
		cQuery3 += " AND ZK_DENT = '"    + _cDent + "'"
		cQuery3 += " ORDER BY ZK_CONTROL DESC "

		cQuery3 := ChangeQuery(cQuery3)

		Conout("MAIOR CONTROL RETORNADO NA TABELA SZK DE ACORDO COM OS FILTROS INFORMADOS= " + cQuery3)

		If Select("TMP3")<>0
			TMP3->(dbCloseArea())
		Endif

		TCQUERY cQuery3 NEW ALIAS "TMP3"

		TMP3->(dbGoTop())
		
		cQry := " SELECT ZG_NUMAM AS AVISO_DE_MATANCA, ZK_CONTROL AS CONTROL, ZK_DATAABT AS DATA_DE_ABATE, ZK_DENT AS DENTICAO, ZK_PROGRAM, ZK_CLASSIF, ZK_RACA AS RACA "
		cQry += " FROM " + RetSqlTab('SZG')
		cQry += " INNER JOIN " + RetSqlTab('SZK') + " ON ZG_NUMAM = ZK_NUMAM"
		cQry += " WHERE " + retSqlDel('SZG') + " AND " + retSqlDel('SZK')
		cQry += " AND ZK_DATAABT = '" + DToS(_dDtAbate)  + "'"
		cQry += " AND ZK_CLASSIF = '" + _cClassif + "'"
		cQry += " AND ZK_PROGRAM = '" + _cProgra + "'"
		cQry += " AND ZK_DENT = '"    + _cDent + "'"		
		cQry += " AND ZK_CONTROL > " + iif(empty(TMP2->CONTROL),'000000',TMP2->CONTROL) + " AND  ZK_CONTROL <= '" + TMP3->CONTROL + "'"

		cQry := ChangeQuery(cQry)

		Conout("RESULTADO DA CONSULTA = " + cQry)		

		If Select("TMP")<>0
			TMP->(dbCloseArea())
		Endif

		TCQUERY cQry NEW ALIAS "TMP"

		TMP->(dbGoTop())

		cQuery4 := " SELECT COUNT (ZY3_CONTRO) AS CONTAD "
		cQuery4 += " FROM " + RetSqlTab('ZY3')				
		cQuery4 += " WHERE " + retSqlDel('ZY3') + " AND ZY3_NUMAN = '" + _cNumam + "' AND ZY3_CLASSI = '" + _cClassif + "' AND ZY3_DENTIC = '" + _cDent + "' AND ZY3_CONTRO = '" + TMP->CONTROL + "'"

		cQuery4 := ChangeQuery(cQuery4)

		Conout("CONTADOR = " + cQuery4)

		If Select("TMP4")<>0
			TMP4->(dbCloseArea())
		Endif

		TCQUERY cQuery4 NEW ALIAS "TMP4"

		TMP4->(dbGoTop())

		conout('MENOR CONTROL NA ZY3:= ' + TMP2->CONTROL)
		conout('MAIOR CONTROL NA SZK:= ' + TMP3->CONTROL)
		conout('CONTROL SZK:= '  + TMP->CONTROL)
		
		If(!Empty(TMP->CONTROL))			
			reclock('ZAJ',.t.)
			ZAJ->ZAJ_FILIAL  := xfilial('ZAJ')
			ZAJ->ZAJ_COD     := PADL(alltrim(_cCod),6,'0')
			ZAJ->ZAJ_DESCRI  := substr(_cDescri,1,20)
			ZAJ->ZAJ_CORORI  := _nCorori
			ZAJ->ZAJ_NUMAM   := _cNumam
			ZAJ->ZAJ_PREDES  := Alltrim(GetAdvFVal('SZ2','Z2_NUM',FWxfilial('SZ2')+_cNumam,4))
			ZAJ->ZAJ_NUM     := _cNum
			ZAJ->ZAJ_NIVEL   := 1
			ZAJ->ZAJ_REGORI  := '0000000001'
			ZAJ->ZAJ_DATA    := ddatabase
			ZAJ->ZAJ_DTCORT  := ddatabase
			ZAJ->ZAJ_PESO    := _nPeso
			ZAJ->ZAJ_DENT    := _cDent
			ZAJ->ZAJ_PROGRA  := _cProgra
			ZAJ->ZAJ_CLASSI  := _cClassif
			ZAJ->ZAJ_CONTRO  := Alltrim(TMP->CONTROL)
			//ZAJ->ZAJ_LOGEST  := _cHost
			//ZAJ->ZAJ_LOGUSR  := _cOpera		
			msunlock()

			reclock('ZY3',.t.)
			ZY3->ZY3_FILIAL  := xFilial('ZAJ')
			ZY3->ZY3_NUM     := _cNum
			ZY3->ZY3_DTAABT  := _dDtAbate
			ZY3->ZY3_RACA    := TMP->RACA
			ZY3->ZY3_CLASSI  := _cClassif
			ZY3->ZY3_DENTIC  := _cDent
			ZY3->ZY3_PROGRA  := _cProgra
			ZY3->ZY3_NUMSIF  := ''			
			ZY3->ZY3_NUMAN   := _cNumam
			ZY3->ZY3_CONTRO  := Alltrim(TMP->CONTROL)
			ZY3->ZY3_USERCR  := UsrRetName(retCodUsr())    
			ZY3->ZY3_DATA    := Date()  
			ZY3->ZY3_HORA    := Time()
			ZY3->ZY3_CONCAR  := iif(TMP4->CONTAD = 0, 1, 2)
			msunlock()			
			
			VtImprime(_cNum,_cNumam,_cDescri,_cCod, _cProgra, _cClassif, _cDent)
		Else			
			VTAlert('Não foi localizada carcaça através dos dados informados',.T.,1000,1)
		EndIf
	next				
return

Static Function vtGrava2()	
	Local _nQtdReg := 0
	Local i
	
	DbSelectArea('SB1')
	
	if _cCod $ alltrim(getmv('SI_COSDESM'))
		_nQtdReg := 1
	else
		_nQtdReg := val(_cQuant)
	endif	
			
	for i := 1 to _nQtdReg	
		_cNum 	 := GetSx8num('ZAJ','ZAJ_NUM')
		ConfirmSX8()	

		_cDatap := fBuscaCpo('ZAP',3,xFilial('ZAP') + alltrim(_cNumr),'ZAP_DATAP')
		_cCert :=  fBuscaCpo('ZAP',3,xFilial('ZAP') + alltrim(_cNumr),'ZAP_CERT')

		//
		cQuery1 := " SELECT ZAP_NUM AS NUM_CERT"
		cQuery1 += " FROM " + RetSqlTab('ZAP')
		cQuery1 += " WHERE " + retSqlDel('ZAP') + " AND ZAP_SIF = '" + Alltrim(_cSIF) + "' AND ZAP_DATAP = '" + DToS(_dDtAbate) + "' AND ZAP_CORORI = '" + _nCorori + "'"

		cQuery1 := ChangeQuery(cQuery1)

		Conout("RESULTADO DA CONSULTA = " + cQuery1)

		If Select("TMP1")<>0
			TMP1->(dbCloseArea())
		Endif

		TCQUERY cQuery1 NEW ALIAS "TMP1"

		TMP1->(dbGoTop())
		//
		
		_cNumam := DTOS(_cDatap)
			
		_cDescri 	:= fBuscaCPO('SB1',1,xfilial('SB1') + PADL(alltrim(_cCod),6,'0'),"B1_DESC")
		_nPmPec 	:= fBuscaCPO('SB1',1,xfilial('SB1') + PADL(alltrim(_cCod),6,'0'),"B1_PMPEC")
		_nCorori 	:= fBuscaCPO('SB1',1,xfilial('SB1') + PADL(alltrim(_cCod),6,'0'),"B1_CORORI")
		
		_cCosDesm := _GetParam()
		if _cCod $ alltrim(_cCosDesm)
			_nPeso := val(_cQuant) * _nPmPec
		else
			_nPeso := _nPmPec
		endif
		
		reclock('ZAJ',.t.)
		ZAJ->ZAJ_FILIAL  := xfilial('ZAJ')
		ZAJ->ZAJ_COD     := PADL(alltrim(_cCod),6,'0')
		ZAJ->ZAJ_DESCRI  := substr(_cDescri,1,20)
		ZAJ->ZAJ_CORORI  := _nCorori	
		//ZAJ->ZAJ_NUMAM   := _cNumam	
		ZAJ->ZAJ_NUM     := _cNum
		ZAJ->ZAJ_NIVEL   := 1
		ZAJ->ZAJ_REGORI  := '0000000001'
		ZAJ->ZAJ_DATA    := _cDatap
		ZAJ->ZAJ_DTCORT  := _cDatap
		ZAJ->ZAJ_PESO    := _nPeso
		ZAJ->ZAJ_DENT    := _cDent
		ZAJ->ZAJ_PROGRA  := _cProgra
		ZAJ->ZAJ_CLASSI  := _cClassif		
		ZAJ->ZAJ_ZAPNUM  := TMP1->NUM_CERT
		msunlock()

		reclock('ZY3',.t.)
		ZY3->ZY3_FILIAL  := xFilial('ZAJ')
		ZY3->ZY3_NUM     := _cNum
		ZY3->ZY3_DTAABT  := _dDtAbate
		ZY3->ZY3_RACA    := TMP->RACA
		ZY3->ZY3_CLASSI  := _cClassif
		ZY3->ZY3_DENTIC  := _cDent
		ZY3->ZY3_NUMSIF  := _cSIF
		ZY3->ZY3_NUMAN   := _cNumam
		ZY3->ZY3_CONTRO  := Alltrim(TMP->CONTROL)
		ZY3->ZY3_USERCR  := UsrRetName(retCodUsr())    
		ZY3->ZY3_DATA    := Date()  
		ZY3->ZY3_HORA    := Time()
		msunlock()			
		
		VtImp2(_cNum,_cNumam,_cDescri,_cCod,_cDatap,_cCert)
		
	next
	
return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                 Imprime a Etiqueta                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VtImprime(_cNum,_cNumam,_cDescri,_cProd, _cProgra, _cClassif, _cDent)
	_Font01 	:= "60,60"
	_Font02 	:= "70,70"
	_cProd2 := PADL(alltrim(_cProd),6,'0')	
	_cDescPro := GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6')+_cProgra,1)
	ZAJ->(dbSetOrder(2))
	ZAJ->(dbGoTop())
	if ZAJ->(dbSeek(xFilial('ZAJ') + alltrim(_cNum)))


		MSCBPRINTER('S600','IP',,,,,_cIp)
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(1,6)

		MSCBBOX(01,16,60,33)

		//Lado
		MSCBSAY(50, 17,'-',"N","0","100,100")

		//Codigo de Barras
		MSCBSAYBAR(08,17,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,2,2,.t.)

		MSCBBOX(01,35,14,48)
		MSCBSAY(3, 36,'Gord',"N","E","8,8")
		MSCBSAY(6, 40,"-","N","0",_Font01)

		MSCBBOX(17, 35,31,48)
		MSCBSAY(20, 36,'Dent',"N","E","8,8")
		MSCBSAY(23, 40,_cDent,"N","0",_Font01)

		MSCBBOX(34, 35,60,48)
		
		MSCBSAY(35, 36,'Cod.Prod.',"N","E","8,8")
		MSCBSAY(35, 40,_cProd2,"N","0",_Font01)

		MSCBBOX(02,50,60,70)
		MSCBLINEV(39,50,70)
		MSCBLINEH(39,60,60)

		MSCBSAY(03, 52,'SEQ.',"N","E","8,8")
		MSCBSAY(13, 52,"-","N","0",_Font02)

		_cDescri := ZAJ->ZAJ_DESCRI
		MSCBSAY(03, 62,substr(_cDescri,1,9),"N","0",_Font01)

		MSCBSAY(40, 52,'Abate',"N","E","8,8")
		MSCBSAY(40, 55,ZAJ->ZAJ_NUMAM,"N","E","8,8")

		MSCBSAY(40, 62,'Lote',"N","E","8,8")
		MSCBSAY(40, 66,'-',"N","E","8,8")

		dAbate := fBuscaCPO('SZG',1,xFilial('SZG')+ ZAJ->ZAJ_NUMAM ,'ZG_DATA')

		MSCBBOX(02,72,60,77)
		MSCBSAY(02,73, GetMv("MV_NUMIF") + strtran(dtoc(dAbate),'/','') +'0000',"N","E","8,8")

		MSCBBOX(02,79,30,89)
		MSCBSAY(03,80,'SIF',"N","E","8,8")
		MSCBSAY(07,84,GetMv("MV_NUMIF"), "N","E","28,15")

		MSCBBOX(32,79,60,89)
		MSCBSAY(33,80,'Data Abate',"N","E","8,8")
		MSCBSAY(37,84,dtoc(dAbate),"N","E","28,15")

		nL := 125

		MSCBBOX(02,93,60,98)

		MSCBBOX(02,100,60,109)
		MSCBSAY(03,101,_cDescPro,"N","0",_Font01)
		MSCBBOX(02,110,60,130)
		MSCBSAY(12,111,_cClassif,"N","0",_Font01)

		//****************************  FIM  *****************************************
		MSCBSAY(13,285,"DTI","N","0","100,190")

		MSCBEND()
		MSCBCLOSEPRINTER()
	endif

return


Static Function VtImp2(_cNum,_cNumam,_cDescri,_cProd,_dDt,_cCRT)

	_Font01 	:= "60,60"
	_Font02 	:= "70,70"
	//_cIp := '10.11.20.184'

	//conout(_cIp)
	_cProd2 := PADL(alltrim(_cProd),6,'0')
	ZAJ->(dbSetOrder(2))
	ZAJ->(dbGoTop())
	if ZAJ->(dbSeek(xFilial('ZAJ') + alltrim(_cNum)))


		MSCBPRINTER('S600','IP',,,,,_cIp)
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(1,6)

		MSCBBOX(01,16,60,33)

		//Lado
		MSCBSAY(50, 17,'-',"N","0","100,100")

		//Codigo de Barras
		MSCBSAYBAR(08,17,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,2,2,.t.)

		MSCBBOX(01,35,14,48)
		MSCBSAY(3, 36,'Gord',"N","E","8,8")
		MSCBSAY(6, 40,"-","N","0",_Font01)

		MSCBBOX(17, 35,31,48)
		MSCBSAY(20, 36,'Dent',"N","E","8,8")

		MSCBSAY(23, 40,"-","N","0",_Font01)

		MSCBBOX(34, 35,60,48)
		
		MSCBSAY(35, 36,'Cod.Prod.',"N","E","8,8")
		MSCBSAY(35, 40,_cProd2,"N","0",_Font01)

		MSCBBOX(02,50,60,70)
		MSCBLINEV(39,50,70)
		MSCBLINEH(39,60,60)

		MSCBSAY(03, 52,'SEQ.',"N","E","8,8")
		MSCBSAY(13, 52,"-","N","0",_Font02)

		_cDescri := ZAJ->ZAJ_DESCRI
		MSCBSAY(03, 62,substr(_cDescri,1,9),"N","0",_Font01)

		MSCBSAY(40, 52,'Abate',"N","E","8,8")
		MSCBSAY(40, 55,ZAJ->ZAJ_NUMAM,"N","E","8,8")

		MSCBSAY(40, 62,'Lote',"N","E","8,8")
		MSCBSAY(40, 66,'-',"N","E","8,8")

		dAbate := fBuscaCPO('SZG',1,xFilial('SZG')+ ZAJ->ZAJ_NUMAM ,'ZG_DATA')

		MSCBBOX(02,72,60,77)
		MSCBSAY(02,73, 'Cert: '+_cCRT,"N","E","8,8")

		MSCBBOX(02,79,30,89)
		MSCBSAY(03,80,'SIF',"N","E","8,8")
		MSCBSAY(07,84,GetMv("MV_NUMIF"), "N","E","28,15")

		MSCBBOX(32,79,60,89)
		MSCBSAY(33,80,'Data Abate',"N","E","8,8")
		//MSCBSAY(37,84,dtoc(dAbate),"N","E","28,15")
		MSCBSAY(37,84,DTOC(_dDt),"N","E","28,15")
		
		nL := 125

		MSCBBOX(02,93,60,98)

		MSCBBOX(02,100,60,109)
		MSCBSAY(03,101,'-',"N","0",_Font01)
		MSCBBOX(02,110,60,130)
		MSCBSAY(12,111,'-',"N","0","162,270")

		//****************************  FIM  *****************************************
		MSCBSAY(13,285,"DTI","N","0","100,190")

		MSCBEND()
		MSCBCLOSEPRINTER()
	endif

return


Static Function ValCert(_cCert)	
	 Local _dDTA
	 local _existe := space(10)	 

	_dDTA := fBuscaCpo('ZAP',2,xFilial('ZAP') + alltrim(_cCert),'ZAP_DATAP')
	
	/* Verificar em casa este processe de trazer as informações automáticamente do fonte MRVT15
	Verificar bem certo como funciona a rotina "separar()" porque é ela quem vai trazer a informação para completar o campo do ZAP_NUM.
	Isso é para não precisar digitar o servitoficado..
	
	_monta := fBuscaCpo('ZAP',2,xFilial('ZAP') + alltrim(_cCert),'ZAP_NUM')
	Retorno := consulta(_cMonta)
	*/
	
	// Indice não criado andai  
	//_existe  := fBuscaCpo('ZAP',4,xFilial('ZAP') + Dtoc(_dDTA),'ZAP_NUM')	
	vari1 := alltrim(Dtoc(_dDtAbate))
	vari2 := alltrim(Dtoc(_dDTA))
	
	_existe := fBuscaCpo('ZAP',2,xFilial('ZAP') + alltrim(_cCert),'ZAP_NUM')
	
	if !empty(alltrim(_existe))
		//_cNumr  := fBuscaCpo('ZAP',2,xFilial('ZAP') + alltrim(_cCr),'ZAP_NUM')
		_cNumr  := _existe
		if !empty(alltrim(_cNumr))
			
			ZAP->(DbGoTop())
			ZAP->(DbSetOrder(3))		
			if ZAP->(DbSeek(xfilial('ZAP')+alltrim(_cNumr)))
				
			else
				VTAlert('Numero recebimento Peças não encontrado!','Aviso',.T.,1500,1)
				Return .f.
			endif
				
		else
				return .F.
		endif
	Else
		
		VTAlert(' Certificado de Terceiro não encontrado!','Aviso',.T.,1700,1)
		Return .f.
		
	Endif
		
Return .T.

static function consultar(_cCrt)

	geraTrab(_cCrt)

	aFields := {"NUM","CERT","DATAP"}
	aHeader := {"NUM","CERTIFICADO","DATAP"}
	aSize   := {6,5,5}

	dbselectarea('TRB')

	TRB->(dbgotop())

	//mostra o grid na tela
	nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"TRB",aHeader,aFields,aSize,"u_vtCoB",)

	VTClear()
	VTClearBuffer()

return

User Function vtCoB(modo)
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,100,1)
		_lOk2 := .f.
		return 0
	elseif VTLastkey()==13
		return 1
	endif
return


Static Function _GetParam()

	_cRet := getmv('SI_COSDESM')

Return(_cRet)
