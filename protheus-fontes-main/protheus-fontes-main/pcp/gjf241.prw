#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"   
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF241  º Autor ³ Giuliano Forgiraini  º Data ³ 27/01/16    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³rotina de controle e gerenciamento de impressão de etiquetasº±±
±±º          ³ internas                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP desossa                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    
User Function GJF241() 
	private aRotina   :={}
	Private lInverte  := .f.
	Private cMark     := GetMark()  
	Private oMark     
	Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)     
	Private _aProcess := {}    
	Private _cCombo   := ''   
	Private _cSay1    := 'Filtrar Processo'
	Private _cSay2		:= 'Impressão'
	Private cAliasTMP := nil   
	Private _nCount   := 0 
	Private cPerg     := "GJF241"

	if !pergunte(cPerg,.t.)
		return
	endif

	aObjects := {}    //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	ProcReg()

	_cCombo := _aProcess[1]

	GeraTMP()

	aCampos  := {} 
	AADD(aCampos,{"ZU_OK"     ,, "OK"	               ,"@!" })
	AADD(aCampos,{"ZU_NUM"    ,, "Previsão         "   ,"@!" })
	AADD(aCampos,{"ZU_COD"    ,, "Codigo           "   ,"@!" })
	AADD(aCampos,{"ZU_DESC"   ,, "Descricao        "   ,"@!" })  
	AADD(aCampos,{"ZU_DTPROD" ,, "Data Produção    "   ,"99/99/99" }) 
	AADD(aCampos,{"ZU_DTEMB"  ,, "Data Embalagem   "   ,"99/99/99" }) 
	AADD(aCampos,{"ZU_QPCAIX" ,, "Qtd.Prev.Caixas  "   ,"@E 999" })
	AADD(aCampos,{"ZZ7_TARAP" ,, "Tara             "   ,"" })
	AADD(aCampos,{"ZZ7_MSIF"  ,, "Processo         "   ,"@!" })
	AADD(aCampos,{"ZU_QPETIQ" ,, "Qtd.Prev.Etiq.   "   ,"@E 9,999" })
	AADD(aCampos,{"ZU_QRETIQ" ,, "Qtd.Real.Etiq.   "   ,"@E 9,999" })



	DEFINE MSDIALOG oDlg TITLE "Controle de Gerenciamento de Impressão de Etiquetas Internas" From 9,0 To 570,1280 PIXEL

	oMark := MsSelect():New("TMP","ZU_OK","",aCampos,@lInverte,@cMark,{05,1,250,643},,,,,) 
	oMark:bMark := {| | Disp()}                                                                                               

	_oSay1    := TSay():New(265,130, {|| _cSay1}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 080,020)  
	_oCombo   := TComboBox():New(265, 200, {|u| If(PCount() > 0, _cCombo:= u, _cCombo)}, _aProcess, 50, 20, oDlg,, {|| ComboSel()},,,,.T.,,,,,,,,,'_cCombo') 
	_oButton1 := TButton():New(265, 020, "Marcar/Desmarcar", oDlg,{|| Selecionar()	 } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )     
	_oSay2    := TSay():New(255,380, {|| _cSay2}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 080,020)
	_oButton2 := TButton():New(265, 280, "Cod. de Barras"   , oDlg,{|| Imprimir('CB')  } ,50,15,,,.F.,.T.,.F.,,.F.,,,.F. )   
	_oButton3 := TButton():New(265, 339, "Merc. Interno "   , oDlg,{|| Imprimir('MI')  } ,50,15,,,.F.,.T.,.F.,,.F.,,,.F. )   
	_oButton4 := TButton():New(265, 398, "Merc. Externo "   , oDlg,{|| Imprimir('ME')  } ,50,15,,,.F.,.T.,.F.,,.F.,,,.F. )   
	_oButton5 := TButton():New(265, 457±, "Etiqueta GO  "   , oDlg,{|| Imprimir('GO')  } ,50,15,,,.F.,.T.,.F.,,.F.,,,.F. )   
	_oButton6 := TButton():New(265, 580, "Sair"             , oDlg,{|| oDlg:end()      } ,50,15,,,.F.,.T.,.F.,,.F.,,,.F. )	

	ACTIVATE MSDIALOG oDlg CENTERED 

	If Select("TMP")<> 0
		TMP->(dbCloseArea())
	Endif


Return .T.

Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("ZU_OK")	   
		TMP->ZU_OK := cMark
	Else     
		TMP->ZU_OK := ""
	Endif             
	msunlock()  

	oMark:oBrowse:Refresh()
Return()


Static Function ComboSel() 
	GeraTMP()
	//oMark:Refresh()
	oMark:oBrowse:Refresh()	
	oDlg:refresh()

