#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF49  ºAutor  ³Giuliano Forgiarini º Data ³  13/09/09      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle de Peças  e Manutenção de Estoque                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF49()


	lOk         := .f.
	oDesc       := '' 
	vNumPrev    := ''
	aIndSZK   	:= {}					                                                               	// Arquivo e número de índice utilizado
	cCondicao 	:= ""					                                                               	// Condição para a filtragem

	Private cPerg   := "GJF49"
	Private cCadastro := "Controle de Peças e Manutenção de Lotes"
	Private aRotina := { {"Pesquisar","AxPesqui"    ,0,1} ,;
	{"Consultar","u_gjf49con " ,0,4},;
	{"Desc.Cons.","u_gjf49dco" ,0,4},;
	{"Desc.Sum.","u_gjf49sum" ,0,4},;
	{"Reimprimir","u_gjf49imp" ,0,4}}     

	private cString := "SZK"   

	if !pergunte(cPerg,.t.)
		return
	endif                                                   
	_cMod   := alltrim(mv_par03)                           //modelo imp zebra
	_cPor   := alltrim(mv_par04)                           //porta im zebra




	dbSelectArea(cString)
	SZK->(dbSetOrder(5))

	cCondicao := "SZK->ZK_NUMAM = '" +  mv_par01 + "' .and.  SZK->ZK_LOTE = '" + mv_par02 + "' .and. SZK->ZK_FILIAL = '" + xfilial('SZK') + "'"

	FilBrowse("SZK",@aIndSZK,@cCondicao)

	mBrowse( 6, 1, 22, 75,cString,,,,,,)

	Set Key 123 To 																	// Desativa a tecla F12 do acionamento dos parametros

	If ( Len(aIndSZK)>0 )
		EndFilBrw("SZK",@aIndSZK)                                                   //Encerra o filtro e refaz os índices padrões
	endif     

	DbCloseArea('SZK')   

Return


