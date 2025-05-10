#INCLUDE "topconn.ch"   
#INCLUDE "tbiconn.ch"                                                                                                              
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"   
#INCLUDE "MATA380.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF193     ºAutor  ³Giuliano Forgiarini º Data ³  29/07/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controle do apontamento de devoluções de PA                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qualidade PCP                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF193()

	Local aIndSZN   	:= {}					
	Local cCondicao 	:= ""				
	lOk := .f.
	aObjects := {}                                      
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 :=  "SZN->ZN_DESTINO = 'E' .and. SZN->ZN_FILIAL = '" + xfilial('SZN')+"'"
	bLegenda2 :=  "SZN->ZN_DESTINO = 'R' .and. SZN->ZN_FILIAL = '" + xfilial('SZN')+"' .and.  empty(SZN->ZN_DTSAIDA)"
	bLegenda3 :=  "SZN->ZN_DESTINO = 'R' .and. SZN->ZN_FILIAL = '" + xfilial('SZN')+"' .and. !empty(SZN->ZN_DTSAIDA)"
	bLegenda4 :=  "SZN->ZN_DESTINO = 'P' .and. SZN->ZN_FILIAL = '" + xfilial('SZN')+"' .and.  empty(SZN->ZN_DTSAIDA)"
	bLegenda5 :=  "SZN->ZN_DESTINO = 'P' .and. SZN->ZN_FILIAL = '" + xfilial('SZN')+"' .and. !empty(SZN->ZN_DTSAIDA)"
	bLegenda6 :=  "SZN->ZN_DESTINO = 'C' .and. SZN->ZN_FILIAL = '" + xfilial('SZN')+"'"
	bLegenda7 :=  "SZN->ZN_DESTINO = 'G' .and. SZN->ZN_FILIAL = '" + xfilial('SZN')+"'"

	aCores2:= {{'BR_VERDE'   ,'Estoque'     },;
	{'BR_AMARELO' ,'Repes. na Cam.'  },;
	{'BR_AZUL   ' ,'Repes.Fora da Cam.'  },;
	{'BR_LARANJA' ,'Reproc.na Cam.' },;
	{'BR_CINZA'   ,'Reproc.Fora da Cam.' },;
	{'BR_VERMELHO','Charque'     },;
	{'BR_PRETO'   ,'Graxaria'}}

	aCores := { {bLegenda1, 'BR_VERDE'   },;
	{bLegenda2, 'BR_AMARELO' },;
	{bLegenda3, 'BR_AZUL'    },;
	{bLegenda4, 'BR_LARANJA' },;
	{bLegenda5, 'BR_CINZA'   },;
	{bLegenda6, 'BR_VERMELHO'},;
	{bLegenda7, 'BR_PRETO'}}


	Private cPerg     := "GJF193"
	Private cCadastro := "Controle de apontamentos de devoluções"
	Private aRotina    := { {"Pesquisar"    ,"AxPesqui"  ,0,1} ,;
	{"&Visualizar"  ,"AxVisual"  ,0,2} ,;  
	{"&Incluir"     ,"" ,0,3} ,;                      
	{"&Alterar"     ,"u_gjf193a" ,0,4} ,;                          
	{"E&xcluir"     ,"u_gj193x"  ,0,5} ,;
	{"Legenda"      ,"u_gjf193l" ,0,2}}  
	//{"&Incluir"     ,"u_gjf193i" ,0,3} ,;

	cString := "SZN"
	dbSelectArea(cString)
	SZN->(dbsetorder(1))

	if !pergunte(cPerg,.t.)
		return
	endif

	cCondicao := "ZN_DTENTR >=  '" + dtos(mv_par01) + "' AND ZN_DTENTR <=  '" + dtos(mv_par02) + "'" +;
	" AND ZN_FILIAL = '" + xfilial('SZN') + "' " + iif(mv_par03 = 1, " AND ZN_DESTINO = 'E'",;
	iif(mv_par03 = 2, " AND ZN_DESTINO IN ('R','P')",; 
	iif(mv_par03 = 3, " AND ZN_DESTINO = 'C'",;
	iif(mv_par03 = 4, " AND ZN_DESTINO = 'G'",""))))

	if !empty(mv_par04) .and. !empty(mv_par05)
		cCondicao += " AND ZN_CLIENTE = '" + mv_par04  + "' AND ZN_LOJA = '" + mv_par05  + "'"
	endif

	if !empty(mv_par06) .and. !empty(mv_par07)
		cCondicao += " AND ZN_NF = '" + mv_par06  + "' AND ZN_SERIE = '" + mv_par07  + "'"
	endif


	mBrowse(6,1,22,75,cString, ,,,,2,aCores,,,,{|x| AutoRefresh(x)},,,,cCondicao) 

	DbCloseArea('SZN')   