return

Static Function Selecionar()
	TMP->(dbgotop())   

	while TMP->(!eof())                               
		reclock('TMP',.f.)
		TMP->ZU_OK := iif(empty(TMP->ZU_OK),cMark,"")
		msunlock()		 

		TMP->(dbskip())
	enddo      

	TMP->(dbgotop())   

	oMark:oBrowse:Refresh()	
return .t.     



//Função para processar registros
Static Function ProcReg()

	_aProcess := {}

	cAliasTMP := GetNextAlias()

	BeginSql Alias cAliasTMP    
		column  ZU_QPCAIX as numeric (4,0), ZU_QPETIQ as numeric (4,0),ZU_QRETIQ as numeric (4,0)

		SELECT ZU_NUM, ZU_COD, ZU_DESC,ZZ7_MSIF,ZZ7_CODPRO,ZZ7_CORTE,ZU_QPCAIX, ZU_QPETIQ,ZU_QRETIQ
		FROM %Table:SZU% SZU , %Table:ZZ7% ZZ7
		WHERE
		SZU.ZU_FILIAL = %xFilial:SZU% AND ZZ7.ZZ7_FILIAL = %xFilial:ZZ7% AND ZU_LISTETQ = "S" AND 
		ZU_COD = ZZ7_CODPRO AND  SZU.ZU_DTPROD = %Exp:DTOS(DDATABASE)% AND ZU_QPETIQ <> 0 AND //deve ser aqui DATA
		SZU.%NotDel% AND ZZ7.%NotDel%
		ORDER BY ZZ7_MSIF,ZU_COD,ZZ7_CODPRO
	EndSql

	aadd(_aProcess,'Todos')

	While (cAliasTMP)->(!eof()) 

		if empty((cAliasTMP)->ZZ7_MSIF)
			(cAliasTMP)->(DbSkip())
			loop
		endif

		_nPos := aScan(_aProcess,(cAliasTMP)->ZZ7_MSIF)   

		if _nPos = 0
			aadd(_aProcess,(cAliasTMP)->ZZ7_MSIF)
		endif


		(cAliasTMP)->(DbSkip())
	enddo

return

//Gera Arquivo Temporário para MSSELECT()
Static Function GeraTMP()

	_nCount   := 0

	//If Select("TMP")<>0
	//	TMP->(dbCloseArea())
	//Endif

	DbSelectArea(cAliasTMP)
	(cAliasTMP)->(DbGotop())

	//cArq  := CriaTrab( Nil, .F. )                      

	aStru := dbStruct()                                                         

	aadd(aStru,{"ZU_OK"     , "C",  02, 0})
	aadd(aStru,{"ZU_DTPROD" , "D",  08, 0})
	aadd(aStru,{"ZU_DTEMB"  , "D",  08, 0})
	aadd(aStru,{"ZZ7_TARAP" , "C",  10, 0})

	//dbcreate(cArq,aStru)
	//dbUseArea( .T.,,cArq,'TMP', .F. , .F. )               //cria temp
	//Index On ZZ7_MSIF To (cArq)

	_aArqTrb :={}
	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {"ZZ7_MSIF"}, @_aArqTrb)

	(cAliasTMP)->(DbGoTop())

	While (cAliasTMP)->(!eof())  

		if _cCombo <> 'Todos' 
			if (cAliasTMP)->ZZ7_MSIF <> _cCombo
				(cAliasTMP)->(DbSkip())
				loop
			endif 
		endif

		_cPredes := fBuscaCPO('SZU',2,xfilial('SZU') + (cAliasTMP)->ZU_NUM,'ZU_PREDES')
		_dDtProd := fBuscaCPO('SZ2',2,xfilial('SZ2') + _cPredes,'Z2_DATAABT')
		_dDtEmb  := fBuscaCPO('SZU',2,xfilial('SZU') + (cAliasTMP)->ZU_NUM,'ZU_DTPROD')
		_cTara   := fBuscaCPO('ZZ7',1,xfilial('ZZ7') + (cAliasTMP)->ZU_COD,'ZZ7_TARAP')

		DbSelectArea('TMP')
		Reclock('TMP',.t.)
		TMP->ZU_NUM     := (cAliasTMP)->ZU_NUM
		TMP->ZU_COD     := (cAliasTMP)->ZU_COD
		TMP->ZU_DESC    := (cAliasTMP)->ZU_DESC      
		TMP->ZZ7_MSIF	 := (cAliasTMP)->ZZ7_MSIF
		TMP->ZU_QPCAIX	 := (cAliasTMP)->ZU_QPCAIX   
		TMP->ZU_DTPROD  := _dDtProd
		TMP->ZU_DTEMB   := _dDtEmb      
		TMP->ZZ7_TARAP  := _cTara
		TMP->ZU_QPETIQ  := (cAliasTMP)->ZU_QPETIQ
		TMP->ZU_QRETIQ  := (cAliasTMP)->ZU_QRETIQ
		MsUnlock() 

		_nCount++

		(cAliasTMP)->(DbSkip())
	enddo

	dbSelectarea('TMP')
	IndRegua("TMP",cArq,"ZZ7_MSIF",,,"Selecionando Registros...") //ordena
	TMP->(dbGotop())