user function gjf49con()
	_cDD    := 0
	_cTD    := 0

	SZ4->(DbSetOrder(1))
	SZ4->(DbSeek(xfilial('SZ4')+SZK->(ZK_NUMAM+ZK_LOTE))) 

	DEFINE MSDIALOG oDlg TITLE 'Consulta de Peças' from 0,0 To 600,560 PIXEL

	oFont       := tFont():New("courier new",,-18,,.t.,,,,)
	oFont2      := tFont():New(,,,,.t.,,,,)
	oFont3      := tFont():New(,,-16,,.t.,,,,)
	oSayLabel1  := tSay():New(010,10,{|| 'Aviso de Matança nº:'},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayCont1   := tSay():New(008,70,{|| SZK->ZK_NUMAM },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)  
	oSayLabel7  := tSay():New(030,140,{|| 'Sexo:'},oDlg,,oFont2,,,,.T.,,,200,30)   
	oSayCont7   := tSay():New(028,190,{|| iif(SZK->ZK_SEXO = 'M','Macho','Femea') },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 

	if !empty(SZK->ZK_OPCORD) .or. !empty(SZK->ZK_OPCORT)       // rever com giuliano isso deveria buscar das tabelas de processados
		_cClasOP1 := ""
		_cClasOP2 := ""
		_cClasOP1 := fBuscaCPO('SZ2',2,xfilial('SZ2')+SZK->ZK_OPCORD,'Z2_CLASSIF')
		_cClasOP2 := fBuscaCPO('SZ2',2,xfilial('SZ2')+SZK->ZK_OPCORT,'Z2_CLASSIF')
		oSayLabel10 := tSay():New(040,140,{|| 'Reserv. OP Diant.:'},oDlg,,oFont2,,,,.T.,,,200,30)   
		oSayCont10  := tSay():New(038,190,{|| SZK->ZK_OPCORD + ' (' + _cClasOP1 + ') ' },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 
		oSayLabel11 := tSay():New(050,140,{|| 'Reserv. OP Tras.: '},oDlg,,oFont2,,,,.T.,,,200,30)   
		oSayCont11  := tSay():New(048,190,{|| SZK->ZK_OPCORT + ' (' + _cClasOP2 + ') '},oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 
	endif 

	_clin3 := 6
	_aString3 := {} 
	SZL->(DbSetOrder(1))   
	if SZL->(DbSeek(xfilial('SZL')+SZK->(ZK_NUMAM+ZK_CONTROL))) 
		while SZL->(!eof()).and. SZL->ZL_NUMAM = SZK->ZK_NUMAM .and. SZK->ZK_CONTROL = SZL->ZL_SEQUEN  
			AADD(_aString3,SZL->ZL_PH)            
			SZL->(DbSkip())
		enddo 
	endif 

	if len(_aString3) = 1
		@_clin3,18 say 'Analise de pH  - Carcaça 01: ' + alltrim(str(_aString3[1]))
		_clin3 += 1 
	elseif len(_aString3) = 2
		@_clin3,18 say 'Analise de pH  - Carcaça 01: ' + alltrim(str(_aString3[1]))
		_clin3 += 1 
		@_clin3,18 say 'Analise de pH  - Carcaça 02: ' + alltrim(str(_aString3[2]))
		_clin3 += 1 
	endif

	oSayLabel2 := tSay():New(020,10,{|| 'Lote nº:'},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayCont2  := tSay():New(018,70,{|| SZK->ZK_LOTE + ' (' + SZ4->Z4_CLASSIF  + ')'},oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 
	oSayLabel3 := tSay():New(030,10,{|| 'Sequencial nº:'},oDlg,,oFont2,,,,.T.,,,200,30)   
	oSayCont3  := tSay():New(028,70,{|| SZK->ZK_CONTROL },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 

	if AllTrim(SZ4->Z4_CLASSIF) = 'RT'
		oSayLabel3 := tSay():New(040,10,{|| 'SISBOV:'},oDlg,,oFont2,,,,.T.,,,200,30)   
		oSayCont3  := tSay():New(038,70,{|| SZK->ZK_RASTRO },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 
	endif 

	if AllTrim(SZ4->Z4_CLASSIF) = 'RT'  .and. AllTrim(SZK->ZK_CLASABA) <> 'RT' .and. SZK->ZK_OBS <> '0' 
		do case       
			case '1'
			_cMot := 'Sem Brinco'
			case '2'
			_cMot := 'Brinco Errado'
			case '3'
			_cMot := 'Sexo Errado'
			case '4'
			_cMot := 'Idade'
			case '7'
			_cMot := 'DIF'

		endcase
		oSayLabel3 := tSay():New(040,10,{|| 'Mot. Desclassif.:'},oDlg,,oFont2,,,,.T.,,,200,30)   
		oSayCont3  := tSay():New(038,70,{||  _cMot},oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 
	endif 


	oSayLabel4 := tSay():New(050,10,{|| 'Class. Abate:'},oDlg,,oFont2,,,,.T.,,,200,30)   
	oSayCont4  := tSay():New(048,70,{|| SZK->ZK_CLASABA },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 
	oSayLabel5 := tSay():New(060,10,{|| 'Passagem pelo DIF?'},oDlg,,oFont2,,,,.T.,,,200,30)   
	oSayCont5  := tSay():New(058,70,{|| iif(SZK->ZK_IF = 'S','Sim','Nao') },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 
	oSayLabel6 := tSay():New(070,10,{|| 'Cons. Maturação?'},oDlg,,oFont2,,,,.T.,,,200,30)   
	oSayCont6  := tSay():New(068,70,{|| iif(SZK->ZK_MATURA = 'S','Sim','Nao') },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 
	oSayLabel7 := tSay():New(080,10,{|| 'Classificação Final:'},oDlg,,oFont2,,,,.T.,,,200,30)   
	oSayCont7  := tSay():New(078,70,{|| SZK->ZK_CLASABA },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 

	_clin := 9
	_aString := {}  
	_cString := ''
	//SZN->(DbSetorder(2))
	//SZN->(DbSetorder(5))
	//if SZN->(DbSeek(xfilial('SZN')+SZK->(ZK_NUMAM+ZK_LOTE+ZK_CONTROL))) 
	if SZN->(DbSeek(xfilial('SZN')+SZK->(ZK_NUMAM+ZK_CONTROL))) 
		//alert('2')
		oSayLabel8 := tSay():New(100,10,{|| 'Entrada da Desossa:'},oDlg,,oFont,,,,.T.,,,200,30)   
		//while SZN->(!eof()) .and.  SZN->ZN_FILIAL = xfilial('SZN') .and. alltrim(SZK->(ZK_NUMAM+ZK_LOTE+ZK_CONTROL)) = alltrim(SZN->ZN_RASTRO)
		while SZN->(!eof()) .and.  SZN->ZN_FILIAL = xfilial('SZN') .and. alltrim(SZK->(ZK_NUMAM+ZK_CONTROL)) = alltrim(SZN->(ZN_NUMAM+ZN_SEQUEN))
			//alert('3')
			_cString := SZN->ZN_DESCRI + '...    Desossado em ' + dtoc(SZN->ZN_DATA) + '   as ' +;
			SZN->ZN_HORA + ' horas    Lado ' + iif(SZN->ZN_LADO = 'D','Dir.','Esq.') + ' na OP ' + SZN->ZN_PREV
			AADD(_aString,_cString)            
			SZN->(DbSkip())
		enddo
	endif   

	if len(_aString) = 1
		@_clin,01 say _aString[1]
		_clin += 1 
	elseif len(_aString) = 2
		@_clin,01 say _aString[1]
		_clin += 1 
		@_clin,01 say _aString[2]
		_clin += 1 
	elseif len(_aString) = 3
		@_clin,01 say _aString[1]
		_clin += 1 
		@_clin,01 say _aString[2]
		_clin += 1 
		@_clin,01 say _aString[3]
		_clin += 1 
	elseif len(_aString) = 4
		@_clin,01 say _aString[1]
		_clin += 1 
		@_clin,01 say _aString[2]
		_clin += 1 
		@_clin,01 say _aString[3]
		_clin += 1 
		@_clin,01 say _aString[4]
		_clin += 1 
	endif


	_clin2 := 15
	_aString2 := {}  
	_cString2 := ''  
	_cProd := ''
	ZZG->(DbSetorder(4)) 
	if ZZG->(DbSeek(xfilial('ZZG')+SZK->(ZK_NUMAM+ZK_CONTROL))) 
		oSayLabel9 := tSay():New(176,10,{|| 'Carregamento de Peças:'},oDlg,,oFont,,,,.T.,,,200,30)   
		while ZZG->(!eof()) .and.  ZZG->ZZG_FILIAL = xfilial('ZZG') .and. alltrim(SZK->(ZK_NUMAM+ZK_CONTROL)) = ZZG->(ZZG_NUMAM+ZZG_CONTRO) 
			_cProd := fBuscaCPO('SB1',1,xfilial('SB1')+ZZG->ZZG_COD,'B1_DESC')
			_cData := dtoc(fBuscaCPO('ZZ2',2,xfilial('ZZ2')+ZZG->(ZZG_PREPED+ZZG_NUM+ZZG_ITEM),'ZZ2_DATAC'))
			_cHora := fBuscaCPO('ZZ2',2,xfilial('ZZ2')+ZZG->(ZZG_PREPED+ZZG_NUM+ZZG_ITEM),'ZZ2_HORAC')
			_cString2 := alltrim(_cProd) + '  Carregado em  ' + _cData + '  as  ' + _cHora + '  no Carreg.  ' +;
			ZZG->ZZG_PRECAR + '  no Pre-Ped.  ' + ZZG->ZZG_PREPED
			AADD(_aString2,_cString2)            
			ZZG->(DbSkip())
		enddo
	endif   

	if len(_aString2) = 1
		@_clin2,01 say _aString2[1]
		_clin2 += 1 
	elseif len(_aString2) = 2
		@_clin2,01 say _aString2[1]
		_clin2 += 1 
		@_clin2,01 say _aString2[2]
		_clin2 += 1 
	elseif len(_aString2) = 3
		@_clin2,01 say _aString2[1]
		_clin2 += 1 
		@_clin2,01 say _aString2[2]
		_clin2 += 1 
		@_clin2,01 say _aString2[3]
		_clin2 += 1 
	elseif len(_aString2) = 4
		@_clin2,01 say _aString2[1]
		_clin2 += 1 
		@_clin2,01 say _aString2[2]
		_clin2 += 1 
		@_clin2,01 say _aString2[3]
		_clin2 += 1 
		@_clin2,01 say _aString2[4]
		_clin2 += 1 
	endif


	@ 275,190  BUTTON 'Fechar'   SIZE 45,15 ACTION ODlg:end()  OBJECT oBtn2
	ACTIVATE MSDIALOG oDlg CENTERED
return




User Function gjf49imp()

	If empty(_cMod)
		Return
	Endif

	reimprime()
Return



//************************************************  
Static Function reimprime(dAbate)
	dAbate := Posicione('SZG',1,xFilial('SZG')+ZK_NUMAM+ZK_LOTE,'ZG_DATA')
	_Font01 := "60,60"
	//As duas primeiras etiquetas do lado esquerdo            

	MSCBPRINTER(_cMod,_cPor)
	MSCBCHKSTATUS(.t.)
	MSCBBEGIN(1,6)

	MSCBBOX(01,16,60,33)
	MSCBSAYBAR(08,17,SZK->ZK_NUMAM+SZK->ZK_LOTE+SZK->ZK_CONTROL+"00","N","C",10,,.t.,,,2,2,.t.)
	MSCBSAY(50,17,"D","N","0","100,100")

	MSCBBOX(01,35,14,48)
	MSCBSAY(3, 36,'Gord',"N","E","8,8")
	MSCBSAY(6,40,SZK->ZK_COBGOR,"N","0",_Font01)

	MSCBBOX(17,35,31,48)
	MSCBSAY(20,36,'Dent',"N","E","8,8")
	MSCBSAY(23,40,SZK->ZK_DENT,"N","0",_Font01)

	MSCBBOX(34,35,46,48)
	MSCBSAY(35,36,'Conf',"N","E","8,8")
	MSCBSAY(40,40,SZK->ZK_CONFORM,"N","0",_Font01)

	MSCBBOX(48,35,60,48)
	MSCBSAY(50,36,'Tip',"N","E","8,8")
	MSCBSAY(50,40,SZK->ZK_TIPIFI,"N","0",_Font01)

	MSCBBOX(02,50,60,70)
	MSCBLINEV(39,50,70)
	MSCBLINEH(39,60,60)

	MSCBSAY(03,52,'Sequencial',"N","E","8,8")
	MSCBSAY(03,56,SZK->ZK_CONTROL,"N","0","100,100")

	MSCBSAY(40,52,'Abate',"N","E","8,8")
	MSCBSAY(40,55,SZK->ZK_NUMAM,"N","E","8,8")

	MSCBSAY(40,62,'Lote',"N","E","8,8")
	MSCBSAY(40,66,SZK->ZK_LOTE,"N","E","8,8")

	MSCBBOX(02,72,60,77)
	MSCBSAY(02,73, GetMv("MV_NUMIF") + strtran(dtoc(dAbate),'/','') +'0000',"N","E","8,8")

	MSCBBOX(02,79,30,89)
	MSCBSAY(03,80, 'SIF',"N","E","8,8")
	MSCBSAY(07,84, GetMv("MV_NUMIF"), "N","E","28,15")

	MSCBBOX(32,79,60,89)
	MSCBSAY(33,80,'Data Abate',"N","E","8,8")
	MSCBSAY(37,84, dtoc(dAbate),"N","E","28,15")

	nL := 125

	Private raca  := SZK->ZK_RACA  

	raca := If(  !Empty( raca), raca,'001' )

	Private nomeRaca := POSICIONE('SZ6', 1, xFilial('SZ6')+raca , 'Z6_DESC')

	MSCBSAY(03,90, 'Raca: '+ nomeRaca, "N","E","8,8")

	MSCBBOX(02,93,60,98)  
	If SZK->ZK_OBS == '0'  //ok
		MSCBSAY(03,94, 'SISBOV:'+(SZK->ZK_RASTRO),"N","E","8,8")
	Endif

	MSCBBOX(02,100,60,120)
	MSCBSAY(12,101,SZK->ZK_CLASABA,"N","0","180,300")


	MSCBSAY(13,285,"DTI","N","0","100,190")

	MSCBEND()
	MSCBCLOSEPRINTER()
Return


//Função que serva para desclassificar o lote caso seja constatada conserva em alguma carcaça
User Function gjf49dco()  

	if !msgbox('Deseja realmente desclassificar esse lote por conserva?','AVISO DE DESCLASSIFICAÇÃO','YESNO')
		return .f.
	endif

	_achou := .f.

	SZK->(DbSetOrder(2))
	SZK->(DbGoTop())
	SZK->(DbSeek(xfilial('SZK')+mv_par01+mv_par02))
	while SZK->(!eof()) .and. SZK->ZK_FILIAL = xfilial('SZK');
	.and. SZK->ZK_NUMAM = mv_par01;
	.and. SZK->ZK_LOTE = mv_par02
		if SZK->ZK_DESTINO $ 'R/G'
			_achou := .t.
			exit
		endif
		SZK->(DbSkip())
	enddo   

	//if _achou
	SZK->(DbGoTop())
	SZK->(DbSeek(xfilial('SZK')+mv_par01+mv_par02))
	while SZK->(!eof()) .and. SZK->ZK_FILIAL = xfilial('SZK');
	.and. SZK->ZK_NUMAM = mv_par01;
	.and. SZK->ZK_LOTE = mv_par02 

		if SZK->ZK_DESTINO $ 'R/G'
			reclock('SZK',.f.)
			SZK->ZK_CLASSIF := 'NE' 
			SZK->ZK_CLASABA := 'NE'
			msunlock()             
		else
			reclock('SZK',.f.)
			if AllTrim(SZK->ZK_CLASABA) <> 'NE'
				SZK->ZK_CLASSIF := 'HK'
				SZK->ZK_CLASABA := 'HK'
			endif
			msunlock()             
		endif

		_claT := ''
		_claD := ''

		_claT := fBuscaCPO('SZ2',2,xfilial('SZ2')+SZK->ZK_OPCORT,'Z2_CLASSIF')
		_claD := fBuscaCPO('SZ2',2,xfilial('SZ2')+SZK->ZK_OPCORD,'Z2_CLASSIF')  

		if (!empty(SZK->ZK_OPCORD) .or. !empty(SZK->ZK_OPCORT)) .and.;
		SZK->ZK_PROCD = 0 .and. SZK->ZK_PROCT = 0 .and. !(SZK->ZK_CLASABA $ _claT+"/"+_claD)
			SZ2->(DbSetOrder(4))  

			if SZ2->(DbSeek(xfilial('SZ2')+SZK->(ZK_NUMAM+ZK_OPCORD)))
				reclock('SZ2',.f.)
				SZ2->Z2_QPPECA := SZ2->Z2_QPPECA - 2
				SZ2->Z2_QRPESO := SZ2->Z2_QPPESO - (SZK->ZK_PETOTAL * 0.38)
				msunlock()
			endif  

			if SZ2->(DbSeek(xfilial('SZ2')+SZK->(ZK_NUMAM+ZK_OPCORT)))
				reclock('SZ2',.f.)
				SZ2->Z2_QPPECA := SZ2->Z2_QPPECA - 2
				SZ2->Z2_QRPESO := SZ2->Z2_QPPESO - (SZK->ZK_PETOTAL * 0.48)
				msunlock()
			endif

			RecLock('SZK',.F.)			
			SZK->ZK_OPCORD := ''
			SZK->ZK_OPCORT := '' 
			MsUnlock()

			msgbox('Carcaça de numero  ' + transform(SZK->ZK_CONTROL,'@E 999999') + ' já pertencia a uma Previsão de Produção da Desossa!',;
			'CARCAÇA REMOVIDA DE PREVISÃO DE PRODUÇÃO DEVIDO A DESCLASSIFICACAO!','INFO')
		endif

		SZK->(DbSkip())
	enddo  
	msgbox('Carcaças reclassificadas com sucesso!','LOTE RECLASSIFICADO!','INFO') 
	//else
	//	alert('Este lote não possui carcaças em conserva!')
	//endif
Return                                         


//Função que serva para desclassificar TODO o lote de forma sumária
User Function gjf49sum()  

	if !msgbox('Deseja realmente desclassificar sumariamente esse lote?','AVISO DE DESCLASSIFICAÇÃO','YESNO')
		return .f.
	endif

	_achou := .f.

	SZK->(DbSetOrder(2))
	SZK->(DbGoTop())
	SZK->(DbSeek(xfilial('SZK')+mv_par01+mv_par02))
	while SZK->(!eof()) .and. SZK->ZK_FILIAL = xfilial('SZK');
	.and. SZK->ZK_NUMAM = mv_par01;
	.and. SZK->ZK_LOTE = mv_par02 

		if  AllTrim(SZK->ZK_CLASABA) = 'RT' 
			reclock('SZK',.f.)
			SZK->ZK_CLASABA := 'RU'
			SZK->ZK_CLASSIF := 'RU'
			msunlock()
		elseif AllTrim(SZK->ZK_CLASABA) = 'RU'
			reclock('SZK',.f.)
			SZK->ZK_CLASABA := 'HK'
			SZK->ZK_CLASSIF := 'HK'
			msunlock()
		elseif AllTrim(SZK->ZK_CLASABA) = 'HK'
			reclock('SZK',.f.)
			SZK->ZK_CLASABA := 'NE'
			SZK->ZK_CLASSIF := 'NE'
			msunlock()
		endif

		_claT := ''
		_claD := ''

		_claT := fBuscaCPO('SZ2',2,xfilial('SZ2')+SZK->ZK_OPCORT,'Z2_CLASSIF')
		_claD := fBuscaCPO('SZ2',2,xfilial('SZ2')+SZK->ZK_OPCORD,'Z2_CLASSIF')  

		if (!empty(SZK->ZK_OPCORD) .or. !empty(SZK->ZK_OPCORT)) .and.;
		SZK->ZK_PROCD = 0 .and. SZK->ZK_PROCT = 0 .and. !(SZK->ZK_CLASABA $ _claT+"/"+_claD)
			SZ2->(DbSetOrder(4))  

			if SZ2->(DbSeek(xfilial('SZ2')+SZK->(ZK_NUMAM+ZK_OPCORD)))
				reclock('SZ2',.f.)
				SZ2->Z2_QPPECA := SZ2->Z2_QPPECA - 2
				SZ2->Z2_QRPESO := SZ2->Z2_QPPESO - (SZK->ZK_PETOTAL * 0.38)
				msunlock()
			endif  

			if SZ2->(DbSeek(xfilial('SZ2')+SZK->(ZK_NUMAM+ZK_OPCORT)))
				reclock('SZ2',.f.)
				SZ2->Z2_QPPECA := SZ2->Z2_QPPECA - 2
				SZ2->Z2_QRPESO := SZ2->Z2_QPPESO - (SZK->ZK_PETOTAL * 0.48)
				msunlock()
			endif

			RecLock('SZK',.F.)			
			SZK->ZK_OPCORD := ''
			SZK->ZK_OPCORT := '' 
			MsUnlock()

			msgbox('Carcaça de numero  ' + transform(SZK->ZK_CONTROL,'@E 999999') + ' já pertencia a uma Previsão de Produção da Desossa!',;
			'CARCAÇA REMOVIDA DE PREVISÃO DE PRODUÇÃO DEVIDO A DESCLASSIFICACAO!','INFO')
		endif

		SZK->(DbSkip())
	enddo  
	msgbox('Carcaças reclassificadas com sucesso!','LOTE RECLASSIFICADO!','INFO') 
	//else
	//	alert('Este lote não possui carcaças em conserva!')
	//endif
Return                                         
