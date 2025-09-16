#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch" 
#INCLUDE "tbiconn.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF51  ºAutor  ³Giuliano Forgiarini º Data ³  08/11/10      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Produção do corte                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF51()

	lOk      := .f.        

	Private _cValProd := space(06) 
	Private _cCampo   := space(06)
	Private _cValPeca := space(24) 
	Private _cCampo2  := space(21)

	Private cCadastro := "Produção do Corte"
	Private aRotina := { {"Pesquisar"  ,"AxPesqui"  ,0,1} ,;
						{"Visualizar" ,"AxVisual"  ,0,2} ,;
						{"Produzir"   ,"u_gjf51pro",0,3} ,;
						{"Excluir"    ,"u_gjf69del",0,5} }

	private cString  := "ZZD"
	private aCampos  :={}   
	private _stru    :={}     
	private nposdel  := 0
	private nusado   := 0  
	private area     := getarea()

	_aArqTrb  := {} 

	aadd(_Stru,{"OK"     , "C",  02, 0})
	aadd(_Stru,{"COMP"   , "C",  06, 0})
	aadd(_Stru,{"DESCRI" , "C",  30, 0}) 

	aadd(aCampos,{"OK"    ,, "OK"      ,"@!"})
	aadd(aCampos,{"COMP"  ,,"Produto  ","@X"})
	aadd(aCampos,{"DESCRI",,"Descricao","@X"})  

	//cArq := Criatrab(_stru,.T.)   
	//if Select('TRB')<>0 
	//	DbSelectArea('TRB')
	//	DbCloseArea()
	//endif
	//DBUSEAREA(.t.,,cArq,"TRB",.t.,.f.)

	If Select('TRB')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TRB->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TRB", aStru, {}, @_aArqTrb)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a Filtragem                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbSelectArea("ZZD")
	ZZD->(DbSetOrder(1))

	SET FILTER TO ZZD->ZZD_DATA = date() .and. ZZD->ZZD_FILIAL = xfilial('ZZD') .and. ZZD->ZZD_LOCPRO = 'C'

	mBrowse(6      ,1      ,22     ,75     ,cString, ,,,,1     ,)
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores

Return

//Função que realiza a produção dos cortes
user function gjf51pro()

	Private lInverte  := .f.  
	Private cMarca    := getmark()

	private acols    :={}
	private aheader  :={} 

	oFont  := tFont():New("courier new",,-16,,.t.,,,,)
	oTProd := ''  

	DbSelectArea('TRB')

	MntBrw1()

	nusado := gjf51hd() 

	gjf51cl()

	DEFINE MSDIALOG oDlg TITLE 'Desmembramento de Peças' from 0,0 To 500,600 PIXEL

	oSayProd  := tSay():New(013,090,{|| oTProd},oDlg,,oFont,,,,.T.,,,200,30)

	@ 01,001 SAY 'Codigo:'
	@ 01,006 MSGET _cCampo VAR _cValProd SIZE 40,11 OF oDlg  VALID gjf51v()

	oMark  := MsSelect():New("TRB","OK","",aCampos,@lInverte,@cMarca,{030,005,110,300})
	//oMark:bmark  := {||gjf51mkv()}

	@ 010,001 SAY 'Scan Peça:'
	@ 010,006 MSGET _cCampo2 VAR _cValPeca SIZE 80,11 OF oDlg  VALID gjf51s()

	oCor := MSGetDados():New(145,005,210,300,3,,,,.F.,{},,.F.,,,,,,oDlg)

	oMark:oBrowse:refresh()

	@ 220,005  BUTTON 'Produzir'     SIZE 57,20 ACTION produzir() OBJECT oBtn1
	@ 220,080  BUTTON 'Reimpressao'  SIZE 57,20 ACTION alert('Em Contrução') OBJECT oBtn2
	@ 220,240  BUTTON 'Abandonar'    SIZE 57,20 ACTION ODlg:end() OBJECT oBtn3

	ACTIVATE MSDIALOG oDlg CENTERED //ON INIT EnchoiceBar(oDlg,{||gjf17ok()},{||ODlg:end()})

	_cValProd := space(06)

return


//Função para montar o browse 01
Static Function MntBrw1()       

	DbSelectArea('TRB')

	TRB->(DbGoTop())
	while !TRB->(eof())
		reclock('TRB',.f.) 
		dbdelete()
		msunlock()
		TRB->(DbSkip())
	enddo

	cQuery := " SELECT G1_COMP AS COMP"
	cQuery += " FROM " + RetSqlName("SG1") + " WHERE D_E_L_E_T_ <> '*'  AND G1_COD = '"+ _cValProd + "'"
	cQuery += " AND G1_FILIAL = '" + xfilial('SG1') + "'"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	QRY->(DbGoTop())
	TRB->(DbGoTop())

	While QRY->(!eof())

		dbselectarea('SB1')

		reclock('TRB',.t.)
		TRB->COMP    := QRY->COMP
		TRB->DESCRI  := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->COMP,'B1_DESC') 
		msunlock()

		QRY->(DbSkip())
	enddo

	TRB->(DbGoTop())