return


Static function Imprimir(_cMerc)  
	Processa({||ProcImp(_cMerc)} ,"ETIQUETAS INTERNAS","Impressão em adamento!")
return

Static Function ProcImp(_cMerc)

	ProcRegua(_nCount)

	TMP->(DbGotop())

	while TMP->(!eof())

		incproc('Processando Processo ' + alltrim(TMP->ZZ7_MSIF) + ' Produto ' + alltrim(TMP->ZU_COD) + '...')  

		if !empty(TMP->ZU_OK) 

			_nQtdE := TMP->ZU_QPETIQ

			if _cMerc = 'CB'
				ImpEtq2(alltrim(TMP->ZU_COD),_nQtdE,TMP->ZU_DTPROD,TMP->ZZ7_TARAP,_cMerc)    
			elseif _cMerc = 'GO'
				ImpEtq3(alltrim(TMP->ZU_COD),_nQtdE,TMP->ZU_DTPROD,TMP->ZZ7_TARAP,_cMerc)       	   
			else
				ImpEtq1(alltrim(TMP->ZU_COD),_nQtdE,TMP->ZU_DTPROD,TMP->ZZ7_TARAP,_cMerc)    
			endif

			SZU->(DbSetOrder(2))
			if SZU->(DbSeek(xfilial('SZU') + TMP->ZU_NUM))
				reclock('SZU',.f.)
				SZU->ZU_QRETIQ += _nQtdE
				SZU->ZU_QPETIQ := 0
				msunlock()
			endif   
			sleep(3000)
		endif

		TMP->(Dbskip())
	enddo

	(cAliasTMP)->(DbCloseArea())

	TMP->(DbcloseArea())

	ProcReg()

	GeraTMP()

return            


