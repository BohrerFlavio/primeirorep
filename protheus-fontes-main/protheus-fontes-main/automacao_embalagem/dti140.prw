#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} CONECT 
@Type			: Função de Usuário
@Sample			: U_ETQRAIOX()
@Description	: Rotina para geração de etiquetas de gordutra a partir dos dados do servidor do Raio X
				OBS - Rotina com impressão de etiqueta pequena.
                  postgreSQL
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol / Flávio
@Since			: Out/2021
@version		: Protheus 12.1.25 e posteriores
@Comments		: A integração é feita através de TCLink() e configuração do DBAccess
/*/
//--------------------------------------------------------------------------------------
Static Function CONECT()

	Private cDBPostgres  := "Postgres/PostgreSQL30"		// através do DBAccess
	Private cSrvPostgres := "10.0.10.4"					// através do DBAccess
	Private nPort 		 := 7890						// através do DBAccess
	Private nHndProtheus := AdvConnection()
	Private nHndPostgres
	Private cVq1 := ''
	Private cFamRX := ''
	Private cObjtkey :=space(20)

	//validar se vem informação primeiro
	
	if empty(cPreE)
		s := .t.
		Return s
	endif

	_cIp  := ''
	_cEst := getComputerName()
	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	if ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
 		_cIp := alltrim(ZAM->ZAM_IP)
	endif
	
	_c1 := substr(cPreE,1,2)	
	_c3 := substr(cPreE,6,9)

	_CSeqpE := alltrim(_c1)+'000'+alltrim(_c3)
	SZ8->(dbsetorder(16))                       
	if SZ8->(dbseek(xfilial('SZ8')+alltrim(_CSeqpE)))  		
		// Só verifica se existe
		cCaixa := SZ8->Z8_CONTROL
		cFamRX := fBuscaCPO('SB1',1,xfilial('SB1') + alltrim(SZ8->Z8_COD),'B1_FAMRX')
		//alert('linha 60 - Caixa -'+cCaixa+'Familia - '+cFamRX)
	else
		msgbox('Caixa não encontrada!','OPERAÇÃO INCONSISTENTE!','STOP')
				
		cPreE := space(15)	
		oDlg:refresh()	
		
	
		Return
	endif   

	//alert('linha 71 - Familia - '+cFamRX)
	// Cria uma nova conexão com um banco de dados SGBD através do DBAccess
	nHndPostgres := TcLink(cDBPostgres,cSrvPostgres,nPort)
	
	If nHndPostgres < 0
		UserException("Erro (" + str(nHndPostgres,4) + ") ao conectar com " + cDBPostgres + " em " + cSrvPostgres)
		//alert("linha 76 - Erro !!")
	Else
        // Conexão com PostgreSQL
        TCSetConn(nHndPostgres)
		//alert("!! linha 80 - Conecção ok, Agora verificar consulta no Banco Raio X")
		// Buscar o produto
	//	alert("!! linha 82 - Familia--"+cFamRX)
		if !empty(alltrim(cFamRX))

			//alert("!! linha 85 - localizou Família ")
			cQuery4 := "SELECT * "
			cQuery4 += "  FROM product" 
			cQuery4 += " WHERE name like '%"+alltrim(cFamRX)+"%'"
			//cQuery4 += "  order by productkey DESC limit 1" 
			cQuery4 += "  order by productkey ASC limit 1" 
			cQuery4 := ChangeQuery(cQuery4)
			TCQuery cQuery4 New Alias "TRB4"

		else

			//alert("!! linha 95 - Não Localizou  Família  '%000%' ")
			cQuery4 := "SELECT * "
			cQuery4 += "  FROM product" 
			cQuery4 += " WHERE name like '%000%'"
			//cQuery4 += "  order by productkey DESC limit 1" 
			cQuery4 += "  order by productkey ASC limit 1" 
			cQuery4 := ChangeQuery(cQuery4)
			TCQuery cQuery4 New Alias "TRB4"

		endif	
		
		If !TRB4->(Eof())
			While !TRB4->(Eof())
				
			 	cProd := TRB4->productkey
				 TRB4->(DbSkip())
				// alert("!! linha 110 - Produto"+str(cProd))
			Enddo
		EndIf

		TRB4->(DbCloseArea())
		//alert('linha 115 - Produto-'+str(cProd))
		cQuery := "SELECT *"
		cQuery += "  FROM object" 
		cQuery += " WHERE productkey = "+ alltrim(str(cProd))
		cQuery += " order by objectkey DESC limit 1"

		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery New Alias "TRB1"
		//alert("Campo Objectkey-"+str(TRB1->objectkey)) // aqui é o galho relação entre tabelas Product e Object
		//alert("Campo productkey-"+str(TRB1->productkey))
		//alert("Campo Objectkey-"+TRB1->barcode)
		//If !TRB1->(Eof())
			While !TRB1->(Eof())
				//alert("Linha 128 - entrou while")			
				cObjtkey := str(TRB1->objectkey)				
				varFat := Fquery2(TRB1->objectkey)							
				// Imprimir a pré etiqueta de % e Gordura
				//alert("Linha 130 gerando Impressão !!")

				etqim(varFat,cObjtkey,cCaixa)
				
				TRB1->(DbSkip())

			Enddo
		//EndIf

		TRB1->(DbCloseArea())
		
        // Fecha conexão com PostgreSQL
        TCUnLink(nHndPostgres)

        // Retorna conexão com Protheus
        TCSetConn(nHndProtheus)
	EndIf	
	cPreE := space(15)		
	oDlg:refresh()
	
	
Return .f.

Static Function etqim(_sPercG,_cObjK,cCx)
	
    // Gravando na SZ8 para ter o registro para futura impressão de % de gordura caso precise
	SZ8->(DbSetOrder(3))
	if SZ8->(DbSeek(xfilial('SZ8')+alltrim(cCx))) 
		reclock('SZ8',.f.)
			SZ8->Z8_PERCGRX := _sPercG		
			SZ8->Z8_STRRX := "Raio X ID -> "+alltrim(_cObjK)+" - Perc. Grodura -> "+_sPercG+" %"+"Caixa -> "+cCx	
		msunlock()
	endif
	// Caso for realmente imprimir na linha após o Raio X..
	//Return

	if empty(_cIp)
		MSCBPRINTER('S600','LPT1')
	else
		MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
	endif
	
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,4,50)
	
	fDesc2_1		:=  "60,33"
	fDesc2_2		:=  "90,60"
	fDesc2_3		:=  "70,50"
	fDesc2_4		:=  "150,100"
	
	MSCBSAY(5,08,'Perc. Gord. Produto: ',"N","0",fDesc2_1)
	
	if	alltrim(_sPercG) = '0'
		MSCBSAY(10,15,'Zero',"N","0",fDesc2_2)
	else
		MSCBSAY(10,15,_sPercG+' %',"N","0",fDesc2_2)
		MSCBSAY(05,27,'Nr: '+alltrim(_cObjK),"N","0",fDesc2_3)	
		MSCBSAY(05,37,'Cx: '+alltrim(cCx),"N","0",fDesc2_3)				
	endif
	
	MSCBEND()
	MSCBCLOSEPRINTER()
	
return



Static Function FQuery2(cBatchK)
	Local cont := 0
	Local cBatchV := space(5)
	
	cQuery2 := "SELECT * "
	cQuery2 += "  FROM result" 
	cQuery2 += " WHERE objectkey =" + str(cBatchK )
	cQuery2 += "  order by resultkey" 


	cQuery2 := ChangeQuery(cQuery2)
	TCQuery cQuery2 New Alias "TRB3"
	cont++
	If !TRB3->(Eof())
		While !TRB3->(Eof())
			
			if cont = 2				
				cBatchV := alltrim(str(Round( TRB3->value, 0 )))
			endif
			cont++
			TRB3->(DbSkip())

		Enddo
	EndIf

	TRB3->(DbCloseArea())
	
Return cBatchV


User function DTI140()
	
	_oFont    := tFont():New("courier new",,-14,,.t.,,,,)
	_cMemo   := ""
	
	valor := space(15)
	cPreE := space(15)
	/*
	DEFINE MSDIALOG oDlg2 TITLE 'Lendo Pré-Etiqueta:...' from 000,000 To 100,250 OF oMainWnd PIXEL
	@ 010,003 SAY  'Numero:' Object oSay1
	@ 010,025 GET cPreE PICTURE "@!"   SIZE 50,13  Object oCaixa
	@ 010,80 BMPBUTTON TYPE 1 ACTION ETQRAIOX() Object Obtn1
	//@ 025,80 BMPBUTTON TYPE 2 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2
	*/
	//DEFINE DIALOG oDlg TITLE "Impressão de Etiquetas De % de Gordura" FROM 180,180 TO 750,800 PIXEL
	DEFINE DIALOG oDlg TITLE "Impressão de Etiquetas De % de Gordura" FROM 70,80 TO 300,450 PIXEL

	_oSay1   := TSay():New(30,005, {|| 'Codigo da Pré-Etiqueta:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)  
	_oGet1   := TGet():New(45,30, {|u| If(PCount() > 0, cPreE:= u, cPreE)}, oDlg,, 009, "@!",{||CONECT()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cPreE,,,,.t.,)

	_oBtn2 := TButton():New(90,120, "Sair"    , oDlg,{||oDlg:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 

	ACTIVATE DIALOG oDlg CENTERED  
	
return