return

//Função que valida a digitação do codigo da peça 
//no primeiro campo da tela e monta o MsSelect 
//através da função MntBrw1()
Static Function gjf51v() 
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbGotop()  

	gjf51cl()

	MntBrw1()

	DbSelectArea('SB1')
	oTProd := fBuscaCPO('SB1',1,xfilial('SB1')+_cValProd,'B1_DESC')
	_cCampo2:setfocus()
	oMark:oBrowse:refresh()
	oCor:refresh()
	oDlg:refresh()

Return  

//Monta o aHeader do msgetdados 
//(segundo browser)
Static Function gjf51hd()

	Aheader := {}

	aAdd(Aheader,{'Rastro'   ,'RASTRO' ,'@!' , 20 , 0 , , , 'C' ,'TRB',})
	aAdd(Aheader,{'Lado'     ,'LADO'   ,'@!' , 01 , 0 , , , 'C' ,'TRB',})
	aAdd(Aheader,{'Tipif.'   ,'TIPIFI' ,'@!' , 01 , 0 , , , 'C' ,'TRB',})
	aAdd(Aheader,{'Classif.' ,'CLASSI' ,'@!' , 02 , 0 , , , 'C' ,'TRB',})

Return len(aHeader)  

static Function gjf51cl()
	Local nI         

	nPosDel	:= Len(aHeader) + 1
	aCols := {}	
	aCols := Array(1,nUsado+1)

	For nI := 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			aCols[1,nI] := Space(aHeader[nI,4])
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := CtoD(" / / ")
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI

Return


//Valida o scan da carcaças 
static function gjf51s()
	Local i
	if empty(_cValPeca)
		return .t.
	endif

	if substr(_cValPeca,21,1) <> '0'
		msgbox('Peça produzida no Corte!','OPERAÇÃO INVALIDA!','STOP') 
		return .f.
	endif

	if empty(_cValProd)
		msgbox('Produto a ser processado não apontado!','OPERAÇÃO INVALIDA!','STOP') 
		return .f.
	else  

		if TRB->(eof())
			msgbox('Estrutura do produto não listada!','OPERAÇÃO INVALIDA!','STOP') 
			return .f. 
		endif 	
	endif

	_cRastro := substr(_cValPeca,1,20)  
	_cLado   := iif(substr(_cValPeca,22,1)='0','D','E')

	SZK->(DbSetorder(5))
	if !SZK->(DbSeek(xfilial('SZK')+_cRastro))
		SomErr()      
		msgbox('Carcaça inexistente!','OPERAÇÃO INVALIDA!','STOP') 
		Return .f.
	endif

	if empty(SZK->ZK_CLASSIF)
		alert('Problema na classificação da carcaça. Recolha a etiqueta e envie ao DTI!') 
		SomErr()
		return .f.
	endif

	if alltrim(_cValProd) = '000030'
		if SZK->ZK_PROCT  >= 2
			SomErr() 
			msgbox('Traseiros desta carcaça já processados!','OPERAÇÃO INVALIDA!','STOP')
			Return .f.
		endif
	elseif alltrim(_cValProd) = '000031'
		if SZK->ZK_PROCD  >= 2
			SomErr()
			msgbox('Dianteiros desta carcaça já processados!','OPERAÇÃO INVALIDA!','STOP')
			Return .f.
		endif
	elseif alltrim(_cValProd) = '000032'
		if SZK->ZK_PROCC  >= 2
			SomErr()
			msgbox('Costelas desta carcaça já processados!','OPERAÇÃO INVALIDA!','STOP')
			Return .f.
		endif
	endif

	SZN->(DbSetOrder(2))
	SZN->(DbGoTop())
	if SZN->(DbSeek(xfilial('SZN')+_cRastro))
		while SZN->(!eof()) .and. SZN->ZN_FILIAL = xfilial('SZN') .and. SZN->ZN_RASTRO = _cRastro
			if SZN->ZN_COD = alltrim(_cValProd) .and. SZN->ZN_LADO = _cLado
				SomErr()
				msgbox('Peça já processada!','OPERAÇÃO INVALIDA!','STOP') 
				Return .f.
			endif 
			SZN->(DbSkip())
		enddo
	endif

	for i := 1 to len(aCols)
		if aCols[i,1] = _cRastro .and. aCols[i,2] = _cLado
			SomErr()
			msgbox('Peça já processada!','OPERAÇÃO INVALIDA!','STOP') 
			Return .f.	
		endif
	next

	if !empty(aCols[1,1])
		aadd(aCols,{_cRastro,_cLado,SZK->ZK_TIPIFI,SZK->ZK_CLASSIF,.t.})
	else
		aCols[1,1] := _cRastro
		aCols[1,2] := _cLado
		aCols[1,3] := SZK->ZK_TIPIFI
		aCols[1,4] := SZK->ZK_CLASSIF 
		aCols[1,5] := .t.
		aCols[1, nPosDel] := .t.
	endif

	oCor:refresh()
	ExecSom()