Static function ImpEtq1(_cProd,_nEtq,_dDtProd,_cTaraP, _cMerc) 

	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7') + _cProd))

	//MSCBPRINTER('S600','IP',,,,,'10.0.0.176') //Impressão por IP  

	if mv_par01 = 1
		MSCBPRINTER('S600','LPT1')
	else
		MSCBPRINTER('S600','IP',,,,,alltrim(mv_par02))	
	endif

	//MSCBPRINTER('S600','COM1:4800,e,7,2')
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nEtq,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas VALOR5


	dtVALID := _dDtProd + ZZ7->ZZ7_DVALID // Data de validade
	fontecorte      :="22,29"
	fontedesc       :="22,29"
	fonteNomeCorte  :="28,35"
	fonteNomeCorte1 :="18,35"
	fonteData       :="16,35"
	fonteMesTemp    :="22,15"
	fonteMesTemp1   :="19,13"
	fonteInscSIF    :="19,16"
	fonteInfNutri1  :="16,25"
	fonteInfNutri2  :="16,18"
	fonteNutri3     :="16,9"
	fonteNutri4     :="19,10"
	fontelinha9     :="14,14"
	fonte3          :="16,13"
	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=42-t
	MSCBSAY(2,pos,alltrim(ZZ7->ZZ7_DESC),"B","0",fonteDesc)
	pos2:=0
	t2:=len(alltrim(ZZ7->ZZ7_CORTE))
	pos2:=42-t2  
	DbSelectArea('SB1') 

	MSCBSAY(9,pos2,alltrim(ZZ7->ZZ7_CORTE),"B","0",fontecorte) // nome do corte
	MSCBSAY(16,52,substr(dtos(TMP->ZU_DTPROD),7,2)+'/'+substr(dtos(TMP->ZU_DTPROD),5,2)+'/'+substr(dtos(TMP->ZU_DTPROD),3,2),"B","0",fonteData) //Data da producao
	_sif01 := GetMV('SI_SIFET01')
	_sif04 := GetMV('SI_SIFET04')
	_sif07 := GetMV('SI_SIFET07')
	_sif07_2 := GetMv('SI_SIFTE07')
	_sif12 := GetMV('SI_SIFET12')
	_sif18 := GetMV('SI_SIFET18')
	_MSIF  := substr(ZZ7->ZZ7_MSIF,1,4)

	if (_MSIF $ _sif07) .or. (_MSIF $ _sif07_2)
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif12
		MSCBSAY(15,5,'MANTER CONGELADA A -12 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif18
		MSCBSAY(15,5,'MANTER CONGELADA A -18 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif04
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 4 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif01
		MSCBSAY(15,5,'MANTER RESFRIADA DE -1 a 1 GRAUS CELSIUS',"B","0",fonteMesTemp1)	
	endif 


	//MSCBSAY(21,52,substr(dtos(dtVALID),7,2)+'/'+substr(dtos(dtVALID),5,2)+'/'+substr(dtos(dtVALID),3,2),"B","0",fonteData) //Data validade
	MSCBSAY(21,49,dtoc(dtVALID),"B","0",fonteData) //Data validade
	MSCBSAY(21,24,"XXXXX","B","0",fonteNomeCorte1)// Sexo
	MSCBSAY(21,13,alltrim(_cTaraP),"B","0",fonteNomeCorte1)//tara
	//Criado Fabian Maurer para identificar o tipo de mensagem do Ministerio 19/12/11 

	if _cMerc = 'ME' 	
		MSCBSAY(24,02,'USO AUTORIZADO PELO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)
	else
		MSCBSAY(24,07,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)//REGISTRO NO 
	endif

	//Box Grande
	MSCBBOX(26,2,53,70,4)
	//1º Titulo
	MSCBSAY(27,41,'INFORMACOES NUTRICIONAIS',"B","0",fonteInfNutri1)
	MSCBSAY(27,03,ZZ7->ZZ7_PRTCOM,"B","0",fonteInfNutri1)//MSCBBOX(34,6,34,70,3)
	MSCBBOX(29,2,29,70,3)
	//2º Linha
	MSCBSAY(30,49,'Quantidade por Porcao',"B","0",fonteInfNutri2)
	MSCBLineH(29,42,44,3,"B")//1ª Barra vertical
	MSCBSAY(30,35,'%VD(*)',"B","0",fonteInfNutri2)
	MSCBLineH(32,57,44,3,"B")//2ª Barra vertical
	MSCBSAY(30,12,'Quantidade por Porcao',"B","0",fonteInfNutri2)
	MSCBLineH(29,33,44,3,"B")   //3ª barra vertical   (y1,x1,x2)
	MSCBSAY(30,3,'%VD(*)',"B","0",fonteInfNutri2)
	MSCBLineV(32,3,70,3,"B")// essa linha esta fazendo a horizontal (Y,X1,X2)

	//3ª Linha           ENERGETICO
	MSCBSAY(33,57,'Valor energ.',"B","0",fonteInfNutri2)
	MSCBLineH(32,20,44,3,"B")//1ª Barra vertical
	MSCBSAY(33,43,ZZ7->ZZ7_CALQTP,"B","0",fonteInfNutri2)
	MSCBLineH(29,10,44,3,"B")//2ª Barra vertical
	MSCBSAY(33,36,ZZ7->ZZ7_CALVD,"B","0",fonteInfNutri2)
	MSCBSAY(33,21,'Gord. Trans.',"B","0",fonteInfNutri2)
	MSCBSAY(33,18,ZZ7->ZZ7_GTRTP,"B","0",fonteInfNutri2)
	MSCBSAY(33,9,ZZ7->ZZ7_GTRVD,"B","0",fonteInfNutri2)
	MSCBLineV(35,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)

	//4ª Linha
	MSCBSAY(36,58,'Carboidratos',"B","0",fonteInfNutri2)
	MSCBSAY(36,47,ZZ7->ZZ7_CARQTP,"B","0",fonteNutri4)
	MSCBSAY(36,36,ZZ7->ZZ7_CARVD,"B","0",fonteInfNutri2)
	MSCBSAY(36,20,'Fibra Alim.',"B","0",fonteInfNutri2)
	MSCBSAY(36,14,ZZ7->ZZ7_FIAQTP,"B","0",fonteNutri4)
	MSCBSAY(36,5,ZZ7->ZZ7_FIAVD,"B","0",fonteInfNutri2)
	MSCBLineV(38,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)

	//5ª Linha
	MSCBSAY(39,61,'Proteinas',"B","0",fonteInfNutri2)
	MSCBSAY(39,48,ZZ7->ZZ7_PROQTP,"B","0",fonteInfNutri2)
	MSCBSAY(39,36,ZZ7->ZZ7_PROVD,"B","0",fonteInfNutri2)
	MSCBSAY(39,25,'Sodio',"B","0",fonteInfNutri2)
	MSCBSAY(39,12,ZZ7->ZZ7_SODQTP,"B","0",fonteInfNutri2)
	MSCBSAY(39,5,ZZ7->ZZ7_SODVD,"B","0",fonteInfNutri2)
	MSCBLineV(41,3,70,3,"B")

	//6ª Linha
	MSCBSAY(42,57,'Gorduras Tot.',"B","0",fonteInfNutri2)
	MSCBSAY(42,48,ZZ7->ZZ7_GTQTP,"B","0",fonteInfNutri2)
	MSCBSAY(42,36,ZZ7->ZZ7_GTVD,"B","0",fonteInfNutri2)
	MSCBSAY(42,21,'Gord. Satur.',"B","0",fonteInfNutri2)
	MSCBSAY(42,15,ZZ7->ZZ7_GSQTP,"B","0",fonteInfNutri2)
	MSCBSAY(42,5,ZZ7->ZZ7_GSVD,"B","0",fonteInfNutri2)
	MSCBLineV(44,3,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)


	MSCBSAY(45,12,'(*)VALORES DIARIOS DE REFERENCIA COM BASE EM UMA DIETA DE 2.000kcal,',"B","0",fontelinha9)
	MSCBSAY(47,16,'OU 8400 kj.SEUS VALORES DIARIOS PODEM SER MAIORES OU MENORES',"B","0",fontelinha9)
	MSCBSAY(49,29,'DEPENDENDO DE SUAS NECESSIDADES ENERGETICAS.',"B","0",fontelinha9)
	MSCBSAY(51,38,'APOS ABERTO CONSUMIR EM ATE 2 DIAS.',"B","0",fontelinha9)
	MSCBEND()
	MSCBCLOSEPRINTER()

return  

Static Function ImpEtq2(_cProd,_nEtq,_dDtProd,_cTaraP, _cMerc) 

	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7')+_cProd))

	_cCodBar  := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(_cProd),'B1_CODBAR') 

	if mv_par01 = 1
		MSCBPRINTER('S600','LPT1')
	else
		MSCBPRINTER('S600','IP',,,,,alltrim(mv_par02))	
	endif

	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nEtq,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas VALOR5
	//           \ VARIAVEL _nEtq para pegar o valor da variavel de numeros de etiquetas que serão impressas

	dtVALID := _dDtProd + ZZ7->ZZ7_DVALID // Data de validade
	fontecorte      :="22,29"
	fontedesc       :="22,29"
	fonteNomeCorte  :="28,35"
	fonteNomeCorte1 :="18,35"
	fonteData       :="16,35"
	fonteMesTemp    :="22,15"
	fonteMesTemp1   :="19,13"
	fonteInscSIF    :="19,16"
	fonteInfNutri1  :="16,25"
	fonteInfNutri2  :="16,18"
	fonteNutri3     :="16,9"
	fonteNutri4     :="19,10"
	fontelinha9     :="14,14"
	fonte3          :="16,13"
	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=42-t
	MSCBSAY(2,pos,alltrim(ZZ7->ZZ7_DESC),"B","0",fonteDesc)
	pos2:=0
	t2:=len(alltrim(ZZ7->ZZ7_CORTE))
	pos2:=42-t2  
	DbSelectArea('SB1') 

	MSCBSAY(9,pos2,alltrim(ZZ7->ZZ7_CORTE),"B","0",fontecorte)// nome do corte
	//MSCBSAY(9,pos2,alltrim(valor3),"B","0",fontecorte) // nome do corte
	//MSCBSAY(16,52,substr(dtos(valor2),7,2)+'/'+substr(dtos(valor2),5,2)+'/'+substr(dtos(valor2),3,2),"B","0",fonteData) //Data da producao
	MSCBSAY(16,52,substr(dtos(TMP->ZU_DTPROD),7,2)+'/'+substr(dtos(TMP->ZU_DTPROD),5,2)+'/'+substr(dtos(TMP->ZU_DTPROD),3,2),"B","0",fonteData) //Data da producao
	MSCBSAY(21,49,dtoc(dtVALID),"B","0",fonteData)
	_sif01 := GetMV('SI_SIFET01')
	_sif04 := GetMV('SI_SIFET04')
	_sif07 := GetMV('SI_SIFET07')
	_sif07_2 := GetMv('SI_SIFTE07')
	_sif12 := GetMV('SI_SIFET12')
	_sif18 := GetMV('SI_SIFET18')
	_MSIF  := substr(ZZ7->ZZ7_MSIF,1,4)

	if (_MSIF $ _sif07) .or. (_MSIF $ _sif07_2)
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif12
		MSCBSAY(15,5,'MANTER CONGELADA A -12 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif18
		MSCBSAY(15,5,'MANTER CONGELADA A -18 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif04
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 4 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif01
		MSCBSAY(15,5,'MANTER RESFRIADA DE -1 a 1 GRAUS CELSIUS',"B","0",fonteMesTemp1)		
	endif 



	MSCBSAY(21,24,"XXXXX","B","0",fonteNomeCorte1)// Sexo
	MSCBSAY(21,13,alltrim(_cTaraP),"B","0",fonteNomeCorte1)//tara



	//CODIGO DE BARRAS
	//MSCBSAYBAR(30,03,_cCodBar,"B","MB07",10,.F.,.T.,.F.,"C",2,1,.F.)
	MSCBSAYBAR(42,30,_cCodBar,"B","MB07",8,.F.,.T.,.F.,"C",2,1,.F.)

	//1º Titulo
	MSCBSAY(27,41,'INFORMACOES NUTRICIONAIS',"B","0",fonteInfNutri1)
	//MSCBSAY(27,07,'Porcao de 100g de parte comestivel',"B","0",fonteInfNutri1)//MSCBBOX(34,6,34,70,3) 
	MSCBSAY(27,07,ZZ7->ZZ7_PRTCOM,"B","0",fonteInfNutri1)
	//MSCBBOX(29,6,29,70,3)
	//2º Linha
	MSCBSAY(30,49,'Quantidade por Porcao',"B","0",fonteInfNutri2)
	//MSCBLineH(29,45,37,3,"B")//1ª Barra vertical
	MSCBSAY(30,38,'%VD(*)',"B","0",fonteInfNutri2)
	//MSCBLineH(29,37,37,3,"B")//2ª Barra vertical

	//3ª Linha           ENERGETICO
	MSCBSAY(32,56,'Valor energ.',"B","0",fonteInfNutri2)
	//MSCBLineH(32,55,44,3,"B")//1ª Barra vertical
	MSCBSAY(32,46,ZZ7->ZZ7_CALQTP,"B","0",fonteInfNutri2)
	//MSCBLineH(37,45,40,3,"B")//2ª Barra vertical
	MSCBSAY(32,38,ZZ7->ZZ7_CALVD,"B","0",fonteInfNutri2)
	//MSCBLineH(32,37,40,3,"B")//3ª Barra vertical

	//4ª Linha
	MSCBSAY(34,56,'Carb.',"B","0",fonteInfNutri2)
	//MSCBLineH(32,55,44,3,"B")//1ª Barra vertical
	MSCBSAY(34,47,ZZ7->ZZ7_CARQTP,"B","0",fonteNutri4)
	//MSCBLineH(37,45,43,3,"B")//2ª Barra vertical
	MSCBSAY(34,38,ZZ7->ZZ7_CARVD,"B","0",fonteInfNutri2)
	//MSCBLineH(34,37,43,3,"B")//3ª Barra vertical

	//5ª Linha
	MSCBSAY(36,56,'Prot.',"B","0",fonteInfNutri2)
	//MSCBLineH(43,56,44,3,"B")//1ª Barra vertical
	MSCBSAY(36,48,ZZ7->ZZ7_PROQTP,"B","0",fonteInfNutri2)
	//MSCBLineH(43,45,44,3,"B")//2ª Barra vertical
	MSCBSAY(36,38,ZZ7->ZZ7_PROVD,"B","0",fonteInfNutri2)
	//MSCBLineH(36,37,44,3,"B")//3ª Barra vertical

	//6ª Linha
	MSCBSAY(38,56,'Gord. Totais',"B","0",fonteInfNutri2)
	//MSCBLineH(42,55,44,3,"B")//1ª Barra vertical
	MSCBSAY(38,48,ZZ7->ZZ7_GTQTP,"B","0",fonteInfNutri2)
	//MSCBLineH(42,45,43,3,"B")//2ª Barra vertical
	MSCBSAY(38,38,ZZ7->ZZ7_GTVD,"B","0",fonteInfNutri2)
	//MSCBLineH(38,37,44,3,"B")//3ª Barra vertical

	//7ª Linha
	MSCBSAY(40,56,'Gord. Satur.',"B","0",fonteInfNutri2)
	//MSCBLineH(45,55,44,3,"B")//4ª Barra vertical
	MSCBSAY(40,48,ZZ7->ZZ7_GSQTP,"B","0",fonteInfNutri2)
	//MSCBLineH(45,45,43,3,"B")//5ª Barra vertical
	MSCBSAY(40,38,ZZ7->ZZ7_GSVD,"B","0",fonteInfNutri2) 
	//MSCBLineH(40,37,44,3,"B")//2ª Barra vertical
	//MSCBLineH(45,39,44,3,"B")//3ª Barra vertical
	//MSCBLineV(44,6,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)

	//8ª Linha
	MSCBSAY(42,56,'Sodio',"B","0",fonteInfNutri2)
	//MSCBLineH(47,55,44,3,"B")//4ª Barra vertical
	MSCBSAY(42,48,ZZ7->ZZ7_SODQTP,"B","0",fonteInfNutri2)
	//MSCBLineH(47,45,43,3,"B")//5ª Barra vertical
	MSCBSAY(42,38,ZZ7->ZZ7_SODVD,"B","0",fonteInfNutri2)
	//MSCBLineH(42,37,44,3,"B")//2ª Barra vertical

	//9ª Linha
	MSCBSAY(44,56,'Fibra Alim.',"B","0",fonteInfNutri2)
	//MSCBLineH(49,55,44,3,"B")//4ª Barra vertical
	MSCBSAY(44,48,ZZ7->ZZ7_FIAQTP,"B","0",fonteNutri4)
	//MSCBLineH(49,45,43,3,"B")//5ª Barra vertical
	MSCBSAY(44,38,ZZ7->ZZ7_FIAVD,"B","0",fonteInfNutri2)
	//MSCBLineH(49,37,44,3,"B")//2ª Barra vertical

	//10ª Linha
	MSCBSAY(46,56,'Gord. Trans.',"B","0",fonteInfNutri2)
	//MSCBLineH(51,55,44,3,"B")//4ª Barra vertical
	MSCBSAY(46,48,ZZ7->ZZ7_GTRTP,"B","0",fonteInfNutri2)
	//MSCBLineH(51,45,43,3,"B")//5ª Barra vertical
	MSCBSAY(46,38,ZZ7->ZZ7_GTRVD,"B","0",fonteInfNutri2)
	//MSCBLineH(51,37,44,3,"B")//2ª Barra vertical
	//MSCBLineV(48,6,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)

	MSCBSAY(48,12,'(*)VALORES DIARIOS DE REFERENCIA COM BASE EM UMA DIETA DE 2.000kcal,',"B","0",fontelinha9)
	MSCBSAY(50,16,'OU 8400 kj.SEUS VALORES DIARIOS PODEM SER MAIORES OU MENORES',"B","0",fontelinha9)
	MSCBSAY(52,29,'DEPENDENDO DE SUAS NECESSIDADES ENERGETICAS.',"B","0",fontelinha9)
	MSCBSAY(54,38,'APOS ABERTO CONSUMIR EM ATE 2 DIAS.',"B","0",fontelinha9)

	MSCBEND()
	MSCBCLOSEPRINTER()

return  


// criado por Max dia 16/02/16########################################################################

Static function ImpEtq3(_cProd,_nEtq,_dDtProd,_cTaraP, _cMerc) 


	dbselectarea('ZZ7')
	dbsetorder(1)

	/*
	campoA  := '      '  //campo do codigo do produto
	campoB  := '        ' //campo da data da produção
	campoC 	:= '                                      '  //campo da descrição do corte
	campoD 	:= '   ' // campo da tara para impressão na etiqueta
	campoE 	:= 000
	//campoF 	:= {"   ","Macho","Femea","XXXXX"}//sexo
	campoG	:= space(08)

	_dDTMaior := date()
	_dDTMenor := date() - 10

	valor1 	:= '      ' 	//codigo do produto
	valor2 	:= date()   	//data de produção
	valor3 	:= '                   ' //Descrição do corte
	valor4 	:= '   '   //Tara
	valor5 	:= 000     //Quantidade de etiqueta
	valor6 	:= "XXXXX"  //Sexo               
	valor7	:= date() //data de embalagem
	*/


	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7')+_cProd))

	_cCodBar  := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(_cProd),'B1_CODBAR') 

	if mv_par01 = 1
		MSCBPRINTER('S600','LPT1')
	else
		MSCBPRINTER('S600','IP',,,,,alltrim(mv_par02))	
	endif

	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nEtq,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas VALOR5
	//           \ VARIAVEL _nEtq para pegar o valor da variavel de numeros de etiquetas que serão impressas


	dtVALID :=  _dDtProd+ZZ7->ZZ7_DVALID // Data de validade
	fontecorte      :="22,29"
	fontedesc       :="22,29"
	fonteNomeCorte  :="28,35"
	fonteNomeCorte1 :="18,35"
	fonteData       :="16,35"
	fonteMesTemp    :="22,15"
	fonteMesTemp1   :="19,13"
	fonteInscSIF    :="19,16"
	fonteInfNutri1  :="8,10"
	fonteInfNutri2  :="16,18"
	fonteNutri3     :="16,9"
	fonteNutri4     :="19,10"
	fontelinha9     :="14,14"
	fonte3          :="16,13"
	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=42-t
	MSCBSAY(2,pos,ZZ7->ZZ7_DESC,"B","0",fonteDesc)
	pos2:=0
	t2:=len(alltrim(ZZ7->ZZ7_CORTE))
	pos2:=42-t2
	//MSCBSAY(9,pos2,alltrim(valor3),"B","0",fontecorte) // nome do corte

	MSCBSAY(9,pos2,alltrim(ZZ7->ZZ7_CORTE),"B","0",fontecorte)
	MSCBSAY(16,52,substr(dtos(TMP->ZU_DTPROD),7,2)+'/'+substr(dtos(TMP->ZU_DTPROD),5,2)+'/'+substr(dtos(TMP->ZU_DTPROD),3,2),"B","0",fonteData) //Data da producao

	_sif01 := GetMV('SI_SIFET01')
	_sif04 := GetMV('SI_SIFET04')
	_sif07 := GetMV('SI_SIFET07')             
	_sif07_2 := GetMv('SI_SIFTE07')
	_sif12 := GetMV('SI_SIFET12')
	_sif18 := GetMV('SI_SIFET18')
	_MSIF  := substr(ZZ7->ZZ7_MSIF,1,4)

	if (_MSIF $ _sif07) .or. (_MSIF $ _sif07_2)
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif12
		MSCBSAY(15,5,'MANTER CONGELADA A -12 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif18
		MSCBSAY(15,5,'MANTER CONGELADA A -18 GRAUS CELSIUS',"B","0",fonteMesTemp)    
	elseif _MSIF $ _sif04
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 4 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif01
		MSCBSAY(15,5,'MANTER RESFRIADA DE -1 a 1 GRAUS CELSIUS',"B","0",fonteMesTemp1)		
	endif 	



	MSCBSAY(21,52,substr(dtos(dtVALID),7,2)+'/'+substr(dtos(dtVALID),5,2)+'/'+substr(dtos(dtVALID),3,2),"B","0",fonteData) //Data validade
	MSCBSAY(21,24,'XXXXXX',"B","0",fonteNomeCorte1)// Sexo
	MSCBSAY(21,13,alltrim(_cTaraP)+'g',"B","0",fonteNomeCorte1)//tara
	MSCBSAY(24,9,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)
	//       Y  X  
	// Primeira linha
	MSCBSAY(33,29,ZZ7->ZZ7_GOVE,"B","0",fonteInfNutri1)
	MSCBSAY(33,49,ZZ7->ZZ7_GOKCAL,"B","0",fonteInfNutri1) 
	MSCBSAY(33,05,ZZ7->ZZ7_GOGS,"B","0",fonteInfNutri1)
	MSCBSAY(33,22,ZZ7->ZZ7_GOGSG,"B","0",fonteInfNutri1) 

	//       Y  X    
	// Segunda linha
	MSCBSAY(39,29,ZZ7->ZZ7_GOC,"B","0",fonteInfNutri1)
	MSCBSAY(39,40,ZZ7->ZZ7_GOCG,"B","0",fonteInfNutri1)
	MSCBSAY(39,05,ZZ7->ZZ7_GOGT,"B","0",fonteInfNutri1)
	MSCBSAY(39,22,ZZ7->ZZ7_GOGTG,"B","0",fonteInfNutri1) 

	//       Y  X 
	// Terceira linha
	MSCBSAY(45,29,ZZ7->ZZ7_GOP,"B","0",fonteInfNutri1)
	MSCBSAY(45,49,ZZ7->ZZ7_GOPG,"B","0",fonteInfNutri1)
	MSCBSAY(45,05,ZZ7->ZZ7_GOFA,"B","0",fonteInfNutri1)
	MSCBSAY(45,22,ZZ7->ZZ7_GOFAG,"B","0",fonteInfNutri1) 

	//       Y  X            
	// Quarta linha
	MSCBSAY(51,29,ZZ7->ZZ7_GOGTO,"B","0",fonteInfNutri1)
	MSCBSAY(51,49,ZZ7->ZZ7_GOGTOG,"B","0",fonteInfNutri1)
	MSCBSAY(51,05,ZZ7->ZZ7_GOS,"B","0",fonteInfNutri1)
	MSCBSAY(51,22,ZZ7->ZZ7_GOSG,"B","0",fonteInfNutri1) 

	MSCBEND()
	MSCBCLOSEPRINTER()
	//fbf06clear()


	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

return
