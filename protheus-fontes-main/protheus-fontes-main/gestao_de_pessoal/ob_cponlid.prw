#INCLUDE 'protheus.ch'
#INCLUDE "TOPCONN.CH"

user function ob_CPonLid()
	local _x
	private nValor := 0.00
	Private aArq := {}
	Private alHabCpo := {}
	private alHabB := {}
	private cJust  := space(50)
	private cProblem := space(50)
	private oP1Ent,oP2Ent,oP3Ent,oP4Ent,oP1Said,oP2Said,oP3Said,oP4Said,oJust
	private nP1Ent,nP2Ent,nP3Ent,nP4Ent,nP1Said,nP2Said,nP3Said,nP4Said, _nHrTot := 00.00
	private nInd := 0
	private oBtnE1B,oBtnE2B,oBtnE21C,oBtnE3B,oBtnE3C,oBtnE4C
	private oDlg
	private nOpca,nOp
	Private _nMarc
	Private cCadastro := "Inconsistências ponto eletrônico"
	
	private _cPdCpFalta := "203" //código do evento de compensação de faltas
	private _cPdAcordo  := "015" //código do evento de geração do banco de horas troca de roupa	
	private _cPdCpAtest := "204" //código do evento de compensação de atestado

	private cPerPo:= Alltrim(GetMv("MV_PONMES"))
	private _dDPIni := stod(left(cPerPo,8))
	private _dDPFim := stod(right(cPerPo,8))

	DEFINE FONT oFnt NAME "Arial" SIZE 12,14 BOLD

	private oGreen   := LoadBitmap( GetResources(), "BR_VERDE")
	private oRed     := LoadBitmap( GetResources(), "BR_VERMELHO")
	private oBlack   := LoadBitmap( GetResources(), "BR_PRETO")
	private oYellow  := LoadBitmap( GetResources(), "BR_AMARELO")

	if !SM0->M0_CODIGO $ "01"
		MsgAlert("Rotina não disponível para essa empresa.")
		return
	endif

	Dbselectarea("ZBE")
	dBSetOrder(1)
	if DbSeek(xFilial("ZBE") + __cUserID, .T.)
		if ZBE->ZBE_ATIVO <> '1'
			MsgAlert("Somente líderes ativos podem acessar esta rotina, verifique.")
			return
		endif
	else
		MsgAlert("Usuário não cadastrado nos líderes, acesso não permitido.")
		return
	endif
	
	cPerg :=  "OBCPONLID"
	ValidPerg()
	//MV_PAR03 := RetCodUsr()
	//U_GravaSX1(cPerg, "03", RetCodUsr())

	// faz o calculo automatico de dimensoes de objetos
	aSize := MsAdvSize(,.F.,370)
	aObjects := {}
	aVisual := {}
	AAdd( aObjects, { 015, 200 , .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	if Pergunte(cPerg,.T.)
		if MV_PAR01 < _dDPIni .or. MV_PAR02>_dDPFim  
			MsgAlert("Datas não podem estar fora do período do ponto que é de '"+dtoc(_dDPIni)+"' a '"+dtoc(_dDPFim)+"' ")
			return()
		endif
		retMP()

		if len(aArq) > 0

			aArq := aSort(aArq,,,{|x,y| x[4]+dtos(x[2]) < y[4]+dtos(y[2])})

			DEFINE MSDIALOG oDlgKco TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] pixel //OF oMainWnd  pixel

			@ 032, 005 Say "Intervalo de datas" FONT oDlgKco:oFont PIXEL Of oDlgKco
			@ 032, 060 Say dtoc(mv_par01)+ ' a '+dtoc(mv_par02) Picture "@!" FONT oFnt COLOR CLR_HBLUE	PIXEL Of oDlgKco

			@ 045, 005 LISTBOX oListp FIELDS HEADER '','Data','Dia','Matricula','Nome', '1E','1S','2E','2S','3E','3S','4E','4S','Problema','Justificativa' FIELDSIZES 100 SIZE (oDlgKco:nClientWidth / 2) - 20  , (oDlgKco:nClientHeight / 2) - 50  SCROLL OF oDlgKco PIXEL

			oListp:SetArray(aArq)
			oListp:bLine:= _bAtul()
			oListp:bLDblClick := {|| corrige_ponto(oListp:nAt),oListp:SetArray(aArq),oListp:bLine:=_bAtul(),oListp:Refresh()}

			aButtons := {}
			AADD(aButtons,{"S4WB009N", {|| corrige_ponto(oListp:nAt),oListp:SetArray(aArq),oListp:bLine:=_bAtul(),oListp:Refresh()},'Corrigir'})
			Aadd(aButtons,{"HISTORIC", {|| ob_excZBD(oListp:nAt),oListp:SetArray(aArq),oListp:bLine:=_bAtul(),oListp:Refresh()}, "Excluir...", "Excluir" , {|| .T.}} )

			ACTIVATE MSDIALOG oDlgKco CENTERED ON INIT EnchoiceBar(oDlgKco,{|| nOp:=1, oDlgKco:End()},	{|| nOp:= 2, oDlgKco:End()},,aButtons)

		else
			MsgAlert("Sem inconsistências")
		endif

		if nOp == 1
		//U_SHOWARRAY(aArq)
			DbSelectArea('ZBD')
			DbSetOrder(1)
			for _x:= 1 to len(aArq)
				if  aArq[_x][25] == "ZBD" .and. aArq[_x][1] == 3
					//u_showarray(aArq[_x])
					dbSeek(xFilial('ZBD')+ aArq[_x][4] + DTOS(aArq[_x][2]),.T.)
					if found()
						RecLock("ZBD",.F.)
					else
						RecLock("ZBD",.T.)
					endif
					ZBD->ZBD_FILFUN:= cFilAnt
					ZBD->ZBD_DATA := aArq[_x][2]
					ZBD->ZBD_MAT  := aArq[_x][4]	
					ZBD->ZBD_1E   := aArq[_x][6] 
					ZBD->ZBD_1S   := aArq[_x][7]
					ZBD->ZBD_2E   := aArq[_x][8]
					ZBD->ZBD_2S   := aArq[_x][9]
					ZBD->ZBD_3E   := aArq[_x][10]
					ZBD->ZBD_3S   := aArq[_x][11]
					ZBD->ZBD_4E   := aArq[_x][12]
					ZBD->ZBD_4S   := aArq[_x][13]
					ZBD->ZBD_PROBLE:= aArq[_x][14]
					ZBD->ZBD_JUST  := aArq[_x][15]
					ZBD->ZBD_ORDEM := aArq[_x][24]
					ZBD->ZBD_SAPROV:= 'S'
					ZBD->ZBD_CODAPR:= __cUserID 
					ZBD->ZBD_DTAPRO:= date() 
					MsUnlock()
				endif	
			next
		endif
	endif
return

/*
Excluir ZBD ainda não aprovado
*/
static function ob_excZBD(_nAt)
	if aArq[_nAt][25] == "ZBD"
		If Msgyesno("Deseja excluir as correções da matrícula '"+aArq[_nAt][4] +"' do dia '"+dtoc(aArq[_nAt][2])+"'? ")	
			DbSelectArea('ZBD')
			DbSetOrder(1)	
			dbSeek(xFilial('ZBD')+ aArq[_nAt][4] + dtos(aArq[_nAt][2]),.T.)
			if found()
				aArq[_nAt][1] := 4
				RecLock("ZBD",.F.)
				dbDelete()
				MsUnlock()
			else
				aArq[_nAt][1] := 4	
			endif
		endif
	else
		MsgAlert("Não pode ser excluído pois não é correção.") 
	endif
return

/*-------------------------------------------------------------------------*
| Func:  _bAtul                                                            |
| Autor: Divair Zarpelon                                                   |
| Data:  25/01/2018                                                        |
| Desc:  Função que é executada toda vez que mudamos de linha  na listbox  |
| dos arquivos a serem processados                                         |
*------------------------------------------------------------------------*/
static function _bAtul()
	local bCod:= {|| {If(aArq[oListp:nAt,1]==1,oGreen,if(aArq[oListp:nAt,1]==2,oRed,if(aArq[oListp:nAt,1]==3,oYellow,oBlack))),;
	aArq[oListp:nAt,2],;
	aArq[oListp:nAt,3],;
	aArq[oListp:nAt,4],;
	aArq[oListp:nAt,5],;
	aArq[oListp:nAt,6],;
	aArq[oListp:nAt,7],;
	aArq[oListp:nAt,8],;
	aArq[oListp:nAt,9],;
	aArq[oListp:nAt,10],;
	aArq[oListp:nAt,11],;
	aArq[oListp:nAt,12],;
	aArq[oListp:nAt,13],;
	aArq[oListp:nAt,14],;
	aArq[oListp:nAt,15]}}

return bCod


static function corrige_ponto(_ind)
	nOpca := 2
	nInd := _ind

	//DEFINE MSDIALOG oDlg TITLE 'Ajuste marcacoes'  From 9,0 To 35,70 OF oMainWnd
	DEFINE MSDIALOG oDlg TITLE "Ajuste Marcações" From 9,0 To 440,450 pixel //OF oMainWnd  pixel

	populavar()

	@ 010 ,10 Say "Primeira entrada " 	FONT oDlg:oFont PIXEL Of oDlg
	@ 010 ,80 MSGET oP1Ent  var nP1Ent picture "@E 99.99" when (alHabCpo[nInd][1] .OR. alHabCpo[nInd][2])  size 060,010 VALID valDig('E1') OF oDlg   PIXEL
	@ 018, 110 BTNBMP oBtn1 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION  bDesloca('B','E1') oF oDlg

	@ 030 ,10 Say "Primeira saida" 	FONT oDlg:oFont PIXEL Of oDlg
	@ 030 ,80 MSGET oP1Said  var nP1Said when (alHabCpo[nInd][3] .OR. alHabCpo[nInd][4]) picture "@E 99.99"  size 060,010 VALID  valDig('S1') OF oDlg   PIXEL
	@ 058, 110 BTNBMP oBtn2 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION  bDesloca('B','S1') oF oDlg
	@ 058, 130 BTNBMP oBtn3 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION  bDesloca('C','S1') oF oDlg

	@ 050 ,10 Say "Segunda entrada " 	FONT oDlg:oFont PIXEL Of oDlg
	@ 050 ,80 MSGET oP2Ent  var nP2Ent when (alHabCpo[nInd][5] .OR. alHabCpo[nInd][6])  picture "@E 99.99" size 060,010 VALID  valDig('E2') OF oDlg   PIXEL
	@ 098, 110 BTNBMP oBtn4 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION  bDesloca('B','E2') oF oDlg
	@ 098, 130 BTNBMP oBtn5 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION  bDesloca('C','E2') oF oDlg

	@ 070 ,10 Say "Segunda saida" 	FONT oDlg:oFont PIXEL Of oDlg
	@ 070 ,80 MSGET oP2Said  var nP2Said when (alHabCpo[nInd][7] .OR. alHabCpo[nInd][8]) picture "@E 99.99"   size 060,010 VALID  valDig('S2') OF oDlg   PIXEL
	@ 138, 110 BTNBMP oBtn6 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION bDesloca('B','S2') oF oDlg
	@ 138, 130 BTNBMP oBtn7 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION bDesloca('C','S2') oF oDlg

	@ 090 ,10 Say "Terceira entrada " 	FONT oDlg:oFont PIXEL Of oDlg
	@ 090 ,80 MSGET oP3Ent  var nP3Ent when (alHabCpo[nInd][9] .OR. alHabCpo[nInd][10]) picture "@E 99.99"   size 060,010 VALID  valDig('E3') OF oDlg   PIXEL
	@ 178, 110 BTNBMP oBtn8 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION  bDesloca('B','E3') oF oDlg
	@ 178, 130 BTNBMP oBtn9 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION  bDesloca('C','E3') oF oDlg

	@ 110 ,10 Say "Terceira saida" 	FONT oDlg:oFont PIXEL Of oDlg
	@ 110 ,80 MSGET oP3Said  var nP3Said when (alHabCpo[nInd][11] .OR. alHabCpo[nInd][12]) picture "@E 99.99"  size 060,010 VALID  valDig('S3') OF oDlg   PIXEL
	@ 218, 110 BTNBMP oBtn10 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION  bDesloca('B','S3') oF oDlg
	@ 218, 130 BTNBMP oBtn11 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION  bDesloca('C','S3') oF oDlg

	@ 130 ,10 Say "Quarta entrada " 	FONT oDlgKco:oFont PIXEL Of oDlg
	@ 130 ,80 MSGET oP4Ent  var nP4Ent when (alHabCpo[nInd][13] .OR. alHabCpo[nInd][14]) picture "@E 99.99"   size 060,010 VALID  valDig('E4') OF oDlg   PIXEL
	@ 258, 110 BTNBMP oBtn12 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION  bDesloca('B','E4') oF oDlg
	@ 258, 130 BTNBMP oBtn13 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION  bDesloca('C','E4') oF oDlg

	@ 150 ,10 Say "Quarta saida" 	FONT oDlg:oFont PIXEL Of oDlg
	@ 150 ,80 MSGET oP4Said  var nP4Said when (alHabCpo[nInd][15] .OR. alHabCpo[nInd][16]) picture "@E 99.99"  size 060,010 valid valDig('S4') OF oDlg   PIXEL
	@ 298, 130 BTNBMP oBtn14 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION bDesloca('C','S4') oF oDlg

	@ 170 ,10 Say "Total de horas:" FONT oDlg:oFont PIXEL Of oDlg
	@ 170 ,50 Say TRANSFORM(fConvHr(_nHrTot, 'H') , "@E 99.99")  FONT oDlg:oFont PIXEL Of oDlg	

	@ 185 ,10 Say "Problema:" FONT oDlg:oFont PIXEL Of oDlg
	@ 185 ,50 Say cProblem   FONT oDlg:oFont PIXEL Of oDlg

	@ 200 ,10 Say "Justificativa" FONT oDlg:oFont PIXEL Of oDlg
	@ 200 ,50 MSGET oJust var cJust size 160,010 OF oDlg   PIXEL

	//verificar se precisa ficar essa linha do focus
	@ 010 ,189 MSGET oPz3Ent var nP3Ent  picture "@E 99.99"   size 005,002 OF oDlg   PIXEL
	oPz3Ent:setfocus()

	DEFINE SBUTTON FROM 10  ,190  TYPE 1 ACTION  bValInf() ENABLE OF oDlg
	DEFINE SBUTTON FROM 22.5,190  TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	if nOpca == 1

		aArq[nInd][1] := 3

		aArq[nInd][6] := nP1Ent
		aArq[nInd][7] := nP1Said

		aArq[nInd][8] := nP2Ent
		aArq[nInd][9] := nP2Said

		aArq[nInd][10] := nP3Ent
		aArq[nInd][11] := nP3Said

		aArq[nInd][12] := nP4Ent
		aArq[nInd][13] := nP4Said

		//aArq[nInd][12] := nP4Said
		aArq[nInd][14] := cProblem 
		aArq[nInd][15] := cJust 

		aArq[nInd][25] := "ZBD"

	else
		alHabCpo:=aclone(alHabB)
	endif

return

static function populavar()
	_nHrTot:= 0.00

	nP1Ent  := aArq[nInd][6]
	nP1Said := aArq[nInd][7]

	nP2Ent  := aArq[nInd][8]
	nP2Said := aArq[nInd][9]

	nP3Ent  := aArq[nInd][10]
	nP3Said := aArq[nInd][11]

	nP4Ent  := aArq[nInd][12]
	nP4Said := aArq[nInd][13]

	cProblem:= aArq[nInd][14]
	cJust   := aArq[nInd][15]

	alHabB  := aclone(alHabCpo)

	ob_calcHrs()	 
	/*
	Aadd(alHabCpo,{.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.})
	|   |   |   |   |   |   |   |   |   |   |   |   |   |   |  16 controle alteração quarta saida
	|   |   |   |   |   |   |   |   |   |   |   |   |   |  15 controle quarta saida  
	|   |   |   |   |   |   |   |   |   |   |   |   |  14 controle alteração quarta entrada
	|   |   |   |   |   |   |   |   |   |   |   |  13 controle quarta entrada  
	|   |   |   |   |   |   |   |   |   |   |  12 controle alteração terceira saida
	|   |   |   |   |   |   |   |   |   |  11 controle terceira saida  
	|   |   |   |   |   |   |   |   |  10 controle alteração terceira entrada
	|   |   |   |   |   |   |   |  09 controle terceira entrada  
	|   |   |   |   |   |   |  08 controle alteração segunda saida
	|   |   |   |   |   |  07 controle segunda saida  
	|   |   |   |   |  06 controle alteração segunda entrada
	|   |   |   |  05 controle segunda entrada  
	|   |   |  04 controle alteração primeira saida
	|   |  03 controle primeira saida  
	|  02 controle alteração primeira entrada
	01 controle primeira entrada    
	*/

return



static function valDig(cTip)
	local lRetv := .t.
	_nHrTot := 0.00

	Do Case
		Case cTip == 'E1'
		//alHabCpo[nInd][1] .OR. alHabCpo[nInd][2]   nP1Ent
		alHabCpo[nInd][2] := .T.

		Case cTip == 'S1'
		//alHabCpo[nInd][3] .OR. alHabCpo[nInd][4]  nP1Said
		alHabCpo[nInd][4] := .T.

		Case cTip == 'E2'
		//alHabCpo[nInd][5] .OR. alHabCpo[nInd][6]   nP2Ent
		alHabCpo[nInd][6] := .T.

		Case cTip == 'S2'
		//alHabCpo[nInd][7] .OR. alHabCpo[nInd][8]  nP2Said
		alHabCpo[nInd][8] := .T.

		Case cTip == 'E3'
		//alHabCpo[nInd][9] .OR. alHabCpo[nInd][10]  nP3Ent
		alHabCpo[nInd][10] := .T.

		Case cTip == 'S3'
		//alHabCpo[nInd][11] .OR. alHabCpo[nInd][12]  nP3Said
		alHabCpo[nInd][12] := .T.


		Case cTip == 'E4'
		//alHabCpo[nInd][13] .OR. alHabCpo[nInd][14]   nP4Ent
		alHabCpo[nInd][14] := .T.

		Case cTip == 'S4'
		//alHabCpo[nInd][15] .OR. alHabCpo[nInd][16]  nP4Said
		alHabCpo[nInd][16] := .T.

	EndCase

	lRetv := bvalDig()
	if !lRetv
		msgalert('Verifique o valor digitado ele deve estar entre <b>0.00</b> e <b>23.59</b> e o decimal nao pode ser superior a <b>0.59</b>..')
	else
		ob_calcHrs()		
	endif

return lRetv


static function bDesloca(cDir,cMarc)
	_nHrTot := 0.00
	oPz3Ent:setfocus()
	if cMarc == 'E1'
		if cDir == 'B' .and.  nP4Said == 0.00 .and. nP1Ent > 0
			nP4Said := nP4Ent
			nP4Ent  := nP3Said
			nP3Said := nP3Ent
			nP3Ent  := nP2Said
			nP2Said := nP2Ent
			nP2Ent  := nP1Said
			nP1Said := nP1Ent
			nP1Ent  := 0.00

			alHabCpo[nInd][15] := alHabCpo[nInd][13]
			alHabCpo[nInd][16] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := alHabCpo[nInd][11]
			alHabCpo[nInd][14] := alHabCpo[nInd][12]
			alHabCpo[nInd][11] := alHabCpo[nInd][09]
			alHabCpo[nInd][12] := alHabCpo[nInd][10]
			alHabCpo[nInd][9]  := alHabCpo[nInd][7]
			alHabCpo[nInd][10] := alHabCpo[nInd][8]
			alHabCpo[nInd][7]  := alHabCpo[nInd][5]
			alHabCpo[nInd][8]  := alHabCpo[nInd][6]
			alHabCpo[nInd][5]  := alHabCpo[nInd][3]
			alHabCpo[nInd][6]  := alHabCpo[nInd][4]
			alHabCpo[nInd][3]  := alHabCpo[nInd][1]
			alHabCpo[nInd][4]  := alHabCpo[nInd][2]
			alHabCpo[nInd][1]  := .t.
			alHabCpo[nInd][2]  := .t.
		endif
	endif

	if cMarc == 'S1'
		if cDir == 'B' .and.  nP4Said == 0.00 .and. nP1Said > 0
			nP4Said := nP4Ent
			nP4Ent  := nP3Said
			nP3Said := nP3Ent
			nP3Ent  := nP2Said
			nP2Said := nP2Ent
			nP2Ent  := nP1Said
			nP1Said := 0.00

			alHabCpo[nInd][15] := alHabCpo[nInd][13]
			alHabCpo[nInd][16] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := alHabCpo[nInd][11]
			alHabCpo[nInd][14] := alHabCpo[nInd][12]
			alHabCpo[nInd][11] := alHabCpo[nInd][09]
			alHabCpo[nInd][12] := alHabCpo[nInd][10]
			alHabCpo[nInd][9]  := alHabCpo[nInd][7]
			alHabCpo[nInd][10] := alHabCpo[nInd][8]
			alHabCpo[nInd][7]  := alHabCpo[nInd][5]
			alHabCpo[nInd][8]  := alHabCpo[nInd][6]
			alHabCpo[nInd][5]  := alHabCpo[nInd][3]
			alHabCpo[nInd][6]  := alHabCpo[nInd][4]
			alHabCpo[nInd][3]  := .T.
			alHabCpo[nInd][4]  := .T.
		endif

		if cDir == 'C' .and.  nP1Ent == 0.00 .and. nP1Said > 0
			nP1Ent  := nP1Said
			nP1Said := nP2Ent
			nP2Ent  := nP2Said
			nP2Said := nP3Ent
			nP3Ent  := nP3Said
			nP3Said := nP4Ent
			nP4Ent  := nP4Said
			nP4Said := 0.00

			alHabCpo[nInd][1] := alHabCpo[nInd][3]
			alHabCpo[nInd][2] := alHabCpo[nInd][4]
			alHabCpo[nInd][3] := alHabCpo[nInd][5]
			alHabCpo[nInd][4] := alHabCpo[nInd][6]
			alHabCpo[nInd][5] := alHabCpo[nInd][7]
			alHabCpo[nInd][6] := alHabCpo[nInd][8]
			alHabCpo[nInd][7] := alHabCpo[nInd][9]
			alHabCpo[nInd][8] := alHabCpo[nInd][10]
			alHabCpo[nInd][9] := alHabCpo[nInd][11]
			alHabCpo[nInd][10] := alHabCpo[nInd][12]
			alHabCpo[nInd][11] := alHabCpo[nInd][13]
			alHabCpo[nInd][12] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := alHabCpo[nInd][15]
			alHabCpo[nInd][14] := alHabCpo[nInd][16]
			alHabCpo[nInd][15] := .t.
			alHabCpo[nInd][16] := .t.
		endif
	endif

	if cMarc == 'E2'
		if cDir == 'B' .and.  nP4Said == 0.00 .and. nP2Ent > 0
			nP4Said := nP4Ent
			nP4Ent  := nP3Said
			nP3Said := nP3Ent
			nP3Ent  := nP2Said
			nP2Said := nP2Ent
			nP2Ent  := 0.00

			alHabCpo[nInd][15] := alHabCpo[nInd][13]
			alHabCpo[nInd][16] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := alHabCpo[nInd][11]
			alHabCpo[nInd][14] := alHabCpo[nInd][12]
			alHabCpo[nInd][11] := alHabCpo[nInd][09]
			alHabCpo[nInd][12] := alHabCpo[nInd][10]
			alHabCpo[nInd][9]  := alHabCpo[nInd][7]
			alHabCpo[nInd][10] := alHabCpo[nInd][8]
			alHabCpo[nInd][7]  := alHabCpo[nInd][5]
			alHabCpo[nInd][8]  := alHabCpo[nInd][6]
			alHabCpo[nInd][5]  := .t.
			alHabCpo[nInd][6]  := .t.
		endif

		if cDir == 'C' .and.  nP1Said == 0.00 .and. nP2Ent > 0
			nP1Said := nP2Ent
			nP2Ent  := nP2Said
			nP2Said := nP3Ent
			nP3Ent  := nP3Said
			nP3Said := nP4Ent
			nP4Ent  := nP4Said
			nP4Said := 0.00

			alHabCpo[nInd][3] := alHabCpo[nInd][5]
			alHabCpo[nInd][4] := alHabCpo[nInd][6]
			alHabCpo[nInd][5] := alHabCpo[nInd][7]
			alHabCpo[nInd][6] := alHabCpo[nInd][8]
			alHabCpo[nInd][7] := alHabCpo[nInd][9]
			alHabCpo[nInd][8] := alHabCpo[nInd][10]
			alHabCpo[nInd][9] := alHabCpo[nInd][11]
			alHabCpo[nInd][10] := alHabCpo[nInd][12]
			alHabCpo[nInd][11] := alHabCpo[nInd][13]
			alHabCpo[nInd][12] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := alHabCpo[nInd][15]
			alHabCpo[nInd][14] := alHabCpo[nInd][16]
			alHabCpo[nInd][15] := .t.
			alHabCpo[nInd][16] := .t.
		endif
	endif

	if cMarc == 'S2'
		if cDir == 'B' .and.  nP4Said == 0.00 .and. nP2Said > 0
			nP4Said := nP4Ent
			nP4Ent  := nP3Said
			nP3Said := nP3Ent
			nP3Ent  := nP2Said
			nP2Said := 0.00

			alHabCpo[nInd][15] := alHabCpo[nInd][13]
			alHabCpo[nInd][16] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := alHabCpo[nInd][11]
			alHabCpo[nInd][14] := alHabCpo[nInd][12]
			alHabCpo[nInd][11] := alHabCpo[nInd][09]
			alHabCpo[nInd][12] := alHabCpo[nInd][10]
			alHabCpo[nInd][9]  := alHabCpo[nInd][7]
			alHabCpo[nInd][10] := alHabCpo[nInd][8]
			alHabCpo[nInd][7]  := .T.
			alHabCpo[nInd][8]  := .T.
		endif

		if cDir == 'C' .and.  nP2Ent == 0.00 .and. nP2Said > 0
			nP2Ent  := nP2Said
			nP2Said := nP3Ent
			nP3Ent  := nP3Said
			nP3Said := nP4Ent
			nP4Ent  := nP4Said
			nP4Said := 0.00

			alHabCpo[nInd][5] := alHabCpo[nInd][7]
			alHabCpo[nInd][6] := alHabCpo[nInd][8]
			alHabCpo[nInd][7] := alHabCpo[nInd][9]
			alHabCpo[nInd][8] := alHabCpo[nInd][10]
			alHabCpo[nInd][9] := alHabCpo[nInd][11]
			alHabCpo[nInd][10] := alHabCpo[nInd][12]
			alHabCpo[nInd][11] := alHabCpo[nInd][13]
			alHabCpo[nInd][12] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := alHabCpo[nInd][15]
			alHabCpo[nInd][14] := alHabCpo[nInd][16]
			alHabCpo[nInd][15] := .t.
			alHabCpo[nInd][16] := .t.
		endif
	endif


	if cMarc == 'E3'
		if cDir == 'B' .and.  nP4Said == 0.00 .and. nP3Ent > 0
			nP4Said := nP4Ent
			nP4Ent  := nP3Said
			nP3Said := nP3Ent
			nP3Ent  := 0.00

			alHabCpo[nInd][15] := alHabCpo[nInd][13]
			alHabCpo[nInd][16] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := alHabCpo[nInd][11]
			alHabCpo[nInd][14] := alHabCpo[nInd][12]
			alHabCpo[nInd][11] := alHabCpo[nInd][09]
			alHabCpo[nInd][12] := alHabCpo[nInd][10]
			alHabCpo[nInd][9]  := .t.
			alHabCpo[nInd][10] := .t.
		endif

		if cDir == 'C' .and.  nP2Said == 0.00 .and. nP3Ent > 0
			nP2Said := nP3Ent
			nP3Ent  := nP3Said
			nP3Said := nP4Ent
			nP4Ent  := nP4Said
			nP4Said := 0.00

			alHabCpo[nInd][7] := alHabCpo[nInd][9]
			alHabCpo[nInd][8] := alHabCpo[nInd][10]
			alHabCpo[nInd][9] := alHabCpo[nInd][11]
			alHabCpo[nInd][10] := alHabCpo[nInd][12]
			alHabCpo[nInd][11] := alHabCpo[nInd][13]
			alHabCpo[nInd][12] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := alHabCpo[nInd][15]
			alHabCpo[nInd][14] := alHabCpo[nInd][16]
			alHabCpo[nInd][15] := .t.
			alHabCpo[nInd][16] := .t.
		endif

	endif

	if cMarc == 'S3'
		if cDir == 'B' .and.  nP4Said == 0.00 .and. nP3Said > 0
			nP4Said := nP4Ent
			nP4Ent  := nP3Said
			nP3Said := 0.00

			alHabCpo[nInd][15] := alHabCpo[nInd][13]
			alHabCpo[nInd][16] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := alHabCpo[nInd][11]
			alHabCpo[nInd][14] := alHabCpo[nInd][12]
			alHabCpo[nInd][11] := .T.
			alHabCpo[nInd][12] := .T.
		endif

		if cDir == 'C' .and.  nP3Ent == 0.00 .and. nP3Said > 0
			nP3Ent  := nP3Said
			nP3Said := nP4Ent
			nP4Ent  := nP4Said
			nP4Said := 0.00

			alHabCpo[nInd][9] := alHabCpo[nInd][11]
			alHabCpo[nInd][10] := alHabCpo[nInd][12]
			alHabCpo[nInd][11] := alHabCpo[nInd][13]
			alHabCpo[nInd][12] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := alHabCpo[nInd][15]
			alHabCpo[nInd][14] := alHabCpo[nInd][16]
			alHabCpo[nInd][15] := .t.
			alHabCpo[nInd][16] := .t.
		endif
	endif

	if cMarc == 'E4'
		if cDir == 'B' .and.  nP4Said == 0.00 .and. nP4Ent > 0
			nP4Said := nP4Ent
			nP4Ent  := 0.00
			alHabCpo[nInd][15] := alHabCpo[nInd][13]
			alHabCpo[nInd][16] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := .t.
			alHabCpo[nInd][14] := .t.
		Endif

		if cDir == 'C' .and.  nP3Said == 0.00 .and. nP4Ent > 0
			nP3Said := nP4Ent
			nP4Ent  := nP4Said
			nP4Said := 0.00

			alHabCpo[nInd][11] := alHabCpo[nInd][13]
			alHabCpo[nInd][12] := alHabCpo[nInd][14]
			alHabCpo[nInd][13] := alHabCpo[nInd][15]
			alHabCpo[nInd][14] := alHabCpo[nInd][16]
			alHabCpo[nInd][15] := .t.
			alHabCpo[nInd][16] := .t.
		endif
	endif

	if cMarc == 'S4'
		if cDir == 'C' .and.  nP3Said == 0.00 .and. nP4Ent > 0
			nP3Said := nP4Ent
			nP4Ent  := nP4Said
			nP4Said := 0.00

			alHabCpo[nInd][13] := alHabCpo[nInd][15]
			alHabCpo[nInd][14] := alHabCpo[nInd][16]
			alHabCpo[nInd][15] := .t.
			alHabCpo[nInd][16] := .t.
		endif
	Endif

	ob_calcHrs()	 

	oP1Ent:Refresh()
	oP2Ent:Refresh()
	oP3Ent:refresh()
	oP4Ent:Refresh()
	oP1Said:Refresh()
	oP2Said:Refresh()
	oP3Said:Refresh()
	oP4Said:Refresh()

return



static function bValInf()

	local _n := 0
	local lret := .f.

	//verifica a quantidade de marcacoes
	_n := nNumMarc()
	if Mod(_n, 2) == 0
		lret := .t.
	else
		msgalert('Numero de marcações <b>('+cvaltochar(_n)+')</b> invalido...','Atenção')
	endif

	//verifica se nao existem quantidades zeradas entre valores
	if lret
		lret:= bInter()
		if !lret
			msgalert('Existem intervalos zerados entre marcações...','Atenção')
		endif
	endif

	if lret
		nOpca := 1
		oDlg:End()
	endif

return


static function nNumMarc()
	local _n := 0
	if nP1Ent >0
		_n += 1
	endif

	if nP1Said >0
		_n += 1
	endif

	if nP2Ent >0
		_n += 1
	endif

	if nP2Said >0
		_n += 1
	endif

	if nP3Ent >0
		_n += 1
	endif

	if nP3Said >0
		_n += 1
	endif

	if nP4Ent >0
		_n += 1
	endif

	if nP4Ent >0
		_n += 1
	endif

	if nP4Said >0
		_n += 1
	endif
return _n

static function bvalDig()
	local lRetD := .t.

	if nP1Ent > 23.59 .or. nP1Ent < 0.00 .or. (nP1Ent - int(nP1Ent) > 0.59)
		lRetD := .f.
	endif

	if nP1Said > 23.59 .or. nP1Said < 0.00 .or. (nP1Said - int(nP1Said) > 0.59)
		lRetD := .f.
	endif

	if nP2Ent > 23.59 .or. nP2Ent < 0.00 .or. (nP2Ent - int(nP2Ent) > 0.59)
		lRetD := .f.
	endif

	if nP2Said > 23.59 .or. nP2Said < 0.00 .or. (nP2Said - int(nP2Said) > 0.59)
		lRetD := .f.
	endif

	if nP3Ent > 23.59 .or. nP3Ent < 0.00 .or. (nP3Ent - int(nP3Ent) > 0.59)
		lRetD := .f.
	endif

	if nP3Said > 23.59 .or. nP3Said < 0.00 .or. (nP3Said - int(nP3Said) > 0.59)
		lRetD := .f.
	endif

	if nP4Ent > 23.59 .or. nP4Ent < 0.00 .or. (nP4Ent - int(nP4Ent) > 0.59)
		lRetD := .f.
	endif

	if nP4Said > 23.59 .or. nP4Said < 0.00 .or. (nP4Said - int(nP4Said) > 0.59)
		lRetD := .f.
	endif

return (lRetD)


static function bInter()
	local lRetI := .t.

	if nP1Ent == 0 .and. (nP1Said > 0 .or. nP2Ent > 0 .or. nP2Said > 0 .or. nP3Ent > 0  .or. nP3Said > 0 .or. nP4Ent > 0 .or. nP4Said >0)
		lRetI := .f.
	endif

	if nP1Said == 0 .and. (nP2Ent > 0 .or. nP2Said > 0 .or. nP3Ent > 0  .or. nP3Said > 0 .or. nP4Ent > 0 .or. nP4Said >0)
		lRetI := .f.
	endif

	if nP2Ent == 0 .and. (nP2Said > 0 .or. nP3Ent > 0  .or. nP3Said > 0 .or. nP4Ent > 0 .or. nP4Said >0)
		lRetI := .f.
	endif

	if nP2Said == 0 .and. (nP3Ent > 0  .or. nP3Said > 0 .or. nP4Ent > 0 .or. nP4Said >0)
		lRetI := .f.
	endif

	if nP3Ent == 0 .and. (nP3Said > 0 .or. nP4Ent > 0 .or. nP4Said >0)
		lRetI := .f.
	endif

	if nP3Said == 0 .and. (nP4Ent > 0 .or. nP4Said >0)
		lRetI := .f.
	endif

	if nP4Ent == 0 .and. (nP4Said >0)
		lRetI := .f.
	endif

return lRetI

static function bQuantMarc(ZBD1E,ZBD1S,ZBD2E,ZBD2S,ZBD3E,ZBD3S,ZBD4E,ZBD4S)
	local _nMar := 0

	if ZBD1E > 0
		_nMar+=1
	endif

	if ZBD1S > 0
		_nMar+=1
	endif

	if ZBD2E > 0
		_nMar+=1
	endif

	if ZBD2S > 0
		_nMar+=1
	endif

	if ZBD3E > 0
		_nMar+=1
	endif

	if ZBD3S > 0
		_nMar+=1
	endif

	if ZBD4E > 0
		_nMar+=1
	endif

	if ZBD4S > 0
		_nMar+=1
	endif

return(_nMar)



Static Function ValidPerg()
	Local i
	Local j
	cAlias := Alias()
	aRegs  :={}

	AADD(aRegs,{cPerg,"01","Data de         ?","Data de            ?","Data de           ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Data ate        ?","Data Ate           ?","Data ate          ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Lider           ?","Lider              ?","Lider             ?","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
	AADD(aRegs,{cPerg,"04","Centro de custo ?","Centro de custo    ?","Centro de custo   ?","mv_ch4","C",09,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CTT",""})
	AADD(aRegs,{cPerg,"05","Matrícula       ?","Matrícula          ?","Matrícula         ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SRA",""})

	DbSelectArea("SX1")
	DbSetOrder(1)
	For i:=1 to Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j<=Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	DbSelectArea(cAlias)
Return


static function retMP()
	Local _x1
	Local _x2
	Local _x3
	Local _x4
	Local _x5
	Local _x6
	Local _nx
	Private _aMarcacoes	:= {}
	Private _aTabCalend  := {}
	Private _aTabPadrao  := {}
	Private _aRecsMarcAutDele	:= {}
	Private _aBatNorm := {}
	Private _aBatMarc := {}
	Private _aProblems:= {}
	Private _aMarc:= {}
	Private dPerIni := MV_PAR01
	Private dPerFim := MV_PAR02

	_cQuery := " SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_TNOTRAB, RA_SEQTURN, RA_CC, RA_ADMISSA "
	_cQuery += " FROM " + RETSQLNAME ("SRA") +" AS SRA "
	_cQuery += " WHERE SRA.D_E_L_E_T_ = '' AND RA_DEMISSA = '' AND RA_FILIAL = '"+cFilAnt+ "' "
	_cQuery += " AND RA_MAT < '900000' AND RA_TNOTRAB <> '999' AND RA_TNOTRAB <> '998'" //AND RA_TPJORNA <> '2' AND RA_TPJORNA <> '3' "
	//_cQuery += " AND RA_MAT  = '014434' "
	if !empty(MV_PAR03)
		_cQuery += " AND (RA_LIDER = '"+MV_PAR03+"' or RA_LIDER2 = '"+MV_PAR03+"' )"
	endif	
	if !empty(MV_PAR04)
		_cQuery += " AND RA_CC  = '"+MV_PAR04+"' "
	ENDIF
	if !empty(MV_PAR05)
		_cQuery += " AND RA_MAT = '"+MV_PAR05+"' "
	endif
	_cQuery += " ORDER BY RA_FILIAL, RA_MAT "

	tcquery _cQuery new alias _trba
	do while ! _trba -> (eof ())
		_aMarcacoes := {}
		_aTabCalend := {}
		_aTabPadrao:= {}
		
		dbSelectArea("SRA")
		DbGoTop()			
		DbSeek(_trba->RA_FILIAL+_trba->RA_MAT)

		IF GetMarcacoes(	@_aMarcacoes			,;	//01 -> Marcacoes dos Funcionarios
		@_aTabCalend			,;	//02 -> Calendario de Marcacoes
		@_aTabPadrao			,;	//03 -> Tabela Padrao
		NIL     	,;	//04 -> Turnos de Trabalho
		_dDPIni 	,;	//05 -> Periodo Inicial
		_dDPFim	    ,;	//06 -> Periodo Final
		_trba->RA_FILIAL	,;	//07 -> Filial
		_trba->RA_MAT		,;	//08 -> Matricula
		_trba->RA_TNOTRAB	,;	//09 -> Turno
		_trba->RA_SEQTURN	,;	//10 -> Sequencia de Turno
		_trba->RA_CC			,;	//11 -> Centro de Custo
		/*cAlias*/			,;	//12 -> Alias para Carga das Marcacoes
		.T.					,;	//13 -> Se carrega Recno em aMarcacoes
		.T.		 			,;	//14 -> Se considera Apenas Ordenadas
		NIL					,;  //15 -> Verifica as Folgas Automaticas
		NIL  				,;  //16 -> Se Grava Evento de Folga Mes Anterior
		NIL					,;	//17 -> Se Carrega as Marcacoes Automaticas
		@_aRecsMarcAutDele	 ;	//18 -> Registros de Marcacoes Automaticas que deverao ser Deletados
		)
			//u_showarray(_aTabCalend)
			//u_showarray(_aMarcacoes)
			_aBatNorm := {}
			_cOrdemI := _aTabCalend[ascan(_aTabCalend, {|x|x[1] == dPerIni})][2]
			_cOrdemF := _aTabCalend[ascan(_aTabCalend, {|x|x[1] == dPerFim})][2]

			for _x1:= 1 to len(_aTabCalend)
				if _aTabCalend[_x1][6] == "S"; //dia normal
				.and. empty(_aTabCalend[_x1][25]); //afastamento
				.and. _aTabCalend[_x1][2] >= _cOrdemI;			
				.and. _aTabCalend[_x1][2] <= _cOrdemF;						
				.and. _aTabCalend[_x1][1] >= STOD(_trba->RA_ADMISSA)

					//monto array com quantidade batidas no dia normal
					//_nLocal := ascan(_aBatNorm, {|x|x[1] == _aTabCalend[_x1][2]})
					_nLocal := ascan(_aBatNorm, {|x|x[1] == _aTabCalend[_x1][2]})
					if _nLocal == 0
						AAdd( _aBatNorm, { _aTabCalend[_x1][2], 1 } )
					else
						_aBatNorm[_nLocal][2] := _aBatNorm[_nLocal][2] + 1
					endif

				endif
			next _x1
			//u_showarray(_aBatNorm)
			_aBatMarc := {}
			for _x2:= 1 to len(_aMarcacoes)
				if _aMarcacoes[_x2][3] >= _cOrdemI .and. _aMarcacoes[_x2][3] <= _cOrdemF
					//monto array com quantidade batidas no dia normal
					_nLocal := ascan(_aBatMarc, {|x|x[1] == _aMarcacoes[_x2][3]})
					if _nLocal == 0
						AAdd( _aBatMarc, { _aMarcacoes[_x2][3], 1 } )
					else
						_aBatMarc[_nLocal][2] := _aBatMarc[_nLocal][2] + 1
					endif

				endif
			next _x2
			//u_showarray(_aBatMarc)
			_aProblems := {}
			for _x3:= 1 to len(_aBatNorm)
				_nLocal := ascan(_aBatMarc, {|x|x[1] == _aBatNorm[_x3][1]})
				if _nLocal == 0
					aadd(_aProblems, { _aBatNorm[_x3][1], "Sem marcações, deveriam ter ";
					+TRANSFORM(_aBatNorm[_x3][2],'9')+" marcações nesse dia." } )
				elseif _aBatMarc[_nLocal][2] < _aBatNorm[_x3][2]
					aadd(_aProblems, { _aBatNorm[_x3][1], "Menos marcações que padrão, deveriam ter " ;
					+TRANSFORM(_aBatNorm[_x3][2],'9')+" marcações nesse dia." } )
				endif
			next _x3

			for _x4:= 1 to len(_aBatMarc)
				if mod(_aBatMarc[_x4][2],2) > 0 .and. ascan(_aProblems, {|x|x[1] == _aBatMarc[_x4][1]}) == 0
					aadd(_aProblems, { _aBatMarc[_x4][1], "Marcações ímpares"} )
				endif
			next _x4

			for _x5:=1 to len(_aProblems)
				_nLocal := ascan(_aTabCalend, {|x|x[2] == _aProblems[_x5][1]})
				_aMarc:= {}

				//se não tiver abono nesse dia
				if !_lTemAbono(_aTabCalend[_nLocal][1], _trba->RA_MAT) .and.;
				!_lTemCodInf(_aTabCalend[_nLocal][1], _trba->RA_MAT) .and.;
				!_lTemCodInf(_aTabCalend[_nLocal][1], _trba->RA_MAT) 						

					for _x6:=1 to len(_aMarcacoes)
						if 	_aMarcacoes[_x6][3] == _aProblems[_x5][1]
							aadd(_aMarc, { _aMarcacoes[_x6][2], _aMarcacoes[_x6][4], _aMarcacoes[_x6][3] })
						endif
					next _x6

					//u_showarray(_aMarc)
					DbSelectArea('ZBD')
					DbSetOrder(1)
					dbSeek(xFilial('ZBD')+ _trba->RA_MAT + DTOS(_aTabCalend[_nLocal][1]),.T.)
					if found() .AND. empty(ZBD->ZBD_SIMPOR) .AND. ZBD->ZBD_FILFUN == cFilAnt
						Aadd(aArq,{3,_aTabCalend[_nLocal][1], DiaSemana( _aTabCalend[_nLocal][1], 3 ), _trba->RA_MAT,_trba->RA_NOME,;
						ZBD->ZBD_1E,; //5
						ZBD->ZBD_1S,;
						ZBD->ZBD_2E,;
						ZBD->ZBD_2S,;
						ZBD->ZBD_3E,;
						ZBD->ZBD_3S,;//10
						ZBD->ZBD_4E,;
						ZBD->ZBD_4S,;
						ZBD->ZBD_PROBLE,;
						ZBD->ZBD_JUST,;
						"E",;//15
						"E",;
						"E",;
						"E",;
						"E",;
						"E",;//20
						"E",;
						"E",;
						ZBD->ZBD_ORDEM,;
						'ZBD',;					
						})					
					else					
						Aadd(aArq,{2,_aTabCalend[_nLocal][1],  DiaSemana( _aTabCalend[_nLocal][1] , 3 ), _trba->RA_MAT,_trba->RA_NOME,;
						iif(len(_aMarc)>0, _aMarc[1][1], 0),; //5
						iif(len(_aMarc)>1, _aMarc[2][1], 0),;
						iif(len(_aMarc)>2, _aMarc[3][1], 0),;
						iif(len(_aMarc)>3, _aMarc[4][1], 0),;
						iif(len(_aMarc)>4, _aMarc[5][1], 0),;
						iif(len(_aMarc)>5, _aMarc[6][1], 0),;//10
						iif(len(_aMarc)>6, _aMarc[7][1], 0),;
						iif(len(_aMarc)>7, _aMarc[8][1], 0),;
						_aProblems[_x5][2],;
						space(50),;
						iif(len(_aMarc)>0, _aMarc[1][2], "I"),;//15
						iif(len(_aMarc)>1, _aMarc[2][2], "I"),;
						iif(len(_aMarc)>2, _aMarc[3][2], "I"),;
						iif(len(_aMarc)>3, _aMarc[4][2], "I"),;
						iif(len(_aMarc)>4, _aMarc[5][2], "I"),;
						iif(len(_aMarc)>5, _aMarc[6][2], "I"),;//20
						iif(len(_aMarc)>6, _aMarc[7][2], "I"),;
						iif(len(_aMarc)>7, _aMarc[8][2], "I"),;
						_aTabCalend[_nLocal][2],;
						'SP8',;					
						})
					endif
				endif					
			next _x5
		endif

		dbSelectArea("_trba")
		dbSkip()
	enddo
	dbSelectArea("_trba")
	_trba->(DbCloseArea())


	for _nx:= 1 to len(aArq)
		//array que vai habilitar ou nao o campo de edição dos GETS, se as marcações tiveram conteudo eu seto .f.
		//O .f. seguinte serve para setar .t. quando eu digitar um conteudo em um campo que nao tiver conteudo
		Aadd(alHabCpo,{iif(aArq[_nx][ 6]>0, .f., .t.),iif(aArq[_nx][ 16] == 'E', .f., .t.),;
		iif(aArq[_nx][ 7]>0, .f., .t.),iif(aArq[_nx][ 17] == 'E', .f., .t.),;
		iif(aArq[_nx][ 8]>0, .f., .t.),iif(aArq[_nx][ 18] == 'E', .f., .t.),;
		iif(aArq[_nx][ 9]>0, .f., .t.),iif(aArq[_nx][ 19] == 'E', .f., .t.),;
		iif(aArq[_nx][10]>0, .f., .t.),iif(aArq[_nx][ 20] == 'E', .f., .t.),;
		iif(aArq[_nx][11]>0, .f., .t.),iif(aArq[_nx][ 21] == 'E', .f., .t.),;
		iif(aArq[_nx][12]>0, .f., .t.),iif(aArq[_nx][ 22] == 'E', .f., .t.),;
		iif(aArq[_nx][13]>0, .f., .t.),iif(aArq[_nx][ 23] == 'E', .f., .t.)})
	next _nx	

return


/*
Verifica se evento foi abonado, se tiver ignora o dia
*/
static function _lTemAbono(_dData1, _cMat)
	Local _cQuery := ""
	Local _nCount := 0
	_cQuery := " SELECT COUNT(*) AS CONT "
	_cQuery += " FROM " + RETSQLNAME ("SPK") +" AS SPK  "
	_cQuery += " WHERE SPK.D_E_L_E_T_ = '' AND PK_MAT = '"+_cMat+"' AND PK_FILIAL = '"+cFilAnt+"' "
	_cQuery += " AND PK_DATA = '"+dtos(_dData1)+"' " //"AND PK_CODEVE = '"+_cPdAb+"' "

	tcquery _cQuery new alias _trbb

	do while !_trbb->(eof())
		_nCount := _trbb->CONT
		dbSelectArea("_trbb")
		dbSkip()
	enddo
	dbSelectArea("_trbb")
	_trbb->(DbCloseArea())

return(_nCount > 0)


/*
Verifica se tem codigo informado nos abonos, se tiver ignora o dia
*/
static function _lTemCodInf(_dData1, _cMat)
	Local _cQuery := ""
	Local _nCount := 0
	_cQuery := " SELECT COUNT(*) AS CONT "
	_cQuery += " FROM " + RETSQLNAME ("SPC") +" AS SPC  "
	_cQuery += " WHERE SPC.D_E_L_E_T_ = '' AND PC_MAT = '"+_cMat+"' AND PC_FILIAL = '"+cFilAnt+"' "
	_cQuery += " AND PC_DATA = '"+dtos(_dData1)+"' AND PC_PDI <> '' " //"AND PK_CODEVE = '"+_cPdAb+"' "

	tcquery _cQuery new alias _trbb

	do while !_trbb->(eof())
		_nCount := _trbb->CONT
		dbSelectArea("_trbb")
		dbSkip()
	enddo
	dbSelectArea("_trbb")
	_trbb->(DbCloseArea())

return(_nCount > 0)

/*
Verifica se tem eventos de compensação gerados, se tiver ignora o dia
*/
static function _lTemComp(_dData1, _cMat)
	Local _cQuery := ""
	Local _nCount := 0
	_cQuery := " SELECT COUNT(*) AS CONT "
	_cQuery += " FROM " + RETSQLNAME ("SPC") +" AS SPC  "
	_cQuery += " WHERE SPC.D_E_L_E_T_ = '' AND PC_MAT = '"+_cMat+"' AND PC_FILIAL = '"+cFilAnt+"' "
	_cQuery += " AND PC_DATA = '"+dtos(_dData1)+"' AND ( PC_PD = '"+_cPdCpFalta+"' OR PC_PD = '"+_cPdAcordo+"' OR PC_PD = '"+_cPdCpAtest+"') "

	tcquery _cQuery new alias _trbb

	do while !_trbb->(eof())
		_nCount := _trbb->CONT
		dbSelectArea("_trbb")
		dbSkip()
	enddo
	dbSelectArea("_trbb")
	_trbb->(DbCloseArea())

return(_nCount > 0)

static function ob_calcHrs ()
	if nP1Said > 0 .and. nP1Ent > 0
		if nP1Ent > nP1Said
			_nHrTot += 24-fConvHr(nP1Ent, 'D') + fConvHr(nP1Said, 'D')
		else
			_nHrTot += fConvHr(nP1Said, 'D') - fConvHr(nP1Ent, 'D')
		endif	
	endif
	if nP2Said > 0 .and. nP2Ent > 0
		if nP2Ent > nP2Said
			_nHrTot += 24-fConvHr(nP2Ent, 'D') + fConvHr(nP2Said, 'D')
		else
			_nHrTot += fConvHr(nP2Said, 'D') - fConvHr(nP2Ent, 'D')
		endif	
	endif	
	if nP3Said > 0 .and. nP3Ent > 0
		if nP3Ent > nP3Said
			_nHrTot += 24-fConvHr(nP3Ent, 'D') + fConvHr(nP3Said, 'D')
		else
			_nHrTot += fConvHr(nP3Said, 'D') - fConvHr(nP3Ent, 'D')
		endif	
	endif
	if nP4Said > 0 .and. nP4Ent > 0
		if nP4Ent > nP4Said
			_nHrTot += 24-fConvHr(nP4Ent, 'D') + fConvHr(nP4Said, 'D')
		else
			_nHrTot += fConvHr(nP4Said, 'D') - fConvHr(nP4Ent, 'D')
		endif	
	endif
return




/*
#INCLUDE 'protheus.ch'
#INCLUDE "TOPCONN.CH"

user function ob_CPonLid()
private nValor := 0.00
Private aArq := {}
Private alHabCpo := {}
private alHabB := {}
private cJust  := space(50)
private cProblem := space(50)
private oP1Ent,oP2Ent,oP3Ent,oP4Ent,oP1Said,oP2Said,oP3Said,oP4Said,oJust
private nP1Ent,nP2Ent,nP3Ent,nP4Ent,nP1Said,nP2Said,nP3Said,nP4Said, _nHrTot := 00.00
private nInd := 0
private oBtnE1B,oBtnE2B,oBtnE21C,oBtnE3B,oBtnE3C,oBtnE4C
private oDlg
private nOpca,nOp
Private _nMarc
Private cCadastro := "Inconsistências ponto eletrônico"

private cPerPo:= Alltrim(GetMv("MV_PONMES"))
private _dDPIni := stod(left(cPerPo,8))
private _dDPFim := stod(right(cPerPo,8))

DEFINE FONT oFnt NAME "Arial" SIZE 12,14 BOLD

private oGreen   := LoadBitmap( GetResources(), "BR_VERDE")
private oRed     := LoadBitmap( GetResources(), "BR_VERMELHO")
private oBlack   := LoadBitmap( GetResources(), "BR_PRETO")
private oYellow  := LoadBitmap( GetResources(), "BR_AMARELO")

if !SM0->M0_CODIGO $ "01"
MsgAlert("Rotina não disponível para essa empresa.")
return
endif

cPerg :=  "OBCPONLID"
ValidPerg()
MV_PAR03 := RetCodUsr()

// faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize(,.F.,370)
aObjects := {}
aVisual := {}
AAdd( aObjects, { 015, 200 , .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
if Pergunte(cPerg,.T.)
if MV_PAR01 < _dDPIni .or. MV_PAR02>_dDPFim  
MsgAlert("Datas não podem estar fora do período do ponto que é de '"+dtoc(_dDPIni)+"' a '"+dtoc(_dDPFim)+"' ")
return()
endif
retMP()

if len(aArq) > 0

aArq := aSort(aArq,,,{|x,y| x[3]+dtos(x[2]) < y[3]+dtos(y[2])})

DEFINE MSDIALOG oDlgKco TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] pixel //OF oMainWnd  pixel

@ 032, 005 Say "Intervalo de datas" FONT oDlgKco:oFont PIXEL Of oDlgKco
@ 032, 060 Say dtoc(mv_par01)+ ' a '+dtoc(mv_par02) Picture "@!" FONT oFnt COLOR CLR_HBLUE	PIXEL Of oDlgKco

@ 045, 005 LISTBOX oListp FIELDS HEADER '','Data','Matricula','Nome', '1E','1S','2E','2S','3E','3S','4E','4S','Problema','Justificativa' FIELDSIZES 100 SIZE (oDlgKco:nClientWidth / 2) - 20  , (oDlgKco:nClientHeight / 2) - 50  SCROLL OF oDlgKco PIXEL

oListp:SetArray(aArq)
oListp:bLine:= _bAtul()
oListp:bLDblClick := {|| corrige_ponto(oListp:nAt),oListp:SetArray(aArq),oListp:bLine:=_bAtul(),oListp:Refresh()}

aButtons := {}
AADD(aButtons,{"S4WB009N", {|| corrige_ponto(oListp:nAt),oListp:SetArray(aArq),oListp:bLine:=_bAtul(),oListp:Refresh()},'Corrigir'})
Aadd(aButtons,{"HISTORIC", {|| ob_excZBD(oListp:nAt),oListp:SetArray(aArq),oListp:bLine:=_bAtul(),oListp:Refresh()}, "Excluir...", "Excluir" , {|| .T.}} )

ACTIVATE MSDIALOG oDlgKco CENTERED ON INIT EnchoiceBar(oDlgKco,{|| nOp:=1, oDlgKco:End()},	{|| nOp:= 2, oDlgKco:End()},,aButtons)

else
MsgAlert("Sem inconsistências")
endif

if nOp == 1
DbSelectArea('ZBD')
DbSetOrder(1)
for _x:= 1 to len(aArq)
if  aArq[_x][24] == "ZBD" .and. aArq[_x][1] == 3
//u_showarray(aArq[_x])
dbSeek(xFilial('ZBD')+ aArq[_x][3] + DTOS(aArq[_x][2]),.T.)
if found()
RecLock("ZBD",.F.)
else
RecLock("ZBD",.T.)
endif
ZBD->ZBD_FILFUN:= cFilAnt
ZBD->ZBD_DATA := aArq[_x][2]
ZBD->ZBD_MAT  := aArq[_x][3]	
ZBD->ZBD_1E   := aArq[_x][5] 
ZBD->ZBD_1S   := aArq[_x][6]
ZBD->ZBD_2E   := aArq[_x][7]
ZBD->ZBD_2S   := aArq[_x][8]
ZBD->ZBD_3E   := aArq[_x][9]
ZBD->ZBD_3S   := aArq[_x][10]
ZBD->ZBD_4E   := aArq[_x][11]
ZBD->ZBD_4S   := aArq[_x][12]
ZBD->ZBD_PROBLE:= aArq[_x][13]
ZBD->ZBD_JUST  := aArq[_x][14]
ZBD->ZBD_ORDEM := aArq[_x][23]
ZBD->ZBD_SAPROV:= 'S'
ZBD->ZBD_CODAPR:= RetCodUsr() 
ZBD->ZBD_DTAPRO:= date() 
MsUnlock()
endif	
next
endif
endif
return

//Excluir ZBD ainda não aprovado
static function ob_excZBD(_nAt)
if aArq[_nAt][24] == "ZBD"
If Msgyesno("Deseja excluir as correções da matrícula '"+aArq[_nAt][3] +"' do dia '"+dtoc(aArq[_nAt][2])+"'? ")	
DbSelectArea('ZBD')
DbSetOrder(1)	
dbSeek(xFilial('ZBD')+ aArq[_nAt][3] + dtos(aArq[_nAt][2]),.T.)
if found()
aArq[_nAt][1] := 4
RecLock("ZBD",.F.)
dbDelete()
MsUnlock()
else
aArq[_nAt][1] := 4	
endif
endif
else
MsgAlert("Não pode ser excluído pois não é correção.") 
endif
return

static function _bAtul()
local bCod:= {|| {If(aArq[oListp:nAt,1]==1,oGreen,if(aArq[oListp:nAt,1]==2,oRed,if(aArq[oListp:nAt,1]==3,oYellow,oBlack))),;
aArq[oListp:nAt,2],;
aArq[oListp:nAt,3],;
aArq[oListp:nAt,4],;
aArq[oListp:nAt,5],;
aArq[oListp:nAt,6],;
aArq[oListp:nAt,7],;
aArq[oListp:nAt,8],;
aArq[oListp:nAt,9],;
aArq[oListp:nAt,10],;
aArq[oListp:nAt,11],;
aArq[oListp:nAt,12],;
aArq[oListp:nAt,13],;
aArq[oListp:nAt,14]}}

return bCod


static function corrige_ponto(_ind)
nOpca := 2
nInd := _ind

//DEFINE MSDIALOG oDlg TITLE 'Ajuste marcacoes'  From 9,0 To 35,70 OF oMainWnd
DEFINE MSDIALOG oDlg TITLE "Ajuste Marcações" From 9,0 To 440,450 pixel //OF oMainWnd  pixel

populavar()

@ 010 ,10 Say "Primeira entrada " 	FONT oDlg:oFont PIXEL Of oDlg
@ 010 ,80 MSGET oP1Ent  var nP1Ent picture "@E 99.99" when (alHabCpo[nInd][1] .OR. alHabCpo[nInd][2])  size 060,010 VALID valDig('E1') OF oDlg   PIXEL
@ 018, 110 BTNBMP oBtn1 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION  bDesloca('B','E1') oF oDlg

@ 030 ,10 Say "Primeira saida" 	FONT oDlg:oFont PIXEL Of oDlg
@ 030 ,80 MSGET oP1Said  var nP1Said when (alHabCpo[nInd][3] .OR. alHabCpo[nInd][4]) picture "@E 99.99"  size 060,010 VALID  valDig('S1') OF oDlg   PIXEL
@ 058, 110 BTNBMP oBtn2 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION  bDesloca('B','S1') oF oDlg
@ 058, 130 BTNBMP oBtn3 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION  bDesloca('C','S1') oF oDlg

@ 050 ,10 Say "Segunda entrada " 	FONT oDlg:oFont PIXEL Of oDlg
@ 050 ,80 MSGET oP2Ent  var nP2Ent when (alHabCpo[nInd][5] .OR. alHabCpo[nInd][6])  picture "@E 99.99" size 060,010 VALID  valDig('E2') OF oDlg   PIXEL
@ 098, 110 BTNBMP oBtn4 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION  bDesloca('B','E2') oF oDlg
@ 098, 130 BTNBMP oBtn5 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION  bDesloca('C','E2') oF oDlg

@ 070 ,10 Say "Segunda saida" 	FONT oDlg:oFont PIXEL Of oDlg
@ 070 ,80 MSGET oP2Said  var nP2Said when (alHabCpo[nInd][7] .OR. alHabCpo[nInd][8]) picture "@E 99.99"   size 060,010 VALID  valDig('S2') OF oDlg   PIXEL
@ 138, 110 BTNBMP oBtn6 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION bDesloca('B','S2') oF oDlg
@ 138, 130 BTNBMP oBtn7 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION bDesloca('C','S2') oF oDlg

@ 090 ,10 Say "Terceira entrada " 	FONT oDlg:oFont PIXEL Of oDlg
@ 090 ,80 MSGET oP3Ent  var nP3Ent when (alHabCpo[nInd][9] .OR. alHabCpo[nInd][10]) picture "@E 99.99"   size 060,010 VALID  valDig('E3') OF oDlg   PIXEL
@ 178, 110 BTNBMP oBtn8 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION  bDesloca('B','E3') oF oDlg
@ 178, 130 BTNBMP oBtn9 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION  bDesloca('C','E3') oF oDlg

@ 110 ,10 Say "Terceira saida" 	FONT oDlg:oFont PIXEL Of oDlg
@ 110 ,80 MSGET oP3Said  var nP3Said when (alHabCpo[nInd][11] .OR. alHabCpo[nInd][12]) picture "@E 99.99"  size 060,010 VALID  valDig('S3') OF oDlg   PIXEL
@ 218, 110 BTNBMP oBtn10 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION  bDesloca('B','S3') oF oDlg
@ 218, 130 BTNBMP oBtn11 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION  bDesloca('C','S3') oF oDlg

@ 130 ,10 Say "Quarta entrada " 	FONT oDlgKco:oFont PIXEL Of oDlg
@ 130 ,80 MSGET oP4Ent  var nP4Ent when (alHabCpo[nInd][13] .OR. alHabCpo[nInd][14]) picture "@E 99.99"   size 060,010 VALID  valDig('E4') OF oDlg   PIXEL
@ 258, 110 BTNBMP oBtn12 RESOURCE "PMSSETADOWN"	  SIZE 25,25  PIXEL ACTION  bDesloca('B','E4') oF oDlg
@ 258, 130 BTNBMP oBtn13 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION  bDesloca('C','E4') oF oDlg

@ 150 ,10 Say "Quarta saida" 	FONT oDlg:oFont PIXEL Of oDlg
@ 150 ,80 MSGET oP4Said  var nP4Said when (alHabCpo[nInd][15] .OR. alHabCpo[nInd][16]) picture "@E 99.99"  size 060,010 valid valDig('S4') OF oDlg   PIXEL
@ 298, 130 BTNBMP oBtn14 RESOURCE "PMSSETAUP"	  SIZE 25,25  PIXEL ACTION bDesloca('C','S4') oF oDlg

@ 170 ,10 Say "Total de horas:" FONT oDlg:oFont PIXEL Of oDlg
@ 170 ,50 Say TRANSFORM(fConvHr(_nHrTot, 'H') , "@E 99.99")  FONT oDlg:oFont PIXEL Of oDlg	

@ 185 ,10 Say "Problema:" FONT oDlg:oFont PIXEL Of oDlg
@ 185 ,50 Say cProblem   FONT oDlg:oFont PIXEL Of oDlg

@ 200 ,10 Say "Justificativa" FONT oDlg:oFont PIXEL Of oDlg
@ 200 ,50 MSGET oJust var cJust size 160,010 OF oDlg   PIXEL

//verificar se precisa ficar essa linha do focus
@ 010 ,189 MSGET oPz3Ent var nP3Ent  picture "@E 99.99"   size 005,002 OF oDlg   PIXEL
oPz3Ent:setfocus()

DEFINE SBUTTON FROM 10  ,190  TYPE 1 ACTION  bValInf() ENABLE OF oDlg
DEFINE SBUTTON FROM 22.5,190  TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

if nOpca == 1

aArq[nInd][1] := 3

aArq[nInd][5] := nP1Ent
aArq[nInd][6] := nP1Said

aArq[nInd][7] := nP2Ent
aArq[nInd][8] := nP2Said

aArq[nInd][9] := nP3Ent
aArq[nInd][10] := nP3Said

aArq[nInd][11] := nP4Ent
aArq[nInd][12] := nP4Said

aArq[nInd][12] := nP4Said
aArq[nInd][13] := cProblem 
aArq[nInd][14] := cJust 

aArq[nInd][24] := "ZBD"

else
alHabCpo:=aclone(alHabB)
endif

return

static function populavar()
_nHrTot:= 0.00

nP1Ent  := aArq[nInd][5]
nP1Said := aArq[nInd][6]

nP2Ent  := aArq[nInd][7]
nP2Said := aArq[nInd][8]

nP3Ent  := aArq[nInd][9]
nP3Said := aArq[nInd][10]

nP4Ent  := aArq[nInd][11]
nP4Said := aArq[nInd][12]

cProblem:= aArq[nInd][13]
cJust   := aArq[nInd][14]

alHabB  := aclone(alHabCpo)

ob_calcHrs()	 

return

static function valDig(cTip)
local lRetv := .t.
_nHrTot := 0.00

Do Case
Case cTip == 'E1'
//alHabCpo[nInd][1] .OR. alHabCpo[nInd][2]   nP1Ent
alHabCpo[nInd][2] := .T.

Case cTip == 'S1'
//alHabCpo[nInd][3] .OR. alHabCpo[nInd][4]  nP1Said
alHabCpo[nInd][4] := .T.

Case cTip == 'E2'
//alHabCpo[nInd][5] .OR. alHabCpo[nInd][6]   nP2Ent
alHabCpo[nInd][6] := .T.

Case cTip == 'S2'
//alHabCpo[nInd][7] .OR. alHabCpo[nInd][8]  nP2Said
alHabCpo[nInd][8] := .T.

Case cTip == 'E3'
//alHabCpo[nInd][9] .OR. alHabCpo[nInd][10]  nP3Ent
alHabCpo[nInd][10] := .T.

Case cTip == 'S3'
//alHabCpo[nInd][11] .OR. alHabCpo[nInd][12]  nP3Said
alHabCpo[nInd][12] := .T.


Case cTip == 'E4'
//alHabCpo[nInd][13] .OR. alHabCpo[nInd][14]   nP4Ent
alHabCpo[nInd][14] := .T.

Case cTip == 'S4'
//alHabCpo[nInd][15] .OR. alHabCpo[nInd][16]  nP4Said
alHabCpo[nInd][16] := .T.

EndCase

lRetv := bvalDig()
if !lRetv
msgalert('Verifique o valor digitado ele deve estar entre <b>0.00</b> e <b>23.59</b> e o decimal nao pode ser superior a <b>0.59</b>..')
else
ob_calcHrs()		
endif

return lRetv


static function bDesloca(cDir,cMarc)
_nHrTot := 0.00
oPz3Ent:setfocus()
if cMarc == 'E1'
if cDir == 'B' .and.  nP4Said == 0.00 .and. nP1Ent > 0
nP4Said := nP4Ent
nP4Ent  := nP3Said
nP3Said := nP3Ent
nP3Ent  := nP2Said
nP2Said := nP2Ent
nP2Ent  := nP1Said
nP1Said := nP1Ent
nP1Ent  := 0.00

alHabCpo[nInd][15] := alHabCpo[nInd][13]
alHabCpo[nInd][16] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := alHabCpo[nInd][11]
alHabCpo[nInd][14] := alHabCpo[nInd][12]
alHabCpo[nInd][11] := alHabCpo[nInd][09]
alHabCpo[nInd][12] := alHabCpo[nInd][10]
alHabCpo[nInd][9]  := alHabCpo[nInd][7]
alHabCpo[nInd][10] := alHabCpo[nInd][8]
alHabCpo[nInd][7]  := alHabCpo[nInd][5]
alHabCpo[nInd][8]  := alHabCpo[nInd][6]
alHabCpo[nInd][5]  := alHabCpo[nInd][3]
alHabCpo[nInd][6]  := alHabCpo[nInd][4]
alHabCpo[nInd][3]  := alHabCpo[nInd][1]
alHabCpo[nInd][4]  := alHabCpo[nInd][2]
alHabCpo[nInd][1]  := .t.
alHabCpo[nInd][2]  := .t.
endif
endif

if cMarc == 'S1'
if cDir == 'B' .and.  nP4Said == 0.00 .and. nP1Said > 0
nP4Said := nP4Ent
nP4Ent  := nP3Said
nP3Said := nP3Ent
nP3Ent  := nP2Said
nP2Said := nP2Ent
nP2Ent  := nP1Said
nP1Said := 0.00

alHabCpo[nInd][15] := alHabCpo[nInd][13]
alHabCpo[nInd][16] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := alHabCpo[nInd][11]
alHabCpo[nInd][14] := alHabCpo[nInd][12]
alHabCpo[nInd][11] := alHabCpo[nInd][09]
alHabCpo[nInd][12] := alHabCpo[nInd][10]
alHabCpo[nInd][9]  := alHabCpo[nInd][7]
alHabCpo[nInd][10] := alHabCpo[nInd][8]
alHabCpo[nInd][7]  := alHabCpo[nInd][5]
alHabCpo[nInd][8]  := alHabCpo[nInd][6]
alHabCpo[nInd][5]  := alHabCpo[nInd][3]
alHabCpo[nInd][6]  := alHabCpo[nInd][4]
alHabCpo[nInd][3]  := .T.
alHabCpo[nInd][4]  := .T.
endif

if cDir == 'C' .and.  nP1Ent == 0.00 .and. nP1Said > 0
nP1Ent  := nP1Said
nP1Said := nP2Ent
nP2Ent  := nP2Said
nP2Said := nP3Ent
nP3Ent  := nP3Said
nP3Said := nP4Ent
nP4Ent  := nP4Said
nP4Said := 0.00

alHabCpo[nInd][1] := alHabCpo[nInd][3]
alHabCpo[nInd][2] := alHabCpo[nInd][4]
alHabCpo[nInd][3] := alHabCpo[nInd][5]
alHabCpo[nInd][4] := alHabCpo[nInd][6]
alHabCpo[nInd][5] := alHabCpo[nInd][7]
alHabCpo[nInd][6] := alHabCpo[nInd][8]
alHabCpo[nInd][7] := alHabCpo[nInd][9]
alHabCpo[nInd][8] := alHabCpo[nInd][10]
alHabCpo[nInd][9] := alHabCpo[nInd][11]
alHabCpo[nInd][10] := alHabCpo[nInd][12]
alHabCpo[nInd][11] := alHabCpo[nInd][13]
alHabCpo[nInd][12] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := alHabCpo[nInd][15]
alHabCpo[nInd][14] := alHabCpo[nInd][16]
alHabCpo[nInd][15] := .t.
alHabCpo[nInd][16] := .t.
endif
endif

if cMarc == 'E2'
if cDir == 'B' .and.  nP4Said == 0.00 .and. nP2Ent > 0
nP4Said := nP4Ent
nP4Ent  := nP3Said
nP3Said := nP3Ent
nP3Ent  := nP2Said
nP2Said := nP2Ent
nP2Ent  := 0.00

alHabCpo[nInd][15] := alHabCpo[nInd][13]
alHabCpo[nInd][16] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := alHabCpo[nInd][11]
alHabCpo[nInd][14] := alHabCpo[nInd][12]
alHabCpo[nInd][11] := alHabCpo[nInd][09]
alHabCpo[nInd][12] := alHabCpo[nInd][10]
alHabCpo[nInd][9]  := alHabCpo[nInd][7]
alHabCpo[nInd][10] := alHabCpo[nInd][8]
alHabCpo[nInd][7]  := alHabCpo[nInd][5]
alHabCpo[nInd][8]  := alHabCpo[nInd][6]
alHabCpo[nInd][5]  := .t.
alHabCpo[nInd][6]  := .t.
endif

if cDir == 'C' .and.  nP1Said == 0.00 .and. nP2Ent > 0
nP1Said := nP2Ent
nP2Ent  := nP2Said
nP2Said := nP3Ent
nP3Ent  := nP3Said
nP3Said := nP4Ent
nP4Ent  := nP4Said
nP4Said := 0.00

alHabCpo[nInd][3] := alHabCpo[nInd][5]
alHabCpo[nInd][4] := alHabCpo[nInd][6]
alHabCpo[nInd][5] := alHabCpo[nInd][7]
alHabCpo[nInd][6] := alHabCpo[nInd][8]
alHabCpo[nInd][7] := alHabCpo[nInd][9]
alHabCpo[nInd][8] := alHabCpo[nInd][10]
alHabCpo[nInd][9] := alHabCpo[nInd][11]
alHabCpo[nInd][10] := alHabCpo[nInd][12]
alHabCpo[nInd][11] := alHabCpo[nInd][13]
alHabCpo[nInd][12] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := alHabCpo[nInd][15]
alHabCpo[nInd][14] := alHabCpo[nInd][16]
alHabCpo[nInd][15] := .t.
alHabCpo[nInd][16] := .t.
endif
endif

if cMarc == 'S2'
if cDir == 'B' .and.  nP4Said == 0.00 .and. nP2Said > 0
nP4Said := nP4Ent
nP4Ent  := nP3Said
nP3Said := nP3Ent
nP3Ent  := nP2Said
nP2Said := 0.00

alHabCpo[nInd][15] := alHabCpo[nInd][13]
alHabCpo[nInd][16] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := alHabCpo[nInd][11]
alHabCpo[nInd][14] := alHabCpo[nInd][12]
alHabCpo[nInd][11] := alHabCpo[nInd][09]
alHabCpo[nInd][12] := alHabCpo[nInd][10]
alHabCpo[nInd][9]  := alHabCpo[nInd][7]
alHabCpo[nInd][10] := alHabCpo[nInd][8]
alHabCpo[nInd][7]  := .T.
alHabCpo[nInd][8]  := .T.
endif

if cDir == 'C' .and.  nP2Ent == 0.00 .and. nP2Said > 0
nP2Ent  := nP2Said
nP2Said := nP3Ent
nP3Ent  := nP3Said
nP3Said := nP4Ent
nP4Ent  := nP4Said
nP4Said := 0.00

alHabCpo[nInd][5] := alHabCpo[nInd][7]
alHabCpo[nInd][6] := alHabCpo[nInd][8]
alHabCpo[nInd][7] := alHabCpo[nInd][9]
alHabCpo[nInd][8] := alHabCpo[nInd][10]
alHabCpo[nInd][9] := alHabCpo[nInd][11]
alHabCpo[nInd][10] := alHabCpo[nInd][12]
alHabCpo[nInd][11] := alHabCpo[nInd][13]
alHabCpo[nInd][12] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := alHabCpo[nInd][15]
alHabCpo[nInd][14] := alHabCpo[nInd][16]
alHabCpo[nInd][15] := .t.
alHabCpo[nInd][16] := .t.
endif
endif


if cMarc == 'E3'
if cDir == 'B' .and.  nP4Said == 0.00 .and. nP3Ent > 0
nP4Said := nP4Ent
nP4Ent  := nP3Said
nP3Said := nP3Ent
nP3Ent  := 0.00

alHabCpo[nInd][15] := alHabCpo[nInd][13]
alHabCpo[nInd][16] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := alHabCpo[nInd][11]
alHabCpo[nInd][14] := alHabCpo[nInd][12]
alHabCpo[nInd][11] := alHabCpo[nInd][09]
alHabCpo[nInd][12] := alHabCpo[nInd][10]
alHabCpo[nInd][9]  := .t.
alHabCpo[nInd][10] := .t.
endif

if cDir == 'C' .and.  nP2Said == 0.00 .and. nP3Ent > 0
nP2Said := nP3Ent
nP3Ent  := nP3Said
nP3Said := nP4Ent
nP4Ent  := nP4Said
nP4Said := 0.00

alHabCpo[nInd][7] := alHabCpo[nInd][9]
alHabCpo[nInd][8] := alHabCpo[nInd][10]
alHabCpo[nInd][9] := alHabCpo[nInd][11]
alHabCpo[nInd][10] := alHabCpo[nInd][12]
alHabCpo[nInd][11] := alHabCpo[nInd][13]
alHabCpo[nInd][12] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := alHabCpo[nInd][15]
alHabCpo[nInd][14] := alHabCpo[nInd][16]
alHabCpo[nInd][15] := .t.
alHabCpo[nInd][16] := .t.
endif

endif

if cMarc == 'S3'
if cDir == 'B' .and.  nP4Said == 0.00 .and. nP3Said > 0
nP4Said := nP4Ent
nP4Ent  := nP3Said
nP3Said := 0.00

alHabCpo[nInd][15] := alHabCpo[nInd][13]
alHabCpo[nInd][16] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := alHabCpo[nInd][11]
alHabCpo[nInd][14] := alHabCpo[nInd][12]
alHabCpo[nInd][11] := .T.
alHabCpo[nInd][12] := .T.
endif

if cDir == 'C' .and.  nP3Ent == 0.00 .and. nP3Said > 0
nP3Ent  := nP3Said
nP3Said := nP4Ent
nP4Ent  := nP4Said
nP4Said := 0.00

alHabCpo[nInd][9] := alHabCpo[nInd][11]
alHabCpo[nInd][10] := alHabCpo[nInd][12]
alHabCpo[nInd][11] := alHabCpo[nInd][13]
alHabCpo[nInd][12] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := alHabCpo[nInd][15]
alHabCpo[nInd][14] := alHabCpo[nInd][16]
alHabCpo[nInd][15] := .t.
alHabCpo[nInd][16] := .t.
endif
endif

if cMarc == 'E4'
if cDir == 'B' .and.  nP4Said == 0.00 .and. nP4Ent > 0
nP4Said := nP4Ent
nP4Ent  := 0.00
alHabCpo[nInd][15] := alHabCpo[nInd][13]
alHabCpo[nInd][16] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := .t.
alHabCpo[nInd][14] := .t.
Endif

if cDir == 'C' .and.  nP3Said == 0.00 .and. nP4Ent > 0
nP3Said := nP4Ent
nP4Ent  := nP4Said
nP4Said := 0.00

alHabCpo[nInd][11] := alHabCpo[nInd][13]
alHabCpo[nInd][12] := alHabCpo[nInd][14]
alHabCpo[nInd][13] := alHabCpo[nInd][15]
alHabCpo[nInd][14] := alHabCpo[nInd][16]
alHabCpo[nInd][15] := .t.
alHabCpo[nInd][16] := .t.
endif
endif

if cMarc == 'S4'
if cDir == 'C' .and.  nP3Said == 0.00 .and. nP4Ent > 0
nP3Said := nP4Ent
nP4Ent  := nP4Said
nP4Said := 0.00

alHabCpo[nInd][13] := alHabCpo[nInd][15]
alHabCpo[nInd][14] := alHabCpo[nInd][16]
alHabCpo[nInd][15] := .t.
alHabCpo[nInd][16] := .t.
endif
Endif

ob_calcHrs()	 

oP1Ent:Refresh()
oP2Ent:Refresh()
oP3Ent:refresh()
oP4Ent:Refresh()
oP1Said:Refresh()
oP2Said:Refresh()
oP3Said:Refresh()
oP4Said:Refresh()

return



static function bValInf()

local _n := 0
local lret := .f.

//verifica a quantidade de marcacoes
_n := nNumMarc()
if Mod(_n, 2) == 0
lret := .t.
else
msgalert('Numero de marcações <b>('+cvaltochar(_n)+')</b> invalido...','Atenção')
endif

//verifica se nao existem quantidades zeradas entre valores
if lret
lret:= bInter()
if !lret
msgalert('Existem intervalos zerados entre marcações...','Atenção')
endif
endif

if lret
nOpca := 1
oDlg:End()
endif

return


static function nNumMarc()
local _n := 0
if nP1Ent >0
_n += 1
endif

if nP1Said >0
_n += 1
endif

if nP2Ent >0
_n += 1
endif

if nP2Said >0
_n += 1
endif

if nP3Ent >0
_n += 1
endif

if nP3Said >0
_n += 1
endif

if nP4Ent >0
_n += 1
endif

if nP4Ent >0
_n += 1
endif

if nP4Said >0
_n += 1
endif
return _n

static function bvalDig()
local lRetD := .t.

if nP1Ent > 23.59 .or. nP1Ent < 0.00 .or. (nP1Ent - int(nP1Ent) > 0.59)
lRetD := .f.
endif

if nP1Said > 23.59 .or. nP1Said < 0.00 .or. (nP1Said - int(nP1Said) > 0.59)
lRetD := .f.
endif

if nP2Ent > 23.59 .or. nP2Ent < 0.00 .or. (nP2Ent - int(nP2Ent) > 0.59)
lRetD := .f.
endif

if nP2Said > 23.59 .or. nP2Said < 0.00 .or. (nP2Said - int(nP2Said) > 0.59)
lRetD := .f.
endif

if nP3Ent > 23.59 .or. nP3Ent < 0.00 .or. (nP3Ent - int(nP3Ent) > 0.59)
lRetD := .f.
endif

if nP3Said > 23.59 .or. nP3Said < 0.00 .or. (nP3Said - int(nP3Said) > 0.59)
lRetD := .f.
endif

if nP4Ent > 23.59 .or. nP4Ent < 0.00 .or. (nP4Ent - int(nP4Ent) > 0.59)
lRetD := .f.
endif

if nP4Said > 23.59 .or. nP4Said < 0.00 .or. (nP4Said - int(nP4Said) > 0.59)
lRetD := .f.
endif

return (lRetD)


static function bInter()
local lRetI := .t.

if nP1Ent == 0 .and. (nP1Said > 0 .or. nP2Ent > 0 .or. nP2Said > 0 .or. nP3Ent > 0  .or. nP3Said > 0 .or. nP4Ent > 0 .or. nP4Said >0)
lRetI := .f.
endif

if nP1Said == 0 .and. (nP2Ent > 0 .or. nP2Said > 0 .or. nP3Ent > 0  .or. nP3Said > 0 .or. nP4Ent > 0 .or. nP4Said >0)
lRetI := .f.
endif

if nP2Ent == 0 .and. (nP2Said > 0 .or. nP3Ent > 0  .or. nP3Said > 0 .or. nP4Ent > 0 .or. nP4Said >0)
lRetI := .f.
endif

if nP2Said == 0 .and. (nP3Ent > 0  .or. nP3Said > 0 .or. nP4Ent > 0 .or. nP4Said >0)
lRetI := .f.
endif

if nP3Ent == 0 .and. (nP3Said > 0 .or. nP4Ent > 0 .or. nP4Said >0)
lRetI := .f.
endif

if nP3Said == 0 .and. (nP4Ent > 0 .or. nP4Said >0)
lRetI := .f.
endif

if nP4Ent == 0 .and. (nP4Said >0)
lRetI := .f.
endif

return lRetI

static function bQuantMarc(ZBD1E,ZBD1S,ZBD2E,ZBD2S,ZBD3E,ZBD3S,ZBD4E,ZBD4S)
local _nMar := 0

if ZBD1E > 0
_nMar+=1
endif

if ZBD1S > 0
_nMar+=1
endif

if ZBD2E > 0
_nMar+=1
endif

if ZBD2S > 0
_nMar+=1
endif

if ZBD3E > 0
_nMar+=1
endif

if ZBD3S > 0
_nMar+=1
endif

if ZBD4E > 0
_nMar+=1
endif

if ZBD4S > 0
_nMar+=1
endif

return(_nMar)



Static Function ValidPerg()
cAlias := Alias()
aRegs  :={}

AADD(aRegs,{cPerg,"01","Data de         ?","Data de            ?","Data de           ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data ate        ?","Data Ate           ?","Data ate          ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Lider           ?","Lider              ?","Lider             ?","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"04","Centro de custo ?","Centro de custo    ?","Centro de custo   ?","mv_ch4","C",09,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CTT",""})
AADD(aRegs,{cPerg,"05","Matrícula       ?","Matrícula          ?","Matrícula         ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SRA",""})

DbSelectArea("SX1")
DbSetOrder(1)
For i:=1 to Len(aRegs)
If !DbSeek(cPerg+aRegs[i,2])
RecLock("SX1",.T.)
For j:=1 to FCount()
If j<=Len(aRegs[i])
FieldPut(j,aRegs[i,j])
Endif
Next
MsUnlock()
Endif
Next
DbSelectArea(cAlias)
Return


static function retMP()
Private _aMarcacoes	:= {}
Private _aTabCalend  := {}
Private _aTabPadrao  := {}
Private _aRecsMarcAutDele	:= {}
Private _aBatNorm := {}
Private _aBatMarc := {}
Private _aProblems:= {}
Private _aMarc:= {}
Private dPerIni := MV_PAR01
Private dPerFim := MV_PAR02

_cQuery := " SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_TNOTRAB, RA_SEQTURN, RA_CC, RA_ADMISSA "
_cQuery += " FROM " + RETSQLNAME ("SRA") +" AS SRA "
_cQuery += " WHERE SRA.D_E_L_E_T_ = '' AND RA_DEMISSA = '' AND RA_FILIAL = '"+cFilAnt+ "' "
_cQuery += " AND RA_MAT < '900000' AND RA_TNOTRAB <> '999' AND RA_TNOTRAB <> '998'" //AND RA_TPJORNA <> '2' AND RA_TPJORNA <> '3' "
//_cQuery += " AND RA_MAT  = '014434' "
if !empty(MV_PAR03)
//_cQuery += " AND RA_MAT  = '006912' "
endif	
if !empty(MV_PAR04)
_cQuery += " AND RA_CC  = '"+MV_PAR04+"' "
ENDIF
if !empty(MV_PAR05)
_cQuery += " AND RA_MAT = '"+MV_PAR05+"' "
endif
_cQuery += " ORDER BY RA_FILIAL, RA_MAT "

tcquery _cQuery new alias _trba
do while ! _trba -> (eof ())
_aMarcacoes := {}
_aTabCalend := {}
@_aTabPadrao:= {}

IF GetMarcacoes(	@_aMarcacoes			,;	//01 -> Marcacoes dos Funcionarios
@_aTabCalend			,;	//02 -> Calendario de Marcacoes
@_aTabPadrao			,;	//03 -> Tabela Padrao
NIL     	,;	//04 -> Turnos de Trabalho
_dDPIni 	,;	//05 -> Periodo Inicial
_dDPFim	    ,;	//06 -> Periodo Final
_trba->RA_FILIAL	,;	//07 -> Filial
_trba->RA_MAT		,;	//08 -> Matricula
_trba->RA_TNOTRAB	,;	//09 -> Turno
_trba->RA_SEQTURN	,;	//10 -> Sequencia de Turno
_trba->RA_CC			,;	//11 -> Centro de Custo
,;	//12 -> Alias para Carga das Marcacoes
.T.					,;	//13 -> Se carrega Recno em aMarcacoes
.T.		 			,;	//14 -> Se considera Apenas Ordenadas
NIL					,;  //15 -> Verifica as Folgas Automaticas
NIL  				,;  //16 -> Se Grava Evento de Folga Mes Anterior
NIL					,;	//17 -> Se Carrega as Marcacoes Automaticas
@_aRecsMarcAutDele	 ;	//18 -> Registros de Marcacoes Automaticas que deverao ser Deletados
)
//u_showarray(_aTabCalend)
//u_showarray(_aMarcacoes)
_aBatNorm := {}
_cOrdemI := _aTabCalend[ascan(_aTabCalend, {|x|x[1] == dPerIni})][2]
_cOrdemF := _aTabCalend[ascan(_aTabCalend, {|x|x[1] == dPerFim})][2]

for _x1:= 1 to len(_aTabCalend)
if _aTabCalend[_x1][6] == "S"; //dia normal
.and. empty(_aTabCalend[_x1][25]); //afastamento
.and. _aTabCalend[_x1][2] >= _cOrdemI;			
.and. _aTabCalend[_x1][2] <= _cOrdemF;						
.and. _aTabCalend[_x1][1] >= STOD(_trba->RA_ADMISSA)

//monto array com quantidade batidas no dia normal
//_nLocal := ascan(_aBatNorm, {|x|x[1] == _aTabCalend[_x1][2]})
_nLocal := ascan(_aBatNorm, {|x|x[1] == _aTabCalend[_x1][2]})
if _nLocal == 0
AAdd( _aBatNorm, { _aTabCalend[_x1][2], 1 } )
else
_aBatNorm[_nLocal][2] := _aBatNorm[_nLocal][2] + 1
endif

endif
next _x1
//u_showarray(_aBatNorm)
_aBatMarc := {}
for _x2:= 1 to len(_aMarcacoes)
if _aMarcacoes[_x2][3] >= _cOrdemI .and. _aMarcacoes[_x2][3] <= _cOrdemF
//monto array com quantidade batidas no dia normal
_nLocal := ascan(_aBatMarc, {|x|x[1] == _aMarcacoes[_x2][3]})
if _nLocal == 0
AAdd( _aBatMarc, { _aMarcacoes[_x2][3], 1 } )
else
_aBatMarc[_nLocal][2] := _aBatMarc[_nLocal][2] + 1
endif

endif
next _x2
//u_showarray(_aBatMarc)
_aProblems := {}
for _x3:= 1 to len(_aBatNorm)
_nLocal := ascan(_aBatMarc, {|x|x[1] == _aBatNorm[_x3][1]})
if _nLocal == 0
aadd(_aProblems, { _aBatNorm[_x3][1], "Sem marcações, deveriam ter ";
+TRANSFORM(_aBatNorm[_x3][2],'9')+" marcações nesse dia." } )
elseif _aBatMarc[_nLocal][2] < _aBatNorm[_x3][2]
aadd(_aProblems, { _aBatNorm[_x3][1], "Menos marcações que padrão, deveriam ter " ;
+TRANSFORM(_aBatNorm[_x3][2],'9')+" marcações nesse dia." } )
endif
next _x3

for _x4:= 1 to len(_aBatMarc)
if mod(_aBatMarc[_x4][2],2) > 0 .and. ascan(_aProblems, {|x|x[1] == _aBatMarc[_x4][1]}) == 0
aadd(_aProblems, { _aBatMarc[_x4][1], "Marcações ímpares"} )
endif
next _x4

for _x5:=1 to len(_aProblems)
_nLocal := ascan(_aTabCalend, {|x|x[2] == _aProblems[_x5][1]})
_aMarc:= {}

//se não tiver abono nesse dia
if !_lTemAbono(_aTabCalend[_nLocal][1], _trba->RA_MAT) .and.;
!_lTemCodInf(_aTabCalend[_nLocal][1], _trba->RA_MAT)						

for _x6:=1 to len(_aMarcacoes)
if 	_aMarcacoes[_x6][3] == _aProblems[_x5][1]
aadd(_aMarc, { _aMarcacoes[_x6][2], _aMarcacoes[_x6][4], _aMarcacoes[_x6][3] })
endif
next _x6

//u_showarray(_aMarc)
DbSelectArea('ZBD')
DbSetOrder(1)
dbSeek(xFilial('ZBD')+ _trba->RA_MAT + DTOS(_aTabCalend[_nLocal][1]),.T.)
if found() .AND. empty(ZBD->ZBD_SIMPOR) .AND. ZBD->ZBD_FILFUN == cFilAnt
Aadd(aArq,{3,_aTabCalend[_nLocal][1] ,_trba->RA_MAT,_trba->RA_NOME,;
ZBD->ZBD_1E,; //5
ZBD->ZBD_1S,;
ZBD->ZBD_2E,;
ZBD->ZBD_2S,;
ZBD->ZBD_3E,;
ZBD->ZBD_3S,;//10
ZBD->ZBD_4E,;
ZBD->ZBD_4S,;
ZBD->ZBD_PROBLE,;
ZBD->ZBD_JUST,;
"E",;//15
"E",;
"E",;
"E",;
"E",;
"E",;//20
"E",;
"E",;
ZBD->ZBD_ORDEM,;
'ZBD',;					
})					
else					
Aadd(aArq,{2,_aTabCalend[_nLocal][1] ,_trba->RA_MAT,_trba->RA_NOME,;
iif(len(_aMarc)>0, _aMarc[1][1], 0),; //5
iif(len(_aMarc)>1, _aMarc[2][1], 0),;
iif(len(_aMarc)>2, _aMarc[3][1], 0),;
iif(len(_aMarc)>3, _aMarc[4][1], 0),;
iif(len(_aMarc)>4, _aMarc[5][1], 0),;
iif(len(_aMarc)>5, _aMarc[6][1], 0),;//10
iif(len(_aMarc)>6, _aMarc[7][1], 0),;
iif(len(_aMarc)>7, _aMarc[8][1], 0),;
_aProblems[_x5][2],;
space(50),;
iif(len(_aMarc)>0, _aMarc[1][2], "I"),;//15
iif(len(_aMarc)>1, _aMarc[2][2], "I"),;
iif(len(_aMarc)>2, _aMarc[3][2], "I"),;
iif(len(_aMarc)>3, _aMarc[4][2], "I"),;
iif(len(_aMarc)>4, _aMarc[5][2], "I"),;
iif(len(_aMarc)>5, _aMarc[6][2], "I"),;//20
iif(len(_aMarc)>6, _aMarc[7][2], "I"),;
iif(len(_aMarc)>7, _aMarc[8][2], "I"),;
_aTabCalend[_nLocal][2],;
'SP8',;					
})
endif
endif					
next _x5
endif

dbSelectArea("_trba")
dbSkip()
enddo
dbSelectArea("_trba")
_trba->(DbCloseArea())


for _nx:= 1 to len(aArq)
//array que vai habilitar ou nao o campo de edição dos GETS, se as marcações tiveram conteudo eu seto .f.
//O .f. seguinte serve para setar .t. quando eu digitar um conteudo em um campo que nao tiver conteudo
Aadd(alHabCpo,{iif(aArq[_nx][ 5]>0, .f., .t.),iif(aArq[_nx][ 15] == 'E', .f., .t.),;
iif(aArq[_nx][ 6]>0, .f., .t.),iif(aArq[_nx][ 16] == 'E', .f., .t.),;
iif(aArq[_nx][ 7]>0, .f., .t.),iif(aArq[_nx][ 17] == 'E', .f., .t.),;
iif(aArq[_nx][ 8]>0, .f., .t.),iif(aArq[_nx][ 18] == 'E', .f., .t.),;
iif(aArq[_nx][ 9]>0, .f., .t.),iif(aArq[_nx][ 19] == 'E', .f., .t.),;
iif(aArq[_nx][10]>0, .f., .t.),iif(aArq[_nx][ 20] == 'E', .f., .t.),;
iif(aArq[_nx][11]>0, .f., .t.),iif(aArq[_nx][ 21] == 'E', .f., .t.),;
iif(aArq[_nx][12]>0, .f., .t.),iif(aArq[_nx][ 22] == 'E', .f., .t.)})
next _nx	

return


static function _lTemAbono(_dData1, _cMat)
Local _cQuery := ""
Local _nCount := 0
_cQuery := " SELECT COUNT(*) AS CONT "
_cQuery += " FROM " + RETSQLNAME ("SPK") +" AS SPK  "
_cQuery += " WHERE SPK.D_E_L_E_T_ = '' AND PK_MAT = '"+_cMat+"' AND PK_FILIAL = '"+cFilAnt+"' "
_cQuery += " AND PK_DATA = '"+dtos(_dData1)+"' " //"AND PK_CODEVE = '"+_cPdAb+"' "

tcquery _cQuery new alias _trbb

do while !_trbb->(eof())
_nCount := _trbb->CONT
dbSelectArea("_trbb")
dbSkip()
enddo
dbSelectArea("_trbb")
_trbb->(DbCloseArea())

return(_nCount > 0)


static function _lTemCodInf (_dData1, _cMat)
Local _cQuery := ""
Local _nCount := 0
_cQuery := " SELECT COUNT(*) AS CONT "
_cQuery += " FROM " + RETSQLNAME ("SPC") +" AS SPC  "
_cQuery += " WHERE SPC.D_E_L_E_T_ = '' AND PC_MAT = '"+_cMat+"' AND PC_FILIAL = '"+cFilAnt+"' "
_cQuery += " AND PC_DATA = '"+dtos(_dData1)+"' AND PC_PDI <> '' " //"AND PK_CODEVE = '"+_cPdAb+"' "

tcquery _cQuery new alias _trbb

do while !_trbb->(eof())
_nCount := _trbb->CONT
dbSelectArea("_trbb")
dbSkip()
enddo
dbSelectArea("_trbb")
_trbb->(DbCloseArea())

return(_nCount > 0)


static function ob_calcHrs ()
if nP1Said > 0 .and. nP1Ent > 0
if nP1Ent > nP1Said
_nHrTot += 24-fConvHr(nP1Ent, 'D') + fConvHr(nP1Said, 'D')
else
_nHrTot += fConvHr(nP1Said, 'D') - fConvHr(nP1Ent, 'D')
endif	
endif
if nP2Said > 0 .and. nP2Ent > 0
if nP2Ent > nP2Said
_nHrTot += 24-fConvHr(nP2Ent, 'D') + fConvHr(nP2Said, 'D')
else
_nHrTot += fConvHr(nP2Said, 'D') - fConvHr(nP2Ent, 'D')
endif	
endif	
if nP3Said > 0 .and. nP3Ent > 0
if nP3Ent > nP3Said
_nHrTot += 24-fConvHr(nP3Ent, 'D') + fConvHr(nP3Said, 'D')
else
_nHrTot += fConvHr(nP3Said, 'D') - fConvHr(nP3Ent, 'D')
endif	
endif
if nP4Said > 0 .and. nP4Ent > 0
if nP4Ent > nP4Said
_nHrTot += 24-fConvHr(nP4Ent, 'D') + fConvHr(nP4Said, 'D')
else
_nHrTot += fConvHr(nP4Said, 'D') - fConvHr(nP4Ent, 'D')
endif	
endif
return
*/	