return .f.

//Função para efetivar a 
//produção do corte
Static Function produzir()  
	Local i
	Local j
	aProd := {}

	TRB->(DbGoTop())

	While TRB->(!eof())
		if TRB->OK = thismark()
			aadd(aProd,{TRB->COMP})
		endif
		TRB->(DbSkip())
	enddo

	if len(aProd) = 0
		msgbox('Não existem marcas na estrutura do produto!','OPERAÇÃO INVÁLIDA!','STOP')
		MntBrw1()
		oMark:oBrowse:refresh()
		oDlg:refresh()
		return .f.
	endif

	for i:= 1 to len(aCols)     

		RegToMemory("SZN",.T.)
		_cControl :=  GetSx8num('SZN','ZN_CONTROL')
		ConfirmSx8() 

		DbSelectArea('SB1')
		_cDescProd := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(_cValProd),'B1_DESC') 
		_cCorOri   := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(_cValProd),'B1_CORORI') 

		SZK->(DbSetorder(5))
		SZK->(DbSeek(xfilial('SZK')+_cRastro))

		for j := 1 to len(aProd)
			//Registra as novas peças geradas
			//com o desmembramento dos cortes
			reclock('ZA6',.t.)
			ZA6->ZA6_FILIAL := xfilial('ZA6')
			ZA6->ZA6_RASTRO := aCols[i,1]
			ZA6->ZA6_LADO   := aCols[i,2]
			ZA6->ZA6_CLASS  := aCols[i,4]
			ZA6->ZA6_CONTRO := _cControl
			ZA6->ZA6_PRODOR := alltrim(_cValProd)
			ZA6->ZA6_ITEM   := strzero(j,3)
			ZA6->ZA6_COD    := aProd[j]
			ZA6->ZA6_DATA   := data()
			ZA6->ZA6_HORA   := time()   
			ZA6->ZA6_PROGRA := SZK->ZK_RACA
			msunlock()	      
		next

		//Registra as carcaças processadas no corte 

		if _cCorOri = 'T'
			reclock('SZK',.f.)
			SZK->ZK_PROCT := SZK->ZK_PROCT + 1
			msunlock()
		elseif _cCorOri  = 'D'
			reclock('SZK',.f.)
			SZK->ZK_PROCD := SZK->ZK_PROCD + 1
			msunlock()      
		elseif _cCorOri  = 'C'
			reclock('SZK',.f.)
			SZK->ZK_PROCC := SZK->ZK_PROCC + 1
			msunlock()
		elseif _cCorOri  = 'E'
			reclock('SZK',.f.)
			SZK->ZK_PROCT := SZK->ZK_PROCT + 1
			SZK->ZK_PROCC := SZK->ZK_PROCC + 1
			SZK->ZK_PROCD := SZK->ZK_PROCD + 1
			msunlock()    
		endif           

		reclock('SZN',.t.)
		SZN->ZN_CONTROL := _cControl
		SZN->ZN_DATA    := ddatabase
		SZN->ZN_HORA    := time()
		SZN->ZN_FILIAL  := xfilial('SZN')
		SZN->ZN_RASTRO  := aCols[i,1]
		SZN->ZN_COD     := alltrim(_cValProd)
		SZN->ZN_DESCRI  := _cDescProd
		SZN->ZN_EXPORT  := aCols[i,4]
		SZN->ZN_TIPIFI  := aCols[i,3]
		SZN->ZN_LADO    := aCols[i,2]
		SZN->ZN_LOCPROC := 'C'
		SZN->ZN_PROGRAM := SZK->ZK_RACA 
		SZN->ZN_NPCORTE := len(aProd)
		msunlock()

		reclock('ZZD',.t.)
		ZZD->ZZD_CONTRO  := _cControl
		ZZD->ZZD_DATA    := ddatabase
		ZZD->ZZD_HORA    := time()
		ZZD->ZZD_FILIAL  := xfilial('SZN')
		ZZD->ZZD_RASTRO  := aCols[i,1]
		ZZD->ZZD_COD     := alltrim(_cValProd)
		ZZD->ZZD_DESCRI  := _cDescProd
		ZZD->ZZD_EXPORT  := aCols[i,4]
		ZZD->ZZD_TIPIFI  := aCols[i,3]
		ZZD->ZZD_LADO    := aCols[i,2]
		ZZD->ZZD_LOCPROC := 'C'
		msunlock()

	next

	_cValProd := space(06) 
	_cValPeca := space(24) 
	oTProd    := '' 

	oCor:refresh()
	oMark:oBrowse:refresh()
	oDlg:refresh()
	_cCampo:setfocus() 

	gjf51cl()
	MntBrw1()