return

//Inclusão
user function gjf193i(cAlias,nReg,nOpc)
	Local nCont
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0

	DEFINE MSDIALOG oDlg TITLE 'Apontamento de Devolução' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("SZN",.T.) 

	obj := MsMGet():New("SZN" ,SZN->(RECNO()),3   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gf193ok()},{||gf193nok()})
	If lOk 

		ConfirmSX8()

		recLock('SZN',.T.)
		// Grava previsao de producao
		For nCont := 1 To FCount()
			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("SZN"))
			Else
				FieldPut(nCont,M->&(FIELDNAME(nCont)))
			Endif
		Next nCont

		MsUnLock() 

	else
		RollBackSx8()
	endif    

return

//Alteração
User function gjf193a(cAlias,nReg,nOpc)
	Local nCont
	//Private aHeader	:= {}
	//Private aCols	:= {}
	//Private _cProd := ''
	//Private nUsado	:=	0   

	if SZN->ZN_DESTINO <> 'C' .or. SZN->ZN_DESTINO <> 'G'
		if !empty(SZN->ZN_DTSAIDA)
			alert('Devolução já se encontra fora da camara')	
			SZN->(DbGoTop())
			return	
		endif            
	endif

	//if SZN->ZN_DTENTR < dDataBase
	//	alert('Devolução fora do prazo de 1 dia para alteração')
	//	SZN->(DbGoTop())
	//	return		
	//endif       


	DEFINE MSDIALOG oDlg TITLE 'Previsão de Gerenciamento de Producao' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("SZN",.F.)        

	M->ZN_CODUSER     := retCodUsr()

	obj := MsMGet():New("SZN" ,SZN->(RECNO()),4   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gf193oka()},{||gf193nok()}, ,)


	If lOk     
		recLock('SZN',.F.)
		// Grava previsao de producao
		For nCont := 1 To FCount()
			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("SZN"))
			Else
				FieldPut(nCont,M->&(FIELDNAME(nCont)))
			Endif
		Next nCont
		MsUnLock()
	endif

return


static function gf193ok()
	lOk := .t.
	Odlg:end()
Return lOk

static function gf193oka()
	lOk := .t.
	Odlg:end()      
Return lOk


static function gf193nok()
	lOk := .f.
	Odlg:end()
Return


user function gj193x()

	local _lOk := .t.
	_cNum := SZN->ZN_NUM

	//alert(_cNum)

	SZN->(DbGoTop())
	SZN->(DbSetOrder(8))
	if SZN->(DbSeek(xFilial('SZN') + _cNum))
		if !empty(SZN->ZN_DTSAIDA)
			alert('Devolução já se encontra fora da camara')	
			SZN->(DbGoTop())
			return	
		endif

		//if SZN->ZN_DTENTR < dDataBase
		//	alert('Devolução fora do prazo de 1 dia para exclusão')
		//	SZN->(DbGoTop())
		//	return		
		//endif       

		if !msgbox('Deseja realmente excluir esta devolução? Continua(S/N)','EXCLUSÃO DE DEVOLUÇÃO','YESNO')
			_lOk := .f.
		endif		
	else
		alert('Devolução não encontrada')		
		return
	endif

	if _lOk           
		reclock('SZN',.f.)
		dbdelete()
		msunlock()	
	endif   	      

	SZN->(DbGoTop())    

return


user Function gjf193l()
	BrwLegenda('Destinos',"Legenda",aCores2)
return 


////Funções para atualização do mBrowse////
Static Function AutoRefresh(oDlg)
	Local oTimer
	oTimer := TTimer():New(2, {|| PBrow() }, oDlg)  
	oTimer:Activate()
Return .T.

////Funções para atualização do mBrowse////
Static Function PBrow()
	oBrowse := getObjBrow() 
	oBrowse:default() 
	oBrowse:refresh()
Return  