return .t.

Static Function SomErr()
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
return

Static Function ExecSom()
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)

return

//Função destinada a impressão das etiquetas
Static Function ImpEtq()
	MSCBPRINTER(mv_par01,mv_par02)
	MSCBCHKSTATUS(.t.)
	MSCBBEGIN(2,6)

	MSCBBOX(01,16,60,33)
	MSCBSAYBAR(08,17,M->ZK_NUMAM+M->ZK_LOTE+M->ZK_CONTROL+"00","N","C",10,,.t.,,,2,2,.t.)
	MSCBSAY(50, 17,"D","N","0","100,100")

	MSCBBOX(01,35,14,48)
	MSCBSAY(3, 36,'Gord',"N","E","8,8")
	MSCBSAY(6, 40,M->ZK_COBGOR,"N","0",_Font01)

	MSCBBOX(17, 35,31,48)
	MSCBSAY(20, 36,'Dent',"N","E","8,8")
	MSCBSAY(23, 40,M->ZK_DENT,"N","0",_Font01) 

	MSCBBOX(34, 35,46,48)
	MSCBSAY(35, 36,'Conf',"N","E","8,8")
	MSCBSAY(40, 40,M->ZK_CONFORM,"N","0",_Font01)

	MSCBBOX(48, 35,60,48)
	MSCBSAY(50, 36,'Tip',"N","E","8,8")
	MSCBSAY(50, 40,M->ZK_TIPIFI,"N","0",_Font01)

	MSCBBOX(02,50,60,70)
	MSCBLINEV(39,50,70)
	MSCBLINEH(39,60,60)

	MSCBSAY(03, 52,'Sequencial',"N","E","8,8")
	MSCBSAY(03, 56,M->ZK_CONTROL,"N","0","100,100")

	MSCBSAY(40, 52,'Abate',"N","E","8,8")
	MSCBSAY(40, 55,M->ZK_NUMAM,"N","E","8,8")

	MSCBSAY(40, 62,'Lote',"N","E","8,8")
	MSCBSAY(40, 66,M->ZK_LOTE,"N","E","8,8")      

	MSCBBOX(02,72,60,77)
	MSCBSAY(02,73, GetMv("MV_NUMIF") + strtran(dtoc(dAbate),'/','') +'0000',"N","E","8,8")

	MSCBBOX(02,79,30,89)
	MSCBSAY(03,80,'SIF',"N","E","8,8")
	MSCBSAY(07,84,GetMv("MV_NUMIF"), "N","E","28,15")

	MSCBBOX(32,79,60,89)
	MSCBSAY(33,80,'Data Abate',"N","E","8,8")
	MSCBSAY(37,84,dtoc(dAbate),"N","E","28,15")

	nL := 125

	Private raca  := M->ZK_RACA
	Private nomeRaca := POSICIONE('SZ6', 1, xFilial('SZ6')+raca , 'Z6_DESC')

	MSCBBOX(02,93,60,98)  
	If M->ZK_OBS == '0'  //ok
		MSCBSAY(03,94, 'SISBOV:'+ M->ZK_RASTRO ,"N","E","8,8")
	Endif
	_cCateg := fBuscaCPO('SZ5',1,xfilial('SZ5')+M->ZK_CATEG,'Z5_DESC')  
	if M->ZK_RACA = '006'
		MSCBBOX(02,100,60,109)
		MSCBSAY(03,101,_cCateg,"N","0",_Font01)// *** Verificar campo novo
		MSCBBOX(02,110,60,120) 
		MSCBSAY(10,111,'ANGUS',"N","0","90,105")
		MSCBBOX(02,124,60,144)// quadrado             
		MSCBSAY(10,125,M->ZK_CLASSIF,"N","0","180,300")
	else   
		MSCBBOX(02,100,60,109)
		MSCBSAY(03,101,_cCateg,"N","0",_Font01)
		MSCBBOX(02,110,60,130)
		MSCBSAY(12,111,M->ZK_CLASSIF,"N","0","162,270")  
		If !Empty(nomeRaca) .and.   nomeRaca != '001'
			MSCBSAY(03,138,substr(nomeRaca,1,10), "N","0","100,80")// aqui esta sendo modificado 
		endif                         
	endif              
	//****************************  FIM  *****************************************
	MSCBSAY(13,285,"DTI","N","0","100,190")

	MSCBEND()
	MSCBCLOSEPRINTER()

Return
